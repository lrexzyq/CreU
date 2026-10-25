if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().meoww_loaded then return end
getgenv().meoww_loaded = true

task.spawn(function()
    pcall(function()
        for _, v in pairs(getgc()) do
            if type(v) == "function" and debug.info(v, "s"):find("AnalyticsPipelineController") then
                hookfunction(v, function() end)
            end
        end
    end)
end)

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local VirtualUser      = game:GetService("VirtualUser")
local HttpService      = game:GetService("HttpService")
local workspace        = game:GetService("Workspace")
local localplayer      = Players.LocalPlayer

getgenv().config = {
    nc = false, flyEnabled = false, flySpeed = 50, doubleJumpEnabled = false,
    fakePositionEnabled = false, desyncEnabled = false,
    evasionEnabled = false, evasionIntensity = 3.0,
    blinkEnabled = false, blinkRadius = 80, blinkRate = 60,
    ghostEnabled = false, ghostDistance = 150,
    glideEnabled = false, glideSpeed = 280, glideAccel = 18,
    VoidEnabled = false, voidX = 1e8, voidY = 1e8, voidZ = 1e8,
    voidSpamEnabled = false, voidSpamInterval = 0.016, voidSpamBurst = 5,
    voidSmooth = false, voidSmoothAlpha = 0.5, voidPattern = "random",
    voidAxisX = true, voidAxisY = true, voidAxisZ = true,
    voidXPos = 2500, voidXNeg = 2500, voidYPos = 1500, voidYNeg = 1500, voidZPos = 2500, voidZNeg = 2500,
    orbit = false, orbitSpeed = 90, orbitDistance = 8, orbitHeight = 0,
    wallbangEnabled = false, rapidFire = false, teleportEnemyEnabled = false,
    sling = false, daggerBypass = false, AntiEnemy = false,
    slingRage = false, antiProj = false, fastReload = false, antiClose = false,
    antiAimEnabled = false, pitchAngle = 0, yawAngle = 0, spinEnabled = false,
    underMapEnabled = false, underMapY = -500,
    riotAbuserEnabled = false, riotAbuserDistance = 300, riotAbuserX = 30,
    riotAbuserY = 8, riotAbuserZ = 30, riotAbuserSpin = 720,
    riotBypassEnabled = false, riotBypassDistance = 3, riotBypassHeight = 0, riotBypassUpdate = 0.02, riotBypassPosition = "Front",
    antiAfkEnabled = false, autocollectEnabled = false, autocollectRadius = 60,
    returnHomeEnabled = false, homeReturnDelay = 3.0,
    safeZoneEnabled = false, safeZoneY = -10,
    teleportLoopEnabled = false, teleportLoopDelay = 1.5,
}

local ROOT_FOLDER        = "meowwCL"
local PROFILES_FOLDER    = ROOT_FOLDER .. "/profiles"
local GLOBAL_CFG_FILE    = ROOT_FOLDER .. "/global_config.json"
local ACTIVE_PROFILE_FILE = ROOT_FOLDER .. "/active_profile.txt"

local function ensureFolders()
    local function mf(path) if not isfolder(path) then pcall(makefolder, path) end end
    mf(ROOT_FOLDER); mf(PROFILES_FOLDER)
end

local function safeWrite(path, content) return pcall(writefile, path, content) end
local function safeRead(path) local ok, d = pcall(readfile, path); return ok and d or nil end
local function safeDelete(path) pcall(delfile, path) end

local function jsonEncode(t)
    local ok, s = pcall(function() return HttpService:JSONEncode(t) end)
    return ok and s or nil
end
local function jsonDecode(s)
    local ok, t = pcall(function() return HttpService:JSONDecode(s) end)
    return ok and t or nil
end

local function getActiveProfileName() return safeRead(ACTIVE_PROFILE_FILE) end
local function setActiveProfileName(name)
    if name then safeWrite(ACTIVE_PROFILE_FILE, name) else safeDelete(ACTIVE_PROFILE_FILE) end
end

local function profilePath(name)
    local safe = name:gsub("[^%w%-%_ ]", ""):sub(1, 48)
    return PROFILES_FOLDER .. "/" .. safe .. ".json"
end

local function listProfiles()
    local names = {}
    local ok, files = pcall(listfiles, PROFILES_FOLDER)
    if not ok or not files then return names end
    for _, path in ipairs(files) do
        local name = path:match("([^/\\]+)%.json$")
        if name then table.insert(names, name) end
    end
    table.sort(names); return names
end

local function saveProfile(name)
    name = name:match("^%s*(.-)%s*$")
    if name == "" then return false, "Enter a profile name" end
    local t = {}
    for k, v in pairs(getgenv().config) do t[k] = v end
    local s = jsonEncode(t)
    if not s then return false, "JSON encode failed" end
    local ok, err = safeWrite(profilePath(name), s)
    if not ok then return false, tostring(err) end
    setActiveProfileName(name)
    return true, "Saved profile: " .. name
end

local function loadProfile(name)
    local raw = safeRead(profilePath(name))
    if not raw then return false, "Profile not found" end
    local data = jsonDecode(raw)
    if not data then return false, "Corrupted profile" end
    for k, v in pairs(data) do
        if getgenv().config[k] ~= nil then
            if type(getgenv().config[k]) == type(v) then getgenv().config[k] = v end
        end
    end
    setActiveProfileName(name)
    return true, "Loaded: " .. name
end

local function deleteProfile(name)
    safeDelete(profilePath(name))
    if getActiveProfileName() == name then setActiveProfileName(nil) end
    return true, "Deleted: " .. name
end

local function saveGlobalConfig()
    local t = {}
    for k, v in pairs(getgenv().config) do t[k] = v end
    local s = jsonEncode(t)
    if s then safeWrite(GLOBAL_CFG_FILE, s) end
end

local function loadGlobalConfig()
    local raw = safeRead(GLOBAL_CFG_FILE)
    if not raw then return end
    local data = jsonDecode(raw)
    if not data then return end
    for k, v in pairs(data) do
        if getgenv().config[k] ~= nil and type(getgenv().config[k]) == type(v) then
            getgenv().config[k] = v
        end
    end
end

pcall(ensureFolders)
pcall(loadGlobalConfig)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local Window = Library:CreateWindow({ Title = "meowwCL Premium", Center = true, AutoShow = true, Resizable = true, MobileButtonsSide = "Right" })

local function Notify(title, desc)
    Library:Notify({ Title = title, Description = desc, Time = 3 })
end

getgenv().AllConnections   = {}
getgenv().loopWaypoints    = {}
getgenv().loopIndex        = 1
getgenv().homePosition     = nil
getgenv().safeZoneSavedPos = nil

local config = getgenv().config

local function getHrp()
    return localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
end

local function getClosest()
    local closest, minD = nil, math.huge
    local hrp = getHrp()
    if not hrp then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localplayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if localplayer.Team == nil or p.Team == nil or localplayer.Team ~= p.Team then
                local hum = p.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local d = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < minD then minD = d; closest = p end
                end
            end
        end
    end
    return closest
end

local function safeTeleport(pos)
    local hrp = getHrp()
    if not hrp then return end
    local x, y, z = pos.X, pos.Y, pos.Z
    y = math.clamp(y, 2, hrp.Position.Y + 800)
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = { localplayer.Character }
    local hit = workspace:Raycast(Vector3.new(x, y + 60, z), Vector3.new(0, -220, 0), p)
    if hit then y = math.max(hit.Position.Y + 3, 2) end
    hrp.CFrame = CFrame.new(x, y, z)
end

local oldFireServer
oldFireServer = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
    if not checkcaller() and config.daggerBypass then
        local n, a = self.Name:lower(), table.concat({ ... }, " "):lower()
        if (n:find("dagger") or n:find("knife") or n:find("throw") or n:find("blade"))
        and not (a:find(localplayer.Name:lower()) or a:find("owner")) then return end
    end
    return oldFireServer(self, ...)
