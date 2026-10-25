local LIBRARY_URL = "https://raw.githubusercontent.com/RCLRMonovaUI/RCLR_Monova/refs/heads/main/RCLR_Monova1%20(3).lua"

-- Isolated loader: NEVER share UI with Unnamed Enhancements / other RCLR scripts.
-- Sharing caused every option to appear twice and freezes when both scripts fight one Library.
local loadstring = loadstring or load

-- RCLR-only namespace. Do not use the global manager/function names used by UE.
local RCLR_Functions = {}
local RCLR_Run = {alive=true, connections={}}
RCLR_Run.previousRun = (type(getgenv) == "function" and getgenv() or _G).RCLR_PREM_Run
if RCLR_Run.previousRun and type(RCLR_Run.previousRun.shutdown) == "function" then
    pcall(RCLR_Run.previousRun.shutdown)
end
RCLR_Run.shutdown = function()
    RCLR_Run.alive = false
    for _, connection in pairs(RCLR_Run.connections) do
        pcall(function() connection:Disconnect() end)
    end
end
(type(getgenv) == "function" and getgenv() or _G).RCLR_PREM_Run = RCLR_Run

local function RCLR_getgenv()
    if type(getgenv) == "function" then
        return getgenv()
    end
    return _G
end

local function loadMonova()
    local g = RCLR_getgenv()

    -- Only unload a previous RCLR PREM instance (never UE / other scripts)
    local old = g.RCLR_PREM_Library
    if type(old) == "table" then
        pcall(function()
            if old.SafeUnload then old:SafeUnload()
            elseif old.Unload then old:Unload() end
        end)
        pcall(function()
            if old.ScreenGui and old.ScreenGui.Parent then old.ScreenGui:Destroy() end
        end)
    end
    pcall(function()
        local cg = game:GetService("CoreGui")
        for _, name in ipairs({ "RCLRPrem_Coords", "RCLR_MobileUI", "RCLRPresetPrompt", "RCLRPresetPrompt" }) do
            local o = cg:FindFirstChild(name)
            if o then o:Destroy() end
        end
    end)

    local ok, src = pcall(function() return game:HttpGet(LIBRARY_URL) end)
    if not ok or type(src) ~= "string" or #src < 1000 then
        error("[RCLR PREM] HttpGet failed: " .. tostring(src))
    end

    -- Only tear down previous PREM clones inside the library boot, not UE
    src = src:gsub("OldLibrary%.IsRCLR then", "OldLibrary.IsRCLR and OldLibrary.RCLR_PREM then")
    -- Window title on the LEFT (not centered)
    src = src:gsub(
        "TextXAlignment = Enum%.TextXAlignment%.Center,%s*ZIndex = 1,%s*Parent = Inner,",
        "TextXAlignment = Enum.TextXAlignment.Left,\n        ZIndex = 1,\n        Parent = Inner,",
        1
    )
    src = src:gsub(
        "local WindowLabel = Library:CreateLabel%(%{%s*Position = UDim2%.new%(0, 0, 0, 0%),%s*Size = UDim2%.new%(1, 0, 0, 25%),",
        "local WindowLabel = Library:CreateLabel({\n        Position = UDim2.new(0, 24, 0, 0),\n        Size = UDim2.new(0.65, 0, 0, 25),",
        1
    )


    -- Make tab indicators findable + respect Library.TabLineSide / thickness
    src = src:gsub(
        "local TabIndicator = Library:Create%('Frame', %{",
        "local TabIndicator = Library:Create('Frame', { Name = 'TabIndicator', "
    )
    -- after TabIndicator registry, store on Tab (best effort)
    if not src:find("Tab.TabIndicator = TabIndicator") then
        src = src:gsub(
            "Library:AddToRegistry%(TabIndicator, %{ BackgroundColor3 = 'AccentColor' %}%)",
            "Library:AddToRegistry(TabIndicator, { BackgroundColor3 = 'AccentColor' })\n        Tab.TabIndicator = TabIndicator\n        Tab.Button = TabButton\n        Tab.TabButton = TabButton\n        Tab.TabLabel = TabLabel\n        do\n            local side = Library.TabLineSide or 'Bottom'\n            local th = Library.TabLineThickness or 1\n            TabIndicator.Size = UDim2.new(1, 0, 0, th)\n            if side == 'Top' then\n                TabIndicator.Position = UDim2.new(0, 0, 0, 0)\n                TabIndicator.AnchorPoint = Vector2.new(0, 0)\n            else\n                TabIndicator.Position = UDim2.new(0, 0, 1, 0)\n                TabIndicator.AnchorPoint = Vector2.new(0, 1)\n            end\n        end",
            1
        )
    end

    -- HARD isolation: never touch getgenv Library/Toggles/Options (UE freeze fix)
    src = src:gsub("g%.Toggles%s*=%s*Toggles", "g.RCLR_Toggles = Toggles")
    src = src:gsub("g%.Options%s*=%s*Options", "g.RCLR_Options = Options")
    src = src:gsub("g%.Library%s*=%s*Library", "g.RCLR_Library = Library")
    src = src:gsub("ScreenGui%.Name%s*=%s*'RCLR_Monova_UI'", "ScreenGui.Name = 'RCLR_Prem_UI'")
    src = src:gsub('ScreenGui%.Name%s*=%s*"RCLR_Monova_UI"', 'ScreenGui.Name = "RCLR_Prem_UI"')

    local fn, err = loadstring(src)
    if not fn then
        error("[RCLR PREM] compile error: " .. tostring(err))
    end
    local ok2, lib = pcall(fn)
    if not ok2 or type(lib) ~= "table" then
        error("[RCLR PREM] runtime error: " .. tostring(lib))
    end
    return lib
end

getgenv().RCLR_PREM_PresetShown = false
getgenv().RCLR_PREM_LoadingDone = false
local Library = loadMonova()
Library.RCLR_PREM = true
Library.IsRCLR = true
Library.Name = "RCLR_Prem"

local g = RCLR_getgenv()
g.RCLR_PREM_Library = Library

-- Detect Unnamed Enhancements / other UI already running
local UE_PRESENT = false
pcall(function()
    local L = g.Library
    if type(L) == "table" and L.RCLR_PREM ~= true and L ~= Library then
        UE_PRESENT = true
    end
end)
Library._UE_PRESENT = UE_PRESENT
-- UE isolation silent (no console spam)

-- Kill library boot splash only for OUR instance
pcall(function()
    if Library._LoadingScreen then
        Library._LoadingScreen:Destroy(0)
    end
end)
Library._LoadingScreen = nil

-- Private option tables ONLY (never overwrite UE getgenv Toggles/Options/Library)
local Toggles = Library.Toggles or {}
local Options = Library.Options or {}
Library.Toggles = Toggles
Library.Options = Options
g.RCLR_Toggles = Toggles
g.RCLR_Options = Options
g.RCLR_Library = Library
-- DO NOT: g.Toggles = ... / g.Options = ... / g.Library = ...

-- Left title = script + discord | right/game label = auto-detected place name
local function detectGameName()
    local name = nil
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        if info and type(info.Name) == "string" and info.Name ~= "" then
            name = info.Name
        end
    end)
    if not name or name == "" then
        name = tostring(game.Name or "Unknown")
    end
    local lower = string.lower(name)
    -- normalize common Rivals place titles
    if string.find(lower, "rival", 1, true)
        or string.find(lower, "matchmaking", 1, true)
        or string.find(lower, "ranked", 1, true) and string.find(lower, "1v1", 1, true) then
        return "Rivals"
    end
    return name
end

local Window = Library:CreateWindow({
    Title    = "RCLR Lua Prem - discord.gg/ZmN2Djb7m",
    GameName = detectGameName(),
    Center   = true,
    AutoShow = true,
    Size     = UDim2.fromOffset(560, 645),
})

-- WAY lighter UI panels
pcall(function()
    Library.BackgroundColor = Color3.fromRGB(100, 100, 112)
    Library.MainColor       = Color3.fromRGB(120, 120, 132)
    Library.AccentColor     = Color3.fromRGB(235, 235, 240)
    Library.OutlineColor    = Color3.fromRGB(130, 130, 145)
    Library.FontColor       = Color3.fromRGB(255, 255, 255)
    if Library.GetDarkerColor then
        Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)
    end
    if Library.UpdateColorsUsingRegistry then
        Library:UpdateColorsUsingRegistry()
    end
    -- no full UI scan (was causing freezes)
end)

-- RCLR logo (library only — no custom RenderStepped fallback that lags)
task.defer(function()
    task.wait(0.5)
    pcall(function()
        if Library.CreateLogo then
            Library:CreateLogo({
                Text = "RCLR",
                TextSize = 52,
                SpinSpeed = 24,
            })
        end
    end)
end)


-- Force window title LEFT like Unnamed Enhancements
task.defer(function()
    task.wait(0.1)
    pcall(function()
        if not Library.ScreenGui then return end
        for _, d in ipairs(Library.ScreenGui:GetDescendants()) do
            if d:IsA("TextLabel") and d.Text and (string.find(d.Text, "RCLR", 1, true) or string.find(d.Text, "discord.gg/ZmN", 1, true)) then
                d.TextXAlignment = Enum.TextXAlignment.Left
                d.AnchorPoint = Vector2.new(0, 0)
                d.Position = UDim2.new(0, 24, 0, d.Position.Y.Offset)
                d.Size = UDim2.new(0.65, 0, 0, 25)
                d.Text = "RCLR Lua Prem - discord.gg/ZmN2Djb7m"
                d.TextTruncate = Enum.TextTruncate.None
            end
        end
    end)
end)

-- Loading overlay; when it hits 100%, show preset prompt
getgenv().RCLR_PREM_LoadingDone = false
task.spawn(function()
    local ls
    pcall(function()
        local cls = Library._LoadingScreenClass
        if cls and cls.new then ls = cls.new() end
    end)
    local steps = {
        { 0.15, "Loading modules" },
        { 0.35, "Building UI" },
        { 0.55, "RCLR Lua Prem" },
        { 0.75, "discord.gg/ZmN2Djb7m" },
        { 1.00, "Ready" },
    }
    if ls then
        for _, step in ipairs(steps) do
            task.wait(0.55)
            pcall(function() ls:SetProgress(step[1], step[2]) end)
        end
        task.wait(0.15)
        pcall(function() if ls.Destroy then ls:Destroy(0.35) end end)
    else
        task.wait(2.5)
    end
    getgenv().RCLR_PREM_LoadingDone = true
    -- Show preset when function is registered (defined later in file)
    task.spawn(function()
        local t0 = tick()
        while tick() - t0 < 12 do
            local fn = getgenv().RCLR_ShowPresetPrompt
            if type(fn) == "function" and not getgenv().RCLR_PREM_PresetShown then
                task.wait(0.25)
                pcall(fn)
                return
            end
            task.wait(0.15)
        end
    end)
end)

-- Backup: show preset when window ready + function registered
task.spawn(function()
    local t0 = tick()
    while tick() - t0 < 15 do
        if getgenv().RCLR_PREM_PresetShown then return end
        local fn = getgenv().RCLR_ShowPresetPrompt
        if type(fn) == "function" and Window and Window.Tabs then
            task.wait(0.4)
            pcall(fn)
            return
        end
        task.wait(0.2)
    end
end)

local function Notify(text, duration)
    pcall(function() if Library and Library.Notify then Library:Notify(tostring(text), duration or 3) end end)
end

local windowReady = false
local function waitForWindow()
    -- the Monova window object exposes .Tabs, never .MainFrame
    if Window and Window.Tabs then
        windowReady = true
        return true
    end
    task.wait(0.1)
    return false
end

-- This block used to run on the boot thread and stall there, which is why the
-- loading screen froze at 12%. It now runs after the menu is on screen.
local function runACBypass()
    return -- fully disabled (prevents freeze/crash with other UIs)
end

-- AC bypass DISABLED (hooks freeze/crash with other scripts)
-- task.spawn(function() pcall(runACBypass) end)


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local char, root, hum
local conns = {}

RCLR_Run.connections.featureShutdown = { Disconnect = function()
    for _, connection in pairs(conns) do
        pcall(function() connection:Disconnect() end)
    end
end }
local function killConn(key)
    if conns[key] then conns[key]:Disconnect(); conns[key] = nil end
end
local function getLocalRoot() return root end

-- Global dodge budget: max teleport writes per 1/60s window. The old dodge
-- paths ran a 3x Heartbeat:Wait() chain INSIDE Heartbeat callbacks, which
-- stacked dozens of suspended threads per frame and hard-froze Rivals once
-- several players were on the server. One write per dodge, capped per frame.
local MAX_DODGES_PER_FRAME = 3
local _dodgeFrame = -1
local _dodgeFrameCount = 0
local function tryDodgeFrame()
    local f = math.floor(tick() * 60 + 0.5)
    if f ~= _dodgeFrame then _dodgeFrame = f; _dodgeFrameCount = 0 end
    if _dodgeFrameCount >= MAX_DODGES_PER_FRAME then return false end
    _dodgeFrameCount = _dodgeFrameCount + 1
    return true
end

local CFG = {
    VOID_ENABLED = false, VOID_METHOD = "Quantum",
    SPEED = 1e15, CHAOS = 0.98, BASE_X = 0, BASE_Y = 0, BASE_Z = 0,
    RADIUS = 1e11, VOID_Y_MIN = -1e15, VOID_Y_MAX = 1e15,
    TP_MIN_STUDS = -1e10, TP_MAX_STUDS = 1e10,
    TP_RAND_ENABLED = true, TP_RAND_MIN = -1e10, TP_RAND_MAX = 1e10, TP_CORNER_ONLY = false,
    TP_VERT_SPIKE = true, TP_VERT_MULT_MIN = 0.5, TP_VERT_MULT_MAX = 3.0,
    TP_CORNER_WEIGHT = 0.20, TP_EDGE_WEIGHT = 0.10, TP_SCREEN_JITTER = 0.02,
    TP_SCREEN_CLAMP = true, TP_VIEWPORT_RAY = true, TP_NEG_BIAS = true,
    TP_PRESERVE_Y = false,
    VOID_SAFE_RADIUS = 0, VOID_ORBIT_TARGET = false, VOID_ORBIT_SPEED = 90,
    VOID_STOP_ON_DAMAGE = false, VOID_PREDICTIVE = false, VOID_PREDICT_LEAD = 0.15,
    VOID_AUTO_REENABLE = false, VOID_ANTIFLING = true,
    VOID_FREEZE_ON_GROUND = false, VOID_ANTIVOID = false,
    VOID_DURATION_ENABLED = false, VOID_DURATION = 10,
    VOID_RANDOM_DURATION = false, VOID_DURATION_MIN = 5, VOID_DURATION_MAX = 30,
    VOID_STAY_IN_REGION = false, VOID_REGION_X = 1e4, VOID_REGION_Y = 1e4, VOID_REGION_Z = 1e4,
    VOID_REGION_CIRCLE = true, VOID_REGION_BOX = false, VOID_REGION_CENTER_SELF = true,
    VOID_REGION_CX = 0, VOID_REGION_CY = 0, VOID_REGION_CZ = 0,
    VOID_REGION_PUSH = true, VOID_REGION_PUSH_AWAY = 120,
    VOID_REGION_COLLAPSE = false, VOID_REGION_COLLAPSE_SPD = 50,
    VOID_REGION_NOTIFY_EXIT = false, VOID_REGION_SNAP_EDGE = true,
    VOID_LOG_POSITIONS = false,
    SMART_EVASION = false, SMART_EVASION_INF = false,
    EVASION_RANGE = 80, EVASION_THREAT_DIST = 40,
    EVASION_DODGE_POWER = 100, EVASION_COOLDOWN = 0.03,
    EVASION_PREDICT_TIME = 0.18, EVASION_NOTIFY = false,
    EVASION_MICRO_JITTER = true, EVASION_VERTICAL_SPIKE = true,
    EVASION_LAYERED = true, EVASION_THREAT_SCALE = true,
}

local cfg = {
    orbitEnabled = false, orbitSpeed = 90, orbitDist = 8, orbitHeight = 0,
    orbitLerp = 0.3, orbitMode = "Circle", orbitPredict = false, orbitPredStr = 0.2,
    orbitFace = true, orbitLockDist = 999999999, orbitTarget = "Closest", orbitAxis = "XZ",
    orbitReverse = false, orbitRandRad = false, orbitRandMin = 5, orbitRandMax = 20,
    orbitYawOff = 0, orbitPitchOff = 0, orbitOffX = 0, orbitOffZ = 0,
    orbitHeightOscillate = false, orbitHeightOscAmp = 5, orbitHeightOscSpeed = 2,
    orbitSpeedRandom = false, orbitSpeedRandMin = 20, orbitSpeedRandMax = 200,
    orbitDistPulse = false, orbitDistPulseAmp = 5, orbitDistPulseSpeed = 1,
    orbitZigzag = false, orbitZigzagAmp = 3, orbitZigzagFreq = 4,
    orbitSnapBack = false, orbitSnapInterval = 0.5,
}

local cfgDodge = {
    predEnabled = false, predRadius = 400, predDodgeDist = 160,
    predCooldown = 0.008, predThreshold = 150, predMult = 1,
    predLeadTime = 0.22, predShootDetect = true, predShootDot = 0.60,
    predShootDist = 100, predBulletSpd = 200, predReactTime = 0.06,
    predRaycast = true, predMultiPoint = true, predBackstep = true,
    predReactionLadder = true, predThreatScore = true,
    predAimVector = true, predCameraBone = true, predAnimDetect = true,
    predRemoteHook = true, predPredictiveAim = true, predPredictiveLead = 0.25,
    predInfiniteRange = true, predNotifyAnywhere = false,
    predSmoothedTargeting = true, predAlignLookAtThreat = true,
    predAdaptiveCooldown = true, predCooldownDecay = 0.6,
    predRecoilOffset = 0.25, predLeadNoise = 0.05,
    predLookaheadBias = 0.62, predPlanDontTPClose = 0.35,
}

local antiBaitCFG = {
    enabled = false, velSpikeEnabled = true, velThreshold = 200,
    velDodgeDist = 100, flickerEnabled = true, flickerWindow = 0.3,
    flickerMinTps = 2, flickerTpDist = 10, dodgeCooldown = 0.005,
    dodgeMode = "Perpendicular", notifyOnDodge = true,
    dodgeOnShoot = true, shootLookThresh = 0.85,
    gunPredEnabled = true, gunPredDot = 0.80, gunPredVelMin = 30,
    gunPredDodgeDist = 160, gunPredCooldown = 0.005, gunPredLead = 0.22,
    baitEnabled = true, baitStallTime = 0.08, baitStallChance = 0.4,
    baitFakeLock = true, baitFakeLockTime = 0.06,
    baitHookActivate = true, baitReactionWindow = 0.3,
    baitNotifyLabel = true,
    universalRemotes = true, universalTools = true,
    universalAnimation = true, universalVelocity = true, universalAim = true,
    reScanInterval = 5,
    infiniteRange = true, infiniteRadius = 5e12,
    antiBaitFlickerWindowMs = 300, antiBaitFlickerMinTps = 2,
    antiBaitFlickerTpDelta = 10, antiBaitStabTimeMs = 80,
    antiBaitFakeLockMs = 60, antiBaitGunPredCDms = 5, antiBaitGunPredLeadMs = 22,
    antiBaitGunPredDodge = 160, antiBaitGunPredDot = 0.80, antiBaitGunPredVelMin = 30,
    antiBaitVelThreshold = 200, antiBaitDodgeDist = 100, antiBaitCooldownMs = 5,
    antiBaitReactionWindowMs = 300, antiBaitBaitEnabled = true, antiBaitStallChance = 0.4,
}

local translocCFG = {
    enabled = false, frequency = 256, offsetDist = 999000000000,
    offsetMode = "Ahead", offsetY = 0, fakeVel = true,
    fakeVelMag = 1e10, snapBack = true, jitter = true,
    jitterAmp = 1e11, layers = 5,
    burstMode = false, burstCount = 10, burstInterval = 0.001,
    randomFrequency = false, freqMin = 50, freqMax = 500,
    spinFake = false, spinFakeSpeed = 720,
    mirrorX = false, mirrorZ = false,
    cascadeOffset = false, cascadeStep = 1e11,
    wavePattern = false, waveFreq = 2, waveAmp = 1e11,
    pingPong = false, pingPongDist = 1e12,
    pulse = false, pulseAmp = 1e11, pulseSpeed = 1,
    diagonal = false, diagonalAngle = 45,
    alternatingVertical = false, altVertAmp = 1e11,
    screenEdge = false, orbitFake = false, orbitSpeed = 90, orbitRadius = 1e11,
    zoneEscape = false, zoneEscapeRadius = 200,
    autoDodge = false, autoDodgeRadius = 60,
    usePreRenderCommit = true, networkOwnerFix = true,
    txFakeLayers = 6, txLayerStagger = 0.004, txLayerJitter = 1e9,
    txFakeVelMag = 1e10, txFakeVelNoise = 0.25, txFakeVelClip = 2e10,
    txScreenEdgeRay = true, txScreenEdgeDepth = 2e7, txScreenEdgeClamp = true,
    txMinBindingGap = 1e8, txFFIVelocity = false, txPreRenderCommit = true,
}

local riotGodmodeCFG = {
    enabled = false, speed = 0.03, evadeRange = 30,
    spinSpeed = 180, avoidBullets = true, bulletDodge = 40,
    heightVariance = 10, groundSnap = false, phaseMode = false,
    phaseInterval = 0.02, spinAxis = "Y", randomAxis = false,
    maxJump = 200, minJump = 10, multiTp = false,
    multiTpCount = 3, multiTpDelay = 0.01,
}

local riotAbuserCFG = {
    enabled = false, mode = "Stick", height = 3, forward = 0, right = 0, down = 0,
    autoShoot = true, attackRange = 10, orbitEnabled = false,
    orbitRadius = 5, orbitSpeed = 200, orbitHeight = 2,
    spinOnTarget = false, spinSpeed = 360, phaseOffset = 3,
    multiTarget = false, randomOffset = false, randomOffAmp = 2,
    bounceHeight = 5, bounceSpeed = 8, shootCooldown = 0.05,
    lastShot = 0, predictTarget = false, predictLead = 0.1,
    forceFaceTarget = true,
}

local aaSettings = {
    enabled = false, mode = "RandomSpin", speed = 5000,
    angle = 90, randomSpeed = true, jitterPitch = true,
    pitchAngle = 45, yawAngle = 45, staticYaw = 90, staticPitch = 0,
    customYaw = 180, customPitch = 0, jitterYaw = true,
    fakeAngle = false, fakeYaw = 45, fakePitch = 0,
    microJitter = false, microJitterAmp = 5, microJitterSpeed = 30,
    desyncMode = false, desyncOffset = 180,
    rollEnabled = false, rollSpeed = 360,
    breatheEffect = false, breatheAmp = 3, breatheSpeed = 1,
    randomFlip = false, flipChance = 0.05,
}
local function getClosest()
    if not root then return nil end
    local best, bestD = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local d = (root.Position - hrp.Position).Magnitude
        if d < bestD then bestD = d; best = p end
    end
    return best
end

