repeat task.wait() until game:IsLoaded()

local IsSupported = true
if not setfflag or not hookfunction or not getrenv or not newcclosure or not islclosure or not getconnections or not debug.getupvalues or not getgc or not setthreadidentity or not getthreadidentity then
    IsSupported = false
end

local ENXUI = {
    Version = '1.5'
};

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Players = cloneref(game:GetService("Players"))
local Stats = cloneref(game:GetService("Stats"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local TweenService = cloneref(game:GetService("TweenService"))
local CollectionService = cloneref(game:GetService("CollectionService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Workspace = cloneref(game:GetService("Workspace"))
local TextService = cloneref(game:GetService('TextService'));
local Debris = cloneref(game:GetService("Debris"))
local HttpService = cloneref(game:GetService("HttpService"))

local _PARRY_PATCH = { ready = true }

local function findToken()
    for _, Function in getgc(true) do
        if type(Function) ~= 'function' then continue end
        local okSrc, src = pcall(function()
            return debug.info(Function, 's')
        end)
        if okSrc and src and tostring(src):find('PRY', 1, true) then
            local okUps, ups = pcall(function()
                return debug.getupvalues(Function)
            end)
            if okUps and type(ups) == 'table' then
                for _, value in ups do
                    if type(value) == 'function' then
                        return value
                    end
                end
            end
        end
    end
    return nil
end

local _token

task.spawn(function()
    local tries = 0
    while not _token and tries < 30 do
        tries += 1
        task.wait(1)
        local ZC = getgenv()._ENX_ZC
        if ZC then
            if ZC.ready and ZC.tokenFn then
                _token = ZC.tokenFn
                break
            end
            if ZC.pryFn then
                _token = ZC.pryFn
                break
            end
        end
    end
end)

function _tokenize(_remote_uid)
    local time = tostring(math.floor(workspace:GetServerTimeNow() * 100))
    local key = _token(_remote_uid, 'TIME')
    local characters = table.create(#time)
    for index = 1, #time do
        characters[index] = string.char(bit32.bxor(
            (string.byte(time, index) + index) % 256,
            string.byte(key, (index - 1) % #key + 1)
        ))
    end
    return table.concat(characters)
end

local _reverted = {}
local _original = {}
local _captured = nil

function _is_valid(args)
    return #args == 8 and type(args[2]) == "string" and type(args[3]) == "string"
        and type(args[4]) == "number" and typeof(args[5]) == "CFrame"
        and type(args[6]) == "table" and type(args[7]) == "table"
        and type(args[8]) == "boolean"
end

_PARRY_PATCH.wrapped = setmetatable({}, { __mode = "k" })

function _hook(remote)
    if not _reverted[remote] then
        if not _original[getrawmetatable(remote)] then
            _original[getrawmetatable(remote)] = true
            local _meta = getrawmetatable(remote)
            setreadonly(_meta, false)
            local _old = _meta.__index
            _meta.__index = function(self, key)
                if (key == 'FireServer' and self:IsA('RemoteEvent'))
                or (key == 'InvokeServer' and self:IsA('RemoteFunction')) then
                    local _cachedWrap = _PARRY_PATCH.wrapped[self]
                    if _cachedWrap then
                        return _cachedWrap
                    end
                    local _wrap = function(_, ...)
                        if not _reverted[self] then
                            local _arguments = { ... }
                            if _is_valid(_arguments) then
                                _reverted[self] = _arguments
                                _captured = { remote = self, args = _arguments }
                            end
                            return _old(self, key)(_, unpack(_arguments))
                        end
                        return _old(self, key)(self, ...)
                    end
                    _PARRY_PATCH.wrapped[self] = _wrap
                    return _wrap
                end
                return _old(self, key)
            end
            setreadonly(_meta, true)
        end
    end
end

for _iterator, _remote in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
    if _remote:IsA('RemoteEvent') or _remote:IsA('RemoteFunction') then
        _hook(_remote)
    end
end

local _ZC = {
    ready = false,
    remote = nil,
    hash = nil,
    key = nil,
    num = nil,
    tokenFn = nil,
    pryFn = nil,
    tries = 0,
    lastRescan = 0,
}

local _zc_scanning = false
local _zc_netFolder = nil
local _zc_netLit = {}
local _zc_pryFallback = nil
local _zc_hash, _zc_key, _zc_num, _zc_tokenFn

local function _zc_resolve_net()
    if _zc_netFolder and _zc_netFolder.Parent then return _zc_netFolder end
    local ok, f = pcall(function()
        return ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net
    end)
    if ok then _zc_netFolder = f end
    return _zc_netFolder
end

local function _zc_finalize()
    if not (_ZC.hash and _ZC.key and _ZC.tokenFn) then return false end
    local netFolder = _zc_resolve_net()
    if not netFolder then return false end
    for _, r in ipairs(netFolder:GetDescendants()) do
        if r:IsA("RemoteEvent") and not _zc_netLit[r] then
            if r.Name:sub(1, 3) == "RE/"
                and #r.Name >= 32
                and select(2, r.Name:gsub("[/`:<;_=?>]", "")) >= 3 then
                _ZC.remote = r
                _ZC.ready = true
                return true
            end
        end
    end
    return false
end

local function _zc_process_obj(obj, netFolder, netLit)
    local tobj = type(obj)
    if tobj == "table" then
        for _, v in pairs(obj) do
            if typeof(v) == "Instance" and v:IsA("RemoteEvent") and netFolder then
                local okNet, isNet = pcall(v.IsDescendantOf, v, netFolder)
                if okNet and isNet then netLit[v] = true end
            end
        end
    elseif tobj == "function" then
        local okSrc, src = pcall(debug.info, obj, 's')
        if okSrc and src then
            local s = tostring(src)
            if s:find('SwordsController', 1, true) and s:find('PRY', 1, true) then
                local okUps, ups = pcall(debug.getupvalues, obj)
                if okUps and type(ups) == 'table' then
                    if not _zc_pryFallback then
                        for _, value in ups do
                            if type(value) == 'function' then
                                _zc_pryFallback = value
                                break
                            end
                        end
                    end
                    local withKey = ups[3]
                    if type(withKey) == 'table' and type(withKey[1]) == 'table' and type(ups[8]) == 'string' then
                        _zc_hash = ups[8]
                        _zc_key = withKey[2]
                        _zc_num = withKey[1][withKey[3]]
                        _zc_tokenFn = ups[4]
                    end
                end
            elseif not _zc_pryFallback and s:find('PRY', 1, true) then
                local okUps, ups = pcall(debug.getupvalues, obj)
                if okUps and type(ups) == 'table' then
                    for _, value in ups do
                        if type(value) == 'function' then
                            _zc_pryFallback = value
                            break
                        end
                    end
                end
            end
        end
    end
end

local function _zc_adopt()
    if _ZC.tokenFn and not _ZC.pryFn then _ZC.pryFn = _ZC.tokenFn end
    if _zc_pryFallback then
        _ZC.pryFn = _ZC.pryFn or _zc_pryFallback
        if not _token then _token = _zc_pryFallback end
    end
    if _ZC.ready and not _token then _token = _ZC.tokenFn end
end

local function _zc_scan_sync()
    if _ZC.ready or _zc_scanning then return end
    if not (getgc and debug and debug.getupvalues and debug.info) then return end
    _zc_scanning = true
    local ok, err = pcall(function()
        local netFolder = _zc_resolve_net()
        if not netFolder then return end
        local netLit = {}
        _zc_netLit = netLit
        _zc_hash, _zc_key, _zc_num, _zc_tokenFn = nil, nil, nil, nil
        for _, obj in getgc(true) do
            _zc_process_obj(obj, netFolder, netLit)
        end
        if _zc_hash and _zc_key and _zc_tokenFn then
            _ZC.hash = _zc_hash
            _ZC.key = _zc_key
            _ZC.num = _zc_num
            _ZC.tokenFn = _zc_tokenFn
        end
        _zc_finalize()
    end)
    _zc_adopt()
    _zc_scanning = false
    if not ok then
    end
end

local function _zc_scan()
    if _ZC.ready or _zc_scanning then return end
    if not (getgc and debug and debug.getupvalues and debug.info) then return end
    _zc_scanning = true
    task.spawn(function()
        local ok, err = pcall(function()
            local okArr, arr = pcall(getgc, true)
            if not okArr or type(arr) ~= "table" then return end
            local n = #arr
            if n == 0 and next(arr) ~= nil then
                local list = {}
                for _, obj in arr do list[#list + 1] = obj end
                arr = list
                n = #arr
            end
            local netFolder = _zc_resolve_net()
            local netLit = {}
            _zc_netLit = netLit
            _zc_hash, _zc_key, _zc_num, _zc_tokenFn = nil, nil, nil, nil
            local i = 1
            local sliceStart = os.clock()
            while i <= n and not _ZC.ready do
                pcall(_zc_process_obj, arr[i], netFolder, netLit)
                i += 1
                if os.clock() - sliceStart >= 0.003 then
                    task.wait()
                    sliceStart = os.clock()
                end
            end
            if not _ZC.ready then
                if _zc_hash and _zc_key and _zc_tokenFn then
                    _ZC.hash = _zc_hash
                    _ZC.key = _zc_key
                    _ZC.num = _zc_num
                    _ZC.tokenFn = _zc_tokenFn
                end
                _zc_finalize()
            end
        end)
        _zc_adopt()
        _zc_scanning = false
        if not ok then
        end
    end)
end

pcall(_zc_scan_sync)

local function _zc_tokenize(uid)
    local ok, token = pcall(function()
        local t = tostring(math.floor(workspace:GetServerTimeNow() * 100))
        local key = _ZC.tokenFn(uid, 'TIME')
        local characters = table.create(#t)
        for index = 1, #t do
            characters[index] = string.char(bit32.bxor(
                (string.byte(t, index) + index) % 256,
                string.byte(key, (index - 1) % #key + 1)
            ))
        end
        return table.concat(characters)
    end)
    if ok and type(token) == 'string' then return token end
    return nil
end

local _zc_tokWindow, _zc_tokNum, _zc_tokKey = -1, nil, nil
local _zc_tokCheck = 0
local _zc_noPos, _zc_noMouse = {}, {}

function _ZC.fire(curveCFrame, screenPositions, mouseLocation, isSpam, forceFreshToken)
    if not _ZC.ready then return false end
    local remote = _ZC.remote
    if not remote or not remote.Parent then
        _ZC.ready = false
        if _ZC.requestRescan then task.spawn(_ZC.requestRescan) end
        return false
    end
    if not curveCFrame then
        local cam = workspace.CurrentCamera
        curveCFrame = cam and cam.CFrame
    end
    if not curveCFrame then return false end
    if forceFreshToken or (os.clock() - _zc_tokCheck) >= 0.005 or not _zc_tokNum then
        _zc_tokCheck = os.clock()
        local now100 = math.floor(workspace:GetServerTimeNow() * 100)
        if now100 ~= _zc_tokWindow then
            _zc_tokWindow = now100
            _zc_tokNum = _zc_tokenize(_ZC.num)
            _zc_tokKey = _zc_tokNum or _zc_tokenize(_ZC.key)
        end
    end
    local token = _zc_tokNum
    if not token then token = _zc_tokKey end
    if not token then return false end
    local ok = pcall(remote.FireServer, remote,
        _ZC.hash,
        _ZC.key,
        token,
        isSpam and 0 or 0.5,
        curveCFrame,
        screenPositions or _zc_noPos,
        mouseLocation or _zc_noMouse,
        false
    )
    return ok
end

getgenv()._ENX_ZC = _ZC

_ZC.requestRescan = function()
    if _ZC.ready then return end
    local now = os.clock()
    if now - (_ZC.lastRescan or 0) < 10 then return end
    _ZC.lastRescan = now
    _zc_scan()
end
task.spawn(function()
    if not (getgc and debug and debug.getupvalues and debug.info) then return end
    local backoff = 1
    while not _ZC.ready and _ZC.tries < 12 do
        _ZC.tries += 1
        pcall(_zc_scan)
        local waited = 0
        while not _ZC.ready and waited < backoff do
            waited += 0.25
            task.wait(0.25)
        end
        if _ZC.ready then break end
        backoff = math.min(backoff * 2, 30)
    end
    if _ZC.ready then
        if not _token then _token = _ZC.tokenFn end
    else
    end
end)

task.wait(1)

local _captureTriggered = false
local function fireParryInput()
    if _captureTriggered then return false end
    _captureTriggered = true
    
    pcall(function()
        local lp = game:GetService("Players").LocalPlayer
        local pg = lp:FindFirstChildOfClass("PlayerGui")
        local hotbar = pg and (pg:FindFirstChild("Hotbar") or pg:WaitForChild("Hotbar", 1))
        local block = hotbar and hotbar:FindFirstChild("Block")
        if block then
            local conns = getconnections(block.Activated)
            for _, conn in ipairs(conns) do
                if conn.Function then
                    local ok, env = pcall(function() return getfenv(conn.Function).script end)
                    if ok and env and tostring(env):find("SwordsController", 1, true) then
                        conn:Fire()
                        return
                    end
                end
            end
            if conns and conns[2] then
                conns[2]:Fire()
            end
        end
    end)
    
    task.delay(1, function()
        _captureTriggered = false
    end)
    return true
end

ReplicatedStorage.ChildAdded:Connect(function(child)
    if child:IsA('RemoteEvent') or child:IsA('RemoteFunction') then
        pcall(function() _hook(child) end)
    end
end)

workspace.ChildAdded:Connect(function(child)
    if child:IsA('RemoteEvent') or child:IsA('RemoteFunction') then
        pcall(function() _hook(child) end)
    end
end)

local _fastSnapshot = {
    cam = nil,
    camCFrame = CFrame.identity,
    viewport = Vector2.new(1, 1),
    positions = {},
    cursor = {0, 0},
    lastRefresh = 0,
}

local function refreshSnapshot(force)
    local now = os.clock()
    if not force and (now - _fastSnapshot.lastRefresh) < 0.033 then
        return
    end
    _fastSnapshot.lastRefresh = now
    local cam = workspace.CurrentCamera
    if not cam then return end
    _fastSnapshot.cam = cam
    _fastSnapshot.camCFrame = cam.CFrame
    _fastSnapshot.viewport = cam.ViewportSize
    local positions = _fastSnapshot.positions
    table.clear(positions)
    _fastSnapshot.closestChar = nil
    local mousePos = UserInputService:GetMouseLocation()
    local _zxsnapcursor = _fastSnapshot.cursor
    _zxsnapcursor[1] = mousePos.X
    _zxsnapcursor[2] = mousePos.Y
    local aliveFolder = workspace:FindFirstChild("Alive")
    if aliveFolder then
        local ray = cam:ScreenPointToRay(mousePos.X, mousePos.Y)
        local pointer = CFrame.lookAt(ray.Origin, ray.Origin + ray.Direction)
        local camPos = cam.CFrame.Position
        local bestDot = -math.huge
        for _, aliveChar in ipairs(aliveFolder:GetChildren()) do
            if aliveChar:IsA("Model") then
                local hrp = aliveChar:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local ok, sp = pcall(cam.WorldToScreenPoint, cam, hrp.Position)
                    if ok then positions[aliveChar.Name] = sp end
                    if aliveChar ~= Players.LocalPlayer.Character then
                        local d = hrp.Position - camPos
                        local mag = d.Magnitude
                        if mag > 0.001 then
                            local dot = pointer.LookVector:Dot(d / mag)
                            if dot > bestDot then
                                bestDot = dot
                                _fastSnapshot.closestChar = aliveChar
                            end
                        end
                    end
                end
            end
        end
    end
    _fastSnapshot.positions = positions
end

_PARRY_PATCH.prySignal = nil
_PARRY_PATCH.pryChecked = 0

function _PARRY_PATCH.resolvePry()
    if _PARRY_PATCH.prySignal then
        return _PARRY_PATCH.prySignal
    end
    local now = os.clock()
    if now - _PARRY_PATCH.pryChecked < 5 then
        return nil
    end
    _PARRY_PATCH.pryChecked = now
    local ok, resolved = pcall(function()
        local controllers = ReplicatedStorage:FindFirstChild("Controllers")
        if not controllers then
            return nil
        end
        for _, controller in ipairs(controllers:GetChildren()) do
            if controller.Name:find("SwordsController", 1, true) == 1 then
                local pry = controller:FindFirstChild("PRY")
                if pry then
                    local okReq, pryFn = pcall(require, pry)
                    if okReq and type(pryFn) == "function" then
                        local packages = ReplicatedStorage:FindFirstChild("Packages")
                        local signalModule = packages and packages:FindFirstChild("Signal")
                        if signalModule then
                            local okSig, signalLib = pcall(require, signalModule)
                            if okSig and type(signalLib) == "table" and type(signalLib.new) == "function" then
                                local signal = signalLib.new()
                                signal:Connect(pryFn)
                                return signal
                            end
                        end
                        return {
                            Fire = function(_, ...)
                                return pryFn(...)
                            end,
                        }
                    end
                end
            end
        end
        return nil
    end)
    if ok and resolved then
        _PARRY_PATCH.prySignal = resolved
        return resolved
    end
    return nil
end

function _PARRY_PATCH.firePry(curveCFrame, screenPositions, mouseLocation)
    local signal = _PARRY_PATCH.resolvePry()
    if not signal then
        return false
    end
    if not curveCFrame then
        local cam = workspace.CurrentCamera
        curveCFrame = cam and cam.CFrame
    end
    if not curveCFrame then
        return false
    end
    if not screenPositions or not mouseLocation then
        refreshSnapshot(true)
        screenPositions = screenPositions or _fastSnapshot.positions
        mouseLocation = mouseLocation or _fastSnapshot.cursor
    end
    return pcall(function()
        signal:Fire(0.5, curveCFrame, screenPositions, mouseLocation, false)
    end)
end

local function fireCoreParry(isSpam, curveCFrame)
    if _PARRY_PATCH.firePry(curveCFrame, nil, nil) then
        return true
    end
    if _ZC.ready then
        refreshSnapshot(false)
        local snap = _fastSnapshot
        if _ZC.fire(curveCFrame or snap.camCFrame, snap.positions, snap.cursor, isSpam) then
            return true
        end
    end
    if not _token or not _reverted or next(_reverted) == nil then
        fireParryInput()
        return false
    end

    refreshSnapshot(false)
    local snap = _fastSnapshot
    local camCFrame = curveCFrame or snap.camCFrame
    local positions = snap.positions
    local cursor = snap.cursor

    local fired = false
    for _remote, _originalArgs in pairs(_reverted) do
        if type(_originalArgs) == "table" and _originalArgs[1] ~= nil then
            local okFire = pcall(function()
                _remote:FireServer(
                    _originalArgs[1],
                    _originalArgs[2],
                    _tokenize(_originalArgs[2]),
                    isSpam and 0 or 0.5,
                    camCFrame,
                    positions,
                    cursor,
                    false
                )
            end)
            if okFire then fired = true end
        end
    end
    return fired
end

local function fireOnce(curveCFrame)
    return fireCoreParry(false, curveCFrame)
end
getgenv()._ENX_fireOnce = fireOnce
getgenv()._ENX_AZURE_PF = function()
    local _azcf = nil
    pcall(function()
        local _azsys = getgenv()._ENX_System
        if _azsys and _azsys.curve and _azsys.curve.get_cframe then
            _azcf = _azsys.curve.get_cframe()
        end
    end)
    return fireCoreParry(false, _azcf)
end
_AZURE_PF = getgenv()._ENX_AZURE_PF

local function fireSpam()
    local _spcf = nil
    pcall(function()
        local _spsys = getgenv()._ENX_System
        if _spsys and _spsys.curve and _spsys.curve.get_cframe then
            _spcf = _spsys.curve.get_cframe()
        end
    end)
    return fireCoreParry(true, _spcf)
end
getgenv()._ENX_fireSpam = fireSpam

local LocalPlayer = Players.LocalPlayer
local Alive = Workspace:FindFirstChild("Alive")
local Runtime = Workspace:FindFirstChild("Runtime")
local function _resolveAlive()
    if not Alive or not Alive.Parent then
        Alive = Workspace:FindFirstChild("Alive")
    end
    return Alive
end
local function _resolveRuntime()
    if not Runtime or not Runtime.Parent then
        Runtime = Workspace:FindFirstChild("Runtime")
    end
    return Runtime
end

task.spawn(function()
    while true do
        Alive = _resolveAlive()
        Runtime = _resolveRuntime()
        task.wait(1)
    end
end)

_PARRY_PATCH.resolve = _PARRY_PATCH.resolve or function() return _token ~= nil or _ZC.ready end
_PARRY_PATCH.ready = true

function _PARRY_PATCH.fire(curveCFrame, screenPositions, mouseLocation, isSpam, forceFreshToken)
    if _PARRY_PATCH.firePry(curveCFrame, screenPositions, mouseLocation) then
        if getgenv().AutoParryAnimationFix then
            getgenv()._ZX_AnimationFixPF()
        end
        return true
    end
    if _ZC.fire(curveCFrame, screenPositions, mouseLocation, isSpam, forceFreshToken) then
        if getgenv().AutoParryAnimationFix then
            getgenv()._ZX_AnimationFixPF()
        end
        return true
    end
    if not _token or not _reverted or next(_reverted) == nil then
        fireParryInput()
        return false
    end
    if not curveCFrame then
        local cam = workspace.CurrentCamera
        curveCFrame = cam and cam.CFrame
    end
    if not curveCFrame then return false end
    if not screenPositions or not mouseLocation then
        refreshSnapshot(true)
        screenPositions = screenPositions or _fastSnapshot.positions
        mouseLocation = mouseLocation or _fastSnapshot.cursor
    end
    local fired = false
    for _remote, _originalArgs in pairs(_reverted) do
        if type(_originalArgs) == "table" and _originalArgs[1] ~= nil then
            local okFire = pcall(function()
                _remote:FireServer(
                    _originalArgs[1],
                    _originalArgs[2],
                    _tokenize(_originalArgs[2]),
                    isSpam and 0 or 0.5,
                    curveCFrame,
                    screenPositions,
                    mouseLocation,
                    false
                )
            end)
            if okFire then fired = true end
        end
    end
    if fired and getgenv().AutoParryAnimationFix then
        getgenv()._ZX_AnimationFixPF()
    end
    return fired
end

getgenv()._ENX_System = nil

local System = {
    __properties = {
        __autoparry_enabled = false,
        __triggerbot_enabled = false,
        __manual_spam_enabled = false,
        __auto_spam_enabled = false,
        __curve_mode = 1,
        __accuracy = 100,
        __divisor_multiplier = 0.75 + ((1 + (100 - 1) * (79 / 99)) - 1) * (3 / 99),
        __parried = false,
        __training_parried = false,
        __spam_threshold = 1,
        __parries = 0,
        __parries_last = 0,
        __parry_key = nil,
        __grab_animation = nil,
        __play_animation = false,
        __tornado_time = tick(),
        __first_parry_done = false,
        __connections = {},
        __reverted_remotes = {},
        __spam_accumulator = 0,
        __spam_rate = (79+921),
        __infinity_active = false,
        __deathslash_active = false,
        __timehole_active = false,
        __slashesoffury_active = false,
        __forcefield_active = false,
        __slashesoffury_count = 0,
        __humanizer_enabled = false,
        __humanizer_min_accuracy = 21,
        __humanizer_middle_accuracy = 52,
        __humanizer_max_accuracy = 100,
        __humanizer_last_update = 0,
        __humanizer_next_change = 0.8,
        __is_mobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled,
        __mobile_guis = {}
    },
    __config = {
        __curve_names = {'Camera', 'Random', 'Accelerated', 'Backwards', 'Slow', 'High', 'Left', 'Right', 'Straight', 'RandomTarget', 'Forward', 'Up', 'Down'},
        __detections = {
            __infinity = false,
            __deathslash = false,
            __timehole = false,
            __slashesoffury = false,
            __phantom = false,
            __forcefield = false,
            __dribble = false,
            __pull = false,
        }
    },
    __triggerbot = {
        __enabled = false,
        __is_parrying = false
    }
}

local revertedRemotes = {}
local Parry_Key = nil
local SC = nil

do
local _Anim = {
    SwordAPI = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SwordAPI"),
    lastPlayed = 0,
    bypassCd = false,
    delay = 1,
    cache = {},
    grabTrack = nil,
}

local function _GetCharacter() return LocalPlayer.Character end
local function _GetHumanoid()
    local char = _GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end
local function _StopAnim(track)
    pcall(function() track:Stop(track:GetAttribute("StopFadeTime") or 0.1) end)
end
local function _PlayGrabAnim(track)
    pcall(function()
        track:Play(track:GetAttribute("PlayFadeTime") or 0,
                   track:GetAttribute("PlayWeight") or 1,
                   track:GetAttribute("PlaySpeed") or 1)
    end)
end
local function _GetParryAnimation()
    local char = _GetCharacter()
    if not char then return nil end
    local currentSword = char:GetAttribute("CurrentlyEquippedSword")
    if not currentSword then
        return _Anim.SwordAPI.Collection.Default:FindFirstChild("GrabParry")
    end
    if _Anim.cache[currentSword] then return _Anim.cache[currentSword] end
    local ok, swordData = pcall(function()
        return ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(currentSword)
    end)
    if not ok or type(swordData) ~= "table" then
        _Anim.cache[currentSword] = _Anim.SwordAPI.Collection.Default:FindFirstChild("GrabParry")
        return _Anim.cache[currentSword]
    end
    for _, obj in pairs(_Anim.SwordAPI.Collection:GetChildren()) do
        if obj.Name == swordData.AnimationType then
            local anim = obj:FindFirstChild("GrabParry") or obj:FindFirstChild("Grab")
            if anim then
                _Anim.cache[currentSword] = anim
                return anim
            end
        end
    end
    _Anim.cache[currentSword] = _Anim.SwordAPI.Collection.Default:FindFirstChild("GrabParry")
    return _Anim.cache[currentSword]
end
local function _PlayParryAnim()
    local humanoid = _GetHumanoid()
    if not humanoid or not humanoid:FindFirstChild("Animator") then return end
    local animator = humanoid.Animator
    local animation = _GetParryAnimation()
    if not animation then return end
    pcall(function()
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            if track.Name == "GrabParry" or track.Name == "Grab" then
                track.TimePosition = 0
                _StopAnim(track)
            elseif track.Name == "SuccessParry" or track.Name == "Success" then
                _StopAnim(track)
            end
        end
    end)
    pcall(function()
        _Anim.grabTrack = animator:LoadAnimation(animation)
        _Anim.grabTrack.Name = "GrabParry"
        _PlayGrabAnim(_Anim.grabTrack)
    end)
end
local function _SpamParryAnim()
    if (os.clock() - _Anim.lastPlayed) >= (_Anim.delay - 0.9) or _Anim.bypassCd then
        _Anim.lastPlayed = os.clock()
        _Anim.bypassCd = false
        _PlayParryAnim()
    end
end
pcall(function()
    ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()
        _Anim.bypassCd = true
        local humanoid = _GetHumanoid()
        if humanoid and humanoid:FindFirstChild("Animator") then
            pcall(function()
                for _, track in pairs(humanoid.Animator:GetPlayingAnimationTracks()) do
                    if track.Name == "GrabParry" or track.Name == "Grab" then
                        _StopAnim(track)
                    end
                end
            end)
        end
    end)
end)

getgenv()._ZX_AnimationFixPF = function()
    _SpamParryAnim()
    local now = os.clock()
    if now - (getgenv()._ZX_AF_LastConn or 0) < 0.1 then return end
    getgenv()._ZX_AF_LastConn = now
    pcall(function()
        local conns = getconnections(game.Players.LocalPlayer.PlayerGui.Hotbar.Block.Activated)
        if conns and conns[2] then conns[2]:Fire() end
    end)
end
end

if ReplicatedStorage:FindFirstChild("Controllers") then
    for _, child in ipairs(ReplicatedStorage.Controllers:GetChildren()) do
        if child.Name:sub(1, (87-71)) == "SwordsController" then
            SC = child
            break
        end
    end
end

local function update_divisor()
        local accuracy = math.clamp(System.__properties.__accuracy or 100, 1, 100)
    local mapped_accuracy = 1 + (accuracy - 1) * (79 / 99)
    System.__properties.__divisor_multiplier = 0.75 + (mapped_accuracy - 1) * (3 / 99)
end

local function update_randomized_accuracy()
if (#"">2) then local _q={} _q[1]=2 end
    if (({})~=nil) and (not System.__properties.__humanizer_enabled) then return end

    local props = System.__properties
    local now = os.clock()

    if now < props.__humanizer_last_update + props.__humanizer_next_change then
        return
    end

    props.__humanizer_last_update = now

    local ping_str = tostring(getgenv()._ZX_PingCache)
    local ping = tonumber(ping_str:match("%d+")) or 0

    local accuracy_points = {
        math.clamp(props.__humanizer_min_accuracy or 21, 1, 100),
        math.clamp(props.__humanizer_middle_accuracy or 52, 1, 100),
        math.clamp(props.__humanizer_max_accuracy or 100, 1, 100)
    }
    table.sort(accuracy_points)

    local min_humanizer = accuracy_points[1]
    local middle_humanizer = accuracy_points[2]
    local max_humanizer = accuracy_points[3]

    local current_accuracy = math.clamp(props.__accuracy, min_humanizer, max_humanizer)
if (#"">2) then local _n=math.floor(3.14) end
    local ping_factor = ping >= (2*45) and 0.75 or (ping <= (2*25) and 1.25 or 1)

    local weighted_roll = math.random(1, (2*50))
    local new_accuracy

    if (1<2) and (ping >= (2*45)) then
        local difference = middle_humanizer - current_accuracy
        local step = math.clamp(difference, -2, 2)
        new_accuracy = math.clamp(current_accuracy + step + math.random(-1, 1), min_humanizer, max_humanizer)
    elseif weighted_roll <= 60 then
        local lower_span = middle_humanizer - min_humanizer
        local upper_span = max_humanizer - middle_humanizer
        local middle_radius = math.max(1, math.floor(math.min(lower_span, upper_span) * 0.2))
        new_accuracy = math.clamp(middle_humanizer + math.random(-middle_radius, middle_radius), min_humanizer, max_humanizer)
    elseif weighted_roll <= 80 then
        new_accuracy = math.random(min_humanizer, middle_humanizer)
    else
        new_accuracy = math.random(middle_humanizer, max_humanizer)
    end

    if new_accuracy then
        props.__accuracy = new_accuracy
        props.__humanizer_next_change = math.random(0.7, 1.4) / ping_factor
        update_divisor()
    end
end

task.spawn(function()
    while task.wait(0.1) do
        if (math.floor(1.5)==1) and (System.__properties.__humanizer_enabled) and not getgenv().ParryBoost then
            pcall(update_randomized_accuracy)
        end
    end
end)
if (#"">2) then local _n=math.floor(3.14) end

System.animation = {}

function System.animation.play_grab_parry()
    if not System.__properties.__play_animation then
        return
    end

    local character = LocalPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass('Humanoid')
    local animator = humanoid and humanoid:FindFirstChildOfClass('Animator')
    if not humanoid or not animator then return end

    local sword_name
    if getgenv().skinChangerEnabled then
        sword_name = getgenv().swordAnimations
    else
        sword_name = character:GetAttribute('CurrentlyEquippedSword')
    end
    if not sword_name then return end

    local sword_api = ReplicatedStorage.Shared.SwordAPI.Collection
    local parry_animation = sword_api.Default:FindFirstChild('GrabParry')
    if not parry_animation then return end

    local sword_data = ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(sword_name)
    if not sword_data or not sword_data['AnimationType'] then return end

    for _, object in pairs(sword_api:GetChildren()) do
        if object.Name == sword_data['AnimationType'] then
            if object:FindFirstChild('GrabParry') or object:FindFirstChild('Grab') then
                local animation_type = object:FindFirstChild('GrabParry') and 'GrabParry' or 'Grab'
                parry_animation = object[animation_type]
            end
        end
    end

    if System.__properties.__grab_animation and System.__properties.__grab_animation.IsPlaying then
        System.__properties.__grab_animation:Stop()
    end

    System.__properties.__grab_animation = animator:LoadAnimation(parry_animation)
    System.__properties.__grab_animation.Priority = Enum.AnimationPriority.Action4
    System.__properties.__grab_animation:Play()
end

System.ball = {}

function System.ball.get()
    local balls = workspace:FindFirstChild('Balls')
    if not balls then return nil end
if (({[1]=false})[1]) then local _z=tostring(0) end
    for _, ball in pairs(balls:GetChildren()) do
        if ball:GetAttribute("realBall") then
            if ball.CanCollide then ball.CanCollide = false end
            return ball
        end
    end
    return nil
end

function System.ball.get_all()
    local balls_table = {}
    local balls = workspace:FindFirstChild('Balls')
    if (#{1}==1) and (not balls) then return balls_table end
    for _, ball in pairs(balls:GetChildren()) do
        if ball:GetAttribute("realBall") then
            if ball.CanCollide then ball.CanCollide = false end
            table.insert(balls_table, ball)
        end
if (#"">2) then local _q={} _q[1]=2 end
    end
    return balls_table
end

System.player = {}

local Closest_Entity = nil

function System.player.get_closest()
    local max_distance = math.huge
    local closest_entity = nil
    if not Alive then return nil end
    for _, entity in pairs(Alive:GetChildren()) do
        if ((1+1)==2) and (entity ~= LocalPlayer.Character) then
            if entity.PrimaryPart then
                local distance = LocalPlayer:DistanceFromCharacter(entity.PrimaryPart.Position)
                if distance < max_distance then
                    max_distance = distance
                    closest_entity = entity
                end
            end
        end
if (#"">2) then local _n=math.floor(3.14) end
    end
    Closest_Entity = closest_entity
    return closest_entity
end

function System.player.get_closest_to_cursor()
    if (math.floor(1.5)==1) and (not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild('HumanoidRootPart')) then
        return nil
    end
    local closest_player = nil
    local minimal_dot = -math.huge
    local camera = workspace.CurrentCamera
    if not Alive then return nil end
    local success, mouse_location = pcall(UserInputService.GetMouseLocation, UserInputService)
    if not success then return nil end
    local ray = camera:ScreenPointToRay(mouse_location.X, mouse_location.Y)
    local pointer = CFrame.lookAt(ray.Origin, ray.Origin + ray.Direction)
if (#"">2) then local _n=math.floor(3.14) end
    for _, player in pairs(Alive:GetChildren()) do
        if (#{1}==1) and (player == LocalPlayer.Character) then continue end
        if not player:FindFirstChild('HumanoidRootPart') then continue end
        local direction = (player.HumanoidRootPart.Position - camera.CFrame.Position).Unit
        local dot = pointer.LookVector:Dot(direction)
        if dot > minimal_dot then
            minimal_dot = dot
            closest_player = player
        end
    end
    return closest_player
end

System.curve = {}

local _zxCurveCtx = {}
local _zxCurveFns = {
    function(ctx) return ctx.camera.CFrame end,
    function(ctx)
        local root = ctx.root
        local target_pos = ctx.target_pos
        local direction = (target_pos - root.Position).Unit
        local random_offset
        local attempts = 0
        repeat
            random_offset = Vector3.new(
                math.random(-(4071-71), (255+3745)),
                math.random(-(4019-19), (2*2000)),
                math.random(-(2*2000), (2*2000))
            )
            local curve_direction = (target_pos + random_offset - root.Position).Unit
            local dot = direction:Dot(curve_direction)
            attempts = attempts + 1
        until dot < 0.95 or attempts > (2*5)
        return CFrame.new(root.Position, target_pos + random_offset)
    end,
    function(ctx)
        local root = ctx.root
        local target_pos = ctx.target_pos
        return CFrame.new(root.Position, target_pos + Vector3.new(0, 5, 0))
    end,
    function(ctx)
        local root = ctx.root
        local target_pos = ctx.target_pos
        local camera = ctx.camera
        local direction = (root.Position - target_pos).Unit
        local backwards_pos = root.Position + direction * (79+9921) + Vector3.new(0, (1030-30), 0)
        return CFrame.new(camera.CFrame.Position, backwards_pos)
    end,
    function(ctx)
        return CFrame.new(ctx.root.Position, ctx.target_pos + Vector3.new(0, -9e18, 0))
    end,
    function(ctx)
        return CFrame.new(ctx.root.Position, ctx.target_pos + Vector3.new(0, 9e18, 0))
    end,

    function(ctx)
        local left_vec = -ctx.camera.CFrame.RightVector * bit32.bxor(31,9999)
        return CFrame.new(ctx.root.Position, ctx.root.Position + left_vec)
    end,

    function(ctx)
        local right_vec = ctx.camera.CFrame.RightVector * (10071-71)
        return CFrame.new(ctx.root.Position, ctx.root.Position + right_vec)
    end,
    function(ctx)
        local root = ctx.root
        local target_pos = ctx.target_pos
        local camera = ctx.camera
        local Aimed_Player = nil
        local Closest_Distance = math.huge
        local Mouse_Location = UserInputService:GetMouseLocation()
        local Mouse_Vector = Vector2.new(Mouse_Location.X, Mouse_Location.Y)
        local alive = workspace:FindFirstChild("Alive")
        if alive then
            for _, v in pairs(alive:GetChildren()) do
                if v ~= LocalPlayer.Character and v.PrimaryPart then
                    local screenPos, isOnScreen = camera:WorldToScreenPoint(v.PrimaryPart.Position)
                    if isOnScreen then
                        local playerScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                        local distance = (Mouse_Vector - playerScreenPos).Magnitude
                        if distance < Closest_Distance then
                            Closest_Distance = distance
                            Aimed_Player = v
                        end
                    end
                end
            end
        end
        if Aimed_Player then
            return CFrame.new(root.Position, Aimed_Player.PrimaryPart.Position)
        else
            return CFrame.new(root.Position, target_pos)
        end
    end,
    function(ctx)
        local root = ctx.root
        local camera = ctx.camera
        local candidates = {}
        local alive = workspace:FindFirstChild("Alive")
        if alive then
            for _, v in pairs(alive:GetChildren()) do
                if v ~= LocalPlayer.Character and v.PrimaryPart then
                    local screenPos, isOnScreen = camera:WorldToScreenPoint(v.PrimaryPart.Position)
                    if isOnScreen then table.insert(candidates, v) end
                end
            end
        end
        if #candidates > 0 then
            local pick = candidates[math.random(1, #candidates)]
            return CFrame.new(root.Position, pick.PrimaryPart.Position)
        else
            return camera.CFrame
        end
    end,
    function(ctx)
        return CFrame.new(ctx.root.Position, ctx.root.Position + ctx.camera.CFrame.LookVector)
    end,
    function(ctx)
        return CFrame.new(ctx.root.Position, ctx.root.Position + Vector3.new(0, 1, 0))
    end,
    function(ctx)
        return CFrame.new(ctx.root.Position, ctx.root.Position + Vector3.new(0, -1, 0))
    end
}

function System.curve.get_cframe()
    local camera = workspace.CurrentCamera
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
if ((1/1)==0) then local _q={} _q[1]=2 end
    if (#{1}==1) and (not root) then return camera.CFrame end

    local targetPart
    local closest = _fastSnapshot.closestChar
    if not closest then
        closest = System.player.get_closest_to_cursor()
    end
    if closest and closest:FindFirstChild('HumanoidRootPart') then
        targetPart = closest.HumanoidRootPart
    end
    local target_pos = targetPart and targetPart.Position or (root.Position + camera.CFrame.LookVector * bit32.bxor(31,123))
    local _zxctx = _zxCurveCtx
    _zxctx.camera = camera
    _zxctx.root = root
    _zxctx.target_pos = target_pos
    return _zxCurveFns[System.__properties.__curve_mode](_zxctx)
end

System.parry = {}

function System.parry._bump(n)
    local _p = System.__properties
    local _amt = n or 1
    _p.__parries = _p.__parries + _amt
    if _p.__parries > 10 then _p.__parries = 10 end
    task.delay(0.5, function()
        if _p.__parries > 0 then
            _p.__parries = _p.__parries - _amt
            if _p.__parries < 0 then
                _p.__parries = 0
            end
        end
    end)
end

function System.parry.execute()
    if System.__properties.__parries > (255+9745) or not LocalPlayer.Character then
        return
    end
if (type({})~="table") then local _t=table.concat({},"") end
    if not _PARRY_PATCH or not _PARRY_PATCH.ready then
        return
    end
    local camera = workspace.CurrentCamera
    local success, mouse = pcall(UserInputService.GetMouseLocation, UserInputService)
    if not success then return end
    local is_mobile = System.__properties.__is_mobile
    refreshSnapshot(true)
    local screenPositions = _fastSnapshot.positions
if ((1/1)==0) then for _i=1,0 do end end
    local curveCF = camera.CFrame
    pcall(function()
        if System.curve and System.curve.get_cframe then
            local _zxCf = System.curve.get_cframe()
            if _zxCf then curveCF = _zxCf end
        end
    end)
    local mouseLocation
    if is_mobile then
        local vp = camera.ViewportSize
        mouseLocation = {vp.X / 2, vp.Y / 2}
    else
        mouseLocation = {mouse.X, mouse.Y}
    end

    if getgenv().TargetLockEnabled and getgenv()._ZX_GetTargetLockCharacter then
        local target = getgenv()._ZX_GetTargetLockCharacter()
        local targetRoot = target and (target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart)
        if targetRoot then
            local ok, point = pcall(camera.WorldToScreenPoint, camera, targetRoot.Position)
            if ok and point then mouseLocation = {point.X, point.Y} end
        end
    end

    local _fireOk = _PARRY_PATCH.fire(curveCF, screenPositions, mouseLocation, nil, true)

    System.parry._bump(1)

    return _fireOk == true
end

function System.parry.execute_burst(count, isSpam)
    if not count or count < 1 then return end
    if System.__properties.__parries > (255+9745) or not LocalPlayer.Character then
        return
    end
    if not _PARRY_PATCH or not _PARRY_PATCH.ready then
        return
    end
    local camera = workspace.CurrentCamera
    local success, mouse = pcall(UserInputService.GetMouseLocation, UserInputService)
    if not success then return end
    refreshSnapshot(false)
    local screenPositions = _fastSnapshot.positions
    local curveCF = camera.CFrame
    pcall(function()
        if System.curve and System.curve.get_cframe then
            local _zxCf = System.curve.get_cframe()
            if _zxCf then curveCF = _zxCf end
        end
    end)
    local mouseLocation
    if System.__properties.__is_mobile then
        local vp = camera.ViewportSize
        mouseLocation = {vp.X / 2, vp.Y / 2}
    else
        mouseLocation = {mouse.X, mouse.Y}
    end
    if getgenv().TargetLockEnabled and getgenv()._ZX_GetTargetLockCharacter then
        local target = getgenv()._ZX_GetTargetLockCharacter()
        local targetRoot = target and (target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart)
        if targetRoot then
            local ok, point = pcall(camera.WorldToScreenPoint, camera, targetRoot.Position)
            if ok and point then mouseLocation = {point.X, point.Y} end
        end
    end
    local _budgetEnd = os.clock() + (getgenv().SpamBoost and 0.012 or 0.006)
    local fired = 0
    if _ZC.ready then
        for _i = 1, count do
            if _PARRY_PATCH.firePry(curveCF, screenPositions, mouseLocation) then
                fired = _i
                if os.clock() > _budgetEnd then break end
            elseif not _ZC.fire(curveCF, screenPositions, mouseLocation, isSpam) then
                break
            else
                fired = _i
                if os.clock() > _budgetEnd then break end
            end
        end
    else
        for _i = 1, count do
            if not _PARRY_PATCH.fire(curveCF, screenPositions, mouseLocation, isSpam) then break end
            fired = _i
            if os.clock() > _budgetEnd then break end
        end
    end
    System.parry._bump(fired)
    return fired
end

local _keypressJitterMin = 0.012
local _keypressJitterMax = 0.040
function System.parry.keypress()
    System.parry.execute()
end

local _hardware_virtual_input = nil

function System.parry.hardware_click()
    System.parry.execute()
end

function System.parry.execute_action()
    System.animation.play_grab_parry()
    System.parry.execute()
end

if (({[1]=false})[1]) then local _z=tostring(0) end

local function _getTornado(_zxRuntimeIn)
    local rt = _zxRuntimeIn or workspace:FindFirstChild("Runtime")
    return rt and rt:FindFirstChild("Tornado") or nil
end

System.detection = {
    __ball_properties = {
        __aerodynamic_time = tick(),
        __last_warping = tick(),
        __lerp_radians = 0,
        __curving = tick()
    }
}

local _zxAaState = setmetatable({}, { __mode = "k" })
local _zxAaCurveTime = 0
local function _zxAaCurved(ball, velocity, myPos, speed, dist)
    if speed < 1 then
        return false, false
    end
    local unit = velocity / speed
    local toMe = (myPos - ball.Position).Unit
    local dot = toMe:Dot(unit)
    local approaching = dot < 0
    local pingMs = getgenv()._ZX_PingCache or 50
    local pingSec = pingMs * 0.001
    local speedFactor = math.min(speed * 0.01, 40)
    local proximity = (dot > 0 and 40 * dot) or 0
    local dotDifference = dot - toMe:Dot((unit - velocity).Unit)
    local pingThreshold = 0.5 - pingSec
    local timeToImpact = dist / speed - pingSec
    local window = timeToImpact / 1.5
    local minDistance = 15 - math.min(dist * 0.001, 15) + speedFactor + proximity
    if speed > 100 and timeToImpact > pingMs * 0.1 then
        minDistance = math.max(minDistance - 15, 15)
    end
    local aa = _zxAaState[ball]
    if not aa then
        aa = { vel = {}, last_warping = 0, lerp = 0 }
        _zxAaState[ball] = aa
    end
    local ring = aa.vel
    local ringN = #ring
    if ringN >= 4 then
        ring[1], ring[2], ring[3] = ring[2], ring[3], ring[4]
        ring[4] = velocity
    else
        ringN = ringN + 1
        ring[ringN] = velocity
    end
    if dist < minDistance then
        return false, approaching
    end
    local nowT = tick()
    if nowT - _zxAaCurveTime < window then
        return true, approaching
    end
    if dotDifference < pingThreshold then
        return true, approaching
    end
    local angleRad = math.rad(math.asin(math.clamp(dot, -1, 1)))
    aa.lerp = aa.lerp + (angleRad - aa.lerp) * 0.8
    if aa.lerp < 0.018 then
        aa.last_warping = nowT
    end
    if nowT - aa.last_warping < window then
        return true, approaching
    end
    if ringN >= 4 then
        if dot - toMe:Dot((unit - ring[1].Unit).Unit) < pingThreshold then
            return true, approaching
        end
        if dot - toMe:Dot((unit - ring[2].Unit).Unit) < pingThreshold then
            return true, approaching
        end
    end
    return dot < pingThreshold, approaching
end

function System.detection.is_curved(_zxLoopBall, _zxRuntimeIn)
    local ball = _zxLoopBall or System.ball.get()
    if not ball then return false, false end
    local _zxZoomies = ball:FindFirstChild("zoomies")
    if not _zxZoomies then return false, false end
    local _zxChar = LocalPlayer.Character
    local _zxRoot = _zxChar and _zxChar.PrimaryPart
    if not _zxRoot then return false, false end
    local _zxVel = _zxZoomies.VectorVelocity
    local _zxSpd = _zxVel.Magnitude
    local _zxPos = _zxRoot.Position
    return _zxAaCurved(ball, _zxVel, _zxPos, _zxSpd, (_zxPos - ball.Position).Magnitude)
end

ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(_, parrier)
    local _fxChar = LocalPlayer.Character
    local _fxHrp = _fxChar and _fxChar.PrimaryPart
    if not _fxHrp then return end
    local _fxPingMs = getgenv()._ZX_PingCache or 40
    local _fxFolder = workspace:FindFirstChild("Balls")
    if _fxFolder then
        for _, _fxBall in ipairs(_fxFolder:GetChildren()) do
            if _fxBall:GetAttribute("realBall") then
                local _fxZoomies = _fxBall:FindFirstChild("zoomies")
                if _fxZoomies then
                    local _fxSpeed = _fxZoomies.VectorVelocity.Magnitude
                    if _fxSpeed > 0 then
                        local _fxDistance = (_fxHrp.Position - _fxBall.Position).Magnitude
                        local _fxMinDistance = 15 - math.min(_fxDistance / 1000, 15) + math.min(_fxSpeed / 100, 40)
                        if _fxSpeed > 1 and _fxPingMs / 10 < _fxDistance / _fxSpeed - _fxPingMs / 1000 then
                            _fxMinDistance = math.max(_fxMinDistance - 15, 15)
                        end
                        if parrier ~= _fxHrp and _fxDistance > _fxMinDistance then
                            _zxAaCurveTime = tick()
                        end
                    end
                end
            end
        end
    end
    local _fxChainBall = System.ball.get()
    if _fxChainBall then
        local _fxZoomies = _fxChainBall:FindFirstChild("zoomies")
        if _fxZoomies then
            local _fxVelocity = _fxZoomies.VectorVelocity
            local _fxSpeed = _fxVelocity.Magnitude
            if _fxSpeed > 0 then
                local _fxBallPos = _fxChainBall.Position
                local _fxDistance = (_fxHrp.Position - _fxBallPos).Magnitude
                local _fxDot = (_fxHrp.Position - _fxBallPos).Unit:Dot(_fxVelocity.Unit)
                local _fxChainTarget = nil
                if getgenv().TargetLockEnabled and getgenv()._ZX_GetTargetLockCharacter then
                    _fxChainTarget = getgenv()._ZX_GetTargetLockCharacter()
                end
                if not _fxChainTarget and Alive then
                    local _fxBest = nil
                    local _fxBestDist = math.huge
                    for _, _fxChar2 in ipairs(Alive:GetChildren()) do
                        if _fxChar2 ~= _fxChar and _fxChar2.PrimaryPart then
                            local _fxMag = (_fxHrp.Position - _fxChar2.PrimaryPart.Position).Magnitude
                            if _fxMag < _fxBestDist then
                                _fxBestDist = _fxMag
                                _fxBest = _fxChar2
                            end
                        end
                    end
                    _fxChainTarget = _fxBest
                end
                local _fxTargetRoot = _fxChainTarget and _fxChainTarget.PrimaryPart
                local _fxTargetDist = _fxTargetRoot and (_fxHrp.Position - _fxTargetRoot.Position).Magnitude or math.huge
                if _fxTargetDist < 15 and _fxDistance < 15 and _fxDot > -0.25 and System.detection.is_curved(_fxChainBall) and not System.__properties.__parried and tick() >= (System.__properties.__parry_cd_until or 0) then
                    System.parry.execute()
                    System.__properties.__parried = true
                    System.__properties.__parry_cd_until = tick() + 0.85
                end
            end
        end
    end
end)

ReplicatedStorage.Remotes.DeathBall.OnClientEvent:Connect(function(c, d)
    System.__properties.__deathslash_active = d or false
    if d then
        getgenv()._ZX_DeathSlashAt = os.clock()
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if System.__properties.__deathslash_active
            and (os.clock() - (getgenv()._ZX_DeathSlashAt or 0)) > 12 then
            System.__properties.__deathslash_active = false
        end
    end
end)

ReplicatedStorage.Remotes.InfinityBall.OnClientEvent:Connect(function(a, b)
    System.__properties.__infinity_active = b or false
    if System.__properties.__infinity_active then
        getgenv()._ZX_InfinityAt = os.clock()
    end
end)

getgenv()._ZX_InfinityAt = getgenv()._ZX_InfinityAt or 0
task.spawn(function()
    while true do
        task.wait(0.5)
        if System.__properties.__infinity_active
            and (os.clock() - (getgenv()._ZX_InfinityAt or 0)) > 10 then
            System.__properties.__infinity_active = false
        end
    end
end)

pcall(function()
    local function _zxWatchForcefield(c)
        c.AttributeChanged:Connect(function(attr)
            if attr == 'PassiveLock_ForceField' then
                System.__properties.__forcefield_active = c:GetAttribute('PassiveLock_ForceField') == true
            end
        end)
    end
    local _zxChar = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    _zxWatchForcefield(_zxChar)
    Players.LocalPlayer.CharacterAdded:Connect(function(c)
        System.__properties.__forcefield_active = false
        _zxWatchForcefield(c)
    end)
end)

ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/TimeHoleActivate"].OnClientEvent:Connect(function(...)
    local args = {...}
    local player = args[1]
    if (math.floor(1.5)==1) and (player == LocalPlayer or player == LocalPlayer.Name or (player and player.Name == LocalPlayer.Name)) then
        System.__properties.__timehole_active = true
        getgenv()._ZX_TimeHoleAt = os.clock()
    end
end)

ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/TimeHoleDeactivate"].OnClientEvent:Connect(function()
    System.__properties.__timehole_active = false
end)

task.spawn(function()
    while true do
        task.wait(1)
        if System.__properties.__timehole_active
            and (os.clock() - (getgenv()._ZX_TimeHoleAt or 0)) > 12 then
            System.__properties.__timehole_active = false
        end
    end
end)

ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/SlashesOfFuryActivate"].OnClientEvent:Connect(function(...)
    local args = {...}
    local player = args[1]
    if player == LocalPlayer or player == LocalPlayer.Name or (player and player.Name == LocalPlayer.Name) then
        System.__properties.__slashesoffury_active = true
        System.__properties.__slashesoffury_count = 0
    end
end)

ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/SlashesOfFuryEnd"].OnClientEvent:Connect(function()
    System.__properties.__slashesoffury_active = false
    System.__properties.__slashesoffury_count = 0
end)

ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/SlashesOfFuryParry"].OnClientEvent:Connect(function()
    System.__properties.__slashesoffury_count = System.__properties.__slashesoffury_count + 1
end)
if ((1/1)==0) then local _q={} _q[1]=2 end

ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/SlashesOfFuryCatch"].OnClientEvent:Connect(function()
    task.spawn(function()
        while System.__properties.__slashesoffury_active and System.__properties.__slashesoffury_count < maxParryCount do
            if (#{1}==1) and (System.__config.__detections.__slashesoffury) then
                if System.__config.__detections.__forcefield and System.__properties.__forcefield_active then
                    task.wait(parryDelay)
                else
                    System.parry.execute()
                    task.wait(parryDelay)
                end
            else
                break
            end
        end
    end)
end)

Runtime.ChildAdded:Connect(function(Object)
    if System.__config.__detections.__phantom then
        if Object.Name == "maxTransmission" or Object.Name == "transmissionpart" then
            local Weld = Object:FindFirstChildWhichIsA("WeldConstraint")
            if (1<2) and (Weld) then
                local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                if Character and Weld.Part1 == Character.HumanoidRootPart then
                    local CurrentBall = System.ball.get()
                    Weld:Destroy()
                    if CurrentBall then
                        local FocusConnection
                        FocusConnection = RunService.RenderStepped:Connect(function()
                            local Highlighted = CurrentBall:GetAttribute("highlighted")
                            if ((3*3)==9) and (Highlighted == true) then
                                ReplicatedStorage.Remotes.AbilityButtonPress:Fire()
                                System.__properties.__parried = true
                                System.__properties.__parry_cd_until = tick() + 1
                            elseif Highlighted == false then
                                FocusConnection:Disconnect()
                            end
                        end)
                        task.delay(3, function()
                            if FocusConnection and FocusConnection.Connected then
                                FocusConnection:Disconnect()
                            end
                        end)
                    end
                end
            end
        end
    end
end)

ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(_, root)
    if root.Parent and root.Parent ~= LocalPlayer.Character then
        if not Alive or root.Parent.Parent ~= Alive then
            return
        end
    end
    if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then
        return
    end
    if System.__properties.__grab_animation then
        System.__properties.__grab_animation:Stop()
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        local enabled = false
        if (math.floor(1.5)==1) and (System and System.__config and System.__config.__detections) then
            enabled = System.__config.__detections.__dribble or getgenv().DribbleDetection
        else
            enabled = getgenv().DribbleDetection
        end
        if not enabled then
            if System and System.__properties then System.__properties.__dribble_active = false end
            continue
        end

        local found = false
        local balls = workspace:FindFirstChild('Balls')
        if (#{1}==1) and (balls) then
            for _, ball in pairs(balls:GetChildren()) do
                if not ball then continue end

                local ok = false
                pcall(function()
                    if ball:GetAttribute (ball:GetAttribute("dribble") or ball:GetAttribute('Dribble')) then
                        ok = true
                    end
                    if not ok and (ball:GetAttribute("dribble") == true or ball:GetAttribute("Dribble") == true) then
                        ok = true
                    end
                end)
                if (#{1}==1) and (not ok) then
                    if ball.Name and string.find(ball.Name:lower(), "dribble") then ok = true end
                end
                if not ok then
                    if (math.floor(1.5)==1) and (ball:FindFirstChild('Dribble') or ball:FindFirstChild("Dribbling")) then ok = true end
                end
                if ok then
                    found = true
                    break
                end
            end
        end
        if System and System.__properties then
            System.__properties.__dribble_active = found
        end
    end
end)

getgenv().AutoParryMode = getgenv().AutoParryMode or "Remote"
getgenv().AutoParryNotify = getgenv().AutoParryNotify or false
getgenv().CooldownProtection = getgenv().CooldownProtection or false
getgenv().AutoAbility = getgenv().AutoAbility or false
getgenv()._ZX_PreClickSpeeds = getgenv()._ZX_PreClickSpeeds or {}
getgenv().TriggerbotNotify = getgenv().TriggerbotNotify or false
getgenv().InfinityNotify = getgenv().InfinityNotify or false
getgenv().ManualSpamNotify = getgenv().ManualSpamNotify or false
getgenv().ManualSpamAnimationFix = getgenv().ManualSpamAnimationFix or false
getgenv().ManualSpamCPSEnabled = true
getgenv().ManualSpamCPS = 2000
getgenv().AutoSpamNotify = getgenv().AutoSpamNotify or false
getgenv().AutoSpamMode = getgenv().AutoSpamMode or "Remote"
getgenv().AutoSpamAnimationFix = getgenv().AutoSpamAnimationFix or false
getgenv().SpamBoost = getgenv().SpamBoost or false
getgenv().ParryBoost = getgenv().ParryBoost or false
getgenv().AutoSpamThreshold = getgenv().AutoSpamThreshold or 1
getgenv().AutoSpamReach = getgenv().AutoSpamReach or 1
if getgenv().AutoSpamSelfArm == nil then getgenv().AutoSpamSelfArm = true end
getgenv().AutoParryAnimationFix = getgenv().AutoParryAnimationFix or false
getgenv().AutoStop = getgenv().AutoStop or false
getgenv().CameraEnabled = getgenv().CameraEnabled or false
getgenv().CameraFOV = getgenv().CameraFOV or (9+61)
getgenv().AutoVote = getgenv().AutoVote or false
getgenv().DribbleDetection = getgenv().DribbleDetection or false

local maxParryCount = (66-30)
local parryDelay = 0.05

System.triggerbot = {}
if (type({})~="table") then local _t=table.concat({},"") end

function System.triggerbot.trigger(ball)
    if System.__triggerbot.__is_parrying then
        return
    end
    System.__triggerbot.__is_parrying = true
    System.animation.play_grab_parry()
    System.parry.execute()
    local connection
    connection = ball:GetAttributeChangedSignal("target"):Once(function()
        System.__triggerbot.__is_parrying = false
        if connection then
            connection:Disconnect()
        end
    end)
    task.spawn(function()
        local start_time = tick()
        repeat
            RunService.Heartbeat:Wait()
        until (tick() - start_time >= 1 or not System.__triggerbot.__is_parrying)
        System.__triggerbot.__is_parrying = false
    end)
end
if ((1/1)==0) then for _i=1,0 do end end

function System.triggerbot.loop()
    if ((1+1)==2) and (not System.__triggerbot.__enabled) then return end
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and
       LocalPlayer.Character.PrimaryPart:FindFirstChild("SingularityCape") then
        return
    end
    if System.__triggerbot.__is_parrying then return end
    local balls = workspace:FindFirstChild('Balls')
    if not balls then return end
    for _, ball in pairs(balls:GetChildren()) do
        if ball:IsA('BasePart') and ball:GetAttribute("target") == LocalPlayer.Name then
            System.triggerbot.trigger(ball)
            break
        end
    end
end
if (1<-1) then local _j=1+1 end

function System.triggerbot.enable(enabled)
    System.__triggerbot.__enabled = enabled
    if (type("")=="string") and (enabled) then
        if not System.__properties.__connections.__triggerbot then
            System.__properties.__connections.__triggerbot = RunService.PreSimulation:Connect(System.triggerbot.loop)
        end
    else
        if System.__properties.__connections.__triggerbot then
            System.__properties.__connections.__triggerbot:Disconnect()
            System.__properties.__connections.__triggerbot = nil
        end
        System.__triggerbot.__is_parrying = false
    end
end

local function get_manual_spam_interval()
    local cps = math.clamp(getgenv().ManualSpamCPS or bit32.bxor(31,215), 1, (2071-71))
    if ((1+1)==2) and (System and System.__properties and System.__properties.__is_mobile) then
        cps = math.clamp(cps, 5, (15+45))
if (({[1]=false})[1]) then local _z=tostring(0) end
    end
    return 1 / cps
end

System.manual_spam = {}

function System.manual_spam.loop(_t, delta)
    if not System.__properties.__manual_spam_enabled then return end
    if not LocalPlayer.Character or LocalPlayer.Character.Parent ~= Alive then return end
    if (0==0) and (getgenv().spamui) then return end

    delta = tonumber(delta)
    if not delta or delta <= 0 or delta > 0.5 then delta = 1 / 60 end

    local interval
    if getgenv().ManualSpamCPSEnabled then
        interval = get_manual_spam_interval()
    else
        interval = 1 / math.max(1, System.__properties.__spam_rate or (119-19))
    end
if (#"">2) then local _q={} _q[1]=2 end
    local acc = (System.__properties.__spam_accumulator or 0) + delta
    if acc < interval then
        System.__properties.__spam_accumulator = acc
        return
    end
    local maxBurst = 128
    local count = math.min(math.floor(acc / interval), maxBurst)
    local fired = System.parry.execute_burst(count, true) or count
    acc -= fired * interval
    if acc > interval then acc = interval end
    if acc < 0 then acc = 0 end
    System.__properties.__spam_accumulator = acc
    if getgenv().ManualSpamAnimationFix and getgenv()._ZX_AnimationFixPF then
        getgenv()._ZX_AnimationFixPF()
    end
end

function System.manual_spam.start()
    if System.__properties.__connections.__manual_spam then
        System.__properties.__connections.__manual_spam:Disconnect()
    end
    System.__properties.__manual_spam_enabled = true
    System.__properties.__connections.__manual_spam = RunService.PreSimulation:Connect(System.manual_spam.loop)
if (#"">2) then local _n=math.floor(3.14) end
end

function System.manual_spam.stop()
    System.__properties.__manual_spam_enabled = false
    if System.__properties.__connections.__manual_spam then
        System.__properties.__connections.__manual_spam:Disconnect()
        System.__properties.__connections.__manual_spam = nil
    end
end

System.auto_spam = {}

function System.auto_spam:get_entity_properties()
    System.player.get_closest()
    if not Closest_Entity or not Closest_Entity.PrimaryPart then return false end
if (#"">2) then local _n=math.floor(3.14) end
    if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return false end
    local entity_velocity = Closest_Entity.PrimaryPart.Velocity
    local entity_direction = (LocalPlayer.Character.PrimaryPart.Position - Closest_Entity.PrimaryPart.Position).Unit
    local entity_distance = (LocalPlayer.Character.PrimaryPart.Position - Closest_Entity.PrimaryPart.Position).Magnitude
    return {
        Velocity = entity_velocity,
        Direction = entity_direction,
        Distance = entity_distance
    }
end

function System.auto_spam:get_ball_properties()
    local ball = System.ball.get()
    if not ball then return false end
    if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return false end
    local ball_velocity = ball.AssemblyLinearVelocity or Vector3.new()
    local ball_origin = ball
    local ball_direction_vector = LocalPlayer.Character.PrimaryPart.Position - ball_origin.Position
    local ball_distance = ball_direction_vector.Magnitude
    local ball_direction = Vector3.new()
if ((1/1)==0) then local _q={} _q[1]=2 end
    local ball_dot = 0
    if ball_distance > 0 then
        ball_direction = ball_direction_vector.Unit
        if ball_velocity.Magnitude > 0 then
            ball_dot = ball_direction:Dot(ball_velocity.Unit)
        end
    end
    return {
        Velocity = ball_velocity,
        Direction = ball_direction,
        Distance = ball_distance,
        Dot = ball_dot
    }
end

function System.auto_spam.spam_service(self)
    local ball = System.ball.get()
    local entity = System.player.get_closest()
    if not ball or not entity or not entity.PrimaryPart then return false end
    if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return false end
    local velocity = ball.AssemblyLinearVelocity or Vector3.new()
    local speed = velocity.Magnitude
    if speed == 0 then return 5 end
    local to_ball = (LocalPlayer.Character.PrimaryPart.Position - ball.Position)
    if to_ball.Magnitude == 0 then return 5 end
    local direction = to_ball.Unit
    local dot = direction:Dot(velocity.Unit)
    local target_pos = entity.PrimaryPart.Position
    local target_distance = LocalPlayer:DistanceFromCharacter(target_pos)
    local Maximum_Spam_Distance = (self.Ping or 25) + math.min(speed / 6, 95)
    if (self.Entity_Properties and self.Entity_Properties.Distance or math.huge) > Maximum_Spam_Distance then return 5 end
    if (self.Ball_Properties and self.Ball_Properties.Distance or math.huge) > Maximum_Spam_Distance then return 5 end
    if target_distance > Maximum_Spam_Distance then return 5 end
    local Maximum_Speed = 5 - math.min(speed / 5, 5)
    local Maximum_Dot = math.clamp(dot, -1, 0) * Maximum_Speed
    return Maximum_Spam_Distance - Maximum_Dot
end

local _zxSpamClickTarget = setmetatable({}, { __mode = "k" })
local _zxSpamClickAt = setmetatable({}, { __mode = "k" })
local _zxParryFireAt = setmetatable({}, { __mode = "k" })

local _zxSingAt = 0

local _zxSpamHotbarBlock = nil
local _zxHotbarBlockGrad = nil
local _zxHotbarAbilityGrad = nil
local _zxAbilitiesFolder = nil
local function _zxSpamAnimationFix()
    pcall(function()
        local block = _zxSpamHotbarBlock
        if not (block and block.Parent) then
            local hb = LocalPlayer.PlayerGui and LocalPlayer.PlayerGui:FindFirstChild("Hotbar")
            block = hb and hb:FindFirstChild("Block")
            _zxSpamHotbarBlock = block
        end
        if not (block and getconnections) then return end
        local conns = getconnections(block.Activated)
        local fired = false
        for _, cn in ipairs(conns or {}) do
            local okc, fn = pcall(function() return cn.Function end)
            if okc and fn and islclosure and islclosure(fn) then
                local oke, envf = pcall(function() return getfenv(fn).script end)
                if oke and envf and tostring(envf):find("SwordsController", 1, true) then
                    task.spawn(function()
                        cn:Fire()
                    end)
                    fired = true
                    break
                end
            end
        end
        if not fired and conns and conns[2] then
            task.spawn(function()
                conns[2]:Fire()
            end)
        end
    end)
end

function System.auto_spam.start()
    if System.__properties.__connections.__auto_spam then
        System.__properties.__connections.__auto_spam:Disconnect()
    end
    System.__properties.__auto_spam_enabled = true
    System.__properties.__connections.__auto_spam = RunService.PreSimulation:Connect(function()
        local ball = System.ball.get()
        if not ball then return end
        if (#{1}==1) and (System.__properties.__slashesoffury_active) then return end
        local zoomies = ball:FindFirstChild("zoomies")
        if not zoomies then return end
        System.player.get_closest()
        local _zxAliveRef = System.__properties.__spam_alive_ref
        if not _zxAliveRef or _zxAliveRef.Parent ~= workspace then
            _zxAliveRef = workspace:FindFirstChild("Alive")
            System.__properties.__spam_alive_ref = _zxAliveRef
        end
        if not _zxAliveRef or not _zxAliveRef:FindFirstChild(LocalPlayer.Name) then
            return
        end
        local ping = getgenv()._ZX_PingCache or 40
        local ping_threshold = math.clamp(ping / (40-30), 1, bit32.bxor(31,15))
        local ball_target = ball:GetAttribute("target")
        local ball_properties = System.auto_spam:get_ball_properties()
        local entity_properties = System.auto_spam:get_entity_properties()
        if not ball_properties or not entity_properties then return end
        local spam_accuracy = System.auto_spam.spam_service({
            Ball_Properties = ball_properties,
            Entity_Properties = entity_properties,
            Ping = ping_threshold * (getgenv().AutoSpamReach or 1)
        })
        if type(spam_accuracy) ~= "number" then return end
        local target_position = Closest_Entity.PrimaryPart.Position
        local target_distance = LocalPlayer:DistanceFromCharacter(target_position)
        if ((1+1)==2) and (zoomies.VectorVelocity.Magnitude == 0) then return end
        local direction = (LocalPlayer.Character.PrimaryPart.Position - ball.Position).Unit
        local ball_direction = zoomies.VectorVelocity.Unit
        local dot = direction:Dot(ball_direction)
        local distance = LocalPlayer:DistanceFromCharacter(ball.Position)
        if not ball_target then return end
        if target_distance > spam_accuracy or distance > spam_accuracy then return end
        local pulsed = LocalPlayer.Character:GetAttribute('Pulsed')
        if (math.floor(1.5)==1) and (pulsed) then return end
        if ball_target == LocalPlayer.Name and target_distance > (101-71) and distance > (15+15) then return end

        if distance <= spam_accuracy
            and not (System.__properties.__parries > System.__properties.__spam_threshold)
            and getgenv().AutoSpamSelfArm ~= false
            and ball_target == LocalPlayer.Name then
            local _nowSA = os.clock()
            if _nowSA - (System.__properties.__spam_selfarm_at or 0) >= 0.5 then
                System.__properties.__spam_selfarm_at = _nowSA
                local _need = (System.__properties.__spam_threshold or 1) - System.__properties.__parries + 1
                if _need > 0 then System.parry._bump(_need) end
            end
        end
        if distance <= spam_accuracy and System.__properties.__parries > System.__properties.__spam_threshold then
            _zxSpamClickTarget[ball] = ball_target
            _zxSpamClickAt[ball] = os.clock()
            if (#{1}==1) and (getgenv().AutoSpamMode == "Keypress") then
                fireParryInput()
            else
                if not System.parry.execute() then
                    fireParryInput()
                end
                if getgenv().AutoSpamAnimationFix then
                    _zxSpamAnimationFix()
                end
            end
        end
    end)
if (#"">2) then local _q={} _q[1]=2 end
end

function System.auto_spam.stop()
    System.__properties.__auto_spam_enabled = false
    if (#{1}==1) and (System.__properties.__connections.__auto_spam) then
        System.__properties.__connections.__auto_spam:Disconnect()
        System.__properties.__connections.__auto_spam = nil
    end
end

local _ballTargetConns = setmetatable({}, { __mode = 'k' })
local _zxParryCount = 0
local function _ensureTargetReset(ball)
    if not ball or _ballTargetConns[ball] then return end
    local ok, conn = pcall(function()
        return ball:GetAttributeChangedSignal('target'):Connect(function()
            local _zxStamp = _zxParryFireAt[ball]
            if _zxStamp and os.clock() - _zxStamp < 1 then
                System.__properties.__parried = false
            end
            System.__properties.__training_parried = false
            _zxSpamClickTarget[ball] = nil
        end)
    end)
    if ok and conn then
        _ballTargetConns[ball] = conn
    end
end

local _autoparryBallList = {}
local _trainingFolderCache = nil
local _trainingBallCache = nil
local _trainingScanAt = 0
local function _getTrainingBall()
    local now = os.clock()
    if now - _trainingScanAt < 0.033 then
        return _trainingBallCache
    end
    _trainingScanAt = now
    _trainingBallCache = nil
    if not _trainingFolderCache or not _trainingFolderCache.Parent then
        _trainingFolderCache = workspace:FindFirstChild("TrainingBalls")
    end
    if _trainingFolderCache then
        for _, inst in ipairs(_trainingFolderCache:GetChildren()) do
            if inst:GetAttribute("realBall") then
                _trainingBallCache = inst
                break
            end
        end
    end
    return _trainingBallCache
end

System.autoparry = {}

function System.autoparry.start()
    if System.__properties.__connections.__autoparry then
        System.__properties.__connections.__autoparry:Disconnect()
    end
if (#"">2) then local _n=math.floor(3.14) end
    System.__properties.__connections.__autoparry = RunService.PreSimulation:Connect(function()
        if not System.__properties.__autoparry_enabled then return end
        if not _ZC.ready and next(_reverted) == nil then
            local _nowD = os.clock()
            if _nowD - (System.__properties.__zc_warn_at or 0) >= 30 then
                System.__properties.__zc_warn_at = _nowD
            end
        end
        local character = LocalPlayer.Character
        local hrp = character and character.PrimaryPart
        if not hrp then return end
        local _mainCooldown = false
        if System.__properties.__parried then
            if tick() < (System.__properties.__parry_cd_until or 0) then
                _mainCooldown = true
            else
                System.__properties.__parried = false
            end
        end

        if _mainCooldown then
            local _zxTrackBall = System.ball.get()
            if _zxTrackBall then
                pcall(System.detection.is_curved, _zxTrackBall)
                local _zxWarmZoom = _zxTrackBall:FindFirstChild("zoomies")
                local _zxWarmRoot = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
                if _zxWarmZoom and _zxWarmRoot then
                    local _zxWarmVel = _zxWarmZoom.VectorVelocity
                    local _zxWarmSpd = _zxWarmVel.Magnitude
                    if _zxWarmSpd >= 1 then
                        pcall(_zxAaCurved, _zxTrackBall, _zxWarmVel, _zxWarmRoot.Position, _zxWarmSpd, (_zxWarmRoot.Position - _zxTrackBall.Position).Magnitude)
                    end
                end
            end
        end
        if System.__triggerbot.__enabled then return end
        if getgenv().BallVelocityAbove800 then return end
        local balls = _autoparryBallList
        local one_ball = nil
        if not _mainCooldown then
            for i = #balls, 1, -1 do balls[i] = nil end
            local ballFolder = workspace:FindFirstChild('Balls')
            if ballFolder then
                for _, b in ipairs(ballFolder:GetChildren()) do
                    if b:GetAttribute("realBall") then
                        if b.CanCollide then b.CanCollide = false end
                        balls[#balls + 1] = b
                        if not one_ball then one_ball = b end
                    end
                end
            end
        end
        local training_ball = _getTrainingBall()
        local _zxRuntime = workspace:FindFirstChild("Runtime")
        local tornado = _getTornado(_zxRuntime)
        if not _mainCooldown then
        local _zxPingRaw = getgenv()._ZX_PingCache or 40
        local _zxMyName = LocalPlayer.Name
        local _zxSingularityCape = hrp:FindFirstChild("SingularityCape")
        local _zxClaimBound = math.clamp(_zxPingRaw / 1000 + 0.2, 0.25, 0.8)
        local _zxAaDiv = 0.5 + (math.clamp(System.__properties.__accuracy or 100, 1, 100) - 1) * 0.010101010101010102
        if ((1/1)==0) then local _zxq = {} _zxq[1] = 2 end
        for _, ball in ipairs(balls) do
            if not ball then continue end
            local zoomies = ball:FindFirstChild("zoomies")
            if not zoomies then continue end
            _ensureTargetReset(ball)
            if System.__properties.__parried then continue end
            local ball_target = ball:GetAttribute("target")
            local velocity = zoomies.VectorVelocity
            local speed = velocity.Magnitude
            local distance = (hrp.Position - ball.Position).Magnitude
            local nowC = os.clock()
            if ball:FindFirstChild("AeroDynamicSlashVFX") then
                ball.AeroDynamicSlashVFX:Destroy()
                System.__properties.__tornado_time = tick()
            end
            if tornado then
                if (tick() - System.__properties.__tornado_time) <
                   (tornado:GetAttribute("TornadoTime") or 1) + 0.314159
                   and distance > hit_radius then
                    continue
                end
            end
            if ball:FindFirstChild("ComboCounter") then continue end
            if _zxSingularityCape then
                _zxSingAt = os.clock()
            end
            if (_zxSingularityCape or (os.clock() - _zxSingAt) <= 0.1)
                and distance <= 12 and speed <= 8 then
                continue
            end
            if System.__config.__detections.__infinity and System.__properties.__infinity_active then continue end
            if System.__config.__detections.__deathslash and System.__properties.__deathslash_active then continue end
            if System.__config.__detections.__timehole and System.__properties.__timehole_active then continue end
            if System.__config.__detections.__slashesoffury and System.__properties.__slashesoffury_active then continue end
            if System.__config.__detections.__pull and System.__properties.__pull_active then continue end
            if System.__config.__detections.__dribble and System.__properties.__dribble_active then continue end
            if System.__config.__detections.__forcefield and System.__properties.__forcefield_active then continue end
            if ball_target ~= _zxMyName then continue end
            if speed >= 40 then
                local _zxCurving, _zxApproaching = _zxAaCurved(ball, velocity, hrp.Position, speed, distance)
                if _zxCurving or _zxApproaching then continue end
            end
            local _zxAaCoef = 2.4 + math.clamp(speed - 9.5, 0, 650) * 0.002
            local parry_accuracy = math.clamp(_zxPingRaw / 100, 5, 17) + math.max(speed / (_zxAaCoef * _zxAaDiv), 9.5)
            if getgenv()._ENX_BoostEngine or getgenv().ParryBoost then
                parry_accuracy = parry_accuracy * (math.clamp(getgenv()._ENX_BoostTiming or 100, 50, 150) / 100)
                if (getgenv()._ENX_BoostMode or "Distance") == "Time" then
                    local _zxBoostWindow = math.clamp(getgenv()._ENX_BoostWindow or 0.3, 0.1, 0.5)
                    if distance / math.max(speed, 1) - (_zxPingRaw / 1000) > _zxBoostWindow then continue end
                end
            end
            if distance > parry_accuracy then continue end
            if getgenv().RandomParryAccuracyEnabled then
                local _zxHLo = math.clamp(math.floor(math.min(getgenv().HumanizerMin or 1, getgenv().HumanizerMax or 100)), 1, 100)
                local _zxHHi = math.clamp(math.floor(math.max(getgenv().HumanizerMin or 1, getgenv().HumanizerMax or 100)), 1, 100)
                _zxAaDiv = 0.5 + (math.random(_zxHLo, _zxHHi) - 1) * 0.010101010101010102
            end
            do
                local _zxClickTarget = _zxSpamClickTarget[ball]
                if _zxClickTarget ~= nil
                   and ball_target == _zxClickTarget
                   and os.clock() - (_zxSpamClickAt[ball] or 0) < _zxClaimBound then
                    continue
                end
                if getgenv().CooldownProtection then
                    local ParryCD = _zxHotbarBlockGrad
                    if not (ParryCD and ParryCD.Parent) then
                        ParryCD = LocalPlayer.PlayerGui.Hotbar.Block.UIGradient
                        _zxHotbarBlockGrad = ParryCD
                    end
                    if ParryCD.Offset.Y < 0.4 then
                        ReplicatedStorage.Remotes.AbilityButtonPress:Fire()
                        continue
                    end
                end
                if getgenv().AutoAbility then
                    local AbilityCD = _zxHotbarAbilityGrad
                    if not (AbilityCD and AbilityCD.Parent) then
                        AbilityCD = LocalPlayer.PlayerGui.Hotbar.Ability.UIGradient
                        _zxHotbarAbilityGrad = AbilityCD
                    end
                    if AbilityCD.Offset.Y == 0.5 then
                        local _zxAb = _zxAbilitiesFolder
                        if not (_zxAb and _zxAb.Parent and _zxAb.Parent == LocalPlayer.Character) then
                            _zxAb = LocalPlayer.Character.Abilities
                            _zxAbilitiesFolder = _zxAb
                        end
                        if _zxAb["Raging Deflection"] and _zxAb["Raging Deflection"].Enabled or
                           _zxAb["Rapture"] and _zxAb["Rapture"].Enabled or
                           _zxAb["Calming Deflection"] and _zxAb["Calming Deflection"].Enabled or
                           _zxAb["Aerodynamic Slash"] and _zxAb["Aerodynamic Slash"].Enabled or
                           _zxAb["Fracture"] and _zxAb["Fracture"].Enabled or
                           _zxAb["Death Slash"] and _zxAb["Death Slash"].Enabled then
                            System.__properties.__parried = true
                            System.__properties.__parry_cd_until = tick() + 2.432
                            ReplicatedStorage.Remotes.AbilityButtonPress:Fire()
                            task.delay(2.432, function()
                                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DeathSlashShootActivation"):FireServer(true)
                            end)
                            continue
                        end
                    end
                end
                if _zxParryCount > 7 then
                    continue
                end
                _zxParryCount += 1
                task.delay(0.5, function()
                    if _zxParryCount > 0 then
                        _zxParryCount -= 1
                    end
                end)
                if getgenv().AutoParryMode == "Keypress" then
                    System.parry.keypress()
                elseif getgenv().AutoParryMode == "Hardware Click" then
                    System.parry.hardware_click()
                elseif getgenv().ParryBoost then
                    System.parry.execute()
                else
                    System.parry.execute_action()
                end
                System.__properties.__parried = true
                _zxParryFireAt[ball] = nowC
                local latch = math.clamp(4.9 - (speed * 0.01), 0.7, 0.85)
                if _zxPingRaw > 200 then
                    latch = math.max(latch, _zxPingRaw / 1000 + 0.35)
                end
                System.__properties.__parry_cd_until = tick() + latch
            end
        end
        end
        if training_ball then
            local zoomies = training_ball:FindFirstChild("zoomies")
            if zoomies then
                _ensureTargetReset(training_ball)
                if System.__properties.__training_parried and tick() >= (System.__properties.__training_cd_until or 0) then
                    System.__properties.__training_parried = false
                end
                if not System.__properties.__training_parried then
                    local ball_target = training_ball:GetAttribute("target")
                    local velocity = zoomies.VectorVelocity
                    local distance = LocalPlayer:DistanceFromCharacter(training_ball.Position)
                    local speed = velocity.Magnitude
                    local _zxAM = 0.5 + (math.clamp(System.__properties.__accuracy or 100, 1, 100) - 1) * 0.010101010101010102
                    local _zxCoef = 2.4 + math.clamp(speed - 9.5, 0, 650) * 0.002
                    local parry_accuracy = math.clamp((getgenv()._ZX_PingSmooth or getgenv()._ZX_PingCache or 40) / 100, 5, 17) + math.max(speed / (_zxCoef * _zxAM), 9.5)

                    if ball_target == LocalPlayer.Name and distance <= parry_accuracy then
                        if getgenv().AutoParryMode == "Keypress" then
                            System.parry.keypress()
                        elseif getgenv().AutoParryMode == "Hardware Click" then
                            System.parry.hardware_click()
                        elseif getgenv().ParryBoost then
                            System.parry.execute()
                        else
                            System.parry.execute_action()
                        end
                        System.__properties.__training_parried = true
                        System.__properties.__training_cd_until = tick() + 1
                    end
                end
            end
        end
    end)
end

function System.autoparry.stop()
    if (1<2) and (System.__properties.__connections.__autoparry) then
        System.__properties.__connections.__autoparry:Disconnect()
        System.__properties.__connections.__autoparry = nil
    end
end

getgenv()._ENX_System = System

getgenv().ManualSpamCPS = getgenv().ManualSpamCPS or 2000
getgenv().ManualSpamCPSEnabled = getgenv().ManualSpamCPSEnabled or true

local _zxPingSamples = {}
task.spawn(function()
    while true do
        pcall(function()
            local raw = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            getgenv()._ZX_PingCache = raw
            if type(raw) == "number" and raw > 0 then
                table.insert(_zxPingSamples, raw)
                if #_zxPingSamples > 8 then table.remove(_zxPingSamples, 1) end
                local sorted = table.clone(_zxPingSamples)
                table.sort(sorted)
                local median = sorted[math.ceil(#sorted / 2)]
                local fed = raw
                if raw > median * 2.5 + 30 then
                    fed = median + (raw - median) * 0.15
                end
                local smooth = getgenv()._ZX_PingSmooth
                getgenv()._ZX_PingSmooth = (smooth and (smooth * 0.6 + fed * 0.4)) or fed
            end
        end)
        task.wait(0.25)
    end
end)

getgenv().PullDetection = getgenv().PullDetection or false
getgenv()._ZX_PullActive = getgenv()._ZX_PullActive or false
getgenv()._ZX_PullGen = getgenv()._ZX_PullGen or 0

pcall(function()
    local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net
    local pullRemote = net:FindFirstChild("RE/PlrPulled") or net:FindFirstChild("RE/PlrPulsed")
    if pullRemote then
        pullRemote.OnClientEvent:Connect(function(a, b)
            local isMe = false
            local flag = true
            if typeof(a) == "Instance" and a:IsA("Player") then
                isMe = (a == LocalPlayer or a.Name == LocalPlayer.Name)
                if type(b) == "boolean" then flag = b end
            elseif type(a) == "string" then
                isMe = (a == LocalPlayer.Name)
                if type(b) == "boolean" then flag = b end
            elseif type(a) == "boolean" then
                flag = a
                isMe = true
            elseif type(b) == "boolean" then
                flag = b
                isMe = true
            end
            if not isMe then return end
            getgenv()._ZX_PullGen = getgenv()._ZX_PullGen + 1
            local _zxPullMyGen = getgenv()._ZX_PullGen
            if not flag then
                getgenv()._ZX_PullActive = false
                if System and System.__properties then
                    System.__properties.__pull_active = false
                end
                return
            end
            getgenv()._ZX_PullActive = true
            if System and System.__properties then
                System.__properties.__pull_active = true
            end
            task.delay(2, function()
                if getgenv()._ZX_PullGen == _zxPullMyGen then
                    getgenv()._ZX_PullActive = false
                    if System and System.__properties then
                        System.__properties.__pull_active = false
                    end
                end
            end)
        end)
    end
end)

local _orig_autoparry_start = System.autoparry.start
System.autoparry.start = function()
    _orig_autoparry_start()
    if not System.__properties.__pull_active then
        System.__properties.__pull_active = false
    end
    if not System.__properties.__dribble_active then
        System.__properties.__dribble_active = false
    end
end

task.spawn(function()
    while true do
        pcall(function()
            if System and System.__properties then
                System.__properties.__pull_active = getgenv()._ZX_PullActive or false
            end
        end)
        task.wait(0.2)
    end
end)

local SETTINGS_FILE = "EclipseNexusSetting.json"
local ApplyLoadedState
local function SaveSettings(data)
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if success then
        writefile(SETTINGS_FILE, encoded)
    else
    end
end

local function LoadSettings()
    if isfile(SETTINGS_FILE) then
        local content = readfile(SETTINGS_FILE)
        if content and content ~= "" then
            local success, decoded = pcall(function()
                return HttpService:JSONDecode(content)
            end)
            if success then
                return decoded
            else
            end
        end
    end
    return nil
end

do
    local CurrentCamera = workspace.CurrentCamera;
    local LocalPlayer = Players.LocalPlayer;
    local Mouse = LocalPlayer:GetMouse();

    ENXUI.ProtectGui = protect_gui or protectgui or (syn and syn.protect_gui) or function() end;
    ENXUI.MinimumTabSize = 535;

    ENXUI.Connections = {};
    ENXUI.Guis = {};
    ENXUI.Cleanups = {};

    function ENXUI:Track(conn)
        table.insert(ENXUI.Connections, conn);
        return conn;
    end;

    function ENXUI:IsMouseOverFrame(Frame)
        local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;
        if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then
            return true;
        end;
    end;

    function ENXUI:NewInput(frame, call)
        local Bth = Instance.new('TextButton',frame);
        Bth.ZIndex = frame.ZIndex + 10;
        Bth.Size = UDim2.fromScale(1,1);
        Bth.BackgroundTransparency = 1;
        Bth.TextTransparency = 1;
        if call then
            Bth.MouseButton1Click:Connect(call)
        end
        return Bth;
    end;

    ENXUI.Lucide = {
        ["lucide-accessibility"] = "rbxassetid://10709751939",
        ["lucide-activity"] = "rbxassetid://10709752035",
        ["lucide-air-vent"] = "rbxassetid://10709752131",
        ["lucide-airplay"] = "rbxassetid://10709752254",
        ["lucide-alarm-check"] = "rbxassetid://10709752405",
        ["lucide-alarm-clock"] = "rbxassetid://10709752630",
        ["lucide-alarm-clock-off"] = "rbxassetid://10709752508",
        ["lucide-alarm-minus"] = "rbxassetid://10709752732",
        ["lucide-alarm-plus"] = "rbxassetid://10709752825",
        ["lucide-album"] = "rbxassetid://10709752906",
        ["lucide-alert-circle"] = "rbxassetid://10709752996",
        ["lucide-alert-octagon"] = "rbxassetid://10709753064",
        ["lucide-alert-triangle"] = "rbxassetid://10709753149",
        ["lucide-align-center"] = "rbxassetid://10709753570",
        ["lucide-align-center-horizontal"] = "rbxassetid://10709753272",
        ["lucide-align-center-vertical"] = "rbxassetid://10709753421",
        ["lucide-align-end-horizontal"] = "rbxassetid://10709753692",
        ["lucide-align-end-vertical"] = "rbxassetid://10709753808",
        ["lucide-align-horizontal-distribute-center"] = "rbxassetid://10747779791",
        ["lucide-align-horizontal-distribute-end"] = "rbxassetid://10747784534",
        ["lucide-align-horizontal-distribute-start"] = "rbxassetid://10709754118",
        ["lucide-align-horizontal-justify-center"] = "rbxassetid://10709754204",
        ["lucide-align-horizontal-justify-end"] = "rbxassetid://10709754317",
        ["lucide-align-horizontal-justify-start"] = "rbxassetid://10709754436",
        ["lucide-align-horizontal-space-around"] = "rbxassetid://10709754590",
        ["lucide-align-horizontal-space-between"] = "rbxassetid://10709754749",
        ["lucide-align-justify"] = "rbxassetid://10709759610",
        ["lucide-align-left"] = "rbxassetid://10709759764",
        ["lucide-align-right"] = "rbxassetid://10709759895",
        ["lucide-align-start-horizontal"] = "rbxassetid://10709760051",
        ["lucide-align-start-vertical"] = "rbxassetid://10709760244",
        ["lucide-align-vertical-distribute-center"] = "rbxassetid://10709760351",
        ["lucide-align-vertical-distribute-end"] = "rbxassetid://10709760434",
        ["lucide-align-vertical-distribute-start"] = "rbxassetid://10709760612",
        ["lucide-align-vertical-justify-center"] = "rbxassetid://10709760814",
        ["lucide-align-vertical-justify-end"] = "rbxassetid://10709761003",
        ["lucide-align-vertical-justify-start"] = "rbxassetid://10709761176",
        ["lucide-align-vertical-space-around"] = "rbxassetid://10709761324",
        ["lucide-align-vertical-space-between"] = "rbxassetid://10709761434",
        ["lucide-anchor"] = "rbxassetid://10709761530",
        ["lucide-angry"] = "rbxassetid://10709761629",
        ["lucide-annoyed"] = "rbxassetid://10709761722",
        ["lucide-aperture"] = "rbxassetid://10709761813",
        ["lucide-apple"] = "rbxassetid://10709761889",
        ["lucide-archive"] = "rbxassetid://10709762233",
        ["lucide-archive-restore"] = "rbxassetid://10709762058",
        ["lucide-armchair"] = "rbxassetid://10709762327",
        ["lucide-arrow-big-down"] = "rbxassetid://10747796644",
        ["lucide-arrow-big-left"] = "rbxassetid://10709762574",
        ["lucide-arrow-big-right"] = "rbxassetid://10709762727",
        ["lucide-arrow-big-up"] = "rbxassetid://10709762879",
        ["lucide-arrow-down"] = "rbxassetid://10709767827",
        ["lucide-arrow-down-circle"] = "rbxassetid://10709763034",
        ["lucide-arrow-down-left"] = "rbxassetid://10709767656",
        ["lucide-arrow-down-right"] = "rbxassetid://10709767750",
        ["lucide-arrow-left"] = "rbxassetid://10709768114",
        ["lucide-arrow-left-circle"] = "rbxassetid://10709767936",
        ["lucide-arrow-left-right"] = "rbxassetid://10709768019",
        ["lucide-arrow-right"] = "rbxassetid://10709768347",
        ["lucide-arrow-right-circle"] = "rbxassetid://10709768226",
        ["lucide-arrow-up"] = "rbxassetid://10709768939",
        ["lucide-arrow-up-circle"] = "rbxassetid://10709768432",
        ["lucide-arrow-up-down"] = "rbxassetid://10709768538",
        ["lucide-arrow-up-left"] = "rbxassetid://10709768661",
        ["lucide-arrow-up-right"] = "rbxassetid://10709768787",
        ["lucide-asterisk"] = "rbxassetid://10709769095",
        ["lucide-at-sign"] = "rbxassetid://10709769286",
        ["lucide-award"] = "rbxassetid://10709769406",
        ["lucide-axe"] = "rbxassetid://10709769508",
        ["lucide-axis-3d"] = "rbxassetid://10709769598",
        ["lucide-baby"] = "rbxassetid://10709769732",
        ["lucide-backpack"] = "rbxassetid://10709769841",
        ["lucide-baggage-claim"] = "rbxassetid://10709769935",
        ["lucide-banana"] = "rbxassetid://10709770005",
        ["lucide-banknote"] = "rbxassetid://10709770178",
        ["lucide-bar-chart"] = "rbxassetid://10709773755",
        ["lucide-bar-chart-2"] = "rbxassetid://10709770317",
        ["lucide-bar-chart-3"] = "rbxassetid://10709770431",
        ["lucide-bar-chart-4"] = "rbxassetid://10709770560",
        ["lucide-bar-chart-horizontal"] = "rbxassetid://10709773669",
        ["lucide-barcode"] = "rbxassetid://10747360675",
        ["lucide-baseline"] = "rbxassetid://10709773863",
        ["lucide-bath"] = "rbxassetid://10709773963",
        ["lucide-battery"] = "rbxassetid://10709774640",
        ["lucide-battery-charging"] = "rbxassetid://10709774068",
        ["lucide-battery-full"] = "rbxassetid://10709774206",
        ["lucide-battery-low"] = "rbxassetid://10709774370",
        ["lucide-battery-medium"] = "rbxassetid://10709774513",
        ["lucide-beaker"] = "rbxassetid://10709774756",
        ["lucide-bed"] = "rbxassetid://10709775036",
        ["lucide-bed-double"] = "rbxassetid://10709774864",
        ["lucide-bed-single"] = "rbxassetid://10709774968",
        ["lucide-beer"] = "rbxassetid://10709775167",
        ["lucide-bell"] = "rbxassetid://10709775704",
        ["lucide-bell-minus"] = "rbxassetid://10709775241",
        ["lucide-bell-off"] = "rbxassetid://10709775320",
        ["lucide-bell-plus"] = "rbxassetid://10709775448",
        ["lucide-bell-ring"] = "rbxassetid://10709775560",
        ["lucide-bike"] = "rbxassetid://10709775894",
        ["lucide-binary"] = "rbxassetid://10709776050",
        ["lucide-bitcoin"] = "rbxassetid://10709776126",
        ["lucide-bluetooth"] = "rbxassetid://10709776655",
        ["lucide-bluetooth-connected"] = "rbxassetid://10709776240",
        ["lucide-bluetooth-off"] = "rbxassetid://10709776344",
        ["lucide-bluetooth-searching"] = "rbxassetid://10709776501",
        ["lucide-bold"] = "rbxassetid://10747813908",
        ["lucide-bomb"] = "rbxassetid://10709781460",
        ["lucide-bone"] = "rbxassetid://10709781605",
        ["lucide-book"] = "rbxassetid://10709781824",
        ["lucide-book-open"] = "rbxassetid://10709781717",
        ["lucide-bookmark"] = "rbxassetid://10709782154",
        ["lucide-bookmark-minus"] = "rbxassetid://10709781919",
        ["lucide-bookmark-plus"] = "rbxassetid://10709782044",
        ["lucide-bot"] = "rbxassetid://10709782230",
        ["lucide-box"] = "rbxassetid://10709782497",
        ["lucide-box-select"] = "rbxassetid://10709782342",
        ["lucide-boxes"] = "rbxassetid://10709782582",
        ["lucide-briefcase"] = "rbxassetid://10709782662",
        ["lucide-brush"] = "rbxassetid://10709782758",
        ["lucide-bug"] = "rbxassetid://10709782845",
        ["lucide-building"] = "rbxassetid://10709783051",
        ["lucide-building-2"] = "rbxassetid://10709782939",
        ["lucide-bus"] = "rbxassetid://10709783137",
        ["lucide-cake"] = "rbxassetid://10709783217",
        ["lucide-calculator"] = "rbxassetid://10709783311",
        ["lucide-calendar"] = "rbxassetid://10709789505",
        ["lucide-calendar-check"] = "rbxassetid://10709783474",
        ["lucide-calendar-check-2"] = "rbxassetid://10709783392",
        ["lucide-calendar-clock"] = "rbxassetid://10709783577",
        ["lucide-calendar-days"] = "rbxassetid://10709783673",
        ["lucide-calendar-heart"] = "rbxassetid://10709783835",
        ["lucide-calendar-minus"] = "rbxassetid://10709783959",
        ["lucide-calendar-off"] = "rbxassetid://10709788784",
        ["lucide-calendar-plus"] = "rbxassetid://10709788937",
        ["lucide-calendar-range"] = "rbxassetid://10709789053",
        ["lucide-calendar-search"] = "rbxassetid://10709789200",
        ["lucide-calendar-x"] = "rbxassetid://10709789407",
        ["lucide-calendar-x-2"] = "rbxassetid://10709789329",
        ["lucide-camera"] = "rbxassetid://10709789686",
        ["lucide-camera-off"] = "rbxassetid://10747822677",
        ["lucide-car"] = "rbxassetid://10709789810",
        ["lucide-carrot"] = "rbxassetid://10709789960",
        ["lucide-cast"] = "rbxassetid://10709790097",
        ["lucide-charge"] = "rbxassetid://10709790202",
        ["lucide-check"] = "rbxassetid://10709790644",
        ["lucide-check-circle"] = "rbxassetid://10709790387",
        ["lucide-check-circle-2"] = "rbxassetid://10709790298",
        ["lucide-check-square"] = "rbxassetid://10709790537",
        ["lucide-chef-hat"] = "rbxassetid://10709790757",
        ["lucide-cherry"] = "rbxassetid://10709790875",
        ["lucide-chevron-down"] = "rbxassetid://10709790948",
        ["lucide-chevron-first"] = "rbxassetid://10709791015",
        ["lucide-chevron-last"] = "rbxassetid://10709791130",
        ["lucide-chevron-left"] = "rbxassetid://10709791281",
        ["lucide-chevron-right"] = "rbxassetid://10709791437",
        ["lucide-chevron-up"] = "rbxassetid://10709791523",
        ["lucide-chevrons-down"] = "rbxassetid://10709796864",
        ["lucide-chevrons-down-up"] = "rbxassetid://10709791632",
        ["lucide-chevrons-left"] = "rbxassetid://10709797151",
        ["lucide-chevrons-left-right"] = "rbxassetid://10709797006",
        ["lucide-chevrons-right"] = "rbxassetid://10709797382",
        ["lucide-chevrons-right-left"] = "rbxassetid://10709797274",
        ["lucide-chevrons-up"] = "rbxassetid://10709797622",
        ["lucide-chevrons-up-down"] = "rbxassetid://10709797508",
        ["lucide-chrome"] = "rbxassetid://10709797725",
        ["lucide-circle"] = "rbxassetid://10709798174",
        ["lucide-circle-dot"] = "rbxassetid://10709797837",
        ["lucide-circle-ellipsis"] = "rbxassetid://10709797985",
        ["lucide-circle-slashed"] = "rbxassetid://10709798100",
        ["lucide-citrus"] = "rbxassetid://10709798276",
        ["lucide-clapperboard"] = "rbxassetid://10709798350",
        ["lucide-clipboard"] = "rbxassetid://10709799288",
        ["lucide-clipboard-check"] = "rbxassetid://10709798443",
        ["lucide-clipboard-copy"] = "rbxassetid://10709798574",
        ["lucide-clipboard-edit"] = "rbxassetid://10709798682",
        ["lucide-clipboard-list"] = "rbxassetid://10709798792",
        ["lucide-clipboard-signature"] = "rbxassetid://10709798890",
        ["lucide-clipboard-type"] = "rbxassetid://10709798999",
        ["lucide-clipboard-x"] = "rbxassetid://10709799124",
        ["lucide-clock"] = "rbxassetid://10709805144",
        ["lucide-clock-1"] = "rbxassetid://10709799535",
        ["lucide-clock-10"] = "rbxassetid://10709799718",
        ["lucide-clock-11"] = "rbxassetid://10709799818",
        ["lucide-clock-12"] = "rbxassetid://10709799962",
        ["lucide-clock-2"] = "rbxassetid://10709803876",
        ["lucide-clock-3"] = "rbxassetid://10709803989",
        ["lucide-clock-4"] = "rbxassetid://10709804164",
        ["lucide-clock-5"] = "rbxassetid://10709804291",
        ["lucide-clock-6"] = "rbxassetid://10709804435",
        ["lucide-clock-7"] = "rbxassetid://10709804599",
        ["lucide-clock-8"] = "rbxassetid://10709804784",
        ["lucide-clock-9"] = "rbxassetid://10709804996",
        ["lucide-cloud"] = "rbxassetid://10709806740",
        ["lucide-cloud-cog"] = "rbxassetid://10709805262",
        ["lucide-cloud-drizzle"] = "rbxassetid://10709805371",
        ["lucide-cloud-fog"] = "rbxassetid://10709805477",
        ["lucide-cloud-hail"] = "rbxassetid://10709805596",
        ["lucide-cloud-lightning"] = "rbxassetid://10709805727",
        ["lucide-cloud-moon"] = "rbxassetid://10709805942",
        ["lucide-cloud-moon-rain"] = "rbxassetid://10709805838",
        ["lucide-cloud-off"] = "rbxassetid://10709806060",
        ["lucide-cloud-rain"] = "rbxassetid://10709806277",
        ["lucide-cloud-rain-wind"] = "rbxassetid://10709806166",
        ["lucide-cloud-snow"] = "rbxassetid://10709806374",
        ["lucide-cloud-sun"] = "rbxassetid://10709806631",
        ["lucide-cloud-sun-rain"] = "rbxassetid://10709806475",
        ["lucide-cloudy"] = "rbxassetid://10709806859",
        ["lucide-clover"] = "rbxassetid://10709806995",
        ["lucide-code"] = "rbxassetid://10709810463",
        ["lucide-code-2"] = "rbxassetid://10709807111",
        ["lucide-codepen"] = "rbxassetid://10709810534",
        ["lucide-codesandbox"] = "rbxassetid://10709810676",
        ["lucide-coffee"] = "rbxassetid://10709810814",
        ["lucide-cog"] = "rbxassetid://10709810948",
        ["lucide-coins"] = "rbxassetid://10709811110",
        ["lucide-columns"] = "rbxassetid://10709811261",
        ["lucide-command"] = "rbxassetid://10709811365",
        ["lucide-compass"] = "rbxassetid://10709811445",
        ["lucide-component"] = "rbxassetid://10709811595",
        ["lucide-concierge-bell"] = "rbxassetid://10709811706",
        ["lucide-connection"] = "rbxassetid://10747361219",
        ["lucide-contact"] = "rbxassetid://10709811834",
        ["lucide-contrast"] = "rbxassetid://10709811939",
        ["lucide-cookie"] = "rbxassetid://10709812067",
        ["lucide-copy"] = "rbxassetid://10709812159",
        ["lucide-copyleft"] = "rbxassetid://10709812251",
        ["lucide-copyright"] = "rbxassetid://10709812311",
        ["lucide-corner-down-left"] = "rbxassetid://10709812396",
        ["lucide-corner-down-right"] = "rbxassetid://10709812485",
        ["lucide-corner-left-down"] = "rbxassetid://10709812632",
        ["lucide-corner-left-up"] = "rbxassetid://10709812784",
        ["lucide-corner-right-down"] = "rbxassetid://10709812939",
        ["lucide-corner-right-up"] = "rbxassetid://10709813094",
        ["lucide-corner-up-left"] = "rbxassetid://10709813185",
        ["lucide-corner-up-right"] = "rbxassetid://10709813281",
        ["lucide-cpu"] = "rbxassetid://10709813383",
        ["lucide-croissant"] = "rbxassetid://10709818125",
        ["lucide-crop"] = "rbxassetid://10709818245",
        ["lucide-cross"] = "rbxassetid://10709818399",
        ["lucide-crosshair"] = "rbxassetid://10709818534",
        ["lucide-crown"] = "rbxassetid://10709818626",
        ["lucide-cup-soda"] = "rbxassetid://10709818763",
        ["lucide-curly-braces"] = "rbxassetid://10709818847",
        ["lucide-currency"] = "rbxassetid://10709818931",
        ["lucide-database"] = "rbxassetid://10709818996",
        ["lucide-delete"] = "rbxassetid://10709819059",
        ["lucide-diamond"] = "rbxassetid://10709819149",
        ["lucide-dice-1"] = "rbxassetid://10709819266",
        ["lucide-dice-2"] = "rbxassetid://10709819361",
        ["lucide-dice-3"] = "rbxassetid://10709819508",
        ["lucide-dice-4"] = "rbxassetid://10709819670",
        ["lucide-dice-5"] = "rbxassetid://10709819801",
        ["lucide-dice-6"] = "rbxassetid://10709819896",
        ["lucide-dices"] = "rbxassetid://10723343321",
        ["lucide-diff"] = "rbxassetid://10723343416",
        ["lucide-disc"] = "rbxassetid://10723343537",
        ["lucide-divide"] = "rbxassetid://10723343805",
        ["lucide-divide-circle"] = "rbxassetid://10723343636",
        ["lucide-divide-square"] = "rbxassetid://10723343737",
        ["lucide-dollar-sign"] = "rbxassetid://10723343958",
        ["lucide-download"] = "rbxassetid://10723344270",
        ["lucide-download-cloud"] = "rbxassetid://10723344088",
        ["lucide-droplet"] = "rbxassetid://10723344432",
        ["lucide-droplets"] = "rbxassetid://10734883356",
        ["lucide-drumstick"] = "rbxassetid://10723344737",
        ["lucide-edit"] = "rbxassetid://10734883598",
        ["lucide-edit-2"] = "rbxassetid://10723344885",
        ["lucide-edit-3"] = "rbxassetid://10723345088",
        ["lucide-egg"] = "rbxassetid://10723345518",
        ["lucide-egg-fried"] = "rbxassetid://10723345347",
        ["lucide-electricity"] = "rbxassetid://10723345749",
        ["lucide-electricity-off"] = "rbxassetid://10723345643",
        ["lucide-equal"] = "rbxassetid://10723345990",
        ["lucide-equal-not"] = "rbxassetid://10723345866",
        ["lucide-eraser"] = "rbxassetid://10723346158",
        ["lucide-euro"] = "rbxassetid://10723346372",
        ["lucide-expand"] = "rbxassetid://10723346553",
        ["lucide-external-link"] = "rbxassetid://10723346684",
        ["lucide-eye"] = "rbxassetid://10723346959",
        ["lucide-eye-off"] = "rbxassetid://10723346871",
        ["lucide-factory"] = "rbxassetid://10723347051",
        ["lucide-fan"] = "rbxassetid://10723354359",
        ["lucide-fast-forward"] = "rbxassetid://10723354521",
        ["lucide-feather"] = "rbxassetid://10723354671",
        ["lucide-figma"] = "rbxassetid://10723354801",
        ["lucide-file"] = "rbxassetid://10723374641",
        ["lucide-file-archive"] = "rbxassetid://10723354921",
        ["lucide-file-audio"] = "rbxassetid://10723355148",
        ["lucide-file-audio-2"] = "rbxassetid://10723355026",
        ["lucide-file-axis-3d"] = "rbxassetid://10723355272",
        ["lucide-file-badge"] = "rbxassetid://10723355622",
        ["lucide-file-badge-2"] = "rbxassetid://10723355451",
        ["lucide-file-bar-chart"] = "rbxassetid://10723355887",
        ["lucide-file-bar-chart-2"] = "rbxassetid://10723355746",
        ["lucide-file-box"] = "rbxassetid://10723355989",
        ["lucide-file-check"] = "rbxassetid://10723356210",
        ["lucide-file-check-2"] = "rbxassetid://10723356100",
        ["lucide-file-clock"] = "rbxassetid://10723356329",
        ["lucide-file-code"] = "rbxassetid://10723356507",
        ["lucide-file-cog"] = "rbxassetid://10723356830",
        ["lucide-file-cog-2"] = "rbxassetid://10723356676",
        ["lucide-file-diff"] = "rbxassetid://10723357039",
        ["lucide-file-digit"] = "rbxassetid://10723357151",
        ["lucide-file-down"] = "rbxassetid://10723357322",
        ["lucide-file-edit"] = "rbxassetid://10723357495",
        ["lucide-file-heart"] = "rbxassetid://10723357637",
        ["lucide-file-image"] = "rbxassetid://10723357790",
        ["lucide-file-input"] = "rbxassetid://10723357933",
        ["lucide-file-json"] = "rbxassetid://10723364435",
        ["lucide-file-json-2"] = "rbxassetid://10723364361",
        ["lucide-file-key"] = "rbxassetid://10723364605",
        ["lucide-file-key-2"] = "rbxassetid://10723364515",
        ["lucide-file-line-chart"] = "rbxassetid://10723364725",
        ["lucide-file-lock"] = "rbxassetid://10723364957",
        ["lucide-file-lock-2"] = "rbxassetid://10723364861",
        ["lucide-file-minus"] = "rbxassetid://10723365254",
        ["lucide-file-minus-2"] = "rbxassetid://10723365086",
        ["lucide-file-output"] = "rbxassetid://10723365457",
        ["lucide-file-pie-chart"] = "rbxassetid://10723365598",
        ["lucide-file-plus"] = "rbxassetid://10723365877",
        ["lucide-file-plus-2"] = "rbxassetid://10723365766",
        ["lucide-file-question"] = "rbxassetid://10723365987",
        ["lucide-file-scan"] = "rbxassetid://10723366167",
        ["lucide-file-search"] = "rbxassetid://10723366550",
        ["lucide-file-search-2"] = "rbxassetid://10723366340",
        ["lucide-file-signature"] = "rbxassetid://10723366741",
        ["lucide-file-spreadsheet"] = "rbxassetid://10723366962",
        ["lucide-file-symlink"] = "rbxassetid://10723367098",
        ["lucide-file-terminal"] = "rbxassetid://10723367244",
        ["lucide-file-text"] = "rbxassetid://10723367380",
        ["lucide-file-type"] = "rbxassetid://10723367606",
        ["lucide-file-type-2"] = "rbxassetid://10723367509",
        ["lucide-file-up"] = "rbxassetid://10723367734",
        ["lucide-file-video"] = "rbxassetid://10723373884",
        ["lucide-file-video-2"] = "rbxassetid://10723367834",
        ["lucide-file-volume"] = "rbxassetid://10723374172",
        ["lucide-file-volume-2"] = "rbxassetid://10723374030",
        ["lucide-file-warning"] = "rbxassetid://10723374276",
        ["lucide-file-x"] = "rbxassetid://10723374544",
        ["lucide-file-x-2"] = "rbxassetid://10723374378",
        ["lucide-files"] = "rbxassetid://10723374759",
        ["lucide-film"] = "rbxassetid://10723374981",
        ["lucide-filter"] = "rbxassetid://10723375128",
        ["lucide-fingerprint"] = "rbxassetid://10723375250",
        ["lucide-flag"] = "rbxassetid://10723375890",
        ["lucide-flag-off"] = "rbxassetid://10723375443",
        ["lucide-flag-triangle-left"] = "rbxassetid://10723375608",
        ["lucide-flag-triangle-right"] = "rbxassetid://10723375727",
        ["lucide-flame"] = "rbxassetid://10723376114",
        ["lucide-flashlight"] = "rbxassetid://10723376471",
        ["lucide-flashlight-off"] = "rbxassetid://10723376365",
        ["lucide-flask-conical"] = "rbxassetid://10734883986",
        ["lucide-flask-round"] = "rbxassetid://10723376614",
        ["lucide-flip-horizontal"] = "rbxassetid://10723376884",
        ["lucide-flip-horizontal-2"] = "rbxassetid://10723376745",
        ["lucide-flip-vertical"] = "rbxassetid://10723377138",
        ["lucide-flip-vertical-2"] = "rbxassetid://10723377026",
        ["lucide-flower"] = "rbxassetid://10747830374",
        ["lucide-flower-2"] = "rbxassetid://10723377305",
        ["lucide-focus"] = "rbxassetid://10723377537",
        ["lucide-folder"] = "rbxassetid://10723387563",
        ["lucide-folder-archive"] = "rbxassetid://10723384478",
        ["lucide-folder-check"] = "rbxassetid://10723384605",
        ["lucide-folder-clock"] = "rbxassetid://10723384731",
        ["lucide-folder-closed"] = "rbxassetid://10723384893",
        ["lucide-folder-cog"] = "rbxassetid://10723385213",
        ["lucide-folder-cog-2"] = "rbxassetid://10723385036",
        ["lucide-folder-down"] = "rbxassetid://10723385338",
        ["lucide-folder-edit"] = "rbxassetid://10723385445",
        ["lucide-folder-heart"] = "rbxassetid://10723385545",
        ["lucide-folder-input"] = "rbxassetid://10723385721",
        ["lucide-folder-key"] = "rbxassetid://10723385848",
        ["lucide-folder-lock"] = "rbxassetid://10723386005",
        ["lucide-folder-minus"] = "rbxassetid://10723386127",
        ["lucide-folder-open"] = "rbxassetid://10723386277",
        ["lucide-folder-output"] = "rbxassetid://10723386386",
        ["lucide-folder-plus"] = "rbxassetid://10723386531",
        ["lucide-folder-search"] = "rbxassetid://10723386787",
        ["lucide-folder-search-2"] = "rbxassetid://10723386674",
        ["lucide-folder-symlink"] = "rbxassetid://10723386930",
        ["lucide-folder-tree"] = "rbxassetid://10723387085",
        ["lucide-folder-up"] = "rbxassetid://10723387265",
        ["lucide-folder-x"] = "rbxassetid://10723387448",
        ["lucide-folders"] = "rbxassetid://10723387721",
        ["lucide-form-input"] = "rbxassetid://10723387841",
        ["lucide-forward"] = "rbxassetid://10723388016",
        ["lucide-frame"] = "rbxassetid://10723394389",
        ["lucide-framer"] = "rbxassetid://10723394565",
        ["lucide-frown"] = "rbxassetid://10723394681",
        ["lucide-fuel"] = "rbxassetid://10723394846",
        ["lucide-function-square"] = "rbxassetid://10723395041",
        ["lucide-gamepad"] = "rbxassetid://10723395457",
        ["lucide-gamepad-2"] = "rbxassetid://10723395215",
        ["lucide-gauge"] = "rbxassetid://10723395708",
        ["lucide-gavel"] = "rbxassetid://10723395896",
        ["lucide-gem"] = "rbxassetid://10723396000",
        ["lucide-ghost"] = "rbxassetid://10723396107",
        ["lucide-gift"] = "rbxassetid://10723396402",
        ["lucide-gift-card"] = "rbxassetid://10723396225",
        ["lucide-git-branch"] = "rbxassetid://10723396676",
        ["lucide-git-branch-plus"] = "rbxassetid://10723396542",
        ["lucide-git-commit"] = "rbxassetid://10723396812",
        ["lucide-git-compare"] = "rbxassetid://10723396954",
        ["lucide-git-fork"] = "rbxassetid://10723397049",
        ["lucide-git-merge"] = "rbxassetid://10723397165",
        ["lucide-git-pull-request"] = "rbxassetid://10723397431",
        ["lucide-git-pull-request-closed"] = "rbxassetid://10723397268",
        ["lucide-git-pull-request-draft"] = "rbxassetid://10734884302",
        ["lucide-glass"] = "rbxassetid://10723397788",
        ["lucide-glass-2"] = "rbxassetid://10723397529",
        ["lucide-glass-water"] = "rbxassetid://10723397678",
        ["lucide-glasses"] = "rbxassetid://10723397895",
        ["lucide-globe"] = "rbxassetid://10723404337",
        ["lucide-globe-2"] = "rbxassetid://10723398002",
        ["lucide-grab"] = "rbxassetid://10723404472",
        ["lucide-graduation-cap"] = "rbxassetid://10723404691",
        ["lucide-grape"] = "rbxassetid://10723404822",
        ["lucide-grid"] = "rbxassetid://10723404936",
        ["lucide-grip-horizontal"] = "rbxassetid://10723405089",
        ["lucide-grip-vertical"] = "rbxassetid://10723405236",
        ["lucide-hammer"] = "rbxassetid://10723405360",
        ["lucide-hand"] = "rbxassetid://10723405649",
        ["lucide-hand-metal"] = "rbxassetid://10723405508",
        ["lucide-hard-drive"] = "rbxassetid://10723405749",
        ["lucide-hard-hat"] = "rbxassetid://10723405859",
        ["lucide-hash"] = "rbxassetid://10723405975",
        ["lucide-haze"] = "rbxassetid://10723406078",
        ["lucide-headphones"] = "rbxassetid://10723406165",
        ["lucide-heart"] = "rbxassetid://10723406885",
        ["lucide-heart-crack"] = "rbxassetid://10723406299",
        ["lucide-heart-handshake"] = "rbxassetid://10723406480",
        ["lucide-heart-off"] = "rbxassetid://10723406662",
        ["lucide-heart-pulse"] = "rbxassetid://10723406795",
        ["lucide-help-circle"] = "rbxassetid://10723406988",
        ["lucide-hexagon"] = "rbxassetid://10723407092",
        ["lucide-highlighter"] = "rbxassetid://10723407192",
        ["lucide-history"] = "rbxassetid://10723407335",
        ["lucide-home"] = "rbxassetid://10723407389",
        ["lucide-hourglass"] = "rbxassetid://10723407498",
        ["lucide-ice-cream"] = "rbxassetid://10723414308",
        ["lucide-image"] = "rbxassetid://10723415040",
        ["lucide-image-minus"] = "rbxassetid://10723414487",
        ["lucide-image-off"] = "rbxassetid://10723414677",
        ["lucide-image-plus"] = "rbxassetid://10723414827",
        ["lucide-import"] = "rbxassetid://10723415205",
        ["lucide-inbox"] = "rbxassetid://10723415335",
        ["lucide-indent"] = "rbxassetid://10723415494",
        ["lucide-indian-rupee"] = "rbxassetid://10723415642",
        ["lucide-infinity"] = "rbxassetid://10723415766",
        ["lucide-info"] = "rbxassetid://10723415903",
        ["lucide-inspect"] = "rbxassetid://10723416057",
        ["lucide-italic"] = "rbxassetid://10723416195",
        ["lucide-japanese-yen"] = "rbxassetid://10723416363",
        ["lucide-joystick"] = "rbxassetid://10723416527",
        ["lucide-key"] = "rbxassetid://10723416652",
        ["lucide-keyboard"] = "rbxassetid://10723416765",
        ["lucide-lamp"] = "rbxassetid://10723417513",
        ["lucide-lamp-ceiling"] = "rbxassetid://10723416922",
        ["lucide-lamp-desk"] = "rbxassetid://10723417016",
        ["lucide-lamp-floor"] = "rbxassetid://10723417131",
        ["lucide-lamp-wall-down"] = "rbxassetid://10723417240",
        ["lucide-lamp-wall-up"] = "rbxassetid://10723417356",
        ["lucide-landmark"] = "rbxassetid://10723417608",
        ["lucide-languages"] = "rbxassetid://10723417703",
        ["lucide-laptop"] = "rbxassetid://10723423881",
        ["lucide-laptop-2"] = "rbxassetid://10723417797",
        ["lucide-lasso"] = "rbxassetid://10723424235",
        ["lucide-lasso-select"] = "rbxassetid://10723424058",
        ["lucide-laugh"] = "rbxassetid://10723424372",
        ["lucide-layers"] = "rbxassetid://10723424505",
        ["lucide-layout"] = "rbxassetid://10723425376",
        ["lucide-layout-dashboard"] = "rbxassetid://10723424646",
        ["lucide-layout-grid"] = "rbxassetid://10723424838",
        ["lucide-layout-list"] = "rbxassetid://10723424963",
        ["lucide-layout-template"] = "rbxassetid://10723425187",
        ["lucide-leaf"] = "rbxassetid://10723425539",
        ["lucide-library"] = "rbxassetid://10723425615",
        ["lucide-life-buoy"] = "rbxassetid://10723425685",
        ["lucide-lightbulb"] = "rbxassetid://10723425852",
        ["lucide-lightbulb-off"] = "rbxassetid://10723425762",
        ["lucide-line-chart"] = "rbxassetid://10723426393",
        ["lucide-link"] = "rbxassetid://10723426722",
        ["lucide-link-2"] = "rbxassetid://10723426595",
        ["lucide-link-2-off"] = "rbxassetid://10723426513",
        ["lucide-list"] = "rbxassetid://10723433811",
        ["lucide-list-checks"] = "rbxassetid://10734884548",
        ["lucide-list-end"] = "rbxassetid://10723426886",
        ["lucide-list-minus"] = "rbxassetid://10723426986",
        ["lucide-list-music"] = "rbxassetid://10723427081",
        ["lucide-list-ordered"] = "rbxassetid://10723427199",
        ["lucide-list-plus"] = "rbxassetid://10723427334",
        ["lucide-list-start"] = "rbxassetid://10723427494",
        ["lucide-list-video"] = "rbxassetid://10723427619",
        ["lucide-list-x"] = "rbxassetid://10723433655",
        ["lucide-loader"] = "rbxassetid://10723434070",
        ["lucide-loader-2"] = "rbxassetid://10723433935",
        ["lucide-locate"] = "rbxassetid://10723434557",
        ["lucide-locate-fixed"] = "rbxassetid://10723434236",
        ["lucide-locate-off"] = "rbxassetid://10723434379",
        ["lucide-lock"] = "rbxassetid://10723434711",
        ["lucide-log-in"] = "rbxassetid://10723434830",
        ["lucide-log-out"] = "rbxassetid://10723434906",
        ["lucide-luggage"] = "rbxassetid://10723434993",
        ["lucide-magnet"] = "rbxassetid://10723435069",
        ["lucide-mail"] = "rbxassetid://10734885430",
        ["lucide-mail-check"] = "rbxassetid://10723435182",
        ["lucide-mail-minus"] = "rbxassetid://10723435261",
        ["lucide-mail-open"] = "rbxassetid://10723435342",
        ["lucide-mail-plus"] = "rbxassetid://10723435443",
        ["lucide-mail-question"] = "rbxassetid://10723435515",
        ["lucide-mail-search"] = "rbxassetid://10734884739",
        ["lucide-mail-warning"] = "rbxassetid://10734885015",
        ["lucide-mail-x"] = "rbxassetid://10734885247",
        ["lucide-mails"] = "rbxassetid://10734885614",
        ["lucide-map"] = "rbxassetid://10734886202",
        ["lucide-map-pin"] = "rbxassetid://10734886004",
        ["lucide-map-pin-off"] = "rbxassetid://10734885803",
        ["lucide-maximize"] = "rbxassetid://10734886735",
        ["lucide-maximize-2"] = "rbxassetid://10734886496",
        ["lucide-medal"] = "rbxassetid://10734887072",
        ["lucide-megaphone"] = "rbxassetid://10734887454",
        ["lucide-megaphone-off"] = "rbxassetid://10734887311",
        ["lucide-meh"] = "rbxassetid://10734887603",
        ["lucide-menu"] = "rbxassetid://10734887784",
        ["lucide-message-circle"] = "rbxassetid://10734888000",
        ["lucide-message-square"] = "rbxassetid://10734888228",
        ["lucide-mic"] = "rbxassetid://10734888864",
        ["lucide-mic-2"] = "rbxassetid://10734888430",
        ["lucide-mic-off"] = "rbxassetid://10734888646",
        ["lucide-microscope"] = "rbxassetid://10734889106",
        ["lucide-microwave"] = "rbxassetid://10734895076",
        ["lucide-milestone"] = "rbxassetid://10734895310",
        ["lucide-minimize"] = "rbxassetid://10734895698",
        ["lucide-minimize-2"] = "rbxassetid://10734895530",
        ["lucide-minus"] = "rbxassetid://10734896206",
        ["lucide-minus-circle"] = "rbxassetid://10734895856",
        ["lucide-minus-square"] = "rbxassetid://10734896029",
        ["lucide-monitor"] = "rbxassetid://10734896881",
        ["lucide-monitor-off"] = "rbxassetid://10734896360",
        ["lucide-monitor-speaker"] = "rbxassetid://10734896512",
        ["lucide-moon"] = "rbxassetid://10734897102",
        ["lucide-more-horizontal"] = "rbxassetid://10734897250",
        ["lucide-more-vertical"] = "rbxassetid://10734897387",
        ["lucide-mountain"] = "rbxassetid://10734897956",
        ["lucide-mountain-snow"] = "rbxassetid://10734897665",
        ["lucide-mouse"] = "rbxassetid://10734898592",
        ["lucide-mouse-pointer"] = "rbxassetid://10734898476",
        ["lucide-mouse-pointer-2"] = "rbxassetid://10734898194",
        ["lucide-mouse-pointer-click"] = "rbxassetid://10734898355",
        ["lucide-move"] = "rbxassetid://10734900011",
        ["lucide-move-3d"] = "rbxassetid://10734898756",
        ["lucide-move-diagonal"] = "rbxassetid://10734899164",
        ["lucide-move-diagonal-2"] = "rbxassetid://10734898934",
        ["lucide-move-horizontal"] = "rbxassetid://10734899414",
        ["lucide-move-vertical"] = "rbxassetid://10734899821",
        ["lucide-music"] = "rbxassetid://10734905958",
        ["lucide-music-2"] = "rbxassetid://10734900215",
        ["lucide-music-3"] = "rbxassetid://10734905665",
        ["lucide-music-4"] = "rbxassetid://10734905823",
        ["lucide-navigation"] = "rbxassetid://10734906744",
        ["lucide-navigation-2"] = "rbxassetid://10734906332",
        ["lucide-navigation-2-off"] = "rbxassetid://10734906144",
        ["lucide-navigation-off"] = "rbxassetid://10734906580",
        ["lucide-network"] = "rbxassetid://10734906975",
        ["lucide-newspaper"] = "rbxassetid://10734907168",
        ["lucide-octagon"] = "rbxassetid://10734907361",
        ["lucide-option"] = "rbxassetid://10734907649",
        ["lucide-outdent"] = "rbxassetid://10734907933",
        ["lucide-package"] = "rbxassetid://10734909540",
        ["lucide-package-2"] = "rbxassetid://10734908151",
        ["lucide-package-check"] = "rbxassetid://10734908384",
        ["lucide-package-minus"] = "rbxassetid://10734908626",
        ["lucide-package-open"] = "rbxassetid://10734908793",
        ["lucide-package-plus"] = "rbxassetid://10734909016",
        ["lucide-package-search"] = "rbxassetid://10734909196",
        ["lucide-package-x"] = "rbxassetid://10734909375",
        ["lucide-paint-bucket"] = "rbxassetid://10734909847",
        ["lucide-paintbrush"] = "rbxassetid://10734910187",
        ["lucide-paintbrush-2"] = "rbxassetid://10734910030",
        ["lucide-palette"] = "rbxassetid://10734910430",
        ["lucide-palmtree"] = "rbxassetid://10734910680",
        ["lucide-paperclip"] = "rbxassetid://10734910927",
        ["lucide-party-popper"] = "rbxassetid://10734918735",
        ["lucide-pause"] = "rbxassetid://10734919336",
        ["lucide-pause-circle"] = "rbxassetid://10735024209",
        ["lucide-pause-octagon"] = "rbxassetid://10734919143",
        ["lucide-pen-tool"] = "rbxassetid://10734919503",
        ["lucide-pencil"] = "rbxassetid://10734919691",
        ["lucide-percent"] = "rbxassetid://10734919919",
        ["lucide-person-standing"] = "rbxassetid://10734920149",
        ["lucide-phone"] = "rbxassetid://10734921524",
        ["lucide-phone-call"] = "rbxassetid://10734920305",
        ["lucide-phone-forwarded"] = "rbxassetid://10734920508",
        ["lucide-phone-incoming"] = "rbxassetid://10734920694",
        ["lucide-phone-missed"] = "rbxassetid://10734920845",
        ["lucide-phone-off"] = "rbxassetid://10734921077",
        ["lucide-phone-outgoing"] = "rbxassetid://10734921288",
        ["lucide-pie-chart"] = "rbxassetid://10734921727",
        ["lucide-piggy-bank"] = "rbxassetid://10734921935",
        ["lucide-pin"] = "rbxassetid://10734922324",
        ["lucide-pin-off"] = "rbxassetid://10734922180",
        ["lucide-pipette"] = "rbxassetid://10734922497",
        ["lucide-pizza"] = "rbxassetid://10734922774",
        ["lucide-plane"] = "rbxassetid://10734922971",
        ["lucide-play"] = "rbxassetid://10734923549",
        ["lucide-play-circle"] = "rbxassetid://10734923214",
        ["lucide-plus"] = "rbxassetid://10734924532",
        ["lucide-plus-circle"] = "rbxassetid://10734923868",
        ["lucide-plus-square"] = "rbxassetid://10734924219",
        ["lucide-podcast"] = "rbxassetid://10734929553",
        ["lucide-pointer"] = "rbxassetid://10734929723",
        ["lucide-pound-sterling"] = "rbxassetid://10734929981",
        ["lucide-power"] = "rbxassetid://10734930466",
        ["lucide-power-off"] = "rbxassetid://10734930257",
        ["lucide-printer"] = "rbxassetid://10734930632",
        ["lucide-puzzle"] = "rbxassetid://10734930886",
        ["lucide-quote"] = "rbxassetid://10734931234",
        ["lucide-radio"] = "rbxassetid://10734931596",
        ["lucide-radio-receiver"] = "rbxassetid://10734931402",
        ["lucide-rectangle-horizontal"] = "rbxassetid://10734931777",
        ["lucide-rectangle-vertical"] = "rbxassetid://10734932081",
        ["lucide-recycle"] = "rbxassetid://10734932295",
        ["lucide-redo"] = "rbxassetid://10734932822",
        ["lucide-redo-2"] = "rbxassetid://10734932586",
        ["lucide-refresh-ccw"] = "rbxassetid://10734933056",
        ["lucide-refresh-cw"] = "rbxassetid://10734933222",
        ["lucide-refrigerator"] = "rbxassetid://10734933465",
        ["lucide-regex"] = "rbxassetid://10734933655",
        ["lucide-repeat"] = "rbxassetid://10734933966",
        ["lucide-repeat-1"] = "rbxassetid://10734933826",
        ["lucide-reply"] = "rbxassetid://10734934252",
        ["lucide-reply-all"] = "rbxassetid://10734934132",
        ["lucide-rewind"] = "rbxassetid://10734934347",
        ["lucide-rocket"] = "rbxassetid://10734934585",
        ["lucide-rocking-chair"] = "rbxassetid://10734939942",
        ["lucide-rotate-3d"] = "rbxassetid://10734940107",
        ["lucide-rotate-ccw"] = "rbxassetid://10734940376",
        ["lucide-rotate-cw"] = "rbxassetid://10734940654",
        ["lucide-rss"] = "rbxassetid://10734940825",
        ["lucide-ruler"] = "rbxassetid://10734941018",
        ["lucide-russian-ruble"] = "rbxassetid://10734941199",
        ["lucide-sailboat"] = "rbxassetid://10734941354",
        ["lucide-save"] = "rbxassetid://10734941499",
        ["lucide-scale"] = "rbxassetid://10734941912",
        ["lucide-scale-3d"] = "rbxassetid://10734941739",
        ["lucide-scaling"] = "rbxassetid://10734942072",
        ["lucide-scan"] = "rbxassetid://10734942565",
        ["lucide-scan-face"] = "rbxassetid://10734942198",
        ["lucide-scan-line"] = "rbxassetid://10734942351",
        ["lucide-scissors"] = "rbxassetid://10734942778",
        ["lucide-screen-share"] = "rbxassetid://10734943193",
        ["lucide-screen-share-off"] = "rbxassetid://10734942967",
        ["lucide-scroll"] = "rbxassetid://10734943448",
        ["lucide-search"] = "rbxassetid://10734943674",
        ["lucide-send"] = "rbxassetid://10734943902",
        ["lucide-separator-horizontal"] = "rbxassetid://10734944115",
        ["lucide-separator-vertical"] = "rbxassetid://10734944326",
        ["lucide-server"] = "rbxassetid://10734949856",
        ["lucide-server-cog"] = "rbxassetid://10734944444",
        ["lucide-server-crash"] = "rbxassetid://10734944554",
        ["lucide-server-off"] = "rbxassetid://10734944668",
        ["lucide-settings"] = "rbxassetid://10734950309",
        ["lucide-settings-2"] = "rbxassetid://10734950020",
        ["lucide-share"] = "rbxassetid://10734950813",
        ["lucide-share-2"] = "rbxassetid://10734950553",
        ["lucide-sheet"] = "rbxassetid://10734951038",
        ["lucide-shield"] = "rbxassetid://10734951847",
        ["lucide-shield-alert"] = "rbxassetid://10734951173",
        ["lucide-shield-check"] = "rbxassetid://10734951367",
        ["lucide-shield-close"] = "rbxassetid://10734951535",
        ["lucide-shield-off"] = "rbxassetid://10734951684",
        ["lucide-shirt"] = "rbxassetid://10734952036",
        ["lucide-shopping-bag"] = "rbxassetid://10734952273",
        ["lucide-shopping-cart"] = "rbxassetid://10734952479",
        ["lucide-shovel"] = "rbxassetid://10734952773",
        ["lucide-shower-head"] = "rbxassetid://10734952942",
        ["lucide-shrink"] = "rbxassetid://10734953073",
        ["lucide-shrub"] = "rbxassetid://10734953241",
        ["lucide-shuffle"] = "rbxassetid://10734953451",
        ["lucide-sidebar"] = "rbxassetid://10734954301",
        ["lucide-sidebar-close"] = "rbxassetid://10734953715",
        ["lucide-sidebar-open"] = "rbxassetid://10734954000",
        ["lucide-sigma"] = "rbxassetid://10734954538",
        ["lucide-signal"] = "rbxassetid://10734961133",
        ["lucide-signal-high"] = "rbxassetid://10734954807",
        ["lucide-signal-low"] = "rbxassetid://10734955080",
        ["lucide-signal-medium"] = "rbxassetid://10734955336",
        ["lucide-signal-zero"] = "rbxassetid://10734960878",
        ["lucide-siren"] = "rbxassetid://10734961284",
        ["lucide-skip-back"] = "rbxassetid://10734961526",
        ["lucide-skip-forward"] = "rbxassetid://10734961809",
        ["lucide-skull"] = "rbxassetid://10734962068",
        ["lucide-slack"] = "rbxassetid://10734962339",
        ["lucide-slash"] = "rbxassetid://10734962600",
        ["lucide-slice"] = "rbxassetid://10734963024",
        ["lucide-sliders"] = "rbxassetid://10734963400",
        ["lucide-sliders-horizontal"] = "rbxassetid://10734963191",
        ["lucide-smartphone"] = "rbxassetid://10734963940",
        ["lucide-smartphone-charging"] = "rbxassetid://10734963671",
        ["lucide-smile"] = "rbxassetid://10734964441",
        ["lucide-smile-plus"] = "rbxassetid://10734964188",
        ["lucide-snowflake"] = "rbxassetid://10734964600",
        ["lucide-sofa"] = "rbxassetid://10734964852",
        ["lucide-sort-asc"] = "rbxassetid://10734965115",
        ["lucide-sort-desc"] = "rbxassetid://10734965287",
        ["lucide-speaker"] = "rbxassetid://10734965419",
        ["lucide-sprout"] = "rbxassetid://10734965572",
        ["lucide-square"] = "rbxassetid://10734965702",
        ["lucide-star"] = "rbxassetid://10734966248",
        ["lucide-star-half"] = "rbxassetid://10734965897",
        ["lucide-star-off"] = "rbxassetid://10734966097",
        ["lucide-stethoscope"] = "rbxassetid://10734966384",
        ["lucide-sticker"] = "rbxassetid://10734972234",
        ["lucide-sticky-note"] = "rbxassetid://10734972463",
        ["lucide-stop-circle"] = "rbxassetid://10734972621",
        ["lucide-stretch-horizontal"] = "rbxassetid://10734972862",
        ["lucide-stretch-vertical"] = "rbxassetid://10734973130",
        ["lucide-strikethrough"] = "rbxassetid://10734973290",
        ["lucide-subscript"] = "rbxassetid://10734973457",
        ["lucide-sun"] = "rbxassetid://10734974297",
        ["lucide-sun-dim"] = "rbxassetid://10734973645",
        ["lucide-sun-medium"] = "rbxassetid://10734973778",
        ["lucide-sun-moon"] = "rbxassetid://10734973999",
        ["lucide-sun-snow"] = "rbxassetid://10734974130",
        ["lucide-sunrise"] = "rbxassetid://10734974522",
        ["lucide-sunset"] = "rbxassetid://10734974689",
        ["lucide-superscript"] = "rbxassetid://10734974850",
        ["lucide-swiss-franc"] = "rbxassetid://10734975024",
        ["lucide-switch-camera"] = "rbxassetid://10734975214",
        ["lucide-sword"] = "rbxassetid://10734975486",
        ["lucide-swords"] = "rbxassetid://10734975692",
        ["lucide-syringe"] = "rbxassetid://10734975932",
        ["lucide-table"] = "rbxassetid://10734976230",
        ["lucide-table-2"] = "rbxassetid://10734976097",
        ["lucide-tablet"] = "rbxassetid://10734976394",
        ["lucide-tag"] = "rbxassetid://10734976528",
        ["lucide-tags"] = "rbxassetid://10734976739",
        ["lucide-target"] = "rbxassetid://10734977012",
        ["lucide-tent"] = "rbxassetid://10734981750",
        ["lucide-terminal"] = "rbxassetid://10734982144",
        ["lucide-terminal-square"] = "rbxassetid://10734981995",
        ["lucide-text-cursor"] = "rbxassetid://10734982395",
        ["lucide-text-cursor-input"] = "rbxassetid://10734982297",
        ["lucide-thermometer"] = "rbxassetid://10734983134",
        ["lucide-thermometer-snowflake"] = "rbxassetid://10734982571",
        ["lucide-thermometer-sun"] = "rbxassetid://10734982771",
        ["lucide-thumbs-down"] = "rbxassetid://10734983359",
        ["lucide-thumbs-up"] = "rbxassetid://10734983629",
        ["lucide-ticket"] = "rbxassetid://10734983868",
        ["lucide-timer"] = "rbxassetid://10734984606",
        ["lucide-timer-off"] = "rbxassetid://10734984138",
        ["lucide-timer-reset"] = "rbxassetid://10734984355",
        ["lucide-toggle-left"] = "rbxassetid://10734984834",
        ["lucide-toggle-right"] = "rbxassetid://10734985040",
        ["lucide-tornado"] = "rbxassetid://10734985247",
        ["lucide-toy-brick"] = "rbxassetid://10747361919",
        ["lucide-train"] = "rbxassetid://10747362105",
        ["lucide-trash"] = "rbxassetid://10747362393",
        ["lucide-trash-2"] = "rbxassetid://10747362241",
        ["lucide-tree-deciduous"] = "rbxassetid://10747362534",
        ["lucide-tree-pine"] = "rbxassetid://10747362748",
        ["lucide-trees"] = "rbxassetid://10747363016",
        ["lucide-trending-down"] = "rbxassetid://10747363205",
        ["lucide-trending-up"] = "rbxassetid://10747363465",
        ["lucide-triangle"] = "rbxassetid://10747363621",
        ["lucide-trophy"] = "rbxassetid://10747363809",
        ["lucide-truck"] = "rbxassetid://10747364031",
        ["lucide-tv"] = "rbxassetid://10747364593",
        ["lucide-tv-2"] = "rbxassetid://10747364302",
        ["lucide-type"] = "rbxassetid://10747364761",
        ["lucide-umbrella"] = "rbxassetid://10747364971",
        ["lucide-underline"] = "rbxassetid://10747365191",
        ["lucide-undo"] = "rbxassetid://10747365484",
        ["lucide-undo-2"] = "rbxassetid://10747365359",
        ["lucide-unlink"] = "rbxassetid://10747365771",
        ["lucide-unlink-2"] = "rbxassetid://10747397871",
        ["lucide-unlock"] = "rbxassetid://10747366027",
        ["lucide-upload"] = "rbxassetid://10747366434",
        ["lucide-upload-cloud"] = "rbxassetid://10747366266",
        ["lucide-usb"] = "rbxassetid://10747366606",
        ["lucide-user"] = "rbxassetid://10747373176",
        ["lucide-user-check"] = "rbxassetid://10747371901",
        ["lucide-user-cog"] = "rbxassetid://10747372167",
        ["lucide-user-minus"] = "rbxassetid://10747372346",
        ["lucide-user-plus"] = "rbxassetid://10747372702",
        ["lucide-user-x"] = "rbxassetid://10747372992",
        ["lucide-users"] = "rbxassetid://10747373426",
        ["lucide-utensils"] = "rbxassetid://10747373821",
        ["lucide-utensils-crossed"] = "rbxassetid://10747373629",
        ["lucide-venetian-mask"] = "rbxassetid://10747374003",
        ["lucide-verified"] = "rbxassetid://10747374131",
        ["lucide-vibrate"] = "rbxassetid://10747374489",
        ["lucide-vibrate-off"] = "rbxassetid://10747374269",
        ["lucide-video"] = "rbxassetid://10747374938",
        ["lucide-video-off"] = "rbxassetid://10747374721",
        ["lucide-view"] = "rbxassetid://10747375132",
        ["lucide-voicemail"] = "rbxassetid://10747375281",
        ["lucide-volume"] = "rbxassetid://10747376008",
        ["lucide-volume-1"] = "rbxassetid://10747375450",
        ["lucide-volume-2"] = "rbxassetid://10747375679",
        ["lucide-volume-x"] = "rbxassetid://10747375880",
        ["lucide-wallet"] = "rbxassetid://10747376205",
        ["lucide-wand"] = "rbxassetid://10747376565",
        ["lucide-wand-2"] = "rbxassetid://10747376349",
        ["lucide-watch"] = "rbxassetid://10747376722",
        ["lucide-waves"] = "rbxassetid://10747376931",
        ["lucide-webcam"] = "rbxassetid://10747381992",
        ["lucide-wifi"] = "rbxassetid://10747382504",
        ["lucide-wifi-off"] = "rbxassetid://10747382268",
        ["lucide-wind"] = "rbxassetid://10747382750",
        ["lucide-wrap-text"] = "rbxassetid://10747383065",
        ["lucide-wrench"] = "rbxassetid://10747383470",
        ["lucide-x"] = "rbxassetid://10747384394",
        ["lucide-x-circle"] = "rbxassetid://10747383819",
        ["lucide-x-octagon"] = "rbxassetid://10747384037",
        ["lucide-x-square"] = "rbxassetid://10747384217",
        ["lucide-zoom-in"] = "rbxassetid://10747384552",
        ["lucide-zoom-out"] = "rbxassetid://10747384679",
    };

    local function Fixed(planePos, planeNormal, rayOrigin, rayDirection)
        local n = planeNormal
        local d = rayDirection
        local v = rayOrigin - planePos
        local num = (n.x*v.x) + (n.y*v.y) + (n.z*v.z)
        local den = (n.x*d.x) + (n.y*d.y) + (n.z*d.z)
        local a = -num / den
        return rayOrigin + (a * rayDirection), a;
    end;

    function ENXUI:SetBlur(frame, NoAutoBackground)
        local Part = Instance.new('Part',workspace.Camera);
        local DepthOfField = Instance.new('DepthOfFieldEffect',cloneref(game:GetService('Lighting')));
        local SurfaceGui = Instance.new('SurfaceGui',Part);
        local BlockMesh = Instance.new("BlockMesh");
        BlockMesh.Parent = Part;
        Part.Material = Enum.Material.Glass;
        Part.Transparency = 1;
        Part.Reflectance = 1;
        Part.CastShadow = false;
        Part.Anchored = true;
        Part.CanCollide = false;
        Part.CanQuery = false;
        Part.CollisionGroup = ENXUI:RandomString();
        Part.Size = Vector3.new(1, 1, 1) * 0.01;
        Part.Color = Color3.fromRGB(0,0,0);
        TweenService:Create(Part,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{
            Transparency = 0.8;
        }):Play()
        DepthOfField.Enabled = true;
        DepthOfField.FarIntensity = 1;
        DepthOfField.FocusDistance = 0;
        DepthOfField.InFocusRadius = 500;
        DepthOfField.NearIntensity = 1;
        SurfaceGui.AlwaysOnTop = true;
        SurfaceGui.Adornee = Part;
        SurfaceGui.Active = true;
        SurfaceGui.Face = Enum.NormalId.Front;
        SurfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
        DepthOfField.Name = ENXUI:RandomString();
        Part.Name = ENXUI:RandomString();
        SurfaceGui.Name = ENXUI:RandomString();
        local C4 = {
            Update = nil,
            Collection = SurfaceGui,
            Enabled = true,
            Instances = {
                BlockMesh = BlockMesh,
                Part = Part,
                DepthOfField = DepthOfField,
                SurfaceGui = SurfaceGui,
            },
            Signal = nil
        };
        local _c4LastUpd = 0
        local Update = function()
            local _c4now = os.clock()
            if _c4now - _c4LastUpd < 0.1 then return end
            _c4LastUpd = _c4now
            local _,updatec = pcall(function()
                local userSettings = UserSettings():GetService("UserGameSettings")
                local qualityLevel = userSettings.SavedQualityLevel.Value
                if not NoAutoBackground then
                    if qualityLevel < 8 then
                        TweenService:Create(Part,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                            Transparency = 1;
                        }):Play()
                        frame.BackgroundTransparency = 0.01
                    else
                        TweenService:Create(Part,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                            Transparency = 0.8;
                        }):Play()
                        frame.BackgroundTransparency = 0.075
                    end;
                end;
            end)
            local corner0 = frame.AbsolutePosition;
            local corner1 = corner0 + frame.AbsoluteSize;
            local ray0 = CurrentCamera.ScreenPointToRay(CurrentCamera,corner0.X, corner0.Y, 1);
            local ray1 = CurrentCamera.ScreenPointToRay(CurrentCamera,corner1.X, corner1.Y, 1);
            local planeOrigin = CurrentCamera.CFrame.Position + CurrentCamera.CFrame.LookVector * (0.05 - CurrentCamera.NearPlaneZ);
            local planeNormal = CurrentCamera.CFrame.LookVector;
            local pos0 = Fixed(planeOrigin, planeNormal, ray0.Origin, ray0.Direction);
            local pos1 = Fixed(planeOrigin, planeNormal, ray1.Origin, ray1.Direction);
            pos0 = CurrentCamera.CFrame:PointToObjectSpace(pos0);
            pos1 = CurrentCamera.CFrame:PointToObjectSpace(pos1);
            local size   = pos1 - pos0;
            local center = (pos0 + pos1) / 2;
            BlockMesh.Offset = center
            BlockMesh.Scale  = size / 0.0101;
            Part.CFrame = CurrentCamera.CFrame;
        end
        C4.Update = Update;
        C4.Signal = ENXUI:Track(RunService.RenderStepped:Connect(Update));
        pcall(function()
            C4.Signal2 = ENXUI:Track(CurrentCamera:GetPropertyChangedSignal('CFrame'):Connect(function()
                Part.CFrame = CurrentCamera.CFrame;
            end));
        end)
        C4.Destroy = function()
            C4.Signal:Disconnect();
            C4.Signal2:Disconnect();
            C4.Update = function() end;
            TweenService:Create(Part,TweenInfo.new(1),{
                Transparency = 1
            }):Play();
            DepthOfField:Destroy();
            Part:Destroy()
        end;
        return C4;
    end;

    function ENXUI:GetIcon(name)
        return ENXUI.Lucide['lucide-'..tostring(name)] or ENXUI.Lucide[name] or ENXUI.Lucide[tostring(name)] or "";
    end;

    function ENXUI:RandomString()
        return string.char(math.random(60,120))..string.char(math.random(60,120))..string.char(math.random(60,120))..string.char(math.random(60,120))..string.char(math.random(60,120))..string.char(math.random(60,120))..string.char(math.random(60,120))..string.char(math.random(60,120))..string.char(math.random(60,120))..string.char(math.random(60,120))..string.char(math.random(60,120))..string.char(math.random(60,120))..string.char(math.random(60,120))..string.char(math.random(60,120))
    end;

    function ENXUI:Rounding(num, numDecimalPlaces)
        local mult = 10^(numDecimalPlaces or 0)
        return math.floor(num * mult + 0.5) / mult
    end;

    ENXUI.Theme = {
        WindowBackgroundColor = Color3.fromRGB(10, 6, 7),
        HeadText = Color3.fromRGB(232, 210, 212),
        LineColor = Color3.fromRGB(46, 20, 24),
        BackgroundColor = Color3.fromRGB(30, 14, 17),
        SectionColor = Color3.fromRGB(20, 10, 12),
        Hightlight = Color3.fromRGB(220, 20, 40),
        StrokeColor = Color3.fromRGB(54, 22, 27),
        StrokeColor2 = Color3.fromRGB(150, 96, 104),
        BackgroundColor2 = Color3.fromRGB(18, 9, 11),
        IconColor = Color3.fromRGB(255, 235, 238),
    }

    ENXUI.Chroma = {
        Enabled = true,
        Speed = 0.45,
        Targets = {},
    }

    function ENXUI:ChromaColor(offset)
        local t = (tick() * ENXUI.Chroma.Speed) + (offset or 0)
        local wave = (math.sin(t * math.pi * 2) + 1) / 2
        local hue = ((wave * 0.055) + 0.972) % 1
        local sat = 0.85 + (math.sin(t * math.pi * 1.3) * 0.10)
        local val = 0.80 + (math.sin(t * math.pi * 1.7) * 0.18)
        return Color3.fromHSV(hue, math.clamp(sat, 0, 1), math.clamp(val, 0.35, 1))
    end

    function ENXUI:BindChroma(instance, property, offset, gate)
        if not instance or not property then return end
        local entry = {
            Instance = instance,
            Property = property,
            Offset = offset or 0,
            Gate = gate,
        }
        table.insert(ENXUI.Chroma.Targets, entry)
        return entry
    end

    task.spawn(function()
        while task.wait(0.05) do
            if ENXUI.Chroma.Enabled then
                local base = ENXUI:ChromaColor(0)
                ENXUI.Theme.Hightlight = base
                for i = #ENXUI.Chroma.Targets, 1, -1 do
                    local entry = ENXUI.Chroma.Targets[i]
                    local inst = entry.Instance
                    if not inst or not inst.Parent then
                        table.remove(ENXUI.Chroma.Targets, i)
                    elseif (not entry.Gate) or entry.Gate() then
                        local ok = pcall(function()
                            inst[entry.Property] = ENXUI:ChromaColor(entry.Offset)
                        end)
                        if not ok then
                            table.remove(ENXUI.Chroma.Targets, i)
                        end
                    end
                end
            end
        end
    end)

    function ENXUI:SetTheme(name)
        if name == "Default" or name == "Gamesense" or name == "Skeet" then
            ENXUI.Theme = {
                WindowBackgroundColor = Color3.fromRGB(12, 12, 12),
                HeadText = Color3.fromRGB(209, 209, 209),
                LineColor = Color3.fromRGB(35, 35, 35),
                BackgroundColor = Color3.fromRGB(32, 32, 32),
                SectionColor = Color3.fromRGB(23, 23, 23),
                Hightlight = Color3.fromRGB(161, 208, 42),
                StrokeColor = Color3.fromRGB(40, 40, 40),
                StrokeColor2 = Color3.fromRGB(136, 136, 136),
                BackgroundColor2 = Color3.fromRGB(20, 20, 20),
                IconColor = Color3.fromRGB(255, 255, 255),
            }
        elseif name == "Neverlose" then
            ENXUI.Theme = {
                WindowBackgroundColor = Color3.fromRGB(6,8,5),
                HeadText = Color3.fromRGB(233,239,237),
                LineColor = Color3.fromRGB(18,20,19),
                BackgroundColor = Color3.fromRGB(6,8,5),
                SectionColor = Color3.fromRGB(9,11,10),
                Hightlight = Color3.fromRGB(0,169,239),
                StrokeColor = Color3.fromRGB(18,20,19),
                StrokeColor2 = Color3.fromRGB(77,90,92),
                BackgroundColor2 = Color3.fromRGB(10,14,13),
                IconColor = Color3.fromRGB(5,164,233),
            };
        elseif name == "Fatality" then
            ENXUI.Theme = {
                WindowBackgroundColor = Color3.fromRGB(8, 7, 20),
                HeadText = Color3.fromRGB(245,245,245),
                LineColor = Color3.fromRGB(54,47,86),
                BackgroundColor = Color3.fromRGB(11,10,26),
                SectionColor = Color3.fromRGB(17, 14, 36),
                Hightlight = Color3.fromRGB(198,9,85),
                StrokeColor = Color3.fromRGB(54,47,86),
                StrokeColor2 = Color3.fromRGB(54,47,86),
                BackgroundColor2 = Color3.fromRGB(21,18,45),
                IconColor = Color3.fromRGB(233,5,89),
            };
        elseif name == "Anyx" then
            ENXUI.Theme = {
                WindowBackgroundColor = Color3.fromRGB(17, 17, 17),
                HeadText = Color3.fromRGB(245,245,245),
                LineColor = Color3.fromRGB(42, 42, 42),
                BackgroundColor = Color3.fromRGB(20, 20, 20),
                SectionColor = Color3.fromRGB(20,20,20),
                Hightlight = Color3.fromRGB(81,195,206),
                StrokeColor = Color3.fromRGB(29,35,38),
                StrokeColor2 = Color3.fromRGB(29,35,38),
                BackgroundColor2 = Color3.fromRGB(31,31,31),
                IconColor = Color3.fromRGB(128,174,172),
            };
        elseif name == "Hyperion" then
            ENXUI.Theme = {
                WindowBackgroundColor = Color3.fromRGB(23, 26, 29),
                HeadText = Color3.fromRGB(211,34,35),
                LineColor = Color3.fromRGB(52,55,60),
                BackgroundColor = Color3.fromRGB(38, 43, 49),
                SectionColor = Color3.fromRGB(38,42,48),
                Hightlight = Color3.fromRGB(197,29,29),
                StrokeColor = Color3.fromRGB(48,51,56),
                StrokeColor2 = Color3.fromRGB(54, 58, 63),
                BackgroundColor2 = Color3.fromRGB(43,48,55),
                IconColor = Color3.fromRGB(220,221,222),
            };
        elseif name == "Airflow" then
            ENXUI.Theme = {
                WindowBackgroundColor = Color3.fromRGB(41,40,38),
                HeadText = Color3.fromRGB(229,229,228),
                LineColor = Color3.fromRGB(49,49,48),
                BackgroundColor = Color3.fromRGB(69,66,63),
                SectionColor = Color3.fromRGB(42,41,40),
                Hightlight = Color3.fromRGB(143,107,190),
                StrokeColor = Color3.fromRGB(49,49,48),
                StrokeColor2 = Color3.fromRGB(36, 36, 35),
                BackgroundColor2 = Color3.fromRGB(46,46,44),
                IconColor = Color3.fromRGB(143,107,190),
            };
        end;
    end;

    function ENXUI.new(config)
        config = config or {};
        config.Name = config.Name or "ECLIPSENEXUS";
        config.Keybind = config.Keybind or Enum.KeyCode.LeftControl;
        config.Scale = config.Scale or UDim2.new(0, 611, 0, 396);
        config.Resizable = config.Resizable;
        config.Shadow = config.Shadow or false;
        config.ShowProfile = config.ShowProfile or false;
        config.Acrylic = config.Acrylic or false;

        local WindowSignal = {};
        WindowSignal.SelectedTab = nil;
        WindowSignal.Tabs = {};
        WindowSignal.Config = config;
        WindowSignal.Toggle = true;
        WindowSignal.FrameMemory = {
            WindowBackgroundColor = {},
            HeadText = {},
            LineColor = {},
        };

        local Content = Instance.new("ScreenGui")
        local WindowFrame = Instance.new("Frame")
        local UICorner = Instance.new("UICorner")
        local UIStroke = Instance.new("UIStroke")
        local Header = Instance.new("Frame")
        local HeaderText = Instance.new("TextLabel")
        local SubTitleText = Instance.new("TextLabel")
        local Line = Instance.new("Frame")
        local Frame = Instance.new("Frame")
        local UIListLayout = Instance.new("UIListLayout")
        local SearchFrame = Instance.new("Frame")
        local SearchButton = Instance.new("ImageButton")
        local UIStroke_2 = Instance.new("UIStroke")
        local UICorner_2 = Instance.new("UICorner")
        local TextBox = Instance.new("TextBox")
        local MinButton = Instance.new("ImageButton")
        local Line_2 = Instance.new("Frame")
        local BthFrames = Instance.new("Frame")
        local InformationFrame = Instance.new("Frame")
        local ProfileIcon = Instance.new("ImageLabel")
        local UICorner_3 = Instance.new("UICorner")
        local UIStroke_3 = Instance.new("UIStroke")
        local UsernameText = Instance.new("TextLabel")
        local UIGradient = Instance.new("UIGradient")
        local TabButtons = Instance.new("Frame")
        local TBSFrame = Instance.new("ScrollingFrame")
        local UIListLayout_2 = Instance.new("UIListLayout")
        local Line_3 = Instance.new("Frame")
        local TabWin = Instance.new("Frame")

        Content.Name = ENXUI:RandomString()
        Content.Parent = CoreGui;
        Content.ResetOnSpawn = false
        Content.IgnoreGuiInset = true
        Content.ZIndexBehavior = Enum.ZIndexBehavior.Global;
        table.insert(ENXUI.Guis, Content);
        ENXUI.ProtectGui(Content);

        WindowFrame.Name = ENXUI:RandomString()
        WindowFrame.Parent = Content
        WindowFrame.BackgroundColor3 = ENXUI.Theme.WindowBackgroundColor
        WindowFrame.BackgroundTransparency = 0.1
        WindowFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        WindowFrame.BorderSizePixel = 0
        WindowFrame.ClipsDescendants = true
        WindowFrame.Position = UDim2.new(0, 177, 0, 177)
        WindowFrame.Size = UDim2.new(0,0,0,0)
        WindowFrame.Active = true
        table.insert(WindowSignal.FrameMemory.WindowBackgroundColor , WindowFrame)

        if config.Shadow then
            local DropShadow = Instance.new("ImageLabel")
            DropShadow.Name = ENXUI:RandomString()
            DropShadow.Parent = WindowFrame
            DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
            DropShadow.BackgroundTransparency = 1.000
            DropShadow.BorderSizePixel = 0
            DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
            DropShadow.Rotation = 0.01
            DropShadow.Size = UDim2.new(1, 47, 1, 47)
            DropShadow.ZIndex = -1
            DropShadow.Image = "rbxassetid://6015897843"
            DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
            DropShadow.ImageTransparency = 1
            DropShadow.ScaleType = Enum.ScaleType.Slice
            DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
            task.delay(1,function()
                TweenService:Create(DropShadow,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                    ImageTransparency = 0.75
                }):Play()
            end)
        end

        TweenService:Create(WindowFrame,TweenInfo.new(1,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Size = config.Scale,
            Position = UDim2.new(0, 75, 0, 75)
        }):Play()

        if config.Acrylic == nil then
            config.Acrylic = true
        end

        if config.Acrylic then
            local Blur = ENXUI:SetBlur(WindowFrame)
            table.insert(ENXUI.Cleanups, Blur.Destroy);
        end;

        function WindowSignal:SetScale(new)
            WindowSignal.Config.Scale = new;
            TweenService:Create(WindowFrame,TweenInfo.new(0.4,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                Size = new,
            }):Play()
        end;

        function WindowSignal:SetSubTitle(text)
            SubTitleText.Text = text or ""
        end;

        UICorner.CornerRadius = UDim.new(0, 4)
        UICorner.Parent = WindowFrame

        UIStroke.Transparency = 0.850
        UIStroke.Color = Color3.fromRGB(0, 25, 34)
        UIStroke.Parent = WindowFrame

        Header.Name = ENXUI:RandomString()
        Header.Parent = WindowFrame
        Header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Header.BackgroundTransparency = 1.000
        Header.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Header.BorderSizePixel = 0
        Header.ClipsDescendants = true
        Header.Size = UDim2.new(1, 0, 0, 45)
        Header.Position = UDim2.new(0,0,0,-50)
        Header.Active = true

        task.delay(0.2,function()
            TweenService:Create(Header,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                Position = UDim2.new(0,0,0,0)
            }):Play()
        end)

        HeaderText.Name = ENXUI:RandomString()
        HeaderText.Parent = Header
        HeaderText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HeaderText.BackgroundTransparency = 1.000
        HeaderText.BorderColor3 = Color3.fromRGB(0, 0, 0)
        HeaderText.BorderSizePixel = 0
        HeaderText.Position = UDim2.new(0, 10, 0, 3)
        HeaderText.Size = UDim2.new(0, 160, 1, -20)
        HeaderText.Font = Enum.Font.GothamBold
        HeaderText.Text = config.Name;
        HeaderText.TextColor3 = ENXUI.Theme.HeadText
        HeaderText.TextScaled = false
        HeaderText.TextXAlignment = Enum.TextXAlignment.Left
        HeaderText.TextSize = 25.000
        HeaderText.TextWrapped = true
        table.insert(WindowSignal.FrameMemory.HeadText , HeaderText)

        task.delay(0.4,function()
            TweenService:Create(HeaderText,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                Position = UDim2.new(0, 10, 0, 5)
            }):Play()
        end)

        Line.Name = ENXUI:RandomString()
        Line.Parent = Header
        Line.AnchorPoint = Vector2.new(0, 1)
        Line.BackgroundColor3 =ENXUI.Theme.LineColor
        Line.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Line.BorderSizePixel = 0
        Line.Position = UDim2.new(0, 170, 1, 0)
        Line.Size = UDim2.new(1, -170, 0, 1)

        SubTitleText.Name = ENXUI:RandomString()
        SubTitleText.Parent = Header
        SubTitleText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SubTitleText.BackgroundTransparency = 1.000
        SubTitleText.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SubTitleText.BorderSizePixel = 0
        SubTitleText.AnchorPoint = Vector2.new(0, 0.5)
        SubTitleText.Position = UDim2.new(0, 10, 0.7, 0)
        SubTitleText.Size = UDim2.new(0, 160, 0, 15)
        SubTitleText.Font = Enum.Font.GothamMedium
        SubTitleText.Text = config.SubTitle or ""
        SubTitleText.TextColor3 = ENXUI.Theme.HeadText
        SubTitleText.TextSize = 12.000
        SubTitleText.TextTransparency = 0.500
        SubTitleText.TextXAlignment = Enum.TextXAlignment.Left
        SubTitleText.ClipsDescendants = true

        Frame.Parent = Header
        Frame.AnchorPoint = Vector2.new(1, 0.5)
        Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Frame.BackgroundTransparency = 1.000
        Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Frame.BorderSizePixel = 0
        Frame.Position = UDim2.new(1, -10, -0.5, 0)
        Frame.Size = UDim2.new(0, 150, 0.5, 0)
        Frame.ZIndex = 5

        task.delay(0.6,function()
            TweenService:Create(Frame,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                Position = UDim2.new(1, -10, 0.5, 0)
            }):Play()
        end)

        UIListLayout.Parent = Frame
        UIListLayout.FillDirection = Enum.FillDirection.Horizontal
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        UIListLayout.Padding = UDim.new(0, 5)

        SearchFrame.Name = ENXUI:RandomString()
        SearchFrame.Parent = Frame
        SearchFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SearchFrame.BackgroundTransparency = 1.000
        SearchFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SearchFrame.BorderSizePixel = 0
        SearchFrame.ClipsDescendants = true
        SearchFrame.Size = UDim2.new(0, 140, 0, 22)

        SearchButton.Name = ENXUI:RandomString()
        SearchButton.Parent = SearchFrame
        SearchButton.AnchorPoint = Vector2.new(1, 0.5)
        SearchButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SearchButton.BackgroundTransparency = 1.000
        SearchButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SearchButton.BorderSizePixel = 0
        SearchButton.Position = UDim2.new(1, -2, 0.5, 0)
        SearchButton.Size = UDim2.new(0.800000012, 0, 0.800000012, 0)
        SearchButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
        SearchButton.Image = "rbxassetid://10734943674"
        SearchButton.ImageTransparency = 0.200

        UIStroke_2.Color = ENXUI.Theme.LineColor;
        UIStroke_2.Parent = SearchFrame

        UICorner_2.CornerRadius = UDim.new(0, 4)
        UICorner_2.Parent = SearchFrame

        TextBox.Parent = SearchFrame
        TextBox.AnchorPoint = Vector2.new(0, 0.5)
        TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextBox.BackgroundTransparency = 1.000
        TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextBox.BorderSizePixel = 0
        TextBox.Position = UDim2.new(0, 5, 0.5, 0)
        TextBox.Size = UDim2.new(1, -27, 0.649999976, 0)
        TextBox.ClearTextOnFocus = false
        TextBox.Font = Enum.Font.GothamMedium
        TextBox.PlaceholderText = "Search"
        TextBox.Text = ""
        TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextBox.TextSize = 14.000
        TextBox.TextTransparency = 0.200
        TextBox.TextXAlignment = Enum.TextXAlignment.Left

        TextBox:GetPropertyChangedSignal('Text'):Connect(function()
            if WindowSignal.SelectedTab then
                if TextBox.Text:byte() then
                    WindowSignal.SelectedTab.Search(TextBox.Text);
                else
                    WindowSignal.SelectedTab.Search(nil);
                end
            end;
        end)

        MinButton.Name = ENXUI:RandomString()
        MinButton.Parent = Frame
        MinButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        MinButton.BackgroundTransparency = 1.000
        MinButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        MinButton.BorderSizePixel = 0
        MinButton.Size = UDim2.new(1, 0, 1, 0)
        MinButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
        MinButton.Image = ENXUI:GetIcon('scan')
        MinButton.ImageTransparency = 0.200

        Line_2.Name = ENXUI:RandomString()
        Line_2.Parent = WindowFrame
        Line_2.BackgroundColor3 =ENXUI.Theme.LineColor
        Line_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Line_2.BorderSizePixel = 0
        Line_2.Position = UDim2.new(0, 170, 0, 0)
        Line_2.Size = UDim2.new(0, 1, 1, 0)

        BthFrames.Name = ENXUI:RandomString()
        BthFrames.Parent = WindowFrame
        BthFrames.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        BthFrames.BackgroundTransparency = 1.000
        BthFrames.BorderColor3 = Color3.fromRGB(0, 0, 0)
        BthFrames.BorderSizePixel = 0
        BthFrames.Position = UDim2.new(-1, 0, 0, 45)
        BthFrames.Size = UDim2.new(0, 170, 1, -45)

        task.delay(0.3,function()
            TweenService:Create(BthFrames,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                Position = UDim2.new(0, 0, 0, 45)
            }):Play()
        end)

        InformationFrame.Name = ENXUI:RandomString()
        InformationFrame.Parent = BthFrames
        InformationFrame.AnchorPoint = Vector2.new(0, 1)
        InformationFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InformationFrame.BackgroundTransparency = 1.000
        InformationFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        InformationFrame.BorderSizePixel = 0
        InformationFrame.Position = UDim2.new(0, 0, 1, 55)
        InformationFrame.Size = UDim2.new(1, 0, 0, 45)
        InformationFrame.Visible = config.ShowProfile

        task.delay(0.3,function()
            TweenService:Create(InformationFrame,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                Position = UDim2.new(0, 0, 1, 0)
            }):Play()
        end)

        ProfileIcon.Name = ENXUI:RandomString()
        ProfileIcon.Parent = InformationFrame
        ProfileIcon.Active = true
        ProfileIcon.AnchorPoint = Vector2.new(0, 0.5)
        ProfileIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ProfileIcon.BackgroundTransparency = 1.000
        ProfileIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ProfileIcon.BorderSizePixel = 0
        ProfileIcon.Position = UDim2.new(0, 5, 1.3, 0)
        ProfileIcon.Size = UDim2.new(0, 35, 0, 35)
        pcall(function()
            ProfileIcon.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)
        end)
        task.delay(0.45,function()
            TweenService:Create(ProfileIcon,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                Position = UDim2.new(0, 5, 0.5, 0)
            }):Play()
        end)

        UICorner_3.CornerRadius = UDim.new(1, 0)
        UICorner_3.Parent = ProfileIcon

        UIStroke_3.Thickness = 2.000
        UIStroke_3.Color =ENXUI.Theme.LineColor
        UIStroke_3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        UIStroke_3.Parent = ProfileIcon

        UsernameText.Name = ENXUI:RandomString()
        UsernameText.Parent = InformationFrame
        UsernameText.AnchorPoint = Vector2.new(0, 0.5)
        UsernameText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        UsernameText.BackgroundTransparency = 1.000
        UsernameText.BorderColor3 = Color3.fromRGB(0, 0, 0)
        UsernameText.BorderSizePixel = 0
        UsernameText.Position = UDim2.new(0, 47, 1.4, 0)
        UsernameText.Size = UDim2.new(1, -35, 0, -25)
        UsernameText.Font = Enum.Font.GothamBold
        UsernameText.Text = string.sub(LocalPlayer.DisplayName , 0, math.round(#LocalPlayer.DisplayName / 2))..string.rep("*",math.round(#LocalPlayer.DisplayName / 2));
        UsernameText.TextColor3 = Color3.fromRGB(206, 206, 206)
        UsernameText.TextSize = 14.000
        UsernameText.TextXAlignment = Enum.TextXAlignment.Left

        task.delay(0.5,function()
            TweenService:Create(UsernameText,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                Position = UDim2.new(0, 47, 0.5, 0)
            }):Play()
        end)

        UIGradient.Rotation = 90
        UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 1.00), NumberSequenceKeypoint.new(0.20, 0.24), NumberSequenceKeypoint.new(0.50, 0.00), NumberSequenceKeypoint.new(0.80, 0.24), NumberSequenceKeypoint.new(1.00, 1.00)}
        UIGradient.Parent = UsernameText

        TabButtons.Name = ENXUI:RandomString()
        TabButtons.Parent = BthFrames
        TabButtons.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabButtons.BackgroundTransparency = 1.000
        TabButtons.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabButtons.BorderSizePixel = 0
        TabButtons.ClipsDescendants = true
        TabButtons.Size = UDim2.new(0, 170, 1.13661206, -100)

        TBSFrame.Name = ENXUI:RandomString()
        TBSFrame.Parent = TabButtons
        TBSFrame.Active = true
        TBSFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        TBSFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TBSFrame.BackgroundTransparency = 1.000
        TBSFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TBSFrame.BorderSizePixel = 0
        TBSFrame.ClipsDescendants = false
        TBSFrame.Position = UDim2.new(-0.4, 0, 0.5, 0)
        TBSFrame.Size = UDim2.new(1, -5, 1, -5)
        TBSFrame.ZIndex = 2
        TBSFrame.BottomImage = ""
        TBSFrame.ScrollBarThickness = 0
        TBSFrame.TopImage = ""

        task.delay(0.3,function()
            TweenService:Create(TBSFrame,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
        end)

        UIListLayout_2.Parent = TBSFrame
        UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_2.Padding = UDim.new(0, 3)

        UIListLayout_2:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            TBSFrame.CanvasSize = UDim2.fromOffset(0,UIListLayout_2.AbsoluteContentSize.Y + 5)
        end)

        Line_3.Name = ENXUI:RandomString()
        Line_3.Parent = BthFrames
        Line_3.AnchorPoint = Vector2.new(0, 1)
        Line_3.BackgroundColor3 =ENXUI.Theme.LineColor
        Line_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Line_3.BorderSizePixel = 0
        Line_3.Position = UDim2.new(0, 0, 1, -45)
        Line_3.Size = UDim2.new(0, 170, 0, 1)
        Line_3.Visible = config.ShowProfile

        TabWin.Name = ENXUI:RandomString()
        TabWin.Parent = WindowFrame
        TabWin.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabWin.BackgroundTransparency = 1.000
        TabWin.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabWin.BorderSizePixel = 0
        TabWin.Position = UDim2.new(0, 170, 1, 45)
        TabWin.Size = UDim2.new(1, -170, 1, -45)
        TabWin.ZIndex = 2

        task.delay(0.3,function()
            TweenService:Create(TabWin,TweenInfo.new(0.8,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                Position = UDim2.new(0, 170, 0, 45)
            }):Play()
        end);

        function WindowSignal:StatusBar()
            local Statusbar = Instance.new("Frame")
            local UIListLayout = Instance.new("UIListLayout")
            Statusbar.Name = ENXUI:RandomString();
            Statusbar.Parent = Content;
            Statusbar.AnchorPoint = Vector2.new(1, 0)
            Statusbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Statusbar.BackgroundTransparency = 1.000
            Statusbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Statusbar.BorderSizePixel = 0
            Statusbar.Position = UDim2.new(1, -5, 0, 5)
            Statusbar.Size = UDim2.new(0, 150, 0, 1)
            UIListLayout.Parent = Statusbar
            UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Padding = UDim.new(0, 3);
            return {
                create = function(name)
                    local Frame = Instance.new("Frame")
                    local UICorner = Instance.new("UICorner")
                    local Label = Instance.new("TextLabel")
                    Frame.Parent = Statusbar
                    Frame.BackgroundColor3 = ENXUI.Theme.WindowBackgroundColor
                    Frame.BackgroundTransparency = 0.100
                    Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Frame.BorderSizePixel = 0
                    Frame.Size = UDim2.new(0, 250, 0, 20)
                    UICorner.CornerRadius = UDim.new(0, 4)
                    UICorner.Parent = Frame
                    Label.Name = ENXUI:RandomString()
                    Label.Parent = Frame
                    Label.AnchorPoint = Vector2.new(0.5, 0.5)
                    Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Label.BackgroundTransparency = 1.000
                    Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Label.BorderSizePixel = 0
                    Label.Position = UDim2.new(0.5, 0, 0.5, 0)
                    Label.Size = UDim2.new(1, -10, 0.699999988, 0)
                    Label.Font = Enum.Font.GothamMedium
                    Label.Text = name or ""
                    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Label.TextSize = 14.000
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    return {
                        Visible = function(self,a)
                            if a then
                                Frame.Visible = true
                            else
                                Frame.Visible = false
                            end
                        end,
                        Text = function(self , name)
                            Label.Text = name or ""
                        end,
                    }
                end,
            };
        end;

        function WindowSignal:AddLabel(name)
            local TBSTitle = Instance.new("TextLabel")
            TBSTitle.Name = ENXUI:RandomString()
            TBSTitle.Parent = TBSFrame
            TBSTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TBSTitle.BackgroundTransparency = 1.000
            TBSTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TBSTitle.BorderSizePixel = 0
            TBSTitle.Size = UDim2.new(1, -17, 0, 15)
            TBSTitle.ZIndex = 5
            TBSTitle.Font = Enum.Font.GothamBold
            TBSTitle.Text = name
            TBSTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            TBSTitle.TextSize = 14.000
            TBSTitle.TextTransparency = 1
            TBSTitle.TextXAlignment = Enum.TextXAlignment.Left
            task.delay(#WindowSignal.Tabs / 5,function()
                TweenService:Create(TBSTitle,TweenInfo.new(0.45),{
                    TextTransparency = 0.75
                }):Play()
            end)
            table.insert(WindowSignal.Tabs,{TBSTitle});
        end;

        function WindowSignal:AddTab(config)
            config = config or {};
            config.Name = config.Name or 'Example';
            config.Icon = config.Icon or "target";
            config.SingleMode = config.SingleMode or false;

            local TabSignal = {};
            local TabButton = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local TabIcon = Instance.new("ImageLabel")
            local TabName = Instance.new("TextLabel")

            TabButton.Name = ENXUI:RandomString()
            TabButton.Parent = TBSFrame
            TabButton.BackgroundColor3 = ENXUI.Theme.BackgroundColor2
            TabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TabButton.BorderSizePixel = 0
            TabButton.Size = UDim2.new(0, 0, 0, 35)
            TabButton.ZIndex = 5

            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = TabButton

            TabIcon.Name = ENXUI:RandomString()
            TabIcon.Parent = TabButton
            TabIcon.AnchorPoint = Vector2.new(0, 0.5)
            TabIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TabIcon.BackgroundTransparency = 1.000
            TabIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TabIcon.BorderSizePixel = 0
            TabIcon.Position = UDim2.new(0, 7, 0.5, 0)
            TabIcon.Size = UDim2.new(0, 20, 0, 20)
            TabIcon.ZIndex = 5
            TabIcon.Image = ENXUI:GetIcon(config.Icon);
            TabIcon.ImageTransparency = 1
            TabIcon.ImageColor3 = ENXUI.Theme.IconColor

            TabName.Name = ENXUI:RandomString()
            TabName.Parent = TabButton
            TabName.AnchorPoint = Vector2.new(0, 0.5)
            TabName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TabName.BackgroundTransparency = 1.000
            TabName.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TabName.BorderSizePixel = 0
            TabName.Position = UDim2.new(0, 37, 0.5, 0)
            TabName.Size = UDim2.new(1, -45, 0, 15)
            TabName.ZIndex = 5
            TabName.Font = Enum.Font.GothamMedium
            TabName.Text = config.Name
            TabName.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabName.TextScaled = true
            TabName.TextSize = 14.000
            TabName.TextTransparency = 1
            TabName.TextWrapped = true
            TabName.TextXAlignment = Enum.TextXAlignment.Left

            local TabFrame = Instance.new("Frame")
            local LeftFrame = Instance.new("ScrollingFrame")
            local UIListLayout = Instance.new("UIListLayout")
            local RightFrame = Instance.new("ScrollingFrame")
            local UIListLayout_2 = Instance.new("UIListLayout")
            local CTFrame = Instance.new("ScrollingFrame")
            local UIListLayoutAF = Instance.new("UIListLayout")

            TabFrame.Name = ENXUI:RandomString()
            TabFrame.Parent = TabWin
            TabFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            TabFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TabFrame.BackgroundTransparency = 1.000
            TabFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TabFrame.BorderSizePixel = 0
            TabFrame.ClipsDescendants = true
            TabFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            TabFrame.Size = UDim2.new(1, -2, 1, -2)
            TabFrame.ZIndex = 4

            CTFrame.Name = ENXUI:RandomString()
            CTFrame.Parent = TabFrame
            CTFrame.Active = true
            CTFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            CTFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            CTFrame.BackgroundTransparency = 1.000
            CTFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            CTFrame.BorderSizePixel = 0
            CTFrame.ClipsDescendants = false
            CTFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            CTFrame.Size = UDim2.new(1, -1, 1, -3)
            CTFrame.CanvasSize = UDim2.new(0, 0, 0, 450)
            CTFrame.ScrollBarThickness = 0
            CTFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left

            UIListLayoutAF.Parent = CTFrame
            UIListLayoutAF.FillDirection = Enum.FillDirection.Horizontal
            UIListLayoutAF.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayoutAF.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayoutAF.Padding = UDim.new(0, 2)

            LeftFrame.Name = ENXUI:RandomString()
            LeftFrame.Parent = CTFrame
            LeftFrame.Active = true
            LeftFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            LeftFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            LeftFrame.BackgroundTransparency = 1.000
            LeftFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            LeftFrame.BorderSizePixel = 0
            LeftFrame.ClipsDescendants = false
            LeftFrame.Position = UDim2.new(0.25, 0, 0.5, 0)
            LeftFrame.Size = UDim2.new(0.5, -5, 1, -3)
            LeftFrame.ScrollBarThickness = 0
            LeftFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left

            UIListLayout.Parent = LeftFrame
            UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Padding = UDim.new(0, 5)

            UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                LeftFrame.CanvasSize = UDim2.fromOffset(0,UIListLayout.AbsoluteContentSize.Y + 5)
            end)

            RightFrame.Name = ENXUI:RandomString()
            RightFrame.Parent = CTFrame
            RightFrame.Active = true
            RightFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            RightFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            RightFrame.BackgroundTransparency = 1.000
            RightFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            RightFrame.BorderSizePixel = 0
            RightFrame.ClipsDescendants = false
            RightFrame.Position = UDim2.new(0.75, 0, 0.5, 0)
            RightFrame.Size = UDim2.new(0.5, -5, 1, -3)
            RightFrame.ScrollBarThickness = 0

            UIListLayout_2.Parent = RightFrame
            UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout_2.Padding = UDim.new(0, 5)

            UIListLayout_2:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                RightFrame.CanvasSize = UDim2.fromOffset(0,UIListLayout_2.AbsoluteContentSize.Y + 5)
            end)

            task.spawn(function()
                local _enxafLast = nil
                while true do task.wait(0.25)
                    local _enxafSmall = (WindowSignal.Config.Scale.X.Offset <= ENXUI.MinimumTabSize) or config.SingleMode
                    if _enxafSmall ~= _enxafLast then _enxafLast = _enxafSmall
                    if _enxafSmall then
                        UIListLayoutAF.FillDirection = Enum.FillDirection.Vertical
                        UIListLayoutAF.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        UIListLayoutAF.SortOrder = Enum.SortOrder.LayoutOrder
                        CTFrame.ScrollingEnabled = true
                        TweenService:Create(RightFrame,TweenInfo.new(0.2),{
                            Size = UDim2.new(1,-5,0,UIListLayout_2.AbsoluteContentSize.Y + 2)
                        }):Play()
                        TweenService:Create(LeftFrame,TweenInfo.new(0.2),{
                            Size = UDim2.new(1, -5, 0,UIListLayout.AbsoluteContentSize.Y + 3)
                        }):Play()
                        TweenService:Create(UIListLayoutAF,TweenInfo.new(0.2),{
                            Padding = UDim.new(0, 2)
                        }):Play()
                        RightFrame.ScrollingEnabled = false
                        LeftFrame.ScrollingEnabled = false
                        RightFrame.CanvasPosition = Vector2.new(0,0)
                        LeftFrame.CanvasPosition = Vector2.new(0,0)
                        CTFrame.CanvasSize = UDim2.fromOffset(0,UIListLayoutAF.AbsoluteContentSize.Y)
                    else
                        CTFrame.CanvasSize = UDim2.fromOffset(0,0)
                        TweenService:Create(UIListLayoutAF,TweenInfo.new(0.2),{
                            Padding = UDim.new(0, 5)
                        }):Play()
                        TweenService:Create(RightFrame,TweenInfo.new(0.2),{
                            Size = UDim2.new(0.5, -5, 1, -3)
                        }):Play()
                        TweenService:Create(LeftFrame,TweenInfo.new(0.2),{
                            Size = UDim2.new(0.5, -5, 1, -3)
                        }):Play()
                        CTFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
                        UIListLayoutAF.FillDirection = Enum.FillDirection.Horizontal
                        UIListLayoutAF.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        UIListLayoutAF.SortOrder = Enum.SortOrder.LayoutOrder
                        CTFrame.ScrollingEnabled = false
                        RightFrame.ScrollingEnabled = true
                        LeftFrame.ScrollingEnabled = true
                        CTFrame.CanvasPosition = Vector2.new(0,0)
                    end;
                    end;
                end;
            end);

            local ToggleFunc = function(value)
                if value then
                    TabFrame.Visible = true;
                    TweenService:Create(TabButton,TweenInfo.new(0.2),{
                        BackgroundTransparency = 0.1
                    }):Play()
                    TweenService:Create(TabIcon,TweenInfo.new(0.3),{
                        ImageTransparency = 0.25,
                        Size = UDim2.new(0, 25, 0, 25),
                        Position = UDim2.new(0, 4, 0.5, 0)
                    }):Play()
                    TweenService:Create(TabName,TweenInfo.new(0.1),{
                        TextTransparency = 0.1,
                        Position = UDim2.new(0, 37, 0.5, 0)
                    }):Play()
                else
                    TabFrame.Visible = false;
                    TweenService:Create(TabButton,TweenInfo.new(0.2),{
                        BackgroundTransparency = 1
                    }):Play()
                    TweenService:Create(TabIcon,TweenInfo.new(0.3),{
                        ImageTransparency = 0.5,
                        Position = UDim2.new(0, 7, 0.5, 0),
                        Size = UDim2.new(0, 20, 0, 20)
                    }):Play()
                    TweenService:Create(TabName,TweenInfo.new(0.1),{
                        TextTransparency = 0.2,
                        Position = UDim2.new(0, 33, 0.5, 0)
                    }):Play()
                end;
            end;

            local itemForSearch = {};
            local searchItem = function(q)
                if q and q:byte() then
                    for i,v in next , itemForSearch do
                        if (i % 25) == 1 then
                            task.wait()
                        end
                        if string.find(string.lower(v.Name) , string.lower(q) , 1, true) then
                            v.Frame.Visible = true;
                            task.wait()
                        else
                            v.Frame.Visible = false;
                        end;
                    end;
                else
                    for i,v in next , itemForSearch do
                        if (i % 25) == 1 then
                            task.wait()
                        end
                        v.Frame.Visible = true;
                    end;
                end;
            end;

            local TabIden = {
                call = ToggleFunc,
                target = TabButton,
                Search = searchItem,
            };

            task.delay(#WindowSignal.Tabs / 8,function()
                TweenService:Create(TabButton,TweenInfo.new(0.35),{
                    Size = UDim2.new(1, 0, 0, 35)
                }):Play()
            end)

            ToggleFunc(WindowSignal.SelectedTab == nil and true)

            table.insert(WindowSignal.Tabs,TabIden);

            WindowSignal.SelectedTab = TabIden;

            task.delay(0.1,function()
                WindowSignal.SelectedTab = TabIden;
            end)

            ENXUI:NewInput(TabButton,function()
                if not Content.Enabled or not Content.Parent then
                    return;
                end;
                WindowSignal.SelectedTab = TabIden;
                for i,v in next , WindowSignal.Tabs do
                    if v.target == TabButton then
                        ToggleFunc(true)
                    else
                        if v.call then
                            v.call(false)
                        end
                    end;
                end;
            end);

            function TabSignal:AddSection(Config)
                Config = Config or {};
                Config.Name = Config.Name or "Section";
                Config.Position = Config.Position or "left";

                local SectionSignal = {};
                local Section = Instance.new("Frame")
                local UICorner = Instance.new("UICorner")
                local UIStroke = Instance.new("UIStroke")
                local head = Instance.new("Frame")
                local Label = Instance.new("TextLabel")
                local Frame = Instance.new("Frame")
                local UIListLayout = Instance.new("UIListLayout")

                Section.Name = ENXUI:RandomString()
                Section.Parent = (string.lower(Config.Position) == "left" and LeftFrame) or RightFrame;
                Section.BackgroundColor3 = ENXUI.Theme.SectionColor
                Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Section.BorderSizePixel = 0
                Section.ClipsDescendants = true
                Section.Size = UDim2.new(1, 0, 0, 25)

                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = Section

                UIStroke.Color = ENXUI.Theme.BackgroundColor
                UIStroke.Parent = Section

                head.Name = "head"
                head.Parent = Section
                head.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                head.BackgroundTransparency = 1.000
                head.BorderColor3 = Color3.fromRGB(0, 0, 0)
                head.BorderSizePixel = 0
                head.Size = UDim2.new(1, 0, 0, 24)

                Label.Name = "Label"
                Label.Parent = head
                Label.AnchorPoint = Vector2.new(0.5, 0)
                Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Label.BackgroundTransparency = 1.000
                Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Label.BorderSizePixel = 0
                Label.Position = UDim2.new(0.5, 0, 0, 2)
                Label.Size = UDim2.new(1, -10, 0, 20)
                Label.Font = Enum.Font.GothamMedium
                Label.Text = Config.Name
                Label.TextColor3 = Color3.fromRGB(254, 254, 254)
                Label.TextSize = 14.000
                Label.TextTransparency = 0.200
                Label.TextXAlignment = Enum.TextXAlignment.Left

                Frame.Parent = head
                Frame.AnchorPoint = Vector2.new(0, 1)
                Frame.BackgroundColor3 = ENXUI.Theme.BackgroundColor
                Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Frame.BorderSizePixel = 0
                Frame.Position = UDim2.new(0, 0, 1, 0)
                Frame.Size = UDim2.new(1, 0, 0, 1)
                Frame.ZIndex = 6

                UIListLayout.Parent = Section
                UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.Padding = UDim.new(0, 3)

                UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                    TweenService:Create(Section,TweenInfo.new(0.3,Enum.EasingStyle.Quint),{
                        Size = UDim2.new(1, 0, 0, UIListLayout.AbsoluteContentSize.Y + 3)
                    }):Play()
                end)

                function SectionSignal:AddDivider(config)
                    config = config or {};
                    config.Color = config.Color or ENXUI.Theme.LineColor;
                    config.Height = config.Height or 1;
                    local Divider = Instance.new("Frame");
                    local UICorner = Instance.new("UICorner");
                    table.insert(itemForSearch,{
                        Frame = Divider,
                        Name = ""
                    });
                    Divider.Name = ENXUI:RandomString();
                    Divider.Parent = Section;
                    Divider.BackgroundColor3 = config.Color;
                    Divider.BorderColor3 = Color3.fromRGB(0, 0, 0);
                    Divider.BorderSizePixel = 0;
                    Divider.Size = UDim2.new(1, -10, 0, config.Height);
                    UICorner.CornerRadius = UDim.new(0, 2);
                    UICorner.Parent = Divider;
                    return {
                        SetColor = function(self, newColor)
                            config.Color = newColor;
                            Divider.BackgroundColor3 = newColor;
                        end,
                        SetHeight = function(self, newHeight)
                            config.Height = newHeight;
                            Divider.Size = UDim2.new(1, -10, 0, newHeight);
                        end,
                        Visible = function(self, value)
                            Divider.Visible = value;
                        end,
                        Destroy = function(self)
                            Divider:Destroy();
                        end
                    };
                end;

                function SectionSignal:AddToggle(config)
                    config = config or {};
                    config.Default = config.Default or false;
                    config.Name = config.Name or "Toggle";
                    config.Callback = config.Callback or function() end;

                    local Toggle = Instance.new("Frame")
                    local Label = Instance.new("TextLabel")
                    local sys = Instance.new("Frame")
                    local UICorner = Instance.new("UICorner")
                    local color = Instance.new("Frame")
                    local UICorner_2 = Instance.new("UICorner")
                    local UIStroke = Instance.new("UIStroke")

                    table.insert(itemForSearch,{
                        Frame = Toggle,
                        Name = config.Name
                    })

                    Toggle.Name = ENXUI:RandomString()
                    Toggle.Parent = Section
                    Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Toggle.BackgroundTransparency = 1.000
                    Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Toggle.BorderSizePixel = 0
                    Toggle.Size = UDim2.new(1, -5, 0, 25)

                    Label.Name = "Label"
                    Label.Parent = Toggle
                    Label.AnchorPoint = Vector2.new(0, 0.5)
                    Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Label.BackgroundTransparency = 1.000
                    Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Label.BorderSizePixel = 0
                    Label.Position = UDim2.new(0, 5, 0.5, 0)
                    Label.Size = UDim2.new(1, -25, 0.649999976, 0)
                    Label.Font = Enum.Font.GothamMedium
                    Label.Text = config.Name
                    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Label.TextSize = 14.000
                    Label.TextTransparency = 0.100
                    Label.TextXAlignment = Enum.TextXAlignment.Left

                    sys.Name = "sys"
                    sys.Parent = Toggle
                    sys.AnchorPoint = Vector2.new(1, 0.5)
                    sys.BackgroundColor3 = ENXUI.Theme.BackgroundColor
                    sys.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    sys.BorderSizePixel = 0
                    sys.Position = UDim2.new(1, -3, 0.5, 0)
                    sys.Size = UDim2.new(0, 25, 0, 15)

                    UICorner.CornerRadius = UDim.new(1, 0)
                    UICorner.Parent = sys

                    color.Name = "color"
                    color.Parent = sys
                    color.AnchorPoint = Vector2.new(0.5, 0.5)
                    color.BackgroundColor3 = ENXUI.Theme.Hightlight
                    color.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    local ToggleActive = config.Default and true or false
                    ENXUI:BindChroma(color, "BackgroundColor3", 0.05, function()
                        return ToggleActive
                    end)
                    color.BorderSizePixel = 0
                    color.Position = UDim2.new(0.75, 0, 0.5, 0)
                    color.Size = UDim2.new(1, 0, 1, 0)
                    color.SizeConstraint = Enum.SizeConstraint.RelativeYY

                    UICorner_2.CornerRadius = UDim.new(1, 0)
                    UICorner_2.Parent = color

                    UIStroke.Color = ENXUI.Theme.StrokeColor
                    UIStroke.Parent = sys

                    local setValue = function(value)
                        ToggleActive = value and true or false
                        if value then
                            TweenService:Create(color,TweenInfo.new(0.2),{
                                Position = UDim2.new(0.75, 0, 0.5, 0),
                                BackgroundColor3 = ENXUI.Theme.Hightlight
                            }):Play()
                            TweenService:Create(Label,TweenInfo.new(0.4),{
                                TextTransparency = 0.1
                            }):Play()
                        else
                            TweenService:Create(Label,TweenInfo.new(0.4),{
                                TextTransparency = 0.4
                            }):Play()
                            TweenService:Create(color,TweenInfo.new(0.2),{
                                Position = UDim2.new(0.25, 0, 0.5, 0),
                                BackgroundColor3 = Color3.fromRGB(152, 152, 152)
                            }):Play()
                        end;
                    end;

                    setValue(config.Default);

                    ENXUI:NewInput(Toggle,function()
                        if not Content.Enabled or not Content.Parent then
                            return;
                        end;
                        config.Default = not config.Default
                        setValue(config.Default)
                        config.Callback(config.Default,config)
                    end);

                    return {
                        SetValue = function(self,newvalue)
                            config.Default = newvalue
                            setValue(config.Default)
                            config.Callback(config.Default,config)
                        end,
                        Visible = function(self,value)
                            Toggle.Visible = value;
                        end,
                    }
                end;

                function SectionSignal:AddLabel(name)
                    local Label = Instance.new("TextLabel")
                    table.insert(itemForSearch,{
                        Frame = Label,
                        Name = name
                    })
                    Label.Name = ENXUI:RandomString()
                    Label.Parent = Section
                    Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Label.BackgroundTransparency = 1.000
                    Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Label.BorderSizePixel = 0
                    Label.Size = UDim2.new(1, -10, 0, 20)
                    Label.ZIndex = 5
                    Label.Font = Enum.Font.GothamBold
                    Label.Text = name
                    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Label.TextSize = 13.000
                    Label.TextTransparency = 0.200
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    return {
                        SetValue = function(self,newvalue)
                            Label.Text = newvalue
                        end,
                        Visible = function(self,value)
                            Label.Visible = value;
                        end,
                    }
                end;

                function SectionSignal:AddTextbox(config)
                    config = config or {};
                    config.Name = config.Name or "Textbox";
                    config.Placeholder = config.Placeholder or "";
                    config.Default = config.Default or "";
                    config.Callback = config.Callback or function() end;

                    local Textbox = Instance.new("Frame")
                    local Label = Instance.new("TextLabel")
                    local value = Instance.new("Frame")
                    local UICorner = Instance.new("UICorner")
                    local UIStroke = Instance.new("UIStroke")
                    local Input = Instance.new("TextBox")

                    table.insert(itemForSearch,{
                        Frame = Textbox,
                        Name = config.Name
                    })

                    Textbox.Name = ENXUI:RandomString()
                    Textbox.Parent = Section
                    Textbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Textbox.BackgroundTransparency = 1.000
                    Textbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Textbox.BorderSizePixel = 0
                    Textbox.Size = UDim2.new(1, -5, 0, 25)

                    Label.Name = "Label"
                    Label.Parent = Textbox
                    Label.AnchorPoint = Vector2.new(0, 0.5)
                    Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Label.BackgroundTransparency = 1.000
                    Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Label.BorderSizePixel = 0
                    Label.Position = UDim2.new(0, 5, 0.5, 0)
                    Label.Size = UDim2.new(0.42, -10, 0.649999976, 0)
                    Label.Font = Enum.Font.GothamMedium
                    Label.Text = config.Name
                    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Label.TextSize = 14.000
                    Label.TextTransparency = 0.100
                    Label.TextXAlignment = Enum.TextXAlignment.Left

                    value.Name = "value"
                    value.Parent = Textbox
                    value.AnchorPoint = Vector2.new(1, 0.5)
                    value.BackgroundColor3 = ENXUI.Theme.BackgroundColor
                    value.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    value.BorderSizePixel = 0
                    value.Position = UDim2.new(1, -3, 0.5, 0)
                    value.Size = UDim2.new(0.58, -13, 0, 17)

                    UICorner.CornerRadius = UDim.new(0, 4)
                    UICorner.Parent = value

                    UIStroke.Color = ENXUI.Theme.StrokeColor
                    UIStroke.Parent = value

                    Input.Name = "Input"
                    Input.Parent = value
                    Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Input.BackgroundTransparency = 1.000
                    Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Input.BorderSizePixel = 0
                    Input.Position = UDim2.new(0, 4, 0, 0)
                    Input.Size = UDim2.new(1, -8, 1, 0)
                    Input.Font = Enum.Font.GothamMedium
                    Input.Text = tostring(config.Default)
                    Input.PlaceholderText = config.Placeholder
                    Input.PlaceholderColor3 = Color3.fromRGB(152, 152, 152)
                    Input.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Input.TextSize = 11.000
                    Input.TextTransparency = 0.100
                    Input.TextXAlignment = Enum.TextXAlignment.Left
                    Input.ClearTextOnFocus = false
                    Input.MultiLine = false
                    Input.TextEditable = true
                    Input.ClipsDescendants = true
                    Input.ZIndex = 20

                    Input.Focused:Connect(function()
                        Input.Text = tostring(config.Default)
                    end)

                    Input.FocusLost:Connect(function()
                        local text = tostring(Input.Text or "")
                        config.Default = text
                        config.Callback(text, config)
                    end)

                    return {
                        SetValue = function(self,newvalue)
                            config.Default = tostring(newvalue or "")
                            Input.Text = config.Default
                        end,
                        Visible = function(self,value)
                            Textbox.Visible = value;
                        end,
                    }
                end;

                function SectionSignal:AddButton(config)
                    config = config or {};
                    config.Name = config.Name or "Button";
                    config.Callback = config.Callback or function() end;

                    local Button = Instance.new("Frame")
                    local Label = Instance.new("TextLabel")
                    local UICorner = Instance.new("UICorner")
                    local UIStroke = Instance.new("UIStroke")

                    table.insert(itemForSearch,{
                        Frame = Button,
                        Name = config.Name
                    })

                    Button.Name = ENXUI:RandomString()
                    Button.Parent = Section
                    Button.BackgroundColor3 = ENXUI.Theme.BackgroundColor
                    Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Button.BorderSizePixel = 0
                    Button.Size = UDim2.new(1, -10, 0, 25)

                    Label.Name = "Label"
                    Label.Parent = Button
                    Label.AnchorPoint = Vector2.new(0.5, 0.5)
                    Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Label.BackgroundTransparency = 1.000
                    Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Label.BorderSizePixel = 0
                    Label.Position = UDim2.new(0.5, 0, 0.5, 0)
                    Label.Size = UDim2.new(1, -25, 0.649999976, 0)
                    Label.Font = Enum.Font.GothamMedium
                    Label.Text = config.Name
                    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Label.TextSize = 14.000
                    Label.TextTransparency = 0.100

                    UICorner.CornerRadius = UDim.new(0, 4)
                    UICorner.Parent = Button

                    UIStroke.Color = ENXUI.Theme.StrokeColor
                    UIStroke.Parent = Button

                    local button = ENXUI:NewInput(Button,function()
                        if not Content.Enabled or not Content.Parent then
                            return;
                        end;
                        config.Callback(config);
                    end)

                    button.MouseEnter:Connect(function()
                        TweenService:Create(Button,TweenInfo.new(0.1),{
                            BackgroundColor3 = ENXUI.Theme.Hightlight
                        }):Play()
                    end)

                    button.MouseLeave:Connect(function()
                        TweenService:Create(Button,TweenInfo.new(0.1),{
                            BackgroundColor3 = ENXUI.Theme.BackgroundColor
                        }):Play()
                    end)

                    return {
                        SetText = function(self,newvalue)
                            Label.Text = newvalue
                        end,
                        Fire = config.Callback,
                        Visible = function(self,value)
                            Button.Visible = value;
                        end,
                    };
                end;

                function SectionSignal:AddSlider(config)
                    config = config or {};
                    config.Name = config.Name or "Slider"
                    config.Min = config.Min or 0;
                    config.Max = config.Max or 100;
                    config.Default = config.Default or config.Min;
                    config.Round = config.Round or 0;
                    config.Type = config.Type or "";
                    config.Callback = config.Callback or function() end;

                    local Slider = Instance.new("Frame")
                    local value = Instance.new("Frame")
                    local UICorner = Instance.new("UICorner")
                    local LabelValue = Instance.new("TextBox")
                    local UIStroke = Instance.new("UIStroke")
                    local Label = Instance.new("TextLabel")
                    local con = Instance.new("Frame")
                    local UICorner_2 = Instance.new("UICorner")
                    local UIStroke_2 = Instance.new("UIStroke")
                    local block = Instance.new("Frame")
                    local UICorner_3 = Instance.new("UICorner")
                    local move = Instance.new("Frame")
                    local UICorner_4 = Instance.new("UICorner")

                    table.insert(itemForSearch,{
                        Frame = Slider,
                        Name = config.Name
                    })

                    Slider.Name = ENXUI:RandomString()
                    Slider.Parent = Section
                    Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Slider.BackgroundTransparency = 1.000
                    Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Slider.BorderSizePixel = 0
                    Slider.Size = UDim2.new(1, -5, 0, 22)

                    value.Name = "value"
                    value.Parent = Slider
                    value.AnchorPoint = Vector2.new(1, 0.5)
                    value.BackgroundColor3 = ENXUI.Theme.BackgroundColor
                    value.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    value.BorderSizePixel = 0
                    value.Position = UDim2.new(1, -3, 0.5, 0)
                    value.Size = UDim2.new(0, 35, 0, 15)

                    UICorner.CornerRadius = UDim.new(0, 4)
                    UICorner.Parent = value

                    LabelValue.Name = "LabelValue"
                    LabelValue.Parent = value
                    LabelValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    LabelValue.BackgroundTransparency = 1.000
                    LabelValue.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    LabelValue.BorderSizePixel = 0
                    LabelValue.Size = UDim2.new(1, 0, 1, 0)
                    LabelValue.Font = Enum.Font.GothamMedium
                    LabelValue.Text = tostring(config.Default)..tostring(config.Type)
                    LabelValue.TextColor3 = Color3.fromRGB(255, 255, 255)
                    LabelValue.TextSize = 10.000
                    LabelValue.TextTransparency = 0.250
                    LabelValue.ClearTextOnFocus = false
                    LabelValue.MultiLine = false
                    LabelValue.TextEditable = true
                    LabelValue.ZIndex = 20

                    UIStroke.Color = ENXUI.Theme.StrokeColor
                    UIStroke.Parent = value
                    value.Active = false

                    Label.Name = "Label"
                    Label.Parent = Slider
                    Label.AnchorPoint = Vector2.new(0, 0.5)
                    Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Label.BackgroundTransparency = 1.000
                    Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Label.BorderSizePixel = 0
                    Label.Position = UDim2.new(0, 5, 0.5, 0)
                    Label.Size = UDim2.new(1, -40, 0.649999976, 0)
                    Label.Font = Enum.Font.GothamMedium
                    Label.Text = config.Name
                    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Label.TextSize = 14.000
                    Label.TextTransparency = 0.250
                    Label.TextXAlignment = Enum.TextXAlignment.Left

                    con.Name = "con"
                    con.Parent = Slider
                    con.AnchorPoint = Vector2.new(1, 0.5)
                    con.BackgroundColor3 = ENXUI.Theme.BackgroundColor
                    con.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    con.BorderSizePixel = 0
                    con.Position = UDim2.new(1, -40, 0.5, 0)
                    con.Size = UDim2.new(1, -140, 1, -1)

                    UICorner_2.CornerRadius = UDim.new(1, 0)
                    UICorner_2.Parent = con

                    UIStroke_2.Color = ENXUI.Theme.StrokeColor
                    UIStroke_2.Parent = con

                    local hitArea = Instance.new("Frame")
                    hitArea.Name = "hitArea"
                    hitArea.Parent = con
                    hitArea.BackgroundTransparency = 1
                    hitArea.AnchorPoint = Vector2.new(0.5, 0.5)
                    hitArea.Position = UDim2.new(0.5, 0, 0.5, 0)
                    hitArea.Size = UDim2.new(1, 0, 0, UserInputService.TouchEnabled and 44 or 20)
                    hitArea.ZIndex = con.ZIndex + 5

                    block.Name = "block"
                    block.Parent = con
                    block.BackgroundColor3 = ENXUI.Theme.Hightlight
                    block.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    ENXUI:BindChroma(block, "BackgroundColor3", 0.10)
                    block.BorderSizePixel = 0
                    block.Size = UDim2.new(((config.Default - config.Min) / (config.Max - config.Min)), 0, 1, 0)
                    block.ZIndex = 15
                    block.Active = true

                    UICorner_3.CornerRadius = UDim.new(1, 0)
                    UICorner_3.Parent = block

                    move.Name = "move"
                    move.Parent = block
                    move.AnchorPoint = Vector2.new(0.5, 0.5)
                    move.BackgroundColor3 = ENXUI.Theme.Hightlight
                    move.BackgroundTransparency = 1
                    move.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    move.BorderSizePixel = 0
                    move.Position = UDim2.new(1, 0, 0.5, 0)
                    move.Size = UDim2.new(2, 0, 2, 0)
                    move.SizeConstraint = Enum.SizeConstraint.RelativeYY

                    UICorner_4.CornerRadius = UDim.new(1, 0)
                    UICorner_4.Parent = move

                    local IsHold = false;

                    local updateSIZE = function()
                        local test = "2."..string.rep("4",(config.Round or 0) + 1)..tostring(config.Type);
                        local scale = TextService:GetTextSize(test,LabelValue.TextSize,LabelValue.Font,Vector2.new(math.huge,math.huge));
                        local scalelab = TextService:GetTextSize(Label.Text,Label.TextSize,Label.Font,Vector2.new(math.huge,math.huge));
                        local valueWidth = math.max(scale.X + 10, 35)
                        local labelWidth = scalelab.X + 10
                        value.Size = UDim2.new(0, valueWidth, 0, 15)
                        con.Position = UDim2.new(1, -(valueWidth + 8), 0.5, 0)
                        con.Size = UDim2.new(1, -(labelWidth + valueWidth + 15), 0.200000003, 0)
                    end

                    updateSIZE()

                    local function update(Input)
                        local SizeScale = math.clamp((((Input.Position.X) - con.AbsolutePosition.X) / con.AbsoluteSize.X), 0, 1);
                        local Main = ((config.Max - config.Min) * SizeScale) + config.Min;
                        local Value = ENXUI:Rounding(Main,config.Round);
                        local normalized = (Value - config.Min) / (config.Max - config.Min);
                        TweenService:Create(block , TweenInfo.new(0.04),{
                            Size = UDim2.new(normalized, 0, 1, 0)
                        }):Play();
                        LabelValue.Text = tostring(Value)..tostring(config.Type)
                        config.Default = Value
                        updateSIZE()
                        config.Callback(Value,config)
                    end;

                    local function applyTypedValue(raw)
                        local cleaned = tostring(raw or ""):gsub("[^%d%.%-]", "")
                        local typed = tonumber(cleaned)
                        if not typed then
                            LabelValue.Text = tostring(config.Default)..tostring(config.Type)
                            updateSIZE()
                            return
                        end
                        local Value = ENXUI:Rounding(math.clamp(typed, config.Min, config.Max), config.Round)
                        config.Default = Value
                        local normalized = (Value - config.Min) / (config.Max - config.Min)
                        TweenService:Create(block, TweenInfo.new(0.08), {
                            Size = UDim2.new(normalized, 0, 1, 0)
                        }):Play()
                        LabelValue.Text = tostring(Value)..tostring(config.Type)
                        updateSIZE()
                        config.Callback(Value, config)
                    end

                    LabelValue.Focused:Connect(function()
                        IsHold = false
                        LabelValue.Text = tostring(config.Default)
                    end)

                    LabelValue.FocusLost:Connect(function()
                        applyTypedValue(LabelValue.Text)
                    end)

                    local function onInputBegan(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            if LabelValue:IsFocused() then return end
                            IsHold = true
                            update(Input)
                        end
                    end

                    con.InputBegan:Connect(onInputBegan)
                    hitArea.InputBegan:Connect(onInputBegan)

                    ENXUI:Track(UserInputService.InputEnded:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            IsHold = false
                        end
                    end))

                    ENXUI:Track(UserInputService.InputChanged:Connect(function(Input)
                        if IsHold then
                            if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                                update(Input)
                            end
                        end
                    end));

                    return {
                        SetValue = function(self,newvalue)
                            config.Default = newvalue;
                            block.Size = UDim2.new(((config.Default - config.Min) / (config.Max - config.Min)), 0, 1, 0)
                            LabelValue.Text = tostring(config.Default)..tostring(config.Type)
                            updateSIZE()
                        end,
                        Fire = config.Callback,
                        Visible = function(self,value)
                            Slider.Visible = value;
                        end,
                    };
                end;

                function SectionSignal:AddKeybind(config)
                    config = config or {};
                    config.Name = config.Name or "Keybind";
                    config.Default = config.Default or nil;
                    config.Callback = config.Callback or function() end;

                    local Keys = {
                        One = '1',
                        Two = '2',
                        Three = '3',
                        Four = '4',
                        Five = '5',
                        Six = '6',
                        Seven = '7',
                        Eight = '8',
                        Nine = '9',
                        Zero = '0',
                        ['Minus'] = "-",
                        ['Plus'] = "+",
                        BackSlash = "\\",
                        Slash = "/",
                        Period = '.',
                        Semicolon = ';',
                        Colon = ":",
                        LeftControl = "LCtrl",
                        RightControl = "RCtrl",
                        LeftShift = "LShift",
                        RightShift = "RShift",
                    };

                    local GetItem = function(item)
                        if item then
                            if typeof(item) == 'EnumItem' then
                                return Keys[item.Name] or item.Name;
                            else
                                return Keys[tostring(item)] or string.upper(tostring(item))
                            end;
                        else
                            return 'NONE';
                        end;
                    end;

                    local Keybind = Instance.new("Frame")
                    local sys = Instance.new("Frame")
                    local UICorner = Instance.new("UICorner")
                    local value = Instance.new("TextLabel")
                    local UIStroke = Instance.new("UIStroke")
                    local Label = Instance.new("TextLabel")

                    table.insert(itemForSearch,{
                        Frame = Keybind,
                        Name = config.Name
                    })

                    Keybind.Name = ENXUI:RandomString()
                    Keybind.Parent = Section
                    Keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Keybind.BackgroundTransparency = 1.000
                    Keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Keybind.BorderSizePixel = 0
                    Keybind.Size = UDim2.new(1, -5, 0, 25)

                    sys.Name = "sys"
                    sys.Parent = Keybind
                    sys.AnchorPoint = Vector2.new(1, 0.5)
                    sys.BackgroundColor3 = ENXUI.Theme.BackgroundColor
                    sys.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    sys.BorderSizePixel = 0
                    sys.Position = UDim2.new(1, -3, 0.5, 0)
                    sys.Size = UDim2.new(0, 25, 0, 15)

                    UICorner.CornerRadius = UDim.new(0, 4)
                    UICorner.Parent = sys

                    value.Name = "value"
                    value.Parent = sys
                    value.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    value.BackgroundTransparency = 1.000
                    value.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    value.BorderSizePixel = 0
                    value.Size = UDim2.new(1, 0, 1, 0)
                    value.Font = Enum.Font.GothamMedium
                    value.Text = GetItem(config.Default)
                    value.TextColor3 = ENXUI.Theme.Hightlight;
                    ENXUI:BindChroma(value, "TextColor3", 0.15)
                    value.TextSize = 12.000
                    value.TextTransparency = 0.250

                    UIStroke.Color = ENXUI.Theme.StrokeColor
                    UIStroke.Parent = sys

                    Label.Name = "Label"
                    Label.Parent = Keybind
                    Label.AnchorPoint = Vector2.new(0, 0.5)
                    Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Label.BackgroundTransparency = 1.000
                    Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Label.BorderSizePixel = 0
                    Label.Position = UDim2.new(0, 5, 0.5, 0)
                    Label.Size = UDim2.new(1, -25, 0.649999976, 0)
                    Label.Font = Enum.Font.GothamMedium
                    Label.Text = config.Name
                    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Label.TextSize = 14.000
                    Label.TextTransparency = 0.250
                    Label.TextXAlignment = Enum.TextXAlignment.Left

                    local UpdateScale = function()
                        local BindLabelScale = TextService:GetTextSize(value.Text,value.TextSize,value.Font,Vector2.new(math.huge,math.huge));
                        TweenService:Create(sys,TweenInfo.new(0.1),{
                            Size = UDim2.new(0, BindLabelScale.X + 10, 0, 15)
                        }):Play();
                    end;

                    UpdateScale();

                    local Button = ENXUI:NewInput(Keybind);
                    local IsBinding = false;

                    Button.MouseButton1Click:Connect(function()
                        if not Content.Enabled or not Content.Parent then
                            return;
                        end;
                        if IsBinding then return; end;
                        IsBinding = true;
                        value.Text = "...";
                        UpdateScale();
                        local Selected = nil;
                        while not Selected do
                            local Key = UserInputService.InputBegan:Wait();
                            if Key.KeyCode ~= Enum.KeyCode.Unknown then
                                Selected = Key.KeyCode;
                            end;
                        end;
                        config.Default = Selected;
                        value.Text = GetItem(Selected);
                        UpdateScale();
                        IsBinding = false;
                        config.Callback(Selected,config);
                    end)

                    return {
                        SetValue = function(self,newvalue)
                            config.Default = newvalue;
                            value.Text = GetItem(newvalue);
                            UpdateScale();
                            config.Callback(newvalue,config);
                        end,
                        Fire = config.Callback,
                        Visible = function(self,value)
                            Keybind.Visible = value;
                        end,
                    };
                end;

                function SectionSignal:AddInput(config)
                    config = config or {};
                    config.Name = config.Name or "Input";
                    config.Default = config.Default or "";
                    config.Placeholder = config.Placeholder or "Type here...";
                    config.ClearTextOnFocus = config.ClearTextOnFocus or false;
                    config.Callback = config.Callback or function() end;
                    config.FireOnEnter = config.FireOnEnter or false;
                    config.FireOnLostFocus = config.FireOnLostFocus or false;
                    config.Numeric = config.Numeric or false;
                    config.MaxLength = config.MaxLength or 100;

                    local Input = Instance.new("Frame");
                    local Label = Instance.new("TextLabel");
                    local inputFrame = Instance.new("Frame");
                    local UICorner = Instance.new("UICorner");
                    local UIStroke = Instance.new("UIStroke");
                    local textBox = Instance.new("TextBox");
                    local UICorner_2 = Instance.new("UICorner");

                    table.insert(itemForSearch, {
                        Frame = Input,
                        Name = config.Name
                    });

                    Input.Name = ENXUI:RandomString();
                    Input.Parent = Section;
                    Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                    Input.BackgroundTransparency = 1.000;
                    Input.BorderColor3 = Color3.fromRGB(0, 0, 0);
                    Input.BorderSizePixel = 0;
                    Input.Size = UDim2.new(1, -5, 0, 25);

                    Label.Name = ENXUI:RandomString();
                    Label.Parent = Input;
                    Label.AnchorPoint = Vector2.new(0, 0.5);
                    Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                    Label.BackgroundTransparency = 1.000;
                    Label.BorderColor3 = Color3.fromRGB(0, 0, 0);
                    Label.BorderSizePixel = 0;
                    Label.Position = UDim2.new(0, 5, 0.5, 0);
                    Label.Size = UDim2.new(0, 80, 0.649999976, 0);
                    Label.Font = Enum.Font.GothamMedium;
                    Label.Text = config.Name;
                    Label.TextColor3 = Color3.fromRGB(255, 255, 255);
                    Label.TextSize = 14.000;
                    Label.TextTransparency = 0.250;
                    Label.TextXAlignment = Enum.TextXAlignment.Left;

                    inputFrame.Name = ENXUI:RandomString();
                    inputFrame.Parent = Input;
                    inputFrame.AnchorPoint = Vector2.new(1, 0.5);
                    inputFrame.BackgroundColor3 = ENXUI.Theme.BackgroundColor;
                    inputFrame.BorderColor3 = Color3.fromRGB(0, 0, 0);
                    inputFrame.BorderSizePixel = 0;
                    inputFrame.Position = UDim2.new(1, -3, 0.5, 0);
                    inputFrame.Size = UDim2.new(1, -85, 0, 15);

                    UICorner.CornerRadius = UDim.new(0, 4);
                    UICorner.Parent = inputFrame;

                    UIStroke.Color = ENXUI.Theme.StrokeColor;
                    UIStroke.Parent = inputFrame;

                    textBox.Name = ENXUI:RandomString();
                    textBox.Parent = inputFrame;
                    textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                    textBox.BackgroundTransparency = 1.000;
                    textBox.BorderColor3 = Color3.fromRGB(0, 0, 0);
                    textBox.BorderSizePixel = 0;
                    textBox.Position = UDim2.new(0, 2, 0, 0);
                    textBox.Size = UDim2.new(1, -4, 1, 0);
                    textBox.Font = Enum.Font.GothamMedium;
                    textBox.Text = config.Default;
                    textBox.TextColor3 = Color3.fromRGB(255, 255, 255);
                    textBox.TextSize = 12.000;
                    textBox.TextTransparency = 0.250;
                    textBox.TextXAlignment = Enum.TextXAlignment.Left;
                    textBox.PlaceholderText = config.Placeholder;
                    textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150);
                    textBox.ClearTextOnFocus = config.ClearTextOnFocus;
                    textBox.MaxVisibleGraphemes = config.MaxLength;

                    if config.Numeric then
                        textBox.Text = tostring(config.Default);
                        textBox:GetPropertyChangedSignal("Text"):Connect(function()
                            local text = textBox.Text
                            local filteredText = ""
                            for i = 1, #text do
                                local char = text:sub(i, i)
                                if char:match("[0-9]") or char == "." or (char == "-" and i == 1) then
                                    filteredText = filteredText .. char
                                end
                            end
                            if filteredText ~= text then
                                textBox.Text = filteredText
                            end
                        end)
                    end

                    UICorner_2.CornerRadius = UDim.new(0, 3);
                    UICorner_2.Parent = textBox;

                    local function fireCallback()
                        if config.Numeric then
                            local numValue = tonumber(textBox.Text) or 0
                            config.Callback(numValue, config)
                        else
                            config.Callback(textBox.Text, config)
                        end
                    end

                    local isFocused = false

                    textBox.Focused:Connect(function()
                        isFocused = true
                        TweenService:Create(inputFrame, TweenInfo.new(0.2), {
                            BackgroundColor3 = ENXUI.Theme.BackgroundColor2
                        }):Play()
                        TweenService:Create(UIStroke, TweenInfo.new(0.2), {
                            Color = ENXUI.Theme.Hightlight
                        }):Play()
                        TweenService:Create(textBox, TweenInfo.new(0.2), {
                            TextTransparency = 0.1
                        }):Play()
                    end)

                    textBox.FocusLost:Connect(function(enterPressed)
                        isFocused = false
                        TweenService:Create(inputFrame, TweenInfo.new(0.2), {
                            BackgroundColor3 = ENXUI.Theme.BackgroundColor
                        }):Play()
                        TweenService:Create(UIStroke, TweenInfo.new(0.2), {
                            Color = ENXUI.Theme.StrokeColor
                        }):Play()
                        TweenService:Create(textBox, TweenInfo.new(0.2), {
                            TextTransparency = 0.250
                        }):Play()
                        if config.FireOnLostFocus or (enterPressed and config.FireOnEnter) then
                            fireCallback()
                        end
                    end)

                    if not config.Numeric then
                        textBox:GetPropertyChangedSignal("Text"):Connect(function()
                            if not config.FireOnLostFocus and not config.FireOnEnter then
                                fireCallback()
                            end
                        end)
                    else
                        if not config.FireOnLostFocus and not config.FireOnEnter then
                            textBox:GetPropertyChangedSignal("Text"):Connect(function()
                                fireCallback()
                            end)
                        end
                    end

                    textBox.FocusLost:Connect(function(enterPressed)
                        if enterPressed and config.FireOnEnter then
                            fireCallback()
                        end
                    end)

                    return {
                        SetValue = function(self, value)
                            textBox.Text = tostring(value)
                            if not config.FireOnLostFocus and not config.FireOnEnter then
                                fireCallback()
                            end
                        end,
                        GetValue = function(self)
                            if config.Numeric then
                                return tonumber(textBox.Text) or 0
                            else
                                return textBox.Text
                            end
                        end,
                        SetPlaceholder = function(self, placeholder)
                            config.Placeholder = placeholder
                            textBox.PlaceholderText = placeholder
                        end,
                        Clear = function(self)
                            textBox.Text = ""
                        end,
                        Focus = function(self)
                            textBox:CaptureFocus()
                        end,
                        SetLabel = function(self, newLabel)
                            config.Name = newLabel
                            Label.Text = newLabel
                        end,
                        SetMaxLength = function(self, maxLength)
                            config.MaxLength = maxLength
                            textBox.MaxVisibleGraphemes = maxLength
                        end,
                        SetNumeric = function(self, isNumeric)
                            config.Numeric = isNumeric
                            if isNumeric then
                                local currentText = textBox.Text
                                local filteredText = ""
                                for i = 1, #currentText do
                                    local char = currentText:sub(i, i)
                                    if char:match("[0-9]") or char == "." or (char == "-" and i == 1) then
                                        filteredText = filteredText .. char
                                    end
                                end
                                textBox.Text = filteredText
                            end
                        end,
                        Disable = function(self)
                            textBox.TextEditable = false
                            textBox.ClearTextOnFocus = false
                            TweenService:Create(textBox, TweenInfo.new(0.2), {
                                TextTransparency = 0.5
                            }):Play()
                            TweenService:Create(Label, TweenInfo.new(0.2), {
                                TextTransparency = 0.5
                            }):Play()
                        end,
                        Enable = function(self)
                            textBox.TextEditable = true
                            textBox.ClearTextOnFocus = config.ClearTextOnFocus
                            TweenService:Create(textBox, TweenInfo.new(0.2), {
                                TextTransparency = 0.250
                            }):Play()
                            TweenService:Create(Label, TweenInfo.new(0.2), {
                                TextTransparency = 0.250
                            }):Play()
                        end,
                        Visible = function(self, value)
                            Input.Visible = value
                        end,
                        Fire = config.Callback,
                        FireCallback = fireCallback
                    };
                end;

                function SectionSignal:AddDropdown(config)
                    config = config or {};
                    config.Name = config.Name or "Dropdown";
                    config.Values = config.Values or {};
                    config.Default = config.Default or {};
                    config.Multi = config.Multi or false;
                    config.Callback = config.Callback or function() end;

                    local parse = function(value)
                        if not value then return 'NONE' end;
                        if typeof(value) == 'table' then
                            if #value > 0 then
                                local x = {};
                                for i,v in next , value do
                                    table.insert(x , tostring(v))
                                end;
                                return table.concat(x,' , ')
                            else
                                local x = {};
                                for i,v in next , value do
                                    if v == true then
                                        table.insert(x , tostring(i))
                                    end
                                end;
                                return table.concat(x,' , ')
                            end;
                        else
                            return tostring(value);
                        end;
                    end;

                    local Dropown = Instance.new("Frame")
                    local sys = Instance.new("Frame")
                    local UICorner = Instance.new("UICorner")
                    local value = Instance.new("TextLabel")
                    local UIStroke = Instance.new("UIStroke")
                    local Label = Instance.new("TextLabel")

                    table.insert(itemForSearch,{
                        Frame = Dropown,
                        Name = config.Name
                    })

                    Dropown.Name = ENXUI:RandomString()
                    Dropown.Parent = Section
                    Dropown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Dropown.BackgroundTransparency = 1.000
                    Dropown.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Dropown.BorderSizePixel = 0
                    Dropown.Size = UDim2.new(1, -5, 0, 25)

                    sys.Name = ENXUI:RandomString()
                    sys.Parent = Dropown
                    sys.AnchorPoint = Vector2.new(1, 0.5)
                    sys.BackgroundColor3 = ENXUI.Theme.BackgroundColor
                    sys.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    sys.BorderSizePixel = 0
                    sys.Position = UDim2.new(1, -3, 0.5, 0)
                    sys.Size = UDim2.new(0, 55, 0, 15)

                    UICorner.CornerRadius = UDim.new(0, 4)
                    UICorner.Parent = sys

                    value.Name = ENXUI:RandomString()
                    value.Parent = sys
                    value.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    value.BackgroundTransparency = 1.000
                    value.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    value.BorderSizePixel = 0
                    value.Size = UDim2.new(1, 0, 1, 0)
                    value.Font = Enum.Font.GothamMedium
                    value.Text = parse(config.Default)
                    value.TextColor3 = Color3.fromRGB(255, 255, 255)
                    value.TextSize = 12.000
                    value.TextTransparency = 0.250

                    UIStroke.Color = ENXUI.Theme.StrokeColor
                    UIStroke.Parent = sys

                    Label.Name = ENXUI:RandomString()
                    Label.Parent = Dropown
                    Label.AnchorPoint = Vector2.new(0, 0.5)
                    Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Label.BackgroundTransparency = 1.000
                    Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Label.BorderSizePixel = 0
                    Label.Position = UDim2.new(0, 5, 0.5, 0)
                    Label.Size = UDim2.new(1, -25, 0.649999976, 0)
                    Label.Font = Enum.Font.GothamMedium
                    Label.Text = config.Name
                    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Label.TextSize = 14.000
                    Label.TextTransparency = 0.250
                    Label.TextXAlignment = Enum.TextXAlignment.Left

                    local DropdownItems = Instance.new("Frame")
                    local UICorner = Instance.new("UICorner")
                    local UIStroke = Instance.new("UIStroke")
                    local Scroll = Instance.new("ScrollingFrame")
                    local UIListLayout = Instance.new("UIListLayout")
                    local DropShadow = Instance.new("ImageLabel")

                    DropdownItems.Name = ENXUI:RandomString()
                    DropdownItems.Parent = Content
                    DropdownItems.BackgroundColor3 = ENXUI.Theme.WindowBackgroundColor
                    DropdownItems.BackgroundTransparency = 0.050
                    DropdownItems.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    DropdownItems.BorderSizePixel = 0
                    DropdownItems.ClipsDescendants = true
                    DropdownItems.Position = UDim2.new(0.518932879, 0, 0.54108721, 0)
                    DropdownItems.Size = UDim2.new(0, 165, 0, 0)
                    DropdownItems.ZIndex = 100
                    DropdownItems.Visible = false

                    table.insert(WindowSignal.FrameMemory.WindowBackgroundColor , DropdownItems)

                    UICorner.CornerRadius = UDim.new(0, 4)
                    UICorner.Parent = DropdownItems

                    UIStroke.Color = ENXUI.Theme.BackgroundColor
                    UIStroke.Parent = DropdownItems

                    Scroll.Name = ENXUI:RandomString()
                    Scroll.Parent = DropdownItems
                    Scroll.Active = true
                    Scroll.AnchorPoint = Vector2.new(0.5, 0.5)
                    Scroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Scroll.BackgroundTransparency = 1.000
                    Scroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Scroll.BorderSizePixel = 0
                    Scroll.ClipsDescendants = false
                    Scroll.Position = UDim2.new(0.5, 0, 0.5, 0)
                    Scroll.Size = UDim2.new(1, -5, 1, -5)
                    Scroll.ZIndex = 101
                    Scroll.ScrollBarThickness = 0

                    UIListLayout.Parent = Scroll
                    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    UIListLayout.Padding = UDim.new(0, 5)

                    UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function(...)
                        Scroll.CanvasSize = UDim2.fromOffset(0,UIListLayout.AbsoluteContentSize.Y + 2)
                    end)

                    DropShadow.Name = ENXUI:RandomString()
                    DropShadow.Parent = DropdownItems
                    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
                    DropShadow.BackgroundTransparency = 1.000
                    DropShadow.BorderSizePixel = 0
                    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
                    DropShadow.Rotation = 0.000
                    DropShadow.Size = UDim2.new(1, 47, 1, 47)
                    DropShadow.ZIndex = 99
                    DropShadow.Image = "rbxassetid://6015897843"
                    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
                    DropShadow.ImageTransparency = 0.500
                    DropShadow.ScaleType = Enum.ScaleType.Slice
                    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

                    DropdownItems:GetPropertyChangedSignal('Size'):Connect(function()
                        if DropdownItems.Size.Y.Offset < 5 then
                            DropdownItems.Visible = false
                        else
                            DropdownItems.Visible = true
                        end
                    end);

                    local Icons = {
                        Selected = "rbxassetid://10734923868",
                        Normal = "rbxassetid://10734895856"
                    }

                    local update = function()
                        local scale = TextService:GetTextSize(value.Text,value.TextSize,value.Font,Vector2.new(math.huge,math.huge));
                        TweenService:Create(sys , TweenInfo.new(0.1),{
                            Size = UDim2.new(0, scale.X + 10, 0, 15)
                        }):Play()
                    end;

                    update()

                    ENXUI:Track(UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType ~= Enum.UserInputType.MouseButton1 or input.UserInputType ~= Enum.UserInputType.Touch then
                            if not ENXUI:IsMouseOverFrame(DropdownItems) then
                                TweenService:Create(DropdownItems,TweenInfo.new(0.1),{
                                    Size = UDim2.new(0, 165, 0, 0)
                                }):Play()
                                DropdownItems:SetAttribute('OPENED',false)
                            end;
                        end;
                    end))

                    do
                        local _ddLast = 0
                        ENXUI:Track(RunService.Stepped:Connect(function()
                            if not DropdownItems:GetAttribute('OPENED') then return end
                            local _ddNow = os.clock()
                            if _ddNow - _ddLast < 0.05 then return end
                            _ddLast = _ddNow
                            TweenService:Create(DropdownItems,TweenInfo.new(0.1),{
                                Position = UDim2.fromOffset(sys.AbsolutePosition.X - (DropdownItems.AbsoluteSize.X / 2),sys.AbsolutePosition.Y),
                                Size = UDim2.new(0, 165, 0, math.clamp(UIListLayout.AbsoluteContentSize.Y + 5, 15 , 150))
                            }):Play()
                        end));
                    end

                    local CreateButton = function(name,val)
                        local Selected = Instance.new("Frame")
                        local Icon = Instance.new("ImageLabel")
                        local Label = Instance.new("TextLabel")
                        local UIStroke = Instance.new("UIStroke")
                        local UICorner = Instance.new("UICorner")

                        Selected.Name = ENXUI:RandomString()
                        Selected.Parent = Scroll
                        Selected.BackgroundColor3 = ENXUI.Theme.BackgroundColor2
                        Selected.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Selected.BorderSizePixel = 0
                        Selected.Size = UDim2.new(1, 0, 0, 25)
                        Selected.ZIndex = 102

                        Icon.Name = ENXUI:RandomString()
                        Icon.Parent = Selected
                        Icon.AnchorPoint = Vector2.new(0, 0.5)
                        Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Icon.BackgroundTransparency = 1.000
                        Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Icon.BorderSizePixel = 0
                        Icon.Position = UDim2.new(0, 2, 0.5, 0)
                        Icon.Size = UDim2.new(0.699999988, 0, 0.699999988, 0)
                        Icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
                        Icon.ZIndex = 102
                        Icon.ImageTransparency = 0.500

                        Label.Name = ENXUI:RandomString()
                        Label.Parent = Selected
                        Label.AnchorPoint = Vector2.new(0, 0.5)
                        Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Label.BackgroundTransparency = 1.000
                        Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Label.BorderSizePixel = 0
                        Label.Position = UDim2.new(0, 25, 0.5, 0)
                        Label.Size = UDim2.new(1, -25, 0.649999976, 0)
                        Label.ZIndex = 102
                        Label.Font = Enum.Font.GothamMedium
                        Label.Text = tostring(name)
                        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        Label.TextSize = 12.000
                        Label.TextTransparency = 0.500
                        Label.TextXAlignment = Enum.TextXAlignment.Left

                        UIStroke.Transparency = 0.850
                        UIStroke.Color = ENXUI.Theme.StrokeColor2
                        UIStroke.Parent = Selected

                        UICorner.CornerRadius = UDim.new(0, 4)
                        UICorner.Parent = Selected

                        return Selected , Icon
                    end;

                    local refresh = function()
                        for i,v in next , Scroll:GetChildren() do
                            if v:IsA('Frame') then
                                v:Destroy()
                            end;
                        end;

                        local valueBl = (typeof(config.Default) == 'table' and table.clone(config.Default)) or config.Default;
                        local old_call;

                        if config.Multi then
                            if typeof(valueBl) == 'table' and #valueBl > 0 then
                                local fake = {};
                                for i,v in next , valueBl do
                                    fake[v] = true;
                                end;
                                table.clear(valueBl)
                                valueBl = {};
                                valueBl = fake;
                            end;
                        end;

                        config.Default = valueBl;

                        for i,v in next,config.Values do
                            local IsDefault = config.Default == v or (typeof(valueBl) == 'table' and (config.Default[v] or table.find(config.Default,v)));
                            local Selected , Icon = CreateButton(v,IsDefault);

                            local effect = function(val)
                                local x = TweenService:Create(Icon,TweenInfo.new(0.4),{
                                    Rotation = (val and 180) or -180
                                });
                                x:Play()
                                x.Completed:Connect(function()
                                    Icon.Rotation = 0
                                end)
                            end;

                            local call = function(v)
                                if v then
                                    if Icon.Image ~= Icons.Selected then
                                        effect(true)
                                    end
                                    Icon.Image = Icons.Selected
                                    Icon.ImageTransparency = 0.1
                                    Icon.ImageColor3 = ENXUI.Theme.Hightlight;
                                else
                                    if Icon.Image ~= Icons.Normal then
                                        effect(false)
                                    end
                                    Icon.Image = Icons.Normal
                                    Icon.ImageTransparency = 0.5
                                    Icon.ImageColor3 = Color3.fromRGB(255, 255, 255);
                                end;
                            end;

                            if IsDefault then
                                old_call = call;
                                call(true)
                            else
                                call(false)
                            end;

                            ENXUI:NewInput(Selected,function()
                                if not Content.Enabled or not Content.Parent then
                                    return;
                                end;
                                if config.Multi then
                                    config.Default[v] = not (config.Default[v] or table.find(config.Default,v));
                                    call(config.Default[v])
                                    if #config.Default > 0 then
                                        for i,v in ipairs(config.Default) do
                                            table.remove(config.Default,i)
                                        end
                                    end;
                                    value.Text = parse(config.Default)
                                    update()
                                    config.Callback(config.Default)
                                else
                                    config.Default = v;
                                    if old_call then
                                        old_call(false)
                                    end;
                                    call(true)
                                    old_call = call;
                                    value.Text = parse(config.Default)
                                    update()
                                    config.Callback(config.Default)
                                end;
                            end);
                        end;
                    end;

                    local upd = ENXUI:NewInput(Dropown);

                    DropdownItems:SetAttribute('OPENED',false)

                    upd.MouseButton1Click:Connect(function()
                        if not Content.Enabled or not Content.Parent then
                            return;
                        end;
                        DropdownItems:SetAttribute('OPENED',true)
                        TweenService:Create(DropdownItems,TweenInfo.new(0.1),{
                            Size = UDim2.new(0, 165, 0, math.clamp(UIListLayout.AbsoluteContentSize.Y , 15 , 150))
                        }):Play()
                        refresh()
                    end);

                    return {
                        SetValue = function(self,newvalue)
                            config.Default = newvalue;
                            value.Text = parse(newvalue)
                            update();
                        end,
                        SetValues = function(self , new)
                            config.Values = new
                        end,
                        Fire = config.Callback,
                        Visible = function(self,value)
                            Dropown.Visible = value;
                        end,
                    };
                end;

                function SectionSignal:AddColorPicker(config)
                    config = config or {};
                    config.Name = config.Name or "Color";
                    config.Default = config.Default or Color3.fromRGB(255, 255, 255);
                    config.Callback = config.Callback or function() end;

                    local currentColor = config.Default;

                    local Row = Instance.new("Frame")
                    local Label = Instance.new("TextLabel")
                    local Swatch = Instance.new("Frame")
                    local UICorner_sw = Instance.new("UICorner")
                    local UIStroke_sw = Instance.new("UIStroke")

                    table.insert(itemForSearch, { Frame = Row, Name = config.Name })

                    Row.Name = ENXUI:RandomString()
                    Row.Parent = Section
                    Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Row.BackgroundTransparency = 1
                    Row.BorderSizePixel = 0
                    Row.Size = UDim2.new(1, -5, 0, 25)

                    Label.Parent = Row
                    Label.AnchorPoint = Vector2.new(0, 0.5)
                    Label.BackgroundTransparency = 1
                    Label.BorderSizePixel = 0
                    Label.Position = UDim2.new(0, 5, 0.5, 0)
                    Label.Size = UDim2.new(1, -35, 0.65, 0)
                    Label.Font = Enum.Font.GothamMedium
                    Label.Text = config.Name
                    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Label.TextSize = 14
                    Label.TextTransparency = 0.25
                    Label.TextXAlignment = Enum.TextXAlignment.Left

                    Swatch.Name = "Swatch"
                    Swatch.Parent = Row
                    Swatch.AnchorPoint = Vector2.new(1, 0.5)
                    Swatch.BackgroundColor3 = currentColor
                    Swatch.BorderSizePixel = 0
                    Swatch.Position = UDim2.new(1, -3, 0.5, 0)
                    Swatch.Size = UDim2.new(0, 28, 0, 15)

                    UICorner_sw.CornerRadius = UDim.new(0, 4)
                    UICorner_sw.Parent = Swatch

                    UIStroke_sw.Color = ENXUI.Theme.StrokeColor
                    UIStroke_sw.Parent = Swatch

                    local Picker = Instance.new("Frame")
                    local UICorner_pk = Instance.new("UICorner")
                    local UIStroke_pk = Instance.new("UIStroke")
                    local SVField = Instance.new("Frame")
                    local SVWhite = Instance.new("UIGradient")
                    local SVBlack = Instance.new("Frame")
                    local SVBlackGrad = Instance.new("UIGradient")
                    local SVCursor = Instance.new("Frame")
                    local UICorner_svc = Instance.new("UICorner")
                    local HueBar = Instance.new("Frame")
                    local HueGrad = Instance.new("UIGradient")
                    local UICorner_hb = Instance.new("UICorner")
                    local HueCursor = Instance.new("Frame")
                    local UICorner_hc = Instance.new("UICorner")
                    local HexFrame = Instance.new("Frame")
                    local UICorner_hex = Instance.new("UICorner")
                    local UIStroke_hex = Instance.new("UIStroke")
                    local HexBox = Instance.new("TextBox")

                    Picker.Name = ENXUI:RandomString()
                    Picker.Parent = Content
                    Picker.BackgroundColor3 = ENXUI.Theme.WindowBackgroundColor
                    Picker.BackgroundTransparency = 0.05
                    Picker.BorderSizePixel = 0
                    Picker.Size = UDim2.new(0, 165, 0, 175)
                    Picker.ZIndex = 200
                    Picker.Visible = false
                    Picker.ClipsDescendants = true

                    UICorner_pk.CornerRadius = UDim.new(0, 5)
                    UICorner_pk.Parent = Picker

                    UIStroke_pk.Color = ENXUI.Theme.BackgroundColor
                    UIStroke_pk.Parent = Picker

                    SVField.Name = "SVField"
                    SVField.Parent = Picker
                    SVField.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
                    SVField.BorderSizePixel = 0
                    SVField.Position = UDim2.new(0, 8, 0, 8)
                    SVField.Size = UDim2.new(1, -16, 0, 100)
                    SVField.ZIndex = 201
                    SVField.ClipsDescendants = true

                    local UICorner_svf = Instance.new("UICorner")
                    UICorner_svf.CornerRadius = UDim.new(0, 3)
                    UICorner_svf.Parent = SVField

                    SVWhite.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                        ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
                    }
                    SVWhite.Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }
                    SVWhite.Rotation = 0
                    SVWhite.Parent = SVField

                    SVBlack.BackgroundColor3 = Color3.new(0,0,0)
                    SVBlack.BorderSizePixel = 0
                    SVBlack.Size = UDim2.fromScale(1,1)
                    SVBlack.ZIndex = 202
                    SVBlack.Parent = SVField

                    local UICorner_svb = Instance.new("UICorner")
                    UICorner_svb.CornerRadius = UDim.new(0, 3)
                    UICorner_svb.Parent = SVBlack

                    SVBlackGrad.Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    }
                    SVBlackGrad.Rotation = 90
                    SVBlackGrad.Parent = SVBlack

                    SVCursor.BackgroundColor3 = Color3.new(1,1,1)
                    SVCursor.BorderSizePixel = 0
                    SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                    SVCursor.Size = UDim2.fromOffset(8, 8)
                    SVCursor.ZIndex = 205
                    SVCursor.Parent = SVField
                    UICorner_svc.CornerRadius = UDim.new(1,0)
                    UICorner_svc.Parent = SVCursor

                    local UIStroke_svc = Instance.new("UIStroke")
                    UIStroke_svc.Color = Color3.new(0,0,0)
                    UIStroke_svc.Thickness = 1.5
                    UIStroke_svc.Parent = SVCursor

                    HueBar.Parent = Picker
                    HueBar.BackgroundColor3 = Color3.new(1,1,1)
                    HueBar.BorderSizePixel = 0
                    HueBar.Position = UDim2.new(0, 8, 0, 116)
                    HueBar.Size = UDim2.new(1, -16, 0, 10)
                    HueBar.ZIndex = 201
                    UICorner_hb.CornerRadius = UDim.new(1, 0)
                    UICorner_hb.Parent = HueBar

                    HueGrad.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,1,1)),
                        ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),
                        ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),
                        ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5,1,1)),
                        ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),
                        ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),
                        ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,1,1)),
                    }
                    HueGrad.Parent = HueBar

                    HueCursor.BackgroundColor3 = Color3.new(1,1,1)
                    HueCursor.BorderSizePixel = 0
                    HueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                    HueCursor.Size = UDim2.fromOffset(6, 14)
                    HueCursor.Position = UDim2.new(0, 0, 0.5, 0)
                    HueCursor.ZIndex = 205
                    HueCursor.Parent = HueBar
                    UICorner_hc.CornerRadius = UDim.new(0, 2)
                    UICorner_hc.Parent = HueCursor

                    local UIStroke_hc = Instance.new("UIStroke")
                    UIStroke_hc.Color = Color3.new(0,0,0)
                    UIStroke_hc.Thickness = 1
                    UIStroke_hc.Parent = HueCursor

                    HexFrame.Parent = Picker
                    HexFrame.BackgroundColor3 = ENXUI.Theme.BackgroundColor
                    HexFrame.BorderSizePixel = 0
                    HexFrame.Position = UDim2.new(0, 8, 0, 134)
                    HexFrame.Size = UDim2.new(1, -16, 0, 16)
                    HexFrame.ZIndex = 201
                    UICorner_hex.CornerRadius = UDim.new(0, 4)
                    UICorner_hex.Parent = HexFrame
                    UIStroke_hex.Color = ENXUI.Theme.StrokeColor
                    UIStroke_hex.Parent = HexFrame

                    HexBox.Parent = HexFrame
                    HexBox.BackgroundTransparency = 1
                    HexBox.BorderSizePixel = 0
                    HexBox.Position = UDim2.new(0, 5, 0, 0)
                    HexBox.Size = UDim2.new(1, -10, 1, 0)
                    HexBox.Font = Enum.Font.GothamMedium
                    HexBox.Text = currentColor:ToHex():upper()
                    HexBox.TextColor3 = Color3.new(1,1,1)
                    HexBox.TextTransparency = 0.2
                    HexBox.TextSize = 11
                    HexBox.TextXAlignment = Enum.TextXAlignment.Left
                    HexBox.ZIndex = 202
                    HexBox.ClearTextOnFocus = false
                    HexBox.MaxVisibleGraphemes = 6

                    local PreviewRow = Instance.new("Frame")
                    PreviewRow.Parent = Picker
                    PreviewRow.BackgroundTransparency = 1
                    PreviewRow.BorderSizePixel = 0
                    PreviewRow.Position = UDim2.new(0, 8, 0, 156)
                    PreviewRow.Size = UDim2.new(1, -16, 0, 13)
                    PreviewRow.ZIndex = 201

                    local PreviewSwatch = Instance.new("Frame")
                    PreviewSwatch.Parent = PreviewRow
                    PreviewSwatch.BackgroundColor3 = currentColor
                    PreviewSwatch.BorderSizePixel = 0
                    PreviewSwatch.AnchorPoint = Vector2.new(1, 0.5)
                    PreviewSwatch.Position = UDim2.new(1, 0, 0.5, 0)
                    PreviewSwatch.Size = UDim2.fromOffset(28, 13)
                    PreviewSwatch.ZIndex = 202
                    local UICorner_pv = Instance.new("UICorner")
                    UICorner_pv.CornerRadius = UDim.new(0, 3)
                    UICorner_pv.Parent = PreviewSwatch

                    local RGBLabel = Instance.new("TextLabel")
                    RGBLabel.Parent = PreviewRow
                    RGBLabel.BackgroundTransparency = 1
                    RGBLabel.BorderSizePixel = 0
                    RGBLabel.AnchorPoint = Vector2.new(0, 0.5)
                    RGBLabel.Position = UDim2.new(0, 0, 0.5, 0)
                    RGBLabel.Size = UDim2.new(1, -36, 1, 0)
                    RGBLabel.Font = Enum.Font.GothamMedium
                    RGBLabel.TextColor3 = Color3.new(1,1,1)
                    RGBLabel.TextTransparency = 0.4
                    RGBLabel.TextSize = 10
                    RGBLabel.TextXAlignment = Enum.TextXAlignment.Left
                    RGBLabel.ZIndex = 202

                    local function colorToRGBStr(c)
                        return math.round(c.R*255)..", "..math.round(c.G*255)..", "..math.round(c.B*255)
                    end

                    local hue, sat, val = Color3.toHSV(currentColor)

                    local function applyColor(h, s, v)
                        hue, sat, val = h, s, v
                        currentColor = Color3.fromHSV(h, s, v)
                        Swatch.BackgroundColor3 = currentColor
                        PreviewSwatch.BackgroundColor3 = currentColor
                        SVField.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        HexBox.Text = currentColor:ToHex():upper()
                        RGBLabel.Text = colorToRGBStr(currentColor)
                        SVCursor.Position = UDim2.new(s, 0, 1-v, 0)
                        HueCursor.Position = UDim2.new(h, 0, 0.5, 0)
                        config.Callback(currentColor, config)
                    end

                    applyColor(hue, sat, val)

                    local svDrag = false
                    local hueDrag = false

                    ENXUI:Track(SVField.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                            svDrag = true
                            local rel = inp.Position - SVField.AbsolutePosition
                            local s2 = math.clamp(rel.X / SVField.AbsoluteSize.X, 0, 1)
                            local v2 = math.clamp(1 - (rel.Y / SVField.AbsoluteSize.Y), 0, 1)
                            applyColor(hue, s2, v2)
                        end
                    end))

                    ENXUI:Track(HueBar.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                            hueDrag = true
                            local rel = inp.Position - HueBar.AbsolutePosition
                            local h2 = math.clamp(rel.X / HueBar.AbsoluteSize.X, 0, 1)
                            applyColor(h2, sat, val)
                        end
                    end))

                    ENXUI:Track(UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                            svDrag = false
                            hueDrag = false
                        end
                    end))

                    ENXUI:Track(UserInputService.InputChanged:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                            if svDrag then
                                local rel = inp.Position - SVField.AbsolutePosition
                                local s2 = math.clamp(rel.X / SVField.AbsoluteSize.X, 0, 1)
                                local v2 = math.clamp(1 - (rel.Y / SVField.AbsoluteSize.Y), 0, 1)
                                applyColor(hue, s2, v2)
                            elseif hueDrag then
                                local rel = inp.Position - HueBar.AbsolutePosition
                                local h2 = math.clamp(rel.X / HueBar.AbsoluteSize.X, 0, 1)
                                applyColor(h2, sat, val)
                            end
                        end
                    end))

                    HexBox.FocusLost:Connect(function()
                        local hex = HexBox.Text:gsub("#","")
                        if #hex == 6 then
                            local ok, c = pcall(function() return Color3.fromHex(hex) end)
                            if ok then
                                local h2, s2, v2 = Color3.toHSV(c)
                                applyColor(h2, s2, v2)
                            end
                        end
                        HexBox.Text = currentColor:ToHex():upper()
                    end)

                    local pickerOpen = false

                    local function updatePickerPos()
                        Picker.Position = UDim2.fromOffset(
                            Swatch.AbsolutePosition.X + Swatch.AbsoluteSize.X - Picker.AbsoluteSize.X,
                            Swatch.AbsolutePosition.Y + Swatch.AbsoluteSize.Y + 4
                        )
                    end

                    ENXUI:NewInput(Swatch, function()
                        if not Content.Enabled or not Content.Parent then return end
                        pickerOpen = not pickerOpen
                        if pickerOpen then
                            updatePickerPos()
                            Picker.Visible = true
                        else
                            Picker.Visible = false
                        end
                    end)

                    UserInputService.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                            if pickerOpen and not ENXUI:IsMouseOverFrame(Picker) and not ENXUI:IsMouseOverFrame(Swatch) then
                                pickerOpen = false
                                Picker.Visible = false
                            end
                        end
                    end)

                    return {
                        SetValue = function(self, newColor)
                            local h2, s2, v2 = Color3.toHSV(newColor)
                            applyColor(h2, s2, v2)
                        end,
                        GetValue = function(self)
                            return currentColor
                        end,
                        Fire = config.Callback,
                        Visible = function(self, value)
                            Row.Visible = value
                        end,
                    }
                end;

                SectionSignal.Frame = Section;

                return SectionSignal;
            end;

            function TabSignal:Rename(new)
                TabName.Text = new;
            end;

            function TabSignal:Icon(new)
                TabIcon.Image = ENXUI:GetIcon(new);
            end;

            return TabSignal;
        end;

        local llk;
        local ToggleWin = function(v)
            if llk then
                llk.Visible = (v and true) or false;
            end;

            if not v then
                TweenService:Create(WindowFrame,TweenInfo.new(0.7,Enum.EasingStyle.Back,Enum.EasingDirection.In),{
                    Size = UDim2.fromOffset(210,44)
                }):Play()
                TweenService:Create(BthFrames,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                    Position = UDim2.new(-1, 0, 0, 45)
                }):Play()
                TweenService:Create(InformationFrame,TweenInfo.new(0.8,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                    Position = UDim2.new(0, 0, 1, 55)
                }):Play()
                TweenService:Create(TabWin,TweenInfo.new(0.45,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                    Position = UDim2.new(1, 170, 0, 45)
                }):Play()
                TweenService:Create(SearchFrame,TweenInfo.new(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                    Size = UDim2.new(0, 0, 0, 22)
                }):Play()
                TweenService:Create(UIStroke_2,TweenInfo.new(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                    Transparency = 1
                }):Play()
            else
                TweenService:Create(UIStroke_2,TweenInfo.new(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                    Transparency = 0
                }):Play()
                TweenService:Create(SearchFrame,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                    Size = UDim2.new(0, 140, 0, 22)
                }):Play()
                TweenService:Create(InformationFrame,TweenInfo.new(0.8,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                    Position = UDim2.new(0, 0, 1, 0)
                }):Play()
                TweenService:Create(BthFrames,TweenInfo.new(0.7,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                    Position = UDim2.new(0, 0, 0, 45)
                }):Play()
                TweenService:Create(TabWin,TweenInfo.new(0.8,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                    Position = UDim2.new(0, 170, 0, 45)
                }):Play()
                TweenService:Create(WindowFrame,TweenInfo.new(0.6,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
                    Size = WindowSignal.Config.Scale
                }):Play()
            end;
        end;

        MinButton.MouseButton1Click:Connect(function()
            WindowSignal.Toggle = not WindowSignal.Toggle;
            ToggleWin(WindowSignal.Toggle)
        end)

        _G.ENX_RESET = function(msg)
            TweenService:Create(WindowFrame,TweenInfo.new(0.7,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
                Position = UDim2.fromOffset(115,155)
            }):Play()
        end;

        ENXUI:Track(UserInputService.InputBegan:Connect(function(input, ty)
            if not ty then
                if input.KeyCode == WindowSignal.Config.Keybind then
                    WindowSignal.Toggle = not WindowSignal.Toggle;
                    ToggleWin(WindowSignal.Toggle)
                end;
            end
        end))

        if config.Resizable then
            local Resize = Instance.new("TextButton")
            local IsHold = false;

            Resize.Name = ENXUI:RandomString();
            Resize.Parent = WindowFrame
            Resize.AnchorPoint = Vector2.new(0.5, 0.5)
            Resize.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Resize.BackgroundTransparency = 1.000
            Resize.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Resize.BorderSizePixel = 0
            Resize.Position = UDim2.new(1, 0, 1, 0)
            Resize.Rotation = 0.010
            Resize.Size = UDim2.new(0.075000003, 0, 0.075000003, 0)
            Resize.SizeConstraint = Enum.SizeConstraint.RelativeYY
            Resize.ZIndex = 100
            Resize.Font = Enum.Font.SourceSans
            Resize.Text = ""
            Resize.TextColor3 = Color3.fromRGB(0, 0, 0)
            Resize.TextSize = 14.000
            Resize.Active = true
            llk = Resize;

            local label = Instance.new('ImageLabel',Resize)

            label.BackgroundTransparency = 1
            label.Size = UDim2.fromOffset(10,10)
            label.ZIndex = Resize.ZIndex + 1
            label.Image = ENXUI:GetIcon('minimize-2')
            label.Position = UDim2.fromScale(0.5,0.5)
            label.AnchorPoint = Vector2.new(0.5,0.5)

            Resize.InputBegan:Connect(function(std)
                if std.UserInputType == Enum.UserInputType.MouseButton1 or std.UserInputType == Enum.UserInputType.Touch then
                    IsHold = true
                    if UserInputService.TouchEnabled then
                        Resize.Size = UDim2.new(0.15000003, 85, 0.15000003, 85)
                    end
                end
            end)

            Resize.InputEnded:Connect(function(std)
                if std.UserInputType == Enum.UserInputType.MouseButton1 or std.UserInputType == Enum.UserInputType.Touch then
                    IsHold = false
                    Resize.Size = UDim2.new(0.075000003, 0, 0.075000003, 0)
                end
            end)

            ENXUI:Track(UserInputService.InputChanged:Connect(function(input)
                if IsHold and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and WindowSignal.Toggle then
                    local pios = input.Position;
                    local x = (pios.X - WindowFrame.AbsolutePosition.X)
                    local y = (pios.Y - WindowFrame.AbsolutePosition.Y)
                    if x < 390 then x = 390 end
                    if y < 240 then y = 240 end
                    local Offset = UDim2.new(0,x,0,y)
                    local plus = UDim2.fromOffset(-(WindowFrame.AbsoluteSize.X - x) / 2, -(WindowFrame.AbsoluteSize.Y - y) / 2);
                    TweenService:Create(WindowFrame , TweenInfo.new(0.05),{
                        Size = Offset,
                    }):Play();
                    WindowSignal.Config.Scale = Offset
                end;
            end));
        end;

        local dragToggle = nil
        local dragSpeed = 0.2
        local dragStart = nil
        local startPos = nil

        local function updateInput(input)
            local delta = input.Position - dragStart
            local position = UDim2.new(startPos.X.Scale, math.max(startPos.X.Offset + delta.X , -10),
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            game:GetService('TweenService'):Create(WindowFrame, TweenInfo.new(dragSpeed), {Position = position}):Play()
        end

        Header.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragToggle = true
                dragStart = input.Position
                startPos = WindowFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragToggle = false
                    end
                end)
            end
        end)

        ENXUI:Track(UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if dragToggle then
                    updateInput(input)
                end
            end
        end))

        return WindowSignal;
    end;

    function ENXUI:CreateNotifier()
        local Content = Instance.new("ScreenGui")
        local Notification = Instance.new("Frame")
        local UIListLayout = Instance.new("UIListLayout")

        Content.Name = ENXUI:RandomString()
        Content.Parent = CoreGui;
        Content.ResetOnSpawn = false
        Content.IgnoreGuiInset = true
        Content.ZIndexBehavior = Enum.ZIndexBehavior.Global;
        table.insert(ENXUI.Guis, Content);
        ENXUI.ProtectGui(Content)

        Notification.Name = ENXUI:RandomString()
        Notification.Parent = Content
        Notification.AnchorPoint = Vector2.new(1, 1)
        Notification.BackgroundColor3 = ENXUI.Theme.WindowBackgroundColor
        Notification.BackgroundTransparency = 1.000
        Notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Notification.BorderSizePixel = 0
        Notification.Position = UDim2.new(1, -5, 1, -5)
        Notification.Size = UDim2.new(0, 220, 0, 65)
        Notification.ZIndex = 100

        UIListLayout.Parent = Notification
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        UIListLayout.Padding = UDim.new(0,5)

        return {
            new = function(head , body , duration)
                local Notify = Instance.new("Frame")
                local UICorner = Instance.new("UICorner")
                local UIStroke = Instance.new("UIStroke")
                local Header = Instance.new("TextLabel")
                local Body = Instance.new("TextLabel")

                Notify.Name = ENXUI:RandomString()
                Notify.Parent = Notification
                Notify.BackgroundColor3 = ENXUI.Theme.WindowBackgroundColor
                Notify.BackgroundTransparency = 0.100
                Notify.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Notify.BorderSizePixel = 0
                Notify.Size = UDim2.new(0, 0,0, 0)
                Notify.ClipsDescendants = true

                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = Notify

                UIStroke.Color = ENXUI.Theme.BackgroundColor
                UIStroke.Parent = Notify

                Header.Name = ENXUI:RandomString()
                Header.Parent = Notify
                Header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Header.BackgroundTransparency = 1.000
                Header.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Header.BorderSizePixel = 0
                Header.Position = UDim2.new(0, 5, 0, 2)
                Header.Size = UDim2.new(1, -10, 0, 20)
                Header.Font = Enum.Font.GothamBold
                Header.Text = head
                Header.TextColor3 = Color3.fromRGB(255, 255, 255)
                Header.TextSize = 14.000
                Header.TextTransparency = 0.100
                Header.TextXAlignment = Enum.TextXAlignment.Left

                Body.Name = ENXUI:RandomString()
                Body.Parent = Notify
                Body.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Body.BackgroundTransparency = 1.000
                Body.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Body.BorderSizePixel = 0
                Body.Position = UDim2.new(0, 5, 0, 22)
                Body.Size = UDim2.new(1, -10, 1, -25)
                Body.Font = Enum.Font.GothamMedium
                Body.Text = body
                Body.TextColor3 = Color3.fromRGB(255, 255, 255)
                Body.TextSize = 11.000
                Body.TextTransparency = 0.500
                Body.TextXAlignment = Enum.TextXAlignment.Left
                Body.TextYAlignment = Enum.TextYAlignment.Top

                local Min = TextService:GetTextSize(Header.Text,Header.TextSize,Header.Font,Vector2.new(math.huge,math.huge));
                local scale = TextService:GetTextSize(Body.Text,Body.TextSize,Body.Font,Vector2.new(math.huge,math.huge));

                Notify.Size = UDim2.new(0,  math.clamp(scale.X + 25 , Min.X + 10 , 10000),0, 0)

                TweenService:Create(Notify,TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),{
                    Size = UDim2.new(0, math.clamp(scale.X + 25 , Min.X + 10 , 10000), 0, scale.Y + 25)
                }):Play()

                task.delay(((duration or 5) - 0.3),function()
                    TweenService:Create(Notify,TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),{
                    Size = UDim2.new(0, 0,0, scale.Y + 25)
                    }):Play()
                    task.wait(.3)
                    Notify:Destroy()
                end)
            end,
        }
    end;

    function ENXUI:Unload()
        for i, v in next, ENXUI.Cleanups do
            pcall(v);
        end;
        table.clear(ENXUI.Cleanups);
        for i, v in next, ENXUI.Connections do
            pcall(function()
                v:Disconnect();
            end)
        end;
        table.clear(ENXUI.Connections);
        for i, v in next, ENXUI.Guis do
            pcall(function()
                v:Destroy();
            end)
        end;
        table.clear(ENXUI.Guis);
    end;
end

local ENXNotify = ENXUI:CreateNotifier()

if not IsSupported then
    ENXNotify.new('EclipseNexus', 'Your executor was not supported.', 10)
    return
end

local ENXAssets = {
    CurrentCamera = nil,
    ServerStatsItem = nil,
    SwordAPI = nil,
    swordInstancesInstance = nil,
    swordInstances = nil,
    SwordController = nil,
    Replion = nil,
    Runtime = nil,
}

local ParryDATA = {
    ParryFunction = nil,
    ParryRemote = nil,
    ParryIndex = 0.500,
}

local function AttemptFunctionFetch()
    _PARRY_PATCH.ready = true
    if _PARRY_PATCH.resolve then
        _PARRY_PATCH.resolve()
    end
    return {
        ParryFunction = _PARRY_PATCH.ready and _PARRY_PATCH.fire or nil,
        ParryRemote   = _captured and _captured.remote or nil,
    }
end

local Result = AttemptFunctionFetch()
ParryDATA.ParryFunction = Result.ParryFunction
ParryDATA.ParryRemote = Result.ParryRemote

pcall(function()
    ENXAssets.CurrentCamera = Workspace.CurrentCamera
    ENXAssets.ServerStatsItem = Stats.Network.ServerStatsItem
end)
pcall(function()
    ENXAssets.SwordAPI = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SwordAPI", 5)
end)
pcall(function()
    ENXAssets.swordInstancesInstance = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ReplicatedInstances"):WaitForChild("Swords", 5)
end)
pcall(function()
    ENXAssets.DebugFlags = require(ReplicatedStorage.Shared.DebugFlags)
end)
pcall(function()
    ENXAssets.ThreadSafeTargetingHelper = require(ReplicatedStorage.Shared.ThreadSafeTargetingHelper)
end)
do
    local OldThreadIdentity = (getthreadidentity and getthreadidentity()) or 2
    if setthreadidentity then setthreadidentity(2) end
    pcall(function()
        ENXAssets.swordInstances = require(ENXAssets.swordInstancesInstance)
    end)
    if setthreadidentity then setthreadidentity(OldThreadIdentity) end
end
ENXAssets.SwordController = nil
pcall(function()
    ENXAssets.Runtime = Workspace:WaitForChild("Runtime", 5)
end)

local function _scanSwordController()
    pcall(function()
        for _, connection in pairs(getconnections(ReplicatedStorage.Remotes.FireSwordInfo.OnClientEvent)) do
            if connection.Function and islclosure(connection.Function) then
                local upvalues = debug.getupvalues(connection.Function)
                if #upvalues == 1 and type(upvalues[1]) == "table" then
                    ENXAssets.SwordController = upvalues[1]
                    break
                end
            end
        end
    end)
    if not ENXAssets.SwordController and ENXAssets.swordInstances then
        ENXAssets.SwordController = ENXAssets.swordInstances
    end
    return ENXAssets.SwordController
end
_scanSwordController()

local ENXData = {
    Player = {
        LocalPlayer = Players.LocalPlayer,
        Character = nil,
        Humanoid = nil,
    },
    Connections = {},
    Balls = (Workspace:FindFirstChild("Balls") or Workspace:WaitForChild("Balls", 5)) or Instance.new("Folder"),
    Parry = {},
    Global = {
        LastInput = nil,
        AutoParryParried = false,
        Parries = 0,
        SuccessParries = 0,
        TornadoTime = 0,
        LerpRadians = 0,
        lastParryTime = 0,
        AutoParryCurrentAccuracy = 0,
        AutoSpamParryCurrentAccuracy = 0,
    },
    Config = {
        AutoParry = {
            Enabled = false,
            AnimationFix = false,
            ParryBoost = false,
            CurveDirection = "Camera"
        },
        LobbyAutoParry = {
            Enabled = false,
            AnimationFix = false
        },
        AutoSpamParry = {
            Enabled = false,
            Keybind = nil,
            DetectionMode = "Speed",
            AnimationFix = false,
            Spamming = false,
            Threshold = 3,
            ParryThreshold = 1,
            Reach = 1.0,
            SelfArm = true,
            DistanceMultiplier = 1.0,
            CPS = 2000,
            SpamBoost = false
        },
        ManualSpamParry = {
            Spamming = false,
            UI = false,
            Keybind = nil,
            AnimationFix = false,
            SuperSpam = false,
            SuperSpamClicks = 5,
        },
        TriggerBot = {
            Enabled = false,
            UI = false,
            Keybind = nil,
            AnimationFix = false,
            InfinityDetection = false
        },
        BallStats = {
            Enabled = false
        },
        ClientStats = {
            Enabled = false
        },
        Animation = {
            GrabParry = nil,
            AnimationCache = {},
            AnimationDelay = 1,
            SpamAnimationParries = 0,
            AnimationSpammingMode = false,
        },
        ParrySettings = {
            Detections = {
                InfinityBall = {
                    Enabled = false,
                    Flag = false
                },
                DeathSlashBall = {
                    Enabled = false,
                    Flag = false
                },
                TimeHole = {
                    Enabled = false,
                    Flag = false
                },
                SlashesofFury = {
                    Enabled = false,
                    Flag = false,
                    Count = 0
                },
                Forcefield = {
                    Enabled = false,
                    Flag = false
                },
                Phantom = {
                    Enabled = false,
                    Flag = false
                },
                Singularity = {
                    Enabled = false,
                    Flag = false
                },
                Dribble = {
                    Enabled = false,
                    Flag = false
                },
                Pull = {
                    Enabled = false,
                    Flag = false
                },
                Pulse = {
                    Enabled = false,
                    Flag = false
                },
                Tornado = {
                    Enabled = false,
                    Flag = false
                },
                HellHook = {
                    Enabled = false,
                    Flag = false
                }
            },
            SpeedDivisorMultiplier = 1.1,
            AutoParryAccuracy = 80,
            AutoParryAutoAccuracy = false,
            ParryMethod = "Blatant",
            SlashesofFuryDetectionMaxParryCount = 36,
            SlashesofFuryDetectionParryDelay = 0.05,
            SpammingRPS = 180,
            ParryCurveDirection = "Camera",
            FastBallProtection = false,
            LobbyAutoParryAccuracy = 80,
            LobbySpeedDivisorMultiplier = 1.1,
            VisualiserParries = 0,
            SafeMode = true
        }
    }
}

local TriggerBotParried = false

local Visuals = {
    VisualisersEnabled = false,
    VisualiserService = {},
    HitEffectEnabled = false,
    HitEffectService = {
        BallEffects = {}
    },
    VisualParts = {}
}

function Visuals.VisualiserService:ClearAll()
    for _, part in pairs(Visuals.VisualParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    Visuals.VisualParts = {}
end

local Immortality = {
    Enabled = false,
    SpeedBypassEnabled = true,
    Angle = 72,
    Height = 15,
    Depth = -8,
    SquareRadius = 10,
    UI = false
}

local SkinChanger = {
    Enabled = false,
    Targets = {
        SwordModel = {
            Enabled = false,
            ModelName = ""
        },
        SwordAnimation = {
            Enabled = false,
            AnimationName = ""
        },
        SwordFX = {
            Enabled = false,
            FXName = ""
        }
    },
    System = {
        SlashName = "SlashEffect",
        parrySuccessAllConnection = nil,
        parrySuccessClientConnection = nil,
        playParryFunc = nil,
        lastOtherParryTimestamp = 0,
        OriginalEquipSwordTo = nil,
        functions = {}
    }
}

local UI = {
    Window = ENXUI.new({
        Name = "EclipseNexus",
        SubTitle = "v1.4 | Blade Ball",
        Keybind = Enum.KeyCode.LeftControl,
        Scale = UDim2.new(0, 545, 0, 353),
        Resizable = true,
        Shadow = false,
        Acrylic = false,
        ShowProfile = false
    }),
    AutoParryToggle = nil,
    ManualSpamParryToggle = nil,
    SpamLoopRPSLabel = nil,
    SpamAccumulatorLabel = nil,
    TriggerBotToggle = nil,
    BallStats = {
        ScreenGui = nil,
        Handler = nil,
        SpeedValue = nil,
        PeakSpeedValue = nil,
        PeakSpeed = 0,
    },
    TriggerBotUI = {
        ScreenGui = nil,
        Handler = nil,
        ToggleButton = nil,
    },
    SpamUI = {
        ScreenGui = nil,
        Handler = nil,
        SpamButton = nil,
    },
    StatsUI = {
        ScreenGui = nil,
        Handler = nil,
        States ={
            FPS = nil,
            PING = nil,
            CPU = nil,
            MEMORY = nil
        }
    }
}

getgenv()._ENX_Tabs = {}

do
    UI.Window:AddLabel('General')
    getgenv()._ENX_Tabs.Combat = UI.Window:AddTab({
        Name = "Combat",
        Icon = "swords"
    })
    UI.Window:AddLabel('Miscellaneous')
    getgenv()._ENX_Tabs.Settings = UI.Window:AddTab({
        Name = "Settings",
        Icon = "settings"
    })
    getgenv()._ENX_Tabs.EclipseNexus = UI.Window:AddTab({
        Name = "EclipseNexus",
        Icon = "swords"
    })
    getgenv()._ENX_Tabs.ESP = UI.Window:AddTab({
        Name = "ESP",
        Icon = "eye"
    })
    getgenv()._ENX_Tabs.Immortal = UI.Window:AddTab({
        Name = "Immortal",
        Icon = "shield"
    })
    getgenv()._ENX_Tabs.ParryBoost = UI.Window:AddTab({
        Name = "Parry Boost",
        Icon = "zap"
    })
    getgenv()._ENX_Tabs.SpamBoost = UI.Window:AddTab({
        Name = "Spam Boost",
        Icon = "bolt"
    })
    getgenv()._ENX_Tabs.Blatant = UI.Window:AddTab({
        Name = "Blatant",
        Icon = "skull"
    })
    getgenv()._ENX_Tabs.FastFlags = UI.Window:AddTab({
        Name = "FastFlags",
        Icon = "flag"
    })
end

local Debug = {
    Spamming = {
        Speed = 0,
        LastRepeat = 0,
        RepeatedAmount = 0,
    }
}

local ManualSpamParryUIService = {}

local TriggerBotUIService = {}
local BallStatsUIService = {}

local StatsUIService = {}

local AnimationFixService = {
    Rate = 180,
    FEMode = false,
    Cache = {}
}

local ClearCache = nil
local ResetAccumulator = nil

local UnloadENX = nil

local function GetCharacter()
    return ENXData.Player.LocalPlayer.Character
end

local function GetHumanoid()
    local character = GetCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function StopAnimation(animationtrack, FadeTime)
    local StopFadeTime = FadeTime or animationtrack:GetAttribute("StopFadeTime")
    animationtrack:Stop(StopFadeTime)
end

local function PlayGrabAnimation(animationtrack)
    local PlayFadeTime = animationtrack:GetAttribute("PlayFadeTime")
    local PlayWeight = animationtrack:GetAttribute("PlayWeight")
    local PlaySpeed = animationtrack:GetAttribute("PlaySpeed")
    animationtrack:Play(PlayFadeTime, PlayWeight, PlaySpeed)
end

local function GetParryAnimation(swordName)
    local character = GetCharacter()
    if not character then return nil end

    if not swordName then
        return ENXAssets.SwordAPI.Collection.Default:FindFirstChild("GrabParry")
    end

    if AnimationFixService.Cache[swordName] then
        return AnimationFixService.Cache[swordName]
    end

    local success, swordData = pcall(function()
        return ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(swordName)
    end)

    if not success or not swordData or type(swordData) ~= "table" then
        AnimationFixService.Cache[swordName] = ENXAssets.SwordAPI.Collection.Default:FindFirstChild("GrabParry")
        return AnimationFixService.Cache[swordName]
    end

    if not swordData.AnimationType or type(swordData.AnimationType) ~= "string" then
        AnimationFixService.Cache[swordName] = ENXAssets.SwordAPI.Collection.Default:FindFirstChild("GrabParry")
        return AnimationFixService.Cache[swordName]
    end

    local swordCollection = ENXAssets.SwordAPI.Collection
    for _, object in pairs(swordCollection:GetChildren()) do
        if object.Name == swordData.AnimationType then
            local animation = object:FindFirstChild("GrabParry") or object:FindFirstChild("Grab")
            if animation then
                AnimationFixService.Cache[swordName] = animation
                return animation
            end
        end
    end

    AnimationFixService.Cache[swordName] = ENXAssets.SwordAPI.Collection.Default:FindFirstChild("GrabParry")
    return AnimationFixService.Cache[swordName]
end

local SpamAnimationFixLastPlayed = 0
local SpamAnimationFixBypass = false

local function PlayParry_Animation()
    local IsBlockLegit = true

    local LocalPlayer = ENXData.Player.LocalPlayer
    local Character = GetCharacter()
    if not Character then IsBlockLegit = false end
    if Character:GetAttribute("Stunned") then
        IsBlockLegit = false
    end
    local IsInLobbyTrainning = LocalPlayer:GetAttribute("LobbyTraining") and (Character.Parent == workspace.Dead and true or false)
    if Character.Parent ~= Workspace.Alive and not (ENXAssets.DebugFlags.LobbyParry or (LocalPlayer:GetAttribute("LobbyParry") or IsInLobbyTrainning)) then
        IsBlockLegit = false
    end
    if Character:GetAttribute("DoNotParry") or Character:GetAttribute("ChargingAdrenaline") and LocalPlayer.Upgrades["Qi-Charge"].Value < 2 then
        IsBlockLegit = false
    end
    if LocalPlayer:GetAttribute("LobbyParry") and LocalPlayer:GetAttribute("InLobbyParryCooldown") then
        IsBlockLegit = false
    end

    local SafeModeEnabled = ENXData.Config.ParrySettings.SafeMode
    local ShouldExecuteRemoteFireServer = (IsBlockLegit and SafeModeEnabled) or not SafeModeEnabled
    if not ShouldExecuteRemoteFireServer then
        return
    end

    local humanoid = GetHumanoid()
    if not humanoid then return end

    local currentSword = nil
    if SkinChanger.Enabled and SkinChanger.Targets.SwordAnimation.Enabled and SkinChanger.Targets.SwordAnimation.AnimationName ~= "" then
        currentSword = SkinChanger.Targets.SwordAnimation.AnimationName
    else
        local character = GetCharacter()
        if not character then return end
        currentSword = character:GetAttribute("CurrentlyEquippedSword")
    end

    local animation = GetParryAnimation(currentSword)
    if not animation then
        animation = ENXAssets.SwordAPI.Collection.Default:FindFirstChild("GrabParry")
        if not animation then return end
    end

    for _, track in pairs(humanoid.Animator:GetPlayingAnimationTracks()) do
        if track.Name == "GrabParry" or track.Name == "Grab" then
            if not ENXData.Config.Animation.AnimationSpammingMode and not AnimationFixService.FEMode then
                track.TimePosition = 0
            end
            StopAnimation(track)
        elseif track.Name == "SuccessParry" or track.Name == "Success" then
            if ENXData.Config.Animation.AnimationSpammingMode and not AnimationFixService.FEMode then
                track.TimePosition = 0
            end
            StopAnimation(track)
        end
    end
    local previous = ENXData.Config.Animation.GrabParry
    if previous then
        pcall(function()
            previous:Stop(0)
            previous:Destroy()
        end)
    end
    ENXData.Config.Animation.GrabParry = humanoid.Animator:LoadAnimation(animation)
    PlayGrabAnimation(ENXData.Config.Animation.GrabParry)
end

local AnimationFixDelayLimit = 0

local function SpamParry_Animation()
    if os.clock() - AnimationFixDelayLimit >= (1/AnimationFixService.Rate) then
        AnimationFixDelayLimit = os.clock()
        if ((os.clock() - SpamAnimationFixLastPlayed) >= 0.1) or SpamAnimationFixBypass or ENXData.Config.Animation.AnimationSpammingMode then
            SpamAnimationFixLastPlayed = os.clock()
            SpamAnimationFixBypass = false
            PlayParry_Animation()
        end
    end
end

ENXUI:Track(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    ENXData.Global.LastInput = input.UserInputType
end))

do
    SkinChanger.System.functions.setSword = function()
        pcall(function()
            debug.setupvalue(SkinChanger.System.OriginalEquipSwordTo,3,false)
        end)

        if SkinChanger.Targets.SwordModel.Enabled and SkinChanger.Targets.SwordModel.ModelName ~= "" then
            ENXAssets.swordInstances:EquipSwordTo(GetCharacter(), SkinChanger.Targets.SwordModel.ModelName)
        end

        if SkinChanger.Targets.SwordAnimation.Enabled and SkinChanger.Targets.SwordAnimation.AnimationName ~= "" and ENXAssets.SwordController then
            ENXAssets.SwordController:SetSword(SkinChanger.Targets.SwordAnimation.AnimationName)
        end
    end

    SkinChanger.System.functions.getSlashName = function(swordName)
        local swordData = ENXAssets.swordInstances:GetSword(swordName)
        return (swordData and swordData.SlashName) or "SlashEffect"
    end

    SkinChanger.System.functions.updateSword = function()
        if SkinChanger.Targets.SwordFX.Enabled and SkinChanger.Targets.SwordFX.FXName ~= "" then
            SkinChanger.System.SlashName = SkinChanger.System.functions.getSlashName(SkinChanger.Targets.SwordFX.FXName)
        end
        SkinChanger.System.functions.setSword()
    end
end

local function GetParry_Data(curveDirection, IsInLobbyTrainning)
    local PlayerPositions = {}
    local Vector2_Mouse_Location

    local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
    local isRelevantInput = ENXData.Global.LastInput and (
        ENXData.Global.LastInput == Enum.UserInputType.MouseButton1 or
        ENXData.Global.LastInput == Enum.UserInputType.MouseButton2 or
        ENXData.Global.LastInput == Enum.UserInputType.Keyboard
    )

    if isRelevantInput and not isMobile then
        local Mouse_Location = UserInputService:GetMouseLocation()
        Vector2_Mouse_Location = {Mouse_Location.X, Mouse_Location.Y}
    else
        local viewportSize = ENXAssets.CurrentCamera.ViewportSize
        Vector2_Mouse_Location = {viewportSize.X / 2, viewportSize.Y / 2}
    end

    if IsInLobbyTrainning then
        for _, player_character in workspace.Dead:GetChildren() do
            local player = Players:GetPlayerFromCharacter(player_character)

            if player and (player:GetAttribute("LobbyTraining") and player_character.PrimaryPart) then
                PlayerPositions[player_character.Name] = ENXAssets.CurrentCamera:WorldToScreenPoint(player_character.PrimaryPart.Position)
            end
        end

        for _, target in CollectionService:GetTagged("LobbyTrainingTarget") do
            PlayerPositions[target.Name] = ENXAssets.CurrentCamera:WorldToScreenPoint(target.Position)
        end
    else
        local CurrentlySelectedMode = Workspace:GetAttribute("CurrentlySelectedMode")

        if CurrentlySelectedMode == "Hovergoal" or CurrentlySelectedMode == "Soccer" then
            local TeamNumber
            if ENXAssets.ThreadSafeTargetingHelper.GetPlayerTeam(ENXData.Player.LocalPlayer) == 1 then TeamNumber = 2 else TeamNumber = 1 end

            for _, hovergoalgoal in CollectionService:GetTagged("HovergoalGoal") do
                if hovergoalgoal.Name == ("Goal%*"):format((tostring(TeamNumber))) then
                    PlayerPositions[hovergoalgoal.Name] = ENXAssets.CurrentCamera:WorldToScreenPoint(hovergoalgoal.Target.Position)

                    break
                end
            end

            for _, player_character in Workspace.Alive:GetChildren() do
                if player_character.PrimaryPart and player_character:GetAttribute("IsTheRisingZombie") then
                    PlayerPositions[player_character.Name] = ENXAssets.CurrentCamera:WorldToScreenPoint(player_character.PrimaryPart.Position)
                end
            end
        else
            for _, player_character in Workspace.Alive:GetChildren() do
                if player_character.PrimaryPart then
                    PlayerPositions[player_character.Name] = ENXAssets.CurrentCamera:WorldToScreenPoint(player_character.PrimaryPart.Position)
                end
            end
        end
    end

    if curveDirection == 'Camera' then
        return {ENXAssets.CurrentCamera.CFrame, PlayerPositions, Vector2_Mouse_Location}
    elseif curveDirection == 'Straight' then
        local closestEntity = nil
        local closestDistance = math.huge
        local mouseVector = Vector2.new(Vector2_Mouse_Location[1], Vector2_Mouse_Location[2])

        if IsInLobbyTrainning then
            for _, player_character in workspace.Dead:GetChildren() do
                local player = Players:GetPlayerFromCharacter(player_character)

                if player and (player:GetAttribute("LobbyTraining") and player_character:FindFirstChild("HumanoidRootPart")) then
                    local screenPos, isOnScreen = ENXAssets.CurrentCamera:WorldToScreenPoint(player_character.PrimaryPart.Position)
                    if isOnScreen then
                        local playerScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                        local distance = (mouseVector - playerScreenPos).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestEntity = player_character
                        end
                    end
                end
            end

            for _, target in CollectionService:GetTagged("LobbyTrainingTarget") do
                local screenPos, isOnScreen = ENXAssets.CurrentCamera:WorldToScreenPoint(target.Position)
                if isOnScreen then
                    local playerScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                    local distance = (mouseVector - playerScreenPos).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestEntity = target
                    end
                end
            end
        else
            local CurrentlySelectedMode = Workspace:GetAttribute("CurrentlySelectedMode")

            if CurrentlySelectedMode == "Hovergoal" or CurrentlySelectedMode == "Soccer" then
                local TeamNumber
                if ENXAssets.ThreadSafeTargetingHelper.GetPlayerTeam(ENXData.Player.LocalPlayer) == 1 then TeamNumber = 2 else TeamNumber = 1 end

                for _, hovergoalgoal in CollectionService:GetTagged("HovergoalGoal") do
                    if hovergoalgoal.Name == ("Goal%*"):format((tostring(TeamNumber))) then
                        local screenPos, isOnScreen = ENXAssets.CurrentCamera:WorldToScreenPoint(hovergoalgoal.Target.Position)
                        if isOnScreen then
                            local playerScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                            local distance = (mouseVector - playerScreenPos).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestEntity = hovergoalgoal.Target
                            end
                        end
                        break
                    end
                end

                for _, player_character in Workspace.Alive:GetChildren() do
                    if player_character.PrimaryPart and player_character:GetAttribute("IsTheRisingZombie") then
                        local screenPos, isOnScreen = ENXAssets.CurrentCamera:WorldToScreenPoint(player_character.PrimaryPart.Position)
                        if isOnScreen then
                            local playerScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                            local distance = (mouseVector - playerScreenPos).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestEntity = player_character
                            end
                        end
                    end
                end
            else
                for _, player_character in Workspace.Alive:GetChildren() do
                    if player_character.PrimaryPart then
                        local screenPos, isOnScreen = ENXAssets.CurrentCamera:WorldToScreenPoint(player_character.PrimaryPart.Position)
                        if isOnScreen then
                            local playerScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                            local distance = (mouseVector - playerScreenPos).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestEntity = player_character
                            end
                        end
                    end
                end
            end
        end

        if closestEntity and closestEntity.PrimaryPart then
            return {CFrame.new(GetCharacter().PrimaryPart.Position, closestEntity.PrimaryPart.Position), PlayerPositions, Vector2_Mouse_Location}
        else
            return {ENXAssets.CurrentCamera.CFrame, PlayerPositions, Vector2_Mouse_Location}
        end
    elseif curveDirection == 'Up' then
        local upDirection = ENXAssets.CurrentCamera.CFrame.UpVector * 1e9
        return {CFrame.new(ENXAssets.CurrentCamera.CFrame.Position, ENXAssets.CurrentCamera.CFrame.Position + upDirection), PlayerPositions, Vector2_Mouse_Location}
    elseif curveDirection == 'Down' then
        local downDirection = ENXAssets.CurrentCamera.CFrame.UpVector * -1e9
        return {CFrame.new(ENXAssets.CurrentCamera.CFrame.Position, ENXAssets.CurrentCamera.CFrame.Position + downDirection), PlayerPositions, Vector2_Mouse_Location}
    elseif curveDirection == 'Left' then
        local leftDirection = ENXAssets.CurrentCamera.CFrame.RightVector * -1e9
        return {CFrame.new(ENXAssets.CurrentCamera.CFrame.Position, ENXAssets.CurrentCamera.CFrame.Position + leftDirection), PlayerPositions, Vector2_Mouse_Location}
    elseif curveDirection == 'Right' then
        local rightDirection = ENXAssets.CurrentCamera.CFrame.RightVector * 1e9
        return {CFrame.new(ENXAssets.CurrentCamera.CFrame.Position, ENXAssets.CurrentCamera.CFrame.Position + rightDirection), PlayerPositions, Vector2_Mouse_Location}
    elseif curveDirection == 'Backward' then
        local backDirection = ENXAssets.CurrentCamera.CFrame.LookVector * -1e9
        return {CFrame.new(ENXAssets.CurrentCamera.CFrame.Position, ENXAssets.CurrentCamera.CFrame.Position + backDirection), PlayerPositions, Vector2_Mouse_Location}
    elseif curveDirection == 'Random' then
        local randomDirection = Vector3.new(math.random(-1e9, 1e9), math.random(-1e9, 1e9), math.random(-1e9, 1e9))
        return {CFrame.new(ENXAssets.CurrentCamera.CFrame.Position, ENXAssets.CurrentCamera.CFrame.Position + randomDirection), PlayerPositions, Vector2_Mouse_Location}
    elseif curveDirection == 'Accelerate' then
        local accelerateDirection = ENXAssets.CurrentCamera.CFrame.LookVector * 10 + Vector3.new(0,7,0)
        return {CFrame.new(ENXAssets.CurrentCamera.CFrame.Position, ENXAssets.CurrentCamera.CFrame.Position + accelerateDirection), PlayerPositions, Vector2_Mouse_Location}
    elseif curveDirection == 'Decelerate' then
        local decelerateDirection = Vector3.new(0, -1, 0) * 1e9
        return {CFrame.new(ENXAssets.CurrentCamera.CFrame.Position, ENXAssets.CurrentCamera.CFrame.Position + decelerateDirection), PlayerPositions, Vector2_Mouse_Location}
    elseif curveDirection == 'High' then
        local highDirection = ENXAssets.CurrentCamera.CFrame.UpVector * 1e9
        return {CFrame.new(ENXAssets.CurrentCamera.CFrame.Position, ENXAssets.CurrentCamera.CFrame.Position + highDirection), PlayerPositions, Vector2_Mouse_Location}
    elseif curveDirection == 'Slow' then
        local slowDirection = ENXAssets.CurrentCamera.CFrame.UpVector * -1e9
        return {CFrame.new(ENXAssets.CurrentCamera.CFrame.Position, ENXAssets.CurrentCamera.CFrame.Position + slowDirection), PlayerPositions, Vector2_Mouse_Location}
    elseif curveDirection == 'Backwards' then
        local backwardsDirection = ENXAssets.CurrentCamera.CFrame.LookVector * -1e9
        return {CFrame.new(ENXAssets.CurrentCamera.CFrame.Position, ENXAssets.CurrentCamera.CFrame.Position + backwardsDirection), PlayerPositions, Vector2_Mouse_Location}
    elseif curveDirection == 'Accelerated' then
        local acceleratedDirection = ENXAssets.CurrentCamera.CFrame.LookVector * 10 + Vector3.new(0,7,0)
        return {CFrame.new(ENXAssets.CurrentCamera.CFrame.Position, ENXAssets.CurrentCamera.CFrame.Position + acceleratedDirection), PlayerPositions, Vector2_Mouse_Location}
    elseif curveDirection == 'RandomTarget' then
        local candidates = {}
        for _, player_character in Workspace.Alive:GetChildren() do
            if player_character ~= GetCharacter() and player_character.PrimaryPart then
                table.insert(candidates, player_character)
            end
        end
        if #candidates > 0 and GetCharacter() and GetCharacter().PrimaryPart then
            local pick = candidates[math.random(1, #candidates)]
            return {CFrame.new(GetCharacter().PrimaryPart.Position, pick.PrimaryPart.Position), PlayerPositions, Vector2_Mouse_Location}
        end
        return {ENXAssets.CurrentCamera.CFrame, PlayerPositions, Vector2_Mouse_Location}
    elseif curveDirection == 'Forward' then
        local forwardDirection = ENXAssets.CurrentCamera.CFrame.LookVector
        return {CFrame.new(ENXAssets.CurrentCamera.CFrame.Position, ENXAssets.CurrentCamera.CFrame.Position + forwardDirection), PlayerPositions, Vector2_Mouse_Location}
    else
        return {
            ENXAssets.CurrentCamera.CFrame,
            PlayerPositions,
            Vector2_Mouse_Location
        }
    end
end

local function Parry(ParryData)
    local cam = workspace.CurrentCamera
    local mouse = UserInputService:GetMouseLocation()
    local screenPositions = {}
    local alive = workspace:FindFirstChild('Alive')
    if alive then
        for _, entity in pairs(alive:GetChildren()) do
            if entity.PrimaryPart then
                local s, sp = pcall(function() return cam:WorldToScreenPoint(entity.PrimaryPart.Position) end)
                if s then screenPositions[entity.Name] = sp end
            end
        end
    end
    return _PARRY_PATCH.fire(cam.CFrame, screenPositions, {mouse.X, mouse.Y})
end

local ExecuteRemoteFireServer = function(ParryData)
    return fireOnce(ParryData and ParryData[1] or nil)
end

local FireParry = function()
    local ParryMethod = ENXData.Config.ParrySettings.ParryMethod
    if ParryMethod == "Blatant" then
        local IsBlockLegit = true

        local LocalPlayer = ENXData.Player.LocalPlayer
        local Character = GetCharacter()
        if not Character then IsBlockLegit = false end
        if Character:GetAttribute("Stunned") then
            IsBlockLegit = false
        end
        local IsInLobbyTrainning = LocalPlayer:GetAttribute("LobbyTraining") and (Character.Parent == workspace.Dead and true or false)
        if Character.Parent ~= Workspace.Alive and not (ENXAssets.DebugFlags.LobbyParry or (LocalPlayer:GetAttribute("LobbyParry") or IsInLobbyTrainning)) then
            IsBlockLegit = false
        end
        if Character:GetAttribute("DoNotParry") or Character:GetAttribute("ChargingAdrenaline") and LocalPlayer.Upgrades["Qi-Charge"].Value < 2 then
            IsBlockLegit = false
        end
        if LocalPlayer:GetAttribute("LobbyParry") and LocalPlayer:GetAttribute("InLobbyParryCooldown") then
            IsBlockLegit = false
        end

        local SafeModeEnabled = ENXData.Config.ParrySettings.SafeMode
        local ShouldExecuteRemoteFireServer = (IsBlockLegit and SafeModeEnabled) or not SafeModeEnabled
        if ShouldExecuteRemoteFireServer then
            local ParryData = GetParry_Data(ENXData.Config.ParrySettings.ParryCurveDirection, IsInLobbyTrainning)
            ExecuteRemoteFireServer(ParryData)
        end
    elseif ParryMethod == "Legit" then
        if _AZURE_PF then
            pcall(_AZURE_PF)
        end
    end

    if ENXData.Global.Parries <= 7 then
        ENXData.Global.Parries += 1
        task.delay(0.5, function()
            if ENXData.Global.Parries > 0 then
                ENXData.Global.Parries -= 1
            end
        end)
    end
end

local function Get_Balls()
    local BallInstances = {}
    for _, Instance in pairs(ENXData.Balls:GetChildren()) do
        if Instance:GetAttribute("realBall") then
            table.insert(BallInstances, Instance)
        end
    end
    return BallInstances
end

local function GetTraining_Balls()
    local BallInstances = {}
    for _, Instance in pairs(Workspace:WaitForChild("TrainingBalls"):GetChildren()) do
        if Instance:GetAttribute("realBall") then
            table.insert(BallInstances, Instance)
        end
    end
    return BallInstances
end

local function GetLinear_Interpolation(a, b, time_volume)
    return a + (b - a) * time_volume
end

local function IsBall_Curved(Ball, Ping, char)
    if not Ball then
        return false
    end

    local Zoomies = Ball:FindFirstChild("zoomies")

    if not Zoomies then
        return false
    end

    local velocity = Zoomies.VectorVelocity
    local ball_direction = velocity.Unit
    local direction = (char.PrimaryPart.Position - Ball.Position).Unit
    local dot = direction:Dot(ball_direction)
    local speed = velocity.Magnitude
    local speed_threshold = math.min(speed / 100, 40)
    local direction_difference = (ball_direction - velocity).Unit
    local direction_similarity = direction:Dot(direction_difference)
    local dot_difference = dot - direction_similarity
    local distance = (char.PrimaryPart.Position - Ball.Position).Magnitude
    local dot_threshold = 0.5 - (Ping / 1000)
    local reach_time = distance / speed - (Ping / 1000)
    local ball_distance_threshold = 15 - math.min(distance / 1000, 15) + speed_threshold
    local clamped_dot = math.clamp(dot, -1, 1)
    local radians = math.rad(math.asin(clamped_dot))

    ENXData.Parry[Ball].lerp_radians = GetLinear_Interpolation(ENXData.Parry[Ball].lerp_radians, radians, 0.8)
    if speed > 0 and reach_time > Ping / 10 then
        ball_distance_threshold = math.max(ball_distance_threshold - 15, 15)
    end

    if distance < ball_distance_threshold then
        return false
    end
    if dot_difference < dot_threshold then
        return true
    end
    if ENXData.Parry[Ball].lerp_radians < 0.018 then
        ENXData.Parry[Ball].last_warping = tick()
    end
    if (tick() - ENXData.Parry[Ball].last_warping) < (reach_time / 1.5) then
        return true
    end
    if (tick() - ENXData.Parry[Ball].curving) < (reach_time / 1.5) then
        return true
    end

    return dot < dot_threshold
end

local function GetClosest_Player()
    local closestPlayer = nil
    local closestDistance = math.huge
    local lpCharacter = GetCharacter()
    if not lpCharacter or not lpCharacter.PrimaryPart then
        return nil
    end

    for _, entity in ipairs(Workspace.Alive:GetChildren()) do
        if entity ~= lpCharacter and entity.PrimaryPart then
            local distance = (lpCharacter.PrimaryPart.Position - entity.PrimaryPart.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = entity
            end
        end
    end

    return closestPlayer, closestDistance
end

local function MainConnection()
    if not GetCharacter() or not GetCharacter().PrimaryPart then
        return
    end
    local IsSpamming = ENXData.Config.AutoSpamParry.Spamming or ENXData.Config.ManualSpamParry.Spamming
    do
        local BallsList = Get_Balls()
        if ENXData.Config.AutoParry.Enabled and not IsSpamming and not ENXData.Config.TriggerBot.Enabled then
            for _, Ball in pairs(BallsList) do
                if not Ball then continue end
                local zoomies = Ball:FindFirstChild('zoomies')
                if zoomies then
                    local velocity = zoomies.VectorVelocity
                    local distance = (GetCharacter().PrimaryPart.Position - Ball.Position).Magnitude
                    local ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue() / 10
                    local ping_threshold = (function()
                        local _p = Stats.Network.ServerStatsItem['Data Ping']:GetValue()
                        if _p < 100 then return math.clamp(ping / 10, 5, 17)
                        elseif _p < 200 then return math.clamp(ping / 10, 5, 25)
                        else return math.clamp(ping / 10, 5, 35) end
                    end)()
                    local speed = velocity.Magnitude
                    local capped_speed_diff = math.min(math.max(speed - 9.5, 0), 650)
                    local speed_divisor = (2.4 + capped_speed_diff * 0.002) * ENXData.Config.ParrySettings.SpeedDivisorMultiplier
                    local parry_accuracy = ping_threshold + math.max(speed / speed_divisor, 9.5)
                    ENXData.Global.AutoParryCurrentAccuracy = parry_accuracy
                end
            end
        else
            ENXData.Global.AutoParryCurrentAccuracy = 0
        end

        if false and ENXData.Config.LobbyAutoParry.Enabled then
            local LobbyBallsList = GetTraining_Balls()
            for _, Ball in pairs(LobbyBallsList) do
                if not Ball then
                    continue
                end

                if not ENXData.Parry[Ball] then
                    ENXData.Parry[Ball] = {
                        lastVelUnit = nil,
                        velHistory = {},
                        lerp_radians = 0,
                        last_warping = 0,
                        curving = tick(),
                        LastParry = os.clock(),
                        LobbyParried = false,
                        LobbyLastParry = os.clock(),
                        TargetConn = Ball:GetAttributeChangedSignal('target'):Connect(function()
                            local st = ENXData.Parry[Ball]
                            if st then
                                st.LobbyParried = false
                                st.LobbyLastParry = 0
                                st.Parried = false
                                st.LastParry = 0
                            end
                        end)
                    }
                end

                local Zoomies = Ball:FindFirstChild('zoomies')
                if not Zoomies then
                    continue
                end

                local Ball_Target = Ball:GetAttribute('target')
                local Velocity = Zoomies.VectorVelocity
                local Distance = (GetCharacter().PrimaryPart.Position - Ball.Position).Magnitude - 5
                local Ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue()
                local Ping_Threshold = (function()
                    local _p = Stats.Network.ServerStatsItem['Data Ping']:GetValue()
                    if _p < 100 then return math.clamp(Ping / 20, 5, 17)
                    elseif _p < 200 then return math.clamp(Ping / 20, 5, 25)
                    else return math.clamp(Ping / 20, 5, 35) end
                end)()
                local Speed = Velocity.Magnitude * 1.5
                local cappedSpeedDiff = math.min(math.max(Speed - 9.5, 0), 650)
                local speed_divisor_base = 2.4 + cappedSpeedDiff * 0.002
                local speed_divisor = speed_divisor_base * ENXData.Config.ParrySettings.LobbySpeedDivisorMultiplier
                local Parry_Accuracy = Ping_Threshold + math.max(Speed / speed_divisor, 9.5) + (Distance / 75) + (function()
                    local _p = Stats.Network.ServerStatsItem['Data Ping']:GetValue()
                    if _p < 100 then return 0
                    elseif _p < 200 then return Ping * 0.3
                    else return Ping * 0.5 end
                end)()
                local Curved = false

                local CurveVaildation = false

                local LobbyState = ENXData.Parry[Ball]
                if Ball_Target ~= tostring(ENXData.Player.LocalPlayer) then
                    LobbyState.LobbyParried = false
                elseif not LobbyState.LobbyParried and Distance <= Parry_Accuracy and not CurveVaildation then
                    if ENXData.Config.LobbyAutoParry.AnimationFix and ENXData.Config.ParrySettings.ParryMethod ~= "Legit" then
                        PlayParry_Animation()
                    end

                    FireParry()

                    LobbyState.LobbyLastParry = os.clock()
                    LobbyState.LobbyParried = true
                end
            end
        end

        if false and ENXData.Config.AutoSpamParry.Enabled then
            for _, Ball in pairs(BallsList) do
                local Zoomies = Ball:FindFirstChild('zoomies')
                if not Zoomies then
                    ENXData.Config.AutoSpamParry.Spamming = false
                    continue
                end

                local Closest_Entity, Closest_Distance = GetClosest_Player()
                local Root = GetCharacter() and GetCharacter().PrimaryPart

                if not Root then
                    ENXData.Config.AutoSpamParry.Spamming = false
                    continue
                end

                if not Closest_Entity or not Closest_Entity.PrimaryPart then
                    ENXData.Config.AutoSpamParry.Spamming = false
                    continue
                end

                local Ping = ENXAssets.ServerStatsItem["Data Ping"]:GetValue()
                local PingFactor = Ping / 500
                local BallSpeed = Zoomies.VectorVelocity.Magnitude

                local TargetCheck = 30.3
                if Ping <= 0 or Ping >= 130 then
                    if Ping <= 131 or Ping >= 160 then
                        if Ping <= 161 or Ping >= 225 then
                            if Ping > 226 and Ping < 500 then
                                TargetCheck = math.clamp(math.floor(math.max(BallSpeed / 4 + PingFactor, 32.5)), 32.5, 80)
                            end
                        else
                            TargetCheck = math.clamp(math.floor(math.max(BallSpeed / 4.25 + PingFactor, 29.5)), 29.5, 70)
                        end
                    else
                        TargetCheck = math.clamp(math.floor(math.max(BallSpeed / 4.65 + PingFactor, 27.25)), 27.25, 70)
                    end
                else
                    TargetCheck = math.clamp(math.floor(math.max(BallSpeed / 5 + PingFactor, 26)), 26, 70)
                end

                local RootPos = Root.Position
                local BallPos = Ball.Position
                local TargetPos = Closest_Entity.PrimaryPart.Position

                local DistToBall = (RootPos - BallPos).Magnitude
                local DistToTarget = (RootPos - TargetPos).Magnitude

                local ParryThreshold = ENXData.Config.AutoSpamParry.ParryThreshold or 1.5
                local BallCheck = TargetCheck * ParryThreshold
                local TargetRange = TargetCheck

                ENXData.Global.AutoSpamParryCurrentAccuracy = BallCheck

                local SpamVaildation = false
                if ENXData.Config.AutoSpamParry.DetectionMode == "Speed" then
                    SpamVaildation = ENXData.Global.Parries > 1
                elseif ENXData.Config.AutoSpamParry.DetectionMode == "Distance" then
                    SpamVaildation = true
                end
                ENXData.Config.AutoSpamParry.Spamming = DistToBall <= BallCheck and DistToTarget <= TargetRange and SpamVaildation
            end
        else
            ENXData.Config.AutoSpamParry.Spamming = false
            ENXData.Global.AutoSpamParryCurrentAccuracy = 0
        end

        if false and ENXData.Config.TriggerBot.Enabled and not IsSpamming then
            local burst = 2
            local rps = ENXData.Config.ParrySettings.SpammingRPS or 180
            if rps > 300 then burst = 4
            elseif rps > 180 then burst = 3 end

            for _, Ball in pairs(BallsList) do
                if not Ball then continue end

                local Ball_Target = Ball:GetAttribute('target')
                local char = ENXData.Player.LocalPlayer.Character
                local Singularity_Cape = char and char.PrimaryPart and char.PrimaryPart:FindFirstChild('SingularityCape')

                if Singularity_Cape then continue end
                if ENXData.Config.TriggerBot.InfinityDetection and ENXData.Config.ParrySettings.Detections.InfinityBall.Flag then continue end

                if Ball_Target == tostring(ENXData.Player.LocalPlayer) then
                    if ENXData.Config.TriggerBot.AnimationFix then
                        PlayParry_Animation()
                    end
                    for i = 1, burst do
                        fireSpam()
                    end
                    TriggerBotParried = true
                    ENXData.Global.LastTriggerBotParry = os.clock()
                    break
                end
            end
        end
        if #BallsList <= 0 then
            ENXData.Global.AutoSpamParryCurrentAccuracy = 0
        end
    end
end

task.spawn(function()
    while task.wait(5) do
        for Ball, State in pairs(ENXData.Parry) do
            if typeof(Ball) ~= "Instance" or not Ball.Parent then
                if type(State) == "table" and State.TargetConn then
                    pcall(function() State.TargetConn:Disconnect() end)
                end
                ENXData.Parry[Ball] = nil
            end
        end
    end
end)

ENXUI:Track(ENXData.Balls.ChildRemoved:Connect(function(Child)
    if ENXData.Parry[Child] then
        ENXData.Parry[Child].TargetConn:Disconnect()
        ENXData.Parry[Child] = nil
    end
    if Visuals.HitEffectService.BallEffects[Child] then
        local hit = Visuals.HitEffectService.BallEffects[Child]
        if hit and hit.Parent then hit:Destroy() end
        Visuals.HitEffectService.BallEffects[Child] = nil
    end
    ENXData.Global.Parries = 0
    ENXData.Config.Animation.SpamAnimationParries = 0
    ENXData.Config.AutoSpamParry.Spamming = false
    UI.BallStats.PeakSpeed = 0
end))

ENXUI:Track(Workspace:WaitForChild("TrainingBalls").ChildRemoved:Connect(function(Child)
    if ENXData.Parry[Child] then
        ENXData.Parry[Child].TargetConn:Disconnect()
        ENXData.Parry[Child] = nil
    end
    if Visuals.HitEffectService.BallEffects[Child] then
        local hit = Visuals.HitEffectService.BallEffects[Child]
        if hit and hit.Parent then hit:Destroy() end
        Visuals.HitEffectService.BallEffects[Child] = nil
    end
end))

local function MakeDraggable(Recv, update, speed)
    local dragToggle = nil
    local dragStart = nil
    local startPos = nil

    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(update, TweenInfo.new(speed), {Position = position}):Play()
    end

    Recv.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragToggle = true
            dragStart = input.Position
            startPos = update.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    ENXUI:Track(UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then
                updateInput(input)
            end
        end
    end))
end

function Visuals.VisualiserService:Enabled(value)
    if value then
        for _, VisualPart in pairs(Visuals.VisualParts) do
            VisualPart.Transparency = 0
        end
    else
        for _, VisualPart in pairs(Visuals.VisualParts) do
            VisualPart.Transparency = 1
        end
    end
end

local _lastVizColor = nil
function Visuals.VisualiserService:SetColor(color)
    if _lastVizColor == color then return end
    _lastVizColor = color
    for _, Part in pairs(Visuals.VisualParts) do
        TweenService:Create(Part, TweenInfo.new(0.2), {Color = color}):Play()
    end
end

function Visuals.VisualiserService:Update(hrp, position, size)
    local visualPart = Visuals.VisualParts[hrp]
    if visualPart and not visualPart.Parent then
        visualPart = nil
        Visuals.VisualParts[hrp] = nil
    end

    if not visualPart then
        local NewPart = Instance.new("Part")
        NewPart.Name = "VisualPart"
        NewPart.Anchored = true
        NewPart.CanCollide = false
        NewPart.CastShadow = false
        NewPart.Shape = Enum.PartType.Ball
        NewPart.Transparency = Visuals.VisualisersEnabled and 0 or 1
        NewPart.Material = Enum.Material.ForceField
        NewPart.Color = Color3.fromRGB(255, 255, 255)
        NewPart.Size = Vector3.new(size, size, size)
        NewPart.Parent = Workspace

        Visuals.VisualParts[hrp] = NewPart
        visualPart = NewPart
    end

    visualPart.Position = position
    if visualPart.Parent ~= Workspace then
        visualPart.Parent = Workspace
    end

    Visuals._vizSizes = Visuals._vizSizes or setmetatable({}, { __mode = "k" })
    local _lastSize = Visuals._vizSizes[visualPart]
    if not _lastSize or math.abs(_lastSize - size) > 0.5 then
        Visuals._vizSizes[visualPart] = size
        TweenService:Create(visualPart, TweenInfo.new(0.2), {Size = Vector3.new(size, size, size)}):Play()
    end
end

function Visuals.HitEffectService:Emit(ball, position)
    if not Visuals.HitEffectService.BallEffects[ball] then
        local HitEffect = Instance.new("Attachment")
        local Arcs = Instance.new("ParticleEmitter")

        HitEffect.Name = "HitEffect"
        HitEffect.Parent = ball
        Arcs.Enabled = false
        Arcs.RotSpeed = NumberRange.new(250)
        Arcs.VelocitySpread = -360
        Arcs.Texture = "rbxassetid://8084911316"
        Arcs.ZOffset = 1
        Arcs.LightEmission = 1
        Arcs.Rotation = NumberRange.new(-360, 360)
        Arcs.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1, 0),
            NumberSequenceKeypoint.new(0.25, 0, 0),
            NumberSequenceKeypoint.new(0.75, 0, 0),
            NumberSequenceKeypoint.new(1, 1, 0)
        })
        Arcs.Name = "Arcs"
        Arcs.Lifetime = NumberRange.new(1)
        Arcs.Speed = NumberRange.new(math.random(1, 3))
        Arcs.SpreadAngle = Vector2.new(-360, 360)
        Arcs.Rate = 0
        Arcs.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
        Arcs.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 10, 0),
            NumberSequenceKeypoint.new(1, 10, 0)
        })

        Arcs.Parent = HitEffect
        Visuals.HitEffectService.BallEffects[ball] = HitEffect
    end

    local BallEffect = Visuals.HitEffectService.BallEffects[ball].Arcs
    BallEffect:Emit(1)
end

function ManualSpamParryUIService:Visible(value)
    UI.SpamUI.ScreenGui.Enabled = value
end

function ManualSpamParryUIService:SetColor(value)
    if value then
        local TargetColor = ENXUI.Theme.Hightlight
        local BackgroundColorTween = TweenService:Create(UI.SpamUI.SpamButton, TweenInfo.new(0.2), {BackgroundColor3 = TargetColor})
        local StrokeColorTween = TweenService:Create(UI.SpamUI.SpamButton.UIStroke, TweenInfo.new(0.2), {Color = TargetColor})
        BackgroundColorTween:Play()
        StrokeColorTween:Play()
        UI.SpamUI.SpamButton.Text = "SPAMMING"
    else
        local TargetColor = Color3.new(152/255, 152/255, 152/255)
        local BackgroundColorTween = TweenService:Create(UI.SpamUI.SpamButton, TweenInfo.new(0.2), {BackgroundColor3 = TargetColor})
        local StrokeColorTween = TweenService:Create(UI.SpamUI.SpamButton.UIStroke, TweenInfo.new(0.2), {Color = TargetColor})
        BackgroundColorTween:Play()
        StrokeColorTween:Play()
        UI.SpamUI.SpamButton.Text = "SPAM"
    end
end

function TriggerBotUIService:Visible(value)
    UI.TriggerBotUI.ScreenGui.Enabled = value
end

function TriggerBotUIService:SetColor(value)
    if value then
        local TargetColor = ENXUI.Theme.Hightlight
        local BackgroundColorTween = TweenService:Create(UI.TriggerBotUI.TriggerButton, TweenInfo.new(0.2), {BackgroundColor3 = TargetColor})
        local StrokeColorTween = TweenService:Create(UI.TriggerBotUI.TriggerButton.UIStroke, TweenInfo.new(0.2), {Color = TargetColor})
        BackgroundColorTween:Play()
        StrokeColorTween:Play()
        UI.TriggerBotUI.TriggerButton.Text = "TB ACTIVE"
    else
        local TargetColor = Color3.new(152/255, 152/255, 152/255)
        local BackgroundColorTween = TweenService:Create(UI.TriggerBotUI.TriggerButton, TweenInfo.new(0.2), {BackgroundColor3 = TargetColor})
        local StrokeColorTween = TweenService:Create(UI.TriggerBotUI.TriggerButton.UIStroke, TweenInfo.new(0.2), {Color = TargetColor})
        BackgroundColorTween:Play()
        StrokeColorTween:Play()
        UI.TriggerBotUI.TriggerButton.Text = "TRIGGER BOT"
    end
end

function BallStatsUIService:Visible(value)
    if UI.BallStats.ScreenGui then
        UI.BallStats.ScreenGui.Enabled = value
    end
end

function StatsUIService:Visible(value)
    if UI.StatsUI.ScreenGui then
        UI.StatsUI.ScreenGui.Enabled = value
    end
end

local function SaveAllSettings()
    local data = {
        AutoParry = ENXData.Config.AutoParry,
        LobbyAutoParry = ENXData.Config.LobbyAutoParry,
        AutoSpamParry = {
            Enabled = ENXData.Config.AutoSpamParry.Enabled,
            Keybind = ENXData.Config.AutoSpamParry.Keybind,
            DetectionMode = ENXData.Config.AutoSpamParry.DetectionMode,
            AnimationFix = ENXData.Config.AutoSpamParry.AnimationFix,
            Threshold = ENXData.Config.AutoSpamParry.Threshold,
            ParryThreshold = ENXData.Config.AutoSpamParry.ParryThreshold,
            Reach = ENXData.Config.AutoSpamParry.Reach,
            SelfArm = ENXData.Config.AutoSpamParry.SelfArm,
            DistanceMultiplier = ENXData.Config.AutoSpamParry.DistanceMultiplier,
            CPS = ENXData.Config.AutoSpamParry.CPS,
            SpamBoost = ENXData.Config.AutoSpamParry.SpamBoost,
            Spamming = false,
        },
        ManualSpamParry = {
            UI = ENXData.Config.ManualSpamParry.UI,
            Keybind = ENXData.Config.ManualSpamParry.Keybind,
            AnimationFix = ENXData.Config.ManualSpamParry.AnimationFix,
            SuperSpam = ENXData.Config.ManualSpamParry.SuperSpam,
            SuperSpamClicks = ENXData.Config.ManualSpamParry.SuperSpamClicks,
            Spamming = false,
        },
        TriggerBot = ENXData.Config.TriggerBot,
        BallStats = ENXData.Config.BallStats,
        ClientStats = ENXData.Config.ClientStats,
        ParrySettings = ENXData.Config.ParrySettings,
        Visuals = {
            VisualisersEnabled = Visuals.VisualisersEnabled,
            HitEffectEnabled = Visuals.HitEffectEnabled,
        },
        AutoPlay = { AntiAFK = getgenv().AutoPlayAntiAFK == true },
        Immortality = Immortality,
        SemiImmortal = getgenv()._ENX_DesyncSaveState and getgenv()._ENX_DesyncSaveState() or nil,
        SkinChanger = SkinChanger,
        AnimationFixService = AnimationFixService,
    }
    SaveSettings(data)
end

local function LoadAllSettings()
    local data = LoadSettings()
    if data then
        for k, v in pairs(data) do
            if k == "AutoParry" then
                for kk, vv in pairs(v) do ENXData.Config.AutoParry[kk] = vv end
            elseif k == "LobbyAutoParry" then
                for kk, vv in pairs(v) do ENXData.Config.LobbyAutoParry[kk] = vv end
            elseif k == "AutoSpamParry" then
                for kk, vv in pairs(v) do ENXData.Config.AutoSpamParry[kk] = vv end
            elseif k == "ManualSpamParry" then
                for kk, vv in pairs(v) do ENXData.Config.ManualSpamParry[kk] = vv end
            elseif k == "TriggerBot" then
                for kk, vv in pairs(v) do ENXData.Config.TriggerBot[kk] = vv end
            elseif k == "BallStats" then
                ENXData.Config.BallStats.Enabled = v.Enabled
            elseif k == "ClientStats" then
                ENXData.Config.ClientStats.Enabled = v.Enabled
            elseif k == "ParrySettings" then
                for kk, vv in pairs(v) do
                    if kk == "Detections" and type(vv) == "table" then
                        local Dst = ENXData.Config.ParrySettings.Detections
                        for detName, detVal in pairs(vv) do
                            if type(detVal) == "table" and type(Dst[detName]) == "table" then
                                for fieldName, fieldVal in pairs(detVal) do
                                    Dst[detName][fieldName] = fieldVal
                                end
                            end
                        end
                    else
                        ENXData.Config.ParrySettings[kk] = vv
                    end
                end
            elseif k == "AutoPlay" then
                ENXData.Config.AutoPlay = ENXData.Config.AutoPlay or {}
                ENXData.Config.AutoPlay.AntiAFK = (v.AntiAFK == true)
            elseif k == "Visuals" then
                Visuals.VisualisersEnabled = v.VisualisersEnabled
                Visuals.HitEffectEnabled = v.HitEffectEnabled
            elseif k == "Immortality" then
                for kk, vv in pairs(v) do Immortality[kk] = vv end
            elseif k == "SemiImmortal" then
                getgenv()._ENX_DesyncSavedBlob = v
            elseif k == "SkinChanger" then
                for kk, vv in pairs(v) do SkinChanger[kk] = vv end
            elseif k == "AnimationFixService" then
                for kk, vv in pairs(v) do AnimationFixService[kk] = vv end
            end
        end
        return true
    end
    return false
end

do
    local ok, err = pcall(function()
        return LoadAllSettings()
    end)
    if ok then
        ENXData.Global.SettingsPreloaded = err and true or false
    else
        ENXData.Global.SettingsPreloaded = false
    end

    ENXData.Config.ManualSpamParry.Spamming = false
    ENXData.Config.AutoSpamParry.Spamming = false
    do
        local _pth = tonumber(ENXData.Config.AutoSpamParry.ParryThreshold)
        if _pth then
            _pth = math.clamp(_pth, 0.1, 3)
            ENXData.Config.AutoSpamParry.ParryThreshold = _pth
            getgenv().AutoSpamThreshold = _pth
        end
        getgenv().SpamBoost = (ENXData.Config.AutoSpamParry.SpamBoost == true)
        getgenv().ParryBoost = (ENXData.Config.AutoParry.ParryBoost == true)
        local _Sys = getgenv()._ENX_System
        if _Sys and _Sys.__properties then
            if _pth then _Sys.__properties.__spam_threshold = _pth end
            local _lacc = tonumber(ENXData.Config.ParrySettings.LobbyAutoParryAccuracy)
            if _lacc and getgenv().ParryBoost ~= true then
                _Sys.__properties.__accuracy = math.clamp(_lacc, 1, 100)
            end
            local _acc = tonumber(ENXData.Config.ParrySettings.AutoParryAccuracy)
            if _acc then
                _acc = math.clamp(_acc, 1, 100)
                ENXData.Config.ParrySettings.AutoParryAccuracy = _acc
                ENXData.Config.ParrySettings.SpeedDivisorMultiplier = 0.7 + (_acc - 1) * (0.35 / 99)
                if getgenv().ParryBoost ~= true then
                    local _mapped = 1 + (_acc - 1) * (79 / 99)
                    _Sys.__properties.__accuracy = _acc
                    _Sys.__properties.__divisor_multiplier = 0.75 + (_mapped - 1) * (3 / 99)
                end
            end
        end
        getgenv().AutoParryAnimationFix = (ENXData.Config.AutoParry.AnimationFix == true)
        getgenv().AutoSpamAnimationFix = (ENXData.Config.AutoSpamParry.AnimationFix == true)
        getgenv().ManualSpamAnimationFix = (ENXData.Config.ManualSpamParry.AnimationFix == true)
        local _reach = tonumber(ENXData.Config.AutoSpamParry.Reach)
        if _reach then getgenv().AutoSpamReach = math.clamp(_reach, 0.1, 3) end
        if ENXData.Config.AutoSpamParry.SelfArm ~= nil then
            getgenv().AutoSpamSelfArm = (ENXData.Config.AutoSpamParry.SelfArm == true)
        end
    end
    ENXData.Global.AutoParryParried = false

    local PS = ENXData.Config.ParrySettings
    if type(PS.AutoParryAccuracy) == "number" then
        PS.SpeedDivisorMultiplier = 0.7 + (PS.AutoParryAccuracy - 1) * (0.35 / 99)
    end
    if type(PS.LobbyAutoParryAccuracy) == "number" then
        PS.LobbySpeedDivisorMultiplier = 0.7 + (PS.LobbyAutoParryAccuracy - 1) * (0.35 / 99)
    end
end

do
    local CombatTab = getgenv()._ENX_Tabs.Combat

    local AutoParrySection = CombatTab:AddSection({
        Name = "Auto Parry",
        Position = "left"
    })

    local LobbyAutoParrySection = CombatTab:AddSection({
        Name = "Lobby Auto Parry",
        Position = "left"
    })

    local AutoSpamParrySection = CombatTab:AddSection({
        Name = "Auto Spam Parry [BETA]",
        Position = "right"
    })

    local ManualSpamParrySection = CombatTab:AddSection({
        Name = "Manual Spam Parry",
        Position = "right"
    })

    local TriggerBotSection = CombatTab:AddSection({
        Name = "Trigger Bot",
        Position = "left"
    })

    do
        UI.AutoParryToggle = AutoParrySection:AddToggle({
            Name = 'Enabled',
            Default = ENXData.Config.AutoParry.Enabled,
            Callback = function(value)
                ENXData.Config.AutoParry.Enabled = value
                local Sys = getgenv()._ENX_System
                if Sys and Sys.__properties then
                    Sys.__properties.__autoparry_enabled = value
                    if value then
                        pcall(Sys.autoparry.start)
                    else
                        pcall(Sys.autoparry.stop)
                    end
                end
                SaveAllSettings()
            end,
        })

        AutoParrySection:AddSlider({
            Name = "Accuracy",
            Min = 1,
            Max = 100,
            Round = 0,
            Default = ENXData.Config.ParrySettings.AutoParryAccuracy,
            Type = "%",
            Callback = function(value)
                ENXData.Config.ParrySettings.AutoParryAccuracy = value
                ENXData.Config.ParrySettings.SpeedDivisorMultiplier = 0.7 + (value - 1) * (0.35 / 99)
                local Sys = getgenv()._ENX_System
                if Sys and Sys.__properties then
                    local mapped_accuracy = 1 + (value - 1) * (79 / 99)
                    Sys.__properties.__divisor_multiplier = 0.75 + (mapped_accuracy - 1) * (3 / 99)
                    Sys.__properties.__accuracy = value
                end
                SaveAllSettings()
            end,
        })

        AutoParrySection:AddKeybind({
            Name = "Keybind",
            Default = ENXData.Config.AutoParry.Keybind,
            Callback = function(key)
                ENXData.Config.AutoParry.Keybind = key
                SaveAllSettings()
            end,
        })

        AutoParrySection:AddToggle({
            Name = 'Animation Fix',
            Default = ENXData.Config.AutoParry.AnimationFix,
            Callback = function(value)
                ENXData.Config.AutoParry.AnimationFix = value
                getgenv().AutoParryAnimationFix = value
                SaveAllSettings()
            end,
        })

        AutoParrySection:AddToggle({
            Name = 'Parry Boost',
            Default = ENXData.Config.AutoParry.ParryBoost or false,
            Callback = function(value)
                ENXData.Config.AutoParry.ParryBoost = value
                getgenv().ParryBoost = value
                if value then
                    local Sys = getgenv()._ENX_System
                    if Sys and Sys.__properties then
                        Sys.__properties.__accuracy = 100
                        Sys.__properties.__divisor_multiplier = 0.75 + ((1 + (100 - 1) * (79 / 99)) - 1) * (3 / 99)
                    end
                else
                    local Sys = getgenv()._ENX_System
                    if Sys and Sys.__properties then
                        local acc0 = math.clamp(ENXData.Config.ParrySettings.AutoParryAccuracy or 100, 1, 100)
                        local mapped0 = 1 + (acc0 - 1) * (79 / 99)
                        Sys.__properties.__accuracy = acc0
                        Sys.__properties.__divisor_multiplier = 0.75 + (mapped0 - 1) * (3 / 99)
                    end
                end
                SaveAllSettings()
            end,
        })

        AutoParrySection:AddDivider({
            Color = Color3.fromRGB(50, 50, 50),
            Height = 1
        })

        do
            local Sys = getgenv()._ENX_System
            local saved = ENXData.Config.AutoParry.CurveDirection or ENXData.Config.ParrySettings.ParryCurveDirection
            if Sys and Sys.__config and Sys.__config.__curve_names and type(saved) == "string" then
                for i, name in ipairs(Sys.__config.__curve_names) do
                    if name == saved then
                        Sys.__properties.__curve_mode = i
                        break
                    end
                end
            end
        end
        AutoParrySection:AddDropdown({
            Name = "Curve Direction",
            Default = ENXData.Config.AutoParry.CurveDirection or "Camera",
            Values = (getgenv()._ENX_System and getgenv()._ENX_System.__config and getgenv()._ENX_System.__config.__curve_names) or {'Camera', 'Random', 'Accelerated', 'Backwards', 'Slow', 'High', 'Left', 'Right', 'Straight', 'RandomTarget', 'Forward', 'Up', 'Down'},
            Callback = function(value)
                ENXData.Config.AutoParry.CurveDirection = value
                ENXData.Config.ParrySettings.ParryCurveDirection = value
                local Sys = getgenv()._ENX_System
                if Sys and Sys.__config and Sys.__config.__curve_names and Sys.__properties then
                    for i, name in ipairs(Sys.__config.__curve_names) do
                        if name == value then
                            Sys.__properties.__curve_mode = i
                            break
                        end
                    end
                end
                SaveAllSettings()
            end,
        })

        getgenv().RandomParryAccuracyEnabled = getgenv().RandomParryAccuracyEnabled or (ENXData.Config.ParrySettings.RandomParryAccuracy == true)
        getgenv().HumanizerMin = getgenv().HumanizerMin or (type(ENXData.Config.ParrySettings.HumanizerMin) == "number" and math.clamp(ENXData.Config.ParrySettings.HumanizerMin, 1, 100) or 1)
        getgenv().HumanizerMax = getgenv().HumanizerMax or (type(ENXData.Config.ParrySettings.HumanizerMax) == "number" and math.clamp(ENXData.Config.ParrySettings.HumanizerMax, 1, 100) or 100)
        AutoParrySection:AddToggle({
            Name = 'Humanizer (Random Parry Accuracy)',
            Default = getgenv().RandomParryAccuracyEnabled == true,
            Callback = function(value)
                getgenv().RandomParryAccuracyEnabled = value
                ENXData.Config.ParrySettings.RandomParryAccuracy = value
                SaveAllSettings()
            end,
        })

        AutoParrySection:AddSlider({
            Name = 'Humanizer Min',
            Min = 1, Max = 100, Round = 0,
            Default = getgenv().HumanizerMin or 1, Type = "",
            Callback = function(value)
                getgenv().HumanizerMin = math.clamp(value, 1, 100)
                ENXData.Config.ParrySettings.HumanizerMin = getgenv().HumanizerMin
                SaveAllSettings()
            end,
        })

        AutoParrySection:AddSlider({
            Name = 'Humanizer Max',
            Min = 1, Max = 100, Round = 0,
            Default = getgenv().HumanizerMax or 100, Type = "",
            Callback = function(value)
                getgenv().HumanizerMax = math.clamp(value, 1, 100)
                ENXData.Config.ParrySettings.HumanizerMax = getgenv().HumanizerMax
                SaveAllSettings()
            end,
        })

        AutoParrySection:AddLabel("Humanizer ON = the Accuracy slider is overridden by the Min/Max draw (classic design)")

        AutoParrySection:AddDivider({
            Color = Color3.fromRGB(50, 50, 50),
            Height = 1
        })

        AutoParrySection:AddToggle({
            Name = 'Infinity Detection',
            Default = ENXData.Config.ParrySettings.Detections.InfinityBall.Enabled,
            Callback = function(value)
                ENXData.Config.ParrySettings.Detections.InfinityBall.Enabled = value
                local Sys = getgenv()._ENX_System
                if Sys and Sys.__config and Sys.__config.__detections then
                    Sys.__config.__detections.__infinity = value
                end
                SaveAllSettings()
            end,
        })

        AutoParrySection:AddToggle({
            Name = 'Death Slash Detection',
            Default = ENXData.Config.ParrySettings.Detections.DeathSlashBall.Enabled,
            Callback = function(value)
                ENXData.Config.ParrySettings.Detections.DeathSlashBall.Enabled = value
                local Sys = getgenv()._ENX_System
                if Sys and Sys.__config and Sys.__config.__detections then
                    Sys.__config.__detections.__deathslash = value
                end
                SaveAllSettings()
            end,
        })

        AutoParrySection:AddToggle({
            Name = 'Time Hole Detection',
            Default = ENXData.Config.ParrySettings.Detections.TimeHole.Enabled,
            Callback = function(value)
                ENXData.Config.ParrySettings.Detections.TimeHole.Enabled = value
                local Sys = getgenv()._ENX_System
                if Sys and Sys.__config and Sys.__config.__detections then
                    Sys.__config.__detections.__timehole = value
                end
                SaveAllSettings()
            end,
        })

        AutoParrySection:AddDivider({
            Color = Color3.fromRGB(50, 50, 50),
            Height = 1
        })

        AutoParrySection:AddToggle({
            Name = 'Slashes of Fury Detection',
            Default = ENXData.Config.ParrySettings.Detections.SlashesofFury.Enabled,
            Callback = function(value)
                ENXData.Config.ParrySettings.Detections.SlashesofFury.Enabled = value
                local Sys = getgenv()._ENX_System
                if Sys and Sys.__config and Sys.__config.__detections then
                    Sys.__config.__detections.__slashesoffury = value
                end
                SaveAllSettings()
            end,
        })

        AutoParrySection:AddSlider({
            Name = "Count",
            Min = 1,
            Max = 36,
            Round = 0,
            Default = ENXData.Config.ParrySettings.SlashesofFuryDetectionMaxParryCount,
            Type = "",
            Callback = function(value)
                ENXData.Config.ParrySettings.SlashesofFuryDetectionMaxParryCount = value
                SaveAllSettings()
            end,
        })

        AutoParrySection:AddSlider({
            Name = "Delay",
            Min = 0,
            Max = 1,
            Round = 2,
            Default = ENXData.Config.ParrySettings.SlashesofFuryDetectionParryDelay,
            Type = "",
            Callback = function(value)
                ENXData.Config.ParrySettings.SlashesofFuryDetectionParryDelay = value
                SaveAllSettings()
            end,
        })

        AutoParrySection:AddDivider({
            Color = Color3.fromRGB(50, 50, 50),
            Height = 1
        })

        do
            local AddedDetections = {
                {Name = 'Forcefield Detection',    Key = 'Forcefield',  SapKey = '__forcefield'},
                {Name = 'Phantom Detection',       Key = 'Phantom',     SapKey = '__phantom'},
                {Name = 'Singularity Detection',   Key = 'Singularity'},
                {Name = 'Dribble Detection',       Key = 'Dribble',   SapKey = '__dribble'},
                {Name = 'Pull Detection',          Key = 'Pull',      SapKey = '__pull'},
                {Name = 'Pulse Detection',         Key = 'Pulse'},
                {Name = 'Tornado Detection',       Key = 'Tornado'},
                {Name = 'Anti Hell Hook',          Key = 'HellHook'},
            }
            for _, det in ipairs(AddedDetections) do
                AutoParrySection:AddToggle({
                    Name = det.Name,
                    Default = ENXData.Config.ParrySettings.Detections[det.Key].Enabled,
                    Callback = function(value)
                        ENXData.Config.ParrySettings.Detections[det.Key].Enabled = value
                        if det.SapKey then
                            local Sys = getgenv()._ENX_System
                            if Sys and Sys.__config and Sys.__config.__detections then
                                Sys.__config.__detections[det.SapKey] = value
                            end
                            if det.SapKey == '__dribble' then
                                getgenv().DribbleDetection = value
                            elseif det.SapKey == '__pull' then
                                getgenv().PullDetection = value
                            end
                        end
                        SaveAllSettings()
                    end,
                })
            end
        end

        AutoParrySection:AddDivider({
            Color = Color3.fromRGB(50, 50, 50),
            Height = 1
        })

    end

    do
        LobbyAutoParrySection:AddToggle({
            Name = 'Enabled',
            Default = ENXData.Config.LobbyAutoParry.Enabled,
            Callback = function(value)
                ENXData.Config.LobbyAutoParry.Enabled = value
                local Sys = getgenv()._ENX_System
                if Sys and Sys.__properties then
                    if value then
                        Sys.__properties.__autoparry_enabled = true
                        pcall(Sys.autoparry.start)
                    else
                        if not ENXData.Config.AutoParry.Enabled then
                            Sys.__properties.__autoparry_enabled = false
                            pcall(Sys.autoparry.stop)
                        end
                    end
                end
                SaveAllSettings()
            end,
        })

        LobbyAutoParrySection:AddSlider({
            Name = "Accuracy",
            Min = 1,
            Max = 100,
            Round = 0,
            Default = ENXData.Config.ParrySettings.LobbyAutoParryAccuracy,
            Type = "%",
            Callback = function(value)
                ENXData.Config.ParrySettings.LobbyAutoParryAccuracy = value
                ENXData.Config.ParrySettings.LobbySpeedDivisorMultiplier = 0.7 + (value - 1) * (0.35 / 99)
                local Sys = getgenv()._ENX_System
                if Sys and Sys.__properties then
                    Sys.__properties.__accuracy = value
                end
                SaveAllSettings()
            end,
        })

        LobbyAutoParrySection:AddToggle({
            Name = 'Animation Fix',
            Default = ENXData.Config.LobbyAutoParry.AnimationFix,
            Callback = function(value)
                ENXData.Config.LobbyAutoParry.AnimationFix = value
                SaveAllSettings()
            end,
        })
    end

    do
        UI.AutoSpamToggle = AutoSpamParrySection:AddToggle({
            Name = 'Enabled',
            Default = ENXData.Config.AutoSpamParry.Enabled,
            Callback = function(value)
                ENXData.Config.AutoSpamParry.Enabled = value
                local Sys = getgenv()._ENX_System
                if Sys and Sys.auto_spam then
                    if value then
                        pcall(Sys.auto_spam.start)
                    else
                        pcall(Sys.auto_spam.stop)
                    end
                end
                SaveAllSettings()
            end,
        })

        AutoSpamParrySection:AddSlider({
            Name = "Spam Reach",
            Min = 0.1,
            Max = 3,
            Round = 1,
            Default = math.clamp(ENXData.Config.AutoSpamParry.Reach or 1, 0.1, 3),
            Type = "x",
            Callback = function(value)
                local v3 = math.clamp(value, 0.1, 3)
                ENXData.Config.AutoSpamParry.Reach = v3
                getgenv().AutoSpamReach = v3
                SaveAllSettings()
            end,
        })

        AutoSpamParrySection:AddToggle({
            Name = 'Self Arm',
            Default = ENXData.Config.AutoSpamParry.SelfArm ~= false,
            Callback = function(value)
                ENXData.Config.AutoSpamParry.SelfArm = value
                getgenv().AutoSpamSelfArm = value
                SaveAllSettings()
            end,
        })

        AutoSpamParrySection:AddSlider({
            Name = "Parry Threshold",
            Min = 0.1,
            Max = 3,
            Round = 1,
            Default = ENXData.Config.AutoSpamParry.ParryThreshold or 1,
            Type = "x",
            Callback = function(value)
                local v2 = math.clamp(value, 0.1, 3)
                ENXData.Config.AutoSpamParry.ParryThreshold = v2
                getgenv().AutoSpamThreshold = v2
                local Sys = getgenv()._ENX_System
                if Sys and Sys.__properties then Sys.__properties.__spam_threshold = v2 end
                SaveAllSettings()
            end,
        })

        AutoSpamParrySection:AddToggle({
            Name = 'Animation Fix',
            Default = ENXData.Config.AutoSpamParry.AnimationFix,
            Callback = function(value)
                ENXData.Config.AutoSpamParry.AnimationFix = value
                getgenv().AutoSpamAnimationFix = value
                SaveAllSettings()
            end,
        })
    end

    do
        UI.ManualSpamParryToggle = ManualSpamParrySection:AddToggle({
            Name = 'Active',
            Default = ENXData.Config.ManualSpamParry.Spamming,
            Callback = function(value)
                ENXData.Config.ManualSpamParry.Spamming = value
                ManualSpamParryUIService:SetColor(value)
                local Sys = getgenv()._ENX_System
                if Sys and Sys.manual_spam then
                    if value then
                        getgenv().ManualSpamCPSEnabled = true
                        getgenv().ManualSpamCPS = 2000
                        pcall(Sys.manual_spam.start)
                    else
                        pcall(Sys.manual_spam.stop)
                    end
                end
                SaveAllSettings()
            end,
        })

        ManualSpamParrySection:AddToggle({
            Name = 'UI',
            Default = ENXData.Config.ManualSpamParry.UI,
            Callback = function(value)
                ENXData.Config.ManualSpamParry.UI = value
                ManualSpamParryUIService:Visible(value)
                SaveAllSettings()
            end,
        })

        ManualSpamParrySection:AddKeybind({
            Name = "Keybind",
            Default = ENXData.Config.ManualSpamParry.Keybind,
            Callback = function(key)
                ENXData.Config.ManualSpamParry.Keybind = key
                SaveAllSettings()
            end,
        })

        ManualSpamParrySection:AddToggle({
            Name = 'Animation Fix',
            Default = ENXData.Config.ManualSpamParry.AnimationFix,
            Callback = function(value)
                ENXData.Config.ManualSpamParry.AnimationFix = value
                getgenv().ManualSpamAnimationFix = value
                SaveAllSettings()
            end,
        })

        ManualSpamParrySection:AddToggle({
            Name = 'Enable CPS Mode',
            Default = true,
            Callback = function(value)
                getgenv().ManualSpamCPSEnabled = value
                SaveAllSettings()
            end,
        })

        ManualSpamParrySection:AddSlider({
            Name = "CPS (max 2000)",
            Min = 1,
            Max = 2000,
            Round = 0,
            Default = 2000,
            Type = " cps",
            Callback = function(value)
                getgenv().ManualSpamCPS = value
                SaveAllSettings()
            end,
        })
    end

    do
        UI.TriggerBotToggle = TriggerBotSection:AddToggle({
            Name = 'Active',
            Default = ENXData.Config.TriggerBot.Enabled,
            Callback = function(value)
                ENXData.Config.TriggerBot.Enabled = value
                TriggerBotUIService:SetColor(value)
                local Sys = getgenv()._ENX_System
                if Sys and Sys.triggerbot then
                    Sys.__properties.__triggerbot_enabled = value
                    pcall(Sys.triggerbot.enable, value)
                end
                SaveAllSettings()
            end,
        })

        TriggerBotSection:AddToggle({
            Name = 'UI',
            Default = ENXData.Config.TriggerBot.UI,
            Callback = function(value)
                ENXData.Config.TriggerBot.UI = value
                TriggerBotUIService:Visible(value)
                SaveAllSettings()
            end,
        })

        TriggerBotSection:AddKeybind({
            Name = "Keybind",
            Default = ENXData.Config.TriggerBot.Keybind,
            Callback = function(key)
                ENXData.Config.TriggerBot.Keybind = key
                SaveAllSettings()
            end,
        })

        TriggerBotSection:AddToggle({
            Name = 'Animation Fix',
            Default = ENXData.Config.TriggerBot.AnimationFix,
            Callback = function(value)
                ENXData.Config.TriggerBot.AnimationFix = value
                SaveAllSettings()
            end,
        })

        TriggerBotSection:AddDivider({
            Color = Color3.fromRGB(50, 50, 50),
            Height = 1
        })

        TriggerBotSection:AddToggle({
            Name = 'Infinity Detection',
            Default = ENXData.Config.TriggerBot.InfinityDetection,
            Callback = function(value)
                ENXData.Config.TriggerBot.InfinityDetection = value
                SaveAllSettings()
            end,
        })
    end

    local SettingsTab = getgenv()._ENX_Tabs.Settings

    local SpammingSection = SettingsTab:AddSection({
        Name = "Spamming",
        Position = "left"
    })

    UI.SpamLoopRPSLabel = SpammingSection:AddLabel("Loop RPS: 0")
    UI.SpamAccumulatorLabel = SpammingSection:AddLabel("Accumulator: 0")

    SpammingSection:AddDivider({
        Color = Color3.fromRGB(50, 50, 50),
        Height = 1
    })

    SpammingSection:AddSlider({
        Name = "Target RPS",
        Min = 60,
        Max = 640,
        Round = 0,
        Default = ENXData.Config.ParrySettings.SpammingRPS,
        Type = " rps",
        Callback = function(value)
            ENXData.Config.ParrySettings.SpammingRPS = value
            SaveAllSettings()
        end,
    })

    SpammingSection:AddButton({
        Name = "Reset Accumulator",
        Callback = function()
            ResetAccumulator()
        end,
    })

    local ParrySystemSection = SettingsTab:AddSection({
        Name = "Parry System",
        Position = "right"
    })

    ParrySystemSection:AddDropdown({
        Name = "Method",
        Default = ENXData.Config.ParrySettings.ParryMethod,
        Values = {"Legit", "Blatant"},
        Callback = function(value)
            ENXData.Config.ParrySettings.ParryMethod = value
            SaveAllSettings()
        end,
    })

    ParrySystemSection:AddDivider({
        Color = Color3.fromRGB(50, 50, 50),
        Height = 2
    })

    ParrySystemSection:AddButton({
        Name = "Refetch function",
        Callback = function()
            ENXNotify.new("EclipseNexus", "Attempting to re-fetch parry function, might cause a possible freeze", 5)
            local Result = AttemptFunctionFetch()
            ParryDATA.ParryFunction = Result.ParryFunction
            ParryDATA.ParryRemote = Result.ParryRemote

            if ParryDATA.ParryFunction and ParryDATA.ParryRemote then
                ENXNotify.new('EclipseNexus', 'Successfully fetched game data.', 5)
            else
                ENXNotify.new('EclipseNexus', 'Failed to fetch game data, please check developer console.', 5)
            end
        end,
    })

    ParrySystemSection:AddDivider({
        Color = Color3.fromRGB(50, 50, 50),
        Height = 1
    })

    ParrySystemSection:AddDropdown({
        Name = "Curve Direction",
        Default = ENXData.Config.ParrySettings.ParryCurveDirection or ENXData.Config.AutoParry.CurveDirection or "Camera",
        Values = (getgenv()._ENX_System and getgenv()._ENX_System.__config and getgenv()._ENX_System.__config.__curve_names) or {'Camera', 'Random', 'Accelerated', 'Backwards', 'Slow', 'High', 'Left', 'Right', 'Straight', 'RandomTarget', 'Forward', 'Up', 'Down'},
        Callback = function(value)
            ENXData.Config.ParrySettings.ParryCurveDirection = value
            ENXData.Config.AutoParry.CurveDirection = value
            local Sys = getgenv()._ENX_System
            if Sys and Sys.__config and Sys.__config.__curve_names and Sys.__properties then
                for i, name in ipairs(Sys.__config.__curve_names) do
                    if name == value then
                        Sys.__properties.__curve_mode = i
                        break
                    end
                end
            end
            SaveAllSettings()
        end,
    })

    ParrySystemSection:AddToggle({
        Name = 'Safe Mode',
        Default = ENXData.Config.ParrySettings.SafeMode,
        Callback = function(value)
            ENXData.Config.ParrySettings.SafeMode = value
            SaveAllSettings()
        end,
    })

    local AnimationFixSection = SettingsTab:AddSection({
        Name = "Animation Fix",
        Position = "left"
    })

    AnimationFixSection:AddSlider({
        Name = "Max Rate",
        Min = 30,
        Max = 240,
        Round = 0,
        Default = AnimationFixService.Rate,
        Type = " FPS",
        Callback = function(value)
            AnimationFixService.Rate = value
            SaveAllSettings()
        end,
    })

    AnimationFixSection:AddToggle({
        Name = 'Spam FE',
        Default = AnimationFixService.FEMode,
        Callback = function(value)
            AnimationFixService.FEMode = value
            SaveAllSettings()
        end,
    })

    local UtilitiesSettingsSection = SettingsTab:AddSection({
        Name = "Utilities",
        Position = "right"
    })

    UtilitiesSettingsSection:AddButton({
        Name = "FPS Boost",
        Callback = function()
            loadstring(game:HttpGet("https://pastebin.com/raw/EjPHWj2u"))()
        end,
    })

    local ConfigSection = SettingsTab:AddSection({
        Name = "Configuration",
        Position = "right"
    })

    ConfigSection:AddButton({
        Name = "Reset Config",
        Callback = function()
            local removed = false
            pcall(function()
                if isfile and isfile(SETTINGS_FILE) and delfile then
                    delfile(SETTINGS_FILE)
                    removed = true
                end
            end)
            if removed then
                ENXNotify.new('EclipseNexus', 'Config reset. Rejoin or reload to apply defaults.', 5)
            else
                ENXNotify.new('EclipseNexus', 'No config file to reset.', 3)
            end
        end,
    })

    local MaintenceSection = SettingsTab:AddSection({
        Name = "Maintenance",
        Position = "left"
    })

    MaintenceSection:AddButton({
        Name = "Clear Cache",
        Callback = function()
            ClearCache()
        end,
    })

    MaintenceSection:AddButton({
        Name = "Unload",
        Callback = function()
            UnloadENX()
        end,
    })
end

do
    UI.SpamUI.ScreenGui = Instance.new("ScreenGui")
    UI.SpamUI.ScreenGui.Name = "ScreenGui"
    UI.SpamUI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    UI.SpamUI.ScreenGui.ResetOnSpawn = false
    UI.SpamUI.ScreenGui.IgnoreGuiInset = true
    UI.SpamUI.ScreenGui.Parent = CoreGui

    ENXUI.ProtectGui(UI.SpamUI.ScreenGui)

    UI.SpamUI.Handler = Instance.new("CanvasGroup")
    UI.SpamUI.Handler.Name = "Handler"
    UI.SpamUI.Handler.Position = UDim2.new(0.5, 0, 0.5, 0)
    UI.SpamUI.Handler.Size = UDim2.new(0, 140, 0, 80)
    UI.SpamUI.Handler.BackgroundColor3 = Color3.new(1, 1, 1)
    UI.SpamUI.Handler.BackgroundTransparency = 1
    UI.SpamUI.Handler.BorderSizePixel = 0
    UI.SpamUI.Handler.BorderColor3 = Color3.new(0, 0, 0)
    UI.SpamUI.Handler.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.SpamUI.Handler.Transparency = 1
    UI.SpamUI.Handler.ClipsDescendants = true
    UI.SpamUI.Handler.Active = true
    UI.SpamUI.Handler.Parent = UI.SpamUI.ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.Name = "UICorner"
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = UI.SpamUI.Handler

    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Name = "ButtonFrame"
    ButtonFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    ButtonFrame.Size = UDim2.new(1, 0, 1, 0)
    ButtonFrame.BackgroundColor3 = Color3.new(0.0470588, 0.0470588, 0.0470588)
    ButtonFrame.BackgroundTransparency = 0.1
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.BorderColor3 = Color3.new(0, 0, 0)
    ButtonFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ButtonFrame.Transparency = 0.1
    ButtonFrame.Parent = UI.SpamUI.Handler

    UI.SpamUI.SpamButton = Instance.new("TextButton")
    UI.SpamUI.SpamButton.Name = "SpamButton"
    UI.SpamUI.SpamButton.Position = UDim2.new(0.5, 0, 0.5, 0)
    UI.SpamUI.SpamButton.Size = UDim2.new(1, -15, 1, -15)
    UI.SpamUI.SpamButton.BackgroundColor3 = Color3.new(152/255, 152/255, 152/255)
    UI.SpamUI.SpamButton.BackgroundTransparency = 0.75
    UI.SpamUI.SpamButton.BorderSizePixel = 0
    UI.SpamUI.SpamButton.BorderColor3 = Color3.new(0, 0, 0)
    UI.SpamUI.SpamButton.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.SpamUI.SpamButton.TextTransparency = 0.25
    UI.SpamUI.SpamButton.Text = "SPAM"
    UI.SpamUI.SpamButton.TextColor3 = Color3.new(1, 1, 1)
    UI.SpamUI.SpamButton.TextSize = 18
    UI.SpamUI.SpamButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    UI.SpamUI.SpamButton.TextScaled = false
    UI.SpamUI.SpamButton.TextWrapped = true
    UI.SpamUI.SpamButton.Parent = ButtonFrame

    local UICorner2 = Instance.new("UICorner")
    UICorner2.Name = "UICorner"
    UICorner2.CornerRadius = UDim.new(0, 2)
    UICorner2.Parent = UI.SpamUI.SpamButton

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Name = "UIStroke"
    UIStroke.Color = Color3.new(152/255, 152/255, 152/255)
    UIStroke.Transparency = 0.5
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = UI.SpamUI.SpamButton

    local UIStroke2 = Instance.new("UIStroke")
    UIStroke2.Name = "UIStroke"
    UIStroke2.Color = Color3.new(0, 0.0980392, 0.133333)
    UIStroke2.Transparency = 0.85
    UIStroke2.Parent = UI.SpamUI.Handler

    local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
    UIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
    UIAspectRatioConstraint.AspectRatio = 2
    UIAspectRatioConstraint.Parent = UI.SpamUI.Handler

    local function ToggleSpam()
        ENXData.Config.ManualSpamParry.Spamming = not ENXData.Config.ManualSpamParry.Spamming
        UI.ManualSpamParryToggle:SetValue(ENXData.Config.ManualSpamParry.Spamming)
        ManualSpamParryUIService:SetColor(ENXData.Config.ManualSpamParry.Spamming)
        SaveAllSettings()
    end

    UI.SpamUI.SpamButton.MouseButton1Click:Connect(ToggleSpam)
    MakeDraggable(UI.SpamUI.Handler, UI.SpamUI.Handler, 0.2)
end

do
    UI.TriggerBotUI.ScreenGui = Instance.new("ScreenGui")
    UI.TriggerBotUI.ScreenGui.Name = "TriggerScreenGui"
    UI.TriggerBotUI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    UI.TriggerBotUI.ScreenGui.ResetOnSpawn = false
    UI.TriggerBotUI.ScreenGui.IgnoreGuiInset = true
    UI.TriggerBotUI.ScreenGui.Parent = CoreGui

    ENXUI.ProtectGui(UI.TriggerBotUI.ScreenGui)

    UI.TriggerBotUI.Handler = Instance.new("CanvasGroup")
    UI.TriggerBotUI.Handler.Name = "TriggerHandler"
    UI.TriggerBotUI.Handler.Position = UDim2.new(0.3, 0, 0.5, 0)
    UI.TriggerBotUI.Handler.Size = UDim2.new(0, 140, 0, 80)
    UI.TriggerBotUI.Handler.BackgroundColor3 = Color3.new(1, 1, 1)
    UI.TriggerBotUI.Handler.BackgroundTransparency = 1
    UI.TriggerBotUI.Handler.BorderSizePixel = 0
    UI.TriggerBotUI.Handler.BorderColor3 = Color3.new(0, 0, 0)
    UI.TriggerBotUI.Handler.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.TriggerBotUI.Handler.Transparency = 1
    UI.TriggerBotUI.Handler.ClipsDescendants = true
    UI.TriggerBotUI.Handler.Active = true
    UI.TriggerBotUI.Handler.Parent = UI.TriggerBotUI.ScreenGui

    local UICornerTrigger = Instance.new("UICorner")
    UICornerTrigger.Name = "UICorner"
    UICornerTrigger.CornerRadius = UDim.new(0, 4)
    UICornerTrigger.Parent = UI.TriggerBotUI.Handler

    local TriggerButtonFrame = Instance.new("Frame")
    TriggerButtonFrame.Name = "TriggerButtonFrame"
    TriggerButtonFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    TriggerButtonFrame.Size = UDim2.new(1, 0, 1, 0)
    TriggerButtonFrame.BackgroundColor3 = Color3.new(0.0470588, 0.0470588, 0.0470588)
    TriggerButtonFrame.BackgroundTransparency = 0.1
    TriggerButtonFrame.BorderSizePixel = 0
    TriggerButtonFrame.BorderColor3 = Color3.new(0, 0, 0)
    TriggerButtonFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    TriggerButtonFrame.Transparency = 0.1
    TriggerButtonFrame.Parent = UI.TriggerBotUI.Handler

    UI.TriggerBotUI.TriggerButton = Instance.new("TextButton")
    UI.TriggerBotUI.TriggerButton.Name = "TriggerButton"
    UI.TriggerBotUI.TriggerButton.Position = UDim2.new(0.5, 0, 0.5, 0)
    UI.TriggerBotUI.TriggerButton.Size = UDim2.new(1, -15, 1, -15)
    UI.TriggerBotUI.TriggerButton.BackgroundColor3 = Color3.new(152/255, 152/255, 152/255)
    UI.TriggerBotUI.TriggerButton.BackgroundTransparency = 0.75
    UI.TriggerBotUI.TriggerButton.BorderSizePixel = 0
    UI.TriggerBotUI.TriggerButton.BorderColor3 = Color3.new(0, 0, 0)
    UI.TriggerBotUI.TriggerButton.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.TriggerBotUI.TriggerButton.TextTransparency = 0.25
    UI.TriggerBotUI.TriggerButton.Text = "TRIGGER BOT"
    UI.TriggerBotUI.TriggerButton.TextColor3 = Color3.new(1, 1, 1)
    UI.TriggerBotUI.TriggerButton.TextSize = 18
    UI.TriggerBotUI.TriggerButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    UI.TriggerBotUI.TriggerButton.TextScaled = false
    UI.TriggerBotUI.TriggerButton.TextWrapped = true
    UI.TriggerBotUI.TriggerButton.Parent = TriggerButtonFrame

    local UICornerTrigger2 = Instance.new("UICorner")
    UICornerTrigger2.Name = "UICorner"
    UICornerTrigger2.CornerRadius = UDim.new(0, 2)
    UICornerTrigger2.Parent = UI.TriggerBotUI.TriggerButton

    local UIStrokeTrigger = Instance.new("UIStroke")
    UIStrokeTrigger.Name = "UIStroke"
    UIStrokeTrigger.Color = Color3.new(152/255, 152/255, 152/255)
    UIStrokeTrigger.Transparency = 0.5
    UIStrokeTrigger.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStrokeTrigger.Parent = UI.TriggerBotUI.TriggerButton

    local UIStrokeTrigger2 = Instance.new("UIStroke")
    UIStrokeTrigger2.Name = "UIStroke"
    UIStrokeTrigger2.Color = Color3.new(0, 0.0980392, 0.133333)
    UIStrokeTrigger2.Transparency = 0.85
    UIStrokeTrigger2.Parent = UI.TriggerBotUI.Handler

    local UIAspectRatioConstraintTrigger = Instance.new("UIAspectRatioConstraint")
    UIAspectRatioConstraintTrigger.Name = "UIAspectRatioConstraint"
    UIAspectRatioConstraintTrigger.AspectRatio = 2
    UIAspectRatioConstraintTrigger.Parent = UI.TriggerBotUI.Handler

    local function ToggleTriggerBot()
        ENXData.Config.TriggerBot.Enabled = not ENXData.Config.TriggerBot.Enabled
        UI.TriggerBotToggle:SetValue(ENXData.Config.TriggerBot.Enabled)
        TriggerBotUIService:SetColor(ENXData.Config.TriggerBot.Enabled)
        SaveAllSettings()
    end

    UI.TriggerBotUI.TriggerButton.MouseButton1Click:Connect(ToggleTriggerBot)
    MakeDraggable(UI.TriggerBotUI.Handler, UI.TriggerBotUI.Handler, 0.2)
end

do
    UI.BallStats.ScreenGui = Instance.new("ScreenGui")
    UI.BallStats.ScreenGui.Name = "BallStatsUI"
    UI.BallStats.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    UI.BallStats.ScreenGui.ResetOnSpawn = false
    UI.BallStats.ScreenGui.IgnoreGuiInset = true
    UI.BallStats.ScreenGui.Enabled = false
    UI.BallStats.ScreenGui.Parent = CoreGui

    ENXUI.ProtectGui(UI.BallStats.ScreenGui)

    UI.BallStats.Handler = Instance.new("CanvasGroup")
    UI.BallStats.Handler.Name = "Handler"
    UI.BallStats.Handler.Position = UDim2.new(0.5, 0, 0.5, 0)
    UI.BallStats.Handler.Size = UDim2.new(0, 170, 0, 90)
    UI.BallStats.Handler.BackgroundColor3 = Color3.new(1, 1, 1)
    UI.BallStats.Handler.BackgroundTransparency = 1
    UI.BallStats.Handler.BorderSizePixel = 0
    UI.BallStats.Handler.BorderColor3 = Color3.new(0, 0, 0)
    UI.BallStats.Handler.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.BallStats.Handler.ClipsDescendants = true
    UI.BallStats.Handler.Active = true
    UI.BallStats.Handler.Parent = UI.BallStats.ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.Name = "UICorner"
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = UI.BallStats.Handler

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundColor3 = Color3.new(0.0470588, 0.0470588, 0.0470588)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.BorderColor3 = Color3.new(0, 0, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Parent = UI.BallStats.Handler

    local LabelFrame = Instance.new("Frame")
    LabelFrame.Name = "LabelFrame"
    LabelFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    LabelFrame.Size = UDim2.new(1, -15, 1, -15)
    LabelFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    LabelFrame.BackgroundTransparency = 1
    LabelFrame.BorderSizePixel = 0
    LabelFrame.BorderColor3 = Color3.new(0, 0, 0)
    LabelFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    LabelFrame.Parent = MainFrame

    local Speed = Instance.new("Frame")
    Speed.Name = "Speed"
    Speed.Size = UDim2.new(1, 0, 0.5, 0)
    Speed.BackgroundColor3 = Color3.new(1, 1, 1)
    Speed.BackgroundTransparency = 1
    Speed.BorderSizePixel = 0
    Speed.BorderColor3 = Color3.new(0, 0, 0)
    Speed.Parent = LabelFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Position = UDim2.new(0.5, 0, 0, 10)
    Title.Size = UDim2.new(1, 0, 0, 10)
    Title.BackgroundColor3 = Color3.new(1, 1, 1)
    Title.BackgroundTransparency = 1
    Title.BorderSizePixel = 0
    Title.BorderColor3 = Color3.new(0, 0, 0)
    Title.AnchorPoint = Vector2.new(0.5, 0.5)
    Title.Text = "CURRENT SPEED"
    Title.TextColor3 = Color3.new(0.588235, 0.588235, 0.588235)
    Title.TextSize = 14
    Title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Speed

    UI.BallStats.SpeedValue = Instance.new("TextLabel")
    UI.BallStats.SpeedValue.Name = "Value"
    UI.BallStats.SpeedValue.Position = UDim2.new(0.5, 0, 1, 0)
    UI.BallStats.SpeedValue.Size = UDim2.new(1, 0, 0, 20)
    UI.BallStats.SpeedValue.BackgroundColor3 = Color3.new(1, 1, 1)
    UI.BallStats.SpeedValue.BackgroundTransparency = 1
    UI.BallStats.SpeedValue.BorderSizePixel = 0
    UI.BallStats.SpeedValue.BorderColor3 = Color3.new(0, 0, 0)
    UI.BallStats.SpeedValue.AnchorPoint = Vector2.new(0.5, 1)
    UI.BallStats.SpeedValue.Text = "0"
    UI.BallStats.SpeedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    UI.BallStats.SpeedValue.TextSize = 20
    UI.BallStats.SpeedValue.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    UI.BallStats.SpeedValue.TextXAlignment = Enum.TextXAlignment.Left
    UI.BallStats.SpeedValue.Parent = Speed

    local PeakSpeed = Instance.new("Frame")
    PeakSpeed.Name = "PeakSpeed"
    PeakSpeed.Position = UDim2.new(0, 0, 0.5, 0)
    PeakSpeed.Size = UDim2.new(1, 0, 0.5, 0)
    PeakSpeed.BackgroundColor3 = Color3.new(1, 1, 1)
    PeakSpeed.BackgroundTransparency = 1
    PeakSpeed.BorderSizePixel = 0
    PeakSpeed.BorderColor3 = Color3.new(0, 0, 0)
    PeakSpeed.Parent = LabelFrame

    UI.BallStats.PeakSpeedValue = Instance.new("TextLabel")
    UI.BallStats.PeakSpeedValue.Name = "Value"
    UI.BallStats.PeakSpeedValue.Position = UDim2.new(0.5, 0, 1, 0)
    UI.BallStats.PeakSpeedValue.Size = UDim2.new(1, 0, 0, 20)
    UI.BallStats.PeakSpeedValue.BackgroundColor3 = Color3.new(1, 1, 1)
    UI.BallStats.PeakSpeedValue.BackgroundTransparency = 1
    UI.BallStats.PeakSpeedValue.BorderSizePixel = 0
    UI.BallStats.PeakSpeedValue.BorderColor3 = Color3.new(0, 0, 0)
    UI.BallStats.PeakSpeedValue.AnchorPoint = Vector2.new(0.5, 1)
    UI.BallStats.PeakSpeedValue.Text = "0"
    UI.BallStats.PeakSpeedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    UI.BallStats.PeakSpeedValue.TextSize = 20
    UI.BallStats.PeakSpeedValue.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    UI.BallStats.PeakSpeedValue.TextXAlignment = Enum.TextXAlignment.Left
    UI.BallStats.PeakSpeedValue.Parent = PeakSpeed

    local Title2 = Instance.new("TextLabel")
    Title2.Name = "Title"
    Title2.Position = UDim2.new(0.5, 0, 0, 10)
    Title2.Size = UDim2.new(1, 0, 0, 10)
    Title2.BackgroundColor3 = Color3.new(1, 1, 1)
    Title2.BackgroundTransparency = 1
    Title2.BorderSizePixel = 0
    Title2.BorderColor3 = Color3.new(0, 0, 0)
    Title2.AnchorPoint = Vector2.new(0.5, 0.5)
    Title2.Text = "PEAK SPEED"
    Title2.TextColor3 = Color3.new(0.588235, 0.588235, 0.588235)
    Title2.TextSize = 14
    Title2.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    Title2.TextXAlignment = Enum.TextXAlignment.Left
    Title2.Parent = PeakSpeed

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Name = "UIStroke"
    UIStroke.Color = Color3.new(0, 0.0980392, 0.133333)
    UIStroke.Transparency = 0.85
    UIStroke.Parent = UI.BallStats.Handler

    MakeDraggable(UI.BallStats.Handler, UI.BallStats.Handler, 0.2)
end

do
    UI.StatsUI.ScreenGui = Instance.new("ScreenGui")
    UI.StatsUI.ScreenGui.Name = "StatsUI"
    UI.StatsUI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    UI.StatsUI.ScreenGui.ResetOnSpawn = false
    UI.StatsUI.ScreenGui.IgnoreGuiInset = true
    UI.StatsUI.ScreenGui.Enabled = false
    UI.StatsUI.ScreenGui.Parent = CoreGui

    ENXUI.ProtectGui(UI.StatsUI.ScreenGui)

    UI.StatsUI.Handler = Instance.new("CanvasGroup")
    UI.StatsUI.Handler.Name = "Handler"
    UI.StatsUI.Handler.Position = UDim2.new(0.5, 0, 0.5, 0)
    UI.StatsUI.Handler.Size = UDim2.new(0, 327, 0, 45)
    UI.StatsUI.Handler.BackgroundColor3 = Color3.new(1, 1, 1)
    UI.StatsUI.Handler.BackgroundTransparency = 1
    UI.StatsUI.Handler.BorderSizePixel = 0
    UI.StatsUI.Handler.BorderColor3 = Color3.new(0, 0, 0)
    UI.StatsUI.Handler.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.StatsUI.Handler.ClipsDescendants = true
    UI.StatsUI.Handler.Active = true
    UI.StatsUI.Handler.Parent = UI.StatsUI.ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.Name = "UICorner"
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = UI.StatsUI.Handler

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundColor3 = Color3.new(0.0470588, 0.0470588, 0.0470588)
    MainFrame.BackgroundTransparency = 0.10000000149011612
    MainFrame.BorderSizePixel = 0
    MainFrame.BorderColor3 = Color3.new(0, 0, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Parent = UI.StatsUI.Handler

    local LabelFrame = Instance.new("Frame")
    LabelFrame.Name = "LabelFrame"
    LabelFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    LabelFrame.Size = UDim2.new(1, -15, 1, -15)
    LabelFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    LabelFrame.BackgroundTransparency = 1
    LabelFrame.BorderSizePixel = 0
    LabelFrame.BorderColor3 = Color3.new(0, 0, 0)
    LabelFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    LabelFrame.Parent = MainFrame

    local FPS = Instance.new("Frame")
    FPS.Name = "FPS"
    FPS.Position = UDim2.new(0, 0, 0.5, 0)
    FPS.Size = UDim2.new(0, 78, 1, 0)
    FPS.BackgroundColor3 = Color3.new(1, 1, 1)
    FPS.BackgroundTransparency = 1
    FPS.BorderSizePixel = 0
    FPS.BorderColor3 = Color3.new(0, 0, 0)
    FPS.AnchorPoint = Vector2.new(0, 0.5)
    FPS.Parent = LabelFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Position = UDim2.new(0.5, 0, 0, 0)
    Title.Size = UDim2.new(1, 0, 0, 10)
    Title.BackgroundColor3 = Color3.new(1, 1, 1)
    Title.BackgroundTransparency = 1
    Title.BorderSizePixel = 0
    Title.BorderColor3 = Color3.new(0, 0, 0)
    Title.AnchorPoint = Vector2.new(0.5, 0)
    Title.Text = "FPS"
    Title.TextColor3 = Color3.new(0.588235, 0.588235, 0.588235)
    Title.TextSize = 12
    Title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = FPS

    UI.StatsUI.States.FPS = Instance.new("TextLabel")
    UI.StatsUI.States.FPS.Name = "Value"
    UI.StatsUI.States.FPS.Position = UDim2.new(0.5, 0, 1, 0)
    UI.StatsUI.States.FPS.Size = UDim2.new(1, 0, 0, 20)
    UI.StatsUI.States.FPS.BackgroundColor3 = Color3.new(1, 1, 1)
    UI.StatsUI.States.FPS.BackgroundTransparency = 1
    UI.StatsUI.States.FPS.BorderSizePixel = 0
    UI.StatsUI.States.FPS.BorderColor3 = Color3.new(0, 0, 0)
    UI.StatsUI.States.FPS.AnchorPoint = Vector2.new(0.5, 1)
    UI.StatsUI.States.FPS.Text = "0"
    UI.StatsUI.States.FPS.TextColor3 = Color3.new(1, 1, 1)
    UI.StatsUI.States.FPS.TextSize = 17
    UI.StatsUI.States.FPS.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    UI.StatsUI.States.FPS.TextXAlignment = Enum.TextXAlignment.Left
    UI.StatsUI.States.FPS.TextYAlignment = Enum.TextYAlignment.Bottom
    UI.StatsUI.States.FPS.Parent = FPS

    local PING = Instance.new("Frame")
    PING.Name = "PING"
    PING.Position = UDim2.new(0.5, 0, 0.5, 0)
    PING.Size = UDim2.new(0, 78, 1, 0)
    PING.BackgroundColor3 = Color3.new(1, 1, 1)
    PING.BackgroundTransparency = 1
    PING.BorderSizePixel = 0
    PING.BorderColor3 = Color3.new(0, 0, 0)
    PING.AnchorPoint = Vector2.new(0, 0.5)
    PING.Parent = LabelFrame

    local Title2 = Instance.new("TextLabel")
    Title2.Name = "Title"
    Title2.Position = UDim2.new(0.5, 0, 0, 0)
    Title2.Size = UDim2.new(1, 0, 0, 10)
    Title2.BackgroundColor3 = Color3.new(1, 1, 1)
    Title2.BackgroundTransparency = 1
    Title2.BorderSizePixel = 0
    Title2.BorderColor3 = Color3.new(0, 0, 0)
    Title2.AnchorPoint = Vector2.new(0.5, 0)
    Title2.Text = "PING"
    Title2.TextColor3 = Color3.new(0.588235, 0.588235, 0.588235)
    Title2.TextSize = 12
    Title2.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    Title2.TextXAlignment = Enum.TextXAlignment.Left
    Title2.Parent = PING

    UI.StatsUI.States.PING = Instance.new("TextLabel")
    UI.StatsUI.States.PING.Name = "Value"
    UI.StatsUI.States.PING.Position = UDim2.new(0.5, 0, 1, 0)
    UI.StatsUI.States.PING.Size = UDim2.new(1, 0, 0, 20)
    UI.StatsUI.States.PING.BackgroundColor3 = Color3.new(1, 1, 1)
    UI.StatsUI.States.PING.BackgroundTransparency = 1
    UI.StatsUI.States.PING.BorderSizePixel = 0
    UI.StatsUI.States.PING.BorderColor3 = Color3.new(0, 0, 0)
    UI.StatsUI.States.PING.AnchorPoint = Vector2.new(0.5, 1)
    UI.StatsUI.States.PING.Text = "0ms"
    UI.StatsUI.States.PING.TextColor3 = Color3.new(1, 1, 1)
    UI.StatsUI.States.PING.TextSize = 17
    UI.StatsUI.States.PING.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    UI.StatsUI.States.PING.TextXAlignment = Enum.TextXAlignment.Left
    UI.StatsUI.States.PING.TextYAlignment = Enum.TextYAlignment.Bottom
    UI.StatsUI.States.PING.Parent = PING

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Name = "UIListLayout"
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = LabelFrame

    local CPU = Instance.new("Frame")
    CPU.Name = "CPU"
    CPU.Position = UDim2.new(0, 0, 0.5, 0)
    CPU.Size = UDim2.new(0, 78, 1, 0)
    CPU.BackgroundColor3 = Color3.new(1, 1, 1)
    CPU.BackgroundTransparency = 1
    CPU.BorderSizePixel = 0
    CPU.BorderColor3 = Color3.new(0, 0, 0)
    CPU.AnchorPoint = Vector2.new(0, 0.5)
    CPU.Parent = LabelFrame

    local Title3 = Instance.new("TextLabel")
    Title3.Name = "Title"
    Title3.Position = UDim2.new(0.5, 0, 0, 0)
    Title3.Size = UDim2.new(1, 0, 0, 10)
    Title3.BackgroundColor3 = Color3.new(1, 1, 1)
    Title3.BackgroundTransparency = 1
    Title3.BorderSizePixel = 0
    Title3.BorderColor3 = Color3.new(0, 0, 0)
    Title3.AnchorPoint = Vector2.new(0.5, 0)
    Title3.Text = "CPU"
    Title3.TextColor3 = Color3.new(0.588235, 0.588235, 0.588235)
    Title3.TextSize = 12
    Title3.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    Title3.TextXAlignment = Enum.TextXAlignment.Left
    Title3.Parent = CPU

    UI.StatsUI.States.CPU = Instance.new("TextLabel")
    UI.StatsUI.States.CPU.Name = "Value"
    UI.StatsUI.States.CPU.Position = UDim2.new(0.5, 0, 1, 0)
    UI.StatsUI.States.CPU.Size = UDim2.new(1, 0, 0, 20)
    UI.StatsUI.States.CPU.BackgroundColor3 = Color3.new(1, 1, 1)
    UI.StatsUI.States.CPU.BackgroundTransparency = 1
    UI.StatsUI.States.CPU.BorderSizePixel = 0
    UI.StatsUI.States.CPU.BorderColor3 = Color3.new(0, 0, 0)
    UI.StatsUI.States.CPU.AnchorPoint = Vector2.new(0.5, 1)
    UI.StatsUI.States.CPU.Text = "0%"
    UI.StatsUI.States.CPU.TextColor3 = Color3.new(1, 1, 1)
    UI.StatsUI.States.CPU.TextSize = 17
    UI.StatsUI.States.CPU.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    UI.StatsUI.States.CPU.TextXAlignment = Enum.TextXAlignment.Left
    UI.StatsUI.States.CPU.TextYAlignment = Enum.TextYAlignment.Bottom
    UI.StatsUI.States.CPU.Parent = CPU

    local MEMORY = Instance.new("Frame")
    MEMORY.Name = "MEMORY"
    MEMORY.Position = UDim2.new(0.5, 0, 0.5, 0)
    MEMORY.Size = UDim2.new(0, 78, 1, 0)
    MEMORY.BackgroundColor3 = Color3.new(1, 1, 1)
    MEMORY.BackgroundTransparency = 1
    MEMORY.BorderSizePixel = 0
    MEMORY.BorderColor3 = Color3.new(0, 0, 0)
    MEMORY.AnchorPoint = Vector2.new(0, 0.5)
    MEMORY.Parent = LabelFrame

    local Title4 = Instance.new("TextLabel")
    Title4.Name = "Title"
    Title4.Position = UDim2.new(0.5, 0, 0, 0)
    Title4.Size = UDim2.new(1, 0, 0, 10)
    Title4.BackgroundColor3 = Color3.new(1, 1, 1)
    Title4.BackgroundTransparency = 1
    Title4.BorderSizePixel = 0
    Title4.BorderColor3 = Color3.new(0, 0, 0)
    Title4.AnchorPoint = Vector2.new(0.5, 0)
    Title4.Text = "MEMORY"
    Title4.TextColor3 = Color3.new(0.588235, 0.588235, 0.588235)
    Title4.TextSize = 12
    Title4.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    Title4.TextXAlignment = Enum.TextXAlignment.Left
    Title4.Parent = MEMORY

    UI.StatsUI.States.MEMORY = Instance.new("TextLabel")
    UI.StatsUI.States.MEMORY.Name = "Value"
    UI.StatsUI.States.MEMORY.Position = UDim2.new(0.5, 0, 1, 0)
    UI.StatsUI.States.MEMORY.Size = UDim2.new(1, 0, 0, 20)
    UI.StatsUI.States.MEMORY.BackgroundColor3 = Color3.new(1, 1, 1)
    UI.StatsUI.States.MEMORY.BackgroundTransparency = 1
    UI.StatsUI.States.MEMORY.BorderSizePixel = 0
    UI.StatsUI.States.MEMORY.BorderColor3 = Color3.new(0, 0, 0)
    UI.StatsUI.States.MEMORY.AnchorPoint = Vector2.new(0.5, 1)
    UI.StatsUI.States.MEMORY.Text = "2300mb"
    UI.StatsUI.States.MEMORY.TextColor3 = Color3.new(1, 1, 1)
    UI.StatsUI.States.MEMORY.TextSize = 17
    UI.StatsUI.States.MEMORY.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    UI.StatsUI.States.MEMORY.TextXAlignment = Enum.TextXAlignment.Left
    UI.StatsUI.States.MEMORY.TextYAlignment = Enum.TextYAlignment.Bottom
    UI.StatsUI.States.MEMORY.Parent = MEMORY

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Name = "UIStroke"
    UIStroke.Color = Color3.new(0, 0.0980392, 0.133333)
    UIStroke.Transparency = 0.85
    UIStroke.Parent = UI.StatsUI.Handler

    MakeDraggable(UI.StatsUI.Handler, UI.StatsUI.Handler, 0.2)
end

ENXUI:Track(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not input.UserInputType == Enum.UserInputType.Keyboard then return end
    if input.KeyCode == ENXData.Config.AutoParry.Keybind then
        ENXData.Config.AutoParry.Enabled = not ENXData.Config.AutoParry.Enabled
        UI.AutoParryToggle:SetValue(ENXData.Config.AutoParry.Enabled)
        SaveAllSettings()
    end
    if input.KeyCode == ENXData.Config.ManualSpamParry.Keybind then
        ENXData.Config.ManualSpamParry.Spamming = not ENXData.Config.ManualSpamParry.Spamming
        UI.ManualSpamParryToggle:SetValue(ENXData.Config.ManualSpamParry.Spamming)
        ManualSpamParryUIService:SetColor(ENXData.Config.ManualSpamParry.Spamming)
        SaveAllSettings()
    end
    if input.KeyCode == ENXData.Config.TriggerBot.Keybind then
        ENXData.Config.TriggerBot.Enabled = not ENXData.Config.TriggerBot.Enabled
        UI.TriggerBotToggle:SetValue(ENXData.Config.TriggerBot.Enabled)
        TriggerBotUIService:SetColor(ENXData.Config.TriggerBot.Enabled)
        SaveAllSettings()
    end
end))

do
    local DesyncTypes = {}
    local DesyncLastBeat = 0
    local DesyncBeatBusy = false

    local function ConnectEclipseDesync()
    ENXUI:Track(RunService.Heartbeat:Connect(function()
        DesyncLastBeat = os.clock()
        if Immortality.Enabled and GetCharacter() and GetCharacter():FindFirstChild("HumanoidRootPart") then
            local DesyncHumanoid = GetCharacter():FindFirstChildOfClass("Humanoid")
            if DesyncHumanoid and DesyncHumanoid.Health <= 0 then
                DesyncTypes[1] = nil
                DesyncTypes[2] = nil
                return
            end
            if DesyncBeatBusy then
                return
            end
            DesyncBeatBusy = true
            local DesyncBeatOK, DesyncBeatErr = pcall(function()
                if Immortality.SpeedBypassEnabled then
                    setfflag("S2PhysicsSenderRate", "1333335")
                end
                local hrp = GetCharacter().HumanoidRootPart
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 0.01, 0)
                DesyncTypes[1] = hrp.CFrame
                DesyncTypes[2] = hrp.AssemblyLinearVelocity

                local currentTime = tick()
                local CalculatedAngle = currentTime * math.pi * 2 * Immortality.Angle / 5
                local CalculatedCycle = math.floor(currentTime * 29) % 2
                local CalculatedYOffset = (CalculatedCycle == 0) and Immortality.Depth or Immortality.Height

                local Calculatedoffset = Vector3.new(
                    math.cos(CalculatedAngle) * Immortality.SquareRadius,
                    CalculatedYOffset,
                    math.sin(CalculatedAngle) * Immortality.SquareRadius
                )

                local TargetCFrame = DesyncTypes[1] + Calculatedoffset
                TargetCFrame = TargetCFrame * CFrame.Angles(
                    math.rad(math.random(-1000 * 90000009292929399949949496000, 1000 * -1e9) / 5e8),
                    math.rad(math.random(-1000 * 90000009292929399949949496000, 1000 * -1e9) / 5e8),
                    math.rad(math.random(-1000 * 90000009292929399949949496000, 1000 * -1e9) / 5e8)
                )

                hrp.CFrame = TargetCFrame
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

                local DesyncWindowOK = pcall(RunService.RenderStepped.Wait, RunService.RenderStepped)

                pcall(function()
                    hrp.CFrame = DesyncTypes[1]
                    hrp.AssemblyLinearVelocity = DesyncTypes[2]
                end)
            end)
            DesyncBeatBusy = false
        end
    end))
    end

    ConnectEclipseDesync()

    local immortalityHookInstalled = false
    local function ensureImmortalityHook()
        if immortalityHookInstalled or not hookmetamethod then return end
        immortalityHookInstalled = true
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if Immortality.Enabled and not checkcaller() then
                if key == "CFrame" and GetCharacter() and GetCharacter():FindFirstChild("HumanoidRootPart") then
                    local DesyncChar = GetCharacter()
                    local DesyncHRP = DesyncChar and DesyncChar:FindFirstChild("HumanoidRootPart") or nil
                    if DesyncHRP then
                        if self == DesyncHRP then
                            return DesyncTypes[1] or oldIndex(self, key)
                        elseif self == DesyncChar:FindFirstChild("Head") then
                            if DesyncTypes[1] then
                                return DesyncTypes[1] + Vector3.new(0, DesyncHRP.Size.Y / 2 + 0.5, 0)
                            end
                            return oldIndex(self, key)
                        end
                    end
                end
            end
            return oldIndex(self, key)
        end))
    end
    getgenv()._ENX_EnsureImmortalityHook = function()
        pcall(ensureImmortalityHook)
    end

    ENXUI:Track(RunService.Stepped:Connect(function()
        if Immortality.Enabled and GetCharacter() and GetCharacter():FindFirstChild("HumanoidRootPart") then
            pcall(function() GetCharacter().HumanoidRootPart:SetNetworkOwner(LocalPlayer) end)
        end
    end))

    ENXUI:Track(RunService.Heartbeat:Connect(function()
        if Immortality.Enabled and os.clock() - DesyncLastBeat > 2 then
            DesyncLastBeat = os.clock()
            ConnectEclipseDesync()
            getgenv()._ENX_EnsureImmortalityHook()
            ENXNotify.new('EclipseNexus', 'EclipseImmortal watchdog re-armed the desync engine', 3)
        end
    end))
end

do
    local _skinSetSwordHooked = false
    local _skinEquipHooked = false
    local function _applySkinHooks()
        if not _skinSetSwordHooked and ENXAssets.SwordController and type(ENXAssets.SwordController.SetSword) == "function" then
            local OriginalSetSword = ENXAssets.SwordController.SetSword
            ENXAssets.SwordController.SetSword = function(self, anim)
                if SkinChanger.Enabled and SkinChanger.Targets.SwordAnimation.Enabled and SkinChanger.Targets.SwordAnimation.AnimationName and SkinChanger.Targets.SwordAnimation.AnimationName ~= "" then
                    anim = SkinChanger.Targets.SwordAnimation.AnimationName
                end
                return OriginalSetSword(self, anim)
            end
            _skinSetSwordHooked = true
        end
        if not _skinEquipHooked and ENXAssets.swordInstances and type(ENXAssets.swordInstances.EquipSwordTo) == "function" then
            local OriginalEquipSwordTo = ENXAssets.swordInstances.EquipSwordTo
            SkinChanger.System.OriginalEquipSwordTo = OriginalEquipSwordTo
            ENXAssets.swordInstances.EquipSwordTo = function(self, char, swordName)
                if SkinChanger.Enabled and SkinChanger.Targets.SwordModel.Enabled and SkinChanger.Targets.SwordModel.ModelName and SkinChanger.Targets.SwordModel.ModelName ~= "" and char == GetCharacter() then
                    swordName = SkinChanger.Targets.SwordModel.ModelName
                end
                return OriginalEquipSwordTo(self, char, swordName)
            end
            _skinEquipHooked = true
        end
        return _skinSetSwordHooked and _skinEquipHooked
    end
    _applySkinHooks()
    task.spawn(function()
        for _i = 1, 30 do
            if _skinSetSwordHooked and _skinEquipHooked then break end
            task.wait(2)
            pcall(_scanSwordController)
            pcall(_applySkinHooks)
        end
    end)

    ENXUI:Track(ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(...)
        local args = {...}
        if tostring(args[4]) ~= ENXData.Player.LocalPlayer.Name then
            SkinChanger.System.lastOtherParryTimestamp = tick()
        end
    end))
end

do
    local _Det = ENXData.Config.ParrySettings.Detections

    local _FlagStamps = {}
    local _FlagMaxAge = {
        SlashesofFury = 12,
        TimeHole = 10,
        Phantom = 4,
        Pull = 3,
        Pulse = 3,
        HellHook = 8,
        InfinityBall = 20,
        DeathSlashBall = 20,
    }

    local function SetDetectionFlag(key, value)
        local d = _Det[key]
        if not d then return end
        d.Flag = value and true or false
        _FlagStamps[key] = d.Flag and os.clock() or nil
    end

    task.spawn(function()
        while task.wait(0.5) do
            local now = os.clock()
            for key, maxAge in pairs(_FlagMaxAge) do
                local stamp = _FlagStamps[key]
                if stamp and (now - stamp) > maxAge then
                    local d = _Det[key]
                    if d then d.Flag = false end
                    _FlagStamps[key] = nil
                end
            end
        end
    end)

    ENXUI:Track(ReplicatedStorage.Remotes.DeathBall.OnClientEvent:Connect(function(_, value)
        SetDetectionFlag("DeathSlashBall", value)
    end))

    ENXUI:Track(ReplicatedStorage.Remotes.InfinityBall.OnClientEvent:Connect(function(_, value)
        SetDetectionFlag("InfinityBall", value)
    end))

    ENXUI:Track(ReplicatedStorage.Remotes.TimeHoleHoldBall.OnClientEvent:Connect(function(_, value)
        SetDetectionFlag("TimeHole", value)
    end))

    ENXUI:Track(ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/SlashesOfFuryActivate"].OnClientEvent:Connect(function(...)
        local args = {...}
        local player = args[1]

        if player == ENXData.Player.LocalPlayer or player == ENXData.Player.LocalPlayer.Name or (player and player.Name == ENXData.Player.LocalPlayer.Name) then
            SetDetectionFlag("SlashesofFury", true)
            ENXData.Config.ParrySettings.Detections.SlashesofFury.Count = 0
        end
    end))

    ENXUI:Track(ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/SlashesOfFuryEnd"].OnClientEvent:Connect(function()
        SetDetectionFlag("SlashesofFury", false)
        ENXData.Config.ParrySettings.Detections.SlashesofFury.Count = 0
    end))

    ENXUI:Track(ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/SlashesOfFuryParry"].OnClientEvent:Connect(function()
        ENXData.Config.ParrySettings.Detections.SlashesofFury.Count = ENXData.Config.ParrySettings.Detections.SlashesofFury.Count + 1
    end))

    pcall(function()
        ENXUI:Track(ReplicatedStorage.Remotes.Phantom.OnClientEvent:Connect(function(a, b)
            if b and b.Name == ENXData.Player.LocalPlayer.Name and _Det.Phantom then
                SetDetectionFlag("Phantom", true)
                task.delay(2, function()
                    SetDetectionFlag("Phantom", false)
                end)
            end
        end))
    end)

    for _, remoteName in ipairs({"PlrPulled", "PlrPulsed"}) do
        pcall(function()
            local rem = ReplicatedStorage.Remotes:FindFirstChild(remoteName)
            if not rem then return end
            ENXUI:Track(rem.OnClientEvent:Connect(function(a, b)
                local flag
                if type(a) == "boolean" then
                    flag = a
                elseif type(b) == "boolean" then
                    flag = b
                else
                    flag = true
                end
                SetDetectionFlag("Pull", flag)
                SetDetectionFlag("Pulse", flag)
                if flag then
                    task.delay(1.5, function()
                        SetDetectionFlag("Pull", false)
                        SetDetectionFlag("Pulse", false)
                    end)
                end
            end))
        end)
    end

    pcall(function()
        local hookConn
        ENXUI:Track(ReplicatedStorage.Remotes.PlrHellHooked.OnClientEvent:Connect(function(a, b)
            if b and b.Name == ENXData.Player.LocalPlayer.Name and _Det.HellHook and _Det.HellHook.Enabled then
                SetDetectionFlag("HellHook", true)
                local char = GetCharacter()
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local pos = char.HumanoidRootPart.CFrame
                if hookConn then hookConn:Disconnect() end
                hookConn = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local c = GetCharacter()
                        if c and c:FindFirstChild("HumanoidRootPart") then
                            c.HumanoidRootPart.CFrame = pos
                        end
                    end)
                end)
            end
        end))
        ENXUI:Track(ReplicatedStorage.Remotes.PlrHellHookCompleted.OnClientEvent:Connect(function()
            SetDetectionFlag("HellHook", false)
            if hookConn then
                task.wait(1)
                hookConn:Disconnect()
                hookConn = nil
            end
        end))
    end)

    ENXUI:Track(RunService.PreSimulation:Connect(function()
        pcall(function()
            local LP = ENXData.Player.LocalPlayer
            if _Det.Pulse and _Det.Pulse.Enabled then
                local red = LP.PlayerGui.Hotbar.Ability:FindFirstChild("Red")
                if red then _Det.Pulse.Flag = red.Visible end
            end
            if _Det.Singularity and _Det.Singularity.Enabled then
                local char = GetCharacter()
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                _Det.Singularity.Flag = (hrp and hrp:FindFirstChild("SingularityCape")) and true or false
            end
        end)
    end))

    ENXUI:Track(ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/SlashesOfFuryCatch"].OnClientEvent:Connect(function()
        task.spawn(function()
            while ENXData.Config.ParrySettings.Detections.SlashesofFury.Flag and ENXData.Config.ParrySettings.Detections.SlashesofFury.Count < ENXData.Config.ParrySettings.SlashesofFuryDetectionMaxParryCount do
                if ENXData.Config.ParrySettings.Detections.SlashesofFury.Enabled then
                    FireParry()
                    task.wait(ENXData.Config.ParrySettings.SlashesofFuryDetectionParryDelay)
                else
                    break
                end
            end
        end)
    end))
end

do
    for _, v in getconnections(ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent) do
        if v.Function and debug.getinfo(v.Function).name == "parrySuccessAll" then
            SkinChanger.System.parrySuccessAllConnection = v
            SkinChanger.System.playParryFunc = v.Function
            break
        end
    end

    for i,v in getconnections(ReplicatedStorage.Remotes.ParrySuccessClient.Event) do
        if v.Function and debug.getinfo(v.Function).name == "parrySuccessAll" then
            SkinChanger.System.parrySuccessClientConnection = v
        end
    end
end

ENXUI:Track(ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()
    if ENXData.Config.Animation.SpamAnimationParries < 5 then
        ENXData.Config.Animation.SpamAnimationParries += 1
        task.delay(0.05, function()
            if ENXData.Config.Animation.SpamAnimationParries > 0 then
                ENXData.Config.Animation.SpamAnimationParries -= 1
            end
        end)
    end

    if ENXData.Config.ParrySettings.VisualiserParries < 10 then
        ENXData.Config.ParrySettings.VisualiserParries += 1
        task.delay(0.25, function()
            if ENXData.Config.ParrySettings.VisualiserParries > 0 then
                ENXData.Config.ParrySettings.VisualiserParries -= 1
            end
        end)
    end

    SpamAnimationFixBypass = true
    local humanoid = GetHumanoid()
    if humanoid and ENXData.Config.ParrySettings.ParryMethod ~= "Legit" then
        for _, track in pairs(humanoid.Animator:GetPlayingAnimationTracks()) do
            if track.Name == "GrabParry" or track.Name == "Grab" then
                if not ENXData.Config.Animation.AnimationSpammingMode and not AnimationFixService.FEMode then
                    track.TimePosition = 0
                end
                StopAnimation(track)
            end
        end
    end

    if Visuals.HitEffectEnabled then
        for _, Ball in pairs(Get_Balls()) do
            Visuals.HitEffectService:Emit(Ball, Ball.Position)
        end
    end
end))

local LastIteration = 0
local FrameUpdateTable = {}
local FpsStart = os.clock()

local _lastBallStatUpd = 0
local _lastStatsTextUpd = 0
local function RefreshVM(deltaTime)
    ENXData.Config.Animation.AnimationSpammingMode = ENXData.Config.Animation.SpamAnimationParries > 1

    if Visuals.VisualisersEnabled then
        if GetCharacter() and GetCharacter():FindFirstChild("HumanoidRootPart") then
            local char = GetCharacter()
            local hrp = char.HumanoidRootPart
            local isclashing = ENXData.Config.AutoSpamParry.Spamming or ENXData.Config.ManualSpamParry.Spamming
            local color = isclashing and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
            local size = (isclashing and 40 + ENXData.Config.ParrySettings.VisualiserParries or math.clamp(ENXData.Global.AutoParryCurrentAccuracy, 10, 220))
            Visuals.VisualiserService:SetColor(color)
            Visuals.VisualiserService:Update(char, hrp.Position, size)
        end
    end

    local _vmNow = os.clock()
    if ENXData.Config.BallStats.Enabled and (_vmNow - _lastBallStatUpd) >= 0.2 then
        _lastBallStatUpd = _vmNow
        local BallsList = Get_Balls()
        local BallSpeed = 0
        for _, Ball in pairs(BallsList) do
            if Ball then
                local CacheSpeed = Ball.AssemblyLinearVelocity.Magnitude
                BallSpeed = CacheSpeed
                if CacheSpeed > UI.BallStats.PeakSpeed then
                    UI.BallStats.PeakSpeed = CacheSpeed
                end
                break
            end
        end
        UI.BallStats.SpeedValue.Text = tostring(math.floor(BallSpeed))
        UI.BallStats.PeakSpeedValue.Text = tostring(math.floor(UI.BallStats.PeakSpeed))
    end

    if ENXData.Config.ClientStats.Enabled then
        local Fps = 0
        local Ping = 0
        local Cpu = 0
        local Memory = 0

        do
            LastIteration = os.clock()
            for Index = #FrameUpdateTable, 1, -1 do
                FrameUpdateTable[Index + 1] = FrameUpdateTable[Index] >= LastIteration - 1 and FrameUpdateTable[Index] or nil
            end

            FrameUpdateTable[1] = LastIteration
            Fps = (math.floor(os.clock() - FpsStart >= 1 and #FrameUpdateTable or #FrameUpdateTable / (os.clock() - FpsStart)))
        end

        if (_vmNow - _lastStatsTextUpd) >= 0.2 then
            _lastStatsTextUpd = _vmNow
            Ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            Memory = Stats:GetTotalMemoryUsageMb()
            Cpu = math.clamp(Memory / 50, 1, 100)

            UI.StatsUI.States.FPS.Text = tostring(math.floor(Fps))
            UI.StatsUI.States.PING.Text = string.format("%sms", tostring(math.floor(Ping)))
            UI.StatsUI.States.CPU.Text = tostring(math.floor(Cpu)).. "%"
            UI.StatsUI.States.MEMORY.Text = string.format("%smb", tostring(math.floor(Memory)))
        end
    end
end

local RequestSpamParry = function()
    do
        Debug.Spamming.RepeatedAmount += 1
        if tick() - Debug.Spamming.LastRepeat > 1 then
            Debug.Spamming.LastRepeat = tick()
            Debug.Spamming.Speed = Debug.Spamming.RepeatedAmount
            UI.SpamLoopRPSLabel:SetValue(string.format("Loop RPS: %d", Debug.Spamming.Speed))
            Debug.Spamming.RepeatedAmount = 0
        end
    end
    if ENXData.Config.AutoSpamParry.Spamming or ENXData.Config.ManualSpamParry.Spamming then
        FireParry()
        if (ENXData.Config.AutoSpamParry.AnimationFix and ENXData.Config.AutoSpamParry.Spamming) or (ENXData.Config.ManualSpamParry.AnimationFix and ENXData.Config.ManualSpamParry.Spamming) and ENXData.Config.ParrySettings.ParryMethod ~= "Legit" then
            SpamParry_Animation()
        end
    end
end

local function LoopConnection(deltaTime)
    local ok, err = pcall(MainConnection)
    if not ok then
    end
    RefreshVM(deltaTime)
end

do
    local timeAccumulator = 0
    local lastAccLabel = 0

    local function FireParryWithAnim()
        fireSpam()
        if ENXData.Config.ManualSpamParry.AnimationFix and ENXData.Config.ParrySettings.ParryMethod ~= "Legit" then
            SpamParry_Animation()
        end
    end

    local function getBurstCount()
        return 0
    end

    ENXUI:Track(RunService.Heartbeat:Connect(function()
        local Sys = getgenv()._ENX_System
        if Sys and Sys.__properties then
            if ENXData.Config.AutoSpamParry.Spamming or ENXData.Config.ManualSpamParry.Spamming then
                Debug.Spamming.RepeatedAmount = (Debug.Spamming.RepeatedAmount or 0) + (Sys.__properties.__parries or 0)
                if tick() - (Debug.Spamming.LastRepeat or 0) > 1 then
                    Debug.Spamming.LastRepeat = tick()
                    Debug.Spamming.Speed = Debug.Spamming.RepeatedAmount
                    if UI.SpamLoopRPSLabel and UI.SpamLoopRPSLabel.SetValue then
                        UI.SpamLoopRPSLabel:SetValue(string.format("Loop RPS: %d", Debug.Spamming.Speed))
                    end
                    Debug.Spamming.RepeatedAmount = 0
                end
            end
        end
    end))

    ENXUI:Track(RunService.RenderStepped:Connect(function(deltaTime)
        local TargetSpeed = ENXData.Config.ParrySettings.SpammingRPS
        timeAccumulator += deltaTime
        if not ENXData.Config.AutoSpamParry.Spamming and not ENXData.Config.ManualSpamParry.Spamming then
            timeAccumulator = 0
        end
        if (os.clock() - lastAccLabel) >= 0.2 then
            lastAccLabel = os.clock()
            UI.SpamAccumulatorLabel:SetValue(string.format("Accumulator: %.3f", timeAccumulator))
        end
    end))

    ResetAccumulator = function()
        timeAccumulator = 0
    end
end

ApplyLoadedState = function()
    pcall(function()
        ManualSpamParryUIService:Visible(ENXData.Config.ManualSpamParry.UI)
        TriggerBotUIService:Visible(ENXData.Config.TriggerBot.UI)
        BallStatsUIService:Visible(ENXData.Config.BallStats.Enabled)
        StatsUIService:Visible(ENXData.Config.ClientStats.Enabled)
    end)

    pcall(function()
        ManualSpamParryUIService:SetColor(ENXData.Config.ManualSpamParry.Spamming)
        TriggerBotUIService:SetColor(ENXData.Config.TriggerBot.Enabled)
    end)

    pcall(function()
        if Immortality.Enabled and getgenv()._ENX_EnsureImmortalityHook then
            getgenv()._ENX_EnsureImmortalityHook()
        end
    end)

    pcall(function()
        if UI.AutoParryToggle and UI.AutoParryToggle.SetValue then
            UI.AutoParryToggle:SetValue(ENXData.Config.AutoParry.Enabled)
        end
        do
            local Sys = getgenv()._ENX_System
            local wantSpam = (ENXData.Config.AutoSpamParry.Enabled == true)
            if Sys and Sys.auto_spam then
                if wantSpam then pcall(Sys.auto_spam.start) else pcall(Sys.auto_spam.stop) end
            end
            if UI.AutoSpamToggle and UI.AutoSpamToggle.SetValue then
                UI.AutoSpamToggle:SetValue(wantSpam)
            end
        end
        if UI.ManualSpamParryToggle and UI.ManualSpamParryToggle.SetValue then
            UI.ManualSpamParryToggle:SetValue(ENXData.Config.ManualSpamParry.Spamming)
        end
        if UI.TriggerBotToggle and UI.TriggerBotToggle.SetValue then
            UI.TriggerBotToggle:SetValue(ENXData.Config.TriggerBot.Enabled)
        end
    end)

    pcall(function()
        local accuracy = ENXData.Config.ParrySettings.AutoParryAccuracy or 100
        local Sys = getgenv()._ENX_System
        if Sys and Sys.__properties then
            local mapped_accuracy = 1 + (accuracy - 1) * (79 / 99)
            Sys.__properties.__divisor_multiplier = 0.75 + (mapped_accuracy - 1) * (3 / 99)
            Sys.__properties.__accuracy = accuracy
        end
    end)
end

ApplyLoadedState()

ENXUI:Track(RunService.Heartbeat:Connect(function(deltaTime)
    pcall(function()
        if ENXData.Config.AutoParry.Enabled then
            local _vn = os.clock()
            if _vn - (getgenv()._ENX_VizCalcLast or 0) >= 0.1 then
            getgenv()._ENX_VizCalcLast = _vn
            local BallsList = Get_Balls()
            for _, Ball in pairs(BallsList) do
                if Ball then
                    local zoomies = Ball:FindFirstChild('zoomies')
                    if zoomies then
                        local velocity = zoomies.VectorVelocity
                        local speed = velocity.Magnitude
                        local _vpRaw = getgenv()._ZX_PingCache or 40
                        local _vpAvg = getgenv()._ZX_PingSmooth or _vpRaw
                        local _vpThreshold = math.clamp((_vpAvg / 10) / 8, 4, 25)
                        local _vpMult = 0.7 + (math.clamp(System.__properties.__accuracy or 100, 1, 100) - 1) * 0.0035353535353535
                        local _vpLogDiv = 2.2 + 0.9 * math.log(1 + speed / 80)
                        local _vpFactor = 1
                        if speed > 200 then
                            _vpFactor = 1 + math.min((speed - 200) / 1000, 0.3)
                        end
                        local _vpTerm = math.max(speed / (_vpLogDiv * _vpMult), 9.5) * _vpFactor
                        if getgenv().ThreeSourceWindow ~= false then
                            local _vpCapped = math.min(math.max(speed - 9.5, 0), 650)
                            local _vpLinear = math.max(speed / ((2.4 + _vpCapped * 0.002) * _vpMult), 9.5)
                            if _vpLinear < _vpTerm then _vpTerm = _vpLinear end
                        end
                        ENXData.Global.AutoParryCurrentAccuracy = _vpThreshold + _vpTerm
                        break
                    end
                end
            end
            end
        else
            ENXData.Global.AutoParryCurrentAccuracy = 0
        end
    end)
    RefreshVM(deltaTime)
end))

ClearCache = function()
    AnimationFixService.Cache = {}
    ENXNotify.new('EclipseNexus', 'Cleared internal caches.', 5)
end

UnloadENX = function()
    SaveAllSettings()
    ENXUI:Unload()
    local ENXConfig = ENXData.Config
    ENXConfig.AutoParry.Enabled = false
    ENXConfig.ManualSpamParry.Spamming = false
    ENXConfig.TriggerBot.Enabled = false
    ENXConfig.AutoSpamParry.Enabled = false
    Immortality.Enabled = false
    Visuals.VisualiserService:ClearAll()
    SkinChanger.Enabled = false
    if SkinChanger.System.parrySuccessAllConnection then
        pcall(function() SkinChanger.System.parrySuccessAllConnection:Enable() end)
    end
    if SkinChanger.System.parrySuccessClientConnection then
        pcall(function() SkinChanger.System.parrySuccessClientConnection:Enable() end)
    end
    UI.StatsUI.ScreenGui:Destroy()
    UI.BallStats.ScreenGui:Destroy()
    UI.SpamUI.ScreenGui:Destroy()
    UI.TriggerBotUI.ScreenGui:Destroy()

    ENXUI:Unload()
end

ENXUI:Track(ENXData.Player.LocalPlayer.CharacterAdded:Connect(function()
    Visuals.VisualiserService:ClearAll()
    task.delay(1.5, function()
        if SkinChanger.Targets.SwordModel.Enabled and SkinChanger.Targets.SwordModel.ModelName and SkinChanger.Targets.SwordModel.ModelName ~= "" then
            SkinChanger.System.functions.setSword()
        end
    end)
end))

ENXData.Config.ManualSpamParry.Spamming = false
ENXData.Config.AutoSpamParry.Spamming = false
ENXData.Global.AutoParryParried = false

for _, BallData in pairs(ENXData.Parry) do
    if type(BallData) == "table" then
        BallData.LobbyParried = false
    end
end

ApplyLoadedState()

do
    local EclipseNexusTab = getgenv()._ENX_Tabs.EclipseNexus

    local UnlockSection = EclipseNexusTab:AddSection({
        Name = "Unlock All",
        Position = "left"
    })

    local PingCheckerSection = EclipseNexusTab:AddSection({
        Name = "Ping Checker",
        Position = "right"
    })

    local __zxPingOverlay = { gui = nil, fpsConn = nil, running = false }

    local function __zxPingOverlayDestroy()
        __zxPingOverlay.running = false
        if __zxPingOverlay.fpsConn then
            pcall(function() __zxPingOverlay.fpsConn:Disconnect() end)
        end
        __zxPingOverlay.fpsConn = nil
        if __zxPingOverlay.gui then
            pcall(function() __zxPingOverlay.gui:Destroy() end)
        end
        __zxPingOverlay.gui = nil
        pcall(function()
            local stale = CoreGui:FindFirstChild("EclipseNexusPingChecker")
            if stale then
                stale:Destroy()
            end
        end)
    end

    local function __zxPingOverlaySet(enabled)
        if not enabled then
            __zxPingOverlayDestroy()
            return
        end
        if __zxPingOverlay.running and __zxPingOverlay.gui and __zxPingOverlay.gui.Parent then
            return
        end
        __zxPingOverlayDestroy()

        local isMob = false
        pcall(function()
            isMob = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        end)

        local gui = Instance.new("ScreenGui")
        gui.Name = "EclipseNexusPingChecker"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 99
        local parented = pcall(function()
            gui.Parent = CoreGui
        end)
        if not parented or not gui.Parent then
            pcall(function()
                gui.Parent = LocalPlayer:WaitForChild("PlayerGui", 9)
            end)
        end

        local panel = Instance.new("Frame")
        panel.Name = "Panel"
        panel.Size = isMob and UDim2.new(0, 96, 0, 42) or UDim2.new(0, 178, 0, 86)
        panel.Position = isMob and UDim2.new(0, 10, 0.5, -28) or UDim2.new(0, 20, 0.5, -43)
        panel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        panel.BorderSizePixel = 0
        panel.Active = true
        panel.Parent = gui
        local panelCorner = Instance.new("UICorner")
        panelCorner.CornerRadius = UDim.new(0, isMob and 8 or 12)
        panelCorner.Parent = panel
        local panelStroke = Instance.new("UIStroke")
        panelStroke.Color = Color3.fromRGB(70, 70, 70)
        panelStroke.Thickness = 1
        panelStroke.Parent = panel

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Size = isMob and UDim2.new(1, 0, 0, 12) or UDim2.new(1, 0, 0, 18)
        title.Position = isMob and UDim2.new(0, 0, 0, 4) or UDim2.new(0, 0, 0, 6)
        title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        title.Text = "FPS & PING"
        title.TextColor3 = Color3.fromRGB(220, 220, 220)
        title.TextSize = isMob and 8 or 10
        title.TextXAlignment = Enum.TextXAlignment.Center
        title.Parent = panel

        local chipHolder = Instance.new("Frame")
        chipHolder.BackgroundTransparency = 1
        chipHolder.Position = isMob and UDim2.new(0, 5, 0, 18) or UDim2.new(0, 10, 0, 26)
        chipHolder.Size = isMob and UDim2.new(1, -10, 0, 32) or UDim2.new(1, -20, 0, 44)
        chipHolder.Parent = panel
        local chipLayout = Instance.new("UIListLayout")
        chipLayout.FillDirection = Enum.FillDirection.Horizontal
        chipLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        chipLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        chipLayout.Padding = UDim.new(0, isMob and 4 or 6)
        chipLayout.Parent = chipHolder

        local function makeChip(tagText)
            local chip = Instance.new("Frame")
            chip.Size = isMob and UDim2.new(0, 55, 0, 26) or UDim2.new(0, 70, 0, 36)
            chip.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            chip.BorderSizePixel = 0
            chip.Parent = chipHolder
            local chipCorner = Instance.new("UICorner")
            chipCorner.CornerRadius = UDim.new(0, isMob and 6 or 10)
            chipCorner.Parent = chip
            local chipStroke = Instance.new("UIStroke")
            chipStroke.Color = Color3.fromRGB(60, 60, 60)
            chipStroke.Thickness = 1
            chipStroke.Parent = chip
            local dot = Instance.new("Frame")
            dot.Size = isMob and UDim2.new(0, 3, 0, 3) or UDim2.new(0, 4, 0, 4)
            dot.Position = isMob and UDim2.new(0, 4, 0, 4) or UDim2.new(0, 6, 0, 5)
            dot.BackgroundColor3 = Color3.fromRGB(100, 220, 130)
            dot.BorderSizePixel = 0
            dot.Parent = chip
            local dotCorner = Instance.new("UICorner")
            dotCorner.CornerRadius = UDim.new(1, 0)
            dotCorner.Parent = dot
            local tag = Instance.new("TextLabel")
            tag.BackgroundTransparency = 1
            tag.Size = isMob and UDim2.new(1, -6, 0, 8) or UDim2.new(1, -8, 0, 9)
            tag.Position = isMob and UDim2.new(0, 3, 0, 2) or UDim2.new(0, 4, 0, 3)
            tag.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            tag.Text = tagText
            tag.TextColor3 = Color3.fromRGB(180, 180, 180)
            tag.TextSize = isMob and 7 or 8
            tag.TextXAlignment = Enum.TextXAlignment.Center
            tag.Parent = chip
            local val = Instance.new("TextLabel")
            val.BackgroundTransparency = 1
            val.Size = isMob and UDim2.new(1, 0, 0, 12) or UDim2.new(1, 0, 0, 16)
            val.Position = isMob and UDim2.new(0, 0, 0, 11) or UDim2.new(0, 0, 0, 16)
            val.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            val.Text = "0"
            val.TextColor3 = Color3.fromRGB(255, 255, 255)
            val.TextSize = isMob and 9 or 11
            val.Parent = chip
            return val, dot
        end

        local fpsVal, fpsDot = makeChip("FPS")
        local pingVal, pingDot = makeChip("PING")

        panel.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                local dragStart = input.Position
                local startPos = panel.Position
                local moving = true
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        moving = false
                    end
                end)
                local dragConn
                dragConn = UserInputService.InputChanged:Connect(function(inp)
                    if not moving then
                        dragConn:Disconnect()
                        return
                    end
                    if inp.UserInputType == Enum.UserInputType.MouseMovement
                        or inp.UserInputType == Enum.UserInputType.Touch
                    then
                        local delta = inp.Position - dragStart
                        panel.Position = UDim2.new(
                            startPos.X.Scale,
                            startPos.X.Offset + delta.X,
                            startPos.Y.Scale,
                            startPos.Y.Offset + delta.Y
                        )
                    end
                end)
            end
        end)

        __zxPingOverlay.gui = gui

        local frameCount, elapsed, smoothFps = 0, 0, 0
        __zxPingOverlay.fpsConn = RunService.RenderStepped:Connect(function(dt)
            frameCount += 1
            elapsed += dt
            if elapsed >= 0.5 then
                smoothFps = math.round(frameCount / elapsed)
                frameCount = 0
                elapsed = 0
            end
        end)

        __zxPingOverlay.running = true
        task.spawn(function()
            while __zxPingOverlay.running do
                local o = __zxPingOverlay
                if o.gui and o.gui.Parent then
                    pcall(function()
                        local fps = smoothFps
                        local fpsColor = (fps >= 55 and Color3.fromRGB(100, 220, 130))
                            or (fps >= 30 and Color3.fromRGB(230, 200, 80))
                            or Color3.fromRGB(220, 80, 80)
                        fpsVal.Text = tostring(fps)
                        fpsVal.TextColor3 = fpsColor
                        fpsDot.BackgroundColor3 = fpsColor

                        local ping = getgenv()._ZX_PingSmooth or getgenv()._ZX_PingCache
                        if type(ping) ~= "number" or ping ~= ping or ping <= 0 then
                            local okG, valG = pcall(function()
                                return LocalPlayer:GetNetworkPing() * 1000
                            end)
                            ping = (okG and type(valG) == "number" and valG == valG) and valG or 0
                        end
                        ping = math.round(ping)
                        local pingColor = (ping <= 80 and Color3.fromRGB(100, 220, 130))
                            or (ping <= 150 and Color3.fromRGB(230, 200, 80))
                            or Color3.fromRGB(220, 80, 80)
                        pingVal.Text = tostring(ping)
                        pingVal.TextColor3 = pingColor
                        pingDot.BackgroundColor3 = pingColor
                    end)
                end
                task.wait(0.5)
            end
        end)
    end

    PingCheckerSection:AddToggle({
        Name = "FPS & Ping Overlay",
        Default = true,
        Callback = function(value)
            pcall(__zxPingOverlaySet, value)
        end,
    })

    pcall(__zxPingOverlaySet, true)

    local ENX_State = {
        UnlockEnabled = false,
        ItemName = "",
    }

    local function EquipEverything(itemName)
        if not itemName or itemName == "" then return false end
        local char = GetCharacter()
        if not char then
            ENXNotify.new('EclipseNexus', 'Character not loaded yet — try again', 4)
            return false
        end

        local success = false
        pcall(function()
            ENXAssets.swordInstances:EquipSwordTo(char, itemName)
            success = true
        end)
        pcall(function()
            if ENXAssets.SwordController and ENXAssets.SwordController.SetSword then
                ENXAssets.SwordController:SetSword(itemName)
            end
        end)
        pcall(function()
            if ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("FireSwordInfo") then
                ReplicatedStorage.Remotes.FireSwordInfo:FireServer(itemName)
            end
        end)

        SkinChanger.Targets.SwordModel.Enabled = true
        SkinChanger.Targets.SwordModel.ModelName = itemName
        SkinChanger.Targets.SwordAnimation.Enabled = true
        SkinChanger.Targets.SwordAnimation.AnimationName = itemName
        SkinChanger.Targets.SwordFX.Enabled = true
        SkinChanger.Targets.SwordFX.FXName = itemName
        SkinChanger.Enabled = true

        local player = ENXData.Player.LocalPlayer
        pcall(function() player:SetAttribute("CurrentlyEquippedExplosion", itemName) end)
        pcall(function() player:SetAttribute("EquippedExplosion", itemName) end)
        pcall(function() player:SetAttribute("KillEffect", itemName) end)
        if player.Character then
            pcall(function() player.Character:SetAttribute("CurrentlyEquippedExplosion", itemName) end)
            pcall(function() player.Character:SetAttribute("EquippedExplosion", itemName) end)
        end

        if success then
            ENXNotify.new('EclipseNexus', 'Equipped: ' .. itemName, 4)
        else
            ENXNotify.new('EclipseNexus', 'Partial equip: ' .. itemName, 4)
        end
        return true
    end

    local fxHooked = false
    local fxHookedFuncs = {}

    local function getSlashName(swordName)
        local slashName = "SlashEffect"
        pcall(function()
            local ok, swordData = pcall(function()
                return ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(swordName)
            end)
            if ok and swordData and swordData.SlashName then
                slashName = swordData.SlashName
            end
        end)
        return slashName
    end

    local function InstallFXHook()
        if fxHooked then return end
        fxHooked = true

        task.spawn(function()
            local remotesToHook = {"ParrySuccessAll", "ParryAttempt", "ParrySuccess", "PlaySound", "PlayVisuals"}
            local fxSeenRemotes, fxAllDone = {}, false
            while task.wait(fxAllDone and 15 or 1) do
                for _, remoteName in ipairs(remotesToHook) do
                    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild(remoteName)
                    if remote and remote:IsA("RemoteEvent") then
                        if not fxSeenRemotes[remoteName] then
                            fxSeenRemotes[remoteName] = true
                        end
                        local ok, conns = pcall(getconnections, remote.OnClientEvent)
                        if ok and type(conns) == "table" then
                            for _, v in ipairs(conns) do
                                local func = v.Function
                                if func and not fxHookedFuncs[func] then
                                    if isourclosure and isourclosure(func) then
                                        fxHookedFuncs[func] = true
                                    else
                                        fxHookedFuncs[func] = true
                                        v:Disable()
                                        local targetFunc = func
                                        local ourFunc
                                        ourFunc = function(...)
                                            local args = { ... }

                                            local isLocal = false
                                            for _, arg in ipairs(args) do
                                                if tostring(arg) == ENXData.Player.LocalPlayer.Name or (typeof(arg) == "Instance" and (arg == ENXData.Player.LocalPlayer.Character or arg == ENXData.Player.LocalPlayer)) then
                                                    isLocal = true
                                                    break
                                                end
                                            end

                                            if isLocal and ENX_State.UnlockEnabled and ENX_State.ItemName ~= "" then
                                                local fxSword = ENX_State.ItemName
                                                local slashName = getSlashName(fxSword)

                                                local swordFound = false
                                                local slashFound = false

                                                for i, arg in ipairs(args) do
                                                    if type(arg) == "string" then
                                                        if not slashFound and (arg:match("Slash") or arg == "Default" or arg:match("Effect")) then
                                                            args[i] = slashName
                                                            slashFound = true
                                                        elseif not swordFound then
                                                            local isSword = false
                                                            pcall(function()
                                                                if ReplicatedStorage.Shared.ReplicatedInstances.Swords:FindFirstChild(arg) then
                                                                    isSword = true
                                                                end
                                                            end)
                                                            if isSword or arg == ENXData.Player.LocalPlayer:GetAttribute("CurrentlyEquippedSword") then
                                                                args[i] = fxSword
                                                                swordFound = true
                                                            end
                                                        end
                                                    end
                                                end

                                                if not slashFound and type(args[1]) == "string" then
                                                    args[1] = slashName
                                                end
                                                if not swordFound and type(args[3]) == "string" then
                                                    args[3] = fxSword
                                                end
                                            end
                                            if setthreadidentity then pcall(setthreadidentity, 2) end
                                            pcall(targetFunc, unpack(args))
                                        end
                                        fxHookedFuncs[ourFunc] = true
                                        remote.OnClientEvent:Connect(ourFunc)
                                    end
                                end
                            end
                        end
                    end
                end
                fxAllDone = true
                for _, rn in ipairs(remotesToHook) do
                    if not fxSeenRemotes[rn] then fxAllDone = false break end
                end
            end
        end)
    end

    UI.UnlockAllToggle = UnlockSection:AddToggle({
        Name = 'Unlock All (On/Off)',
        Default = ENX_State.UnlockEnabled,
        Callback = function(value)
            ENX_State.UnlockEnabled = value
            if value then
                SkinChanger.Enabled = true
                InstallFXHook()
                ENXNotify.new('EclipseNexus', 'Unlock All ON — type a name below and press Enter', 4)
            else
                SkinChanger.Enabled = false
                SkinChanger.Targets.SwordModel.Enabled = false
                SkinChanger.Targets.SwordAnimation.Enabled = false
                SkinChanger.Targets.SwordFX.Enabled = false
                ENXNotify.new('EclipseNexus', 'Unlock All OFF', 3)
            end
        end,
    })

    UnlockSection:AddDivider({ Color = Color3.fromRGB(50, 50, 50), Height = 1 })

    local nameInput = UnlockSection:AddInput({
        Name = 'Sword / Explosion Name',
        Default = ENX_State.ItemName,
        Placeholder = "Type name + press Enter (e.g. Default)",
        FireOnEnter = true,
        Callback = function(text)
            ENX_State.ItemName = text or ""
            if text and text ~= "" then
                EquipEverything(text)
            end
        end,
    })

    UnlockSection:AddButton({
        Name = 'Apply (Equip Everything)',
        Callback = function()
            local name = ENX_State.ItemName
            if name and name ~= "" then
                EquipEverything(name)
            else
                ENXNotify.new('EclipseNexus', 'Type a name first', 3)
            end
        end,
    })

    UnlockSection:AddDivider({ Color = Color3.fromRGB(50, 50, 50), Height = 1 })

    ENXUI:Track(ENXData.Player.LocalPlayer.CharacterAdded:Connect(function()
        task.wait(2)
        if ENX_State.UnlockEnabled and ENX_State.ItemName ~= "" then
            EquipEverything(ENX_State.ItemName)
        end
    end))

    local InfoSection = EclipseNexusTab:AddSection({ Name = "How To Use", Position = "right" })
    InfoSection:AddLabel("1. Toggle 'Unlock All' ON")
    InfoSection:AddLabel("2. Type a sword/explosion name")
    InfoSection:AddLabel("3. Press Enter — everything equips")
    InfoSection:AddLabel("4. Auto-reequips on respawn")

    task.spawn(function()
        task.wait(1)
        pcall(function()
            if isfile and isfile("EclipseNexus/unlock_all.json") then
                local data = HttpService:JSONDecode(readfile("EclipseNexus/unlock_all.json"))
                if type(data) == "table" then
                    if data.UnlockEnabled ~= nil then ENX_State.UnlockEnabled = data.UnlockEnabled end
                    if data.ItemName then ENX_State.ItemName = data.ItemName end
                    if nameInput and nameInput.SetValue then nameInput:SetValue(ENX_State.ItemName) end
                    if UI.UnlockAllToggle and UI.UnlockAllToggle.SetValue then UI.UnlockAllToggle:SetValue(ENX_State.UnlockEnabled) end
                end
            end
        end)
    end)

    task.spawn(function()
        local _savedState = nil
        while true do
            task.wait(10)
            pcall(function()
                if not (isfolder and makefolder and writefile) then return end
                if not isfolder("EclipseNexus") then makefolder("EclipseNexus") end
                local enc = HttpService:JSONEncode(ENX_State)
                if enc ~= _savedState then
                    _savedState = enc
                    writefile("EclipseNexus/unlock_all.json", enc)
                end
            end)
        end
    end)
end

do
    local ESPTab = getgenv()._ENX_Tabs.ESP

    local ESPState = {
        PlayerESP = false,
        BallESP = false,
        AbilityESP = false,
        DistanceESP = false,
        RainbowESP = false,
        BallSpeed = false,
    }

    local ESPHighlights = {}
    local ESPBillboards = {}
    local BallESPHighlight = nil
    local BallESP_Billboard = nil
    local BallESP_BillboardFor = nil
    local ESP_Folder = Instance.new("Folder")
    ESP_Folder.Name = "EclipseNexusESP_Storage"
    ESP_Folder.Parent = workspace
    local BallESP_Folder = Instance.new("Folder")
    BallESP_Folder.Name = "EclipseNexusBallESP_Storage"
    BallESP_Folder.Parent = workspace
    getgenv()._ENX_BallSpeedPeak = 0
    getgenv()._ENX_BallSpeedUI_Ref = { ScreenGui = nil, SpeedLabel = nil, PeakLabel = nil }
    local BallSpeedPeak = getgenv()._ENX_BallSpeedPeak
    local BallSpeedUI_Ref = getgenv()._ENX_BallSpeedUI_Ref

    local _espHue = 0

    do
        local sg = Instance.new("ScreenGui")
        sg.Name = "EclipseNexusBallSpeed"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.Enabled = false
        sg.Parent = CoreGui
        ENXUI.ProtectGui(sg)
        BallSpeedUI_Ref.ScreenGui = sg

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 180, 0, 80)
        frame.Position = UDim2.new(0.05, 0, 0.4, 0)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 0
        frame.Active = true
        frame.Parent = sg

        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(100, 100, 100)
        stroke.Thickness = 2

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 25)
        title.BackgroundTransparency = 1
        title.Text = "BALL SPEED"
        title.TextColor3 = Color3.fromRGB(180, 180, 180)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.Parent = frame

        local speedLabel = Instance.new("TextLabel")
        speedLabel.Position = UDim2.new(0.1, 0, 0.35, 0)
        speedLabel.Size = UDim2.new(0.8, 0, 0, 25)
        speedLabel.BackgroundTransparency = 1
        speedLabel.Text = "0.0"
        speedLabel.TextColor3 = Color3.fromRGB(255, 140, 0)
        speedLabel.Font = Enum.Font.GothamBold
        speedLabel.TextSize = 22
        speedLabel.TextXAlignment = Enum.TextXAlignment.Left
        speedLabel.Parent = frame
        BallSpeedUI_Ref.SpeedLabel = speedLabel

        local peakLabel = Instance.new("TextLabel")
        peakLabel.Position = UDim2.new(0.1, 0, 0.72, 0)
        peakLabel.Size = UDim2.new(0.8, 0, 0, 18)
        peakLabel.BackgroundTransparency = 1
        peakLabel.Text = "Peak: 0.0"
        peakLabel.TextColor3 = Color3.fromRGB(0, 120, 255)
        peakLabel.Font = Enum.Font.GothamBold
        peakLabel.TextSize = 16
        peakLabel.TextXAlignment = Enum.TextXAlignment.Left
        peakLabel.Parent = frame
        BallSpeedUI_Ref.PeakLabel = peakLabel

        local dragging, dragInput, dragStart, startPos
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    local PlayerESPSection = ESPTab:AddSection({ Name = "Player ESP", Position = "left" })

    PlayerESPSection:AddToggle({
        Name = 'Player ESP',
        Default = ESPState.PlayerESP,
        Callback = function(value)
            ESPState.PlayerESP = value
            if not value then
                for p, h in pairs(ESPHighlights) do pcall(function() h:Destroy() end) end
                ESPHighlights = {}
            end
        end,
    })

    PlayerESPSection:AddToggle({
        Name = 'Distance ESP',
        Default = ESPState.DistanceESP,
        Callback = function(value)
            ESPState.DistanceESP = value
            if not value then
                for p, b in pairs(ESPBillboards) do pcall(function() b:Destroy() end) end
                ESPBillboards = {}
            end
        end,
    })

    PlayerESPSection:AddToggle({
        Name = 'Rainbow ESP',
        Default = ESPState.RainbowESP,
        Callback = function(value)
            ESPState.RainbowESP = value
            if not value and not ESPState.PlayerESP then
                for p, h in pairs(ESPHighlights) do pcall(function() h:Destroy() end) end
                ESPHighlights = {}
            end
        end,
    })

    local BallESPSection = ESPTab:AddSection({ Name = "Ball ESP", Position = "right" })

    BallESPSection:AddToggle({
        Name = 'Ball ESP',
        Default = ESPState.BallESP,
        Callback = function(value)
            ESPState.BallESP = value
            if not value then
                if BallESPHighlight then
                    pcall(function() BallESPHighlight:Destroy() end)
                    BallESPHighlight = nil
                end
                if BallESP_Billboard then
                    pcall(function() BallESP_Billboard:Destroy() end)
                    BallESP_Billboard = nil
                    BallESP_BillboardFor = nil
                end
            end
        end,
    })

    BallESPSection:AddToggle({
        Name = 'Ball Speed Tracker',
        Default = ESPState.BallSpeed,
        Callback = function(value)
            ESPState.BallSpeed = value
            if BallSpeedUI_Ref.ScreenGui then BallSpeedUI_Ref.ScreenGui.Enabled = value end
            if not value then
                getgenv()._ENX_BallSpeedPeak = 0
                if BallSpeedUI_Ref.PeakLabel then BallSpeedUI_Ref.PeakLabel.Text = "Peak: 0.0" end
            end
        end,
    })

    local AbilityESPSection = ESPTab:AddSection({ Name = "Ability ESP", Position = "left" })

    local ESP_Data = {}
    local ESP_IconCache = {}
    local ESP_Cooldowns = {}
    local ESP_UseCounts = {}
    local ESP_CharConns = {}
    local ESP_HeartbeatConn = nil
    local ESP_PlayerAddedConn = nil
    local ESP_AliveAddedConn = nil
    local ESP_AliveRemovedConn = nil
    local _esp_last_update = 0

    local _Abilities = nil
    do
        local _okAb, _abMod = pcall(function()
            return require(game.ReplicatedStorage.Shared.Abilities)
        end)
        if _okAb then _Abilities = _abMod end
    end

    local function esp_get_cd(player)
        local ability = player:GetAttribute('CurrentlyEquippedAbility') or player:GetAttribute('EquippedAbility')
        if not ability then return nil end
        local ok, cd = pcall(_Abilities.getAbilityCooldown, player, ability)
        if ok and type(cd) == 'number' and cd > 0 then return cd end
        return nil
    end

    local function esp_get_icon(abilityName)
        if not abilityName or abilityName == '' then return '' end
        if ESP_IconCache[abilityName] ~= nil then return ESP_IconCache[abilityName] end
        local shared = game.ReplicatedStorage:FindFirstChild('Shared')
        local abilities = shared and shared:FindFirstChild('Abilities')
        local m = abilities and abilities:FindFirstChild(abilityName)
        if not m then ESP_IconCache[abilityName] = ''; return '' end
        local ok, mod = pcall(require, m)
        local icon = (ok and mod and type(mod.iconId) == 'string') and mod.iconId or ''
        ESP_IconCache[abilityName] = icon
        return icon
    end

    local function esp_get_max_uses(player, abilityName)
        if not abilityName or abilityName == '' then return nil end
        local shared = game.ReplicatedStorage:FindFirstChild('Shared')
        local abilities = shared and shared:FindFirstChild('Abilities')
        local m = abilities and abilities:FindFirstChild(abilityName)
        if not m then return nil end
        local ok, mod = pcall(require, m)
        if not (ok and mod) then return nil end
        local maxUses = nil
        for _, key in ipairs({ 'maxUses', 'uses', 'maxUsesPerRound', 'usesPerRound', 'maxCharges', 'charges' }) do
            local v = mod[key]
            if type(v) == 'number' and v >= 1 then maxUses = v break end
        end
        if not maxUses then
            for _, fn in ipairs({ 'getAbilityUses', 'getAbilityCharges', 'getAbilityMaxUses' }) do
                local f = mod[fn]
                if type(f) == 'function' then
                    local ok2, res = pcall(f, player, abilityName)
                    if ok2 and type(res) == 'number' and res >= 1 then maxUses = res break end
                end
            end
        end
        if not maxUses and type(_Abilities) == 'table' then
            for _, fn in ipairs({ 'getAbilityUses', 'getAbilityCharges', 'getAbilityMaxUses' }) do
                local f = _Abilities[fn]
                if type(f) == 'function' then
                    local ok3, res3 = pcall(f, player, abilityName)
                    if ok3 and type(res3) == 'number' and res3 >= 1 then maxUses = res3 break end
                end
            end
        end
        return maxUses
    end

    local function esp_note_use(player)
        local u = ESP_UseCounts[player]
        if u and u.left > 0 then u.left = u.left - 1 end
    end

    local function create_esp_for_player(player)
        task.spawn(function()
            local char = player.Character
            while not char or not char.Parent do
                task.wait()
                char = player.Character
            end
            local head = char:WaitForChild('Head', 10)
            if not head or not getgenv().AbilityESP then return end

            if ESP_Data[player] then
                pcall(function() ESP_Data[player].bill:Destroy() end)
                if ESP_Data[player].cdConn then
                    pcall(function() ESP_Data[player].cdConn:Disconnect() end)
                end
                ESP_Data[player] = nil
            end

            local bill = Instance.new('BillboardGui')
            bill.Name = 'AbilityESPGui'
            bill.Adornee = head
            bill.Size = UDim2.fromOffset(100, 76)
            bill.StudsOffset = Vector3.new(0, 3.2, 0)
            bill.AlwaysOnTop = true
            bill.ResetOnSpawn = false
            bill.Parent = CoreGui

            local icon = Instance.new('ImageLabel')
            icon.Name = 'AbilityIcon'
            icon.Size = UDim2.fromOffset(32, 32)
            icon.AnchorPoint = Vector2.new(0.5, 0)
            icon.Position = UDim2.new(0.5, 0, 0, 0)
            icon.BackgroundTransparency = 1
            icon.BorderSizePixel = 0
            icon.ScaleType = Enum.ScaleType.Fit
            icon.Image = esp_get_icon(player:GetAttribute('CurrentlyEquippedAbility') or player:GetAttribute('EquippedAbility') or '')
            icon.Parent = bill

            local label = Instance.new('TextLabel')
            label.Size = UDim2.new(1, 0, 0, 14)
            label.Position = UDim2.new(0, 0, 0, 34)
            label.BackgroundTransparency = 1
            label.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 11
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.TextStrokeTransparency = 0.2
            label.TextXAlignment = Enum.TextXAlignment.Center
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.Text = player:GetAttribute('CurrentlyEquippedAbility') or player:GetAttribute('EquippedAbility') or player.DisplayName
            label.Parent = bill

            local timerLabel = Instance.new('TextLabel')
            timerLabel.Size = UDim2.new(1, 0, 0, 13)
            timerLabel.Position = UDim2.new(0, 0, 0, 49)
            timerLabel.BackgroundTransparency = 1
            timerLabel.FontFace = Font.new('rbxasset://fonts/families/SFPro.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            timerLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
            timerLabel.TextSize = 12
            timerLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            timerLabel.TextStrokeTransparency = 0.2
            timerLabel.TextXAlignment = Enum.TextXAlignment.Center
            timerLabel.Text = 'Ready'
            timerLabel.Parent = bill

            local usesLabel = Instance.new('TextLabel')
            usesLabel.Size = UDim2.new(1, 0, 0, 14)
            usesLabel.Position = UDim2.new(0, 0, 0, 62)
            usesLabel.BackgroundTransparency = 1
            usesLabel.FontFace = timerLabel.FontFace
            usesLabel.TextColor3 = Color3.fromRGB(80, 220, 255)
            usesLabel.TextSize = 12
            usesLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            usesLabel.TextStrokeTransparency = 0.2
            usesLabel.TextXAlignment = Enum.TextXAlignment.Center
            usesLabel.Visible = false
            usesLabel.Parent = bill

            local _last_cd_trigger = 0
            local cdConn = char.AttributeChanged:Connect(function(attr)
                if attr == 'CooldownExpiration' then
                    local val = char:GetAttribute('CooldownExpiration')
                    if (val == 0 or val == nil) and tick() - _last_cd_trigger > 0.5 then
                        local dur = esp_get_cd(player)
                        if dur then
                            _last_cd_trigger = tick()
                            ESP_Cooldowns[player] = { expiry = tick() + dur, duration = dur }
                        esp_note_use(player)
                        end
                    end
                elseif attr == 'AbilityActive' then
                    local active = char:GetAttribute('AbilityActive')
                    if active == true and tick() - _last_cd_trigger > 0.5 then
                        local dur = esp_get_cd(player)
                        if dur then
                            _last_cd_trigger = tick()
                            ESP_Cooldowns[player] = { expiry = tick() + dur, duration = dur }
                        esp_note_use(player)
                        end
                    end
                end
            end)

            local _ability = player:GetAttribute('CurrentlyEquippedAbility') or player:GetAttribute('EquippedAbility')
            local _ok, _dur = pcall(_Abilities.getAbilityCooldown, player, _ability or '')
            local _isPassive = _ok and type(_dur) == 'number' and _dur <= 0

            local _maxUses = _ability and esp_get_max_uses(player, _ability) or nil
            if _maxUses and not ESP_UseCounts[player] then
                ESP_UseCounts[player] = { max = _maxUses, left = _maxUses }
            end

            ESP_Data[player] = {
                bill = bill,
                label = label,
                icon = icon,
                timerLabel = timerLabel,
                cdConn = cdConn,
                isPassive = _isPassive,
                usesLabel = usesLabel,
            }
        end)
    end

    local function add_esp_player(player)
        if player == Players.LocalPlayer then return end
        if ESP_CharConns[player] then return end

        local charAddedConn = player.CharacterAdded:Connect(function()
            ESP_Cooldowns[player] = nil
            create_esp_for_player(player)
        end)

        local charRemovingConn = player.CharacterRemoving:Connect(function()
            ESP_Cooldowns[player] = nil
            if ESP_Data[player] then
                if ESP_Data[player].isPassive then
                    ESP_Data[player].timerLabel.Text = 'Passive'
                    ESP_Data[player].timerLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
                else
                    ESP_Data[player].timerLabel.Text = 'Ready'
                    ESP_Data[player].timerLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
                end
            end
        end)

        ESP_CharConns[player] = { charAddedConn, charRemovingConn }

        if player.Character then
            create_esp_for_player(player)
        end
    end

    local function esp_reset_all_cooldowns()
        table.clear(ESP_Cooldowns)
        for player in pairs(ESP_Data) do
            pcall(function()
                local ab = player:GetAttribute('CurrentlyEquippedAbility') or player:GetAttribute('EquippedAbility')
                local maxUses = ab and esp_get_max_uses(player, ab) or nil
                if maxUses then
                    ESP_UseCounts[player] = { max = maxUses, left = maxUses }
                else
                    ESP_UseCounts[player] = nil
                end
            end)
        end
        for _, data in pairs(ESP_Data) do
            pcall(function()
                if data.isPassive then
                    data.timerLabel.Text = 'Passive'
                    data.timerLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
                else
                    data.timerLabel.Text = 'Ready'
                    data.timerLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
                end
            end)
        end
    end

    local function start_ability_esp()
        getgenv().AbilityESP = true

        local _lastAliveCount = #workspace.Alive:GetChildren()
        if not ESP_AliveAddedConn then
            ESP_AliveAddedConn = workspace.Alive.ChildAdded:Connect(function()
                if not getgenv().AbilityESP then return end
                local count = #workspace.Alive:GetChildren()
                if _lastAliveCount == 0 and count > 0 then
                    task.defer(esp_reset_all_cooldowns)
                end
                _lastAliveCount = count
            end)
        end
        if not ESP_AliveRemovedConn then
            ESP_AliveRemovedConn = workspace.Alive.ChildRemoved:Connect(function()
                if not getgenv().AbilityESP then return end
                local count = #workspace.Alive:GetChildren()
                if count == 0 then
                    task.defer(esp_reset_all_cooldowns)
                end
                _lastAliveCount = count
            end)
        end

        if not ESP_HeartbeatConn then
            ESP_HeartbeatConn = RunService.Heartbeat:Connect(function()
                if not getgenv().AbilityESP then return end
                local now = tick()
                if now - _esp_last_update < 0.1 then return end
                _esp_last_update = now
                for player, data in pairs(ESP_Data) do
                    if not (player and player.Parent) then
                        pcall(function() data.bill:Destroy() end)
                        if data.cdConn then pcall(function() data.cdConn:Disconnect() end) end
                        ESP_Data[player] = nil
                        ESP_Cooldowns[player] = nil
                        continue
                    end

                    local ab = player:GetAttribute('CurrentlyEquippedAbility') or player:GetAttribute('EquippedAbility') or ''
                    local displayText = ab ~= '' and ab or player.DisplayName
                    if data.label.Text ~= displayText then
                        data.label.Text = displayText
                        data.icon.Image = esp_get_icon(ab)
                        local ok2, dur2 = pcall(_Abilities.getAbilityCooldown, player, ab)
                        data.isPassive = ok2 and type(dur2) == 'number' and dur2 <= 0
                        ESP_Cooldowns[player] = nil
                        local maxUses = ab ~= '' and esp_get_max_uses(player, ab) or nil
                        if maxUses then
                            ESP_UseCounts[player] = { max = maxUses, left = maxUses }
                        else
                            ESP_UseCounts[player] = nil
                        end
                    end

                    local cd = ESP_Cooldowns[player]
                    if cd and now < cd.expiry then
                        local remaining = cd.expiry - now
                        data.timerLabel.Text = string.format('%.1fs', remaining)
                        data.timerLabel.TextColor3 = Color3.fromRGB(255, 120, 50)
                    else
                        if cd then ESP_Cooldowns[player] = nil end
                        if data.isPassive then
                            data.timerLabel.Text = 'Passive'
                            data.timerLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
                        else
                            data.timerLabel.Text = 'Ready'
                            data.timerLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
                        end
                    end

                    if data.usesLabel then
                        local u = ESP_UseCounts[player]
                        if u then
                            if u.left > 0 then
                                data.usesLabel.Text = 'x' .. u.left
                                data.usesLabel.TextColor3 = Color3.fromRGB(80, 220, 255)
                            else
                                data.usesLabel.Text = 'x0'
                                data.usesLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
                            end
                            data.usesLabel.Visible = true
                        else
                            data.usesLabel.Visible = false
                        end
                    end
                end
            end)
        end

        for _, player in pairs(Players:GetPlayers()) do
            add_esp_player(player)
        end
        if not ESP_PlayerAddedConn then
            ESP_PlayerAddedConn = Players.PlayerAdded:Connect(function(player)
                if getgenv().AbilityESP then add_esp_player(player) end
            end)
        end

    end

    local function stop_ability_esp()
        getgenv().AbilityESP = false
        if ESP_HeartbeatConn then
            ESP_HeartbeatConn:Disconnect()
            ESP_HeartbeatConn = nil
        end
        if ESP_PlayerAddedConn then
            pcall(function() ESP_PlayerAddedConn:Disconnect() end)
            ESP_PlayerAddedConn = nil
        end
        if ESP_AliveAddedConn then
            pcall(function() ESP_AliveAddedConn:Disconnect() end)
            ESP_AliveAddedConn = nil
        end
        if ESP_AliveRemovedConn then
            pcall(function() ESP_AliveRemovedConn:Disconnect() end)
            ESP_AliveRemovedConn = nil
        end
        for _, conns in pairs(ESP_CharConns) do
            for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        end
        table.clear(ESP_CharConns)
        for _, data in pairs(ESP_Data) do
            pcall(function() data.bill:Destroy() end)
            if data.cdConn then pcall(function() data.cdConn:Disconnect() end) end
        end
        ESP_Data = {}
        ESP_Cooldowns = {}
        ESP_UseCounts = {}
        table.clear(ESP_IconCache)
    end

    getgenv()._ENX_AbilityESP_Stop = stop_ability_esp

    AbilityESPSection:AddToggle({
        Name = 'Ability ESP',
        Default = ESPState.AbilityESP,
        Callback = function(value)
            ESPState.AbilityESP = value
            if value then
                start_ability_esp()
            else
                stop_ability_esp()
            end
        end,
    })

    AbilityESPSection:AddLabel("Ability ESP: icon + name + live cooldown (Ready / Passive / X.Xs) + Guardian Angel use count (xN)")

    local WinstreakSection = ESPTab:AddSection({ Name = "Winstreak Spoofer", Position = "left" })

    WinstreakSection:AddToggle({
        Name = 'Winstreak Spoofer',
        Default = false,
        Callback = function(value)
            if value then
                getgenv()._EclipseNexus_Winstreak_Start()
            else
                getgenv()._EclipseNexus_Winstreak_Stop()
            end
        end,
    })

    WinstreakSection:AddLabel("Full winstreak spoofer (EclipseNexus): toggle ON, use the draggable spoofer UI - enter a streak, Apply. 0 = hidden")

    local _espAcc = 0
    ENXUI:Track(RunService.RenderStepped:Connect(function(dt)
        if not (ESPState.PlayerESP or ESPState.RainbowESP or ESPState.BallESP or ESPState.DistanceESP or ESPState.BallSpeed) then _espAcc = 0 return end
        _espAcc += dt
        if _espAcc < 0.1 then return end
        _espAcc = 0
        _espHue = (_espHue + dt * 0.35) % 1
        local currentColor = ESPState.RainbowESP and Color3.fromHSV(_espHue, 1, 1) or nil
        local localChar = GetCharacter()
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= ENXData.Player.LocalPlayer and player.Character then
                local char = player.Character
                if ESPState.PlayerESP or ESPState.RainbowESP then
                    if not ESPHighlights[player] or not ESPHighlights[player].Parent then
                        local h = Instance.new("Highlight")
                        h.Name = "EclipseNexusESP"
                        h.Adornee = char
                        h.FillColor = Color3.fromRGB(0, 255, 100)
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.FillTransparency = 0.5
                        h.OutlineTransparency = 0
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent = ESP_Folder
                        ESPHighlights[player] = h
                    end
                    if ESPHighlights[player].Adornee ~= char then
                        ESPHighlights[player].Adornee = char
                    end
                    if ESPState.RainbowESP then
                        ESPHighlights[player].FillColor = currentColor
                    else
                        ESPHighlights[player].FillColor = Color3.fromRGB(0, 255, 100)
                    end
                end
                if ESPState.DistanceESP and localRoot then
                    local head = char:FindFirstChild("Head")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if head and root then
                        local dist = math.floor((localRoot.Position - root.Position).Magnitude)
                        if not ESPBillboards[player] or not ESPBillboards[player].Parent then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "EclipseNexusDistance"
                            bb.Adornee = head
                            bb.Size = UDim2.new(0, 200, 0, 50)
                            bb.AlwaysOnTop = true
                            bb.ExtentsOffset = Vector3.new(0, 3, 0)
                            local label = Instance.new("TextLabel", bb)
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.Text = player.DisplayName .. " [" .. dist .. "s]"
                            label.TextColor3 = Color3.new(1, 1, 1)
                            label.Font = Enum.Font.GothamBold
                            label.TextSize = 16
                            label.TextStrokeTransparency = 0
                            label.TextStrokeColor3 = Color3.new(0, 0, 0)
                            bb.Parent = head
                            ESPBillboards[player] = bb
                        else
                            local label = ESPBillboards[player]:FindFirstChildOfClass("TextLabel")
                            if label then label.Text = player.DisplayName .. " [" .. dist .. "s]" end
                        end
                    end
                end
            end
        end

        local ball = nil
        local espBallsFolder = Workspace:FindFirstChild("Balls") or ENXData.Balls
        for _, b in ipairs(espBallsFolder:GetChildren()) do
            if b:IsA("BasePart") and b:GetAttribute("realBall") then ball = b; break end
        end
        if not ball then
            for _, b in ipairs(espBallsFolder:GetChildren()) do
                if b:IsA("BasePart") and b:FindFirstChild("zoomies") then ball = b; break end
            end
        end
        if not ball then
            for _, b in ipairs(espBallsFolder:GetChildren()) do
                if b:IsA("BasePart") then ball = b; break end
            end
        end
        if ESPState.BallESP and ball then
            if not BallESPHighlight or not BallESPHighlight.Parent then
                BallESPHighlight = Instance.new("Highlight")
                BallESPHighlight.Name = "EclipseNexusBallESP"
                BallESPHighlight.Adornee = ball
                BallESPHighlight.FillColor = Color3.fromRGB(255, 100, 0)
                BallESPHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                BallESPHighlight.FillTransparency = 0.15
                BallESPHighlight.OutlineTransparency = 0
                BallESPHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                BallESPHighlight.Parent = BallESP_Folder
            end
            if ESPState.RainbowESP then
                BallESPHighlight.FillColor = currentColor
            else
                BallESPHighlight.FillColor = Color3.fromRGB(255, 100, 0)
            end
            if BallESPHighlight.Adornee ~= ball then
                BallESPHighlight.Adornee = ball
            end
            if not BallESP_Billboard or not BallESP_Billboard.Parent or BallESP_BillboardFor ~= ball then
                if BallESP_Billboard then pcall(function() BallESP_Billboard:Destroy() end) end
                BallESP_Billboard = Instance.new("BillboardGui")
                BallESP_Billboard.Name = "EclipseNexusBallDot"
                BallESP_Billboard.Adornee = ball
                BallESP_Billboard.Size = UDim2.new(0, 70, 0, 70)
                BallESP_Billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                BallESP_Billboard.AlwaysOnTop = true
                local dotFrame = Instance.new("Frame")
                dotFrame.Name = "Dot"
                dotFrame.Size = UDim2.new(0, 16, 0, 16)
                dotFrame.Position = UDim2.new(0.5, -8, 0.5, -8)
                dotFrame.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
                dotFrame.BorderSizePixel = 0
                dotFrame.Parent = BallESP_Billboard
                Instance.new("UICorner", dotFrame).CornerRadius = UDim.new(1, 0)
                local dotStroke = Instance.new("UIStroke", dotFrame)
                dotStroke.Color = Color3.fromRGB(255, 255, 255)
                dotStroke.Thickness = 2
                local dotText = Instance.new("TextLabel")
                dotText.Name = "Dist"
                dotText.Size = UDim2.new(1, 0, 0, 14)
                dotText.Position = UDim2.new(0, 0, 0.5, 8)
                dotText.BackgroundTransparency = 1
                dotText.Font = Enum.Font.GothamBold
                dotText.TextSize = 12
                dotText.TextColor3 = Color3.new(1, 1, 1)
                dotText.TextStrokeTransparency = 0
                dotText.TextStrokeColor3 = Color3.new(0, 0, 0)
                dotText.Text = ""
                dotText.Parent = BallESP_Billboard
                BallESP_Billboard.Parent = ball
                BallESP_BillboardFor = ball
            end
            local dotFrame = BallESP_Billboard:FindFirstChild("Dot")
            if dotFrame then
                if ESPState.RainbowESP then
                    dotFrame.BackgroundColor3 = currentColor
                else
                    dotFrame.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
                end
            end
            local ballDist = BallESP_Billboard:FindFirstChild("Dist")
            if ballDist and localRoot then
                ballDist.Text = "[" .. math.floor((localRoot.Position - ball.Position).Magnitude) .. "s]"
            end
        end
        if ESPState.BallSpeed and ball and BallSpeedUI_Ref.SpeedLabel then
            local zoomies = ball:FindFirstChild("zoomies")
            local vel = zoomies and zoomies.VectorVelocity or ball.AssemblyLinearVelocity or Vector3.zero
            local speed = vel.Magnitude
            BallSpeedUI_Ref.SpeedLabel.Text = string.format("%.1f", speed)
            if speed > getgenv()._ENX_BallSpeedPeak then
                getgenv()._ENX_BallSpeedPeak = speed
                BallSpeedUI_Ref.PeakLabel.Text = "Peak: " .. string.format("%.1f", speed)
            end
        end
    end))

    task.spawn(function()
        while true do
            task.wait(0.5)
            if ESPState.PlayerESP or ESPState.RainbowESP then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= ENXData.Player.LocalPlayer and player.Character then
                        if not ESPHighlights[player] or not ESPHighlights[player].Parent then
                            local h = Instance.new("Highlight")
                            h.Name = "EclipseNexusESP"
                            h.Adornee = player.Character
                            h.FillColor = Color3.fromRGB(0, 255, 100)
                            h.OutlineColor = Color3.fromRGB(255, 255, 255)
                            h.FillTransparency = 0.5
                            h.OutlineTransparency = 0
                            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            h.Parent = ESP_Folder
                            ESPHighlights[player] = h
                        else
                            ESPHighlights[player].Adornee = player.Character
                        end
                        if ESPState.RainbowESP then
                            ESPHighlights[player].FillColor = Color3.fromHSV((tick() * 0.35) % 1, 1, 1)
                        end
                    end
                end
            else
                for p, h in pairs(ESPHighlights) do pcall(function() h:Destroy() end) end
                ESPHighlights = {}
            end
        end
    end)

    ENXUI:Track(Players.PlayerRemoving:Connect(function(player)
        if ESPHighlights[player] then pcall(function() ESPHighlights[player]:Destroy() end); ESPHighlights[player] = nil end
        if ESPBillboards[player] then pcall(function() ESPBillboards[player]:Destroy() end); ESPBillboards[player] = nil end
    end))
end

do
    local AnnouncerSection = getgenv()._ENX_Tabs.ESP:AddSection({
        Name = "Kill Announcer",
        Position = "left"
    })

    local KillAnnouncer = {
        enabled = false,
        win_message = "EclipseNexus",
        kill_message = "EclipseNexus",
        connections = {},
    }

    local KAStop
    local function KAApply(label, getter)
        if not label then
            return
        end
        table.insert(KillAnnouncer.connections, label.Changed:Connect(function(prop)
            if prop ~= "Text" or not KillAnnouncer.enabled then
                return
            end
            local message = getter()
            if message ~= nil and message ~= "" and label.Text ~= message then
                label.Text = message
            end
        end))
        local message = getter()
        if message ~= nil and message ~= "" and label.Text ~= message then
            label.Text = message
        end
    end

    local function KAUpdate()
        if not KillAnnouncer.enabled then
            return
        end
        local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then
            return
        end
        local announcer = playerGui:FindFirstChild("announcer")
        if not announcer then
            return
        end
        if KillAnnouncer.kill_message ~= nil and KillAnnouncer.kill_message ~= "" then
            local killed = announcer:FindFirstChild("Killed")
            if killed and (killed:IsA("TextLabel") or killed:IsA("TextBox")) then
                if killed.Text ~= KillAnnouncer.kill_message then
                    killed.Text = KillAnnouncer.kill_message
                end
            end
        end
        if KillAnnouncer.win_message ~= nil and KillAnnouncer.win_message ~= "" then
            local winner = announcer:FindFirstChild("Winner")
            if winner and (winner:IsA("TextLabel") or winner:IsA("TextBox")) then
                if winner.Text ~= KillAnnouncer.win_message then
                    winner.Text = KillAnnouncer.win_message
                end
            end
        end
    end

    local function KAStart()
        KAStop()
        KillAnnouncer.enabled = true
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui", 10)
        if not playerGui then
            return
        end
        local announcer = playerGui:WaitForChild("announcer", 10)
        if not announcer then
            return
        end
        KAApply(announcer:WaitForChild("Killed", 10), function()
            return KillAnnouncer.kill_message
        end)
        KAApply(announcer:FindFirstChild("Winner"), function()
            return KillAnnouncer.win_message
        end)
        table.insert(KillAnnouncer.connections, announcer.ChildAdded:Connect(function(child)
            if child.Name == "Winner" then
                KAApply(child, function()
                    return KillAnnouncer.win_message
                end)
            end
            if child.Name == "Killed" then
                KAApply(child, function()
                    return KillAnnouncer.kill_message
                end)
            end
        end))
    end

    KAStop = function()
        KillAnnouncer.enabled = false
        for _, connection in ipairs(KillAnnouncer.connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        table.clear(KillAnnouncer.connections)
    end

    AnnouncerSection:AddToggle({
        Name = "Custom Win Message",
        Default = false,
        Callback = function(state)
            if state then
                KAStart()
            else
                KAStop()
            end
        end,
    })

    AnnouncerSection:AddTextbox({
        Name = "Win Message",
        Placeholder = "Enter win message...",
        Default = KillAnnouncer.win_message,
        Callback = function(text)
            KillAnnouncer.win_message = text
            if KillAnnouncer.enabled then
                KAUpdate()
            end
        end,
    })

    AnnouncerSection:AddTextbox({
        Name = "Kill Message",
        Placeholder = "Enter kill message...",
        Default = KillAnnouncer.kill_message,
        Callback = function(text)
            KillAnnouncer.kill_message = text
            if KillAnnouncer.enabled then
                KAUpdate()
            end
        end,
    })
end

do
    local ImmortalTab = getgenv()._ENX_Tabs.Immortal

    local DesyncSection = ImmortalTab:AddSection({
        Name = "EclipseNexus Semi Immortal",
        Position = "left"
    })

    local desyncActive = false
    local desyncSpoofing = false
    local DesyncTypes = {}
    local desyncConns = nil
    local desyncHookInstalled = false
    local desyncConfig = { radius = 55, height = 15, spike = 6000, smart = false, range = 300, slowCap = 60, fastFloor = 150, lead = 6, holdSlow = 180, holdMed = 180, holdFast = 180, turn = 20, curveBoost = 3, missBoost = 4 }
    local DESYNC_CLASS_PROFILE = { SLOW = { rng = 1.8, lead = 2.0 }, MEDIUM = { rng = 1.0, lead = 1.0 }, FAST = { rng = 0.8, lead = 1.5 }, CURVE = { rng = 1.4 } }
    local desyncStatusText = nil
    local desyncActivationBtn = nil
    local desyncSmartNearUntil = 0
    local desyncThreatNow = false
    local desyncNearestDist = nil
    local desyncBallMem = {}
    local desyncLastClass = "-"
    local desyncSpoofCount = 0
    local desyncPhaseH, desyncPhaseV, desyncPhaseS = math.random() * 6.283185307179586, math.random() * 6.283185307179586, math.random() * 6.283185307179586

    local function RandomNumberRange(a)
        return math.random(-a * 90000009292929399949949496000, a * -1e9) / 5e8
    end

    local function DesyncStopLoops()
        local wasSpoofing = desyncSpoofing
        desyncSpoofing = false
        desyncActive = false
        if desyncConns then
            for _, c in ipairs(desyncConns) do
                pcall(function() c:Disconnect() end)
            end
            desyncConns = nil
        end
        if wasSpoofing and DesyncTypes[1] then
            pcall(function()
                local char = ENXData.Player.LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = DesyncTypes[1]
                    hrp.AssemblyLinearVelocity = DesyncTypes[2] or Vector3.zero
                end
            end)
        end
        DesyncTypes[1] = nil
        DesyncTypes[2] = nil
        desyncStatusText = nil
        desyncActivationBtn = nil
        desyncSmartNearUntil = 0
        desyncThreatNow = false
        desyncNearestDist = nil
        desyncBallMem = {}
        desyncLastClass = "-"
        desyncSpoofCount = 0
    end

    local function DisableEclipseImmortalAuto()
        if Immortality.Enabled then
            Immortality.Enabled = false
            SaveAllSettings()
            ENXNotify.new('EclipseNexus', 'EclipseImmortal auto-disabled - run ONE immortal system', 3)
        end
        pcall(function() if getgenv()._ENX_V2Stop then getgenv()._ENX_V2Stop() end end)
    end
    local function SemiDesyncStopBridge()
        DesyncStopLoops()
        pcall(function()
            local pg = ENXData.Player.LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                local old = pg:FindFirstChild("EclipseNexus_SemiImmortality")
                if old then old:Destroy() end
            end
        end)
        if UI.DesyncImmortalToggle and UI.DesyncImmortalToggle.SetValue then
            UI.DesyncImmortalToggle:SetValue(false)
        end
    end
    getgenv()._ENX_SemiDesyncIsActive = function() return desyncActive end
    getgenv()._ENX_SemiDesyncStop = SemiDesyncStopBridge

    getgenv()._ENX_DesyncSaveState = function()
        return {
            radius = desyncConfig.radius, height = desyncConfig.height,
            spike = desyncConfig.spike, range = desyncConfig.range,
            slowCap = desyncConfig.slowCap, fastFloor = desyncConfig.fastFloor,
            lead = desyncConfig.lead, holdSlow = desyncConfig.holdSlow,
            holdMed = desyncConfig.holdMed, holdFast = desyncConfig.holdFast,
            turn = desyncConfig.turn, curveBoost = desyncConfig.curveBoost,
            missBoost = desyncConfig.missBoost,
            holdVer = 222,
        }
    end
    do
        local _desyncSaved = getgenv()._ENX_DesyncSavedBlob
        getgenv()._ENX_DesyncSavedBlob = nil
        if type(_desyncSaved) == "table" then
            local _holdVer = tonumber(_desyncSaved.holdVer) or 0
            for kk, vv in pairs(_desyncSaved) do
                if desyncConfig[kk] ~= nil and type(vv) == "number" then
                    if kk == "holdSlow" or kk == "holdMed" or kk == "holdFast" then
                        if _holdVer >= 222 then
                            desyncConfig[kk] = math.clamp(vv, 1, 300)
                        end
                    else
                        desyncConfig[kk] = vv
                    end
                end
            end
        end
    end

    local function DesyncSetup()
        local LocalPlayer = ENXData.Player.LocalPlayer
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
        desyncPhaseH, desyncPhaseV, desyncPhaseS = math.random() * 6.283185307179586, math.random() * 6.283185307179586, math.random() * 6.283185307179586
        pcall(function()
            local old = PlayerGui:FindFirstChild("EclipseNexus_SemiImmortality")
            if old then old:Destroy() end
        end)
        local SemiImmortality = Instance.new("ScreenGui")
        SemiImmortality.Name = "EclipseNexus_SemiImmortality"
        SemiImmortality.Parent = PlayerGui
        SemiImmortality.ResetOnSpawn = false
        SemiImmortality.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        local Immortality = Instance.new("Frame")
        Immortality.Name = "Immortality"
        Immortality.Parent = SemiImmortality
        Immortality.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Immortality.BackgroundTransparency = 0.3
        Immortality.BorderSizePixel = 0
        Immortality.Position = UDim2.new(0.057, 0, 0.078, 0)
        Immortality.Size = UDim2.new(0, 139, 0, 119)
        local UICorner = Instance.new("UICorner")
        UICorner.Parent = Immortality
        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.Parent = Immortality
        Title.BackgroundTransparency = 1
        Title.Size = UDim2.new(0, 139, 0, 29)
        Title.Font = Enum.Font.SourceSans
        Title.Text = "EclipseNexus Semi Immortal"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextScaled = true
        Title.TextWrapped = true
        local Activation = Instance.new("TextButton")
        Activation.Name = "Activation"
        Activation.Parent = Immortality
        Activation.BackgroundTransparency = 1
        Activation.Position = UDim2.new(0, 0, 0.326, 0)
        Activation.Size = UDim2.new(0, 139, 0, 60)
        Activation.Font = Enum.Font.SourceSans
        Activation.Text = "OFF"
        Activation.TextColor3 = Color3.fromRGB(255, 0, 0)
        Activation.TextScaled = true
        Activation.TextWrapped = true
        local function toggle()
            desyncActive = not desyncActive
            if desyncActive then
                Activation.Text = "ON"
                Activation.TextColor3 = Color3.fromRGB(0, 255, 0)
                DisableEclipseImmortalAuto()
            else
                Activation.Text = "OFF"
                Activation.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        end
        Activation.MouseButton1Click:Connect(toggle)
        desyncActivationBtn = Activation
        local Status = Instance.new("TextLabel")
        Status.Name = "Status"
        Status.Parent = Immortality
        Status.BackgroundTransparency = 1
        Status.Position = UDim2.new(0, 0, 0, 99)
        Status.Size = UDim2.new(0, 139, 0, 20)
        Status.Font = Enum.Font.SourceSans
        Status.Text = "OFF"
        Status.TextColor3 = Color3.fromRGB(255, 80, 80)
        Status.TextScaled = true
        desyncStatusText = Status
        local dragging = false
        local dragInput, dragStart, startPos
        local function update(input)
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            TweenService:Create(Immortality, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = newPos}):Play()
        end
        Immortality.Active = true
        Immortality.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = Immortality.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        Immortality.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then update(input) end
        end)
        if not desyncConns then
            desyncConns = {}
            local desyncNearBall = true
            local desyncStatusAcc = 0
            table.insert(desyncConns, RunService.Stepped:Connect(function()
                if desyncActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function() LocalPlayer.Character.HumanoidRootPart:SetNetworkOwner(LocalPlayer) end)
                end
            end))
            table.insert(desyncConns, RunService.Heartbeat:Connect(function(delta)
                desyncStatusAcc = desyncStatusAcc + delta
                if desyncStatusAcc >= 0.1 then
                    desyncStatusAcc = 0
                    if desyncStatusText then
                        pcall(function()
                            if not desyncActive or not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
                                if desyncStatusText.Text ~= "OFF" then
                                    desyncStatusText.Text = "OFF"
                                    desyncStatusText.TextColor3 = Color3.fromRGB(255, 80, 80)
                                end
                                return
                            end
                            local txt, col
                            if desyncConfig.smart and os.clock() >= desyncSmartNearUntil then
                                txt = desyncNearestDist and ("SWEEP IDLE - " .. math.floor(desyncNearestDist + 0.5) .. " studs") or "SWEEP IDLE - no ball in range"
                                col = Color3.fromRGB(255, 170, 0)
                            elseif desyncConfig.smart and not desyncThreatNow then
                                local _holdLeft = math.max(desyncSmartNearUntil - os.clock(), 0)
                                if _holdLeft >= 60 then
                                    txt = "SWEEP HOLD " .. math.floor(_holdLeft / 60) .. "m" .. string.format("%02d", math.floor(_holdLeft % 60)) .. "s #" .. desyncSpoofCount
                                else
                                    txt = "SWEEP HOLD " .. string.format("%.1f", _holdLeft) .. "s #" .. desyncSpoofCount
                                end
                                col = Color3.fromRGB(160, 220, 255)
                            else
                                txt = (desyncConfig.smart and ("SWEEP ACTIVE " .. desyncLastClass) or "ARMED") .. " #" .. desyncSpoofCount
                                col = Color3.fromRGB(120, 255, 120)
                            end
                            if desyncStatusText.Text ~= txt then
                                desyncStatusText.Text = txt
                                desyncStatusText.TextColor3 = col
                            end
                        end)
                    end
                end
                if not (desyncActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
                    desyncSpoofing = false
                    return
                end
                pcall(setfflag, "S2PhysicsSenderRate", "1333335")
                if desyncConfig.smart then
                    local now = os.clock()
                    local myName = LocalPlayer.Name
                    local holdBefore = desyncSmartNearUntil
                    desyncNearestDist = nil
                    desyncLastClass = "-"
                    if next(desyncBallMem) then
                        for mBall, mEntry in pairs(desyncBallMem) do
                            if now - mEntry.t > 2 then desyncBallMem[mBall] = nil end
                        end
                        local mCount = 0
                        for _ in pairs(desyncBallMem) do mCount = mCount + 1 end
                        if mCount > 128 then desyncBallMem = {} end
                    end
                    pcall(function()
                        local ballsFolder = workspace:FindFirstChild("Balls")
                        local hrp = LocalPlayer.Character.HumanoidRootPart
                        if not ballsFolder then
                            desyncSmartNearUntil = math.max(desyncSmartNearUntil, now + desyncConfig.holdMed)
                            return
                        end
                        for _, ball in ipairs(ballsFolder:GetChildren()) do
                            local okAttr, isReal = pcall(ball.GetAttribute, ball, "realBall")
                            if okAttr and isReal then
                                pcall(function()
                                    local part = ball:IsA("BasePart") and ball or ball.PrimaryPart
                                    if not part then return end
                                    local offset = part.Position - hrp.Position
                                    local dist = offset.Magnitude
                                    if not desyncNearestDist or dist < desyncNearestDist then desyncNearestDist = dist end
                                    local okVel, vel = pcall(function() return part.AssemblyLinearVelocity end)
                                    local sp = okVel and vel.Magnitude or 0
                                    if not okVel and dist <= desyncConfig.range * 2 then
                                        desyncSmartNearUntil = math.max(desyncSmartNearUntil, now + desyncConfig.holdMed)
                                        return
                                    end
                                    local cls = "MEDIUM"
                                    if sp < desyncConfig.slowCap then
                                        cls = "SLOW"
                                    elseif sp > desyncConfig.fastFloor then
                                        cls = "FAST"
                                    end
                                    local prof = DESYNC_CLASS_PROFILE[cls]
                                    local inbound = 0
                                    if sp > 1 then inbound = vel.Unit:Dot(-offset.Unit) end
                                    local curve = false
                                    if sp > 1 then
                                        local curDir = vel.Unit
                                        local mem = desyncBallMem[ball]
                                        if mem then
                                            local dt = now - mem.t
                                            if dt >= 0.03 and dt <= 1.5 then
                                                local turnRate = math.acos(math.clamp(mem.dir:Dot(curDir), -1, 1)) / dt
                                                if turnRate >= math.rad(desyncConfig.turn) and dist <= desyncConfig.range * 10 then
                                                    curve = true
                                                end
                                            end
                                        end
                                        desyncBallMem[ball] = { dir = curDir, t = now }
                                    elseif desyncBallMem[ball] then
                                        desyncBallMem[ball] = nil
                                    end
                                    local clsRange = desyncConfig.range * prof.rng * (curve and DESYNC_CLASS_PROFILE.CURVE.rng or 1)
                                    local clsLead = desyncConfig.lead * prof.lead
                                    local clsHold = cls == "SLOW" and desyncConfig.holdSlow or (cls == "FAST" and desyncConfig.holdFast or desyncConfig.holdMed)
                                    if curve then clsHold = clsHold + desyncConfig.curveBoost end
                                    local miss = dist <= clsRange and sp > 1 and inbound > 0
                                    if miss then clsHold = clsHold + desyncConfig.missBoost end
                                    local deadline = now + clsHold
                                    local trip = false
                                    if dist <= clsRange then trip = true end
                                    if sp > 1 and inbound > 0.2 and dist / sp <= clsLead then trip = true end
                                    if curve and dist <= desyncConfig.range * 3 then trip = true end
                                    local okTarget, ballTarget = pcall(ball.GetAttribute, ball, "target")
                                    if okTarget and ballTarget == myName then trip = true end
                                    if trip then
                                        desyncSmartNearUntil = math.max(desyncSmartNearUntil, deadline)
                                        desyncLastClass = cls .. (curve and "-CURVE" or "") .. (miss and "+MISS" or "")
                                    end
                                end)
                            end
                        end
                    end)
                    desyncThreatNow = desyncSmartNearUntil > holdBefore
                    desyncNearBall = os.clock() < desyncSmartNearUntil
                    if not desyncNearBall then
                        desyncSpoofing = false
                        return
                    end
                end
                local DesyncHRP = LocalPlayer.Character.HumanoidRootPart
                DesyncTypes[1] = DesyncHRP.CFrame
                DesyncTypes[2] = DesyncHRP.AssemblyLinearVelocity
                local SpoofThis = DesyncHRP.CFrame
                local horizontalOscillation = math.sin(tick() * 60 + desyncPhaseH) * desyncConfig.radius
                local verticalOscillation = math.sin(tick() * 25 + desyncPhaseV) * desyncConfig.height
                SpoofThis = SpoofThis * CFrame.new(horizontalOscillation, verticalOscillation, 0) * CFrame.Angles(math.rad(RandomNumberRange(1000)), math.rad(RandomNumberRange(1000)), math.rad(RandomNumberRange(1000)))
                desyncSpoofing = true
                desyncSpoofCount = desyncSpoofCount + 1
                DesyncHRP.CFrame = SpoofThis
                DesyncHRP.AssemblyLinearVelocity = DesyncTypes[2] + Vector3.new(math.cos(tick() * 8 + desyncPhaseS) * desyncConfig.spike, math.cos(tick() * 11 + desyncPhaseS) * desyncConfig.spike, math.cos(tick() * 9 - desyncPhaseS) * desyncConfig.spike)
                local DesyncWindowOK = pcall(RunService.RenderStepped.Wait, RunService.RenderStepped)
                pcall(function()
                    DesyncHRP.CFrame = DesyncTypes[1]
                    DesyncHRP.AssemblyLinearVelocity = DesyncTypes[2]
                end)
                desyncSpoofing = false
            end))
        end
        if not desyncHookInstalled and hookmetamethod and checkcaller and newcclosure then
            local ok = pcall(function()
                local oldIndex
                oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
                    if desyncSpoofing and not checkcaller() then
                        if key == "CFrame" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local DesyncChar = LocalPlayer.Character
                            local DesyncHRP = DesyncChar and DesyncChar:FindFirstChild("HumanoidRootPart") or nil
                            if DesyncHRP then
                                if self == DesyncHRP then
                                    return DesyncTypes[1] or oldIndex(self, key)
                                elseif self == DesyncChar:FindFirstChild("Head") then
                                    if DesyncTypes[1] then
                                        return DesyncTypes[1] + Vector3.new(0, DesyncHRP.Size.Y / 2 + 0.5, 0)
                                    end
                                    return oldIndex(self, key)
                                end
                            end
                        end
                    end
                    return oldIndex(self, key)
                end))
            end)
            if ok then desyncHookInstalled = true end
        end
        ENXNotify.new('EclipseNexus', 'EclipseNexus Semi Immortal panel shown - click ON on the panel', 3)
    end

    UI.DesyncImmortalToggle = DesyncSection:AddToggle({
        Name = 'Enable EclipseNexus Semi Immortal',
        Default = false,
        Callback = function(value)
            if value then
                pcall(function() if getgenv()._ENX_V2Stop then getgenv()._ENX_V2Stop() end end)
                DesyncSetup()
            else
                DesyncStopLoops()
                pcall(function()
                    local pg = ENXData.Player.LocalPlayer:FindFirstChild("PlayerGui")
                    if pg then
                        local old = pg:FindFirstChild("EclipseNexus_SemiImmortality")
                        if old then old:Destroy() end
                    end
                end)
                ENXNotify.new('EclipseNexus', 'EclipseNexus Semi Immortal OFF', 3)
            end
        end,
    })

    DesyncSection:AddLabel("Hardened desync engine: floating draggable panel.")
    DesyncSection:AddLabel("Toggle ON here, then click ON/OFF on the panel.")
    DesyncSection:AddLabel("Defaults reproduce the tuned constants 55 / 15 / 6000.")
    DesyncSection:AddLabel("v210: every tuning slider below persists across re-executes.")
    DesyncSection:AddLabel("Smart Desync v3 CLASS SWEEP: every real ball is classified each beat from its real speed - SLOW under Slow Class Cap, FAST over Fast Class Floor, MEDIUM between - and each class answers with its OWN tuned response (SLOW = widest net x1.8 + longest hold, MEDIUM = mainline x1.0, FAST = tight net x0.8 + widest ETA lead x1.5 + short hard hold). The direction memory flags CURVE balls at any speed (net widens x1.4, Curve Boost added) and a ball still flying at you inside its class net is a missed parry (Miss Boost added). Speed changes need no detector - an accelerating ball simply re-classifies. Every hold write is a ratchet: holds only extend. Defaults are simulator-tuned (scripts/sim_v199.py).")
    DesyncSection:AddLabel("v222: every class holds 180 seconds by default and all three Hold sliders reach 300 seconds - the desync holds for the exact time you set, counted from the last threat, and old saved holds under the previous 60 second cap are upgraded to the 3 minute default.")
    DesyncSection:AddSlider({
        Name = "Oscillation Radius",
        Min = 0, Max = 600, Round = 0, Default = desyncConfig.radius, Type = "",
        Callback = function(value)
            desyncConfig.radius = math.clamp(value, 0, 600)
            SaveAllSettings()
        end,
    })
    DesyncSection:AddSlider({
        Name = "Oscillation Height",
        Min = 0, Max = 300, Round = 0, Default = desyncConfig.height, Type = "",
        Callback = function(value)
            desyncConfig.height = math.clamp(value, 0, 300)
            SaveAllSettings()
        end,
    })
    DesyncSection:AddSlider({
        Name = "Velocity Spike",
        Min = 0, Max = 50000, Round = 0, Default = desyncConfig.spike, Type = "",
        Callback = function(value)
            desyncConfig.spike = math.clamp(value, 0, 50000)
            SaveAllSettings()
        end,
    })
    DesyncSection:AddToggle({
        Name = "Smart Desync (auto-arms the panel)",
        Default = false,
        Callback = function(value)
            desyncConfig.smart = value
            if value then
                if not desyncActive then
                    DesyncSetup()
                    desyncActive = true
                end
                if desyncActivationBtn then
                    desyncActivationBtn.Text = "ON"
                    desyncActivationBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
                end
                DisableEclipseImmortalAuto()
                ENXNotify.new('EclipseNexus', 'Smart Desync ON v3 - CLASS SWEEP engine auto-armed; every real ball is classified each beat from its real speed (SLOW / MEDIUM / FAST) and each class answers with its own net, lead window and hold - slow balls get the widest net and the longest hold, fast balls a tight net with the widest ETA lead and a short hard hold; the direction memory flags CURVE balls (net widens, Curve Boost added) and a ball still flying at you inside its class net is a missed parry (Miss Boost added); every hold write is a ratchet so holds only extend; speed changes need no detector - an accelerating ball simply re-classifies. Simulator-validated: slow/medium/fast straight + curved, accelerating and rebound balls all trip with time to spare; orbiters that can never close and receders stay quiet. v222: holds default to 180 seconds and every Hold slider reaches 300, honored from the last threat to the exact time you set', 3)
            else
                if desyncActive then
                    DesyncStopLoops()
                    pcall(function()
                        local pg = ENXData.Player.LocalPlayer:FindFirstChild("PlayerGui")
                        if pg then
                            local old = pg:FindFirstChild("EclipseNexus_SemiImmortality")
                            if old then old:Destroy() end
                        end
                    end)
                end
                ENXNotify.new('EclipseNexus', 'Smart Desync OFF - engine disarmed (enable Semi Immortal again for always-on spoofing)', 3)
            end
        end,
    })
    DesyncSection:AddSlider({
        Name = "Sweep Range (studs)",
        Min = 20, Max = 5000, Round = 0, Default = desyncConfig.range, Type = "",
        Callback = function(value)
            desyncConfig.range = math.clamp(value, 20, 5000)
            SaveAllSettings()
        end,
    })
    DesyncSection:AddSlider({
        Name = "Slow Class Cap (studs/s)",
        Min = 5, Max = 300, Round = 0, Default = desyncConfig.slowCap, Type = "",
        Callback = function(value)
            desyncConfig.slowCap = math.clamp(value, 5, 300)
            SaveAllSettings()
        end,
    })
    DesyncSection:AddSlider({
        Name = "Fast Class Floor (studs/s)",
        Min = 80, Max = 1000, Round = 0, Default = desyncConfig.fastFloor, Type = "",
        Callback = function(value)
            desyncConfig.fastFloor = math.clamp(value, 80, 1000)
            SaveAllSettings()
        end,
    })
    DesyncSection:AddSlider({
        Name = "Lead Window (seconds)",
        Min = 0, Max = 60, Round = 0, Default = desyncConfig.lead, Type = "",
        Callback = function(value)
            desyncConfig.lead = math.clamp(value, 0, 60)
            SaveAllSettings()
        end,
    })
    DesyncSection:AddSlider({
        Name = "Hold Slow (seconds)",
        Min = 1, Max = 300, Round = 0, Default = desyncConfig.holdSlow, Type = "",
        Callback = function(value)
            desyncConfig.holdSlow = math.clamp(value, 1, 300)
            SaveAllSettings()
        end,
    })
    DesyncSection:AddSlider({
        Name = "Hold Medium (seconds)",
        Min = 1, Max = 300, Round = 0, Default = desyncConfig.holdMed, Type = "",
        Callback = function(value)
            desyncConfig.holdMed = math.clamp(value, 1, 300)
            SaveAllSettings()
        end,
    })
    DesyncSection:AddSlider({
        Name = "Hold Fast (seconds)",
        Min = 1, Max = 300, Round = 0, Default = desyncConfig.holdFast, Type = "",
        Callback = function(value)
            desyncConfig.holdFast = math.clamp(value, 1, 300)
            SaveAllSettings()
        end,
    })
    DesyncSection:AddSlider({
        Name = "Curve Turn (deg/s)",
        Min = 1, Max = 180, Round = 0, Default = desyncConfig.turn, Type = "",
        Callback = function(value)
            desyncConfig.turn = math.clamp(value, 1, 180)
            SaveAllSettings()
        end,
    })
    DesyncSection:AddSlider({
        Name = "Curve Boost (seconds)",
        Min = 0, Max = 30, Round = 0, Default = desyncConfig.curveBoost, Type = "",
        Callback = function(value)
            desyncConfig.curveBoost = math.clamp(value, 0, 30)
            SaveAllSettings()
        end,
    })
    DesyncSection:AddSlider({
        Name = "Miss Boost (seconds)",
        Min = 0, Max = 30, Round = 0, Default = desyncConfig.missBoost, Type = "",
        Callback = function(value)
            desyncConfig.missBoost = math.clamp(value, 0, 30)
            SaveAllSettings()
        end,
    })

    task.spawn(function()
        while true do
            task.wait(2)
            if desyncActive and not desyncConns then
                DesyncSetup()
                desyncActive = true
                if desyncActivationBtn then
                    desyncActivationBtn.Text = "ON"
                    desyncActivationBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
                end
                ENXNotify.new('EclipseNexus', 'EclipseNexus Semi Immortal watchdog re-armed the desync engine', 3)
            end
        end
    end)

    local BloodmoonImmSection = ImmortalTab:AddSection({
        Name = "EclipseImmortal",
        Position = "right"
    })

    BloodmoonImmSection:AddToggle({
        Name = 'Enable EclipseImmortal',
        Default = Immortality.Enabled,
        Callback = function(value)
            if value then
                if desyncActive then
                    SemiDesyncStopBridge()
                    ENXNotify.new('EclipseNexus', 'EclipseNexus Semi Immortal auto-stopped - run ONE immortal system', 3)
                end
                pcall(function() if getgenv()._ENX_V2Stop then getgenv()._ENX_V2Stop() end end)
            end
            Immortality.Enabled = value
            if value and getgenv()._ENX_EnsureImmortalityHook then pcall(getgenv()._ENX_EnsureImmortalityHook) end
            SaveAllSettings()
            ENXNotify.new('EclipseNexus', value and 'EclipseImmortal ON' or 'EclipseImmortal OFF', 3)
        end,
    })

    BloodmoonImmSection:AddSlider({
        Name = 'Angle',
        Min = 10, Max = 360, Round = 0,
        Default = Immortality.Angle, Type = " deg",
        Callback = function(value) Immortality.Angle = value; SaveAllSettings() end,
    })

    BloodmoonImmSection:AddSlider({
        Name = 'Height',
        Min = 0, Max = 50, Round = 0,
        Default = Immortality.Height, Type = " studs",
        Callback = function(value) Immortality.Height = value; SaveAllSettings() end,
    })

    BloodmoonImmSection:AddSlider({
        Name = 'Depth',
        Min = -50, Max = 0, Round = 0,
        Default = Immortality.Depth, Type = " studs",
        Callback = function(value) Immortality.Depth = value; SaveAllSettings() end,
    })

    BloodmoonImmSection:AddSlider({
        Name = 'Square Radius',
        Min = 0, Max = 100, Round = 0,
        Default = Immortality.SquareRadius, Type = " studs",
        Callback = function(value) Immortality.SquareRadius = value; SaveAllSettings() end,
    })

    BloodmoonImmSection:AddToggle({
        Name = 'Speed Bypass',
        Default = Immortality.SpeedBypassEnabled,
        Callback = function(value) Immortality.SpeedBypassEnabled = value; SaveAllSettings() end,
    })

    BloodmoonImmSection:AddLabel("EclipseImmortal — angle-based desync.")
    BloodmoonImmSection:AddLabel("Uses CFrame offset + hookmetamethod __index.")
    BloodmoonImmSection:AddLabel("v210: enabling one immortal auto-disables the other.")

    local V2Section = ImmortalTab:AddSection({
        Name = "EclipseNexus v2",
        Position = "right"
    })

    local V2Config = {
        radius = 200,
        height = 100,
        angles = 360,
        visualizer_enabled = false,
        visualizer_color = Color3.fromRGB(255, 0, 0),
    }
    local V2State = {
        enabled = false,
        notify = false,
        connections = {},
        cache = {
            character = nil,
            hrp = nil,
            head = nil,
            alive = nil,
            original_cframe = nil,
            original_velocity = nil,
        },
        visualizer = { parts = {}, folder = nil },
    }
    local V2Consts = { empty_cframe = CFrame.new(), velocity = Vector3.new(1, 1, 1) }
    local V2OldIndex = nil

    local function V2UpdateCache()
        local character = ENXData.Player.LocalPlayer.Character
        if character == V2State.cache.character then
            return
        end
        V2State.cache.character = character
        if character then
            V2State.cache.hrp = character:FindFirstChild("HumanoidRootPart")
            V2State.cache.head = character:FindFirstChild("Head")
            V2State.cache.alive = workspace:FindFirstChild("Alive")
        else
            V2State.cache.hrp = nil
            V2State.cache.head = nil
        end
    end

    local function V2IsInAlive()
        return V2State.cache.alive and V2State.cache.character and V2State.cache.character.Parent == V2State.cache.alive
    end

    local function V2GetRandomPosition()
        if not V2State.cache.hrp then
            return V2Consts.empty_cframe
        end
        local hrp = V2State.cache.hrp
        local pos = hrp.Position
        local angle = math.rad(math.random(0, V2Config.angles))
        local radius = V2Config.radius
        local height = math.floor(tick() * 11.9) % 2 == 0 and 0 or V2Config.height
        local x = pos.X + math.cos(angle) * radius
        height = pos.Y - hrp.Size.Y * 0.5 + 5 + height
        local z = pos.Z + math.sin(angle) * radius
        return CFrame.new(x, height, z)
    end

    local function V2CreateVisualizer()
        if V2State.visualizer.folder then
            V2State.visualizer.folder:Destroy()
        end
        local folder = Instance.new("Folder")
        folder.Name = "ImmortalVisualizer"
        folder.Parent = workspace
        V2State.visualizer.folder = folder
    end

    local function V2UpdateVisualizer(position)
        if not V2Config.visualizer_enabled or not V2State.visualizer.folder then
            return
        end
        for _, part in ipairs(V2State.visualizer.parts) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        V2State.visualizer.parts = {}
        local marker = Instance.new("Part")
        marker.Size = Vector3.new(2, 1, 2)
        marker.CFrame = position
        marker.Anchored = true
        marker.CanCollide = false
        marker.Material = Enum.Material.Neon
        marker.Color = V2Config.visualizer_color
        marker.Transparency = 0.5
        marker.Parent = V2State.visualizer.folder
        table.insert(V2State.visualizer.parts, marker)
        game:GetService("Debris"):AddItem(marker, 0.1)
    end

    local function V2DestroyVisualizer()
        if V2State.visualizer.folder then
            V2State.visualizer.folder:Destroy()
            V2State.visualizer.folder = nil
        end
        V2State.visualizer.parts = {}
    end

    local V2BeatBusy = false
    local V2LastBeat = 0

    local function V2PerformDesync()
        V2LastBeat = os.clock()
        if V2BeatBusy then
            return
        end
        V2UpdateCache()
        if not V2State.enabled or not V2State.cache.hrp or not V2IsInAlive() then
            return
        end
        V2BeatBusy = true
        pcall(function()
            local hrp = V2State.cache.hrp
            if setfflag then
                pcall(setfflag, "S2PhysicsSenderRate", "1333335")
            end
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 0.01, 0)
            V2State.cache.original_cframe = hrp.CFrame
            V2State.cache.original_velocity = hrp.AssemblyLinearVelocity
            local target = V2GetRandomPosition()
            hrp.CFrame = target
            hrp.AssemblyLinearVelocity = V2Consts.velocity
            if V2Config.visualizer_enabled then
                V2UpdateVisualizer(target)
            end
            pcall(RunService.RenderStepped.Wait, RunService.RenderStepped)
            hrp.CFrame = V2State.cache.original_cframe
            hrp.AssemblyLinearVelocity = V2State.cache.original_velocity
        end)
        V2BeatBusy = false
    end

    local function V2ResetCache()
        V2State.cache.character = nil
        V2State.cache.hrp = nil
        V2State.cache.head = nil
        V2State.cache.alive = nil
        V2State.cache.original_cframe = nil
        V2State.cache.original_velocity = nil
    end

    local function V2ArmReplication()
        V2UpdateCache()
        pcall(function()
            if setfflag then
                setfflag("S2PhysicsSenderRate", "1333335")
            end
        end)
        pcall(function()
            local hrp = V2State.cache.hrp
            if hrp then
                hrp:SetNetworkOwner(LocalPlayer)
            end
        end)
    end

    local function V2Start()
        if V2State.enabled then
            return
        end
        V2State.enabled = true
        V2ArmReplication()
        if V2Config.visualizer_enabled then
            V2CreateVisualizer()
        end
        if not V2State.connections.heartbeat then
            V2State.connections.heartbeat = RunService.Heartbeat:Connect(V2PerformDesync)
        end
        if not V2State.connections.stepped then
            V2State.connections.stepped = RunService.Stepped:Connect(function()
                pcall(function()
                    local hrp = V2State.cache.hrp
                    if hrp then
                        hrp:SetNetworkOwner(LocalPlayer)
                    end
                end)
            end)
        end
        if not V2State.connections.watchdog then
            V2State.connections.watchdog = RunService.Heartbeat:Connect(function()
                if not V2State.enabled or os.clock() - V2LastBeat <= 2 then
                    return
                end
                V2LastBeat = os.clock()
                if V2State.connections.heartbeat then
                    V2State.connections.heartbeat:Disconnect()
                end
                V2State.connections.heartbeat = RunService.Heartbeat:Connect(V2PerformDesync)
            end)
        end
    end

    local function V2Stop()
        if not V2State.enabled then
            return
        end
        V2State.enabled = false
        if V2State.connections.heartbeat then
            V2State.connections.heartbeat:Disconnect()
            V2State.connections.heartbeat = nil
        end
        if V2State.connections.stepped then
            V2State.connections.stepped:Disconnect()
            V2State.connections.stepped = nil
        end
        if V2State.connections.watchdog then
            V2State.connections.watchdog:Disconnect()
            V2State.connections.watchdog = nil
        end
        V2DestroyVisualizer()
        V2ResetCache()
    end

    if getgenv()._ENX_V2CharConn then
        pcall(function() getgenv()._ENX_V2CharConn:Disconnect() end)
    end
    getgenv()._ENX_V2CharConn = ENXData.Player.LocalPlayer.CharacterAdded:Connect(function()
        if not V2State.enabled then
            return
        end
        task.wait(1)
        V2ResetCache()
        if V2State.connections.heartbeat then
            V2State.connections.heartbeat:Disconnect()
        end
        V2State.connections.heartbeat = RunService.Heartbeat:Connect(V2PerformDesync)
        if V2Config.visualizer_enabled then
            V2CreateVisualizer()
        end
    end)

    getgenv()._ENX_V2Stop = function()
        if V2State.enabled then
            V2Stop()
            ENXNotify.new('EclipseNexus', 'EclipseNexus v2 auto-stopped - run ONE immortal system', 3)
        end
    end

    local V2Flags = {}
    do
        local ok, data = pcall(function()
            if isfile and readfile and isfile("EclipseNexus/v2immortal.json") then
                return game:GetService("HttpService"):JSONDecode(readfile("EclipseNexus/v2immortal.json"))
            end
        end)
        if ok and type(data) == "table" then
            V2Flags = data
        end
    end
    if V2Flags.v2_defaults_stamp ~= 1 then
        V2Flags.v2_radius = 200
        V2Flags.v2_height = 100
        V2Flags.v2_defaults_stamp = 1
    end

    local function V2SaveFlags()
        pcall(function()
            if writefile then
                if isfolder and makefolder and not isfolder("EclipseNexus") then
                    makefolder("EclipseNexus")
                end
                writefile("EclipseNexus/v2immortal.json", game:GetService("HttpService"):JSONEncode(V2Flags))
            end
        end)
    end

    local function V2FlagType(flag, kind)
        if not V2Flags[flag] then
            return nil
        end
        return typeof(V2Flags[flag]) == kind
    end

    local V2Conns = {}

    local function V2Disconnect(key)
        local conn = V2Conns[key]
        if not conn then
            return
        end
        conn:Disconnect()
        V2Conns[key] = nil
    end

    local V2Theme = {
        Background = Color3.fromRGB(12, 11, 17),
        Stroke = Color3.fromRGB(36, 40, 55),
        StrokeHot = Color3.fromRGB(99, 75, 130),
        Accent = Color3.fromRGB(99, 75, 241),
        AccentDim = Color3.fromRGB(55, 55, 190),
        AccentSoft = Color3.fromRGB(172, 178, 255),
        Text = Color3.fromRGB(235, 235, 245),
    }

    local V2TweenService = game:GetService("TweenService")
    local V2UserInputService = game:GetService("UserInputService")
    local V2Mouse = ENXData.Player.LocalPlayer:GetMouse()
    local V2RowWidth = 176

    local function V2CreateCheckbox(container, cfg)
        cfg = cfg or {}
        cfg.title = cfg.title or ""
        cfg.callback = cfg.callback or function() end
        local state = { _state = false }
        local row = Instance.new("TextButton")
        row.Text = ""
        row.AutoButtonColor = false
        row.BackgroundTransparency = 1
        row.Name = "Checkbox"
        row.Size = UDim2.new(0, V2RowWidth, 0, 21)
        row.BorderSizePixel = 0
        row.Parent = container
        local title = Instance.new("TextLabel")
        title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
        title.TextSize = 11
        title.TextColor3 = V2Theme.Text
        title.TextTransparency = 0.16
        title.Text = cfg.title
        title.Size = UDim2.new(0, V2RowWidth - 54, 0, 13)
        title.AnchorPoint = Vector2.new(0, 0.5)
        title.Position = UDim2.new(0, 0, 0.5, 0)
        title.BackgroundTransparency = 1
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = row
        local box = Instance.new("Frame")
        box.AnchorPoint = Vector2.new(1, 0.5)
        box.BackgroundTransparency = 0.86
        box.Position = UDim2.new(1, 0, 0.5, 0)
        box.Name = "Box"
        box.Size = UDim2.new(0, 15, 0, 15)
        box.BorderSizePixel = 0
        box.BackgroundColor3 = V2Theme.Accent
        box.Parent = row
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 4)
        boxCorner.Parent = box
        local boxStroke = Instance.new("UIStroke")
        boxStroke.Color = V2Theme.StrokeHot
        boxStroke.Transparency = 0.3
        boxStroke.Parent = box
        local fill = Instance.new("Frame")
        fill.AnchorPoint = Vector2.new(0.5, 0.5)
        fill.BackgroundTransparency = 0.86
        fill.Position = UDim2.new(0.5, 0, 0.5, 0)
        fill.Name = "Fill"
        fill.Size = UDim2.fromOffset(0, 0)
        fill.BorderSizePixel = 0
        fill.BackgroundColor3 = V2Theme.Accent
        fill.Parent = box
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 3)
        fillCorner.Parent = fill

        function state.change_state(s, value)
            s._state = value
            V2TweenService:Create(box, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = value and 0.62 or 0.86 }):Play()
            V2TweenService:Create(fill, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = value and UDim2.fromOffset(9, 9) or UDim2.fromOffset(0, 0) }):Play()
            if cfg.flag then
                V2Flags[cfg.flag] = s._state
                V2SaveFlags()
            end
            cfg.callback(s._state)
        end

        if cfg.flag and V2FlagType(cfg.flag, "boolean") then
            state:change_state(V2Flags[cfg.flag])
        end

        row.MouseButton1Click:Connect(function()
            state:change_state(not state._state)
        end)

        return state
    end

    local function V2CreateSlider(container, cfg)
        cfg = cfg or {}
        cfg.title = cfg.title or "Slider"
        cfg.minimum_value = cfg.minimum_value or 0
        cfg.maximum_value = cfg.maximum_value or 100
        cfg.decimals = cfg.decimals or 0
        cfg.callback = cfg.callback or function() end
        local mult = 10 ^ cfg.decimals

        local function fmt(v)
            if cfg.decimals == 0 then
                return tostring(math.floor(v))
            end
            return string.format("%." .. cfg.decimals .. "f", v)
        end

        local row = Instance.new("TextButton")
        row.Text = ""
        row.AutoButtonColor = false
        row.BackgroundTransparency = 1
        row.Name = "Slider"
        row.Size = UDim2.new(0, V2RowWidth, 0, 28)
        row.BorderSizePixel = 0
        row.Parent = container
        local title = Instance.new("TextLabel")
        title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
        title.TextSize = 12
        title.TextColor3 = V2Theme.Text
        title.TextTransparency = 0.16
        title.Text = cfg.title
        title.Size = UDim2.new(0, V2RowWidth - 54, 0, 13)
        title.Position = UDim2.new(0, 0, 0.05, 0)
        title.BackgroundTransparency = 1
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = row
        local drag = Instance.new("Frame")
        drag.AnchorPoint = Vector2.new(0.5, 1)
        drag.BackgroundTransparency = 0.78
        drag.Position = UDim2.new(0.5, 0, 0.5, 0)
        drag.Name = "Drag"
        drag.Size = UDim2.new(0, V2RowWidth, 0, 4)
        drag.BorderSizePixel = 0
        drag.BackgroundColor3 = V2Theme.Stroke
        drag.Parent = row
        local dragCorner = Instance.new("UICorner")
        dragCorner.CornerRadius = UDim.new(0, 4)
        dragCorner.Parent = drag
        local fillBar = Instance.new("Frame")
        fillBar.AnchorPoint = Vector2.new(0, 0.5)
        fillBar.BackgroundTransparency = 0.05
        fillBar.Position = UDim2.new(0, 0, 0.5, 0)
        fillBar.Name = "Fill"
        fillBar.Size = UDim2.new(0, math.floor(V2RowWidth / 2), 0, 4)
        fillBar.BorderSizePixel = 0
        fillBar.BackgroundColor3 = V2Theme.Accent
        fillBar.Parent = drag
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 2)
        fillCorner.Parent = fillBar
        local fillGradient = Instance.new("UIGradient")
        fillGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, V2Theme.AccentSoft), ColorSequenceKeypoint.new(1, V2Theme.AccentDim) })
        fillGradient.Parent = fillBar
        local circle = Instance.new("Frame")
        circle.AnchorPoint = Vector2.new(1, 0.5)
        circle.Name = "Circle"
        circle.Position = UDim2.new(1, 0, 0.5, 0)
        circle.Size = UDim2.new(0, 7, 0, 7)
        circle.BorderSizePixel = 0
        circle.BackgroundColor3 = V2Theme.AccentSoft
        circle.Parent = fillBar
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(0, 4)
        circleCorner.Parent = circle
        local valueLabel = Instance.new("TextLabel")
        valueLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
        valueLabel.TextColor3 = Color3.fromRGB(235, 235, 245)
        valueLabel.TextTransparency = 0.2
        valueLabel.Text = "0"
        valueLabel.Name = "Value"
        valueLabel.Size = UDim2.new(0, 42, 0, 13)
        valueLabel.AnchorPoint = Vector2.new(1, 0)
        valueLabel.Position = UDim2.new(1, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.TextSize = 10
        valueLabel.Parent = row

        local slider = {
            set_percentage = function(s, v)
                local value = math.floor(math.clamp(v, cfg.minimum_value, cfg.maximum_value) * mult + 0.5) / mult
                local px = math.clamp((value - cfg.minimum_value) / (cfg.maximum_value - cfg.minimum_value), 0.02, 1) * drag.Size.X.Offset
                if cfg.flag then
                    V2Flags[cfg.flag] = value
                end
                valueLabel.Text = fmt(value)
                V2TweenService:Create(fillBar, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(px, drag.Size.Y.Offset) }):Play()
                cfg.callback(value)
            end,
            update = function(s)
                s:set_percentage(cfg.minimum_value + (cfg.maximum_value - cfg.minimum_value) * math.clamp((V2Mouse.X - drag.AbsolutePosition.X) / drag.Size.X.Offset, 0, 1))
            end,
            input = function(s)
                s:update()
                if cfg.flag then
                    V2Conns["slider_drag_" .. cfg.flag] = V2Mouse.Move:Connect(function()
                        s:update()
                    end)
                    V2Conns["slider_input_" .. cfg.flag] = V2UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and inp.UserInputType ~= Enum.UserInputType.Touch then
                            return
                        end
                        V2Disconnect("slider_drag_" .. cfg.flag)
                        V2Disconnect("slider_input_" .. cfg.flag)
                        if not cfg.ignoresaved then
                            V2SaveFlags()
                        end
                    end)
                end
            end
        }

        if cfg.flag and V2FlagType(cfg.flag, "number") and not cfg.ignoresaved then
            slider:set_percentage(V2Flags[cfg.flag])
        else
            slider:set_percentage(cfg.value)
        end

        row.MouseButton1Down:Connect(function()
            slider:input()
        end)

        return slider
    end

    local function V2CreateColorPicker(container, cfg)
        cfg = cfg or {}
        cfg.title = cfg.title or "Color"
        cfg.callback = cfg.callback or function() end
        local hsv = { _h = 0, _s = 1, _v = 1 }

        if cfg.flag and V2Flags[cfg.flag] then
            local saved = V2Flags[cfg.flag]
            if type(saved) == "table" and saved.H ~= nil then
                hsv._h = saved.H
                hsv._s = saved.S
                hsv._v = saved.V
            end
        elseif cfg.color then
            local h0, s0, v0 = Color3.toHSV(cfg.color)
            hsv._h = h0
            hsv._s = s0
            hsv._v = v0
        end

        local row = Instance.new("TextButton")
        row.Size = UDim2.new(0, V2RowWidth, 0, 20)
        row.BackgroundTransparency = 1
        row.Text = ""
        row.AutoButtonColor = false
        row.Parent = container
        local title = Instance.new("TextLabel")
        title.Text = cfg.title
        title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
        title.TextSize = 11
        title.TextColor3 = V2Theme.Text
        title.TextTransparency = 0.16
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(0, V2RowWidth - 57, 1, 0)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = row
        local swatch = Instance.new("Frame")
        swatch.Size = UDim2.new(0, 44, 0, 14)
        swatch.AnchorPoint = Vector2.new(1, 0.5)
        swatch.Position = UDim2.new(1, 0, 0.5, 0)
        swatch.BorderSizePixel = 0
        swatch.BackgroundColor3 = Color3.fromHSV(hsv._h, hsv._s, hsv._v)
        swatch.Parent = row
        local swatchCorner = Instance.new("UICorner")
        swatchCorner.CornerRadius = UDim.new(0, 5)
        swatchCorner.Parent = swatch
        local swatchStroke = Instance.new("UIStroke")
        swatchStroke.Color = V2Theme.StrokeHot
        swatchStroke.Transparency = 0.38
        swatchStroke.Parent = swatch
        local arrow = Instance.new("TextLabel")
        arrow.Text = "›"
        arrow.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
        arrow.TextSize = 14
        arrow.TextColor3 = V2Theme.Accent
        arrow.BackgroundTransparency = 1
        arrow.Size = UDim2.new(0, 12, 1, 0)
        arrow.AnchorPoint = Vector2.new(1, 0.5)
        arrow.Position = UDim2.new(1, -50, 0.5, 0)
        arrow.Rotation = 90
        arrow.Parent = row
        local panel = Instance.new("Frame")
        panel.Size = UDim2.new(0, V2RowWidth, 0, 0)
        panel.BackgroundTransparency = 1
        panel.ClipsDescendants = true
        panel.BorderSizePixel = 0
        panel.Parent = container
        local svBox = Instance.new("Frame")
        svBox.Size = UDim2.new(1, 0, 0, 62)
        svBox.Position = UDim2.new(0, 0, 0, 4)
        svBox.BorderSizePixel = 0
        svBox.BackgroundColor3 = Color3.fromHSV(hsv._h, 1, 1)
        svBox.ClipsDescendants = true
        svBox.Active = true
        svBox.Parent = panel
        local svCorner = Instance.new("UICorner")
        svCorner.CornerRadius = UDim.new(0, 6)
        svCorner.Parent = svBox
        local svWhite = Instance.new("Frame")
        svWhite.Size = UDim2.new(1, 0, 1, 0)
        svWhite.BackgroundColor3 = Color3.new(1, 1, 1)
        svWhite.BorderSizePixel = 0
        svWhite.ZIndex = 2
        svWhite.Parent = svBox
        local svWhiteGradient = Instance.new("UIGradient")
        svWhiteGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
        svWhiteGradient.Parent = svWhite
        local svBlack = Instance.new("Frame")
        svBlack.Size = UDim2.new(1, 0, 1, 0)
        svBlack.BackgroundColor3 = Color3.new(0, 0, 0)
        svBlack.BorderSizePixel = 0
        svBlack.ZIndex = 3
        svBlack.Parent = svBox
        local svBlackGradient = Instance.new("UIGradient")
        svBlackGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
        svBlackGradient.Rotation = 90
        svBlackGradient.Parent = svBlack
        local svCursor = Instance.new("Frame")
        svCursor.Size = UDim2.new(0, 12, 0, 12)
        svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        svCursor.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        svCursor.BorderSizePixel = 0
        svCursor.ZIndex = 5
        svCursor.Visible = false
        svCursor.Position = UDim2.new(hsv._s, 0, 1 - hsv._v, 0)
        svCursor.Parent = svBox
        local svCursorCorner = Instance.new("UICorner")
        svCursorCorner.CornerRadius = UDim.new(1, 0)
        svCursorCorner.Parent = svCursor
        local svCursorDot = Instance.new("Frame")
        svCursorDot.Size = UDim2.new(0, 8, 0, 8)
        svCursorDot.AnchorPoint = Vector2.new(0.5, 0.5)
        svCursorDot.Position = UDim2.new(0.5, 0, 0.5, 0)
        svCursorDot.BackgroundColor3 = Color3.new(1, 1, 1)
        svCursorDot.BorderSizePixel = 0
        svCursorDot.ZIndex = 6
        svCursorDot.Parent = svCursor
        local svCursorDotCorner = Instance.new("UICorner")
        svCursorDotCorner.CornerRadius = UDim.new(1, 0)
        svCursorDotCorner.Parent = svCursorDot
        local hueBar = Instance.new("Frame")
        hueBar.Size = UDim2.new(1, 0, 0, 12)
        hueBar.Position = UDim2.new(0, 0, 0, 72)
        hueBar.BorderSizePixel = 0
        hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
        hueBar.Active = true
        hueBar.Parent = panel
        local hueCorner = Instance.new("UICorner")
        hueCorner.CornerRadius = UDim.new(0, 5)
        hueCorner.Parent = hueBar
        local hueGradient = Instance.new("UIGradient")
        hueGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
            ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
            ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
            ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 1, 1))
        })
        hueGradient.Parent = hueBar
        local hueCursor = Instance.new("Frame")
        hueCursor.Size = UDim2.new(0, 6, 1, 4)
        hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        hueCursor.Position = UDim2.new(hsv._h, 0, 0.5, 0)
        hueCursor.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        hueCursor.BorderSizePixel = 0
        hueCursor.ZIndex = 4
        hueCursor.Visible = false
        hueCursor.Parent = hueBar
        local hueCursorCorner = Instance.new("UICorner")
        hueCursorCorner.CornerRadius = UDim.new(0, 3)
        hueCursorCorner.Parent = hueCursor
        local hueCursorDot = Instance.new("Frame")
        hueCursorDot.Size = UDim2.new(0, 8, 1, 0)
        hueCursorDot.AnchorPoint = Vector2.new(0.5, 0.5)
        hueCursorDot.Position = UDim2.new(0.5, 0, 0.5, 0)
        hueCursorDot.BackgroundColor3 = Color3.new(1, 1, 1)
        hueCursorDot.BorderSizePixel = 0
        hueCursorDot.ZIndex = 5
        hueCursorDot.Parent = hueCursor
        local hueCursorDotCorner = Instance.new("UICorner")
        hueCursorDotCorner.CornerRadius = UDim.new(0, 2)
        hueCursorDotCorner.Parent = hueCursorDot

        local function get_color()
            return Color3.fromHSV(hsv._h, hsv._s, hsv._v)
        end

        local function update_visuals()
            swatch.BackgroundColor3 = get_color()
            svBox.BackgroundColor3 = Color3.fromHSV(hsv._h, 1, 1)
            svCursor.Position = UDim2.new(hsv._s, 0, 1 - hsv._v, 0)
            hueCursor.Position = UDim2.new(hsv._h, 0, 0.5, 0)
        end

        local function commit()
            if cfg.flag then
                V2Flags[cfg.flag] = { H = hsv._h, S = hsv._s, V = hsv._v }
                V2SaveFlags()
            end
            cfg.callback(get_color())
        end

        local svDrag = false
        local hueDrag = false

        svBox.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                svDrag = true
            end
        end)

        hueBar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                hueDrag = true
            end
        end)

        V2Conns["cp_moved_" .. tostring(cfg.flag)] = V2UserInputService.InputChanged:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then
                return
            end
            if svDrag then
                hsv._s = math.clamp((inp.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
                hsv._v = 1 - math.clamp((inp.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                update_visuals()
                cfg.callback(Color3.fromHSV(hsv._h, hsv._s, hsv._v))
            end
            if not hueDrag then
                return
            end
            hsv._h = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
            update_visuals()
            cfg.callback(Color3.fromHSV(hsv._h, hsv._s, hsv._v))
        end)

        V2Conns["cp_ended_" .. tostring(cfg.flag)] = V2UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and inp.UserInputType ~= Enum.UserInputType.Touch then
                return
            end
            if svDrag or hueDrag then
                svDrag = false
                hueDrag = false
                commit()
            end
        end)

        local open = false

        row.MouseButton1Click:Connect(function()
            open = not open
            svCursor.Visible = open
            hueCursor.Visible = open
            V2TweenService:Create(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, V2RowWidth, 0, open and 90 or 0)
            }):Play()
            V2TweenService:Create(arrow, TweenInfo.new(0.25), { Rotation = open and -90 or 90 }):Play()
        end)

        update_visuals()

        if cfg.callback then
            cfg.callback(get_color())
        end

        function hsv.Set(h, color)
            local h2, s2, v2 = Color3.toHSV(color)
            h._h = h2
            h._s = s2
            h._v = v2
            update_visuals()
            commit()
        end

        return hsv
    end

    V2CreateCheckbox(V2Section.Frame, {
        title = "EclipseNexus v2",
        flag = "v2_enabled",
        callback = function(value)
            if value then
                if desyncActive then
                    SemiDesyncStopBridge()
                    ENXNotify.new('EclipseNexus', 'EclipseNexus Semi Immortal auto-stopped - run ONE immortal system', 3)
                end
                if Immortality.Enabled then
                    Immortality.Enabled = false
                    ENXNotify.new('EclipseNexus', 'EclipseImmortal auto-disabled - run ONE immortal system', 3)
                end
                V2Start()
                if not V2OldIndex and hookmetamethod and checkcaller and newcclosure then
                    V2OldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
                        if not V2State.enabled or checkcaller() or key ~= "CFrame" or not V2State.cache.hrp or not V2IsInAlive() then
                            return V2OldIndex(self, key)
                        end
                        if self == V2State.cache.hrp then
                            return V2State.cache.original_cframe or V2Consts.empty_cframe
                        elseif self == V2State.cache.head and V2State.cache.original_cframe then
                            local upOffset = Vector3.new(0, V2State.cache.hrp.Size.Y * 0.5 + 0.5, 0)
                            return V2State.cache.original_cframe + upOffset
                        end
                        return V2OldIndex(self, key)
                    end))
                end
                ENXNotify.new('EclipseNexus', 'EclipseNexus v2 ON', 3)
            else
                V2Stop()
                ENXNotify.new('EclipseNexus', 'EclipseNexus v2 OFF', 3)
            end
        end,
    })

    V2CreateCheckbox(V2Section.Frame, {
        title = "Show Visualizer",
        flag = "v2_visualizer",
        callback = function(value)
            V2Config.visualizer_enabled = value
            if value and V2State.enabled then
                V2CreateVisualizer()
            elseif not value then
                V2DestroyVisualizer()
            end
        end,
    })

    V2CreateColorPicker(V2Section.Frame, {
        title = "Visualizer Color",
        flag = "v2_visualizer_color",
        color = V2Config.visualizer_color,
        callback = function(value)
            V2Config.visualizer_color = value
        end,
    })

    V2CreateSlider(V2Section.Frame, {
        title = "Radius",
        flag = "v2_radius",
        value = 200,
        minimum_value = 0,
        maximum_value = 200,
        callback = function(value)
            V2Config.radius = value
        end,
    })

    V2CreateSlider(V2Section.Frame, {
        title = "Height",
        flag = "v2_height",
        value = 100,
        minimum_value = 0,
        maximum_value = 100,
        callback = function(value)
            V2Config.height = value
        end,
    })

    V2Section:AddLabel("Enabling one immortal auto-stops the others.")

    local InfoSection2 = ImmortalTab:AddSection({ Name = "Info", Position = "left" })
    InfoSection2:AddLabel("Three immortal systems available:")
    InfoSection2:AddLabel("1. EclipseNexus Semi Immortal (desync) — left side")
    InfoSection2:AddLabel("2. EclipseImmortal — right side")
    InfoSection2:AddLabel("3. EclipseNexus v2 (orbit) — right side")
    InfoSection2:AddLabel("Pick ONE - auto-disables the others for you.")
    InfoSection2:AddLabel("v210: Semi Immortal tuning sliders persist across re-executes.")

end

do
    local ParryBoostTab = getgenv()._ENX_Tabs.ParryBoost

    local ParryBoostSection = ParryBoostTab:AddSection({
        Name = "Boost Settings",
        Position = "left"
    })

    local ParryBoost = {
        Enabled = getgenv()._ENX_BoostEngine or false,
        PreClick = getgenv()._ENX_BoostPreClick or 1.3,
        HitSound = false,
        Mode = getgenv()._ENX_BoostMode or "Distance",
        Timing = getgenv()._ENX_BoostTiming or 100,
        TargetTime = getgenv()._ENX_BoostWindow or 0.3,
    }

    if not getgenv()._ENX_ParryLock then
        getgenv()._ENX_ParryLock = { lastFire = 0, LOCK_TIME = 0.4 }
    end
    local ParryLock = getgenv()._ENX_ParryLock

    local function CanFire()
        return (tick() - ParryLock.lastFire) >= ParryLock.LOCK_TIME
    end

    local function MarkFired()
        ParryLock.lastFire = tick()
    end

    getgenv()._ENX_SpamBoostActive = false
    local OriginalFireParry = FireParry
    FireParry = function(...)
        if getgenv()._ENX_SpamBoostActive then return end
        local isSpamming = ENXData.Config.AutoSpamParry.Spamming
            or ENXData.Config.ManualSpamParry.Spamming
        if not isSpamming and not CanFire() then return end
        if not isSpamming then
            MarkFired()
            for _, ball in ipairs(ENXData.Balls:GetChildren()) do
                local st = ENXData.Parry[ball]
                if st and not st.Parried then
                    st.Parried = true
                    st.LastParry = tick()
                end
            end
            ENXData.Global.AutoParryParried = true
        end
        return OriginalFireParry(...)
    end

    local hitSounds = {
        ["UwU"] = "rbxassetid://4612696038",
        ["Medal"] = "rbxassetid://3251785210",
        ["Piu"] = "rbxassetid://5152762925",
        ["Keyboard"] = "rbxassetid://3781186340",
        ["Pop"] = "rbxassetid://4919655462",
        ["Ding"] = "rbxassetid://4590657391",
    }
    local currentHitSound = "UwU"

    local function PlayHitSound()
        if not ParryBoost.HitSound then return end
        pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = hitSounds[currentHitSound] or hitSounds["UwU"]
            s.Volume = 0.5
            s.Parent = game:GetService("SoundService")
            s:Play()
            Debris:AddItem(s, 2)
        end)
    end

    ParryBoostSection:AddToggle({
        Name = 'Enable Parry Boost',
        Default = ParryBoost.Enabled,
        Callback = function(value)
            ParryBoost.Enabled = value
            getgenv()._ENX_BoostEngine = value
            ENXNotify.new('EclipseNexus', value and 'Parry Boost ON' or 'Parry Boost OFF', 3)
        end,
    })

    ParryBoostSection:AddSlider({
        Name = 'Pre-Click Multiplier',
        Min = 10, Max = 20, Round = 1,
        Default = 13, Type = "x",
        Callback = function(value)
            ParryBoost.PreClick = value / 10
            getgenv()._ENX_BoostPreClick = value / 10
        end,
    })

    ParryBoostSection:AddDropdown({
        Name = 'Parry Mode',
        Default = ParryBoost.Mode,
        Values = {"Distance", "Time"},
        Callback = function(value) ParryBoost.Mode = value; getgenv()._ENX_BoostMode = value end,
    })

    ParryBoostSection:AddSlider({
        Name = 'Distance Timing',
        Min = 50, Max = 150, Round = 0,
        Default = 100, Type = "%",
        Callback = function(value) ParryBoost.Timing = value; getgenv()._ENX_BoostTiming = value end,
    })

    ParryBoostSection:AddSlider({
        Name = 'Time Mode Window',
        Min = 10, Max = 50, Round = 2,
        Default = 30, Type = " s",
        Callback = function(value) ParryBoost.TargetTime = value / 100; getgenv()._ENX_BoostWindow = value / 100 end,
    })

    ParryBoostSection:AddToggle({
        Name = 'Hit Sound',
        Default = ParryBoost.HitSound,
        Callback = function(value) ParryBoost.HitSound = value end,
    })

    ParryBoostSection:AddDropdown({
        Name = 'Hit Sound Type',
        Default = currentHitSound,
        Values = {"UwU", "Medal", "Piu", "Keyboard", "Pop", "Ding"},
        Callback = function(value) currentHitSound = value end,
    })

    ParryBoostSection:AddLabel("With the Auto Parry Parry Boost toggle ON, Distance Timing scales the live parry reach and Parry Mode Time gates it by the Time Mode Window.")
    ParryBoostSection:AddLabel("0.4s global lock prevents ALL double-firing.")
    ParryBoostSection:AddLabel("Ping cached every 0.5s for performance.")

    local cachedPingMs = 80
    local lastPingUpdate = 0
    local function GetPingMs()
        if tick() - lastPingUpdate > 0.5 then
            pcall(function()
                cachedPingMs = Stats.Network.ServerStatsItem['Data Ping']:GetValue()
            end)
            lastPingUpdate = tick()
        end
        return cachedPingMs
    end

    local function GetEmergencyDistance(speed)
        return math.clamp(8 + (speed * 0.09), 10, 75)
    end

    local frameCount = 0
    ENXUI:Track(RunService.Stepped:Connect(function()
        if not ParryBoost.Enabled then return end
        if not ENXData.Config.AutoParry.Enabled then return end
        if ENXData.Config.AutoSpamParry.Spamming or ENXData.Config.ManualSpamParry.Spamming then return end
        if ENXData.Config.TriggerBot.Enabled then return end

        frameCount = frameCount + 1
        if frameCount % 2 ~= 0 then return end

        if not CanFire() then return end

        local char = GetCharacter()
        if not char or not char.PrimaryPart then return end
        local playerPos = char.PrimaryPart.Position

        local pingMs = GetPingMs()
        local pingSeconds = pingMs / 1000
        local pingFactor = math.clamp(pingMs * 0.01, 1, 20)

        local now = tick()

        for _, ball in ipairs(ENXData.Balls:GetChildren()) do
            if not ball:GetAttribute("realBall") then continue end

            local ballState = ENXData.Parry[ball]
            if not ballState then continue end
            if ballState.Parried then continue end

            local ball_target = ball:GetAttribute('target')
            if ball_target ~= tostring(ENXData.Player.LocalPlayer) then continue end

            local zoomies = ball:FindFirstChild('zoomies')
            if not zoomies then continue end

            local vel = zoomies.VectorVelocity
            local speed = vel.Magnitude
            if speed < 1 then continue end

            local ballPos = ball.Position
            local diff = playerPos - ballPos
        local distSq = diff.X*diff.X + diff.Y*diff.Y + diff.Z*diff.Z
        if distSq < 1 then continue end
        local dist = math.sqrt(distSq)

        local approachSpeed = (diff.X*vel.X + diff.Y*vel.Y + diff.Z*vel.Z) / dist
        if approachSpeed <= 0 then continue end

        local ballDir = vel.Unit
        local toPlayerDir = diff.Unit
        local dotProduct = ballDir:Dot(toPlayerDir)

        local reachTime = dist / math.max(speed, 1)

        local shouldFire = false

        if ParryBoost.Mode == "Distance" then
            local emergencyDist = GetEmergencyDistance(speed)
            local userScale = ParryBoost.Timing / 100
            local baseThreshold = (10 + speed * 0.14) * userScale
            local pingOffset = pingSeconds * speed
            local calculatedThreshold = baseThreshold + pingOffset
            local maxAllowedDist = math.max(emergencyDist + 6, speed * (pingSeconds + 0.38))
            local finalThreshold = math.min(calculatedThreshold, maxAllowedDist)

            finalThreshold = finalThreshold * ParryBoost.PreClick

            if dist <= emergencyDist * ParryBoost.PreClick then
                shouldFire = true
            elseif dist <= finalThreshold and dotProduct > -0.15 and reachTime <= 0.45 then
                shouldFire = true
            end
        else
            local triggerTime = ParryBoost.TargetTime + pingSeconds
            if reachTime <= triggerTime and dotProduct > -0.25 then
                if reachTime <= triggerTime * ParryBoost.PreClick then
                    shouldFire = true
                end
            end
        end

        if shouldFire then
            MarkFired()
            ballState.Parried = true
            ballState.LastParry = now
            ENXData.Global.AutoParryParried = true

            PlayHitSound()

            task.spawn(function()
                pcall(OriginalFireParry)
            end)

            local thisBall = ball
            task.spawn(function()
                local done = false
                task.delay(1.5, function()
                    if not done then
                        done = true
                        local st = ENXData.Parry[thisBall]
                        if st then st.Parried = false end
                    end
                end)
                pcall(function()
                    thisBall:GetAttributeChangedSignal("target"):Wait()
                end)
                done = true
                local st = ENXData.Parry[thisBall]
                if st then st.Parried = false end
            end)

            break
        end
    end
    end))
end

do
    local SpamBoostTab = getgenv()._ENX_Tabs.SpamBoost

    local BurstSection = SpamBoostTab:AddSection({
        Name = "Burst Settings",
        Position = "left"
    })

    local SpamBoost = {
        TriggerbotBurst = true,
        TriggerbotCount = 4,
        ManualSpamBurst = true,
        ManualSpamCount = 4,
        ManualSpamSpeed = 0.015,
        AutoSpamBurst = true,
        AutoSpamCount = 4,
    }

    BurstSection:AddToggle({
        Name = 'Triggerbot Burst (no cooldown)',
        Default = SpamBoost.TriggerbotBurst,
        Callback = function(value) SpamBoost.TriggerbotBurst = value end,
    })

    BurstSection:AddSlider({
        Name = 'Triggerbot Burst Count',
        Min = 2, Max = 20, Round = 0,
        Default = SpamBoost.TriggerbotCount, Type = "x",
        Callback = function(value) SpamBoost.TriggerbotCount = value end,
    })

    BurstSection:AddDivider({ Color = Color3.fromRGB(50, 50, 50), Height = 1 })

    BurstSection:AddToggle({
        Name = 'Manual Spam Burst (fast)',
        Default = SpamBoost.ManualSpamBurst,
        Callback = function(value) SpamBoost.ManualSpamBurst = value end,
    })

    BurstSection:AddSlider({
        Name = 'Manual Spam Burst Count',
        Min = 2, Max = 20, Round = 0,
        Default = SpamBoost.ManualSpamCount, Type = "x",
        Callback = function(value) SpamBoost.ManualSpamCount = value end,
    })

    BurstSection:AddSlider({
        Name = 'Manual Spam Speed',
        Min = 0, Max = 50, Round = 2,
        Default = 15, Type = " ms",
        Callback = function(value) SpamBoost.ManualSpamSpeed = value / 1000 end,
    })

    BurstSection:AddDivider({ Color = Color3.fromRGB(50, 50, 50), Height = 1 })

    BurstSection:AddToggle({
        Name = 'Auto Spam Burst',
        Default = SpamBoost.AutoSpamBurst,
        Callback = function(value) SpamBoost.AutoSpamBurst = value end,
    })

    BurstSection:AddSlider({
        Name = 'Auto Spam Burst Count',
        Min = 2, Max = 20, Round = 0,
        Default = SpamBoost.AutoSpamCount, Type = "x",
        Callback = function(value) SpamBoost.AutoSpamCount = value end,
    })

    local InfoSection = SpamBoostTab:AddSection({ Name = "How It Works", Position = "right" })
    InfoSection:AddLabel("Triggerbot: removes 0.12s cooldown, fires Nx per frame")
    InfoSection:AddLabel("Manual Spam: 0.015s interval (66/sec) + Nx burst")
    InfoSection:AddLabel("Auto Spam: Nx burst on top of the spam loop")
    InfoSection:AddLabel("")
    InfoSection:AddLabel("Drives the parry hook directly.")
    InfoSection:AddLabel("No 0.4s lock — pure spam for clash mode.")

    local function FireSpamParry()
        local cam = workspace.CurrentCamera
        local mouse = UserInputService:GetMouseLocation()
        local screenPositions = {}
        local alive = workspace:FindFirstChild('Alive')
        if alive then
            for _, entity in pairs(alive:GetChildren()) do
                if entity.PrimaryPart then
                    local s, sp = pcall(function() return cam:WorldToScreenPoint(entity.PrimaryPart.Position) end)
                    if s then screenPositions[entity.Name] = sp end
                end
            end
        end
        _PARRY_PATCH.fire(cam.CFrame, screenPositions, {mouse.X, mouse.Y})
    end
end

do
    local function ResetBallSpeedPeak()
        if getgenv()._ENX_BallSpeedPeak ~= nil then
            getgenv()._ENX_BallSpeedPeak = 0
        end
        if getgenv()._ENX_BallSpeedUI_Ref and getgenv()._ENX_BallSpeedUI_Ref.PeakLabel then
            getgenv()._ENX_BallSpeedUI_Ref.PeakLabel.Text = "Peak: 0.0"
        end
    end

    ENXUI:Track(ENXData.Balls.ChildRemoved:Connect(function(child)
        ResetBallSpeedPeak()
    end))

    ENXUI:Track(ENXData.Player.LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        ResetBallSpeedPeak()
    end))
end


do
    local BlatantTab = getgenv()._ENX_Tabs.Blatant

    local InfiniteJumpSection = BlatantTab:AddSection({
        Name = "Movement",
        Position = "left"
    })

    local infinite_jump_enabled = false
    InfiniteJumpSection:AddToggle({
        Name = "Infinite Jump",
        Default = false,
        Callback = function(state)
            infinite_jump_enabled = state
            if state then
                if not getgenv().InfiniteJumpConnection then
                    getgenv().InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                        if infinite_jump_enabled then
                            local char = Players.LocalPlayer and Players.LocalPlayer.Character
                            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                        end
                    end)
                end
            else
                if getgenv().InfiniteJumpConnection then
                    getgenv().InfiniteJumpConnection:Disconnect()
                    getgenv().InfiniteJumpConnection = nil
                end
            end
            ENXNotify.new("EclipseNexus", state and "Infinite Jump ON" or "Infinite Jump OFF", 3)
        end,
    })

    local CameraSection = BlatantTab:AddSection({
        Name = "Camera",
        Position = "left"
    })

    local FOVState = { enabled = false, fov = 70 }

    local function FOVApply(enabled, value)
        FOVState.enabled = enabled
        if not value then
            value = FOVState.fov
        end
        FOVState.fov = value
        local camera = workspace.CurrentCamera
        if camera then
            camera.FieldOfView = enabled and FOVState.fov or 70
        end
    end

    CameraSection:AddToggle({
        Name = "Field of View",
        Default = false,
        Callback = function(state)
            FOVApply(state, nil)
            ENXNotify.new("EclipseNexus", state and "Field of View ON" or "Field of View OFF", 3)
        end,
    })

    CameraSection:AddSlider({
        Name = "FOV",
        Min = 40,
        Max = 120,
        Default = 70,
        Round = 0,
        Callback = function(value)
            FOVState.fov = value
            if FOVState.enabled then
                local camera = workspace.CurrentCamera
                if camera then
                    camera.FieldOfView = value
                end
            end
        end,
    })

    local FollowSection = BlatantTab:AddSection({
        Name = "Player Follow",
        Position = "left"
    })

    getgenv().PlayerFollowEnabled = getgenv().PlayerFollowEnabled or false
    getgenv().PlayerFollowMode = getgenv().PlayerFollowMode or 'Walk'
    getgenv().PlayerFollowTPDistance = getgenv().PlayerFollowTPDistance or 4
    getgenv().PlayerFollowTPInterval = getgenv().PlayerFollowTPInterval or 0.15
    getgenv().PlayerFollowWalkDistance = getgenv().PlayerFollowWalkDistance or 6

    local SelectedPlayerFollow = nil
    local followDropdown = nil

    local function getPlayerNames()
        local names = {}
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= Players.LocalPlayer then
                table.insert(names, pl.Name)
            end
        end
        table.sort(names)
        return names
    end

    local function updateFollowTarget()
        local availablePlayers = getPlayerNames()
        if #availablePlayers > 0 then
            SelectedPlayerFollow = availablePlayers[1]
            if followDropdown then
                pcall(function() followDropdown:SetValue(SelectedPlayerFollow) end)
            end
        else
            SelectedPlayerFollow = nil
        end
    end

    FollowSection:AddToggle({
        Name = "Player Follow",
        Default = false,
        Callback = function(value)
            if value then
                getgenv().PlayerFollowEnabled = true
                if getgenv().PlayerFollowConnection then
                    getgenv().PlayerFollowConnection:Disconnect()
                    getgenv().PlayerFollowConnection = nil
                end
                local teleportAccumulator = 0
                getgenv().PlayerFollowConnection = RunService.Heartbeat:Connect(function(deltaTime)
                    if not getgenv().PlayerFollowEnabled or not SelectedPlayerFollow then
                        return
                    end
                    local targetPlayer = Players:FindFirstChild(SelectedPlayerFollow)
                    local targetCharacter = targetPlayer and targetPlayer.Character
                    local targetRoot = targetCharacter and (targetCharacter:FindFirstChild('HumanoidRootPart') or targetCharacter.PrimaryPart)
                    local character = Players.LocalPlayer.Character
                    local localRoot = character and (character:FindFirstChild('HumanoidRootPart') or character.PrimaryPart)
                    local humanoid = character and character:FindFirstChildOfClass('Humanoid')
                    if not targetRoot or not character or not localRoot then
                        return
                    end
                    if getgenv().PlayerFollowMode == "Teleport" then
                        teleportAccumulator += deltaTime
                        local interval = math.clamp(tonumber(getgenv().PlayerFollowTPInterval) or 0.15, 0.05, 1)
                        if teleportAccumulator < interval then
                            return
                        end
                        teleportAccumulator = 0
                        local followDistance = math.clamp(tonumber(getgenv().PlayerFollowTPDistance) or 4, 2, 15)
                        local destination = targetRoot.CFrame * CFrame.new(0, 0, followDistance)
                        if humanoid then
                            humanoid:Move(Vector3.zero, false)
                        end
                        pcall(function()
                            character:PivotTo(destination)
                        end)
                    else
                        teleportAccumulator = 0
                        if humanoid then
                            local walkDistance = math.clamp(tonumber(getgenv().PlayerFollowWalkDistance) or 6, 2, 25)
                            local currentDistance = (localRoot.Position - targetRoot.Position).Magnitude
                            local walkDestination = (targetRoot.CFrame * CFrame.new(0, 0, walkDistance)).Position
                            if currentDistance > walkDistance + 1 then
                                humanoid:MoveTo(walkDestination)
                            else
                                humanoid:Move(Vector3.zero, false)
                            end
                        end
                    end
                end)
            else
                getgenv().PlayerFollowEnabled = false
                if getgenv().PlayerFollowConnection then
                    getgenv().PlayerFollowConnection:Disconnect()
                    getgenv().PlayerFollowConnection = nil
                end
            end
            ENXNotify.new("EclipseNexus", value and "Follow ON" or "Follow OFF", 3)
        end,
    })

    followDropdown = FollowSection:AddDropdown({
        Name = "Follow Target",
        Values = getPlayerNames(),
        Default = "",
        Callback = function(value)
            if value then
                SelectedPlayerFollow = value
            end
        end,
    })

    local initialFollowOptions = getPlayerNames()
    if #initialFollowOptions > 0 then
        SelectedPlayerFollow = initialFollowOptions[1]
        if followDropdown then
            pcall(function() followDropdown:SetValue(SelectedPlayerFollow) end)
        end
    end

    FollowSection:AddDropdown({
        Name = "Follow Mode",
        Values = {"Walk", "Teleport"},
        Default = getgenv().PlayerFollowMode,
        Callback = function(value)
            if value == 'Walk' or value == 'Teleport' then
                getgenv().PlayerFollowMode = value
            end
        end,
    })

    FollowSection:AddSlider({
        Name = "Walk Distance",
        Min = 2, Max = 25, Round = 0,
        Default = 6, Type = " studs",
        Callback = function(value)
            getgenv().PlayerFollowWalkDistance = math.clamp(tonumber(value) or 6, 2, 25)
        end,
    })

    FollowSection:AddSlider({
        Name = "Teleport Distance",
        Min = 2, Max = 15, Round = 0,
        Default = 4, Type = " studs",
        Callback = function(value)
            getgenv().PlayerFollowTPDistance = math.clamp(tonumber(value) or 4, 2, 15)
        end,
    })

    FollowSection:AddSlider({
        Name = "Teleport Interval (s)",
        Min = 0.05, Max = 1, Round = 2,
        Default = 0.15, Type = "",
        Callback = function(value)
            getgenv().PlayerFollowTPInterval = math.clamp(tonumber(value) or 0.15, 0.05, 1)
        end,
    })

    local lastFollowOptions = table.concat(getPlayerNames(), ',')
    local followUpdateTimer = 0
    getgenv().PlayerFollowRefreshConnection = RunService.Heartbeat:Connect(function(dt)
        followUpdateTimer = followUpdateTimer + dt
        if followUpdateTimer < 10 then return end
        followUpdateTimer = 0
        local newOptions = getPlayerNames()
        local newOptionsString = table.concat(newOptions, ',')
        if newOptionsString ~= lastFollowOptions then
            lastFollowOptions = newOptionsString
            if followDropdown then
                if #newOptions > 0 then
                    pcall(function() followDropdown:SetValues(newOptions) end)
                    if not table.find(newOptions, SelectedPlayerFollow) then
                        SelectedPlayerFollow = newOptions[1]
                        pcall(function() followDropdown:SetValue(SelectedPlayerFollow) end)
                    end
                else
                    SelectedPlayerFollow = nil
                end
            end
        end
    end)

    local CosmeticsSection = BlatantTab:AddSection({
        Name = "Cosmetics",
        Position = "right"
    })

    local CosmeticsCleanup = { headTransparency = nil, faceDecalId = nil, faceDecalName = nil }
    _G.PlayerCosmeticsCleanup = CosmeticsCleanup

    local function applyKorblox(character)
        if not character then return end
        local leg = character:FindFirstChild("Right Leg") or character:FindFirstChild('RightLeg')
        if not leg then return end
        if leg:FindFirstChild("KorbloxMesh") then return end
        for _, child in ipairs(leg:GetChildren()) do
            if child:IsA('SpecialMesh') then child:Destroy() end
        end
        local mesh = Instance.new('SpecialMesh')
        mesh.Name = "KorbloxMesh"
        mesh.MeshId = 'rbxassetid://902942096'
        mesh.TextureId = 'rbxassetid://902843398'
        mesh.Offset = Vector3.new(0, 0.7, 0)
        mesh.Parent = leg
    end

    local function restoreKorblox(character)
        if not character then return end
        local leg = character:FindFirstChild("Right Leg") or character:FindFirstChild('RightLeg')
        if not leg then return end
        for _, child in ipairs(leg:GetChildren()) do
            if child:IsA('SpecialMesh') and child.Name == "KorbloxMesh" then
                child:Destroy()
            end
        end
    end

    local function applyHeadless(character)
        if not character then return end
        local head = character:FindFirstChild('Head')
        if not head then return end
        if CosmeticsCleanup.headTransparency == nil then
            CosmeticsCleanup.headTransparency = head.Transparency
        end
        local face = head:FindFirstChildOfClass('Decal')
        if face then
            CosmeticsCleanup.faceDecalId = face.Texture
            CosmeticsCleanup.faceDecalName = face.Name
        end
        head.Transparency = 1
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA('Decal') or child.Name == "face" then
                child.Transparency = 1
            elseif child:IsA('SpecialMesh') or child:IsA('DataModelMesh') then
                if not child:GetAttribute("OriginalScale") then
                    child:SetAttribute("OriginalScale", child.Scale)
                    child.Scale = Vector3.new(0, 0, 0)
                end
            end
        end
    end

    local function restoreHeadless(character)
        if not character then return end
        local head = character:FindFirstChild('Head')
        if not head then return end
        if CosmeticsCleanup.headTransparency ~= nil then
            head.Transparency = CosmeticsCleanup.headTransparency
        end
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA('Decal') or child.Name == "face" then
                child.Transparency = 0
                if CosmeticsCleanup.faceDecalId and CosmeticsCleanup.faceDecalName == child.Name then
                    child.Texture = CosmeticsCleanup.faceDecalId
                end
            elseif child:IsA('SpecialMesh') or child:IsA('DataModelMesh') then
                local orig = child:GetAttribute("OriginalScale")
                if orig then child.Scale = orig end
            end
        end
    end

    CosmeticsSection:AddToggle({
        Name = "Korblox",
        Default = false,
        Callback = function(value)
            getgenv().HeadlessKorbloxEnabled = value
            local lp = Players.LocalPlayer
            if value then
                if lp.Character then applyKorblox(lp.Character) end
                if not getgenv().KorbloxCharConn then
                    getgenv().KorbloxCharConn = lp.CharacterAdded:Connect(function(c)
                        task.wait(0.5)
                        if getgenv().HeadlessKorbloxEnabled then applyKorblox(c) end
                    end)
                end
            else
                if lp.Character then restoreKorblox(lp.Character) end
                if getgenv().KorbloxCharConn then
                    getgenv().KorbloxCharConn:Disconnect()
                    getgenv().KorbloxCharConn = nil
                end
            end
            ENXNotify.new("EclipseNexus", value and "Korblox ON" or "Korblox OFF", 3)
        end,
    })

    CosmeticsSection:AddToggle({
        Name = "Headless",
        Default = false,
        Callback = function(value)
            getgenv().HeadlessEnabled = value
            local lp = Players.LocalPlayer
            if value then
                if lp.Character then applyHeadless(lp.Character) end
                if not getgenv().HeadlessCharConn then
                    getgenv().HeadlessCharConn = lp.CharacterAdded:Connect(function(c)
                        task.wait(0.5)
                        if getgenv().HeadlessEnabled then applyHeadless(c) end
                    end)
                end
            else
                if lp.Character then restoreHeadless(lp.Character) end
                if getgenv().HeadlessCharConn then
                    getgenv().HeadlessCharConn:Disconnect()
                    getgenv().HeadlessCharConn = nil
                end
            end
            ENXNotify.new("EclipseNexus", value and "Headless ON" or "Headless OFF", 3)
        end,
    })

    local AbilitySection = BlatantTab:AddSection({
        Name = "Abilities",
        Position = "right"
    })

    local thunder_dash_exploit_connection = nil
    getgenv().AbilityExploit = false
    getgenv().ThunderDashNoCooldown = false

    local function apply_thunder_dash_exploit()
        if not getgenv().AbilityExploit or not getgenv().ThunderDashNoCooldown then return end
        local shared = ReplicatedStorage:FindFirstChild('Shared')
        local abilities = shared and shared:FindFirstChild("Abilities")
        local thunderDashModule = abilities and abilities:FindFirstChild("Thunder Dash")
        if not thunderDashModule then return end
        local ok, mod = pcall(require, thunderDashModule)
        if ok and mod then
            pcall(function()
                mod.cooldown = 0
                mod.cooldownReductionPerUpgrade = 0
            end)
        end
    end

    local function start_thunder_dash_exploit()
        if thunder_dash_exploit_connection then return end
        thunder_dash_exploit_connection = RunService.Heartbeat:Connect(function()
            if getgenv().AbilityExploit and getgenv().ThunderDashNoCooldown then
                apply_thunder_dash_exploit()
            end
        end)
    end

    local function stop_thunder_dash_exploit()
        if thunder_dash_exploit_connection then
            thunder_dash_exploit_connection:Disconnect()
            thunder_dash_exploit_connection = nil
        end
    end

    local super_jump_exploit_connection = nil
    getgenv().SuperJumpNoCooldown = false

    local function apply_super_jump_exploit()
        if not getgenv().AbilityExploit or not getgenv().SuperJumpNoCooldown then return end
        local shared = ReplicatedStorage:FindFirstChild('Shared')
        local abilities = shared and shared:FindFirstChild("Abilities")
        local superJumpModule = abilities and abilities:FindFirstChild("Super Jump")
        if not superJumpModule then return end
        local ok, mod = pcall(require, superJumpModule)
        if ok and mod then
            pcall(function()
                mod.cooldown = 0
                mod.cooldownReductionPerUpgrade = 0
            end)
        end
    end

    local function start_super_jump_exploit()
        if super_jump_exploit_connection then return end
        super_jump_exploit_connection = RunService.Heartbeat:Connect(function()
            if getgenv().AbilityExploit and getgenv().SuperJumpNoCooldown then
                apply_super_jump_exploit()
            end
        end)
    end

    local function stop_super_jump_exploit()
        if super_jump_exploit_connection then
            super_jump_exploit_connection:Disconnect()
            super_jump_exploit_connection = nil
        end
    end

    local dash_exploit_connection = nil
    getgenv().DashNoCooldown = false

    local function apply_dash_exploit()
        if not getgenv().AbilityExploit or not getgenv().DashNoCooldown then return end
        local shared = ReplicatedStorage:FindFirstChild('Shared')
        local abilities = shared and shared:FindFirstChild("Abilities")
        local dashModule = abilities and abilities:FindFirstChild("Dash")
        if not dashModule then return end
        local ok, mod = pcall(require, dashModule)
        if ok and mod then
            pcall(function()
                mod.cooldown = 0
                mod.cooldownReductionPerUpgrade = 0
            end)
        end
    end

    local function start_dash_exploit()
        if dash_exploit_connection then return end
        dash_exploit_connection = RunService.Heartbeat:Connect(function()
            if getgenv().AbilityExploit and getgenv().DashNoCooldown then
                apply_dash_exploit()
            end
        end)
    end

    local function stop_dash_exploit()
        if dash_exploit_connection then
            dash_exploit_connection:Disconnect()
            dash_exploit_connection = nil
        end
    end

    AbilitySection:AddToggle({
        Name = "Ability Exploit",
        Default = false,
        Callback = function(value)
            getgenv().AbilityExploit = value
            if value and getgenv().ThunderDashNoCooldown then
                apply_thunder_dash_exploit()
                start_thunder_dash_exploit()
            else
                stop_thunder_dash_exploit()
            end
            if value and getgenv().SuperJumpNoCooldown then
                apply_super_jump_exploit()
                start_super_jump_exploit()
            else
                stop_super_jump_exploit()
            end
            if value and getgenv().DashNoCooldown then
                apply_dash_exploit()
                start_dash_exploit()
            else
                stop_dash_exploit()
            end
            ENXNotify.new("EclipseNexus", value and "Ability Exploit ON" or "Ability Exploit OFF", 3)
        end,
    })

    AbilitySection:AddToggle({
        Name = "Thunder Dash No Cooldown",
        Default = false,
        Callback = function(value)
            getgenv().ThunderDashNoCooldown = value
            if value and getgenv().AbilityExploit then
                apply_thunder_dash_exploit()
                start_thunder_dash_exploit()
            else
                stop_thunder_dash_exploit()
            end
            ENXNotify.new("EclipseNexus", value and "Thunder Dash NoCD ON" or "Thunder Dash NoCD OFF", 3)
        end,
    })

    AbilitySection:AddToggle({
        Name = "Super Jump No Cooldown",
        Default = false,
        Callback = function(value)
            getgenv().SuperJumpNoCooldown = value
            if value and getgenv().AbilityExploit then
                apply_super_jump_exploit()
                start_super_jump_exploit()
            else
                stop_super_jump_exploit()
            end
            ENXNotify.new("EclipseNexus", value and "Super Jump NoCD ON" or "Super Jump NoCD OFF", 3)
        end,
    })

    AbilitySection:AddToggle({
        Name = "Dash No Cooldown",
        Default = false,
        Callback = function(value)
            getgenv().DashNoCooldown = value
            if value and getgenv().AbilityExploit then
                apply_dash_exploit()
                start_dash_exploit()
            else
                stop_dash_exploit()
            end
            ENXNotify.new("EclipseNexus", value and "Dash NoCD ON" or "Dash NoCD OFF", 3)
        end,
    })

    AbilitySection:AddToggle({
        Name = "Cooldown Protection",
        Default = false,
        Callback = function(value)
            getgenv().CooldownProtection = value
            ENXNotify.new("EclipseNexus", value and "Cooldown Protect ON" or "Cooldown Protect OFF", 3)
        end,
    })
    AbilitySection:AddLabel("Cooldown Protection auto-presses Ability button")
    AbilitySection:AddLabel("when your parry is on cooldown (0.4s threshold).")

    local TargetLockSection = BlatantTab:AddSection({
        Name = "Target Lock",
        Position = "left"
    })

    getgenv().TargetLockEnabled = false
    getgenv().TargetLockAutoSwitch = false
    getgenv().TargetLockHighlight = false
    getgenv().TargetLockPlayerName = nil
    getgenv()._ZX_TargetLockPlayerMap = {}
    getgenv()._ZX_TargetLockLabelByPlayer = {}

    getgenv()._ZX_GetTargetLockCharacter = function()
        local playerName = getgenv().TargetLockPlayerName
        if type(playerName) ~= "string" or playerName == "" then return nil end
        local player = Players:FindFirstChild(playerName)
        if not player or player == Players.LocalPlayer then return nil end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not character or not humanoid or humanoid.Health <= 0 then return nil end
        local aliveFolder = workspace:FindFirstChild("Alive")
        if aliveFolder and character.Parent ~= aliveFolder then return nil end
        return character
    end

    getgenv()._ZX_SelectTargetLockFallback = function()
        local localCharacter = Players.LocalPlayer.Character
        local localRoot = localCharacter and (localCharacter:FindFirstChild("HumanoidRootPart") or localCharacter.PrimaryPart)
        local aliveFolder = workspace:FindFirstChild("Alive")
        local bestPlayer = nil
        local bestDistance = math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
                if humanoid and humanoid.Health > 0 and root and (not aliveFolder or character.Parent == aliveFolder) then
                    local distance = localRoot and (localRoot.Position - root.Position).Magnitude or 0
                    if distance < bestDistance then
                        bestDistance = distance
                        bestPlayer = player
                    end
                end
            end
        end
        if not bestPlayer then
            getgenv().TargetLockPlayerName = nil
            return nil
        end
        getgenv().TargetLockPlayerName = bestPlayer.Name
        local label = getgenv()._ZX_TargetLockLabelByPlayer[bestPlayer.Name]
        if not label then
            local playerOptions, playerMap, labelByPlayer = {}, {}, {}
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer then
                    local label2 = "@" .. tostring(player.DisplayName) .. " (" .. player.Name .. ")"
                    table.insert(playerOptions, label2)
                    playerMap[label2] = player.Name
                    labelByPlayer[player.Name] = label2
                end
            end
            table.sort(playerOptions)
            getgenv()._ZX_TargetLockPlayerMap = playerMap
            getgenv()._ZX_TargetLockLabelByPlayer = labelByPlayer
            label = labelByPlayer[bestPlayer.Name]
            if getgenv()._ZX_TargetLockDropdown and getgenv()._ZX_TargetLockDropdown.SetValues then
                pcall(function() getgenv()._ZX_TargetLockDropdown:SetValues(playerOptions) end)
            end
        end
        if label and getgenv()._ZX_TargetLockDropdown then
            pcall(function() getgenv()._ZX_TargetLockDropdown:SetValue(label) end)
        end
        return bestPlayer.Character
    end

    getgenv()._ZX_ClearTargetLockHighlight = function()
        if getgenv()._ZX_TargetLockHighlightInstance then
            pcall(function() getgenv()._ZX_TargetLockHighlightInstance:Destroy() end)
            getgenv()._ZX_TargetLockHighlightInstance = nil
        end
    end

    getgenv()._ZX_UpdateTargetLockHighlight = function()
        if not getgenv().TargetLockEnabled or not getgenv().TargetLockHighlight then
            getgenv()._ZX_ClearTargetLockHighlight()
            return
        end
        local character = getgenv()._ZX_GetTargetLockCharacter()
        if not character then
            getgenv()._ZX_ClearTargetLockHighlight()
            return
        end
        local highlight = getgenv()._ZX_TargetLockHighlightInstance
        if not highlight or not highlight.Parent then
            highlight = Instance.new("Highlight")
            highlight.Name = "EclipseNexus_TargetLockHighlight"
            getgenv()._ZX_TargetLockHighlightInstance = highlight
        end
        local pulse = (math.sin(os.clock() * 5) + 1) * 0.5
        highlight.Enabled = true
        highlight.FillColor = Color3.fromRGB(255, 35, 55)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.10 + pulse * 0.12
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = character
        highlight.Parent = character
    end

    local function targetLockBuildOptions()
        local playerOptions, playerMap, labelByPlayer = {}, {}, {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                local label = "@" .. tostring(player.DisplayName) .. " (" .. player.Name .. ")"
                table.insert(playerOptions, label)
                playerMap[label] = player.Name
                labelByPlayer[player.Name] = label
            end
        end
        table.sort(playerOptions)
        if #playerOptions == 0 then
            playerOptions[1] = "No Players Online"
        end
        getgenv()._ZX_TargetLockPlayerMap = playerMap
        getgenv()._ZX_TargetLockLabelByPlayer = labelByPlayer
        return playerOptions
    end

    TargetLockSection:AddToggle({
        Name = "Target Lock",
        Default = false,
        Callback = function(value)
            getgenv().TargetLockEnabled = value
            if value and getgenv().TargetLockAutoSwitch and not getgenv()._ZX_GetTargetLockCharacter() then
                getgenv()._ZX_SelectTargetLockFallback()
            end
            getgenv()._ZX_UpdateTargetLockHighlight()
            ENXNotify.new("EclipseNexus", value and "Target Lock ON" or "Target Lock OFF", 3)
        end,
    })

    local targetLockDropdown = TargetLockSection:AddDropdown({
        Name = "Target Player",
        Values = targetLockBuildOptions(),
        Default = "",
        Callback = function(value)
            local label = typeof(value) == "string" and value or (value and value.Name)
            local playerName = label and getgenv()._ZX_TargetLockPlayerMap[label]
            if playerName then
                getgenv().TargetLockPlayerName = playerName
            elseif label == "No Players Online" then
                getgenv().TargetLockPlayerName = nil
            end
            getgenv()._ZX_UpdateTargetLockHighlight()
        end,
    })
    getgenv()._ZX_TargetLockDropdown = targetLockDropdown

    TargetLockSection:AddToggle({
        Name = "Auto Switch",
        Default = false,
        Callback = function(value)
            getgenv().TargetLockAutoSwitch = value
            if value and getgenv().TargetLockEnabled and not getgenv()._ZX_GetTargetLockCharacter() then
                getgenv()._ZX_SelectTargetLockFallback()
            end
        end,
    })

    TargetLockSection:AddToggle({
        Name = "Target Highlight",
        Default = false,
        Callback = function(value)
            getgenv().TargetLockHighlight = value
            getgenv()._ZX_UpdateTargetLockHighlight()
        end,
    })

    TargetLockSection:AddLabel("Locks every parry onto the selected player.")
    TargetLockSection:AddLabel("Auto Switch falls back to the nearest player still in the round.")

    if getgenv()._ZX_TargetLockMonitorConnection then
        pcall(function() getgenv()._ZX_TargetLockMonitorConnection:Disconnect() end)
    end
    local monitorAccumulator = 0
    getgenv()._ZX_TargetLockMonitorConnection = RunService.Heartbeat:Connect(function(delta)
        monitorAccumulator = monitorAccumulator + delta
        if monitorAccumulator < 0.25 then return end
        monitorAccumulator = 0
        if not getgenv().TargetLockEnabled then
            getgenv()._ZX_ClearTargetLockHighlight()
            return
        end
        if getgenv().TargetLockAutoSwitch and not getgenv()._ZX_GetTargetLockCharacter() then
            getgenv()._ZX_SelectTargetLockFallback()
        end
        getgenv()._ZX_UpdateTargetLockHighlight()
    end)

    if getgenv()._ZX_TargetLockRosterConn then
        pcall(function() getgenv()._ZX_TargetLockRosterConn:Disconnect() end)
    end
    getgenv()._ZX_TargetLockRosterConn = Players.PlayerAdded:Connect(function()
        local playerOptions = targetLockBuildOptions()
        if getgenv()._ZX_TargetLockDropdown and getgenv()._ZX_TargetLockDropdown.SetValues then
            pcall(function() getgenv()._ZX_TargetLockDropdown:SetValues(playerOptions) end)
        end
    end)
    if getgenv()._ZX_TargetLockLeaveConn then
        pcall(function() getgenv()._ZX_TargetLockLeaveConn:Disconnect() end)
    end
    getgenv()._ZX_TargetLockLeaveConn = Players.PlayerRemoving:Connect(function(player)
        if player.Name == getgenv().TargetLockPlayerName then
            getgenv().TargetLockPlayerName = nil
        end
        local playerOptions = targetLockBuildOptions()
        if getgenv()._ZX_TargetLockDropdown and getgenv()._ZX_TargetLockDropdown.SetValues then
            pcall(function() getgenv()._ZX_TargetLockDropdown:SetValues(playerOptions) end)
        end
    end)

    local Connections_Manager = getgenv().Connections_Manager or {}
    getgenv().Connections_Manager = Connections_Manager

    local Player = Players.LocalPlayer

    local function get_real_ball()
        local balls = Workspace:FindFirstChild('Balls')
        if not balls then
            return nil
        end

        for _, ball in pairs(balls:GetChildren()) do
            if ball:GetAttribute("realBall") then
                ball.CanCollide = false
                return ball
            end
        end

        return nil
    end

    local AutoPlayState = {
        connection = nil,
        character_connection = nil,
        elapsed = 0,
        control_point = nil,
        last_generation = 0,
        double_jumped = false,
        ball = nil,
        floor = nil,
        enabled = false
    }

    local function auto_play_percentage_check(limit)
        if tick() - AutoPlayState.last_generation < (getgenv().AutoPlayGenerationThreshold or 0.25) then
            return false
        end

        AutoPlayState.last_generation = tick()
        return math.random((130-30)) <= limit
    end

    local function auto_play_get_floor()
        local floor = Workspace:FindFirstChild('FLOOR')
        if floor and floor:IsA('BasePart') then
            return floor
        end

        local cached = AutoPlayState.floor
        if cached and cached.Parent then
            return cached
        end

        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA('BasePart') and part.Size.X > bit32.bxor(31,45) and part.Size.Z > (121-71) and part.Position.Y < 5 then
                AutoPlayState.floor = part
                return part
            end
        end

        return nil
    end

    local function auto_play_get_curve(startPosition, finishPosition, delta)
        AutoPlayState.elapsed = AutoPlayState.elapsed + delta
        local timeElapsed = math.clamp(AutoPlayState.elapsed / (getgenv().AutoPlayMovementDuration or 0.8), 0, 1)

        if timeElapsed >= 1 then
            AutoPlayState.elapsed = 0
            AutoPlayState.control_point = nil
            return finishPosition
        end

        if not AutoPlayState.control_point then
            local middle = (startPosition + finishPosition) * 0.5
            local difference = startPosition - finishPosition
            if difference.Magnitude < 5 then
                return finishPosition
            end

            local theta = math.atan2(difference.Z, difference.X)
            local offsetLength = difference.Magnitude * (getgenv().AutoPlayOffsetFactor or 0.7)
            local firstCandidate = middle + Vector3.new(math.cos(theta + math.pi / 2), 0, math.sin(theta + math.pi / 2)) * offsetLength
            local secondCandidate = middle + Vector3.new(math.cos(theta - math.pi / 2), 0, math.sin(theta - math.pi / 2)) * offsetLength
            local dotValue = startPosition - middle
            AutoPlayState.control_point = ((firstCandidate - middle):Dot(dotValue) < 0 and firstCandidate) or secondCandidate
        end

        local firstLerp = startPosition + (AutoPlayState.control_point - startPosition) * timeElapsed
        local secondLerp = AutoPlayState.control_point + (finishPosition - AutoPlayState.control_point) * timeElapsed
        return firstLerp + (secondLerp - firstLerp) * timeElapsed
    end

    local function auto_play_get_target_position()
        local floor = auto_play_get_floor()
        local ball = get_real_ball()
        if not ball then
            ball = AutoPlayState.ball
            if not (ball and ball.Parent) then
                ball = nil
            end
            if ball then
                if not ball:GetAttribute("realBall") then
                    ball = nil
                end
            end
        end
        local character = Player.Character
        local hrp = character and character:FindFirstChild('HumanoidRootPart')

        if not floor or not ball or not hrp then
            return nil
        end

        AutoPlayState.ball = ball
        local delta = Vector3.new(hrp.Position.X - ball.Position.X, 0, hrp.Position.Z - ball.Position.Z)
        local direction = (delta.Magnitude > 0.01 and delta.Unit) or Vector3.new(0, 0, 1)
        local speed = 0
        local success, speed_value = pcall(function()
            if ball and ball:FindFirstChild("zoomies") and ball.zoomies and ball.zoomies.VectorVelocity then
                return ball.zoomies.VectorVelocity.Magnitude
            end
            return 0
        end)
        if success then
            speed = speed_value or 0
        end
        local speedThreshold = math.min(speed / (5+5), getgenv().AutoPlayMultiplierThreshold or (89-19))
        local distance = (getgenv().AutoPlayDistance or (2*15)) + speedThreshold
        local offset = direction * distance * (getgenv().AutoPlayDirection or 1)
        local currentTime = os.time() / 1.2
        local sine = math.sin(currentTime) * (getgenv().AutoPlayTransversing or (5*5))
        local cosine = math.cos(currentTime) * (getgenv().AutoPlayTransversing or (5*5))

        local traversing = Vector3.new(sine, 0, cosine)

        return Vector3.new(ball.Position.X, floor.Position.Y, ball.Position.Z) + offset + traversing
    end

    local function auto_play_step()
        if not AutoPlayState.enabled then
            return
        end

        local character = Player.Character
        local humanoid = character and character:FindFirstChildOfClass('Humanoid')
        local hrp = character and character:FindFirstChild('HumanoidRootPart')

        if not humanoid or not hrp or humanoid.Health <= 0 then
            return
        end

        if humanoid.FloorMaterial ~= Enum.Material.Air then
            AutoPlayState.double_jumped = false
        end

        local targetPosition = auto_play_get_target_position()

        if targetPosition then
            local path = auto_play_get_curve(hrp.Position, targetPosition, 0.016)
            humanoid:MoveTo(path)
        end

        if getgenv().AutoPlayJumpingEnabled and auto_play_percentage_check(getgenv().AutoPlayJumpPercentage or (2*25)) then
            if humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            elseif not AutoPlayState.double_jumped and auto_play_percentage_check(getgenv().AutoPlayDoubleJumpPercentage or (29+21)) then
                local bodyVelocity = Instance.new('BodyVelocity')
                bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bodyVelocity.Velocity = Vector3.new(0, (110-30), 0)
                bodyVelocity.Parent = hrp
                Debris:AddItem(bodyVelocity, 0.1)
                AutoPlayState.double_jumped = true
            end
        end
    end

    local function auto_play_set_enabled(state)
        AutoPlayState.enabled = state
        getgenv().AutoPlay = state

        if AutoPlayState.connection then
            AutoPlayState.connection:Disconnect()
            AutoPlayState.connection = nil
        end

        if AutoPlayState.character_connection then
            AutoPlayState.character_connection:Disconnect()
            AutoPlayState.character_connection = nil
        end

        if state then
            AutoPlayState.connection = RunService.Heartbeat:Connect(auto_play_step)
            AutoPlayState.character_connection = Player.CharacterAdded:Connect(function()
                AutoPlayState.double_jumped = false
                AutoPlayState.ball = nil
                AutoPlayState.control_point = nil
                AutoPlayState.elapsed = 0
            end)
        end
    end

    getgenv().AutoPlayDistance = getgenv().AutoPlayDistance or (89-71)
    getgenv().AutoPlayMultiplierThreshold = getgenv().AutoPlayMultiplierThreshold or (3*15)
    getgenv().AutoPlayTransversing = getgenv().AutoPlayTransversing or 8
    getgenv().AutoPlayDirection = getgenv().AutoPlayDirection or 1
    getgenv().AutoPlayOffsetFactor = getgenv().AutoPlayOffsetFactor or 0.4
    getgenv().AutoPlayMovementDuration = getgenv().AutoPlayMovementDuration or 0.8
    getgenv().AutoPlayGenerationThreshold = getgenv().AutoPlayGenerationThreshold or 0.3
    getgenv().AutoPlayJumpPercentage = getgenv().AutoPlayJumpPercentage or (2*10)
    getgenv().AutoPlayDoubleJumpPercentage = getgenv().AutoPlayDoubleJumpPercentage or (40-30)
    getgenv().AutoVote = getgenv().AutoVote or false

    local AutoPlaySection = BlatantTab:AddSection({
        Name = "Auto Play",
        Position = "right"
    })

    AutoPlaySection:AddToggle({
        Name = "Auto Play",
        Default = false,
        Callback = function(value)
            auto_play_set_enabled(value)
            ENXNotify.new("EclipseNexus", value and "Auto Play ON" or "Auto Play OFF", 3)
        end,
    })

    local AntiAFKToggle = AutoPlaySection:AddToggle({
        Name = "Anti AFK",
        Default = getgenv().AutoPlayAntiAFK == true,
        Callback = function(value)
            getgenv().AutoPlayAntiAFK = value
            ENXData.Config.AutoPlay = ENXData.Config.AutoPlay or {}
            ENXData.Config.AutoPlay.AntiAFK = value
            if Connections_Manager["AutoPlayAntiAFK"] then
                pcall(function() Connections_Manager["AutoPlayAntiAFK"]:Disconnect() end)
                Connections_Manager["AutoPlayAntiAFK"] = nil
            end
            if value then
                Connections_Manager["AutoPlayAntiAFK"] = Players.LocalPlayer.Idled:Connect(function()
                    local virtualUser = cloneref(game:GetService('VirtualUser'))
                    virtualUser:CaptureController()
                    virtualUser:ClickButton2(Vector2.new())
                end)
            end
            SaveAllSettings()
        end,
    })
    if ENXData.Config.AutoPlay and ENXData.Config.AutoPlay.AntiAFK == true then
        task.defer(function()
            pcall(function() AntiAFKToggle:SetValue(true) end)
        end)
    end

    AutoPlaySection:AddToggle({
        Name = "Enable Jumping",
        Default = false,
        Callback = function(value)
            getgenv().AutoPlayJumpingEnabled = value
        end,
    })

    AutoPlaySection:AddToggle({
        Name = "Auto Vote",
        Default = false,
        Callback = function(value)
            getgenv().AutoVote = value
        end,
    })

    AutoPlaySection:AddSlider({
        Name = "Distance From Ball",
        Min = 5,
        Max = 100,
        Round = 0,
        Default = 18,
        Type = "",
        Callback = function(value)
            getgenv().AutoPlayDistance = value
        end,
    })

    AutoPlaySection:AddSlider({
        Name = "Speed Multiplier",
        Min = 10,
        Max = 200,
        Round = 0,
        Default = 45,
        Type = "",
        Callback = function(value)
            getgenv().AutoPlayMultiplierThreshold = value
        end,
    })

    AutoPlaySection:AddSlider({
        Name = "Transversing",
        Min = 0,
        Max = 100,
        Round = 0,
        Default = 8,
        Type = "",
        Callback = function(value)
            getgenv().AutoPlayTransversing = value
        end,
    })

    AutoPlaySection:AddSlider({
        Name = "Direction",
        Min = -1,
        Max = 1,
        Round = 1,
        Default = 1,
        Type = "",
        Callback = function(value)
            getgenv().AutoPlayDirection = value
        end,
    })

    AutoPlaySection:AddSlider({
        Name = "Offset Factor",
        Min = 0.1,
        Max = 1,
        Round = 1,
        Default = 0.4,
        Type = "",
        Callback = function(value)
            getgenv().AutoPlayOffsetFactor = value
        end,
    })

    AutoPlaySection:AddSlider({
        Name = "Movement Duration",
        Min = 0.1,
        Max = 1,
        Round = 1,
        Default = 0.8,
        Type = "",
        Callback = function(value)
            getgenv().AutoPlayMovementDuration = value
        end,
    })

    AutoPlaySection:AddSlider({
        Name = "Generation Threshold",
        Min = 0.1,
        Max = 0.5,
        Round = 1,
        Default = 0.3,
        Type = "",
        Callback = function(value)
            getgenv().AutoPlayGenerationThreshold = value
        end,
    })

    AutoPlaySection:AddSlider({
        Name = "Jump Chance",
        Min = 0,
        Max = 100,
        Round = 0,
        Default = 20,
        Type = "",
        Callback = function(value)
            getgenv().AutoPlayJumpPercentage = value
        end,
    })

    AutoPlaySection:AddSlider({
        Name = "Double Jump Chance",
        Min = 0,
        Max = 100,
        Round = 0,
        Default = 10,
        Type = "",
        Callback = function(value)
            getgenv().AutoPlayDoubleJumpPercentage = value
        end,
    })

    AutoPlaySection:AddLabel("EclipseNexus engine: curved movement, speed-scaled distance to the ball, optional jump chances, anti-afk.")

end

local FASTFLAGS_BY_CATEGORY = {
    ["Blade Ball"] = {
        desc = "Blade Ball game flags: curve, spin, swing, block and parry timing as circulated for this game. Flags the client does not know are skipped by the Apply pcall and counted as skipped.",
        flags = {
            ["DFIntBladeBallMinCurveAngle"] = "360",
            ["DFFlagBladeBallAllowInstantCombo"] = "True",
            ["DFFlagBladeBallBypassSwingCooldown"] = "True",
            ["DFIntBladeBallSwordComboWindowMs"] = "9999",
            ["DFFlagBladeBallServerInstantBlockProcessing"] = "True",
            ["DFFlagBladeBallAutoPerfectBlock"] = "True",
            ["DFFlagBladeBallAdaptiveSpinCorrection"] = "False",
            ["DFIntBladeBallSwordSwingDelayMs"] = "0",
            ["DFFlagBladeBallRemoveCurveLimit"] = "True",
            ["DFIntBladeBallMaxBlockCount"] = "9999",
            ["DFIntBladeBallSpeedToCurveRatio"] = "5000",
            ["DFIntBladeBallSwordHitboxActiveTimeMs"] = "9999",
            ["DFIntBladeBallMaxCurveAngle"] = "999999",
            ["DFFlagBladeBallIgnoreCurveLimits"] = "True",
            ["DFFlagBladeBallRemoveSwordCooldown"] = "True",
            ["DFIntBladeBallSwordCooldownTimeMs"] = "0",
            ["DFFlagBladeBallUncappedSwordSwingSpeed"] = "True",
            ["DFFlagBladeBallRemoveSpinDecayCap"] = "True",
            ["FFlagBladeBallNoCurveDampening"] = "True",
            ["DFFlagBladeBallSuperchargedCurving"] = "True",
            ["DFIntBladeBallPerfectBlockBonusTimeMs"] = "999999",
            ["DFFlagBladeBallInstantBlockRecovery"] = "True",
            ["DFFlagBladeBallAdaptiveCurving"] = "True",
            ["DFIntBladeBallGravityMultiplier"] = "0",
            ["DFFlagBladeBallNoVelocityDecayWhenFrozen"] = "True",
            ["DFIntBladeBallSwordRecoveryTimeMs"] = "0",
            ["DFIntBladeBallReverseCurveMultiplier"] = "9999",
            ["DFIntBladeBallSwordAnimationSpeedMultiplier"] = "10",
            ["DFFlagBladeBallUnlimitedSwordSwings"] = "True",
            ["DFIntBladeBallAccelerationBoost"] = "9999",
            ["DFIntBladeBallMaxSpeedMultiplier"] = "10",
            ["DFIntBladeBallBaseSpinRate"] = "5000",
            ["DFFlagBladeBallInstantSwordRecovery"] = "True",
            ["DFFlagBladeBallSyncCurveWithServer"] = "True",
            ["DFIntBladeBallSpinDecayRate"] = "-1000",
            ["DFIntBladeBallSpinInfluence"] = "99999",
            ["DFIntBladeBallCurveDecayRate"] = "0",
            ["DFIntBladeBallCurvePersistence"] = "9999",
            ["DFIntBladeBallMaxSpinRate"] = "99999",
            ["DFIntBladeBallLowSpeedCurveMultiplier"] = "10",
            ["DFIntBladeBallMaxSpinSpeed"] = "999999",
            ["DFIntBladeBallCurvePersistenceTimeMs"] = "999999",
            ["DFFlagBladeBallAlwaysCurveBack"] = "True",
            ["DFFlagBladeBallInfiniteCurve"] = "True",
            ["DFFlagBladeBallCurveRetentionBoost"] = "True",
            ["DFFlagBladeBallUncappedDeflection"] = "True",
            ["DFIntBladeBallCurvedDeflectionMultiplier"] = "9999",
            ["DFFlagBladeBallIgnoreFrictionForCurving"] = "True",
            ["DFFlagBladeBallNoCurveDampening"] = "True",
            ["DFFlagBladeBallSyncCurveWithClient"] = "True",
            ["FFlagBladeBallUnrestrictedSpin"] = "True",
            ["DFIntBladeBallSwordMaxSwingSpeedMultiplier"] = "10",
            ["DFFlagBladeBallInfiniteCurveStacking"] = "True",
            ["DFFlagBladeBallEnableExtremeCurving"] = "True",
            ["DFFlagBladeBallNoCurveCap"] = "True",
            ["DFIntBladeBallSwordAutoSwingDelayMs"] = "0",
            ["DFFlagBladeBallOverclockedSpinPhysics"] = "True",
            ["DFIntBladeBallAirResistanceMultiplier"] = "0",
            ["DFIntBladeBallBlockCooldownTimeMs"] = "0",
            ["DFFlagBladeBallClientSideBlockPrediction"] = "True",
            ["DFIntBladeBallSpinToCurveRatio"] = "1000",
            ["DFIntBladeBallAutoCurveStrengthMultiplier"] = "10",
            ["DFFlagBladeBallSuperfastSwordAttacks"] = "True",
            ["DFFlagBladeBallIgnorePhysicsDrag"] = "True",
            ["DFIntBladeBallFrictionMultiplier"] = "0",
            ["DFFlagBladeBallNoBlockCooldown"] = "True",
            ["DFFlagBladeBallCurveAlwaysApplies"] = "True",
            ["DFIntBladeBallBlockInputBufferMs"] = "0",
            ["DFIntBladeBallBlockRecoveryTimeMs"] = "0",
            ["FFlagBladeBallAdaptiveSpinCorrection"] = "False",
            ["DFFlagBladeBallAllowNegativeSpinDecay"] = "True",
            ["DFIntBladeBallMaxDeflectionAngle"] = "180",
            ["DFFlagBladeBallNoBlockLag"] = "True",
            ["DFIntBladeBallSwordAttackSpeedBoost"] = "9999",
            ["DFFlagBladeBallUnlimitedBlockUses"] = "True",
            ["DFFlagBladeBallUnrestrictedSpin"] = "True",
            ["DFFlagBladeBallBlockRollbackProtection"] = "True",
            ["DFIntBladeBallCurveStrength"] = "999999",
            ["DFIntBladeBallSwordNoHitLag"] = "1",
            ["DFIntBladeBallHighSpeedCurveMultiplier"] = "20",
            ["DFIntBladeBallBlockWindowExtensionMs"] = "999999",
        },
    },
    ["FPS / Frame Rate"] = {
        desc = "Unlocks the FPS cap, raises scheduler tick rate and job limits, tightens frame-time budgets. WARNING: 9999 FPS can overheat some machines; 240 is safer.",
        flags = {
            ["DFFlagGraphicsOptimizationModeMVPExposureEnrollment3"] = "False",
            ["TaskSchedulerLimitTargetFpsTo2402"] = "False",
            ["TaskSchedulerTargetFps"] = "9999",
            ["FFlagDebugDisplayFPS"] = "True",
            ["DFIntRuntimeConcurrency"] = "2139999999",
            ["FIntTaskSchedulerMaxNumOfJobs"] = "2139999999",
            ["FIntRuntimeMaxNumOfConditions"] = "20000",
            ["DFFlagDebugPerfMode"] = "True",
            ["DFIntMicroProfilerDpiScaleOverride"] = "100",
            ["FIntCLI20390_2"] = "0",
            ["DFIntMaxAverageFrameDelayExceedFactor"] = "0",
            ["FIntNumFramesToCaptureCallStack"] = "1",
            ["DFIntPerformanceControlFrameTimeMax"] = "1",
            ["DFIntRuntimeTickrate"] = "2139999999",
            ["FIntRuntimeMaxNumOfLatches"] = "20000",
            ["DFIntGraphicsOptimizationModeMaxFrameTimeTargetMs"] = "360",
            ["FFlagDebugCodegenOptSize"] = "True",
            ["FIntRuntimeMaxNumOfSchedulers"] = "20000",
            ["DFIntTaskSchedulerTargetFps"] = "9999",
            ["FIntRuntimeMaxNumOfThreads"] = "20000",
            ["FFlagLuauCodegen"] = "True",
            ["DFIntNumFramesAllowedToBeAboveError"] = "0",
            ["FFlagMessageBusCallOptimization"] = "True",
            ["FIntRuntimeMaxNumOfMutexes"] = "20000",
            ["DFIntMaxFrameBufferSize"] = "1",
            ["DFFlagGraphicsOptimizationModeMVPExposureEnrollment4"] = "False",
            ["DFIntGraphicsOptimizationModeFRMFrameRateTarget"] = "360",
            ["DFIntGraphicsOptimizationModeMinFrameTimeTargetMs"] = "360",
        },
    },
    ["Network / Ping"] = {
        desc = "RakNet + packet-processing tuning: lower send/recv delays, bigger bandwidth ceilings, faster ping cadence. Apply the latency flags first, then test the rest one by one.",
        flags = {
            ["DFIntClientPacketExcessMicroseconds"] = "1",
            ["DFIntClientPacketMaxFrameMicroseconds"] = "1",
            ["DFIntMaxProcessPacketsStepsPerCyclic"] = "2147483647",
            ["DFIntMaxFramesToSend"] = "1",
            ["DFIntOptimizePingThreshold"] = "-1",
            ["DFIntNetworkLatencyTolerance"] = "-1",
            ["DFIntRakNetApplicationFeedbackMaxSpeedBPS"] = "2139999999",
            ["DFIntRaknetBandwidthPingSendEveryXSeconds"] = "-1",
            ["DFIntMaxProcessPacketsJobScaling"] = "2147483647",
            ["DFIntClientPacketMinMicroseconds"] = "1",
            ["DFIntRakNetLoopMs"] = "5",
            ["DFIntClientPacketHealthyAllocationPercent"] = "80",
            ["DFIntCodecMaxIncomingPackets"] = "2147483647",
            ["DFIntClientPacketHealthyMsPerSecondLimit"] = "1",
            ["DFIntMaxProcessPacketsStepsAccumulated"] = "0",
            ["DFFlagSampleAndRefreshRakPing"] = "True",
            ["DFIntClientPacketMaxDelayMs"] = "1",
            ["DFIntRakNetResendRttMultiple"] = "2",
            ["DFIntRakNetPingFrequencyMillisecond"] = "10",
            ["DFIntWaitOnUpdateNetworkLoopEndedMS"] = "100",
            ["DFIntRakNetApplicationFeedbackInitialSpeedBPS"] = "2139999999",
            ["DFIntClientPacketUnhealthyContEscMsPerSecond"] = "1",
            ["DFIntMaxReceiveToDeserializeLatencyMilliseconds"] = "1",
            ["DFIntTargetTimeDelayFacctorTenths"] = "0",
            ["DFIntCodecMaxOutgoingFrames"] = "2147483647",
            ["DFIntRakNetClockDriftAdjustmentPerPingMillisecond"] = "2147483647",
            ["FFlagVideoServiceAddHardwareCodecMetrics"] = "True",
            ["DFIntRakNetSelectUnblockSocketWriteDurationMs"] = "10",
        },
    },
    ["Graphics / Rendering"] = {
        desc = "Render pipeline, terrain, grass, particles, post-FX and culling. These trade visual quality for frames; combine with Shadows off for the biggest gain.",
        flags = {
            ["FIntTerrainOTAMaxTextureSize"] = "4",
            ["FFlagDisablePostFx"] = "True",
            ["FIntRenderMeshOptimizeVertexBuffer"] = "1",
            ["FIntRenderGrassDetailStrands"] = "0",
            ["FFlagRemovedRbxRenderingPreProcessor"] = "False",
            ["FFlagRenderInstanceClusterRetryPartInvalidationWhenMeshNotReady4"] = "False",
            ["FIntFRMMaxGrassDistance"] = "0",
            ["FIntGrassMovementReducedMotionFactor"] = "0",
            ["FFlagEnableTerrainFoliageOptimizations"] = "True",
            ["FFlagDebugGraphicsPreferD3D11"] = "True",
            ["FFlagCSGDecalOptimizeVB"] = "True",
            ["DFIntDebugFRMQualityLevelOverride"] = "1",
            ["FFlagVideoReportHardwareBufferMetrics"] = "True",
            ["FFlagRenderDebugCheckThreading2"] = "True",
            ["FFlagHighlightOutlinesOnMobile"] = "True",
            ["FFlagUserHideCharacterParticlesInFirstPerson"] = "True",
            ["DFFlagDebugPauseVoxelizer"] = "True",
            ["DFFlagDebugAuroraServiceRevertAddBindingForNextFixedStep"] = "True",
            ["FFlagFRMRefactor"] = "False",
            ["FFlagDebugDeterministicParticles"] = "False",
            ["FFlagEnableGPUFrustumCulling"] = "True",
            ["FIntTerrainArraySliceSize"] = "0",
            ["FFlagRenderOptimizeDecalTransparencyInvalidation"] = "True",
            ["DFFlagDebugSkipMeshVoxelizer"] = "True",
            ["FFlagDebugGraphicsDisableDirect3D11"] = "False",
            ["DFFlagDebugRenderForceTechnologyVoxel"] = "True",
            ["FIntEnableVisBugChecksHundredthPercent27"] = "0",
            ["FFlagDebugCheckRenderThreading"] = "True",
            ["FFlagRenderDynamicResolutionScale7"] = "True",
            ["DFIntRenderGrassDetailStrands"] = "0",
            ["FIntRenderGrassHeightScaler"] = "0",
            ["FFlagRenderNoLowFrmBloom"] = "False",
            ["FIntDebugForceMSAASamples"] = "1",
            ["FFlagEnableTerrainOptimizations"] = "True",
            ["FIntFRMMinGrassDistance"] = "0",
            ["DFFlagUseVisBugChecks"] = "True",
        },
    },
    ["Shadows / Lighting"] = {
        desc = "Shadow maps, local lights, SSAO, sky rendering and GPU light culling. Disabling shadows/lighting saves the most GPU time.",
        flags = {
            ["FIntRenderShadowmapBias"] = "0",
            ["DFIntCullFactorPixelThresholdShadowMapLowQuality"] = "2147483647",
            ["FIntRenderShadowIntensity"] = "0",
            ["FFlagEnableFastGPULightCulling2"] = "True",
            ["FFlagGlobalShadowsEnabled"] = "False",
            ["FIntRenderLocalLightUpdatesMin"] = "1",
            ["FFlagDebugSSAOForce"] = "False",
            ["FFlagDebugForceGenerateHSR"] = "True",
            ["FFlagRenderLegacyShadowsQualityRefactor"] = "True",
            ["DFIntCullFactorPixelThresholdShadowMapHighQuality"] = "2147483647",
            ["FFlagEnableFastGPULightCulling3"] = "True",
            ["FFlagDebugForceFSMCPULightCulling"] = "True",
            ["FIntSSAOMipLevels"] = "0",
            ["FIntRenderMaxShadowAtlasUsageBeforeDownscale"] = "0",
            ["FFlagEnableNewLightCulling"] = "True",
            ["FFlagFastGPULightCulling3"] = "True",
            ["FFlagRenderLightGridEfficientTextureAtlasUpdate"] = "True",
            ["FFlagNewLightAttenuation"] = "True",
            ["FFlagRenderLocalLightShadows"] = "False",
            ["FFlagDebugForceFutureIsBrightPhase2"] = "False",
            ["FIntRenderLocalLightFadeInMs"] = "0",
            ["FFlagFastGPULightCulling"] = "True",
            ["FFlagShaderLightingRefactor"] = "True",
            ["FIntDirectionalAttenuationMaxPoints"] = "0",
            ["FFlagDebugSkyGray"] = "True",
            ["DFIntRenderShadowIntensity"] = "0",
            ["FIntRenderLocalLightUpdatesMax"] = "1",
            ["FFlagDebugForceFutureIsBrightPhase3"] = "False",
            ["FIntUnifiedLightingBlendZone"] = "0",
        },
    },
    ["Textures / Materials"] = {
        desc = "Texture quality overrides plus every asset/teleport preloading switch. Quality flags save VRAM; preloading flags can lengthen join times but reduce mid-game stutter.",
        flags = {
            ["FFlagPreloadTextureItemsOption4"] = "True",
            ["FFlagPreloadAllFonts"] = "True",
            ["DFFlagAssetPreloadingUrlVersionEnabled2"] = "True",
            ["DFFlagTeleportClientAssetPreloadingEnabledIXP"] = "True",
            ["DFFlagTeleportClientAssetPreloadingDoingExperiment"] = "True",
            ["DFFlagTextureQualityOverrideEnabled"] = "True",
            ["FFlagAssetPreloadingIXP"] = "True",
            ["DFFlagTeleportClientAssetPreloadingEnabled9"] = "True",
            ["DFFlagTeleportClientAssetPreloadingEnabledIXP2"] = "True",
            ["DFFlagEnableMeshPreloading2"] = "True",
            ["DFFlagTeleportClientAssetPreloadingDoingExperiment2"] = "True",
            ["DFFlagEnableTexturePreloading"] = "True",
            ["FIntVertexSmoothingGroupTolerance"] = "1",
            ["DFIntDebugAdditionalNumberOfMipsToSkipForNonAlbedoTextures"] = "0",
            ["DFIntTeleportClientAssetPreloadingHundredthsPercentage"] = "100000",
            ["DFIntAssetPreloading"] = "2147483647",
            ["DFIntNumAssetsMaxToPreload"] = "2147483647",
            ["DFFlagTeleportPreloadingMetrics5"] = "True",
            ["FFlagFastLoadingAssets"] = "True",
            ["DFIntTextureQualityOverride"] = "0",
            ["FFlagMigrateTextureManagerIsLocalAsset"] = "True",
        },
    },
    ["Physics / Simulation"] = {
        desc = "Physics solver, timestep, interpolation and simulation tuning. Extreme values can rubber-band - test incrementally.",
        flags = {
            ["DFIntHACDPointSampleDistApartTenths"] = "2147483647",
            ["DFIntInterpolationDtLimitForLod"] = "1",
            ["DFIntTimestepArbiterThresholdCFLThou"] = "300",
            ["DFIntPhysicsMaxAngularVelocity"] = "999999",
            ["FIntInterpolationAwareTargetTimeLerpHundredth"] = "100",
            ["DFFlagPhysicsAllowExtremeSpin"] = "True",
            ["DFIntParallelAdaptiveInterpolationBatchCount"] = "2",
            ["FFlagSimEnableDCD16"] = "True",
            ["DFFlagPhysicsSyncCurvingWithServer"] = "True",
            ["DFIntPhysicsFrozenStateTimeMs"] = "999999",
            ["DFIntPhysicsLowSpeedCurveBoost"] = "5",
            ["DFIntPhysicsHighSpeedCurveBoost"] = "10",
            ["DFFlagPhysicsAdaptiveCurveStrength"] = "True",
            ["DFFlagPhysicsAlwaysAllowCurving"] = "True",
            ["FIntSmoothTerrainPhysicsCacheSize"] = "0",
            ["DFIntInterpolationMinAssemblyCount"] = "1",
            ["DFIntPhysicsSpinCurveAcceleration"] = "99999",
            ["DFFlagPhysicsInfiniteCurvePersistence"] = "True",
            ["DFIntPhysicsSpinFrictionMultiplier"] = "0",
            ["DFFlagSimOptimizeSetSize"] = "True",
            ["FIntSimSolverResponsiveness"] = "2139999999",
            ["FFlagNewOptimizeNoCollisionPrimitiveInMidphase637"] = "True",
            ["DFFlagPhysicsIgnoreDragForCurving"] = "True",
            ["FIntInterpolationMaxDelayMSec"] = "2",
        },
    },
    ["Animations"] = {
        desc = "Animation LOD + animator optimizations. Small frame gain, low risk.",
        flags = {
            ["FFlagOptimizeAnimations"] = "True",
            ["DFIntAnimationLodFacsDistanceMin"] = "0",
            ["DFIntAnimationLodFacsVisibilityDenominator"] = "0",
            ["DFIntAnimationLodFacsDistanceMax"] = "0",
            ["FFlagQuaternionPoseCorrection"] = "True",
        },
    },
    ["Telemetry / Analytics"] = {
        desc = "Telemetry, analytics, ads and data-sharing switches plus the FLog network logger. Disabling these cuts background noise; this category stays ON by default.",
        flags = {
            ["FFlagDebugDisableTelemetryEphemeralCounter"] = "True",
            ["FFlagDebugDisableTelemetryPoint"] = "True",
            ["FFlagDebugDisableTelemetryEphemeralStat"] = "True",
            ["FFlagAdServiceEnabled"] = "False",
            ["FFlagDebugDisableTelemetryV2Event"] = "True",
            ["DFIntWindowsWebViewTelemetryThrottleHundredthsPercent"] = "0",
            ["FFlagContentProviderPreloadHangTelemetry"] = "False",
            ["FFlagDebugDisableTelemetryV2Stat"] = "True",
            ["FIntCAP1209DataSharingRolloutPercentage"] = "0",
            ["FFlagDebugDisableTelemetryV2Counter"] = "True",
            ["FIntCAP1544DataSharingUserRolloutPercentage"] = "0",
            ["FLogNetwork"] = "7",
            ["FFlagDebugDisableTelemetryEventIngest"] = "True",
            ["FIntCAP1209DataSharingTOSVersion"] = "0",
        },
    },
    ["UI / Menu"] = {
        desc = "In-game menu, badges, camera/input feel, DPI scaling and core UI behavior.",
        flags = {
            ["FFlagEnableInGameMenuDurationLogger"] = "False",
            ["FFlagVoiceBetaBadge"] = "False",
            ["FFlagUserUpdateInputConnections"] = "True",
            ["FFlagSyncWebViewCookieToEngine2"] = "False",
            ["FFlagHandleAltEnterFullscreenManually"] = "False",
            ["FFlagAlwaysShowVRToggleV3"] = "False",
            ["FIntCameraMaxZoomDistance"] = "9999",
            ["FFlagNewCameraControls"] = "True",
            ["FFlagBetaBadgeLearnMoreLinkFormview"] = "False",
            ["DFFlagDisableDPIScale"] = "True",
            ["FIntFullscreenTitleBarTriggerDelayMillis"] = "3600000",
            ["FFlagImproveShiftLockTransition"] = "True",
            ["FFlagEnableInGameMenuChromeABTest4"] = "True",
            ["FFlagControlBetaBadgeWithGuac"] = "False",
            ["FFlagMovePrerenderV2"] = "True",
            ["FFlagDisableFeedbackSoothsayerCheck"] = "False",
            ["FFlagTopBarUseNewBadge"] = "False",
            ["FFlagLuaMenuPerfImprovements"] = "True",
            ["FIntActivatedCountTimerMSKeyboard"] = "0",
            ["DFFlagDebugOverrideDPIScale"] = "False",
            ["FFlagEnableCommandAutocomplete"] = "False",
            ["FIntActivatedCountTimerMSMouse"] = "0",
            ["FFlagEnableInGameMenuChrome"] = "True",
            ["FFlagDisableDPIScale"] = "True",
            ["FFlagLuaAppsEnableParentalControlsTab"] = "False",
            ["FStringVoiceBetaBadgeLearnMoreLink"] = "null",
            ["FFlagMovePrerender"] = "True",
            ["FFlagAddHapticsToggle"] = "False",
            ["FFlagUserCameraInputRefactor3"] = "True",
            ["FFlagLuaAppLegacyInputSettingRefactor"] = "True",
            ["FFlagChatTranslationEnableSystemMessage"] = "False",
        },
    },
    ["Client Fixes"] = {
        desc = "The crash/hang/fix batch shipped inside the new set. Safe to leave ON with any category.",
        flags = {
            ["FFlagFixTestServiceStart"] = "True",
            ["DFFlagFixCloudWarnings"] = "True",
            ["FFlagFixMeshLoadingHang"] = "True",
            ["DFFlagFixCircularBuffer"] = "True",
            ["FFlagFixBTIDState"] = "True",
            ["DFFlagCrash155229Fix"] = "True",
            ["DFFlagFixImprovedSearchCutThroughWallLerpTarget"] = "True",
            ["DFFlagContentProviderFixAssetFormatHashingInUpdatePriority"] = "True",
            ["DFFlagFixHumanoidRootPartRaycasts"] = "True",
            ["DFFlagFixNavigationAnalyticDuplicatePlaceId"] = "True",
            ["DFFlagSimActiveConstraintReportingFix"] = "True",
            ["DFFlagSimFixForBoundaryWaterCellBuoyancy"] = "True",
            ["DFFlagHighlightsFixAncestorChanges"] = "True",
            ["DFFlagFixFreefallCleanup"] = "True",
            ["DFFlagSimFixRunningControllerFreeFall"] = "True",
            ["FFlagAssetConfigFixBadIdVerifyState"] = "True",
            ["FFlagRenderFixParticleDegenCrossProduct"] = "True",
            ["FFlagFixPersistentConstantBufferInstancing"] = "True",
            ["DFFlagTimerServiceFix"] = "True",
            ["DFFlagTeleportTimeToSleepAdjustmentFix"] = "True",
            ["DFFlagPathfindingFixPathCutThoughtWall"] = "True",
            ["FFlagFixFileMenuFiles"] = "True",
            ["FFlagFixGetHumanoidForAccessories"] = "True",
            ["DFFlagFixAVBURST15480"] = "True",
            ["FFlagRenderFixFog"] = "False",
            ["DFFlagHttpFixUnfinishedBody"] = "True",
            ["FFlagModifiedPropertiesFixEventOrdering"] = "True",
            ["DFFlagSimSolverFixRodGS"] = "True",
            ["FFlagFixSmoothingDegenerateTriangles"] = "True",
            ["FFlagFixFirstPersonMouseCursorSnapping_CenterPos"] = "True",
            ["FFlagAnimationTrackStepFix"] = "True",
            ["FFlagFixGraphicsQuality"] = "True",
            ["FFlagFixIntervalStatStartSamplingThisUse"] = "True",
            ["DFFlagSimCSG4FixBoxMapping"] = "True",
            ["DFFlagDisconnectReasonPerConnectionFix"] = "True",
            ["DFFlagAuroraFixForDoubleUpdate"] = "True",
            ["DFFlagSimBucketCountAnalyticsFix"] = "True",
            ["DFFlagPhantomFreezeKeepAliveFix"] = "True",
            ["FFlagFixReducedMotionStuckIGM2"] = "True",
            ["DFFlagSimFixAssemblyRadiusCalc"] = "True",
            ["DFFlagFixCREATORBUG5135"] = "True",
            ["DFFlagStepExitStatFix"] = "True",
            ["FFlagFixParticleEmissionBias2"] = "False",
            ["DFFlagFixFreefall"] = "True",
            ["DFFlagDebugSimSolverPrimalDtFix"] = "True",
            ["DFFlagRakNetFixBwCollapse"] = "True",
            ["FFlagCLI_148857_GenerationServiceTestingFixes"] = "True",
            ["DFFlagDMServiceStatsNullPtrFixEnabled"] = "True",
            ["DFFlagCaptureEngineFixDereferencingNull"] = "True",
            ["FFlagFCFixPartIndices"] = "True",
            ["FFlagFixIntervalStatsSynchronization"] = "True",
            ["DFFlagSimFixCanSetNetworkOwnership"] = "True",
            ["DFFlagFixLastAssetDeliveredTime"] = "True",
            ["FFlagFixBTIDStateTelemetry"] = "True",
            ["FFlagFixRedundantAllocationInAnimator"] = "True",
            ["DFFlagConfigServiceTelemetryFix"] = "True",
            ["DFFlagFixAppSuccssMult"] = "True",
            ["FFlagRobloxTelemetryFixHostNameKey"] = "True",
            ["DFFlagUGCValidateMeshTriangleAreaFacesFix"] = "True",
            ["FFlagFixCLI125315"] = "True",
            ["FFlagFixSBT4425"] = "True",
            ["DFFlagHttpFixLastModified"] = "True",
            ["FFlagLocServiceUseNewAutoLocSettingEndpointFix"] = "True",
            ["FFlagEmitterTextureDimensionFix"] = "True",
            ["FFlagHideCoreGuiFixes"] = "True",
            ["FFlagPerformanceControlAverageTunableQualityFix"] = "True",
            ["DFFlagFixServerQueuePushBack"] = "True",
            ["FFlagFixSpecialFileMeshToIc"] = "True",
            ["DFFlagContentProviderFixClearContent"] = "True",
            ["DFFlagFixCompositorAtomicsGc"] = "True",
            ["FFlagPerformanceControlFixTelemetryName"] = "True",
            ["DFFlagFixJoinMismatchReport"] = "True",
            ["DFFlagSimStepPhysicsFixNotifyPrimitivesUseAfterFree"] = "True",
            ["FFlagFixDiffToolSpacing"] = "True",
            ["FFlagTerrainFixDoubleMeshing"] = "True",
            ["FFlagFixCalloutResizeOgreWidget"] = "True",
            ["DFFlagFixSessionMetricTeleportCondition"] = "True",
        },
    },
}

do
    local FastFlagsTab = getgenv()._ENX_Tabs.FastFlags

    local InfoSection = FastFlagsTab:AddSection({
        Name = "How To Use",
        Position = "left"
    })
    InfoSection:AddLabel("Toggle categories on/off, then click Apply.")
    InfoSection:AddLabel("Each category has a description below.")
    InfoSection:AddLabel("Note: Most flags require a respawn to take effect.")
    InfoSection:AddLabel("WARNING: Some flags may cause crashes if combined badly.")

    local CategoriesSection = FastFlagsTab:AddSection({
        Name = "Categories",
        Position = "left"
    })

    local DescriptionsSection = FastFlagsTab:AddSection({
        Name = "Descriptions",
        Position = "right"
    })

    local CategoryState = {}

    local category_order = {
        "Blade Ball",
        "FPS / Frame Rate",
        "Network / Ping",
        "Graphics / Rendering",
        "Shadows / Lighting",
        "Textures / Materials",
        "Physics / Simulation",
        "Animations",
        "Telemetry / Analytics",
        "UI / Menu",
        "Client Fixes",
    }

    for _, cat_name in ipairs(category_order) do
        local cat_data = FASTFLAGS_BY_CATEGORY[cat_name]
        if cat_data then
            local default = (cat_name == "Telemetry / Analytics")
            CategoryState[cat_name] = default

            CategoriesSection:AddToggle({
                Name = cat_name,
                Default = default,
                Callback = function(value)
                    CategoryState[cat_name] = value
                end,
            })

            DescriptionsSection:AddLabel(cat_name)
            DescriptionsSection:AddLabel(cat_data.desc)
            local n = 0
            for _ in pairs(cat_data.flags) do n = n + 1 end
            DescriptionsSection:AddLabel("(" .. n .. " flags)")
        end
    end

    local ApplySection = FastFlagsTab:AddSection({
        Name = "Apply",
        Position = "right"
    })

    ApplySection:AddButton({
        Name = "Apply Selected Categories",
        Callback = function()
            local applied = 0
            local skipped = 0
            for cat_name, enabled in pairs(CategoryState) do
                if enabled then
                    local cat_data = FASTFLAGS_BY_CATEGORY[cat_name]
                    if cat_data then
                        for flag_name, flag_value in pairs(cat_data.flags) do
                            local ok = pcall(function()
                                setfflag(flag_name, tostring(flag_value))
                            end)
                            if ok then applied = applied + 1 else skipped = skipped + 1 end
                        end
                    end
                end
            end
            ENXNotify.new('EclipseNexus',
                'Applied ' .. applied .. ' flags (' .. skipped .. ' skipped). Respawn to take effect.', 5)
        end,
    })

    ApplySection:AddButton({
        Name = "Apply ALL Categories",
        Callback = function()
            local applied = 0
            local skipped = 0
            for cat_name, cat_data in pairs(FASTFLAGS_BY_CATEGORY) do
                for flag_name, flag_value in pairs(cat_data.flags) do
                    local ok = pcall(function()
                        setfflag(flag_name, tostring(flag_value))
                    end)
                    if ok then applied = applied + 1 else skipped = skipped + 1 end
                end
            end
            ENXNotify.new('EclipseNexus',
                'Applied ALL ' .. applied .. ' flags (' .. skipped .. ' skipped). Respawn to take effect.', 5)
        end,
    })

    ApplySection:AddButton({
        Name = "Reset Selected to Default",
        Callback = function()
            local reset = 0
            for cat_name, enabled in pairs(CategoryState) do
                if enabled then
                    local cat_data = FASTFLAGS_BY_CATEGORY[cat_name]
                    if cat_data then
                        for flag_name, _ in pairs(cat_data.flags) do
                            pcall(function()
                                setfflag(flag_name, "False")
                            end)
                            reset = reset + 1
                        end
                    end
                end
            end
            ENXNotify.new('EclipseNexus',
                'Reset ' .. reset .. ' flags to False. Respawn to take effect.', 5)
        end,
    })

    ApplySection:AddLabel("Total flags available: 374 (across all categories)")
    ApplySection:AddLabel("Tip: Enable Telemetry + Network first, then test others one by one.")
end

do
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

pcall(getgenv()._EclipseNexus_Winstreak_Stop)

local FAKE = 0
local uiFrame = nil
local isDragging = false
local dragStart = nil
local startPos = nil

local _ws_running = false
local _ws_conns = {}
local _ws_charConn = nil
local _ws_gui = nil
local _ws_mine = nil
local _ws_orig = nil
local _ws_added = {}
local _ws_buildWait = nil
local _ws_buildSince = 0

local function _ws_drop_dead(char)
    if _ws_mine and _ws_mine.Parent ~= char then
        _ws_mine = nil
    end
    if _ws_orig and _ws_orig.display.Parent ~= char then
        _ws_orig = nil
    end
    local _ws_alive = {}
    for _, inst in ipairs(_ws_added) do
        if inst.Parent then
            _ws_alive[#_ws_alive + 1] = inst
        end
    end
    _ws_added = _ws_alive
end

local FIRE_ICON_ORANGE = "rbxassetid://89658127170771"
local FIRE_ICON_BLUE = "rbxassetid://75598166115655"

local function getIconImage(n)
    return n >= 10 and FIRE_ICON_BLUE or FIRE_ICON_ORANGE
end

local function makeOverheadText(n)
    return string.format('<b><stroke color="rgb(0, 0, 0)" thickness="2"><font color="#ffffff">%d</font></stroke></b>', n)
end

local function updateOverhead()
    local char = player.Character
    if not char then return end

    _ws_drop_dead(char)

    local display = nil
    do
        local gameDisp, mineDisp = nil, nil
        for _, child in ipairs(char:GetChildren()) do
            if child.Name == "WinStreakDisplay" then
                if child:GetAttribute("EclipseNexusWinstreak") then
                    mineDisp = child
                elseif gameDisp == nil then
                    gameDisp = child
                end
            end
        end
        if gameDisp then
            if mineDisp then
                pcall(function() mineDisp:Destroy() end)
                for i = #_ws_added, 1, -1 do
                    local inst = _ws_added[i]
                    if inst == mineDisp or inst:IsDescendantOf(mineDisp)
                        or not inst.Parent then
                        table.remove(_ws_added, i)
                    end
                end
                if _ws_mine == mineDisp then
                    _ws_mine = nil
                end
                if _ws_orig and _ws_orig.display == mineDisp then
                    _ws_orig = nil
                end
            end
            display = gameDisp
        elseif mineDisp then
            display = mineDisp
            if _ws_mine ~= display then
                _ws_mine = display
                _ws_orig = nil
            end
        end
    end
    if not display then
        local head = char:FindFirstChild("Head")
        if not head then return end
        display = Instance.new("BillboardGui")
        display.Name = "WinStreakDisplay"
        display.Adornee = head
        display.Size = UDim2.new(0, 200, 0, 50)
        display.StudsOffset = Vector3.new(0, 3.5, 0)
        display.MaxDistance = 200
        display.AlwaysOnTop = true
        display:SetAttribute("EclipseNexusWinstreak", true)
        display.Parent = char
        _ws_mine = display
    end

    if not _ws_mine and (not _ws_orig or _ws_orig.display ~= display) then
        _ws_orig = { display = display, text = nil, image = nil, captured = false }
    end

    display.Enabled = true
    display.AlwaysOnTop = true

    if not _ws_mine then
        local gameMain = nil
        for _, child in ipairs(display:GetChildren()) do
            if child.Name == "Main" and not table.find(_ws_added, child) then
                gameMain = child
                break
            end
        end
        if gameMain then
            local hadFallback = false
            for _, inst in ipairs(_ws_added) do
                if inst.Parent and inst:IsDescendantOf(display) then
                    hadFallback = true
                    break
                end
            end
            if hadFallback then
                for i = #_ws_added, 1, -1 do
                    local inst = _ws_added[i]
                    if inst:IsDescendantOf(display) then
                        if inst.Parent then
                            pcall(function() inst:Destroy() end)
                        end
                        table.remove(_ws_added, i)
                    end
                end
                if _ws_orig and _ws_orig.display == display then
                    _ws_orig = nil
                end
            end
        end
    end

    local main = display:FindFirstChild("Main")
    if not main then
        if not _ws_mine and FAKE > 0 then
            if _ws_buildWait ~= display then
                _ws_buildWait = display
                _ws_buildSince = os.clock()
            end
            if os.clock() - _ws_buildSince < 3 then
                return
            end
        end
        main = Instance.new("Frame")
        main.Name = "Main"
        main.Size = UDim2.new(1, 0, 1, 0)
        main.BackgroundTransparency = 1
        main.Parent = display
        _ws_added[#_ws_added + 1] = main
    end
    _ws_buildWait = nil

    if FAKE <= 0 then
        display.Enabled = false
        return
    end

    local icon = main:FindFirstChild("Icon")
    if not icon then
        icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(1.25, 0, 1.25, 0)
        icon.Position = UDim2.new(0.5, 0, 0.899999976, 0)
        icon.BackgroundTransparency = 1
        icon.Parent = main
        local aspect = Instance.new("UIAspectRatioConstraint")
        aspect.Parent = icon
        _ws_added[#_ws_added + 1] = icon
    end

    if not _ws_mine and _ws_orig and _ws_orig.display == display
        and _ws_orig.main ~= nil and _ws_orig.main ~= main
        and not table.find(_ws_added, main) then
        _ws_orig.captured = false
        _ws_orig.text = nil
        _ws_orig.image = nil
    end
    if not _ws_mine and _ws_orig and _ws_orig.display == display
        and not _ws_orig.captured then
        _ws_orig.captured = true
        _ws_orig.main = main
        local v0 = main:FindFirstChild("Value")
        if v0 and not table.find(_ws_added, v0) then
            _ws_orig.text = v0.Text
        end
        if not table.find(_ws_added, icon) then
            _ws_orig.image = icon.Image
        end
    end

    icon.Image = getIconImage(FAKE)
    icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    icon.Visible = true

    local value = main:FindFirstChild("Value")
    if not value then
        value = Instance.new("TextLabel")
        value.Name = "Value"
        value.Size = UDim2.new(1, 0, 1, 0)
        value.BackgroundTransparency = 1
        value.TextScaled = true
        value.Font = Enum.Font.SourceSansBold
        value.TextColor3 = Color3.fromRGB(255, 255, 255)
        value.TextStrokeColor3 = Color3.new(0, 0, 0)
        value.TextStrokeTransparency = 0
        value.RichText = true
        value.Parent = main
        _ws_added[#_ws_added + 1] = value
    end

    value.Text = makeOverheadText(FAKE)
    value.Visible = true
end

local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WinstreakController"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 100
    local _ws_core_ok = pcall(function()
        screenGui.Parent = CoreGui
    end)
    if not _ws_core_ok or not screenGui.Parent then
        screenGui.Parent = player:WaitForChild("PlayerGui")
    end
    ENXUI.ProtectGui(screenGui)
    _ws_gui = screenGui

    uiFrame = Instance.new("Frame")
    uiFrame.Name = "Main"
    uiFrame.Size = UDim2.new(0, 250, 0, 120)
    uiFrame.Position = UDim2.new(0.5, -125, 0.5, -60)
    uiFrame.BackgroundTransparency = 0.3
    uiFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    uiFrame.BorderSizePixel = 2
    uiFrame.BorderColor3 = Color3.fromRGB(50, 150, 255)
    uiFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = uiFrame

    local dragBar = Instance.new("Frame")
    dragBar.Name = "DragBar"
    dragBar.Size = UDim2.new(1, 0, 0, 25)
    dragBar.Position = UDim2.new(0, 0, 0, 0)
    dragBar.BackgroundTransparency = 0.5
    dragBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    dragBar.BorderSizePixel = 0
    dragBar.Parent = uiFrame

    local dragCorner = Instance.new("UICorner")
    dragCorner.CornerRadius = UDim.new(0, 10)
    dragCorner.Parent = dragBar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Winstreak Spoofer"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.SourceSansBold
    title.Parent = dragBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -28, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = dragBar

    closeBtn.MouseButton1Click:Connect(function()
        uiFrame.Visible = false
    end)

    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = uiFrame.Position
        end
    end)

    _ws_conns[#_ws_conns + 1] = UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            uiFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    _ws_conns[#_ws_conns + 1] = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    dragBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.7, 0, 0, 35)
    input.Position = UDim2.new(0.15, 0, 0.35, 0)
    input.BackgroundTransparency = 0.5
    input.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    input.BorderSizePixel = 1
    input.BorderColor3 = Color3.fromRGB(100, 100, 100)
    input.PlaceholderText = "Enter winstreak..."
    input.Text = "0"
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextSize = 20
    input.Font = Enum.Font.SourceSansBold
    input.ClearTextOnFocus = false
    input.Parent = uiFrame

    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 6)
    corner2.Parent = input

    local apply = Instance.new("TextButton")
    apply.Size = UDim2.new(0.4, 0, 0, 30)
    apply.Position = UDim2.new(0.3, 0, 0.75, 0)
    apply.BackgroundTransparency = 0.2
    apply.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    apply.BorderSizePixel = 0
    apply.Text = "Apply"
    apply.TextColor3 = Color3.fromRGB(255, 255, 255)
    apply.TextSize = 16
    apply.Font = Enum.Font.SourceSansBold
    apply.Parent = uiFrame

    local corner3 = Instance.new("UICorner")
    corner3.CornerRadius = UDim.new(0, 6)
    corner3.Parent = apply

    apply.MouseButton1Click:Connect(function()
        local num = tonumber(input.Text)
        if num and num >= 0 then
            FAKE = num
            updateOverhead()
        end
    end)

    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local num = tonumber(input.Text)
            if num and num >= 0 then
                FAKE = num
                updateOverhead()
            end
        end
    end)

    local showBtn = Instance.new("TextButton")
    showBtn.Size = UDim2.new(0, 35, 0, 35)
    showBtn.Position = UDim2.new(0, 10, 0, 10)
    showBtn.BackgroundTransparency = 0.5
    showBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    showBtn.BorderSizePixel = 2
    showBtn.BorderColor3 = Color3.fromRGB(50, 150, 255)
    showBtn.Text = "WS"
    showBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    showBtn.TextSize = 12
    showBtn.Font = Enum.Font.SourceSansBold
    showBtn.Visible = false
    showBtn.Parent = screenGui

    local showCorner = Instance.new("UICorner")
    showCorner.CornerRadius = UDim.new(0, 8)
    showCorner.Parent = showBtn

    showBtn.MouseButton1Click:Connect(function()
        uiFrame.Visible = true
        showBtn.Visible = false
    end)

    uiFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if not uiFrame.Visible then
            showBtn.Visible = true
        end
    end)

    return input
end

local function watchCharacter(char)
    if not char then return end
    if _ws_charConn then
        pcall(function() _ws_charConn:Disconnect() end)
        _ws_charConn = nil
    end
    _ws_charConn = char.ChildAdded:Connect(function(child)
        if child.Name == "WinStreakDisplay" then
            task.wait(0.05)
            pcall(updateOverhead)
        end
    end)
    pcall(updateOverhead)
end

local function start_winstreak()
    if _ws_running then return end
    _ws_running = true

    if player.Character then
        watchCharacter(player.Character)
    end

    _ws_conns[#_ws_conns + 1] = player.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart", 5)
        task.wait(0.5)
        if player.Character ~= char then return end
        _ws_drop_dead(char)
        isDragging = false
        dragStart = nil
        startPos = nil
        pcall(updateOverhead)
        watchCharacter(char)
    end)

    task.spawn(function()
        while _ws_running do
            task.wait(0.5)
            pcall(updateOverhead)
        end
    end)

    createUI()

end

local function stop_winstreak()
    _ws_running = false
    for _, c in ipairs(_ws_conns) do
        pcall(function() c:Disconnect() end)
    end
    _ws_conns = {}
    if _ws_charConn then
        pcall(function() _ws_charConn:Disconnect() end)
        _ws_charConn = nil
    end
    isDragging = false
    dragStart = nil
    startPos = nil
    _ws_buildWait = nil
    _ws_buildSince = 0
    if _ws_gui then
        pcall(function() _ws_gui:Destroy() end)
        _ws_gui = nil
    end
    uiFrame = nil
    local char = player.Character
    local display = char and char:FindFirstChild("WinStreakDisplay")
    if display then
        if _ws_mine then
            pcall(function() display:Destroy() end)
        else
            for _, child in ipairs(_ws_added) do
                pcall(function() child:Destroy() end)
            end
            if _ws_orig and _ws_orig.display == display then
                pcall(function()
                    local main = display:FindFirstChild("Main")
                    local value = main and main:FindFirstChild("Value")
                    if value and _ws_orig.text ~= nil then value.Text = _ws_orig.text end
                    local icon = main and main:FindFirstChild("Icon")
                    if icon and _ws_orig.image ~= nil then icon.Image = _ws_orig.image end
                    display.Enabled = true
                end)
            end
        end
    end
    _ws_mine = nil
    _ws_orig = nil
    _ws_added = {}
    FAKE = 0
end

getgenv()._EclipseNexus_Winstreak_Start = start_winstreak
getgenv()._EclipseNexus_Winstreak_Stop = stop_winstreak
end

ENXNotify.new("EclipseNexus", "EclipseNexus loaded", 5)