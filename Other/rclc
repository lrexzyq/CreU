-- RCLC Premium (Roblox hvh addon) -- readable build
-- Same code and behaviour as rclc_deobf.lua, with the leftover obfuscator names replaced:
--   * UI: tabs are voidTab / orbitTab / defenseTab / translocTab / extrasTab / settingsTab,
--     and every Callback gets `enabled` (toggles), `value` (sliders), `option` (dropdowns), `key` (keybind)
--   * logic: v###/p###/f### locals renamed after what they hold (dt, root, now, radius, ...)
--   * layout: section banners added; nothing reordered
-- Fixed corruption from the source file:
--   * `Instance.negh("Frame")` in the position HUD  -> `Instance.new("Frame")`
--   * `["Incr'ent"]` on the Yaw Max slider          -> `Increment`
-- Bugs that are in the ORIGINAL logic and are still there (marked with "BUG" comments):
--   * hookToolActivate uses `old` and `v346`, which are never defined
--   * enableTransloc calls stopTransloc(), which does not exist
--   * voidTarget ("Chaos" method) uses a global VOID_CHAOS_MAX that is never set

local getRoot, frameBudgetOk, weaponSlotIndex, getNpcTargets, disableKillAura, nearestPlayerRoot, getHead, sidestepDirection, scorePlayers, sanitizeVector, disableVoid, enableWireframes, disableWireframes, disableOrbit, enableOrbit, disablePrediction, hookAllPlayerTools, enableUndergroundAA, disableUndergroundAA,
  enableTransloc, disableTransloc, enableFakePos, disableFakePos, enableVelDesync, disableVelDesync, enableFastMelee, disconnectConn, startAutoEquip, randomRange, enableVoid, mhapiPresent, AirflowUI, window, Players,
  RunService, ReplicatedStorage, localPlayer, character, rootPart, humanoid, connections, frameStamp, frameCount, voidCfg, orbitCfg, predictCfg,
  translocCfg, fakePosCfg, velDesyncCfg, antiAimCfg, undergroundCfg, undergroundAngle, undergroundConn, savedRootJointC0, fastMeleeCfg, fastGunState, excludedGuns, killAuraCfg, Utility, EnumLibrary, FighterController, lastShotTime, killAuraConn,
  autoEquipThread, notify, patchGun, patchEquippedGuns, fastGunTick, weaponSlots, stopAutoEquip, killAuraStep, enableKillAura, velTrackers, getTracker, updateTracker, voidState, voidPhaseTime, voidBaitPhase, voidTarget, voidStep, wireframeFolder, wireframeBoxes,
  setWireframes, orbitAngle, lastPredFire, lastToolUse, hookedTools, hookedToolCount, hookToolActivate, enablePrediction, enableAntiAim, disableAntiAim, translocConn, translocTimer, fakePosHeartbeat, fakePosRender, fakePosAnchor, fakePosAngle,
  fakePosHue, fakePosLastWrite, fakePosTime, velDesyncConn, velDesyncConn2, desyncSavedVel, desyncAngle, desyncFlipTimer, desyncOscTime, desyncBurstTimer, desyncFlipState, fastMeleeConn, cacheMeleeTables, disableFastMelee, onCharacterAdded, positionHud

mhapiPresent = false

if _G.Mhapi then
  mhapiPresent = true
end

local game3 = game

AirflowUI = loadstring(game3:HttpGet("https://raw.githubusercontent.com/PookiePepelsss/Airflow-UI/refs/heads/main/Source.luau"))()

AirflowUI:LoadFont({
  Name = "ValleySans",
})

window = AirflowUI:CreateWindow({
  Name = "RCLC",
  LoadingSubtitle = "RCLC",
  Theme = "Default",
  ToggleUIKeybind = "RightControl",
  ConfigurationSaving = {
    Enabled = true,
    FolderName = "RCLCPremium",
    FileName = "default",
  },
  Home = {
    Name = "Home",
    Stats = {
      "FPS",
      "Ping",
      "Executor",
      "Game",
      "Time",
    },
    Pages = {
      {
        Name = "Info",
        Icon = "info",
        Content = "RCLC Premium Lua - #1 hvh addon",
      },
    },
  },
})

Players = game:GetService("Players")

RunService = game:GetService("RunService")

game:GetService("UserInputService")

ReplicatedStorage = game:GetService("ReplicatedStorage")

localPlayer = Players.LocalPlayer

local camera = workspace.CurrentCamera

character = nil
rootPart = nil
humanoid = nil
connections = {}

function disconnectConn(connName)
  if connections[connName] then
    connections[connName]:Disconnect()
    connections[connName] = nil
  end
end

function getRoot()
  return rootPart
end

frameStamp = -1

function frameBudgetOk()
  local currentFrame = math.floor(tick()
      * 60
    + 0.5)

  if currentFrame ~= frameStamp then
    frameStamp = currentFrame
    frameCount = 0
  end

  if frameCount >= 3 then
    return false
  end

  frameCount = frameCount + 1
  return true
end

frameCount = 0

-- ============================================================
-- CONFIG TABLES (defaults mirror the UI controls)
-- ============================================================
voidCfg = {
  VOID_ENABLED = false,
  VOID_METHOD = "Quantum",
  VOID_ATTACKER_INTERVAL = 4,
  VOID_ATTACKER_DURATION = 0.4,
  VOID_BAIT_INTERVAL = 3,
  VOID_BAIT_DURATION = 0.4,
  SPEED = 1000000000,
  CHAOS = 0.98,
  BASE_X = 0,
  BASE_Y = 0,
  BASE_Z = 0,
  RADIUS = 10000000,
  VOID_Y_MIN = -10000000,
  VOID_Y_MAX = 10000000,
  VOID_WRITES_PER_FRAME = 1,
  VOID_INTERP = true,
  VOID_INTERP_ALPHA = 0.35,
  VOID_HOLD = 0,
  VOID_JITTER = 0,
  VOID_ANTIFLING = true,
  VOID_ANTIVOID = false,
  VOID_SAFE_RADIUS = 0,
  VOID_LOG = false,
  VOID_CURVE_FREQ = 0.7,
  VOID_CURVE_AMP = 0.5,
  VOID_DRIFT_SPEED = 1,
  VOID_GRID_SIZE = 8,
  VOID_SCREEN_DEPTH_MIN = 50,
  VOID_SCREEN_DEPTH_MAX = 50000,
  VOID_CHASE_MAX = 200,
  VOID_MIRROR_AXIS = "X",
  VOID_PREDICT_LEAD = 0.2,
  VOID_DURATION_ENABLED = false,
  VOID_DURATION = 10,
  WIREFRAME_ENABLED = false,
}

orbitCfg = {
  orbitEnabled = false,
  orbitSpeed = 90,
  orbitDist = 8,
  orbitHeight = 0,
  orbitMode = "Clockwise",
  orbitLockDist = 10000000,
}

predictCfg = {
  predEnabled = false,
  predRadius = 150,
  predDodgeDist = 80,
  predCooldown = 0.05,
  predReactionTime = 0.12,
  predBulletSpeed = 1000,
  predAimThreshold = 0.7,
  predKinematic = true,
  predPredictive = true,
  predLookahead = 0.5,
  predInfiniteRange = false,
}

translocCfg = {
  enabled = false,
  frequency = 1000000,
  jitterX = 10000000,
  jitterY = 10000000,
  fixedZ = 1,
  fakeVel = true,
  fakeVelMag = 10000000000,
  burstMode = false,
  burstCount = 10,
}

fakePosCfg = {
  enabled = false,
  radius = 1000000,
  height = 999999999,
  yDist = 999999999,
  speed = 100000,
  pattern = "Scatter",
  distribution = "Random",
  axisLock = "None",
  randomizeEveryFrame = false,
  scatterAngle = 360,
  pulseRadius = false,
  pulseRadiusMin = 100,
  pulseRadiusMax = 999999,
  pulseSpeed = 2,
  layeredFake = false,
  layerCount = 3,
  chaosMode = false,
  chaosMult = 5,
}

velDesyncCfg = {
  enabled = false,
  intensity = 50,
  angle = 90,
  jitter = 20,
  flip = false,
  speed = 10,
  randomizeAngle = false,
  angleMin = 0,
  angleMax = 360,
  multiVector = false,
  vectorCount = 3,
  spikeMode = false,
  spikeInterval = 0.05,
  spikeMag = 1000000,
  invertOnTimer = false,
  invertInterval = 0.2,
  oscillate = false,
  oscillateFreq = 5,
  oscillateAmp = 30,
  noiseVel = false,
  noiseScale = 1,
  burstDesync = false,
  burstEvery = 0.1,
  burstMag = 500000,
  counterVel = false,
  rotateVel = false,
  rotateVelSpeed = 180,
}

antiAimCfg = {
  enabled = false,
  speed = 5000,
  chaosLevel = 100,
  pitch = 360,
  yaw = 360,
}

undergroundCfg = {
  enabled = false,
  depth = 1.5,
  orbitRadius = 3,
  orbitSpeed = 200,
  spinSpeed = 720,
}

undergroundAngle = 0
undergroundConn = nil
savedRootJointC0 = nil

fastMeleeCfg = {
  enabled = false,
  cached = {},
  cooldown = 0,
  animSpeed = 100,
  remoteCount = 5,
}

fastGunState = {
  primaryOn = false,
  primaryHits = 0,
  lastPatch = 0,
}

excludedGuns = {
  Sniper = true,
  Crossbow = true,
  Bow = true,
  RPG = true,
}

killAuraCfg = {
  enabled = false,
  fireRate = 0.02,
  weaponSlot = "Primary",
  radius = 5000,
  headshotOffset = 1,
  jitter = 0.02,
  autoEquip = true,
}

Utility = nil
EnumLibrary = nil
FighterController = nil
lastShotTime = 0
killAuraConn = nil
autoEquipThread = nil

-- ============================================================
-- GAME MODULES (Utility / EnumLibrary / FighterController)
-- ============================================================
pcall(function()
  Utility = require(ReplicatedStorage.Modules.Utility)

  EnumLibrary = require(ReplicatedStorage.Modules.EnumLibrary)

  local findFirstChild = localPlayer:FindFirstChild("PlayerScripts")

  if findFirstChild then
    local findFirstChild2 = findFirstChild:FindFirstChild("Controllers")

    if findFirstChild2
      and findFirstChild2:FindFirstChild("FighterController") then
      FighterController = require(findFirstChild2.FighterController)
    end
  end
end)

function notify(title, message, kind, duration)
  if mhapiPresent
    and _G.Mhapi
    and _G.Mhapi.Notify then
    pcall(function()
      _G.Mhapi:Notify(tostring(title) .. " | " .. tostring(message), duration
        or 3)
    end)
  else
    pcall(function()
      AirflowUI:Notify({
        Title = title,
        Content = message,
        Icon = "bell",
        Type = kind or "Info",
        Duration = duration
          or 3,
      })
    end)
  end
end

-- ============================================================
-- FAST GUN + KILL AURA
-- ============================================================
function patchGun(gunStats)
  if type(gunStats)
    ~= "table" then
    return false
  else
    local didPatch = false

    if gunStats.ShootSpread then
      gunStats.ShootSpread = 0

      didPatch = true
    end

    if gunStats.ShootAccuracy then
      gunStats.ShootAccuracy = 0

      didPatch = true
    end

    if gunStats.ShootRecoil then
      gunStats.ShootRecoil = 0

      didPatch = true
    end

    if gunStats.ShootCooldown then
      gunStats.ShootCooldown = 0.001

      didPatch = true
    end

    if gunStats.ShootBurstCooldown then
      gunStats.ShootBurstCooldown = 0.001

      didPatch = true
    end

    return didPatch
  end