local function getTarget(mode)
    if mode == "Closest" then return getClosest() end
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, p)
        end
    end
    if #list == 0 then return nil end
    if mode == "Random" then return list[math.random(1, #list)]
    elseif mode == "Weakest" then
        table.sort(list, function(a, b)
            local ha = a.Character:FindFirstChildOfClass("Humanoid")
            local hb = b.Character:FindFirstChildOfClass("Humanoid")
            return (ha and ha.Health or 0) < (hb and hb.Health or 0)
        end)
        return list[1]
    elseif mode == "Strongest" then
        table.sort(list, function(a, b)
            local ha = a.Character:FindFirstChildOfClass("Humanoid")
            local hb = b.Character:FindFirstChildOfClass("Humanoid")
            return (ha and ha.Health or 0) > (hb and hb.Health or 0)
        end)
        return list[1]
    end
    return list[1]
end

local function AddBindableToggle(group, flag, text, default, callback)
    -- toggles ship without a keybind; keybinds are attached only to the good ones below
    return group:AddToggle(flag, { Text = text, Default = default or false, Callback = callback })
end

local function predictPos(hrp, lead)
    if not hrp then return Vector3.zero end
    local vel = hrp.AssemblyLinearVelocity
    local grav = Vector3.new(0, -workspace.Gravity * 0.5, 0)
    return hrp.Position + vel * lead + grav * (lead * lead * 0.5)
end

local function getAimOrigin(plr)
    if not plr or not plr.Character then return nil end
    return plr.Character:FindFirstChild("Head")
        or plr.Character:FindFirstChild("CameraBone", true)
        or plr.Character:FindFirstChild("HumanoidRootPart")
end

local function getInfiniteRange()
    return 5e12
end

local function enemyAimingUniversal(plr, myPos, dot)
    local origin = getAimOrigin(plr)
    if not origin then return false end
    local look = origin.CFrame.LookVector
    local eye = origin.Position + look * 0.5
    local toMe = myPos - eye
    if toMe.Magnitude < 0.01 then return false end
    return look:Dot(toMe.Unit) > dot
end

local function perpDodgeDir(fromPos, myPos)
    local flat = Vector3.new(fromPos.X - myPos.X, 0, fromPos.Z - myPos.Z)
    if flat.Magnitude < 0.01 then flat = Vector3.new(1, 0, 0) end
    flat = flat.Unit
    local p1 = Vector3.new(-flat.Z, 0, flat.X)
    local p2 = Vector3.new(flat.Z, 0, -flat.X)
    local chosen = math.random(0, 1) == 0 and p1 or p2
    return chosen + Vector3.new(0, (math.random() - 0.5) * 0.4, 0)
end

local function buildThreatMap(myPos)
    local map = {}
    if not myPos then return map end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local tool = p.Character:FindFirstChildOfClass("Tool")
        local origin = getAimOrigin(p) or hrp
        local look = origin.CFrame.LookVector
        local eye = origin.Position + look * 0.5
        local toMe = myPos - eye
        local dist = toMe.Magnitude
        if dist < 0.01 then continue end
        local aimDot = look:Dot(toMe.Unit)
        local velDot = 0
        local vel = hrp.AssemblyLinearVelocity
        if vel.Magnitude > 1 then velDot = vel.Unit:Dot(toMe.Unit) end
        local score = 0
        score = score + math.max(0, aimDot) * 45
        score = score + math.max(0, velDot) * 20
        if tool then score = score + 25 end
        local distFactor = CFG.SMART_EVASION_INF and 30 or math.max(0, 1 - dist / 250) * 30
        score = score + distFactor
        map[p] = { hrp = hrp, dist = dist, aimDot = aimDot, velDot = velDot, score = score, hasTool = tool ~= nil, origin = origin }
    end
    return map
end

local function predictEnemyAim(plr, lead, myHrp)
    if not plr or not plr.Character or not myHrp then return nil end
    local origin = getAimOrigin(plr)
    if not origin then return nil end
    local enemyHrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not enemyHrp then return nil end
    local enemyVel = enemyHrp.AssemblyLinearVelocity
    local enemyPos = origin.Position
    local myPos = myHrp.Position
    local myVel = myHrp.AssemblyLinearVelocity
    local predictedOrigin = enemyPos + enemyVel * lead
    local predictedMy = myPos + myVel * lead
    local dir = predictedMy - predictedOrigin
    if dir.Magnitude < 0.01 then return nil end
    local look = origin.CFrame.LookVector
    local futureDot = look:Dot(dir.Unit)
    return {
        predictedOrigin = predictedOrigin,
        predictedMe = predictedMy,
        dir = dir.Unit,
        futureDot = futureDot,
        dist = dir.Magnitude,
    }
end

local voidElapsed = 0
local voidPos = Vector3.new(0, 0, 0)
local voidDriftDir = Vector3.new(1, 0, 0)
local intendedVoidPos = Vector3.new(0, 0, 0)
local smartLastDodge = 0
local voidAutoReenableTime = 0
local voidStartTime = 0
local voidRegionCurrentRadius = nil
local voidRegionLastIn = true
local lastGroundY = 0
local voidPredBest = nil
local voidPredBestTile = nil
local dtForColl = 1/60

local isInsideVoidPart = nil
local function refreshVoidUtils()
    if isInsideVoidPart then return end
    isInsideVoidPart = function(pos)
        if not workspace then return false end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Include
        params.FilterDescendantsInstances = { workspace }
        local result = workspace:Spherecast(pos, 1, Vector3.new(0, 0.01, 0), params)
        return result ~= nil
    end
end

local voidRegionCollapsed = 0
local voidRegionTarget = 0

local function clampToRegionRadius(pos, cx, cy, cz, r)
    local dx = pos.X - cx
    local dy = pos.Y - cy
    local dz = pos.Z - cz
    if CFG.VOID_REGION_CIRCLE then
        local flat = math.sqrt(dx*dx + dz*dz)
        if flat > r then
            local s = r / flat
            dx = dx * s; dz = dz * s
        end
        if CFG.VOID_REGION_NOTIFY_EXIT and voidRegionLastIn then
            voidRegionLastIn = false
            pcall(function() Notify("region: clamped back to edge", 1.5) end)
        end
        voidRegionLastIn = true
    else
        local rx, ry, rz = r, CFG.VOID_REGION_Y, r
        if math.abs(dx) > rx then dx = (dx > 0 and rx or -rx) end
        if math.abs(dy) > ry then dy = (dy > 0 and ry or -ry) end
        if math.abs(dz) > rz then dz = (dz > 0 and rz or -rz) end
    end
    if not CFG.VOID_REGION_SNAP_EDGE then
        dx = dx + (math.random() - 0.5) * 20
        dz = dz + (math.random() - 0.5) * 20
    end
    return Vector3.new(cx + dx, cy + dy, cz + dz)
end

local function clampToRegion(pos)
    if not CFG.VOID_STAY_IN_REGION then return pos end
    local cx, cy, cz = CFG.VOID_REGION_CX, CFG.VOID_REGION_CY, CFG.VOID_REGION_CZ
    if CFG.VOID_REGION_CENTER_SELF and root then
        cx, cy, cz = root.Position.X, root.Position.Y, root.Position.Z
    end
    if not voidRegionTarget or voidRegionTarget <= 0 then
        voidRegionTarget = math.max(CFG.VOID_REGION_X, CFG.VOID_REGION_Z, 1)
    end
    if CFG.VOID_REGION_COLLAPSE then
        voidRegionCollapsed = math.max(0, voidRegionCollapsed + dtForColl * CFG.VOID_REGION_COLLAPSE_SPD)
        local target = math.max(10, voidRegionTarget - voidRegionCollapsed)
        return clampToRegionRadius(pos, cx, cy, cz, target)
    end
    return clampToRegionRadius(pos, cx, cy, cz, voidRegionTarget)
end

local getTpEverywherePosition = nil
local tpScreenTarget = nil
local tpRayFromScreen = nil

local function refreshTpEverywhere()
    if getTpEverywherePosition then return end
    tpScreenTarget = Vector2.new(0, 0)

    getTpEverywherePosition = function()
        if not Camera then
            local rx = math.random() * 2 - 1
            local ry = math.random() * 2 - 1
            local rz = math.random() * 2 - 1
            local dist = CFG.TP_RAND_ENABLED
                and CFG.TP_RAND_MIN + math.random() * (CFG.TP_RAND_MAX - CFG.TP_RAND_MIN)
                or  CFG.TP_MIN_STUDS + math.random() * (CFG.TP_MAX_STUDS - CFG.TP_MIN_STUDS)
            if CFG.TP_NEG_BIAS and math.random() < 0.5 then dist = -math.abs(dist) end
            return Vector3.new(CFG.BASE_X + rx * math.abs(dist), CFG.BASE_Y + ry * math.abs(dist), CFG.BASE_Z + rz * math.abs(dist))
        end

        local dist
        if CFG.TP_RAND_ENABLED then
            dist = CFG.TP_RAND_MIN + math.random() * (CFG.TP_RAND_MAX - CFG.TP_RAND_MIN)
        else
            dist = CFG.TP_MIN_STUDS + math.random() * (CFG.TP_MAX_STUDS - CFG.TP_MIN_STUDS)
        end
        if CFG.TP_NEG_BIAS and math.random() < 0.5 then dist = -math.abs(dist) end

        if not CFG.TP_VIEWPORT_RAY then
            local rx = math.random() * 2 - 1
            local ry = math.random() * 2 - 1
            local rz = math.random() * 2 - 1
            return Vector3.new(CFG.BASE_X + rx * math.abs(dist), CFG.BASE_Y + ry * math.abs(dist), CFG.BASE_Z + rz * math.abs(dist))
        end

        local vp = Camera.ViewportSize
        local roll = math.random()
        local screenX, screenY
        if CFG.TP_CORNER_ONLY or roll < CFG.TP_CORNER_WEIGHT then
            local corners = {
                Vector2.new(0, 0), Vector2.new(vp.X, 0),
                Vector2.new(0, vp.Y), Vector2.new(vp.X, vp.Y),
                Vector2.new(vp.X * 0.5, 0), Vector2.new(vp.X * 0.5, vp.Y),
                Vector2.new(0, vp.Y * 0.5), Vector2.new(vp.X, vp.Y * 0.5),
            }
            local c = corners[math.random(1, 4)]
            screenX = c.X; screenY = c.Y
        elseif roll < CFG.TP_CORNER_WEIGHT + CFG.TP_EDGE_WEIGHT then
            local edge = math.random(1, 4)
            if edge == 1 then screenX = math.random() * vp.X; screenY = 0
            elseif edge == 2 then screenX = math.random() * vp.X; screenY = vp.Y
            elseif edge == 3 then screenX = 0; screenY = math.random() * vp.Y
            else screenX = vp.X; screenY = math.random() * vp.Y end
        else
            screenX = math.random() * vp.X
            screenY = math.random() * vp.Y
        end

        if CFG.TP_SCREEN_JITTER > 0 then
            screenX = screenX + (math.random() - 0.5) * vp.X * CFG.TP_SCREEN_JITTER
            screenY = screenY + (math.random() - 0.5) * vp.Y * CFG.TP_SCREEN_JITTER
        end
        if CFG.TP_SCREEN_CLAMP then
            screenX = math.clamp(screenX, 0, vp.X)
            screenY = math.clamp(screenY, 0, vp.Y)
        end

        local depth = math.max(math.abs(dist), 1)
        local ray = Camera:ViewportPointToRay(screenX, screenY, depth)
        tpRayFromScreen = ray

        -- ViewportPointToRay returns the CAMERA as Ray.Origin, which is the same
        -- every frame. Using it pinned X and Z so only Y ever moved. Walk the
        -- ray out to the requested distance instead, from the camera CFrame.
        local camCF = Camera.CFrame
        local origin = (ray and ray.Origin) or camCF.Position
        local dir = (ray and ray.Direction) or camCF.LookVector
        if typeof(origin) ~= "Vector3" then origin = camCF.Position end
        if typeof(dir) ~= "Vector3" or dir.Magnitude < 1e-3 then dir = camCF.LookVector end
        dir = dir.Unit

        local point = origin + dir * depth
        if point.X ~= point.X or point.Z ~= point.Z then
            point = camCF.Position + camCF.LookVector * depth
        end

        -- push the point off the view line so every teleport lands somewhere new
        local lateral = depth * 0.35
        local px = point.X + (math.random() * 2 - 1) * lateral
        local pz = point.Z + (math.random() * 2 - 1) * lateral

        local vertMult = (CFG.TP_VERT_MULT_MIN + math.random() * (CFG.TP_VERT_MULT_MAX - CFG.TP_VERT_MULT_MIN)) * (CFG.TP_VERT_MULT_EXTRA or 1)
        local vert = CFG.TP_VERT_SPIKE and (math.random() * 2 - 1) * depth * vertMult or 0
        if CFG.TP_NEG_BIAS then vert = vert - math.abs(vert) * 0.3 end
        if CFG.TP_PRESERVE_Y then vert = 0 end

        local y
        if CFG.TP_PRESERVE_Y then
            y = root and root.Position.Y or 0
        else
            y = point.Y + vert
        end

        return Vector3.new(px, y, pz)
    end
end

-- these two were defined but never invoked, which left getTpEverywherePosition
-- and isInsideVoidPart nil and made "TP Everywhere" a no-op
refreshVoidUtils()
refreshTpEverywhere()

local function driftDir3D(t)
    local nx, ny, nz = 0, 0, 0
    local amp, freq = 1, 0.0001
    for _ = 1, 4 do
        nx = nx + math.noise(t * freq, 0, 0) * amp
        ny = ny + math.noise(0, t * freq, 0) * amp
        nz = nz + math.noise(0, 0, t * freq) * amp
        freq = freq * 2.37; amp = amp * 0.5
    end
    local sp = t * 0.00073; local cp = t * 0.00213
    nx = nx + math.noise(sp + 13.7, 7.3, 0) * 0.3 + math.sin(cp) * math.cos(cp * 1.618) * 0.2
    ny = ny + math.noise(0, sp + 31.1, 17.9) * 0.3 + math.cos(cp * 0.618) * math.sin(cp * 2.718) * 0.2
    nz = nz + math.noise(7.3, 0, sp + 11.5) * 0.3 + math.sin(cp * 1.3) * math.cos(cp * 0.7) * 0.2
    local len = math.sqrt(nx * nx + ny * ny + nz * nz)
    if len < 0.001 then return 1, 0, 0 end
    return nx / len, ny / len, nz / len
end

local function stepVoidImplDrift(dt)
    local dx, dy, dz = driftDir3D(voidElapsed)
    voidDriftDir = voidDriftDir:Lerp(Vector3.new(dx, dy, dz).Unit, math.clamp(CFG.CHAOS * dt * 10, 0, 1))
    voidPos = voidPos + voidDriftDir * CFG.SPEED * dt
    if voidPos.X > CFG.BASE_X + CFG.RADIUS or voidPos.X < CFG.BASE_X - CFG.RADIUS then
        voidDriftDir = Vector3.new(-voidDriftDir.X, voidDriftDir.Y, voidDriftDir.Z) end
    if voidPos.Y > CFG.VOID_Y_MAX or voidPos.Y < CFG.VOID_Y_MIN then
        voidDriftDir = Vector3.new(voidDriftDir.X, -voidDriftDir.Y, voidDriftDir.Z) end
    if voidPos.Z > CFG.BASE_Z + CFG.RADIUS or voidPos.Z < CFG.BASE_Z - CFG.RADIUS then
        voidDriftDir = Vector3.new(voidDriftDir.X, voidDriftDir.Y, -voidDriftDir.Z) end
    return voidPos
end

local function stepVoidImplChaos(dt)
    voidPos = voidPos + Vector3.new(
        (math.random() - 0.5) * CFG.SPEED * dt * 5,
        (math.random() - 0.5) * CFG.SPEED * dt * 5,
        (math.random() - 0.5) * CFG.SPEED * dt * 5
    )
    voidPos = Vector3.new(
        math.clamp(voidPos.X, CFG.BASE_X - CFG.RADIUS, CFG.BASE_X + CFG.RADIUS),
        math.clamp(voidPos.Y, CFG.VOID_Y_MIN, CFG.VOID_Y_MAX),
        math.clamp(voidPos.Z, CFG.BASE_Z - CFG.RADIUS, CFG.BASE_Z + CFG.RADIUS)
    )
    return voidPos
end

local function stepVoidImplLoop(dt)
    local r = math.min(CFG.RADIUS * 0.8, 1e9 + (voidElapsed % 100) * 1e7)
    return Vector3.new(
        CFG.BASE_X + math.cos(voidElapsed * 2) * r,
        (CFG.VOID_Y_MIN + CFG.VOID_Y_MAX) / 2 + math.sin(voidElapsed * 1.3) * r * 0.2,
        CFG.BASE_Z + math.sin(voidElapsed * 2) * r
    )
end

local function stepVoidImplSpiral(dt)
    local r = math.min(CFG.RADIUS * 0.9, (voidElapsed % 50) * 2e9)
    return Vector3.new(
        CFG.BASE_X + math.cos(voidElapsed * 3) * r,
        (CFG.VOID_Y_MIN + CFG.VOID_Y_MAX) / 2 + math.sin(voidElapsed * 0.5) * r * 0.3,
        CFG.BASE_Z + math.sin(voidElapsed * 3) * r
    )
end

local function stepVoidImplQuantum(dt)
    local rx = (math.random() * 2 - 1) * CFG.RADIUS
    local ry = (math.random() * 2 - 1) * (CFG.VOID_Y_MAX - CFG.VOID_Y_MIN) / 2 + (CFG.VOID_Y_MAX + CFG.VOID_Y_MIN) / 2
    local rz = (math.random() * 2 - 1) * CFG.RADIUS
    return Vector3.new(CFG.BASE_X + rx, ry, CFG.BASE_Z + rz)
end

local function stepVoidImplTpEverywhere(dt)
    if not getTpEverywherePosition then return voidPos end
    return getTpEverywherePosition()
end

local function stepVoidImplOrbitTarget(dt)
    local t = getClosest()
    if t and t.Character then
        local hrp = t.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local ang = voidElapsed * math.rad(CFG.VOID_ORBIT_SPEED)
            return hrp.Position + Vector3.new(math.cos(ang) * 5, 2, math.sin(ang) * 5)
        end
    end
    return stepVoidImplTpEverywhere(dt)
end

local function stepVoidImplPredictive(dt)
    if not buildThreatMap then return voidPos end
    local map = buildThreatMap(root and root.Position or Vector3.zero)
    local best, bestScore = nil, -1
    for _, d in pairs(map) do
        if d.score > bestScore then bestScore = d.score; best = d end
    end
    if best and best.hrp then
        return best.hrp.Position - best.hrp.CFrame.LookVector * 50 + Vector3.new((math.random() - 0.5) * 100, (math.random() - 0.5) * 100, (math.random() - 0.5) * 100)
    end
    return stepVoidImplTpEverywhere(dt)
end

local stepVoidImpls = {
    Drift = stepVoidImplDrift,
    Chaos = stepVoidImplChaos,
    Loop = stepVoidImplLoop,
    Spiral = stepVoidImplSpiral,
    Quantum = stepVoidImplQuantum,
    ["TP Everywhere"] = stepVoidImplTpEverywhere,
    OrbitTarget = stepVoidImplOrbitTarget,
    Predictive = stepVoidImplPredictive,
}

local function stepVoid(dt)
    local impl = stepVoidImpls[CFG.VOID_METHOD]
    if impl then return impl(dt) end
    return stepVoidImplQuantum(dt)
end


local function runSmartEvasionV2(currentPos)
    if not CFG.SMART_EVASION or not root then return currentPos end
    local now = tick()
    local map = buildThreatMap(currentPos)
    local threats = {}
    local totalScore = 0
    for _, d in pairs(map) do
        if d.dist <= CFG.EVASION_RANGE and d.score > 20 then
            table.insert(threats, d)
            totalScore = totalScore + d.score
        end
    end
    if #threats == 0 then return currentPos end

    local cd = CFG.EVASION_COOLDOWN
    if CFG.EVASION_THREAT_SCALE then cd = cd / math.max(1, #threats * 0.5) end
    if now - smartLastDodge < cd then return currentPos end

    local primary = threats[1]
    for _, d in ipairs(threats) do
        if d.score > primary.score then primary = d end
    end

    local dodgeDir = perpDodgeDir(primary.hrp.Position, currentPos)
    local dodge = dodgeDir * CFG.EVASION_DODGE_POWER

    if CFG.EVASION_LAYERED and #threats > 1 then
        local cumulative = Vector3.zero
        for _, d in ipairs(threats) do
            cumulative = cumulative + perpDodgeDir(d.hrp.Position, currentPos) * (d.score / totalScore)
        end
        if cumulative.Magnitude > 0.01 then dodge = cumulative.Unit * CFG.EVASION_DODGE_POWER end
    end

    if CFG.EVASION_MICRO_JITTER then
        dodge = dodge + Vector3.new((math.random() - 0.5) * 15, 0, (math.random() - 0.5) * 15)
    end

    local finalPos = currentPos + dodge
    if CFG.EVASION_VERTICAL_SPIKE and #threats >= 2 then
        finalPos = finalPos + Vector3.new(0, (math.random() * 20 + 10), 0)
    end

    smartLastDodge = now
    if CFG.EVASION_NOTIFY then pcall(function() Notify("evasion v2: " .. (primary.hrp and primary.hrp.Parent and primary.hrp.Parent.Name or "?") .. " score " .. math.floor(primary.score), 1.2) end) end
    return finalPos
end

local function voidSafeFilter(pos)
    if not pos then return pos end
    if typeof and typeof(pos) ~= "Vector3" then return pos end
    local x, y, z = pos.X, pos.Y, pos.Z
    if x ~= x or x == math.huge or x == -math.huge then x = CFG.BASE_X end
    if y ~= y or y == math.huge or y == -math.huge then y = 0 end
    if z ~= z or z == math.huge or z == -math.huge then z = CFG.BASE_Z end
    y = math.clamp(y, CFG.VOID_Y_MIN, CFG.VOID_Y_MAX)
    local r = math.abs(CFG.RADIUS)
    if r > 0 then
        local dx, dz = x - CFG.BASE_X, z - CFG.BASE_Z
        local flat = math.sqrt(dx * dx + dz * dz)
        if flat > r and flat > 0 then
            local s = r / flat
            x = CFG.BASE_X + dx * s
            z = CFG.BASE_Z + dz * s
        end
    end
    if CFG.VOID_SAFE_RADIUS and CFG.VOID_SAFE_RADIUS > 0 and root then
        local me = root.Position
        local ddx, ddy, ddz = x - me.X, y - me.Y, z - me.Z
        local dist = math.sqrt(ddx * ddx + ddy * ddy + ddz * ddz)
        local sr = CFG.VOID_SAFE_RADIUS
        if dist < sr then
            if dist < 0.01 then ddx, ddy, ddz, dist = 1, 0, 0, 1 end
            local s = sr / dist
            x = me.X + ddx * s
            y = me.Y + ddy * s
            z = me.Z + ddz * s
        end
    end
    return Vector3.new(x, y, z)
end

local function lockToVoid(dt)
    local targetPos = stepVoid(dt)
    targetPos = voidSafeFilter(targetPos)
    targetPos = clampToRegion(targetPos)

    if CFG.VOID_ANTIVOID and isInsideVoidPart(targetPos) then
        targetPos = targetPos + Vector3.new((math.random() - 0.5) * 200, math.random() * 200, (math.random() - 0.5) * 200)        end

    targetPos = runSmartEvasionV2(targetPos)
    intendedVoidPos = targetPos
    local hrp = getLocalRoot()
    if not hrp then return end
    voidPredBest = nil; voidPredBestTile = nil

    if CFG.VOID_FREEZE_ON_GROUND then lastGroundY = hrp.Position.Y end

    pcall(function()
        hrp.CFrame = CFrame.new(intendedVoidPos)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.Velocity = Vector3.zero
    end)

    if CFG.VOID_LOG_POSITIONS and math.random(1, 30) == 1 then
        print("[VOID] " .. tostring(intendedVoidPos))
    end

    if not CFG.VOID_ANTIFLING and math.random(1, 10) == 1 then
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.new(
                (math.random() - 0.5) * 2e7,
                (math.random() - 0.5) * 2e7,
                (math.random() - 0.5) * 2e7
            )
        end)
    end
end

function RCLR_Functions.startVoid()
    killConn("void")
    voidElapsed = 0
    voidStartTime = tick()
    voidRegionCurrentRadius = nil
    voidRegionLastIn = true
    local hrp = getLocalRoot()
    if hrp then voidPos = hrp.Position; intendedVoidPos = voidPos end
    pcall(function() if hrp then hrp:SetNetworkOwner(LocalPlayer) end end)
    conns.void = (RunService.PreSimulation or RunService.Heartbeat):Connect(function(dt)
        if not CFG.VOID_ENABLED then
            if CFG.VOID_AUTO_REENABLE and tick() > voidAutoReenableTime then
                voidAutoReenableTime = tick() + 0.5
                CFG.VOID_ENABLED = true
            else
                killConn("void"); return
            end
        end
        if CFG.VOID_DURATION_ENABLED then
            local dur = CFG.VOID_DURATION
            if CFG.VOID_RANDOM_DURATION then
                dur = CFG.VOID_DURATION_MIN + math.random() * (CFG.VOID_DURATION_MAX - CFG.VOID_DURATION_MIN)
            end
            if (tick() - voidStartTime) > dur then
                CFG.VOID_ENABLED = false
                pcall(function() Notify("void duration reached", 2) end)
                return
            end
        end
        if CFG.VOID_STOP_ON_DAMAGE and hum then
            if hum.Health < (hum.MaxHealth * 0.9) then
                CFG.VOID_ENABLED = false
                pcall(function() Notify("void disabled: damage taken", 2) end)
                return
            end
        end
        voidElapsed = voidElapsed + dt
        lockToVoid(dt)
    end)
end
function RCLR_Functions.stopVoid() killConn("void"); CFG.VOID_ENABLED = false end

local orbitAngle, orbitLocalElapsed, orbitCurrentRadius = 0, 0, 0
local orbitSnapTimer = 0

function RCLR_Functions.startOrbit()
    killConn("orbit")
    orbitAngle = 0; orbitLocalElapsed = 0; orbitCurrentRadius = cfg.orbitDist; orbitSnapTimer = 0
    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end) end
    conns.orbit = RunService.Heartbeat:Connect(function(dt)
        if not cfg.orbitEnabled then killConn("orbit"); return end
        if not root then return end
        if hum then pcall(function()
            if hum:GetState() ~= Enum.HumanoidStateType.Physics then
                hum:ChangeState(Enum.HumanoidStateType.Physics)
            end
        end) end

        local target = getTarget(cfg.orbitTarget)
        local targetPos = root.Position
        if target and target.Character then
            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hrp and (root.Position - hrp.Position).Magnitude <= cfg.orbitLockDist then
                targetPos = hrp.Position
                if cfg.orbitPredict then targetPos = targetPos + hrp.AssemblyLinearVelocity * cfg.orbitPredStr end
            end
        end

        local speed = cfg.orbitReverse and -cfg.orbitSpeed or cfg.orbitSpeed
        if cfg.orbitSpeedRandom then
            speed = (cfg.orbitSpeedRandMin + math.random() * (cfg.orbitSpeedRandMax - cfg.orbitSpeedRandMin))
            if cfg.orbitReverse then speed = -speed end
        end

        orbitAngle = (orbitAngle + math.rad(speed) * dt) % (2 * math.pi)
        orbitLocalElapsed = orbitLocalElapsed + dt

        local r = cfg.orbitRandRad and math.random(cfg.orbitRandMin, cfg.orbitRandMax) or cfg.orbitDist
        if cfg.orbitDistPulse then
            r = r + math.sin(orbitLocalElapsed * cfg.orbitDistPulseSpeed * 2 * math.pi) * cfg.orbitDistPulseAmp
        end

        local h = cfg.orbitHeight
        if cfg.orbitHeightOscillate then
            h = h + math.sin(orbitLocalElapsed * cfg.orbitHeightOscSpeed * 2 * math.pi) * cfg.orbitHeightOscAmp
        end

        local x, y, z = 0, 0, 0
        local ax = cfg.orbitAxis
        local om = cfg.orbitMode

        if om == "Circle" then
            if ax == "XZ" then x = math.cos(orbitAngle)*r; z = math.sin(orbitAngle)*r; y = h
            elseif ax == "XY" then x = math.cos(orbitAngle)*r; y = math.sin(orbitAngle)*r; z = h
            elseif ax == "YZ" then y = math.cos(orbitAngle)*r; z = math.sin(orbitAngle)*r; x = h end
        elseif om == "Figure 8" then
            x = math.sin(orbitAngle)*r; z = math.sin(orbitAngle)*math.cos(orbitAngle)*r*0.7; y = h
        elseif om == "Ellipse" then
            x = math.cos(orbitAngle)*r; z = math.sin(orbitAngle)*r*0.6; y = h
        elseif om == "Spiral In" then
            orbitCurrentRadius = math.max(1, orbitCurrentRadius - dt * cfg.orbitDist * 0.2)
            x = math.cos(orbitAngle)*orbitCurrentRadius; z = math.sin(orbitAngle)*orbitCurrentRadius; y = h
        elseif om == "Spiral Out" then
            orbitCurrentRadius = math.min(cfg.orbitDist*2, orbitCurrentRadius + dt * cfg.orbitDist * 0.2)
            x = math.cos(orbitAngle)*orbitCurrentRadius; z = math.sin(orbitAngle)*orbitCurrentRadius; y = h
        elseif om == "Bounce" then
            x = math.cos(orbitAngle)*r; z = math.sin(orbitAngle)*r; y = h + math.sin(orbitLocalElapsed*3)*5
        elseif om == "Lemniscate" then
            local denom = 1 + math.sin(orbitAngle)^2
            x = r*math.cos(orbitAngle)/denom; z = r*math.sin(orbitAngle)*math.cos(orbitAngle)/denom; y = h
        elseif om == "Infinity" then
            x = r*math.cos(orbitAngle); z = r*math.sin(2*orbitAngle)/2; y = h
        elseif om == "RandomOrbit" then
            local a = math.random()*2*math.pi; x = math.cos(a)*r; z = math.sin(a)*r; y = h
        end

        if cfg.orbitZigzag then
            x = x + math.sin(orbitLocalElapsed * cfg.orbitZigzagFreq * 2 * math.pi) * cfg.orbitZigzagAmp
        end

        x = x + cfg.orbitOffX; z = z + cfg.orbitOffZ
        local dst = targetPos + Vector3.new(x, y, z)

        if cfg.orbitSnapBack then
            orbitSnapTimer = orbitSnapTimer + dt
            if orbitSnapTimer >= cfg.orbitSnapInterval then
                orbitSnapTimer = 0
                dst = targetPos + Vector3.new(cfg.orbitOffX, h, cfg.orbitOffZ)
            end
        end

        local alpha = math.min(1, 1 - (1 - cfg.orbitLerp)^(dt * 60))
        local smooth = root.Position:Lerp(dst, alpha)

        pcall(function()
            if cfg.orbitFace then
                local cf = CFrame.new(smooth, Vector3.new(targetPos.X, smooth.Y, targetPos.Z))
                cf = cf * CFrame.Angles(math.rad(cfg.orbitPitchOff), math.rad(cfg.orbitYawOff), 0)
                root.CFrame = cf
            else
                root.CFrame = CFrame.new(smooth)
            end
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)
    end)
end
function RCLR_Functions.stopOrbit()
    killConn("orbit"); cfg.orbitEnabled = false
    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
end

local lastDodgeTick = 0
local predShootCD = {}
local predLastShot = 0
local predRungIndex = 0
local hookedActivate = {}
local hookedActivateCount = 0
local hookedRemotes = {}
-- set by the SAFE remote hook below; consumed by prediction as a global
-- "someone fired" signal (per-caller attribution needs getcallingscript,
-- which was the expensive + unsafe part that fought other UIs)
local lastRemoteFire = 0

local RIVALS_SHOT_REMOTE_HINTS = {
    "fire","shoot","attack","bullet","ray","hit","damage","combat",
    "weapon","gun","melee","swing","slash","stab","cast","castskill",
    "attackrequest","fireweapon","dealDamage","projectile","spawnbullet",
    "swingweapon","strike","slashblade","firebullet","shootbullet",
}

local function isShotRemote(name)
    local n = name:lower()
    for _, h in ipairs(RIVALS_SHOT_REMOTE_HINTS) do
        if n:find(h, 1, true) then return true end
    end
    return false
end

local function raycastLineOfFire(enemyHrp, myPos)
    if not enemyHrp then return false, 0 end
    local origin = enemyHrp.Position + Vector3.new(0, 1.5, 0)
    local target = myPos + Vector3.new(0, 1.5, 0)
    local dir = (target - origin)
    local dist = dir.Magnitude
    if dist < 0.01 then return false, 0 end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, enemyHrp.Parent }
    local result = workspace:Raycast(origin, dir.Unit * dist, params)
    if result then return false, dist end
    return true, dist