end))

UserInputService.JumpRequest:Connect(function()
    if config.doubleJumpEnabled then
        local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local voidConn1, voidConn2, voidConn3, voidToggle = nil, nil, nil, false
getgenv().startVoid = function()
    if voidConn1 then voidConn1:Disconnect() end
    if voidConn2 then voidConn2:Disconnect() end
    if voidConn3 then voidConn3:Disconnect() end
    voidConn1 = RunService.Heartbeat:Connect(function()
        if not config.VoidEnabled or not getHrp() then return end
        voidToggle = not voidToggle
        local hrp = getHrp()
        local vx, vy, vz = config.voidX, config.voidY, config.voidZ
        if voidToggle then hrp.CFrame = CFrame.new(math.random(-vx, vx), vy, math.random(-vz, vz))
        else hrp.CFrame = CFrame.new(math.random(vx, vx * 2), -vy, math.random(vz, vz * 2)) end
        hrp.AssemblyLinearVelocity = Vector3.new(math.random(-1e5, 1e5), math.random(-1e5, 1e5), math.random(-1e5, 1e5))
        hrp.AssemblyAngularVelocity = Vector3.new(math.random(-1e5, 1e5), math.random(-1e5, 1e5), math.random(-1e5, 1e5))
    end)
    voidConn2 = RunService.RenderStepped:Connect(function()
        if not config.VoidEnabled or not getHrp() then return end
        getHrp().CFrame = getHrp().CFrame * CFrame.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
    end)
    voidConn3 = RunService.Stepped:Connect(function()
        if not config.VoidEnabled or not getHrp() then return end
        if getHrp().Position.Magnitude > 1e7 then getHrp().CFrame = CFrame.new(0, config.voidY, 0) end
    end)
end
getgenv().stopVoid = function()
    if voidConn1 then voidConn1:Disconnect() voidConn1 = nil end
    if voidConn2 then voidConn2:Disconnect() voidConn2 = nil end
    if voidConn3 then voidConn3:Disconnect() voidConn3 = nil end
end
local voidSpamConn, voidSpamCharConn = nil, nil
local voidSpiralAngle = 0
local voidWaveTime    = 0
local voidBounceDir   = { X = 1, Y = 1, Z = 1 }
local voidChaosSeeds  = { math.random(), math.random(), math.random() }
local voidHelixT      = 0
local voidStrobePhase = false

local function getVoidSpamDelta(dt)
    local xp, xn = config.voidXPos, config.voidXNeg
    local yp, yn = config.voidYPos, config.voidYNeg
    local zp, zn = config.voidZPos, config.voidZNeg
    local ax, ay, az = config.voidAxisX, config.voidAxisY, config.voidAxisZ
    local p = config.voidPattern
    if p == "spiral" then
        voidSpiralAngle = voidSpiralAngle + 0.35
        return Vector3.new(ax and math.cos(voidSpiralAngle) * (xp + xn) / 2 or 0, ay and math.sin(voidSpiralAngle * 0.6) * (yp + yn) / 2 or 0, az and math.sin(voidSpiralAngle) * (zp + zn) / 2 or 0)
    elseif p == "wave" then
        voidWaveTime = voidWaveTime + dt * 8
        return Vector3.new(ax and math.sin(voidWaveTime) * (xp + xn) / 2 or 0, ay and math.sin(voidWaveTime * 1.7) * (yp + yn) / 2 or 0, az and math.cos(voidWaveTime * 0.9) * (zp + zn) / 2 or 0)
    elseif p == "bounce" then
        local step = Vector3.new(ax and voidBounceDir.X * (xp + xn) / 3 or 0, ay and voidBounceDir.Y * (yp + yn) / 3 or 0, az and voidBounceDir.Z * (zp + zn) / 3 or 0)
        if math.random() < 0.25 then voidBounceDir.X = -voidBounceDir.X end
        if math.random() < 0.25 then voidBounceDir.Y = -voidBounceDir.Y end
        if math.random() < 0.25 then voidBounceDir.Z = -voidBounceDir.Z end
        return step
    elseif p == "chaos" then
        voidChaosSeeds[1] = (voidChaosSeeds[1] * 1664525 + 1013904223) % 1
        voidChaosSeeds[2] = (voidChaosSeeds[2] * 22695477 + 1) % 1
        voidChaosSeeds[3] = (voidChaosSeeds[3] * 214013 + 2531011) % 1
        return Vector3.new(ax and (voidChaosSeeds[1] * (xp + xn) - xn) or 0, ay and (voidChaosSeeds[2] * (yp + yn) - yn) or 0, az and (voidChaosSeeds[3] * (zp + zn) - zn) or 0)
    elseif p == "cross" then
        local tog = (math.floor(tick() * 10)) % 2 == 0
        return Vector3.new(ax and (tog and (math.random() * (xp + xn) - xn) or 0) or 0, ay and (not tog and (math.random() * (yp + yn) - yn) or 0) or 0, az and (tog and (math.random() * (zp + zn) - zn) or 0) or 0)
    elseif p == "helix" then
        voidHelixT = voidHelixT + dt * 6
        return Vector3.new(ax and math.cos(voidHelixT * 2) * (xp + xn) / 2 or 0, ay and math.sin(voidHelixT) * (yp + yn) / 8 or 0, az and math.sin(voidHelixT * 2) * (zp + zn) / 2 or 0)
    elseif p == "strobe" then
        voidStrobePhase = not voidStrobePhase
        local s = voidStrobePhase and 1 or -1
        return Vector3.new(ax and s * xp or 0, ay and s * yp or 0, az and s * zp or 0)
    else
        return Vector3.new(ax and (math.random() * (xp + xn) - xn) or 0, ay and (math.random() * (yp + yn) - yn) or 0, az and (math.random() * (zp + zn) - zn) or 0)
    end
end

getgenv().startVoidSpam = function()
    if voidSpamConn then return end
    voidSpiralAngle = 0; voidWaveTime = 0; voidHelixT = 0; voidStrobePhase = false
    voidBounceDir = { X = 1, Y = 1, Z = 1 }; voidChaosSeeds = { math.random(), math.random(), math.random() }
    local root, humanoid
    local function refreshChar()
        local ch = localplayer.Character
        if not ch then root = nil; humanoid = nil; return end
        root = ch:FindFirstChild("HumanoidRootPart"); humanoid = ch:FindFirstChildOfClass("Humanoid")
    end
    refreshChar()
    voidSpamCharConn = localplayer.CharacterAdded:Connect(function(ch)
        root = ch:WaitForChild("HumanoidRootPart"); humanoid = ch:WaitForChild("Humanoid")
        task.wait(0.2)
        if config.voidSpamEnabled and humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Physics) end
    end)
    local acc, dtBuf = 0, 0
    voidSpamConn = RunService.Heartbeat:Connect(function(dt)
        if not config.voidSpamEnabled then getgenv().stopVoidSpam(); return end
        if not root or not root.Parent then refreshChar(); return end
        if humanoid and humanoid.Health <= 0 then return end
        dtBuf = dtBuf + dt; acc = acc + dt
        local interval = math.max(config.voidSpamInterval, 0.005)
        if acc < interval then return end
        acc = acc % interval
        local burst = math.clamp(config.voidSpamBurst, 1, 20)
        for _ = 1, burst do
            if not root or not root.Parent then break end
            local pos = root.Position; local look = root.CFrame.LookVector
            local delta = getVoidSpamDelta(dtBuf / burst)
            local newPos
            if config.voidSmooth then
                newPos = pos:Lerp(pos + delta, math.clamp(config.voidSmoothAlpha, 0.01, 1))
            else newPos = pos + delta end
            root.CFrame = CFrame.new(newPos, newPos + look)
        end
        dtBuf = 0
    end)
