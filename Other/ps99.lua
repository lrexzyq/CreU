
--==================================================================
-- Services / core refs
--==================================================================
local Players       = game:GetService("Players")
local RS            = game:GetService("ReplicatedStorage")
local UserInput     = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local RunService    = game:GetService("RunService")
local HttpService   = game:GetService("HttpService")
local LocalPlayer   = Players.LocalPlayer

local function req(path)
	local ok, mod = pcall(require, path)
	if ok then return mod end
	return nil
end

local Library      = RS:WaitForChild("Library")
local TradingCmds  = req(Library.Client.TradingCmds)
local AbstractItem = req(Library.Items.AbstractItem)
local Functions    = req(Library.Functions)
local TradingCfg   = req(Library.Types.Trading) -- config: ItemLimit, ReadyDuration, PresetMessages...
-- inventory / item modules (for the Spawner tab)
local InventoryCmds = req(Library.Client.InventoryCmds)
local ItemTypes     = req(Library.Items.Types)     -- item registry: ItemTypes.From(class, data)
local CurrencyCmds  = req(Library.Client.CurrencyCmds)
local PetController  = req(Library.Client.PetCmds.Controller) -- server-gated equip path
local PetCmds        = req(Library.Client.PetCmds)
local PlayerPet      = req(Library.Client.PlayerPet)           -- CLIENT-side pet spawn/render
local RAPCmds        = req(Library.Client.RAPCmds)             -- diamond value ("worth")
local ExistCountCmds = req(Library.Client.ExistCountCmds)      -- global item existence counts
local EquipController = PetController                          -- Library.Client.PetCmds.Controller
local PetNetworking  = req(Library.Client.PetNetworking)       -- EquippedPets() / EquippedPetsChanged
local Riding         = req(Library.Client.CustomPet.Riding)    -- riding cleanup / recovery
local ItemUI         = req(Library.Client.UI.ItemUI)           -- inventory tile builder
local ItemContainerUI = req(Library.Client.UI.ItemContainerUI) -- inventory render/hide helper
-- NOTE: never require Library.Directory.Pets directly (it errors / can poison the
-- module cache). Pull the valid-pet list from the already-loaded Pet type instead.

if not TradingCmds then
	warn("[MockTrade] Could not require TradingCmds - aborting. Check the module path.")
	return
end

local READY_DURATION = (TradingCfg and TradingCfg.ReadyDuration) or 5
local MOD_LOCK       = (TradingCfg and TradingCfg.ModificationReadyDuration) or 3
local PRESETS        = (TradingCfg and TradingCfg.PresetMessages) or {}
local PARTNER_DELAY  = 0.5 -- seconds the partner waits before mirroring your ready/confirm

local function now() return workspace:GetServerTimeNow() end

--==================================================================
-- Executor helpers (make a possibly-frozen table writable, fire events)
--==================================================================
local function unlock(tbl)
	-- best-effort: different executors expose different unlock functions
	pcall(function() if setreadonly then setreadonly(tbl, false) end end)
	pcall(function() if make_writeable then make_writeable(tbl) end end)
	pcall(function() if makewriteable then makewriteable(tbl) end end)
	pcall(function()
		local getmt = getrawmetatable or debug and debug.getmetatable
		local mt = getmt and getmt(tbl)
		if mt then
			if setreadonly then pcall(setreadonly, mt, false) end
			pcall(function() mt.__newindex = nil end)
		end
	end)
end

-- assign tbl[key] = fn, unlocking the table if the first attempt fails
local function setfn(tbl, key, fn)
	if pcall(function() tbl[key] = fn end) and tbl[key] == fn then
		return true
	end
	unlock(tbl)
	local ok = pcall(function() tbl[key] = fn end)
	return ok and tbl[key] == fn
end

-- fire one of the game's Event objects (supports FireAsync / SynchronousFire / Fire)
local function fire(evt, ...)
	if not evt then return end
	if pcall(evt.FireAsync, evt, ...) then return end
	if pcall(evt.SynchronousFire, evt, ...) then return end
	pcall(evt.Fire, evt, ...)
end