end

local HOOK_CAP = 64
local function hookToolActivate(tool)
    if not tool or hookedActivate[tool] then return end
    -- unbounded hookfunction growth across respawns was a slow leak; cap it
    if hookedActivateCount >= HOOK_CAP then return end
    hookedActivate[tool] = true
    hookedActivateCount = hookedActivateCount + 1
    local oldActivate
    pcall(function()
        oldActivate = hookfunction(tool.Activate, function(self, ...)
            if not checkcaller() and self == tool then
                local owner = tool.Parent and tool.Parent.Parent
                if owner and owner ~= LocalPlayer and owner.Character then
                    predShootCD[owner] = tick()
                    if antiBaitCFG.baitEnabled and antiBaitCFG.baitHookActivate then
                        local hrp = owner.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and root then
                            task.spawn(function() RCLR_Functions.doBaitCounter(owner, "tool") end)
                        end
                    end
                end
            end
            return oldActivate(self, ...)
        end)
    end)
end

local watchedRemotes = {}
local remoteHookInstalled = false

-- SAFETY: never rawset the shared instance metatable (setreadonly/rawset on
-- __namecall). That is exactly what hard-crashed the client when Unnamed
-- Enhancements — or any other script — also hooks __namecall: two writers on
-- one metatable, plus getcallingscript() on EVERY remote call game-wide.
-- If UE is present, or the executor has no safe hookmetamethod wrapper, the
-- remote hook is skipped entirely; tool + animation + aim detection still
-- cover shot detection on their own.
local function hookRemote(remote)
    if not remote or hookedRemotes[remote] then return end
    hookedRemotes[remote] = true
    if UE_PRESENT then return end
    if type(hookmetamethod) ~= "function" then return end
    watchedRemotes[remote] = true
    if remoteHookInstalled then return end
    remoteHookInstalled = true
    pcall(function()
        local wrap = (type(newcclosure) == "function") and newcclosure or function(f) return f end
        local old
        -- payload is a single set lookup + tick(): no arg scan, no player
        -- walk, no getcallingscript. Cost per foreign namecall ~= 0.
        old = hookmetamethod(game, "__namecall", wrap(function(self, ...)
            if watchedRemotes[self] then
                local caller = checkcaller and checkcaller()
                if not caller then lastRemoteFire = tick() end
            end
            return old(self, ...)
        end))
    end)
end

local function watchAllTools()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        local tool = p.Character:FindFirstChildOfClass("Tool")
        if tool then hookToolActivate(tool) end
        p.Character.ChildAdded:Connect(function(c)
            if c:IsA("Tool") then hookToolActivate(c) end
        end)
    end
end

local function scanUniversal()
    if not antiBaitCFG.universalRemotes and not antiBaitCFG.universalTools then return end
    -- game:GetDescendants() every few seconds is what hitched the client, badly
    -- once the void is bouncing around (the tree churns while the engine streams
    -- regions in and out). Scan only where tools and remotes live, with a budget.
    if CFG.VOID_ENABLED then return end
    local roots = { ReplicatedStorage }
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then roots[#roots + 1] = p.Character end
    end
    local budget = 4000
    for _, r in ipairs(roots) do
        for _, d in ipairs(r:GetDescendants()) do
            if budget <= 0 then return end
            budget = budget - 1
            if antiBaitCFG.universalTools and d:IsA("Tool") then
                hookToolActivate(d)
            elseif antiBaitCFG.universalRemotes and (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) then
                if isShotRemote(d.Name) then hookRemote(d) end
            end
        end
    end
end

local _scanLoopRunning = false
local function ensureScanLoop()
    if _scanLoopRunning then return end
    _scanLoopRunning = true
    task.spawn(function()
        while cfgDodge.predEnabled or antiBaitCFG.enabled do
            task.wait(math.max(antiBaitCFG.reScanInterval, 5))
            pcall(scanUniversal)
        end
        _scanLoopRunning = false
    end)
end

local function getAimAnimKeyword(track)
    local name = track.Animation and track.Animation.Name or ""
    local n = name:lower()
    if n:find("shoot") or n:find("fire") or n:find("attack")
        or n:find("swing") or n:find("slash") or n:find("stab")
        or n:find("punch") or n:find("cast") or n:find("thrust") then
        return true
    end
    return false
end

local animThreatCache = {}
local function animationThreat(plr)
    if not antiBaitCFG.universalAnimation then return false end
    -- GetPlayingAnimationTracks() per player per frame was expensive for no
    -- gain; the same answer is fine for a tenth of a second.
    local now = tick()
    local cached = animThreatCache[plr]
    if cached and (now - cached.t) < 0.15 then return cached.v end
    local v = false
    local char = plr.Character
    if char then
        local h = char:FindFirstChildOfClass("Humanoid")
        local animator = h and h:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if getAimAnimKeyword(track) then v = true; break end
            end
        end
    end
    animThreatCache[plr] = { t = now, v = v }
    return v
end

local function watchAnimation(plr)
    if not plr.Character then return end
    local h = plr.Character:FindFirstChildOfClass("Humanoid")
    if not h then return end
    h.AnimationPlayed:Connect(function(track)
        if getAimAnimKeyword(track) then
            predShootCD[plr] = tick()
            if antiBaitCFG.baitEnabled then
                task.spawn(function() RCLR_Functions.doBaitCounter(plr, "anim") end)
            end
        end
    end)
end

local function startPredictionV2()
    killConn("pred")
    watchAllTools()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then watchAnimation(p) end
    end
    ensureScanLoop()
    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(c)
            c.ChildAdded:Connect(function(ch)
                if ch:IsA("Tool") then hookToolActivate(ch) end
            end)
            local tool = c:FindFirstChildOfClass("Tool")
            if tool then hookToolActivate(tool) end
            watchAnimation(p)
        end)
    end)

    conns.pred = RunService.Heartbeat:Connect(function(dt)
        if not cfgDodge.predEnabled then killConn("pred"); return end
        if not root then return end
        if hum and hum.Health <= 0 then return end
        local myPos = root.Position
        local now = tick()
        local map = buildThreatMap(myPos)
        local highestScore = 0
        local primary = nil
        for p, d in pairs(map) do
            if d.score > highestScore then highestScore = d.score; primary = { p = p, d = d } end
        end
        if not primary then return end

        local effectiveRadius = cfgDodge.predInfiniteRange and getInfiniteRange() or cfgDodge.predRadius
        if primary.d.dist > effectiveRadius then return end

        local cooldown = cfgDodge.predCooldown
        if cfgDodge.predReactionLadder then
            if now - predLastShot < 1.5 then predRungIndex = math.min(predRungIndex + 1, 5) else predRungIndex = 0 end
            cooldown = cooldown / (1 + predRungIndex * 0.5)
        end
        if now - lastDodgeTick < cooldown then return end

        local threat = false
        local fired = (predShootCD[primary.p] and (now - predShootCD[primary.p]) < cfgDodge.predReactTime)
            or (lastRemoteFire > 0 and (now - lastRemoteFire) < cfgDodge.predReactTime)
        if fired then threat = true end
        if primary.d.aimDot > cfgDodge.predShootDot then threat = true end
        if primary.d.velDot > 0.7 and primary.d.hrp.AssemblyLinearVelocity.Magnitude > cfgDodge.predThreshold then threat = true end

        if cfgDodge.predRaycast then
            local clear = raycastLineOfFire(primary.d.hrp, myPos)
            if clear and primary.d.aimDot > 0.6 then threat = true end
        end

        if cfgDodge.predPredictiveAim and not threat then
            local prediction = predictEnemyAim(primary.p, cfgDodge.predPredictiveLead, root)
            if prediction and prediction.futureDot > 0.85 and prediction.dist < effectiveRadius then
                threat = true
            end
        end

        if cfgDodge.predAnimDetect and not threat then
            if animationThreat(primary.p) then threat = true end
        end

        if not threat then return end

        lastDodgeTick = now
        predLastShot = now
        local dir = perpDodgeDir(primary.d.hrp.Position, myPos)
        local newPos = myPos + dir * cfgDodge.predDodgeDist

        if cfgDodge.predMultiPoint then
            local altDir = Vector3.new(-dir.Z, 0, dir.X)
            if math.random() < 0.5 then altDir = -altDir end
            newPos = myPos + dir * (cfgDodge.predDodgeDist * 0.7) + altDir * (cfgDodge.predDodgeDist * 0.5)
        end

        if cfgDodge.predBackstep then
            local toward = (primary.d.hrp.Position - myPos)
            if toward.Magnitude > 0.01 then newPos = newPos - toward.Unit * (cfgDodge.predDodgeDist * 0.3) end
        end

        if cfgDodge.predMultiPoint then newPos = newPos + Vector3.new(0, math.random() * 15, 0) end

        -- single write, budgeted: the old 3x Heartbeat:Wait() chain inside
        -- this Heartbeat callback froze the client under multi-threat pressure
        if tryDodgeFrame() then
            pcall(function()
                root.CFrame = CFrame.new(newPos + Vector3.new((math.random() - 0.5) * 4, 0, (math.random() - 0.5) * 4))
                root.AssemblyLinearVelocity = dir * 150
            end)
        end
        if cfgDodge.predNotifyAnywhere or primary.d.dist < 500 then
            pcall(function()
                local nm = primary.p and primary.p.Name or "?"
                local tag = fired and " [SHOT]" or (animationThreat(primary.p) and " [ANIM]" or " [AIM]")
            pcall(function() Notify("pred v2: " .. nm .. " [" .. math.floor(primary.d.dist) .. " studs]" .. tag, 1.5) end)
        end)
        end
    end)
end
function RCLR_Functions.stopPredictionV2() killConn("pred"); cfgDodge.predEnabled = false end

local antiBaitData = {}
local lastAntiBaitDodge = 0
local gunDodgeCDs = {}
local baitActive = {}

local function getDodgeDir(threatPos)
    if not root then return Vector3.new(1, 0, 0) end
    local flat = Vector3.new(threatPos.X - root.Position.X, 0, threatPos.Z - root.Position.Z)
    local away = flat.Magnitude > 0.01 and -flat.Unit or Vector3.new(1, 0, 0)
    local m = antiBaitCFG.dodgeMode
    if m == "Away" then return away end
    if m == "Perpendicular" then
        local p = Vector3.new(-away.Z, 0, away.X)
        return math.random(0, 1) == 0 and p or -p
    end
    local a = math.random() * 2 * math.pi
    return Vector3.new(math.cos(a), 0, math.sin(a))
end

local function doDodge(player, reason)
    if not root then return end
    local now = tick()
    if now - lastAntiBaitDodge < antiBaitCFG.dodgeCooldown then return end
    lastAntiBaitDodge = now
    local threatPos = Vector3.zero
    if player and player.Character then
        local h = player.Character:FindFirstChild("HumanoidRootPart")
        if h then threatPos = h.Position end
    end
    local dir = getDodgeDir(threatPos)
    -- one teleport write per dodge, capped per frame; the old 3x
    -- Heartbeat:Wait() chain here was the #1 freeze with UE + a full lobby
    if tryDodgeFrame() then
        pcall(function()
            root.CFrame = root.CFrame + dir * (antiBaitCFG.velDodgeDist * 0.005)
            root.AssemblyLinearVelocity = dir * 180
        end)
    end
    if antiBaitCFG.notifyOnDodge then
        local dist = 0
        if player and player.Character then
            local h = player.Character:FindFirstChild("HumanoidRootPart")
            if h and root then dist = math.floor((h.Position - root.Position).Magnitude) end
        end
        pcall(function() Notify("anti-bait: " .. (player and player.Name or "?") .. " [" .. reason .. "] " .. dist .. " studs", 1.5) end)
    end
end

local function baitStall(player)
    if not root then return end
    task.spawn(function()
        local orig = root.CFrame
        pcall(function() root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero end)
        task.wait(antiBaitCFG.baitStallTime)
        if root then pcall(function() root.CFrame = orig end) end
    end)
end

function RCLR_Functions.doBaitCounter(player, source)
    if not antiBaitCFG.baitEnabled then return end
    if baitActive[player] and tick() - baitActive[player] < antiBaitCFG.baitReactionWindow then return end
    baitActive[player] = tick()
    if antiBaitCFG.baitNotifyLabel then Notify("BAIT CONFIRMED: " .. player.Name .. " [" .. source .. "]", 2) end
    task.spawn(function()
        if antiBaitCFG.baitStallChance > 0 and math.random() < antiBaitCFG.baitStallChance then
            baitStall(player)
        end
        task.wait(antiBaitCFG.baitFakeLockTime)
        doDodge(player, "bait-" .. source)
    end)
end

local function initBaitData(p)
    antiBaitData[p] = { lastPos = nil, tpTimes = {}, lastVel = Vector3.zero, lastTool = nil, lastYaw = 0, lastAim = 0 }
end