end
getgenv().stopVoidSpam = function()
    if voidSpamConn then voidSpamConn:Disconnect() voidSpamConn = nil end
    if voidSpamCharConn then voidSpamCharConn:Disconnect() voidSpamCharConn = nil end
    config.voidSpamEnabled = false
end

local orbConn, orbAngle = nil, 0
getgenv().startOrbit = function()
    if orbConn then orbConn:Disconnect() end
    local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end
    orbAngle = 0
    orbConn = RunService.Heartbeat:Connect(function(dt)
        if not config.orbit then return end
        local myHrp = getHrp()
        if not myHrp then return end
        local cl = getClosest()
        if cl and cl.Character then
            local hrp = cl.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local speedMod = (config.orbitSpeed or 90) / 500
                orbAngle = orbAngle + speedMod
                local radius = config.orbitDistance or 8
                local height = config.orbitHeight or 0
                local offset = Vector3.new(math.cos(orbAngle) * radius, height, math.sin(orbAngle) * radius)
                myHrp.CFrame = CFrame.new(hrp.Position + offset, hrp.Position)
                pcall(function()
                    myHrp.AssemblyLinearVelocity = Vector3.zero
                    myHrp.AssemblyAngularVelocity = Vector3.zero
                end)
            end
        end
    end)
end
getgenv().stopOrbit = function()
    if orbConn then orbConn:Disconnect() orbConn = nil end
    config.orbit = false
end
local tpConn
getgenv().startTp = function()
    if tpConn then tpConn:Disconnect() end
    tpConn = RunService.Heartbeat:Connect(function()
        if config.teleportEnemyEnabled then
            local t = getClosest()
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and getHrp() then
                getHrp().CFrame = CFrame.new(t.Character.HumanoidRootPart.Position + Vector3.new(0, 3.5, 0))
            end
        end
    end)
end
getgenv().stopTp = function() if tpConn then tpConn:Disconnect() tpConn = nil end end

local fakePosConnection, renderPosConnection, realCF = nil, nil, nil
getgenv().startFakePosition = function()
    if fakePosConnection then fakePosConnection:Disconnect() end
    if renderPosConnection then renderPosConnection:Disconnect() end
    fakePosConnection = RunService.Heartbeat:Connect(function()
        local tHrp = getHrp()
        if config.fakePositionEnabled and tHrp then
            realCF = tHrp.CFrame
            tHrp.CFrame = realCF + Vector3.new(math.random(-150, 150), math.random(10, 100), math.random(-150, 150))
        end
    end)
    renderPosConnection = RunService.RenderStepped:Connect(function()
        local tHrp = getHrp()
        if config.fakePositionEnabled and tHrp and realCF then tHrp.CFrame = realCF end
    end)
end
getgenv().stopFakePosition = function()
    if fakePosConnection then fakePosConnection:Disconnect() fakePosConnection = nil end
    if renderPosConnection then renderPosConnection:Disconnect() renderPosConnection = nil end
end

local desyncHeartbeat, desyncRender, realVel = nil, nil, nil
getgenv().startDesync = function()
    if desyncHeartbeat then desyncHeartbeat:Disconnect() end
    if desyncRender then desyncRender:Disconnect() end
    desyncHeartbeat = RunService.Heartbeat:Connect(function()
        local tHrp = getHrp()
        if config.desyncEnabled and tHrp then
            realVel = tHrp.AssemblyLinearVelocity
            tHrp.AssemblyLinearVelocity = Vector3.new(math.random(-5000, 5000), math.random(-5000, 5000), math.random(-5000, 5000))
        end
    end)
    desyncRender = RunService.RenderStepped:Connect(function()
        local tHrp = getHrp()
        if config.desyncEnabled and tHrp and realVel then tHrp.AssemblyLinearVelocity = realVel end
    end)
end
getgenv().stopDesync = function()
    if desyncHeartbeat then desyncHeartbeat:Disconnect() desyncHeartbeat = nil end
    if desyncRender then desyncRender:Disconnect() desyncRender = nil end
end

local evasionConn, blinkConn, ghostConn = nil, nil, nil
getgenv().startEvasion = function()
    if evasionConn then evasionConn:Disconnect() end
    local t0, s1, s2, s3 = tick(), math.random(1e3, 9e3), math.random(1e3, 9e3), math.random(1e3, 9e3)
    evasionConn = RunService.Heartbeat:Connect(function()
        if not config.evasionEnabled or not getHrp() then return end
        local t, i = tick() - t0, config.evasionIntensity
        local r1, r2, r3 = 500 * 0.18 * i, 500 * 0.35 * i, 500 * 0.55 * i
        local oX = math.cos(t * 18.7) * r1 + math.cos(t * 7.3 + s1) * r2 + math.cos(t * 2.1 + s2) * r3
        local oZ = math.sin(t * 18.7) * r1 + math.sin(t * 7.3 + s1) * r2 + math.sin(t * 2.1 + s2) * r3
        local oY = math.sin(t * 11.3 + s3) * 500 * 0.12 * i + math.sin(t * 5.7) * 500 * 0.08 * i
        local jX = math.noise(t * 8, s1, 0) * 40 * i
        local jY = math.noise(0, t * 8, s2) * 20 * i
        local jZ = math.noise(0, 0, t * 8 + s3) * 40 * i
        safeTeleport(getHrp().Position + Vector3.new(oX + jX, oY + jY, oZ + jZ))
    end)
end
getgenv().stopEvasion = function() if evasionConn then evasionConn:Disconnect() evasionConn = nil end end

local blinkAnchor = nil
getgenv().startBlink = function()
    if blinkConn then blinkConn:Disconnect() end
    if getHrp() then blinkAnchor = getHrp().Position end
    local lastSnap, anchorT, seed = 0, 0, math.random(1e3, 9e3)
    blinkConn = RunService.Heartbeat:Connect(function(dt)
        if not config.blinkEnabled or not getHrp() then return end
        anchorT = anchorT + dt
        blinkAnchor = (blinkAnchor or getHrp().Position) + Vector3.new(math.sin(anchorT * 1.3 + seed) * 12, math.sin(anchorT * 2.1) * 3, math.cos(anchorT * 1.7 + seed) * 12) * dt
        local now = tick()
        if (now - lastSnap) >= (1 / config.blinkRate) then
            lastSnap = now
            local a, d = math.random() * math.pi * 2, math.random() * config.blinkRadius
            safeTeleport(Vector3.new(blinkAnchor.X + math.cos(a) * d, blinkAnchor.Y + (math.random() - 0.5) * config.blinkRadius * 0.3, blinkAnchor.Z + math.sin(a) * d))
        end
    end)
end
getgenv().stopBlink = function() if blinkConn then blinkConn:Disconnect() blinkConn = nil end end

getgenv().startGhost = function()
    if ghostConn then ghostConn:Disconnect() end
    local flip, t0, seed = false, tick(), math.random(1e3, 9e3)
    ghostConn = RunService.Heartbeat:Connect(function()
        if not config.ghostEnabled or not getHrp() then return end
        flip = not flip
        if flip then
            local a = (tick() - t0) * 4.3 + seed
            safeTeleport(Vector3.new(getHrp().Position.X + math.cos(a) * config.ghostDistance, getHrp().Position.Y, getHrp().Position.Z + math.sin(a) * config.ghostDistance))
        end
    end)
end
getgenv().stopGhost = function() if ghostConn then ghostConn:Disconnect() ghostConn = nil end end