-- Set this thread's identity to a normal game-script level. Item rendering (esp.
-- huge pets) lazily require()s modules; if that first load runs on the executor's
-- own thread it gets the wrong context ("Cannot require a non-RobloxScript module
-- from a RobloxScript"). Running injection/equip at identity 2 makes those loads
-- behave like the game's. Best-effort across executor APIs.
local function setIdentity(n)
	pcall(function() if setthreadidentity then setthreadidentity(n) end end)
	pcall(function() if getgenv and getgenv().syn and getgenv().syn.set_thread_identity then getgenv().syn.set_thread_identity(n) end end)
	pcall(function() if syn and syn.set_thread_identity then syn.set_thread_identity(n) end end)
	pcall(function() if setidentity then setidentity(n) end end)
	pcall(function() if setthreadcontext then setthreadcontext(n) end end)
end

--==================================================================
-- Silent player block helper (the supplied implementation)
--==================================================================
local silentBlockPlayer
(function()
	local SilentBlockConfig = {
		modalAppearTimeout = 10,
		modalDismissTimeout = 10,
		maxAttempts = 20,
		overlayName = "FoundationOverlay",
		modalName = "BlockingModalScreen",
	}

	local SilentBlockServices = {
		CoreGui = game:GetService("CoreGui"),
		StarterGui = game:GetService("StarterGui"),
		RunService = game:GetService("RunService"),
		GuiService = game:GetService("GuiService"),
		VirtualInputManager = game:GetService("VirtualInputManager"),
	}

	local SilentBlockHideOps = {
		{ class = "ScreenGui", apply = function(n) n.Enabled = false end },
		{ class = "GuiObject", apply = function(n) n.Visible = false; n.BackgroundTransparency = 1 end },
		{ class = "ImageLabel", apply = function(n) n.ImageTransparency = 1 end },
		{ class = "ImageButton", apply = function(n) n.ImageTransparency = 1 end },
		{ class = "TextLabel", apply = function(n) n.TextTransparency = 1 end },
		{ class = "TextButton", apply = function(n) n.TextTransparency = 1 end },
		{ class = "UIStroke", apply = function(n) n.Transparency = 1 end },
	}

	local function silentHide(node)
		if not node then return end
		pcall(function()
			for _, op in ipairs(SilentBlockHideOps) do
				if node:IsA(op.class) then pcall(op.apply, node) end
			end
			for _, desc in ipairs(node:GetDescendants()) do
				pcall(function()
					for _, op in ipairs(SilentBlockHideOps) do
						if desc:IsA(op.class) then pcall(op.apply, desc) end
					end
				end)
			end
		end)
	end

	local function findOverlay()
		return SilentBlockServices.CoreGui:FindFirstChild(SilentBlockConfig.overlayName)
	end

	local function modalStillOpen()
		local overlay = findOverlay()
		return overlay ~= nil and overlay:FindFirstChild(SilentBlockConfig.modalName, true) ~= nil
	end

	local function fireAllConnections(button)
		pcall(function()
			if not getconnections then return end
			for _, signalName in ipairs({ "MouseButton1Click", "Activated", "MouseButton1Down", "MouseButton1Up" }) do
				for _, connection in pairs(getconnections(button[signalName])) do
					pcall(function() if connection.Fire then connection:Fire() end end)
					pcall(function() if connection.Function then connection.Function() end end)
				end
			end
		end)
	end

	local function findBlockButton(modal)
		local button
		pcall(function()
			button = modal.BlockingModalContainerWrapper.BlockingModal.AlertModal.AlertContents.Footer.Buttons["3"]
		end)
		if button then return button end
		pcall(function()
			local container = modal:FindFirstChild("Buttons", true)
			if not container then return end
			for _, child in ipairs(container:GetChildren()) do
				if child:IsA("ImageButton") or child:IsA("TextButton") then
					local label = child:FindFirstChild("Text")
					if label and label:IsA("TextLabel") and label.Text == "Block" then
						button = child
						return
					end
				end
			end
			if not button then button = container:FindFirstChild("3") end
		end)
		if button then return button end
		pcall(function()
			for _, desc in ipairs(modal:GetDescendants()) do
				if desc:IsA("ImageButton") or desc:IsA("TextButton") then
					local label = desc:FindFirstChild("Text")
					if label and label:IsA("TextLabel") and label.Text == "Block" then
						button = desc
						return
					end
				end
			end
		end)
		return button
	end

	local strategies = {
		{ run = function(button) fireAllConnections(button) end, settle = 0.05 },
		{ run = function(button)
			pcall(function() if firesignal then firesignal(button.MouseButton1Click) end end)
			pcall(function() if fireclick then fireclick(button) end end)
		end, settle = 0.05 },
		{ run = function(button)
			pcall(function() SilentBlockServices.GuiService.SelectedObject = button end)
			task.wait()
			pcall(function()
				local vim = SilentBlockServices.VirtualInputManager
				vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
				vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
			end)
		end, settle = 0.05, skipCheck = true },
		{ run = function(button)
			pcall(function()
				local position, size = button.AbsolutePosition, button.AbsoluteSize
				local vim = SilentBlockServices.VirtualInputManager
				vim:SendMouseButtonEvent(position.X + size.X / 2, position.Y + size.Y / 2, 0, true, game, 1)
				task.wait()
				vim:SendMouseButtonEvent(position.X + size.X / 2, position.Y + size.Y / 2, 0, false, game, 1)
			end)
		end, settle = 0.15 },
	}

	silentBlockPlayer = function(selected)
		if typeof(selected) ~= "Instance" or not selected:IsA("Player") then
			return false, "Roblox can only block a live Player"
		end

		pcall(function() setthreadidentity(8) end)
		local watchers = {}
		pcall(function()
			local connection = SilentBlockServices.CoreGui.DescendantAdded:Connect(function(descendant)
				if descendant.Name == SilentBlockConfig.modalName then
					silentHide(descendant)
					table.insert(watchers, descendant.DescendantAdded:Connect(function() silentHide(descendant) end))
				end
			end)
			table.insert(watchers, connection)
		end)

		local started, modal = tick(), nil
		local opened, openError = pcall(function()
			SilentBlockServices.StarterGui:SetCore("PromptBlockPlayer", selected)
		end)
		if not opened then
			for _, watcher in ipairs(watchers) do pcall(function() watcher:Disconnect() end) end
			pcall(function() setthreadidentity(2) end)
			return false, tostring(openError)
		end

		while not modal do
			SilentBlockServices.RunService.Heartbeat:Wait()
			if tick() - started > SilentBlockConfig.modalAppearTimeout then
				for _, watcher in ipairs(watchers) do pcall(function() watcher:Disconnect() end) end
				pcall(function() setthreadidentity(2) end)
				return false, "Block prompt did not appear"
			end
			local overlay = findOverlay()
			if overlay then modal = overlay:FindFirstChild(SilentBlockConfig.modalName, true) end
		end

		silentHide(modal)
		local hideConnection
		hideConnection = SilentBlockServices.RunService.Heartbeat:Connect(function()
			if modal and modal.Parent then silentHide(modal) else hideConnection:Disconnect() end
		end)
		local button = findBlockButton(modal)
		if button then
			for _ = 1, SilentBlockConfig.maxAttempts do
				local dismissed = false
				for _, strategy in ipairs(strategies) do
					strategy.run(button)
					task.wait(strategy.settle)
					if not strategy.skipCheck and not modalStillOpen() then dismissed = true break end
				end
				if dismissed then break end
			end
		end

		pcall(function() if hideConnection then hideConnection:Disconnect() end end)
		for _, watcher in ipairs(watchers) do pcall(function() watcher:Disconnect() end) end
		pcall(function() SilentBlockServices.GuiService.SelectedObject = nil end)
		local timeout = tick() + SilentBlockConfig.modalDismissTimeout
		while tick() < timeout and modalStillOpen() do SilentBlockServices.RunService.Heartbeat:Wait() end
		pcall(function() setthreadidentity(2) end)
		return not modalStillOpen(), button and "Block request submitted" or "Block button was not found"
	end
end)()
_G._silentBlockPlayer = silentBlockPlayer

-- Reveal item value info on hovers: RAPCmds.ShowValues is gated to admin UserIds,
-- and the RAP / RAPOverlay FFlags gate the "worth" display. Turn them on so pet
-- hovers show exist count + diamond value (for mock pets and real ones alike).
pcall(function() if RAPCmds then RAPCmds.ShowValues = true end end)
pcall(function()
	local FF = req(Library.Client.FFlags)
	if FF and FF.currentData and FF.Keys then
		unlock(FF.currentData)
		for _, k in ipairs({ "RAP", "RAPOverlay" }) do
			local key = FF.Keys[k]
			key = (type(key) == "table" and key.Key) or key
			if type(key) == "string" then FF.currentData[key] = true end
		end
	end
end)

--==================================================================
-- Mock state
--==================================================================
local Mock = {
	active         = false,
	pendingRequest = false,
	partner        = nil,
	state          = nil,
	id             = 90000000,          -- arbitrary mock trade id
	autoReady      = false,             -- auto-click YOUR Ready button while a trade is open
	autoConfirm    = false,             -- auto-click YOUR Confirm button once both are ready
	myDiamonds     = 0,
	completeToken  = 0,
	blockedUserIds = {},                -- mock-only blocks for users not present in this server
}

-- Methods the trade UI calls on a TradeState object.
local StateMethods = {}
StateMethods.__index = StateMethods
function StateMethods:PlayerIndex(plr) return table.find(self._players, plr) end
function StateMethods:Index1(i)        return i end
function StateMethods:Index2(i)        return 3 - i end
function StateMethods:Player1(i)       return self._players[i] end
function StateMethods:Player2(i)       return self._players[3 - i] end
function StateMethods:IsEveryoneReady()
	return self._ready[1] and self._ready[2] and true or false
end

-- lightweight "Currency" item stand-in (only the methods the UI touches)
local function makeCurrency(amount)
	local c = {}
	function c:IsA(cls)       return cls == "Currency" end
	function c:GetAmount()    return amount end
	function c:IsRAPVisible() return false end
	function c:GetRAP()       return 0 end
	function c:IsTradable()   return true end
	function c:GetUID()       return "MockDiamonds" end
	function c:GetName()      return "Diamonds" end
	function c:Clone()        return c end
	return c
end

--==================================================================
-- Fake partner (behaves enough like a Player for the trade UI)
--==================================================================
local function buildPartner(username)
	username = (username ~= "" and username) or "MockPartner"
	local userId = 1
	pcall(function()
		userId = Players:GetUserIdFromNameAsync(username)
	end)
	local p = {
		Name        = username,
		DisplayName = username,
		UserId      = userId,
		__isMock    = true,
	}
	function p:GetAttribute() return nil end
	function p:IsA(cls) return cls == "Player" or cls == "Instance" end
	return p
end

--==================================================================
-- Mock request entry in the game's Trade Player List
--==================================================================
-- The game's list removes children carrying its "Trader" attribute whenever
-- there is no matching Player instance.  This mock row deliberately uses its
-- own marker, so it can stay visible until this mock request is resolved.
local MOCK_LIST_ENTRY_NAME = "__MockTradeRequest"
local mockListConnection

local function getTradeListParts()
	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local tradeListGui = playerGui and playerGui:FindFirstChild("TradePlayerList")
	local frame = tradeListGui and tradeListGui:FindFirstChild("Frame")
	return frame, frame and frame:FindFirstChild("Players")
end

local function removeMockTradeListEntry()
	if mockListConnection then
		mockListConnection:Disconnect()
		mockListConnection = nil
	end

	local _, list = getTradeListParts()
	if not list then return end

	local row = list:FindFirstChild(MOCK_LIST_ENTRY_NAME)
	if row then row:Destroy() end
end

local function addMockTradeListEntry()
	removeMockTradeListEntry()
	if not Mock.pendingRequest or not Mock.partner then return end

	local frame, list = getTradeListParts()
	local template = RS:FindFirstChild("Assets")
		and RS.Assets:FindFirstChild("UI")
		and RS.Assets.UI:FindFirstChild("Trading")
		and RS.Assets.UI.Trading:FindFirstChild("PlayerList")
		and RS.Assets.UI.Trading.PlayerList:FindFirstChild("Player")
	if not frame or not list or not template then
		-- The player-list UI can finish loading after this script.  Retry only
		-- while the request remains pending, so the Accept row is not missed.
		task.delay(0.5, function()
			if Mock.pendingRequest then addMockTradeListEntry() end
		end)
		return
	end

	local row = template:Clone()
	row.Name = MOCK_LIST_ENTRY_NAME
	row:SetAttribute("MockTradeEntry", true)
	row.LayoutOrder = 1

	local nameHolder = row:FindFirstChild("NameHolder")
	if nameHolder then
		local usernameLabel = nameHolder:FindFirstChild("Username")
		local displayLabel = nameHolder:FindFirstChild("Display")
		if usernameLabel then usernameLabel.Text = Mock.partner.Name end
		if displayLabel then displayLabel.Text = Mock.partner.DisplayName end
	end

	local icon = row:FindFirstChild("Icon")
	if icon then
		local friend = icon:FindFirstChild("Friend")
		if friend then friend.Visible = false end

		local rank = icon:FindFirstChild("Rank")
		if rank then rank.Visible = false end

		task.spawn(function()
			local image
			pcall(function()
				image = Players:GetUserThumbnailAsync(
					Mock.partner.UserId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size48x48
				)
			end)
			if row.Parent and image then icon.Image = image end
		end)
	end

	local buttonHolder = row:FindFirstChild("ButtonHolder")
	local acceptButton = buttonHolder and buttonHolder:FindFirstChild("Trade")
	if acceptButton then
		local label = acceptButton:FindFirstChild("TextLabel")
		if label then label.Text = "Accept!" end

		pcall(function()
			Functions.GradientSwap(acceptButton, RS.Assets.UI.Gradients.GreenGradient)
		end)

		acceptButton.Activated:Connect(function()
			if Mock.pendingRequest and Mock.partner then
				-- Let the player-list click finish before opening the TradeWindow.
				-- Its inventory grid is populated by the TradeCreated listener.
				task.defer(function()
					if Mock.pendingRequest and Mock.partner then
						TradingCmds.Request(Mock.partner)
					end
				end)
			end
		end)
	end

	row.Parent = list

	-- The base list will otherwise show "Nobody to trade with" when the mock
	-- is the only entry.  Keep that empty-state label hidden while it exists.
	mockListConnection = RunService.RenderStepped:Connect(function()
		if not Mock.pendingRequest then
			removeMockTradeListEntry()
			return
		end
		if not row.Parent then
			-- The game's list rebuild may have cleared the cloned row.
			addMockTradeListEntry()
			return
		end
		local noneAvailable = frame:FindFirstChild("NoneAvailable")
		if noneAvailable then noneAvailable.Visible = false end
	end)
end

--==================================================================
-- State / timer logic
--==================================================================
local settleSuccessfulMockTrade

local function cancelCompletion()
	Mock.completeToken = Mock.completeToken + 1
end

local function endTrade(message)
	if not Mock.active then return end
	local st = Mock.state
	if message == "Trade successfully\ncompleted!" and settleSuccessfulMockTrade then
		settleSuccessfulMockTrade(st)
	end
	cancelCompletion()
	Mock.active         = false
	Mock.pendingRequest = false
	Mock.state          = nil
	if st then st._destroyed = true end
	removeMockTradeListEntry()
	-- Fire the game's TradeDestroyed -> real UI closes the window.
	-- NOTE: avoid the word "successfully" so the built-in
	-- "friend this player?" prompt (which needs a real Player) is skipped.
	fire(TradingCmds.TradeDestroyed, Mock.id, message, Mock.partner)
end

local function scheduleCompletion()
	cancelCompletion()
	local token = Mock.completeToken
	local st = Mock.state
	task.delay(READY_DURATION, function()
		if token ~= Mock.completeToken then return end
		if not Mock.active or Mock.state ~= st then return end
		if not (st._confirmed[1] and st._confirmed[2]) then return end
		st._executing = true
		fire(TradingCmds.TradeExecuting, Mock.id)
		task.wait(0.6)
		if token ~= Mock.completeToken then return end
		endTrade("Trade successfully\ncompleted!") -- fixed by blueprint.lua on discord best coder in the world w speed for blueprint.lua
	end)
end

local function recomputeReady()
	local st = Mock.state
	if not st then return end
	if st._ready[1] and st._ready[2] then
		if not st._readyTimer then
			st._readyTimer = now()
		end
	else
		st._readyTimer     = nil
		st._confirmedTimer = nil
		st._confirmed      = { false, false }
		cancelCompletion()
	end
end

local function recomputeConfirm()
	local st = Mock.state
	if not st then return end
	if st._readyTimer and st._confirmed[1] and st._confirmed[2] then
		if not st._confirmedTimer then
			st._confirmedTimer = now() + READY_DURATION
			scheduleCompletion()
		end
	else
		st._confirmedTimer = nil
		cancelCompletion()
	end
end

local function setPartnerReady(v)
	local st = Mock.state
	if not st then return end
	st._ready[2] = v
	if not v then st._confirmed[2] = false end
	fire(TradingCmds.TradeSetReady, Mock.id, 2, v)
	recomputeReady()
end

local function setPartnerConfirmed(v)
	local st = Mock.state
	if not st then return end
	if not st._readyTimer then return end
	st._confirmed[2] = v
	recomputeConfirm()
end

--==================================================================
-- Open the trade (fire TradeCreated -> real window opens)
--==================================================================
local function openTrade()
	if Mock.active then return end
	cancelCompletion()
	local st = setmetatable({
		_destroyed     = false,
		_executing     = false,
		_counter       = 1,
		_id            = Mock.id,
		_players       = { LocalPlayer, Mock.partner },
		_ready         = { false, false },
		_confirmed     = { false, false },
		_items         = { {}, {} },
		_readyTimer    = nil,
		_confirmedTimer= nil,
		_lastModified  = now() - MOD_LOCK, -- so Ready is available immediately
	}, StateMethods)

	Mock.state          = st
	Mock.myDiamonds     = 0
	Mock.pendingRequest = false
	Mock.active         = true -- must be true BEFORE firing so GetState() resolves

	-- (id, player1, player2, lastModified); the UI flips so player2 = partner side
	fire(TradingCmds.TradeCreated, Mock.id, LocalPlayer, Mock.partner, st._lastModified)

	-- auto-ready / auto-confirm watcher: clicks YOUR Ready/Confirm for you.
	-- Ready waits out the modification lock so you can add items first.
	task.spawn(function()
		while Mock.active and Mock.state == st do
			if Mock.autoReady and not st._ready[1] and (now() - st._lastModified) >= MOD_LOCK then
				pcall(function() TradingCmds.SetReady(true) end)
			end
			if Mock.autoConfirm and st._readyTimer and st._ready[1] and not st._confirmed[1] then
				pcall(function() TradingCmds.SetConfirmed(true) end)
			end
			task.wait(0.25)
		end
	end)
end

--==================================================================
-- Install TradingCmds overrides (fall through to originals when idle)
--==================================================================
local orig = {}
local function wrap(name, impl)
	orig[name] = TradingCmds[name]
	setfn(TradingCmds, name, impl)
end
local function callOrig(name, ...)
	if orig[name] then return orig[name](...) end
end

wrap("GetState", function(id)
	if Mock.active and (id == nil or id == Mock.id) then
		return Mock.state
	end
	return callOrig("GetState", id)
end)

wrap("SetReady", function(v)
	if not Mock.active then return callOrig("SetReady", v) end
	local st = Mock.state
	st._ready[1] = v
	if not v then st._confirmed[1] = false end
	fire(TradingCmds.TradeSetReady, Mock.id, 1, v)
	-- the partner always responds ~0.5s after you ready
	local st2 = st
	task.delay(PARTNER_DELAY, function()
		if Mock.active and Mock.state == st2 and st2._ready[1] == v then
			setPartnerReady(v)
		end
	end)
	recomputeReady()
	return true
end)

wrap("SetConfirmed", function(v)
	if not Mock.active then return callOrig("SetConfirmed", v) end
	local st = Mock.state
	if not st._readyTimer then return false, "Not ready yet" end
	st._confirmed[1] = v
	-- the partner always responds ~0.5s after you confirm
	local st2 = st
	task.delay(PARTNER_DELAY, function()
		if Mock.active and Mock.state == st2 and st2._confirmed[1] == v then
			setPartnerConfirmed(v)
		end
	end)
	recomputeConfirm()
	return true
end)

wrap("SetItem", function(class, uid, amount)
	if not Mock.active then return callOrig("SetItem", class, uid, amount) end
	local st = Mock.state
	st._items[1][class] = st._items[1][class] or {}
	if amount and amount > 0 then
		local item
		pcall(function() item = AbstractItem and AbstractItem:Get(uid) end)
		if item then
			local disp = item
			pcall(function()
				local c = item:Clone()
				pcall(function() c:SetUID(uid) end)
				pcall(function() c:SetAmount(amount) end)
				disp = c
			end)
			st._items[1][class][uid] = disp
		else
			st._items[1][class][uid] = item
		end
	else
		st._items[1][class][uid] = nil
	end
	st._counter      = st._counter + 1
	st._lastModified = now()
	fire(TradingCmds.TradeSetItem, Mock.id, 1, class, uid, st._items[1][class][uid], st._counter, st._lastModified)
	return true
end)

wrap("SetCurrency", function(name, amount)
	if not Mock.active then return callOrig("SetCurrency", name, amount) end
	local st = Mock.state
	if name == "Diamonds" then
		Mock.myDiamonds = amount or 0
		if Mock.myDiamonds > 0 then
			st._items[1].Currency = { Diamonds = makeCurrency(Mock.myDiamonds) }
		else
			st._items[1].Currency = nil
		end
		st._lastModified = now()
	end
	return true
end)

wrap("Message", function(text)
	if not Mock.active then return callOrig("Message", text) end
	if text and text ~= "" then
		fire(TradingCmds.TradeMessage, Mock.id, 1, text)
	end
	return true
end)

wrap("PresetMessage", function(key)
	if not Mock.active then return callOrig("PresetMessage", key) end
	local text = PRESETS[key] or key
	fire(TradingCmds.TradeMessage, Mock.id, 1, text)
	return true
end)

wrap("Decline", function()
    if not Mock.active then return callOrig("Decline") end

    endTrade(LocalPlayer.Name .. " cancelled the trade!") -- blueprint.lua saved the day!
    return true
end)

wrap("Request", function(player)
	-- accept path: the game's request notification's "Yes" calls Request(player)
	if Mock.pendingRequest and player == Mock.partner then
		openTrade()
		return true
	end
	if Mock.active then return true end
	return callOrig("Request", player)
end)

wrap("HasRequestFromPlayer", function(player)
	if Mock.pendingRequest and player == Mock.partner then return true end
	return callOrig("HasRequestFromPlayer", player)
end)

wrap("Reject", function(player)
	if Mock.pendingRequest and player == Mock.partner then
		Mock.pendingRequest = false
		removeMockTradeListEntry()
		return
	end
	return callOrig("Reject", player)
end)

if TradingCmds.HasOutgoingRequestToPlayer then
	wrap("HasOutgoingRequestToPlayer", function(player)
		if Mock.active and player == Mock.partner then return false end
		return callOrig("HasOutgoingRequestToPlayer", player)
	end)
end

--==================================================================
-- Public actions (used by the GUI)
--==================================================================
local partnerName = ""

local function startRequest(username)
	local partner = buildPartner(username)
	if Mock.blockedUserIds[partner.UserId] then
		return false, "That user is blocked from mock trades"
	end

	if Mock.active then endTrade("Restarting mock trade...") task.wait(0.1) end
	removeMockTradeListEntry()
	Mock.partner        = partner
	Mock.pendingRequest = true
	-- best-effort: make sure the Trading FFlag is on so the popup's Accept passes
	pcall(function()
		local FF = req(Library.Client.FFlags)
		if FF and FF.currentData and FF.Keys and FF.Keys.Trading then
			unlock(FF.currentData)
			local key = FF.Keys.Trading
			key = (type(key) == "table" and key.Key) or key
			if type(key) == "string" then FF.currentData[key] = true end
		end
	end)
	-- fire the REAL trade-request notification; the trade only opens when
	-- you press Accept on that popup (-> our Request override -> openTrade).
	fire(TradingCmds.TradeRequested, Mock.partner, LocalPlayer, 0)
	addMockTradeListEntry()
	return true
end

local function getCurrentTradePartner()
	local state = TradingCmds.GetState()
	if not state then return nil end
	local playerIndex = state:PlayerIndex(LocalPlayer)
	if not playerIndex then return nil end
	return state:Player2(playerIndex)
end

local function blockCurrentTradePartner(fallbackUsername)
	local partner = getCurrentTradePartner()
	if not partner and fallbackUsername and fallbackUsername ~= "" then
		partner = buildPartner(fallbackUsername)
	end
	if not partner then return false, "No active trade or username selected" end

	if type(partner) == "table" and partner.__isMock then
		Mock.blockedUserIds[partner.UserId] = true
		local livePlayer = Players:GetPlayerByUserId(partner.UserId)
		if livePlayer then
			task.spawn(function() silentBlockPlayer(livePlayer) end)
			return true, "Real account block started for @" .. partner.Name
		end
		return true, "@" .. partner.Name .. " is blocked from future mock trades"
	end

	if typeof(partner) ~= "Instance" or not partner:IsA("Player") then
		return false, "Could not identify the other trader"
	end

	task.spawn(function() silentBlockPlayer(partner) end)
	return true, "Block started for @" .. partner.Name
end

--==================================================================
-- Spawner (injects mock items into your inventory the way the game does:
-- container:ApplyPacket{ set = { Class = { [uid] = data } } }, which is the
-- exact handler for the server's "Items: Update". Client-side only, so items
-- appear in your inventory + trade grid; equipping stays server-authoritative.
--==================================================================
local function getContainer()
	if not InventoryCmds then return nil end
	local c
	pcall(function() c = InventoryCmds.Container(LocalPlayer) end)
	return c
end

-- valid pet ids, taken from the already-loaded Pet type (PetItem returns a table
-- whose .Directory is the Pets directory) - avoids requiring Directory.Pets directly
local function getPetsDir()
	local d
	pcall(function() d = ItemTypes.Type("Pet").Directory end)
	return d
end

-- ==============================================================
-- CLIENT-side pet equip (no server). Recipe:
--   * PlayerPet.new(uid, item, player) spawns the follower model.
--   * Neuter its networking methods so the native AI never sends server
--     routes/pins - a server-less pet that networks gets REAPED. It follows
--     locally via PlayerPet.SetTargetWithoutNetworking instead.
--   * A heartbeat loop re-equips if the game's reconciliation reaps a follower.
-- Controller.Equip / PetCmds.Equip are the server-gated paths and do nothing
-- for a mock pet, so we render it ourselves.
-- ==============================================================
local records = {} -- [uid] = { uid=, euid=, item=, equipped=, visual= }
local lastNativeMockToggle = {} -- [uid] = os.clock(), prevents a tile-click double-toggle
-- Keep the unpatched networking reader so teamView can always start with the
-- real equipped-pet list, even after we expose mock pets to the team UI.
local rawEquippedPets = PetNetworking and PetNetworking.EquippedPets

local function visualAlive(v)
	return v and not v.destroyed and v.cpet and v.cpet.physical and v.cpet.physical.Parent ~= nil
end

local function neuterVisual(visual)
	local function follow(self)
		if LocalPlayer.Character then
			pcall(function() PlayerPet.SetTargetWithoutNetworking(self, LocalPlayer.Character) end)
		end
	end
	visual.SetTarget                 = follow
	visual.SetTargetFromServer       = follow
	visual.SetTargetWithoutNetworking = follow
	visual.SetAnchored               = function() end
	visual.SetAnchoredFromServer     = function() end
end

-- Register a spawned pet so its inventory tile gets a client equip button and it
-- can appear on the team. Call BEFORE the inventory renders it (before ApplyPacket).
local function makeRecord(item)
	local uid = item:GetOptionalUID()
	if not uid then uid = AbstractItem.GenerateUID(); pcall(function() item:SetUID(uid) end) end
	-- Inventory UIDs and equipped-pet IDs are different in the normal client.
	-- Give mock pets a separate euid so Team entries and world visuals follow
	-- the same mapping.
	local rec = records[uid] or {
		uid = uid,
		euid = HttpService:GenerateGUID(false),
		item = item,
		equipped = false,
	}
	rec.item = item
	records[uid] = rec
	return rec
end

-- The equipped "team" the game sees = real equipped pets + our equipped mock records.
-- Patching PetCmds.GetEquipped to this is what makes mock pets show on your team and
-- stops the "you're already using your best pets" gating from blocking them.
local function teamView()
	local view = {}
	pcall(function()
		if rawEquippedPets then
			view = table.clone(rawEquippedPets())
		end
	end)
	for uid, rec in pairs(records) do
		if rec.equipped then
			view[rec.euid] = { euid = rec.euid, uid = uid, modifiers = {} }
		end
	end
	return view
end

local function updateTeamUI()
	pcall(function()
		if PetNetworking and PetNetworking.EquippedPetsChanged then
			PetNetworking.EquippedPetsChanged:FireAsync(teamView())
		end
	end)
end

local function equip(record)
	if not (PlayerPet and PlayerPet.new) then return false, "PlayerPet module not available" end
	local character = LocalPlayer.Character
	if not (character and character.PrimaryPart) then return false, "Wait for your character to load" end
	setIdentity(2)
	local ok, err = pcall(function()
		if not visualAlive(record.visual) then
			if record.visual and not record.visual.destroyed then pcall(function() record.visual:Cleanup() end) end
			-- PlayerPet is keyed by the equipped-pet id, not the inventory uid.
			-- Keeping that mapping correct lets the normal Team UI find the mock pet.
			local visual = PlayerPet.new(record.euid, record.item, LocalPlayer)
			record.visual = visual
			neuterVisual(visual)     -- stop native networking BEFORE it targets
			visual:SetTarget(character)
		end
		record.equipped = true
		PlayerPet.UpdatePlayerPlacements(LocalPlayer)
	end)
	updateTeamUI()
	return ok, err
end

local function unequip(record)
	record.equipped = false
	if record.visual and not record.visual.destroyed then pcall(function() record.visual:Cleanup() end) end
	record.visual = nil
	pcall(function() PlayerPet.UpdatePlayerPlacements(LocalPlayer) end)
	updateTeamUI()
end

-- Riding temporarily removes the pet visual. Re-create an equipped mock pet
-- once the ride is gone, with a fresh equipped-pet id just like the client
-- does for a newly rendered pet.
local function recoverPetAfterRide(record)
	if not record or not record.equipped or record.recovering then return end
	record.recovering = true
	task.defer(function()
		RunService.Heartbeat:Wait()
		if not record.equipped then
			record.recovering = nil
			return
		end
		local isRiding = false
		pcall(function()
			isRiding = Riding and Riding.isRiding and Riding.isRiding(LocalPlayer, record.uid) or false
		end)
		if isRiding then
			record.recovering = nil
			return
		end

		local ok = pcall(function()
			setIdentity(2)
			record.euid = HttpService:GenerateGUID(false)
			if record.visual and not record.visual.destroyed then record.visual:Cleanup() end
			local visual = PlayerPet.new(record.euid, record.item, LocalPlayer)
			record.visual = visual
			neuterVisual(visual)
			visual:SetTarget(LocalPlayer.Character)
			PlayerPet.UpdatePlayerPlacements(LocalPlayer)
		end)
		record.recovering = nil
		if ok then updateTeamUI() end
	end)
end

-- Successful mock trades are presentation-only: never delete a server-owned
-- pet. The inventory UI already has a local-only global-hide mechanism, so use
-- that rather than attempting a server inventory update.
local hiddenAfterMockTrade = {}

local function refreshInventoryRenderers()
	if not (ItemContainerUI and ItemContainerUI.GetActiveContainers) then return end
	pcall(function()
		for _, uiContainer in ipairs(ItemContainerUI.GetActiveContainers()) do
			if uiContainer and uiContainer.cachedPopulation then
				uiContainer:Populate(uiContainer.cachedPopulation)
			end
		end
	end)
end

local function hideTradedInventoryPet(item, uid)
	hiddenAfterMockTrade[uid] = true
	if ItemContainerUI and ItemContainerUI.SetGloballyHidden and item then
		pcall(function() ItemContainerUI.SetGloballyHidden(item, true) end)
	end
end

settleSuccessfulMockTrade = function(state)
	if not state or not state._items then return end

	-- Hide every pet the local player offered, including real pets. This only
	-- changes the local inventory renderer; the server inventory is untouched.
	local offeredPets = state._items[1] and state._items[1].Pet
	if offeredPets then
		for uid, item in pairs(offeredPets) do
			local record = records[uid]
			if record then
				unequip(record)
				records[uid] = nil
			end
			hideTradedInventoryPet(item, uid)
		end
	end

	-- Make the partner's mock pet offer appear in the local inventory after the
	-- mock trade finishes. As with the spawner, ApplyPacket is client-only.
	local receivedPets = state._items[2] and state._items[2].Pet
	local inventory = getContainer()
	if receivedPets and inventory and ItemTypes and AbstractItem then
		local set = {}
		pcall(function()
			setIdentity(2)
			for _, offeredItem in pairs(receivedPets) do
				local received = offeredItem:Clone()
				local receivedUID = AbstractItem.GenerateUID()
				received:SetUID(receivedUID)
				local record = makeRecord(received)
				set[record.uid] = received:GetData()
			end
			if next(set) then
				inventory:ApplyPacket({ set = { Pet = set } })
			end
		end)
	end

	refreshInventoryRenderers()
end

-- fire the REAL server unequip-all remote (unequips your actual equipped pets).
local bypassRoute = false
local function unequipRealPets()
	bypassRoute = true
	local ok, err = pcall(function()
		if PetCmds and PetCmds.UnequipAll then PetCmds.UnequipAll()
		elseif EquipController and EquipController.UnequipAll then EquipController.UnequipAll()
		else error("no UnequipAll available") end
	end)
	bypassRoute = false
	return ok, err
end

-- Keep followers alive against the game's equip reconciliation / reaping.
task.spawn(function()
	while true do
		task.wait(2)
		local char = LocalPlayer.Character
		if char and char.PrimaryPart then
			for _, rec in pairs(records) do
				if rec.equipped and not rec.recovering and not rec.riding then
					pcall(function()
						if not visualAlive(rec.visual) then
							equip(rec)
						else
							rec.visual:SetTarget(char)
						end
					end)
				end
			end
		end
	end
end)

-- ============================================================
-- Install reversible adapters so the game's own equip UI / team display work with
-- mock pets. Only our own UIDs are intercepted; real pets keep original behavior.
-- ============================================================
local function patchFn(target, key, replacement)
	if not target then return end
	if not setfn(target, key, replacement) then
		warn("[MockTrade] could not patch " .. tostring(key))
	end
end

local function routeEquip(original)
	return function(target, ...)
		local uid = target
		if type(target) == "table" then
			pcall(function()
				uid = (target.GetOptionalUID and target:GetOptionalUID())
					or (target.GetUID and target:GetUID())
			end)
		end
		local rec = uid and records[uid]
		if not rec then return original(target, ...) end
		lastNativeMockToggle[rec.uid] = os.clock()
		local ok, err = equip(rec)
		return ok, err
	end
end

local function routeUnequip(original)
	return function(item, ...)
		local uid = item
		if type(item) == "table" then
			pcall(function()
				uid = (item.GetOptionalUID and item:GetOptionalUID())
					or (item.GetUID and item:GetUID())
			end)
		end
		local rec = uid and records[uid]
		if bypassRoute or not rec then return original(item, ...) end
		lastNativeMockToggle[rec.uid] = os.clock()
		unequip(rec)
		return true
	end
end

pcall(function()
	if EquipController then
		patchFn(EquipController, "Equip", routeEquip(EquipController.Equip))
		patchFn(EquipController, "UnequipByItem", routeUnequip(EquipController.UnequipByItem))
	end
	if PetCmds then
		patchFn(PetCmds, "Equip", routeEquip(PetCmds.Equip))
		patchFn(PetCmds, "UnequipByItem", routeUnequip(PetCmds.UnequipByItem))
		patchFn(PetCmds, "GetEquipped", function() return teamView() end)
		local origGetItem = PetCmds.GetItem
		patchFn(PetCmds, "GetItem", function(euid, ...)
			for uid, rec in pairs(records) do
				if rec.equipped and (rec.euid == euid or uid == euid) then return rec.item end
			end
			return origGetItem and origGetItem(euid, ...)
		end)
		patchFn(PetCmds, "GetEquippedItems", function()
			local items = {}
			for euid in pairs(teamView()) do
				local it = PetCmds.GetItem(euid)
				if it then table.insert(items, it) end
			end
			return items
		end)
		patchFn(PetCmds, "IsEquippingOne", function() return next(teamView()) ~= nil end)
		patchFn(PetCmds, "IsMaxEquipped", function()
			local count = 0
			for _ in pairs(teamView()) do count = count + 1 end
			local max = 4
			pcall(function() max = PetCmds.GetMaxEquipped() end)
			return count >= max
		end)
	end
	-- Inventory's Team page obtains its list from PetNetworking rather than
	-- PetCmds. Expose the same combined real + mock view there as well.
	if PetNetworking and rawEquippedPets then
		patchFn(PetNetworking, "EquippedPets", function() return teamView() end)
	end
	-- A ride cleans up its pet visual. Preserve the record while riding, then
	-- restore the local mock visual and refresh the Team view when the ride ends.
	if Riding and Riding.ride and Riding.destroyByPlayer then
		local oldRide = Riding.ride
		patchFn(Riding, "ride", function(player, owner, item, seat, ...)
			local uid
			pcall(function() uid = item and item:GetUID() end)
			local record = uid and records[uid]
			if record then
				record.riding = true
				if record.visual then
					pcall(function() record.visual:Cleanup() end)
					record.visual = nil
				end
			end
			return oldRide(player, owner, item, seat, ...)
		end)

		local oldDestroyByPlayer = Riding.destroyByPlayer
		patchFn(Riding, "destroyByPlayer", function(player, ...)
			local record
			pcall(function()
				local state = Riding.findState and Riding.findState(player)
				local item = state and state.cpet and state.cpet.item
				local uid = item and item:GetUID()
				record = uid and records[uid]
			end)
			local result = table.pack(oldDestroyByPlayer(player, ...))
			local stillRiding = false
			pcall(function()
				stillRiding = record and Riding.isRiding and Riding.isRiding(player, record.uid) or false
			end)
			if record and not stillRiding then record.riding = nil end
			if record and record.equipped and not stillRiding then
				recoverPetAfterRide(record)
			end
			return table.unpack(result, 1, result.n)
		end)
	end
	-- The "you are already using your best pets" gate lives in the inventory UI
	-- script itself (before it reaches Equip), so routing can't reach it. Overlay a
	-- small EQUIP button on the bottom strip of mock tiles that calls our equip
	-- directly. It's only ~22px tall, so the rest of the tile still shows the hover.
	if ItemUI and ItemUI.Create then
		local originalCreate = ItemUI.Create
		patchFn(ItemUI, "Create", function(item, settings, ...)
			-- ItemUI lazily requires pet-render modules.  This wrapper runs in the
			-- executor thread, so restore the normal client identity before handing
			-- control back to the game's renderer.
			setIdentity(2)
			local uid = item and type(item) == "table" and item.GetOptionalUID and item:GetOptionalUID()
			local rets = table.pack(originalCreate(item, settings, ...))
			local tile = rets[1]
			pcall(function()
				if tile and tile:IsA("GuiObject") and uid then
					tile:SetAttribute("MockTradeItemUID", uid)
					if hiddenAfterMockTrade[uid] then tile.Visible = false end
				end
			end)
			if not (uid and records[uid]) then
				return table.unpack(rets, 1, rets.n)
			end
			pcall(function()
				if not (tile and tile:IsA("GuiObject")) then return end
				local lastDirectClick = 0
				local function toggleMockPet()
					local rec = records[uid]
					if not rec then return end
					if rec.equipped then unequip(rec) else equip(rec) end
					local action = tile:FindFirstChild("ShowcaseEquip")
					if action and action:IsA("TextButton") then
						action.Text = rec.equipped and "UNEQUIP" or "EQUIP"
					end
				end

				-- Normal inventory pet tiles are clickable. Intercept that click for
				-- mock pets so it equips locally instead of going through the server
				-- equip request. Trade-grid tiles use NoActionMenu and are intentionally
				-- left alone so they can still be selected for a mock trade.
				if not (settings and settings.NoActionMenu) and tile:IsA("GuiButton") then
					tile.Activated:Connect(function()
						task.defer(function()
							if os.clock() - lastDirectClick > 0.1
								and os.clock() - (lastNativeMockToggle[uid] or 0) > 0.1 then
								toggleMockPet()
							end
						end)
					end)
				end

				local btn = CreateInstance("TextButton", tile, {
					Name = "ShowcaseEquip",
					Size = UDim2.new(1, 0, 0, 22),
					Position = UDim2.new(0, 0, 1, -22),
					BackgroundColor3 = Color3.fromRGB(90, 40, 140),
					BackgroundTransparency = 0.15,
					Text = records[uid].equipped and "UNEQUIP" or "EQUIP",
					Font = Enum.Font.GothamBold,
					TextSize = 11,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					AutoButtonColor = true,
					ZIndex = (tile.ZIndex or 1) + 20,
				})
				CreateInstance("UICorner", btn, { CornerRadius = UDim.new(0, 4) })
				btn.Activated:Connect(function()
					lastDirectClick = os.clock()
					toggleMockPet()
				end)
			end)
			return table.unpack(rets, 1, rets.n)
		end)
	end
end)

local function spawnPets(name, opts, amount)
	if not (InventoryCmds and ItemTypes) then return false, "Inventory modules not loaded" end
	if not name or name == "" then return false, "Enter a pet name" end
	local petsDir = getPetsDir()
	if petsDir and not petsDir[name] then return false, "Unknown pet id: " .. name end
	local container = getContainer()
	if not container then return false, "Inventory not ready yet" end
	amount = math.clamp(math.floor(tonumber(amount) or 1), 1, 500)
	opts = opts or {}
	setIdentity(2) -- so the item-render's lazy requires (e.g. huge pets) load correctly
	local spawnedRecs = {}
	local ok, err = pcall(function()
		local set = {}
		for _ = 1, amount do
			local item = ItemTypes.From("Pet", { id = name })
			if opts.shiny then pcall(function() item:SetShiny(true) end) end
			if opts.rainbow then pcall(function() item:SetRainbow() end)
			elseif opts.golden then pcall(function() item:SetGolden() end) end
			pcall(function() item:SetUID(AbstractItem.GenerateUID()) end)
			local rec = makeRecord(item) -- register BEFORE render so its tile gets the equip button
			set[rec.uid] = item:GetData()
			table.insert(spawnedRecs, rec)
		end
		container:ApplyPacket({ set = { Pet = set } })
	end)
	if not ok then return false, tostring(err) end
	if opts.equip then
		for _, rec in ipairs(spawnedRecs) do equip(rec) end
	end
	return true
end

local function spawnDiamonds(amount)
	if not (InventoryCmds and ItemTypes) then return false, "Inventory modules not loaded" end
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return false, "Enter a positive amount" end
	local container = getContainer()
	if not container then return false, "Inventory not ready yet" end
	setIdentity(2)
	local ok, err = pcall(function()
		local dia = CurrencyCmds and CurrencyCmds.GetItem("Diamonds")
		local item, base, uid
		if dia then
			item = dia:Clone()
			base = dia:GetAmount() or 0
			uid  = dia:GetOptionalUID() or AbstractItem.GenerateUID()
		else
			item = ItemTypes.From("Currency", { id = "Diamonds" })
			base = 0
			uid  = AbstractItem.GenerateUID()
		end
		local target = base + amount
		local maxAmt = item:GetMaxAmount()
		if maxAmt then target = math.min(target, maxAmt) end
		item:SetAmount(target)
		container:ApplyPacket({ set = { Currency = { [uid] = item:GetData() } } })
	end)
	if not ok then return false, tostring(err) end
	return true
end

-- Pet signers (BIG Games staff / devs / partners) from petsimulatorvalues.com/signatures.php.
-- SetSignedBy takes a Roblox UserId; some spawned pets get a random one for realism.
local SIGNERS = {
	{ name = "Preston", id = 19717956 }, { name = "David", id = 1210210 },
	{ name = "Lucas", id = 3687735502 }, { name = "Joey", id = 2882755487 },
	{ name = "Mitchell", id = 2878290231 }, { name = "Conner", id = 2213470865 },
	{ name = "Gavin", id = 63844404 }, { name = "Tony", id = 3983340648 },
	{ name = "ADAM", id = 13365322 },
	{ name = "0SIM0N", id = 7777931 }, { name = "AlexiaActually", id = 8793873373 },
	{ name = "Alivein2020", id = 2065808901 }, { name = "ArchEssence", id = 57651881 },
	{ name = "Arrayte", id = 140459984 }, { name = "CaptnChillie", id = 30236088 },
	{ name = "CertifiedChrxs", id = 629799654 }, { name = "Charlotte", id = 41216406 },
	{ name = "Cheena_Cheena", id = 88000021 }, { name = "Chloe", id = 79447925 },
	{ name = "Coylist", id = 40222641 }, { name = "CursedKrampus", id = 42283838 },
	{ name = "Cutesquishylove", id = 665342225 }, { name = "darklove", id = 691136 },
	{ name = "DaudiBro56", id = 1739128334 }, { name = "FabledTears", id = 86182738 },
	{ name = "Hanna", id = 1583139092 }, { name = "Haru_Kida", id = 3986724533 },
	{ name = "HeyDude", id = 97577763 }, { name = "Iamuss76", id = 57100195 },
	{ name = "Isaiah", id = 2856041991 }, { name = "jairtym2006", id = 3395092890 },
	{ name = "Jamien", id = 7707349 }, { name = "KitKats1297", id = 1202523313 },
	{ name = "Lady_Vythika", id = 569066313 }, { name = "LaliLauri", id = 540536417 },
	{ name = "lkeshl", id = 1085337938 }, { name = "Nixxie", id = 6173690020 },
	{ name = "PenguinTehh", id = 306054023 }, { name = "Phoenix", id = 509200510 },
	{ name = "Repoman46", id = 393582309 }, { name = "Sam", id = 158564108 },
	{ name = "Sem", id = 173184370 }, { name = "SJWHITE1994", id = 153905165 },
	{ name = "slendergad", id = 552292750 }, { name = "Soapii_SereiaVT", id = 47921302 },
	{ name = "Steezy", id = 204796674 }, { name = "SueBoo", id = 1657957717 },
	{ name = "SunnyRain", id = 163214036 }, { name = "Syl", id = 594354313 },
	{ name = "Synchiron1", id = 3856278446 }, { name = "tasdanop", id = 97533948 },
	{ name = "Taypoodoo", id = 721879356 }, { name = "TaztheV1", id = 3664468462 },
	{ name = "tenskawatawa", id = 290326088 }, { name = "Vhankii", id = 51579833 },
	{ name = "Zeion97", id = 4441146554 }, { name = "AlphaGG", id = 1212154812 },
	{ name = "Altimox", id = 482885214 }, { name = "1337_DISRUPTOR", id = 4184446329 },
	{ name = "727_ac", id = 1552435065 },
}

local function randomSigner() return SIGNERS[math.random(#SIGNERS)] end

-- Spawn a realistic rich loadout using the live existence-count cache:
-- 4 Gargantuans (>50 exist), 10 Titanics (>100 exist), 125 Huges (>1000 exist).
-- Every pet is independently normal, golden, rainbow, or shiny.
local function spawnRichPets(noDev, multiplier)
	multiplier = math.max(1, math.floor(tonumber(multiplier) or 1))
	local gargAmount = 4 * multiplier
	local titanAmount = 10 * multiplier
	local hugeAmount = 125 * multiplier
	if not (InventoryCmds and ItemTypes) then return false, "Inventory modules not loaded" end
	if not (ExistCountCmds and ExistCountCmds.IsReady and ExistCountCmds.IsReady()) then
		return false, "Existence data is still loading; try again shortly"
	end
	local container = getContainer()
	if not container then return false, "Inventory not ready yet" end
	local dir = getPetsDir()
	if not dir then return false, "Pet directory unavailable" end
	setIdentity(2)

	local function applyVariant(item, variant)
		if variant == 2 then
			item:SetGolden()
		elseif variant == 3 then
			item:SetRainbow()
		elseif variant == 4 then
			item:SetShiny(true)
		end
	end

	local garg, titan, huge = {}, {}, {}
	for _, d in pairs(dir) do
		if type(d) == "table" and type(d._id) == "string" then
			local isDev = d.hidden == true or d.secretExclusive == true
			if not (noDev and isDev) then
				local minimum = d.gargantuan and 50 or d.titanic and 100 or d.huge and 1000
				if minimum then
					for variant = 1, 4 do
						local prototype
						local made = pcall(function()
							prototype = ItemTypes.From("Pet", { id = d._id })
							applyVariant(prototype, variant)
						end)
						local exists, ready
						if made and prototype then
							exists, ready = ExistCountCmds.Get(prototype)
						end
						if ready and type(exists) == "number" and exists > minimum then
							local entry = { id = d._id, variant = variant }
							if d.gargantuan then garg[#garg + 1] = entry
							elseif d.titanic then titan[#titan + 1] = entry
							else huge[#huge + 1] = entry end
						end
					end
				end
			end
		end
	end
	if #garg == 0 or #titan == 0 or #huge == 0 then
		return false, "No eligible Garg, Titanic, or Huge pets found for the requested existence limits"
	end

	local picks = {}
	local function pick(pool, n)
		for _ = 1, n do picks[#picks + 1] = pool[math.random(#pool)] end
	end
	pick(garg, gargAmount)
	pick(titan, titanAmount)
	pick(huge, hugeAmount)

	local signed = 0
	local variants = { normal = 0, golden = 0, rainbow = 0, shiny = 0 }
	local ok, err = pcall(function()
		local set = {}
		for _, pick in ipairs(picks) do
			local item = ItemTypes.From("Pet", { id = pick.id })
			applyVariant(item, pick.variant)
			if pick.variant == 2 then variants.golden = variants.golden + 1
			elseif pick.variant == 3 then variants.rainbow = variants.rainbow + 1
			elseif pick.variant == 4 then variants.shiny = variants.shiny + 1
			else variants.normal = variants.normal + 1 end
			if #SIGNERS > 0 and math.random() < 0.4 then
				local s = randomSigner()
				local okSign = pcall(function() item:SetSignedBy(s.id) end)
				if okSign then signed = signed + 1 end
			end
			pcall(function() item:SetUID(AbstractItem.GenerateUID()) end)
			local rec = makeRecord(item) -- register so its tile gets the equip button
			set[rec.uid] = item:GetData()
		end
		container:ApplyPacket({ set = { Pet = set } })
	end)
	if not ok then return false, tostring(err) end
	return true, string.format(
		"%d pets: %d Garg, %d Titanic, %d Huge; %d normal, %d golden, %d rainbow, %d shiny; %d signed",
		#picks, gargAmount, titanAmount, hugeAmount,
		variants.normal, variants.golden, variants.rainbow, variants.shiny, signed
	)
end

--==================================================================
-- Partner pet offers. They stay trade-window-only until a successful mock
-- trade, then settlement adds them to the client-side inventory.
--==================================================================
local function addPartnerPet(petId)
	if not Mock.active or not Mock.state then return false, "No active trade" end
	if not (ItemTypes and AbstractItem) then return false, "Pet item modules not loaded" end
	if not petId or petId == "" then return false, "Choose a pet first" end

	local petDirectory = getPetsDir()
	if petDirectory and not petDirectory[petId] then
		return false, "Unknown pet id: " .. tostring(petId)
	end

	local st = Mock.state
	if st._readyTimer then
		return false, "Unready both sides before changing the partner offer"
	end

	local item, uid
	local ok, err = pcall(function()
		setIdentity(2)
		item = ItemTypes.From("Pet", { id = petId })
		uid = AbstractItem.GenerateUID()
		item:SetUID(uid)
	end)
	if not ok or not item or not uid then return false, tostring(err or "Could not create pet") end

	st._items[2].Pet = st._items[2].Pet or {}
	st._items[2].Pet[uid] = item
	st._counter = st._counter + 1
	st._lastModified = now()
	fire(TradingCmds.TradeSetItem, Mock.id, 2, "Pet", uid, item, st._counter, st._lastModified)
	return true, petId
end

local function addRandomPartnerPet(kind)
	local petDirectory = getPetsDir()
	if not petDirectory then return false, "Pet directory unavailable" end
	if not (RAPCmds and ExistCountCmds) then
		return false, "RAP or existence data module is unavailable"
	end

	local choices = {}
	local waitingForMarketData = false
	local valueLimit = kind == "Huge" and 1000000000 or 50000000000
	setIdentity(2)
	for _, data in pairs(petDirectory) do
		if type(data) == "table" and type(data._id) == "string" then
			if (kind == "Huge" and data.huge) or (kind == "Titanic" and data.titanic) then
				local item
				local madeItem = pcall(function()
					item = ItemTypes.From("Pet", { id = data._id })
				end)
				if madeItem and item then
					local rap, rapReady = RAPCmds.Get(item)
					local exists, existsReady = ExistCountCmds.Get(item)
					if not rapReady or not existsReady then
						waitingForMarketData = true
					elseif type(rap) == "number" and type(exists) == "number"
						and exists > 500 and rap < valueLimit then
						table.insert(choices, data._id)
					end
				end
			end
		end
	end

	if #choices == 0 then
		if waitingForMarketData then
			return false, "RAP/existence data is still loading; try again shortly"
		end
		return false, "No realistic " .. kind:lower() .. " pets found"
	end
	return addPartnerPet(choices[math.random(1, #choices)])
end

local function addRandomHugeOrTitanic()
	local first = math.random(1, 2) == 1 and "Huge" or "Titanic"
	local second = first == "Huge" and "Titanic" or "Huge"
	local ok, result = addRandomPartnerPet(first)
	if ok then return true, first, result end

	local fallbackOk, fallbackResult = addRandomPartnerPet(second)
	if fallbackOk then return true, second, fallbackResult end
	return false, fallbackResult or result
end

--==================================================================================
--  GUI  (styled after the tabbed template - dark / purple, draggable, tweened)
--==================================================================================
local THEME = {
	bg        = Color3.fromRGB(30, 30, 40),
	panel     = Color3.fromRGB(35, 35, 45),
	stroke    = Color3.fromRGB(100, 100, 255),
	btn       = Color3.fromRGB(100, 50, 150),
	btnOn     = Color3.fromRGB(140, 70, 200),
	btnStroke = Color3.fromRGB(200, 100, 255),
	text      = Color3.fromRGB(255, 255, 255),
	subtext   = Color3.fromRGB(180, 180, 180),
}

local function CreateInstance(class, parent, props)
	local o = Instance.new(class)
	for k, v in next, props or {} do o[k] = v end
	o.Parent = parent
	return o
end

--== root
-- Parent to PlayerGui (NOT gethui/CoreGui): in this executor, event-callback
-- threads lack the Plugin capability, so touching CoreGui instances from a
-- button click throws "cannot access 'Instance' (lacking capability Plugin)".
local guiParent = LocalPlayer:WaitForChild("PlayerGui")

local function spawnDraggableUsernameGUI()
	local existing = guiParent:FindFirstChild("MockTradeUsernameBadge")
	if existing then
		local existingLabel = existing:FindFirstChild("UsernameLabel")
		if existingLabel and existingLabel:IsA("TextLabel") then
			existingLabel.Text = "USERNAME: " .. LocalPlayer.Name
			existing.Enabled = true
			return
		end
		existing:Destroy()
	end

	local badgeGui = CreateInstance("ScreenGui", guiParent, {
		Name = "MockTradeUsernameBadge",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 1000000000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	local badge = CreateInstance("TextLabel", badgeGui, {
		Name = "UsernameLabel",
		Size = UDim2.new(0, 760, 0, 125),
		Position = UDim2.new(0.5, -380, 0.18, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "USERNAME: " .. LocalPlayer.Name,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 0,
		Font = Enum.Font.FredokaOne,
		TextSize = 62,
		TextScaled = false,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Active = true,
		ZIndex = 1000000001,
	})
	CreateInstance("UIStroke", badge, {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
		Color = Color3.fromRGB(0, 0, 0),
		Thickness = 3,
	})
	local draggingBadge, dragStart, badgeStartPosition = false, nil, nil
	badge.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			draggingBadge = true
			dragStart = input.Position
			badgeStartPosition = badge.Position
		end
	end)
	UserInput.InputChanged:Connect(function(input)
		if not draggingBadge then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			badge.Position = UDim2.new(
				badgeStartPosition.X.Scale, badgeStartPosition.X.Offset + delta.X,
				badgeStartPosition.Y.Scale, badgeStartPosition.Y.Offset + delta.Y
			)
		end
	end)
	UserInput.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			draggingBadge = false
		end
	end)
end

local controlGui = CreateInstance("ScreenGui", guiParent, {
	Name = "MockTradeShowcase",
	ResetOnSpawn = false,
	DisplayOrder = 999999999,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local mainFrame = CreateInstance("Frame", controlGui, {
	Size = UDim2.new(0, 250, 0, 500),
	Position = UDim2.new(0.5, -125, 0.5, -250),
	BackgroundColor3 = THEME.bg,
	BorderSizePixel = 0,
	ClipsDescendants = false,
	Active = true,
})
CreateInstance("UICorner", mainFrame, { CornerRadius = UDim.new(0, 8) })
CreateInstance("UIStroke", mainFrame, {
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	Color = THEME.stroke, Thickness = 2.5,
})

--== dragging
local canDrag, dragging, dragStart, startPos = true, false, nil, nil
mainFrame.InputBegan:Connect(function(input)
	if not canDrag then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)
UserInput.InputChanged:Connect(function(input)
	if not canDrag or not dragging then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UserInput.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

--== title
local titleLabel = CreateInstance("TextLabel", mainFrame, {
	Size = UDim2.new(1, 0, 0, 25),
	Position = UDim2.new(0, 0, 0, 2),
	BackgroundTransparency = 1,
	Text = "blueprint.lua / .slaypeter. on discord",
	Font = Enum.Font.FredokaOne,
	TextSize = 16,
	TextColor3 = Color3.fromRGB(240, 240, 255),
})
CreateInstance("UIStroke", titleLabel, {
	ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
	Color = Color3.new(0, 0, 0), Thickness = 1.0,
})

--== persistent status line
local statusLabel = CreateInstance("TextLabel", mainFrame, {
	Size = UDim2.new(0.96, 0, 0, 16),
	Position = UDim2.new(0.02, 0, 0, 80),
	BackgroundTransparency = 1,
	Text = "Idle. Enter a username to start.",
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextWrapped = true,
	TextColor3 = THEME.subtext,
	TextXAlignment = Enum.TextXAlignment.Left,
})
local function setStatus(t, color)
	statusLabel.Text = t
	statusLabel.TextColor3 = color or THEME.subtext
end

--== tabs
local tabContainer = CreateInstance("Frame", mainFrame, {
	Size = UDim2.new(0.96, 0, 0, 35),
	Position = UDim2.new(0.02, 0, 0, 40),
	BackgroundTransparency = 1,
})

local tabs = { "Control", "Players", "Users", "Chat", "Spawner" }
local currentTab = "Control"
local tabFrames, tabButtons = {}, {}
local activeTabPulseTween

local function setActiveTab(tabName)
	if currentTab == tabName then return end
	if activeTabPulseTween then activeTabPulseTween:Cancel() activeTabPulseTween = nil end
	currentTab = tabName
	for name, data in pairs(tabButtons) do
		local isActive = name == tabName
		TweenService:Create(data.button, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundColor3 = isActive and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(40, 40, 50),
		}):Play()
		local targetColor = isActive and THEME.stroke or Color3.fromRGB(80, 80, 80)
		TweenService:Create(data.stroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Color = targetColor, Thickness = isActive and 2 or 1,
		}):Play()
		if isActive then
			local pulseInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
			activeTabPulseTween = TweenService:Create(data.stroke, pulseInfo, {
				Color = targetColor:Lerp(Color3.fromRGB(255, 255, 255), 0.3),
			})
			activeTabPulseTween:Play()
		end
	end
	for name, frame in pairs(tabFrames) do
		frame.Visible = name == tabName
	end
end

for i, tabName in ipairs(tabs) do
	local tabButton = CreateInstance("TextButton", tabContainer, {
		Size = UDim2.new(1/#tabs - 0.015, 0, 1, 0),
		Position = UDim2.new((i - 1) * (1/#tabs), 0, 0, 0),
		BackgroundColor3 = i == 1 and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(40, 40, 50),
		BackgroundTransparency = 0.2,
		Text = tabName,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = THEME.text,
	})
	CreateInstance("UICorner", tabButton, { CornerRadius = UDim.new(0, 6) })
	local tabStroke = CreateInstance("UIStroke", tabButton, {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = i == 1 and THEME.stroke or Color3.fromRGB(80, 80, 80),
		Thickness = i == 1 and 2 or 1,
	})
	tabButtons[tabName] = { button = tabButton, stroke = tabStroke }

	local scrollFrame = CreateInstance("ScrollingFrame", mainFrame, {
		Size = UDim2.new(0.96, 0, 1, -105),
		Position = UDim2.new(0.02, 0, 0, 100),
		BackgroundColor3 = THEME.panel,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = THEME.stroke,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Visible = i == 1,
	})
	CreateInstance("UICorner", scrollFrame, { CornerRadius = UDim.new(0, 8) })
	local layout = CreateInstance("UIListLayout", scrollFrame, {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
	})
	CreateInstance("UIPadding", scrollFrame, {
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
	})
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
	end)
	tabFrames[tabName] = scrollFrame

	tabButton.MouseButton1Click:Connect(function() setActiveTab(tabName) end)
end

local controlFrame = tabFrames["Control"]
local playersFrame = tabFrames["Players"]
local usersFrame   = tabFrames["Users"]
local chatFrame    = tabFrames["Chat"]
local spawnerFrame = tabFrames["Spawner"]

--==================================================================
-- UI helper constructors (from the template style)
--==================================================================
local pulsationTweens = {}

local function CreateSpace(parent, h)
	CreateInstance("Frame", parent, {
		Size = UDim2.new(1, 0, 0, h or 5),
		BackgroundTransparency = 1,
	})
end

local function CreateButton(parent, text, fn)
	local button = CreateInstance("TextButton", parent, {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundColor3 = THEME.btn,
		BackgroundTransparency = 0.2,
		Text = text,
		Font = Enum.Font.FredokaOne,
		TextSize = 14,
		TextColor3 = THEME.text,
	})
	CreateInstance("UICorner", button, { CornerRadius = UDim.new(0, 5) })
	CreateInstance("UIStroke", button, {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = THEME.btnStroke, Thickness = 1.5, Transparency = 0.3,
	})
	if fn then
		button.MouseButton1Click:Connect(function()
			local ok, err = pcall(fn)
			if not ok then setStatus("Error: " .. tostring(err), Color3.fromRGB(255, 90, 90)) end
		end)
	end
	return button
end

-- opts (optional): { size = UDim2, position = UDim2 } for custom placement (e.g. side-by-side)
local function CreateToggleButton(parent, text, state, cb, opts)
	opts = opts or {}
	local button = CreateInstance("TextButton", parent, {
		Size = opts.size or UDim2.new(1, 0, 0, 26),
		Position = opts.position,
		BackgroundColor3 = THEME.btn,
		BackgroundTransparency = 0.2,
		Text = text .. ": OFF",
		Font = Enum.Font.FredokaOne,
		TextSize = 14,
		TextScaled = opts.size ~= nil, -- shrink text to fit narrow (side-by-side) buttons
		TextColor3 = THEME.text,
	})
	CreateInstance("UICorner", button, { CornerRadius = UDim.new(0, 5) })
	CreateInstance("UIStroke", button, {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = THEME.btnStroke, Thickness = 1.5, Transparency = 0.3,
	})
	local function update()
		TweenService:Create(button, TweenInfo.new(0.15), {
			BackgroundColor3 = state and THEME.btnOn or THEME.btn,
		}):Play()
		button.Text = text .. (state and ": ON" or ": OFF")
	end
	update()
	button.MouseButton1Click:Connect(function()
		state = not state
		update()
		if cb then cb(state) end
	end)
	return button
end

local function CreateHeading(parent, text)
	return CreateInstance("TextLabel", parent, {
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1,
		Text = text,
		Font = Enum.Font.SourceSansSemibold,
		TextSize = 13,
		TextColor3 = THEME.subtext,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
end

-- a focus-pulsing textbox (optionally with a label above it)
local function attachFocusPulse(box, stroke)
	box.Focused:Connect(function()
		if pulsationTweens[box] then pulsationTweens[box]:Cancel() end
		local pulseInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		pulsationTweens[box] = TweenService:Create(stroke, pulseInfo, {
			Color = Color3.fromRGB(100, 100, 255):Lerp(Color3.fromRGB(150, 150, 255), 0.5),
			Thickness = 1.5, Transparency = 0.2,
		})
		pulsationTweens[box]:Play()
	end)
	box.FocusLost:Connect(function()
		if pulsationTweens[box] then pulsationTweens[box]:Cancel() pulsationTweens[box] = nil end
		TweenService:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Color = Color3.fromRGB(100, 100, 100), Thickness = 1.0, Transparency = 0.5,
		}):Play()
	end)
end

local function createSettingRow(parent, labelText, defaultValue)
	local row = CreateInstance("Frame", parent, {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 42),
	})
	CreateInstance("UIListLayout", row, {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 1),
	})
	CreateInstance("TextLabel", row, {
		Size = UDim2.new(1, 0, 0, 15),
		BackgroundTransparency = 1,
		Text = labelText,
		Font = Enum.Font.SourceSansSemibold,
		TextSize = 12,
		TextColor3 = THEME.subtext,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	local box = CreateInstance("TextBox", row, {
		Size = UDim2.new(1, 0, 0, 25),
		BackgroundColor3 = Color3.fromRGB(40, 40, 50),
		BackgroundTransparency = 0.2,
		Text = tostring(defaultValue or ""),
		Font = Enum.Font.SourceSans,
		TextSize = 14,
		TextColor3 = THEME.text,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	CreateInstance("UICorner", box, { CornerRadius = UDim.new(0, 5) })
	local stroke = CreateInstance("UIStroke", box, {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = Color3.fromRGB(100, 100, 100), Thickness = 1.0, Transparency = 0.5,
	})
	attachFocusPulse(box, stroke)
	return box
end

local function CreateRow(parent, placeholder)
	local box = CreateInstance("TextBox", parent, {
		Size = UDim2.new(1, 0, 0, 25),
		BackgroundColor3 = Color3.fromRGB(40, 40, 50),
		BackgroundTransparency = 0.2,
		PlaceholderText = placeholder,
		Text = "",
		Font = Enum.Font.SourceSans,
		TextSize = 14,
		TextColor3 = THEME.text,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	CreateInstance("UICorner", box, { CornerRadius = UDim.new(0, 5) })
	local stroke = CreateInstance("UIStroke", box, {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = Color3.fromRGB(100, 100, 100), Thickness = 1.0, Transparency = 0.5,
	})
	attachFocusPulse(box, stroke)
	return box
end

--==================================================================
-- CONTROL TAB
--==================================================================
local PRESET_USERS = {
    "orlmeme",
    "cheyjqp",
    "Kekc_U9",
    "azazkinzz",
    "Hollow1750",
    "Mo046556",
    "zezinn0123",
    "omarxoxkl",
    "Kyrenee2468",
    "mexs164",
    "itz_4114",
    "HesCavad",
    "MrEshMood",
    "dmstj0306",
    "davigabsaf2012",
    "hsposa",
    "szymuswag0",
    "laefis",
    "Beastmode105688",
    "cutegirlrule77",
    "venusufd",
    "Haida_653",
    "maesuke9993",
    "keuri_00",
    "Ethan6jiggly",
    "OpticLuciferSon",
    "RobloxGod19571",
}

local partnerBox = createSettingRow(controlFrame, "Partner Username", "")
partnerBox.FocusLost:Connect(function()
    partnerName = partnerBox.Text
end)

local function startTradeFromControl()
    if Mock.active or Mock.pendingRequest then
        return setStatus(
            "A trade is already open or awaiting acceptance.",
            Color3.fromRGB(255, 180, 90)
        )
    end

    partnerName = partnerBox.Text

    if partnerName == "" then
        return setStatus(
            "Choose or enter a partner username first.",
            Color3.fromRGB(255, 180, 90)
        )
    end

    local ok, err = startRequest(partnerName)
    if not ok then
        return setStatus(tostring(err), Color3.fromRGB(255, 180, 90))
    end
    setStatus(
        "Request sent to @" .. partnerName .. " - accept the popup!",
        Color3.fromRGB(120, 220, 120)
    )
end

CreateSpace(controlFrame)
CreateButton(controlFrame, "Send Request", startTradeFromControl)

CreateSpace(controlFrame)
CreateButton(controlFrame, "Block Current Trade Partner", function()
	local ok, result = blockCurrentTradePartner(partnerBox.Text)
	setStatus(tostring(result), ok and Color3.fromRGB(120, 220, 120) or Color3.fromRGB(255, 120, 120))
end)

--==================================================================
-- KEYBINDS DROPDOWN
--==================================================================
CreateSpace(controlFrame)

local keybinds = {
    startTrade = Enum.KeyCode.T,
    partnerAction = Enum.KeyCode.Y,
    partnerUndo = Enum.KeyCode.U,
    randomUser = Enum.KeyCode.H,
    randomPartnerPet = Enum.KeyCode.P,
	blockPartner = Enum.KeyCode.J,
}

local keybindNames = {
    startTrade = "Start trade",
    partnerAction = "Partner accept / confirm",
    partnerUndo = "Partner unaccept",
    randomUser = "Random preset user",
    randomPartnerPet = "Random Huge / Titanic",
	blockPartner = "Block current partner",
}

local listeningFor = nil
local keybindButtons = {}

local keybindMenuButton = CreateButton(controlFrame, "Keybinds  ▶")

local keybindMenu = CreateInstance("Frame", controlFrame, {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
})

CreateInstance("UIPadding", keybindMenu, {
    PaddingTop = UDim.new(0, 6),
    PaddingBottom = UDim.new(0, 6),
})

CreateInstance("UIListLayout", keybindMenu, {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 3),
})

CreateHeading(keybindMenu, "Click a binding, then press a keyboard key")

local function refreshKeybindButton(id)
    keybindButtons[id].Text = keybindNames[id] .. ": [" .. keybinds[id].Name .. "]"
end

for _, id in ipairs({
    "startTrade",
    "partnerAction",
    "partnerUndo",
    "randomUser",
    "randomPartnerPet",
	"blockPartner",
}) do
    local button = CreateButton(keybindMenu, "")
    keybindButtons[id] = button
    refreshKeybindButton(id)

    button.MouseButton1Click:Connect(function()
        listeningFor = id
        button.Text = keybindNames[id] .. ": press a key..."
        setStatus("Press a key for " .. keybindNames[id] .. ".")
    end)
end

local keybindMenuOpen = false

keybindMenuButton.MouseButton1Click:Connect(function()
    keybindMenuOpen = not keybindMenuOpen
    keybindMenuButton.Text = keybindMenuOpen and "Keybinds  ▼" or "Keybinds  ▶"

    TweenService:Create(
        keybindMenu,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(1, 0, 0, keybindMenuOpen and 205 or 0),
        }
    ):Play()
end)

local function partnerAcceptOrConfirm()
    if Mock.pendingRequest then
        TradingCmds.Request(Mock.partner)
        return setStatus(
            "Partner accepted the trade.",
            Color3.fromRGB(120, 220, 120)
        )
    end

    if not Mock.active then
        return setStatus(
            "No pending or active trade.",
            Color3.fromRGB(255, 180, 90)
        )
    end

    local st = Mock.state

    if not st._ready[2] then
        setPartnerReady(true)
        return setStatus(
            "Partner accepted / readied.",
            Color3.fromRGB(120, 220, 120)
        )
    end

    if not st._readyTimer then
        return setStatus(
            "You must click Ready before the partner can confirm.",
            Color3.fromRGB(255, 180, 90)
        )
    end

    if not st._confirmed[2] then
        setPartnerConfirmed(true)
        return setStatus(
            "Partner confirmed.",
            Color3.fromRGB(120, 220, 120)
        )
    end

    setStatus("Partner has already confirmed.", Color3.fromRGB(255, 180, 90))
end

local function partnerUnaccept()
    if Mock.pendingRequest then
        TradingCmds.Reject(Mock.partner)
        return setStatus(
            "Partner declined the pending request.",
            Color3.fromRGB(255, 180, 90)
        )
    end

    if not Mock.active then
        return setStatus(
            "No pending or active trade.",
            Color3.fromRGB(255, 180, 90)
        )
    end

    local st = Mock.state

    if st._confirmed[2] then
        setPartnerConfirmed(false)
        return setStatus(
            "Partner unconfirmed.",
            Color3.fromRGB(255, 180, 90)
        )
    end

    if st._ready[2] then
        setPartnerReady(false)
        return setStatus(
            "Partner unaccepted / unreadied.",
            Color3.fromRGB(255, 180, 90)
        )
    end

    setStatus("Partner is not ready or confirmed.", Color3.fromRGB(255, 180, 90))
end

local function chooseRandomPresetUser()
    if Mock.active or Mock.pendingRequest then
        return setStatus(
            "Finish the current trade before changing partner.",
            Color3.fromRGB(255, 180, 90)
        )
    end

    local username = PRESET_USERS[math.random(1, #PRESET_USERS)]

    partnerName = username
    partnerBox.Text = username

    setStatus(
        "Random partner selected: @" .. username,
        Color3.fromRGB(120, 220, 120)
    )
end

UserInput.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if input.KeyCode == Enum.KeyCode.RightControl then return end

    if listeningFor then
        keybinds[listeningFor] = input.KeyCode
        refreshKeybindButton(listeningFor)

        setStatus(
            keybindNames[listeningFor] .. " set to [" .. input.KeyCode.Name .. "]."
        )

        listeningFor = nil
        return
    end

    if gameProcessed then return end

    if input.KeyCode == keybinds.startTrade then
        startTradeFromControl()
    elseif input.KeyCode == keybinds.partnerAction then
        partnerAcceptOrConfirm()
    elseif input.KeyCode == keybinds.partnerUndo then
        partnerUnaccept()
    elseif input.KeyCode == keybinds.randomUser then
        chooseRandomPresetUser()
	elseif input.KeyCode == keybinds.randomPartnerPet then
		local ok, kind, result = addRandomHugeOrTitanic()
		if ok then
			setStatus("Partner added random " .. kind .. ": " .. result, Color3.fromRGB(120, 220, 120))
		else
			setStatus("Random partner pet failed: " .. tostring(kind), Color3.fromRGB(255, 120, 120))
		end
	elseif input.KeyCode == keybinds.blockPartner then
		local ok, result = blockCurrentTradePartner(partnerBox.Text)
		setStatus(tostring(result), ok and Color3.fromRGB(120, 220, 120) or Color3.fromRGB(255, 120, 120))
    end
end)

--==================================================================
-- PARTNER PET OFFER
--==================================================================
CreateSpace(controlFrame)

CreateHeading(controlFrame, "Partner pet offer")
CreateSpace(controlFrame, 3)

local partnerPetSearch = CreateRow(controlFrame, "Search any pet")
partnerPetSearch.Size = UDim2.new(1, 0, 0, 25)

local partnerPetResults = CreateInstance("ScrollingFrame", controlFrame, {
    Size = UDim2.new(1, 0, 0, 115),
    BackgroundColor3 = Color3.fromRGB(20, 20, 28),
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = THEME.stroke,
})
CreateInstance("UICorner", partnerPetResults, { CornerRadius = UDim.new(0, 5) })
CreateInstance("UIPadding", partnerPetResults, {
    PaddingTop = UDim.new(0, 5),
    PaddingBottom = UDim.new(0, 5),
    PaddingLeft = UDim.new(0, 5),
    PaddingRight = UDim.new(0, 5),
})
local partnerPetResultsLayout = CreateInstance("UIListLayout", partnerPetResults, {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 3),
})
partnerPetResultsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    partnerPetResults.CanvasSize = UDim2.new(0, 0, 0, partnerPetResultsLayout.AbsoluteContentSize.Y + 10)
end)

local partnerPetBox = createSettingRow(controlFrame, "Pet id", "")
local partnerPetChoicesBuilt = false

local function filterPartnerPetChoices()
    local query = partnerPetSearch.Text:lower()
    for _, child in ipairs(partnerPetResults:GetChildren()) do
        if child:IsA("TextButton") then
            child.Visible = query == "" or child:GetAttribute("PetId"):lower():find(query, 1, true) ~= nil
        end
    end
end

local function buildPartnerPetChoices()
    if partnerPetChoicesBuilt then return end

    local petDirectory = getPetsDir()
    if not petDirectory then
        setStatus("Pet directory is not available yet.", Color3.fromRGB(255, 180, 90))
		task.delay(1, buildPartnerPetChoices)
        return
    end

    local petIds = {}
    for id, data in pairs(petDirectory) do
        local petId = type(data) == "table" and data._id or id
        if type(petId) == "string" then table.insert(petIds, petId) end
    end
    table.sort(petIds)

    for _, petId in ipairs(petIds) do
        local button = CreateButton(partnerPetResults, petId, function()
            partnerPetBox.Text = petId
            setStatus("Partner pet selected: " .. petId)
        end)
        button.Name = "Pet_" .. petId
        button:SetAttribute("PetId", petId)
        button.Size = UDim2.new(1, 0, 0, 24)
        button.TextSize = 12
    end

    partnerPetChoicesBuilt = true
    filterPartnerPetChoices()
end

partnerPetSearch:GetPropertyChangedSignal("Text"):Connect(filterPartnerPetChoices)

CreateButton(controlFrame, "Add Pet to Partner", function()
    local ok, result = addPartnerPet(partnerPetBox.Text)
    if ok then
        setStatus("Partner added " .. result .. ".", Color3.fromRGB(120, 220, 120))
    else
        setStatus("Partner pet failed: " .. tostring(result), Color3.fromRGB(255, 120, 120))
    end
end)

CreateButton(controlFrame, "Add Random Huge Pet", function()
    local ok, result = addRandomPartnerPet("Huge")
    if ok then
        setStatus("Partner added random Huge: " .. result, Color3.fromRGB(120, 220, 120))
    else
        setStatus("Random Huge failed: " .. tostring(result), Color3.fromRGB(255, 120, 120))
    end
end)

CreateButton(controlFrame, "Add Random Titanic", function()
    local ok, result = addRandomPartnerPet("Titanic")
    if ok then
        setStatus("Partner added random Titanic: " .. result, Color3.fromRGB(120, 220, 120))
    else
        setStatus("Random Titanic failed: " .. tostring(result), Color3.fromRGB(255, 120, 120))
    end
end)

task.defer(buildPartnerPetChoices)

-- Auto Ready + Auto Confirm side by side
CreateSpace(controlFrame)

local autoRow = CreateInstance("Frame", controlFrame, {
    Size = UDim2.new(1, 0, 0, 26),
    BackgroundTransparency = 1,
})

CreateToggleButton(autoRow, "Auto Ready", false, function(state)
    Mock.autoReady = state
end, {
    size = UDim2.new(0.49, 0, 1, 0),
    position = UDim2.new(0, 0, 0, 0),
})

CreateToggleButton(autoRow, "Auto Confirm", false, function(state)
    Mock.autoConfirm = state
end, {
    size = UDim2.new(0.49, 0, 1, 0),
    position = UDim2.new(0.51, 0, 0, 0),
})

CreateSpace(controlFrame)
CreateHeading(controlFrame, "Partner controls")

CreateSpace(controlFrame)
CreateButton(controlFrame, "Toggle partner READY", function()
    if not Mock.active then
        return setStatus("No active trade.", Color3.fromRGB(255, 180, 90))
    end

    setPartnerReady(not Mock.state._ready[2])
    setStatus("Partner ready = " .. tostring(Mock.state._ready[2]))
end)

CreateSpace(controlFrame)
CreateButton(controlFrame, "Toggle partner CONFIRM", function()
    if not Mock.active then
        return setStatus("No active trade.", Color3.fromRGB(255, 180, 90))
    end

    if not Mock.state._readyTimer then
        return setStatus(
            "Both must be Ready before Confirm.",
            Color3.fromRGB(255, 180, 90)
        )
    end

    setPartnerConfirmed(not Mock.state._confirmed[2])
    setStatus("Partner confirm = " .. tostring(Mock.state._confirmed[2]))
end)

CreateSpace(controlFrame)
CreateButton(controlFrame, "Force COMPLETE trade", function()
    if not Mock.active then
        return setStatus("No active trade.", Color3.fromRGB(255, 180, 90))
    end

    Mock.state._executing = true
    fire(TradingCmds.TradeExecuting, Mock.id)

    task.wait(0.4)

    endTrade("Trade successfully\ncompleted!")
    setStatus("Trade completed.", Color3.fromRGB(120, 220, 120))
end)
--==================================================================
-- PLAYERS TAB
--==================================================================
local countPlayers = CreateHeading(playersFrame, "Players in server - 0")

local playersScroll = CreateInstance("ScrollingFrame", playersFrame, {
	Size = UDim2.new(1, 0, 0, 300),
	BackgroundTransparency = 0.7,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = THEME.stroke,
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BorderSizePixel = 0,
})
local playersListLayout = CreateInstance("UIListLayout", playersScroll, {
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 6),
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
})
CreateInstance("UIPadding", playersScroll, { PaddingTop = UDim.new(0, 8) })
CreateInstance("UICorner", playersScroll, { CornerRadius = UDim.new(0, 8) })
playersListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	playersScroll.CanvasSize = UDim2.new(0, 0, 0, playersListLayout.AbsoluteContentSize.Y + 16)
end)

local searchBox
local function updatePlayers()
	for _, child in ipairs(playersScroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			local btn = CreateButton(playersScroll, p.Name, function()
				partnerName = p.Name
				partnerBox.Text = p.Name
				setActiveTab("Control")
				setStatus("Partner set to @" .. p.Name)
			end)
			btn.Size = UDim2.new(0.9, 0, 0, 30)
		end
	end
	countPlayers.Text = "Players in server - " .. (#Players:GetPlayers() - 1)
end

CreateSpace(playersFrame)
searchBox = CreateRow(playersFrame, "Search player")
searchBox.Size = UDim2.new(1, 0, 0, 30)
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local q = searchBox.Text:lower()
	for _, btn in ipairs(playersScroll:GetChildren()) do
		if btn:IsA("TextButton") then
			btn.Visible = q == "" or (btn.Text:lower():find(q, 1, true) ~= nil)
		end
	end
end)

Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(function() task.defer(updatePlayers) end)
task.spawn(updatePlayers)
--==================================================================
-- USERS TAB (MANUALLLY CODED BY BLUEPRINT.LUA MY COLLAR IS BLUE AND MY NECK IS RED)
--==================================================================
--==================================================================
-- USERS TAB
--==================================================================
CreateHeading(usersFrame, "Preset users")
CreateSpace(usersFrame)

CreateButton(usersFrame, "Select Current Trade Partner", function()
	local partner = getCurrentTradePartner()
	if not partner then
		return setStatus("No active real or mock trade.", Color3.fromRGB(255, 180, 90))
	end

	partnerName = partner.Name
	partnerBox.Text = partner.Name
	setActiveTab("Control")
	setStatus("Partner set to @" .. partner.Name, Color3.fromRGB(120, 220, 120))
end)

CreateSpace(usersFrame)

local usersScroll = CreateInstance("ScrollingFrame", usersFrame, {
    Size = UDim2.new(1, 0, 0, 300),
    BackgroundTransparency = 0.7,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = THEME.stroke,
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BorderSizePixel = 0,
})
CreateInstance("UICorner", usersScroll, {
    CornerRadius = UDim.new(0, 8),
})
CreateInstance("UIPadding", usersScroll, {
    PaddingTop = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8),
})

local usersLayout = CreateInstance("UIListLayout", usersScroll, {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 6),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
})
usersLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    usersScroll.CanvasSize = UDim2.new(0, 0, 0, usersLayout.AbsoluteContentSize.Y + 16)
end)

for _, username in ipairs(PRESET_USERS) do
    local button = CreateButton(usersScroll, username, function()
        partnerName = username
        partnerBox.Text = username
        setActiveTab("Control")
        setStatus("Partner set to @" .. username, Color3.fromRGB(120, 220, 120))
    end)
    button.Size = UDim2.new(0.9, 0, 0, 30)
end

--==================================================================
-- CHAT TAB (RECODED BY BLUEPRINT.LUA THE KING)
--==================================================================
CreateHeading(chatFrame, "Preset partner messages")
CreateSpace(chatFrame)

local presetChats = {
    "Thank you so much bro",
    "tysm",
    "thanks",
    "can i get a huge please",
    "can i get a titanic",
    "can i get a free pet",
    "im a huge fan",
    "what can i get upgraded to for this",
    "im following!",
    "im subscribed :)",
    "can i get some gems pls",
    "are you giving away free pets?",
    "thanks for being trusted",
    "trusted",
    "YOO NO WAY TY BRO",
}

for _, message in ipairs(presetChats) do
    CreateButton(chatFrame, message, function()
        if not Mock.active then
            return setStatus("No active trade.", Color3.fromRGB(255, 180, 90))
        end

        fire(TradingCmds.TradeMessage, Mock.id, 2, message)
        setStatus("Sent: " .. message, Color3.fromRGB(120, 220, 120))
    end)
    CreateSpace(chatFrame, 2)
end

CreateSpace(chatFrame)
CreateHeading(chatFrame, "Custom partner message")
CreateSpace(chatFrame)

local chatBox = createSettingRow(chatFrame, "Type a message", "")

CreateSpace(chatFrame)
CreateButton(chatFrame, "Send as partner", function()
    if not Mock.active then
        return setStatus("No active trade.", Color3.fromRGB(255, 180, 90))
    end

    if chatBox.Text ~= "" then
        fire(TradingCmds.TradeMessage, Mock.id, 2, chatBox.Text)
        setStatus("Sent partner message.", Color3.fromRGB(120, 220, 120))
        chatBox.Text = ""
    end
end)
--==================================================================
-- SPAWNER TAB
--==================================================================
CreateHeading(spawnerFrame, "Mock Pet Spawner")
CreateSpace(spawnerFrame)
local petNameBox = createSettingRow(spawnerFrame, "Pet id (exact, e.g. Dog / Huge Cat)", "")
CreateSpace(spawnerFrame)
local spShiny, spGolden, spRainbow = false, false, false
CreateToggleButton(spawnerFrame, "Shiny", false, function(s) spShiny = s end)
CreateSpace(spawnerFrame)
local rarityRow = CreateInstance("Frame", spawnerFrame, {
	Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1,
})
CreateToggleButton(rarityRow, "Golden", false, function(s) spGolden = s end, {
	size = UDim2.new(0.49, 0, 1, 0), position = UDim2.new(0, 0, 0, 0),
})
CreateToggleButton(rarityRow, "Rainbow", false, function(s) spRainbow = s end, {
	size = UDim2.new(0.49, 0, 1, 0), position = UDim2.new(0.51, 0, 0, 0),
})
CreateSpace(spawnerFrame)
local spEquip = false
CreateToggleButton(spawnerFrame, "Equip on spawn (client-side)", false, function(s) spEquip = s end)
CreateSpace(spawnerFrame)
local petAmtBox = createSettingRow(spawnerFrame, "Amount (copies, 1-500)", "1")
CreateSpace(spawnerFrame)
CreateButton(spawnerFrame, "Spawn Pet", function()
	local ok, err = spawnPets(petNameBox.Text,
		{ shiny = spShiny, golden = spGolden, rainbow = spRainbow, equip = spEquip },
		petAmtBox.Text)
	if ok then
		setStatus("Spawned " .. petAmtBox.Text .. " x " .. petNameBox.Text, Color3.fromRGB(120, 220, 120))
	else
		setStatus("Spawn failed: " .. tostring(err), Color3.fromRGB(255, 120, 120))
	end
end)
CreateSpace(spawnerFrame)
CreateButton(spawnerFrame, "Spawn Draggable Username GUI", function()
	spawnDraggableUsernameGUI()
	setStatus("Spawned draggable username label.", Color3.fromRGB(120, 220, 120))
end)
CreateSpace(spawnerFrame)
CreateButton(spawnerFrame, "Unequip real pets", function()
	local ok, err = unequipRealPets()
	if ok then setStatus("Fired real unequip-all remote.")
	else setStatus("Unequip failed: " .. tostring(err), Color3.fromRGB(255, 120, 120)) end
end)

CreateSpace(spawnerFrame)
CreateSpace(spawnerFrame)
CreateHeading(spawnerFrame, "Rich Loadout (4 garg / 10 titanic / 125 huge)")
CreateSpace(spawnerFrame)
local spNoDev = false
CreateToggleButton(spawnerFrame, "No dev pets", false, function(s) spNoDev = s end)
CreateSpace(spawnerFrame)
CreateButton(spawnerFrame, "Spawn all rich pets", function()
	local ok, info = spawnRichPets(spNoDev)
	if ok then setStatus("Spawned rich loadout: " .. tostring(info), Color3.fromRGB(120, 220, 120))
	else setStatus("Rich spawn failed: " .. tostring(info), Color3.fromRGB(255, 120, 120)) end
end)
CreateSpace(spawnerFrame)
CreateButton(spawnerFrame, "Spawn all rich pets 2X", function()
	local ok, info = spawnRichPets(spNoDev, 2)
	if ok then setStatus("Spawned 2X rich loadout: " .. tostring(info), Color3.fromRGB(120, 220, 120))
	else setStatus("2X rich spawn failed: " .. tostring(info), Color3.fromRGB(255, 120, 120)) end
end)

CreateSpace(spawnerFrame)
CreateSpace(spawnerFrame)
CreateHeading(spawnerFrame, "Mock Diamond Spawner")
CreateSpace(spawnerFrame)
local diaBox = createSettingRow(spawnerFrame, "Diamonds to add", "1000000")
CreateSpace(spawnerFrame)
CreateButton(spawnerFrame, "Spawn Diamonds", function()
	local ok, err = spawnDiamonds(diaBox.Text)
	if ok then
		setStatus("Added " .. diaBox.Text .. " diamonds", Color3.fromRGB(120, 220, 120))
	else
		setStatus("Diamond spawn failed: " .. tostring(err), Color3.fromRGB(255, 120, 120))
	end
end)

--==================================================================
-- Toggle GUI visibility (Right Control)
--==================================================================
UserInput.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightControl then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

setStatus("Ready. (Right Ctrl hides this panel)")
print("Fake trade loaded. Script created by blueprint.lua and .slaypeter. on discord | DM FOR ANY SCRIPT INQUIRIES")