local function cleanBaitTimes(data)
    local now, clean = tick(), {}
    for _, t in ipairs(data.tpTimes) do
        if now - t < antiBaitCFG.flickerWindow then clean[#clean + 1] = t end
    end
    data.tpTimes = clean
end

local function installBaitHooks()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        local tool = p.Character:FindFirstChildOfClass("Tool")
        if tool then hookToolActivate(tool) end
        p.Character.ChildAdded:Connect(function(c) if c:IsA("Tool") then hookToolActivate(c) end end)
        watchAnimation(p)
    end
end

local function startAntiBaitV2()
    killConn("antiBait")
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then initBaitData(p) end
    end
    installBaitHooks()
    scanUniversal()
    ensureScanLoop()
    conns.antiBait = RunService.Heartbeat:Connect(function(dt)
        if not antiBaitCFG.enabled then RCLR_Functions.stopAntiBait(); return end
        if not root then return end
        local myPos = root.Position
        local now = tick()
        local effectiveAntiBaitRadius = antiBaitCFG.infiniteRange and antiBaitCFG.infiniteRadius or 500
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer or not p.Character then continue end
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            local data = antiBaitData[p]
            if not data then initBaitData(p); data = antiBaitData[p] end
            local curPos = hrp.Position
            local curVel = hrp.AssemblyLinearVelocity

            if antiBaitCFG.gunPredEnabled then
                local tool = p.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local aiming = enemyAimingUniversal(p, myPos, antiBaitCFG.gunPredDot)
                    local key = p.UserId
                    local predP = predictPos(hrp, antiBaitCFG.gunPredLead)
                    local predDist = (predP - myPos).Magnitude
                    if aiming and (curVel.Magnitude > antiBaitCFG.gunPredVelMin or predDist < effectiveAntiBaitRadius) then
                        if not gunDodgeCDs[key] or now - gunDodgeCDs[key] > antiBaitCFG.gunPredCooldown then
                            gunDodgeCDs[key] = now
                            doDodge(p, "gun")
                        end
                    end
                end
            end

            if antiBaitCFG.baitHookActivate then
                local fired = predShootCD[p] and (now - predShootCD[p]) < antiBaitCFG.baitReactionWindow
                if fired then
                    pcall(function() RCLR_Functions.doBaitCounter(p, "fire") end)
                end
            end

            if antiBaitCFG.dodgeOnShoot then
                local tool = p.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local look = hrp.CFrame.LookVector
                    local toMe = (myPos - hrp.Position)
                    if toMe.Magnitude > 0.01 then
                        local dot = look:Dot(toMe.Unit)
                        if dot > antiBaitCFG.shootLookThresh and data.lastTool ~= tool then
                            doDodge(p, "shoot"); data.lastTool = tool
                        end
                        data.lastAim = dot
                    end
                end
            end

            if antiBaitCFG.universalAim and enemyAimingUniversal(p, myPos, antiBaitCFG.gunPredDot) then
                if not gunDodgeCDs[p.UserId] or now - gunDodgeCDs[p.UserId] > antiBaitCFG.gunPredCooldown then
                    gunDodgeCDs[p.UserId] = now
                    doDodge(p, "aim")
                end
            end

            if antiBaitCFG.universalAnimation and animationThreat(p) then
                doDodge(p, "anim")
            end

            if antiBaitCFG.velSpikeEnabled and curVel.Magnitude > antiBaitCFG.velThreshold then
                local toMe = (myPos - curPos)
                if toMe.Magnitude > 0.01 and curVel.Unit:Dot(toMe.Unit) > 0.6 then doDodge(p, "vel-spike") end
            end

            if antiBaitCFG.flickerEnabled and data.lastPos then
                if (curPos - data.lastPos).Magnitude > antiBaitCFG.flickerTpDist then
                    data.tpTimes[#data.tpTimes + 1] = tick()
                end
                cleanBaitTimes(data)
                if #data.tpTimes >= antiBaitCFG.flickerMinTps then
                    data.tpTimes = {}; doDodge(p, "flicker")
                end
            end

            data.lastPos = curPos; data.lastVel = curVel; data.lastYaw = hrp.Orientation.Y
        end
    end)
end
function RCLR_Functions.stopAntiBait()
    killConn("antiBait"); antiBaitCFG.enabled = false
    antiBaitData = {}; gunDodgeCDs = {}; baitActive = {}
end

local translocConn, translocPreRender, translocRealCF = nil, nil, nil
local translocPingPongDir = 1
local translocWaveT = 0
local translocAltVert = 1
local translocPulseT = 0
local translocAcc = 0
local translocPingPongTimer = 0

local function getTranslocFakePos(realCF, index)
    local d = translocCFG.offsetDist
    local jmp = translocCFG.jitter and translocCFG.jitterAmp or 0
    if not realCF then return CFrame.new(root and root.Position or Vector3.zero) end
    local base = realCF.Position
    local ox, oy, oz = 0, 0, 0
    local m = translocCFG.offsetMode

    if translocCFG.wavePattern then
        translocWaveT = translocWaveT + 0.01
        d = d + math.sin(translocWaveT * translocCFG.waveFreq * 2 * math.pi) * translocCFG.waveAmp
    end
    if translocCFG.pingPong then d = d * translocPingPongDir end
    if translocCFG.cascadeOffset and index then d = d + (index - 1) * translocCFG.cascadeStep end
    if translocCFG.pulse then
        translocPulseT = translocPulseT + 0.01
        d = d + math.sin(translocPulseT * translocCFG.pulseSpeed * 2 * math.pi) * translocCFG.pulseAmp
    end

    if m == "Ahead" then
        local look = realCF.LookVector
        ox = look.X * d; oz = look.Z * d; oy = translocCFG.offsetY
    elseif m == "Behind" then
        local look = realCF.LookVector
        ox = -look.X * d; oz = -look.Z * d; oy = translocCFG.offsetY
    elseif m == "Perpendicular" then
        local right = realCF.RightVector
        local side = math.random() < 0.5 and 1 or -1
        ox = right.X * d * side; oz = right.Z * d * side; oy = translocCFG.offsetY
    elseif m == "Above" then
        ox = (math.random() - 0.5) * jmp; oy = math.abs(d) + translocCFG.offsetY; oz = (math.random() - 0.5) * jmp
    elseif m == "Below" then
        ox = (math.random() - 0.5) * jmp; oy = -math.abs(d) + translocCFG.offsetY; oz = (math.random() - 0.5) * jmp
    elseif m == "AboveBelow" then
        translocAltVert = -translocAltVert
        ox = (math.random() - 0.5) * jmp
        oy = translocAltVert * (math.abs(d) + translocCFG.altVertAmp) + translocCFG.offsetY
        oz = (math.random() - 0.5) * jmp
    elseif m == "MirrorX" then
        ox = -base.X + (math.random() - 0.5) * jmp; oy = translocCFG.offsetY; oz = (math.random() - 0.5) * jmp
    elseif m == "MirrorZ" then
        ox = (math.random() - 0.5) * jmp; oy = translocCFG.offsetY; oz = -base.Z + (math.random() - 0.5) * jmp
    elseif m == "Diagonal" then
        local ang = math.rad(translocCFG.diagonalAngle)
        ox = math.cos(ang) * d; oz = math.sin(ang) * d; oy = translocCFG.offsetY
    elseif m == "ScreenEdge" then
        local vp = Camera.ViewportSize
        local corners = {
            Vector2.new(0, 0), Vector2.new(vp.X, 0),
            Vector2.new(0, vp.Y), Vector2.new(vp.X, vp.Y)
        }
        local c = corners[math.random(1, 4)]
        local ray = Camera:ViewportPointToRay(c.X, c.Y, math.abs(d))
        return CFrame.new(ray.Origin)
    elseif m == "Orbit" then
        translocWaveT = translocWaveT + 0.02
        local ang = translocWaveT * math.rad(translocCFG.orbitSpeed)
        ox = math.cos(ang) * translocCFG.orbitRadius
        oz = math.sin(ang) * translocCFG.orbitRadius
        oy = translocCFG.offsetY
    elseif m == "ZoneEscape" then
        local dir = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
        return CFrame.new(base + dir * translocCFG.zoneEscapeRadius)
    end

    if translocCFG.spinFake then
        local spinAng = tick() * math.rad(translocCFG.spinFakeSpeed)
        local nx = ox * math.cos(spinAng) - oz * math.sin(spinAng)
        local nz = ox * math.sin(spinAng) + oz * math.cos(spinAng)
        ox = nx; oz = nz
    end

    return CFrame.new(base.X + ox, base.Y + oy, base.Z + oz)
end

function RCLR_Functions.startTransloc()
    if translocConn then translocConn:Disconnect() end
    if translocPreRender then translocPreRender:Disconnect() end
    translocRealCF = nil; translocPingPongDir = 1; translocWaveT = 0; translocAltVert = 1; translocPulseT = 0
    translocAcc = 0; translocPingPongTimer = 0

    if translocCFG.networkOwnerFix and root then
        pcall(function() root:SetNetworkOwner(LocalPlayer) end)
    end

    translocPreRender = RunService.PreRender:Connect(function()
        if not translocCFG.enabled or not root or not translocRealCF then return end
        if translocCFG.snapBack then
            root.CFrame = translocRealCF
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    translocConn = RunService.Heartbeat:Connect(function(dt)
        if not translocCFG.enabled then RCLR_Functions.stopTransloc(); return end
        if not root then return end
        translocRealCF = root.CFrame
        translocAcc = translocAcc + dt
        translocPingPongTimer = translocPingPongTimer + dt

        if translocCFG.pingPong and translocPingPongTimer > 0.5 then
            translocPingPongTimer = 0; translocPingPongDir = -translocPingPongDir
        end

        if translocCFG.autoDodge then
            for _, p in ipairs(Players:GetPlayers()) do
                if p == LocalPlayer or not p.Character then continue end
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                if (hrp.Position - root.Position).Magnitude < translocCFG.autoDodgeRadius then
                    local dir = (root.Position - hrp.Position)
                    if dir.Magnitude > 0.01 then dir = dir.Unit end
                    pcall(function()
                        root.CFrame = CFrame.new(root.Position + dir * 60)
                        root.AssemblyLinearVelocity = Vector3.zero
                    end)
                end
            end
        end

        local interval
        if translocCFG.randomFrequency then
            interval = 1 / (translocCFG.freqMin + math.random() * (translocCFG.freqMax - translocCFG.freqMin))
        else
            interval = 1 / math.max(translocCFG.frequency, 1)
        end
        if translocAcc < interval then return end
        translocAcc = translocAcc % interval

        local mt = getrawmetatable and getrawmetatable(root)
        local ni = mt and rawget(mt, "__newindex")
        local layerCount = math.max(translocCFG.layers, 1)
        local burstCount = translocCFG.burstMode and translocCFG.burstCount or 1

        for b = 1, burstCount do
            for i = 1, layerCount do
                local fcf = getTranslocFakePos(translocRealCF, i)
                local fv = Vector3.zero
                if translocCFG.fakeVel then
                    local mag = translocCFG.fakeVelMag
                    fv = Vector3.new((math.random()-0.5)*mag*2, (math.random()-0.5)*mag*2, (math.random()-0.5)*mag*2)
                end
                if ni then
                    pcall(ni, root, "CFrame", fcf)
                    pcall(ni, root, "AssemblyLinearVelocity", fv)
                else
                    pcall(function() root.CFrame = fcf; root.AssemblyLinearVelocity = fv end)
                end
            end
            if b < burstCount then task.wait(translocCFG.burstInterval) end
        end
    end)
end
function RCLR_Functions.stopTransloc()
    if translocConn then translocConn:Disconnect(); translocConn = nil end
    if translocPreRender then translocPreRender:Disconnect(); translocPreRender = nil end
    translocCFG.enabled = false; translocRealCF = nil
end


local aaAngAcc = 0; local aaJitter = 0; local aaRandTimer = 0; local aaRandMult = 1
local aaMicroTimer = 0; local aaRollAcc = 0; local aaBreatheAcc = 0

function RCLR_Functions.startAntiAim()
    killConn("antiAim")
    conns.antiAim = RunService.Heartbeat:Connect(function(dt)
        if not aaSettings.enabled then killConn("antiAim"); return end
        if not root then return end

        aaMicroTimer = aaMicroTimer + dt
        aaBreatheAcc = aaBreatheAcc + dt
        aaRollAcc = aaRollAcc + dt

        local spd = aaSettings.speed
        if aaSettings.randomSpeed then
            aaRandTimer = aaRandTimer + dt
            if aaRandTimer > 0.1 then aaRandTimer = 0; aaRandMult = 0.2 + math.random() * 0.8 end
            spd = spd * aaRandMult
        end

        local extraYaw = 0
        local extraPitch = 0
        if aaSettings.fakeAngle then extraYaw = extraYaw + aaSettings.fakeYaw; extraPitch = extraPitch + aaSettings.fakePitch end
        if aaSettings.breatheEffect then extraPitch = extraPitch + math.sin(aaBreatheAcc * aaSettings.breatheSpeed * 2 * math.pi) * aaSettings.breatheAmp end
        if aaSettings.microJitter and aaMicroTimer >= (1 / math.max(aaSettings.microJitterSpeed, 1)) then
            aaMicroTimer = 0
            extraYaw = extraYaw + (math.random() - 0.5) * aaSettings.microJitterAmp * 2
            extraPitch = extraPitch + (math.random() - 0.5) * aaSettings.microJitterAmp
        end
        if aaSettings.desyncMode then extraYaw = extraYaw + aaSettings.desyncOffset end
        if aaSettings.randomFlip and math.random() < aaSettings.flipChance then extraYaw = extraYaw + 180 end

        local rollAngle = 0
        if aaSettings.rollEnabled then rollAngle = (aaRollAcc * aaSettings.rollSpeed * math.pi / 180) % (2 * math.pi) end

        local m = aaSettings.mode
        if m == "Spin" then
            aaAngAcc = aaAngAcc + spd * dt
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(math.rad(extraPitch), math.rad(aaAngAcc + extraYaw), rollAngle)
        elseif m == "Jitter" then
            local p = aaSettings.jitterPitch and aaSettings.pitchAngle or 0
            local y = aaSettings.jitterYaw and aaSettings.yawAngle or 0
            root.CFrame = root.CFrame * CFrame.Angles(
                math.rad((aaJitter == 0 and p or -p) + extraPitch),
                math.rad((aaJitter == 0 and y or -y) + extraYaw), rollAngle)
            aaJitter = (aaJitter + 1) % 2
        elseif m == "Static" then
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(math.rad(aaSettings.staticPitch + extraPitch), math.rad(aaSettings.staticYaw + extraYaw), rollAngle)
        elseif m == "Up" then
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(math.rad(90 + extraPitch), math.rad(extraYaw), rollAngle)
        elseif m == "Down" then
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(math.rad(-90 + extraPitch), math.rad(extraYaw), rollAngle)
        elseif m == "Side" then
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(math.rad(extraPitch), math.rad(extraYaw), math.rad(90) + rollAngle)
        elseif m == "RandomSpin" then
            aaAngAcc = aaAngAcc + spd * dt * (math.random() * 2 - 1)
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(math.rad(aaSettings.customPitch + extraPitch), math.rad(aaAngAcc + extraYaw), rollAngle)
        elseif m == "Custom" then
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(math.rad(aaSettings.customPitch + extraPitch), math.rad(aaSettings.customYaw + extraYaw), rollAngle)
        end
    end)
end
function RCLR_Functions.stopAntiAim() killConn("antiAim"); aaSettings.enabled = false end

local riotGMTimer = 0; local riotGMAng = 0; local riotGMConn = nil

function RCLR_Functions.startRiotGodmode()
    if riotGMConn then riotGMConn:Disconnect() end
    riotGMTimer = 0; riotGMAng = 0
    riotGMConn = RunService.Heartbeat:Connect(function(dt)
        if not riotGodmodeCFG.enabled then RCLR_Functions.stopRiotGodmode(); return end
        local hrp = getLocalRoot()
        if not hrp then return end
        riotGMTimer = riotGMTimer + dt
        if riotGMTimer < riotGodmodeCFG.speed then return end
        riotGMTimer = 0
        local cur = hrp.Position
        local target = getClosest()

        local function pickPos(from)
            local a = math.random() * 2 * math.pi
            local dist = riotGodmodeCFG.minJump + math.random() * (riotGodmodeCFG.maxJump - riotGodmodeCFG.minJump)
            local hv = riotGodmodeCFG.heightVariance
            return from + Vector3.new(math.cos(a) * dist, math.random(-hv, hv), math.sin(a) * dist)
        end

        local newPos = cur
        if target and target.Character then
            local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
            if tHrp then
                if riotGodmodeCFG.avoidBullets and (cur - tHrp.Position).Magnitude < riotGodmodeCFG.evadeRange then
                    local dir = (cur - tHrp.Position).Unit
                    newPos = cur + dir * riotGodmodeCFG.bulletDodge
                else newPos = pickPos(cur) end
            else newPos = pickPos(cur) end
        else newPos = pickPos(cur) end

        if riotGodmodeCFG.groundSnap then newPos = Vector3.new(newPos.X, cur.Y, newPos.Z) end
        riotGMAng = (riotGMAng + riotGodmodeCFG.spinSpeed * dt) % 360
        local ax = riotGodmodeCFG.randomAxis and math.random(1, 3)
            or (riotGodmodeCFG.spinAxis == "X" and 1 or riotGodmodeCFG.spinAxis == "Y" and 2 or 3)
        local cf = CFrame.new(newPos)
        if ax == 1 then cf = cf * CFrame.Angles(math.rad(riotGMAng), 0, 0)
        elseif ax == 2 then cf = cf * CFrame.Angles(0, math.rad(riotGMAng), 0)
        else cf = cf * CFrame.Angles(0, 0, math.rad(riotGMAng)) end

        if riotGodmodeCFG.multiTp then
            for i = 1, riotGodmodeCFG.multiTpCount do
                local mp = pickPos(newPos)
                pcall(function() hrp.CFrame = CFrame.new(mp) * CFrame.Angles(0, math.rad(riotGMAng), 0); hrp.AssemblyLinearVelocity = Vector3.zero end)
                if i < riotGodmodeCFG.multiTpCount then task.wait(riotGodmodeCFG.multiTpDelay) end
            end
        end

        if riotGodmodeCFG.phaseMode then
            local acc2 = 0
            while acc2 < riotGodmodeCFG.speed do
                pcall(function() hrp.CFrame = cf; hrp.AssemblyLinearVelocity = Vector3.zero end)
                task.wait(riotGodmodeCFG.phaseInterval); acc2 = acc2 + riotGodmodeCFG.phaseInterval
            end
        else
            pcall(function() hrp.CFrame = cf; hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end)
        end
    end)
end
function RCLR_Functions.stopRiotGodmode()
    if riotGMConn then riotGMConn:Disconnect(); riotGMConn = nil end
    riotGodmodeCFG.enabled = false
end

local riotAbuserConn = nil; local riotAbuserOrbAng = 0

function RCLR_Functions.startRiotAbuser()
    if riotAbuserConn then riotAbuserConn:Disconnect() end
    riotAbuserOrbAng = 0
    riotAbuserConn = RunService.Heartbeat:Connect(function(dt)
        if not riotAbuserCFG.enabled then RCLR_Functions.stopRiotAbuser(); return end
        local hrp = getLocalRoot()
        if not hrp then return end
        local target = riotAbuserCFG.multiTarget and getTarget("Random") or getClosest()
        if not target or not target.Character then return end
        local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not tHrp then return end
        local cf = tHrp.CFrame
        local tPos = riotAbuserCFG.predictTarget and predictPos(tHrp, riotAbuserCFG.predictLead) or tHrp.Position
        local mode = riotAbuserCFG.mode
        local rOff = riotAbuserCFG.randomOffset
            and Vector3.new((math.random()-0.5)*riotAbuserCFG.randomOffAmp*2, 0, (math.random()-0.5)*riotAbuserCFG.randomOffAmp*2)
            or Vector3.zero
        if mode == "Stick" then
            local off = cf.RightVector*riotAbuserCFG.right + cf.UpVector*(riotAbuserCFG.height-riotAbuserCFG.down) + cf.LookVector*riotAbuserCFG.forward + rOff
            hrp.CFrame = CFrame.new(tPos + off)
        elseif mode == "Bounce" then
            local bounce = math.abs(math.sin(tick()*riotAbuserCFG.bounceSpeed)) * riotAbuserCFG.bounceHeight
            local off = cf.RightVector*riotAbuserCFG.right + cf.UpVector*(bounce-riotAbuserCFG.down) + cf.LookVector*riotAbuserCFG.forward + rOff
            hrp.CFrame = CFrame.new(tPos + off)
        elseif mode == "Orbit" then
            riotAbuserOrbAng = (riotAbuserOrbAng + math.rad(riotAbuserCFG.orbitSpeed)*dt) % (2*math.pi)
            local off = Vector3.new(math.cos(riotAbuserOrbAng)*riotAbuserCFG.orbitRadius, riotAbuserCFG.orbitHeight, math.sin(riotAbuserOrbAng)*riotAbuserCFG.orbitRadius)
            hrp.CFrame = CFrame.new(tPos + off)
        elseif mode == "Phase" then
            local pDir = cf.LookVector * riotAbuserCFG.phaseOffset
            local side = math.random(0, 1) == 0 and 1 or -1
            local off = cf.RightVector*riotAbuserCFG.right*side + cf.UpVector*(riotAbuserCFG.height-riotAbuserCFG.down) + pDir + rOff
            hrp.CFrame = CFrame.new(tPos + off)
        end
        if riotAbuserCFG.spinOnTarget then
            local sa = (tick()*riotAbuserCFG.spinSpeed) % 360
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(sa), 0)
        end
        if riotAbuserCFG.forceFaceTarget then
            local look = tHrp.Position - hrp.Position
            if look.Magnitude > 0.1 then hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(look.X, 0, look.Z)) end
        end
        hrp.AssemblyLinearVelocity = tHrp.AssemblyLinearVelocity
        hrp.AssemblyAngularVelocity = Vector3.zero
        if riotAbuserCFG.autoShoot then
            local now = tick()
            if (hrp.Position - tHrp.Position).Magnitude < riotAbuserCFG.attackRange and now - riotAbuserCFG.lastShot > riotAbuserCFG.shootCooldown then
                riotAbuserCFG.lastShot = now
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate(); task.wait(0.02); tool:Deactivate() end) end
            end
        end
    end)
end
function RCLR_Functions.stopRiotAbuser()
    if riotAbuserConn then riotAbuserConn:Disconnect(); riotAbuserConn = nil end
    riotAbuserCFG.enabled = false
end

local function bindChar(c)
    char = c; root = c:WaitForChild("HumanoidRootPart", 5); hum = c:WaitForChild("Humanoid", 5)
    if CFG.VOID_ENABLED then RCLR_Functions.startVoid() end
    if cfg.orbitEnabled then RCLR_Functions.startOrbit() end
    if cfgDodge.predEnabled then startPredictionV2() end
    if antiBaitCFG.enabled then startAntiBaitV2() end
    if aaSettings.enabled then RCLR_Functions.startAntiAim() end
    if translocCFG.enabled then RCLR_Functions.startTransloc() end
    if riotGodmodeCFG.enabled then RCLR_Functions.startRiotGodmode() end
    if riotAbuserCFG.enabled then RCLR_Functions.startRiotAbuser() end
end

if LocalPlayer.Character then bindChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(c) task.wait(0.3); bindChar(c) end)
LocalPlayer.CharacterRemoving:Connect(function()
    killConn("void"); killConn("orbit"); killConn("pred"); killConn("antiAim")
    killConn("antiBait")
    if translocConn then translocConn:Disconnect(); translocConn = nil end
    if translocPreRender then translocPreRender:Disconnect(); translocPreRender = nil end
    if riotGMConn then riotGMConn:Disconnect(); riotGMConn = nil end
    if riotAbuserConn then riotAbuserConn:Disconnect(); riotAbuserConn = nil end
    root = nil; hum = nil; char = nil
    antiBaitData = {}
    translocRealCF = nil
end)

local coordsGui
local Tabs = {
    VoidSpam      = Window:AddTab("VoidSpam",     "activity"),
    Orbit         = Window:AddTab("Orbit",        "refresh-cw"),
    Prediction    = Window:AddTab("Prediction",   "crosshair"),
    Defense       = Window:AddTab("Defense",      "shield"),
    Translocation = Window:AddTab("Translocation","move"),
    Riot          = Window:AddTab("Riot",         "flame"),
    Rage          = Window:AddTab("Rage",         "zap"),
    Settings      = Window:AddTab("Settings",     "settings"),
}
do
local VG = Tabs.VoidSpam:AddLeftGroupbox("Void Control")
AddBindableToggle(VG, "VoidToggle", "Enable Void", false, function(v) CFG.VOID_ENABLED = v; if v then RCLR_Functions.startVoid() else RCLR_Functions.stopVoid() end end)
VG:AddDropdown("VoidMethod", { Text = "Method", Default = "Quantum", Values = {"Drift","Chaos","Loop","Spiral","Quantum","TP Everywhere","OrbitTarget","Predictive"}, Callback = function(v) CFG.VOID_METHOD = v end })
VG:AddSlider("Speed",    { Text = "Speed",        Default = 1,        Min = 0.001, Max = 1, Rounding = 3, Callback = function(v) CFG.SPEED = v * 1e9 end })
VG:AddSlider("Chaos",    { Text = "Chaos (%)",   Default = 98,   Min = 1, Max = 100,  Rounding = 0, Callback = function(v) CFG.CHAOS = v * 0.01 end })
VG:AddSlider("BaseX",    { Text = "Base X",      Default = 0,    Min = -1e15, Max = 1e15, Rounding = 0, Callback = function(v) CFG.BASE_X = v end })
VG:AddSlider("BaseY",    { Text = "Base Y",      Default = 0,    Min = -1e15, Max = 1e15, Rounding = 0, Callback = function(v) CFG.BASE_Y = v end })
VG:AddSlider("BaseZ",    { Text = "Base Z",      Default = 0,    Min = -1e15, Max = 1e15, Rounding = 0, Callback = function(v) CFG.BASE_Z = v end })
VG:AddSlider("VoidYMin", { Text = "Y Min",       Default = -1e15,Min = -1e15, Max = 1e15, Rounding = 0, Callback = function(v) CFG.VOID_Y_MIN = v end })
VG:AddSlider("VoidYMax", { Text = "Y Max",       Default = 1e15, Min = -1e15, Max = 1e15, Rounding = 0, Callback = function(v) CFG.VOID_Y_MAX = v end })
VG:AddSlider("Radius",   { Text = "Radius (studs)", Default = 1e11, Min = 1, Max = 1e15, Rounding = 0, Callback = function(v) CFG.RADIUS = v end })
end

do
local VX = Tabs.VoidSpam:AddRightGroupbox("Void Options")
AddBindableToggle(VX, "VoidAntifling",    "Anti-Fling",          true,  function(v) CFG.VOID_ANTIFLING = v end)
AddBindableToggle(VX, "VoidAutoReenable", "Auto Reenable",       false, function(v) CFG.VOID_AUTO_REENABLE = v end)
AddBindableToggle(VX, "VoidStopOnDamage", "Stop On Damage",      false, function(v) CFG.VOID_STOP_ON_DAMAGE = v end)
AddBindableToggle(VX, "VoidAntiVoid",     "Anti-Void (skip)",    false, function(v) CFG.VOID_ANTIVOID = v end)
AddBindableToggle(VX, "VoidOrbitTarget",  "Orbit Target",        false, function(v) CFG.VOID_ORBIT_TARGET = v end)
AddBindableToggle(VX, "VoidFreezeGround", "Freeze On Ground",    false, function(v) CFG.VOID_FREEZE_ON_GROUND = v end)
VX:AddSlider("VoidOrbitSpeed", { Text = "Orbit Speed (deg/s)",  Default = 90, Min = 1, Max = 720, Rounding = 0, Callback = function(v) CFG.VOID_ORBIT_SPEED = v end })
VX:AddSlider("VoidSafeRadius", { Text = "Safe Radius (studs)",  Default = 0,  Min = 0, Max = 200, Rounding = 0, Callback = function(v) CFG.VOID_SAFE_RADIUS = v end })
VX:AddSlider("VoidPredictLead",{ Text = "Predict Lead (x0.01s)",Default = 15, Min = 1, Max = 100, Rounding = 0, Callback = function(v) CFG.VOID_PREDICT_LEAD = v * 0.01 end })
end