local glideConn = nil
getgenv().startGlide = function()
    if glideConn then glideConn:Disconnect() end
    local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end
    local vel = Vector3.zero
    glideConn = RunService.Heartbeat:Connect(function(dt)
        if not config.glideEnabled then getgenv().stopGlide(); return end
        local hrp = getHrp(); if not hrp then return end
        local cam = workspace.CurrentCamera
        local cf  = cam and cam.CFrame or hrp.CFrame
        local f   = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z).Unit
        local r   = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z).Unit
        local humC = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
        local md   = humC and humC.MoveDirection or Vector3.zero
        local wish = Vector3.zero
        if md.Magnitude > 0.001 then
            wish = f * md:Dot(f) + r * md:Dot(r)
            if wish.Magnitude > 0.001 then wish = wish.Unit end
        end
        local accel = math.clamp(config.glideAccel, 1, 100)
        vel = vel:Lerp(wish * config.glideSpeed, 1 - math.exp(-accel * dt))
        hrp.AssemblyLinearVelocity = Vector3.new(vel.X, hrp.AssemblyLinearVelocity.Y, vel.Z)
    end)
end
getgenv().stopGlide = function()
    if glideConn then glideConn:Disconnect() glideConn = nil end
    config.glideEnabled = false
end
local riotAbuserConn = nil
getgenv().startRiotAbuser = function()
    if riotAbuserConn then riotAbuserConn:Disconnect() end
    local t0, seed = tick(), math.random(1e3, 9e3)
    local hrp = getHrp()
    if hrp then getgenv().riotAbuserOriginal = hrp.CFrame end
    riotAbuserConn = RunService.Heartbeat:Connect(function(dt)
        if not config.riotAbuserEnabled or not getHrp() then return end
        local t = tick() - t0
        local hrp2 = getHrp()
        local yaw   = math.rad(config.riotAbuserSpin * dt)
        local pitch = math.rad(config.riotAbuserSpin * 0.37 * dt * math.sin(t * 3.1))
        local roll  = math.rad(config.riotAbuserSpin * 0.19 * dt * math.cos(t * 5.7 + seed))
        local spinCF = hrp2.CFrame * CFrame.Angles(pitch, yaw, roll)
        local spread = config.riotAbuserDistance / 300
        local jX = (math.random() - 0.5) * config.riotAbuserX * spread * 2 + math.noise(t * 9, seed, 0) * config.riotAbuserX * spread
        local jY = (math.random() - 0.5) * config.riotAbuserY * spread + math.noise(0, t * 9, seed) * config.riotAbuserY * spread * 0.3
        local jZ = (math.random() - 0.5) * config.riotAbuserZ * spread * 2 + math.noise(0, 0, t * 9 + seed) * config.riotAbuserZ * spread
        local newY = math.max(spinCF.Position.Y + jY, 2)
        hrp2.CFrame = spinCF + Vector3.new(jX, newY - spinCF.Position.Y, jZ)
    end)
end
getgenv().stopRiotAbuser = function()
    if riotAbuserConn then riotAbuserConn:Disconnect() riotAbuserConn = nil end
    if getHrp() and getgenv().riotAbuserOriginal then getHrp().CFrame = getgenv().riotAbuserOriginal end
end

local riotBypassConn, riotBypassTarget = nil, nil
local riotBypassLastSnap = 0
getgenv().startRiotBypass = function()
    if riotBypassConn then riotBypassConn:Disconnect() end
    riotBypassConn = RunService.Heartbeat:Connect(function()
        if not config.riotBypassEnabled or not getHrp() then return end
        if not riotBypassTarget or not riotBypassTarget.Character or not riotBypassTarget.Character:FindFirstChild("Humanoid") or riotBypassTarget.Character.Humanoid.Health <= 0 then
            riotBypassTarget = getClosest()
            return
        end
        local tr = riotBypassTarget.Character:FindFirstChild("HumanoidRootPart")
        if not tr then return end
        local now = tick()
        if (now - riotBypassLastSnap) < config.riotBypassUpdate then return end
        riotBypassLastSnap = now
        local hrp = getHrp()
        if not hrp then return end
        
        local targetPos = tr.Position
        local targetLook = tr.CFrame.LookVector
        local distance = config.riotBypassDistance or 3
        local heightOffset = config.riotBypassHeight or 0
        local calculatedCFrame = hrp.CFrame
        local mode = config.riotBypassPosition or "Front"
        
        if mode == "Front" then
            calculatedCFrame = CFrame.lookAt(targetPos + (targetLook * distance) + Vector3.new(0, heightOffset, 0), targetPos + Vector3.new(0, heightOffset, 0))
        elseif mode == "Back" then
            calculatedCFrame = CFrame.lookAt(targetPos - (targetLook * distance) + Vector3.new(0, heightOffset, 0), targetPos + Vector3.new(0, heightOffset, 0))
        elseif mode == "Above" then
            calculatedCFrame = CFrame.lookAt(targetPos + Vector3.new(0, distance + heightOffset, 0), targetPos + Vector3.new(0, heightOffset, 0))
        elseif mode == "Below" then
            calculatedCFrame = CFrame.lookAt(targetPos + Vector3.new(0, -distance + heightOffset, 0), targetPos + Vector3.new(0, heightOffset, 0))
        end
        
        hrp.CFrame = calculatedCFrame
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end
getgenv().stopRiotBypass = function()
    if riotBypassConn then riotBypassConn:Disconnect() riotBypassConn = nil end
    riotBypassTarget = nil
    riotBypassLastSnap = 0
end

local slingRageConn, slingProjA, slingProjB
local slingTarget = CFrame.new(9000, 9000, 9000)
local slingProjs  = {}
getgenv().startSlingRage = function()
    if slingRageConn then slingRageConn:Disconnect() end
    slingProjA = workspace.ChildAdded:Connect(function(o)
        if not o:IsA("BasePart") then return end
        if o.Name == "CoreProjectile" then slingProjs[o] = true
        elseif o.Name == "Part" then task.defer(function()
            if o and o.Parent and o.AssemblyLinearVelocity.Magnitude > 50 then slingProjs[o] = true end
        end) end
    end)
    slingProjB = workspace.ChildRemoved:Connect(function(o) slingProjs[o] = nil end)
    slingRageConn = RunService.Heartbeat:Connect(function()
        if not config.slingRage then return end
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= localplayer and p.Character then
                    local h = p.Character:FindFirstChild("HumanoidRootPart")
                    if h then h.CFrame = slingTarget; h.AssemblyLinearVelocity = Vector3.zero; h.AssemblyAngularVelocity = Vector3.zero end
                end
            end
            for _, o in pairs(workspace:GetChildren()) do
                if o.Name == "CoreProjectile" and o:IsA("BasePart") then
                    o.CFrame = slingTarget; o.AssemblyLinearVelocity = Vector3.zero
                end
            end
            for p in pairs(slingProjs) do
                if p and p.Parent then p.CFrame = slingTarget; p.AssemblyLinearVelocity = Vector3.zero
                else slingProjs[p] = nil end
            end
        end)
    end)
end
getgenv().stopSlingRage = function()
    if slingRageConn then slingRageConn:Disconnect() slingRageConn = nil end
    if slingProjA then slingProjA:Disconnect() slingProjA = nil end
    if slingProjB then slingProjB:Disconnect() slingProjB = nil end
    slingProjs = {}
end

local apConn, apProjA, apProjB
local apTarget = CFrame.new(999999, 999999, 999999)
local apProjs  = {}
getgenv().startAntiProj = function()
    if apConn then apConn:Disconnect() end
    apProjA = workspace.ChildAdded:Connect(function(o)
        if not o:IsA("BasePart") then return end
        if o.Name == "CoreProjectile" then apProjs[o] = true
        elseif o.Name == "Part" then task.defer(function()
            if o and o.Parent and o.AssemblyLinearVelocity.Magnitude > 50 then apProjs[o] = true end
        end) end
    end)
    apProjB = workspace.ChildRemoved:Connect(function(o) apProjs[o] = nil end)
    apConn = RunService.Heartbeat:Connect(function()
        if not config.antiProj then return end
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= localplayer and p.Character then
                    local h = p.Character:FindFirstChild("HumanoidRootPart")
                    if h then h.CFrame = apTarget; h.AssemblyLinearVelocity = Vector3.zero; h.AssemblyAngularVelocity = Vector3.zero end
                end
            end
            for _, o in pairs(workspace:GetChildren()) do
                if o.Name == "CoreProjectile" and o:IsA("BasePart") then
                    o.CFrame = apTarget; o.AssemblyLinearVelocity = Vector3.zero
                end
            end
            for p in pairs(apProjs) do
                if p and p.Parent then p.CFrame = apTarget; p.AssemblyLinearVelocity = Vector3.zero
                else apProjs[p] = nil end
            end
        end)
    end)