end

function patchEquippedGuns()
  local itemsOk, items = pcall(function()
    return require(ReplicatedStorage.Modules.ItemLibrary).Items
  end)

  if not itemsOk
    or type(items)
      ~= "table" then
    notify("Fast Gun", "ItemLibrary unavailable", "Error", 3)

    return false
  else
    local patchedCount = 0

    for key, itemData in pairs(items) do
      if not excludedGuns[key]
        and type(itemData) == "table" then
        if patchGun(itemData) then
          patchedCount = patchedCount + 1
        end
      end
    end

    fastGunState.primaryHits = patchedCount

    fastGunState.lastPatch = tick()

    notify("Fast Gun", string.format("patched %d guns", patchedCount), "Success", 3)

    return patchedCount > 0
  end
end

function fastGunTick()
  if fastGunState.primaryOn then
    pcall(patchEquippedGuns)
  end
end

function weaponSlotIndex()
  return weaponSlots[killAuraCfg.weaponSlot]
    or 1
end

weaponSlots = {
  Primary = 1,
  Secondary = 2,
  Melee = 3,
}

function startAutoEquip()
  if autoEquipThread then
    autoEquipThread:Disconnect()
  end

  autoEquipThread = task.spawn(function()
    while killAuraCfg.enabled
      and killAuraCfg.autoEquip do
      task.wait(1)

      if not killAuraCfg.enabled then
        break
      end

      if FighterController
        and FighterController.LocalFighter
        and FighterController.LocalFighter.EquippedItem
          == nil then
        pcall(function()
          FighterController.LocalFighter:EquipItem(weaponSlotIndex())
        end)
      end
    end
  end)
end

function getNpcTargets()
  local myCharacter = localPlayer.Character

  local myRoot = myCharacter
    and myCharacter:FindFirstChild("HumanoidRootPart")

  if not myRoot then
    return {}
  else
    local targets = {}

    for _, model in ipairs(workspace:GetDescendants()) do
      if model:IsA("Model")
        and model ~= myCharacter then
        local npcRoot = model:FindFirstChild("HumanoidRootPart")

        local npcHead = model:FindFirstChild("Head")
        local isValidNpc = npcRoot

        local npcHumanoid = model:FindFirstChildWhichIsA("Humanoid")

        if npcRoot then
          isValidNpc = npcHead
            and npcHumanoid
            and npcHumanoid.Health
              > 0
        end

        if isValidNpc then
          if not (Players:GetPlayerFromCharacter(model) ~= nil) then
            local distance = (myRoot.Position
              - npcRoot.Position).Magnitude

            if distance
              <= killAuraCfg.radius then
              table.insert(targets, {
                model = model,
                root = npcRoot,
                head = npcHead,
                dist = distance,
              })
            end
          end
        end
      end
    end

    table.sort(targets, function(a, b)
      return a.dist
        < b.dist
    end)

    return targets
  end
end

function stopAutoEquip()
  if autoEquipThread then
    task.cancel(autoEquipThread)
    autoEquipThread = nil
  end
end

function killAuraStep()
  local shouldSkip = not killAuraCfg.enabled
    or not Utility or not EnumLibrary or not FighterController

  local fighter, shotPayload

  if shouldSkip then
    return
  elseif tick() - lastShotTime
    < killAuraCfg.fireRate then
    return
  else
    local npcList = getNpcTargets()

    if #npcList == 0 then
      return
    else
      local char = localPlayer.Character

      if not char
        or not char:FindFirstChild("HumanoidRootPart") then
        return
      end

      fighter = FighterController.LocalFighter

      if not fighter
        or not fighter.EquippedItem then
        return
      else
        local targetHead = npcList[1].head
        local vector3 = Vector3

        local headPos = targetHead.Position

        local newVector3 = vector3.new
        local aimOffset = newVector3(0, killAuraCfg.headshotOffset, 0)

        local aimCFrame = CFrame.lookAt(headPos
          + aimOffset, headPos)

        local headCFrame = targetHead.CFrame

        local newVector3B = Vector3.new

        local randX = math.random()

        local jitterX = killAuraCfg.jitter

        local randY = math.random()

        local jitterY = killAuraCfg.jitter

        local randZ = math.random()

        local jitterZ = killAuraCfg.jitter

        local jitterVec = newVector3B(
          (randX - 0.5) * jitterX, (randY - 0.5) * jitterY, (randZ - 0.5) * jitterZ
        )

        local hitOffset = targetHead.CFrame:ToObjectSpace(CFrame.new(headPos
          + jitterVec))

        shotPayload = {}
        local utilA = Utility
        local utilB = Utility
        local utilC = Utility

        shotPayload[utf8.char(1)] = {
          [utf8.char(0)] = utilA:EncodeCFrame(aimCFrame),
          [utf8.char(1)] = utilB:EncodeCFrame(headCFrame),
          [utf8.char(2)] = targetHead,
          [utf8.char(3)] = utilC:EncodeCFrame(hitOffset),
        }

        pcall(function()
          local useItemRemote = ReplicatedStorage.Remotes.Replication.Fighter.UseItem

          local equippedItem = fighter.EquippedItem

          local enums = EnumLibrary

          useItemRemote:FireServer(equippedItem:Get("ObjectID"), enums:ToEnum("StartShooting"), shotPayload, nil)
        end)

        lastShotTime = tick()
        return
      end
    end
  end
end

function disableKillAura()
  if killAuraConn then
    killAuraConn:Disconnect()
    killAuraConn = nil
  end

  stopAutoEquip()

  notify("Kill Aura", "Ka deactivated", "Warning", 3)
end

function nearestPlayerRoot()
  if not rootPart then
    return nil
  else
    local nearestPlayer = nil
    local nearestDist = math.huge

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
      if otherPlayer == localPlayer
        or not otherPlayer.Character then
      else
        local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")

        if not otherRoot then
        else
          local dist = (rootPart.Position
            - otherRoot.Position).Magnitude

          if dist < nearestDist then
            nearestDist = dist
            nearestPlayer = otherPlayer
          end
        end
      end
    end

    return nearestPlayer
  end
end

function enableKillAura()
  if killAuraConn then
    killAuraConn:Disconnect()
  end

  if killAuraCfg.autoEquip then
    startAutoEquip()
  end

  killAuraConn = RunService.Heartbeat:Connect(killAuraStep)

  notify("Kill Aura", "Ka activated", "Success", 3)
end

-- ============================================================
-- TARGETING HELPERS (velocity tracking, player scoring)
-- ============================================================
function getHead(player)
  if not player
    or not player.Character then
    return nil
  end

  return player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("CameraBone", true) or player.Character:FindFirstChild("HumanoidRootPart")
end

velTrackers = {}

function getTracker(player)
  if not velTrackers[player] then
    velTrackers[player] = {
      vel = Vector3.zero,
      accel = Vector3.zero,
      lastPos = nil,
      lastVel = Vector3.zero,
      lastT = tick(),
    }
  end

  return velTrackers[player]
end

function sidestepDirection(attackerPos, myPos)
  local offset = Vector3.new(attackerPos.X - myPos.X, 0, attackerPos.Z - myPos.Z)

  if offset.Magnitude
    < 0.01 then
    offset = Vector3.new(1, 0, 0)
  end

  local dir = offset.Unit

  local perpLeft = Vector3.new(-dir.Z, 0, dir.X)

  local perpRight = Vector3.new(dir.Z, 0, -dir.X)

  return (math.random(
    0, 1
  ) == 0 and perpLeft or perpRight) + Vector3.new(
    0,
    (math.random() - 0.5) * 0.4,
    0
  )
end

function scorePlayers(myPosition)
  local scores = {}

  if not myPosition then
    return scores
  end

  for _, otherPlayer in ipairs(Players:GetPlayers()) do
    if otherPlayer == localPlayer
      or not otherPlayer.Character then
    else
      local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")

      if not otherRoot then
      else
        local heldTool = otherPlayer.Character:FindFirstChildOfClass("Tool")

        local originPart = getHead(otherPlayer) or otherRoot

        local lookVec = originPart.CFrame.LookVector

        local toMe = myPosition
          - (originPart.Position
            + lookVec * 0.5)

        local distToMe = toMe.Magnitude

        if distToMe < 0.01 then
        else
          local tracker = updateTracker(otherPlayer, otherRoot)

          local dot = lookVec:Dot(toMe.Unit)

          local aimFactor = math.max(0, dot)
          local proximityFactor = math.max(0, 1 - distToMe / 250)

          scores[otherPlayer] = {
            hrp = otherRoot,
            dist = distToMe,
            aimDot = dot,
            score = aimFactor
                * 45
              + (heldTool and 25 or 0)
              + proximityFactor * 30,
            hasTool = heldTool
              ~= nil,
            origin = originPart,
            trk = tracker,
          }
        end
      end
    end
  end

  return scores
end

function updateTracker(player, targetRoot)
  local tracker = getTracker(player)
  local now = tick()

  local dt = now
    - tracker.lastT

  if dt > 0.01 then
    local pos = targetRoot.Position

    local velocity = targetRoot.AssemblyLinearVelocity

    if tracker.lastPos
      and tracker.lastVel then
      local oldAccel = tracker.accel

      tracker.accel = oldAccel:Lerp((velocity - tracker.lastVel)
        / dt, 0.2)
    end

    tracker.vel = velocity
    tracker.lastPos = pos
    tracker.lastVel = velocity
    tracker.lastT = now
  end

  return tracker
end

-- ============================================================
-- VOID
-- ============================================================
voidState = {
  t = 0,
  pos = Vector3.zero,
  vel = Vector3.zero,
  phase = 0,
  seed = os.clock(),
  anchor = Vector3.zero,
}

voidPhaseTime = 0
voidBaitPhase = false

function randomRange(minValue, maxValue)
  return minValue
    + math.random()
      * (maxValue - minValue)
end

function sanitizeVector(vec)
  if not vec
    or typeof(vec)
      ~= "Vector3" then
    return vec
  else
    local z = vec.Z
    local y = vec.Y
    local x = vec.X

    if x ~= x or x == math.huge
      or x == -math.huge then
      x = voidCfg.BASE_X
    end

    if y ~= y
      or y
        == math.huge
      or y == -math.huge then
      y = 0
    end

    if z ~= z
      or z == math.huge
      or z
        == -math.huge then
      z = voidCfg.BASE_Z
    end

    local clampedY = math.clamp(y, voidCfg.VOID_Y_MIN, voidCfg.VOID_Y_MAX)

    local maxRadius = math.abs(voidCfg.RADIUS)

    if maxRadius > 0 then
      local dx = x
        - voidCfg.BASE_X

      local dz = z
        - voidCfg.BASE_Z

      local distXZ = math.sqrt(dx * dx
        + dz * dz)

      if distXZ > maxRadius and distXZ > 0 then
        local shrink = maxRadius / distXZ

        x = voidCfg.BASE_X
          + dx * shrink

        z = voidCfg.BASE_Z
          + dz * shrink
      end
    end

    return Vector3.new(x, clampedY, z)
  end