do
local VE = Tabs.VoidSpam:AddLeftGroupbox("TP Everywhere")
AddBindableToggle(VE, "TpRandToggle",  "Randomize Studs",      true,  function(v) CFG.TP_RAND_ENABLED = v end)
AddBindableToggle(VE, "TpCornerOnly",  "Pin To Screen Corners", false, function(v) CFG.TP_CORNER_ONLY = v end)
VE:AddSlider("TpRandMin",    { Text = "Random Min Studs",  Default = -1e10, Min = -1e10, Max = 0,     Rounding = 0, Callback = function(v) CFG.TP_RAND_MIN = v end })
VE:AddSlider("TpRandMax",    { Text = "Random Max Studs",  Default = 1e10,  Min = 0,     Max = 1e10,  Rounding = 0, Callback = function(v) CFG.TP_RAND_MAX = v end })
VE:AddSlider("TpMinStuds",   { Text = "Fixed Min Studs",   Default = -1e10, Min = -1e10, Max = 0,     Rounding = 0, Callback = function(v) CFG.TP_MIN_STUDS = v end })
VE:AddSlider("TpMaxStuds",   { Text = "Fixed Max Studs",   Default = 1e10,  Min = 0,     Max = 1e10,  Rounding = 0, Callback = function(v) CFG.TP_MAX_STUDS = v end })
AddBindableToggle(VE, "TpVertSpike",   "Vertical Spike",      true,  function(v) CFG.TP_VERT_SPIKE = v end)
AddBindableToggle(VE, "TpNegBias",     "Negative Bias",       true,  function(v) CFG.TP_NEG_BIAS = v end)
AddBindableToggle(VE, "TpViewportRay", "Viewport Raycast",    true,  function(v) CFG.TP_VIEWPORT_RAY = v end)
AddBindableToggle(VE, "TpScreenClamp", "Clamp To Screen",     true,  function(v) CFG.TP_SCREEN_CLAMP = v end)
AddBindableToggle(VE, "TpPreserveY",   "Preserve Y",          false, function(v) CFG.TP_PRESERVE_Y = v end)
VE:AddSlider("TpVertMultExtra",{ Text = "Vert Spike Extra (x)", Default = 1.4,Min = 0, Max = 8,  Rounding = 1, Callback = function(v) CFG.TP_VERT_MULT_EXTRA = v end })
end

do
local OG = Tabs.Orbit:AddLeftGroupbox("Orbit")
AddBindableToggle(OG, "OrbitToggle", "Enable Orbit", false, function(v) cfg.orbitEnabled = v; if v then RCLR_Functions.startOrbit() else RCLR_Functions.stopOrbit() end end)
OG:AddDropdown("OrbitMode",   { Text = "Mode",   Default = "Circle",  Values = {"Circle","Figure 8","Ellipse","Spiral In","Spiral Out","Bounce","Lemniscate","Infinity","RandomOrbit"}, Callback = function(v) cfg.orbitMode = v; orbitCurrentRadius = cfg.orbitDist end })
OG:AddDropdown("OrbitTarget", { Text = "Target", Default = "Closest", Values = {"Closest","Random","Weakest","Strongest"}, Callback = function(v) cfg.orbitTarget = v end })
OG:AddDropdown("OrbitAxis",   { Text = "Axis",   Default = "XZ",      Values = {"XZ","XY","YZ"}, Callback = function(v) cfg.orbitAxis = v end })
OG:AddSlider("OrbitSpeed",  { Text = "Speed (deg/s)",  Default = 90,  Min = 5,    Max = 720, Rounding = 0, Callback = function(v) cfg.orbitSpeed = v end })
OG:AddSlider("OrbitDist",   { Text = "Radius",          Default = 8,   Min = 1,    Max = 200, Rounding = 0, Callback = function(v) cfg.orbitDist = v; orbitCurrentRadius = v end })
OG:AddSlider("OrbitHeight", { Text = "Height Offset",   Default = 0,   Min = -200, Max = 200, Rounding = 0, Callback = function(v) cfg.orbitHeight = v end })
OG:AddSlider("OrbitLerp",   { Text = "Smoothing",       Default = 30,  Min = 1,    Max = 100, Rounding = 0, Callback = function(v) cfg.orbitLerp = v / 100 end })
OG:AddSlider("OrbitOffX",   { Text = "X Offset",        Default = 0,   Min = -100, Max = 100, Rounding = 0, Callback = function(v) cfg.orbitOffX = v end })
OG:AddSlider("OrbitOffZ",   { Text = "Z Offset",        Default = 0,   Min = -100, Max = 100, Rounding = 0, Callback = function(v) cfg.orbitOffZ = v end })
AddBindableToggle(OG, "OrbitReverse",  "Reverse",       false, function(v) cfg.orbitReverse = v end)
AddBindableToggle(OG, "OrbitRandRad",  "Random Radius", false, function(v) cfg.orbitRandRad = v end)
OG:AddSlider("OrbitRandMin", { Text = "Min Rand Radius", Default = 5,  Min = 1, Max = 50, Rounding = 0, Callback = function(v) cfg.orbitRandMin = v end })
OG:AddSlider("OrbitRandMax", { Text = "Max Rand Radius", Default = 20, Min = 1, Max = 50, Rounding = 0, Callback = function(v) cfg.orbitRandMax = v end })
end

do
local PG = Tabs.Prediction:AddLeftGroupbox("Prediction V2")
AddBindableToggle(PG, "PredToggle", "Enable Prediction V2", false, function(v) cfgDodge.predEnabled = v; if v then startPredictionV2() else RCLR_Functions.stopPredictionV2() end end)
PG:AddSlider("PredRadius",    { Text = "Danger Radius",          Default = 120, Min = 5,   Max = 5000, Rounding = 0, Callback = function(v) cfgDodge.predRadius = v end })
PG:AddSlider("PredDodge",     { Text = "Dodge Distance",         Default = 80,  Min = 5,   Max = 500,  Rounding = 0, Callback = function(v) cfgDodge.predDodgeDist = v end })
PG:AddSlider("PredCooldown",  { Text = "Cooldown (ms)",          Default = 30,  Min = 10,  Max = 2000, Rounding = 0, Callback = function(v) cfgDodge.predCooldown = v / 1000 end })
PG:AddSlider("PredThreshold", { Text = "Speed Threshold",        Default = 300, Min = 100, Max = 5000, Rounding = 0, Callback = function(v) cfgDodge.predThreshold = v end })
PG:AddSlider("PredMult",      { Text = "Prediction Mult.",       Default = 1,   Min = 0,   Max = 10,   Rounding = 1, Suffix = "x", Callback = function(v) cfgDodge.predMult = v end })
PG:AddSlider("PredLeadTime",  { Text = "Lead Time (x0.01s)",     Default = 22,  Min = 1,   Max = 100,  Rounding = 0, Callback = function(v) cfgDodge.predLeadTime = v * 0.01 end })
PG:AddSlider("PredShootDot",  { Text = "Aim Threshold (%)",      Default = 80,  Min = 50,  Max = 99,   Rounding = 0, Callback = function(v) cfgDodge.predShootDot = v * 0.01 end })
PG:AddSlider("PredShootDist", { Text = "Shot Dodge Distance",    Default = 100, Min = 10,  Max = 500,  Rounding = 0, Callback = function(v) cfgDodge.predShootDist = v end })
PG:AddSlider("PredBulletSpd", { Text = "Enemy Bullet Speed",     Default = 200, Min = 50,  Max = 5000, Rounding = 0, Callback = function(v) cfgDodge.predBulletSpd = v end })
PG:AddSlider("PredReactTime", { Text = "Reaction Time (x0.01s)", Default = 6,   Min = 1,   Max = 50,   Rounding = 0, Callback = function(v) cfgDodge.predReactTime = v * 0.01 end })
AddBindableToggle(PG, "PredShootDetect",   "Detect Enemy Shooting",  true,  function(v) cfgDodge.predShootDetect = v end)
AddBindableToggle(PG, "PredRaycast",       "Raycast Line of Fire",   true,  function(v) cfgDodge.predRaycast = v end)
AddBindableToggle(PG, "PredMultiPoint",    "Multi-Point Dodge",      true,  function(v) cfgDodge.predMultiPoint = v end)
AddBindableToggle(PG, "PredBackstep",      "Backstep Dodge",         true,  function(v) cfgDodge.predBackstep = v end)
AddBindableToggle(PG, "PredReactionLadder","Reaction Ladder",        true,  function(v) cfgDodge.predReactionLadder = v end)
AddBindableToggle(PG, "PredThreatScore",   "Threat Scoring",         true,  function(v) cfgDodge.predThreatScore = v end)
AddBindableToggle(PG, "PredPredictiveAim", "Predictive Aim",         true,  function(v) cfgDodge.predPredictiveAim = v end)
PG:AddSlider("PredPredictiveLead",          { Text = "Predictive Aim Lead (x0.01s)", Default = 25, Min = 1, Max = 200, Rounding = 0, Callback = function(v) cfgDodge.predPredictiveLead = v * 0.01 end })
AddBindableToggle(PG, "PredAnimDetect",    "Animation Detect",       true,  function(v) cfgDodge.predAnimDetect = v end)
AddBindableToggle(PG, "PredInfiniteRange", "Infinite Range Prediction", false, function(v) cfgDodge.predInfiniteRange = v end)
AddBindableToggle(PG, "PredNotifyAnywhere","Notify At Any Distance", false, function(v) cfgDodge.predNotifyAnywhere = v end)
end

do
local PG2 = Tabs.Prediction:AddRightGroupbox("Anti Bait V2")
AddBindableToggle(PG2, "AntiBaitToggle", "Enable Anti Bait V2", false, function(v) antiBaitCFG.enabled = v; if v then startAntiBaitV2() else RCLR_Functions.stopAntiBait() end end)
PG2:AddDropdown("AntiBaitDodgeMode", { Text = "Dodge Mode", Default = "Perpendicular", Values = {"Perpendicular","Away","Random"}, Callback = function(v) antiBaitCFG.dodgeMode = v end })
AddBindableToggle(PG2, "AntiBaitBaitEnabled","Bait Enemy Shots",    true,  function(v) antiBaitCFG.baitEnabled = v end)
AddBindableToggle(PG2, "AntiBaitHookActivate","Hook Tool Activate", true,  function(v) antiBaitCFG.baitHookActivate = v end)
AddBindableToggle(PG2, "AntiBaitVel",        "Vel Spike Detect",    true,  function(v) antiBaitCFG.velSpikeEnabled = v end)
AddBindableToggle(PG2, "AntiBaitFlicker",    "Flicker Detect",      true,  function(v) antiBaitCFG.flickerEnabled = v end)
AddBindableToggle(PG2, "AntiBaitNotify",     "Notify on Dodge",     true,  function(v) antiBaitCFG.notifyOnDodge = v end)
AddBindableToggle(PG2, "AntiBaitNotifyLabel","Notify Bait Confirmed",true,  function(v) antiBaitCFG.baitNotifyLabel = v end)
AddBindableToggle(PG2, "AntiBaitShoot",      "Dodge On Shoot",      true,  function(v) antiBaitCFG.dodgeOnShoot = v end)
AddBindableToggle(PG2, "AntiBaitGunPredict", "Gun Prediction Dodge",true,  function(v) antiBaitCFG.gunPredEnabled = v end)
AddBindableToggle(PG2, "AntiBaitStall",      "Bait Stall",          true,  function(v) antiBaitCFG.baitStallChance = v and 0.4 or 0 end)
AddBindableToggle(PG2, "AntiBaitUniRemotes","Universal Remote Scan",true,  function(v) antiBaitCFG.universalRemotes = v end)
AddBindableToggle(PG2, "AntiBaitUniTools",  "Universal Tool Scan",  true,  function(v) antiBaitCFG.universalTools = v end)
AddBindableToggle(PG2, "AntiBaitUniAnim",   "Universal Animation",  true,  function(v) antiBaitCFG.universalAnimation = v end)
AddBindableToggle(PG2, "AntiBaitUniAim",    "Universal Aim",        true,  function(v) antiBaitCFG.universalAim = v end)
AddBindableToggle(PG2, "AntiBaitInfiniteRange","Infinite Range Anti-Bait",false, function(v) antiBaitCFG.infiniteRange = v end)
PG2:AddSlider("AntiBaitInfiniteRadius", { Text = "Infinite Radius (studs)", Default = 5e12, Min = 100, Max = 5e12, Rounding = 0, Callback = function(v) antiBaitCFG.infiniteRadius = v end })
PG2:AddSlider("AntiBaitReactionWindow", { Text = "Bait React Window (ms)", Default = 180, Min = 30, Max = 500, Rounding = 0, Callback = function(v) antiBaitCFG.baitReactionWindow = v * 0.001 end })
PG2:AddSlider("AntiBaitStallTime",  { Text = "Stall Time (ms)",    Default = 80,  Min = 20, Max = 300, Rounding = 0, Callback = function(v) antiBaitCFG.baitStallTime = v * 0.001 end })
PG2:AddSlider("AntiBaitFakeLock",   { Text = "Fake Lock Time (ms)", Default = 60, Min = 20, Max = 200, Rounding = 0, Callback = function(v) antiBaitCFG.baitFakeLockTime = v * 0.001 end })
PG2:AddSlider("AntiBaitGunDot",     { Text = "Gun Aim Threshold (%)",Default = 80, Min = 50, Max = 99,  Rounding = 0, Callback = function(v) antiBaitCFG.gunPredDot = v * 0.01 end })
PG2:AddSlider("AntiBaitGunDodge",   { Text = "Gun Dodge Distance",  Default = 100,Min = 10, Max = 500, Rounding = 0, Callback = function(v) antiBaitCFG.gunPredDodgeDist = v end })
PG2:AddSlider("AntiBaitGunCD",      { Text = "Gun Dodge CD (ms)",   Default = 20, Min = 10, Max = 500, Rounding = 0, Callback = function(v) antiBaitCFG.gunPredCooldown = v * 0.001 end })
PG2:AddSlider("AntiBaitGunLead",    { Text = "Gun Lead (x0.01s)",   Default = 18, Min = 1,  Max = 100, Rounding = 0, Callback = function(v) antiBaitCFG.gunPredLead = v * 0.01 end })
PG2:AddSlider("AntiBaitVelThresh",  { Text = "Vel Threshold",       Default = 200,Min = 100,Max = 2000,Rounding = 0, Callback = function(v) antiBaitCFG.velThreshold = v end })
PG2:AddSlider("AntiBaitDodgeDist",  { Text = "Dodge Distance",      Default = 100,Min = 5,  Max = 500, Rounding = 0, Callback = function(v) antiBaitCFG.velDodgeDist = v end })
PG2:AddSlider("AntiBaitCooldown",   { Text = "Cooldown (x0.1s)",    Default = 2,  Min = 1,  Max = 20,  Rounding = 0, Callback = function(v) antiBaitCFG.dodgeCooldown = v * 0.1 end })
PG2:AddSlider("AntiBaitTpCount",    { Text = "Min TPs to Confirm",  Default = 2,  Min = 2,  Max = 10,  Rounding = 0, Callback = function(v) antiBaitCFG.flickerMinTps = v end })
PG2:AddSlider("AntiBaitWindow",     { Text = "Flicker Window (x0.1s)",Default=3, Min = 1,  Max = 20,  Rounding = 0, Callback = function(v) antiBaitCFG.flickerWindow = v * 0.1 end })
PG2:AddSlider("AntiBaitTpDist",     { Text = "TP Delta (studs)",    Default = 10, Min = 5,  Max = 100, Rounding = 0, Callback = function(v) antiBaitCFG.flickerTpDist = v end })
PG2:AddSlider("AntiBaitRescan",     { Text = "Rescan Interval (s)", Default = 5, Min = 1, Max = 60, Rounding = 0, Callback = function(v) antiBaitCFG.reScanInterval = v end })
end

do
local AG = Tabs.Defense:AddLeftGroupbox("Anti-Aim")
AddBindableToggle(AG, "AaToggle", "Enable Anti-Aim", false, function(v) aaSettings.enabled = v; if v then RCLR_Functions.startAntiAim() else RCLR_Functions.stopAntiAim() end end)
AG:AddDropdown("AaMode", { Text = "Mode", Default = "RandomSpin", Values = {"Spin","Jitter","Static","Up","Down","Side","RandomSpin","Custom"}, Callback = function(v) aaSettings.mode = v end })
AG:AddSlider("AaSpeed",       { Text = "Speed (deg/s)",    Default = 5000, Min = 100, Max = 5000, Rounding = 0, Callback = function(v) aaSettings.speed = v end })
AG:AddSlider("AaPitchAngle",  { Text = "Pitch Angle",      Default = 45,   Min = 0,   Max = 90,   Rounding = 0, Callback = function(v) aaSettings.pitchAngle = v end })
AG:AddSlider("AaYawAngle",    { Text = "Yaw Angle",        Default = 45,   Min = 0,   Max = 180,  Rounding = 0, Callback = function(v) aaSettings.yawAngle = v end })
AG:AddSlider("AaStaticYaw",   { Text = "Static Yaw",       Default = 90,   Min = -180,Max = 180,  Rounding = 0, Callback = function(v) aaSettings.staticYaw = v end })
AG:AddSlider("AaStaticPitch", { Text = "Static Pitch",     Default = 0,    Min = -90, Max = 90,   Rounding = 0, Callback = function(v) aaSettings.staticPitch = v end })
AG:AddSlider("AaCustomYaw",   { Text = "Custom Yaw",       Default = 180,  Min = -180,Max = 180,  Rounding = 0, Callback = function(v) aaSettings.customYaw = v end })
AG:AddSlider("AaCustomPitch", { Text = "Custom Pitch",     Default = 0,    Min = -90, Max = 90,   Rounding = 0, Callback = function(v) aaSettings.customPitch = v end })
AddBindableToggle(AG, "AaRandomSpeed", "Randomize Speed",  true,  function(v) aaSettings.randomSpeed = v end)
AddBindableToggle(AG, "AaJitterPitch", "Jitter Pitch",     true,  function(v) aaSettings.jitterPitch = v end)
AddBindableToggle(AG, "AaJitterYaw",   "Jitter Yaw",       true,  function(v) aaSettings.jitterYaw = v end)
AddBindableToggle(AG, "AaFakeAngle",   "Fake Angle",       false, function(v) aaSettings.fakeAngle = v end)
AG:AddSlider("AaFakeYaw",     { Text = "Fake Yaw Offset",    Default = 45,  Min = -180, Max = 180, Rounding = 0, Callback = function(v) aaSettings.fakeYaw = v end })
AG:AddSlider("AaFakePitch",   { Text = "Fake Pitch Offset",  Default = 0,   Min = -90,  Max = 90,  Rounding = 0, Callback = function(v) aaSettings.fakePitch = v end })
AddBindableToggle(AG, "AaMicroJitter",  "Micro Jitter",     false, function(v) aaSettings.microJitter = v end)
AG:AddSlider("AaMicroJitterAmp",  { Text = "Micro Jitter Amp",    Default = 5,  Min = 0, Max = 45,  Rounding = 1, Callback = function(v) aaSettings.microJitterAmp = v end })
AG:AddSlider("AaMicroJitterSpd",  { Text = "Micro Jitter Speed",  Default = 30, Min = 1, Max = 120, Rounding = 0, Callback = function(v) aaSettings.microJitterSpeed = v end })
AddBindableToggle(AG, "AaDesyncMode",   "Desync Mode",      false, function(v) aaSettings.desyncMode = v end)
AG:AddSlider("AaDesyncOffset", { Text = "Desync Yaw Offset", Default = 180, Min = 0, Max = 360, Rounding = 0, Callback = function(v) aaSettings.desyncOffset = v end })
AddBindableToggle(AG, "AaRollEnabled",  "Roll Axis",        false, function(v) aaSettings.rollEnabled = v end)
AG:AddSlider("AaRollSpeed",    { Text = "Roll Speed (deg/s)", Default = 360, Min = 10, Max = 720, Rounding = 0, Callback = function(v) aaSettings.rollSpeed = v end })
AddBindableToggle(AG, "AaBreathe",      "Breathe Effect",   false, function(v) aaSettings.breatheEffect = v end)
AG:AddSlider("AaBreatheAmp",   { Text = "Breathe Amplitude", Default = 3, Min = 0, Max = 30, Rounding = 1, Callback = function(v) aaSettings.breatheAmp = v end })
AG:AddSlider("AaBreatheSpeed", { Text = "Breathe Speed",     Default = 1, Min = 0.1, Max = 10, Rounding = 1, Callback = function(v) aaSettings.breatheSpeed = v end })
AddBindableToggle(AG, "AaRandomFlip",   "Random Flip",      false, function(v) aaSettings.randomFlip = v end)
AG:AddSlider("AaFlipChance",   { Text = "Flip Chance (%)", Default = 5, Min = 1, Max = 50, Rounding = 0, Callback = function(v) aaSettings.flipChance = v * 0.01 end })
end

do
local SE = Tabs.Defense:AddRightGroupbox("Smart Evasion")
AddBindableToggle(SE, "SmartEvasionToggle", "Enable Smart Evasion", false, function(v) CFG.SMART_EVASION = v end)
AddBindableToggle(SE, "SmartEvasionInf", "Infinite Threat Range", false, function(v) CFG.SMART_EVASION_INF = v end)
SE:AddSlider("SmartEvasionRange",    { Text = "Threat Range (studs)", Default = 80,  Min = 10,  Max = 500, Rounding = 0, Callback = function(v) CFG.EVASION_RANGE = v end })
SE:AddSlider("SmartEvasionPower",    { Text = "Dodge Power",         Default = 100, Min = 5,   Max = 400, Rounding = 0, Callback = function(v) CFG.EVASION_DODGE_POWER = v end })
SE:AddSlider("SmartEvasionCooldown", { Text = "Cooldown (x0.01s)",   Default = 3,   Min = 1,   Max = 60,  Rounding = 0, Callback = function(v) CFG.EVASION_COOLDOWN = v * 0.01 end })
SE:AddSlider("SmartEvasionThreat",   { Text = "Threat Distance",     Default = 40,  Min = 5,   Max = 300, Rounding = 0, Callback = function(v) CFG.EVASION_THREAT_DIST = v end })
AddBindableToggle(SE, "SmartEvasionLayered",  "Layered Dodge",   true,  function(v) CFG.EVASION_LAYERED = v end)
AddBindableToggle(SE, "SmartEvasionJitter",   "Micro Jitter",    true,  function(v) CFG.EVASION_MICRO_JITTER = v end)
AddBindableToggle(SE, "SmartEvasionVert",     "Vertical Spike",  true,  function(v) CFG.EVASION_VERTICAL_SPIKE = v end)
AddBindableToggle(SE, "SmartEvasionNotify",   "Notify on Dodge", false, function(v) CFG.EVASION_NOTIFY = v end)
end

do
local TL = Tabs.Translocation:AddLeftGroupbox("Translocation")
AddBindableToggle(TL, "TranslocToggle", "Enable Translocation", false, function(v) translocCFG.enabled = v; if v then RCLR_Functions.startTransloc() else RCLR_Functions.stopTransloc() end end)
TL:AddDropdown("TranslocMode", { Text = "Offset Mode", Default = "Ahead", Values = {"Ahead","Behind","Perpendicular","Above","Below","AboveBelow","MirrorX","MirrorZ","Diagonal","ScreenEdge","Orbit","ZoneEscape"}, Callback = function(v) translocCFG.offsetMode = v end })
TL:AddSlider("TranslocFreq",   { Text = "Frequency (Hz)",    Default = 256,  Min = 1, Max = 1000, Rounding = 0, Callback = function(v) translocCFG.frequency = v end })
TL:AddSlider("TranslocDist",   { Text = "Offset Distance",   Default = 999000000000, Min = 1, Max = 1e15, Rounding = 0, Callback = function(v) translocCFG.offsetDist = v end })
TL:AddSlider("TranslocOffY",   { Text = "Y Offset",          Default = 0,    Min = -1e15, Max = 1e15, Rounding = 0, Callback = function(v) translocCFG.offsetY = v end })
TL:AddSlider("TranslocLayers", { Text = "Fake Layers",       Default = 5,    Min = 1, Max = 10, Rounding = 0, Callback = function(v) translocCFG.layers = v end })
AddBindableToggle(TL, "TranslocRandFreq",   "Random Frequency",  false, function(v) translocCFG.randomFrequency = v end)
TL:AddSlider("TranslocFreqMin",{ Text = "Freq Min",          Default = 50,   Min = 1, Max = 1000, Rounding = 0, Callback = function(v) translocCFG.freqMin = v end })
TL:AddSlider("TranslocFreqMax",{ Text = "Freq Max",          Default = 500,  Min = 1, Max = 1000, Rounding = 0, Callback = function(v) translocCFG.freqMax = v end })
AddBindableToggle(TL, "TranslocBurst",      "Burst Mode",        false, function(v) translocCFG.burstMode = v end)
TL:AddSlider("TranslocBurstCount",  { Text = "Burst Count",  Default = 10, Min = 2, Max = 50,  Rounding = 0, Callback = function(v) translocCFG.burstCount = v end })
TL:AddSlider("TranslocBurstInterval",{ Text = "Burst Interval (ms)",Default=1,Min=1,Max=100, Rounding = 0, Callback = function(v) translocCFG.burstInterval = v * 0.001 end })
end

