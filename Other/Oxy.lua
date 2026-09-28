if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Workspace = workspace
local Camera = workspace.CurrentCamera
local lp = Players.LocalPlayer
local cloneref = cloneref or function(x) return x end
local env = (getgenv and getgenv()) or _G
if env.__ObsidianLocalVisuals then pcall(env.__ObsidianLocalVisuals) end
local connections, restorers = {}, {}
local running = true
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end
connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
    Camera = workspace.CurrentCamera
end)
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local okLibrary, Library = pcall(function()
    return loadstring(game:HttpGet(repo .. "Library.lua"))()
end)
if not okLibrary or not Library then
    warn("Obsidian could not load: " .. tostring(Library))
    return
end
local Window = Library:CreateWindow({
    Title = "oxycodone",
    Center = true, AutoShow = true,
    ToggleKeybind = Enum.KeyCode.RightShift,
})
local Options, Toggles = Library.Options or {}, Library.Toggles or {}
local Tabs = {
    Cosmetics = Window:AddTab("Cosmetics", "sparkles"),
    Weapons = Window:AddTab("Weapons", "swords"),
    Inventory = Window:AddTab("Inventory", "box"),
    World = Window:AddTab("World", "globe"),
    Spoofer = Window:AddTab("Spoofer", "user-round"),
    Misc = Window:AddTab("Misc", "layers"),
    Settings = Window:AddTab("Settings", "settings"),
}
local function notify(message)
    Library:Notify(tostring(message), 5)
end
local function patch(target, name, replacement)
    local old = target[name]
    target[name] = replacement
    table.insert(restorers, function()
        if target[name] == replacement then target[name] = old end
    end)
    return old
end
local function moduleAt(root, names)
    for _, name in ipairs(names) do
        root = root and root:FindFirstChild(name)
        if not root then return nil end
    end
    if not root:IsA("ModuleScript") then return nil end
    local ok, value = pcall(require, root)
    if ok and type(value) == "table" then return value end
    return nil
end
local moduleErrors = {}
local moduleCache = setmetatable({}, {__mode="k"})
local function loadGameModule(root, names)
    local path = table.concat(names, ".")
    local node = root
    for _, name in ipairs(names) do
        node = node and node:FindFirstChild(name)
        if not node then moduleErrors[path] = "not loaded yet"; return nil end
    end
    if not node:IsA("ModuleScript") then moduleErrors[path] = "not a ModuleScript"; return nil end
    if moduleCache[node] then return moduleCache[node] end
    local ok, value = pcall(require, node)
    if ok and type(value) == "table" then
        moduleCache[node] = value
        moduleErrors[path] = nil
        return value
    end
    moduleErrors[path] = tostring(value)
    return nil
end
local Rivals = {Ready=false}
local function resolveRivals()
    local scripts = lp:FindFirstChild("PlayerScripts")
    Rivals.Fighter = Rivals.Fighter or loadGameModule(scripts, {"Controllers","FighterController"})
    Rivals.Enums = Rivals.Enums or loadGameModule(ReplicatedStorage, {"Modules","EnumLibrary"})
    Rivals.Cosmetics = Rivals.Cosmetics or loadGameModule(ReplicatedStorage, {"Modules","CosmeticLibrary"})
    Rivals.ItemLib = Rivals.ItemLib or loadGameModule(ReplicatedStorage, {"Modules","ItemLibrary"})
    Rivals.SeasonLibrary = Rivals.SeasonLibrary or loadGameModule(ReplicatedStorage, {"Modules","SeasonLibrary"})
    Rivals.PlayerDataController = Rivals.PlayerDataController or loadGameModule(scripts, {"Controllers","PlayerDataController"})
    Rivals.Gun = Rivals.Gun or loadGameModule(scripts, {"Modules","ItemTypes","Gun"})
    Rivals.Ready = Rivals.Fighter ~= nil
end
local function getEquippedItem()
    local ctrl = Rivals.Fighter
    if not ctrl then return nil end
    local fighter = ctrl.LocalFighter
    if not fighter and type(ctrl.GetFighter) == "function" then
        local ok, value = pcall(ctrl.GetFighter, ctrl, lp)
        if ok then fighter = value end
    end
    if not fighter and ctrl._player_to_fighter then fighter=ctrl._player_to_fighter[lp] end
    return fighter and fighter.EquippedItem
end

local function getHealth(player)
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health or 0, hum and hum.MaxHealth or 100
end
local function isAlive(player)
    local health = getHealth(player)
    return health > 0
end
local function hpRamp(f)
    return Color3.fromRGB(255,68,54):Lerp(Color3.fromRGB(61,224,122), math.clamp(f or 0,0,1))
end
local function getWeaponName(player)
    local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
    return tool and tool.Name or "?"
end
local State = { Shots = 0, Hits = 0, ESPObjects = {} }

local Config = {
    GameVisuals=false, GVUnlockAll=false, GVUnlockWeapons=false,
    GVWrapInverted=false, GVEveryone=false, GVBirthHook=true,
    GVFinisherClone=true, GVRemember=true, GVRankCharmOn=false,
    GVRankCharmRank="", GVRankCharmLb=0, GVEmotes=false,
    Visuals = false, VisualsPreset = "Neutral", VisualsPerformanceMode = false,
    VisualsFullbright = false,
    VisualsNoFog = false,
    VisualsHolograms = false, VisualsRainbowMap = false,
    VisualsRainbowMapSpeed = 0.15, VisualsStretch = 1.0,
    VisualsStretchMin = 0.5, VisualsStretchMax = 1.2,
    VisualsCameraSway = false,
    VisualsCameraSwayAmount = 0.5,
    VisualsHologramDuration = 3.5, VisualsHologramRange = 300,
    VisualsHologramVisibility = 1.4,
    VisualsHologramColor  = Color3.fromRGB(0, 220, 255),
    VisualsHologramAccent = Color3.fromRGB(255, 60, 200),
    VisualsGrade = "Crisp",
    VisualsGradeStrength = 0.6,
    VisualsBloom = false,
    VisualsBloomIntensity = 1.0,
    VisualsVignette = false,
    VisualsVignetteStrength = 0.6,
    VisualsLetterbox = false,
    VisualsLetterboxSize = 0.10,
    VisualsDOF = false,
    VisualsDOFDistance = 28,
    VisualsDOFBlur = 0.5,
    VisualsHologramStyle = "Orb",
    VisualsHologramLethal = true,
    VisualsHologramLethalColor = Color3.fromRGB(255, 200, 60),
    HUD = false,
    FXHitMarker = true,
    FXHitMarkerColor = Color3.fromRGB(255, 255, 255),
    FXHitMarkerCritColor = Color3.fromRGB(255, 194, 75),
    FXHitMarkerLethalColor = Color3.fromRGB(255, 64, 78),
    FXHitMarkerGap = 5,
    FXHitMarkerLen = 8,
    FXHitMarkerThickness = 2,
    FXHitSound = true,
    FXHitSoundId = "",
    FXKillSoundId = "",
    FXHitSoundVolume = 0.5,
    FXDamageNumbers = true,
    FXDamageAccumWindow = 0.9,
    FXKillBanner = true,
    FXKillBannerColor = Color3.fromRGB(255, 194, 75),
    FXKillFeed = true,
    FXHeadshotSpark = true,
    FXHitFlash = true,
    FXDamageDirection = true,
    FXLowHPVignette = true,
    FXLowHPThreshold = 0.35,
    FXCritDamage = 30,
    FXBeamTracer     = false,
    FXBeamStyle      = "Glow",
    FXBeamHitColor   = Color3.fromRGB(255, 194, 75),
    FXBeamMissColor  = Color3.fromRGB(143, 160, 176),
    FXFovRing        = false,
    FXFovColorA      = Color3.fromRGB(53, 215, 199),
    FXFovColorB      = Color3.fromRGB(255, 194, 75),
    FXFovThickness   = 1.5,
    FXFovDriftSpeed  = 0.15,
    FXFovFill        = false,
    FXFovRotate      = true,
    FXWorldSpark     = false,
    FXBeamWidth0    = 0.18,
    FXBeamWidth1    = 0.04,
    FXBeamDur       = 0.55,
    FXBeamGlowLight = true,
    FXBeamTravel      = true,
    FXBeamTravelSpeed = 1400,
    FXBeamImpact      = true,
    FXWorldSparkBloom = true,
    FXKillPillar      = false,
    FXKillPillarColor = Color3.fromRGB(255, 194, 75),
    FXKillShards      = false,
    FXKillShardsColor = Color3.fromRGB(155, 232, 255),
    FXKillPulse       = false,
    FXKillPulseAmount = 0.6,
    FXFovCasing     = true,
    FXCrosshair          = false,
    FXCrosshairStyle     = "Cross",
    FXCrosshairColor     = Color3.fromRGB(243, 246, 250),
    FXCrosshairDot       = true,
    FXCrosshairGap       = 4,
    FXCrosshairLen       = 7,
    FXCrosshairThickness = 2,
    FXCrosshairOutline   = true,
    FXCrosshairHitPop    = true,
    HUDWatermark      = true,
    HUDWatermarkStats = true,
    FXTargetInfo       = false,
    FXTargetInfoOffset = 110,
    HUDBindList     = false,
    HUDBindListSide = "Left",
    FXHitMarkerStyle = "X",
    FXCrosshairBloom = false,
    HUDCompass       = false,
    HUDCompassWidth  = 380,
    HUDCompassPips   = true,
    HUDThreatArc     = false,
    HUDRangeReadout  = false,
    Weather          = false,
    WeatherType      = "Rain",
    WeatherIntensity = 1.0,
    WeatherMeteors   = false,
    WeatherMeteorRate = 1.0,
    WeatherStarRate  = 1.0,
    WeatherClockDial = false,
    WeatherClockCycleMin = 8,
    WeatherStorm     = false,
    WeatherStormFlash= true,
    WeatherStormMin  = 4,
    WeatherStormVar  = 8,
    WeatherThunderId = "rbxassetid://9113169432",
    WeatherSoundIds  = {
        rain  = "rbxassetid://9112858162",
        wind  = "rbxassetid://9112854440",
        fire  = "rbxassetid://2787093357",
        night = "rbxassetid://9112764573",
        birds = "rbxassetid://9112749254",
    },
    WeatherSoundVolume = 0.35,
    WeatherMood      = true,
    SkyboxPreset        = "Off",
    SkyboxHideCelestial = false,
    WeatherGodRays      = false,
    WeatherRainbow      = false,
    WeatherShootingStars = false,
    WeatherPuddles   = false,
    SpooferNameEnabled        = false,
    SpooferName               = "ProPlayer",
    SpooferDisplayName        = "ProPlayer",
    SpooferLevelEnabled       = false,
    SpooferLevel              = 100,
    SpooferCasualWinsEnabled  = false,
    SpooferCasualWins         = 500,
    SpooferRankedWinsEnabled  = false,
    SpooferRankedWins         = 250,
    SpooferRankedEloEnabled   = false,
    SpooferRankedElo          = 2400,
    SpooferWinPercentEnabled  = false,
    SpooferWinPercent         = 75,
    SpooferWinStreakEnabled   = false,
    SpooferWinStreak          = 25,
    SpooferFavoriteMapEnabled = false,
    SpooferFavoriteMap        = "Arena",
    VMOffsetEnabled      = false,
    VMOffsetX            = 0,
    VMOffsetY            = 0,
    VMOffsetZ            = 0,
    VMOffsetPitch        = 0,
    VMOffsetYaw          = 0,
    VMOffsetRoll         = 0,
    VMChamsEnabled       = false,
    VMChamsMaterial      = "ForceField",
    VMChamsColor         = Color3.fromRGB(53, 215, 199),
    VMChamsTransparency  = 0.5,
    VMDisableTextures    = false,
    FXCrosshairAngle     = 0,
    FXCrosshairSpin      = false,
    FXCrosshairSpinSpeed = 1.0,
    FXCrosshairSniper    = false,
    FXCrosshairBounce    = false,
    FXCrosshairBounceAmt = 4,
    CameraAspectRatioEnabled = false,
    CameraAspectRatioX       = 4,
    CameraAspectRatioY       = 3,
    CameraFovOverride        = false,
    CameraFovAmount          = 90,
    ThirdPersonEnabled       = false,
    ThirdPersonDistance      = 12,

}

local screenDraw
do
    local CoreGui = game:GetService("CoreGui")
    local _layers = {}
    local LAYER_ORDER = { base = 100000, fx = 100100 }
    local LAYER_NAME  = { base = "LH_Overlay", fx = "LH_Overlay_FX" }
    local FONT_MAP = {
        [0] = Enum.Font.Gotham, [1] = Enum.Font.SourceSans,
        [2] = Enum.Font.GothamMedium, [3] = Enum.Font.Code,
        [4] = Enum.Font.GothamBold, [5] = Enum.Font.SourceSansBold,
    }
    local BLACK = Color3.new(0, 0, 0)
    local function op(t) return 1 - (t or 1) end
    local function gui(layer)
        local Lr = _layers[layer]
        if not Lr then Lr = { gui = nil, z = 0, pools = {} }; _layers[layer] = Lr end
        if Lr.gui and Lr.gui.Parent then return Lr.gui end
        local g = Instance.new("ScreenGui")
        g.Name = LAYER_NAME[layer] or "LH_Overlay"
        g.IgnoreGuiInset = true
        g.ResetOnSpawn  = false
        g.DisplayOrder  = LAYER_ORDER[layer] or 100000
        g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        local ok = pcall(function() g.Parent = (gethui and gethui()) or CoreGui end)
        if not ok or not g.Parent then
            pcall(function() g.Parent = lp:FindFirstChildOfClass("PlayerGui") end)
        end
        Lr.gui = g
        return g
    end
    local function build(kind)
        if kind == "Square" then
            local f = Instance.new("Frame")
            f.BorderSizePixel = 0; f.BackgroundTransparency = 1
            f.AnchorPoint = Vector2.new(0, 0); f.Visible = false
            local st = Instance.new("UIStroke")
            st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            st.LineJoinMode = Enum.LineJoinMode.Miter
            st.Enabled = false; st.Parent = f
            local ug = nil
            local function apply(s, k)
                if k == "Position" then if s.Position then f.Position = UDim2.fromOffset(s.Position.X, s.Position.Y) end
                elseif k == "Size" then if s.Size then f.Size = UDim2.fromOffset(s.Size.X, s.Size.Y) end
                elseif k == "Color" then if s.Color then f.BackgroundColor3 = s.Color; st.Color = s.Color end
                elseif k == "Thickness" then st.Thickness = math.max(s.Thickness or 1, 0.1)
                elseif k == "Transparency" or k == "Filled" then
                    local o = op(s.Transparency)
                    if s.Filled == false then f.BackgroundTransparency = 1; st.Enabled = true; st.Transparency = o
                    else f.BackgroundTransparency = o; st.Enabled = false end
                elseif k == "Gradient" then
                    if s.Gradient then
                        if not ug then ug = Instance.new("UIGradient"); ug.Parent = st end
                        ug.Color = s.Gradient; ug.Enabled = true
                    elseif ug then ug.Enabled = false end
                elseif k == "GradientRotation" then if ug then ug.Rotation = s.GradientRotation or 0 end
                elseif k == "Visible" then f.Visible = s.Visible and true or false end
            end
            return f, apply
        elseif kind == "Line" then
            local f = Instance.new("Frame")
            f.BorderSizePixel = 0; f.AnchorPoint = Vector2.new(0.5, 0.5); f.Visible = false
            local _len = nil
            local function geom(s)
                if not (s.From and s.To) then return end
                local dx, dy = s.To.X - s.From.X, s.To.Y - s.From.Y
                local len = math.sqrt(dx * dx + dy * dy)
                _len = len
                f.Position = UDim2.fromOffset((s.From.X + s.To.X) * 0.5, (s.From.Y + s.To.Y) * 0.5)
                f.Size     = UDim2.fromOffset(len, math.max(s.Thickness or 1, 0.1))
                f.Rotation = math.deg(math.atan2(dy, dx))
            end
            local function apply(s, k)
                if k == "To" then geom(s)
                elseif k == "From" then
                elseif k == "Thickness" then if _len then f.Size = UDim2.fromOffset(_len, math.max(s.Thickness or 1, 0.1)) end
                elseif k == "Color" then if s.Color then f.BackgroundColor3 = s.Color end
                elseif k == "Transparency" then f.BackgroundTransparency = op(s.Transparency)
                elseif k == "Visible" then f.Visible = s.Visible and true or false end
            end
            return f, apply
        elseif kind == "Text" then
            local t = Instance.new("TextLabel")
            t.BackgroundTransparency = 1; t.BorderSizePixel = 0; t.Visible = false
            t.AutomaticSize = Enum.AutomaticSize.XY; t.RichText = false
            t.TextYAlignment = Enum.TextYAlignment.Top
            t.AnchorPoint = Vector2.new(0, 0); t.TextXAlignment = Enum.TextXAlignment.Left
            local st = Instance.new("UIStroke"); st.Thickness = 1; st.Color = BLACK
            st.LineJoinMode = Enum.LineJoinMode.Miter
            st.Enabled = false; st.Parent = t
            local function apply(s, k)
                if k == "Text" then t.Text = tostring(s.Text or "")
                elseif k == "Size" then t.TextSize = math.max(s.Size or 12, 1)
                elseif k == "Font" then t.Font = FONT_MAP[s.Font or 2] or Enum.Font.GothamMedium
                elseif k == "Color" then if s.Color then t.TextColor3 = s.Color end
                elseif k == "Center" or k == "RightAlign" then
                    if s.Center then t.AnchorPoint = Vector2.new(0.5, 0); t.TextXAlignment = Enum.TextXAlignment.Center
                    elseif s.RightAlign then t.AnchorPoint = Vector2.new(1, 0); t.TextXAlignment = Enum.TextXAlignment.Right
                    else t.AnchorPoint = Vector2.new(0, 0); t.TextXAlignment = Enum.TextXAlignment.Left end
                    if s.Position then t.Position = UDim2.fromOffset(s.Position.X, s.Position.Y) end
                elseif k == "Position" then if s.Position then t.Position = UDim2.fromOffset(s.Position.X, s.Position.Y) end
                elseif k == "Outline" then st.Enabled = s.Outline and true or false
                elseif k == "OutlineColor" then if s.OutlineColor then st.Color = s.OutlineColor end
                elseif k == "Transparency" then local o = op(s.Transparency); t.TextTransparency = o; st.Transparency = o
                elseif k == "Visible" then t.Visible = s.Visible and true or false end
            end
            return t, apply
        elseif kind == "Circle" then
            local f = Instance.new("Frame")
            f.BorderSizePixel = 0; f.AnchorPoint = Vector2.new(0.5, 0.5)
            f.BackgroundTransparency = 1; f.Visible = false
            local uc = Instance.new("UICorner"); uc.CornerRadius = UDim.new(1, 0); uc.Parent = f
            local st = Instance.new("UIStroke"); st.Enabled = false; st.Parent = f
            local function apply(s, k)
                if k == "Radius" then local d = 2 * (s.Radius or 0); f.Size = UDim2.fromOffset(d, d)
                elseif k == "Position" then if s.Position then f.Position = UDim2.fromOffset(s.Position.X, s.Position.Y) end
                elseif k == "Color" then if s.Color then f.BackgroundColor3 = s.Color; st.Color = s.Color end
                elseif k == "Thickness" then st.Thickness = math.max(s.Thickness or 1, 0.1)
                elseif k == "Transparency" or k == "Filled" then
                    local o = op(s.Transparency)
                    if s.Filled == false then f.BackgroundTransparency = 1; st.Enabled = true; st.Transparency = o
                    else f.BackgroundTransparency = o; st.Enabled = false end
                elseif k == "Visible" then f.Visible = s.Visible and true or false end
            end
            return f, apply
        elseif kind == "Triangle" then
            local box = Instance.new("Frame")
            box.BackgroundTransparency = 1; box.BorderSizePixel = 0
            box.AnchorPoint = Vector2.new(0, 0); box.Position = UDim2.fromOffset(0, 0)
            box.Size = UDim2.fromScale(1, 1); box.Visible = false
            local BLK = Color3.new(0, 0, 0)
            local function mkleg(col)
                local l = Instance.new("Frame")
                l.BorderSizePixel = 0; l.AnchorPoint = Vector2.new(0.5, 0.5)
                l.BackgroundColor3 = col or Color3.new(1, 1, 1); l.Visible = false; l.Parent = box
                return l
            end
            local cas1, cas2 = mkleg(BLK), mkleg(BLK)
            local leg1, leg2, leg3, leg4, leg5 = mkleg(), mkleg(), mkleg(), mkleg(), mkleg()
            local legs = { leg1, leg2, leg3, leg4, leg5 }
            local stem = mkleg()
            local function mid(p, q) return Vector2.new((p.X + q.X) * 0.5, (p.Y + q.Y) * 0.5) end
            local function leg(l, p, q, thick)
                local dx, dy = q.X - p.X, q.Y - p.Y
                local len = math.sqrt(dx * dx + dy * dy)
                l.Position = UDim2.fromOffset((p.X + q.X) * 0.5, (p.Y + q.Y) * 0.5)
                l.Size     = UDim2.fromOffset(math.max(len, 1), thick)
                l.Rotation = math.deg(math.atan2(dy, dx))
                l.Visible  = true
            end
            local function geom(s)
                local A, B, C = s.PointA, s.PointB, s.PointC
                if not (A and B and C) then return end
                local dA = (A - mid(B, C)).Magnitude
                local dB = (B - mid(A, C)).Magnitude
                local dC = (C - mid(A, B)).Magnitude
                local apex, b1, b2
                if dA >= dB and dA >= dC then apex, b1, b2 = A, B, C
                elseif dB >= dC then apex, b1, b2 = B, A, C
                else apex, b1, b2 = C, A, B end
                local base = mid(b1, b2)
                local h    = math.max((apex - base).Magnitude, 1)
                if s.Filled == true then
                    cas1.Visible = false; cas2.Visible = false; stem.Visible = false
                    local ft = h / 5 + 1
                    for k = 1, 5 do
                        local t = (k - 0.5) / 5
                        leg(legs[k], b1:Lerp(apex, t), b2:Lerp(apex, t), ft)
                    end
                else
                    local thick = math.clamp(h * 0.34, 3, 6)
                    leg(cas1, apex, b1, thick + 2)
                    leg(cas2, apex, b2, thick + 2)
                    leg(leg1, apex, b1, thick)
                    leg(leg2, apex, b2, thick)
                    local dir = apex - base
                    if dir.Magnitude > 0 then dir = dir.Unit else dir = Vector2.new(0, -1) end
                    leg(stem, apex, apex + dir * (h * 0.5), thick)
                    leg3.Visible = false; leg4.Visible = false; leg5.Visible = false
                end
            end
            local function apply(s, k)
                if k == "PointC" or k == "Filled" then geom(s)
                elseif k == "PointA" or k == "PointB" then
                elseif k == "Color" then
                    if s.Color then
                        leg1.BackgroundColor3 = s.Color; leg2.BackgroundColor3 = s.Color
                        leg3.BackgroundColor3 = s.Color; leg4.BackgroundColor3 = s.Color
                        leg5.BackgroundColor3 = s.Color; stem.BackgroundColor3 = s.Color
                    end
                elseif k == "Transparency" then
                    local o = op(s.Transparency)
                    leg1.BackgroundTransparency = o; leg2.BackgroundTransparency = o
                    leg3.BackgroundTransparency = o; leg4.BackgroundTransparency = o
                    leg5.BackgroundTransparency = o; stem.BackgroundTransparency = o
                elseif k == "Visible" then box.Visible = s.Visible and true or false end
            end
            return box, apply
        end
        return nil
    end
    screenDraw = function(kind, layer)
        layer = layer or "base"
        local Lr = _layers[layer]
        if not Lr then Lr = { gui = nil, z = 0, pools = {} }; _layers[layer] = Lr end
        local pool = Lr.pools[kind]; if not pool then pool = {}; Lr.pools[kind] = pool end
        local inst, applyFn
        local reused = table.remove(pool)
        if reused then
            inst, applyFn = reused.inst, reused.apply
        else
            inst, applyFn = build(kind)
            if not inst then return nil end
            inst.Parent = gui(layer)
        end
        Lr.z = Lr.z + 1; inst.ZIndex = Lr.z
        inst.Visible = false
        local state = {}
        return setmetatable({}, {
            __index = function(_, k)
                if k == "Remove" then
                    return function()
                        inst.Visible = false
                        pool[#pool + 1] = { inst = inst, apply = applyFn }
                    end
                elseif k == "TextBounds" then
                    return inst.TextBounds
                end
                return state[k]
            end,
            __newindex = function(_, k, v)
                if state[k] == v then return end
                state[k] = v
                applyFn(state, k)
            end,
        })
    end
end

local Visuals = {}
;(function()
    local _origLighting, _origClones = nil, {}
    local _hologramFolder, _hologramCooldowns = nil, {}
    local _stretchBound, _rainbowConn = false, nil
    local _rainbowParts, _rainbowHue, _rainbowBatchIdx = {}, 0, 1
    local _perfBackup, _origParticleRates = nil, {}
    local _reassertConn, _reassertLastT = nil, 0
    local LIGHTING_PROPS = {
        "Brightness","ExposureCompensation","GlobalShadows","ShadowSoftness",
        "EnvironmentDiffuseScale","EnvironmentSpecularScale","ClockTime",
        "OutdoorAmbient","Ambient","FogEnd","FogStart","FogColor",
        "ColorShift_Top","ColorShift_Bottom",
    }
    local function snapshotLighting()
        if _origLighting then return end
        _origLighting = {}
        for _, p in ipairs(LIGHTING_PROPS) do
            local ok, v = pcall(function() return Lighting[p] end)
            if ok then _origLighting[p] = v end
        end
        for _, c in ipairs(Lighting:GetChildren()) do
            if not c:GetAttribute("VS_Custom") then
                local ok, clone = pcall(function() return c:Clone() end)
                if ok and clone then table.insert(_origClones, clone) end
            end
        end
    end
    local function clearTagged()
        for _, c in ipairs(Lighting:GetChildren()) do
            if c:GetAttribute("VS_Custom") then c:Destroy() end
        end
    end
    local function restore()
        if not _origLighting then return end
        clearTagged()
        for k, v in pairs(_origLighting) do pcall(function() Lighting[k] = v end) end
        local exist = {}
        for _, c in ipairs(Lighting:GetChildren()) do exist[c.Name] = true end
        for _, clone in ipairs(_origClones) do
            if not exist[clone.Name] then clone:Clone().Parent = Lighting end
        end
    end
    local function fx(cls, props)
        local f = Instance.new(cls)
        f:SetAttribute("VS_Custom", true)
        for k, v in pairs(props) do f[k] = v end
        f.Parent = Lighting
        return f
    end
    local Presets = {}
    Presets.Neutral = function()
        clearTagged()
        Lighting.Brightness = 2; Lighting.ExposureCompensation = 0
        Lighting.GlobalShadows = false; Lighting.ShadowSoftness = 0.2
        Lighting.EnvironmentDiffuseScale = 0.5; Lighting.EnvironmentSpecularScale = 0.5
        Lighting.ClockTime = 14; Lighting.OutdoorAmbient = Color3.fromRGB(70,70,70)
        Lighting.Ambient = Color3.fromRGB(0,0,0); Lighting.FogEnd = 100000
        fx("Atmosphere", { Density=0.3, Offset=0.25, Color=Color3.fromRGB(199,199,199),
            Decay=Color3.fromRGB(106,112,125), Glare=0, Haze=0 })
    end
    Presets.Cyberpunk = function()
        clearTagged()
        Lighting.Brightness = 2.6; Lighting.ExposureCompensation = 0.5
        Lighting.GlobalShadows = false; Lighting.ShadowSoftness = 0.7
        Lighting.EnvironmentDiffuseScale = 0.7; Lighting.EnvironmentSpecularScale = 1
        Lighting.ClockTime = 0; Lighting.OutdoorAmbient = Color3.fromRGB(120,80,165)
        Lighting.Ambient = Color3.fromRGB(80,55,120)
        fx("Atmosphere", { Density=0.3, Offset=0.3, Color=Color3.fromRGB(160,70,215),
            Decay=Color3.fromRGB(75,200,240), Glare=2.2, Haze=1 })
        fx("BloomEffect", { Intensity=1.15, Size=24, Threshold=0.72 })
        fx("ColorCorrectionEffect", { Brightness=0.04, Contrast=0.2, Saturation=0.45,
            TintColor=Color3.fromRGB(220,195,255) })
    end
    Presets.Anime = function()
        clearTagged()
        Lighting.Brightness = 2.3; Lighting.ExposureCompensation = 0.2
        Lighting.GlobalShadows = false; Lighting.ShadowSoftness = 0.7
        Lighting.EnvironmentDiffuseScale = 0.7; Lighting.EnvironmentSpecularScale = 0.7
        Lighting.ClockTime = 15; Lighting.OutdoorAmbient = Color3.fromRGB(150,140,170)
        Lighting.Ambient = Color3.fromRGB(95,85,120)
        fx("Atmosphere", { Density=0.28, Offset=0.35, Color=Color3.fromRGB(255,200,230),
            Decay=Color3.fromRGB(150,195,255), Glare=1, Haze=0.8 })
        fx("BloomEffect", { Intensity=1.0, Size=26, Threshold=0.8 })
        fx("ColorCorrectionEffect", { Brightness=0.03, Contrast=0.14, Saturation=0.32,
            TintColor=Color3.fromRGB(255,228,242) })
    end
    Presets.Sunset = function()
        clearTagged()
        Lighting.Brightness = 2.3; Lighting.ExposureCompensation = 0.4
        Lighting.GlobalShadows = false; Lighting.ShadowSoftness = 0.5
        Lighting.EnvironmentDiffuseScale = 0.75; Lighting.EnvironmentSpecularScale = 0.9
        Lighting.ClockTime = 17.75; Lighting.OutdoorAmbient = Color3.fromRGB(185,115,80)
        Lighting.Ambient = Color3.fromRGB(105,60,45)
        fx("Atmosphere", { Density=0.38, Offset=0.55, Color=Color3.fromRGB(255,150,80),
            Decay=Color3.fromRGB(255,105,60), Glare=1.8, Haze=1.6 })
        fx("BloomEffect", { Intensity=0.9, Size=24, Threshold=0.78 })
        fx("ColorCorrectionEffect", { Brightness=0.03, Contrast=0.16, Saturation=0.32,
            TintColor=Color3.fromRGB(255,195,150) })
    end
    Presets.Vaporwave = function()
        clearTagged()
        Lighting.Brightness = 2.3; Lighting.ExposureCompensation = 0.4
        Lighting.GlobalShadows = false; Lighting.ShadowSoftness = 0.7
        Lighting.EnvironmentDiffuseScale = 0.6; Lighting.EnvironmentSpecularScale = 0.9
        Lighting.ClockTime = 18.4; Lighting.OutdoorAmbient = Color3.fromRGB(150,90,165)
        Lighting.Ambient = Color3.fromRGB(95,60,120)
        fx("Atmosphere", { Density=0.34, Offset=0.4, Color=Color3.fromRGB(255,130,205),
            Decay=Color3.fromRGB(110,200,255), Glare=1.8, Haze=1.3 })
        fx("BloomEffect", { Intensity=1.05, Size=26, Threshold=0.74 })
        fx("ColorCorrectionEffect", { Brightness=0.04, Contrast=0.18, Saturation=0.38,
            TintColor=Color3.fromRGB(255,205,240) })
    end
    Presets.Void = function()
        clearTagged()
        Lighting.Brightness = 2.0; Lighting.ExposureCompensation = 0.25
        Lighting.GlobalShadows = false; Lighting.ShadowSoftness = 0.9
        Lighting.EnvironmentDiffuseScale = 0.5; Lighting.EnvironmentSpecularScale = 0.7
        Lighting.ClockTime = 0; Lighting.OutdoorAmbient = Color3.fromRGB(85,95,135)
        Lighting.Ambient = Color3.fromRGB(55,62,95)
        fx("Atmosphere", { Density=0.35, Offset=0.2, Color=Color3.fromRGB(55,65,110),
            Decay=Color3.fromRGB(95,110,180), Glare=0.3, Haze=0.8 })
        fx("BloomEffect", { Intensity=0.8, Size=22, Threshold=0.76 })
        fx("ColorCorrectionEffect", { Brightness=0.03, Contrast=0.16, Saturation=-0.2,
            TintColor=Color3.fromRGB(190,200,255) })
    end
    Presets.Clarity = function()
        clearTagged()
        Lighting.Brightness = 2.6; Lighting.ExposureCompensation = 0
        Lighting.GlobalShadows = false; Lighting.ShadowSoftness = 1
        Lighting.EnvironmentDiffuseScale = 0.2; Lighting.EnvironmentSpecularScale = 0.1
        Lighting.ClockTime = 14; Lighting.OutdoorAmbient = Color3.fromRGB(150,150,155)
        Lighting.Ambient = Color3.fromRGB(120,120,125); Lighting.FogEnd = 1000000
        fx("ColorCorrectionEffect", { Brightness=0.05, Contrast=0.25, Saturation=-0.2,
            TintColor=Color3.fromRGB(255,255,255) })
    end
    Presets.Toxic = function()
        clearTagged()
        Lighting.Brightness = 2.2; Lighting.ExposureCompensation = 0.35
        Lighting.GlobalShadows = false; Lighting.ShadowSoftness = 0.7
        Lighting.EnvironmentDiffuseScale = 0.6; Lighting.EnvironmentSpecularScale = 0.8
        Lighting.ClockTime = 1; Lighting.OutdoorAmbient = Color3.fromRGB(80,135,70)
        Lighting.Ambient = Color3.fromRGB(45,85,50)
        fx("Atmosphere", { Density=0.34, Offset=0.35, Color=Color3.fromRGB(95,220,110),
            Decay=Color3.fromRGB(55,180,80), Glare=1.8, Haze=1.4 })
        fx("BloomEffect", { Intensity=1.1, Size=24, Threshold=0.74 })
        fx("ColorCorrectionEffect", { Brightness=0.04, Contrast=0.2, Saturation=0.45,
            TintColor=Color3.fromRGB(210,255,205) })
    end
    Presets.Sakura = function()
        clearTagged()
        Lighting.Brightness = 2.2; Lighting.ExposureCompensation = 0.35
        Lighting.GlobalShadows = false; Lighting.ShadowSoftness = 0.8
        Lighting.EnvironmentDiffuseScale = 0.7; Lighting.EnvironmentSpecularScale = 0.7
        Lighting.ClockTime = 15.5; Lighting.OutdoorAmbient = Color3.fromRGB(200,155,180)
        Lighting.Ambient = Color3.fromRGB(120,85,110)
        fx("Atmosphere", { Density=0.3, Offset=0.4, Color=Color3.fromRGB(255,205,225),
            Decay=Color3.fromRGB(255,175,215), Glare=1.2, Haze=1 })
        fx("BloomEffect", { Intensity=1.1, Size=26, Threshold=0.78 })
        fx("ColorCorrectionEffect", { Brightness=0.04, Contrast=0.15, Saturation=0.28,
            TintColor=Color3.fromRGB(255,225,240) })
    end
    Presets.Nebula = function()
        clearTagged()
        Lighting.Brightness = 2.2; Lighting.ExposureCompensation = 0.4
        Lighting.GlobalShadows = false; Lighting.ShadowSoftness = 0.9
        Lighting.EnvironmentDiffuseScale = 0.55; Lighting.EnvironmentSpecularScale = 0.85
        Lighting.ClockTime = 0; Lighting.OutdoorAmbient = Color3.fromRGB(128,94,168)
        Lighting.Ambient = Color3.fromRGB(82,60,120)
        fx("Atmosphere", { Density=0.34, Offset=0.25, Color=Color3.fromRGB(120,70,180),
            Decay=Color3.fromRGB(220,90,190), Glare=1.4, Haze=1.1 })
        fx("BloomEffect", { Intensity=1.15, Size=24, Threshold=0.72 })
        fx("ColorCorrectionEffect", { Brightness=0.03, Contrast=0.2, Saturation=0.4,
            TintColor=Color3.fromRGB(235,205,255) })
    end
    local PresetScalars = {
        Neutral   = { Brightness=2,   ExposureCompensation=0,    ClockTime=14,   OutdoorAmbient=Color3.fromRGB(70,70,70),
                      Ambient=Color3.fromRGB(0,0,0),      FogEnd=100000,
                      EnvironmentDiffuseScale=0.5,  EnvironmentSpecularScale=0.5 },
        Clarity   = { Brightness=2.6, ExposureCompensation=0,    ClockTime=14,   OutdoorAmbient=Color3.fromRGB(150,150,155),
                      Ambient=Color3.fromRGB(120,120,125), FogEnd=1000000,
                      EnvironmentDiffuseScale=0.2,  EnvironmentSpecularScale=0.1 },
        Cyberpunk = { Brightness=2.6, ExposureCompensation=0.5,  ClockTime=0,    OutdoorAmbient=Color3.fromRGB(120,80,165),
                      Ambient=Color3.fromRGB(80,55,120),
                      EnvironmentDiffuseScale=0.7,  EnvironmentSpecularScale=1 },
        Anime     = { Brightness=2.3, ExposureCompensation=0.2,  ClockTime=15,   OutdoorAmbient=Color3.fromRGB(150,140,170),
                      Ambient=Color3.fromRGB(95,85,120),
                      EnvironmentDiffuseScale=0.7,  EnvironmentSpecularScale=0.7 },
        Sunset    = { Brightness=2.3, ExposureCompensation=0.4,  ClockTime=17.75, OutdoorAmbient=Color3.fromRGB(185,115,80),
                      Ambient=Color3.fromRGB(105,60,45),
                      EnvironmentDiffuseScale=0.75, EnvironmentSpecularScale=0.9 },
        Vaporwave = { Brightness=2.3, ExposureCompensation=0.4,  ClockTime=18.4, OutdoorAmbient=Color3.fromRGB(150,90,165),
                      Ambient=Color3.fromRGB(95,60,120),
                      EnvironmentDiffuseScale=0.6,  EnvironmentSpecularScale=0.9 },
        Toxic     = { Brightness=2.2, ExposureCompensation=0.35, ClockTime=1,    OutdoorAmbient=Color3.fromRGB(80,135,70),
                      Ambient=Color3.fromRGB(45,85,50),
                      EnvironmentDiffuseScale=0.6,  EnvironmentSpecularScale=0.8 },
        Void      = { Brightness=2.0, ExposureCompensation=0.25, ClockTime=0,    OutdoorAmbient=Color3.fromRGB(85,95,135),
                      Ambient=Color3.fromRGB(55,62,95),
                      EnvironmentDiffuseScale=0.5,  EnvironmentSpecularScale=0.7 },
        Sakura    = { Brightness=2.2, ExposureCompensation=0.35, ClockTime=15.5, OutdoorAmbient=Color3.fromRGB(200,155,180),
                      Ambient=Color3.fromRGB(120,85,110),
                      EnvironmentDiffuseScale=0.7,  EnvironmentSpecularScale=0.7 },
        Nebula    = { Brightness=2.2, ExposureCompensation=0.4,  ClockTime=0,    OutdoorAmbient=Color3.fromRGB(128,94,168),
                      Ambient=Color3.fromRGB(82,60,120),
                      EnvironmentDiffuseScale=0.55, EnvironmentSpecularScale=0.85 },
    }
    local _WHITE = Color3.new(1, 1, 1)
    local function applyFullbrightOverride()
        if not Config.VisualsFullbright then return end
        pcall(function() if Lighting.Ambient ~= _WHITE then Lighting.Ambient = _WHITE end end)
        pcall(function() if Lighting.OutdoorAmbient ~= _WHITE then Lighting.OutdoorAmbient = _WHITE end end)
        pcall(function() if Lighting.GlobalShadows ~= false then Lighting.GlobalShadows = false end end)
        pcall(function() if Lighting.Brightness < 2 then Lighting.Brightness = 2 end end)
    end
    local function applyFogOverride()
        if not Config.VisualsNoFog then return end
        pcall(function() if Lighting.FogEnd ~= 1e6 then Lighting.FogEnd = 1e6 end end)
        pcall(function() if Lighting.FogStart ~= 1e6 then Lighting.FogStart = 1e6 end end)
        for _, c in ipairs(Lighting:GetChildren()) do
            if c:IsA("Atmosphere") then
                pcall(function() if c.Density ~= 0 then c.Density = 0 end end)
            end
        end
    end
    local function cfg(key, default)
        local v = Config[key]
        if v == nil then return default end
        return v
    end
    local _GRADES = {
        Crisp = { B = 0.03,  C = 0.20, S = 0.18,  tint = _WHITE },
        Cold  = { B = -0.03, C = 0.28, S = -0.22, tint = Color3.fromRGB(196, 220, 255) },
        Warm  = { B = 0.04,  C = 0.22, S = 0.15,  tint = Color3.fromRGB(255, 222, 180) },
        Comp  = { B = -0.01, C = 0.40, S = 0.28,  tint = Color3.fromRGB(255, 248, 236) },
    }
    local _gradeFx = nil
    local function getGradeFx()
        if _gradeFx and _gradeFx.Parent then return _gradeFx end
        local cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "_vs_grade"
        cc:SetAttribute("VS_Grade", true)
        cc.Parent = Lighting
        _gradeFx = cc
        return cc
    end
    local function reassertGrade()
        local g = _GRADES[cfg("VisualsGrade", "None")]
        if not g then
            if _gradeFx and _gradeFx.Parent then
                pcall(function() if _gradeFx.Enabled then _gradeFx.Enabled = false end end)
            end
            return
        end
        local s  = math.clamp(cfg("VisualsGradeStrength", 1), 0, 1)
        local tB, tC, tS = g.B * s, g.C * s, g.S * s
        local tT = g.tint:Lerp(_WHITE, 1 - s)
        local cc = getGradeFx()
        pcall(function()
            if not cc.Enabled then cc.Enabled = true end
            if math.abs(cc.Brightness - tB) > 0.001 then cc.Brightness = tB end
            if math.abs(cc.Contrast   - tC) > 0.001 then cc.Contrast   = tC end
            if math.abs(cc.Saturation - tS) > 0.001 then cc.Saturation = tS end
            if cc.TintColor ~= tT then cc.TintColor = tT end
        end)
    end
    local function clearGrade()
        if _gradeFx then pcall(function() _gradeFx:Destroy() end); _gradeFx = nil end
    end
    local _bloomFx = nil
    local function getBloomFx()
        if _bloomFx and _bloomFx.Parent then return _bloomFx end
        local b = Instance.new("BloomEffect")
        b.Name = "_vs_bloom"; b:SetAttribute("VS_Bloom", true)
        b.Size = 24; b.Threshold = 0.8; b.Intensity = 0
        b.Parent = Lighting
        _bloomFx = b
        return b
    end
    local function reassertBloom()
        if not cfg("VisualsBloom", false) then
            if _bloomFx and _bloomFx.Parent then
                pcall(function() if _bloomFx.Enabled then _bloomFx.Enabled = false end end)
            end
            return
        end
        local tI = math.clamp(cfg("VisualsBloomIntensity", 1), 0, 3)
        local b = getBloomFx()
        pcall(function()
            if not b.Enabled then b.Enabled = true end
            if math.abs(b.Intensity - tI) > 0.01 then b.Intensity = tI end
        end)
    end
    local function clearBloom()
        if _bloomFx then pcall(function() _bloomFx:Destroy() end); _bloomFx = nil end
    end
    local function reassertScalars()
        local sc = PresetScalars[State.VisualsCurrentPreset or Config.VisualsPreset]
        if sc then
            for k, v in pairs(sc) do pcall(function() if Lighting[k] ~= v then Lighting[k] = v end end) end
            pcall(function() if Lighting.GlobalShadows ~= false then Lighting.GlobalShadows = false end end)
        end
        applyFullbrightOverride()
        applyFogOverride()
        reassertGrade()
        reassertBloom()
    end
    local function startReassert()
        if _reassertConn then return end
        _reassertConn = RunService.Heartbeat:Connect(function()
            if not Config.Visuals or Config.VisualsPerformanceMode then return end
            local now = tick()
            if (now - _reassertLastT) < 1.0 then return end
            _reassertLastT = now
            reassertScalars()
        end)
    end
    local function stopReassert()
        if _reassertConn then _reassertConn:Disconnect(); _reassertConn = nil end
    end
    Visuals.PresetOrder = { "Neutral", "Clarity", "Cyberpunk", "Anime", "Sunset", "Vaporwave", "Toxic", "Void", "Sakura", "Nebula" }
    local function applyPreset(name)
        if not Config.Visuals or Config.VisualsPerformanceMode then return end
        local fn = Presets[name]; if not fn then return end
        pcall(fn); State.VisualsCurrentPreset = name; Config.VisualsPreset = name
        reassertGrade()
        reassertBloom()
    end
    local function getHoloFolder()
        if _hologramFolder and _hologramFolder.Parent then return _hologramFolder end
        local f = Instance.new("Folder"); f.Name = "_vs_holos"; f.Parent = Workspace
        _hologramFolder = f; return f
    end
    local _GOLD = Color3.fromRGB(255, 200, 60)
    local _EDGE    = Color3.fromRGB(155, 232, 255)
    local _VISIBLE = Color3.fromRGB(41, 224, 255)
    local function easeInOut(a) return a * a * (3 - 2 * a) end
    local HOLO_SKEL_R15 = {
        {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
        {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
        {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
        {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
        {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
    }
    local HOLO_SKEL_R6 = {
        {"Head","Torso"},
        {"Torso","Left Arm"},{"Torso","Right Arm"},
        {"Torso","Left Leg"},{"Torso","Right Leg"},
    }
    local function fadePop(container, parts, hl, dur, tr0)
        tr0 = tr0 or 0.55
        local startT = tick()
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not container.Parent then if conn then conn:Disconnect() end return end
            local a  = math.clamp((tick() - startT) / dur, 0, 1)
            local e  = easeInOut(a)
            local tr = tr0 + (1 - tr0) * e
            for _, b in ipairs(parts) do b.Transparency = tr end
            if hl then hl.OutlineTransparency = e end
            if a >= 1 and conn then conn:Disconnect() end
        end)
        Debris:AddItem(container, dur + 0.2)
    end
    local function popSkeleton(char, dur, color)
        local vis = math.clamp(cfg("VisualsHologramVisibility", 1.4), 0.2, 2)
        local tr0 = math.clamp(1 - 0.45 * vis, 0, 0.91)
        local hum  = char:FindFirstChildOfClass("Humanoid")
        local isR6 = (hum and hum.RigType == Enum.HumanoidRigType.R6) or (char:FindFirstChild("Torso") ~= nil)
        local rig  = isR6 and HOLO_SKEL_R6 or HOLO_SKEL_R15
        local model = Instance.new("Model")
        model.Name = "_hs" .. math.random(10000, 99999)
        local parts, n = {}, 0
        for _, pair in ipairs(rig) do
            local a, b = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
            if a and b then
                local ap, bp = a.Position, b.Position
                local len = (bp - ap).Magnitude
                if len > 0.05 and len < 20 then
                    local bone = Instance.new("Part")
                    bone.Shape = Enum.PartType.Cylinder
                    bone.Size = Vector3.new(len, 0.1 + 0.06 * vis, 0.1 + 0.06 * vis)
                    bone.Material = Enum.Material.Neon
                    bone.Color = color
                    bone.Transparency = tr0
                    bone.Anchored = true; bone.CanCollide = false; bone.CanQuery = false
                    bone.CanTouch = false; bone.CastShadow = false; bone.Massless = true
                    bone:SetAttribute("VS_Holo", true)
                    bone.CFrame = CFrame.lookAt((ap + bp) * 0.5, bp) * CFrame.Angles(0, math.rad(90), 0)
                    bone.Parent = model
                    n = n + 1; parts[n] = bone
                end
            end
        end
        if n == 0 then model:Destroy(); return end
        model.Parent = getHoloFolder()
        fadePop(model, parts, nil, dur, tr0)
    end
    local _wraiths = {}
    local function wraithCount()
        local n = 0
        for i = #_wraiths, 1, -1 do
            local m = _wraiths[i]
            if m and m.Parent then n = n + 1 else table.remove(_wraiths, i) end
        end
        return n
    end
    local STRIP_CLASSES = {
        "Humanoid","Sound","ParticleEmitter","Trail","Beam","Fire","Smoke","Sparkles",
        "ForceField","Highlight","BillboardGui","SurfaceGui","BaseScript",
    }
    local function popWraith(char, dur, color)
        if wraithCount() >= 4 then return end
        local vis = math.clamp(cfg("VisualsHologramVisibility", 1.4), 0.2, 2)
        local tr0 = math.clamp(1 - 0.45 * vis, 0, 0.91)
        local clone
        pcall(function()
            local was = char.Archivable
            char.Archivable = true
            clone = char:Clone()
            char.Archivable = was
        end)
        if not clone then return end
        clone.Name = "_hw" .. math.random(10000, 99999)
        local parts, n = {}, 0
        for _, d in ipairs(clone:GetDescendants()) do
            local strip = false
            for _, cls in ipairs(STRIP_CLASSES) do
                if d:IsA(cls) then strip = true break end
            end
            if strip then
                pcall(function() d:Destroy() end)
            elseif d:IsA("BasePart") then
                d.Anchored = true; d.CanCollide = false; d.CanQuery = false
                d.CanTouch = false; d.CastShadow = false; d.Massless = true
                d:SetAttribute("VS_Holo", true)
                if d.Transparency < 0.98 then
                    d.Material = Enum.Material.ForceField
                    d.Color = color
                    d.Transparency = tr0
                    n = n + 1; parts[n] = d
                else
                    d.Transparency = 1
                end
            end
        end
        if n == 0 then clone:Destroy(); return end
        clone:SetAttribute("VS_Holo", true)
        clone.Parent = getHoloFolder()
        local hl
        pcall(function()
            local h = Instance.new("Highlight")
            h.FillTransparency = 1
            h.OutlineColor = _WHITE
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Adornee = clone
            h.Parent = clone
            hl = h
        end)
        table.insert(_wraiths, clone)
        fadePop(clone, parts, hl, dur, tr0)
    end
    local function createHologram(character, lethal)
        if not character or not character.Parent then return end
        local rp = character:FindFirstChild("HitboxHead")
            or character:FindFirstChild("Head")
            or character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChild("UpperTorso")
        if not rp then return end
        if (rp.Position - Camera.CFrame.Position).Magnitude > Config.VisualsHologramRange then return end
        if #getHoloFolder():GetChildren() >= 16 then return end
        local dur = math.clamp(Config.VisualsHologramDuration or 3.5, 0.25, 10)
        local lethalOn  = lethal and cfg("VisualsHologramLethal", true)
        local mainColor = lethalOn and cfg("VisualsHologramLethalColor", _GOLD) or Config.VisualsHologramColor
        local style = cfg("VisualsHologramStyle", "Orb")
        if Config.VisualsPerformanceMode and style == "Wraith" then style = "Orb" end
        if style == "Skeleton" then popSkeleton(character, dur, mainColor); return end
        if style == "Wraith"   then popWraith(character, dur, mainColor);   return end
        local folder = getHoloFolder()
        local function mkBall(size, transp, color)
            local b = Instance.new("Part")
            b.Shape = Enum.PartType.Ball
            b.Size = Vector3.new(size, size, size)
            b.Material = Enum.Material.Neon
            b.Color = color
            b.Transparency = transp
            b.Anchored = true; b.CanCollide = false; b.CanQuery = false
            b.CanTouch = false; b.CastShadow = false; b.Massless = true
            b:SetAttribute("VS_Holo", true)
            return b
        end
        local vis = math.clamp(cfg("VisualsHologramVisibility", 1.4), 0.2, 2)
        local sc  = 0.75 + 0.25 * vis
        local h0  = math.clamp(0.65 / vis, 0.1, 0.9)
        local core = mkBall(0.7 * sc, 0.05, mainColor)
        local halo = mkBall(1.7 * sc, h0, mainColor)
        local startCF = CFrame.new(rp.Position)
        core.CFrame = startCF; halo.CFrame = startCF
        core.Name = "_h" .. math.random(10000, 99999); halo.Name = core.Name .. "_g"
        core.Parent = folder; halo.Parent = folder
        local shockColor = Config.VisualsHologramAccent or Config.VisualsHologramColor
        local shock = mkBall(0.5, 0.15, shockColor)
        shock.Shape = Enum.PartType.Cylinder
        shock.Size  = Vector3.new(0.1, 0.5, 0.5)
        do
            local cam = workspace.CurrentCamera
            if cam then shock.CFrame = CFrame.lookAt(rp.Position, cam.CFrame.Position) * CFrame.Angles(0, math.rad(90), 0)
            else shock.CFrame = startCF * CFrame.Angles(0, 0, math.rad(90)) end
        end
        shock.Name = core.Name .. "_s"
        shock.Parent = folder
        local startT = tick()
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not core.Parent then if conn then conn:Disconnect() end return end
            local alpha = math.clamp((tick() - startT) / dur, 0, 1)
            local rise  = 2.5 * (1 - (1 - alpha) * (1 - alpha))
            local cf    = startCF + Vector3.new(0, rise, 0)
            core.CFrame = cf; halo.CFrame = cf
            core.Transparency = math.clamp(0.05 + 0.95 * alpha, 0, 1)
            halo.Transparency = math.clamp(h0 + (1 - h0) * alpha, 0, 1)
            if shock.Parent then
                local sa = math.clamp((tick() - startT) / 0.3, 0, 1)
                local se = 1 - (1 - sa) * (1 - sa)
                local sd = 0.5 + 3.5 * se
                shock.Size = Vector3.new(0.1, sd, sd)
                shock.Transparency = math.clamp(0.15 + 0.85 * sa, 0, 1)
            end
            if alpha >= 1 and conn then conn:Disconnect() end
        end)
        Debris:AddItem(core, dur + 0.2)
        Debris:AddItem(halo, dur + 0.2)
        Debris:AddItem(shock, 0.5)
    end
    local _beamPool, _beamInit = {}, false
    local function buildBeamRig()
        local model = Instance.new("Model")
        model.Name = "_bt" .. math.random(10000, 99999)
        local function anchor()
            local pt = Instance.new("Part")
            pt.Size = Vector3.new(0.05, 0.05, 0.05)
            pt.Anchored = true; pt.CanCollide = false; pt.CanQuery = false
            pt.CanTouch = false; pt.CastShadow = false; pt.Massless = true
            pt.Transparency = 1
            pt:SetAttribute("VS_Holo", true)
            pt.Parent = model
            local at = Instance.new("Attachment"); at.Parent = pt
            return pt, at
        end
        local part0, a0 = anchor()
        local part1, a1 = anchor()
        local function mkBeam()
            local b = Instance.new("Beam")
            b.Attachment0 = a0; b.Attachment1 = a1
            b.FaceCamera = true; b.Segments = 1; b.Enabled = false
            b.Parent = part0
            return b
        end
        local core, glow, halo = mkBeam(), mkBeam(), mkBeam()
        local light = Instance.new("PointLight")
        light.Range = 12; light.Brightness = 0; light.Enabled = false
        light.Parent = part1
        local impact = Instance.new("Part")
        impact.Shape = Enum.PartType.Ball
        impact.Size = Vector3.new(0.2, 0.2, 0.2)
        impact.Material = Enum.Material.Neon
        impact.Transparency = 1
        impact.Anchored = true; impact.CanCollide = false; impact.CanQuery = false
        impact.CanTouch = false; impact.CastShadow = false; impact.Massless = true
        impact:SetAttribute("VS_Holo", true)
        impact.Parent = model
        model.Parent = getHoloFolder()
        return { model = model, part0 = part0, part1 = part1, core = core, glow = glow, halo = halo,
                 light = light, impact = impact, on = false, conn = nil, startT = 0 }
    end
    local function ensureBeamPool()
        if _beamInit then return end
        _beamInit = true
        for i = 1, 8 do _beamPool[i] = buildBeamRig() end
    end
    local function beamRamp(head, tail)
        return NumberSequence.new({
            NumberSequenceKeypoint.new(0, tail),
            NumberSequenceKeypoint.new(0.55, tail + (head - tail) * 0.65),
            NumberSequenceKeypoint.new(1, head),
        })
    end
    local function spawnBeamTracer(muzzlePos, hitPos)
        if not (muzzlePos and hitPos) then return end
        local dist = (hitPos - muzzlePos).Magnitude
        if dist < 0.5 then return end
        ensureBeamPool()
        local rig, oldest, oldT = nil, nil, math.huge
        for _, r in ipairs(_beamPool) do
            if not (r.model and r.model.Parent) then
                pcall(function() if r.model then r.model.Parent = getHoloFolder() end end)
            end
            if not r.on then rig = r break end
            if r.startT < oldT then oldest, oldT = r, r.startT end
        end
        rig = rig or oldest
        if not rig then return end
        if rig.conn then rig.conn:Disconnect(); rig.conn = nil end
        local dirU  = (hitPos - muzzlePos).Unit
        local color = cfg("FXBeamHitColor", _GOLD)
        local style = cfg("FXBeamStyle", "Glow")
        local lit   = style == "Line"
        local prism = style == "Prism"
        local useLight  = (not lit) and cfg("FXBeamGlowLight", true)
        local useImpact = cfg("FXBeamImpact", true)
        local core, glow, halo = rig.core, rig.glow, rig.halo
        core.Color = ColorSequence.new(lit and color or (prism and _WHITE or color:Lerp(_WHITE, 0.78)))
        local gCol = prism and _EDGE or color
        glow.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, gCol),
            ColorSequenceKeypoint.new(0.8, gCol),
            ColorSequenceKeypoint.new(1, prism and _EDGE or color:Lerp(_WHITE, 0.5)),
        })
        halo.Color = ColorSequence.new(prism and _VISIBLE or color)
        core.LightEmission = lit and 0 or 1
        core.LightInfluence = lit and 1 or 0
        glow.LightEmission = 1; glow.LightInfluence = 0
        halo.LightEmission = 1; halo.LightInfluence = 0
        local w0, w1 = cfg("FXBeamWidth0", 0.18), cfg("FXBeamWidth1", 0.04)
        core.Width0 = w0 * 0.55; core.Width1 = w1 * 0.55
        local gw = prism and 0.45 or 1.7
        local hw = prism and 0.45 or 3.4
        glow.Width0 = w0 * gw; glow.Width1 = w1 * gw
        halo.Width0 = w0 * hw; halo.Width1 = w1 * hw
        local curve = (style == "Arc") and math.clamp(dist * 0.06, 0.5, 9) or 0
        local split = prism and math.clamp(dist * 0.02, 0.3, 1.6) or 0
        core.CurveSize0 = curve;         core.CurveSize1 = curve
        glow.CurveSize0 = curve + split; glow.CurveSize1 = curve + split
        halo.CurveSize0 = curve - split; halo.CurveSize1 = curve - split
        local seg = (curve ~= 0 or split ~= 0) and 10 or 1
        core.Segments = seg; glow.Segments = seg; halo.Segments = seg
        core.Transparency = beamRamp(0, 0.85)
        glow.Transparency = beamRamp(0.3, 0.92)
        halo.Transparency = beamRamp(0.72, 0.985)
        local travDur = 0
        if cfg("FXBeamTravel", true) then
            travDur = math.min(dist / math.max(cfg("FXBeamTravelSpeed", 1400), 100), 0.25)
            if travDur < 0.02 then travDur = 0 end
        end
        local trail = math.clamp(dist * 0.35, 4, 30)
        rig.part0.CFrame = CFrame.new(muzzlePos)
        rig.part1.CFrame = CFrame.new(travDur > 0 and (muzzlePos + dirU * 0.5) or hitPos)
        core.Enabled = true
        glow.Enabled = not lit
        halo.Enabled = not lit
        rig.light.Color = prism and _EDGE or color
        rig.light.Brightness = 2.5
        rig.light.Enabled = useLight
        rig.impact.Color = color:Lerp(_WHITE, 0.55)
        rig.impact.Transparency = 1
        rig.on = true; rig.startT = tick()
        local dur = cfg("FXBeamDur", 0.55)
        local landed = travDur <= 0
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not (rig.model and rig.model.Parent) then
                rig.on = false; if conn then conn:Disconnect() end; rig.conn = nil; return
            end
            local t = tick() - rig.startT
            if t < travDur then
                local headD = (t / travDur) * dist
                pcall(function()
                    rig.part1.CFrame = CFrame.new(muzzlePos + dirU * headD)
                    rig.part0.CFrame = CFrame.new(muzzlePos + dirU * math.max(headD - trail, 0))
                end)
                return
            end
            if not landed then
                landed = true
                pcall(function()
                    rig.part1.CFrame = CFrame.new(hitPos)
                    rig.part0.CFrame = CFrame.new(muzzlePos)
                    if useImpact then rig.impact.CFrame = CFrame.new(hitPos) end
                end)
            end
            local a = math.clamp((t - travDur) / dur, 0, 1)
            local e = 1 - (1 - a) * (1 - a)
            pcall(function()
                core.Transparency = beamRamp(0.25 + 0.75 * e, 0.9 + 0.1 * e)
                if not lit then
                    glow.Transparency = beamRamp(0.5 + 0.5 * e, 0.95 + 0.05 * e)
                    halo.Transparency = beamRamp(0.85 + 0.15 * e, 1)
                end
                if useImpact then
                    local ie = 1 - (1 - math.clamp((t - travDur) / 0.12, 0, 1)) ^ 2
                    local d = 0.25 + 0.9 * ie
                    rig.impact.Size = Vector3.new(d, d, d)
                    rig.impact.Transparency = 0.05 + 0.95 * math.clamp((t - travDur) / 0.3, 0, 1)
                end
                if useLight then rig.light.Brightness = 4 * (1 - e) end
            end)
            if a >= 1 then
                rig.on = false
                pcall(function()
                    core.Enabled = false; glow.Enabled = false; halo.Enabled = false
                    rig.light.Enabled = false; rig.light.Brightness = 0
                    rig.impact.Transparency = 1
                end)
                if conn then conn:Disconnect() end; rig.conn = nil
            end
        end)
        rig.conn = conn
    end
    local _SPARK_HIT  = Color3.fromRGB(255, 233, 184)
    local _SPARK_KILL = Color3.fromRGB(255, 194, 75)
    local _sparks = {}
    local function sparkPrune()
        for i = #_sparks, 1, -1 do
            local m = _sparks[i]
            if not (m and m.Parent) then table.remove(_sparks, i) end
        end
    end
    local function mkSparkRing(parent, pos, dia, color)
        local r = Instance.new("Part")
        r.Shape = Enum.PartType.Cylinder
        r.Size = Vector3.new(0.1, dia, dia)
        r.Material = Enum.Material.Neon
        r.Color = color
        r.Transparency = 0.1
        r.Anchored = true; r.CanCollide = false; r.CanQuery = false
        r.CanTouch = false; r.CastShadow = false; r.Massless = true
        r:SetAttribute("VS_Holo", true)
        local cam = workspace.CurrentCamera
        if cam then
            r.CFrame = CFrame.lookAt(pos, cam.CFrame.Position) * CFrame.Angles(0, math.rad(90), 0)
        else
            r.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
        end
        r.Parent = parent
        return r
    end
    local function spawnWorldSpark(pos, kill)
        if not pos then return end
        sparkPrune()
        while #_sparks >= 12 do
            local old = table.remove(_sparks, 1)
            if old then pcall(function() old:Destroy() end) end
        end
        local folder = getHoloFolder()
        local color  = kill and _SPARK_KILL or _SPARK_HIT
        local model  = Instance.new("Model")
        model.Name = (kill and "_ks" or "_hs") .. math.random(10000, 99999)
        local bloom, bloomB0 = nil, kill and 6 or 4
        if cfg("FXWorldSparkBloom", true) then
            local lpart = Instance.new("Part")
            lpart.Size = Vector3.new(0.05, 0.05, 0.05)
            lpart.Transparency = 1
            lpart.Anchored = true; lpart.CanCollide = false; lpart.CanQuery = false
            lpart.CanTouch = false; lpart.CastShadow = false; lpart.Massless = true
            lpart:SetAttribute("VS_Holo", true)
            lpart.CFrame = CFrame.new(pos)
            lpart.Parent = model
            local light = Instance.new("PointLight")
            light.Color = color; light.Range = kill and 14 or 9; light.Brightness = bloomB0
            light.Parent = lpart
            bloom = light
        end
        local rings, sparks, dirs = {}, {}, {}
        local dur
        if kill then
            dur = 0.32
            rings[1] = { p = mkSparkRing(model, pos, 0.6, color), d0 = 0.6, d1 = 6.0 }
            rings[2] = { p = mkSparkRing(model, pos, 1.0, color), d0 = 1.0, d1 = 4.4 }
        else
            dur = 0.22
            rings[1] = { p = mkSparkRing(model, pos, 0.6, color), d0 = 0.6, d1 = 4.0 }
            for i = 1, 3 do
                local b = Instance.new("Part")
                b.Shape = Enum.PartType.Ball
                b.Size = Vector3.new(0.12, 0.12, 0.12)
                b.Material = Enum.Material.Neon
                b.Color = color
                b.Transparency = 0
                b.Anchored = true; b.CanCollide = false; b.CanQuery = false
                b.CanTouch = false; b.CastShadow = false; b.Massless = true
                b:SetAttribute("VS_Holo", true)
                b.CFrame = CFrame.new(pos)
                b.Parent = model
                sparks[i] = b
                local ang  = math.random() * math.pi * 2
                local elev = (math.random() - 0.5) * 1.2
                dirs[i] = Vector3.new(math.cos(ang), elev, math.sin(ang)).Unit
            end
        end
        model.Parent = folder
        _sparks[#_sparks + 1] = model
        local startT = tick()
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not model.Parent then if conn then conn:Disconnect() end return end
            local a = math.clamp((tick() - startT) / dur, 0, 1)
            local e = 1 - (1 - a) * (1 - a)
            local tr = math.clamp(0.1 + 0.9 * a, 0, 1)
            pcall(function()
                for _, rg in ipairs(rings) do
                    local d = rg.d0 + (rg.d1 - rg.d0) * e
                    rg.p.Size = Vector3.new(0.1, d, d)
                    rg.p.Transparency = tr
                end
                for i, b in ipairs(sparks) do
                    if b and b.Parent then
                        b.CFrame = CFrame.new(pos + dirs[i] * (0.6 * e) + Vector3.new(0, 0.4 * e, 0))
                        b.Transparency = math.clamp(a, 0, 1)
                    end
                end
                if bloom then bloom.Brightness = bloomB0 * (1 - e) end
            end)
            if a >= 1 and conn then conn:Disconnect() end
        end)
        Debris:AddItem(model, dur + 0.2)
    end
    Visuals.worldSpark = spawnWorldSpark
    local spawnKillPillar, spawnKillShards, triggerKillPulse, clearKillPulse
    ;(function()
        local _pillars, _bursts = {}, {}
        local function alive(list)
            for i = #list, 1, -1 do
                local m = list[i]
                if not (m and m.Parent) then table.remove(list, i) end
            end
            return #list
        end
        local function mkNeon(model, shape, color, tr)
            local p = Instance.new("Part")
            p.Shape = shape
            p.Material = Enum.Material.Neon
            p.Color = color
            p.Transparency = tr
            p.Anchored = true; p.CanCollide = false; p.CanQuery = false
            p.CanTouch = false; p.CastShadow = false; p.Massless = true
            p:SetAttribute("VS_Holo", true)
            p.Parent = model
            return p
        end
        local VERT = CFrame.Angles(0, 0, math.rad(90))
        spawnKillPillar = function(pos)
            if alive(_pillars) >= 3 then return end
            local color = Config.FXKillPillarColor or _SPARK_KILL
            local model = Instance.new("Model")
            model.Name = "_kf" .. math.random(10000, 99999)
            local dur = 1.0
            local col = mkNeon(model, Enum.PartType.Cylinder, color, 0.3)
            col.Size = Vector3.new(3, 1.1, 1.1)
            col.CFrame = CFrame.new(pos + Vector3.new(0, 0.5, 0)) * VERT
            local ring = mkNeon(model, Enum.PartType.Cylinder, color, 0.15)
            ring.Size = Vector3.new(0.12, 1.4, 1.4)
            ring.CFrame = CFrame.new(pos - Vector3.new(0, 2.2, 0)) * VERT
            local motes, mBase, mVel = {}, {}, {}
            for i = 1, 6 do
                local m = mkNeon(model, Enum.PartType.Ball, color:Lerp(_WHITE, 0.35), 0.1)
                local s = 0.14 + math.random() * 0.12
                m.Size = Vector3.new(s, s, s)
                mBase[i] = pos + Vector3.new((math.random() - 0.5) * 2.2,
                    math.random() * 1.5 - 1.5, (math.random() - 0.5) * 2.2)
                m.CFrame = CFrame.new(mBase[i])
                local a = math.random() * math.pi * 2
                mVel[i] = Vector3.new(math.cos(a) * (0.6 + math.random()), 6 + math.random() * 5,
                    math.sin(a) * (0.6 + math.random()))
                motes[i] = m
            end
            local anchorP = mkNeon(model, Enum.PartType.Ball, color, 1)
            anchorP.Size = Vector3.new(0.05, 0.05, 0.05)
            anchorP.CFrame = CFrame.new(pos)
            local bloom = Instance.new("PointLight")
            bloom.Color = color; bloom.Range = 16; bloom.Brightness = 7
            bloom.Parent = anchorP
            model.Parent = getHoloFolder()
            _pillars[#_pillars + 1] = model
            local t0 = tick()
            local conn
            conn = RunService.Heartbeat:Connect(function()
                if not model.Parent then if conn then conn:Disconnect() end return end
                local a = math.clamp((tick() - t0) / dur, 0, 1)
                local e = 1 - (1 - a) * (1 - a)
                pcall(function()
                    local h = 3 + 21 * e
                    local w = 1.1 * (1 - 0.55 * e)
                    col.Size = Vector3.new(h, w, w)
                    col.CFrame = CFrame.new(pos + Vector3.new(0, h * 0.5 - 1, 0)) * VERT
                    col.Transparency = a < 0.3 and (0.3 - 0.5 * a) or (0.15 + 0.85 * (a - 0.3) / 0.7)
                    local d = 1.4 + 8.6 * e
                    ring.Size = Vector3.new(0.12, d, d)
                    ring.Transparency = 0.15 + 0.85 * e
                    for i = 1, 6 do
                        motes[i].CFrame = CFrame.new(mBase[i] + mVel[i] * (dur * e))
                        motes[i].Transparency = 0.1 + 0.9 * a
                    end
                    bloom.Brightness = 7 * (1 - e)
                end)
                if a >= 1 and conn then conn:Disconnect() end
            end)
            Debris:AddItem(model, dur + 0.2)
        end
        spawnKillShards = function(pos)
            if alive(_bursts) >= 3 then return end
            local color = Config.FXKillShardsColor or _EDGE
            local model = Instance.new("Model")
            model.Name = "_kb" .. math.random(10000, 99999)
            local dur = 0.75
            local shards, sBase, sVel, sRot, sSpin, sSize = {}, {}, {}, {}, {}, {}
            for i = 1, 10 do
                local s = mkNeon(model, Enum.PartType.Block,
                    i % 3 == 0 and color:Lerp(_WHITE, 0.5) or color, 0.05)
                local k = 0.7 + math.random() * 0.8
                sSize[i] = Vector3.new(0.42 * k, 0.26 * k, 0.09 * k)
                s.Size = sSize[i]
                sBase[i] = pos + Vector3.new((math.random() - 0.5) * 1.4,
                    (math.random() - 0.5) * 1.8, (math.random() - 0.5) * 1.4)
                sRot[i] = CFrame.Angles(math.random() * 6.283, math.random() * 6.283, math.random() * 6.283)
                s.CFrame = CFrame.new(sBase[i]) * sRot[i]
                local a = (i / 10) * math.pi * 2 + math.random()
                sVel[i] = Vector3.new(math.cos(a) * (6 + math.random() * 7), 5 + math.random() * 9,
                    math.sin(a) * (6 + math.random() * 7))
                sSpin[i] = Vector3.new(math.random() * 10 - 5, math.random() * 10 - 5, math.random() * 10 - 5)
                shards[i] = s
            end
            model.Parent = getHoloFolder()
            _bursts[#_bursts + 1] = model
            local t0 = tick()
            local conn
            conn = RunService.Heartbeat:Connect(function()
                if not model.Parent then if conn then conn:Disconnect() end return end
                local a = math.clamp((tick() - t0) / dur, 0, 1)
                local t = a * dur
                local tr = a < 0.4 and 0.05 or (0.05 + 0.95 * (a - 0.4) / 0.6)
                local sc = 1 - 0.45 * a
                pcall(function()
                    for i = 1, 10 do
                        local p = sBase[i] + sVel[i] * t - Vector3.new(0, 26 * t * t, 0)
                        local sp = sSpin[i]
                        shards[i].CFrame = CFrame.new(p) * sRot[i] * CFrame.Angles(sp.X * t, sp.Y * t, sp.Z * t)
                        shards[i].Size = sSize[i] * sc
                        shards[i].Transparency = tr
                    end
                end)
                if a >= 1 and conn then conn:Disconnect() end
            end)
            Debris:AddItem(model, dur + 0.2)
        end
        local _pulseCC, _pulseConn, _pulseT0 = nil, nil, 0
        triggerKillPulse = function()
            if not (_pulseCC and _pulseCC.Parent) then
                local cc = Instance.new("ColorCorrectionEffect")
                cc.Name = "_vs_pulse"
                cc:SetAttribute("VS_Pulse", true)
                cc.Parent = Lighting
                _pulseCC = cc
            end
            _pulseT0 = tick()
            if _pulseConn then return end
            _pulseConn = RunService.Heartbeat:Connect(function()
                local cc = _pulseCC
                if not (cc and cc.Parent) then
                    if _pulseConn then _pulseConn:Disconnect(); _pulseConn = nil end
                    return
                end
                local a = (tick() - _pulseT0) / 0.35
                if a >= 1 then
                    _pulseConn:Disconnect(); _pulseConn = nil
                    pcall(function() cc.Saturation = 0; cc.Brightness = 0; cc.Contrast = 0 end)
                    return
                end
                local k = (1 - a) * (1 - a) * math.clamp(Config.FXKillPulseAmount or 0.6, 0, 1)
                pcall(function()
                    cc.Saturation = -0.5 * k
                    cc.Brightness = 0.07 * k
                    cc.Contrast   = 0.12 * k
                end)
            end)
        end
        clearKillPulse = function()
            if _pulseConn then _pulseConn:Disconnect(); _pulseConn = nil end
            if _pulseCC then pcall(function() _pulseCC:Destroy() end); _pulseCC = nil end
        end
    end)()
    local FX = {}
    Visuals.FX = FX
    ;(function()
        local SoundService = game:GetService("SoundService")
        local StatsService = game:GetService("Stats")
        local hasDrawing = screenDraw ~= nil
        local C_GREY   = Color3.fromRGB(200, 200, 200)
        local C_AMBER  = Color3.fromRGB(255, 170, 60)
        local C_ORANGE = Color3.fromRGB(255, 120, 30)
        local C_RED    = Color3.fromRGB(255, 59, 78)
        local C_SCREENRED = Color3.fromRGB(194, 30, 47)
        local C_BLACK  = Color3.new(0, 0, 0)
        local C_GOLD   = Color3.fromRGB(255, 194, 75)
        local C_FILL   = Color3.fromRGB(13, 18, 25)
        local C_HPBG   = Color3.fromRGB(11, 15, 22)
        local C_TEXT2  = Color3.fromRGB(174, 185, 197)
        local function dnRamp(total)
            if total <= 25 then
                return C_GREY:Lerp(C_AMBER, math.clamp(total / 25, 0, 1))
            end
            return C_AMBER:Lerp(C_ORANGE, math.clamp((total - 25) / 25, 0, 1))
        end
        local _started, _alloc = false, false
        local _updConn, _gui = nil, nil
        local _hmLines, _hmLinesBlk = nil, nil
        local _hm = { on = false, t0 = 0, pop = 0, color = _WHITE }
        local _snds, _sndIdx, _sndLastT = nil, 1, 0
        local _dnPool, _dnActive, _dnByPlr = nil, {}, {}
        local _kbL1, _kbL2, _kbRing = nil, nil, nil
        local _kb = { on = false, t0 = 0, streak = 0, lastKillT = 0, line1 = "", line2 = "" }
        local _ddArcs = nil
        local _kfPool, _kfItems = nil, {}
        local _hsLines, _hsLinesBlk = nil, nil
        local _hs = { on = false, t0 = 0, pos = nil }
        local _flashFrame = nil
        local _hf = { on = false, t0 = 0 }
        local _vgFrames = nil
        local _vgHP, _vgLastPoll = 1, 0
        local _hcConn, _charConn, _lastHP = nil, nil, nil
        local _fovA, _fovB, _fovFill, _fovCas = nil, nil, nil, nil
        local _fxLastT = nil
        local _fxThrT  = 0
        local _hmRing, _hmRingBlk = nil, nil
        local _chLines, _chLinesBlk, _chDot, _chDotBlk = nil, nil, nil, nil
        local _chTri, _chTriBlk = nil, nil
        local _ch2 = { shots = 0, shotT = -10, rot = 0, rotTgt = 0 }
        local _wmBg, _wmAccent, _wmText = nil, nil, nil
        local _wm = { fps = 60, ping = 0, pingT = 0, str = "", strT = 0, bw = nil, pw = 60 }
        local _sessKills, _sessT0 = 0, tick()
        local _tiBg, _tiAccent, _tiName, _tiHpBg, _tiHpFill, _tiInfo = nil, nil, nil, nil, nil, nil
        local _ti = { tgt = nil, a = 0, hp = nil, frac = 1, pollT = 0, name = nil, info = "" }
        local _blTexts, _blHead, _blBar = nil, nil, nil
        local _bl = { scanT = 0, rows = {}, on = {}, t0 = {} }
        local _kfTicks = nil
        local function mkDraw(t, props)
            if not hasDrawing then return nil end
            local ok, d = pcall(screenDraw, t, "fx")
            if not ok then return nil end
            d.Visible = false
            if props then for k, v in pairs(props) do pcall(function() d[k] = v end) end end
            return d
        end
        local function ensureGui()
            if _gui and _gui.Parent then return _gui end
            local g = Instance.new("ScreenGui")
            g.Name = "_vs_fx"
            g.IgnoreGuiInset = true
            g.ResetOnSpawn = false
            g.DisplayOrder = 999
            local ok = pcall(function() g.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
            if not ok or not g.Parent then
                pcall(function() g.Parent = lp:FindFirstChildOfClass("PlayerGui") end)
            end
            _gui = g
            return g
        end
        local function allocate()
            if _alloc then return end
            _alloc = true
            local g = ensureGui()
            local fr = Instance.new("Frame")
            fr.Name = "_fl"; fr.BackgroundColor3 = C_SCREENRED; fr.BackgroundTransparency = 1
            fr.BorderSizePixel = 0; fr.Size = UDim2.new(1, 0, 1, 0); fr.Visible = false
            fr.ZIndex = 1; fr.Parent = g
            _flashFrame = fr
            _vgFrames = {}
            local SIDES = {
                { size = UDim2.new(1, 0, 0.16, 0),  pos = UDim2.new(0, 0, 0, 0),     rot = 90  },
                { size = UDim2.new(1, 0, 0.16, 0),  pos = UDim2.new(0, 0, 0.84, 0),  rot = 270 },
                { size = UDim2.new(0.12, 0, 1, 0),  pos = UDim2.new(0, 0, 0, 0),     rot = 0   },
                { size = UDim2.new(0.12, 0, 1, 0),  pos = UDim2.new(0.88, 0, 0, 0),  rot = 180 },
            }
            for i, s in ipairs(SIDES) do
                local f = Instance.new("Frame")
                f.Name = "_vg" .. i; f.BackgroundColor3 = C_SCREENRED; f.BackgroundTransparency = 1
                f.BorderSizePixel = 0; f.Size = s.size; f.Position = s.pos; f.Visible = false
                f.ZIndex = 2
                local grad = Instance.new("UIGradient")
                grad.Rotation = s.rot
                grad.Transparency = NumberSequence.new(0, 1)
                grad.Parent = f
                f.Parent = g
                _vgFrames[i] = f
            end
            _hmLinesBlk = {}
            for i = 1, 4 do _hmLinesBlk[i] = mkDraw("Line", { Color = C_BLACK }) end
            _hmLines = {}
            for i = 1, 4 do _hmLines[i] = mkDraw("Line") end
            _dnPool = {}
            for i = 1, 24 do _dnPool[i] = mkDraw("Text", { Center = true, Outline = true, Font = 0 }) end
            _kbL1   = mkDraw("Text", { Center = true, Outline = true, Font = 3, Size = 12 })
            _kbL2   = mkDraw("Text", { Center = true, Outline = true, Font = 0, Size = 22 })
            _kbRing = mkDraw("Circle", { Filled = false, NumSides = 48 })
            _ddArcs = {}
            for i = 1, 6 do
                local arc = { on = false, t0 = 0, ang = 0, dscale = 0, red = {}, blk = {} }
                for j = 1, 9 do
                    arc.blk[j] = mkDraw("Line", { Color = C_BLACK, Thickness = 8 })
                    arc.red[j] = mkDraw("Line", { Color = C_SCREENRED, Thickness = 4 })
                end
                _ddArcs[i] = arc
            end
            _kfPool = {}
            for i = 1, 5 do _kfPool[i] = mkDraw("Text", { Center = false, Outline = true, Font = 3, Size = 13 }) end
            _hsLinesBlk = {}
            for i = 1, 6 do _hsLinesBlk[i] = mkDraw("Line", { Color = C_BLACK, Thickness = 4 }) end
            _hsLines = {}
            for i = 1, 6 do _hsLines[i] = mkDraw("Line", { Thickness = 2 }) end
            _fovFill = mkDraw("Circle", { Filled = true,  NumSides = 96 })
            _fovCas  = mkDraw("Circle", { Filled = false, NumSides = 96 })
            _fovA    = mkDraw("Circle", { Filled = false, NumSides = 96 })
            _fovB    = mkDraw("Circle", { Filled = false, NumSides = 96 })
            _hmRingBlk = mkDraw("Circle", { Filled = false, Color = C_BLACK })
            _hmRing    = mkDraw("Circle", { Filled = false })
            _chLinesBlk = {}
            for i = 1, 4 do _chLinesBlk[i] = mkDraw("Line", { Color = C_BLACK }) end
            _chLines = {}
            for i = 1, 4 do _chLines[i] = mkDraw("Line") end
            _chDotBlk = mkDraw("Circle", { Filled = true, Color = C_BLACK })
            _chDot    = mkDraw("Circle", { Filled = true })
            _chTriBlk = {}
            for i = 1, 3 do _chTriBlk[i] = mkDraw("Circle", { Filled = true, Color = C_BLACK }) end
            _chTri = {}
            for i = 1, 3 do _chTri[i] = mkDraw("Circle", { Filled = true }) end
            _wmBg     = mkDraw("Square", { Filled = true, Color = C_FILL })
            _wmAccent = mkDraw("Line",   { Color = C_GOLD, Thickness = 2 })
            _wmText   = mkDraw("Text",   { Center = false, Outline = true, Font = 2, Size = 13, Text = "oxycodone", Color = _WHITE })
            _wm.stats = mkDraw("Text",   { Center = false, Outline = true, Font = 3, Size = 12, Color = C_TEXT2 })
            _tiBg     = mkDraw("Square", { Filled = true, Color = C_FILL })
            _tiAccent = mkDraw("Line",   { Color = C_GOLD, Thickness = 2 })
            _tiHpBg   = mkDraw("Square", { Filled = true, Color = C_HPBG })
            _tiHpFill = mkDraw("Square", { Filled = true })
            _tiName   = mkDraw("Text",   { Center = true, Outline = true, Font = 0, Size = 13 })
            _tiInfo   = mkDraw("Text",   { Center = true, Outline = true, Font = 0, Size = 11, Color = C_TEXT2 })
            _blBar  = mkDraw("Line", { Color = C_GOLD, Thickness = 2 })
            _blHead = mkDraw("Text", { Center = false, Outline = true, Font = 3, Size = 12, Color = C_GOLD })
            _blTexts = {}
            for i = 1, 10 do _blTexts[i] = mkDraw("Text", { Center = false, Outline = true, Font = 3, Size = 12 }) end
            _kfTicks = {}
            for i = 1, 5 do _kfTicks[i] = mkDraw("Line", { Color = C_GOLD, Thickness = 2 }) end
            _snds = {}
            for i = 1, 4 do
                local s = Instance.new("Sound")
                s.Name = "_fxs" .. i
                s.Volume = 0.5
                s.Parent = SoundService
                _snds[i] = s
            end
        end
        local function triggerHitMarker(crit, lethal)
            if not (_hmLines and _hmLines[1]) then return end
            local now = tick()
            if _hm.on and (now - _hm.t0) < 0.18 then
                _hm.pop = math.min(_hm.pop + 1, 3)
            else
                _hm.pop = 0
            end
            _hm.on = true; _hm.t0 = now
            _hm.color = (lethal and cfg("FXHitMarkerLethalColor", C_RED))
                or (crit and cfg("FXHitMarkerCritColor", _GOLD))
                or cfg("FXHitMarkerColor", _WHITE)
        end
        local function playHitSound(dmg, lethal)
            if not _snds then return end
            local id = lethal and cfg("FXKillSoundId", "") or cfg("FXHitSoundId", "")
            if not id or id == "" then return end
            local now = tick()
            if (now - _sndLastT) < 0.035 then return end
            _sndLastT = now
            local s = _snds[_sndIdx]
            _sndIdx = (_sndIdx % #_snds) + 1
            if not (s and s.Parent) then return end
            pcall(function()
                if s.SoundId ~= id then s.SoundId = id end
                if lethal then
                    s.PlaybackSpeed = 1.0; s.Volume = 0.7
                else
                    s.PlaybackSpeed = 0.9 + math.clamp(dmg / 50, 0, 1) * 0.45
                    s.Volume = cfg("FXHitSoundVolume", 0.5)
                end
                s:Play()
            end)
        end
        local function dnFree(d)
            for _, e in ipairs(_dnActive) do if e.d == d then return false end end
            return true
        end
        local function pushDamageNumber(p, dmg, crit, lethal, hitPos)
            if not (_dnPool and hitPos) then return end
            local now = tick()
            local e = _dnByPlr[p]
            if e and e.alive and (now - e.lastT) <= cfg("FXDamageAccumWindow", 0.9) then
                e.total = e.total + dmg
                e.t0 = now; e.lastT = now; e.popT = now; e.pos = hitPos
                e.crit = e.crit or crit; e.lethal = e.lethal or lethal
                return
            end
            local d
            for _, cand in ipairs(_dnPool) do
                if cand and dnFree(cand) then d = cand break end
            end
            if not d then return end
            e = { d = d, p = p, total = dmg, pos = hitPos, t0 = now, lastT = now, popT = now,
                  drift = math.random(-8, 8), crit = crit, lethal = lethal, alive = true }
            _dnByPlr[p] = e
            table.insert(_dnActive, e)
        end
        local function trackText(s)
            return (s:gsub("(.)", "%1 ")):sub(1, -2)
        end
        local KB_STREAK = { [2] = "DOUBLE", [3] = "TRIPLE", [4] = "QUAD" }
        local function triggerKillBanner(p)
            if not (_kbL1 and _kbL2) then return end
            local now = tick()
            if (now - _kb.lastKillT) <= 4 then _kb.streak = _kb.streak + 1 else _kb.streak = 1 end
            _kb.lastKillT = now
            _kb.on = true; _kb.t0 = now
            local label = "ELIMINATED"
            if _kb.streak >= 5 then label = _kb.streak .. "x"
            elseif _kb.streak >= 2 then label = KB_STREAK[_kb.streak] end
            _kb.line1 = trackText(label)
            _kb.line2 = tostring(p.DisplayName or p.Name)
        end
        local function pushKillFeed(p, crit)
            if not _kfPool then return end
            table.insert(_kfItems, 1, { text = "You  ·  " .. tostring(p.DisplayName or p.Name), t0 = tick(), crit = crit and true or false })
            while #_kfItems > 5 do table.remove(_kfItems) end
        end
        local function triggerSpark(hitPos)
            if not (_hsLines and hitPos) then return end
            _hs.on = true; _hs.t0 = tick(); _hs.pos = hitPos
        end
        local function triggerFlash()
            if not _flashFrame then return end
            _hf.on = true; _hf.t0 = tick()
        end
        local function nearestEnemyPos()
            local myC = lp.Character
            local myR = myC and myC:FindFirstChild("HumanoidRootPart")
            if not myR then return nil end
            local best, bestD, bestVis, bestVisD = nil, math.huge, nil, math.huge
            for plr, o in pairs(State.ESPObjects) do
                local r = o.root
                if plr ~= lp and r and r.Parent then
                    local d = (r.Position - myR.Position).Magnitude
                    if o._vis and d < bestVisD then bestVis, bestVisD = r.Position, d end
                    if d < bestD then best, bestD = r.Position, d end
                end
            end
            return bestVis or best
        end
        local function triggerDirection(drop)
            if not _ddArcs then return end
            local src = nearestEnemyPos(); if not src then return end
            local rel = Camera.CFrame:PointToObjectSpace(src)
            local ang = math.atan2(rel.X, -rel.Z)
            local arc, oldest, oldT = nil, nil, math.huge
            for _, a in ipairs(_ddArcs) do
                if not a.on then arc = a break end
                if a.t0 < oldT then oldest, oldT = a, a.t0 end
            end
            arc = arc or oldest
            if not arc then return end
            arc.on = true; arc.t0 = tick(); arc.ang = ang
            arc.dscale = math.clamp(drop / 50, 0, 1)
            local vp = Camera.ViewportSize
            local cx, cy = vp.X * 0.5, vp.Y * 0.5
            local r = 0.22 * math.min(vp.X, vp.Y)
            local width = math.rad(24 + 24 * arc.dscale)
            local step = width / 9
            local th0 = ang - width * 0.5
            for j = 1, 9 do
                local t1 = th0 + step * (j - 1)
                local t2 = t1 + step * 0.8
                local p1 = Vector2.new(cx + math.sin(t1) * r, cy - math.cos(t1) * r)
                local p2 = Vector2.new(cx + math.sin(t2) * r, cy - math.cos(t2) * r)
                local lb, lr = arc.blk[j], arc.red[j]
                if lb then lb.From = p1; lb.To = p2 end
                if lr then lr.From = p1; lr.To = p2 end
            end
            arc.built = true
        end
        function FX.onHit(p, dmg, crit, lethal, hitPos)
            if not _started then return end
            if cfg("FXHitMarker", true) then triggerHitMarker(crit, lethal) end
            if dmg > 0 or lethal then
                if cfg("FXHitSound", true) then playHitSound(dmg, lethal) end
                if dmg > 0 and cfg("FXDamageNumbers", true) then pushDamageNumber(p, dmg, crit, lethal, hitPos) end
            end
            if crit and cfg("FXHeadshotSpark", true) then triggerSpark(hitPos) end
            if lethal then
                _sessKills = _sessKills + 1
                if cfg("FXKillBanner", true) then triggerKillBanner(p) end
                if cfg("FXKillFeed", true) then pushKillFeed(p, crit) end
            end
            if hitPos then
                if cfg("FXBeamTracer", false) then
                    local cc = Camera.CFrame
                    pcall(spawnBeamTracer,
                        cc.Position + cc.RightVector * 1.4 - cc.UpVector * 1.05 + cc.LookVector * 1.5,
                        hitPos)
                end
                if cfg("FXWorldSpark", false) then pcall(spawnWorldSpark, hitPos, lethal) end
                if lethal then
                    if cfg("FXKillPillar", false) then pcall(spawnKillPillar, hitPos) end
                    if cfg("FXKillShards", false) then pcall(spawnKillShards, hitPos) end
                    if cfg("FXKillPulse", false)  then pcall(triggerKillPulse) end
                end
            end
        end
        function FX.onIncoming(drop)
            if not _started then return end
            if cfg("FXHitFlash", true) then triggerFlash() end
            if cfg("FXDamageDirection", true) then triggerDirection(drop) end
        end
        local DIAG = { Vector2.new(1, 1), Vector2.new(-1, 1), Vector2.new(1, -1), Vector2.new(-1, -1) }
        local INV_SQ2 = 0.70710678
        local PLUS = { Vector2.new(0, -1), Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(-1, 0) }
        local BL_FEATURES = {
            { "RAGE",    "Rage" },
            { "SILENT",  "SilentAim" },
            { "AIMBOT",  "Aimbot" },
            { "ESP",     "ESP" },
            { "VISUALS", "Visuals" },
        }
        local function hideMarker()
            _hm.on = false
            for _, l in ipairs(_hmLines) do if l then l.Visible = false end end
            if _hmLinesBlk then for _, l in ipairs(_hmLinesBlk) do if l then l.Visible = false end end end
            if _hmRing then _hmRing.Visible = false end
            if _hmRingBlk then _hmRingBlk.Visible = false end
        end
        local function update()
            local now = tick()
            if now - _fxThrT < 0.0083 then return end
            _fxThrT = now
            local dt = now - (_fxLastT or now)
            _fxLastT = now
            if dt > 0.1 then dt = 0.1 end
            local vp = Camera.ViewportSize
            local cx, cy = vp.X * 0.5, vp.Y * 0.5
            if _hm.on and _hmLines then
                local a = now - _hm.t0
                if a >= 0.18 then
                    hideMarker()
                else
                    local style = cfg("FXHitMarkerStyle", "X")
                    local snap = math.clamp(a / 0.07, 0, 1)
                    snap = 1 - (1 - snap) * (1 - snap)
                    local gap = cfg("FXHitMarkerGap", 5)
                    local len = cfg("FXHitMarkerLen", 8) * snap + _hm.pop
                    local th  = cfg("FXHitMarkerThickness", 2)
                    local tr  = 1 - math.clamp((a - 0.09) / 0.09, 0, 1)
                    if style == "Ring" or style == "Dot" then
                        for i, l in ipairs(_hmLines) do
                            if l then l.Visible = false end
                            local lb = _hmLinesBlk and _hmLinesBlk[i]
                            if lb then lb.Visible = false end
                        end
                        if _hmRing then
                            local ctr = Vector2.new(cx, cy)
                            if style == "Ring" then
                                local r = math.max(gap + len, 1)
                                if _hmRingBlk then
                                    _hmRingBlk.Filled = false; _hmRingBlk.Position = ctr; _hmRingBlk.Radius = r
                                    _hmRingBlk.Thickness = th + 2; _hmRingBlk.Color = C_BLACK
                                    _hmRingBlk.Transparency = tr; _hmRingBlk.Visible = true
                                end
                                _hmRing.Filled = false; _hmRing.Position = ctr; _hmRing.Radius = r
                                _hmRing.Thickness = th; _hmRing.Color = _hm.color
                                _hmRing.Transparency = tr; _hmRing.Visible = true
                            else
                                local r = (th + 1) * (1.4 - 0.4 * snap)
                                if _hmRingBlk then
                                    _hmRingBlk.Filled = true; _hmRingBlk.Position = ctr; _hmRingBlk.Radius = r + 1
                                    _hmRingBlk.Color = C_BLACK; _hmRingBlk.Transparency = tr; _hmRingBlk.Visible = true
                                end
                                _hmRing.Filled = true; _hmRing.Position = ctr; _hmRing.Radius = r
                                _hmRing.Color = _hm.color; _hmRing.Transparency = tr; _hmRing.Visible = true
                            end
                        end
                    else
                        if _hmRing then _hmRing.Visible = false end
                        if _hmRingBlk then _hmRingBlk.Visible = false end
                        local plus = style == "Plus"
                        for i, l in ipairs(_hmLines) do
                            if l then
                                local nx, ny
                                if plus then nx, ny = PLUS[i].X, PLUS[i].Y
                                else nx, ny = DIAG[i].X * INV_SQ2, DIAG[i].Y * INV_SQ2 end
                                local from = Vector2.new(cx + nx * gap, cy + ny * gap)
                                local to   = Vector2.new(cx + nx * (gap + len), cy + ny * (gap + len))
                                local lb = _hmLinesBlk and _hmLinesBlk[i]
                                if lb then
                                    lb.From = from; lb.To = to
                                    lb.Color = C_BLACK; lb.Thickness = th + 2
                                    lb.Transparency = tr; lb.Visible = true
                                end
                                l.From = from
                                l.To   = to
                                l.Color = _hm.color
                                l.Thickness = th
                                l.Transparency = tr
                                l.Visible = true
                            end
                        end
                    end
                end
            end
            if _chLines then
                local wep = getEquippedItem and getEquippedItem()
                local isScoped = wep and wep.IsAiming and wep:IsAiming()
                local crossOn = cfg("FXCrosshair", false) or (cfg("FXCrosshairSniper", false) and isScoped)
                if crossOn then
                    local style = cfg("FXCrosshairStyle", "Cross")
                    local gap  = cfg("FXCrosshairGap", 4)
                    local len  = cfg("FXCrosshairLen", 7)
                    local th   = cfg("FXCrosshairThickness", 2)
                    local col  = cfg("FXCrosshairColor", _WHITE)
                    local outl = cfg("FXCrosshairOutline", true)
                    if cfg("FXCrosshairHitPop", true) and _hm.t0 > 0 then
                        len = len + 2 * (1 - math.clamp((now - _hm.t0) / 0.06, 0, 1))
                    end
                    local sh = State.Shots or 0
                    if sh ~= _ch2.shots then
                        _ch2.rotTgt = _ch2.rotTgt + 15 * math.min(math.abs(sh - _ch2.shots), 3)
                        _ch2.shots = sh; _ch2.shotT = now
                    end
                    if cfg("FXCrosshairBloom", false) or cfg("FXCrosshairBounce", false) then
                        local bAmt = cfg("FXCrosshairBounceAmt", 4)
                        gap = gap + bAmt * (1 - math.clamp((now - _ch2.shotT) / 0.12, 0, 1))
                    end
                    local rotDeg = cfg("FXCrosshairAngle", 0)
                    if cfg("FXCrosshairSpin", false) then
                        rotDeg = (rotDeg + now * cfg("FXCrosshairSpinSpeed", 1.0) * 360) % 360
                    end
                    local rotRad = math.rad(rotDeg)
                    local cosR, sinR = math.cos(rotRad), math.sin(rotRad)
                    local chev = style == "Chevron"
                    local diag = style == "X"
                    for i = 1, 4 do
                        local l  = _chLines[i]
                        local lb = _chLinesBlk and _chLinesBlk[i]
                        local hide = style == "Dot" or (style == "T" and i == 1) or (chev and i > 2)
                        if l then
                            if hide then
                                l.Visible = false; if lb then lb.Visible = false end
                            else
                                local nx, ny
                                if chev then
                                    local sx = (i == 1) and -1 or 1
                                    nx, ny = sx * 0.707, 0.707
                                elseif diag then
                                    nx, ny = DIAG[i].X * INV_SQ2, DIAG[i].Y * INV_SQ2
                                else
                                    nx, ny = PLUS[i].X, PLUS[i].Y
                                end
                                local rnx = nx * cosR - ny * sinR
                                local rny = nx * sinR + ny * cosR
                                local from = Vector2.new(cx + rnx * gap, cy + rny * gap)
                                local to   = Vector2.new(cx + rnx * (gap + len), cy + rny * (gap + len))
                                if lb then
                                    if outl then
                                        lb.From = from; lb.To = to; lb.Thickness = th + 2
                                        lb.Color = C_BLACK; lb.Transparency = 1; lb.Visible = true
                                    else lb.Visible = false end
                                end
                                l.From = from; l.To = to; l.Thickness = th
                                l.Color = col; l.Transparency = 1; l.Visible = true
                            end
                        end
                    end
                    if _chDot then
                        if style == "Dot" or cfg("FXCrosshairDot", true) then
                            local r = math.max(th * 0.5 + 0.5, 1)
                            if style == "Dot" then r = th + 1 end
                            if _chDotBlk then
                                if outl then
                                    _chDotBlk.Filled = true; _chDotBlk.Position = Vector2.new(cx, cy)
                                    _chDotBlk.Radius = r + 1; _chDotBlk.Color = C_BLACK
                                    _chDotBlk.Transparency = 1; _chDotBlk.Visible = true
                                else _chDotBlk.Visible = false end
                            end
                            _chDot.Filled = true; _chDot.Position = Vector2.new(cx, cy)
                            _chDot.Radius = r; _chDot.Color = col
                            _chDot.Transparency = 1; _chDot.Visible = true
                        else
                            _chDot.Visible = false
                            if _chDotBlk then _chDotBlk.Visible = false end
                        end
                    end
                else
                    for i = 1, 4 do
                        local l = _chLines[i]; if l and l.Visible then l.Visible = false end
                        local lb = _chLinesBlk and _chLinesBlk[i]; if lb and lb.Visible then lb.Visible = false end
                    end
                    if _chDot and _chDot.Visible then _chDot.Visible = false end
                    if _chDotBlk and _chDotBlk.Visible then _chDotBlk.Visible = false end
                    if _chTri then
                        for i = 1, 3 do
                            local d2 = _chTri[i]; if d2 and d2.Visible then d2.Visible = false end
                            local db = _chTriBlk and _chTriBlk[i]; if db and db.Visible then db.Visible = false end
                        end
                    end
                end
            end
            if _dnActive[1] then
                for i = #_dnActive, 1, -1 do
                    local e = _dnActive[i]
                    local a = (now - e.t0) / 0.7
                    if a >= 1 then
                        if e.d then e.d.Visible = false end
                        e.alive = false
                        if _dnByPlr[e.p] == e then _dnByPlr[e.p] = nil end
                        table.remove(_dnActive, i)
                    elseif e.d then
                        local sp = Camera:WorldToViewportPoint(e.pos)
                        if sp.Z <= 0 then
                            e.d.Visible = false
                        else
                            local d = e.d
                            local ease = 1 - (1 - a) * (1 - a)
                            local pop  = 1 + 0.25 * (1 - math.clamp((now - e.popT) / 0.12, 0, 1))
                            d.Size = math.floor((14 + math.clamp(e.total / 50, 0, 1) * 8) * pop + 0.5)
                            d.Text = tostring(math.floor(e.total + 0.5))
                            if e.crit or e.lethal then d.Color = C_GOLD
                            else d.Color = dnRamp(e.total) end
                            d.Position = Vector2.new(sp.X + e.drift * a, sp.Y - 42 * ease)
                            d.Transparency = a < 0.6 and 1 or 1 - (a - 0.6) / 0.4
                            d.Visible = true
                        end
                    end
                end
            end
            if _kb.on then
                local a = now - _kb.t0
                if a >= 1.17 then
                    _kb.on = false
                    if _kbL1 then _kbL1.Visible = false end
                    if _kbL2 then _kbL2.Visible = false end
                    if _kbRing then _kbRing.Visible = false end
                else
                    local y = cy - 140
                    local scale, tr, rise = 1, 1, 0
                    if a < 0.09 then
                        scale = 0.6 + 0.4 * (a / 0.09)
                    elseif a > 0.79 then
                        local f = (a - 0.79) / 0.38
                        tr = 1 - f
                        rise = 8 * f
                    end
                    if _kbL1 then
                        local lt = math.clamp(a / 0.24, 0, 1)
                        local le = 1 - (1 - lt) * (1 - lt) * (1 - lt)
                        _kbL1.Text = _kb.line1
                        _kbL1.Size = math.floor(12 * scale + 0.5)
                        _kbL1.Color = _WHITE
                        _kbL1.Position = Vector2.new(cx, y - rise - 3 * (1 - le))
                        _kbL1.Transparency = tr * le
                        _kbL1.Visible = true
                    end
                    if _kbL2 then
                        _kbL2.Text = _kb.line2
                        _kbL2.Size = math.floor(22 * scale + 0.5)
                        _kbL2.Color = cfg("FXKillBannerColor", _GOLD)
                        _kbL2.Position = Vector2.new(cx, y - rise + 16)
                        _kbL2.Transparency = tr
                        _kbL2.Visible = true
                    end
                    if _kbRing then
                        if a < 0.32 then
                            local f = a / 0.32
                            local fe = 1 - (1 - f) * (1 - f)
                            _kbRing.Position = Vector2.new(cx, cy)
                            _kbRing.Radius = 6 + 40 * fe
                            _kbRing.Thickness = 2 - 1.5 * f
                            _kbRing.Color = cfg("FXKillBannerColor", _GOLD)
                            _kbRing.Transparency = math.min(1, 0.6 + 0.1 * (_kb.streak - 1)) * (1 - f)
                            _kbRing.Visible = true
                        else
                            _kbRing.Visible = false
                        end
                    end
                end
            end
            if _ddArcs then
                for _, arc in ipairs(_ddArcs) do
                    if arc.on then
                        local a = now - arc.t0
                        if a >= 1.12 then
                            arc.on = false
                            for j = 1, 9 do
                                if arc.red[j] then arc.red[j].Visible = false end
                                if arc.blk[j] then arc.blk[j].Visible = false end
                            end
                        else
                            local op = 0.6 + 0.35 * arc.dscale
                            if a > 0.22 then op = op * (1 - (a - 0.22) / 0.9) end
                            for j = 1, 9 do
                                local lb, lr = arc.blk[j], arc.red[j]
                                if lb then lb.Transparency = op * 0.8; lb.Visible = true end
                                if lr then lr.Transparency = op; lr.Visible = true end
                            end
                        end
                    end
                end
            end
            if _kfPool then
                local y0 = Config.ESPRadar and (Config.ESPRadarInset + Config.ESPRadarSize + 16) or 110
                for i, d in ipairs(_kfPool) do
                    local it = _kfItems[i]
                    local tk = _kfTicks and _kfTicks[i]
                    if d then
                        if not it or (now - it.t0) >= 5 then
                            d.Visible = false
                            if tk then tk.Visible = false end
                        else
                            local a = now - it.t0
                            local slide = math.clamp(a / 0.12, 0, 1)
                            slide = 1 - (1 - slide) * (1 - slide)
                            d.Text = it.text
                            d.Color = it.crit and C_GOLD or _WHITE
                            d.Size = 13
                            local rx = vp.X - 16 - d.TextBounds.X + (1 - slide) * 30
                            local ry = y0 + (i - 1) * 18
                            local tr = a < 4 and 1 or 1 - (a - 4)
                            d.Position = Vector2.new(rx, ry)
                            d.Transparency = tr
                            d.Visible = true
                            if tk then
                                tk.From = Vector2.new(rx - 8, ry + 2)
                                tk.To   = Vector2.new(rx - 8, ry + 13)
                                tk.Thickness = 2; tk.Color = C_GOLD
                                tk.Transparency = tr; tk.Visible = true
                            end
                        end
                    end
                end
                for i = #_kfItems, 1, -1 do
                    if (now - _kfItems[i].t0) >= 5 then table.remove(_kfItems, i) end
                end
            end
            if _hs.on and _hsLines then
                local a = (now - _hs.t0) / 0.18
                if a >= 1 then
                    _hs.on = false
                    for _, l in ipairs(_hsLines) do if l then l.Visible = false end end
                    if _hsLinesBlk then for _, l in ipairs(_hsLinesBlk) do if l then l.Visible = false end end end
                else
                    local sp = Camera:WorldToViewportPoint(_hs.pos)
                    if sp.Z <= 0 then
                        for _, l in ipairs(_hsLines) do if l then l.Visible = false end end
                        if _hsLinesBlk then for _, l in ipairs(_hsLinesBlk) do if l then l.Visible = false end end end
                    else
                        local rad = 4 + 8 * a
                        local tr = 1 - a * a
                        for i, l in ipairs(_hsLines) do
                            if l then
                                local th = (i - 1) * (math.pi / 3)
                                local dx, dy = math.cos(th), math.sin(th)
                                local from = Vector2.new(sp.X + dx * rad, sp.Y + dy * rad)
                                local to   = Vector2.new(sp.X + dx * (rad + 5), sp.Y + dy * (rad + 5))
                                local lb = _hsLinesBlk and _hsLinesBlk[i]
                                if lb then
                                    lb.From = from; lb.To = to
                                    lb.Transparency = tr; lb.Visible = true
                                end
                                l.From = from
                                l.To   = to
                                l.Color = C_GOLD
                                l.Transparency = tr
                                l.Visible = true
                            end
                        end
                    end
                end
            end
            if _hf.on and _flashFrame then
                local a = (now - _hf.t0) / 0.16
                if a >= 1 then
                    _hf.on = false
                    _flashFrame.Visible = false
                else
                    _flashFrame.BackgroundTransparency = 0.78 + 0.22 * a
                    _flashFrame.Visible = true
                end
            end
            if _vgFrames then
                local show = false
                if cfg("FXLowHPVignette", true) then
                    if (now - _vgLastPoll) > 0.1 then
                        _vgLastPoll = now
                        local hp, mh = getHealth(lp)
                        _vgHP = (mh and mh > 0) and hp / mh or 1
                    end
                    local thr = cfg("FXLowHPThreshold", 0.35)
                    if _vgHP > 0 and _vgHP < thr then
                        local sev = math.clamp((thr - _vgHP) / math.max(thr - 0.10, 0.01), 0, 1)
                        local freq = 0.8 + 0.6 * sev
                        local tr = (0.85 - 0.35 * sev)
                            + 0.06 * (0.5 + 0.5 * math.sin(now * freq * 6.283185))
                        tr = math.clamp(tr, 0, 1)
                        for _, f in ipairs(_vgFrames) do
                            f.BackgroundTransparency = tr
                            if not f.Visible then f.Visible = true end
                        end
                        show = true
                    end
                end
                if not show then
                    for _, f in ipairs(_vgFrames) do if f.Visible then f.Visible = false end end
                end
            end
            if _fovA then
                if cfg("FXFovRing", false) then
                    local _vpF = Camera.ViewportSize
                    local _hf  = math.tan(math.rad(Camera.FieldOfView) * 0.5)
                    local _deg = math.clamp(cfg("AimbotFOVDeg", 20), 0.1, 89)
                    local R    = (_hf > 0)
                        and math.clamp(math.tan(math.rad(_deg)) / _hf * (_vpF.Y * 0.5), 4, math.max(_vpF.X, _vpF.Y))
                        or  math.max(_vpF.X, _vpF.Y)
                    local th = math.clamp(cfg("FXFovThickness", 1.5), 0.5, 4)
                    local cA = cfg("FXFovColorA", _WHITE)
                    local cB = cfg("FXFovColorB", _GOLD)
                    local phase = cfg("FXFovRotate", true) and (now * cfg("FXFovDriftSpeed", 0.15)) or 0
                    local t = 0.5 + 0.5 * math.sin(phase * 6.283185)
                    local center = Vector2.new(cx, cy)
                    if _fovFill then
                        if cfg("FXFovFill", false) then
                            _fovFill.Position = center; _fovFill.Radius = R
                            _fovFill.Color = _SPARK_KILL
                            _fovFill.Transparency = 0.05
                            _fovFill.Visible = true
                        elseif _fovFill.Visible then
                            _fovFill.Visible = false
                        end
                    end
                    if _fovCas then
                        if cfg("FXFovCasing", true) then
                            _fovCas.Position = center; _fovCas.Radius = R
                            _fovCas.Thickness = th + 2; _fovCas.Color = C_BLACK
                            _fovCas.Transparency = 0.5; _fovCas.Visible = true
                        elseif _fovCas.Visible then
                            _fovCas.Visible = false
                        end
                    end
                    _fovA.Position = center; _fovA.Radius = R
                    _fovA.Thickness = th; _fovA.Color = cA:Lerp(cB, t)
                    _fovA.Transparency = 0.5; _fovA.Visible = true
                    if _fovB then
                        _fovB.Position = center; _fovB.Radius = math.max(1, R - th)
                        _fovB.Thickness = th; _fovB.Color = cB:Lerp(cA, t)
                        _fovB.Transparency = 0.5; _fovB.Visible = true
                    end
                else
                    if _fovA.Visible then _fovA.Visible = false end
                    if _fovB and _fovB.Visible then _fovB.Visible = false end
                    if _fovFill and _fovFill.Visible then _fovFill.Visible = false end
                    if _fovCas and _fovCas.Visible then _fovCas.Visible = false end
                end
            end
            if _wmText then
                if cfg("HUDWatermark", true) then
                    if dt > 0 then _wm.fps = _wm.fps + (1 / dt - _wm.fps) * 0.1 end
                    local stats = cfg("HUDWatermarkStats", true)
                    if stats and (now - _wm.pingT) > 1 then
                        _wm.pingT = now
                        pcall(function()
                            _wm.ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
                        end)
                    end
                    _wmText.Position = Vector2.new(26, 21)
                    _wmText.Transparency = 1
                    _wmText.Visible = true
                    if not _wm.bw then
                        pcall(function() local tb = _wmText.TextBounds; if tb and tb.X > 0 then _wm.bw = tb.X end end)
                    end
                    local bw = _wm.bw or 52
                    if (now - _wm.strT) > 0.25 then
                        _wm.strT = now
                        if stats then
                            local sess = now - _sessT0
                            _wm.str = string.format("%d fps · %d ms · %02d:%02d · %d kills",
                                math.floor(_wm.fps + 0.5), _wm.ping,
                                math.floor(sess / 60), math.floor(sess % 60), _sessKills)
                        else
                            _wm.str = ""
                        end
                        local sw = 0
                        if _wm.stats and _wm.str ~= "" then
                            _wm.stats.Text = _wm.str
                            pcall(function() local tb = _wm.stats.TextBounds; if tb then sw = tb.X end end)
                        end
                        _wm.pw = (sw > 0) and (10 + bw + 12 + sw + 10) or (10 + bw + 10)
                    end
                    if _wm.stats then
                        if _wm.str ~= "" then
                            _wm.stats.Position = Vector2.new(26 + bw + 12, 22)
                            _wm.stats.Transparency = 1
                            _wm.stats.Visible = true
                        elseif _wm.stats.Visible then _wm.stats.Visible = false end
                    end
                    if _wmBg then
                        _wmBg.Filled = true
                        _wmBg.Position = Vector2.new(16, 16); _wmBg.Size = Vector2.new(_wm.pw, 24)
                        _wmBg.Color = C_FILL; _wmBg.Transparency = 0.72; _wmBg.Visible = true
                    end
                    if _wmAccent then
                        _wmAccent.From = Vector2.new(16, 16); _wmAccent.To = Vector2.new(16, 40)
                        _wmAccent.Thickness = 2; _wmAccent.Color = C_GOLD
                        _wmAccent.Transparency = 1; _wmAccent.Visible = true
                    end
                else
                    if _wmText.Visible then _wmText.Visible = false end
                    if _wm.stats and _wm.stats.Visible then _wm.stats.Visible = false end
                    if _wmBg and _wmBg.Visible then _wmBg.Visible = false end
                    if _wmAccent and _wmAccent.Visible then _wmAccent.Visible = false end
                end
            end
            if _tiBg and _tiAccent and _tiName and _tiHpBg and _tiHpFill and _tiInfo then
                local tgt = nil
                if cfg("FXTargetInfo", false) then
                    tgt = State.PrimaryTarget
                    if tgt and not (tgt.Parent and tgt.Character and isAlive(tgt)) then tgt = nil end
                end
                if tgt ~= _ti.tgt then
                    _ti.tgt = tgt
                    if tgt then
                        _ti.name = tostring(tgt.DisplayName or tgt.Name)
                        _ti.hp = nil; _ti.pollT = 0
                    end
                end
                if tgt and (now - (_ti.pollT or 0)) > 0.1 then
                    _ti.pollT = now
                    pcall(function()
                        local hp, mh = getHealth(tgt)
                        _ti.frac = math.clamp((mh or 0) > 0 and hp / mh or 0, 0, 1)
                        local d = 0
                        local myR = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                        local tR  = tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart")
                        if myR and tR then d = (myR.Position - tR.Position).Magnitude end
                        _ti.info = string.format("%dm  ·  %s", math.floor(d + 0.5), getWeaponName(tgt))
                    end)
                end
                _ti.a = (_ti.a or 0) + ((tgt and 1 or 0) - (_ti.a or 0)) * math.clamp(dt * 16, 0, 1)
                if _ti.a > 0.02 and _ti.name then
                    local frac = _ti.frac or 1
                    if _ti.hp == nil then _ti.hp = frac
                    else _ti.hp = _ti.hp + (frac - _ti.hp) * (1 - math.exp(-18 * dt)) end
                    local aa = math.clamp(_ti.a, 0, 1)
                    local px = cx - 90
                    local py = cy + cfg("FXTargetInfoOffset", 110)
                    _tiBg.Filled = true; _tiBg.Position = Vector2.new(px, py); _tiBg.Size = Vector2.new(180, 46)
                    _tiBg.Color = C_FILL; _tiBg.Transparency = 0.62 * aa; _tiBg.Visible = true
                    _tiAccent.From = Vector2.new(px + 1, py); _tiAccent.To = Vector2.new(px + 1, py + 46)
                    _tiAccent.Thickness = 2; _tiAccent.Color = C_GOLD
                    _tiAccent.Transparency = aa; _tiAccent.Visible = true
                    _tiName.Text = _ti.name; _tiName.Position = Vector2.new(px + 90, py + 3)
                    _tiName.Color = _WHITE; _tiName.Transparency = aa; _tiName.Visible = true
                    local fillW = math.max(164 * math.clamp(_ti.hp, 0, 1), 1)
                    _tiHpBg.Filled = true; _tiHpBg.Position = Vector2.new(px + 8, py + 23)
                    _tiHpBg.Size = Vector2.new(164, 5); _tiHpBg.Color = C_HPBG
                    _tiHpBg.Transparency = 0.86 * aa; _tiHpBg.Visible = true
                    _tiHpFill.Filled = true; _tiHpFill.Position = Vector2.new(px + 8, py + 23)
                    _tiHpFill.Size = Vector2.new(fillW, 5); _tiHpFill.Color = hpRamp(_ti.hp)
                    _tiHpFill.Transparency = aa; _tiHpFill.Visible = true
                    _tiInfo.Text = _ti.info or ""; _tiInfo.Position = Vector2.new(px + 90, py + 31)
                    _tiInfo.Color = C_TEXT2; _tiInfo.Transparency = aa; _tiInfo.Visible = true
                else
                    if _tiBg.Visible then
                        _tiBg.Visible = false; _tiAccent.Visible = false; _tiName.Visible = false
                        _tiHpBg.Visible = false; _tiHpFill.Visible = false; _tiInfo.Visible = false
                    end
                end
            end
            if _blTexts then
                if cfg("HUDBindList", false) then
                    if (now - (_bl.scanT or 0)) >= 0.25 then
                        _bl.scanT = now
                        local n = 0
                        for _, f in ipairs(BL_FEATURES) do
                            if Config[f[2]] then
                                n = n + 1
                                _bl.rows[n] = f[1]
                                if not _bl.on[f[2]] then _bl.on[f[2]] = true; _bl.t0[f[1]] = now end
                            else
                                _bl.on[f[2]] = false
                            end
                        end
                        for i = #_bl.rows, n + 1, -1 do _bl.rows[i] = nil end
                    end
                    local right = cfg("HUDBindListSide", "Left") == "Right"
                    local bx = right and (vp.X - 110) or 16
                    local by = vp.Y * 0.35
                    if _blHead then
                        _blHead.Text = "oxycodone"; _blHead.Color = C_GOLD
                        _blHead.Position = Vector2.new(bx, by)
                        _blHead.Transparency = 1; _blHead.Visible = true
                    end
                    local nRows = #_bl.rows
                    for i, d in ipairs(_blTexts) do
                        local label = _bl.rows[i]
                        if label then
                            local a = math.clamp((now - (_bl.t0[label] or 0)) / 0.12, 0, 1)
                            local e = 1 - (1 - a) * (1 - a)
                            d.Text = label; d.Color = _WHITE
                            d.Position = Vector2.new(bx + (1 - e) * 14 * (right and 1 or -1), by + 17 + (i - 1) * 15)
                            d.Transparency = e
                            d.Visible = true
                        elseif d.Visible then
                            d.Visible = false
                        end
                    end
                    if _blBar then
                        _blBar.From = Vector2.new(bx - 6, by)
                        _blBar.To   = Vector2.new(bx - 6, by + 17 + nRows * 15)
                        _blBar.Thickness = 2; _blBar.Color = C_GOLD
                        _blBar.Transparency = 0.9; _blBar.Visible = true
                    end
                else
                    if _blHead and _blHead.Visible then _blHead.Visible = false end
                    if _blBar and _blBar.Visible then _blBar.Visible = false end
                    for _, d in ipairs(_blTexts) do if d.Visible then d.Visible = false end end
                end
            end
        end
        local function hideAllFX()
            if _hmLines then hideMarker() end
            for i = #_dnActive, 1, -1 do
                local e = _dnActive[i]
                if e.d then e.d.Visible = false end
                _dnActive[i] = nil
            end
            table.clear(_dnByPlr)
            _kb.on = false
            if _kbL1 then _kbL1.Visible = false end
            if _kbL2 then _kbL2.Visible = false end
            if _kbRing then _kbRing.Visible = false end
            if _ddArcs then
                for _, arc in ipairs(_ddArcs) do
                    arc.on = false
                    for j = 1, 9 do
                        if arc.red[j] then arc.red[j].Visible = false end
                        if arc.blk[j] then arc.blk[j].Visible = false end
                    end
                end
            end
            table.clear(_kfItems)
            if _kfPool then for _, d in ipairs(_kfPool) do if d then d.Visible = false end end end
            _hs.on = false
            if _hsLines then for _, l in ipairs(_hsLines) do if l then l.Visible = false end end end
            if _hsLinesBlk then for _, l in ipairs(_hsLinesBlk) do if l then l.Visible = false end end end
            _hf.on = false
            if _flashFrame then _flashFrame.Visible = false end
            if _vgFrames then for _, f in ipairs(_vgFrames) do f.Visible = false end end
            if _fovA then _fovA.Visible = false end
            if _fovB then _fovB.Visible = false end
            if _fovFill then _fovFill.Visible = false end
            if _fovCas then _fovCas.Visible = false end
            if _hmRing then _hmRing.Visible = false end
            if _hmRingBlk then _hmRingBlk.Visible = false end
            if _chLines then for _, l in ipairs(_chLines) do if l then l.Visible = false end end end
            if _chLinesBlk then for _, l in ipairs(_chLinesBlk) do if l then l.Visible = false end end end
            if _chDot then _chDot.Visible = false end
            if _chDotBlk then _chDotBlk.Visible = false end
            if _chTri then for i = 1, 3 do if _chTri[i] then _chTri[i].Visible = false end end end
            if _chTriBlk then for i = 1, 3 do if _chTriBlk[i] then _chTriBlk[i].Visible = false end end end
            if _wmBg then _wmBg.Visible = false end
            if _wmAccent then _wmAccent.Visible = false end
            if _wmText then _wmText.Visible = false end
            if _wm.stats then _wm.stats.Visible = false end
            if _tiBg then _tiBg.Visible = false end
            if _tiAccent then _tiAccent.Visible = false end
            if _tiName then _tiName.Visible = false end
            if _tiHpBg then _tiHpBg.Visible = false end
            if _tiHpFill then _tiHpFill.Visible = false end
            if _tiInfo then _tiInfo.Visible = false end
            _ti.tgt = nil; _ti.a = 0
            if _blHead then _blHead.Visible = false end
            if _blBar then _blBar.Visible = false end
            if _blTexts then for _, d in ipairs(_blTexts) do if d then d.Visible = false end end end
            if _kfTicks then for _, l in ipairs(_kfTicks) do if l then l.Visible = false end end end
        end
        local function hookHumanoid(char)
            if _hcConn then _hcConn:Disconnect(); _hcConn = nil end
            if not char then return end
            task.spawn(function()
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum then
                    pcall(function() hum = char:WaitForChild("Humanoid", 5) end)
                end
                if not hum or not _started or char ~= lp.Character then return end
                _lastHP = hum.Health
                _hcConn = hum.HealthChanged:Connect(function(h)
                    local prev = _lastHP or h
                    _lastHP = h
                    local drop = prev - h
                    if drop > 0.5 then FX.onIncoming(drop) end
                end)
            end)
        end
        function FX.start()
            if _started then return end
            _started = true
            allocate()
            ensureGui()
            hookHumanoid(lp.Character)
            _charConn = lp.CharacterAdded:Connect(function(c) if _started then hookHumanoid(c) end end)
            if not _updConn then
                _updConn = RunService.RenderStepped:Connect(function()
                    if _started then pcall(update) end
                end)
            end
        end
        function FX.stop()
            if not _started then return end
            _started = false
            if _updConn then _updConn:Disconnect(); _updConn = nil end
            if _hcConn then _hcConn:Disconnect(); _hcConn = nil end
            if _charConn then _charConn:Disconnect(); _charConn = nil end
            hideAllFX()
        end
        function FX.destroy()
            FX.stop()
            local function rm(d) if d then pcall(function() d:Remove() end) end end
            if _hmLines then for _, d in ipairs(_hmLines) do rm(d) end _hmLines = nil end
            if _hmLinesBlk then for _, d in ipairs(_hmLinesBlk) do rm(d) end _hmLinesBlk = nil end
            if _dnPool then for _, d in ipairs(_dnPool) do rm(d) end _dnPool = nil end
            rm(_kbL1); rm(_kbL2); rm(_kbRing); _kbL1, _kbL2, _kbRing = nil, nil, nil
            if _ddArcs then
                for _, arc in ipairs(_ddArcs) do
                    for j = 1, 9 do rm(arc.red[j]); rm(arc.blk[j]) end
                end
                _ddArcs = nil
            end
            if _kfPool then for _, d in ipairs(_kfPool) do rm(d) end _kfPool = nil end
            if _hsLines then for _, d in ipairs(_hsLines) do rm(d) end _hsLines = nil end
            if _hsLinesBlk then for _, d in ipairs(_hsLinesBlk) do rm(d) end _hsLinesBlk = nil end
            rm(_fovA); rm(_fovB); rm(_fovFill); rm(_fovCas); _fovA, _fovB, _fovFill, _fovCas = nil, nil, nil, nil
            rm(_hmRing); rm(_hmRingBlk); _hmRing, _hmRingBlk = nil, nil
            if _chLines then for _, d in ipairs(_chLines) do rm(d) end _chLines = nil end
            if _chLinesBlk then for _, d in ipairs(_chLinesBlk) do rm(d) end _chLinesBlk = nil end
            rm(_chDot); rm(_chDotBlk); _chDot, _chDotBlk = nil, nil
            if _chTri then for _, d in ipairs(_chTri) do rm(d) end _chTri = nil end
            if _chTriBlk then for _, d in ipairs(_chTriBlk) do rm(d) end _chTriBlk = nil end
            rm(_wmBg); rm(_wmAccent); rm(_wmText); _wmBg, _wmAccent, _wmText = nil, nil, nil
            rm(_wm.stats); _wm.stats = nil
            rm(_tiBg); rm(_tiAccent); rm(_tiName); rm(_tiHpBg); rm(_tiHpFill); rm(_tiInfo)
            _tiBg, _tiAccent, _tiName, _tiHpBg, _tiHpFill, _tiInfo = nil, nil, nil, nil, nil, nil
            rm(_blHead); rm(_blBar); _blHead, _blBar = nil, nil
            if _blTexts then for _, d in ipairs(_blTexts) do rm(d) end _blTexts = nil end
            if _kfTicks then for _, d in ipairs(_kfTicks) do rm(d) end _kfTicks = nil end
            if _snds then for _, s in ipairs(_snds) do pcall(function() s:Destroy() end) end _snds = nil end
            if _gui then pcall(function() _gui:Destroy() end); _gui = nil end
            _flashFrame = nil; _vgFrames = nil
            _alloc = false
        end
    end)()
    function Visuals.previewHologram(character)
        createHologram(character, Config.VisualsHologramLethal)
    end
    function Visuals.onShotHit(character)
        if not Config.VisualsHolograms or not character then return end
        local now=tick()
        if now-(_hologramCooldowns[character] or 0)<0.15 then return end
        _hologramCooldowns[character]=now
        local hum=character:FindFirstChildOfClass("Humanoid")
        createHologram(character,hum and hum.Health<=0)
    end
    local _hpPrev = {}
    function Visuals.notifyTarget(p, info)
        if not p or p == lp or not p.Character then return end
        local cur, maxHP = getHealth(p)
        local dmg = math.max(0, (_hpPrev[p] or maxHP) - cur)
        _hpPrev[p] = cur
        local lethal = (not isAlive(p)) or cur <= 0
        local char = p.Character
        local rp = char:FindFirstChild("HitboxHead")
            or char:FindFirstChild("Head")
            or char:FindFirstChild("HumanoidRootPart")
            or char:FindFirstChild("UpperTorso")
        local hitPos = rp and rp.Position or nil
        local crit = (info and info.crit) or (dmg >= cfg("FXCritDamage", 30))
        if Config.VisualsHolograms then
            local now = tick()
            if (now - (_hologramCooldowns[p] or 0)) >= 0.35 then
                _hologramCooldowns[p] = now
                createHologram(char, lethal)
            end
        end
        FX.onHit(p, dmg, crit, lethal, hitPos)
    end
    local applyCamFrame, clearCamFrame
    ;(function()
        local TweenService = game:GetService("TweenService")
        local _camGui, _vgFrames, _lbTop, _lbBot, _dof = nil, nil, nil, nil, nil
        local C_BLACK_FRAME = Color3.new(0, 0, 0)
        local function ensureCamGui()
            if _camGui and _camGui.Parent then return _camGui end
            local g = Instance.new("ScreenGui")
            g.Name = "_vs_cam"
            g.IgnoreGuiInset = true; g.ResetOnSpawn = false
            g.DisplayOrder = 990
            local ok = pcall(function() g.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
            if not ok or not g.Parent then
                pcall(function() g.Parent = lp:FindFirstChildOfClass("PlayerGui") end)
            end
            _camGui = g
            return g
        end
        local VG_SIDES = {
            { size = UDim2.new(1, 0, 0.24, 0),  pos = UDim2.new(0, 0, 0, 0),     rot = 90  },
            { size = UDim2.new(1, 0, 0.24, 0),  pos = UDim2.new(0, 0, 0.76, 0),  rot = 270 },
            { size = UDim2.new(0.17, 0, 1, 0),  pos = UDim2.new(0, 0, 0, 0),     rot = 0   },
            { size = UDim2.new(0.17, 0, 1, 0),  pos = UDim2.new(0.83, 0, 0, 0),  rot = 180 },
        }
        local function vgApply()
            local on = cfg("VisualsVignette", false)
            if not on then
                if _vgFrames then
                    for i = 1, #_vgFrames do _vgFrames[i].Visible = false end
                end
                return
            end
            if not _vgFrames then
                local g = ensureCamGui()
                _vgFrames = {}
                for i = 1, #VG_SIDES do
                    local s = VG_SIDES[i]
                    local f = Instance.new("Frame")
                    f.Name = "_cv" .. i
                    f.BackgroundColor3 = C_BLACK_FRAME; f.BorderSizePixel = 0
                    f.Size = s.size; f.Position = s.pos; f.Visible = false; f.ZIndex = 1
                    local grad = Instance.new("UIGradient")
                    grad.Rotation = s.rot
                    grad.Transparency = NumberSequence.new(0, 1)
                    grad.Parent = f
                    f.Parent = g
                    _vgFrames[i] = f
                end
            end
            local tr = 1 - 0.85 * math.clamp(cfg("VisualsVignetteStrength", 0.6), 0, 1)
            for i = 1, #_vgFrames do
                local f = _vgFrames[i]
                f.BackgroundTransparency = tr; f.Visible = true
            end
        end
        local LB_TI = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local function lbApply(animate)
            local on = cfg("VisualsLetterbox", false)
            if not on and not _lbTop then return end
            if not _lbTop then
                local g = ensureCamGui()
                for i = 1, 2 do
                    local f = Instance.new("Frame")
                    f.Name = "_clb" .. i
                    f.BackgroundColor3 = C_BLACK_FRAME; f.BackgroundTransparency = 0
                    f.BorderSizePixel = 0; f.ZIndex = 2
                    f.Parent = g
                    if i == 1 then _lbTop = f else _lbBot = f end
                end
                _lbTop.Position = UDim2.new(0, 0, -0.2, 0)
                _lbBot.Position = UDim2.new(0, 0, 1, 0)
            end
            local sz = math.clamp(cfg("VisualsLetterboxSize", 0.10), 0.04, 0.18)
            local topP = on and UDim2.new(0, 0, 0, 0)      or UDim2.new(0, 0, -sz - 0.02, 0)
            local botP = on and UDim2.new(0, 0, 1 - sz, 0) or UDim2.new(0, 0, 1.02, 0)
            _lbTop.Size = UDim2.new(1, 0, sz, 0); _lbBot.Size = UDim2.new(1, 0, sz, 0)
            if animate then
                pcall(function()
                    TweenService:Create(_lbTop, LB_TI, { Position = topP }):Play()
                    TweenService:Create(_lbBot, LB_TI, { Position = botP }):Play()
                end)
            else
                _lbTop.Position = topP; _lbBot.Position = botP
            end
        end
        local function dofApply()
            local on = not Config.VisualsPerformanceMode and cfg("VisualsDOF", false)
            if not on then
                if _dof then pcall(function() _dof:Destroy() end); _dof = nil end
                return
            end
            if not (_dof and _dof.Parent) then
                local d = Instance.new("DepthOfFieldEffect")
                d.Name = "_vs_dof"; d:SetAttribute("VS_DoF", true)
                d.InFocusRadius = 22
                d.Parent = Lighting
                _dof = d
            end
            local blur = math.clamp(cfg("VisualsDOFBlur", 0.5), 0, 1)
            pcall(function()
                _dof.FocusDistance = math.clamp(cfg("VisualsDOFDistance", 28), 5, 100)
                _dof.FarIntensity  = 0.75 * blur
                _dof.NearIntensity = 0.5  * blur
            end)
        end
        applyCamFrame = function(animate) vgApply(); lbApply(animate); dofApply() end
        clearCamFrame = function()
            if _camGui then pcall(function() _camGui:Destroy() end) end
            _camGui, _vgFrames, _lbTop, _lbBot = nil, nil, nil, nil
            if _dof then pcall(function() _dof:Destroy() end); _dof = nil end
        end
        function Visuals.setVignette(on) Config.VisualsVignette = on; vgApply() end
        function Visuals.setVignetteStrength(v)
            Config.VisualsVignetteStrength = math.clamp(v, 0, 1); vgApply()
        end
        function Visuals.setLetterbox(on) Config.VisualsLetterbox = on; lbApply(true) end
        function Visuals.setLetterboxSize(v)
            Config.VisualsLetterboxSize = math.clamp(v, 0.04, 0.18); lbApply(false)
        end
        function Visuals.setDOF(on) Config.VisualsDOF = on; dofApply() end
        function Visuals.setDOFDistance(v)
            Config.VisualsDOFDistance = math.clamp(v, 5, 100); dofApply()
        end
        function Visuals.setDOFBlur(v)
            Config.VisualsDOFBlur = math.clamp(v, 0, 1); dofApply()
        end
    end)()
    local _fovSaved = nil
    local _tpRP = nil
    local function bindStretch()
        if _stretchBound then return end
        _stretchBound = true
        RunService:BindToRenderStep("VS_Stretch", Enum.RenderPriority.Last.Value+1, function()
            if not running or not Camera then return end
            local s = Config.VisualsStretch or 1.0
            local doStretch = math.abs(s - 1.0) >= 0.001
            local doSway = Config.VisualsCameraSway
            local doAspect = Config.CameraAspectRatioEnabled
            local doThird  = Config.ThirdPersonEnabled
            local doExtra = Config.ExtraRatioEnabled
            if Config.CameraFovOverride then
                local want = math.clamp(Config.CameraFovAmount or 90, 40, 130)
                if _fovSaved == nil then _fovSaved = Camera.FieldOfView end
                if Camera.FieldOfView ~= want then Camera.FieldOfView = want end
            elseif _fovSaved ~= nil then
                Camera.FieldOfView = _fovSaved; _fovSaved = nil
            end
            if not (doStretch or doSway or doAspect or doThird or doExtra) then return end
            local c = Camera.CFrame
            if doSway then
                local amt = math.clamp(Config.VisualsCameraSwayAmount or 0.5, 0, 1)
                local t = tick()
                local roll  = (math.sin(t * 0.9) + math.sin(t * 0.37) * 0.6) * amt
                local pitch =  math.sin(t * 1.3) * 0.7 * amt
                local yaw   =  math.sin(t * 0.7) * 0.8 * amt
                c = c * CFrame.Angles(math.rad(pitch), math.rad(yaw), math.rad(roll))
            end
            if doStretch then
                c = CFrame.fromMatrix(c.Position, c.RightVector * s, c.UpVector)
            end
            if doAspect then
                local rx = math.clamp(Config.CameraAspectRatioX or 4, 1, 21)
                local ry = math.clamp(Config.CameraAspectRatioY or 3, 1, 21)
                c = CFrame.fromMatrix(c.Position, c.RightVector * ((rx / ry) / math.max(Camera.ViewportSize.X / math.max(Camera.ViewportSize.Y, 1), 0.01)), c.UpVector)
            end
            if doExtra then
                local w=math.clamp(Config.ExtraRatioWidth or 100,10,150)/100
                local h=math.clamp(Config.ExtraRatioHeight or 100,10,150)/100
                c=CFrame.fromMatrix(c.Position,c.RightVector,c.UpVector*h,-c.LookVector*(w/h))
            end
            if doThird and lp.Character then
                local dist = math.clamp(Config.ThirdPersonDistance or 12, 4, 30)
                local desiredPos = c.Position - c.LookVector * dist
                if _tpRP == nil then
                    _tpRP = RaycastParams.new()
                    _tpRP.FilterType = Enum.RaycastFilterType.Exclude
                end
                _tpRP.FilterDescendantsInstances = { lp.Character }
                local hit = Workspace:Raycast(c.Position, -c.LookVector * dist, _tpRP)
                if hit then desiredPos = hit.Position + c.LookVector * 0.5 end
                c = (c - c.Position) + desiredPos
            end
            Camera.CFrame = c
        end)
    end
    local _vmBound = false
    local _vmSaved = setmetatable({}, {__mode="k"})
    local _vmLastRoot, _vmBase, _vmApplied
    local VM_MATERIALS = {
        ForceField=Enum.Material.ForceField, Neon=Enum.Material.Neon,
        Glass=Enum.Material.Glass, SmoothPlastic=Enum.Material.SmoothPlastic,
    }
    local function vmWanted()
        return Config.VMOffsetEnabled or Config.VMChamsEnabled or Config.VMDisableTextures
    end
    local function undoVMOffset()
        if _vmLastRoot and _vmLastRoot.Parent and _vmApplied then
            if _vmLastRoot.CFrame == _vmApplied then _vmLastRoot.CFrame = _vmBase end
        end
        _vmLastRoot, _vmBase, _vmApplied = nil, nil, nil
    end
    local function restoreVMObject(obj, saved)
        if obj.Parent then
            for key, value in pairs(saved) do pcall(function() obj[key]=value end) end
        end
    end
    local function vmRestore()
        undoVMOffset()
        for obj,saved in pairs(_vmSaved) do restoreVMObject(obj,saved) end
        table.clear(_vmSaved)
    end
    local function viewModelNow()
        local item=getEquippedItem()
        local vm=item and item.ViewModel
        local model=vm and (vm.Model or vm._model)
        if typeof(model) == "Instance" and model:IsA("Model") and model.Parent then return model end
         
        local candidate=Camera and (Camera:FindFirstChild("ViewModel") or Camera:FindFirstChild("Viewmodel"))
        if candidate and candidate:IsA("Model") then return candidate end
    end
    local function applyViewModel()
        if not vmWanted() then return end
        local model=viewModelNow()
        if not model then return end
        undoVMOffset()
        local root=model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart",true)
        if Config.VMOffsetEnabled and root then
            _vmLastRoot=root
            _vmBase=root.CFrame
            local offset=CFrame.new(Config.VMOffsetX or 0,Config.VMOffsetY or 0,Config.VMOffsetZ or 0)
                * CFrame.Angles(math.rad(Config.VMOffsetPitch or 0),math.rad(Config.VMOffsetYaw or 0),math.rad(Config.VMOffsetRoll or 0))
            _vmApplied=_vmBase*offset
            root.CFrame=_vmApplied
        end
        for _,obj in ipairs(model:GetDescendants()) do
            local saved=_vmSaved[obj]
            if obj:IsA("BasePart") and Config.VMChamsEnabled then
                if not saved then
                    saved={Material=obj.Material,Color=obj.Color,Transparency=obj.Transparency}
                    _vmSaved[obj]=saved
                end
                obj.Material=VM_MATERIALS[Config.VMChamsMaterial] or Enum.Material.ForceField
                obj.Color=Config.VMChamsColor
                obj.Transparency=Config.VMChamsTransparency
            elseif (obj:IsA("Decal") or obj:IsA("Texture")) and Config.VMDisableTextures then
                if not saved then saved={Transparency=obj.Transparency}; _vmSaved[obj]=saved end
                obj.Transparency=1
            elseif saved then
                restoreVMObject(obj,saved)
                _vmSaved[obj]=nil
            end
        end
    end
    local function bindViewModel()
        if _vmBound or not vmWanted() then return end
        _vmBound=true
        RunService:BindToRenderStep("LHOV_VMUndo",Enum.RenderPriority.First.Value,undoVMOffset)
        RunService:BindToRenderStep("LHOV_VMApply",Enum.RenderPriority.Last.Value+2,function()
            local ok, err=pcall(applyViewModel)
            if not ok then State.VMError=tostring(err) else State.VMError=nil end
        end)
    end
    local function unbindViewModel()
        RunService:UnbindFromRenderStep("LHOV_VMUndo")
        RunService:UnbindFromRenderStep("LHOV_VMApply")
        _vmBound=false
        vmRestore()
    end
    local function refreshViewModel()
        if vmWanted() then bindViewModel() else unbindViewModel() end
    end
    local _spooferActive = false
    local _spooferConns = {}
    local _isSpoofing = {}
    local _origText = {}
    local function anySpoofOn()
        return Config.SpooferNameEnabled or Config.SpooferLevelEnabled or Config.SpooferCasualWinsEnabled
            or Config.SpooferRankedWinsEnabled or Config.SpooferRankedEloEnabled
            or Config.SpooferWinPercentEnabled or Config.SpooferWinStreakEnabled
            or Config.SpooferFavoriteMapEnabled
    end
    local function escPat(s) return (s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")) end
    local function escRep(s) return (s:gsub("%%", "%%%%")) end
    local function belongsToLp(obj)
        local node, depth = obj, 0
        while node ~= nil and node ~= game and depth < 12 do
            if node:IsA("BillboardGui") then
                local anchor = node.Adornee or node.Parent
                while anchor ~= nil and not anchor:IsA("Model") do anchor = anchor.Parent end
                if anchor ~= nil then
                    local plr = Players:GetPlayerFromCharacter(anchor)
                    if plr ~= nil then return plr == lp end
                end
            elseif node:IsA("Model") then
                local plr = Players:GetPlayerFromCharacter(node)
                if plr ~= nil then return plr == lp end
            end
            local asId = tonumber(node.Name)
            if asId ~= nil and Players:GetPlayerByUserId(asId) ~= nil then return asId == lp.UserId end
            node = node.Parent; depth = depth + 1
        end
        return true
    end
    local ALLOWED_TEXT_NAMES = {
        DisplayName = true, Username = true, Name = true, Handle = true, Nametag = true,
        Title = true, TitleText = true, Value = true, Text = true, Label = true,
        Wins = true, WinRate = true, Streak = true, WinStreak = true, ELO = true, Level = true,
    }
    local function applyTextSpoof(obj)
        if not (obj and obj.Parent) then return end
        if _isSpoofing[obj] then return end
        local text = obj.Text
        if not text or #text == 0 then return end
        local newText = text
        local changed = false
        if Config.SpooferNameEnabled then
            local fakeName = Config.SpooferName or "ProPlayer"
            local fakeDisp = Config.SpooferDisplayName or fakeName
            local realName = lp.Name
            local realDisp = lp.DisplayName
            if realDisp and #realDisp > 0 and newText:find(realDisp, 1, true) then
                newText = newText:gsub(escPat(realDisp), escRep(fakeDisp))
                changed = true
            end
            if realName and #realName > 0 and newText:find(realName, 1, true) then
                newText = newText:gsub(escPat(realName), escRep(fakeName))
                changed = true
            end
        end
        local pn = obj.Parent and obj.Parent.Name or ""
        local on = obj.Name
        local isVal = (on == "Value" or on == "Text")
        local is_level = (pn == "Level" or pn == "LevelContainer") and (isVal or on == "Level")
        local is_wins = (on == "Wins" or pn == "Wins" or pn == "WinsContainer") and (isVal or on == "Wins")
        local is_elo = (pn == "ELO" or pn == "RankedElo" or pn == "Rating" or pn == "Rank") and (isVal or on == "ELO")
        local is_winrate = (on == "WinRate" or on == "win rate" or pn == "WinRate") and (isVal or on == "WinRate")
        local is_streak = (pn == "Streak" or pn == "WinStreak" or pn == "StreakContainer" or on == "Streak" or on == "WinStreak")
            and (isVal or on == "Streak" or on == "WinStreak")
        if (is_level or is_wins or is_elo or is_winrate or is_streak) and belongsToLp(obj) then
            local sVal = nil
            if Config.SpooferLevelEnabled and is_level then sVal = tostring(Config.SpooferLevel or 100)
            elseif Config.SpooferCasualWinsEnabled and is_wins then sVal = tostring(Config.SpooferCasualWins or 500)
            elseif Config.SpooferRankedEloEnabled and is_elo then sVal = tostring(Config.SpooferRankedElo or 2400)
            elseif Config.SpooferWinPercentEnabled and is_winrate then sVal = tostring(Config.SpooferWinPercent or 75) .. "%"
            elseif Config.SpooferWinStreakEnabled and is_streak then sVal = tostring(Config.SpooferWinStreak or 25)
            end
            if sVal ~= nil and newText ~= sVal then newText = sVal; changed = true end
        end
        if changed and newText ~= text then
            if _origText[obj] == nil then _origText[obj] = text end
            _isSpoofing[obj] = true
            pcall(function() obj.Text = newText end)
            _isSpoofing[obj] = nil
        end
    end
    local function registerTextObj(obj)
        if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
        if _spooferConns[obj] ~= nil then return end
        local txt = nil
        pcall(function() txt = obj.Text end)
        local mine = type(txt) == "string" and #txt > 0
            and ((#lp.Name > 0 and txt:find(lp.Name, 1, true) ~= nil)
              or (#lp.DisplayName > 0 and txt:find(lp.DisplayName, 1, true) ~= nil))
        if not ALLOWED_TEXT_NAMES[obj.Name] and not mine then return end
        applyTextSpoof(obj)
        _spooferConns[obj] = obj:GetPropertyChangedSignal("Text"):Connect(function() applyTextSpoof(obj) end)
        obj.Destroying:Once(function()
            local c = _spooferConns[obj]
            if c ~= nil then pcall(function() c:Disconnect() end) end
            _spooferConns[obj] = nil; _origText[obj] = nil; _isSpoofing[obj] = nil
        end)
    end
    local function stopGuiNameSpoofer()
        for k, c in pairs(_spooferConns) do
            pcall(function() c:Disconnect() end)
            _spooferConns[k] = nil
        end
        for obj, t in pairs(_origText) do
            pcall(function()
                if obj.Parent ~= nil then
                    _isSpoofing[obj] = true; obj.Text = t; _isSpoofing[obj] = nil
                end
            end)
            _origText[obj] = nil
        end
        _isSpoofing = {}
        _spooferActive = false
    end
    local function startGuiNameSpoofer()
        if _spooferActive or not anySpoofOn() then return end
        _spooferActive = true
        local pGui = lp:FindFirstChildOfClass("PlayerGui")
        if pGui then
            for _, inst in ipairs(pGui:GetDescendants()) do registerTextObj(inst) end
            _spooferConns["pGuiDesc"] = pGui.DescendantAdded:Connect(registerTextObj)
        end
        pcall(function()
            local cGui = cloneref(game:GetService("CoreGui"))
            if cGui then
                for _, inst in ipairs(cGui:GetDescendants()) do registerTextObj(inst) end
                _spooferConns["cGuiDesc"] = cGui.DescendantAdded:Connect(registerTextObj)
            end
        end)
        if Config.SpooferNameEnabled then
            _spooferConns["wsDesc"] = Workspace.DescendantAdded:Connect(function(inst)
                if inst:IsA("BillboardGui") or inst:IsA("SurfaceGui") then
                    for _, child in ipairs(inst:GetDescendants()) do registerTextObj(child) end
                    if _spooferConns[inst] == nil then
                        _spooferConns[inst] = inst.DescendantAdded:Connect(registerTextObj)
                    end
                end
            end)
        end
    end
    local function refreshGuiNameSpoofer()
        if not anySpoofOn() then stopGuiNameSpoofer(); return end
        if not _spooferActive then startGuiNameSpoofer(); return end
        for obj in pairs(_spooferConns) do
            if typeof(obj) == "Instance" then pcall(applyTextSpoof, obj) end
        end
    end
    local _savedAttrs = {}
    local _pinnedAttrs = {}
    local _pinConns = {}
    local function pinAttr(attrName, val)
        if not _savedAttrs[attrName] then _savedAttrs[attrName] = {value=lp:GetAttribute(attrName)} end
        _pinnedAttrs[attrName] = val
        if not _pinConns[attrName] then
            _pinConns[attrName] = lp:GetAttributeChangedSignal(attrName):Connect(function()
                local targetVal = _pinnedAttrs[attrName]
                if targetVal ~= nil and lp:GetAttribute(attrName) ~= targetVal then
                    pcall(function() lp:SetAttribute(attrName, targetVal) end)
                end
            end)
        end
        pcall(function() lp:SetAttribute(attrName, val) end)
    end
    local function unpinAttr(attrName)
        _pinnedAttrs[attrName] = nil
        if _pinConns[attrName] then
            _pinConns[attrName]:Disconnect()
            _pinConns[attrName] = nil
        end
        local saved = _savedAttrs[attrName]
        if saved then
            _savedAttrs[attrName] = nil
            pcall(function() lp:SetAttribute(attrName, saved.value) end)
        end
    end
    local function unpinAll()
        local names = {}
        for k in pairs(_pinConns) do names[#names + 1] = k end
        for _, k in ipairs(names) do unpinAttr(k) end
    end
    local function updatePlayerSpoofer()
        if not anySpoofOn() then unpinAll(); return end
        pcall(function()
            local cData = nil  
            local sLev = tonumber(Config.SpooferLevel) or 100
            local sElo = tonumber(Config.SpooferRankedElo) or 2400
            local sCWins = tonumber(Config.SpooferCasualWins) or 500
            local sRWins = tonumber(Config.SpooferRankedWins) or 250
            local sWP = (tonumber(Config.SpooferWinPercent) or 75) / 100
            local sStreak = tonumber(Config.SpooferWinStreak) or 25
            local sMap = tostring(Config.SpooferFavoriteMap or "Arena")
            if Config.SpooferLevelEnabled then
                pinAttr("Level", sLev)
                if cData then cData.Level = sLev end
            else
                unpinAttr("Level")
            end
            if Config.SpooferRankedEloEnabled then
                pinAttr("DisplayELO", sElo)
                pinAttr("RankedCurrentELO", sElo)
                if cData then
                    cData.RankedCurrentELO = sElo
                    if cData.Seasons then
                        for _, season in pairs(cData.Seasons) do
                            if season.RankedPerformances then
                                for _, perf in pairs(season.RankedPerformances) do
                                    perf.CurrentELO = sElo
                                end
                            end
                        end
                    end
                end
            else
                unpinAttr("DisplayELO")
                unpinAttr("RankedCurrentELO")
            end
            if Config.SpooferCasualWinsEnabled then
                pinAttr("CasualWins", sCWins)
                pinAttr("StatisticDuelsWins", sCWins)
                if cData then cData.CasualWins = sCWins end
            else
                unpinAttr("CasualWins")
                unpinAttr("StatisticDuelsWins")
            end
            if Config.SpooferRankedWinsEnabled then
                pinAttr("RankedWins", sRWins)
                if cData then cData.RankedWins = sRWins end
            else
                unpinAttr("RankedWins")
            end
            if Config.SpooferWinPercentEnabled then
                pinAttr("CasualWinPercent", sWP)
                pinAttr("RankedWinPercent", sWP)
                pinAttr("StatisticDuelsWinRate", sWP * 100)
                pinAttr("WinRate", sWP * 100)
                if cData then
                    cData.CasualWinPercent = sWP
                    cData.RankedWinPercent = sWP
                end
            else
                unpinAttr("CasualWinPercent")
                unpinAttr("RankedWinPercent")
                unpinAttr("StatisticDuelsWinRate")
                unpinAttr("WinRate")
            end
            if Config.SpooferWinStreakEnabled then
                pinAttr("StatisticDuelsWinStreak", sStreak)
                pinAttr("WinStreak", sStreak)
                pinAttr("CurrentWinStreak", sStreak)
                if cData then
                    cData.StatisticDuelsWinStreak = sStreak
                    cData.WinStreak = sStreak
                    cData.CurrentWinStreak = sStreak
                end
            else
                unpinAttr("StatisticDuelsWinStreak")
                unpinAttr("WinStreak")
                unpinAttr("CurrentWinStreak")
            end
            if Config.SpooferFavoriteMapEnabled then
                pinAttr("FavoriteMap", sMap)
                if cData then cData.FavoriteMap = sMap end
            else
                unpinAttr("FavoriteMap")
            end
             
        end)
    end
    function Visuals.setStretch(v)
        Config.VisualsStretch = math.clamp(v, Config.VisualsStretchMin, Config.VisualsStretchMax)
    end
    local function startRainbow()
        if _rainbowConn then return end
        _rainbowBatchIdx = 1; table.clear(_rainbowParts)
        local charSet = {}
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl.Character then charSet[pl.Character] = true end
        end
        for _, d in ipairs(Workspace:GetDescendants()) do
            if d:IsA("BasePart") and not d:GetAttribute("VS_Holo")
                and not charSet[d.Parent]
                and d.Name ~= "Terrain" then
                table.insert(_rainbowParts, { part = d, originalColor = d.Color })
            end
        end
        _rainbowConn = RunService.Heartbeat:Connect(function(dt)
            if not Config.Visuals or not Config.VisualsRainbowMap then return end
            _rainbowHue = (_rainbowHue + dt * Config.VisualsRainbowMapSpeed) % 1
            local total = #_rainbowParts; if total == 0 then return end
            local batch = math.min(250, total)
            for i = 1, batch do
                local idx = ((_rainbowBatchIdx - 1 + i - 1) % total) + 1
                local e   = _rainbowParts[idx]
                if e and e.part and e.part.Parent then
                    e.part.Color = Color3.fromHSV((_rainbowHue + (idx / total) * 0.3) % 1, 0.85, 1)
                end
            end
            _rainbowBatchIdx = ((_rainbowBatchIdx + batch - 1) % total) + 1
        end)
    end
    local function stopRainbow()
        if _rainbowConn then _rainbowConn:Disconnect(); _rainbowConn = nil end
        for _, e in ipairs(_rainbowParts) do
            if e.part and e.part.Parent then pcall(function() e.part.Color = e.originalColor end) end
        end
        table.clear(_rainbowParts)
    end
    function Visuals.toggleRainbowMap(on)
        Config.VisualsRainbowMap = on
        if on and Config.Visuals then startRainbow() else stopRainbow() end
    end
    local function applyPerf()
        if not _perfBackup then
            _perfBackup = {
                GlobalShadows = Lighting.GlobalShadows,
                EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
                EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
                Brightness = Lighting.Brightness,
                ShadowSoftness = Lighting.ShadowSoftness,
            }
        end
        clearTagged(); clearGrade(); clearBloom()
        Lighting.GlobalShadows = false; Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0; Lighting.Brightness = 2
        Lighting.ShadowSoftness = 0
        for _, d in ipairs(Workspace:GetDescendants()) do
            if d:IsA("ParticleEmitter") and not d:GetAttribute("VS_Holo") then
                if not _origParticleRates[d] then _origParticleRates[d] = d.Rate end
                d.Rate = 0
            end
        end
    end
    local function disablePerf()
        if _perfBackup then
            for k, v in pairs(_perfBackup) do pcall(function() Lighting[k] = v end) end
            _perfBackup = nil
        end
        for em, rate in pairs(_origParticleRates) do
            if em and em.Parent then pcall(function() em.Rate = rate end) end
        end
        table.clear(_origParticleRates)
        if State.VisualsCurrentPreset then applyPreset(State.VisualsCurrentPreset) end
    end
    function Visuals.togglePerf(on)
        Config.VisualsPerformanceMode = on
        if on then applyPerf() else disablePerf() end
        applyCamFrame(false)
    end
    function Visuals.setPreset(name)
        if Presets[name] then
            Config.VisualsPreset = name
            applyPreset(name)
        end
    end
    function Visuals.toggleHolograms(on) Config.VisualsHolograms = on end
    function Visuals.setHologramStyle(name) Config.VisualsHologramStyle = name end
    Visuals.HologramStyleOrder = { "Orb", "Skeleton", "Wraith" }
    Visuals.GradeOrder = { "None", "Crisp", "Cold", "Warm", "Comp" }
    function Visuals.setGrade(name)
        Config.VisualsGrade = name
        if not Config.Visuals or Config.VisualsPerformanceMode then return end
        reassertGrade()
    end
    function Visuals.setGradeStrength(v)
        Config.VisualsGradeStrength = math.clamp(v, 0, 1)
        if not Config.Visuals or Config.VisualsPerformanceMode then return end
        reassertGrade()
    end
    function Visuals.setBloom(on)
        Config.VisualsBloom = on
        if not Config.Visuals or Config.VisualsPerformanceMode then return end
        reassertBloom()
    end
    function Visuals.setBloomIntensity(v)
        Config.VisualsBloomIntensity = math.clamp(v, 0, 3)
        if not Config.Visuals or Config.VisualsPerformanceMode then return end
        reassertBloom()
    end
    function Visuals.toggleFullbright(on)
        Config.VisualsFullbright = on
        if not Config.Visuals or Config.VisualsPerformanceMode then return end
        if on then applyFullbrightOverride()
        else applyPreset(State.VisualsCurrentPreset or Config.VisualsPreset or "Neutral") end
    end
    function Visuals.toggleNoFog(on)
        Config.VisualsNoFog = on
        if not Config.Visuals or Config.VisualsPerformanceMode then return end
        if on then applyFogOverride()
        else applyPreset(State.VisualsCurrentPreset or Config.VisualsPreset or "Neutral") end
    end
    function Visuals.enableHUD()  Config.HUD = true;  FX.start() end
    function Visuals.disableHUD() Config.HUD = false; FX.stop()  end
    Visuals.updatePlayerSpoofer = updatePlayerSpoofer
    Visuals.applyGuiNameSpoof = refreshGuiNameSpoofer
    Visuals.refreshViewModel = refreshViewModel
    function Visuals.init()
        snapshotLighting()
        bindStretch()
        refreshViewModel()
        updatePlayerSpoofer()
        refreshGuiNameSpoofer()
    end
    function Visuals.enable()
        Config.Visuals = true; applyPreset(Config.VisualsPreset or "Neutral")
        if not Config.VisualsPerformanceMode then
            applyFullbrightOverride(); applyFogOverride()
        end
        bindStretch()
        refreshViewModel()
        updatePlayerSpoofer()
        refreshGuiNameSpoofer()
        if Config.VisualsRainbowMap then startRainbow() end
        if Config.VisualsPerformanceMode then applyPerf() end
        startReassert()
        applyCamFrame(false)
    end
    function Visuals.disable()
        Config.Visuals = false; stopRainbow(); stopReassert()
        clearGrade(); clearBloom()
        if Config.VisualsPerformanceMode then disablePerf() end
        restore()
        if _fovSaved ~= nil then
            pcall(function() Camera.FieldOfView = _fovSaved end)
            _fovSaved = nil
        end
    end
    function Visuals.unload()
        Visuals.disable(); stopReassert()
        clearCamFrame()
        FX.destroy()
        clearKillPulse()
        unbindViewModel()
        stopGuiNameSpoofer()
        unpinAll()
        if _fovSaved ~= nil then
            pcall(function() Camera.FieldOfView = _fovSaved end)
            _fovSaved = nil
        end
        if _hologramFolder then pcall(function() _hologramFolder:Destroy() end); _hologramFolder = nil end
        if _stretchBound then
            pcall(function() RunService:UnbindFromRenderStep("VS_Stretch") end)
            _stretchBound = false
        end
    end
end)()

local Weather = {}
;(function()
    local SoundService = game:GetService("SoundService")
    local TweenService = game:GetService("TweenService")
    local function cfg(key, default)
        local v = Config[key]
        if v == nil then return default end
        return v
    end
    local function iAmt()
        return math.clamp(cfg("WeatherIntensity", 1), 0.15, 2)
    end
    local function iRate(I, kLo, kHi)
        if I < 1 then
            return math.exp(kLo * (I - 1))
        end
        return math.exp(kHi * (I - 1))
    end
    local function evRate(key)
        return math.clamp(cfg(key, 1), 0.25, 3)
    end
    local IR = {
        Snow      = { lo = 1.75, hi = 0.85, acc = 0.45, sz = 0.08, alp = 0.35, gst = 0.30 },
        Petals    = { lo = 1.75, hi = 0.85, acc = 0.40, sz = 0.08, alp = 0.30, gst = 0.30 },
        Autumn    = { lo = 1.75, hi = 0.85, acc = 0.40, sz = 0.08, alp = 0.30, gst = 0.30 },
        Mist      = { lo = 1.35, hi = 1.10, acc = 0.30, sz = 0.25, alp = 0.75, gst = 0.20 },
        Ash       = { lo = 1.45, hi = 1.05, acc = 0.35, sz = 0.15, alp = 0.55, gst = 0.20 },
        Sandstorm = { lo = 1.35, hi = 1.60, acc = 0.45, sz = 0.30, alp = 0.75, gst = 0.20 },
        Embers    = { lo = 1.45, hi = 1.05, acc = 0.30, sz = 0.10, alp = 0.25, gst = 0.20 },
        Fireflies = { lo = 1.45, hi = 1.00, acc = 0.10, sz = 0.08, alp = 0.20, gst = 0.15 },
    }
    local IR_DEF = { lo = 1.6, hi = 0.9, acc = 0.3, sz = 0.10, alp = 0.25, gst = 0.25 }
    local SET_LO, SET_HI = 0.75, 0.45
    local Vec   = Vector3.new
    local WHITE = Color3.new(1, 1, 1)
    local TX_SOFT  = "rbxasset://textures/particles/smoke_main.dds"
    local TX_SPARK = "rbxasset://textures/particles/sparkles_main.dds"
    local TX_FLAKE    = "rbxassetid://101749163393113"
    local TX_SNOWSOFT = "rbxassetid://78582616787441"
    local TX_PUFF     = "rbxassetid://77935321198144"
    local TX_PETAL    = "rbxassetid://243344623"
    local TX_LEAFA    = "rbxassetid://8590047664"
    local TX_LEAFB    = "rbxassetid://5970677338"
    local TX_LEAFC    = "rbxassetid://9239040931"
    local TX_DUST     = "rbxassetid://341828512"
    local _curType = nil
    local Wind = { x = 0, z = 0 }
    ;(function()
        local baseAng = math.random() * 6.283
        local gustT0, gustDur, gustAmp = 0, 1, 0
        local nextGustT = math.huge
        local cbs = {}
        function Wind.onGust(fn)
            cbs[#cbs + 1] = fn
        end
        function Wind.reset(now)
            nextGustT = now + 8 + math.random() * 17
            gustT0, gustAmp = 0, 0
            Wind.x, Wind.z = 0, 0
        end
        function Wind.update(now)
            if now >= nextGustT then
                gustT0 = now
                gustDur = 2 + math.random() * 2
                gustAmp = 1 + math.random()
                nextGustT = now + 8 + math.random() * 17
                for i = 1, #cbs do
                    pcall(cbs[i], gustDur, 1 + gustAmp)
                end
            end
            local ang = baseAng + 0.6 * math.sin(now * 0.013) + 0.9 * math.sin(now * 0.031 + 2.6)
            local str = 1 + 0.35 * math.sin(now * 0.17) + 0.22 * math.sin(now * 0.41 + 1.3)
                          + 0.15 * math.sin(now * 0.07 + 4.1)
            local ga = (now - gustT0) / gustDur
            if gustAmp > 0 and ga < 1 then
                str = str * (1 + gustAmp * math.sin(ga * math.pi))
            end
            Wind.x = math.cos(ang) * str
            Wind.z = math.sin(ang) * str
        end
        function Wind.vec()
            return Vec(Wind.x, 0, Wind.z)
        end
    end)()
    local _folder = nil
    local function getFolder()
        if _folder and _folder.Parent then return _folder end
        local f = Instance.new("Folder"); f.Name = "_wx"; f:SetAttribute("WX_Custom", true)
        f.Parent = Workspace
        _folder = f; return f
    end
    local _rain = { drops = {}, conn = nil, folder = nil, dir = nil, applied = nil }
    local RAIN_DIR      = Vec(-0.16, -1, 0.05).Unit
    local RAIN_LEAN_K   = 0.12
    local RAIN_LEAN_MAX = 0.2126
    local RAIN_RADIUS = 70
    local RAIN_TOP    = 70
    local RAIN_BOT    = -28
    local RAIN_MAX    = 420
    local function rainFolder()
        if _rain.folder and _rain.folder.Parent then return _rain.folder end
        local f = Instance.new("Folder"); f.Name = "_wxRain"; f:SetAttribute("WX_Custom", true)
        f.Parent = getFolder()
        _rain.folder = f; return f
    end
    local function makeDrop(parent, streakLen, width, color, glow, transp)
        local part = Instance.new("Part")
        part.Anchored = true; part.CanCollide = false; part.CanQuery = false; part.CanTouch = false
        part.CastShadow = false; part.Massless = true; part.Transparency = 1; part.Size = Vec(0.05,0.05,0.05)
        part:SetAttribute("WX_Custom", true)
        local a0 = Instance.new("Attachment"); a0.Parent = part
        local a1 = Instance.new("Attachment"); a1.Position = _rain.dir * streakLen; a1.Parent = part
        local beam = Instance.new("Beam")
        beam.Attachment0 = a0; beam.Attachment1 = a1
        beam.Segments = 1; beam.FaceCamera = true
        beam.Width0 = width; beam.Width1 = width * 0.55
        local emission = 0.35
        if glow then
            emission = 1
        end
        beam.LightEmission = emission
        beam.LightInfluence = 0
        beam.Color = ColorSequence.new(color)
        beam.Transparency = NumberSequence.new(transp)
        beam.Parent = part
        part.Parent = parent
        return part, a1, beam
    end
    local function seedDrop(d, camPos)
        local ang = math.random() * math.pi * 2
        local rad = math.sqrt(math.random()) * RAIN_RADIUS
        local y   = camPos.Y + RAIN_TOP - math.random() * (RAIN_TOP - RAIN_BOT)
        d.pos = Vec(camPos.X + math.cos(ang) * rad, y, camPos.Z + math.sin(ang) * rad)
    end
    local function newDrop(folder, i, camPos)
        local base, width, color, transp, spd0
        if (i % 3) ~= 0 then
            base, width, transp = 5 + math.random() * 3, 0.10, 0.22
            spd0 = 150 + math.random() * 30
            color = Color3.fromRGB(180, 202, 232)
        else
            base, width, transp = 3 + math.random() * 2, 0.06, 0.55
            spd0 = 120 + math.random() * 30
            color = Color3.fromRGB(158, 182, 214)
        end
        local part, a1, beam = makeDrop(folder, base, width, color, false, transp)
        local d = { part = part, a1 = a1, beam = beam, base = base, len = base,
                    w0 = width, t0 = transp, spd0 = spd0, spd = spd0 }
        seedDrop(d, camPos)
        part.CFrame = CFrame.new(d.pos)
        return d
    end
    local function tuneRain()
        local folder = rainFolder()
        local I = iAmt()
        local n = math.clamp(math.floor(150 * iRate(I, 1.75, 0.85)), 16, RAIN_MAX)
        local drops = _rain.drops
        local camPos = Vec(0, 0, 0)
        if Camera then
            camPos = Camera.CFrame.Position
        end
        for i = #drops, n + 1, -1 do
            drops[i].part:Destroy()
            drops[i] = nil
        end
        for i = #drops + 1, n do
            drops[i] = newDrop(folder, i, camPos)
        end
        local sm = 0.55 + 0.45 * I
        local wm = 0.85 + 0.15 * I
        local am = 0.78 + 0.22 * I
        local dir = _rain.applied or _rain.dir or RAIN_DIR
        for i = 1, n do
            local d = drops[i]
            d.spd = d.spd0 * sm
            d.len = d.base * sm
            d.a1.Position = dir * d.len
            local w = d.w0 * wm
            d.beam.Width0 = w
            d.beam.Width1 = w * 0.55
            d.beam.Transparency = NumberSequence.new(math.clamp(1 - (1 - d.t0) * am, 0.02, 1))
        end
    end
    local function buildRain()
        if _rain.folder then pcall(function() _rain.folder:Destroy() end); _rain.folder = nil end
        table.clear(_rain.drops)
        if not _rain.dir then _rain.dir = RAIN_DIR end
        _rain.applied = _rain.dir
        tuneRain()
    end
    local function startRain()
        if _rain.conn then return end
        _rain.conn = RunService.Heartbeat:Connect(function(dt)
            if not Config.Weather or _curType ~= "Rain" then return end
            local cam = Camera; if not cam then return end
            local camPos = cam.CFrame.Position
            local lx, lz = Wind.x * RAIN_LEAN_K, Wind.z * RAIN_LEAN_K
            local lm = math.sqrt(lx * lx + lz * lz)
            if lm > RAIN_LEAN_MAX then
                local s = RAIN_LEAN_MAX / lm
                lx, lz = lx * s, lz * s
            end
            local step = _rain.dir:Lerp(Vec(lx, -1, lz).Unit, math.min(dt * 2, 1)).Unit
            _rain.dir = step
            if (step - _rain.applied).Magnitude > 0.015 then
                _rain.applied = step
                for i = 1, #_rain.drops do
                    local d = _rain.drops[i]
                    d.a1.Position = step * d.len
                end
            end
            local r2 = RAIN_RADIUS * RAIN_RADIUS
            for i = 1, #_rain.drops do
                local d = _rain.drops[i]
                local p = d.pos + step * (d.spd * dt)
                local relX, relY, relZ = p.X - camPos.X, p.Y - camPos.Y, p.Z - camPos.Z
                if relY < RAIN_BOT or (relX * relX + relZ * relZ) > r2 then
                    seedDrop(d, camPos)
                    p = d.pos
                end
                d.pos = p
                if d.part then d.part.CFrame = CFrame.new(p) end
            end
        end)
    end
    local function stopRain()
        if _rain.conn then _rain.conn:Disconnect(); _rain.conn = nil end
        if _rain.folder then pcall(function() _rain.folder:Destroy() end); _rain.folder = nil end
        table.clear(_rain.drops)
        _rain.dir = nil; _rain.applied = nil
    end
    local ND = Enum.NormalId
    local function flutterSeq(lo, hi, n, env, flip)
        local kps = table.create(n + 1)
        for i = 0, n do
            local v = lo
            if (i + flip) % 2 == 1 then
                v = hi
            end
            kps[i + 1] = NumberSequenceKeypoint.new(i / n, v, env)
        end
        return NumberSequence.new(kps)
    end
    local PRESETS = {
        Snow = {
            { size=Vec(22,4,22), oy=5, tex=TX_FLAKE, color=WHITE,
              skeys={{0,1.7,0.35},{1,1.35,0.3}}, squash=-0.12, transp0=0.18,transp1=0.55,
              rate=0.7, speed={0.8,1.6}, life={5,7}, spread=28, rot={-60,60}, rotSpd=26,
              accel=Vec(0,-2.4,0), drag=2.2, glow=0.2, dir=ND.Bottom,
              gust={ax=1.8,az=1.2,wx=0.4,wz=0.31,ph=0.5} },
            { size=Vec(46,4,46), oy=10, tex=TX_SNOWSOFT, color=WHITE,
              skeys={{0,0.48,0.15},{1,0.38,0.10}}, squash=-0.05, transp0=0.7,transp1=0.92,
              rate=12, speed={1.5,3}, life={5,8}, spread=45, rot={-180,180}, rotSpd=10,
              accel=Vec(0,-3.5,0), drag=1.8, glow=0.12, dir=ND.Bottom,
              gust={ax=2.5,az=1.6,wx=0.37,wz=0.29,ph=0} },
            { size=Vec(140,4,140), oy=20, tex=TX_FLAKE, color=Color3.fromRGB(242,248,255),
              skeys={{0,0.5,0.2},{1,0.38,0.14}}, squash=-0.08, transp0=0.08,transp1=0.5,
              rate=190, speed={2,4}, life={7,10}, spread=50, rot={-180,180}, rotSpd=42,
              accel=Vec(0,-5,0), drag=1.7, glow=0.35, dir=ND.Bottom,
              gust={ax=2.2,az=1.4,wx=0.33,wz=0.26,ph=1.9} },
            { size=Vec(220,4,220), oy=32, tex=TX_SNOWSOFT, color=Color3.fromRGB(214,231,255),
              skeys={{0,0.3,0.08},{1,0.22,0.06}}, transp0=0.5,transp1=0.85,
              rate=265, speed={2,4}, life={8,11}, spread=55, rot={-30,30}, rotSpd=12,
              accel=Vec(0,-5.5,0), drag=1.5, glow=0.3, dir=ND.Bottom,
              gust={ax=1.5,az=1,wx=0.29,wz=0.25,ph=3.8} },
            { size=Vec(100,4,100), oy=12, tex=TX_SPARK, color=WHITE,
              skeys={{0,0.4,0.12},{1,0.32,0.1}},
              tkeys={{0,1},{0.2,0.5},{0.45,0.78},{0.62,0.42},{0.85,0.78},{1,1}},
              rate=10, speed={2,4}, life={5,8}, spread=45, rot={-180,180}, rotSpd=60,
              accel=Vec(0,-4.5,0), drag=1.6, glow=0.7, dir=ND.Bottom,
              gust={ax=2.2,az=1.4,wx=0.35,wz=0.27,ph=1} },
        },
        Mist = {
            { size=Vec(150,8,150), oy=0, tex=TX_SOFT, color=Color3.fromRGB(210,216,226),
              size0=26,size1=44, transp0=0.68,transp1=0.94,
              rate=16, speed={0.8,2.2}, life={9,13}, spread=20, rot={-5,5}, rotSpd=3,
              accel=Vec(2.2,0.25,1.2), drag=0.8, dir=ND.Top },
            { size=Vec(110,6,110), oy=1, tex=TX_SOFT, color=Color3.fromRGB(228,232,240),
              size0=12,size1=22, transp0=0.75,transp1=0.95,
              rate=10, speed={1.5,3}, life={6,9}, spread=25, rot={-8,8}, rotSpd=5,
              accel=Vec(3,0.4,1.6), drag=0.8, dir=ND.Top },
        },
        Embers = {
            { size=Vec(90,28,90), oy=2, tex=TX_SOFT, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,170,60)),
                  ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,95,25)),
                  ColorSequenceKeypoint.new(1,   Color3.fromRGB(165,35,12)) }),
              size0=0.85,size1=0.3, transp0=0.05,transp1=0.85,
              rate=80, speed={3,7}, life={3,5}, spread=40, rot={-60,60}, rotSpd=90,
              accel=Vec(1.5,9,1), drag=1.6, glow=0.35, dir=ND.Top },
            { size=Vec(120,30,120), oy=6, tex=TX_SPARK, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0, Color3.fromRGB(255,220,140)),
                  ColorSequenceKeypoint.new(1, Color3.fromRGB(255,110,40)) }),
              size0=0.3,size1=0.08, transp0=0.05,transp1=0.9,
              rate=55, speed={2,5}, life={2.5,4}, spread=55, rot={-40,40}, rotSpd=60,
              accel=Vec(1,7,0.8), drag=1.4, glow=0.9, dir=ND.Top },
        },
        Fireflies = {
            { size=Vec(70,8,70), oy=-2, tex=TX_SNOWSOFT, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0,   Color3.fromRGB(220,255,130)),
                  ColorSequenceKeypoint.new(0.5, Color3.fromRGB(205,245,100)),
                  ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,200,80)) }),
              skeys={{0,0.1},{0.08,0.62,0.15},{0.45,0.5,0.1},{1,0.08}},
              tkeys={{0,1},{0.08,0.08},{0.4,0.45},{0.75,0.85},{1,1}},
              rate=18, speed={0.5,1.6}, life={2.5,4}, spread=180, rot={0,0}, rotSpd=0,
              accel=Vec(0,0.3,0), drag=2.5, glow=0.95, dir=ND.Top },
            { size=Vec(140,14,140), oy=-1, tex=TX_SNOWSOFT, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0, Color3.fromRGB(175,225,95)),
                  ColorSequenceKeypoint.new(1, Color3.fromRGB(200,190,70)) }),
              skeys={{0,0.06},{0.1,0.32,0.08},{0.5,0.26},{1,0.05}},
              tkeys={{0,1},{0.1,0.3},{0.5,0.6},{1,1}},
              rate=18, speed={0.4,1.2}, life={3,5}, spread=180, rot={0,0}, rotSpd=0,
              accel=Vec(0,0.3,0), drag=2.5, glow=0.95, dir=ND.Top },
            { size=Vec(120,4,120), oy=-4, tex=TX_PUFF, color=Color3.fromRGB(148,158,178),
              size0=13,size1=22, tkeys={{0,1},{0.2,0.8},{0.7,0.89},{1,1}},
              rate=8, speed={0.5,1.5}, life={8,12}, spread=14, rot={-180,180}, rotSpd=4,
              accel=Vec(1.2,0.12,0.7), drag=0.7, glow=0, dir=ND.Top,
              gust={ax=1.2,az=0.8,wx=0.23,wz=0.19,ph=2.2} },
        },
        Petals = {
            { size=Vec(26,6,26), oy=3, tex=TX_SNOWSOFT, zoff=3, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0, Color3.fromRGB(255,222,232)),
                  ColorSequenceKeypoint.new(1, Color3.fromRGB(250,205,220)) }),
              skeys={{0,1.75,0.5},{1,1.4,0.3}}, transp0=0.78,transp1=0.92,
              rate=7, speed={0.4,1.1}, life={5,7}, spread=30, rot={-180,180}, rotSpd=22,
              accel=Vec(0,-3,0), drag=1.7, glow=0.04, dir=ND.Bottom,
              gust={ax=2.2,az=1.5,wx=0.43,wz=0.33,ph=1.4} },
            { size=Vec(64,12,64), oy=5, tex=TX_PETAL, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0,    Color3.fromRGB(255,222,234)),
                  ColorSequenceKeypoint.new(0.55, Color3.fromRGB(248,178,206)),
                  ColorSequenceKeypoint.new(1,    Color3.fromRGB(226,132,176)) }),
              skeys={{0,2.05,0.5},{1,1.7,0.35}}, qseq=flutterSeq(-0.88, 0.08, 14, 0.12, 0),
              transp0=0.1,transp1=0.38,
              rate=13, speed={0.6,1.4}, life={6,8}, spread=35, rot={-180,180}, rotSpd=95,
              accel=Vec(0,-3.5,0), drag=1.6, glow=0.08, dir=ND.Bottom,
              gust={ax=2.6,az=1.8,wx=0.4,wz=0.31,ph=0.5} },
            { size=Vec(76,12,76), oy=7, tex=TX_PETAL, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0,    Color3.fromRGB(250,224,200)),
                  ColorSequenceKeypoint.new(0.55, Color3.fromRGB(244,203,178)),
                  ColorSequenceKeypoint.new(1,    Color3.fromRGB(230,176,150)) }),
              skeys={{0,1.55,0.4},{1,1.28,0.28}}, qseq=flutterSeq(-0.8, 0.15, 12, 0.15, 1),
              transp0=0.14,transp1=0.44,
              rate=12, speed={0.8,1.8}, life={6,8.5}, spread=42, rot={-180,180}, rotSpd=140,
              accel=Vec(0,-3.2,0), drag=1.55, glow=0.05, dir=ND.Bottom,
              gust={ax=3,az=2,wx=0.37,wz=0.29,ph=2.1} },
            { size=Vec(130,6,130), oy=15, tex=TX_PETAL, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0, Color3.fromRGB(255,222,234)),
                  ColorSequenceKeypoint.new(1, Color3.fromRGB(246,178,204)) }),
              skeys={{0,0.85,0.26},{1,0.68,0.18}}, qseq=flutterSeq(-0.7, 0.1, 8, 0.2, 0),
              transp0=0.06,transp1=0.44,
              rate=120, speed={1.4,3}, life={7,9}, spread=48, rot={-180,180}, rotSpd=170,
              accel=Vec(0,-5.2,0), drag=1.5, glow=0.1, dir=ND.Bottom,
              gust={ax=3.2,az=2.2,wx=0.33,wz=0.26,ph=1.9} },
            { size=Vec(240,6,240), oy=26, tex=TX_PETAL, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0, Color3.fromRGB(250,214,228)),
                  ColorSequenceKeypoint.new(1, Color3.fromRGB(238,190,210)) }),
              skeys={{0,0.3,0.09},{1,0.24,0.06}}, squash=-0.5, transp0=0.42,transp1=0.8,
              rate=170, speed={1.5,3.2}, life={8,11}, spread=55, rot={-180,180}, rotSpd=90,
              accel=Vec(0,-6,0), drag=1.35, glow=0.08, dir=ND.Bottom,
              gust={ax=2.4,az=1.6,wx=0.29,wz=0.25,ph=3.8} },
            { size=Vec(56,1.2,56), oy=-3.7, tex=TX_PETAL, tag="settle",
              color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0, Color3.fromRGB(255,214,228)),
                  ColorSequenceKeypoint.new(1, Color3.fromRGB(240,178,204)) }),
              skeys={{0,1.1,0.3},{1,0.95,0.2}}, qseq=flutterSeq(-0.92, -0.2, 10, 0.1, 0),
              transp0=0.05,transp1=0.42,
              rate=34, speed={0.05,0.5}, life={14,20}, spread=90, rot={-180,180}, rotSpd=25,
              accel=Vec(0,-0.15,0), drag=2.6, glow=0.08, dir=ND.Bottom,
              gust={ax=3.6,az=3,wx=0.5,wz=0.44,ph=0.9} },
        },
        Autumn = {
            { size=Vec(20,6,20), oy=13, uw=8, tex=TX_LEAFA, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0,    Color3.fromRGB(226,190,128)),
                  ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255,246,200)),
                  ColorSequenceKeypoint.new(1,    Color3.fromRGB(190,132,62)) }),
              skeys={{0,0.62,0.14},{1,0.54,0.10}}, qseq=flutterSeq(-0.60, 0.14, 13, 0.10, 0),
              transp0=0.08,transp1=0.42,
              rate=14, speed={0.6,1.6}, life={7,9}, spread=34, rot={-180,180}, rotSpd=130,
              accel=Vec(0,-5,0), drag=1.5, glow=0.62, dir=ND.Bottom,
              gust={ax=3.4,az=2.2,wx=0.41,wz=0.3,ph=0.5} },
            { size=Vec(22,6,22), oy=15, uw=8, tex=TX_LEAFB, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0, Color3.fromRGB(156,74,255)),
                  ColorSequenceKeypoint.new(1, Color3.fromRGB(106,46,200)) }),
              skeys={{0,0.60,0.14},{1,0.52,0.10}}, qseq=flutterSeq(-0.56, 0.20, 11, 0.14, 1),
              transp0=0.12,transp1=0.46,
              rate=9, speed={0.8,1.9}, life={7,9}, spread=40, rot={-180,180}, rotSpd=185,
              accel=Vec(0,-5.6,0), drag=1.5, glow=0.07, dir=ND.Bottom,
              gust={ax=3.9,az=2.6,wx=0.36,wz=0.27,ph=2.1} },
            { size=Vec(150,8,150), oy=16, uw=26, tex=TX_LEAFA, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0,    Color3.fromRGB(226,190,128)),
                  ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255,246,200)),
                  ColorSequenceKeypoint.new(1,    Color3.fromRGB(190,132,62)) }),
              skeys={{0,0.56,0.16},{1,0.44,0.11}}, qseq=flutterSeq(-0.50, 0.10, 8, 0.16, 0),
              transp0=0.08,transp1=0.50,
              rate=24, speed={1.4,3}, life={7,9}, spread=54, rot={-180,180}, rotSpd=210,
              accel=Vec(0,-7,0), drag=1.45, glow=0.62, dir=ND.Bottom,
              gust={ax=4.2,az=2.8,wx=0.33,wz=0.24,ph=1.9} },
            { size=Vec(150,8,150), oy=16, uw=26, tex=TX_LEAFB, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0, Color3.fromRGB(160,80,52)),
                  ColorSequenceKeypoint.new(1, Color3.fromRGB(104,44,30)) }),
              skeys={{0,0.54,0.16},{1,0.42,0.11}}, qseq=flutterSeq(-0.54, 0.14, 9, 0.16, 1),
              transp0=0.10,transp1=0.50,
              rate=21, speed={1.4,3.1}, life={7,9}, spread=54, rot={-180,180}, rotSpd=200,
              accel=Vec(0,-7.2,0), drag=1.45, glow=0.07, dir=ND.Bottom,
              gust={ax=4,az=2.7,wx=0.31,wz=0.26,ph=3.3} },
            { size=Vec(150,8,150), oy=16, uw=26, tex=TX_LEAFA, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0,   Color3.fromRGB(230,222,176)),
                  ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,254,228)),
                  ColorSequenceKeypoint.new(1,   Color3.fromRGB(200,180,122)) }),
              skeys={{0,0.52,0.15},{1,0.41,0.10}}, qseq=flutterSeq(-0.52, 0.12, 10, 0.16, 1),
              transp0=0.10,transp1=0.52,
              rate=17, speed={1.3,2.9}, life={7,9}, spread=52, rot={-180,180}, rotSpd=190,
              accel=Vec(0,-6.8,0), drag=1.45, glow=0.60, dir=ND.Bottom,
              gust={ax=4.1,az=2.7,wx=0.35,wz=0.28,ph=2.7} },
            { size=Vec(150,8,150), oy=16, uw=26, tex=TX_LEAFB, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0, Color3.fromRGB(156,74,255)),
                  ColorSequenceKeypoint.new(1, Color3.fromRGB(106,46,200)) }),
              skeys={{0,0.53,0.16},{1,0.42,0.11}}, qseq=flutterSeq(-0.52, 0.16, 9, 0.16, 0),
              transp0=0.10,transp1=0.50,
              rate=12, speed={1.4,3.1}, life={7,9}, spread=54, rot={-180,180}, rotSpd=220,
              accel=Vec(0,-7.1,0), drag=1.45, glow=0.07, dir=ND.Bottom,
              gust={ax=4,az=2.7,wx=0.3,wz=0.25,ph=5.1} },
            { size=Vec(150,8,150), oy=16, uw=20, tex=TX_LEAFC, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0, Color3.fromRGB(196,156,112)),
                  ColorSequenceKeypoint.new(1, Color3.fromRGB(146,110,74)) }),
              skeys={{0,0.50,0.15},{1,0.40,0.10}}, qseq=flutterSeq(-0.52, 0.10, 7, 0.16, 0),
              transp0=0.14,transp1=0.55,
              rate=11, speed={1.5,3.2}, life={7,9}, spread=56, rot={-180,180}, rotSpd=240,
              accel=Vec(0,-7.6,0), drag=1.45, glow=0.08, dir=ND.Bottom,
              gust={ax=3.8,az=2.6,wx=0.29,wz=0.23,ph=0.9} },
            { size=Vec(150,8,150), oy=16, uw=26, tex=TX_LEAFA, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0, Color3.fromRGB(152,255,255)),
                  ColorSequenceKeypoint.new(1, Color3.fromRGB(118,214,240)) }),
              skeys={{0,0.52,0.15},{1,0.41,0.10}}, qseq=flutterSeq(-0.50, 0.14, 8, 0.16, 1),
              transp0=0.12,transp1=0.52,
              rate=10, speed={1.4,3}, life={7,9}, spread=54, rot={-180,180}, rotSpd=195,
              accel=Vec(0,-7,0), drag=1.45, glow=0.16, dir=ND.Bottom,
              gust={ax=4.1,az=2.7,wx=0.34,wz=0.27,ph=4.2} },
            { size=Vec(300,30,300), oy=30, uw=60, tex=TX_LEAFA, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0,    Color3.fromRGB(226,190,128)),
                  ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255,246,200)),
                  ColorSequenceKeypoint.new(1,    Color3.fromRGB(190,132,62)) }),
              skeys={{0,0.24,0.06},{1,0.18,0.04}}, squash=-0.35, transp0=0.68,transp1=0.92,
              rate=30, speed={1.5,3.2}, life={8,11}, spread=55, rot={-180,180}, rotSpd=110,
              accel=Vec(0,-8,0), drag=1.35, glow=0.55, dir=ND.Bottom,
              gust={ax=3.1,az=2.1,wx=0.27,wz=0.24,ph=1.2} },
            { size=Vec(300,30,300), oy=30, uw=60, tex=TX_LEAFB, color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0, Color3.fromRGB(160,80,52)),
                  ColorSequenceKeypoint.new(1, Color3.fromRGB(104,44,30)) }),
              skeys={{0,0.23,0.06},{1,0.17,0.04}}, squash=-0.35, transp0=0.70,transp1=0.93,
              rate=24, speed={1.5,3.2}, life={8,11}, spread=55, rot={-180,180}, rotSpd=120,
              accel=Vec(0,-8,0), drag=1.35, glow=0.07, dir=ND.Bottom,
              gust={ax=3,az=2,wx=0.29,wz=0.22,ph=3.8} },
            { size=Vec(120,16,120), oy=6, tex=TX_LEAFA, tag="streak", aim=true,
              orient=Enum.ParticleOrientation.VelocityParallel,
              color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0,    Color3.fromRGB(226,190,128)),
                  ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255,246,200)),
                  ColorSequenceKeypoint.new(1,    Color3.fromRGB(190,132,62)) }),
              skeys={{0,0.66,0.16},{1,0.46,0.10}}, squash=-0.55,
              tkeys={{0,1},{0.08,0.06},{0.72,0.34},{1,1}},
              rate=0, speed={16,26}, life={1,1.9}, spread=13, rot={-180,180}, rotSpd=300,
              accel=Vec(0,-3.4,0), drag=2.6, glow=0.62, dir=ND.Front,
              gust={ax=5,az=4,wx=0.4,wz=0.35,ph=0} },
            { size=Vec(120,16,120), oy=5, tex=TX_LEAFB, tag="streak", aim=true,
              orient=Enum.ParticleOrientation.VelocityParallel,
              color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0, Color3.fromRGB(160,80,52)),
                  ColorSequenceKeypoint.new(1, Color3.fromRGB(104,44,30)) }),
              skeys={{0,0.62,0.16},{1,0.44,0.10}}, squash=-0.55,
              tkeys={{0,1},{0.08,0.08},{0.72,0.38},{1,1}},
              rate=0, speed={15,24}, life={1,1.8}, spread=14, rot={-180,180}, rotSpd=280,
              accel=Vec(0,-3.6,0), drag=2.6, glow=0.07, dir=ND.Front,
              gust={ax=5,az=4,wx=0.37,wz=0.33,ph=1.7} },
            { size=Vec(96,0.9,96), oy=-3.9, tex=TX_LEAFA, tag="settle",
              color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0,   Color3.fromRGB(200,150,86)),
                  ColorSequenceKeypoint.new(0.5, Color3.fromRGB(168,110,58)),
                  ColorSequenceKeypoint.new(1,   Color3.fromRGB(130,80,44)) }),
              skeys={{0,0.50,0.14},{1,0.44,0.10}}, qseq=flutterSeq(-0.62, -0.05, 10, 0.1, 0),
              transp0=0.06,transp1=0.46,
              rate=34, speed={0.8,3.2}, life={10,16}, spread=90, rot={-180,180}, rotSpd=90,
              accel=Vec(0,-0.15,0), drag=3.2, glow=0.32, dir=ND.Bottom,
              gust={ax=9,az=8,wx=0.5,wz=0.44,ph=0.9} },
            { size=Vec(70,0.8,70), oy=-3.85, tex=TX_LEAFB, tag="settle",
              color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0, Color3.fromRGB(160,80,52)),
                  ColorSequenceKeypoint.new(1, Color3.fromRGB(104,44,30)) }),
              skeys={{0,0.54,0.12},{1,0.46,0.08}}, qseq=flutterSeq(-0.66, 0.26, 16, 0.06, 0),
              transp0=0.05,transp1=0.44,
              rate=14, speed={0.6,2.2}, life={3,5}, spread=70, rot={-180,180}, rotSpd=340,
              accel=Vec(0,-1.2,0), drag=1.9, glow=0.10, dir=ND.Top,
              gust={ax=8,az=7,wx=0.62,wz=0.55,ph=2.4} },
            { size=Vec(74,0.6,74), oy=-3.95, tex=TX_LEAFC, tag="settle",
              orient=Enum.ParticleOrientation.VelocityPerpendicular,
              color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0, Color3.fromRGB(190,146,96)),
                  ColorSequenceKeypoint.new(1, Color3.fromRGB(150,110,72)) }),
              skeys={{0,0.76,0.16},{1,0.72,0.12}}, squash=0, transp0=0.04,transp1=0.30,
              rate=42, speed={0.04,0.1}, life={20,28}, spread=90, rot={-180,180}, rotSpd=3,
              accel=Vec(0,-0.12,0), drag=4, glow=0.22, dir=ND.Bottom },
            { size=Vec(80,0.8,80), oy=-4, tex=TX_DUST, tag="dust",
              color=ColorSequence.new({
                  ColorSequenceKeypoint.new(0, Color3.fromRGB(206,180,140)),
                  ColorSequenceKeypoint.new(1, Color3.fromRGB(150,124,92)) }),
              skeys={{0,1.1,0.35},{1,3.4,0.5}}, tkeys={{0,1},{0.18,0.84},{0.7,0.93},{1,1}},
              rate=0, speed={2,6}, life={1.1,2}, spread=85, rot={-180,180}, rotSpd=22,
              accel=Vec(0,0.6,0), drag=2.4, glow=0.06, dir=ND.Top,
              gust={ax=8,az=7,wx=0.4,wz=0.35,ph=0} },
        },
        Ash = {
            { size=Vec(110,4,110), oy=16, tex=TX_SOFT, color=Color3.fromRGB(96,90,86),
              size0=0.4,size1=0.3, transp0=0.05,transp1=0.5,
              rate=140, speed={2,4}, life={6,9}, spread=45, rot={-60,60}, rotSpd=45,
              accel=Vec(-3.5,-5,2), drag=1.6, glow=0, dir=ND.Bottom },
            { size=Vec(170,4,170), oy=26, tex=TX_SPARK, color=Color3.fromRGB(255,140,70),
              size0=0.14,size1=0.05, transp0=0.15,transp1=0.9,
              rate=26, speed={1.5,3.5}, life={4,7}, spread=60, rot={-40,40}, rotSpd=70,
              accel=Vec(-2.5,-2,1.5), drag=1.5, glow=0.9, dir=ND.Bottom },
        },
        Sandstorm = {
            { size=Vec(160,20,160), oy=6, tex=TX_SOFT, color=Color3.fromRGB(194,168,120),
              size0=24,size1=38, transp0=0.58,transp1=0.93,
              rate=24, speed={8,15}, life={5,8}, spread=28, rot={-8,8}, rotSpd=6,
              accel=Vec(20,0.5,7), drag=0.6, dir=ND.Right },
        },
    }
    Weather.TypeOrder = { "Rain", "Snow", "Mist", "Embers", "Fireflies", "Petals", "Autumn",
                          "Ash", "Sandstorm", "BloodMoon" }
    local MOOD = {
        Rain      = { B=-0.03, C=0.08,  S=-0.12, tint=Color3.fromRGB(205,220,255) },
        Snow      = { B= 0.03, C=0.05,  S=-0.08, tint=Color3.fromRGB(226,240,255) },
        Mist      = { B=-0.01, C=-0.05, S=-0.20, tint=Color3.fromRGB(220,224,230) },
        Embers    = { B= 0.02, C=0.08,  S= 0.10, tint=Color3.fromRGB(255,238,220) },
        Fireflies = { B=-0.04, C=0.06,  S= 0.02, tint=Color3.fromRGB(238,228,205) },
        Petals    = { B= 0.00, C=0.09,  S= 0.05, tint=Color3.fromRGB(255,234,234) },
        Autumn    = { B= 0.005, C=0.08, S= 0.04, tint=Color3.fromRGB(253,244,232) },
        Ash       = { B=-0.04, C=0.06,  S=-0.25, tint=Color3.fromRGB(225,220,215) },
        Sandstorm = { B=-0.02, C=0.10,  S= 0.05, tint=Color3.fromRGB(224,196,150) },
        BloodMoon = { B=-0.05, C=0.12,  S=-0.20, tint=Color3.fromRGB(255,180,180) },
    }
    local SOUND = { Rain="rain", Snow="wind", Mist="wind", Embers="fire",
                    Fireflies="night", Petals="birds", Autumn="wind", Ash="wind",
                    Sandstorm="wind", BloodMoon="night" }
    local function ambientId(mood)
        local map = cfg("WeatherSoundIds", nil)
        if type(map) == "table" and map[mood] and map[mood] ~= "" then return map[mood] end
        return nil
    end
    local _partLayers = {}
    local _ambient  = nil
    local _moodCC   = nil
    local _moodTween = nil
    local FADE_TI = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local MOOD_TI = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local _followConn = nil
    local _lightFolder = nil
    local _rays = nil
    local _special = { moon = nil, shell = nil, sky = nil, cc = nil, atmo = nil, halo = nil, kind = nil }
    local _specialConn = nil
    local _clockConn = nil
    local function clearPartLayers()
        for _, L in _partLayers do
            if L.rateTween then L.rateTween:Cancel() end
            if L.host then pcall(function() L.host:Destroy() end) end
        end
        table.clear(_partLayers)
    end
    local _fadeLayers = {}
    local _fadeToken = 0
    local function killFade()
        _fadeToken = _fadeToken + 1
        for _, F in _fadeLayers do
            local host = F.host
            pcall(function() host:Destroy() end)
        end
        table.clear(_fadeLayers)
    end
    local function beginLayerFade()
        killFade()
        local maxLife = 0
        for _, L in _partLayers do
            if L.rateTween then L.rateTween:Cancel() end
            if L.emitter then
                TweenService:Create(L.emitter, FADE_TI, { Rate = 0 }):Play()
            end
            if L.life2 > maxLife then maxLife = L.life2 end
            _fadeLayers[#_fadeLayers + 1] = { host = L.host, oy = L.oy }
        end
        table.clear(_partLayers)
        local tok = _fadeToken
        task.delay(FADE_TI.Time + maxLife, function()
            if tok == _fadeToken then killFade() end
        end)
    end
    local _spectacles, _spectWeight, _spectNextT = {}, 0, 0
    local function registerSpectacle(name, weight, fn)
        _spectacles[#_spectacles + 1] = { name = name, weight = weight, fn = fn }
        _spectWeight = _spectWeight + weight
    end
    local _blizzT0, _blizzDur = 0, 1
    local function layerRate(L, I)
        if L.spec.tag == "settle" then
            return L.spec.rate * iRate(I, SET_LO, SET_HI)
        end
        return L.spec.rate * iRate(I, L.ir.lo, L.ir.hi)
    end
    local function tuneLayer(L, I)
        local spec, R, e = L.spec, L.ir, L.emitter
        local am = 1
        if spec.tag ~= "settle" then
            am = 1 - R.acc + R.acc * I
        end
        L.accel = spec.accel * am
        if not spec.gust then
            e.Acceleration = L.accel
        end
        e.Speed = NumberRange.new(spec.speed[1] * am, spec.speed[2] * am)
        if spec.gust then
            local gm = 1 - R.gst + R.gst * I
            L.gax, L.gaz = spec.gust.ax * gm, spec.gust.az * gm
        end
        local sm = 1 - R.sz + R.sz * I
        if spec.skeys then
            local ks = spec.skeys
            local kps = table.create(#ks)
            for i = 1, #ks do
                local k = ks[i]
                kps[i] = NumberSequenceKeypoint.new(k[1], k[2] * sm, (k[3] or 0) * sm)
            end
            e.Size = NumberSequence.new(kps)
        else
            e.Size = NumberSequence.new(spec.size0 * sm, spec.size1 * sm)
        end
        if not spec.tkeys then
            local om = 1 - R.alp + R.alp * I
            e.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0,    1),
                NumberSequenceKeypoint.new(0.12, math.clamp(1 - (1 - spec.transp0) * om, 0, 1)),
                NumberSequenceKeypoint.new(0.8,  math.clamp(1 - (1 - spec.transp1) * om, 0, 1)),
                NumberSequenceKeypoint.new(1,    1),
            })
        end
    end
    local function mkPartLayer(spec, ir, rampIn)
        local host = Instance.new("Part")
        host.Name = "_wxHost"; host.Anchored = true; host.CanCollide = false; host.CanQuery = false
        host.CanTouch = false; host.CastShadow = false; host.Transparency = 1; host.Massless = true
        host.Size = spec.size; host:SetAttribute("WX_Custom", true)
        host.Parent = getFolder()
        local e = Instance.new("ParticleEmitter")
        e:SetAttribute("WX_Custom", true)
        e.Texture = spec.tex
        local colorSeq = spec.color
        if typeof(colorSeq) ~= "ColorSequence" then
            colorSeq = ColorSequence.new(colorSeq)
        end
        e.Color = colorSeq
        local glow = spec.glow or 0
        e.LightEmission  = glow
        e.LightInfluence = 1 - math.min(glow, 1)
        e.Lifetime = NumberRange.new(spec.life[1], spec.life[2])
        e.SpreadAngle = Vector2.new(spec.spread, spec.spread)
        local rot0, rot1 = 0, 360
        if spec.rot then
            rot0, rot1 = spec.rot[1], spec.rot[2]
        end
        e.Rotation = NumberRange.new(rot0, rot1)
        e.RotSpeed = NumberRange.new(-(spec.rotSpd or 45), spec.rotSpd or 45)
        if spec.qseq then
            e.Squash = spec.qseq
        else
            e.Squash = NumberSequence.new(spec.squash or 0)
        end
        if spec.tkeys then
            local kps = table.create(#spec.tkeys)
            for i = 1, #spec.tkeys do kps[i] = NumberSequenceKeypoint.new(spec.tkeys[i][1], spec.tkeys[i][2]) end
            e.Transparency = NumberSequence.new(kps)
        end
        e.Drag = spec.drag or 0
        e.ZOffset = spec.zoff or 0
        e.EmissionDirection = spec.dir
        if spec.orient then
            e.Orientation = spec.orient
        end
        e.Parent = host
        local L = { host = host, oy = spec.oy, emitter = e, spec = spec, ir = ir,
                    accel = spec.accel, gust = spec.gust, tag = spec.tag,
                    gax = 0, gaz = 0, rateMul = 1,
                    uw = spec.uw, aim = spec.aim,
                    life2 = spec.life[2], rateTween = nil }
        local I = iAmt()
        tuneLayer(L, I)
        local targetRate = layerRate(L, I)
        if rampIn then
            e.Rate = 0
            L.rateTween = TweenService:Create(e, FADE_TI, { Rate = targetRate })
            L.rateTween:Play()
        else
            e.Rate = targetRate
        end
        _partLayers[#_partLayers + 1] = L
    end
    local function clearMood()
        if _moodTween then _moodTween:Cancel(); _moodTween = nil end
        if _moodCC then pcall(function() _moodCC:Destroy() end); _moodCC = nil end
    end
    local function applyMood(name)
        if not cfg("WeatherMood", true) then
            clearMood()
            return
        end
        local m = MOOD[name]
        if not m then
            clearMood()
            return
        end
        if _moodTween then _moodTween:Cancel(); _moodTween = nil end
        local g = 0.6 + 0.4 * iAmt()
        local cc = _moodCC
        if cc and cc.Parent then
            _moodTween = TweenService:Create(cc, MOOD_TI,
                { Brightness = m.B * g, Contrast = m.C * g, Saturation = m.S * g, TintColor = m.tint })
            _moodTween:Play()
            return
        end
        cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "_wxMood"; cc:SetAttribute("WX_Custom", true)
        cc.Brightness = m.B * g; cc.Contrast = m.C * g; cc.Saturation = m.S * g; cc.TintColor = m.tint
        cc.Parent = Lighting
        _moodCC = cc
    end
    local function startAmbient(mood)
        if _ambient then pcall(function() _ambient:Destroy() end); _ambient = nil end
        local id = mood and ambientId(mood)
        if not id then return end
        local s = Instance.new("Sound")
        s.Name = "_wxAmb"; s:SetAttribute("WX_Custom", true)
        s.SoundId = id; s.Looped = true; s.Volume = cfg("WeatherSoundVolume", 0.35)
        s.Parent = SoundService
        pcall(function() s:Play() end)
        _ambient = s
    end
    local function oneShot(id, vol, pitch)
        if not id or id == "" then return end
        local s = Instance.new("Sound")
        s.Name = "_wxSfx"; s:SetAttribute("WX_Custom", true)
        s.SoundId = id; s.Volume = math.clamp(vol, 0, 10)
        if pitch then s.PlaybackSpeed = pitch end
        s.Parent = SoundService
        pcall(function() s:Play() end)
        Debris:AddItem(s, 8)
    end
    local function getLightFolder()
        if _lightFolder and _lightFolder.Parent then return _lightFolder end
        local f = Instance.new("Folder"); f.Name = "_wxBolts"; f:SetAttribute("WX_Custom", true)
        f.Parent = getFolder()
        _lightFolder = f; return f
    end
    local function mkBoltPart(color, transp, size, cf, parent)
        local p = Instance.new("Part")
        p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
        p.CastShadow = false; p.Massless = true; p.Material = Enum.Material.Neon
        p.Color = color; p.Transparency = transp; p:SetAttribute("WX_Custom", true)
        p.Size = size; p.CFrame = cf; p.Parent = parent
        return p
    end
    local startStorm, stopStormLoop, stopStorm, rescheduleStorm
    ;(function()
        local TX_BGLOW   = "rbxassetid://78582616787441"
        local TX_BSTREAK = "rbxassetid://102481842205398"
        local BOLT_CORE  = Color3.fromRGB(245, 242, 255)
        local BOLT_GLOW  = Color3.fromRGB(162, 145, 255)
        local BOLT_AFTER = Color3.fromRGB(126, 96, 228)
        local ROT90 = CFrame.Angles(0, math.rad(90), 0)
        local FLICK = 0.12
        local _stormConn, _stormNextT = nil, 0
        local _boltRp = RaycastParams.new()
        _boltRp.FilterType = Enum.RaycastFilterType.Exclude
        local function mkSeg(color, transp, dia, len, cf, parent)
            local p = Instance.new("Part")
            p.Shape = Enum.PartType.Cylinder
            p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
            p.CastShadow = false; p.Massless = true; p.Material = Enum.Material.Neon
            p.Color = color; p.Transparency = transp; p:SetAttribute("WX_Custom", true)
            p.Size = Vec(len, dia, dia); p.CFrame = cf * ROT90; p.Parent = parent
            return p
        end
        local function boltChannel(model, segs, top, bot, n, thick, jitter, layer3)
            local pts = { top }
            local prev = top
            local driftAng = math.random() * 6.283
            for i = 1, n do
                local t = i / n
                local point = top:Lerp(bot, t)
                if i < n then
                    driftAng = driftAng + (math.random() - 0.5) * 2.2
                    local j = jitter * (0.5 + 0.5 * (1 - t))
                    local off = j * (0.3 + math.random() * 0.7)
                    point = point + Vec(math.cos(driftAng) * off, (math.random() - 0.5) * j * 0.25, math.sin(driftAng) * off)
                end
                local len = math.max((point - prev).Magnitude, 0.1)
                local cf = CFrame.lookAt((point + prev) * 0.5, point)
                segs[#segs + 1] = { p = mkSeg(BOLT_CORE, 0.02, thick, len + thick * 1.6, cf, model), on = 0.02, fade = 0.16 }
                segs[#segs + 1] = { p = mkSeg(BOLT_GLOW, 0.78, thick * 5.5, len + thick * 1.8, cf, model), on = 0.78, fade = 0.38 }
                if layer3 then
                    segs[#segs + 1] = { p = mkSeg(BOLT_AFTER, 0.88, thick * 2.2, len + thick * 1.6, cf, model), on = 0.75, fade = 0.85 }
                end
                pts[#pts + 1] = point
                prev = point
            end
            return pts
        end
        local function boltBranch(model, segs, fromPts, groundY, thick, depth)
            local count = 1
            if depth == 1 then count = math.random(2, 4) end
            for _ = 1, count do
                local idx = math.random(math.floor(#fromPts * 0.2), math.floor(#fromPts * 0.7))
                local a = fromPts[math.max(idx, 2)]
                local ang = math.random() * 6.283
                local drop = (a.Y - groundY) * (0.3 + math.random() * 0.25)
                local outw = drop * (0.55 + math.random() * 0.4)
                local endp = a + Vec(math.cos(ang) * outw, -drop, math.sin(ang) * outw)
                local n = 5
                if depth == 1 then n = 8 end
                local blen = (endp - a).Magnitude
                local pts = boltChannel(model, segs, a, endp, n, thick, math.max(5, blen * 0.1) / depth, false)
                if depth < 3 and math.random() < 0.5 then
                    boltBranch(model, segs, pts, groundY, thick * 0.45, depth + 1)
                end
            end
        end
        local function preFlash(pos, scale)
            local host = mkBoltPart(BOLT_CORE, 1, Vec(2, 2, 2), CFrame.new(pos), getLightFolder())
            local e = Instance.new("ParticleEmitter")
            e:SetAttribute("WX_Custom", true)
            e.Texture = TX_BGLOW
            e.Color = ColorSequence.new(Color3.fromRGB(206, 192, 255))
            e.LightEmission = 0.85; e.LightInfluence = 0
            e.Size = NumberSequence.new(60 * scale, 85 * scale)
            e.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.25, 0.55),
                NumberSequenceKeypoint.new(0.7, 0.75), NumberSequenceKeypoint.new(1, 1),
            })
            e.Lifetime = NumberRange.new(0.22, 0.3)
            e.Rate = 0; e.Speed = NumberRange.new(0, 0.5)
            e.Parent = host
            e:Emit(1)
            task.delay(0.09, function() pcall(function() e:Emit(1) end) end)
            Debris:AddItem(host, 1.2)
        end
        local function screenFlash()
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "_wxFlash"; cc:SetAttribute("WX_Custom", true); cc.Brightness = 0.35; cc.Parent = Lighting
            local pulseA = 0.3 + math.random() * 0.25
            local pulseB = -1
            if math.random() < 0.6 then pulseB = pulseA + 0.18 + math.random() * 0.12 end
            local st = tick(); local c2
            c2 = RunService.Heartbeat:Connect(function()
                if not cc.Parent then if c2 then c2:Disconnect() end return end
                local a = (tick() - st) / 0.45
                if a >= 1 then pcall(function() cc:Destroy() end); if c2 then c2:Disconnect() end return end
                local b = 0.35 * (1 - a)
                if a >= pulseA and a < pulseA + 0.14 then
                    b = b + 0.22 * (1 - (a - pulseA) / 0.14)
                elseif pulseB > 0 and a >= pulseB and a < pulseB + 0.14 then
                    b = b + 0.16 * (1 - (a - pulseB) / 0.14)
                end
                cc.Brightness = b
            end)
            Debris:AddItem(cc, 0.7)
        end
        local function igniteBolt(ground, top)
            local model = Instance.new("Model"); model.Name = "_bolt"; model:SetAttribute("WX_Custom", true)
            local segs = {}
            local mainPts = boltChannel(model, segs, top, ground, 18, 1.0, 14, true)
            boltBranch(model, segs, mainPts, ground.Y, 0.55, 1)
            local dome = mkBoltPart(Color3.fromRGB(228, 240, 255), 0.5, Vec(0.6, 5, 5),
                CFrame.new(ground + Vec(0, 0.3, 0)) * CFrame.Angles(0, 0, math.rad(90)), model)
            dome.Shape = Enum.PartType.Cylinder
            local fl = Instance.new("PointLight"); fl.Color = BOLT_GLOW; fl.Range = 150; fl.Brightness = 8; fl.Parent = dome
            TweenService:Create(dome, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = Vec(0.6, 30, 30), Transparency = 1 }):Play()
            TweenService:Create(fl, TweenInfo.new(0.5), { Brightness = 0 }):Play()
            local cb = mkBoltPart(BOLT_CORE, 1, Vec(2, 2, 2), CFrame.new(ground + Vec(0, 1.5, 0)), model)
            local ce = Instance.new("ParticleEmitter")
            ce:SetAttribute("WX_Custom", true)
            ce.Texture = TX_BGLOW
            ce.Color = ColorSequence.new(Color3.fromRGB(235, 228, 255))
            ce.LightEmission = 1; ce.LightInfluence = 0
            ce.Size = NumberSequence.new(13, 17)
            ce.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1),
            })
            ce.Lifetime = NumberRange.new(0.3, 0.4)
            ce.Rate = 0; ce.Speed = NumberRange.new(0, 0.1)
            ce.Parent = cb
            local se = Instance.new("ParticleEmitter")
            se:SetAttribute("WX_Custom", true)
            se.Texture = TX_BSTREAK
            se.Color = ColorSequence.new(Color3.fromRGB(220, 205, 255))
            se.LightEmission = 1; se.LightInfluence = 0
            se.Size = NumberSequence.new(2, 3)
            se.Transparency = NumberSequence.new(0.25, 1)
            se.Lifetime = NumberRange.new(0.5, 0.9)
            se.Rate = 0; se.Speed = NumberRange.new(26, 44)
            se.SpreadAngle = Vector2.new(38, 38)
            se.Orientation = Enum.ParticleOrientation.VelocityParallel
            se.EmissionDirection = Enum.NormalId.Top
            se.Acceleration = Vec(0, -40, 0)
            se.Parent = cb
            ce:Emit(1)
            se:Emit(9)
            model.Parent = getLightFolder()
            preFlash(top + Vec(0, 10, 0), 1.5)
            local flickEnd = FLICK
            local restrikeAt = -1
            if math.random() < 0.3 then restrikeAt = FLICK + 0.08 + math.random() * 0.07 end
            local startT = tick(); local conn
            conn = RunService.Heartbeat:Connect(function()
                if not model.Parent then if conn then conn:Disconnect() end return end
                local a = tick() - startT
                if restrikeAt > 0 and a >= restrikeAt then
                    restrikeAt = -1
                    flickEnd = a + 0.1
                    fl.Brightness = 6
                    TweenService:Create(fl, TweenInfo.new(0.4), { Brightness = 0 }):Play()
                end
                if a < flickEnd then
                    local dim = 0
                    if math.random() < 0.28 then dim = 0.85 end
                    for i = 1, #segs do
                        local s = segs[i]
                        s.p.Transparency = s.on + (1 - s.on) * dim
                    end
                    return
                end
                local f = a - flickEnd
                if f >= 0.85 then
                    if conn then conn:Disconnect() end
                    pcall(function() model:Destroy() end)
                    return
                end
                for i = 1, #segs do
                    local s = segs[i]
                    local k = math.clamp(f / s.fade, 0, 1)
                    s.p.Transparency = s.on + (1 - s.on) * k
                end
            end)
            Debris:AddItem(model, 1.8)
            if cfg("WeatherStormFlash", true) then screenFlash() end
            local tid = cfg("WeatherThunderId", "")
            if tid ~= "" then
                local cam = Camera
                local dist = 120
                if cam then dist = (ground - cam.CFrame.Position).Magnitude end
                task.delay(dist * (3 / 343), function()
                    oneShot(tid, cfg("WeatherSoundVolume", 0.35) * 8 * (0.85 + math.random() * 0.3),
                        0.92 + math.random() * 0.16)
                end)
            end
        end
        local function spawnBolt()
            if not Config.Weather or not cfg("WeatherStorm", false) then return end
            local cam = Camera; if not cam then return end
            local base = cam.CFrame.Position
            local lv = cam.CFrame.LookVector
            local flat = Vec(lv.X, 0, lv.Z)
            if flat.Magnitude < 0.05 then flat = Vec(0, 0, -1) else flat = flat.Unit end
            local right = Vec(flat.Z, 0, -flat.X)
            local fwd  = 55 + math.random() * 95
            local side = (math.random() - 0.5) * 85
            local gx = base.X + flat.X * fwd + right.X * side
            local gz = base.Z + flat.Z * fwd + right.Z * side
            local ground = Vec(gx + (math.random() - 0.5) * 20, base.Y - 45, gz + (math.random() - 0.5) * 20)
            local ch = lp and lp.Character
            if ch then
                _boltRp.FilterDescendantsInstances = { getFolder(), ch }
            else
                _boltRp.FilterDescendantsInstances = { getFolder() }
            end
            local hit = Workspace:Raycast(Vec(gx, base.Y + 140, gz), Vec(0, -400, 0), _boltRp)
            if hit then ground = hit.Position end
            local top = Vec(gx + (math.random() - 0.5) * 90, base.Y + 280, gz + (math.random() - 0.5) * 90)
            preFlash(Vec(top.X, top.Y - 20, top.Z), 1)
            task.delay(0.1 + math.random() * 0.2, function()
                if not Config.Weather or not cfg("WeatherStorm", false) then return end
                pcall(function() igniteBolt(ground, top) end)
            end)
        end
        function startStorm()
            if _stormConn then return end
            _stormNextT = tick() + 2 + math.random() * 3
            _stormConn = RunService.Heartbeat:Connect(function()
                if not Config.Weather or not cfg("WeatherStorm", false) then return end
                local now = tick()
                if now >= _stormNextT then
                    _stormNextT = now + cfg("WeatherStormMin", 4)
                        + math.random() * cfg("WeatherStormVar", 8)
                    pcall(spawnBolt)
                end
            end)
        end
        function rescheduleStorm()
            if not _stormConn then
                return
            end
            local cap = tick() + cfg("WeatherStormMin", 4) + cfg("WeatherStormVar", 8)
            _stormNextT = math.min(_stormNextT, cap)
        end
        function stopStormLoop()
            if _stormConn then _stormConn:Disconnect(); _stormConn = nil end
        end
        function stopStorm()
            stopStormLoop()
            if _lightFolder then pcall(function() _lightFolder:Destroy() end); _lightFolder = nil end
        end
        registerSpectacle("StormBarrage", 1, function()
            if not Config.Weather or not cfg("WeatherStorm", false) then return end
            for i = 0, 2 do
                task.delay(i * (0.35 + math.random() * 0.3), function() pcall(spawnBolt) end)
            end
        end)
    end)()
    local function startFollow()
        if _followConn then return end
        local now0 = tick()
        Wind.reset(now0)
        _spectNextT = now0 + 120 + math.random() * 120
        _followConn = RunService.Heartbeat:Connect(function()
            if not Config.Weather then return end
            local now = tick()
            Wind.update(now)
            local amb = _ambient
            if amb then
                local vol = cfg("WeatherSoundVolume", 0.35)
                if amb.Volume ~= vol then amb.Volume = vol end
            end
            local cam = Camera; if not cam then return end
            local pos = cam.CFrame.Position
            if now >= _spectNextT then
                _spectNextT = now + 120 + math.random() * 120
                if _spectWeight > 0 then
                    local r = math.random() * _spectWeight
                    for i = 1, #_spectacles do
                        local s = _spectacles[i]
                        r = r - s.weight
                        if r <= 0 then
                            pcall(s.fn)
                            break
                        end
                    end
                end
            end
            local wgain = 1
            local bt = (now - _blizzT0) / _blizzDur
            if bt >= 0 and bt < 1 then
                wgain = 1 + 1.7 * math.sin(bt * math.pi)
            end
            local nwx, nwz = 1, 0
            local wl = math.sqrt(Wind.x * Wind.x + Wind.z * Wind.z)
            if wl > 0.05 then
                nwx = Wind.x / wl
                nwz = Wind.z / wl
            end
            for i = 1, #_partLayers do
                local L = _partLayers[i]
                if L.host and L.host.Parent then
                    local hx, hz = pos.X, pos.Z
                    if L.uw then
                        hx = hx - nwx * L.uw
                        hz = hz - nwz * L.uw
                    end
                    local hy = pos.Y + L.oy
                    if L.aim then
                        L.host.CFrame = CFrame.lookAt(Vec(hx, hy, hz), Vec(hx + nwx, hy, hz + nwz))
                    else
                        L.host.CFrame = CFrame.new(hx, hy, hz)
                    end
                    local g = L.gust
                    if g then
                        L.emitter.Acceleration = L.accel + Vec(
                            Wind.x * wgain * L.gax * (1 + 0.3 * math.sin(now * g.wx + g.ph)), 0,
                            Wind.z * wgain * L.gaz * (1 + 0.3 * math.cos(now * g.wz + g.ph)))
                    end
                end
            end
            for i = 1, #_fadeLayers do
                local F = _fadeLayers[i]
                if F.host and F.host.Parent then
                    F.host.CFrame = CFrame.new(pos.X, pos.Y + F.oy, pos.Z)
                end
            end
        end)
    end
    local function stopFollow()
        if _followConn then _followConn:Disconnect(); _followConn = nil end
    end
    do
        local SWELL_UP = TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local SWELL_DOWN = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local function windSwell(kind, dur, rateMul)
            if not Config.Weather or _curType ~= kind then return end
            _blizzT0, _blizzDur = tick(), dur
            local surged = {}
            local I = iAmt()
            for _, L in _partLayers do
                if L.emitter and L.tag ~= "settle" then
                    if L.rateTween then L.rateTween:Cancel() end
                    L.rateMul = rateMul
                    local tw = TweenService:Create(L.emitter, SWELL_UP, { Rate = layerRate(L, I) * rateMul })
                    L.rateTween = tw
                    tw:Play()
                    surged[#surged + 1] = L
                end
            end
            task.delay(dur - 3, function()
                local I2 = iAmt()
                for _, L in surged do
                    local live = false
                    for _, cur in _partLayers do
                        if cur == L then live = true break end
                    end
                    if live and L.emitter and L.emitter.Parent then
                        if L.rateTween then L.rateTween:Cancel() end
                        L.rateMul = 1
                        local tw = TweenService:Create(L.emitter, SWELL_DOWN, { Rate = layerRate(L, I2) })
                        L.rateTween = tw
                        tw:Play()
                    end
                end
            end)
        end
        registerSpectacle("SnowBlizzard", 1, function()
            windSwell("Snow", 11 + math.random() * 3, 1.9)
        end)
        registerSpectacle("SakuraGale", 1, function()
            windSwell("Petals", 9 + math.random() * 4, 1.7)
        end)
    end
    do
        local GUST_UP   = TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local GUST_DOWN = TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local STREAK_BURST = { {0.3, 18}, {0.65, 14}, {1.05, 9} }
        Wind.onGust(function(dur)
            if not Config.Weather or _curType ~= "Autumn" then return end
            local I = iAmt()
            local em = iRate(I, IR.Autumn.lo, IR.Autumn.hi)
            local gm = 1 + 0.4 * I
            local surged = {}
            for _, L in _partLayers do
                if L.emitter and L.tag == "dust" then
                    local e = L.emitter
                    local n2 = math.max(1, math.floor(10 * em + 0.5))
                    e:Emit(math.max(1, math.floor(14 * em + 0.5)))
                    task.delay(0.4, function()
                        if e.Parent then e:Emit(n2) end
                    end)
                elseif L.emitter and L.tag == "streak" then
                    local e = L.emitter
                    e:Emit(math.max(1, math.floor(20 * em + 0.5)))
                    for _, b in STREAK_BURST do
                        local n = math.max(1, math.floor(b[2] * em + 0.5))
                        task.delay(b[1], function()
                            if e.Parent then e:Emit(n) end
                        end)
                    end
                elseif L.emitter and L.tag ~= "settle" then
                    if L.rateTween then L.rateTween:Cancel() end
                    L.rateMul = gm
                    local tw = TweenService:Create(L.emitter, GUST_UP, { Rate = layerRate(L, I) * gm })
                    L.rateTween = tw
                    tw:Play()
                    surged[#surged + 1] = L
                end
            end
            task.delay(dur, function()
                local I2 = iAmt()
                for _, L in surged do
                    local live = false
                    for _, cur in _partLayers do
                        if cur == L then live = true break end
                    end
                    if live and L.emitter and L.emitter.Parent then
                        if L.rateTween then L.rateTween:Cancel() end
                        L.rateMul = 1
                        local tw = TweenService:Create(L.emitter, GUST_DOWN, { Rate = layerRate(L, I2) })
                        L.rateTween = tw
                        tw:Play()
                    end
                end
            end)
        end)
    end
    local function clearSpecial()
        if _specialConn then _specialConn:Disconnect(); _specialConn = nil end
        if _special.moon  then pcall(function() _special.moon:Destroy() end);  _special.moon  = nil end
        if _special.shell then pcall(function() _special.shell:Destroy() end); _special.shell = nil end
        if _special.sky   then pcall(function() _special.sky:Destroy() end);   _special.sky   = nil end
        if _special.cc    then pcall(function() _special.cc:Destroy() end);    _special.cc    = nil end
        if _special.atmo  then pcall(function() _special.atmo:Destroy() end);  _special.atmo  = nil end
        _special.halo = nil
        _special.kind = nil
    end
    local function tuneBloodMoon(I)
        local ms = 0.72 + 0.28 * I
        local gr = 0.5 + 0.5 * I
        if _special.moon then
            _special.moon.Size = Vec(130, 130, 130) * ms
        end
        if _special.shell then
            _special.shell.Size = Vec(160, 160, 160) * ms
        end
        if _special.halo then
            _special.halo.Rate = 25 * iRate(I, 1.45, 1.05)
            _special.halo.Size = NumberSequence.new(330 * ms)
        end
        if _special.cc then
            _special.cc.Saturation = -0.15 * gr
            _special.cc.Brightness = -0.04 * gr
        end
        if _special.atmo then
            _special.atmo.Density = 0.12 + 0.18 * I
            _special.atmo.Haze    = 0.9 + 0.9 * I
            _special.atmo.Glare   = 0.4 + 0.4 * I
        end
        if _special.sky then
            _special.sky.StarCount = math.floor(4000 * (0.55 + 0.45 * I))
        end
    end
    local function buildBloodMoon()
        local folder = getFolder()
        local s = Instance.new("Sky"); s.Name = "_wxSkyBM"; s:SetAttribute("WX_Custom", true)
        s.SkyboxBk = "rbxassetid://159454299"; s.SkyboxDn = "rbxassetid://159454296"
        s.SkyboxFt = "rbxassetid://159454293"; s.SkyboxLf = "rbxassetid://159454286"
        s.SkyboxRt = "rbxassetid://159454300"; s.SkyboxUp = "rbxassetid://159454288"
        s.SunAngularSize = 0; s.MoonAngularSize = 0; s.StarCount = 4000
        s.Parent = Lighting; _special.sky = s
        local moon = Instance.new("Part")
        moon.Shape = Enum.PartType.Ball; moon.Size = Vec(130, 130, 130)
        moon.Material = Enum.Material.Neon; moon.Color = Color3.fromRGB(215, 45, 35)
        moon.Anchored = true; moon.CanCollide = false; moon.CanQuery = false; moon.CanTouch = false
        moon.CastShadow = false; moon.Massless = true; moon:SetAttribute("WX_Custom", true)
        local att = Instance.new("Attachment"); att.Parent = moon
        local halo = Instance.new("ParticleEmitter")
        halo.Texture = TX_SOFT; halo.Color = ColorSequence.new(Color3.fromRGB(255, 60, 42))
        halo.LightEmission = 1; halo.LightInfluence = 0
        halo.Rate = 25; halo.Lifetime = NumberRange.new(0.22, 0.28)
        halo.Speed = NumberRange.new(0, 0); halo.Size = NumberSequence.new(330)
        halo.Transparency = NumberSequence.new(0.72); halo.RotSpeed = NumberRange.new(0, 0)
        halo.Parent = att; _special.halo = halo
        moon.Parent = folder; _special.moon = moon
        local shell = Instance.new("Part")
        shell.Shape = Enum.PartType.Ball; shell.Size = Vec(160, 160, 160)
        shell.Material = Enum.Material.Neon; shell.Color = Color3.fromRGB(255, 60, 45); shell.Transparency = 0.7
        shell.Anchored = true; shell.CanCollide = false; shell.CanQuery = false; shell.CanTouch = false
        shell.CastShadow = false; shell.Massless = true; shell:SetAttribute("WX_Custom", true)
        shell.Parent = folder; _special.shell = shell
        local cc = Instance.new("ColorCorrectionEffect"); cc.Name = "_wxBM"; cc:SetAttribute("WX_Custom", true)
        cc.TintColor = Color3.fromRGB(255, 165, 160); cc.Saturation = -0.15; cc.Brightness = -0.04
        cc.Parent = Lighting; _special.cc = cc
        local at = Instance.new("Atmosphere"); at.Name = "_wxBMAtmo"; at:SetAttribute("WX_Custom", true)
        at.Density = 0.3; at.Color = Color3.fromRGB(125, 35, 35); at.Decay = Color3.fromRGB(190, 55, 50)
        at.Glare = 0.8; at.Haze = 1.8; at.Parent = Lighting; _special.atmo = at
        _special.kind = "BloodMoon"
        tuneBloodMoon(iAmt())
    end
    local function startSpecialAnim()
        if _specialConn then return end
        local accum = 0
        _specialConn = RunService.Heartbeat:Connect(function(dt)
            if not Config.Weather or not _special.kind then return end
            accum = accum + dt
            if accum < 0.1 then return end
            accum = 0
            local cam = Camera; if not cam then return end
            local pos = cam.CFrame.Position
            if _special.kind == "BloodMoon" and _special.moon then
                local cf = CFrame.new(pos + Vec(0.45, 0.62, -0.64).Unit * 700)
                _special.moon.CFrame = cf
                if _special.shell then _special.shell.CFrame = cf end
            end
        end)
    end
    local CSK, NSK = ColorSequenceKeypoint.new, NumberSequenceKeypoint.new
    local TX_MGLOW = "rbxassetid://78582616787441"
    local startMeteors, stopMeteors, rescheduleMeteors
    ;(function()
        local MET_TXS  = "rbxassetid://77935321198144"
        local MET_TXK  = "rbxassetid://102481842205398"
        local MET_TXD  = "rbxassetid://341828512"
        local MET_HAZE = Color3.fromRGB(128, 146, 176)
        local MET_GLOW = {
            { z = -0.80, size = 0.85, tr = 0.03, col = Color3.fromRGB(255, 246, 216), life = 0.09, rate = 34, b0 = 1.35, b1 = 2.1 },
            { z = -0.10, size = 1.75, tr = 0.55, col = Color3.fromRGB(255, 194, 106), life = 0.10, rate = 30, b0 = 0.85, b1 = 1.4 },
            { z =  1.30, size = 3.10, tr = 0.80, col = Color3.fromRGB(255, 124,  46), life = 0.11, rate = 26, b0 = 0.5, b1 = 0.8 },
            { z =  3.20, size = 5.20, tr = 0.92, col = Color3.fromRGB(224,  72,  26), life = 0.12, rate = 22, b0 = 0.4, b1 = 0.6 },
        }
        local MET_ROCK = {
            { 1.00, 0.74, 1.28,  0.00,  0.00,  0.00, 0.25, 0.40, 0.18, 58, 51, 47, 0.00, true },
            { 0.70, 0.60, 0.76,  0.40,  0.20,  0.12, 0.80, 0.50, 1.10, 47, 41, 39, 0.00, true },
            { 0.58, 0.48, 0.64, -0.38, -0.26,  0.34, 1.20, 0.90, 0.30, 36, 31, 30, 0.00, true },
            { 0.46, 0.40, 0.52,  0.06, -0.42, -0.24, 0.40, 1.30, 0.70, 52, 45, 42, 0.00, true },
            { 0.36, 0.30, 0.40, -0.32,  0.36, -0.08, 0.90, 0.20, 1.40, 42, 36, 34, 0.00, true },
            { 0.30, 0.26, 0.34,  0.22, -0.10,  0.46, 1.50, 0.70, 0.20, 38, 33, 32, 0.00, true },
            { 0.26, 0.34, 0.22, -0.20, -0.34, -0.02, 0.60, 1.10, 0.90, 33, 29, 28, 0.00, true },
            { 0.52, 0.40, 0.16,  0.10,  0.06, -0.56, 0.00, 0.00, 0.50, 255, 244, 214, 0.10, false },
            { 0.30, 0.46, 0.14, -0.30, -0.14, -0.44, 0.00, 0.00, -0.90, 255, 190, 104, 0.28, false },
            { 0.34, 0.20, 0.12,  0.16, -0.34, -0.40, 0.00, 0.00, 0.20, 255, 158,  66, 0.36, false },
            { 0.22, 0.16, 0.10, -0.10,  0.34, -0.38, 0.00, 0.00, 1.20, 255, 214, 150, 0.30, false },
        }
        local MET_ABL0 = 8
        local MET_ABLA = { 0.06, 0.20, 0.26, 0.22 }
        local MET_ABLK = { 0.20, 0.24, 0.26, 0.26 }
        local MET_UP, MET_DOWN = Vec(0, 300, 0), Vec(0, -800, 0)
        local _metConn = nil
        local _metNextFar, _metNextNear = 0, 0
        local _metFar, _metNear = 0, 0
        local _metLive = {}
        local _metRp = RaycastParams.new()
        _metRp.FilterType = Enum.RaycastFilterType.Exclude
        local function hz(c, k)
            return c:Lerp(MET_HAZE, k)
        end
        local function metPart(sx, sy, sz, cf)
            local p = Instance.new("Part")
            p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
            p.CastShadow = false; p.Massless = true
            p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
            p.Size = Vec(sx, sy, sz); p.CFrame = cf
            p:SetAttribute("WX_Custom", true)
            p.Parent = getLightFolder()
            return p
        end
        local function metFilter()
            local ch = nil
            if lp then ch = lp.Character end
            if ch then
                _metRp.FilterDescendantsInstances = { getFolder(), ch }
            else
                _metRp.FilterDescendantsInstances = { getFolder() }
            end
        end
        local function metSolveLand(base, out, tang)
            local d = 90 + math.random() * 110
            local lat = (math.random() - 0.5) * 160
            for _ = 1, 2 do
                local c = base + out * d + tang * lat
                local h = Workspace:Raycast(c + MET_UP, MET_DOWN, _metRp)
                if h then
                    return h.Position + Vec(0, 1.5, 0)
                end
                d = d * 0.5
                lat = lat * 0.5
            end
            return nil
        end
        local function metGlow(host, size, transp, color, life, rate)
            local g = Instance.new("ParticleEmitter")
            g:SetAttribute("WX_Custom", true)
            g.Texture = TX_MGLOW; g.Color = ColorSequence.new(color)
            g.LightEmission = 1; g.LightInfluence = 0
            g.Rate = rate; g.Lifetime = NumberRange.new(life, life)
            g.Size = NumberSequence.new(size); g.Transparency = NumberSequence.new(transp)
            g.Speed = NumberRange.new(0, 0); g.LockedToPart = true
            g.Parent = host
            return g
        end
        local function metRibbon(part, sep, c0, c1, a0, w1, life, emit, inf)
            local aT = Instance.new("Attachment"); aT.Position = Vec(0, sep * 0.5, 0); aT.Parent = part
            local aB = Instance.new("Attachment"); aB.Position = Vec(0, -sep * 0.5, 0); aB.Parent = part
            local tr = Instance.new("Trail")
            tr:SetAttribute("WX_Custom", true)
            tr.Attachment0 = aT; tr.Attachment1 = aB; tr.FaceCamera = true
            tr.Texture = TX_MGLOW; tr.TextureMode = Enum.TextureMode.Stretch; tr.TextureLength = 1
            tr.Color = ColorSequence.new(c0, c1)
            tr.Transparency = NumberSequence.new({ NSK(0, a0), NSK(0.6, a0 + (1 - a0) * 0.45), NSK(1, 1) })
            tr.WidthScale = NumberSequence.new({ NSK(0, 1), NSK(1, w1) })
            tr.Lifetime = life; tr.LightEmission = emit; tr.LightInfluence = inf
            tr.MinLength = 0.05
            tr.Parent = part
            return { t = tr, a = aT, b = aB, sep = sep }
        end
        local function metSmoke(host, sb, lo, hi, rate, aBase, drift, spread, k)
            local e = Instance.new("ParticleEmitter")
            e:SetAttribute("WX_Custom", true)
            e.Texture = MET_TXS
            e.Color = ColorSequence.new({
                CSK(0,   hz(Color3.fromRGB(178, 164, 152), k * 0.5)),
                CSK(0.2, hz(Color3.fromRGB(146, 142, 138), k * 0.5)),
                CSK(1,   hz(Color3.fromRGB(84, 82, 80), k * 0.5)) })
            e.LightEmission = 0.02; e.LightInfluence = 0.6
            e.Rate = rate; e.Lifetime = NumberRange.new(lo, hi)
            e.Size = NumberSequence.new({ NSK(0, sb), NSK(0.35, sb * 1.9), NSK(1, sb * 3) })
            e.Transparency = NumberSequence.new({
                NSK(0, 0.94), NSK(0.07, aBase + 0.16 * k), NSK(0.62, aBase + 0.16), NSK(1, 1) })
            e.Speed = NumberRange.new(0, spread); e.SpreadAngle = Vector2.new(60, 60)
            e.Drag = 0.5
            e.RotSpeed = NumberRange.new(-8, 8); e.Rotation = NumberRange.new(0, 360)
            e.Acceleration = Vec(Wind.x * drift, 0.35, Wind.z * drift)
            e.Parent = host
            return e
        end
        local function bez(p0, p1, p2, a)
            return p0:Lerp(p1, a):Lerp(p1:Lerp(p2, a), a)
        end
        local function metImpact(pos, sc)
            if Camera then
                sc = math.min(sc, math.max(0.85, (pos - Camera.CFrame.Position).Magnitude / 44))
            end
            local host = metPart(4 * sc, 4 * sc, 4 * sc, CFrame.new(pos))
            host.Shape = Enum.PartType.Ball; host.Material = Enum.Material.Neon
            host.Color = Color3.fromRGB(255, 240, 202); host.Transparency = 0.05
            local fl = Instance.new("PointLight")
            fl.Color = Color3.fromRGB(255, 176, 90); fl.Range = 150; fl.Brightness = 9; fl.Parent = host
            local glow = metPart(2, 2, 2, CFrame.new(pos + Vec(0, 3, 0)))
            glow.Transparency = 1
            local gl = Instance.new("PointLight")
            gl.Color = Color3.fromRGB(255, 148, 68); gl.Range = 120 * sc; gl.Brightness = 4; gl.Parent = glow
            local ring = metPart(12 * sc, 2 * sc, 12 * sc, CFrame.new(pos))
            ring.Shape = Enum.PartType.Ball; ring.Material = Enum.Material.Neon
            ring.Color = Color3.fromRGB(255, 150, 60); ring.Transparency = 0.35
            local scorch = metPart(15 * sc, 0.6, 15 * sc, CFrame.new(pos - Vec(0, 0.4, 0)))
            scorch.Shape = Enum.PartType.Ball; scorch.Material = Enum.Material.Neon
            scorch.Color = Color3.fromRGB(255, 104, 24); scorch.Transparency = 0.2
            local att = Instance.new("Attachment"); att.Parent = host
            local datt = Instance.new("Attachment"); datt.Orientation = Vec(0, 0, -90); datt.Parent = host
            local flash = Instance.new("ParticleEmitter")
            flash:SetAttribute("WX_Custom", true)
            flash.Texture = TX_MGLOW; flash.Rate = 0
            flash.Color = ColorSequence.new({
                CSK(0,    Color3.fromRGB(255, 246, 214)),
                CSK(0.45, Color3.fromRGB(255, 186, 96)),
                CSK(1,    Color3.fromRGB(226, 96, 34)) })
            flash.LightEmission = 1; flash.LightInfluence = 0
            flash.Lifetime = NumberRange.new(0.30, 0.30)
            flash.Size = NumberSequence.new({ NSK(0, 14 * sc), NSK(0.35, 34 * sc), NSK(1, 44 * sc) })
            flash.Transparency = NumberSequence.new({ NSK(0, 0.05), NSK(0.45, 0.42), NSK(1, 1) })
            flash.Speed = NumberRange.new(0, 0); flash.Rotation = NumberRange.new(0, 360)
            flash.Parent = att
            flash:Emit(2)
            local dust = Instance.new("ParticleEmitter")
            dust:SetAttribute("WX_Custom", true)
            dust.Texture = MET_TXD; dust.Rate = 0
            dust.Color = ColorSequence.new(Color3.fromRGB(198, 178, 152), Color3.fromRGB(120, 112, 104))
            dust.LightEmission = 0.05; dust.LightInfluence = 0.5
            dust.Lifetime = NumberRange.new(5.5, 9)
            dust.Size = NumberSequence.new({ NSK(0, 6 * sc), NSK(1, 22 * sc) })
            dust.Transparency = NumberSequence.new({ NSK(0, 0.6), NSK(0.1, 0.42), NSK(0.6, 0.68), NSK(1, 1) })
            dust.Speed = NumberRange.new(22, 38); dust.SpreadAngle = Vector2.new(0, 180)
            dust.Drag = 1.9; dust.EmissionDirection = ND.Top
            dust.RotSpeed = NumberRange.new(-16, 16); dust.Rotation = NumberRange.new(0, 360)
            dust.Acceleration = Vec(Wind.x * 6, 0.4, Wind.z * 6)
            dust.Parent = datt
            dust:Emit(math.floor(24 * sc))
            local fount = Instance.new("ParticleEmitter")
            fount:SetAttribute("WX_Custom", true)
            fount.Texture = MET_TXK; fount.Rate = 0
            fount.Color = ColorSequence.new(Color3.fromRGB(255, 200, 110), Color3.fromRGB(196, 52, 14))
            fount.LightEmission = 1; fount.LightInfluence = 0
            fount.Lifetime = NumberRange.new(1.1, 2.2)
            fount.Size = NumberSequence.new({ NSK(0, 1.7 * sc), NSK(1, 0.08) })
            fount.Transparency = NumberSequence.new({ NSK(0, 0), NSK(0.7, 0.35), NSK(1, 1) })
            fount.Orientation = Enum.ParticleOrientation.VelocityParallel
            fount.Speed = NumberRange.new(48, 96); fount.SpreadAngle = Vector2.new(30, 30)
            fount.Acceleration = Vec(0, -74, 0); fount.Drag = 0.35
            fount.EmissionDirection = ND.Top; fount.Parent = att
            fount:Emit(math.floor(52 * sc))
            local col = Instance.new("ParticleEmitter")
            col:SetAttribute("WX_Custom", true)
            col.Texture = TX_MGLOW; col.Rate = 0
            col.Color = ColorSequence.new({
                CSK(0,    Color3.fromRGB(255, 236, 180)),
                CSK(0.35, Color3.fromRGB(255, 130, 40)),
                CSK(1,    Color3.fromRGB(122, 40, 18)) })
            col.LightEmission = 0.9; col.LightInfluence = 0
            col.Lifetime = NumberRange.new(0.55, 1.05)
            col.Size = NumberSequence.new({ NSK(0, 5 * sc), NSK(1, 14 * sc) })
            col.Transparency = NumberSequence.new({ NSK(0, 0.12), NSK(0.6, 0.55), NSK(1, 1) })
            col.Speed = NumberRange.new(32, 62); col.SpreadAngle = Vector2.new(10, 10)
            col.EmissionDirection = ND.Top; col.Parent = att
            col:Emit(18)
            local pil = Instance.new("ParticleEmitter")
            pil:SetAttribute("WX_Custom", true)
            pil.Texture = MET_TXS; pil.Rate = 0
            pil.Color = ColorSequence.new({
                CSK(0,   Color3.fromRGB(186, 150, 118)),
                CSK(0.3, Color3.fromRGB(146, 140, 132)),
                CSK(1,   Color3.fromRGB(88, 85, 82)) })
            pil.LightEmission = 0.02; pil.LightInfluence = 0.5
            pil.Lifetime = NumberRange.new(4.5, 8)
            pil.Size = NumberSequence.new({ NSK(0, 4.5 * sc), NSK(1, 20 * sc) })
            pil.Transparency = NumberSequence.new({ NSK(0, 0.52), NSK(0.5, 0.68), NSK(1, 1) })
            pil.Speed = NumberRange.new(16, 30); pil.SpreadAngle = Vector2.new(9, 9)
            pil.Acceleration = Vec(Wind.x * 7, 2.6, Wind.z * 7); pil.Drag = 0.6
            pil.EmissionDirection = ND.Top
            pil.RotSpeed = NumberRange.new(-12, 12); pil.Rotation = NumberRange.new(0, 360)
            pil.Parent = att
            task.delay(0.12, function() if pil.Parent then pil:Emit(7) end end)
            task.delay(0.62, function() if pil.Parent then pil:Emit(5) end end)
            task.delay(1.30, function() if pil.Parent then pil:Emit(4) end end)
            local t0 = tick()
            local conn
            conn = RunService.Heartbeat:Connect(function()
                if not host.Parent then
                    conn:Disconnect()
                    return
                end
                local k = tick() - t0
                local f1 = math.clamp(k / 0.10, 0, 1)
                host.Size = Vec(1, 1, 1) * (4 + 6 * f1) * sc
                host.Transparency = 0.05 + 0.95 * f1
                fl.Brightness = 9 * (1 - math.clamp(k / 0.55, 0, 1))
                gl.Brightness = 4 * (1 - math.clamp(k / 5, 0, 1))
                local f2 = math.clamp(k / 0.55, 0, 1)
                ring.Size = Vec(12 + 52 * f2, 2 - 1.2 * f2, 12 + 52 * f2) * sc
                ring.Transparency = 0.35 + 0.65 * f2
                scorch.Transparency = 0.2 + 0.8 * math.clamp(k / 7, 0, 1)
                if k > 7.2 then
                    conn:Disconnect()
                end
            end)
            Debris:AddItem(ring, 1.1)
            Debris:AddItem(glow, 5.2)
            Debris:AddItem(scorch, 7.5)
            Debris:AddItem(host, 11)
        end
        local function launch(far, opts)
            local ang = math.random() * 6.28318
            local mul = 1
            local big = false
            if opts then
                if opts.ang then ang = opts.ang end
                if opts.scaleMul then mul = opts.scaleMul end
                big = opts.big == true
            end
            local tang = Vec(-math.sin(ang), 0, math.cos(ang))
            local out = Vec(math.cos(ang), 0, math.sin(ang))
            local sgn = 1
            if math.random() < 0.5 then sgn = -1 end
            local base = Camera.CFrame.Position
            local startP, endP, spd, rs, ws, k, doImpact, smk
            if far then
                local ctr = base + out * (1400 + math.random() * 1200)
                          + Vec(0, 820 + math.random() * 360, 0)
                local travel = 3000 + math.random() * 900
                local drop = 320 + math.random() * 200
                startP = ctr - tang * (travel * 0.5 * sgn) + Vec(0, drop * 0.5, 0)
                endP = ctr + tang * (travel * 0.5 * sgn) - Vec(0, drop * 0.5, 0)
                spd = 255 + math.random() * 70
                rs = 14 + math.random() * 5
                ws = 3.9 + math.random()
                k = 0.14 + math.random() * 0.10
                doImpact = false
                smk = 1.6
            else
                metFilter()
                local land = nil
                if opts and opts.land then
                    local h = Workspace:Raycast(opts.land + MET_UP, MET_DOWN, _metRp)
                    if h then land = h.Position + Vec(0, 1.5, 0) end
                end
                if not land then land = metSolveLand(base, out, tang) end
                doImpact = land ~= nil
                if not land then
                    land = base + out * 150 + Vec(0, 40, 0)
                end
                local travel = 1750 + math.random() * 450
                startP = land - tang * (travel * sgn) + out * (190 + math.random() * 190)
                         + Vec(0, 640 + math.random() * 160, 0)
                if opts and opts.start then startP = opts.start end
                endP = land
                spd = 175 + math.random() * 38
                rs = (7.0 + math.random() * 2.6) * mul
                ws = (1.3 + math.random() * 0.28) * mul
                k = 0
                smk = 1
            end
            if big then
                rs = rs * 1.7
                ws = ws * 1.5
                spd = spd * 0.92
            end
            local flare = far or (not doImpact)
            local splitAt = nil
            if big and not (opts and opts.noSplit) then
                splitAt = 0.42 + math.random() * 0.12
            end
            local mid = startP:Lerp(endP, 0.5) + Vec(0, (endP - startP).Magnitude * 0.075, 0)
            local dur = ((startP - mid).Magnitude + (mid - endP).Magnitude) / spd
            local cf0 = CFrame.lookAt(startP, endP)
            local root = metPart(0.2, 0.2, 0.2, cf0)
            root.Transparency = 1
            local a0 = Instance.new("Attachment"); a0.Parent = root
            local glows = table.create(4)
            for i, s in MET_GLOW do
                local hp = metPart(0.2, 0.2, 0.2, cf0)
                hp.Transparency = 1
                glows[i] = { p = hp, z = s.z * rs, b0 = s.b0, b1 = s.b1,
                    e = metGlow(hp, s.size * rs, math.min(0.97, s.tr + 0.18 * k),
                        hz(s.col, k * 0.55), s.life, s.rate) }
            end
            local chunks = table.create(#MET_ROCK)
            for i, r in MET_ROCK do
                local p = metPart(r[1] * rs, r[2] * rs, r[3] * rs, cf0)
                p.Transparency = r[13]
                if r[14] then
                    p.Material = Enum.Material.Slate
                    p.Color = Color3.fromRGB(r[10], r[11], r[12])
                else
                    p.Material = Enum.Material.Neon
                    p.Color = hz(Color3.fromRGB(r[10], r[11], r[12]), k * 0.4)
                end
                chunks[i] = { p = p, tumble = r[14],
                    off = CFrame.new(r[4] * rs, r[5] * rs, r[6] * rs) * CFrame.Angles(r[7], r[8], r[9]) }
            end
            local noseLight, bodyLight = nil, nil
            if not far then
                noseLight = Instance.new("PointLight")
                noseLight.Color = Color3.fromRGB(255, 186, 108)
                noseLight.Range = 4.2 * rs; noseLight.Brightness = 11
                noseLight.Parent = glows[1].p
                bodyLight = Instance.new("PointLight")
                bodyLight.Color = Color3.fromRGB(255, 150, 70)
                bodyLight.Range = 16 * rs; bodyLight.Brightness = 3
                bodyLight.Parent = root
            end
            local ha = 0.20 * k
            local ribbons = {
                metRibbon(root, 7.5 * ws, hz(Color3.fromRGB(255, 253, 248), k * 0.3),
                    hz(Color3.fromRGB(255, 226, 156), k * 0.6), ha, 0.45, 0.26, 1, 0),
                metRibbon(root, 14 * ws, hz(Color3.fromRGB(255, 222, 146), k * 0.5),
                    hz(Color3.fromRGB(255, 136, 40), k * 0.9), 0.06 + ha, 0.36, 0.72, 1, 0),
                metRibbon(root, 23 * ws, hz(Color3.fromRGB(255, 138, 42), k * 0.9),
                    hz(Color3.fromRGB(196, 50, 14), k), 0.22 + ha, 0.28, 1.85, 1, 0),
                metRibbon(root, 33 * ws, hz(Color3.fromRGB(196, 62, 18), k),
                    hz(Color3.fromRGB(88, 26, 14), k), 0.52 + ha, 0.30, 3.20, 0.55, 0.12),
            }
            local trainRate = math.clamp(spd / (17 * ws * 0.30 * smk), 6, 30)
            local train = metSmoke(a0, 17 * ws, 5, 7.5, trainRate, 0.56, 5.6, 3, k)
            local scarRate = math.clamp(spd / (50 * ws * 0.28 * smk), 1.6, 9)
            local scar = metSmoke(a0, 50 * ws, 20, 32, scarRate, 0.74, 7.8, 7, k)
            local sparks = nil
            if not far then
                sparks = Instance.new("ParticleEmitter")
                sparks:SetAttribute("WX_Custom", true)
                sparks.Texture = MET_TXK
                sparks.Color = ColorSequence.new(Color3.fromRGB(255, 172, 70), Color3.fromRGB(186, 44, 12))
                sparks.LightEmission = 1; sparks.LightInfluence = 0
                sparks.Rate = 60; sparks.Lifetime = NumberRange.new(0.6, 1.5)
                sparks.Size = NumberSequence.new({ NSK(0, 2.2 * ws), NSK(1, 0.06) })
                sparks.Transparency = NumberSequence.new({ NSK(0, 0.08), NSK(1, 1) })
                sparks.Orientation = Enum.ParticleOrientation.VelocityParallel
                sparks.Speed = NumberRange.new(6, 20); sparks.SpreadAngle = Vector2.new(32, 32)
                sparks.Acceleration = Vec(0, -12, 0); sparks.Drag = 0.6
                sparks.Parent = a0
            end
            if far then _metFar = _metFar + 1 else _metNear = _metNear + 1 end
            local rec = { root = root }
            _metLive[#_metLive + 1] = rec
            local t0 = tick()
            local ph = math.random() * 20
            local spinX, spinY, spinZ = (math.random() - 0.5) * 3, (math.random() - 0.5) * 3.4,
                0.6 + math.random() * 1.6
            local flareAt = 0.76 + math.random() * 0.10
            local shedAt = 0.25 + math.random() * 0.2
            local dead, endT = false, nil
            local conn
            local function retire()
                if dead then
                    return
                end
                dead = true
                if far then
                    _metFar = math.max(0, _metFar - 1)
                else
                    _metNear = math.max(0, _metNear - 1)
                end
                for i = #_metLive, 1, -1 do
                    if _metLive[i] == rec then table.remove(_metLive, i) end
                end
            end
            conn = RunService.Heartbeat:Connect(function()
                if not root.Parent then
                    conn:Disconnect()
                    retire()
                    return
                end
                local now = tick()
                local a = math.clamp((now - t0) / dur, 0, 1)
                local p = bez(startP, mid, endP, a)
                local d = (mid - startP) * (2 * (1 - a)) + (endP - mid) * (2 * a)
                if d.Magnitude < 1e-3 then d = endP - startP end
                local cf = CFrame.lookAt(p, p + d)
                local n = math.clamp(0.5 + 0.27 * math.sin(now * 41 + ph)
                    + 0.17 * math.sin(now * 67.3 + ph * 2.1)
                    + 0.09 * math.sin(now * 103.7 + ph * 0.7), 0, 1)
                local burn = 1
                if flare and a > flareAt then
                    local u = (a - flareAt) / (1 - flareAt)
                    burn = math.clamp((1 + 1.7 * math.exp(-((u - 0.14) ^ 2) / 0.011))
                        * (1 - u) ^ 1.5, 0, 3)
                end
                if endT then burn = burn * math.clamp(1 - (now - endT) / 0.4, 0, 1) end
                local bw = math.clamp(burn, 0, 1)
                if not endT then
                    root.CFrame = cf
                    for _, g in glows do
                        g.p.CFrame = cf * CFrame.new(0, 0, g.z)
                    end
                    local tum = CFrame.Angles(now * spinX, now * spinY, now * spinZ)
                    for _, c in chunks do
                        if c.tumble then
                            c.p.CFrame = cf * tum * c.off
                        else
                            c.p.CFrame = cf * c.off
                        end
                    end
                end
                for _, g in glows do
                    g.e.Brightness = (g.b0 + g.b1 * n) * burn
                end
                for i = 1, 4 do
                    local c = chunks[MET_ABL0 + i - 1]
                    c.p.Transparency = math.clamp(1 - (1 - (MET_ABLA[i] + MET_ABLK[i] * (1 - n))) * bw, 0, 1)
                end
                if noseLight then
                    noseLight.Brightness = (7 + 9 * n) * bw
                    bodyLight.Brightness = (2 + 3 * n) * bw
                end
                train.Rate = trainRate * bw
                scar.Rate = scarRate * bw
                if sparks then sparks.Rate = 60 * bw * (0.6 + 0.8 * n) end
                local pinch = (0.5 + 0.5 * bw) * (0.9 + 0.2 * n)
                for _, L in ribbons do
                    local h = L.sep * 0.5 * pinch
                    L.a.Position = Vec(0, h, 0)
                    L.b.Position = Vec(0, -h, 0)
                end
                if splitAt and a >= splitAt then
                    splitAt = nil
                    if sparks then sparks:Emit(30) end
                    for _ = 1, math.random(2, 3) do
                        launch(false, {
                            ang = ang,
                            noSplit = true,
                            scaleMul = 0.40 + math.random() * 0.14,
                            start = p + Vec((math.random() - 0.5) * 30, (math.random() - 0.5) * 20,
                                (math.random() - 0.5) * 30),
                            land = endP + Vec((math.random() - 0.5) * 110, 0, (math.random() - 0.5) * 110),
                        })
                    end
                end
                if (not far) and a > shedAt then
                    shedAt = 2
                    local fp = metPart(0.3 * rs, 0.24 * rs, 0.38 * rs, CFrame.new(p))
                    fp.Material = Enum.Material.Slate
                    fp.Color = Color3.fromRGB(40, 35, 33)
                    metRibbon(fp, 6, Color3.fromRGB(255, 220, 160), Color3.fromRGB(150, 34, 12),
                        0.12, 0.2, 0.8, 1, 0)
                    local fdir = (d.Unit * 0.65
                        + Vec(math.random() - 0.5, -0.5, math.random() - 0.5).Unit * 0.5).Unit
                    local fv, ft0 = fdir * spd * 0.6, tick()
                    local fc
                    fc = RunService.Heartbeat:Connect(function()
                        if not fp.Parent then
                            fc:Disconnect()
                            return
                        end
                        local age = tick() - ft0
                        if age > 2.4 then
                            fc:Disconnect()
                            fp:Destroy()
                            return
                        end
                        fv = fv + Vec(0, -0.88, 0)
                        fp.CFrame = CFrame.new(fp.Position + fv * 0.016)
                            * CFrame.Angles(age * 5, age * 3, age * 4)
                    end)
                end
                if not endT then
                    if a >= 1 then
                        endT = now
                        if doImpact then
                            metImpact(endP, rs * 0.215 + 0.6)
                            local tid = cfg("WeatherThunderId", "")
                            if tid ~= "" then
                                task.delay(0.15, function()
                                    oneShot(tid, cfg("WeatherSoundVolume", 0.35) * 6)
                                end)
                            end
                        end
                    elseif flare and burn < 0.02 and a > flareAt then
                        endT = now
                    end
                elseif now - endT >= 0.4 then
                    retire()
                    conn:Disconnect()
                    train.Enabled = false; scar.Enabled = false
                    if sparks then sparks.Enabled = false end
                    for _, g in glows do
                        g.e.Enabled = false
                        g.p:Destroy()
                    end
                    for _, L in ribbons do L.t.Enabled = false end
                    for _, c in chunks do c.p:Destroy() end
                    if noseLight then noseLight:Destroy(); bodyLight:Destroy() end
                    Debris:AddItem(root, 42)
                end
            end)
            Debris:AddItem(root, dur + 46)
        end
        local function spawnMeteor(far, opts)
            if not Config.Weather or not cfg("WeatherMeteors", false) then
                return
            end
            local r = evRate("WeatherMeteorRate")
            local capped
            if far then
                capped = _metFar >= math.clamp(math.floor(1 + 1.5 * r), 1, 4)
            elseif r >= 2.5 then
                capped = _metNear >= 3
            elseif r >= 1.5 then
                capped = _metNear >= 2
            else
                capped = _metNear >= 1
            end
            if capped then
                return
            end
            launch(far, opts)
        end
        startMeteors = function()
            if _metConn then
                return
            end
            local t = tick()
            _metNextFar = t + 1 + math.random() * 2
            _metNextNear = t + 5 + math.random() * 6
            _metConn = RunService.Heartbeat:Connect(function()
                if not Config.Weather or not cfg("WeatherMeteors", false) then
                    return
                end
                local now = tick()
                local r = evRate("WeatherMeteorRate")
                if now >= _metNextFar then
                    _metNextFar = now + (6 + math.random() * 5) / r
                    pcall(spawnMeteor, true)
                end
                if now >= _metNextNear then
                    _metNextNear = now + (14 + math.random() * 10) / r
                    pcall(spawnMeteor, false)
                end
            end)
        end
        rescheduleMeteors = function()
            if not _metConn then
                return
            end
            local now, r = tick(), evRate("WeatherMeteorRate")
            _metNextFar = math.min(_metNextFar, now + 11 / r)
            _metNextNear = math.min(_metNextNear, now + 24 / r)
        end
        stopMeteors = function()
            if _metConn then _metConn:Disconnect(); _metConn = nil end
            for _, rec in _metLive do
                pcall(function() rec.root:Destroy() end)
            end
            table.clear(_metLive)
        end
        registerSpectacle("MeteorBigOne", 1, function()
            if not Config.Weather or not cfg("WeatherMeteors", false) then
                return
            end
            launch(false, { big = true })
        end)
    end)()
    local startStars, stopStars, rescheduleStars
    ;(function()
        local TX_SGLOW = "rbxassetid://78582616787441"
        local TX_STAR4 = "rbxassetid://17726943419"
        local GLINT_C  = Color3.fromRGB(246, 250, 255)
        local MIN_SIN  = 0.3
        local FLOOR_H  = 60
        local PAL = {
            { WHITE, Color3.fromRGB(222, 234, 255), Color3.fromRGB(150, 184, 240) },
            { Color3.fromRGB(242, 250, 255), Color3.fromRGB(160, 206, 255), Color3.fromRGB(78, 138, 255) },
            { Color3.fromRGB(255, 246, 220), Color3.fromRGB(255, 205, 122), Color3.fromRGB(222, 140, 44) },
        }
        local CLS = {
            { 80, 55, 250, 105, 50, 28, 3.6 },
            { 145, 90, 158, 62, 76, 44, 5.4 },
            { 240, 150, 98, 46, 118, 62, 7.2 },
        }
        local TR_TRANSP  = NumberSequence.new({ NSK(0, 0.04), NSK(0.12, 0.12), NSK(0.45, 0.55), NSK(1, 1) })
        local TR_WIDTH   = NumberSequence.new({ NSK(0, 0.4), NSK(0.08, 1), NSK(1, 0.02) })
        local ION_TRANSP = NumberSequence.new({ NSK(0, 0.86), NSK(0.3, 0.9), NSK(1, 1) })
        local ION_WIDTH  = NumberSequence.new({ NSK(0, 0.5), NSK(0.25, 1), NSK(1, 0.35) })
        local HEAD_TR    = NumberSequence.new({ NSK(0, 1), NSK(0.05, 0), NSK(0.72, 0.06), NSK(1, 1) })
        local HALO_TR    = NumberSequence.new({ NSK(0, 1), NSK(0.07, 0.82), NSK(0.7, 0.88), NSK(1, 1) })
        local GLINT_TR   = NumberSequence.new({ NSK(0, 1), NSK(0.3, 0.12), NSK(0.55, 0.42), NSK(1, 1) })
        local _starConn, _starNextT = nil, 0
        local _starLive = {}
        local function mkSprite(parent, tex, col, sizeSeq, transpSeq, life, emit)
            local e = Instance.new("ParticleEmitter")
            e.Texture = tex
            e.Color = ColorSequence.new(col)
            e.Size = sizeSeq
            e.Transparency = transpSeq
            e.Lifetime = NumberRange.new(life)
            e.Rate = 0
            e.Speed = NumberRange.new(0, 0)
            e.SpreadAngle = Vector2.new(0, 0)
            e.LightEmission = emit
            e.LightInfluence = 0
            e.Drag = 0
            e.Parent = parent
            return e
        end
        local function spawnStreak(start, dir, ci, pi, floorY)
            if not Config.Weather or not cfg("WeatherShootingStars", false) then
                return
            end
            if #_starLive >= math.clamp(math.floor(4 + 2 * evRate("WeatherStarRate")), 4, 8) then
                return
            end
            local cls, pal = CLS[ci], PAL[pi]
            local dist = cls[1] + math.random() * cls[2]
            local spd  = cls[3] + math.random() * cls[4]
            local tail = cls[5] + math.random() * cls[6]
            if start.Y + dir.Y * dist < floorY then
                local ny = (floorY - start.Y) / dist
                local hl = math.sqrt(dir.X * dir.X + dir.Z * dir.Z)
                if hl > 1e-4 then
                    local k = math.sqrt(math.max(0, 1 - ny * ny)) / hl
                    dir = Vec(dir.X * k, ny, dir.Z * k)
                end
            end
            local dur  = dist / spd
            local life = math.min(tail / spd, dur * 0.9)
            local sep  = cls[7] * (0.85 + math.random() * 0.3)
            local glintD = 0.3 + math.random() * 0.3
            local cf0 = CFrame.lookAt(start, start + dir)
            local host = mkBoltPart(WHITE, 1, Vec(0.2, 0.2, 0.2), cf0, getLightFolder())
            local aT = Instance.new("Attachment"); aT.Position = Vec(0, sep * 0.5, 0); aT.Parent = host
            local aB = Instance.new("Attachment"); aB.Position = Vec(0, -sep * 0.5, 0); aB.Parent = host
            local tr = Instance.new("Trail")
            tr.Attachment0 = aT; tr.Attachment1 = aB
            tr.FaceCamera = true
            tr.Texture = TX_SGLOW; tr.TextureMode = Enum.TextureMode.Stretch; tr.TextureLength = 1
            tr.Color = ColorSequence.new({ CSK(0, pal[1]), CSK(0.24, pal[2]), CSK(1, pal[3]) })
            tr.Transparency = TR_TRANSP; tr.WidthScale = TR_WIDTH
            tr.Lifetime = life; tr.LightEmission = 1; tr.LightInfluence = 0
            tr.MinLength = 0.08; tr.Enabled = false
            tr.Parent = host
            local ion = nil
            if ci == 3 then
                ion = Instance.new("Trail")
                ion.Attachment0 = aT; ion.Attachment1 = aB
                ion.FaceCamera = true
                ion.Texture = TX_SGLOW; ion.TextureMode = Enum.TextureMode.Stretch; ion.TextureLength = 1
                ion.Color = ColorSequence.new({ CSK(0, pal[2]), CSK(1, pal[3]) })
                ion.Transparency = ION_TRANSP; ion.WidthScale = ION_WIDTH
                ion.Lifetime = life * 2.6; ion.LightEmission = 0.85; ion.LightInfluence = 0
                ion.MinLength = 0.1; ion.Enabled = false
                ion.Parent = host
            end
            local hub = Instance.new("Attachment"); hub.Parent = host
            local coreS = sep * 0.62
            local core = mkSprite(hub, TX_SGLOW, pal[1], NumberSequence.new({
                NSK(0, coreS * 0.55), NSK(0.1, coreS), NSK(1, coreS * 0.3) }), HEAD_TR, dur, 1)
            core.LockedToPart = true
            local haloS = sep * 1.7
            local halo = mkSprite(hub, TX_SGLOW, pal[2], NumberSequence.new({
                NSK(0, haloS * 0.5), NSK(0.12, haloS), NSK(1, haloS * 0.35) }), HALO_TR, dur, 1)
            halo.LockedToPart = true
            local gs = sep * 1.9
            local gl = mkSprite(hub, TX_STAR4, GLINT_C, NumberSequence.new({
                NSK(0, gs * 0.1), NSK(0.32, gs), NSK(1, gs * 0.14) }), GLINT_TR, glintD * 1.2, 0.55)
            gl.Rotation = NumberRange.new(0, 90)
            gl.RotSpeed = NumberRange.new(-16, 16)
            gl:Emit(1)
            table.insert(_starLive, {
                host = host, tr = tr, ion = ion, core = core, halo = halo, aT = aT, aB = aB,
                cf0 = cf0, dir = dir, dist = dist, dur = dur, sep = sep,
                t0 = tick() + glintD, started = false,
            })
            Debris:AddItem(host, glintD + dur + life * 2.8 + 0.6)
        end
        local function pickPal()
            local r = math.random()
            if r < 0.55 then
                return 1
            end
            if r < 0.92 then
                return 2
            end
            return 3
        end
        local function pickCls(pi)
            if pi == 3 then
                if math.random() < 0.6 then
                    return 3
                end
                return 2
            end
            local r = math.random()
            if r < 0.25 then
                return 1
            end
            if r < 0.7 then
                return 2
            end
            return 3
        end
        local function viewAz(cam)
            local lv = cam.CFrame.LookVector
            local az = math.atan2(lv.Z, lv.X)
            if math.random() < 0.35 then
                return math.random() * 6.283
            end
            return az
        end
        local function spawnSingle()
            local cam = Camera
            if not cam then
                return
            end
            local base = cam.CFrame.Position
            local az = viewAz(cam) + (math.random() - 0.5) * 1.5
            local el = math.rad(24 + math.random() * 30)
            local r  = 190 + math.random() * 130
            local ce = math.cos(el)
            local start = base + Vec(ce * math.cos(az) * r, math.sin(el) * r, ce * math.sin(az) * r)
            local hd = az + 1.5708 + (math.random() - 0.5) * 2.2
            local pi = pickPal()
            spawnStreak(start, Vec(math.cos(hd), -(0.05 + math.random() * 0.34), math.sin(hd)).Unit,
                pickCls(pi), pi, base.Y + FLOOR_H)
        end
        local function spawnShower()
            local cam = Camera
            if not cam then
                return
            end
            local base = cam.CFrame.Position
            local floorY = base.Y + FLOOR_H
            local raz = viewAz(cam) + (math.random() - 0.5) * 0.9
            local rel = math.rad(36 + math.random() * 16)
            local cr = math.cos(rel)
            local rv = Vec(cr * math.cos(raz), math.sin(rel), cr * math.sin(raz))
            local dn = (Vec(0, -1, 0) + rv * rv.Y).Unit
            local sd = rv:Cross(dn).Unit
            local pi = pickPal()
            local t = 0
            for _ = 1, 3 + math.random(0, 2) do
                t = t + 0.16 + math.random() * 0.42
                task.delay(t, function()
                    if not Config.Weather or not cfg("WeatherShootingStars", false) then
                        return
                    end
                    local phi = (math.random() - 0.5) * 2.8
                    local off = dn * math.cos(phi) + sd * math.sin(phi)
                    local th = math.rad(9 + math.random() * 24)
                    local ct, st = math.cos(th), math.sin(th)
                    local u = (rv * ct + off * st).Unit
                    if u.Y < MIN_SIN then
                        off = -off
                        u = (rv * ct + off * st).Unit
                    end
                    if u.Y < MIN_SIN then
                        return
                    end
                    local ci = 2
                    if th < 0.22 then
                        ci = 1
                    elseif th > 0.44 then
                        ci = 3
                    end
                    pcall(spawnStreak, base + u * (215 + math.random() * 75),
                        (off * ct - rv * st).Unit, ci, pi, floorY)
                end)
            end
        end
        local function stepStars(now)
            for i = #_starLive, 1, -1 do
                local s = _starLive[i]
                if not s.host.Parent then
                    table.remove(_starLive, i)
                else
                    local a = (now - s.t0) / s.dur
                    if a >= 1 then
                        s.tr.Enabled = false
                        if s.ion then
                            s.ion.Enabled = false
                        end
                        table.remove(_starLive, i)
                    elseif a >= 0 then
                        if not s.started then
                            s.started = true
                            s.tr.Enabled = true
                            s.core:Emit(1)
                            s.halo:Emit(1)
                            if s.ion then
                                s.ion.Enabled = true
                            end
                        end
                        s.host.CFrame = s.cf0 + s.dir * (s.dist * a)
                        if a > 0.7 then
                            local h = s.sep * 0.5 * (1 - (a - 0.7) / 0.3)
                            s.aT.Position = Vec(0, h, 0)
                            s.aB.Position = Vec(0, -h, 0)
                        end
                    end
                end
            end
        end
        startStars = function()
            if _starConn then
                return
            end
            _starNextT = tick() + 2 + math.random() * 4
            _starConn = RunService.Heartbeat:Connect(function()
                if not Config.Weather or not cfg("WeatherShootingStars", false) then
                    return
                end
                local now = tick()
                if now >= _starNextT then
                    local r = evRate("WeatherStarRate")
                    _starNextT = now + (5 + math.random() * 6) / r
                    if math.random() < math.min(0.06 * r, 0.35) then
                        pcall(spawnShower)
                    else
                        pcall(spawnSingle)
                        if math.random() < math.min(0.22 * r, 0.6) then
                            task.delay(0.3 + math.random() * 0.5, function()
                                pcall(spawnSingle)
                            end)
                        end
                    end
                end
                pcall(stepStars, now)
            end)
        end
        rescheduleStars = function()
            if not _starConn then
                return
            end
            _starNextT = math.min(_starNextT, tick() + 11 / evRate("WeatherStarRate"))
        end
        stopStars = function()
            if _starConn then
                _starConn:Disconnect()
                _starConn = nil
            end
            for _, s in _starLive do
                pcall(function() s.host:Destroy() end)
            end
            table.clear(_starLive)
        end
        registerSpectacle("StarShower", 1, function()
            if not cfg("WeatherShootingStars", false) then
                return
            end
            spawnShower()
        end)
    end)()
    local startFireflies, stopFireflies, refreshFireflies
    ;(function()
        local FF_N     = 7
        local FF_BODY  = Color3.fromRGB(215, 255, 120)
        local FF_LIGHT = Color3.fromRGB(244, 232, 120)
        local FF_DOWN  = Vec(0, -80, 0)
        local WANDER   = 28
        local FF_STEP  = 2
        local FF_SEG   = 1.2
        local FF_TRC = ColorSequence.new({ CSK(0, Color3.fromRGB(198, 255, 128)),
            CSK(0.45, Color3.fromRGB(216, 238, 108)), CSK(1, Color3.fromRGB(255, 196, 86)) })
        local FF_TRT = NumberSequence.new({ NSK(0, 0.36), NSK(0.35, 0.66), NSK(1, 1) })
        local FF_TRW = NumberSequence.new({ NSK(0, 0.8), NSK(0.3, 1), NSK(1, 0) })
        local _ff = { list = nil, conn = nil, folder = nil, burst = nil, burstHost = nil, n = 4 }
        local _swarm = { active = false, t0 = 0, cx = 0, cz = 0, y = 0 }
        local _ffRp = RaycastParams.new()
        _ffRp.FilterType = Enum.RaycastFilterType.Exclude
        local function groundY(camPos, x, z)
            local ch = lp and lp.Character
            if ch then
                _ffRp.FilterDescendantsInstances = { getFolder(), ch }
            else
                _ffRp.FilterDescendantsInstances = { getFolder() }
            end
            local hit = Workspace:Raycast(Vec(x, camPos.Y + 6, z), FF_DOWN, _ffRp)
            if hit then
                return hit.Position.Y
            end
            return camPos.Y - 7
        end
        local function pickWaypoint(H, camPos)
            local x = camPos.X + (math.random() - 0.5) * WANDER
            local z = camPos.Z + (math.random() - 0.5) * WANDER
            H.a = H.pos
            H.bpt = Vec(x, groundY(camPos, x, z) + 0.5 + math.random() * 3, z)
            H.dur = math.clamp((H.bpt - H.a).Magnitude / 2.2, 1.5, 6)
            H.t = 0
        end
        local function stepToward(cur, target, maxStep)
            local d = target - cur
            local m = d.Magnitude
            if m <= maxStep or m < 1e-4 then
                return target
            end
            return cur + d * (maxStep / m)
        end
        local function trailOff(H)
            H.calm = 0
            if H.trail.Enabled then
                H.trail.Enabled = false
                H.trail:Clear()
            end
        end
        local function buildFlies()
            local folder = Instance.new("Folder")
            folder.Name = "_wxFlies"; folder:SetAttribute("WX_Custom", true)
            folder.Parent = getFolder()
            _ff.folder = folder
            _ff.list = {}
            local cam = Camera
            local camPos
            if cam then camPos = cam.CFrame.Position else camPos = Vec(0, 0, 0) end
            for i = 1, FF_N do
                local b = mkBoltPart(FF_BODY, 0, Vec(0.25, 0.25, 0.25), CFrame.new(camPos), folder)
                b.Shape = Enum.PartType.Ball
                local light = Instance.new("PointLight")
                light.Color = FF_LIGHT; light.Range = 8; light.Brightness = 2.5
                light.Parent = b
                local halo = Instance.new("ParticleEmitter")
                halo:SetAttribute("WX_Custom", true)
                halo.Texture = TX_MGLOW
                halo.Color = ColorSequence.new(FF_BODY)
                halo.LightEmission = 1; halo.LightInfluence = 0
                halo.Size = NumberSequence.new(1.1, 1.5)
                halo.Transparency = NumberSequence.new({ NSK(0, 0.75), NSK(1, 1) })
                halo.Rate = 12; halo.Lifetime = NumberRange.new(0.25, 0.4)
                halo.Speed = NumberRange.new(0, 0)
                halo.LockedToPart = true
                halo.Parent = b
                local a0 = Instance.new("Attachment")
                a0.Position = Vec(0, 0.6, 0); a0.Parent = b
                local a1 = Instance.new("Attachment")
                a1.Position = Vec(0, -0.6, 0); a1.Parent = b
                local tr = Instance.new("Trail")
                tr:SetAttribute("WX_Custom", true)
                tr.Attachment0 = a0; tr.Attachment1 = a1
                tr.Texture = TX_MGLOW; tr.TextureMode = Enum.TextureMode.Stretch
                tr.Color = FF_TRC; tr.Transparency = FF_TRT; tr.WidthScale = FF_TRW
                tr.Lifetime = 0.65
                tr.LightEmission = 1; tr.LightInfluence = 0
                tr.FaceCamera = true
                tr.MinLength = 0.25; tr.MaxLength = 14
                tr.Enabled = false
                tr.Parent = b
                local H = { part = b, light = light, trail = tr, halo = halo, bm = 1,
                            calm = 0, jump = true,
                            pos = camPos, a = camPos, bpt = camPos, t = 0, dur = 1,
                            ph = math.random() * 6.283, spin = 1.7 + i * 0.25,
                            blinkT = math.random() * 3, period = 2.4 + math.random() * 1.4 }
                pickWaypoint(H, camPos)
                H.pos = H.bpt
                pickWaypoint(H, camPos)
                b.CFrame = CFrame.new(H.pos)
                _ff.list[i] = H
            end
            local bh = mkBoltPart(FF_BODY, 1, Vec(1.5, 1.5, 1.5), CFrame.new(camPos), folder)
            local be = Instance.new("ParticleEmitter")
            be:SetAttribute("WX_Custom", true)
            be.Texture = TX_MGLOW
            be.Color = ColorSequence.new(Color3.fromRGB(220, 255, 130), Color3.fromRGB(255, 200, 80))
            be.LightEmission = 0.95; be.LightInfluence = 0.05
            be.Size = NumberSequence.new({ NSK(0, 0.1), NSK(0.08, 0.62, 0.15), NSK(0.45, 0.5, 0.1), NSK(1, 0.08) })
            be.Transparency = NumberSequence.new({ NSK(0, 1), NSK(0.08, 0.08), NSK(0.4, 0.45), NSK(0.75, 0.85), NSK(1, 1) })
            be.Rate = 0; be.Lifetime = NumberRange.new(1.6, 2.8)
            be.Speed = NumberRange.new(0.8, 2.2); be.SpreadAngle = Vector2.new(180, 180)
            be.Drag = 2.5; be.EmissionDirection = Enum.NormalId.Top
            be.Parent = bh
            _ff.burst = be; _ff.burstHost = bh
        end
        refreshFireflies = function()
            local list = _ff.list
            if not list then
                return
            end
            local I = iAmt()
            _ff.n = math.clamp(math.floor(1.5 + 3 * I), 1, FF_N)
            local rm, bm = 0.8 + 0.2 * I, 0.7 + 0.3 * I
            for i = 1, FF_N do
                local H = list[i]
                local on = i <= _ff.n
                H.bm = bm
                H.light.Range = 8 * rm
                H.halo.Enabled = on
                if not on then
                    H.light.Brightness = 0
                    H.part.Transparency = 1
                    H.jump = true
                    trailOff(H)
                end
            end
        end
        startFireflies = function()
            if _ff.conn then return end
            buildFlies()
            refreshFireflies()
            local accum = 0
            _ff.conn = RunService.Heartbeat:Connect(function(dt)
                if not Config.Weather then return end
                accum = accum + dt
                if accum < 0.05 then return end
                local step = accum; accum = 0
                local cam = Camera; if not cam then return end
                local camPos = cam.CFrame.Position
                local now = tick()
                local sw = -1
                if _swarm.active then
                    sw = now - _swarm.t0
                    if sw > 9 then _swarm.active = false; sw = -1 end
                end
                local list = _ff.list
                for i = 1, _ff.n do
                    local H = list[i]
                    local prev = H.pos
                    local newPos
                    if sw >= 0 then
                        local ang = H.ph + now * H.spin
                        local r
                        if sw < 2.5 then r = 10 - 7.4 * (sw / 2.5)
                        elseif sw < 6.5 then r = 2.6
                        else r = 2.6 + (sw - 6.5) * 6 end
                        local target = Vec(_swarm.cx + math.cos(ang) * r,
                            _swarm.y + 0.55 * math.sin(now * 1.3 + H.ph * 2),
                            _swarm.cz + math.sin(ang) * r)
                        newPos = stepToward(prev, prev:Lerp(target, math.min(step * 3, 1)), FF_STEP)
                        H.bpt = newPos; H.t = 1; H.dur = 1
                    else
                        H.t = H.t + step
                        local relX, relZ = prev.X - camPos.X, prev.Z - camPos.Z
                        if H.t >= H.dur or (relX * relX + relZ * relZ) > 3600 then
                            pickWaypoint(H, camPos)
                        end
                        local u = H.t / H.dur
                        u = u * u * (3 - 2 * u)
                        newPos = stepToward(prev, H.a:Lerp(H.bpt, u), FF_STEP)
                    end
                    H.pos = newPos
                    if H.jump or (sw >= 0 and (sw < 2.5 or sw >= 6.4))
                        or (newPos - prev).Magnitude > FF_SEG then
                        H.jump = false
                        trailOff(H)
                    else
                        H.calm = H.calm + step
                        if H.calm >= 0.25 and not H.trail.Enabled then
                            H.trail:Clear()
                            H.trail.Enabled = true
                        end
                    end
                    H.part.CFrame = CFrame.new(H.pos.X, H.pos.Y + 0.3 * math.sin(now * 1.7 + H.ph), H.pos.Z)
                    local pulse = math.exp(-((now + H.blinkT) % H.period) * 1.4)
                    H.light.Brightness = (0.5 + 2.6 * pulse) * H.bm
                    H.part.Transparency = 0.4 * (1 - pulse)
                end
            end)
        end
        stopFireflies = function()
            if _ff.conn then _ff.conn:Disconnect(); _ff.conn = nil end
            if _ff.folder then pcall(function() _ff.folder:Destroy() end); _ff.folder = nil end
            _ff.list = nil; _ff.burst = nil; _ff.burstHost = nil
            _swarm.active = false
        end
        registerSpectacle("FireflySwarm", 1, function()
            if not Config.Weather or _curType ~= "Fireflies" or not _ff.list then return end
            local cam = Camera; if not cam then return end
            local camPos = cam.CFrame.Position
            local ang = math.random() * 6.283
            local d = 8 + math.random() * 8
            local cx = camPos.X + math.cos(ang) * d
            local cz = camPos.Z + math.sin(ang) * d
            _swarm.cx = cx; _swarm.cz = cz
            _swarm.y = groundY(camPos, cx, cz) + 2.2
            _swarm.t0 = tick(); _swarm.active = true
            _ff.burstHost.CFrame = CFrame.new(cx, _swarm.y, cz)
            for _, H in _ff.list do
                trailOff(H)
            end
            local em = math.max(1, math.floor(7 * iRate(iAmt(), IR.Fireflies.lo, IR.Fireflies.hi) + 0.5))
            for n = 0, 5 do
                task.delay(1.6 + n * 0.7, function()
                    if _swarm.active and _ff.burst then _ff.burst:Emit(em) end
                end)
            end
        end)
    end)()
    local stopLeafDevil
    ;(function()
        local RING_N   = 11
        local DEV_H    = 25
        local DEV_R    = 9.5
        local DEV_LIFE = 14
        local DEV_HOLD = 9.6
        local DEV_DOWN = Vec(0, -80, 0)
        local RELEASE  = Vec(-8, -3.5, 3)
        local RING_TEX  = { TX_LEAFA, TX_LEAFB, TX_LEAFA, TX_LEAFB, TX_LEAFC }
        local RING_GLOW = { 0.62, 0.07, 0.6, 0.08, 0.1 }
        local RING_COL  = {
            ColorSequence.new({ CSK(0, Color3.fromRGB(226,190,128)), CSK(0.45, Color3.fromRGB(255,246,200)),
                                CSK(1, Color3.fromRGB(190,132,62)) }),
            ColorSequence.new({ CSK(0, Color3.fromRGB(160,80,52)), CSK(1, Color3.fromRGB(104,44,30)) }),
            ColorSequence.new({ CSK(0, Color3.fromRGB(230,222,176)), CSK(0.5, Color3.fromRGB(255,254,228)),
                                CSK(1, Color3.fromRGB(200,180,122)) }),
            ColorSequence.new({ CSK(0, Color3.fromRGB(156,74,255)), CSK(1, Color3.fromRGB(106,46,200)) }),
            ColorSequence.new({ CSK(0, Color3.fromRGB(196,156,112)), CSK(1, Color3.fromRGB(146,110,74)) }),
        }
        local RING_SIZE = NumberSequence.new({ NSK(0, 0.56, 0.14), NSK(1, 0.46, 0.1) })
        local RING_TR   = NumberSequence.new({ NSK(0, 1), NSK(0.07, 0.05), NSK(0.78, 0.4), NSK(1, 1) })
        local RING_SQ   = NumberSequence.new({ NSK(0, -0.6), NSK(0.25, 0.16), NSK(0.5, -0.6),
                                               NSK(0.75, 0.16), NSK(1, -0.6) })
        local SKIRT_SIZE = NumberSequence.new({ NSK(0, 1.5), NSK(1, 4.4) })
        local SKIRT_TR   = NumberSequence.new({ NSK(0, 1), NSK(0.22, 0.82), NSK(0.75, 0.92), NSK(1, 1) })
        local LEAF_SIZE  = NumberSequence.new({ NSK(0, 0.52, 0.12), NSK(1, 0.44, 0.1) })
        local LEAF_TR    = NumberSequence.new({ NSK(0, 1), NSK(0.1, 0.08), NSK(0.75, 0.42), NSK(1, 1) })
        local DUCK_TI = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local BACK_TI = TweenInfo.new(2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local _dev = { folder = nil, conn = nil }
        local _devRp = RaycastParams.new()
        _devRp.FilterType = Enum.RaycastFilterType.Exclude
        local function ambientRate(mul, ti)
            local I = iAmt()
            for _, L in _partLayers do
                if L.emitter and L.tag == nil then
                    if L.rateTween then L.rateTween:Cancel() end
                    L.rateMul = mul
                    local tw = TweenService:Create(L.emitter, ti, { Rate = layerRate(L, I) * mul })
                    L.rateTween = tw
                    tw:Play()
                end
            end
        end
        stopLeafDevil = function()
            if _dev.conn then _dev.conn:Disconnect(); _dev.conn = nil end
            if _dev.folder then pcall(function() _dev.folder:Destroy() end); _dev.folder = nil end
            if _dev.rings then
                _dev.rings = nil
                ambientRate(1, BACK_TI)
            end
        end
        local function mkRing(folder, cf, i, r)
            local p = mkBoltPart(WHITE, 1, Vec(0.3, 0.3, 0.3), cf, folder)
            local k = ((i - 1) % 5) + 1
            local glow = RING_GLOW[k]
            local e = Instance.new("ParticleEmitter")
            e:SetAttribute("WX_Custom", true)
            e.Texture = RING_TEX[k]
            e.Color = RING_COL[k]
            e.LightEmission = glow; e.LightInfluence = 1 - glow
            e.Size = RING_SIZE; e.Transparency = RING_TR; e.Squash = RING_SQ
            e.Rate = 0
            e.Lifetime = NumberRange.new(2, 3)
            e.Speed = NumberRange.new(5, 9)
            e.SpreadAngle = Vector2.new(8, 8)
            e.Rotation = NumberRange.new(-180, 180)
            e.RotSpeed = NumberRange.new(-300, 300)
            e.Acceleration = Vec(0, 2.6, 0)
            e.Drag = 1.4
            e.EmissionDirection = ND.Front
            e.Parent = p
            return { part = p, e = e, r = r }
        end
        registerSpectacle("LeafDevil", 1, function()
            if not Config.Weather or _curType ~= "Autumn" or _dev.conn then return end
            local cam = Camera; if not cam then return end
            local camPos = cam.CFrame.Position
            local bearing = math.random() * 6.283
            local dist = 18 + math.random() * 12
            local cx = camPos.X + math.cos(bearing) * dist
            local cz = camPos.Z + math.sin(bearing) * dist
            local ch = lp and lp.Character
            if ch then
                _devRp.FilterDescendantsInstances = { getFolder(), ch }
            else
                _devRp.FilterDescendantsInstances = { getFolder() }
            end
            local hit = Workspace:Raycast(Vec(cx, camPos.Y + 6, cz), DEV_DOWN, _devRp)
            local gy = camPos.Y - 4.6
            if hit then gy = hit.Position.Y end
            local folder = Instance.new("Folder")
            folder.Name = "_wxDevil"; folder:SetAttribute("WX_Custom", true)
            folder.Parent = getFolder()
            _dev.folder = folder
            local em = iRate(iAmt(), IR.Autumn.lo, IR.Autumn.hi)
            local seed = CFrame.new(cx, gy + 1, cz)
            local rings = table.create(RING_N)
            for i = 1, RING_N do
                local h = 0.8 + (i - 1) * (DEV_H - 0.8) / (RING_N - 1)
                local u = h / DEV_H
                local r = DEV_R * (0.15 + 0.85 * u ^ 0.9)
                if u > 0.72 then r = r * (1 + (u - 0.72) * 1.5) end
                local R = mkRing(folder, seed, i, r)
                R.h = h
                R.ph = (i - 1) * 0.62
                R.t0 = 0.12 * (i - 1)
                R.rate = (10 + 34 * (r / DEV_R)) * em
                rings[i] = R
            end
            _dev.rings = rings
            local foot = mkBoltPart(WHITE, 1, Vec(6.5, 0.4, 6.5), CFrame.new(cx, gy + 0.35, cz), folder)
            local leafSkirt = Instance.new("ParticleEmitter")
            leafSkirt:SetAttribute("WX_Custom", true)
            leafSkirt.Texture = TX_LEAFA
            leafSkirt.Color = RING_COL[1]
            leafSkirt.LightEmission = 0.3; leafSkirt.LightInfluence = 0.7
            leafSkirt.Size = LEAF_SIZE; leafSkirt.Transparency = LEAF_TR; leafSkirt.Squash = RING_SQ
            leafSkirt.Rate = 0
            leafSkirt.Lifetime = NumberRange.new(1.2, 2.2)
            leafSkirt.Speed = NumberRange.new(2, 5)
            leafSkirt.SpreadAngle = Vector2.new(70, 70)
            leafSkirt.Rotation = NumberRange.new(-180, 180)
            leafSkirt.RotSpeed = NumberRange.new(-260, 260)
            leafSkirt.Acceleration = Vec(0, 1.2, 0)
            leafSkirt.Drag = 2.2
            leafSkirt.EmissionDirection = ND.Top
            leafSkirt.Parent = foot
            local dustSkirt = Instance.new("ParticleEmitter")
            dustSkirt:SetAttribute("WX_Custom", true)
            dustSkirt.Texture = TX_DUST
            dustSkirt.Color = ColorSequence.new(Color3.fromRGB(190,166,130), Color3.fromRGB(140,118,90))
            dustSkirt.LightEmission = 0.04; dustSkirt.LightInfluence = 0.96
            dustSkirt.Size = SKIRT_SIZE; dustSkirt.Transparency = SKIRT_TR
            dustSkirt.Rate = 0
            dustSkirt.Lifetime = NumberRange.new(0.9, 1.4)
            dustSkirt.Speed = NumberRange.new(1, 2.6)
            dustSkirt.SpreadAngle = Vector2.new(85, 85)
            dustSkirt.RotSpeed = NumberRange.new(-25, 25)
            dustSkirt.Acceleration = Vec(0, 1, 0)
            dustSkirt.Drag = 2.4
            dustSkirt.EmissionDirection = ND.Top
            dustSkirt.Parent = foot
            local scuff = mkBoltPart(WHITE, 1, Vec(15, 0.08, 15), CFrame.new(cx, gy + 0.05, cz), folder)
            scuff.Material = Enum.Material.SmoothPlastic
            local sd = Instance.new("Decal")
            sd:SetAttribute("WX_Custom", true)
            sd.Face = ND.Top; sd.Texture = TX_DUST
            sd.Color3 = Color3.fromRGB(96, 74, 52); sd.Transparency = 0.55
            sd.Parent = scuff
            ambientRate(0.45, DUCK_TI)
            local t0 = tick()
            local ang, px, pz = 0, cx, cz
            local lean = math.random() * 6.283
            _dev.conn = RunService.Heartbeat:Connect(function(dt)
                if not folder.Parent then stopLeafDevil() return end
                local t = tick() - t0
                if t > DEV_LIFE then stopLeafDevil() return end
                ang = ang + dt * 2.7
                px = px + Wind.x * dt * 0.75
                pz = pz + Wind.z * dt * 0.75
                local lx = math.cos(lean + t * 0.21) * 0.13
                local lz = math.sin(lean + t * 0.17) * 0.13
                local climb = math.min(t / 1.5, 1)
                local release = t > DEV_HOLD
                for i = 1, RING_N do
                    local R = rings[i]
                    local h = R.h * climb
                    local th = ang + R.ph
                    local cs, sn = math.cos(th), math.sin(th)
                    local r = R.r * (0.55 + 0.45 * climb)
                    local p = Vec(px + lx * h + cs * r, gy + 0.35 + h, pz + lz * h + sn * r)
                    R.part.CFrame = CFrame.lookAt(p, p + Vec(-sn, 0.3, cs))
                    if release then
                        R.e.Rate = 0
                        R.e.Acceleration = RELEASE
                    else
                        R.e.Rate = R.rate * math.clamp((t - R.t0) / 0.6, 0, 1)
                    end
                end
                foot.CFrame = CFrame.new(px, gy + 0.35, pz)
                scuff.CFrame = CFrame.new(px, gy + 0.05, pz) * CFrame.Angles(0, t * 0.35, 0)
                if release then
                    leafSkirt.Rate = 0
                    dustSkirt.Rate = 0
                    leafSkirt.Acceleration = RELEASE
                    sd.Transparency = math.min(0.55 + (t - DEV_HOLD) * 0.35, 1)
                    if t > DEV_HOLD + 0.1 and _dev.rings then
                        _dev.rings = nil
                        ambientRate(1, BACK_TI)
                    end
                else
                    local k = math.min(t / 0.8, 1)
                    leafSkirt.Rate = 26 * em * k
                    dustSkirt.Rate = 15 * em * k
                    sd.Transparency = 0.95 - 0.4 * math.min(t / 1.2, 1)
                end
            end)
        end)
    end)()
    local puddlesRefresh, puddlesIntensity, stopPuddles
    ;(function()
        local TXP_RING = "rbxassetid://17738857765"
        local TXP_DROP = "rbxassetid://14964503448"
        local TXP_STAR = "rbxassetid://17726943419"
        local WATER_C  = Color3.fromRGB(22, 28, 37)
        local SHEEN_C  = Color3.fromRGB(150, 175, 205)
        local FOAM_C   = Color3.fromRGB(236, 246, 255)
        local PUD_DOWN = Vec(0, -90, 0)
        local FIT_DOWN = Vec(0, -4.2, 0)
        local HALF_PI  = 1.5707963
        local FIT_TOL  = 1.5
        local FIT_R    = 1.09
        local FIT_K    = { 1, 0.66, 0.44, 0.28 }
        local FIT_C = {
            1, 0, 0.70711, 0.70711, 0, 1, -0.70711, 0.70711,
            -1, 0, -0.70711, -0.70711, 0, -1, 0.70711, -0.70711,
        }
        local FIT_Q = {
            1, 1, 0.333, 1, -0.333, 1, -1, 1,
            -1, 0.333, -1, -0.333, -1, -1, -0.333, -1,
            0.333, -1, 1, -1, 1, -0.333, 1, 0.333,
        }
        local CELL     = 32
        local HALF     = 16
        local NOISE_F  = 0.018
        local POOL_F   = 0.74
        local TILE_K   = 1 / 470
        local K_CAP    = 48
        local MAX_REC  = 96
        local _pud = { folder = nil, conn = nil }
        local _plist = {}
        local _pmap = {}
        local _pfail = {}
        local _cd = { i = 0, j = 0, key = 0, kind = 0, cx = 0, cz = 0, gy = 0 }
        local _units, _uIdx = {}, 1
        local _prints, _pIdx = {}, 1
        local _pstates = {}
        local _abuf = {}
        local _prp = RaycastParams.new()
        _prp.FilterType = Enum.RaycastFilterType.Exclude
        local _pfilter = {}
        local _fieldToken, _rebuild = 0, false
        local _int, _thr, _placeR, _seed = 1, 0, 50, 0
        local _wTr, _wRf = 0.35, 0.16
        local _homeI, _homeJ = 1e9, 1e9
        local function pudActive()
            if not Config.Weather or not cfg("WeatherPuddles", false) then
                return false
            end
            if _curType == "Rain" then
                return true
            end
            return cfg("WeatherStorm", false)
        end
        local function pudIntensity()
            return iAmt()
        end
        local function mkFlatPart(size, cf, parent)
            local p = Instance.new("Part")
            p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
            p.CastShadow = false; p.Transparency = 1
            p.Size = size; p.CFrame = cf
            p:SetAttribute("WX_Custom", true)
            p.Parent = parent
            return p
        end
        local function mkSlab(d1, d2, cf, parent, sheen)
            local p = Instance.new("Part")
            p.Shape = Enum.PartType.Cylinder
            p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
            p.CastShadow = false; p.Material = Enum.Material.SmoothPlastic
            if sheen then
                p.Color = SHEEN_C; p.Transparency = 0.74; p.Reflectance = 0.38
            else
                p.Color = WATER_C; p.Transparency = _wTr; p.Reflectance = _wRf
                p:SetAttribute("WX_W", true)
            end
            p.Size = Vec(0.05, d1, d2)
            p.CFrame = cf
            p:SetAttribute("WX_Custom", true)
            p.Parent = parent
        end
        local function mkTile(w, l, cf, parent)
            local p = Instance.new("Part")
            p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
            p.CastShadow = false; p.Material = Enum.Material.SmoothPlastic
            p.Color = WATER_C; p.Transparency = _wTr; p.Reflectance = _wRf
            p.Size = Vec(w, 0.05, l)
            p.CFrame = cf
            p:SetAttribute("WX_Custom", true)
            p:SetAttribute("WX_W", true)
            p.Parent = parent
        end
        local function fitSlab(cx, cz, d1, d2, yaw, gy)
            local cs, sn = math.cos(yaw), math.sin(yaw)
            for k = 1, 4 do
                local f = FIT_K[k] * FIT_R * 0.5
                local a, b = d1 * f, d2 * f
                local ok, gx, gz, n = true, 0, 0, 0
                for i = 1, 8 do
                    local ct, st = FIT_C[i * 2 - 1], FIT_C[i * 2]
                    local ox = sn * b * st - cs * a * ct
                    local oz = sn * a * ct + cs * b * st
                    local h = Workspace:Raycast(Vec(cx + ox, gy + 2, cz + oz), FIT_DOWN, _prp)
                    local sup = false
                    if h and h.Normal.Y >= 0.86 and h.Instance.CanCollide then
                        local dy = h.Position.Y - gy
                        sup = dy < FIT_TOL and dy > -FIT_TOL
                    end
                    if sup then
                        gx, gz, n = gx + ox, gz + oz, n + 1
                    else
                        ok = false
                    end
                end
                if ok then
                    return cx, cz, d1 * FIT_K[k], d2 * FIT_K[k]
                end
                if n == 0 then
                    return nil
                end
                cx, cz = cx + gx / n * 0.5, cz + gz / n * 0.5
            end
            return nil
        end
        local function fitRect(cx, cz, w, l, gy)
            for k = 1, 4 do
                local f = FIT_K[k] * FIT_R * 0.5
                local a, b = w * f, l * f
                local ok = true
                for i = 1, 12 do
                    local h = Workspace:Raycast(
                        Vec(cx + FIT_Q[i * 2 - 1] * a, gy + 2, cz + FIT_Q[i * 2] * b), FIT_DOWN, _prp)
                    local sup = false
                    if h and h.Normal.Y >= 0.86 and h.Instance.CanCollide then
                        local dy = h.Position.Y - gy
                        sup = dy < FIT_TOL and dy > -FIT_TOL
                    end
                    if not sup then
                        ok = false
                        break
                    end
                end
                if ok then
                    return w * FIT_K[k], l * FIT_K[k]
                end
            end
            return nil
        end
        local function mkHost(m, cf, size, k, I)
            local host = mkFlatPart(size, cf, m)
            local e = Instance.new("ParticleEmitter")
            e:SetAttribute("WX_Custom", true)
            e.Texture = TXP_RING
            e.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            e.EmissionDirection = Enum.NormalId.Top
            e.Speed = NumberRange.new(0.05, 0.05)
            e.Rate = (2.1 + 4.2 * I) * k
            e.Lifetime = NumberRange.new(1.1, 1.6)
            e.Size = NumberSequence.new({ NSK(0, 0.12), NSK(1, 4.4) })
            e.Transparency = NumberSequence.new({ NSK(0, 0.9), NSK(0.14, 0.12), NSK(0.62, 0.5), NSK(1, 1) })
            e.Color = ColorSequence.new(Color3.fromRGB(215, 234, 250))
            e.LightEmission = 0.45
            e.Parent = host
            local g = Instance.new("ParticleEmitter")
            g:SetAttribute("WX_Custom", true)
            g.Texture = TXP_STAR
            g.EmissionDirection = Enum.NormalId.Top
            g.Speed = NumberRange.new(0, 0)
            g.Rate = 0.8 * I * k
            g.Lifetime = NumberRange.new(0.16, 0.28)
            g.Size = NumberSequence.new({ NSK(0, 0.06), NSK(0.4, 0.3), NSK(1, 0.04) })
            g.Transparency = NumberSequence.new({ NSK(0, 0.6), NSK(1, 1) })
            g.Color = ColorSequence.new(Color3.fromRGB(240, 248, 255))
            g.LightEmission = 0.5
            g.Parent = host
            return e, g
        end
        local function mkPuddle(cd, span, nslab, I)
            local x, z, gy = cd.cx, cd.cz, cd.gy
            local m = Instance.new("Model")
            m.Name = "_pud"
            local px = x + (math.random() - 0.5) * CELL * 0.16
            local pz = z + (math.random() - 0.5) * CELL * 0.16
            local spine = math.random() * 6.28318
            local sx, sz = math.cos(spine), math.sin(spine)
            local lx, lz = -sz, sx
            local yaw0 = math.pi - spine
            local slabs, rmax = {}, 0
            local s0, s1, l0, l1 = 1e9, -1e9, 1e9, -1e9
            local function place(cx, cz, d1, d2, yaw, yoff, sheen)
                local fx, fz, fd1, fd2 = fitSlab(cx, cz, d1, d2, yaw, gy)
                if not fx then
                    return false
                end
                local rad = math.max(fd1, fd2) * 0.5
                local ex, ez = fx - x, fz - z
                if math.abs(ex) + rad > HALF or math.abs(ez) + rad > HALF then
                    return false
                end
                mkSlab(fd1, fd2, CFrame.new(fx, gy + yoff, fz)
                    * CFrame.Angles(0, yaw, 0) * CFrame.Angles(0, 0, HALF_PI), m, sheen)
                if not sheen then
                    slabs[#slabs + 1] = {
                        cx = fx, cz = fz,
                        cs = math.cos(yaw), sn = math.sin(yaw),
                        ia = 2 / fd1, ib = 2 / fd2, rect = false,
                    }
                    rmax = math.max(rmax, math.sqrt(ex * ex + ez * ez) + rad)
                end
                local dx, dz = fx - px, fz - pz
                local t, lat = dx * sx + dz * sz, dx * lx + dz * lz
                local ins = math.min(fd1, fd2) * 0.375
                s0, s1 = math.min(s0, t - ins), math.max(s1, t + ins)
                l0, l1 = math.min(l0, lat - ins), math.max(l1, lat + ins)
                return true
            end
            if not place(px, pz, span, span * 0.62, yaw0, 0.002, false) then
                m:Destroy()
                return false
            end
            for i = 1, nslab do
                local t = ((i - 0.5) / nslab - 0.5) * span * 0.62 + (math.random() - 0.5) * span * 0.14
                local lat = (math.random() - 0.5) * span * 0.24
                local d1 = span * (0.34 + math.random() * 0.3)
                place(px + sx * t + lx * lat, pz + sz * t + lz * lat,
                    d1, d1 * (0.6 + math.random() * 0.34),
                    yaw0 + (math.random() - 0.5) * 1.6, 0.008 + i * 0.004, false)
            end
            for _ = 1, 2 do
                local t = (math.random() - 0.5) * span * 0.5
                local lat = (math.random() - 0.5) * span * 0.16
                local d1 = span * (0.14 + math.random() * 0.18)
                place(px + sx * t + lx * lat, pz + sz * t + lz * lat,
                    d1, d1 * (0.4 + math.random() * 0.35), math.random() * math.pi, 0.036, true)
            end
            s0, s1 = math.max(s0, span * -0.425), math.min(s1, span * 0.425)
            l0, l1 = math.max(l0, span * -0.225), math.min(l1, span * 0.225)
            local hw, hl = math.max(s1 - s0, 1), math.max(l1 - l0, 1)
            local hm, hn = (s0 + s1) * 0.5, (l0 + l1) * 0.5
            local k = (span / 26) ^ 1.5 * hw * hl / (span * span * 0.3825)
            local e, g = mkHost(m, CFrame.new(px + sx * hm + lx * hn, gy + 0.1, pz + sz * hm + lz * hn)
                * CFrame.Angles(0, -spine, 0), Vec(hw, 0.05, hl), k, I)
            m.Parent = _pud.folder
            local P = {
                cx = x, cz = z, top = gy + 0.06, r2 = rmax * rmax, k = k,
                key = cd.key, ci = cd.i, cj = cd.j, kind = cd.kind,
                slabs = slabs, ring = e, glint = g, model = m,
            }
            _plist[#_plist + 1] = P
            _pmap[cd.key] = P
            return true
        end
        local function mkFloodCell(cd, I)
            local gy = cd.gy
            local m = Instance.new("Model")
            m.Name = "_pud"
            local slabs = {}
            local area, rmax = 0, 0
            local x0, x1, z0, z1 = 1e9, -1e9, 1e9, -1e9
            for a = 0, 1 do
                for b = 0, 1 do
                    local scx = cd.cx + (a - 0.5) * HALF
                    local scz = cd.cz + (b - 0.5) * HALF
                    local fw, fl = fitRect(scx, scz, HALF, HALF, gy)
                    if fw then
                        mkTile(fw, fl, CFrame.new(scx, gy + 0.002, scz), m)
                        slabs[#slabs + 1] = {
                            cx = scx, cz = scz, cs = 1, sn = 0,
                            ia = 2 / fw, ib = 2 / fl, rect = true,
                        }
                        area = area + fw * fl
                        rmax = math.max(rmax, 0.7072 * (HALF + fw))
                        x0 = math.min(x0, scx - fw * 0.5)
                        x1 = math.max(x1, scx + fw * 0.5)
                        z0 = math.min(z0, scz - fl * 0.5)
                        z1 = math.max(z1, scz + fl * 0.5)
                    end
                end
            end
            if area <= 0 then
                m:Destroy()
                return false
            end
            if area > CELL * CELL * 0.98 and math.random() < 0.45 then
                local d1 = CELL * (0.15 + math.random() * 0.1)
                local sx = cd.cx + (math.random() - 0.5) * CELL * 0.4
                local sz = cd.cz + (math.random() - 0.5) * CELL * 0.4
                local yaw = math.random() * math.pi
                local fx, fz, fd1, fd2 = fitSlab(sx, sz, d1, d1 * (0.4 + math.random() * 0.35), yaw, gy)
                if fx and math.abs(fx - cd.cx) + fd1 * 0.5 < HALF
                    and math.abs(fz - cd.cz) + fd1 * 0.5 < HALF then
                    mkSlab(fd1, fd2, CFrame.new(fx, gy + 0.036, fz)
                        * CFrame.Angles(0, yaw, 0) * CFrame.Angles(0, 0, HALF_PI), m, true)
                end
            end
            local hw, hl = math.max(x1 - x0, 1), math.max(z1 - z0, 1)
            local e, g = mkHost(m, CFrame.new((x0 + x1) * 0.5, gy + 0.1, (z0 + z1) * 0.5),
                Vec(hw, 0.05, hl), area * TILE_K, I)
            m.Parent = _pud.folder
            local P = {
                cx = cd.cx, cz = cd.cz, top = gy + 0.06, r2 = rmax * rmax, k = area * TILE_K,
                key = cd.key, ci = cd.i, cj = cd.j, kind = cd.kind,
                slabs = slabs, ring = e, glint = g, model = m,
            }
            _plist[#_plist + 1] = P
            _pmap[cd.key] = P
            return true
        end
        local function mkSplashUnit(parent)
            local p = mkFlatPart(Vec(1.1, 0.1, 1.1), CFrame.new(0, -900, 0), parent)
            local ring = Instance.new("ParticleEmitter")
            ring:SetAttribute("WX_Custom", true)
            ring.Texture = TXP_RING
            ring.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            ring.EmissionDirection = Enum.NormalId.Top
            ring.Speed = NumberRange.new(0.05, 0.05)
            ring.Rate = 0
            ring.Lifetime = NumberRange.new(0.45, 0.7)
            ring.Size = NumberSequence.new({ NSK(0, 0.1), NSK(1, 4) })
            ring.Transparency = NumberSequence.new({ NSK(0, 0.75), NSK(0.1, 0.05), NSK(0.5, 0.4), NSK(1, 1) })
            ring.Color = ColorSequence.new(Color3.fromRGB(230, 244, 255))
            ring.LightEmission = 0.5
            ring.Parent = p
            local foam = Instance.new("ParticleEmitter")
            foam:SetAttribute("WX_Custom", true)
            foam.Texture = TX_SNOWSOFT
            foam.Orientation = Enum.ParticleOrientation.VelocityParallel
            foam.EmissionDirection = Enum.NormalId.Top
            foam.Rate = 0
            foam.SpreadAngle = Vector2.new(56, 56)
            foam.Acceleration = Vec(0, -80, 0)
            foam.Lifetime = NumberRange.new(0.3, 0.6)
            foam.Size = NumberSequence.new({ NSK(0, 0.6, 0.22), NSK(1, 0.2) })
            foam.Squash = NumberSequence.new({ NSK(0, 1.5), NSK(1, 0.4) })
            foam.Speed = NumberRange.new(6, 12)
            foam.Color = ColorSequence.new(FOAM_C)
            foam.Transparency = NumberSequence.new({ NSK(0, 0.18), NSK(0.7, 0.45), NSK(1, 1) })
            foam.LightEmission = 0.18
            foam.Parent = p
            local drops = Instance.new("ParticleEmitter")
            drops:SetAttribute("WX_Custom", true)
            drops.Texture = TXP_DROP
            drops.Orientation = Enum.ParticleOrientation.VelocityParallel
            drops.EmissionDirection = Enum.NormalId.Top
            drops.Rate = 0
            drops.SpreadAngle = Vector2.new(52, 52)
            drops.Acceleration = Vec(0, -80, 0)
            drops.Lifetime = NumberRange.new(0.32, 0.62)
            drops.Size = NumberSequence.new({ NSK(0, 0.55, 0.18), NSK(1, 0.28) })
            drops.Speed = NumberRange.new(6, 12)
            drops.Color = ColorSequence.new(Color3.fromRGB(210, 232, 250))
            drops.Transparency = NumberSequence.new({ NSK(0, 0.1), NSK(0.75, 0.3), NSK(1, 1) })
            drops.LightEmission = 0.25
            drops.Parent = p
            local mist = Instance.new("ParticleEmitter")
            mist:SetAttribute("WX_Custom", true)
            mist.Texture = TX_SNOWSOFT
            mist.EmissionDirection = Enum.NormalId.Top
            mist.Rate = 0
            mist.Speed = NumberRange.new(1.2, 2.8)
            mist.SpreadAngle = Vector2.new(48, 48)
            mist.Lifetime = NumberRange.new(0.3, 0.5)
            mist.Size = NumberSequence.new({ NSK(0, 0.5), NSK(1, 1.6) })
            mist.Transparency = NumberSequence.new({ NSK(0, 0.75), NSK(1, 1) })
            mist.Color = ColorSequence.new(FOAM_C)
            mist.LightEmission = 0.1
            mist.Parent = p
            return { part = p, ring = ring, foam = foam, drops = drops, mist = mist }
        end
        local function fireSplash(x, y, z, speed)
            local u = _units[_uIdx]
            if not u then
                return
            end
            _uIdx = (_uIdx % #_units) + 1
            local s = math.clamp(speed, 4, 36)
            u.part.CFrame = CFrame.new(x, y + 0.12, z)
            u.ring.Size = NumberSequence.new({ NSK(0, 0.1), NSK(1, 3.2 + s * 0.18) })
            local lo, hi = 5 + s * 0.38, 8 + s * 0.6
            u.foam.Speed = NumberRange.new(lo, hi)
            u.drops.Speed = NumberRange.new(lo * 0.8, hi * 0.9)
            u.ring:Emit(2)
            u.foam:Emit(9 + math.floor(s * 0.75))
            u.drops:Emit(4 + math.floor(s * 0.3))
            u.mist:Emit(3)
        end
        local function dropPrint(x, y, z, heading, side)
            local p = _prints[_pIdx]
            if not p then
                return
            end
            _pIdx = (_pIdx % #_prints) + 1
            p.CFrame = CFrame.new(x, y + 0.02, z) * CFrame.Angles(0, heading, 0) * CFrame.new(side * 0.4, 0, 0)
            p.Transparency = 0.42
            TweenService:Create(p, TweenInfo.new(2.2), { Transparency = 1 }):Play()
        end
        local function defaultActors()
            local n = 0
            local cam = Camera
            if not cam then
                return _abuf, 0
            end
            local camPos = cam.CFrame.Position
            for _, plr in Players:GetPlayers() do
                local ch = plr.Character
                local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local pos = hrp.Position
                    local dx, dy, dz = pos.X - camPos.X, pos.Y - camPos.Y, pos.Z - camPos.Z
                    if dx * dx + dy * dy + dz * dz < 12100 then
                        local vel = hrp.AssemblyLinearVelocity
                        local grounded = vel.Y > -6 and vel.Y < 6
                        if not grounded then
                            local hum = ch:FindFirstChildOfClass("Humanoid")
                            grounded = hum ~= nil and hum.FloorMaterial ~= Enum.Material.Air
                        end
                        n = n + 1
                        local rec = _abuf[n]
                        if not rec then
                            rec = {}
                            _abuf[n] = rec
                        end
                        rec.key = plr
                        rec.fx, rec.fy, rec.fz = pos.X, pos.Y - 2.9, pos.Z
                        rec.vx, rec.vy, rec.vz = vel.X, vel.Y, vel.Z
                        rec.speed = math.sqrt(vel.X * vel.X + vel.Z * vel.Z)
                        rec.grounded = grounded
                    end
                end
            end
            return _abuf, n
        end
        local actorsProvider = defaultActors
        local function inPuddle(P, x, z)
            local dx, dz = x - P.cx, z - P.cz
            if dx * dx + dz * dz > P.r2 then
                return false
            end
            for _, sl in P.slabs do
                local ux, uz = x - sl.cx, z - sl.cz
                local u = (-ux * sl.cs + uz * sl.sn) * sl.ia
                local v = (ux * sl.sn + uz * sl.cs) * sl.ib
                if sl.rect then
                    if u > -1 and u < 1 and v > -1 and v < 1 then
                        return true
                    end
                elseif u * u + v * v <= 1 then
                    return true
                end
            end
            return false
        end
        local function fieldAt(wx, wz)
            return math.noise(wx * NOISE_F, wz * NOISE_F, _seed)
        end
        local function floodThr(I)
            if I <= 1 then
                return -0.4043 * (I - 0.3)
            end
            if I <= 1.6 then
                return -0.283 - 0.3417 * (I - 1)
            end
            return -0.488 - 1.405 * (I - 1.6)
        end
        local function refreshParams()
            local I = pudIntensity()
            _int = I
            _thr = floodThr(I)
            _placeR = 46 + 20 * I
            _wTr = 0.46 - 0.11 * I
            _wRf = 0.11 + 0.05 * I
        end
        local function cellKind(i, j)
            local ccx, ccz = (i + 0.5) * CELL, (j + 0.5) * CELL
            if fieldAt(ccx, ccz) <= _thr then
                return 0
            end
            if fieldAt(ccx + CELL, ccz) > _thr and fieldAt(ccx - CELL, ccz) > _thr
                and fieldAt(ccx, ccz + CELL) > _thr and fieldAt(ccx, ccz - CELL) > _thr then
                return 2
            end
            return 1
        end
        local function placeCell(i, j, key, kind, by)
            local folder = _pud.folder
            if not folder then
                return false
            end
            local ccx, ccz = (i + 0.5) * CELL, (j + 0.5) * CELL
            _pfilter[1] = folder
            local ch = lp and lp.Character
            if ch then
                _pfilter[2] = ch
            else
                _pfilter[2] = folder
            end
            _prp.FilterDescendantsInstances = _pfilter
            local hit = Workspace:Raycast(Vec(ccx, by + 6, ccz), PUD_DOWN, _prp)
            if not hit or hit.Normal.Y < 0.94 then
                return false
            end
            local inst = hit.Instance
            if not inst.CanCollide then
                return false
            end
            if inst:IsA("Terrain") and hit.Material == Enum.Material.Water then
                return false
            end
            local cd = _cd
            cd.i, cd.j, cd.key, cd.kind = i, j, key, kind
            cd.cx, cd.cz, cd.gy = ccx, ccz, hit.Position.Y
            if kind == 2 then
                return mkFloodCell(cd, _int)
            end
            local nslab = 5
            if _int > 1.15 then
                nslab = 4
            end
            return mkPuddle(cd, CELL * POOL_F * (0.82 + 0.24 * math.random()), nslab, _int)
        end
        local function tryCell(i, j, bx, bz, by)
            local key = (i + 32768) * 65536 + j + 32768
            if _pmap[key] or _pfail[key] then
                return false
            end
            local dx = (i + 0.5) * CELL - bx
            local dz = (j + 0.5) * CELL - bz
            if dx * dx + dz * dz > _placeR * _placeR then
                return false
            end
            local kind = cellKind(i, j)
            if kind == 0 then
                return false
            end
            if not placeCell(i, j, key, kind, by) then
                _pfail[key] = true
            end
            return true
        end
        local function maintain(bx, by, bz)
            local ci, cj = math.floor(bx / CELL), math.floor(bz / CELL)
            local budget = 8
            if ci ~= _homeI or cj ~= _homeJ then
                _homeI, _homeJ = ci, cj
                table.clear(_pfail)
            end
            if _rebuild then
                _rebuild = false
                refreshParams()
                table.clear(_pfail)
                budget = 18
                for _, P in _plist do
                    for _, d in P.model:GetChildren() do
                        if d:GetAttribute("WX_W") then
                            d.Transparency = _wTr
                            d.Reflectance = _wRf
                        end
                    end
                end
                local n = 1
                while n <= #_plist do
                    local P = _plist[n]
                    if P.kind == cellKind(P.ci, P.cj) then
                        n = n + 1
                    else
                        _pmap[P.key] = nil
                        P.model:Destroy()
                        _plist[n] = _plist[#_plist]
                        _plist[#_plist] = nil
                    end
                end
            end
            local cull = _placeR + CELL * 0.75
            local cull2 = cull * cull
            local n = 1
            while n <= #_plist do
                local P = _plist[n]
                local dx, dz = P.cx - bx, P.cz - bz
                if dx * dx + dz * dz > cull2 then
                    _pmap[P.key] = nil
                    P.model:Destroy()
                    _plist[n] = _plist[#_plist]
                    _plist[#_plist] = nil
                else
                    n = n + 1
                end
            end
            local nr = math.ceil(_placeR / CELL)
            for ring = 0, nr do
                for di = -ring, ring do
                    for dj = -ring, ring do
                        if budget > 0 and #_plist < MAX_REC
                            and math.max(math.abs(di), math.abs(dj)) == ring
                            and tryCell(ci + di, cj + dj, bx, bz, by) then
                            budget = budget - 1
                        end
                    end
                end
            end
            local ksum = 0
            for _, P in _plist do
                ksum = ksum + P.k
            end
            local damp = 1
            if ksum > K_CAP then
                damp = K_CAP / ksum
            end
            local rr = (2.1 + 4.2 * _int) * damp
            local gr = 0.8 * _int * damp
            for _, P in _plist do
                P.ring.Rate = rr * P.k
                P.glint.Rate = gr * P.k
            end
        end
        local function tick20(now, doMaintain)
            local bx, by, bz
            local ch = lp and lp.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            if hrp then
                local p = hrp.Position
                bx, by, bz = p.X, p.Y, p.Z
            elseif Camera then
                local p = Camera.CFrame.Position
                bx, by, bz = p.X, p.Y, p.Z
            else
                return
            end
            if doMaintain then
                maintain(bx, by, bz)
            end
            local list, n = actorsProvider()
            for ai = 1, n do
                local a = list[ai]
                local st = _pstates[a.key]
                if not st then
                    st = { last = 0, wet = 0, side = 1, prevVy = 0 }
                    _pstates[a.key] = st
                end
                local sp = a.speed
                local pud = nil
                for _, P in _plist do
                    if math.abs(a.fy - P.top) < 4.5 and inPuddle(P, a.fx, a.fz) then
                        pud = P
                        break
                    end
                end
                local interval = math.clamp(3.6 / math.max(sp, 1), 0.15, 0.32)
                if pud and a.grounded and sp > 2.2 then
                    local landing = st.prevVy < -25
                    if landing or now - st.last >= interval then
                        st.last = now
                        st.side = -st.side
                        local fs = sp
                        if landing then
                            fs = 36
                        end
                        fireSplash(a.fx, pud.top, a.fz, fs)
                        st.wet = now + 1.7
                    end
                elseif not pud and now < st.wet and a.grounded and sp > 2.2 then
                    if now - st.last >= interval then
                        st.last = now
                        st.side = -st.side
                        dropPrint(a.fx, a.fy, a.fz, math.atan2(-a.vx, -a.vz), st.side)
                    end
                end
                st.prevVy = a.vy
            end
        end
        local function startPuddles()
            if _pud.conn then
                return
            end
            local folder = Instance.new("Folder")
            folder.Name = "_wxPuddles"
            folder:SetAttribute("WX_Custom", true)
            folder.Parent = getFolder()
            _pud.folder = folder
            _plist = {}
            _pmap = {}
            table.clear(_pfail)
            _seed = math.random() * 512
            _homeI, _homeJ = 1e9, 1e9
            refreshParams()
            _units, _uIdx = {}, 1
            for i = 1, 8 do
                _units[i] = mkSplashUnit(folder)
            end
            _prints, _pIdx = {}, 1
            for i = 1, 12 do
                local p = mkFlatPart(Vec(0.6, 0.02, 1.0), CFrame.new(0, -900, 0), folder)
                p.Material = Enum.Material.SmoothPlastic
                p.Color = Color3.fromRGB(14, 18, 25)
                p.Reflectance = 0.18
                _prints[i] = p
            end
            local accum = 0
            local mTick = 0
            _pud.conn = RunService.Heartbeat:Connect(function(dt)
                accum = accum + dt
                if accum < 0.05 then
                    return
                end
                accum = 0
                if not pudActive() then
                    return
                end
                mTick = mTick + 1
                local doMaintain = false
                if mTick >= 14 then
                    mTick = 0
                    doMaintain = true
                end
                pcall(tick20, os.clock(), doMaintain)
            end)
        end
        function stopPuddles(hard)
            if _pud.conn then
                _pud.conn:Disconnect()
                _pud.conn = nil
            end
            table.clear(_pstates)
            local folder = _pud.folder
            _pud.folder = nil
            _plist = {}
            _pmap = {}
            table.clear(_pfail)
            _units = {}
            _prints = {}
            _rebuild = false
            if not folder then
                return
            end
            if hard then
                folder:Destroy()
                return
            end
            for _, m in folder:GetDescendants() do
                if m:IsA("ParticleEmitter") then
                    m.Rate = 0
                elseif m:IsA("Part") and m.Transparency < 1 then
                    TweenService:Create(m, TweenInfo.new(1.4, Enum.EasingStyle.Sine), { Transparency = 1 }):Play()
                end
            end
            task.delay(2.2, function()
                pcall(function() folder:Destroy() end)
            end)
        end
        function puddlesRefresh()
            if pudActive() then
                startPuddles()
            else
                stopPuddles(false)
            end
        end
        function puddlesIntensity()
            if not _pud.conn then
                return
            end
            _fieldToken = _fieldToken + 1
            local token = _fieldToken
            task.delay(0.25, function()
                if token ~= _fieldToken then
                    return
                end
                _rebuild = true
            end)
        end
    end)()
    local function startClock()
        if _clockConn then return end
        local accum = 0
        _clockConn = RunService.Heartbeat:Connect(function(dt)
            accum = accum + dt
            if accum < 1 then return end
            accum = 0
            if not Config.Weather or not cfg("WeatherClockDial", false) then return end
            if Config.Visuals then return end
            local cycle = math.max(cfg("WeatherClockCycleMin", 8), 1) * 60
            local t = ((tick() % cycle) / cycle) * 24
            if math.abs(Lighting.ClockTime - t) > 0.02 then
                Lighting.ClockTime = t
            end
        end)
    end
    local function stopClock()
        if _clockConn then _clockConn:Disconnect(); _clockConn = nil end
    end
    local function normType(name)
        if name == "Rain" or name == "BloodMoon" or PRESETS[name] then
            return name
        end
        return "Rain"
    end
    local function applyType(name)
        name = normType(name)
        local prev = _curType
        stopRain(); clearSpecial()
        if #_partLayers > 0 then
            beginLayerFade()
        end
        _curType = name
        if name == "Rain" then
            buildRain(); startRain()
        elseif name == "BloodMoon" then
            buildBloodMoon(); startSpecialAnim()
        else
            local ramp = PRESETS[prev] ~= nil
            local ir = IR[name] or IR_DEF
            for _, spec in PRESETS[name] do
                mkPartLayer(spec, ir, ramp)
            end
        end
        if name == "Fireflies" then startFireflies() else stopFireflies() end
        applyMood(name)
        startAmbient(SOUND[name])
        puddlesRefresh()
    end
    function Weather.setType(name)
        name = normType(name)
        Config.WeatherType = name
        if Config.Weather then applyType(name) end
    end
    local _intensityToken = 0
    function Weather.setIntensity(v)
        Config.WeatherIntensity = math.clamp(v, 0.15, 2)
        if not Config.Weather then return end
        puddlesIntensity()
        local I = Config.WeatherIntensity
        for _, L in _partLayers do
            if L.emitter then
                pcall(tuneLayer, L, I)
                if L.rateTween then L.rateTween:Cancel(); L.rateTween = nil end
                pcall(function() L.emitter.Rate = layerRate(L, I) * L.rateMul end)
            end
        end
        if _special.kind == "BloodMoon" then pcall(tuneBloodMoon, I) end
        if _rays then
            pcall(function()
                _rays.Intensity = 0.10 + 0.18 * I
                _rays.Spread = 1.1 - 0.2 * I
            end)
        end
        _intensityToken = _intensityToken + 1
        local token = _intensityToken
        task.delay(0.12, function()
            if token ~= _intensityToken then return end
            if not Config.Weather then return end
            if _curType == "Rain" then pcall(tuneRain) end
            if _curType then pcall(applyMood, _curType) end
            pcall(refreshFireflies)
        end)
    end
    function Weather.setSoundVolume(v)
        Config.WeatherSoundVolume = v
        if _ambient then pcall(function() _ambient.Volume = v end) end
    end
    function Weather.toggleStorm(on)
        Config.WeatherStorm = on
        if not Config.Weather then return end
        if on then startStorm() else stopStormLoop() end
        puddlesRefresh()
    end
    function Weather.setStormMin(v)
        Config.WeatherStormMin = math.clamp(v, 1, 30)
        rescheduleStorm()
    end
    function Weather.setStormVar(v)
        Config.WeatherStormVar = math.clamp(v, 0, 30)
        rescheduleStorm()
    end
    function Weather.setMeteorRate(v)
        Config.WeatherMeteorRate = math.clamp(v, 0.25, 3)
        rescheduleMeteors()
    end
    function Weather.setStarRate(v)
        Config.WeatherStarRate = math.clamp(v, 0.25, 3)
        rescheduleStars()
    end
    function Weather.togglePuddles(on)
        Config.WeatherPuddles = on
        puddlesRefresh()
    end
    function Weather.toggleMood(on)
        Config.WeatherMood = on
        if Config.Weather and _curType then
            if on then applyMood(_curType) else clearMood() end
        end
    end
    function Weather.toggleMeteors(on)
        Config.WeatherMeteors = on
        if Config.Weather then if on then startMeteors() else stopMeteors() end end
    end
    function Weather.toggleShootingStars(on)
        Config.WeatherShootingStars = on
        if Config.Weather then if on then startStars() else stopStars() end end
    end
    function Weather.toggleClock(on)
        Config.WeatherClockDial = on
        if Config.Weather then if on then startClock() else stopClock() end end
    end
    function Weather.enableWeather()
        Config.Weather = true
        getFolder(); startFollow()
        applyType(cfg("WeatherType", "Rain"))
        if cfg("WeatherStorm", false) then startStorm() end
        if cfg("WeatherMeteors", false) then startMeteors() end
        if cfg("WeatherShootingStars", false) then startStars() end
        if cfg("WeatherClockDial", false) then startClock() end
    end
    function Weather.disableWeather()
        Config.Weather = false
        stopFollow(); stopStorm(); stopRain(); clearPartLayers(); killFade(); clearMood()
        clearSpecial(); stopMeteors(); stopStars(); stopFireflies(); stopLeafDevil(); stopClock()
        stopPuddles(true)
        if _ambient then pcall(function() _ambient:Destroy() end); _ambient = nil end
        _curType = nil
    end
    local SKY = {
        Space     = { Bk="rbxassetid://159454299", Dn="rbxassetid://159454296", Ft="rbxassetid://159454293", Lf="rbxassetid://159454286", Rt="rbxassetid://159454300", Up="rbxassetid://159454288" },
        Sunset    = { Bk="rbxassetid://264908339", Dn="rbxassetid://264907909", Ft="rbxassetid://264909420", Lf="rbxassetid://264909758", Rt="rbxassetid://264908886", Up="rbxassetid://264907379" },
        Clouds    = { Bk="rbxassetid://570557514", Dn="rbxassetid://570557775", Ft="rbxassetid://570557559", Lf="rbxassetid://570557620", Rt="rbxassetid://570557672", Up="rbxassetid://570557727" },
        Storm     = { Bk="rbxassetid://255027929", Dn="rbxassetid://255027967", Ft="rbxassetid://255027923", Lf="rbxassetid://255027938", Rt="rbxassetid://255027946", Up="rbxassetid://255027960" },
        Winter    = { Bk="rbxassetid://402229526", Dn="rbxassetid://402229596", Ft="rbxassetid://402229293", Lf="rbxassetid://402229368", Rt="rbxassetid://402229417", Up="rbxassetid://402229564" },
        Vaporwave = { Bk="rbxassetid://1417494030", Dn="rbxassetid://1417494146", Ft="rbxassetid://1417494253", Lf="rbxassetid://1417494402", Rt="rbxassetid://1417494499", Up="rbxassetid://1417494643" },
    }
    Weather.SkyboxOrder = { "Off", "Space", "Sunset", "Clouds", "Storm", "Winter", "Vaporwave" }
local ImportedSkyboxPresets = {
    ["None"] = {SkyboxBk="rbxassetid://14147881792",SkyboxDn="rbxassetid://14147882149",SkyboxFt="rbxassetid://14147882761",SkyboxLf="rbxassetid://14147883091",SkyboxRt="rbxassetid://14147882405",SkyboxUp="rbxassetid://14147881297"},
    Aurora = {SkyboxBk="rbxassetid://116533337330584",SkyboxDn="rbxassetid://80054106187171",SkyboxFt="rbxassetid://94459139270943",SkyboxLf="rbxassetid://116368999680791",SkyboxRt="rbxassetid://125758104196312",SkyboxUp="rbxassetid://107060226443967"},
    Battlerock = {SkyboxBk="rbxassetid://131136284306917",SkyboxDn="rbxassetid://89505977207531",SkyboxFt="rbxassetid://140099243548102",SkyboxLf="rbxassetid://121676169821100",SkyboxRt="rbxassetid://97183886241447",SkyboxUp="rbxassetid://107128620201556"},
    ["Beach Bowl"] = {SkyboxBk="rbxassetid://81804134601271",SkyboxDn="rbxassetid://92395364196932",SkyboxFt="rbxassetid://81804134601271",SkyboxLf="rbxassetid://81804134601271",SkyboxRt="rbxassetid://81804134601271",SkyboxUp="rbxassetid://119089964803065"},
    ["Buoy Base"] = {SkyboxBk="rbxassetid://135017685421888",SkyboxDn="rbxassetid://76610044495625",SkyboxFt="rbxassetid://89675413438577",SkyboxLf="rbxassetid://138307087837279",SkyboxRt="rbxassetid://136723547010707",SkyboxUp="rbxassetid://83404878914838"},
    Clockwork = {SkyboxBk="rbxassetid://86284761193226",SkyboxDn="rbxassetid://111425663631622",SkyboxFt="rbxassetid://115606366886873",SkyboxLf="rbxassetid://127287488325060",SkyboxRt="rbxassetid://126844150113423",SkyboxUp="rbxassetid://74510789204352"},
    ["Dark Matter"] = {SkyboxBk="rbxassetid://97629693450922",SkyboxDn="rbxassetid://97898396690232",SkyboxFt="rbxassetid://134755033418084",SkyboxLf="rbxassetid://118219143707956",SkyboxRt="rbxassetid://114940065588775",SkyboxUp="rbxassetid://95430908943263"},
    ["Flash Black"] = {SkyboxBk="rbxassetid://78426835654353",SkyboxDn="rbxassetid://6213218651",SkyboxFt="rbxassetid://71970982976722",SkyboxLf="rbxassetid://78426835654353",SkyboxRt="rbxassetid://78426835654353",SkyboxUp="rbxassetid://138004866371717"},
    Ghostly = {SkyboxBk="rbxassetid://111506743048183",SkyboxDn="rbxassetid://86198196348228",SkyboxFt="rbxassetid://86265514167302",SkyboxLf="rbxassetid://100257959405445",SkyboxRt="rbxassetid://71935101953120",SkyboxUp="rbxassetid://132011089223498"},
    ["Good Egg"] = {SkyboxBk="rbxassetid://94681381933012",SkyboxDn="rbxassetid://75843838469806",SkyboxFt="rbxassetid://97891957473259",SkyboxLf="rbxassetid://102971518965494",SkyboxRt="rbxassetid://94588890960775",SkyboxUp="rbxassetid://127368871569815"},
    ["Melty Molten"] = {SkyboxBk="rbxassetid://131463907527649",SkyboxDn="rbxassetid://116154164311420",SkyboxFt="rbxassetid://113077689016278",SkyboxLf="rbxassetid://79984367513909",SkyboxRt="rbxassetid://82395195737484",SkyboxUp="rbxassetid://117530106700350"},
    Shiverburn = {SkyboxBk="rbxassetid://113636030839991",SkyboxDn="rbxassetid://118027268179499",SkyboxFt="rbxassetid://76405010847029",SkyboxLf="rbxassetid://112044353352688",SkyboxRt="rbxassetid://121078604572355",SkyboxUp="rbxassetid://132486295432727"},
    ["Spin Dig"] = {SkyboxBk="rbxassetid://124211111366754",SkyboxDn="rbxassetid://120491795220431",SkyboxFt="rbxassetid://130119279111055",SkyboxLf="rbxassetid://70742671331562",SkyboxRt="rbxassetid://76516826791940",SkyboxUp="rbxassetid://100229310567751"},
    ["Sweet Mystery"] = {SkyboxBk="rbxassetid://107264897520277",SkyboxDn="rbxassetid://135637946277638",SkyboxFt="rbxassetid://135705252786048",SkyboxLf="rbxassetid://119667604517747",SkyboxRt="rbxassetid://75904303027092",SkyboxUp="rbxassetid://97011146822716"},
    ["Terrace Dome"] = {SkyboxBk="rbxassetid://98684100016510",SkyboxDn="rbxassetid://108354040356521",SkyboxFt="rbxassetid://95723629635852",SkyboxLf="rbxassetid://106269064939837",SkyboxRt="rbxassetid://136234415079744",SkyboxUp="rbxassetid://75385962780878"},
}

    for name,faces in pairs(ImportedSkyboxPresets)do
        local label=name=="None" and "Imported Default" or name
        SKY[label]={Bk=faces.SkyboxBk,Dn=faces.SkyboxDn,Ft=faces.SkyboxFt,Lf=faces.SkyboxLf,Rt=faces.SkyboxRt,Up=faces.SkyboxUp}
        Weather.SkyboxOrder[#Weather.SkyboxOrder+1]=label
    end

    local _sky, _skyConn = nil, nil
    local _origSkies = {}
    local function hideMapSkies()
        for _, c in ipairs(Lighting:GetChildren()) do
            if c:IsA("Sky") and not c:GetAttribute("WX_Custom") then
                table.insert(_origSkies, c)
                pcall(function() c.Parent = nil end)
            end
        end
    end
    local function restoreMapSkies()
        for i = #_origSkies, 1, -1 do
            local c = _origSkies[i]
            if c and c.Parent == nil then
                pcall(function() c.Parent = Lighting end)
            end
            _origSkies[i] = nil
        end
    end
    local function buildSky(preset)
        local set = SKY[preset]; if not set then return end
        hideMapSkies()
        local s = Instance.new("Sky")
        s.Name = "_wxSky"; s:SetAttribute("WX_Custom", true)
        s.SkyboxBk, s.SkyboxDn, s.SkyboxFt = set.Bk, set.Dn, set.Ft
        s.SkyboxLf, s.SkyboxRt, s.SkyboxUp = set.Lf, set.Rt, set.Up
        if cfg("SkyboxHideCelestial", false) then
            s.SunAngularSize = 0; s.MoonAngularSize = 0; s.StarCount = 0
            s.CelestialBodiesShown = false
        else
            s.CelestialBodiesShown = true
        end
        s.Parent = Lighting
        _sky = s
    end
    local function startSkyGuard()
        if _skyConn then return end
        _skyConn = Lighting.ChildAdded:Connect(function(c)
            if c:IsA("Sky") and not c:GetAttribute("WX_Custom") and Config.SkyboxPreset and Config.SkyboxPreset ~= "Off" then
                table.insert(_origSkies, c)
                pcall(function() c.Parent = nil end)
            end
        end)
    end
    local function stopSkyGuard()
        if _skyConn then _skyConn:Disconnect(); _skyConn = nil end
    end
    local function clearSky()
        if _sky then pcall(function() _sky:Destroy() end); _sky = nil end
        restoreMapSkies()
    end
    function Weather.setSkybox(preset)
        if preset and not SKY[preset] then preset = "Off" end
        Config.SkyboxPreset = preset
        clearSky()
        if preset == "Off" or preset == nil then stopSkyGuard(); return end
        buildSky(preset); startSkyGuard()
    end
    function Weather.toggleCelestial(hide)
        Config.SkyboxHideCelestial = hide
        if _sky then
            if hide then
                _sky.SunAngularSize = 0; _sky.MoonAngularSize = 0; _sky.StarCount = 0
                _sky.CelestialBodiesShown = false
            else
                _sky.SunAngularSize = 11; _sky.MoonAngularSize = 11; _sky.StarCount = 3000
                _sky.CelestialBodiesShown = true
            end
        end
    end
    local _rainbow = { host = nil, conn = nil }
    local RB_BANDS = {
        { Color3.fromRGB(255, 40, 40),  0.10, 24 },
        { Color3.fromRGB(255, 130, 20), 0.12, 24 },
        { Color3.fromRGB(255, 225, 40), 0.14, 24 },
        { Color3.fromRGB(60, 210, 70),  0.16, 24 },
        { Color3.fromRGB(40, 130, 255), 0.18, 24 },
        { Color3.fromRGB(85, 60, 235),  0.26, 18 },
        { Color3.fromRGB(165, 65, 230), 0.30, 16 },
    }
    local RB_DIST, RB_OY = 430, -20
    local function clearRainbow()
        if _rainbow.conn then _rainbow.conn:Disconnect(); _rainbow.conn = nil end
        if _rainbow.host then pcall(function() _rainbow.host:Destroy() end); _rainbow.host = nil end
    end
    local function buildRainbow()
        local host = Instance.new("Part")
        host.Name = "_wxRainbow"; host.Anchored = true; host.CanCollide = false; host.CanQuery = false
        host.CanTouch = false; host.CastShadow = false; host.Massless = true; host.Transparency = 1
        host.Size = Vec(1, 1, 1); host:SetAttribute("WX_Custom", true)
        local rot = CFrame.Angles(0, 0, math.rad(90))
        local function band(sp, rr, w, col, midT, emit, soft)
            local a0 = Instance.new("Attachment"); a0.CFrame = CFrame.new(-sp, 0, 0) * rot; a0.Parent = host
            local a1 = Instance.new("Attachment"); a1.CFrame = CFrame.new( sp, 0, 0) * rot; a1.Parent = host
            local b = Instance.new("Beam")
            b.Attachment0 = a0; b.Attachment1 = a1; b.Segments = 46; b.FaceCamera = true
            if soft then b.Texture = TX_SOFT; b.TextureMode = Enum.TextureMode.Stretch; b.TextureLength = 1 end
            b.Width0 = w; b.Width1 = w; b.CurveSize0 = rr; b.CurveSize1 = -rr
            b.LightEmission = emit; b.LightInfluence = 0
            b.Color = ColorSequence.new(col)
            local edge = math.min(midT + 0.25, 1)
            b.Transparency = NumberSequence.new({
                NSK(0, 1), NSK(0.08, edge), NSK(0.45, midT), NSK(0.55, midT), NSK(0.92, edge), NSK(1, 1) })
            b.Parent = host
        end
        for i = 1, #RB_BANDS do
            local B = RB_BANDS[i]
            band(340, 320 - (i - 1) * 15, B[3], B[1], B[2], 0.42, false)
        end
        band(340, 165, 52, Color3.fromRGB(242, 248, 255), 0.78, 0.6, true)
        for i = 1, #RB_BANDS do
            band(400, 355 + (i - 1) * 12, 20, RB_BANDS[i][1], 0.64 + i * 0.012, 0.42, false)
        end
        host.Parent = getFolder()
        _rainbow.host = host
    end
    local function startRainbowFollow()
        if _rainbow.conn then return end
        local accum = 0
        _rainbow.conn = RunService.Heartbeat:Connect(function(dt)
            if not cfg("WeatherRainbow", false) then return end
            accum = accum + dt; if accum < 0.08 then return end
            accum = 0
            local cam = Camera; if not cam then return end
            local host = _rainbow.host; if not host or not host.Parent then return end
            local p = cam.CFrame.Position
            local hp = Vec(p.X, p.Y + RB_OY, p.Z - RB_DIST)
            host.CFrame = CFrame.lookAt(hp, Vec(p.X, hp.Y, p.Z))
        end)
    end
    function Weather.toggleRainbow(on)
        Config.WeatherRainbow = on
        clearRainbow()
        if not on then return end
        buildRainbow(); startRainbowFollow()
    end
    function Weather.toggleGodRays(on)
        Config.WeatherGodRays = on
        if _rays then pcall(function() _rays:Destroy() end); _rays = nil end
        if not on then return end
        local r = Instance.new("SunRaysEffect")
        r.Name = "_wxRays"; r:SetAttribute("WX_Custom", true)
        local I = iAmt()
        r.Intensity = 0.10 + 0.18 * I
        r.Spread = 1.1 - 0.2 * I
        r.Parent = Lighting
        _rays = r
    end
    function Weather.init()
        if Config.Weather then pcall(Weather.enableWeather) end
        if Config.SkyboxPreset and Config.SkyboxPreset ~= "Off" then pcall(Weather.setSkybox, Config.SkyboxPreset) end
        if Config.WeatherGodRays then pcall(Weather.toggleGodRays, true) end
        if Config.WeatherRainbow then pcall(Weather.toggleRainbow, true) end
    end
    function Weather.unload()
        pcall(Weather.disableWeather)
        stopSkyGuard(); clearSky(); clearRainbow()
        if _rays then pcall(function() _rays:Destroy() end); _rays = nil end
        if _folder then pcall(function() _folder:Destroy() end); _folder = nil end
        _lightFolder = nil
    end
end)()

local GameVisuals = {}
GameVisuals.uiAlive = true
;(function()
    local NONE_COSMETIC   = "NONE_COSMETIC"
    local RANDOM_COSMETIC = "RANDOM_COSMETIC"
    local POLL_S = 0.35
    local REBUILD_COOLDOWN = 1.5
    local captureInstall, captureRestore
    local saveSoon, saveDrain
    local _log, _lastNote = {}, nil
    local function note(msg)
        State.GVStatus = msg
        if msg == _lastNote then return end
        _lastNote = msg
        table.insert(_log, os.date("%H:%M:%S") .. "  " .. msg)
        if #_log > 60 then table.remove(_log, 1) end
    end
    function GameVisuals.history(n)
        local out = {}
        local want = n or 12
        for i = #_log, math.max(1, #_log - want + 1), -1 do table.insert(out, _log[i]) end
        if #out == 0 then table.insert(out, "nothing yet") end
        return out
    end
    local ENUM = {}
    local function enumOf(key)
        if ENUM[key] ~= nil then return ENUM[key] end
        local e = nil
        pcall(function() e = Rivals.Enums:ToEnum(key) end)
        ENUM[key] = e
        return e
    end
    local M = { cvm = nil, ci = nil, pdc = nil, fctrl = nil, ilib = nil, cent = nil,
                cslot = nil, copts = nil, shop = nil }
    local function moduleAt(path)
        local m = nil
        pcall(function() m = loadGameModule(lp.PlayerScripts, path) end)
        return m
    end
    local function repModuleAt(path)
        local m = nil
        pcall(function() m = loadGameModule(ReplicatedStorage, path) end)
        return m
    end
    local _resolving, _resolveAt, _optTries = false, 0, 0
    local function resolveModules()
        if _resolving then return end
        local now = tick()
        if now < _resolveAt then return end
        _resolveAt = now + 5
        _resolving = true
        if M.cvm == nil then
            M.cvm = moduleAt({"Modules","ClientReplicatedClasses","ClientFighter","ClientItem","ClientViewModel"})
        end
        if M.ci   == nil then M.ci   = moduleAt({"Modules","ClientReplicatedClasses","ClientFighter","ClientItem"}) end
        if M.cent == nil then M.cent = moduleAt({"Modules","ClientReplicatedClasses","ClientEntity"}) end
        if M.pdc  == nil then M.pdc  = moduleAt({"Controllers","PlayerDataController"}) end
        if _optTries < 3 or M.seasonLib == nil or M.cslot == nil or M.copts == nil then
            _optTries = _optTries + 1
            if M.cslot == nil then M.cslot = moduleAt({"Modules","CosmeticSlot"}) end
            if M.copts == nil then
                M.copts = moduleAt({"Modules","UserInterface","Equipment","Interface","Customize","Options"})
            end
            if M.shop  == nil then M.shop  = repModuleAt({"Modules","ShopLibrary"}) end
            if M.seasonLib == nil then M.seasonLib = repModuleAt({"Modules","SeasonLibrary"}) end
            if M.emoteCtl == nil then M.emoteCtl = moduleAt({"Controllers","EmoteController"}) end
        end
        if M.fctrl == nil then M.fctrl = Rivals.Fighter end
        if M.ilib  == nil then M.ilib  = Rivals.ItemLib end
        _resolving = false
    end
    GameVisuals.Choices = {}
    GameVisuals.InventoryVisibility = {}
    GameVisuals.WeaponVisibility = {}
    local function selectionFor(itemName)
        return GameVisuals.Choices[itemName]
    end
    local _maskTarget, _maskInner, _maskConn = nil, nil, nil
    local _spoof = {}
    local _favOverride = {}
    local _rsPatch, _captured, _captureBound = {}, 0, 0
    local DECOY, _lastFn = nil, nil
    local _saveAt, _fsWarned = nil, false
    local function maskActive()
        if _maskTarget == nil then return false end
        local cur = nil
        pcall(function() cur = M.pdc.CurrentData end)
        return cur == _maskTarget
    end
    local function maskRemove()
        if _maskTarget == nil then return end
        local target, inner = _maskTarget, _maskInner
        _maskTarget, _maskInner = nil, nil
        pcall(function() rawset(target, "Data", inner) end)
    end
    local function maskInstall()
        resolveModules()
        if M.pdc == nil then return false, "PlayerDataController did not resolve" end
        local cur = nil
        pcall(function() cur = M.pdc.CurrentData end)
        if cur == nil then return false, "no CurrentData yet (still loading)" end
        if cur == _maskTarget then return true, nil end
        maskRemove()
        local inner = rawget(cur, "Data")
        if type(inner) ~= "table" then return false, "CurrentData.Data is not a table" end
        local proxy = setmetatable({}, {
            __index = function(_, k)
                local p = _spoof[k]
                if p ~= nil then return p(inner[k]) end
                return inner[k]
            end,
            __newindex = function(_, k, v) inner[k] = v end,
            __iter = function() return next, inner end,
            __len  = function() return #inner end,
        })
        rawset(cur, "Data", proxy)
        _maskTarget, _maskInner = cur, inner
        return true, nil
    end
    local function refresh(key)
        pcall(function()
            local cur = M.pdc.CurrentData
            if cur ~= nil then cur:Replicate(key) end
        end)
    end
    local function refreshAll()
        refresh("CosmeticInventory")
        refresh("FavoritedCosmetics")
        refresh("WeaponInventory")
        refresh("EquippedEmotes")
    end
    local function everyCosmetic(real)
        local out = {}
        if type(real) == "table" then
            for k, v in pairs(real) do out[k] = v end
        end
        pcall(function()
            local cos = Rivals.Cosmetics.Cosmetics
            if type(cos) ~= "table" then return end
            for name, entry in pairs(cos) do
                if Config.GVUnlockAll and type(entry) == "table" and out[name] == nil then out[name] = true end
            end
        end)
        for name,shown in pairs(GameVisuals.InventoryVisibility) do
            if shown then out[name]=true else out[name]=nil end
        end
        return out
    end
    local function everyFavorite(real)
        local out = {}
        if type(real) == "table" then
            for k, v in pairs(real) do out[k] = v end
        end
        for weapon, marks in pairs(_favOverride) do
            local merged = {}
            if type(out[weapon]) == "table" then
                for k, v in pairs(out[weapon]) do merged[k] = v end
            end
            for k, v in pairs(marks) do merged[k] = v end
            out[weapon] = merged
        end
        return out
    end
    local function mergeChoices(entry, weapon)
        local slot = GameVisuals.Choices[weapon]
        if slot == nil then return entry end
        for _, kind in pairs({ "Skin", "Charm", "Wrap", "Finisher" }) do
            local sel = slot[kind]
            if sel ~= nil then
                if sel.Name == NONE_COSMETIC then
                    entry[kind] = nil
                elseif sel.Name == RANDOM_COSMETIC then
                    entry[kind] = sel
                else
                    entry[kind] = sel
                end
            end
        end
        return entry
    end
    local function ownableWeapons()
        local out = {}
        pcall(function()
            if M.shop == nil or type(M.shop.GetReleasedOwnableWeapons) ~= "function" then return end
            local list = M.shop:GetReleasedOwnableWeapons()
            if type(list) ~= "table" then return end
            for _, name in pairs(list) do
                if type(name) == "string" then table.insert(out, name) end
            end
        end)
        return out
    end
    local function weaponInventory(real)
        local out, seen = {}, {}
        if type(real) == "table" then
            for i, entry in pairs(real) do
                if type(entry) == "table" then
                    local copy = {}
                    for k, v in pairs(entry) do copy[k] = v end
                    if type(copy.Name) == "string" then
                        seen[copy.Name] = true
                        mergeChoices(copy, copy.Name)
                    end
                    out[i] = copy
                else
                    out[i] = entry
                end
            end
        end
        if Config.GVUnlockWeapons == true then
            for _, wname in pairs(ownableWeapons()) do
                if not seen[wname] then
                    seen[wname] = true
                    table.insert(out, mergeChoices(
                        { Name = wname, Level = 1, XP = 0, IsFavorited = false }, wname))
                end
            end
        end
        local filtered={}
        for _,entry in pairs(out)do
            if type(entry)~="table"or GameVisuals.WeaponVisibility[entry.Name]~=false then
                filtered[#filtered+1]=entry
            end
        end
        for name,visible in pairs(GameVisuals.WeaponVisibility)do
            if visible and not seen[name] then
                filtered[#filtered+1]=mergeChoices({Name=name,Level=1,XP=0,IsFavorited=false},name)
            end
        end
        return filtered
    end
    local _emoteNames = nil
    local function emoteNames()
        if _emoteNames ~= nil then return _emoteNames end
        local out = {}
        pcall(function()
            local mods = ReplicatedStorage:FindFirstChild("Modules")
            local folder = mods and mods:FindFirstChild("Emotes")
            local cos = Rivals.Cosmetics and Rivals.Cosmetics.Cosmetics
            if folder == nil or type(cos) ~= "table" then return end
            for _, node in ipairs(folder:GetChildren()) do
                local e = cos[node.Name]
                if type(e) == "table" and e.Type == "Emote" then table.insert(out, node.Name) end
            end
        end)
        table.sort(out)
        _emoteNames = out
        return out
    end
    local function equippedEmotes(real)
        if Config.GVEmotes ~= true then return real end
        local names = emoteNames()
        if #names == 0 then return real end
        local out = {}
        if type(real) == "table" then
            for k, v in pairs(real) do out[k] = v end
        end
        local nexti = 1
        for slot = 1, 8 do
            local k = tostring(slot)
            if out[k] == nil then
                out[k] = { Name = names[nexti] }
                nexti = nexti + 1
                if nexti > #names then break end
            end
        end
        return out
    end
    local function applyMaskFields()
        if Config.GVUnlockAll == true or next(GameVisuals.InventoryVisibility)~=nil then
            _spoof.CosmeticInventory = everyCosmetic
        else
            _spoof.CosmeticInventory = nil
        end
        if Config.GVUnlockAll == true or next(_favOverride) ~= nil then
            _spoof.FavoritedCosmetics = everyFavorite
        else
            _spoof.FavoritedCosmetics = nil
        end
        if next(GameVisuals.Choices) ~= nil or Config.GVUnlockWeapons == true or next(GameVisuals.WeaponVisibility)~=nil then
            _spoof.WeaponInventory = weaponInventory
        else
            _spoof.WeaponInventory = nil
        end
        if Config.GVEmotes == true then
            _spoof.EquippedEmotes = equippedEmotes
        else
            _spoof.EquippedEmotes = nil
        end
    end
    local function maskNeeded()
        return next(GameVisuals.InventoryVisibility)~=nil or next(GameVisuals.WeaponVisibility)~=nil
            or Config.GVUnlockAll == true or Config.GVUnlockWeapons == true
            or Config.GVEmotes == true
            or next(GameVisuals.Choices) ~= nil or next(_favOverride) ~= nil
    end
    local function watchPlayerData()
        if _maskConn ~= nil then return end
        pcall(function()
            local sig = M.pdc.PlayerDataAdded
            if sig == nil then return end
            _maskConn = sig:Connect(function()
                if not maskNeeded() then return end
                task.defer(function()
                    if maskInstall() then
                        applyMaskFields()
                        refreshAll()
                    end
                end)
            end)
        end)
    end
    local function syncMask()
        applyMaskFields()
        if not maskNeeded() then
            maskRemove()
            refreshAll()
            return true, nil
        end
        local ok, why = maskInstall()
        if not ok then return false, why end
        watchPlayerData()
        refreshAll()
        return true, nil
    end
    function GameVisuals.setInventoryVisibility(names,shown)
        if names==nil then table.clear(GameVisuals.InventoryVisibility)
        else for _,name in ipairs(names)do GameVisuals.InventoryVisibility[name]=shown end end
        local ok,why=syncMask()
        if not ok then note("Catalog display: "..tostring(why))end
    end
    function GameVisuals.setWeaponVisibility(name,shown)
        if name==nil then table.clear(GameVisuals.WeaponVisibility)
        else
            local valid=false
            for _,known in pairs(ownableWeapons())do if known==name then valid=true;break end end
            if not valid then note("Unknown or unloaded weapon: "..tostring(name));notify(State.GVStatus);return end
            GameVisuals.WeaponVisibility[name]=shown
        end
        local ok,why=syncMask()
        if not ok then note("Weapon display: "..tostring(why))end
    end
    function GameVisuals.setUnlockAll(on)
        Config.GVUnlockAll = (on == true)
        local ok, why = syncMask()
        if ok then
            note("unlock all " .. tostring(Config.GVUnlockAll))
        else
            note("unlock all: " .. tostring(why))
        end
    end
    function GameVisuals.syncEmotes(on)
        Config.GVEmotes = (on == true)
        pcall(syncMask)
    end
    function GameVisuals.setUnlockWeapons(on)
        Config.GVUnlockWeapons = (on == true)
        local ok, why = syncMask()
        if ok then
            note("unlock weapons " .. tostring(Config.GVUnlockWeapons))
        else
            note("unlock weapons: " .. tostring(why))
        end
    end
    local function charmMetadata(charmName)
        if type(charmName) ~= "string" or string.match(charmName, "^Season %d+$") == nil then return nil end
        return (GameVisuals.seasonMetadata and GameVisuals.seasonMetadata(charmName)) or GameVisuals.resolveRankStamp()
    end
    local function cloneCosmetic(name, ctype, inverted)
        local base = nil
        pcall(function() base = Rivals.Cosmetics.Cosmetics[name] end)
        if type(base) ~= "table" then return nil end
        local data = {}
        for k, v in pairs(base) do data[k] = v end
        data.Name = name
        if data.Type == nil then data.Type = ctype end
        data.Seed = math.random(1, 1000000)
        local id = enumOf(name)
        if id ~= nil then
            data.Enum     = id
            data.ObjectID = id
        end
        if inverted == true then data.Inverted = true end
        if ctype == "Charm" then
            local md = charmMetadata(name)
            if md ~= nil then data.Metadata = md end
        end
        return data
    end
    local function rankOverrideRecord(liveCharm)
        local nm = nil
        if type(liveCharm) == "table" then nm = liveCharm.Name end
        local want = charmMetadata(nm)
        if want == nil then return nil end
        local have = (type(liveCharm) == "table") and liveCharm.Metadata or nil
        if have ~= nil and have.SeasonELO == want.SeasonELO
            and have.SeasonLeaderboardRank == want.SeasonLeaderboardRank then
            return nil
        end
        return cloneCosmetic(nm, "Charm")
    end
    local function randomCosmetic(ctype, weapon, inverted)
        local pool = {}
        pcall(function()
            local cos = Rivals.Cosmetics.Cosmetics
            local inv = M.pdc and M.pdc:Get("CosmeticInventory")
            if type(cos) ~= "table" then return end
            for name, entry in pairs(cos) do
                if type(entry) == "table" and entry.Type == ctype and entry.Hidden ~= true then
                    local owned = true
                    pcall(function() owned = Rivals.Cosmetics:OwnsCosmetic(inv, name, weapon) and true or false end)
                    if owned and (ctype ~= "Skin" or entry.ItemName == weapon) then
                        table.insert(pool, name)
                    end
                end
            end
        end)
        if #pool == 0 then return nil end
        return cloneCosmetic(pool[math.random(#pool)], ctype, inverted)
    end
    local function resolveSel(weapon, ctype)
        local slot = GameVisuals.Choices[weapon]
        local sel = slot and slot[ctype]
        if sel == nil then return nil end
        if sel.Name == NONE_COSMETIC then return nil end
        if sel.Name == RANDOM_COSMETIC then
            if sel.Resolved == nil then
                sel.Resolved = randomCosmetic(ctype, weapon, sel.Inverted)
            end
            return sel.Resolved
        end
        return sel
    end
    local function hasIntent(weapon, ctype)
        local slot = GameVisuals.Choices[weapon]
        return slot ~= nil and slot[ctype] ~= nil
    end
    local function buildPayload(weapon, dst, key)
        if hasIntent(weapon, "Skin") then
            local s = resolveSel(weapon, "Skin")
            dst[key("Name")] = (s ~= nil) and s.Name or weapon
        end
        if hasIntent(weapon, "Wrap") then
            dst[key("Wrap")] = resolveSel(weapon, "Wrap")
        end
        if hasIntent(weapon, "Charm") then
            dst[key("Charm")] = resolveSel(weapon, "Charm")
        end
        return dst
    end
    local function identityKey(k) return k end
    local HOOKS = {}
    local function hookField(tbl, key, make)
        if tbl == nil then return false end
        local orig = nil
        pcall(function() orig = tbl[key] end)
        if type(orig) ~= "function" then return false end
        for _, h in pairs(HOOKS) do
            if h.tbl == tbl and h.key == key then return true end
        end
        local inherited = false
        pcall(function() inherited = (rawget(tbl, key) == nil) end)
        local ok = false
        pcall(function()
            tbl[key] = make(orig)
            ok = true
        end)
        if not ok then return false end
        table.insert(HOOKS, { tbl = tbl, key = key, orig = orig, inherited = inherited })
        return true
    end
    local function hooksRestore()
        for i = #HOOKS, 1, -1 do
            local h = HOOKS[i]
            pcall(function()
                if h.inherited then
                    h.tbl[h.key] = nil
                else
                    h.tbl[h.key] = h.orig
                end
            end)
            HOOKS[i] = nil
        end
    end
    local function origOf(tbl, key)
        if tbl == nil then return nil end
        for _, h in pairs(HOOKS) do
            if h.tbl == tbl and h.key == key then return h.orig end
        end
        local fn = nil
        pcall(function() fn = tbl[key] end)
        return fn
    end
    local function ownedByUs(item)
        local owner = nil
        pcall(function() owner = item.ClientFighter.Player end)
        if owner == lp then return true end
        if Config.GVEveryone == true and owner ~= nil then return true end
        return false
    end
    local function enumKey(k)
        local e = enumOf(k)
        if e ~= nil then return e end
        return k
    end
    local function styleSerial(serial, weapon)
        if type(serial) ~= "table" or type(weapon) ~= "string" then return false end
        if selectionFor(weapon) == nil then return false end
        local touched = false
        pcall(function()
            local dk = enumOf("Data")
            local slot = nil
            if dk ~= nil and type(serial[dk]) == "table" then
                slot = serial[dk]
            elseif type(serial.Data) == "table" then
                slot = serial.Data
            end
            if slot == nil then return end
            buildPayload(weapon, slot, enumKey)
            touched = true
        end)
        return touched
    end
    local _building = nil
    local _oidWeapon, _oidAt = {}, 0
    local function atIdentity2(fn)
        local prev = 8
        if getthreadidentity ~= nil then pcall(function() prev = getthreadidentity() end) end
        local setter = setthreadidentity
        if setter == nil then setter = setidentity end
        if setter ~= nil then pcall(setter, 2) end
        local ok, err = pcall(fn)
        if setter ~= nil then pcall(setter, prev) end
        return ok, err
    end
    local FINISHER_FOLDER = nil
    local function finisherFolder()
        if FINISHER_FOLDER == nil then
            pcall(function() FINISHER_FOLDER = ReplicatedStorage.Modules.Finishers end)
        end
        return FINISHER_FOLDER
    end
    local function cloneCharacter(model)
        local copy = nil
        pcall(function()
            local was = model.Archivable
            model.Archivable = true
            copy = model:Clone()
            model.Archivable = was
        end)
        return copy
    end
    local function hideCorpse(model)
        pcall(function()
            for _, d in pairs(model:GetDescendants()) do
                if d:IsA("BasePart") then d.Transparency = 1
                elseif d:IsA("Decal") then d:Destroy()
                elseif d:IsA("BillboardGui") then d.Enabled = false end
            end
        end)
    end
    local _finisherCopies = setmetatable({}, { __mode = "k" })
    local function playFinisherOnClone(ent, model, mod, isFinal, killer, serial)
        local copy = cloneCharacter(model)
        if copy == nil then return false end
        local hum, root = nil, nil
        pcall(function()
            hum  = copy:FindFirstChildOfClass("Humanoid")
            root = copy:FindFirstChild("HumanoidRootPart")
        end)
        if hum == nil or root == nil then
            pcall(function() copy:Destroy() end)
            return false
        end
        hideCorpse(model)
        pcall(function()
            for _, d in pairs(copy:GetDescendants()) do
                if d:IsA("BillboardGui") or d:IsA("SurfaceGui") or d:IsA("Highlight") then d:Destroy() end
            end
        end)
        local ok = false
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.zero
            hum.Health = 0
            local parts = {}
            for _, c in pairs(copy:GetChildren()) do
                if c:IsA("BasePart") then
                    pcall(function() c.CollisionGroup = "Players" end)
                    table.insert(parts, c)
                end
            end
            for i = 1, #parts do
                for j = i + 1, #parts do
                    local nc = Instance.new("NoCollisionConstraint")
                    nc.Part0 = parts[i]
                    nc.Part1 = parts[j]
                    nc.Parent = parts[i]
                end
            end
            copy:PivotTo(model:GetPivot())
            copy.Parent = model.Parent
            ok = true
        end)
        if not ok then
            pcall(function() copy:Destroy() end)
            return false
        end
        pcall(function()
            model.Destroying:Once(function()
                if copy.Parent ~= nil then copy:Destroy() end
            end)
        end)
        local prevCopy = rawget(_finisherCopies, ent)
        if prevCopy ~= nil and prevCopy ~= copy and prevCopy.Parent ~= nil then
            pcall(function() prevCopy:Destroy() end)
        end
        rawset(_finisherCopies, ent, copy)
        local fin = nil
        atIdentity2(function()
            local prev = rawget(ent, "_current_finisher")
            if prev ~= nil then pcall(prev.Destroy, prev) end
            fin = mod.new(hum, isFinal, killer)
            rawset(ent, "_current_finisher", fin)
            fin:SetSerial(serial)
            task.spawn(function() pcall(fin.PlayClient, fin) end)
        end)
        if fin == nil then
            pcall(function() copy:Destroy() end)
            return false
        end
        return true
    end
    local function reallyOwnsEmote(name)
        local inv = nil
        pcall(function()
            if _maskInner ~= nil then inv = _maskInner.CosmeticInventory end
        end)
        if type(inv) ~= "table" then return false end
        local owned = false
        pcall(function() owned = Rivals.Cosmetics:OwnsCosmetic(inv, name) == true end)
        return owned
    end
    local function localEntity()
        local ent = nil
        pcall(function()
            local f = Rivals.Fighter:GetFighter(lp)
            ent = f and f.Entity
        end)
        return ent
    end
    local function armEmoteCancel(ent, obj, oid, hum)
        task.spawn(function()
            local origin = nil
            pcall(function()
                local rp = hum.RootPart
                if rp ~= nil then origin = rp.Position end
            end)
            local shots0 = State.Shots or 0
            local t0 = tick()
            while tick() - t0 < 600 do
                task.wait(0.2)
                if rawget(ent, "_current_emote") ~= obj then return end
                local dead, moved = false, false
                pcall(function() dead = hum.Health <= 0 end)
                pcall(function()
                    local rp = hum.RootPart
                    moved = (rp ~= nil and origin ~= nil and (rp.Position - origin).Magnitude >= 4)
                end)
                local fired = (State.Shots or 0) ~= shots0
                local expired = (type(obj.Lifetime) == "number") and (tick() - t0 > obj.Lifetime + 0.5)
                if dead or moved or fired or expired then
                    local delay = 0.15
                    pcall(function() delay = math.max(lp:GetNetworkPing(), 0.05) end)
                    task.delay(delay, function()
                        pcall(function() ent:CancelEmote(oid) end)
                    end)
                    return
                end
            end
        end)
    end
    local function localPlayEmote(name)
        local ent = localEntity()
        if ent == nil then return false end
        local hum = nil
        pcall(function() hum = ent.Humanoid end)
        if hum == nil then return false end
        local alive = true
        pcall(function() alive = hum.Health > 0 end)
        if not alive then return false end
        local node = nil
        pcall(function()
            local mods = ReplicatedStorage:FindFirstChild("Modules")
            local folder = mods and mods:FindFirstChild("Emotes")
            node = folder and folder:FindFirstChild(name)
        end)
        if node == nil then return false end
        pcall(function() ent:CancelEmote(nil) end)
        local ok = false
        atIdentity2(function()
            ok = pcall(function()
                local obj = require(node).new(hum)
                local oid = "LH" .. tostring(math.random(100000000, 999999999))
                obj:SetSerial({ ObjectID = oid, Name = name, Seed = math.random(1, 1000000) })
                rawset(ent, "_current_emote", obj)
                pcall(function() ent.EmoteStatusChanged:Fire() end)
                task.spawn(function() pcall(obj.PlayClient, obj) end)
                armEmoteCancel(ent, obj, oid, hum)
            end)
        end)
        return ok
    end
    function GameVisuals.emoteList()
        local out = { "None" }
        for _, name in ipairs(emoteNames()) do out[#out + 1] = name end
        return out
    end
    function GameVisuals.playEmote(name)
        if type(name) ~= "string" or name == "" or name == "None" then return end
        if Config.GVEmotes ~= true then
            note("turn on 'Unlock emotes' first")
            return
        end
        if not localPlayEmote(name) then
            note("emote unavailable: " .. name .. " (in a round? alive?)")
        end
    end
    local function hooksInstall()
        resolveModules()
        if Config.GVBirthHook == false then return false, "birth hook disabled in config" end
        local n = 0
        if hookField(M.ci, "_CreateViewModel", function(orig)
            return function(item, serial)
                local weapon = nil
                pcall(function() weapon = item.Name end)
                local mine = ownedByUs(item)
                _building = mine and weapon or nil
                if mine and weapon ~= nil then pcall(styleSerial, serial, weapon) end
                local ok, res = pcall(orig, item, serial)
                _building = nil
                if not ok then error(res, 0) end
                return res
            end
        end) then n = n + 1 end
        if hookField(M.cvm, "new", function(orig)
            return function(serial, item)
                local weapon = _building
                if weapon == nil and item ~= nil then
                    pcall(function() if ownedByUs(item) then weapon = item.Name end end)
                end
                if weapon ~= nil then pcall(styleSerial, serial, weapon) end
                local vm = orig(serial, item)
                if vm ~= nil and weapon ~= nil and resolveSel(weapon, "Wrap") ~= nil then
                    local upd = nil
                    pcall(function() upd = M.cvm._UpdateWrap end)
                    if type(upd) == "function" then
                        task.spawn(function()
                            pcall(upd, vm)
                            task.wait(0.1)
                            if rawget(vm, "_destroyed") ~= true then pcall(upd, vm) end
                        end)
                    end
                end
                return vm
            end
        end) then n = n + 1 end
        if hookField(M.cvm, "GetWrap", function(orig)
            return function(vm)
                local weapon, mine = nil, false
                pcall(function()
                    local item = vm.ClientItem
                    weapon = item.Name
                    mine = ownedByUs(item)
                end)
                if mine and weapon ~= nil and hasIntent(weapon, "Wrap") then
                    return resolveSel(weapon, "Wrap")
                end
                return orig(vm)
            end
        end) then n = n + 1 end
        if hookField(M.fctrl, "GetWrap", function(orig)
            return function(ctrl, oid)
                local res = orig(ctrl, oid)
                if res ~= nil then return res end
                local weapon = _oidWeapon and _oidWeapon[tostring(oid)] or nil
                if weapon == nil then return nil end
                return resolveSel(weapon, "Wrap")
            end
        end) then n = n + 1 end
        if hookField(M.ilib, "GetViewModelImageFromWeaponData", function(orig)
            return function(lib, wdata, hires)
                if type(wdata) == "table" and type(wdata.Name) == "string" then
                    local skin = resolveSel(wdata.Name, "Skin")
                    if skin ~= nil then
                        local img = nil
                        pcall(function()
                            local info = lib.ViewModels[skin.Name]
                            if info ~= nil then
                                img = hires and info.ImageHighResolution or info.Image
                                if img == nil then img = info.Image end
                            end
                        end)
                        if img ~= nil then return img end
                    end
                end
                return orig(lib, wdata, hires)
            end
        end) then n = n + 1 end
        if hookField(M.emoteCtl, "UseEmoteByName", function(orig)
            return function(self, name)
                if Config.GVEmotes == true and type(name) == "string"
                    and not reallyOwnsEmote(name) and localPlayEmote(name) then
                    return
                end
                return orig(self, name)
            end
        end) then n = n + 1 end
        if hookField(M.emoteCtl, "EquipEmote", function(orig)
            return function(self, slot, name)
                if Config.GVEmotes == true and type(name) == "string"
                    and not reallyOwnsEmote(name) then
                    return
                end
                return orig(self, slot, name)
            end
        end) then n = n + 1 end
        if hookField(M.cent, "ReplicateFromServer", function(orig)
            return function(ent, action, ...)
                if action ~= "FinisherEffect" then return orig(ent, action, ...) end
                local args = { ... }
                local killer = args[3]
                local isUs = false
                pcall(function()
                    if typeof(killer) == "Instance" then isUs = (killer == lp)
                    elseif type(killer) == "number" then isUs = (killer == lp.UserId)
                    elseif type(killer) == "string" then isUs = (killer:lower() == lp.Name:lower()) end
                end)
                if not isUs then return orig(ent, action, ...) end
                local held = nil
                pcall(function()
                    local lf = Rivals.Fighter and Rivals.Fighter.LocalFighter
                    local it = lf and lf.EquippedItem
                    if it ~= nil then held = it.Name end
                end)
                local fin, weapon = nil, nil
                local atkW = State.LastAttackWeapon
                if type(atkW) ~= "string" or tick() - (State.LastAttackWeaponAt or 0) > 30 then
                    atkW = nil
                end
                for _, w in pairs({ atkW, held, GameVisuals.lastWeapon }) do
                    if fin == nil and type(w) == "string" then
                        fin = resolveSel(w, "Finisher")
                        if fin ~= nil then weapon = w end
                    end
                end
                if fin == nil then
                    for w in pairs(GameVisuals.Choices) do
                        if fin == nil then
                            fin = resolveSel(w, "Finisher")
                            if fin ~= nil then weapon = w end
                        end
                    end
                end
                if fin == nil then return orig(ent, action, ...) end
                local rendered = false
                pcall(function() rendered = ent:IsRendered() end)
                if not rendered then return orig(ent, action, ...) end
                local mod, model = nil, nil
                pcall(function()
                    local folder = finisherFolder()
                    local node = folder and folder:FindFirstChild(tostring(fin.Name)) or nil
                    if node ~= nil then atIdentity2(function() mod = require(node) end) end
                    model = rawget(ent, "Model")
                end)
                if type(mod) ~= "table" or type(mod.new) ~= "function" or model == nil then
                    return orig(ent, action, ...)
                end
                if Config.GVFinisherClone == false then
                    local played = false
                    pcall(function()
                        ent:_PlayFinisher(fin.Name, args[2], args[3], args[4])
                        played = true
                    end)
                    if played then return end
                    return orig(ent, action, ...)
                end
                if playFinisherOnClone(ent, model, mod, args[2], args[3], args[4]) then
                    note((weapon or "?") .. " finisher -> " .. tostring(fin.Name))
                    return
                end
                note("finisher clone failed for " .. tostring(fin.Name))
                return orig(ent, action, ...)
            end
        end) then n = n + 1 end
        if n == 0 then return false, "no hook target resolved (modules not loaded yet?)" end
        return true, n
    end
    local function rebuildOidMap()
        local now = tick()
        if now < _oidAt then return end
        _oidAt = now + 5
        pcall(function()
            local f = Rivals.Fighter:GetFighter(lp)
            if f == nil or type(f.Items) ~= "table" then return end
            for _, item in pairs(f.Items) do
                local oid = nil
                pcall(function() oid = item:Get("ObjectID") end)
                if oid ~= nil then _oidWeapon[tostring(oid)] = item.Name end
            end
        end)
    end
    local function upvaluesOf(fn)
        local ups = nil
        pcall(function() ups = debug.getupvalues(fn) end)
        if type(ups) == "table" and next(ups) ~= nil then return ups end
        if debug.getupvalue == nil then return nil end
        ups = {}
        for i = 1, 64 do
            local ok, v = pcall(debug.getupvalue, fn, i)
            if not ok then break end
            ups[i] = v
        end
        if next(ups) == nil then return nil end
        return ups
    end
    local _rebuildAt = setmetatable({}, { __mode = "k" })
    local _forceRebuild = false
    local _lastRefusal = {}
    local _rebuildFails = setmetatable({}, { __mode = "k" })
    local _rebuildSeen  = setmetatable({}, { __mode = "k" })
    local function liveTriple(vm)
        local name, charm, wrap = nil, nil, nil
        pcall(function()
            local src = rawget(vm, "Data")
            if type(src) ~= "table" then return end
            name  = src.Name
            charm = src.Charm
            wrap  = src.Wrap
        end)
        return name, charm, wrap
    end
    local function applyWrapLive(vm, wrap)
        local data = nil
        pcall(function() data = rawget(vm, "Data") end)
        if type(data) ~= "table" then return false, "ViewModel.Data unreadable" end
        local upd = nil
        pcall(function() upd = M.cvm._UpdateWrap end)
        if type(upd) ~= "function" then return false, "ClientViewModel._UpdateWrap not found" end
        rawset(data, "Wrap", wrap)
        local ok, err = atIdentity2(function() upd(vm) end)
        if not ok then return false, "wrap update failed: " .. tostring(err) end
        return true, nil
    end
    local function wrapLabel(w)
        if type(w) ~= "table" then return "none" end
        return tostring(w.Name)
    end
    local INTENT_OF = { Name = "Skin", Charm = "Charm", Wrap = "Wrap" }
    local function wants(base, dataKey)
        return hasIntent(base, INTENT_OF[dataKey])
    end
    local function writeData(obj, raw, base)
        if obj == nil then return false end
        local wrote = false
        for _, key in pairs({ "Name", "Charm", "Wrap" }) do
          if wants(base, key) then
            local ok = false
            pcall(function()
                obj:SetReplicate(key, raw[key])
                ok = true
            end)
            if not ok then
                pcall(function()
                    local d = rawget(obj, "Data")
                    if type(d) == "table" then
                        d[key] = raw[key]
                        ok = true
                    end
                end)
            end
            if ok then wrote = true end
          end
        end
        return wrote
    end
    local function armsDataOf(item)
        local packed = nil
        pcall(function()
            local f = item.ClientFighter
            if f == nil then return end
            local get = f.GetArmsData
            if type(get) ~= "function" then return end
            packed = table.pack(get(f))
        end)
        return packed
    end
    local function rebuildPayload(base, vm)
        local liveName, liveCharm, liveWrap = liveTriple(vm)
        local raw = {}
        if hasIntent(base, "Skin") then
            local s = resolveSel(base, "Skin")
            raw[enumKey("Name")] = (s ~= nil) and s.Name or base
        else
            raw[enumKey("Name")] = liveName or base
        end
        if hasIntent(base, "Charm") then
            raw[enumKey("Charm")] = resolveSel(base, "Charm")
        else
            local forced = rankOverrideRecord(liveCharm)
            raw[enumKey("Charm")] = forced or liveCharm
        end
        if hasIntent(base, "Wrap") then
            raw[enumKey("Wrap")] = resolveSel(base, "Wrap")
        else
            raw[enumKey("Wrap")] = liveWrap
        end
        return raw
    end
    local function payloadKeysAreEnums(raw)
        for _, k in pairs({ "Name", "Charm", "Wrap" }) do
            if rawget(raw, k) ~= nil and enumOf(k) ~= k then return false, k end
        end
        return true, nil
    end
    local function adoptViewModel(item, fresh, arms)
        pcall(function() rawset(item, "ViewModel", fresh) end)
        if arms ~= nil then
            atIdentity2(function() M.cvm.SetArmsData(fresh, table.unpack(arms, 1, arms.n)) end)
        end
        atIdentity2(function() M.cvm.Equip(fresh, true) end)
        pcall(function()
            local sp = rawget(fresh, "_equip_spring")
            if sp ~= nil then sp._position0 = 0 ; sp._velocity0 = 0 end
        end)
    end
    local function usableReplacement(fresh, vm)
        if fresh == nil or fresh == vm then return false end
        local ok = false
        pcall(function()
            ok = (rawget(fresh, "_destroyed") ~= true) and (rawget(fresh, "Model") ~= nil)
        end)
        return ok
    end
    local function tryBuild(create, item, serial, vm)
        local fresh = nil
        atIdentity2(function() fresh = create(item, serial) end)
        if fresh == nil then pcall(function() fresh = rawget(item, "ViewModel") end) end
        if usableReplacement(fresh, vm) then return fresh end
        return nil
    end
    local function dropViewModel(drop, vm)
        pcall(function()
            if rawget(vm, "_destroyed") ~= true then atIdentity2(function() drop(vm) end) end
        end)
    end
    local function rebuildViewModel(item, base, vm)
        if Config.GVBirthHook == false then return false, "style at construction is off", false end
        if State.RageFiring == true then return false, nil, true end
        local now = tick()
        if not _forceRebuild and now < (_rebuildAt[item] or 0) then return false, nil, true end
        local fails = _rebuildFails[item]
        if not _forceRebuild and fails ~= nil and fails >= 3 and _rebuildSeen[item] == vm then
            return false, "constructor keeps refusing — lands on next spawn", false
        end
        local create = origOf(M.ci, "_CreateViewModel")
        if type(create) ~= "function" then return false, "_CreateViewModel missing — needs a respawn", false end
        local drop = nil
        pcall(function() drop = M.cvm.Destroy end)
        if type(drop) ~= "function" then return false, "Destroy missing — needs a respawn", false end
        local equip = nil
        pcall(function() equip = M.cvm.Equip end)
        if type(equip) ~= "function" then return false, "Equip missing — needs a respawn", false end
        local raw = rebuildPayload(base, vm)
        local keysOk, badKey = payloadKeysAreEnums(raw)
        if not keysOk then
            return false, "no enum for '" .. tostring(badKey) .. "' — lands on next spawn", false
        end
        _rebuildAt[item] = now + REBUILD_COOLDOWN
        local arms = armsDataOf(item)
        local serial = { Data = raw }
        local prevField = nil
        pcall(function() prevField = rawget(item, "ViewModel") end)
        pcall(function() rawset(item, "ViewModel", nil) end)
        local fresh = tryBuild(create, item, serial, vm)
        if fresh ~= nil then
            adoptViewModel(item, fresh, arms)
            dropViewModel(drop, vm)
            _rebuildFails[item] = nil
            _rebuildSeen[item] = nil
            return true, nil, false
        end
        pcall(function() rawset(item, "ViewModel", prevField) end)
        _rebuildFails[item] = (fails or 0) + 1
        _rebuildSeen[item] = vm
        return false, "constructor refused — lands on next spawn", false
    end
    local function sameSub(a, b)
        if a == nil and b == nil then return true end
        if a == nil or b == nil then return false end
        local am,bm=a.Metadata or {},b.Metadata or {}
        return a.Name == b.Name and a.Inverted == b.Inverted
            and am.SeasonELO == bm.SeasonELO
            and am.SeasonLeaderboardRank == bm.SeasonLeaderboardRank
    end
    local function applyToItem(item, base)
        local vm = nil
        pcall(function() vm = item.ViewModel end)
        local sel = selectionFor(base)
        if vm == nil then
            if sel ~= nil then note(base .. ": item has no ViewModel yet") end
            return false
        end
        local curName, curCharm, curWrap = liveTriple(vm)
        if curName == nil then
            if sel ~= nil then note(base .. ": ViewModel.Data unreadable") end
            return false
        end
        if sel == nil then return true end
        local raw = buildPayload(base, { Name = base }, identityKey)
        if raw == nil then raw = { Name = base } end
        local wrapOk = true
        if wants(base, "Wrap") and not sameSub(curWrap, raw.Wrap) then
            local wok, wwhy = applyWrapLive(vm, raw.Wrap)
            if wok then
                note(base .. " wrap -> " .. wrapLabel(raw.Wrap))
            else
                note(base .. ": " .. tostring(wwhy))
                wrapOk = false
            end
        end
        local needName  = wants(base, "Name")  and curName ~= raw.Name
        local needCharm = wants(base, "Charm") and not sameSub(curCharm, raw.Charm)
        if not needCharm and wants(base, "Charm") ~= true then
            local forced = rankOverrideRecord(curCharm)
            if forced ~= nil then
                local slotChoices = GameVisuals.Choices[base]
                if slotChoices == nil then slotChoices = {} ; GameVisuals.Choices[base] = slotChoices end
                slotChoices.Charm = forced
                raw[identityKey("Charm")] = forced
                note(base .. ": rank override adopted Season charm " .. tostring(forced.Name))
                needCharm = true
            end
        end
        if not needName and not needCharm then
            if wants(base, "Name") then
                local shown = nil
                pcall(function() shown = rawget(vm, "Name") end)
                if shown == raw.Name then _lastRefusal[base] = nil end
            else
                _lastRefusal[base] = nil
            end
            return wrapOk
        end
        local rok, rwhy, transient = rebuildViewModel(item, base, vm)
        writeData(item, raw, base)
        if transient ~= true then
            local nowVm = nil
            pcall(function() nowVm = item.ViewModel end)
            writeData(nowVm or vm, raw, base)
        end
        if transient ~= true then _lastRefusal[base] = nil end
        if rok then
            note(base .. " -> " .. tostring(raw.Name))
        elseif rwhy ~= nil then
            _lastRefusal[base] = rwhy
            note(base .. " -> " .. tostring(raw.Name) .. " (" .. rwhy .. ")")
        end
        return true
    end
    local function itemsOf(player)
        local items = nil
        pcall(function()
            local f = Rivals.Fighter:GetFighter(player)
            if f ~= nil and type(f.Items) == "table" then items = f.Items end
        end)
        if items == nil then
            pcall(function()
                local map = Rivals.Fighter._player_to_fighter
                local f = map and map[player]
                if f ~= nil and type(f.Items) == "table" then items = f.Items end
            end)
        end
        return items
    end
    local function applyToPlayer(player)
        local items = itemsOf(player)
        if items == nil then
            if next(GameVisuals.Choices) ~= nil then
                note("no fighter items for " .. player.Name .. " (not spawned in a match?)")
            end
            return 0
        end
        local n, matched, carried = 0, false, ""
        for _, item in pairs(items) do
            if type(item) == "table" then
                local base = nil
                pcall(function() base = item.Name end)
                if type(base) == "string" then
                    carried = carried .. base .. " "
                    if selectionFor(base) ~= nil then matched = true end
                    if applyToItem(item, base) then n = n + 1 end
                end
            end
        end
        if player == lp and next(GameVisuals.Choices) ~= nil and not matched then
            note("no carried weapon matches a selection — carrying: " .. carried)
        end
        return n
    end
    function GameVisuals.apply()
        if Config.GameVisuals ~= true then return 0 end
        resolveModules()
        rebuildOidMap()
        local n = applyToPlayer(lp)
        if Config.GVEveryone == true then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp then n = n + applyToPlayer(p) end
            end
        end
        State.GVApplied = n
        return n
    end
    local function noneSlot()
        return {
            Skin     = { Name = NONE_COSMETIC },
            Charm    = { Name = NONE_COSMETIC },
            Wrap     = { Name = NONE_COSMETIC },
            Finisher = { Name = NONE_COSMETIC },
        }
    end
    function GameVisuals.restore()
        for weapon in pairs(GameVisuals.Choices) do
            GameVisuals.Choices[weapon] = noneSlot()
        end
        _forceRebuild = true
        pcall(GameVisuals.apply)
        _forceRebuild = false
        GameVisuals.Choices = {}
        pcall(syncMask)
        note("reset")
        saveSoon()
    end
    local _conn, _last, _loaded = nil, 0, false
    local _hookRetryAt = 0
    function GameVisuals.enable()
        Config.GameVisuals = true
        resolveModules()
        local hok, hwhy = hooksInstall()
        if hok then
            note("hooks bound (" .. tostring(hwhy) .. ")")
        else
            note("hooks: " .. tostring(hwhy))
        end
        local cok, cwhy = captureInstall()
        if not cok then note("menu capture unavailable (" .. tostring(cwhy) .. ")") end
        local mok, mwhy = syncMask()
        if not mok then note("mask: " .. tostring(mwhy)) end
        note("hooks=" .. #HOOKS .. "  menu doors=" .. _captureBound .. "/2  captured=" .. _captured)
        if Config.GVRemember ~= false and not _loaded then
            _loaded = true
            local lok, lwhy = GameVisuals.loadConfig()
            if not lok and lwhy ~= "no saved cosmetics" then note("load: " .. tostring(lwhy)) end
        end
        if _conn ~= nil then return end
        _conn = RunService.Heartbeat:Connect(function()
            if Config.GameVisuals ~= true then return end
            local now = tick()
            if now - _last < POLL_S then return end
            _last = now
            if now >= _hookRetryAt and Config.GVBirthHook ~= false then
                _hookRetryAt=now+5
                pcall(hooksInstall)
            end
            if _captureBound < 2 and Config.GVBirthHook ~= false then pcall(captureInstall) end
            if maskNeeded() and not maskActive() then pcall(syncMask) end
            local applied,why=pcall(GameVisuals.apply)
            if not applied then note("apply failed: "..tostring(why)) end
            saveDrain()
        end)
    end
    function GameVisuals.disable()
        Config.GameVisuals = false
        if _saveAt ~= nil then
            _saveAt = nil
            pcall(GameVisuals.saveConfig)
        end
        _loaded = false
        if _conn ~= nil then
            _conn:Disconnect()
            _conn = nil
        end
        if _maskConn ~= nil then
            pcall(function() _maskConn:Disconnect() end)
            _maskConn = nil
        end
        captureRestore()
        for weapon in pairs(GameVisuals.Choices) do
            GameVisuals.Choices[weapon] = noneSlot()
        end
        _forceRebuild = true
        pcall(applyToPlayer, lp)
        _forceRebuild = false
        GameVisuals.Choices = {}
        hooksRestore()
        _favOverride = {}
        _spoof.CosmeticInventory  = nil
        _spoof.FavoritedCosmetics = nil
        _spoof.WeaponInventory    = nil
        _spoof.EquippedEmotes     = nil
        maskRemove()
        note("off")
    end
    local CAT, _catalogSource = nil, nil
    local function sortTail(t)
        local head = table.remove(t, 1)
        table.sort(t)
        table.insert(t, 1, head)
        table.insert(t, 2, "Random")
    end
    local function buildCatalog()
        if CAT ~= nil and _catalogSource == Rivals.Cosmetics then return end
        _catalogSource = Rivals.Cosmetics
        CAT = {
            Skin = { "None" }, Charm = { "None" }, Wrap = { "None" }, Finisher = { "None" },
            weapons = { "None" }, byWeapon = {}, owner = {},
        }
        pcall(function()
            local cos = Rivals.Cosmetics.Cosmetics
            if type(cos) ~= "table" then return end
            for name, entry in pairs(cos) do
                if type(entry) == "table" and entry.Hidden ~= true then
                    local t = entry.Type
                    if t == "Skin" and type(entry.ItemName) == "string" then
                        local item = entry.ItemName
                        CAT.owner[name] = item
                        CAT.owner[item .. " | " .. name] = item
                        table.insert(CAT.Skin, item .. " | " .. name)
                        if CAT.byWeapon[item] == nil then
                            CAT.byWeapon[item] = { "None" }
                            table.insert(CAT.weapons, item)
                        end
                        table.insert(CAT.byWeapon[item], name)
                    elseif CAT[t] ~= nil then
                        table.insert(CAT[t], name)
                    end
                end
            end
        end)
        sortTail(CAT.Skin) ; sortTail(CAT.Charm) ; sortTail(CAT.Wrap)
        sortTail(CAT.Finisher)
        local head = table.remove(CAT.weapons, 1)
        table.sort(CAT.weapons)
        table.insert(CAT.weapons, 1, head)
        for _, list in pairs(CAT.byWeapon) do sortTail(list) end
    end
    function GameVisuals.listOf(kind)
        buildCatalog()
        return CAT[kind] or { "None" }
    end
    function GameVisuals.skinList()  return GameVisuals.listOf("Skin")  end
    function GameVisuals.charmList() return GameVisuals.listOf("Charm") end
    function GameVisuals.wrapList()  return GameVisuals.listOf("Wrap")  end
    function GameVisuals.finisherList() return GameVisuals.listOf("Finisher") end
    function GameVisuals.weaponList()
        buildCatalog()
        return CAT.weapons
    end
    function GameVisuals.skinsFor(item)
        buildCatalog()
        local list = CAT.byWeapon[item]
        if list == nil then return { "None" } end
        return list
    end
    local _weapon = nil
    GameVisuals.lastWeapon = nil
    function GameVisuals.setWeapon(name)
        if name == nil or name == "None" then _weapon = nil else _weapon = name end
        GameVisuals.lastWeapon = _weapon
    end
    local function heldItemName()
        local base = nil
        pcall(function()
            local lf = Rivals.Fighter and Rivals.Fighter.LocalFighter
            local it = lf and lf.EquippedItem
            if it ~= nil then base = it.Name end
        end)
        if type(base) == "string" then return base end
        return _weapon
    end
    function GameVisuals.setFor(weapon, kind, name, inverted)
        if type(weapon) ~= "string" or type(kind) ~= "string" then return end
        buildCatalog()
        local slot = GameVisuals.Choices[weapon]
        if slot == nil then
            slot = {}
            GameVisuals.Choices[weapon] = slot
        end
        if name == nil or name == "None" or name == NONE_COSMETIC then
            slot[kind] = { Name = NONE_COSMETIC }
        elseif name == "Random" or name == RANDOM_COSMETIC then
            slot[kind] = { Name = RANDOM_COSMETIC, Type = kind, Inverted = inverted == true }
        else
            local rec = cloneCosmetic(name, kind, inverted)
            if rec == nil then
                note("unknown " .. kind .. ": " .. tostring(name))
                return
            end
            slot[kind] = rec
        end
        GameVisuals.lastWeapon = weapon
        note(weapon .. " " .. kind .. " = " .. tostring(name))
        pcall(syncMask)
        pcall(GameVisuals.apply)
        if kind == "Charm" then
            task.defer(function() pcall(GameVisuals.restyleSeasonCharms) end)
        end
        saveSoon()
    end
    function GameVisuals.setSkin(label)
        buildCatalog()
        if label == nil or label == "None" then
            if _weapon ~= nil then GameVisuals.setFor(_weapon, "Skin", nil) end
            return
        end
        if label == "Random" then
            local w = _weapon or heldItemName()
            if w == nil then
                note("pick a Weapon above, or hold the one you want to change")
                return
            end
            GameVisuals.setFor(w, "Skin", "Random")
            return
        end
        local item = CAT.owner[label]
        if item == nil then
            note("unknown skin: " .. tostring(label))
            return
        end
        local skin = label
        local bar = string.find(label, " | ", 1, true)
        if bar ~= nil then skin = string.sub(label, bar + 3) end
        GameVisuals.setFor(item, "Skin", skin)
    end
    function GameVisuals.setOn(kind, name)
        local base = _weapon or heldItemName()
        if base == nil then
            note("pick a Weapon above, or hold the one you want to change")
            return
        end
        local inv = nil
        if kind == "Wrap" then inv = Config.GVWrapInverted == true end
        GameVisuals.setFor(base, kind, name, inv)
    end
    function GameVisuals.setCharm(name)    GameVisuals.setOn("Charm", name)    end
    function GameVisuals.setWrap(name)     GameVisuals.setOn("Wrap", name)     end
    function GameVisuals.setFinisher(name) GameVisuals.setOn("Finisher", name) end
    function GameVisuals.setWrapInverted(on)
        Config.GVWrapInverted = (on == true)
        for _, slot in pairs(GameVisuals.Choices) do
            local w = slot.Wrap
            if type(w) == "table" and w.Name ~= NONE_COSMETIC then
                w.Inverted = Config.GVWrapInverted
                if type(w.Resolved) == "table" then w.Resolved.Inverted = Config.GVWrapInverted end
            end
        end
        note("wrap inverted " .. tostring(Config.GVWrapInverted))
        pcall(GameVisuals.apply)
        saveSoon()
    end
    local RANK_FALLBACK = {
        "Bronze 1", "Bronze 2", "Bronze 3", "Silver 1", "Silver 2", "Silver 3",
        "Gold 1", "Gold 2", "Gold 3", "Platinum 1", "Platinum 2", "Platinum 3",
        "Diamond 1", "Diamond 2", "Diamond 3", "Onyx 1", "Onyx 2", "Onyx 3",
        "Nemesis", "Archnemesis",
    }
    local RANK_ELO_FALLBACK = {
        ["Bronze 1"] = 0,    ["Bronze 2"] = 200,  ["Bronze 3"] = 400,
        ["Silver 1"] = 600,  ["Silver 2"] = 800,  ["Silver 3"] = 1000,
        ["Gold 1"] = 1200,   ["Gold 2"] = 1400,   ["Gold 3"] = 1600,
        ["Platinum 1"] = 1800, ["Platinum 2"] = 2000, ["Platinum 3"] = 2200,
        ["Diamond 1"] = 2400, ["Diamond 2"] = 2600, ["Diamond 3"] = 2800,
        ["Onyx 1"] = 3000,   ["Onyx 2"] = 3200,   ["Onyx 3"] = 3400,
        ["Nemesis"] = 3600,  ["Archnemesis"] = 3600,
    }
    function GameVisuals.rankNames()
        local sl = M.seasonLib
        if sl ~= nil and type(sl.RankProfiles) == "table" then
            local prof = sl.RankProfiles.ranks_version1
            if type(prof) == "table" and type(prof.RanksOrder) == "table" then
                local out = {}
                for _, name in ipairs(prof.RanksOrder) do
                    if name ~= "Unranked" then out[#out + 1] = name end
                end
                if #out > 0 then return out end
            end
        end
        local out = {}
        for _, name in ipairs(RANK_FALLBACK) do out[#out + 1] = name end
        return out
    end
    function GameVisuals.rankEloFor(rankName)
        if type(rankName) ~= "string" or rankName == "" then return nil end
        local sl = M.seasonLib
        if sl ~= nil and type(sl.RankProfiles) == "table" then
            local prof = sl.RankProfiles.ranks_version1
            local r = (type(prof) == "table" and type(prof.Ranks) == "table") and prof.Ranks[rankName] or nil
            if type(r) == "table" and type(r.RequiredELO) == "number" then return r.RequiredELO end
        end
        return RANK_ELO_FALLBACK[rankName]
    end
    function GameVisuals.rankNeedsLb(rankName)
        if rankName == "Archnemesis" then return true end
        local sl = M.seasonLib
        if sl ~= nil and type(sl.RankProfiles) == "table" then
            local prof = sl.RankProfiles.ranks_version1
            local r = (type(prof) == "table" and type(prof.Ranks) == "table") and prof.Ranks[rankName] or nil
            if type(r) == "table" and r.RequiredELOLeaderboardRanking ~= nil then return true end
        end
        return false
    end
    function GameVisuals.resolveRankStamp()
        if Config.GVRankCharmOn ~= true then return nil end
        local elo = GameVisuals.rankEloFor(Config.GVRankCharmRank)
        if type(elo) ~= "number" then return nil end
        local lb = tonumber(Config.GVRankCharmLb) or 0
        if lb <= 0 and GameVisuals.rankNeedsLb(Config.GVRankCharmRank) then lb = 1 end
        return { SeasonELO = elo, SeasonLeaderboardRank = (lb > 0 and lb or nil) }
    end
    function GameVisuals.rankedCharmsFor()
        local out = { "Held weapon" }
        for _, w in ipairs(GameVisuals.weaponList()) do
            if w ~= "None" then out[#out + 1] = w end
        end
        return out
    end
    function GameVisuals.applyRankedCharm(rankName, weaponLabel)
        if Config.GVRankCharmOn ~= true then
            note("turn on 'Spoof ranked charm rank' first")
            return
        end
        if type(rankName) ~= "string" or rankName == "" or rankName == "None" then return end
        if type(GameVisuals.rankEloFor(rankName)) ~= "number" then
            note("unknown rank: " .. tostring(rankName))
            return
        end
        local base = nil
        if type(weaponLabel) == "string" and weaponLabel ~= "" and weaponLabel ~= "None"
            and weaponLabel ~= "Held weapon" then
            base = weaponLabel
        else
            base = heldItemName()
        end
        if base == nil then
            note("hold the weapon you want it on (or pick one above)")
            return
        end
        local bestN, bestSeason = -1, nil
        for _, name in ipairs(GameVisuals.charmList()) do
            local n = string.match(name, "^Season (%d+)$")
            n = n and tonumber(n)
            if n ~= nil and n > bestN then bestN, bestSeason = n, name end
        end
        if bestSeason == nil then
            note("no Season charms found in the catalogue")
            return
        end
        Config.GVRankCharmRank = rankName
        local slotChoices = GameVisuals.Choices[base]
        if slotChoices == nil then slotChoices = {} ; GameVisuals.Choices[base] = slotChoices end
        slotChoices.Charm = cloneCosmetic(bestSeason, "Charm")
        pcall(GameVisuals.apply)
        saveSoon()
        note(base .. ": ranked charm -> " .. rankName .. " (" .. bestSeason .. ")")
    end
    function GameVisuals.restyleSeasonCharms()
        if Config.GVRankCharmOn ~= true then return end
        local sl = M.seasonLib
        if sl == nil or type(sl.FormatSeasonRankCharm) ~= "function" then return end
        local md = GameVisuals.resolveRankStamp()
        if type(md) ~= "table" then return end
        pcall(function()
            for _, d in ipairs(workspace:GetDescendants()) do
                if d:IsA("Model") and string.match(d.Name, "^Season %d+$") ~= nil
                    and d:FindFirstChild("Extra") ~= nil then
                    pcall(function()
                        sl:FormatSeasonRankCharm(d, d.Name, md.SeasonELO, md.SeasonLeaderboardRank)
                    end)
                end
            end
        end)
    end
    function GameVisuals.refreshRankCharmMeta()
        for _, slot in pairs(GameVisuals.Choices) do
            local c = slot.Charm
            if c ~= nil and c.Name ~= NONE_COSMETIC and string.match(c.Name, "^Season %d+$") ~= nil then
                slot.Charm = cloneCosmetic(c.Name, "Charm", c.Inverted)
            end
        end
        pcall(GameVisuals.apply)
        pcall(GameVisuals.restyleSeasonCharms)
        saveSoon()
    end
    function GameVisuals.clearWeapon()
        local base = _weapon or heldItemName()
        if base == nil then return end
        GameVisuals.Choices[base] = noneSlot()
        _forceRebuild = true
        pcall(GameVisuals.apply)
        _forceRebuild = false
        GameVisuals.Choices[base] = nil
        note("cleared " .. base)
        pcall(syncMask)
        saveSoon()
    end
    function GameVisuals.summary()
        local out = {}
        for weapon, slot in pairs(GameVisuals.Choices) do
            local bits = {}
            for _, kind in pairs({ "Skin", "Wrap", "Charm", "Finisher" }) do
                local v = slot[kind]
                if v ~= nil and v.Name ~= NONE_COSMETIC then
                    local shown = tostring(v.Name)
                    if v.Name == RANDOM_COSMETIC then
                        shown = "Random"
                        if type(v.Resolved) == "table" and v.Resolved.Name ~= nil then
                            shown = "Random (" .. tostring(v.Resolved.Name) .. ")"
                        end
                    end
                    table.insert(bits, string.lower(kind) .. " " .. shown)
                end
            end
            if #bits > 0 then
                local line = weapon .. " — " .. table.concat(bits, " · ")
                local why = _lastRefusal[weapon]
                if why ~= nil then line = line .. "  (" .. tostring(why) .. ")" end
                table.insert(out, line)
            end
        end
        table.sort(out)
        return out
    end
    function GameVisuals.ready()
        return #HOOKS > 0
    end
    local CFG_DIR, CFG_FILE = "oxycodoneObsidian", "oxycodoneObsidian/cosmetics.json"
    local function fsReady()
        if type(writefile) ~= "function" or type(readfile) ~= "function"
            or type(isfile) ~= "function" then
            if not _fsWarned then
                _fsWarned = true
                note("no filesystem API — picks last this session only")
            end
            return false
        end
        pcall(function()
            if type(isfolder) ~= "function" or type(makefolder) ~= "function" then return end
            if not isfolder(CFG_DIR) then makefolder(CFG_DIR) end
        end)
        return true
    end
    function GameVisuals.saveConfig()
        if Config.GVRemember == false then return false, "remember picks is off" end
        if not fsReady() then return false, "no filesystem API" end
        local doc = { v = 1, choices = {} }
        for weapon, slot in pairs(GameVisuals.Choices) do
            local entry = nil
            for _, kind in pairs({ "Skin", "Charm", "Wrap", "Finisher" }) do
                local sel = slot[kind]
                if type(sel) == "table" and type(sel.Name) == "string" then
                    if entry == nil then entry = {} end
                    entry[kind] = { Name = sel.Name, Inverted = sel.Inverted == true }
                end
            end
            if entry ~= nil then doc.choices[weapon] = entry end
        end
        local ok, err = pcall(function()
            writefile(CFG_FILE, game:GetService("HttpService"):JSONEncode(doc))
        end)
        if not ok then return false, tostring(err) end
        return true, nil
    end
    saveSoon = function()
        if Config.GVRemember == false then return end
        _saveAt = tick() + 1
    end
    saveDrain = function()
        if _saveAt == nil or tick() < _saveAt then return end
        _saveAt = nil
        local ok, why = GameVisuals.saveConfig()
        if not ok and why ~= "remember picks is off" and why ~= "no filesystem API" then
            note("save failed: " .. tostring(why))
        end
    end
    function GameVisuals.loadConfig()
        if not fsReady() then return false, "no filesystem API" end
        local raw = nil
        pcall(function()
            if isfile(CFG_FILE) then raw = readfile(CFG_FILE) end
        end)
        if type(raw) ~= "string" or #raw == 0 then return false, "no saved cosmetics" end
        local doc = nil
        pcall(function() doc = game:GetService("HttpService"):JSONDecode(raw) end)
        if type(doc) ~= "table" then return false, "cosmetics.json did not decode" end
        buildCatalog()
        local n, skipped = 0, 0
        if type(doc.choices) == "table" then
            for weapon, entry in pairs(doc.choices) do
                if type(weapon) == "string" and type(entry) == "table" then
                    local slot = GameVisuals.Choices[weapon]
                    if slot == nil then
                        slot = {}
                        GameVisuals.Choices[weapon] = slot
                    end
                    for _, kind in pairs({ "Skin", "Charm", "Wrap", "Finisher" }) do
                        local sel = entry[kind]
                        if type(sel) == "table" and type(sel.Name) == "string" then
                            local inverted = sel.Inverted == true
                            if sel.Name == NONE_COSMETIC then
                                slot[kind] = { Name = NONE_COSMETIC }
                                n = n + 1
                            elseif sel.Name == RANDOM_COSMETIC then
                                slot[kind] = { Name = RANDOM_COSMETIC, Type = kind, Inverted = inverted }
                                n = n + 1
                            else
                                local rec = cloneCosmetic(sel.Name, kind, inverted)
                                if rec == nil then
                                    skipped = skipped + 1
                                else
                                    slot[kind] = rec
                                    n = n + 1
                                end
                            end
                        end
                    end
                    if next(slot) == nil then GameVisuals.Choices[weapon] = nil end
                end
            end
        end
        pcall(syncMask)
        pcall(GameVisuals.apply)
        local msg = "loaded " .. n .. " saved picks"
        if skipped > 0 then msg = msg .. " (" .. skipped .. " no longer in the game)" end
        note(msg)
        return true, n
    end
    local function isReplicatedStorage(v)
        local ok = false
        pcall(function() ok = (typeof(v) == "Instance" and v.ClassName == "ReplicatedStorage") end)
        return ok
    end
    local function cosmeticsCaller()
        for lvl = 2, 8 do
            local src, fn = nil, nil
            local ok = pcall(function() src, fn = debug.info(lvl, "sf") end)
            if not ok then return nil end
            if type(src) == "string" and type(fn) == "function"
                and string.match(src, "Cosmetics$") ~= nil then
                return fn
            end
        end
        return nil
    end
    local function onEquipPicked(weapon, ctype, cname, opts)
        _captured = _captured + 1
        if type(weapon) ~= "string" or type(ctype) ~= "string" then return end
        local inverted = nil
        if type(opts) == "table" then inverted = opts.IsInverted == true end
        if ctype == "Wrap" and inverted ~= nil then Config.GVWrapInverted = inverted end
        GameVisuals.setFor(weapon, ctype, cname, inverted)
    end
    local function onFavouritePicked(weapon, cname, state, ctype)
        if type(weapon) ~= "string" or type(cname) ~= "string" then return end
        local key = cname
        if cname == NONE_COSMETIC and type(ctype) == "string" then key = cname .. "_" .. ctype end
        local slot = _favOverride[weapon]
        if slot == nil then
            slot = {}
            _favOverride[weapon] = slot
        end
        slot[key] = (state == true) or nil
        refresh("FavoritedCosmetics")
    end
    local function makeDecoy()
        local equip = {}
        equip.FireServer = function(_, weapon, ctype, cname, opts)
            pcall(onEquipPicked, weapon, ctype, cname, opts)
        end
        local fav = {}
        fav.FireServer = function(_, weapon, cname, state, ctype)
            pcall(onFavouritePicked, weapon, cname, state, ctype)
        end
        return { Remotes = { Data = { EquipCosmetic = equip, FavoriteCosmetic = fav } } }
    end
    local function patchRemoteUpvalue(fn)
        if type(fn) ~= "function" then return false end
        if fn == _lastFn then return true end
        if debug.setupvalue == nil then return false end
        if DECOY == nil then DECOY = makeDecoy() end
        local ups = upvaluesOf(fn)
        if ups == nil then return false end
        for i, v in pairs(ups) do
            if v == DECOY then return true end
            if isReplicatedStorage(v) then
                local ok = false
                pcall(function()
                    debug.setupvalue(fn, i, DECOY)
                    ok = true
                end)
                if ok then
                    _lastFn = fn
                    table.insert(_rsPatch, { fn = fn, idx = i, orig = v })
                    while #_rsPatch > 24 do
                        local oldest = _rsPatch[1]
                        pcall(function() debug.setupvalue(oldest.fn, oldest.idx, oldest.orig) end)
                        table.remove(_rsPatch, 1)
                    end
                    return true
                end
                return false
            end
        end
        return false
    end
    captureRestore = function()
        for i = #_rsPatch, 1, -1 do
            local p = _rsPatch[i]
            pcall(function() debug.setupvalue(p.fn, p.idx, p.orig) end)
            _rsPatch[i] = nil
        end
        _captureBound = 0
        _lastFn = nil
    end
    captureInstall = function()
        resolveModules()
        if Config.GVBirthHook == false then return false, "menu capture disabled with the birth hook" end
        if debug.setupvalue == nil then return false, "executor lacks debug.setupvalue" end
        local bound = 0
        if hookField(M.cslot, "new", function(orig)
            return function(...)
                if debug.info ~= nil then
                    local fn = cosmeticsCaller()
                    if fn ~= nil then pcall(patchRemoteUpvalue, fn) end
                end
                return orig(...)
            end
        end) then bound = bound + 1 end
        if M.copts ~= nil then
            local initFn = nil
            pcall(function() initFn = M.copts._Init end)
            if patchRemoteUpvalue(initFn) then bound = bound + 1 end
        end
        _captureBound = bound
        if bound == 0 then return false, "no capture target resolved yet" end
        return true, bound
    end
end)()

do (function()
    local LTB = Tabs.World:AddLeftTabbox('World')
    local WL = LTB:AddTab('Lighting')
    local WX = LTB:AddTab('Weather')
    WL:AddToggle('Visuals', { Text='Enable', Default=(Config.Visuals or false),
        Callback=function(v) if v then Visuals.enable() else Visuals.disable() end end })
        :AddKeyPicker('VisualsToggleKey', { Default='None', Mode='Toggle', SyncToggleState=true, Text='Visuals' })
    local litDep = WL:AddDependencyBox()
    litDep:AddDropdown('VisualsPreset', { Values=Visuals.PresetOrder or {'Neutral','Day','Night','Cyber','Sunset','Winter','Vaporwave'},
        Default=(Config.VisualsPreset or 'Neutral'), Text='Preset',
        Callback=function(v) Visuals.setPreset(v) end })
    litDep:AddDropdown('VisualsGrade', { Values={'None','Crisp','Cold','Warm','Comp'},
        Default=(Config.VisualsGrade or 'Crisp'), Text='Color grade',
        Callback=function(v) if Visuals.setGrade then Visuals.setGrade(v) else Config.VisualsGrade = v end end })
    litDep:AddSlider('VisualsGradeStrength', { Text='Grade strength', Default=(Config.VisualsGradeStrength or 0.6),
        Min=0, Max=1, Rounding=2, Suffix='x',
        Callback=function(v) if Visuals.setGradeStrength then Visuals.setGradeStrength(v) else Config.VisualsGradeStrength = v end end })
    litDep:AddToggle('VisualsBloom', { Text='Bloom', Default=(Config.VisualsBloom or false),
        Callback=function(v) Visuals.setBloom(v) end })
    local blmDep = litDep:AddDependencyBox()
    blmDep:AddSlider('VisualsBloomIntensity', { Text='Bloom intensity', Default=(Config.VisualsBloomIntensity or 1.0),
        Min=0, Max=3, Rounding=2, Suffix='x',
        Callback=function(v) if Visuals.setBloomIntensity then Visuals.setBloomIntensity(v) else Config.VisualsBloomIntensity = v end end })
    blmDep:SetupDependencies({ { Toggles.VisualsBloom, true } })
    litDep:AddDivider('World')
    litDep:AddToggle('VisualsFullbright', { Text='Fullbright', Default=(Config.VisualsFullbright or false),
        Callback=function(v) Visuals.toggleFullbright(v) end })
    litDep:AddToggle('VisualsNoFog', { Text='No fog', Default=(Config.VisualsNoFog or false),
        Callback=function(v) Visuals.toggleNoFog(v) end })
    litDep:AddToggle('VisualsRainbowMap', { Text='Rainbow world', Default=(Config.VisualsRainbowMap or false),
        Callback=function(v) if Visuals.toggleRainbowMap then Visuals.toggleRainbowMap(v) else Config.VisualsRainbowMap = v end end })
    litDep:AddToggle('VisualsPerformanceMode', { Text='Performance mode', Default=(Config.VisualsPerformanceMode or false),
        Callback=function(v) Visuals.togglePerf(v) end })
    litDep:SetupDependencies({ { Toggles.Visuals, true } })
    WX:AddToggle('Weather', { Text='Enable', Default=(Config.Weather or false),
        Callback=function(v) if v then Weather.enableWeather() else Weather.disableWeather() end end })
    local wxDep = WX:AddDependencyBox()
    wxDep:AddDropdown('WeatherType', { Values=Weather.TypeOrder,
        Default=(Config.WeatherType or 'Rain'), Text='Precipitation',
        Callback=function(v) Weather.setType(v) end })
    wxDep:AddSlider('WeatherIntensity', { Text='Intensity', Default=(Config.WeatherIntensity or 1.0),
        Min=0.15, Max=2, Rounding=2, Suffix='x',
        Callback=function(v) Weather.setIntensity(v) end })
    wxDep:AddSlider('WeatherSoundVolume', { Text='Volume', Default=(Config.WeatherSoundVolume or 0.35),
        Min=0, Max=1, Rounding=2,
        Callback=function(v) Weather.setSoundVolume(v) end })
    wxDep:AddToggle('WeatherMood', { Text='Mood tint', Default=(Config.WeatherMood or true),
        Callback=function(v) Weather.toggleMood(v) end })
    wxDep:AddDivider('Atmosphere')
    wxDep:AddToggle('WeatherStorm', { Text='Storm & lightning', Default=(Config.WeatherStorm or false),
        Callback=function(v) Weather.toggleStorm(v) end })
    local stormDep = wxDep:AddDependencyBox()
    stormDep:AddToggle('WeatherStormFlash', { Text='Sky flash', Default=(Config.WeatherStormFlash or true),
        Callback=function(v) Config.WeatherStormFlash = v end })
    stormDep:SetupDependencies({ { Toggles.WeatherStorm, true } })
    wxDep:AddToggle('WeatherMeteors', { Text='Meteors', Default=(Config.WeatherMeteors or false),
        Callback=function(v) Weather.toggleMeteors(v) end })
    local metDep = wxDep:AddDependencyBox()
    metDep:AddSlider('WeatherMeteorRate', { Text='Rate', Default=(Config.WeatherMeteorRate or 1.0),
        Min=0.25, Max=3, Rounding=2, Suffix='x', Compact=true,
        Callback=function(v) Weather.setMeteorRate(v) end })
    metDep:SetupDependencies({ { Toggles.WeatherMeteors, true } })
    wxDep:AddToggle('WeatherShootingStars', { Text='Shooting stars', Default=(Config.WeatherShootingStars or false),
        Callback=function(v) Weather.toggleShootingStars(v) end })
    local starDep = wxDep:AddDependencyBox()
    starDep:AddSlider('WeatherStarRate', { Text='Rate', Default=(Config.WeatherStarRate or 1.0),
        Min=0.25, Max=3, Rounding=2, Suffix='x', Compact=true,
        Callback=function(v) Weather.setStarRate(v) end })
    starDep:SetupDependencies({ { Toggles.WeatherShootingStars, true } })
    wxDep:AddDropdown('SkyboxPreset', { Values=Weather.SkyboxOrder or {'Off','Space','Sunset','Clouds','Storm','Winter','Vaporwave'},
        Default=(Config.SkyboxPreset or 'Off'), Text='Skybox',
        Callback=function(v) Weather.setSkybox(v) end })
    wxDep:AddToggle('SkyboxHideCelestial', { Text='Hide celestial', Default=(Config.SkyboxHideCelestial or false),
        Callback=function(v) Weather.toggleCelestial(v) end })
    wxDep:AddToggle('WeatherGodRays', { Text='God rays', Default=(Config.WeatherGodRays or false),
        Callback=function(v) Weather.toggleGodRays(v) end })
    wxDep:AddToggle('WeatherRainbow', { Text='Rainbow', Default=(Config.WeatherRainbow or false),
        Callback=function(v) Weather.toggleRainbow(v) end })
    wxDep:AddToggle('WeatherPuddles', { Text='Puddles', Default=(Config.WeatherPuddles or false),
        Callback=function(v) Weather.togglePuddles(v) end })
    wxDep:AddToggle('WeatherClockDial', { Text='Clock dial', Default=(Config.WeatherClockDial or false),
        Callback=function(v) Weather.toggleClock(v) end })
    wxDep:SetupDependencies({ { Toggles.Weather, true } })
    local VM = Tabs.Weapons:AddLeftGroupbox('Viewmodel & Chams')
    VM:AddToggle('VMOffsetEnabled', { Text='6-DOF transform', Default=(Config.VMOffsetEnabled or false),
        Callback=function(v) Config.VMOffsetEnabled = v; pcall(Visuals.refreshViewModel) end })
    local vmDep = VM:AddDependencyBox()
    vmDep:AddDivider('Position')
    vmDep:AddSlider('VMOffsetX', { Text='X', Default=(Config.VMOffsetX or 0), Min=-5, Max=5, Rounding=2, Compact=true,
        Callback=function(v) Config.VMOffsetX = v end })
    vmDep:AddSlider('VMOffsetY', { Text='Y', Default=(Config.VMOffsetY or 0), Min=-5, Max=5, Rounding=2, Compact=true,
        Callback=function(v) Config.VMOffsetY = v end })
    vmDep:AddSlider('VMOffsetZ', { Text='Z', Default=(Config.VMOffsetZ or 0), Min=-5, Max=5, Rounding=2, Compact=true,
        Callback=function(v) Config.VMOffsetZ = v end })
    vmDep:AddDivider('Rotation')
    vmDep:AddSlider('VMOffsetPitch', { Text='Pitch', Default=(Config.VMOffsetPitch or 0), Min=-180, Max=180, Rounding=0, Compact=true, Suffix='°',
        Callback=function(v) Config.VMOffsetPitch = math.floor(v) end })
    vmDep:AddSlider('VMOffsetYaw', { Text='Yaw', Default=(Config.VMOffsetYaw or 0), Min=-180, Max=180, Rounding=0, Compact=true, Suffix='°',
        Callback=function(v) Config.VMOffsetYaw = math.floor(v) end })
    vmDep:AddSlider('VMOffsetRoll', { Text='Roll', Default=(Config.VMOffsetRoll or 0), Min=-180, Max=180, Rounding=0, Compact=true, Suffix='°',
        Callback=function(v) Config.VMOffsetRoll = math.floor(v) end })
    vmDep:SetupDependencies({ { Toggles.VMOffsetEnabled, true } })
    VM:AddDivider('Chams & Textures')
    VM:AddToggle('VMChamsEnabled', { Text='Material chams', Default=(Config.VMChamsEnabled or false),
        Callback=function(v) Config.VMChamsEnabled = v; pcall(Visuals.refreshViewModel) end })
        :AddColorPicker('VMChamsColor', { Default=(Config.VMChamsColor or Color3.fromRGB(53, 215, 199)), Title='Cham Color',
            Callback=function(v) Config.VMChamsColor = v end })
    local vmcDep = VM:AddDependencyBox()
    vmcDep:AddDropdown('VMChamsMaterial', { Values={'ForceField','Neon','Glass','SmoothPlastic'},
        Default=(Config.VMChamsMaterial or 'ForceField'), Text='Material', Callback=function(v) Config.VMChamsMaterial = v end })
    vmcDep:AddSlider('VMChamsTransparency', { Text='Transparency', Default=(Config.VMChamsTransparency or 0.5),
        Min=0, Max=1, Rounding=2, Callback=function(v) Config.VMChamsTransparency = v end })
    vmcDep:SetupDependencies({ { Toggles.VMChamsEnabled, true } })
    VM:AddToggle('VMDisableTextures', { Text='Disable gun textures', Default=(Config.VMDisableTextures or false),
        Callback=function(v) Config.VMDisableTextures = v; pcall(Visuals.refreshViewModel) end })
    local RTB1 = Tabs.World:AddRightTabbox('Effects & Camera')
    local HL = RTB1:AddTab('Holograms')
    local CM = RTB1:AddTab('Camera')
    HL:AddToggle('VisualsHolograms', { Text='On-hit holograms', Default=(Config.VisualsHolograms or false),
        Callback=function(v) Config.VisualsHolograms = v end })
        :AddColorPicker('VisualsHologramColor', { Default=(Config.VisualsHologramColor or Color3.fromRGB(0, 220, 255)), Title='Core Color',
            Callback=function(v) Config.VisualsHologramColor = v end })
        :AddColorPicker('VisualsHologramAccent', { Default=(Config.VisualsHologramAccent or Color3.fromRGB(255, 60, 200)), Title='Halo Accent',
            Callback=function(v) Config.VisualsHologramAccent = v end })
    local holoDep = HL:AddDependencyBox()
    holoDep:AddDropdown('VisualsHologramStyle', { Values={'Orb','Skeleton','Wraith'}, Default=(Config.VisualsHologramStyle or 'Orb'),
        Text='Style', Callback=function(v) Config.VisualsHologramStyle = v end })
    holoDep:AddSlider('VisualsHologramDuration', { Text='Duration', Default=(Config.VisualsHologramDuration or 3.5),
        Min=0.5, Max=5, Rounding=1, Suffix='s', Callback=function(v) Config.VisualsHologramDuration = v end })
    holoDep:AddSlider('VisualsHologramRange', { Text='Max range', Default=(Config.VisualsHologramRange or 300),
        Min=20, Max=300, Rounding=0, Suffix=' studs', Callback=function(v) Config.VisualsHologramRange = math.floor(v) end })
    holoDep:AddSlider('VisualsHologramVisibility', { Text='Visibility', Default=(Config.VisualsHologramVisibility or 1.4),
        Min=0.2, Max=2, Rounding=1, Suffix='x', Callback=function(v) Config.VisualsHologramVisibility = v end })
    holoDep:AddToggle('VisualsHologramLethal', { Text='Gold kill aura', Default=(Config.VisualsHologramLethal or true),
        Callback=function(v) Config.VisualsHologramLethal = v end })
    holoDep:SetupDependencies({ { Toggles.VisualsHolograms, true } })
    CM:AddToggle('CameraFovOverride', { Text='FOV override', Default=(Config.CameraFovOverride or false),
        Callback=function(v) Config.CameraFovOverride = v end })
    local fovDep = CM:AddDependencyBox()
    fovDep:AddSlider('CameraFovAmount', { Text='Field of view', Default=(Config.CameraFovAmount or 90),
        Min=40, Max=130, Rounding=0, Suffix='°', Callback=function(v) Config.CameraFovAmount = math.floor(v) end })
    fovDep:SetupDependencies({ { Toggles.CameraFovOverride, true } })
    CM:AddToggle('CameraAspectRatioEnabled', { Text='Aspect ratio stretch', Default=(Config.CameraAspectRatioEnabled or false),
        Callback=function(v) Config.CameraAspectRatioEnabled = v end })
    local arDep = CM:AddDependencyBox()
    arDep:AddSlider('CameraAspectRatioX', { Text='Width', Default=(Config.CameraAspectRatioX or 4),
        Min=1, Max=21, Rounding=0, Compact=true, Callback=function(v) Config.CameraAspectRatioX = math.floor(v) end })
    arDep:AddSlider('CameraAspectRatioY', { Text='Height', Default=(Config.CameraAspectRatioY or 3),
        Min=1, Max=21, Rounding=0, Compact=true, Callback=function(v) Config.CameraAspectRatioY = math.floor(v) end })
    arDep:SetupDependencies({ { Toggles.CameraAspectRatioEnabled, true } })
    CM:AddToggle('ThirdPersonEnabled', { Text='Third person', Default=(Config.ThirdPersonEnabled or false),
        Callback=function(v) Config.ThirdPersonEnabled = v end })
    local tpDep = CM:AddDependencyBox()
    tpDep:AddSlider('ThirdPersonDistance', { Text='Distance', Default=(Config.ThirdPersonDistance or 12),
        Min=4, Max=30, Rounding=0, Suffix=' studs', Callback=function(v) Config.ThirdPersonDistance = math.floor(v) end })
    tpDep:SetupDependencies({ { Toggles.ThirdPersonEnabled, true } })


    HL:AddLabel("Triggered by local shot results, not mouse clicks.")
    HL:AddButton({Text="Preview on your character",Func=function()
        Visuals.previewHologram(lp.Character)
    end})
    CM:AddToggle("VisualsVignette",{Text="Vignette",Default=false,Callback=Visuals.setVignette})
    CM:AddSlider("VisualsVignetteStrength",{Text="Vignette strength",Default=0.6,Min=0,Max=1,Rounding=2,Callback=Visuals.setVignetteStrength})
    CM:AddToggle("VisualsLetterbox",{Text="Letterbox",Default=false,Callback=Visuals.setLetterbox})
    CM:AddSlider("VisualsLetterboxSize",{Text="Letterbox size",Default=0.1,Min=0.04,Max=0.18,Rounding=2,Callback=Visuals.setLetterboxSize})
    CM:AddToggle("VisualsDOF",{Text="Depth of field",Default=false,Callback=Visuals.setDOF})
    CM:AddSlider("VisualsDOFDistance",{Text="Focus distance",Default=28,Min=5,Max=100,Rounding=0,Callback=Visuals.setDOFDistance})
    CM:AddSlider("VisualsDOFBlur",{Text="Blur",Default=0.5,Min=0,Max=1,Rounding=2,Callback=Visuals.setDOFBlur})
    CM:AddToggle("VisualsCameraSway",{Text="Camera sway",Default=false,Callback=function(v) Config.VisualsCameraSway=v end})
    CM:AddSlider("VisualsCameraSwayAmount",{Text="Sway amount",Default=0.5,Min=0,Max=1,Rounding=2,Callback=function(v) Config.VisualsCameraSwayAmount=v end})
    local cosmeticsTab = Tabs.Cosmetics
    local GL=cosmeticsTab:AddLeftGroupbox("GameVisuals")
    local SP=Tabs.Spoofer:AddRightGroupbox("Local profile display")
    GL:AddToggle('GameVisuals', { Text='Enable', Default=(Config.GameVisuals or false),
        Callback=function(v) if v then GameVisuals.enable() else GameVisuals.disable() end end })
    local gvDep = GL:AddDependencyBox()
    gvDep:AddToggle('GVUnlockAll', { Text='Show all cosmetics locally', Default=(Config.GVUnlockAll == true),
        Callback=function(v) pcall(GameVisuals.setUnlockAll, v) end })
    gvDep:AddToggle('GVRemember', { Text='Remember picks', Default=(Config.GVRemember or true),
        Callback=function(v) Config.GVRemember = v ; if v then pcall(GameVisuals.saveConfig) end end })
    gvDep:AddToggle('GVEmotes', { Text='Unlock emotes', Default=(Config.GVEmotes or false),
        Callback=function(v) pcall(GameVisuals.syncEmotes, v) end })
    gvDep:AddDropdown('GVEmote', { Values = { 'None' }, Default = 'None', Text = 'Play emote',
        Callback = function(v) pcall(GameVisuals.playEmote, v) end })
    gvDep:AddButton({ Text='Reset all', Func=function() pcall(GameVisuals.restore) end })
    gvDep:AddDivider('Ranked charm')
    gvDep:AddToggle('GVRankCharmOn', { Text='Spoof ranked charm rank', Default=(Config.GVRankCharmOn or false),
        Callback=function(v) Config.GVRankCharmOn = v ; if v then pcall(GameVisuals.refreshRankCharmMeta) end end })
    gvDep:SetupDependencies({ { Toggles.GameVisuals, true } })
    local rcDep = GL:AddDependencyBox()
    rcDep:AddDropdown('GVRankWep', { Values = { 'Held weapon' }, Default = 'Held weapon',
        Text = 'Ranked charm on', Callback = function(v) end })
    rcDep:AddDropdown('GVRankLook', { Values = { 'None' }, Default = 'None',
        Text = 'make it look like',
        Callback = function(v)
            if v == nil or v == 'None' then return end
            local wv = 'Held weapon'
            pcall(function() wv = Options.GVRankWep.Value or wv end)
            pcall(GameVisuals.applyRankedCharm, v, wv)
        end })
    rcDep:AddInput('GVRankCharmLb', { Default = tostring(Config.GVRankCharmLb or 0), Numeric = true,
        Text = '#N (optional, auto for Archnemesis)', Placeholder = '0', Finished = false,
        Callback = function(v) Config.GVRankCharmLb = tonumber(v) or 0 ; pcall(GameVisuals.refreshRankCharmMeta) end })
    rcDep:SetupDependencies({ { Toggles.GVRankCharmOn, true }, { Toggles.GameVisuals, true } })
    local manual=Tabs.Cosmetics:AddRightGroupbox('Manual skin / charm / wrap picker')
    manual:AddLabel('Enable cosmetics, choose a weapon, then select its cosmetics.',true)
    local pickDep = manual:AddDependencyBox()
    pickDep:AddDropdown('GVWeapon', { Values = { 'None' }, Default = 'None', Text = 'Weapon',
        Callback = function(v) pcall(GameVisuals.setWeapon, v) end })
    pickDep:AddDropdown('GVSkin', { Values = { 'None' }, Default = 'None', Text = 'Skin',
        Callback = function(v) pcall(GameVisuals.setSkin, v) end })
    pickDep:AddDropdown('GVCharm', { Values = { 'None' }, Default = 'None', Text = 'Charm',
        Callback = function(v) pcall(GameVisuals.setCharm, v) end })
    pickDep:AddDropdown('GVWrap', { Values = { 'None' }, Default = 'None', Text = 'Wrap',
        Callback = function(v) pcall(GameVisuals.setWrap, v) end })
    pickDep:AddDropdown('GVFinisher', { Values = { 'None' }, Default = 'None', Text = 'Finisher',
        Callback = function(v) pcall(GameVisuals.setFinisher, v) end })
    pickDep:AddToggle('GVWrapInverted', { Text='Invert wrap', Default=(Config.GVWrapInverted or false),
        Callback=function(v) pcall(GameVisuals.setWrapInverted, v) end })
    pickDep:SetupDependencies({ { Toggles.GameVisuals, true } })
    task.spawn(function()
        local sig = nil
        while running and GameVisuals.uiAlive do
            task.wait(3)
            local ok, lists = pcall(function()
                return { GameVisuals.weaponList(), GameVisuals.skinList(), GameVisuals.charmList(),
                         GameVisuals.wrapList(), GameVisuals.finisherList(), GameVisuals.rankNames(),
                         GameVisuals.emoteList(), GameVisuals.rankedCharmsFor() }
            end)
            if ok and type(lists) == 'table' then
                local lens = {}
                for i = 1, 8 do lens[i] = lists[i] and #lists[i] or 0 end
                local now = table.concat(lens, '/')
                if now ~= sig then
                    sig = now
                    pcall(function() Options.GVWeapon:SetValues(lists[1]) end)
                    pcall(function() Options.GVSkin:SetValues(lists[2]) end)
                    pcall(function() Options.GVCharm:SetValues(lists[3]) end)
                    pcall(function() Options.GVWrap:SetValues(lists[4]) end)
                    pcall(function() Options.GVFinisher:SetValues(lists[5]) end)
                    pcall(function() Options.GVRankLook:SetValues(lists[6]) end)
                    pcall(function() Options.GVEmote:SetValues(lists[7]) end)
                    pcall(function() Options.GVRankWep:SetValues(lists[8]) end)
                end
            end
        end
    end)
    GL:AddDivider('Live Loaded')
    local LOADED_LINES = 6
    local loaded = {}
    for i = 1, LOADED_LINES do loaded[i] = GL:AddLabel(' ', true) end
    if type(loaded[1]) == 'table' and type(loaded[1].SetText) == 'function' then
        task.spawn(function()
            local shown = nil
            while GameVisuals.uiAlive do
                task.wait(0.35)
                local lines = GameVisuals.summary()
                table.insert(lines,1,tostring(State.GVStatus or "Enable cosmetics to load the game adapters."))
                if #lines == 0 then
                    if Config.GameVisuals == true and GameVisuals.ready() ~= true then
                        lines = { 'not active yet' }
                    else
                        lines = {}
                    end
                end
                local joined = table.concat(lines, '\n')
                if joined ~= shown then
                    shown = joined
                    for i = 1, LOADED_LINES do
                        pcall(function() loaded[i]:SetText(lines[i] or ' ') end)
                    end
                end
            end
        end)
    end


    SP:AddToggle('SpooferNameEnabled', { Text='Spoof name', Default=(Config.SpooferNameEnabled or false),
        Callback=function(v) Config.SpooferNameEnabled = v ; if Visuals.applyGuiNameSpoof then Visuals.applyGuiNameSpoof() end end })
    local spNDep = SP:AddDependencyBox()
    spNDep:AddInput('SpooferName', { Default=(Config.SpooferName or 'ProPlayer'), Text='Username',
        Placeholder='Username', Finished=false,
        Callback=function(v) Config.SpooferName = v ; if Visuals.applyGuiNameSpoof then Visuals.applyGuiNameSpoof() end end })
    spNDep:AddInput('SpooferDisplayName', { Default=(Config.SpooferDisplayName or 'ProPlayer'), Text='Display name',
        Placeholder='Display name', Finished=false,
        Callback=function(v) Config.SpooferDisplayName = v ; if Visuals.applyGuiNameSpoof then Visuals.applyGuiNameSpoof() end end })
    spNDep:SetupDependencies({ { Toggles.SpooferNameEnabled, true } })
    SP:AddDivider('Ranked & Stats')
    SP:AddToggle('SpooferLevelEnabled', { Text='Spoof level', Default=(Config.SpooferLevelEnabled or false),
        Callback=function(v) Config.SpooferLevelEnabled = v ; if Visuals.updatePlayerSpoofer then Visuals.updatePlayerSpoofer() end end })
    local spLDep = SP:AddDependencyBox()
    spLDep:AddInput('SpooferLevel', { Default=tostring(Config.SpooferLevel or 100), Text='Level',
        Placeholder='100', Finished=false, Numeric=true,
        Callback=function(v) Config.SpooferLevel = tonumber(v) or 100 ; if Visuals.updatePlayerSpoofer then Visuals.updatePlayerSpoofer() end end })
    spLDep:SetupDependencies({ { Toggles.SpooferLevelEnabled, true } })
    SP:AddToggle('SpooferRankedEloEnabled', { Text='Spoof ELO', Default=(Config.SpooferRankedEloEnabled or false),
        Callback=function(v) Config.SpooferRankedEloEnabled = v ; if Visuals.updatePlayerSpoofer then Visuals.updatePlayerSpoofer() end end })
    local spEDep = SP:AddDependencyBox()
    spEDep:AddInput('SpooferRankedElo', { Default=tostring(Config.SpooferRankedElo or 2400), Text='ELO rating',
        Placeholder='2400', Finished=false, Numeric=true,
        Callback=function(v) Config.SpooferRankedElo = tonumber(v) or 2400 ; if Visuals.updatePlayerSpoofer then Visuals.updatePlayerSpoofer() end end })
    spEDep:SetupDependencies({ { Toggles.SpooferRankedEloEnabled, true } })
    SP:AddToggle('SpooferCasualWinsEnabled', { Text='Spoof casual wins', Default=(Config.SpooferCasualWinsEnabled or false),
        Callback=function(v) Config.SpooferCasualWinsEnabled = v ; if Visuals.updatePlayerSpoofer then Visuals.updatePlayerSpoofer() end end })
    local spWDep = SP:AddDependencyBox()
    spWDep:AddInput('SpooferCasualWins', { Default=tostring(Config.SpooferCasualWins or 500), Text='Casual wins',
        Placeholder='500', Finished=false, Numeric=true,
        Callback=function(v) Config.SpooferCasualWins = tonumber(v) or 500 ; if Visuals.updatePlayerSpoofer then Visuals.updatePlayerSpoofer() end end })
    spWDep:SetupDependencies({ { Toggles.SpooferCasualWinsEnabled, true } })
    SP:AddToggle('SpooferRankedWinsEnabled', { Text='Spoof ranked wins', Default=(Config.SpooferRankedWinsEnabled or false),
        Callback=function(v) Config.SpooferRankedWinsEnabled = v ; if Visuals.updatePlayerSpoofer then Visuals.updatePlayerSpoofer() end end })
    local spRWDep = SP:AddDependencyBox()
    spRWDep:AddInput('SpooferRankedWins', { Default=tostring(Config.SpooferRankedWins or 250), Text='Ranked wins',
        Placeholder='250', Finished=false, Numeric=true,
        Callback=function(v) Config.SpooferRankedWins = tonumber(v) or 250 ; if Visuals.updatePlayerSpoofer then Visuals.updatePlayerSpoofer() end end })
    spRWDep:SetupDependencies({ { Toggles.SpooferRankedWinsEnabled, true } })
    SP:AddToggle('SpooferWinPercentEnabled', { Text='Spoof winrate', Default=(Config.SpooferWinPercentEnabled or false),
        Callback=function(v) Config.SpooferWinPercentEnabled = v ; if Visuals.updatePlayerSpoofer then Visuals.updatePlayerSpoofer() end end })
    local spPDep = SP:AddDependencyBox()
    spPDep:AddInput('SpooferWinPercent', { Default=tostring(Config.SpooferWinPercent or 75), Text='Winrate %',
        Placeholder='75', Finished=false, Numeric=true,
        Callback=function(v) Config.SpooferWinPercent = tonumber(v) or 75 ; if Visuals.updatePlayerSpoofer then Visuals.updatePlayerSpoofer() end end })
    spPDep:SetupDependencies({ { Toggles.SpooferWinPercentEnabled, true } })
    SP:AddToggle('SpooferWinStreakEnabled', { Text='Spoof win streak', Default=(Config.SpooferWinStreakEnabled or false),
        Callback=function(v) Config.SpooferWinStreakEnabled = v ; if Visuals.updatePlayerSpoofer then Visuals.updatePlayerSpoofer() end end })
    local spSDep = SP:AddDependencyBox()
    spSDep:AddInput('SpooferWinStreak', { Default=tostring(Config.SpooferWinStreak or 25), Text='Win streak',
        Placeholder='25', Finished=false, Numeric=true,
        Callback=function(v) Config.SpooferWinStreak = tonumber(v) or 25 ; if Visuals.updatePlayerSpoofer then Visuals.updatePlayerSpoofer() end end })
    spSDep:SetupDependencies({ { Toggles.SpooferWinStreakEnabled, true } })
    SP:AddToggle('SpooferFavoriteMapEnabled', { Text='Spoof favorite map', Default=(Config.SpooferFavoriteMapEnabled or false),
        Callback=function(v) Config.SpooferFavoriteMapEnabled = v ; if Visuals.updatePlayerSpoofer then Visuals.updatePlayerSpoofer() end end })
    local spMDep = SP:AddDependencyBox()
    spMDep:AddInput('SpooferFavoriteMap', { Default=tostring(Config.SpooferFavoriteMap or 'Arena'), Text='Map name',
        Placeholder='Arena', Finished=false,
        Callback=function(v) Config.SpooferFavoriteMap = v ; if Visuals.updatePlayerSpoofer then Visuals.updatePlayerSpoofer() end end })
    spMDep:SetupDependencies({ { Toggles.SpooferFavoriteMapEnabled, true } })
end)() end



 
do
    local seasons={}
    local names={[0]="Zero",[1]="Warp",[2]="Polar",[3]="Fame"}
    local byName={Zero=0,Warp=1,Polar=2,Fame=3}
    local ranks={"Use custom ELO","Unranked","Bronze 1","Bronze 2","Bronze 3","Silver 1","Silver 2","Silver 3","Gold 1","Gold 2","Gold 3","Platinum 1","Platinum 2","Platinum 3","Diamond 1","Diamond 2","Diamond 3","Onyx 1","Onyx 2","Onyx 3","Nemesis","Archnemesis"}
    local function seasonNumber(value)
        if type(value) == "number" then return value end
        if type(value) ~= "string" then return nil end
        return byName[value] or tonumber(value:match("^Season (%d+)$")) or tonumber(value)
    end
    local function metadata(value)
        local cfg=seasons[seasonNumber(value)]
        if not cfg or not cfg.enabled then return nil end
        local elo=cfg.elo
        if cfg.rank ~= "Use custom ELO" then
            elo=cfg.rank == "Unranked" and -1 or GameVisuals.rankEloFor(cfg.rank)
            if cfg.rank == "Archnemesis" then elo=math.max(elo or 0,5000) end
        end
        return {SeasonELO=elo or 0,SeasonLeaderboardRank=cfg.arch}
    end
    GameVisuals.seasonMetadata=metadata
    local formatter
    local records=setmetatable({}, {__mode="k"})
    local function isLocalModel(model)
        if typeof(model) ~= "Instance" then return false end
        local item=getEquippedItem()
        local vm=item and item.ViewModel
        local root=vm and (vm.Model or vm._model)
        return (root and (model==root or model:IsDescendantOf(root)))
            or (Camera and model:IsDescendantOf(Camera))
            or (lp.Character and model:IsDescendantOf(lp.Character))
    end
    local function install()
        if formatter or not Rivals.SeasonLibrary then return end
        local lib=Rivals.SeasonLibrary
        if type(lib.FormatSeasonRankCharm) ~= "function" then return end
        local original=lib.FormatSeasonRankCharm
        local replacement=function(self,model,season,elo,arch,...)
            local md=metadata(season)
            if md then
                 
                 
                records[model]=records[model] or {season=season,elo=elo,arch=arch}
                elo,arch=md.SeasonELO,md.SeasonLeaderboardRank
            end
            return original(self,model,season,elo,arch,...)
        end
        local ok,err=pcall(patch,lib,"FormatSeasonRankCharm",replacement)
        if ok then formatter=original else State.SeasonError=tostring(err) end
    end
    local function refresh()
        install()
        if formatter then
            for model,saved in pairs(records) do
                if typeof(model)=="Instance" and model.Parent then
                    local md=metadata(saved.season)
                    pcall(formatter,Rivals.SeasonLibrary,model,saved.season,
                        md and md.SeasonELO or saved.elo,md and md.SeasonLeaderboardRank or saved.arch)
                end
            end
            local item=getEquippedItem()
            local vm=item and item.ViewModel
            local root=vm and (vm.Model or vm._model)
            local search=root or Camera
            if search then
                for _,model in ipairs(search:GetDescendants()) do
                    if model:IsA("Model") and seasonNumber(model.Name)~=nil then
                        local md=metadata(model.Name)
                        if md then
                            local index=seasonNumber(model.Name)
                            local season=(records[model] and records[model].season) or names[index] or model.Name
                            pcall(Rivals.SeasonLibrary.FormatSeasonRankCharm,Rivals.SeasonLibrary,model,season,md.SeasonELO,md.SeasonLeaderboardRank)
                        end
                    end
                end
            end
        end
        GameVisuals.refreshRankCharmMeta()
    end
    local tab=Tabs.Spoofer
    local boxes={tab:AddLeftGroupbox("Seasons 0–1"),tab:AddRightGroupbox("Seasons 2–3")}
    for i=0,3 do
        local cfg={enabled=false,rank="Use custom ELO",elo=0,arch=1}
        seasons[i]=cfg
        local box=boxes[i<2 and 1 or 2]
        local id="SeasonELO"..i
        box:AddLabel("Season "..i.." — "..names[i])
        box:AddToggle(id.."Enabled",{Text="Enable season appearance",Default=false,Callback=function(v) cfg.enabled=v; refresh() end})
        box:AddDropdown(id.."Rank",{Text="Rank",Values=ranks,Default=1,Callback=function(v) cfg.rank=v; refresh() end})
        box:AddInput(id.."ELO",{Text="Custom ELO",Default="0",Numeric=true,Finished=true,Callback=function(v) cfg.elo=tonumber(v) or 0; refresh() end})
        box:AddSlider(id.."Leaderboard",{Text="Leaderboard rank",Default=1,Min=1,Max=100,Rounding=0,Callback=function(v) cfg.arch=v; refresh() end})
    end
    boxes[1]:AddButton({Text="Refresh charm appearance",Func=refresh})
    boxes[1]:AddLabel("Select a Season charm in Cosmetics first.")
    table.insert(restorers,function()
        if formatter then
            for model,saved in pairs(records) do
                if typeof(model)=="Instance" and model.Parent then
                    pcall(formatter,Rivals.SeasonLibrary,model,saved.season,saved.elo,saved.arch)
                end
            end
        end
    end)
    local last=0
    connect(RunService.Heartbeat,function()
        if tick()-last<2 then return end
        last=tick()
        install()
    end)
end

 
do
    local box = Tabs.World:AddLeftGroupbox("Custom ambient")
    local enabled = false
    local inside, outside = Lighting.Ambient, Lighting.OutdoorAmbient
    local originalInside, originalOutside = inside, outside
    box:AddToggle("CustomAmbientEnabled",{Text="Override ambient",Default=false,Callback=function(v)
        enabled=v
        if not v then Lighting.Ambient=originalInside; Lighting.OutdoorAmbient=originalOutside end
    end})
    box:AddLabel("Ambient"):AddColorPicker("AmbientColor",{Default=inside,Callback=function(v) inside=v end})
    box:AddLabel("Outdoor ambient"):AddColorPicker("OutdoorAmbientColor",{Default=outside,Callback=function(v) outside=v end})
    connect(RunService.Heartbeat,function()
        if enabled then
            if Lighting.Ambient ~= inside then Lighting.Ambient=inside end
            if Lighting.OutdoorAmbient ~= outside then Lighting.OutdoorAmbient=outside end
        end
    end)
    table.insert(restorers,function()
        if enabled then Lighting.Ambient=originalInside; Lighting.OutdoorAmbient=originalOutside end
    end)
end
local function cleanup()
    if not running then return end
    running=false
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    GameVisuals.uiAlive=false
    pcall(Weather.unload)
    pcall(Visuals.unload)
    for i=#restorers,1,-1 do pcall(restorers[i]) end
    pcall(GameVisuals.disable)
    env.__ObsidianLocalVisuals=nil
end
do
    local platform=Tabs.Spoofer:AddLeftGroupbox("Device spoof")
    local devices={Desktop="MouseKeyboard",Mobile="Touch",Console="Gamepad",VR="VR"}
    local enabled,changed=false,false
    local selected="Desktop"
    local originalControls
    local function controlsRemote()
        local node=ReplicatedStorage
        for _,name in ipairs({"Remotes","Replication","Fighter","SetControls"}) do
            node=node and node:FindFirstChild(name)
        end
        return node
    end
    local function applyDevice(restore)
        if restore and not changed then return end
        local remote=controlsRemote()
        if not remote or not remote:IsA("RemoteEvent") then
            notify("Device spoof: SetControls remote is unavailable.")
            return
        end
        if not originalControls then
            local controller=loadGameModule(lp:FindFirstChild("PlayerScripts"),{"Controllers","ControlsController"})
            local current=controller and tostring(controller.CurrentControls)
            originalControls=devices[current] or current
            if originalControls~="MouseKeyboard" and originalControls~="Touch" and originalControls~="Gamepad" and originalControls~="VR" then
                originalControls=nil
                notify("Device spoof: waiting for the current controls type; try again once loaded.")
                return
            end
        end
        local ok,err=pcall(function()remote:FireServer(restore and originalControls or devices[selected])end)
        if ok then
            changed=not restore
            if restore then originalControls=nil end
        else
            notify("Device spoof: "..tostring(err))
        end
    end
    platform:AddLabel("Reports a device selection to the server; not a local-only preview.",true)
    platform:AddDropdown("DeviceSpoofSelection",{Text="Device",Values={"Desktop","Mobile","Console","VR"},Default="Desktop",Callback=function(v)
        selected=v
        if enabled then applyDevice(false) end
    end})
    platform:AddToggle("DeviceSpoofEnabled",{Text="Spoof device",Default=false,Callback=function(v)
        enabled=v
        applyDevice(not v)
    end})
    platform:AddButton({Text="Apply / retry",Func=function()applyDevice(not enabled)end})
    table.insert(restorers,function()applyDevice(true)end)
end

local settings=Tabs.Settings
local menu=settings:AddLeftGroupbox("Menu")
menu:AddLabel("Choose your menu key below (default: RightShift).")
menu:AddLabel("Local rendering is not a guarantee of game-rule compliance.")
menu:AddLabel("Enable oxycodone Cosmetics to load selections.")
menu:AddLabel("Camera, viewmodel and chams work independently of lighting.")
menu:AddButton({Text="Unload and restore",Func=function() Library:Unload() end})
Library:OnUnload(cleanup)
env.__ObsidianLocalVisuals=function()
    cleanup()
    pcall(function() Library:Unload() end)
end

 
local onLocalShotHit
local shotHooked=false
local function installShotEffects()
    if shotHooked or not Rivals.Gun or type(Rivals.Gun._ShootEffect)~="function" then return end
    local original=Rivals.Gun._ShootEffect
    local replacement=function(item, results, ...)
        local returned=table.pack(original(item,results,...))
        local ok,why=pcall(function()
            if not running or type(results)~="table" then return end
            local fighter=item and item.ClientFighter
            local mine=(fighter and (fighter.Player==lp or fighter.IsLocalPlayer==true)) or item==getEquippedItem()
            if not mine then return end
            State.Shots=State.Shots+1
            State.LastAttackWeapon=item.Name
            State.LastAttackWeaponAt=tick()
            local seen={}
            for _,entry in pairs(results) do
                if type(entry)=="table" then
                    local part=entry[utf8.char(1)] or entry.Instance or entry.HitPart
                    if typeof(part)=="Instance" then
                        local model=part:FindFirstAncestorOfClass("Model")
                        while model and model~=workspace do
                            if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
                                if model~=lp.Character and not seen[model] then
                                    seen[model]=true
                                    if Config.VisualsHolograms then Visuals.onShotHit(model) end
                                    if onLocalShotHit then onLocalShotHit() end
                                end
                                break
                            end
                            model=model.Parent
                        end
                    end
                end
            end
        end)
        if not ok then State.HologramError=tostring(why) end
        return table.unpack(returned,1,returned.n)
    end
    local ok,why=pcall(patch,Rivals.Gun,"_ShootEffect",replacement)
    if ok then shotHooked=true else State.HologramError=tostring(why) end
end
local diagnostics=settings:AddRightGroupbox("Diagnostics")
local labels={}
for i=1,7 do labels[i]=diagnostics:AddLabel("Waiting for game modules...",true) end
local function showDiagnostics()
    local item=getEquippedItem()
    local vm=item and item.ViewModel
    local lines={
        "Fighter controller: "..(Rivals.Fighter and "loaded" or "waiting"),
        "Equipped item: "..tostring(item and item.Name or "none"),
        "Viewmodel: "..((vm and (vm.Model or vm._model)) and "found" or "not found"),
        "Shot effects: "..(shotHooked and "connected" or "waiting for Gun._ShootEffect"),
        "Cosmetics: "..tostring(State.GVStatus or "disabled"),
        "Season library: "..(Rivals.SeasonLibrary and "loaded" or "waiting"),
        State.DisplayError or State.HitSoundError or State.VMError or State.HologramError or State.SeasonError or "",
    }
    if not Rivals.Fighter or not Rivals.Cosmetics then
        local path,why=next(moduleErrors)
        if path then lines[7]=path..": "..why end
    end
    for i,label in ipairs(labels) do
        if label.SetText then label:SetText(lines[i] or "") end
    end
end
diagnostics:AddButton({Text="Retry module loading",Func=function()
    task.spawn(function()
        resolveRivals()
        if not running then return end
        installShotEffects()
        if Config.GameVisuals then GameVisuals.enable() end
        Visuals.refreshViewModel()
        showDiagnostics()
    end)
end})
task.spawn(function()
    while running do
        resolveRivals()
        if not running then break end
        installShotEffects()
        pcall(showDiagnostics)
        task.wait(2)
    end
end)

local initialized, initError=pcall(function() Visuals.init(); Weather.init() end)
if not initialized then notify("Visual initialization: " .. tostring(initError)) end
notify("Loaded. Settings includes menu keybind, configs, themes and server controls.")


 
do
    local tab=Tabs.World
    local sounds=Tabs.Weapons:AddRightGroupbox("Hit sounds")
    local SoundService=game:GetService("SoundService")
    local hit={enabled=false,name="Bell",asset="",volume=0.5,pitch=1}
    local soundMap={Bameware="130791763",Bell="146680539",Bubble="146665237",Click="146633140",
        Pop="146681941",Rust="146692956",Fart="130791763",Big="130792279",Vine="146606035",
        Bruh="146657737",Skeet="130791733",Neverlose="146633485",Fatality="146665147",
        Bonk="146661497",Minecraft="146649495"}
    local names={"None","Custom asset ID"}
    for name in pairs(soundMap) do names[#names+1]=name end
    table.sort(names)
    local activeSounds={}
    local ContentProvider=game:GetService("ContentProvider")
    local lastHitAt=-math.huge
    local lastFailure={}
    local function playSound(preview)
        local raw=tostring(hit.asset or "")
        local id=hit.name=="Custom asset ID" and (raw:match("^%s*(%d+)%s*$") or raw:match("^rbxassetid://(%d+)$")) or soundMap[hit.name]
        if not id then return false end
        local now=os.clock()
        if not preview and now-lastHitAt<0.08 then return true end
        if not preview then lastHitAt=now end
        while #activeSounds>=10 do table.remove(activeSounds,1):Destroy() end
        local sound=Instance.new("Sound")
        sound.SoundId="rbxassetid://"..id
        sound.Volume=hit.volume
        sound.PlaybackSpeed=hit.pitch
        sound.Parent=SoundService
        activeSounds[#activeSounds+1]=sound
        Debris:AddItem(sound,15)
        task.spawn(function()
            local loaded,reason=pcall(function()
                ContentProvider:PreloadAsync({sound},function(_,status)
                    if status~=Enum.AssetFetchStatus.Success then error("audio unavailable or not permitted") end
                end)
            end)
            if not running or not sound.Parent then return end
            if loaded and sound.IsLoaded then
                SoundService:PlayLocalSound(sound)
                State.HitSoundError=nil
            else
                State.HitSoundError="Audio "..id.." could not load. Try another preset or permitted asset."
                if preview or not lastFailure[id] or os.clock()-lastFailure[id]>15 then
                    lastFailure[id]=os.clock()
                    notify(State.HitSoundError)
                end
                sound:Destroy()
            end
        end)
        return true
    end
    onLocalShotHit=function()
        if running and hit.enabled then playSound(false) end
    end
    sounds:AddToggle("ExtraHitEnabled",{Text="Custom hit sound",Default=false,Callback=function(v)hit.enabled=v end})
    sounds:AddDropdown("ExtraHitSound",{Text="Sound",Values=names,Default="Bell",Callback=function(v)hit.name=v end})
    sounds:AddInput("ExtraHitAsset",{Text="Custom asset ID",Default="",Finished=true,Callback=function(v)hit.asset=tostring(v)end})
    sounds:AddSlider("ExtraHitVolume",{Text="Volume",Default=50,Min=0,Max=100,Rounding=0,Suffix="%",Callback=function(v)hit.volume=v/100 end})
    sounds:AddSlider("ExtraHitPitch",{Text="Pitch",Default=1,Min=0.1,Max=10,Rounding=1,Suffix="x",Callback=function(v)hit.pitch=v end})
    sounds:AddButton({Text="Preview sound",Func=function()if not playSound(true) then notify("Choose a sound or a numeric custom asset ID.")end end})
    local soundHook
    task.spawn(function()
        while running and not soundHook do
            local vm=loadGameModule(lp:FindFirstChild("PlayerScripts"),{"Modules","ClientReplicatedClasses","ClientFighter","ClientItem","ClientViewModel"})
            if vm and type(vm.PlayHitmarkerSound)=="function" then
                local original=vm.PlayHitmarkerSound
                local ok,err=pcall(patch,vm,"PlayHitmarkerSound",function(self,...)
                    local fighter=self.ClientItem and self.ClientItem.ClientFighter
                    local mine=(fighter and (fighter.Player==lp or fighter.IsLocalPlayer==true)) or self==((getEquippedItem() or {}).ViewModel)
                    if running and hit.enabled and mine then
                        local played,result=pcall(playSound)
                         
                        if not played then State.HitSoundError=tostring(result) end
                    end
                    return original(self,...)
                end)
                if ok then soundHook=true else notify("Hit sound adapter: "..tostring(err));break end
            end
            if not soundHook then task.wait(2) end
        end
    end)
    table.insert(restorers,function()onLocalShotHit=nil;for _,sound in ipairs(activeSounds)do pcall(function()sound:Destroy()end)end end)

    local ratio=tab:AddLeftGroupbox("Independent screen scaling")
    Config.ExtraRatioEnabled=false;Config.ExtraRatioWidth=100;Config.ExtraRatioHeight=100
    ratio:AddToggle("ExtraRatioEnabled",{Text="Enable width / height scaling",Default=false,Callback=function(v)Config.ExtraRatioEnabled=v end})
    ratio:AddSlider("ExtraRatioWidth",{Text="Width",Default=100,Min=10,Max=150,Rounding=0,Suffix="%",Callback=function(v)Config.ExtraRatioWidth=v end})
    ratio:AddSlider("ExtraRatioHeight",{Text="Height",Default=100,Min=10,Max=150,Rounding=0,Suffix="%",Callback=function(v)Config.ExtraRatioHeight=v end})
    ratio:AddLabel("Applied by the existing camera renderer.")

    local sky=tab:AddLeftGroupbox("Sky details")
    Config.ExtraSkyStars=3000;Config.ExtraSkySun=20;Config.ExtraSkyMoon=11
    Config.ExtraSkyRotate=false;Config.ExtraSkySpeed=10
    sky:AddLabel("The imported presets are in World > Weather > Skybox.",true)
    sky:AddSlider("ExtraSkyStars",{Text="Stars",Default=3000,Min=0,Max=5000,Rounding=0,Callback=function(v)Config.ExtraSkyStars=v end})
    sky:AddSlider("ExtraSkySun",{Text="Sun size",Default=20,Min=0,Max=50,Rounding=1,Callback=function(v)Config.ExtraSkySun=v end})
    sky:AddSlider("ExtraSkyMoon",{Text="Moon size",Default=11,Min=0,Max=30,Rounding=1,Callback=function(v)Config.ExtraSkyMoon=v end})
    sky:AddToggle("ExtraSkyRotate",{Text="Rotate sky",Default=false,Callback=function(v)Config.ExtraSkyRotate=v end})
    sky:AddSlider("ExtraSkySpeed",{Text="Rotation speed",Default=10,Min=1,Max=100,Rounding=0,Suffix="°/s",Callback=function(v)Config.ExtraSkySpeed=v end})
    connect(RunService.Heartbeat,function(dt)
        local current=Lighting:FindFirstChild("_wxSky")
        if not current or not current:IsA("Sky")then return end
        local hidden=Config.SkyboxHideCelestial
        current.StarCount=hidden and 0 or Config.ExtraSkyStars
        current.SunAngularSize=hidden and 0 or Config.ExtraSkySun
        current.MoonAngularSize=hidden and 0 or Config.ExtraSkyMoon
        if Config.ExtraSkyRotate then current.SkyboxOrientation=Vector3.new(0,(current.SkyboxOrientation.Y+Config.ExtraSkySpeed*dt)%360,0)end
    end)

    local profile=Tabs.Spoofer
    local currency=profile:AddLeftGroupbox("Currency display")
    currency:AddLabel("Local display values only; not spendable balances.",true)
    local currencyValues={}
    local displayDataOriginals={}
    local function applyDisplayData()
        local pdc=Rivals.PlayerDataController
        local current=pdc and pdc.CurrentData and pdc.CurrentData.Data
        local wanted={}
        if running then
            for key,value in pairs(currencyValues)do if value.enabled then wanted[key]=value.amount end end
            if Config.SpooferFavoriteMapEnabled then wanted.FavoriteMap=tostring(Config.SpooferFavoriteMap or "Arena")end
        end
        for data,fields in pairs(displayDataOriginals)do
            for key,saved in pairs(fields)do
                if data~=current or wanted[key]==nil then
                    if data[key]==saved.applied then data[key]=saved.original end
                    fields[key]=nil
                end
            end
            if next(fields)==nil then displayDataOriginals[data]=nil end
        end
        if type(current)~="table" then return false end
        for key,value in pairs(wanted)do
            local fields=displayDataOriginals[current]
            if not fields then fields={};displayDataOriginals[current]=fields end
            local saved=fields[key]
            if not saved then saved={original=current[key]};fields[key]=saved
            elseif current[key]~=saved.applied then saved.original=current[key]end
            current[key]=value;saved.applied=value
        end
        return true
    end
    local function refreshData(key)
        applyDisplayData()
        local pdc=Rivals.PlayerDataController
        if pdc and pdc.CurrentData and pdc.CurrentData.Replicate then
            local ok,why=pcall(pdc.CurrentData.Replicate,pdc.CurrentData,key)
            if not ok then State.DisplayError=tostring(why) end
        end
    end
    for _,spec in ipairs({{"Keys","WeaponKeys"},{"Tokens","UnlockTokens"},{"Event currency","EventCurrency"},{"Glory","Glory"},{"Tickets","SkinTickets"}})do
        local key=spec[2];local value={enabled=false,amount=0};currencyValues[key]=value
        currency:AddToggle("ExtraCurrency"..key,{Text="Override "..spec[1],Default=false,Callback=function(v)value.enabled=v;refreshData(key)end})
        currency:AddInput("ExtraCurrencyValue"..key,{Text=spec[1],Default="0",Numeric=true,Finished=true,Callback=function(v)value.amount=math.max(0,tonumber(v)or 0);refreshData(key)end})
    end
    local function deepCopy(value,seen)
        if type(value)~="table"then return value end
        seen=seen or {};if seen[value]then return seen[value]end
        local out={};seen[value]=out
        for key,v in pairs(value)do out[key]=deepCopy(v,seen)end
        return out
    end
    local history={enabled=false,match_index=1,mode="Ranked",result="Victory",map="Factory",team1score=5,team2score=0,
        dueler_index=1,username="",display_name="",kills=15,deaths=2,assists=6,damage=5000,elo=2000,elo_change=35}
    local function transformHistory(key,data)
        if not history.enabled or type(data)~="table"then return data end
        local copy=deepCopy(data)
        local entry=copy[history.match_index]
        if type(entry)~="table"then return data end
        if key=="LoggedELOEvents"then
            entry.CurrentELO=history.elo;entry.ELOIncrement=history.elo_change
        else
            entry.QueueName=history.mode;entry.Map=history.map
            entry.Scores={history.team1score,history.team2score}
            entry.WinningTeamIndex=history.result=="Victory"and 1 or 2
            local dueler=entry.Duelers and entry.Duelers[history.dueler_index]
            if type(dueler)=="table"then
                if history.username~=""then dueler.Username=history.username end
                if history.display_name~=""then dueler.DisplayName=history.display_name end
                dueler.Eliminations=history.kills;dueler.Deaths=history.deaths
                dueler.Assists=history.assists;dueler.Damage=history.damage
                if history.mode=="Ranked"then dueler.DisplayELO=history.elo end
            end
        end
        return copy
    end
    local historyBox=profile:AddRightGroupbox("Duel history display")
    local function refreshHistory()refreshData("DuelHistory");refreshData("LoggedELOEvents")end
    historyBox:AddToggle("ExtraHistoryEnabled",{Text="Override displayed match",Default=false,Callback=function(v)history.enabled=v;refreshHistory()end})
    for _,spec in ipairs({{"Match index","match_index",1},{"Dueler index","dueler_index",1},{"Team 1 score","team1score",5},{"Team 2 score","team2score",0},
        {"Kills","kills",15},{"Deaths","deaths",2},{"Assists","assists",6},{"Damage","damage",5000},{"ELO","elo",2000},{"ELO change","elo_change",35}})do
        local key=spec[2]
        historyBox:AddInput("ExtraHistory"..key,{Text=spec[1],Default=tostring(spec[3]),Numeric=true,Finished=true,Callback=function(v)
            local n=tonumber(v)or spec[3]
            if key=="match_index"or key=="dueler_index"then n=math.max(1,math.floor(n))end
            history[key]=n;refreshHistory()
        end})
    end
    for _,spec in ipairs({{"Username","username",""},{"Display name","display_name",""},{"Map","map","Factory"}})do
        local key=spec[2]
        historyBox:AddInput("ExtraHistory"..key,{Text=spec[1],Default=spec[3],Finished=true,Callback=function(v)history[key]=v;refreshHistory()end})
    end
    historyBox:AddDropdown("ExtraHistoryMode",{Text="Mode",Values={"Ranked","Casual"},Default=1,Callback=function(v)history.mode=v;refreshHistory()end})
    historyBox:AddDropdown("ExtraHistoryResult",{Text="Result",Values={"Victory","Defeat"},Default=1,Callback=function(v)history.result=v;refreshHistory()end})
    local displayStatus=currency:AddLabel("Data adapters: waiting",true)
    local hookedReaders=setmetatable({},{__mode="k"})
    local readDepth=0
    local function installDisplayReader(target)
        if not target or type(target.Get)~="function" then return false end
        if hookedReaders[target]==target.Get then return true end
        local original=target.Get
        local replacement=function(self,key,...)
             
            readDepth=readDepth+1
            local data=table.pack(pcall(original,self,key,...))
            readDepth=readDepth-1
            if not data[1] then error(data[2],0) end
            if running and readDepth==0 then
                local value=currencyValues[key]
                if value and value.enabled then data[2]=value.amount;data.n=math.max(data.n,2)
                elseif key=="FavoriteMap"and Config.SpooferFavoriteMapEnabled then data[2]=tostring(Config.SpooferFavoriteMap or "Arena");data.n=math.max(data.n,2)
                elseif key=="DuelHistory"or key=="LoggedELOEvents"then data[2]=transformHistory(key,data[2])end
            end
            return table.unpack(data,2,data.n)
        end
        patch(target,"Get",replacement)
        hookedReaders[target]=replacement
        return true
    end
    local function installDisplayReaders()
        local pdc=Rivals.PlayerDataController
        if not pdc then
            pdc=loadGameModule(lp:FindFirstChild("PlayerScripts"),{"Controllers","PlayerDataController"})
            Rivals.PlayerDataController=pdc
        end
        local a=installDisplayReader(pdc)
        local b=installDisplayReader(pdc and pdc.CurrentData)
        displayStatus:SetText("Data adapters: controller "..(a and "ready" or "waiting")..", current data "..(b and "ready" or "waiting"))
        return a and b
    end
    local function refreshDisplays()
        local ok,why=pcall(installDisplayReaders)
        if not ok then displayStatus:SetText("Data adapter error: "..tostring(why));return end
        for key in pairs(currencyValues)do refreshData(key)end
        refreshData("FavoriteMap")
        refreshHistory()
        local pdc=Rivals.PlayerDataController
        local data=pdc and pdc.CurrentData and pdc.CurrentData.Data
        if data then
            local reports={}
            for key,value in pairs(currencyValues)do
                if value.enabled then reports[#reports+1]=key..": "..tostring(data[key])end
            end
            if Config.SpooferFavoriteMapEnabled then reports[#reports+1]="FavoriteMap: "..tostring(data.FavoriteMap)end
            if #reports>0 then displayStatus:SetText("Current display data — "..table.concat(reports,"; "))end
        end
    end
    currency:AddButton({Text="Refresh displays / retry",Func=refreshDisplays})
    task.spawn(function()
        while running do
            local pdc=Rivals.PlayerDataController
            refreshDisplays()
            task.wait(2)
        end
    end)
    table.insert(restorers,function()
        for _,v in pairs(currencyValues)do v.enabled=false end;history.enabled=false
        applyDisplayData()
        for key in pairs(currencyValues)do refreshData(key)end;refreshHistory()
        refreshData("FavoriteMap")
    end)

    local badges=profile:AddLeftGroupbox("Local badge attributes")
    badges:AddLabel("Display attributes only; no account privileges.",true)
    local originals={}
    for _,spec in ipairs({{"Premium","IsPremium"},{"Verified","HasVerifiedBadge"},{"Influencer","IsInfluencer"},{"Admin","IsRobloxEmployee"}})do
        local attr=spec[2]
        originals[attr]={value=lp:GetAttribute(attr)}
        badges:AddToggle("ExtraBadge"..attr,{Text=spec[1],Default=false,Callback=function(v)
            lp:SetAttribute(attr,v and true or originals[attr].value)
        end})
    end
    table.insert(restorers,function()for key,v in pairs(originals)do lp:SetAttribute(key,v.value)end end)

    local board=profile:AddRightGroupbox("Leaderboard display")
    local boardState={}
    local refreshBoardUI=function()end
    for _,spec in ipairs({{"ELO","Highest ELO"},{"Streak","Current Highest Win Streak"},{"Kills","Most Eliminations"},{"Wins","Most Wins"},{"Level","Highest Level"}})do
        local key=spec[2];local cfg={enabled=false,value=0};boardState[key]=cfg
        board:AddToggle("ExtraBoard"..spec[1],{Text="Override "..spec[1],Default=false,Callback=function(v)cfg.enabled=v;refreshBoardUI()end})
        board:AddInput("ExtraBoardValue"..spec[1],{Text=spec[1],Default="0",Numeric=true,Finished=true,Callback=function(v)cfg.value=tonumber(v)or 0;refreshBoardUI()end})
    end
    local legacyBoards={
        ["Highest ELO"]={"SpooferRankedEloEnabled","SpooferRankedElo"},
        ["Highest Level"]={"SpooferLevelEnabled","SpooferLevel"},
        ["Most Wins"]={"SpooferCasualWinsEnabled","SpooferCasualWins"},
        ["Current Highest Win Streak"]={"SpooferWinStreakEnabled","SpooferWinStreak"},
    }
    local function effectiveBoard(key)
        local cfg=boardState[key]
        if not running then return {enabled=false,value=0}end
        local legacy=legacyBoards[key]
        if not cfg.enabled and legacy and Config[legacy[1]]then return {enabled=true,value=tonumber(Config[legacy[2]])or 0}end
        return cfg
    end
     
    local textNodes=setmetatable({},{__mode="k"})
    local function compactName(value)return tostring(value):lower():gsub("[^%w]","")end
    local function formatDisplayNumber(n)
        return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
    end
    local function displayTextFor(obj)
        if not running or not obj.Parent then return nil end
        local parent=obj.Parent
        local name,container=compactName(obj.Name),compactName(parent.Name)
        local key=name
        if name=="value"or name=="amount"or name=="count"or name=="text"then key=container end
        local ancestor=parent
        while ancestor and ancestor~=game do
            local uid=ancestor:GetAttribute("UserId")or ancestor:GetAttribute("PlayerId")
            if uid and tonumber(uid)~=lp.UserId then return nil end
            ancestor=ancestor.Parent
        end
        if (key=="favoritemap"or key=="favouritemap")and Config.SpooferFavoriteMapEnabled then
            return tostring(Config.SpooferFavoriteMap or "Arena")
        end
        local currencyKey=({weaponkeys="WeaponKeys",unlocktokens="UnlockTokens",eventcurrency="EventCurrency",glory="Glory",skintickets="SkinTickets"})[key]
        local value=currencyKey and currencyValues[currencyKey]
        if value and value.enabled and obj.Text:find("%d")then return formatDisplayNumber(value.amount)end
        local boardKey=({wins="Most Wins",level="Highest Level",streak="Current Highest Win Streak",elo="Highest ELO",kills="Most Eliminations"})[key]
        local cfg=boardKey and effectiveBoard(boardKey)
        if cfg and cfg.enabled and obj.Text:find("%d")then return formatDisplayNumber(cfg.value)end
    end
    local function updateText(obj,record)
        if record.busy or not obj.Parent then return end
        local desired=displayTextFor(obj)
        if desired then
            if obj.Text~=record.applied then record.original=obj.Text end
            record.busy=true;obj.Text=desired;record.applied=desired;record.busy=false
        elseif record.applied then
            record.busy=true
            if obj.Text==record.applied then obj.Text=record.original end
            record.applied=nil;record.busy=false
        end
    end
    local function registerDisplayText(obj)
        if textNodes[obj]or not(obj:IsA("TextLabel")or obj:IsA("TextButton"))then return end
        local record={original=obj.Text};textNodes[obj]=record
        connect(obj:GetPropertyChangedSignal("Text"),function()updateText(obj,record)end)
        updateText(obj,record)
    end
    local playerGui=lp:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        for _,obj in ipairs(playerGui:GetDescendants())do registerDisplayText(obj)end
        connect(playerGui.DescendantAdded,registerDisplayText)
    end
    local function refreshTextDisplays()
        local count=0
        for obj,record in pairs(textNodes)do
            if obj.Parent then updateText(obj,record);if record.applied then count=count+1 end end
        end
        return count
    end
    table.insert(restorers,refreshTextDisplays)
    local boardController
    local boardBackups={}
    local boardStatus=board:AddLabel("Boards: waiting for controller",true)
    local boardAttributes={}
    local function boardFingerprint(list)
        local parts={}
        for i,row in ipairs(list)do
            parts[i]=tostring(row)..":"..tostring(row.key or row.UserId or row.UserID or row.PlayerId)..":"..tostring(row.value or row.Value)
        end
        return table.concat(parts,"|")
    end
    local function restoreBoardRow(list,saved)
         
        for i=#list,1,-1 do
            if list[i]==saved.row then
                table.remove(list,i)
                if saved.originalRow then table.insert(list,math.min(saved.index,#list+1),saved.originalRow)end
                return
            end
        end
    end
    local function updateBoards()
        if not boardController then
            boardController=loadGameModule(lp:FindFirstChild("PlayerScripts"),{"Controllers","LeaderboardController"})
        end
        if not boardController then boardStatus:SetText("Boards: controller not loaded; retry after joining the lobby.");return end
        local available=0
        for key,cfg in pairs(boardState)do
            cfg=effectiveBoard(key)
            local serial=boardController.LeaderboardSerials and boardController.LeaderboardSerials[key]
            if serial and type(serial.Players)=="table"then
                available=available+1
                local list=serial.Players
                local saved=boardBackups[key]
                local unchanged=cfg.enabled and saved and saved.list==list and saved.value==cfg.value
                    and saved.fingerprint==boardFingerprint(list)
                if not unchanged then
                if saved then restoreBoardRow(saved.list,saved);boardBackups[key]=nil end
                if cfg.enabled then
                    local originalRow,index
                    for i=#list,1,-1 do
                        local p=list[i]
                        if type(p)=="table" and tonumber(p.key or p.UserId or p.UserID or p.PlayerId)==lp.UserId then
                            originalRow=p;index=i;table.remove(list,i)
                        end
                    end
                    local row=originalRow and deepCopy(originalRow)or {key=tostring(lp.UserId),UserId=lp.UserId}
                    row.value=cfg.value
                    if row.Value~=nil then row.Value=cfg.value end
                    local rank=1
                    for i,p in ipairs(list)do
                        if (tonumber(p.value or p.Value)or 0)>=cfg.value then rank=i+1 else break end
                    end
                    table.insert(list,rank,row)
                    boardBackups[key]={list=list,row=row,originalRow=originalRow,index=index,
                        value=cfg.value,fingerprint=boardFingerprint(list)}
                end
                if (cfg.enabled or saved)and boardController.Refreshed then
                    local ok,why=pcall(boardController.Refreshed.Fire,boardController.Refreshed,key)
                    if not ok then error("Refreshed("..key.."): "..tostring(why))end
                end
                end
            end
        end
        for _,spec in ipairs({{"Highest Level","Level"},{"Current Highest Win Streak","StatisticDuelsWinStreak"}})do
            local cfg=effectiveBoard(spec[1]);local attr=spec[2]
            if cfg.enabled then
                if not boardAttributes[attr]then boardAttributes[attr]={value=lp:GetAttribute(attr)}end
                if lp:GetAttribute(attr)~=cfg.value then lp:SetAttribute(attr,cfg.value)end
            elseif boardAttributes[attr]then
                lp:SetAttribute(attr,boardAttributes[attr].value);boardAttributes[attr]=nil
            end
        end
        local names={}
        if available==0 then for key in pairs(boardController.LeaderboardSerials or {})do names[#names+1]=tostring(key)end end
        boardStatus:SetText("Boards available: "..available.." / 5. Text displays updated: "..refreshTextDisplays()
            ..(available==0 and (". Loaded names: "..table.concat(names,", "))or ""))
    end
    local function refreshBoards()
        local textOK,textError=pcall(refreshTextDisplays)
        if not textOK then State.DisplayError=tostring(textError)end
        local ok,why=pcall(updateBoards)
        if not ok then boardStatus:SetText("Leaderboard error: "..tostring(why))end
    end
    refreshBoardUI=refreshBoards
    board:AddButton({Text="Refresh leaderboards / retry",Func=refreshBoards})
    local boardAt=0
    connect(RunService.Heartbeat,function()if tick()-boardAt>5 then boardAt=tick();refreshBoards()end end)
    local updateRemote=ReplicatedStorage:FindFirstChild("Remotes")
    updateRemote=updateRemote and updateRemote:FindFirstChild("Misc")
    updateRemote=updateRemote and updateRemote:FindFirstChild("UpdateLeaderboard")
    if updateRemote and updateRemote:IsA("RemoteEvent")then
        connect(updateRemote.OnClientEvent,function()task.defer(function()if running then refreshBoards()end end)end)
    end
    table.insert(restorers,function()
        for _,saved in pairs(boardBackups)do restoreBoardRow(saved.list,saved)end
        table.clear(boardBackups)
        for _,v in pairs(boardState)do v.enabled=false end
        pcall(updateBoards)
    end)
end


do
    local injector=Tabs.Inventory:AddRightGroupbox("Backpack injector with skins")
    injector:AddLabel("Local weapon inventory entries with cosmetic skins. Does not grant server ownership.",true)
    local weapon,skin="None","None"
    local status=injector:AddLabel("Choose a weapon and skin, then inject locally.",true)
    local added={}
    local function skinNames()
        local out={"None"}
        local catalog=Rivals.Cosmetics and Rivals.Cosmetics.Cosmetics
        for name,record in pairs(catalog or {})do
            if type(record)=="table"and record.Type=="Skin"and record.ItemName==weapon then out[#out+1]=name end
        end
        table.sort(out,function(a,b)if a=="None"then return b~="None"elseif b=="None"then return false else return a<b end end)
        return out
    end
    injector:AddDropdown("BackpackWeapon",{Text="Weapon",Values={"None"},Default="None",Callback=function(v)
        weapon=v;skin="None"
        if Options.BackpackSkin then Options.BackpackSkin:SetValues(skinNames());Options.BackpackSkin:SetValue("None")end
    end})
    injector:AddDropdown("BackpackSkin",{Text="Skin",Values={"None"},Default="None",Callback=function(v)skin=v end})
    local function inject()
        if weapon=="None"then status:SetText("Choose a weapon first.");return end
        if not Config.GameVisuals then Toggles.GameVisuals:SetValue(true)end
        if not GameVisuals.ready()then status:SetText("Cosmetics modules are loading. Try Inject again shortly.");return end
        if skin~="None"then
            local entry=Rivals.Cosmetics and Rivals.Cosmetics.Cosmetics[skin]
            if not entry or entry.Type~="Skin"or entry.ItemName~=weapon then status:SetText("Choose a skin for this weapon.");return end
        end
        if not added[weapon]then
            local choices=GameVisuals.Choices[weapon]
            added[weapon]={visibility=GameVisuals.WeaponVisibility[weapon],skin=choices and choices.Skin,hadChoices=choices~=nil}
        end
        GameVisuals.setFor(weapon,"Skin",skin)
        GameVisuals.setWeaponVisibility(weapon,true)
        status:SetText("Local entry requested: "..weapon.." / "..skin..". "..tostring(State.GVStatus or ""))
    end
    local function remove(weaponName)
        local saved=added[weaponName]
        if not saved then return end
        local choices=GameVisuals.Choices[weaponName]
        if choices then
            choices.Skin=saved.skin
            if not saved.hadChoices and next(choices)==nil then GameVisuals.Choices[weaponName]=nil end
        end
        GameVisuals.setWeaponVisibility(weaponName,saved.visibility)
        pcall(GameVisuals.apply)
        pcall(GameVisuals.saveConfig)
        added[weaponName]=nil
    end
    injector:AddButton({Text="Inject weapon + skin locally",Func=function()
        local ok,why=pcall(inject);if not ok then status:SetText("Injector error: "..tostring(why))end
    end})
    injector:AddButton({Text="Remove selected injection",Func=function()remove(weapon);status:SetText("Selected injection restored.")end})
    injector:AddButton({Text="Remove all injections",Func=function()for name in pairs(added)do remove(name)end;status:SetText("Injections restored.")end})
    task.spawn(function()
        local lastWeapons,lastSkins
        while running do
            local ok,why=pcall(function()
                local names=GameVisuals.weaponList()
                local signature=table.concat(names,"\n")
                if signature~=lastWeapons then Options.BackpackWeapon:SetValues(names);lastWeapons=signature end
                local skins=skinNames();signature=table.concat(skins,"\n")
                if signature~=lastSkins then Options.BackpackSkin:SetValues(skins);lastSkins=signature end
            end)
            if not ok then status:SetText("Catalog error: "..tostring(why))end
            task.wait(2)
        end
    end)
    table.insert(restorers,function()for name in pairs(added)do pcall(remove,name)end end)
end

do
    local tab=Tabs.Inventory
    local box=tab:AddLeftGroupbox("Local catalog visibility")
    local state={kind="Skin",rarity="Common",name="",weapon="",inverted=false}
    local function entryList(mode)
        local catalog=Rivals.Cosmetics and Rivals.Cosmetics.Cosmetics
        if not catalog then notify("Cosmetic catalog is still loading.");return nil end
        local out={}
        for name,item in pairs(catalog)do
            if type(item)=="table"then
                local match=mode=="all"
                    or (mode=="type"and item.Type==state.kind)
                    or (mode=="rarity"and item.Type==state.kind and item.Rarity==state.rarity)
                    or (mode=="specific"and name==state.name and item.Type==state.kind
                        and (item.Type~="Skin"or state.weapon==""or item.ItemName==state.weapon))
                    or (mode=="weapon"and (item.Type~="Skin"or item.ItemName==state.weapon))
                if match then out[#out+1]=name end
            end
        end
        return out
    end
    local function visibility(mode,value)
        if not Config.GameVisuals then notify("Enable oxycodone Cosmetics first.");return end
        local names=entryList(mode)
        if not names then return end
        GameVisuals.setInventoryVisibility(names,value)
        notify(tostring(#names).." local catalog entries updated.")
    end
    box:AddLabel("These controls change the local catalog, not account ownership.",true)
    box:AddDropdown("ExtraCosmeticType",{Text="Type",Values={"Skin","Wrap","Charm","Finisher"},Default=1,Callback=function(v)state.kind=v end})
    box:AddDropdown("ExtraCosmeticRarity",{Text="Rarity",Values={"Common","Rare","Legendary","Mythical","Unique","Unobtainable"},Default=1,Callback=function(v)state.rarity=v end})
    box:AddInput("ExtraCosmeticName",{Text="Cosmetic name",Default="",Finished=true,Callback=function(v)state.name=v end})
    box:AddInput("ExtraCosmeticWeapon",{Text="Weapon name",Default="",Finished=true,Callback=function(v)state.weapon=v end})
    for _,spec in ipairs({{"selected rarity","rarity"},{"selected type","type"},{"specific cosmetic","specific"},{"weapon cosmetics","weapon"},{"all cosmetics","all"}})do
        local mode=spec[2]
        box:AddButton({Text="Show "..spec[1],Func=function()visibility(mode,true)end})
        box:AddButton({Text="Hide "..spec[1],Func=function()visibility(mode,false)end})
    end
    box:AddButton({Text="Reset catalog overrides",Func=function()GameVisuals.setInventoryVisibility(nil,nil)end})
    local equip=tab:AddRightGroupbox("Apply cosmetic")
    equip:AddLabel("Uses the type, name and weapon fields on the left.",true)
    equip:AddToggle("ExtraEquipInverted",{Text="Invert wrap",Default=false,Callback=function(v)state.inverted=v end})
    local function apply(all)
        if not Config.GameVisuals then notify("Enable oxycodone Cosmetics first.");return end
        local catalog=Rivals.Cosmetics and Rivals.Cosmetics.Cosmetics
        local item=catalog and catalog[state.name]
        if not item or item.Type~=state.kind then notify("Enter an exact cosmetic name matching the selected type.");return end
        local weapons={}
        if all then
            for _,weapon in ipairs(GameVisuals.weaponList())do
                if weapon~="None"and (item.Type~="Skin"or item.ItemName==weapon)then weapons[#weapons+1]=weapon end
            end
        else
            local weapon=state.weapon
            if weapon==""then local held=getEquippedItem();weapon=held and held.Name end
            if not weapon or weapon==""then notify("Enter a weapon or equip one.");return end
            if item.Type=="Skin"and item.ItemName~=weapon then notify("This skin belongs to "..tostring(item.ItemName));return end
            weapons[1]=weapon
        end
        for _,weapon in ipairs(weapons)do GameVisuals.setFor(weapon,state.kind,state.name,state.inverted)end
        notify("Applied locally to "..#weapons.." compatible weapons.")
    end
    equip:AddButton({Text="Apply to selected / held weapon",Func=function()apply(false)end})
    equip:AddButton({Text="Apply to all compatible weapons",Func=function()apply(true)end})
    equip:AddButton({Text="Show all weapons locally",Func=function()
        if Config.GameVisuals then GameVisuals.setUnlockWeapons(true)else notify("Enable oxycodone Cosmetics first.")end
    end})
    equip:AddButton({Text="Restore weapon catalog",Func=function()GameVisuals.setUnlockWeapons(false);GameVisuals.setWeaponVisibility(nil,nil)end})
    equip:AddButton({Text="Show selected weapon locally",Func=function()GameVisuals.setWeaponVisibility(state.weapon,true)end})
    equip:AddButton({Text="Hide selected weapon locally",Func=function()GameVisuals.setWeaponVisibility(state.weapon,false)end})
end


do
    local tab=Tabs.Misc
    local cfg={anonymous=false,avatar=false,userId=lp.UserId,display=false,username=false,displayName=lp.DisplayName,userName=lp.Name}
    local box=tab:AddLeftGroupbox("Names and thumbnails")
    local tracked=setmetatable({}, {__mode="k"})
    local fakeNames={}
    local refresh,refreshAvatars
    local function replacePlain(text,old,new)
        if old==""then return text end
        local pattern=old:gsub("([^%w])","%%%1")
        return (text:gsub(pattern,function()return new end))
    end
    local function desiredText(original)
        local text=original
        if cfg.anonymous then
            for _,player in ipairs(Players:GetPlayers())do
                if not fakeNames[player.UserId]then fakeNames[player.UserId]="Player"..tostring(player.UserId%100000)end
                text=replacePlain(text,player.DisplayName,fakeNames[player.UserId])
                text=replacePlain(text,player.Name,fakeNames[player.UserId])
            end
        else
            if cfg.display then text=replacePlain(text,lp.DisplayName,cfg.displayName)end
            if cfg.username then text=replacePlain(text,lp.Name,cfg.userName)end
        end
        return text
    end
    local function applyObject(obj,saved)
        if not obj.Parent or saved.writing then return end
        local value=saved.original
        if saved.property=="Text"then value=desiredText(value)
        else
            if cfg.anonymous then
                for _,player in ipairs(Players:GetPlayers())do
                    value=value:gsub("%f[%d]"..tostring(player.UserId).."%f[%D]","6942067")
                end
            elseif cfg.avatar then
                value=value:gsub("%f[%d]"..tostring(lp.UserId).."%f[%D]",tostring(cfg.userId))
            end
        end
        if obj[saved.property]~=value then
            saved.writing=true;obj[saved.property]=value;saved.writing=false
        end
    end
    local function register(obj)
        if tracked[obj]then return end
        local property
        if obj:IsA("TextLabel")or obj:IsA("TextButton")then property="Text"
        elseif obj:IsA("ImageLabel")or obj:IsA("ImageButton")then property="Image"end
        if not property then return end
        local saved={property=property,original=obj[property]}
        tracked[obj]=saved
        saved.connection=obj:GetPropertyChangedSignal(property):Connect(function()
            if saved.writing then return end
            saved.original=obj[property]
            applyObject(obj,saved)
        end)
        applyObject(obj,saved)
    end
    local roots={}
    local function scan()
        local gui=lp:FindFirstChildOfClass("PlayerGui")
        for _,root in ipairs({gui,workspace})do
            if root and not roots[root]then
                roots[root]=true
                for _,obj in ipairs(root:GetDescendants())do register(obj)end
                connect(root.DescendantAdded,register)
            end
        end
    end
    refresh=function()
        scan()
        for obj,saved in pairs(tracked)do applyObject(obj,saved)end
    end
    box:AddInput("ExtraDisplayName",{Text="Display name",Default=lp.DisplayName,Finished=true,Callback=function(v)cfg.displayName=v;refresh()end})
    box:AddToggle("ExtraDisplayNameEnabled",{Text="Override display name",Default=false,Callback=function(v)cfg.display=v;refresh()end})
    box:AddInput("ExtraUsername",{Text="Username",Default=lp.Name,Finished=true,Callback=function(v)cfg.userName=v;refresh()end})
    box:AddToggle("ExtraUsernameEnabled",{Text="Override username",Default=false,Callback=function(v)cfg.username=v;refresh()end})
    local avatar=tab:AddRightGroupbox("Local outfit preview")
    avatar:AddLabel("Copies clothing, accessories and face; keeps body geometry.",true)
    local backups=setmetatable({}, {__mode="k"})
    local generations=setmetatable({}, {__mode="k"})
    local rigs={}
    local function clothing(obj)
        return obj:IsA("Accessory")or obj:IsA("Shirt")or obj:IsA("Pants")or obj:IsA("ShirtGraphic")or obj:IsA("BodyColors")
    end
    local function restoreCharacter(char)
        local saved=backups[char]
        if not saved then return end
        for _,obj in ipairs(saved.added)do pcall(function()obj:Destroy()end)end
        for _,entry in ipairs(saved.removed)do
            if entry.parent and entry.parent.Parent then pcall(function()entry.object.Parent=entry.parent end)end
        end
        if char.Parent then
            for part,color in pairs(saved.colors)do if part.Parent then part.Color=color end end
        end
        backups[char]=nil
    end
    local function outfit(char,userId)
        generations[char]=(generations[char]or 0)+1
        local generation=generations[char]
        restoreCharacter(char)
        if not userId then return end
        task.spawn(function()
            local rig=rigs[userId]
            if not rig then
                local ok,value=pcall(Players.CreateHumanoidModelFromUserId,Players,userId)
                if not ok then if running then notify("Avatar preview unavailable: "..tostring(value))end;return end
                rig=value
                if not running then rig:Destroy();return end
                if rigs[userId]then rig:Destroy();rig=rigs[userId]else rigs[userId]=rig end
            end
            if not running or not char.Parent or generations[char]~=generation then return end
            local saved={removed={},added={},colors={}};backups[char]=saved
            for _,obj in ipairs(char:GetChildren())do
                if clothing(obj)then saved.removed[#saved.removed+1]={object=obj,parent=char};obj.Parent=nil end
                if obj:IsA("BasePart")then saved.colors[obj]=obj.Color end
            end
            local head=char:FindFirstChild("Head")
            if head then
                for _,obj in ipairs(head:GetChildren())do
                    if obj:IsA("Decal")then saved.removed[#saved.removed+1]={object=obj,parent=head};obj.Parent=nil end
                end
            end
            for _,obj in ipairs(rig:GetChildren())do
                if clothing(obj)then
                    local copy=obj:Clone()
                    for _,part in ipairs(copy:GetDescendants())do
                        if part:IsA("BasePart")then part.CanCollide=false;part.Massless=true end
                    end
                    copy.Parent=char;saved.added[#saved.added+1]=copy
                    if copy:IsA("Accessory")then
                        local handle=copy:FindFirstChild("Handle")
                        if handle then
                            local old=handle:FindFirstChild("AccessoryWeld");if old then old:Destroy()end
                            local attachment=handle:FindFirstChildOfClass("Attachment")
                            local target=attachment and char:FindFirstChild(attachment.Name,true)
                            if target and target:IsDescendantOf(copy)then target=nil end
                            if not target and attachment then
                                for _,part in ipairs(char:GetChildren())do
                                    if part:IsA("BasePart")then target=part:FindFirstChild(attachment.Name);if target then break end end
                                end
                            end
                            if target and not target:IsA("Attachment")then target=nil end
                            if target or head then
                                local weld=Instance.new("Weld");weld.Part0=handle
                                weld.Part1=target and target.Parent or head
                                weld.C0=attachment and attachment.CFrame or copy.AttachmentPoint
                                weld.C1=target and target.CFrame or CFrame.new(0,0.5,0)
                                weld.Parent=handle
                            end
                        end
                    end
                end
            end
            local sourceHead=rig:FindFirstChild("Head")
            if head and sourceHead then
                for _,obj in ipairs(sourceHead:GetChildren())do
                    if obj:IsA("Decal")then local copy=obj:Clone();copy.Parent=head;saved.added[#saved.added+1]=copy end
                end
            end
        end)
    end
    refreshAvatars=function()
        for _,player in ipairs(Players:GetPlayers())do
            if player.Character then
                outfit(player.Character,cfg.anonymous and 6942067 or (player==lp and cfg.avatar and cfg.userId or nil))
            end
        end
    end
    avatar:AddInput("ExtraAvatarUserId",{Text="Avatar user ID",Default=tostring(lp.UserId),Numeric=true,Finished=true,Callback=function(v)
        local id=tonumber(v)
        if id and id>0 and id%1==0 then cfg.userId=id;if cfg.avatar then refreshAvatars();refresh()end end
    end})
    avatar:AddToggle("ExtraAvatarEnabled",{Text="Enable local outfit",Default=false,Callback=function(v)cfg.avatar=v;refreshAvatars();refresh()end})
    box:AddToggle("ExtraAnonymous",{Text="Anonymous names, thumbnails and outfits",Default=false,Callback=function(v)
        cfg.anonymous=v;refresh();refreshAvatars()
    end})
    local function watch(player)
        connect(player.CharacterAdded,function(char)
            task.delay(0.5,function()
                if running then outfit(char,cfg.anonymous and 6942067 or (player==lp and cfg.avatar and cfg.userId or nil))end
            end)
        end)
    end
    for _,player in ipairs(Players:GetPlayers())do watch(player)end
    connect(Players.PlayerAdded,function(player)watch(player);if cfg.anonymous then refresh()end end)
    table.insert(restorers,function()
        cfg.anonymous=false;cfg.avatar=false;cfg.display=false;cfg.username=false
        for obj,saved in pairs(tracked)do
            saved.connection:Disconnect()
            if obj.Parent then pcall(function()obj[saved.property]=saved.original end)end
        end
        for char in pairs(backups)do restoreCharacter(char)end
        for _,rig in pairs(rigs)do rig:Destroy()end
    end)
end

 
menu:AddLabel("Menu keybind"):AddKeyPicker("MenuKeybind",{
    Default="RightShift", Mode="Toggle", NoUI=true, Text="Open / close menu",
})
Library.ToggleKeybind=Options.MenuKeybind
menu:AddButton({Text="Reset menu key to RightShift",Func=function()
    Options.MenuKeybind:SetValue({"RightShift","Toggle"})
    Library.ToggleKeybind=Options.MenuKeybind
end})

do
    local TeleportService=game:GetService("TeleportService")
    local HttpService=game:GetService("HttpService")
    local box=settings:AddLeftGroupbox("Server")
    local status=box:AddLabel("Ready",true)
    local busy=false
    local operation=0
    local function setStatus(message)
        if running and status.SetText then status:SetText(message) end
    end
    local function finish(message)
        busy=false
        setStatus(message)
    end
    local function teleport(jobId,token)
        if not running or operation~=token then return end
        setStatus("Joining server...")
        local ok,why=pcall(function()
            if type(jobId)=="string" and jobId~="" then
                TeleportService:TeleportToPlaceInstance(game.PlaceId,jobId,lp)
            else
                TeleportService:Teleport(game.PlaceId,lp)
            end
        end)
        if not ok then finish("Teleport failed: "..tostring(why)); return end
        task.delay(25,function()
            if running and busy and operation==token then
                finish("Teleport has not completed. You can retry.")
            end
        end)
    end
    connect(TeleportService.TeleportInitFailed,function(player,result,message,placeId)
        if player~=lp or not busy or placeId~=game.PlaceId then return end
        finish("Teleport failed: "..tostring(message or result))
    end)
    local function begin()
        if busy then notify("A server action is already in progress."); return nil end
        busy=true
        operation=operation+1
        return operation
    end
    box:AddButton({Text="Rejoin current server",Func=function()
        local token=begin()
        if token then task.spawn(function() teleport(game.JobId,token) end) end
    end})
    box:AddButton({Text="Server hop",Func=function()
        local token=begin()
        if not token then return end
        task.spawn(function()
            local ok,why=pcall(function()
                local cursor=nil
                local seenCursors={}
                for page=1,10 do
                    if not running or operation~=token then return end
                    setStatus("Finding a public server... page "..page)
                    local url="https://games.roblox.com/v1/games/"..tostring(game.PlaceId)
                        .."/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
                    if cursor then url=url.."&cursor="..HttpService:UrlEncode(cursor) end
                    local body=game:HttpGet(url)
                    if not running or operation~=token then return end
                    local data=HttpService:JSONDecode(body)
                    if type(data)~="table" or type(data.data)~="table" then
                        error("Unexpected server-list response")
                    end
                    local candidates={}
                    for _,server in ipairs(data.data) do
                        if type(server.id)=="string" and server.id~="" and server.id~=game.JobId
                            and type(server.playing)=="number" and type(server.maxPlayers)=="number"
                            and server.playing<server.maxPlayers then
                            candidates[#candidates+1]=server.id
                        end
                    end
                    if #candidates>0 then teleport(candidates[math.random(#candidates)],token); return end
                    cursor=data.nextPageCursor
                    if type(cursor)~="string" or cursor=="" or seenCursors[cursor] then break end
                    seenCursors[cursor]=true
                    task.wait(0.4)
                end
                finish("No different server with an open slot was found.")
            end)
            if not ok and running and operation==token then
                finish("Server search failed: "..tostring(why))
            end
        end)
    end})
    box:AddLabel("Server hop searches public servers in this place.")
    box:AddLabel("Save changes before leaving. Run the script again after joining.")
end

 
task.spawn(function()
     
    local api={(type(readfile)=="function"),(type(writefile)=="function"),
        (type(listfiles)=="function"),(type(isfile)=="function"),
        (type(isfolder)=="function"),(type(makefolder)=="function")}
    for _,available in ipairs(api) do
        if not available then
            if running then
                settings:AddRightGroupbox("Saved settings"):AddLabel(
                    "Config/theme saving needs readfile, writefile, listfiles, isfile, isfolder and makefolder.",true)
            end
            return
        end
    end
    local function addon(name,setup)
        local ok,why=pcall(function()
            local source=game:HttpGet(repo.."addons/"..name..".lua")
            if not running then return end
            local compiled,err=loadstring(source)
            if not compiled then error(err) end
            local manager=compiled()
            if type(manager)~="table" then error("Invalid add-on response") end
            if not running then return end
            manager:SetLibrary(Library)
            manager:SetFolder("oxycodoneObsidian/UI")
            setup(manager)
        end)
        if not ok and running then notify(name.." could not load: "..tostring(why)) end
    end
    addon("ThemeManager",function(manager)
        manager:ApplyToTab(settings)
    end)
    addon("SaveManager",function(manager)
        manager:IgnoreThemeSettings()
         
         
        manager:SetIgnoreIndexes({"GVWeapon","GVSkin","GVCharm","GVWrap",
            "GVFinisher","GVEmote","GVRankWep","GVRankLook"})
        if manager.SetLoadingOrder then
            manager:SetLoadingOrder(true,{"Input","Slider","Dropdown","ColorPicker","KeyPicker","Toggle"})
        end
        manager:BuildConfigSection(settings)
        menu:AddLabel("Configs save UI settings and the menu key.",true)
        menu:AddLabel("Cosmetic selections use oxycodone's Remember picks.",true)
        task.spawn(function()
            local deadline=tick()+20
            while running and not Rivals.Cosmetics and tick()<deadline do task.wait(0.25) end
            if not running then return end
            local ok,why=pcall(function() manager:LoadAutoloadConfig() end)
            if not ok then notify("Autoload failed: "..tostring(why)) end
        end)
    end)
end)