end

function voidTarget(dt)
  if voidCfg.VOID_METHOD
    == "Freeze Bait" then
    voidPhaseTime = voidPhaseTime + dt

    if voidBaitPhase then
      if voidPhaseTime
        >= voidCfg.VOID_BAIT_DURATION then
        voidBaitPhase = false
        voidPhaseTime = 0
      else
        local selfRoot = getRoot()

        return selfRoot
            and selfRoot.Position
          or Vector3.zero
      end
    elseif voidPhaseTime
      >= voidCfg.VOID_BAIT_INTERVAL then
      voidBaitPhase = true
      voidPhaseTime = 0
      local selfRoot = getRoot()

      return selfRoot
          and selfRoot.Position
        or Vector3.zero
    end

    local radius = voidCfg.RADIUS

    return sanitizeVector(Vector3.new(voidCfg.BASE_X + randomRange(-radius, radius), randomRange(voidCfg.VOID_Y_MIN, voidCfg.VOID_Y_MAX), voidCfg.BASE_Z + randomRange(-radius, radius)))
  elseif voidCfg.VOID_METHOD
    == "Attacker" then
    voidPhaseTime = voidPhaseTime + dt

    if voidBaitPhase then
      if voidPhaseTime
        >= voidCfg.VOID_ATTACKER_DURATION then
        voidBaitPhase = false
        voidPhaseTime = 0
      else
        local nearestPlr = nearestPlayerRoot()

        if nearestPlr
          and nearestPlr.Character then
          local nearestRoot = nearestPlr.Character:FindFirstChild("HumanoidRootPart")

          if nearestRoot then
            return nearestRoot.Position
          end
        end
      end
    elseif voidPhaseTime
      >= voidCfg.VOID_ATTACKER_INTERVAL then
      voidBaitPhase = true
      voidPhaseTime = 0
      local nearestPlr = nearestPlayerRoot()

      if nearestPlr
        and nearestPlr.Character then
        local nearestRoot = nearestPlr.Character:FindFirstChild("HumanoidRootPart")

        if nearestRoot then
          return nearestRoot.Position
        end
      end
    end

    local radius = voidCfg.RADIUS

    return sanitizeVector(Vector3.new(voidCfg.BASE_X + randomRange(-radius, radius), randomRange(voidCfg.VOID_Y_MIN, voidCfg.VOID_Y_MAX), voidCfg.BASE_Z + randomRange(-radius, radius)))
  elseif voidCfg.VOID_METHOD
    == "Chaos" then
    return Vector3.new(voidCfg.BASE_X + randomRange(
      -VOID_CHAOS_MAX, VOID_CHAOS_MAX -- BUG (from original): global never set
    ), randomRange(voidCfg.VOID_Y_MIN, voidCfg.VOID_Y_MAX), voidCfg.BASE_Z + randomRange(
      -VOID_CHAOS_MAX, VOID_CHAOS_MAX -- BUG (from original): global never set
    ))
  else
    local radius = voidCfg.RADIUS

    return Vector3.new(voidCfg.BASE_X
      + randomRange(-radius, radius), randomRange(voidCfg.VOID_Y_MIN, voidCfg.VOID_Y_MAX), voidCfg.BASE_Z
      + randomRange(-radius, radius))
  end
end

function voidStep(dt)
  voidState.t = voidState.t + dt
  local root = getRoot()

  if not root then
    return
  end

  local targetPos = voidTarget(dt)

  if not targetPos then
    return
  end

  pcall(function()
    root.CFrame = CFrame.new(targetPos)

    root.AssemblyLinearVelocity = Vector3.zero

    root.AssemblyAngularVelocity = Vector3.zero
  end)
end

function enableVoid()
  disconnectConn("void")

  voidState.t = 0
  voidState.phase = 0

  voidState.vel = Vector3.zero

  voidPhaseTime = 0
  voidBaitPhase = false
  local root = getRoot()

  if root then
    voidState.pos = root.Position

    voidState.anchor = root.Position

    pcall(function()
      root:SetNetworkOwner(localPlayer)
    end)
  end

  connections.void = (RunService.PreSimulation
    or RunService.Heartbeat):Connect(function(dt)
    if not voidCfg.VOID_ENABLED then
      disconnectConn("void")
      return
    end

    if voidCfg.VOID_DURATION_ENABLED
      and tick() - voidState.t
        > voidCfg.VOID_DURATION then
      voidCfg.VOID_ENABLED = false

      notify("Void", "duration reached", "Warning", 2)

      return
    end

    voidStep(dt)
  end)
end

function disableVoid()
  disconnectConn("void")

  voidCfg.VOID_ENABLED = false

  voidBaitPhase = false
  voidPhaseTime = 0
end

-- ============================================================
-- WIREFRAME ESP
-- ============================================================
function enableWireframes()
  if not wireframeFolder then
    wireframeFolder = Instance.new("Folder")

    wireframeFolder.Name = "RCLC_Wireframes"

    wireframeFolder.Parent = game:GetService("CoreGui")
  end

  local function addWireframeBox(part)
    if wireframeBoxes[part] then
      return
    else
      local box = Instance.new("BoxHandleAdornment")

      box.Name = "RCLC_Box"

      box.Adornee = part

      box.AlwaysOnTop = true

      box.ZIndex = 10

      box.Size = Vector3.new(
        4, 6, 4
      )

      box.Transparency = 0.5

      box.Color3 = Color3.fromRGB(
        168, 85, 247
      )

      box.Parent = wireframeFolder

      wireframeBoxes[part] = box
      return
    end
  end

  for _, otherPlayer in ipairs(Players:GetPlayers()) do
    if otherPlayer == localPlayer
      or not otherPlayer.Character then
    else
      local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")

      if otherRoot then
        addWireframeBox(otherRoot)
      end
    end
  end

  local playerAdded = Players.PlayerAdded

  connections.wireframe = playerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
      task.wait(0.5)

      if voidCfg.WIREFRAME_ENABLED then
        local charRoot = char:FindFirstChild("HumanoidRootPart")

        if charRoot then
          addWireframeBox(charRoot)
        end
      end
    end)
  end)
end

function disableWireframes()
  if wireframeFolder then
    wireframeFolder:Destroy()
    wireframeFolder = nil
  end

  wireframeBoxes = {}

  if connections.wireframe then
    connections.wireframe:Disconnect()

    connections.wireframe = nil
  end
end

wireframeFolder = nil
wireframeBoxes = {}

function setWireframes(state)
  voidCfg.WIREFRAME_ENABLED = state

  if state then
    enableWireframes()
  else
    disableWireframes()
  end
end

-- ============================================================
-- ORBIT
-- ============================================================
function disableOrbit()
  disconnectConn("orbit")

  orbitCfg.orbitEnabled = false

  if humanoid then
    pcall(function()
      local hum = humanoid

      hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end)
  end
end

orbitAngle = 0

function enableOrbit()
  disconnectConn("orbit")
  orbitAngle = 0

  if humanoid then
    pcall(function()
      local hum = humanoid

      hum:ChangeState(Enum.HumanoidStateType.Physics)
    end)
  end

  local heartbeat = RunService.Heartbeat

  connections.orbit = heartbeat:Connect(function(dt)
    local center, orbitPos

    if not orbitCfg.orbitEnabled then
      disconnectConn("orbit")
      return
    elseif not rootPart then
      return
    else
      if humanoid then
        pcall(function()
          local hum = humanoid

          if hum:GetState()
            ~= Enum.HumanoidStateType.Physics then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
          end
        end)
      end

      local nearestPlr = nearestPlayerRoot()

      center = rootPart.Position

      if nearestPlr
        and nearestPlr.Character then
        local nearestRoot = nearestPlr.Character:FindFirstChild("HumanoidRootPart")

        if nearestRoot
          and (rootPart.Position
              - nearestRoot.Position).Magnitude
            <= orbitCfg.orbitLockDist then
          center = nearestRoot.Position
        end
      end

      orbitAngle = (orbitAngle + math.rad(orbitCfg.orbitSpeed) * (orbitCfg.orbitMode == "Counter-Clockwise" and -1 or 1) * dt) % (2 * math.pi)

      local radius = orbitCfg.orbitDist

      local cosA = math.cos(orbitAngle)
      local sinA = math.sin(orbitAngle)

      orbitPos = center + Vector3.new(
        cosA * radius, orbitCfg.orbitHeight,
        sinA * radius
      )

      pcall(function()
        rootPart.CFrame = CFrame.new(orbitPos, Vector3.new(center.X, orbitPos.Y, center.Z))

        rootPart.AssemblyLinearVelocity = Vector3.zero

        rootPart.AssemblyAngularVelocity = Vector3.zero
      end)

      return
    end
  end)
end

-- ============================================================
-- PREDICTION (DODGING)
-- ============================================================
lastPredFire = 0
lastToolUse = {}
hookedTools = {}
hookedToolCount = 0

function disablePrediction()
  disconnectConn("pred")

  predictCfg.predEnabled = false
end

function hookAllPlayerTools()
  for _, otherPlayer in ipairs(Players:GetPlayers()) do
    if otherPlayer == localPlayer
      or not otherPlayer.Character then
    else
      local tool = otherPlayer.Character:FindFirstChildOfClass("Tool")

      if tool then
        hookToolActivate(tool)
      end

      otherPlayer.Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
          hookToolActivate(child)
        end
      end)
    end
  end
end

function hookToolActivate(tool)
  if not tool or hookedTools[tool] or hookedToolCount >= 64 then
    return
  end

  hookedTools[tool] = true
  hookedToolCount = hookedToolCount + 1

  pcall(function()
    hookfunction(tool.Activate, function(selfArg)
      if not checkcaller() and selfArg == tool then
        local owner = tool.Parent
          and tool.Parent.Parent

        if owner
          and owner ~= localPlayer
          and owner.Character then
          lastToolUse[owner] = tick()
        end
      end

      -- BUG (from original): `old` and `v346` are never defined, so this line errors when a hooked Tool:Activate runs
      return old(selfArg, unpack(v346))
    end)
  end)
end