end
getgenv().stopAntiProj = function()
    if apConn then apConn:Disconnect() apConn = nil end
    if apProjA then apProjA:Disconnect() apProjA = nil end
    if apProjB then apProjB:Disconnect() apProjB = nil end
    apProjs = {}
end

local antiCloseConn = nil
getgenv().startAntiClose = function()
    if antiCloseConn then antiCloseConn:Disconnect() end
    antiCloseConn = RunService.Heartbeat:Connect(function()
        if not config.antiClose then return end
        local hrp = getHrp(); if not hrp then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localplayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if (hrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude < 20 then
                    hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 60 + Vector3.new(0, 30, 0)
                    break
                end
            end
        end
    end)
end
getgenv().stopAntiClose = function() if antiCloseConn then antiCloseConn:Disconnect() antiCloseConn = nil end end

getgenv().startFastReload = function()
    local ok, ItemLibrary = pcall(function() return require(game:GetService("ReplicatedStorage").Modules.ItemLibrary) end)
    if not ok or not ItemLibrary then return end
    local Items = rawget(ItemLibrary, "Items"); if not Items then return end
    task.spawn(function()
        while config.fastReload do
            for _, Item in pairs(Items) do
                pcall(function()
                    local speed = Item.Name == "Daggers" and 0.09 or 0
                    rawset(Item, "ReloadLength", speed); rawset(Item, "FireRate", 0)
                    rawset(Item, "Cooldown", 0); rawset(Item, "AttackCooldown", 0)
                    rawset(Item, "SwingCooldown", 0); rawset(Item, "ThrowCooldown", 0)
                    rawset(Item, "RecoverTime", 0); rawset(Item, "WindupTime", 0)
                end)
            end
            task.wait(0.1)
        end
    end)
end
getgenv().stopFastReload = function() config.fastReload = false end
local lastShootTime = 0
local function handleWallbang()
    if not config.wallbangEnabled then return end
    local cl = getClosest(); local hrp = getHrp(); local char = localplayer.Character
    if cl and cl.Character and cl.Character:FindFirstChild("Head") and hrp and char then
        local hd  = cl.Character.Head
        local cam = workspace.CurrentCamera
        cam.CFrame = CFrame.lookAt(cam.CFrame.Position, hd.Position)
        local t = char:FindFirstChildOfClass("Tool")
        if t then t:Activate() end
        if tick() - lastShootTime > 0.05 then
            lastShootTime = tick()
            pcall(function()
                if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
                    local center = cam.ViewportSize / 2
                    if firetouchtap then firetouchtap(center) elseif touchtap then touchtap(center) end
                else
                    if mouse1click then mouse1click() else VirtualUser:ClickButton1(Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)) end
                end
            end)
        end
    end
end
getgenv().startWallbang = function() RunService:BindToRenderStep("WbAimFix", Enum.RenderPriority.Camera.Value + 1, handleWallbang) end
getgenv().stopWallbang  = function() RunService:UnbindFromRenderStep("WbAimFix") end

local rapidFireConn = nil
getgenv().startRapidFire = function()
    if rapidFireConn then rapidFireConn:Disconnect() end
    rapidFireConn = RunService.Heartbeat:Connect(function()
        if config.rapidFire then
            local t = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Tool")
            if t then t:Activate() end
        end
    end)
end
getgenv().stopRapidFire = function() if rapidFireConn then rapidFireConn:Disconnect() rapidFireConn = nil end end

