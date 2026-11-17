-- ============================================================
-- KICIA MELEE v10 — Zero-Ping + Agresif Takip + Ragebot Filtreleri
-- Sticky TP + RespawnNow spam + Booster Collector + Idle Descend
-- ============================================================
local Players    = game:GetService("Players")
local RS         = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer
local UIS        = game:GetService("UserInputService")

-- ============================================================
-- GAME CHECK
-- ============================================================
if game.CreatorId ~= 3461453 then
    lp:Kick("Not Supported game")
    return
end

repeat task.wait() until game:IsLoaded() and lp.Character

-- ============================================================
-- Signal / Trove
-- ============================================================
local Signal = {}
Signal.__index = Signal
function Signal.new() return setmetatable({ _handlers = {} }, Signal) end
function Signal:Connect(fn)
    local h = { fn = fn, connected = true }
    table.insert(self._handlers, h)
    local sig = self
    return {
        Connected = true,
        Disconnect = function(c)
            if not h.connected then return end
            h.connected = false
            c.Connected = false
            local i = table.find(sig._handlers, h)
            if i then table.remove(sig._handlers, i) end
        end,
    }
end
function Signal:Fire(...)
    local list = table.clone(self._handlers)
    for _, h in ipairs(list) do
        if h.connected then task.spawn(h.fn, ...) end
    end
end
function Signal:Destroy() table.clear(self._handlers) end

local Trove = {}
Trove.__index = Trove
function Trove.new(name) return setmetatable({ _name = name, _items = {}, _cleaning = false }, Trove) end
local function cleanItem(o)
    local t = typeof(o)
    if t == "RBXScriptConnection" then pcall(function() o:Disconnect() end)
    elseif t == "Instance" then pcall(function() o:Destroy() end)
    elseif t == "thread" then pcall(task.cancel, o)
    elseif type(o) == "function" then pcall(o)
    elseif type(o) == "table" then
        local destroy = o.Destroy or o.Disconnect
        if type(destroy) == "function" then pcall(destroy, o) end
    end
end
function Trove:Add(o) table.insert(self._items, o); return o end
function Trove:Connect(sig, fn) return self:Add(sig:Connect(fn)) end
function Trove:Clean()
    if self._cleaning then return end
    self._cleaning = true
    local items = self._items
    self._items = {}
    for i = #items, 1, -1 do cleanItem(items[i]) end
    self._cleaning = false
end
Trove.Destroy = Trove.Clean

local MainTrove = Trove.new("KiciaMelee")

-- ============================================================
-- FAST FLAGS
-- ============================================================
pcall(function()
    if setfflag then
        setfflag("DFIntS2PhysicsSenderRate", "240")
        setfflag("DFIntAssemblyHistoryBufferSize", "2147483648")
        setfflag("DFIntAssemblyHistorySkipSize", "0")
    end
end)

-- ============================================================
-- MODÜL YÜKLEMELERİ
-- ============================================================
local EnumLibrary = require(RS.Modules.EnumLibrary)
local UseItem     = RS.Remotes.Replication.Fighter:WaitForChild("UseItem", 10)
local FC          = require(lp.PlayerScripts.Controllers:WaitForChild("FighterController", 30))
local function localFighter() return FC and FC.LocalFighter end

local CameraController
pcall(function()
    CameraController = require(lp.PlayerScripts.Controllers.CameraController)
end)

local setRotationFn = nil
if CameraController then
    pcall(function()
        local mt = getmetatable(CameraController)
        if mt and type(mt.__index) == "table" then
            setRotationFn = mt.__index.SetRotation
        end
    end)
end

local function applyCameraRotation(pitch, yaw)
    local rot = Vector2.new(pitch, yaw)
    if setRotationFn then
        pcall(function() coroutine.wrap(setRotationFn)(CameraController, rot) end)
    else
        pcall(function() CameraController.Rotation = rot end)
    end
end

local _to_enum = rawget(EnumLibrary, "_to_enum")
local function toEnum(name)
    if _to_enum then return _to_enum[name] end
    local ok, v = pcall(function() return EnumLibrary:ToEnum(name) end)
    if ok and v ~= nil then return v end
    return nil
