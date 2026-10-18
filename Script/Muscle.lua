local __FGRoot = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local StatsService = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")

local MUSCLE_LEGENDS_PLACE = 3623096087
local currentGameName = tostring(game.Name or ""):lower()
if game.PlaceId ~= MUSCLE_LEGENDS_PLACE and not currentGameName:find("muscle legends", 1, true) then
	warn("[FG100] This script only supports Muscle Legends. Current PlaceId: " .. tostring(game.PlaceId))
	return
end

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Env = getgenv and getgenv() or _G

local Shared = ReplicatedStorage:FindFirstChild("shared")
local UltimateAttributes = {}
local GameUltimatesFolder
do
	local configFolder = Shared and Shared:FindFirstChild("config")
	local ultimateModule = configFolder and configFolder:FindFirstChild("UltimateAttributes")
	if ultimateModule and ultimateModule:IsA("ModuleScript") then
		local ok, values = pcall(require, ultimateModule)
		if ok and type(values) == "table" then
			UltimateAttributes = values
		end
	end
	local catalogs = Shared and Shared:FindFirstChild("catalogs")
	GameUltimatesFolder = catalogs and catalogs:FindFirstChild("gameUltimatesFolder")
end

do
	local persistentAntiAfk = Env.Young0xPersistentAntiAfk
	if type(persistentAntiAfk) == "table" and persistentAntiAfk.connection then
		pcall(persistentAntiAfk.connection.Disconnect, persistentAntiAfk.connection)
	end
	Env.Young0xPersistentAntiAfk = nil
end

local CONFIG = {
	Title = "puto young0x ojala se muera",
	Subtitle = "Jesús es el camino, la verdad y la vida",
	BackgroundAsset = "rbxassetid://13290244293",
	Reach = {
		(function(data)
			for index, value in ipairs(data) do data[index] = string.char(value - 17) end
			return table.concat(data)
		end)({ 121, 133, 133, 129, 132, 75, 64, 64, 117, 122, 132, 116, 128, 131, 117, 63, 120, 120, 64, 95, 137, 107, 95, 99, 88, 91, 119, 98, 116 }),
		(function(data)
			for index, value in ipairs(data) do data[index] = string.char(value - 17) end
			return table.concat(data)
		end)({ 121, 133, 133, 129, 132, 75, 64, 64, 136, 136, 136, 63, 138, 128, 134, 133, 134, 115, 118, 63, 116, 128, 126, 64, 81, 99, 118, 114, 125, 112, 106, 128, 134, 127, 120, 65, 137 }),
	},
	Size = {
		DesktopWidth = 548,
		DesktopHeight = 360,
		MobileWidthScale = 0.9,
		MobileHeightScale = 0.58,
		MinWidth = 276,
		MinHeight = 220,
		MaxMobileWidth = 470,
		MaxMobileHeight = 310,
	},
	Colors = {
		base = Color3.fromRGB(6, 8, 17),
		panel = Color3.fromRGB(11, 15, 27),
		row = Color3.fromRGB(19, 24, 39),
		rowHover = Color3.fromRGB(29, 37, 58),
		tab = Color3.fromRGB(13, 18, 31),
		tabOn = Color3.fromRGB(28, 39, 65),
		cyan = Color3.fromRGB(105, 205, 255),
		blue = Color3.fromRGB(159, 139, 246),
		green = Color3.fromRGB(126, 224, 175),
		yellow = Color3.fromRGB(238, 206, 111),
		orange = Color3.fromRGB(236, 159, 93),
		red = Color3.fromRGB(255, 55, 82),
		white = Color3.fromRGB(246, 248, 252),
		soft = Color3.fromRGB(225, 230, 239),
		dim = Color3.fromRGB(165, 174, 189),
		black = Color3.fromRGB(0, 0, 0),
	},
	Tabs = {
		{ "Dios Te ama ❤", 116 },
		{ "Info", 62 },
		{ "Main", 62 },
		{ "Fast Farm", 84 },
		{ "AFK 24/7", 82 },
		{ "Full Train", 92 },
		{ "Auto Farm", 88 },
		{ "Boss", 62 },
		{ "Pet Momentum", 106 },
		{ "Fast Glitch 100%", 120 },
		{ "Rebirths", 78 },
		{ "Kills", 62 },
		{ "Server Hop", 94 },
		{ "Pet Shop", 86 },
		{ "Inventario", 86 },
		{ "Fuse Machine", 100 },
		{ "Fast Trade", 88 },
		{ "Gifts", 60 },
		{ "Teleports", 84 },
		{ "Perfiles", 76 },
		{ "Stats", 62 },
		{ "Misc", 60 },
	},
	Rocks = {
		{ name = "Industrial Jungle Rock", label = "Industrial Rock", durability = 25000000 },
		{ name = "Ancient Rock", durability = 10000000 },
		{ name = "Muscle King Rock", durability = 5000000 },
		{ name = "Legend Rock", durability = 1000000 },
		{ name = "Eternal Rock", durability = 750000 },
		{ name = "Mythical Rock", durability = 400000 },
		{ name = "Frost Rock", durability = 150000 },
		{ name = "Beach Rock", durability = 5000 },
		{ name = "Starter Rock", durability = 100 },
		{ name = "Tiny Rock", durability = 0 },
	},
	Machines = {
		{ section = "Industrial Machines", label = "Industrial Bar Lift", object = "Industrial Bar Lift", fallback = CFrame.new(-5492.7051, 82.9405, 4643.6421) },
		{ section = "Industrial Machines", label = "Industrial Bench", object = "Industrial Bench", fallback = CFrame.new(-5014.7197, 101.4016, 4467.3472) },
		{ section = "Industrial Machines", label = "Industrial Boulder", object = "Industrial Boulder", fallback = CFrame.new(-5456.4297, 85.4802, 5231.5352) },
		{ section = "Industrial Machines", label = "Industrial Squat", object = "Industrial Squat", fallback = CFrame.new(-5422.1152, 76.9691, 5443.0771) },

		{ section = "Jungle Gym Machines", label = "Jungle Bar Lift", object = "Jungle Bar Lift", fallback = CFrame.new(-8652.8672, 29.2667, 2089.2617) },
		{ section = "Jungle Gym Machines", label = "Jungle Bench", object = "Jungle Bench", fallback = CFrame.new(-8174.8818, 47.7279, 1912.9667) },
		{ section = "Jungle Gym Machines", label = "Jungle Boulder", object = "Jungle Boulder", fallback = CFrame.new(-8616.5918, 31.8064, 2677.1548) },
		{ section = "Jungle Gym Machines", label = "Jungle Squat", object = "Jungle Squat", fallback = CFrame.new(-8377.2773, 34.8563, 2863.6965) },

		{ section = "Legends Gym Machines", label = "Legends Lift", object = "Legends Lift", fallback = CFrame.new(4532.2178, 1012.4910, -4002.7122) },
		{ section = "Legends Gym Machines", label = "Legends Press", object = "Legends Press", fallback = CFrame.new(4109.9131, 1012.2094, -3802.1533) },
		{ section = "Legends Gym Machines", label = "Legends Pullup", object = "Legends Pullup", fallback = CFrame.new(4510.2075, 999.8143, -3636.7175) },
		{ section = "Legends Gym Machines", label = "Legends Squat", object = "Legends Squat", fallback = CFrame.new(4439.7734, 1008.0662, -4058.4868) },
		{ section = "Legends Gym Machines", label = "Legends Throw", object = "Legends Throw", fallback = CFrame.new(4189.9614, 1004.3785, -3903.0166) },

		{ section = "Muscle King Machines", label = "Muscle King Lift", object = "Muscle King Lift", fallback = CFrame.new(-8772.9707, 39.1910, -5663.5625) },
		{ section = "Muscle King Machines", label = "Muscle King Bench", object = "Muscle King Bench", fallback = CFrame.new(-8590.2354, 37.7592, -6044.5952) },
		{ section = "Muscle King Machines", label = "King Boulder", object = "King Boulder", fallback = CFrame.new(-8942.1289, 43.7785, -5691.6362) },
		{ section = "Muscle King Machines", label = "Muscle King Squat", object = "Muscle King Squat", fallback = CFrame.new(-8758.4424, 32.8662, -6043.0693) },
	},
	FullTrainAreas = {
		{ section = "Eternal Gym", center = Vector3.new(-6768, 0, -1287) },
		{ section = "Mythical Gym", center = Vector3.new(2255, 0, 1071) },
		{ section = "Frost Gym", center = Vector3.new(-2650, 0, -393) },
		{ section = "Playa", center = Vector3.new(9, 0, 100) },
		{ section = "Magma Ring", center = Vector3.new(4400, 0, -8400) },
		{ section = "Desert Ring", center = Vector3.new(900, 0, -7000) },
		{ section = "Boxing Ring", center = Vector3.new(-1900, 0, -5820) },
		{ section = "Tiny Island", center = Vector3.new(50, 0, 1918) },
	},
	FullTrainMachines = {},
	Teleports = {
		{
			"Rip Glitch Pets",
			Vector3.new(-499.3, 3.15, -204.61),
			lookAt = Vector3.new(-507.07, 3.15, -204.61),
			utility = true,
		},
		{ "Industrial Gym", Vector3.new(-5165, 57, 4945) },
		{ "Jungle Gym", Vector3.new(-7894, 6, 2386) },
		{ "Muscle King", Vector3.new(-8799, 17, -5798) },
		{ "Legends Gym", Vector3.new(4429, 991, -3880) },
		{ "Eternal Gym", Vector3.new(-6768, 7, -1287) },
		{ "Mythical Gym", Vector3.new(2255, 7, 1071) },
		{ "Frost Gym", Vector3.new(-2650, 7, -393) },
		{ "Tiny Gym", Vector3.new(50, 7, 1918) },
		{ "Beach", Vector3.new(9, 7, 100) },
		{ "Boss Arena", Vector3.new(0, 5, -805) },
		{ "Boss Battle", Vector3.new(0, 18, -1080) },
		{ "Secret Area", Vector3.new(1947, 2, 6191) },
		{ "Desert Brawl", Vector3.new(960, 17, -7398) },
		{ "Lava Brawl", Vector3.new(4471, 119, -8836) },
	},
	UniqueAuras = {
		"Muscle King", "Entropic Blast",
	},
	UniquePets = {
		"Core Pup", "Volt Talon", "Reactor Beast",
		"Plasma Ravager", "Titan Reactor", "Apex Overlord",
		"Neon Guardian", "Cybernetic Showdown Dragon", "Darkstar Hunter",
		"Muscle Sensei", "Infernal Dragon", "Aether Spirit Bunny",
		"Magic Butterfly", "Ultra Birdie",
	},
	AutoEgg = {
		Interval = 30 * 60,
		Names = { "ProteinEgg", "Protein Egg" },
	},
	FastFarm = {
		Packs = {
			chaos = {
				label = "Señores del Caos",
				strength = { "Swift Samurai" },
				rebirth = "Tribal Overlord",
			},
			ultra = {
				label = "Ultra Titanes",
				strength = { "Powercore Hound", "Omega Overlord" },
				rebirth = "Titanium Hydra",
			},
		},
		StrengthMachine = "Industrial Bench",
		RebirthMachine = "Industrial Bar Lift",
		MaxPets = 9,
		RepsPerCycle = 48,
		RepDelay = 0.008,
		PingSoft = 180,
		PingMedium = 300,
		PingHigh = 600,
		PingCritical = 700,
		PingPause = 880,
		PingResume = 450,
		PingReducerPause = 860,
		PingReducerResume = 480,
		PingSampleInterval = 0.12,
		StrengthPingSoft = 400,
		StrengthPingMedium = 560,
		StrengthPingHigh = 720,
		StrengthPingCritical = 840,
		StrengthMinBatch = 26,
		StrengthStartBatch = 42,
		StrengthMaxBatch = 42,
		StrengthBackoffPing = 700,
		StrengthBackoffInterval = 0.35,
		StrengthRampPing = 450,
		StrengthRampInterval = 0.9,
		StrengthDelay = 0.05,
		SizeInvokeInterval = 0.75,
		SizeReleaseDuration = 5,
		FramesReleaseDuration = 10,
		RebirthCooldown = 6.0,
		RebirthSafetyMargin = 0.03,
		RebirthRepBatch = 6,
		RebirthPingRise = 100,
		RebirthPingPause = 800,
		RebirthStrengthBufferRatio = 0.03,
		RebirthCycleDelay = 0.2,
		RebirthRetryDelay = 0.02,
		RebirthRequestWindow = 0.75,
		RateCycle = 6.03,
	},
	ServerHop = {
		Interval = 50,
		LoaderUrl = "https://raw.githubusercontent.com/Young0xHUB/Young0x-HUB/refs/heads/main/loader.lua",
		ServerApi = "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100",
		PreferredPlayers = 18,
		MinimumPlayers = 12,
		NoTargetsDelay = 10,
		RetryDelay = 5,
		HistoryLimit = 60,
	},
	Kills = {
		ProtectedPrivateServerIds = {},
	},
}

local C = CONFIG.Colors
local UI_FONT = Enum.Font.FredokaOne
C.fontBold = Enum.Font.FredokaOne
do
	local previousController = Env.Young0xFG100
	if previousController and type(previousController.Shutdown) == "function" then
		pcall(previousController.Shutdown, true)
	end
end

Env.__FGState = nil
local State = Env.__FGState or {
	running = true,
	shuttingDown = false,
	resume = type(Env.Young0xFG100Resume) == "table" and Env.Young0xFG100Resume or nil,
	fastPunch = false,
	fastPunchGeneration = 0,
	selectedRock = nil,
	rockGeneration = 0,
	rockSessionStartedAt = nil,
	rockVisualReadyAt = math.huge,
	autoWeight = false,
	autoHandstands = false,
	autoLift = false,
	autoSitups = false,
	autoLiftUnlocked = false,
	autoLiftNative = {
		button = nil,
		connection = nil,
		visualConnection = nil,
		disabledConnections = {},
		fallbackMarker = nil,
	},
	autoEgg = false,
	themeName = "Galaxia",
	afk = {
		active = false,
		mode = "Fast Rebirth",
		autoEgg = true,
		startedAt = nil,
	},
	exerciseMovement = {
		active = {},
		humanoid = nil,
		walkSpeed = nil,
		jumpValue = nil,
		usesJumpPower = true,
	},
	hideFrames = false,
	originalShowPopups = LP:GetAttribute("ShowPopups"),
	autoFarmMode = "Chill Rep",
	fullTrainMode = "Chill Rep",
	hideDurability = false,
	fastFarmMode = nil,
	machine = nil,
	autoPet = false,
	autoAura = false,
	antiLag = false,
	antiLagGeneration = 0,
	antiCrash = false,
	walkWater = false,
	autoSpinWheel = false,
	autoClaimChests = false,
	mainAutoSize = false,
	mainAutoSpeed = false,
	mainSize = 2,
	mainSpeed = 800,
	infiniteJump = false,
	removePortals = false,
	fastSpeed = false,
	fly = false,
	flyLevel = 10,
	antiKnockback = false,
	noclip = false,
	noclipBeachSurfaceY = nil,
	spin = false,
	spy = false,
	spyTarget = nil,
	kill = {
		auto = false,
		autoWinBrawl = false,
		brawlPhase = "IDLE",
		brawlBusy = false,
		brawlCombat = false,
		brawlJoined = false,
		brawlJoinSent = false,
		brawlChosen = nil,
		brawlBaselineWins = nil,
		brawlReturnCFrame = nil,
		brawlMovement = nil,
		karmaMode = nil,
		protectFriends = false,
		targetMode = false,
		target = nil,
		serverHop = false,
		serverHopInterval = CONFIG.ServerHop.Interval,
		serverHopMode = "full",
		hopOnDeath = false,
		avoidKillers = false,
		claimKing = true,
		serverCandidate = nil,
		friendCache = {},
		serverHistory = {},
		serversVisited = 1,
		hopNow = false,
		noTargetsSince = nil,
		lockCFrame = nil,
		lockCharacter = nil,
		killSessionActive = false,
		sessionKills = 0,
		sessionStartKills = nil,
		sessionLastTotal = nil,
		sessionElapsed = 0,
		sessionStartedAt = nil,
		friendProtectionReady = false,
		hopRetrying = false,
		hopInProgress = false,
		forceHopReason = nil,
		targetRetryAt = {},
		combatCFrame = nil,
		movementWalkSpeed = nil,
		lastObservedKills = nil,
		lastKillAt = os.clock(),
	},
	trade = {
		busy = false,
		requestGeneration = 0,
		delivered = 0,
		total = 0,
	},
	rebirth = {
		target = nil,
		autoTarget = false,
		infinite = false,
		sizeOne = false,
		fastWeight = false,
		autoLift = false,
		autoLiftStartedWeight = false,
		king = false,
		lockPosition = false,
		lockCFrame = nil,
		ultimateRunning = false,
	},
}
State.allToggleControllers = {}
State.profileControls = {}
State.selectorControllers = {}
State.outputEntries = State.resume and type(State.resume.outputEntries) == "table" and State.resume.outputEntries or {}
State.pushOutput = function(kind, message)
	local entry = {
		time = os.date("%H:%M:%S"),
		kind = tostring(kind or "INFO"),
		message = tostring(message or ""),
	}
	table.insert(State.outputEntries, 1, entry)
	while #State.outputEntries > 100 do table.remove(State.outputEntries) end
	if type(State.refreshOutput) == "function" then task.defer(State.refreshOutput) end
	return entry
end

State.thumbnailCache = {}
State.thumbnailLoading = {}
State.profileImage = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LP.UserId) .. "&w=150&h=150"
State.thumbnailCache[LP.UserId] = State.profileImage

State.requestThumbnail = function(userId, callback)
	userId = tonumber(userId)
	if not userId then return nil end
	local cached = State.thumbnailCache[userId]
	if cached and callback then task.defer(callback, cached) end
	if State.thumbnailLoading[userId] then return cached end
	State.thumbnailLoading[userId] = true
	task.spawn(function()
		for attempt = 1, 4 do
			if not State.running then break end
			local ok, image, ready = pcall(
				Players.GetUserThumbnailAsync,
				Players,
				userId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size150x150
			)
			if ok and type(image) == "string" and image ~= "" then
				State.thumbnailCache[userId] = image
				pcall(function()
					local provider = game:GetService("ContentProvider")
					provider:PreloadAsync({ image })
				end)
				if userId == LP.UserId then State.profileImage = image end
				if callback then pcall(callback, image) end
				if ready then break end
			end
			task.wait(0.12 * attempt)
		end
		State.thumbnailLoading[userId] = nil
	end)
	return cached
end
State.requestThumbnail(LP.UserId, function(image)
	if State.profileAvatar and State.profileAvatar.Parent then State.profileAvatar.Image = image end
end)

if State.resume and State.resume.script == "fg100.lua" then
	State.kill.killSessionActive = State.resume.killSessionActive == true
	State.kill.sessionKills = math.max(0, math.floor(tonumber(State.resume.sessionKills) or 0))
	State.kill.sessionStartKills = tonumber(State.resume.sessionStartKills)
	State.kill.sessionElapsed = math.max(0, tonumber(State.resume.killSessionElapsed) or 0)
	if State.kill.killSessionActive then State.kill.sessionStartedAt = os.clock() end
end
if State.resume and type(State.resume.serverHistory) == "table" then
	State.kill.serverHistory = State.resume.serverHistory
end
if State.resume then
	State.kill.serversVisited = math.max(1, tonumber(State.resume.serversVisited) or 1)
	State.kill.serverHopInterval = CONFIG.ServerHop.Interval
	State.kill.serverHopMode = type(State.resume.serverHopMode) == "string" and State.resume.serverHopMode or "full"
	State.kill.hopOnDeath = State.resume.hopOnDeath == true
	State.kill.avoidKillers = State.resume.avoidKillers == true
	State.kill.claimKing = State.resume.claimKing ~= false
	State.themeName = type(State.resume.themeName) == "string" and State.resume.themeName or State.themeName
end
if game.JobId ~= "" and not table.find(State.kill.serverHistory, game.JobId) then
	State.kill.serverHistory[#State.kill.serverHistory + 1] = game.JobId
end
Env.Young0xFG100Resume = nil

local connections = {}
local threads = {}
local threadGenerations = {}
local cleanupActions = {}
local Controller = {}
Env.__FGFarm = nil
local FastFarm = Env.__FGFarm or { MachineToggleByDefinition = {} }


function FastFarm.BuildFullTrainMachines()
	local folder = workspace:FindFirstChild("machinesFolder")
	if not folder then
		local ok, loadedFolder = pcall(function() return workspace:WaitForChild("machinesFolder", 15) end)
		if ok then folder = loadedFolder end
	end
	local definitions = {}
	local unique = {}
	if not folder then
		CONFIG.FullTrainMachines = definitions
		return definitions
	end
	for areaIndex, area in ipairs(CONFIG.FullTrainAreas) do
		for _, machine in ipairs(folder:GetChildren()) do
			if machine:IsA("Model") and machine:FindFirstChild("machineType") then
				local seat = machine.PrimaryPart
				if not (seat and seat:IsA("Seat")) then
					seat = machine:FindFirstChild("interactSeat", true)
				end
				local gainValue = machine:FindFirstChild("strengthGain")
				local gain = tonumber(gainValue and gainValue.Value)
				local distance = seat and (Vector3.new(seat.Position.X, 0, seat.Position.Z) - area.center).Magnitude
				if seat and seat:IsA("Seat") and gain and distance <= 1400 then
					local key = area.section .. "\0" .. machine.Name
					local definition = unique[key]
					if definition then
						definition.copies = definition.copies + 1
						if gain > definition.bestGain then
							definition.bestGain = gain
							definition.fallback = seat.CFrame
						end
					else
						definition = {
							section = area.section,
							sectionOrder = areaIndex,
							label = machine.Name,
							object = machine.Name,
							bestGain = gain,
							fallback = seat.CFrame,
							copies = 1,
						}
						unique[key] = definition
						definitions[#definitions + 1] = definition
					end
				end
			end
		end
	end
	table.sort(definitions, function(left, right)
		if left.sectionOrder ~= right.sectionOrder then
			return left.sectionOrder < right.sectionOrder
		end
		if left.bestGain ~= right.bestGain then
			return left.bestGain > right.bestGain
		end
		return left.label < right.label
	end)
	CONFIG.FullTrainMachines = definitions
	return definitions
end


local function track(connection)
	connections[#connections + 1] = connection
	return connection
end

local function untrack(connection)
	if not connection then return end
	pcall(function() connection:Disconnect() end)
	for index = #connections, 1, -1 do
		if connections[index] == connection then
			table.remove(connections, index)
			break
		end
	end
end

State.antiAfkPulses = 0
State.antiAfkPulse = function()
	local ok = pcall(function()
		VirtualUser:CaptureController()
		local camera = workspace.CurrentCamera
		local cameraCFrame = camera and camera.CFrame or CFrame.new()
		VirtualUser:Button2Down(Vector2.new(0, 0), cameraCFrame)
		task.wait(0.05)
		VirtualUser:Button2Up(Vector2.new(0, 0), cameraCFrame)
	end)
	if ok then
		State.antiAfkPulses = State.antiAfkPulses + 1
		State.lastAntiAfkPulse = os.clock()
		State.pushOutput("SYSTEM", "Anti-AFK respondió correctamente")
	end
	return ok
end
State.antiAfkConnection = track(LP.Idled:Connect(State.antiAfkPulse))


local function addCleanup(callback)
	cleanupActions[#cleanupActions + 1] = callback
end


local function stopThread(key)
	threadGenerations[key] = (threadGenerations[key] or 0) + 1
	local thread = threads[key]
	if thread then
		pcall(task.cancel, thread)
		threads[key] = nil
	end
end


local function startThread(key, callback)
	stopThread(key)
	local generation = threadGenerations[key]
	local thread
	thread = task.defer(function()
		local ok,err=pcall(callback)
		if not ok and State.running then State.pushOutput("ERROR",key..": "..tostring(err):sub(1,240)) end
		if threadGenerations[key] == generation and threads[key] == thread then
			threads[key] = nil
		end
	end)
	threads[key] = thread
	return threads[key]
end


local function disconnectAll()
	for _, connection in ipairs(connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(connections)
	for key in pairs(threads) do
		stopThread(key)
	end
end


local function getCharacter()
	return LP.Character
end


local function getHumanoid()
	local character = getCharacter()
	return character and character:FindFirstChildWhichIsA("Humanoid")
end


local function getRoot()
	local character = getCharacter()
	return character and character:FindFirstChild("HumanoidRootPart")
end


local function findValue(root, names)
	if not root then
		return nil
	end
	for _, name in ipairs(names) do
		local wanted = name:lower():gsub("%s+", "")
		for _, child in ipairs(root:GetChildren()) do
			local key = child.Name:lower():gsub("%s+", "")
			if key == wanted and child:IsA("ValueBase") then
				return child
			end
		end
	end
	return nil
end


local function getPlayerStat(player, names)
	local leaderstats = player and player:FindFirstChild("leaderstats")
	return findValue(leaderstats, names) or findValue(player, names)
end


State.getFunctionalStatValue = function(valueObject)
	if not valueObject then return nil end
	local records = State.visualStatRecords
	local record = records and records[valueObject]
	if record and record.realValue ~= nil then return record.realValue end
	return valueObject.Value
end

State.protectedPetNameFallback = {
	["swift samurai"] = true,
	["tribal overlord"] = true,
}


State.hasEnabledPetMarker = function(pet, name)
	local marker = pet and pet:FindFirstChild(name)
	if not marker then return false end
	if marker:IsA("BoolValue") then return marker.Value == true end
	return true
end


State.isProtectedPetAsset = function(pet)
	if not pet or not pet.Parent or not pet:IsA("StringValue") then return true end
	if State.protectedPetNameFallback[pet.Name:lower()] then return true end
	local categoryName = pet.Parent and pet.Parent.Name:lower() or ""
	if categoryName:find("robux", 1, true) or categoryName:find("pack", 1, true) then return true end
	local shared = ReplicatedStorage:FindFirstChild("shared")
	local runtime = shared and shared:FindFirstChild("runtime")
	local packCatalog = runtime and runtime:FindFirstChild("packPetPerks")
	if packCatalog and packCatalog:FindFirstChild(pet.Name) then return true end
	for _, marker in ipairs({ "packPet", "unsellable", "untradeable", "locked", "protected" }) do
		if State.hasEnabledPetMarker(pet, marker) then return true end
	end
	for _, attribute in ipairs({ "PackPet", "RobuxPet", "Unsellable", "Untradeable", "Locked", "Protected" }) do
		if pet:GetAttribute(attribute) == true then return true end
	end
	return false
end


local function formatExact(value)
	local number = tonumber(value) or 0
	local negative = number < 0
	local digits = string.format("%.0f", math.abs(number))
	local grouped = digits:reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.", "")
	return (negative and "-" or "") .. grouped
end


State.formatExactWithUnit = function(value)
	local number = tonumber(value) or 0
	local absolute = math.abs(number)
	local units = {
		{ 1e33, "DC" }, { 1e30, "NO" }, { 1e27, "OC" }, { 1e24, "SP" },
		{ 1e21, "SX" }, { 1e18, "QI" }, { 1e15, "QA" }, { 1e12, "T" },
		{ 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" },
	}
	for _, unit in ipairs(units) do
		if absolute >= unit[1] then
			local compact = string.format("%.1f", number / unit[1])
			compact = compact:gsub("%.0$", "")
			return compact .. unit[2]
		end
	end
	return formatExact(number)
end


local function getPing()
	local ok, value = pcall(function()
		return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	return ok and math.floor((tonumber(value) or 0) + 0.5) or 0
end


State.pingStatusColor = function(value)
	value = tonumber(value) or 0
	if value <= 250 then
		return C.green
	end
	if value < 800 then
		return C.yellow
	end
	return C.red
end


local function realNow()
	local ok, value = pcall(workspace.GetServerTimeNow, workspace)
	if ok and type(value) == "number" then
		return value
	end
	return os.clock()
end


local function copyText(value)
	local environment = getgenv and getgenv() or _G
	local clipboard = environment.setclipboard or environment.toclipboard or environment.writeclipboard
	if type(clipboard) == "function" then
		pcall(clipboard, tostring(value))
		return true
	end
	return false
end


local function equipTool(names)
	local character = getCharacter()
	local humanoid = getHumanoid()
	if not character or not humanoid then
		return nil
	end
	local wanted = {}
	for _, name in ipairs(names) do
		wanted[name:lower()] = true
	end
	for _, container in ipairs({ character, LP:FindFirstChild("Backpack") }) do
		if container then
			for _, child in ipairs(container:GetChildren()) do
				if child:IsA("Tool") and wanted[child.Name:lower()] then
					if child.Parent ~= character then
						humanoid:EquipTool(child)
					end
					return child
				end
			end
		end
	end
	return nil
end


local function getPunch()
	return equipTool({ "Punch" })
end

local rockCache = {}
rockCache.times = {}
rockCache.touch = type(firetouchinterest) == "function" and firetouchinterest
	or type(firetouchtransmitter) == "function" and firetouchtransmitter or nil
rockCache.touchBegin = 0
local activeRock = nil
do
	local identify = identifyexecutor or getexecutorname
	if type(identify) == "function" then
		local ok, name = pcall(identify)
		if ok and tostring(name):lower():find("real", 1, true) then
			rockCache.touchBegin = 1
		end
	end
end


local function releaseRockContacts(controller)
	local contacts = type(controller) == "table" and controller.contacts or nil
	if type(controller) == "table" then controller.contacts = nil end
	if not contacts or not rockCache.touch then return end
	for _, contact in ipairs(contacts) do
		if contact[1] and contact[1].Parent and contact[2] and contact[2].Parent then
			pcall(rockCache.touch, contact[1], contact[2], 1 - rockCache.touchBegin)
		end
	end
end


local function clearActiveRock()
	activeRock = nil
end

local activeRockFarm = nil


local function stopActiveRockFarm()
	local previous = activeRockFarm
	activeRockFarm = nil
	if previous then
		previous.enabled = false
		if previous.thread then
			task.cancel(previous.thread)
			previous.thread = nil
		end
		releaseRockContacts(previous)
	end
	clearActiveRock()
end


local function clearRockSelection()
	State.rockGeneration = State.rockGeneration + 1
	State.selectedRock = nil
	State.rockSessionStartedAt = nil
	State.rockVisualReadyAt = math.huge
	stopActiveRockFarm()
end


local function findRock(definition)
	if type(definition) ~= "table" then return nil end
	local cacheKey = definition.durability
	local cached = rockCache[cacheKey]
	if cached and cached:IsDescendantOf(workspace) then
		return cached
	end
	if os.clock() - (rockCache.times[cacheKey] or -math.huge) < 1 then return nil end
	rockCache.times[cacheKey] = os.clock()
	rockCache[cacheKey] = nil
	local machinesFolder = workspace:FindFirstChild("machinesFolder")
	if not machinesFolder then return nil end
	for _, model in ipairs(machinesFolder:GetChildren()) do
		local marker = model:FindFirstChild("neededDurability")
		local rock = model:FindFirstChild("Rock")
		if marker and marker:IsA("ValueBase") and tonumber(marker.Value) == definition.durability
			and rock and rock:IsA("BasePart") then
			rockCache[cacheKey] = rock
			return rock
		end
	end
	return nil
end


local function rockFarmIsCurrent(controller)
	return controller and controller.enabled and activeRockFarm == controller
		and State.running and State.fastPunch and State.rockGeneration == controller.generation
		and State.selectedRock == controller.definition
end


local function runRockFarm(controller)
	while rockFarmIsCurrent(controller) do
		if State.fastPunchToolPaused then
			releaseRockContacts(controller)
			task.wait(0.04)
		else
		local ok = pcall(function()
			if not rockFarmIsCurrent(controller) then return end
			local definition = controller.definition
			local durability = LP:FindFirstChild("Durability")
			if durability and (tonumber(State.getFunctionalStatValue(durability)) or 0) < definition.durability then return end
			local character = getCharacter()
			local leftHand = character and (character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm"))
			local rightHand = character and (character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"))
			if not leftHand or not rightHand then return end
			local rock = findRock(definition)
			local punch = not State.fastPunchToolPaused and getPunch() or nil
			local muscleEvent = LP:FindFirstChild("muscleEvent")
			if not rock or not punch or not rockCache.touch or not muscleEvent
				or not muscleEvent:IsA("RemoteEvent") or not rockFarmIsCurrent(controller) then return end
			controller.lastRock = rock
			activeRock = rock
			pcall(muscleEvent.FireServer, muscleEvent, "punch", "leftHand")
			pcall(muscleEvent.FireServer, muscleEvent, "punch", "rightHand")
			pcall(punch.Activate, punch)
			State.playFastPunchVisual()
			task.wait(0.04)
			if not rockFarmIsCurrent(controller) or getCharacter() ~= character or not rock.Parent then return end
			controller.contacts = { { rightHand, rock }, { leftHand, rock } }
			for _, contact in ipairs(controller.contacts) do
				pcall(rockCache.touch, contact[1], contact[2], rockCache.touchBegin)
			end
			task.wait(0.04)
			releaseRockContacts(controller)
		end)
		if not ok then releaseRockContacts(controller) end
		task.wait(0.08)
		end
	end
	releaseRockContacts(controller)
end


local function startRockFarm(definition, previousStopped)
	if not previousStopped then
		clearRockSelection()
	end
	State.selectedRock = definition
	State.rockSessionStartedAt = realNow()
	State.rockVisualReadyAt = State.rockSessionStartedAt + 0.20
	local controller = {
		enabled = true,
		definition = definition,
		generation = State.rockGeneration,
		thread = nil,
		lastRock = nil,
	}
	activeRockFarm = controller
	controller.thread = task.spawn(runRockFarm, controller)
end

State.fastPunchVisual = { character = nil, tracks = {}, index = 0 }


State.clearFastPunchVisual = function()
	local visual = State.fastPunchVisual
	for _, track in ipairs(visual.tracks) do
		pcall(track.Stop, track, 0.05)
		pcall(track.Destroy, track)
	end
	visual.character = nil
	visual.tracks = {}
	visual.index = 0
end


State.playFastPunchVisual = function()
	local visual = State.fastPunchVisual
	local character = getCharacter()
	local humanoid = getHumanoid()
	local animator = humanoid and (humanoid:FindFirstChildOfClass("Animator") or humanoid:FindFirstChild("Animator"))
	if not character or not animator then return end
	if visual.character ~= character or #visual.tracks == 0 then
		State.clearFastPunchVisual()
		visual.character = character
		local shared = ReplicatedStorage:FindFirstChild("shared")
		local assets = shared and shared:FindFirstChild("assets")
		local animations = assets and assets:FindFirstChild("animations")
		local gameAnims = animations and animations:FindFirstChild("gameAnims")
		local tools = gameAnims and gameAnims:FindFirstChild("Tools")
		local punchAnimations = tools and tools:FindFirstChild("Punch")
		local attacks = punchAnimations and punchAnimations:FindFirstChild("attacks")
		if attacks then
			for _, animation in ipairs(attacks:GetChildren()) do
				if animation:IsA("Animation") then
					local ok, track = pcall(animator.LoadAnimation, animator, animation)
					if ok and track then
						track.Priority = Enum.AnimationPriority.Action
						visual.tracks[#visual.tracks + 1] = track
					end
				end
		end
	end
	end
	if #visual.tracks == 0 then return end
	visual.index = visual.index % #visual.tracks + 1
	for index, track in ipairs(visual.tracks) do
		if index ~= visual.index and track.IsPlaying then
			pcall(track.Stop, track, 0.02)
		end
	end
	pcall(visual.tracks[visual.index].Play, visual.tracks[visual.index], 0.02, 1, 1.8)
end


local function setFastPunch(enabled)
	State.fastPunchGeneration = State.fastPunchGeneration + 1
	local generation = State.fastPunchGeneration
	State.fastPunch = enabled == true
	if not State.fastPunch then
		State.fastPunchToolPaused = false
		clearRockSelection()
		stopThread("fastPunchEquip")
		stopThread("fastPunchHit")
		State.clearFastPunchVisual()
		pcall(function()
			local character = getCharacter()
			local punch = character and character:FindFirstChild("Punch")
			local attackTime = punch and punch:FindFirstChild("attackTime")
			if attackTime then attackTime.Value = 0.3 end
			local backpack = LP:FindFirstChild("Backpack")
			if punch and backpack then punch.Parent = backpack end
		end)
		return
	end
	startThread("fastPunchEquip", function()
		while State.running and State.fastPunch and State.fastPunchGeneration == generation do
			pcall(function()
				local punch = not State.fastPunchToolPaused and getPunch() or nil
				local attackTime = punch and punch:FindFirstChild("attackTime")
				if attackTime then attackTime.Value = 0 end
			end)
			task.wait(0.05)
		end
	end)
	startThread("fastPunchHit", function()
		local lastVisual = 0
		while State.running and State.fastPunch and State.fastPunchGeneration == generation do
			if not activeRockFarm then
				local event = LP:FindFirstChild("muscleEvent")
				local punch = not State.fastPunchToolPaused and getPunch() or nil
				if event and event:IsA("RemoteEvent") then
					pcall(event.FireServer, event, "punch", "rightHand")
					pcall(event.FireServer, event, "punch", "leftHand")
				end
				if punch and time() - lastVisual >= 0.12 then
					lastVisual = time()
					pcall(punch.Activate, punch)
					State.playFastPunchVisual()
				end
			end
			task.wait(0.01)
		end
	end)
end

local repTimeOriginals = {}

do
	local movement = State.exerciseMovement
	movement.toolKinds = {
		["weight"] = "Weight",
		["heavy weight"] = "Weight",
		["handstand"] = "Handstands",
		["handstands"] = "Handstands",
		["pushup"] = "Pushups",
		["pushups"] = "Pushups",
		["situp"] = "Situps",
		["situps"] = "Situps",
	}
	movement.animationIds = {}

	movement.idsFor = function(kind)
		local cached = movement.animationIds[kind]
		if cached then return cached end
		cached = {}
		local shared = ReplicatedStorage:FindFirstChild("shared")
		local assets = shared and shared:FindFirstChild("assets")
		local animations = assets and assets:FindFirstChild("animations")
		local gameAnims = animations and animations:FindFirstChild("gameAnims")
		local tools = gameAnims and gameAnims:FindFirstChild("Tools")
		local folder = tools and tools:FindFirstChild(kind)
		if folder then
			for _, animation in ipairs(folder:GetDescendants()) do
				if animation:IsA("Animation") and animation.AnimationId ~= "" then
					cached[animation.AnimationId] = true
				end
			end
		end
		movement.animationIds[kind] = cached
		return cached
	end

	movement.stopTracks = function(humanoid, kind)
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		if not animator or not kind then return end
		local ids = movement.idsFor(kind)
		for _, animationTrack in ipairs(animator:GetPlayingAnimationTracks()) do
			local animation = animationTrack.Animation
			if animation and ids[animation.AnimationId] then
				animationTrack:Stop(0.03)
			end
		end
	end

	movement.bindHumanoid = function(humanoid)
		if movement.boundHumanoid == humanoid then return end
		if movement.animationConnection then
			movement.animationConnection:Disconnect()
			movement.animationConnection = nil
		end
		movement.boundHumanoid = humanoid
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		if animator then
			movement.animationConnection = animator.AnimationPlayed:Connect(function(animationTrack)
				local tool = movement.freeTool
				local kind = tool and tool.Parent and movement.toolKinds[tool.Name:lower()]
				local animation = animationTrack.Animation
				if kind and animation and movement.idsFor(kind)[animation.AnimationId] then
					animationTrack:Stop(0.03)
				end
			end)
		end
	end

	movement.freedomStep = function()
		if not State.running then return end
		local character = getCharacter()
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not character or not humanoid or not root then
			movement.bindHumanoid(nil)
			movement.freeTool = nil
			movement.cameraDistance = nil
			return
		end
		movement.bindHumanoid(humanoid)
		local tool = character:FindFirstChildWhichIsA("Tool")
		local kind = tool and movement.toolKinds[tool.Name:lower()]
		if not kind then
			movement.freeTool = nil
			movement.cameraDistance = nil
			return
		end
		local camera = workspace.CurrentCamera
		if movement.freeTool ~= tool then
			movement.freeTool = tool
			movement.freeWalkSpeed = humanoid.WalkSpeed > 0 and humanoid.WalkSpeed or 16
			movement.cameraDistance = camera and (camera.CFrame.Position - root.Position).Magnitude or 14
			movement.stopTracks(humanoid, kind)
		end
		if not State.machine and not State.fly then
			root.Anchored = false
			humanoid.PlatformStand = false
			humanoid.Sit = false
			humanoid.AutoRotate = true
			if humanoid.WalkSpeed <= 0 then
				humanoid.WalkSpeed = movement.freeWalkSpeed or 16
			end
		end
		if camera and not State.spy and not State.miscFreecam then
			if camera.CameraSubject ~= humanoid or camera.CameraType == Enum.CameraType.Scriptable then
				camera.CameraSubject = humanoid
				camera.CameraType = Enum.CameraType.Custom
			end
			local distance = (camera.CFrame.Position - root.Position).Magnitude
			local expected = math.clamp(tonumber(movement.cameraDistance) or 14, 6, 80)
			if distance > math.max(220, expected * 6) then
				local backwards = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
				backwards = backwards.Magnitude > 0.01 and backwards.Unit or Vector3.new(0, 0, -1)
				local offset = math.clamp(expected, 10, 34)
				camera.CFrame = CFrame.lookAt(
					root.Position - backwards * offset + Vector3.new(0, math.min(8, offset * 0.35), 0),
					root.Position + Vector3.new(0, 2, 0)
				)
			elseif distance >= 5 and distance <= 120 then
				movement.cameraDistance = distance
			end
		end
	end
	local bindName = "FG100_ExerciseFreedom"
	pcall(RunService.UnbindFromRenderStep, RunService, bindName)
	RunService:BindToRenderStep(bindName, Enum.RenderPriority.Camera.Value - 1, movement.freedomStep)
	addCleanup(function()
		pcall(RunService.UnbindFromRenderStep, RunService, bindName)
		movement.bindHumanoid(nil)
	end)
end


local function setFastRepTime(key, tool)
	if not tool then
		return
	end
	local repTime = tool:FindFirstChild("repTime")
	if not repTime or not repTime:IsA("ValueBase") then
		return
	end
	repTimeOriginals[key] = repTimeOriginals[key] or setmetatable({}, { __mode = "k" })
	if repTimeOriginals[key][repTime] == nil then
		repTimeOriginals[key][repTime] = repTime.Value
	end
	repTime.Value = 0
end


local function restoreRepTime(key)
	local saved = repTimeOriginals[key]
	if not saved then
		return
	end
	for repTime, original in pairs(saved) do
		if repTime and repTime.Parent then
			pcall(function()
				repTime.Value = original
			end)
		end
	end
	repTimeOriginals[key] = nil
end


local function unequipRepTools(tools)
	local character = getCharacter()
	local backpack = LP:FindFirstChild("Backpack")
	if not character or not backpack or not tools then
		return
	end
	local wanted = {}
	for _, name in ipairs(tools) do
		wanted[name:lower()] = true
	end
	for _, tool in ipairs(character:GetChildren()) do
		if tool:IsA("Tool") and wanted[tool.Name:lower()] then
			pcall(function()
				tool.Parent = backpack
			end)
		end
	end
end


local function setAutoRep(key, enabled, tools, interval, forceFast)
	State[key] = enabled == true
	local movement = State.exerciseMovement
	movement.active[key] = State[key] or nil
	local threadKey = "rep_" .. key
	if not State[key] then
		stopThread(threadKey)
		restoreRepTime(key)
		unequipRepTools(tools)
		local hasActiveExercise = false
		for _ in pairs(movement.active) do
			hasActiveExercise = true
			break
		end
		if not hasActiveExercise then
			stopThread("exerciseMovement")
			local humanoid = movement.humanoid
			if humanoid and humanoid.Parent then
				pcall(function()
					if not State.fastSpeed and movement.walkSpeed then
						humanoid.WalkSpeed = movement.walkSpeed
					end
					if movement.jumpValue then
						if movement.usesJumpPower then
							humanoid.JumpPower = movement.jumpValue
						else
							humanoid.JumpHeight = movement.jumpValue
						end
					end
				end)
			end
			movement.humanoid = nil
			movement.walkSpeed = nil
			movement.jumpValue = nil
		end
		return
	end
	local humanoid = getHumanoid()
	if humanoid and movement.humanoid ~= humanoid then
		movement.humanoid = humanoid
		movement.walkSpeed = humanoid.WalkSpeed > 0 and humanoid.WalkSpeed or 16
		movement.usesJumpPower = humanoid.UseJumpPower
		movement.jumpValue = movement.usesJumpPower and humanoid.JumpPower or humanoid.JumpHeight
	end
	startThread("exerciseMovement", function()
		while State.running and next(movement.active) do
			local activeHumanoid = getHumanoid()
			local root = getRoot()
			if activeHumanoid then
				if movement.humanoid ~= activeHumanoid then
					movement.humanoid = activeHumanoid
					movement.walkSpeed = activeHumanoid.WalkSpeed > 0 and activeHumanoid.WalkSpeed or 16
					movement.usesJumpPower = activeHumanoid.UseJumpPower
					movement.jumpValue = movement.usesJumpPower and activeHumanoid.JumpPower or activeHumanoid.JumpHeight
				end
				if not State.machine and not State.fly then
					if root then
						root.Anchored = false
					end
					activeHumanoid.PlatformStand = false
					activeHumanoid.Sit = false
					local wantedSpeed = State.fastSpeed and 1000 or movement.walkSpeed
					if wantedSpeed and activeHumanoid.WalkSpeed < wantedSpeed then
						activeHumanoid.WalkSpeed = wantedSpeed
					end
					if movement.jumpValue then
						if movement.usesJumpPower and activeHumanoid.JumpPower < movement.jumpValue then
							activeHumanoid.JumpPower = movement.jumpValue
						elseif not movement.usesJumpPower and activeHumanoid.JumpHeight < movement.jumpValue then
							activeHumanoid.JumpHeight = movement.jumpValue
						end
					end
				end
			end
			RunService.Heartbeat:Wait()
		end
	end)
	startThread(threadKey, function()
		while State.running and State[key] do
			local repDelay = interval or 0.01
			pcall(function()
				local tool
				if tools and #tools > 0 then
					tool = equipTool(tools)
					if forceFast or State.autoFarmMode == "Fast Rep" or State.autoFarmMode == "Super Fast Rep" then
						setFastRepTime(key, tool)
					else
						restoreRepTime(key)
						local repTime = tool and tool:FindFirstChild("repTime", true)
						repDelay = math.max(0.02, tonumber(repTime and repTime.Value) or 1)
						local owned = LP:FindFirstChild("ownedGamepasses")
						if owned and owned:FindFirstChild("x2 Rep Time") then
							repDelay = repDelay * 0.02
						end
					end
				end
				local event = LP:FindFirstChild("muscleEvent")
				if event then
					if State.autoFarmMode == "Super Fast Rep" then
						for _ = 1, 10 do
							event:FireServer("rep")
						end
					else
						event:FireServer("rep")
					end
				end
			end)
			task.wait(repDelay)
		end
	end)
end


local function findProteinEgg()
	for _, container in ipairs({
		getCharacter(),
		LP:FindFirstChild("Backpack"),
	}) do
		if container then
			for _, egg in ipairs(container:GetChildren()) do
				if egg:IsA("Tool") and table.find(CONFIG.AutoEgg.Names, egg.Name)
					and egg:GetAttribute("Used") ~= true then
					return egg
				end
			end
		end
	end
	return nil
end


local function hasProteinEggBoost()
	local boostTimers = LP:FindFirstChild("boostTimersFolder")
	if not boostTimers then
		return false
	end
	for _, name in ipairs(CONFIG.AutoEgg.Names) do
		local timer = boostTimers:FindFirstChild(name)
		if timer and timer:IsA("ValueBase") and tonumber(timer.Value) and timer.Value > 0 then
			return true
		end
	end
	return false
end


local function hubNotify(text, duration)
	pcall(function()
		local message = tostring(text or "")
		if type(State.translateText) == "function" then message = State.translateText(message) end
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Young0x Hub",
			Text = message,
			Duration = tonumber(duration) or 4,
		})
	end)
end


local function countProteinEggs()
	local total = 0
	for _, container in ipairs({
		getCharacter(),
		LP:FindFirstChild("Backpack"),
		LP:FindFirstChild("consumablesFolder"),
	}) do
		if container then
			for _, egg in ipairs(container:GetChildren()) do
				if (egg:IsA("Tool") or egg:IsA("StringValue"))
					and table.find(CONFIG.AutoEgg.Names, egg.Name) then
					total = total + 1
				end
			end
		end
	end
	return total
end

State.eggBusy = false

State.eatProteinEgg = function(force)
	if not force and hasProteinEggBoost() then
		return true
	end
	if State.eggBusy then
		return false
	end

	local egg = findProteinEgg()
	local character = getCharacter()
	local muscleEvent = LP:FindFirstChild("muscleEvent")
	if not egg or not character or not muscleEvent or not muscleEvent:IsA("RemoteEvent") then
		return false
	end

	State.eggBusy = true
	local ok, consumed = pcall(function()
		local originalParent = egg.Parent
		local originalUsed = egg:GetAttribute("Used")
		local beforeCount = countProteinEggs()
		local hadBoost = hasProteinEggBoost()

		local function confirmed()
			return not egg.Parent or countProteinEggs() < beforeCount
				or (not hadBoost and hasProteinEggBoost())
		end

		if egg.Parent ~= character then
			egg.Parent = character
			task.wait(0.2)
		end

		if confirmed() then
			return true
		end

		egg:SetAttribute("Used", true)
		muscleEvent:FireServer("proteinEgg", egg)
		local deadline = time() + 3
		while time() < deadline do
			if confirmed() then
				return true
			end
			task.wait(0.1)
		end

		if egg.Parent then egg:SetAttribute("Used", originalUsed) end
		if egg.Parent == character and originalParent and originalParent.Parent then
			egg.Parent = originalParent
		end
		return false
	end)
	State.eggBusy = false
	return ok and consumed == true
end

do

local function parseBoostTime(text)
	text = tostring(text or "")
	local hours = tonumber(text:match("(%d+)%s*[hH]")) or 0
	local minutes = tonumber(text:match("(%d+)%s*[mM]")) or 0
	local seconds = tonumber(text:match("(%d+)%s*[sS]")) or 0
	local total = hours * 3600 + minutes * 60 + seconds
	return total > 0 and total or nil
end


local function visibleStrengthBoostRemaining()
	local boostTimers = LP:FindFirstChild("boostTimersFolder")
	if boostTimers then
		for _, name in ipairs(CONFIG.AutoEgg.Names) do
			local timer = boostTimers:FindFirstChild(name)
			local remaining = timer and tonumber(timer.Value)
			if remaining and remaining > 0 then
				return remaining
			end
		end
	end
	return 0
end

State.autoEggSources = { manual = false, fastFarm = false, rebirth = false }
State.autoEggNextAt = 0
State.autoEggImmediateRequested = false

State.setAutoEgg = function(enabled, source)
	source = source or "manual"
	local wasEnabled = State.autoEggSources[source] == true
	State.autoEggSources[source] = enabled == true
	if enabled == true and not wasEnabled then
		State.autoEggImmediateRequested = true
	end
	local desired = false
	for _, active in pairs(State.autoEggSources) do
		if active then
			desired = true
			break
		end
	end
	if State.autoEgg == desired then
		return
	end
	State.autoEgg = desired
	if not desired then
		State.autoEggImmediateRequested = false
		stopThread("autoEgg")
		return
	end
	startThread("autoEgg", function()
		while State.running and State.autoEgg do
			local now = time()
			if State.autoEggImmediateRequested then
				State.autoEggImmediateRequested = false
				if State.eatProteinEgg(false) then
					State.autoEggNextAt = now + CONFIG.AutoEgg.Interval
				else
					State.autoEggNextAt = now + 10
				end
			else
				local remaining = visibleStrengthBoostRemaining()
				if remaining > 0 then
					State.autoEggNextAt = math.max(State.autoEggNextAt, now + remaining)
				end
				if now >= State.autoEggNextAt then
					if State.eatProteinEgg(false) then
						State.autoEggNextAt = now + CONFIG.AutoEgg.Interval
					else
						State.autoEggNextAt = now + 10
					end
				end
			end
			task.wait(1)
		end
	end)
end
end


local function findNativeAutoLiftButton()
	local gameGui = PlayerGui:FindFirstChild("gameGui")
	local modernHud = gameGui and gameGui:FindFirstChild("hudNewMenu")
	local modernTop = modernHud and modernHud:FindFirstChild("Top")
	local modernButton = modernTop and modernTop:FindFirstChild("AutoLiftBtn")
	if modernButton and modernButton:IsA("GuiButton") then
		return modernButton
	end
	local frame = PlayerGui:FindFirstChild("autoLiftFrame", true)
	local button = frame and frame:FindFirstChild("autoLiftButton", true)
	if button and button:IsA("GuiButton") then
		return button
	end
	return nil
end


local function releaseNativeAutoLiftButton()
	local native = State.autoLiftNative
	if native.connection then
		pcall(function()
			native.connection:Disconnect()
		end)
		native.connection = nil
	end
	if native.visualConnection then
		pcall(function() native.visualConnection:Disconnect() end)
		native.visualConnection = nil
	end
	for _, connection in ipairs(native.disabledConnections) do
		pcall(function()
			connection:Enable()
		end)
	end
	table.clear(native.disabledConnections)
	if native.fallbackMarker then
		pcall(function()
			native.fallbackMarker:Destroy()
		end)
		native.fallbackMarker = nil
	end
	if State.autoLiftEditableImage then
		pcall(function() State.autoLiftEditableImage:Destroy() end)
		State.autoLiftEditableImage = nil
	end
	State.autoLiftEditableLoading = false
	native.button = nil
end


State.refreshNativeAutoLiftVisual = function()
	local button = State.autoLiftNative.button
	if not button or not button.Parent or button.Name ~= "AutoLiftBtn" then return end
	local enabled = LP:GetAttribute("AutoLiftEnabled") == true
	local stateLabel = button:FindFirstChild("InfoLabel")
	if stateLabel and stateLabel:IsA("TextLabel") then
		stateLabel.Text = enabled and "ON" or "OFF"
		stateLabel.TextColor3 = enabled and Color3.fromRGB(85, 255, 127) or Color3.fromRGB(255, 80, 80)
		stateLabel.TextStrokeColor3 = enabled and Color3.fromRGB(0, 85, 0) or Color3.fromRGB(85, 0, 0)
	end
	if button:IsA("ImageButton") then
		button.ImageColor3 = Color3.new(1, 1, 1)
		if not enabled then
			button.Image = "rbxassetid://129249781616384"
			return
		end
		local editable = State.autoLiftEditableImage
		local usable = editable and pcall(function() return editable.Size.X > 0 end)
		if not usable and not State.autoLiftEditableLoading then
			State.autoLiftEditableLoading = true
			local created, result = pcall(function()
				local image = game:GetService("AssetService"):CreateEditableImageAsync(
					Content.fromUri("rbxassetid://129249781616384")
				)
				local size = image.Size
				local pixels = image:ReadPixelsBuffer(Vector2.zero, size)
				for index = 0, size.X * size.Y - 1 do
					local offset = index * 4
					local red = buffer.readu8(pixels, offset)
					local green = buffer.readu8(pixels, offset + 1)
					local blue = buffer.readu8(pixels, offset + 2)
					local alpha = buffer.readu8(pixels, offset + 3)
					if alpha > 0 and red > 45 and red > green * 1.35 and red > blue * 1.18 then
						buffer.writeu8(pixels, offset, math.floor(red * 0.1))
						buffer.writeu8(pixels, offset + 1, red)
						buffer.writeu8(pixels, offset + 2, math.floor(red * 0.33))
					end
				end
				image:WritePixelsBuffer(Vector2.zero, size, pixels)
				return image
			end)
			State.autoLiftEditableLoading = false
			if created and result then
				State.autoLiftEditableImage = result
				State.autoLiftEditableError = nil
				editable = result
			else
				State.autoLiftEditableError = tostring(result)
			end
		end
		if editable then
			local applied = pcall(function()
				button.ImageContent = Content.fromObject(editable)
			end)
			if applied then return end
		end
		button.Image = "rbxassetid://129249781616384"
	end
end


local function bindNativeAutoLiftButton()
	local button = findNativeAutoLiftButton()
	if not button then
		return false
	end
	local native = State.autoLiftNative
	if native.button == button and native.connection and native.connection.Connected then
		return true
	end
	releaseNativeAutoLiftButton()
	native.button = button
	button.Active = true
	button.Selectable = true

	local isolated = false
	if type(getconnections) == "function" then
		for _, signal in ipairs({
			button.Activated,
			button.MouseButton1Click,
			button.MouseButton1Down,
			button.MouseButton1Up,
		}) do
			local ok, connections = pcall(getconnections, signal)
			if ok and type(connections) == "table" then
				for _, connection in ipairs(connections) do
					local disabled = pcall(function()
						connection:Disable()
					end)
					if disabled then
						table.insert(native.disabledConnections, connection)
						isolated = true
					end
				end
			end
		end
	end

	local owned = LP:FindFirstChild("ownedGamepasses")
	if owned and not owned:FindFirstChild("Auto Lift") then
		local marker = Instance.new("BoolValue")
		marker.Name = "Auto Lift"
		marker.Value = true
		marker:SetAttribute("Temp", not isolated)
		marker.Parent = owned
		native.fallbackMarker = marker
	end

	native.connection = button.Activated:Connect(function()
		if not State.running or not State.autoLiftUnlocked then
			return
		end
		LP:SetAttribute("AutoLiftEnabled", LP:GetAttribute("AutoLiftEnabled") ~= true)
	end)
	native.visualConnection = LP:GetAttributeChangedSignal("AutoLiftEnabled"):Connect(function()
		task.defer(State.refreshNativeAutoLiftVisual)
	end)
	State.refreshNativeAutoLiftVisual()
	return true
end


local function unlockNativeAutoLift()
	if State.autoLiftUnlocked then
		local bound = bindNativeAutoLiftButton()
		if bound then LP:SetAttribute("AutoLiftEnabled", true); task.defer(State.refreshNativeAutoLiftVisual) end
		return bound
	end
	if not bindNativeAutoLiftButton() then
		return false
	end
	State.autoLiftUnlocked = true
	LP:SetAttribute("AutoLiftEnabled", true)
	task.defer(State.refreshNativeAutoLiftVisual)
	return true
end

local hiddenFrames = setmetatable({}, { __mode = "k" })
local hideFramesConnections = {}
local hiddenDurabilityFrames = setmetatable({}, { __mode = "k" })
local durabilityFrameConnections = {}
local trainingFrameNames = {
	strengthframe = true,
	durabilityframe = true,
	agilityframe = true,
	fuerzaframe = true,
}


local function releaseHiddenObjects(objects)
	for object, entry in pairs(objects) do
		if entry.visibleConnection then
			entry.visibleConnection:Disconnect()
		end
		if entry.ancestryConnection then
			entry.ancestryConnection:Disconnect()
		end
		if object and object.Parent then
			pcall(function()
				object.Visible = entry.visible
			end)
		end
	end
	table.clear(objects)
end


local function keepObjectHidden(objects, object, isEnabled)
	if objects[object] ~= nil then
		return
	end
	local entry = { visible = object.Visible }
	objects[object] = entry
	entry.visibleConnection = object:GetPropertyChangedSignal("Visible"):Connect(function()
		if isEnabled() and object.Parent and object.Visible then
			object.Visible = false
		end
	end)
	entry.ancestryConnection = object.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			if entry.visibleConnection then
				entry.visibleConnection:Disconnect()
			end
			if entry.ancestryConnection then
				entry.ancestryConnection:Disconnect()
			end
			objects[object] = nil
		end
	end)
	object.Visible = false
end


local function hideDurabilityFrame(object)
	if object
		and object:IsA("GuiObject")
		and object.Name == "durabilityFrame"
		and hiddenDurabilityFrames[object] == nil then
		keepObjectHidden(hiddenDurabilityFrames, object, function()
			return State.running and State.hideDurability
		end)
	end
end


local function setHideDurability(enabled)
	State.hideDurability = enabled == true
	for _, connection in ipairs(durabilityFrameConnections) do
		connection:Disconnect()
	end
	table.clear(durabilityFrameConnections)

	if State.hideDurability then
		for _, object in ipairs(ReplicatedStorage:GetChildren()) do
			pcall(hideDurabilityFrame, object)
		end
		for _, object in ipairs(PlayerGui:GetDescendants()) do
			pcall(hideDurabilityFrame, object)
		end
		durabilityFrameConnections[#durabilityFrameConnections + 1] = ReplicatedStorage.ChildAdded:Connect(function(object)
			if State.hideDurability then
				task.defer(hideDurabilityFrame, object)
			end
		end)
		durabilityFrameConnections[#durabilityFrameConnections + 1] = PlayerGui.DescendantAdded:Connect(function(object)
			if State.hideDurability then
				task.defer(hideDurabilityFrame, object)
			end
		end)
	else
		releaseHiddenObjects(hiddenDurabilityFrames)
	end
end

do
	local durabilityBurstConnection = nil
	local durabilityBurstGeneration = 0
	local durabilityBurstLastAt = 0
	local durabilityBurstEchoing = false


	local function stopDurabilityBurst()
		durabilityBurstGeneration = durabilityBurstGeneration + 1
		if durabilityBurstConnection then
			durabilityBurstConnection:Disconnect()
			durabilityBurstConnection = nil
		end
	end


	local function startDurabilityBurst()
		stopDurabilityBurst()
		if type(firesignal) ~= "function" then
			return
		end
		local muscleEvent = LP:FindFirstChild("muscleEvent")
		if not muscleEvent or not muscleEvent:IsA("RemoteEvent") then
			return
		end
		local generation = durabilityBurstGeneration
		durabilityBurstConnection = muscleEvent.OnClientEvent:Connect(function(kind, amount)
			local controller = activeRockFarm
			local selectedRock = State.selectedRock
			local rockGeneration = State.rockGeneration
			if durabilityBurstEchoing
				or kind ~= "showDurability"
				or amount == nil
				or not State.running
				or not State.fastPunch
				or not selectedRock
				or not controller
				or not controller.enabled
				or controller.definition ~= selectedRock
				or not controller.lastRock
				or realNow() < (State.rockVisualReadyAt or math.huge) then
				return
			end
			if State.hideDurability then
				return
			end
			local now = time()
			if now - durabilityBurstLastAt < 0.28 then
				return
			end
			durabilityBurstLastAt = now
			for _, delay in ipairs({ 0.10, 0.24 }) do
				task.delay(delay, function()
					if generation ~= durabilityBurstGeneration
						or not State.running
						or not State.fastPunch
						or State.rockGeneration ~= rockGeneration
						or State.selectedRock ~= selectedRock
						or activeRockFarm ~= controller
						or not controller.enabled
						or State.hideDurability then
						return
					end
					durabilityBurstEchoing = true
					pcall(firesignal, muscleEvent.OnClientEvent, "showDurability", amount)
					durabilityBurstEchoing = false
				end)
			end
		end)
	end

	State.stopDurabilityBurst = stopDurabilityBurst
	startDurabilityBurst()
end


local function getTrainingUiAssets()
	local shared = ReplicatedStorage:FindFirstChild("shared")
	local assets = shared and shared:FindFirstChild("assets")
	return assets and assets:FindFirstChild("ui") or nil
end


local function hideFrame(object, expectedParent)
	if State.hideFrames
		and object
		and object.Parent == expectedParent
		and object:IsA("GuiObject")
		and trainingFrameNames[tostring(object.Name or ""):lower()]
		and hiddenFrames[object] == nil then
		keepObjectHidden(hiddenFrames, object, function()
			return State.running and State.hideFrames
		end)
	end
end


local function setHideFrames(enabled)
	State.hideFrames = enabled == true
	local showPopups = not State.hideFrames
	local changedPreference = LP:GetAttribute("ShowPopups") ~= showPopups
	pcall(LP.SetAttribute, LP, "ShowPopups", showPopups)
	if changedPreference and not State.shuttingDown then
		local events = ReplicatedStorage:FindFirstChild("rEvents")
		local remote = events and events:FindFirstChild("savePlayerSizeEvent")
		if remote and remote:IsA("RemoteEvent") then
			pcall(remote.FireServer, remote, "showPopupsOption")
		end
	end
	for _, connection in ipairs(hideFramesConnections) do
		connection:Disconnect()
	end
	table.clear(hideFramesConnections)

	if State.hideFrames then
		local watchedRoots = {}

		local function watchRoot(root)
			if not root or watchedRoots[root] then
				return
			end
			watchedRoots[root] = true
			for _, object in ipairs(root:GetChildren()) do
				pcall(hideFrame, object, root)
			end
			hideFramesConnections[#hideFramesConnections + 1] = root.ChildAdded:Connect(function(object)
				if State.running and State.hideFrames then
					task.defer(hideFrame, object, root)
				end
			end)
		end

		watchRoot(getTrainingUiAssets())
		watchRoot(PlayerGui:FindFirstChild("statEffectsGui"))
		hideFramesConnections[#hideFramesConnections + 1] = PlayerGui.ChildAdded:Connect(function(object)
			if State.running and State.hideFrames and object.Name == "statEffectsGui" then
				task.defer(watchRoot, object)
			end
		end)
	else
		releaseHiddenObjects(hiddenFrames)
	end
end

local machineGeneration = 0
local machineFunctions = nil
FastFarm.MachineVisuals = {
	humanoid = nil,
	tracks = {},
	activeType = nil,
	activeMachine = nil,
}

do
local machineVisuals = FastFarm.MachineVisuals

local function stopMachineAnimations(fadeTime)
	for _, bundle in pairs(machineVisuals.tracks) do
		for _, animationTrack in pairs(bundle) do
			if animationTrack and animationTrack.IsPlaying then
				pcall(animationTrack.Stop, animationTrack, fadeTime or 0.1)
			end
		end
	end
	machineVisuals.activeType = nil
	machineVisuals.activeMachine = nil
end


local function destroyMachineAnimationTracks()
	stopMachineAnimations(0)
	for _, bundle in pairs(machineVisuals.tracks) do
		for _, animationTrack in pairs(bundle) do
			if animationTrack then
				pcall(animationTrack.Destroy, animationTrack)
			end
		end
	end
	machineVisuals.tracks = {}
	machineVisuals.humanoid = nil
end


local function getMachineAnimationBundle(machine)
	local humanoid = getHumanoid()
	if not humanoid then return nil, nil end
	if machineVisuals.humanoid ~= humanoid then
		destroyMachineAnimationTracks()
		machineVisuals.humanoid = humanoid
	end
	local machineType = machine and machine:FindFirstChild("machineType")
	local typeName = machineType and tostring(machineType.Value) or nil
	if not typeName then return nil, nil end
	local bundle = machineVisuals.tracks[typeName]
	if bundle then return bundle, typeName end
	local machines = ReplicatedStorage.shared.assets.animations.gameAnims.Machines
	local folder = machines:FindFirstChild(typeName)
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not folder or not animator then return nil, typeName end
	bundle = {
		idle = animator:LoadAnimation(folder.idle),
		rep = animator:LoadAnimation(folder.rep),
	}
	bundle.idle.Looped = true
	bundle.rep.Looped = false
	machineVisuals.tracks[typeName] = bundle
	return bundle, typeName
end


local function playMachineIdle(machine)
	local bundle, machineType = getMachineAnimationBundle(machine)
	if not bundle or not bundle.idle then return false end
	if machineVisuals.activeType ~= machineType then
		stopMachineAnimations(0.08)
	end
	machineVisuals.activeType = machineType
	machineVisuals.activeMachine = machine
	if not bundle.idle.IsPlaying then
		pcall(bundle.idle.Play, bundle.idle, 0.1, 1, 1)
	end
	return bundle.idle.IsPlaying
end


local function playMachineRep(machine, speedOverride)
	local bundle = getMachineAnimationBundle(machine)
	if not bundle or not bundle.rep then return false end
	local speed = tonumber(speedOverride)
	if not speed then
		speed = 1
		local owned = LP:FindFirstChild("ownedGamepasses")
		if owned and owned:FindFirstChild("x2 Rep Time") then
			speed = 2
		end
	end
	speed = math.clamp(speed, 0.25, 8)
	pcall(bundle.rep.Play, bundle.rep, 0.04, 1, speed)
	pcall(bundle.rep.AdjustSpeed, bundle.rep, speed)
	return bundle.rep.IsPlaying
end

machineVisuals.stopAnimations = stopMachineAnimations
machineVisuals.destroyTracks = destroyMachineAnimationTracks
machineVisuals.playIdle = playMachineIdle
machineVisuals.playRep = playMachineRep
end
addCleanup(function()
	FastFarm.MachineVisuals.destroyTracks()
end)


local function machineIsActive(machine, seat, humanoid)
	if not machine or not seat then
		return false
	end
	if humanoid and humanoid.SeatPart == seat then
		return true
	end
	local machineInUse = LP:FindFirstChild("machineInUse")
	if machineInUse and machineInUse.Value == seat then
		return true
	end
	if tonumber(machine:GetAttribute("InUseUserId")) == LP.UserId then
		return true
	end
	local character = getCharacter()
	local standingMount = character and character:GetAttribute("MachineStandingMount") == true
	local scaleFrozen = character and character:GetAttribute("MachineScaleFrozen") == true
	return (standingMount or scaleFrozen)
		and FastFarm.acceptedMachine == machine
		and FastFarm.acceptedMachineSeat == seat
end


local function getMachineParts(definition)
	local folder = workspace:FindFirstChild("machinesFolder")
	if not folder or type(definition) ~= "table" then
		return nil, nil
	end

	local bestMachine, bestSeat, bestGain, bestRequirement, bestDistance = nil, nil, -math.huge, -1, math.huge
	local currentHumanoid = getHumanoid()
	local root = getRoot()
	local referencePosition = root and root.Position or (definition.fallback and definition.fallback.Position)
	local expectedPosition = definition.fallback and definition.fallback.Position
	local candidates = definition.instance and { definition.instance } or folder:GetChildren()
	for _, candidate in ipairs(candidates) do
		if candidate:IsA("Model") and candidate.Name == definition.object then
			local seat = candidate.PrimaryPart
			if not (seat and seat:IsA("Seat")) then
				seat = candidate:FindFirstChild("interactSeat", true)
			end
			local expectedDistance = seat and expectedPosition
				and (Vector3.new(seat.Position.X, 0, seat.Position.Z)
					- Vector3.new(expectedPosition.X, 0, expectedPosition.Z)).Magnitude or 0
			local candidateGain = candidate:FindFirstChild("strengthGain")
			local gainMatches = definition.strengthGain == nil
				or (candidateGain and tonumber(candidateGain.Value) == tonumber(definition.strengthGain))
			if seat and seat:IsA("Seat") and expectedDistance <= 1400 and gainMatches then
				if machineIsActive(candidate, seat, currentHumanoid) then
					return candidate, seat
				end
				local inUseUserId = tonumber(candidate:GetAttribute("InUseUserId"))
				local available = (seat.Occupant == nil or seat.Occupant == currentHumanoid)
					and (inUseUserId == nil or inUseUserId == LP.UserId)
				local requirement = 0
				local requirements = candidate:FindFirstChild("requirements")
				if available and requirements then
					for _, value in ipairs(requirements:GetChildren()) do
						if value:IsA("ValueBase") then
							local playerValue = getPlayerStat(LP, { value.Name })
							local needed = tonumber(value.Value) or 0
							if not playerValue or (tonumber(State.getFunctionalStatValue(playerValue)) or 0) < needed then
								available = false
								break
							end
							requirement = math.max(requirement, needed)
						end
					end
				end
				if available then
					local strengthGain = tonumber(candidateGain and candidateGain.Value) or 0
					local distance = referencePosition and (seat.Position - referencePosition).Magnitude or 0
					if strengthGain > bestGain
						or (strengthGain == bestGain and requirement > bestRequirement)
						or (strengthGain == bestGain and requirement == bestRequirement and distance < bestDistance) then
						bestMachine, bestSeat = candidate, seat
						bestGain, bestRequirement, bestDistance = strengthGain, requirement, distance
					end
				end
			end
		end
	end
	return bestMachine, bestSeat
end


local function machineTargetCFrame(machine, seat, fallback, humanoid, root)
	if seat and seat:IsA("BasePart") then
		local rootHalf = root and root.Size.Y * 0.5 or 1
		local seatHalf = seat.Size.Y * 0.5
		local hipAllowance = humanoid and math.max(0.15, humanoid.HipHeight * 0.12) or 0.25
		local lift = math.clamp(rootHalf + seatHalf + hipAllowance, 1.8, 3.3)
		return seat.CFrame * CFrame.new(0, lift, 0)
	end
	if machine then
		local ok, pivot = pcall(machine.GetPivot, machine)
		if ok then return pivot end
	end
	return fallback
end


FastFarm.SafeMachineLockCFrame = function(character, frame)
	local expectedY = character and tonumber(character:GetAttribute("MachineStandHrpY"))
	if frame and expectedY and frame.Position.Y < expectedY - 0.15 then
		frame = frame + Vector3.new(0, expectedY - frame.Position.Y, 0)
	end
	return frame
end


local function machineRepDelay(machine)
	local repTime = machine and machine:FindFirstChild("repTime", true)
	local attributeRepTime = machine and machine:GetAttribute("repTime")
	local delay = math.max(0.15, tonumber(attributeRepTime) or tonumber(repTime and repTime.Value) or 1)
	local owned = LP:FindFirstChild("ownedGamepasses")
	if owned and owned:FindFirstChild("x2 Rep Time") then
		delay = delay * 0.5
	end
	if not machineFunctions then
		pcall(function()
			local shared = ReplicatedStorage:FindFirstChild("shared")
			local modules = shared and shared:FindFirstChild("modules")
			local module = (modules and modules:FindFirstChild("GlobalFunctions"))
				or ReplicatedStorage:FindFirstChild("globalFunctions")
			if module and module:IsA("ModuleScript") then
				machineFunctions = require(module)
			end
		end)
	end
	if machineFunctions then
		local okUltimate, ultimate = pcall(machineFunctions.calculateUltimateRepTime, LP)
		if okUltimate then
			delay = delay * (1 - math.clamp(tonumber(ultimate) or 0, 0, 0.9))
		end
		local okPet, petBoost = pcall(machineFunctions.calculatePetRepTimeBoost, LP)
		if okPet then
			delay = delay * (1 - math.clamp(tonumber(petBoost) or 0, 0, 0.9))
		end
	end
	return math.max(0.12, delay + 0.025)
end


local function useMachine(definition, maximumAttempts, retryDelay)
	local root = getRoot()
	local humanoid = getHumanoid()
	if not root or not humanoid then return false end
	local machine, seat = getMachineParts(definition)
	if not machine or not seat or not seat:IsA("Seat") then
		return false
	end
	if machineIsActive(machine, seat, humanoid) then
		return true, machine, seat
	end
	local remote = ReplicatedStorage:FindFirstChild("rEvents")
		and ReplicatedStorage.rEvents:FindFirstChild("machineInteractRemote")
	if not remote or not remote:IsA("RemoteFunction") then
		return false
	end
	local attempts = math.max(1, tonumber(maximumAttempts) or 4)
	for attempt = 1, attempts do
		repeat
		if machineIsActive(machine, seat, humanoid) then
			return true, machine, seat
		end
		local targetCFrame = machineTargetCFrame(machine, seat, definition.fallback, humanoid, root)
		if not targetCFrame then return false end
		if seat.Occupant and seat.Occupant ~= humanoid then
			return false, machine, seat, "occupied"
		end
		root.Anchored = false
		local character = LP.Character
		if character then
			pcall(character.PivotTo, character, targetCFrame)
		end
		root.CFrame = targetCFrame
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		RunService.Heartbeat:Wait()
		task.wait(FastFarm.mode == "strength" and 0.02 or (attempt == 1 and 0.1 or 0.06))
		local invoked, accepted, rejectionReason = pcall(remote.InvokeServer, remote, "useMachine", seat)
		if FastFarm.mode == "rebirth" and FastFarm.currentCycle then
			local cycle = FastFarm.currentCycle
			cycle.machineAttempts = cycle.machineAttempts or {}
			if #cycle.machineAttempts < 20 then
				cycle.machineAttempts[#cycle.machineAttempts + 1] = {
					machine = machine.Name, accepted = invoked and accepted == true,
					reason = tostring(rejectionReason), at = os.clock() - cycle.startedAt,
				}
			end
		end
		if invoked and accepted == true then
			FastFarm.acceptedMachine = machine
			FastFarm.acceptedMachineSeat = seat
		elseif invoked and accepted == false then
			if attempt < attempts then
				local retryWait = tonumber(retryDelay) or 0.22
				task.wait(retryWait)
				break
			else
				return false, machine, seat, rejectionReason
			end
		elseif not invoked then
			return false, machine, seat, "invokeFailed"
		end
		local entryWait = FastFarm.MachineEntryWait or 2.3
		if FastFarm.mode == "strength" then
			entryWait = math.clamp(0.35 + math.max(0, getPing()) * 0.0015, 0.55, 1.4)
		end
		local deadline = time() + entryWait
		repeat
			if machineIsActive(machine, seat, humanoid) then
				return true, machine, seat
			end
			RunService.Heartbeat:Wait()
		until time() >= deadline
		machine, seat = getMachineParts(definition)
		if not machine or not seat then
			return false
		end
		until true
	end
	return machineIsActive(machine, seat, humanoid), machine, seat
end


local function leaveMachine()
	FastFarm.MachineVisuals.stopAnimations(0.1)
	FastFarm.acceptedMachine = nil
	FastFarm.acceptedMachineSeat = nil
	local remote = ReplicatedStorage:FindFirstChild("rEvents")
		and ReplicatedStorage.rEvents:FindFirstChild("machineInteractRemote")
	if remote and remote:IsA("RemoteFunction") then
		if State.shuttingDown then
			task.spawn(function()
				pcall(remote.InvokeServer, remote, "leaveMachine")
			end)
		else
			pcall(remote.InvokeServer, remote, "leaveMachine")
		end
	end
	local humanoid = getHumanoid()
	if humanoid and humanoid.SeatPart then
		humanoid.Sit = false
	end
end
setHideFrames(false)


function FastFarm.RegisterMachineToggle(definition, toggle)
	FastFarm.MachineToggleByDefinition[definition] = toggle
end


function FastFarm.SelectMachineToggle(activeToggle)
	if FastFarm.machineToggleSync then
		return
	end
	if FastFarm.StopFastModesForManualFarm then
		FastFarm.StopFastModesForManualFarm()
	end
	for _, toggle in ipairs(FastFarm.RepToggles or {}) do
		pcall(function()
			if toggle:Get() then
				toggle:Set(false)
			end
		end)
	end
	FastFarm.machineToggleSync = true
	for _, toggle in pairs(FastFarm.MachineToggleByDefinition) do
		if toggle ~= activeToggle and toggle.Get and toggle.Set then
			pcall(function()
				if toggle:Get() then
					toggle:Set(false)
				end
			end)
		end
	end
	FastFarm.machineToggleSync = false
end


function FastFarm.SwitchOffMachineToggle(definition)
	local toggle = FastFarm.MachineToggleByDefinition[definition]
	if toggle and toggle.Get and toggle:Get() then
		toggle:Set(false, true)
	end
end


local function setMachine(definition, enabled)
	local previous = State.machine
	machineGeneration = machineGeneration + 1
	local generation = machineGeneration
	stopThread("machine")
	if not enabled then
		State.machine = nil
		local humanoid = getHumanoid()
		local machineInUse = LP:FindFirstChild("machineInUse")
		local mounted = previous ~= nil
			or FastFarm.acceptedMachine ~= nil
			or (machineInUse and machineInUse.Value ~= nil)
			or (humanoid and humanoid.SeatPart ~= nil)
		if mounted then
			leaveMachine()
		else
			FastFarm.MachineVisuals.stopAnimations(0.1)
		end
		return
	end
	State.machine = definition
	FastFarm.lastMachineError = nil
	startThread("machine", function()
		local lastInteract = 0
		local lastRep = 0
		local mountDefinition = {}
		for key, value in pairs(definition) do mountDefinition[key] = value end
		local pinnedMachine = getMachineParts(definition)
		if pinnedMachine then mountDefinition.instance = pinnedMachine end
		if previous and previous ~= definition then
			leaveMachine()
			task.wait(0.15)
		end
		local machineReady, machine, seat, rejectionReason = useMachine(mountDefinition, 3, 0.35)
		if rejectionReason == "isKingMachine" then
			FastFarm.MachineVisuals.stopAnimations(0.1)
			FastFarm.lastMachineError = rejectionReason
			State.machine = nil
			FastFarm.SwitchOffMachineToggle(definition)
			return
		end
		lastInteract = time()
		while State.running and State.machine == definition and machineGeneration == generation do
			local humanoid = getHumanoid()
			if not machineReady or not machineIsActive(machine, seat, humanoid) then
				if FastFarm.MachineVisuals.activeMachine == machine then
					FastFarm.MachineVisuals.stopAnimations(0.1)
				end
				if time() - lastInteract >= 0.65 then
					lastInteract = time()
					machineReady, machine, seat, rejectionReason = useMachine(mountDefinition, 3, 0.35)
					if rejectionReason == "isKingMachine" then
						FastFarm.MachineVisuals.stopAnimations(0.1)
						FastFarm.lastMachineError = rejectionReason
						State.machine = nil
						FastFarm.SwitchOffMachineToggle(definition)
						return
					end
				end
				task.wait(0.03)
			else
				FastFarm.MachineVisuals.playIdle(machine, seat)
				local fastMode = (definition.fullTrain and State.fullTrainMode == "Fast Rep")
					or (definition.autoFarm and State.autoFarmMode == "Fast Rep")
				local superMode = (definition.autoFarm and State.autoFarmMode == "Super Fast Rep")
				local delay = superMode
					and math.max(0.015, tonumber(definition.repInterval) or 0.02)
					or (fastMode
					and math.max(0.02, tonumber(definition.repInterval) or 0.025)
					or machineRepDelay(machine))
				if time() - lastRep >= delay then
					local muscleEvent = LP:FindFirstChild("muscleEvent") or ReplicatedStorage:FindFirstChild("muscleEvent")
					if muscleEvent and muscleEvent:IsA("RemoteEvent") and machineIsActive(machine, seat, humanoid) then
						local sent = false
						if superMode then
							for _ = 1, 10 do
								sent = pcall(muscleEvent.FireServer, muscleEvent, "rep", seat) or sent
							end
						else
							sent = pcall(muscleEvent.FireServer, muscleEvent, "rep", seat)
						end
						if sent then
							lastRep = time()
							FastFarm.MachineVisuals.playRep(machine, (fastMode or superMode) and 8 or nil)
						end
					end
				end
				task.wait(superMode and 0.015 or (fastMode and 0.02 or 0.035))
			end
		end
	end)
end


function FastFarm.StopFastModesForManualFarm()
	local stoppedByToggle = false
	for _, toggle in ipairs({ FastFarm.StrengthToggle, FastFarm.RebirthToggle }) do
		if toggle and toggle.Get and toggle.Set and toggle:Get() then
			stoppedByToggle = true
			toggle:Set(false)
		end
	end
	if not stoppedByToggle and FastFarm.mode and FastFarm.Stop then
		FastFarm:Stop(true)
	end
end


function FastFarm.StopMachineForExercise()
	if FastFarm.machineToggleSync then
		return
	end
	local activeDefinition = State.machine
	FastFarm.machineToggleSync = true
	for _, toggle in pairs(FastFarm.MachineToggleByDefinition) do
		if toggle.Get and toggle.Set then
			pcall(function()
				if toggle:Get() then
					toggle:Set(false)
				end
			end)
		end
	end
	FastFarm.machineToggleSync = false
	if activeDefinition then
		setMachine(activeDefinition, false)
	end
end

do
	FastFarm.generation = 0
	FastFarm.warningAccepted = false
	FastFarm.mode = nil
	FastFarm.startedAt = nil
	FastFarm.sessionStartedAt = nil
	FastFarm.startStats = nil
	FastFarm.lockCFrame = nil
	FastFarm.lockCharacter = nil
	FastFarm.machine = nil
	FastFarm.machineSeat = nil
	FastFarm.machineDefinition = nil
	FastFarm.machineFailureCooldowns = {}
	FastFarm.lastMachineSelection = nil
	FastFarm.hideFramesOwned = false
	FastFarm.packCount = 0
	FastFarm.petSlotCapacity = 1
	FastFarm.requiredPackCount = 1
	FastFarm.strengthPack = nil
	FastFarm.strengthPackCount = 0
	FastFarm.strengthPackRepBoost = 0
	FastFarm.rebirthPack = nil
	FastFarm.rebirthPackCount = 0
	FastFarm.expectedRebirthDelta = 0
	FastFarm.cycleStrengthGain = 0
	FastFarm.lastTargetStrength = 0
	FastFarm.cycleCount = 0
	FastFarm.successfulRebirths = 0
	FastFarm.failedRebirths = 0
	FastFarm.validRebirthSamples = {}
	FastFarm.validStrengthSamples = {}
	FastFarm.lastSuccessfulRebirthAt = nil
	FastFarm.rebirthMeasurementStartedAt = nil
	FastFarm.nextRebirthRequestAt = nil
	FastFarm.lastStrengthSampleAt = nil
	FastFarm.lastStrengthSampleValue = nil
	FastFarm.lastRequiredStrength = 0
	FastFarm.lastRebirthAccepted = false
	FastFarm.lastError = nil
	FastFarm.cachedPing = 0
	FastFarm.pingCheckedAt = 0
	FastFarm.pingPaused = false
	FastFarm.resumeSamples = 0
	FastFarm.strengthBatch = CONFIG.FastFarm.StrengthStartBatch
	FastFarm.lastBatchAdjust = 0
	FastFarm.pingReducer = false
	FastFarm.sizeInvokeBusy = false
	FastFarm.lastSizeInvoke = 0
	FastFarm.sizeReleaseGeneration = 0
	FastFarm.frameReleaseGeneration = 0
	FastFarm.bootstrapAutoWeight = false
	FastFarm.nextMachineAcquireAt = 0


	function FastFarm:SetPingReducer(enabled)
		self.pingReducer = enabled == true
		self.resumeSamples = 0
		if self.pingReducer then
			self.strengthBatch = math.min(
				self.strengthBatch or CONFIG.FastFarm.StrengthStartBatch,
				CONFIG.FastFarm.StrengthStartBatch
			)
		end
		return self.pingReducer
	end


	local function readStat(names)
		local value = getPlayerStat(LP, names)
		return value and tonumber(State.getFunctionalStatValue(value)) or 0, value
	end


	local function readStats()
		local rebirths = readStat({ "Rebirths", "Rebirth" })
		local strength = readStat({ "Strength", "Fuerza" })
		local durability = readStat({ "Durability", "Resistencia" })
		return {
			rebirths = rebirths,
			strength = strength,
			durability = durability,
		}
	end


	local function farmEvents()
		return ReplicatedStorage:FindFirstChild("rEvents")
	end


	local function unequipAllPets()
		local events = farmEvents()
		local remote = events and events:FindFirstChild("equipPetEvent")
		local equippedPets = LP:FindFirstChild("equippedPets")
		if not remote or not equippedPets then
			return false
		end
		for _, slot in ipairs(equippedPets:GetChildren()) do
			local reference = slot:FindFirstChild("petReference")
			local pet = reference and reference:IsA("ObjectValue") and reference.Value
			if pet then
				pcall(remote.FireServer, remote, "unequipPet", pet)
			end
		end
		RunService.Heartbeat:Wait()
		local deadline = time() + 1.2
		repeat
			local remaining = 0
			for _, slot in ipairs(equippedPets:GetChildren()) do
				local reference = slot:FindFirstChild("petReference")
				if reference and reference:IsA("ObjectValue") and reference.Value then
					remaining = remaining + 1
				end
			end
			if remaining == 0 then return true end
			task.wait(0.04)
		until time() >= deadline
		return false
	end


	function FastFarm:GetPetSlotCapacity()
		local capacity = 2
		if LP.MembershipType == Enum.MembershipType.Premium then
			capacity = capacity + 1
		end
		local ownedGamepasses = LP:FindFirstChild("ownedGamepasses")
		if ownedGamepasses and ownedGamepasses:FindFirstChild("+2 Pet Slots") then
			capacity = capacity + 2
		end
		local petSlotAttribute = UltimateAttributes["+1 Pet Slot"] or "UltimatePetSlot"
		local ultimateSlots = LP:GetAttribute(petSlotAttribute)
		if typeof(ultimateSlots) == "number" then
			capacity = capacity + math.max(0, math.floor(ultimateSlots))
		end
		local industrialSlot = LP:GetAttribute("IndustrialPetSlot")
		if industrialSlot == true or industrialSlot == 1 then
			capacity = capacity + 1
		end
		local availableSlotObjects = 0
		local equippedPets = LP:FindFirstChild("equippedPets")
		if equippedPets then
			for _, slot in ipairs(equippedPets:GetChildren()) do
				if slot:IsA("ObjectValue") then
					availableSlotObjects = availableSlotObjects + 1
				end
			end
		end
		if availableSlotObjects > 0 then
			capacity = math.min(capacity, availableSlotObjects)
		end
		self.petSlotCapacity = math.clamp(capacity, 1, CONFIG.FastFarm.MaxPets)
		return self.petSlotCapacity
	end


	function FastFarm:CountOwnedPet(name)
		local count = 0
		local petsFolder = LP:FindFirstChild("petsFolder")
		if petsFolder then
			for _, folder in ipairs(petsFolder:GetChildren()) do
				if folder:IsA("Folder") then
					for _, pet in ipairs(folder:GetChildren()) do
						if pet:IsA("StringValue") and pet.Name == name then
							count = count + 1
						end
					end
				end
			end
		end
		return count
	end


	function FastFarm:GetPackCatalog(force)
		if not force and self.packCatalog and time() - (self.packCatalogAt or 0) < 30 then return self.packCatalog end
		local shared = ReplicatedStorage:FindFirstChild("shared")
		local runtime = shared and shared:FindFirstChild("runtime")
		local catalog = runtime and runtime:FindFirstChild("packPetPerks")
		local modules = shared and shared:FindFirstChild("modules")
		local module = modules and modules:FindFirstChild("GlobalFunctions")
		local ok, functions = pcall(function() return module and require(module) end)
		if not catalog or not ok or type(functions) ~= "table" then return self.packCatalog or {} end
		local result, owned = {}, {}
		local inventory = LP:FindFirstChild("petsFolder")
		for _, folder in ipairs(inventory and inventory:GetChildren() or {}) do
			for _, pet in ipairs(folder:GetChildren()) do
				if pet:IsA("StringValue") then owned[pet.Name] = (owned[pet.Name] or 0) + 1 end
			end
		end
		local sample = Instance.new("Folder")
		local equipped = Instance.new("Folder")
		equipped.Name, equipped.Parent = "equippedPets", sample
		local slot = Instance.new("ObjectValue")
		slot.Parent = equipped
		local reference = Instance.new("ObjectValue")
		reference.Name, reference.Parent = "petReference", slot
		for _, item in ipairs(catalog:GetChildren()) do
			local perks = item:FindFirstChild("perksFolder")
			local strength = perks and perks:FindFirstChild("strength")
			local entry = { name = item.Name, owned = owned[item.Name] or 0, ref = item,
				strength = strength and tonumber(strength.Value) or 0 }
			slot.Value, reference.Value = item, item
			for key, method in pairs({ repSpeed = "calculatePetRepTimeBoost",
				strengthBonus = "calculatePetStrengthGainMultiplier", rebirthBonus = "calculatePetRebirthGainMultiplier" }) do
				if type(functions[method]) == "function" then
					local calculated, value = pcall(functions[method], sample)
					if calculated and type(value) == "number" then entry[key] = value end
				end
			end
			result[#result + 1] = entry
		end
		sample:Destroy()
		table.sort(result, function(a, b) return a.name < b.name end)
		self.packCatalog, self.packCatalogAt = result, time()
		return result
	end


	function FastFarm:GetModes(force)
		local cap = self:GetPetSlotCapacity()
		local byName = {}
		for _, pet in ipairs(self:GetPackCatalog(force)) do byName[pet.name] = pet end
		local out = {}
		for key, pack in pairs(CONFIG.FastFarm.Packs) do
			local strength = 0
			for _, name in ipairs(pack.strength) do
				strength = strength + math.min(cap, tonumber(byName[name] and byName[name].owned) or 0)
			end
			local rebirth = math.min(cap, tonumber(byName[pack.rebirth] and byName[pack.rebirth].owned) or 0)
			out[key] = { key = key, label = pack.label, available = strength > 0 and rebirth > 0,
				strength = strength, rebirth = rebirth, pets = byName }
		end
		self.packModes = out
		return out
	end


	function FastFarm:LoadPack(force)
		local modes = self:GetModes(force)
		local mode = modes[self.packMode]
		if not mode or not mode.available then
			for _, fallbackMode in ipairs({ "chaos", "ultra" }) do
				if modes[fallbackMode] and modes[fallbackMode].available then
					self.packMode = fallbackMode
					mode = modes[fallbackMode]
					break
				end
			end
		end
		if not mode or not mode.available then
			self.strengthPack, self.rebirthPack = nil, nil
			self.strengthSetup, self.rebirthSetup = nil, nil
			self.strengthPackCount, self.rebirthPackCount = 0, 0
			self.strengthPackRepBoost, self.expectedRebirthDelta = 0, 0
			return false, false
		end
		local cap = self:GetPetSlotCapacity()
		local pack = CONFIG.FastFarm.Packs[self.packMode]
		local s = {}
		if self.packMode == "ultra" then
			local hound, omega = mode.pets[pack.strength[1]], mode.pets[pack.strength[2]]
			local hMax = math.min(cap, tonumber(hound and hound.owned) or 0)
			local oMax = math.min(cap, tonumber(omega and omega.owned) or 0)
			local bestH, bestO, bestScore, bestUsed = 0, 0, -1, 0
			for h = 0, hMax do
				for o = 0, math.min(oMax, cap - h) do
					local used = h + o
					if used > 0 then
						local base = h * (tonumber(hound.strength) or 0) + o * (tonumber(omega.strength) or 0)
						local bonus = h * (tonumber(hound.strengthBonus) or 0)
							+ o * (tonumber(omega.strengthBonus) or 0)
						local speed = h * (tonumber(hound.repSpeed) or 0) + o * (tonumber(omega.repSpeed) or 0)
						local score = base * (1 + bonus) / math.max(0.10, 1 - math.min(0.90, speed))
						if score > bestScore or (score == bestScore and used > bestUsed) then
							bestH, bestO, bestScore, bestUsed = h, o, score, used
						end
					end
				end
			end
			if bestH > 0 then s[#s + 1] = { name = hound.name, count = bestH, data = hound } end
			if bestO > 0 then s[#s + 1] = { name = omega.name, count = bestO, data = omega } end
		else
			local pet = mode.pets[pack.strength[1]]
			local count = math.min(cap, tonumber(pet and pet.owned) or 0)
			if count > 0 then s[1] = { name = pet.name, count = count, data = pet } end
		end
		local rPet = mode.pets[pack.rebirth]
		local rCount = math.min(cap, tonumber(rPet and rPet.owned) or 0)
		local r = rCount > 0 and { { name = rPet.name, count = rCount, data = rPet } } or {}
		local sCount, rep = 0, 0
		for _, part in ipairs(s) do
			sCount = sCount + part.count
			rep = rep + (tonumber(part.data.repSpeed) or 0) * part.count
		end
		self.strengthSetup, self.rebirthSetup = s, r
		self.strengthPack, self.rebirthPack = "s:" .. self.packMode, "r:" .. self.packMode
		self.strengthPackCount, self.rebirthPackCount = sCount, rCount
		self.strengthPackRepBoost = rep
		self.expectedRebirthDelta = math.max(1,
			math.floor((tonumber(rPet.rebirthBonus) or 0) * rCount + 0.5))
		return sCount > 0, rCount > 0
	end


	local function equipPetByName(name, requestedCount)
		local events = farmEvents()
		local remote = events and events:FindFirstChild("equipPetEvent")
		local petsFolder = LP:FindFirstChild("petsFolder")
		if not remote or not petsFolder then
			return 0
		end
		local pets = {}
		for _, folder in ipairs(petsFolder:GetChildren()) do
			if folder:IsA("Folder") then
				for _, pet in ipairs(folder:GetChildren()) do
					if pet.Name == name then
						pets[#pets + 1] = pet
					end
				end
			end
		end
		table.sort(pets, function(a, b)
			local momentumA = tonumber(a:GetAttribute("MomentumSeconds")) or 0
			local momentumB = tonumber(b:GetAttribute("MomentumSeconds")) or 0
			if momentumA ~= momentumB then
				return momentumA > momentumB
			end
			return a:GetFullName() < b:GetFullName()
		end)
		local target = math.min(requestedCount or FastFarm:GetPetSlotCapacity(), FastFarm:GetPetSlotCapacity(), #pets)
		FastFarm.requiredPackCount = math.max(1, target)
		if target < 1 then
			FastFarm.lastError = "No se encontró el pack " .. tostring(name)
			return 0
		end
		for index = 1, target do
			pcall(remote.FireServer, remote, "equipPet", pets[index])
		end
		RunService.Heartbeat:Wait()
		local equippedPets = LP:FindFirstChild("equippedPets")
		local deadline = time() + 1.4
		repeat
			local confirmed = 0
			if equippedPets then
				for _, slot in ipairs(equippedPets:GetChildren()) do
					local reference = slot:FindFirstChild("petReference")
					local pet = reference and reference:IsA("ObjectValue") and reference.Value
					if pet and pet.Name == name then confirmed = confirmed + 1 end
				end
			end
			if confirmed >= target then
				FastFarm.lastError = nil
				return confirmed
			end
			task.wait(0.04)
		until time() >= deadline
		FastFarm.lastError = "No se confirmó el equipamiento de " .. tostring(name)
		return 0
	end


	local function switchPetPack(name, requestedCount)
		local generation = FastFarm.generation
		local events = farmEvents()
		local remote = events and events:FindFirstChild("equipPetEvent")
		local petsFolder = LP:FindFirstChild("petsFolder")
		local equippedPets = LP:FindFirstChild("equippedPets")
		if not remote or not petsFolder or not equippedPets then
			return 0
		end

		local targets = {}
		FastFarm.packCache = FastFarm.packCache or {}
		local cached = FastFarm.packCache[name]
		local validCache = cached and time() - cached.at < 30
		if validCache then
			for _, pet in ipairs(cached.pets) do
				if not pet:IsDescendantOf(petsFolder) or pet.Name ~= name then validCache = false; break end
			end
		end
		if validCache then targets = cached.pets else
		for _, folder in ipairs(petsFolder:GetChildren()) do
			if folder:IsA("Folder") then
				for _, pet in ipairs(folder:GetChildren()) do
					if pet.Name == name then targets[#targets + 1] = pet end
				end
			end
		end
		FastFarm.packCache[name] = { at = time(), pets = targets }
		end
		table.sort(targets, function(a, b)
			local momentumA = tonumber(a:GetAttribute("MomentumSeconds")) or 0
			local momentumB = tonumber(b:GetAttribute("MomentumSeconds")) or 0
			if momentumA ~= momentumB then return momentumA > momentumB end
			return a:GetFullName() < b:GetFullName()
		end)
		local target = math.min(requestedCount or FastFarm:GetPetSlotCapacity(), FastFarm:GetPetSlotCapacity(), #targets)
		FastFarm.requiredPackCount = math.max(1, target)
		if target < 1 or #targets < target or FastFarm:GetPetSlotCapacity() < target then
			FastFarm.lastError = "No se encontró el pack " .. tostring(name)
			return 0
		end
		local selected = {}
		for index = 1, target do selected[targets[index]] = true end

		local function confirmedReferences()
			local found, occupied, seen = 0, 0, {}
			for _, slot in ipairs(equippedPets:GetChildren()) do
				local reference = slot:FindFirstChild("petReference")
				local pet = reference and reference:IsA("ObjectValue") and reference.Value
				if pet then
					occupied = occupied + 1
					if slot:IsA("ObjectValue") and slot.Value and selected[pet]
						and pet.Parent and not seen[pet] then
						seen[pet] = true
						found = found + 1
					end
				end
			end
			return found == target and occupied == target
		end

		local matching = 0
		local occupied = 0
		for _, slot in ipairs(equippedPets:GetChildren()) do
			local reference = slot:FindFirstChild("petReference")
			local pet = reference and reference:IsA("ObjectValue") and reference.Value
			if pet then
				occupied = occupied + 1
				if pet.Name == name then matching = matching + 1 end
			end
		end
		if matching == target and occupied == target and confirmedReferences() then
			FastFarm.confirmedPack = { name = name, references = selected, count = target }
			FastFarm.lastError = nil
			return matching
		end
		local network = FastFarm:GetRebirthNetwork()
		while os.clock() < (network.petNextSendAt or 0) do
			if not State.running or FastFarm.generation ~= generation then return 0 end
			task.wait(0.05)
		end
		if confirmedReferences() then
			FastFarm.confirmedPack = { name = name, references = selected, count = target }
			return target
		end
		network.petNextSendAt = os.clock() + math.max(0.4, (FastFarm.cachedPing or 0) / 500)

		for _, slot in ipairs(equippedPets:GetChildren()) do
			local reference = slot:FindFirstChild("petReference")
			local pet = reference and reference:IsA("ObjectValue") and reference.Value
			if pet then pcall(remote.FireServer, remote, "unequipPet", pet) end
		end
		for index = 1, target do
			pcall(remote.FireServer, remote, "equipPet", targets[index])
		end

		local deadline = time() + math.max(1.4, (FastFarm.cachedPing or 0) / 1000 * 4)
		repeat
			if not State.running or FastFarm.generation ~= generation then return 0 end
			local confirmed = 0
			for _, slot in ipairs(equippedPets:GetChildren()) do
				local reference = slot:FindFirstChild("petReference")
				local pet = reference and reference:IsA("ObjectValue") and reference.Value
				if pet and pet.Name == name then confirmed = confirmed + 1 end
			end
			if confirmed >= target and confirmedReferences() then
				FastFarm.confirmedPack = { name = name, references = selected, count = target }
				FastFarm.lastError = nil
				return confirmed
			end
			RunService.Heartbeat:Wait()
		until time() >= deadline
		FastFarm.lastError = "No se confirmó el equipamiento de " .. tostring(name)
		return 0
	end
	FastFarm.UnequipAllPets = unequipAllPets
	FastFarm.EquipPack = equipPetByName
	FastFarm.SwitchPack = switchPetPack


	local function equipSetup(setup, key)
		if type(setup) ~= "table" or #setup < 1 then return 0 end
		if #setup == 1 and not setup[1].pets then
			local count = switchPetPack(setup[1].name, setup[1].count)
			if count > 0 and FastFarm.confirmedPack then FastFarm.confirmedPack.name = key end
			return count
		end
		local generation = FastFarm.generation
		local events = farmEvents()
		local remote = events and events:FindFirstChild("equipPetEvent")
		local pets = LP:FindFirstChild("petsFolder")
		local equipped = LP:FindFirstChild("equippedPets")
		if not remote or not pets or not equipped then return 0 end
		local targets = {}
		for _, part in ipairs(setup) do
			local found = {}
			if part.pets then
				for _,pet in ipairs(part.pets) do if pet.Parent and pet.Name==part.name then found[#found+1]=pet end end
			else
			for _, folder in ipairs(pets:GetChildren()) do
				for _, pet in ipairs(folder:IsA("Folder") and folder:GetChildren() or {}) do
					if pet.Name == part.name then found[#found + 1] = pet end
				end
			end
			table.sort(found, function(a, b)
				local am = tonumber(a:GetAttribute("MomentumSeconds")) or 0
				local bm = tonumber(b:GetAttribute("MomentumSeconds")) or 0
				return am ~= bm and am > bm or (am == bm and a:GetFullName() < b:GetFullName())
			end)
			end
			if #found < part.count then return 0 end
			for i = 1, part.count do targets[#targets + 1] = found[i] end
		end
		if #targets < 1 or #targets > FastFarm:GetPetSlotCapacity() then return 0 end
		local selected = {}
		for _, pet in ipairs(targets) do selected[pet] = true end

		local function ready()
			local count, used, seen = 0, 0, {}
			for _, slot in ipairs(equipped:GetChildren()) do
				local ref = slot:FindFirstChild("petReference")
				local pet = ref and ref:IsA("ObjectValue") and ref.Value
				if pet then
					used = used + 1
					if slot:IsA("ObjectValue") and slot.Value and selected[pet] and pet.Parent and not seen[pet] then
						seen[pet], count = true, count + 1
					end
				end
			end
			return count == #targets and used == count
		end
		if not ready() then
			local net = FastFarm:GetRebirthNetwork()
			while os.clock() < (net.petNextSendAt or 0) do
				if not State.running or FastFarm.generation ~= generation then return 0 end
				task.wait(0.04)
			end
			net.petNextSendAt = os.clock() + math.max(0.4, (FastFarm.cachedPing or 0) / 500)
			for _, slot in ipairs(equipped:GetChildren()) do
				local ref = slot:FindFirstChild("petReference")
				local pet = ref and ref:IsA("ObjectValue") and ref.Value
				if pet then pcall(remote.FireServer, remote, "unequipPet", pet) end
			end
			for _, pet in ipairs(targets) do pcall(remote.FireServer, remote, "equipPet", pet) end
			local deadline = time() + math.max(1.4, (FastFarm.cachedPing or 0) / 250)
			repeat
				if not State.running or FastFarm.generation ~= generation then return 0 end
				if ready() then break end
				RunService.Heartbeat:Wait()
			until time() >= deadline
		end
		if not ready() then return 0 end
		FastFarm.confirmedPack = { name = key, references = selected, count = #targets }
		FastFarm.lastError = nil
		return #targets
	end
	FastFarm.EquipSetup = equipSetup


	local function fireReps(amount, machineSeat, allowFallback)
		local event = LP:FindFirstChild("muscleEvent")
		if not event then
			return false
		end
		local humanoid = getHumanoid()
		local machineReady = machineSeat and humanoid
			and machineIsActive(FastFarm.machine, machineSeat, humanoid)
		if not machineReady and not allowFallback then
			return false
		end
		for _ = 1, amount or CONFIG.FastFarm.RepsPerCycle do
			if machineReady then
				pcall(event.FireServer, event, "rep", machineSeat)
			else
				pcall(event.FireServer, event, "rep")
			end
		end
		if FastFarm.currentCycle and FastFarm.mode == "rebirth" then
			FastFarm.currentCycle.reps = FastFarm.currentCycle.reps + (amount or CONFIG.FastFarm.RepsPerCycle)
		end
		return true
	end


	local function adaptiveRepDelay(mode, machineSeat)
		local now = time()
		local sampled = false
		if now - FastFarm.pingCheckedAt >= CONFIG.FastFarm.PingSampleInterval then
			FastFarm.cachedPing = getPing()
			FastFarm.pingCheckedAt = now
			sampled = true
		end
		local ping = FastFarm.cachedPing
		if mode == "rebirth" then
			local cycle = FastFarm.currentCycle
			if ping <= 0 then FastFarm.repBlockedReason = "ping_pending"; return 0.2, false end
			if not FastFarm.rebirthIdlePing or FastFarm.rebirthIdlePing <= 0 then
				FastFarm.rebirthIdlePing = ping
			end
			local baseline = FastFarm.rebirthIdlePing
			local pauseAt = CONFIG.FastFarm.RebirthPingPause
			local resumeAt = math.max(0, pauseAt - 150)
			if cycle then cycle.maxPing = math.max(cycle.maxPing, ping) end
			if ping >= pauseAt then FastFarm.pingPaused = true end
			if FastFarm.pingPaused then
				if sampled then
					if ping > 0 and ping <= resumeAt then
						FastFarm.resumeSamples = FastFarm.resumeSamples + 1
					else
						FastFarm.resumeSamples = 0
					end
				end
				if FastFarm.resumeSamples < 3 then FastFarm.repBlockedReason = "ping"; return 0.25, false end
				FastFarm.pingPaused, FastFarm.resumeSamples = false, 0
				if cycle then cycle.lastGainAt = time() end
			end
			if not FastFarm:HasRebirthMachine() or not FastFarm:PackStillConfirmed(FastFarm.strengthPack) then
				FastFarm.repBlockedReason = "machine_or_pack"
				return 0.1, false
			end
			if (FastFarm.strengthPackRepBoost or 0) < 0.9 then
				FastFarm.repBlockedReason = nil
				fireReps(1, machineSeat, false)
				return machineRepDelay(FastFarm.machine), true
			end
			local amount = CONFIG.FastFarm.RebirthRepBatch
			local idle = cycle and time() - cycle.lastGainAt or 0
			if ping > baseline + CONFIG.FastFarm.RebirthPingRise or idle > 0.65 then amount = 1 end
			if idle > 1.25 then FastFarm.repBlockedReason = "no_progress"; return 0.2, false end
			FastFarm.repBlockedReason = nil
			fireReps(amount, machineSeat, false)
			return ping > baseline + 60 and 0.04 or 0.02, true
		end
		local reducerEnabled = FastFarm.pingReducer == true

		local function sendReps(amount)
			return fireReps(amount, machineSeat, mode == "rebirth")
		end
		local pauseAt = reducerEnabled and CONFIG.FastFarm.PingReducerPause or CONFIG.FastFarm.PingPause
		local resumeAt = reducerEnabled and CONFIG.FastFarm.PingReducerResume or CONFIG.FastFarm.PingResume

		if mode ~= "rebirth" and mode ~= "strength" and not FastFarm.pingPaused and ping >= pauseAt then
			FastFarm.pingPaused = true
			FastFarm.resumeSamples = 0
			FastFarm.strengthBatch = CONFIG.FastFarm.StrengthMinBatch
			FastFarm.lastBatchAdjust = now
		end

		if mode ~= "rebirth" and mode ~= "strength" and FastFarm.pingPaused then
			if sampled then
				if ping <= resumeAt then
					FastFarm.resumeSamples = FastFarm.resumeSamples + 1
				else
					FastFarm.resumeSamples = 0
				end
				if FastFarm.resumeSamples >= 4 then
					FastFarm.pingPaused = false
					FastFarm.resumeSamples = 0
					if mode == "strength" then
						FastFarm.strengthBatch = math.max(
							FastFarm.strengthBatch,
							math.floor(CONFIG.FastFarm.StrengthStartBatch * 0.75)
						)
						FastFarm.lastBatchAdjust = now
					end
				end
			end
			if FastFarm.pingPaused then
				return 0.25, false
			end
		end
		if mode == "strength" then
			if sampled then
				if ping >= CONFIG.FastFarm.StrengthBackoffPing
					and now - FastFarm.lastBatchAdjust >= CONFIG.FastFarm.StrengthBackoffInterval then
					FastFarm.strengthBatch = math.max(
						CONFIG.FastFarm.StrengthMinBatch,
						FastFarm.strengthBatch - (reducerEnabled and 6 or 4)
					)
					FastFarm.lastBatchAdjust = now
				elseif ping <= CONFIG.FastFarm.StrengthRampPing
					and now - FastFarm.lastBatchAdjust >= CONFIG.FastFarm.StrengthRampInterval then
					FastFarm.strengthBatch = math.min(
						CONFIG.FastFarm.StrengthMaxBatch,
						FastFarm.strengthBatch + 2
					)
					FastFarm.lastBatchAdjust = now
				end
			end
			local repScale = 1
			local delayScale = 1
			local criticalAt = CONFIG.FastFarm.StrengthPingCritical

			local function scaledReps(amount, minimum)
				return math.max(minimum or 1, math.floor(amount * repScale))
			end
			if ping >= criticalAt then
				sendReps(1)
				return 0.25, true
			elseif ping >= CONFIG.FastFarm.StrengthPingHigh then
				sendReps(scaledReps(2))
				return 0.18 * delayScale, true
			elseif ping >= CONFIG.FastFarm.StrengthPingMedium then
				sendReps(scaledReps(FastFarm.strengthBatch * 0.18, 3))
				return 0.09 * delayScale, true
			elseif ping >= CONFIG.FastFarm.StrengthPingSoft then
				sendReps(scaledReps(FastFarm.strengthBatch * 0.35, 6))
				return 0.05 * delayScale, true
			end
			sendReps(scaledReps(FastFarm.strengthBatch * 0.6, 10))
			return CONFIG.FastFarm.StrengthDelay * delayScale, true
		end

		if ping >= CONFIG.FastFarm.PingCritical then
			sendReps(4)
			return 0.35, true
		elseif ping >= CONFIG.FastFarm.PingHigh then
			sendReps(10)
			return 0.18, true
		elseif ping >= CONFIG.FastFarm.PingMedium then
			sendReps(24)
			return 0.075, true
		elseif ping >= CONFIG.FastFarm.PingSoft then
			sendReps(36)
			return 0.025, true
		end
		sendReps(CONFIG.FastFarm.RepsPerCycle)
		return CONFIG.FastFarm.RepDelay, true
	end


	local function goldenRebirths()
		local attributeName = UltimateAttributes["Golden Rebirth"]
		local value = attributeName and LP:GetAttribute(attributeName)
		return typeof(value) == "number" and math.max(0, math.floor(value)) or 0
	end


	local function requiredStrength(rebirthValue)
		if not machineFunctions then
			pcall(function()
				local shared = ReplicatedStorage:FindFirstChild("shared")
				local modules = shared and shared:FindFirstChild("modules")
				local module = modules and modules:FindFirstChild("GlobalFunctions")
				if module and module:IsA("ModuleScript") then machineFunctions = require(module) end
			end)
		end
		if machineFunctions and type(machineFunctions.calculateRequiredRebirthStrength) == "function" then
			local ok, official = pcall(machineFunctions.calculateRequiredRebirthStrength, rebirthValue, LP)
			if ok and type(official) == "number" then return math.floor(official) end
		end
		local required = 10000 + 5000 * (tonumber(rebirthValue) or 0)
		local golden = goldenRebirths()
		if golden > 0 then required = required * math.max(0.1, 1 - golden * 0.1) end
		return math.floor(required)
	end


	local function requestRebirth()
		local events = farmEvents()
		local remote = events and events:FindFirstChild("rebirthRemote")
		if remote and remote:IsA("RemoteFunction") then
			local ok, accepted = pcall(remote.InvokeServer, remote, "rebirthRequest")
			return ok and accepted == true
		elseif remote and remote:IsA("RemoteEvent") then
			return pcall(remote.FireServer, remote, "rebirthRequest")
		end
		return false
	end
	FastFarm.GetRequiredRebirthStrength = requiredStrength
	FastFarm.RequestRebirth = requestRebirth


	local function waitForRebirthWindow(controller, generation, mode)
		while State.running and controller.mode == mode and controller.generation == generation do
			local deadline = controller.nextRebirthRequestAt
			if not deadline then return true end
			local remaining = deadline - os.clock()
			if remaining <= 0 then return true end
			if remaining > 0.12 then
				task.wait(math.min(remaining - 0.06, 0.2))
			else
				RunService.Heartbeat:Wait()
			end
		end
		return false
	end


	local function applyLocalSizeOne()
		local humanoid = getHumanoid()
		if not humanoid then
			return
		end
		for _, name in ipairs({
			"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale",
		}) do
			local scale = humanoid:FindFirstChild(name)
			if scale and scale:IsA("NumberValue") then
				pcall(function()
					scale.Value = 1
				end)
			end
		end
	end


	local function setSizeOne()
		applyLocalSizeOne()
		local now = time()
		if FastFarm.sizeInvokeBusy
			or now - FastFarm.lastSizeInvoke < CONFIG.FastFarm.SizeInvokeInterval then
			return
		end
		local events = farmEvents()
		local remote = events and events:FindFirstChild("changeSpeedSizeRemote")
		if remote then
			FastFarm.sizeInvokeBusy = true
			FastFarm.lastSizeInvoke = now
			task.spawn(function()
				pcall(remote.InvokeServer, remote, "changeSize", 1)
				FastFarm.sizeInvokeBusy = false
			end)
		end
	end
	FastFarm.SetSizeOne = setSizeOne


	local function holdSizeOne(seconds)
		FastFarm.sizeReleaseGeneration = FastFarm.sizeReleaseGeneration + 1
		local releaseGeneration = FastFarm.sizeReleaseGeneration
		task.spawn(function()
			local deadline = time() + (seconds or CONFIG.FastFarm.SizeReleaseDuration)
			while State.running and FastFarm.mode == nil
				and FastFarm.sizeReleaseGeneration == releaseGeneration and time() < deadline do
				setSizeOne()
				task.wait(0.1)
			end
		end)
	end


	local function minimumIndustrialStrength()
		local folder = workspace:FindFirstChild("machinesFolder")
		local minimum = math.huge
		for _, machine in ipairs(folder and folder:GetChildren() or {}) do
			if machine:IsA("Model") and string.find(machine.Name, "Industrial", 1, true) then
				local seat = machine.PrimaryPart
				if not (seat and seat:IsA("Seat")) then seat = machine:FindFirstChild("interactSeat", true) end
				local requirements = machine:FindFirstChild("requirements")
				local requirement = requirements and (requirements:FindFirstChild("Strength")
					or requirements:FindFirstChild("Fuerza"))
				if seat and seat:IsA("Seat") and requirement and requirement:IsA("ValueBase") then
					minimum = math.min(minimum, tonumber(requirement.Value) or math.huge)
				end
			end
		end
		return minimum < math.huge and math.max(0, minimum) or 0
	end
	FastFarm.GetMinimumIndustrialStrength = minimumIndustrialStrength

	FastFarm.NeedsBootstrap = function(strength)
		return (tonumber(strength) or 0) < minimumIndustrialStrength()
	end
	FastFarm.MachineEntryWait = 2.3
	FastFarm.MachineRetryDelay = 2.15


	function FastFarm:BootstrapToIndustrial(generation, mode)
		if mode == "rebirth" and self:HasRebirthMachine() then
			self.bootstrapAutoWeight = false
			return true
		end
		local minimum = minimumIndustrialStrength()
		local strength = readStat({ "Strength", "Fuerza" })
		if minimum <= 0 or strength >= minimum then
			self.bootstrapAutoWeight = false
			return true
		end
		self.bootstrapAutoWeight = true
		equipTool({ "Weight" })
		self.bootstrapTool = getCharacter() and getCharacter():FindFirstChild("Weight")
		local progressAt, previousStrength = time(), strength
		while State.running and self.generation == generation and self.mode == mode do
			strength = readStat({ "Strength", "Fuerza" })
			if strength >= minimum then break end
			if strength > previousStrength then progressAt, previousStrength = time(), strength end
			if time() - progressAt > 3 or not self.bootstrapTool or self.bootstrapTool.Parent ~= getCharacter() then
				self.lastError = "Weight temporal sin progreso"
				break
			end
			if mode == "rebirth" then
				if self.currentCycle then self.currentCycle.bootstrap = true end
				self.cachedPing = getPing()
				if self.cachedPing >= CONFIG.FastFarm.RebirthPingPause then break end
			end
			fireReps(mode == "rebirth" and 1 or 6, nil, true)
			task.wait(0.08)
		end
		self:CleanBootstrapTool()
		return self.generation == generation and self.mode == mode
			and readStat({ "Strength", "Fuerza" }) >= minimum
	end


	local function machineDefinition(objectName)
		for _, definition in ipairs(CONFIG.Machines) do
			if definition.object == objectName then
				return definition
			end
		end
		return nil
	end


	local function fastFarmMachineCandidates(primaryObject)
		local candidates = {}
		local seenDefinitions = {}

		local function add(definition)
			if not definition or seenDefinitions[definition] then return end
			seenDefinitions[definition] = true
			candidates[#candidates + 1] = definition
		end

		add(machineDefinition(primaryObject))
		for _, definition in ipairs(CONFIG.Machines) do
			if definition.section == "Industrial Machines" then add(definition) end
		end
		return candidates
	end
	FastFarm.GetMachineCandidates = fastFarmMachineCandidates


	local function acquireFastFarmMachine(generation, mode, primaryObject)
		local now = time()
		if now < (FastFarm.nextMachineAcquireAt or 0) then return false end
		FastFarm.nextMachineAcquireAt = now + 2.5
		for _, definition in ipairs(fastFarmMachineCandidates(primaryObject)) do
			if FastFarm.generation ~= generation or FastFarm.mode ~= mode then
				return false
			end
			local cooldownKey = definition.instance or definition
			local blockedUntil = FastFarm.machineFailureCooldowns[cooldownKey]
			if not blockedUntil or now >= blockedUntil then
				local ready, machine, seat, rejectionReason = useMachine(definition, 2)
				local humanoid = getHumanoid()
				if ready and machine and seat and machineIsActive(machine, seat, humanoid) then
					FastFarm.machine = machine
					FastFarm.machineSeat = seat
					FastFarm.machineDefinition = definition
					FastFarm.lastMachineSelection = definition.label or definition.object
					FastFarm.machineFailureCooldowns[cooldownKey] = nil
					FastFarm.nextMachineAcquireAt = 0
					if mode == "rebirth" then
						local root = getRoot()
						FastFarm.lockCharacter = getCharacter()
						FastFarm.lockCFrame = FastFarm.SafeMachineLockCFrame(FastFarm.lockCharacter, root and root.CFrame)
					end
					return true
				end
				if rejectionReason == "occupied" then
					FastFarm.machineFailureCooldowns[cooldownKey] = time() + 3
				else
					FastFarm.nextMachineAcquireAt = time() + 0.65
				end
				return false
			end
		end
		FastFarm.machine = nil
		FastFarm.machineSeat = nil
		FastFarm.machineDefinition = nil
		FastFarm.lastMachineSelection = nil
		return false
	end

	FastFarm.AcquireStrengthMachine = function(generation)
		return acquireFastFarmMachine(generation, "strength", CONFIG.FastFarm.StrengthMachine)
	end


	local function prepareLift(generation)
		return FastFarm:AcquireRebirthMachine(generation)
	end


	local function setFarmFrames(enabled)
		if FastFarm.HideFramesToggle then
			FastFarm.HideFramesToggle:Set(enabled)
		else
			setHideFrames(enabled)
		end
	end
	FastFarm.SetFarmFrames = setFarmFrames


	local function disableOtherFarmControls()
		for _, toggle in ipairs(FastFarm.RepToggles or {}) do
			toggle:Set(false)
		end
		for _, toggle in ipairs(FastFarm.MachineToggles or {}) do
			toggle:Set(false)
		end
		for _, toggle in ipairs(FastFarm.FullTrainToggles or {}) do
			toggle:Set(false)
		end
	end


	function FastFarm:ReadStats()
		return readStats()
	end


	function FastFarm:CalculateRebirthRate(samples)
		samples = samples or self.validRebirthSamples or {}
		if #samples < 3 then return nil, #samples end
		local durations = {}
		local deltas = {}
		for _, sample in ipairs(samples) do
			local duration = tonumber(sample.duration)
			local delta = tonumber(sample.delta)
			if duration and delta and duration >= 0.4 and duration <= 120 and delta >= 1 and delta <= 10000 then
				durations[#durations + 1] = duration
				deltas[#deltas + 1] = delta
			end
		end
		if #durations < 3 then return nil, #durations end
		local sortedDurations = table.clone(durations)
		local sortedDeltas = table.clone(deltas)
		table.sort(sortedDurations)
		table.sort(sortedDeltas)

		local function median(values)
			local count = #values
			local middle = math.floor((count + 1) * 0.5)
			return count % 2 == 0 and (values[middle] + values[middle + 1]) * 0.5 or values[middle]
		end
		local medianDuration = median(sortedDurations)
		local medianDelta = median(sortedDeltas)
		local totalDuration, totalDelta, accepted = 0, 0, 0
		for _, sample in ipairs(samples) do
			local duration = tonumber(sample.duration)
			local delta = tonumber(sample.delta)
			if duration and delta
				and duration >= math.max(0.4, medianDuration * 0.4)
				and duration <= math.min(120, medianDuration * 2.5)
				and delta >= math.max(1, medianDelta * 0.25)
				and delta <= math.min(10000, medianDelta * 4) then
				totalDuration = totalDuration + duration
				totalDelta = totalDelta + delta
				accepted = accepted + 1
			end
		end
		if accepted < 3 or totalDuration <= 0 then return nil, accepted end
		return totalDelta / totalDuration, accepted
	end


	function FastFarm:CalculateStrengthRate(samples)
		samples = samples or self.validStrengthSamples or {}
		if #samples < 3 then return nil, #samples end
		local durations = {}
		local deltas = {}
		for _, sample in ipairs(samples) do
			local duration = tonumber(sample.duration)
			local delta = tonumber(sample.delta)
			if duration and delta and duration >= 0.05 and duration <= 30 and delta > 0 then
				durations[#durations + 1] = duration
				deltas[#deltas + 1] = delta
			end
		end
		if #durations < 3 then return nil, #durations end
		local sortedDurations = table.clone(durations)
		local sortedDeltas = table.clone(deltas)
		table.sort(sortedDurations)
		table.sort(sortedDeltas)

		local function median(values)
			local count = #values
			local middle = math.floor((count + 1) * 0.5)
			return count % 2 == 0 and (values[middle] + values[middle + 1]) * 0.5 or values[middle]
		end
		local medianDuration = median(sortedDurations)
		local medianDelta = median(sortedDeltas)
		local totalDuration, totalDelta, accepted = 0, 0, 0
		for _, sample in ipairs(samples) do
			local duration = tonumber(sample.duration)
			local delta = tonumber(sample.delta)
			if duration and delta
				and duration >= math.max(0.05, medianDuration * 0.25)
				and duration <= math.min(30, medianDuration * 4)
				and delta >= math.max(1, medianDelta * 0.1)
				and delta <= medianDelta * 10 then
				totalDuration = totalDuration + duration
				totalDelta = totalDelta + delta
				accepted = accepted + 1
			end
		end
		if accepted < 3 or totalDuration <= 0 then return nil, accepted end
		return totalDelta / totalDuration, accepted
	end


	function FastFarm:FormatCompact(value)
		local number = tonumber(value) or 0
		local absolute = math.abs(number)
		local units = {
			{ 1e18, "QI" }, { 1e15, "QA" }, { 1e12, "T" },
			{ 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" },
		}
		for _, unit in ipairs(units) do
			if absolute >= unit[1] then
				local scaled = number / unit[1]
				local decimals = math.abs(scaled) >= 100 and 0 or (math.abs(scaled) >= 10 and 1 or 2)
				local compact = string.format("%." .. decimals .. "f", scaled)
				compact = compact:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
				return compact .. unit[2]
			end
		end
		return formatExact(number)
	end


	function FastFarm:FormatExactWithUnit(value)
		local number = tonumber(value) or 0
		local absolute = math.abs(number)
		local suffix = absolute >= 1e18 and "QI"
			or (absolute >= 1e15 and "QA")
			or (absolute >= 1e12 and "T")
			or (absolute >= 1e9 and "B")
			or (absolute >= 1e6 and "M")
			or (absolute >= 1e3 and "K")
			or ""
		return formatExact(number) .. suffix
	end


	function FastFarm:CleanBootstrapTool()
		local tool = self.bootstrapTool
		self.bootstrapTool, self.bootstrapAutoWeight = nil, false
		if tool and tool.Parent == getCharacter() and LP:FindFirstChild("Backpack") then
			tool.Parent = LP.Backpack
		end
	end


	function FastFarm:AcquireRebirthMachine(generation)
		if self:HasRebirthMachine() then return true end
		if time() < (self.nextMachineAcquireAt or 0) then return false end
		self.nextMachineAcquireAt = time() + 0.6
		local folder = workspace:FindFirstChild("machinesFolder")
		local candidates = {}
		for _, machine in ipairs(folder and folder:GetChildren() or {}) do
			if machine:IsA("Model") and machine.Name:find("Industrial", 1, true) and machine:FindFirstChild("strengthGain") then
				local definition = { object = machine.Name, instance = machine }
				local resolved, seat = getMachineParts(definition)
				if resolved and seat then candidates[#candidates + 1] = definition end
			end
		end
		table.sort(candidates, function(a, b)
			return a.instance.strengthGain.Value > b.instance.strengthGain.Value
		end)
		local definition
		for _, candidate in ipairs(candidates) do
			local blocked = self.machineFailureCooldowns[candidate.instance] or 0
			if time() >= blocked then definition = candidate; break end
		end
		if definition then
			local ready, machine, seat, reason = useMachine(definition, 3)
			if self.mode ~= "rebirth" or self.generation ~= generation then return false end
			if ready then
				self.machine, self.machineSeat, self.machineDefinition = machine, seat, definition
				self.machineCharacter = getCharacter()
				if self:HasRebirthMachine() then
					self.lastMachineSelection = machine.Name
					self.lockCharacter = getCharacter()
					local root = getRoot()
					self.lockCFrame = self.SafeMachineLockCFrame(self.lockCharacter, root and root.CFrame)
					self.lastError = nil
					return true
				end
			end
			if reason == "occupied" then
				self.machineFailureCooldowns[definition.instance] = time() + 3
				self.lastError = "Máquina ocupada; buscando otra disponible"
			else
				self.nextMachineAcquireAt = time() + 0.65
				self.lastError = "Confirmando " .. tostring(definition.instance and definition.instance.Name or definition.object)
			end
			return false
		end
		self.nextMachineAcquireAt = time() + 0.45
		self.lastError = "No hay máquina industrial disponible con los requisitos actuales"
		return false
	end


	function FastFarm:HasRebirthMachine()
		local machine, seat, humanoid = self.machine, self.machineSeat, getHumanoid()
		if not machine or not machine.Parent or not seat or not seat:IsDescendantOf(machine)
			or not humanoid or humanoid.Health <= 0 or self.machineCharacter ~= getCharacter() then return false end
		local serverSeat = LP:FindFirstChild("machineInUse")
		return (serverSeat and serverSeat.Value == seat)
			or (humanoid.SeatPart == seat and seat.Occupant == humanoid)
			or tonumber(machine:GetAttribute("InUseUserId")) == LP.UserId
	end


	function FastFarm:PackStillConfirmed(name)
		local pack, equipped = self.confirmedPack, LP:FindFirstChild("equippedPets")
		if not pack or pack.name ~= name or not equipped then return false end
		local count, occupied, seen = 0, 0, {}
		for _, slot in ipairs(equipped:GetChildren()) do
			local ref = slot:FindFirstChild("petReference")
			local pet = ref and ref:IsA("ObjectValue") and ref.Value
			if pet then
				occupied = occupied + 1
				if slot:IsA("ObjectValue") and slot.Value and pack.references[pet]
					and pet.Parent and not seen[pet] then
					seen[pet], count = true, count + 1
				end
			end
		end
		return count == pack.count and occupied == count
	end


	function FastFarm:GetRebirthNetwork()
		local network = Env.__FGRebirthNet
		if type(network) ~= "table" or network.player ~= LP then
			network = { player = LP }
			Env.__FGRebirthNet = network
		end
		return network
	end


	function FastFarm:RequestTrackedRebirth(generation)
		if self.generation ~= generation or self.mode ~= "rebirth" then return nil, "cancelled" end
		local network = self:GetRebirthNetwork()
		if network.pending and not network.pending.done then return nil, "pending" end
		local events = farmEvents()
		local remote = events and events:FindFirstChild("rebirthRemote")
		if not remote or not remote:IsA("RemoteFunction") then return nil, "remote_missing" end
		local operation = { requestedAt = os.clock(), done = false, oldRebirths = readStat({ "Rebirths", "Rebirth" }) }
		network.pending = operation
		task.spawn(function()
			local ok, accepted = pcall(remote.InvokeServer, remote, "rebirthRequest")
			operation.accepted, operation.done = ok and accepted == true, true
			operation.answeredAt = os.clock()
			if operation.accepted then
				network.nextRequestAt = operation.requestedAt
					+ CONFIG.FastFarm.RebirthCooldown + CONFIG.FastFarm.RebirthSafetyMargin
			end
		end)
		return operation
	end


	function FastFarm:FinishRebirthCycle(reason)
		for _, key in ipairs({ "strengthConnection", "rebirthConnection" }) do
			if self[key] then self[key]:Disconnect(); self[key] = nil end
		end
		local cycle = self.currentCycle
		if not cycle then return end
		cycle.elapsed, cycle.reason = os.clock() - cycle.startedAt, reason
		cycle.phase = self.phase
		cycle.lastGainAt = nil
		self.rebirthDiagnostics = self.rebirthDiagnostics or {}
		self.rebirthDiagnostics[#self.rebirthDiagnostics + 1] = cycle
		if #self.rebirthDiagnostics > 1024 then table.remove(self.rebirthDiagnostics, 1) end
		self.currentCycle = nil
	end


	function FastFarm:RunRebirthCycle(generation)
		local pending = self:GetRebirthNetwork().pending
		if pending and (not pending.done or (pending.accepted
			and readStat({ "Rebirths", "Rebirth" }) <= pending.oldRebirths)) then
			self.phase, self.lastError = "pending", "Esperando el rebirth anterior; no se duplican solicitudes"
			return false
		end
		local character = getCharacter()
		local rebirths, rebirthObject = readStat({ "Rebirths", "Rebirth" })
		local strength, strengthObject = readStat({ "Strength", "Fuerza" })
		if not character or not getHumanoid() or getHumanoid().Health <= 0
			or not strengthObject or not rebirthObject then
			self.lastError = "Esperando personaje y stats"
			return false
		end
		if self.machineCharacter and self.machineCharacter ~= character then
			self.lockCFrame, self.lockCharacter = nil, nil
			leaveMachine()
			self.machine, self.machineSeat, self.machineCharacter = nil, nil, nil
			self.nextMachineAcquireAt = 0
		end
		local required = requiredStrength(rebirths)
		local target = math.max(required + 1, math.ceil(required * (1 + CONFIG.FastFarm.RebirthStrengthBufferRatio)))
		self.lastRequiredStrength = required
		self.lastTargetStrength = target
		local cycle = {
			startedAt = self.lastSuccessfulRebirthAt or os.clock(), lastGainAt = time(), initialStrength = strength,
			confirmedAt = false,
			reps = 0, attempts = {}, recoveries = 0, maxPing = getPing(),
			machine = self.machine and self.machine.Name,
			startup = self.lastSuccessfulRebirthAt == nil, bootstrap = false, required = required, target = target,
		}
		self.currentCycle = cycle
		self.cycleCount = self.cycleCount + 1
		local previousStrength = strength

		local function observeStrength()
			local value = tonumber(State.getFunctionalStatValue(strengthObject)) or 0
			if value > previousStrength then
				cycle.firstGain = cycle.firstGain or os.clock() - cycle.startedAt
				cycle.lastGainAt = time()
				self.cycleStrengthGain = (self.cycleStrengthGain or 0) + value - previousStrength
			end
			previousStrength = value
			if value >= target then cycle.targetAt = cycle.targetAt or os.clock() - cycle.startedAt end
			return value
		end
		self.strengthConnection = strengthObject:GetPropertyChangedSignal("Value"):Connect(observeStrength)
		self.rebirthConnection = rebirthObject:GetPropertyChangedSignal("Value"):Connect(function()
			local value = tonumber(State.getFunctionalStatValue(rebirthObject)) or rebirths
			if value > rebirths and not cycle.confirmedAt then
				cycle.confirmedAt, cycle.delta = os.clock(), value - rebirths
			end
		end)

		local function alive()
			return State.running and self.mode == "rebirth" and self.generation == generation
				and getCharacter() == character and strengthObject.Parent and rebirthObject.Parent
				and getHumanoid() and getHumanoid().Health > 0
		end
		self.phase = "strength_pack"
		self.cycleStrengthGain = 0
		self.packCount = equipSetup(self.strengthSetup, self.strengthPack)
		if not alive() or self.packCount < 1 or not self:PackStillConfirmed(self.strengthPack) then return false end
		cycle.strengthPack, cycle.strengthPets = self.strengthPack, self.packCount
		cycle.strengthPackAt = os.clock() - cycle.startedAt
		while alive() and observeStrength() < target do
			if not self:PackStillConfirmed(self.strengthPack) then
				self.lastError = "Cambió el pack de fuerza"
				return false
			end
			if not self:HasRebirthMachine() then
				self.phase = "machine"
				self.lockCFrame, self.lockCharacter = nil, nil
				if not self:BootstrapToIndustrial(generation, "rebirth") then return false end
				if not alive() then return false end
				prepareLift(generation)
				self.machineCharacter = getCharacter()
				cycle.lastGainAt = time()
				cycle.machine = self.machine and self.machine.Name
				cycle.machineReadyAt = os.clock() - cycle.startedAt
			end
			if not alive() then return false end
			self.phase = "training"
			if not self.pingPaused and self:HasRebirthMachine() and time() - cycle.lastGainAt > 2.5 then
				cycle.recoveries = cycle.recoveries + 1
				self.lastError = "Máquina sin ganancia confirmada"
				self.lockCFrame, self.lockCharacter = nil, nil
				leaveMachine()
				self.machine, self.machineSeat, self.machineCharacter = nil, nil, nil
				cycle.lastGainAt = time()
				if cycle.recoveries >= 3 then return false end
			end
			local delay = adaptiveRepDelay("rebirth", self.machineSeat)
			task.wait(delay)
		end
		if not alive() then return false end
		cycle.strengthReadyAt = os.clock() - cycle.startedAt
		self.phase = "rebirth_pack"
		self.packCount = equipSetup(self.rebirthSetup, self.rebirthPack)
		if not alive() or self.packCount ~= self.rebirthPackCount
			or not self:PackStillConfirmed(self.rebirthPack) then return false end
		cycle.tribalPets, cycle.tribalConfirmed = self.packCount, true
		cycle.rebirthPack, cycle.expectedDelta = self.rebirthPack, self.expectedRebirthDelta
		cycle.tribalPackAt = os.clock() - cycle.startedAt
		local network = self:GetRebirthNetwork()
		for attempt = 1, 3 do
			self.phase = "cooldown"
			self.nextRebirthRequestAt = network.nextRequestAt or self.nextRebirthRequestAt
			if not waitForRebirthWindow(self, generation, "rebirth") or not alive() then return false end
			if not self:PackStillConfirmed(self.rebirthPack) then return false end
			cycle.strengthBefore = observeStrength()
			cycle.required = requiredStrength(readStat({ "Rebirths", "Rebirth" }))
			local currentTarget = math.max(cycle.required + 1,
				math.ceil(cycle.required * (1 + CONFIG.FastFarm.RebirthStrengthBufferRatio)))
			if cycle.strengthBefore < currentTarget then
				self.lastError = "Fuerza pendiente antes de renacer"
				return false
			end
			self.phase = "request"
			local operation, err = self:RequestTrackedRebirth(generation)
			if not operation then self.lastError = err; return false end
			cycle.attempts[#cycle.attempts + 1] = operation
			local deadline = os.clock() + math.max(3, getPing() / 1000 * 4)
			while alive() and not operation.done and os.clock() < deadline do RunService.Heartbeat:Wait() end
			if not alive() then return false end
			if not operation.done then self.lastError = "Rebirth pendiente del servidor"; return false end
			self.lastRebirthAccepted = operation.accepted
			self.phase = "confirmation"
			while alive() and operation.accepted and not cycle.confirmedAt and os.clock() < deadline do
				RunService.Heartbeat:Wait()
			end
			if cycle.confirmedAt then
				cycle.interval = self.lastSuccessfulRebirthAt and cycle.confirmedAt - self.lastSuccessfulRebirthAt or nil
				cycle.confirmationDelay = cycle.confirmedAt - operation.requestedAt
				if not self.sessionStartedAt then
					self.sessionStartedAt = cycle.confirmedAt
					self.startedAt = cycle.confirmedAt
				end
				self.lastSuccessfulRebirthAt = cycle.confirmedAt
				self.nextRebirthRequestAt = network.nextRequestAt
				self.successfulRebirths = self.successfulRebirths + 1
				self.validRebirthSamples[#self.validRebirthSamples + 1] = {
					at = cycle.confirmedAt, duration = cycle.interval or cycle.confirmedAt - cycle.startedAt, delta = cycle.delta,
				}
				if #self.validRebirthSamples > 9 then table.remove(self.validRebirthSamples, 1) end
				if cycle.delta < self.expectedRebirthDelta then
					self.lastError = "Rebirth confirmado con incremento menor a +"
						.. tostring(self.expectedRebirthDelta) .. ": +" .. tostring(cycle.delta)
					self:FinishRebirthCycle("unexpected_delta")
					self:Stop(true)
					return false
				end
				self.lastError = nil
				return true
			end
			self.failedRebirths = self.failedRebirths + 1
			self.lastError = operation.accepted and "Falta confirmación de Rebirths" or "Rebirth rechazado"
			task.wait(0.35 * attempt)
		end
		return false
	end


	function FastFarm:Stop(restoreFrames, preserveSession)
		self:FinishRebirthCycle("cancelled")
		self:CleanBootstrapTool()
		if self.strengthConnection then
			self.strengthConnection:Disconnect()
			self.strengthConnection = nil
		end
		local keepSizeOne = self.mode ~= nil
		self.generation = self.generation + 1
		self.mode = nil
		State.fastFarmMode = nil
		self.lockCFrame = nil
		self.lockCharacter = nil
		self.machine = nil
		self.machineSeat = nil
		self.machineDefinition = nil
		self.lastMachineSelection = nil
		self.bootstrapAutoWeight = false
		self.nextMachineAcquireAt = 0
		self.nextRebirthRequestAt = nil
		self.startedAt = nil
		self.startStats = nil
		if not preserveSession then self.sessionStartedAt = nil end
		if FastFarm.UpdateStrengthFramesControl then
			FastFarm.UpdateStrengthFramesControl(false)
		end
		for _, key in ipairs({
			"fastFarmSize", "fastFarmLock", "fastFarmMachine",
			"fastFarmRebirth", "fastFarmStrength", "fastFarmVisual",
		}) do
			stopThread(key)
		end
		if keepSizeOne then
			leaveMachine()
		end
		local humanoid = getHumanoid()
		if humanoid and humanoid.SeatPart then
			humanoid.Sit = false
		end
		if keepSizeOne then
			holdSizeOne(CONFIG.FastFarm.SizeReleaseDuration)
			State.setAutoEgg(false, "fastFarm")
		end
		if restoreFrames and self.hideFramesOwned then
			self.frameReleaseGeneration = self.frameReleaseGeneration + 1
			local releaseGeneration = self.frameReleaseGeneration
			task.delay(CONFIG.FastFarm.FramesReleaseDuration, function()
				if State.running and self.mode == nil
					and self.frameReleaseGeneration == releaseGeneration and self.hideFramesOwned then
					setFarmFrames(false)
					self.hideFramesOwned = false
				end
			end)
		end
	end


	function FastFarm:Start(mode)
		if mode ~= "rebirth" and mode ~= "strength" then
			return false
		end
		if self.mode == mode then
			return true
		end
		if mode == "rebirth" and (State.rebirth.autoTarget or State.rebirth.infinite
			or State.rebirth.fastWeight or State.rebirth.autoLift or State.autoWeight
			or LP:GetAttribute("AutoLiftEnabled") == true) then
			self.lastError = "Apagá los otros autos de entrenamiento y rebirth antes de Fast Rebirth"
			return false
		end
		self.packCache = {}
		local strengthAvailable, rebirthAvailable = self:LoadPack(true)
		if not strengthAvailable or self.strengthPackCount < 1 then
			self.lastError = "No se encontró un pack de fuerza compatible"
			return false
		end
		if mode == "rebirth" and (not rebirthAvailable or self.rebirthPackCount < 1
			or self.expectedRebirthDelta < 1) then
			self.lastError = "Fast Rebirth requiere al menos un pet con bonus de rebirth"
			return false
		end
		local previousSessionStartedAt = self.sessionStartedAt
		self:Stop(false, true)
		self.frameReleaseGeneration = self.frameReleaseGeneration + 1
		self.sizeReleaseGeneration = self.sizeReleaseGeneration + 1
		disableOtherFarmControls()
		self.mode = mode
		State.fastFarmMode = mode
		if mode == "rebirth" then
			self.sessionStartedAt = nil
		else
			self.sessionStartedAt = previousSessionStartedAt or os.clock()
		end
		self.generation = self.generation + 1
		local generation = self.generation
		self.startedAt = self.sessionStartedAt or os.clock()
		self.startStats = readStats()
		self.packCount = 0
		self:GetPetSlotCapacity()
		self.requiredPackCount = math.max(1, math.min(
			self.petSlotCapacity,
			mode == "rebirth" and math.min(self.strengthPackCount, self.rebirthPackCount)
				or self.strengthPackCount
		))
		self.cycleCount = 0
		self.successfulRebirths = 0
		self.failedRebirths = 0
		self.validRebirthSamples = {}
		self.validStrengthSamples = {}
		self.lastSuccessfulRebirthAt = nil
		self.rebirthMeasurementStartedAt = os.clock()
		self.nextRebirthRequestAt = nil
		self.lastStrengthSampleAt = realNow()
		self.lastStrengthSampleValue = self.startStats.strength
		self.lastRequiredStrength = 0
		self.lastTargetStrength = 0
		self.cycleStrengthGain = 0
		self.lastRebirthAccepted = false
		self.lastError = nil
		self.cachedPing = getPing()
		self.rebirthIdlePing = self.cachedPing
		self.machineCharacter = nil
		self.rebirthDiagnostics = {}
		self.pingCheckedAt = time()
		self.pingPaused = false
		self.resumeSamples = 0
		self.strengthBatch = CONFIG.FastFarm.StrengthStartBatch
		self.lastBatchAdjust = time()
		self.machineFailureCooldowns = {}
		self.bootstrapAutoWeight = false
		self.nextMachineAcquireAt = 0
		if not State.hideFrames then
			self.hideFramesOwned = true
		end
		setFarmFrames(true)
		if FastFarm.UpdateStrengthFramesControl then
			FastFarm.UpdateStrengthFramesControl(mode == "strength")
		end
		State.setAutoEgg(mode == "strength", "fastFarm")
		setSizeOne()
		startThread("fastFarmSize", function()
			while State.running and self.mode == mode and self.generation == generation do
				setSizeOne()
				task.wait(0.1)
			end
		end)
		startThread("fastFarmVisual", function()
			local lastVisualRep = 0
			while State.running and self.mode == mode and self.generation == generation do
				local machine = self.machine
				local seat = self.machineSeat
				local humanoid = getHumanoid()
				if machine and seat and machineIsActive(machine, seat, humanoid) then
					FastFarm.MachineVisuals.playIdle(machine)
					local visualDelay = machineRepDelay(machine)
					if time() - lastVisualRep >= visualDelay then
						if FastFarm.MachineVisuals.playRep(machine) then
							lastVisualRep = time()
						end
					end
				else
					if FastFarm.MachineVisuals.activeMachine then
						FastFarm.MachineVisuals.stopAnimations(0.1)
					end
					lastVisualRep = 0
				end
				task.wait(0.05)
			end
			FastFarm.MachineVisuals.stopAnimations(0.1)
		end)

		if mode == "rebirth" then
			startThread("fastFarmLock", function()
				while State.running and self.mode == mode and self.generation == generation do
					local character = getCharacter()
					local root = getRoot()
					if root and self.lockCFrame and self.lockCharacter == character then
						self.lockCFrame = self.SafeMachineLockCFrame(self.lockCharacter, self.lockCFrame) or self.lockCFrame
						root.CFrame = self.lockCFrame
						root.AssemblyLinearVelocity = Vector3.zero
						root.AssemblyAngularVelocity = Vector3.zero
					elseif root and character then
						local expectedY = tonumber(character:GetAttribute("MachineStandHrpY"))
						if expectedY and root.Position.Y < expectedY - 0.15 then
							root.CFrame = root.CFrame + Vector3.new(0, expectedY - root.Position.Y, 0)
							root.AssemblyLinearVelocity = Vector3.zero
							root.AssemblyAngularVelocity = Vector3.zero
						end
					end
					RunService.PreRender:Wait()
				end
			end)
			startThread("fastFarmRebirth", function()
				while State.running and self.mode == mode and self.generation == generation do
					local ok, success = pcall(self.RunRebirthCycle, self, generation)
					if not ok then self.lastError = tostring(success) end
					self:CleanBootstrapTool()
					self:FinishRebirthCycle(ok and success and "confirmed" or self.lastError or "interrupted")
					if self.mode ~= mode or self.generation ~= generation then break end
					if not ok or not success then task.wait(0.75) end
				end
			end)
		else
			startThread("fastFarmStrength", function()
				setSizeOne()
				task.wait(0.3)
				unequipAllPets()
				self.packCount = equipSetup(self.strengthSetup, self.strengthPack)
				local pendingStats = readStats()
				self.lastStrengthSampleAt = realNow()
				self.lastStrengthSampleValue = pendingStats.strength
				if self:BootstrapToIndustrial(generation, mode) then
					FastFarm.AcquireStrengthMachine(generation)
				end
				setSizeOne()
				local lastStartCheck = 0
				local lastMachineAttempt = time()
				local lastCharacter = getCharacter()
				local lastStrengthValue = pendingStats.strength
				local lastStrengthGainAt = time()
				while State.running and self.mode == mode and self.generation == generation do
					if lastCharacter ~= getCharacter() then
						lastCharacter = getCharacter()
						self.startedAt = nil
						self.startStats = nil
						self.machine = nil
						self.machineSeat = nil
						self.machineDefinition = nil
						setSizeOne()
						task.wait(0.3)
						unequipAllPets()
						self.packCount = equipSetup(self.strengthSetup, self.strengthPack)
						pendingStats = readStats()
						lastStrengthValue = pendingStats.strength
						lastStrengthGainAt = time()
						if self:BootstrapToIndustrial(generation, mode) then
							FastFarm.AcquireStrengthMachine(generation)
						end
						setSizeOne()
						lastMachineAttempt = time()
					end
					local humanoid = getHumanoid()
					local machineReady = self.machine and self.machineSeat
						and machineIsActive(self.machine, self.machineSeat, humanoid)
					local currentStats = readStats()
					if currentStats.strength > lastStrengthValue then
						local sampleAt = realNow()
						local sampleDuration = sampleAt - (self.lastStrengthSampleAt or sampleAt)
						local sampleDelta = currentStats.strength
							- (self.lastStrengthSampleValue or lastStrengthValue)
						if sampleDuration >= 0.05 and sampleDuration <= 30 and sampleDelta > 0 then
							self.validStrengthSamples[#self.validStrengthSamples + 1] = {
								at = sampleAt,
								duration = sampleDuration,
								delta = sampleDelta,
							}
							if #self.validStrengthSamples > 12 then table.remove(self.validStrengthSamples, 1) end
						end
						self.lastStrengthSampleAt = sampleAt
						self.lastStrengthSampleValue = currentStats.strength
						lastStrengthValue = currentStats.strength
						lastStrengthGainAt = time()
					elseif machineReady and time() - lastStrengthGainAt >= 6.5 then
						local failedDefinition = self.machineDefinition
						if failedDefinition then
							self.machineFailureCooldowns[failedDefinition.instance or failedDefinition] = time() + 10
						end
						leaveMachine()
						self.machine = nil
						self.machineSeat = nil
						self.machineDefinition = nil
						machineReady = false
						lastStrengthGainAt = time()
					end
					if not machineReady and time() - lastMachineAttempt >= 1.2 then
						if self.machine or self.machineSeat then
							leaveMachine()
							self.machine = nil
							self.machineSeat = nil
							self.machineDefinition = nil
						end
						setSizeOne()
						if self:BootstrapToIndustrial(generation, mode) then
							FastFarm.AcquireStrengthMachine(generation)
						end
						setSizeOne()
						lastMachineAttempt = time()
					end
					local delay = adaptiveRepDelay("strength", self.machineSeat)
					if not self.startedAt and time() - lastStartCheck >= 0.15 then
						lastStartCheck = time()
						if currentStats.strength > pendingStats.strength then
							self.startedAt = realNow()
							self.startStats = pendingStats
						end
					end
					task.wait(delay)
				end
			end)
		end
		return true
	end
end

FastFarm.PetMomentum = FastFarm.PetMomentum or {}
do
	local PetMomentum = FastFarm.PetMomentum
	PetMomentum.generation = 0
	PetMomentum.mode = nil
	PetMomentum.targetSeconds = 0
	PetMomentum.targetMultiplier = 50
	PetMomentum.startedAt = nil
	PetMomentum.originalCFrame = nil
	PetMomentum.treadmill = nil
	PetMomentum.treadmillPart = nil
	PetMomentum.lastError = nil
	PetMomentum.available = false
	PetMomentum.tiers = {}
	PetMomentum.attribute = "MomentumSeconds"
	PetMomentum.maxSeconds = 0
	PetMomentum.treadmillRemote = nil
	PetMomentum.usesPhysicalContact = true
	PetMomentum.distanceModeAvailable = false
	PetMomentum.hiddenAgilityFrames = setmetatable({}, { __mode = "k" })
	PetMomentum.agilityPopupConnection = nil


	function PetMomentum:SetAgilityPopupsHidden(hidden)
		if self.agilityPopupConnection then
			self.agilityPopupConnection:Disconnect()
			self.agilityPopupConnection = nil
		end
		if not hidden then
			for object, wasVisible in pairs(self.hiddenAgilityFrames) do
				if object and object.Parent and object:IsA("GuiObject") then object.Visible = wasVisible end
				self.hiddenAgilityFrames[object] = nil
			end
			return
		end
		local effectsGui = PlayerGui:FindFirstChild("statEffectsGui")
		if not effectsGui then return end

		local function hideFrame(object)
			if object:IsA("GuiObject") and object.Name:lower() == "agilityframe" then
				if self.hiddenAgilityFrames[object] == nil then self.hiddenAgilityFrames[object] = object.Visible end
				object.Visible = false
			end
		end
		for _, object in ipairs(effectsGui:GetDescendants()) do hideFrame(object) end
		self.agilityPopupConnection = effectsGui.DescendantAdded:Connect(function(object)
			if self.mode == "running" then task.defer(hideFrame, object) end
		end)
	end


	function PetMomentum:RefreshRealData()
		table.clear(self.tiers)
		local shared = ReplicatedStorage:FindFirstChild("shared")
		local configFolder = shared and shared:FindFirstChild("config")
		local modules = shared and shared:FindFirstChild("modules")
		local configModule = configFolder and configFolder:FindFirstChild("PetMomentumConfig")
		local momentumModule = modules and modules:FindFirstChild("PetMomentum")
		local okConfig, momentumConfig = pcall(function()
			return configModule and configModule:IsA("ModuleScript") and require(configModule)
		end)
		local okModule, momentumApi = pcall(function()
			return momentumModule and momentumModule:IsA("ModuleScript") and require(momentumModule)
		end)
		if not okConfig or type(momentumConfig) ~= "table"
			or not okModule or type(momentumApi) ~= "table" then
			self.available = false
			self.lastError = "Pet Momentum no está disponible en esta versión"
			return false
		end
		self.attribute = type(momentumConfig.ATTRIBUTE) == "string"
			and momentumConfig.ATTRIBUTE or "MomentumSeconds"
		for _, tier in ipairs(momentumConfig.TIERS or {}) do
			local seconds = tonumber(tier.Seconds)
			local multiplier = tonumber(tier.Multiplier)
			if seconds and multiplier then
				self.tiers[#self.tiers + 1] = {
					seconds = math.max(0, seconds),
					multiplier = multiplier,
				}
			end
		end
		table.sort(self.tiers, function(a, b) return a.seconds < b.seconds end)
		self.maxSeconds = tonumber(momentumApi.MaxSeconds)
			or (#self.tiers > 0 and self.tiers[#self.tiers].seconds) or 0
		self.available = #self.tiers > 0 and self.maxSeconds > 0
		if self.available then
			self.targetSeconds = self.maxSeconds
			self.targetMultiplier = self.tiers[#self.tiers].multiplier
			self.lastError = nil
		else
			self.lastError = "No se encontraron tiers reales"
		end
		return self.available
	end


	function PetMomentum:GetTierOptions()
		local options = {}
		for _, tier in ipairs(self.tiers) do
			if tier.seconds > 0 then
				local minutes = math.floor(tier.seconds / 60)
				options[#options + 1] = string.format("x%d • %dm", tier.multiplier, minutes)
			end
		end
		return options
	end


	function PetMomentum:SetTierByLabel(label)
		for _, tier in ipairs(self.tiers) do
			local option = string.format("x%d • %dm", tier.multiplier, math.floor(tier.seconds / 60))
			if option == label then
				self.targetSeconds = tier.seconds
				self.targetMultiplier = tier.multiplier
				return true
			end
		end
		return false
	end


	function PetMomentum:GetOccupiedTreadmills()
		local occupied = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LP then
				local inUse = player:FindFirstChild("treadmillInUse")
				if inUse and inUse:IsA("ObjectValue") and inUse.Value then
					occupied[inUse.Value] = true
				end
			end
		end
		return occupied
	end


	function PetMomentum:FindBestTreadmill(excluded)
		local folder = workspace:FindFirstChild("Treadmills")
		if not folder then
			return nil
		end
		excluded = excluded or {}
		local occupied = self:GetOccupiedTreadmills()
		local candidates = {}
		for _, treadmill in ipairs(folder:GetChildren()) do
			local part = treadmill:IsA("Model") and treadmill:FindFirstChild("treadmillPart")
			local amount = treadmill:IsA("Model") and treadmill:FindFirstChild("agilityAmount")
			local requirements = treadmill:IsA("Model") and treadmill:FindFirstChild("requirements")
			if not excluded[treadmill] and not occupied[treadmill]
				and part and part:IsA("BasePart") and amount and amount:IsA("IntValue") then
				local allowed = true
				if requirements and machineFunctions
					and type(machineFunctions.checkIfPlayerCanUseMachine) == "function" then
					local ok, result = pcall(machineFunctions.checkIfPlayerCanUseMachine, LP, requirements)
					allowed = ok and result == true
				elseif requirements then
					for _, requirement in ipairs(requirements:GetChildren()) do
						if requirement:IsA("ValueBase") then
							local stat = getPlayerStat(LP, { requirement.Name })
							local statValue = stat and tonumber(State.getFunctionalStatValue(stat))
							local requiredValue = tonumber(requirement.Value)
							if not statValue or not requiredValue or statValue < requiredValue then
								allowed = false
								break
							end
						end
					end
				end
					if allowed then
						local requiredAgility = requirements and requirements:FindFirstChild("Agility")
						candidates[#candidates + 1] = {
							model = treadmill,
							part = part,
							amount = tonumber(amount.Value) or 0,
							requirement = tonumber(requiredAgility and requiredAgility.Value) or 0,
						}
					end
			end
		end
		table.sort(candidates, function(a, b)
			if a.amount ~= b.amount then return a.amount > b.amount end
			return a.requirement > b.requirement
		end)
		return candidates[1]
	end


	function PetMomentum:GetEquippedPackPets()
		local pets = {}
		local equipped = LP:FindFirstChild("equippedPets")
		if equipped then
			for _, slot in ipairs(equipped:GetChildren()) do
				local reference = slot:FindFirstChild("petReference")
				local pet = reference and reference:IsA("ObjectValue") and reference.Value
				if not pet and slot:IsA("ObjectValue") then pet = slot.Value end
				if pet and pet:IsA("StringValue") and pet.Parent then
					pets[#pets + 1] = pet
				end
			end
		end
		return pets
	end


	function PetMomentum:GetProgress()
		local pets = self:GetEquippedPackPets()
		local values = {}
		for _, pet in ipairs(pets) do
			values[#values + 1] = tonumber(pet:GetAttribute(self.attribute)) or 0
		end
		return self:SummarizeSeconds(values)
	end


	function PetMomentum:MultiplierAt(seconds)
		local multiplier = 1
		for _, tier in ipairs(self.tiers) do
			if seconds >= tier.seconds then multiplier = tier.multiplier end
		end
		return multiplier
	end


    PetMomentum.progressText = {
        es = { remaining = "Hasta el máximo:", complete = "Máximo alcanzado", shortMax = "MÁXIMO", count = "%d/%d al máximo", durability = "Durabilidad", paused = "Punch apagado" },
        en = { remaining = "Until maximum:", complete = "Maximum reached", shortMax = "MAX", count = "%d/%d at max", durability = "Durability", paused = "Punch off" },
        pt = { remaining = "Até o máximo:", complete = "Máximo atingido", shortMax = "MÁXIMO", count = "%d/%d no máximo", durability = "Durabilidade", paused = "Punch desligado" },
        ar = { remaining = "حتى الحد الأقصى:", complete = "تم بلوغ الحد الأقصى", shortMax = "الحد الأقصى", count = "%d/%d عند الحد الأقصى", durability = "المتانة", paused = "اللكم متوقف" },
    }

    function PetMomentum:GetAuraMomentumBoost()
        local equipped = LP:FindFirstChild("equippedPowerUp")
        local aura = equipped and equipped:IsA("ObjectValue") and equipped.Value or nil
        local perks = aura and aura:FindFirstChild("perksFolder")
        local value = perks and perks:FindFirstChild("momentumGainPercent")
        local percent = math.max(0, tonumber(value and value.Value) or 0)
        return 1 + percent / 100, percent, aura
    end

    function PetMomentum:GetTierProgress(rawSeconds)
        local seconds = tonumber(rawSeconds) or 0
        if seconds ~= seconds or seconds == math.huge or seconds == -math.huge then seconds = 0 end
        local maximum = math.max(0, tonumber(self.maxSeconds) or 0)
        seconds = math.clamp(seconds, 0, maximum)
        local previous, nextTier = 0, nil
        for _, tier in ipairs(self.tiers) do
            if tier.seconds <= seconds then previous = tier.seconds else nextTier = tier; break end
        end
        if not nextTier and maximum > seconds then nextTier = { seconds = maximum, multiplier = self:MultiplierAt(maximum) } end
        local gainMultiplier, auraPercent = self:GetAuraMomentumBoost()
        return {
            seconds = seconds,
            elapsed = nextTier and math.max(0, seconds - previous) or 0,
            duration = nextTier and math.max(1, nextTier.seconds - previous) or 0,
            targetSeconds = nextTier and nextTier.seconds or maximum,
            multiplier = self:MultiplierAt(seconds),
            nextMultiplier = nextTier and nextTier.multiplier or nil,
            remaining = math.max(0, math.ceil((maximum - seconds) / gainMultiplier)),
            auraPercent = auraPercent,
            gainMultiplier = gainMultiplier,
            complete = maximum > 0 and seconds >= maximum,
            available = maximum > 0 and #self.tiers > 0,
        }
    end

    function PetMomentum:FormatTierProgress(seconds)
        local progress = self:GetTierProgress(seconds)
        if not progress.available then return "--" end
        local words = self.progressText[State.language] or self.progressText.es
        local first
        if progress.complete or not progress.nextMultiplier then
            first = "x" .. tostring(progress.multiplier) .. " · " .. words.complete
        else
            first = string.format("x%s → x%s · %02d:%02d / %02d:%02d",
                tostring(progress.multiplier), tostring(progress.nextMultiplier),
                math.floor(progress.elapsed / 60), math.floor(progress.elapsed) % 60,
                math.floor(progress.duration / 60), math.floor(progress.duration) % 60)
        end
        local left = progress.remaining
        return first .. "\n" .. words.remaining .. " " .. string.format("%02d:%02d:%02d",
            math.floor(left / 3600), math.floor(left / 60) % 60, math.floor(left) % 60)
    end

	function PetMomentum:SummarizeSeconds(values)
		local minimum = math.huge
		local maximum = 0
		local total = 0
		local completed = 0
		local minimumMultiplier = math.huge
		local maximumMultiplier = 1
		for _, rawSeconds in ipairs(values or {}) do
			local seconds = tonumber(rawSeconds) or 0
			seconds = math.clamp(seconds, 0, self.maxSeconds)
			minimum = math.min(minimum, seconds)
			maximum = math.max(maximum, seconds)
			total = total + seconds
			local multiplier = self:MultiplierAt(seconds)
			minimumMultiplier = math.min(minimumMultiplier, multiplier)
			maximumMultiplier = math.max(maximumMultiplier, multiplier)
			if seconds >= self.maxSeconds then completed = completed + 1 end
		end
		local count = #(values or {})
		if count == 0 then
			minimum = 0
			minimumMultiplier = 1
		end
		return {
			count = count,
			minimum = minimum,
			maximum = maximum,
			average = count > 0 and total / count or 0,
			minimumMultiplier = minimumMultiplier,
			maximumMultiplier = maximumMultiplier,
			completed = completed,
			complete = count > 0 and completed == count,
		}
	end


    function PetMomentum:GetTreadmillFacing(part, position)
        local model = self.treadmill and self.treadmill.model or part.Parent
        local menu = model and model:FindFirstChild("menuPart", true)
        local direction = menu and menu:IsA("BasePart") and (menu.Position - position) or -part.CFrame.LookVector
        local flat = Vector3.new(direction.X, 0, direction.Z)
        if flat.Magnitude < 0.05 then
            local look = part.CFrame.LookVector
            flat = Vector3.new(-look.X, 0, -look.Z)
        end
        return flat.Magnitude >= 0.05 and flat.Unit or Vector3.new(0, 0, 1)
    end

    function PetMomentum:TouchTreadmill()
        local root = getRoot()
        local part = self.treadmillPart
        if not root or not part or not part.Parent then return false end
        local inUse = LP:FindFirstChild("treadmillInUse")
        if inUse and inUse:IsA("ObjectValue") and self.treadmill and inUse.Value == self.treadmill.model then return true end
        local humanoid = getHumanoid()
        if humanoid and humanoid.SeatPart then humanoid.Sit = false; return false end
        if root.Anchored then return false end
        local character = LP.Character
        local connected, parts = pcall(root.GetConnectedParts, root, true)
        if not connected or not character then return false end
        for _, linked in ipairs(parts) do
            if linked ~= root and not linked:IsDescendantOf(character) then return false end
        end
        local height = part.Size.Y * 0.5 + (humanoid and humanoid.HipHeight or 2) + root.Size.Y * 0.5
        local target = part.CFrame:PointToWorldSpace(Vector3.new(0, height, 0))
        local facing = self:GetTreadmillFacing(part, target)
        local look = root.CFrame.LookVector
        local flat = Vector3.new(look.X, 0, look.Z)
        local aligned = flat.Magnitude >= 0.05 and flat.Unit:Dot(facing) >= 0.995 and root.CFrame.UpVector.Y >= 0.95
        if (root.Position - target).Magnitude > 0.6 or not aligned then
            local placed = pcall(function()
                root.CFrame = CFrame.lookAt(target, target + facing)
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end)
            if not placed then return false end
        end
        if type(firetouchinterest) == "function" then pcall(firetouchinterest, root, part, 0) end
        return true
    end

	function PetMomentum:Stop(restorePosition)
		local wasRunning = self.mode ~= nil
        if wasRunning and self.DisableLinkedDurability then self:DisableLinkedDurability() end
		self.generation = self.generation + 1
		self.mode = nil
		stopThread("petMomentumRun")
		self:SetAgilityPopupsHidden(false)
		local root = getRoot()
		if root and self.treadmillPart and self.treadmillPart.Parent
			and type(firetouchinterest) == "function" then
			pcall(firetouchinterest, root, self.treadmillPart, 1)
		end
		if restorePosition and root and self.originalCFrame then
			root.CFrame = self.originalCFrame
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
		self.startedAt = nil
		self.originalCFrame = nil
		self.treadmill = nil
		self.treadmillPart = nil
		if self.UpdateToggle then self.UpdateToggle(false) end
		return wasRunning
	end


	function PetMomentum:Complete()
		self:Stop(true)
		hubNotify("Pet Momentum completado: multiplicador máximo x" .. tostring(self.targetMultiplier), 5)
	end


	function PetMomentum:Start()
		if not self.available and not self:RefreshRealData() then return false end
		if self.mode then return true end
		local equippedProgress = self:GetProgress()
		if equippedProgress.count < 1 then
			self.lastError = "Equipá al menos una pet."
			return false
		end
		local selected = self:FindBestTreadmill()
		if not selected then
			self.lastError = "No hay una cinta accesible"
			return false
		end
		local root = getRoot()
		if not root then
			self.lastError = "Personaje no disponible"
			return false
		end
        FastFarm.StopFastModesForManualFarm()
        FastFarm.StopMachineForExercise()
        for _, toggle in ipairs(FastFarm.RepToggles or {}) do
            if toggle.Get and toggle.Set and toggle:Get() then toggle:Set(false) end
        end
        if State.stopKills and State.kill and (State.kill.auto or State.kill.autoWinBrawl or State.kill.targetMode or State.kill.karmaMode) then
            State.stopKills()
        end
		self.generation = self.generation + 1
		local generation = self.generation
		self.mode = "running"
        self.linkedPunchSuppressed = false
        self.linkedRockAuto = true
		self.startedAt = realNow()
		self.originalCFrame = root.CFrame
		self.treadmill = selected
		self.treadmillPart = selected.part
		self.lastError = nil
		self:SetAgilityPopupsHidden(true)
		self:TouchTreadmill()
        task.defer(function()
            if self.mode == "running" and self.generation == generation and self.EnableLinkedDurability then
                self:EnableLinkedDurability(true)
            end
        end)
		startThread("petMomentumRun", function()
			local lastTouch = 0
            local lastRockCheck = 0
			local acquisitionStarted = time()
			local excluded = {}
			while State.running and self.mode == "running" and self.generation == generation do
				local inUse = LP:FindFirstChild("treadmillInUse")
				local occupied = self:GetOccupiedTreadmills()
				local acquired = inUse and self.treadmill and inUse.Value == self.treadmill.model
				if self.treadmill and occupied[self.treadmill.model] then
					acquired = false
					acquisitionStarted = 0
				end
				if not acquired and time() - acquisitionStarted >= 3 then
					if self.treadmill then excluded[self.treadmill.model] = true end
					local replacement = self:FindBestTreadmill(excluded)
					if not replacement then
						self.lastError = "Todas las cintas accesibles están ocupadas"
						hubNotify(self.lastError)
						self:Stop(true)
						break
					end
					local rootNow = getRoot()
					if rootNow and self.treadmillPart and self.treadmillPart.Parent
						and type(firetouchinterest) == "function" then
						pcall(firetouchinterest, rootNow, self.treadmillPart, 1)
					end
					self.treadmill = replacement
					self.treadmillPart = replacement.part
					self.lastError = "Cinta ocupada; cambiando a " .. replacement.model.Name
					acquisitionStarted = time()
					lastTouch = 0
				end
				if not acquired or time() - lastTouch >= 1 then
					self:TouchTreadmill()
					lastTouch = time()
				end
				if acquired then
					acquisitionStarted = time()
					self.lastError = nil
				end
                if State.fastPunch and self.linkedRockAuto and time() - lastRockCheck >= 1 then
                    lastRockCheck = time()
                    self:EnableLinkedDurability(true)
                end
				local progress = self:GetProgress()
				if progress.count == 0 then
					self.lastError = "Equipá al menos una pet."
					self:Stop(true)
					break
				end
                if progress.complete then
                    self.allPetsMax = true
                else
                    self.allPetsMax = false
                end
				task.wait(0.5)
			end
		end)
		if self.UpdateToggle then self.UpdateToggle(true) end
		return true
	end

	PetMomentum:RefreshRealData()
	addCleanup(function()
		PetMomentum:Stop(true)
	end)
end

local antiLagOriginal = setmetatable({}, { __mode = "k" })
local antiLagAddedConnection = nil

local antiLagStatusUpdater = function() end
local originalLighting = nil
local originalQuality = nil


local function rememberProperty(object, property)
	antiLagOriginal[object] = antiLagOriginal[object] or {}
	if antiLagOriginal[object][property] == nil then
		local ok, value = pcall(function()
			return object[property]
		end)
		if ok then
			antiLagOriginal[object][property] = value
		end
	end
end


local function setOptimizedProperty(object, property, value)
	rememberProperty(object, property)
	pcall(function()
		object[property] = value
	end)
end


local function optimizeObject(object)
	if object:IsA("BasePart") then
		setOptimizedProperty(object, "Material", Enum.Material.SmoothPlastic)
		setOptimizedProperty(object, "Reflectance", 0)
		setOptimizedProperty(object, "CastShadow", false)
		if object:IsA("MeshPart") then
			setOptimizedProperty(object, "TextureID", "")
		end
	elseif object:IsA("Decal") or object:IsA("Texture") then
		setOptimizedProperty(object, "Transparency", 1)
	elseif object:IsA("SurfaceAppearance") then
		setOptimizedProperty(object, "ColorMap", "")
		setOptimizedProperty(object, "MetalnessMap", "")
		setOptimizedProperty(object, "NormalMap", "")
		setOptimizedProperty(object, "RoughnessMap", "")
	elseif object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam")
		or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") then
		setOptimizedProperty(object, "Enabled", false)
	elseif object:IsA("PointLight") or object:IsA("SpotLight") or object:IsA("SurfaceLight") then
		setOptimizedProperty(object, "Enabled", false)
	elseif object:IsA("Highlight") then
		setOptimizedProperty(object, "Enabled", false)
	elseif object:IsA("BloomEffect") or object:IsA("BlurEffect") or object:IsA("ColorCorrectionEffect")
		or object:IsA("DepthOfFieldEffect") or object:IsA("SunRaysEffect") then
		setOptimizedProperty(object, "Enabled", false)
	elseif object:IsA("Explosion") then
		setOptimizedProperty(object, "BlastPressure", 0)
		setOptimizedProperty(object, "BlastRadius", 0)
	end
end


local function restoreAntiLag(generation, allowYield)
	local restored = 0
	for object, properties in pairs(antiLagOriginal) do
		if State.antiLagGeneration ~= generation then
			return false
		end
		if object and object.Parent then
			for property, value in pairs(properties) do
				pcall(function()
					object[property] = value
				end)
			end
		end
		restored = restored + 1
		if allowYield and restored % 260 == 0 then
			RunService.Heartbeat:Wait()
		end
	end
	antiLagOriginal = setmetatable({}, { __mode = "k" })
	if originalLighting then
		Lighting.GlobalShadows = originalLighting.GlobalShadows
		Lighting.FogEnd = originalLighting.FogEnd
		Lighting.Brightness = originalLighting.Brightness
	end
	pcall(function()
		if originalQuality then
			settings().Rendering.QualityLevel = originalQuality
		end
	end)
	antiLagStatusUpdater("Desactivado")
	return true
end


local function setAntiLag(enabled, immediate)
	State.antiLag = enabled == true
	State.antiLagGeneration = State.antiLagGeneration + 1
	local generation = State.antiLagGeneration
	stopThread("antiLag")
	if antiLagAddedConnection then
		antiLagAddedConnection:Disconnect()
		antiLagAddedConnection = nil
	end
	if State.antiLag then
		antiLagStatusUpdater("Optimizando...")
		originalLighting = originalLighting or {
			GlobalShadows = Lighting.GlobalShadows,
			FogEnd = Lighting.FogEnd,
			Brightness = Lighting.Brightness,
		}
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 1000000000
		Lighting.Brightness = 0
		pcall(function()
			originalQuality = originalQuality or settings().Rendering.QualityLevel
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		end)
		local terrain = workspace:FindFirstChildOfClass("Terrain")
		if terrain then
			setOptimizedProperty(terrain, "WaterWaveSize", 0)
			setOptimizedProperty(terrain, "WaterWaveSpeed", 0)
			setOptimizedProperty(terrain, "WaterReflectance", 0)
			setOptimizedProperty(terrain, "WaterTransparency", 1)
		end
		antiLagAddedConnection = workspace.DescendantAdded:Connect(function(object)
			if State.antiLag then
				task.defer(function()
					pcall(optimizeObject, object)
				end)
			end
		end)
		startThread("antiLag", function()
			local queue = { workspace, Lighting }
			local head = 1
			local processed = 0
			while head <= #queue and State.running and State.antiLag and State.antiLagGeneration == generation do
				local parent = queue[head]
				head = head + 1
				local ok, children = pcall(function()
					return parent:GetChildren()
				end)
				if ok then
					for _, child in ipairs(children) do
						queue[#queue + 1] = child
						pcall(optimizeObject, child)
						processed = processed + 1
						if processed % 260 == 0 then
							RunService.Heartbeat:Wait()
						end
					end
				end
			end
			if State.antiLag and State.antiLagGeneration == generation then
				antiLagStatusUpdater("100% Optimizado")
			end
		end)
	else
		antiLagStatusUpdater("Restaurando...")
		if immediate then
			restoreAntiLag(generation, true)
		else
			startThread("antiLag", function()
				restoreAntiLag(generation, true)
			end)
		end
	end
end

local AntiCrash = {
	original = setmetatable({}, { __mode = "k" }),
	addedConnection = nil,
	heartbeatConnection = nil,
	recentEffects = {},
	shieldUntil = 0,
	stalls = 0,
	lastPruneAt = 0,
}


function AntiCrash.effectProperty(object)
	if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam")
		or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") then
		return "Enabled"
	end
	if object:IsA("Explosion") then
		return "Visible"
	end
	return nil
end


function AntiCrash.suppressEffect(object)
	local property = AntiCrash.effectProperty(object)
	if not property or AntiCrash.original[object] then
		return
	end
	local ok, value = pcall(function()
		return object[property]
	end)
	if not ok then
		return
	end
	AntiCrash.original[object] = { property = property, value = value }
	pcall(function()
		object[property] = false
	end)
end


function AntiCrash.pruneRecentEffects(now)
	local recent = AntiCrash.recentEffects
	local write = 1
	for read = 1, #recent do
		local entry = recent[read]
		if entry and now - entry.time <= 0.75 then
			recent[write] = entry
			write = write + 1
		end
	end
	for index = #recent, write, -1 do
		recent[index] = nil
	end
end


function AntiCrash.trackEffect(object, now)
	local recent = AntiCrash.recentEffects
	recent[#recent + 1] = { object = object, time = now }
	AntiCrash.pruneRecentEffects(now)
	if #recent > 96 then
		local first = #recent - 95
		local write = 1
		for read = first, #recent do
			recent[write] = recent[read]
			write = write + 1
		end
		for index = #recent, write, -1 do
			recent[index] = nil
		end
	end
	return #recent
end


function AntiCrash.suppressRecentEffects()
	for _, entry in ipairs(AntiCrash.recentEffects) do
		local object = entry.object
		if object and object.Parent then
			task.defer(AntiCrash.suppressEffect, object)
		end
	end
end


function AntiCrash.restore()
	if AntiCrash.addedConnection then
		AntiCrash.addedConnection:Disconnect()
		AntiCrash.addedConnection = nil
	end
	if AntiCrash.heartbeatConnection then
		AntiCrash.heartbeatConnection:Disconnect()
		AntiCrash.heartbeatConnection = nil
	end
	for object, saved in pairs(AntiCrash.original) do
		if object and object.Parent then
			pcall(function()
				object[saved.property] = saved.value
			end)
		end
	end
	AntiCrash.original = setmetatable({}, { __mode = "k" })
	table.clear(AntiCrash.recentEffects)
	AntiCrash.shieldUntil = 0
	AntiCrash.stalls = 0
	AntiCrash.lastPruneAt = 0
end


function AntiCrash.set(enabled)
	State.antiCrash = enabled == true
	AntiCrash.restore()
	if not State.antiCrash then
		return
	end

	AntiCrash.addedConnection = workspace.DescendantAdded:Connect(function(object)
		if not State.antiCrash or not AntiCrash.effectProperty(object) then
			return
		end
		local now = realNow()
		if now <= AntiCrash.shieldUntil then
			task.defer(AntiCrash.suppressEffect, object)
			return
		end
		local recentCount = AntiCrash.trackEffect(object, now)
		if recentCount >= 36 then
			AntiCrash.shieldUntil = math.max(AntiCrash.shieldUntil, now + 4)
			AntiCrash.suppressRecentEffects()
		end
		if now <= AntiCrash.shieldUntil then
			task.defer(AntiCrash.suppressEffect, object)
		end
	end)

	AntiCrash.heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
		if not State.antiCrash then
			return
		end
		local now = realNow()
		if now - AntiCrash.lastPruneAt >= 0.25 then
			AntiCrash.lastPruneAt = now
			AntiCrash.pruneRecentEffects(now)
		end
		if deltaTime >= 0.35 then
			AntiCrash.stalls = math.min(AntiCrash.stalls + 1, 4)
		elseif AntiCrash.stalls > 0 then
			AntiCrash.stalls = AntiCrash.stalls - 1
		end
		if AntiCrash.stalls >= 3 then
			AntiCrash.shieldUntil = math.max(AntiCrash.shieldUntil, now + 4)
			AntiCrash.suppressRecentEffects()
			AntiCrash.stalls = 0
		end
	end)
end


local function setWalkWater(enabled)
	State.walkWater = enabled == true
	if State.waterFloorConnection then
		State.waterFloorConnection:Disconnect()
		State.waterFloorConnection = nil
	end
	if State.waterFloor then
		State.waterFloor:Destroy()
		State.waterFloor = nil
	end
	if not State.walkWater then
		return true
	end

	State.waterFloor = Instance.new("Part")
	State.waterFloor.Name = "WaterFloor"
	State.waterFloor.Size = Vector3.new(2048, 1, 2048)
	State.waterFloor.Anchored = true
	State.waterFloor.CanCollide = true
	State.waterFloor.CanTouch = false
	State.waterFloor.CanQuery = false
	State.waterFloor.Transparency = 1
	State.waterFloor.CastShadow = false
	State.waterFloor.Parent = workspace


	local function followCharacter()
		if not State.walkWater or not State.waterFloor or not State.waterFloor.Parent then
			return
		end
		local root = getRoot()
		if root then
			local x = math.floor(root.Position.X / 256 + 0.5) * 256
			local z = math.floor(root.Position.Z / 256 + 0.5) * 256
			State.waterFloor.Position = Vector3.new(x, -9.5, z)
		end
	end
	followCharacter()
	State.waterFloorConnection = RunService.Heartbeat:Connect(followCharacter)
	return true
end


local function callServer(remote, ...)
	if not remote then
		return false, nil
	end
	local ok, result
	if remote:IsA("RemoteFunction") then
		ok, result = pcall(remote.InvokeServer, remote, ...)
	elseif remote:IsA("RemoteEvent") then
		ok, result = pcall(remote.FireServer, remote, ...)
	else
		return false, nil
	end
	if not ok or result == false then
		return false, result
	end
	return true, result
end


State.fortuneSpinRaw = function()
    if State.rewardDataValue then
        local purchased=State.rewardDataValue("purchasedSpins")
        local free=State.rewardDataValue("freeWheelSpins")
        if type(purchased)=="number" or type(free)=="number" then
            return math.max(0,math.floor((tonumber(purchased) or 0)+(tonumber(free) or 0)))
        end
    end
    local menu=PlayerGui:FindFirstChild("fortuneWheelMenuGui")
    local label=menu and menu:FindFirstChild("spinAmountLabel",true)
    if not label or not label:IsA("TextLabel") then return nil end
    return tonumber(tostring(label.Text or ""):match("(%d+)"))
end
State.fortuneCooldownRemaining=function()
    local serverUntil=tonumber(LP:GetAttribute("FortuneWheelCooldownUntil")) or 0
    return math.max(0,serverUntil-workspace:GetServerTimeNow(),
        (State.fortuneRetryAt or 0)-os.clock(),(State.fortuneNextAt or 0)-os.clock())
end
State.fortuneSpinAmount=function()
    if State.fortuneCooldownRemaining()>0 then return nil end
    local amount=State.fortuneSpinRaw()
    local pending=State.fortunePending
    if pending then
        if amount and amount<pending.before then
            State.fortunePending=nil
        elseif (pending.returned or pending.cancelled) and os.clock()>=(pending.releaseAt or math.huge) then
            State.fortunePending=nil
        else return nil end
    end
    return amount
end
State.syncAvailabilityToggle=function(toggle,enabled)
    if toggle and toggle:Get()~=enabled then toggle:Set(enabled,true) end
end
local function setAutoSpinWheel(enabled)
    enabled=enabled==true
    if not enabled then
        State.autoSpinWheel=false
        local pending=State.fortunePending
        if pending and not pending.returned then
            pending.cancelled=true
            pending.releaseAt=math.max(State.fortuneNextAt or 0,os.clock()+20)
        end
        stopThread("fortuneWheel")
        if State.rewardsBusy=="wheel" then State.rewardsBusy=nil end
        State.syncAvailabilityToggle(State.autoSpinToggle,false)
        return true
    end
    if State.autoSpinWheel then return true end
    local available=State.fortuneSpinAmount()
    if State.rewardsBusy or not available or available<=0 then return false end
    local events=ReplicatedStorage:FindFirstChild("rEvents")
    local remote=events and events:FindFirstChild("openFortuneWheelRemote")
    local shared=ReplicatedStorage:FindFirstChild("shared")
    local catalogs=shared and shared:FindFirstChild("catalogs")
    local chances=catalogs and catalogs:FindFirstChild("fortuneWheelChances")
    local wheel=chances and chances:FindFirstChild("Fortune Wheel")
    if not remote or not remote:IsA("RemoteFunction") or not wheel then return false end
    State.autoSpinWheel=true
    State.rewardsBusy="wheel"
    State.fortuneLastSpins=0
    State.fortuneLastError=nil
    startThread("fortuneWheel",function()
        local ok,problem=pcall(function()
            local rejections=0
            while State.running and State.autoSpinWheel do
                if not State.running or not State.autoSpinWheel then break end
                while State.running and State.autoSpinWheel and State.fortuneCooldownRemaining()>0 do
                    task.wait(math.min(.25,State.fortuneCooldownRemaining()))
                end
                if not State.running or not State.autoSpinWheel then break end
                local before=State.fortuneSpinRaw()
                if not before or before<=0 then break end
                local pending={before=before,at=os.clock(),returned=false}
                State.fortunePending=pending
                State.fortuneNextAt=os.clock()+.25
                local sent,result=pcall(remote.InvokeServer,remote,"openFortuneWheel",wheel)
                pending.returned=true
                pending.releaseAt=math.max(State.fortuneNextAt,os.clock()+.5)
                local valid=sent and type(result)=="table" and type(result.name)=="string"
                    and type(result.rarity)=="string" and type(result.image)=="string" and typeof(result.itemColor)=="Color3"
                State.fortuneLastRequest={before=before,at=pending.at,returnedAt=os.clock(),sent=sent,
                    valid=valid,reply=type(result)=="table" and tostring(result.name) or tostring(result)}
                if not valid then
                    State.fortunePending=nil
                    rejections=rejections+1
                    local retryDelay=math.min(.35+rejections*.2,2.5)
                    State.fortuneRetryAt=os.clock()+retryDelay
                    State.fortuneLastError=sent and "La ruleta todavía no aceptó el giro" or "Esperando confirmación del giro"
                    task.wait(retryDelay)
                else
                    local confirmed=false
                    local deadline=os.clock()+4
                    repeat
                        task.wait(.1)
                        local remaining=State.fortuneSpinRaw()
                        State.fortuneLastRequest.after=remaining
                        confirmed=remaining~=nil and remaining<before
                    until confirmed or os.clock()>=deadline or not State.running or not State.autoSpinWheel
                    if not confirmed then
                        State.fortunePending=nil
                        rejections=rejections+1
                        local retryDelay=math.min(.35+rejections*.2,2.5)
                        State.fortuneRetryAt=os.clock()+retryDelay
                        State.fortuneLastError="Esperando confirmación del giro"
                        task.wait(retryDelay)
                    else
                        State.fortunePending=nil
                        State.fortuneLastError=nil
                        State.fortuneLastSpins=State.fortuneLastSpins+1
                        rejections=0
                        if State.pushOutput then State.pushOutput("REWARD","Fortune Wheel · +1 giro confirmado") end
                        task.wait(.08)
                    end
                end
            end
        end)
        if not ok then State.fortuneLastError=tostring(problem) end
        State.autoSpinWheel=false
        if State.rewardsBusy=="wheel" then State.rewardsBusy=nil end
        State.syncAvailabilityToggle(State.autoSpinToggle,false)
        if State.fortuneLastError and State.pushOutput then State.pushOutput("ERROR",State.fortuneLastError) end
        if State.refreshMiscAvailability then State.refreshMiscAvailability() end
    end)
    return true
end

local CHEST_DEFINITIONS = {
	{ name = "Industrial Chest", objectName = "industrialChest", timeName = "industrialChestTime" },
	{ name = "Golden Chest", objectName = "goldenChest", timeName = "goldenChestTime" },
	{ name = "Enchanted Chest", objectName = "enchantedChest", timeName = "enchantedChestTime" },
	{ name = "Magma Chest", objectName = "magmaChest", timeName = "magmaChestTime" },
	{ name = "Mythical Chest", objectName = "mythicalChest", timeName = "mythicalChestTime" },
	{ name = "Legends Chest", objectName = "legendsChest", timeName = "legendsChestTime" },
	{ name = "Jungle Chest", objectName = "jungleChest", timeName = "jungleChestTime" },
}

State.chestClaimBusy = false
State.chestRejectedUntil = {}


local function chestNotify(text)
	pcall(function()
		local title = "Young0x Hub - Cofres"
		local message = tostring(text or "")
		if type(State.translateText) == "function" then
			title = State.translateText(title)
			message = State.translateText(message)
		end
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = title,
			Text = message,
			Duration = 4,
		})
	end)
end

local ChestData = nil
local NeededChestTimers = Shared and Shared:FindFirstChild("catalogs")
NeededChestTimers = NeededChestTimers and NeededChestTimers:FindFirstChild("neededTimers")
startThread("chestDataLoader", function()
	local ok, data = pcall(function()
		local packages = ReplicatedStorage:FindFirstChild("packages")
		local module = packages and packages:FindFirstChild("ReplicatorClient")
		if not module then return nil end
		local replicator = require(module)
		return replicator.get("Data")
	end)
	if ok then ChestData = data end
end)


State.rewardDataValue=function(key)
    if not ChestData then return nil end
    local ok,value=pcall(function() return ChestData:TryIndex({key}) end)
    return ok and value or nil
end
State.chestIsReady = function(definition)
	local blockedUntil = State.chestRejectedUntil[definition.name]
	if typeof(blockedUntil) == "number" and os.clock() < blockedUntil then
		return false
	end
	local model = workspace:FindFirstChild(definition.objectName, true)
	local trigger = model and model:FindFirstChild("circleInner", true)
	local timer = NeededChestTimers and NeededChestTimers:FindFirstChild(definition.name)
	if not trigger or not trigger:IsA("BasePart") or not timer or not timer:IsA("IntValue") or not ChestData then
		return false
	end
	local ok, claimedAt = pcall(function()
		return ChestData:TryIndex({ definition.timeName })
	end)
	if not ok or typeof(claimedAt) ~= "number" then
		return false
	end
	local serverNow = workspace:GetServerTimeNow()
	return serverNow - claimedAt >= timer.Value
end


State.chestClaimTime = function(definition)
	if not ChestData then return nil end
	local ok, claimedAt = pcall(function()
		return ChestData:TryIndex({ definition.timeName })
	end)
	return ok and typeof(claimedAt) == "number" and claimedAt or nil
end


State.readyChestDefinitions = function()
	local ready = {}
	for _, definition in ipairs(CHEST_DEFINITIONS) do
		if State.chestIsReady(definition) then
			ready[#ready + 1] = definition
		end
	end
	return ready
end

State.closeRewardPopup=function()
    local gui=LP:FindFirstChildOfClass("PlayerGui")
    gui=gui and gui:FindFirstChild("gameGui")
    local popup=gui and gui:FindFirstChild("groupRewardsMenu")
    if not popup or not popup:IsA("GuiObject") or not popup.Visible then return false end
    local event=gui:FindFirstChild("guiEffectsEvent")
    if event and event:IsA("BindableEvent") then
        event:Fire("resetMenus")
        return true
    end
    popup.Visible=false
    return true
end
State.watchRewardPopups=function()
    startThread("rewardMenus",function()
        local deadline=os.clock()+2
        while State.running and (State.autoClaimChests or os.clock()<deadline) do
            if State.autoClaimChests then deadline=os.clock()+2 end
            State.closeRewardPopup()
            task.wait(.35)
        end
    end)
end
State.activeChestRestore=nil
State.restoreChestTravel=function()
    local restore=State.activeChestRestore
    State.activeChestRestore=nil
    if restore then
        local ok,problem=pcall(restore)
        if not ok then State.chestLastError=tostring(problem) end
    end
end
State.rewardPauseBegin=function()
    if State.rewardsBusy and State.rewardsBusy~="chests" then return nil,"Hay otra recompensa en curso" end
    if State.kill and (State.kill.hopInProgress or State.kill.teleportPending or State.kill.brawlBusy) then return nil,"Esperá a que termine la pelea o el cambio de servidor" end
    local beforeCharacter=getCharacter()
    local paused={controls={},mode=FastFarm.mode,pack=FastFarm.packMode,machine=State.machine,
        afk=State.afkSnapshot and State.afkSnapshot(),momentum=FastFarm.PetMomentum and FastFarm.PetMomentum.mode,
        kill=State.kill and State.kill.auto,brawl=State.kill and State.kill.autoWinBrawl,
        hop=State.kill and State.kill.serverHop,at=os.clock(),
        rebirthing=beforeCharacter and (beforeCharacter:GetAttribute("IsRebirthing")==true or beforeCharacter:GetAttribute("LastMapCFrame")~=nil)}
    paused.rebirthing=paused.rebirthing or paused.mode=="rebirth" or (paused.afk and paused.afk.mode=="Auto Rebirth") or false
    local released=false
    local function activeMovement()
        if FastFarm.mode or State.afk and State.afk.active or FastFarm.PetMomentum and FastFarm.PetMomentum.mode then return true end
        if State.machine or State.fly or State.kill and (State.kill.auto or State.kill.autoWinBrawl or State.kill.serverHop) then return true end
        for _,key in ipairs({"autoWeight","autoLift","autoHandstands","autoSitups"}) do if State[key] then return true end end
        return false
    end
    local function restore()
        if released then return end
        released=true
        if not State.running or State.shuttingDown then return end
        task.defer(function()
            if not State.running or State.shuttingDown or activeMovement() then return end
            if paused.afk and State.afkResume then
                State.afkResume(paused.afk)
            elseif paused.mode then
                FastFarm.packMode=paused.pack
                FastFarm:Start(paused.mode)
            elseif paused.momentum and FastFarm.PetMomentum then
                FastFarm.PetMomentum:Start()
            else
                local restoredMachine=false
                for _,saved in ipairs(paused.controls) do
                    local c=State.profileControls[saved.key]
                    if c and not c:Get() then
                        local ok,accepted=pcall(c.Set,c,true)
                        if not ok or accepted==false then State.pushOutput("ERROR","No se pudo reanudar: "..saved.key) end
                        if saved.key:sub(1,11)=="Full Train|" or saved.key:sub(1,10)=="Auto Farm|" then restoredMachine=true end
                    end
                end
                if paused.machine and not restoredMachine and not State.machine then setMachine(paused.machine,true) end
                if paused.kill and not State.kill.auto and State.killAutoToggle then State.killAutoToggle:Set(true) end
                if paused.brawl and not State.kill.autoWinBrawl and State.killAutoWinBrawlToggle then State.killAutoWinBrawlToggle:Set(true) end
                if paused.hop and not State.kill.serverHop and State.killServerHopToggle then State.killServerHopToggle:Set(true) end
            end
        end)
    end
    paused.restore=restore
    State.rewardPaused=paused
    if paused.afk and State.afkStop then State.afkStop() end
    if FastFarm.PetMomentum and FastFarm.PetMomentum.mode then FastFarm.PetMomentum:Stop(false) end
    if FastFarm.mode then FastFarm:Stop(false,true) end
    for key,c in pairs(State.profileControls or {}) do
        if c.ProfileKind=="toggle" and c:Get() then
            local moving=key:sub(1,9)=="Rebirths|" or key:sub(1,11)=="Full Train|"
                or key:sub(1,15)=="Fast Glitch 100%" or key=="Misc| Fly "
                or key:sub(1,10)=="Auto Farm|" and not key:find("Egg",1,true) and not key:find("GAMEPASS",1,true)
                or key=="Kills|Auto Kill" or key=="Kills|Auto Win Brawl" or key=="Kills|Server Hop inteligente"
                or key=="Kills|Matar jugador" or key=="Kills|Good Karma" or key=="Kills|Evil Karma"
                or key=="Server Hop|Mantener objetivo automáticamente"
            if moving then
                paused.controls[#paused.controls+1]={key=key}
                c:Set(false)
            end
        end
    end
    table.sort(paused.controls,function(a,b) return a.key<b.key end)
    if State.kill then
        if State.kill.auto and State.setAutoKill then State.setAutoKill(false) end
        if State.kill.autoWinBrawl and State.setAutoWinBrawl then State.setAutoWinBrawl(false) end
        if State.kill.serverHop and State.setServerHop then State.setServerHop(false) end
    end
    if State.machine then setMachine(nil,false) end
    local inUse=LP:FindFirstChild("machineInUse")
    if inUse and inUse.Value then leaveMachine() end
    return paused
end
State.waitRewardCharacter=function(timeout,wasRebirthing)
    local deadline=os.clock()+(tonumber(timeout) or 15)
    local stableAt,stablePosition,stableCharacter,stableRoot,clearAt=nil,nil,nil,nil,nil
    local sawRebirth=wasRebirthing==true
    State.rewardSettling={startedAt=os.clock(),deadline=deadline,stableFor=0,reason="Esperando personaje"}
    while State.running and State.autoClaimChests and os.clock()<deadline do
        local now=os.clock()
        local character=getCharacter()
        local root=getRoot()
        local humanoid=character and character:FindFirstChildOfClass("Humanoid")
        local machine=LP:FindFirstChild("machineInUse")
        local rebirthing=character and (character:GetAttribute("IsRebirthing")==true or character:GetAttribute("LastMapCFrame")~=nil)
        local mounted=(machine and machine.Value~=nil) or (humanoid and humanoid.SeatPart~=nil)
        local ready=character and root and root.Parent and humanoid and humanoid.Health>0 and not rebirthing and not mounted
        if rebirthing then sawRebirth=true;clearAt=nil end
        if not ready then
            stableAt,stablePosition,stableCharacter,stableRoot=nil,nil,nil,nil
            State.rewardSettling.reason=rebirthing and "Esperando el regreso del rebirth" or mounted and "Saliendo de la máquina" or "Esperando personaje"
        else
            clearAt=clearAt or now
            if character~=stableCharacter or root~=stableRoot or not stablePosition or (root.Position-stablePosition).Magnitude>1.25 then
                stableAt,stablePosition,stableCharacter,stableRoot=now,root.Position,character,root
            end
            State.rewardSettling.stableFor=now-(stableAt or now)
            State.rewardSettling.reason="Esperando posición estable"
            if now-(stableAt or now)>=1 and (not sawRebirth or now-clearAt>=3) then
                State.rewardSettling=nil
                return character,root,humanoid
            end
        end
        task.wait(.1)
    end
    local reason=State.rewardSettling and State.rewardSettling.reason or "Esperando personaje"
    State.rewardSettling=nil
    return nil,nil,nil,State.autoClaimChests and ("No se inició el recorrido: "..reason) or "Recorrido cancelado"
end
local function claimChestBatch(definitions)
    if State.chestClaimBusy or not State.running or not State.autoClaimChests then return false,{} end
    State.chestClaimBusy=true
    State.chestLastBatchClaims=0
    State.chestLastError=nil
    State.chestLastResults={}
    local results,paused,character,root,origin,anchored,restored={},nil,nil,nil,nil,false,false
    local function restore()
        if restored then return end
        restored=true
        local positionOk,positionError=pcall(function()
            if character and LP.Character==character and root and root.Parent and origin then
                root.Anchored=false
                character:PivotTo(origin)
                root.AssemblyLinearVelocity=Vector3.zero
                root.AssemblyAngularVelocity=Vector3.zero
                root.Anchored=anchored
                State.chestLastRestoreDistance=(character:GetPivot().Position-origin.Position).Magnitude
            end
        end)
        if not positionOk then
            if root and root.Parent then pcall(function() root.Anchored=false end) end
            State.chestLastError=tostring(positionError)
        end
        State.chestClaimBusy=false
        stopThread("chestRequest")
        if State.rewardsBusy=="chests" then State.rewardsBusy=nil end
        local previous=paused or State.rewardPaused
        State.rewardPaused=nil
        if previous then
            local resumed,problem=pcall(previous.restore)
            if not resumed then State.chestLastError=tostring(problem) end
        end
    end
    State.activeChestRestore=restore
    local ok,problem=xpcall(function()
        local reason
        paused,reason=State.rewardPauseBegin()
        if not paused then error(reason or "No se pudo pausar el entrenamiento") end
        local humanoid,settleError
        character,root,humanoid,settleError=State.waitRewardCharacter(15,paused.rebirthing)
        if not State.autoClaimChests or not State.running then return end
        if not character then error(settleError or "El personaje no está listo") end
        origin=character:GetPivot(); anchored=root.Anchored
        local events=ReplicatedStorage:FindFirstChild("rEvents")
        local remote=events and events:FindFirstChild("checkChestRemote")
        if not remote then error("No se encontró el control de cofres") end
        for _,definition in ipairs(definitions) do
            if not State.running or not State.autoClaimChests then break end
            if LP.Character~=character or not root.Parent or humanoid.Health<=0 then error("El personaje cambió durante el recorrido") end
            local cooldown=os.clock()+5
            while State.running and State.autoClaimChests do
                local untilAt=tonumber(LP:GetAttribute("ChestRequestCooldownUntil")) or 0
                if untilAt<=workspace:GetServerTimeNow() then break end
                if os.clock()>=cooldown then error("El servidor sigue procesando el cofre anterior") end
                task.wait(.1)
            end
            if not State.running or not State.autoClaimChests then break end
            local model=workspace:FindFirstChild(definition.objectName,true)
            local trigger=model and model:FindFirstChild("circleInner",true)
            if State.chestIsReady(definition) and trigger and trigger:IsA("BasePart") then
                local before=State.chestClaimTime(definition)
                local report={name=definition.name,before=before,request="pending"}
                State.chestLastResults[#State.chestLastResults+1]=report
                local footOffset=root.Size.Y*.5+humanoid.HipHeight
                local leg=character:FindFirstChild("Left Leg")
                if leg and leg:IsA("BasePart") then footOffset=root.Size.Y*.5+leg.Size.Y end
                local ray=RaycastParams.new()
                ray.FilterType=Enum.RaycastFilterType.Exclude
                ray.FilterDescendantsInstances={character,model}
                local hit=workspace:Raycast(trigger.Position+Vector3.new(0,12,0),Vector3.new(0,-220,0),ray)
                local groundY=hit and hit.Position.Y or trigger.Position.Y
                local position=Vector3.new(trigger.Position.X,groundY+math.max(.2,footOffset)+.05,trigger.Position.Z)
                report.groundY=groundY
                report.footOffset=footOffset
                root.Anchored=false
                character:PivotTo(CFrame.new(position)*origin.Rotation)
                root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero
                RunService.Heartbeat:Wait()
                task.wait(math.clamp((getPing() or 0)/1000*2+.18,.25,1.2))
                report.distance=(root.Position-trigger.Position).Magnitude
                report.anchored=root.Anchored
                local feet=root.Position-Vector3.new(0,footOffset,0)
                local point=trigger.CFrame:PointToObjectSpace(feet)
                local radius=math.max(trigger.Size.Y,trigger.Size.Z)*.5
                report.localFeet={x=point.X,y=point.Y,z=point.Z}
                report.insideStrict=math.abs(point.X)<=trigger.Size.X*.5 and point.Y*point.Y+point.Z*point.Z<=radius*radius
                report.insideClient=math.abs(point.X)<=trigger.Size.X*.5+10 and point.Y*point.Y+point.Z*point.Z<=(radius+10)*(radius+10)
                local strength=getPlayerStat(LP,{"Strength"})
                local rebirths=getPlayerStat(LP,{"Rebirths"})
                local inUse=LP:FindFirstChild("machineInUse")
                report.strength=strength and tonumber(State.getFunctionalStatValue(strength)) or 0
                report.rebirths=rebirths and tonumber(State.getFunctionalStatValue(rebirths)) or 0
                report.machine=inUse and tostring(inUse.Value) or "nil"
                report.rebirthing=character:GetAttribute("IsRebirthing")==true
                report.lastMap=tostring(character:GetAttribute("LastMapCFrame"))
                local accepted=false
                local response={done=false}
                local observed=State.chestClaimTime(definition)
                if type(observed)=="number" and type(before)=="number" and observed>before then
                    accepted=true
                    report.request="native"
                else
                    startThread("chestRequest",function()
                        local sent,granted,reward,amount=pcall(remote.InvokeServer,remote,definition.name)
                        response.done=true
                        response.accepted=sent and granted==true and reward~=nil and amount~=nil
                        report.request=sent and "returned" or "error"
                        report.granted=tostring(granted)
                        report.reward=tostring(reward)
                        report.amount=tostring(amount)
                    end)
                end
                local deadline=os.clock()+4
                while not accepted and os.clock()<deadline and State.autoClaimChests and State.running do
                    task.wait(.1)
                    if LP.Character~=character or not root.Parent or humanoid.Health<=0 then error("El personaje cambió durante el recorrido") end
                    local after=State.chestClaimTime(definition)
                    report.after=after
                    accepted=type(after)=="number" and type(before)=="number" and after>before
                end
                root.Anchored=false
                if not accepted and not response.done and State.autoClaimChests and State.running then
                    error("El servidor no confirmó el cofre; se canceló el recorrido")
                end
                stopThread("chestRequest")
                results[definition.name]=accepted
                report.accepted=accepted
                State.chestLastClaim=definition.name
                State.chestLastClaimAccepted=accepted
                if accepted then
                    State.chestRejectedUntil[definition.name]=nil
                    State.chestLastBatchClaims=State.chestLastBatchClaims+1
                    if State.pushOutput then State.pushOutput("REWARD",definition.name.." · reclamado") end
                else
                    State.chestRejectedUntil[definition.name]=os.clock()+30
                    if State.pushOutput then State.pushOutput("ERROR",definition.name.." · sin confirmar ("..tostring(report.reward or report.granted or report.request)..")") end
                end
            end
        end
    end,debug.traceback)
    if not ok then State.chestLastError=tostring(problem) end
    if ok and State.autoClaimChests and State.chestLastBatchClaims<#definitions then
        State.chestLastError="Cofres confirmados: "..tostring(State.chestLastBatchClaims).."/"..tostring(#definitions)
    end
    State.restoreChestTravel()
    return ok,results
end
local function setAutoClaimChests(enabled)
    enabled=enabled==true
    if not enabled then
        State.autoClaimChests=false
        State.restoreChestTravel()
        stopThread("autoClaimChests")
        State.chestClaimBusy=false
        if State.rewardsBusy=="chests" then State.rewardsBusy=nil end
        State.syncAvailabilityToggle(State.autoClaimToggle,false)
        return true
    end
    if State.autoClaimChests then return true end
    if State.rewardsBusy then return false end
    local ready=State.readyChestDefinitions()
    if #ready==0 then return false end
    State.autoClaimChests=true
    State.rewardsBusy="chests"
    State.watchRewardPopups()
    startThread("autoClaimChests",function()
        local ok,problem=pcall(claimChestBatch,ready)
        if not ok then State.chestLastError=tostring(problem) end
        State.autoClaimChests=false
        State.restoreChestTravel()
        State.chestClaimBusy=false
        if State.rewardsBusy=="chests" then State.rewardsBusy=nil end
        State.syncAvailabilityToggle(State.autoClaimToggle,false)
        if State.chestLastError then
            if State.pushOutput then State.pushOutput("ERROR",State.chestLastError) end
            chestNotify("No se pudieron reclamar los cofres.")
        else
            chestNotify("Cofres reclamados: "..tostring(State.chestLastBatchClaims or 0).."/"..tostring(#ready)..".")
        end
        if State.refreshMiscAvailability then State.refreshMiscAvailability() end
    end)
    return true
end
addCleanup(function()
    State.autoClaimChests=false
    State.closeRewardPopup()
    State.restoreChestTravel()
    State.autoSpinWheel=false
    State.rewardsBusy=nil
end)

local portalConnection = nil
local removedPortals = {}

local function removePortal(object)
	if object and object.Name == "RobloxForwardPortals" and object.Parent then
		removedPortals[#removedPortals + 1] = { object = object, parent = object.Parent }
		object.Parent = nil
	end
end


local function setRemovePortals(enabled)
	State.removePortals = enabled == true
	stopThread("removePortals")
	if portalConnection then
		portalConnection:Disconnect()
		portalConnection = nil
	end
	if not State.removePortals then
		for _, entry in ipairs(removedPortals) do
			if entry.object and not entry.object.Parent then
				pcall(function()
					entry.object.Parent = entry.parent and entry.parent.Parent and entry.parent or workspace
				end)
			end
		end
		table.clear(removedPortals)
		return
	end
	if State.removePortals then
		portalConnection = game.DescendantAdded:Connect(removePortal)
		startThread("removePortals", function()
			local queue = { workspace }
			local head = 1
			local processed = 0
			while head <= #queue and State.running and State.removePortals do
				local parent = queue[head]
				head = head + 1
				local ok, children = pcall(function()
					return parent:GetChildren()
				end)
				if ok then
					for _, child in ipairs(children) do
						queue[#queue + 1] = child
						removePortal(child)
						processed = processed + 1
						if processed % 300 == 0 then
							RunService.Heartbeat:Wait()
						end
					end
				end
			end
		end)
	end
end

local baseWalkSpeed = nil

local function applyWalkSpeed()
	local humanoid = getHumanoid()
	if humanoid then
		if State.fastSpeed then
			humanoid.WalkSpeed = 1000
		elseif baseWalkSpeed ~= nil then
			humanoid.WalkSpeed = baseWalkSpeed
		end
	end
end


local function setFastSpeed(enabled)
	local humanoid = getHumanoid()
	if enabled and humanoid and not State.fastSpeed then
		baseWalkSpeed = humanoid.WalkSpeed
	end
	local wasEnabled = State.fastSpeed
	State.fastSpeed = enabled == true
	if State.fastSpeed or wasEnabled then
		applyWalkSpeed()
	end
	if wasEnabled and not State.fastSpeed then
		baseWalkSpeed = nil
	end
end

local flyGyro = nil
local flyVelocity = nil
local mobileFlyUp = false
local mobileFlyDown = false


State.clearAntiKnockback = function()
	if State.antiKnockbackVelocity then
		State.antiKnockbackVelocity:Destroy()
		State.antiKnockbackVelocity = nil
	end
end


State.setAntiKnockback = function(enabled)
	State.antiKnockback = enabled == true
	if not State.antiKnockback and not State.noclip then
		State.clearAntiKnockback()
	end
end


local function clearFlyMovers()
	if flyGyro then
		flyGyro:Destroy()
		flyGyro = nil
	end
	if flyVelocity then
		flyVelocity:Destroy()
		flyVelocity = nil
	end
	local humanoid = getHumanoid()
	if humanoid then
		humanoid.PlatformStand = false
	end
end


local function setFly(enabled)
	State.fly = enabled == true
	if not State.fly then
		mobileFlyUp = false
		mobileFlyDown = false
		if State.mobileFlyUpToggle then State.mobileFlyUpToggle:Set(false, true) end
		if State.mobileFlyDownToggle then State.mobileFlyDownToggle:Set(false, true) end
		clearFlyMovers()
	end
end

local setNoclip
do
	local originals = setmetatable({}, { __mode = "k" })
	local simulationConnection = nil

	local function findBeachSurfaceY()
		local bestSurface = nil
		local bestScore = math.huge
		for _, object in ipairs(workspace:GetChildren()) do
			if object:IsA("BasePart") and object.Name:lower() == "baseplate"
				and math.max(object.Size.X, object.Size.Z) >= 250 then
				local frame = object.CFrame
				local verticalHalfSize = math.abs(frame.RightVector.Y) * object.Size.X * 0.5
					+ math.abs(frame.UpVector.Y) * object.Size.Y * 0.5
					+ math.abs(frame.LookVector.Y) * object.Size.Z * 0.5
				local surface = object.Position.Y + verticalHalfSize
				local score = math.abs(surface)
				if score < bestScore then
					bestScore = score
					bestSurface = surface
				end
			end
		end
		if bestSurface ~= nil then
			return bestSurface
		end
		local root = getRoot()
		local humanoid = getHumanoid()
		if root then
			return root.Position.Y - ((humanoid and humanoid.HipHeight or 2) + root.Size.Y * 0.5)
		end
		return 0
	end


	local function applyToPart(part)
		if originals[part] == nil then
			originals[part] = {
				canCollide = part.CanCollide,
				canTouch = part.CanTouch,
				canQuery = part.CanQuery,
			}
		end
		pcall(function()
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
		end)
	end


	local function applyNoclip()
		if not State.running or not State.noclip then return end
		local character = getCharacter()
		if not character then return end
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				applyToPart(part)
			end
		end
	end


	local function restoreNoclip()
		if simulationConnection then
			simulationConnection:Disconnect()
			simulationConnection = nil
		end
		for part, properties in pairs(originals) do
			if part and part.Parent then
				pcall(function()
					part.CanCollide = properties.canCollide
					part.CanTouch = properties.canTouch
					part.CanQuery = properties.canQuery
				end)
			end
		end
		table.clear(originals)
	end


	setNoclip = function(enabled)
		State.noclip = enabled == true
		if not State.noclip then
			State.noclipBeachSurfaceY = nil
			restoreNoclip()
			if not State.antiKnockback then
				State.clearAntiKnockback()
			end
			return true
		end
		State.noclipBeachSurfaceY = findBeachSurfaceY()
		if simulationConnection then
			simulationConnection:Disconnect()
		end
		applyNoclip()
		simulationConnection = RunService.PreSimulation:Connect(applyNoclip)
		return true
	end
end

local spinVelocity = nil
local spinHumanoid = nil
local spinAutoRotate = true


local function clearSpin()
	if spinVelocity then
		local root = spinVelocity.Parent
		if root and root:IsA("BasePart") then
			root.AssemblyAngularVelocity = Vector3.zero
		end
		spinVelocity:Destroy()
		spinVelocity = nil
	end
	if spinHumanoid and spinHumanoid.Parent then
		spinHumanoid.AutoRotate = spinAutoRotate
	end
	spinHumanoid = nil
end


local function setSpin(enabled)
	State.spin = enabled == true
	if not State.spin then
		clearSpin()
	end
end


local function resetCamera()
	local humanoid = getHumanoid()
	if workspace.CurrentCamera and humanoid then
		workspace.CurrentCamera.CameraSubject = humanoid
	end
end


local function setSpy(enabled)
	State.spy = enabled == true
	if not State.spy then
		resetCamera()
	end
end

do
	local BrawlState = ReplicatedStorage:WaitForChild("shared"):WaitForChild("state"):WaitForChild("Brawl")
	local BrawlEvent = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("brawlEvent")

	local function restorePunch()
		pcall(function()
			local character = getCharacter()
			local backpack = LP:FindFirstChild("Backpack")
			local punch = character and character:FindFirstChild("Punch")
			if punch and backpack then
				punch.Parent = backpack
			end
		end)
	end


	local function equipPunch()
		local character = getCharacter()
		local humanoid = getHumanoid()
		local backpack = LP:FindFirstChild("Backpack")
		if not character or not humanoid then
			return nil
		end
		local punch = character:FindFirstChild("Punch") or (backpack and backpack:FindFirstChild("Punch"))
		if punch and punch.Parent ~= character then
			pcall(humanoid.EquipTool, humanoid, punch)
		end
		if punch then
			local attackTime = punch:FindFirstChild("attackTime")
			if attackTime and attackTime:IsA("ValueBase") then
				pcall(function()
					attackTime.Value = 0
				end)
			end
		end
		return punch
	end


	local function hasSpawnProtection(character)
		local protectedUntil = character and character:GetAttribute("SpawnProtectedUntil")
		if type(protectedUntil) == "number" and workspace:GetServerTimeNow() < protectedUntil then
			return true
		end
		return character ~= nil and (
			character:FindFirstChildOfClass("ForceField") ~= nil
			or character:FindFirstChild("spawnProtectionHighlight") ~= nil
		)
	end


	local function hasTargetProtection(character)
		return hasSpawnProtection(character)
			or (character ~= nil and character:GetAttribute("InTinyIsland") == true)
	end


	local function killsBlockedHere()
		if #CONFIG.Kills.ProtectedPrivateServerIds == 0 then
			return false
		end
		local environment = getgenv and getgenv() or _G
		local reader = environment.gethiddenproperty or environment.gethiddenprop
		if type(reader) ~= "function" then
			return false
		end
		local ok, value = pcall(reader, game, "PrivateServerId")
		local privateServerId = ok and tostring(value or "") or ""
		return privateServerId ~= ""
			and table.find(CONFIG.Kills.ProtectedPrivateServerIds, privateServerId) ~= nil
	end


	local function currentKillsTotal()
		local stat = getPlayerStat(LP, { "Kills" })
		local value = stat and tonumber(State.getFunctionalStatValue(stat))
		return value and math.floor(value) or nil
	end


	local function refreshKillSessionCounter()
		if type(State.kill.updateSessionCounter) == "function" then
			pcall(State.kill.updateSessionCounter, State.kill.sessionKills, State.kill.killSessionActive)
		end
	end


	local function updateKillSession(value)
		local numeric = tonumber(value)
		if not numeric then
			return
		end
		local current = math.floor(numeric)
		local previous = State.kill.lastObservedKills
		State.kill.lastObservedKills = current
		if previous == nil or current > previous then
			State.kill.lastKillAt = os.clock()
			if previous ~= nil then State.pushOutput("KILL", "+" .. formatExact(current - previous) .. " kills confirmadas") end
		end
		State.kill.sessionLastTotal = current
		if State.kill.killSessionActive then
			if State.kill.sessionStartKills == nil then
				State.kill.sessionStartKills = current
				State.kill.sessionKills = 0
			elseif current >= State.kill.sessionStartKills then
				State.kill.sessionKills = current - State.kill.sessionStartKills
			end
		end
		refreshKillSessionCounter()
	end


	local function startKillSession()
		if State.kill.killSessionActive then
			if not State.kill.sessionStartedAt then State.kill.sessionStartedAt = os.clock() end
			return
		end
		State.kill.killSessionActive = true
		State.kill.sessionKills = 0
		State.kill.sessionStartKills = currentKillsTotal()
		State.kill.sessionLastTotal = State.kill.sessionStartKills
		State.kill.sessionElapsed = 0
		State.kill.sessionStartedAt = os.clock()
		refreshKillSessionCounter()
	end
	State.getKillSessionElapsed = function()
		local elapsed = math.max(0, tonumber(State.kill.sessionElapsed) or 0)
		if State.kill.killSessionActive and State.kill.sessionStartedAt then
			elapsed = elapsed + math.max(0, os.clock() - State.kill.sessionStartedAt)
		end
		return elapsed
	end

	local function stopKillSessionIfIdle()
		local active = State.kill.auto or State.kill.targetMode or State.kill.karmaMode ~= nil
			or State.kill.autoWinBrawl
		if active or not State.kill.killSessionActive then return false end
		State.kill.sessionElapsed = State.getKillSessionElapsed()
		State.kill.sessionStartedAt = nil
		State.kill.killSessionActive = false
		refreshKillSessionCounter()
		return true
	end


	local function rebuildKillFriendCache()
		local fresh = {}
		local loaded = false
		local endpoint = string.format("https://friends.roblox.com/v1/users/%d/friends", LP.UserId)
		local httpOk, body = pcall(game.HttpGet, game, endpoint, true)
		if httpOk and type(body) == "string" then
			local httpService = game:GetService("HttpService")
			local decodeOk, response = pcall(httpService.JSONDecode, httpService, body)
			if decodeOk and type(response) == "table" and type(response.data) == "table" then
				for _, friend in ipairs(response.data) do
					local userId = tonumber(friend.id or friend.Id)
					if userId then fresh[userId] = true end
				end
				loaded = true
			end
		end
		if not loaded then
			loaded = pcall(function()
				local pages = Players:GetFriendsAsync(LP.UserId)
				while State.running and State.kill.protectFriends do
					for _, friend in ipairs(pages:GetCurrentPage()) do
						local userId = tonumber(friend.Id)
						if userId then fresh[userId] = true end
					end
					if pages.IsFinished then break end
					pages:AdvanceToNextPageAsync()
				end
			end)
		end
		if loaded then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LP and fresh[player.UserId] == nil then
					fresh[player.UserId] = false
				end
			end
			State.kill.friendCache = fresh
		end
		State.kill.friendProtectionReady = loaded
		return loaded
	end


	local function checkFriendship(player)
		local asyncOk, asyncResult = pcall(LP.IsFriendsWithAsync, LP, player.UserId)
		if asyncOk then
			return asyncResult == true
		end
		local legacyOk, legacyResult = pcall(LP.IsFriendsWith, LP, player.UserId)
		if legacyOk then
			return legacyResult == true
		end
		return nil
	end


	local function refreshKillFriendProtection()
		stopThread("killFriendRefresh")
		table.clear(State.kill.friendCache)
		State.kill.friendProtectionReady = false
		if not State.kill.protectFriends then
			return
		end
		startThread("killFriendRefresh", function()
			while State.running and State.kill.protectFriends do
				rebuildKillFriendCache()
				for _ = 1, 60 do
					if not State.running or not State.kill.protectFriends then
						return
					end
					task.wait(1)
				end
			end
		end)
	end


	local function isFriendProtected(player)
		if not State.kill.protectFriends or not player or player == LP then
			return false
		end
		local cached = State.kill.friendCache[player.UserId]
		if cached ~= nil and State.kill.friendProtectionReady then
			return cached == true
		end
		local result = checkFriendship(player)
		if result ~= nil then
			State.kill.friendCache[player.UserId] = result
			return result
		end
		return true
	end


	local function hasKillClanTag(player)
		if not player then
			return false
		end
		local username = string.lower(tostring(player.Name or ""))
		local displayName = string.lower(tostring(player.DisplayName or ""))
		return string.find(username, "0x", 1, true) ~= nil
			or string.find(displayName, "0x", 1, true) ~= nil
	end


	local function protectedTarget(player)
		if not player or player == LP then
			return true
		end
		if hasKillClanTag(player) then
			return true
		end
		return isFriendProtected(player)
	end
	State.kill.estimateCurrentTargets = function()
		if State.kill.targetMode then
			local target = State.kill.target and Players:FindFirstChild(State.kill.target)
			return target and not protectedTarget(target) and 1 or 0
		end
		local total = 0
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
			if not protectedTarget(player) and humanoid and humanoid.Health > 0 and not hasTargetProtection(character) then
				total = total + 1
			end
		end
		return total
	end


	local function isInsideBrawl(player)
		local character = player and player.Character
		return character ~= nil and character:GetAttribute("LastMapCFrame") ~= nil
	end


	local function isInBrawlBattle(player)
		local character = player and player.Character
		return character ~= nil and character:GetAttribute("InBattle") == true
	end


	local function currentBrawlWins()
		local leaderstats = LP:FindFirstChild("leaderstats")
		local brawls = leaderstats and leaderstats:FindFirstChild("Brawls")
		local value = brawls and tonumber(State.getFunctionalStatValue(brawls))
		return value and math.floor(value) or nil
	end


	local function brawlPromptVisible()
		local gameGui = PlayerGui:FindFirstChild("gameGui")
		local prompt = gameGui and gameGui:FindFirstChild("brawlJoinLabel")
		return prompt ~= nil and prompt.Visible == true
	end

	State.updateKillSession = updateKillSession
	State.refreshKillSessionCounter = refreshKillSessionCounter


	local function refreshFastPunch()
		stopThread("killFastPunch")
	end

	local TARGET_ATTACK_WINDOW = 0.75
	local TARGET_UPDATE_INTERVAL = 0.06
	local TARGET_DISTANCE = 0.1
	local TARGET_PREDICTION_TIME = 0.025
	local TARGET_MAX_PREDICTION = 0.8
	local TARGET_SURFACE_GAP = 0.2
	local TARGET_SURFACE_SIZE = 4.5
	local TARGET_POSE_OFFSET = 4
	local TARGET_RETRY_DELAY = 0.8
	local TARGET_SMALL_SIZE = 0.75
	local TARGET_HAND_GAP = 0.02


	local function getCombatPart(character, root)
		return character and (
			character:FindFirstChild("UpperTorso")
			or character:FindFirstChild("Torso")
			or character:FindFirstChild("LowerTorso")
		) or root
	end


	local function getAttackCFrame(character, root, targetCharacter, targetRoot, contactStep)
		local velocity = targetRoot.AssemblyLinearVelocity
		local prediction = Vector3.new(velocity.X, 0, velocity.Z) * TARGET_PREDICTION_TIME
		if prediction.Magnitude > TARGET_MAX_PREDICTION then prediction = prediction.Unit * TARGET_MAX_PREDICTION end
		local ownPart = getCombatPart(character, root)
		local targetPart = getCombatPart(targetCharacter, targetRoot)
		local ownOffset = ownPart and (ownPart.Position - root.Position) or Vector3.zero
		if ownOffset.Magnitude > 4 then ownOffset = Vector3.new(0, 1, 0) end
		local step = ((contactStep or 1) - 1) % 5 + 1
		local rootPosition = targetRoot.Position + prediction
		local targetPosition = (targetPart and targetPart.Position or targetRoot.Position) + prediction
		if targetPart then
			local size = targetPart.Size
			local ownHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
			if targetRoot.Size.X <= TARGET_SMALL_SIZE and ownHand then
				local normal, extent
				if step == 1 then normal, extent = -targetPart.CFrame.LookVector, size.Z * 0.5
				elseif step == 2 then normal, extent = targetPart.CFrame.RightVector, size.X * 0.5
				elseif step == 3 then normal, extent = targetPart.CFrame.LookVector, size.Z * 0.5
				elseif step == 4 then normal, extent = -targetPart.CFrame.RightVector, size.X * 0.5
				else normal, extent = -targetPart.CFrame.LookVector, 0 end
				local facing = CFrame.lookAt(Vector3.zero, -normal)
				local handOffset = root.CFrame:PointToObjectSpace(ownHand.Position)
				local attackPosition = targetPosition + normal * (extent + TARGET_HAND_GAP)
					- facing:VectorToWorldSpace(handOffset)
				return CFrame.new(attackPosition) * facing.Rotation
			end
			local oversized = math.max(size.X, size.Y, size.Z) >= TARGET_SURFACE_SIZE
			local displaced = (targetPart.Position - targetRoot.Position).Magnitude >= TARGET_POSE_OFFSET
			if not oversized and not displaced then
				local normal, extent
				if step == 1 then normal, extent = -targetRoot.CFrame.LookVector, targetRoot.Size.Z * 0.5
				elseif step == 2 then normal, extent = targetRoot.CFrame.RightVector, targetRoot.Size.X * 0.5
				elseif step == 3 then normal, extent = targetRoot.CFrame.LookVector, targetRoot.Size.Z * 0.5
				elseif step == 4 then normal, extent = -targetRoot.CFrame.RightVector, targetRoot.Size.X * 0.5 end
				if normal and extent then
					local ownExtent = math.max(root.Size.Z * 0.5, 0.15)
					local attackPosition = rootPosition + normal * (extent + ownExtent + TARGET_SURFACE_GAP)
					return CFrame.lookAt(attackPosition, rootPosition)
				end
				return CFrame.lookAt(rootPosition - targetRoot.CFrame.LookVector * TARGET_DISTANCE, rootPosition)
			end
			if displaced and not oversized then step = step == 1 and 5 or step - 1 end
			local normal, extent
			if step == 1 then normal, extent = targetPart.CFrame.RightVector, size.X * 0.5
			elseif step == 2 then normal, extent = -targetPart.CFrame.RightVector, size.X * 0.5
			elseif step == 3 then normal, extent = -targetPart.CFrame.LookVector, size.Z * 0.5
			elseif step == 4 then normal, extent = targetPart.CFrame.LookVector, size.Z * 0.5 end
			if normal and extent then
				local attackPosition = targetPosition + normal * (extent + TARGET_SURFACE_GAP)
				return CFrame.lookAt(attackPosition, targetPosition)
			end
		end
		local direction = Vector3.new(targetRoot.CFrame.LookVector.X, 0, targetRoot.CFrame.LookVector.Z)
		if direction.Magnitude < 0.01 then direction = Vector3.zAxis else direction = direction.Unit end
		local attackPosition = targetPosition - ownOffset - direction * TARGET_DISTANCE
		return CFrame.lookAt(attackPosition, targetPosition)
	end


	local function stopMovementAnimation(humanoid)
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		if not animator then return end
		for _, animationTrack in ipairs(animator:GetPlayingAnimationTracks()) do
			local name = string.lower(animationTrack.Name)
			if string.find(name, "walk", 1, true) or string.find(name, "run", 1, true) then
				pcall(animationTrack.Stop, animationTrack, 0)
			end
		end
	end


	local function restoreKillMovement()
		local humanoid = getHumanoid()
		if not humanoid then return end
		humanoid:Move(Vector3.zero, false)
		if humanoid.WalkSpeed <= 0 then humanoid.WalkSpeed = State.kill.movementWalkSpeed or 16 end
		humanoid.AutoRotate = true
	end


	local function touchKill(player)
		if not player or player == LP or protectedTarget(player) then
			return false
		end
		local targetCharacter = player.Character
		local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildWhichIsA("Humanoid")
		local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
		if not targetHumanoid or targetHumanoid.Health <= 0 or not targetRoot or hasTargetProtection(targetCharacter) then
			return false
		end
		local startingHealth = targetHumanoid.Health
		local punch = equipPunch()
		if not punch then return false end
		RunService.Heartbeat:Wait()
		local deadline = os.clock() + TARGET_ATTACK_WINDOW
		local hit = false
		local contactStep = 1
		local localHumanoid = getHumanoid()
		if localHumanoid then
			localHumanoid:Move(Vector3.zero, false)
			stopMovementAnimation(localHumanoid)
		end

		while State.running and os.clock() < deadline do
			if State.kill.brawlCombat then
				if not isInsideBrawl(LP) or not isInBrawlBattle(LP)
					or not isInsideBrawl(player) or not isInBrawlBattle(player) then
					break
				end
			elseif State.kill.targetMode then
				if State.kill.target ~= player.Name then break end
			elseif not State.kill.auto and State.kill.karmaMode == nil then
				break
			end
			targetCharacter = player.Character
			targetHumanoid = targetCharacter and targetCharacter:FindFirstChildWhichIsA("Humanoid")
			targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
			if not targetHumanoid or targetHumanoid.Health <= 0 or not targetRoot or hasTargetProtection(targetCharacter) then break end
			local character = getCharacter()
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not root then break end
			if localHumanoid then
				localHumanoid:Move(Vector3.zero, false)
				stopMovementAnimation(localHumanoid)
			end
			State.kill.combatCFrame = getAttackCFrame(character, root, targetCharacter, targetRoot, contactStep)
			character:PivotTo(State.kill.combatCFrame)
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			RunService.Heartbeat:Wait()
			targetCharacter = player.Character
			targetHumanoid = targetCharacter and targetCharacter:FindFirstChildWhichIsA("Humanoid")
			targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
			if not targetHumanoid or targetHumanoid.Health <= 0 or not targetRoot
				or hasTargetProtection(targetCharacter) then break end
			if State.kill.brawlCombat and (not isInsideBrawl(player) or not isInBrawlBattle(player)) then break end
			if (root.Position - State.kill.combatCFrame.Position).Magnitude > 0.35 then
				character:PivotTo(State.kill.combatCFrame)
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
				RunService.Heartbeat:Wait()
			end
			if punch.Parent ~= character then punch = equipPunch() end
			if punch then
				pcall(punch.Deactivate, punch)
				RunService.Heartbeat:Wait()
				pcall(punch.Activate, punch)
				task.wait(TARGET_UPDATE_INTERVAL)
				pcall(punch.Deactivate, punch)
			end
			hit = targetHumanoid.Health < startingHealth
			contactStep = contactStep + 1
			task.wait()
		end

		State.kill.combatCFrame = nil
		if punch then pcall(punch.Deactivate, punch) end
		local root = getRoot()
		if root and State.kill.lockCFrame then
			root.CFrame = State.kill.lockCFrame
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
		local defeated = targetHumanoid and targetHumanoid.Health <= 0
		if hit or defeated then
			State.kill.targetRetryAt[player.UserId] = nil
		elseif not State.kill.targetMode then
			State.kill.targetRetryAt[player.UserId] = os.clock() + TARGET_RETRY_DELAY
		end
		return hit or defeated or false
	end


	local function matchesKarma(player, mode)
		if not mode then
			return true
		end
		local good = getPlayerStat(player, { "goodKarma", "Good Karma" })
		local evil = getPlayerStat(player, { "evilKarma", "Evil Karma" })
		local goodValue = tonumber(good and State.getFunctionalStatValue(good)) or 0
		local evilValue = tonumber(evil and State.getFunctionalStatValue(evil)) or 0
		if mode == "evil" then
			return goodValue > evilValue
		elseif mode == "good" then
			return evilValue > goodValue
		end
		return false
	end


	local function massKillEnabled()
		return State.kill.auto or State.kill.karmaMode ~= nil
	end


	local function autoKillTargets()
		local targets = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LP and not protectedTarget(player) and matchesKarma(player, State.kill.karmaMode) then
				local character = player.Character
				local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
				local root = character and character:FindFirstChild("HumanoidRootPart")
				local retryAt = State.kill.targetRetryAt[player.UserId]
				if humanoid and humanoid.Health > 0 and root and not hasTargetProtection(character)
					and (not retryAt or os.clock() >= retryAt) then
					targets[#targets + 1] = { player = player, health = humanoid.Health }
				end
			end
		end
		table.sort(targets, function(a, b)
			return a.health < b.health
		end)
		return targets
	end


	local function brawlTargets()
		local targets = {}
		local added = {}
		if not State.kill.brawlCombat or not isInsideBrawl(LP) or not isInBrawlBattle(LP) then
			return targets
		end

		local function add(player)
			if not player or player == LP or added[player.UserId] or protectedTarget(player) then return end
			local character = player.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not humanoid or humanoid.Health <= 0 or not root or not isInsideBrawl(player)
				or not isInBrawlBattle(player) or hasTargetProtection(character) then return end
			added[player.UserId] = true
			targets[#targets + 1] = { player = player, health = humanoid.Health }
		end
		add(State.kill.brawlChosen)
		for _, player in ipairs(Players:GetPlayers()) do add(player) end
		table.sort(targets, function(a, b)
			if a.player == State.kill.brawlChosen then return true end
			if b.player == State.kill.brawlChosen then return false end
			return a.health < b.health
		end)
		return targets
	end


	local function refreshKillLoop()
		stopThread("killFarm")
		local normalEnabled = not State.kill.brawlBusy and (massKillEnabled() or State.kill.targetMode)
		if not State.kill.brawlCombat and not normalEnabled then
			restorePunch()
			return
		end
		startThread("killFarm", function()
			while State.running do
				if State.kill.brawlCombat then
					local targets = brawlTargets()
					for _, target in ipairs(targets) do
						if not State.running or not State.kill.brawlCombat then break end
						touchKill(target.player)
					end
				elseif State.kill.brawlBusy then
					break
				elseif State.kill.targetMode then
					touchKill(State.kill.target and Players:FindFirstChild(State.kill.target))
				elseif massKillEnabled() then
					local targets = autoKillTargets()
					for _, target in ipairs(targets) do
						if not State.running or not massKillEnabled() then
							break
						end
						touchKill(target.player)
					end
					if State.kill.serverHop then
						if #targets == 0 then
							State.kill.noTargetsSince = State.kill.noTargetsSince or time()
							if time() - State.kill.noTargetsSince >= CONFIG.ServerHop.NoTargetsDelay then
								State.kill.hopNow = true
							end
						else
							State.kill.noTargetsSince = nil
						end
					end
				else
					break
				end
				task.wait()
			end
			restorePunch()
		end)
	end


	local function getTeleportQueue()
		local environment = getgenv and getgenv() or _G
		local queue = environment.queue_on_teleport or environment.queueonteleport
			or queue_on_teleport or queueonteleport
		if type(queue) == "function" then
			return queue
		end
		local synApi = environment.syn
		if type(synApi) == "table" and type(synApi.queue_on_teleport) == "function" then
			return synApi.queue_on_teleport
		end
		local fluxusApi = environment.fluxus
		if type(fluxusApi) == "table" and type(fluxusApi.queue_on_teleport) == "function" then
			return fluxusApi.queue_on_teleport
		end
		return nil
	end


	local function serverWasVisited(serverId)
		return table.find(State.kill.serverHistory, serverId) ~= nil
	end


	local function rememberServer(serverId)
		if not serverWasVisited(serverId) then
			State.kill.serverHistory[#State.kill.serverHistory + 1] = serverId
		end
		while #State.kill.serverHistory > CONFIG.ServerHop.HistoryLimit do
			table.remove(State.kill.serverHistory, 1)
		end
	end


	local function killHttpGet(url)
		local environment = getgenv and getgenv() or _G
		local requestFunction = environment.request
			or environment.http_request
			or (type(environment.syn) == "table" and environment.syn.request)
		if type(requestFunction) == "function" then
			local requestOk, response = pcall(requestFunction, {
				Url = url,
				Method = "GET",
				Headers = { ["cache-control"] = "no-store" },
			})
			local body = type(response)=="table" and (response.Body or response.body) or (type(response)=="string" and response)
			if requestOk and type(body) == "string" then
				return true, body
			end
		end
		return pcall(game.HttpGet, game, url, true)
	end


	local function serverScore(server, mode)
		local playing = tonumber(server.playing) or 0
		local maximum = math.max(1, tonumber(server.maxPlayers) or 20)
		local ping = tonumber(server.ping)
		local fps = tonumber(server.fps)
		if mode == "solo" then return (playing > 2 and 100000 or 0) + math.abs(playing - 1) * 100 + (ping or 0) end
		if mode == "balanced" then return math.abs(playing - math.min(10, maximum - 1)) * 100 + (ping or 0) end
		if mode == "ping" then return (ping or (fps and math.max(0, 60 - fps) * 20) or 500) + playing * 2 end
		if mode == "king" then return playing * 120 + (ping or 0) end
		return (playing < 18 and 100000 or 0) + math.abs(playing - math.min(18, maximum - 1)) * 100 + (ping or 0)
	end

    local function findPublicServer(allowVisited)
        local mode=State.kill.serverHopMode or "full"
        local now=os.clock()
        local cache=State.kill.serverCache
        local failed=State.kill.failedServers or {}
        State.kill.failedServers=failed
        local function choose(list)
            for _,server in ipairs(list) do
                if server.id~=game.JobId and (allowVisited or not serverWasVisited(server.id))
                    and (failed[server.id] or 0)<=os.clock() then
                    State.kill.serverCandidate=server
                    return server.id,server
                end
            end
        end
        if cache and cache.mode==mode and now-cache.at<30 then
            local id,server=choose(cache.list)
            if id then return id,server end
        end
        if State.kill.serverSearchBusy then State.kill.serverError="La búsqueda sigue en curso."; return nil end
        if now<(State.kill.serverRetryAt or 0) then
            State.kill.serverError="Roblox pidió esperar. Reintentá en "..math.ceil(State.kill.serverRetryAt-now).."s."
            return nil
        end
        State.kill.serverSearchBusy=true
        State.kill.serverError=nil
        local candidates,seen={},{}
        local ok,err=pcall(function()
            local httpService=game:GetService("HttpService")
            local cursor=nil
            local ascending=mode=="solo" or mode=="king"
            for page=1,6 do
                if not State.running then break end
                local url=string.format(CONFIG.ServerHop.ServerApi,game.PlaceId)
                url=url:gsub("sortOrder=%w+","sortOrder="..(ascending and "Asc" or "Desc"))
                if cursor then url=url.."&cursor="..httpService:UrlEncode(cursor) end
                local requestOk,body=killHttpGet(url)
                if not requestOk or type(body)~="string" then error("No se pudo consultar Roblox.") end
                local decoded,response=pcall(httpService.JSONDecode,httpService,body)
                if not decoded or type(response)~="table" then error("Roblox devolvió una respuesta incompleta.") end
                if type(response.data)~="table" then
                    State.kill.serverRetryAt=os.clock()+12
                    error("Roblox limitó la búsqueda. Esperá unos segundos.")
                end
                for _,server in ipairs(response.data) do
                    local n=tonumber(server.playing)
                    local maximum=tonumber(server.maxPlayers)
                    local eligible=n and maximum and n<maximum and n>=1
                    if eligible then
                        eligible=(mode=="full" and n>=math.min(18,maximum-1))
                            or (mode=="solo" and n<=2) or (mode=="king" and n<=2)
                            or (mode=="balanced" and n>=8 and n<=14) or mode=="ping"
                    end
                    if eligible and type(server.id)=="string" and server.id~=game.JobId and not seen[server.id] then
                        seen[server.id]=true
                        candidates[#candidates+1]=server
                    end
                end
                cursor=response.nextPageCursor
                if not cursor or #candidates>=12 then break end
                task.wait(.35)
            end
            table.sort(candidates,function(a,b)
                local first,second=serverScore(a,mode),serverScore(b,mode)
                if first==second then return a.id<b.id end
                return first<second
            end)
        end)
        State.kill.serverSearchBusy=false
        if not ok then State.kill.serverError=tostring(err):gsub("^.-:%d+: ","") end
        State.kill.serverCandidates=candidates
        State.kill.serverCache={mode=mode,at=os.clock(),list=candidates}
        local id,server=choose(candidates)
        if not id then
            State.kill.serverCandidate=nil
            State.kill.serverError=State.kill.serverError or "No hay candidatos con ese filtro en este momento."
        end
        return id,server
    end

	State.findPublicServer = findPublicServer


	local function queueResume(queue, serverId, resumeData)
		local httpService = game:GetService("HttpService")
		rememberServer(serverId)
		resumeData = resumeData or {}
		resumeData.script = "fg100.lua"
        resumeData.afkSession=State.afkSnapshot and State.afkSnapshot() or nil
        resumeData.sessionBrawls=State.kill.sessionBrawls
		resumeData.language=State.language
		resumeData.fastMode=FastFarm.mode
		resumeData.packMode=FastFarm.packMode
		resumeData.afkMode=State.afk.active and State.afk.mode or nil
		resumeData.serverHistory = State.kill.serverHistory
		resumeData.serversVisited = State.kill.serversVisited + 1
		resumeData.outputEntries = {}
		for index = 1, math.min(50, #State.outputEntries) do
			resumeData.outputEntries[index] = State.outputEntries[index]
		end
		local snapshot = httpService:JSONEncode(resumeData)
		local loader="loadstring(game:HttpGet(" .. string.format("%q",CONFIG.ServerHop.LoaderUrl) .. ",true))()"
        if Env.Young0xFG100LocalBuild then
            local localFile=Env.Young0xFG100LocalFile
            if type(localFile)=="string" and localFile~="" then
                loader="local p="..string.format("%q",localFile).."; assert(type(readfile)==\"function\",\"readfile no disponible\"); env.Young0xFG100LocalFile=p; local s=readfile(p); assert(loadstring(s))()"
            else
                local source=Env.Young0xFG100LocalSource
                if type(source)~="string" or #source<10000 then return false end
                loader="env.Young0xFG100LocalSource="..string.format("%q",source).."; assert(loadstring(env.Young0xFG100LocalSource))()"
            end
        end
        local queuedSource = table.concat({
			"repeat task.wait() until game:IsLoaded()",
			"local env = getgenv and getgenv() or _G",
			"if game.JobId ~= "..string.format("%q",serverId).." then return end",
			"if env.__Young0xHopJob == game.JobId then return end",
			"env.__Young0xHopJob = game.JobId",
			"local ok,err=pcall(function()",
			"env.Young0xFG100Resume = game:GetService('HttpService'):JSONDecode(" .. string.format("%q", snapshot) .. ")",
			loader,
			"end)",
			"if not ok then env.__Young0xHopJob=nil; error(err,0) end",
		}, "\n")
		local ok,accepted=pcall(queue,queuedSource)
        return ok and accepted~=false
	end


	local function queueServerResume(queue, serverId)
		updateKillSession(currentKillsTotal())
		local controls, selectors = {}, {}
		for key, control in pairs(State.profileControls) do
			if type(control) == "table" and type(control.Get) == "function" then
				local ok, value = pcall(control.Get, control)
				if ok and (type(value) == "boolean" or type(value) == "string" or type(value) == "number") then controls[key] = value end
			end
		end
		for key, control in pairs(State.selectorControllers) do
			if type(control) == "table" and type(control.Get) == "function" then
				local ok, value = pcall(control.Get, control)
				if ok and (type(value) == "string" or type(value) == "number") then selectors[key] = value end
			end
		end
		return queueResume(queue, serverId, {
			tab = State.currentTab or "Server Hop",
			autoKill = State.kill.auto,
			autoWinBrawl = State.kill.autoWinBrawl,
			karmaMode = State.kill.karmaMode,
			protectFriends = State.kill.protectFriends,
			serverHop = State.kill.serverHop,
			serverHopInterval = State.kill.serverHopInterval,
			serverHopMode = State.kill.serverHopMode,
			hopOnDeath = State.kill.hopOnDeath,
			avoidKillers = State.kill.avoidKillers,
			claimKing = State.kill.claimKing,
			themeName = State.themeName,
			controls = controls,
			selectors = selectors,
			killSessionActive = State.kill.killSessionActive,
			sessionKills = State.kill.sessionKills,
			sessionStartKills = State.kill.sessionStartKills,
			killSessionElapsed = State.getKillSessionElapsed and State.getKillSessionElapsed() or 0,
		})
	end


    local function performServerHop()
        if State.rewardsBusy or State.chestClaimBusy then return false,"Esperá a que termine de reclamar las recompensas." end
        if State.kill.teleportDispatching then return false,"Ya hay un cambio en curso." end
        local pending=State.kill.teleportPending
        State.kill.failedServers=State.kill.failedServers or {}
        if pending then
            if os.clock()-pending.at<18 then return false,"Ya hay un cambio en curso." end
            State.kill.failedServers[pending.id]=os.clock()+60
            State.kill.teleportPending=nil
        end
        State.kill.teleportDispatching=true
        local callOk,accepted,detail=pcall(function()
        local queue=getTeleportQueue()
        if not queue then return false,"Tu executor no permite mantener el script al cambiar." end
        local serverId,candidate=findPublicServer(false)
        if not serverId then serverId,candidate=findPublicServer(true) end
        if not serverId then return false,State.kill.serverError or "No encontré otro servidor disponible." end
        if State.rewardsBusy or State.chestClaimBusy then return false,"Esperá a que termine de reclamar las recompensas." end
        if not queueServerResume(queue,serverId) then return false,"No se pudo preparar la reconexión." end
        State.kill.teleportPending={id=serverId,at=os.clock()}
        State.kill.teleportError=nil
        local ok,message=pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,serverId,LP) end)
        if not ok then
            State.kill.teleportPending=nil
            State.kill.failedServers[serverId]=os.clock()+60
            State.kill.teleportError=tostring(message)
            State.pushOutput("ERROR","Server Hop: "..tostring(message):sub(1,180))
            return false,"Roblox rechazó el cambio. Volvé a intentarlo."
        end
        State.pushOutput("SERVER","Conectando a "..tostring(candidate.playing).."/"..tostring(candidate.maxPlayers).." jugadores")
        return true
        end)
        State.kill.teleportDispatching=false
        if not callOk then
            State.kill.teleportPending=nil
            State.pushOutput("ERROR","Server Hop: "..tostring(accepted):sub(1,180))
            return false,"No se pudo cambiar de servidor"
        end
        return accepted,detail
    end

	local function kingIsFree()
		local kingPosition = Vector3.new(-8646, 13.25, -5738)
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LP then
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
				if root and humanoid and humanoid.Health > 0 and (root.Position - kingPosition).Magnitude <= 45 then return false, player end
			end
		end
		return true, nil
	end

	local function serverGoalMet()
		local count = #Players:GetPlayers()
		local mode = State.kill.serverHopMode or "full"
		if mode == "solo" then return count <= 2, "Servidor solitario listo" end
		if mode == "balanced" then return count >= 8 and count <= 14, "Servidor equilibrado listo" end
		if mode == "king" then
			local free = kingIsFree()
			if free and State.kill.claimKing then
                local root=getRoot()
                if root and (root.Position-Vector3.new(-8646,16.4,-5738)).Magnitude>12 then root.CFrame=CFrame.new(-8646,16.4,-5738) end
            end
			return free, free and "King libre en este servidor" or "King ocupado"
		end
		if mode == "full" then return count >= 18, "Servidor lleno listo" end
		return getPing() <= 150, getPing() <= 150 and "Latencia dentro del objetivo (150 ms)" or "Buscando mejor latencia"
	end

	State.kingIsFree = kingIsFree
	State.serverGoalMet = serverGoalMet
	State.performServerHop = performServerHop
	State.previewServerHop = function()
		local _, server = findPublicServer(false)
		if not server then _, server = findPublicServer(true) end
		return server
	end
	State.requestServerHop = function()
		if State.kill.hopInProgress or (State.kill.teleportPending and os.clock()-State.kill.teleportPending.at<18) then return false,"Ya hay un cambio en curso." end
		if State.kill.serverHop then State.kill.forceHopReason = "Cambio manual solicitado"; return true end
		State.kill.hopInProgress = true
		local ok, message = performServerHop()
		State.kill.hopInProgress = false
		return ok, message
	end
	State.playerLooksDangerous = function(player)
		if not player or player == LP then return false end
		local theirs = getPlayerStat(player, { "Kills" })
		local mine = getPlayerStat(LP, { "Kills" })
		local theirKills = tonumber(theirs and theirs.Value) or 0
		local myKills = tonumber(mine and mine.Value) or 0
		return theirKills >= math.max(5000, myKills * 1.15)
	end
	State.killerInServer = function()
		for _, player in ipairs(Players:GetPlayers()) do if State.playerLooksDangerous(player) then return player end end
		return nil
	end


	local function updateHopStatus(seconds, message)
		if type(State.kill.updateHopStatus) == "function" then
			pcall(State.kill.updateHopStatus, seconds, message)
		end
	end


	State.setServerHop = function(enabled)
		if enabled and (State.kill.targetMode or not getTeleportQueue()) then
			return false
		end
		State.kill.serverHop = enabled == true
		State.kill.hopNow = false
		State.kill.noTargetsSince = nil
		stopThread("killServerHop")
		if State.kill.serverHop then
			startThread("killServerHop", function()
				local startedAt = os.clock()
				while State.running and State.kill.serverHop do
					repeat
					if State.kill.brawlBusy then
						updateHopStatus(nil,"Esperando que termine la pelea...")
						task.wait(1)
						break
					end
					local interval = State.kill.serverHopInterval or CONFIG.ServerHop.Interval
					local remaining = math.max(0, math.ceil(interval - (os.clock() - startedAt)))
					local reason = State.kill.forceHopReason
					if not reason and State.kill.avoidKillers then local killer = State.killerInServer(); if killer then reason = killer.DisplayName .. " parece peligroso. Cambiando..." end end
					if not reason and State.kill.hopNow then reason = "Sin objetivos. Buscando otro servidor..." end
					if not reason and massKillEnabled() and #Players:GetPlayers() < 10 then
						reason = "Servidor con pocos jugadores..."
					end
					if not reason and massKillEnabled() and os.clock() - State.kill.lastKillAt >= 18 then
						reason = "Sin kills. Buscando otro servidor..."
					end
					if not reason and not massKillEnabled() and not State.kill.autoWinBrawl then
						local reached, status = serverGoalMet()
						if reached then startedAt = os.clock(); updateHopStatus(nil, status); task.wait(1); break end
					end
					if not reason and remaining <= 0 then reason = "Cambiando de servidor..." end
					if not reason then
						updateHopStatus(remaining)
						task.wait(1)
						break
					end
					State.kill.hopNow = false
					State.kill.forceHopReason = nil
					State.kill.hopInProgress = true
					updateHopStatus(0, reason)
					local ok, message = performServerHop()
					if ok then
						updateHopStatus(0, "Conectando...")
						for _ = 1, 24 do
							if not State.running or not State.kill.serverHop or State.kill.forceHopReason then break end
							task.wait(0.5)
						end
					else
						updateHopStatus(0, message or "Reintentando...")
						State.kill.forceHopReason = reason
						task.wait(12)
					end
					State.kill.hopInProgress = false
					until true
				end
			end)
		else
			State.kill.hopRetrying = false
			State.kill.hopInProgress = false
			State.kill.forceHopReason = nil
			updateHopStatus(nil)
		end
		return true
	end

    track(game:GetService("TeleportService").TeleportInitFailed:Connect(function(player,result,message)
        if player~=LP or not State.running then return end
        local pending=State.kill.teleportPending
        if pending then State.kill.failedServers[pending.id]=os.clock()+90 end
        State.kill.teleportPending=nil
        State.kill.hopInProgress=false
        State.kill.teleportError=tostring(result)..": "..tostring(message)
        State.pushOutput("ERROR","Server Hop: "..State.kill.teleportError:sub(1,180))
        local text="Roblox no pudo conectar. Buscando otro candidato..."
        if State.kill.serverHop then State.kill.forceHopReason=text end
        updateHopStatus(nil,text)
    end))

	local deathWatcherHumanoid = nil
	local deathWatcherConnection = nil
	local function watchKillDeath(character)
		if not character or not State.running then return end
		task.spawn(function()
			local humanoid = character:FindFirstChildOfClass("Humanoid")
				or character:WaitForChild("Humanoid", 10)
			if not humanoid or not humanoid:IsA("Humanoid") or not State.running then return end
			if deathWatcherHumanoid == humanoid then return end
			if deathWatcherConnection then
				untrack(deathWatcherConnection)
				deathWatcherConnection = nil
			end
			deathWatcherHumanoid = humanoid
			deathWatcherConnection = track(humanoid.Died:Connect(function()
				if not State.running then return end
				local enabledControls = {}
				for key, control in pairs(State.profileControls or {}) do
					if type(control) == "table" and control.ProfileKind == "toggle"
						and type(control.Get) == "function" then
						local ok, value = pcall(control.Get, control)
						if ok and value == true then
							enabledControls[#enabledControls + 1] = { key = key }
						end
					end
				end
				table.sort(enabledControls, function(a, b) return a.key < b.key end)
				local afkSnapshot
				if type(State.afkSnapshot) == "function" then
					local ok, value = pcall(State.afkSnapshot)
					if ok then afkSnapshot = value end
				end
				local fastMode = not afkSnapshot and FastFarm and FastFarm.mode or nil
				local momentumMode = not afkSnapshot and not fastMode and FastFarm
					and FastFarm.PetMomentum and FastFarm.PetMomentum.mode or nil
				State.deathResumeSnapshot = {
					character = character,
					controls = enabledControls,
					afk = afkSnapshot,
					fastMode = fastMode,
					momentumMode = momentumMode,
					capturedAt = os.clock(),
				}
				State.pushOutput("SYSTEM", "Respawn recovery queued for " .. tostring(#enabledControls) .. " toggles")
				if State.kill and State.kill.hopOnDeath then
					task.delay(0.8, function()
						if State.running and State.kill and State.kill.hopOnDeath
							and type(State.requestServerHop) == "function" then
							pcall(State.requestServerHop)
						end
					end)
				end
			end))
		end)
	end
	track(LP.CharacterAdded:Connect(watchKillDeath))
	if LP.Character then task.defer(watchKillDeath, LP.Character) end


	local function refreshKillSizeSupport()
		stopThread("killSizeOne")
		if not massKillEnabled() and not State.kill.targetMode and not State.kill.brawlCombat then
			return
		end
		if type(FastFarm.SetSizeOne) == "function" then
			FastFarm.SetSizeOne()
		end
		startThread("killSizeOne", function()
			while State.running and (massKillEnabled() or State.kill.targetMode or State.kill.brawlCombat) do
				if type(FastFarm.SetSizeOne) == "function" then
					FastFarm.SetSizeOne()
				end
				task.wait(0.5)
			end
		end)
	end


	local function stopKillPositionLock()
		stopThread("killPositionLock")
		State.kill.combatCFrame = nil
		State.kill.lockCFrame = nil
		State.kill.lockCharacter = nil
		restoreKillMovement()
	end


	local function stopKillPunchAnimation()
		stopThread("killPunchAnimation")
		if State.fastPunch then return end
		pcall(function()
			local character = getCharacter()
			local backpack = LP:FindFirstChild("Backpack")
			local punch = (character and character:FindFirstChild("Punch"))
				or (backpack and backpack:FindFirstChild("Punch"))
			local attackTime = punch and punch:FindFirstChild("attackTime")
			if attackTime then attackTime.Value = 0.3 end
		end)
	end


	local function startKillPositionLock()
		stopKillPositionLock()
		local character = getCharacter()
		local root = getRoot()
		if character and root then
			State.kill.lockCharacter = character
			State.kill.lockCFrame = root.CFrame
		end
		startThread("killPositionLock", function()
			while State.running and massKillEnabled() and not State.kill.brawlBusy do
				local currentCharacter = getCharacter()
				local currentRoot = getRoot()
				if currentCharacter and currentRoot then
					if State.kill.lockCharacter ~= currentCharacter or not State.kill.lockCFrame then
						State.kill.lockCharacter = currentCharacter
						State.kill.lockCFrame = currentRoot.CFrame
					end
					currentRoot.CFrame = State.kill.combatCFrame or State.kill.lockCFrame
					currentRoot.AssemblyLinearVelocity = Vector3.zero
					currentRoot.AssemblyAngularVelocity = Vector3.zero
				end
				RunService.Heartbeat:Wait()
			end
		end)
	end


	local function restoreBrawlPositionAndMovement()
		local character = getCharacter()
		local root = getRoot()
		if character and root and typeof(State.kill.brawlReturnCFrame) == "CFrame" then
			pcall(character.PivotTo, character, State.kill.brawlReturnCFrame)
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
		local humanoid = getHumanoid()
		local movement = State.kill.brawlMovement
		if humanoid and type(movement) == "table" then
			pcall(function()
				humanoid.WalkSpeed = movement.walkSpeed
				humanoid.AutoRotate = movement.autoRotate
				if movement.usesJumpPower then
					humanoid.JumpPower = movement.jumpValue
				else
					humanoid.JumpHeight = movement.jumpValue
				end
			end)
		end
		State.kill.brawlReturnCFrame = nil
		State.kill.brawlMovement = nil
		restoreKillMovement()
	end


	local function restoreAfterBrawl()
		State.kill.brawlPhase = "IDLE"
		State.kill.brawlBusy = false
		State.kill.brawlCombat = false
		State.kill.brawlJoined = false
		State.kill.brawlJoinSent = false
		State.kill.brawlChosen = nil
		State.kill.lastKillAt = os.clock()
		State.kill.forceHopReason = nil
		restoreBrawlPositionAndMovement()
		refreshKillSizeSupport()
		refreshKillLoop()
		if massKillEnabled() then
			startKillPositionLock()
		else
			restoreKillMovement()
		end
	end


	local function finishBrawlCycle()
		if not State.kill.brawlBusy and State.kill.brawlPhase == "IDLE" then return end
		State.kill.brawlPhase = "RESTORING"
		State.kill.brawlCombat = false
		State.kill.brawlChosen = nil
		State.kill.combatCFrame = nil
		refreshKillSizeSupport()
		refreshKillLoop()
		stopThread("killBrawlRestore")
		startThread("killBrawlRestore", function()
			local exitDeadline = os.clock() + 15
			while State.running and isInsideBrawl(LP) do
				if BrawlState:GetAttribute("BrawlInProgress") ~= true and os.clock() >= exitDeadline then break end
				task.wait(0.25)
			end
			if State.running then
				local wins = currentBrawlWins()
				State.kill.lastBrawlWon = wins ~= nil and State.kill.brawlBaselineWins ~= nil
					and wins > State.kill.brawlBaselineWins
				restoreAfterBrawl()
                if State.kill.autoWinBrawl and State.kill.serverHop and not massKillEnabled() then
                    State.kill.forceHopReason=State.kill.lastBrawlWon and "Victoria confirmada. Buscando otra pelea..." or "Pelea terminada. Buscando otra..."
                end
			end
		end)
	end


	local function prepareBrawlCycle()
		if not State.kill.brawlBusy then
			State.kill.brawlBaselineWins = currentBrawlWins()
			local root = getRoot()
			local humanoid = getHumanoid()
			State.kill.brawlReturnCFrame = root and root.CFrame or nil
			State.kill.brawlMovement = humanoid and {
				walkSpeed = humanoid.WalkSpeed,
				autoRotate = humanoid.AutoRotate,
				usesJumpPower = humanoid.UseJumpPower,
				jumpValue = humanoid.UseJumpPower and humanoid.JumpPower or humanoid.JumpHeight,
			} or nil
		end
		State.kill.brawlBusy = true
		State.kill.brawlCombat = false
		State.kill.brawlJoined = isInsideBrawl(LP)
		State.kill.brawlChosen = nil
		State.kill.brawlPhase = State.kill.brawlJoined and "WAITING" or "JOINING"
		State.kill.forceHopReason = nil
		stopKillPositionLock()
		refreshKillLoop()
	end


	local function beginBrawlCombat()
		if not State.kill.autoWinBrawl or not isInsideBrawl(LP) then return false end
		if not State.kill.brawlBusy then prepareBrawlCycle() end
		State.kill.brawlJoined = true
		State.kill.brawlCombat = true
		State.kill.brawlPhase = "FIGHTING"
		State.kill.brawlChosen = nil
		stopKillPositionLock()
		refreshKillSizeSupport()
		refreshKillLoop()
		return true
	end


	local function tryJoinBrawl()
		if not State.kill.autoWinBrawl or State.kill.brawlJoinSent
			or BrawlState:GetAttribute("BrawlInProgress") ~= true
			or BrawlState:GetAttribute("BrawlStarted") == true then
			return false
		end
		prepareBrawlCycle()
		if type(FastFarm.SetSizeOne) == "function" then FastFarm.SetSizeOne() end
		State.kill.brawlJoinSent = true
		local joined = pcall(BrawlEvent.FireServer, BrawlEvent, "joinBrawl")
		if not joined then
			State.kill.brawlJoinSent = false
			finishBrawlCycle()
			return false
		end
		return true
	end


	State.setAutoWinBrawl = function(enabled)
		State.kill.autoWinBrawl = enabled == true
		if not State.kill.autoWinBrawl then
			if State.kill.brawlBusy then finishBrawlCycle() else restoreAfterBrawl() end
			stopKillSessionIfIdle()
			return true
		end
		startKillSession()
		if BrawlState:GetAttribute("BrawlStarted") == true then
			beginBrawlCombat()
		elseif brawlPromptVisible() then
			tryJoinBrawl()
		end
		return true
	end

	track(BrawlEvent.OnClientEvent:Connect(function(action, ...)
		if not State.running or not State.kill.autoWinBrawl then return end
		if action == "brawlStarting" then
			State.kill.brawlJoinSent = false
			task.defer(tryJoinBrawl)
		elseif action == "joinedBrawl" then
			if not State.kill.brawlBusy then prepareBrawlCycle() end
			State.kill.brawlJoined = true
			State.kill.brawlPhase = "WAITING"
		elseif action == "beginBrawl" then
			beginBrawlCombat()
		elseif action == "playerChosen" then
			local chosen = select(1, ...)
			if typeof(chosen) == "Instance" and chosen:IsA("Player")
				and chosen ~= LP and isInBrawlBattle(LP) then
				State.kill.brawlChosen = chosen
			else
				State.kill.brawlChosen = nil
			end
		elseif action == "noOtherBrawlers" or action == "endBrawl" then
			finishBrawlCycle()
		end
	end))

	track(BrawlState:GetAttributeChangedSignal("BrawlStarted"):Connect(function()
		if not State.running or not State.kill.autoWinBrawl then return end
		if BrawlState:GetAttribute("BrawlStarted") == true then
			beginBrawlCombat()
		elseif BrawlState:GetAttribute("BrawlInProgress") ~= true then
			finishBrawlCycle()
		end
	end))

	track(BrawlState:GetAttributeChangedSignal("BrawlInProgress"):Connect(function()
		if not State.running or not State.kill.autoWinBrawl then return end
		if BrawlState:GetAttribute("BrawlInProgress") ~= true and State.kill.brawlBusy then
			finishBrawlCycle()
		end
	end))

	State.killBrawlPromptVisible = brawlPromptVisible
	State.killTryJoinBrawl = tryJoinBrawl


	State.setAutoKill = function(enabled)
		if enabled and killsBlockedHere() then
			return false
		end
		if enabled then
			startKillSession()
			State.kill.lastKillAt = os.clock()
			local humanoid = getHumanoid()
			if humanoid and humanoid.WalkSpeed > 0 then State.kill.movementWalkSpeed = humanoid.WalkSpeed end
		end
		State.kill.auto = enabled == true
		if State.kill.auto and not State.kill.brawlBusy then
			State.kill.targetMode = false
			State.kill.karmaMode = nil
			startKillPositionLock()
		else
			stopKillPositionLock()
		end
		stopKillPunchAnimation()
		refreshKillSizeSupport()
		refreshFastPunch()
		refreshKillLoop()
		stopKillSessionIfIdle()
		return true
	end


	State.setTargetKill = function(enabled)
		local selectedTarget = State.kill.target and Players:FindFirstChild(State.kill.target)
		if enabled and (killsBlockedHere() or not selectedTarget or protectedTarget(selectedTarget)) then
			return false
		end
		State.kill.targetMode = enabled == true
		if State.kill.targetMode then
			startKillSession()
			State.kill.auto = false
			State.kill.karmaMode = nil
			stopKillPositionLock()
			stopKillPunchAnimation()
			State.setServerHop(false)
		elseif not massKillEnabled() then
			restoreKillMovement()
		end
		refreshKillSizeSupport()
		refreshFastPunch()
		refreshKillLoop()
		stopKillSessionIfIdle()
		return true
	end


	State.setKarmaKill = function(mode, enabled)
		if mode ~= "evil" and mode ~= "good" then
			return false
		end
		if enabled and killsBlockedHere() then
			return false
		end
		if enabled then
			startKillSession()
			State.kill.karmaMode = mode
		elseif State.kill.karmaMode == mode then
			State.kill.karmaMode = nil
		end
		if State.kill.karmaMode and not State.kill.brawlBusy then
			State.kill.auto = false
			stopKillPunchAnimation()
			State.kill.targetMode = false
			startKillPositionLock()
		else
			stopKillPositionLock()
			stopKillPunchAnimation()
		end
		refreshKillSizeSupport()
		refreshFastPunch()
		refreshKillLoop()
		stopKillSessionIfIdle()
		return true
	end


	State.setProtectFriends = function(enabled)
		State.kill.protectFriends = enabled == true
		refreshKillFriendProtection()
		return true
	end


	State.clearKillFriend = function(player)
		if player then
			State.kill.friendCache[player.UserId] = nil
		end
	end


	State.stopKills = function()
		State.kill.auto = false
		State.kill.autoWinBrawl = false
		State.kill.karmaMode = nil
		State.kill.targetMode = false
		State.kill.serverHop = false
		stopThread("killFarm")
		stopThread("killSizeOne")
		stopThread("killFastPunch")
		stopThread("killFriendRefresh")
		stopKillPositionLock()
		stopKillPunchAnimation()
		stopThread("killServerHop")
		stopThread("killBrawlRestore")
		State.kill.brawlBusy = false
		State.kill.brawlCombat = false
		State.kill.brawlJoined = false
		State.kill.brawlJoinSent = false
		State.kill.brawlChosen = nil
		State.kill.brawlPhase = "IDLE"
		stopKillSessionIfIdle()
		updateHopStatus(nil)
		restorePunch()
	end
end

addCleanup(function()
	FastFarm:Stop(true)
	setFastPunch(false)
	setAutoRep("autoWeight", false)
	setAutoRep("autoHandstands", false)
	setAutoRep("autoLift", false)
	setAutoRep("autoSitups", false)
	State.autoLiftUnlocked = false
	LP:SetAttribute("AutoLiftEnabled", false)
	releaseNativeAutoLiftButton()
	State.setAutoEgg(false)
	setHideDurability(false)
	if type(State.stopDurabilityBurst) == "function" then
		State.stopDurabilityBurst()
	end
	setHideFrames(false)
	pcall(LP.SetAttribute, LP, "ShowPopups", State.originalShowPopups)
	setMachine(nil, false)
	setAntiLag(false, true)
	AntiCrash.set(false)
	setWalkWater(false)
	setAutoSpinWheel(false)
	setAutoClaimChests(false)
	setRemovePortals(false)
	setFastSpeed(false)
	setFly(false)
	State.setAntiKnockback(false)
	setNoclip(false)
	setSpin(false)
	setSpy(false)
	State.stopKills()
	State.autoPet = false
	State.autoAura = false
	stopThread("autoPet")
	stopThread("autoAura")
end)

do
	local oldGui = PlayerGui:FindFirstChild("FG100Hub")
	if oldGui then
		oldGui:Destroy()
	end
end


local function viewportSize()
	local camera = workspace.CurrentCamera
	return camera and camera.ViewportSize or Vector2.new(1280, 720)
end


local function getHubSize()
	local viewport = viewportSize()
	local mobile = viewport.X < 760 or (UserInputService.TouchEnabled and viewport.X < 1100)
	if mobile then
		return math.floor(math.clamp(viewport.X * CONFIG.Size.MobileWidthScale, CONFIG.Size.MinWidth, CONFIG.Size.MaxMobileWidth)),
			math.floor(math.clamp(viewport.Y * CONFIG.Size.MobileHeightScale, CONFIG.Size.MinHeight, CONFIG.Size.MaxMobileHeight))
	end
	return CONFIG.Size.DesktopWidth, CONFIG.Size.DesktopHeight
end

local hubWidth, hubHeight = getHubSize()
local HEADER_H = 54
local TAB_H = 40
local MIN_WIDTH = UserInputService.TouchEnabled and viewportSize().X < 1100 and 132 or 168
local MIN_HEIGHT = UserInputService.TouchEnabled and viewportSize().X < 1100 and 64 or 68

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FG100Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 1000
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
	ScreenGui.AutoLocalize = false
end)
ScreenGui:SetAttribute("Young0x", "0x")
ScreenGui:SetAttribute("FG100", "Young0x")
-- Keep the legacy visual tree as a hidden compatibility model during startup.
-- The visible window and every migrated control are rendered by Crefy instead.
ScreenGui.Enabled = false
ScreenGui.Parent = PlayerGui

local previousVisualGui = PlayerGui:FindFirstChild("FG100VisualLayer")
if previousVisualGui then pcall(function() previousVisualGui:Destroy() end) end
local VisualGui = Instance.new("ScreenGui")
VisualGui.Name = "FG100VisualLayer"
VisualGui.ResetOnSpawn = false
VisualGui.IgnoreGuiInset = true
VisualGui.DisplayOrder = 1001
VisualGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() VisualGui.AutoLocalize = false end)
VisualGui.Parent = PlayerGui
addCleanup(function()
	if VisualGui and VisualGui.Parent then VisualGui:Destroy() end
end)

do
	local EN = {
		["Jesús es el camino, la verdad y la vida"] = "Jesus is the way, the truth, and the life",
		["Dios Te ama ❤"] = "God loves you ❤",
		["PALABRA DE VIDA"] = "WORD OF LIFE",
		["Inventario"] = "Inventory",
		["Perfiles"] = "Profiles",
		["AFK 24/7"] = "AFK 24/7",
		["Server Hop"] = "Server Hop",
		["👤 Info Player 👤"] = "👤 Player Info 👤",
		["🌐 Info Server 🌐"] = "🌐 Server Info 🌐",
		["Juego:"] = "Game:",
		["Autor:"] = "Author:",
		["Link copiado"] = "Link copied",
		["Set Size (Máximo 100)"] = "Set Size (Maximum 100)",
		["Ejemplo: 2"] = "Example: 2",
		["Ejemplo: 800"] = "Example: 800",
		["Ejemplo: 1.000"] = "Example: 1,000",
		["Estadísticas visuales"] = "Visual stats",
		["Códigos"] = "Codes",
		["Canjear todos los códigos"] = "Redeem all codes",
		["Ocultar Durabilidad"] = "Hide Durability",
		["Fue lindo mientras duró, Rip pets bug 2019 - 2026 🥀."] = "It was fun while it lasted, RIP pets bug 2019 - 2026 🥀.",
		["Modo"] = "Mode",
		["🙈 Ocultar Frames 🙈"] = "🙈 Hide Pop-ups 🙈",
		["Requisito:"] = "Requirement:",
		["Muscle King actual"] = "Current Muscle King",
		["Tiempo:"] = "Time:",
		["Calculadora:"] = "Calculator:",
		["Calculadora de kills"] = "Kill calculator",
		["Kills aproximadas"] = "Estimated kills",
		["POR HORA"] = "PER HOUR",
		["POR DÍA"] = "PER DAY",
		["POR SEMANA"] = "PER WEEK",
		["Estado del sistema"] = "System status",
		["Historial de actividad"] = "Activity history",
		["Limpiar Output"] = "Clear Output",
		["Centro de control"] = "Control center",
		["Actividad en vivo"] = "Live activity",
		["ACTIVIDAD EN VIVO"] = "LIVE ACTIVITY",
		["Limpiar historial"] = "Clear history",
		["FG100 ONLINE"] = "FG100 ONLINE",
		["Elegí con qué pack querés farmear"] = "Choose which pack you want to farm with",
		["FG100 adapta la combinación y los slots automáticamente."] = "FG100 adapts the combination and slots automatically.",
		["Señores del Caos"] = "Chaos Lords",
		["Ultra Titanes"] = "Ultra Titans",
		["Seleccioná un pack para continuar."] = "Select a pack to continue.",
		["No tenés un pack compatible disponible."] = "You do not have a compatible pack available.",
		["Calibrando..."] = "Calibrating...",
		["Farmear Pet Momentum"] = "Farm Pet Momentum",
		["0/0 al máximo"] = "0/0 at max",
		["Contador de renas"] = "Rebirth counter",
		["Herramientas"] = "Tools",
		["Canjeando..."] = "Redeeming...",
		["No se pudo canjear"] = "Could not redeem",
		["Canjear 2K de Fuerza"] = "Redeem 2K Strength",
		["Código canjeado"] = "Code redeemed",
		["Código ya canjeado"] = "Code already redeemed",
		["Pesa rápida"] = "Fast Weight",
		["Objetivo de renacimientos"] = "Rebirth target",
		["Ejemplo: 18,980"] = "Example: 18,980",
		["Renacer hasta el objetivo"] = "Rebirth until target",
		["Renacimientos infinitos"] = "Infinite Rebirths",
		["Ultimates"] = "Ultimates",
		["Seleccionar Ultimate"] = "Select Ultimate",
		["Cantidad a comprar"] = "Amount to buy",
		["Nivel seleccionado"] = "Selected level",
		["Comprar Ultimate"] = "Buy Ultimate",
		["Cancelar compra"] = "Cancel purchase",
		["Máximo"] = "Maximum",
		["Esperando selección"] = "Waiting for selection",
		["Esperando compra"] = "Waiting for purchase",
		["Compra cancelada"] = "Purchase cancelled",
		["Ultimate al máximo"] = "Ultimate at max",
		["Server Hop inteligente"] = "Smart Server Hop",
		["Tipo de servidor"] = "Server type",
		["Lleno (18-19)"] = "Full (18-19)",
		["Solitario (1-2)"] = "Solo (1-2)",
		["Equilibrado (8-14)"] = "Balanced (8-14)",
		["Mejor latencia"] = "Best latency",
		["King libre"] = "Free King",
		["Analizar servidores"] = "Scan servers",
		["Cambiar de servidor ahora"] = "Change server now",
		["Mantener objetivo automáticamente"] = "Maintain target automatically",
		["Cambiar si me eliminan"] = "Change if I am eliminated",
		["Cambiar si entra un killer"] = "Change if a killer joins",
		["Jugadores:"] = "Players:",
		["Estado:"] = "Status:",
		["Sin analizar"] = "Not scanned",
		["MEMORIA"] = "MEMORY",
		["JUGADORES"] = "PLAYERS",
		["Reclamar King automáticamente"] = "Claim King automatically",
		["Mejor candidato:"] = "Best candidate:",
		["Listo para analizar"] = "Ready to scan",
		["No matar a mis amigos"] = "Do not kill my friends",
		["Seleccionar jugador"] = "Select player",
		["Matar jugador"] = "Kill player",
		["Seleccionar pet"] = "Select pet",
		["Pets por trade"] = "Pets per trade",
		["Iniciar Fast Trade"] = "Start Fast Trade",
		["Cancelar Fast Trade"] = "Cancel Fast Trade",
		["Regalos"] = "Gifts",
		["Enviar Regalos"] = "Send Gifts",
		["Jugador"] = "Player",
		["Cantidad de Eggs"] = "Egg amount",
		["Cantidad de Shakes"] = "Shake amount",
		["Seleccioná un jugador"] = "Select a player",
		["Envío en curso"] = "Sending",
		["Seleccionar Pet"] = "Select Pet",
		["Precio:"] = "Price:",
		["🐾 Comprar Pets 🐾"] = "🐾 Buy Pets 🐾",
		["🔁 Auto Comprar Pet 🔁"] = "🔁 Auto Buy Pet 🔁",
		["Seleccionar Aura"] = "Select Aura",
		["🌌 Comprar Aura 🌌"] = "🌌 Buy Aura 🌌",
		["🔁 Auto Comprar Aura 🔁"] = "🔁 Auto Buy Aura 🔁",
		["Auto evolucionar pet seleccionada"] = "Auto evolve selected pet",
		["Pet Lab"] = "Pet Lab",
		["Optimizar pets para"] = "Optimize pets for",
		["Fuerza"] = "Strength",
		["Daño"] = "Damage",
		["Mejor combinación:"] = "Best combination:",
		["Resultado:"] = "Result:",
		["Equipar mejor combinación"] = "Equip best combination",
		["Analizando..."] = "Scanning...",
		["Esperando pets"] = "Waiting for pets",
		["Mis perfiles"] = "My profiles",
		["Perfil"] = "Profile",
		["Cargar perfil"] = "Load profile",
		["Guardar"] = "Save",
		["Crear perfil"] = "Create profile",
		["Nombre"] = "Name",
		["Mi perfil"] = "My profile",
		["Cancelar"] = "Cancel",
		["Actualizar perfil"] = "Update profile",
		["Administrar"] = "Manage",
		["Renombrar perfil"] = "Rename profile",
		["Nuevo nombre"] = "New name",
		["Nombre nuevo"] = "New name",
		["Confirmar"] = "Confirm",
		["Eliminar perfil"] = "Delete profile",
		["No tenés perfiles"] = "You do not have any profiles",
		["Pet que querés"] = "Pet you want",
		["Probabilidad máxima"] = "Maximum chance",
		["Pets en Fuse Machine"] = "Pets in Fuse Machine",
		["La Fuse Machine sigue siendo RNG. Esta receta maximiza la probabilidad de conseguir la pet elegida."] = "The Fuse Machine is still RNG. This recipe maximizes the chance of getting the selected pet.",
		["Fusión activa"] = "Active fuse",
		["Fusionando"] = "Fusing",
		["Pet lista para reclamar"] = "Pet ready to claim",
		["Confirmar fusión"] = "Confirm fuse",
		["Estadísticas"] = "Stats",
		["Ver estadísticas de"] = "View stats for",
		["Minimapa"] = "Minimap",
		["🖥️ Rendimiento 🖥️"] = "🖥️ Performance 🖥️",
		["👁️ ESP y tracers 👁️"] = "👁️ ESP and tracers 👁️",
		["ESP: Nombres"] = "ESP: Names",
		["ESP: Distancia"] = "ESP: Distance",
		["ESP: Durabilidad"] = "ESP: Durability",
		["🧭 Jugadores 🧭"] = "🧭 Players 🧭",
		["Objetivo"] = "Target",
		["Teletransportarse al jugador"] = "Teleport to player",
		["Tracker: Seguir jugador"] = "Tracker: Follow player",
		["Orbitar alrededor del objetivo"] = "Orbit around target",
		["Radio de órbita"] = "Orbit radius",
		["Velocidad de órbita"] = "Orbit speed",
		["Spy: Mirar jugador"] = "Spy: Watch player",
		["Ocultar jugadores"] = "Hide players",
		["🌎 Mundo y cámara 🌎"] = "🌎 World and camera 🌎",
		["Quitar niebla"] = "Remove fog",
		["FOV personalizado"] = "Custom FOV",
		["Campo de visión"] = "Field of view",
		["Zoom extendido"] = "Extended zoom",
		["Ocultar interfaz del juego"] = "Hide game interface",
		["🧰 Utilidades 🧰"] = "🧰 Utilities 🧰",
		["Ocultar pets"] = "Hide pets",
		["⚙️ Misc ⚙️"] = "⚙️ Misc ⚙️",
		["🌐 Idioma 🌐"] = "🌐 Language 🌐",
		["Idioma"] = "Language",
		["Español"] = "Spanish",
		["🎨 Temas 🎨"] = "🎨 Themes 🎨",
		["Tema visual"] = "Visual theme",
		["Galaxia"] = "Galaxy",
		["Violeta"] = "Violet",
		["Carmesí"] = "Crimson",
		["Esmeralda"] = "Emerald",
		["Modo AFK"] = "AFK mode",
		["Auto Farm Kills"] = "Auto Farm Kills",
		["Fuerza + Durabilidad"] = "Strength + Durability",
		["Auto Egg inteligente"] = "Smart Auto Egg",
		["Iniciar modo AFK"] = "Start AFK mode",
		["Tiempo activo:"] = "Active time:",
		["Esperando inicio"] = "Waiting to start",
		["Elegí una tecla"] = "Choose a key",
		["❌ Cerrar Script ❌"] = "❌ Close Script ❌",
		["Young0x Hub - Cofres"] = "Young0x Hub - Chests",
		["Sin opciones"] = "No options",
		["Sin jugadores disponibles"] = "No players available",
		["Desactivado"] = "Disabled",
		["Velocidad del Fly"] = "Fly speed",
		["Distancia seguimiento"] = "Follow distance",
		["Velocidad Freecam"] = "Freecam speed",
		["Fuerza"] = "Strength",
		["Durabilidad"] = "Durability",
		["Agilidad"] = "Agility",
		["Peleas"] = "Fights",
		["Gemas"] = "Gems",
		["Regalos"] = "Gifts",
		["Estado"] = "Status",
		["Bloq Mayús"] = "Caps Lock",
		["Conectando..."] = "Connecting...",
		["Reintentando..."] = "Retrying...",
		["Servidor lleno. Buscando otro..."] = "Server full. Finding another...",
		["No hay cofres disponibles."] = "No chests are available.",
		["No se pudieron reclamar los cofres."] = "Could not claim the chests.",
		["No se pudo iniciar Fast Farm"] = "Could not start Fast Farm",
		["No se pudo iniciar Pet Momentum"] = "Could not start Pet Momentum",
		["Fast Trade activo · preparando primer lote"] = "Fast Trade active · preparing first batch",
		["Fast Trade activo · esperando pets"] = "Fast Trade active · waiting for pets",
		["Esperando que la otra cuenta acepte..."] = "Waiting for the other account to accept...",
		["Trade cerrado; reintentando el mismo lote..."] = "Trade closed; retrying the same batch...",
		["Aceptando y verificando entrega..."] = "Accepting and verifying delivery...",
		["No se pudo aceptar; reintentando..."] = "Could not accept; retrying...",
		["El executor no permite perfiles locales"] = "The executor does not support local profiles",
		["Tu executor no ofrece FPS Unlock."] = "Your executor does not provide FPS Unlock.",
		["No se pudo iniciar Freecam; todo fue restaurado."] = "Could not start Freecam; everything was restored.",
		["Este script es de paga. Si estás interesado en comprarlo, abrí un ticket."] = "This is a paid script. If you are interested in buying it, open a ticket.",
		["Evolucionadas:"] = "Evolved:",
		["No evolucionadas:"] = "Not evolved:",
		["Sin pets"] = "No pets",
		["Quitar pets"] = "Remove pets",
	}
	local PH = {
		{ "Activá un modo de kills para comenzar.", "Enable a kill mode to begin." },
		{ "Basado en ", "Based on " },
		{ " kills durante ", " kills over " },
		{ " objetivos", " targets" },
		{ "ciclo: ", "cycle: " },
		{ "ciclo de servidor: ", "server cycle: " },
		{ "Acción rechazada: ", "Action rejected: " },
		{ "Abrir selector: ", "Open selector: " },
		{ "Cerrar selector: ", "Close selector: " },
		{ "Historial limpiado", "History cleared" },
		{ "Anti-AFK respondió correctamente", "Anti-AFK responded correctly" },
		{ " SISTEMAS", " SYSTEMS" },
		{ " SISTEMA", " SYSTEM" },
		{ "Limpiar historial · ", "Clear history · " },
		{ "Próximo análisis en ", "Next scan in " },
		{ "Tema aplicado: ", "Theme applied: " },
		{ "Bonus total: ", "Total bonus: " },
		{ "Equipadas ", "Equipped " },
		{ " parece peligroso. Cambiando...", " looks dangerous. Switching..." },
		{ "Killer detectado. Cambiando...", "Killer detected. Switching..." },
		{ "Candidato encontrado", "Candidate found" },
		{ "No encontré un servidor compatible", "No compatible server found" },
		{ "King libre en este servidor", "King is free in this server" },
		{ "King ocupado", "King is occupied" },
		{ "Monitoreando servidor", "Monitoring server" },
		{ "Activo · ", "Active · " },
		{ "FG100 iniciado · Output en vivo", "FG100 started · Live Output" },
		{ "No se encontró el pack ", "Pack not found: " },
		{ "No se confirmó el equipamiento de ", "Could not confirm equipping " },
		{ "No hay máquina industrial disponible con los requisitos actuales", "No industrial machine is available for the current requirements" },
		{ "Cambió el pack de fuerza", "The strength pack changed" },
		{ "Máquina sin ganancia confirmada", "Machine gain was not confirmed" },
		{ "Falta confirmación de Rebirths", "Rebirth confirmation is missing" },
		{ "Rebirth rechazado", "Rebirth rejected" },
		{ "Rebirth confirmado con incremento menor a", "Rebirth confirmed with a lower gain than" },
		{ "Apagá los otros autos de entrenamiento y rebirth antes de Fast Rebirth", "Turn off the other training and rebirth automations before Fast Rebirth" },
		{ "No se encontró un pack de fuerza compatible", "No compatible strength pack was found" },
		{ "Fast Rebirth requiere al menos un pet con bonus de rebirth", "Fast Rebirth requires at least one pet with a rebirth bonus" },
		{ "Fast Rebirth requiere un pack de fuerza y al menos un pet con bonus de rebirth", "Fast Rebirth requires a strength pack and at least one pet with a rebirth bonus" },
		{ "Pet Momentum no está disponible en esta versión", "Pet Momentum is not available in this version" },
		{ "Pet Momentum completado: multiplicador máximo", "Pet Momentum complete: max multiplier" },
		{ "Equipá al menos una pet.", "Equip at least one pet." },
		{ "Todas las cintas accesibles están ocupadas", "All accessible treadmills are occupied" },
		{ "No encontré otro servidor disponible.", "No other server was available." },
		{ "No se pudo preparar la reconexión.", "Could not prepare the reconnection." },
		{ "Ingresá un número válido para ", "Enter a valid number for " },
		{ " no está disponible en el leaderboard", " is not available on the leaderboard" },
		{ "El canje de códigos no está disponible", "Code redemption is not available" },
		{ "No se pudieron canjear algunos códigos.", "Some codes could not be redeemed." },
		{ "Canjeando ", "Redeeming " },
		{ " al máximo", " at max" },
		{ " Pausado por ping", " Paused due to ping" },
		{ " Entrenando", " Training" },
		{ "Faltan: ", "Remaining: " },
		{ "Tiempo: ", "Time: " },
		{ "Ciclo: ", "Cycle: " },
		{ "Calculando ciclos: ", "Measuring cycles: " },
		{ "Seleccionado: ", "Selected: " },
		{ "Cancelado: cambió el jugador", "Cancelled: player changed" },
		{ "Cancelado: cambió la pet", "Cancelled: pet changed" },
		{ "Fast Trade activo · esperando aceptación", "Fast Trade active · waiting for acceptance" },
		{ "Cerrá el trade actual antes de iniciar", "Close the current trade before starting" },
		{ "Seleccioná un jugador válido", "Select a valid player" },
		{ "Seleccioná una pet", "Select a pet" },
		{ "El remote de trade no está disponible", "The trade remote is not available" },
		{ "No tenés esa pet disponible", "You do not have that pet available" },
		{ "El jugador salió del servidor", "The player left the server" },
		{ "No se confirmó la entrega; reintentando...", "Delivery was not confirmed; retrying..." },
		{ "No tenés ", "You do not have " },
		{ " Enviados ", " Sent " },
		{ " Enviar ", " Send " },
		{ "No se confirmó el envío", "Sending was not confirmed" },
		{ "Esperando tienda real", "Waiting for the real shop" },
		{ "Perfil inválido o dañado", "Invalid or damaged profile" },
		{ "Nombre inválido o borrado local no disponible", "Invalid name or local deletion unavailable" },
		{ "Ingresá un nombre", "Enter a name" },
		{ "Usá otro nombre", "Use another name" },
		{ "Confirmar eliminar ", "Confirm deletion of " },
		{ "Tenés ", "Owned: " },
		{ "Una pet ya no está disponible.", "A pet is no longer available." },
		{ "Desequipá las pets primero.", "Unequip the pets first." },
		{ "Una pet está en intercambio.", "A pet is being traded." },
		{ "Quitá la protección de la pet.", "Remove the pet protection." },
		{ "Una pet está bloqueada.", "A pet is locked." },
		{ "Combinación no disponible.", "Combination unavailable." },
		{ "Colocá las 4 pets.", "Place all 4 pets." },
		{ "Una pet no es válida.", "A pet is not valid." },
		{ "Esperá un momento.", "Wait a moment." },
		{ "La pet todavía no está lista.", "The pet is not ready yet." },
		{ "Ya hay una fusión activa.", "A fuse is already active." },
		{ "La Fuse Machine todavía no está disponible.", "The Fuse Machine is not available yet." },
		{ "No se pudieron limpiar los espacios de fusión.", "Could not clear the fuse slots." },
		{ "No se pudo colocar la receta. Intentá nuevamente.", "Could not place the recipe. Try again." },
		{ "No se pudo reclamar la pet. Intentá nuevamente.", "Could not claim the pet. Try again." },
		{ "Iniciando la fusión...", "Starting the fuse..." },
		{ "No se pudo iniciar la fusión. Intentá nuevamente.", "Could not start the fuse. Try again." },
		{ "Script ejecutado hace: ", "Script running for: " },
		{ "Freecam necesita que tu personaje esté vivo.", "Freecam requires your character to be alive." },
		{ "Emergency Stop: todo quedó detenido.", "Emergency Stop: everything was stopped." },
		{ "Seleccioná un jugador disponible.", "Select an available player." },
		{ "El objetivo ya no está disponible.", "The target is no longer available." },
		{ "Reclamando ", "Claiming " },
		{ " cofres disponibles...", " available chests..." },
		{ "Cofres reclamados: ", "Chests claimed: " },
		{ "Cantidad seleccionada: ", "Selected amount: " },
		{ "Comprando ", "Buying " },
		{ "Esperando renacimientos suficientes...", "Waiting for enough rebirths..." },
		{ "Seleccionando lote de ", "Selecting a batch of " },
		{ " pets...", " pets..." },
		{ "Perfil guardado: ", "Profile saved: " },
		{ "No se pudo guardar el perfil", "Could not save the profile" },
		{ "Perfil cargado: ", "Profile loaded: " },
		{ " renombrado a ", " renamed to " },
		{ "No se pudo renombrar", "Could not rename" },
		{ "Perfil eliminado: ", "Profile deleted: " },
		{ "No se pudo eliminar", "Could not delete" },
		{ "Quitar pets · ", "Remove pets · " },
		{ "% por intento", "% per attempt" },
		{ "Campo de visión:", "Field of view:" },
		{ "Radio de órbita:", "Orbit radius:" },
		{ "Velocidad de órbita:", "Orbit speed:" },
		{ "Velocidad del Fly:", "Fly speed:" },
		{ "Distancia seguimiento:", "Follow distance:" },
		{ "Velocidad Freecam:", "Freecam speed:" },
	}
    local rows = {
    {"Jesus is the way, the truth, and the life","Jesus é o caminho, a verdade e a vida","يسوع هو الطريق والحق والحياة"},
    {"God loves you ❤","Deus te ama ❤","الله يحبك ❤"},
    {"WORD OF LIFE","PALAVRA DE VIDA","كلمة الحياة"},
    {"Inventory","Inventário","المخزون"},
    {"Profiles","Perfis","الملفات الشخصية"},
    {"Player Info","Informações do jogador","معلومات اللاعب"},
    {"Server Info","Informações do servidor","معلومات الخادم"},
    {"Game:","Jogo:","اللعبة:"},
    {"Author:","Autor:","المؤلف:"},
    {"Link copied","Link copiado","تم نسخ الرابط"},
    {"Set Size (Maximum 100)","Definir tamanho (máximo 100)","تحديد الحجم (الحد الأقصى 100)"},
    {"Example:","Exemplo:","مثال:"},
    {"Visual stats","Estatísticas visuais","الإحصاءات المرئية"},
    {"Codes","Códigos","الرموز"},
    {"Redeem all codes","Resgatar todos os códigos","استرداد جميع الرموز"},
    {"Hide Durability","Ocultar durabilidade","إخفاء المتانة"},
    {"It was fun while it lasted, RIP pets bug 2019 - 2026 🥀.","Foi bom enquanto durou, RIP pets bug 2019 - 2026 🥀.","كانت أيامًا جميلة، وداعًا لخلل الحيوانات 2019 - 2026 🥀."},
    {"Mode","Modo","الوضع"},
    {"Hide Pop-ups","Ocultar pop-ups","إخفاء النوافذ المنبثقة"},
    {"Requirement:","Requisito:","المتطلب:"},
    {"Current Muscle King","Muscle King atual","ملك العضلات الحالي"},
    {"Time:","Tempo:","الوقت:"},
    {"Calculator:","Calculadora:","الحاسبة:"},
    {"Kill calculator","Calculadora de eliminações","حاسبة الإقصاءات"},
    {"Estimated kills","Eliminações estimadas","الإقصاءات التقريبية"},
    {"PER HOUR","POR HORA","في الساعة"},
    {"PER DAY","POR DIA","في اليوم"},
    {"PER WEEK","POR SEMANA","في الأسبوع"},
    {"System status","Estado do sistema","حالة النظام"},
    {"Activity history","Histórico de atividade","سجل النشاط"},
    {"Clear Output","Limpar Output","مسح السجل"},
    {"Control center","Central de controle","مركز التحكم"},
    {"Live activity","Atividade ao vivo","النشاط المباشر"},
    {"LIVE ACTIVITY","ATIVIDADE AO VIVO","النشاط المباشر"},
    {"Clear history","Limpar histórico","مسح السجل"},
    {"Choose which pack you want to farm with","Escolha o pacote que quer usar","اختر الحزمة التي تريد استخدامها"},
    {"FG100 adapts the combination and slots automatically.","O FG100 ajusta a combinação e os espaços automaticamente.","يضبط FG100 التشكيلة والخانات تلقائيًا."},
    {"Chaos Lords","Senhores do Caos","سادة الفوضى"},
    {"Ultra Titans","Ultra Titãs","العمالقة الخارقون"},
    {"Select a pack to continue.","Selecione um pacote para continuar.","اختر حزمة للمتابعة."},
    {"You do not have a compatible pack available.","Você não tem um pacote compatível disponível.","ليست لديك حزمة متوافقة متاحة."},
    {"Calibrating...","Calibrando...","جارٍ المعايرة..."},
    {"Farm Pet Momentum","Treinar Pet Momentum","تدريب زخم الحيوانات"},
    {"at max","no máximo","عند الحد الأقصى"},
    {"Rebirth counter","Contador de renascimentos","عداد إعادة الولادة"},
    {"Tools","Ferramentas","الأدوات"},
    {"Redeeming...","Resgatando...","جارٍ الاسترداد..."},
    {"Could not redeem","Não foi possível resgatar","تعذر الاسترداد"},
    {"Redeem 2K Strength","Resgatar 2 mil de força","استرداد 2000 قوة"},
    {"Code redeemed","Código resgatado","تم استرداد الرمز"},
    {"Code already redeemed","Código já resgatado","تم استرداد الرمز مسبقًا"},
    {"Fast Weight","Peso rápido","الأثقال السريعة"},
    {"Rebirth target","Meta de renascimentos","هدف إعادة الولادة"},
    {"Rebirth until target","Renascer até a meta","إعادة الولادة حتى الهدف"},
    {"Infinite Rebirths","Renascimentos infinitos","إعادة ولادة بلا نهاية"},
    {"Select Ultimate","Selecionar Ultimate","اختيار Ultimate"},
    {"Amount to buy","Quantidade a comprar","الكمية المراد شراؤها"},
    {"Selected level","Nível selecionado","المستوى المختار"},
    {"Buy Ultimate","Comprar Ultimate","شراء Ultimate"},
    {"Cancel purchase","Cancelar compra","إلغاء الشراء"},
    {"Maximum","Máximo","الحد الأقصى"},
    {"Waiting for selection","Aguardando seleção","بانتظار الاختيار"},
    {"Waiting for purchase","Aguardando compra","بانتظار الشراء"},
    {"Purchase cancelled","Compra cancelada","تم إلغاء الشراء"},
    {"Ultimate at max","Ultimate no máximo","Ultimate عند الحد الأقصى"},
    {"Smart Server Hop","Troca inteligente de servidor","التنقل الذكي بين الخوادم"},
    {"Server type","Tipo de servidor","نوع الخادم"},
    {"Full (18-19)","Cheio (18-19)","ممتلئ (18-19)"},
    {"Solo (1-2)","Solitário (1-2)","قليل اللاعبين (1-2)"},
    {"Balanced (8-14)","Equilibrado (8-14)","متوازن (8-14)"},
    {"Best latency","Melhor latência","أفضل زمن استجابة"},
    {"Free King","King livre","King متاح"},
    {"Scan servers","Analisar servidores","فحص الخوادم"},
    {"Change server now","Trocar de servidor agora","تغيير الخادم الآن"},
    {"Maintain target automatically","Manter objetivo automaticamente","الحفاظ على الهدف تلقائيًا"},
    {"Change if I am eliminated","Trocar se eu for eliminado","تغيير الخادم عند إقصائي"},
    {"Change if a killer joins","Trocar se entrar um jogador perigoso","التغيير عند دخول لاعب يحتمل أن يكون خطرًا"},
    {"Players:","Jogadores:","اللاعبون:"},
    {"Status:","Estado:","الحالة:"},
    {"Not scanned","Não analisado","لم يُفحص"},
    {"MEMORY","MEMÓRIA","الذاكرة"},
    {"PLAYERS","JOGADORES","اللاعبون"},
    {"Claim King automatically","Reivindicar King automaticamente","الاستحواذ على King تلقائيًا"},
    {"Best candidate:","Melhor candidato:","أفضل خيار:"},
    {"Ready to scan","Pronto para analisar","جاهز للفحص"},
    {"Do not kill my friends","Não eliminar meus amigos","عدم إقصاء أصدقائي"},
    {"Select player","Selecionar jogador","اختيار لاعب"},
    {"Kill player","Eliminar jogador","إقصاء اللاعب"},
    {"Select pet","Selecionar pet","اختيار حيوان"},
    {"Select Pet","Selecionar pet","اختيار حيوان"},
    {"Pets per trade","Pets por troca","الحيوانات في كل تبادل"},
    {"Start Fast Trade","Iniciar Fast Trade","بدء التبادل السريع"},
    {"Cancel Fast Trade","Cancelar Fast Trade","إلغاء التبادل السريع"},
    {"Gifts","Presentes","الهدايا"},
    {"Send Gifts","Enviar presentes","إرسال هدايا"},
    {"Player","Jogador","اللاعب"},
    {"Egg amount","Quantidade de ovos","عدد البيض"},
    {"Shake amount","Quantidade de shakes","عدد المشروبات"},
    {"Select a player","Selecione um jogador","اختر لاعبًا"},
    {"Sending","Enviando","جارٍ الإرسال"},
    {"Price:","Preço:","السعر:"},
    {"Buy Pets","Comprar pets","شراء حيوانات"},
    {"Auto Buy Pet","Comprar pet automaticamente","شراء الحيوانات تلقائيًا"},
    {"Select Aura","Selecionar aura","اختيار هالة"},
    {"Buy Aura","Comprar aura","شراء هالة"},
    {"Auto Buy Aura","Comprar aura automaticamente","شراء الهالات تلقائيًا"},
    {"Auto evolve selected pet","Evoluir a pet selecionada automaticamente","تطوير الحيوان المختار تلقائيًا"},
    {"Pet Lab","Laboratório de pets","مختبر الحيوانات"},
    {"Optimize pets for","Otimizar pets para","تحسين التشكيلة من أجل"},
    {"Strength + Durability","Força + Durabilidade","القوة + المتانة"},
    {"Strength","Força","القوة"},
    {"Durability","Durabilidade","المتانة"},
    {"Damage","Dano","الضرر"},
    {"Best combination:","Melhor combinação:","أفضل تشكيلة:"},
    {"Result:","Resultado:","النتيجة:"},
    {"Equip best combination","Equipar a melhor combinação","تجهيز أفضل تشكيلة"},
    {"Scanning...","Analisando...","جارٍ الفحص..."},
    {"Waiting for pets","Aguardando pets","بانتظار الحيوانات"},
    {"My profiles","Meus perfis","ملفاتي الشخصية"},
    {"Profile","Perfil","الملف الشخصي"},
    {"Load profile","Carregar perfil","تحميل ملف شخصي"},
    {"Save","Salvar","حفظ"},
    {"Create profile","Criar perfil","إنشاء ملف شخصي"},
    {"Name","Nome","الاسم"},
    {"My profile","Meu perfil","ملفي الشخصي"},
    {"Cancel","Cancelar","إلغاء"},
    {"Update profile","Atualizar perfil","تحديث الملف الشخصي"},
    {"Manage","Gerenciar","إدارة"},
    {"Rename profile","Renomear perfil","إعادة تسمية الملف"},
    {"New name","Novo nome","الاسم الجديد"},
    {"Confirm","Confirmar","تأكيد"},
    {"Delete profile","Excluir perfil","حذف الملف الشخصي"},
    {"You do not have any profiles","Você não tem perfis","ليس لديك أي ملفات شخصية"},
    {"Pet you want","Pet desejada","الحيوان المطلوب"},
    {"Maximum chance","Chance máxima","أعلى احتمال"},
    {"Pets in Fuse Machine","Pets na máquina de fusão","الحيوانات في آلة الدمج"},
    {"The Fuse Machine is still RNG. This recipe maximizes the chance of getting the selected pet.","A fusão continua aleatória. Esta receita maximiza a chance da pet escolhida.","يبقى الدمج عشوائيًا. هذه الوصفة تزيد احتمال الحصول على الحيوان المختار."},
    {"Active fuse","Fusão ativa","دمج نشط"},
    {"Fusing","Fundindo","جارٍ الدمج"},
    {"Pet ready to claim","Pet pronta para resgatar","الحيوان جاهز للاستلام"},
    {"Confirm fuse","Confirmar fusão","تأكيد الدمج"},
    {"Stats","Estatísticas","الإحصاءات"},
    {"View stats for","Ver estatísticas de","عرض إحصاءات"},
    {"Minimap","Minimapa","الخريطة المصغرة"},
    {"Performance","Desempenho","الأداء"},
    {"ESP and tracers","ESP e rastreadores","ESP وخطوط التتبع"},
    {"ESP: Names","ESP: Nomes","ESP: الأسماء"},
    {"ESP: Distance","ESP: Distância","ESP: المسافة"},
    {"ESP: Durability","ESP: Durabilidade","ESP: المتانة"},
    {"Players","Jogadores","اللاعبون"},
    {"Target","Objetivo","الهدف"},
    {"Teleport to player","Ir até o jogador","الانتقال إلى اللاعب"},
    {"Tracker: Follow player","Rastreador: Seguir jogador","المتتبع: متابعة اللاعب"},
    {"Orbit around target","Orbitar ao redor do objetivo","الدوران حول الهدف"},
    {"Orbit radius","Raio da órbita","نصف قطر المدار"},
    {"Orbit speed","Velocidade da órbita","سرعة الدوران"},
    {"Spy: Watch player","Observar jogador","مشاهدة اللاعب"},
    {"Hide players","Ocultar jogadores","إخفاء اللاعبين"},
    {"World and camera","Mundo e câmera","العالم والكاميرا"},
    {"Remove fog","Remover neblina","إزالة الضباب"},
    {"Custom FOV","FOV personalizado","مجال رؤية مخصص"},
    {"Field of view","Campo de visão","مجال الرؤية"},
    {"Extended zoom","Zoom ampliado","تقريب ممتد"},
    {"Hide game interface","Ocultar interface do jogo","إخفاء واجهة اللعبة"},
    {"Utilities","Utilidades","الأدوات المساعدة"},
    {"Hide pets","Ocultar pets","إخفاء الحيوانات"},
    {"Language","Idioma","اللغة"},
    {"Spanish","Español","Español"},
    {"Themes","Temas","السمات"},
    {"Visual theme","Tema visual","السمة المرئية"},
    {"Galaxy","Galáxia","المجرة"},
    {"Violet","Violeta","البنفسجي"},
    {"Crimson","Carmesim","القرمزي"},
    {"Emerald","Esmeralda","الزمردي"},
    {"AFK mode","Modo AFK","وضع AFK"},
    {"Smart Auto Egg","Auto Egg inteligente","استخدام البيض الذكي"},
    {"Start AFK mode","Iniciar modo AFK","بدء وضع AFK"},
    {"Active time:","Tempo ativo:","مدة النشاط:"},
    {"Waiting to start","Aguardando início","بانتظار البدء"},
    {"Choose a key","Escolha uma tecla","اختر مفتاحًا"},
    {"Close Script","Fechar script","إغلاق السكربت"},
    {"Chests","Baús","الصناديق"},
    {"No options","Sem opções","لا توجد خيارات"},
    {"No players available","Nenhum jogador disponível","لا يوجد لاعبون متاحون"},
    {"Disabled","Desativado","معطل"},
    {"Fly speed","Velocidade de voo","سرعة الطيران"},
    {"Follow distance","Distância de acompanhamento","مسافة المتابعة"},
    {"Freecam speed","Velocidade da câmera livre","سرعة الكاميرا الحرة"},
    {"Agility","Agilidade","الرشاقة"},
    {"Fights","Lutas","المعارك"},
    {"Gems","Gemas","الجواهر"},
    {"Status","Estado","الحالة"},
    {"Caps Lock","Caps Lock","Caps Lock"},
    {"Connecting...","Conectando...","جارٍ الاتصال..."},
    {"Retrying...","Tentando novamente...","إعادة المحاولة..."},
    {"Server full. Finding another...","Servidor cheio. Procurando outro...","الخادم ممتلئ. جارٍ البحث عن آخر..."},
    {"No chests are available.","Nenhum baú disponível.","لا توجد صناديق متاحة."},
    {"Could not claim the chests.","Não foi possível resgatar os baús.","تعذر استلام الصناديق."},
    {"Could not start Fast Farm","Não foi possível iniciar Fast Farm","تعذر بدء Fast Farm"},
    {"Could not start Pet Momentum","Não foi possível iniciar Pet Momentum","تعذر بدء زخم الحيوانات"},
    {"Fast Trade active · preparing first batch","Fast Trade ativo · preparando o primeiro lote","التبادل السريع نشط · تجهيز الدفعة الأولى"},
    {"Fast Trade active · waiting for pets","Fast Trade ativo · aguardando pets","التبادل السريع نشط · بانتظار الحيوانات"},
    {"Waiting for the other account to accept...","Aguardando a outra conta aceitar...","بانتظار قبول الحساب الآخر..."},
    {"Trade closed; retrying the same batch...","Troca encerrada; tentando o mesmo lote...","أُغلق التبادل؛ إعادة محاولة الدفعة نفسها..."},
    {"Accepting and verifying delivery...","Aceitando e verificando a entrega...","جارٍ القبول والتحقق من التسليم..."},
    {"Could not accept; retrying...","Não foi possível aceitar; tentando novamente...","تعذر القبول؛ إعادة المحاولة..."},
    {"The executor does not support local profiles","O executor não oferece perfis locais","المشغّل لا يدعم الملفات الشخصية المحلية"},
    {"Your executor does not provide FPS Unlock.","Seu executor não oferece FPS Unlock.","مشغّلك لا يدعم فتح حد الإطارات."},
    {"Could not start Freecam; everything was restored.","Não foi possível iniciar a câmera livre; tudo foi restaurado.","تعذر بدء الكاميرا الحرة؛ تمت استعادة كل شيء."},
    {"Evolved:","Evoluídas:","المطورة:"},
    {"Not evolved:","Não evoluídas:","غير المطورة:"},
    {"No pets","Sem pets","لا توجد حيوانات"},
    {"Remove pets","Remover pets","إزالة الحيوانات"},
    {"Enable a kill mode to begin.","Ative um modo de eliminações para começar.","فعّل وضع إقصاء للبدء."},
    {"Based on ","Com base em ","بناءً على "},
    {" kills over "," eliminações em "," إقصاءات خلال "},
    {" targets"," objetivos"," أهداف"},
    {"cycle: ","ciclo: ","الدورة: "},
    {"server cycle: ","ciclo do servidor: ","دورة الخادم: "},
    {"Action rejected: ","Ação recusada: ","الإجراء مرفوض: "},
    {"Open selector: ","Abrir seletor: ","فتح الاختيار: "},
    {"Close selector: ","Fechar seletor: ","إغلاق الاختيار: "},
    {"History cleared","Histórico limpo","تم مسح السجل"},
    {"Anti-AFK responded correctly","Anti-AFK respondeu corretamente","استجاب منع الخمول بنجاح"},
    {"SYSTEMS","SISTEMAS","أنظمة"},
    {"SYSTEM","SISTEMA","نظام"},
    {"Next scan in ","Próxima análise em ","الفحص التالي بعد "},
    {"Theme applied: ","Tema aplicado: ","السمة المطبقة: "},
    {"Total bonus: ","Bônus total: ","المكافأة الإجمالية: "},
    {"Equipped ","Equipadas ","تم تجهيز "},
    {" looks dangerous. Switching..."," parece perigoso. Trocando..."," يبدو خطرًا. جارٍ التغيير..."},
    {"Killer detected. Switching...","Possível ameaça detectada. Trocando...","رُصد تهديد محتمل. جارٍ التغيير..."},
    {"Candidate found","Candidato encontrado","تم العثور على خيار"},
    {"No compatible server found","Nenhum servidor compatível encontrado","لم يُعثر على خادم متوافق"},
    {"King is free in this server","King livre neste servidor","King متاح في هذا الخادم"},
    {"King is occupied","King ocupado","King مشغول"},
    {"Monitoring server","Monitorando servidor","مراقبة الخادم"},
    {"Mode stopped","Modo parado","تم إيقاف الوضع"},
    {"Active · ","Ativo · ","نشط · "},
    {"FG100 started · Live Output","FG100 iniciado · Output ao vivo","بدأ FG100 · سجل مباشر"},
    {"Pack not found: ","Pacote não encontrado: ","لم تُعثر على الحزمة: "},
    {"Could not confirm equipping ","Não foi possível confirmar o equipamento de ","تعذر تأكيد تجهيز "},
    {"No industrial machine is available for the current requirements","Nenhuma máquina industrial está disponível com os requisitos atuais","لا توجد آلة صناعية متاحة بالمتطلبات الحالية"},
    {"The strength pack changed","O pacote de força mudou","تغيرت حزمة القوة"},
    {"Machine gain was not confirmed","O ganho na máquina não foi confirmado","لم تتأكد زيادة الآلة"},
    {"Rebirth confirmation is missing","Falta confirmação do renascimento","تأكيد إعادة الولادة مفقود"},
    {"Rebirth rejected","Renascimento recusado","رُفضت إعادة الولادة"},
    {"Rebirth confirmed with a lower gain than","Renascimento confirmado com ganho menor que","تأكدت إعادة الولادة بزيادة أقل من"},
    {"Turn off the other training and rebirth automations before Fast Rebirth","Desative os outros treinos e renascimentos automáticos antes do Fast Rebirth","أوقف أنظمة التدريب وإعادة الولادة الأخرى قبل Fast Rebirth"},
    {"No compatible strength pack was found","Nenhum pacote de força compatível encontrado","لم تُعثر على حزمة قوة متوافقة"},
    {"Fast Rebirth requires at least one pet with a rebirth bonus","Fast Rebirth precisa de ao menos uma pet com bônus de renascimento","يتطلب Fast Rebirth حيوانًا واحدًا على الأقل بمكافأة إعادة ولادة"},
    {"Fast Rebirth requires a strength pack and at least one pet with a rebirth bonus","Fast Rebirth precisa de um pacote de força e uma pet com bônus de renascimento","يتطلب Fast Rebirth حزمة قوة وحيوانًا بمكافأة إعادة ولادة"},
    {"Pet Momentum is not available in this version","Pet Momentum não está disponível nesta versão","زخم الحيوانات غير متاح في هذا الإصدار"},
    {"Pet Momentum complete: max multiplier","Pet Momentum concluído: multiplicador máximo","اكتمل زخم الحيوانات: أعلى مضاعف"},
    {"Equip at least one pet.","Equipe ao menos uma pet.","جهّز حيوانًا واحدًا على الأقل."},
    {"All accessible treadmills are occupied","Todas as esteiras acessíveis estão ocupadas","جميع أجهزة الجري المتاحة مشغولة"},
    {"No other server was available.","Nenhum outro servidor disponível.","لا يوجد خادم آخر متاح."},
    {"Could not prepare the reconnection.","Não foi possível preparar a reconexão.","تعذر تجهيز إعادة الاتصال."},
    {"Enter a valid number for ","Digite um número válido para ","أدخل رقمًا صالحًا لـ "},
    {" is not available on the leaderboard"," não está disponível no placar"," غير متاح في لوحة المتصدرين"},
    {"Code redemption is not available","O resgate de códigos não está disponível","استرداد الرموز غير متاح"},
    {"Some codes could not be redeemed.","Alguns códigos não puderam ser resgatados.","تعذر استرداد بعض الرموز."},
    {"Redeeming ","Resgatando ","جارٍ استرداد "},
    {"Paused due to ping","Pausado por latência","متوقف بسبب زمن الاستجابة"},
    {"Training","Treinando","جارٍ التدريب"},
    {"Remaining: ","Faltam: ","المتبقي: "},
    {"Cycle: ","Ciclo: ","الدورة: "},
    {"Measuring cycles: ","Medindo ciclos: ","قياس الدورات: "},
    {"Selected: ","Selecionado: ","المختار: "},
    {"Cancelled: player changed","Cancelado: o jogador mudou","أُلغي: تغير اللاعب"},
    {"Cancelled: pet changed","Cancelado: a pet mudou","أُلغي: تغير الحيوان"},
    {"Fast Trade active · waiting for acceptance","Fast Trade ativo · aguardando aceitação","التبادل السريع نشط · بانتظار القبول"},
    {"Close the current trade before starting","Feche a troca atual antes de começar","أغلق التبادل الحالي قبل البدء"},
    {"Select a valid player","Selecione um jogador válido","اختر لاعبًا صالحًا"},
    {"Select a pet","Selecione uma pet","اختر حيوانًا"},
    {"The trade remote is not available","O serviço de troca não está disponível","خدمة التبادل غير متاحة"},
    {"You do not have that pet available","Você não tem essa pet disponível","هذا الحيوان غير متاح لديك"},
    {"The player left the server","O jogador saiu do servidor","غادر اللاعب الخادم"},
    {"Delivery was not confirmed; retrying...","Entrega não confirmada; tentando novamente...","لم يتأكد التسليم؛ إعادة المحاولة..."},
    {"You do not have ","Você não tem ","ليس لديك "},
    {" Sent "," Enviados "," تم إرسال "},
    {" Send "," Enviar "," إرسال "},
    {"Sending was not confirmed","O envio não foi confirmado","لم يتأكد الإرسال"},
    {"Waiting for the real shop","Aguardando a loja do jogo","بانتظار متجر اللعبة"},
    {"Invalid or damaged profile","Perfil inválido ou danificado","ملف شخصي غير صالح أو تالف"},
    {"Invalid name or local deletion unavailable","Nome inválido ou exclusão local indisponível","اسم غير صالح أو الحذف المحلي غير متاح"},
    {"Enter a name","Digite um nome","أدخل اسمًا"},
    {"Use another name","Use outro nome","استخدم اسمًا آخر"},
    {"Confirm deletion of ","Confirmar exclusão de ","تأكيد حذف "},
    {"Owned: ","Você tem: ","لديك: "},
    {"A pet is no longer available.","Uma pet não está mais disponível.","لم يعد أحد الحيوانات متاحًا."},
    {"Unequip the pets first.","Desequipe as pets primeiro.","أزل تجهيز الحيوانات أولًا."},
    {"A pet is being traded.","Uma pet está em troca.","أحد الحيوانات قيد التبادل."},
    {"Remove the pet protection.","Remova a proteção da pet.","أزل حماية الحيوان."},
    {"A pet is locked.","Uma pet está bloqueada.","أحد الحيوانات مقفل."},
    {"Combination unavailable.","Combinação indisponível.","التشكيلة غير متاحة."},
    {"Place all 4 pets.","Coloque as 4 pets.","ضع الحيوانات الأربعة."},
    {"A pet is not valid.","Uma pet não é válida.","أحد الحيوانات غير صالح."},
    {"Wait a moment.","Aguarde um momento.","انتظر لحظة."},
    {"The pet is not ready yet.","A pet ainda não está pronta.","الحيوان ليس جاهزًا بعد."},
    {"A fuse is already active.","Já existe uma fusão ativa.","يوجد دمج نشط بالفعل."},
    {"The Fuse Machine is not available yet.","A máquina de fusão ainda não está disponível.","آلة الدمج ليست متاحة بعد."},
    {"Could not clear the fuse slots.","Não foi possível limpar os espaços de fusão.","تعذر إفراغ خانات الدمج."},
    {"Could not place the recipe. Try again.","Não foi possível colocar a receita. Tente novamente.","تعذر وضع الوصفة. حاول مجددًا."},
    {"Could not claim the pet. Try again.","Não foi possível resgatar a pet. Tente novamente.","تعذر استلام الحيوان. حاول مجددًا."},
    {"Starting the fuse...","Iniciando a fusão...","جارٍ بدء الدمج..."},
    {"Could not start the fuse. Try again.","Não foi possível iniciar a fusão. Tente novamente.","تعذر بدء الدمج. حاول مجددًا."},
    {"Script running for: ","Script em execução há: ","مدة تشغيل السكربت: "},
    {"Freecam requires your character to be alive.","A câmera livre precisa que seu personagem esteja vivo.","تتطلب الكاميرا الحرة أن تكون شخصيتك حية."},
    {"Emergency Stop: everything was stopped.","Parada de emergência: tudo foi interrompido.","إيقاف طارئ: تم إيقاف كل شيء."},
    {"Select an available player.","Selecione um jogador disponível.","اختر لاعبًا متاحًا."},
    {"The target is no longer available.","O objetivo não está mais disponível.","الهدف لم يعد متاحًا."},
    {"Claiming ","Resgatando ","جارٍ استلام "},
    {" available chests..."," baús disponíveis..."," صناديق متاحة..."},
    {"Chests claimed: ","Baús resgatados: ","الصناديق المستلمة: "},
    {"Selected amount: ","Quantidade selecionada: ","الكمية المختارة: "},
    {"Buying ","Comprando ","جارٍ شراء "},
    {"Waiting for enough rebirths...","Aguardando renascimentos suficientes...","بانتظار عدد كافٍ من إعادات الولادة..."},
    {"Selecting a batch of ","Selecionando um lote de ","اختيار دفعة من "},
    {" pets..."," pets..."," حيوانات..."},
    {"Profile saved: ","Perfil salvo: ","تم حفظ الملف: "},
    {"Could not save the profile","Não foi possível salvar o perfil","تعذر حفظ الملف الشخصي"},
    {"Profile loaded: ","Perfil carregado: ","تم تحميل الملف: "},
    {" renamed to "," renomeado para "," تمت إعادة تسميته إلى "},
    {"Could not rename","Não foi possível renomear","تعذرت إعادة التسمية"},
    {"Profile deleted: ","Perfil excluído: ","تم حذف الملف: "},
    {"Could not delete","Não foi possível excluir","تعذر الحذف"},
    {"% per attempt","% por tentativa","% لكل محاولة"},
    {"Home","Principal","الرئيسية"},
    {"Combat","Combate","القتال"},
    {"Progress per pet","Progresso por pet","تقدم كل حيوان"},
    {"Equipped bonus:","Bônus equipado:","مكافأة التشكيلة الحالية:"},
    {"Possible improvement:","Melhoria possível:","التحسن الممكن:"},
    {"Progress:","Progresso:","التقدم:"},
    {"Choose your mode","Escolha seu modo","اختر وضعك"},
    {"Choose another mode","Escolher outro modo","اختيار وضع آخر"},
    {"Your best available exercise","Seu melhor exercício disponível","أفضل تمرين متاح لك"},
    {"Rock and training at the same time","Rocha e treino ao mesmo tempo","الصخرة والتدريب في الوقت نفسه"},
    {"Confirmed kills and server changes","Eliminações confirmadas e troca de servidor","إقصاءات مؤكدة وتغيير الخادم"},
    {"Ready to start","Pronto para iniciar","جاهز للبدء"},
    {"Waiting for character","Aguardando personagem","بانتظار الشخصية"},
    {"Waiting for server response","Aguardando resposta do servidor","بانتظار استجابة الخادم"},
    {"Ready to rebirth","Pronto para renascer","جاهز لإعادة الولادة"},
    {"Retrying after a pause","Tentando novamente após uma pausa","إعادة المحاولة بعد مهلة"},
    {"Training Pushups","Treinando flexões","التدريب على تمارين الضغط"},
    {"Recovering strength with Weight","Recuperando força com pesos","استعادة القوة بالأثقال"},
    {"Training until a rock is unlocked","Treinando até desbloquear uma rocha","التدريب حتى فتح صخرة"},
    {"Changing servers","Trocando de servidor","جارٍ تغيير الخادم"},
    {"Finding targets","Procurando objetivos","البحث عن أهداف"},
    {"Activity","Atividade","النشاط"},
    {"Systems","Sistemas","الأنظمة"},
    {"Diagnostics","Diagnóstico","التشخيص"},
    {"Show","Mostrar","عرض"},
    {"All","Tudo","الكل"},
    {"Errors","Erros","الأخطاء"},
    {"Actions","Ações","الإجراءات"},
    {"Server","Servidor","الخادم"},
    {"Pause feed","Pausar leitura","إيقاف تحديث السجل"},
    {"No activity recorded.","Nenhuma atividade registrada.","لا يوجد نشاط مسجل."},
    {"Connected","Conectado","متصل"},
    {"Disconnected","Desconectado","غير متصل"},
    {"responses","respostas","استجابات"},
    {"Waiting for the multiplier to end","Aguardando o multiplicador terminar","بانتظار انتهاء المضاعف"},
    {"Lua memory","Memória Lua","ذاكرة Lua"},
    {"Resources","Recursos","الموارد"},
    {"tasks","tarefas","مهام"},
    {"connections","conexões","اتصالات"},
    {"No errors detected","Nenhum erro detectado","لم تُرصد أخطاء"},
    {"Compatibility","Compatibilidade","التوافق"},
    {"Files:","Arquivos:","الملفات:"},
    {"Last measurement","Última medição","القياس الأخير"},
    {"Measuring confirmed kills","Medindo eliminações confirmadas","قياس الإقصاءات المؤكدة"},
    {"Purchase stopped: funds, inventory, or server response","Compra interrompida: saldo, inventário ou resposta do servidor","توقف الشراء: الرصيد أو المخزون أو استجابة الخادم"},
    {"Latency within target (150 ms)","Latência dentro da meta (150 ms)","زمن الاستجابة ضمن الهدف (150 ملّي ثانية)"},
    {"Looking for lower latency","Buscando menor latência","البحث عن زمن استجابة أقل"},
    {"Could not start Auto Kill","Não foi possível iniciar Auto Kill","تعذر بدء الإقصاء التلقائي"},
    {"Reconnection unavailable","Reconexão indisponível","إعادة الاتصال غير متاحة"},
    {"Unavailable","Indisponível","غير متاح"},
    {"Stop Fast Farm before changing pets","Pare o Fast Farm antes de mudar as pets","أوقف Fast Farm قبل تغيير الحيوانات"},
    {"No compatible pets","Nenhuma pet compatível","لا توجد حيوانات متوافقة"},
    {"Equipment was not confirmed","O equipamento não foi confirmado","لم يتأكد التجهيز"},
    {"Young0x Hub: THE BEST MUSCLE LEGENDS SCRIPTS 💪","Young0x Hub: OS MELHORES SCRIPTS DE MUSCLE LEGENDS 💪","Young0x Hub: أفضل سكربتات MUSCLE LEGENDS 💪"},
    {"Info","Informações","المعلومات"},
    {"Main","Principal","الرئيسية"},
    {"Farm","Treino","التدريب"},
    {"Pets","Pets","الحيوانات"},
    {"Rebirths","Renascimentos","إعادة الولادة"},
    {"Kills","Eliminações","الإقصاءات"},
    {"Output","Output","السجل"},
    {"Misc","Extras","إضافات"},
    {"Rebirths without packs","Renascimentos sem pacotes","إعادة الولادة دون حزم"},
    {"Kills across servers","Eliminações entre servidores","إقصاءات عبر الخوادم"},
    {"Automatic strength","Força automática","زيادة القوة تلقائيًا"},
    {"Combined training","Treinamento combinado","تدريب متكامل"},
    {"Choose what to farm","Escolha o que treinar","اختر ما تريد تطويره"},
    {"This is a paid script. If you are interested in buying it, open a ticket.","Este script é pago. Se você tiver interesse em comprá-lo, abra um ticket.","هذا السكربت مدفوع. إذا كنت مهتمًا بشرائه، فافتح تذكرة."},
    {"Activity","Atividade","النشاط"},
    {"Systems","Sistemas","الأنظمة"},
    {"Diagnostics","Diagnóstico","التشخيص"},
    {"All","Tudo","الكل"},
    {"Errors","Erros","الأخطاء"},
    {"Pause","Pausar","إيقاف مؤقت"},
    {"Resume","Retomar","استئناف"},
    {"Clear","Limpar","مسح"},
    {"Pause reading","Pausar leitura","إيقاف القراءة مؤقتًا"},
    {"Resume reading","Retomar leitura","استئناف القراءة"},
    {"History cleared","Histórico limpo","تم مسح السجل"},
    {"Ready","Pronto","جاهز"},
    {"Disconnected","Desconectado","غير متصل"},
    {"Off","Desligado","متوقف"},
    {"Responses sent","Respostas enviadas","الاستجابات المرسلة"},
    {"Paused for latency","Pausado por latência","متوقف مؤقتًا بسبب التأخير"},
    {"Multiplier active","Multiplicador ativo","المضاعف نشط"},
    {"Waiting for an available egg","Aguardando um ovo disponível","بانتظار بيضة متاحة"},
    {"Looking for targets","Procurando alvos","البحث عن أهداف"},
    {"In the brawl","Na batalha","داخل المعركة"},
    {"Waiting for the brawl","Aguardando a batalha","بانتظار المعركة"},
    {"Looking for a brawl","Procurando uma batalha","البحث عن معركة"},
    {"Switching servers","Trocando de servidor","تغيير الخادم"},
    {"Monitoring the server","Monitorando o servidor","مراقبة الخادم"},
    {"Option enabled","Opção ativada","الخيار مفعّل"},
    {"Performance","Desempenho","الأداء"},
    {"FPS and latency measured in this session","FPS e latência medidos nesta sessão","معدل الإطارات والتأخير المقاسان في هذه الجلسة"},
    {"Lua memory","Memória Lua","ذاكرة Lua"},
    {"Unavailable","Indisponível","غير متاح"},
    {"Memory reported by the Lua environment, not total Roblox RAM","Memória do ambiente Lua, não a RAM total do Roblox","ذاكرة بيئة Lua، وليست إجمالي ذاكرة Roblox"},
    {"Hub tasks","Tarefas do hub","مهام الواجهة"},
    {"Registered routines that work in the background","Rotinas registradas que trabalham em segundo plano","عمليات مسجلة تعمل في الخلفية"},
    {"Active listeners","Escutas ativas","المستمعات النشطة"},
    {"Listeners for buttons, game changes and events, not network connections","Escutas de botões, mudanças no jogo e eventos, não conexões de rede","مستمعات للأزرار وتغييرات اللعبة والأحداث، وليست اتصالات شبكة"},
    {"Save files","Salvar arquivos","حفظ الملفات"},
    {"Yes","Sim","نعم"},
    {"Executor support for saving profiles and settings","Suporte do executor para salvar perfis e ajustes","دعم أداة التنفيذ لحفظ الملفات الشخصية والإعدادات"},
    {"Continue after switching","Continuar após a troca","المتابعة بعد التبديل"},
    {"The executor supports continuity; the server switch still needs confirmation","O executor oferece continuidade; a troca de servidor ainda precisa ser confirmada","تدعم أداة التنفيذ المتابعة، لكن نجاح تغيير الخادم يحتاج إلى تأكيد"},
    {"Errors in history","Erros no histórico","أخطاء في السجل"},
    {"Only logged errors; this does not certify every feature","Somente erros registrados; isso não garante todas as funções","يعرض الأخطاء المسجلة فقط، ولا يضمن عمل جميع الميزات"},
    {"Opened","Abriu","فتح"},
    {"Pressed","Pressionou","ضغط"},
    {"Enabled","Ativou","فعّل"},
    {"Disabled","Desativou","أوقف"},
    {"Selected","Selecionou","اختار"},
    {"Entered","Digitou","أدخل"},
    {"Adjusted","Ajustou","عدّل"},
    {"Notice","Aviso","تنبيه"},
    {"Server","Servidor","الخادم"},
    {"Theme","Tema","السمة"},
    {"Information","Informação","معلومات"},
    {"No notices logged","Nenhum aviso registrado","لا توجد تنبيهات مسجلة"},
    {"No activity logged.","Nenhuma atividade registrada.","لا يوجد نشاط مسجل."},
    {"Reading paused; features keep running","Leitura pausada; as funções continuam ativas","القراءة متوقفة مؤقتًا، والميزات تواصل العمل"},
    {"Newest first","Mais recentes primeiro","الأحدث أولًا"},
    {"Observed status; tap a row for details","Estado observado; toque em uma linha para ver mais","الحالة المرصودة؛ اضغط على صف لعرض التفاصيل"},
    {"Tap a row to see what it means","Toque em uma linha para saber o que significa","اضغط على صف لمعرفة معناه"},
    {"Young0x Hub ready","Young0x Hub pronto","Young0x Hub جاهز"},
    {"Choose a pet from the shop","Escolha uma mascote da loja","اختر حيوانًا أليفًا من المتجر"},
    {"Waiting for 5 pets of the same type","Aguardando 5 mascotes do mesmo tipo","في انتظار 5 حيوانات أليفة من النوع نفسه"},
    {"Equipped or protected pets will not be evolved","Mascotes equipadas ou protegidas não serão evoluídas","لن يتم تطوير الحيوانات الأليفة المجهزة أو المحمية"},
    {"Evolution is unavailable on this server","A evolução não está disponível neste servidor","التطوير غير متاح في هذا الخادم"},
    {"Waiting for evolution confirmation","Aguardando a confirmação da evolução","في انتظار تأكيد التطوير"},
    {"Could not request evolution","Não foi possível solicitar a evolução","تعذر طلب التطوير"},
    {"Pet evolved: ","Mascote evoluída: ","تم تطوير الحيوان الأليف: "},
    {"Evolution paused: no confirmation from the server","Evolução pausada: o servidor não confirmou","تم إيقاف التطوير مؤقتًا: لم يصل تأكيد من الخادم"},
    {"The wheel did not accept the spin","A roleta não aceitou o giro","لم تقبل العجلة المحاولة"},
    {"Waiting for spin confirmation","Aguardando a confirmação do giro","في انتظار تأكيد المحاولة"},
    {"Another reward is being claimed","Outra recompensa está sendo coletada","يتم الحصول على مكافأة أخرى الآن"},
    {"Wait for the battle or server change to finish","Espere a batalha ou a troca de servidor terminar","انتظر حتى تنتهي المعركة أو عملية تغيير الخادم"},
    {"Could not pause training","Não foi possível pausar o treino","تعذّر إيقاف التدريب مؤقتًا"},
    {"Your character is not ready","Seu personagem ainda não está pronto","شخصيتك ليست جاهزة"},
    {"The chest service was not found","O serviço de baús não foi encontrado","لم يتم العثور على خدمة الصناديق"},
    {"Your character changed during the trip","Seu personagem mudou durante o percurso","تغيّرت شخصيتك أثناء التنقل"},
    {"The server is still processing the previous chest","O servidor ainda está processando o baú anterior","ما زال الخادم يعالج الصندوق السابق"},
    {"The server did not confirm the chest; the trip was canceled","O servidor não confirmou o baú; o percurso foi cancelado","لم يؤكد الخادم الصندوق؛ تم إلغاء التنقل"},
    {"Could not resume: ","Não foi possível retomar: ","تعذّر الاستئناف: "},
    {"+1 confirmed spin","+1 giro confirmado","+1 محاولة مؤكدة"},
    {"claimed","coletado","تم الحصول عليه"},
    {"Confirmed chests: ","Baús confirmados: ","الصناديق المؤكدة: "},
    {"unconfirmed","sem confirmação","غير مؤكد"},
    {"Auto Rebirth","Renascimento automático","إعادة الولادة التلقائية"},
    {"Selected profile","Perfil selecionado","الملف المحدد"},
    {"Save changes","Salvar alterações","حفظ التغييرات"},
    {"New profile","Novo perfil","ملف جديد"},
    {"Boss","Boss","الزعيم"},
    {"No active boss","Nenhum boss ativo","لا يوجد زعيم نشط"},
    {"Boss health:","Vida do boss:","صحة الزعيم:"},
    {"Hide boss effects","Ocultar efeitos do boss","إخفاء مؤثرات الزعيم"},
    {"Attack the boss","Atacar o boss","مهاجمة الزعيم"},
    {"Boss defeated · claiming reward","Boss derrotado · coletando recompensa","هُزم الزعيم · استلام المكافأة"},
    {"The boss event is unavailable","O evento do boss não está disponível","حدث الزعيم غير متاح"},
    {"Fast Strength","Força rápida","قوة سريعة"},
    {"Fast Rebirths","Renascimentos rápidos","إعادات ولادة سريعة"},
    {"Durability + Strength","Durabilidade + Força","المتانة + القوة"},
    {"Detects your packs and uses the fastest method","Detecta seus pacotes e usa o método mais rápido","يكتشف حزمك ويستخدم أسرع طريقة"},
    {"The best option for you","A melhor opção para você","أفضل خيار لك"},
    {"Auto Kill · Auto Win Brawl · Server Hop · Anti Lag","Auto Kill · Auto Win Brawl · Server Hop · Anti Lag","قتل تلقائي · فوز تلقائي · تبديل الخادم · تقليل التقطيع"},
    {"Your best pets · The best available machine","Seus melhores pets · A melhor máquina disponível","أفضل حيواناتك · أفضل آلة متاحة"},
    {"The best rock · Punch and combined exercises","A melhor rocha · Soco e exercícios combinados","أفضل صخرة · اللكم والتمارين معًا"},
    {"Switch servers if I get killed","Trocar de servidor se me matarem","تبديل الخادم إذا قتلوني"},
    {"Many players","Muitos jogadores","لاعبون كثر"},
    {"Balanced","Equilibrado","متوازن"},
    {"Almost empty","Quase vazio","شبه فارغ"},
    {"Boss Battles","Batalhas de chefes","معارك الزعماء"},
    {"Boss:","Chefe:","الزعيم:"},
    {"Health:","Vida:","الحياة:"},
    {"Auto Farm Boss","Farm automático de chefes","صيد الزعماء تلقائيًا"},
    {"Boss Anti-Lag","Anti-lag do chefe","تقليل تأخير الزعيم"},
    {"Waiting for the next boss","Aguardando o próximo chefe","بانتظار الزعيم التالي"},
    {"Waiting for character","Aguardando o personagem","بانتظار الشخصية"},
    {"Boss defeated · finding chest","Chefe derrotado · procurando baú","هُزم الزعيم · جارٍ البحث عن الصندوق"},
    {"Boss Battles unavailable","Batalhas de chefes indisponíveis","معارك الزعماء غير متاحة"},
    {"Boss Arena","Arena dos chefes","ساحة الزعماء"},
    {"Boss Battle","Batalha de chefe","معركة الزعيم"},
    {"Estimated rate","Ritmo estimado","المعدل التقديري"},
    {"Auto Farm Kills","Farm de abates","تجميع القتلات تلقائيًا"},
    {"Auto Strength","Força automática","تدريب القوة تلقائيًا"},
    {"Strength + Durability","Força + Durabilidade","القوة + المتانة"},
    {"Weight · Pushups · King · Rebirth","Peso · Flexões · King · Renascimento","أوزان · ضغط · King · إعادة الولادة"},
    {"Auto Kill · Auto Win Brawl · Server Hop","Abates · Vitórias · Troca de servidor","قتلات · معارك · تبديل الخادم"},
    {"Your best pets and a machine you can use","Suas melhores mascotes e uma máquina","أفضل حيواناتك وجهاز يناسبك"},
    {"Rock and exercises together","Rocha e exercícios ao mesmo tempo","صخرة وتمارين معًا"},
    {"Choose what to farm","Escolha o que quer treinar","اختر ما تريد تطويره"},
    {"Choose your mode","Escolha seu modo","اختر وضعك"},
    {"Equipping your best pets","Equipando suas melhores mascotes","تجهيز أفضل حيواناتك"},
    {"Waiting for a free machine","Aguardando uma máquina livre","بانتظار جهاز شاغر"},
    {"Training while waiting for a free machine","Treinando enquanto aguarda uma máquina","التدريب لحين توفر جهاز شاغر"},
    {"Getting onto ","Indo para ","التوجه إلى "},
    {" pets"," mascotes"," حيوانات"},
    {"Waiting for server response","Aguardando resposta do servidor","بانتظار رد الخادم"},
    {"Could not start Auto Kill","Não foi possível iniciar Auto Kill","تعذر بدء القتل التلقائي"},
    {"Could not start Auto Win Brawl","Não foi possível iniciar Auto Win Brawl","تعذر بدء الفوز التلقائي بالمعارك"},
    {"Reconnection unavailable","Reconexão indisponível","إعادة الاتصال غير متاحة"},
    {"Waiting for character","Aguardando personagem","بانتظار الشخصية"},
    {"Ready to rebirth","Pronto para renascer","جاهز لإعادة الولادة"},
    {"Retrying after a pause","Tentando novamente após uma pausa","إعادة المحاولة بعد مهلة"},
    {"Training Pushups","Treinando flexões","التدريب على تمارين الضغط"},
    {"Recovering strength with Weight","Recuperando força com pesos","استعادة القوة بالأوزان"},
    {"Training until a rock is unlocked","Treinando até desbloquear uma rocha","التدريب حتى فتح صخرة"},
    {"Mode stopped: check Output","O modo parou: veja Output","توقف الوضع؛ راجع Output"},
    {"AFK mode","Modo AFK","وضع AFK"},
    {"‹ Choose another mode","‹ Escolher outro modo","‹ اختيار وضع آخر"},
    {"Start AFK mode","Iniciar modo AFK","بدء وضع AFK"},
    {"Find your next server","Encontre seu próximo servidor","اعثر على خادمك التالي"},
    {"Full (18-19)","Cheio (18-19)","شبه ممتلئ (18-19)"},
    {"Quiet (1-2)","Tranquilo (1-2)","قليل اللاعبين (1-2)"},
    {"Mid-size (8-14)","Médio (8-14)","متوسط (8-14)"},
    {"Lower latency","Menor latência","تأخير أقل"},
    {"Available King","King livre","King شاغر"},
    {"Search","Buscar","بحث"},
    {"players","jogadores","لاعبون"},
    {" players"," jogadores"," لاعبين"},
    {"Choose a destination and scan.","Escolha um destino e busque.","اختر وجهة وابدأ البحث."},
    {"Your enabled options carry over.","Suas opções ativas continuam na troca.","تستمر خياراتك المفعلة بعد التبديل."},
    {"Server found","Servidor encontrado","تم العثور على خادم"},
    {"King is checked on arrival; searching 1–2 player servers.","King será verificado ao chegar; busca por 1–2 jogadores.","يُفحص King عند الوصول؛ البحث عن خوادم فيها 1–2 لاعب."},
    {"Listed ping: ","Ping informado: ","التأخير المعلن: "},
    {" · may change on arrival."," · pode mudar ao entrar."," · قد يتغير عند الدخول."},
    {"Space was available when checked.","Havia espaço no momento da consulta.","كان هناك مكان متاح عند الفحص."},
    {"No servers match that filter right now.","Nenhum servidor corresponde ao filtro agora.","لا توجد خوادم تطابق الفلتر حاليًا."},
    {"Scan again or choose another destination.","Busque novamente ou escolha outro destino.","أعد البحث أو اختر وجهة أخرى."},
    {"Scan","Buscar","فحص"},
    {"Searching servers...","Buscando servidores...","جارٍ البحث عن خوادم..."},
    {"Could not query Roblox.","Não foi possível consultar o Roblox.","تعذر الاستعلام من Roblox."},
    {"Join server  ›","Entrar no servidor  ›","دخول الخادم  ›"},
    {"Preparing to switch...","Preparando a troca...","جارٍ التحضير للتبديل..."},
    {"Connecting...","Conectando...","جارٍ الاتصال..."},
    {"Could not switch servers","Não foi possível trocar de servidor","تعذر تغيير الخادم"},
    {"Search until the target is met","Buscar até alcançar o objetivo","البحث حتى تحقق الهدف"},
    {"Switch if I am eliminated","Trocar se eu for eliminado","التبديل عند إقصائي"},
    {"Switch if a killer joins","Trocar se entrar um killer","التبديل عند دخول لاعب مهاجم"},
    {"Killer detected. Switching...","Killer detectado. Trocando...","تم رصد لاعب مهاجم. جارٍ التبديل..."},
    {"Claim King when available","Assumir King quando estiver livre","الحصول على King عندما يكون شاغرًا"},
    {"Next scan in ","Próxima busca em ","الفحص التالي بعد "},
    {"The switch was not confirmed. Try again.","A troca não foi confirmada. Tente novamente.","لم يتأكد التبديل. حاول مرة أخرى."},
    {"The search is still running.","A busca ainda está em andamento.","ما زال البحث جاريًا."},
    {"Roblox requested a pause. Retry in ","O Roblox pediu uma pausa. Tente em ","طلب Roblox الانتظار. أعد المحاولة بعد "},
    {"Roblox returned an incomplete response.","O Roblox retornou uma resposta incompleta.","أعاد Roblox استجابة غير مكتملة."},
    {"Roblox limited the search. Wait a few seconds.","O Roblox limitou a busca. Espere alguns segundos.","قيّد Roblox البحث. انتظر بضع ثوانٍ."},
    {"Your executor cannot keep the script running after switching.","Seu executor não permite continuar o script após a troca.","لا تدعم أداة التنفيذ استمرار السكربت بعد التبديل."},
    {"No other available server was found.","Nenhum outro servidor disponível foi encontrado.","لم يُعثر على خادم آخر متاح."},
    {"Could not prepare reconnection.","Não foi possível preparar a reconexão.","تعذر التحضير لإعادة الاتصال."},
    {"Roblox rejected the switch. Try again.","O Roblox recusou a troca. Tente novamente.","رفض Roblox التبديل. حاول مرة أخرى."},
    {"Connecting to ","Conectando a ","جارٍ الاتصال بـ "},
    {"A server switch is already in progress.","Uma troca de servidor já está em andamento.","هناك تبديل خادم جارٍ بالفعل."},
    {"Roblox could not connect. Looking for another server...","O Roblox não conectou. Buscando outro servidor...","تعذر اتصال Roblox. جارٍ البحث عن خادم آخر..."},
    {"Waiting for the brawl to finish...","Aguardando a batalha terminar...","بانتظار انتهاء المعركة..."},
    {"Win confirmed. Looking for another brawl...","Vitória confirmada. Buscando outra batalha...","تأكد الفوز. جارٍ البحث عن معركة أخرى..."},
    {"Brawl finished. Looking for another...","Batalha encerrada. Buscando outra...","انتهت المعركة. جارٍ البحث عن أخرى..."},
    {"Brawls","Vitórias em batalhas","انتصارات المعارك"},
    {"Equipped pets","Pets equipados","الحيوانات المجهزة"},
    {"Choose your next server","Escolha seu próximo servidor","اختر خادمك التالي"},
    {"Destination","Destino","الوجهة"},
    {"Many players (18-19)","Muitos jogadores (18-19)","لاعبون كثر (18-19)"},
    {"Almost empty (1-2)","Quase vazio (1-2)","شبه فارغ (1-2)"},
    {"Best connection","Melhor conexão","أفضل اتصال"},
    {"Find a free King","Buscar King livre","البحث عن King شاغر"},
    {"Find server","Buscar servidor","البحث عن خادم"},
    {"You have not searched for a server yet.","Você ainda não buscou um servidor.","لم تبحث عن خادم بعد."},
    {"Choose a destination and press Find server.","Escolha um destino e toque em Buscar servidor.","اختر وجهة واضغط البحث عن خادم."},
    {"Join now  ›","Entrar agora  ›","الدخول الآن  ›"},
    {"Server ready to join","Servidor pronto para entrar","الخادم جاهز للدخول"},
    {"Server with 1–2 players. King availability is confirmed after joining.","Servidor com 1–2 jogadores. O King é confirmado ao entrar.","خادم فيه 1–2 لاعبين. يتم تأكيد توفر King بعد الدخول."},
    {"Reported ping: ","Ping informado: ","زمن الاستجابة المعلن: "},
    {"There was room when the search ran.","Havia espaço no momento da busca.","كانت هناك مساحة عند البحث."},
    {"Destination updated","Destino atualizado","تم تحديث الوجهة"},
    {"Press Find server to get a new option.","Toque em Buscar servidor para encontrar uma nova opção.","اضغط البحث عن خادم للعثور على خيار جديد."},
    {"No server was found for that destination.","Nenhum servidor foi encontrado para esse destino.","لم يتم العثور على خادم لهذه الوجهة."},
    {"Try again or choose a different destination.","Tente novamente ou escolha outro destino.","حاول مجددًا أو اختر وجهة مختلفة."},
    {"Automations","Automações","الأتمتة"},
    {"Automatically find another","Buscar outro automaticamente","البحث عن خادم آخر تلقائيًا"},
    {"Switch servers if I die","Trocar de servidor se eu morrer","تبديل الخادم إذا مت"},
    {"Avoid servers with killers","Evitar servidores com killers","تجنب الخوادم التي فيها مهاجمون"},
    {"Claim King after joining","Assumir King ao entrar","الحصول على King بعد الدخول"},
    {"Next search in ","Próxima busca em ","البحث التالي بعد "},
    {"Searching automatically","Buscando automaticamente","جارٍ البحث تلقائيًا"},
    {"This may take a few seconds.","Isso pode levar alguns segundos.","قد يستغرق هذا بضع ثوانٍ."},
    {"Ready to search","Pronto para buscar","جاهز للبحث"},
    {"Event boss","Chefe do evento","زعيم الحدث"},
    {"Status:","Estado:","الحالة:"},
    {"No active boss","Nenhum chefe ativo","لا يوجد زعيم نشط"},
    {"Boss health:","Vida do chefe:","صحة الزعيم:"},
    {"Hide heavy boss effects","Ocultar efeitos pesados do chefe","إخفاء مؤثرات الزعيم الثقيلة"},
    {"Attack boss automatically","Atacar o chefe automaticamente","مهاجمة الزعيم تلقائيًا"},
    {"Boss defeated · claiming reward","Chefe derrotado · coletando recompensa","تمت هزيمة الزعيم · استلام المكافأة"},
    {"The boss event is unavailable","O evento de chefe não está disponível","حدث الزعيم غير متاح"},
}
    local extra = {
    {"Principal","Home"},
    {"Combate","Combat"},
    {"Progreso por mascota","Progress per pet"},
    {"Bonus equipado:","Equipped bonus:"},
    {"Mejora posible:","Possible improvement:"},
    {"Progreso:","Progress:"},
    {"Elegí tu modo","Choose your mode"},
    {"Elegir otro modo","Choose another mode"},
    {"El mejor ejercicio disponible para vos","Your best available exercise"},
    {"Roca y entrenamiento al mismo tiempo","Rock and training at the same time"},
    {"Kills confirmadas y cambio de servidor","Confirmed kills and server changes"},
    {"Listo para iniciar","Ready to start"},
    {"Esperando personaje","Waiting for character"},
    {"Esperando respuesta del servidor","Waiting for server response"},
    {"Listo para renacer","Ready to rebirth"},
    {"Reintentando con pausa","Retrying after a pause"},
    {"Entrenando Pushups","Training Pushups"},
    {"Recuperando fuerza con Weight","Recovering strength with Weight"},
    {"Entrenando hasta desbloquear una roca","Training until a rock is unlocked"},
    {"Entrenando","Training"},
    {"Cambiando de servidor","Changing servers"},
    {"Buscando objetivos","Finding targets"},
    {"Actividad","Activity"},
    {"Sistemas","Systems"},
    {"Diagnóstico","Diagnostics"},
    {"Mostrar","Show"},
    {"Todo","All"},
    {"Errores","Errors"},
    {"Acciones","Actions"},
    {"Servidor","Server"},
    {"Pausar lectura","Pause feed"},
    {"Sin actividad registrada.","No activity recorded."},
    {"Conectado","Connected"},
    {"Desconectado","Disconnected"},
    {"respuestas","responses"},
    {"Esperando fin del multiplicador","Waiting for the multiplier to end"},
    {"Rendimiento","Performance"},
    {"Memoria Lua","Lua memory"},
    {"Recursos","Resources"},
    {"tareas","tasks"},
    {"conexiones","connections"},
    {"Sin errores detectados","No errors detected"},
    {"Compatibilidad","Compatibility"},
    {"Archivos:","Files:"},
    {"Última medición","Last measurement"},
    {"Midiendo kills confirmadas","Measuring confirmed kills"},
    {"Compra detenida: fondos, inventario o respuesta del servidor","Purchase stopped: funds, inventory, or server response"},
    {"Latencia dentro del objetivo (150 ms)","Latency within target (150 ms)"},
    {"Buscando mejor latencia","Looking for lower latency"},
    {"No se pudo iniciar Auto Kill","Could not start Auto Kill"},
    {"Reconexión no disponible","Reconnection unavailable"},
    {"No disponible","Unavailable"},
    {"Detené Fast Farm antes de cambiar pets","Stop Fast Farm before changing pets"},
    {"No hay pets compatibles","No compatible pets"},
    {"Sin pets compatibles","No compatible pets"},
    {"No se confirmó el equipamiento","Equipment was not confirmed"},
    {"Português","Português"},
    {"العربية","العربية"},
    {"Young0x Hub: LOS MEJORES SCRIPTS DE MUSCLE LEGENDS 💪","Young0x Hub: THE BEST MUSCLE LEGENDS SCRIPTS 💪"},
    {"Renacimientos sin packs","Rebirths without packs"},
    {"Kills entre servidores","Kills across servers"},
    {"Fuerza automáticamente","Automatic strength"},
    {"Entrenamiento combinado","Combined training"},
    {"Elegí qué querés farmear","Choose what to farm"},
    {"Actividad","Activity"},
    {"Sistemas","Systems"},
    {"Diagnóstico","Diagnostics"},
    {"Todo","All"},
    {"Errores","Errors"},
    {"Pausar","Pause"},
    {"Reanudar","Resume"},
    {"Limpiar","Clear"},
    {"Pausar lectura","Pause reading"},
    {"Reanudar lectura","Resume reading"},
    {"Historial limpiado","History cleared"},
    {"Listo","Ready"},
    {"Desconectado","Disconnected"},
    {"Apagado","Off"},
    {"Respuestas enviadas","Responses sent"},
    {"Pausa por ping","Paused for latency"},
    {"Multiplicador activo","Multiplier active"},
    {"Esperando un huevo disponible","Waiting for an available egg"},
    {"Buscando objetivos","Looking for targets"},
    {"En la pelea","In the brawl"},
    {"Esperando la pelea","Waiting for the brawl"},
    {"Buscando una pelea","Looking for a brawl"},
    {"Cambiando de servidor","Switching servers"},
    {"Monitoreando servidor","Monitoring the server"},
    {"Opción encendida","Option enabled"},
    {"Rendimiento","Performance"},
    {"FPS y latencia medidos en esta sesión","FPS and latency measured in this session"},
    {"Memoria Lua","Lua memory"},
    {"No disponible","Unavailable"},
    {"Memoria del entorno Lua; no es la RAM total de Roblox","Memory reported by the Lua environment, not total Roblox RAM"},
    {"Tareas del hub","Hub tasks"},
    {"Rutinas registradas que realizan trabajo en segundo plano","Registered routines that work in the background"},
    {"Conexiones activas","Active listeners"},
    {"Escuchas de botones, cambios del juego y eventos; no conexiones de red","Listeners for buttons, game changes and events, not network connections"},
    {"Guardar archivos","Save files"},
    {"Sí","Yes"},
    {"Función del executor para conservar perfiles y ajustes","Executor support for saving profiles and settings"},
    {"Continuar tras un cambio","Continue after switching"},
    {"El executor ofrece continuidad; el cambio de servidor debe confirmarse","The executor supports continuity; the server switch still needs confirmation"},
    {"Errores en el historial","Errors in history"},
    {"Solo los errores registrados; no certifica todas las funciones","Only logged errors; this does not certify every feature"},
    {"Abrió","Opened"},
    {"Pulsó","Pressed"},
    {"Activó","Enabled"},
    {"Desactivó","Disabled"},
    {"Eligió","Selected"},
    {"Escribió","Entered"},
    {"Ajustó","Adjusted"},
    {"Aviso","Notice"},
    {"Servidor","Server"},
    {"Tema","Theme"},
    {"Información","Information"},
    {"Sin avisos registrados","No notices logged"},
    {"Sin actividad registrada.","No activity logged."},
    {"Lectura pausada; las funciones siguen activas","Reading paused; features keep running"},
    {"Más reciente primero","Newest first"},
    {"Estado observado; tocá una fila para ver más","Observed status; tap a row for details"},
    {"Tocá una fila para ver qué significa","Tap a row to see what it means"},
    {"Young0x Hub listo","Young0x Hub ready"},
    {"Elegí una pet de la tienda","Choose a pet from the shop"},
    {"Esperando 5 pets del mismo tipo","Waiting for 5 pets of the same type"},
    {"No se evolucionan pets equipadas o protegidas","Equipped or protected pets will not be evolved"},
    {"Evolución no disponible en este servidor","Evolution is unavailable on this server"},
    {"Esperando confirmación de la evolución","Waiting for evolution confirmation"},
    {"No se pudo solicitar la evolución","Could not request evolution"},
    {"Pet evolucionada: ","Pet evolved: "},
    {"Evolución pausada: no llegó la confirmación del servidor","Evolution paused: no confirmation from the server"},
    {"La ruleta no aceptó el giro","The wheel did not accept the spin"},
    {"Esperando confirmación del giro","Waiting for spin confirmation"},
    {"Hay otra recompensa en curso","Another reward is being claimed"},
    {"Esperá a que termine la pelea o el cambio de servidor","Wait for the battle or server change to finish"},
    {"No se pudo pausar el entrenamiento","Could not pause training"},
    {"El personaje no está listo","Your character is not ready"},
    {"No se encontró el control de cofres","The chest service was not found"},
    {"El personaje cambió durante el recorrido","Your character changed during the trip"},
    {"El servidor sigue procesando el cofre anterior","The server is still processing the previous chest"},
    {"El servidor no confirmó el cofre; se canceló el recorrido","The server did not confirm the chest; the trip was canceled"},
    {"No se pudo reanudar: ","Could not resume: "},
    {"+1 giro confirmado","+1 confirmed spin"},
    {"reclamado","claimed"},
    {"Cofres confirmados: ","Confirmed chests: "},
    {"sin confirmar","unconfirmed"},
    {"Auto Rebirth","Auto Rebirth"},
    {"Perfil seleccionado","Selected profile"},
    {"Guardar cambios","Save changes"},
    {"Nuevo perfil","New profile"},
    {"Boss","Boss"},
    {"Sin boss activo","No active boss"},
    {"Vida del boss:","Boss health:"},
    {"Ocultar efectos del boss","Hide boss effects"},
    {"Atacar al boss","Attack the boss"},
    {"Boss derrotado · reclamando recompensa","Boss defeated · claiming reward"},
    {"El evento del boss no está disponible","The boss event is unavailable"},
    {"Fuerza rápida","Fast Strength"},
    {"Rebirths rápidos","Fast Rebirths"},
    {"Durabilidad + Fuerza","Durability + Strength"},
    {"Detecta tus packs y usa el método más rápido","Detects your packs and uses the fastest method"},
    {"La mejor opción para el usuario","The best option for you"},
    {"Auto Kill · Auto Win Brawl · Server Hop · Anti Lag","Auto Kill · Auto Win Brawl · Server Hop · Anti Lag"},
    {"Tus mejores pets · La mejor máquina disponible","Your best pets · The best available machine"},
    {"La mejor roca · Punch y ejercicios combinados","The best rock · Punch and combined exercises"},
    {"Cambiar de server si me matan","Switch servers if I get killed"},
    {"Con mucha gente","Many players"},
    {"Equilibrado","Balanced"},
    {"Casi vacío","Almost empty"},
    {"Boss Battles","Boss Battles"},
    {"Boss:","Boss:"},
    {"Vida:","Health:"},
    {"Auto Farm Boss","Auto Farm Boss"},
    {"Boss Anti-Lag","Boss Anti-Lag"},
    {"Esperando próximo boss","Waiting for the next boss"},
    {"Esperando personaje","Waiting for character"},
    {"Boss derrotado · buscando cofre","Boss defeated · finding chest"},
    {"Boss Battles no disponible","Boss Battles unavailable"},
    {"Boss Arena","Boss Arena"},
    {"Boss Battle","Boss Battle"},
    {"Ritmo estimado","Estimated rate"},
    {"Auto Farm Kills","Auto Farm Kills"},
    {"Auto Strength","Auto Strength"},
    {"Fuerza + Durabilidad","Strength + Durability"},
    {"Weight · Pushups · King · Rebirth","Weight · Pushups · King · Rebirth"},
    {"Auto Kill · Auto Win Brawl · Server Hop","Auto Kill · Auto Win Brawl · Server Hop"},
    {"Tus mejores pets y una máquina para vos","Your best pets and a machine you can use"},
    {"Roca y ejercicios al mismo tiempo","Rock and exercises together"},
    {"Elegí qué querés farmear","Choose what to farm"},
    {"Elegí tu modo","Choose your mode"},
    {"Equipando tus mejores pets","Equipping your best pets"},
    {"Esperando una máquina libre","Waiting for a free machine"},
    {"Entrenando mientras se libera una máquina","Training while waiting for a free machine"},
    {"Subiendo a ","Getting onto "},
    {" pets"," pets"},
    {"Esperando respuesta del servidor","Waiting for server response"},
    {"No se pudo iniciar Auto Kill","Could not start Auto Kill"},
    {"No se pudo iniciar Auto Win Brawl","Could not start Auto Win Brawl"},
    {"Reconexión no disponible","Reconnection unavailable"},
    {"Esperando personaje","Waiting for character"},
    {"Listo para renacer","Ready to rebirth"},
    {"Reintentando con pausa","Retrying after a pause"},
    {"Entrenando Pushups","Training Pushups"},
    {"Recuperando fuerza con Weight","Recovering strength with Weight"},
    {"Entrenando hasta desbloquear una roca","Training until a rock is unlocked"},
    {"El modo se detuvo: revisá Output","Mode stopped: check Output"},
    {"Modo AFK","AFK mode"},
    {"‹ Elegir otro modo","‹ Choose another mode"},
    {"Iniciar modo AFK","Start AFK mode"},
    {"Encontrá tu próximo servidor","Find your next server"},
    {"Lleno (18-19)","Full (18-19)"},
    {"Solitario (1-2)","Quiet (1-2)"},
    {"Equilibrado (8-14)","Mid-size (8-14)"},
    {"Mejor latencia","Lower latency"},
    {"King libre","Available King"},
    {"Buscar","Search"},
    {"jugadores","players"},
    {" jugadores"," players"},
    {"Elegí un destino y analizá.","Choose a destination and scan."},
    {"Tus opciones activas viajan con vos.","Your enabled options carry over."},
    {"Candidato encontrado","Server found"},
    {"King se comprueba al llegar; búsqueda de 1–2 jugadores.","King is checked on arrival; searching 1–2 player servers."},
    {"Ping publicado: ","Listed ping: "},
    {" · puede variar al entrar."," · may change on arrival."},
    {"Espacio disponible al consultar.","Space was available when checked."},
    {"No hay candidatos con ese filtro en este momento.","No servers match that filter right now."},
    {"Podés volver a analizar o elegir otro destino.","Scan again or choose another destination."},
    {"Analizar","Scan"},
    {"Buscando servidores...","Searching servers..."},
    {"No se pudo consultar Roblox.","Could not query Roblox."},
    {"Entrar al servidor  ›","Join server  ›"},
    {"Preparando cambio...","Preparing to switch..."},
    {"Conectando...","Connecting..."},
    {"No se pudo cambiar de servidor","Could not switch servers"},
    {"Buscar hasta cumplir el objetivo","Search until the target is met"},
    {"Cambiar si me eliminan","Switch if I am eliminated"},
    {"Cambiar si entra un killer","Switch if a killer joins"},
    {"Killer detectado. Cambiando...","Killer detected. Switching..."},
    {"Reclamar King al encontrarlo libre","Claim King when available"},
    {"Próximo análisis en ","Next scan in "},
    {"El cambio no se confirmó. Volvé a intentar.","The switch was not confirmed. Try again."},
    {"La búsqueda sigue en curso.","The search is still running."},
    {"Roblox pidió esperar. Reintentá en ","Roblox requested a pause. Retry in "},
    {"Roblox devolvió una respuesta incompleta.","Roblox returned an incomplete response."},
    {"Roblox limitó la búsqueda. Esperá unos segundos.","Roblox limited the search. Wait a few seconds."},
    {"Tu executor no permite mantener el script al cambiar.","Your executor cannot keep the script running after switching."},
    {"No encontré otro servidor disponible.","No other available server was found."},
    {"No se pudo preparar la reconexión.","Could not prepare reconnection."},
    {"Roblox rechazó el cambio. Volvé a intentarlo.","Roblox rejected the switch. Try again."},
    {"Conectando a ","Connecting to "},
    {"Ya hay un cambio en curso.","A server switch is already in progress."},
    {"Roblox no pudo conectar. Buscando otro candidato...","Roblox could not connect. Looking for another server..."},
    {"Esperando que termine la pelea...","Waiting for the brawl to finish..."},
    {"Victoria confirmada. Buscando otra pelea...","Win confirmed. Looking for another brawl..."},
    {"Pelea terminada. Buscando otra...","Brawl finished. Looking for another..."},
    {"Brawls","Brawls"},
    {"Mascotas equipadas","Equipped pets"},
    {"Elegí tu próximo servidor","Choose your next server"},
    {"Destino","Destination"},
    {"Con mucha gente (18-19)","Many players (18-19)"},
    {"Casi vacío (1-2)","Almost empty (1-2)"},
    {"Mejor conexión","Best connection"},
    {"Buscar King libre","Find a free King"},
    {"Buscar servidor","Find server"},
    {"Todavía no buscaste ningún servidor.","You have not searched for a server yet."},
    {"Elegí un destino y tocá Buscar servidor.","Choose a destination and press Find server."},
    {"Entrar ahora  ›","Join now  ›"},
    {"Servidor listo para entrar","Server ready to join"},
    {"Servidor con 1–2 jugadores. El King se confirma al entrar.","Server with 1–2 players. King availability is confirmed after joining."},
    {"Ping informado: ","Reported ping: "},
    {"Había lugar disponible al momento de buscar.","There was room when the search ran."},
    {"Destino actualizado","Destination updated"},
    {"Tocá Buscar servidor para encontrar una opción nueva.","Press Find server to get a new option."},
    {"No encontré un servidor para ese destino.","No server was found for that destination."},
    {"Probá otra vez o elegí un destino diferente.","Try again or choose a different destination."},
    {"Automatizaciones","Automations"},
    {"Buscar otro automáticamente","Automatically find another"},
    {"Cambiar de servidor si muero","Switch servers if I die"},
    {"Evitar servidores con killers","Avoid servers with killers"},
    {"Reclamar King al entrar","Claim King after joining"},
    {"Próxima búsqueda en ","Next search in "},
    {"Buscando automáticamente","Searching automatically"},
    {"Esto puede tardar unos segundos.","This may take a few seconds."},
    {"Listo para buscar","Ready to search"},
    {"Jefe del evento","Event boss"},
    {"Estado:","Status:"},
    {"Sin jefe activo","No active boss"},
    {"Vida del jefe:","Boss health:"},
    {"Ocultar efectos pesados del jefe","Hide heavy boss effects"},
    {"Atacar al jefe automáticamente","Attack boss automatically"},
    {"Jefe derrotado · reclamando recompensa","Boss defeated · claiming reward"},
    {"El evento de jefe no está disponible","The boss event is unavailable"},
}
    for _,r in ipairs(extra) do EN[r[1]]=r[2]; PH[#PH+1]={r[1],r[2]} end
    table.sort(PH,function(a,b) return #a[1]>#b[1] end)
    local maps={pt={},ar={}}
    local roots={pt={},ar={}}
    local function insert(root,key,value)
        local node=root
        for i=1,#key do local b=key:byte(i); node[b]=node[b] or {}; node=node[b] end
        node.value=value
    end
    for _,r in ipairs(rows) do
        maps.pt[r[1]]=r[2]; maps.ar[r[1]]=r[3]
        insert(roots.pt,r[1],r[2]); insert(roots.ar,r[1],r[3])
    end
    local esRoot={}
    for k,v in pairs(EN) do insert(esRoot,k,v) end
    for _,r in ipairs(PH) do insert(esRoot,r[1],r[2]) end
    local function scan(text,root)
        local out,i={},1
        while i<=#text do
            local node,j,best,ending=root,i,nil,nil
            while j<=#text and node[text:byte(j)] do
                node=node[text:byte(j)]; j=j+1
                if node.value then best=node.value; ending=j end
            end
            if best then out[#out+1]=best; i=ending else out[#out+1]=text:sub(i,i); i=i+1 end
        end
        return table.concat(out)
    end
    local cache,order={},{}
    State.localize=function(value,lang)
        if not maps[lang] then return value end
        local key=lang..":"..value
        if cache[key] then return cache[key] end
        local base=EN[value] or scan(value,esRoot)
        local translated=maps[lang][base] or scan(base,roots[lang])
        if #order>=512 then cache[table.remove(order,1)]=nil end
        order[#order+1]=key; cache[key]=translated
        return translated
    end
    local styles=setmetatable({},{__mode="k"})
    State.styleLanguage=function(object)
        if not (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")) then return end
        if State.language~="ar" and not styles[object] then return end
        local original=styles[object]
        local limit=object:FindFirstChildWhichIsA("UITextSizeConstraint")
        if not original then original={align=object.TextXAlignment,font=object.Font,textSize=object.TextSize,limit=limit and limit.MaxTextSize}; styles[object]=original end
        local arabic=State.language=="ar" and tostring(object.Text):find("[\216-\219]")~=nil
        pcall(function()
            object.TextDirection=State.language=="ar" and Enum.TextDirection.RightToLeft or Enum.TextDirection.Auto
        end)
        object.TextXAlignment=State.language=="ar" and original.align==Enum.TextXAlignment.Left and Enum.TextXAlignment.Right or original.align
        object.Font=arabic and (original.font.Name:find("Bold") and Enum.Font.ArialBold or Enum.Font.Arial) or original.font
        object.TextSize=arabic and math.max(15,math.floor(original.textSize*1.24)) or original.textSize
        if limit and original.limit then limit.MaxTextSize=arabic and math.max(15,math.floor(original.limit*1.24)) or original.limit end
    end
    State.languageCatalog={rows=#rows,languages={"es","en","pt","ar"}}

	local BACK = {}
	for source, translated in pairs(EN) do BACK[translated] = source end
	local ITEMS = setmetatable({}, { __mode = "k" })
	local function swap(text, source, translated)
		local parts, cursor = {}, 1
		while true do
			local first, last = string.find(text, source, cursor, true)
			if not first then
				parts[#parts + 1] = string.sub(text, cursor)
				break
			end
			parts[#parts + 1] = string.sub(text, cursor, first - 1)
			parts[#parts + 1] = translated
			cursor = last + 1
		end
		return table.concat(parts)
	end
	local function english(value)
		local text = tostring(value or "")
		if State.language == "pt" or State.language == "ar" then return State.localize(text, State.language) end
		if EN[text] then return EN[text] end
		for _, pair in ipairs(PH) do text = swap(text, pair[1], pair[2]) end
		return text
	end
	local function apply(object, entry, property)
		local item = entry[property]
		if not item or not object.Parent then return end
		local target = State.language ~= "es" and english(item.source) or item.source
		item.applied = State.language ~= "es" and target or nil
		if object[property] ~= target then
			item.busy = true
			object[property] = target
			item.busy = false
		end
		if State.styleLanguage then State.styleLanguage(object) end
	end
	local function bind(object)
		if ITEMS[object] or object:GetAttribute("NoTranslate") then return end
		local properties = object:IsA("TextBox") and { "PlaceholderText" }
			or ((object:IsA("TextLabel") or object:IsA("TextButton")) and { "Text" } or nil)
		if not properties then return end
		local entry = { connections = {} }
		ITEMS[object] = entry
		State.languageBindingCount = (State.languageBindingCount or 0) + 1
		for _, property in ipairs(properties) do
			local item = { source = object[property], applied = nil, busy = false }
			entry[property] = item
			entry.connections[#entry.connections + 1] = object:GetPropertyChangedSignal(property):Connect(function()
				if item.busy then return end
				local current = object[property]
				if State.language ~= "es" and current == item.applied then return end
				item.source = State.language ~= "es" and (BACK[current] or current) or current
				apply(object, entry, property)
			end)
			apply(object, entry, property)
		end
		entry.destroying = object.Destroying:Connect(function()
			for _, connection in ipairs(entry.connections) do pcall(connection.Disconnect, connection) end
			if entry.destroying then pcall(entry.destroying.Disconnect, entry.destroying) end
			ITEMS[object] = nil
			State.languageBindingCount = math.max(0, (State.languageBindingCount or 1) - 1)
		end)
	end
	State.language = "es"
	local LANG_HOOKS = {}
	State.translateText = function(value)
		return State.language ~= "es" and english(value) or tostring(value or "")
	end
	State.bindLanguage = bind
	State.onLanguageChanged = function(callback)
		if type(callback) ~= "function" then return function() end end
		local hook = { callback = callback, active = true }
		LANG_HOOKS[#LANG_HOOKS + 1] = hook
		return function() hook.active = false end
	end
	State.setLanguage = function(language)
		State.language = ({es=true,en=true,pt=true,ar=true})[language] and language or "es"
		ScreenGui:SetAttribute("Language", State.language)
		if State.saveLanguage then State.saveLanguage(State.language) end
		for object, entry in pairs(ITEMS) do
			if object.Parent then
				if entry.Text then apply(object, entry, "Text") end
				if entry.PlaceholderText then apply(object, entry, "PlaceholderText") end
			end
		end
		for _, hook in ipairs(LANG_HOOKS) do
			if hook.active then pcall(hook.callback, State.language) end
		end
		return State.language
	end
	State.getLanguage = function() return State.language end
	addCleanup(function()
		for object, entry in pairs(ITEMS) do
			for _, connection in ipairs(entry.connections) do pcall(connection.Disconnect, connection) end
			if entry.destroying then pcall(entry.destroying.Disconnect, entry.destroying) end
			ITEMS[object] = nil
		end
		for _, hook in ipairs(LANG_HOOKS) do hook.active = false end
		table.clear(LANG_HOOKS)
		State.languageBindingCount = 0
	end)
end


local function styleHubText(object)
	if object:IsA("GuiObject") then
		object:SetAttribute("Young0x", "0x")
		object:SetAttribute("FG100", "Young0x")
	end
	if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
		if object:GetAttribute("KeepTextStyle") then
			return
		end
		local prominent = object:IsA("TextButton") or object.TextSize >= 14
		object.Font = prominent and C.fontBold or UI_FONT
		object.TextColor3 = C.white
		object.TextStrokeColor3 = C.black
		object.TextStrokeTransparency = prominent and 0.42 or 0.62
		if not object.TextScaled and object.TextSize < 12 then
			object.TextSize = 12
		end
		object.TextWrapped = true
		object.TextScaled = true
		local textLimit = object:FindFirstChild("TextLimit")
		if not textLimit then
			textLimit = Instance.new("UITextSizeConstraint")
			textLimit.Name = "TextLimit"
			textLimit.MinTextSize = 8
			textLimit.MaxTextSize = math.max(8, math.floor(object.TextSize))
			textLimit.Parent = object
		end
		if object:IsA("TextBox") then
			object.PlaceholderColor3 = C.soft
		end
	end
end

track(ScreenGui.DescendantAdded:Connect(function(object)
	task.defer(function()
		if State.running and object and object.Parent and object:IsDescendantOf(ScreenGui) then
			styleHubText(object)
			State.bindLanguage(object)
		end
	end)
end))

local AnimationRoot = Instance.new("Frame")
AnimationRoot.Name = "AnimationRoot"
AnimationRoot.AnchorPoint = Vector2.new(0.5, 0.5)
AnimationRoot.Size = UDim2.fromOffset(hubWidth, hubHeight)
AnimationRoot.Position = UDim2.fromScale(0.5, 0.5)
AnimationRoot.BackgroundTransparency = 1
AnimationRoot.BorderSizePixel = 0
AnimationRoot.Parent = ScreenGui
do
	local scale = Instance.new("UIScale")
	scale.Name = "MotionScale"
	scale.Scale = 1
	scale.Parent = AnimationRoot
end

local Shadow = Instance.new("Frame")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Size = UDim2.fromOffset(hubWidth, hubHeight)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 8)
Shadow.BackgroundColor3 = C.black
Shadow.BackgroundTransparency = 1
Shadow.BorderSizePixel = 0
Shadow.ClipsDescendants = true
Shadow.ZIndex = 1
Shadow.Parent = AnimationRoot
local ShadowCorner = Instance.new("UICorner", Shadow)
ShadowCorner.CornerRadius = UDim.new(0, 15)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.fromOffset(hubWidth - 2, hubHeight - 2)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.BackgroundColor3 = C.base
MainFrame.BackgroundTransparency = 0.03
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 3
MainFrame.Parent = AnimationRoot
local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

do
	local backgroundGradient = Instance.new("UIGradient")
	backgroundGradient.Rotation = 24
	backgroundGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(7, 12, 28)),
		ColorSequenceKeypoint.new(0.48, Color3.fromRGB(10, 13, 29)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 7, 18)),
	})
	backgroundGradient.Parent = MainFrame
	local topSheen = Instance.new("Frame")
	topSheen.Size = UDim2.new(1, 0, 0, 90)
	topSheen.BackgroundColor3 = C.white
	topSheen.BackgroundTransparency = 0.975
	topSheen.BorderSizePixel = 0
	topSheen.ZIndex = 3
	topSheen.Visible = false
	topSheen.Parent = MainFrame
	local sheenGradient = Instance.new("UIGradient")
	sheenGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.65),
		NumberSequenceKeypoint.new(1, 1),
	})
	sheenGradient.Parent = topSheen
end

do
	local backgroundArt = Instance.new("ImageLabel")
	backgroundArt.Name = "BackgroundArt"
	backgroundArt.Size = UDim2.fromScale(1, 1)
	backgroundArt.Position = UDim2.fromOffset(0, 0)
	backgroundArt.BackgroundTransparency = 1
	backgroundArt.BorderSizePixel = 0
	backgroundArt.ClipsDescendants = true
	backgroundArt.Image = CONFIG.BackgroundAsset
	backgroundArt.Visible = CONFIG.BackgroundAsset ~= ""
	backgroundArt.ImageColor3 = Color3.fromRGB(204, 211, 255)
	backgroundArt.ImageTransparency = 0.56
	backgroundArt.ScaleType = Enum.ScaleType.Crop
	backgroundArt.ZIndex = 4
	backgroundArt.Parent = MainFrame
	Instance.new("UICorner", backgroundArt).CornerRadius = UDim.new(0, 12)

	local backgroundShade = Instance.new("Frame")
	backgroundShade.Name = "BackgroundShade"
	backgroundShade.Size = UDim2.fromScale(1, 1)
	backgroundShade.BackgroundColor3 = Color3.fromRGB(5, 7, 16)
	backgroundShade.BackgroundTransparency = 0.24
	backgroundShade.BorderSizePixel = 0
	backgroundShade.ClipsDescendants = true
	backgroundShade.ZIndex = 5
	backgroundShade.Parent = MainFrame
	Instance.new("UICorner", backgroundShade).CornerRadius = UDim.new(0, 12)
	State.bibleFullArt = Instance.new("ImageLabel")
	State.bibleFullArt.Name = "BibleFullArt"
	State.bibleFullArt.Size = UDim2.fromScale(1, 1)
	State.bibleFullArt.Position = UDim2.fromOffset(0, 0)
	State.bibleFullArt.BackgroundTransparency = 1
	State.bibleFullArt.BorderSizePixel = 0
	State.bibleFullArt.ClipsDescendants = true
	State.bibleFullArt.Image = "rbxassetid://2938752004"
	State.bibleFullArt.ImageColor3 = Color3.fromRGB(190, 180, 225)
	State.bibleFullArt.ImageTransparency = 0.20
	State.bibleFullArt.ScaleType = Enum.ScaleType.Crop
	State.bibleFullArt.Visible = false
	State.bibleFullArt.ZIndex = 6
	State.bibleFullArt.Parent = MainFrame
	Instance.new("UICorner", State.bibleFullArt).CornerRadius = UDim.new(0, 12)
	State.bibleFullShade = Instance.new("Frame")
	State.bibleFullShade.Name = "BibleFullShade"
	State.bibleFullShade.Size = UDim2.fromScale(1, 1)
	State.bibleFullShade.BackgroundColor3 = Color3.fromRGB(5, 4, 13)
	State.bibleFullShade.BackgroundTransparency = 0.34
	State.bibleFullShade.BorderSizePixel = 0
	State.bibleFullShade.ClipsDescendants = true
	State.bibleFullShade.Visible = false
	State.bibleFullShade.ZIndex = 7
	State.bibleFullShade.Parent = MainFrame
	Instance.new("UICorner", State.bibleFullShade).CornerRadius = UDim.new(0, 12)

	task.defer(function()
		pcall(function()
			local contentProvider = game:GetService("ContentProvider")
			contentProvider:PreloadAsync({ backgroundArt, State.bibleFullArt })
		end)
	end)
end

do
	local dim = Instance.new("Frame")
	dim.Size = UDim2.fromScale(1, 1)
	dim.BackgroundColor3 = C.panel
	dim.BackgroundTransparency = 0.64
	dim.BorderSizePixel = 0
	dim.ZIndex = 4
	dim.Visible = false
	dim.Parent = MainFrame
	Instance.new("UICorner", dim).CornerRadius = UDim.new(0, 12)
end

local Border = Instance.new("Frame")
Border.Name = "Border"
Border.AnchorPoint = Vector2.new(0.5, 0.5)
Border.Size = UDim2.fromOffset(hubWidth, hubHeight)
Border.Position = UDim2.fromScale(0.5, 0.5)
Border.BackgroundColor3 = C.black
Border.BackgroundTransparency = 1
Border.BorderSizePixel = 0
Border.ClipsDescendants = true
Border.ZIndex = 2
Border.Parent = AnimationRoot
local BorderCorner = Instance.new("UICorner", Border)
BorderCorner.CornerRadius = UDim.new(0, 13)
do
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.fromRGB(208, 225, 255)
	stroke.Thickness = 1.65
	stroke.Transparency = 0.06
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Parent = Border
	local strokeGradient = Instance.new("UIGradient")
	strokeGradient.Rotation = 12
	strokeGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(192, 224, 255)),
		ColorSequenceKeypoint.new(0.52, Color3.fromRGB(188, 137, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(192, 224, 255)),
	})
	strokeGradient.Parent = stroke
	local auraStroke = Instance.new("UIStroke")
	auraStroke.Name = "AuraStroke"
	auraStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	auraStroke.Color = Color3.fromRGB(142, 188, 255)
	auraStroke.Thickness = 4
	auraStroke.Transparency = 0.70
	auraStroke.LineJoinMode = Enum.LineJoinMode.Round
	auraStroke.Parent = Border
end
MainFrame.Parent = Border

local BorderSweep = Instance.new("Frame")
BorderSweep.Name = "BorderSweep"
BorderSweep.AnchorPoint = Vector2.new(0.5, 0.5)
BorderSweep.Size = UDim2.fromOffset(68, 4)
BorderSweep.Position = UDim2.fromOffset(28, 2)
BorderSweep.BackgroundColor3 = C.black
BorderSweep.BorderSizePixel = 0
BorderSweep.Visible = false
BorderSweep.ZIndex = 82
BorderSweep.Parent = Border
Instance.new("UICorner", BorderSweep).CornerRadius = UDim.new(1, 0)
do
	local gradient = Instance.new("UIGradient")
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.22, 0.18),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(0.78, 0.18),
		NumberSequenceKeypoint.new(1, 1),
	})
	gradient.Parent = BorderSweep
end

local DragHandle, HeaderFrame, HeaderTitle, MiniIcon
local MiniBubble, MiniDragHandle

local playMiniPress = function() end
do
	local headerBackdrop = Instance.new("Frame")
	headerBackdrop.Name = "TopbarBackdrop"
	headerBackdrop.Size = UDim2.new(1, 0, 0, HEADER_H)
	headerBackdrop.Position = UDim2.fromOffset(0, 0)
	headerBackdrop.BackgroundTransparency = 1
	headerBackdrop.BorderSizePixel = 0
	headerBackdrop.ClipsDescendants = true
	headerBackdrop.ZIndex = 9
	headerBackdrop.Parent = MainFrame

	local headerFill = Instance.new("Frame")
	headerFill.Name = "HeaderFill"
	headerFill.Size = UDim2.new(1, 0, 1, 18)
	headerFill.BackgroundColor3 = Color3.fromRGB(8, 12, 25)
	headerFill.BackgroundTransparency = 0.36
	headerFill.BorderSizePixel = 0
	headerFill.Visible = false
	headerFill.ZIndex = 9
	headerFill.Parent = headerBackdrop
	Instance.new("UICorner", headerFill).CornerRadius = UDim.new(0, 14)
	local headerGradient = Instance.new("UIGradient")
	headerGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(9, 24, 43)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 14, 31)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(19, 10, 35)),
	})
	headerGradient.Parent = headerFill
	local headerLine = Instance.new("Frame")
	headerLine.Size = UDim2.new(1, -28, 0, 1)
	headerLine.Position = UDim2.new(0, 14, 1, -1)
	headerLine.BackgroundColor3 = C.blue
	headerLine.BackgroundTransparency = 0.62
	headerLine.BorderSizePixel = 0
	headerLine.ZIndex = 11
	headerLine.Parent = headerBackdrop
	local headerLineGradient = Instance.new("UIGradient")
	headerLineGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.22, 0.18),
		NumberSequenceKeypoint.new(0.78, 0.18),
		NumberSequenceKeypoint.new(1, 1),
	})
	headerLineGradient.Parent = headerLine
	headerLine.Visible = false

	local header = Instance.new("Frame")
	HeaderFrame = header
	header.Name = "Topbar"
	header.Size = UDim2.new(1, 0, 0, HEADER_H)
	header.BackgroundTransparency = 1
	header.BorderSizePixel = 0
	header.ClipsDescendants = true
	header.ZIndex = 10
	header.Parent = MainFrame
	local Title = Instance.new("TextLabel")
	HeaderTitle = Title
	Title.AnchorPoint = Vector2.new(0.5, 0)
	Title.Size = UDim2.new(1, -16, 0, 29)
	Title.Position = UDim2.new(0.5, 0, 0, 4)
	Title.BackgroundTransparency = 1
	Title.Text = CONFIG.Title
	Title.TextColor3 = C.white
	Title.TextStrokeColor3 = C.black
	Title.TextStrokeTransparency = 0.70
	Title.Font = C.fontBold
	Title.TextSize = 19
	Title.TextScaled = true
	Title.TextXAlignment = Enum.TextXAlignment.Center
	Title.ZIndex = 12
	Title.Parent = header
	Instance.new("UITextSizeConstraint", Title).MaxTextSize = 19
	local titleShine = Instance.new("UIGradient")
	titleShine.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(246, 248, 252)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(221, 205, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(246, 248, 252)),
	})
	titleShine.Parent = Title

	local Subtitle = Instance.new("TextLabel")
	Subtitle.Name = "Subtitle"
	Subtitle.AnchorPoint = Vector2.new(0.5, 0)
	Subtitle.Size = UDim2.new(1, -36, 0, 18)
	Subtitle.Position = UDim2.new(0.5, 0, 0, 30)
	Subtitle.BackgroundTransparency = 1
	Subtitle.Text = CONFIG.Subtitle
	Subtitle.TextColor3 = Color3.fromRGB(198, 203, 235)
	Subtitle.TextStrokeColor3 = C.black
	Subtitle.TextStrokeTransparency = 0.76
	Subtitle.Font = UI_FONT
	Subtitle.TextSize = 12
	Subtitle.TextXAlignment = Enum.TextXAlignment.Center
	Subtitle.ZIndex = 12
	Subtitle.Parent = header
	MiniIcon = Instance.new("TextLabel")
	MiniIcon.Name = "MiniIcon"
	MiniIcon.Size = UDim2.fromScale(1, 1)
	MiniIcon.BackgroundTransparency = 1
	MiniIcon.Text = "FG100%"
	MiniIcon.TextColor3 = C.white
	MiniIcon.TextStrokeColor3 = C.black
	MiniIcon.TextStrokeTransparency = 0.06
	MiniIcon.Font = C.fontBold
	MiniIcon.TextSize = 16
	MiniIcon.Visible = false
	MiniIcon.ZIndex = 12
	MiniIcon.Parent = header
	DragHandle = Instance.new("TextButton")
	DragHandle.Name = "MinimizeHub"
	DragHandle:SetAttribute("OutputLabel", "Minimizar hub")
	DragHandle.Size = UDim2.fromScale(1, 1)
	DragHandle.BackgroundTransparency = 1
	DragHandle.Text = ""
	DragHandle.AutoButtonColor = false
	DragHandle.ZIndex = 60
	DragHandle.Parent = header
end

do
	MiniBubble = Instance.new("Frame")
	MiniBubble.Name = "MiniBubble"
	MiniBubble.AnchorPoint = Vector2.new(0.5, 0.5)
	MiniBubble.Size = UDim2.fromOffset(MIN_WIDTH, MIN_HEIGHT)
	MiniBubble.Position = UDim2.new(
		0.5,
		-math.floor(hubWidth * 0.5 + MIN_WIDTH * 0.5 + 18),
		0.5,
		0
	)
	MiniBubble.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
	MiniBubble.BackgroundTransparency = 0.02
	MiniBubble.BorderSizePixel = 0
	MiniBubble.ClipsDescendants = true
	MiniBubble.Visible = true
	MiniBubble.ZIndex = 100
	MiniBubble.Parent = ScreenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, MIN_HEIGHT < 50 and 10 or 12)
	corner.Parent = MiniBubble
	local miniScale = Instance.new("UIScale")
	miniScale.Scale = 1
	miniScale.Parent = MiniBubble

	local miniGradient = Instance.new("UIGradient")
	miniGradient.Rotation = 0
	miniGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(17, 20, 27)),
		ColorSequenceKeypoint.new(0.42, Color3.fromRGB(31, 38, 49)),
		ColorSequenceKeypoint.new(0.58, Color3.fromRGB(51, 61, 76)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 24, 32)),
	})
	miniGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 0),
	})
	miniGradient.Parent = MiniBubble

	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.fromRGB(172, 198, 219)
	stroke.Thickness = 1.25
	stroke.Transparency = 0.18
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Parent = MiniBubble
	local auraStroke = Instance.new("UIStroke")
	auraStroke.Name = "AuraStroke"
	auraStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	auraStroke.Color = Color3.fromRGB(134, 191, 232)
	auraStroke.Thickness = 3
	auraStroke.Transparency = 0.84
	auraStroke.LineJoinMode = Enum.LineJoinMode.Round
	auraStroke.Parent = MiniBubble

	local miniAccent = Instance.new("Frame")
	miniAccent.Name = "BottomAccent"
	miniAccent.Size = UDim2.new(1, -10, 0, 2)
	miniAccent.Position = UDim2.new(0, 5, 1, -4)
	miniAccent.BackgroundColor3 = C.cyan
	miniAccent.BackgroundTransparency = 0.42
	miniAccent.BorderSizePixel = 0
	miniAccent.ZIndex = 101
	miniAccent.Parent = MiniBubble
	Instance.new("UICorner", miniAccent).CornerRadius = UDim.new(1, 0)
	local miniAccentGradient = Instance.new("UIGradient")
	miniAccentGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 27, 36)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(145, 207, 245)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 27, 36)),
	})
	miniAccentGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.78),
		NumberSequenceKeypoint.new(0.5, 0.28),
		NumberSequenceKeypoint.new(1, 0.78),
	})
	miniAccentGradient.Parent = miniAccent

	local miniStars = Instance.new("ImageLabel")
	miniStars.Name = "Stars"
	miniStars.Size = UDim2.fromScale(1, 1)
	miniStars.BackgroundTransparency = 1
	miniStars.Image = CONFIG.BackgroundAsset
	miniStars.ImageColor3 = Color3.fromRGB(215, 229, 244)
	miniStars.ImageTransparency = 0.36
	miniStars.ScaleType = Enum.ScaleType.Crop
	miniStars.ZIndex = 100
	miniStars.Parent = MiniBubble
	Instance.new("UICorner", miniStars).CornerRadius = corner.CornerRadius

	local icon = Instance.new("TextLabel")
	MiniIcon = icon
	icon.Name = "Icon"
	icon.Size = UDim2.new(1, 0, 0.58, 0)
	icon.BackgroundTransparency = 1
	icon.Text = "FG100%"
	icon.TextColor3 = C.white
	icon.TextStrokeColor3 = C.black
	icon.TextStrokeTransparency = 0.12
	icon.Font = C.fontBold
	icon.TextSize = MIN_HEIGHT < 50 and 12 or 16
	icon.ZIndex = 101
	icon:SetAttribute("KeepTextStyle", true)
	icon.Parent = MiniBubble

	State.MiniStats = Instance.new("TextLabel")
	State.MiniStats.Name = "LiveStats"
	State.MiniStats.Size = UDim2.new(1, -12, 0.42, -3)
	State.MiniStats.Position = UDim2.new(0, 6, 0.58, -2)
	State.MiniStats.BackgroundTransparency = 1
	State.MiniStats.Text = "-- FPS  •  -- ms"
	State.MiniStats.TextColor3 = C.cyan
	State.MiniStats.TextStrokeColor3 = C.black
	State.MiniStats.TextStrokeTransparency = 0.28
	State.MiniStats.Font = Enum.Font.GothamBold
	State.MiniStats.TextScaled = true
	State.MiniStats.ZIndex = 101
	State.MiniStats:SetAttribute("KeepTextStyle", true)
	State.MiniStats:SetAttribute("NoTranslate", true)
	State.MiniStats.Parent = MiniBubble
	local miniStatsLimit = Instance.new("UITextSizeConstraint")
	miniStatsLimit.MinTextSize = 7
	miniStatsLimit.MaxTextSize = MIN_HEIGHT < 50 and 9 or 11
	miniStatsLimit.Parent = State.MiniStats

	MiniDragHandle = Instance.new("TextButton")
	MiniDragHandle.Name = "DragHandle"
	MiniDragHandle:SetAttribute("OutputLabel", "Abrir hub")
	MiniDragHandle.Size = UDim2.fromScale(1, 1)
	MiniDragHandle.BackgroundTransparency = 1
	MiniDragHandle.Text = ""
	MiniDragHandle.AutoButtonColor = false
	MiniDragHandle.ZIndex = 102
	MiniDragHandle.Parent = MiniBubble

	local miniHovered = false
	local pressGeneration = 0

	playMiniPress = function()
		if not MiniBubble or not MiniBubble.Parent then return end
		pressGeneration = pressGeneration + 1
		local generation = pressGeneration
		TweenService:Create(miniScale, TweenInfo.new(0.07, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Scale = 0.91,
		}):Play()
		TweenService:Create(MiniBubble, TweenInfo.new(0.07, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0,
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.07, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Transparency = 0.05,
			Thickness = 1.8,
		}):Play()
		TweenService:Create(auraStroke, TweenInfo.new(0.07, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Transparency = 0.66,
			Thickness = 4.2,
		}):Play()
		TweenService:Create(miniGradient, TweenInfo.new(0.07, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Offset = Vector2.new(-0.16, 0),
		}):Play()
		task.delay(0.08, function()
			if generation ~= pressGeneration or not MiniBubble.Parent then return end
			TweenService:Create(miniScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Scale = miniHovered and 1.045 or 1,
			}):Play()
			TweenService:Create(MiniBubble, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.02,
			}):Play()
			TweenService:Create(stroke, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Transparency = miniHovered and 0.08 or 0.18,
				Thickness = miniHovered and 1.6 or 1.25,
			}):Play()
			TweenService:Create(auraStroke, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Transparency = miniHovered and 0.72 or 0.84,
				Thickness = miniHovered and 3.8 or 3,
			}):Play()
			TweenService:Create(miniGradient, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Offset = miniHovered and Vector2.new(0.16, 0) or Vector2.zero,
			}):Play()
		end)
	end

	track(MiniDragHandle.MouseEnter:Connect(function()
		miniHovered = true
		TweenService:Create(miniScale, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Scale = 1.045,
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Transparency = 0.08,
			Thickness = 1.6,
		}):Play()
		TweenService:Create(auraStroke, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Transparency = 0.72,
			Thickness = 3.8,
		}):Play()
		TweenService:Create(miniGradient, TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Offset = Vector2.new(0.16, 0),
		}):Play()
		TweenService:Create(miniAccent, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.24,
		}):Play()
	end))
	track(MiniDragHandle.MouseLeave:Connect(function()
		miniHovered = false
		TweenService:Create(miniScale, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Scale = 1,
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Transparency = 0.18,
			Thickness = 1.25,
		}):Play()
		TweenService:Create(auraStroke, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Transparency = 0.84,
			Thickness = 3,
		}):Play()
		TweenService:Create(miniGradient, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Offset = Vector2.zero,
		}):Play()
		TweenService:Create(miniAccent, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.42,
		}):Play()
	end))
end

do
	local sounds = Shared and Shared:FindFirstChild("assets")
	sounds = sounds and sounds:FindFirstChild("sounds")
	local template = sounds and sounds:FindFirstChild("whooshSound")
	local sound = template and template:IsA("Sound") and template:Clone() or Instance.new("Sound")
	State.uiWhoosh = sound
	sound.Name = "UiWhoosh"
	sound.SoundId = sound.SoundId ~= "" and sound.SoundId or "rbxassetid://3611025588"
	sound.Volume = 0.26
	sound.Parent = game:GetService("SoundService")
	addCleanup(function()
		if State.uiWhoosh then State.uiWhoosh:Destroy(); State.uiWhoosh = nil end
	end)
end


State.playUiWhoosh = function(opening)
	local sound = State.uiWhoosh
	if not sound then return end
	pcall(function()
		sound:Stop()
		sound.TimePosition = 0
		sound.PlaybackSpeed = opening and 0.92 or 1.18
		sound:Play()
	end)
end

local TabBar = Instance.new("ScrollingFrame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -24, 0, TAB_H)
TabBar.Position = UDim2.new(0, 0, 0, HEADER_H)
TabBar.BackgroundColor3 = Color3.fromRGB(8, 12, 25)
TabBar.BackgroundTransparency = 1
TabBar.BorderSizePixel = 0
TabBar.ClipsDescendants = true
TabBar.ScrollBarThickness = 0
TabBar.ScrollingDirection = Enum.ScrollingDirection.X
TabBar.CanvasSize = UDim2.new()
TabBar.ZIndex = 10
TabBar.Parent = MainFrame
local TabCorner = Instance.new("UICorner", TabBar)
TabCorner.CornerRadius = UDim.new(0, 0)

local tabLayout = Instance.new("UIListLayout", TabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 4)

do
	local tabPadding = Instance.new("UIPadding", TabBar)
	tabPadding.PaddingLeft = UDim.new(0, 6)
	tabPadding.PaddingRight = UDim.new(0, 6)
	tabPadding.PaddingTop = UDim.new(0, 4)
	tabPadding.PaddingBottom = UDim.new(0, 4)
end

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -(HEADER_H + TAB_H + 8))
Content.Position = UDim2.new(0, 0, 0, HEADER_H + TAB_H)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.ZIndex = 8
Content.Parent = MainFrame

do
	local veil = Instance.new("Frame")
	veil.Name = "MotionVeil"
	veil.Size = UDim2.fromScale(1, 1)
	veil.BackgroundColor3 = Color3.fromRGB(3, 4, 10)
	veil.BackgroundTransparency = 1
	veil.BorderSizePixel = 0
	veil.ClipsDescendants = true
	veil.Visible = false
	veil.Active = false
	veil.ZIndex = 180
	veil.Parent = MainFrame
	Instance.new("UICorner", veil).CornerRadius = UDim.new(0, 12)
	local art = Instance.new("ImageLabel")
	art.Name = "MotionVeilArt"
	art.Size = UDim2.fromScale(1.04, 1.04)
	art.Position = UDim2.fromScale(-0.02, -0.02)
	art.BackgroundTransparency = 1
	art.BorderSizePixel = 0
	art.Image = CONFIG.BackgroundAsset
	art.ImageColor3 = Color3.fromRGB(164, 172, 218)
	art.ImageTransparency = 1
	art.ScaleType = Enum.ScaleType.Crop
	art.ZIndex = 181
	art.Parent = veil
	Instance.new("UICorner", art).CornerRadius = UDim.new(0, 12)
	State.motionVeil = veil
	State.motionVeilArt = art
end
do
	local shell = Instance.new("Frame")
	shell.Name = "MotionShell"
	shell.AnchorPoint = Vector2.new(0.5, 0.5)
	shell.Size = UDim2.fromOffset(hubWidth, hubHeight)
	shell.Position = UDim2.fromScale(0.5, 0.5)
	shell.BackgroundColor3 = Color3.fromRGB(3, 4, 10)
	shell.BackgroundTransparency = 0.02
	shell.BorderSizePixel = 0
	shell.ClipsDescendants = true
	shell.Visible = false
	shell.ZIndex = 90
	shell.Parent = ScreenGui
	local shellCorner = Instance.new("UICorner", shell)
	shellCorner.CornerRadius = UDim.new(0, 12)
	local art = Instance.new("ImageLabel")
	art.Name = "MotionShellArt"
	art.Size = UDim2.fromScale(1.04, 1.04)
	art.Position = UDim2.fromScale(-0.02, -0.02)
	art.BackgroundTransparency = 1
	art.BorderSizePixel = 0
	art.Image = CONFIG.BackgroundAsset
	art.ImageColor3 = Color3.fromRGB(164, 172, 218)
	art.ImageTransparency = 0.46
	art.ScaleType = Enum.ScaleType.Crop
	art.ZIndex = 91
	art.Parent = shell
	local artCorner = Instance.new("UICorner", art)
	artCorner.CornerRadius = UDim.new(0, 12)
	local shellStroke = Instance.new("UIStroke")
	shellStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	shellStroke.Color = Color3.fromRGB(188, 158, 255)
	shellStroke.Thickness = 1.5
	shellStroke.Transparency = 0.12
	shellStroke.LineJoinMode = Enum.LineJoinMode.Round
	shellStroke.Parent = shell
	State.motionShell = shell
	State.motionShellArt = art
	State.motionShellCorner = shellCorner
	State.motionShellArtCorner = artCorner
	State.motionShellStroke = shellStroke
end

local Pages = {}
local TabButtons = {}
__FGRoot.pageOrders = {}
__FGRoot.MotionPageCache = Instance.new("Folder")
__FGRoot.MotionPageCache.Name = "0x"
__FGRoot.MotionPageCache.Parent = ScreenGui
__FGRoot.MotionPageHomes = {}

-- Crefy window adapter. The feature pages keep their existing controller objects so
-- their callbacks, live panels and profile restoration continue to work.
__FGRoot.CrefyLibrary = nil
__FGRoot.CrefyBootstrapLibrary = nil
__FGRoot.CrefyThemeManager = nil
__FGRoot.CrefySaveManager = nil
__FGRoot.CrefyWindow = nil
__FGRoot.CrefyTabs = {}
__FGRoot.CrefyEnabled = false
__FGRoot.CrefyGroups = {}
__FGRoot.CrefyCurrentGroups = {}
__FGRoot.CrefyControlSerial = 0
__FGRoot.CrefyCallbackSuppressed = {}
__FGRoot.CrefyGroupProxies = setmetatable({}, { __mode = "k" })
-- The old visual tree is retained only as an invisible compatibility model for
-- specialized dashboard logic. Every exposed input control is rendered by Crefy.
-- Declared before Crefy callbacks so its Unload button can stop the script too.
local shutdown = nil

local function getHubUIDescendants()
    local result, seen = {}, {}
    local function add(object)
        if object and not seen[object] then
            seen[object] = true
            result[#result + 1] = object
        end
    end
    if ScreenGui then
        for _, object in ipairs(ScreenGui:GetDescendants()) do add(object) end
    end
    for _, page in pairs(Pages) do
        if page then
            add(page)
            for _, object in ipairs(page:GetDescendants()) do add(object) end
        end
    end
    return result
end


local function addRgbStroke(target, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Thickness = thickness or 1
	stroke.Transparency = math.clamp((transparency or 0.12) + 0.07, 0, 1)
	stroke.Color = C.blue
	stroke.Parent = target
	return stroke
end


local function nextOrder(page)
	__FGRoot.pageOrders[page] = (__FGRoot.pageOrders[page] or 0) + 1
	return __FGRoot.pageOrders[page]
end


State.pageScrollPositions = State.pageScrollPositions or {}
local function refreshTabs(active)
    if not active then return end
    local previous = State.currentTab
    if previous and Pages[previous] then
        Pages[previous].Visible = false
    end
    State.currentTab = active
    if Pages[active] then
        Pages[active].Visible = true
    end
    local nativeTab = __FGRoot.CrefyTabs[active]
    if __FGRoot.CrefyEnabled and nativeTab then
        pcall(function()
            if __FGRoot.CrefyLibrary.ActiveTab ~= nativeTab then nativeTab:Show() end
        end)
    end
    if active == "Fast Farm" and FastFarm.ShowPackWelcome then
        task.defer(FastFarm.ShowPackWelcome)
    elseif FastFarm.HidePackWelcome then
        FastFarm.HidePackWelcome()
    end
end


-- Load the same Crefy fork used by the supplied example. This converted build requires
-- Crefy; if it cannot load, initialization is stopped and all started work is cleaned up.
do
    local repo = "https://raw.githubusercontent.com/lrexzyq/Crefy/main/"
    local ok, result = pcall(function()
        local library = loadstring(game:HttpGet(repo .. "Library.lua"))()
        __FGRoot.CrefyBootstrapLibrary = library
        assert(type(library) == "table", "Crefy Library.lua did not return a table")
        assert(type(library.CreateWindow) == "function", "Crefy Library is missing CreateWindow")
        local themeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
        assert(type(themeManager) == "table", "Crefy ThemeManager.lua did not return a table")
        assert(type(themeManager.SetLibrary) == "function" and type(themeManager.ApplyToTab) == "function",
            "Crefy ThemeManager is missing required methods")
        local saveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
        assert(type(saveManager) == "table", "Crefy SaveManager.lua did not return a table")
        assert(type(saveManager.SetLibrary) == "function" and type(saveManager.BuildConfigSection) == "function",
            "Crefy SaveManager is missing required methods")
        library.ForceCheckbox = false
        library.ShowToggleFrameInKeybinds = true
        pcall(function()
            library.Scheme.BackgroundColor = C.base
            library.Scheme.MainColor = C.panel
            library.Scheme.AccentColor = C.cyan
            library.Scheme.OutlineColor = C.blue
            library.Scheme.FontColor = C.white
        end)
        local window = library:CreateWindow({
            Title = "FG100 | Muscle Legends",
            Footer = "FG100 | Muscle Legends",
            Icon = 95816097006870,
            Center = true,
            AutoShow = true,
            Resizable = true,
            Size = UDim2.fromOffset(860, 630),
            NotifySide = "Right",
            ShowCustomCursor = true,
            Minimizable = true,
            MinimizeKeybind = Enum.KeyCode.RightBracket,
            ToggleKeybind = Enum.KeyCode.RightShift,
            MobileButtonsSide = "Right",
        })
        return { Library = library, ThemeManager = themeManager, SaveManager = saveManager, Window = window }
    end)
    if ok and type(result) == "table" and result.Window then
        __FGRoot.CrefyLibrary = result.Library
        __FGRoot.CrefyThemeManager = result.ThemeManager
        __FGRoot.CrefySaveManager = result.SaveManager
        __FGRoot.CrefyWindow = result.Window
        __FGRoot.CrefyEnabled = true
        addCleanup(function()
            if __FGRoot.CrefyLibrary and not __FGRoot.CrefyLibrary.Unloaded then
                pcall(function() __FGRoot.CrefyLibrary:Unload() end)
            end
        end)
    else
        warn("[FG100] Crefy UI failed to load; this converted build requires Crefy: " .. tostring(result))
    end
end

if not __FGRoot.CrefyEnabled then
	State.running = false
	if type(__FGRoot.CrefyBootstrapLibrary) == "table" and type(__FGRoot.CrefyBootstrapLibrary.Unload) == "function" then
		pcall(__FGRoot.CrefyBootstrapLibrary.Unload, __FGRoot.CrefyBootstrapLibrary)
	end
	for _, cleanup in ipairs(cleanupActions) do pcall(cleanup) end
	disconnectAll()
	if VisualGui and VisualGui.Parent then pcall(function() VisualGui:Destroy() end) end
	if ScreenGui and ScreenGui.Parent then pcall(function() ScreenGui:Destroy() end) end
	warn("[FG100] Initialization aborted: Crefy is required for this converted build; no automation was left running.")
	return
end

__FGRoot.CrefyIconByTab = {
    ["Dios Te ama ❤"] = "heart",
    ["Info"] = "info",
    ["Main"] = "house",
    ["Fast Farm"] = "zap",
    ["AFK 24/7"] = "moon",
    ["Full Train"] = "dumbbell",
    ["Auto Farm"] = "bot",
    ["Boss"] = "swords",
    ["Pet Momentum"] = "paw-print",
    ["Fast Glitch 100%"] = "gauge",
    ["Rebirths"] = "refresh-cw",
    ["Kills"] = "target",
    ["Server Hop"] = "server",
    ["Pet Shop"] = "shopping-bag",
    ["Inventario"] = "package",
    ["Fuse Machine"] = "combine",
    ["Fast Trade"] = "arrow-left-right",
    ["Gifts"] = "gift",
    ["Teleports"] = "map-pin",
    ["Perfiles"] = "users",
    ["Stats"] = "chart-no-axes-combined",
    ["Misc"] = "sliders-horizontal",
}



local function addTab(text, width, order)
    assert(__FGRoot.CrefyEnabled and __FGRoot.CrefyWindow, "Crefy must load before feature tabs are built")
    local ok, nativeTab = pcall(function()
        return __FGRoot.CrefyWindow:AddTab({
            Name = text,
            Icon = __FGRoot.CrefyIconByTab[text] or "layout-grid",
            Layout = "Single",
            Order = order,
        })
    end)
    assert(ok and nativeTab, "Could not create Crefy tab " .. tostring(text) .. ": " .. tostring(nativeTab))
    __FGRoot.CrefyTabs[text] = nativeTab
    if nativeTab.Button then
        track(nativeTab.Button.MouseButton1Click:Connect(function()
            task.defer(function()
                if State.running then refreshTabs(text) end
            end)
        end))
    end

    -- Backing frame is never presented. The script's dashboard/graph bookkeeping
    -- still expects a named ScrollingFrame while its controls now render in Crefy.
    local page = Instance.new("ScrollingFrame")
    page.Name = text
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 0
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.ZIndex = 1
    page.Parent = Content
    Pages[text] = page
    __FGRoot.MotionPageHomes[page] = Content

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 3)
    layout.Parent = page
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.PaddingTop = UDim.new(0, 7)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = page
    track(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 24)
    end))
    return page
end

for index, tab in ipairs(CONFIG.Tabs) do
	addTab(tab[1], tab[2], index)
end

if __FGRoot.CrefyEnabled then
    local settingsTab
    local settingsOk, settingsValue = pcall(function()
        return __FGRoot.CrefyWindow:AddTab({ Name = "UI Settings", Icon = "settings", Order = #CONFIG.Tabs + 1 })
    end)
    if settingsOk then
        settingsTab = settingsValue
        __FGRoot.CrefyTabs["UI Settings"] = settingsTab
        if settingsTab and settingsTab.Button then
            track(settingsTab.Button.MouseButton1Click:Connect(function()
                task.defer(function()
                    if State.running then refreshTabs("UI Settings") end
                end)
            end))
        end
    else
        warn("[FG100] Could not create Crefy UI Settings tab: " .. tostring(settingsValue))
    end

    if settingsTab then
        local addonSetupOk, addonSetupError = pcall(function()
            local menuGroup = settingsTab:AddGroupbox({ Side = "Left", Name = "Menu", IconName = "wrench" })
            menuGroup:AddToggle("FG100_KeybindMenuOpen", {
                Text = "Open Keybind Menu",
                Default = __FGRoot.CrefyLibrary.KeybindFrame and __FGRoot.CrefyLibrary.KeybindFrame.Visible or false,
                Callback = function(value)
                    if __FGRoot.CrefyLibrary.KeybindFrame then __FGRoot.CrefyLibrary.KeybindFrame.Visible = value end
                end,
            })
            menuGroup:AddToggle("FG100_ShowCustomCursor", {
                Text = "Custom Cursor",
                Default = __FGRoot.CrefyLibrary.ShowCustomCursor,
                Callback = function(value) __FGRoot.CrefyLibrary.ShowCustomCursor = value end,
            })
            menuGroup:AddToggle("FG100_AlwaysOnTop", {
                Text = "Always On Top",
                Default = __FGRoot.CrefyWindow.AlwaysOnTop,
                Callback = function(value) __FGRoot.CrefyWindow:SetAlwaysOnTop(value) end,
            })
            menuGroup:AddDropdown("FG100_NotificationSide", {
                Values = { "Left", "Right" },
                Default = "Right",
                Text = "Notification Side",
                Callback = function(value) __FGRoot.CrefyLibrary:SetNotifySide(value) end,
            })
            menuGroup:AddDropdown("FG100_DPI", {
                Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
                Default = "100%",
                Text = "DPI Scale",
                Callback = function(value)
                    local dpi = tonumber(tostring(value):gsub("%%", ""))
                    if dpi then __FGRoot.CrefyLibrary:SetDPIScale(dpi) end
                end,
            })
            menuGroup:AddSlider("FG100_CornerRadius", {
                Text = "Corner Radius",
                Default = __FGRoot.CrefyLibrary.CornerRadius or 4,
                Min = 0,
                Max = 20,
                Rounding = 0,
                Callback = function(value) __FGRoot.CrefyWindow:SetCornerRadius(value) end,
            })
            menuGroup:AddDivider()
            menuGroup:AddLabel("Menu bind"):AddKeyPicker("FG100_MenuKeybind", {
                Default = "RightShift",
                NoUI = true,
                Text = "Menu keybind",
            })
            __FGRoot.CrefyLibrary.ToggleKeybind = __FGRoot.CrefyLibrary.Options.FG100_MenuKeybind
            menuGroup:AddButton({ Text = "Unload", Func = function()
                if type(shutdown) == "function" then
                    shutdown(false)
                else
                    -- Covers an unusually early click during script initialization.
                    State.shutdownRequested = true
                    if __FGRoot.CrefyLibrary and not __FGRoot.CrefyLibrary.Unloaded then
                        pcall(function() __FGRoot.CrefyLibrary:Unload() end)
                    end
                end
            end })

            __FGRoot.CrefyThemeManager:SetLibrary(__FGRoot.CrefyLibrary)
            __FGRoot.CrefySaveManager:SetLibrary(__FGRoot.CrefyLibrary)
            __FGRoot.CrefySaveManager:IgnoreThemeSettings()
            __FGRoot.CrefySaveManager:SetIgnoreIndexes({ "FG100_MenuKeybind" })
            __FGRoot.CrefyThemeManager:SetFolder("Young0xHub/FG100")
            __FGRoot.CrefySaveManager:SetFolder("Young0xHub/FG100/MuscleLegends")
            __FGRoot.CrefySaveManager:SetSubFolder(tostring(game.PlaceId))
            __FGRoot.CrefySaveManager:BuildConfigSection(settingsTab)
            __FGRoot.CrefyThemeManager:ApplyToTab(settingsTab)
        end)
        if not addonSetupOk then
            warn("[FG100] Crefy Settings/addon setup failed: " .. tostring(addonSetupError))
        end
    end
end

track(tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	TabBar.CanvasSize = UDim2.fromOffset(tabLayout.AbsoluteContentSize.X + 14, 0)
end))
track(UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseWheel or not TabBar.Visible then return end
	local mouse = UserInputService:GetMouseLocation()
	local position, size = TabBar.AbsolutePosition, TabBar.AbsoluteSize
	if mouse.X < position.X or mouse.X > position.X + size.X
		or mouse.Y < position.Y or mouse.Y > position.Y + size.Y then return end
	local maximum = math.max(0, TabBar.AbsoluteCanvasSize.X - size.X)
	local target = math.clamp(TabBar.CanvasPosition.X - input.Position.Z * 92, 0, maximum)
	TabBar.CanvasPosition = Vector2.new(target, 0)
end))

do
	local TabOverflow = Instance.new("TextButton")
	TabOverflow.Name = "TabOverflow"
	TabOverflow.Size = UDim2.fromOffset(24, TAB_H - 8)
	TabOverflow.Position = UDim2.new(1, -24, 0, HEADER_H + 4)
	TabOverflow.BackgroundColor3 = Color3.fromRGB(8, 9, 18)
	TabOverflow.BackgroundTransparency = 1
	TabOverflow.BorderSizePixel = 0
	TabOverflow.Text = ""
	TabOverflow.AutoButtonColor = false
	TabOverflow.Active = true
	TabOverflow.Selectable = true
	TabOverflow.ZIndex = 24
	TabOverflow.Visible = false
	TabOverflow.Parent = MainFrame
	Instance.new("UICorner", TabOverflow).CornerRadius = UDim.new(0, 7)
	local overflowStroke = Instance.new("UIStroke")
	overflowStroke.Color = C.blue
	overflowStroke.Transparency = 1
	overflowStroke.Parent = TabOverflow

	local Fade = Instance.new("UIGradient")
	Fade.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 1),
	})
	Fade.Parent = TabOverflow

	local Arrow = Instance.new("TextLabel")
	Arrow.Size = UDim2.fromScale(1, 1)
	Arrow.Position = UDim2.fromOffset(0, 0)
	Arrow.BackgroundTransparency = 1
	Arrow.Text = "›"
	Arrow.TextColor3 = Color3.fromRGB(190, 150, 255)
	Arrow.TextStrokeColor3 = Color3.fromRGB(4, 5, 12)
	Arrow.TextStrokeTransparency = 0.34
	Arrow.Font = Enum.Font.GothamBold
	Arrow.TextSize = 26
	Arrow.ZIndex = 25
	Arrow.Parent = TabOverflow
	Arrow:SetAttribute("KeepTextStyle", true)

	track(TabOverflow.Activated:Connect(function()
		local maximum = math.max(0, TabBar.AbsoluteCanvasSize.X - TabBar.AbsoluteSize.X)
		local target = math.clamp(TabBar.CanvasPosition.X + math.max(110, TabBar.AbsoluteSize.X * 0.58), 0, maximum)
		if State.tabScrollTween then pcall(State.tabScrollTween.Cancel, State.tabScrollTween) end
		State.tabScrollTween = TweenService:Create(TabBar,
			TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				CanvasPosition = Vector2.new(target, 0),
		})
		State.tabScrollTween:Play()
	end))
	track(TabOverflow.MouseEnter:Connect(function()
		TweenService:Create(Arrow, TweenInfo.new(0.10), {
			TextColor3 = C.white,
			TextStrokeTransparency = 0.18,
		}):Play()
	end))
	track(TabOverflow.MouseLeave:Connect(function()
		TweenService:Create(Arrow, TweenInfo.new(0.12), {
			TextColor3 = Color3.fromRGB(190, 150, 255),
			TextStrokeTransparency = 0.34,
		}):Play()
	end))

	local TabUnderflow = Instance.new("TextButton")
	TabUnderflow.Name = "TabUnderflow"
	TabUnderflow.Size = UDim2.fromOffset(24, TAB_H - 8)
	TabUnderflow.Position = UDim2.new(0, 0, 0, HEADER_H + 4)
	TabUnderflow.BackgroundColor3 = Color3.fromRGB(8, 9, 18)
	TabUnderflow.BackgroundTransparency = 1
	TabUnderflow.BorderSizePixel = 0
	TabUnderflow.Text = ""
	TabUnderflow.AutoButtonColor = false
	TabUnderflow.Active = true
	TabUnderflow.Selectable = true
	TabUnderflow.ZIndex = 24
	TabUnderflow.Visible = false
	TabUnderflow.Parent = MainFrame
	Instance.new("UICorner", TabUnderflow).CornerRadius = UDim.new(0, 7)

	local LeftArrow = Instance.new("TextLabel")
	LeftArrow.Size = UDim2.fromScale(1, 1)
	LeftArrow.BackgroundTransparency = 1
	LeftArrow.Text = "‹"
	LeftArrow.TextColor3 = Color3.fromRGB(190, 150, 255)
	LeftArrow.TextStrokeColor3 = Color3.fromRGB(4, 5, 12)
	LeftArrow.TextStrokeTransparency = 0.34
	LeftArrow.Font = Enum.Font.GothamBold
	LeftArrow.TextSize = 26
	LeftArrow.ZIndex = 25
	LeftArrow.Parent = TabUnderflow
	LeftArrow:SetAttribute("KeepTextStyle", true)

	track(TabUnderflow.Activated:Connect(function()
		local target = math.max(0,
			TabBar.CanvasPosition.X - math.max(110, (TabBar.AbsoluteSize.X + 24) * 0.58))
		if State.tabScrollTween then pcall(State.tabScrollTween.Cancel, State.tabScrollTween) end
		State.tabScrollTween = TweenService:Create(TabBar,
			TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				CanvasPosition = Vector2.new(target, 0),
			})
		State.tabScrollTween:Play()
	end))
	track(TabUnderflow.MouseEnter:Connect(function()
		TweenService:Create(LeftArrow, TweenInfo.new(0.10), {
			TextColor3 = C.white,
			TextStrokeTransparency = 0.18,
		}):Play()
	end))
	track(TabUnderflow.MouseLeave:Connect(function()
		TweenService:Create(LeftArrow, TweenInfo.new(0.12), {
			TextColor3 = Color3.fromRGB(190, 150, 255),
			TextStrokeTransparency = 0.34,
		}):Play()
	end))


	local function refreshOverflow()
		local showLeft = TabBar.CanvasPosition.X > 4
		if TabUnderflow.Visible ~= showLeft then
			TabUnderflow.Visible = showLeft
			TabBar.Position = UDim2.new(0, showLeft and 24 or 0, 0, HEADER_H)
			TabBar.Size = UDim2.new(1, showLeft and -48 or -24, 0, TAB_H)
		end
		local maximum = math.max(0, tabLayout.AbsoluteContentSize.X + 14 - TabBar.AbsoluteSize.X)
		TabOverflow.Visible = maximum > 5 and TabBar.CanvasPosition.X < maximum - 4
	end
	track(TabBar:GetPropertyChangedSignal("CanvasPosition"):Connect(refreshOverflow))
	track(TabBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshOverflow))
	track(tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		task.defer(refreshOverflow)
	end))
	task.defer(refreshOverflow)
end


__FGRoot.CrefyUI = (function()
local function nativePageName(page)
    if type(page) == "table" then return tostring(page.Name or "Main") end
    local ok, name = pcall(function() return page.Name end)
    return ok and tostring(name) or "Main"
end

-- Central registry used by config persistence and death/respawn recovery.
-- The native UI migration had retained calls to this function but omitted its
-- implementation, which left the profile registry empty.
State.registerProfileControl = function(page, titleText, kind, controller)
    if not page or nativePageName(page) == "Perfiles" or type(controller) ~= "table" then
        return nil
    end
    local base = nativePageName(page) .. "|" .. tostring(titleText)
    local key = base
    local suffix = 2
    while State.profileControls[key] and State.profileControls[key] ~= controller do
        key = base .. "|" .. tostring(suffix)
        suffix = suffix + 1
    end
    controller.ProfileKind = kind
    controller.ProfileKey = key
    State.profileControls[key] = controller
    if kind == "selector" then
        State.selectorControllers[key] = controller
    end
    return key
end

local CrefyControlIds = {}
local function idToken(value)
    local token = tostring(value or "control"):lower()
    token = token:gsub("[^%w]+", "_"):gsub("_+", "_"):gsub("^_", ""):gsub("_$", "")
    if token == "" then token = "control" end
    if #token > 42 then token = token:sub(1, 42):gsub("_+$", "") end
    return token:upper()
end

local function nextCrefyId(kind, page, title)
    local base = string.format("FG100_%s_%s_%s", idToken(nativePageName(page)), idToken(kind), idToken(title))
    local id = base
    local suffix = 2
    while CrefyControlIds[id] do
        id = base .. "_" .. tostring(suffix)
        suffix = suffix + 1
    end
    CrefyControlIds[id] = true
    return id
end

local function bindCrefyLanguage(control, originalText)
    if not control or type(State.onLanguageChanged) ~= "function" then return end
    local baseText = tostring(originalText or "")
    local unbind = State.onLanguageChanged(function()
        local translated = type(State.translateText) == "function" and State.translateText(baseText) or baseText
        pcall(function()
            if type(control.SetText) == "function" then
                control:SetText(translated)
            elseif control.TextLabel then
                control.TextLabel.Text = translated
            else
                control.Text = translated
            end
        end)
    end)
    if type(unbind) == "function" then addCleanup(unbind) end
end

local function makeGroupProxy(group, name)
    local attrs = { Name = name }
    local proxy = setmetatable({}, {
        __index = function(_, key)
            if key == "Name" then return attrs.Name end
            if key == "Visible" then return group.Visible ~= false end
            if key == "Parent" then return nil end
            if key == "SetVisible" then return function(_, visible) group:SetVisible(visible == true) end end
            if key == "SetAttribute" then return function(_, attr, value) attrs[attr] = value end end
            if key == "GetAttribute" then return function(_, attr) return attrs[attr] end end
            if key == "IsA" then return function() return false end end
            if key == "GetDescendants" or key == "GetChildren" then return function() return {} end end
            if key == "FindFirstChild" or key == "FindFirstChildOfClass" then return function() return nil end end
            if key == "Destroy" then return function() if group.Destroy then group:Destroy() end end end
            return attrs[key]
        end,
        __newindex = function(_, key, value)
            if key == "Visible" then
                if group.SetVisible then group:SetVisible(value == true) end
            elseif key == "Name" then
                attrs.Name = value
            else
                -- Size/position/stroke fields belonged to the previous skin and are
                -- intentionally not forwarded into Crefy's internal layout objects.
                attrs[key] = value
            end
        end,
    })
    __FGRoot.CrefyGroupProxies[group] = proxy
    return proxy
end

local function getCrefyGroup(page)
    assert(__FGRoot.CrefyEnabled and __FGRoot.CrefyLibrary, "Crefy library is not initialized")
    local pageName = nativePageName(page)
    local group = __FGRoot.CrefyCurrentGroups[pageName]
    if group and not group.Destroyed then return group end
    local tab = __FGRoot.CrefyTabs[pageName]
    assert(tab, "No Crefy tab mapped for page " .. pageName)
    group = tab:AddGroupbox({ Side = "Left", Name = pageName .. " Controls", IconName = "sliders-horizontal" })
    __FGRoot.CrefyGroups[pageName] = __FGRoot.CrefyGroups[pageName] or {}
    table.insert(__FGRoot.CrefyGroups[pageName], group)
    __FGRoot.CrefyCurrentGroups[pageName] = group
    return group
end

local function makeGuiCompatProxy(control, target, kind)
    local attrs = {}
    local proxy = {}
    local function getTarget()
        return target or (control and (control.Base or control.Holder))
    end
    setmetatable(proxy, {
        __index = function(_, key)
            if key == "Text" then return control and control.Text or (getTarget() and getTarget().Text) end
            if key == "Visible" then return control and control.Visible ~= false end
            if key == "Parent" then return control and control.Parent or (getTarget() and getTarget().Parent) end
            if key == "Name" then return attrs.Name or (getTarget() and getTarget().Name) end
            if key == "SetText" then return function(_, value) if control and control.SetText then control:SetText(tostring(value or "")) elseif getTarget() then getTarget().Text = tostring(value or "") end end end
            if key == "SetVisible" then return function(_, value) if control and control.SetVisible then control:SetVisible(value == true) elseif getTarget() then getTarget().Visible = value == true end end end
            if key == "SetDisabled" then return function(_, value) if control and control.SetDisabled then control:SetDisabled(value == true) elseif getTarget() then getTarget().Active = not value end end end
            if key == "SetAttribute" then return function(_, name, value) attrs[name] = value; if name == "Disabled" and control and control.SetDisabled then control:SetDisabled(value == true) end end end
            if key == "GetAttribute" then return function(_, name) return attrs[name] end end
            if key == "Activated" or key == "MouseButton1Click" or key == "MouseEnter" or key == "MouseLeave" then
                local instance = getTarget()
                return instance and instance[key]
            end
            if key == "FindFirstChild" or key == "FindFirstChildOfClass" or key == "FindFirstChildWhichIsA" or key == "GetChildren" or key == "GetDescendants" or key == "IsA" then
                local instance = getTarget()
                if not instance then
                    return function()
                        if key == "GetChildren" or key == "GetDescendants" then return {} end
                        return nil
                    end
                end
                return function(_, ...) return instance[key](instance, ...) end
            end
            if key == "Destroy" then return function() if control and control.Destroy then control:Destroy() elseif getTarget() then getTarget():Destroy() end end end
            if key == "Size" or key == "Position" or key == "LayoutOrder" or key == "TextSize" or key == "BackgroundTransparency" or key == "BackgroundColor3" or key == "TextColor3" or key == "TextTransparency" or key == "Active" or key == "Selectable" then
                local instance = getTarget()
                if instance then local ok, value = pcall(function() return instance[key] end); if ok then return value end end
                return attrs[key]
            end
            if control and control[key] ~= nil then return control[key] end
            local instance = getTarget()
            if instance then local ok, value = pcall(function() return instance[key] end); if ok then return value end end
            return attrs[key]
        end,
        __newindex = function(_, key, value)
            if key == "Text" then
                if control and control.SetText then control:SetText(tostring(value or "")) elseif getTarget() then getTarget().Text = tostring(value or "") end
            elseif key == "Visible" then
                if control and control.SetVisible then control:SetVisible(value == true) elseif getTarget() then getTarget().Visible = value == true end
            elseif key == "Active" or key == "Selectable" then
                if control and control.SetDisabled then control:SetDisabled(value == false) elseif getTarget() then getTarget()[key] = value end
            elseif key == "Name" then
                attrs.Name = value
                -- Do not rename controls inside Crefy's internal tree.
            elseif key == "Parent" or key == "Size" or key == "Position" or key == "LayoutOrder" or key == "TextSize" then
                attrs[key] = value
            elseif key == "SetAttribute" then
                attrs[key] = value
            else
                local instance = getTarget()
                if instance then pcall(function() instance[key] = value end) else attrs[key] = value end
            end
        end,
    })
    return proxy
end

local function makeSectionProxy(group, title)
    local groupProxy = makeGroupProxy(group, title)
    local attrs = { Text = title }
    return setmetatable({}, {
        __index = function(_, key)
            if key == "Parent" then return groupProxy end
            if key == "Text" then return attrs.Text end
            if key == "Visible" then return group.Visible ~= false end
            if key == "SetAttribute" then return function(_, name, value) attrs[name] = value end end
            if key == "GetAttribute" then return function(_, name) return attrs[name] end end
            if key == "SetText" then return function(_, value) attrs.Text = tostring(value or "") end end
            if key == "IsA" then return function() return false end end
            if key == "GetDescendants" or key == "GetChildren" then return function() return {} end end
            return attrs[key]
        end,
        __newindex = function(_, key, value)
            if key == "Visible" then group:SetVisible(value == true) else attrs[key] = value end
        end,
    })
end

local function uiAddSection(page, text)
    local tabName = nativePageName(page)
    local tab = __FGRoot.CrefyTabs[tabName]
    assert(tab, "Missing Crefy tab for section " .. tostring(text))
    local group = tab:AddGroupbox({
        Side = "Left",
        Name = tostring(text or (tabName .. " Controls")),
        IconName = (__FGRoot.CrefyIconByTab and __FGRoot.CrefyIconByTab[tabName]) or "sliders-horizontal",
    })
    __FGRoot.CrefyGroups[tabName] = __FGRoot.CrefyGroups[tabName] or {}
    table.insert(__FGRoot.CrefyGroups[tabName], group)
    __FGRoot.CrefyCurrentGroups[tabName] = group
    nextOrder(page)
    return makeSectionProxy(group, tostring(text or ""))
end

local function styleRow(row, height)
	row.Size = UDim2.new(1, 0, 0, height or 38)
	row.BackgroundColor3 = C.row
	row.BackgroundTransparency = 0.16
	row.BorderSizePixel = 0
	row.ZIndex = 11
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 11)
	local stroke = addRgbStroke(row, 1, 0.30)
    row:SetAttribute("SurfaceRow",true)
    local surface=Instance.new("UIGradient",row)
    surface.Name="Surface"; surface.Rotation=90
    surface.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(218,218,225))
	local topLine = Instance.new("Frame")
	topLine.Name = "TopSheen"
	topLine.Size = UDim2.new(1, -20, 0, 1)
	topLine.Position = UDim2.fromOffset(10, 0)
	topLine.BackgroundColor3 = C.white
	topLine.BackgroundTransparency = 0.92
	topLine.BorderSizePixel = 0
	topLine.ZIndex = 12
	topLine.Parent = row
	Instance.new("UICorner", topLine).CornerRadius = UDim.new(1, 0)
	local topLineGradient = Instance.new("UIGradient")
	topLineGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	topLineGradient.Parent = topLine
	return stroke
end


local function colorToHex(color)
    if typeof(color) ~= "Color3" then return "#DDE6F5" end
    local r = math.clamp(math.floor(color.R * 255 + 0.5), 0, 255)
    local g = math.clamp(math.floor(color.G * 255 + 0.5), 0, 255)
    local b = math.clamp(math.floor(color.B * 255 + 0.5), 0, 255)
    return string.format("#%02X%02X%02X", r, g, b)
end

local function escapeRichText(value)
    return tostring(value or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

local function uiAddInfoRow(page, labelText, valueText, color, showIndicator, showAccent)
    local group = getCrefyGroup(page)
    local nativeLabel = group:AddLabel({ Text = "", DoesWrap = true, Size = 12 })
    local label = tostring(labelText or "")
    local value = tostring(valueText or "-")
    local valueColor = color or C.white
    local indicatorColor = color or C.green
    local visible = true
    local order = nextOrder(page)
    local function render()
        local displayLabel = type(State.translateText) == "function" and State.translateText(label) or label
        local displayValue = type(State.translateText) == "function" and State.translateText(value) or value
        local dot = showIndicator and ('<font color="' .. colorToHex(indicatorColor) .. '">●</font> ') or ""
        local labelPart = displayLabel ~= "" and ('<font color="' .. colorToHex(C.dim) .. '">' .. escapeRichText(displayLabel) .. '</font> ') or ""
        local valuePart = '<font color="' .. colorToHex(valueColor) .. '">' .. escapeRichText(displayValue) .. '</font>'
        nativeLabel:SetText(dot .. labelPart .. valuePart)
        nativeLabel:SetVisible(visible)
    end
    if type(State.onLanguageChanged) == "function" then
        local unbind = State.onLanguageChanged(function() render() end)
        if type(unbind) == "function" then addCleanup(unbind) end
    end
    local valueProxy = setmetatable({}, {
        __index = function(_, key)
            if key == "Text" then return value end
            if key == "SetText" then return function(_, newValue) value = tostring(newValue or ""); render() end end
            if key == "SetVisible" then return function(_, newVisible) visible = newVisible == true; render() end end
            if key == "Visible" then return visible end
            if key == "Parent" then return __FGRoot.CrefyGroupProxies[group] or makeGroupProxy(group, tostring(group.Name or "Groupbox")) end
            if key == "Name" then return tostring(label):gsub("[^%w]+", "") .. "Value" end
            return nil
        end,
        __newindex = function(_, key, newValue)
            if key == "Text" then value = tostring(newValue or ""); render()
            elseif key == "Visible" then visible = newValue == true; render()
            elseif key == "TextColor3" then valueColor = newValue; render()
            else end
        end,
    })
    local indicatorProxy = setmetatable({}, {
        __index = function(_, key)
            if key == "BackgroundColor3" then return indicatorColor end
            if key == "Visible" then return showIndicator and visible end
            if key == "Name" then return "StatusDot" end
            return nil
        end,
        __newindex = function(_, key, newValue)
            if key == "BackgroundColor3" then indicatorColor = newValue; render()
            elseif key == "Visible" then showIndicator = newValue == true; render() end
        end,
    })
    local rowAttrs = { LayoutOrder = order, Visible = true }
    local rowProxy = setmetatable({}, {
        __index = function(_, key)
            if key == "Visible" then return visible end
            if key == "LayoutOrder" then return rowAttrs.LayoutOrder end
            if key == "Name" then return tostring(label):gsub("[^%w]+", "") .. "Row" end
            if key == "Parent" then return __FGRoot.CrefyGroupProxies[group] or makeGroupProxy(group, tostring(group.Name or "Groupbox")) end
            if key == "FindFirstChild" then return function(_, name) if name == "StatusDot" and showIndicator then return indicatorProxy end return nil end end
            if key == "FindFirstChildOfClass" or key == "FindFirstChildWhichIsA" then return function() return nil end end
            if key == "GetDescendants" or key == "GetChildren" then return function() return {} end end
            if key == "SetAttribute" then return function(_, name, v) rowAttrs[name] = v end end
            if key == "GetAttribute" then return function(_, name) return rowAttrs[name] end end
            if key == "IsA" then return function() return false end end
            return rowAttrs[key]
        end,
        __newindex = function(_, key, newValue)
            if key == "Visible" then visible = newValue == true; render() else rowAttrs[key] = newValue end
        end,
    })
    local labelProxy = setmetatable({}, {
        __index = function(_, key)
            if key == "Text" then return label end
            if key == "SetText" then return function(_, newValue) label = tostring(newValue or ""); render() end end
            if key == "SetAttribute" then return function(_, name, v) rowAttrs[name] = v end end
            if key == "GetAttribute" then return function(_, name) return rowAttrs[name] end end
            return nil
        end,
        __newindex = function(_, key, newValue) if key == "Text" then label = tostring(newValue or ""); render() end end,
    })
    render()
    return valueProxy, rowProxy, labelProxy, showIndicator and indicatorProxy or nil
end

local function uiAddStatusRow(page, text)
    local value = uiAddInfoRow(page, "Estado", text, C.green)
    return value
end

local function uiAddButton(page, text, callback, color, hoverColor)
    local group = getCrefyGroup(page)
    local id = nextCrefyId("Button", page, text)
    local compat
    local control
    control = group:AddButton(id, {
        Text = tostring(text or "Button"),
        Func = function()
            if control and control.Disabled then return end
            State.pushOutput("CLICK", tostring(text or "Button"))
            local ok, err = pcall(callback or function() end, compat)
            if not ok then State.pushOutput("ERROR", tostring(text or "Button") .. ": " .. tostring(err):sub(1, 240)) end
        end,
        DoubleClick = false,
        Disabled = false,
        Visible = true,
    })
    compat = makeGuiCompatProxy(control, control and control.Base, "button")
    bindCrefyLanguage(control, text)
    nextOrder(page)
    return compat
end

State.setButtonDisabled = function(button, disabled)
    if not button then return end
    disabled = disabled == true
    local ok = pcall(function()
        if type(button.SetDisabled) == "function" then
            button:SetDisabled(disabled)
        elseif type(button.SetAttribute) == "function" then
            button:SetAttribute("Disabled", disabled)
            button.Active = not disabled
        end
    end)
    if not ok then end
end

local RESPAWN_RESTART_SAFE_PAGES = {
    Main = true,
    ["Fast Farm"] = true,
    ["Auto Farm"] = true,
    ["Full Train"] = true,
    Boss = true,
    Rebirths = true,
    ["Pet Shop"] = true,
    Inventario = true,
    Misc = true,
}

local function uiAddToggle(page, text, callback)
    local group = getCrefyGroup(page)
    local id = nextCrefyId("Toggle", page, text)
    local current = false
    local locked = false
    local frozen = false
    local control
    local function callCallback(value)
        if __FGRoot.CrefyCallbackSuppressed[id] then
            current = value == true
            return true
        end
        local previous = current
        local ok, accepted = pcall(callback or function() end, value == true)
        if not ok or accepted == false then
            __FGRoot.CrefyCallbackSuppressed[id] = true
            if control then pcall(function() control:SetValue(previous) end) end
            __FGRoot.CrefyCallbackSuppressed[id] = nil
            current = previous
            State.pushOutput("ERROR", "Acción rechazada: " .. tostring(text))
            return false
        end
        current = value == true
        State.pushOutput(current and "ON" or "OFF", tostring(text))
        return true
    end
    control = group:AddToggle(id, {
        Text = tostring(text or "Toggle"),
        Default = false,
        Disabled = false,
        Visible = true,
        Callback = function(value) callCallback(value == true) end,
    })
    current = control and control.Value == true or false
    bindCrefyLanguage(control, text)
    local compatButton = makeGuiCompatProxy(control, control and control.Holder, "toggle")
    local controller = { Button = compatButton, Native = control }
    function controller:Set(value, silent)
        value = value == true
        if locked and value then return false end
        if current == value then return current end
        __FGRoot.CrefyCallbackSuppressed[id] = silent == true
        local ok = pcall(function() control:SetValue(value) end)
        __FGRoot.CrefyCallbackSuppressed[id] = nil
        if not ok then return current end
        if silent then current = control.Value == true end
        return current
    end
    function controller:Get() return current end
    function controller:Restart()
        if not current then return false end
        local pageName = nativePageName(page)
        -- Do not replay action-oriented controls after death (for example kill/server-hop
        -- controls). Dedicated AFK/Fast Farm/Pet Momentum resume paths are handled separately.
        if not RESPAWN_RESTART_SAFE_PAGES[pageName] then
            State.pushOutput("SYSTEM", "Respawn recovery skipped non-idempotent toggle: " .. tostring(text))
            return false
        end
        local ok, accepted = pcall(callback or function() end, true)
        if not ok or accepted == false then
            State.pushOutput("ERROR", "No se pudo reanudar: " .. tostring(text))
            return false
        end
        return true
    end
    function controller:SetLocked(value)
        locked = value == true
        if locked and current then controller:Set(false, false) end
        if control and control.SetDisabled then control:SetDisabled(locked or frozen) end
    end
    function controller:SetFrozen(value)
        frozen = value == true
        if control and control.SetDisabled then control:SetDisabled(locked or frozen) end
    end
    function controller:IsFrozen() return frozen end
    function controller:IsLocked() return locked end
    State.allToggleControllers[#State.allToggleControllers + 1] = controller
    State.registerProfileControl(page, text, "toggle", controller)
    nextOrder(page)
    return controller, compatButton
end

local function valuesEqual(left, right)
    if left == right then return true end
    if type(left) == "table" and type(right) == "table" then
        return (left.userId and left.userId == right.userId)
            or (left.name and left.name == right.name)
            or (left.profileValue and left.profileValue == right.profileValue)
            or (left.label and left.label == right.label)
    end
    return false
end

local function selectorLabel(value)
    if type(value) == "table" then
        return tostring(value.label or value.name or value.profileValue or value.displayName or value.DisplayName or value[1] or value.username or "Option")
    end
    return tostring(value)
end

local function uiAddSelector(page, titleText, values, callback, openCallback, placeholder)
    local group = getCrefyGroup(page)
    local id = nextCrefyId("Dropdown", page, titleText)
    local sourceValues = {}
    local keyToValue = {}
    local valueToKey = {}
    local dictionary = {}
    local selectedKey = nil
    local suppress = false
    local control
    local function stableOptionKey(value, index, used)
        local identity = value
        if type(value) == "table" then
            identity = value.userId or value.UserId or value.UserID or value.id or value.Id
                or value.jobId or value.JobId or value.profileValue or value.name or value.Name
                or value.label or value.Label or value.username or value[1] or index
        end
        local token = tostring(identity or index):lower()
        token = token:gsub("[^%w]+", "_"):gsub("_+", "_"):gsub("^_", ""):gsub("_$", "")
        if token == "" then token = "item_" .. tostring(index) end
        if #token > 48 then token = token:sub(1, 48):gsub("_+$", "") end
        local base = "opt_" .. token
        local key = base
        local suffix = 2
        while used[key] do
            key = base .. "_" .. tostring(suffix)
            suffix = suffix + 1
        end
        used[key] = true
        return key
    end
    local function rebuild(newValues)
        sourceValues = type(newValues) == "table" and newValues or {}
        keyToValue, valueToKey, dictionary = {}, {}, {}
        if placeholder then dictionary.__placeholder = tostring(placeholder) end
        local used = { __placeholder = true }
        for index, value in ipairs(sourceValues) do
            local key = stableOptionKey(value, index, used)
            keyToValue[key] = value
            local label = selectorLabel(value)
            dictionary[key] = type(State.translateText) == "function" and State.translateText(label) or label
            if valueToKey[value] == nil then valueToKey[value] = key end
        end
    end
    rebuild(values)
    local firstDefault = placeholder and "__placeholder" or (sourceValues[1] ~= nil and valueToKey[sourceValues[1]] or nil)
    control = group:AddDropdown(id, {
        Values = dictionary,
        Default = firstDefault,
        Multi = false,
        AllowNull = true,
        Searchable = true,
        Text = tostring(titleText or "Select"),
        Callback = function(key)
            selectedKey = key
            if suppress or __FGRoot.CrefyCallbackSuppressed[id] then return end
            local selected = keyToValue[key]
            local ok, err = pcall(callback or function() end, selected)
            if not ok then State.pushOutput("ERROR", tostring(titleText) .. ": " .. tostring(err):sub(1, 240)) end
            State.pushOutput("SELECT", tostring(titleText) .. ": " .. (selected ~= nil and selectorLabel(selected) or tostring(placeholder or "None")))
        end,
    })
    selectedKey = control and control.Value or firstDefault
    bindCrefyLanguage(control, titleText)
    local data = {}
    local rowProxy = makeGuiCompatProxy(control, control and control.Holder, "dropdown")
    data.Row = rowProxy
    data.Page = page
    data.Native = control
    local function getSelected()
        local key = control and control.Value
        if key == "__placeholder" or key == nil then return nil end
        return keyToValue[key]
    end
    function data:Get() return getSelected() end
    function data:SetValues(newValues, preserve)
        local old = preserve and getSelected() or nil
        rebuild(newValues)
        suppress = true
        __FGRoot.CrefyCallbackSuppressed[id] = true
        pcall(function() control:SetValues(dictionary) end)
        local targetKey
        if old ~= nil then
            for _, value in ipairs(sourceValues) do
                if valuesEqual(value, old) then targetKey = valueToKey[value]; break end
            end
        end
        targetKey = targetKey
            or (placeholder and "__placeholder")
            or (sourceValues[1] ~= nil and valueToKey[sourceValues[1]] or nil)
        if targetKey then
            pcall(function() control:SetValue(targetKey) end)
        else
            -- Empty dynamic lists must clear stale selection keys instead of retaining
            -- a value that no longer exists in the dropdown's current Values table.
            pcall(function() control:SetValue(nil) end)
        end
        selectedKey = targetKey
        __FGRoot.CrefyCallbackSuppressed[id] = nil
        suppress = false
    end
    function data:SetIndex(index)
        index = tonumber(index) or 1
        index = math.floor(index)
        local selectedValue = index >= 1 and sourceValues[index] or nil
        local key = selectedValue ~= nil and valueToKey[selectedValue] or nil
        if key then
            suppress = true; __FGRoot.CrefyCallbackSuppressed[id] = true
            pcall(function() control:SetValue(key) end)
            __FGRoot.CrefyCallbackSuppressed[id] = nil; suppress = false
            selectedKey = key
        elseif placeholder then
            suppress = true; __FGRoot.CrefyCallbackSuppressed[id] = true
            pcall(function() control:SetValue("__placeholder") end)
            __FGRoot.CrefyCallbackSuppressed[id] = nil; suppress = false
            selectedKey = "__placeholder"
        end
        return getSelected()
    end
    function data:SetValue(target)
        if target == nil and placeholder then return data:SetIndex(0) end
        for index, value in ipairs(sourceValues) do
            if valuesEqual(value, target) or selectorLabel(value) == tostring(target)
                or (type(value) == "table" and (value.profileValue == target or value.name == target or value.label == target or value[1] == target)) then
                return data:SetIndex(index)
            end
        end
        return nil
    end
    function data:SetOpen(value)
        if not control then return false end
        pcall(function()
            if value then control:Expand() else control:Collapse() end
        end)
        return data:IsOpen()
    end
    function data:IsOpen()
        local ok, expanded = pcall(function() return control:IsExpanded() end)
        return ok and expanded == true or false
    end
    function data:SetVisible(value)
        if control and control.SetVisible then control:SetVisible(value == true) end
    end
    State.registerProfileControl(page, titleText, "selector", data)
    if type(State.onLanguageChanged) == "function" then
        local unbind = State.onLanguageChanged(function()
            if not State.running or not control then return end
            data:SetValues(sourceValues, true)
        end)
        if type(unbind) == "function" then addCleanup(unbind) end
    end
    nextOrder(page)
    if type(openCallback) == "function" then
        task.spawn(function()
            local wasOpen = false
            while State.running and control and not control.Destroyed do
                local isOpen = data:IsOpen()
                if isOpen and not wasOpen then pcall(openCallback, data.Row) end
                wasOpen = isOpen
                task.wait(0.12)
            end
        end)
    end
    -- The second return value used to be the old dropdown's display TextLabel.
    -- This lightweight proxy keeps its cosmetic name assignments harmless.
    local function hierarchyProxy()
        local attrs = {}
        return setmetatable({}, {
            __index = function(_, key)
                if key == "Parent" then return hierarchyProxy() end
                if key == "GetDescendants" or key == "GetChildren" then return function() return {} end end
                if key == "IsA" then return function() return false end end
                return attrs[key]
            end,
            __newindex = function(_, key, value) attrs[key] = value end,
        })
    end
    data.ValueLabel = hierarchyProxy()
    return data, data.ValueLabel
end

local function uiAddInput(page, titleText, placeholder, callback, skipProfile)
    local group = getCrefyGroup(page)
    local id = nextCrefyId("Input", page, titleText)
    local suppress = false
    local focused = false
    local pendingValue = ""
    local function commit(value)
        value = tostring(value or "")
        pendingValue = value
        State.pushOutput("INPUT", tostring(titleText) .. ": " .. value)
        local ok, err = pcall(callback or function() end, value)
        if not ok then
            State.pushOutput("ERROR", tostring(titleText) .. ": " .. tostring(err):sub(1, 240))
        end
    end
    local control = group:AddInput(id, {
        Default = "",
        Numeric = false,
        Finished = false,
        ClearTextOnFocus = false,
        Text = tostring(titleText or "Input"),
        Placeholder = tostring(placeholder or ""),
        Callback = function(value)
            pendingValue = tostring(value or "")
            -- While the user is typing, commit only on FocusLost, matching the former UI.
            -- Programmatic changes (for example config loads) still invoke the callback.
            if not suppress and not focused then commit(pendingValue) end
        end,
    })
    bindCrefyLanguage(control, titleText)
    pendingValue = tostring(control and control.Value or "")
    local textBox = control and control.Holder and control.Holder:FindFirstChildWhichIsA("TextBox", true)
    if textBox then
        track(textBox.Focused:Connect(function() focused = true end))
        track(textBox.FocusLost:Connect(function()
            focused = false
            if not suppress then commit(pendingValue) end
        end))
    else
        warn("[FG100] Crefy input did not expose its TextBox; input commits will use native callback timing")
    end

    local function setValue(value, invokeCallback)
        value = tostring(value or "")
        suppress = true
        local ok = pcall(function() control:SetValue(value) end)
        pendingValue = tostring((ok and control and control.Value) or value)
        suppress = false
        if ok and invokeCallback then commit(pendingValue) end
        return pendingValue
    end
    local proxy = {}
    local parentProxy = setmetatable({}, {
        __index = function(_, key) if key == "Visible" then return control.Visible end return nil end,
        __newindex = function(_, key, value)
            if key == "Visible" and control.SetVisible then control:SetVisible(value == true) end
        end,
    })
    setmetatable(proxy, {
        __index = function(_, key)
            if key == "Text" or key == "Value" then return control.Value end
            if key == "Parent" then return parentProxy end
            if key == "Native" then return control end
            if key == "SetVisible" then return function(_, visible) control:SetVisible(visible == true) end end
            if key == "Get" then return function() return control.Value end end
            if key == "Set" then return function(_, value) return setValue(value, true) end end
            if key == "SetText" then return function(_, value) control:SetText(tostring(value or "")) end end
            if key == "Name" then return titleText end
            return nil
        end,
        __newindex = function(_, key, value)
            if key == "Text" or key == "Value" then setValue(value, true)
            elseif key == "Visible" then control:SetVisible(value == true) end
        end,
    })
    local profileInput = {}
    function profileInput:Get() return control.Value end
    function profileInput:Set(value) return setValue(value, true) end
    if not skipProfile then State.registerProfileControl(page, titleText, "input", profileInput) end
    nextOrder(page)
    return proxy
end

local function uiAddSlider(page, titleText, minimum, maximum, initial, callback)
    local group = getCrefyGroup(page)
    local id = nextCrefyId("Slider", page, titleText)
    minimum = tonumber(minimum) or 0
    maximum = tonumber(maximum) or minimum + 1
    if maximum <= minimum then maximum = minimum + 1 end
    local initialValue = math.clamp(math.floor((tonumber(initial) or minimum) + 0.5), minimum, maximum)
    local suppress = false
    local control = group:AddSlider(id, {
        Text = tostring(titleText or "Slider"),
        Default = initialValue,
        Min = minimum,
        Max = maximum,
        Rounding = 0,
        Compact = false,
        Callback = function(value)
            if suppress then return end
            local rounded = math.clamp(math.floor((tonumber(value) or initialValue) + 0.5), minimum, maximum)
            pcall(callback or function() end, rounded)
        end,
    })
    bindCrefyLanguage(control, titleText)
    local controller = { Native = control }
    function controller:Get() return control.Value end
    function controller:Set(value)
        local target = math.clamp(math.floor((tonumber(value) or control.Value) + 0.5), minimum, maximum)
        if target == control.Value then return control.Value end
        control:SetValue(target)
        return control.Value
    end
    State.registerProfileControl(page, titleText, "slider", controller)
    nextOrder(page)
    -- Match the former helper's initial callback behavior.
    pcall(callback or function() end, initialValue)
    return controller
end

return {
    nativePageName = nativePageName,
    getCrefyGroup = getCrefyGroup,
    styleRow = styleRow,
    uiAddSection = uiAddSection,
    uiAddInfoRow = uiAddInfoRow,
    uiAddStatusRow = uiAddStatusRow,
    uiAddButton = uiAddButton,
    uiAddToggle = uiAddToggle,
    uiAddSelector = uiAddSelector,
    uiAddInput = uiAddInput,
    uiAddSlider = uiAddSlider,
    RESPAWN_RESTART_SAFE_PAGES = RESPAWN_RESTART_SAFE_PAGES,
}
end)()

do
local infoPage = Pages.Info
__FGRoot.CrefyUI.uiAddSection(infoPage, "👤 Info Player 👤")
__FGRoot.CrefyUI.uiAddInfoRow(infoPage, "User:", LP.DisplayName, C.white)
local fpsValue, fpsRow = __FGRoot.CrefyUI.uiAddInfoRow(infoPage, "FPS:", "0", C.green, true)
local fpsIndicator = fpsRow:FindFirstChild("StatusDot")
local initialPing = getPing()
local initialPingColor = State.pingStatusColor(initialPing)
local pingValue, pingRow = __FGRoot.CrefyUI.uiAddInfoRow(infoPage, "Ping:", tostring(initialPing) .. " ms", initialPingColor, true)
local pingIndicator = pingRow:FindFirstChild("StatusDot")
__FGRoot.CrefyUI.uiAddSection(infoPage, "🌐 Info Server 🌐")
__FGRoot.CrefyUI.uiAddInfoRow(infoPage, "Juego:", "Muscle Legends", C.cyan)
local serverPlayersValue = __FGRoot.CrefyUI.uiAddInfoRow(infoPage, "Server Players:", "0/0", C.white)
__FGRoot.CrefyUI.uiAddSection(infoPage, "⚡ Info Young0x Hub ⚡")
__FGRoot.CrefyUI.uiAddInfoRow(infoPage, "Script:", "Fast Glitch 100%", C.cyan)
__FGRoot.CrefyUI.uiAddInfoRow(infoPage, "Autor:", "Young0x", C.white)
__FGRoot.CrefyUI.uiAddButton(infoPage, "Discord", function(button)
	local original = button.Text
	button.Text = copyText(CONFIG.Reach[1]) and "Link copiado" or original
	task.delay(1.1, function()
		if button and button.Parent then
			button.Text = original
		end
	end)
end)
__FGRoot.CrefyUI.uiAddButton(infoPage, "YouTube", function(button)
	local original = button.Text
	button.Text = copyText(CONFIG.Reach[2]) and "Link copiado" or original
	task.delay(1.1, function()
		if button and button.Parent then
			button.Text = original
		end
	end)
end)

local frameCounter = 0
track(RunService.RenderStepped:Connect(function()
	frameCounter = frameCounter + 1
end))
startThread("infoUpdater", function()
	local lastSample = tick()
	while State.running do
		task.wait(1)
		local now = tick()
		local frames = frameCounter
		frameCounter = 0
		local fps = math.floor(frames / math.max(now - lastSample, 0.001) + 0.5)
		local fpsColor = fps >= 55 and C.green or (fps >= 30 and C.orange or C.red)
		State.currentFps = fps
		fpsValue.Text = tostring(fps)
		fpsValue.TextColor3 = fpsColor
		if fpsIndicator then
			fpsIndicator.BackgroundColor3 = fpsColor
			local glow = fpsIndicator:FindFirstChildOfClass("UIStroke")
			if glow then
				glow.Color = fpsColor
			end
		end
		lastSample = now
		local ping = getPing()
		local pingColor = State.pingStatusColor(ping)
		pingValue.Text = tostring(ping) .. " ms"
		pingValue.TextColor3 = pingColor
		if pingIndicator then
			pingIndicator.BackgroundColor3 = pingColor
			local glow = pingIndicator:FindFirstChildOfClass("UIStroke")
			if glow then
				glow.Color = pingColor
			end
		end
		serverPlayersValue.Text = tostring(#Players:GetPlayers()) .. "/" .. tostring(Players.MaxPlayers)
	end
end)
end

(function()
local mainPage = Pages.Main
__FGRoot.CrefyUI.uiAddSection(mainPage, "Main")

local sizeInput
local speedInput
local mainSizeInvokeBusy = false
local mainSizeInvokeSerial = 0


local function readMainSize()
	local normalized = tostring(sizeInput and sizeInput.Text or State.mainSize):gsub(",", ".")
	local parsed = tonumber(normalized)
	local previous = State.mainSize or 2
	local size = math.clamp(math.floor((parsed or previous) + 0.5), 1, 100)
	State.mainSize = size
	if sizeInput then sizeInput.Text = tostring(size) end
	return size
end


local function requestMainSize()
	local events = ReplicatedStorage:FindFirstChild("rEvents")
	local remote = events and events:FindFirstChild("changeSpeedSizeRemote")
	if not remote or mainSizeInvokeBusy then return end
	local size = math.clamp(math.floor((State.mainSize or 2) + 0.5), 1, 100)
	mainSizeInvokeBusy = true
	mainSizeInvokeSerial = mainSizeInvokeSerial + 1
	local serial = mainSizeInvokeSerial
	task.spawn(function()
		if remote:IsA("RemoteEvent") then
			pcall(remote.FireServer, remote, "changeSize", size)
		else
			pcall(remote.InvokeServer, remote, "changeSize", size)
		end
		if mainSizeInvokeSerial == serial then mainSizeInvokeBusy = false end
	end)
	task.delay(0.8, function()
		if mainSizeInvokeSerial == serial then mainSizeInvokeBusy = false end
	end)
end

sizeInput = __FGRoot.CrefyUI.uiAddInput(mainPage, "Set Size (Máximo 100)", "Ejemplo: 2", function()
	readMainSize()
	if State.mainAutoSize then requestMainSize() end
end)
sizeInput.Text = "2"
__FGRoot.CrefyUI.uiAddToggle(mainPage, "Auto Set Size", function(enabled)
	readMainSize()
	State.mainAutoSize = enabled == true
	stopThread("mainAutoSize")
	if State.mainAutoSize then
		requestMainSize()
		startThread("mainAutoSize", function()
			while State.running and State.mainAutoSize do
				requestMainSize()
				task.wait(0.5)
			end
		end)
	else
		mainSizeInvokeSerial = mainSizeInvokeSerial + 1
		mainSizeInvokeBusy = false
	end
	return true
end)

local originalMainSpeeds = setmetatable({}, { __mode = "k" })
local boundSpeedHumanoid = nil
local speedChangedConnection = nil
local applyingMainSpeed = false


local function readMainSpeed()
	local normalized = tostring(speedInput and speedInput.Text or State.mainSpeed):gsub(",", ".")
	local parsed = tonumber(normalized)
	local previous = State.mainSpeed or 800
	local speed = math.max(0, math.floor((parsed or previous) + 0.5))
	State.mainSpeed = speed
	if speedInput then speedInput.Text = tostring(speed) end
	return speed
end


local function applyMainSpeed()
	local humanoid = getHumanoid()
	if not humanoid then return end
	if originalMainSpeeds[humanoid] == nil then
		originalMainSpeeds[humanoid] = humanoid.WalkSpeed
	end
	if boundSpeedHumanoid ~= humanoid then
		if speedChangedConnection then
			speedChangedConnection:Disconnect()
			speedChangedConnection = nil
		end
		boundSpeedHumanoid = humanoid
		speedChangedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			if State.mainAutoSpeed and not applyingMainSpeed and humanoid.Parent
				and humanoid.WalkSpeed ~= State.mainSpeed then
				applyingMainSpeed = true
				humanoid.WalkSpeed = State.mainSpeed
				applyingMainSpeed = false
			end
		end)
	end
	if humanoid.WalkSpeed ~= State.mainSpeed then
		applyingMainSpeed = true
		humanoid.WalkSpeed = State.mainSpeed
		applyingMainSpeed = false
	end
end


local function unbindMainSpeed()
	if speedChangedConnection then
		speedChangedConnection:Disconnect()
		speedChangedConnection = nil
	end
	boundSpeedHumanoid = nil
	for humanoid, original in pairs(originalMainSpeeds) do
		if humanoid and humanoid.Parent and not State.fastSpeed then
			humanoid.WalkSpeed = original
		end
	end
end

speedInput = __FGRoot.CrefyUI.uiAddInput(mainPage, "Set Speed", "Ejemplo: 800", function()
	readMainSpeed()
	if State.mainAutoSpeed then applyMainSpeed() end
end)
speedInput.Text = "800"
__FGRoot.CrefyUI.uiAddToggle(mainPage, "Auto Set Speed", function(enabled)
	readMainSpeed()
	State.mainAutoSpeed = enabled == true
	stopThread("mainAutoSpeed")
	if State.mainAutoSpeed then
		applyMainSpeed()
		startThread("mainAutoSpeed", function()
			while State.running and State.mainAutoSpeed do
				applyMainSpeed()
				task.wait(0.35)
			end
		end)
	else
		unbindMainSpeed()
	end
	return true
end)

__FGRoot.CrefyUI.uiAddSelector(mainPage, "Set Time", { "Day", "Night" }, function(value)
	if State.setDayNight then State.setDayNight(value) end
end, function(row)
	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	local bottom = math.max(0, mainPage.AbsoluteCanvasSize.Y - mainPage.AbsoluteSize.Y)
	local rowTop = row.AbsolutePosition.Y - mainPage.AbsolutePosition.Y + mainPage.CanvasPosition.Y - 3
	TweenService:Create(mainPage, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		CanvasPosition = Vector2.new(0, math.clamp(rowTop, 0, bottom)),
	}):Play()
end)
__FGRoot.CrefyUI.uiAddToggle(mainPage, "Infinite Jump", function(enabled)
	State.infiniteJump = enabled == true
	return true
end)
track(UserInputService.JumpRequest:Connect(function()
	if State.infiniteJump then
		local humanoid = getHumanoid()
		if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end))

__FGRoot.CrefyUI.uiAddSection(mainPage, "Estadísticas visuales")
local visualStatDefinitions = {
	{ key = "Strength", label = "Strength (visual)", names = { "Strength", "Fuerza" } },
	{ key = "Gems", label = "Gems (visual)", names = { "Gems", "Gemas" } },
	{ key = "Rebirths", label = "Rebirths (visual)", names = { "Rebirths", "Rebirth" } },
	{ key = "Fights", label = "Fights (visual)", names = { "Brawls", "Fights", "Fight" } },
	{ key = "Kills", label = "Kills (visual)", names = { "Kills" } },
}
local visualStats = {}
State.visualStatRecords = setmetatable({}, { __mode = "k" })
local visualStatInputs = {}
local visualOriginalLabels = setmetatable({}, { __mode = "k" })
State.visualStatInputs = visualStatInputs
local applyingVisualStat = false


local function setVisualLabel(label, text, rememberOriginal, key)
	if not label or not label.Parent then return end
	if rememberOriginal and not visualOriginalLabels[label] then
		local shadow = label:FindFirstChild("shadow")
		visualOriginalLabels[label] = {
			text = label.Text,
			shadowText = shadow and (shadow:IsA("TextLabel") or shadow:IsA("TextButton")) and shadow.Text or nil,
			key = key,
		}
	end
	if label:IsA("TextLabel") or label:IsA("TextButton") or label:IsA("TextBox") then
		label.Text = text
	end
	local shadow = label:FindFirstChild("shadow")
	if shadow and (shadow:IsA("TextLabel") or shadow:IsA("TextButton")) then shadow.Text = text end
end


local function visualText(key)
	local record = visualStats[key]
	return record and State.formatExactWithUnit(record.value) or nil
end


local function captureOfficialVisualLabels(key)
	local gameGui = PlayerGui:FindFirstChild("gameGui")
	local currencyGui = PlayerGui:FindFirstChild("currencyFrameGui")
	local hudNew = gameGui and gameGui:FindFirstChild("hudNewMenu")
	local hudTop = hudNew and hudNew:FindFirstChild("Top")
	local infoSlots = hudTop and hudTop:FindFirstChild("InfoSlots")
	local statsMenu = gameGui and gameGui:FindFirstChild("statsMenu")
	local statsList = statsMenu and statsMenu:FindFirstChild("statsList")
	local bottomList = statsMenu and statsMenu:FindFirstChild("bottomStatList")
	local currencyFrame = currencyGui and currencyGui:FindFirstChild("currencyFrame")

	local function capture(label)
		if label and label.Parent then setVisualLabel(label, label.Text, true, key) end
	end
	if key == "Strength" then
		local frame = statsList and statsList:FindFirstChild("strengthFrame")
		local currency = currencyFrame and currencyFrame:FindFirstChild("strengthFrame")
		local newSlot = infoSlots and infoSlots:FindFirstChild("StrengthSlot")
		capture(frame and frame:FindFirstChild("amountLabel"))
		capture(currency and currency:FindFirstChild("amountLabel"))
		capture(newSlot and newSlot:FindFirstChild("Amnt"))
	elseif key == "Gems" then
		local currency = currencyFrame and currencyFrame:FindFirstChild("gemsFrame")
		local newSlot = infoSlots and infoSlots:FindFirstChild("GemSlot")
		capture(currency and currency:FindFirstChild("amountLabel"))
		capture(newSlot and newSlot:FindFirstChild("Amnt"))
	else
		local frameNames = { Rebirths = "rebirthsFrame", Fights = "brawlsFrame", Kills = "killsFrame" }
		local frame = bottomList and bottomList:FindFirstChild(frameNames[key])
		capture(frame and frame:FindFirstChild("statLabel"))
	end
end


local function applyOfficialVisualLabels()
	local gameGui = PlayerGui:FindFirstChild("gameGui")
	local currencyGui = PlayerGui:FindFirstChild("currencyFrameGui")
	local hudNew = gameGui and gameGui:FindFirstChild("hudNewMenu")
	local hudTop = hudNew and hudNew:FindFirstChild("Top")
	local infoSlots = hudTop and hudTop:FindFirstChild("InfoSlots")
	local statsMenu = gameGui and gameGui:FindFirstChild("statsMenu")
	local statsList = statsMenu and statsMenu:FindFirstChild("statsList")
	local bottomList = statsMenu and statsMenu:FindFirstChild("bottomStatList")
	local currencyFrame = currencyGui and currencyGui:FindFirstChild("currencyFrame")
	local strengthText = visualText("Strength")
	if strengthText then
		local frame = statsList and statsList:FindFirstChild("strengthFrame")
		setVisualLabel(frame and frame:FindFirstChild("amountLabel"), strengthText)
		local currency = currencyFrame and currencyFrame:FindFirstChild("strengthFrame")
		setVisualLabel(currency and currency:FindFirstChild("amountLabel"), strengthText)
		local newSlot = infoSlots and infoSlots:FindFirstChild("StrengthSlot")
		setVisualLabel(newSlot and newSlot:FindFirstChild("Amnt"), strengthText)
	end
	local gemsText = visualText("Gems")
	if gemsText then
		local currency = currencyFrame and currencyFrame:FindFirstChild("gemsFrame")
		setVisualLabel(currency and currency:FindFirstChild("amountLabel"), gemsText)
		local newSlot = infoSlots and infoSlots:FindFirstChild("GemSlot")
		setVisualLabel(newSlot and newSlot:FindFirstChild("Amnt"), gemsText)
	end
	for key, frameName in pairs({ Rebirths = "rebirthsFrame", Fights = "brawlsFrame", Kills = "killsFrame" }) do
		local text = visualText(key)
		local frame = bottomList and bottomList:FindFirstChild(frameName)
		local label = frame and frame:FindFirstChild("statLabel")
		if text and label then
			local prefix = key == "Fights" and "Brawls" or (key == "Kills" and "KOs" or "Rebirths")
			setVisualLabel(label, prefix .. " - " .. text)
		end
	end
end


local function ensureVisualPresentationLoop()
	if threads.visualStatPresentation then return end
	startThread("visualStatPresentation", function()
		while State.running and next(visualStats) do
			applyOfficialVisualLabels()
			task.wait(0.5)
		end
	end)
end


local function restoreVisualStats(silent)
	for key, record in pairs(visualStats) do
		if record.connection then pcall(record.connection.Disconnect, record.connection) end
		if record.object then State.visualStatRecords[record.object] = nil end
		if record.object and record.object.Parent and record.realValue ~= nil then
			applyingVisualStat = true
			pcall(function() record.object.Value = record.realValue end)
			applyingVisualStat = false
		end
		visualStats[key] = nil
	end
	stopThread("visualStatPresentation")
	for label, original in pairs(visualOriginalLabels) do
		if label and label.Parent then
			label.Text = original.text or ""
			local shadow = label:FindFirstChild("shadow")
			if shadow and (shadow:IsA("TextLabel") or shadow:IsA("TextButton")) then
				shadow.Text = original.shadowText or original.text or ""
			end
		end
		visualOriginalLabels[label] = nil
	end
	for _, input in pairs(visualStatInputs) do
		if input and input.Parent then
			input.Text = ""
			input.PlaceholderText = "Ejemplo: 1.000"
		end
	end
end


local function clearVisualStat(key)
	local record = visualStats[key]
	if record then
		if record.connection then pcall(record.connection.Disconnect, record.connection) end
		if record.object then State.visualStatRecords[record.object] = nil end
		if record.object and record.object.Parent and record.realValue ~= nil then
			applyingVisualStat = true
			pcall(function() record.object.Value = record.realValue end)
			applyingVisualStat = false
		end
		visualStats[key] = nil
	end
	for label, original in pairs(visualOriginalLabels) do
		if original.key == key then
			if label and label.Parent then
				label.Text = original.text or ""
				local shadow = label:FindFirstChild("shadow")
				if shadow and (shadow:IsA("TextLabel") or shadow:IsA("TextButton")) then
					shadow.Text = original.shadowText or original.text or ""
				end
			end
			visualOriginalLabels[label] = nil
		end
	end
	if not next(visualStats) then stopThread("visualStatPresentation") end
	return true
end


local function parseVisualAmount(rawValue)
	local raw = tostring(rawValue or ""):upper():gsub("%s+", "")
	if raw == "" then return nil, true end
	local numberText, suffix = raw:match("^([%d%.,]+)(%a*)$")
	if not numberText then return nil, false end
	local multipliers = {
		K = 1e3, M = 1e6, B = 1e9, T = 1e12, QA = 1e15, QI = 1e18,
		SX = 1e21, SP = 1e24, OC = 1e27, NO = 1e30, DC = 1e33,
	}
	local multiplier = suffix == "" and 1 or multipliers[suffix]
	if not multiplier then return nil, false end
	if suffix == "" then
		numberText = numberText:gsub("%.", ""):gsub(",", ".")
	else
		numberText = numberText:gsub(",", ".")
		if select(2, numberText:gsub("%.", "")) > 1 then
			local decimal = numberText:match("%.(%d+)$")
			numberText = numberText:gsub("%.", "")
			if decimal then numberText = numberText:sub(1, #numberText - #decimal) .. "." .. decimal end
		end
	end
	local parsed = tonumber(numberText)
	if not parsed then return nil, false end
	return parsed * multiplier, false
end


local function applyVisualStat(definition, rawValue)
	local raw = tostring(rawValue or "")
	local value, empty = parseVisualAmount(raw)
	if empty then return clearVisualStat(definition.key) end
	if not value then
		hubNotify("Usá un número o una cantidad como 250K, 10M, 2B, 1T o 5QA")
		return false
	end
	value = math.max(0, math.floor(value + 0.5))
	local object = getPlayerStat(LP, definition.names)
	if not object then
		hubNotify(definition.key .. " no está disponible en el leaderboard")
		return false
	end
	local record = visualStats[definition.key]
	if not record or record.object ~= object then
		if record and record.connection then pcall(record.connection.Disconnect, record.connection) end
		if record and record.object then State.visualStatRecords[record.object] = nil end
		record = { object = object, realValue = object.Value, value = value, key = definition.key }
		visualStats[definition.key] = record
		State.visualStatRecords[object] = record
		record.connection = object:GetPropertyChangedSignal("Value"):Connect(function()
			if applyingVisualStat or not State.running or visualStats[definition.key] ~= record then return end
			if object.Value ~= record.value then
				record.realValue = object.Value
				applyingVisualStat = true
				pcall(function() object.Value = record.value end)
				applyingVisualStat = false
			end
		end)
	else
		record.value = value
	end
	captureOfficialVisualLabels(definition.key)
	applyingVisualStat = true
	local ok = pcall(function() object.Value = value end)
	applyingVisualStat = false
	if ok then
		ensureVisualPresentationLoop()
		applyOfficialVisualLabels()
	end
	return ok
end

for _, definition in ipairs(visualStatDefinitions) do
	local visualDefinition = definition
	local input = __FGRoot.CrefyUI.uiAddInput(mainPage, visualDefinition.label, "Ejemplo: 1.000", function(value)
		applyVisualStat(visualDefinition, value)
	end, true)
	visualStatInputs[visualDefinition.key] = input
end

State.applyVisualStat = function(key, value)
	for _, definition in ipairs(visualStatDefinitions) do
		if definition.key == key then return applyVisualStat(definition, value) end
	end
	return false
end
State.restoreVisualStats = restoreVisualStats
addCleanup(function() restoreVisualStats(true) end)

__FGRoot.CrefyUI.uiAddSection(mainPage, "Códigos")
local codeSessionProcessed = {}
local officialCodeFallback = {
	"bossstrike", "bossguard",
	"MLREVIVED", "Industrialgym500",
	"junglegym500", "epicmuscle20", "ultimate250", "mightygems2500",
	"MillionWarriors", "superpunch100", "megalift50", "epicreward500",
	"spacegems50", "speedy50", "Skyagility50", "Musclestorm50",
	"launch250", "galaxycrystal50", "supermuscle100", "frostgems10",
}
local codeStateFolder = "Young0xHub/FG100/state"
local codeStateKey = "v1660b:" .. tostring(LP.UserId)
local codeStatePath = codeStateFolder .. "/codes_v1660b_" .. tostring(LP.UserId) .. ".done"
local legacyCodeStatePath = codeStateFolder .. "/codes_" .. tostring(LP.UserId) .. ".done"


local function codesMarkedDone()
	if type(Env.FGCodeDone) == "table" and Env.FGCodeDone[codeStateKey] then
		return true
	end
	if type(isfile) == "function" then
		local ok, exists = pcall(isfile, codeStatePath)
		if ok and exists then return true end
	end
	return false
end

local function legacyCodesMarkedDone()
	if type(Env.FGCodeDone) == "table" and Env.FGCodeDone[LP.UserId] then return true end
	if type(isfile) == "function" then
		local ok, exists = pcall(isfile, legacyCodeStatePath)
		if ok and exists then return true end
	end
	return false
end

local function markCodesDone()
	Env.FGCodeDone = type(Env.FGCodeDone) == "table" and Env.FGCodeDone or {}
	Env.FGCodeDone[codeStateKey] = true
	if type(writefile) ~= "function" then return end
	pcall(function()
		if type(isfolder) == "function" and type(makefolder) == "function" then
			if not isfolder("Young0xHub") then makefolder("Young0xHub") end
			if not isfolder("Young0xHub/FG100") then makefolder("Young0xHub/FG100") end
			if not isfolder(codeStateFolder) then makefolder(codeStateFolder) end
		end
		writefile(codeStatePath, tostring(os.time()))
	end)
end
State.codesMarkedDone = codesMarkedDone
State.markCodesDone = markCodesDone


local function currentOfficialCodes()
	local codes = {}
	local seen = {}
	local marketplace = game:GetService("MarketplaceService")
	local ok, info = pcall(marketplace.GetProductInfo, marketplace, game.PlaceId, Enum.InfoType.Asset)
	local description = ok and type(info) == "table" and tostring(info.Description or "") or ""
	local segment = description:match("[Cc][Oo][Dd][Ee][Ss]%s*:%s*([^\n\r✨]+)")
	if segment then
		for code in segment:gmatch("[%w_%-]+") do
			local lower = string.lower(code)
			if #lower >= 4 and string.find(lower, "%d") and not seen[lower] then
				seen[lower] = true
				codes[#codes + 1] = lower
			end
		end
	end
	for _, code in ipairs(officialCodeFallback) do
		local lower = string.lower(code)
		if not seen[lower] then
			seen[lower] = true
			codes[#codes + 1] = code
		end
	end
	return codes
end
State.currentOfficialCodes = currentOfficialCodes


local function redeemedCodeSet()
	local used = {}
	pcall(function()
		local dataFolder = ReplicatedStorage:FindFirstChild("playerData")
		local module = dataFolder and dataFolder:FindFirstChild(tostring(LP.UserId))
		local data = module and module:IsA("ModuleScript") and require(module)
		for key, value in pairs(data and data.Data and data.Data.usedCodes or {}) do
			local code = type(key) == "string" and key or value
			if code ~= nil then used[string.lower(tostring(code))] = true end
		end
	end)
	return used
end

local function pendingOfficialCodes()
	local redeemed = redeemedCodeSet()
	local legacyDone = legacyCodesMarkedDone()
	local pendingCodes = {}
	for _, code in ipairs(currentOfficialCodes()) do
		local lower = string.lower(code)
		local newlyAdded = lower == "bossstrike" or lower == "bossguard"
		if not redeemed[lower] and not codeSessionProcessed[lower] and (not legacyDone or newlyAdded) then
			pendingCodes[#pendingCodes + 1] = code
		end
	end
	return pendingCodes
end

local redeemAllButton

State.redeemProgressText = function(index, total)
	return string.format("Canjeando %d/%d", math.max(0, tonumber(index) or 0), math.max(0, tonumber(total) or 0))
end
redeemAllButton = __FGRoot.CrefyUI.uiAddButton(mainPage, "Canjear todos los códigos", function(button)
	if State.redeemingAllCodes then return end
	if codesMarkedDone() then
		State.setButtonDisabled(button, true)
		return
	end
	local events = ReplicatedStorage:FindFirstChild("rEvents")
	local remote = events and events:FindFirstChild("codeRemote")
	if not remote or not remote:IsA("RemoteFunction") then
		hubNotify("El canje de códigos no está disponible")
		return
	end
	State.redeemingAllCodes = true
	State.setButtonDisabled(button, true)
	startThread("redeemAllCodes", function()
		local codes = pendingOfficialCodes()
		local technicalError = false
		for index, code in ipairs(codes) do
			if not State.running then break end
			button.Text = State.redeemProgressText(index, #codes)
			local lower = string.lower(code)
			if not codeSessionProcessed[lower] then
				local callOk, success, response = pcall(remote.InvokeServer, remote, code)
				local responseText = string.lower(tostring(response or ""))
				if callOk and success == true then
					codeSessionProcessed[lower] = "accepted"
				elseif string.find(responseText, "already", 1, true)
					or string.find(responseText, "used", 1, true)
					or string.find(responseText, "redeem", 1, true)
					or string.find(responseText, "usado", 1, true) then
					codeSessionProcessed[lower] = "used"
				else
					codeSessionProcessed[lower] = "invalid"
					technicalError = technicalError or not callOk
				end
			end
			task.wait(0.65)
		end
		State.redeemingAllCodes = false
		button.Text = "Canjear todos los códigos"
		if technicalError then
			hubNotify("No se pudieron canjear algunos códigos.")
			State.setButtonDisabled(button, false)
		else
			markCodesDone()
			State.setButtonDisabled(button, true)
		end
	end)
end)

do
	local redeemed = redeemedCodeSet()
	local complete = codesMarkedDone()
	if not complete then
		complete = true
		for _, code in ipairs(pendingOfficialCodes()) do
			if not redeemed[string.lower(code)] then complete = false; break end
		end
	end
	if complete then
		markCodesDone()
		State.setButtonDisabled(redeemAllButton, true)
	end
end

addCleanup(function()
	State.mainAutoSize = false
	State.mainAutoSpeed = false
	State.infiniteJump = false
	mainSizeInvokeSerial = mainSizeInvokeSerial + 1
	mainSizeInvokeBusy = false
	stopThread("mainAutoSize")
	stopThread("mainAutoSpeed")
	stopThread("redeemAllCodes")
	State.redeemingAllCodes = false
	unbindMainSpeed()
	restoreVisualStats(true)
end)
end)()

do
local fastPage = Pages["Fast Glitch 100%"]
__FGRoot.CrefyUI.uiAddSection(fastPage, "Fast Glitch 100%")
local rockToggles = {}
local rockSync = false
FastFarm.RockToggles = {}
FastFarm.RockDefinitions = {}
local fastPunchToggle
fastPunchToggle = __FGRoot.CrefyUI.uiAddToggle(fastPage, "Fast Punch ", function(enabled)
	local momentum = FastFarm.PetMomentum
    if momentum and momentum.mode == "running" and not momentum.syncingDurability then
        if enabled then
            momentum.linkedPunchSuppressed = false
            if not State.selectedRock then momentum.linkedRockAuto = true end
        else
            momentum.linkedPunchSuppressed = true
            momentum.linkedPunchOwned = false
        end
    end
	setFastPunch(enabled)
	rockSync = true
	for _, toggle in ipairs(rockToggles) do
		if not enabled then
			toggle:Set(false, true)
		end
		toggle:SetLocked(not enabled)
	end
	rockSync = false
    if enabled and momentum and momentum.mode == "running" and not momentum.syncingDurability then
        task.defer(function() momentum:EnableLinkedDurability(true) end)
    end
end)
FastFarm.FastPunchToggle = fastPunchToggle
__FGRoot.CrefyUI.uiAddToggle(fastPage, "Ocultar Durabilidad", function(enabled)
	setHideDurability(enabled)
end)

local petsBugMemorial = Instance.new("Frame")
petsBugMemorial.LayoutOrder = nextOrder(fastPage)
petsBugMemorial.Parent = fastPage
__FGRoot.CrefyUI.styleRow(petsBugMemorial, 48)
local memorialAccent = Instance.new("Frame")
memorialAccent.Size = UDim2.fromOffset(3, 28)
memorialAccent.Position = UDim2.new(0, 8, 0.5, -14)
memorialAccent.BackgroundColor3 = C.blue
memorialAccent.BackgroundTransparency = 0.02
memorialAccent.BorderSizePixel = 0
memorialAccent.ZIndex = 12
memorialAccent.Parent = petsBugMemorial
Instance.new("UICorner", memorialAccent).CornerRadius = UDim.new(1, 0)
local memorialText = Instance.new("TextLabel")
memorialText.Size = UDim2.new(1, -32, 1, -8)
memorialText.Position = UDim2.fromOffset(21, 4)
memorialText.BackgroundTransparency = 1
memorialText.Text = "Fue lindo mientras duró, Rip pets bug 2019 - 2026 🥀."
memorialText.TextColor3 = Color3.fromRGB(225, 215, 220)
memorialText.Font = C.fontBold
memorialText.TextSize = 12
memorialText.TextWrapped = true
memorialText.TextXAlignment = Enum.TextXAlignment.Left
memorialText.TextYAlignment = Enum.TextYAlignment.Center
memorialText.ZIndex = 12
	memorialText:SetAttribute("KeepTextStyle", true)
memorialText.Parent = petsBugMemorial

__FGRoot.CrefyUI.uiAddSection(fastPage, "Rocks")
for _, definition in ipairs(CONFIG.Rocks) do
	local rockDefinition = definition
	local toggle
	toggle = __FGRoot.CrefyUI.uiAddToggle(fastPage, rockDefinition.label or rockDefinition.name, function(enabled)
		if rockSync then
			return
		end
		if enabled and not State.fastPunch then
			return false
		end
		if enabled then
            local momentum = FastFarm.PetMomentum
            if momentum and momentum.mode == "running" and not momentum.syncingDurability then
                momentum.linkedRockAuto = false
            end
			clearRockSelection()
			rockSync = true
			for _, other in ipairs(rockToggles) do
				if other ~= toggle then
					other:Set(false, true)
				end
			end
			rockSync = false
			startRockFarm(rockDefinition, true)
		elseif State.selectedRock == rockDefinition then
			clearRockSelection()
		end
		return nil
	end)
	toggle:SetLocked(true)
	rockToggles[#rockToggles + 1] = toggle
    FastFarm.RockToggles[rockDefinition.name] = toggle
    FastFarm.RockDefinitions[rockDefinition.name] = rockDefinition
end

local PetMomentum = FastFarm.PetMomentum
function PetMomentum:GetBestRockDefinition()
    local durability = LP:FindFirstChild("Durability")
    local value = durability and tonumber(State.getFunctionalStatValue(durability)) or 0
    for _, definition in ipairs(CONFIG.Rocks) do
        if value >= definition.durability and findRock(definition) then return definition end
    end
    return nil
end
function PetMomentum:EnableLinkedDurability(forceBest)
    if self.mode ~= "running" or self.linkedPunchSuppressed then return false end
    local wasEnabled = State.fastPunch == true
    self.syncingDurability = true
    if FastFarm.FastPunchToggle and not FastFarm.FastPunchToggle:Get() then
        FastFarm.FastPunchToggle:Set(true)
    elseif not State.fastPunch then
        setFastPunch(true)
    end
    if not wasEnabled and State.fastPunch then self.linkedPunchOwned = true end
    local definition = forceBest and self:GetBestRockDefinition() or State.selectedRock or self:GetBestRockDefinition()
    if definition and State.selectedRock ~= definition then
        local toggle = FastFarm.RockToggles[definition.name]
        if toggle then toggle:Set(true) else startRockFarm(definition) end
    end
    self.syncingDurability = false
    self.linkedRock = State.selectedRock
    return State.fastPunch and State.selectedRock ~= nil
end
function PetMomentum:DisableLinkedDurability()
    self.syncingDurability = true
    if self.linkedPunchOwned and State.fastPunch then
        if FastFarm.FastPunchToggle then FastFarm.FastPunchToggle:Set(false) else setFastPunch(false) end
    end
    self.syncingDurability = false
    self.linkedPunchOwned = false
    self.linkedRock = nil
end

end

do
do
    local CollectionService = game:GetService("CollectionService")
    local BossFarm = {
        active = false,
        generation = 0,
        status = "Sin boss activo",
        originalCharacter = nil,
        originalPivot = nil,
        originalSize = nil,
        resumeFastMode = nil,
        engagedBoss = nil,
        confirmedDamage = 0,
        attacks = 0,
        hitInterval = 0.31,
        antiLag = false,
        antiLagOriginals = setmetatable({}, { __mode = "k" }),
        antiLagConnection = nil,
        cameraShakeHooks = nil,
        cameraSaved = nil,
        cameraFocusPosition = nil,
        cameraStableCFrame = nil,
        cameraRenderName = "Young0xBossStableCamera",
        originalRootAnchored = nil,
        safeAttackPosition = nil,
        durabilityManaged = false,
        resumeFastPunch = nil,
        resumeRock = nil,
        lastPlayerHealth = nil,
        safetyTriggered = false,
    }
    State.bossFarm = BossFarm

    local function findBoss()
        for _, boss in ipairs(CollectionService:GetTagged("BossEventBoss")) do
            if boss and boss.Parent then
                local part = boss:FindFirstChild("BossDamageHitbox", true)
                    or boss.PrimaryPart
                    or boss:FindFirstChild("Boss", true)
                    or boss:FindFirstChild("Head", true)
                    or boss:FindFirstChildWhichIsA("BasePart", true)
                if part and part:IsA("BasePart") then
                    local target = boss:FindFirstChild("Boss")
                        or boss:FindFirstChild("Head", true)
                        or boss.PrimaryPart
                        or part
                    if not target:IsA("BasePart") then target = part end
                    return boss, part, target
                end
            end
        end
        return nil, nil, nil
    end

    local function bossHealth()
        return math.max(0, tonumber(workspace:GetAttribute("BossHealth")) or 0)
    end

    function BossFarm:ApplyAntiLagObject(object)
        if not self.antiLag or not object then return end
        local property
        if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam")
            or object:IsA("Fire") or object:IsA("Smoke") or object:IsA("Sparkles")
            or object:IsA("PointLight") or object:IsA("SpotLight") or object:IsA("SurfaceLight")
            or object:IsA("Highlight") then
            property = "Enabled"
        elseif object:IsA("BasePart") then
            property = "CastShadow"
        end
        if property and self.antiLagOriginals[object] == nil then
            self.antiLagOriginals[object] = { property = property, value = object[property] }
            pcall(function() object[property] = false end)
        end
    end

    function BossFarm:SetAntiLag(enabled)
        enabled = enabled == true
        self.antiLag = enabled
        if self.antiLagConnection then
            self.antiLagConnection:Disconnect()
            self.antiLagConnection = nil
        end
        if not enabled then
            for object, saved in pairs(self.antiLagOriginals) do
                if object and object.Parent then pcall(function() object[saved.property] = saved.value end) end
                self.antiLagOriginals[object] = nil
            end
            return true
        end
        local events = workspace:FindFirstChild("Events")
        local arena = events and events:FindFirstChild("BossArena")
        if not arena then self.antiLag = false; return false end
        for _, object in ipairs(arena:GetDescendants()) do self:ApplyAntiLagObject(object) end
        self.antiLagConnection = arena.DescendantAdded:Connect(function(object)
            task.defer(function() self:ApplyAntiLagObject(object) end)
        end)
        return true
    end

    local function setCharacterSize(size)
        local events = ReplicatedStorage:FindFirstChild("rEvents")
        local remote = events and events:FindFirstChild("changeSpeedSizeRemote")
        size = math.clamp(math.floor((tonumber(size) or 2) + 0.5), 1, 100)
        if not remote then return false end
        if remote:IsA("RemoteEvent") then
            return pcall(remote.FireServer, remote, "changeSize", size)
        elseif remote:IsA("RemoteFunction") then
            return pcall(remote.InvokeServer, remote, "changeSize", size)
        end
        return false
    end

    local function readCharacterSize()
        local humanoid = getHumanoid()
        local height = humanoid and humanoid:FindFirstChild("BodyHeightScale")
        return math.clamp(math.floor(((height and height.Value) or State.mainSize or 2) + 0.5), 1, 100)
    end

    local function equipBossPunch()
        local character = getCharacter()
        local humanoid = getHumanoid()
        local backpack = LP:FindFirstChild("Backpack")
        local punch = character and character:FindFirstChild("Punch")
            or (backpack and backpack:FindFirstChild("Punch"))
        if punch and humanoid and punch.Parent ~= character then
            pcall(humanoid.EquipTool, humanoid, punch)
            RunService.Heartbeat:Wait()
        end
        local attackTime = punch and punch:FindFirstChild("attackTime")
        if attackTime and attackTime:IsA("ValueBase") then attackTime.Value = 0 end
        return punch
    end

    function BossFarm:UpdateUi()
        if self.StatusValue then
            self.StatusValue.Text = self.status
            self.StatusValue.TextColor3 = self.engagedBoss and C.green or C.dim
        end
        if self.HealthValue then
            local health = bossHealth()
            local maximum = math.max(health, tonumber(workspace:GetAttribute("BossMaxHealth")) or 0)
            if maximum > 0 and workspace:GetAttribute("BossActive") == true then
                self.HealthValue.Text = formatExact(health) .. " / " .. formatExact(maximum)
            else
                self.HealthValue.Text = "—"
            end
        end
    end

    function BossFarm:PauseFastFarm()
        if self.resumeFastMode == nil and (FastFarm.mode == "rebirth" or FastFarm.mode == "strength") then
            self.resumeFastMode = FastFarm.mode
        end
        if FastFarm.mode then Controller.SetFastFarm(nil) end
    end

    function BossFarm:ResumeFastFarm()
        local mode = self.resumeFastMode
        self.resumeFastMode = nil
        if mode and not self.engagedBoss then
            task.defer(function()
                if State.running and not self.engagedBoss and FastFarm.mode == nil then Controller.SetFastFarm(mode) end
            end)
        end
    end

    function BossFarm:GetBestRockDefinition()
        local durability = LP:FindFirstChild("Durability")
        local amount = durability and tonumber(State.getFunctionalStatValue(durability)) or 0
        for _, definition in ipairs(CONFIG.Rocks) do
            if amount >= definition.durability and findRock(definition) then return definition end
        end
        return nil
    end

    function BossFarm:EnableLinkedDurability()
        if not self.durabilityManaged then
            self.durabilityManaged = true
            self.resumeFastPunch = State.fastPunch == true
            self.resumeRock = State.selectedRock
        end
        if FastFarm.FastPunchToggle and not FastFarm.FastPunchToggle:Get() then
            FastFarm.FastPunchToggle:Set(true)
        elseif not State.fastPunch then
            setFastPunch(true)
        end
        local definition = State.selectedRock or self:GetBestRockDefinition()
        if definition and State.selectedRock ~= definition then
            local toggle = FastFarm.RockToggles and FastFarm.RockToggles[definition.name]
            if toggle then toggle:Set(true) else startRockFarm(definition) end
        end
        return State.fastPunch == true and State.selectedRock ~= nil
    end

    function BossFarm:RestoreLinkedDurability()
        if not self.durabilityManaged then return end
        local resumeFastPunch, resumeRock = self.resumeFastPunch, self.resumeRock
        self.durabilityManaged = false
        self.resumeFastPunch = nil
        self.resumeRock = nil
        if not resumeFastPunch then
            if FastFarm.FastPunchToggle and FastFarm.FastPunchToggle:Get() then
                FastFarm.FastPunchToggle:Set(false)
            elseif State.fastPunch then
                setFastPunch(false)
            end
        elseif resumeRock and State.selectedRock ~= resumeRock then
            local toggle = FastFarm.RockToggles and FastFarm.RockToggles[resumeRock.name]
            if toggle then toggle:Set(true) else startRockFarm(resumeRock) end
        end
    end

    function BossFarm:StopStableCamera()
        pcall(RunService.UnbindFromRenderStep, RunService, self.cameraRenderName)
        local camera = workspace.CurrentCamera
        local saved = self.cameraSaved
        if camera and saved then
            pcall(function()
                camera.CameraType = Enum.CameraType.Scriptable
                camera.CFrame = saved.cframe
                camera.Focus = saved.focus
                if saved.subject and saved.subject.Parent then camera.CameraSubject = saved.subject end
                camera.CameraType = saved.cameraType
            end)
        end
        self.cameraSaved = nil
        self.cameraFocusPosition = nil
        self.cameraStableCFrame = nil
        local hooks = self.cameraShakeHooks
        self.cameraShakeHooks = nil
        if type(hooks) ~= "table" then return end
        for index = #hooks, 1, -1 do
            local hook = hooks[index]
            local restored = false
            if type(restorefunction) == "function" then
                restored = pcall(restorefunction, hook.original, hook.target)
                if not restored then restored = pcall(restorefunction, hook.target) end
            end
            if not restored and type(hookfunction) == "function" then
                pcall(hookfunction, hook.target, hook.original)
            end
        end
    end

    function BossFarm:StartStableCamera()
        self:StopStableCamera()
        local camera = workspace.CurrentCamera
        if camera then
            self.cameraSaved = {
                cameraType = camera.CameraType,
                subject = camera.CameraSubject,
                cframe = camera.CFrame,
                focus = camera.Focus,
            }
            camera.CameraType = Enum.CameraType.Scriptable
            RunService:BindToRenderStep(self.cameraRenderName, Enum.RenderPriority.Camera.Value + 50, function(delta)
                local focus = self.cameraFocusPosition
                local currentCamera = workspace.CurrentCamera
                if not self.engagedBoss or not focus or not currentCamera then return end
                local desired = CFrame.lookAt(focus + Vector3.new(0, 34, 48), focus + Vector3.new(0, -5, 0))
                self.cameraStableCFrame = self.cameraStableCFrame
                    and self.cameraStableCFrame:Lerp(desired, math.clamp(delta * 4, 0.04, 0.22)) or desired
                currentCamera.CameraType = Enum.CameraType.Scriptable
                currentCamera.CFrame = self.cameraStableCFrame
                currentCamera.Focus = CFrame.new(focus)
            end)
        end
        local client = ReplicatedStorage:FindFirstChild("client")
        local utils = client and client:FindFirstChild("utils")
        local scriptObject = utils and utils:FindFirstChild("CameraShake")
        if not scriptObject or not scriptObject:IsA("ModuleScript") or type(hookfunction) ~= "function" then return end
        local ok, module = pcall(require, scriptObject)
        if not ok or type(module) ~= "table" then return end
        local hooks = {}
        for _, name in ipairs({ "Play", "PlayInArena", "PlayAt" }) do
            local target = module[name]
            if type(target) == "function" then
                local original
                local hooked, result = pcall(function()
                    original = hookfunction(target, function() return nil end)
                    return original
                end)
                if hooked and type(result) == "function" then
                    hooks[#hooks + 1] = { target = target, original = result }
                end
            end
        end
        if #hooks > 0 then self.cameraShakeHooks = hooks end
    end

    function BossFarm:WaitForReadyCharacter(timeout)
        local deadline = os.clock() + (tonumber(timeout) or 8)
        local stableCharacter, stableRoot, stableAt
        while State.running and self.active and os.clock() < deadline do
            local character = getCharacter()
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
            local machine = LP:FindFirstChild("machineInUse")
            local rebirthing = character and (character:GetAttribute("IsRebirthing") == true
                or character:GetAttribute("LastMapCFrame") ~= nil)
            local mounted = (machine and machine.Value ~= nil) or (humanoid and humanoid.SeatPart ~= nil)
            if character and root and humanoid and humanoid.Health > 0 and not rebirthing and not mounted then
                if character ~= stableCharacter or root ~= stableRoot then
                    stableCharacter, stableRoot, stableAt = character, root, os.clock()
                elseif os.clock() - stableAt >= 0.18 then
                    return character, root, humanoid
                end
            else
                stableCharacter, stableRoot, stableAt = nil, nil, nil
            end
            task.wait(0.05)
        end
        return nil, nil, nil
    end

    function BossFarm:BeginBattle(boss)
        if self.engagedBoss == boss then return true end
        self:PauseFastFarm()
        if FastFarm.PetMomentum and FastFarm.PetMomentum.mode then
            FastFarm.PetMomentum:Stop(true)
        end
        if State.afkMainToggle and State.afkMainToggle:Get() then State.afkMainToggle:Set(false) end
        for _, toggle in ipairs({ State.killAutoToggle, State.killEvilToggle, State.killGoodToggle, State.killTargetToggle }) do
            if toggle and toggle.Get and toggle:Get() then toggle:Set(false) end
        end
        local character, root = self:WaitForReadyCharacter(8)
        if not character or not root or boss.Parent == nil or workspace:GetAttribute("BossActive") ~= true then
            self:RestoreBattle()
            return false
        end
        self.originalCharacter = character
        self.originalPivot = character:GetPivot()
        self.originalSize = readCharacterSize()
        self.originalRootAnchored = root.Anchored
        self.engagedBoss = boss
        self.confirmedDamage = 0
        self.attacks = 0
        self.safetyTriggered = false
        self.lastPlayerHealth = nil
        self.safeAttackPosition = nil
        self:StartStableCamera()
        setCharacterSize(5)
        task.wait(0.55)
        local humanoid = getHumanoid()
        self.lastPlayerHealth = humanoid and humanoid.Health or nil
        self:EnableLinkedDurability()
        return true
    end

    function BossFarm:RestoreBattle()
        local character = LP.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if character and character == self.originalCharacter and root and self.originalPivot then
            character:PivotTo(self.originalPivot)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            if self.originalRootAnchored ~= nil then root.Anchored = self.originalRootAnchored end
        end
        if self.originalSize then setCharacterSize(self.originalSize) end
        self:StopStableCamera()
        local backpack = LP:FindFirstChild("Backpack")
        local punch = character and character:FindFirstChild("Punch")
        if punch and backpack then punch.Parent = backpack end
        self.originalCharacter = nil
        self.originalPivot = nil
        self.originalSize = nil
        self.originalRootAnchored = nil
        self.engagedBoss = nil
        self.lastPlayerHealth = nil
        self.safeAttackPosition = nil
        self:RestoreLinkedDurability()
        self:ResumeFastFarm()
    end

    function BossFarm:CollectChest(timeout)
        if type(fireproximityprompt) ~= "function" then return false end
        local opened = false
        local openedConnection
        local remoteFolder = ReplicatedStorage:FindFirstChild("rEvents")
        local openedEvent = remoteFolder and remoteFolder:FindFirstChild("bossChestOpenedEvent")
        if openedEvent and openedEvent:IsA("RemoteEvent") then
            openedConnection = openedEvent.OnClientEvent:Connect(function() opened = true end)
        end
        local function finish(success)
            if openedConnection then openedConnection:Disconnect() end
            return success
        end
        local deadline = os.clock() + (tonumber(timeout) or 15)
        local pendingWasSeen, attempted, lastAttempt = false, false, 0
        while State.running and self.active and os.clock() < deadline do
            if opened then
                State.pushOutput("BOSS", "Cofre del boss reclamado")
                return finish(true)
            end
            local chestModel
            local prompt
            for _, candidate in ipairs(CollectionService:GetTagged("BossEventChest")) do
                prompt = candidate:FindFirstChild("bossChestPrompt", true)
                if prompt then chestModel = candidate break end
            end
            if not prompt then
                local events = workspace:FindFirstChild("Events")
                prompt = events and events:FindFirstChild("bossChestPrompt", true)
                chestModel = prompt and prompt:FindFirstAncestorOfClass("Model") or nil
            end
            local eligible = LP:GetAttribute("BossChestEligible") == true
            local pending = LP:GetAttribute("BossChestPending") == true
            if pending then
                pendingWasSeen = true
            elseif attempted and pendingWasSeen then
                State.pushOutput("BOSS", "Cofre del boss reclamado")
                return finish(true)
            end
            local emerging = chestModel and chestModel:GetAttribute("BossChestEmerging") == true
            if prompt and prompt:IsA("ProximityPrompt") and eligible and pending and not emerging then
                local character = getCharacter()
                local root = getRoot()
                local parent = prompt.Parent
                if character and root and parent and parent:IsA("BasePart") then
                    character:PivotTo(parent.CFrame * CFrame.new(0, math.max(4, parent.Size.Y * 0.5 + 3), 0))
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    task.wait(0.12)
                end
                if prompt.Enabled and os.clock() - lastAttempt >= 0.45 then
                    lastAttempt = os.clock()
                    attempted = pcall(fireproximityprompt, prompt) or attempted
                end
            end
            task.wait(0.1)
        end
        return finish(opened or (attempted and pendingWasSeen and LP:GetAttribute("BossChestPending") ~= true))
    end

    function BossFarm:Fight(boss)
        if not self:BeginBattle(boss) then return end
        local lastHealth = bossHealth()
        local lastAttack = 0
        while State.running and self.active and boss.Parent and workspace:GetAttribute("BossActive") == true do
            local currentBoss, part, target = findBoss()
            if currentBoss ~= boss or not part or not target then break end
            local character = getCharacter()
            local root = getRoot()
            local humanoid = getHumanoid()
            local punch = equipBossPunch()
            if not character or not root or not humanoid or humanoid.Health <= 0 or not punch then
                self.status = "Esperando personaje"
                self:UpdateUi()
                task.wait(0.25)
            else
                if self.lastPlayerHealth and humanoid.Health < self.lastPlayerHealth then
                    self.safetyTriggered = true
                    self.active = false
                    self.status = "Protección activada"
                    self:SetAntiLag(false)
                    if self.Toggle then self.Toggle:Set(false, true) end
                    self:UpdateUi()
                    break
                end
                self.lastPlayerHealth = humanoid.Health
                self:EnableLinkedDurability()
                local bossTop = target.Position.Y + target.Size.Y * 0.5
                local clearance = math.max(6, root.Size.Y * 0.5 + 4)
                local desiredPosition = Vector3.new(part.Position.X, bossTop + clearance, part.Position.Z)
                if not self.safeAttackPosition or (desiredPosition - self.safeAttackPosition).Magnitude > 45 then
                    self.safeAttackPosition = desiredPosition
                else
                    self.safeAttackPosition = self.safeAttackPosition:Lerp(desiredPosition, 0.16)
                end
                local attackPosition = self.safeAttackPosition
                local aimPosition = target.Position + Vector3.new(0, target.Size.Y * 0.32, 0)
                self.cameraFocusPosition = self.cameraFocusPosition
                    and self.cameraFocusPosition:Lerp(aimPosition, 0.08) or aimPosition
                character:PivotTo(CFrame.lookAt(attackPosition, aimPosition))
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                local now = os.clock()
                if now - lastAttack >= self.hitInterval then
                    lastAttack = now
                    pcall(punch.Deactivate, punch)
                    pcall(punch.Activate, punch)
                    self.attacks = self.attacks + 1
                end
                local health = bossHealth()
                if health < lastHealth then self.confirmedDamage = self.confirmedDamage + lastHealth - health end
                lastHealth = health
                self.status = tostring(workspace:GetAttribute("BossDisplayName") or "Boss")
                    .. " · daño " .. formatExact(self.confirmedDamage)
                self:UpdateUi()
                task.wait(0.04)
            end
        end
        local defeated = workspace:GetAttribute("BossActive") ~= true or bossHealth() <= 0
        if defeated and self.active then
            self.status = "Boss derrotado · reclamando recompensa"
            self:UpdateUi()
            self:CollectChest(12)
        end
        self:RestoreBattle()
    end

    function BossFarm:Set(enabled)
        enabled = enabled == true
        self.generation = self.generation + 1
        local generation = self.generation
        self.active = enabled
        stopThread("autoBossFarm")
        if not enabled then
            self.status = "Sin boss activo"
            self:RestoreBattle()
            self:SetAntiLag(false)
            self:UpdateUi()
            return true
        end
        local config = ReplicatedStorage:FindFirstChild("shared")
        config = config and config:FindFirstChild("config")
        config = config and config:FindFirstChild("BossEventConfig")
        local ok, values = pcall(function() return config and require(config) end)
        if not ok or type(values) ~= "table" or values.ENABLED ~= true then
            self.active = false
            self.status = "El evento del boss no está disponible"
            self:SetAntiLag(false)
            self:UpdateUi()
            return false
        end
        self:SetAntiLag(true)
        self.hitInterval = math.max(0.31, (tonumber(values.MIN_HIT_INTERVAL) or 0.3) + 0.01)
        startThread("autoBossFarm", function()
            while State.running and self.active and self.generation == generation do
                local boss = findBoss()
                if boss and workspace:GetAttribute("BossActive") == true then
                    self:Fight(boss)
                else
                    self.engagedBoss = nil
                    self.status = "Sin boss activo"
                    self:UpdateUi()
                    task.wait(0.4)
                end
            end
            if self.generation == generation then self:RestoreBattle() end
        end)
        self:UpdateUi()
        return true
    end

    local page = Pages.Boss
    __FGRoot.CrefyUI.uiAddSection(page, "Boss")
    BossFarm.StatusValue = __FGRoot.CrefyUI.uiAddInfoRow(page, "Estado:", "Sin boss activo", C.dim)
    BossFarm.HealthValue = __FGRoot.CrefyUI.uiAddInfoRow(page, "Vida del boss:", "—", C.cyan)
    BossFarm.Toggle = __FGRoot.CrefyUI.uiAddToggle(page, "Atacar al boss", function(enabled)
        local accepted = BossFarm:Set(enabled)
        if accepted == false and BossFarm.Toggle then BossFarm.Toggle:Set(false, true) end
        return accepted
    end)
    State.autoBossToggle = BossFarm.Toggle
    State.bossAntiLagToggle = nil
    BossFarm:UpdateUi()

    addCleanup(function()
        BossFarm.active = false
        BossFarm.generation = BossFarm.generation + 1
        stopThread("autoBossFarm")
        BossFarm:RestoreBattle()
        BossFarm:SetAntiLag(false)
    end)
end

local autoFarmPage = Pages["Auto Farm"]
__FGRoot.CrefyUI.uiAddSection(autoFarmPage, "Auto Farm")
FastFarm.AutoFarmModeSelector = __FGRoot.CrefyUI.uiAddSelector(autoFarmPage, "Modo", { "Chill Rep", "Fast Rep", "Super Fast Rep" }, function(value)
	if value == "Super Fast Rep" then
		State.autoFarmMode = "Super Fast Rep"
	elseif value == "Fast Rep" then
		State.autoFarmMode = "Fast Rep"
	else
		State.autoFarmMode = "Chill Rep"
	end
end)
local autoLiftGamepassToggle
autoLiftGamepassToggle = __FGRoot.CrefyUI.uiAddToggle(autoFarmPage, "🍀 Auto Lift GAMEPASS 🍀", function(enabled)
	if not enabled then
		return false
	end
	local unlocked = unlockNativeAutoLift()
	if unlocked then
		task.defer(function()
			autoLiftGamepassToggle:Set(true, true)
			autoLiftGamepassToggle:SetFrozen(true)
		end)
	end
	return unlocked
end)
	Controller.AutoLiftGamepassToggle = autoLiftGamepassToggle
local repToggles = {}

local function addExclusiveRep(label, key, tools, interval)
	local toggle
	toggle = __FGRoot.CrefyUI.uiAddToggle(autoFarmPage, label, function(enabled)
		if enabled then
			FastFarm.StopFastModesForManualFarm()
			FastFarm.StopMachineForExercise()
			for _, other in ipairs(repToggles) do
				if other ~= toggle then
					other:Set(false)
				end
			end
		end
		setAutoRep(key, enabled, tools, interval)
	end)
	repToggles[#repToggles + 1] = toggle
end
addExclusiveRep("🏋️ Auto Weight 🏋️", "autoWeight", { "Weight" }, 0)
addExclusiveRep("🤸 Auto Handstands 🤸", "autoHandstands", { "Handstands", "Handstand" }, 0.01)
addExclusiveRep("💪 Auto Pushups 💪", "autoLift", { "Pushup", "Pushups" }, 0.01)
addExclusiveRep("🧘 Auto Situps 🧘", "autoSitups", { "Situps", "Situp" }, 0.01)
	FastFarm.RepToggles = repToggles
__FGRoot.CrefyUI.uiAddToggle(autoFarmPage, "🥚 Auto Egg (30mins) 🥚", function(enabled)
	State.setAutoEgg(enabled)
end)
	FastFarm.HideFramesToggle = __FGRoot.CrefyUI.uiAddToggle(autoFarmPage, "🙈 Ocultar Frames 🙈", function(enabled)
		setHideFrames(enabled)
	end)
	track(LP:GetAttributeChangedSignal("ShowPopups"):Connect(function()
		local hidden = LP:GetAttribute("ShowPopups") == false
		if State.hideFrames ~= hidden then setHideFrames(hidden) end
		if FastFarm.HideFramesToggle:Get() ~= hidden then
			FastFarm.HideFramesToggle:Set(hidden, true)
		end
	end))
local machineToggles = {}
local currentMachineSection
for _, definition in ipairs(CONFIG.Machines) do
	local machineDefinition = definition
	machineDefinition.autoFarm = true
	machineDefinition.repInterval = 0
	local toggle
	if machineDefinition.section ~= currentMachineSection then
		currentMachineSection = machineDefinition.section
		__FGRoot.CrefyUI.uiAddSection(autoFarmPage, currentMachineSection)
		if currentMachineSection == "Muscle King Machines" then
			__FGRoot.CrefyUI.uiAddInfoRow(autoFarmPage, "Requisito:", "Muscle King actual", C.yellow)
		end
	end
	toggle = __FGRoot.CrefyUI.uiAddToggle(autoFarmPage, machineDefinition.label, function(enabled)
		if FastFarm.machineToggleSync then
			return
		end
		if enabled then
			FastFarm.SelectMachineToggle(toggle)
			setMachine(machineDefinition, true)
		elseif State.machine == machineDefinition then
			setMachine(machineDefinition, false)
		end
	end)
	machineToggles[#machineToggles + 1] = toggle
	FastFarm.RegisterMachineToggle(machineDefinition, toggle)
end
	FastFarm.MachineToggles = machineToggles
end

do
local fullTrainPage = Pages["Full Train"]
fullTrainPage:SetAttribute("TightCanvas", true)
__FGRoot.CrefyUI.uiAddSection(fullTrainPage, "Full Train")
FastFarm.FullTrainModeSelector = __FGRoot.CrefyUI.uiAddSelector(fullTrainPage, "Modo", { "Chill Rep", "Fast Rep" }, function(value)
	State.fullTrainMode = value == "Fast Rep" and "Fast Rep" or "Chill Rep"
end)
local fullTrainToggles = {}
local createdFullTrainKeys = {}
local createdFullTrainSections = {}
local scanStatus

local function addFullTrainMachineControls()
	local added = 0
	for _, definition in ipairs(CONFIG.FullTrainMachines) do
		local machineDefinition = definition
		local stableKey = tostring(machineDefinition.section or "") .. "\0" .. tostring(machineDefinition.object or machineDefinition.label or "")
		if not createdFullTrainKeys[stableKey] then
			createdFullTrainKeys[stableKey] = true
			machineDefinition.fullTrain = true
			machineDefinition.repInterval = 0.01
			if not createdFullTrainSections[machineDefinition.section] then
				createdFullTrainSections[machineDefinition.section] = true
				__FGRoot.CrefyUI.uiAddSection(fullTrainPage, machineDefinition.section)
				if machineDefinition.section == "Muscle King" then
					__FGRoot.CrefyUI.uiAddInfoRow(fullTrainPage, "Requisito:", "Muscle King actual", C.yellow)
				end
			end
			local toggle
			toggle = __FGRoot.CrefyUI.uiAddToggle(fullTrainPage, machineDefinition.label, function(enabled)
				if FastFarm.machineToggleSync then
					return
				elseif State.machine == machineDefinition then
					setMachine(machineDefinition, false)
				end
			end)
			fullTrainToggles[#fullTrainToggles + 1] = toggle
			FastFarm.RegisterMachineToggle(machineDefinition, toggle)
			added = added + 1
		end
	end
	FastFarm.FullTrainToggles = fullTrainToggles
	return added
end

local function rescanFullTrainMachines()
	local definitions = FastFarm.BuildFullTrainMachines()
	if #definitions > 0 then
		if scanStatus then scanStatus:SetVisible(false) end
		local added = addFullTrainMachineControls()
		if added > 0 then
			State.pushOutput("SYSTEM", "Full Train discovered " .. tostring(added) .. " additional machine controls")
			hubNotify("Full Train: " .. tostring(added) .. " machine controls loaded")
		else
			State.pushOutput("SYSTEM", "Full Train machine scan complete; no new controls")
		end
	else
		if not scanStatus then
			scanStatus = __FGRoot.CrefyUI.uiAddInfoRow(fullTrainPage, "Machine scan", "No machinesFolder found yet. Press Rescan after the map loads.", C.yellow)
		else
			scanStatus:SetText("No machinesFolder found yet. Press Rescan after the map loads.")
			scanStatus:SetVisible(true)
		end
		hubNotify("Full Train: machinesFolder is not available yet")
	end
end

rescanFullTrainMachines()
__FGRoot.CrefyUI.uiAddButton(fullTrainPage, "Rescan machines", rescanFullTrainMachines, C.cyan)
end

State.ThemePresets = {
	Galaxia = { base = Color3.fromRGB(6, 8, 17), panel = Color3.fromRGB(11, 15, 27), row = Color3.fromRGB(19, 24, 39), rowHover = Color3.fromRGB(29, 37, 58), tab = Color3.fromRGB(13, 18, 31), tabOn = Color3.fromRGB(28, 39, 65), cyan = Color3.fromRGB(105, 205, 255), blue = Color3.fromRGB(159, 139, 246), green = Color3.fromRGB(126, 224, 175), yellow = Color3.fromRGB(238, 206, 111), orange = Color3.fromRGB(236, 159, 93), red = Color3.fromRGB(255, 55, 82), white = Color3.fromRGB(246, 248, 252), soft = Color3.fromRGB(225, 230, 239), dim = Color3.fromRGB(165, 174, 189), black = Color3.fromRGB(0, 0, 0), art = Color3.fromRGB(204, 211, 255) },
	Violeta = { base = Color3.fromRGB(10, 6, 20), panel = Color3.fromRGB(20, 12, 37), row = Color3.fromRGB(31, 20, 50), rowHover = Color3.fromRGB(47, 29, 73), tab = Color3.fromRGB(24, 14, 42), tabOn = Color3.fromRGB(52, 31, 82), cyan = Color3.fromRGB(190, 142, 255), blue = Color3.fromRGB(139, 104, 255), green = Color3.fromRGB(126, 224, 175), yellow = Color3.fromRGB(240, 207, 121), orange = Color3.fromRGB(240, 146, 105), red = Color3.fromRGB(255, 76, 116), white = Color3.fromRGB(250, 247, 255), soft = Color3.fromRGB(230, 220, 244), dim = Color3.fromRGB(169, 153, 190), black = Color3.fromRGB(0, 0, 0), art = Color3.fromRGB(222, 190, 255) },
	["Carmesí"] = { base = Color3.fromRGB(17, 6, 10), panel = Color3.fromRGB(31, 11, 17), row = Color3.fromRGB(45, 18, 26), rowHover = Color3.fromRGB(68, 25, 37), tab = Color3.fromRGB(37, 13, 21), tabOn = Color3.fromRGB(74, 25, 40), cyan = Color3.fromRGB(255, 113, 145), blue = Color3.fromRGB(218, 87, 126), green = Color3.fromRGB(128, 225, 168), yellow = Color3.fromRGB(245, 205, 117), orange = Color3.fromRGB(246, 143, 91), red = Color3.fromRGB(255, 58, 91), white = Color3.fromRGB(255, 247, 249), soft = Color3.fromRGB(240, 218, 224), dim = Color3.fromRGB(188, 151, 161), black = Color3.fromRGB(0, 0, 0), art = Color3.fromRGB(255, 180, 195) },
	Esmeralda = { base = Color3.fromRGB(4, 13, 14), panel = Color3.fromRGB(8, 25, 26), row = Color3.fromRGB(13, 38, 38), rowHover = Color3.fromRGB(19, 57, 55), tab = Color3.fromRGB(9, 31, 31), tabOn = Color3.fromRGB(17, 61, 58), cyan = Color3.fromRGB(84, 231, 204), blue = Color3.fromRGB(79, 194, 179), green = Color3.fromRGB(117, 239, 173), yellow = Color3.fromRGB(232, 217, 116), orange = Color3.fromRGB(233, 156, 91), red = Color3.fromRGB(255, 77, 99), white = Color3.fromRGB(243, 255, 253), soft = Color3.fromRGB(212, 240, 235), dim = Color3.fromRGB(145, 183, 176), black = Color3.fromRGB(0, 0, 0), art = Color3.fromRGB(170, 255, 235) },
}
State.themeConfigFolder = "Young0xHub/FG100"
State.themeConfigPath = State.themeConfigFolder .. "/theme_" .. tostring(LP.UserId) .. ".txt"
if not State.resume and type(isfile) == "function" and type(readfile) == "function" then
	pcall(function() if isfile(State.themeConfigPath) then local saved = readfile(State.themeConfigPath); if State.ThemePresets[saved] then State.themeName = saved end end end)
end
local function themeColorKey(color)
	return string.format("%d,%d,%d", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
end
State.applyTheme = function(name, quiet)
	local preset = State.ThemePresets[name]
	if not preset then return false end
	local old = {}
	for role, color in pairs(C) do if typeof(color) == "Color3" then old[themeColorKey(color)] = role end end
	for _, object in ipairs(getHubUIDescendants()) do
		for _, property in ipairs({ "BackgroundColor3", "TextColor3", "ImageColor3", "ScrollBarImageColor3" }) do
			pcall(function() local role = old[themeColorKey(object[property])]; if role and preset[role] then object[property] = preset[role] end end)
		end
		if object:IsA("UIStroke") then local role = old[themeColorKey(object.Color)]; if role and preset[role] then object.Color = preset[role] end end
	end
	for role, color in pairs(preset) do if role ~= "art" then C[role] = color end end
    if __FGRoot.CrefyLibrary and __FGRoot.CrefyLibrary.Scheme then
        pcall(function()
            __FGRoot.CrefyLibrary.Scheme.BackgroundColor = C.base
            __FGRoot.CrefyLibrary.Scheme.MainColor = C.panel
            __FGRoot.CrefyLibrary.Scheme.AccentColor = C.cyan
            __FGRoot.CrefyLibrary.Scheme.OutlineColor = C.blue
            __FGRoot.CrefyLibrary.Scheme.FontColor = C.white
            __FGRoot.CrefyLibrary:UpdateColorsUsingRegistry()
        end)
    end
	MainFrame.BackgroundColor3 = C.base
	TabBar.BackgroundColor3 = C.base
	MiniBubble.BackgroundColor3 = C.panel
	local art = MainFrame:FindFirstChild("BackgroundArt")
	if art then art.ImageColor3 = preset.art end
	local stars = MiniBubble:FindFirstChild("Stars")
	if stars then stars.ImageColor3 = preset.art end
	if State.motionShell then State.motionShell.BackgroundColor3 = C.base end
	if State.motionShellArt then State.motionShellArt.ImageColor3 = preset.art end
	State.themeName = name
	ScreenGui:SetAttribute("Theme", name)
	if type(makefolder) == "function" and type(writefile) == "function" then pcall(function() if type(isfolder) ~= "function" or not isfolder("Young0xHub") then makefolder("Young0xHub") end; if type(isfolder) ~= "function" or not isfolder(State.themeConfigFolder) then makefolder(State.themeConfigFolder) end; writefile(State.themeConfigPath, name) end) end
	if State.currentTab then refreshTabs(State.currentTab) end
	if not quiet then State.pushOutput("THEME", "Tema aplicado: " .. name) end
	return true
end

local pageSetup

pageSetup = function()
local fastFarmPage = Pages["Fast Farm"]
fastFarmPage:SetAttribute("TightCanvas", true)
fastFarmPage.ScrollingEnabled = false
fastFarmPage.ScrollBarThickness = 0
local fastFarmSection = __FGRoot.CrefyUI.uiAddSection(fastFarmPage, "Fast Farm")
fastFarmSection.Parent.Size = UDim2.new(1, 0, 0, 10)
fastFarmSection.Size = UDim2.fromOffset(0, 10)

local rebirthToggle
local strengthToggle

local function startMode(toggle, otherToggle, mode)
	local sessionStartedAt = FastFarm.sessionStartedAt
	if otherToggle then
		otherToggle:Set(false)
	end
	if sessionStartedAt then FastFarm.sessionStartedAt = sessionStartedAt end
	local started = FastFarm:Start(mode)
	if not started then hubNotify(FastFarm.lastError or "No se pudo iniciar Fast Farm") end
	return started
end

strengthToggle = __FGRoot.CrefyUI.uiAddToggle(fastFarmPage, "Fuerza rápida", function(enabled)
	if enabled then
		return startMode(strengthToggle, rebirthToggle, "strength")
	elseif FastFarm.mode == "strength" then
		FastFarm:Stop(true)
	end
	return nil
end)
strengthToggle.Button.Size = UDim2.new(1, 0, 0, 30)
FastFarm.StrengthToggle = strengthToggle

rebirthToggle = __FGRoot.CrefyUI.uiAddToggle(fastFarmPage, "Rebirths rápidos", function(enabled)
	if enabled then
		return startMode(rebirthToggle, strengthToggle, "rebirth")
	elseif FastFarm.mode == "rebirth" then
		FastFarm:Stop(true)
	end
	return nil
end)
rebirthToggle.Button.Size = UDim2.new(1, 0, 0, 30)
FastFarm.RebirthToggle = rebirthToggle
	track(rebirthToggle.Button.Activated:Connect(function()
		if rebirthToggle:IsLocked() then
			hubNotify("Rebirths rápidos requiere un pack de fuerza y al menos un pet con bonus de rebirth")
		end
	end))


	local setFastFarmContentDisabled = function() end

	FastFarm.RefreshAvailability = function()
		local strengthAvailable, rebirthPackAvailable = FastFarm:LoadPack(false)
		local rebirthAvailable = strengthAvailable and rebirthPackAvailable
	if strengthToggle:IsLocked() == strengthAvailable then
		strengthToggle:SetLocked(not strengthAvailable)
	end
	if rebirthToggle:IsLocked() == rebirthAvailable then
		rebirthToggle:SetLocked(not rebirthAvailable)
	end
	FastFarm.strengthAvailable = strengthAvailable
	FastFarm.rebirthAvailable = rebirthAvailable
	setFastFarmContentDisabled(not strengthAvailable and not rebirthAvailable)
    if FastFarm.CrefyPackSelector and FastFarm.packMode then
        FastFarm.CrefyPackSelector:SetValue(FastFarm.packMode)
    end
	return strengthAvailable, rebirthAvailable
end
startThread("fastFarmAvailability", function()
	while State.running do
		FastFarm.RefreshAvailability()
		task.wait(1.5)
	end
end)


FastFarm.UpdateStrengthFramesControl = function() end

local timeValue, timeRow, timeLabel = __FGRoot.CrefyUI.uiAddInfoRow(fastFarmPage, "Tiempo:", "0d 0h 0m 0s", C.white)
timeRow.Size = UDim2.new(1, 0, 0, 23)
timeLabel.TextColor3 = C.white
timeLabel.TextSize = 11
timeValue.TextSize = 11
local calculatorValue, calculatorRow, calculatorLabel = __FGRoot.CrefyUI.uiAddInfoRow(fastFarmPage, "Calculadora:", "0/h  •  0/d  •  0/w", C.white)
calculatorRow.Size = UDim2.new(1, 0, 0, 23)
calculatorRow.BackgroundTransparency = 0.02
calculatorLabel.TextColor3 = C.white
calculatorLabel.TextSize = 11
calculatorValue.TextSize = 11
calculatorValue.TextColor3 = C.white
calculatorValue.TextStrokeTransparency = 1
local calculatorStroke = calculatorRow:FindFirstChildOfClass("UIStroke")
if calculatorStroke then
	calculatorStroke.Color = C.cyan
	calculatorStroke.Transparency = 0.28
end
local counterRow = __FGRoot.CrefyUI.uiAddSection(fastFarmPage, "Resultados")

local function addFarmCounterColumn(titleText)
    local value, _, label = __FGRoot.CrefyUI.uiAddInfoRow(fastFarmPage, titleText, "0", C.white)
    local gain = __FGRoot.CrefyUI.uiAddInfoRow(fastFarmPage, titleText .. " ganancia", "", C.green)
    gain.Visible = false
    return { Value = value, Gain = gain, Title = label }
end

local strengthCounter = addFarmCounterColumn("Strength:")
local rebirthCounter = addFarmCounterColumn("Rebirths:")

local WORDS = {
	{ es = "Si reconocemos nuestros pecados ante Dios, él es fiel: nos perdona y limpia toda nuestra maldad.", en = "If we confess our sins to God, he is faithful: he forgives us and cleanses us from all wrongdoing.", esRef = "1 Juan 1:9", enRef = "1 John 1:9", esNote = "No tenés que esconderte de Dios. Podés hablarle con sinceridad y empezar de nuevo.", enNote = "You do not have to hide from God. You can speak honestly to him and begin again." },
	{ es = "Dios aleja nuestros pecados tan lejos como está el oriente del occidente.", en = "God removes our sins as far away as the east is from the west.", esRef = "Salmos 103:12", enRef = "Psalms 103:12", esNote = "Cuando Dios te perdona, no quiere que vivas prisionero de la culpa del pasado.", enNote = "When God forgives you, he does not want you to remain trapped by past guilt." },
	{ es = "Aunque tus pecados sean rojos como la sangre, Dios puede dejarlos blancos como la nieve.", en = "Even if your sins are red like blood, God can make them white like snow.", esRef = "Isaías 1:18", enRef = "Isaiah 1:18", esNote = "Ningún error es demasiado grande para la misericordia de Dios.", enNote = "No mistake is too great for God's mercy." },
	{ es = "Dios vuelve a tener compasión, vence nuestra maldad y arroja nuestros pecados al fondo del mar.", en = "God has compassion again, defeats our wrongdoing, and throws our sins into the depths of the sea.", esRef = "Miqueas 7:19", enRef = "Micah 7:19", esNote = "Dios puede dejar tu culpa atrás y darte una vida diferente.", enNote = "God can put your guilt behind you and give you a different life." },
	{ es = "Dios amó tanto al mundo que dio a su único Hijo, para que quien crea en él tenga vida eterna.", en = "God loved the world so much that he gave his only Son, so whoever believes in him may have eternal life.", esRef = "Juan 3:16", enRef = "John 3:16", esNote = "El amor de Dios también es para vos. Jesús abrió un camino de vida y esperanza.", enNote = "God's love is for you too. Jesus opened a way of life and hope." },
	{ es = "Dios demuestra su amor: aun cuando éramos pecadores, Cristo murió por nosotros.", en = "God proves his love: even while we were sinners, Christ died for us.", esRef = "Romanos 5:8", enRef = "Romans 5:8", esNote = "Dios no esperó que fueras perfecto para amarte.", enNote = "God did not wait for you to be perfect before loving you." },
	{ es = "Para quienes están en Cristo Jesús ya no hay condenación.", en = "There is no condemnation for those who belong to Christ Jesus.", esRef = "Romanos 8:1", enRef = "Romans 8:1", esNote = "Tu pasado no tiene que decidir quién sos ni cómo termina tu historia.", enNote = "Your past does not have to decide who you are or how your story ends." },
	{ es = "Quien está unido a Cristo es una nueva persona: lo viejo pasó y comenzó algo nuevo.", en = "Anyone joined to Christ is a new person: the old life is gone and a new life has begun.", esRef = "2 Corintios 5:17", enRef = "2 Corinthians 5:17", esNote = "Con Jesús siempre existe la posibilidad de volver a comenzar.", enNote = "With Jesus, there is always a chance to begin again." },
	{ es = "Dios mostró cuánto nos ama enviando a su Hijo para darnos vida por medio de él.", en = "God showed how much he loves us by sending his Son so we could have life through him.", esRef = "1 Juan 4:9", enRef = "1 John 4:9", esNote = "El amor de Dios no es solo una idea: se mostró en lo que hizo por nosotros.", enNote = "God's love is not just an idea: it was shown in what he did for us." },
	{ es = "El amor perfecto de Dios expulsa el miedo.", en = "God's perfect love drives out fear.", esRef = "1 Juan 4:18", enRef = "1 John 4:18", esNote = "Recordar cuánto te ama Dios puede darle calma a tu corazón.", enNote = "Remembering how much God loves you can bring peace to your heart." },
	{ es = "Vengan a mí todos los que están cansados y cargados, y yo les daré descanso.", en = "Come to me, all who are tired and carrying heavy burdens, and I will give you rest.", esRef = "Mateo 11:28", enRef = "Matthew 11:28", esNote = "No tenés que cargar todo solo. Jesús quiere recibir tu cansancio.", enNote = "You do not have to carry everything alone. Jesus wants to receive your weariness." },
	{ es = "Dios está cerca de quienes tienen el corazón roto y salva a quienes perdieron el ánimo.", en = "God is close to those with broken hearts and saves those who have lost their courage.", esRef = "Salmos 34:18", enRef = "Psalms 34:18", esNote = "Cuando más herido te sentís, Dios no se aleja: se acerca.", enNote = "When you feel most wounded, God does not move away: he comes near." },
	{ es = "Dios sana los corazones rotos y cura sus heridas.", en = "God heals broken hearts and cares for their wounds.", esRef = "Salmos 147:3", enRef = "Psalms 147:3", esNote = "Dios ve el dolor que otros no ven y puede restaurarte poco a poco.", enNote = "God sees the pain others cannot see and can restore you little by little." },
	{ es = "No tengas miedo, porque yo estoy contigo. Te daré fuerzas, te ayudaré y te sostendré.", en = "Do not be afraid, because I am with you. I will strengthen, help, and support you.", esRef = "Isaías 41:10", enRef = "Isaiah 41:10", esNote = "No estás solo frente a lo difícil. Dios promete acompañarte y sostenerte.", enNote = "You are not alone when life is hard. God promises to stay with you and hold you up." },
	{ es = "Sé fuerte y valiente. No tengas miedo, porque Dios estará contigo dondequiera que vayas.", en = "Be strong and courageous. Do not be afraid, because God will be with you wherever you go.", esRef = "Josué 1:9", enRef = "Joshua 1:9", esNote = "Podés avanzar con valor porque Dios también entra con vos en lo desconocido.", enNote = "You can move forward bravely because God goes with you into the unknown." },
	{ es = "Dios irá delante de vos. No te dejará ni te abandonará; no tengas miedo.", en = "God will go ahead of you. He will never leave or abandon you, so do not be afraid.", esRef = "Deuteronomio 31:8", enRef = "Deuteronomy 31:8", esNote = "Antes de que llegues al problema, Dios ya conoce el camino.", enNote = "Before you reach the problem, God already knows the way." },
	{ es = "Aunque camine por el valle más oscuro, no temeré, porque tú estás conmigo.", en = "Even when I walk through the darkest valley, I will not be afraid, because you are with me.", esRef = "Salmos 23:4", enRef = "Psalms 23:4", esNote = "El momento oscuro no es el final. Dios camina a tu lado mientras lo atravesás.", enNote = "The dark moment is not the end. God walks beside you while you go through it." },
	{ es = "Dios es mi luz y mi salvación; ¿a quién voy a temer?", en = "God is my light and my salvation, so whom should I fear?", esRef = "Salmos 27:1", enRef = "Psalms 27:1", esNote = "Cuando Dios guía tu camino, el miedo deja de tener el control.", enNote = "When God guides your path, fear no longer has control." },
	{ es = "Aunque un ejército acampe contra mí, no temerá mi corazón; aunque contra mí se levante guerra, yo estaré confiado.", en = "Even if an army surrounds me, my heart will not fear; even if war rises against me, I will remain confident.", esRef = "Salmos 27:3", enRef = "Psalms 27:3", esNote = "La fe no niega la batalla: mantiene firme tu corazón en medio de ella.", enNote = "Faith does not deny the battle: it keeps your heart steady in the middle of it." },
	{ es = "Dios es nuestro refugio y nuestra fuerza, una ayuda siempre presente en los problemas.", en = "God is our refuge and strength, always ready to help in times of trouble.", esRef = "Salmos 46:1", enRef = "Psalms 46:1", esNote = "Cuando todo se mueve, podés correr hacia Dios y encontrar seguridad.", enNote = "When everything shakes, you can run to God and find safety." },
	{ es = "Entregale tus cargas a Dios y él te sostendrá.", en = "Give your burdens to God and he will sustain you.", esRef = "Salmos 55:22", enRef = "Psalms 55:22", esNote = "Dios puede sostenerte cuando sentís que ya no te quedan fuerzas.", enNote = "God can hold you up when you feel that you have no strength left." },
	{ es = "Dejen todas sus preocupaciones en Dios, porque él cuida de ustedes.", en = "Give all your worries to God, because he cares for you.", esRef = "1 Pedro 5:7", enRef = "1 Peter 5:7", esNote = "Lo que te preocupa también le importa a Dios. Podés contárselo.", enNote = "What worries you matters to God too. You can tell him about it." },
	{ es = "Jesús dice: Les dejo mi paz. No tengan miedo ni se angustien.", en = "Jesus says: I leave you my peace. Do not be afraid or troubled.", esRef = "Juan 14:27", enRef = "John 14:27", esNote = "La paz de Jesús puede cuidar tu corazón incluso cuando alrededor hay problemas.", enNote = "Jesus' peace can guard your heart even when there are problems around you." },
	{ es = "No vivan preocupados. Hablen con Dios de todo y denle gracias; su paz cuidará su corazón.", en = "Do not live in worry. Talk to God about everything with gratitude, and his peace will guard your heart.", esRef = "Filipenses 4:6-7", enRef = "Philippians 4:6-7", esNote = "Cuando llegue la ansiedad, convertí la preocupación en una conversación con Dios.", enNote = "When anxiety comes, turn your worry into a conversation with God." },
	{ es = "Todo lo puedo enfrentar con Cristo, porque él me da fuerzas.", en = "I can face every situation through Christ, because he gives me strength.", esRef = "Filipenses 4:13", enRef = "Philippians 4:13", esNote = "Cristo te fortalece para atravesar cada etapa, incluso las más difíciles.", enNote = "Christ strengthens you to go through every season, even the hardest ones." },
	{ es = "Mi gracia es suficiente para vos, porque mi poder se muestra mejor en la debilidad.", en = "My grace is enough for you, because my power is shown best in weakness.", esRef = "2 Corintios 12:9", enRef = "2 Corinthians 12:9", esNote = "Ser débil no te hace inútil. Dios puede mostrar su poder justo ahí.", enNote = "Being weak does not make you useless. God can show his power right there." },
	{ es = "Dios hace que todas las cosas ayuden para bien a quienes lo aman.", en = "God works through all things for the good of those who love him.", esRef = "Romanos 8:28", enRef = "Romans 8:28", esNote = "Dios puede usar incluso una etapa dolorosa para construir algo bueno.", enNote = "God can use even a painful season to build something good." },
	{ es = "Dios tiene pensamientos de paz para vos, para darte esperanza y un futuro.", en = "God has plans of peace for you, to give you hope and a future.", esRef = "Jeremías 29:11", enRef = "Jeremiah 29:11", esNote = "Aunque hoy no veas el camino completo, Dios todavía puede guiar tu futuro.", enNote = "Even when you cannot see the whole path today, God can still guide your future." },
	{ es = "El amor de Dios nunca se acaba; su misericordia es nueva cada mañana.", en = "God's faithful love never ends; his mercy is new every morning.", esRef = "Lamentaciones 3:22-23", enRef = "Lamentations 3:22-23", esNote = "Cada día trae una nueva oportunidad. Lo de ayer no limita lo que Dios puede hacer hoy.", enNote = "Every day brings a new opportunity. Yesterday does not limit what God can do today." },
	{ es = "El llanto puede durar una noche, pero por la mañana llega la alegría.", en = "Crying may last through the night, but joy comes in the morning.", esRef = "Salmos 30:5", enRef = "Psalms 30:5", esNote = "El dolor es real, pero no dura para siempre. La alegría puede volver.", enNote = "Pain is real, but it does not last forever. Joy can return." },
	{ es = "No se cansen de hacer el bien. A su tiempo cosecharán, si no se rinden.", en = "Do not grow tired of doing good. At the right time you will harvest, if you do not give up.", esRef = "Gálatas 6:9", enRef = "Galatians 6:9", esNote = "Aunque todavía no veas resultados, seguir haciendo el bien vale la pena.", enNote = "Even when you cannot see results yet, continuing to do good is worth it." },
	{ es = "Dios secará cada lágrima. Ya no habrá muerte, llanto ni dolor.", en = "God will wipe away every tear. There will be no more death, crying, or pain.", esRef = "Apocalipsis 21:4", enRef = "Revelation 21:4", esNote = "El sufrimiento no tendrá la última palabra. Dios promete un final lleno de vida.", enNote = "Suffering will not have the final word. God promises an ending filled with life." },
	{ es = "Poné tu camino en manos de Dios, confiá en él y él actuará.", en = "Place your path in God's hands, trust him, and he will act.", esRef = "Salmos 37:5", enRef = "Psalms 37:5", esNote = "Confiar en Dios también significa entregarle tus decisiones y seguir avanzando.", enNote = "Trusting God also means giving him your decisions and continuing forward." },
	{ es = "Confiá en Dios con todo tu corazón; él te mostrará el camino correcto.", en = "Trust God with all your heart, and he will show you the right path.", esRef = "Proverbios 3:5-6", enRef = "Proverbs 3:5-6", esNote = "No necesitás entender todo para dar el siguiente paso de la mano de Dios.", enNote = "You do not need to understand everything to take the next step with God." },
	{ es = "Poné en manos de Dios todo lo que hagas, y tus planes podrán afirmarse.", en = "Place everything you do in God's hands, and your plans can become firm.", esRef = "Proverbios 16:3", enRef = "Proverbs 16:3", esNote = "Invitá a Dios a tus proyectos, decisiones y sueños desde el principio.", enNote = "Invite God into your projects, decisions, and dreams from the beginning." },
	{ es = "Mi ayuda viene de Dios, creador del cielo y de la tierra.", en = "My help comes from God, the maker of heaven and earth.", esRef = "Salmos 121:1-2", enRef = "Psalms 121:1-2", esNote = "Tu ayuda no depende solamente de tus fuerzas: podés mirar a Dios.", enNote = "Your help does not depend only on your own strength: you can look to God." },
	{ es = "Quienes confían en Dios renuevan sus fuerzas; vuelan como águilas y corren sin rendirse.", en = "Those who trust God renew their strength; they soar like eagles and run without giving up.", esRef = "Isaías 40:31", enRef = "Isaiah 40:31", esNote = "Esperar en Dios no es perder tiempo: es recibir nuevas fuerzas para continuar.", enNote = "Waiting for God is not wasting time: it is receiving new strength to continue." },
	{ es = "Quien vive bajo el cuidado del Altísimo puede decir: Dios es mi refugio y mi lugar seguro.", en = "Whoever lives under the care of the Most High can say: God is my refuge and my safe place.", esRef = "Salmos 91:1-2", enRef = "Psalms 91:1-2", esNote = "En Dios podés encontrar seguridad aun cuando el mundo se sienta inseguro.", enNote = "In God you can find safety even when the world feels unsafe." },
	{ es = "Cuando tenga miedo, confiaré en ti.", en = "When I am afraid, I will trust in you.", esRef = "Salmos 56:3", enRef = "Psalms 56:3", esNote = "Tener fe no significa no sentir miedo; significa elegir confiar a pesar de él.", enNote = "Faith does not mean never feeling fear; it means choosing to trust despite it." },
	{ es = "En el mundo van a tener dificultades. Pero tengan ánimo: yo he vencido al mundo.", en = "In the world you will have trouble. But take courage: I have overcome the world.", esRef = "Juan 16:33", enRef = "John 16:33", esNote = "Estas palabras son de Jesús. Él sabe que la vida puede ser difícil, pero te anima a no rendirte.", enNote = "These are Jesus' words. He knows life can be hard, but he encourages you not to give up." },
	{ es = "Nada podrá separarnos del amor que Dios nos mostró en Cristo Jesús.", en = "Nothing can separate us from the love God showed us in Christ Jesus.", esRef = "Romanos 8:38-39", enRef = "Romans 8:38-39", esNote = "El miedo y los errores no cambian ese amor. Podés volver a levantarte sin vivir atrapado en la culpa.", enNote = "Fear and mistakes do not change that love. You can get back up without living trapped in guilt." },
	{ es = "Te doy gracias porque fui creado de una manera maravillosa.", en = "I thank you because I was made in a wonderful way.", esRef = "Salmos 139:14", enRef = "Psalms 139:14", esNote = "Tu vida tiene valor. No sos un accidente ni una copia de otra persona.", enNote = "Your life has value. You are not an accident or a copy of someone else." },
	{ es = "Somos obra de Dios, creados para hacer el bien que él preparó para nosotros.", en = "We are God's work, created to do the good things he prepared for us.", esRef = "Efesios 2:10", enRef = "Ephesians 2:10", esNote = "Dios puso propósito en tu vida y puede usar lo que sos para hacer el bien.", enNote = "God placed purpose in your life and can use who you are to do good." },
	{ es = "Sean amables y compasivos, y perdónense como Dios los perdonó.", en = "Be kind and compassionate, and forgive each other as God forgave you.", esRef = "Efesios 4:32", enRef = "Ephesians 4:32", esNote = "La fe también se nota en cómo tratás a las personas que tenés cerca.", enNote = "Faith is also seen in how you treat the people around you." },
	{ es = "Tengan paciencia y perdónense cuando alguien los ofenda, así como Cristo los perdonó.", en = "Be patient and forgive when someone hurts you, just as Christ forgave you.", esRef = "Colosenses 3:13", enRef = "Colossians 3:13", esNote = "Perdonar no aprueba el daño; evita que el rencor siga controlando tu corazón.", enNote = "Forgiving does not approve the harm; it keeps resentment from controlling your heart." },
	{ es = "Un amigo ama en todo momento y en la dificultad se vuelve como un hermano.", en = "A friend loves at all times and becomes like family in times of trouble.", esRef = "Proverbios 17:17", enRef = "Proverbs 17:17", esNote = "La amistad verdadera se demuestra quedándose cerca cuando la vida se complica.", enNote = "True friendship is shown by staying close when life becomes difficult." },
	{ es = "Si Dios es por nosotros, ¿quién contra nosotros?", en = "If God is for us, who can be against us?", esRef = "Romanos 8:31", enRef = "Romans 8:31", esNote = "No enfrentás la vida solo: Dios está de tu lado aun cuando el camino se pone difícil.", enNote = "You do not face life alone: God is with you even when the road becomes difficult." },
	{ es = "Ustedes son la luz del mundo. Que su luz se vea y ayude a otros.", en = "You are the light of the world. Let your light be seen and help others.", esRef = "Mateo 5:14-16", enRef = "Matthew 5:14-16", esNote = "Tus buenas acciones pueden mostrar esperanza a una persona que la necesita.", enNote = "Your good actions can show hope to someone who needs it." },
	{ es = "Para Dios no hay nada imposible.", en = "Nothing is impossible for God.", esRef = "Lucas 1:37", enRef = "Luke 1:37", esNote = "Cuando vos no ves una salida, Dios todavía puede abrir un camino.", enNote = "When you cannot see a way out, God can still open a path." },
	{ es = "Que Dios te bendiga y te cuide; que te mire con amor y te dé paz.", en = "May God bless and protect you; may he look on you with love and give you peace.", esRef = "Números 6:24-26", enRef = "Numbers 6:24-26", esNote = "La bendición de Dios incluye cuidado, cercanía y paz para tu camino.", enNote = "God's blessing includes care, closeness, and peace for your journey." },
	{ es = "Dios creó a los seres humanos a su imagen; los creó hombre y mujer.", en = "God created human beings in his own image; he created them male and female.", esRef = "Génesis 1:27", enRef = "Genesis 1:27", esNote = "Tu vida tiene valor desde el comienzo. No sos una copia de nadie.", enNote = "Your life has value from the beginning. You are not a copy of anyone else." },
	{ es = "Tú formaste todo mi cuerpo y me hiciste dentro del vientre de mi madre.", en = "You formed my whole body and made me inside my mother's womb.", esRef = "Salmos 139:13", enRef = "Psalms 139:13", esNote = "Tu historia empezó antes de que pudieras recordarla. Cada parte de vos merece cuidado y respeto.", enNote = "Your story began before you could remember it. Every part of you deserves care and respect." },
	{ es = "Sobre todas las cosas, cuidá tu corazón, porque de él nace tu manera de vivir.", en = "Above everything else, guard your heart, because your way of life flows from it.", esRef = "Proverbios 4:23", enRef = "Proverbs 4:23", esNote = "Cuidá lo que dejás entrar en tu mente, porque termina influyendo en tus palabras y acciones.", enNote = "Be careful what you allow into your mind because it shapes your words and actions." },
	{ es = "La preocupación aplasta el corazón, pero una buena palabra trae alegría.", en = "Worry weighs down the heart, but a kind word brings joy.", esRef = "Proverbios 12:25", enRef = "Proverbs 12:25", esNote = "Una palabra buena puede cambiar el día de alguien que está cargando algo difícil.", enNote = "A kind word can change the day of someone carrying something difficult." },
	{ es = "Las palabras amables son como miel: dulces para el alma y buenas para el cuerpo.", en = "Kind words are like honey: sweet to the soul and good for the body.", esRef = "Proverbios 16:24", enRef = "Proverbs 16:24", esNote = "Tus palabras pueden sanar o herir. Elegí usarlas para dar vida y ánimo.", enNote = "Your words can heal or hurt. Choose to use them to give life and courage." },
	{ es = "Todo lo que hagan, háganlo de corazón, como para Dios y no solo para las personas.", en = "Whatever you do, do it with all your heart, as for God and not only for people.", esRef = "Colosenses 3:23", enRef = "Colossians 3:23", esNote = "Hacer bien incluso lo pequeño muestra quién sos, aunque nadie te esté mirando.", enNote = "Doing even small things well shows who you are, even when nobody is watching." },
	{ es = "Traten a los demás como quieren que ellos los traten a ustedes.", en = "Treat others the way you want them to treat you.", esRef = "Lucas 6:31", enRef = "Luke 6:31", esNote = "Antes de actuar, pensá cómo te sentirías si alguien hiciera lo mismo con vos.", enNote = "Before acting, think about how you would feel if someone did the same to you." },
	{ es = "El amor es paciente y bondadoso; no tiene envidia, no presume y no busca hacer daño.", en = "Love is patient and kind; it is not jealous, proud, or looking to cause harm.", esRef = "1 Corintios 13:4-5", enRef = "1 Corinthians 13:4-5", esNote = "El amor verdadero se nota en la paciencia y en cómo tratás a la otra persona.", enNote = "Real love is seen in patience and in how you treat the other person." },
	{ es = "Ámense unos a otros. Así como yo los amé, también ustedes deben amarse.", en = "Love one another. Just as I loved you, you should also love each other.", esRef = "Juan 13:34", enRef = "John 13:34", esNote = "Amar como Jesús es tratar a los demás con paciencia, ayuda y cariño.", enNote = "Loving like Jesus means treating others with patience, help, and care." },
	{ es = "Amá a Dios con todo tu corazón y amá a tu prójimo como a vos mismo.", en = "Love God with all your heart, and love your neighbor as yourself.", esRef = "Mateo 22:37-39", enRef = "Matthew 22:37-39", esNote = "Jesús resumió así una vida buena: amar a Dios y tratar con amor a los demás.", enNote = "Jesus summed up a good life this way: love God and treat others with love." },
	{ es = "No te dejes vencer por el mal; vencé el mal haciendo el bien.", en = "Do not let evil defeat you; defeat evil by doing good.", esRef = "Romanos 12:21", enRef = "Romans 12:21", esNote = "Hacer el bien evita que el mal cambie tu corazón y siga lastimando a otros.", enNote = "Doing good keeps evil from changing your heart and continuing to hurt others." },
	{ es = "Dios te pide hacer justicia, amar la misericordia y caminar humildemente con él.", en = "God asks you to act justly, love mercy, and walk humbly with him.", esRef = "Miqueas 6:8", enRef = "Micah 6:8", esNote = "Seguir a Dios significa hacer lo correcto, tratar con compasión y no creerte superior.", enNote = "Following God means doing what is right, showing compassion, and not acting superior." },
	{ es = "Si a alguno le falta sabiduría, pídasela a Dios, que da con generosidad.", en = "If anyone lacks wisdom, ask God, who gives generously.", esRef = "Santiago 1:5", enRef = "James 1:5", esNote = "Cuando no sabés qué hacer, podés pedirle a Dios claridad para elegir bien.", enNote = "When you do not know what to do, you can ask God for clarity to choose well." },
	{ es = "Tu palabra es una lámpara para mis pies y una luz para mi camino.", en = "Your word is a lamp for my feet and a light for my path.", esRef = "Salmos 119:105", enRef = "Psalms 119:105", esNote = "La Biblia puede ayudarte a ver la próxima decisión, aunque todavía no veas todo el camino.", enNote = "The Bible can help you see the next choice even when you cannot see the whole road." },
	{ es = "Tú llevás cuenta de mis tristezas y guardás cada una de mis lágrimas.", en = "You keep track of my sorrows and remember every one of my tears.", esRef = "Salmos 56:8", enRef = "Psalms 56:8", esNote = "Tu tristeza no es invisible. Cada lágrima importa.", enNote = "Your sadness is not invisible. Every tear matters." },
	{ es = "Aunque una madre pudiera olvidar a su hijo, yo nunca te olvidaré; te llevo escrito en mis manos.", en = "Even if a mother could forget her child, I will never forget you; I have written you on my hands.", esRef = "Isaías 49:15-16", enRef = "Isaiah 49:15-16", esNote = "Sentirte olvidado no significa que estés solo. Tu vida sigue siendo vista y recordada.", enNote = "Feeling forgotten does not mean you are alone. Your life is still seen and remembered." },
	{ es = "Felices los que lloran, porque serán consolados.", en = "Blessed are those who mourn, because they will be comforted.", esRef = "Mateo 5:4", enRef = "Matthew 5:4", esNote = "Llorar no te hace débil. El consuelo puede llegar después de un momento muy duro.", enNote = "Crying does not make you weak. Comfort can come after a very hard time." },
	{ es = "Dios nos consuela en todas nuestras dificultades, para que podamos consolar a otros.", en = "God comforts us in all our troubles so that we can comfort others.", esRef = "2 Corintios 1:3-4", enRef = "2 Corinthians 1:3-4", esNote = "El consuelo que recibís también puede convertirse en ayuda para otra persona.", enNote = "The comfort you receive can also become help for someone else." },
	{ es = "Esperé con paciencia a Dios; él me oyó, me sacó del pozo y puso mis pies sobre una roca.", en = "I waited patiently for God; he heard me, lifted me from the pit, and placed my feet on a rock.", esRef = "Salmos 40:1-2", enRef = "Psalms 40:1-2", esNote = "Aunque la salida tarde, podés volver a encontrar un lugar firme y empezar de nuevo.", enNote = "Even when the way out takes time, you can find firm ground and begin again." },
	{ es = "El Señor está conmigo; no temeré. ¿Qué puede hacerme el hombre?", en = "The Lord is with me; I will not be afraid. What can man do to me?", esRef = "Salmos 118:6", enRef = "Psalms 118:6", esNote = "No enfrentás el miedo solo: Dios permanece a tu lado.", enNote = "You do not face fear alone: God remains by your side." },
	{ es = "Cuando pases por las aguas, yo estaré contigo; cuando pases por el fuego, no te quemarás.", en = "When you pass through the waters, I will be with you; when you walk through fire, you will not be burned.", esRef = "Isaías 43:2", enRef = "Isaiah 43:2", esNote = "Dios no dice que nunca habrá pruebas. Promete que no tendrás que cruzarlas solo.", enNote = "God does not say there will never be trials. He promises you will not cross them alone." },
	{ es = "Confíen siempre en Dios y abran delante de él su corazón; Dios es nuestro refugio.", en = "Always trust God and pour out your heart before him; God is our refuge.", esRef = "Salmos 62:8", enRef = "Psalms 62:8", esNote = "Orar es hablar con sinceridad, incluso sobre lo que te cuesta explicar.", enNote = "Prayer means speaking honestly, even about what is hard to explain." },
	{ es = "En paz me acostaré y dormiré, porque solo tú, Dios, me hacés vivir seguro.", en = "I will lie down and sleep in peace, because you alone, God, make me live safely.", esRef = "Salmos 4:8", enRef = "Psalms 4:8", esNote = "Antes de dormir, podés soltar tus temores y darte permiso para descansar.", enNote = "Before sleeping, you can release your fears and give yourself permission to rest." },
	{ es = "Dios mantiene en completa paz a quien confía en él y piensa en él.", en = "God keeps in perfect peace those who trust him and keep their minds on him.", esRef = "Isaías 26:3", enRef = "Isaiah 26:3", esNote = "Recordar quién es Dios ayuda a que el miedo no ocupe todo tu pensamiento.", enNote = "Remembering who God is helps keep fear from filling your whole mind." },
	{ es = "Quédense quietos y reconozcan que yo soy Dios.", en = "Be still and know that I am God.", esRef = "Salmos 46:10", enRef = "Psalms 46:10", esNote = "No todo se resuelve corriendo. A veces hace bien detenerte, respirar y recordar quién está al mando.", enNote = "Not everything is solved by rushing. Sometimes it helps to stop, breathe, and remember who is in control." },
	{ es = "Dios es mi roca, mi fortaleza y quien me rescata.", en = "God is my rock, my fortress, and the one who rescues me.", esRef = "Salmos 18:2", enRef = "Psalms 18:2", esNote = "Cuando todo parece inestable, necesitás un lugar firme donde apoyarte.", enNote = "When everything feels unsteady, you need firm ground to stand on." },
	{ es = "No estén tristes, porque la alegría que viene de Dios es su fuerza.", en = "Do not be sad, because the joy that comes from God is your strength.", esRef = "Nehemías 8:10", enRef = "Nehemiah 8:10", esNote = "La alegría también puede darte fuerzas para atravesar un día difícil.", enNote = "Joy can also give you strength to make it through a difficult day." },
	{ es = "Alégrense por la esperanza, sean pacientes en la dificultad y sigan orando.", en = "Rejoice in hope, be patient in trouble, and keep praying.", esRef = "Romanos 12:12", enRef = "Romans 12:12", esNote = "La esperanza, la paciencia y la oración te ayudan a no rendirte en el camino.", enNote = "Hope, patience, and prayer help you keep going on the journey." },
	{ es = "Quienes siembran con lágrimas cosecharán con alegría.", en = "Those who sow with tears will harvest with joy.", esRef = "Salmos 126:5", enRef = "Psalms 126:5", esNote = "Una etapa difícil no dura para siempre. Las lágrimas también pueden abrir paso a una nueva alegría.", enNote = "A hard season does not last forever. Tears can also make way for new joy." },
	{ es = "Dios dijo: Miren, estoy haciendo nuevas todas las cosas.", en = "God said: Look, I am making everything new.", esRef = "Apocalipsis 21:5", enRef = "Revelation 21:5", esNote = "Lo que parecía terminado puede recibir un nuevo comienzo.", enNote = "What seemed finished can receive a new beginning." },
	{ es = "Dios comenzó una buena obra en ustedes y la llevará hasta el final.", en = "God began a good work in you, and he will carry it through to completion.", esRef = "Filipenses 1:6", enRef = "Philippians 1:6", esNote = "Todavía estás creciendo. No te juzgues como si tu historia ya estuviera terminada.", enNote = "You are still growing. Do not judge yourself as if your story were already finished." },
	{ es = "Dios afirma los pasos de quien busca agradarle. Aunque caiga, no quedará tirado, porque Dios lo sostiene.", en = "God makes firm the steps of those who seek to please him. Even if they fall, God holds them up.", esRef = "Salmos 37:23-24", enRef = "Psalms 37:23-24", esNote = "Caerte no significa que todo terminó. Dios puede levantarte y enseñarte a seguir.", enNote = "Falling does not mean everything is over. God can lift you and teach you to continue." },
	{ es = "Que el Dios de la esperanza los llene de alegría y paz, para que rebosen de esperanza.", en = "May the God of hope fill you with joy and peace so that you overflow with hope.", esRef = "Romanos 15:13", enRef = "Romans 15:13", esNote = "La esperanza puede llenar tu corazón y también alcanzar a otras personas.", enNote = "Hope can fill your heart and also reach other people." },
	{ es = "No tengas miedo, porque yo te rescaté; te llamé por tu nombre: sos mío.", en = "Do not be afraid, because I rescued you; I called you by name: you are mine.", esRef = "Isaías 43:1", enRef = "Isaiah 43:1", esNote = "No sos un número ni alguien invisible. Tu nombre y tu historia importan.", enNote = "You are not a number or someone invisible. Your name and your story matter." },
	{ es = "Dios está en medio de vos y es poderoso para salvar. Se alegra por vos con amor.", en = "God is with you and is mighty to save. He rejoices over you with love.", esRef = "Sofonías 3:17", enRef = "Zephaniah 3:17", esNote = "No sos indiferente para Dios. Él te ve con amor y se alegra cuando te acercás.", enNote = "You are not unimportant to God. He sees you with love and rejoices when you come near." },
	{ es = "Cada cosa tiene su momento; hay un tiempo para todo lo que sucede bajo el cielo.", en = "There is a right time for everything that happens under heaven.", esRef = "Eclesiastés 3:1", enRef = "Ecclesiastes 3:1", esNote = "No todos los días se ven iguales. Aprender a vivir cada etapa con paciencia también es crecer.", enNote = "Not every day looks the same. Learning to live through each season patiently is also part of growing." },
	{ es = "No se preocupen por el mañana, porque el mañana traerá sus propias preocupaciones.", en = "Do not worry about tomorrow, because tomorrow will bring its own worries.", esRef = "Mateo 6:34", enRef = "Matthew 6:34", esNote = "Enfrentá el día de hoy. No cargues ahora con problemas que todavía no llegaron.", enNote = "Face today as it comes. Do not carry problems now that have not arrived yet." },
	{ es = "Aunque una persona justa caiga siete veces, vuelve a levantarse.", en = "Even if a righteous person falls seven times, they rise again.", esRef = "Proverbios 24:16", enRef = "Proverbs 24:16", esNote = "Caer no te convierte en un fracaso. Lo importante es levantarte y volver a intentarlo.", enNote = "Falling does not make you a failure. What matters is getting back up and trying again." },
	{ es = "Estén listos para escuchar, piensen antes de hablar y no se enojen enseguida.", en = "Be ready to listen, think before speaking, and do not become angry quickly.", esRef = "Santiago 1:19", enRef = "James 1:19", esNote = "Escuchar con atención puede evitar heridas y ayudarte a entender mejor a los demás.", enNote = "Listening carefully can prevent hurt and help you understand other people better." },
	{ es = "Que de su boca no salga nada que haga daño, sino palabras que ayuden y animen.", en = "Do not let harmful words come from your mouth, but words that help and encourage.", esRef = "Efesios 4:29", enRef = "Ephesians 4:29", esNote = "Antes de hablar, preguntate si tus palabras van a construir o a lastimar.", enNote = "Before speaking, ask whether your words are going to build someone up or hurt them." },
	{ es = "Anímense y ayúdense a crecer unos a otros.", en = "Encourage one another and help each other grow.", esRef = "1 Tesalonicenses 5:11", enRef = "1 Thessalonians 5:11", esNote = "A veces una frase sincera de aliento es justo lo que alguien necesita para seguir.", enNote = "Sometimes a sincere word of encouragement is exactly what someone needs to keep going." },
	{ es = "Dos personas trabajan mejor que una. Si una cae, la otra puede ayudarla a levantarse.", en = "Two people work better than one. If one falls, the other can help them up.", esRef = "Eclesiastés 4:9-10", enRef = "Ecclesiastes 4:9-10", esNote = "Aceptar ayuda no te hace débil. Hay caminos que se atraviesan mejor acompañado.", enNote = "Accepting help does not make you weak. Some roads are easier to cross with someone beside you." },
	{ es = "Así como el hierro afila el hierro, una persona ayuda a otra a mejorar.", en = "As iron sharpens iron, one person helps another improve.", esRef = "Proverbios 27:17", enRef = "Proverbs 27:17", esNote = "Los buenos amigos no solo te aplauden: también te ayudan a crecer con sinceridad.", enNote = "Good friends do not only cheer for you; they also help you grow honestly." },
	{ es = "Hagan todo lo posible por vivir en paz con todos.", en = "Do everything you can to live at peace with everyone.", esRef = "Romanos 12:18", enRef = "Romans 12:18", esNote = "No podés controlar la reacción de los demás, pero sí elegir actuar con paz y respeto.", enNote = "You cannot control how others react, but you can choose to act with peace and respect." },
	{ es = "No hagan nada por orgullo. Con humildad, valoren también a los demás.", en = "Do nothing out of pride. With humility, value other people too.", esRef = "Filipenses 2:3-4", enRef = "Philippians 2:3-4", esNote = "Ser humilde no es pensar que valés menos; es recordar que los demás también importan.", enNote = "Being humble does not mean thinking you are worth less; it means remembering others matter too." },
	{ es = "Pensemos cómo animarnos unos a otros a amar y hacer el bien.", en = "Let us think about how to encourage one another to love and do good.", esRef = "Hebreos 10:24", enRef = "Hebrews 10:24", esNote = "Una buena comunidad no empuja hacia abajo: ayuda a cada persona a sacar lo mejor de sí.", enNote = "A good community does not push people down; it helps each person bring out their best." },
	{ es = "La persona generosa prosperará; quien ayuda a otros también será ayudado.", en = "A generous person will prosper; whoever helps others will also be helped.", esRef = "Proverbios 11:25", enRef = "Proverbs 11:25", esNote = "Compartir tiempo, ayuda o cariño también llena el corazón de quien da.", enNote = "Sharing time, help, or care also fills the heart of the person who gives." },
	{ es = "Hay más felicidad en dar que en recibir.", en = "There is more happiness in giving than in receiving.", esRef = "Hechos 20:35", enRef = "Acts 20:35", esNote = "Dar con amor puede convertir algo pequeño en una alegría enorme para otra persona.", enNote = "Giving with love can turn something small into great joy for another person." },
	{ es = "Un corazón alegre hace bien como una medicina, pero el desánimo quita las fuerzas.", en = "A joyful heart is good medicine, but discouragement drains your strength.", esRef = "Proverbios 17:22", enRef = "Proverbs 17:22", esNote = "Cuidar la alegría no significa negar los problemas; significa no dejar que apaguen todo lo bueno.", enNote = "Protecting your joy does not mean denying problems; it means not letting them erase everything good." },
	{ es = "Hagan todo con amor.", en = "Do everything with love.", esRef = "1 Corintios 16:14", enRef = "1 Corinthians 16:14", esNote = "Que este sea el final y también el comienzo: llevá amor a todo lo que hagas.", enNote = "Let this be both the ending and the beginning: carry love into everything you do." },
}
State.bibleWords = WORDS
do
    local data={
    {"1 Juan 1:9","Se confessarmos nossos pecados a Deus, ele é fiel: nos perdoa e nos limpa de toda maldade.","Você pode falar com Deus com sinceridade e começar de novo.","إذا اعترفنا بخطايانا لله، فهو أمين: يغفر لنا ويطهرنا من كل شر.","يمكنك أن تتحدث مع الله بصدق وتبدأ من جديد."},
    {"Salmos 103:12","Deus afasta nossos pecados para tão longe quanto o leste está do oeste.","O perdão de Deus oferece um novo começo, sem viver preso à culpa.","يبعد الله عنا خطايانا كما يبتعد المشرق عن المغرب.","يمنحك غفران الله بداية جديدة، فلا تعش أسيرًا للذنب."},
    {"Isaías 1:18","Mesmo que seus pecados sejam vermelhos como sangue, Deus pode torná-los brancos como a neve.","A misericórdia de Deus abre espaço para o arrependimento e o perdão.","حتى إن كانت خطاياكم حمراء كالدم، يستطيع الله أن يجعلها بيضاء كالثلج.","رحمة الله تفتح باب التوبة والغفران."},
    {"Miqueas 7:19","Deus volta a ter compaixão, vence nossa maldade e lança nossos pecados no fundo do mar.","Você pode deixar a culpa para trás e buscar uma vida diferente.","يعود الله فيرحمنا، ويغلب شرنا، ويلقي خطايانا في أعماق البحر.","يمكنك أن تترك الذنب وراءك وتسعى إلى حياة مختلفة."},
    {"Juan 3:16","Deus amou tanto o mundo que deu seu único Filho, para que quem crê nele tenha vida eterna.","Esse amor também alcança você. Em Jesus há vida e esperança.","أحب الله العالم حتى بذل ابنه الوحيد، لكي تكون لكل من يؤمن به حياة أبدية.","هذا الحب يشملك أيضًا. في يسوع حياة ورجاء."},
    {"Romanos 5:8","Deus demonstra seu amor: quando ainda éramos pecadores, Cristo morreu por nós.","Deus não esperou que você fosse perfeito para amar você.","يُظهر الله محبته لنا: فبينما كنا خطاة، مات المسيح من أجلنا.","لم ينتظر الله أن تكون كاملًا حتى يحبك."},
    {"Romanos 8:1","Para quem está em Cristo Jesus, já não há condenação.","Seu passado não precisa decidir quem você é ou como sua história termina.","ليس على الذين هم في المسيح يسوع أي حكم بالدينونة.","ليس على ماضيك أن يحدد من أنت أو كيف تنتهي قصتك."},
    {"2 Corintios 5:17","Quem está unido a Cristo é uma nova pessoa: o que era velho passou e uma nova vida começou.","Com Jesus, existe a possibilidade de recomeçar.","من يتحد بالمسيح يصبح إنسانًا جديدًا؛ مضى القديم وبدأت حياة جديدة.","مع يسوع توجد فرصة للبداية من جديد."},
    {"1 Juan 4:9","Deus mostrou quanto nos ama ao enviar seu Filho, para que tivéssemos vida por meio dele.","O amor se mostra em atitudes, não apenas em palavras.","أظهر الله مقدار حبه لنا بإرسال ابنه، لكي نحيا به.","يظهر الحب في الأفعال، لا في الكلمات وحدها."},
    {"1 Juan 4:18","O amor perfeito de Deus expulsa o medo.","Lembrar que você é amado pode trazer calma ao coração.","محبة الله الكاملة تطرد الخوف.","تذكّر أنك محبوب، فهذا قد يمنح قلبك الطمأنينة."},
    {"Mateo 11:28","Venham a mim todos vocês que estão cansados e carregam grandes pesos, e eu lhes darei descanso.","Você não precisa carregar tudo sozinho. Pode levar seu cansaço a Jesus.","تعالوا إليّ يا جميع المتعبين والمثقلين بالأحمال، وأنا أريحكم.","ليس عليك أن تحمل كل شيء وحدك. يمكنك أن تأتي بتعبك إلى يسوع."},
    {"Salmos 34:18","Deus está perto de quem tem o coração partido e socorre quem perdeu o ânimo.","Sentir dor não significa estar abandonado.","الله قريب من أصحاب القلوب المنكسرة، وينقذ من فقدوا الأمل.","شعورك بالألم لا يعني أنك متروك وحدك."},
    {"Salmos 147:3","Deus cura os corações partidos e cuida de suas feridas.","Ele vê a dor que os outros não conseguem enxergar.","يشفي الله القلوب المنكسرة ويعتني بجراحها.","يرى الله الألم الذي لا يستطيع الآخرون رؤيته."},
    {"Isaías 41:10","Não tenha medo, pois estou com você. Eu lhe darei forças, ajudarei e sustentarei você.","Você não está sozinho diante das dificuldades.","لا تخف، فأنا معك. سأقويك وأساعدك وأسندك.","أنت لست وحدك أمام الصعوبات."},
    {"Josué 1:9","Seja forte e corajoso. Não tenha medo, pois Deus estará com você aonde quer que vá.","É possível seguir em frente mesmo quando o caminho é novo.","كن قويًا وشجاعًا. لا تخف، لأن الله سيكون معك أينما ذهبت.","يمكنك أن تتقدم حتى عندما يكون الطريق جديدًا عليك."},
    {"Deuteronomio 31:8","Deus irá à sua frente. Ele não deixará nem abandonará você; não tenha medo.","Antes de você chegar à dificuldade, Deus já conhece o caminho.","الله يسير أمامك. لن يتركك أو يتخلى عنك، فلا تخف.","قبل أن تصل إلى الصعوبة، يعرف الله الطريق."},
    {"Salmos 23:4","Mesmo que eu caminhe pelo vale mais escuro, não terei medo, pois tu estás comigo.","O momento escuro não precisa ser o fim da caminhada.","حتى إن سرت في أشد الأودية ظلامًا، فلن أخاف، لأنك معي.","اللحظة المظلمة ليست بالضرورة نهاية الطريق."},
    {"Salmos 27:1","Deus é minha luz e minha salvação; de quem terei medo?","A confiança em Deus ajuda a não deixar o medo decidir tudo.","الله نوري وخلاصي، فممن أخاف؟","الثقة بالله تساعدك ألا تدع الخوف يقرر كل شيء."},
    {"Salmos 27:3","Mesmo que um exército acampe contra mim, meu coração não terá medo; mesmo que a guerra se levante contra mim, continuarei confiante.","A fé não nega a batalha: ajuda o coração a permanecer firme.","حتى إن نزل عليّ جيش، فلن يخاف قلبي؛ وحتى إن قامت عليّ حرب، سأبقى واثقًا.","الإيمان لا ينكر المعركة، بل يساعد القلب على الثبات خلالها."},
    {"Salmos 46:1","Deus é nosso refúgio e nossa força, sempre presente para ajudar nas dificuldades.","Quando tudo parece instável, você pode procurar apoio em Deus.","الله ملجؤنا وقوتنا، وعون حاضر في الشدائد.","حين يبدو كل شيء مضطربًا، يمكنك أن تطلب العون من الله."},
    {"Salmos 55:22","Entregue suas cargas a Deus, e ele sustentará você.","Você pode pedir ajuda quando sentir que suas forças acabaram.","ألقِ أحمالك على الله، وهو يسندك.","يمكنك أن تطلب العون عندما تشعر أن قوتك قد نفدت."},
    {"1 Pedro 5:7","Deixem todas as suas preocupações com Deus, pois ele cuida de vocês.","O que preocupa você também importa para Deus.","ألقوا كل همومكم على الله، فهو يعتني بكم.","ما يقلقك مهم عند الله أيضًا."},
    {"Juan 14:27","Jesus diz: Deixo com vocês a minha paz. Não tenham medo nem se aflijam.","A paz de Jesus pode acompanhar você mesmo em dias difíceis.","يقول يسوع: أترك لكم سلامي. فلا تخافوا ولا تضطرب قلوبكم.","سلام يسوع يستطيع أن يرافقك حتى في الأيام الصعبة."},
    {"Filipenses 4:6-7","Não vivam dominados pela preocupação. Falem com Deus sobre tudo, com gratidão, e sua paz guardará seus corações.","Você pode transformar a preocupação em uma conversa sincera com Deus.","لا تعيشوا أسرى القلق. تحدثوا مع الله عن كل شيء بشكر، وسلامه يحفظ قلوبكم.","يمكنك أن تحوّل قلقك إلى حديث صادق مع الله."},
    {"Filipenses 4:13","Posso enfrentar cada situação com Cristo, pois ele me dá forças.","Cristo fortalece você para atravessar as diferentes fases da vida.","أستطيع مواجهة كل ظرف بالمسيح، لأنه يمنحني القوة.","يقويك المسيح لتجتاز مراحل الحياة المختلفة."},
    {"2 Corintios 12:9","Minha graça é suficiente para você, pois meu poder se mostra melhor na fraqueza.","Estar fraco não torna você inútil nem sem valor.","نعمتي تكفيك، لأن قوتي تظهر في الضعف.","كونك ضعيفًا لا يجعلك بلا فائدة أو قيمة."},
    {"Romanos 8:28","Deus age em todas as coisas para o bem de quem o ama.","Mesmo uma fase dolorosa pode fazer parte de um caminho de crescimento.","يعمل الله في كل الأمور لخير الذين يحبونه.","حتى المرحلة المؤلمة قد تصبح جزءًا من طريق للنمو."},
    {"Jeremías 29:11","Deus tem pensamentos de paz, para dar esperança e um futuro.","Quando você não vê o caminho todo, ainda pode buscar direção e esperança.","لدى الله أفكار سلام، ليمنح رجاءً ومستقبلًا.","حين لا ترى الطريق كاملًا، يمكنك أن تطلب الإرشاد والرجاء."},
    {"Lamentaciones 3:22-23","O amor fiel de Deus não acaba; sua misericórdia se renova a cada manhã.","Um novo dia traz a oportunidade de recomeçar.","محبة الله الأمينة لا تنتهي؛ وتتجدد رحمته كل صباح.","اليوم الجديد يحمل فرصة للبداية من جديد."},
    {"Salmos 30:5","O choro pode durar uma noite, mas a alegria chega pela manhã.","A dor é real, mas a alegria pode voltar.","قد يستمر البكاء ليلًا، لكن الفرح يأتي في الصباح.","الألم حقيقي، لكن الفرح يستطيع أن يعود."},
    {"Gálatas 6:9","Não se cansem de fazer o bem. No tempo certo, colherão, se não desistirem.","Fazer o bem vale a pena, mesmo quando o resultado demora.","لا تملّوا من فعل الخير، ففي الوقت المناسب تحصدون إن لم تستسلموا.","فعل الخير يستحق العناء، حتى إن تأخرت النتيجة."},
    {"Apocalipsis 21:4","Deus enxugará cada lágrima. Não haverá mais morte, choro nem dor.","A esperança cristã aponta para uma vida em que o sofrimento não vence.","سيمسح الله كل دمعة، ولن يكون موت أو بكاء أو ألم.","يشير الرجاء المسيحي إلى حياة لا ينتصر فيها الألم."},
    {"Salmos 37:5","Coloque seu caminho nas mãos de Deus, confie nele, e ele agirá.","Confiar também é entregar suas decisões e continuar caminhando.","سلّم طريقك إلى الله، وثق به، وهو يعمل.","الثقة تعني أيضًا أن تسلّم قراراتك وتواصل السير."},
    {"Proverbios 3:5-6","Confie em Deus de todo o coração; ele mostrará o caminho certo.","Você não precisa entender tudo para buscar o próximo passo.","ثق بالله من كل قلبك، وهو يريك الطريق المستقيم.","لا تحتاج إلى فهم كل شيء لكي تبحث عن الخطوة التالية."},
    {"Proverbios 16:3","Entregue a Deus tudo o que fizer, e seus planos poderão se firmar.","Leve a Deus seus projetos e escolhas desde o começo.","سلّم إلى الله كل ما تعمل، فتثبت خططك.","شارك الله مشروعاتك واختياراتك منذ البداية."},
    {"Salmos 121:1-2","Minha ajuda vem de Deus, que fez o céu e a terra.","Você não precisa depender apenas das próprias forças.","عونِي من الله، خالق السماء والأرض.","لست مضطرًا إلى الاعتماد على قوتك وحدها."},
    {"Isaías 40:31","Quem confia em Deus renova suas forças; voa como águia e corre sem desistir.","Esperar com fé pode trazer forças para continuar.","الذين يثقون بالله تتجدد قوتهم؛ يحلقون كالنسور ويركضون دون أن يستسلموا.","الانتظار بإيمان قد يمنحك قوة لمواصلة الطريق."},
    {"Salmos 91:1-2","Quem vive sob o cuidado do Altíssimo pode dizer: Deus é meu refúgio e meu lugar seguro.","Em Deus você pode encontrar apoio quando o mundo parece inseguro.","من يعيش في رعاية العلي يستطيع أن يقول: الله ملجئي ومكاني الآمن.","تستطيع أن تجد سندًا في الله حين يبدو العالم غير آمن."},
    {"Salmos 56:3","Quando eu sentir medo, confiarei em ti.","Ter fé não é nunca sentir medo; é escolher confiar apesar dele.","عندما أخاف، أتكل عليك.","الإيمان ليس غياب الخوف، بل اختيار الثقة رغم وجوده."},
    {"Juan 16:33","No mundo vocês terão dificuldades. Mas tenham coragem: eu venci o mundo.","Jesus reconhece a dificuldade da vida e encoraja você a continuar.","في العالم ستواجهون صعوبات. لكن تشجعوا: أنا قد غلبت العالم.","يعترف يسوع بصعوبة الحياة ويشجعك على الاستمرار."},
    {"Romanos 8:38-39","Nada poderá nos separar do amor que Deus mostrou em Cristo Jesus.","O medo e os erros não apagam esse amor.","لا شيء يستطيع أن يفصلنا عن المحبة التي أظهرها الله في المسيح يسوع.","الخوف والأخطاء لا يمحوان هذه المحبة."},
    {"Salmos 139:14","Eu te agradeço porque fui criado de maneira maravilhosa.","Sua vida tem valor. Você não é uma cópia de outra pessoa.","أشكرك لأنني خُلقت بطريقة عجيبة.","لحياتك قيمة. أنت لست نسخة من شخص آخر."},
    {"Efesios 2:10","Somos obra de Deus, criados para fazer o bem que ele preparou para nós.","Você pode usar seus dons e sua história para ajudar.","نحن صنع الله، خُلقنا لفعل الخير الذي أعده لنا.","يمكنك أن تستخدم مواهبك وتجاربك لمساعدة الآخرين."},
    {"Efesios 4:32","Sejam bondosos e compassivos; perdoem uns aos outros como Deus perdoou vocês.","A fé também aparece na maneira de tratar quem está perto.","كونوا لطفاء ورحماء، واغفروا بعضكم لبعض كما غفر الله لكم.","يظهر الإيمان أيضًا في طريقة معاملتك لمن حولك."},
    {"Colosenses 3:13","Tenham paciência e perdoem quando alguém os ofender, assim como Cristo perdoou vocês.","Perdoar não aprova o dano; ajuda a não viver preso ao rancor.","اصبروا واغفروا حين يسيء إليكم أحد، كما غفر لكم المسيح.","الغفران لا يبرر الأذى، بل يساعدك ألا تعيش أسيرًا للحقد."},
    {"Proverbios 17:17","Um amigo ama em todos os momentos e, na dificuldade, torna-se como um irmão.","Amizade verdadeira também é ficar por perto quando a vida complica.","الصديق يحب في كل وقت، وفي الشدة يصبح كالأخ.","الصداقة الحقيقية تعني البقاء قريبًا حين تصعب الحياة."},
    {"Romanos 8:31","Se Deus é por nós, quem será contra nós?","Você não enfrenta a vida sozinho: Deus está ao seu lado mesmo quando o caminho fica difícil.","إن كان الله معنا، فمن علينا؟","أنت لا تواجه الحياة وحدك؛ فالله معك حتى عندما يصبح الطريق صعبًا."},
    {"Mateo 5:14-16","Vocês são a luz do mundo. Deixem sua luz aparecer e ajudar outras pessoas.","Uma boa atitude pode levar esperança a quem precisa.","أنتم نور العالم. دعوا نوركم يظهر ويساعد الآخرين.","قد يحمل تصرف طيب الرجاء إلى شخص يحتاج إليه."},
    {"Lucas 1:37","Para Deus, nada é impossível.","Quando você não vê saída, ainda pode ter esperança.","ليس عند الله شيء مستحيل.","حين لا ترى مخرجًا، لا يزال بإمكانك أن ترجو."},
    {"Números 6:24-26","Que Deus abençoe e cuide de você; que olhe para você com amor e lhe dê paz.","Essa bênção deseja cuidado, proximidade e paz para sua caminhada.","ليباركك الله ويحفظك، وينظر إليك بمحبة ويمنحك السلام.","هذه البركة تتمنى لك الرعاية والقرب والسلام في طريقك."},
    {"Génesis 1:27","Deus criou os seres humanos à sua imagem; criou homem e mulher.","Toda vida humana merece dignidade e respeito.","خلق الله البشر على صورته، ذكرًا وأنثى خلقهم.","كل حياة بشرية تستحق الكرامة والاحترام."},
    {"Salmos 139:13","Tu formaste todo o meu corpo e me fizeste no ventre da minha mãe.","Cada parte de você merece cuidado e respeito.","أنت كوّنت جسدي كله وصنعتني في رحم أمي.","كل جزء منك يستحق الرعاية والاحترام."},
    {"Proverbios 4:23","Acima de tudo, cuide do seu coração, pois dele nasce seu modo de viver.","O que você alimenta na mente influencia suas atitudes.","احفظ قلبك قبل كل شيء، فمنه تنبع طريقة حياتك.","ما تغذّي به ذهنك يؤثر في تصرفاتك."},
    {"Proverbios 12:25","A preocupação pesa no coração, mas uma palavra boa traz alegria.","Uma frase gentil pode mudar o dia de alguém.","الهم يثقل القلب، والكلمة الطيبة تجلب الفرح.","قد تغيّر كلمة لطيفة يوم شخص آخر."},
    {"Proverbios 16:24","Palavras gentis são como mel: doces para a alma e boas para o corpo.","Use suas palavras para cuidar e encorajar, não para ferir.","الكلمات اللطيفة كالعسل، حلوة للنفس ونافعة للجسد.","استخدم كلماتك للرعاية والتشجيع، لا للجرح."},
    {"Colosenses 3:23","Tudo o que fizerem, façam de coração, como para Deus e não apenas para as pessoas.","Fazer bem o que é pequeno importa, mesmo quando ninguém vê.","كل ما تفعلونه، افعلوه من القلب، كأنكم تعملون لله لا للناس فقط.","إتقان الأمور الصغيرة مهم، حتى إن لم يرك أحد."},
    {"Lucas 6:31","Tratem os outros como gostariam de ser tratados.","Antes de agir, pense em como você se sentiria no lugar do outro.","عاملوا الآخرين كما تحبون أن يعاملوكم.","قبل أن تتصرف، فكّر كيف ستشعر لو كنت مكان الآخر."},
    {"1 Corintios 13:4-5","O amor é paciente e bondoso; não tem inveja, não se orgulha e não procura machucar.","O amor aparece na paciência e no cuidado com o outro.","المحبة صبورة ولطيفة؛ لا تحسد ولا تتكبر ولا تسعى إلى الأذى.","يظهر الحب في الصبر والعناية بالآخر."},
    {"Juan 13:34","Amem uns aos outros. Assim como eu amei vocês, também devem amar uns aos outros.","Amar como Jesus é agir com paciência, ajuda e carinho.","أحبوا بعضكم بعضًا. كما أحببتكم، أحبوا أنتم أيضًا بعضكم بعضًا.","أن تحب مثل يسوع يعني أن تتصرف بصبر وعون وحنان."},
    {"Mateo 22:37-39","Ame a Deus de todo o coração e ame seu próximo como a si mesmo.","Jesus colocou o amor a Deus e às pessoas no centro da vida.","أحب الله من كل قلبك، وأحب قريبك كنفسك.","جعل يسوع محبة الله والناس في قلب الحياة."},
    {"Romanos 12:21","Não deixe o mal vencer você; vença o mal fazendo o bem.","Você pode escolher não continuar a corrente de sofrimento.","لا تدع الشر يغلبك، بل اغلب الشر بفعل الخير.","يمكنك أن تختار ألا تواصل سلسلة الأذى."},
    {"Miqueas 6:8","Deus pede que você pratique a justiça, ame a misericórdia e caminhe com humildade ao lado dele.","Faça o que é certo sem perder a compaixão nem se achar superior.","يطلب الله منك أن تعمل بالعدل، وتحب الرحمة، وتسير معه بتواضع.","افعل الصواب دون أن تفقد الرحمة أو ترى نفسك أعلى من غيرك."},
    {"Santiago 1:5","Se alguém precisa de sabedoria, peça a Deus, que dá com generosidade.","Você pode pedir clareza quando não souber o que fazer.","من يحتاج إلى الحكمة فليطلبها من الله، الذي يعطي بسخاء.","يمكنك أن تطلب الوضوح عندما لا تعرف ماذا تفعل."},
    {"Salmos 119:105","Tua palavra é uma lâmpada para meus pés e uma luz para meu caminho.","A Bíblia pode iluminar a próxima escolha, mesmo sem mostrar a estrada inteira.","كلمتك مصباح لقدمي ونور لطريقي.","قد يضيء الكتاب المقدس اختيارك التالي، حتى إن لم تر الطريق كله."},
    {"Salmos 56:8","Tu conheces minhas tristezas e guardas cada uma das minhas lágrimas.","Sua tristeza não é invisível. Cada lágrima importa.","أنت تعرف أحزاني وتحفظ كل دمعة من دموعي.","حزنك ليس خفيًا. لكل دمعة أهمية."},
    {"Isaías 49:15-16","Mesmo que uma mãe pudesse esquecer seu filho, eu nunca esquecerei você; seu nome está gravado em minhas mãos.","Sentir-se esquecido não significa que sua vida deixou de importar.","حتى إن نسيت أم طفلها، فأنا لن أنساك؛ لقد نقشتك على كفّي.","شعورك بأنك منسي لا يعني أن حياتك فقدت أهميتها."},
    {"Mateo 5:4","Felizes os que choram, pois serão consolados.","Chorar não faz de você alguém fraco. Há espaço para o consolo.","طوبى للحزانى، لأنهم سيتعزّون.","البكاء لا يجعلك ضعيفًا. يوجد مكان للعزاء."},
    {"2 Corintios 1:3-4","Deus nos consola em nossas dificuldades, para que também possamos consolar outras pessoas.","O cuidado que você recebe pode se transformar em ajuda para alguém.","يعزّينا الله في صعوباتنا، لكي نستطيع أن نعزّي غيرنا.","العناية التي تتلقاها قد تتحول إلى عون لشخص آخر."},
    {"Salmos 40:1-2","Esperei com paciência por Deus. Ele me ouviu, tirou-me do poço e firmou meus pés sobre uma rocha.","Mesmo que a saída demore, é possível encontrar firmeza e recomeçar.","انتظرت الله بصبر، فسمعني وأخرجني من الحفرة وثبّت قدمي على صخرة.","حتى إن تأخر المخرج، يمكنك أن تجد الثبات وتبدأ من جديد."},
    {"Salmos 118:6","O Senhor está comigo; não temerei. O que pode o homem fazer contra mim?","Você não enfrenta o medo sozinho: Deus permanece ao seu lado.","الرب معي فلا أخاف. ماذا يصنع بي الإنسان؟","أنت لا تواجه الخوف وحدك؛ فالله باقٍ إلى جانبك."},
    {"Isaías 43:2","Quando você atravessar as águas, estarei com você; quando passar pelo fogo, ele não o queimará.","A promessa não é a ausência de dificuldades, mas a presença de Deus nelas.","عندما تعبر المياه، أكون معك؛ وعندما تمر بالنار، لن تحرقك.","الوعد ليس غياب الصعوبات، بل حضور الله معك فيها."},
    {"Salmos 62:8","Confiem sempre em Deus e abram seu coração diante dele; Deus é nosso refúgio.","Orar é falar com sinceridade, mesmo sobre o que é difícil explicar.","ثقوا بالله دائمًا وافتحوا قلوبكم أمامه؛ فالله ملجؤنا.","الصلاة حديث صادق، حتى عما يصعب شرحه."},
    {"Salmos 4:8","Em paz me deitarei e dormirei, pois só tu, Deus, me fazes viver em segurança.","Antes de dormir, você pode soltar os temores e permitir-se descansar.","بسلام أستلقي وأنام، لأنك وحدك، يا الله، تمنحني الأمان.","قبل النوم، يمكنك أن تترك مخاوفك وتسمح لنفسك بالراحة."},
    {"Isaías 26:3","Deus mantém em paz quem confia nele e volta seus pensamentos para ele.","Lembrar de Deus pode ajudar a não deixar o medo ocupar a mente inteira.","يحفظ الله في سلام من يثق به ويوجّه أفكاره إليه.","تذكّر الله قد يساعدك ألا تدع الخوف يملأ ذهنك كله."},
    {"Salmos 46:10","Aquietem-se e reconheçam que eu sou Deus.","Às vezes, faz bem parar, respirar e não tentar resolver tudo correndo.","اهدأوا واعلموا أني أنا الله.","أحيانًا يفيدك أن تتوقف وتتنفس، بدل محاولة حل كل شيء بعجلة."},
    {"Salmos 18:2","Deus é minha rocha, minha fortaleza e quem me resgata.","Quando tudo parece instável, você pode buscar um apoio firme.","الله صخرتي وحصني ومن ينقذني.","حين يبدو كل شيء غير ثابت، يمكنك أن تطلب سندًا راسخًا."},
    {"Nehemías 8:10","Não fiquem tristes, pois a alegria que vem de Deus é a força de vocês.","A alegria também pode dar forças para enfrentar um dia difícil.","لا تحزنوا، لأن الفرح الآتي من الله هو قوتكم.","قد يمنحك الفرح أيضًا قوة لمواجهة يوم صعب."},
    {"Romanos 12:12","Alegrem-se na esperança, tenham paciência na dificuldade e continuem orando.","Esperança, paciência e oração ajudam a continuar.","افرحوا بالرجاء، واصبروا في الشدة، وواظبوا على الصلاة.","الرجاء والصبر والصلاة تساعدك على الاستمرار."},
    {"Salmos 126:5","Quem semeia com lágrimas colherá com alegria.","Uma fase dolorosa não precisa ser o fim da sua história.","الذين يزرعون بالدموع يحصدون بالفرح.","ليس على المرحلة المؤلمة أن تكون نهاية قصتك."},
    {"Apocalipsis 21:5","Deus disse: Vejam, estou fazendo novas todas as coisas.","Aquilo que parecia terminado pode receber um novo começo.","قال الله: انظروا، أنا أجعل كل شيء جديدًا.","ما بدا منتهيًا قد يجد بداية جديدة."},
    {"Filipenses 1:6","Deus começou uma boa obra em vocês e vai levá-la até o fim.","Você ainda está crescendo. Não se julgue como se sua história já tivesse acabado.","بدأ الله فيكم عملًا صالحًا، وسيكمله إلى النهاية.","أنت ما زلت تنمو. لا تحكم على نفسك كأن قصتك انتهت."},
    {"Salmos 37:23-24","Deus firma os passos de quem busca agradá-lo. Mesmo que caia, não ficará no chão, pois Deus o sustenta.","Cair não significa que tudo acabou. É possível levantar e aprender.","يثبت الله خطوات من يسعى إلى إرضائه. وإن سقط، لا يبقى مطروحًا، لأن الله يسنده.","السقوط لا يعني أن كل شيء انتهى. يمكنك أن تقوم وتتعلم."},
    {"Romanos 15:13","Que o Deus da esperança encha vocês de alegria e paz, para que transbordem de esperança.","A esperança pode alcançar seu coração e também outras pessoas.","ليملأكم إله الرجاء فرحًا وسلامًا، حتى تفيضوا بالرجاء.","الرجاء يستطيع أن يملأ قلبك ويصل إلى الآخرين أيضًا."},
    {"Isaías 43:1","Não tenha medo, pois eu resgatei você; chamei você pelo nome: você é meu.","Você não é um número. Seu nome e sua história importam.","لا تخف، فأنا افتديتك؛ دعوتك باسمك: أنت لي.","أنت لست رقمًا. لاسمك وقصتك أهمية."},
    {"Sofonías 3:17","Deus está com você e é poderoso para salvar. Ele se alegra por você com amor.","Você não é indiferente para Deus; é visto com amor.","الله معك، وهو قادر على الخلاص. يفرح بك بمحبة.","أنت لست بلا أهمية عند الله؛ فهو ينظر إليك بمحبة."},
    {"Eclesiastés 3:1","Há um momento certo para tudo o que acontece debaixo do céu.","Cada fase é diferente. Viver com paciência também é crescer.","لكل شيء وقت مناسب تحت السماء.","كل مرحلة مختلفة. والتعامل معها بصبر جزء من النمو."},
    {"Mateo 6:34","Não se preocupem com o amanhã, pois ele trará suas próprias preocupações.","Cuide do dia de hoje sem carregar agora problemas que ainda não chegaram.","لا تقلقوا بشأن الغد، فله همومه الخاصة.","اهتم بيومك دون أن تحمل الآن مشكلات لم تأتِ بعد."},
    {"Proverbios 24:16","Mesmo que uma pessoa justa caia sete vezes, ela se levanta novamente.","Cair não faz de você um fracasso. Você pode tentar outra vez.","حتى إن سقط الإنسان الصالح سبع مرات، فإنه يقوم من جديد.","السقوط لا يجعلك فاشلًا. يمكنك أن تحاول مرة أخرى."},
    {"Santiago 1:19","Estejam prontos para ouvir, pensem antes de falar e não se irritem depressa.","Ouvir com atenção ajuda a entender e evita machucar.","كونوا مستعدين للاستماع، وفكّروا قبل الكلام، ولا تغضبوا سريعًا.","الإصغاء باهتمام يساعد على الفهم ويمنع الجرح."},
    {"Efesios 4:29","Não deixem sair da boca palavras que machucam, mas palavras que ajudam e encorajam.","Antes de falar, pense se suas palavras vão construir ou ferir.","لا تخرج من أفواهكم كلمات تؤذي، بل كلمات تساعد وتشجع.","قبل الكلام، فكّر هل ستبني كلماتك أم ستجرح."},
    {"1 Tesalonicenses 5:11","Encorajem uns aos outros e ajudem uns aos outros a crescer.","Uma palavra sincera de apoio pode ser o que alguém precisa.","شجعوا بعضكم بعضًا، وساعدوا بعضكم على النمو.","قد تكون كلمة دعم صادقة هي ما يحتاج إليه شخص آخر."},
    {"Eclesiastés 4:9-10","Duas pessoas trabalham melhor do que uma. Se uma cair, a outra pode ajudá-la a levantar.","Aceitar ajuda não é fraqueza. Há caminhos melhores quando compartilhados.","اثنان يعملان أفضل من واحد. إن سقط أحدهما، يساعده الآخر على النهوض.","قبول المساعدة ليس ضعفًا. بعض الطرق أفضل بصحبة الآخرين."},
    {"Proverbios 27:17","Assim como o ferro afia o ferro, uma pessoa ajuda outra a melhorar.","Um bom amigo também ajuda você a crescer com sinceridade.","كما يشحذ الحديد الحديد، يساعد الإنسان غيره على التحسن.","الصديق الجيد يساعدك أيضًا على النمو بصدق."},
    {"Romanos 12:18","Façam tudo o que puderem para viver em paz com todos.","Você não controla a reação dos outros, mas pode agir com respeito.","ابذلوا كل ما تستطيعون لتعيشوا بسلام مع الجميع.","لا تتحكم في ردود أفعال الآخرين، لكن يمكنك التصرف باحترام."},
    {"Filipenses 2:3-4","Não ajam por orgulho. Com humildade, deem valor também às outras pessoas.","Humildade não é valer menos; é lembrar que os outros também importam.","لا تتصرفوا بدافع الكبرياء. بتواضع، قدّروا الآخرين أيضًا.","التواضع ليس أن تقلل من قيمتك، بل أن تتذكر قيمة الآخرين."},
    {"Hebreos 10:24","Pensemos em como encorajar uns aos outros a amar e fazer o bem.","Uma boa comunidade ajuda cada pessoa a crescer.","لنفكر كيف نشجع بعضنا بعضًا على المحبة وفعل الخير.","المجتمع الطيب يساعد كل شخص على النمو."},
    {"Proverbios 11:25","A pessoa generosa prospera; quem ajuda os outros também recebe ajuda.","Compartilhar tempo, cuidado e apoio faz bem a quem recebe e a quem dá.","الإنسان الكريم يزدهر، ومن يساعد غيره يجد العون أيضًا.","مشاركة الوقت والرعاية والدعم تنفع من يتلقاها ومن يقدمها."},
    {"Hechos 20:35","Há mais felicidade em dar do que em receber.","Um gesto pequeno feito com amor pode trazer muita alegria.","في العطاء سعادة أكثر من الأخذ.","قد تحمل لفتة صغيرة بمحبة فرحًا كبيرًا."},
    {"Proverbios 17:22","Um coração alegre faz bem como remédio, mas o desânimo tira as forças.","Cuidar da alegria não é negar os problemas; é preservar o que faz bem.","القلب الفرح نافع كالدواء، والإحباط يستنزف القوة.","حماية الفرح ليست إنكارًا للمشكلات، بل حفاظًا على ما ينفعك."},
    {"1 Corintios 16:14","Façam tudo com amor.","Leve esse cuidado para o que você faz todos os dias.","افعلوا كل شيء بمحبة.","احمل هذه العناية إلى كل ما تفعله كل يوم."},
}
    local books={
        {"Salmos","Salmos","المزامير"},{"Juan","João","يوحنا"},{"Isaías","Isaías","إشعياء"},
        {"Miqueas","Miqueias","ميخا"},{"Romanos","Romanos","رومية"},{"Corintios","Coríntios","كورنثوس"},
        {"Mateo","Mateus","متى"},{"Josué","Josué","يشوع"},{"Deuteronomio","Deuteronômio","التثنية"},
        {"Pedro","Pedro","بطرس"},{"Filipenses","Filipenses","فيلبي"},{"Jeremías","Jeremias","إرميا"},
        {"Lamentaciones","Lamentações","مراثي إرميا"},{"Gálatas","Gálatas","غلاطية"},{"Apocalipsis","Apocalipse","الرؤيا"},
        {"Proverbios","Provérbios","الأمثال"},{"Efesios","Efésios","أفسس"},{"Colosenses","Colossenses","كولوسي"},
        {"Lucas","Lucas","لوقا"},{"Números","Números","العدد"},{"Génesis","Gênesis","التكوين"},
        {"Santiago","Tiago","يعقوب"},{"Nehemías","Neemias","نحميا"},{"Sofonías","Sofonias","صفنيا"},
        {"Eclesiastés","Eclesiastes","الجامعة"},{"Tesalonicenses","Tessalonicenses","تسالونيكي"},
        {"Hebreos","Hebreus","العبرانيين"},{"Hechos","Atos","أعمال الرسل"},
    }
    local byRef={}
    for _,r in ipairs(data) do byRef[r[1]]=r end
    for _,item in ipairs(State.bibleWords) do
        local r=assert(byRef[item.esRef],"Bible translation missing: "..item.esRef)
        item.pt,item.ptNote,item.ar,item.arNote=r[2],r[3],r[4],r[5]
        item.ptRef,item.arRef=item.esRef,item.esRef
        for _,b in ipairs(books) do
            if item.esRef:find(b[1],1,true) then
                item.ptRef=item.esRef:gsub(b[1],b[2]); item.arRef=item.esRef:gsub(b[1],b[3]); break
            end
        end
    end
end


do
    -- Native Crefy replacement for the old full-screen pack selection modal.
    -- The old modal is not rendered anymore because the legacy ScreenGui is disabled.
    local packOptions = {
        { name = "Señores del Caos", label = "Señores del Caos", profileValue = "chaos" },
        { name = "Ultra Titanes", label = "Ultra Titanes", profileValue = "ultra" },
    }
    local packSelector = __FGRoot.CrefyUI.uiAddSelector(fastFarmPage, "Pack de farmeo", packOptions, function(selected)
        local key = type(selected) == "table" and selected.profileValue or selected
        if not CONFIG.FastFarm.Packs[key] then return false end
        local modes = FastFarm:GetModes(true)
        local mode = modes and modes[key]
        if not mode or not mode.available then
            hubNotify("No tenés un pack compatible disponible.")
            task.defer(function()
                if FastFarm.CrefyPackSelector and FastFarm.packMode then
                    FastFarm.CrefyPackSelector:SetValue(FastFarm.packMode)
                end
            end)
            return false
        end
        FastFarm.packMode = key
        local ok, strengthAvailable, rebirthAvailable = pcall(function()
            return FastFarm:LoadPack(true)
        end)
        if not ok then
            State.pushOutput("ERROR", "Pack de farmeo: " .. tostring(strengthAvailable):sub(1, 200))
            return false
        end
        if FastFarm.RefreshAvailability then FastFarm.RefreshAvailability() end
        State.pushOutput("PACK", "Pack seleccionado: " .. tostring(mode.label))
        return true
    end, nil, "Seleccionar pack")
    FastFarm.CrefyPackSelector = packSelector

    -- Preserve the previous auto-fallback behavior while syncing the native dropdown.
    pcall(function() FastFarm:LoadPack(true) end)
    if FastFarm.packMode then packSelector:SetValue(FastFarm.packMode) end
    FastFarm.ShowPackWelcome = function()
        if FastFarm.RefreshAvailability then FastFarm.RefreshAvailability() end
        if FastFarm.packMode then packSelector:SetValue(FastFarm.packMode) end
    end
    FastFarm.HidePackWelcome = function() end
end

do
	local originals = {}
	local disabledText = Color3.fromRGB(112, 118, 126)
	local disabledSurface = Color3.fromRGB(31, 34, 40)
	local disabledBorder = Color3.fromRGB(77, 82, 92)
	local roots = { fastFarmSection.Parent, timeRow, calculatorRow, counterRow }

	local function remember(instance)
		if originals[instance] then return end
		if instance:IsA("TextLabel") or instance:IsA("TextButton") then
			originals[instance] = {
				TextColor3 = instance.TextColor3,
				TextTransparency = instance.TextTransparency,
			}
		elseif instance:IsA("Frame") then
			originals[instance] = {
				BackgroundColor3 = instance.BackgroundColor3,
				BackgroundTransparency = instance.BackgroundTransparency,
			}
		elseif instance:IsA("UIStroke") then
			originals[instance] = {
				Color = instance.Color,
				Transparency = instance.Transparency,
			}
		end
	end
	for _, root in ipairs(roots) do
		remember(root)
		for _, descendant in ipairs(root:GetDescendants()) do remember(descendant) end
	end

	setFastFarmContentDisabled = function(disabled)
		disabled = disabled == true
		if FastFarm.contentDisabled == disabled then return end
		FastFarm.contentDisabled = disabled
		for instance, original in pairs(originals) do
			if instance.Parent then
				if instance:IsA("TextLabel") or instance:IsA("TextButton") then
					instance.TextColor3 = disabled and disabledText or original.TextColor3
					instance.TextTransparency = disabled and math.max(original.TextTransparency, 0.28)
						or original.TextTransparency
				elseif instance:IsA("Frame") then
					instance.BackgroundColor3 = disabled and disabledSurface or original.BackgroundColor3
					instance.BackgroundTransparency = disabled and math.max(original.BackgroundTransparency, 0.45)
						or original.BackgroundTransparency
				elseif instance:IsA("UIStroke") then
					instance.Color = disabled and disabledBorder or original.Color
					instance.Transparency = disabled and math.max(original.Transparency, 0.65)
						or original.Transparency
				end
			end
		end
	end
	FastFarm.contentDisabled = nil
	FastFarm.RefreshAvailability()
end


local function renderFarmCounter(counter, valueText, gainText, hasGain)
	counter.Value.Text = valueText
	local valueLength = #tostring(valueText)
	counter.Value.TextSize = valueLength >= 17 and 14 or (valueLength >= 15 and 16 or 18)
	counter.Gain.TextSize = #tostring(gainText) >= 17 and 10 or (#tostring(gainText) >= 14 and 11 or 12)
	counter.Gain.Visible = hasGain
	if hasGain then
		counter.Value.Position = UDim2.new(counter.Value.Position.X.Scale, counter.Value.Position.X.Offset, 0, 15)
		counter.Value.Size = UDim2.new(0.5, -14, 0, 27)
		counter.Gain.Text = "+" .. gainText
	else
		counter.Value.Position = UDim2.new(counter.Value.Position.X.Scale, counter.Value.Position.X.Offset, 0, 15)
		counter.Value.Size = UDim2.new(0.5, -14, 0, 39)
		counter.Gain.Text = ""
	end
end


local function elapsedText(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	local days = math.floor(seconds / 86400)
	local hours = math.floor((seconds % 86400) / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	return string.format("%dd %dh %dm %ds", days, hours, minutes, secs)
end

local calculatorMode = nil
local calculatorRate = nil
startThread("fastFarmStatsUI", function()
	while State.running do
		if FastFarm.RebirthToggle then FastFarm.RebirthToggle:Set(FastFarm.mode=="rebirth",true) end
		if FastFarm.StrengthToggle then FastFarm.StrengthToggle:Set(FastFarm.mode=="strength",true) end
		local stats = FastFarm:ReadStats()
		local baseline = FastFarm.startStats or stats
		local strengthGain = FastFarm.mode == "rebirth" and math.max(0, FastFarm.cycleStrengthGain or 0)
			or math.max(0, stats.strength - (baseline.strength or stats.strength))
		local rebirthGain = math.max(0, stats.rebirths - (baseline.rebirths or stats.rebirths))
		renderFarmCounter(
			strengthCounter,
			formatExact(stats.strength),
			formatExact(strengthGain),
			strengthGain > 0
		)
		renderFarmCounter(
			rebirthCounter,
			formatExact(stats.rebirths),
			formatExact(rebirthGain),
			rebirthGain > 0
		)

		if calculatorMode ~= FastFarm.mode then
			calculatorMode = FastFarm.mode
			calculatorRate = nil
		end

		if FastFarm.mode and FastFarm.sessionStartedAt then
			local now = os.clock()
			local elapsed = math.max(now - FastFarm.sessionStartedAt, 0)
			local status
			if FastFarm.pingPaused then
				status = " Pausado por ping"
			else
				status = FastFarm.mode == "rebirth" and "" or " Entrenando"
			end
			timeValue.Text = elapsedText(elapsed) .. status
			if FastFarm.mode == "rebirth" then
				calculatorRate = calculatorRate or (FastFarm.expectedRebirthDelta or 0)
					/ CONFIG.FastFarm.RateCycle * 3600
			elseif calculatorRate == nil and #(FastFarm.validStrengthSamples or {}) >= 8 then
				local rate = FastFarm:CalculateStrengthRate()
				calculatorRate = rate and rate * 3600 or nil
			end
			if calculatorRate == nil then
				calculatorValue.Text = "Calibrando..."
			else
				local perHour = calculatorRate
				local perDay = perHour * 24
				if FastFarm.mode == "rebirth" and math.abs(perDay) >= 100000 then
					perDay = math.floor(perDay / 10000 + 0.5) * 10000
				end
				calculatorValue.Text = FastFarm:FormatCompact(perHour) .. "/h  •  "
					.. FastFarm:FormatCompact(perDay) .. "/d  •  "
					.. FastFarm:FormatCompact(perHour * 168) .. "/w"
			end
		else
			timeValue.Text = "0d 0h 0m 0s"
			calculatorValue.Text = "0/h  •  0/d  •  0/w"
		end
		task.wait(0.5)
	end
end)
end
pageSetup()


pageSetup = function()
local biblePage = Pages["Dios Te ama ❤"]
local scripture = State.bibleWords
biblePage:SetAttribute("TightCanvas", true)
biblePage.ScrollingEnabled = false
biblePage.ScrollBarThickness = 0
local sanctuary = Instance.new("Frame")
sanctuary.Name = "ScriptureSanctuary"
sanctuary.LayoutOrder = nextOrder(biblePage)
sanctuary.Size = UDim2.new(1, 0, 0, 240)
sanctuary.BackgroundColor3 = Color3.fromRGB(11, 8, 25)
sanctuary.BackgroundTransparency = 1
sanctuary.BorderSizePixel = 0
sanctuary.ClipsDescendants = true
sanctuary.ZIndex = 11
sanctuary.Parent = biblePage
Instance.new("UICorner", sanctuary).CornerRadius = UDim.new(0, 12)
local holyBorder = Instance.new("UIStroke")
holyBorder.Name = "HolyBorder"
holyBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
holyBorder.Color = Color3.fromRGB(166, 121, 255)
holyBorder.Transparency = 1
holyBorder.Thickness = 1
holyBorder.Parent = sanctuary
local holyAura = Instance.new("UIGradient")
holyAura.Rotation = 20
holyAura.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 20, 51)),
	ColorSequenceKeypoint.new(0.32, Color3.fromRGB(17, 12, 35)),
	ColorSequenceKeypoint.new(0.72, Color3.fromRGB(12, 10, 31)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 20, 48)),
})
holyAura.Parent = sanctuary
local innerBorder = Instance.new("Frame")
innerBorder.Name = "InnerBorder"
innerBorder.Size = UDim2.new(1, -10, 1, -10)
innerBorder.Position = UDim2.fromOffset(5, 5)
innerBorder.BackgroundTransparency = 1
innerBorder.BorderSizePixel = 0
innerBorder.ZIndex = 12
innerBorder.Parent = sanctuary
Instance.new("UICorner", innerBorder).CornerRadius = UDim.new(0, 9)
local innerStroke = Instance.new("UIStroke")
innerStroke.Color = Color3.fromRGB(188, 137, 255)
innerStroke.Transparency = 1
innerStroke.Thickness = 1
innerStroke.Parent = innerBorder
local topGlow = Instance.new("Frame")
topGlow.Name = "Light"
topGlow.AnchorPoint = Vector2.new(0.5, 0)
topGlow.Size = UDim2.new(0.76, 0, 0, 2)
topGlow.Position = UDim2.new(0.5, 0, 0, 5)
topGlow.BackgroundColor3 = C.cyan
topGlow.BackgroundTransparency = 1
topGlow.BorderSizePixel = 0
topGlow.ZIndex = 13
topGlow.Parent = sanctuary
Instance.new("UICorner", topGlow).CornerRadius = UDim.new(1, 0)
local crown = Instance.new("TextLabel")
crown.Name = "Crown"
crown.Size = UDim2.new(1, -32, 0, 24)
crown.Position = UDim2.fromOffset(16, 13)
crown.BackgroundTransparency = 1
crown.Text = "PALABRA DE VIDA"
crown.TextColor3 = Color3.fromRGB(216, 194, 255)
crown.TextStrokeColor3 = Color3.fromRGB(20, 8, 38)
crown.TextStrokeTransparency = 0.56
crown.Font = Enum.Font.GothamBold
crown.TextSize = 13
crown.ZIndex = 15
crown.Parent = sanctuary
local verseBody = Instance.new("TextLabel")
verseBody.Name = "Verse"
verseBody.AnchorPoint = Vector2.new(0.5, 0)
verseBody.Size = UDim2.new(1, -86, 0, 77)
verseBody.Position = UDim2.new(0.5, 0, 0, 38)
verseBody.BackgroundTransparency = 1
verseBody.Text = ""
verseBody.TextColor3 = Color3.fromRGB(250, 247, 255)
verseBody.TextStrokeColor3 = Color3.fromRGB(20, 8, 30)
verseBody.TextStrokeTransparency = 0.48
verseBody.Font = Enum.Font.GothamMedium
verseBody.TextSize = 23
verseBody.TextScaled = true
verseBody.TextWrapped = true
verseBody.LineHeight = 1.08
verseBody.TextXAlignment = Enum.TextXAlignment.Center
verseBody.TextYAlignment = Enum.TextYAlignment.Center
verseBody.ZIndex = 15
verseBody:SetAttribute("KeepTextStyle", true)
verseBody:SetAttribute("NoTranslate", true)
verseBody.Parent = sanctuary
local verseLimit = Instance.new("UITextSizeConstraint")
verseLimit.MinTextSize = 11
verseLimit.MaxTextSize = 23
verseLimit.Parent = verseBody
local verseRef = Instance.new("TextLabel")
verseRef.Name = "Reference"
verseRef.AnchorPoint = Vector2.new(0.5, 0)
verseRef.Size = UDim2.new(1, -104, 0, 21)
verseRef.Position = UDim2.new(0.5, 0, 0, 114)
verseRef.BackgroundTransparency = 1
verseRef.Text = ""
verseRef.TextColor3 = Color3.fromRGB(190, 150, 255)
verseRef.TextStrokeColor3 = Color3.fromRGB(20, 8, 38)
verseRef.TextStrokeTransparency = 0.58
verseRef.Font = Enum.Font.GothamBold
verseRef.TextSize = 13
verseRef.ZIndex = 15
verseRef:SetAttribute("KeepTextStyle", true)
verseRef:SetAttribute("NoTranslate", true)
verseRef.Parent = sanctuary
local verseNote = Instance.new("TextLabel")
verseNote.Name = "Meaning"
verseNote.AnchorPoint = Vector2.new(0.5, 0)
verseNote.Size = UDim2.new(1, -72, 0, 62)
verseNote.Position = UDim2.new(0.5, 0, 0, 137)
verseNote.BackgroundColor3 = Color3.fromRGB(28, 22, 50)
verseNote.BackgroundTransparency = 1
verseNote.BorderSizePixel = 0
verseNote.Text = ""
verseNote.TextColor3 = Color3.fromRGB(244, 239, 255)
verseNote.TextStrokeColor3 = C.black
verseNote.TextStrokeTransparency = 0.42
verseNote.Font = Enum.Font.GothamBold
verseNote.TextSize = 15
verseNote.TextScaled = false
verseNote.TextWrapped = true
verseNote.LineHeight = 1.08
verseNote.TextXAlignment = Enum.TextXAlignment.Center
verseNote.TextYAlignment = Enum.TextYAlignment.Center
verseNote.ZIndex = 15
verseNote:SetAttribute("KeepTextStyle", true)
verseNote:SetAttribute("NoTranslate", true)
verseNote.Parent = sanctuary
Instance.new("UICorner", verseNote).CornerRadius = UDim.new(0, 8)
local noteStroke = Instance.new("UIStroke")
noteStroke.Color = Color3.fromRGB(120, 90, 181)
noteStroke.Transparency = 1
noteStroke.Thickness = 1
noteStroke.Parent = verseNote
local noteLimit = Instance.new("UITextSizeConstraint")
noteLimit.MinTextSize = 8
noteLimit.MaxTextSize = 15
noteLimit.Parent = verseNote
local guide = Instance.new("TextLabel")
guide.Name = "Guide"
guide.AnchorPoint = Vector2.new(0.5, 0)
guide.Size = UDim2.new(1, -150, 0, 17)
guide.Position = UDim2.new(0.5, 0, 0, 222)
guide.BackgroundTransparency = 1
guide.Text = ""
guide.TextColor3 = Color3.fromRGB(194, 174, 225)
guide.TextStrokeColor3 = C.black
guide.TextStrokeTransparency = 0.56
guide.Font = Enum.Font.Gotham
guide.TextSize = 9
guide.ZIndex = 15
guide.Visible = false
guide.Parent = sanctuary
local pageCount = Instance.new("TextLabel")
pageCount.Name = "Count"
pageCount.AnchorPoint = Vector2.new(0.5, 0)
pageCount.Size = UDim2.fromOffset(62, 22)
pageCount.Position = UDim2.new(0.5, 0, 0, 209)
pageCount.BackgroundTransparency = 1
pageCount.Text = "1 / 30"
pageCount.TextColor3 = Color3.fromRGB(202, 170, 255)
pageCount.TextStrokeColor3 = C.black
pageCount.TextStrokeTransparency = 0.42
pageCount.Font = Enum.Font.GothamMedium
pageCount.TextSize = 11
pageCount.ZIndex = 17
pageCount:SetAttribute("KeepTextStyle", true)
pageCount:SetAttribute("NoTranslate", true)
pageCount.Parent = sanctuary
local function makeVerseArrow(symbol, xScale, xOffset)
	local arrow = Instance.new("TextButton")
	arrow.Name = symbol == "‹" and "Previous" or "Next"
	arrow.AnchorPoint = Vector2.new(0.5, 0)
	arrow.Size = UDim2.fromOffset(44, 31)
	arrow.Position = UDim2.new(xScale, xOffset, 0, 205)
	arrow.BackgroundColor3 = Color3.fromRGB(33, 27, 57)
	arrow.BackgroundTransparency = 1
	arrow.BorderSizePixel = 0
	arrow.Text = symbol
	arrow.TextColor3 = C.cyan
	arrow.TextStrokeColor3 = C.black
	arrow.TextStrokeTransparency = 0.25
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = 28
	arrow.AutoButtonColor = false
	arrow.ZIndex = 19
	arrow:SetAttribute("KeepTextStyle", true)
	arrow:SetAttribute("NoTranslate", true)
	arrow.Parent = sanctuary
	Instance.new("UICorner", arrow).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(166, 121, 255)
	stroke.Transparency = 1
	stroke.Thickness = 1.2
	stroke.Parent = arrow
	track(arrow.MouseEnter:Connect(function()
		TweenService:Create(arrow, TweenInfo.new(0.10), { BackgroundTransparency = 1, TextColor3 = C.white }):Play()
		TweenService:Create(stroke, TweenInfo.new(0.10), { Transparency = 1, Thickness = 1 }):Play()
	end))
	track(arrow.MouseLeave:Connect(function()
		TweenService:Create(arrow, TweenInfo.new(0.12), { BackgroundTransparency = 1, TextColor3 = C.cyan }):Play()
		TweenService:Create(stroke, TweenInfo.new(0.12), { Transparency = 1, Thickness = 1 }):Play()
	end))
	return arrow
end
local previousVerse = makeVerseArrow("‹", 0, 46)
local nextVerse = makeVerseArrow("›", 1, -46)
local verseClick = Instance.new("TextButton")
verseClick.Name = "CenterArea"
verseClick.AnchorPoint = Vector2.zero
verseClick.Size = UDim2.new(0.334, 0, 1, 0)
verseClick.Position = UDim2.new(0.333, 0, 0, 0)
verseClick.BackgroundTransparency = 1
verseClick.Text = ""
verseClick.AutoButtonColor = false
verseClick.ZIndex = 16
verseClick:SetAttribute("KeepTextStyle", true)
verseClick:SetAttribute("NoTranslate", true)
verseClick.Parent = sanctuary
local leftTap = verseClick:Clone()
leftTap.Name = "PreviousArea"
leftTap.Size = UDim2.new(0.333, 0, 1, 0)
leftTap.Position = UDim2.fromScale(0, 0)
leftTap.Parent = sanctuary
local rightTap = verseClick:Clone()
rightTap.Name = "NextArea"
rightTap.Size = UDim2.new(0.333, 0, 1, 0)
rightTap.Position = UDim2.new(0.667, 0, 0, 0)
rightTap.Parent = sanctuary
local bibleIndex = 1
local bibleTurn = 0
local bibleNextAt = os.clock() + math.random(15, 20)
local bibleTweens = {}
local verseHome = verseBody.Position
local function stopBibleTweens()
	for _, tween in ipairs(bibleTweens) do pcall(tween.Cancel, tween) end
	table.clear(bibleTweens)
end
do
    local words = State.bibleWords
    local order = {
        "Josué 1:9",
        "Isaías 41:10",
        "Salmos 27:1",
        "Salmos 27:3",
        "Deuteronomio 31:8",
        "Salmos 23:4",
        "Isaías 43:2",
        "Salmos 46:1",
        "Salmos 18:2",
        "Salmos 118:6",
        "Romanos 8:31",
        "Salmos 56:3",
        "Isaías 40:31",
        "Filipenses 4:13",
        "Juan 16:33",
        "Mateo 11:28",
        "Salmos 121:1-2",
        "Salmos 91:1-2",
        "Salmos 37:23-24",
        "Salmos 37:5",
        "Proverbios 3:5-6",
        "Jeremías 29:11",
        "Filipenses 1:6",
        "Gálatas 6:9",
        "Proverbios 24:16",
        "2 Corintios 12:9",
        "1 Pedro 5:7",
        "Filipenses 4:6-7",
        "Juan 14:27",
        "Isaías 26:3",
        "Salmos 4:8",
        "Salmos 55:22",
        "Salmos 34:18",
        "Salmos 147:3",
        "Salmos 30:5",
        "Salmos 126:5",
        "Salmos 40:1-2",
        "Mateo 5:4",
        "Salmos 56:8",
        "2 Corintios 1:3-4",
        "Romanos 8:28",
        "Lamentaciones 3:22-23",
        "Romanos 15:13",
        "Lucas 1:37",
        "Nehemías 8:10",
        "Apocalipsis 21:4",
        "Apocalipsis 21:5",
        "Juan 3:16",
        "1 Juan 4:9",
        "Romanos 5:8",
        "1 Juan 1:9",
        "Isaías 1:18",
        "Miqueas 7:19",
        "Salmos 103:12",
        "Romanos 8:1",
        "2 Corintios 5:17",
        "Romanos 8:38-39",
        "Sofonías 3:17",
        "Isaías 49:15-16",
        "Isaías 43:1",
        "1 Juan 4:18",
        "Salmos 139:14",
        "Génesis 1:27",
        "Salmos 139:13",
        "Efesios 2:10",
        "Salmos 119:105",
        "Proverbios 4:23",
        "Eclesiastés 3:1",
        "Proverbios 16:3",
        "Santiago 1:5",
        "Colosenses 3:23",
        "Romanos 12:12",
        "Proverbios 12:25",
        "Proverbios 16:24",
        "Proverbios 17:22",
        "1 Tesalonicenses 5:11",
        "Eclesiastés 4:9-10",
        "Proverbios 17:17",
        "Proverbios 27:17",
        "Lucas 6:31",
        "Santiago 1:19",
        "Efesios 4:29",
        "Romanos 12:18",
        "Filipenses 2:3-4",
        "Efesios 4:32",
        "Colosenses 3:13",
        "1 Corintios 13:4-5",
        "Juan 13:34",
        "Mateo 22:37-39",
        "Hebreos 10:24",
        "Mateo 6:34",
        "Miqueas 6:8",
        "Romanos 12:21",
        "Mateo 5:14-16",
        "Proverbios 11:25",
        "Hechos 20:35",
        "Salmos 62:8",
        "Números 6:24-26",
        "1 Corintios 16:14",
        "Salmos 46:10",
    }
    local notes = {
        {"Proverbios 17:22", "Un momento de alegría puede darte ánimo para seguir con tu día.", "A moment of joy can encourage you as you go through your day.", "Um momento de alegria pode dar ânimo para continuar o dia.", "قد تمنحك لحظة فرح دفعة لتكمل يومك."},
        {"Proverbios 27:17", "Un buen amigo te escucha y te ayuda a mejorar, con cariño y sinceridad.", "A good friend listens and helps you grow, with kindness and honesty.", "Um bom amigo escuta e ajuda você a melhorar, com carinho e sinceridade.", "الصديق الجيد يستمع إليك ويساعدك على التحسن بلطف وصدق."},
        {"Eclesiastés 4:9-10", "No tenés que resolverlo todo solo. También podés dejar que alguien te ayude.", "You do not have to solve everything alone. You can let someone help you too.", "Você não precisa resolver tudo sozinho. Também pode aceitar a ajuda de alguém.", "ليس عليك أن تحل كل شيء وحدك. يمكنك أيضًا أن تقبل مساعدة الآخرين."},
        {"Mateo 11:28", "Cuando estés cansado, podés hacer una pausa y contarle a Jesús lo que te preocupa.", "When you are tired, you can pause and tell Jesus what is worrying you.", "Quando estiver cansado, você pode fazer uma pausa e contar a Jesus o que preocupa você.", "عندما تتعب، يمكنك أن تتوقف قليلًا وتتحدث مع يسوع عما يقلقك."},
        {"1 Juan 1:9", "Podés reconocer lo que hiciste mal, pedir perdón y buscar cómo repararlo.", "You can admit what you did wrong, ask for forgiveness and look for ways to make amends.", "Você pode reconhecer o que fez de errado, pedir perdão e procurar reparar o que aconteceu.", "يمكنك أن تعترف بما أخطأت فيه، وتطلب الغفران، وتسعى لإصلاح ما حدث."},
        {"Salmos 103:12", "El perdón abre una oportunidad para cambiar y seguir adelante.", "Forgiveness opens an opportunity to change and move forward.", "O perdão abre uma oportunidade para mudar e seguir em frente.", "يفتح الغفران فرصة للتغيير والمضي قدمًا."},
        {"Isaías 1:18", "Reconocer un error y querer cambiar puede ser el comienzo de algo mejor.", "Admitting a mistake and wanting to change can be the start of something better.", "Reconhecer um erro e querer mudar pode ser o começo de algo melhor.", "الاعتراف بخطأ والرغبة في التغيير قد يكونان بداية لشيء أفضل."},
        {"Miqueas 7:19", "El perdón no borra lo que pasó, pero puede abrir un camino distinto.", "Forgiveness does not undo what happened, but it can open a different path.", "O perdão não desfaz o que aconteceu, mas pode abrir um caminho diferente.", "الغفران لا يلغي ما حدث، لكنه قد يفتح طريقًا مختلفًا."},
        {"2 Corintios 12:9", "No tenés que ser fuerte todo el tiempo. También podés recibir ayuda.", "You do not have to be strong all the time. You can receive help too.", "Você não precisa ser forte o tempo todo. Também pode receber ajuda.", "ليس عليك أن تكون قويًا طوال الوقت. يمكنك أيضًا أن تتلقى المساعدة."},
        {"Romanos 8:28", "Esto no dice que el daño sea bueno. Habla de confiar en Dios también en los días difíciles.", "This does not say that harm is good. It speaks of trusting God on difficult days too.", "Isso não diz que o sofrimento é bom. Fala de confiar em Deus também nos dias difíceis.", "هذا لا يعني أن الأذى خير. بل يتحدث عن الثقة بالله في الأيام الصعبة أيضًا."},
        {"Jeremías 29:11", "Estas palabras llevaron esperanza a personas que vivían lejos de su hogar.", "These words brought hope to people living far from home.", "Estas palavras levaram esperança a pessoas que viviam longe de casa.", "حملت هذه الكلمات الرجاء إلى أناس كانوا يعيشون بعيدًا عن ديارهم."},
        {"Salmos 30:5", "Después de un día difícil, también pueden volver los momentos de alegría.", "After a difficult day, moments of joy can return too.", "Depois de um dia difícil, os momentos de alegria também podem voltar.", "بعد يوم صعب، يمكن أن تعود لحظات الفرح أيضًا."},
        {"Romanos 8:38-39", "Aun en los momentos difíciles, este pasaje recuerda la firmeza del amor de Dios.", "Even in difficult times, this passage reminds us of the steadfastness of God's love.", "Mesmo nos momentos difíceis, esta passagem lembra a firmeza do amor de Deus.", "حتى في الأوقات الصعبة، يذكّرنا هذا المقطع بثبات محبة الله."},
        {"Salmos 118:6", "No enfrentás el miedo solo: Dios permanece a tu lado.", "You do not face fear alone: God remains by your side.", "Você não enfrenta o medo sozinho: Deus permanece ao seu lado.", "أنت لا تواجه الخوف وحدك؛ فالله باقٍ إلى جانبك."},
        {"Romanos 8:31", "No enfrentás la vida solo: Dios está de tu lado aun cuando el camino se pone difícil.", "You do not face life alone: God is with you even when the road becomes difficult.", "Você não enfrenta a vida sozinho: Deus está ao seu lado mesmo quando o caminho fica difícil.", "أنت لا تواجه الحياة وحدك؛ فالله معك حتى عندما يصبح الطريق صعبًا."},
        {"Isaías 43:2", "Las pruebas pueden llegar, pero no las atravesás solo: Dios sigue con vos.", "Trials may come, but you do not face them alone: God remains with you.", "As provações podem chegar, mas você não passa por elas sozinho: Deus continua com você.", "قد تأتي التجارب، لكنك لا تعبرها وحدك: الله يبقى معك."},
        {"Salmos 46:10", "Una pausa para respirar y orar puede ayudarte a recuperar la calma.", "Pausing to breathe and pray can help you find calm again.", "Uma pausa para respirar e orar pode ajudar você a recuperar a calma.", "قد تساعدك وقفة للتنفس والصلاة على استعادة الهدوء."},
        {"Apocalipsis 21:5", "Este pasaje mira hacia un mundo renovado, sin dolor ni sufrimiento.", "This passage looks toward a renewed world without pain or suffering.", "Esta passagem olha para um mundo renovado, sem dor nem sofrimento.", "يتطلع هذا المقطع إلى عالم متجدد بلا ألم ولا معاناة."},
        {"Sofonías 3:17", "El pasaje describe a Dios acompañando a su pueblo con amor y alegría.", "The passage describes God being with his people in love and joy.", "A passagem descreve Deus acompanhando seu povo com amor e alegria.", "يصف المقطع الله وهو يرافق شعبه بمحبة وفرح."},
        {"1 Corintios 16:14", "Que el amor se note en cómo hablás y tratás a los demás.", "Let love show in how you speak and treat others.", "Que o amor apareça no jeito como você fala e trata os outros.", "ليظهر الحب في طريقة كلامك وتعاملك مع الآخرين."},
    }
    if type(words) == "table" then
        local byRef, arranged = {}, {}
        for _, item in ipairs(words) do
            if type(item) == "table" and item.esRef then byRef[item.esRef] = item end
        end
        local ready = #words == #order
        for i, ref in ipairs(order) do
            arranged[i] = byRef[ref]
            if not arranged[i] then ready = false end
        end
        if ready then
            for i=1,#order do words[i] = arranged[i] end
        end
        for _, row in ipairs(notes) do
            local item = byRef[row[1]]
            if item then item.esNote, item.enNote, item.ptNote, item.arNote = row[2], row[3], row[4], row[5] end
        end
    end
end

local function scriptureText(index)
 local item=scripture[index] or scripture[1]
 local lang=State.language or "es"
 local prefix=({es="Mensaje: ",en="Meaning: ",pt="Mensagem: ",ar="المعنى: "})[lang]
 return item[lang] or item.es,item[lang.."Ref"] or item.esRef,prefix..(item[lang.."Note"] or item.esNote)
end

-- Native Crefy content for the former custom Scripture card.
__FGRoot.CrefyUI.uiAddSection(biblePage, "Versículo diario")
local bibleNativeGroup = __FGRoot.CrefyUI.getCrefyGroup(biblePage)
local bibleNativeVerse = bibleNativeGroup:AddLabel({ Text = "", DoesWrap = true, Size = 17 })
local bibleNativeReference = bibleNativeGroup:AddLabel({ Text = "", DoesWrap = true, Size = 13 })
local bibleNativeMeaning = bibleNativeGroup:AddLabel({ Text = "", DoesWrap = true, Size = 12 })
local bibleNativeCount = bibleNativeGroup:AddLabel({ Text = "", DoesWrap = false, Size = 11 })
local function drawScripture(index, motion)
	bibleIndex = ((tonumber(index) or bibleIndex) - 1) % #scripture + 1
	State.bibleIndex = bibleIndex
	bibleTurn = bibleTurn + 1
	local turn = bibleTurn
	stopBibleTweens()
	verseBody.Position = verseHome
	verseBody.TextTransparency = 0
	verseRef.TextTransparency = 0
	verseNote.TextTransparency = 0
	pageCount.TextTransparency = 0
	local function applyScripture()
		if turn ~= bibleTurn or not verseBody.Parent then return end
        local verseText, verseReferenceText, verseMeaningText = scriptureText(bibleIndex)
        verseBody.Text, verseRef.Text, verseNote.Text = verseText, verseReferenceText, verseMeaningText
        if bibleNativeVerse then bibleNativeVerse:SetText(verseText) end
        if bibleNativeReference then bibleNativeReference:SetText(verseReferenceText) end
        if bibleNativeMeaning then bibleNativeMeaning:SetText(verseMeaningText) end
        if bibleNativeCount then bibleNativeCount:SetText(tostring(bibleIndex) .. " / " .. tostring(#scripture)) end
        for _,label in ipairs({verseBody,verseRef,verseNote}) do State.styleLanguage(label) end
        verseLimit.MaxTextSize=State.language=="ar" and 28 or 23
        verseBody.TextSize=verseLimit.MaxTextSize
        verseNote.TextSize=State.language=="ar" and 19 or 15
        local noteLimit=verseNote:FindFirstChildWhichIsA("UITextSizeConstraint")
        if noteLimit then noteLimit.MaxTextSize=verseNote.TextSize end
		pageCount.Text = tostring(bibleIndex) .. " / " .. tostring(#scripture)
	end
	if not motion or motion == 0 then
		applyScripture()
		verseBody.Position = verseHome
		verseBody.TextTransparency = 0
		verseRef.TextTransparency = 0
		verseNote.TextTransparency = 0
		pageCount.TextTransparency = 0
		return
	end
	local side = motion < 0 and -10 or 10
	bibleTweens[1] = TweenService:Create(verseBody, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1, Position = verseHome + UDim2.fromOffset(-side, 0) })
	bibleTweens[2] = TweenService:Create(verseRef, TweenInfo.new(0.10), { TextTransparency = 1 })
	bibleTweens[3] = TweenService:Create(verseNote, TweenInfo.new(0.10), { TextTransparency = 1 })
	bibleTweens[4] = TweenService:Create(pageCount, TweenInfo.new(0.10), { TextTransparency = 1 })
	for _, tween in ipairs(bibleTweens) do tween:Play() end
	task.delay(0.13, function()
		if turn ~= bibleTurn or not State.running then return end
		applyScripture()
		verseBody.Position = verseHome + UDim2.fromOffset(side, 0)
		bibleTweens[1] = TweenService:Create(verseBody, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { TextTransparency = 0, Position = verseHome })
		bibleTweens[2] = TweenService:Create(verseRef, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 })
		bibleTweens[3] = TweenService:Create(verseNote, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 })
		bibleTweens[4] = TweenService:Create(pageCount, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 })
		for _, tween in ipairs(bibleTweens) do tween:Play() end
	end)
end
local function moveScripture(step)
	bibleNextAt = os.clock() + math.random(15, 20)
	drawScripture(bibleIndex + step, step)
	TweenService:Create(verseRef, TweenInfo.new(0.10), { TextColor3 = C.cyan }):Play()
	task.delay(0.13, function()
		if State.running and verseRef.Parent then TweenService:Create(verseRef, TweenInfo.new(0.22), { TextColor3 = Color3.fromRGB(190, 150, 255) }):Play() end
	end)
end
__FGRoot.CrefyUI.uiAddButton(biblePage, "← Versículo anterior", function() moveScripture(-1) end)
__FGRoot.CrefyUI.uiAddButton(biblePage, "Siguiente versículo →", function() moveScripture(1) end)
local bibleLanguageOff = State.onLanguageChanged(function()
	drawScripture(bibleIndex, 0)
end)
addCleanup(function()
	bibleLanguageOff()
	bibleTurn = bibleTurn + 1
	stopBibleTweens()
end)
track(verseClick.Activated:Connect(function() moveScripture(1) end))
track(leftTap.Activated:Connect(function() moveScripture(-1) end))
track(rightTap.Activated:Connect(function() moveScripture(1) end))
track(previousVerse.Activated:Connect(function() moveScripture(-1) end))
track(nextVerse.Activated:Connect(function() moveScripture(1) end))
drawScripture(1, false)
State.biblePage = biblePage
State.bibleCard = sanctuary
State.bibleBody = verseBody
State.bibleReference = verseRef
State.bibleMeaning = verseNote
State.bibleChapter = crown
State.bibleLeftArea = leftTap
State.bibleCenterArea = verseClick
State.bibleRightArea = rightTap
State.bibleCount = #scripture
State.bibleDraw = function(index, motion) drawScripture(index, motion or 0) end
State.bibleNext = function() moveScripture(1) end
State.biblePrevious = function() moveScripture(-1) end
startThread("bibleWord", function()
	while State.running do
		if biblePage.Visible and biblePage.Parent ~= __FGRoot.MotionPageCache then
			if os.clock() >= bibleNextAt then moveScripture(1) end
		else
			bibleNextAt = os.clock() + math.random(15, 20)
		end
		task.wait(0.15)
	end
end)
end
pageSetup()


pageSetup = function()
local momentumPage = Pages["Pet Momentum"]
local PetMomentum = FastFarm.PetMomentum
momentumPage:SetAttribute("TightCanvas", true)
__FGRoot.CrefyUI.uiAddSection(momentumPage, "Pet Momentum")

local momentumToggle
momentumToggle = __FGRoot.CrefyUI.uiAddToggle(momentumPage, "Farmear Pet Momentum", function(enabled)
	if enabled then
		local accepted = PetMomentum:Start()
		if accepted == false then hubNotify(PetMomentum.lastError or "No se pudo iniciar Pet Momentum") end
		return accepted
	end
	PetMomentum:Stop(true)
	return nil
end)
momentumToggle.Button.Size = UDim2.new(1, 0, 0, 54)

PetMomentum.UpdateToggle = function(active)
	if momentumToggle and momentumToggle:Get() ~= active then
		momentumToggle:Set(active, true)
	end
end

local progressCard = Instance.new("Frame")
progressCard.Name = "MomentumProgress"
progressCard.LayoutOrder = nextOrder(momentumPage)
progressCard.Parent = momentumPage
__FGRoot.CrefyUI.styleRow(progressCard, 64)

local progressCaption = Instance.new("TextLabel")
progressCaption.Size = UDim2.new(1, -100, 0, 22)
progressCaption.Position = UDim2.fromOffset(12, 3)
progressCaption.BackgroundTransparency = 1
progressCaption.Text = "x1  →  x50"
progressCaption.TextColor3 = C.soft
progressCaption.Font = C.fontBold
progressCaption.TextSize = 14
progressCaption.TextXAlignment = Enum.TextXAlignment.Left
progressCaption.ZIndex = 13
progressCaption.Parent = progressCard

local multiplierValue = Instance.new("TextLabel")
multiplierValue.Size = UDim2.fromOffset(82, 22)
multiplierValue.Position = UDim2.new(1, -94, 0, 3)
multiplierValue.BackgroundTransparency = 1
multiplierValue.Text = "x1"
multiplierValue.TextColor3 = C.cyan
multiplierValue.Font = C.fontBold
multiplierValue.TextSize = 14
multiplierValue.TextXAlignment = Enum.TextXAlignment.Right
multiplierValue.ZIndex = 13
multiplierValue.Parent = progressCard

local completedValue = Instance.new("TextLabel")
completedValue.Size = UDim2.new(1, -24, 0, 14)
completedValue.Position = UDim2.fromOffset(12, 25)
completedValue.BackgroundTransparency = 1
completedValue.Text = "0/0 al máximo"
completedValue.TextColor3 = C.dim
completedValue.Font = UI_FONT
completedValue.TextSize = 10
completedValue.TextXAlignment = Enum.TextXAlignment.Left
completedValue.ZIndex = 13
completedValue.Parent = progressCard

local progressTrack = Instance.new("Frame")
progressTrack.Size = UDim2.new(1, -24, 0, 10)
progressTrack.Position = UDim2.fromOffset(12, 46)
progressTrack.BackgroundColor3 = Color3.fromRGB(12, 15, 21)
progressTrack.BackgroundTransparency = 0.08
progressTrack.BorderSizePixel = 0
progressTrack.ClipsDescendants = true
progressTrack.ZIndex = 13
progressTrack.Parent = progressCard
Instance.new("UICorner", progressTrack).CornerRadius = UDim.new(1, 0)

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.fromScale(0, 1)
progressFill.BackgroundColor3 = C.cyan
progressFill.BorderSizePixel = 0
progressFill.ZIndex = 14
progressFill.Parent = progressTrack
Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)
local progressGradient = Instance.new("UIGradient")
progressGradient.Color = ColorSequence.new(C.blue, C.cyan)
progressGradient.Parent = progressFill

startThread("petMomentumStatsUI", function()
	while State.running do
		local progress = PetMomentum:GetProgress()
		if progress.minimumMultiplier == progress.maximumMultiplier then
			multiplierValue.Text = "x" .. tostring(progress.minimumMultiplier)
		else
			multiplierValue.Text = "x" .. tostring(progress.minimumMultiplier)
				.. " – x" .. tostring(progress.maximumMultiplier)
		end
		local words = PetMomentum.progressText[State.language] or PetMomentum.progressText.es
        local linked = State.fastPunch and State.selectedRock
            and (words.durability .. ": " .. tostring(State.selectedRock.label or State.selectedRock.name)) or words.paused
        local _, auraPercent = PetMomentum:GetAuraMomentumBoost()
        local auraText = auraPercent > 0 and string.format(" · Aura +%.1f%%", auraPercent) or ""
        completedValue.Text = string.format(words.count, progress.completed, progress.count) .. " · " .. linked .. auraText
		local alpha = PetMomentum.maxSeconds > 0 and math.clamp(progress.minimum / PetMomentum.maxSeconds, 0, 1) or 0
		TweenService:Create(progressFill, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
			Size = UDim2.fromScale(alpha, 1),
		}):Play()
		task.wait(0.5)
	end
end)
end
pageSetup()


pageSetup = function()
local teleportsPage = Pages.Teleports
__FGRoot.CrefyUI.uiAddSection(teleportsPage, "Teleports")
for _, location in ipairs(CONFIG.Teleports) do
	local data = location
	__FGRoot.CrefyUI.uiAddButton(teleportsPage, data[1], function()
		local root = getRoot()
		if root then
			root.CFrame = data.lookAt and CFrame.lookAt(data[2], data.lookAt) or CFrame.new(data[2])
		end
	end)
end
end
pageSetup()


local function playerOptions()
	local options = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LP then
			options[#options + 1] = {
				label = player.DisplayName,
				name = player.Name,
				userId = player.UserId,
			}
		end
	end
	table.sort(options, function(a, b)
		return a.label:lower() < b.label:lower()
	end)
	return options
end


pageSetup = function()
local rebirthPage = Pages.Rebirths
local rebirthUi = {}
local KING_POSITION = Vector3.new(-8646, 13.25, -5738)
local KING_RETURN_DISTANCE = 42


local function getRebirthRemote()
	local events = ReplicatedStorage:FindFirstChild("rEvents")
	return events and events:FindFirstChild("rebirthRemote")
end


local function changeRebirthSizeOne()
	local events = ReplicatedStorage:FindFirstChild("rEvents")
	local remote = events and events:FindFirstChild("changeSpeedSizeRemote")
	if remote then
		pcall(remote.InvokeServer, remote, "changeSize", 1)
	end
end


local function parseRebirthNumber(value)
	local digits = tostring(value or ""):gsub("[^%d]", "")
	local number = tonumber(digits)
	if not number then
		return nil
	end
	return math.clamp(math.floor(number), 0, 9007199254740991)
end


local function rebirthDuration(seconds)
	if not seconds or seconds ~= seconds or seconds == math.huge then
		return "Calculando..."
	end
	seconds = math.max(0, math.floor(seconds + 0.5))
	local days = math.floor(seconds / 86400)
	local hours = math.floor((seconds % 86400) / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	if days > 0 then
		return string.format("%dd %02dh %02dm", days, hours, minutes)
	elseif hours > 0 then
		return string.format("%dh %02dm %02ds", hours, minutes, secs)
	end
	return string.format("%dm %02ds", minutes, secs)
end


local function rebirthMedian(values)
	if #values == 0 then return nil end
	local sorted = table.clone(values)
	table.sort(sorted)
	local middle = math.floor((#sorted + 1) / 2)
	if #sorted % 2 == 1 then return sorted[middle] end
	return (sorted[middle] + sorted[middle + 1]) / 2
end

__FGRoot.CrefyUI.uiAddSection(rebirthPage, "Rebirths")
do
local summaryRow = Instance.new("Frame")
summaryRow.LayoutOrder = nextOrder(rebirthPage)
summaryRow.Parent = rebirthPage
__FGRoot.CrefyUI.styleRow(summaryRow, 62)

local summaryTitle = Instance.new("TextLabel")
summaryTitle.Size = UDim2.new(1, -20, 0, 22)
summaryTitle.Position = UDim2.fromOffset(10, 3)
summaryTitle.BackgroundTransparency = 1
summaryTitle.Text = "Contador de renas"
summaryTitle.TextColor3 = C.cyan
summaryTitle.Font = C.fontBold
summaryTitle.TextSize = 12
summaryTitle.TextXAlignment = Enum.TextXAlignment.Left
summaryTitle.ZIndex = 12
summaryTitle.Parent = summaryRow

local rebirthCountLabel = Instance.new("TextLabel")
rebirthCountLabel.Size = UDim2.new(0.5, -12, 0, 25)
rebirthCountLabel.Position = UDim2.fromOffset(11, 27)
rebirthCountLabel.BackgroundTransparency = 1
rebirthCountLabel.Text = "Rebirths: 0"
rebirthCountLabel.TextColor3 = C.white
rebirthCountLabel.Font = UI_FONT
rebirthCountLabel.TextSize = 14
rebirthCountLabel.TextXAlignment = Enum.TextXAlignment.Left
rebirthCountLabel.ZIndex = 12
rebirthCountLabel.Parent = summaryRow

local objectiveLabel = rebirthCountLabel:Clone()
objectiveLabel.Size = UDim2.new(0.5, -12, 0, 25)
objectiveLabel.Position = UDim2.new(0.5, 1, 0, 27)
objectiveLabel.Text = ""
objectiveLabel.TextXAlignment = Enum.TextXAlignment.Right
objectiveLabel.Visible = false
objectiveLabel.Parent = summaryRow

local remainingLabel = rebirthCountLabel:Clone()
remainingLabel.Position = UDim2.fromOffset(11, 54)
remainingLabel.Text = ""
remainingLabel.Visible = false
remainingLabel.Parent = summaryRow

local etaLabel = objectiveLabel:Clone()
etaLabel.Position = UDim2.new(0.5, 1, 0, 54)
etaLabel.Text = ""
etaLabel.Visible = false
etaLabel.Parent = summaryRow

local cycleLabel = Instance.new("TextLabel")
cycleLabel.Size = UDim2.new(1, -22, 0, 22)
cycleLabel.Position = UDim2.fromOffset(11, 79)
cycleLabel.BackgroundTransparency = 1
cycleLabel.Text = ""
cycleLabel.TextColor3 = C.dim
cycleLabel.Font = UI_FONT
cycleLabel.TextSize = 12
cycleLabel.TextXAlignment = Enum.TextXAlignment.Center
cycleLabel.Visible = false
cycleLabel.ZIndex = 12
cycleLabel.Parent = summaryRow

local estimator = {
	samples = {},
	lastValue = nil,
	burstGain = 0,
	burstStartedAt = nil,
	lastPositiveAt = nil,
	previousBurstAt = nil,
	smoothedEta = nil,
	lastEtaUpdate = 0,
	rebirthSpendSerial = 0,
}
rebirthUi.summaryRow = summaryRow
rebirthUi.rebirthCountLabel = rebirthCountLabel
rebirthUi.objectiveLabel = objectiveLabel
rebirthUi.remainingLabel = remainingLabel
rebirthUi.etaLabel = etaLabel
rebirthUi.cycleLabel = cycleLabel
rebirthUi.estimator = estimator
end


local function resetTargetEstimator(current)
	local estimator = rebirthUi.estimator
	table.clear(estimator.samples)
	estimator.lastValue = current
	estimator.burstGain = 0
	estimator.burstStartedAt = nil
	estimator.lastPositiveAt = nil
	estimator.previousBurstAt = nil
	estimator.smoothedEta = nil
	estimator.lastEtaUpdate = 0
end


local function finishTargetBurst()
	local estimator = rebirthUi.estimator
	if estimator.burstGain <= 0 or not estimator.burstStartedAt then return end
	if estimator.previousBurstAt then
		local interval = estimator.burstStartedAt - estimator.previousBurstAt
		if interval >= 0.08 and interval <= 3600 then
			estimator.samples[#estimator.samples + 1] = {
				interval = interval,
				gain = estimator.burstGain,
			}
			while #estimator.samples > 20 do table.remove(estimator.samples, 1) end
		end
	end
	estimator.previousBurstAt = estimator.burstStartedAt
	estimator.burstGain = 0
	estimator.burstStartedAt = nil
	estimator.lastPositiveAt = nil
end


local function observeTargetRebirths(value, now)
	local estimator = rebirthUi.estimator
	if estimator.lastValue == nil then
		estimator.lastValue = value
		return
	end
	local delta = value - estimator.lastValue
	estimator.lastValue = value
	if delta > 0 then
		if estimator.burstGain == 0 then estimator.burstStartedAt = now end
		estimator.burstGain = estimator.burstGain + delta
		estimator.lastPositiveAt = now
	elseif delta < 0 then
		estimator.rebirthSpendSerial = estimator.rebirthSpendSerial + 1
		estimator.burstGain = 0
		estimator.burstStartedAt = nil
		estimator.lastPositiveAt = nil
		estimator.previousBurstAt = nil
	end
	if estimator.lastPositiveAt and now - estimator.lastPositiveAt >= 0.85 then
		finishTargetBurst()
	end
end


local function stableTargetRate()
	local estimator = rebirthUi.estimator
	if #estimator.samples < 3 then return nil, nil, nil end
	local intervals, gains = {}, {}
	for _, sample in ipairs(estimator.samples) do
		intervals[#intervals + 1] = sample.interval
		gains[#gains + 1] = sample.gain
	end
	local middleInterval = rebirthMedian(intervals)
	local middleGain = rebirthMedian(gains)
	local weightedGain, weightedTime, accepted = 0, 0, 0
	for index, sample in ipairs(estimator.samples) do
		local validInterval = sample.interval >= middleInterval * 0.45 and sample.interval <= middleInterval * 2.2
		local validGain = sample.gain >= middleGain * 0.4 and sample.gain <= middleGain * 2.5
		if validInterval and validGain then
			local weight = 0.45 + index / #estimator.samples
			weightedGain = weightedGain + sample.gain * weight
			weightedTime = weightedTime + sample.interval * weight
			accepted = accepted + 1
		end
	end
	if accepted < 3 or weightedTime <= 0 then return nil, middleInterval, middleGain end
	return weightedGain / weightedTime, middleInterval, middleGain
end

local targetInput
local targetToggle
local infiniteToggle
local rebirthWeightToggle


local function currentRebirths()
	local stat = getPlayerStat(LP, { "Rebirths", "Rebirth" })
	return math.max(0, math.floor(tonumber(stat and State.getFunctionalStatValue(stat)) or 0))
end


local function autoLiftReachedTarget()
	return State.rebirth.autoLift
		and State.rebirth.target ~= nil
		and currentRebirths() >= State.rebirth.target
		and not State.rebirth.autoTarget
		and not State.rebirth.ultimateRunning
end


local function findRebirthTrainingTool(names)
	local character = getCharacter()
	local backpack = LP:FindFirstChild("Backpack")
	for _, name in ipairs(names) do
		local tool = character and character:FindFirstChild(name)
			or backpack and backpack:FindFirstChild(name)
		if tool and tool:IsA("Tool") then
			return tool
		end
	end
	return nil
end


local function pushupsRequirementMet()
	local tool = findRebirthTrainingTool({ "Pushups" })
	if not tool then return false end
	local requirement = tool:FindFirstChild("requiredAmount")
	local requiredType = requirement and requirement:FindFirstChild("requiredType")
	local statName = requiredType and tostring(requiredType.Value) or "Strength"
	local required = requirement and tonumber(requirement.Value) or 2000
	local stat = getPlayerStat(LP, { statName })
	return stat ~= nil and (tonumber(State.getFunctionalStatValue(stat)) or 0) >= required
end


local function cleanRebirthTrainingTool(name)
	local character = getCharacter()
	local backpack = LP:FindFirstChild("Backpack")
	local tool = character and character:FindFirstChild(name)
	if tool and tool:IsA("Tool") and backpack then
		pcall(function() tool:Deactivate() end)
		pcall(function() tool.Parent = backpack end)
	end
end


local function runPushupRep()
	if not autoLiftReachedTarget() or not pushupsRequirementMet() then return false end
	if State.rebirth.fastWeight and rebirthWeightToggle then
		rebirthWeightToggle:Set(false, false)
		State.rebirth.autoLiftStartedWeight = false
	else
		cleanRebirthTrainingTool("Weight")
		cleanRebirthTrainingTool("Heavy Weight")
	end

	local tool = findRebirthTrainingTool({ "Pushups" })
	local humanoid = getHumanoid()
	local character = getCharacter()
	if not tool or not humanoid or not character then return false end
	if tool.Parent ~= character then
		pcall(function() humanoid:EquipTool(tool) end)
	end
	if tool.Parent ~= character then return false end
	local muscleEvent = LP:FindFirstChild("muscleEvent")
	if not muscleEvent or not muscleEvent:IsA("RemoteEvent") then return false end
	return pcall(function()
		muscleEvent:FireServer("rep")
	end)
end

__FGRoot.CrefyUI.uiAddSection(rebirthPage, "Herramientas")
local starterCode = "epicmuscle20"

local function starterCodeWasRedeemed()
	local ok, redeemed = pcall(function()
		local data = ChestData
		local usedCodes = data and data.Data and data.Data.usedCodes
		if type(usedCodes) ~= "table" then return false end
		for _, code in pairs(usedCodes) do
			if string.lower(tostring(code)) == starterCode then return true end
		end
		return false
	end)
	return ok and redeemed == true
end


local function redeemStarterCode(button)
	if State.redeemingStarterCode then return end
	State.redeemingStarterCode = true
	button.Text = "Canjeando..."
	local events = ReplicatedStorage:FindFirstChild("rEvents")
	local remote = events and events:FindFirstChild("codeRemote")
	local requestOk, accepted, response = false, false, nil
	if remote and remote:IsA("RemoteFunction") then
		requestOk, accepted, response = pcall(remote.InvokeServer, remote, starterCode)
	end
	local responseText = string.lower(tostring(response or ""))
	local handled = requestOk and (accepted == true or string.find(responseText, "already used", 1, true) ~= nil)
	if handled then
		button.Text = accepted == true and "Código canjeado" or "Código ya canjeado"
		button.TextColor3 = accepted == true and C.green or C.soft
		task.delay(0.4, function()
			if button and button.Parent then button:Destroy() end
		end)
	else
		button.Text = "No se pudo canjear"
		button.TextColor3 = C.red
		task.delay(1, function()
			if button and button.Parent then
				button.Text = "Canjear 2K de Fuerza"
				button.TextColor3 = C.white
			end
		end)
	end
	State.redeemingStarterCode = false
end
State.redeemStarterCode = redeemStarterCode

local starterCodeButton
if not starterCodeWasRedeemed() then
	starterCodeButton = __FGRoot.CrefyUI.uiAddButton(rebirthPage, "Canjear 2K de Fuerza", redeemStarterCode)
	starterCodeButton.Name = "StarterCode"
	startThread("starterCodeStatus", function()
		for _ = 1, 40 do
			if starterCodeWasRedeemed() then
				if starterCodeButton and starterCodeButton.Parent then starterCodeButton:Destroy() end
				return
			end
			task.wait(0.25)
		end
	end)
end
__FGRoot.CrefyUI.uiAddToggle(rebirthPage, "Set Size 1", function(enabled)
	State.rebirth.sizeOne = enabled == true
	stopThread("rebirthSizeOne")
	if State.rebirth.sizeOne then
		changeRebirthSizeOne()
		startThread("rebirthSizeOne", function()
			while State.running and State.rebirth.sizeOne do
				changeRebirthSizeOne()
				task.wait(0.75)
			end
		end)
	end
	return true
end)

rebirthWeightToggle = __FGRoot.CrefyUI.uiAddToggle(rebirthPage, "Pesa rápida", function(enabled)
	State.rebirth.fastWeight = enabled == true
	setAutoRep("rebirthFastWeight", State.rebirth.fastWeight, { "Weight", "Heavy Weight" }, 0.005, true)
	return true
end)

__FGRoot.CrefyUI.uiAddToggle(rebirthPage, "Auto Pushups", function(enabled)
	State.rebirth.autoLift = enabled == true
	stopThread("rebirthAutoLift")
	if State.rebirth.autoLift then
		State.rebirth.autoLiftStartedWeight = false
		startThread("rebirthAutoLift", function()
			while State.running and State.rebirth.autoLift do
				if autoLiftReachedTarget() then
					if pushupsRequirementMet() then
						runPushupRep()
					elseif not State.rebirth.fastWeight and rebirthWeightToggle then
						State.rebirth.autoLiftStartedWeight = true
						rebirthWeightToggle:Set(true, false)
					end
				end
				task.wait(0.05)
			end
		end)
	else
		if State.rebirth.autoLiftStartedWeight and State.rebirth.fastWeight and rebirthWeightToggle then
			rebirthWeightToggle:Set(false, false)
		end
		State.rebirth.autoLiftStartedWeight = false
		cleanRebirthTrainingTool("Pushups")
	end
	return true
end)

__FGRoot.CrefyUI.uiAddToggle(rebirthPage, "King", function(enabled)
	State.rebirth.king = enabled == true
	stopThread("rebirthKing")
	if State.rebirth.king then
		startThread("rebirthKing", function()
			while State.running and State.rebirth.king do
				local root = getRoot()
				if root and (root.Position - KING_POSITION).Magnitude > KING_RETURN_DISTANCE then
					local params = RaycastParams.new()
					params.FilterType = Enum.RaycastFilterType.Exclude
					local ignored = {}
					for _, player in ipairs(Players:GetPlayers()) do
						if player.Character then ignored[#ignored + 1] = player.Character end
					end
					params.FilterDescendantsInstances = ignored
					params.IgnoreWater = true
					local target = KING_POSITION
					local result = workspace:Raycast(KING_POSITION + Vector3.new(0, 35, 0), Vector3.new(0, -80, 0), params)
					if result then target = Vector3.new(KING_POSITION.X, result.Position.Y + 3.1, KING_POSITION.Z) end
					local targetCFrame = CFrame.new(target)
					if State.rebirth.lockPosition then
						State.rebirth.lockCFrame = targetCFrame
					end
					root.CFrame = targetCFrame
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
				end
				task.wait(0.25)
			end
		end)
	end
	return true
end)

__FGRoot.CrefyUI.uiAddToggle(rebirthPage, "Lock Position", function(enabled)
	State.rebirth.lockPosition = enabled == true
	local root = getRoot()
	State.rebirth.lockCFrame = State.rebirth.lockPosition and root and root.CFrame or nil
	stopThread("rebirthLock")
	if State.rebirth.lockPosition and State.rebirth.lockCFrame then
		startThread("rebirthLock", function()
			while State.running and State.rebirth.lockPosition do
				local currentRoot = getRoot()
				if currentRoot and State.rebirth.lockCFrame then
					currentRoot.CFrame = State.rebirth.lockCFrame
					currentRoot.AssemblyLinearVelocity = Vector3.zero
					currentRoot.AssemblyAngularVelocity = Vector3.zero
				end
				RunService.Heartbeat:Wait()
			end
		end)
	end
	return true
end)

__FGRoot.CrefyUI.uiAddToggle(rebirthPage, "Egg cada 30 minutos", function(enabled)
	State.setAutoEgg(enabled, "rebirth")
	return true
end)

targetInput = __FGRoot.CrefyUI.uiAddInput(rebirthPage, "Objetivo de renacimientos", "Ejemplo: 18,980", function(value)
	local parsed = parseRebirthNumber(value)
	if parsed and parsed > 0 then
		State.rebirth.target = parsed
		targetInput.Text = formatExact(parsed):gsub("%.", ",")
	elseif tostring(value or ""):gsub("%s+", "") == "" then
		State.rebirth.target = nil
		targetInput.Text = ""
	else
		targetInput.Text = State.rebirth.target and formatExact(State.rebirth.target):gsub("%.", ",") or ""
	end
end)
targetInput.Text = ""


local function setRebirthMode(mode, enabled)
	if mode == "target" then
		if enabled and not State.rebirth.target then return false end
		State.rebirth.autoTarget = enabled == true
		if State.rebirth.autoTarget then
			State.rebirth.infinite = false
			if infiniteToggle and infiniteToggle:Get() then infiniteToggle:Set(false, true) end
			local stat = getPlayerStat(LP, { "Rebirths", "Rebirth" })
			resetTargetEstimator(tonumber(stat and State.getFunctionalStatValue(stat)) or 0)
			task.defer(function()
				RunService.Heartbeat:Wait()
				TweenService:Create(rebirthPage, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					CanvasPosition = Vector2.zero,
				}):Play()
			end)
		end
	elseif mode == "infinite" then
		State.rebirth.infinite = enabled == true
		if State.rebirth.infinite then
			State.rebirth.autoTarget = false
			if targetToggle and targetToggle:Get() then targetToggle:Set(false, true) end
		end
	end
	stopThread("rebirthLoop")
	if not State.rebirth.autoTarget and not State.rebirth.infinite then return true end
	startThread("rebirthLoop", function()
		local nextRequestAt = 0
		while State.running and (State.rebirth.autoTarget or State.rebirth.infinite) do
			local stat = getPlayerStat(LP, { "Rebirths", "Rebirth" })
			local current = tonumber(stat and State.getFunctionalStatValue(stat)) or 0
			if State.rebirth.autoTarget and State.rebirth.target and current >= State.rebirth.target then
				State.rebirth.autoTarget = false
				if targetToggle then targetToggle:Set(false, true) end
				break
			end
			local strengthStat = getPlayerStat(LP, { "Strength", "Fuerza" })
			local strength = tonumber(strengthStat and State.getFunctionalStatValue(strengthStat)) or 0
			local required = FastFarm.GetRequiredRebirthStrength(current)
			local character = getCharacter()
			local ready = character ~= nil
				and character:GetAttribute("IsRebirthing") ~= true
				and character:GetAttribute("LastMapCFrame") == nil
			local now = os.clock()
			if strength >= required and ready and now >= nextRequestAt then
				local accepted = FastFarm.RequestRebirth()
				nextRequestAt = now + (accepted
					and (CONFIG.FastFarm.RebirthCooldown + CONFIG.FastFarm.RebirthSafetyMargin)
					or 0.12)
			end
			task.wait(0.03)
		end
	end)
	return true
end

targetToggle = __FGRoot.CrefyUI.uiAddToggle(rebirthPage, "Renacer hasta el objetivo", function(enabled)
	return setRebirthMode("target", enabled)
end)
infiniteToggle = __FGRoot.CrefyUI.uiAddToggle(rebirthPage, "Renacimientos infinitos", function(enabled)
	return setRebirthMode("infinite", enabled)
end)

startThread("rebirthCounter", function()
	local estimator = rebirthUi.estimator
	while State.running and rebirthUi.summaryRow.Parent do
		local now = realNow()
		local stat = getPlayerStat(LP, { "Rebirths", "Rebirth" })
		local current = tonumber(stat and State.getFunctionalStatValue(stat)) or 0
		if State.rebirth.autoTarget then
			observeTargetRebirths(current, now)
			if estimator.lastPositiveAt and now - estimator.lastPositiveAt >= 0.85 then finishTargetBurst() end
		else
			if estimator.lastValue and current < estimator.lastValue then
				estimator.rebirthSpendSerial = estimator.rebirthSpendSerial + 1
			end
			estimator.lastValue = current
			estimator.burstGain = 0
			estimator.burstStartedAt = nil
			estimator.lastPositiveAt = nil
		end

		rebirthUi.rebirthCountLabel.Text = "Rebirths: " .. formatExact(current)
		local targetMode = State.rebirth.autoTarget and State.rebirth.target ~= nil
		local infiniteMode = State.rebirth.infinite
		rebirthUi.objectiveLabel.Visible = State.rebirth.target ~= nil and not infiniteMode
		rebirthUi.objectiveLabel.Text = State.rebirth.target and ("Objetivo: " .. formatExact(State.rebirth.target)) or ""
		rebirthUi.remainingLabel.Visible = targetMode
		rebirthUi.etaLabel.Visible = targetMode
		rebirthUi.cycleLabel.Visible = targetMode
		rebirthUi.summaryRow.Size = UDim2.new(1, 0, 0, targetMode and 106 or 62)

		if targetMode then
			local remaining = math.max(0, State.rebirth.target - current)
			local rate, cycleTime, cycleGain = stableTargetRate()
			local etaText = remaining <= 0 and "Objetivo alcanzado" or "Calculando..."
			if rate and remaining > 0 then
				local rawEta = remaining / rate
				if not estimator.smoothedEta then
					estimator.smoothedEta = rawEta
					estimator.lastEtaUpdate = now
				elseif now - estimator.lastEtaUpdate >= 2 then
					local difference = math.abs(rawEta - estimator.smoothedEta) / math.max(1, estimator.smoothedEta)
					local blend = difference > 0.3 and 0.35 or 0.18
					estimator.smoothedEta = estimator.smoothedEta * (1 - blend) + rawEta * blend
					estimator.lastEtaUpdate = now
				end
				etaText = rebirthDuration(estimator.smoothedEta)
			end
			rebirthUi.remainingLabel.Text = "Faltan: " .. formatExact(remaining)
			rebirthUi.etaLabel.Text = "Tiempo: " .. etaText
			if cycleTime and cycleGain then
				rebirthUi.cycleLabel.Text = "Ciclo: " .. string.format("%.2fs", cycleTime)
					.. "   •   +" .. formatExact(math.floor(cycleGain + 0.5))
					.. "   •   Muestras: " .. #estimator.samples
			else
				rebirthUi.cycleLabel.Text = "Calculando ciclos: " .. #estimator.samples .. "/3"
			end
		else
			rebirthUi.remainingLabel.Text = ""
			rebirthUi.etaLabel.Text = ""
			rebirthUi.cycleLabel.Text = ""
		end
		task.wait(0.25)
	end
end)

addCleanup(function()
	State.rebirth.autoTarget = false
	State.rebirth.infinite = false
	State.rebirth.sizeOne = false
	State.rebirth.autoLift = false
	State.rebirth.autoLiftStartedWeight = false
	State.rebirth.king = false
	State.rebirth.lockPosition = false
	setAutoRep("rebirthFastWeight", false, { "Weight", "Heavy Weight" })
	State.setAutoEgg(false, "rebirth")
	stopThread("rebirthLoop")
	stopThread("rebirthSizeOne")
	stopThread("rebirthAutoLift")
	stopThread("rebirthKing")
	cleanRebirthTrainingTool("Pushups")
	stopThread("rebirthLock")
end)
end
pageSetup()


pageSetup = function()
local rebirthPage = Pages.Rebirths
local ULTIMATES = {
	{ name = "+1 Daily Spin", max = 5 },
	{ name = "+1 Pet Slot", max = 3 },
	{ name = "+10 Item Capacity", max = 6 },
	{ name = "+5% Rep Speed", max = 10 },
	{ name = "Demon Damage", max = 5 },
	{ name = "Galaxy Gains", max = 5 },
	{ name = "Golden Rebirth", max = 5 },
	{ name = "Jungle Swift", max = 5 },
	{ name = "Muscle Mind", max = 5 },
	{ name = "Infernal Health", max = 5 },
	{ name = "x2 Chest Rewards", max = 5 },
	{ name = "x2 Quest Rewards", max = 3 },
}

__FGRoot.CrefyUI.uiAddSection(rebirthPage, "Ultimates")
local ultimateOptions = {}
for _, ultimate in ipairs(ULTIMATES) do
	ultimateOptions[#ultimateOptions + 1] = { label = ultimate.name, name = ultimate.name, data = ultimate }
end

local ultimateSelector
local ultimateAmountSelector
local ultimateLevelValue
local ultimateStatus
local lastUltimateLevel = nil
local ultimateStatusSerial = 0


local function setUltimateStatus(text, duration, fallback)
	if not ultimateStatus then return end
	ultimateStatusSerial = ultimateStatusSerial + 1
	local serial = ultimateStatusSerial
	if ultimateStatus then ultimateStatus.Text = text end
	if duration then
		task.delay(duration, function()
			if serial == ultimateStatusSerial and not State.rebirth.ultimateRunning
				and ultimateStatus and ultimateStatus.Parent then
				ultimateStatus.Text = fallback or "Esperando selección"
			end
		end)
	end
end


local function ultimateLevel(ultimate)
	if not ultimate then return 0 end
	local attributeName = UltimateAttributes[ultimate.name]
	local stored = attributeName and LP:GetAttribute(attributeName)
	if typeof(stored) == "number" then
		return math.max(0, math.floor(stored))
	end
	return 0
end


local function ultimateMaximum(ultimate)
	if not ultimate then return 0 end
	local item = GameUltimatesFolder and GameUltimatesFolder:FindFirstChild(ultimate.name)
	local maximum = item and item:FindFirstChild("maxUpgrades")
	local liveMaximum = maximum and maximum:IsA("ValueBase") and tonumber(maximum.Value)
	return math.max(0, math.floor(liveMaximum or tonumber(ultimate.max) or 0))
end


local function selectedUltimate()
	local selected = ultimateSelector and ultimateSelector:Get()
	return type(selected) == "table" and selected.data or nil
end


local function amountValuesFor(ultimate)
	local available = math.max(0, ultimateMaximum(ultimate) - ultimateLevel(ultimate))
	if available <= 0 then
		return { { label = "Máximo", amount = 0 } }
	end
	local values = {}
	for amount = 1, available do values[#values + 1] = amount end
	return values
end

local refreshingUltimateAmount = false

local function refreshUltimateControls()
	local ultimate = selectedUltimate()
	if not ultimate then return end
	local level = ultimateLevel(ultimate)
	local maximum = ultimateMaximum(ultimate)
	if ultimateLevelValue then
		ultimateLevelValue.Text = formatExact(level) .. " / " .. formatExact(maximum)
	end
	if ultimateAmountSelector then
		refreshingUltimateAmount = true
		ultimateAmountSelector:SetValues(amountValuesFor(ultimate), false)
		refreshingUltimateAmount = false
	end
	lastUltimateLevel = level
end

ultimateSelector = __FGRoot.CrefyUI.uiAddSelector(rebirthPage, "Seleccionar Ultimate", ultimateOptions, function()
	if ultimateAmountSelector then
		refreshUltimateControls()
		if not State.rebirth.ultimateRunning then
			local ultimate = selectedUltimate()
			setUltimateStatus(ultimate and ("Seleccionado: " .. ultimate.name) or "Esperando selección", 5, "Esperando compra")
		end
	end
end, function(row)
	RunService.Heartbeat:Wait()
	local bottom = math.max(0, rebirthPage.AbsoluteCanvasSize.Y - rebirthPage.AbsoluteSize.Y)
	local rowTop = row.AbsolutePosition.Y - rebirthPage.AbsolutePosition.Y + rebirthPage.CanvasPosition.Y - 3
	rebirthPage.CanvasPosition = Vector2.new(0, math.clamp(rowTop, 0, bottom))
end)

ultimateAmountSelector = __FGRoot.CrefyUI.uiAddSelector(rebirthPage, "Cantidad a comprar", { 1, 2, 3 }, function(value)
	if refreshingUltimateAmount then return end
	if not State.rebirth.ultimateRunning then
		local amount = type(value) == "table" and value.amount or tonumber(value)
		if amount and amount > 0 then
			setUltimateStatus("Cantidad seleccionada: " .. formatExact(amount), 5, "Esperando compra")
		end
	end
end)
ultimateLevelValue = __FGRoot.CrefyUI.uiAddInfoRow(rebirthPage, "Nivel seleccionado", "0 / 0", C.cyan)
ultimateStatus = __FGRoot.CrefyUI.uiAddStatusRow(rebirthPage, "Esperando selección")
refreshUltimateControls()

__FGRoot.CrefyUI.uiAddButton(rebirthPage, "Comprar Ultimate", function(button)
	if State.rebirth.ultimateRunning then
		State.rebirth.ultimateRunning = false
		stopThread("ultimateBuyer")
		button.Text = "Comprar Ultimate"
		setUltimateStatus("Compra cancelada", 7, "Esperando selección")
		return
	end
	local ultimate = selectedUltimate()
	local selectedAmount = ultimateAmountSelector:Get()
	local wanted = type(selectedAmount) == "table" and selectedAmount.amount or tonumber(selectedAmount)
	if not ultimate or not wanted or wanted <= 0 then
		setUltimateStatus("Ultimate al máximo", 7, "Esperando selección")
		return
	end
	wanted = math.min(wanted, math.max(0, ultimateMaximum(ultimate) - ultimateLevel(ultimate)))
	State.rebirth.ultimateRunning = true
	button.Text = "Cancelar compra"
	startThread("ultimateBuyer", function()
		local purchased = 0
		local failureMessage = nil
		while State.running and State.rebirth.ultimateRunning and purchased < wanted do
			local events = ReplicatedStorage:FindFirstChild("rEvents")
			local remote = events and events:FindFirstChild("ultimatesRemote")
			if not remote then
				failureMessage = "Remote de Ultimates no disponible"
				break
			end
			local beforeLevel = ultimateLevel(ultimate)
			local maximum = ultimateMaximum(ultimate)
			if beforeLevel >= maximum then
				failureMessage = "Ultimate al máximo"
				break
			end
			setUltimateStatus("Comprando " .. ultimate.name .. " (" .. (purchased + 1) .. "/" .. wanted .. ")")
			local okRequest, accepted = pcall(remote.InvokeServer, remote, "upgradeUltimate", ultimate.name)
			if not okRequest or accepted ~= true then
				setUltimateStatus("Esperando renacimientos suficientes...")
				task.wait(0.8)
			else
				local deadline = realNow() + 8
				local confirmed = false
				while State.running and State.rebirth.ultimateRunning and realNow() < deadline do
					if ultimateLevel(ultimate) > beforeLevel then
						confirmed = true
						break
					end
					task.wait(0.15)
				end
				if confirmed then
					purchased = purchased + 1
				else
					setUltimateStatus("Esperando renacimientos suficientes...")
					task.wait(0.8)
				end
			end
		end
		State.rebirth.ultimateRunning = false
		if button and button.Parent then button.Text = "Comprar Ultimate" end
		refreshUltimateControls()
		local result = failureMessage or (purchased > 0 and ("Compra completada: " .. purchased) or "Sin cambios")
		setUltimateStatus(result, 7, "Esperando selección")
	end)
end, C.row, C.rowHover)

startThread("ultimateCounter", function()
	while State.running and rebirthPage.Parent do
		local ultimate = selectedUltimate()
		if ultimate then
			local level = ultimateLevel(ultimate)
			if level ~= lastUltimateLevel then refreshUltimateControls() end
		end
		task.wait(0.25)
	end
end)

addCleanup(function()
	State.rebirth.ultimateRunning = false
	stopThread("ultimateCounter")
	stopThread("ultimateBuyer")
end)
end
pageSetup()


pageSetup = function()
local killsPage = Pages.Kills
__FGRoot.CrefyUI.uiAddSection(killsPage, "Kills")
local killCounterValue, killCounterRow, killCounterLabel = __FGRoot.CrefyUI.uiAddInfoRow(killsPage, "Kills:", "0", C.cyan)
killCounterValue.Font = C.fontBold
killCounterValue.TextSize = 17
killCounterLabel.Font = C.fontBold
killCounterLabel.TextSize = 15
killCounterLabel.TextColor3 = C.soft
killCounterRow.Size = UDim2.new(1, 0, 0, 38)
local brawlValue,brawlRow,brawlLabel=__FGRoot.CrefyUI.uiAddInfoRow(killsPage,"Brawls","—",C.blue)
brawlValue.Font=C.fontBold; brawlValue.TextSize=15; brawlLabel.Font=C.fontBold; brawlLabel.TextSize=13
local killSummaryCard=Instance.new("Frame")
killSummaryCard.Name="KillSummaryCard"; killSummaryCard.Size=UDim2.new(1,0,0,40); killSummaryCard.BackgroundColor3=Color3.fromRGB(11,14,28); killSummaryCard.BackgroundTransparency=.08; killSummaryCard.BorderSizePixel=0; killSummaryCard.LayoutOrder=killCounterRow.LayoutOrder; killSummaryCard.ZIndex=10; killSummaryCard.ClipsDescendants=true; killSummaryCard.Parent=killsPage
Instance.new("UICorner",killSummaryCard).CornerRadius=UDim.new(0,10); addRgbStroke(killSummaryCard,1,.18)
for index,row in ipairs({killCounterRow,brawlRow}) do row.Parent=killSummaryCard; row.LayoutOrder=index; row.Position=UDim2.new((index-1)*.5,index==1 and 0 or 3,0,1); row.Size=UDim2.new(.5,-3,0,38); row.BackgroundTransparency=1; for _,child in ipairs(row:GetChildren()) do if child:IsA("UIStroke") then child.Transparency=1 end end end
local killSummaryDivider=Instance.new("Frame",killSummaryCard); killSummaryDivider.Size=UDim2.fromOffset(1,24); killSummaryDivider.Position=UDim2.new(.5,0,0,8); killSummaryDivider.BackgroundColor3=C.blue; killSummaryDivider.BackgroundTransparency=.72; killSummaryDivider.BorderSizePixel=0; killSummaryDivider.ZIndex=12
State.kill.sessionBrawls=tonumber(State.resume and State.resume.sessionBrawls) or 0
State.kill.brawlCounterValue=brawlValue
local lastWins=nil
startThread("brawlCounter",function()
 while State.running do
  local stat=getPlayerStat(LP,{"Brawls","Fights","Fight"})
  local wins=stat and tonumber(State.getFunctionalStatValue(stat))
  if wins then
   if lastWins and wins>lastWins then State.kill.sessionBrawls=State.kill.sessionBrawls+(wins-lastWins) end
   lastWins=wins; brawlValue.Text=formatExact(wins).."  (+"..formatExact(State.kill.sessionBrawls)..")"
  else brawlValue.Text="—" end
  task.wait(.5)
 end
end)
local killRateCard = Instance.new("Frame")
killRateCard.Name = "KillRateCard"
killRateCard.Size = UDim2.new(1, -8, 0, 68)
killRateCard.Position = UDim2.fromOffset(4, 43)
killRateCard.BackgroundColor3 = Color3.fromRGB(11, 14, 28)
killRateCard.BackgroundTransparency = 0.10
killRateCard.BorderSizePixel = 0
killRateCard.LayoutOrder = 3
killRateCard.ZIndex = 11
killRateCard.Parent = killSummaryCard
Instance.new("UICorner", killRateCard).CornerRadius = UDim.new(0, 10)
addRgbStroke(killRateCard, 1, 0.22)
local killRateTitle = Instance.new("TextLabel")
killRateTitle.Size = UDim2.new(1, -16, 0, 16)
killRateTitle.Position = UDim2.fromOffset(8, 1)
killRateTitle.BackgroundTransparency = 1
killRateTitle.Text = "Ritmo estimado"
killRateTitle.TextColor3 = C.soft
killRateTitle.Font = C.fontBold
killRateTitle.TextSize = 10
killRateTitle.TextXAlignment = Enum.TextXAlignment.Left
killRateTitle.ZIndex = 12
killRateTitle.Parent = killRateCard
local killRateGrid = Instance.new("Frame")
killRateGrid.Size = UDim2.new(1, -12, 0, 32)
killRateGrid.Position = UDim2.fromOffset(6, 17)
killRateGrid.BackgroundTransparency = 1
killRateGrid.ZIndex = 12
killRateGrid.Parent = killRateCard
local killRateLayout = Instance.new("UIGridLayout")
killRateLayout.CellSize = UDim2.new(0.3333, -4, 1, 0)
killRateLayout.CellPadding = UDim2.fromOffset(6, 0)
killRateLayout.FillDirectionMaxCells = 3
killRateLayout.SortOrder = Enum.SortOrder.LayoutOrder
killRateLayout.Parent = killRateGrid
local killRateValues = {}
for index, titleText in ipairs({ "POR HORA", "POR DÍA", "POR SEMANA" }) do
	local cell = Instance.new("Frame")
	cell.BackgroundColor3 = Color3.fromRGB(20, 24, 43)
	cell.BackgroundTransparency = 1
	cell.BorderSizePixel = 0
	cell.LayoutOrder = index
	cell.ZIndex = 12
	cell.Parent = killRateGrid
	Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 8)
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -8, 0, 12)
	title.Position = UDim2.fromOffset(4, 0)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.TextColor3 = C.dim
	title.Font = C.fontBold
	title.TextSize = 8
	title.ZIndex = 13
	title.Parent = cell
	local value = Instance.new("TextLabel")
	value.Size = UDim2.new(1, -8, 0, 19)
	value.Position = UDim2.fromOffset(4, 12)
	value.BackgroundTransparency = 1
	value.Text = "--"
	value.TextColor3 = index == 1 and C.cyan or (index == 2 and C.blue or C.green)
	value.Font = C.fontBold
	value.TextScaled = true
	value.ZIndex = 13
	value.Parent = cell
	local limit = Instance.new("UITextSizeConstraint")
	limit.MinTextSize = 9
	limit.MaxTextSize = 13
	limit.Parent = value
	killRateValues[index] = value
end
local killRateDetail = Instance.new("TextLabel")
killRateDetail.Size = UDim2.new(1, -16, 0, 15)
killRateDetail.Position = UDim2.new(0, 8, 1, -17)
killRateDetail.BackgroundTransparency = 1
killRateDetail.Text = "Activá un modo de kills para comenzar."
killRateDetail.TextColor3 = C.dim
killRateDetail.Font = UI_FONT
killRateDetail.TextSize = 9
killRateDetail.TextTruncate = Enum.TextTruncate.AtEnd
killRateDetail.ZIndex = 12
killRateDetail.Parent = killRateCard
local function formatKillSessionTime(seconds)
	seconds = math.max(0, math.floor(tonumber(seconds) or 0))
	return string.format("%02d:%02d:%02d", math.floor(seconds / 3600), math.floor(seconds % 3600 / 60), seconds % 60)
end
killRateCard.Size=UDim2.new(1,-8,0,24)
killRateCard.Position=UDim2.fromOffset(4,42)
killRateCard.BackgroundTransparency=.28
killRateTitle.Size=UDim2.new(.34,-8,1,0)
killRateTitle.Position=UDim2.fromOffset(9,0)
killRateTitle.Text="Calculadora:"
killRateTitle.TextSize=10
killRateTitle.TextYAlignment=Enum.TextYAlignment.Center
killRateGrid.Visible=false
killRateDetail.Visible=false
local killRateCompactValue=Instance.new("TextLabel")
killRateCompactValue.Name="Estimate"
killRateCompactValue.Size=UDim2.new(.66,-12,1,0)
killRateCompactValue.Position=UDim2.new(.34,4,0,0)
killRateCompactValue.BackgroundTransparency=1
killRateCompactValue.Text="--/h · --/d · --/w"
killRateCompactValue.TextColor3=C.cyan
killRateCompactValue.Font=C.fontBold
killRateCompactValue.TextSize=10
killRateCompactValue.TextXAlignment=Enum.TextXAlignment.Right
killRateCompactValue.TextTruncate=Enum.TextTruncate.AtEnd
killRateCompactValue.ZIndex=13
killRateCompactValue.Parent=killRateCard
State.kill.rateCompactValue=killRateCompactValue
State.kill.updateSessionCounter=function(kills,active)
 local elapsed=State.getKillSessionElapsed and State.getKillSessionElapsed() or 0
 local amount=math.max(0,tonumber(kills) or 0)
 killRateCard.Visible=true
 killSummaryCard.Size=UDim2.new(1,0,0,70)
 local cycle=math.max(1,tonumber(State.kill.serverHopInterval) or CONFIG.ServerHop.Interval)
 if not active then
  killRateCompactValue.Text=State.kill.lastEstimate and State.kill.lastEstimate.text or "--/h · --/d · --/w"
  return
 end
 if elapsed<cycle then
  killRateCompactValue.Text="Midiendo · "..tostring(math.floor(elapsed)).."/"..tostring(cycle).."s"
  return
 end
 local rate=amount/math.max(1,elapsed)
 local values={}
 for i,m in ipairs({3600,86400,604800}) do values[i]=math.floor(rate*m) end
 local compact=State.formatExactWithUnit
 local text=compact(values[1]).."/h · "..compact(values[2]).."/d · "..compact(values[3]).."/w"
 killRateCompactValue.Text=text
 State.kill.lastEstimate={rate=rate,text=text,kills=amount,elapsed=elapsed}
end
killRateCard.Visible=true
killSummaryCard.Size=UDim2.new(1,0,0,70)
local autoKillToggle
local evilKarmaToggle
local goodKarmaToggle
local targetKillToggle
local protectFriendsToggle
local serverHopToggle
local autoWinBrawlToggle

local function revealKillsSelector(row)
	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	local bottom = math.max(0, killsPage.AbsoluteCanvasSize.Y - killsPage.AbsoluteSize.Y)
	local rowTop = row.AbsolutePosition.Y - killsPage.AbsolutePosition.Y + killsPage.CanvasPosition.Y - 3
	TweenService:Create(killsPage, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		CanvasPosition = Vector2.new(0, math.clamp(rowTop, 0, bottom)),
	}):Play()
end

local function disableOtherKillModes(activeToggle)
	for _, toggle in ipairs({ autoKillToggle, evilKarmaToggle, goodKarmaToggle, targetKillToggle }) do
		if toggle and toggle ~= activeToggle and toggle:Get() then
			toggle:Set(false)
		end
	end
end
autoKillToggle = __FGRoot.CrefyUI.uiAddToggle(killsPage, "Auto Kill", function(enabled)
	if enabled then
		disableOtherKillModes(autoKillToggle)
	end
	return State.setAutoKill(enabled)
end)
State.kill.serverHopInterval = CONFIG.ServerHop.Interval
serverHopToggle = __FGRoot.CrefyUI.uiAddToggle(killsPage, "Server Hop inteligente", function(enabled)
	if enabled and targetKillToggle and targetKillToggle:Get() then
		return false
	end
	local accepted = State.setServerHop(enabled)
	if accepted ~= false and State.serverHopPageToggle then State.serverHopPageToggle:Set(enabled, true) end
	return accepted
end)
autoWinBrawlToggle = __FGRoot.CrefyUI.uiAddToggle(killsPage, "Auto Win Brawl", function(enabled)
	return State.setAutoWinBrawl(enabled)
end)
protectFriendsToggle = __FGRoot.CrefyUI.uiAddToggle(killsPage, "No matar a mis amigos", function(enabled)
	return State.setProtectFriends(enabled)
end)

State.kill.updateHopStatus = function() end
evilKarmaToggle = __FGRoot.CrefyUI.uiAddToggle(killsPage, "Evil Karma", function(enabled)
	if enabled then
		disableOtherKillModes(evilKarmaToggle)
	end
	return State.setKarmaKill("evil", enabled)
end)
goodKarmaToggle = __FGRoot.CrefyUI.uiAddToggle(killsPage, "Good Karma", function(enabled)
	if enabled then
		disableOtherKillModes(goodKarmaToggle)
	end
	return State.setKarmaKill("good", enabled)
end)
local killSelector = __FGRoot.CrefyUI.uiAddSelector(killsPage, "Seleccionar jugador", playerOptions(), function(value)
	State.kill.target = type(value) == "table" and value.name or value
end, revealKillsSelector)
targetKillToggle = __FGRoot.CrefyUI.uiAddToggle(killsPage, "Matar jugador", function(enabled)
	if enabled then
		disableOtherKillModes(targetKillToggle)
		if serverHopToggle and serverHopToggle:Get() then
			serverHopToggle:Set(false)
		end
	end
	return State.setTargetKill(enabled)
end)
State.killSelector = killSelector
State.killAutoToggle = autoKillToggle
State.killEvilToggle = evilKarmaToggle
State.killGoodToggle = goodKarmaToggle
State.killTargetToggle = targetKillToggle
State.killProtectToggle = protectFriendsToggle
State.killServerHopToggle = serverHopToggle
State.killAutoWinBrawlToggle = autoWinBrawlToggle
State.killServerHopTimeSelector = nil
startThread("killCounter", function()
	while State.running and killCounterValue.Parent do
		local stat = getPlayerStat(LP, { "Kills" })
		local current = stat and tonumber(stat.Value) or 0
		killCounterValue.Text = formatExact(current)
		if type(State.updateKillSession) == "function" then
			State.updateKillSession(current)
		end
		task.wait(0.5)
	end
end)
end
pageSetup()


pageSetup = function()
local afkPage = Pages["AFK 24/7"]
afkPage:SetAttribute("TightCanvas", true)
local modes = {"Auto Rebirth", "Auto Farm Kills", "Auto Strength", "Durabilidad + Fuerza"}
local descriptions = {
    "La mejor opción para el usuario",
    "Auto Kill · Auto Win Brawl · Server Hop · Anti Lag",
    "Tus mejores pets · La mejor máquina disponible",
    "La mejor roca · Punch y ejercicios combinados",
}
State.afk.mode = "Auto Rebirth"
local owned = {}
local directFastFarmStart = FastFarm.Start
local serial = 0
local pending = false
local requestSerial = 0
local exercise = nil
local lastRock = nil
local af = { blocked = setmetatable({}, {__mode="k"}), nextPets = 0, nextMachine = 0, nextRep = 0,
    nextUpgrade = 0, nextExerciseSwitch = 0, exerciseIndex = 0, exerciseWindow = false }
local tiles, detail = {}, {}
local welcome=Instance.new("TextLabel")
welcome.Name="AfkWelcome"; welcome.Text="Elegí qué querés farmear"; welcome.BackgroundTransparency=1
welcome.Size=UDim2.new(1,0,0,42); welcome.LayoutOrder=0; welcome.Font=Enum.Font.GothamMedium
welcome.TextSize=18; welcome.TextColor3=C.white; welcome.TextWrapped=true; welcome.ZIndex=12
welcome:SetAttribute("KeepTextStyle",true); welcome.Parent=afkPage
local header=Instance.new("Frame")
header.Name="AfkHeader"; header.BackgroundTransparency=1; header.Size=UDim2.new(1,0,0,30)
header.LayoutOrder=0; header.Parent=afkPage
local heading=welcome:Clone(); heading.Name="ModeTitle"; heading.Size=UDim2.new(1,-76,1,0)
heading.Position=UDim2.fromOffset(38,0); heading.Text="Auto Rebirth"; heading.TextSize=15; heading.Parent=header
local grid = Instance.new("Frame")
grid.Name = "AfkModes"
grid.Size = UDim2.new(1, 0, 0, 162)
grid.BackgroundTransparency = 1
grid.LayoutOrder = nextOrder(afkPage)
grid.Parent = afkPage
local layout = Instance.new("UIGridLayout", grid)
layout.CellSize = UDim2.new(0.5, -5, 0, 76)
layout.CellPadding = UDim2.fromOffset(10, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
local status,statusRow,statusTitle = __FGRoot.CrefyUI.uiAddInfoRow(afkPage, "", "Elegí tu modo", C.dim, false, false)
statusRow.BackgroundTransparency=1; statusRow.Size=UDim2.new(1,0,0,0); statusRow.LayoutOrder=6; statusRow.Visible=false
statusTitle.Visible=false; status.Size=UDim2.fromScale(1,1); status.Position=UDim2.new()
status.TextXAlignment=Enum.TextXAlignment.Center; status:SetAttribute("KeepTextStyle",true); status.TextSize=11
for _,o in ipairs(statusRow:GetDescendants()) do if o:IsA("UIStroke") then o.Transparency=1 end end
local timer,timerRow = __FGRoot.CrefyUI.uiAddInfoRow(afkPage, "Tiempo:", "00:00:00", C.soft)
timerRow.Size=UDim2.new(1,0,0,24); timerRow.LayoutOrder=4
local counterRow = __FGRoot.CrefyUI.uiAddSection(afkPage, "Resultados")
local function meter(titleText)
    local value, _, title = __FGRoot.CrefyUI.uiAddInfoRow(afkPage, titleText, "0", C.white)
    local gain = __FGRoot.CrefyUI.uiAddInfoRow(afkPage, titleText .. " ganancia", "+0", C.green)
    gain.Visible = false
    return { Title = title, Value = value, Gain = gain }
end
local leftCounter = meter("Fuerza")
local rightCounter = meter("Rebirths")
local selector, toggle, back
local function tr(s) return State.translateText and State.translateText(s) or s end
local function control(key, value)
    local c = State.profileControls[key]
    if not c then return false end
    if value then
        if not c:Get() then
            if c:Set(true) ~= true then return false end
            owned[key] = true
        end
    elseif owned[key] then c:Set(false); owned[key] = nil end
    return true
end
local function enableAfkProtection(includeConnectionTools)
    control("Misc|Anti Lag 100%", true)
    if includeConnectionTools then
        control("Misc|FullBright", true)
        control("Misc|🛡️ Anti Crash 🛡️", true)
        control("Misc|📶 Ping Reducer 📶", true)
    end
end
local function train(key)
    if exercise == key then return end
    for _, item in ipairs({{"afkWeight", {"Weight", "Heavy Weight"}}, {"afkPushups", {"Pushups", "Pushup"}}, {"afkHandstands", {"Handstands", "Handstand"}}, {"afkSitups", {"Situps", "Situp"}}}) do
        setAutoRep(item[1], item[1] == key, item[2], 0.05, true)
    end
    exercise = key
end
local function requirement(names)
    local char, bag = getCharacter(), LP:FindFirstChild("Backpack")
    for _, name in ipairs(names) do
        local tool = char and char:FindFirstChild(name) or bag and bag:FindFirstChild(name)
        if tool and tool:IsA("Tool") then
            local need = tool:FindFirstChild("requiredAmount")
            local kind = need and need:FindFirstChild("requiredType")
            local stat = getPlayerStat(LP, {kind and tostring(kind.Value) or "Strength"})
            local amount = stat and tonumber(State.getFunctionalStatValue(stat)) or 0
            return amount >= (need and tonumber(need.Value) or 0), tool
        end
    end
    return false
end
local combinedExercises = {
    {"afkPushups", {"Pushups", "Pushup"}},
    {"afkHandstands", {"Handstands", "Handstand"}},
    {"afkSitups", {"Situps", "Situp"}},
}
function af.rotateCombinedExercise(now)
    if now < af.nextExerciseSwitch then return end
    if af.exerciseWindow then
        train(nil)
        State.fastPunchToolPaused = false
        af.exerciseWindow = false
        af.nextExerciseSwitch = now + 1.15
        return
    end
    local selectedKey
    for _ = 1, #combinedExercises do
        af.exerciseIndex = af.exerciseIndex % #combinedExercises + 1
        local option = combinedExercises[af.exerciseIndex]
        if requirement(option[2]) then selectedKey = option[1]; break end
    end
    if not selectedKey then
        local weightReady = requirement({"Weight", "Heavy Weight"})
        selectedKey = weightReady and "afkWeight" or nil
    end
    if selectedKey then
        State.fastPunchToolPaused = true
        train(selectedKey)
        af.exerciseWindow = true
        af.nextExerciseSwitch = now + 0.45
    else
        train(nil)
        State.fastPunchToolPaused = false
        af.nextExerciseSwitch = now + 1.15
    end
end
function af.bestPets()
    local folder = LP:FindFirstChild("petsFolder")
    local catalog = {}
    for _, item in ipairs(FastFarm:GetPackCatalog()) do catalog[item.name] = item end
    local candidates, groups, common = {}, {}, {}
    local cap = FastFarm:GetPetSlotCapacity()
    for _, category in ipairs(folder and folder:GetChildren() or {}) do
        for _, pet in ipairs(category:IsA("Folder") and category:GetChildren() or {}) do
            if pet:IsA("StringValue") then
                local perks = pet:FindFirstChild("perksFolder")
                local strength = perks and perks:FindFirstChild("strength")
                local durability = perks and perks:FindFirstChild("durability")
                local pack = catalog[pet.Name]
                local data = {pet=pet, name=pet.Name, strength=tonumber(strength and strength.Value) or 0,
                    durability=tonumber(durability and durability.Value) or 0,
                    speed=tonumber(pack and pack.repSpeed) or 0,
                    boost=tonumber(pack and pack.strengthBonus) or 0,
                    momentum=tonumber(pet:GetAttribute("MomentumSeconds")) or 0}
                if data.strength > 0 or data.durability > 0 or data.speed > 0 or data.boost > 0 then
                    candidates[#candidates+1] = data
                    if data.speed > 0 or data.boost > 0 then
                        groups[data.name] = groups[data.name] or {}
                        table.insert(groups[data.name], data)
                    else common[#common+1] = data end
                end
            end
        end
    end
    local function order(a,b)
        if a.strength ~= b.strength then return a.strength > b.strength end
        if a.durability ~= b.durability then return a.durability > b.durability end
        if a.momentum ~= b.momentum then return a.momentum > b.momentum end
        return a.pet:GetFullName() < b.pet:GetFullName()
    end
    table.sort(common, order)
    local kinds = {}
    for name, list in pairs(groups) do
        table.sort(list, order)
        kinds[#kinds+1] = {name=name, list=list}
    end
    table.sort(kinds,function(a,b) return a.name<b.name end)
    local best, bestScore, bestDurability, bestMomentum = {}, -1, -1, -1
    local chosen, visits = {}, 0
    local function consider()
        local picks, strength, speed, boost, durability, momentum = {}, 0, 0, 0, 0, 0
        for _, data in ipairs(chosen) do picks[#picks+1]=data end
        for i=1, math.min(cap-#picks,#common) do picks[#picks+1]=common[i] end
        for _, data in ipairs(picks) do
            strength=strength+data.strength; speed=speed+data.speed; boost=boost+data.boost
            durability=durability+data.durability; momentum=momentum+data.momentum
        end
        local speedFactor = speed>=1 and 120 or 1/math.max(.01,1-speed)
        local score = (1+strength)*(1+boost)*speedFactor
        if score > bestScore or (score == bestScore and (#picks > #best
            or (#picks == #best and (durability > bestDurability
            or (durability == bestDurability and momentum > bestMomentum))))) then
            best,bestScore,bestDurability,bestMomentum = picks,score,durability,momentum
        end
    end
    local function walk(index)
        if visits >= 12000 then return end
        visits=visits+1
        if index > #kinds or #chosen == cap then consider(); return end
        local list = kinds[index].list
        local before = #chosen
        for count=0,math.min(cap-before,#list) do
            if count > 0 then chosen[#chosen+1]=list[count] end
            walk(index+1)
        end
        for i=#chosen,before+1,-1 do chosen[i]=nil end
    end
    walk(1)
    if visits >= 12000 then
        table.sort(candidates,function(a,b)
            local sa=(1+a.strength)*(1+a.boost)*(a.speed>=1 and 120 or 1/math.max(.01,1-a.speed))
            local sb=(1+b.strength)*(1+b.boost)*(b.speed>=1 and 120 or 1/math.max(.01,1-b.speed))
            return sa~=sb and sa>sb or (sa==sb and order(a,b))
        end)
        table.clear(chosen)
        for i=1,math.min(cap,#candidates) do chosen[i]=candidates[i] end
        consider()
    end
    local setup, byName, selected, speed = {}, {}, {}, 0
    for _, data in ipairs(best) do
        local part=byName[data.name]
        if not part then part={name=data.name,count=0,pets={}}; byName[data.name]=part; setup[#setup+1]=part end
        part.count=part.count+1; part.pets[#part.pets+1]=data.pet; selected[data.pet]=true
        speed=speed+data.speed
    end
    table.sort(setup,function(a,b) return a.name<b.name end)
    return setup,selected,#best,speed
end
function af.ensurePets(now)
    if now < af.nextPets then return end
    af.nextPets=now+8
    local setup,selected,count,speed=af.bestPets()
    if count==0 then State.afk.petCount=0; af.repBoost=0; return end
    local equipped,matched,total=LP:FindFirstChild("equippedPets"),0,0
    for _,slot in ipairs(equipped and equipped:GetChildren() or {}) do
        local ref=slot:FindFirstChild("petReference")
        local pet=ref and ref:IsA("ObjectValue") and ref.Value
        if pet then total=total+1; if selected[pet] then matched=matched+1 end end
    end
    if matched~=count or total~=count then
        State.afk.phase="Equipando tus mejores pets"
        matched=FastFarm.EquipSetup(setup,"afk-strength")
        if matched<count then af.nextPets=os.clock()+3 end
    end
    State.afk.petCount=matched
    af.repBoost=speed
end
function af.releaseMachine()
    local definition=af.definition
    af.machine,af.seat,af.definition=nil,nil,nil
    if definition and State.machine==definition then
        State.machine=nil
        leaveMachine()
    end
end
function af.chooseMachine(now)
    local folder=workspace:FindFirstChild("machinesFolder")
    local candidates={}
    for _,machine in ipairs(folder and folder:GetChildren() or {}) do
        local gain=machine:FindFirstChild("strengthGain")
        if machine:IsA("Model") and gain and tonumber(gain.Value) and tonumber(gain.Value)>0
            and not machine.Name:lower():find("king",1,true) and (af.blocked[machine] or 0)<=now then
            local definition={object=machine.Name,instance=machine,autoFarm=true,repInterval=.04}
            local resolved,seat=getMachineParts(definition)
            if resolved and seat then
                definition.score=tonumber(gain.Value)/machineRepDelay(machine)
                definition.seat=seat
                candidates[#candidates+1]=definition
            end
        end
    end
    local root=getRoot()
    table.sort(candidates,function(a,b)
        if a.score~=b.score then return a.score>b.score end
        local p=root and root.Position or Vector3.zero
        return (a.seat.Position-p).Magnitude<(b.seat.Position-p).Magnitude
    end)
    return candidates[1]
end
function af.strength(now,id)
    af.ensurePets(now)
    if not State.afk.active or serial~=id then return end
    if af.machine and now>=af.nextUpgrade then
        af.nextUpgrade=now+12
        local better=af.chooseMachine(now)
        local gain=af.machine:FindFirstChild("strengthGain")
        local current=(tonumber(gain and gain.Value) or 0)/machineRepDelay(af.machine)
        if better and better.instance~=af.machine and better.score>current*1.02 then
            af.releaseMachine(); af.nextMachine=0
        end
    end
    if af.machine and machineIsActive(af.machine,af.seat,getHumanoid()) then
        train(nil)
        State.afk.phase=af.machine.Name.." · "..tostring(State.afk.petCount or 0).." pets"
        if now>=af.nextRep then
            local ping=getPing()
            local delay=af.repBoost and af.repBoost>=1 and .05 or machineRepDelay(af.machine)
            local batch=af.repBoost and af.repBoost>=1 and 6 or 1
            if ping>=700 then delay=.3; batch=1 elseif ping>=450 then delay=math.max(delay,.15); batch=1 end
            af.nextRep=now+delay
            local remote=LP:FindFirstChild("muscleEvent") or ReplicatedStorage:FindFirstChild("muscleEvent")
            if remote and remote:IsA("RemoteEvent") then
                for _=1,batch do pcall(remote.FireServer,remote,"rep",af.seat) end
                if batch>0 then FastFarm.MachineVisuals.playRep(af.machine,af.repBoost>=1 and 8 or nil) end
            end
        end
        return
    end
    if now<af.nextMachine then State.afk.phase="Esperando una máquina libre"; return end
    af.nextMachine=now+3
    local definition=af.definition
    if not definition or not definition.instance or not definition.instance.Parent
        or (af.blocked[definition.instance] or 0)>now then definition=af.chooseMachine(now) end
    if not definition then
        af.releaseMachine()
        local pushups=requirement({"Pushups","Pushup"})
        train(pushups and "afkPushups" or "afkWeight")
        State.afk.phase="Entrenando mientras se libera una máquina"
        return
    end
    train(nil)
    af.releaseMachine()
    af.definition=definition; State.machine=definition
    State.afk.phase="Subiendo a "..definition.object
    local ready,machine,seat,reason=useMachine(definition,3,.35)
    if not State.afk.active or serial~=id then return end
    if ready then
        af.machine,af.seat=machine,seat
        af.nextRep=0
        FastFarm.MachineVisuals.playIdle(machine,seat)
    else
        if reason=="occupied" then
            af.blocked[definition.instance]=os.clock()+3
            af.releaseMachine()
            State.afk.phase="Máquina ocupada · buscando otra"
        else
            af.machine,af.seat=nil,nil
            af.definition=definition
            State.machine=definition
            af.nextMachine=os.clock()+.65
            State.afk.phase="Confirmando "..definition.object
        end
    end
end
local function stop(keepToggle)
    serial = serial + 1
    State.afk.active = false
    if State.afk.startedAt then State.afk.elapsed = os.clock() - State.afk.startedAt end
    State.afk.startedAt = nil
    if threads.afkWorker ~= coroutine.running() then stopThread("afkWorker") end
    if State.afk.proRebirth and FastFarm.mode=="rebirth" then FastFarm:Stop(true) end
    if State.afk.proRebirth and FastFarm.RebirthToggle then FastFarm.RebirthToggle:Set(false,true) end
    State.afk.proRebirth=false
    State.fastPunchToolPaused=false
    af.exerciseWindow=false
    af.nextExerciseSwitch=0
    train(nil)
    for key in pairs(owned) do control(key, false) end
    if lastRock then clearRockSelection(); setFastPunch(false); lastRock = nil end
    af.releaseMachine()
    State.setAutoEgg(false, "afk")
    if State.afk.previousRepMode then State.autoFarmMode = State.afk.previousRepMode; State.afk.previousRepMode = nil end
    if toggle and not keepToggle then toggle:Set(false, true) end
    State.afk.phase = ""
end
State.afkStop = stop
local function show(selected)
    grid.Visible = not selected
    welcome.Visible=not selected
    header.Visible=selected==true
    statusRow.Visible=false
    heading.Text=State.afk.mode
    for _, object in ipairs(detail) do object.Visible = selected == true end
end
State.afkShowSelected=show
local function start()
    if State.afk.active and State.afk.runningMode==State.afk.mode then return true end
    if pending then return false, "Esperando respuesta del servidor" end
    local selected = State.afk.mode
    local continued=af.resumeNext
    af.resumeNext=nil
    if not continued and not af.resumeApplied and State.resume and State.resume.afkMode==selected then
        continued=State.resume.afkSession
        af.resumeApplied=true
    end
    if type(continued)~="table" or continued.mode~=selected then continued=nil end
    if selected == "Auto Farm Kills" and not State.killAutoToggle then return false, "No disponible" end
    stop(true)
    if FastFarm.PetMomentum and FastFarm.PetMomentum.mode then FastFarm.PetMomentum:Stop(true) end
    if FastFarm.mode then FastFarm:Stop(true) end
    if FastFarm.RebirthToggle then FastFarm.RebirthToggle:Set(false, true) end
    if FastFarm.StrengthToggle then FastFarm.StrengthToggle:Set(false, true) end
    for _, c in ipairs(FastFarm.RepToggles or {}) do if c:Get() then c:Set(false) end end
    for _, c in ipairs(FastFarm.MachineToggles or {}) do if c:Get() then c:Set(false) end end
    for _, c in ipairs(FastFarm.FullTrainToggles or {}) do if c:Get() then c:Set(false) end end
    for key, c in pairs(State.profileControls) do
        if c.ProfileKind == "toggle" and c:Get() and (key:sub(1,9)=="Rebirths|"
            or key:sub(1,15)=="Fast Glitch 100%" or key=="Kills|Auto Kill"
            or key=="Kills|Auto Win Brawl" or key=="Kills|Server Hop inteligente"
            or key=="Server Hop|Mantener objetivo automáticamente") then c:Set(false) end
    end
    if State.machine then setMachine(nil,false) end
    clearRockSelection(); setFastPunch(false)
    State.afk.active = true
    State.afk.runningMode=selected
    State.afk.startedAt = os.clock()
    State.afk.elapsed = 0
    State.afk.gain = 0
    State.afk.autoEgg=true
    af.nextPets,af.nextMachine,af.nextRep,af.nextUpgrade=0,0,0,0
    af.nextExerciseSwitch,af.exerciseIndex,af.exerciseWindow=0,0,false
    State.fastPunchToolPaused=false
    State.afk.previousRepMode = State.autoFarmMode
    State.autoFarmMode = "Fast Rep"
    State.afk.base = FastFarm:ReadStats()
    for _,entry in ipairs({{"durability",{"Durability"}},{"kills",{"Kills"}},{"brawls",{"Brawls","Brawl Wins","Brawls Won","brawls"}}}) do
        local stat=getPlayerStat(LP,entry[2])
        State.afk.base[entry[1]]=stat and tonumber(State.getFunctionalStatValue(stat)) or 0
    end
    if continued then
        local elapsed=math.max(0,tonumber(continued.elapsed) or 0)
        State.afk.startedAt=os.clock()-elapsed
        State.afk.elapsed=elapsed
        State.afk.gain=math.max(0,tonumber(continued.gain) or 0)
        for _,entry in ipairs({{"strength","baseStrength"},{"durability","baseDurability"},{"kills","baseKills"},{"brawls","baseBrawls"},{"rebirths","baseRebirths"}}) do
            local value=tonumber(continued[entry[2]])
            if value and value>=0 then State.afk.base[entry[1]]=value end
        end
    end
    State.setAutoEgg(true, "afk")
    local id = serial
    local last = FastFarm:ReadStats().rebirths or 0
    local nextRequestAt = 0
    local lastProgressAt = os.clock()
    local previousStrength = State.afk.base.strength or 0
    if selected == "Auto Farm Kills" then
        enableAfkProtection(false)
        if not control("Kills|Auto Kill", true) then stop(); return false, "No se pudo iniciar Auto Kill" end
        if not control("Kills|Auto Win Brawl", true) then stop(); return false, "No se pudo iniciar Auto Win Brawl" end
        State.kill.serverHopMode="full"
        if State.serverHopModeSelector then State.serverHopModeSelector:SetValue("Con mucha gente") end
        if not control("Kills|Server Hop inteligente", true) then stop(); return false, "Reconexión no disponible" end
    elseif selected == "Auto Rebirth" then
        local strengthAvailable,rebirthAvailable=FastFarm:LoadPack(true)
        local proReady=strengthAvailable and rebirthAvailable and FastFarm.strengthPackCount>0
            and FastFarm.rebirthPackCount>0 and FastFarm.expectedRebirthDelta>0
        if proReady then
            enableAfkProtection(true)
            FastFarm.warningAccepted=true
            local started=directFastFarmStart(FastFarm,"rebirth")
            if not started then stop(); return false,FastFarm.lastError or "No se pudo iniciar Rebirths rápidos" end
            State.afk.proRebirth=true
            if FastFarm.RebirthToggle then FastFarm.RebirthToggle:Set(true,true) end
            State.afk.phase="Rebirths rápidos · "..tostring(FastFarm.rebirthPackCount).." packs detectados"
        else
            control("Rebirths|King", true)
            State.afk.phase="Auto Rebirth adaptado sin packs"
        end
    end
    State.pushOutput("ON", "AFK: " .. selected)
    startThread("afkWorker", function()
        local succeeded,problem=pcall(function()
        while State.running and State.afk.active and serial == id do
            local stats = FastFarm:ReadStats()
            local char, humanoid = getCharacter(), getHumanoid()
            local now = os.clock()
            if FastFarm.mode and not (selected=="Auto Rebirth" and State.afk.proRebirth and FastFarm.mode=="rebirth") then stop(); break end
            if not char or not humanoid or humanoid.Health <= 0 then
                train(nil); af.releaseMachine(); State.afk.phase = "Esperando personaje"
            elseif selected == "Auto Farm Kills" then
                State.afk.phase = State.kill.hopInProgress and "Cambiando de servidor" or "Buscando objetivos"
                local total=getPlayerStat(LP,{"Kills"})
                State.afk.gain = math.max(0,(total and tonumber(State.getFunctionalStatValue(total)) or 0)-(State.afk.base.kills or 0))
                if not State.kill.auto and not State.kill.hopInProgress then control("Kills|Auto Kill", true) end
            else
                if stats.strength ~= previousStrength then lastProgressAt = now; previousStrength = stats.strength end
                if selected == "Auto Rebirth" then
                    if State.afk.proRebirth then
                        if stats.rebirths>last then
                            State.afk.gain=State.afk.gain+stats.rebirths-last
                            last=stats.rebirths
                        end
                        State.afk.phase=FastFarm.mode=="rebirth"
                            and ("Rebirths rápidos · +"..tostring(State.afk.gain))
                            or "Recuperando Rebirths rápidos"
                        if FastFarm.mode~="rebirth" and now>=nextRequestAt then
                            nextRequestAt=now+2
                            directFastFarmStart(FastFarm,"rebirth")
                        end
                    else
                    if stats.rebirths > last then
                        State.afk.gain = State.afk.gain + stats.rebirths - last
                        last = stats.rebirths
                        nextRequestAt = now + CONFIG.FastFarm.RebirthCooldown + CONFIG.FastFarm.RebirthSafetyMargin
                        State.pushOutput("REBIRTH", "+" .. tostring(State.afk.gain) .. " · Auto Rebirth")
                        train(nil)
                    end
                    local required = FastFarm.GetRequiredRebirthStrength(stats.rebirths)
                    State.afk.required = required
                    local ready = char:GetAttribute("IsRebirthing") ~= true and char:GetAttribute("LastMapCFrame") == nil
                    if stats.strength >= required and ready then
                        train(nil)
                        State.afk.phase = pending and "Esperando respuesta del servidor" or "Listo para renacer"
                        if not pending and now >= nextRequestAt then
                            pending = true
                            requestSerial = requestSerial + 1
                            local requestId = requestSerial
                            nextRequestAt = now + 2
                            task.spawn(function()
                                local ok, accepted = pcall(FastFarm.RequestRebirth)
                                if requestId == requestSerial then pending = false end
                                if serial == id and State.afk.active and (not ok or accepted == false) then
                                    State.afk.phase = "Reintentando con pausa"
                                    nextRequestAt = os.clock() + 2
                                end
                            end)
                        end
                    else
                        local pushups = requirement({"Pushups", "Pushup"})
                        train(pushups and "afkPushups" or "afkWeight")
                        State.afk.phase = pushups and "Entrenando Pushups" or "Recuperando fuerza con Weight"
                    end
                    end
                elseif selected == "Auto Strength" then
                    af.strength(now,id)
                    State.afk.gain = math.max(0, stats.strength - (State.afk.base.strength or 0))
                else
                    af.ensurePets(now)
                    if not State.afk.active or serial~=id then break end
                    local durability = getPlayerStat(LP, {"Durability"})
                    local amount = durability and tonumber(State.getFunctionalStatValue(durability)) or 0
                    local best
                    for _, rock in ipairs(CONFIG.Rocks) do if amount >= rock.durability then best = rock; break end end
                    if best and best ~= lastRock then
                        setFastPunch(true); startRockFarm(best, true); lastRock = best
                    end
                    af.rotateCombinedExercise(now)
                    State.afk.phase = best and best.name or "Entrenando hasta desbloquear una roca"
                    State.afk.gain = math.max(0, amount - (State.afk.base.durability or amount))
                end
                if now - lastProgressAt > 20 and not pending then
                    train(nil)
                    if selected=="Auto Strength" and af.machine then
                        af.blocked[af.machine]=now+8; af.releaseMachine(); af.nextMachine=0
                    end
                    lastProgressAt = now
                end
            end
            task.wait(selected=="Auto Strength" and .04 or .2)
        end
        end)
        if not succeeded and serial==id then
            stop()
            State.afk.phase="El modo se detuvo · reintentá"
            State.pushOutput("ERROR","AFK: "..tostring(problem):sub(1,220))
        end
    end)
    return true
end
State.startAfk = start
selector = __FGRoot.CrefyUI.uiAddSelector(afkPage, "Modo AFK", modes, function(value)
    local active = State.afk.active
    if active then stop() end
    State.afk.mode = value or modes[1]
    show(true)
    if toggle then toggle:Set(true) end
end)
back = __FGRoot.CrefyUI.uiAddButton(afkPage, "‹ Elegir otro modo", function() if State.afk.active then stop() end; show(false) end)
back.Name="AfkBack"; back.Text="‹"; back.Size=UDim2.fromOffset(30,28); back.Position=UDim2.fromOffset(0,0)
back.Parent=header; back.BackgroundTransparency=1; back.TextSize=27; back.TextColor3=C.soft
back:SetAttribute("KeepTextStyle",true); back:SetAttribute("NoTranslate",true)
for _,o in ipairs(back:GetDescendants()) do
    if o:IsA("UIStroke") then o.Transparency=1 elseif o:IsA("UITextSizeConstraint") then o.MaxTextSize=27 end
end
toggle = __FGRoot.CrefyUI.uiAddToggle(afkPage, "Iniciar modo AFK", function(enabled)
    if not enabled then stop(); return true end
    local ok, message = start()
    if not ok then State.afk.phase = message; State.pushOutput("ERROR", message) end
    return ok
end)
State.afkModeSelector, State.afkMainToggle, State.afkEggToggle = selector, toggle, nil
State.afkSnapshot=function()
    if not State.afk.active then return nil end
    local base=State.afk.base or {}
    return {version=1,mode=State.afk.mode,
        elapsed=State.afk.startedAt and math.max(0,os.clock()-State.afk.startedAt) or State.afk.elapsed or 0,
        gain=State.afk.gain or 0,baseStrength=base.strength,baseDurability=base.durability,
        baseKills=base.kills,baseBrawls=base.brawls,baseRebirths=base.rebirths}
end
State.afkResume=function(session)
    if type(session)~="table" then return false end
    local valid=false
    for _,mode in ipairs(modes) do if session.mode==mode then valid=true; break end end
    if not valid then return false end
    af.resumeNext=session
    selector:SetValue(session.mode)
    if not State.afk.active then toggle:Set(true) end
    return State.afk.active==true
end
toggle.Button.LayoutOrder=2; toggle.Button.Size=UDim2.new(1,0,0,32)
local toggleTitle=toggle.Button:FindFirstChildWhichIsA("TextLabel")
local function rowOf(label)
    local p = label
    while p and p.Parent ~= afkPage do p = p.Parent end
    return p
end
for _, label in ipairs({timer, counterRow, toggle.Button}) do detail[#detail+1] = rowOf(label) end
-- AFK modes are selected by the native Crefy dropdown above; no legacy tiles are built.

State.afk.phase = ""
show(false)
startThread("afkStatus", function()
    while State.running do
        if State.currentTab == "AFK 24/7" then
            status.Text = ""
            local elapsed = State.afk.startedAt and os.clock() - State.afk.startedAt or State.afk.elapsed or 0
            timer.Text = string.format("%02d:%02d:%02d", math.floor(elapsed/3600),math.floor(elapsed/60)%60,math.floor(elapsed)%60)
            local stats=FastFarm:ReadStats()
            local kills=State.afk.mode=="Auto Farm Kills"
            local leftStat=kills and getPlayerStat(LP,{"Kills"})
            local current=kills and (leftStat and tonumber(State.getFunctionalStatValue(leftStat)) or 0) or stats.strength
            leftCounter.Title.Text=tr(kills and "Kills" or "Fuerza")
            leftCounter.Value.Text=formatExact(current)
            local base=State.afk.base or {}
            local leftGain=kills and current-(base.kills or current) or State.afk.mode=="Auto Rebirth" and current or current-(base.strength or current)
            leftCounter.Gain.Text="+"..formatExact(math.max(0,leftGain))
            local kind=State.afk.mode=="Auto Rebirth" and "Rebirths" or kills and "Brawls" or "Durability"
            local stat=getPlayerStat(LP,kind=="Brawls" and {"Brawls","Brawl Wins","Brawls Won","brawls"} or {kind})
            rightCounter.Title.Text=kind=="Durability" and tr("Durabilidad") or kind
            rightCounter.Value.Text=formatExact(stat and State.getFunctionalStatValue(stat) or 0)
            local currentRight=stat and tonumber(State.getFunctionalStatValue(stat)) or 0
            local rightGain=kind=="Rebirths" and State.afk.gain or currentRight-(base[kind=="Brawls" and "brawls" or "durability"] or currentRight)
            rightCounter.Gain.Text="+"..formatExact(math.max(0,rightGain or 0))
            if toggleTitle then toggleTitle.Text=State.afk.mode end
            local width = afkPage.AbsoluteSize.X
            local narrow = width < 370
            statusRow.Size=UDim2.new(1,0,0,0)
            layout.CellSize = UDim2.new(narrow and 1 or .5, narrow and 0 or -5,0,76)
            grid.Size = UDim2.new(1,0,0,narrow and 334 or 162)
        end
        task.wait(.5)
    end
end)
addCleanup(stop)
do
    local manual=FastFarm.StopFastModesForManualFarm
    FastFarm.StopFastModesForManualFarm=function(...)
        if State.afk.active then stop() end
        return manual(...)
    end
    local old=FastFarm.Start
    FastFarm.Start=function(self,...)
        if State.afk.active then stop() end
        return old(self,...)
    end
    if FastFarm.PetMomentum then
        local previous=FastFarm.PetMomentum.Start
        FastFarm.PetMomentum.Start=function(self,...)
            if State.afk.active then stop() end
            return previous(self,...)
        end
    end
end

end
pageSetup()
pageSetup = function()
local serverPage=Pages["Server Hop"]
serverPage:SetAttribute("TightCanvas",true)

local function label(parent,text,size,color)
    local value=Instance.new("TextLabel")
    value.BackgroundTransparency=1
    value.BorderSizePixel=0
    value.Text=text
    value.TextSize=size
    value.TextColor3=color or C.soft
    value.Font=Enum.Font.GothamMedium
    value.TextXAlignment=Enum.TextXAlignment.Left
    value:SetAttribute("KeepTextStyle",true)
    value.Parent=parent
    return value
end

local function sectionTitle(text)
    local row=Instance.new("Frame")
    row.BackgroundTransparency=1
    row.Size=UDim2.new(1,0,0,26)
    row.LayoutOrder=nextOrder(serverPage)
    row.Parent=serverPage
    local accent=Instance.new("Frame")
    accent.BackgroundColor3=C.cyan
    accent.BorderSizePixel=0
    accent.Position=UDim2.fromOffset(0,6)
    accent.Size=UDim2.fromOffset(3,16)
    accent.Parent=row
    Instance.new("UICorner",accent).CornerRadius=UDim.new(1,0)
    local title=label(row,text,12,C.cyan)
    title.Font=Enum.Font.GothamBold
    title.Position=UDim2.fromOffset(11,0)
    title.Size=UDim2.new(1,-11,1,0)
end

local function compact(control)
    control.Button.Size=UDim2.new(1,0,0,34)
    return control
end

sectionTitle("Automatizaciones")
State.kill.hopOnDeath=false
State.serverHopDeathToggle=compact(__FGRoot.CrefyUI.uiAddToggle(serverPage,"Cambiar de server si me matan",function(value)
    State.kill.hopOnDeath=value==true
    return true
end))
State.serverHopDeathToggle:Set(false,true)
State.serverHopPageToggle=nil
State.serverHopAvoidToggle=nil
State.serverHopClaimKingToggle=nil

local heading=Instance.new("Frame")
heading.BackgroundTransparency=1
heading.Size=UDim2.new(1,0,0,30)
heading.LayoutOrder=nextOrder(serverPage)
heading.Parent=serverPage
local headingAccent=Instance.new("Frame")
headingAccent.BackgroundColor3=C.cyan
headingAccent.BorderSizePixel=0
headingAccent.Position=UDim2.fromOffset(0,6)
headingAccent.Size=UDim2.fromOffset(3,18)
headingAccent.Parent=heading
Instance.new("UICorner",headingAccent).CornerRadius=UDim.new(1,0)
local title=label(heading,"Elegí tu próximo servidor",16,C.white)
title.Font=Enum.Font.GothamBold
title.Position=UDim2.fromOffset(12,0)
title.Size=UDim2.new(.63,-12,1,0)
local live=label(heading,"",10,C.dim)
live:SetAttribute("NoTranslate",true)
live.TextXAlignment=Enum.TextXAlignment.Right
live.Size=UDim2.new(.37,0,1,0)
live.Position=UDim2.fromScale(.63,0)

local names={
    ["Con mucha gente"]="full",
    ["Equilibrado"]="balanced",
    ["Casi vacío"]="solo",
    ["Mejor conexión"]="ping",
}
local modeNames={"Con mucha gente","Equilibrado","Casi vacío","Mejor conexión"}
local drawCandidate
local selector=__FGRoot.CrefyUI.uiAddSelector(serverPage,"Destino",modeNames,function(value)
    State.kill.serverHopMode=names[value] or "full"
    State.kill.serverCandidate=nil
    State.kill.serverError=nil
    if drawCandidate then drawCandidate(nil,true) end
end)
selector.Row.Size=UDim2.new(1,0,0,38)
State.serverHopModeSelector=selector

local analyze
analyze=__FGRoot.CrefyUI.uiAddButton(serverPage,"Buscar servidor",function()
    if State.serverPreviewBusy or State.kill.hopInProgress then return end
    State.serverPreviewBusy=true
    State.setButtonDisabled(analyze,true)
    if drawCandidate then drawCandidate(nil,false,"Buscando servidores...") end
    startThread("serverPreview",function()
        local ok,c=pcall(State.previewServerHop)
        if not ok then
            State.kill.serverError="No se pudo consultar Roblox."
            State.pushOutput("ERROR","Server Hop: "..tostring(c))
            c=nil
        end
        drawCandidate(c,false)
        State.serverPreviewBusy=false
        State.setButtonDisabled(analyze,false)
    end)
end,C.tabOn,C.rowHover)
analyze.Size=UDim2.new(1,0,0,34)

local candidateCard=Instance.new("Frame")
candidateCard.BackgroundColor3=C.row
candidateCard.BackgroundTransparency=.30
candidateCard.BorderSizePixel=0
candidateCard.Size=UDim2.new(1,0,0,72)
candidateCard.LayoutOrder=nextOrder(serverPage)
candidateCard.Parent=serverPage
Instance.new("UICorner",candidateCard).CornerRadius=UDim.new(0,10)
local border=Instance.new("UIStroke",candidateCard)
border.Color=C.blue
border.Transparency=.48
border.Thickness=1
local surface=Instance.new("UIGradient",candidateCard)
surface.Name="Surface"
surface.Color=ColorSequence.new(Color3.fromRGB(13,19,35),Color3.fromRGB(20,16,39))
surface.Rotation=8
local candidateAccent=Instance.new("Frame")
candidateAccent.BackgroundColor3=C.blue
candidateAccent.BorderSizePixel=0
candidateAccent.Position=UDim2.fromOffset(7,9)
candidateAccent.Size=UDim2.fromOffset(3,54)
candidateAccent.Parent=candidateCard
Instance.new("UICorner",candidateAccent).CornerRadius=UDim.new(1,0)
local amount=label(candidateCard,"—",23,C.white)
amount:SetAttribute("NoTranslate",true)
amount.Font=Enum.Font.GothamBold
amount.Size=UDim2.new(0,88,0,30)
amount.Position=UDim2.fromOffset(17,7)
local population=label(candidateCard,"jugadores",10,C.dim)
population.Size=UDim2.fromOffset(88,18)
population.Position=UDim2.fromOffset(17,36)
local status=label(candidateCard,"Listo para buscar",12,C.soft)
status.Size=UDim2.new(1,-119,0,25)
status.Position=UDim2.fromOffset(111,7)
status.TextWrapped=true
local detail=label(candidateCard,"Elegí un destino y tocá Buscar servidor.",10,C.dim)
detail.Size=UDim2.new(1,-119,0,36)
detail.Position=UDim2.fromOffset(111,32)
detail.TextWrapped=true

local join
join=__FGRoot.CrefyUI.uiAddButton(serverPage,"Entrar ahora  ›",function()
    if State.serverPreviewBusy or not State.kill.serverCandidate then return end
    status.Text="Preparando cambio..."
    State.setButtonDisabled(join,true)
    startThread("serverHopManual",function()
        local ok,accepted,message=pcall(State.requestServerHop)
        if not ok then message=tostring(accepted); accepted=false end
        status.Text=accepted and "Conectando..." or (message or "No se pudo cambiar de servidor")
        if not accepted then State.setButtonDisabled(join,false) end
    end)
end,C.tabOn,C.rowHover)
join.Size=UDim2.new(1,0,0,34)
State.setButtonDisabled(join,true)

drawCandidate=function(candidate,selectionChanged,temporaryStatus)
    if candidate then
        amount.Text=tostring(candidate.playing).."/"..tostring(candidate.maxPlayers)
        status.Text="Servidor listo para entrar"
        local ping=tonumber(candidate.ping)
        detail.Text=ping and ("Ping informado: "..math.floor(ping).." ms · puede variar al entrar.")
            or "Había lugar disponible al momento de buscar."
        border.Color=C.cyan
        candidateAccent.BackgroundColor3=C.cyan
        State.setButtonDisabled(join,false)
    else
        amount.Text="—"
        if temporaryStatus then
            status.Text=temporaryStatus
            detail.Text="Esto puede tardar unos segundos."
        elseif selectionChanged then
            status.Text="Destino actualizado"
            detail.Text="Tocá Buscar servidor para encontrar una opción nueva."
        else
            status.Text=State.kill.serverError or "No encontré un servidor para ese destino."
            detail.Text="Probá otra vez o elegí un destino diferente."
        end
        border.Color=C.blue
        candidateAccent.BackgroundColor3=C.blue
        State.setButtonDisabled(join,true)
    end
end

drawCandidate(nil,true)
status.Text="Listo para buscar"
detail.Text="Elegí un destino y tocá Buscar servidor."
State.kill.updateHopStatus=function(seconds,message)
    if message then status.Text=message
    elseif seconds then status.Text="Próxima búsqueda en "..seconds.."s"
    elseif State.kill.serverHop then status.Text="Buscando automáticamente" end
end
startThread("serverPageMetrics",function()
    while State.running and serverPage.Parent do
        if State.currentTab=="Server Hop" then
            live.Text=#Players:GetPlayers().."/"..Players.MaxPlayers.." · "..math.floor(getPing()+.5).." ms"
            State.serverHopDeathToggle:Set(State.kill.hopOnDeath==true,true)
            local pendingTeleport=State.kill.teleportPending
            if pendingTeleport and os.clock()-pendingTeleport.at>18 then
                State.kill.teleportPending=nil
                status.Text="El cambio no se confirmó. Volvé a intentar."
            end
        end
        task.wait(1)
    end
end)
State.serverHopUI={candidate=amount,status=status,detail=detail,analyze=analyze,join=join}

end
pageSetup()
pageSetup=function()
local tradePage = Pages["Fast Trade"]
tradePage:SetAttribute("TightCanvas", true)
__FGRoot.CrefyUI.uiAddSection(tradePage, "Fast Trade")


local function revealTradeSelector(row)
	RunService.Heartbeat:Wait()
	local bottom = math.max(0, tradePage.AbsoluteCanvasSize.Y - tradePage.AbsoluteSize.Y)
	local rowTop = row.AbsolutePosition.Y - tradePage.AbsolutePosition.Y + tradePage.CanvasPosition.Y - 3
	TweenService:Create(tradePage, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		CanvasPosition = Vector2.new(0, math.clamp(rowTop, 0, bottom)),
	}):Play()
end


local function tradeEquippedSet()
	local equipped = {}
	local folder = LP:FindFirstChild("equippedPets")
	for _, slot in ipairs(folder and folder:GetChildren() or {}) do
		local reference = slot:FindFirstChild("petReference")
		local pet = reference and reference:IsA("ObjectValue") and reference.Value
		if not pet and slot:IsA("ObjectValue") then pet = slot.Value end
		if pet then equipped[pet] = true end
	end
	return equipped
end


local function tradeEligible(pet, equipped)
	if not pet or not pet.Parent or not pet:IsA("StringValue") or (equipped and equipped[pet]) then
		return false
	end
	return not State.isProtectedPetAsset(pet)
end


local function ownedPetOptions()
	local counts = {}
	local folder = LP:FindFirstChild("petsFolder")
	local equipped = tradeEquippedSet()
	if folder then
		for _, category in ipairs(folder:GetChildren()) do
			if category:IsA("Folder") then
				for _, pet in ipairs(category:GetChildren()) do
					if tradeEligible(pet, equipped) then
						counts[pet.Name] = (counts[pet.Name] or 0) + 1
					end
				end
			end
		end
	end
	local names = {}
	for name in pairs(counts) do
		names[#names + 1] = name
	end
	table.sort(names, function(a, b) return a:lower() < b:lower() end)
	local options = {}
	for _, name in ipairs(names) do
		options[#options + 1] = {
			label = name .. "  x" .. formatExact(counts[name]),
			name = name,
			count = counts[name],
		}
	end
	return options
end


local function findOwnedPets(name, limit)
	local found = {}
	local folder = LP:FindFirstChild("petsFolder")
	local equipped = tradeEquippedSet()
	if not folder or type(name) ~= "string" then
		return found
	end
	for _, category in ipairs(folder:GetChildren()) do
		if category:IsA("Folder") then
			for _, pet in ipairs(category:GetChildren()) do
				if pet.Name == name and tradeEligible(pet, equipped) then
					found[#found + 1] = pet
					if #found >= limit then
						return found
					end
				end
			end
		end
	end
	return found
end


local function countOwnedPets(name)
	return #findOwnedPets(name, math.huge)
end


local function visibleGui(object)
	local current = object
	while current and current ~= PlayerGui do
		if current:IsA("GuiObject") and not current.Visible then
			return false
		end
		current = current.Parent
	end
	return current == PlayerGui
end

local cachedTradeGuiRefs

local function getTradeGuiRefs()
	if cachedTradeGuiRefs and cachedTradeGuiRefs.TradePanel
		and cachedTradeGuiRefs.TradePanel.Parent then
		return cachedTradeGuiRefs
	end
	local client = ReplicatedStorage:FindFirstChild("client")
	local utils = client and client:FindFirstChild("utils")
	local module = utils and utils:FindFirstChild("TradeMenuRefs")
	if module and module:IsA("ModuleScript") then
		local ok, refs = pcall(function()
			local resolver = require(module)
			return type(resolver) == "table" and type(resolver.Resolve) == "function"
				and resolver.Resolve() or nil
		end)
		if ok and type(refs) == "table" then
			cachedTradeGuiRefs = refs
			return refs
		end
	end
	return nil
end

local cachedTradeWindow

local function findTradeWindow()
	local refs = getTradeGuiRefs()
	local resolvedPanel = refs and refs.TradePanel
	if resolvedPanel and resolvedPanel:IsA("GuiObject") then
		cachedTradeWindow = visibleGui(resolvedPanel) and resolvedPanel or nil
		return cachedTradeWindow
	end
	local gameGui = PlayerGui:FindFirstChild("gameGui")
	local officialPanel = gameGui and (gameGui:FindFirstChild("tradeMainNewMenu")
		or gameGui:FindFirstChild("tradePanel"))
	if officialPanel and officialPanel:IsA("GuiObject") then
		cachedTradeWindow = officialPanel.Visible and officialPanel or nil
		return cachedTradeWindow
	end
	if cachedTradeWindow and cachedTradeWindow.Parent and visibleGui(cachedTradeWindow)
		and cachedTradeWindow.AbsoluteSize.X >= 160 and cachedTradeWindow.AbsoluteSize.Y >= 110 then
		return cachedTradeWindow
	end
	cachedTradeWindow = nil
	local best, bestArea = nil, 0
	for _, object in ipairs(PlayerGui:GetDescendants()) do
		if object:IsA("GuiObject") and not object:IsDescendantOf(ScreenGui) and visibleGui(object) then
			local lowerName = object.Name:lower()
			if (lowerName:find("trade", 1, true) or lowerName:find("trading", 1, true))
				and object.AbsoluteSize.X >= 160 and object.AbsoluteSize.Y >= 110 then
				local area = object.AbsoluteSize.X * object.AbsoluteSize.Y
				if area > bestArea then
					best, bestArea = object, area
				end
			end
		end
	end
	cachedTradeWindow = best
	return best
end

local cachedTradeController

local function closeTradeSuccessGui()
	local gameGui = PlayerGui:FindFirstChild("gameGui")
	local refs = getTradeGuiRefs()
	local menus = {
		refs and refs.CompleteMenu,
		refs and refs.DeclineMenu,
		gameGui and gameGui:FindFirstChild("tradeCompleteNewMenu"),
		gameGui and gameGui:FindFirstChild("tradeDeclineNewMenu"),
		gameGui and gameGui:FindFirstChild("tradeSuccessMenu"),
	}
	local visibleResult = false
	for _, menu in ipairs(menus) do
		if menu and menu:IsA("GuiObject") and visibleGui(menu) then
			visibleResult = true
			break
		end
	end
	if not visibleResult then
		return true
	end
	if not cachedTradeController then
		local controllers = ReplicatedStorage:FindFirstChild("client")
		controllers = controllers and controllers:FindFirstChild("controllers")
		local module = controllers and controllers:FindFirstChild("TradeController")
		if module and module:IsA("ModuleScript") then
			local ok, controller = pcall(require, module)
			if ok and type(controller) == "table" then
				cachedTradeController = controller
			end
		end
	end
	if cachedTradeController and type(cachedTradeController.CloseTradeSuccess) == "function" then
		pcall(cachedTradeController.CloseTradeSuccess, cachedTradeController)
	end
	for _, menu in ipairs(menus) do
		if menu and menu:IsA("GuiObject") and visibleGui(menu) then
			return false
		end
	end
	return true
end


local function acceptedText(text)
	local lower = tostring(text or ""):lower()
	return lower:find("accepted", 1, true)
		or lower:find("ready", 1, true)
		or lower:find("aceptado", 1, true)
		or lower:find("aceptó", 1, true)
		or lower:find("listo", 1, true)
		or lower:find("confirmado", 1, true)
end


local function scopeHasTarget(scope, target)
	local user = target.Name:lower()
	local display = target.DisplayName:lower()
	for _, child in ipairs(scope:GetDescendants()) do
		if child:IsA("TextLabel") or child:IsA("TextButton") then
			local text = tostring(child.Text or ""):lower()
			if text:find(user, 1, true) or text:find(display, 1, true) then
				return true
			end
		end
	end
	return false
end


local function targetAccepted(window, target)
	if not window or not target then
		return false
	end
	local refs = getTradeGuiRefs()
	local acceptedCover = refs and refs.OtherAcceptedCover
	if refs and refs.TradePanel == window and acceptedCover and acceptedCover:IsA("GuiObject") then
		return visibleGui(acceptedCover)
	end
	if not scopeHasTarget(window, target) then return false end
	for _, child in ipairs(window:GetDescendants()) do
		if (child:IsA("TextLabel") or child:IsA("TextButton"))
			and visibleGui(child) and acceptedText(child.Text) then
			local scope = child.Parent
			for _ = 1, 4 do
				if not scope or scope == window.Parent then break end
				if scopeHasTarget(scope, target) then return true end
				scope = scope.Parent
			end
			local objectPath = child:GetFullName():lower()
			if objectPath:find("other", 1, true)
				or objectPath:find("opponent", 1, true)
				or objectPath:find("player2", 1, true)
				or objectPath:find("recipient", 1, true) then
				return true
			end
		end
	end
	return false
end


local function getTradeRemote()
	local events = ReplicatedStorage:FindFirstChild("rEvents")
	return events and (events:FindFirstChild("tradingEvent") or events:FindFirstChild("tradeRemote"))
end


local function sendTrade(remote, action, value)
	return callServer(remote, action, value)
end

local tradeButton
local selectedAmount = 6
local tradeMessageGeneration = 0


local function updateTradeStatus(textValue, delivered, total)
	if delivered ~= nil then State.trade.delivered = delivered end
	if total ~= nil then State.trade.total = total end
	if tradeButton and tradeButton.Parent and textValue then
		tradeMessageGeneration = tradeMessageGeneration + 1
		local generation = tradeMessageGeneration
		tradeButton.Text = tostring(textValue)
		if not State.trade.busy then
			task.delay(1.4, function()
				if tradeButton and tradeButton.Parent and not State.trade.busy and tradeMessageGeneration == generation then
					tradeButton.Text = "Iniciar Fast Trade"
				end
			end)
		end
	end
end


local function cancelFastTrade(message)
	State.trade.requestGeneration = State.trade.requestGeneration + 1
	State.trade.busy = false
	State.trade.activePlayer = nil
	State.trade.activePet = nil
	stopThread("fastTrade")
	if tradeButton and tradeButton.Parent then
		tradeButton.Text = "Iniciar Fast Trade"
	end
	if message then updateTradeStatus(message) end
end

local refreshingTradeSelectors = false
local playerSelector = __FGRoot.CrefyUI.uiAddSelector(tradePage, "Seleccionar jugador", playerOptions(), function(value)
	local name = type(value) == "table" and value.name or value
	if not refreshingTradeSelectors and State.trade.busy and State.trade.activePlayer and name ~= State.trade.activePlayer then
		cancelFastTrade("Cancelado: cambió el jugador")
	end
end, revealTradeSelector)
local petSelector = __FGRoot.CrefyUI.uiAddSelector(tradePage, "Seleccionar pet", ownedPetOptions(), function(value)
	local name = type(value) == "table" and value.name or value
	if not refreshingTradeSelectors and State.trade.busy and State.trade.activePet and name ~= State.trade.activePet then
		cancelFastTrade("Cancelado: cambió la pet")
	end
end, revealTradeSelector)
local amountSelector = __FGRoot.CrefyUI.uiAddSelector(tradePage, "Pets por trade", { 6, 5, 4, 3, 2, 1 }, function(value)
	selectedAmount = math.clamp(math.floor(tonumber(value) or 6), 1, 6)
end, revealTradeSelector)


local function selectedName(value)
	return type(value) == "table" and value.name or value
end


local function waitForTrade(remote, target, generation)
	local nextRequest = 0
	while State.running and State.trade.busy
		and State.trade.requestGeneration == generation and target.Parent do
		local window = findTradeWindow()
		if window then return window end
		local now = time()
		local cooldown = target:GetAttribute("TradeCooldown_" .. tostring(LP.UserId))
		if typeof(cooldown) == "number" then
			local remaining = cooldown - workspace:GetServerTimeNow()
			if remaining > 0 then
				nextRequest = math.max(nextRequest, now + remaining + 0.03)
			end
		end
		if now >= nextRequest then
			sendTrade(remote, "sendTradeRequest", target)
			nextRequest = now + 0.5
			updateTradeStatus("Fast Trade activo · esperando aceptación")
		end
		task.wait(0.05)
	end
	return nil
end

tradeButton = __FGRoot.CrefyUI.uiAddButton(tradePage, "Iniciar Fast Trade", function(button)
	if State.trade.busy then
		cancelFastTrade("Cancelado por el usuario")
		return
	end
	if findTradeWindow() then
		updateTradeStatus("Cerrá el trade actual antes de iniciar")
		return
	end
	local targetName = selectedName(playerSelector:Get())
	local petName = selectedName(petSelector:Get())
	local target = targetName and Players:FindFirstChild(targetName)
	local remote = getTradeRemote()
	local batchLimit = math.clamp(math.floor(tonumber(amountSelector:Get()) or selectedAmount), 1, 6)
	if not target or target == LP then
		updateTradeStatus("Seleccioná un jugador válido")
		return
	end
	if not petName then
		updateTradeStatus("Seleccioná una pet")
		return
	end
	if not remote then
		updateTradeStatus("El remote de trade no está disponible")
		return
	end
	if countOwnedPets(petName) < 1 then
		updateTradeStatus("No tenés esa pet disponible")
		return
	end

	State.trade.requestGeneration = State.trade.requestGeneration + 1
	local generation = State.trade.requestGeneration
	State.trade.busy = true
	State.trade.activePlayer = targetName
	State.trade.activePet = petName
	State.trade.delivered = 0
	State.trade.total = batchLimit
	button.Text = "Cancelar Fast Trade"
	updateTradeStatus("Fast Trade activo · preparando primer lote", 0, batchLimit)

	startThread("fastTrade", function()
		while State.running and State.trade.busy
			and State.trade.requestGeneration == generation do
			repeat
			if not target.Parent then
				cancelFastTrade("El jugador salió del servidor")
				return
			end
			local pets = findOwnedPets(petName, batchLimit)
			if #pets == 0 then
				updateTradeStatus("Fast Trade activo · esperando pets")
				task.wait(0.5)
				break
			end
			local batchSize = #pets
			local beforeCount = countOwnedPets(petName)
			local window = waitForTrade(remote, target, generation)
			if not window then
				cancelFastTrade("No se pudo abrir el trade")
				return
			end

			updateTradeStatus("Seleccionando lote de " .. batchSize .. " pets...")
			local offered = 0
			for _, pet in ipairs(pets) do
				if not State.trade.busy or State.trade.requestGeneration ~= generation then
					return
				end
				if tradeEligible(pet, tradeEquippedSet()) then
					local ok = sendTrade(remote, "offerItem", pet)
					if ok then
						offered = offered + 1
					end
					task.wait(0.12)
				end
			end
			if offered == 0 then
				cancelFastTrade("No se pudo ofrecer ninguna pet")
				return
			end
			batchSize = offered

			updateTradeStatus("Esperando que la otra cuenta acepte...")
			local otherAccepted = false
			local acceptDeadline = time() + 120
			while State.running and State.trade.busy
				and State.trade.requestGeneration == generation and target.Parent
				and not otherAccepted and time() < acceptDeadline do
				window = findTradeWindow()
				if not window then
					break
				end
				otherAccepted = targetAccepted(window, target)
				task.wait(0.2)
			end
			if not State.trade.busy or State.trade.requestGeneration ~= generation then
				return
			end
			if not target.Parent then
				cancelFastTrade("El jugador salió del servidor")
				return
			end
			if not otherAccepted then
				updateTradeStatus("Trade cerrado; reintentando el mismo lote...")
				task.wait(0.8)
			else
				updateTradeStatus("Aceptando y verificando entrega...")
				local accepted = sendTrade(remote, "acceptTrade")
				if not accepted then
					updateTradeStatus("No se pudo aceptar; reintentando...")
					task.wait(0.8)
				else
					local deadline = time() + 30
					local sentCount = 0
					while State.running and State.trade.busy
						and State.trade.requestGeneration == generation and time() < deadline do
						sentCount = math.clamp(beforeCount - countOwnedPets(petName), 0, batchSize)
						if sentCount > 0 then break end
						task.wait(0.2)
					end
					if sentCount > 0 then
						State.trade.delivered = State.trade.delivered + sentCount
						updateTradeStatus("Fast Trade activo · "
							.. formatExact(State.trade.delivered) .. " pets entregadas",
							State.trade.delivered, batchLimit)
					else
						updateTradeStatus("No se confirmó la entrega; reintentando...")
					end
					while State.running and State.trade.busy
						and State.trade.requestGeneration == generation and findTradeWindow() do
						task.wait(0.05)
					end
					if sentCount > 0 then
						local closeDeadline = time() + 3
						while State.running and State.trade.busy
							and State.trade.requestGeneration == generation and time() < closeDeadline do
							if closeTradeSuccessGui() then break end
							task.wait(0.05)
						end
					end
					task.wait(0.05)
				end
			end
			until true
		end
	end)
end, C.row, C.rowHover)


local function refreshTradePlayers()
	refreshingTradeSelectors = true
	playerSelector:SetValues(playerOptions(), true)
	refreshingTradeSelectors = false
end
local refreshQueued = false

local function refreshTradePets()
	if refreshQueued then return end
	refreshQueued = true
	task.delay(0.15, function()
		refreshQueued = false
		if State.running then
			refreshingTradeSelectors = true
			petSelector:SetValues(ownedPetOptions(), true)
			refreshingTradeSelectors = false
		end
	end)
end
track(Players.PlayerAdded:Connect(refreshTradePlayers))
track(Players.PlayerRemoving:Connect(refreshTradePlayers))
track(LP.DescendantAdded:Connect(function(descendant)
	local folder = LP:FindFirstChild("petsFolder")
	local equipped = LP:FindFirstChild("equippedPets")
	if (folder and descendant:IsDescendantOf(folder)) or (equipped and descendant:IsDescendantOf(equipped)) then
		refreshTradePets()
	end
end))
track(LP.DescendantRemoving:Connect(function(descendant)
	local folder = LP:FindFirstChild("petsFolder")
	local equipped = LP:FindFirstChild("equippedPets")
	if (folder and descendant:IsDescendantOf(folder)) or (equipped and descendant:IsDescendantOf(equipped)) then
		refreshTradePets()
	end
end))
addCleanup(function() cancelFastTrade() end)
end
pageSetup()

pageSetup = function()
local giftPage = Pages.Gifts
__FGRoot.CrefyUI.uiAddSection(giftPage, "Regalos")
local eggCountValue = __FGRoot.CrefyUI.uiAddInfoRow(giftPage, "Eggs", "0", C.cyan)
local shakeCountValue = __FGRoot.CrefyUI.uiAddInfoRow(giftPage, "Tropical Shakes", "0", C.cyan)
__FGRoot.CrefyUI.uiAddSection(giftPage, "Enviar Regalos")
local giftTargetSelector = __FGRoot.CrefyUI.uiAddSelector(giftPage, "Jugador", playerOptions(), function() end)
State.giftTargetSelector = giftTargetSelector
local eggAmount = 1
local shakeAmount = 1
local eggSendButton = nil
local shakeSendButton = nil
__FGRoot.CrefyUI.uiAddInput(giftPage, "Cantidad de Eggs", "1", function(value)
	eggAmount = math.clamp(math.floor(tonumber(value) or 1), 1, 9999)
	if eggSendButton then
		eggSendButton.Text = "🥚 Enviar " .. eggAmount .. " Protein Egg" .. (eggAmount == 1 and "" or "s") .. " 🥚"
	end
end)


local function consumableNames(value)
	return type(value) == "table" and value or { value }
end


local function findConsumable(folder, names, excluded)
	if not folder then
		return nil
	end
	for _, name in ipairs(consumableNames(names)) do
		for _, item in ipairs(folder:GetChildren()) do
			if item.Name == name and not (excluded and excluded[item]) then
				return item
			end
		end
	end
	return nil
end


local function countConsumable(names)
	local folder = LP:FindFirstChild("consumablesFolder")
	if not folder then
		return 0
	end
	local acceptedNames = {}
	for _, name in ipairs(consumableNames(names)) do
		acceptedNames[name] = true
	end
	local count = 0
	for _, item in ipairs(folder:GetChildren()) do
		if acceptedNames[item.Name] then
			count = count + 1
		end
	end
	return count
end

State.giftSendBusy = false

local function sendGift(itemNames, displayName, amount, button, icon, baseDelay)
	local selectedTarget = giftTargetSelector:Get()
	local targetName = type(selectedTarget) == "table" and selectedTarget.name or selectedTarget
	local target = targetName and Players:FindFirstChild(targetName)
	local folder = LP:FindFirstChild("consumablesFolder")
	local events = ReplicatedStorage:FindFirstChild("rEvents")
	local remote = events and events:FindFirstChild("giftRemote")
	local baseText = icon .. " Enviar " .. amount .. " " .. displayName .. (amount == 1 and "" or "s") .. " " .. icon
	if not target or target == LP or not folder or not remote then
		button.Text = "Seleccioná un jugador"
		task.delay(0.9, function()
			if button and button.Parent then
				button.Text = baseText
			end
		end)
		return
	end
	if State.giftSendBusy then
		button.Text = "Envío en curso"
		task.delay(0.8, function()
			if button and button.Parent then
				button.Text = baseText
			end
		end)
		return
	end
	local acceptedNames = {}
	for _, name in ipairs(consumableNames(itemNames)) do
		acceptedNames[name] = true
	end
	local queue = {}
	for _, item in ipairs(folder:GetChildren()) do
		if acceptedNames[item.Name] then
			queue[#queue + 1] = item
		end
	end
	local sendAmount = math.min(amount, #queue)
	if sendAmount == 0 then
		button.Text = "No tenés " .. displayName
		task.delay(0.9, function()
			if button and button.Parent then
				button.Text = baseText
			end
		end)
		return
	end
	State.giftSendBusy = true
	startThread("giftSender", function()
		local sent = 0
		local failed = 0
		local lastUiUpdate = 0
		local sendDelay = math.max(tonumber(baseDelay) or 0.1, 0.08)
		for index = 1, sendAmount do
			if not State.running then
				break
			end
			local item = queue[index]
			local ping = getPing()
			while State.running and ping >= 650 do
				task.wait(0.25)
				ping = getPing()
			end
			if not State.running then
				break
			end
			if not target.Parent then
				break
			end
			local ok, response = callServer(remote, "giftRequest", target, item)
			local confirmed = ok and response == true
			if ok and not confirmed then
				local deadline = time() + 2.5
				repeat
					confirmed = not item.Parent
					if not confirmed then task.wait(0.08) end
				until confirmed or not State.running or time() >= deadline
			end
			if confirmed then
				sent = sent + 1
			else
				failed = failed + 1
				if failed >= 3 then
					break
				end
			end
			if time() - lastUiUpdate >= 0.25 then
				button.Text = icon .. " Enviando " .. sent .. "/" .. sendAmount .. " " .. icon
				lastUiUpdate = time()
			end
			local adaptiveDelay = sendDelay
			if ping >= 400 then
				adaptiveDelay = math.max(adaptiveDelay, 0.4)
			elseif ping >= 250 then
				adaptiveDelay = math.max(adaptiveDelay, 0.28)
			elseif ping >= 150 then
				adaptiveDelay = math.max(adaptiveDelay, 0.2)
			end
			task.wait(adaptiveDelay)
		end
		State.giftSendBusy = false
		if button and button.Parent then
			button.Text = sent > 0 and (icon .. " Enviados " .. sent .. " " .. icon) or "No se confirmó el envío"
			task.delay(1.2, function()
				if button and button.Parent and not threads.giftSender then
					button.Text = baseText
				end
			end)
		end
		eggCountValue.Text = formatExact(countConsumable(CONFIG.AutoEgg.Names))
		shakeCountValue.Text = formatExact(countConsumable("Tropical Shake"))
	end)
end

eggSendButton = __FGRoot.CrefyUI.uiAddButton(giftPage, "🥚 Enviar 1 Protein Egg 🥚", function(button)
	sendGift(CONFIG.AutoEgg.Names, "Protein Egg", eggAmount, button, "🥚", 0.16)
end)
__FGRoot.CrefyUI.uiAddInput(giftPage, "Cantidad de Shakes", "1", function(value)
	shakeAmount = math.clamp(math.floor(tonumber(value) or 1), 1, 9999)
	if shakeSendButton then
		shakeSendButton.Text = "🥤 Enviar " .. shakeAmount .. " Tropical Shake" .. (shakeAmount == 1 and "" or "s") .. " 🥤"
	end
end)
shakeSendButton = __FGRoot.CrefyUI.uiAddButton(giftPage, "🥤 Enviar 1 Tropical Shake 🥤", function(button)
	sendGift("Tropical Shake", "Tropical Shake", shakeAmount, button, "🥤", 0.16)
end)

startThread("giftUpdater", function()
	while State.running do
		if not threads.giftSender then
			eggCountValue.Text = formatExact(countConsumable(CONFIG.AutoEgg.Names))
			shakeCountValue.Text = formatExact(countConsumable("Tropical Shake"))
		end
		task.wait(2)
	end
end)
end
pageSetup()


pageSetup = function()

local function currentShopFolder()
	local shared = ReplicatedStorage:FindFirstChild("shared")
	local runtime = shared and shared:FindFirstChild("runtime")
	return (runtime and runtime:FindFirstChild("cPetShopFolder"))
		or ReplicatedStorage:FindFirstChild("cPetShopFolder")
end


local function currentShopRemote()
	local events = ReplicatedStorage:FindFirstChild("rEvents")
	return (events and events:FindFirstChild("cPetShopRemote"))
		or ReplicatedStorage:FindFirstChild("cPetShopRemote")
end

local shopZonePriority = {
	["Core Pup"] = 70, ["Volt Talon"] = 70, ["Reactor Beast"] = 70,
	["Plasma Ravager"] = 70, ["Titan Reactor"] = 70, ["Apex Overlord"] = 70,
	["Neon Guardian"] = 60, ["Cybernetic Showdown Dragon"] = 60, ["Darkstar Hunter"] = 60,
	["Muscle Sensei"] = 50, ["Infernal Dragon"] = 50, ["Aether Spirit Bunny"] = 50,
	["Magic Butterfly"] = 40, ["Ultra Birdie"] = 40,
	["Muscle King"] = 70, ["Entropic Blast"] = 60,
}
local shopRarityPriority = { Basic = 1, Advanced = 2, Rare = 3, Epic = 4, Unique = 5 }


local function shopItemZone(option)
	local item = option.item
	for _, attribute in ipairs({ "ZoneRequirement", "IslandRequirement", "UnlockRequirement", "ZonePriority" }) do
		local value = item and tonumber(item:GetAttribute(attribute))
		if value then return value end
	end
	return shopZonePriority[option.name] or 0
end


local function shopOptionBetter(a, b)
	local zoneA = shopItemZone(a)
	local zoneB = shopItemZone(b)
	if zoneA ~= zoneB then return zoneA > zoneB end
	local priceA = tonumber(a.item and a.item:GetAttribute("Price")) or 0
	local priceB = tonumber(b.item and b.item:GetAttribute("Price")) or 0
	if priceA ~= priceB then return priceA > priceB end
	local rarityA = shopRarityPriority[tostring(a.item and a.item:GetAttribute("Rarity"))] or 0
	local rarityB = shopRarityPriority[tostring(b.item and b.item:GetAttribute("Rarity"))] or 0
	if rarityA ~= rarityB then return rarityA > rarityB end
	return a.name < b.name
end


local function shopLists()
	local pets = {}
	local auras = {}
	local folder = currentShopFolder()
	if folder then
		local livePets = {}
		local liveAuras = {}
		for _, item in ipairs(folder:GetChildren()) do
			local price = item:GetAttribute("Price")
			local priceType = item:GetAttribute("PriceType")
			if typeof(price) == "number" and (priceType == "Strength" or priceType == "Gems") then
				local option = {
					name = item.Name,
					label = item.Name,
					profileValue = item.Name,
					item = item,
				}
				local destination = item:GetAttribute("IsPowerUp") == true and liveAuras or livePets
				destination[#destination + 1] = option
			end
		end
		table.sort(livePets, shopOptionBetter)
		table.sort(liveAuras, shopOptionBetter)
		pets = livePets
		auras = liveAuras
	else
		for _, name in ipairs(CONFIG.UniquePets) do
			pets[#pets + 1] = { name = name, label = name, profileValue = name }
		end
		for _, name in ipairs(CONFIG.UniqueAuras) do
			auras[#auras + 1] = { name = name, label = name, profileValue = name }
		end
	end
	return pets, auras
end

local petNames, auraNames = shopLists()
local petPage = Pages["Pet Shop"]

local function updateShopInfo(selection, priceLabel)
	local item = type(selection) == "table" and selection.item
	if not item or not item.Parent then
		priceLabel.Text = "Esperando tienda real"
		return
	end
	local price = item:GetAttribute("Price")
	local priceType = item:GetAttribute("PriceType")
	priceLabel.Text = formatExact(price) .. " " .. tostring(priceType or "-")
end

__FGRoot.CrefyUI.uiAddSection(petPage, "🐾 Pets 🐾")
local petPriceValue
local petSelector = __FGRoot.CrefyUI.uiAddSelector(petPage, "Seleccionar Pet", petNames, function(selection)
	if petPriceValue then updateShopInfo(selection, petPriceValue) end
end)
State.petShopPetSelector = petSelector
petPriceValue = __FGRoot.CrefyUI.uiAddInfoRow(petPage, "Precio:", "-", C.yellow)
updateShopInfo(petSelector:Get(), petPriceValue)


local function buyShopItem(selection)
	local folder = currentShopFolder()
	local remote = currentShopRemote()
	local item = type(selection) == "table" and selection.item
	if (not item or not item.Parent) and folder and selection then
		local name = type(selection) == "table" and selection.name or tostring(selection)
		item = folder:FindFirstChild(name)
	end
	if not item or not remote or not remote:IsA("RemoteFunction") then
		return false
	end
	local priceType = item:GetAttribute("PriceType")
	if priceType ~= "Strength" and priceType ~= "Gems" then return false end
	local price=tonumber(item:GetAttribute("Price")) or 0
    local stat=getPlayerStat(LP,{priceType})
    if not stat or (tonumber(State.getFunctionalStatValue(stat)) or 0)<price then return false end
    local ok, result = pcall(function()
        return remote:InvokeServer(item)
    end)
	return ok and result == true
end

__FGRoot.CrefyUI.uiAddButton(petPage, "🐾 Comprar Pets 🐾", function()
	buyShopItem(petSelector:Get())
end)
__FGRoot.CrefyUI.uiAddToggle(petPage, "🔁 Auto Comprar Pet 🔁", function(enabled)
	State.autoPet = enabled
	if not enabled then
		stopThread("autoPet")
		return
	end
	startThread("autoPet", function()
		while State.running and State.autoPet do
            if not buyShopItem(petSelector:Get()) then
                State.autoPet=false
                local c=State.profileControls["Pet Shop|🔁 Auto Comprar Pet 🔁"]
                if c then c:Set(false,true) end
                State.pushOutput("ERROR","Compra detenida: fondos, inventario o respuesta del servidor")
                break
            end
            task.wait(0.6)
		end
	end)
end)

__FGRoot.CrefyUI.uiAddSection(petPage, "🌌 Auras 🌌")
local auraPriceValue
local auraSelector = __FGRoot.CrefyUI.uiAddSelector(petPage, "Seleccionar Aura", auraNames, function(selection)
	if auraPriceValue then updateShopInfo(selection, auraPriceValue) end
end)
State.petShopAuraSelector = auraSelector
auraPriceValue = __FGRoot.CrefyUI.uiAddInfoRow(petPage, "Precio:", "-", C.yellow)
updateShopInfo(auraSelector:Get(), auraPriceValue)
__FGRoot.CrefyUI.uiAddButton(petPage, "🌌 Comprar Aura 🌌", function()
	buyShopItem(auraSelector:Get())
end)
__FGRoot.CrefyUI.uiAddToggle(petPage, "🔁 Auto Comprar Aura 🔁", function(enabled)
	State.autoAura = enabled
	if not enabled then
		stopThread("autoAura")
		return
	end
	startThread("autoAura", function()
		while State.running and State.autoAura do
            if not buyShopItem(auraSelector:Get()) then
                State.autoAura=false
                local c=State.profileControls["Pet Shop|🔁 Auto Comprar Aura 🔁"]
                if c then c:Set(false,true) end
                State.pushOutput("ERROR","Compra detenida: fondos, inventario o respuesta del servidor")
                break
            end
            task.wait(0.6)
		end
	end)
end)


local function refreshShopSelectors()
	local pets, auras = shopLists()
	petSelector:SetValues(pets, true)
	auraSelector:SetValues(auras, true)
	updateShopInfo(petSelector:Get(), petPriceValue)
	updateShopInfo(auraSelector:Get(), auraPriceValue)
end

local shopFolder = currentShopFolder()
if shopFolder then
	track(shopFolder.ChildAdded:Connect(function()
		task.defer(refreshShopSelectors)
	end))
	track(shopFolder.ChildRemoved:Connect(function()
		task.defer(refreshShopSelectors)
	end))
else
	track(ReplicatedStorage.DescendantAdded:Connect(function(child)
		if child.Name == "cPetShopFolder" then
			task.defer(refreshShopSelectors)
		end
	end))
end
startThread("petShopPriceUpdater", function()
	while State.running do
		updateShopInfo(petSelector:Get(), petPriceValue)
		updateShopInfo(auraSelector:Get(), auraPriceValue)
		task.wait(1)
	end
end)
end
pageSetup()


pageSetup = function()
local inventoryPage = Pages["Inventario"]
local Inventory = {
	groups = {},
	options = {},
	selectedName = nil,
	autoEvolve = false,
}
State.Inventory = Inventory
local inventoryEvents = ReplicatedStorage:FindFirstChild("rEvents")
local inventoryEvolveRemote = inventoryEvents and inventoryEvents:FindFirstChild("petEvolveEvent")
local inventorySelector
local inventoryEvolvedValue
local inventoryUnevolvedValue
local inventoryEvolvedRow
local inventoryUnevolvedRow
local inventoryEvolvedLabel
local inventoryUnevolvedLabel
State.inventoryLab = {}


function Inventory:IsProtected(pet)
	return State.isProtectedPetAsset(pet)
end


function Inventory:GetEquippedSet()
	local equipped = {}
	local folder = LP:FindFirstChild("equippedPets")
	for _, slot in ipairs(folder and folder:GetChildren() or {}) do
		local reference = slot:FindFirstChild("petReference")
		local pet = reference and reference:IsA("ObjectValue") and reference.Value
		if not pet and slot:IsA("ObjectValue") then pet = slot.Value end
		if pet then equipped[pet] = true end
	end
	return equipped
end


function Inventory:IsEvolved(pet)
	local marker = pet and pet:FindFirstChild("evolved")
	if marker and marker:IsA("BoolValue") then return marker.Value == true end
	return pet and pet:GetAttribute("Evolved") == true or false
end


function Inventory:ShopCatalog()
    local shared = ReplicatedStorage:FindFirstChild("shared")
    local runtime = shared and shared:FindFirstChild("runtime")
    local folder = (runtime and runtime:FindFirstChild("cPetShopFolder")) or ReplicatedStorage:FindFirstChild("cPetShopFolder")
    local packPerks = runtime and runtime:FindFirstChild("packPetPerks")
    local packs, catalog = {}, {}
    for _, pack in pairs(CONFIG.FastFarm.Packs or {}) do
        if type(pack.rebirth) == "string" then packs[pack.rebirth] = true end
        for _, name in ipairs(pack.strength or {}) do packs[name] = true end
    end
    if folder then
        for _, item in ipairs(folder:GetChildren()) do
            local price, currency = item:GetAttribute("Price"), item:GetAttribute("PriceType")
            if typeof(price) == "number" and price == price and price >= 0
                and (currency == "Strength" or currency == "Gems") and item:GetAttribute("IsPowerUp") ~= true
                and item:GetAttribute("CanEvolve") ~= false and item:GetAttribute("Evolvable") ~= false
                and not packs[item.Name] and not (packPerks and packPerks:FindFirstChild(item.Name)) then
                catalog[item.Name] = true
            end
        end
    else
        for _, name in ipairs(CONFIG.UniquePets or {}) do
            if not packs[name] and not (packPerks and packPerks:FindFirstChild(name)) then catalog[name] = true end
        end
    end
    self.catalog = catalog
    return catalog
end

function Inventory:Scan()
	local groups = {}
	local equipped = self:GetEquippedSet()
	local folder = LP:FindFirstChild("petsFolder")
	for _, category in ipairs(folder and folder:GetChildren() or {}) do
		if category:IsA("Folder") then
			for _, pet in ipairs(category:GetChildren()) do
				if pet:IsA("StringValue") then
					local group = groups[pet.Name]
					if not group then
						group = { name = pet.Name, instances = {}, total = 0, evolved = 0, equipped = 0, protected = 0, unevolved = 0 }
						groups[pet.Name] = group
					end
					group.instances[#group.instances + 1] = pet
					group.total = group.total + 1
					if self:IsEvolved(pet) then
						group.evolved = group.evolved + 1
					else
						group.unevolved = group.unevolved + 1
					end
					if equipped[pet] then group.equipped = group.equipped + 1 end
					if self:IsProtected(pet) then group.protected = group.protected + 1 end
				end
			end
		end
	end
	local options = {}
	local catalog = self:ShopCatalog()
	for name, group in pairs(groups) do
		if catalog[name] then options[#options + 1] = { name = name, label = name, profileValue = name, group = group } end
	end
	table.sort(options, function(a, b) return a.name < b.name end)
	local signatureParts = {}
	for _, option in ipairs(options) do
		local group = option.group
		signatureParts[#signatureParts + 1] = string.format("%s:%d:%d:%d", option.name, group.total, group.evolved, group.protected)
	end
	self.groups = groups
	self.options = options
	self.signature = table.concat(signatureParts, "|")
	return options
end


function Inventory:UpdateInfo(selection)
	local name = type(selection) == "table" and selection.name or selection
	local changed = self.selectedName ~= name
	self.selectedName = name
	local group = name and self.groups[name]
	if inventoryEvolvedValue then inventoryEvolvedValue.Text = group and formatExact(group.evolved) or "0" end
	if inventoryUnevolvedValue then inventoryUnevolvedValue.Text = group and formatExact(group.unevolved) or "0" end
	if changed and self.autoEvolve and self.QueueRefresh then self:QueueRefresh() end
end


function Inventory:Refresh()
	local previousSignature = self.signature
	local options = self:Scan()
	if inventorySelector then
		if previousSignature ~= self.signature then
			inventorySelector:SetValues(options, true)
			if not inventorySelector:Get() and #options > 0 then inventorySelector:SetIndex(1) end
		end
		self:UpdateInfo(inventorySelector:Get())
	end
	self.labDirty = true
	if State.currentTab == "Inventario" then self:RefreshLab() end
	if self.autoEvolve then self:PumpEvolution() end
	return #options
end


function Inventory:CanAutoEvolve(group)
    if not group or not (self.catalog and self.catalog[group.name]) then return false, "Elegí una pet de la tienda" end
    if group.unevolved < 5 then return false, "Esperando 5 pets del mismo tipo" end
    local equipped, eligible = self:GetEquippedSet(), {}
    for _, pet in ipairs(group.instances) do
        if pet.Parent and not self:IsEvolved(pet) then
            if self:IsProtected(pet) or equipped[pet] then return false, "No se evolucionan pets equipadas o protegidas" end
            eligible[#eligible + 1] = pet
        end
    end
    if #eligible >= 5 then return true, nil, eligible end
    return false, "Esperando 5 pets del mismo tipo"
end

function Inventory:SetEvolutionError(message)
    self.autoEvolve = false
    State.inventoryAutoEvolve = false
    self.evolveStatus = message
    if self.AutoEvolveToggle then self.AutoEvolveToggle:Set(false, true) end
    State.pushOutput("ERROR", message)
end

function Inventory:EvolveSelected()
    if self.evolvePending or not self.autoEvolve or not State.running then return false end
    self:ShopCatalog()
    local group = self.selectedName and self.groups[self.selectedName]
    local allowed, reason, originals = self:CanAutoEvolve(group)
    self.evolveStatus = reason
    if not allowed then return false end
    local events = ReplicatedStorage:FindFirstChild("rEvents")
    inventoryEvolveRemote = events and events:FindFirstChild("petEvolveEvent")
    if not inventoryEvolveRemote or not inventoryEvolveRemote:IsA("RemoteEvent") then
        self:SetEvolutionError("Evolución no disponible en este servidor")
        return false
    end
    local pending = {
        name = group.name, originals = originals, evolved = group.evolved,
        started = os.clock(), deadline = os.clock() + 8,
    }
    self.evolvePending = pending
    self.evolveStatus = "Esperando confirmación de la evolución"
    local ok = pcall(inventoryEvolveRemote.FireServer, inventoryEvolveRemote, "evolvePet", group.name)
    if not ok then
        self.evolvePending = nil
        self:SetEvolutionError("No se pudo solicitar la evolución")
    end
    return ok
end

function Inventory:PumpEvolution()
    if not self.autoEvolve or not State.running or self.evolvePumping then return false end
    self.evolvePumping = true
    local pending = self.evolvePending
    if pending then
        local changed = 0
        local folder = LP:FindFirstChild("petsFolder")
        for _, pet in ipairs(pending.originals) do
            if not pet.Parent or not folder or not pet:IsDescendantOf(folder) or self:IsEvolved(pet) then changed = changed + 1 end
        end
        local group = self.groups[pending.name]
        if group and group.evolved > pending.evolved and changed >= 5 then
            self.evolvePending = nil
            self.evolveNextAt = os.clock() + 0.08
            self.evolveConfirmed = (self.evolveConfirmed or 0) + 1
            self.evolveStatus = "Pet evolucionada: " .. pending.name
            State.pushOutput("SYSTEM", self.evolveStatus)
        elseif os.clock() >= pending.deadline then
            self:SetEvolutionError("Evolución pausada: no llegó la confirmación del servidor")
        end
        self.evolvePumping = false
        return false
    end
    if os.clock() >= (self.evolveNextAt or 0) then self:EvolveSelected() end
    self.evolvePumping = false
    return self.evolvePending ~= nil
end

function Inventory:QueueRefresh()
    if self.refreshTask or not State.running then return end
    self.refreshTask = task.delay(0.06, function()
        self.refreshTask = nil
        if State.running then self:Refresh() end
    end)
end

function Inventory:BuildBestSetup(statName)
	local candidates = {}
	local folder = LP:FindFirstChild("petsFolder")
	for _, category in ipairs(folder and folder:GetChildren() or {}) do
		for _, pet in ipairs(category:IsA("Folder") and category:GetChildren() or {}) do
			if pet:IsA("StringValue") then
				local perks = pet:FindFirstChild("perksFolder")
				local perk = perks and perks:FindFirstChild(statName)
				local score = tonumber(perk and perk.Value) or 0
				if score > 0 then candidates[#candidates + 1] = { pet = pet, name = pet.Name, score = score, momentum = tonumber(pet:GetAttribute("MomentumSeconds")) or 0 } end
			end
		end
	end
	table.sort(candidates, function(a, b)
		if a.score ~= b.score then return a.score > b.score end
		if a.momentum ~= b.momentum then return a.momentum > b.momentum end
		return a.pet:GetFullName() < b.pet:GetFullName()
	end)
	local cap = FastFarm:GetPetSlotCapacity()
	local counts, total,refs = {}, 0,{}
	for index = 1, math.min(cap, #candidates) do
		local candidate = candidates[index]
		counts[candidate.name] = (counts[candidate.name] or 0) + 1
		total = total + candidate.score
		refs[candidate.name]=refs[candidate.name] or {}
		table.insert(refs[candidate.name],candidate.pet)
	end
	local setup, summary = {}, {}
	for name, count in pairs(counts) do setup[#setup + 1] = { name = name, count = count, pets=refs[name] }; summary[#summary + 1] = name .. " x" .. tostring(count) end
	table.sort(setup, function(a, b) return a.name < b.name end)
	table.sort(summary)
	return setup, total, table.concat(summary, " + ")
end

function Inventory:RefreshLab()
	if not State.inventoryLab.selector or not State.inventoryLab.result then return end
	local selected = State.inventoryLab.selector:Get() or "Fuerza"
	local key = ({ Fuerza = "strength", Durabilidad = "durability", ["Daño"] = "damage" })[selected] or "strength"
	local setup, total, summary = self:BuildBestSetup(key)
	self.labSetup, self.labStat, self.labTotal = setup, key, total
	State.inventoryLab.result.Text = summary ~= "" and summary or "Sin pets compatibles"
	self.labDirty = false
end

function Inventory:EquipBest()
	if FastFarm.mode or State.fastFarmMode then return false, "Detené Fast Farm antes de cambiar pets" end
	self:RefreshLab()
	if not self.labSetup or #self.labSetup == 0 then return false, "No hay pets compatibles" end
	local equipped = FastFarm.EquipSetup(self.labSetup, "petlab-" .. tostring(self.labStat))
	if equipped < 1 then return false, FastFarm.lastError or "No se confirmó el equipamiento" end
	return true, "Equipadas " .. tostring(equipped) .. " pets"
end

inventoryPage:SetAttribute("TightCanvas", true)
__FGRoot.CrefyUI.uiAddSection(inventoryPage, "Pet Lab")
State.inventoryLab.selector = __FGRoot.CrefyUI.uiAddSelector(inventoryPage, "Optimizar pets para", { "Fuerza", "Durabilidad", "Daño" }, function()
	Inventory:RefreshLab()
end)
State.inventoryLab.result = __FGRoot.CrefyUI.uiAddInfoRow(inventoryPage, "Mejor combinación:", "Analizando...", C.cyan, false, true)
State.inventoryLab.equipButton = __FGRoot.CrefyUI.uiAddButton(inventoryPage, "Equipar mejor combinación", function(button)
	State.setButtonDisabled(button, true)
	startThread("inventoryPetLab", function()
		local ok, message = Inventory:EquipBest()
        State.inventoryLab.flash = (State.inventoryLab.flash or 0) + 1
        local flash = State.inventoryLab.flash
        button.Text = message or (ok and "Completado" or "No disponible")
        task.delay(1.8, function()
            if State.running and button.Parent and State.inventoryLab.flash == flash then button.Text = "Equipar mejor combinación" end
        end)
		State.pushOutput(ok and "ON" or "ERROR", "Pet Lab: " .. tostring(message or "sin resultado"))
		State.setButtonDisabled(button, false)
	end)
end, C.tabOn, C.rowHover)
__FGRoot.CrefyUI.uiAddSection(inventoryPage, "Inventario")
inventorySelector = __FGRoot.CrefyUI.uiAddSelector(inventoryPage, "Pet", {}, function(selection)
	Inventory:UpdateInfo(selection)
end, nil, "Sin pets")
Inventory.Selector = inventorySelector
inventoryEvolvedValue, inventoryEvolvedRow, inventoryEvolvedLabel = __FGRoot.CrefyUI.uiAddInfoRow(
	inventoryPage, "Evolucionadas:", "0", C.cyan, false, true
)
inventoryUnevolvedValue, inventoryUnevolvedRow, inventoryUnevolvedLabel = __FGRoot.CrefyUI.uiAddInfoRow(
	inventoryPage, "No evolucionadas:", "0", C.white, false, true
)
for _, label in ipairs({ inventoryEvolvedLabel, inventoryUnevolvedLabel }) do
	label.Position = UDim2.fromOffset(16, 0)
	label.Size = UDim2.new(0.42, -6, 1, 0)
end
local inventoryAutoEvolveToggle = __FGRoot.CrefyUI.uiAddToggle(inventoryPage, "Auto evolucionar pet seleccionada", function(enabled)
    Inventory.autoEvolve = enabled == true
    State.inventoryAutoEvolve = Inventory.autoEvolve
    if not enabled then
        stopThread("inventoryAutoEvolve")
        return true
    end
    if Inventory.evolvePending and os.clock() >= Inventory.evolvePending.deadline then Inventory.evolvePending = nil end
    Inventory:Refresh()
    startThread("inventoryAutoEvolve", function()
        while State.running and Inventory.autoEvolve do
            if Inventory.evolvePending then Inventory:Refresh() else Inventory:PumpEvolution() end
            task.wait(Inventory.evolvePending and 0.12 or 0.25)
        end
    end)
    return true
end)
do
    local label
    for _, child in ipairs(inventoryAutoEvolveToggle.Button:GetChildren()) do
        if child:IsA("TextLabel") then label = child; break end
    end
    if label then
        label.Position = UDim2.fromOffset(16, 0)
        label.Size = UDim2.new(1, -68, 1, 0)
    end
end

Inventory.AutoEvolveToggle = inventoryAutoEvolveToggle

Inventory:Refresh()
do
    local watched, hooks
    local function disconnect()
        for _, connection in ipairs(hooks or {}) do connection:Disconnect() end
        hooks = nil
    end
    local function bind()
        local folder = LP:FindFirstChild("petsFolder")
        if folder == watched then return end
        disconnect()
        watched = folder
        if folder then
            hooks = {
                folder.DescendantAdded:Connect(function(object)
                    if object:IsA("StringValue") or object.Name == "evolved" or object:IsA("Folder") then Inventory:QueueRefresh() end
                end),
                folder.DescendantRemoving:Connect(function(object)
                    if object:IsA("StringValue") or object.Name == "evolved" or object:IsA("Folder") then Inventory:QueueRefresh() end
                end),
            }
        end
        Inventory:QueueRefresh()
    end
    track(LP.ChildAdded:Connect(function(child) if child.Name == "petsFolder" then bind() end end))
    track(LP.ChildRemoved:Connect(function(child) if child == watched then bind() end end))
    bind()
    addCleanup(disconnect)
end

startThread("inventorySlowRefresh", function()
	while State.running do
		Inventory:Refresh()
		task.wait(4)
	end
end)
addCleanup(function()
	Inventory.autoEvolve = false
	State.inventoryAutoEvolve = false
	stopThread("inventoryAutoEvolve")
	stopThread("inventorySlowRefresh")
	if Inventory.refreshTask then pcall(task.cancel, Inventory.refreshTask); Inventory.refreshTask = nil end
	Inventory.evolvePending = nil
end)
end
pageSetup()


pageSetup = function()
local profilesPage = Pages["Perfiles"]
local Profiles = {
	Root = "Young0xHub/FG100/profiles",
	Folder = "Young0xHub/FG100/profiles/" .. tostring(LP.UserId),
	selected = nil,
	deleteName = nil,
	deleteUntil = 0,
}
State.Profiles = Profiles
local profileSelector
local profileNameInput
local profileRenameInput
local profileDeleteButton
local profileLoadButton
local profileUpdateButton
local profileRenameButton

local updateProfileControls = function() end


function Profiles:Available()
	return type(isfile) == "function" and type(readfile) == "function"
		and type(writefile) == "function" and type(listfiles) == "function"
		and type(isfolder) == "function" and type(makefolder) == "function"
end


function Profiles:SetStatus(message, color)
	self.lastStatus = tostring(message or "")
	self.lastStatusColor = color
end


function Profiles:Sanitize(name)
	name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	name = name:gsub("[^%w%-%_ ]", "_"):sub(1, 32)
	return name
end


function Profiles:Normalize(name)
	return string.lower(self:Sanitize(name))
end


function Profiles:EnsureFolder()
	if not self:Available() then return false end
	return pcall(function()
		if not isfolder("Young0xHub") then makefolder("Young0xHub") end
		if not isfolder("Young0xHub/FG100") then makefolder("Young0xHub/FG100") end
		if not isfolder(self.Root) then makefolder(self.Root) end
		if not isfolder(self.Folder) then makefolder(self.Folder) end
	end)
end


function Profiles:Path(name)
	name = self:Sanitize(name)
	if name == "" then return nil end
	return self.Folder .. "/" .. name .. ".txt", name
end


function Profiles:List()
	if not self:EnsureFolder() then return {} end
	local ok, files = pcall(listfiles, self.Folder)
	if not ok or type(files) ~= "table" then return {} end
	local names = {}
	for _, path in ipairs(files) do
		local name = tostring(path):match("([^/\\]+)%.txt$")
		if name then names[#names + 1] = name end
	end
	table.sort(names)
	return names
end


function Profiles:FindDuplicate(name, exceptName)
	local normalized = self:Normalize(name)
	local exceptNormalized = exceptName and self:Normalize(exceptName) or nil
	if normalized == "" then return nil end
	for _, current in ipairs(self:List()) do
		local currentNormalized = self:Normalize(current)
		if currentNormalized == normalized and currentNormalized ~= exceptNormalized then
			return current
		end
	end
	return nil
end


function Profiles:Capture(name)
	local controls = {}
	for key, control in pairs(State.profileControls) do
		local ok, value = pcall(control.Get, control)
		if ok then
			if type(value) == "table" then
				value = value.profileValue or value.name or value.label or value[1]
			end
			if type(value) == "string" or type(value) == "number" or type(value) == "boolean" then
				controls[key] = { kind = control.ProfileKind, value = value }
			end
		end
	end
	return { version = 1, name = name, userId = LP.UserId, updatedAt = os.time(), controls = controls }
end


function Profiles:Write(name, allowOverwrite)
	local path, cleanName = self:Path(name)
	if not path then
		return false, nil, "empty"
	end
	if not self:EnsureFolder() then
		self:SetStatus("El executor no permite perfiles locales", C.red)
		return false, nil, "unavailable"
	end
	local duplicate = self:FindDuplicate(cleanName)
	if duplicate and not allowOverwrite then
		return false, nil, "duplicate", duplicate
	end
	if duplicate and allowOverwrite then
		path, cleanName = self:Path(duplicate)
	end
	local ok = pcall(function()
		local payload = game:GetService("HttpService"):JSONEncode(self:Capture(cleanName))
		writefile(path, payload)
	end)
	self:SetStatus(ok and ("Perfil guardado: " .. cleanName) or "No se pudo guardar el perfil", ok and C.green or C.red)
	local reason = nil
	if not ok then reason = "write" end
	return ok, cleanName, reason
end


function Profiles:Load(name)
	local path, cleanName = self:Path(name)
	if not path or not self:Available() or not isfile(path) then
		return false
	end
	local ok, payload = pcall(function()
		return game:GetService("HttpService"):JSONDecode(readfile(path))
	end)
	if not ok or type(payload) ~= "table" or type(payload.controls) ~= "table" then
		self:SetStatus("Perfil inválido o dañado", C.red)
		return false
	end
	local applied,failed=0,0
    for key,c in pairs(State.profileControls) do
        if c.ProfileKind=="toggle" and payload.controls[key] and c:Get() then pcall(c.Set,c,false) end
    end
    local function applyKind(wantToggles)
		local keys = {}
		for key in pairs(payload.controls) do keys[#keys + 1] = key end
		table.sort(keys)
		for _, key in ipairs(keys) do
			local record = payload.controls[key]
			local aliases = {
				["Fast Farm|Fast Strength"] = "Fast Farm|Fuerza rápida",
				["Fast Farm|Fast Rebirth"] = "Fast Farm|Rebirths rápidos",
			}
			local control = State.profileControls[key] or State.profileControls[aliases[key]]
			if control and type(record) == "table"
				and (control.ProfileKind == "toggle") == wantToggles then
				local success, accepted
				if control.ProfileKind == "selector" and type(control.SetValue) == "function" then
					local migrated = ({
						["Fuerza + Durabilidad"] = "Durabilidad + Fuerza",
						["Con mucha gente (18-19)"] = "Con mucha gente",
						["Lleno (18-19)"] = "Con mucha gente",
						["Equilibrado (8-14)"] = "Equilibrado",
						["Casi vacío (1-2)"] = "Casi vacío",
						["Buscar King libre"] = "Casi vacío",
					})[record.value] or record.value
					success, accepted = pcall(control.SetValue, control, migrated)
				else
					success, accepted = pcall(control.Set, control, record.value)
				end
				if success and accepted ~= false then applied = applied + 1 else failed=failed+1; State.pushOutput("ERROR","Perfil: "..key) end
			end
		end
	end
	applyKind(false)
	applyKind(true)
	self:SetStatus("Perfil cargado: " .. cleanName.." · "..tostring(applied).." OK / "..tostring(failed).." errores",failed==0 and C.green or C.red)
	return failed==0
end


function Profiles:Rename(oldName, requestedName)
	local oldPath, cleanOld = self:Path(oldName)
	local newPath, cleanNew = self:Path(requestedName)
	if not newPath then return false, nil, "empty" end
	if not oldPath or not newPath or type(delfile) ~= "function" then
		if not oldPath then return false end
		self:SetStatus("Nombre inválido o borrado local no disponible", C.red)
		return false
	end
	if not isfile(oldPath) then
		return false
	end
	if self:Normalize(cleanOld) == self:Normalize(cleanNew) then
		return false, nil, "same"
	end
	local duplicate = self:FindDuplicate(cleanNew, cleanOld)
	if duplicate or isfile(newPath) then
		return false, nil, "duplicate", duplicate or cleanNew
	end
	local ok = pcall(function()
		local payload = game:GetService("HttpService"):JSONDecode(readfile(oldPath))
		if type(payload) == "table" then payload.name = cleanNew end
		writefile(newPath, game:GetService("HttpService"):JSONEncode(payload))
		delfile(oldPath)
	end)
	self:SetStatus(ok and (cleanOld .. " renombrado a " .. cleanNew) or "No se pudo renombrar", ok and C.green or C.red)
	local reason = nil
	if not ok then reason = "write" end
	return ok, cleanNew, reason
end


function Profiles:Delete(name)
	local path, cleanName = self:Path(name)
	if not path or type(delfile) ~= "function" or not isfile(path) then
		return false
	end
	local ok = pcall(delfile, path)
	self:SetStatus(ok and ("Perfil eliminado: " .. cleanName) or "No se pudo eliminar", ok and C.green or C.red)
	return ok
end


function Profiles:Refresh()
	local names = self:List()
	profileSelector:SetValues(names, true)
	if not profileSelector:Get() and #names > 0 then profileSelector:SetIndex(1) end
	self.selected = profileSelector:Get()
	updateProfileControls()
	return names
end

local profileFeedbackSerial = setmetatable({}, { __mode = "k" })

local function profileButtonFeedback(button, message, color, defaultText)
	if not button then return end
	local serial = (profileFeedbackSerial[button] or 0) + 1
	profileFeedbackSerial[button] = serial
	button.Text = message
	button.BackgroundColor3 = color or Color3.fromRGB(92, 74, 24)
	task.delay(1.8, function()
		if button.Parent and profileFeedbackSerial[button] == serial then
			button.Text = defaultText
			button.BackgroundColor3 = C.row
		end
	end)
end


function Profiles:CancelDeleteConfirmation()
	self.deleteName = nil
	self.deleteUntil = 0
	if profileDeleteButton then
		profileDeleteButton.Text = "Eliminar perfil"
		profileDeleteButton.BackgroundColor3 = C.row
	end
end

__FGRoot.CrefyUI.uiAddSection(profilesPage, "Perfil seleccionado")
profileSelector = __FGRoot.CrefyUI.uiAddSelector(profilesPage, "Perfil", {}, function(value)
	if Profiles.selected ~= value then Profiles:CancelDeleteConfirmation() end
	Profiles.selected = value
	updateProfileControls()
end, nil, "No tenés perfiles")
Profiles.Selector = profileSelector
profileLoadButton = __FGRoot.CrefyUI.uiAddButton(profilesPage, "Cargar perfil", function()
	if not Profiles.selected then return end
	Profiles:Load(Profiles.selected)
end)
profileUpdateButton = __FGRoot.CrefyUI.uiAddButton(profilesPage, "Guardar cambios", function()
	if not Profiles.selected then return end
	local ok, name = Profiles:Write(Profiles.selected, true)
	if ok then
		Profiles:Refresh()
		profileSelector:SetValue(name)
	end
end)

__FGRoot.CrefyUI.uiAddSection(profilesPage, "Nuevo perfil")

State.hideProfileCreate = function()
	profileNameInput.Parent.Visible = false
	State.profileCreateSaveButton.Visible = false
	State.profileCreateCancelButton.Visible = false
end
__FGRoot.CrefyUI.uiAddButton(profilesPage, "Crear perfil", function()
	if State.hideProfileRename then State.hideProfileRename() end
	profileNameInput.Parent.Visible = true
	State.profileCreateSaveButton.Visible = true
	State.profileCreateCancelButton.Visible = true
	profileNameInput:CaptureFocus()
end)
profileNameInput = __FGRoot.CrefyUI.uiAddInput(profilesPage, "Nombre", "Mi perfil", function() end)
State.profileCreateSaveButton = __FGRoot.CrefyUI.uiAddButton(profilesPage, "Guardar", function()
	local ok, name, reason, duplicate = Profiles:Write(profileNameInput.Text, false)
	if ok then
		Profiles:Refresh()
		profileSelector:SetValue(name)
		State.hideProfileCreate()
	elseif reason == "duplicate" then
		profileButtonFeedback(State.profileCreateSaveButton, "Ya existe: " .. tostring(duplicate), nil, "Guardar")
	elseif reason == "empty" then
		profileButtonFeedback(State.profileCreateSaveButton, "Ingresá un nombre", nil, "Guardar")
	end
end)
State.profileCreateCancelButton = __FGRoot.CrefyUI.uiAddButton(profilesPage, "Cancelar", function()
	State.hideProfileCreate()
end)
profileNameInput.Parent.Visible = false
State.profileCreateSaveButton.Visible = false
State.profileCreateCancelButton.Visible = false
__FGRoot.CrefyUI.uiAddSection(profilesPage, "Administrar")

State.hideProfileRename = function()
	profileRenameInput.Parent.Visible = false
	State.profileRenameConfirmButton.Visible = false
	State.profileRenameCancelButton.Visible = false
end
profileRenameButton = __FGRoot.CrefyUI.uiAddButton(profilesPage, "Renombrar perfil", function()
	if not Profiles.selected then return end
	State.hideProfileCreate()
	profileRenameInput.Parent.Visible = true
	State.profileRenameConfirmButton.Visible = true
	State.profileRenameCancelButton.Visible = true
	profileRenameInput:CaptureFocus()
end)
profileRenameInput = __FGRoot.CrefyUI.uiAddInput(profilesPage, "Nuevo nombre", "Nombre nuevo", function() end)
State.profileRenameConfirmButton = __FGRoot.CrefyUI.uiAddButton(profilesPage, "Confirmar", function()
	local ok, newName, reason, duplicate = Profiles:Rename(Profiles.selected, profileRenameInput.Text)
	if ok then
		Profiles:Refresh()
		profileSelector:SetValue(newName)
		State.hideProfileRename()
	elseif reason == "duplicate" then
		profileButtonFeedback(State.profileRenameConfirmButton, "Ya existe: " .. tostring(duplicate), nil, "Confirmar")
	elseif reason == "same" then
		profileButtonFeedback(State.profileRenameConfirmButton, "Usá otro nombre", nil, "Confirmar")
	elseif reason == "empty" then
		profileButtonFeedback(State.profileRenameConfirmButton, "Ingresá un nombre", nil, "Confirmar")
	end
end)
State.profileRenameCancelButton = __FGRoot.CrefyUI.uiAddButton(profilesPage, "Cancelar", function()
	State.hideProfileRename()
end)
profileRenameInput.Parent.Visible = false
State.profileRenameConfirmButton.Visible = false
State.profileRenameCancelButton.Visible = false
profileDeleteButton = __FGRoot.CrefyUI.uiAddButton(profilesPage, "Eliminar perfil", function(button)
	if not Profiles.selected then return end
	local path, name = Profiles:Path(Profiles.selected)
	if not path or type(delfile) ~= "function" or not isfile(path) then
		button.BackgroundColor3 = C.row
		Profiles:Refresh()
		return
	end
	if Profiles.deleteName ~= name or time() > Profiles.deleteUntil then
		Profiles.deleteName = name
		Profiles.deleteUntil = time() + 6
		button.Text = "Confirmar eliminar " .. name
		button.BackgroundColor3 = C.red
		task.delay(6.1, function()
			if button.Parent and Profiles.deleteName == name and time() > Profiles.deleteUntil then
				Profiles:CancelDeleteConfirmation()
			end
		end)
		return
	end
	local ok = Profiles:Delete(name)
	Profiles:CancelDeleteConfirmation()
	if ok then Profiles:Refresh() end
end, C.row, C.rowHover)

updateProfileControls = function()
	local hasSelection = Profiles.selected ~= nil and Profiles.selected ~= ""
	for _, button in ipairs({ profileLoadButton, profileUpdateButton, profileRenameButton, profileDeleteButton }) do
		State.setButtonDisabled(button, not hasSelection)
	end
	if not hasSelection then
		Profiles:CancelDeleteConfirmation()
		if profileDeleteButton then profileDeleteButton.BackgroundColor3 = Color3.fromRGB(30, 33, 40) end
		if State.hideProfileRename then State.hideProfileRename() end
	end
end
Profiles:Refresh()
end
pageSetup()


pageSetup = function()
local fusePage = Pages["Fuse Machine"]
fusePage.Parent.Name = "PagesContainer"
fusePage.Name = "FuseOptimizerPage"

local fuseRecipes = {
	{
		key = "FusePet1",
		name = "Mushroom Sprout",
		fallbackChance = 45,
		pets = {
			{ name = "Dark Vampy", power = 10 },
			{ name = "Dark Vampy", power = 10 },
			{ name = "Dark Vampy", power = 10 },
			{ name = "Dark Vampy", power = 10 },
		},
	},
	{
		key = "FusePet2",
		name = "Candy Wisp",
		fallbackChance = 30,
		pets = {
			{ name = "Alien Girl", power = 30 },
			{ name = "Alien Girl", power = 30 },
			{ name = "Alien Girl", power = 30 },
			{ name = "Alien Girl", power = 30 },
		},
	},
	{
		key = "FusePet3",
		name = "Pebble Dragon",
		fallbackChance = 33.33,
		pets = {
			{ name = "Dark Golem", power = 8 },
			{ name = "Dark Golem", power = 8 },
			{ name = "A. Gnatomy", power = 22 },
			{ name = "Phantom Genesis Dragon", power = 48 },
		},
	},
	{
		key = "FusePet4",
		name = "Griffin",
		fallbackChance = 31.25,
		pets = {
			{ name = "Orange Pegasus", power = 20 },
			{ name = "Green Firecaster", power = 36 },
			{ name = "Green Firecaster", power = 36 },
			{ name = "Cool Guy Larry", power = 62 },
		},
	},
	{
		key = "FusePet5",
		name = "Venom Bloom",
		fallbackChance = 35,
		pets = {
			{ name = "Dark Vampy", power = 10 },
			{ name = "Dark Vampy", power = 10 },
			{ name = "Core Pup", power = 70 },
			{ name = "Core Pup", power = 70 },
		},
	},
	{
		key = "FusePet6",
		name = "Moonlight",
		fallbackChance = 40,
		pets = {
			{ name = "Orange Pegasus", power = 20 },
			{ name = "Neon Guardian", power = 80 },
			{ name = "Neon Guardian", power = 80 },
			{ name = "Neon Guardian", power = 80 },
		},
	},
	{
		key = "FusePet7",
		name = "Prismatic Chimera",
		fallbackChance = 55,
		pets = {
			{ name = "Apex Overlord", power = 100 },
			{ name = "Apex Overlord", power = 100 },
			{ name = "Apex Overlord", power = 100 },
			{ name = "Apex Overlord", power = 100 },
		},
	},
	{
		key = "FusePet8",
		name = "Eclipse Sovereign",
		fallbackChance = 5,
		pets = {
			{ name = "Titan Reactor", power = 94 },
			{ name = "Titan Reactor", power = 94 },
			{ name = "Titan Reactor", power = 94 },
			{ name = "Titan Reactor", power = 94 },
		},
	},
}

local petCraftConfig
local petCraft
local petCraftController
do
	local shared = ReplicatedStorage:FindFirstChild("shared")
	local configFolder = shared and shared:FindFirstChild("config")
	local modulesFolder = shared and shared:FindFirstChild("modules")
	local client = ReplicatedStorage:FindFirstChild("client")
	local controllersFolder = client and client:FindFirstChild("controllers")
	local configModule = configFolder and configFolder:FindFirstChild("PetCraftConfig")
	local craftModule = modulesFolder and modulesFolder:FindFirstChild("PetCraft")
	local controllerModule = controllersFolder and controllersFolder:FindFirstChild("PetCraftController")
	if configModule and configModule:IsA("ModuleScript") then
		local ok, result = pcall(require, configModule)
		if ok and type(result) == "table" then
			petCraftConfig = result
		end
	end
	if craftModule and craftModule:IsA("ModuleScript") then
		local ok, result = pcall(require, craftModule)
		if ok and type(result) == "table" then
			petCraft = result
		end
	end
	if controllerModule and controllerModule:IsA("ModuleScript") then
		local ok, result = pcall(require, controllerModule)
		if ok and type(result) == "table" then
			petCraftController = result
		end
	end
end


local function countNormalPets(petName)
	local count = 0
	local folder = LP:FindFirstChild("petsFolder")
	if not folder then
		return count
	end
	for _, category in ipairs(folder:GetChildren()) do
		if category:IsA("Folder") then
			for _, pet in ipairs(category:GetChildren()) do
				if pet.Name == petName and not pet:FindFirstChild("evolved") then
					count = count + 1
				end
			end
		end
	end
	return count
end


local function combinedFusePower(recipe)
	local count = #recipe.pets
	local sumSquares = 0
	local strongest = 0
	for _, input in ipairs(recipe.pets) do
		local power = input.power
		if petCraftConfig and type(petCraftConfig.BASE_FUSE_POWER) == "table" then
			power = tonumber(petCraftConfig.BASE_FUSE_POWER[input.name]) or power
		end
		sumSquares = sumSquares + (power * power)
		strongest = math.max(strongest, power)
	end
	local rms = count > 0 and math.sqrt(sumSquares / count) or 0
	local rmsWeight = petCraftConfig and tonumber(petCraftConfig.RMS_WEIGHT) or 0.5
	local strongestWeight = petCraftConfig and tonumber(petCraftConfig.STRONGEST_WEIGHT) or 0.5
	local power = (rms * rmsWeight) + (strongest * strongestWeight)
	local minimum = petCraftConfig and tonumber(petCraftConfig.MIN_FUSE_POWER) or 0
	local maximum = petCraftConfig and tonumber(petCraftConfig.MAX_FUSE_POWER) or 100
	return math.clamp(power, minimum, maximum)
end


local function targetChance(recipe, power)
	if petCraft and type(petCraft.GetVisibleResults) == "function" then
		local ok, results = pcall(petCraft.GetVisibleResults, power)
		if ok and type(results) == "table" then
			for _, result in ipairs(results) do
				if result.Key == recipe.key or result.PetName == recipe.name then
					return tonumber(result.Chance) or 0
				end
			end
			return 0
		end
	end
	return recipe.fallbackChance
end


local function formatChance(value)
	if math.abs(value - math.round(value)) < 0.005 then
		return formatExact(math.round(value)) .. "%"
	end
	return string.format("%.2f%%", value)
end

__FGRoot.CrefyUI.uiAddSection(fusePage, "Fuse Optimizer")

local selectedRecipe = fuseRecipes[1]
local refreshFuseOptimizer
local refreshFuseProcess
local fuseConfirmationExpires = 0
local fuseSelector, fuseSelectorValue = __FGRoot.CrefyUI.uiAddSelector(fusePage, "Pet que querés", fuseRecipes, function(value)
	selectedRecipe = type(value) == "table" and value or fuseRecipes[1]
	fuseConfirmationExpires = 0
	if refreshFuseOptimizer then
		refreshFuseOptimizer()
	end
	if refreshFuseProcess then
		refreshFuseProcess()
	end
end)
fuseSelectorValue.Name = "FuseTargetValue"
fuseSelectorValue.Parent.Name = "FuseTargetSelector"
fuseSelectorValue.Parent.Parent.Name = "FuseTargetSelectorRow"
for index, child in ipairs(fuseSelectorValue.Parent.Parent:GetDescendants()) do
	if child:IsA("TextButton") and child ~= fuseSelectorValue.Parent then
		child.Name = "FuseTargetOption_" .. formatExact(index)
	end
end

local chanceValue = __FGRoot.CrefyUI.uiAddInfoRow(fusePage, "Probabilidad máxima", "-", C.green, false, true)
local recipeCard = Instance.new("Frame")
recipeCard.LayoutOrder = nextOrder(fusePage)
recipeCard.Parent = fusePage
__FGRoot.CrefyUI.styleRow(recipeCard, 48)

local recipeTitle = Instance.new("TextLabel")
recipeTitle.Size = UDim2.new(1, -22, 0, 18)
recipeTitle.Position = UDim2.fromOffset(11, 3)
recipeTitle.BackgroundTransparency = 1
recipeTitle.Text = "Pets en Fuse Machine"
recipeTitle.TextColor3 = C.cyan
recipeTitle.Font = C.fontBold
recipeTitle.TextSize = 10
recipeTitle.TextXAlignment = Enum.TextXAlignment.Left
recipeTitle.ZIndex = 13
	recipeTitle:SetAttribute("KeepTextStyle", true)
recipeTitle.Parent = recipeCard

local recipeLines = {}
for index = 1, 4 do
	local dot = Instance.new("Frame")
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Size = UDim2.fromOffset(5, 5)
	dot.Position = UDim2.fromOffset(14, 30 + ((index - 1) * 18))
	dot.BackgroundColor3 = C.cyan
	dot.BorderSizePixel = 0
	dot.ZIndex = 13
	dot.Parent = recipeCard
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.7, -24, 0, 18)
	nameLabel.Position = UDim2.fromOffset(22, 21 + ((index - 1) * 18))
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = "-"
	nameLabel.TextColor3 = C.white
	nameLabel.Font = UI_FONT
	nameLabel.TextSize = 11
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.ZIndex = 13
	nameLabel.Parent = recipeCard

	local ownedLabel = Instance.new("TextLabel")
	ownedLabel.Size = UDim2.new(0.3, -12, 0, 18)
	ownedLabel.Position = UDim2.new(0.7, 0, 0, 21 + ((index - 1) * 18))
	ownedLabel.BackgroundTransparency = 1
	ownedLabel.Text = "-"
	ownedLabel.TextColor3 = C.yellow
	ownedLabel.Font = UI_FONT
	ownedLabel.TextSize = 11
	ownedLabel.TextXAlignment = Enum.TextXAlignment.Right
	ownedLabel.ZIndex = 13
	ownedLabel:SetAttribute("KeepTextStyle", true)
	ownedLabel.Parent = recipeCard

	recipeLines[index] = {
		dot = dot,
		name = nameLabel,
		owned = ownedLabel,
	}
end

local notice = Instance.new("Frame")
notice.LayoutOrder = nextOrder(fusePage)
notice.Parent = fusePage
__FGRoot.CrefyUI.styleRow(notice, 48)
local noticeAccent = Instance.new("Frame")
noticeAccent.Size = UDim2.fromOffset(3, 28)
noticeAccent.Position = UDim2.new(0, 8, 0.5, -14)
noticeAccent.BackgroundColor3 = C.yellow
noticeAccent.BackgroundTransparency = 0.08
noticeAccent.BorderSizePixel = 0
noticeAccent.ZIndex = 12
noticeAccent.Parent = notice
Instance.new("UICorner", noticeAccent).CornerRadius = UDim.new(1, 0)
local noticeText = Instance.new("TextLabel")
noticeText.Size = UDim2.new(1, -32, 1, -8)
noticeText.Position = UDim2.fromOffset(21, 4)
noticeText.BackgroundTransparency = 1
noticeText.Text = "La Fuse Machine sigue siendo RNG. Esta receta maximiza la probabilidad de conseguir la pet elegida."
noticeText.TextColor3 = C.dim
noticeText.Font = UI_FONT
noticeText.TextSize = 11
noticeText.TextWrapped = true
noticeText.TextScaled = true
noticeText.TextXAlignment = Enum.TextXAlignment.Left
noticeText.TextYAlignment = Enum.TextYAlignment.Center
noticeText.ZIndex = 12
	noticeText:SetAttribute("KeepTextStyle", true)
noticeText.Parent = notice
local noticeTextLimit = Instance.new("UITextSizeConstraint", noticeText)
noticeTextLimit.MinTextSize = 7
noticeTextLimit.MaxTextSize = 11

	chanceValue:SetAttribute("KeepTextStyle", true)

local activeSectionLabel = __FGRoot.CrefyUI.uiAddSection(fusePage, "Fusión activa")
local activeSection = activeSectionLabel.Parent
activeSection.Visible = false

local processCard = Instance.new("Frame")
processCard.Name = "FuseProcessCard"
processCard.LayoutOrder = nextOrder(fusePage)
processCard.Parent = fusePage
processCard.Visible = false
__FGRoot.CrefyUI.styleRow(processCard, 46)

local processAccent = Instance.new("Frame")
processAccent.Name = "ProcessAccent"
processAccent.Size = UDim2.fromOffset(3, 26)
processAccent.Position = UDim2.new(0, 8, 0.5, -13)
processAccent.BackgroundColor3 = C.cyan
processAccent.BorderSizePixel = 0
processAccent.ZIndex = 13
processAccent.Parent = processCard
Instance.new("UICorner", processAccent).CornerRadius = UDim.new(1, 0)

local processTitle = Instance.new("TextLabel")
processTitle.Name = "FuseProcessTitle"
processTitle.Size = UDim2.new(0.58, -20, 0, 30)
processTitle.Position = UDim2.fromOffset(20, 2)
processTitle.BackgroundTransparency = 1
processTitle.Text = "Fusionando"
processTitle.TextColor3 = C.white
processTitle.Font = C.fontBold
processTitle.TextSize = 12
processTitle.TextXAlignment = Enum.TextXAlignment.Left
processTitle.TextTruncate = Enum.TextTruncate.AtEnd
processTitle.ZIndex = 13
	processTitle:SetAttribute("KeepTextStyle", true)
processTitle.Parent = processCard

local processTimer = Instance.new("TextLabel")
processTimer.Name = "FuseProcessTimer"
processTimer.Size = UDim2.new(0.42, -20, 0, 30)
processTimer.Position = UDim2.new(0.58, 0, 0, 2)
processTimer.BackgroundTransparency = 1
processTimer.Text = ""
processTimer.TextColor3 = C.white
processTimer.Font = C.fontBold
processTimer.TextSize = 11
processTimer.TextXAlignment = Enum.TextXAlignment.Right
processTimer.ZIndex = 13
	processTimer:SetAttribute("KeepTextStyle", true)
processTimer.Parent = processCard

local processTrack = Instance.new("Frame")
processTrack.Name = "FuseProgressTrack"
processTrack.Size = UDim2.new(1, -40, 0, 4)
processTrack.Position = UDim2.new(0, 20, 1, -9)
processTrack.BackgroundColor3 = C.black
processTrack.BackgroundTransparency = 0.28
processTrack.BorderSizePixel = 0
processTrack.ClipsDescendants = true
processTrack.ZIndex = 13
processTrack.Parent = processCard
Instance.new("UICorner", processTrack).CornerRadius = UDim.new(1, 0)

local processFill = Instance.new("Frame")
processFill.Name = "FuseProgressFill"
processFill.Size = UDim2.fromScale(0, 1)
processFill.BackgroundColor3 = C.cyan
processFill.BorderSizePixel = 0
processFill.ZIndex = 14
processFill.Parent = processTrack
Instance.new("UICorner", processFill).CornerRadius = UDim.new(1, 0)


refreshFuseOptimizer = function()
	local recipe = selectedRecipe or fuseRecipes[1]
	local power = combinedFusePower(recipe)
	local chance = targetChance(recipe, power)
	chanceValue.Text = formatChance(chance) .. " por intento"
	chanceValue.TextColor3 = chance >= 30 and C.green or (chance >= 10 and C.yellow or C.orange)

	local grouped = {}
	local order = {}
	for _, input in ipairs(recipe.pets) do
		if not grouped[input.name] then
			grouped[input.name] = 0
			order[#order + 1] = input.name
		end
		grouped[input.name] = grouped[input.name] + 1
	end

	for index, name in ipairs(order) do
		local required = grouped[name]
		local owned = countNormalPets(name)
		local ownedColor = owned >= required and C.green or (owned > 0 and C.yellow or C.red)
		local item = recipeLines[index]
		item.dot.Visible = true
		item.name.Visible = true
		item.owned.Visible = true
		item.name.Text = "x" .. formatExact(required) .. "  " .. name
		item.owned.Text = "Tenés " .. formatExact(math.min(owned, required)) .. "/" .. formatExact(required)
		item.owned.TextColor3 = ownedColor
		item.dot.BackgroundColor3 = ownedColor
	end
	for index = #order + 1, #recipeLines do
		recipeLines[index].dot.Visible = false
		recipeLines[index].name.Visible = false
		recipeLines[index].owned.Visible = false
	end
	recipeCard.Size = UDim2.new(1, 0, 0, 28 + (#order * 18))
end

local fuseMode = "idle"
local fuseTotalDuration
local fuseBusy = false
local fusePlacedCount = 0
local fuseFeedbackExpires = 0
local prepareRecipeButton
local removePetsButton
local fuseActionButton
local refreshInventoryButton
local feedbackRow
local feedbackAccent
local feedbackText
local fuseButtonAccents = {}


local function formatFuseTime(seconds)
	local remaining = math.max(0, math.ceil(tonumber(seconds) or 0))
	local hours = math.floor(remaining / 3600)
	local minutes = math.floor((remaining % 3600) / 60)
	local secs = remaining % 60
	if hours > 0 then
		return string.format("%dh %02dm %02ds", hours, minutes, secs)
	end
	return string.format("%02dm %02ds", minutes, secs)
end


local function configuredFuseDuration(fuse)
	local duration
	if type(fuse) == "table" and petCraftConfig and type(petCraftConfig.RARITY_FUSE_DURATION) == "table" then
		duration = tonumber(petCraftConfig.RARITY_FUSE_DURATION[fuse.Rarity])
	end
	duration = duration or (petCraftConfig and tonumber(petCraftConfig.FUSE_DURATION))
	return math.max(duration or 0, type(fuse) == "table" and tonumber(fuse.RemainingTime) or 0)
end


local function describeFuseReason(reason)
	local messages = {
		empty = "Falta una pet.",
		notOwned = "Una pet ya no está disponible.",
		duplicate = "Las 4 pets deben ser distintas.",
		equipped = "Desequipá las pets primero.",
		tradeLocked = "Una pet está en intercambio.",
		robuxPet = "Esa pet no se puede fusionar.",
		protected = "Quitá la protección de la pet.",
		blocked = "Una pet está bloqueada.",
		unconfigured = "Combinación no disponible.",
		evolvedNotAllowed = "No acepta pets evolucionadas.",
		incompleteSlots = "Colocá las 4 pets.",
		ineligibleInput = "Una pet no es válida.",
		rewardsUnavailable = "No hay resultados disponibles.",
		cooldown = "Esperá un momento.",
		rateLimited = "Esperá un momento.",
		busy = "Fuse Machine ocupada.",
		tooFar = "Acercate a la Fuse Machine.",
		notReady = "La pet todavía no está lista.",
		grantFailed = "No se pudo entregar la pet.",
		petsFull = "Inventario de pets lleno.",
		invalidRequest = "Solicitud rechazada.",
		noRemote = "Fuse Machine no disponible.",
		fuseActive = "Ya hay una fusión activa.",
		fuseNotReady = "La pet todavía no está lista.",
		noFuse = "No hay una pet para reclamar.",
		disabled = "Fuse Machine desactivada.",
	}
	return messages[tostring(reason or "")] or "No se pudo completar."
end


local function setFuseButton(button, text, enabled, accentColor)
    if not button then return end
    local available = enabled == true
    button.Text = tostring(text or "")
    button:SetAttribute("FuseEnabled", available)
    button:SetDisabled(not available)
end


local function updateFuseButtons()
	local active = fuseMode == "fusing" or fuseMode == "ready"
	setFuseButton(prepareRecipeButton, fuseBusy and "Procesando..." or "Poner pets", not fuseBusy and not active, C.cyan)
	local removeLabel = fusePlacedCount > 0 and ("Quitar pets · " .. formatExact(fusePlacedCount) .. "/4") or "Quitar pets"
	setFuseButton(removePetsButton, removeLabel, not fuseBusy and not active and fusePlacedCount > 0, C.blue)
	setFuseButton(refreshInventoryButton, "Actualizar inventario", not fuseBusy, C.cyan)
	if fuseBusy then
		setFuseButton(fuseActionButton, "Procesando...", false, C.cyan)
	elseif fuseMode == "fusing" then
		setFuseButton(fuseActionButton, "Fusionando", false, C.cyan)
	elseif fuseMode == "ready" then
		setFuseButton(fuseActionButton, "Reclamar", true, C.green)
	elseif fuseConfirmationExpires > os.clock() then
		setFuseButton(fuseActionButton, "Confirmar fusión", true, C.yellow)
	else
		setFuseButton(fuseActionButton, "Fusionar", not fuseBusy and fusePlacedCount == 4, C.cyan)
	end
end


local function setFuseProcess(mode, detail, remaining, total)
	fuseMode = mode or "idle"
	local showingActiveFuse = fuseMode == "fusing" or fuseMode == "ready"
	activeSection.Visible = showingActiveFuse
	processCard.Visible = showingActiveFuse
	if not showingActiveFuse then
		processTimer.Visible = false
		processTimer.Text = ""
		processTrack.Visible = false
	end
	if fuseMode == "fusing" and type(remaining) == "number" then
		local duration = math.max(tonumber(total) or remaining, 1)
		processTitle.Text = "Fusionando"
		processTitle.TextColor3 = C.white
		processAccent.BackgroundColor3 = C.cyan
		processTimer.Visible = true
		processTimer.Text = formatFuseTime(remaining)
		processTimer.TextColor3 = C.white
		processTrack.Visible = true
		processFill.Size = UDim2.fromScale(math.clamp(1 - (remaining / duration), 0, 1), 1)
		processFill.BackgroundColor3 = C.cyan
	elseif fuseMode == "ready" then
		processTitle.Text = "Pet lista para reclamar"
		processTitle.TextColor3 = C.green
		processTitle.Size = UDim2.new(1, -40, 0, 42)
		processAccent.BackgroundColor3 = C.green
		processTimer.Visible = false
		processTrack.Visible = false
	end
	if fuseMode ~= "ready" then
		processTitle.Size = UDim2.new(0.58, -20, 0, 30)
	end

	local feedback
	local feedbackColor
	if fuseMode == "confirm" then
		feedback = "Las 4 pets se eliminan al fusionar."
		feedbackColor = C.yellow
	elseif fuseMode == "error" then
		feedback = tostring(detail or "No se pudo completar.")
		feedbackColor = C.red
		fuseFeedbackExpires = os.clock() + 4
	elseif fuseMode == "claimed" then
		feedback = tostring(detail or "Pet reclamada.")
		feedbackColor = C.green
		fuseFeedbackExpires = os.clock() + 5
	end
	if feedbackRow then
		feedbackRow.Visible = feedback ~= nil
		if feedback then
			feedbackText.Text = feedback
			feedbackText.TextColor3 = feedbackColor
			feedbackAccent.BackgroundColor3 = feedbackColor
		end
	end
	updateFuseButtons()
end


local function getFuseRemaining()
	if not petCraftController or type(petCraftController.GetFuseRemaining) ~= "function" then
		return nil
	end
	local ok, remaining = pcall(petCraftController.GetFuseRemaining, petCraftController)
	return ok and type(remaining) == "number" and remaining or nil
end


local function getPlacedPetCount()
	if not petCraftController or type(petCraftController.GetSlots) ~= "function" then
		return 0
	end
	local ok, slots = pcall(petCraftController.GetSlots, petCraftController)
	if not ok or type(slots) ~= "table" then
		return 0
	end
	local count = 0
	for index = 1, 4 do
		if slots[index] then
			count = count + 1
		end
	end
	return count
end


local function findPlacedRecipeIndex()
	if not petCraftController or type(petCraftController.GetSlots) ~= "function" then
		return nil
	end
	local ok, slots = pcall(petCraftController.GetSlots, petCraftController)
	if not ok or type(slots) ~= "table" then
		return nil
	end
	local placed = {}
	for index = 1, 4 do
		local pet = slots[index]
		if not pet then
			return nil
		end
		placed[pet.Name] = (placed[pet.Name] or 0) + 1
	end
	for recipeIndex, recipe in ipairs(fuseRecipes) do
		local needed = {}
		for _, input in ipairs(recipe.pets) do
			needed[input.name] = (needed[input.name] or 0) + 1
		end
		local matches = true
		for name, amount in pairs(needed) do
			if placed[name] ~= amount then
				matches = false
				break
			end
		end
		for name, amount in pairs(placed) do
			if needed[name] ~= amount then
				matches = false
				break
			end
		end
		if matches then
			return recipeIndex
		end
	end
	return nil
end


refreshFuseProcess = function()
	if fuseBusy then
		return
	end
	local remaining = getFuseRemaining()
	if type(remaining) == "number" then
		fusePlacedCount = getPlacedPetCount()
		if remaining > 0 then
			fuseTotalDuration = math.max(tonumber(fuseTotalDuration) or 0, remaining)
			setFuseProcess("fusing", nil, remaining, fuseTotalDuration)
		else
			setFuseProcess("ready", nil, 0, fuseTotalDuration)
		end
	else
		local placedCount = getPlacedPetCount()
		fusePlacedCount = placedCount
		if fuseConfirmationExpires > 0 and fuseConfirmationExpires <= os.clock() then
		fuseConfirmationExpires = 0
			setFuseProcess(placedCount == 4 and "prepared" or "idle",
				placedCount == 4 and "4/4 pets colocadas." or nil)
		elseif fuseFeedbackExpires > 0 and fuseFeedbackExpires <= os.clock()
			and (fuseMode == "error" or fuseMode == "claimed") then
			fuseFeedbackExpires = 0
			setFuseProcess(placedCount == 4 and "prepared" or "idle")
		elseif fuseMode == "idle" and placedCount == 4 then
			setFuseProcess("prepared")
		elseif fuseMode == "prepared" and placedCount ~= 4 then
			setFuseProcess("idle")
		else
			updateFuseButtons()
		end
	end
end


local function addFuseActionButton(text, callback)
    local button = __FGRoot.CrefyUI.uiAddButton(fusePage, text, function(proxy)
        if proxy and proxy:GetAttribute("FuseEnabled") == true then
            pcall(callback, proxy)
        end
    end)
    button:SetAttribute("FuseEnabled", true)
    return button
end


local function prepareFuseRecipe()
	if fuseBusy then
		return
	end
	local activeRemaining = getFuseRemaining()
	if type(activeRemaining) == "number" then
		refreshFuseProcess()
		return
	end
	local recipe = selectedRecipe or fuseRecipes[1]
	local petsFolder = LP:FindFirstChild("petsFolder")
	if not petsFolder or not petCraftController
		or type(petCraftController.SetSlot) ~= "function"
		or type(petCraftController.DescribePet) ~= "function" then
		setFuseProcess("error", "La Fuse Machine todavía no está disponible.")
		return
	end

	local selected = {}
	local used = {}
	for _, input in ipairs(recipe.pets) do
		local chosen
		for _, category in ipairs(petsFolder:GetChildren()) do
			if chosen then break end
			if category:IsA("Folder") then
				for _, pet in ipairs(category:GetChildren()) do
					if pet.Name == input.name and not used[pet] and not pet:FindFirstChild("evolved") then
						local ok, description = pcall(petCraftController.DescribePet, petCraftController, pet)
						if ok and type(description) == "table" and description.Eligible then
							chosen = pet
							break
						end
					end
			end
		end
		end
		if not chosen then
			setFuseProcess("error", "Faltan pets para esta receta.")
			return
		end
		used[chosen] = true
		selected[#selected + 1] = chosen
	end

	local previous = type(petCraftController.GetSlots) == "function"
		and petCraftController:GetSlots() or {}
	fuseBusy = true
	fuseConfirmationExpires = 0
	setFuseProcess("loading", "Colocando cuatro pets distintas...")
	local cleared = pcall(petCraftController.ClearSlots, petCraftController)
	if not cleared then
		fuseBusy = false
		setFuseProcess("error", "No se pudieron limpiar los espacios de fusión.")
		return
	end
	for index, pet in ipairs(selected) do
		local ok, accepted = pcall(petCraftController.SetSlot, petCraftController, index, pet)
		if not ok or not accepted then
			pcall(petCraftController.ClearSlots, petCraftController)
			for oldIndex = 1, 4 do
				local oldPet = previous[oldIndex]
				if oldPet and oldPet.Parent then
					pcall(petCraftController.SetSlot, petCraftController, oldIndex, oldPet)
				end
			end
			fuseBusy = false
			setFuseProcess("error", "No se pudo colocar la receta. Intentá nuevamente.")
			return
		end
	end
	fuseBusy = false
	fusePlacedCount = 4
	local preview = type(petCraftController.GetLatestPreview) == "function"
		and petCraftController:GetLatestPreview() or nil
	if type(preview) == "table" and tonumber(preview.FuseDuration) then
		fuseTotalDuration = tonumber(preview.FuseDuration)
	end
	setFuseProcess("prepared")
end


local function removeFusePets()
	if fuseBusy or fusePlacedCount <= 0 or getFuseRemaining() ~= nil
		or not petCraftController or type(petCraftController.ClearSlots) ~= "function" then
		return
	end
	fuseBusy = true
	fuseConfirmationExpires = 0
	setFuseProcess("loading")
	local ok = pcall(petCraftController.ClearSlots, petCraftController)
	fuseBusy = false
	fusePlacedCount = getPlacedPetCount()
	if ok and fusePlacedCount == 0 then
		setFuseProcess("idle")
	else
		setFuseProcess("error", "No se pudieron quitar las pets.")
	end
end


local function claimFinishedFuse()
	if fuseBusy or not petCraftController or type(petCraftController.ClaimFuse) ~= "function" then
		return
	end
	fuseBusy = true
	setFuseProcess("loading", "Retirando tu nueva pet...")
	local ok, response = pcall(petCraftController.ClaimFuse, petCraftController)
	fuseBusy = false
	if not ok or type(response) ~= "table" then
		setFuseProcess("error", "No se pudo reclamar la pet. Intentá nuevamente.")
		return
	end
	if response.Ok and type(response.Result) == "table" then
		local petName = tostring(response.Result.PetName or "nueva pet")
		fusePlacedCount = 0
		setFuseProcess("claimed", "Obtuviste: " .. petName)
		refreshFuseOptimizer()
	elseif response.Fuse then
		local remaining = tonumber(response.Fuse.RemainingTime) or 0
		fuseTotalDuration = math.max(tonumber(fuseTotalDuration) or 0, configuredFuseDuration(response.Fuse))
		setFuseProcess(remaining > 0 and "fusing" or "ready",
			nil,
			remaining, fuseTotalDuration)
	else
		setFuseProcess("error", describeFuseReason(response.Reason))
	end
end


local function fuseSelectedPets()
	if fuseBusy then
		return
	end
	local remaining = getFuseRemaining()
	if type(remaining) == "number" then
		if remaining <= 0 then
			claimFinishedFuse()
		else
			refreshFuseProcess()
		end
		return
	end
	if not petCraftController or type(petCraftController.Craft) ~= "function" then
		setFuseProcess("error", "La Fuse Machine todavía no está disponible.")
		return
	end
	if getPlacedPetCount() ~= 4 then
		setFuseProcess("error", "Colocá las 4 pets.")
		return
	end
	if fuseConfirmationExpires <= os.clock() then
		fuseConfirmationExpires = os.clock() + 4
		setFuseProcess("confirm")
		return
	end

	fuseConfirmationExpires = 0
	fuseBusy = true
	setFuseProcess("loading", "Iniciando la fusión...")
	local ok, response = pcall(petCraftController.Craft, petCraftController)
	fuseBusy = false
	if not ok or type(response) ~= "table" then
		setFuseProcess("error", "No se pudo iniciar la fusión. Intentá nuevamente.")
		return
	end
	if response.Ok and response.Fuse then
		local startedRemaining = tonumber(response.Fuse.RemainingTime) or 0
		fusePlacedCount = 0
		fuseTotalDuration = math.max(tonumber(fuseTotalDuration) or 0, configuredFuseDuration(response.Fuse))
		setFuseProcess(startedRemaining > 0 and "fusing" or "ready",
			nil,
			startedRemaining, fuseTotalDuration)
		refreshFuseOptimizer()
	elseif response.Ok and type(response.Result) == "table" then
		fusePlacedCount = 0
		setFuseProcess("claimed", "Obtuviste: " .. tostring(response.Result.PetName or "nueva pet"))
		refreshFuseOptimizer()
	else
		setFuseProcess("error", describeFuseReason(response.Reason))
	end
end

prepareRecipeButton = addFuseActionButton("Poner pets", prepareFuseRecipe)
prepareRecipeButton.Name = "FusePrepareRecipeButton"

removePetsButton = addFuseActionButton("Quitar pets", removeFusePets)
removePetsButton.Name = "FuseRemovePetsButton"

fuseActionButton = addFuseActionButton("Fusionar", fuseSelectedPets)
fuseActionButton.Name = "FuseActionButton"

refreshInventoryButton = addFuseActionButton("Actualizar inventario", refreshFuseOptimizer)
refreshInventoryButton.Name = "FuseRefreshInventoryButton"

feedbackRow = Instance.new("Frame")
feedbackRow.Name = "FuseFeedbackRow"
feedbackRow.LayoutOrder = nextOrder(fusePage)
feedbackRow.Parent = fusePage
feedbackRow.Visible = false
__FGRoot.CrefyUI.styleRow(feedbackRow, 32)
feedbackAccent = Instance.new("Frame")
feedbackAccent.Size = UDim2.fromOffset(3, 18)
feedbackAccent.Position = UDim2.new(0, 8, 0.5, -9)
feedbackAccent.BackgroundColor3 = C.red
feedbackAccent.BorderSizePixel = 0
feedbackAccent.ZIndex = 13
feedbackAccent.Parent = feedbackRow
Instance.new("UICorner", feedbackAccent).CornerRadius = UDim.new(1, 0)
feedbackText = Instance.new("TextLabel")
feedbackText.Size = UDim2.new(1, -32, 1, 0)
feedbackText.Position = UDim2.fromOffset(20, 0)
feedbackText.BackgroundTransparency = 1
feedbackText.Text = ""
feedbackText.TextColor3 = C.red
feedbackText.Font = UI_FONT
feedbackText.TextSize = 11
feedbackText.TextXAlignment = Enum.TextXAlignment.Left
feedbackText.TextTruncate = Enum.TextTruncate.AtEnd
feedbackText.ZIndex = 13
	feedbackText:SetAttribute("KeepTextStyle", true)
feedbackText.Parent = feedbackRow

local petsFolder = LP:FindFirstChild("petsFolder")
if petsFolder then
	track(petsFolder.DescendantAdded:Connect(function()
		task.defer(refreshFuseOptimizer)
	end))
	track(petsFolder.DescendantRemoving:Connect(function()
		task.defer(refreshFuseOptimizer)
	end))
end

local placedRecipeIndex = findPlacedRecipeIndex()
fusePlacedCount = getPlacedPetCount()
if placedRecipeIndex then
	fuseSelector:SetIndex(placedRecipeIndex)
else
	refreshFuseOptimizer()
end
setFuseProcess(placedRecipeIndex and "prepared" or "idle")
if petCraftController and type(petCraftController.GetFuse) == "function" then
	startThread("fuseMachineQuery", function()
		local ok, fuse = pcall(petCraftController.GetFuse, petCraftController)
		if ok and type(fuse) == "table" then
			fuseTotalDuration = configuredFuseDuration(fuse)
		end
		refreshFuseProcess()
	end)
elseif petCraftController and type(petCraftController.EnsureFuseKnown) == "function" then
	pcall(petCraftController.EnsureFuseKnown, petCraftController)
end
startThread("fuseMachineStatus", function()
	while State.running do
		refreshFuseProcess()
		task.wait(0.5)
	end
end)
end
pageSetup()


pageSetup = function()
local statsPage = Pages.Stats
__FGRoot.CrefyUI.uiAddSection(statsPage, "Estadísticas")

State.statsTargetUserId = LP.UserId

State.statsTargetOptions = function()
	local options = {
		{ label = LP.DisplayName, name = LP.Name, userId = LP.UserId },
	}
	local others = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LP then
			others[#others + 1] = {
				label = player.DisplayName,
				name = player.Name,
				userId = player.UserId,
			}
		end
	end
	table.sort(others, function(a, b)
		return a.label:lower() < b.label:lower()
	end)
	for _, option in ipairs(others) do options[#options + 1] = option end
	return options
end

State.statsSelectedPlayer = function()
	return Players:GetPlayerByUserId(tonumber(State.statsTargetUserId) or LP.UserId)
end

local playerCard = Instance.new("Frame")
playerCard.Name = "PlayerCard"
playerCard.LayoutOrder = nextOrder(statsPage)
playerCard.Parent = statsPage
__FGRoot.CrefyUI.styleRow(playerCard, 112)

local playerAccent = Instance.new("Frame")
playerAccent.Size = UDim2.fromOffset(3, 84)
playerAccent.Position = UDim2.new(0, 8, 0.5, -42)
playerAccent.BackgroundColor3 = C.blue
playerAccent.BackgroundTransparency = 0.08
playerAccent.BorderSizePixel = 0
playerAccent.ZIndex = 13
playerAccent.Parent = playerCard
Instance.new("UICorner", playerAccent).CornerRadius = UDim.new(1, 0)

local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.Size = UDim2.fromOffset(72, 72)
avatar.Position = UDim2.fromOffset(18, 20)
avatar.BackgroundColor3 = C.panel
avatar.BackgroundTransparency = 0.10
avatar.BorderSizePixel = 0
avatar.Image = State.profileImage
avatar.ScaleType = Enum.ScaleType.Crop
avatar.ZIndex = 13
avatar.Parent = playerCard
State.profileAvatar = avatar
Instance.new("UICorner", avatar).CornerRadius = UDim.new(0, 12)
addRgbStroke(avatar, 1, 0.16)

local displayLabel = Instance.new("TextLabel")
displayLabel.Name = "DisplayName"
displayLabel.Size = UDim2.new(1, -112, 0, 22)
displayLabel.Position = UDim2.fromOffset(102, 10)
displayLabel.BackgroundTransparency = 1
displayLabel.Text = tostring(LP.DisplayName)
displayLabel.TextColor3 = C.white
displayLabel.Font = C.fontBold
displayLabel.TextSize = 15
displayLabel.TextXAlignment = Enum.TextXAlignment.Left
displayLabel.TextTruncate = Enum.TextTruncate.AtEnd
displayLabel.ZIndex = 13
displayLabel.Parent = playerCard

local userLabel = Instance.new("TextLabel")
userLabel.Name = "Username"
userLabel.Size = UDim2.new(1, -112, 0, 17)
userLabel.Position = UDim2.fromOffset(102, 33)
userLabel.BackgroundTransparency = 1
userLabel.Text = "@" .. tostring(LP.Name)
userLabel.TextColor3 = C.dim
userLabel.Font = UI_FONT
userLabel.TextSize = 11
userLabel.TextXAlignment = Enum.TextXAlignment.Left
userLabel.TextTruncate = Enum.TextTruncate.AtEnd
userLabel.ZIndex = 13
userLabel.Parent = playerCard

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FPS"
fpsLabel.Size = UDim2.fromOffset(90, 19)
fpsLabel.Position = UDim2.fromOffset(102, 55)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 0"
fpsLabel.TextColor3 = C.green
fpsLabel.Font = C.fontBold
fpsLabel.TextSize = 11
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.ZIndex = 13
fpsLabel.Parent = playerCard

local pingValue = Instance.new("TextLabel")
pingValue.Name = "Ping"
pingValue.Size = UDim2.new(1, -210, 0, 19)
pingValue.Position = UDim2.fromOffset(196, 55)
pingValue.BackgroundTransparency = 1
pingValue.Text = "Ping: 0 ms"
pingValue.TextColor3 = C.green
pingValue.Font = C.fontBold
pingValue.TextSize = 11
pingValue.TextXAlignment = Enum.TextXAlignment.Left
pingValue.TextTruncate = Enum.TextTruncate.AtEnd
pingValue.ZIndex = 13
pingValue.Parent = playerCard

local uptimeValue = Instance.new("TextLabel")
uptimeValue.Name = "ScriptUptime"
uptimeValue.Size = UDim2.new(1, -112, 0, 20)
uptimeValue.Position = UDim2.fromOffset(102, 80)
uptimeValue.BackgroundTransparency = 1
uptimeValue.Text = "Script ejecutado hace: 0h 00m 00s"
uptimeValue.TextColor3 = C.soft
uptimeValue.Font = UI_FONT
uptimeValue.TextSize = 11
uptimeValue.TextXAlignment = Enum.TextXAlignment.Left
uptimeValue.TextTruncate = Enum.TextTruncate.AtEnd
uptimeValue.ZIndex = 13
uptimeValue.Parent = playerCard

local statRows = {
	{ icon = "💪", label = "Fuerza", names = { "Strength", "Fuerza" } },
	{ icon = "🛡️", label = "Durabilidad", names = { "Durability", "Durabilidad" } },
	{ icon = "⚡", label = "Agilidad", names = { "Agility", "Agilidad" } },
	{ icon = "🔄", label = "Rebirths", names = { "Rebirths", "Renacimientos" } },
	{ icon = "⚔️", label = "Kills", names = { "Kills" } },
	{ icon = "🥊", label = "Peleas", names = { "Brawls", "Fights", "Fight" } },
	{ icon = "💎", label = "Gemas", names = { "Gems", "Gemas" } },
	{ icon = "😇", label = "Good Karma", names = { "goodKarma", "Good Karma" } },
	{ icon = "😈", label = "Evil Karma", names = { "evilKarma", "Evil Karma" } },
}

local statGrid = Instance.new("Frame")
statGrid.Size = UDim2.new(1, 0, 0, 210)
statGrid.BackgroundTransparency = 1
statGrid.BorderSizePixel = 0
statGrid.LayoutOrder = nextOrder(statsPage)
statGrid.ZIndex = 11
statGrid.Parent = statsPage

local statGridLayout = Instance.new("UIGridLayout")
statGridLayout.CellSize = UDim2.new(0.3333, -4, 0, 66)
statGridLayout.CellPadding = UDim2.fromOffset(6, 6)
statGridLayout.FillDirectionMaxCells = 3
statGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
statGridLayout.Parent = statGrid

for index, definition in ipairs(statRows) do
	local card = Instance.new("Frame")
	card.BackgroundColor3 = C.row
	card.BackgroundTransparency = 0.20
	card.BorderSizePixel = 0
	card.LayoutOrder = index
	card.ZIndex = 12
	card.Parent = statGrid
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
	addRgbStroke(card, 1, 0.24)

	local icon = Instance.new("Frame")
	icon.Size = UDim2.fromOffset(34, 34)
	icon.Position = UDim2.fromOffset(10, 13)
	icon.BackgroundColor3 = C.tabOn
	icon.BackgroundTransparency = 0.72
	icon.BorderSizePixel = 0
	icon.ZIndex = 13
	icon.Parent = card
	Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 8)
	local glyph = Instance.new("TextLabel")
	glyph.Size = UDim2.fromScale(1, 1)
	glyph.BackgroundTransparency = 1
	glyph.Text = definition.icon
	glyph.TextColor3 = C.white
	glyph.Font = C.fontBold
	glyph.TextSize = 18
	glyph.ZIndex = 14
	glyph.Parent = icon

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -62, 0, 18)
	title.Position = UDim2.fromOffset(54, 8)
	title.BackgroundTransparency = 1
	title.Text = definition.label
	title.TextColor3 = C.soft
	title.Font = C.fontBold
	title.TextSize = 11
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.ZIndex = 13
	title.Parent = card

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(1, -62, 0, 27)
	valueLabel.Position = UDim2.fromOffset(54, 25)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = "0"
	valueLabel.TextColor3 = C.white
	valueLabel.Font = C.fontBold
	valueLabel.TextScaled = true
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left
	valueLabel.ZIndex = 13
	valueLabel.Parent = card
	local valueConstraint = Instance.new("UITextSizeConstraint")
	valueConstraint.MinTextSize = 10
	valueConstraint.MaxTextSize = 18
	valueConstraint.Parent = valueLabel

	definition.valueLabel = valueLabel
end


State.setStatsPrivateRowsVisible = function(visible)
	visible = visible == true
	fpsLabel.Visible = visible
	pingValue.Visible = visible
	uptimeValue.Visible = visible
end
State.statsPlayerSelector = __FGRoot.CrefyUI.uiAddSelector(statsPage, "Ver estadísticas de", State.statsTargetOptions(), function(value)
	State.statsTargetUserId = type(value) == "table" and value.userId or LP.UserId
	State.setStatsPrivateRowsVisible(State.statsTargetUserId == LP.UserId)
	local requestedUserId = State.statsTargetUserId
	State.requestThumbnail(requestedUserId, function(image)
		if avatar.Parent and State.statsTargetUserId == requestedUserId then avatar.Image = image end
	end)
end)

local scriptStartedAt = os.time()

local function formatScriptUptime(seconds)
	local days = math.floor(seconds / 86400)
	local hours = math.floor(seconds % 86400 / 3600)
	local minutes = math.floor(seconds % 3600 / 60)
	local secs = seconds % 60
	if days > 0 then
		return string.format("%dd %02dh %02dm %02ds", days, hours, minutes, secs)
	end
	return string.format("%dh %02dm %02ds", hours, minutes, secs)
end
startThread("statsUpdater", function()
	while State.running do
		local selectedPlayer = State.statsSelectedPlayer() or LP
		if selectedPlayer.UserId ~= State.statsTargetUserId then
			State.statsTargetUserId = selectedPlayer.UserId
			if State.statsPlayerSelector then State.statsPlayerSelector:SetIndex(1) end
		end
		if State.statsRenderedUserId ~= selectedPlayer.UserId then
			State.statsRenderedUserId = selectedPlayer.UserId
			displayLabel.Text = tostring(selectedPlayer.DisplayName)
			userLabel.Text = "@" .. tostring(selectedPlayer.Name)
			local renderedUserId = selectedPlayer.UserId
			avatar.Image = State.thumbnailCache[renderedUserId]
				or ("rbxthumb://type=AvatarHeadShot&id=" .. tostring(renderedUserId) .. "&w=150&h=150")
			State.requestThumbnail(renderedUserId, function(image)
				if avatar.Parent and State.statsRenderedUserId == renderedUserId then avatar.Image = image end
			end)
		end
		local localProfile = selectedPlayer == LP
		State.setStatsPrivateRowsVisible(localProfile)
		if localProfile then
			local elapsed = os.time() - scriptStartedAt
			uptimeValue.Text = "Script ejecutado hace: " .. formatScriptUptime(elapsed)
			local fps = tonumber(State.currentFps) or 0
			local fpsColor = fps >= 55 and C.green or (fps >= 30 and C.orange or C.red)
			fpsLabel.Text = "FPS: " .. tostring(fps)
			fpsLabel.TextColor3 = fpsColor
			local ping = getPing()
			local pingColor = State.pingStatusColor(ping)
			pingValue.Text = "Ping: " .. tostring(ping) .. " ms"
			pingValue.TextColor3 = pingColor
		end
		for _, definition in ipairs(statRows) do
			local stat = getPlayerStat(selectedPlayer, definition.names)
			local current = stat and tonumber(stat.Value) or 0
			local visualRecord = localProfile and stat and State.visualStatRecords and State.visualStatRecords[stat]
			definition.valueLabel.Text = formatExact(visualRecord and visualRecord.value or current)
		end
		task.wait(0.5)
	end
end)
end
pageSetup()

pageSetup = function()
end
pageSetup()

__FGRoot.setMinimized = nil
__FGRoot.minimizeKey = Enum.KeyCode.RightShift
__FGRoot.waitingForMinimizeKey = false
__FGRoot.minimizeKeyButton = nil

State.minimizeKeyConfigFolder = "Young0xHub/FG100"
State.minimizeKeyConfigPath = State.minimizeKeyConfigFolder
	.. "/keybind_" .. tostring(LP.UserId) .. ".txt"

State.loadMinimizeKey = function()
	if type(isfile) ~= "function" or type(readfile) ~= "function" then
		return false
	end
	local ok, storedName = pcall(function()
		if not isfile(State.minimizeKeyConfigPath) then
			return nil
		end
		return readfile(State.minimizeKeyConfigPath)
	end)
	if not ok or type(storedName) ~= "string" then
		return false
	end
	storedName = storedName:match("^%s*([%w_]+)%s*$")
	if not storedName then
		return false
	end
	for _, keyCode in ipairs(Enum.KeyCode:GetEnumItems()) do
		if keyCode.Name == storedName
			and keyCode ~= Enum.KeyCode.Escape
			and keyCode ~= Enum.KeyCode.Unknown then
			__FGRoot.minimizeKey = keyCode
			return true
		end
	end
	return false
end

State.saveMinimizeKey = function(keyCode)
	if typeof(keyCode) ~= "EnumItem" or keyCode.EnumType ~= Enum.KeyCode
		or type(writefile) ~= "function" then
		return false
	end
	return pcall(function()
		if type(isfolder) == "function" and type(makefolder) == "function"
			and not isfolder(State.minimizeKeyConfigFolder) then
			makefolder(State.minimizeKeyConfigFolder)
		end
		writefile(State.minimizeKeyConfigPath, keyCode.Name)
	end)
end
State.loadMinimizeKey()


__FGRoot.minimizeKeyName = function(keyCode)
	local localizedNames = {
		[Enum.KeyCode.RightShift] = "Shift derecho",
		[Enum.KeyCode.LeftShift] = "Shift izquierdo",
		[Enum.KeyCode.Space] = "Espacio",
		[Enum.KeyCode.Backspace] = "Retroceso",
		[Enum.KeyCode.Return] = "Enter",
		[Enum.KeyCode.Escape] = "Esc",
		[Enum.KeyCode.CapsLock] = "Bloq Mayús",
		[Enum.KeyCode.KeypadZero] = "Numpad 0",
		[Enum.KeyCode.KeypadOne] = "Numpad 1",
		[Enum.KeyCode.KeypadTwo] = "Numpad 2",
		[Enum.KeyCode.KeypadThree] = "Numpad 3",
		[Enum.KeyCode.KeypadFour] = "Numpad 4",
		[Enum.KeyCode.KeypadFive] = "Numpad 5",
		[Enum.KeyCode.KeypadSix] = "Numpad 6",
		[Enum.KeyCode.KeypadSeven] = "Numpad 7",
		[Enum.KeyCode.KeypadEight] = "Numpad 8",
		[Enum.KeyCode.KeypadNine] = "Numpad 9",
	}
	if localizedNames[keyCode] then
		return localizedNames[keyCode]
	end
	local ok, printable = pcall(UserInputService.GetStringForKeyCode, UserInputService, keyCode)
	if ok and type(printable) == "string" and printable ~= "" then
		return printable
	end
	return keyCode.Name
end


__FGRoot.minimizeKeyText = function()
	return "Keybind: " .. __FGRoot.minimizeKeyName(__FGRoot.minimizeKey)
end

do

local function setupExpandedMisc()
local PROTECTED_MISC_TARGET_USER_IDS = {
	[4473738491] = true,
}
local PROTECTED_MISC_TARGET_NAMES = {
	young0x = true,
	dm_sebas94k = true,
}


local function isProtectedMiscTarget(player)
	if not player then return false end
	if PROTECTED_MISC_TARGET_USER_IDS[player.UserId] then return true end
	return PROTECTED_MISC_TARGET_NAMES[tostring(player.Name):lower()] == true
		or PROTECTED_MISC_TARGET_NAMES[tostring(player.DisplayName):lower()] == true
end
State.isProtectedMiscTarget = isProtectedMiscTarget


local function miscTargetOptions()
	local options = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LP and not isProtectedMiscTarget(player) then
			options[#options + 1] = {
				label = player.DisplayName,
				name = player.Name,
				userId = player.UserId,
			}
		end
	end
	table.sort(options, function(a, b)
		return a.label:lower() < b.label:lower()
	end)
	return options
end
State.miscTargetOptions = miscTargetOptions


local function miscNotify(text)
	pcall(function()
		local message = tostring(text or "")
		if type(State.translateText) == "function" then message = State.translateText(message) end
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Young0x Hub - Misc",
			Text = message,
			Duration = 4,
		})
	end)
end
State.miscNotify = miscNotify

State.miscVisualFlags = {
	names = false,
	boxes = false,
	tracers = false,
	distance = false,
	durability = false,
}
State.miscVisualObjects = {}
State.miscTarget = nil
State.miscFollowEnabled = false
State.miscFollowDistance = 5
State.miscFaceTarget = false
State.miscOrbitEnabled = false
State.miscOrbitRadius = 10
State.miscOrbitSpeed = 4
State.miscMinimapEnabled = false
State.miscFovEnabled = false
State.miscFov = math.floor((workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView) or 70)
State.miscHidePlayers = false
State.miscHideGameUi = false
State.miscZoomEnabled = false

do
	State.miscClickTp = false
	State.miscHidePets = false
	State.miscFpsUnlock = false
	State.miscHeadless = false
	State.miscFreecam = false
	State.miscFreecamSpeed = 80
	State.miscFreecamKeys = {}
	State.miscFreecamTouchMove = Vector2.zero
	State.miscAvatarOriginals = setmetatable({}, { __mode = "k" })


	local function captureAndHide(store, object)
		if object:IsA("BasePart") then
			if store[object] == nil then store[object] = { "LocalTransparencyModifier", object.LocalTransparencyModifier } end
			object.LocalTransparencyModifier = 1
		elseif object:IsA("Decal") or object:IsA("Texture") then
			if store[object] == nil then store[object] = { "Transparency", object.Transparency } end
			object.Transparency = 1
		elseif object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam")
			or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles")
			or object:IsA("BillboardGui") or object:IsA("SurfaceGui")
			or object:IsA("PointLight") or object:IsA("SpotLight") or object:IsA("SurfaceLight")
			or object:IsA("Highlight") then
			if store[object] == nil then store[object] = { "Enabled", object.Enabled } end
			object.Enabled = false
		end
	end


	local function restoreVisual(store, object)
		local snapshot = store[object]
		if not snapshot then return end
		if object.Parent then pcall(function() object[snapshot[1]] = snapshot[2] end) end
		store[object] = nil
	end


	local function restoreVisualStore(store)
		for object in pairs(store) do restoreVisual(store, object) end
	end


	local function setOfficialPetVisibility(hidden)
		local playerGui = LP:FindFirstChildOfClass("PlayerGui")
		local gameGui = playerGui and playerGui:FindFirstChild("gameGui")
		local legacyMenu = gameGui and gameGui:FindFirstChild("settingsMenu")
		local legacySettings = legacyMenu and legacyMenu:FindFirstChild("settingsFrame")
		local modernMenu = gameGui and gameGui:FindFirstChild("settingsNewMenu")
		local modernScroll = modernMenu and modernMenu:FindFirstChild("ScrollingFrame", true)
		local preferenceController = nil
		local useModernMenus = false
		local loaded = pcall(function()
			preferenceController = require(ReplicatedStorage.client.controllers.PlayerPreferenceController)
			useModernMenus = require(ReplicatedStorage.client.utils.UiVariant).UseNewMenus() == true
		end)
		if not loaded or type(preferenceController) ~= "table" then return false end
		local ownSetting = useModernMenus and modernScroll and modernScroll:FindFirstChild("MyPetsBase")
			or legacySettings and legacySettings:FindFirstChild("showPetsSetting")
		local otherSetting = useModernMenus and modernScroll and modernScroll:FindFirstChild("OtherPets")
			or legacySettings and legacySettings:FindFirstChild("showOtherPetsSetting")
		if not ownSetting or not otherSetting or type(preferenceController.TogglePetSetting) ~= "function"
			or type(preferenceController.AreOtherPetsShown) ~= "function" then return false end
		local shouldShow = not hidden
		if (LP:GetAttribute("PetsVisible") == true) ~= shouldShow then
			preferenceController:TogglePetSetting(ownSetting)
		end
		if (preferenceController:AreOtherPetsShown() == true) ~= shouldShow then
			preferenceController:TogglePetSetting(otherSetting)
		end
		return true
	end


	State.setMiscHidePets = function(enabled)
		local hidden = enabled == true
		if not setOfficialPetVisibility(hidden) then return false end
		State.miscHidePets = hidden
		return true
	end


	local function avatarVisualShouldHide(object, character)
		local head = character and character:FindFirstChild("Head")
		return State.miscHeadless and head ~= nil
			and (object == head or object:IsDescendantOf(head))
	end


	local function applyAvatarVisuals()
		local character = LP.Character
		for object in pairs(State.miscAvatarOriginals) do
			if not character or not object:IsDescendantOf(character)
				or not avatarVisualShouldHide(object, character) then
				restoreVisual(State.miscAvatarOriginals, object)
			end
		end
		if character then
			for _, object in ipairs(character:GetDescendants()) do
				if avatarVisualShouldHide(object, character) then
					captureAndHide(State.miscAvatarOriginals, object)
				end
			end
		end
	end


	local function refreshAvatarVisualLoop()
		stopThread("miscAvatarVisuals")
		applyAvatarVisuals()
		if not State.miscHeadless then return end
		startThread("miscAvatarVisuals", function()
			while State.running and State.miscHeadless do
				applyAvatarVisuals()
				task.wait(0.25)
			end
		end)
	end


	State.setMiscHeadless = function(enabled)
		State.miscHeadless = enabled == true
		refreshAvatarVisualLoop()
		return true
	end

	local fpsSetter = type(setfpscap) == "function" and setfpscap or set_fps_cap
	local fpsGetter = type(getfpscap) == "function" and getfpscap or get_fps_cap

	State.setMiscFpsUnlock = function(enabled)
		enabled = enabled == true
		if enabled and type(fpsSetter) ~= "function" then
			miscNotify("Tu executor no ofrece FPS Unlock.")
			return false
		end
		if enabled == State.miscFpsUnlock then return true end
		stopThread("miscFpsUnlock")
		if enabled then
			local ok, cap = false, nil
			if type(fpsGetter) == "function" then ok, cap = pcall(fpsGetter) end
			cap = ok and tonumber(cap) or nil
			State.miscPreviousFpsCap = cap and cap > 0 and cap or 60
			local applied = pcall(fpsSetter, 999)
			if not applied then return false end
			State.miscFpsUnlock = true
			State.miscFpsTarget = 999
			startThread("miscFpsUnlock", function()
				while State.running and State.miscFpsUnlock do
					local readable, current = false, nil
					if type(fpsGetter) == "function" then readable, current = pcall(fpsGetter) end
					current = readable and tonumber(current) or nil
					if not current or current <= 0 or math.abs(current - 999) > 0.5 then
						pcall(fpsSetter, 999)
					end
					task.wait(1)
				end
			end)
		else
			pcall(fpsSetter, tonumber(State.miscPreviousFpsCap) or 60)
			State.miscFpsUnlock = false
			State.miscPreviousFpsCap = nil
			State.miscFpsTarget = nil
		end
		return true
	end


	State.setMiscClickTp = function(enabled)
		enabled = enabled == true
		if enabled and State.miscFreecam and State.setMiscFreecam then
			State.setMiscFreecam(false)
			if State.miscFreecamToggle then State.miscFreecamToggle:Set(false, true) end
		end
		State.miscClickTp = enabled
		return true
	end


	local function performMiscClickTp(inputPosition)
		if typeof(inputPosition) ~= "Vector2"
			or time() - (State.miscLastClickTp or 0) < 0.15 then return false end
		local camera = workspace.CurrentCamera
		local root = getRoot()
		if not camera or not root then return false end
		local ray = camera:ScreenPointToRay(inputPosition.X, inputPosition.Y)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		local ignored = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then ignored[#ignored + 1] = player.Character end
		end
		local boundaryParts = workspace:FindFirstChild("boundaryParts")
		if boundaryParts then ignored[#ignored + 1] = boundaryParts end
		params.FilterDescendantsInstances = ignored
		params.IgnoreWater = false
		local result
		for _ = 1, 16 do
			result = workspace:Raycast(ray.Origin, ray.Direction * 100000, params)
			if not result then break end
			local instance = result.Instance
			local skip = instance:IsA("BasePart") and (
				instance.Transparency >= 0.95
				or (not instance.CanCollide and instance.Transparency >= 0.65)
			)
			local ancestor = instance
			while ancestor and ancestor ~= workspace do
				local lowered = ancestor.Name:lower()
				if lowered:find("boundary", 1, true)
					or lowered:find("invisiblewall", 1, true) then
					skip = true
					break
				end
				ancestor = ancestor.Parent
			end
			if not skip then break end
			ignored[#ignored + 1] = instance
			params.FilterDescendantsInstances = ignored
			result = nil
		end
		if not result then return false end
		State.miscLastClickTp = time()
		local humanoid = LP.Character and LP.Character:FindFirstChildWhichIsA("Humanoid")
		local destination = result.Position + Vector3.new(0,
			(humanoid and humanoid.HipHeight or 2) + root.Size.Y * 0.5 + 0.25, 0)
		local look = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
		if look.Magnitude < 0.01 then look = Vector3.new(0, 0, -1) end
		root.CFrame = CFrame.lookAt(destination, destination + look.Unit)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		return true
	end
	State.performMiscClickTp = performMiscClickTp

	track(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not State.miscClickTp or State.miscFreecam or gameProcessed
			or UserInputService:GetFocusedTextBox() then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		performMiscClickTp(Vector2.new(input.Position.X, input.Position.Y))
	end))


	local function clearFreecamInput()
		State.miscFreecamKeys = {}
		State.miscFreecamMouseLook = false
		State.miscFreecamMoveTouch = nil
		State.miscFreecamLookTouch = nil
		State.miscFreecamTouchMove = Vector2.zero
	end


	local function captureFreecamTransparency(character)
		local originals = setmetatable({}, { __mode = "k" })
		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then
				originals[object] = object.LocalTransparencyModifier
			end
		end
		return originals
	end


	local function keepFreecamCharacterVisible(saved)
		if not saved or not saved.character or not saved.character.Parent then return end
		for object in pairs(saved.transparency or {}) do
			if object.Parent and not avatarVisualShouldHide(object, saved.character)
				and object.LocalTransparencyModifier ~= 0 then
				object.LocalTransparencyModifier = 0
			end
		end
	end


	local function restoreFreecamTransparency(saved)
		for object, transparency in pairs(saved and saved.transparency or {}) do
			if object.Parent then
				object.LocalTransparencyModifier = transparency
			end
		end
		applyAvatarVisuals()
	end


	local function restoreFreecam()
		local saved = State.miscFreecamSaved
		State.miscFreecam = false
		clearFreecamInput()
		if saved and saved.character and saved.character.Parent
			and saved.root and saved.root.Parent then
			pcall(function()
				saved.root.CFrame = saved.lockRootCFrame
				saved.root.AssemblyLinearVelocity = Vector3.zero
				saved.root.AssemblyAngularVelocity = Vector3.zero
				saved.root.Anchored = saved.rootAnchored
			end)
		end
		if saved and saved.humanoid and saved.humanoid.Parent then
			pcall(function()
				saved.humanoid.WalkSpeed = saved.walkSpeed
				saved.humanoid.AutoRotate = saved.autoRotate
				saved.humanoid.JumpPower = saved.jumpPower
				saved.humanoid.JumpHeight = saved.jumpHeight
			end)
		end
		local camera = workspace.CurrentCamera
		if camera and saved then
			local currentHumanoid = LP.Character and LP.Character:FindFirstChildWhichIsA("Humanoid")
			local restoredSubject = currentHumanoid
				or (saved.cameraSubject and saved.cameraSubject.Parent and saved.cameraSubject)
			pcall(function()
				camera.CameraType = Enum.CameraType.Scriptable
				camera.CFrame = saved.cframe
				camera.Focus = saved.focus
				camera.FieldOfView = saved.fov
				if restoredSubject then camera.CameraSubject = restoredSubject end
				camera.CameraType = saved.cameraType == Enum.CameraType.Scriptable
					and Enum.CameraType.Custom or saved.cameraType
			end)
		end
		if saved then
			pcall(function()
				UserInputService.MouseBehavior = saved.mouseBehavior
				UserInputService.MouseIconEnabled = saved.mouseIconEnabled
			end)
			restoreFreecamTransparency(saved)
		end
		State.miscFreecamSaved = nil
	end


	local function syncFreecamOff()
		restoreFreecam()
		if State.miscFreecamToggle and State.miscFreecamToggle:Get() then
			State.miscFreecamToggle:Set(false, true)
		end
	end


	State.setMiscFreecam = function(enabled)
		enabled = enabled == true
		if not enabled then
			if State.miscFreecam or State.miscFreecamSaved then
				syncFreecamOff()
			else
				clearFreecamInput()
			end
			return true
		end
		if State.miscFreecam then return true end
		local camera = workspace.CurrentCamera
		local character = LP.Character
		local root = getRoot()
		local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
		if not camera or not character or not root or not humanoid or humanoid.Health <= 0 then
			miscNotify("Freecam necesita que tu personaje esté vivo.")
			return false
		end
		if State.miscClickTp then
			State.setMiscClickTp(false)
			if State.miscClickTpToggle then State.miscClickTpToggle:Set(false, true) end
		end
		State.miscFreecamSaved = {
			cameraType = camera.CameraType,
			cameraSubject = camera.CameraSubject,
			cframe = camera.CFrame,
			focus = camera.Focus,
			fov = camera.FieldOfView,
			mouseBehavior = UserInputService.MouseBehavior,
			mouseIconEnabled = UserInputService.MouseIconEnabled,
			character = character,
			root = root,
			humanoid = humanoid,
			lockRootCFrame = root.CFrame,
			rootAnchored = root.Anchored,
			walkSpeed = humanoid.WalkSpeed,
			autoRotate = humanoid.AutoRotate,
			jumpPower = humanoid.JumpPower,
			jumpHeight = humanoid.JumpHeight,
			transparency = captureFreecamTransparency(character),
		}
		local started = pcall(function()
			State.miscFreecam = true
			State.miscFreecamPosition = camera.CFrame.Position
			State.miscFreecamPitch, State.miscFreecamYaw = camera.CFrame:ToOrientation()
			State.miscFreecamKeys = {}
			State.miscFreecamTouchMove = Vector2.zero
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			root.Anchored = true
			humanoid.WalkSpeed = 0
			humanoid.AutoRotate = false
			humanoid.Jump = false
			humanoid.JumpPower = 0
			humanoid.JumpHeight = 0
			humanoid:Move(Vector3.zero, false)
			camera.CameraType = Enum.CameraType.Scriptable
			keepFreecamCharacterVisible(State.miscFreecamSaved)
		end)
		if not started then
			syncFreecamOff()
			miscNotify("No se pudo iniciar Freecam; todo fue restaurado.")
			return false
		end
		return true
	end

	track(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not State.miscFreecam then return end
		if input.UserInputType == Enum.UserInputType.Keyboard and not gameProcessed
			and not UserInputService:GetFocusedTextBox() then
			State.miscFreecamKeys[input.KeyCode] = true
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 and not gameProcessed then
			State.miscFreecamMouseLook = true
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		elseif input.UserInputType == Enum.UserInputType.Touch then
			local overHub = false
			local guiOk, guiObjects = pcall(GuiService.GetGuiObjectsAtPosition,
				GuiService, input.Position.X, input.Position.Y)
			if guiOk then
				for _, guiObject in ipairs(guiObjects) do
					local inLegacyHub = guiObject:IsDescendantOf(ScreenGui)
					local inCrefyHub = __FGRoot.CrefyLibrary and __FGRoot.CrefyLibrary.ScreenGui and guiObject:IsDescendantOf(__FGRoot.CrefyLibrary.ScreenGui)
					if inLegacyHub or inCrefyHub then
						overHub = true
						break
					end
				end
			end
			if overHub then return end
			if input.Position.X < viewportSize().X * 0.45 and not State.miscFreecamMoveTouch then
				State.miscFreecamMoveTouch = input
				State.miscFreecamMoveStart = input.Position
			else
				State.miscFreecamLookTouch = input
				State.miscFreecamLookLast = input.Position
			end
		end
	end))
	track(UserInputService.InputChanged:Connect(function(input)
		if not State.miscFreecam then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement and State.miscFreecamMouseLook then
			State.miscFreecamYaw = State.miscFreecamYaw - input.Delta.X * 0.0035
			State.miscFreecamPitch = math.clamp(State.miscFreecamPitch - input.Delta.Y * 0.0035, -1.5, 1.5)
		elseif input.UserInputType == Enum.UserInputType.MouseWheel then
			State.miscFreecamSpeed = math.clamp(State.miscFreecamSpeed + input.Position.Z * 10, 20, 250)
		elseif input == State.miscFreecamMoveTouch then
			local delta = (input.Position - State.miscFreecamMoveStart) / 70
			State.miscFreecamTouchMove = Vector2.new(math.clamp(delta.X, -1, 1), math.clamp(delta.Y, -1, 1))
		elseif input == State.miscFreecamLookTouch then
			local delta = input.Position - State.miscFreecamLookLast
			State.miscFreecamLookLast = input.Position
			State.miscFreecamYaw = State.miscFreecamYaw - delta.X * 0.006
			State.miscFreecamPitch = math.clamp(State.miscFreecamPitch - delta.Y * 0.006, -1.5, 1.5)
		end
	end))
	track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			State.miscFreecamKeys[input.KeyCode] = nil
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			State.miscFreecamMouseLook = false
			if State.miscFreecam then UserInputService.MouseBehavior = Enum.MouseBehavior.Default end
		elseif input == State.miscFreecamMoveTouch then
			State.miscFreecamMoveTouch = nil
			State.miscFreecamTouchMove = Vector2.zero
		elseif input == State.miscFreecamLookTouch then
			State.miscFreecamLookTouch = nil
		end
	end))
	local FREECAM_RENDER_NAME = "FG_FreecamRender"
	pcall(RunService.UnbindFromRenderStep, RunService, FREECAM_RENDER_NAME)
	RunService:BindToRenderStep(FREECAM_RENDER_NAME, Enum.RenderPriority.Camera.Value + 1, function(delta)
		if not State.miscFreecam then return end
		local camera = workspace.CurrentCamera
		local saved = State.miscFreecamSaved
		if not camera or not saved or not saved.character or not saved.character.Parent
			or not saved.root or not saved.root.Parent or not saved.humanoid
			or not saved.humanoid.Parent or saved.humanoid.Health <= 0 then
			syncFreecamOff()
			return
		end
		pcall(function()
			saved.root.Anchored = true
			if (saved.root.Position - saved.lockRootCFrame.Position).Magnitude > 0.05 then
				saved.root.CFrame = saved.lockRootCFrame
			end
			saved.root.AssemblyLinearVelocity = Vector3.zero
			saved.root.AssemblyAngularVelocity = Vector3.zero
			saved.humanoid.WalkSpeed = 0
			saved.humanoid.AutoRotate = false
			saved.humanoid.Jump = false
			saved.humanoid:Move(Vector3.zero, false)
			keepFreecamCharacterVisible(saved)
		end)
		camera.CameraType = Enum.CameraType.Scriptable
		local keys = State.miscFreecamKeys
		local touch = State.miscFreecamTouchMove or Vector2.zero
		local x = (keys[Enum.KeyCode.D] and 1 or 0) - (keys[Enum.KeyCode.A] and 1 or 0) + touch.X
		local y = (keys[Enum.KeyCode.E] and 1 or 0) - (keys[Enum.KeyCode.Q] and 1 or 0)
		local z = (keys[Enum.KeyCode.W] and 1 or 0) - (keys[Enum.KeyCode.S] and 1 or 0) - touch.Y
		local movement = Vector3.new(x, y, z)
		if movement.Magnitude > 1 then movement = movement.Unit end
		local rotation = CFrame.fromOrientation(State.miscFreecamPitch, State.miscFreecamYaw, 0)
		local speed = State.miscFreecamSpeed
			* ((keys[Enum.KeyCode.LeftShift] or keys[Enum.KeyCode.RightShift]) and 2 or 1)
		State.miscFreecamPosition = State.miscFreecamPosition
			+ (rotation.RightVector * movement.X + Vector3.yAxis * movement.Y
				+ rotation.LookVector * movement.Z) * speed * delta
		camera.CFrame = CFrame.new(State.miscFreecamPosition) * rotation
		camera.Focus = CFrame.new(State.miscFreecamPosition + rotation.LookVector * 24)
	end)


	State.miscEmergencyStop = function()
		for _, toggle in ipairs(State.allToggleControllers) do
			if toggle.Get and toggle:Get() then pcall(toggle.Set, toggle, false) end
		end
		pcall(FastFarm.Stop, FastFarm, true)
		State.rebirth.ultimateRunning = false
		State.trade.requestGeneration = (State.trade.requestGeneration or 0) + 1
		State.trade.busy = false
		State.kill.hopNow = false
		State.setMiscClickTp(false)
		State.setMiscFreecam(false)
		State.setMiscHidePets(false)
		State.setMiscHeadless(false)
		for flag in pairs(State.miscVisualFlags) do
			State.setMiscVisualFlag(flag, false)
		end
		if State.setMiscMinimap then State.setMiscMinimap(false) end
		if State.setMiscFullBright then State.setMiscFullBright(false) end
		if State.setMiscNoFog then State.setMiscNoFog(false) end
		if State.setMiscFov then State.setMiscFov(false) end
		if State.setMiscZoom then State.setMiscZoom(false) end
		if State.setMiscHideGameUi then State.setMiscHideGameUi(false) end
		if State.setMiscHidePlayers then State.setMiscHidePlayers(false) end
		local root = getRoot()
		if root then
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
		miscNotify("Emergency Stop: todo quedó detenido.")
		return true
	end

	addCleanup(function()
		pcall(RunService.UnbindFromRenderStep, RunService, FREECAM_RENDER_NAME)
		State.miscClickTp = false
		State.miscFreecam = false
		restoreFreecam()
		restoreVisualStore(State.miscAvatarOriginals)
		if State.miscFpsUnlock then State.setMiscFpsUnlock(false) end
	end)
end

local METERS_PER_STUD = 0.28
local NEARBY_VISUAL_STUDS = 500 / METERS_PER_STUD
local ISLAND_RADIUS_STUDS = 1350
local miscIslandCenters = {}
for _, teleport in ipairs(CONFIG.Teleports) do
	local position = teleport[2]
	if typeof(position) == "Vector3" and not teleport.utility then
		miscIslandCenters[#miscIslandCenters + 1] = {
			name = tostring(teleport[1]),
			position = position,
		}
	end
end


local function nearestMiscIsland(position)
	if typeof(position) ~= "Vector3" then return nil, math.huge end
	local flat = Vector3.new(position.X, 0, position.Z)
	local best, bestDistance = nil, math.huge
	for _, island in ipairs(miscIslandCenters) do
		local center = island.position
		local distance = (flat - Vector3.new(center.X, 0, center.Z)).Magnitude
		if distance < bestDistance then
			best = island
			bestDistance = distance
		end
	end
	return best, bestDistance
end


local function miscVisualEligibility(localRoot, targetRoot)
	if not localRoot or not targetRoot then return false, math.huge, math.huge end
	local studs = (targetRoot.Position - localRoot.Position).Magnitude
	local meters = studs * METERS_PER_STUD
	if studs <= NEARBY_VISUAL_STUDS then
		return true, studs, meters
	end
	local localIsland, localIslandDistance = nearestMiscIsland(localRoot.Position)
	local targetIsland, targetIslandDistance = nearestMiscIsland(targetRoot.Position)
	local sameIsland = localIsland and targetIsland
		and localIsland.name == targetIsland.name
		and localIslandDistance <= ISLAND_RADIUS_STUDS
		and targetIslandDistance <= ISLAND_RADIUS_STUDS
	return sameIsland == true, studs, meters
end
State.miscVisualEligibility = miscVisualEligibility

local TracerWorldFolder = Instance.new("Folder")
TracerWorldFolder.Name = "TracerWorld"
TracerWorldFolder.Parent = workspace
addCleanup(function()
	if TracerWorldFolder and TracerWorldFolder.Parent then TracerWorldFolder:Destroy() end
end)


local function tracerChestPart(character)
	return character and (character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart"))
end


local function createTracerChestAttachment(character, name)
	local chest = tracerChestPart(character)
	if not chest or not chest:IsA("BasePart") then return nil end
	local attachment = Instance.new("Attachment")
	attachment.Name = name
	attachment.Position = chest.Name == "HumanoidRootPart"
		and Vector3.new(0, math.max(1.2, chest.Size.Y * 0.6), 0)
		or Vector3.zero
	attachment.Parent = chest
	return attachment
end


local function ensureTracerSourceAttachment(character)
	local attachment = State.miscTracerSourceAttachment
	local chest = tracerChestPart(character)
	if attachment and attachment.Parent == chest then return attachment end
	if attachment then pcall(attachment.Destroy, attachment) end
	attachment = createTracerChestAttachment(character, "TracerSource")
	State.miscTracerSourceAttachment = attachment
	return attachment
end


local function destroyPlayerVisual(player)
	local objects = State.miscVisualObjects[player]
	if not objects then return end
	for _, key in ipairs({ "billboard", "label", "tracer", "tracerAttachment" }) do
		local object = objects[key]
		if typeof(object) == "Instance" then pcall(object.Destroy, object) end
	end
	for _, highlight in pairs(objects.highlights or {}) do
		if typeof(highlight) == "Instance" then pcall(highlight.Destroy, highlight) end
	end
	State.miscVisualObjects[player] = nil
end


local function clearPlayerVisuals()
	for player in pairs(State.miscVisualObjects) do
		destroyPlayerVisual(player)
	end
	if State.miscTracerSourceAttachment then
		pcall(State.miscTracerSourceAttachment.Destroy, State.miscTracerSourceAttachment)
		State.miscTracerSourceAttachment = nil
	end
end


local function createPlayerVisual(player)
	if player == LP then return nil end
	local objects = State.miscVisualObjects[player]
	if objects then return objects end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESPLabel_" .. player.Name
	billboard.Size = UDim2.fromOffset(310, 94)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 7, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 2200
	billboard.Enabled = false
	billboard.Parent = VisualGui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = C.white
	label.TextStrokeColor3 = C.black
	label.TextStrokeTransparency = 0.08
	label.Font = C.fontBold
	label.TextSize = 12
	label.TextWrapped = true
	label.RichText = true
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.ZIndex = 3
	label:SetAttribute("KeepTextStyle", true)
	label.Parent = billboard

	local tracer = Instance.new("Beam")
	tracer.Name = "Tracer_" .. player.Name
	tracer.Color = ColorSequence.new(Color3.fromRGB(255, 0, 45))
	tracer.Transparency = NumberSequence.new(0)
	tracer.Width0 = 0.1
	tracer.Width1 = 0.1
	tracer.FaceCamera = true
	tracer.LightEmission = 1
	tracer.LightInfluence = 0
	tracer.Segments = 1
	tracer.Enabled = false
	tracer.Parent = TracerWorldFolder

	objects = {
		highlights = {},
		highlightCharacter = nil,
		billboard = billboard,
		label = label,
		tracer = tracer,
		tracerAttachment = nil,
		tracerCharacter = nil,
	}
	State.miscVisualObjects[player] = objects
	return objects
end

local ESP_BODY_PARTS = {
	Head = true,
	Torso = true,
	UpperTorso = true,
	LowerTorso = true,
	LeftArm = true,
	RightArm = true,
	LeftLeg = true,
	RightLeg = true,
	LeftUpperArm = true,
	LeftLowerArm = true,
	LeftHand = true,
	RightUpperArm = true,
	RightLowerArm = true,
	RightHand = true,
	LeftUpperLeg = true,
	LeftLowerLeg = true,
	LeftFoot = true,
	RightUpperLeg = true,
	RightLowerLeg = true,
	RightFoot = true,
}


local function syncBodyHighlights(objects, character, enabled)
	if objects.highlightCharacter ~= character then
		for _, highlight in pairs(objects.highlights) do
			pcall(highlight.Destroy, highlight)
		end
		objects.highlights = {}
		objects.highlightCharacter = character
		if character then
			for _, part in ipairs(character:GetChildren()) do
				if part:IsA("BasePart") and ESP_BODY_PARTS[part.Name] then
					local highlight = Instance.new("Highlight")
					highlight.Name = "ESPBody_" .. part.Name
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.FillColor = Color3.fromRGB(255, 0, 45)
					highlight.FillTransparency = 0.82
					highlight.OutlineColor = Color3.fromRGB(255, 0, 45)
					highlight.OutlineTransparency = 0
					highlight.Adornee = part
					highlight.Enabled = false
					highlight.Parent = VisualGui
					objects.highlights[part] = highlight
				end
			end
		end
	end
	for part, highlight in pairs(objects.highlights) do
		if not part.Parent then
			pcall(highlight.Destroy, highlight)
			objects.highlights[part] = nil
		else
			highlight.Enabled = enabled == true
		end
	end
end


local function anyPlayerVisualEnabled()
	for _, enabled in pairs(State.miscVisualFlags) do
		if enabled then return true end
	end
	return false
end


local function escapeRichText(value)
	return tostring(value or "")
		:gsub("&", "&amp;")
		:gsub("<", "&lt;")
		:gsub(">", "&gt;")
end


local function formatExactMisc(value)
	local text = string.format("%.0f", math.max(0, tonumber(value) or 0))
	local grouped
	repeat
		text, grouped = text:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
	until grouped == 0
	return text
end


local function durabilityColor(ratio)
	if ratio <= 0.25 then return "#FF405B" end
	if ratio <= 0.65 then return "#FFD34D" end
	return "#55DDFF"
end


local function formatMeters(meters)
	if meters < 100 then
		local text = string.format("%.1f", meters):gsub("%.0$", "")
		return text .. " m"
	end
	return tostring(math.floor(meters + 0.5)) .. " m"
end


local function refreshPlayerVisualLoop()
	if not anyPlayerVisualEnabled() then
		stopThread("miscPlayerVisuals")
		clearPlayerVisuals()
		return
	end
	startThread("miscPlayerVisuals", function()
		while State.running and anyPlayerVisualEnabled() do
			local localRoot = getRoot()
			local localCharacter = LP.Character
			local sourceAttachment = State.miscVisualFlags.tracers
				and ensureTracerSourceAttachment(localCharacter) or nil
			local present = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LP then
					present[player] = true
					local objects = createPlayerVisual(player)
					local character = player.Character
					local root = character and character:FindFirstChild("HumanoidRootPart")
					local head = character and character:FindFirstChild("Head")
					local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
					local alive = root and head and humanoid and humanoid.Health > 0
					local eligible, _, meters = miscVisualEligibility(localRoot, root)
					local ready = alive and eligible and not State.miscHidePlayers
					syncBodyHighlights(objects, character, ready and State.miscVisualFlags.boxes)
					objects.billboard.Adornee = ready and head or nil

					local text = {}
					if ready and State.miscVisualFlags.durability then
						local current = math.max(0, tonumber(humanoid.Health) or 0)
						local maximum = math.max(1, tonumber(humanoid.MaxHealth) or 0, current)
						local ratio = math.clamp(current / maximum, 0, 1)
						text[#text + 1] = "<font color=\"#AEB9C2\">Durabilidad </font>"
							.. "<font color=\"" .. durabilityColor(ratio) .. "\"><b>"
							.. formatExactMisc(current) .. "</b></font>"
							.. "<font color=\"#AEB9C2\">/</font>"
							.. "<font color=\"#55DDFF\"><b>" .. formatExactMisc(maximum) .. "</b></font>"
					end
					if ready and State.miscVisualFlags.names then
						text[#text + 1] = "<font color=\"#FF002D\"><b>"
							.. escapeRichText(player.DisplayName) .. "</b></font>"
					end
					if ready and State.miscVisualFlags.distance and meters >= 10 then
						text[#text + 1] = "<font color=\"#E7EDF2\">" .. formatMeters(meters) .. "</font>"
					end
					objects.label.Text = table.concat(text, "\n")
					objects.billboard.Enabled = ready and #text > 0

					if objects.tracerCharacter ~= character
						or not objects.tracerAttachment or not objects.tracerAttachment.Parent then
						if objects.tracerAttachment then pcall(objects.tracerAttachment.Destroy, objects.tracerAttachment) end
						objects.tracerAttachment = createTracerChestAttachment(character, "TracerTarget")
						objects.tracerCharacter = character
					end
					if ready and State.miscVisualFlags.tracers and meters >= 10
						and sourceAttachment and objects.tracerAttachment then
						objects.tracer.Attachment0 = sourceAttachment
						objects.tracer.Attachment1 = objects.tracerAttachment
						objects.tracer.Enabled = true
					else
						objects.tracer.Enabled = false
					end
				end
			end
			for player in pairs(State.miscVisualObjects) do
				if not present[player] then destroyPlayerVisual(player) end
			end
			RunService.RenderStepped:Wait()
		end
		clearPlayerVisuals()
	end)
end


State.setMiscVisualFlag = function(flag, enabled)
	if State.miscVisualFlags[flag] == nil then return false end
	State.miscVisualFlags[flag] = enabled == true
	refreshPlayerVisualLoop()
	return true
end


local function selectedMiscPlayer()
	local player = State.miscTarget and Players:FindFirstChild(State.miscTarget) or nil
	if not player or player == LP or isProtectedMiscTarget(player) then
		return nil
	end
	return player
end
State.selectedMiscPlayer = selectedMiscPlayer


local function miscFollowOffset(root, targetRoot)
	local requested = math.clamp(State.miscFollowDistance, 2, 30)
	local bodyClearance = ((root and root.Size.Z or 2) + (targetRoot and targetRoot.Size.Z or 2)) * 0.5 + 0.35
	return math.max(requested, bodyClearance)
end


State.teleportToMiscPlayer = function()
	local player = selectedMiscPlayer()
	local root = getRoot()
	local targetRoot = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not player or not root or not targetRoot then
		miscNotify("Seleccioná un jugador disponible.")
		return false
	end
	root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, miscFollowOffset(root, targetRoot))
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	return true
end


State.setMiscFollow = function(enabled)
	enabled = enabled == true
	if enabled and not selectedMiscPlayer() then
		miscNotify("Seleccioná un jugador disponible.")
		return false
	end
	if enabled and State.miscOrbitEnabled and State.setMiscOrbit then
		State.setMiscOrbit(false)
		if State.miscOrbitToggle then State.miscOrbitToggle:Set(false, true) end
	end
	State.miscFollowEnabled = enabled
	stopThread("miscFollowPlayer")
	if not enabled then return true end
	startThread("miscFollowPlayer", function()
		while State.running and State.miscFollowEnabled do
			local player = selectedMiscPlayer()
			local root = getRoot()
			local targetRoot = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if not player then
				State.miscFollowEnabled = false
				if State.miscFollowToggle then State.miscFollowToggle:Set(false, true) end
				miscNotify("El objetivo ya no está disponible.")
				break
			elseif root and targetRoot then
				local followCFrame = targetRoot.CFrame
					* CFrame.new(0, 0, miscFollowOffset(root, targetRoot))
				if State.miscFaceTarget then
					followCFrame = CFrame.lookAt(followCFrame.Position, targetRoot.Position)
				end
				root.CFrame = followCFrame
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
			end
			RunService.Heartbeat:Wait()
		end
	end)
	return true
end


State.setMiscFaceTarget = function(enabled)
	enabled = enabled == true
	if enabled and not selectedMiscPlayer() then
		miscNotify("Seleccioná un jugador disponible.")
		return false
	end
	State.miscFaceTarget = enabled
	stopThread("miscFaceTarget")
	if not enabled then return true end
	startThread("miscFaceTarget", function()
		while State.running and State.miscFaceTarget do
			local player = selectedMiscPlayer()
			local root = getRoot()
			local targetRoot = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if not player then
				State.miscFaceTarget = false
				if State.miscFaceToggle then State.miscFaceToggle:Set(false, true) end
				break
			elseif root and targetRoot and not State.miscFollowEnabled and not State.miscOrbitEnabled then
				local targetPosition = Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z)
				if (targetPosition - root.Position).Magnitude > 0.1 then
					root.CFrame = CFrame.lookAt(root.Position, targetPosition)
				end
			end
			RunService.RenderStepped:Wait()
		end
	end)
	return true
end


State.setMiscOrbit = function(enabled)
	enabled = enabled == true
	if enabled and not selectedMiscPlayer() then
		miscNotify("Seleccioná un jugador disponible.")
		return false
	end
	if enabled and State.miscFollowEnabled then
		State.setMiscFollow(false)
		if State.miscFollowToggle then State.miscFollowToggle:Set(false, true) end
	end
	State.miscOrbitEnabled = enabled
	stopThread("miscOrbit")
	if not enabled then return true end
	startThread("miscOrbit", function()
		local angle = 0
		while State.running and State.miscOrbitEnabled do
			local delta = RunService.Heartbeat:Wait()
			local player = selectedMiscPlayer()
			local root = getRoot()
			local targetRoot = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if not player then
				State.miscOrbitEnabled = false
				if State.miscOrbitToggle then State.miscOrbitToggle:Set(false, true) end
				miscNotify("El objetivo ya no está disponible.")
				break
			elseif root and targetRoot then
				angle = angle + math.max(1, State.miscOrbitSpeed) * delta
				local bodyClearance = (root.Size.X + targetRoot.Size.X) * 0.5 + 0.5
				local radius = math.max(math.clamp(State.miscOrbitRadius, 10, 24), bodyClearance)
				local position = targetRoot.Position + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
				root.CFrame = CFrame.lookAt(position, targetRoot.Position)
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
			end
		end
	end)
	return true
end

local MinimapFrame = Instance.new("Frame")
MinimapFrame.Name = "Minimap"
MinimapFrame.AnchorPoint = Vector2.new(1, 0)
MinimapFrame.BackgroundColor3 = C.panel
MinimapFrame.BackgroundTransparency = 0.02
MinimapFrame.BorderSizePixel = 0
MinimapFrame.Visible = false
MinimapFrame.ZIndex = 80
MinimapFrame.Parent = ScreenGui
Instance.new("UICorner", MinimapFrame).CornerRadius = UDim.new(0, 12)
local minimapStroke = Instance.new("UIStroke")
minimapStroke.Color = C.blue
minimapStroke.Thickness = 1.2
minimapStroke.Transparency = 0.28
minimapStroke.Parent = MinimapFrame

local MinimapDismiss = Instance.new("TextButton")
MinimapDismiss.Name = "MinimapDismiss"
MinimapDismiss.Size = UDim2.fromScale(1, 1)
MinimapDismiss.BackgroundTransparency = 1
MinimapDismiss.BorderSizePixel = 0
MinimapDismiss.Text = ""
MinimapDismiss.AutoButtonColor = false
MinimapDismiss.Visible = false
MinimapDismiss.Active = true
MinimapDismiss.ZIndex = 79
MinimapDismiss.Parent = ScreenGui

local MinimapTitle = Instance.new("TextLabel")
MinimapTitle.Name = "Title"
MinimapTitle.Position = UDim2.fromOffset(6, 2)
MinimapTitle.Size = UDim2.new(1, -12, 0, 21)
MinimapTitle.BackgroundTransparency = 1
MinimapTitle.Font = C.fontBold
MinimapTitle.Text = "Minimapa"
MinimapTitle.TextColor3 = C.white
MinimapTitle.TextSize = 11
MinimapTitle.TextTruncate = Enum.TextTruncate.AtEnd
MinimapTitle.ZIndex = 84
MinimapTitle:SetAttribute("KeepTextStyle", true)
MinimapTitle.Parent = MinimapFrame

local MinimapViewport = Instance.new("ViewportFrame")
MinimapViewport.Name = "Map"
MinimapViewport.Position = UDim2.fromOffset(6, 24)
MinimapViewport.Size = UDim2.new(1, -12, 1, -30)
MinimapViewport.BackgroundColor3 = Color3.fromRGB(65, 181, 225)
MinimapViewport.BackgroundTransparency = 0
MinimapViewport.BorderSizePixel = 0
MinimapViewport.Ambient = Color3.fromRGB(195, 205, 218)
MinimapViewport.LightColor = Color3.fromRGB(255, 255, 255)
MinimapViewport.LightDirection = Vector3.new(-0.35, -1, -0.25)
MinimapViewport.ClipsDescendants = true
MinimapViewport.ZIndex = 81
MinimapViewport.Parent = MinimapFrame
Instance.new("UICorner", MinimapViewport).CornerRadius = UDim.new(0, 8)

local MinimapWorld = Instance.new("WorldModel")
MinimapWorld.Name = "HDWorld"
MinimapWorld.Parent = MinimapViewport
local MinimapCamera = Instance.new("Camera")
MinimapCamera.Name = "MapCamera"
MinimapCamera.FieldOfView = 35
pcall(function() MinimapCamera.FieldOfViewMode = Enum.FieldOfViewMode.Vertical end)
MinimapCamera.Parent = MinimapViewport
MinimapViewport.CurrentCamera = MinimapCamera

local MinimapMarkers = Instance.new("Frame")
MinimapMarkers.Name = "Markers"
MinimapMarkers.Size = UDim2.fromScale(1, 1)
MinimapMarkers.BackgroundTransparency = 1
MinimapMarkers.BorderSizePixel = 0
MinimapMarkers.ClipsDescendants = true
MinimapMarkers.ZIndex = 82
MinimapMarkers.Parent = MinimapViewport

local MinimapLocalDot = Instance.new("Frame")
MinimapLocalDot.Name = "You"
MinimapLocalDot.AnchorPoint = Vector2.new(0.5, 0.5)
MinimapLocalDot.Size = UDim2.fromOffset(15, 15)
MinimapLocalDot.BackgroundColor3 = C.cyan
MinimapLocalDot.BackgroundTransparency = 1
MinimapLocalDot.BorderSizePixel = 0
MinimapLocalDot.Rotation = 0
MinimapLocalDot.ZIndex = 86
MinimapLocalDot.Parent = MinimapMarkers
Instance.new("UICorner", MinimapLocalDot).CornerRadius = UDim.new(1, 0)
local localDotStroke = Instance.new("UIStroke")
localDotStroke.Color = C.cyan
localDotStroke.Thickness = 1
localDotStroke.Transparency = 1
localDotStroke.Parent = MinimapLocalDot

local MinimapHeading = Instance.new("TextLabel")
MinimapHeading.Name = "Heading"
MinimapHeading.AnchorPoint = Vector2.new(0.5, 0.5)
MinimapHeading.Position = UDim2.new(0.5, 0, 0, 2)
MinimapHeading.Size = UDim2.fromOffset(18, 18)
MinimapHeading.BackgroundColor3 = Color3.fromRGB(8, 8, 11)
MinimapHeading.BackgroundTransparency = 1
MinimapHeading.BorderSizePixel = 0
MinimapHeading.Text = "▲"
MinimapHeading.TextColor3 = C.cyan
MinimapHeading.TextStrokeColor3 = Color3.fromRGB(6, 10, 20)
MinimapHeading.TextStrokeTransparency = .18
MinimapHeading.Font = C.fontBold
MinimapHeading.TextSize = 14
MinimapHeading:SetAttribute("KeepTextStyle", true)
MinimapHeading:SetAttribute("NoTranslate", true)
MinimapHeading.ZIndex = 87
MinimapHeading.Parent = MinimapMarkers
Instance.new("UICorner", MinimapHeading).CornerRadius = UDim.new(0, 4)

local MinimapExpandHitbox = Instance.new("TextButton")
MinimapExpandHitbox.Name = "Expand"
MinimapExpandHitbox.Size = UDim2.fromScale(1, 1)
MinimapExpandHitbox.BackgroundTransparency = 1
MinimapExpandHitbox.BorderSizePixel = 0
MinimapExpandHitbox.Text = ""
MinimapExpandHitbox.AutoButtonColor = false
MinimapExpandHitbox.Active = true
MinimapExpandHitbox.ZIndex = 90
MinimapExpandHitbox.Parent = MinimapFrame

State.miscMinimapDots = {}
State.miscMinimapBuildKey = nil
State.miscMinimapActiveBounds = nil
State.miscMinimapCloneCount = 0
State.miscMinimapExpanded = false


local function minimapIsMobile()
	local viewport = viewportSize()
	return viewport.X < 760 or (UserInputService.TouchEnabled and viewport.X < 1100)
end


local layoutMiscMinimap
do
    local panel = { size = nil, position = nil, expanded = false, gesture = nil }
    State.miscMinimapPanel = panel

    local MinimapLayer = Instance.new("ScreenGui")
    MinimapLayer.Name = "FG100MinimapLayer"
    MinimapLayer.ResetOnSpawn = false
    MinimapLayer.IgnoreGuiInset = true
    MinimapLayer.DisplayOrder = -100
    MinimapLayer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() MinimapLayer.AutoLocalize = false end)
    MinimapLayer:SetAttribute("Young0x", "0x")
    MinimapLayer:SetAttribute("FG100Minimap", true)
    MinimapLayer.Parent = PlayerGui
    MinimapDismiss.Parent = MinimapLayer
    MinimapFrame.Parent = MinimapLayer

    MinimapFrame.AnchorPoint = Vector2.zero
    MinimapFrame.ClipsDescendants = true
    MinimapFrame.BackgroundTransparency = 0.08
    MinimapDismiss.Active = false
    MinimapDismiss.Visible = false
    MinimapTitle.Position = UDim2.fromOffset(8, 3)
    MinimapTitle.Size = UDim2.new(1, -16, 0, 24)
    MinimapTitle.TextXAlignment = Enum.TextXAlignment.Center
    MinimapViewport.Position = UDim2.fromOffset(6, 30)
    MinimapViewport.Size = UDim2.new(1, -12, 1, -36)
    MinimapViewport.BackgroundColor3 = Color3.fromRGB(38, 151, 202)
    MinimapExpandHitbox.Position = MinimapViewport.Position
    MinimapExpandHitbox.Size = MinimapViewport.Size
    MinimapExpandHitbox:SetAttribute("OutputHandled", true)

    local playerInfo = Instance.new("Frame")
    playerInfo.Name = "PlayerInfo"
    playerInfo.AnchorPoint = Vector2.new(0.5, 0)
    playerInfo.Position = UDim2.new(0.5, 0, 0, 8)
    playerInfo.Size = UDim2.fromOffset(210, 48)
    playerInfo.BackgroundColor3 = Color3.fromRGB(10, 14, 27)
    playerInfo.BackgroundTransparency = 0.08
    playerInfo.BorderSizePixel = 0
    playerInfo.Visible = false
    playerInfo.ZIndex = 93
    playerInfo.Parent = MinimapViewport
    Instance.new("UICorner", playerInfo).CornerRadius = UDim.new(0, 10)
    local playerInfoStroke = Instance.new("UIStroke")
    playerInfoStroke.Color = C.blue
    playerInfoStroke.Thickness = 1
    playerInfoStroke.Transparency = 0.18
    playerInfoStroke.Parent = playerInfo

    local playerAvatar = Instance.new("ImageLabel")
    playerAvatar.Name = "Avatar"
    playerAvatar.Position = UDim2.fromOffset(6, 6)
    playerAvatar.Size = UDim2.fromOffset(36, 36)
    playerAvatar.BackgroundColor3 = Color3.fromRGB(20, 26, 43)
    playerAvatar.BorderSizePixel = 0
    playerAvatar.ZIndex = 94
    playerAvatar.Parent = playerInfo
    Instance.new("UICorner", playerAvatar).CornerRadius = UDim.new(1, 0)

    local playerDisplay = Instance.new("TextLabel")
    playerDisplay.Name = "Display"
    playerDisplay.Position = UDim2.fromOffset(49, 5)
    playerDisplay.Size = UDim2.new(1, -101, 0, 21)
    playerDisplay.BackgroundTransparency = 1
    playerDisplay.BorderSizePixel = 0
    playerDisplay.Font = C.fontBold
    playerDisplay.Text = ""
    playerDisplay.TextColor3 = C.white
    playerDisplay.TextSize = 13
    playerDisplay.TextTruncate = Enum.TextTruncate.AtEnd
    playerDisplay.TextXAlignment = Enum.TextXAlignment.Left
    playerDisplay.ZIndex = 94
    playerDisplay:SetAttribute("KeepTextStyle", true)
    playerDisplay:SetAttribute("NoTranslate", true)
    playerDisplay.Parent = playerInfo

    local playerUsername = Instance.new("TextLabel")
    playerUsername.Name = "Username"
    playerUsername.Position = UDim2.fromOffset(49, 24)
    playerUsername.Size = UDim2.new(1, -101, 0, 18)
    playerUsername.BackgroundTransparency = 1
    playerUsername.BorderSizePixel = 0
    playerUsername.Font = UI_FONT
    playerUsername.Text = ""
    playerUsername.TextColor3 = C.soft
    playerUsername.TextSize = 11
    playerUsername.TextTruncate = Enum.TextTruncate.AtEnd
    playerUsername.TextXAlignment = Enum.TextXAlignment.Left
    playerUsername.ZIndex = 94
    playerUsername:SetAttribute("KeepTextStyle", true)
    playerUsername:SetAttribute("NoTranslate", true)
    playerUsername.Parent = playerInfo

    local playerTeleport = Instance.new("TextButton")
    playerTeleport.Name = "Teleport"
    playerTeleport.AnchorPoint = Vector2.new(1, 0.5)
    playerTeleport.Position = UDim2.new(1, -7, 0.5, 0)
    playerTeleport.Size = UDim2.fromOffset(38, 34)
    playerTeleport.BackgroundColor3 = C.cyan
    playerTeleport.BorderSizePixel = 0
    playerTeleport.Text = "IR"
    playerTeleport.TextColor3 = Color3.fromRGB(5, 10, 19)
    playerTeleport.Font = C.fontBold
    playerTeleport.TextSize = 12
    playerTeleport.AutoButtonColor = false
    playerTeleport.ZIndex = 95
    playerTeleport:SetAttribute("KeepTextStyle", true)
    playerTeleport:SetAttribute("NoTranslate", true)
    playerTeleport:SetAttribute("OutputHandled", true)
    playerTeleport.Parent = playerInfo
    Instance.new("UICorner", playerTeleport).CornerRadius = UDim.new(0, 8)
    track(playerTeleport.Activated:Connect(function()
        local selected = State.miscMinimapSelectedPlayer
        if not selected or selected.Parent ~= Players then
            playerInfo.Visible = false
            return
        end
        if Controller and type(Controller.SetFastFarm) == "function" then Controller.SetFastFarm(nil) end
        State.miscTarget = selected.Name
        State.spyTarget = selected.Name
        if type(State.teleportToMiscPlayer) == "function" then State.teleportToMiscPlayer() end
        playerInfo.Visible = false
    end))
    State.miscMinimapPlayerInfo = playerInfo

    local drag = Instance.new("TextButton")
    drag.Name = "Move"
    drag.Size = UDim2.new(1, 0, 0, 30)
    drag.BackgroundTransparency = 1
    drag.BorderSizePixel = 0
    drag.Text = ""
    drag.AutoButtonColor = false
    drag.Active = true
    drag.ZIndex = 91
    drag:SetAttribute("OutputHandled", true)
    drag.Parent = MinimapFrame

    local grip = Instance.new("Frame")
    grip.Name = "Grip"
    grip.Position = UDim2.new(1, -16, 1, -16)
    grip.Size = UDim2.fromOffset(10, 10)
    grip.BackgroundTransparency = 1
    grip.BorderSizePixel = 0
    grip.ZIndex = 94
    grip.Parent = MinimapFrame
    for index = 1, 3 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(2, 2)
        dot.Position = UDim2.fromOffset(index * 3 - 2, 8 - index * 3)
        dot.BackgroundColor3 = C.soft
        dot.BackgroundTransparency = 0.35
        dot.BorderSizePixel = 0
        dot.ZIndex = 94
        dot.Parent = grip
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    end

    local function limits()
        local view = viewportSize()
        local top, bottom = 8, 8
        local ok, first, last = pcall(GuiService.GetGuiInset, GuiService)
        if ok and typeof(first) == "Vector2" and typeof(last) == "Vector2" then
            top = math.max(top, first.Y + 4)
            bottom = math.max(bottom, last.Y + 4)
        end
        local room = math.max(48, math.min(view.X - 16, view.Y - top - bottom))
        return view, top, bottom, math.min(minimapIsMobile() and 150 or 170, room),
            math.min(minimapIsMobile() and 540 or 720, room)
    end

    local function cancelTween()
        if panel.done then panel.done:Disconnect(); panel.done = nil end
        if panel.tween then panel.tween:Cancel(); panel.tween = nil end
    end

    local function clamp(position, size)
        local view, top, bottom, minimum, maximum = limits()
        size = math.floor(math.clamp(size, minimum, maximum) + 0.5)
        local x = math.clamp(position.X, 8, math.max(8, view.X - size - 8))
        local y = math.clamp(position.Y, top, math.max(top, view.Y - size - bottom))
        return Vector2.new(math.floor(x + 0.5), math.floor(y + 0.5)), size
    end

    local function place(position, size, animated)
        panel.position, panel.size = clamp(position, size)
        local key = tostring(panel.position.X) .. ":" .. tostring(panel.position.Y) .. ":" .. tostring(panel.size)
        if panel.key == key then return end
        panel.key = key
        cancelTween()
        local target = {
            Position = UDim2.fromOffset(panel.position.X, panel.position.Y),
            Size = UDim2.fromOffset(panel.size, panel.size),
        }
        if animated and MinimapFrame.Visible then
            panel.tween = TweenService:Create(MinimapFrame,
                TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), target)
            panel.done = panel.tween.Completed:Connect(function()
                if panel.done then panel.done:Disconnect(); panel.done = nil end
                panel.tween = nil
            end)
            panel.tween:Play()
        else
            MinimapFrame.Position = target.Position
            MinimapFrame.Size = target.Size
        end
    end

    layoutMiscMinimap = function(animated)
        local view = viewportSize()
        if not panel.position then
            panel.size = minimapIsMobile() and 160 or 220
            panel.position = Vector2.new(
                view.X - panel.size - (minimapIsMobile() and 140 or 230),
                view.Y - panel.size - (minimapIsMobile() and 82 or 104)
            )
        end
        local expanded = State.miscMinimapEnabled and State.miscMinimapExpanded == true
        if expanded ~= panel.expanded then
            panel.gesture = nil
            playerInfo.Visible = false
            State.miscMinimapSelectedPlayer = nil
            State.miscMinimapInfoGeneration = (State.miscMinimapInfoGeneration or 0) + 1
            if expanded then
                panel.compact = { position = panel.position, size = panel.size }
                panel.pan = Vector2.zero
                panel.size = panel.large and panel.large.size or math.max(panel.size * 1.4, minimapIsMobile() and 340 or 480)
                panel.position = panel.large and panel.large.position or (view - Vector2.new(panel.size, panel.size)) * 0.5
            else
                panel.large = { position = panel.position, size = panel.size }
                panel.pan = Vector2.zero
                if panel.compact then
                    panel.position, panel.size = panel.compact.position, panel.compact.size
                end
            end
            panel.expanded = expanded
        end
        place(panel.position, panel.size, animated)
        MinimapTitle.TextSize = panel.size >= 260 and 13 or 11
        MinimapDismiss.Active = expanded
        MinimapDismiss.Visible = expanded
    end

    State.setMiscMinimapExpanded = function(expanded)
        State.miscMinimapExpanded = State.miscMinimapEnabled and expanded == true
        layoutMiscMinimap(true)
        return true
    end

    local function begin(input, side)
        if not State.miscMinimapEnabled or not MinimapFrame.Visible or panel.gesture then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local framePosition = MinimapFrame.Position
        panel.position = Vector2.new(framePosition.X.Offset, framePosition.Y.Offset)
        panel.size = MinimapFrame.AbsoluteSize.X
        panel.gesture = {
            input = input, side = side, point = Vector2.new(input.Position.X, input.Position.Y),
            position = panel.position, size = panel.size, pan = panel.pan or Vector2.zero,
            heading = State.miscMinimapHeading, moved = false,
        }
        if side == "pan" then
            playerInfo.Visible = false
            State.miscMinimapInfoGeneration = (State.miscMinimapInfoGeneration or 0) + 1
        end
    end

    local function endGesture(input)
        local gesture = panel.gesture
        if not gesture then return end
        if input and input ~= gesture.input and not (gesture.input.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseButton1) then return end
        panel.gesture = nil
        minimapStroke.Transparency = 0.28
    end

    track(drag.InputBegan:Connect(function(input) begin(input, "move") end))
    for _, side in ipairs({ "w", "e", "n", "s", "nw", "ne", "sw", "se" }) do
        local handle = Instance.new("TextButton")
        handle.Name = side
        handle.BackgroundTransparency = 1
        handle.BorderSizePixel = 0
        handle.Text = ""
        handle.Active = true
        handle.AutoButtonColor = false
        handle.ZIndex = 96
        handle:SetAttribute("OutputHandled", true)
        local edge = UserInputService.TouchEnabled and 12 or 6
        local corner = UserInputService.TouchEnabled and 20 or 13
        if #side == 2 then
            handle.Size = UDim2.fromOffset(corner, corner)
            handle.Position = UDim2.new(side:find("e", 1, true) and 1 or 0,
                side:find("e", 1, true) and -corner or 0,
                side:find("s", 1, true) and 1 or 0, side:find("s", 1, true) and -corner or 0)
        elseif side == "w" or side == "e" then
            handle.Size = UDim2.new(0, edge, 1, -corner * 2)
            handle.Position = UDim2.new(side == "e" and 1 or 0, side == "e" and -edge or 0, 0, corner)
        else
            handle.Size = UDim2.new(1, -corner * 2, 0, edge)
            handle.Position = UDim2.new(0, corner, side == "s" and 1 or 0, side == "s" and -edge or 0)
        end
        handle.Parent = MinimapFrame
        track(handle.InputBegan:Connect(function(input) begin(input, side) end))
    end

    track(UserInputService.InputChanged:Connect(function(input)
        local gesture = panel.gesture
        if not gesture then return end
        if gesture.input.UserInputType == Enum.UserInputType.Touch then
            if input ~= gesture.input then return end
        elseif input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end
        if not MinimapFrame.Visible or not State.miscMinimapEnabled then endGesture(); return end
        local delta = Vector2.new(input.Position.X, input.Position.Y) - gesture.point
        if not gesture.moved and delta.Magnitude < (gesture.side == "pan" and 4 or 6) then return end
        if not gesture.moved then
            gesture.moved = true
            cancelTween()
            panel.key = nil
            minimapStroke.Transparency = 0.08
        end
        if gesture.side == "pan" then
            local bounds = State.miscMinimapViewBounds
            local width = math.max(1, MinimapViewport.AbsoluteSize.X)
            local worldPerPixel = ((bounds and bounds.halfSize or 300) * 2.2) / width
            local heading3 = gesture.heading or Vector3.new(0, 0, -1)
            local forward = Vector2.new(heading3.X, heading3.Z)
            if forward.Magnitude < 0.01 then forward = Vector2.new(0, -1) else forward = forward.Unit end
            local right = Vector2.new(-forward.Y, forward.X)
            panel.pan = gesture.pan - right * (delta.X * worldPerPixel) + forward * (delta.Y * worldPerPixel)
        elseif gesture.side == "move" then
            place(gesture.position + delta, gesture.size, false)
        else
            local west, north = gesture.side:find("w", 1, true), gesture.side:find("n", 1, true)
            local horizontal = west or gesture.side:find("e", 1, true)
            local vertical = north or gesture.side:find("s", 1, true)
            local amount = ((horizontal and (west and -delta.X or delta.X) or 0)
                + (vertical and (north and -delta.Y or delta.Y) or 0)) / (horizontal and vertical and 2 or 1)
            local _, _, _, minimum, maximum = limits()
            local size = math.clamp(gesture.size + amount, minimum, maximum)
            local position = gesture.position + Vector2.new(west and gesture.size - size or 0, north and gesture.size - size or 0)
            place(position, size, false)
        end
    end))
    track(UserInputService.InputEnded:Connect(endGesture))
    track(UserInputService.WindowFocusReleased:Connect(function() endGesture() end))
    track(MinimapFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if not MinimapFrame.Visible then endGesture() end
    end))
    track(MinimapExpandHitbox.Activated:Connect(function()
        if State.miscMinimapEnabled and not State.miscMinimapExpanded then State.setMiscMinimapExpanded(true) end
    end))
    track(MinimapExpandHitbox.InputBegan:Connect(function(input)
        if State.miscMinimapExpanded then begin(input, "pan") end
    end))
    track(MinimapDismiss.Activated:Connect(function()
        if State.miscMinimapExpanded then State.setMiscMinimapExpanded(false) end
    end))
    addCleanup(function()
        panel.gesture = nil
        cancelTween()
        State.miscMinimapPlayerInfo = nil
        State.miscMinimapSelectedPlayer = nil
        if MinimapLayer and MinimapLayer.Parent then MinimapLayer:Destroy() end
    end)
end


local function clearMiscMinimapDots()
	if State.miscMinimapBossMarker then
		pcall(State.miscMinimapBossMarker.Destroy, State.miscMinimapBossMarker)
		State.miscMinimapBossMarker = nil
	end
	for player, dot in pairs(State.miscMinimapDots) do
		if dot then pcall(dot.Destroy, dot) end
		State.miscMinimapDots[player] = nil
	end
end


local function clearMiscMinimapWorld()
	MinimapWorld:ClearAllChildren()
	State.miscMinimapCloneCount = 0
end


local function minimapObjectLooksLikeWater(object)
	if object == workspace.Terrain then return true end
	local current = object
	for _ = 1, 5 do
		if not current or current == workspace then break end
		local name = current.Name:lower()
		if name:find("water", 1, true) or name:find("ocean", 1, true)
			or name:find("sea", 1, true) or name:find("cloud", 1, true) then
			return true
		end
		current = current.Parent
	end
	return false
end


local function isPlayerWorldObject(object)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and object:IsDescendantOf(player.Character) then return true end
	end
	return false
end


local function isBossWorldObject(object)
    for _, boss in ipairs(game:GetService("CollectionService"):GetTagged("BossEventBoss")) do
        if boss and boss.Parent and (object == boss or object:IsDescendantOf(boss)) then return true end
    end
    return false
end

local function resolveMiscMinimapBounds(island)
	local center = island.position
	local flatCenter = Vector3.new(center.X, 0, center.Z)
	local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
	local found = 0
	for _, object in ipairs(workspace:GetDescendants()) do
		if object:IsA("BasePart") and object.Anchored and object.Transparency < 0.95
			and object.Size.X <= 1800 and object.Size.Z <= 1800
			and not minimapObjectLooksLikeWater(object) and not isBossWorldObject(object) then
			local flatPosition = Vector3.new(object.Position.X, 0, object.Position.Z)
			local reach = math.min(math.max(object.Size.X, object.Size.Z) * 0.5, 650)
			if (flatPosition - flatCenter).Magnitude <= ISLAND_RADIUS_STUDS + math.min(reach, 350) then
				local reachX = math.min(math.max(object.Size.X, object.Size.Z) * 0.5, 650)
				local reachZ = reachX
				minX = math.min(minX, object.Position.X - reachX)
				maxX = math.max(maxX, object.Position.X + reachX)
				minZ = math.min(minZ, object.Position.Z - reachZ)
				maxZ = math.max(maxZ, object.Position.Z + reachZ)
				found = found + 1
			end
		end
	end
	if found > 0 then
		local resolvedCenter = Vector3.new((minX + maxX) * 0.5, center.Y, (minZ + maxZ) * 0.5)
		local halfSize = math.clamp(math.max(maxX - minX, maxZ - minZ) * 0.52, 450, 1000)
		return {
			name = island.name,
			center = resolvedCenter,
			halfSize = halfSize,
		}
	end
	return { name = island.name, center = center, halfSize = 800 }
end


local function cloneMinimapPart(object)
	local clone
	pcall(function() clone = object:Clone() end)
	if not clone or not clone:IsA("BasePart") then
		clone = Instance.new("Part")
		clone.Size = object.Size
		clone.CFrame = object.CFrame
		clone.Color = object.Color
		clone.Material = object.Material
		clone.Transparency = object.Transparency
		if object:IsA("Part") then clone.Shape = object.Shape end
	end
	for _, child in ipairs(clone:GetDescendants()) do
		if child:IsA("BasePart") or child:IsA("Script") or child:IsA("LocalScript")
			or child:IsA("ModuleScript") or child:IsA("LayerCollector")
			or child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("Beam")
			or child:IsA("Light") or child:IsA("Sound") or child:IsA("Constraint") then
			child:Destroy()
		end
	end
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.CastShadow = false
	clone.CFrame = object.CFrame
	clone.Parent = MinimapWorld
	return clone
end


local function rebuildMiscMinimap(island)
	local key = island.name .. ":HD"
	if State.miscMinimapBuildKey == key then return end
	State.miscMinimapBuildKey = key
	stopThread("miscMinimapBuild")
	clearMiscMinimapWorld()
	local bounds = resolveMiscMinimapBounds(island)
	State.miscMinimapActiveBounds = bounds
	startThread("miscMinimapBuild", function()
		local parts = {}
		local horizontalLimit = bounds.halfSize * 1.08
		for _, object in ipairs(workspace:GetDescendants()) do
			if object:IsA("BasePart") and object.Anchored and object.Transparency < 0.98
				and object.Size.Magnitude < 4000 and not minimapObjectLooksLikeWater(object)
				and not isPlayerWorldObject(object) and not isBossWorldObject(object) and not object.Name:find("Young0x", 1, true)
				and math.abs(object.Position.X - bounds.center.X) <= horizontalLimit
				and math.abs(object.Position.Z - bounds.center.Z) <= horizontalLimit
				and object.Position.Y >= island.position.Y - 500
				and object.Position.Y <= island.position.Y + 1800 then
				parts[#parts + 1] = object
			end
		end
		table.sort(parts, function(a, b)
			return a.Size.X * a.Size.Z > b.Size.X * b.Size.Z
		end)
		local limit = minimapIsMobile() and 800 or 1500
		for index, object in ipairs(parts) do
			if index > limit or not State.running
				or State.miscMinimapBuildKey ~= key then break end
			if cloneMinimapPart(object) then
				State.miscMinimapCloneCount = State.miscMinimapCloneCount + 1
			end
			if index % 45 == 0 then task.wait() end
		end
	end)
end


local function minimapHeadingVector(localRoot)
	local camera = workspace.CurrentCamera
	local look = camera and camera.CFrame.LookVector or (localRoot and localRoot.CFrame.LookVector)
	local flat = look and Vector3.new(look.X, 0, look.Z) or Vector3.new(0, 0, -1)
	if flat.Magnitude < 0.05 and localRoot then
		local rootLook = localRoot.CFrame.LookVector
		flat = Vector3.new(rootLook.X, 0, rootLook.Z)
	end
	return flat.Magnitude >= 0.05 and flat.Unit or Vector3.new(0, 0, -1)
end


local function updateMinimapCamera(bounds, heading)
    local size = MinimapViewport.AbsoluteSize
    local aspect = math.max(size.X, 1) / math.max(size.Y, 1)
    local span = bounds.halfSize * 1.1 * math.sqrt(2) / math.min(1, aspect)
    local height = span / math.tan(math.rad(MinimapCamera.FieldOfView * 0.5))
    local focus = Vector3.new(bounds.center.X, bounds.center.Y, bounds.center.Z)
    MinimapCamera.CFrame = CFrame.lookAt(focus + Vector3.new(0, height, 0), focus, heading)
    MinimapCamera.Focus = CFrame.new(focus)
end

local function minimapPosition(worldPosition, bounds, heading)
    local size = MinimapViewport.AbsoluteSize
    local width, height = math.max(size.X, 1), math.max(size.Y, 1)
    local point = MinimapCamera.CFrame:PointToObjectSpace(worldPosition)
    local denominator = math.max(0.01, -point.Z) * math.tan(math.rad(MinimapCamera.FieldOfView * 0.5)) * 2
    local marginX, marginY = math.min(0.2, 16 / width), math.min(0.2, 16 / height)
    return UDim2.fromScale(
        math.clamp(0.5 + point.X / (denominator * width / height), marginX, 1 - marginX),
        math.clamp(0.5 - point.Y / denominator, marginY, 1 - marginY)
    )
end

local function showMiscMinimapPlayer(player)
    if not player or player.Parent ~= Players then return end
    local card = State.miscMinimapPlayerInfo
    if not card or not card.Parent then return end
    local avatar = card:FindFirstChild("Avatar")
    local display = card:FindFirstChild("Display")
    local username = card:FindFirstChild("Username")
    if avatar then
        avatar.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", player.UserId)
    end
    if display then display.Text = player.DisplayName end
    if username then username.Text = "@" .. player.Name end
    State.miscMinimapSelectedPlayer = player
    State.miscMinimapInfoGeneration = (State.miscMinimapInfoGeneration or 0) + 1
    local generation = State.miscMinimapInfoGeneration
    card.Visible = true
    task.delay(4, function()
        if State.running and State.miscMinimapInfoGeneration == generation and card.Parent then
            card.Visible = false
        end
    end)
end

local function refreshMiscMinimap()
	layoutMiscMinimap()
	local localRoot = getRoot()
	local island, islandDistance = nil, math.huge
	if localRoot then island, islandDistance = nearestMiscIsland(localRoot.Position) end
	local validIsland = island and islandDistance <= ISLAND_RADIUS_STUDS
	if validIsland then rebuildMiscMinimap(island) end
	if not State.miscMinimapEnabled then
		MinimapFrame.Visible = false
		State.miscMinimapExpanded = false
		MinimapDismiss.Visible = false
		clearMiscMinimapDots()
		return
	end
	MinimapFrame.Visible = true
	MinimapLocalDot.Visible = validIsland == true
	MinimapHeading.Visible = validIsland == true
	MinimapTitle.Text = "Minimapa"
	if not validIsland then
		clearMiscMinimapDots()
		return
	end
	local bounds = State.miscMinimapActiveBounds
	if not bounds or bounds.name ~= island.name then
		bounds = { name = island.name, center = island.position, halfSize = 800 }
	end
	local heading = minimapHeadingVector(localRoot)
    State.miscMinimapHeading = heading
    local visibleRadius = math.clamp(230 + math.max(0, MinimapViewport.AbsoluteSize.X - 150) * 1.05, 230, 650)
    local minimapPanel = State.miscMinimapPanel
    local pan = State.miscMinimapExpanded and minimapPanel and minimapPanel.pan or Vector2.zero
    local desiredCenter = Vector3.new(localRoot.Position.X + pan.X, bounds.center.Y, localRoot.Position.Z + pan.Y)
    local panLimit = math.max(visibleRadius * 0.3, bounds.halfSize - visibleRadius * 0.25)
    desiredCenter = Vector3.new(
        math.clamp(desiredCenter.X, bounds.center.X - panLimit, bounds.center.X + panLimit),
        bounds.center.Y,
        math.clamp(desiredCenter.Z, bounds.center.Z - panLimit, bounds.center.Z + panLimit)
    )
    local viewBounds = {
        name = bounds.name,
        center = desiredCenter,
        halfSize = visibleRadius,
    }
    State.miscMinimapViewBounds = viewBounds
    updateMinimapCamera(viewBounds, heading)
	MinimapLocalDot.Position = minimapPosition(localRoot.Position, viewBounds, heading)
    MinimapHeading.Position = MinimapLocalDot.Position
    do
        local look = localRoot.CFrame.LookVector
        local forward = Vector2.new(heading.X, heading.Z)
        local right = Vector2.new(-forward.Y, forward.X)
        local facing = Vector2.new(look.X, look.Z)
        MinimapHeading.Rotation = facing.Magnitude > 0.01 and math.deg(math.atan2(facing:Dot(right), facing:Dot(forward))) or 0
    end
	do
		local taggedBosses = game:GetService("CollectionService"):GetTagged("BossEventBoss")
		local bossModel = workspace:GetAttribute("BossActive") == true and taggedBosses[1] or nil
		local bossPart = bossModel and (bossModel:FindFirstChild("Boss", true)
			or bossModel:FindFirstChild("Head", true) or bossModel.PrimaryPart)
		if bossPart and bossPart:IsA("BasePart") then
			local marker = State.miscMinimapBossMarker
			if not marker then
				marker = Instance.new("TextLabel")
				marker.Name = "Boss"
				marker.AnchorPoint = Vector2.new(0.5, 0.5)
				marker.BackgroundTransparency = 1
				marker.BorderSizePixel = 0
				marker.Font = C.fontBold
				marker.Text = "◆"
				marker.TextColor3 = Color3.fromRGB(255, 196, 54)
				marker.TextStrokeColor3 = Color3.fromRGB(66, 28, 0)
				marker.TextStrokeTransparency = 0.05
				marker.ZIndex = 88
				marker:SetAttribute("NoTranslate", true)
				marker:SetAttribute("KeepTextStyle", true)
				marker.Parent = MinimapMarkers
				State.miscMinimapBossMarker = marker
			end
			local pulse = (math.sin(time() * 5) + 1) * 0.5
			local side = math.floor(16 + pulse * 3 + 0.5)
			marker.Size = UDim2.fromOffset(side, side)
			marker.TextSize = side
			marker.TextTransparency = 0.02 + (1 - pulse) * 0.08
			marker.Position = minimapPosition(bossPart.Position, viewBounds, heading)
		elseif State.miscMinimapBossMarker then
			pcall(State.miscMinimapBossMarker.Destroy, State.miscMinimapBossMarker)
			State.miscMinimapBossMarker = nil
		end
	end
	local present = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LP and player.Character then
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
			local eligible = root and select(1, miscVisualEligibility(localRoot, root))
			if root and humanoid and humanoid.Health > 0 and eligible then
				present[player] = true
				local dot = State.miscMinimapDots[player]
				if not dot then
					dot = Instance.new("Frame")
					dot.Name = "Player_" .. player.Name
					dot.AnchorPoint = Vector2.new(0.5, 0.5)
					dot.Size = UDim2.fromOffset(7, 7)
					dot.BackgroundColor3 = Color3.fromRGB(255, 0, 45)
					dot.BorderSizePixel = 0
					dot.ZIndex = 85
					dot.Parent = MinimapMarkers
					Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
					local stroke = Instance.new("UIStroke")
					stroke.Color = Color3.fromRGB(35, 0, 7)
					stroke.Thickness = 1
					stroke.Parent = dot
                    local selectPlayer = Instance.new("TextButton")
                    selectPlayer.Name = "Select"
                    selectPlayer.AnchorPoint = Vector2.new(0.5, 0.5)
                    selectPlayer.Position = UDim2.fromScale(0.5, 0.5)
                    selectPlayer.Size = UDim2.fromOffset(28, 28)
                    selectPlayer.BackgroundTransparency = 1
                    selectPlayer.BorderSizePixel = 0
                    selectPlayer.Text = ""
                    selectPlayer.AutoButtonColor = false
                    selectPlayer.Active = true
                    selectPlayer.ZIndex = 92
                    selectPlayer:SetAttribute("OutputHandled", true)
                    selectPlayer.Parent = dot
                    selectPlayer.Activated:Connect(function()
                        showMiscMinimapPlayer(player)
                    end)
					State.miscMinimapDots[player] = dot
				end
				dot.Position = minimapPosition(root.Position, viewBounds, heading)
			end
		end
	end
	for player, dot in pairs(State.miscMinimapDots) do
		if not present[player] then
			pcall(dot.Destroy, dot)
			State.miscMinimapDots[player] = nil
		end
	end
end


State.setMiscMinimap = function(enabled)
	State.miscMinimapEnabled = enabled == true
	if not State.miscMinimapEnabled then State.miscMinimapExpanded = false end
	stopThread("miscMinimap")
	refreshMiscMinimap()
	if not State.miscMinimapEnabled then return true end
	startThread("miscMinimap", function()
		local elapsed = 0
		while State.running and State.miscMinimapEnabled do
			elapsed = elapsed + RunService.RenderStepped:Wait()
			if elapsed >= (minimapIsMobile() and 1 / 20 or 1 / 30) then
				elapsed = 0
				refreshMiscMinimap()
			end
		end
	end)
	return true
end

startThread("miscMinimapCache", function()
	while State.running do
		if not State.miscMinimapEnabled then refreshMiscMinimap() end
		task.wait(1)
	end
end)

local lightingOriginal = {
	ClockTime = Lighting.ClockTime,
	GeographicLatitude = Lighting.GeographicLatitude,
	Brightness = Lighting.Brightness,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	ExposureCompensation = Lighting.ExposureCompensation,
	ColorShift_Top = Lighting.ColorShift_Top,
	ColorShift_Bottom = Lighting.ColorShift_Bottom,
	GlobalShadows = Lighting.GlobalShadows,
}
local lightingController = {
	dayMode = nil,
	fullBright = false,
	fullBrightOriginal = nil,
	restoring = false,
}


local function applyCombinedLighting()
	if lightingController.restoring then return end
	if lightingController.dayMode then
		Lighting.ClockTime = lightingController.dayMode == "Night" and 0 or 14
	end
	if lightingController.fullBright then
		if not lightingController.dayMode then Lighting.ClockTime = 14 end
		Lighting.Brightness = 3
		Lighting.Ambient = Color3.fromRGB(178, 178, 178)
		Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
		Lighting.GlobalShadows = false
	end
end


local function ensureLightingLoop()
	if threads.miscLightingController then return end
	startThread("miscLightingController", function()
		while State.running and (lightingController.dayMode or lightingController.fullBright) do
			applyCombinedLighting()
			task.wait(0.35)
		end
	end)
end


State.setDayNight = function(value)
	lightingController.dayMode = value == "Night" and "Night" or "Day"
	applyCombinedLighting()
	ensureLightingLoop()
	return true
end


State.setMiscFullBright = function(enabled)
	enabled = enabled == true
	if enabled == lightingController.fullBright then
		applyCombinedLighting()
		return true
	end
	if enabled then
		lightingController.fullBrightOriginal = {
			ClockTime = Lighting.ClockTime,
			Brightness = Lighting.Brightness,
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient,
			GlobalShadows = Lighting.GlobalShadows,
		}
		lightingController.fullBright = true
		applyCombinedLighting()
		ensureLightingLoop()
		return true
	end
	lightingController.fullBright = false
	for property, originalValue in pairs(lightingController.fullBrightOriginal or {}) do
		pcall(function() Lighting[property] = originalValue end)
	end
	lightingController.fullBrightOriginal = nil
	applyCombinedLighting()
	if not lightingController.dayMode then stopThread("miscLightingController") end
	return true
end


State.restoreLighting = function()
	lightingController.restoring = true
	lightingController.dayMode = nil
	lightingController.fullBright = false
	lightingController.fullBrightOriginal = nil
	stopThread("miscLightingController")
	for property, originalValue in pairs(lightingOriginal) do
		pcall(function() Lighting[property] = originalValue end)
	end
end
addCleanup(State.restoreLighting)

local noFogOriginal = nil
local atmosphereOriginal = setmetatable({}, { __mode = "k" })

State.setMiscNoFog = function(enabled)
	stopThread("miscNoFog")
	if not enabled then
		if noFogOriginal then
			Lighting.FogStart = noFogOriginal.FogStart
			Lighting.FogEnd = noFogOriginal.FogEnd
			Lighting.FogColor = noFogOriginal.FogColor
			noFogOriginal = nil
		end
		for atmosphere, values in pairs(atmosphereOriginal) do
			if atmosphere and atmosphere.Parent then
				for property, value in pairs(values) do
					pcall(function() atmosphere[property] = value end)
				end
			end
			atmosphereOriginal[atmosphere] = nil
		end
		return true
	end
	noFogOriginal = {
		FogStart = Lighting.FogStart,
		FogEnd = Lighting.FogEnd,
		FogColor = Lighting.FogColor,
	}
	startThread("miscNoFog", function()
		while State.running and noFogOriginal do
			Lighting.FogStart = 100000
			Lighting.FogEnd = 1000000
			for _, object in ipairs(Lighting:GetDescendants()) do
				if object:IsA("Atmosphere") then
					if not atmosphereOriginal[object] then
						atmosphereOriginal[object] = {
							Density = object.Density,
							Offset = object.Offset,
							Haze = object.Haze,
							Glare = object.Glare,
						}
					end
					object.Density = 0
					object.Haze = 0
					object.Glare = 0
				end
			end
			task.wait(0.5)
		end
	end)
	return true
end

local originalFov = nil

local function applyMiscFov(camera)
	if not camera then return end
	local requested = math.clamp(State.miscFov, 50, 150)
	if requested > 120 then
		camera.FieldOfViewMode = Enum.FieldOfViewMode.MaxAxis
		camera.MaxAxisFieldOfView = requested
	else
		camera.FieldOfViewMode = Enum.FieldOfViewMode.Vertical
		camera.FieldOfView = requested
	end
end
State.applyMiscFov = applyMiscFov


State.setMiscFov = function(enabled)
	State.miscFovEnabled = enabled == true
	stopThread("miscFov")
	if not State.miscFovEnabled then
		local camera = workspace.CurrentCamera
		if camera and originalFov then
			camera.FieldOfViewMode = originalFov.Mode
			if originalFov.Mode == Enum.FieldOfViewMode.Diagonal then
				camera.DiagonalFieldOfView = originalFov.Diagonal
			elseif originalFov.Mode == Enum.FieldOfViewMode.MaxAxis then
				camera.MaxAxisFieldOfView = originalFov.MaxAxis
			else
				camera.FieldOfView = originalFov.Vertical
			end
		end
		originalFov = nil
		return true
	end
	local camera = workspace.CurrentCamera
	if camera and not originalFov then
		originalFov = {
			Mode = camera.FieldOfViewMode,
			Vertical = camera.FieldOfView,
			Diagonal = camera.DiagonalFieldOfView,
			MaxAxis = camera.MaxAxisFieldOfView,
		}
	end
	startThread("miscFov", function()
		while State.running and State.miscFovEnabled do
			applyMiscFov(workspace.CurrentCamera)
			RunService.RenderStepped:Wait()
		end
	end)
	return true
end

local originalMaxZoom = nil

State.setMiscZoom = function(enabled)
	State.miscZoomEnabled = enabled == true
	stopThread("miscZoom")
	if not State.miscZoomEnabled then
		if originalMaxZoom then LP.CameraMaxZoomDistance = originalMaxZoom end
		originalMaxZoom = nil
		return true
	end
	originalMaxZoom = originalMaxZoom or LP.CameraMaxZoomDistance
	startThread("miscZoom", function()
		while State.running and State.miscZoomEnabled do
			LP.CameraMaxZoomDistance = 100000
			task.wait(0.4)
		end
	end)
	return true
end

local hiddenPlayerObjects = {}
local hiddenPlayerHumanoids = {}


local function hidePlayerObject(object, property, hiddenValue)
	local values = hiddenPlayerObjects[object]
	if not values then
		values = {}
		hiddenPlayerObjects[object] = values
	end
	if values[property] == nil then
		local ok, original = pcall(function() return object[property] end)
		if ok then values[property] = original end
	end
	pcall(function() object[property] = hiddenValue end)
end


local function restoreHiddenPlayers()
	for object, values in pairs(hiddenPlayerObjects) do
		if object and object.Parent then
			for property, value in pairs(values) do
				pcall(function() object[property] = value end)
			end
		end
		hiddenPlayerObjects[object] = nil
	end
	for humanoid, values in pairs(hiddenPlayerHumanoids) do
		if humanoid and humanoid.Parent then
			pcall(function()
				humanoid.DisplayDistanceType = values.DisplayDistanceType
				humanoid.NameDisplayDistance = values.NameDisplayDistance
				humanoid.HealthDisplayDistance = values.HealthDisplayDistance
			end)
		end
		hiddenPlayerHumanoids[humanoid] = nil
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LP and player.Character then
			for _, object in ipairs(player.Character:GetDescendants()) do
				if object:IsA("BasePart") then
					pcall(function() object.LocalTransparencyModifier = 0 end)
				end
			end
		end
	end
end

State.setMiscHidePlayers = function(enabled)
	State.miscHidePlayers = enabled == true
	stopThread("miscHidePlayers")
	if not State.miscHidePlayers then
		restoreHiddenPlayers()
		refreshPlayerVisualLoop()
		task.defer(function()
			RunService.Heartbeat:Wait()
			if State.running and not State.miscHidePlayers then restoreHiddenPlayers() end
		end)
		return true
	end
	startThread("miscHidePlayers", function()
		while State.running and State.miscHidePlayers do
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LP and player.Character then
					local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
					if humanoid then
						if not hiddenPlayerHumanoids[humanoid] then
							hiddenPlayerHumanoids[humanoid] = {
								DisplayDistanceType = humanoid.DisplayDistanceType,
								NameDisplayDistance = humanoid.NameDisplayDistance,
								HealthDisplayDistance = humanoid.HealthDisplayDistance,
							}
						end
						humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
						humanoid.NameDisplayDistance = 0
						humanoid.HealthDisplayDistance = 0
					end
					for _, object in ipairs(player.Character:GetDescendants()) do
						if object:IsA("BasePart") then
							hidePlayerObject(object, "LocalTransparencyModifier", 1)
						elseif object:IsA("Decal") or object:IsA("Texture") then
							hidePlayerObject(object, "Transparency", 1)
						elseif object:IsA("BillboardGui") or object:IsA("SurfaceGui") then
							hidePlayerObject(object, "Enabled", false)
						elseif object:IsA("ParticleEmitter") or object:IsA("Trail")
							or object:IsA("Beam") or object:IsA("Highlight")
							or object:IsA("Fire") or object:IsA("Smoke")
							or object:IsA("Sparkles") or object:IsA("Light") then
							hidePlayerObject(object, "Enabled", false)
						elseif object:IsA("BoxHandleAdornment") or object:IsA("CylinderHandleAdornment")
							or object:IsA("SphereHandleAdornment") or object:IsA("SelectionBox") then
							hidePlayerObject(object, "Visible", false)
						end
					end
				end
			end
			task.wait(0.25)
		end
	end)
	return true
end

local hiddenGameUi = setmetatable({}, { __mode = "k" })

local function restoreGameUi()
	for object, value in pairs(hiddenGameUi) do
		if object and object.Parent then
			pcall(function() object.Enabled = value end)
		end
		hiddenGameUi[object] = nil
	end
end

State.setMiscHideGameUi = function(enabled)
	State.miscHideGameUi = enabled == true
	stopThread("miscHideGameUi")
	if not State.miscHideGameUi then
		restoreGameUi()
		return true
	end
	startThread("miscHideGameUi", function()
		while State.running and State.miscHideGameUi do
			for _, object in ipairs(PlayerGui:GetChildren()) do
				if object:IsA("LayerCollector") and object ~= ScreenGui then
					if hiddenGameUi[object] == nil then hiddenGameUi[object] = object.Enabled end
					object.Enabled = false
				end
			end
			task.wait(0.4)
		end
	end)
	return true
end

track(Players.PlayerRemoving:Connect(function(player)
	destroyPlayerVisual(player)
	local dot = State.miscMinimapDots and State.miscMinimapDots[player]
	if dot then
		pcall(dot.Destroy, dot)
		State.miscMinimapDots[player] = nil
	end
end))

addCleanup(function()
	State.miscFollowEnabled = false
	State.miscFaceTarget = false
	State.miscOrbitEnabled = false
	State.miscMinimapEnabled = false
	for flag in pairs(State.miscVisualFlags) do State.miscVisualFlags[flag] = false end
	clearPlayerVisuals()
	State.setMiscMinimap(false)
	State.setMiscFullBright(false)
	State.setMiscNoFog(false)
	State.setMiscFov(false)
	State.setMiscZoom(false)
	State.setMiscHidePlayers(false)
	State.setMiscHideGameUi(false)
end)
end
setupExpandedMisc()
end

do
local miscPage = Pages.Misc
local languageHeading=__FGRoot.CrefyUI.uiAddSection(miscPage,"Idiomas: Español · English · Português · العربية")
languageHeading:SetAttribute("NoTranslate",true)
languageHeading.TextSize=11
State.languageSelector = __FGRoot.CrefyUI.uiAddSelector(miscPage, "Idioma", { "Español", "English", "Português", "العربية" }, function(value)
	State.setLanguage(({English="en",["Português"]="pt",["العربية"]="ar"})[value] or "es")
end)
for _,label in ipairs(State.languageSelector.Row:GetDescendants()) do if label:IsA("TextLabel") or label:IsA("TextButton") then label:SetAttribute("NoTranslate",true) end end
__FGRoot.CrefyUI.uiAddSection(miscPage, "🖥️ Rendimiento 🖥️")
__FGRoot.CrefyUI.uiAddToggle(miscPage, "Anti Lag 100%", function(enabled)
	setAntiLag(enabled)
end)
local antiLagStatus = __FGRoot.CrefyUI.uiAddStatusRow(miscPage, "Desactivado")

antiLagStatusUpdater = function(text)
	if antiLagStatus and antiLagStatus.Parent then
		antiLagStatus.Text = text
	end
end
__FGRoot.CrefyUI.uiAddSection(miscPage, "🚀 Fly 🚀")
__FGRoot.CrefyUI.uiAddToggle(miscPage, " Fly ", function(enabled)
	setFly(enabled)
end)
__FGRoot.CrefyUI.uiAddSlider(miscPage, "Velocidad del Fly", 1, 30, State.flyLevel, function(value)
	State.flyLevel = value
end)
__FGRoot.CrefyUI.uiAddSection(miscPage, "🎨 Temas 🎨")
local themeInitializing = true
State.themeSelector = __FGRoot.CrefyUI.uiAddSelector(miscPage, "Tema visual", { "Galaxia", "Violeta", "Carmesí", "Esmeralda" }, function(value)
	State.applyTheme(tostring(value or "Galaxia"), themeInitializing)
end)
State.themeSelector:SetValue(State.themeName)
themeInitializing = false
__FGRoot.CrefyUI.uiAddSection(miscPage, "👁️ ESP y tracers 👁️")
State.miscVisualToggles = {
	boxes = __FGRoot.CrefyUI.uiAddToggle(miscPage, "ESP", function(enabled)
		return State.setMiscVisualFlag("boxes", enabled)
	end),
	names = __FGRoot.CrefyUI.uiAddToggle(miscPage, "ESP: Nombres", function(enabled)
		return State.setMiscVisualFlag("names", enabled)
	end),
	tracers = __FGRoot.CrefyUI.uiAddToggle(miscPage, "Tracers", function(enabled)
		return State.setMiscVisualFlag("tracers", enabled)
	end),
	distance = __FGRoot.CrefyUI.uiAddToggle(miscPage, "ESP: Distancia", function(enabled)
		return State.setMiscVisualFlag("distance", enabled)
	end),
	durability = __FGRoot.CrefyUI.uiAddToggle(miscPage, "ESP: Durabilidad", function(enabled)
		return State.setMiscVisualFlag("durability", enabled)
	end),
}
__FGRoot.CrefyUI.uiAddSection(miscPage, "🧭 Jugadores 🧭")
State.miscPlayerSelector = __FGRoot.CrefyUI.uiAddSelector(miscPage, "Objetivo", State.miscTargetOptions(), function(value)
	State.miscTarget = type(value) == "table" and value.name or value
	State.spyTarget = State.miscTarget
end, nil, "Sin jugadores disponibles")
if #State.miscTargetOptions() > 0 then
	State.miscPlayerSelector:SetIndex(1)
end
__FGRoot.CrefyUI.uiAddButton(miscPage, "Teletransportarse al jugador", function()
	State.teleportToMiscPlayer()
end)
State.miscFollowToggle = __FGRoot.CrefyUI.uiAddToggle(miscPage, "Tracker: Seguir jugador", function(enabled)
	return State.setMiscFollow(enabled)
end)
__FGRoot.CrefyUI.uiAddSlider(miscPage, "Distancia seguimiento", 2, 30, State.miscFollowDistance, function(value)
	State.miscFollowDistance = value
end)
State.miscOrbitToggle = __FGRoot.CrefyUI.uiAddToggle(miscPage, "Orbitar alrededor del objetivo", function(enabled)
	return State.setMiscOrbit(enabled)
end)
__FGRoot.CrefyUI.uiAddSlider(miscPage, "Radio de órbita", 10, 24, State.miscOrbitRadius, function(value)
	State.miscOrbitRadius = value
end)
__FGRoot.CrefyUI.uiAddSlider(miscPage, "Velocidad de órbita", 1, 15, State.miscOrbitSpeed, function(value)
	State.miscOrbitSpeed = value
end)
State.spyToggle = __FGRoot.CrefyUI.uiAddToggle(miscPage, "Spy: Mirar jugador", function(enabled)
	local target = State.selectedMiscPlayer()
	if enabled and not target then return false end
	if target then State.spyTarget = target.Name end
	setSpy(enabled)
	return true
end)
__FGRoot.CrefyUI.uiAddToggle(miscPage, "Ocultar jugadores", function(enabled)
	return State.setMiscHidePlayers(enabled)
end)
__FGRoot.CrefyUI.uiAddToggle(miscPage, "Minimapa", function(enabled)
	return State.setMiscMinimap(enabled)
end)
__FGRoot.CrefyUI.uiAddSection(miscPage, "🌎 Mundo y cámara 🌎")
__FGRoot.CrefyUI.uiAddToggle(miscPage, "FullBright", function(enabled)
	return State.setMiscFullBright(enabled)
end)
__FGRoot.CrefyUI.uiAddToggle(miscPage, "Quitar niebla", function(enabled)
	return State.setMiscNoFog(enabled)
end)
State.miscFovToggle = __FGRoot.CrefyUI.uiAddToggle(miscPage, "FOV personalizado", function(enabled)
	return State.setMiscFov(enabled)
end)
__FGRoot.CrefyUI.uiAddSlider(miscPage, "Campo de visión", 50, 150, State.miscFov, function(value)
	State.miscFov = value
	if State.miscFovEnabled and workspace.CurrentCamera then
		State.applyMiscFov(workspace.CurrentCamera)
	end
end)
__FGRoot.CrefyUI.uiAddToggle(miscPage, "Zoom extendido", function(enabled)
	return State.setMiscZoom(enabled)
end)
State.miscFreecamToggle = __FGRoot.CrefyUI.uiAddToggle(miscPage, "Freecam", function(enabled)
	return State.setMiscFreecam(enabled)
end)
__FGRoot.CrefyUI.uiAddSlider(miscPage, "Velocidad Freecam", 20, 250, State.miscFreecamSpeed, function(value)
	State.miscFreecamSpeed = value
end)
__FGRoot.CrefyUI.uiAddToggle(miscPage, "Ocultar interfaz del juego", function(enabled)
	return State.setMiscHideGameUi(enabled)
end)
__FGRoot.CrefyUI.uiAddSection(miscPage, "🧰 Utilidades 🧰")
State.miscClickTpToggle = __FGRoot.CrefyUI.uiAddToggle(miscPage, "Click TP", function(enabled)
	return State.setMiscClickTp(enabled)
end)
State.miscHidePetsToggle = __FGRoot.CrefyUI.uiAddToggle(miscPage, "Ocultar pets", function(enabled)
	return State.setMiscHidePets(enabled)
end)
State.miscFpsUnlockToggle = __FGRoot.CrefyUI.uiAddToggle(miscPage, "FPS Unlock", function(enabled)
	return State.setMiscFpsUnlock(enabled)
end)
State.miscHeadlessToggle = __FGRoot.CrefyUI.uiAddToggle(miscPage, "Headless", function(enabled)
	return State.setMiscHeadless(enabled)
end)
__FGRoot.CrefyUI.uiAddSection(miscPage, "⚙️ Misc ⚙️")
if UserInputService.TouchEnabled and viewportSize().X < 1100 then
	local mobileKeybind = Instance.new("TextLabel")
	mobileKeybind.LayoutOrder = nextOrder(miscPage)
	mobileKeybind.Text = "Keybind:"
	mobileKeybind.TextColor3 = C.white
	mobileKeybind.Font = UI_FONT
	mobileKeybind.TextSize = 12
	mobileKeybind.TextXAlignment = Enum.TextXAlignment.Left
	mobileKeybind.Parent = miscPage
	__FGRoot.CrefyUI.styleRow(mobileKeybind, 38)
	local keyPadding = Instance.new("UIPadding")
	keyPadding.PaddingLeft = UDim.new(0, 20)
	keyPadding.Parent = mobileKeybind
elseif UserInputService.KeyboardEnabled then
	__FGRoot.minimizeKeyButton = __FGRoot.CrefyUI.uiAddButton(miscPage, __FGRoot.minimizeKeyText(), function(button)
		__FGRoot.waitingForMinimizeKey = true
		button.Text = "Elegí una tecla"
	end)
	__FGRoot.minimizeKeyButton.TextXAlignment = Enum.TextXAlignment.Left
	local keyPadding = Instance.new("UIPadding")
	keyPadding.PaddingLeft = UDim.new(0, 20)
	keyPadding.Parent = __FGRoot.minimizeKeyButton
end
__FGRoot.CrefyUI.uiAddToggle(miscPage, "🛡️ Anti Crash 🛡️", function(enabled)
	AntiCrash.set(enabled)
end)
local pingReducerToggle = __FGRoot.CrefyUI.uiAddToggle(miscPage, "📶 Ping Reducer 📶", function(enabled)
	FastFarm:SetPingReducer(enabled)
	return true
end)
pingReducerToggle:Set(FastFarm.pingReducer, true)
FastFarm.PingReducerToggle = pingReducerToggle
__FGRoot.CrefyUI.uiAddToggle(miscPage, "🌀 Spin 🌀", function(enabled)
	setSpin(enabled)
end)
__FGRoot.CrefyUI.uiAddToggle(miscPage, "⚡ Fast Speed ⚡", function(enabled)
	setFastSpeed(enabled)
end)
__FGRoot.CrefyUI.uiAddToggle(miscPage, "🌊 Walk on Water 🌊", function(enabled)
	startThread("walkWater", function()
		setWalkWater(enabled)
	end)
end)
__FGRoot.CrefyUI.uiAddToggle(miscPage, "👻 No Clip 👻", function(enabled)
	setNoclip(enabled)
end)
__FGRoot.CrefyUI.uiAddToggle(miscPage, "🛡️ Anti Knockback 🛡️", function(enabled)
	State.setAntiKnockback(enabled)
end)
local autoSpinToggle = __FGRoot.CrefyUI.uiAddToggle(miscPage, "🎡 Auto Spin Fortune Wheel 🎡", function(enabled)
	return setAutoSpinWheel(enabled)
end)
local autoClaimToggle = __FGRoot.CrefyUI.uiAddToggle(miscPage, "🎁 Auto Claim Chests 🎁", function(enabled)
	return setAutoClaimChests(enabled)
end)
State.autoSpinToggle = autoSpinToggle
State.autoClaimToggle = autoClaimToggle

State.refreshMiscAvailability = function()
	local spinLocked = (State.rewardsBusy and State.rewardsBusy ~= "wheel") or ((State.fortuneSpinAmount() or 0) <= 0 and not State.autoSpinWheel)
	if autoSpinToggle:IsLocked() ~= spinLocked then
		autoSpinToggle:SetLocked(spinLocked)
	end
	local chestLocked = (State.rewardsBusy and State.rewardsBusy ~= "chests") or (#State.readyChestDefinitions() == 0 and not State.chestClaimBusy)
	if autoClaimToggle:IsLocked() ~= chestLocked then
		autoClaimToggle:SetLocked(chestLocked)
	end
end
State.refreshMiscAvailability()
startThread("miscAvailability", function()
	while State.running and miscPage.Parent do
		State.refreshMiscAvailability()
		task.wait(0.5)
	end
end)
__FGRoot.CrefyUI.uiAddToggle(miscPage, "🚫 Remove AD Portal 🚫", function(enabled)
	setRemovePortals(enabled)
end)
local emergencyButton = __FGRoot.CrefyUI.uiAddButton(miscPage, "EMERGENCY STOP", function()
	State.miscEmergencyStop()
end, C.row, Color3.fromRGB(62, 17, 25))
emergencyButton.TextColor3 = Color3.fromRGB(255, 70, 90)
__FGRoot.CrefyUI.uiAddButton(miscPage, "❌ Cerrar Script ❌", function()
	if shutdown then
		shutdown(false)
	end
end, C.row, Color3.fromRGB(72, 34, 52))
end


__FGRoot.refreshPlayerSelectors = function()
	local options = playerOptions()
	local previousKillTarget = State.kill.target
	if State.giftTargetSelector then
		State.giftTargetSelector:SetValues(options, true)
	end
	if State.spySelector then
		State.spySelector:SetValues(options, true)
	end
	if State.miscPlayerSelector then
		local miscOptions = State.miscTargetOptions()
		State.miscPlayerSelector:SetValues(miscOptions, true)
		if #miscOptions > 0 and not State.selectedMiscPlayer() then
			State.miscPlayerSelector:SetIndex(1)
		end
	end
	if State.statsPlayerSelector and State.statsTargetOptions then
		State.statsPlayerSelector:SetValues(State.statsTargetOptions(), true)
		if not State.statsSelectedPlayer() then
			State.statsPlayerSelector:SetIndex(1)
		end
	end
	if State.killSelector then
		State.killSelector:SetValues(options, true)
	end
	if State.spy and State.spyTarget and not Players:FindFirstChild(State.spyTarget) then
		setSpy(false)
	end
	if State.miscFollowEnabled and not State.selectedMiscPlayer() then
		State.setMiscFollow(false)
		if State.miscFollowToggle then State.miscFollowToggle:Set(false, true) end
	end
	if State.miscFaceTarget and not State.selectedMiscPlayer() then
		State.setMiscFaceTarget(false)
		if State.miscFaceToggle then State.miscFaceToggle:Set(false, true) end
	end
	if State.miscOrbitEnabled and not State.selectedMiscPlayer() then
		State.setMiscOrbit(false)
		if State.miscOrbitToggle then State.miscOrbitToggle:Set(false, true) end
	end
	if State.kill.targetMode and previousKillTarget and not Players:FindFirstChild(previousKillTarget) then
		State.setTargetKill(false)
		if State.killTargetToggle then
			State.killTargetToggle:Set(false, true)
		end
	end
end
track(Players.PlayerAdded:Connect(function(player)
	State.clearKillFriend(player)
	__FGRoot.refreshPlayerSelectors()
end))
track(Players.PlayerRemoving:Connect(function(player)
	State.clearKillFriend(player)
	task.defer(__FGRoot.refreshPlayerSelectors)
end))

-- Native Crefy replacement for the old floating mobile fly buttons.
-- The previous buttons lived inside the legacy ScreenGui, which is intentionally
-- disabled after migration. Crefy toggles keep vertical fly controls accessible.
do
    local mobileFlyUpControl
    local mobileFlyDownControl
    __FGRoot.CrefyUI.uiAddSection(Pages.Misc, "Mobile Fly Controls")
    mobileFlyUpControl = __FGRoot.CrefyUI.uiAddToggle(Pages.Misc, "Fly Up (Mobile)", function(enabled)
        if enabled and not State.fly then return false end
        mobileFlyUp = enabled == true
        if mobileFlyUp and mobileFlyDown then
            mobileFlyDown = false
            if mobileFlyDownControl then mobileFlyDownControl:Set(false, true) end
        end
        return true
    end)
    mobileFlyDownControl = __FGRoot.CrefyUI.uiAddToggle(Pages.Misc, "Fly Down (Mobile)", function(enabled)
        if enabled and not State.fly then return false end
        mobileFlyDown = enabled == true
        if mobileFlyDown and mobileFlyUp then
            mobileFlyUp = false
            if mobileFlyUpControl then mobileFlyUpControl:Set(false, true) end
        end
        return true
    end)
    State.mobileFlyUpToggle = mobileFlyUpControl
    State.mobileFlyDownToggle = mobileFlyDownControl
end

track(RunService.Heartbeat:Connect(function()
	if not State.running then
		return
	end
	local character = getCharacter()
	local humanoid = getHumanoid()
	local root = getRoot()

	if State.fastSpeed and humanoid then
		humanoid.WalkSpeed = 1000
	end

	if State.fly and humanoid and root and workspace.CurrentCamera then
		if not flyGyro or flyGyro.Parent ~= root then
			clearFlyMovers()
			flyGyro = Instance.new("BodyGyro")
			flyGyro.Name = "FlyGyro"
			flyGyro.P = 12000
			flyGyro.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
			flyGyro.Parent = root
			flyVelocity = Instance.new("BodyVelocity")
			flyVelocity.Name = "FlyVelocity"
			flyVelocity.P = 15000
			flyVelocity.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
			flyVelocity.Parent = root
		end
		local camera = workspace.CurrentCamera
		local baseSpeed = 160 + (math.clamp(State.flyLevel, 1, 30) - 1) * 24
		local combinedSpeed = baseSpeed + (State.fastSpeed and 1000 or 0)
		local direction = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			direction = direction + camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			direction = direction - camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			direction = direction + camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			direction = direction - camera.CFrame.RightVector
		end
		if direction.Magnitude < 0.05 and humanoid.MoveDirection.Magnitude > 0.05 then
			direction = humanoid.MoveDirection
		end
		if direction.Magnitude > 0 then
			direction = direction.Unit
		end
		local vertical = 0
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) or humanoid.Jump or mobileFlyUp then
			vertical = 1
		elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or mobileFlyDown then
			vertical = -1
		end
		humanoid.PlatformStand = true
		flyGyro.MaxTorque = State.spin
			and Vector3.new(9000000000, 0, 9000000000)
			or Vector3.new(9000000000, 9000000000, 9000000000)
		flyGyro.CFrame = camera.CFrame
		local verticalSpeed = vertical * combinedSpeed
		local targetVelocity = direction * combinedSpeed + Vector3.new(0, verticalSpeed, 0)
		flyVelocity.Velocity = targetVelocity
	elseif not State.fly and (flyGyro or flyVelocity) then
		clearFlyMovers()
	end

	if (State.antiKnockback or State.noclip) and root and humanoid and not State.fly then
		if not State.antiKnockbackVelocity or State.antiKnockbackVelocity.Parent ~= root then
			State.clearAntiKnockback()
			State.antiKnockbackVelocity = Instance.new("BodyVelocity")
			State.antiKnockbackVelocity.Name = "AntiKnockback"
			State.antiKnockbackVelocity.P = 25000
			State.antiKnockbackVelocity.MaxForce = Vector3.new(1000000000, 0, 1000000000)
			State.antiKnockbackVelocity.Parent = root
		end
		local movement = humanoid.MoveDirection
		local speed = State.fastSpeed and 1000 or math.max(humanoid.WalkSpeed, 16)
		State.antiKnockbackVelocity.Velocity = Vector3.new(movement.X * speed, 0, movement.Z * speed)
		root.AssemblyLinearVelocity = Vector3.new(
			movement.X * speed,
			math.clamp(root.AssemblyLinearVelocity.Y, -90, 90),
			movement.Z * speed
		)
		root.AssemblyAngularVelocity = Vector3.zero
	elseif State.antiKnockbackVelocity then
		State.clearAntiKnockback()
	end

	if State.noclip and not State.machine and character and root then
		if not State.fly then
			if humanoid then
				humanoid.Sit = false
				local humanoidState = humanoid:GetState()
				if humanoidState == Enum.HumanoidStateType.Seated
					or humanoidState == Enum.HumanoidStateType.Climbing then
					humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
				end
			end
			local floorOffset = (humanoid and humanoid.HipHeight or 2) + root.Size.Y * 0.5 + 0.05
			local floorY = (State.noclipBeachSurfaceY or 0) + floorOffset
			if math.abs(root.Position.Y - floorY) > 0.01 or math.abs(root.AssemblyLinearVelocity.Y) > 0.05 then
				root.CFrame = CFrame.new(root.Position.X, floorY, root.Position.Z) * root.CFrame.Rotation
				root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
			end
		end
	end

	if State.spin and root and humanoid then
		if not spinVelocity or spinVelocity.Parent ~= root then
			clearSpin()
			spinHumanoid = humanoid
			spinAutoRotate = humanoid.AutoRotate
			humanoid.AutoRotate = false
			spinVelocity = Instance.new("BodyAngularVelocity")
			spinVelocity.Name = "Spin"
			spinVelocity.AngularVelocity = Vector3.new(0, 7, 0)
			spinVelocity.MaxTorque = Vector3.new(0, 9000000000, 0)
			spinVelocity.P = 6000
			spinVelocity.Parent = root
		end
	elseif spinVelocity then
		clearSpin()
	end

	if State.spy and workspace.CurrentCamera then
		local target = State.spyTarget and Players:FindFirstChild(State.spyTarget)
		local targetHumanoid = target and target.Character and target.Character:FindFirstChildWhichIsA("Humanoid")
		if targetHumanoid then
			workspace.CurrentCamera.CameraSubject = targetHumanoid
		end
	end
end))

__FGRoot.restoreAfterDeath = function(character)
	local snapshot = State.deathResumeSnapshot
	if not snapshot or snapshot.character == character then return end
	State.deathResumeSnapshot = nil
	task.spawn(function()
		local humanoid = character and (character:FindFirstChildOfClass("Humanoid")
			or character:WaitForChild("Humanoid", 10))
		if not humanoid or not humanoid:IsA("Humanoid") then
			if State.deathResumeSnapshot == nil then State.deathResumeSnapshot = snapshot end
			return
		end
		local deadline = os.clock() + 10
		while State.running and LP.Character == character and humanoid.Health <= 0 and os.clock() < deadline do
			task.wait(0.1)
		end
		if not State.running or LP.Character ~= character or humanoid.Health <= 0 then
			if State.deathResumeSnapshot == nil then State.deathResumeSnapshot = snapshot end
			return
		end
		task.wait(0.35)
		if not State.running or LP.Character ~= character or humanoid.Health <= 0 then return end

		local exclusiveMode = snapshot.afk ~= nil or snapshot.fastMode ~= nil or snapshot.momentumMode ~= nil
		local farmPages = {
			["AFK 24/7"] = true, ["Fast Farm"] = true, ["Full Train"] = true,
			["Auto Farm"] = true, ["Pet Momentum"] = true, ["Fast Glitch 100%"] = true,
			["Rebirths"] = true,
		}
		local restored = 0
		for _, saved in ipairs(snapshot.controls or {}) do
			if not State.running or LP.Character ~= character or humanoid.Health <= 0 then break end
			local pageName = tostring(saved.key):match("^([^|]+)|") or ""
			local control = State.profileControls and State.profileControls[saved.key]
			local restartSafe = __FGRoot.CrefyUI.RESPAWN_RESTART_SAFE_PAGES[pageName] == true
			if control and control.ProfileKind == "toggle" and restartSafe
				and not (exclusiveMode and farmPages[pageName]) then
				local okGet, enabled = pcall(control.Get, control)
				if okGet then
					if enabled ~= true then
						local okSet, result = pcall(control.Set, control, true)
						if okSet and result ~= false then restored = restored + 1 end
					else
						-- Re-run the feature initializer for toggles that stayed checked
					-- but whose character-bound worker may have exited on death.
						if type(control.Restart) == "function" then
							local okRestart, result = pcall(control.Restart, control)
						if okRestart and result ~= false then restored = restored + 1 end
						end
					end
				end
			end
			task.wait(0.025)
		end

		-- Exclusive modes get resumed last to prevent ordinary controls from
		-- accidentally cancelling the AFK/Fast Farm/Pet Momentum controller.
		if State.running and LP.Character == character and humanoid.Health > 0 then
			if snapshot.afk and type(State.afkResume) == "function" then
				local ok, result = pcall(State.afkResume, snapshot.afk)
				if ok and result ~= false then restored = restored + 1 end
			elseif snapshot.fastMode and FastFarm then
				pcall(function() FastFarm:Stop(false, true) end)
				if Controller and type(Controller.SetFastFarm) == "function" then
					local ok, result = pcall(Controller.SetFastFarm, snapshot.fastMode)
					if ok and result ~= false then restored = restored + 1 end
				end
			elseif snapshot.momentumMode and FastFarm and FastFarm.PetMomentum then
				local momentum = FastFarm.PetMomentum
				if momentum.mode then pcall(momentum.Stop, momentum, false) end
				local ok, result = pcall(momentum.Start, momentum)
				if ok and result ~= false then restored = restored + 1 end
			end
		end
		if restored > 0 then
			State.pushOutput("SYSTEM", "Respawn recovery restored/restarted " .. tostring(restored) .. " controls")
		end
	end)
end

track(LP.CharacterAdded:Connect(function(character)
	task.wait(0.6)
	if not State.running then return end
	if State.fastSpeed then
		applyWalkSpeed()
	end
	if State.fastPunch and not State.deathResumeSnapshot then
		setFastPunch(true)
	end
	if not State.spy then
		resetCamera()
	end
	__FGRoot.restoreAfterDeath(character)
end))

do
	local bound = setmetatable({}, { __mode = "k" })
	local names = {
		PreviousArea = "Versículo anterior",
		CenterArea = "Siguiente versículo",
		NextArea = "Siguiente versículo",
		TabOverflow = "Mover pestañas a la derecha",
		TabUnderflow = "Mover pestañas a la izquierda",
	}
	local function bindOutputClick(object)
		if bound[object] or not object:IsA("GuiButton") or object:GetAttribute("OutputHandled") then return end
		bound[object] = true
		track(object.Activated:Connect(function()
			if not State.running then return end
			local label = object:GetAttribute("OutputLabel")
			if type(label) ~= "string" or label == "" then
				label = object:IsA("TextButton") and object.Text:gsub("^%s+", ""):gsub("%s+$", "") or ""
			end
			if label == "" then label = names[object.Name] or object.Name end
			State.pushOutput("CLICK", label)
		end))
	end
	for _, object in ipairs(getHubUIDescendants()) do bindOutputClick(object) end
	track(ScreenGui.DescendantAdded:Connect(function(object) task.defer(bindOutputClick, object) end))	
	for _, page in pairs(Pages) do
		for _, object in ipairs(page:GetDescendants()) do bindOutputClick(object) end
		track(page.DescendantAdded:Connect(function(object) task.defer(bindOutputClick, object) end))
	end
end

for _, object in ipairs(getHubUIDescendants()) do
	styleHubText(object)
end

__FGRoot.UiMotion = {
	minimized = false,
	dragging = false,
	dragTarget = nil,
	dragStart = nil,
	startPosition = nil,
	dragDistance = 0,
	expandedPosition = AnimationRoot.Position,
	bubblePosition = MiniBubble.Position,
	transitionId = 0,
	entranceRootTween = nil,
	entranceFrameTweens = {},
	minimizeTweens = {},
	shuttingDown = false,
}


__FGRoot.floatMiniIcon = function(position)
	if not MiniIcon or not MiniIcon.Parent then return end
	MiniIcon.Parent = ScreenGui
	MiniIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	MiniIcon.Position = position
	MiniIcon.Size = UDim2.fromOffset(
		math.max(1, MiniBubble.AbsoluteSize.X),
		math.max(1, MiniBubble.AbsoluteSize.Y)
	)
	MiniIcon.ZIndex = 210
end


__FGRoot.dockMiniIcon = function()
	if not MiniIcon then return end
	MiniIcon.Parent = MiniBubble
	MiniIcon.AnchorPoint = Vector2.zero
	MiniIcon.Position = UDim2.fromOffset(0, 0)
	MiniIcon.Size = UDim2.new(1, 0, 0.58, 0)
	MiniIcon.ZIndex = 101
end


__FGRoot.cancelTweenList = function(list)
	for index, tween in ipairs(list) do
		pcall(tween.Cancel, tween)
		list[index] = nil
	end
end


__FGRoot.moveHub = function(position)
	AnimationRoot.Position = position
end


__FGRoot.moveBubble = function(position)
	MiniBubble.Position = position
end


__FGRoot.clampUiPosition = function(centerX, centerY, width, height)
	local viewport = viewportSize()
	local halfWidth = math.min(width * 0.5, viewport.X * 0.5)
	local halfHeight = math.min(height * 0.5, viewport.Y * 0.5)
	local maxX = math.max(halfWidth, viewport.X - halfWidth)
	local maxY = math.max(halfHeight, viewport.Y - halfHeight)
	centerX = math.clamp(centerX, halfWidth, maxX)
	centerY = math.clamp(centerY, halfHeight, maxY)
	return UDim2.fromOffset(math.floor(centerX + 0.5), math.floor(centerY + 0.5))
end


__FGRoot.freeBubblePosition = function(startPosition, delta)
	return UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end


State.rememberMiniBubblePosition = function()
	if MiniBubble and MiniBubble.Parent then
		__FGRoot.UiMotion.bubblePosition = MiniBubble.Position
	end
end


__FGRoot.setMinimized = function() end

do
	local actionService = game:GetService("ContextActionService")
	pcall(actionService.UnbindAction, actionService, "FG_Freecam")
	actionService:BindActionAtPriority("FG_Freecam", function(_, inputState)
		if inputState == Enum.UserInputState.Begin and not __FGRoot.waitingForMinimizeKey
			and not UserInputService:GetFocusedTextBox() and State.miscFreecamToggle then
			State.miscFreecamToggle:Set(not State.miscFreecamToggle:Get())
		end
		if __FGRoot.waitingForMinimizeKey or UserInputService:GetFocusedTextBox() then
			return Enum.ContextActionResult.Pass
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value + 100, Enum.KeyCode.C)
	addCleanup(function()
		pcall(actionService.UnbindAction, actionService, "FG_Freecam")
	end)
end

track(UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not UserInputService.KeyboardEnabled or input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end
	if __FGRoot.waitingForMinimizeKey then
		__FGRoot.waitingForMinimizeKey = false
		if input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then
			__FGRoot.minimizeKey = input.KeyCode
			State.saveMinimizeKey(__FGRoot.minimizeKey)
		end
		if __FGRoot.minimizeKeyButton and __FGRoot.minimizeKeyButton.Parent then
			__FGRoot.minimizeKeyButton.Text = __FGRoot.minimizeKeyText()
		end
		return
	end
	if gameProcessed or UserInputService:GetFocusedTextBox() then
		return
	end
	if input.KeyCode == __FGRoot.minimizeKey then
		__FGRoot.setMinimized(not __FGRoot.UiMotion.minimized)
	end
end))

track(DragHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		__FGRoot.UiMotion.dragging = true
		__FGRoot.UiMotion.dragTarget = "main"
		__FGRoot.UiMotion.dragStart = input.Position
		__FGRoot.UiMotion.startPosition = AnimationRoot.Position
		__FGRoot.UiMotion.dragDistance = 0
	end
end))

track(MiniDragHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		__FGRoot.UiMotion.dragging = true
		__FGRoot.UiMotion.dragTarget = "bubble"
		__FGRoot.UiMotion.dragStart = input.Position
		__FGRoot.UiMotion.startPosition = MiniBubble.Position
		__FGRoot.UiMotion.dragDistance = 0
	end
end))

track(UserInputService.InputChanged:Connect(function(input)
	if not __FGRoot.UiMotion.dragging or not __FGRoot.UiMotion.dragStart or not __FGRoot.UiMotion.startPosition then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local delta = input.Position - __FGRoot.UiMotion.dragStart
	__FGRoot.UiMotion.dragDistance = delta.Magnitude
	if __FGRoot.UiMotion.dragTarget == "bubble" then
		__FGRoot.moveBubble(__FGRoot.freeBubblePosition(__FGRoot.UiMotion.startPosition, delta))
	else
		local viewport = viewportSize()
		local centerX = viewport.X * __FGRoot.UiMotion.startPosition.X.Scale + __FGRoot.UiMotion.startPosition.X.Offset + delta.X
		local centerY = viewport.Y * __FGRoot.UiMotion.startPosition.Y.Scale + __FGRoot.UiMotion.startPosition.Y.Offset + delta.Y
		__FGRoot.moveHub(__FGRoot.clampUiPosition(centerX, centerY, hubWidth, hubHeight))
	end
end))

track(UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if __FGRoot.UiMotion.dragging and __FGRoot.UiMotion.dragDistance >= 8 then
			if __FGRoot.UiMotion.dragTarget == "bubble" then
				State.rememberMiniBubblePosition()
			else
				__FGRoot.UiMotion.expandedPosition = AnimationRoot.Position
			end
		end
		__FGRoot.UiMotion.dragging = false
		__FGRoot.UiMotion.dragTarget = nil
		__FGRoot.UiMotion.dragStart = nil
		__FGRoot.UiMotion.startPosition = nil
	end
end))

track(DragHandle.Activated:Connect(function()
	if __FGRoot.UiMotion.dragDistance < 8 then
		__FGRoot.setMinimized(true)
	end
end))

track(MiniDragHandle.Activated:Connect(function()
	if __FGRoot.UiMotion.dragDistance < 8 then
		__FGRoot.setMinimized(not __FGRoot.UiMotion.minimized)
	end
end))


shutdown = function(immediate, guiDestroying)
	if __FGRoot.UiMotion.shuttingDown then
		return
	end
	__FGRoot.UiMotion.shuttingDown = true
	State.shuttingDown = true
	if __FGRoot.UiMotion.entranceRootTween then
		pcall(__FGRoot.UiMotion.entranceRootTween.Cancel, __FGRoot.UiMotion.entranceRootTween)
		__FGRoot.UiMotion.entranceRootTween = nil
	end
	__FGRoot.cancelTweenList(__FGRoot.UiMotion.entranceFrameTweens)
	__FGRoot.cancelTweenList(__FGRoot.UiMotion.minimizeTweens)
	State.running = false
	for _, callback in ipairs(cleanupActions) do
		pcall(callback)
	end
	disconnectAll()
	if Env.Young0xFG100 == Controller then
		Env.Young0xFG100 = nil
	end
	if immediate or __FGRoot.CrefyEnabled then
		if not guiDestroying and ScreenGui and ScreenGui.Parent then
			ScreenGui:Destroy()
		end
		if VisualGui and VisualGui.Parent then pcall(function() VisualGui:Destroy() end) end
		return
	end
	local info = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	local currentWidth = MainFrame.AbsoluteSize.X
	local currentHeight = MainFrame.AbsoluteSize.Y
	local closeWidth = math.floor(currentWidth * 0.9)
	local closeHeight = math.floor(currentHeight * 0.9)
	local currentPosition = AnimationRoot.Position
	local closePosition = UDim2.new(
		currentPosition.X.Scale,
		currentPosition.X.Offset,
		currentPosition.Y.Scale,
		currentPosition.Y.Offset + 14
	)
	TweenService:Create(AnimationRoot, info, {
		Position = closePosition,
	}):Play()
	TweenService:Create(MainFrame, info, {
		Size = UDim2.fromOffset(math.max(1, closeWidth - 2), math.max(1, closeHeight - 2)),
	}):Play()
	TweenService:Create(Border, info, {
		Size = UDim2.fromOffset(closeWidth, closeHeight),
	}):Play()
	TweenService:Create(Shadow, info, {
		Size = UDim2.fromOffset(closeWidth, closeHeight),
	}):Play()
	task.delay(0.32, function()
		if ScreenGui and ScreenGui.Parent then
			ScreenGui:Destroy()
		end
	end)
end

Controller.Shutdown = shutdown
if State.shutdownRequested then
    task.defer(function()
        if type(shutdown) == "function" then shutdown(false) end
    end)
end
track(ScreenGui.Destroying:Connect(function()
	if State.running then shutdown(true, true) end
end))
Controller.State = State
Controller.Config = CONFIG
Controller.Pages = Pages
Controller.Tabs = TabButtons
Controller.ShowTab = refreshTabs
State.refreshResponsiveLayout = function()
	local newWidth, newHeight = getHubSize()
	if newWidth == hubWidth and newHeight == hubHeight then return false end
	hubWidth, hubHeight = newWidth, newHeight
	AnimationRoot.Size = UDim2.fromOffset(hubWidth, hubHeight)
	MainFrame.Size = UDim2.fromOffset(math.max(1, hubWidth - 2), math.max(1, hubHeight - 2))
	Border.Size = UDim2.fromOffset(hubWidth, hubHeight)
	Shadow.Size = UDim2.fromOffset(hubWidth, hubHeight)
	if State.motionShell and not State.motionShell.Visible then State.motionShell.Size = UDim2.fromOffset(hubWidth, hubHeight) end
	local viewport = viewportSize()
	local centerX = viewport.X * AnimationRoot.Position.X.Scale + AnimationRoot.Position.X.Offset
	local centerY = viewport.Y * AnimationRoot.Position.Y.Scale + AnimationRoot.Position.Y.Offset
	__FGRoot.UiMotion.expandedPosition = __FGRoot.clampUiPosition(centerX, centerY, hubWidth, hubHeight)
	if not __FGRoot.UiMotion.minimized then AnimationRoot.Position = __FGRoot.UiMotion.expandedPosition end
	local bubbleX = viewport.X * MiniBubble.Position.X.Scale + MiniBubble.Position.X.Offset
	local bubbleY = viewport.Y * MiniBubble.Position.Y.Scale + MiniBubble.Position.Y.Offset
	MiniBubble.Position = __FGRoot.clampUiPosition(bubbleX, bubbleY, MiniBubble.AbsoluteSize.X, MiniBubble.AbsoluteSize.Y)
	__FGRoot.UiMotion.bubblePosition = MiniBubble.Position
	return true
end
State.responsiveSerial = 0
State.queueResponsiveLayout = function()
	State.responsiveSerial = State.responsiveSerial + 1
	local serial = State.responsiveSerial
	task.delay(0.12, function() if State.running and serial == State.responsiveSerial then State.refreshResponsiveLayout() end end)
end
State.bindResponsiveCamera = function()
	if State.responsiveCameraConnection then pcall(State.responsiveCameraConnection.Disconnect, State.responsiveCameraConnection) end
	local camera = workspace.CurrentCamera
	if camera then State.responsiveCameraConnection = track(camera:GetPropertyChangedSignal("ViewportSize"):Connect(State.queueResponsiveLayout)) end
	State.queueResponsiveLayout()
end
State.bindResponsiveCamera()
track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(State.bindResponsiveCamera))
Controller.SetMinimized = __FGRoot.setMinimized
Controller.SetHideFrames = setHideFrames
Controller.SetFastPunch = setFastPunch
Controller.SetAutoWinBrawl = State.setAutoWinBrawl
Controller.SetAutoSpinWheel = setAutoSpinWheel
Controller.SetAutoClaimChests = setAutoClaimChests
Controller.SetWalkWater = setWalkWater
Controller.SetNoclip = setNoclip
Controller.SetAntiCrash = AntiCrash.set
Controller.EatProteinEgg = State.eatProteinEgg
Controller.GetOfficialCodes = State.currentOfficialCodes
Controller.FastFarm = FastFarm
Controller.PetMomentum = FastFarm.PetMomentum
Controller.Inventory = State.Inventory
Controller.Profiles = State.Profiles
Controller.BossFarm = State.bossFarm
Controller.SetTab = function(name)
	if not Pages[name] and not __FGRoot.CrefyTabs[name] then return false end
	refreshTabs(name)
	return true
end
Controller.GetCurrentTab = function() return State.currentTab end
Controller.ScreenGui = ScreenGui
Controller.MainFrame = MainFrame
Controller.MiniBubble = MiniBubble
State.miniFpsFrames = 0
State.miniFpsSampleAt = os.clock()
State.liveFps = 0
track(RunService.RenderStepped:Connect(function() State.miniFpsFrames = State.miniFpsFrames + 1 end))
startThread("miniHudStats", function()
	while State.running and MiniBubble.Parent do
		local now = os.clock()
		local elapsed = math.max(0.001, now - State.miniFpsSampleAt)
		State.liveFps = math.floor(State.miniFpsFrames / elapsed + 0.5)
		State.miniFpsFrames = 0
		State.miniFpsSampleAt = now
		local ping = math.floor(getPing() + 0.5)
		State.livePing = ping
		if State.MiniStats and State.MiniStats.Parent then if State.updateMiniStats then State.updateMiniStats(State.liveFps,ping) else State.MiniStats.Text=tostring(State.liveFps).." FPS  •  "..(ping>0 and tostring(ping) or "--").." ms" end end
        if State.MiniIdentity then State.MiniIdentity.Text=LP.DisplayName.." · "..#Players:GetPlayers().."/"..Players.MaxPlayers end
		task.wait(0.5)
	end
end)
Controller.SetDayNight = State.setDayNight
Controller.SetFullBright = State.setMiscFullBright
Controller.RestoreLighting = State.restoreLighting
Controller.ApplyVisualStat = State.applyVisualStat
Controller.RestoreVisualStats = State.restoreVisualStats
Controller.GetFunctionalStatValue = State.getFunctionalStatValue
Controller.SetLanguage = State.setLanguage
Controller.GetLanguage = State.getLanguage
Controller.AntiAfkPulse = State.antiAfkPulse

Controller.GetRuntimeMetrics = function()
	local connected = 0
	for _, connection in ipairs(connections) do
		local ok, active = pcall(function() return connection.Connected end)
		if ok and active then connected = connected + 1 end
	end
	local activeThreads = 0
	for _, thread in pairs(threads) do
		if thread then activeThreads = activeThreads + 1 end
	end
	local antiAfkConnected = false
	pcall(function() antiAfkConnected = State.antiAfkConnection.Connected end)
	return {
		trackedConnections = #connections,
		connectedConnections = connected,
		activeThreads = activeThreads,
		memoryKb = collectgarbage("count"),
		uiDescendants = ScreenGui and #ScreenGui:GetDescendants() or 0,
		language = State.language,
		languageBindings = State.languageBindingCount or 0,
		antiAfkConnected = antiAfkConnected,
		antiAfkPulses = State.antiAfkPulses or 0,
	}
end

Controller.SetPingReducer = function(enabled)
	local active = FastFarm:SetPingReducer(enabled)
	if FastFarm.PingReducerToggle then
		FastFarm.PingReducerToggle:Set(active, true)
	end
	return active
end

Controller.SetFastFarm = function(mode)
	if mode == "strength" then
		FastFarm.warningAccepted = true
		if FastFarm.RebirthToggle then FastFarm.RebirthToggle:Set(false, true) end
		local started = FastFarm:Start("strength")
		if FastFarm.StrengthToggle then FastFarm.StrengthToggle:Set(started == true, true) end
		return started
	elseif mode == "rebirth" then
		FastFarm.warningAccepted = true
		if FastFarm.StrengthToggle then FastFarm.StrengthToggle:Set(false, true) end
		local started = FastFarm:Start("rebirth")
		if FastFarm.RebirthToggle then FastFarm.RebirthToggle:Set(started == true, true) end
		return started
	end
	if FastFarm.RebirthToggle then FastFarm.RebirthToggle:Set(false, true) end
	if FastFarm.StrengthToggle then FastFarm.StrengthToggle:Set(false, true) end
	FastFarm:Stop(true)
	return true
end
Controller.MinimizeKeyName = __FGRoot.minimizeKeyName
Controller.UnlockAutoLift = unlockNativeAutoLift
pageSetup = function()
do
    local scale = AnimationRoot:FindFirstChild("MotionScale")
    local veil, art = State.motionVeil, State.motionVeilArt
    local shell=State.motionShell
    local shellArt=State.motionShellArt
    local shellCorner=State.motionShellCorner
    local shellArtCorner=State.motionShellArtCorner
    local shellStroke=State.motionShellStroke
    if art then art.Size=UDim2.fromScale(1,1); art.Position=UDim2.new() end
    local function restoreSavedNavigation()
        local savedTab=__FGRoot.UiMotion.savedTab
        if not savedTab or not Pages[savedTab] then return end
        local page=Pages[savedTab]
        local pagePosition=__FGRoot.UiMotion.savedTabScroll or Vector2.zero
        State.pageScrollPositions=State.pageScrollPositions or {}
        State.pageScrollPositions[savedTab]=pagePosition
        State.currentTab=savedTab
        for name,other in pairs(Pages) do
            if name==savedTab then
                if other.Parent==__FGRoot.MotionPageCache then other.Parent=__FGRoot.MotionPageHomes[other] or Content end
                other.Position=UDim2.fromOffset(0,0)
                other.Visible=true
            else
                other.Visible=false
                if other.Parent~=__FGRoot.MotionPageCache then
                    __FGRoot.MotionPageHomes[other]=other.Parent
                    other.Parent=__FGRoot.MotionPageCache
                end
            end
        end
        page.CanvasPosition=pagePosition
        TabBar.CanvasPosition=__FGRoot.UiMotion.savedTabBarScroll or TabBar.CanvasPosition
    end
    local function shellStyle(position,size,radius,transparency)
        if not shell then return end
        shell.Position=position
        shell.Size=size
        shell.BackgroundTransparency=transparency
        if shellArt then shellArt.ImageTransparency=.46 end
        if shellCorner then shellCorner.CornerRadius=UDim.new(0,radius) end
        if shellArtCorner then shellArtCorner.CornerRadius=UDim.new(0,radius) end
        if shellStroke then shellStroke.Thickness=1.4; shellStroke.Transparency=.14 end
    end
    __FGRoot.setMinimized=function(value)
        value=value==true
        if __FGRoot.CrefyEnabled and __FGRoot.CrefyWindow then
            if __FGRoot.CrefyWindow.SetMinimized then
                pcall(function() __FGRoot.CrefyWindow:SetMinimized(value) end)
            end
            __FGRoot.UiMotion.minimized=value
            State.uiMoving=false
            return
        end
        if __FGRoot.UiMotion.minimized==value or __FGRoot.UiMotion.shuttingDown then return end
        if value then
            __FGRoot.UiMotion.savedTab=State.currentTab
            __FGRoot.UiMotion.savedTabScroll=State.currentTab and Pages[State.currentTab] and Pages[State.currentTab].CanvasPosition or Vector2.zero
            __FGRoot.UiMotion.savedTabBarScroll=TabBar.CanvasPosition
            __FGRoot.UiMotion.savedExpandedPosition=AnimationRoot.Position
            __FGRoot.UiMotion.expandedPosition=AnimationRoot.Position
        elseif __FGRoot.UiMotion.savedTab and Pages[__FGRoot.UiMotion.savedTab] then
            restoreSavedNavigation()
        end
        if not __FGRoot.UiMotion.minimized and not State.uiMoving then __FGRoot.UiMotion.expandedPosition=AnimationRoot.Position end
        __FGRoot.UiMotion.transitionId=__FGRoot.UiMotion.transitionId+1
        local id=__FGRoot.UiMotion.transitionId
        __FGRoot.UiMotion.minimized=value
        State.uiMoving=true
        if __FGRoot.UiMotion.entranceRootTween then __FGRoot.UiMotion.entranceRootTween:Cancel() end
        __FGRoot.cancelTweenList(__FGRoot.UiMotion.entranceFrameTweens)
        __FGRoot.cancelTweenList(__FGRoot.UiMotion.minimizeTweens)
        local shellWasVisible=shell and shell.Visible==true
        local origin=ScreenGui.AbsolutePosition
        local center=MiniBubble.AbsolutePosition+MiniBubble.AbsoluteSize*.5-origin
        local bubbleTarget=UDim2.fromOffset(center.X,center.Y)
        local bubbleSize=UDim2.fromOffset(math.max(20,MiniBubble.AbsoluteSize.X-8),math.max(20,MiniBubble.AbsoluteSize.Y-8))
        local bubbleRadius=math.max(10,math.floor((MiniBubble.AbsoluteSize.Y-8)*.5))
        local expandedTarget=__FGRoot.UiMotion.savedExpandedPosition or __FGRoot.UiMotion.expandedPosition
        local expandedSize=UDim2.fromOffset(hubWidth,hubHeight)
        AnimationRoot.Position=expandedTarget
        scale.Scale=1
        MainFrame.Visible=true; Border.Visible=true; Shadow.Visible=true; TabBar.Visible=true; Content.Visible=true
        MiniBubble.Visible=true; MiniBubble.ZIndex=200
        if value then
            State.playUiWhoosh(false)
            if shellWasVisible then
                AnimationRoot.Visible=false
                if veil then veil.Visible=false end
                local reverseInfo=TweenInfo.new(.22,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)
                local reverse=TweenService:Create(shell,reverseInfo,{Position=bubbleTarget,Size=bubbleSize,BackgroundTransparency=.08})
                __FGRoot.UiMotion.minimizeTweens={reverse}
                reverse:Play()
                if shellCorner then local t=TweenService:Create(shellCorner,reverseInfo,{CornerRadius=UDim.new(0,bubbleRadius)}); table.insert(__FGRoot.UiMotion.minimizeTweens,t); t:Play() end
                if shellArtCorner then local t=TweenService:Create(shellArtCorner,reverseInfo,{CornerRadius=UDim.new(0,bubbleRadius)}); table.insert(__FGRoot.UiMotion.minimizeTweens,t); t:Play() end
                local reversed; reversed=reverse.Completed:Connect(function(state)
                    reversed:Disconnect()
                    if state~=Enum.PlaybackState.Completed or id~=__FGRoot.UiMotion.transitionId then return end
                    shell.Visible=false
                    State.uiMoving=false
                end)
                State.rememberMiniBubblePosition()
                return
            end
            AnimationRoot.Visible=true
            if shell then shell.Visible=false end
            if veil then veil.Visible=true; veil.BackgroundTransparency=1 end
            if art then art.ImageTransparency=1 end
            local coverInfo=TweenInfo.new(.065,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
            local cover=veil and TweenService:Create(veil,coverInfo,{BackgroundTransparency=.02})
            local coverArt=art and TweenService:Create(art,coverInfo,{ImageTransparency=.50})
            __FGRoot.UiMotion.minimizeTweens={cover,coverArt}
            if cover then cover:Play() end
            if coverArt then coverArt:Play() end
            task.delay(.06,function()
                if id~=__FGRoot.UiMotion.transitionId or not __FGRoot.UiMotion.minimized or not State.running then return end
                if not shell then AnimationRoot.Visible=false; State.uiMoving=false; return end
                shellStyle(expandedTarget,expandedSize,12,.02)
                shell.Visible=true
                AnimationRoot.Visible=false
                if veil then veil.Visible=false end
                local info=TweenInfo.new(.27,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)
                local movement=TweenService:Create(shell,info,{Position=bubbleTarget,Size=bubbleSize,BackgroundTransparency=.08})
                __FGRoot.UiMotion.minimizeTweens={movement}
                movement:Play()
                if shellCorner then local t=TweenService:Create(shellCorner,info,{CornerRadius=UDim.new(0,bubbleRadius)}); table.insert(__FGRoot.UiMotion.minimizeTweens,t); t:Play() end
                if shellArtCorner then local t=TweenService:Create(shellArtCorner,info,{CornerRadius=UDim.new(0,bubbleRadius)}); table.insert(__FGRoot.UiMotion.minimizeTweens,t); t:Play() end
                local done; done=movement.Completed:Connect(function(state)
                    done:Disconnect()
                    if state~=Enum.PlaybackState.Completed or id~=__FGRoot.UiMotion.transitionId then return end
                    shell.Visible=false
                    State.uiMoving=false
                end)
            end)
        else
            State.playUiWhoosh(true)
            restoreSavedNavigation()
            if AnimationRoot.Visible and not shellWasVisible then
                if shell then shell.Visible=false end
                if veil then
                    veil.Visible=true
                    local reveal=TweenService:Create(veil,TweenInfo.new(.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=1})
                    __FGRoot.UiMotion.minimizeTweens={reveal}
                    reveal:Play()
                end
                if art then
                    local revealArt=TweenService:Create(art,TweenInfo.new(.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageTransparency=1})
                    table.insert(__FGRoot.UiMotion.minimizeTweens,revealArt)
                    revealArt:Play()
                end
                task.delay(.085,function()
                    if id~=__FGRoot.UiMotion.transitionId or __FGRoot.UiMotion.minimized then return end
                    if veil then veil.Visible=false end
                    State.uiMoving=false
                end)
                State.rememberMiniBubblePosition()
                return
            end
            AnimationRoot.Visible=false
            if veil then veil.Visible=true; veil.BackgroundTransparency=.02 end
            if art then art.ImageTransparency=.50 end
            if not shell then
                AnimationRoot.Visible=true
                if veil then veil.Visible=false end
                State.uiMoving=false
                return
            end
            if not shell.Visible then shellStyle(bubbleTarget,bubbleSize,bubbleRadius,.08) end
            shell.Visible=true
            local info=TweenInfo.new(.30,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
            local movement=TweenService:Create(shell,info,{Position=expandedTarget,Size=expandedSize,BackgroundTransparency=.02})
            __FGRoot.UiMotion.minimizeTweens={movement}
            movement:Play()
            if shellCorner then local t=TweenService:Create(shellCorner,info,{CornerRadius=UDim.new(0,12)}); table.insert(__FGRoot.UiMotion.minimizeTweens,t); t:Play() end
            if shellArtCorner then local t=TweenService:Create(shellArtCorner,info,{CornerRadius=UDim.new(0,12)}); table.insert(__FGRoot.UiMotion.minimizeTweens,t); t:Play() end
            local done; done=movement.Completed:Connect(function(state)
                done:Disconnect()
                if state~=Enum.PlaybackState.Completed or id~=__FGRoot.UiMotion.transitionId or not State.running then return end
                task.defer(function()
                    if id~=__FGRoot.UiMotion.transitionId or __FGRoot.UiMotion.minimized then return end
                    restoreSavedNavigation()
                    RunService.RenderStepped:Wait()
                    if id~=__FGRoot.UiMotion.transitionId or __FGRoot.UiMotion.minimized then return end
                    restoreSavedNavigation()
                    AnimationRoot.Position=expandedTarget
                    AnimationRoot.Visible=true
                    shell.Visible=false
                    local revealInfo=TweenInfo.new(.11,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
                    local reveal=veil and TweenService:Create(veil,revealInfo,{BackgroundTransparency=1})
                    local revealArt=art and TweenService:Create(art,revealInfo,{ImageTransparency=1})
                    __FGRoot.UiMotion.minimizeTweens={reveal,revealArt}
                    if reveal then reveal:Play() end
                    if revealArt then revealArt:Play() end
                    task.delay(.115,function()
                        if id~=__FGRoot.UiMotion.transitionId or __FGRoot.UiMotion.minimized then return end
                        if veil then veil.Visible=false end
                        State.uiMoving=false
                    end)
                end)
            end)
        end
    end
    Controller.SetMinimized=__FGRoot.setMinimized
    Controller.IsMinimized=function() return __FGRoot.UiMotion.minimized end
end

do
    local rows={}
    local PetMomentum=FastFarm.PetMomentum
    local page=Pages["Pet Momentum"]
    __FGRoot.CrefyUI.uiAddSection(page,"Mascotas equipadas")
    local holder=Instance.new("Frame")
    holder.Name="MomentumPetGrid"
    holder.BackgroundTransparency=1
    holder.BorderSizePixel=0
    holder.Size=UDim2.new(1,0,0,0)
    holder.Visible=false
    holder.LayoutOrder=nextOrder(page)
    holder.Parent=page
    local grid=Instance.new("UIGridLayout")
    grid.CellPadding=UDim2.fromOffset(6,6)
    grid.CellSize=UDim2.new(.5,-3,0,44)
    grid.FillDirection=Enum.FillDirection.Horizontal
    grid.FillDirectionMaxCells=2
    grid.HorizontalAlignment=Enum.HorizontalAlignment.Center
    grid.SortOrder=Enum.SortOrder.LayoutOrder
    grid.Parent=holder
    for i=1,9 do
        local card=Instance.new("Frame")
        card.Name="Pet"..tostring(i)
        card.LayoutOrder=i
        card.Visible=false
        card.Parent=holder
        __FGRoot.CrefyUI.styleRow(card,44)
        local title=Instance.new("TextLabel")
        title.BackgroundTransparency=1
        title.BorderSizePixel=0
        title.Position=UDim2.fromOffset(10,3)
        title.Size=UDim2.new(.63,-12,0,18)
        title.Font=C.fontBold
        title.Text=tostring(i)
        title.TextColor3=C.white
        title.TextSize=11
        title.TextTruncate=Enum.TextTruncate.AtEnd
        title.TextXAlignment=Enum.TextXAlignment.Left
        title.ZIndex=13
        title:SetAttribute("NoTranslate",true)
        title:SetAttribute("KeepTextStyle",true)
        title.Parent=card
        local multiplier=Instance.new("TextLabel")
        multiplier.BackgroundTransparency=1
        multiplier.BorderSizePixel=0
        multiplier.Position=UDim2.new(.63,0,0,3)
        multiplier.Size=UDim2.new(.37,-9,0,18)
        multiplier.Font=C.fontBold
        multiplier.Text="x1"
        multiplier.TextColor3=C.blue
        multiplier.TextSize=11
        multiplier.TextXAlignment=Enum.TextXAlignment.Right
        multiplier.ZIndex=13
        multiplier:SetAttribute("NoTranslate",true)
        multiplier:SetAttribute("KeepTextStyle",true)
        multiplier.Parent=card
        local track=Instance.new("Frame")
        track.BackgroundColor3=Color3.fromRGB(9,12,19)
        track.BackgroundTransparency=.08
        track.BorderSizePixel=0
        track.ClipsDescendants=true
        track.Position=UDim2.fromOffset(10,27)
        track.Size=UDim2.new(.58,-10,0,5)
        track.ZIndex=13
        track.Parent=card
        Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
        local fill=Instance.new("Frame")
        fill.BackgroundColor3=C.cyan
        fill.BorderSizePixel=0
        fill.Size=UDim2.fromScale(0,1)
        fill.ZIndex=14
        fill.Parent=track
        Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
        local gradient=Instance.new("UIGradient")
        gradient.Color=ColorSequence.new(C.blue,C.cyan)
        gradient.Parent=fill
        local remaining=Instance.new("TextLabel")
        remaining.BackgroundTransparency=1
        remaining.BorderSizePixel=0
        remaining.Position=UDim2.new(.58,3,0,21)
        remaining.Size=UDim2.new(.42,-12,0,18)
        remaining.Font=UI_FONT
        remaining.Text="--"
        remaining.TextColor3=C.dim
        remaining.TextSize=9
        remaining.TextXAlignment=Enum.TextXAlignment.Right
        remaining.ZIndex=13
        remaining:SetAttribute("NoTranslate",true)
        remaining:SetAttribute("KeepTextStyle",true)
        remaining.Parent=card
        rows[i]={row=card,title=title,multiplier=multiplier,remaining=remaining,fill=fill}
    end
    startThread("momentumDetails",function()
        while State.running do
            if State.currentTab=="Pet Momentum" then
                local pets=PetMomentum:GetEquippedPackPets()
                local visible=math.min(#pets,#rows)
                holder.Visible=visible>0
                holder.Size=UDim2.new(1,0,0,visible>0 and (math.ceil(visible/2)*50-6) or 0)
                for i,row in ipairs(rows) do
                    local pet=pets[i]; row.row.Visible=pet~=nil
                    if pet then
                        local seconds=tonumber(pet:GetAttribute(PetMomentum.attribute)) or 0
                        local progress=PetMomentum:GetTierProgress(seconds)
                        row.title.Text=pet.Name
                        row.multiplier.Text=progress.complete and ("x"..tostring(progress.multiplier).." ✓")
                            or ("x"..tostring(progress.multiplier).." › x"..tostring(progress.nextMultiplier or progress.multiplier))
                        local left=progress.remaining
                        local words=PetMomentum.progressText[State.language] or PetMomentum.progressText.es
                        row.remaining.Text=progress.complete and words.shortMax or string.format("-%02d:%02d:%02d",math.floor(left/3600),math.floor(left/60)%60,math.floor(left)%60)
                        local alpha=progress.duration>0 and math.clamp(progress.elapsed/progress.duration,0,1) or 1
                        row.fill.Size=UDim2.fromScale(alpha,1)
                    end
                end
            end
            task.wait(State.currentTab=="Pet Momentum" and .5 or 1)
        end
    end)
end

do
    local path="Young0xHub/FG100/language_"..tostring(LP.UserId)..".txt"
    State.saveLanguage=function(language)
        if type(writefile)~="function" or type(makefolder)~="function" then return end
        pcall(function()
            if not isfolder("Young0xHub") then makefolder("Young0xHub") end
            if not isfolder("Young0xHub/FG100") then makefolder("Young0xHub/FG100") end
            writefile(path,language)
        end)
    end
    local language=State.resume and State.resume.language
    if not language and type(readfile)=="function" and type(isfile)=="function" then
        local ok,value=pcall(function() return isfile(path) and readfile(path) end)
        if ok then language=value end
    end
    State.initialLanguage=language or "es"
end

end
pageSetup()
pageSetup=function()
do
    MiniIcon.Text="Young0x Hub"
    MiniIcon.TextStrokeTransparency=.8
    MiniIcon.Position=UDim2.fromOffset(6,2)
    MiniIcon.Size=UDim2.new(1,-12,0,22)
    MiniIcon.TextSize=MIN_WIDTH<140 and 14 or 17
    MiniIcon:SetAttribute("NoTranslate",true)
    local identity=Instance.new("TextLabel")
    identity.Name="Player"; identity.BackgroundTransparency=1; identity.BorderSizePixel=0
    identity.Position=UDim2.fromOffset(7,30); identity.Size=UDim2.new(1,-14,0,15)
    identity.TextColor3=C.soft; identity.Font=Enum.Font.GothamMedium; identity.TextSize=10
    identity.TextTruncate=Enum.TextTruncate.AtEnd; identity.ZIndex=MiniIcon.ZIndex
    identity:SetAttribute("NoTranslate",true); identity:SetAttribute("KeepTextStyle",true)
    identity.Parent=MiniBubble
    State.MiniIdentity=identity
    State.MiniStats.Size=UDim2.new(1,-12,0,16)
    State.MiniStats.Position=UDim2.new(0,6,1,-20)
    State.MiniStats.RichText=true
    local statsLimit=State.MiniStats:FindFirstChildWhichIsA("UITextSizeConstraint")
    if statsLimit then statsLimit.MinTextSize=9; statsLimit.MaxTextSize=11 end
    local function colorHex(color)
        return string.format("#%02X%02X%02X",math.floor(color.R*255+.5),math.floor(color.G*255+.5),math.floor(color.B*255+.5))
    end
    State.updateMiniStats=function(fps,ping)
        fps=math.max(0,math.floor(tonumber(fps) or 0))
        ping=math.max(0,math.floor(tonumber(ping) or 0))
        local fpsColor=fps>=55 and C.green or (fps>=30 and C.orange or C.red)
        local pingColor=ping>0 and State.pingStatusColor(ping) or C.dim
        State.MiniStats.Text=string.format('<font color="%s">%d FPS</font><font color="%s">  •  </font><font color="%s">%s ms</font>',
            colorHex(fpsColor),fps,colorHex(C.dim),colorHex(pingColor),ping>0 and tostring(ping) or "--")
    end
    State.updateMiniStats(State.liveFps or 0,State.livePing or 0)
end
do
    local original=State.applyTheme
    State.applyTheme=function(name,quiet)
        local accepted=original(name,quiet)
        if not accepted then return false end
        local treatment=({Galaxia={90,.18,.28},Violeta={-35,.29,.22},["Carmesí"]={25,.22,.32},Esmeralda={140,.27,.25}})[name]
        if treatment then
            for _,object in ipairs(getHubUIDescendants()) do
                if object:IsA("UIGradient") and object.Name=="Surface" then
                    object.Rotation=treatment[1]
                end
                if object:IsA("GuiObject") and object:GetAttribute("SurfaceRow") then
                    object.BackgroundTransparency=treatment[2]
                end
            end
            local art=MainFrame:FindFirstChild("BackgroundArt")
            if art then art.ImageTransparency=treatment[3] end
        end
        return accepted
    end
end
do
    local gameGui=PlayerGui:FindFirstChild("gameGui")
    local brawlPrompt=gameGui and gameGui:FindFirstChild("brawlJoinLabel")
    if brawlPrompt then
        local function closeUnusedBrawlPrompt()
            if State.running and not State.kill.autoWinBrawl and brawlPrompt.Visible then
                brawlPrompt.Visible=false
            end
        end
        track(brawlPrompt:GetPropertyChangedSignal("Visible"):Connect(function()
            if brawlPrompt.Visible and not State.kill.autoWinBrawl then
                task.defer(closeUnusedBrawlPrompt)
            end
        end))
        closeUnusedBrawlPrompt()
    end
end

end
pageSetup()
Env.Young0xFG100 = Controller

AnimationRoot.Position=UDim2.fromScale(.5,.5)
MainFrame.Size=UDim2.fromOffset(hubWidth-2,hubHeight-2)
Border.Size=UDim2.fromOffset(hubWidth,hubHeight)
Shadow.Size=UDim2.fromOffset(hubWidth,hubHeight)
__FGRoot.UiMotion.expandedPosition=AnimationRoot.Position

RunService.Heartbeat:Wait()
TabBar.CanvasSize = UDim2.fromOffset(tabLayout.AbsoluteContentSize.X + 14, 0)
State.restoreResume=function()
 local r=State.resume
 if type(r)~="table" or r.script~="fg100.lua" then refreshTabs("Dios Te ama ❤"); return end
 State.resumeApplied = true
 FastFarm.packMode=r.packMode or FastFarm.packMode
 local exclusive=r.afkMode or r.fastMode
 local farmPages={["Full Train"]=true,["Auto Farm"]=true,["Pet Momentum"]=true,["Rebirths"]=true,["Fast Glitch 100%"]=true,["Kills"]=true}
 local function configure(values,toggles)
  local keys={}
  for key in pairs(values or {}) do keys[#keys+1]=key end
  table.sort(keys,function(a,b) return tostring(a)<tostring(b) end)
  for _,key in ipairs(keys) do
   local c=State.profileControls[key] or State.selectorControllers[key]
   if c and c~=State.afkModeSelector and (c.ProfileKind=="toggle")==toggles then
    local v=values[key]
    local page=tostring(key):match("^([^|]+)|")
    local skip=toggles and (page=="Fast Farm" or page=="AFK 24/7" or c==State.killServerHopToggle or (exclusive and farmPages[page] and c~=State.killProtectToggle and c~=State.autoBossToggle))
    if (not toggles or v==true) and not skip then
     local ok,result=pcall(toggles and c.Set or c.SetValue or c.Set,c,v)
     if not ok or result==false then State.pushOutput("ERROR","Restaurar: "..tostring(key)) end
    end
   end
  end
 end
 configure(r.selectors,false); configure(r.controls,false)
 configure(r.controls,true)
 if r.afkMode then
  local ok,result=pcall(State.afkResume,r.afkSession or {mode=r.afkMode})
  if not ok or result==false then State.pushOutput("ERROR","Restaurar: AFK 24/7") end
 elseif r.fastMode then Controller.SetFastFarm(r.fastMode) end
 if r.serverHop and State.killServerHopToggle then State.killServerHopToggle:Set(true) end
 refreshTabs(Pages[r.tab] and r.tab or "Dios Te ama ❤")
end
State.restoreResume()
State.restoreResume = nil
State.applyTheme(State.themeName, true)
State.resume = nil

State.setLanguage(State.initialLanguage or "es")
State.languageSelector:SetValue(({es="Español",en="English",pt="Português",ar="العربية"})[State.language] or "Español")

if __FGRoot.CrefyEnabled then
    -- The former custom UI is now only a hidden compatibility model. All user-facing
    -- tabs and controls live in Crefy, so no legacy ScreenGui is rendered.
    pcall(function() ScreenGui.Enabled = false end)
    refreshTabs((State.currentTab and Pages[State.currentTab]) and State.currentTab or "Dios Te ama ❤")
    if __FGRoot.CrefySaveManager and not State.resumeApplied then
        task.defer(function()
            if State.running and __FGRoot.CrefySaveManager and not State.resumeApplied then
                local ok, err = pcall(function() __FGRoot.CrefySaveManager:LoadAutoloadConfig() end)
                if not ok then warn("[FG100] Crefy autoload config failed: " .. tostring(err)) end
            end
        end)
    end
end
State.ready=true