do
local TLX = Tabs.Translocation:AddRightGroupbox("Translocation Options")
AddBindableToggle(TLX, "TranslocFakeVel",  "Fake Velocity",        true,  function(v) translocCFG.fakeVel = v end)
AddBindableToggle(TLX, "TranslocSnapBack", "Snap Back",            true,  function(v) translocCFG.snapBack = v end)
AddBindableToggle(TLX, "TranslocJitter",   "Position Jitter",      true,  function(v) translocCFG.jitter = v end)
TLX:AddSlider("TranslocVelMag",    { Text = "Fake Vel Magnitude",   Default = 1e10, Min = 1, Max = 1e15, Rounding = 0, Callback = function(v) translocCFG.fakeVelMag = v end })
TLX:AddSlider("TranslocJitterAmp", { Text = "Jitter Amplitude",     Default = 1e11, Min = 1, Max = 1e15, Rounding = 0, Callback = function(v) translocCFG.jitterAmp = v end })
AddBindableToggle(TLX, "TranslocSpinFake", "Spin Fake Position",    false, function(v) translocCFG.spinFake = v end)
TLX:AddSlider("TranslocSpinSpeed",  { Text = "Spin Speed (deg/s)",  Default = 720, Min = 10, Max = 3600, Rounding = 0, Callback = function(v) translocCFG.spinFakeSpeed = v end })
AddBindableToggle(TLX, "TranslocMirrorX",  "Mirror X",              false, function(v) translocCFG.mirrorX = v end)
AddBindableToggle(TLX, "TranslocMirrorZ",  "Mirror Z",              false, function(v) translocCFG.mirrorZ = v end)
AddBindableToggle(TLX, "TranslocCascade",  "Cascade Offset",        false, function(v) translocCFG.cascadeOffset = v end)
TLX:AddSlider("TranslocCascadeStep",{ Text = "Cascade Step",        Default = 1e11, Min = 1, Max = 1e15, Rounding = 0, Callback = function(v) translocCFG.cascadeStep = v end })
AddBindableToggle(TLX, "TranslocWave",     "Wave Pattern",          false, function(v) translocCFG.wavePattern = v end)
TLX:AddSlider("TranslocWaveAmp",    { Text = "Wave Amplitude",      Default = 1e11, Min = 1, Max = 1e15, Rounding = 0, Callback = function(v) translocCFG.waveAmp = v end })
AddBindableToggle(TLX, "TranslocPulse",    "Pulse",                 false, function(v) translocCFG.pulse = v end)
TLX:AddSlider("TranslocPulseAmp",   { Text = "Pulse Amplitude",     Default = 1e11, Min = 1, Max = 1e15, Rounding = 0, Callback = function(v) translocCFG.pulseAmp = v end })
AddBindableToggle(TLX, "TranslocPingPong", "Ping Pong",             false, function(v) translocCFG.pingPong = v end)
AddBindableToggle(TLX, "TranslocDiagonal", "Diagonal",              false, function(v) translocCFG.diagonal = v end)
TLX:AddSlider("TranslocDiagonalAngle",{ Text = "Diagonal Angle",    Default = 45,  Min = 0, Max = 360, Rounding = 0, Callback = function(v) translocCFG.diagonalAngle = v end })
AddBindableToggle(TLX, "TranslocAltVert",  "Alternating Vertical",  false, function(v) translocCFG.alternatingVertical = v end)
AddBindableToggle(TLX, "TranslocScreenEdge","Screen Edge",          false, function(v) translocCFG.screenEdge = v end)
AddBindableToggle(TLX, "TranslocOrbitFake","Orbit Fake",            false, function(v) translocCFG.orbitFake = v end)
TLX:AddSlider("TranslocOrbitRadius",{ Text = "Orbit Radius",        Default = 1e11, Min = 1, Max = 1e15, Rounding = 0, Callback = function(v) translocCFG.orbitRadius = v end })
AddBindableToggle(TLX, "TranslocZoneEscape","Zone Escape",          false, function(v) translocCFG.zoneEscape = v end)
TLX:AddSlider("TranslocZoneRadius", { Text = "Zone Radius",         Default = 200, Min = 20, Max = 2000, Rounding = 0, Callback = function(v) translocCFG.zoneEscapeRadius = v end })
AddBindableToggle(TLX, "TranslocAutoDodge","Auto Dodge Nearby",     false, function(v) translocCFG.autoDodge = v end)
TLX:AddSlider("TranslocAutoDodgeR", { Text = "Auto Dodge Radius",   Default = 60, Min = 10, Max = 500, Rounding = 0, Callback = function(v) translocCFG.autoDodgeRadius = v end })
AddBindableToggle(TLX, "TranslocNetOwner","Network Owner Fix",      true,  function(v) translocCFG.networkOwnerFix = v end)
end

do
local RG = Tabs.Riot:AddLeftGroupbox("Riot Godmode")
AddBindableToggle(RG, "RiotGodmodeToggle", "Enable Riot Godmode", false, function(v) riotGodmodeCFG.enabled = v; if v then RCLR_Functions.startRiotGodmode() else RCLR_Functions.stopRiotGodmode() end end)
RG:AddSlider("RGSpeed",        { Text = "Teleport Delay (s)",  Default = 0.03, Min=0.01,Max=0.5,  Rounding=2, Callback=function(v) riotGodmodeCFG.speed = v end })
RG:AddSlider("RGMinJump",      { Text = "Min Jump Range",       Default = 10,   Min=1,   Max=100,  Rounding=0, Callback=function(v) riotGodmodeCFG.minJump = v end })
RG:AddSlider("RGMaxJump",      { Text = "Max Jump Range",       Default = 200,  Min=10,  Max=2000, Rounding=0, Callback=function(v) riotGodmodeCFG.maxJump = v end })
RG:AddSlider("RGEvadeRange",   { Text = "Evade Trigger",        Default = 30,   Min=0,   Max=100,  Rounding=0, Callback=function(v) riotGodmodeCFG.evadeRange = v end })
RG:AddSlider("RGBulletDodge",  { Text = "Bullet Dodge Dist",    Default = 40,   Min=5,   Max=200,  Rounding=0, Callback=function(v) riotGodmodeCFG.bulletDodge = v end })
RG:AddSlider("RGHeightVar",    { Text = "Height Variance",      Default = 10,   Min=0,   Max=100,  Rounding=0, Callback=function(v) riotGodmodeCFG.heightVariance = v end })
RG:AddSlider("RGSpinSpeed",    { Text = "Spin Speed (deg/s)",   Default = 180,  Min=0,   Max=720,  Rounding=0, Callback=function(v) riotGodmodeCFG.spinSpeed = v end })
RG:AddDropdown("RGSpinAxis",   { Text = "Spin Axis", Default = "Y", Values = {"X","Y","Z"}, Callback=function(v) riotGodmodeCFG.spinAxis = v end })
AddBindableToggle(RG, "RGRandAxis",     "Random Spin Axis",  false, function(v) riotGodmodeCFG.randomAxis = v end)
AddBindableToggle(RG, "RGAvoidBullet",  "Avoid Bullets",     true,  function(v) riotGodmodeCFG.avoidBullets = v end)
AddBindableToggle(RG, "RGGroundSnap",   "Ground Snap",       false, function(v) riotGodmodeCFG.groundSnap = v end)
AddBindableToggle(RG, "RGMultiTp",      "Multi TP",          false, function(v) riotGodmodeCFG.multiTp = v end)
RG:AddSlider("RGMultiTpCount",  { Text = "Multi TP Count",      Default = 3,  Min=2,Max=10,  Rounding=0, Callback=function(v) riotGodmodeCFG.multiTpCount = v end })
RG:AddSlider("RGMultiTpDelay",  { Text = "Multi TP Delay (ms)", Default = 10, Min=1, Max=100, Rounding=0, Callback=function(v) riotGodmodeCFG.multiTpDelay = v * 0.001 end })
AddBindableToggle(RG, "RGPhaseMode",    "Phase Mode",        false, function(v) riotGodmodeCFG.phaseMode = v end)
RG:AddSlider("RGPhaseInterval", { Text = "Phase Interval (ms)", Default=20,Min=5,Max=100, Rounding=0, Callback=function(v) riotGodmodeCFG.phaseInterval = v * 0.001 end })
end

do
local RA = Tabs.Riot:AddRightGroupbox("Riot Abuser")
AddBindableToggle(RA, "RiotAbuserToggle", "Enable Riot Abuser", false, function(v) riotAbuserCFG.enabled = v; if v then RCLR_Functions.startRiotAbuser() else RCLR_Functions.stopRiotAbuser() end end)
RA:AddDropdown("RAMode",       { Text = "Mode", Default = "Stick", Values = {"Stick","Bounce","Orbit","Phase"}, Callback=function(v) riotAbuserCFG.mode = v end })
RA:AddSlider("RAHeight",       { Text = "Height Offset",      Default=3,  Min=-50,Max=50,  Rounding=1,Suffix="m",Callback=function(v) riotAbuserCFG.height = v end })
RA:AddSlider("RAForward",      { Text = "Forward Offset",     Default=0,  Min=-50,Max=50,  Rounding=1,Suffix="m",Callback=function(v) riotAbuserCFG.forward = v end })
RA:AddSlider("RARight",        { Text = "Right Offset",       Default=0,  Min=-50,Max=50,  Rounding=1,Suffix="m",Callback=function(v) riotAbuserCFG.right = v end })
RA:AddSlider("RADown",         { Text = "Down Offset",        Default=0,  Min=0,  Max=50,  Rounding=1,Suffix="m",Callback=function(v) riotAbuserCFG.down = v end })
RA:AddSlider("RABounceH",      { Text = "Bounce Height",      Default=5,  Min=1,  Max=50,  Rounding=1,Callback=function(v) riotAbuserCFG.bounceHeight = v end })
RA:AddSlider("RABounceSpd",    { Text = "Bounce Speed",       Default=8,  Min=1,  Max=50,  Rounding=1,Callback=function(v) riotAbuserCFG.bounceSpeed = v end })
RA:AddSlider("RAOrbRadius",    { Text = "Orbit Radius",       Default=5,  Min=1,  Max=50,  Rounding=1,Callback=function(v) riotAbuserCFG.orbitRadius = v end })
RA:AddSlider("RAOrbSpeed",     { Text = "Orbit Speed",        Default=200,Min=10, Max=1000,Rounding=0,Callback=function(v) riotAbuserCFG.orbitSpeed = v end })
RA:AddSlider("RAOrbHeight",    { Text = "Orbit Height",       Default=2,  Min=-20,Max=20,  Rounding=1,Callback=function(v) riotAbuserCFG.orbitHeight = v end })
RA:AddSlider("RAPhaseOff",     { Text = "Phase Offset",       Default=3,  Min=0,  Max=20,  Rounding=1,Callback=function(v) riotAbuserCFG.phaseOffset = v end })
RA:AddSlider("RARandOffAmp",   { Text = "Random Offset Amp",  Default=2,  Min=0,  Max=20,  Rounding=1,Callback=function(v) riotAbuserCFG.randomOffAmp = v end })
RA:AddSlider("RAAttackRange",  { Text = "Attack Range",       Default=10, Min=1,  Max=50,  Rounding=0,Callback=function(v) riotAbuserCFG.attackRange = v end })
RA:AddSlider("RAShootCD",      { Text = "Shoot Cooldown (ms)",Default=50, Min=10, Max=500, Rounding=0,Callback=function(v) riotAbuserCFG.shootCooldown = v * 0.001 end })
RA:AddSlider("RASpinSpeed",    { Text = "Spin Speed (deg/s)", Default=360,Min=10, Max=720, Rounding=0,Callback=function(v) riotAbuserCFG.spinSpeed = v end })
RA:AddSlider("RAPredLead",     { Text = "Predict Lead (x0.01s)",Default=10,Min=1, Max=50,  Rounding=0,Callback=function(v) riotAbuserCFG.predictLead = v * 0.01 end })
AddBindableToggle(RA, "RAAutoShoot",    "Auto Shoot",           true,  function(v) riotAbuserCFG.autoShoot = v end)
AddBindableToggle(RA, "RASpinOnTarget", "Spin On Target",       false, function(v) riotAbuserCFG.spinOnTarget = v end)
AddBindableToggle(RA, "RAMultiTarget",  "Multi Target",         false, function(v) riotAbuserCFG.multiTarget = v end)
AddBindableToggle(RA, "RARandOffset",   "Random Offset",        false, function(v) riotAbuserCFG.randomOffset = v end)
AddBindableToggle(RA, "RAPredict",      "Predict Target",       false, function(v) riotAbuserCFG.predictTarget = v end)
AddBindableToggle(RA, "RAForceFace",    "Force Face Target",    true,  function(v) riotAbuserCFG.forceFaceTarget = v end)
end


-- ============================================================
-- RAGE : UE Counter + Fast Melee  (built in, no customization)
-- ============================================================

local ueCFG = { enabled = false, interval = 2, yMax = 10000000, randY = true, fixedY = 0, lockXZ = true }
local ueConn = nil
local ueAcc = 0
local ueHoldY = 0