end

local START_SHOOTING = toEnum("StartShooting")
local START_AIMING   = toEnum("StartAiming")
local ANIM_ATTACK    = toEnum("AttackAnimation1") or toEnum("Attack1")
local ANIM_HEAVY     = toEnum("HeavyAttackAnimation1") or toEnum("HeavyAttack1")

-- ============================================================
-- CONFIG
-- ============================================================
local CONFIG = {
    ATTACK_DURATION  = 0.15,

    -- Sticky TP
    TP_BACK          = 1.5,
    TP_FRONT         = 1.5,
    TP_SIDE          = 1.5,
    TP_Y_OFFSET      = 0.0,
    TP_WRITES_PER_FRAME = 8,
    STICKY_LOCK      = true,
    STICKY_FRAMES    = 4,

    RANGE            = math.huge,
    AIM_SMOOTHING    = 0,

    -- Zero-Ping
    PREDICTION_STRENGTH = 1.0,
    MAX_PING            = 0.3,

    BACKSTAB_SPEED      = 120,
    SMART_BACKSTAB      = true,

    TARGET_MODE         = "Closest",
    PRIORITY_VOIDED     = true,
    PRIORITY_ATTACKERS  = true,
    NEAR_OTHER_MATCH_R  = 1000,

    -- RespawnNow spam
    RESPAWN_SPAM_RATE   = 0.1,

    -- Booster collector
    AUTO_HEALTH        = true,
    AUTO_AMMO          = true,
    AUTO_RESPAWN       = true,

    -- Equip spam (0 = every frame)
    EQUIP_RETRY_RATE   = 0.0,

    -- Idle hover (no target) — up 30 studs above closest part
    IDLE_DESCEND        = true,
    IDLE_DESCEND_HEIGHT = 30,
    IDLE_DESCEND_SPEED  = 0.0,
    IDLE_RAY_LENGTH     = 5000,
}

-- ============================================================
-- RESPAWN NOW SPAM
-- ============================================================
local RespawnNow
pcall(function()
    RespawnNow = RS:WaitForChild("Remotes", 15)
        :WaitForChild("Duels", 15)
        :WaitForChild("RespawnNow", 15)
end)

task.spawn(function()
    while true do
        if RespawnNow then
            pcall(function() RespawnNow:FireServer() end)
        end
        task.wait(CONFIG.RESPAWN_SPAM_RATE)
    end
end)

-- ============================================================
-- AUTO RESPAWN (spacebar method)
-- ============================================================
-- ============================================================
-- FALLEN PARTS
-- ============================================================
local function disableFallenParts()
    pcall(function() workspace.FallenPartsDestroyHeight = 0/0 end)
end
disableFallenParts()
task.spawn(function()
    while true do task.wait(0.5) disableFallenParts() end
end)

-- ============================================================
-- FAST CFrame WRITE (sticky)
-- ============================================================
local _ni_cache = nil
local _ni_checked = false
local function getHRPNewIndex(hrp)
    if not _ni_checked then
        local mt = getrawmetatable(hrp)
        _ni_cache = mt and rawget(mt, "__newindex")
        _ni_checked = true
    end
    return _ni_cache
end

local V0 = Vector3.zero
local function fastSetCF(hrp, cf)
    local ni = getHRPNewIndex(hrp)
    if ni then
        pcall(ni, hrp, "AssemblyLinearVelocity", V0)
        pcall(ni, hrp, "AssemblyAngularVelocity", V0)
        pcall(ni, hrp, "CFrame", cf)
        pcall(ni, hrp, "AssemblyLinearVelocity", V0)
        pcall(ni, hrp, "AssemblyAngularVelocity", V0)
    else
        pcall(function()
            hrp.AssemblyLinearVelocity = V0
            hrp.AssemblyAngularVelocity = V0
            hrp.CFrame = cf
        end)
    end
    if sethiddenproperty then
        pcall(sethiddenproperty, hrp, "CFrame", cf)
        pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", V0)
        pcall(sethiddenproperty, hrp, "AssemblyAngularVelocity", V0)
    end
end

local function stickySetCF(hrp, cf)
    for _ = 1, CONFIG.TP_WRITES_PER_FRAME do
        fastSetCF(hrp, cf)
    end