function enablePrediction()
  disconnectConn("pred")
  hookAllPlayerTools()

  local heartbeat = RunService.Heartbeat

  connections.pred = heartbeat:Connect(function(dt)
    if not predictCfg.predEnabled then
      disconnectConn("pred")
      return
    end

    local dodgeVec, sideDir, sidePos, dodgePos

    if not rootPart
      or humanoid
        and humanoid.Health
          <= 0 then
      return
    else
      local myPos = rootPart.Position

      local myVel = rootPart.AssemblyLinearVelocity

      local now = tick()
      local bestThreat = nil
      local bestScore = 0

      for plr, info in pairs((scorePlayers(myPos))) do
        if info.score
          > bestScore then
          bestScore = info.score

          bestThreat = {
            p = plr,
            d = info,
          }
        end
      end

      if not bestThreat then
        return
      else
        local infiniteRange = predictCfg.predInfiniteRange
          and 5000000000000

        local maxRange = infiniteRange

        maxRange = infiniteRange
          or predictCfg.predRadius

        if bestThreat.d.dist
          > maxRange then
          return
        elseif now - lastPredFire
          < predictCfg.predCooldown then
          return
        else
          local threatened = false

          if lastToolUse[bestThreat.p]
              and now - lastToolUse[bestThreat.p]
                < predictCfg.predReactionTime
            or bestThreat.d.aimDot
              > predictCfg.predAimThreshold then
            threatened = true

            if predictCfg.predPredictive
              and bestThreat.d.trk
              and bestThreat.d.trk.vel then
              local trk = bestThreat.d.trk
              local foundDodge = false
              dodgeVec = Vector3.zero
              local step = 0

              while true do
                step = 1 + step

                if not (10 >= step) then
                  break
                end

                local t = predictCfg.predLookahead
                    / 10
                  * step

                local myFuturePos = myPos + myVel * t

                local enemyFuturePos = trk.lastPos
                  + trk.vel * t
                  + 0.5
                    * trk.accel
                    * t ^ 2

                if math.abs((myFuturePos - enemyFuturePos).Magnitude
                      / predictCfg.predBulletSpeed
                    - t)
                  < 0.15 then
                  foundDodge = true

                  local dirToMe = (myFuturePos - enemyFuturePos).Unit

                  local perpA = Vector3.new(-dirToMe.Z, 0, dirToMe.X)

                  local perpB = Vector3.new(dirToMe.Z, 0, -dirToMe.X)

                  dodgeVec = ((math.random(
                    0, 1
                  ) == 0 and 1 or -1) == 1 and perpA or perpB).Unit * predictCfg.predDodgeDist

                  break
                end
              end

              if foundDodge
                and dodgeVec.Magnitude
                  > 0 then
                dodgePos = myPos + dodgeVec + Vector3.new(0, (math.random() - 0.5) * 15, 0)

                if frameBudgetOk() then
                  pcall(function()
                    rootPart.CFrame = CFrame.new(dodgePos)

                    rootPart.AssemblyLinearVelocity = dodgeVec.Unit * 150
                  end)
                end

                lastPredFire = now
                return
              end
            end
          end

          if threatened
            and predictCfg.predKinematic then
            lastPredFire = now

            sideDir = sidestepDirection(bestThreat.d.hrp.Position, myPos)

            sidePos = myPos
              + sideDir
                * predictCfg.predDodgeDist

            if frameBudgetOk() then
              pcall(function()
                rootPart.CFrame = CFrame.new(sidePos + Vector3.new((math.random() - 0.5) * 4, 0, (math.random() - 0.5) * 4))

                rootPart.AssemblyLinearVelocity = sideDir
                  * 150
              end)
            end
          end

          return
        end
      end
    end
  end)
end

-- ============================================================
-- UNDERGROUND ANTI-AIM + CHAOS ANTI-AIM
-- ============================================================
function enableUndergroundAA()
  if undergroundConn then
    undergroundConn:Disconnect()
  end

  undergroundAngle = 0

  if rootPart and character then
    local torso = character:FindFirstChild("UpperTorso")
      or character:FindFirstChild("Torso")

    local head = character:FindFirstChild("Head")

    if torso and head then
      local neck = head:FindFirstChild("Neck") or character:FindFirstChild("Neck")

      if neck
        and neck:IsA("Motor6D") then
        savedRootJointC0 = neck.C0

        neck.C0 = CFrame.new(
          0, 0, 0
        ) * CFrame.Angles(math.rad(-90), 0, 0)
      end
    end
  end

  undergroundConn = RunService.Heartbeat:Connect(function(dt)
    if not undergroundCfg.enabled then
      return
    end

    local root = getRoot()
    local undergroundPos, spinDeg

    if not root then
      return
    else
      undergroundAngle = (undergroundAngle + math.rad(undergroundCfg.orbitSpeed) * dt) % (2 * math.pi)

      local cosA = math.cos(undergroundAngle)
      local sinA = math.sin(undergroundAngle)

      undergroundPos = root.Position + Vector3.new(cosA * undergroundCfg.orbitRadius, -undergroundCfg.depth, sinA * undergroundCfg.orbitRadius)

      if root.Position.Y
          - undergroundPos.Y
        > undergroundCfg.depth
          + 1 then
        undergroundPos = Vector3.new(undergroundPos.X, root.Position.Y
          - undergroundCfg.depth, undergroundPos.Z)
      end

      local now = tick()
      spinDeg = now * undergroundCfg.spinSpeed % 360

      pcall(function()
        root.CFrame = CFrame.new(undergroundPos) * CFrame.Angles(0, math.rad(spinDeg), 0)

        root.AssemblyLinearVelocity = Vector3.zero

        root.AssemblyAngularVelocity = Vector3.zero
      end)

      return
    end
  end)

  notify("Underground AA", "Activated", "Success", 3)
end

function enableAntiAim()
  disconnectConn("antiAim")
  local heartbeat = RunService.Heartbeat

  connections.antiAim = heartbeat:Connect(function(dt)
    if not antiAimCfg.enabled then
      disconnectConn("antiAim")

      return
    elseif not rootPart then
      return
    else
      local chaos = antiAimCfg.chaosLevel
        * 0.01

      local pitchMax = math.rad(antiAimCfg.pitch)
      local yawMax = math.rad(antiAimCfg.yaw)
      local randPitch = math.random()
      local randYaw = math.random()

      local speedScale = antiAimCfg.speed
        / 5000

      local randRoll = math.random()
      local fullTurn = math.rad(360)

      rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(
        (randPitch - 0.5) * 2 * pitchMax * chaos * speedScale, (randYaw - 0.5) * 2 * yawMax * chaos * speedScale,
        (randRoll - 0.5) * fullTurn * chaos * speedScale
      )

      return
    end
  end)
end

function disableAntiAim()
  disconnectConn("antiAim")

  antiAimCfg.enabled = false
end

function disableUndergroundAA()
  if undergroundConn then
    undergroundConn:Disconnect()
    undergroundConn = nil
  end

  if rootPart and character and savedRootJointC0 then
    local torso = character:FindFirstChild("UpperTorso")
      or character:FindFirstChild("Torso")

    local head = character:FindFirstChild("Head")

    if torso and head then
      local neck = head:FindFirstChild("Neck") or character:FindFirstChild("Neck")

      if neck
        and neck:IsA("Motor6D") then
        neck.C0 = savedRootJointC0
      end
    end
  end

  notify("Underground AA", "Deactivated", "Warning", 3)
end

-- ============================================================
-- TRANSLOCATION
-- ============================================================
translocConn = nil

function enableTransloc()
  if translocConn then
    translocConn:Disconnect()
  end

  translocTimer = 0

  translocConn = RunService.Heartbeat:Connect(function(dt)
    if not translocCfg.enabled then
      stopTransloc() -- BUG (from original): never defined
      return
    elseif not rootPart then
      return
    else
      translocTimer = translocTimer + dt

      local interval = 1 / math.max(translocCfg.frequency, 1)

      local iterations = 1

      if interval < dt then
        iterations = math.floor(dt
          / interval)

        if iterations < 1 then
          iterations = 1
        end

        if iterations > 50 then
          iterations = 50
        end
      end

      if translocTimer >= interval then
        translocTimer = translocTimer % interval

        local origin = rootPart.Position

        local getrawmetatable = getrawmetatable

        local meta = getrawmetatable
        meta = getrawmetatable and getrawmetatable(rootPart)

        local rawNewIndex = meta

        rawNewIndex = meta and rawget(
          meta,
          "__newindex"
        )

        for k = 1, iterations do
          local randX = math.random()
          local randY = math.random()

          local fakeCFrame = CFrame.new(origin.X
            + (randX * 2 - 1) * translocCfg.jitterX, origin.Y
            + (randY * 2 - 1) * translocCfg.jitterY, translocCfg.fixedZ)

          local fakeVel = Vector3.zero

          if translocCfg.fakeVel then
            local mag = translocCfg.fakeVelMag

            fakeVel = Vector3.new((math.random() - 0.5) * mag * 2, (math.random() - 0.5) * mag * 2, (math.random() - 0.5) * mag * 2)
          end

          if rawNewIndex then
            pcall(rawNewIndex, rootPart, "CFrame", fakeCFrame)

            pcall(rawNewIndex, rootPart, "AssemblyLinearVelocity", fakeVel)
          else
            pcall(function()
              rootPart.CFrame = fakeCFrame

              rootPart.AssemblyLinearVelocity = fakeVel
            end)
          end
        end
      end

      return
    end
  end)
end

translocTimer = 0

function disableTransloc()
  if translocConn then
    translocConn:Disconnect()
    translocConn = nil
  end

  translocCfg.enabled = false
end

-- ============================================================
-- FAKE POSITION
-- ============================================================
fakePosHeartbeat = nil
fakePosRender = nil
fakePosAnchor = nil
fakePosAngle = 0
fakePosHue = 0