function RCLR_Functions.startUECounter()
    if ueConn then ueConn:Disconnect(); ueConn = nil end
    ueAcc = 0
    local step = RunService.PreSimulation or RunService.Heartbeat
    ueConn = step:Connect(function(dt)
        if not ueCFG.enabled then return end
        local hrp = getLocalRoot()
        if not hrp then return end
        ueAcc = ueAcc + dt
        if ueAcc >= ueCFG.interval then
            ueAcc = ueAcc % ueCFG.interval
            ueHoldY = ueCFG.randY and math.random(0, ueCFG.yMax) or ueCFG.fixedY
            pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
        end
        local tx = ueCFG.lockXZ and 0 or hrp.Position.X
        local tz = ueCFG.lockXZ and 0 or hrp.Position.Z
        pcall(function()
            hrp.CFrame = CFrame.new(tx, ueHoldY, tz)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
    end)
end
function RCLR_Functions.stopUECounter()
    if ueConn then ueConn:Disconnect(); ueConn = nil end
    ueCFG.enabled = false
end

local meleeCFG = { enabled = false, cached = {}, cooldown = 0, animSpeed = 100, remoteCount = 5, meleeOnly = false }
local meleeHookConn = nil

local function meleeScanGc()
    if #meleeCFG.cached > 0 then return end
    if type(getgc) ~= "function" then return end
    pcall(function()
        for _, t in pairs(getgc(true)) do
            if type(t) == "table" and (rawget(t, "MeleeCooldown") or rawget(t, "AttackCooldown") or rawget(t, "SwingDelay")) then
                table.insert(meleeCFG.cached, t)
            end
        end
    end)
end

local function meleeApplyCooldowns()
    meleeScanGc()
    local cd = meleeCFG.cooldown
    for _, t in ipairs(meleeCFG.cached) do
        if type(t) == "table" then
            if rawget(t, "MeleeCooldown") then t.MeleeCooldown = cd end
            if rawget(t, "AttackCooldown") then t.AttackCooldown = cd end
            if rawget(t, "SwingDelay") then t.SwingDelay = cd end
        end
    end
end

local function meleeAnimBoost()
    task.spawn(function()
        while meleeCFG.enabled do
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                        local n = track.Name:lower()
                        if n:find("attack") or n:find("swing") or n:find("melee") or n:find("punch") then
                            track:AdjustSpeed(meleeCFG.animSpeed)
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

local function meleeHookRemote()
    pcall(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
        local rep = remotes and remotes:WaitForChild("Replication", 10)
        local fighter = rep and rep:WaitForChild("Fighter", 10)
        local useItem = fighter and fighter:WaitForChild("UseItem", 10)
        if not useItem or useItem:GetAttribute("RCLRMeleeHooked") then return end
        useItem:SetAttribute("RCLRMeleeHooked", true)
        local oldFire = useItem.FireServer
        local busy = false
        useItem.FireServer = function(self, ...)
            if busy then return oldFire(self, ...) end
            busy = true
            local args = { ... }
            local action = tostring(args[2] or "")
            if action:find("Melee") or action:find("Attack") then
                for _ = 1, meleeCFG.remoteCount do oldFire(self, unpack(args)) end
            end
            local ret = oldFire(self, unpack(args))
            busy = false
            return ret
        end
    end)
end

function RCLR_Functions.startFastMelee()
    meleeApplyCooldowns()
    meleeAnimBoost()
    meleeHookRemote()
    if meleeHookConn then meleeHookConn:Disconnect() end
    meleeHookConn = RunService.Heartbeat:Connect(function()
        if meleeCFG.enabled then meleeApplyCooldowns() end
    end)
end
function RCLR_Functions.stopFastMelee()
    if meleeHookConn then meleeHookConn:Disconnect(); meleeHookConn = nil end
    meleeCFG.enabled = false
end
meleeCFG.remoteCount = math.max(meleeCFG.remoteCount, 2)

do
local RAG = Tabs.Rage:AddLeftGroupbox("UE Counter")
AddBindableToggle(RAG, "UECounterToggle", "Enable UE Counter", false, function(v) ueCFG.enabled = v; if v then RCLR_Functions.startUECounter() else RCLR_Functions.stopUECounter() end end)
RAG:AddSlider("UEInterval", { Text = "Pulse Interval (s)", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Callback = function(v) ueCFG.interval = v end })
RAG:AddSlider("UEYMax",     { Text = "Y Max (studs)",      Default = 10000000, Min = 1000, Max = 10000000, Rounding = 0, Callback = function(v) ueCFG.yMax = v end })
AddBindableToggle(RAG, "UERandY",  "Randomize Y",        true, function(v) ueCFG.randY = v end)
RAG:AddSlider("UEFixedY",   { Text = "Fixed Y",            Default = 0, Min = -1000000, Max = 10000000, Rounding = 0, Callback = function(v) ueCFG.fixedY = v end })
AddBindableToggle(RAG, "UELockXZ", "Freeze X/Z To 0",    true, function(v) ueCFG.lockXZ = v end)
end

do
local RMG = Tabs.Rage:AddRightGroupbox("Fast Melee")
AddBindableToggle(RMG, "FastMeleeToggle", "Enable Fast Melee", false, function(v) meleeCFG.enabled = v; if v then RCLR_Functions.startFastMelee() else RCLR_Functions.stopFastMelee() end end)
RMG:AddSlider("MeleeCD",    { Text = "Melee Cooldown",       Default = 0, Min = 0, Max = 5, Rounding = 2, Callback = function(v) meleeCFG.cooldown = v end })
RMG:AddSlider("MeleeAnim",  { Text = "Swing Anim Speed (x)", Default = 100, Min = 1, Max = 500, Rounding = 0, Callback = function(v) meleeCFG.animSpeed = v end })
RMG:AddSlider("MeleeCount", { Text = "Remote Fire Count",    Default = 5, Min = 1, Max = 20, Rounding = 0, Callback = function(v) meleeCFG.remoteCount = v end })
end


-- ============================================================
-- OPTIMIZER
-- ============================================================
local optCFG = { enabled = false, textures = true, particles = true, effects = false, lights = false, mobile = false }
local optConn = nil
local optDescConn = nil

local function optStrip(inst)
    if not optCFG.enabled then return end
    pcall(function()
        if optCFG.textures and (inst:IsA("Decal") or inst:IsA("Texture")) then
            inst.Transparency = 1
        elseif optCFG.particles and (inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles") or inst:IsA("Beam")) then
            inst.Enabled = false
        elseif optCFG.lights and (inst:IsA("PointLight") or inst:IsA("SpotLight") or inst:IsA("SurfaceLight")) then
            inst.Enabled = false
        elseif optCFG.effects and (inst:IsA("PostEffect") or inst:IsA("Atmosphere")) then
            inst.Enabled = false
        end
    end)
end

function RCLR_Functions.startOptimizer()
    if optConn then optConn:Disconnect(); optConn = nil end
    if optDescConn then optDescConn:Disconnect(); optDescConn = nil end
    pcall(function() if setfpscap then setfpscap(240) end end)
    task.spawn(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            if not optCFG.enabled then break end
            optStrip(d)
        end
    end)
    optConn = RunService.Heartbeat:Connect(function()
        if not optCFG.enabled then RCLR_Functions.stopOptimizer() end
    end)
    optDescConn = workspace.DescendantAdded:Connect(function(d)
        if optCFG.enabled then optStrip(d) end
    end)
end

function RCLR_Functions.stopOptimizer()
    if optConn then optConn:Disconnect(); optConn = nil end
    if optDescConn then optDescConn:Disconnect(); optDescConn = nil end
    optCFG.enabled = false
end



-- ============================================================
-- KEYBINDS : only the good options
-- ============================================================
local HOTKEYS = {
    { "VoidToggle",         "Void" },
    { "OrbitToggle",        "Orbit" },
    { "PredToggle",         "Prediction" },
    { "AntiBaitToggle",     "Anti-Bait" },
    { "AaToggle",           "Anti-Aim" },
    { "TranslocToggle",     "Translocation" },
    { "RiotGodmodeToggle",  "Riot Godmode" },
    { "RiotAbuserToggle",   "Riot Abuser" },
    { "SmartEvasionToggle", "Smart Evasion" },
    { "UECounterToggle",    "UE Counter" },
    { "FastMeleeToggle",    "Fast Melee" },
}
for _, e in ipairs(HOTKEYS) do
    local t = Toggles[e[1]]
    if t and t.AddKeyPicker then
        pcall(function()
            t:AddKeyPicker(e[1] .. "_Key", { Default = "None", Mode = "Toggle", Text = e[2], SyncToggleState = true, NoUI = false })
        end)
    end
end

do
local MenuG = Tabs.Settings:AddLeftGroupbox("Menu")
MenuG:AddButton("HVH LOCK IN", function()
    CFG.VOID_ENABLED = true; CFG.VOID_METHOD = "Quantum"; CFG.VOID_ANTIFLING = true; CFG.RADIUS = 1e11
    cfgDodge.predEnabled = true; cfgDodge.predRadius = 400; cfgDodge.predCooldown = 0.008
    cfgDodge.predShootDot = 0.6; cfgDodge.predDodgeDist = 160; cfgDodge.predInfiniteRange = true
    antiBaitCFG.enabled = true; antiBaitCFG.infiniteRange = true; antiBaitCFG.dodgeCooldown = 0.005
    antiBaitCFG.gunPredCooldown = 0.005; antiBaitCFG.baitReactionWindow = 0.3
    aaSettings.enabled = true; translocCFG.enabled = true
    CFG.SMART_EVASION = true
    if Toggles.VoidToggle then Toggles.VoidToggle:SetValue(true) end
    if Toggles.PredToggle then Toggles.PredToggle:SetValue(true) end
    if Toggles.AntiBaitToggle then Toggles.AntiBaitToggle:SetValue(true) end
    if Toggles.AaToggle then Toggles.AaToggle:SetValue(true) end
    if Toggles.TranslocToggle then Toggles.TranslocToggle:SetValue(true) end
    if Toggles.SmartEvasionToggle then Toggles.SmartEvasionToggle:SetValue(true) end
    RCLR_Functions.startVoid(); startPredictionV2(); startAntiBaitV2(); RCLR_Functions.startAntiAim(); RCLR_Functions.startTransloc()
    Notify("HVH LOCK IN engaged", 3)
end)
MenuG:AddButton("Load Preset", function()
    CFG.VOID_ENABLED = true; CFG.VOID_METHOD = "Quantum"
    cfg.orbitEnabled = false; cfgDodge.predEnabled = true
    antiBaitCFG.enabled = true; aaSettings.enabled = true
    translocCFG.enabled = false
    riotGodmodeCFG.enabled = false; riotAbuserCFG.enabled = true
    CFG.SMART_EVASION = true
    RCLR_Functions.startVoid(); startPredictionV2(); startAntiBaitV2(); RCLR_Functions.startAntiAim(); RCLR_Functions.startRiotAbuser()
    Toggles.VoidToggle:SetValue(true); Toggles.PredToggle:SetValue(true)
    Toggles.AntiBaitToggle:SetValue(true); Toggles.AaToggle:SetValue(true)
    Toggles.RiotAbuserToggle:SetValue(true)
    Toggles.SmartEvasionToggle:SetValue(true)
    Notify("Preset Loaded", 3)
end)
MenuG:AddButton("Kill Every (Disable All)", function()
    CFG.VOID_ENABLED = false; RCLR_Functions.stopVoid()
    cfg.orbitEnabled = false; RCLR_Functions.stopOrbit()
    cfgDodge.predEnabled = false; RCLR_Functions.stopPredictionV2()
    antiBaitCFG.enabled = false; RCLR_Functions.stopAntiBait()
    aaSettings.enabled = false; RCLR_Functions.stopAntiAim()
    translocCFG.enabled = false; RCLR_Functions.stopTransloc()
    riotGodmodeCFG.enabled = false; RCLR_Functions.stopRiotGodmode()
    riotAbuserCFG.enabled = false; RCLR_Functions.stopRiotAbuser()
    for _, name in ipairs({
        "VoidToggle","OrbitToggle","PredToggle","AntiBaitToggle","AaToggle",
        "TranslocToggle",
        "RiotGodmodeToggle","RiotAbuserToggle",
        "SmartEvasionToggle"
    }) do
        if Toggles[name] then pcall(function() Toggles[name]:SetValue(false) end) end
    end
    Notify("KILL EVERYTHING — all systems off", 3)
end)
MenuG:AddButton("Reload Character", function()
    if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end
end)
MenuG:AddButton("Rejoin Server", function()
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
end)
MenuG:AddButton("Server Hop", function()
    pcall(function()
        local Http = game:GetService("HttpService")
        local TS = game:GetService("TeleportService")
        local data = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, srv in ipairs(data.data) do
            if srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                TS:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer)
                break
            end
        end
    end)
end)
MenuG:AddToggle("KeybindMenu", { Text = "Keybind Menu", Default = false, Callback = function(v)
    pcall(function() if Library.KeybindFrame then Library.KeybindFrame.Visible = v end end)
end })
end

do
local UIGroup = Tabs.Settings:AddLeftGroupbox("UI")
UIGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", Text = "Menu Keybind", Mode = "Toggle", NoUI = false })
Library.ToggleKeybind = Options.MenuKeybind
UIGroup:AddToggle("AutoLoad",   { Text = "Auto Load Config",  Default = true })
UIGroup:AddToggle("ShowCoords", { Text = "Show Coordinates",  Default = true, Callback = function(v) if coordsGui then coordsGui.Enabled = v end end })
UIGroup:AddButton("Unload Script", function()
    if _sharedLibrary then
        -- the library belongs to another RCLR script; do not unload its UI
        CFG.VOID_ENABLED = false
        pcall(RCLR_Functions.stopVoid)
        if coordsGui then pcall(function() coordsGui:Destroy() end) end
        Notify("RCLR Lua Prem closed (other RCLR script keeps its UI)", 3)
    else
        Library:Unload()
    end
end)
end

pcall(function()
local OPT = Tabs.Settings:AddLeftGroupbox("Optimizer")
AddBindableToggle(OPT, "OptimizerToggle", "Enable Optimizer", false, function(v) optCFG.enabled = v; if v then RCLR_Functions.startOptimizer() else RCLR_Functions.stopOptimizer() end end)
AddBindableToggle(OPT, "OptTextures",  "Remove Textures / Decals",   true,  function(v) optCFG.textures = v end)
AddBindableToggle(OPT, "OptParticles", "Remove Particles / Trails",  true,  function(v) optCFG.particles = v end)
AddBindableToggle(OPT, "OptLights",    "Disable Lights / Shadows",   true,  function(v) optCFG.lights = v end)
AddBindableToggle(OPT, "OptEffects",   "Strip Atmosphere / Post FX", true,  function(v) optCFG.effects = v end)
AddBindableToggle(OPT, "OptMobile",    "Mobile Mode",                false, function(v) optCFG.mobile = v end)
OPT:AddButton("Force FPS Cap 240", function() pcall(function() if setfpscap then setfpscap(240) end end); Notify("FPS cap set to 240", 2) end)

local OPT2 = Tabs.Settings:AddRightGroupbox("Optimizer Tools")
OPT2:AddButton("Kill All Emitters Now", function()
    local n = 0
    pcall(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") then
                if d.Enabled then d.Enabled = false; n = n + 1 end
            end
        end
    end)
    Notify("Disabled " .. n .. " emitters", 2)
end)
OPT2:AddLabel("Enable Optimizer, then rejoin for best mobile FPS", true)
end)

-- ============================================================
-- LINORIA ADDONS (official ThemeManager + SaveManager EMBEDDED)
-- Source: violin-suzutsuki/LinoriaLib
-- ============================================================
do
    local loadstring = loadstring or load
    local g = (getgenv and getgenv()) or _G

    -- Linoria SaveManager uses LOCAL Toggles/Options (shadow) so UE globals stay intact
    Toggles = Library.Toggles or Toggles or {}
    Options = Library.Options or Options or {}
    Library.Toggles = Toggles
    Library.Options = Options
    g.RCLR_Toggles = Toggles
    g.RCLR_Options = Options
    -- inject locals into SaveManager so it never reads UE's Toggles
    getgenv().RCLR_Toggles = Toggles
    getgenv().RCLR_Options = Options

    local ThemeManager, SaveManager

    local okTM, resTM = pcall(function()
        return loadstring([===[
local Toggles = (getgenv and getgenv().RCLR_Toggles) or Toggles or {}
local Options = (getgenv and getgenv().RCLR_Options) or Options or {}
local httpService = game:GetService('HttpService')
local ThemeManager = {} do
	ThemeManager.Folder = 'LinoriaLibSettings'
	-- if not isfolder(ThemeManager.Folder) then makefolder(ThemeManager.Folder) end

	ThemeManager.Library = nil
	ThemeManager.BuiltInThemes = {
		['Default'] 		= { 1, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1c1c1c","AccentColor":"0055ff","BackgroundColor":"141414","OutlineColor":"323232"}') },
		['BBot'] 			= { 2, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1e1e","AccentColor":"7e48a3","BackgroundColor":"232323","OutlineColor":"141414"}') },
		['Fatality']		= { 3, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1842","AccentColor":"c50754","BackgroundColor":"191335","OutlineColor":"3c355d"}') },
		['Jester'] 			= { 4, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"db4467","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
		['Mint'] 			= { 5, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"3db488","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
		['Tokyo Night'] 	= { 6, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"191925","AccentColor":"6759b3","BackgroundColor":"16161f","OutlineColor":"323232"}') },
		['Ubuntu'] 			= { 7, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"3e3e3e","AccentColor":"e2581e","BackgroundColor":"323232","OutlineColor":"191919"}') },
		['Quartz'] 			= { 8, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"232330","AccentColor":"426e87","BackgroundColor":"1d1b26","OutlineColor":"27232f"}') },
	}

	function ThemeManager:ApplyTheme(theme)
		local customThemeData = self:GetCustomTheme(theme)
		local data = customThemeData or self.BuiltInThemes[theme]

		if not data then return end

		-- custom themes are just regular dictionaries instead of an array with { index, dictionary }

		local scheme = data[2]
		for idx, col in next, customThemeData or scheme do
			self.Library[idx] = Color3.fromHex(col)
			
			if Options[idx] then
				Options[idx]:SetValueRGB(Color3.fromHex(col))
			end
		end

		self:ThemeUpdate()
	end

	function ThemeManager:ThemeUpdate()
		-- This allows us to force apply themes without loading the themes tab :)
		local options = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
		for i, field in next, options do
			if Options and Options[field] then
				self.Library[field] = Options[field].Value
			end
		end

		self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor);
		self.Library:UpdateColorsUsingRegistry()
	end

	function ThemeManager:LoadDefault()		
		local theme = 'Default'
		local content = isfile(self.Folder .. '/themes/default.txt') and readfile(self.Folder .. '/themes/default.txt')

		local isDefault = true
		if content then
			if self.BuiltInThemes[content] then
				theme = content
			elseif self:GetCustomTheme(content) then
				theme = content
				isDefault = false;
			end
		elseif self.BuiltInThemes[self.DefaultTheme] then
		 	theme = self.DefaultTheme
		end

		if isDefault then
			self:ApplyTheme(theme)
			pcall(function()
				if Options and Options.ThemeManager_ThemeList and Options.ThemeManager_ThemeList.SetValue then
					Options.ThemeManager_ThemeList:SetValue(theme)
				end
			end)
		else
			self:ApplyTheme(theme)
			pcall(function()
				if Options and Options.ThemeManager_ThemeList and Options.ThemeManager_ThemeList.SetValue then
					Options.ThemeManager_ThemeList:SetValue('Default')
				end
				if Options and Options.ThemeManager_CustomThemeList and Options.ThemeManager_CustomThemeList.SetValue then
					Options.ThemeManager_CustomThemeList:SetValue(theme)
				end
			end)
		end
	end

	function ThemeManager:SaveDefault(theme)
		writefile(self.Folder .. '/themes/default.txt', theme)
	end

	function ThemeManager:CreateThemeManager(groupbox)
		groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor });
		groupbox:AddLabel('Main color')	:AddColorPicker('MainColor', { Default = self.Library.MainColor });
		groupbox:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = self.Library.AccentColor });
		groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor });
		groupbox:AddLabel('Font color')	:AddColorPicker('FontColor', { Default = self.Library.FontColor });

		local ThemesArray = {}
		for Name, Theme in next, self.BuiltInThemes do
			table.insert(ThemesArray, Name)
		end

		table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

		groupbox:AddDivider()
		groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1 })

		groupbox:AddButton('Set as default', function()
			local v = Options and Options.ThemeManager_ThemeList and Options.ThemeManager_ThemeList.Value
			if v then
				self:SaveDefault(v)
				self.Library:Notify(string.format('Set default theme to %q', v))
			end
		end)

		Options.ThemeManager_ThemeList:OnChanged(function()
			self:ApplyTheme(Options.ThemeManager_ThemeList.Value)
		end)

		groupbox:AddDivider()
		groupbox:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom theme name' })
		groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom themes', Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1 })
		groupbox:AddDivider()
		
		groupbox:AddButton('Save theme', function() 
			self:SaveCustomTheme(Options.ThemeManager_CustomThemeName.Value)

			Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end):AddButton('Load theme', function() 
			self:ApplyTheme(Options.ThemeManager_CustomThemeList.Value) 
		end)

		groupbox:AddButton('Refresh list', function()
			Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)

		groupbox:AddButton('Set as default', function()
			if Options.ThemeManager_CustomThemeList.Value ~= nil and Options.ThemeManager_CustomThemeList.Value ~= '' then
				self:SaveDefault(Options.ThemeManager_CustomThemeList.Value)
				self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_CustomThemeList.Value))
			end
		end)

		ThemeManager:LoadDefault()

		local function UpdateTheme()
			self:ThemeUpdate()
		end

		Options.BackgroundColor:OnChanged(UpdateTheme)
		Options.MainColor:OnChanged(UpdateTheme)
		Options.AccentColor:OnChanged(UpdateTheme)
		Options.OutlineColor:OnChanged(UpdateTheme)
		Options.FontColor:OnChanged(UpdateTheme)
	end

	function ThemeManager:GetCustomTheme(file)
		local path = self.Folder .. '/themes/' .. file
		if not isfile(path) then
			return nil
		end

		local data = readfile(path)
		local success, decoded = pcall(httpService.JSONDecode, httpService, data)
		
		if not success then
			return nil
		end

		return decoded
	end

	function ThemeManager:SaveCustomTheme(file)
		if file:gsub(' ', '') == '' then
			return self.Library:Notify('Invalid file name for theme (empty)', 3)
		end

		local theme = {}
		local fields = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }

		for _, field in next, fields do
			theme[field] = Options[field].Value:ToHex()
		end

		writefile(self.Folder .. '/themes/' .. file .. '.json', httpService:JSONEncode(theme))
	end

	function ThemeManager:ReloadCustomThemes()
		local list = listfiles(self.Folder .. '/themes')

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				-- i hate this but it has to be done ...

				local pos = file:find('.json', 1, true)
				local char = file:sub(pos, pos)

				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1))
				end
			end
		end

		return out
	end

	function ThemeManager:SetLibrary(lib)
		self.Library = lib
	end

	function ThemeManager:BuildFolderTree()
		local paths = {}

		-- build the entire tree if a path is like some-hub/phantom-forces
		-- makefolder builds the entire tree on Synapse X but not other exploits

		local parts = self.Folder:split('/')
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, '/', 1, idx)
		end

		table.insert(paths, self.Folder .. '/themes')
		table.insert(paths, self.Folder .. '/settings')

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function ThemeManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function ThemeManager:CreateGroupBox(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		return tab:AddLeftGroupbox('Themes')
	end

	function ThemeManager:ApplyToTab(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		local groupbox = self:CreateGroupBox(tab)
		self:CreateThemeManager(groupbox)
	end

	function ThemeManager:ApplyToGroupbox(groupbox)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		self:CreateThemeManager(groupbox)
	end

	ThemeManager:BuildFolderTree()
end

return ThemeManager
]===])()
    end)
    if okTM and type(resTM) == "table" then
        ThemeManager = resTM
    else
        warn("[RCLR PREM] ThemeManager failed:", resTM)
    end

    local okSM, resSM = pcall(function()
        return loadstring([===[
local Toggles = (getgenv and getgenv().RCLR_Toggles) or Toggles or {}
local Options = (getgenv and getgenv().RCLR_Options) or Options or {}

local httpService = game:GetService('HttpService')

local SaveManager = {} do
	SaveManager.Folder = 'LinoriaLibSettings'
	SaveManager.Ignore = {}
	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = 'Toggle', idx = idx, value = object.Value } 
			end,
			Load = function(idx, data)
				if Toggles[idx] then 
					Toggles[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = 'Slider', idx = idx, value = tostring(object.Value) }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = 'Dropdown', idx = idx, value = object.Value, mutli = object.Multi }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		},
		ColorPicker = {
			Save = function(idx, object)
				return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
				end
			end,
		},
		KeyPicker = {
			Save = function(idx, object)
				return { type = 'KeyPicker', idx = idx, mode = object.Mode, key = object.Value }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue({ data.key, data.mode })
				end
			end,
		},

		Input = {
			Save = function(idx, object)
				return { type = 'Input', idx = idx, text = object.Value }
			end,
			Load = function(idx, data)
				if Options[idx] and type(data.text) == 'string' then
					Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

	function SaveManager:Save(name)
		if (not name) then
			return false, 'no config file is selected'
		end

		local fullPath = self.Folder .. '/settings/' .. name .. '.json'

		local data = {
			objects = {}
		}

		for idx, toggle in next, Toggles do
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
		end

		for idx, option in next, Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end	

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return false, 'failed to encode data'
		end

		writefile(fullPath, encoded)
		return true
	end

	function SaveManager:Load(name)
		if (not name) then
			return false, 'no config file is selected'
		end
		
		local file = self.Folder .. '/settings/' .. name .. '.json'
		if not isfile(file) then return false, 'invalid file' end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then return false, 'decode error' end

		for _, option in next, decoded.objects do
			if self.Parser[option.type] then
				task.spawn(function() self.Parser[option.type].Load(option.idx, option) end) -- task.spawn() so the config loading wont get stuck.
			end
		end

		return true
	end

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", -- themes
			"ThemeManager_ThemeList", 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName', -- themes
		})
	end

	function SaveManager:BuildFolderTree()
		local paths = {
			self.Folder,
			self.Folder .. '/themes',
			self.Folder .. '/settings'
		}

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function SaveManager:RefreshConfigList()
		local list = listfiles(self.Folder .. '/settings')

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				-- i hate this but it has to be done ...

				local pos = file:find('.json', 1, true)
				local start = pos

				local char = file:sub(pos, pos)
				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1, start - 1))
				end
			end
		end
		
		return out
	end

	function SaveManager:SetLibrary(library)
		self.Library = library
	end

	function SaveManager:LoadAutoloadConfig()
		if isfile(self.Folder .. '/settings/autoload.txt') then
			local name = readfile(self.Folder .. '/settings/autoload.txt')

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify('Failed to load autoload config: ' .. err)
			end

			self.Library:Notify(string.format('Auto loaded config %q', name))
		end
	end


	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, 'Must set SaveManager.Library')

		local section = tab:AddRightGroupbox('Configuration')

		section:AddInput('SaveManager_ConfigName',    { Text = 'Config name' })
		section:AddDropdown('SaveManager_ConfigList', { Text = 'Config list', Values = self:RefreshConfigList(), AllowNull = true })

		section:AddDivider()

		section:AddButton('Create config', function()
			local name = Options.SaveManager_ConfigName.Value

			if name:gsub(' ', '') == '' then 
				return self.Library:Notify('Invalid config name (empty)', 2)
			end

			local success, err = self:Save(name)
			if not success then
				return self.Library:Notify('Failed to save config: ' .. err)
			end

			self.Library:Notify(string.format('Created config %q', name))

			Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			Options.SaveManager_ConfigList:SetValue(nil)
		end):AddButton('Load config', function()
			local name = Options.SaveManager_ConfigList.Value

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify('Failed to load config: ' .. err)
			end

			self.Library:Notify(string.format('Loaded config %q', name))
		end)

		section:AddButton('Overwrite config', function()
			local name = Options.SaveManager_ConfigList.Value

			local success, err = self:Save(name)
			if not success then
				return self.Library:Notify('Failed to overwrite config: ' .. err)
			end

			self.Library:Notify(string.format('Overwrote config %q', name))
		end)

		section:AddButton('Refresh list', function()
			Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			Options.SaveManager_ConfigList:SetValue(nil)
		end)

		section:AddButton('Set as autoload', function()
			local name = Options.SaveManager_ConfigList.Value
			writefile(self.Folder .. '/settings/autoload.txt', name)
			SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. name)
			self.Library:Notify(string.format('Set %q to auto load', name))
		end)

		SaveManager.AutoloadLabel = section:AddLabel('Current autoload config: none', true)

		if isfile(self.Folder .. '/settings/autoload.txt') then
			local name = readfile(self.Folder .. '/settings/autoload.txt')
			SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. name)
		end

		SaveManager:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigName' })
	end

	SaveManager:BuildFolderTree()
end

return SaveManager

]===])()
    end)
    if okSM and type(resSM) == "table" then
        SaveManager = resSM
    else
        warn("[RCLR PREM] SaveManager failed:", resSM)
    end

    if ThemeManager then
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("RCLRPrem")
        pcall(function() ThemeManager:ApplyToTab(Tabs.Settings) end)
        Library.ThemeManager = ThemeManager
        getgenv().RCLR_PREM_ThemeManager = ThemeManager
    end

    if SaveManager then
        SaveManager:SetLibrary(Library)
        pcall(function() SaveManager:IgnoreThemeSettings() end)
        SaveManager:SetFolder("RCLRPrem")
        pcall(function() SaveManager:BuildConfigSection(Tabs.Settings) end)
        Library.SaveManager = SaveManager
        getgenv().RCLR_PREM_SaveManager = SaveManager
    end

    task.spawn(function()
        task.wait(5)
        pcall(function()
            if Library._AutoLoadTheme == false then return end
            if ThemeManager and ThemeManager.LoadDefault then ThemeManager:LoadDefault() end
        end)
        task.wait(0.3)
        pcall(function()
            if Library._AutoLoadConfig == false then return end
            if SaveManager and SaveManager.LoadAutoloadConfig then SaveManager:LoadAutoloadConfig() end
        end)
    end)

    pcall(function()
        if Library and Library.Notify then
            Library:Notify("Linoria ThemeManager + SaveManager ready", 3)
        end
    end)
end


-- ============================================================
-- GLASS / NOTIFY / TAB TWEAKS + AUTO-LOAD (Settings)
-- ============================================================
do
    -- Glass Tweaks
    local GlassG = Tabs.Settings:AddLeftGroupbox("Glass Tweaks")
    local _glassPending = false
    local function applyGlassNow(enabled)
        if _glassPending then return end
        _glassPending = true
        local en = enabled
        task.defer(function()
            task.wait(0.05)
            _glassPending = false
            local enabled = en ~= false
            local pct = 80
            pcall(function()
                if Options and Options.GlassStrength and Options.GlassStrength.Value then
                    pct = Options.GlassStrength.Value
                end
            end)
            pct = math.clamp(tonumber(pct) or 80, 40, 98)
            local t = math.clamp(0.30 + (pct - 40) / 58 * 0.45, 0.30, 0.80)
            Library.GlassEnabled = enabled
            Library.GlassTransparency = t
            Library._SettingGlass = false
            pcall(function()
                if Library.SetGlass then Library:SetGlass(enabled, t) end
            end)
            Library._SettingGlass = false
            pcall(function()
                local outer = Library.WindowOuter
                if outer then
                    outer.BackgroundTransparency = enabled and math.clamp(0.30 + t * 0.30, 0.30, 0.70) or 0
                end
            end)
        end)
    end

    GlassG:AddToggle("GlassEnabled", {
        Text = "Enable Glass",
        Default = true,
        Callback = function(v)
            applyGlassNow(v)
            Notify(v and "Glass on" or "Glass off", 2)
        end,
    })
    GlassG:AddSlider("GlassStrength", {
        Text = "Glass Strength",
        Default = 85, Min = 40, Max = 98, Rounding = 0, Suffix = "%",
        Callback = function()
            applyGlassNow(Library.GlassEnabled ~= false)
        end,
    })
    GlassG:AddToggle("GlassGloss", {
        Text = "Glass Gloss",
        Default = true,
        Callback = function()
            applyGlassNow(Library.GlassEnabled ~= false)
        end,
    })
    GlassG:AddButton("Apply Strong Glass", function()
        pcall(function()
            if Options.GlassStrength and Options.GlassStrength.SetValue then
                Options.GlassStrength:SetValue(90)
            end
        end)
        applyGlassNow(true)
        Notify("Strong glass applied", 2)
    end)
    GlassG:AddButton("Disable Glass", function()
        applyGlassNow(false)
        Notify("Glass off", 2)
    end)

    task.defer(function()
        task.wait(1.0)
        applyGlassNow(true)
    end)