local autocollectConn, homeConn, loopConn, safeZoneConn = nil, nil, nil, nil
getgenv().startAutocollect = function()
    if autocollectConn then autocollectConn:Disconnect() end
    autocollectConn = RunService.Heartbeat:Connect(function()
        if not config.autocollectEnabled or not getHrp() then return end
        local best, minD = nil, math.huge
        for _, o in ipairs(workspace:GetDescendants()) do
            local n = o.Name:lower()
            if n:find("heal") or n:find("health") or n:find("medkit") or n:find("bandage") then
                local p = o:IsA("Model") and (o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")) or (o:IsA("BasePart") and o or nil)
                if p then
                    local d = (p.Position - getHrp().Position).Magnitude
                    if d < minD and d <= config.autocollectRadius then minD = d; best = p.Position end
                end
            end
        end
        if best then safeTeleport(best) end
    end)
end
getgenv().stopAutocollect = function() if autocollectConn then autocollectConn:Disconnect() autocollectConn = nil end end

getgenv().startReturnHome = function()
    if homeConn then homeConn:Disconnect() end
    if not getgenv().homePosition and getHrp() then getgenv().homePosition = getHrp().Position end
    local lastRet = 0
    homeConn = RunService.Heartbeat:Connect(function()
        if not config.returnHomeEnabled or not getHrp() or not getgenv().homePosition then return end
        if (getHrp().Position - getgenv().homePosition).Magnitude > 50 and (tick() - lastRet) >= config.homeReturnDelay then
            lastRet = tick(); safeTeleport(getgenv().homePosition)
        end
    end)
end
getgenv().stopReturnHome = function() if homeConn then homeConn:Disconnect() homeConn = nil end end

getgenv().startSafeZone = function()
    if safeZoneConn then safeZoneConn:Disconnect() end
    safeZoneConn = RunService.Heartbeat:Connect(function()
        if not getHrp() then return end
        if getHrp().Position.Y > config.safeZoneY then getgenv().safeZoneSavedPos = getHrp().Position
        elseif config.safeZoneEnabled and getgenv().safeZoneSavedPos then getHrp().CFrame = CFrame.new(getgenv().safeZoneSavedPos) end
    end)
end
getgenv().stopSafeZone = function() if safeZoneConn then safeZoneConn:Disconnect() safeZoneConn = nil end end

getgenv().startTeleportLoop = function()
    if loopConn then pcall(task.cancel, loopConn) end
    config.teleportLoopEnabled = true
    loopConn = task.spawn(function()
        while config.teleportLoopEnabled do
            if #getgenv().loopWaypoints > 0 and getHrp() then
                local t = getgenv().loopWaypoints[getgenv().loopIndex]
                if t then safeTeleport(t) end
                getgenv().loopIndex = (getgenv().loopIndex % #getgenv().loopWaypoints) + 1
            end
            task.wait(config.teleportLoopDelay)
        end
    end)
end
getgenv().stopTeleportLoop = function()
    config.teleportLoopEnabled = false
    if loopConn then pcall(task.cancel, loopConn) loopConn = nil end
end

local antiAfkConn = nil
getgenv().startAntiAfk = function()
    if antiAfkConn then antiAfkConn:Disconnect() end
    antiAfkConn = localplayer.Idled:Connect(function()
        if config.antiAfkEnabled then
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end
    end)
end
getgenv().stopAntiAfk = function() if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end end

local flyConn = nil
getgenv().startFly = function()
    if flyConn then flyConn:Disconnect() end
    flyConn = RunService.Heartbeat:Connect(function(dt)
        local tHrp = getHrp()
        if not tHrp or not config.flyEnabled then return end
        local h = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Physics) end
        local c  = workspace.CurrentCamera
        local md = Vector3.zero
        if h and h.MoveDirection.Magnitude > 0 then
            local fl = Vector3.new(c.CFrame.LookVector.X, 0, c.CFrame.LookVector.Z)
            md = fl.Magnitude > 0.001
                and Vector3.new(h.MoveDirection.X, c.CFrame.LookVector.Y * h.MoveDirection:Dot(fl.Unit), h.MoveDirection.Z)
                or  Vector3.new(h.MoveDirection.X, c.CFrame.LookVector.Y, h.MoveDirection.Z)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then md = md + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then md = md - Vector3.new(0, 1, 0) end
        tHrp.AssemblyLinearVelocity = Vector3.zero; tHrp.AssemblyAngularVelocity = Vector3.zero
        if md.Magnitude > 0 then tHrp.CFrame = tHrp.CFrame + (md.Unit * (config.flySpeed * dt)) end
    end)
end
getgenv().stopFly = function()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if getHrp() then getHrp().AssemblyLinearVelocity = Vector3.zero; getHrp().AssemblyAngularVelocity = Vector3.zero end
    local h = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h:ChangeState(Enum.HumanoidStateType.GettingUp) end
end

local underMapConn = nil
getgenv().startUnderMap = function()
    if underMapConn then underMapConn:Disconnect() end
    underMapConn = RunService.Heartbeat:Connect(function()
        if not config.underMapEnabled or not getHrp() then return end
        local hrp = getHrp()
        if localplayer.Character then
            for _, p in ipairs(localplayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
        hrp.CFrame = CFrame.new(hrp.Position.X, config.underMapY, hrp.Position.Z)
    end)
end
getgenv().stopUnderMap = function() if underMapConn then underMapConn:Disconnect() underMapConn = nil end end

table.insert(getgenv().AllConnections, RunService.Stepped:Connect(function()
    if config.nc and localplayer.Character then
        for _, p in ipairs(localplayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end))

table.insert(getgenv().AllConnections, RunService.Heartbeat:Connect(function()
    if config.antiAimEnabled and getHrp() then
        getHrp().CFrame = getHrp().CFrame * CFrame.Angles(math.rad(config.pitchAngle), math.rad(config.yawAngle), 0)
    end
    if config.spinEnabled and getHrp() then
        getHrp().CFrame = getHrp().CFrame * CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)
        getHrp().AssemblyLinearVelocity = Vector3.new(math.random(-200, 200), 250, math.random(-200, 200)) * 45
    end
end))
local function Tgl(box, id, txt, desc, cb)
    box:AddToggle(id, { Text = txt, Default = false, Callback = function(v) if v then Notify(txt, desc) end cb(v) end })
end

local MainTab     = Window:AddTab("Main")
local CombatTab   = Window:AddTab("Combat")
local MovementTab = Window:AddTab("Movement")
local MiscTab     = Window:AddTab("Utilities")
local SettingsTab = Window:AddTab("Settings")

local MoveBox = MainTab:AddLeftGroupbox("Movement")
Tgl(MoveBox, "FlyMode",    "Fly",            "Camera-directed flight.",         function(v) config.flyEnabled = v if v then startFly() else stopFly() end end)
MoveBox:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 50, Min = 1, Max = 2000, Rounding = 0, Callback = function(v) config.flySpeed = v end })
Tgl(MoveBox, "Noclip",     "Noclip",         "Walk through walls.",             function(v) config.nc = v end)
Tgl(MoveBox, "DoubleJump", "Double Jump",    "Infinite mid-air jumps.",         function(v) config.doubleJumpEnabled = v end)
Tgl(MoveBox, "FakePos",    "Fake Position",  "Spoofs server-sided position.",   function(v) config.fakePositionEnabled = v if v then startFakePosition() else stopFakePosition() end end)
Tgl(MoveBox, "Desync",     "Velocity Desync","Spoofs velocity vectors.",       function(v) config.desyncEnabled = v if v then startDesync() else stopDesync() end end)
Tgl(MoveBox, "GlideMode",  "Glide",          "Smooth ground-level glide.",      function(v) config.glideEnabled = v if v then startGlide() else stopGlide() end end)
MoveBox:AddSlider("GlideSpd", { Text = "Glide Speed", Default = 280, Min = 10, Max = 5000, Rounding = 0, Callback = function(v) config.glideSpeed = v end })
MoveBox:AddSlider("GlideAcc", { Text = "Glide Accel", Default = 18,  Min = 1,  Max = 100,  Rounding = 0, Callback = function(v) config.glideAccel = v end })
local CombatBox2 = MainTab:AddRightGroupbox("Combat")
Tgl(CombatBox2, "Wallbang",    "Wallbang Aim",     "Hardware-level lock and auto-shoot.", function(v) config.wallbangEnabled = v if v then startWallbang() else stopWallbang() end end)
Tgl(CombatBox2, "RapidFire",   "Rapid Fire",       "Spams tool activation.",              function(v) config.rapidFire = v if v then startRapidFire() else stopRapidFire() end end)
Tgl(CombatBox2, "TpEnemy",     "Teleport to Enemy","Teleports on top of enemy.",          function(v) config.teleportEnemyEnabled = v if v then startTp() else stopTp() end end)
Tgl(CombatBox2, "FastReload",  "Fast Reload",      "Zero cooldown on all weapons.",       function(v) config.fastReload = v if v then startFastReload() else stopFastReload() end end)
Tgl(CombatBox2, "DaggerBypass","Dagger Bypass",    "Disables incoming dagger hits.",      function(v) config.daggerBypass = v end)
Tgl(CombatBox2, "AntiClose",   "Anti Close",       "Pushes away approaching enemies.",    function(v) config.antiClose = v if v then startAntiClose() else stopAntiClose() end end)

local AntiBox = CombatTab:AddLeftGroupbox("Anti-Aim")
Tgl(AntiBox, "AntiAim",   "Anti Aim",             "Alters orientation angles.",             function(v) config.antiAimEnabled = v end)
AntiBox:AddSlider("PitchShift", { Text = "Pitch Shift", Default = 0, Min = -180, Max = 180, Rounding = 0, Callback = function(v) config.pitchAngle = v end })
AntiBox:AddSlider("YawShift",   { Text = "Yaw Shift",   Default = 0, Min = -180, Max = 180, Rounding = 0, Callback = function(v) config.yawAngle = v end })
Tgl(AntiBox, "SpinBypass","Spin Bypass",               "Spins physical coordinates rapidly.",   function(v) config.spinEnabled = v end)
Tgl(AntiBox, "UnderMap",  "Underground (Anti-Aim)",    "Pushes your character under the map.",   function(v) config.underMapEnabled = v if v then startUnderMap() else stopUnderMap() end end)
AntiBox:AddSlider("UnderMapY", { Text = "Underground Depth", Default = -500, Min = -5000, Max = -50, Rounding = 0, Callback = function(v) config.underMapY = v end })

local OrbitBox = CombatTab:AddLeftGroupbox("Orbit")
Tgl(OrbitBox, "OrbitMode", "Orbit Mode", "Predictive orbit around closest enemy.", function(v) config.orbit = v if v then startOrbit() else stopOrbit() end end)
OrbitBox:AddSlider("OrbSpeed",  { Text = "Orbit Speed (deg/s)", Default = 90, Min = 10, Max = 720, Rounding = 0, Callback = function(v) config.orbitSpeed = v end })
OrbitBox:AddSlider("OrbDist",   { Text = "Orbit Radius",        Default = 8,  Min = 1,  Max = 5000, Rounding = 0, Callback = function(v) config.orbitDistance = v end })
OrbitBox:AddSlider("OrbHeight", { Text = "Orbit Height Offset", Default = 0,  Min = -100, Max = 100, Rounding = 0, Callback = function(v) config.orbitHeight = v end })

local AntiHitBox = CombatTab:AddRightGroupbox("Anti-Hit")
Tgl(AntiHitBox, "SlingRage", "Slingshot Ragebot", "Bypasses slingshot parameters.",    function(v) config.slingRage = v if v then startSlingRage() else stopSlingRage() end end)
Tgl(AntiHitBox, "AntiProj",  "Anti Projectile",   "Freezes and breaks projectiles.",   function(v) config.antiProj = v if v then startAntiProj() else stopAntiProj() end end)