function enableFakePos()
  if fakePosHeartbeat then
    fakePosHeartbeat:Disconnect()
  end

  if fakePosRender then
    fakePosRender:Disconnect()
  end

  fakePosAnchor = nil
  fakePosAngle = 0
  fakePosHue = 0
  fakePosLastWrite = 0
  fakePosTime = 0

  fakePosHeartbeat = RunService.Heartbeat:Connect(function(dt)
    if not fakePosCfg.enabled
      or not rootPart then
      return
    else
      fakePosAnchor = rootPart.CFrame

      fakePosTime = fakePosTime + dt
      local now = tick()

      local rateOverride = fakePosCfg.randomizeEveryFrame
        and 99999

      local writeRate = rateOverride

      writeRate = rateOverride or math.max(
        fakePosCfg.speed, 1
      )

      if now - fakePosLastWrite < 1 / writeRate then
        return
      else
        fakePosLastWrite = now
        local getrawmetatable = getrawmetatable

        local meta = getrawmetatable
        meta = getrawmetatable and getrawmetatable(rootPart)

        local rawNewIndex = meta

        rawNewIndex = meta and rawget(
          meta,
          "__newindex"
        )

        local radius = math.max(fakePosCfg.radius, 1)

        if fakePosCfg.pulseRadius then
          radius = fakePosCfg.pulseRadiusMin + (math.sin(fakePosTime * fakePosCfg.pulseSpeed * 2 * math.pi) * 0.5 + 0.5) * (fakePosCfg.pulseRadiusMax - fakePosCfg.pulseRadiusMin)
        end

        local layers = fakePosCfg.layeredFake
            and fakePosCfg.layerCount
          or 1

        local layer = 0

        while true do
          layer = 1 + layer

          if not (layer <= layers) then
            break
          end

          local offX = 0
          local offY = 0
          local offZ = 0
          local layerRadius = radius * (layer / layers)

          if fakePosCfg.chaosMode then
            layerRadius = layerRadius
              * (1
                + (math.random()
                    - 0.5)
                  * fakePosCfg.chaosMult)
          end

          if fakePosCfg.pattern
            == "Scatter" then
            local scatterRad = math.rad(fakePosCfg.scatterAngle)

            local angle = (math.random()
                - 0.5)
              * scatterRad

            offX = math.cos(angle)
              * (math.random()
                * layerRadius)

            offY = fakePosCfg.height
              + math.random()
                * fakePosCfg.yDist

            offZ = math.sin(angle)
              * (math.random()
                * layerRadius)
          elseif fakePosCfg.pattern
            == "Linear" then
            fakePosHue = fakePosHue + 0.05
            local t = fakePosHue % 1
            offX = (t - 0.5) * 2 * layerRadius

            offY = fakePosCfg.height
              + math.random()
                * fakePosCfg.yDist

            offZ = (t - 0.5) * 2 * layerRadius
          elseif fakePosCfg.pattern
            == "Circle" then
            fakePosAngle = (fakePosAngle
                + math.rad(fakePosCfg.speed
                  * dt
                  * 60))
              % (2 * math.pi)

            offX = math.cos(fakePosAngle)
              * layerRadius

            offY = fakePosCfg.height
              + math.random()
                * fakePosCfg.yDist

            offZ = math.sin(fakePosAngle)
              * layerRadius
          elseif fakePosCfg.pattern
            == "Random" then
            offX = (math.random()
                  * 2
                - 1)
              * layerRadius

            offY = fakePosCfg.height
              + math.random()
                * fakePosCfg.yDist

            offZ = (math.random()
                  * 2
                - 1)
              * layerRadius
          elseif fakePosCfg.pattern
            == "Spiral" then
            fakePosAngle = (fakePosAngle + math.rad(fakePosCfg.speed * dt * 60)) % (2 * math.pi)

            local spiralRadius = layerRadius
              * (0.3
                + 0.7 * (fakePosAngle / (2 * math.pi) % 1))

            offX = math.cos(fakePosAngle)
              * spiralRadius

            offY = fakePosCfg.height
              + math.random()
                * fakePosCfg.yDist

            offZ = math.sin(fakePosAngle) * spiralRadius
          end

          if fakePosCfg.distribution
            == "Uniform" then
            local len = math.sqrt(offX * offX
              + offZ * offZ)

            if len > 0 then
              local scale = layerRadius / len
              offX = offX * scale
              offZ = offZ * scale
            end
          elseif fakePosCfg.distribution
            == "Weighted" then
            offX = offX * 0.6
            offZ = offZ * 0.6
          elseif fakePosCfg.distribution
            == "Radial" then
            local ang = math.atan2(
              offZ, offX
            )

            offX = math.cos(ang) * layerRadius
            offZ = math.sin(ang) * layerRadius
          elseif fakePosCfg.distribution
            == "Clustered" then
            local octant = math.floor(math.random() * 8) * (math.pi * 0.25)

            offX = math.cos(octant) * layerRadius
            offZ = math.sin(octant) * layerRadius
          end

          if fakePosCfg.axisLock
            == "X" then
            offZ = 0

            offY = fakePosCfg.height
          elseif fakePosCfg.axisLock
            == "Y" then
            offX = 0
            offZ = 0
          elseif fakePosCfg.axisLock
            == "Z" then
            offX = 0

            offY = fakePosCfg.height
          elseif fakePosCfg.axisLock
            == "XZ" then
            offY = fakePosCfg.height
          end

          local fakePos = fakePosAnchor + Vector3.new(
            offX, offY, offZ
          )

          if rawNewIndex then
            pcall(rawNewIndex, rootPart, "AssemblyLinearVelocity", Vector3.zero)

            pcall(rawNewIndex, rootPart, "CFrame", fakePos)

            pcall(rawNewIndex, rootPart, "AssemblyLinearVelocity", Vector3.zero)
          else
            pcall(function()
              rootPart.AssemblyLinearVelocity = Vector3.zero

              rootPart.CFrame = fakePos

              rootPart.AssemblyLinearVelocity = Vector3.zero
            end)
          end
        end

        return
      end
    end
  end)

  fakePosRender = RunService.RenderStepped:Connect(function()
    if fakePosCfg.enabled
      and rootPart
      and fakePosAnchor then
      rootPart.CFrame = fakePosAnchor

      rootPart.AssemblyLinearVelocity = Vector3.zero

      rootPart.AssemblyAngularVelocity = Vector3.zero
    end
  end)
end

function disableFakePos()
  if fakePosHeartbeat then
    fakePosHeartbeat:Disconnect()
    fakePosHeartbeat = nil
  end

  if fakePosRender then
    fakePosRender:Disconnect()
    fakePosRender = nil
  end

  fakePosAnchor = nil
  fakePosCfg.enabled = false
end

fakePosLastWrite = 0
fakePosTime = 0
-- ============================================================
-- VELOCITY DESYNC
-- ============================================================
velDesyncConn = nil
velDesyncConn2 = nil
desyncSavedVel = nil
desyncAngle = 0
desyncFlipTimer = 0
desyncOscTime = 0
desyncBurstTimer = 0

function enableVelDesync()
  if velDesyncConn then
    velDesyncConn:Disconnect()
  end

  if velDesyncConn2 then
    velDesyncConn2:Disconnect()
  end

  desyncSavedVel = nil
  desyncAngle = 0
  desyncFlipTimer = 0
  desyncOscTime = 0
  desyncBurstTimer = 0
  desyncFlipState = false

  velDesyncConn = RunService.Heartbeat:Connect(function(dt)
    local root = getRoot()

    if not velDesyncCfg.enabled
      or not root then
      return
    else
      desyncSavedVel = root.AssemblyLinearVelocity

      desyncFlipTimer = desyncFlipTimer + dt
      desyncBurstTimer = desyncBurstTimer + dt
      desyncOscTime = desyncOscTime + dt

      if velDesyncCfg.invertOnTimer
        and desyncFlipTimer
          >= velDesyncCfg.invertInterval then
        desyncFlipTimer = 0
        desyncFlipState = not desyncFlipState
      end

      local sign = (velDesyncCfg.flip or desyncFlipState) and -1 or 1

      local speed = math.clamp(
        velDesyncCfg.speed, 1, 100
      )

      desyncAngle = (desyncAngle + math.rad(speed * dt * 360))
        % (2 * math.pi)

      local randomizeAngle = velDesyncCfg.randomizeAngle

      local randomAngle = randomizeAngle

      randomAngle = randomizeAngle and math.rad(velDesyncCfg.angleMin + math.random() * (velDesyncCfg.angleMax - velDesyncCfg.angleMin))

      local baseAngle = randomAngle

      baseAngle = randomAngle
        or math.rad(velDesyncCfg.angle)

      local jitterDeg = math.clamp(velDesyncCfg.jitter, 0, 180)

      local angle = baseAngle + math.rad((math.random() - 0.5) * jitterDeg * 2) + desyncAngle

      if velDesyncCfg.oscillate then
        angle = angle + math.rad(math.sin(desyncOscTime * velDesyncCfg.oscillateFreq * 2 * math.pi) * velDesyncCfg.oscillateAmp)
      end

      if velDesyncCfg.rotateVel then
        angle = angle
          + math.rad(velDesyncCfg.rotateVelSpeed)
            * dt
      end

      local magnitude = math.clamp(velDesyncCfg.intensity, 1, 100) / 100 * 50000

      if velDesyncCfg.spikeMode
        and desyncBurstTimer
          >= velDesyncCfg.spikeInterval then
        desyncBurstTimer = 0

        magnitude = magnitude
          + velDesyncCfg.spikeMag
      end

      if velDesyncCfg.burstDesync
        and desyncBurstTimer
          >= velDesyncCfg.burstEvery then
        magnitude = magnitude
          + velDesyncCfg.burstMag
      end

      local noiseZ = 0
      local noiseX = 0

      if velDesyncCfg.noiseVel then
        local noiseT = tick()
          * velDesyncCfg.noiseScale

        noiseX = math.noise(
          noiseT, 0, 0
        ) * magnitude * 0.5

        noiseZ = math.noise(
          0, noiseT, 0
        ) * magnitude * 0.5
      end

      local velocities = {}

      local vectorCount = velDesyncCfg.multiVector
          and velDesyncCfg.vectorCount
        or 1

      local vecIndex = 0

      while true do
        vecIndex = 1 + vecIndex

        if not (vecIndex <= vectorCount) then
          break
        end

        local vecAngle = angle
          + (vecIndex - 1) * (2 * math.pi / vectorCount)

        table.insert(velocities, Vector3.new(math.cos(vecAngle) * magnitude * sign + noiseX, (math.random() - 0.5) * magnitude * 0.5, math.sin(vecAngle) * magnitude * sign + noiseZ))
      end

      if velDesyncCfg.counterVel
        and desyncSavedVel then
        table.insert(velocities, -desyncSavedVel
          * 2)
      end

      local getrawmetatable = getrawmetatable

      local meta = getrawmetatable
      meta = getrawmetatable and getrawmetatable(root)

      local rawNewIndex = meta

      rawNewIndex = meta and rawget(
        meta,
        "__newindex"
      )

      for _, vel in ipairs(velocities) do
        local velocity = vel

        if rawNewIndex then
          pcall(rawNewIndex, root, "AssemblyLinearVelocity", velocity)
        else
          pcall(function()
            root.AssemblyLinearVelocity = velocity
          end)
        end

        if sethiddenproperty then
          pcall(sethiddenproperty, root, "AssemblyLinearVelocity", velocity)
        end
      end

      return
    end
  end)

  velDesyncConn2 = RunService.RenderStepped:Connect(function()
    local root = getRoot()

    if velDesyncCfg.enabled
      and root
      and desyncSavedVel then
      root.AssemblyLinearVelocity = desyncSavedVel
    end
  end)
end

desyncFlipState = false

function disableVelDesync()
  if velDesyncConn then
    velDesyncConn:Disconnect()
    velDesyncConn = nil
  end

  if velDesyncConn2 then
    velDesyncConn2:Disconnect()
    velDesyncConn2 = nil
  end

  desyncSavedVel = nil
  desyncAngle = 0
  velDesyncCfg.enabled = false
end

-- ============================================================
-- FAST MELEE
-- ============================================================
fastMeleeConn = nil

function enableFastMelee()
  cacheMeleeTables()

  if fastMeleeConn then
    fastMeleeConn:Disconnect()
  end

  fastMeleeConn = RunService.Heartbeat:Connect(function()
    if not fastMeleeCfg.enabled then
      return
    end

    for _, tbl in ipairs(fastMeleeCfg.cached) do
      if rawget(tbl, "MeleeCooldown") then
        tbl.MeleeCooldown = fastMeleeCfg.cooldown
      end

      if rawget(tbl, "AttackCooldown") then
        tbl.AttackCooldown = fastMeleeCfg.cooldown
      end
    end
  end)
end

function cacheMeleeTables()
  if #fastMeleeCfg.cached
      > 0
    or type(getgc)
      ~= "function" then
    return
  end

  pcall(function()
    for _, tbl in pairs(getgc(true)) do
      if type(tbl) == "table" and (rawget(
        tbl,
        "MeleeCooldown"
      ) or rawget(
        tbl,
        "AttackCooldown"
      )) then
        table.insert(fastMeleeCfg.cached, tbl)
      end
    end
  end)
end

function disableFastMelee()
  if fastMeleeConn then
    fastMeleeConn:Disconnect()
    fastMeleeConn = nil
  end

  fastMeleeCfg.enabled = false
end

-- ============================================================
-- CHARACTER LIFECYCLE (re-enable features on respawn, clean up on death)
-- ============================================================
function onCharacterAdded(newCharacter)
  character = newCharacter

  rootPart = newCharacter:WaitForChild("HumanoidRootPart", 5)

  humanoid = newCharacter:WaitForChild("Humanoid", 5)

  if voidCfg.VOID_ENABLED then
    enableVoid()
  end

  if orbitCfg.orbitEnabled then
    enableOrbit()
  end

  if predictCfg.predEnabled then
    enablePrediction()
  end

  if antiAimCfg.enabled then
    enableAntiAim()
  end

  if undergroundCfg.enabled then
    enableUndergroundAA()
  end

  if translocCfg.enabled then
    enableTransloc()
  end

  if fakePosCfg.enabled then
    enableFakePos()
  end

  if velDesyncCfg.enabled then
    enableVelDesync()
  end

  if fastGunState.primaryOn then
    fastGunTick()
  end