end

local stickyLockUntil = 0
local stickyCF = nil

local function beginStickyLock(hrp, cf)
    if not CONFIG.STICKY_LOCK then return end
    stickyCF = cf
    stickyLockUntil = tick() + (CONFIG.STICKY_FRAMES * (1 / 60))
end

-- ============================================================
-- IDLE DESCEND STATE + HELPERS
-- ============================================================
local idleDescendActive = false

local function isIdleDescending()
    return CONFIG.IDLE_DESCEND and idleDescendActive
end

local function findClosestPartUnder(pos)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { lp.Character }
    params.IgnoreWater = true

    local result = workspace:Raycast(pos, Vector3.new(0, -CONFIG.IDLE_RAY_LENGTH, 0), params)
    if not result then return nil end
    return result.Position, result.Instance
end

local function computeIdleDescendCF(hrp)
    local pos = hrp.Position
    local hitPos = findClosestPartUnder(pos)
    if not hitPos then return nil end
    local target = hitPos + Vector3.new(0, CONFIG.IDLE_DESCEND_HEIGHT, 0)
    return CFrame.new(target, target + hrp.CFrame.LookVector)
end

-- ============================================================
-- AUTO COLLECT BOOSTERS
-- ============================================================
local boosterT = 0
MainTrove:Connect(RunService.RenderStepped, function(dt)
    local character = lp.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Don't fight idle-descend for HRP position
    if isIdleDescending() then return end

    boosterT = boosterT + dt * 8
    local bounce = math.sin(boosterT) * 4

    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == "_drop" and obj:IsA("BasePart") then
            if (CONFIG.AUTO_AMMO and obj:FindFirstChild("Ammo")) or
               (CONFIG.AUTO_HEALTH and obj:FindFirstChild("Health")) then

                obj.Anchored = true
                obj.CFrame = CFrame.new(hrp.Position + Vector3.new(0, bounce, 0))
                obj.Transparency = 1

                for _, child in pairs(obj:GetDescendants()) do
                    if child:IsA("BasePart")
                        or child:IsA("UnionOperation")
                        or child:IsA("MeshPart")
                        or child:IsA("SpecialMesh") then
                        pcall(function() child.Transparency = 1 end)
                    end

                    if child:IsA("BillboardGui")
                        or child:IsA("SurfaceGui")
                        or child:IsA("ParticleEmitter")
                        or child:IsA("SelectionBox") then
                        pcall(function() child.Enabled = false end)
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- ENEMY TRACKER
-- ============================================================
local enemyTrackers    = setmetatable({}, { __mode = "k" })
local enemyTrackerChar = setmetatable({}, { __mode = "k" })
local MAX_TRACK_SAMPLES = 8

local function updateEnemyTracker(plr)
    local char = plr.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local tracker = enemyTrackers[plr]
    if not tracker or enemyTrackerChar[plr] ~= char then
        tracker = { positions = {}, cframes = {}, times = {} }
        enemyTrackers[plr]  = tracker
        enemyTrackerChar[plr] = char
    end

    local now = workspace:GetServerTimeNow()
    table.insert(tracker.positions, root.Position)
    table.insert(tracker.cframes,   root.CFrame)
    table.insert(tracker.times,     now)

    while #tracker.positions > MAX_TRACK_SAMPLES do
        table.remove(tracker.positions, 1)
        table.remove(tracker.cframes,   1)
        table.remove(tracker.times,     1)
    end
end

-- ============================================================
-- PREDICTION
-- ============================================================
local function getPredictedState(plr)
    local char = plr.Character
    local fbPos, fbCF = Vector3.zero, CFrame.new()
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then fbPos, fbCF = root.Position, root.CFrame end
    end

    local tracker = enemyTrackers[plr]
    if not tracker or #tracker.positions < 2 then
        return {
            Position = fbPos, CFrame = fbCF,
            Velocity = Vector3.zero, Speed = 0,
            PredictionTime = 0, Confidence = 0,
            RealPosition = fbPos, RealCFrame = fbCF,
        }
    end

    local n = #tracker.positions
    local totalW, sumVel = 0, Vector3.zero
    local velocities = {}

    for i = 2, n do
        local dt = tracker.times[i] - tracker.times[i - 1]
        if dt > 0.001 then
            local v = (tracker.positions[i] - tracker.positions[i - 1]) / dt
            table.insert(velocities, v)
            local w = i - 1
            sumVel  = sumVel + v * w
            totalW  = totalW + w
        end
    end

    local avgVel = totalW > 0 and (sumVel / totalW) or Vector3.zero

    local sigma = 0
    if #velocities >= 2 then
        local acc = 0
        for _, v in velocities do
            acc = acc + (v - avgVel).Magnitude ^ 2
        end
        sigma = math.sqrt(acc / #velocities)
    end

    local sampleConf   = math.clamp((n - 1) / 3, 0.35, 1)
    local varianceConf = math.clamp(1 - sigma / 80, 0.30, 1)
    local confidence   = sampleConf * varianceConf

    local lastPos, lastCF, lastT = tracker.positions[n], tracker.cframes[n], tracker.times[n]
    local sampleAge = math.max(0, workspace:GetServerTimeNow() - lastT)

    local rawPing = lp:GetNetworkPing()
    local rtt = rawPing > 1 and (rawPing / 1000) or rawPing

    local rawPredTime = (rtt + sampleAge) * CONFIG.PREDICTION_STRENGTH * confidence
    local predictionTime = math.clamp(rawPredTime, 0, CONFIG.MAX_PING)

    local predictedPos = lastPos + avgVel * predictionTime
    local horizVel     = Vector3.new(avgVel.X, 0, avgVel.Z)

    return {
        Position        = predictedPos,
        CFrame          = lastCF,
        Velocity        = avgVel,
        Speed           = horizVel.Magnitude,
        PredictionTime  = predictionTime,
        Confidence      = confidence,
        RealPosition    = lastPos,
        RealCFrame      = lastCF,
    }
end

-- ============================================================
-- FİLTRELEME HELPERLARI
-- ============================================================
local function getRoot(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function scanWeapon(plr)
    local vms = workspace:FindFirstChild("ViewModels")
    if not vms then return "" end
    for _, model in ipairs(vms:GetChildren()) do
        if model:IsA("Model") then
            local sp = model.Name:find(" - ", 1, true)
            if sp and model.Name:sub(1, sp-1) == plr.Name then
                return model.Name:sub(sp+3):lower()
            end
        end
    end
    return ""
end

local function isKatana(plr) return scanWeapon(plr):find("katana", 1, true) ~= nil end

local function isInvincible(plr)
    local char = plr and plr.Character
    local root = getRoot(char)
    if not root then return true end
    for _, obj in ipairs(root:GetChildren()) do
        if obj:IsA("Attachment") and obj.Name == "Attachment" then return true end
    end
    return char:FindFirstChild("InvincibilityParticles", true) ~= nil
end

local function isNearOtherMatch(pos, ignore)
    if typeof(pos) ~= "Vector3" then return false end
    local myEnv = lp:GetAttribute("EnvironmentID")
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr ~= ignore and plr:GetAttribute("EnvironmentID") ~= myEnv then
            local r = getRoot(plr.Character)
            if r and (r.Position - pos).Magnitude <= CONFIG.NEAR_OTHER_MATCH_R then
                return true
            end
        end
    end
    return false
end

local function isShootingRange()
    for _, obj in ipairs({workspace, lp}) do
        for _, attr in ipairs({"ShootingRange", "Mode", "Map", "MapName"}) do
            local v = obj:GetAttribute(attr)
            if v == true and attr == "ShootingRange" then return true end
            if type(v) == "string" then
                local t = v:lower():gsub("[%s_%-]", "")
                if t:find("shootingrange", 1, true) or t:find("firingrange", 1, true) then
                    return true
                end
            end
        end
    end
    return false
end

local function hasAllyLabels(plr)
    local char = plr.Character
    if not char then return false end
    for _, n in ipairs({"HumanoidRootPart", "Head", "HitboxHead"}) do
        local part = char:FindFirstChild(n)
        if part then
            for _, l in ipairs({"AllyLabel", "TeammateLabel", "TeamLabel", "FriendLabel"}) do
                if part:FindFirstChild(l) then return true end
            end
        end
    end
    return false
end

-- ============================================================
-- TEAMCHECK
-- ============================================================
local function isTeamMate(plr)
    if plr == lp then return true end
    if lp.Team and plr.Team and lp.Team == plr.Team then return true end
    local myTid = lp:GetAttribute("TeamID")
    local theirTid = plr:GetAttribute("TeamID")
    if myTid ~= nil and theirTid ~= nil and myTid == theirTid then return true end
    return false
end

local function canAttack(plr)
    if plr == lp or isTeamMate(plr) then return false end
    local myEnv = lp:GetAttribute("EnvironmentID")
    if not myEnv or plr:GetAttribute("EnvironmentID") ~= myEnv then return false end
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if char:FindFirstChildWhichIsA("ForceField", true) then return false end
    if plr:GetAttribute("IsInvincible") == true then return false end
    if isInvincible(plr) then return false end
    if hasAllyLabels(plr) then return false end
    if isKatana(plr) then return false end
    local r = getRoot(char)
    if r and isNearOtherMatch(r.Position, plr) then return false end
    return true
end

local function findBestTarget(pos)
    local best, bestV = nil, math.huge
    local useHP = CONFIG.TARGET_MODE == "LowestHealth"
    for _, plr in ipairs(Players:GetPlayers()) do
        if canAttack(plr) then
            local root = getRoot(plr.Character)
            if root then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local v = useHP and (hum and hum.Health or math.huge)
                    or (root.Position - pos).Magnitude
                if CONFIG.PRIORITY_VOIDED and root.Position.Magnitude > 1000000 then
                    v = v - 2000000000
                end
                if CONFIG.PRIORITY_ATTACKERS and scanWeapon(plr) ~= "" then
                    v = v - 1000000000
                end
                if v < bestV then
                    bestV = v
                    best = { Player = plr, Root = root, Char = plr.Character }
                end
            end
        end
    end
    return best
end

local function findClosest(pos) return findBestTarget(pos) end

-- ============================================================
-- PAYLOAD
-- ============================================================
local function orient(base, pitch, yaw, roll)
    return {
        ["\0"]=base["\0"], ["\1"]=base["\1"], ["\2"]=base["\2"],
        ["\3"]=pitch,     ["\4"]=yaw or 0,     ["\5"]=roll or 0
    }
end

local KNIFE_SURFACE         = { ["\0"]=0,     ["\1"]=1,    ["\2"]=0, ["\3"]=0,          ["\4"]=0,       ["\5"]=0 }
local KNIFE_ABOVE_PRIMARY   = { ["\0"]=-9e37, ["\1"]=0,    ["\2"]=0, ["\3"]=-math.pi/2, ["\4"]=math.pi, ["\5"]=math.pi }
local KNIFE_ABOVE_SECONDARY = { ["\0"]=0,     ["\1"]=-9e7, ["\2"]=0, ["\3"]=-math.pi/2, ["\4"]=math.pi, ["\5"]=math.pi }
local PRIMARY_BASE          = { ["\0"]=-9e37, ["\1"]=0,    ["\2"]=0 }
local SECONDARY_BASE        = { ["\0"]=0,     ["\1"]=-9e7, ["\2"]=0 }

local function itemField(item, key)
    if not item then return nil end
    local ok, v = pcall(function() return item:Get(key) end)
    if ok and v ~= nil then return v end
    return rawget(item, key)
end

local function isMeleeItem(item)
    if type(item) ~= "table" then return false end
    local info = rawget(item, "Info")
    if type(info) ~= "table" then return false end
    return (rawget(info, "Type") or rawget(info, "Class")) == "Melee"
end

local function hasRiotShield(enemy)
    if not enemy or not enemy.Char then return false end
    for _, child in ipairs(enemy.Char:GetChildren()) do
        if child:IsA("Tool") and child.Name == "Riot Shield" then return true end
    end
    return false
end

local function computeTPPosFromState(state, isKnife, shieldFront)
    local ep   = state.Position
    local look = Vector3.new(state.CFrame.LookVector.X, 0, state.CFrame.LookVector.Z)
    if look.Magnitude > 0.01 then look = look.Unit end

    local y = ep.Y + CONFIG.TP_Y_OFFSET

    if shieldFront then
        return Vector3.new(ep.X + look.X * CONFIG.TP_FRONT,  y, ep.Z + look.Z * CONFIG.TP_FRONT)
    elseif isKnife then
        return Vector3.new(ep.X - look.X * CONFIG.TP_BACK,   y, ep.Z - look.Z * CONFIG.TP_BACK)
    else
        local right = Vector3.new(state.CFrame.RightVector.X, 0, state.CFrame.RightVector.Z)
        if right.Magnitude > 0.01 then right = right.Unit end
        return Vector3.new(ep.X + right.X * CONFIG.TP_SIDE,  y, ep.Z + right.Z * CONFIG.TP_SIDE)
    end
end

local function buildPayload(predictedCF, targetPart, isKnife)
    local _, eYaw, eRoll = predictedCF:ToOrientation()
    local pitch = -math.pi / 2
    local primary, secondary, anim, fireType
    if isKnife then
        primary   = orient(KNIFE_ABOVE_PRIMARY,   pitch, eYaw, eRoll)
        secondary = orient(KNIFE_ABOVE_SECONDARY, pitch, eYaw, eRoll)
        anim      = ANIM_HEAVY
        fireType  = START_AIMING or START_SHOOTING
    else
        primary   = orient(PRIMARY_BASE,   pitch, eYaw, eRoll)
        secondary = orient(SECONDARY_BASE, pitch, eYaw, eRoll)
        anim      = ANIM_ATTACK
        fireType  = START_SHOOTING
    end
    return {
        [utf8.char(1)] = {
            [utf8.char(0)] = primary,
            [utf8.char(1)] = secondary,
            [utf8.char(2)] = targetPart,
            [utf8.char(3)] = KNIFE_SURFACE,
        },
        [utf8.char(2)] = anim,
    }, fireType
end

local function tryEquipMelee()
    local f = localFighter()
    local items = f and rawget(f, "Items")
    if type(items) ~= "table" then return end
    for i, it in ipairs(items) do
        if isMeleeItem(it) then
            pcall(function() f:EquipItem(i) end)
            return
        end
    end
end

local function canAttackNow(predState)
    if predState.Speed >= CONFIG.BACKSTAB_SPEED then return false end
    return true
end

-- ============================================================
-- STATE
-- ============================================================
local state          = "READY"
local stateEndsAt    = 0
local currentEnemy   = nil
local firedThisAtk   = false
local lastEquip      = 0
local lastGroundPos  = nil
local aimPitch, aimYaw = 0, 0

local cachedEnemy, cachedEnemyAt = nil, 0
local function getClosestEnemy()
    local now = tick()
    if now - cachedEnemyAt < 0.05 then
        if cachedEnemy and canAttack(cachedEnemy.Player) then
            return cachedEnemy
        end
        cachedEnemy, cachedEnemyAt = nil, 0
    end
    cachedEnemyAt = now
    local searchFrom = lastGroundPos
    if not searchFrom then
        local lpRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        searchFrom = lpRoot and lpRoot.Position
    end
    if not searchFrom then cachedEnemy = nil; return nil end
    cachedEnemy = findBestTarget(searchFrom)
    return cachedEnemy
end

-- ============================================================
-- AIM LOCK
-- ============================================================
MainTrove:Connect(RunService.RenderStepped, function(dt)
    if not CameraController then return end
    local enemy = getClosestEnemy()
    if not enemy then return end

    local targetPart = enemy.Char:FindFirstChild("HitboxHead")
        or enemy.Char:FindFirstChild("Head")
        or enemy.Root
    if not targetPart or not targetPart.Parent then return end

    local from
    if state == "ATTACK" and lastGroundPos then
        from = lastGroundPos
    else
        local enemyLook = enemy.Root.CFrame.LookVector
        local lookH = Vector3.new(enemyLook.X, 0, enemyLook.Z)
        if lookH.Magnitude > 0.01 then lookH = lookH.Unit end
        from = enemy.Root.Position - lookH * 3
    end

    local dir = targetPart.Position - from
    if dir.Magnitude < 0.01 then return end
    dir = dir.Unit

    local targetPitch = math.asin(math.clamp(dir.Y, -1, 1))
    local targetYaw   = math.atan2(-dir.X, -dir.Z)

    if CONFIG.AIM_SMOOTHING > 0 then
        local alpha = math.clamp(dt / CONFIG.AIM_SMOOTHING, 0, 1)
        local dYaw = targetYaw - aimYaw
        if dYaw > math.pi then dYaw = dYaw - 2*math.pi
        elseif dYaw < -math.pi then dYaw = dYaw + 2*math.pi end
        aimYaw = aimYaw + dYaw * alpha
        aimPitch = aimPitch + (targetPitch - aimPitch) * alpha
    else
        aimPitch = targetPitch
        aimYaw   = targetYaw
    end

    applyCameraRotation(aimPitch, aimYaw)
end)

-- ============================================================
-- ANA DÖNGÜ — sticky TP + her frame backstab + idle descend
-- ============================================================
MainTrove:Connect(RunService.Heartbeat, function()
    local now    = tick()
    local lpRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not lpRoot then return end

    -- Sticky lock: aktifse her frame pozisyonu yeniden yaz
    if CONFIG.STICKY_LOCK and stickyCF and now < stickyLockUntil then
        stickySetCF(lpRoot, stickyCF)
    end

    if isShootingRange() then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then updateEnemyTracker(plr) end
    end

    local f = localFighter()
    if not f then return end

    local enemy = getClosestEnemy()

    -- ===== IDLE DESCEND (no target) =====
    if not enemy then
        idleDescendActive = true
        local targetCF = computeIdleDescendCF(lpRoot)
        if targetCF then
            if CONFIG.IDLE_DESCEND_SPEED > 0 then
                local cur = lpRoot.Position
                local tgt = targetCF.Position
                local step = CONFIG.IDLE_DESCEND_SPEED * (1/60)
                local delta = tgt - cur
                if delta.Magnitude > 0.01 then
                    local move = delta.Unit * math.min(step, delta.Magnitude)
                    fastSetCF(lpRoot, CFrame.new(cur + move) * (targetCF - targetCF.Position))
                else
                    fastSetCF(lpRoot, targetCF)
                end
            else
                stickySetCF(lpRoot, targetCF)
            end
        end
        return
    else
        idleDescendActive = false
    end

    -- ===== EQUIP =====
    local item = f.EquippedItem
    if not isMeleeItem(item) then
        if now - lastEquip >= CONFIG.EQUIP_RETRY_RATE then
            lastEquip = now
            tryEquipMelee()
        end
        return
    end

    local isKnife = tostring(item.Name or "") == "Knife"

    local invalid = enemy.Root.Parent == nil
        or enemy.Player.Character ~= enemy.Char
        or not canAttack(enemy.Player)
    if invalid then return end

    local predState = getPredictedState(enemy.Player)
    if not canAttackNow(predState) then return end
    if isNearOtherMatch(predState.RealPosition, enemy.Player) then return end

    local hum = lpRoot.Parent and lpRoot.Parent:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end) end

    local shieldFront = isKnife and hasRiotShield(enemy)

    local tpPos = computeTPPosFromState(predState, isKnife, shieldFront)
    local tpCF  = CFrame.lookAt(tpPos, predState.Position)

    -- STRONG STICKY TP
    stickySetCF(lpRoot, tpCF)
    beginStickyLock(lpRoot, tpCF)

    lastGroundPos = lpRoot.Position

    local targetPart = enemy.Char:FindFirstChild("HitboxBody")
        or enemy.Char:FindFirstChild("HitboxHead")
        or enemy.Char:FindFirstChild("Head")
        or enemy.Root
    if not targetPart or not targetPart.Parent then return end

    local payload, fireType = buildPayload(predState.CFrame, targetPart, isKnife)
    local oid = itemField(item, "ObjectID")
    if oid then
        stickySetCF(lpRoot, tpCF)
        pcall(function() UseItem:FireServer(oid, fireType, payload, nil) end)
    end
end)