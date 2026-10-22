local env = getgenv()
local previousPerfectBlockCleanup = env.AutoShootPerfectBlockCleanup
if type(previousPerfectBlockCleanup) == 'function' then pcall(previousPerfectBlockCleanup) end
local previousRuntime = env.AutoShootRuntime
if type(previousRuntime) == 'table' then
    previousRuntime.Running = false
    for _, connection in ipairs(previousRuntime.Connections or {}) do
        pcall(function() connection:Disconnect() end)
    end
    if previousRuntime.Library then
        pcall(function() previousRuntime.Library:Unload() end)
    end
end

local previousUndergroundCleanup = rawget(_G, "__LuaHookUndergroundStandaloneCleanup")
if type(previousUndergroundCleanup) == "function" then pcall(previousUndergroundCleanup) end
local previousUndergroundController = rawget(_G, "__CrefyUndergroundController")
if type(previousUndergroundController) == "table" and type(previousUndergroundController.Stop) == "function" then
    pcall(previousUndergroundController.Stop)
end

local runtime = { Running = true, Connections = {} }
env.AutoShootRuntime = runtime

local repo = 'https://raw.githubusercontent.com/lrexzyq/Crefy/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
runtime.Library = Library
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Options = Library.Options
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local repS = cloneref(game:GetService("ReplicatedStorage"))
local plrs = cloneref(game:GetService("Players"))
local runS = cloneref(game:GetService("RunService"))
local ws = cloneref(game:GetService("Workspace"))

local lplr = plrs.LocalPlayer
local util = require(repS.Modules.Utility)
local enum = require(repS.Modules.EnumLibrary)
local FighterController = require(lplr.PlayerScripts.Controllers.FighterController)

getgenv().Config = {
    Enabled = true,
    FireRate = 0.05,
    WeaponSlot = "Primary",
    MaxDistance = 500
}

local slots = { Primary = 1, Secondary = 2, Melee = 3 }
local function getSlotNumber()
    return slots[getgenv().Config.WeaponSlot] or 1
end

runtime.EquipThread = task.spawn(function()
    while runtime.Running do
        task.wait(1)
        if not runtime.Running then break end
        if not getgenv().Config.Enabled then continue end
        local localFighter = FighterController.LocalFighter
        if localFighter and localFighter.EquippedItem == nil then
            pcall(function() localFighter:EquipItem(getSlotNumber()) end)
        end
    end
end)