end

if localPlayer.Character then
  onCharacterAdded(localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(function(newCharacter)
  task.wait(0.3)
  onCharacterAdded(newCharacter)
end)

localPlayer.CharacterRemoving:Connect(function()
  for connName in pairs(connections) do
    disconnectConn(connName)
  end

  if translocConn then
    translocConn:Disconnect()
    translocConn = nil
  end

  if fakePosHeartbeat then
    fakePosHeartbeat:Disconnect()
    fakePosHeartbeat = nil
  end

  if fakePosRender then
    fakePosRender:Disconnect()
    fakePosRender = nil
  end

  if velDesyncConn then
    velDesyncConn:Disconnect()
    velDesyncConn = nil
  end

  if velDesyncConn2 then
    velDesyncConn2:Disconnect()
    velDesyncConn2 = nil
  end

  if undergroundConn then
    undergroundConn:Disconnect()
    undergroundConn = nil
  end

  rootPart = nil
  humanoid = nil
  character = nil
end)

-- ============================================================
-- POSITION HUD
-- ============================================================
local function createPositionHud()
  local CoreGui = game:GetService("CoreGui")

  local oldHud = CoreGui:FindFirstChild("RCLC_PositionHUD")

  if oldHud then
    oldHud:Destroy()
  end

  local hudGui = Instance.new("ScreenGui")

  hudGui.Name = "RCLC_PositionHUD"

  hudGui.ResetOnSpawn = false

  hudGui.DisplayOrder = 9998

  hudGui.IgnoreGuiInset = true

  hudGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

  if not pcall(function()
    hudGui.Parent = CoreGui
  end) or not hudGui.Parent then
    hudGui.Parent = localPlayer:WaitForChild("PlayerGui")
  end

  local accent = Color3.fromRGB(
    168, 85, 247
  )

  local accentDim = Color3.fromRGB(
    120, 60, 180
  )

  local bgDark = Color3.fromRGB(
    8, 6, 12
  )

  local bgRow = Color3.fromRGB(
    16, 12, 22
  )

  local strokeColor = Color3.fromRGB(
    90, 50, 140
  )

  local textBright = Color3.fromRGB(
    245, 240, 255
  )

  local color3 = Color3
  local textDim = color3.fromRGB(160, 140, 190)

  local hudFont = Enum.Font.Garamond

  local panel = Instance.new("Frame")

  panel.Name = "PositionHUD"

  panel.Size = UDim2.fromOffset(
    200, 132
  )

  panel.Position = UDim2.new(
    0, 16, 0.5, -66
  )

  panel.BackgroundColor3 = bgDark

  panel.BackgroundTransparency = 0.02

  panel.BorderSizePixel = 0

  panel.Active = false

  panel.Parent = hudGui

  local panelCorner = Instance.new("UICorner")

  panelCorner.CornerRadius = UDim.new(
    0, 12
  )

  panelCorner.Parent = panel

  local panelStroke = Instance.new("UIStroke")

  panelStroke.Color = strokeColor

  panelStroke.Thickness = 1.2

  panelStroke.Transparency = 0.15

  panelStroke.Parent = panel

  local panelGradient = Instance.new("UIGradient")

  panelGradient.Rotation = 90

  panelGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(
      28, 14, 44
    )),
    ColorSequenceKeypoint.new(1, bgDark),
  })

  panelGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.1),
    NumberSequenceKeypoint.new(1, 0.35),
  })

  panelGradient.Parent = panel

  local topLine = Instance.new("Frame")

  topLine.Size = UDim2.new(
    1, -24, 0, 1
  )

  topLine.Position = UDim2.fromOffset(
    12, 0
  )

  topLine.BackgroundColor3 = accent

  topLine.BorderSizePixel = 0

  topLine.Parent = panel

  local topLineGradient = Instance.new("UIGradient")

  topLineGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(
      0, 0, 0
    )),
    ColorSequenceKeypoint.new(
      0.5, accent
    ),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(
      0, 0, 0
    )),
  })

  topLineGradient.Parent = topLine

  local topLineCorner = Instance.new("UICorner")

  topLineCorner.CornerRadius = UDim.new(
    1, 0
  )

  topLineCorner.Parent = topLine

  local titleLabel = Instance.new("TextLabel")

  titleLabel.Size = UDim2.new(
    1, -40, 0, 18
  )

  titleLabel.Position = UDim2.fromOffset(
    14, 10
  )

  titleLabel.BackgroundTransparency = 1

  titleLabel.Text = "POSITION"

  titleLabel.TextColor3 = accent

  titleLabel.Font = hudFont
  titleLabel.TextSize = 12

  titleLabel.TextXAlignment = Enum.TextXAlignment.Left

  titleLabel.Parent = panel

  local subtitleLabel = Instance.new("TextLabel")

  subtitleLabel.Size = UDim2.new(
    1, -40, 0, 12
  )

  subtitleLabel.Position = UDim2.fromOffset(
    14, 26
  )

  subtitleLabel.BackgroundTransparency = 1

  subtitleLabel.Text = "RCLC"

  subtitleLabel.TextColor3 = textDim

  subtitleLabel.Font = hudFont
  subtitleLabel.TextSize = 10

  subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left

  subtitleLabel.Parent = panel

  local pulseDot = Instance.new("Frame")

  pulseDot.Size = UDim2.fromOffset(
    6, 6
  )

  pulseDot.Position = UDim2.new(
    1, -18, 0, 16
  )

  pulseDot.BackgroundColor3 = accent

  pulseDot.BorderSizePixel = 0

  pulseDot.Rotation = 45

  pulseDot.Parent = panel

  local divider = Instance.new("Frame")

  divider.Size = UDim2.new(
    1, -24, 0, 1
  )

  divider.Position = UDim2.fromOffset(
    12, 42
  )

  divider.BackgroundColor3 = accentDim

  divider.BackgroundTransparency = 0.4

  divider.BorderSizePixel = 0

  divider.Parent = panel

  local dividerGradient = Instance.new("UIGradient")

  dividerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(
      0, 0, 0
    )),
    ColorSequenceKeypoint.new(0.5, accentDim),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(
      0, 0, 0
    )),
  })

  dividerGradient.Parent = divider

  local valueLabels = {}

  for rowIndex, axisName in ipairs({
    "X", "Y",
    "Z",
  }) do
    local row = Instance.new("Frame")

    row.Size = UDim2.new(
      1, -24, 0, 24
    )

    row.Position = UDim2.fromOffset(12, 50
      + (rowIndex - 1) * 27)

    row.BackgroundColor3 = bgRow

    row.BackgroundTransparency = 0.1

    row.BorderSizePixel = 0

    row.Parent = panel

    local rowCorner = Instance.new("UICorner")

    rowCorner.CornerRadius = UDim.new(
      0, 6
    )

    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")

    rowStroke.Color = strokeColor
    rowStroke.Thickness = 1

    rowStroke.Transparency = 0.55

    rowStroke.Parent = row

    local rowAccent = Instance.new("Frame")

    rowAccent.Size = UDim2.new(
      0, 2, 0, 12
    )

    rowAccent.Position = UDim2.new(
      0, 7, 0.5, -6
    )

    rowAccent.BackgroundColor3 = accent

    rowAccent.BorderSizePixel = 0

    rowAccent.Parent = row

    local rowAccentCorner = Instance.new("UICorner")

    rowAccentCorner.CornerRadius = UDim.new(
      1, 0
    )

    rowAccentCorner.Parent = rowAccent

    local axisLabel = Instance.new("TextLabel")

    axisLabel.Size = UDim2.fromOffset(
      14, 24
    )

    axisLabel.Position = UDim2.fromOffset(
      16, 0
    )

    axisLabel.BackgroundTransparency = 1

    axisLabel.Text = axisName
    axisLabel.TextColor3 = accent
    axisLabel.Font = hudFont

    axisLabel.TextSize = 12

    axisLabel.TextXAlignment = Enum.TextXAlignment.Left

    axisLabel.Parent = row

    local valueLabel = Instance.new("TextLabel")

    valueLabel.Size = UDim2.new(
      1, -40, 1, 0
    )

    valueLabel.Position = UDim2.fromOffset(
      34, 0
    )

    valueLabel.BackgroundTransparency = 1

    valueLabel.Text = "0.00"

    valueLabel.TextColor3 = textBright

    valueLabel.Font = hudFont

    valueLabel.TextSize = 13

    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    valueLabel.Parent = row

    valueLabels[axisName] = valueLabel
  end

  local pulseTime = 0
  local blankText1 = ""
  local blankText2 = ""
  local lastXText = ""
  local lastYText = blankText1
  local lastZText = blankText2

  RunService.Heartbeat:Connect(function(dt)
    if not hudGui.Parent then
      return
    else
      pulseTime = pulseTime + dt * 2.2
      local pulse = math.sin(pulseTime)

      pulseDot.BackgroundTransparency = 1
        - (0.5 + (pulse + 1) * 0.5 * 0.5)

      local char = localPlayer
        and localPlayer.Character

      local root = char and char:FindFirstChild("HumanoidRootPart")

      if root then
        local xText = string.format("%.2f", root.Position.X)

        local yText = string.format("%.2f", root.Position.Y)

        local zText = string.format("%.2f", root.Position.Z)

        if xText ~= lastXText then
          valueLabels.X.Text = xText
          lastXText = xText
        end

        if yText ~= lastYText then
          valueLabels.Y.Text = yText
          lastYText = yText
        end

        if zText ~= lastZText then
          valueLabels.Z.Text = zText
          lastZText = zText
        end
      elseif lastXText ~= "0.00" then
        valueLabels.X.Text = "0.00"

        valueLabels.Y.Text = "0.00"

        valueLabels.Z.Text = "0.00"

        local zeroPrefix = "0."
        local zeroSuffix = "00"
        local zeroText = "0.00"
        lastXText = "0.00"
        lastYText = zeroPrefix .. zeroSuffix
        lastZText = zeroText
      end

      return
    end
  end)

  return hudGui
end

positionHud = createPositionHud()

-- ============================================================
-- UI TABS
-- ============================================================
local voidTab = window:CreateTab({
  Name = "Void",
  Icon = "activity",
})

local orbitTab = window:CreateTab({
  Name = "Orbit",
  Icon = "refresh-cw",
})

local defenseTab = window:CreateTab({
  Name = "Defense",
  Icon = "shield",
})

local translocTab = window:CreateTab({
  Name = "Translocation",
  Icon = "move",
})

local extrasTab = window:CreateTab({
  Name = "Extras",
  Icon = "zap",
})

local settingsTab = window:CreateTab({
  Name = "Settings",
  Icon = "settings",
})

voidTab:CreateSection("Engine")

voidTab:CreateToggle({
  Name = "Enable Void",
  CurrentValue = false,
  Flag = "VoidToggle",
  Callback = function(enabled)
    voidCfg.VOID_ENABLED = enabled

    if enabled then
      enableVoid()
    else
      disableVoid()
    end
  end,
})