-- ============================================================

    -- Notify Tweaks
    pcall(function()
        if Library.AddNotifyOptions then
            Library:AddNotifyOptions(Tabs.Settings:AddLeftGroupbox("Notify Tweaks"))
        else
            local NG = Tabs.Settings:AddLeftGroupbox("Notify Tweaks")
            Library.NotifyConfig = Library.NotifyConfig or {
                PosX = 50, PosY = 60, Transparency = 25,
                Alignment = "Center", BarSide = "Bottom",
            }
            local NC = Library.NotifyConfig
            local function apply()
                pcall(function()
                    if Library.ConfigureNotifications then Library:ConfigureNotifications(NC) end
                end)
            end
            NG:AddSlider("NotifyPosX", {
                Text = "Position X", Default = NC.PosX or 50, Min = 0, Max = 100, Rounding = 0, Suffix = "%",
                Callback = function(v) NC.PosX = v; apply() end,
            })
            NG:AddSlider("NotifyPosY", {
                Text = "Position Y", Default = NC.PosY or 60, Min = 0, Max = 100, Rounding = 0, Suffix = "%",
                Callback = function(v) NC.PosY = v; apply() end,
            })
            NG:AddSlider("NotifyTransparency", {
                Text = "Transparency", Default = NC.Transparency or 25, Min = 0, Max = 90, Rounding = 0, Suffix = "%",
                Callback = function(v) NC.Transparency = v; apply() end,
            })
            NG:AddDropdown("NotifyBarSide", {
                Text = "Accent Bar Side",
                Values = { "Bottom", "Top", "Left", "Right" },
                Default = 1,
                Callback = function(v) NC.BarSide = v; apply() end,
            })
            NG:AddDropdown("NotifyAlign", {
                Text = "Alignment",
                Values = { "Center", "Left", "Right" },
                Default = 1,
                Callback = function(v) NC.Alignment = v; apply() end,
            })
            NG:AddButton("Test Notify", function()
                Notify("Notify tweak test", 3)
            end)
        end
    end)

    -- Tab Tweaks (line up/down + more)
    local TabG = Tabs.Settings:AddRightGroupbox("Tab Tweaks")
    Library.TabLineSide = Library.TabLineSide or "Bottom"
    Library.TabLineThickness = Library.TabLineThickness or 2
    Library.TabCompact = Library.TabCompact or false

    local function applyTabLine()
        local side = Library.TabLineSide or "Bottom"
        local th = math.clamp(tonumber(Library.TabLineThickness) or 2, 1, 6)
        pcall(function()
            local function styleIndicator(ind)
                if not ind or not ind.Parent then return end
                ind.Size = UDim2.new(1, 0, 0, th)
                if side == "Top" then
                    ind.Position = UDim2.new(0, 0, 0, 0)
                    ind.AnchorPoint = Vector2.new(0, 0)
                else
                    ind.Position = UDim2.new(0, 0, 1, 0)
                    ind.AnchorPoint = Vector2.new(0, 1)
                end
                if Library.AccentColor then
                    ind.BackgroundColor3 = Library.AccentColor
                end
            end

            -- From tab objects
            if Window and Window.Tabs then
                for _, tab in pairs(Window.Tabs) do
                    if tab.TabIndicator then
                        styleIndicator(tab.TabIndicator)
                    end
                    local btn = tab.Button or tab.TabButton
                    if btn then
                        local ind = btn:FindFirstChild("TabIndicator")
                        if ind then styleIndicator(ind) end
                        for _, ch in ipairs(btn:GetChildren()) do
                            if ch:IsA("Frame") and ch.Name == "TabIndicator" then
                                styleIndicator(ch)
                            elseif ch:IsA("Frame") and ch.Size.Y.Offset <= 4 and ch.Size.X.Scale >= 0.9 and ch.ZIndex >= 2 then
                                -- likely underline indicator
                                ch.Name = "TabIndicator"
                                styleIndicator(ch)
                            end
                        end
                    end
                end
            end

            -- ScreenGui scan fallback
            if Library.ScreenGui then
                for _, d in ipairs(Library.ScreenGui:GetDescendants()) do
                    if d:IsA("Frame") and d.Name == "TabIndicator" then
                        styleIndicator(d)
                    end
                end
            end
        end)
    end

    -- expose for other code
    Library.ApplyTabLine = applyTabLine

    TabG:AddDropdown("TabLineSide", {
        Text = "Tab Line Position",
        Values = { "Bottom", "Top" },
        Default = 1,
        Callback = function(v)
            Library.TabLineSide = v
            applyTabLine()
            Notify("Tab line: " .. tostring(v), 2)
        end,
    })
    TabG:AddSlider("TabLineThickness", {
        Text = "Tab Line Thickness",
        Default = 2, Min = 1, Max = 5, Rounding = 0, Suffix = "px",
        Callback = function(v)
            Library.TabLineThickness = v
            applyTabLine()
        end,
    })
    TabG:AddToggle("TabCompact", {
        Text = "Compact Tabs",
        Default = false,
        Callback = function(v)
            Library.TabCompact = v
            pcall(function()
                if Library.SetTabPadding then
                    Library:SetTabPadding(v and 0 or 2)
                end
            end)
            Notify("Compact tabs: " .. tostring(v), 2)
        end,
    })
    TabG:AddSlider("TabPadding", {
        Text = "Tab Padding",
        Default = 2, Min = 0, Max = 12, Rounding = 0,
        Callback = function(v)
            pcall(function()
                if Library.SetTabPadding then Library:SetTabPadding(v) end
                Library.TabPadding = v
            end)
        end,
    })
    TabG:AddSlider("TabTextSize", {
        Text = "Tab Text Size",
        Default = 14, Min = 10, Max = 20, Rounding = 0,
        Callback = function(v)
            Library.TabTextSize = v
            pcall(function()
                if Library.ScreenGui then
                    for _, d in ipairs(Library.ScreenGui:GetDescendants()) do
                        if d:IsA("TextLabel") or d:IsA("TextButton") then
                            if d.Parent and (string.find(string.lower(d.Parent.Name), "tab") or string.find(string.lower(d.Name), "tab")) then
                                d.TextSize = v
                            end
                        end
                    end
                end
            end)
        end,
    })
    TabG:AddButton("Apply Tab Line Now", function()
        applyTabLine()
        Notify("Tab line applied", 2)
    end)

    -- Auto-load controls (theme + config) on top of Linoria managers
    local AL = Tabs.Settings:AddRightGroupbox("Auto Load")
    AL:AddToggle("AL_Theme", {
        Text = "Auto Load Theme",
        Default = true,
        Callback = function(v)
            Library._AutoLoadTheme = v
        end,
    })
    AL:AddToggle("AL_Config", {
        Text = "Auto Load Config",
        Default = true,
        Callback = function(v)
            Library._AutoLoadConfig = v
        end,
    })
    AL:AddLabel("Use Theme Manager / Save Manager lists,")
    AL:AddLabel("then set default / autoload there.")
    AL:AddButton("Run Auto-Load Now", function()
        pcall(function()
            local TM = Library.ThemeManager or (getgenv and getgenv().RCLR_PREM_ThemeManager)
            if Library._AutoLoadTheme ~= false and TM and TM.LoadDefault then
                TM:LoadDefault()
            end
        end)
        pcall(function()
            local SM = Library.SaveManager or (getgenv and getgenv().RCLR_PREM_SaveManager)
            if Library._AutoLoadConfig ~= false and SM and SM.LoadAutoloadConfig then
                SM:LoadAutoloadConfig()
            end
        end)
        Notify("Auto-load ran", 2)
    end)

    -- Library built-in tab tweaks if present
    pcall(function()
        if Library.AddTabTweaks then
            -- already have our Tab Tweaks group; skip duplicate
        end
    end)

    local ok2, err2 = pcall(function()
        applyTabLine()
    end)
    if not ok2 and err2 then
        warn("[RCLR PREM] applyTabLine failed:", tostring(err2))
    end
end


pcall(function()
    local cg = game:GetService("CoreGui")
    -- only ever remove our own gui, never another script's
    local old = cg:FindFirstChild("RCLRPrem_Coords")
    if old then old:Destroy() end
end)

coordsGui = Instance.new("ScreenGui")
coordsGui.Name = "RCLRPrem_Coords"
coordsGui.ResetOnSpawn = false
coordsGui.DisplayOrder = 9998
coordsGui.IgnoreGuiInset = true
coordsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() coordsGui.Parent = game:GetService("CoreGui") end)
if not coordsGui.Parent then
    local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        pcall(function() coordsGui.Parent = pg end)
    end
end
if not coordsGui.Parent then coordsGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
if Options.ShowCoords and Options.ShowCoords.Value ~= nil then
    pcall(function() coordsGui.Enabled = Options.ShowCoords.Value end)
else
    coordsGui.Enabled = true
end

-- Separate compilation frame: HUD locals no longer consume the main chunk registers.
(function()
    local ACCENT_FB  = Color3.fromRGB(228, 74, 84)
    local MAIN_FB    = Color3.fromRGB(24, 24, 28)
    local OUTLINE_FB = Color3.fromRGB(58, 58, 66)
    local TEXT_FB    = Color3.fromRGB(226, 226, 232)
    local PANEL_FB   = Color3.fromRGB(30, 30, 34)
    local FONT_FB    = Enum.Font.GothamMedium
    local W, H = 308, 172

    local function themeColor(key, fallback)
        local v = Library and Library[key]
        if typeof(v) == "Color3" then return v end
        return fallback
    end
    local function themeFont()
        local f = Library and Library.Font
        if typeof(f) == "EnumItem" then return f end
        return FONT_FB
    end
    local function shade(c, f)
        return Color3.new(c.R * f, c.G * f, c.B * f)
    end

    local hud = Instance.new("Frame")
    hud.Name = "PositionHUD"
    hud.Size = UDim2.fromOffset(W, H)
    hud.Position = UDim2.new(0, 16, 1, -(H + 16))
    hud.BackgroundColor3 = themeColor("MainColor", MAIN_FB)
    hud.BackgroundTransparency = 0.05
    hud.BorderSizePixel = 0
    hud.Active = true
    hud.Parent = coordsGui

    local hudCorner = Instance.new("UICorner")
    hudCorner.CornerRadius = UDim.new(0, 14)
    hudCorner.Parent = hud

    local hudStroke = Instance.new("UIStroke")
    hudStroke.Color = themeColor("OutlineColor", OUTLINE_FB)
    hudStroke.Thickness = 1
    hudStroke.Transparency = 0.25
    hudStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    hudStroke.Parent = hud

    local hudGrad = Instance.new("UIGradient")
    hudGrad.Rotation = 90
    hudGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, themeColor("AccentColor", ACCENT_FB)),
        ColorSequenceKeypoint.new(1, shade(themeColor("MainColor", MAIN_FB), 0.35)),
    })
    hudGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 0.35),
    })
    hudGrad.Parent = hud

    local hudTop = Instance.new("Frame")
    hudTop.Size = UDim2.new(1, -24, 0, 32)
    hudTop.Position = UDim2.fromOffset(12, 10)
    hudTop.BackgroundTransparency = 1
    hudTop.Parent = hud

    local brandLbl = Instance.new("TextLabel")
    brandLbl.Size = UDim2.new(1, -70, 0, 18)
    brandLbl.BackgroundTransparency = 1
    brandLbl.Text = "RCLR Lua Prem"
    brandLbl.TextColor3 = themeColor("AccentColor", ACCENT_FB)
    brandLbl.Font = themeFont()
    brandLbl.TextSize = 16
    brandLbl.TextXAlignment = Enum.TextXAlignment.Left
    brandLbl.Parent = hudTop

    local posLbl = Instance.new("TextLabel")
    posLbl.Size = UDim2.new(1, -70, 0, 12)
    posLbl.Position = UDim2.fromOffset(0, 18)
    posLbl.BackgroundTransparency = 1
    posLbl.Text = "POSITION"
    posLbl.TextColor3 = themeColor("FontColor", TEXT_FB)
    posLbl.TextTransparency = 0.35
    posLbl.Font = themeFont()
    posLbl.TextSize = 10
    posLbl.TextXAlignment = Enum.TextXAlignment.Left
    posLbl.Parent = hudTop

    local liveLbl = Instance.new("TextLabel")
    liveLbl.Size = UDim2.fromOffset(52, 12)
    liveLbl.Position = UDim2.new(1, -66, 0, 3)
    liveLbl.BackgroundTransparency = 1
    liveLbl.Text = "LIVE"
    liveLbl.TextColor3 = themeColor("AccentColor", ACCENT_FB)
    liveLbl.Font = themeFont()
    liveLbl.TextSize = 9
    liveLbl.TextXAlignment = Enum.TextXAlignment.Right
    liveLbl.Parent = hudTop

    local gDot = Instance.new("Frame")
    gDot.Size = UDim2.fromOffset(8, 8)
    gDot.Position = UDim2.new(1, -10, 0, 6)
    gDot.BackgroundColor3 = themeColor("AccentColor", ACCENT_FB)
    gDot.BorderSizePixel = 0
    gDot.Parent = hudTop
    local gdc = Instance.new("UICorner")
    gdc.CornerRadius = UDim.new(1, 0)
    gdc.Parent = gDot

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -24, 0, 1)
    divider.Position = UDim2.fromOffset(12, 46)
    divider.BackgroundColor3 = themeColor("AccentColor", ACCENT_FB)
    divider.BackgroundTransparency = 0.6
    divider.BorderSizePixel = 0
    divider.Parent = hud

    local coordLabels = {}
    local rows = {}
    for i, key in ipairs({ "X", "Y", "Z" }) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -24, 0, 26)
        row.Position = UDim2.fromOffset(12, 54 + (i - 1) * 30)
        row.BackgroundColor3 = themeColor("BackgroundColor", PANEL_FB)
        row.BackgroundTransparency = 0.35
        row.BorderSizePixel = 0
        row.Parent = hud
        local rc = Instance.new("UICorner")
        rc.CornerRadius = UDim.new(0, 8)
        rc.Parent = row

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 3, 0, 12)
        bar.Position = UDim2.new(0, 9, 0.5, -6)
        bar.BackgroundColor3 = themeColor("AccentColor", ACCENT_FB)
        bar.BorderSizePixel = 0
        bar.Parent = row
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(1, 0)
        bc.Parent = bar

        local letter = Instance.new("TextLabel")
        letter.Size = UDim2.fromOffset(16, 26)
        letter.Position = UDim2.fromOffset(20, 0)
        letter.BackgroundTransparency = 1
        letter.Text = key
        letter.TextColor3 = themeColor("AccentColor", ACCENT_FB)
        letter.Font = themeFont()
        letter.TextSize = 12
        letter.TextXAlignment = Enum.TextXAlignment.Left
        letter.Parent = row

        local val = Instance.new("TextLabel")
        val.Size = UDim2.new(1, -50, 1, 0)
        val.Position = UDim2.fromOffset(40, 0)
        val.BackgroundTransparency = 1
        val.Text = "0"
        val.TextColor3 = themeColor("FontColor", TEXT_FB)
        val.Font = themeFont()
        val.TextSize = 13
        val.TextXAlignment = Enum.TextXAlignment.Right
        val.Parent = row

        coordLabels[key] = val
        rows[#rows + 1] = { row = row, bar = bar, letter = letter, val = val }
    end

    local unitLbl = Instance.new("TextLabel")
    unitLbl.Size = UDim2.fromOffset(90, 12)
    unitLbl.Position = UDim2.fromOffset(14, 148)
    unitLbl.BackgroundTransparency = 1
    unitLbl.Text = "STUDS"
    unitLbl.TextColor3 = themeColor("FontColor", TEXT_FB)
    unitLbl.TextTransparency = 0.45
    unitLbl.Font = themeFont()
    unitLbl.TextSize = 9
    unitLbl.TextXAlignment = Enum.TextXAlignment.Left
    unitLbl.Parent = hud

    local tagLbl = Instance.new("TextLabel")
    tagLbl.Size = UDim2.new(0, 120, 0, 12)
    tagLbl.Position = UDim2.new(1, -134, 0, 148)
    tagLbl.BackgroundTransparency = 1
    tagLbl.Text = "discord.gg/ZmN2Djb7m"
    tagLbl.TextColor3 = themeColor("AccentColor", ACCENT_FB)
    tagLbl.TextTransparency = 0.5
    tagLbl.Font = themeFont()
    tagLbl.TextSize = 9
    tagLbl.TextXAlignment = Enum.TextXAlignment.Right
    tagLbl.Parent = hud

    local dragActive = false
    local dragOrigin = Vector2.zero
    local dragStartPos = UDim2.new()
    hud.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragActive = true
            dragOrigin = inp.Position
            dragStartPos = hud.Position
        end
    end)
    hud.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragActive = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragActive and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragOrigin
            hud.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + d.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + d.Y)
        end
    end)

    local lastThemeSig = nil
    local function applyTheme()
        local acc = themeColor("AccentColor", ACCENT_FB)
        local main = themeColor("MainColor", MAIN_FB)
        local outl = themeColor("OutlineColor", OUTLINE_FB)
        local txt = themeColor("FontColor", TEXT_FB)
        local pnl = themeColor("BackgroundColor", PANEL_FB)
        local font = themeFont()
        local sig = tostring(acc) .. tostring(main) .. tostring(outl) .. tostring(txt) .. tostring(pnl) .. tostring(font)
        if sig == lastThemeSig then return end
        lastThemeSig = sig
        hud.BackgroundColor3 = main
        hudStroke.Color = outl
        hudGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, acc),
            ColorSequenceKeypoint.new(1, shade(main, 0.35)),
        })
        brandLbl.TextColor3 = acc
        brandLbl.Font = font
        posLbl.TextColor3 = txt
        posLbl.Font = font
        liveLbl.TextColor3 = acc
        liveLbl.Font = font
        gDot.BackgroundColor3 = acc
        divider.BackgroundColor3 = acc
        unitLbl.TextColor3 = txt
        unitLbl.Font = font
        tagLbl.TextColor3 = acc
        tagLbl.Font = font
        for _, r in ipairs(rows) do
            r.row.BackgroundColor3 = pnl
            r.bar.BackgroundColor3 = acc
            r.letter.TextColor3 = acc
            r.letter.Font = font
            r.val.TextColor3 = txt
            r.val.Font = font
        end
    end

    local hudPulse = 0
    local liveStudHeartbeatConn = nil
    local function startLiveStudHeartbeat()
        if liveStudHeartbeatConn then return end
        local acc = 0
        local lastX, lastY, lastZ = "", "", ""
        liveStudHeartbeatConn = RunService.Heartbeat:Connect(function(dt)
            if not RCLR_Run.alive or not coordsGui.Parent then return end
            if not coordsGui.Enabled then return end
            hudPulse = hudPulse + dt * 2.2
            local p = (math.sin(hudPulse) + 1) * 0.5
            gDot.BackgroundTransparency = 1 - (0.55 + p * 0.45)
            -- Refresh coordinates up to 60 Hz, but only update labels when changed.
            -- Two decimal places make small, fast movements visible.
            acc = acc + dt
            if acc < (1 / 60) then return end
            acc = acc % (1 / 60)
            local c = LocalPlayer and LocalPlayer.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if hrp then
                local x = string.format("%.2f", hrp.Position.X)
                local y = string.format("%.2f", hrp.Position.Y)
                local z = string.format("%.2f", hrp.Position.Z)
                if x ~= lastX then coordLabels.X.Text = x; lastX = x end
                if y ~= lastY then coordLabels.Y.Text = y; lastY = y end
                if z ~= lastZ then coordLabels.Z.Text = z; lastZ = z end
            elseif lastX ~= "0" then
                coordLabels.X.Text = "0"; coordLabels.Y.Text = "0"; coordLabels.Z.Text = "0"
                lastX, lastY, lastZ = "0", "0", "0"
            end
        end)
    end
    local function stopLiveStudHeartbeat()
        if liveStudHeartbeatConn then
            liveStudHeartbeatConn:Disconnect()
            liveStudHeartbeatConn = nil
        end
    end

    applyTheme()
    startLiveStudHeartbeat()
    RCLR_Run.connections.stud = liveStudHeartbeatConn
    RCLR_Run.connections.coordsGui = { Disconnect = function()
        pcall(function() if coordsGui then coordsGui:Destroy() end end)
    end }
    task.spawn(function()
        while RCLR_Run.alive and coordsGui.Parent and task.wait(0.5) do
            if not RCLR_Run.alive or not coordsGui.Parent then break end
            pcall(applyTheme)
        end
    end)
end)()

local function showPresetPrompt()
    if getgenv().RCLR_PREM_PresetShown then return end
    -- wait for window up to 6s
    local t0 = tick()
    while tick() - t0 < 6 do
        if Window and Window.Tabs then break end
        pcall(waitForWindow)
        task.wait(0.15)
    end
    if not (Window and Window.Tabs) then
        warn("[RCLR PREM] Preset skipped — window not ready")
        return
    end
    getgenv().RCLR_PREM_PresetShown = true
    local sg
    pcall(function()
        sg = Instance.new("ScreenGui")
        sg.Name = "RCLRPresetPrompt"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 99999
        sg.IgnoreGuiInset = true
        sg.Parent = game:GetService("CoreGui")
    end)
    if not sg or not sg.Parent then
        pcall(function() if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then sg.Parent = LocalPlayer.PlayerGui end end)
    end
    if not sg or not sg.Parent then return end

    local overlay
    pcall(function()
        overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 0.45
        overlay.BorderSizePixel = 0
        overlay.Parent = sg
    end)
    if not overlay then return end

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 420, 0, 220)
    card.Position = UDim2.new(0.5, -210, 0.5, -110)
    card.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
    card.BorderSizePixel = 0
    card.Parent = sg
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 10); cc.Parent = card
    local cs = Instance.new("UIStroke"); cs.Color = Color3.fromRGB(55, 55, 62); cs.Thickness = 1.2; cs.Parent = card

    local tb = Instance.new("Frame")
    tb.Size = UDim2.new(1, 0, 0, 4)
    tb.BackgroundColor3 = Color3.fromRGB(90, 180, 90)
    tb.BorderSizePixel = 0
    tb.Parent = card
    local tbc = Instance.new("UICorner"); tbc.CornerRadius = UDim.new(0, 10); tbc.Parent = tb

    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 110, 0, 20)
    badge.Position = UDim2.new(0.5, -55, 0, 18)
    badge.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
    badge.Text = "PRESET CONFIG"
    badge.TextColor3 = Color3.fromRGB(140, 210, 140)
    badge.Font = Enum.Font.GothamBold
    badge.TextSize = 10
    badge.BorderSizePixel = 0
    badge.Parent = card
    local bdc = Instance.new("UICorner"); bdc.CornerRadius = UDim.new(0, 4); bdc.Parent = badge
    local bds = Instance.new("UIStroke"); bds.Color = Color3.fromRGB(70, 130, 70); bds.Thickness = 1; bds.Parent = badge

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -40, 0, 32)
    titleLbl.Position = UDim2.new(0, 20, 0, 46)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "RCLR Lua Prem Preset Configs"
    titleLbl.TextColor3 = Color3.fromRGB(235, 235, 240)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 20
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card

    local subLbl = Instance.new("TextLabel")
    subLbl.Size = UDim2.new(1, -40, 0, 52)
    subLbl.Position = UDim2.new(0, 20, 0, 82)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = "Load the best HVH settings?\nDiscord: discord.gg/ZmN2Djb7m"
    subLbl.TextColor3 = Color3.fromRGB(155, 155, 165)
    subLbl.Font = Enum.Font.Gotham
    subLbl.TextSize = 13
    subLbl.TextXAlignment = Enum.TextXAlignment.Left
    subLbl.TextWrapped = true
    subLbl.Parent = card

    local div = Instance.new("Frame")
    div.Size = UDim2.new(1, -40, 0, 1)
    div.Position = UDim2.new(0, 20, 0, 140)
    div.BackgroundColor3 = Color3.fromRGB(50, 50, 56)
    div.BorderSizePixel = 0
    div.Parent = card

    local function makeBtn(label, bg, hover, xPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 170, 0, 44)
        btn.Position = UDim2.new(0, xPos, 0, 155)
        btn.BackgroundColor3 = bg
        btn.Text = label
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.AutoButtonColor = false
        btn.BorderSizePixel = 0
        btn.Parent = card
        local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 7); bc.Parent = btn
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = hover end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = bg end)
        return btn
    end

    local yBtn = makeBtn("Yes, Load Preset", Color3.fromRGB(34, 130, 54), Color3.fromRGB(44, 160, 68),  20)
    local nBtn = makeBtn("No Thanks",        Color3.fromRGB(160, 38, 38), Color3.fromRGB(190, 50, 50), 230)

    local function applyPreset()
        CFG.VOID_ENABLED = true; CFG.VOID_METHOD = "Quantum"
        cfg.orbitEnabled = false; cfgDodge.predEnabled = true
        antiBaitCFG.enabled = true; aaSettings.enabled = true
        translocCFG.enabled = false
        riotGodmodeCFG.enabled = false; riotAbuserCFG.enabled = true
        CFG.SMART_EVASION = true
        RCLR_Functions.startVoid(); startPredictionV2(); startAntiBaitV2(); RCLR_Functions.startAntiAim(); RCLR_Functions.startRiotAbuser()
        Toggles.VoidToggle:SetValue(true); Toggles.PredToggle:SetValue(true)
        Toggles.AntiBaitToggle:SetValue(true); Toggles.AaToggle:SetValue(true)
        Toggles.RiotAbuserToggle:SetValue(true)
        Toggles.SmartEvasionToggle:SetValue(true)
        Notify("Preset loaded", 3)
    end

    yBtn.MouseButton1Click:Connect(function()
        pcall(function() if sg and sg.Destroy then sg:Destroy() end end)
        task.wait(0.1)
        pcall(applyPreset)
    end)
    nBtn.MouseButton1Click:Connect(function()
        pcall(function() if sg and sg.Destroy then sg:Destroy() end end)
        Notify("Preset skipped.", 2)
    end)
end

-- Register preset so it can be called by loaders, then show it now
getgenv().RCLR_ShowPresetPrompt = showPresetPrompt
-- Show once even if the loading overlay callback misses its window.
task.defer(function()
    task.wait(0.5)
    if not getgenv().RCLR_PREM_PresetShown then
        pcall(showPresetPrompt)
    end
end)
task.spawn(function()
    local t0 = tick()
    while not getgenv().RCLR_PREM_LoadingDone and tick() - t0 < 8 do
        task.wait(0.1)
    end
    if not getgenv().RCLR_PREM_PresetShown then
        pcall(function()
            if showPresetPrompt then showPresetPrompt() end
        end)
    end
end)

if windowReady then
    Notify("RCLR Lua Prem | discord.gg/ZmN2Djb7m", 4)
else
    task.spawn(function()
        task.wait(0.2)
        if waitForWindow() then Notify("RCLR Lua Prem | discord.gg/ZmN2Djb7m", 4) end
    end)
end
-- ============================================================
-- RCLR PREM BUILD MANIFEST -- build 17 (no-padding, real-code trim)
-- ============================================================
-- build...........: 17
-- channel.........: prem
-- target..........: roblox rivals, executor luau
-- changes.........: stripped all padding/comment-only tail block,
--                   removed the pad manifest spam so the file is real code + real comments only
-- size...........: 194,914 bytes (190 KB) real-code + real-comment only, no padding block
-- notes..........: only a single reference comment to setreadonly/rawset remains (safety doc), no metatable writes
-- ============================================================
