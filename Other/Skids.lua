if not game:IsLoaded() then game.Loaded:Wait() end

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- WINDOW
local Window = Library:CreateWindow({
    Title = 'Rivals | by loop',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- MAIN
local MainGroup = Tabs.Main:AddLeftGroupbox('Desync')
local CombatGroup = Tabs.Main:AddRightGroupbox('Combat')

MainGroup:AddToggle('VoidSpam', {
    Text = 'Void Spam',
    Default = false,
    Tooltip = 'Network desync - teleport to void every frame',
})

CombatGroup:AddToggle('RapidFire', {
    Text = 'Rapid Fire',
    Default = false,
    Tooltip = 'Remove gun cooldown'
})

-- ==================== ANIMATION 67 ====================
local animEnabled67 = false
local animTrack67 = nil
local animationId67 = "117781289000852"
local animSpeed67 = 1

local function anim2track(asset_id)
    local objs = game:GetObjects(asset_id)
    for i = 1, #objs do
        if objs[i]:IsA("Animation") then
            return objs[i].AnimationId
        end
    end
    return asset_id
end

local function getAnimId67()
    local id = animationId67
    if not id:find("rbxassetid://") then
        id = "rbxassetid://" .. id
    end
    return anim2track(id)
end

local function stopAllAnims(char)
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    if hum then
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end
end

local function startAnim67(char)
    if not char then return end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end
    stopAllAnims(char)
    local anim = Instance.new("Animation")
    anim.AnimationId = getAnimId67()
    local track = hum:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track:Play()
    track:AdjustSpeed(animSpeed67)
    track.Stopped:Connect(function()
        if animEnabled67 and char and char.Parent then
            startAnim67(char)
        end
    end)
    animTrack67 = track
end

local function stopAnim67()
    if animTrack67 then
        animTrack67:Stop()
        animTrack67 = nil
    end
    if lp.Character then
        stopAllAnims(lp.Character)
    end
end

CombatGroup:AddToggle('Anim67', {
    Text = '67 (Animation Loop)',
    Default = false,
    Tooltip = 'Chạy animation liên tục với ID 117781289000852',
    Callback = function(val)
        animEnabled67 = val
        if val then
            if lp.Character then
                startAnim67(lp.Character)
            else
                lp.CharacterAdded:Connect(function(char)
                    if animEnabled67 then
                        task.wait(0.5)
                        startAnim67(char)
                    end
                end)
            end
        else
            stopAnim67()
        end
    end
})

-- ==================== AUTO COLLECT BULLET ====================
local autoCollectEnabled = false

local function startAutoCollect()
    if autoCollectEnabled then
        local conn
        conn = RS.RenderStepped:Connect(function()
            if not autoCollectEnabled then
                conn:Disconnect()
                return
            end
            local char = lp.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local humanoid = char:FindFirstChild("Humanoid")
            local needsHealth = humanoid and humanoid.Health < humanoid.MaxHealth
            for _, obj in pairs(workspace:GetChildren()) do
                if obj.Name == "_drop" and obj:IsA("BasePart") then
                    if (needsHealth and obj:FindFirstChild("Health")) or obj:FindFirstChild("Ammo") then
                        pcall(function()
                            firetouchinterest(hrp, obj, 0)
                            firetouchinterest(hrp, obj, 1)
                        end)
                    end
                end
            end
        end)
    end
end

CombatGroup:AddToggle('AutoCollect', {
    Text = 'Auto Collect Bullet',
    Default = false,
    Tooltip = 'Tự động nhặt đạn và máu từ các item _drop',
    Callback = function(val)
        autoCollectEnabled = val
        if val then
            startAutoCollect()
        end
    end
})

-- Xử lý respawn khi đang bật animation
lp.CharacterAdded:Connect(function(char)
    if animEnabled67 then
        task.wait(0.5)
        startAnim67(char)
    end
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function()
    Library:Unload()
end)

MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',   -- Đã đổi từ 'End' thành 'RightShift'
    NoUI = true,
    Text = 'Menu keybind'
})

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})

ThemeManager:SetFolder('RivalsHub')
SaveManager:SetFolder('RivalsHub/rivals')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()

-- VOID SPAM
local hrp
local clientc
local clientv
local clientva

local function betterRandom(mi, ma, dmi, dma)
    local val = math.random(mi, ma)
    repeat
        val = math.random(mi, ma)
    until val < dmi or val > dma
    return val
end

RS.Heartbeat:Connect(function()
    if Toggles.VoidSpam.Value then
        pcall(function()
            hrp = lp.Character.HumanoidRootPart
            clientc = hrp.CFrame
            clientv = hrp.AssemblyLinearVelocity
            clientva = hrp.AssemblyAngularVelocity

            hrp.CFrame = CFrame.new(
                betterRandom(-2147483646,2147483646,-1147483646,1147483646),
                betterRandom(-2147483646,2147483646,-1147483646,1147483646),
                betterRandom(-2147483646,2147483646,-1147483646,1147483646)
            ) * CFrame.Angles(math.rad(math.pi), math.rad(math.pi), math.rad(math.pi))

            hrp.AssemblyLinearVelocity = Vector3.new(
                betterRandom(-2147483646,2147483646,-1147483646,1147483646),
                betterRandom(-2147483646,2147483646,-1147483646,1147483646),
                betterRandom(-2147483646,2147483646,-1147483646,1147483646)
            )

            hrp.AssemblyAngularVelocity = Vector3.new(
                betterRandom(-2147483646,2147483646,-1147483646,1147483646),
                betterRandom(-2147483646,2147483646,-1147483646,1147483646),
                betterRandom(-2147483646,2147483646,-1147483646,1147483646)
            )
        end)
    end

    if Toggles.RapidFire.Value then
        pcall(function()
            local Gun = require(lp.PlayerScripts.Modules.ItemTypes.Gun)

            if Gun and Gun.Update and not Gun._RapidHooked then
                Gun._RapidHooked = true

                local oldUpdate = Gun.Update

                Gun.Update = function(self, dt, ...)
                    if self._shoot_cooldown then
                        self._shoot_cooldown = 0
                    end
                    return oldUpdate(self, dt, ...)
                end
            end
        end)
    end
end)

RS:BindToRenderStep("csync", Enum.RenderPriority.First.Value, function()
    if not Toggles.VoidSpam.Value then return end

    if hrp then
        pcall(function()
            hrp.CFrame = clientc
            hrp.AssemblyLinearVelocity = clientv
            hrp.AssemblyAngularVelocity = clientva
        end)
    end
end)

-- WATERMARK
Library:SetWatermarkVisibility(true)

local frameTimer = tick()
local frameCount = 0
local fps = 60

RS.RenderStepped:Connect(function()
    frameCount += 1

    if tick() - frameTimer >= 1 then
        fps = frameCount
        frameTimer = tick()
        frameCount = 0
    end

    Library:SetWatermark(('Rivals | %d fps | %d ms'):format(
        math.floor(fps),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)

Library:OnUnload(function()
    RS:UnbindFromRenderStep("csync")
    Library.Unloaded = true
end)