local RiotAbuserBox = CombatTab:AddRightGroupbox("Riot Abuser")
Tgl(RiotAbuserBox, "RiotAbuserE", "Riot Abuser", "Heavy distortion parameters.", function(v) config.riotAbuserEnabled = v if v then startRiotAbuser() else stopRiotAbuser() end end)
RiotAbuserBox:AddSlider("RA_D",    { Text = "Spread Distance", Default = 300, Min = 10, Max = 1000, Rounding = 0, Callback = function(v) config.riotAbuserDistance = v end })
RiotAbuserBox:AddSlider("RA_X",    { Text = "X Jitter",        Default = 30,  Min = 0,  Max = 200,  Rounding = 0, Callback = function(v) config.riotAbuserX = v end })
RiotAbuserBox:AddSlider("RA_Y",    { Text = "Y Jitter",        Default = 8,   Min = 0,  Max = 100,  Rounding = 0, Callback = function(v) config.riotAbuserY = v end })
RiotAbuserBox:AddSlider("RA_Z",    { Text = "Z Jitter",        Default = 30,  Min = 0,  Max = 200,  Rounding = 0, Callback = function(v) config.riotAbuserZ = v end })
RiotAbuserBox:AddSlider("RA_Spin", { Text = "Spin Speed",      Default = 720, Min = 0,  Max = 2000, Rounding = 0, Callback = function(v) config.riotAbuserSpin = v end })

local RiotBypassBox = CombatTab:AddRightGroupbox("Riot Bypass")
Tgl(RiotBypassBox, "RiotBypassE", "Riot Bypass", "Instant snap to front of target, facing them.", function(v) config.riotBypassEnabled = v if v then startRiotBypass() else stopRiotBypass() end end)
RiotBypassBox:AddSlider("RB_D",  { Text = "Distance In Front",    Default = 3,    Min = 0,   Max = 20,  Rounding = 1,  Callback = function(v) config.riotBypassDistance = v end })
RiotBypassBox:AddSlider("RB_H",  { Text = "Height Offset",        Default = 0,    Min = -20, Max = 20,  Rounding = 1,  Callback = function(v) config.riotBypassHeight = v end })
RiotBypassBox:AddSlider("RB_UR", { Text = "Update Rate (ms)",     Default = 20,   Min = 1,   Max = 500, Rounding = 0,  Callback = function(v) config.riotBypassUpdate = v / 1000 end })
RiotBypassBox:AddDropdown("RB_Pos", {
    Text = "Teleport Position",
    Default = "Front",
    Values = { "Front", "Back", "Above", "Below" },
    Callback = function(v) config.riotBypassPosition = v end
})

local VoidBox = MovementTab:AddLeftGroupbox("Void (Extreme)")
Tgl(VoidBox, "VoidEnable", "Void (Extreme)", "Teleports massively out of map.", function(v) config.VoidEnabled = v if v then startVoid() else stopVoid() end end)
VoidBox:AddSlider("VoidX", { Text = "X Distance Bound", Default = 1e8, Min = 1000, Max = 1e9, Rounding = 0, Callback = function(v) config.voidX = v end })
VoidBox:AddSlider("VoidY", { Text = "Y Height Bound",   Default = 1e8, Min = 1000, Max = 1e9, Rounding = 0, Callback = function(v) config.voidY = v end })
VoidBox:AddSlider("VoidZ", { Text = "Z Distance Bound", Default = 1e8, Min = 1000, Max = 1e9, Rounding = 0, Callback = function(v) config.voidZ = v end })

local VoidSpamBox = MovementTab:AddLeftGroupbox("Void Spam (Pattern)")
Tgl(VoidSpamBox, "VoidSpamE", "Void Spam", "Pattern-based void with 8 modes.", function(v) config.voidSpamEnabled = v if v then startVoidSpam() else stopVoidSpam() end end)
VoidSpamBox:AddSlider("VSInterval", { Text = "Interval (lower=faster)", Default = 16,   Min = 5,  Max = 500,   Rounding = 0, Callback = function(v) config.voidSpamInterval = v / 1000 end })
VoidSpamBox:AddSlider("VSBurst",    { Text = "Burst Count",             Default = 5,    Min = 1,  Max = 20,    Rounding = 0, Callback = function(v) config.voidSpamBurst = v end })
VoidSpamBox:AddSlider("VSXPos",     { Text = "X+ Offset",              Default = 2500, Min = 0,  Max = 50000, Rounding = 0, Callback = function(v) config.voidXPos = v end })
VoidSpamBox:AddSlider("VSXNeg",     { Text = "X- Offset",              Default = 2500, Min = 0,  Max = 50000, Rounding = 0, Callback = function(v) config.voidXNeg = v end })
VoidSpamBox:AddSlider("VSYPos",     { Text = "Y+ Offset",              Default = 1500, Min = 0,  Max = 50000, Rounding = 0, Callback = function(v) config.voidYPos = v end })
VoidSpamBox:AddSlider("VSYNeg",     { Text = "Y- Offset",              Default = 1500, Min = 0,  Max = 50000, Rounding = 0, Callback = function(v) config.voidYNeg = v end })
VoidSpamBox:AddSlider("VSZPos",     { Text = "Z+ Offset",              Default = 2500, Min = 0,  Max = 50000, Rounding = 0, Callback = function(v) config.voidZPos = v end })
VoidSpamBox:AddSlider("VSZNeg",     { Text = "Z- Offset",              Default = 2500, Min = 0,  Max = 50000, Rounding = 0, Callback = function(v) config.voidZNeg = v end })

local VoidPatternBox = MovementTab:AddRightGroupbox("Void Pattern")
VoidPatternBox:AddDropdown("VoidPattern", { Text = "Pattern", Default = "random", Values = { "random", "spiral", "wave", "bounce", "chaos", "cross", "helix", "strobe" }, Callback = function(v) config.voidPattern = v end })
Tgl(VoidPatternBox, "VoidAxisX",  "Axis X Enabled", "Enable X-axis void movement.", function(v) config.voidAxisX = v end)
Tgl(VoidPatternBox, "VoidAxisY",  "Axis Y Enabled", "Enable Y-axis void movement.", function(v) config.voidAxisY = v end)
Tgl(VoidPatternBox, "VoidAxisZ",  "Axis Z Enabled", "Enable Z-axis void movement.", function(v) config.voidAxisZ = v end)
Tgl(VoidPatternBox, "VoidSmooth", "Smooth Mode",    "Lerp instead of snap.",        function(v) config.voidSmooth = v end)
VoidPatternBox:AddSlider("VSSmoothA", { Text = "Smooth Alpha (×100)", Default = 50, Min = 1, Max = 100, Rounding = 0, Callback = function(v) config.voidSmoothAlpha = v / 100 end })

local EvasionBox = MovementTab:AddRightGroupbox("Evasion / Blink / Ghost")
Tgl(EvasionBox, "Evasion", "Evasion", "Complex chaotic dodge pattern.", function(v) config.evasionEnabled = v if v then startEvasion() else stopEvasion() end end)
EvasionBox:AddSlider("EvasInt",  { Text = "Evasion Power",      Default = 30, Min = 10, Max = 100, Rounding = 0, Callback = function(v) config.evasionIntensity = v / 10 end })
Tgl(EvasionBox, "Blink", "Blink", "Rapid teleport snapping.", function(v) config.blinkEnabled = v if v then startBlink() else stopBlink() end end)
EvasionBox:AddSlider("BlinkR",   { Text = "Blink Range",        Default = 80, Min = 10, Max = 300, Rounding = 0, Callback = function(v) config.blinkRadius = v end })
EvasionBox:AddSlider("BlinkRt",  { Text = "Blink Speed (snaps/s)", Default = 60, Min = 10, Max = 120, Rounding = 0, Callback = function(v) config.blinkRate = v end })
Tgl(EvasionBox, "Ghost", "Ghost", "Creates tracking data offsets.", function(v) config.ghostEnabled = v if v then startGhost() else stopGhost() end end)
EvasionBox:AddSlider("GhostG",   { Text = "Ghost Gap",          Default = 150, Min = 20, Max = 500, Rounding = 0, Callback = function(v) config.ghostDistance = v end })