voidTab:CreateDropdown({
  Name = "Method",
  Options = {
    "Attacker",
    "Chaos",
    "Quantum",
    "Freeze Bait",
  },
  CurrentOption = "Quantum",
  Flag = "VoidMethod",
  Callback = function(option)
    voidCfg.VOID_METHOD = option

    voidPhaseTime = 0
    voidBaitPhase = false
  end,
})

voidTab:CreateSection("Attacker Settings")

voidTab:CreateSlider({
  Name = "Attacker Interval (s)",
  Range = {
    1, 10,
  },
  Increment = 0.5,
  CurrentValue = 4,
  Flag = "VoidAttInterval",
  Callback = function(value)
    voidCfg.VOID_ATTACKER_INTERVAL = value
  end,
})

voidTab:CreateSlider({
  Name = "Attacker Freeze (s)",
  Range = {
    0.1, 2,
  },
  Increment = 0.1,
  CurrentValue = 0.4,
  Flag = "VoidAttDuration",
  Callback = function(value)
    voidCfg.VOID_ATTACKER_DURATION = value
  end,
})

voidTab:CreateSection("Freeze Bait Settings")

voidTab:CreateSlider({
  Name = "Bait Interval (s)",
  Range = { 1, 10 },
  Increment = 0.5,
  CurrentValue = 3,
  Flag = "VoidBaitInterval",
  Callback = function(value)
    voidCfg.VOID_BAIT_INTERVAL = value
  end,
})

voidTab:CreateSlider({
  Name = "Bait Freeze Duration (s)",
  Range = { 0.1, 2 },
  Increment = 0.1,
  CurrentValue = 0.4,
  Flag = "VoidBaitDuration",
  Callback = function(value)
    voidCfg.VOID_BAIT_DURATION = value
  end,
})

voidTab:CreateSection("Visuals")

voidTab:CreateToggle({
  Name = "Enable Wireframe ESP",
  CurrentValue = false,
  Flag = "VoidWireframe",
  Callback = function(enabled)
    setWireframes(enabled)
  end,
})

voidTab:CreateSection("Motion")

voidTab:CreateSlider({
  Name = "Speed",
  Range = {
    0.001, 1,
  },
  Increment = 0.001,
  CurrentValue = 1,
  Flag = "VoidSpeed",
  Callback = function(value)
    voidCfg.SPEED = value * 1000000000
  end,
})

voidTab:CreateSlider({
  Name = "Writes / Frame",
  Range = { 1, 8 },
  Increment = 1,
  CurrentValue = 1,
  Flag = "VoidWrites",
  Callback = function(value)
    voidCfg.VOID_WRITES_PER_FRAME = value
  end,
})

voidTab:CreateToggle({
  Name = "Interpolate",
  CurrentValue = true,
  Flag = "VoidInterp",
  Callback = function(enabled)
    voidCfg.VOID_INTERP = enabled
  end,
})

voidTab:CreateSlider({
  Name = "Interp Alpha",
  Range = { 0.05, 1 },
  Increment = 0.05,
  CurrentValue = 0.35,
  Flag = "VoidInterpAlpha",
  Callback = function(value)
    voidCfg.VOID_INTERP_ALPHA = value
  end,
})

voidTab:CreateSection("Space")

voidTab:CreateSlider({
  Name = "Radius",
  Range = {
    1, 10000000,
  },
  Increment = 1,
  CurrentValue = 10000000,
  Flag = "VoidRadius",
  Callback = function(value)
    voidCfg.RADIUS = value
  end,
})

voidTab:CreateSlider({
  Name = "Y Min",
  Range = {
    -10000000, 10000000,
  },
  Increment = 1,
  CurrentValue = -10000000,
  Flag = "VoidYMin",
  Callback = function(value)
    voidCfg.VOID_Y_MIN = value
  end,
})

voidTab:CreateSlider({
  Name = "Y Max",
  Range = {
    -10000000, 10000000,
  },
  Increment = 1,
  CurrentValue = 10000000,
  Flag = "VoidYMax",
  Callback = function(value)
    voidCfg.VOID_Y_MAX = value
  end,
})

orbitTab:CreateToggle({
  Name = "Enable Orbit",
  CurrentValue = false,
  Flag = "OrbitToggle",
  Callback = function(enabled)
    orbitCfg.orbitEnabled = enabled

    if enabled then
      enableOrbit()
    else
      disableOrbit()
    end
  end,
})

orbitTab:CreateDropdown({
  Name = "Direction",
  Options = {
    "Clockwise",
    "Counter-Clockwise",
  },
  CurrentOption = "Clockwise",
  Flag = "OrbitMode",
  Callback = function(option)
    orbitCfg.orbitMode = option
  end,
})

orbitTab:CreateSlider({
  Name = "Speed",
  Range = {
    5, 1000,
  },
  Increment = 1,
  CurrentValue = 90,
  Flag = "OrbitSpeed",
  Callback = function(value)
    orbitCfg.orbitSpeed = value
  end,
})

orbitTab:CreateSlider({
  Name = "Radius",
  Range = { 1, 50 },
  Increment = 1,
  CurrentValue = 8,
  Flag = "OrbitDist",
  Callback = function(value)
    orbitCfg.orbitDist = value
  end,
})

orbitTab:CreateSlider({
  Name = "Height",
  Range = { -100, 100 },
  Increment = 1,
  CurrentValue = 0,
  Flag = "OrbitHeight",
  Callback = function(value)
    orbitCfg.orbitHeight = value
  end,
})

defenseTab:CreateSection("Anti-Aim (Chaos Jitter)")

defenseTab:CreateToggle({
  Name = "Enable Anti-Aim",
  CurrentValue = false,
  Flag = "AaToggle",
  Callback = function(enabled)
    antiAimCfg.enabled = enabled

    if enabled then
      enableAntiAim()
    else
      disableAntiAim()
    end
  end,
})

defenseTab:CreateSlider({
  Name = "Pitch Max (deg)",
  Range = { 1, 360 },
  Increment = 1,
  CurrentValue = 360,
  Flag = "AaPitch",
  Callback = function(value)
    antiAimCfg.pitch = value
  end,
})

defenseTab:CreateSlider({
  Name = "Yaw Max (deg)",
  Range = {
    1, 360,
  },
  Increment = 1,
  CurrentValue = 360,
  Flag = "AaYaw",
  Callback = function(value)
    antiAimCfg.yaw = value
  end,
})

defenseTab:CreateSection("Underground Anti-Aim")

defenseTab:CreateToggle({
  Name = "Enable Underground AA",
  CurrentValue = false,
  Flag = "UgAAToggle",
  Callback = function(enabled)
    undergroundCfg.enabled = enabled

    if enabled then
      enableUndergroundAA()
    else
      disableUndergroundAA()
    end
  end,
})

defenseTab:CreateSlider({
  Name = "Underground Depth",
  Range = { 1, 5 },
  Increment = 0.1,
  CurrentValue = 1.5,
  Flag = "UgAADepth",
  Callback = function(value)
    undergroundCfg.depth = value
  end,
})

defenseTab:CreateSlider({
  Name = "Orbit Radius",
  Range = { 0, 10 },
  Increment = 0.1,
  CurrentValue = 3,
  Flag = "UgAAOrbRadius",
  Callback = function(value)
    undergroundCfg.orbitRadius = value
  end,
})

defenseTab:CreateSlider({
  Name = "Orbit Speed",
  Range = {
    50, 1000,
  },
  Increment = 10,
  CurrentValue = 200,
  Flag = "UgAAOrbSpeed",
  Callback = function(value)
    undergroundCfg.orbitSpeed = value
  end,
})

defenseTab:CreateSlider({
  Name = "Spin Speed",
  Range = {
    100, 2000,
  },
  Increment = 10,
  CurrentValue = 720,
  Flag = "UgAASpinSpeed",
  Callback = function(value)
    undergroundCfg.spinSpeed = value
  end,
})

defenseTab:CreateSection("Prediction (Dodging)")

defenseTab:CreateToggle({
  Name = "Enable Prediction",
  CurrentValue = false,
  Flag = "DefPredToggle",
  Callback = function(enabled)
    predictCfg.predEnabled = enabled

    if enabled then
      enablePrediction()
    else
      disablePrediction()
    end
  end,
})

defenseTab:CreateToggle({
  Name = "Track Enemy Velocity",
  CurrentValue = true,
  Flag = "DefPredKinematic",
  Callback = function(enabled)
    predictCfg.predKinematic = enabled
  end,
})

defenseTab:CreateToggle({
  Name = "Predict Shot Path",
  CurrentValue = true,
  Flag = "DefPredPredictive",
  Callback = function(enabled)
    predictCfg.predPredictive = enabled
  end,
})

defenseTab:CreateSlider({
  Name = "Danger Radius",
  Range = { 5, 5000 },
  Increment = 1,
  CurrentValue = 150,
  Flag = "DefPredRadius",
  Callback = function(value)
    predictCfg.predRadius = value
  end,
})

defenseTab:CreateSlider({
  Name = "Dodge Distance",
  Range = { 5, 500 },
  Increment = 1,
  CurrentValue = 80,
  Flag = "DefPredDodge",
  Callback = function(value)
    predictCfg.predDodgeDist = value
  end,
})

defenseTab:CreateSlider({
  Name = "Reaction Time ms",
  Range = {
    1, 50,
  },
  Increment = 1,
  CurrentValue = 12,
  Flag = "DefPredReactTime",
  Callback = function(value)
    predictCfg.predReactionTime = value
      * 0.01
  end,
})

defenseTab:CreateSlider({
  Name = "Aim Threshold %",
  Range = {
    50, 99,
  },
  Increment = 1,
  CurrentValue = 70,
  Flag = "DefPredAimThreshold",
  Callback = function(value)
    predictCfg.predAimThreshold = value
      * 0.01
  end,
})

defenseTab:CreateSlider({
  Name = "Cooldown ms",
  Range = {
    10, 2000,
  },
  Increment = 1,
  CurrentValue = 50,
  Flag = "DefPredCooldown",
  Callback = function(value)
    predictCfg.predCooldown = value
      / 1000
  end,
})

defenseTab:CreateSection("Velocity Desync")

defenseTab:CreateToggle({
  Name = "Enable Velocity Desync",
  CurrentValue = false,
  Flag = "VelDesyncToggle",
  Callback = function(enabled)
    velDesyncCfg.enabled = enabled

    if enabled then
      enableVelDesync()
    else
      disableVelDesync()
    end
  end,
})

defenseTab:CreateSlider({
  Name = "Intensity %",
  Range = {
    1, 100,
  },
  Increment = 1,
  CurrentValue = 50,
  Flag = "VDIntensity",
  Callback = function(value)
    velDesyncCfg.intensity = value
  end,
})

defenseTab:CreateSlider({
  Name = "Base Angle",
  Range = { 0, 360 },
  Increment = 1,
  CurrentValue = 90,
  Flag = "VDAngle",
  Callback = function(value)
    velDesyncCfg.angle = value
  end,
})

defenseTab:CreateSlider({
  Name = "Jitter",
  Range = { 0, 180 },
  Increment = 1,
  CurrentValue = 20,
  Flag = "VDJitter",
  Callback = function(value)
    velDesyncCfg.jitter = value
  end,
})

defenseTab:CreateSlider({
  Name = "Rotation Speed",
  Range = {
    1, 100,
  },
  Increment = 1,
  CurrentValue = 10,
  Flag = "VDSpeed",
  Callback = function(value)
    velDesyncCfg.speed = value
  end,
})