local lastFire = 0
local cachedTarget, cachedRoot, cachedHead, cachedHumanoid
local lastCacheTime = -math.huge
local CACHE_INTERVAL = 0.2
local function getClosestTarget()
    local now = os.clock()
    local config = getgenv().Config
    local maxDistance = tonumber(config and config.MaxDistance) or 500
    if maxDistance ~= maxDistance or maxDistance == math.huge or maxDistance == -math.huge then
        maxDistance = 500
    end
    maxDistance = math.max(0, maxDistance)
    if now - lastCacheTime < CACHE_INTERVAL then
        local char = lplr.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        local myHumanoid = char and char:FindFirstChildOfClass("Humanoid")
        if cachedTarget and cachedRoot and cachedHead and cachedHumanoid
            and myRoot and myHumanoid and myHumanoid.Health > 0
            and cachedTarget.Parent
            and cachedRoot.Parent == cachedTarget
            and cachedHead.Parent == cachedTarget
            and cachedHumanoid.Parent == cachedTarget
            and cachedHumanoid.Health > 0
            and (myRoot.Position - cachedRoot.Position).Magnitude <= maxDistance then
            return cachedTarget, cachedRoot, cachedHead
        end
        cachedTarget, cachedRoot, cachedHead, cachedHumanoid = nil, nil, nil, nil
        return nil, nil, nil
    end

    lastCacheTime = now

    local char = lplr.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    local myHumanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not myRoot or not myHumanoid or myHumanoid.Health <= 0 then
        cachedTarget, cachedRoot, cachedHead, cachedHumanoid = nil, nil, nil, nil
        return nil, nil, nil
    end

    local closestModel, closestRoot, closestHead, closestHumanoid = nil, nil, nil, nil
    local closestDist = maxDistance
    local function scanFolder(folder)
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") and obj ~= char then
                local pRoot = obj:FindFirstChild("HumanoidRootPart")
                local pHead = obj:FindFirstChild("Head")
                local pHum = obj:FindFirstChildWhichIsA("Humanoid")

                if pRoot and pHead and pHum and pHum.Health > 0 and not plrs:GetPlayerFromCharacter(obj) then
                    local dist = (myRoot.Position - pRoot.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestModel = obj
                        closestRoot = pRoot
                        closestHead = pHead
                        closestHumanoid = pHum
                    end
                end
            end
        end
    end

    scanFolder(ws)
    local npcFolder = ws:FindFirstChild("NPCs") or ws:FindFirstChild("Enemies") or ws:FindFirstChild("Mobs")
    if npcFolder then scanFolder(npcFolder) end

    cachedTarget, cachedRoot, cachedHead, cachedHumanoid = closestModel, closestRoot, closestHead, closestHumanoid
    return cachedTarget, cachedRoot, cachedHead
end

runtime.Heartbeat = runS.Heartbeat:Connect(function()
    if not runtime.Running then return end
    if not getgenv().Config.Enabled then return end

    local targetModel, targetRoot, targetHead = getClosestTarget()
    if not targetModel or not targetHead or not targetRoot then return end

    local char = lplr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local localFighter = FighterController.LocalFighter
    if not localFighter or not localFighter.EquippedItem then return end

    if tick() - lastFire < getgenv().Config.FireRate then return end
    lastFire = tick()

    local originPos = targetHead.Position + Vector3.new(0, 1, 0)
    local targetPos = targetHead.Position
    local aimCF = CFrame.lookAt(originPos, targetPos)
    local targetCF = targetHead.CFrame

    local randomOffset = Vector3.new(
        (math.random() - 0.5) * 0.02,
        (math.random() - 0.5) * 0.02,
        (math.random() - 0.5) * 0.02
    )
    local aimedPos = targetPos + randomOffset
    local objSpaceHeadOffset = targetHead.CFrame:ToObjectSpace(CFrame.new(aimedPos))

    local cameradata = {}
    cameradata[utf8.char(1)] = {
        [utf8.char(0)] = util:EncodeCFrame(aimCF),
        [utf8.char(1)] = util:EncodeCFrame(targetCF),
        [utf8.char(2)] = targetHead,
        [utf8.char(3)] = util:EncodeCFrame(objSpaceHeadOffset)
    }

    pcall(function()
        repS.Remotes.Replication.Fighter.UseItem:FireServer(
            localFighter.EquippedItem:Get("ObjectID"),
            enum:ToEnum("StartShooting"),
            cameradata,
            nil
        )
    end)
end)
table.insert(runtime.Connections, runtime.Heartbeat)

local UndergroundController = (function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local lp = Players.LocalPlayer

    local MIN_DEPTH = 1.25
    local MAX_DEPTH = 12.0
    local SELF_BUFFER = 0.35
    local PLAYER_SCAN_RADIUS = 80
    local PLAYER_VERTICAL_TOLERANCE = 32
    local PLAYER_SEPARATION = 2.5
    local OTHER_THRESHOLD = 0.75
    local ADAPTIVE_SCAN_INTERVAL = 0.20
    local CACHE_MOVE_DISTANCE = 10
    local DOWN_FLOOR_MAX_GAP = 8
    local NEAR_FLOOR_GAP = 3
    local UP_SURFACE_MIN_GAP = 0.6
    local UP_SURFACE_MAX_GAP = 96
    local CLIENT_ESCAPE_DISTANCE = 18
    local MAX_UPDATE_DISTANCE = 500

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true

    local desync = nil
    local heartbeatConn = nil
    local deathConn = nil
    local snapshot = nil
    local snapshotCharacter = nil
    local lastServerCFrame = nil
    local lastClientCFrame = nil
    local enabled = false
    local adaptiveDepth = MIN_DEPTH
    local currentDepth = MIN_DEPTH
    local adaptiveScanAt = 0
    local adaptiveDepthUpdatedAt = 0
    local otherCount = 0
    local otherFloorPart = nil
    local cachedOtherDepth = MIN_DEPTH
    local cachedOtherFloorPart = nil
    local cachedOtherCount = 0
    local cachedFloorPart = nil
    local cachedLocalPosition = nil
    local cachedEnvironmentId = nil

    local startUnderground, stopUnderground
    local localSurfaceCache = { ready = false }

    local RootDesync = {}
    RootDesync.__index = RootDesync

    function RootDesync.new(rootPart)
        local self = setmetatable({
            _rootPart = rootPart,
            _boundId = "LuaHook_Underground_" .. tostring({}),
            _oldCFrame = rootPart.CFrame,
            _cframe = nil,
        }, RootDesync)
        RunService:BindToRenderStep(self._boundId, Enum.RenderPriority.First.Value, function()
            local root = self._rootPart
            local old = self._oldCFrame
            if root and old ~= nil then
                local okParent, hasParent = pcall(function() return root.Parent ~= nil end)
                if not okParent or not hasParent then
                    self._rootPart = nil
                    self._oldCFrame = nil
                    return
                end
                local okRestore = pcall(function() root.CFrame = old end)
                if okRestore then self._oldCFrame = nil end
            end
        end)
        return self
    end

    function RootDesync:SetServerCFrame(cf)
        if cf == nil then
            self._cframe = nil
            return true
        end
        if typeof(cf) ~= "CFrame" then
            self._cframe = nil
            return false
        end
        for _, component in ipairs({ cf:GetComponents() }) do
            if type(component) ~= "number" or component ~= component
                or component == math.huge or component == -math.huge then
                self._cframe = nil
                return false
            end
        end
        local pos = cf.Position
        if math.abs(pos.X) > 1000000 or math.abs(pos.Y) > 1000000 or math.abs(pos.Z) > 1000000 then
            self._cframe = nil
            return false
        end
        self._cframe = cf
        return true
    end

    function RootDesync:GetClientCFrame()
        local root = self._rootPart
        return self._oldCFrame or (root and root.CFrame)
    end

    function RootDesync:HeartbeatUpdate()
        local rootPart = self._rootPart
        local cf = self._cframe
        if not rootPart or cf == nil then return false end
        local okRead, current, hasParent = pcall(function()
            return rootPart.CFrame, rootPart.Parent ~= nil
        end)
        if not okRead or not hasParent or typeof(current) ~= "CFrame" then
            self._cframe = nil
            self._oldCFrame = nil
            self._rootPart = nil
            return false
        end
        local delta = (cf.Position - current.Position).Magnitude
        if delta ~= delta or delta == math.huge or delta > MAX_UPDATE_DISTANCE then
            self._cframe = nil
            self._oldCFrame = current
            return false
        end
        self._oldCFrame = current
        local okWrite = pcall(function() rootPart.CFrame = cf end)
        if not okWrite then
            self._cframe = nil
            local parentOk, hasParentAfter = pcall(function() return rootPart.Parent ~= nil end)
            if not parentOk or not hasParentAfter then
                self._rootPart = nil
                self._oldCFrame = nil
            end
            return false
        end
        pcall(function()
            local linear = rootPart.AssemblyLinearVelocity
            local angular = rootPart.AssemblyAngularVelocity
            if typeof(linear) ~= "Vector3" or linear.Magnitude > 250 then
                rootPart.AssemblyLinearVelocity = Vector3.zero
            end
            if typeof(angular) ~= "Vector3" or angular.Magnitude > 250 then
                rootPart.AssemblyAngularVelocity = Vector3.zero
            end
        end)
        return true
    end

    function RootDesync:Destroy()
        local rootPart = self._rootPart
        local restoreCFrame = self._oldCFrame
        pcall(function() RunService:UnbindFromRenderStep(self._boundId) end)
        if rootPart ~= nil and restoreCFrame ~= nil then
            pcall(function()
                if rootPart.Parent ~= nil then rootPart.CFrame = restoreCFrame end
            end)
        end
        self._rootPart = nil
        self._oldCFrame = nil
        self._cframe = nil
    end

    local function getCharacter() return lp.Character end
    local function getHumanoid(char) return char and char:FindFirstChildOfClass("Humanoid") or nil end
    local function getRoot(char) return char and char:FindFirstChild("HumanoidRootPart") or nil end

    local function rigStable(char)
        if not char or char.Parent ~= Workspace then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or hum.Health <= 0 or not root then return false end
        local rootJoint = char:FindFirstChild("RootJoint", true) or char:FindFirstChild("Root", true)
        if rootJoint and rootJoint:IsA("Motor6D") then
            if rootJoint.Part0 == nil or rootJoint.Part1 == nil
                or typeof(rootJoint.C0) ~= "CFrame" or typeof(rootJoint.C1) ~= "CFrame" then
                return false
            end
        else
            local waist = char:FindFirstChild("Waist", true)
            if waist and waist:IsA("Motor6D") then
                if waist.Part0 == nil or waist.Part1 == nil
                    or typeof(waist.C0) ~= "CFrame" or typeof(waist.C1) ~= "CFrame" then
                    return false
                end
            end
        end
        local neck = char:FindFirstChild("Neck", true)
        if neck and neck:IsA("Motor6D") then
            if neck.Part0 == nil or neck.Part1 == nil
                or typeof(neck.C0) ~= "CFrame" or typeof(neck.C1) ~= "CFrame" then
                return false
            end
        end
        return true
    end

    local function getClientCFrame(root)
        local localChar = getCharacter()
        local localRoot = getRoot(localChar)
        if root ~= nil and root == localRoot and root.Parent
            and typeof(lastClientCFrame) == "CFrame" then
            return lastClientCFrame
        end
        local fallback = root and root.Parent and root.CFrame or nil
        if typeof(fallback) == "CFrame" then return fallback end
        return nil
    end

    local function characterBounds(char)
        if not char or char.Parent == nil then return nil end
        local ok, boxCFrame, boxSize = pcall(function() return char:GetBoundingBox() end)
        if not ok or typeof(boxCFrame) ~= "CFrame" or typeof(boxSize) ~= "Vector3" then return nil end
        local minY, maxY = math.huge, -math.huge
        for x = -1, 1, 2 do
            for y = -1, 1, 2 do
                for z = -1, 1, 2 do
                    local corner = boxCFrame:PointToWorldSpace(Vector3.new(
                        boxSize.X * 0.5 * x,
                        boxSize.Y * 0.5 * y,
                        boxSize.Z * 0.5 * z))
                    minY = math.min(minY, corner.Y)
                    maxY = math.max(maxY, corner.Y)
                end
            end
        end
        if minY == math.huge or maxY == -math.huge then return nil end
        return { boxCFrame, boxSize, minY, maxY }
    end

    local function readEnvironmentId(player, char)
        local value = nil
        pcall(function() if char ~= nil then value = char:GetAttribute("EnvironmentID") end end)
        if value == nil then
            pcall(function() if player ~= nil then value = player:GetAttribute("EnvironmentID") end end)
        end
        return value
    end

    local function environmentKey(part)
        if part == nil then return nil end
        local attr = nil
        pcall(function() attr = part:GetAttribute("EnvironmentID") end)
        if attr ~= nil then return "attr:" .. tostring(attr) end
        if part:IsA("Terrain") then return "terrain" end
        local model = part:FindFirstAncestorOfClass("Model")
        return model or part
    end

    local function sameEnvironment(localPlayer, localChar, localFloorPart, otherPlayer, otherChar, otherFloorPart)
        if localFloorPart == nil or otherFloorPart == nil then return false end
        local localEnv = readEnvironmentId(localPlayer, localChar)
        local otherEnv = readEnvironmentId(otherPlayer, otherChar)
        if localEnv ~= nil and otherEnv ~= nil then return localEnv == otherEnv end
        local localFloorEnv = environmentKey(localFloorPart)
        local otherFloorEnv = environmentKey(otherFloorPart)
        if localFloorEnv ~= nil and otherFloorEnv ~= nil then return localFloorEnv == otherFloorEnv end
        return localFloorPart == otherFloorPart
    end

    local function probeSurface(char, root)
        if not char or char.Parent ~= Workspace or not root or not root.Parent
            or not root:IsDescendantOf(char) then
            return nil
        end
        local clientCF = getClientCFrame(root)
        local pos = clientCF and clientCF.Position or root.Position
        if typeof(pos) ~= "Vector3"
            or pos.X ~= pos.X or pos.Y ~= pos.Y or pos.Z ~= pos.Z then
            return nil
        end
        if math.abs(pos.X) > 100000 or math.abs(pos.Y) > 100000 or math.abs(pos.Z) > 100000 then
            return nil
        end
        local bounds = characterBounds(char)
        if not bounds then return nil end
        local minY, maxY = bounds[3], bounds[4]
        if type(minY) ~= "number" or type(maxY) ~= "number" then return nil end

        local filter = { char }
        for _, player in ipairs(Players:GetPlayers()) do
            local playerCharacter = player.Character
            if playerCharacter ~= nil and playerCharacter ~= char then
                filter[#filter + 1] = playerCharacter
            end
        end
        raycastParams.FilterDescendantsInstances = filter

        local down = Workspace:Raycast(pos + Vector3.new(0, 4, 0), Vector3.new(0, -128, 0), raycastParams)
        local up = Workspace:Raycast(pos + Vector3.new(0, -0.15, 0), Vector3.new(0, 96, 0), raycastParams)

        local downGap, upGap = math.huge, math.huge
        if down and down.Position then downGap = minY - down.Position.Y end
        if up and up.Position then upGap = up.Position.Y - maxY end
        local downValid = down ~= nil and down.Position ~= nil
            and downGap >= -1 and downGap <= DOWN_FLOOR_MAX_GAP
        local upValid = up ~= nil and up.Position ~= nil
            and upGap >= UP_SURFACE_MIN_GAP and upGap <= UP_SURFACE_MAX_GAP

        if upValid and (not downValid or downGap > NEAR_FLOOR_GAP) then
            return { surfaceY = up.Position.Y, surfacePart = up.Instance, surfaceAboveCharacter = true }
        end
        if downValid then
            return { surfaceY = down.Position.Y, surfacePart = down.Instance, surfaceAboveCharacter = false }
        end
        if upValid then
            return { surfaceY = up.Position.Y, surfacePart = up.Instance, surfaceAboveCharacter = true }
        end
        return nil
    end

    local function measureOtherPlayers(localFloorY, localRoot, localFloorPart, localChar)
        if not localFloorY or not localRoot or not localRoot.Parent
            or localFloorPart == nil or localChar == nil then
            otherCount = 0
            otherFloorPart = nil
            cachedOtherDepth = MIN_DEPTH
            cachedOtherCount = 0
            cachedFloorPart = localFloorPart
            cachedLocalPosition = nil
            cachedEnvironmentId = nil
            adaptiveScanAt = os.clock()
            return MIN_DEPTH
        end

        local now = os.clock()
        local localClientCF = getClientCFrame(localRoot)
        local localPos = localClientCF and localClientCF.Position or localRoot.Position
        local localEnv = readEnvironmentId(lp, localChar)

        if cachedFloorPart == localFloorPart
            and cachedLocalPosition ~= nil
            and (cachedLocalPosition - localPos).Magnitude <= CACHE_MOVE_DISTANCE
            and cachedEnvironmentId == localEnv
            and now - adaptiveScanAt < ADAPTIVE_SCAN_INTERVAL then
            otherCount = cachedOtherCount
            otherFloorPart = cachedOtherFloorPart
            return cachedOtherDepth
        end

        local deepest = MIN_DEPTH
        local count = 0
        local deepestFloorPart = nil
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= lp and player.Parent == Players then
                local char = player.Character
                local root = getRoot(char)
                local humanoid = getHumanoid(char)
                if char and root and root.Parent and humanoid and humanoid.Health > 0 then
                    local otherCF = getClientCFrame(root)
                    local otherPos = otherCF and otherCF.Position or root.Position
                    local dx, dz = otherPos.X - localPos.X, otherPos.Z - localPos.Z
                    local horizontalDistance = math.sqrt(dx * dx + dz * dz)
                    if horizontalDistance <= PLAYER_SCAN_RADIUS
                        and math.abs(otherPos.Y - localPos.Y) <= PLAYER_VERTICAL_TOLERANCE then
                        local probe = probeSurface(char, root)
                        if probe and probe.surfaceAboveCharacter == true and probe.surfacePart ~= nil
                            and sameEnvironment(lp, localChar, localFloorPart, player, char, probe.surfacePart) then
                            local bounds = characterBounds(char)
                            local topY = bounds and bounds[4] or nil
                            if topY ~= nil then
                                local depthForOther = probe.surfaceY - topY
                                if depthForOther >= OTHER_THRESHOLD then
                                    count = count + 1
                                    local desired = math.clamp(depthForOther + PLAYER_SEPARATION, MIN_DEPTH, MAX_DEPTH)
                                    if desired > deepest then
                                        deepest = desired
                                        deepestFloorPart = probe.surfacePart
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        otherCount = count
        cachedOtherCount = count
        cachedOtherDepth = deepest
        cachedFloorPart = localFloorPart
        cachedLocalPosition = localPos
        cachedEnvironmentId = localEnv
        adaptiveScanAt = now
        cachedOtherFloorPart = deepestFloorPart or localFloorPart
        return deepest
    end

    local function findFloorY(char, root)
        local isLocalCharacter = char == getCharacter()
        local clientCF = root and getClientCFrame(root) or nil
        local position = clientCF and clientCF.Position or (root and root.Position)
        local now = os.clock()
        if isLocalCharacter and typeof(position) == "Vector3"
            and localSurfaceCache.ready
            and localSurfaceCache.character == char
            and localSurfaceCache.root == root
            and typeof(localSurfaceCache.position) == "Vector3"
            and (position - localSurfaceCache.position).Magnitude <= 2.5
            and now - localSurfaceCache.at < 0.1 then
            local cachedProbe = localSurfaceCache.probe
            if not cachedProbe then return nil, nil, false end
            return cachedProbe.surfaceY, cachedProbe.surfacePart, cachedProbe.surfaceAboveCharacter == true
        end
        local probe = probeSurface(char, root)
        if isLocalCharacter and typeof(position) == "Vector3" then
            localSurfaceCache.ready = true
            localSurfaceCache.character = char
            localSurfaceCache.root = root
            localSurfaceCache.position = position
            localSurfaceCache.at = now
            localSurfaceCache.probe = probe
        end
        if not probe then return nil, nil, false end
        return probe.surfaceY, probe.surfacePart, probe.surfaceAboveCharacter == true
    end

    local function captureSnapshot(char, root, humanoid)
        snapshot = {
            character = char,
            rootCFrame = root.CFrame,
            rootVelocity = root.AssemblyLinearVelocity,
            rootAngularVelocity = root.AssemblyAngularVelocity,
            humanoidState = humanoid and humanoid:GetState() or nil,
            humanoidAutoRotate = humanoid and humanoid.AutoRotate or nil,
        }
        lastServerCFrame = nil
        snapshotCharacter = char
    end

    local function restore(preferredClientCFrame)
        local snap = snapshot
        local char = getCharacter()
        local cachedCF = typeof(preferredClientCFrame) == "CFrame" and preferredClientCFrame or lastClientCFrame
        local liveCF = nil
        if desync then
            pcall(function() liveCF = desync:GetClientCFrame() end)
            pcall(function() desync:Destroy() end)
            desync = nil
        end
        lastServerCFrame = nil
        if not snap or char ~= snap.character then
            snapshot = nil
            snapshotCharacter = nil
            return
        end
        local root = getRoot(char)
        local humanoid = getHumanoid(char)
        if root then
            pcall(function()
                root.CFrame = liveCF or cachedCF or snap.rootCFrame
                local rv, ra = snap.rootVelocity, snap.rootAngularVelocity
                if typeof(rv) ~= "Vector3" or rv.Magnitude > 250 then rv = Vector3.zero end
                if typeof(ra) ~= "Vector3" or ra.Magnitude > 250 then ra = Vector3.zero end
                root.AssemblyLinearVelocity = rv
                root.AssemblyAngularVelocity = ra
            end)
        end
        if humanoid then
            pcall(function()
                if snap.humanoidAutoRotate ~= nil then humanoid.AutoRotate = snap.humanoidAutoRotate end
                if snap.humanoidState then humanoid:ChangeState(snap.humanoidState) end
            end)
        end
        snapshot = nil
        snapshotCharacter = nil
    end

    local function computeServerCFrame(char, root)
        local surfaceY, surfacePart = findFloorY(char, root)
        if surfaceY == nil or surfacePart == nil then return nil end
        local currentRoot = getClientCFrame(root)
        if not currentRoot then return nil end
        local bounds = characterBounds(char)
        if not bounds then return nil end
        local boxCFrame, boxSize = bounds[1], bounds[2]
        local localCorners = {}
        for x = -1, 1, 2 do
            for y = -1, 1, 2 do
                for z = -1, 1, 2 do
                    local corner = boxCFrame:PointToWorldSpace(Vector3.new(
                        boxSize.X * 0.5 * x, boxSize.Y * 0.5 * y, boxSize.Z * 0.5 * z))
                    localCorners[#localCorners + 1] = currentRoot:PointToObjectSpace(corner)
                end
            end
        end
        local pitch, yaw, roll = currentRoot:ToOrientation()
        local desiredRotation = CFrame.fromOrientation(pitch, yaw, roll)
        local highestTransformedY = -math.huge
        for _, localPoint in ipairs(localCorners) do
            local transformed = desiredRotation:VectorToWorldSpace(localPoint)
            highestTransformedY = math.max(highestTransformedY, transformed.Y)
        end
        if highestTransformedY == -math.huge then return nil end

        local characterHeight = tonumber(boxSize.Y) or 5.5
        local environmentDepth = math.clamp(characterHeight * 0.12 + SELF_BUFFER, MIN_DEPTH, 3.5)
        local otherPlayerDepth = measureOtherPlayers(surfaceY, root, surfacePart, char)
        local targetDepth = math.clamp(math.max(environmentDepth, otherPlayerDepth), MIN_DEPTH, MAX_DEPTH)
        local now = os.clock()
        local previousDepth = tonumber(adaptiveDepth) or MIN_DEPTH
        local lastUpdate = tonumber(adaptiveDepthUpdatedAt) or 0
        local elapsed = lastUpdate > 0 and math.clamp(now - lastUpdate, 0, 0.25) or (1 / 60)
        local riseRate, fallRate = 8, 4
        if targetDepth > previousDepth then
            previousDepth = math.min(targetDepth, previousDepth + riseRate * elapsed)
        else
            local releaseDepth = otherCount > 0 and targetDepth or environmentDepth
            previousDepth = math.max(releaseDepth, previousDepth - fallRate * elapsed)
        end
        adaptiveDepth = math.clamp(previousDepth, MIN_DEPTH, MAX_DEPTH)
        currentDepth = adaptiveDepth
        adaptiveDepthUpdatedAt = now

        local targetRootY = surfaceY - adaptiveDepth - highestTransformedY
        if targetRootY ~= targetRootY or math.abs(targetRootY) > 100000 then return nil end
        local result = CFrame.new(currentRoot.Position.X, targetRootY, currentRoot.Position.Z) * desiredRotation
        if lastServerCFrame ~= nil then
            local shift = (result.Position - lastServerCFrame.Position).Magnitude
            if shift > MAX_UPDATE_DISTANCE then return nil end
        end
        return result
    end

    startUnderground = function()
        if heartbeatConn then return true end
        local char = getCharacter()
        local root = getRoot(char)
        local humanoid = getHumanoid(char)
        if not char or not root or not humanoid or humanoid.Health <= 0 then return false end
        if not rigStable(char) then return false end

        adaptiveDepth = MIN_DEPTH
        currentDepth = MIN_DEPTH
        otherCount = 0
        otherFloorPart = nil
        adaptiveScanAt = 0
        adaptiveDepthUpdatedAt = 0
        cachedOtherDepth = MIN_DEPTH
        cachedOtherCount = 0
        cachedOtherFloorPart = nil
        cachedFloorPart = nil
        cachedLocalPosition = nil
        cachedEnvironmentId = nil
        localSurfaceCache.ready = false

        captureSnapshot(char, root, humanoid)
        lastClientCFrame = root.CFrame
        local initialCF = computeServerCFrame(char, root)
        if initialCF == nil then
            snapshot = nil
            snapshotCharacter = nil
            return false
        end

        lastServerCFrame = initialCF
        enabled = true
        desync = RootDesync.new(root)
        if not desync:SetServerCFrame(initialCF) then
            desync:Destroy()
            desync = nil
            enabled = false
            snapshot = nil
            snapshotCharacter = nil
            return false
        end
        deathConn = humanoid.Died:Connect(function()
            if enabled then stopUnderground() end
        end)

        heartbeatConn = RunService.Heartbeat:Connect(function()
            if not enabled then return end
            local currentChar = getCharacter()
            local currentRoot = getRoot(currentChar)
            local currentHumanoid = getHumanoid(currentChar)
            if not currentChar or not currentRoot or not currentHumanoid or currentHumanoid.Health <= 0 then
                stopUnderground()
                return
            end
            if not rigStable(currentChar) then return end
            if currentChar ~= snapshotCharacter then
                stopUnderground()
                return
            end
            local observedCF = currentRoot.CFrame
            if typeof(observedCF) ~= "CFrame" then return end
            if lastClientCFrame and (observedCF.Position - lastClientCFrame.Position).Magnitude > CLIENT_ESCAPE_DISTANCE then
                lastServerCFrame = nil
                adaptiveScanAt = 0
            end
            lastClientCFrame = observedCF
            if not desync or desync._rootPart ~= currentRoot then
                if desync then pcall(function() desync:Destroy() end) end
                desync = RootDesync.new(currentRoot)
            end
            local serverCF = computeServerCFrame(currentChar, currentRoot)
            if serverCF ~= nil then
                lastServerCFrame = serverCF
                if desync then desync:SetServerCFrame(serverCF) end
            else
                lastServerCFrame = nil
                if desync then
                    desync:SetServerCFrame(nil)
                    desync._oldCFrame = currentRoot.CFrame
                end
            end
            if desync then desync:HeartbeatUpdate() end
        end)
        return true
    end

    stopUnderground = function()
        local preferred = lastClientCFrame
        enabled = false
        adaptiveDepth = MIN_DEPTH
        currentDepth = MIN_DEPTH
        otherCount = 0
        otherFloorPart = nil
        adaptiveScanAt = 0
        adaptiveDepthUpdatedAt = 0
        cachedOtherDepth = MIN_DEPTH
        cachedOtherCount = 0
        cachedOtherFloorPart = nil
        cachedFloorPart = nil
        cachedLocalPosition = nil
        cachedEnvironmentId = nil
        localSurfaceCache.ready = false
        lastServerCFrame = nil
        lastClientCFrame = nil
        if heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn = nil end
        if deathConn then deathConn:Disconnect(); deathConn = nil end
        restore(preferred)
    end

    local requested = false
    local retryActive = false
    local function scheduleStart()
        if not requested or retryActive then return end
        retryActive = true
        task.spawn(function()
            local attempt = 0
            local nextWarnAt = os.clock() + 5
            while requested and heartbeatConn == nil do
                local ok, result = pcall(startUnderground)
                if ok and result == true then break end
                local now = os.clock()
                if now >= nextWarnAt then
                    nextWarnAt = now + 10
                    warn("[Underground] Startup still pending; retrying...")
                end
                attempt = math.min(attempt + 1, 11)
                task.wait(math.min(0.25 + (attempt - 1) * 0.1, 1.25))
            end
            retryActive = false
            if requested and heartbeatConn == nil then scheduleStart() end
        end)
    end

    local respawnConn = nil
    if lp then
        respawnConn = lp.CharacterAdded:Connect(function(newCharacter)
            if not requested then return end
            task.spawn(function()
                if snapshotCharacter ~= nil and snapshotCharacter ~= newCharacter then
                    pcall(stopUnderground)
                end
                task.wait()
                if requested then scheduleStart() end
            end)
        end)
    end

    local controller = {}
    local cleanupFn
    controller.Start = function()
        requested = true
        local ok, result = pcall(startUnderground)
        if ok and result == true then return true end
        scheduleStart()
        return false
    end
    controller.Stop = function()
        requested = false
        return pcall(stopUnderground)
    end
    controller.IsEnabled = function()
        return enabled == true
    end
    controller.Destroy = function()
        requested = false
        pcall(stopUnderground)
        if respawnConn then respawnConn:Disconnect(); respawnConn = nil end
        if rawget(_G, "__CrefyUndergroundController") == controller then
            rawset(_G, "__CrefyUndergroundController", nil)
        end
        if rawget(_G, "__LuaHookUndergroundStandaloneCleanup") == cleanupFn then
            rawset(_G, "__LuaHookUndergroundStandaloneCleanup", nil)
        end
    end
    cleanupFn = function() controller.Destroy() end
    _G.__CrefyUndergroundController = controller
    _G.__LuaHookUndergroundStandaloneCleanup = cleanupFn
    return controller
end)()
runtime.UndergroundController = UndergroundController


local PerfectBlock = {}
do
    local active = false
    local cleaned = false
    local workerGeneration = 0
    local maxDistance = 10000
    local lastEncoded = utf8.char(0) .. utf8.char(0)
    local silentActive = false
    local controller = nil
    local currentLoopConnection = nil
    local loopMode = 'PreSimulation'
    local hookPatches = {}
    local patchedValues = setmetatable({}, { __mode = 'k' })
    local remoteRot = nil
    local cleanFireRot = nil
    local lp = plrs.LocalPlayer
    local statusReason = 'off'
    local statusSince = os.clock()
    local statusNotified = {}

    local function setStatus(reason)
        local now = os.clock()
        if reason ~= statusReason then
            statusReason = reason
            statusSince = now
        end
        if reason == 'off' or statusNotified[reason] then return end
        local minimumDuration = reason == 'active' and 1 or 2.5
        if now - statusSince < minimumDuration then return end
        statusNotified[reason] = true
        pcall(function() Library:Notify({ Title = 'Perfect Block', Description = reason, Time = 3 }) end)
    end

    local function resolveRemote()
        if remoteRot and remoteRot.Parent ~= nil then return true end
        local remotes = repS:FindFirstChild('Remotes')
        local replication = remotes and remotes:FindFirstChild('Replication')
        local fighter = replication and replication:FindFirstChild('Fighter')
        remoteRot = fighter and fighter:FindFirstChild('UpdateCameraRotation') or nil
        return remoteRot ~= nil and remoteRot.Parent ~= nil
    end

    do
        local dummyRemote = Instance.new('RemoteEvent')
        if type(clonefunction) == 'function' then
            local ok, result = pcall(clonefunction, dummyRemote.FireServer)
            if ok and type(result) == 'function' then cleanFireRot = result end
        end
        dummyRemote:Destroy()
        if type(cleanFireRot) ~= 'function' then
            cleanFireRot = function(remote, ...)
                return remote:FireServer(...)
            end
        end
    end

    local function collectGCObjects()
        if type(getgc) ~= 'function' then return nil end
        local ok, objects = pcall(getgc, true)
        if ok and type(objects) == 'table' then return objects end
        return nil
    end

    local function isController(candidate)
        if candidate == nil then return false end
        local okMethod, method = pcall(function() return candidate.GetFighter end)
        return okMethod and type(method) == 'function'
    end

    local function hasLocalFighter(candidate)
        if candidate == nil then return false end
        local ok, fighter = pcall(function() return candidate.LocalFighter end)
        return ok and fighter ~= nil
    end

    local function resolveController(objects)
        if isController(FighterController) then
            controller = FighterController
            return true
        end
        if type(objects) ~= 'table' then objects = collectGCObjects() end
        if type(objects) ~= 'table' then return false end
        for _, object in ipairs(objects) do
            if type(object) == 'table' then
                local hasObjects = rawget(object, 'Objects') ~= nil
                local okObjects, objectsValue = pcall(function() return object.Objects end)
                if hasObjects or (okObjects and objectsValue ~= nil) then
                    if isController(object) then
                        controller = object
                        return true
                    end
                end
            end
        end
        return false
    end

    local function getCameraRotation(fighter)
        if fighter == nil then return nil end
        local okRotation, rotation = pcall(function() return fighter.CameraRotation end)
        if okRotation and typeof(rotation) == 'Vector2' then return rotation end
        local okMethod, method = pcall(function() return fighter.GetCameraRotation end)
        if okMethod and type(method) == 'function' then
            local ok, result = pcall(method, fighter)
            if ok and typeof(result) == 'Vector2' then return result end
        end
        local ok, result = pcall(function() return fighter:Get('CameraRotation') end)
        if ok and typeof(result) == 'Vector2' then return result end
        return nil
    end

    local function encodeByte(value)
        if type(value) ~= 'number' or value ~= value
            or value == math.huge or value == -math.huge then
            return utf8.char(0)
        end
        local encoded = math.floor(value % (2 * math.pi) / math.pi / 2 * 256 + 0.5)
        return utf8.char(math.clamp(encoded, 0, 255))
    end

    local function setRawValue(object, key, value)
        if type(object) ~= 'table' then return false end
        local wasReadonly = nil
        if type(isreadonly) == 'function' then
            local ok, state = pcall(isreadonly, object)
            if ok then wasReadonly = state end
        end
        if wasReadonly == true and type(setreadonly) == 'function' then
            pcall(setreadonly, object, false)
        end
        local ok = pcall(rawset, object, key, value)
        if wasReadonly == true and type(setreadonly) == 'function' then
            pcall(setreadonly, object, true)
        end
        return ok
    end

    local function restoreHooks()
        for index = #hookPatches, 1, -1 do
            local patch = hookPatches[index]
            if patch.objectPatched and rawget(patch.object, 'EncodeCameraRotation') == patch.wrapper then
                setRawValue(patch.object, 'EncodeCameraRotation', patch.oldObjectValue)
            end
            if patch.indexPatched and patch.index ~= patch.object
                and rawget(patch.index, 'EncodeCameraRotation') == patch.wrapper then
                setRawValue(patch.index, 'EncodeCameraRotation', patch.oldIndexValue)
            end
        end
        table.clear(hookPatches)
        table.clear(patchedValues)
    end

    local function hasLiveHook()
        for _, patch in ipairs(hookPatches) do
            if (patch.objectPatched and rawget(patch.object, 'EncodeCameraRotation') == patch.wrapper)
                or (patch.indexPatched and patch.index ~= patch.object
                    and rawget(patch.index, 'EncodeCameraRotation') == patch.wrapper) then
                return true
            end
        end
        return false
    end

    local function installEncoderHook(objects)
        if type(debug) ~= 'table' or type(debug.getupvalues) ~= 'function' then return false end
        if type(objects) ~= 'table' then objects = collectGCObjects() end
        if type(objects) ~= 'table' then return false end
        for index = #hookPatches, 1, -1 do
            local patch = hookPatches[index]
            local objectLive = patch.objectPatched and rawget(patch.object, 'EncodeCameraRotation') == patch.wrapper
            local indexLive = patch.indexPatched and patch.index ~= patch.object
                and rawget(patch.index, 'EncodeCameraRotation') == patch.wrapper
            if not objectLive and not indexLive then
                patchedValues[patch.object] = nil
                table.remove(hookPatches, index)
            end
        end
        local installedAny = false
        for _, object in ipairs(objects) do
            if type(object) == 'table' then
                local indexTable = rawget(object, '__index')
                if type(indexTable) == 'table' then
                    local cameraLoop = rawget(indexTable, '_CameraReplicationLoop')
                    if type(cameraLoop) == 'function' then
                        local okUps, upvalues = pcall(debug.getupvalues, cameraLoop)
                        if okUps and type(upvalues) == 'table' then
                            for _, value in pairs(upvalues) do
                                if type(value) == 'table' and not patchedValues[value] then
                                    local okMeta, meta = pcall(getmetatable, value)
                                    local valueIndex = okMeta and type(meta) == 'table' and rawget(meta, '__index') or nil
                                    if type(valueIndex) == 'table' then
                                        local oldObjectValue = rawget(value, 'EncodeCameraRotation')
                                        local oldIndexValue = rawget(valueIndex, 'EncodeCameraRotation')
                                        local original = type(oldObjectValue) == 'function' and oldObjectValue or oldIndexValue
                                        if type(original) == 'function' then
                                            local patch = {
                                                object = value,
                                                index = valueIndex,
                                                oldObjectValue = oldObjectValue,
                                                oldIndexValue = oldIndexValue,
                                                objectPatched = false,
                                                indexPatched = false,
                                            }
                                            patch.wrapper = function(...)
                                                if silentActive and type(lastEncoded) == 'string' and #lastEncoded >= 2 then
                                                    return lastEncoded
                                                end
                                                return original(...)
                                            end
                                            patch.objectPatched = setRawValue(value, 'EncodeCameraRotation', patch.wrapper)
                                            if valueIndex ~= value then
                                                patch.indexPatched = setRawValue(valueIndex, 'EncodeCameraRotation', patch.wrapper)
                                            end
                                            if patch.objectPatched or patch.indexPatched then
                                                hookPatches[#hookPatches + 1] = patch
                                                patchedValues[value] = true
                                                installedAny = true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return installedAny or hasLiveHook()
    end

    local function findTarget()
        if not controller or not lp then return nil end
        local myCharacter = lp.Character
        local myRoot = myCharacter and (myCharacter:FindFirstChild('HumanoidRootPart') or myCharacter.PrimaryPart)
        if not myRoot then return nil end
        local myPosition = myRoot.Position
        local myTeam = lp:GetAttribute('TeamID')
        local myEnvironment = lp:GetAttribute('EnvironmentID')
        local bestPlayer = nil
        local bestDistance = math.huge
        for _, player in ipairs(plrs:GetPlayers()) do
            if player ~= lp and player.Parent == plrs and player:GetAttribute('EnvironmentID') == myEnvironment then
                local sameTeam = myTeam ~= nil and player:GetAttribute('TeamID') == myTeam
                if not sameTeam then
                    local character = player.Character
                    local root = character and (character:FindFirstChild('HumanoidRootPart') or character.PrimaryPart)
                    local humanoid = character and character:FindFirstChildOfClass('Humanoid')
                    if character and root and humanoid and humanoid.Health > 0 then
                        local distance = (root.Position - myPosition).Magnitude
                        if distance <= maxDistance and distance < bestDistance then
                            local okFighter, fighter = pcall(function() return controller:GetFighter(player) end)
                            if okFighter and fighter and getCameraRotation(fighter) then
                                bestDistance = distance
                                bestPlayer = player
                            end
                        end
                    end
                end
            end
        end
        return bestPlayer
    end

    local function update()
        if not active or not runtime.Running then
            silentActive = false
            setStatus('off')
            return
        end
        if not resolveRemote() or type(cleanFireRot) ~= 'function' then
            silentActive = false
            setStatus('UpdateCameraRotation remote unavailable')
            return
        end
        if not isController(controller) or not hasLocalFighter(controller) then
            resolveController()
            if not isController(controller) or not hasLocalFighter(controller) then
                silentActive = false
                setStatus('FighterController or LocalFighter unavailable')
                return
            end
        end
        local player = findTarget()
        if not player or player == lp or player.Parent ~= plrs then
            silentActive = false
            setStatus('no eligible target with a replicated camera rotation')
            return
        end
        local okFighter, fighter = pcall(function() return controller:GetFighter(player) end)
        local rotation = okFighter and fighter and getCameraRotation(fighter) or nil
        if not rotation then
            silentActive = false
            setStatus('target CameraRotation unavailable')
            return
        end
        local maxPitch = math.rad(89.9)
        local pitch = rotation.X
        if pitch > math.pi then pitch = pitch - (2 * math.pi) end
        pitch = math.clamp(pitch, -maxPitch, maxPitch)
        local yaw = rotation.Y % (2 * math.pi)
        lastEncoded = encodeByte(pitch) .. encodeByte(yaw)
        silentActive = true
        pcall(cleanFireRot, remoteRot, lastEncoded, nil)
        if hasLiveHook() then
            setStatus('active')
        else
            setStatus('running without encoder hook')
        end
    end

    local function setupLoop(mode)
        if currentLoopConnection then
            pcall(function() currentLoopConnection:Disconnect() end)
            currentLoopConnection = nil
        end
        loopMode = mode or 'PreSimulation'
        if not active then return true end
        local signal
        if loopMode == 'Heartbeat' then
            signal = runS.Heartbeat
        elseif loopMode == 'RenderStepped' then
            signal = runS.RenderStepped
        else
            signal = runS.PreSimulation or runS.Heartbeat
        end
        if not signal then return false end
        local ok, connection = pcall(function() return signal:Connect(update) end)
        if ok then currentLoopConnection = connection end
        return currentLoopConnection ~= nil
    end

    local function start()
        if cleaned or active then return active end
        active = true
        statusReason = 'starting'
        statusSince = os.clock()
        table.clear(statusNotified)
        workerGeneration = workerGeneration + 1
        local thisGeneration = workerGeneration
        silentActive = false
        resolveRemote()
        local objects = collectGCObjects()
        if objects then
            resolveController(objects)
            installEncoderHook(objects)
        else
            resolveController()
            installEncoderHook()
        end
        if not setupLoop(loopMode) then
            active = false
            silentActive = false
            restoreHooks()
            return false
        end
        task.spawn(function()
            while active and workerGeneration == thisGeneration and runtime.Running and not cleaned do
                if not remoteRot or remoteRot.Parent == nil then resolveRemote() end
                local needsController = not isController(controller)
                local needsHook = not hasLiveHook()
                if needsController or needsHook then
                    local retryObjects = collectGCObjects()
                    if retryObjects then
                        if needsController then resolveController(retryObjects) end
                        if needsHook then installEncoderHook(retryObjects) end
                    end
                end
                task.wait(1)
            end
        end)
        return currentLoopConnection ~= nil
    end

    local function stop()
        active = false
        workerGeneration = workerGeneration + 1
        silentActive = false
        setStatus('off')
        if currentLoopConnection then
            pcall(function() currentLoopConnection:Disconnect() end)
            currentLoopConnection = nil
        end
        restoreHooks()
        return true
    end

    function PerfectBlock.Start()
        return start()
    end

    function PerfectBlock.Stop()
        return stop()
    end

    function PerfectBlock.SetDistance(value)
        if type(value) == 'number' and value == value
            and value ~= math.huge and value ~= -math.huge then
            maxDistance = math.clamp(value, 25, 10000000000)
        end
    end

    function PerfectBlock.SetLoopMode(value)
        if value ~= 'PreSimulation' and value ~= 'RenderStepped' and value ~= 'Heartbeat' then
            value = 'PreSimulation'
        end
        loopMode = value
        if active then setupLoop(loopMode) end
    end

    function PerfectBlock.IsEnabled()
        return active
    end

    local cleanup

    function PerfectBlock.Cleanup()
        if cleaned then return end
        cleaned = true
        stop()
        controller = nil
        remoteRot = nil
        if env.AutoShootPerfectBlockCleanup == cleanup then
            env.AutoShootPerfectBlockCleanup = nil
        end
        if env.__SilentCamera_Cleanup == cleanup then
            env.__SilentCamera_Cleanup = nil
        end
        if env.__SilentCamera_Cleanup_Prev == cleanup then
            env.__SilentCamera_Cleanup_Prev = nil
        end
    end

    cleanup = function() PerfectBlock.Cleanup() end
    env.AutoShootPerfectBlockCleanup = cleanup
    env.__SilentCamera_Cleanup = cleanup
    env.__SilentCamera_Cleanup_Prev = cleanup
end
runtime.PerfectBlock = PerfectBlock

local function cleanupRuntime()
    if runtime.Cleaned then return end
    runtime.Cleaned = true
    runtime.Running = false
    if type(getgenv().Config) == 'table' then
        getgenv().Config.Enabled = false
    end
    if runtime.UndergroundController then
        pcall(function() runtime.UndergroundController.Destroy() end)
        runtime.UndergroundController = nil
    end
    if runtime.PerfectBlock then
        pcall(function() runtime.PerfectBlock.Cleanup() end)
        runtime.PerfectBlock = nil
    end
    for _, connection in ipairs(runtime.Connections or {}) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(runtime.Connections)
    runtime.Library = nil
end

Library:OnUnload(cleanupRuntime)

local Window = Library:CreateWindow({
    Title = 'Auto Shoot',
    Footer = 'Auto Shoot | Underground | Perfect Block',
    Icon = 95816097006870,
    NotifySide = 'Right',
    ShowCustomCursor = true,
    Center = true,
    AutoShow = true,
    Resizable = true,
    Size = UDim2.fromOffset(700, 600),
    Minimizable = true,
    MinimizeKeybind = Enum.KeyCode.RightBracket,
    MobileButtonsSide = 'Right',
    ShowMobileButtons = true,
    AlwaysOnTop = false
})

local Tabs = {
    Main = Window:AddTab('Main', 'crosshair'),
    ['UI Settings'] = Window:AddTab('UI Settings', 'settings')
}

local LeftGroupBox = Tabs.Main:AddGroupbox({
    Side = 'Left',
    Name = 'Combat Settings',
    IconName = 'crosshair'
})

local PerfectBlockGroupBox = Tabs.Main:AddGroupbox({
    Side = 'Right',
    Name = 'Perfect Block',
    IconName = 'shield'
})

LeftGroupBox:AddToggle('EnabledToggle', {
    Text = 'Enable Auto Shoot',
    Default = getgenv().Config.Enabled == true,
    Tooltip = 'Toggles the existing Auto Shoot logic',
    Callback = function(Value)
        if runtime.Running and type(getgenv().Config) == 'table' then
            getgenv().Config.Enabled = Value == true
        end
    end
}):AddKeyPicker('EnabledKeybind', {
    Default = 'F',
    Mode = 'Toggle',
    Text = 'Auto Shoot bind',
    SyncToggleState = true,
    NoUI = false
})

LeftGroupBox:AddToggle('UndergroundToggle', {
    Text = 'Underground',
    Default = false,
    Tooltip = 'Starts or stops the Underground controller',
    Callback = function(Value)
        if not runtime.Running then return end
        if Value then
            UndergroundController.Start()
        else
            UndergroundController.Stop()
        end
    end
}):AddKeyPicker('UndergroundKeybind', {
    Default = 'G',
    Mode = 'Toggle',
    Text = 'Underground bind',
    SyncToggleState = true,
    NoUI = false
})

LeftGroupBox:AddDropdown('WeaponSlotDropdown', {
    Values = { 'Primary', 'Secondary', 'Melee' },
    Default = getgenv().Config.WeaponSlot,
    Multi = false,
    Text = 'Weapon slot',
    Tooltip = 'Select which slot to auto-equip',
    Callback = function(Value)
        if type(getgenv().Config) == 'table' then
            getgenv().Config.WeaponSlot = Value
        end
    end
})

LeftGroupBox:AddSlider('FireRateSlider', {
    Text = 'Fire rate (seconds)',
    Default = getgenv().Config.FireRate,
    Min = 0.01,
    Max = 0.5,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        if type(getgenv().Config) == 'table' then
            getgenv().Config.FireRate = math.clamp(Value, 0.01, 0.5)
        end
    end
})

LeftGroupBox:AddSlider('MaxDistSlider', {
    Text = 'Max distance',
    Default = getgenv().Config.MaxDistance,
    Min = 50,
    Max = 2000,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        if type(getgenv().Config) == 'table' then
            getgenv().Config.MaxDistance = math.clamp(Value, 50, 2000)
        end
    end
})

PerfectBlockGroupBox:AddToggle('PerfectBlockToggle', {
    Text = 'Perfect Block',
    Default = false,
    Tooltip = 'Enables Perfect Block camera replication',
    Callback = function(Value)
        if not runtime.Running then return end
        if Value then
            PerfectBlock.Start()
        else
            PerfectBlock.Stop()
        end
    end
}):AddKeyPicker('PerfectBlockKeybind', {
    Default = 'H',
    Mode = 'Toggle',
    Text = 'Perfect Block bind',
    SyncToggleState = true,
    NoUI = false
})

PerfectBlockGroupBox:AddDropdown('PerfectBlockLoopMode', {
    Text = 'Loop mode',
    Values = { 'PreSimulation', 'RenderStepped', 'Heartbeat' },
    Default = 'PreSimulation',
    Callback = function(Value)
        PerfectBlock.SetLoopMode(Value)
    end
})

PerfectBlockGroupBox:AddSlider('PerfectBlockDistanceSlider', {
    Text = 'Trigger distance',
    Default = 10000,
    Min = 25,
    Max = 10000000000,
    Rounding = 0,
    Suffix = ' studs',
    Callback = function(Value)
        PerfectBlock.SetDistance(Value)
    end
})

local MenuGroup = Tabs['UI Settings']:AddGroupbox({
    Side = 'Left',
    Name = 'Menu',
    IconName = 'wrench'
})

MenuGroup:AddToggle('KeybindMenuOpen', {
    Default = Library.KeybindFrame and Library.KeybindFrame.Visible or false,
    Text = 'Open Keybind Menu',
    Callback = function(Value)
        if Library.KeybindFrame then
            Library.KeybindFrame.Visible = Value
        end
    end
})

MenuGroup:AddToggle('ShowCustomCursor', {
    Text = 'Custom Cursor',
    Default = Library.ShowCustomCursor,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end
})

MenuGroup:AddToggle('AlwaysOnTop', {
    Text = 'Always On Top',
    Default = Window.AlwaysOnTop == true,
    Callback = function(Value)
        Window:SetAlwaysOnTop(Value)
    end
})

MenuGroup:AddDropdown('NotificationSide', {
    Values = { 'Left', 'Right' },
    Default = 'Right',
    Text = 'Notification Side',
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end
})

MenuGroup:AddDropdown('DPIDropdown', {
    Values = { '50%', '75%', '100%', '125%', '150%', '175%', '200%' },
    Default = '100%',
    Text = 'DPI Scale',
    Callback = function(Value)
        local DPI = tonumber(tostring(Value):gsub('%%', ''))
        if DPI then
            Library:SetDPIScale(DPI)
        end
    end
})

MenuGroup:AddSlider('UICornerSlider', {
    Text = 'Corner Radius',
    Default = Library.CornerRadius or 4,
    Min = 0,
    Max = 20,
    Rounding = 0,
    Callback = function(Value)
        Window:SetCornerRadius(Value)
    end
})

MenuGroup:AddDivider()
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = 'Menu keybind'
})

MenuGroup:AddButton('Unload', function()
    Library:Unload()
end)

local Utilities = Tabs['UI Settings']:AddGroupbox({
    Side = 'Right',
    Name = 'Library Utilities',
    IconName = 'wrench'
})

Utilities:AddSection('Keybinds')
Utilities:AddDropdown('UtilKeybindMode', {
    Text = 'Keybind mode',
    Values = { 'All', 'Toggle', 'Hold', 'Always' },
    Default = Library.KeybindMode or 'All',
    Callback = function(Value)
        if Library.SetKeybindMode then
            Library:SetKeybindMode(Value)
        end
    end
})

Utilities:AddButton('Refresh Keybinds', function()
    if Library.RefreshKeybinds then
        Library:RefreshKeybinds()
    end
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('CreU')
SaveManager:SetFolder('CreU/AutoShoot')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