local AutoBox = MiscTab:AddLeftGroupbox("Automation")
Tgl(AutoBox, "AutoHeal",  "Auto Collect Heals", "Teleports to medkits/bandages.",  function(v) config.autocollectEnabled = v if v then startAutocollect() else stopAutocollect() end end)
AutoBox:AddSlider("HealR",  { Text = "Collect Radius",     Default = 60,  Min = 10, Max = 300, Rounding = 0, Callback = function(v) config.autocollectRadius = v end })
Tgl(AutoBox, "SafeZone", "Safe Zone Rescue",   "Rescues you from falling.",       function(v) config.safeZoneEnabled = v if v then startSafeZone() else stopSafeZone() end end)
AutoBox:AddSlider("SafeY",  { Text = "Void Y Threshold",   Default = -10, Min = -200, Max = 50, Rounding = 0, Callback = function(v) config.safeZoneY = v end })
Tgl(AutoBox, "Home",     "Return Home",        "Snaps to saved position.",        function(v) config.returnHomeEnabled = v if v then startReturnHome() else stopReturnHome() end end)
AutoBox:AddButton("Save Home Position", function() if getHrp() then getgenv().homePosition = getHrp().Position Notify("System", "Home Position Saved.") end end)
AutoBox:AddSlider("HomeD",  { Text = "Return Delay (s)",   Default = 30,  Min = 5, Max = 150, Rounding = 0, Callback = function(v) config.homeReturnDelay = v / 10 end })
Tgl(AutoBox, "AntiAfk",  "Anti AFK",           "Prevents idle disconnect.",       function(v) config.antiAfkEnabled = v if v then startAntiAfk() else stopAntiAfk() end end)

local LoopBox = MiscTab:AddRightGroupbox("Teleport Loop")
Tgl(LoopBox, "LoopE", "Teleport Loop", "Cycles saved waypoints.", function(v) if v then startTeleportLoop() else stopTeleportLoop() end end)
LoopBox:AddSlider("LoopD", { Text = "Loop Delay (×10ms)", Default = 150, Min = 10, Max = 1000, Rounding = 0, Callback = function(v) config.teleportLoopDelay = v / 100 end })
LoopBox:AddButton("Add Waypoint",    function() if getHrp() then table.insert(getgenv().loopWaypoints, getHrp().Position) Notify("System", "Waypoint Added: " .. #getgenv().loopWaypoints) end end)
LoopBox:AddButton("Clear Waypoints", function() getgenv().loopWaypoints = {} getgenv().loopIndex = 1 Notify("System", "Waypoints Cleared.") end)

local CfgBox = SettingsTab:AddLeftGroupbox("Config Manager")
CfgBox:AddLabel("Profile name:")
local profileInput = ""
CfgBox:AddInput("ProfileNameInput", { Text = "Profile Name", Default = "Main", Numeric = false, Finished = false, Callback = function(v) profileInput = v end })
CfgBox:AddButton("Save Profile",         function() local s, msg = saveProfile(profileInput ~= "" and profileInput or "Main") Notify("Config", msg) end)
CfgBox:AddButton("Load Profile",         function() local s, msg = loadProfile(profileInput ~= "" and profileInput or "Main") Notify("Config", msg) end)
CfgBox:AddButton("Delete Profile",       function() local s, msg = deleteProfile(profileInput ~= "" and profileInput or "Main") Notify("Config", msg) end)
CfgBox:AddButton("List Profiles",        function()
    local names = listProfiles()
    if #names == 0 then Notify("Profiles", "No profiles saved.")
    else Notify("Profiles", table.concat(names, ", ")) end
end)
CfgBox:AddButton("Save Config to File",  function() saveGlobalConfig() Notify("Config", "Saved to meowwCL/global_config.json") end)
CfgBox:AddButton("Load Config from File", function() loadGlobalConfig() Notify("Config", "Loaded from meowwCL/global_config.json") end)
CfgBox:AddButton("Reset Config to Defaults", function()
    getgenv().config = {
        nc = false, flyEnabled = false, flySpeed = 50, doubleJumpEnabled = false,
        fakePositionEnabled = false, desyncEnabled = false,
        evasionEnabled = false, evasionIntensity = 3.0,
        blinkEnabled = false, blinkRadius = 80, blinkRate = 60,
        ghostEnabled = false, ghostDistance = 150,
        glideEnabled = false, glideSpeed = 280, glideAccel = 18,
        VoidEnabled = false, voidX = 1e8, voidY = 1e8, voidZ = 1e8,
        voidSpamEnabled = false, voidSpamInterval = 0.016, voidSpamBurst = 5,
        voidSmooth = false, voidSmoothAlpha = 0.5, voidPattern = "random",
        voidAxisX = true, voidAxisY = true, voidAxisZ = true,
        voidXPos = 2500, voidXNeg = 2500, voidYPos = 1500, voidYNeg = 1500, voidZPos = 2500, voidZNeg = 2500,
        orbit = false, orbitSpeed = 90, orbitDistance = 8, orbitHeight = 0, orbitDir = 1, orbitPrediction = 0.12,
        wallbangEnabled = false, rapidFire = false, teleportEnemyEnabled = false,
        sling = false, daggerBypass = false, AntiEnemy = false,
        slingRage = false, antiProj = false, fastReload = false, antiClose = false,
        antiAimEnabled = false, pitchAngle = 0, yawAngle = 0, spinEnabled = false,
        underMapEnabled = false, underMapY = -500,
        riotAbuserEnabled = false, riotAbuserDistance = 300, riotAbuserX = 30, riotAbuserY = 8, riotAbuserZ = 30, riotAbuserSpin = 720,
        riotBypassEnabled = false, riotBypassDistance = 3, riotBypassHeight = 0, riotBypassUpdate = 0.02, riotBypassPosition = "Front",
        antiAfkEnabled = false, autocollectEnabled = false, autocollectRadius = 60,
        returnHomeEnabled = false, homeReturnDelay = 3.0,
        safeZoneEnabled = false, safeZoneY = -10,
        teleportLoopEnabled = false, teleportLoopDelay = 1.5,
    }
    config = getgenv().config
    Notify("Config", "Reset to defaults.")
end)

local SysBox = SettingsTab:AddRightGroupbox("System")
SysBox:AddButton("Unload Script", function()
    getgenv().meoww_loaded = false
    stopFly(); stopFakePosition(); stopDesync(); stopRapidFire(); stopWallbang()
    stopTp(); stopAntiAfk(); stopVoid(); stopVoidSpam(); stopOrbit()
    stopRiotAbuser(); stopRiotBypass(); stopEvasion(); stopBlink(); stopGhost()
    stopAutocollect(); stopSafeZone(); stopReturnHome(); stopTeleportLoop()
    stopSlingRage(); stopAntiProj(); stopAntiClose(); stopFastReload()
    stopGlide(); stopUnderMap()
    for _, c in ipairs(getgenv().AllConnections) do pcall(function() c:Disconnect() end) end
    if oldFireServer then hookfunction(Instance.new("RemoteEvent").FireServer, oldFireServer) end
    Library:Unload()
end)

task.spawn(function()
    while task.wait(60) do
        if getgenv().meoww_loaded then pcall(saveGlobalConfig) end
    end
end)

Notify("meowwCL prem loaded successfully")