defenseTab:CreateToggle({
  Name = "Flip Direction",
  CurrentValue = false,
  Flag = "VDFlip",
  Callback = function(enabled)
    velDesyncCfg.flip = enabled
  end,
})

defenseTab:CreateToggle({
  Name = "Oscillate",
  CurrentValue = false,
  Flag = "VDOsc",
  Callback = function(enabled)
    velDesyncCfg.oscillate = enabled
  end,
})

defenseTab:CreateToggle({
  Name = "Spike Mode",
  CurrentValue = false,
  Flag = "VDSpike",
  Callback = function(enabled)
    velDesyncCfg.spikeMode = enabled
  end,
})

defenseTab:CreateToggle({
  Name = "Multi Vector",
  CurrentValue = false,
  Flag = "VDMulti",
  Callback = function(enabled)
    velDesyncCfg.multiVector = enabled
  end,
})

defenseTab:CreateToggle({
  Name = "Noise Velocity",
  CurrentValue = false,
  Flag = "VDNoise",
  Callback = function(enabled)
    velDesyncCfg.noiseVel = enabled
  end,
})

defenseTab:CreateToggle({
  Name = "Burst Desync",
  CurrentValue = false,
  Flag = "VDBurst",
  Callback = function(enabled)
    velDesyncCfg.burstDesync = enabled
  end,
})

defenseTab:CreateSection("Fake Position")

defenseTab:CreateToggle({
  Name = "Enable Fake Position",
  CurrentValue = false,
  Flag = "FakePosToggle",
  Callback = function(enabled)
    fakePosCfg.enabled = enabled

    if enabled then
      enableFakePos()
    else
      disableFakePos()
    end
  end,
})

defenseTab:CreateDropdown({
  Name = "Pattern",
  Options = {
    "Scatter",
    "Linear",
    "Circle",
    "Random",
    "Spiral",
  },
  CurrentOption = "Scatter",
  Flag = "FPPattern",
  Callback = function(option)
    fakePosCfg.pattern = option
  end,
})

defenseTab:CreateDropdown({
  Name = "Distribution",
  Options = {
    "Random",
    "Uniform",
    "Weighted",
    "Radial",
    "Clustered",
  },
  CurrentOption = "Random",
  Flag = "FPDist",
  Callback = function(option)
    fakePosCfg.distribution = option
  end,
})

defenseTab:CreateDropdown({
  Name = "Axis Lock",
  Options = {
    "None", "X",
    "Y", "Z",
    "XZ",
  },
  CurrentOption = "None",
  Flag = "FPAxis",
  Callback = function(option)
    fakePosCfg.axisLock = option
  end,
})

defenseTab:CreateSlider({
  Name = "Radius",
  Range = { 1, 10000000 },
  Increment = 1000,
  CurrentValue = 1000000,
  Flag = "FPRadius",
  Callback = function(value)
    fakePosCfg.radius = value
  end,
})

defenseTab:CreateSlider({
  Name = "Height Offset",
  Range = { -1000000000, 1000000000 },
  Increment = 1000,
  CurrentValue = 999999999,
  Flag = "FPHeight",
  Callback = function(value)
    fakePosCfg.height = value
  end,
})

defenseTab:CreateSlider({
  Name = "Y Distance",
  Range = {
    0, 1000000000,
  },
  Increment = 1000,
  CurrentValue = 999999999,
  Flag = "FPYDist",
  Callback = function(value)
    fakePosCfg.yDist = value
  end,
})

defenseTab:CreateSlider({
  Name = "Speed",
  Range = { 1, 100000 },
  Increment = 100,
  CurrentValue = 100000,
  Flag = "FPSpeed",
  Callback = function(value)
    fakePosCfg.speed = value
  end,
})

defenseTab:CreateToggle({
  Name = "Randomize Every Frame",
  CurrentValue = false,
  Flag = "FPRandFrame",
  Callback = function(enabled)
    fakePosCfg.randomizeEveryFrame = enabled
  end,
})

defenseTab:CreateToggle({
  Name = "Layered Fake",
  CurrentValue = false,
  Flag = "FPLayered",
  Callback = function(enabled)
    fakePosCfg.layeredFake = enabled
  end,
})

defenseTab:CreateToggle({
  Name = "Chaos Mode",
  CurrentValue = false,
  Flag = "FPChaos",
  Callback = function(enabled)
    fakePosCfg.chaosMode = enabled
  end,
})

defenseTab:CreateToggle({
  Name = "Pulse Radius",
  CurrentValue = false,
  Flag = "FPPulse",
  Callback = function(enabled)
    fakePosCfg.pulseRadius = enabled
  end,
})

translocTab:CreateSection("Engine")

translocTab:CreateToggle({
  Name = "Enable Translocation",
  CurrentValue = false,
  Flag = "TranslocToggle",
  Callback = function(enabled)
    translocCfg.enabled = enabled

    if enabled then
      enableTransloc()
    else
      disableTransloc()
    end
  end,
})

translocTab:CreateSlider({
  Name = "Frequency (Hz)",
  Range = { 1, 1000000 },
  Increment = 1000,
  CurrentValue = 1000000,
  Flag = "TranslocFreq",
  Callback = function(value)
    translocCfg.frequency = value
  end,
})

translocTab:CreateSlider({
  Name = "X Jitter Range",
  Range = {
    1, 100000000,
  },
  Increment = 1000,
  CurrentValue = 10000000,
  Flag = "TranslocJitterX",
  Callback = function(value)
    translocCfg.jitterX = value
  end,
})

translocTab:CreateSlider({
  Name = "Y Jitter Range",
  Range = {
    1, 100000000,
  },
  Increment = 1000,
  CurrentValue = 10000000,
  Flag = "TranslocJitterY",
  Callback = function(value)
    translocCfg.jitterY = value
  end,
})

translocTab:CreateSlider({
  Name = "Fixed Z Position",
  Range = { 0, 100 },
  Increment = 0.1,
  CurrentValue = 1,
  Flag = "TranslocFixedZ",
  Callback = function(value)
    translocCfg.fixedZ = value
  end,
})

translocTab:CreateSection("Pulse")

translocTab:CreateToggle({
  Name = "Fake Velocity",
  CurrentValue = true,
  Flag = "TranslocFakeVel",
  Callback = function(enabled)
    translocCfg.fakeVel = enabled
  end,
})

translocTab:CreateSlider({
  Name = "Fake Vel Mag",
  Range = { 1, 1000000000000000 },
  Increment = 1000,
  CurrentValue = 10000000000,
  Flag = "TranslocVelMag",
  Callback = function(value)
    translocCfg.fakeVelMag = value
  end,
})

translocTab:CreateToggle({
  Name = "Burst Mode",
  CurrentValue = false,
  Flag = "TranslocBurst",
  Callback = function(enabled)
    translocCfg.burstMode = enabled
  end,
})

translocTab:CreateSlider({
  Name = "Burst Count",
  Range = {
    2, 50,
  },
  Increment = 1,
  CurrentValue = 10,
  Flag = "TranslocBurstCount",
  Callback = function(value)
    translocCfg.burstCount = value
  end,
})

extrasTab:CreateSection("Zombie Tower Kill Aura")

extrasTab:CreateToggle({
  Name = "Enable Kill Aura",
  CurrentValue = false,
  Flag = "KillAuraToggle",
  Callback = function(enabled)
    killAuraCfg.enabled = enabled

    if enabled then
      enableKillAura()
    else
      disableKillAura()
    end
  end,
})

extrasTab:CreateSection("Fast Melee")

extrasTab:CreateToggle({
  Name = "Enable Fast Melee",
  CurrentValue = false,
  Flag = "FastMeleeToggle",
  Callback = function(enabled)
    fastMeleeCfg.enabled = enabled

    if enabled then
      enableFastMelee()
    else
      disableFastMelee()
    end
  end,
})

extrasTab:CreateSlider({
  Name = "Melee Cooldown",
  Range = {
    0, 5,
  },
  Increment = 0.01,
  CurrentValue = 0,
  Flag = "MeleeCD",
  Callback = function(value)
    fastMeleeCfg.cooldown = value
  end,
})

extrasTab:CreateSection("Fast Gun")

extrasTab:CreateToggle({
  Name = "Enable Fast Gun",
  CurrentValue = false,
  Flag = "FastGunToggle",
  Callback = function(enabled)
    fastGunState.primaryOn = enabled

    if enabled then
      patchEquippedGuns()
    end
  end,
})

extrasTab:CreateButton({
  Name = "Rescan & Repatch All Guns",
  Style = "Primary",
  Icon = "refresh-cw",
  Callback = function()
    fastGunState.primaryOn = true

    patchEquippedGuns()
  end,
})

settingsTab:CreateSection("Presets")

settingsTab:CreateButton({
  Name = "Kill Everything",
  Style = "Danger",
  Icon = "power",
  Callback = function()
    voidCfg.VOID_ENABLED = false

    disableVoid()

    orbitCfg.orbitEnabled = false

    disableOrbit()

    predictCfg.predEnabled = false

    disablePrediction()

    antiAimCfg.enabled = false

    disableAntiAim()

    undergroundCfg.enabled = false

    disableUndergroundAA()

    translocCfg.enabled = false

    disableTransloc()
    fakePosCfg.enabled = false
    disableFakePos()
    velDesyncCfg.enabled = false
    disableVelDesync()

    fastMeleeCfg.enabled = false

    disableFastMelee()

    killAuraCfg.enabled = false

    disableKillAura()
    disableWireframes()

    fastGunState.primaryOn = false

    notify("Preset", "All systems off", "Warning", 3)
  end,
})

settingsTab:CreateSection("Character")

settingsTab:CreateButton({
  Name = "Reload Character",
  Icon = "refresh-cw",
  Callback = function()
    if localPlayer.Character then
      localPlayer.Character:BreakJoints()
    end
  end,
})

settingsTab:CreateButton({
  Name = "Rejoin Server",
  Icon = "log-out",
  Callback = function()
    pcall(function()
      game:GetService("TeleportService"):Teleport(game.PlaceId, localPlayer)
    end)
  end,
})

settingsTab:CreateSection("Interface")

settingsTab:CreateButton({
  Name = "Test MenHub API",
  Icon = "zap",
  Callback = function()
    if _G.Mhapi then
      pcall(function()
        _G.Mhapi:Notify("you click me!")
      end)
    else
      notify("MenHub", "Not detected. Running Airflow.", "Warning", 3)
    end
  end,
})

settingsTab:CreateThemePicker({
  Flag = "Theme",
})

settingsTab:CreateKeybind({
  Name = "Toggle UI",
  CurrentKeybind = "RightControl",
  OnChanged = function(key)
    window:SetKeybind(key)
  end,
})

settingsTab:CreateConfigManager({
  Name = "Configs",
})

settingsTab:CreateButton({
  Name = "Unload Script",
  Style = "Danger",
  Icon = "power",
  Callback = function()
    AirflowUI:Confirm({
      Title = "Unload?",
      ConfirmText = "Unload",
      Callback = function()
        window:Destroy()

        if positionHud then
          positionHud:Destroy()
        end
      end,
    })
  end,
})

window:LoadConfig()

notify("RCLC Premium Lua", "#1 hvh addon loaded", "Success", 4)

