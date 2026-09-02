local InputService = game:GetService('UserInputService');
local TextService = game:GetService('TextService');
local CoreGui = game:GetService('CoreGui');
local Teams = game:GetService('Teams');
local Players = game:GetService('Players');
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService');
local Lighting = game:GetService('Lighting');
local RenderStepped = RunService.RenderStepped;
local LocalPlayer = Players.LocalPlayer;
local Mouse = LocalPlayer and LocalPlayer:GetMouse() or nil;

local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end);

local ScreenGui = Instance.new('ScreenGui');
ProtectGui(ScreenGui);
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
ScreenGui.Parent = CoreGui;

local Toggles = {};
local Options = {};

getgenv().Toggles = Toggles;
getgenv().Options = Options;

local Library = {
    Registry = {};
    RegistryMap = {};

    HudRegistry = {};

    FontColor = Color3.fromRGB(255, 255, 255);
    MainColor = Color3.fromRGB(24, 24, 24);
    BackgroundColor = Color3.fromRGB(20, 20, 20);
    AccentColor = Color3.fromRGB(71, 119, 182);
    OutlineColor = Color3.fromRGB(31, 31, 31);
    RiskColor = Color3.fromRGB(255, 50, 50),

    Black = Color3.new(0, 0, 0);

    Font = Enum.Font.Code,
    FontSize = 14,

    OpenedFrames = {};
    DependencyBoxes = {};

    Signals = {};
    ScreenGui = ScreenGui;

    Toggled = false;
    Unloaded = false;
    BatchUpdating = false;
    UILocked = false;
    Options = Options;
    Toggles = Toggles;
    WireframeDrag = true;
    UseBlur = false;
    BlurSize = 15;

    KeybindMode = 'All';
    ShowKeybinds = true;

    DPIScale = 1;
    ActiveGestureInput = nil;
    ActiveGestureCleanups = {};
    NotifyScale = nil;
    _MobileGui = nil;
    _DropdownScales = {};
    _OnUnloadCallbacks = {};

    NotifyConfig = {
        Alignment = 'Left';
        BarSide   = 'Left';
        PositionX = 0;
        PositionY = 40;
    };
};

Library.Options = Options;
Library.Toggles = Toggles;

Library.KeyPickerList = {};

Library.BlurEffect = Instance.new("BlurEffect")
Library.BlurEffect.Name = "LinoriaBlur"
Library.BlurEffect.Size = 0
Library.BlurEffect.Enabled = false
pcall(function() Library.BlurEffect.Parent = Lighting end)

function Library:UpdateBlur()
    if not Library.BlurEffect then return Library end
    if Library.UseBlur then
        if Library.Toggled then
            Library.BlurEffect.Enabled = true
            TweenService:Create(Library.BlurEffect, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {Size = Library.BlurSize}):Play()
        end
    else
        local tween = TweenService:Create(Library.BlurEffect, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {Size = 0})
        tween:Play()
    
        task.delay(0.2, function()
            if not Library.UseBlur then
                Library.BlurEffect.Enabled = false
            end
        end)
    end
end

function Library:SetFontSize(Size)
    Size = tonumber(Size)
    if not Size or Size <= 0 then return Library end
    Library.FontSize = Size
    for _, descendant in pairs(ScreenGui:GetDescendants()) do
        if descendant:IsA("TextLabel") or descendant:IsA("TextBox") or descendant:IsA("TextButton") then
            local offset = descendant:GetAttribute("FontSizeOffset")
            if offset then
                descendant.TextSize = Size + offset
            end
        end
    end
    local mobileUI = CoreGui:FindFirstChild("LinoriaMobileUI")
    if mobileUI then
        for _, descendant in pairs(mobileUI:GetDescendants()) do
            if descendant:IsA("TextLabel") or descendant:IsA("TextBox") or descendant:IsA("TextButton") then
                local offset = descendant:GetAttribute("FontSizeOffset")
                if offset then
                    descendant.TextSize = Size + offset
                end
            end
        end
    end
end

local RainbowStep = 0
local Hue = 0

table.insert(Library.Signals, RenderStepped:Connect(function(Delta)
    RainbowStep = RainbowStep + Delta

    if RainbowStep >= (1 / 60) then
        RainbowStep = 0

        Hue = Hue + (1 / 400);
        if Hue > 1 then
            Hue = 0;
        end;

        Library.CurrentRainbowHue = Hue;
        Library.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1);
    end
end))

local function GetPlayersString()
    local PlayerList = Players:GetPlayers();
    for i = 1, #PlayerList do
        PlayerList[i] = PlayerList[i].Name;
    end;
    table.sort(PlayerList, function(str1, str2) return str1 < str2 end);

    return PlayerList;
end;

local function GetTeamsString()
    local TeamList = Teams:GetTeams();
    for i = 1, #TeamList do
        TeamList[i] = TeamList[i].Name;
    end;
    table.sort(TeamList, function(str1, str2) return str1 < str2 end);
    
    return TeamList;
end;

function Library:SafeCallback(f, ...)
    if (not f) then
        return;
    end;
    if not Library.NotifyOnError then
        return f(...);
    end;

    local success, event = pcall(f, ...);
    if not success then
        -- Roblox/Luau allows errors to be raised with non-string values.
        -- Never call string methods directly on the raw pcall error object.
        local message = tostring(event);
        local _, i = message:find(":%d+: ");
        if not i then
            return Library:Notify(message);
        end;
        return Library:Notify(message:sub(i + 1), 3);
    end;
end;

function Library:AttemptSave()
    if Library.SaveManager then
        Library.SaveManager:Save();
    end;
end;

function Library:Create(Class, Properties)
    local _Instance = Class;
    if type(Class) == 'string' then
        local ok, created = pcall(Instance.new, Class)
        if not ok then
            error(('Library:Create failed to create %q: %s'):format(tostring(Class), tostring(created)), 2)
        end
        _Instance = created
    end

    if typeof(_Instance) ~= 'Instance' then
        error(('Library:Create expected an Instance or class name, got %s'):format(typeof(_Instance)), 2)
    end

    -- Guard UI construction from class-specific properties. This prevents one
    -- invalid property from aborting the entire window during startup.
    for Property, Value in next, (Properties or {}) do
        local ok = pcall(function()
            _Instance[Property] = Value;
        end);
        if not ok and Library.DebugCreateErrors then
            warn(string.format('[CreU] ignored invalid property %q on %s', tostring(Property), _Instance.ClassName));
        end
    end

    if _Instance:IsA("TextLabel") or _Instance:IsA("TextBox") or _Instance:IsA("TextButton") then
        local textSize = Properties and tonumber(Properties.TextSize)
        if textSize then
            _Instance:SetAttribute("FontSizeOffset", textSize - Library.FontSize)
        else
            _Instance:SetAttribute("FontSizeOffset", 0)
        end
    end

    return _Instance;
end;

function Library:ApplyTextStroke(Inst)
    Inst.TextStrokeTransparency = 1;

    Library:Create('UIStroke', {
        Color = Color3.new(0, 0, 0);
        Thickness = 1;
        LineJoinMode = Enum.LineJoinMode.Miter;
        Parent = Inst;
    });
end;

function Library:ApplyGlow(Inst)

end;

function Library:CreateLabel(Properties, IsHud)
    local _Instance = Library:Create('TextLabel', {
        BackgroundTransparency = 1;
        Font = Library.Font;
        TextColor3 = Library.FontColor;
        TextSize = Library.FontSize; -- trước là FontSize+2, gây lệch cỡ chữ so với phần còn lại của UI (vd Dropdown)
        TextStrokeTransparency = 0;
    });
    Library:ApplyTextStroke(_Instance);

    Library:AddToRegistry(_Instance, {
        TextColor3 = 'FontColor';
    }, IsHud);
    return Library:Create(_Instance, Properties);
end;

local function GetAncestorUIScale(Instance)
    local Current = Instance
    while Current and Current ~= ScreenGui do
        for _, Child in ipairs(Current:GetChildren()) do
            if Child:IsA('UIScale') then
                return Child
            end
        end
        Current = Current.Parent
    end
    return nil
end

function Library:BeginGesture(Input, AllowCurrent)
    if Library.Unloaded or not Input then return false end
    local InputType = Input.UserInputType
    if InputType ~= Enum.UserInputType.MouseButton1
        and InputType ~= Enum.UserInputType.MouseButton2
        and InputType ~= Enum.UserInputType.Touch then
        return false
    end
    if Library.ActiveGestureInput ~= nil then
        -- Dropdown DragSelect may deliberately reuse the same InputObject across
        -- multiple item buttons; every other control remains single-owner.
        return AllowCurrent == true and Library.ActiveGestureInput == Input
    end
    Library.ActiveGestureInput = Input
    Library.ActiveGestureCleanups[Input] = Library.ActiveGestureCleanups[Input] or {}
    return true
end

function Library:RegisterGestureCleanup(Input, Cleanup)
    if not Input or type(Cleanup) ~= 'function' then return end
    if Library.ActiveGestureInput ~= Input then return end
    local Cleanups = Library.ActiveGestureCleanups[Input]
    if not Cleanups then
        Cleanups = {}
        Library.ActiveGestureCleanups[Input] = Cleanups
    end
    table.insert(Cleanups, Cleanup)
end

function Library:_CleanupGesture(Input)
    local Cleanups = Library.ActiveGestureCleanups[Input]
    Library.ActiveGestureCleanups[Input] = nil
    if not Cleanups then return end
    for Index = #Cleanups, 1, -1 do
        local Cleanup = Cleanups[Index]
        Cleanups[Index] = nil
        pcall(Cleanup)
    end
end

function Library:EndGesture(Input)
    if Library.ActiveGestureInput == Input then
        Library.ActiveGestureInput = nil
        Library:_CleanupGesture(Input)
        return true
    end
    return false
end

function Library:CancelGesture()
    local Input = Library.ActiveGestureInput
    Library.ActiveGestureInput = nil
    if Input then
        Library:_CleanupGesture(Input)
    end
end

function Library:MakeDraggable(Instance, Cutoff, IsWindow)
    if typeof(Instance) ~= 'Instance' then return nil end
    local DragCutoff = tonumber(Cutoff) or 40
    Instance.Active = true;
    Instance.InputBegan:Connect(function(Input)
        if Library.UILocked then return end
        if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch)
            and not Library:BeginGesture(Input) then
            return
        end
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            local StartPos = Instance.Position
            local DragStart = Input.Position

            if (DragStart.Y - Instance.AbsolutePosition.Y) > DragCutoff then
                Library:EndGesture(Input)
                return
            end

            local Dragging = true
            local HasMoved = false
            local Wireframe = nil
            local ChangedConn, EndedConn

            -- Track this exact InputObject (and its UserInputType) so that a
            -- different touch/mouse input ending elsewhere on screen can never
            -- prematurely stop or hijack this drag. Only the InputObject that
            -- began the drag, or a matching MouseMovement change, drives it.
            local DragInputType = Input.UserInputType

            ChangedConn = InputService.InputChanged:Connect(function(Change)
                if not Dragging then return end
                if Change == Input or (Change.UserInputType == Enum.UserInputType.MouseMovement and DragInputType == Enum.UserInputType.MouseButton1) then
                    local Delta = Change.Position - DragStart
                    
                    if IsWindow and Library.WireframeDrag then
                        if not HasMoved and Delta.Magnitude > 2 then
                            HasMoved = true
                            
                            Wireframe = Library:Create("Frame", {
                                Size = Instance.Size,
                                Position = Instance.Position,
                                AnchorPoint = Instance.AnchorPoint,
                                BackgroundTransparency = 1,
                                Active = false,
                                ZIndex = 100000,
                                Parent = ScreenGui
                            })
                         
                            local stroke = Library:Create("UIStroke", {
                                Color = Library.AccentColor,
                                Thickness = 1,
                                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                Parent = Wireframe
                            })
                        end
                        
                        if HasMoved and Wireframe then
                            Wireframe.Position = UDim2.new(
                                StartPos.X.Scale, StartPos.X.Offset + Delta.X,
                                StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y
                            )
                        end
                    else
                        HasMoved = HasMoved or Delta.Magnitude > 2
                        Instance.Position = UDim2.new(
                            StartPos.X.Scale, StartPos.X.Offset + Delta.X,
                            StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y
                        )
                    end
                end
            end)

            EndedConn = InputService.InputEnded:Connect(function(EndInput)
                -- Only the specific InputObject that started this drag may end it.
                if EndInput == Input then
                    Dragging = false
                    if IsWindow and Library.WireframeDrag and HasMoved and Wireframe then
                        Instance.Position = Wireframe.Position
                    end
                    Library:EndGesture(Input)
                end
            end)

            Library:RegisterGestureCleanup(Input, function()
                Dragging = false
                if ChangedConn then ChangedConn:Disconnect(); ChangedConn = nil end
                if EndedConn then EndedConn:Disconnect(); EndedConn = nil end
                if Wireframe then
                    if IsWindow and HasMoved then
                        Instance.Position = Wireframe.Position
                    end
                    Wireframe:Destroy()
                    Wireframe = nil
                end
            end)
        end
    end)
end;

function Library:AddToolTip(InfoStr, HoverInstance)
    if typeof(HoverInstance) ~= 'Instance' then return nil end
    InfoStr = tostring(InfoStr or '')
    local X, Y = Library:GetTextBounds(InfoStr, Library.Font, Library.FontSize);
    local Tooltip = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,

        Size = UDim2.fromOffset(X + 5, Y + 4),
        ZIndex = 100,
        Parent = Library.ScreenGui,

        Visible = false,
    })

    local Label = Library:CreateLabel({
        Position = UDim2.fromOffset(3, 1),
        Size = UDim2.fromOffset(X, Y);
        TextSize = Library.FontSize;
        Text = InfoStr,
        TextColor3 = Library.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = Tooltip.ZIndex + 1,

        Parent = Tooltip;
    });
    Library:AddToRegistry(Tooltip, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });
    Library:AddToRegistry(Label, {
        TextColor3 = 'FontColor',
    });
    local IsHovering = false

    HoverInstance.MouseEnter:Connect(function()
        if Library:MouseIsOverOpenedFrame() then
            return
        end

        IsHovering = true

        local MousePos = InputService:GetMouseLocation()
        Tooltip.Position = UDim2.fromOffset(MousePos.X + 15, MousePos.Y + 12)
        Tooltip.Visible = true

        while IsHovering do
            RunService.Heartbeat:Wait()
            local MousePos = InputService:GetMouseLocation()
        Tooltip.Position = UDim2.fromOffset(MousePos.X + 15, MousePos.Y + 12)
        end
    end)

    HoverInstance.MouseLeave:Connect(function()
        IsHovering = false
        Tooltip.Visible = false
    end)
end

function Library:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault)
    HighlightInstance.MouseEnter:Connect(function()
        local Reg = Library.RegistryMap[Instance];

        for Property, ColorIdx in next, Properties do
            Instance[Property] = Library[ColorIdx] or ColorIdx;

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end)

    HighlightInstance.MouseLeave:Connect(function()
        local Reg = Library.RegistryMap[Instance];

        for Property, ColorIdx in next, PropertiesDefault do
            Instance[Property] = Library[ColorIdx] or ColorIdx;

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end)
end;

function Library:MouseIsOverOpenedFrame(InputPos)
    local Pos = InputPos
    if typeof(Pos) ~= 'Vector2' then
        Pos = InputService:GetMouseLocation()
    end

    for Frame, _ in next, Library.OpenedFrames do
        if Frame and Frame.Parent then
            local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;
            if Pos.X >= AbsPos.X and Pos.X <= AbsPos.X + AbsSize.X
                and Pos.Y >= AbsPos.Y and Pos.Y <= AbsPos.Y + AbsSize.Y then
                return true;
            end;
        end;
    end;
end;

function Library:IsMouseOverFrame(Frame, InputPos)
    if not Frame or not Frame.Parent then return false end
    local Pos = InputPos
    if typeof(Pos) ~= 'Vector2' then
        Pos = InputService:GetMouseLocation()
    end
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;
    if Pos.X >= AbsPos.X and Pos.X <= AbsPos.X + AbsSize.X
        and Pos.Y >= AbsPos.Y and Pos.Y <= AbsPos.Y + AbsSize.Y then
        return true;
    end;
    return false
end;

function Library:UpdateDependencyBoxes()
    if Library.BatchUpdating then
        return;
    end;

    for _, Depbox in next, Library.DependencyBoxes do
        if type(Depbox) == 'table' and type(Depbox.Update) == 'function' then Depbox:Update() end;
    end;
end;

function Library:RefreshBatchedUI()
    for _, option in next, Options do
        if option and option.Type == 'Dropdown' and type(option.BuildDropdownList) == 'function' then
            pcall(option.BuildDropdownList, option);
            if type(option.Display) == 'function' then pcall(option.Display, option) end;
        end
    end

    self:UpdateDependencyBoxes();
end;

function Library:MapValue(Value, MinA, MaxA, MinB, MaxB)
    if MaxA == MinA then return MinB end
    return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB;
end;

function Library:GetTextBounds(Text, Font, Size, Resolution)
    Text = tostring(Text or '')
    Size = tonumber(Size) or Library.FontSize
    Font = Font or Library.Font
    local Bounds = TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(1920, 1080))
    return Bounds.X, Bounds.Y
end;

function Library:GetDarkerColor(Color)
    if typeof(Color) ~= 'Color3' then return Library.MainColor end
    local H, S, V = Color3.toHSV(Color);
    return Color3.fromHSV(H, S, V / 1.5);
end;

Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor);

function Library:AddToRegistry(Instance, Properties, IsHud)
    if typeof(Instance) ~= 'Instance' then return nil end
    Properties = type(Properties) == 'table' and Properties or {}
    local Idx = #Library.Registry + 1;
    local Data = {
        Instance = Instance;
        Properties = Properties;
        Idx = Idx;
    };

    table.insert(Library.Registry, Data);
    Library.RegistryMap[Instance] = Data;

    if IsHud then
        table.insert(Library.HudRegistry, Data);
    end;
end;

function Library:RemoveFromRegistry(Instance)
    local Data = Library.RegistryMap[Instance];

    if Data then
        for Idx = #Library.Registry, 1, -1 do
            if Library.Registry[Idx] == Data then
                table.remove(Library.Registry, Idx);
            end;
        end;

        for Idx = #Library.HudRegistry, 1, -1 do
            if Library.HudRegistry[Idx] == Data then
                table.remove(Library.HudRegistry, Idx);
            end;
        end;

        Library.RegistryMap[Instance] = nil;
    end;
end;

function Library:UpdateColorsUsingRegistry()
    if Library.AccentColor then
        Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)
    end

    for Idx = #Library.Registry, 1, -1 do
        local Object = Library.Registry[Idx]
        local InstanceObject = Object and Object.Instance
        if not Object or typeof(InstanceObject) ~= 'Instance' or not InstanceObject.Parent then
            if Object then
                Library.RegistryMap[InstanceObject] = nil
            end
            table.remove(Library.Registry, Idx)
        else
            for Property, ColorIdx in next, Object.Properties do
                pcall(function()
                    if type(ColorIdx) == 'string' then
                        local Color = Library[ColorIdx]
                        if Color ~= nil then InstanceObject[Property] = Color end
                    elseif type(ColorIdx) == 'function' then
                        InstanceObject[Property] = ColorIdx()
                    end
                end)
            end
        end
    end
end;

function Library:SetAccentColor(Color)
    if typeof(Color) ~= 'Color3' then
        return Library
    end
    Library.AccentColor = Color
    Library.AccentColorDark = Library:GetDarkerColor(Color)
    Library:UpdateColorsUsingRegistry()
    return Library
end

function Library:GiveSignal(Signal)
    if Signal then
        table.insert(Library.Signals, Signal)
    end
    return Signal
end

function Library:Unload()
    if Library.Unloaded then return end
    Library.Unloaded = true
    Library:CancelGesture()
    Library.ActiveGestureCleanups = {}

    for Idx = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Idx)
        if Connection then pcall(function() Connection:Disconnect() end) end
    end

    for Index = #Library._OnUnloadCallbacks, 1, -1 do
        local Callback = table.remove(Library._OnUnloadCallbacks, Index)
        if type(Callback) == 'function' then
            pcall(Callback)
        end
    end
    
    if Library.BlurEffect then
        Library.BlurEffect:Destroy()
        Library.BlurEffect = nil
    end

    if Library._MobileGui and Library._MobileGui.Parent then
        Library._MobileGui:Destroy()
    else
        local MobileGui = CoreGui:FindFirstChild('LinoriaMobileUI')
        if MobileGui then MobileGui:Destroy() end
    end
    Library._MobileGui = nil
    Library._MobileScale = nil
    Library._MobileLockRefresh = nil

    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
end

Library:GiveSignal(InputService.InputEnded:Connect(function(Input)
    -- This fallback runs after control-specific InputEnded callbacks. Running
    -- cleanup synchronously here would disconnect those callbacks before they
    -- can finish their click/drag logic because this signal is registered early.
    task.defer(function()
        if Library.ActiveGestureInput == Input then
            Library:EndGesture(Input)
        end
    end)
end))

function Library:OnUnload(Callback)
    if type(Callback) == 'function' then
        table.insert(Library._OnUnloadCallbacks, Callback)
    end
    return Library
end

Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(Instance)
    if Library.RegistryMap[Instance] then
        Library:RemoveFromRegistry(Instance);
    end;
end))

local BaseAddons = {};
do
    local Funcs = {};

    function Funcs:AddColorPicker(Idx, Info)
        Info = type(Info) == 'table' and Info or {};
        assert(self.TextLabel, 'AddColorPicker: this control does not expose an addon host. Use AddColorPicker on a label/toggle-compatible control.');
        local ToggleLabel = self.TextLabel;
        assert(Info.Default, 'AddColorPicker: Missing default value.');

        local ColorPicker = {
            Value = Info.Default;
            Transparency = Info.Transparency or 0;
            Type = 'ColorPicker';
            Title = type(Info.Title) == 'string' and Info.Title or 'Color picker',
            Callback = Info.Callback or function(Color) end;
        };

        function ColorPicker:SetHSVFromRGB(Color)
            local H, S, V = Color3.toHSV(Color);
            ColorPicker.Hue = H;
            ColorPicker.Sat = S;
            ColorPicker.Vib = V;
        end;

        ColorPicker:SetHSVFromRGB(ColorPicker.Value);
        local DisplayFrame = Library:Create('Frame', {
            BackgroundColor3 = ColorPicker.Value;
            BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(0, 28, 0, 14);
            ZIndex = 6;
            Parent = ToggleLabel;
        });
        local CheckerFrame = Library:Create('ImageLabel', {
            BorderSizePixel = 0;
            Size = UDim2.new(0, 27, 0, 13);
            ZIndex = 5;
            Image = 'http://www.roblox.com/asset/?id=12977615774';
            Visible = not not Info.Transparency;
            Parent = DisplayFrame;
        });

        local PickerFrameOuter = Library:Create('Frame', {
            Name = 'Color';
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18),
            Size = UDim2.fromOffset(230, Info.Transparency and 271 or 253);
            Visible = false;
            ZIndex = 15;
            Parent = ScreenGui,
        });
        DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
            PickerFrameOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18);
        end)

        local PickerFrameInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 16;
            Parent = PickerFrameOuter;
        });
        local Highlight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 2);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });
        local SatVibMapOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 4, 0, 25);
            Size = UDim2.new(0, 200, 0, 200);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });
        local SatVibMapInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = SatVibMapOuter;
        });
        local SatVibMap = Library:Create('ImageLabel', {
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Image = 'rbxassetid://4155801252';
            Parent = SatVibMapInner;
        });
        local CursorOuter = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0.5, 0.5);
            Size = UDim2.new(0, 6, 0, 6);
            BackgroundTransparency = 1;
            Image = 'http://www.roblox.com/asset/?id=9619665977';
            ImageColor3 = Color3.new(0, 0, 0);
            ZIndex = 19;
            Parent = SatVibMap;
        });
        local CursorInner = Library:Create('ImageLabel', {
            Size = UDim2.new(0, CursorOuter.Size.X.Offset - 2, 0, CursorOuter.Size.Y.Offset - 2);
            Position = UDim2.new(0, 1, 0, 1);
            BackgroundTransparency = 1;
            Image = 'http://www.roblox.com/asset/?id=9619665977';
            ZIndex = 20;
            Parent = CursorOuter;
        })

        local HueSelectorOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 208, 0, 25);
            Size = UDim2.new(0, 15, 0, 200);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local HueSelectorInner = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = HueSelectorOuter;
        });
        local HueCursor = Library:Create('Frame', { 
            BackgroundColor3 = Color3.new(1, 1, 1);
            AnchorPoint = Vector2.new(0, 0.5);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, 0, 0, 1);
            ZIndex = 18;
            Parent = HueSelectorInner;
        });

        local HueBoxOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(4, 228),
            Size = UDim2.new(0.5, -6, 0, 20),
            ZIndex = 18,
            Parent = PickerFrameInner;
        });
        local HueBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18,
            Parent = HueBoxOuter;
        });
        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = HueBoxInner;
        });

        local HueBox = Library:Create('TextBox', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = 'Hex color',
            Text = '#FFFFFF',
            TextColor3 = Library.FontColor;
            TextSize = Library.FontSize;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 20,
            Parent = HueBoxInner;
        });

        Library:ApplyTextStroke(HueBox);

        local RgbBoxBase = Library:Create(HueBoxOuter:Clone(), {
            Position = UDim2.new(0.5, 2, 0, 228),
            Size = UDim2.new(0.5, -6, 0, 20),
            Parent = PickerFrameInner
        });
        local RgbBox = Library:Create(RgbBoxBase:FindFirstChildWhichIsA('TextBox', true), {
            Text = '255, 255, 255',
            PlaceholderText = 'RGB color',
            TextColor3 = Library.FontColor
        });
        local TransparencyBoxOuter, TransparencyBoxInner, TransparencyCursor;
        
        if Info.Transparency then 
            TransparencyBoxOuter = Library:Create('Frame', {
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.fromOffset(4, 251);
                Size = UDim2.new(1, -8, 0, 15);
                ZIndex = 19;
                Parent = PickerFrameInner;
            });
            TransparencyBoxInner = Library:Create('Frame', {
                BackgroundColor3 = ColorPicker.Value;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 19;
                Parent = TransparencyBoxOuter;
            });
            Library:AddToRegistry(TransparencyBoxInner, { BorderColor3 = 'OutlineColor' });

            Library:Create('ImageLabel', {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                Image = 'http://www.roblox.com/asset/?id=12978095818';
                ZIndex = 20;
                Parent = TransparencyBoxInner;
            });
            TransparencyCursor = Library:Create('Frame', { 
                BackgroundColor3 = Color3.new(1, 1, 1);
                AnchorPoint = Vector2.new(0.5, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(0, 1, 1, 0);
                ZIndex = 21;
                Parent = TransparencyBoxInner;
            });
        end;

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 14);
            Position = UDim2.fromOffset(5, 5);
            TextXAlignment = Enum.TextXAlignment.Left;
            TextSize = Library.FontSize;
            Text = ColorPicker.Title,
            TextWrapped = false;
            ZIndex = 16;
            Parent = PickerFrameInner;
        });
        local ContextMenu = {}
        do
            ContextMenu.Options = {}
            ContextMenu.Container = Library:Create('Frame', {
                BorderColor3 = Color3.new(),
                ZIndex = 14,
                Visible = false,
                Parent = ScreenGui
            })

            ContextMenu.Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.fromScale(1, 1);
                ZIndex = 15;
                Parent = ContextMenu.Container;
            });
            Library:Create('UIListLayout', {
                Name = 'Layout',
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = ContextMenu.Inner;
            });
            Library:Create('UIPadding', {
                Name = 'Padding',
                PaddingLeft = UDim.new(0, 4),
                Parent = ContextMenu.Inner,
            });
            local function updateMenuPosition()
                ContextMenu.Container.Position = UDim2.fromOffset(
                    (DisplayFrame.AbsolutePosition.X + DisplayFrame.AbsoluteSize.X) + 4,
                    DisplayFrame.AbsolutePosition.Y + 1
                )
            end

            local function updateMenuSize()
                local menuWidth = 60
                for i, label in next, ContextMenu.Inner:GetChildren() do
                    if label:IsA('TextLabel') then
                        menuWidth = math.max(menuWidth, label.TextBounds.X)
                    end
                end

                ContextMenu.Container.Size = UDim2.fromOffset(
                    menuWidth + 8,
                    ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 4
                )
            end

            DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(updateMenuPosition)
            ContextMenu.Inner.Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateMenuSize)

            task.spawn(updateMenuPosition)
            task.spawn(updateMenuSize)

            Library:AddToRegistry(ContextMenu.Inner, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            function ContextMenu:Show()
                self.Container.Visible = true
            end

            function ContextMenu:Hide()
                self.Container.Visible = false
            end

            function ContextMenu:AddOption(Str, Callback)
                if type(Callback) ~= 'function' then
                    Callback = function() end
                end

                local Button = Library:CreateLabel({
                    Active = false;
                    Size = UDim2.new(1, 0, 0, 15);
                    TextSize = Library.FontSize - 1;
                    Text = Str;
                    ZIndex = 16;
                    Parent = self.Inner;
                    TextXAlignment = Enum.TextXAlignment.Left,
                });
                Library:OnHighlight(Button, Button, 
                    { TextColor3 = 'AccentColor' },
                    { TextColor3 = 'FontColor' }
                );
                Button.InputBegan:Connect(function(Input)
                    if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end
                    if not Library:BeginGesture(Input) then return end
                    Library:SafeCallback(Callback)
                    Library:EndGesture(Input)
                end)
            end

            ContextMenu:AddOption('Copy color', function()
                Library.ColorClipboard = ColorPicker.Value
                Library:Notify('Copied color!', 2)
            end)

            ContextMenu:AddOption('Paste color', function()
                if not Library.ColorClipboard then
                    return Library:Notify('You have not copied a color!', 2)
                end
                ColorPicker:SetValueRGB(Library.ColorClipboard)
            end)


            ContextMenu:AddOption('Copy HEX', function()
                if type(setclipboard) == 'function' then pcall(setclipboard, ColorPicker.Value:ToHex()) end
                Library:Notify('Copied hex code to clipboard!', 2)
            end)

            ContextMenu:AddOption('Copy RGB', function()
                if type(setclipboard) == 'function' then pcall(setclipboard, table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', ')) end
                Library:Notify('Copied RGB values to clipboard!', 2)
            end)

        end

        Library:AddToRegistry(PickerFrameInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(Highlight, { BackgroundColor3 = 'AccentColor'; });
        Library:AddToRegistry(SatVibMapInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(HueBoxInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(RgbBoxBase, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(RgbBox, { TextColor3 = 'FontColor', });
        Library:AddToRegistry(HueBox, { TextColor3 = 'FontColor', });

        local SequenceTable = {};
        for Hue = 0, 1, 0.1 do
            table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)));
        end;

        local HueSelectorGradient = Library:Create('UIGradient', {
            Color = ColorSequence.new(SequenceTable);
            Rotation = 90;
            Parent = HueSelectorInner;
        });
        HueBox.FocusLost:Connect(function(enter)
            if enter then
                local success, result = pcall(Color3.fromHex, HueBox.Text)
                if success and typeof(result) == 'Color3' then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
                end
            end

            ColorPicker:Display()
        end)

        RgbBox.FocusLost:Connect(function(enter)
            if enter then
                local r, g, b = RgbBox.Text:match('(%d+),%s*(%d+),%s*(%d+)')
                if r and g and b then
                    local ok, result = pcall(function()
                        return Color3.fromRGB(
                            math.clamp(tonumber(r), 0, 255),
                            math.clamp(tonumber(g), 0, 255),
                            math.clamp(tonumber(b), 0, 255)
                        )
                    end)
                    if ok then
                        ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
                    end
                end
            end

            ColorPicker:Display()
        end)

        function ColorPicker:Display()
            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
            SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);

            Library:Create(DisplayFrame, {
                BackgroundColor3 = ColorPicker.Value;
                BackgroundTransparency = ColorPicker.Transparency;
                BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
            });
            if TransparencyBoxInner then
                TransparencyBoxInner.BackgroundColor3 = ColorPicker.Value;
                TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0);
            end;

            CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0);
            HueCursor.Position = UDim2.new(0, 0, ColorPicker.Hue, 0);

            HueBox.Text = '#' .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', ')

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value);
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value);
        end;

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func;
            Library:SafeCallback(Func, ColorPicker.Value)
        end;

        function ColorPicker:Show()
            for Frame, Val in next, Library.OpenedFrames do
                if Frame.Name == 'Color' then
                    Frame.Visible = false;
                    Library.OpenedFrames[Frame] = nil;
                end;
            end;

            PickerFrameOuter.Visible = true;
            Library.OpenedFrames[PickerFrameOuter] = true;
        end;
        function ColorPicker:Hide()
            PickerFrameOuter.Visible = false;
            Library.OpenedFrames[PickerFrameOuter] = nil;
        end;
        function ColorPicker:SetValue(HSV, Transparency)
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);
            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        SatVibMap.InputBegan:Connect(function(Input)
            if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch)
                and Library:BeginGesture(Input) then
                local function UpdateColor(PosX, PosY)
                    local MinX = SatVibMap.AbsolutePosition.X;
                    local MaxX = MinX + SatVibMap.AbsoluteSize.X;
                    local MouseX = math.clamp(PosX, MinX, MaxX);

                    local MinY = SatVibMap.AbsolutePosition.Y;
                    local MaxY = MinY + SatVibMap.AbsoluteSize.Y;
                    local MouseY = math.clamp(PosY, MinY, MaxY);

                    ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX);
                    ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY));
                    ColorPicker:Display();
                end

                UpdateColor(Input.Position.X, Input.Position.Y)

                local ChangedConn = InputService.InputChanged:Connect(function(Change)
                    if Change == Input or (Change.UserInputType == Enum.UserInputType.MouseMovement and Input.UserInputType == Enum.UserInputType.MouseButton1) then
                        UpdateColor(Change.Position.X, Change.Position.Y)
                    end
                end)

                local EndedConn
                EndedConn = InputService.InputEnded:Connect(function(EndInput)
                    if EndInput == Input then
                        ChangedConn:Disconnect()
                        EndedConn:Disconnect()
                        Library:EndGesture(Input)
                        Library:AttemptSave()
                    end
                end)
                Library:RegisterGestureCleanup(Input, function()
                    if ChangedConn then ChangedConn:Disconnect(); ChangedConn = nil end
                    if EndedConn then EndedConn:Disconnect(); EndedConn = nil end
                end)
            end
        end);
        HueSelectorInner.InputBegan:Connect(function(Input)
            if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch)
                and Library:BeginGesture(Input) then
                local function UpdateHue(PosY)
                    local MinY = HueSelectorInner.AbsolutePosition.Y;
                    local MaxY = MinY + HueSelectorInner.AbsoluteSize.Y;
                    local MouseY = math.clamp(PosY, MinY, MaxY);

                    ColorPicker.Hue = ((MouseY - MinY) / (MaxY - MinY));
                    ColorPicker:Display();
                end

                UpdateHue(Input.Position.Y)

                local ChangedConn = InputService.InputChanged:Connect(function(Change)
                    if Change == Input or (Change.UserInputType == Enum.UserInputType.MouseMovement and Input.UserInputType == Enum.UserInputType.MouseButton1) then
                        UpdateHue(Change.Position.Y)
                    end
                end)

                local EndedConn
                EndedConn = InputService.InputEnded:Connect(function(EndInput)
                    if EndInput == Input then
                        ChangedConn:Disconnect()
                        EndedConn:Disconnect()
                        Library:EndGesture(Input)
                        Library:AttemptSave()
                    end
                end)
                Library:RegisterGestureCleanup(Input, function()
                    if ChangedConn then ChangedConn:Disconnect(); ChangedConn = nil end
                    if EndedConn then EndedConn:Disconnect(); EndedConn = nil end
                end)
            end
        end);
        -- Cùng lỗi hệ thống: mở/đóng bảng màu ngay khi chạm xuống khiến lỡ tay
        -- cuộn qua ô màu cũng làm nó tự bật ra. Chuột phải (mở menu ngữ cảnh) vẫn
        -- xử lý ngay vì đó không phải cử chỉ kéo/cuộn trên cảm ứng.
        DisplayFrame.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame(Input.Position) then
                if not Library:BeginGesture(Input) then return end
                ContextMenu:Show()
                ColorPicker:Hide()
                Library:EndGesture(Input)
                return
            end

            if (Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch)
                or Library:MouseIsOverOpenedFrame(Input.Position)
                or not Library:BeginGesture(Input) then return end

            local PressStart = Input.Position;
            local Moved = false;
            local ThisInput = Input;
            local ChangedConn, EndedConn;

            ChangedConn = InputService.InputChanged:Connect(function(Change)
                if Change ~= ThisInput and not (Change.UserInputType == Enum.UserInputType.MouseMovement and ThisInput.UserInputType == Enum.UserInputType.MouseButton1) then return end
                if (Change.Position - PressStart).Magnitude > 6 then
                    Moved = true;
                end
            end);
            EndedConn = InputService.InputEnded:Connect(function(EndInput)
                if EndInput ~= ThisInput then return end
                if ChangedConn then ChangedConn:Disconnect(); end
                if EndedConn then EndedConn:Disconnect(); end
                if not Moved and not Library:MouseIsOverOpenedFrame(EndInput.Position) then
                    if PickerFrameOuter.Visible then
                        ColorPicker:Hide()
                    else
                        ContextMenu:Hide()
                        ColorPicker:Show()
                    end;
                end
            end);
            Library:RegisterGestureCleanup(ThisInput, function()
                if ChangedConn then ChangedConn:Disconnect(); ChangedConn = nil end
                if EndedConn then EndedConn:Disconnect(); EndedConn = nil end
            end)
        end);

        if TransparencyBoxInner then
            TransparencyBoxInner.InputBegan:Connect(function(Input)
                if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch)
                    and Library:BeginGesture(Input) then
                    local function UpdateAlpha(PosX)
                        local MinX = TransparencyBoxInner.AbsolutePosition.X;
                        local MaxX = MinX + TransparencyBoxInner.AbsoluteSize.X;
                        local MouseX = math.clamp(PosX, MinX, MaxX);

                        ColorPicker.Transparency = 1 - ((MouseX - MinX) / (MaxX - MinX));
                        ColorPicker:Display();
                    end

                    UpdateAlpha(Input.Position.X)

                    local ChangedConn = InputService.InputChanged:Connect(function(Change)
                        if Change == Input or (Change.UserInputType == Enum.UserInputType.MouseMovement and Input.UserInputType == Enum.UserInputType.MouseButton1) then
                            UpdateAlpha(Change.Position.X)
                        end
                    end)

                    local EndedConn
                    EndedConn = InputService.InputEnded:Connect(function(EndInput)
                        if EndInput == Input then
                            ChangedConn:Disconnect()
                            EndedConn:Disconnect()
                            Library:AttemptSave()
                        end
                    end)
                    Library:RegisterGestureCleanup(Input, function()
                        if ChangedConn then ChangedConn:Disconnect(); ChangedConn = nil end
                        if EndedConn then EndedConn:Disconnect(); EndedConn = nil end
                    end)
                end
            end);
        end;

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                local AbsPos, AbsSize = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize;
                local DFPos = DisplayFrame.AbsolutePosition;
                local DFSize = DisplayFrame.AbsoluteSize;
                local InputPos = Input.Position
                if InputPos.X < AbsPos.X or InputPos.X > AbsPos.X + AbsSize.X
                    or InputPos.Y < DFPos.Y or InputPos.Y > DFPos.Y + DFSize.Y then
                    if not (InputPos.X >= DFPos.X and InputPos.X <= DFPos.X + DFSize.X
                        and InputPos.Y >= DFPos.Y and InputPos.Y <= DFPos.Y + DFSize.Y) then
                        ColorPicker:Hide();
                    end
                end;

                if not Library:IsMouseOverFrame(ContextMenu.Container, Input.Position) then
                    ContextMenu:Hide()
                end
            end;

            if Input.UserInputType == Enum.UserInputType.MouseButton2 and ContextMenu.Container.Visible then
                if not Library:IsMouseOverFrame(ContextMenu.Container, Input.Position) and not Library:IsMouseOverFrame(DisplayFrame, Input.Position) then
                    ContextMenu:Hide()
                end
            end
        end))

        function ColorPicker:GetTransparency()
            return ColorPicker.Transparency;
        end;

        function ColorPicker:OnTransparencyChanged(Func)
            ColorPicker.TransparencyChanged = Func;
            Library:SafeCallback(Func, ColorPicker.Transparency);
        end;

        local _OrigDisplay = ColorPicker.Display;
        ColorPicker.Display = function(self)
            _OrigDisplay(self);
            Library:SafeCallback(ColorPicker.TransparencyChanged, ColorPicker.Transparency);
        end;

        ColorPicker:Display();
        ColorPicker.DisplayFrame = DisplayFrame

        Options[Idx] = ColorPicker;

        return self;
    end;

    function Funcs:AddColorPickerAlpha(Idx, Info)
        Info = Info or {};
        if Info.Transparency == nil then
            Info.Transparency = 0;
        end;
        return Funcs.AddColorPicker(self, Idx, Info);
    end;

    function Funcs:AddKeyPicker(Idx, Info)
        Info = type(Info) == 'table' and Info or {};
        assert(self.TextLabel, 'AddKeyPicker: this control does not expose an addon host. Use AddKeyPicker on a label/toggle-compatible control.');
        local ParentObj = self;
        local ToggleLabel = self.TextLabel;
        local Container = self.Container;

        Info.Default = Info.Default ~= nil and Info.Default or 'None';
        local DefaultKey = tostring(Info.Default)
        local DefaultShowsUnknown = DefaultKey == 'Touch' or (InputService.TouchEnabled and DefaultKey == 'None')
        if DefaultKey == 'Touch' then
            DefaultKey = 'None'
        end

        local RequestedMode = Info.Mode or 'Toggle'
        if RequestedMode ~= 'Toggle' and RequestedMode ~= 'Always' and RequestedMode ~= 'Hold' then
            RequestedMode = 'Toggle'
        end

        local KeyPicker = {
            Value = DefaultKey;
            Toggled = false;
            Mode = RequestedMode;
            DisplayUnknown = DefaultShowsUnknown;
            Type = 'KeyPicker';
            Callback = Info.Callback or function(Value) end;
            ChangedCallback = Info.ChangedCallback or function(New) end;
            NoUI = Info.NoUI == true;
            MobileHeld = false;

            SyncToggleState = Info.SyncToggleState or false;
            _Initializing = true;
        };
        -- SyncToggleState controls how the picker mirrors its parent Toggle;
        -- it must not remove the normal Always/Toggle/Hold mode selector.
        -- The old implementation rewrote every SyncToggleState picker to
        -- Toggle-only, which was the direct cause of the one-item gear menu.

        local PickOuter = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Size = UDim2.new(0, 72, 0, 18);
            ZIndex = 6;
            Parent = ToggleLabel;
        });

        -- Do not rely on a Unicode gear glyph: its availability varies by font/device
        -- and was rendering as an empty/white box on some mobile clients.
        local GearButton = Library:Create('ImageButton', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Position = UDim2.fromOffset(0, 0);
            Size = UDim2.fromOffset(20, 18);
            AutoButtonColor = false;
            Image = 'rbxassetid://6031280882';
            ImageColor3 = Library.FontColor;
            ImageTransparency = 0;
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 8;
            Parent = PickOuter;
        });
        Library:AddToRegistry(GearButton, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
            ImageColor3 = 'FontColor';
        });

        local KeyButton = Library:Create('TextButton', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Position = UDim2.fromOffset(22, 0);
            Size = UDim2.fromOffset(50, 18);
            AutoButtonColor = false;
            Text = Info.Default;
            Font = Library.Font;
            TextSize = Library.FontSize - 1;
            TextColor3 = Library.FontColor;
            TextXAlignment = Enum.TextXAlignment.Center;
            ZIndex = 8;
            Parent = PickOuter;
        });
        Library:AddToRegistry(KeyButton, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
            TextColor3 = 'FontColor';
        });

        -- Keep the old internal variable name so all existing KeyPicker logic stays compatible.
        local DisplayLabel = KeyButton;

        local function GetKeyDisplayName(Key, ShowUnknown)
            Key = tostring(Key or 'None')
            if ShowUnknown and Key == 'None' then
                return 'Unknown'
            end
            if Key == 'Touch' then
                return 'Unknown'
            end
            if Key == 'None' then
                return '...'
            end
            return Key
        end

        local function RefreshKeyDisplay()
            DisplayLabel.Text = GetKeyDisplayName(KeyPicker.Value, KeyPicker.DisplayUnknown)
        end

        RefreshKeyDisplay()

        local function MarkControlInput(Input)
            KeyPicker._ControlInput = Input
            Input.Changed:Connect(function()
                if KeyPicker._ControlInput == Input and Input.UserInputState == Enum.UserInputState.End then
                    KeyPicker._ControlInput = nil
                end
            end)
        end

        local ModeSelectOuter = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.fromOffset(GearButton.AbsolutePosition.X, GearButton.AbsolutePosition.Y + GearButton.AbsoluteSize.Y + 2);
            Size = UDim2.new(0, 92, 0, 20);
            Visible = false;
            ZIndex = 114;
            Parent = ScreenGui;
        });
        GearButton:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
            if ModeSelectOuter and ModeSelectOuter.Parent then
                ModeSelectOuter.Position = UDim2.fromOffset(GearButton.AbsolutePosition.X, GearButton.AbsolutePosition.Y + GearButton.AbsoluteSize.Y + 2);
            end
        end);
        GearButton:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
            if ModeSelectOuter and ModeSelectOuter.Parent then
                ModeSelectOuter.Position = UDim2.fromOffset(GearButton.AbsolutePosition.X, GearButton.AbsolutePosition.Y + GearButton.AbsoluteSize.Y + 2);
            end
        end);
        local ModeSelectInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 15;
            Parent = ModeSelectOuter;
        });
        Library:AddToRegistry(ModeSelectInner, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });
        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ModeSelectInner;
        });
        local KeybindEntry = Library:Create('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Active = true,
            Visible = false,
            ZIndex = 110,
            Parent = Library.KeybindContainer,
        })

        local MobileBindButton = Library:Create('TextButton', {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.fromOffset(0, 0),
            Text = '',
            AutoButtonColor = false,
            Active = InputService.TouchEnabled,
            ZIndex = 112,
            Parent = KeybindEntry,
        })

        local ContainerLabel = Library:CreateLabel({
            Position = UDim2.new(0, 2, 0, 0),
            Size = UDim2.new(1, -4, 1, 0),
            TextSize = Library.FontSize - 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 113,
            Parent = KeybindEntry,
        }, true)

        local DefaultModes = { 'Always', 'Toggle', 'Hold' };
        local Modes = {};

        -- Normalize the list so an empty/malformed Modes table cannot produce a
        -- half-empty gear menu.
        if type(Info.Modes) == 'table' and #Info.Modes > 0 then
            local seenModes = {};
            for _, ModeName in ipairs(Info.Modes) do
                if (ModeName == 'Always' or ModeName == 'Toggle' or ModeName == 'Hold') and not seenModes[ModeName] then
                    Modes[#Modes + 1] = ModeName;
                    seenModes[ModeName] = true;
                end
            end
        end
        if #Modes == 0 then
            for _, ModeName in ipairs(DefaultModes) do
                Modes[#Modes + 1] = ModeName;
            end
        end

        -- Size from the normalized mode list, not the raw Info.Modes input.
        -- A malformed/empty Modes table must never collapse the gear popup.
        ModeSelectOuter.Size = UDim2.fromOffset(92, (#Modes * 18) + 2)

        local ModeButtons = {};

        for Idx, Mode in next, Modes do
            local ModeButton = {};
            local Button = Library:Create('TextButton', {
                Active = true;
                AutoButtonColor = false;
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 0, 18);
                TextSize = math.max(10, Library.FontSize - 1);
                Text = tostring(Mode);
                Font = Library.Font;
                TextColor3 = Library.FontColor;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 16;
                LayoutOrder = Idx;
                Parent = ModeSelectInner;
            });
            Library:AddToRegistry(Button, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
                TextColor3 = 'FontColor';
            });
            function ModeButton:Select()
                for _, Other in next, ModeButtons do
                    Other:Deselect();
                end;

                if Mode ~= 'Toggle' and Mode ~= 'Always' and Mode ~= 'Hold' then
                    return
                end
                KeyPicker.Mode = Mode;
                if Mode ~= 'Hold' then
                    KeyPicker.MobileHeld = false
                end
                Button.TextColor3 = Library.AccentColor;
                Library.RegistryMap[Button].Properties.TextColor3 = 'AccentColor';
                Button.BackgroundColor3 = Library.MainColor;
                Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';
                ModeSelectOuter.Visible = false;
                KeyPicker:Update();
                if not KeyPicker._Initializing then
                    Library:AttemptSave();
                end
            end;
            function ModeButton:Deselect()
                Button.TextColor3 = Library.FontColor;
                Library.RegistryMap[Button].Properties.TextColor3 = 'FontColor';
                Button.BackgroundColor3 = Library.BackgroundColor;
                Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';
            end;

            Button.InputBegan:Connect(function(Input)
                if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch)
                    and Library:BeginGesture(Input) then
                    MarkControlInput(Input)
                    ModeButton:Select();
                    Library:EndGesture(Input)
                end;
            end);
            -- Register the mode button before any initial selection.
            -- The previous order called Select() before KeyPicker:Update()
            -- existed, causing: "attempt to call missing method 'Update'"
            -- during KeyPicker construction. Initial selection is deferred
            -- until all KeyPicker methods have been defined below.
            ModeButtons[Mode] = ModeButton;
        end;

        function KeyPicker:Update()
            if Info.NoUI then
                return;
            end;
            if Library.Unloaded or not KeybindEntry.Parent or not ContainerLabel.Parent or not Library.KeybindContainer or not Library.KeybindContainer.Parent then
                return
            end

            if Library.ShowKeybinds == false then
                KeybindEntry.Visible = false
                if Library.KeybindFrame then
                    Library.KeybindFrame.Visible = false
                end
                return;
            end

            local State = KeyPicker:GetState();

            local displayKey = GetKeyDisplayName(KeyPicker.Value, KeyPicker.DisplayUnknown)
            ContainerLabel.Text = string.format('[%s] %s (%s)', displayKey, Info.Text, KeyPicker.Mode);
            local kbMode = Library.KeybindMode or 'All'
            if kbMode == 'Active' then
                local canOnlyBeTurnedOnHere = InputService.TouchEnabled
                    and not (ParentObj and ParentObj.Type == 'Toggle')
                KeybindEntry.Visible = State == true or canOnlyBeTurnedOnHere
            elseif kbMode == 'Toggled' then
                local parentOn = false
                if ParentObj and ParentObj.Type == 'Toggle' then
                    parentOn = ParentObj.Value == true
                elseif KeyPicker.SyncToggleState and ParentObj then
                    parentOn = ParentObj.Value == true
                else
                    parentOn = true
                end
                KeybindEntry.Visible = parentOn
            else
                KeybindEntry.Visible = true
            end

            -- An unbound key is still a useful mobile action.  When the keybind
            -- list is enabled, keep an Unknown/None entry visible on touch even
            -- though it cannot be activated by a physical keyboard key.  This
            -- makes the mobile keybind row discoverable and lets the user tap it
            -- to understand/edit the unbound action.
            if InputService.TouchEnabled and KeyPicker.Value == 'None' then
                KeybindEntry.Visible = true
            end

            ContainerLabel.TextColor3 = State and Library.AccentColor or Library.FontColor;
            Library.RegistryMap[ContainerLabel].Properties.TextColor3 = State and 'AccentColor' or 'FontColor';

            local YSize = 0
            local XSize = 0

            for _, Frame in next, Library.KeybindContainer:GetChildren() do
                if Frame:IsA('Frame') and Frame.Visible then
                    YSize = YSize + 20;
                    local LabelChild = Frame:FindFirstChildOfClass('TextLabel')
                    if LabelChild and (LabelChild.TextBounds.X + 20 > XSize) then
                        XSize = LabelChild.TextBounds.X + 20 
                    end
                end;
            end;

            Library.KeybindFrame.Size = UDim2.new(0, math.max(XSize + 10 + 15, 210), 0, YSize + 23)
            Library.KeybindFrame.Visible = YSize > 0
            if YSize > 0 then
                task.defer(function()
                    if Library.Unloaded or not Library.KeybindFrame or not Library.KeybindFrame.Parent then return end
                    local maxWidth = 0
                    for _, Frame in ipairs(Library.KeybindContainer:GetChildren()) do
                        if Frame:IsA('Frame') and Frame.Visible then
                            local LabelChild = Frame:FindFirstChildOfClass('TextLabel')
                            if LabelChild then
                                maxWidth = math.max(maxWidth, LabelChild.TextBounds.X + 20)
                            end
                        end
                    end
                    Library.KeybindFrame.Size = UDim2.fromOffset(math.max(maxWidth + 15, 210), YSize + 23)
                end)
            end
        end;
        function KeyPicker:GetState()
            if KeyPicker.Mode == 'Always' then
                return true;
            elseif KeyPicker.Mode == 'Hold' then
                return KeyPicker.Toggled == true;
            else
                return KeyPicker.Toggled;
            end;
        end;

        -- Now that Update/GetState exist, safely apply the initial mode.
        local InitialModeButton = ModeButtons[KeyPicker.Mode] or ModeButtons['Toggle'];
        if InitialModeButton then
            InitialModeButton:Select();
        end;
        KeyPicker._Initializing = false;

        function KeyPicker:SetValue(Data)
            Data = type(Data) == 'table' and Data or { Data, KeyPicker.Mode };

            local RawKey = Data[1] ~= nil and tostring(Data[1]) or 'None';
            local Key = RawKey;
            local Mode = Data[2] or KeyPicker.Mode or 'Toggle';

            if Mode ~= 'Toggle' and Mode ~= 'Always' and Mode ~= 'Hold' then
                Mode = 'Toggle'
            end

            -- Normalize every common unbound representation.
            local ExplicitUnknown = RawKey:lower() == 'unknown';
            if RawKey == 'Touch' or RawKey == '' or ExplicitUnknown then
                Key = 'None';
            end

            KeyPicker.DisplayUnknown = ExplicitUnknown
                or RawKey == 'Touch'
                or (InputService.TouchEnabled and Key == 'None');

            KeyPicker.Value = Key;
            RefreshKeyDisplay()

            local ModeButton = ModeButtons[Mode] or ModeButtons[KeyPicker.Mode] or ModeButtons['Toggle'];
            if ModeButton then
                ModeButton:Select();
            else
                KeyPicker.Mode = Mode;
            end
            KeyPicker:Update();
            return KeyPicker;
        end;

        function KeyPicker:OnClick(Callback)
            KeyPicker.Clicked = Callback
        end

        function KeyPicker:OnChanged(Callback)
            KeyPicker.Changed = Callback
            Library:SafeCallback(Callback, KeyPicker.Value)
        end

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, KeyPicker)
            table.insert(Library.KeyPickerList, KeyPicker)
        end

        function KeyPicker:DoClick()
            if ParentObj.Type == 'Toggle' and KeyPicker.SyncToggleState then
                KeyPicker._SyncingFromKeyPicker = true
                ParentObj:SetValue(not ParentObj.Value)
                KeyPicker._SyncingFromKeyPicker = nil
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)
        end

        local function SetMobileBindState(Active)
            if KeyPicker.Mode == 'Always' then
                KeyPicker.Toggled = true
                return
            end
            if KeyPicker.Mode == 'Hold' then
                if KeyPicker.MobileHeld == Active then
                    return
                end
                KeyPicker.MobileHeld = Active
                KeyPicker.Toggled = Active
                KeyPicker:DoClick()
                Library:AttemptSave()
                KeyPicker:Update()
                return
            end
            if Active then
                KeyPicker.Toggled = not KeyPicker.Toggled
                KeyPicker:DoClick()
                Library:AttemptSave()
                KeyPicker:Update()
            end
        end

        local Picking = false;
        local LongPressTime = Info.LongPressTime or 0.55;
        local TouchMoveThreshold = Info.TouchMoveThreshold or 10;

        local function OpenModeSelect()
            ModeSelectOuter.Visible = true;
        end;

        local function BeginPicking()
            if Picking or Library.Unloaded then
                return
            end

            Picking = true
            local Break = false
            local Text = ''
            DisplayLabel.Text = ''

            local Event
            Event = InputService.InputBegan:Connect(function(Input)
                if Library.Unloaded or not Picking then
                    return
                end

                local Key
                if Input.UserInputType == Enum.UserInputType.Keyboard then
                    if Input.KeyCode == Enum.KeyCode.Delete or Input.KeyCode == Enum.KeyCode.Backspace then
                        Key = 'None'
                    elseif Input.KeyCode == Enum.KeyCode.Escape then
                        Break = true
                        Picking = false
                        DisplayLabel.Text = GetKeyDisplayName(KeyPicker.Value, KeyPicker.DisplayUnknown)
                        if Event then
                            Event:Disconnect()
                            Event = nil
                        end
                        KeyPicker:Update()
                        return
                    else
                        Key = Input.KeyCode.Name
                    end
                elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Key = 'MB1'
                elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                    Key = 'MB2'
                elseif Input.UserInputType == Enum.UserInputType.Touch then
                    return
                end

                if not Key then
                    return
                end

                Break = true
                Picking = false
                KeyPicker.DisplayUnknown = Key == 'None' or (InputService.TouchEnabled and Key == 'None')
                KeyPicker.Value = Key
                RefreshKeyDisplay()
                local ChangedValue = Key == 'None' and 'None' or (Input.KeyCode or Input.UserInputType)
                Library:SafeCallback(KeyPicker.ChangedCallback, ChangedValue)
                Library:SafeCallback(KeyPicker.Changed, ChangedValue)
                Library:AttemptSave()
                if Event then
                    Event:Disconnect()
                    Event = nil
                end
                KeyPicker:Update()
            end)
            Library:GiveSignal(Event)

            task.spawn(function()
                while not Break and not Library.Unloaded and Picking and DisplayLabel.Parent do
                    if Text == '...' then
                        Text = ''
                    end
                    Text = Text .. '.'
                    DisplayLabel.Text = Text
                    task.wait(0.4)
                end
            end)
        end

        GearButton.InputBegan:Connect(function(Input)
            if Library:MouseIsOverOpenedFrame(Input.Position) then
                return;
            end;
            if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then
                return;
            end;
            if not Library:BeginGesture(Input) then
                return;
            end;
            MarkControlInput(Input)

            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Library:EndGesture(Input)
                OpenModeSelect();
            else
                local StartPosition = Input.Position;
                local TouchMoved = false;
                local TouchEnded = false;
                local ChangedConn;
                local EndedConn;
                local function cleanup()
                    if ChangedConn then ChangedConn:Disconnect(); ChangedConn = nil end
                    if EndedConn then EndedConn:Disconnect(); EndedConn = nil end
                end
                ChangedConn = InputService.InputChanged:Connect(function(Change)
                    if Change == Input and (Change.Position - StartPosition).Magnitude > TouchMoveThreshold then
                        TouchMoved = true;
                    end
                end)
                EndedConn = InputService.InputEnded:Connect(function(EndInput)
                    if EndInput ~= Input then return end
                    TouchEnded = true
                    cleanup()
                    Library:EndGesture(Input)
                    if not TouchMoved then
                        OpenModeSelect()
                    end
                end)
                Library:RegisterGestureCleanup(Input, cleanup)
            end
        end);

        KeyButton.InputBegan:Connect(function(Input)
            if Library:MouseIsOverOpenedFrame(Input.Position) then
                return;
            end;
            if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then
                return;
            end;
            if not Library:BeginGesture(Input) then
                return;
            end;
            MarkControlInput(Input)

            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Library:EndGesture(Input)
                BeginPicking();
            else
                -- Mobile has no physical key to capture. Tapping the key field
                -- therefore acts as an explicit "unbind" action: Q -> Unknown.
                Library:EndGesture(Input)
                KeyPicker:SetValue({ 'None', KeyPicker.Mode });
                Library:SafeCallback(KeyPicker.ChangedCallback, 'None');
                Library:SafeCallback(KeyPicker.Changed, 'None');
                Library:AttemptSave();
            end
        end);

        -- Mobile keybind interaction: the visible keybind row itself acts as the
        -- virtual key. Toggle taps switch state; Hold stays active while the
        -- finger is down; Always is continuously active and is not toggled.
        MobileBindButton.InputBegan:Connect(function(Input)
            if Input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end
            if not Library:BeginGesture(Input) then
                return
            end

            MarkControlInput(Input)
            KeyPicker._MobileBindInput = Input
            local StartPosition = Input.Position
            local Moved = false
            local ChangedConn
            local EndedConn
            local function cleanup()
                if ChangedConn then ChangedConn:Disconnect(); ChangedConn = nil end
                if EndedConn then EndedConn:Disconnect(); EndedConn = nil end
            end

            ChangedConn = InputService.InputChanged:Connect(function(Change)
                if Change ~= Input then return end
                if (Change.Position - StartPosition).Magnitude > TouchMoveThreshold then
                    Moved = true
                end
            end)

            EndedConn = InputService.InputEnded:Connect(function(EndInput)
                if EndInput ~= Input then return end
                cleanup()
                if not Moved then
                    if KeyPicker.Mode == 'Hold' then
                        SetMobileBindState(false)
                    elseif KeyPicker.Mode == 'Toggle' then
                        SetMobileBindState(true)
                    end
                elseif KeyPicker.Mode == 'Hold' then
                    SetMobileBindState(false)
                end
                Library:EndGesture(Input)
                if KeyPicker._ControlInput == Input then
                    KeyPicker._ControlInput = nil
                end
                KeyPicker._MobileBindInput = nil
            end)

            if KeyPicker.Mode == 'Hold' then
                SetMobileBindState(true)
            end
            Library:RegisterGestureCleanup(Input, cleanup)
        end)

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input, Processed)
            if Input == KeyPicker._ControlInput or Input == KeyPicker._MobileBindInput then
                return
            end
            if Input.UserInputType == Enum.UserInputType.Keyboard and Processed then
                return
            end
            if (not Picking) then
                local Key = KeyPicker.Value
                local Matches = false

                if Key == 'MB1' then
                    Matches = Input.UserInputType == Enum.UserInputType.MouseButton1
                elseif Key == 'MB2' then
                    Matches = Input.UserInputType == Enum.UserInputType.MouseButton2
                elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                    Matches = Input.KeyCode.Name == Key
                end

                if Matches then
                    if KeyPicker.Mode == 'Toggle' then
                        KeyPicker.Toggled = not KeyPicker.Toggled
                        KeyPicker:DoClick()
                    elseif KeyPicker.Mode == 'Hold' and not KeyPicker.Toggled then
                        KeyPicker.Toggled = true
                        KeyPicker:DoClick()
                    end
                    KeyPicker:Update();
                end
            end;
            if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                local AbsPos, AbsSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize;
                local InputPos = Input.Position
                local GearPos, GearSize = GearButton.AbsolutePosition, GearButton.AbsoluteSize
                local InGear = InputPos.X >= GearPos.X and InputPos.X <= GearPos.X + GearSize.X
                    and InputPos.Y >= GearPos.Y and InputPos.Y <= GearPos.Y + GearSize.Y
                local InMenu = InputPos.X >= AbsPos.X and InputPos.X <= AbsPos.X + AbsSize.X
                    and InputPos.Y >= AbsPos.Y and InputPos.Y <= AbsPos.Y + AbsSize.Y
                if not InGear and not InMenu then
                    ModeSelectOuter.Visible = false;
                end;
            end;
        end))

        Library:GiveSignal(InputService.InputEnded:Connect(function(Input)
            if Input == KeyPicker._ControlInput or Input == KeyPicker._MobileBindInput then
                if Input == KeyPicker._ControlInput then KeyPicker._ControlInput = nil end
                if Input == KeyPicker._MobileBindInput then KeyPicker._MobileBindInput = nil end
                return
            end
            if (not Picking) then
                local Key = KeyPicker.Value
                local Matches = false
                if Key == 'MB1' then
                    Matches = Input.UserInputType == Enum.UserInputType.MouseButton1
                elseif Key == 'MB2' then
                    Matches = Input.UserInputType == Enum.UserInputType.MouseButton2
                elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                    Matches = Input.KeyCode.Name == Key
                end

                if Matches and KeyPicker.Mode == 'Hold' and KeyPicker.Toggled then
                    KeyPicker.Toggled = false
                    KeyPicker:DoClick()
                end
                KeyPicker:Update();
            end;
        end))

        KeyPicker:Update();
        Options[Idx] = KeyPicker;

        return self;
    end;

    -- Extended component API kept separate from the rendering code so existing scripts remain compatible.
    function Funcs:SetDisabled(Disabled)
        self.Disabled = not not Disabled
        local ui = self._UI
        if ui and ui.Outer then
            ui.Outer.Active = not self.Disabled
            ui.Outer.BackgroundTransparency = self.Disabled and 0.35 or 0
        end
    end

    function Funcs:SetVisible(Visible)
        local IsVisible = Visible ~= false
        local ui = self._UI
        if ui and ui.Outer then
            ui.Outer.Visible = IsVisible
            local parent = ui.Outer.Parent
            if parent and parent.Parent then
                for _, box in next, Library.DependencyBoxes do
                    if box and box.Container == parent then
                        pcall(box.Resize, box)
                    end
                end
            end
        elseif self.TextLabel then
            self.TextLabel.Visible = IsVisible
        end
        return self
    end

    function Funcs:GetValue()
        return self.Value
    end

    function Funcs:SetTooltip(Text)
        -- Tooltips are attached during construction; keep this method as a compatibility no-op for runtime replacement.
        self.Tooltip = Text
    end

    -- Advanced slider controls.
    function Funcs:SetMin(Min)
        if self.Type ~= 'Slider' then return self end
        local n = tonumber(Min)
        if not n then return self end
        self.Min = math.min(n, self.Max)
        self:SetValue(self.Value)
        return self
    end

    function Funcs:SetMax(Max)
        if self.Type ~= 'Slider' then return self end
        local n = tonumber(Max)
        if not n then return self end
        self.Max = math.max(n, self.Min)
        self:SetValue(self.Value)
        return self
    end

    function Funcs:SetPrefix(Prefix)
        if self.Type == 'Slider' then self.Prefix = tostring(Prefix or '') ; self:Display() end
        return self
    end

    function Funcs:SetSuffix(Suffix)
        if self.Type == 'Slider' then self.Suffix = tostring(Suffix or '') ; self:Display() end
        return self
    end

    -- Advanced dropdown controls.
    function Funcs:SetDisabledValues(Values)
        if self.Type ~= 'Dropdown' and self.Type ~= 'PriorityDropdown' then return self end
        self.DisabledValues = {}
        if type(Values) == 'table' then
            for _, v in next, Values do self.DisabledValues[v] = true end
        end
        self:BuildDropdownList()
        return self
    end

    function Funcs:AddDisabledValues(Values)
        if self.Type ~= 'Dropdown' and self.Type ~= 'PriorityDropdown' then return self end
        for _, v in next, Values or {} do self.DisabledValues[v] = true end
        self:BuildDropdownList()
        return self
    end

    function Funcs:ClearDisabledValues()
        if self.Type ~= 'Dropdown' and self.Type ~= 'PriorityDropdown' then return self end
        self.DisabledValues = {}
        self:BuildDropdownList()
        return self
    end

    function Funcs:SelectAll()
        if self.Type ~= 'Dropdown' or not self.Multi then return self end
        local values = {}
        for _, v in next, self.Values do
            if not self.DisabledValues[v] then values[v] = true end
        end
        self:SetValue(values)
        return self
    end

    function Funcs:DeselectAll()
        if self.Type ~= 'Dropdown' or not self.Multi then return self end
        self:SetValue({})
        return self
    end

    function Funcs:Select(Value)
        if self.Type ~= 'Dropdown' and self.Type ~= 'PriorityDropdown' then return self end
        if self.Multi then
            local t = {}
            for k, v in next, self.Value or {} do t[k] = v end
            if table.find(self.Values, Value) and not self.DisabledValues[Value] then t[Value] = true end
            self:SetValue(t)
        elseif table.find(self.Values, Value) and not self.DisabledValues[Value] then
            self:SetValue(Value)
        end
        return self
    end

    function Funcs:Deselect(Value)
        if self.Type ~= 'Dropdown' and self.Type ~= 'PriorityDropdown' then return self end
        if self.Multi then
            local t = {}
            for k, v in next, self.Value or {} do t[k] = v end
            t[Value] = nil
            self:SetValue(t)
        elseif self.Value == Value and self.AllowNull then
            self:SetValue(nil)
        end
        return self
    end

    function Funcs:SetSearch(Text)
        if self.Type ~= 'Dropdown' and self.Type ~= 'PriorityDropdown' then return self end
        if self.Searchable == false then
            self.SearchText = ''
            local ui = self._UI
            if ui and ui.SearchBox and ui.SearchBox.Text ~= '' then
                ui.SearchBox.Text = ''
            end
            if type(self.BuildDropdownList) == 'function' then
                self:BuildDropdownList()
            end
            return self
        end
        Text = tostring(Text or '')
        local ui = self._UI
        if ui and ui.SearchBox then
            ui.SearchBox.Text = Text
        else
            self.SearchText = Text:lower()
            if type(self.BuildDropdownList) == 'function' then
                self:BuildDropdownList()
            end
        end
        return self
    end

    function Funcs:Refresh()
        if self.Type == 'Dropdown' then
            self:BuildDropdownList()
        elseif self.Type == 'Slider' then
            self:Display()
        elseif self.Type == 'Toggle' then
            self:Display()
        end
        return self
    end

    BaseAddons.__index = Funcs;
    BaseAddons.__namecall = function(Table, Key, ...)
        return Funcs[Key](...);
    end;
end;

local BaseGroupbox = {};

do
    local Funcs = {};
    function Funcs:AddBlank(Size)
        local Groupbox = self;
        local Container = Groupbox.Container;
        Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, Size);
            ZIndex = 1;
            Parent = Container;
        });
    end;

    function Funcs:AddRow(Columns)
        local Groupbox = self
        local Container = Groupbox.Container

        local ColumnsCount = type(Columns) == 'number' and math.max(1, Columns) or 2

        local RowOuter = Library:Create('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            ZIndex = 1,
            Parent = Container
        })

        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = RowOuter
        })

        local Boxes = {}

        for i = 1, ColumnsCount do
            local Box = { Type = 'Groupbox' }

            local BoxContainer = Library:Create('Frame', {
                BackgroundTransparency = 1,
                Size = UDim2.new(1 / ColumnsCount, -((ColumnsCount - 1) * 8) / ColumnsCount, 1, 0),
                ZIndex = 1,
                Parent = RowOuter
            })

            local BoxLayout = Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4),
                Parent = BoxContainer
            })

            Box.Container = BoxContainer
            setmetatable(Box, BaseGroupbox)

            function Box:Resize()
                local maxHeight = 0
                for _, child in next, RowOuter:GetChildren() do
                    if child:IsA('Frame') then
                        local layout = child:FindFirstChildOfClass('UIListLayout')
                        if layout and layout.AbsoluteContentSize.Y > maxHeight then
                            maxHeight = layout.AbsoluteContentSize.Y
                        end
                    end
                end
                RowOuter.Size = UDim2.new(1, 0, 0, maxHeight)
                if Groupbox.Resize then
                    Groupbox:Resize()
                end
            end

            BoxLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                Box:Resize()
            end)

            table.insert(Boxes, Box)
        end

        Groupbox:AddBlank(1)
        if Groupbox.Resize then Groupbox:Resize() end

        return unpack(Boxes)
    end;
    function Funcs:AddLabel(Text, DoesWrap)
        local Label = {};
        if type(Text) == 'table' then
            local Info = Text;
            Text = Info.Text or Info.Name or '';
            DoesWrap = Info.DoesWrap == true;
        end

        local Groupbox = self;
        local Container = Groupbox.Container;

        local TextLabel = Library:CreateLabel({
            Size = UDim2.new(1, -4, 0, 15);
            TextSize = Library.FontSize;
            Text = Text;
            TextWrapped = DoesWrap or false,
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
        });
        if DoesWrap then
            local Y = select(2, Library:GetTextBounds(Text, Library.Font, Library.FontSize, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
            TextLabel.Size = UDim2.new(1, -4, 0, Y)
        else
            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 4);
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TextLabel;
            });
        end

        Label.TextLabel = TextLabel;
        Label.Container = Container;
        Label.Addons = {};
        function Label:SetText(Text)
            TextLabel.Text = Text

            if DoesWrap then
                local Y = select(2, Library:GetTextBounds(Text, Library.Font, Library.FontSize, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
                TextLabel.Size = UDim2.new(1, -4, 0, Y)
            end

            Groupbox:Resize();
        end

        if (not DoesWrap) then
            setmetatable(Label, BaseAddons);
        end

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        return Label;
    end;
    function Funcs:AddButton(...)
        local Button = {};
        local function ProcessButtonParams(Class, Obj, ...)
            local Props = select(1, ...)
            if type(Props) == 'table' then
                Obj.Text = Props.Text
                Obj.Func = Props.Func
                Obj.DoubleClick = Props.DoubleClick
                Obj.Tooltip = Props.Tooltip
                Obj.Disabled = Props.Disabled == true
                Obj.DisabledTooltip = Props.DisabledTooltip
            else
                Obj.Text = select(1, ...)
                Obj.Func = select(2, ...)
            end

            assert(type(Obj.Func) == 'function', 'AddButton: `Func` callback is missing.');
        end

        ProcessButtonParams('Button', Button, ...)

        local Groupbox = self;
        local Container = Groupbox.Container;

        local function CreateBaseButton(Button)
            local Outer = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -4, 0, 20);
                Active = true;
                ZIndex = 5;
            });
            local Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 6;
                Parent = Outer;
            });
            local Label = Library:CreateLabel({
                Size = UDim2.new(1, 0, 1, 0);
                TextSize = Library.FontSize;
                Text = Button.Text;
                ZIndex = 6;
                Parent = Inner;
            });

            if Button.Disabled then
                Outer.BackgroundTransparency = 0.25
                Label.TextColor3 = Library.FontColor:Lerp(Color3.new(0,0,0), 0.45)
            end
            Library:Create('UIGradient', {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
                });
                Rotation = 90;
                Parent = Inner;
            });
            Library:AddToRegistry(Outer, {
                BorderColor3 = 'Black';
            });
            Library:AddToRegistry(Inner, {
                BackgroundColor3 = 'MainColor';
                BorderColor3 = 'OutlineColor';
            });
            Library:OnHighlight(Outer, Outer,
                { BorderColor3 = 'AccentColor' },
                { BorderColor3 = 'Black' }
            );
            return Outer, Inner, Label
        end

        local function InitEvents(Button)
            local PendingDoubleClick = false
            local PendingToken = 0

            local function ValidateClick(Position)
                if Library:MouseIsOverOpenedFrame(Position) then
                    return false
                end

                return true
            end

            local function ResetDoubleClick()
                PendingDoubleClick = false
                PendingToken += 1
                Button.Locked = false
                Library:RemoveFromRegistry(Button.Label)
                Library:AddToRegistry(Button.Label, { TextColor3 = 'FontColor' })
                Button.Label.TextColor3 = Library.FontColor
                Button.Label.Text = Button.Text
            end

            -- Outer is intentionally a Frame in CreU, not a GuiButton.
            -- Therefore .Activated is not a valid event here. Use the same
            -- InputBegan -> global InputChanged/InputEnded pattern as the rest
            -- of the library, while keeping the important tap-vs-drag behavior.
            Button.Outer.InputBegan:Connect(function(Input)
                local InputType = Input.UserInputType
                if InputType ~= Enum.UserInputType.MouseButton1 and InputType ~= Enum.UserInputType.Touch then
                    return
                end

                -- A second tap is allowed only while the double-click confirmation
                -- window is active. Other gestures are still single-owner.
                local IsConfirmationTap = Button.DoubleClick and PendingDoubleClick
                if Button.Disabled or (Button.Locked and not IsConfirmationTap) then
                    return
                end
                if not ValidateClick(Input.Position) then
                    return
                end
                if not Library:BeginGesture(Input) then
                    return
                end

                local PressStart = Input.Position
                local Moved = false
                local ThisInput = Input
                local ChangedConn, EndedConn

                ChangedConn = InputService.InputChanged:Connect(function(Change)
                    if Change ~= ThisInput and not (Change.UserInputType == Enum.UserInputType.MouseMovement and ThisInput.UserInputType == Enum.UserInputType.MouseButton1) then
                        return
                    end
                    if (Change.Position - PressStart).Magnitude > 6 then
                        Moved = true
                    end
                end)

                EndedConn = InputService.InputEnded:Connect(function(EndInput)
                    if EndInput ~= ThisInput then
                        return
                    end

                    if ChangedConn then ChangedConn:Disconnect(); ChangedConn = nil end
                    if EndedConn then EndedConn:Disconnect(); EndedConn = nil end

                    local ValidTap = not Moved and ValidateClick(EndInput.Position)
                    Library:EndGesture(ThisInput)

                    if not ValidTap then
                        return
                    end

                    if Button.DoubleClick then
                        if IsConfirmationTap then
                            PendingDoubleClick = false
                            PendingToken += 1
                            Button.Locked = false
                            Library:RemoveFromRegistry(Button.Label)
                            Library:AddToRegistry(Button.Label, { TextColor3 = 'FontColor' })
                            Button.Label.TextColor3 = Library.FontColor
                            Button.Label.Text = Button.Text
                            Library:SafeCallback(Button.Func)
                        else
                            PendingDoubleClick = true
                            PendingToken += 1
                            local Token = PendingToken
                            Button.Locked = true
                            Library:RemoveFromRegistry(Button.Label)
                            Library:AddToRegistry(Button.Label, { TextColor3 = 'AccentColor' })
                            Button.Label.TextColor3 = Library.AccentColor
                            Button.Label.Text = 'Are you sure?'

                            task.delay(0.5, function()
                                if PendingDoubleClick and PendingToken == Token and not Library.Unloaded then
                                    ResetDoubleClick()
                                end
                            end)
                        end
                    else
                        Library:SafeCallback(Button.Func)
                    end
                end)

                Library:RegisterGestureCleanup(ThisInput, function()
                    if ChangedConn then ChangedConn:Disconnect(); ChangedConn = nil end
                    if EndedConn then EndedConn:Disconnect(); EndedConn = nil end
                end)
            end)
        end

        Button.Outer, Button.Inner, Button.Label = CreateBaseButton(Button)
        Button.Outer.Parent = Container

        InitEvents(Button)

        function Button:AddTooltip(tooltip)
            if type(tooltip) == 'string' then
                Library:AddToolTip(tooltip, self.Outer)
            end
            return self
        end

        function Button:AddButton(...)
            local SubButton = {}

            ProcessButtonParams('SubButton', SubButton, ...)

            self.Outer.Size = UDim2.new(0.5, -2, 0, 20)

            SubButton.Outer, SubButton.Inner, SubButton.Label = CreateBaseButton(SubButton)

            SubButton.Outer.Position = UDim2.new(1, 3, 0, 0)
            SubButton.Outer.Size = UDim2.fromOffset(self.Outer.AbsoluteSize.X - 2, self.Outer.AbsoluteSize.Y)
            SubButton.Outer.Parent = self.Outer

            function SubButton:AddTooltip(tooltip)
                if type(tooltip) == 'string' then
                    Library:AddToolTip(tooltip, self.Outer)
                 end
                return SubButton
            end

            if type(SubButton.Tooltip) == 'string' then
                SubButton:AddTooltip(SubButton.Tooltip)
            end

            InitEvents(SubButton)
            return SubButton
        end

        if type(Button.Tooltip) == 'string' then
            Button:AddTooltip(Button.Tooltip)
        end

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        return Button;
    end;

    function Funcs:AddDivider()
        local Groupbox = self;
        local Container = self.Container

        local Divider = {
            Type = 'Divider',
        }

        Groupbox:AddBlank(2);
        local DividerOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 5);
            ZIndex = 5;
            Parent = Container;
        });
        local DividerInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DividerOuter;
        });
        Library:AddToRegistry(DividerOuter, {
            BorderColor3 = 'Black';
        });
        Library:AddToRegistry(DividerInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });
        Groupbox:AddBlank(9);
        Groupbox:Resize();
    end

    function Funcs:AddInput(Idx, Info)
        assert(Info.Text, 'AddInput: Missing `Text` string.')

        local Textbox = {
            Value = Info.Default or '';
            Numeric = Info.Numeric or false;
            Finished = Info.Finished or false;
            Type = 'Input';
            Callback = Info.Callback or function(Value) end;
        };
        local Groupbox = self;
        local Container = Groupbox.Container;

        local InputLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 15);
            TextSize = Library.FontSize;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
        });

        Groupbox:AddBlank(1);

        local TextBoxOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = 5;
            Parent = Container;
        });
        local TextBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = TextBoxOuter;
        });
        Library:AddToRegistry(TextBoxInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });
        Library:OnHighlight(TextBoxOuter, TextBoxOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );
        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, TextBoxOuter)
        end

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = TextBoxInner;
        });
        local Container = Library:Create('Frame', {
            BackgroundTransparency = 1;
            ClipsDescendants = true;

            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);

            ZIndex = 7;
            Parent = TextBoxInner;
        })

        local Box = Library:Create('TextBox', {
            BackgroundTransparency = 1;

            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(5, 1),

            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = Info.Placeholder or '';

            Text = Info.Default or '';
            TextColor3 = Library.FontColor;
            TextSize = Library.FontSize;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;

            ZIndex = 7;
            Parent = Container;
        });

        Library:ApplyTextStroke(Box);
        function Textbox:SetValue(Text)
            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength);
            end;

            if Textbox.Numeric then
                if (not tonumber(Text)) and Text:len() > 0 then
                    Text = Textbox.Value
                end
            end

            Textbox.Value = Text;
            Box.Text = Text;

            Library:SafeCallback(Textbox.Callback, Textbox.Value);
            Library:SafeCallback(Textbox.Changed, Textbox.Value);
        end;

        if Textbox.Finished then
            Box.FocusLost:Connect(function(enter)
                if not enter then return end

                Textbox:SetValue(Box.Text);
                Library:AttemptSave();
            end)
        else
            Box:GetPropertyChangedSignal('Text'):Connect(function()
                Textbox:SetValue(Box.Text);
                Library:AttemptSave();
            end);
        end

        local function Update()
            local PADDING = 2
            local reveal = Container.AbsoluteSize.X

            if not Box:IsFocused() or Box.TextBounds.X <= reveal - 2 * PADDING then
                Box.Position = UDim2.new(0, PADDING, 0, 0)
            else
                local cursor = Box.CursorPosition
                if cursor ~= -1 then
                    local subtext = string.sub(Box.Text, 1, cursor-1)
                    local width = TextService:GetTextSize(subtext, Box.TextSize, Box.Font, Vector2.new(math.huge, math.huge)).X

                    local currentCursorPos = Box.Position.X.Offset + width

                    if currentCursorPos < PADDING then
                        Box.Position = UDim2.fromOffset(PADDING-width, 0)
                    elseif currentCursorPos > reveal - PADDING - 1 then
                        Box.Position = UDim2.fromOffset(reveal-width-PADDING-1, 0)
                    end
                end
            end
        end

        task.spawn(Update)

        Box:GetPropertyChangedSignal('Text'):Connect(Update)
        Box:GetPropertyChangedSignal('CursorPosition'):Connect(Update)
        Box.FocusLost:Connect(Update)
        Box.Focused:Connect(Update)

        Library:AddToRegistry(Box, {
            TextColor3 = 'FontColor';
        });

        function Textbox:OnChanged(Func)
            Textbox.Changed = Func;
            Library:SafeCallback(Func, Textbox.Value);
        end;

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        Options[Idx] = Textbox;

        return Textbox;
    end;

    function Funcs:AddToggle(Idx, Info)
        Info = type(Info) == 'table' and Info or {}
        assert(Info.Text, 'AddToggle: Missing `Text` string.')

        local Toggle = {
            Value = Info.Default or false;
            Type = 'Toggle';

            Callback = Info.Callback or function(Value) end;
            Addons = {},
            Risky = Info.Risky,
        };
        local Groupbox = self;
        local Container = Groupbox.Container;

        local ToggleOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 13, 0, 13);
            ZIndex = 5;
            Parent = Container;
        });
        Library:AddToRegistry(ToggleOuter, {
            BorderColor3 = 'Black';
        });
        local ToggleInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = ToggleOuter;
        });
        Library:AddToRegistry(ToggleInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });
        local ToggleLabel = Library:CreateLabel({
            Size = UDim2.new(0, 216, 1, 0);
            Position = UDim2.new(1, 6, 0, 0);
            TextSize = Library.FontSize;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 6;
            Parent = ToggleInner;
        });
        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 4);
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ToggleLabel;
        });
        local ToggleRegion = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(0, 170, 1, 0);
            ZIndex = 8;
            Parent = ToggleOuter;
        });
        Library:OnHighlight(ToggleRegion, ToggleOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );
        function Toggle:UpdateColors()
            Toggle:Display();
        end;
        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, ToggleRegion)
        end

        function Toggle:Display()
            ToggleInner.BackgroundColor3 = Toggle.Value and Library.AccentColor or Library.MainColor;
            ToggleInner.BorderColor3 = Toggle.Value and Library.AccentColorDark or Library.OutlineColor;

            Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'MainColor';
            Library.RegistryMap[ToggleInner].Properties.BorderColor3 = Toggle.Value and 'AccentColorDark' or 'OutlineColor';
        end;

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func;
            Library:SafeCallback(Func, Toggle.Value);
        end;

        function Toggle:SetValue(Bool)
            Bool = (not not Bool);
            Toggle.Value = Bool;
            Toggle:Display();

            for _, Addon in next, Toggle.Addons do
                if Addon.Type == 'KeyPicker' and Addon.SyncToggleState then
                    Addon.Toggled = Bool
                    Addon:Update()
                    if not Addon._SyncingFromKeyPicker then
                        Library:SafeCallback(Addon.Callback, Bool)
                        Library:SafeCallback(Addon.Clicked, Bool)
                    end
                end
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value);
            Library:SafeCallback(Toggle.Changed, Toggle.Value);
            Library:UpdateDependencyBoxes();
        end;
        -- Cùng lỗi hệ thống: bật/tắt ngay khi chạm xuống khiến lỡ tay cuộn qua
        -- một Toggle cũng làm nó đổi trạng thái. Chỉ đổi khi thả tay ra mà không
        -- di chuyển quá một khoảng nhỏ (tap thật, không phải kéo/cuộn).
        ToggleRegion.InputBegan:Connect(function(Input)
            if (Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch)
                or Library:MouseIsOverOpenedFrame(Input.Position) then return end
            if not Library:BeginGesture(Input) then return end

            local PressStart = Input.Position;
            local Moved = false;
            local ThisInput = Input;
            local ChangedConn, EndedConn;

            ChangedConn = InputService.InputChanged:Connect(function(Change)
                if Change ~= ThisInput and not (Change.UserInputType == Enum.UserInputType.MouseMovement and ThisInput.UserInputType == Enum.UserInputType.MouseButton1) then return end
                if (Change.Position - PressStart).Magnitude > 6 then
                    Moved = true;
                end
            end);
            EndedConn = InputService.InputEnded:Connect(function(EndInput)
                if EndInput ~= ThisInput then return end
                if ChangedConn then ChangedConn:Disconnect(); end
                if EndedConn then EndedConn:Disconnect(); end
                if not Moved and not Library:MouseIsOverOpenedFrame(EndInput.Position) then
                    Toggle:SetValue(not Toggle.Value)
                    Library:AttemptSave();
                end
            end);
            Library:RegisterGestureCleanup(ThisInput, function()
                if ChangedConn then ChangedConn:Disconnect(); ChangedConn = nil end
                if EndedConn then EndedConn:Disconnect(); EndedConn = nil end
            end)
        end);
        if Toggle.Risky then
            Library:RemoveFromRegistry(ToggleLabel)
            ToggleLabel.TextColor3 = Library.RiskColor
            Library:AddToRegistry(ToggleLabel, { TextColor3 = 'RiskColor' })
        end

        Toggle:Display();
        Groupbox:AddBlank((Info.BlankSize or 5) + 2);
        Groupbox:Resize();

        Toggle.TextLabel = ToggleLabel;
        Toggle.Container = Container;
        setmetatable(Toggle, BaseAddons);

        Toggles[Idx] = Toggle;

        Library:UpdateDependencyBoxes();

        return Toggle;
    end;

    function Funcs:AddSlider(Idx, Info)
        Info = type(Info) == 'table' and Info or {}
        assert(Info.Text, 'AddSlider: Missing slider text.');
        assert(Info.Min ~= nil, 'AddSlider: Missing minimum value.');
        assert(Info.Max ~= nil, 'AddSlider: Missing maximum value.');
        assert(Info.Rounding ~= nil, 'AddSlider: Missing rounding value.');

        -- Be defensive about callers/configs that omit Default.  Linoria-style
        -- addons sometimes create a slider before applying their saved value.
        -- Falling back to Min keeps construction deterministic instead of
        -- aborting the whole UI build.
        local MinValue = tonumber(Info.Min) or 0
        local MaxValue = tonumber(Info.Max) or MinValue
        if MaxValue < MinValue then
            MinValue, MaxValue = MaxValue, MinValue
        end
        local DefaultValue = tonumber(Info.Default)
        if DefaultValue == nil then
            DefaultValue = MinValue
        end
        DefaultValue = math.clamp(DefaultValue, MinValue, MaxValue)

        local Slider = {
            Value = DefaultValue;
            Min = MinValue;
            Max = MaxValue;
            Rounding = tonumber(Info.Rounding) or 0;
            MaxSize = 232;
            Type = 'Slider';
            Callback = Info.Callback or function(Value) end;
            SupportsAddons = false;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;
        if not Info.Compact then
            Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10);
                TextSize = Library.FontSize;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                ZIndex = 5;
                Parent = Container;
            });
            Groupbox:AddBlank(3);
        end

        local SliderOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 13);
            ZIndex = 5;
            Parent = Container;
        });
        Library:AddToRegistry(SliderOuter, {
            BorderColor3 = 'Black';
        });
        local SliderInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = SliderOuter;
        });
        Library:AddToRegistry(SliderInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });
        local Fill = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderColor3 = Library.AccentColorDark;
            Size = UDim2.new(0, 0, 1, 0);
            ZIndex = 7;
            Parent = SliderInner;
        });
        Library:AddToRegistry(Fill, {
            BackgroundColor3 = 'AccentColor';
            BorderColor3 = 'AccentColorDark';
        });
        local HideBorderRight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Position = UDim2.new(1, 0, 0, 0);
            Size = UDim2.new(0, 1, 1, 0);
            ZIndex = 8;
            Parent = Fill;
        });

        Library:AddToRegistry(HideBorderRight, {
            BackgroundColor3 = 'AccentColor';
        });
        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = Library.FontSize;
            Text = 'Infinite';
            ZIndex = 9;
            Parent = SliderInner;
        });
        Library:OnHighlight(SliderOuter, SliderOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );
        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, SliderOuter)
        end

        function Slider:UpdateColors()
            Fill.BackgroundColor3 = Library.AccentColor;
            Fill.BorderColor3 = Library.AccentColorDark;
        end;

        function Slider:Display()
            local Prefix = Slider.Prefix ~= nil and Slider.Prefix or (Info.Prefix or '');
            local Suffix = Slider.Suffix ~= nil and Slider.Suffix or (Info.Suffix or '');
            local DisplayValue = Prefix .. tostring(Slider.Value) .. Suffix;

            if type(Info.FormatDisplayValue) == 'function' then
                local Ok, Result = pcall(Info.FormatDisplayValue, Slider, Slider.Value);
                if Ok and Result ~= nil then
                    DisplayValue = tostring(Result);
                end
            end

            if Info.Compact then
                DisplayLabel.Text = tostring(Info.Text or '') .. ': ' .. DisplayValue
            elseif Info.HideMax then
                DisplayLabel.Text = DisplayValue
            elseif type(Info.FormatDisplayValue) == 'function' then
                DisplayLabel.Text = DisplayValue
            else
                DisplayLabel.Text = string.format('%s/%s', DisplayValue, Prefix .. tostring(Slider.Max) .. Suffix);
            end

            local Range = Slider.Max - Slider.Min;
            local Alpha = Range ~= 0 and ((Slider.Value - Slider.Min) / Range) or 0;
            Alpha = math.clamp(Alpha, 0, 1);
            Fill.Size = UDim2.new(Alpha, 0, 1, 0);

            HideBorderRight.Visible = Alpha > 0 and Alpha < 1;
        end;
        function Slider:OnChanged(Func)
            Slider.Changed = Func;
            Library:SafeCallback(Func, Slider.Value);
        end;
        local function Round(Value)
            if Slider.Rounding == 0 then
                return math.floor(Value);
            end;


            return tonumber(string.format('%.' .. Slider.Rounding .. 'f', Value))
        end;
        function Slider:GetValueFromXOffset(X)
            local Width = SliderInner.AbsoluteSize.X;
            if Width <= 0 then
                return Slider.Min;
            end
            return Round(Library:MapValue(math.clamp(X, 0, Width), 0, Width, Slider.Min, Slider.Max));
        end;
        function Slider:SetValue(Str)
            local Num = tonumber(Str);
            if (not Num) then
                return;
            end;

            Num = math.clamp(Num, Slider.Min, Slider.Max);

            Slider.Value = Num;
            Slider:Display();

            Library:SafeCallback(Slider.Callback, Slider.Value);
            Library:SafeCallback(Slider.Changed, Slider.Value);
        end;
        SliderInner.InputBegan:Connect(function(Input)
            if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not Library:MouseIsOverOpenedFrame(Input.Position) then
                if not Library:BeginGesture(Input) then return end
                
                local function UpdateSlider(PosX)
                    local gPos = SliderInner.AbsolutePosition.X
                    local Width = SliderInner.AbsoluteSize.X
                    local Diff = PosX - gPos
                    local nX = math.clamp(Diff, 0, math.max(0, Width))

                    local nValue = Slider:GetValueFromXOffset(nX);
                    local OldValue = Slider.Value;
    
                    Slider.Value = nValue;

                    Slider:Display();

                    if nValue ~= OldValue then
                        Library:SafeCallback(Slider.Callback, Slider.Value);
                        Library:SafeCallback(Slider.Changed, Slider.Value);
                    end;
                end

                UpdateSlider(Input.Position.X)

                local ChangedConn = InputService.InputChanged:Connect(function(Change)
                    if Change == Input or (Change.UserInputType == Enum.UserInputType.MouseMovement and Input.UserInputType == Enum.UserInputType.MouseButton1) then
                        UpdateSlider(Change.Position.X)
                    end
                end)

                local EndedConn
                EndedConn = InputService.InputEnded:Connect(function(EndInput)
                    if EndInput == Input then
                        ChangedConn:Disconnect()
                        EndedConn:Disconnect()
                        Library:EndGesture(Input)
                        Library:AttemptSave()
                    end
                end)
                Library:RegisterGestureCleanup(Input, function()
                    if ChangedConn then ChangedConn:Disconnect(); ChangedConn = nil end
                    if EndedConn then EndedConn:Disconnect(); EndedConn = nil end
                end)
            end;
        end);

        Slider:Display();
        Slider._UI = { Outer = SliderOuter, Inner = SliderInner, Fill = Fill, Label = DisplayLabel };
        Slider.Disabled = false;
        Groupbox:AddBlank(Info.BlankSize or 6);
        Groupbox:Resize();

        Options[Idx] = Slider;
        setmetatable(Slider, BaseAddons);

        return Slider;
    end;
function Funcs:AddDropdown(Idx, Info)
        Info = Info or {};

        if Info.SpecialType == 'Player' then
            Info.Values = GetPlayersString();
            Info.AllowNull = true;
        elseif Info.SpecialType == 'Team' then
            Info.Values = GetTeamsString();
            Info.AllowNull = true;
        end;

        assert(Info.Values, 'AddDropdown: Missing dropdown value list.');
        assert(Info.AllowNull or Info.Default ~= nil or Info.Multi, 'AddDropdown: Missing default value. Pass `AllowNull` as true if this was intentional.');

        if (not Info.Text) then
            Info.Compact = true;
        end;

        local Values = Info.Values;
        if type(Values) ~= 'table' then
            Values = { Values };
        end;

        local Dropdown = {
            Values = Values;
            Value = Info.Multi and {} or nil;
            Multi = Info.Multi == true;
            Type = 'Dropdown';
            SpecialType = Info.SpecialType;
            Callback = Info.Callback or function(Value) end;
            Changed = nil;
            Disabled = Info.Disabled == true;
            Visible = Info.Visible ~= false;
            SearchText = '';
            Searchable = Info.Searchable == true or Info.Search == true;
            DisabledValues = {};
            ValueImages = Info.ValueImages or {};
            MaxVisibleItems = math.clamp(tonumber(Info.MaxVisibleDropdownItems or Info.MaxVisibleItems or Info.MaxItems or 8) or 8, 1, 40);
            ItemHeight = math.max(16, tonumber(Info.ItemHeight or 20) or 20);
            DragSelect = Info.DragSelect == true and Info.Multi == true;
            AllowNull = Info.AllowNull == true;
            Expandable = Info.Expandable ~= false;
            ExpandColumns = math.max(1, tonumber(Info.ExpandColumns) or 1);
            SelectAllButtons = Info.SelectAllButtons ~= false;
            MaxVisibleDropdownItems = math.clamp(tonumber(Info.MaxVisibleDropdownItems or Info.MaxVisibleItems or 8) or 8, 1, 40);
            Text = Info.Text;
            Placeholder = Info.Placeholder or 'Search...';
            SupportsAddons = false;
        };

        -- Accept both array-style and dictionary-style disabled values.
        if type(Info.DisabledValues) == 'table' then
            for Key, Val in next, Info.DisabledValues do
                if type(Key) == 'number' then
                    Dropdown.DisabledValues[Val] = true;
                elseif Val then
                    Dropdown.DisabledValues[Key] = true;
                end
            end
        end;

        local Groupbox = self;
        local Container = Groupbox.Container;

        if not Info.Compact then
            Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10);
                TextSize = Library.FontSize;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                ZIndex = 5;
                Parent = Container;
            });
            Groupbox:AddBlank(3);
        end

        local DropdownOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            Visible = Dropdown.Visible;
            ZIndex = 5;
            Parent = Container;
        });
        Library:AddToRegistry(DropdownOuter, { BorderColor3 = 'Black' });

        local DropdownInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DropdownOuter;
        });
        Library:AddToRegistry(DropdownInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local DropdownArrow = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(1, 0.5);
            BackgroundTransparency = 1;
            Position = UDim2.new(1, -5, 0.5, 0);
            Size = UDim2.new(0, 12, 0, 12);
            Image = 'http://www.roblox.com/asset/?id=6282522798';
            ImageTransparency = 0.15;
            ZIndex = 8;
            Parent = DropdownInner;
        });

        local ItemList = Library:CreateLabel({
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -22, 1, 0);
            TextSize = Library.FontSize;
            Text = '--';
            TextXAlignment = Enum.TextXAlignment.Left;
            TextWrapped = false;
            TextTruncate = Enum.TextTruncate.AtEnd;
            ZIndex = 7;
            Parent = DropdownInner;
        });

        Library:OnHighlight(DropdownOuter, DropdownOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );
        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, DropdownOuter);
        end

        local ListOuter = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.fromOffset(180, Dropdown.MaxVisibleItems * Dropdown.ItemHeight + 2);
            ZIndex = 20;
            Visible = false;
            Parent = ScreenGui;
        });
        -- The popup list is parented directly to ScreenGui (so it can render
        -- above everything and reposition freely), which means it does NOT
        -- inherit the window's UIScale. Without this, the open dropdown list
        -- text renders at full native size while the rest of the UI (inside
        -- the scaled window) renders smaller -- this was the "dropdown text
        -- bigger than the rest of the UI" bug. Mirror the window/mobile scale
        -- onto the list so it always matches.
        local OwnerScale = GetAncestorUIScale(DropdownOuter)
        local ListScale = Library:Create('UIScale', {
            Scale = OwnerScale and OwnerScale.Scale or Library.DPIScale or 1;
            Parent = ListOuter;
        });
        table.insert(Library._DropdownScales, ListScale);
        local OwnerScaleConn
        if OwnerScale then
            OwnerScaleConn = OwnerScale:GetPropertyChangedSignal('Scale'):Connect(function()
                if ListScale.Parent then
                    ListScale.Scale = OwnerScale.Scale
                elseif OwnerScaleConn then
                    OwnerScaleConn:Disconnect()
                    OwnerScaleConn = nil
                end
            end)
            ListOuter.AncestryChanged:Connect(function(_, Parent)
                if not Parent and OwnerScaleConn then
                    OwnerScaleConn:Disconnect()
                    OwnerScaleConn = nil
                end
            end)
        end
        Library:AddToRegistry(ListOuter, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        -- Always create the search field so Searchable can be toggled safely at runtime.
        -- Visibility and layout are controlled by Dropdown.Searchable; opening a dropdown
        -- never captures focus, so the mobile keyboard only appears after the user taps here.
        local SearchHeight = 24;
        local SearchBox = Library:Create('TextBox', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            Size = UDim2.new(1, -4, 0, 22);
            Position = UDim2.fromOffset(2, 2);
            ClearTextOnFocus = false;
            PlaceholderText = Dropdown.Placeholder;
            TextSize = math.max(10, Library.FontSize - 3);
            Text = '';
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 25;
            Visible = Dropdown.Searchable;
            Parent = ListOuter;
        });
        Library:AddToRegistry(SearchBox, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
            TextColor3 = 'FontColor';
            PlaceholderColor3 = 'FontColor';
        });
        Dropdown.SearchBox = SearchBox
        SearchBox:GetPropertyChangedSignal('Text'):Connect(function()
            if not Dropdown.Searchable then
                return;
            end
            Dropdown.SearchText = tostring(SearchBox.Text or ''):lower();
            Dropdown:BuildDropdownList();
        end);

        if #Dropdown.Values == 0 then
            local DictValues = Dropdown.Values
            local Keys = {}
            for Key, _ in next, DictValues do Keys[#Keys + 1] = Key end
            table.sort(Keys, function(a,b) return tostring(a) < tostring(b) end)
            Dropdown._DisplayValues = DictValues
            Dropdown.Values = Keys
            Info.FormatListValue = Info.FormatListValue or function(Value) return tostring(DictValues[Value] or Value) end
        end

        local Scrolling = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            CanvasSize = UDim2.new(0, 0, 0, 0);
            Position = UDim2.fromOffset(0, SearchHeight);
            Size = UDim2.new(1, 0, 1, -SearchHeight);
            ZIndex = 21;
            Parent = ListOuter;
            ScrollBarThickness = 3;
            ScrollBarImageColor3 = Library.AccentColor;
            VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right;
            AutomaticCanvasSize = Enum.AutomaticSize.None;
        });
        Library:AddToRegistry(Scrolling, { ScrollBarImageColor3 = 'AccentColor' });
        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 0);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Scrolling;
        });

        local Buttons = {};
        local DraggingSelection = false;
        local LastDragValue;

        local function ValueText(Value)
            if type(Dropdown._DisplayValues) == 'table' and Dropdown._DisplayValues[Value] ~= nil then
                Value = Dropdown._DisplayValues[Value]
            elseif type(Info.Values) == 'table' and #Info.Values == 0 and Info.Values[Value] ~= nil then
                Value = Info.Values[Value]
            end
            if Info.FormatListValue and type(Info.FormatListValue) == 'function' then
                local Ok, Result = pcall(Info.FormatListValue, Value);
                if Ok and Result ~= nil then return tostring(Result) end
            end
            return tostring(Value);
        end

        local function ValueExists(Value)
            if type(Dropdown.Values) ~= 'table' then return false end
            if Dropdown.Values[Value] ~= nil and type(Dropdown.Values) == 'table' and not (#Dropdown.Values > 0) then
                return true
            end
            return table.find(Dropdown.Values, Value) ~= nil;
        end

        local function Matches(Value)
            if not Dropdown.Searchable then return true end
            local Query = Dropdown.SearchText;
            if Query == '' then return true end
            local Text = ValueText(Value):lower();
            if Text:find(Query, 1, true) then return true end
            if type(Info.SearchAlias) == 'table' and Info.SearchAlias[Value] then
                return tostring(Info.SearchAlias[Value]):lower():find(Query, 1, true) ~= nil;
            end
            return false;
        end

        function Dropdown:Display()
            local Parts = {};
            if self.Multi then
                for _, Value in ipairs(self.Values) do
                    if self.Value[Value] then
                        Parts[#Parts + 1] = ValueText(Value);
                    end
                end
            elseif self.Value ~= nil then
                Parts[1] = ValueText(self.Value);
            end

            local Text = table.concat(Parts, ', ');
            if Text == '' then Text = Info.PlaceholderText or '--' end
            if Info.FormatDisplayValue and type(Info.FormatDisplayValue) == 'function' then
                local Ok, Result = pcall(Info.FormatDisplayValue, self.Value);
                if Ok and Result ~= nil then Text = tostring(Result) end
            end
            ItemList.Text = Text;
        end

        function Dropdown:GetActiveValues(ReturnCount)
            if self.Multi then
                local Active = {};
                for Value, Bool in next, self.Value do
                    if Bool then Active[#Active + 1] = Value end
                end
                if ReturnCount then return #Active end
                return Active;
            end
            return ReturnCount and (self.Value ~= nil and 1 or 0) or (self.Value and { self.Value } or {});
        end

        function Dropdown:BuildDropdownList()
            for _, ButtonData in next, Buttons do
                if ButtonData.Button then ButtonData.Button:Destroy() end
            end
            Buttons = {};

            local VisibleCount = 0;
            local Order = 0;
            for _, Value in ipairs(self.Values) do
                if Matches(Value) then
                    VisibleCount += 1;
                    Order += 1;

                    local Button = Library:Create('TextButton', {
                        AutoButtonColor = false;
                        BackgroundColor3 = Library.MainColor;
                        BorderColor3 = Library.OutlineColor;
                        BorderSizePixel = 1;
                        Size = UDim2.new(1, -1, 0, self.ItemHeight);
                        Text = ValueText(Value);
                        TextColor3 = Library.FontColor;
                        TextSize = math.max(10, Library.FontSize - 4);
                        TextXAlignment = Enum.TextXAlignment.Left;
                        Active = not self.Disabled and not self.DisabledValues[Value];
                        ZIndex = 23;
                        LayoutOrder = Order;
                        Parent = Scrolling;
                    });
                    Library:AddToRegistry(Button, {
                        BackgroundColor3 = 'MainColor';
                        BorderColor3 = 'OutlineColor';
                        TextColor3 = 'FontColor';
                    });

                    local Padding = Library:Create('UIPadding', {
                        PaddingLeft = UDim.new(0, 6);
                        PaddingRight = UDim.new(0, 6);
                        Parent = Button;
                    });

                    local Data = { Button = Button; Value = Value };
                    Buttons[#Buttons + 1] = Data;

                    local function UpdateButton()
                        local Selected = self.Multi and self.Value[Value] or self.Value == Value;
                        local Disabled = self.Disabled or self.DisabledValues[Value];
                        Button.TextColor3 = Disabled and Library.FontColor:Lerp(Color3.new(0, 0, 0), 0.45)
                            or (Selected and Library.AccentColor or Library.FontColor);
                        Button.BackgroundTransparency = Selected and 0.08 or 0;
                        Button.Active = not Disabled;
                    end
                    Data.Update = UpdateButton;
                    UpdateButton();

                    Button.MouseEnter:Connect(function()
                        if Button.Active and not self.Disabled then
                            Button.BackgroundTransparency = 0.15;
                        end
                    end);
                    Button.MouseLeave:Connect(function()
                        UpdateButton();
                    end);

                    local function ToggleValue()
                        if self.Multi then
                            if self.Value[Value] then
                                self.Value[Value] = nil;
                            else
                                self.Value[Value] = true;
                            end
                            self:Display();
                            self:RunChanged();
                            self:RefreshButtons();
                        else
                            if self.Value == Value then
                                if self.AllowNull then
                                    self.Value = nil;
                                else
                                    return;
                                end
                            else
                                self.Value = Value;
                            end
                            self:Display();
                            self:RunChanged();
                            self:RefreshButtons();
                            self:CloseDropdown();
                        end
                        Library:AttemptSave();
                    end
                    Data.ToggleValue = ToggleValue;

                    -- A touch/mouse press only counts as a tap-to-select once it
                    -- releases *without* enough movement to be a scroll gesture.
                    -- This is what previously caused "drag xuống thì tự chọn":
                    -- InputBegan alone was firing ToggleValue() immediately, so
                    -- simply starting to scroll the list selected the first item
                    -- your finger touched. Now selection commits on release,
                    -- and only if the touch never moved past a small threshold.
                    Button.InputBegan:Connect(function(Input)
                        if not Button.Active or self.Disabled then return end
                        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end
                        if not Library:BeginGesture(Input) then return end

                        local PressStart = Input.Position;
                        local Moved = false;
                        local ThisInput = Input;

                        local ChangedConn, EndedConn;
                        ChangedConn = InputService.InputChanged:Connect(function(Change)
                            if Change ~= ThisInput and not (Change.UserInputType == Enum.UserInputType.MouseMovement and ThisInput.UserInputType == Enum.UserInputType.MouseButton1) then return end
                            local Delta = (Change.Position - PressStart).Magnitude;
                            if Delta > 6 then
                                Moved = true;
                                if self.Multi and self.DragSelect and not DraggingSelection then
                                    DraggingSelection = true;
                                    LastDragValue = Value;
                                    ToggleValue();
                                end
                            end
                            if DraggingSelection and self.Multi and self.DragSelect then
                                -- Only toggle newly-entered items while the
                                -- pointer is actually over this button.
                                local AbsPos = Button.AbsolutePosition;
                                local AbsSize = Button.AbsoluteSize;
                                local Px, Py = Change.Position.X, Change.Position.Y;
                                if Px >= AbsPos.X and Px <= AbsPos.X + AbsSize.X and Py >= AbsPos.Y and Py <= AbsPos.Y + AbsSize.Y then
                                    if LastDragValue ~= Value then
                                        LastDragValue = Value;
                                        ToggleValue();
                                    end
                                end
                            end
                        end);
                        EndedConn = InputService.InputEnded:Connect(function(EndInput)
                            if EndInput ~= ThisInput then return end
                            if ChangedConn then ChangedConn:Disconnect(); end
                            if EndedConn then EndedConn:Disconnect(); end
                            DraggingSelection = false;
                            if not Moved then
                                LastDragValue = Value;
                                ToggleValue();
                            end
                        end);
                        Library:RegisterGestureCleanup(ThisInput, function()
                            if ChangedConn then ChangedConn:Disconnect(); ChangedConn = nil end
                            if EndedConn then EndedConn:Disconnect(); EndedConn = nil end
                        end)
                    end);
                end
            end

            local CanvasHeight = VisibleCount * self.ItemHeight;
            local ActiveSearchHeight = self.Searchable and SearchHeight or 0;
            Scrolling.Position = UDim2.fromOffset(0, ActiveSearchHeight);
            Scrolling.Size = UDim2.new(1, 0, 1, -ActiveSearchHeight);
            SearchBox.Visible = self.Searchable;
            if not self.Searchable and self.SearchText ~= '' then
                self.SearchText = '';
                SearchBox.Text = '';
            end
            Scrolling.CanvasSize = UDim2.fromOffset(0, CanvasHeight + 2);
            local Height = math.min(math.max(1, VisibleCount), self.MaxVisibleItems) * self.ItemHeight + ActiveSearchHeight + 2;
            local CurrentScale = ListScale.Scale
            if CurrentScale <= 0 then CurrentScale = 1 end
            local UnscaledWidth = DropdownOuter.AbsoluteSize.X / CurrentScale
            local UnscaledHeight = Height / CurrentScale
            ListOuter.Size = UDim2.fromOffset(math.max(120 / CurrentScale, UnscaledWidth), UnscaledHeight);
        end

        function Dropdown:RefreshButtons()
            for _, Data in next, Buttons do
                if Data.Update then Data.Update() end
            end
        end

        function Dropdown:RunChanged()
            if self.Disabled then return end
            Library:SafeCallback(self.Callback, self.Value);
            Library:SafeCallback(self.Changed, self.Value);
            Library:UpdateDependencyBoxes();
        end

        local function RecalculateListPosition()
            local Camera = workspace.CurrentCamera
            local View = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
            local DropPos = DropdownOuter.AbsolutePosition
            local DropSize = DropdownOuter.AbsoluteSize
            local ListSize = ListOuter.AbsoluteSize
            local X = DropPos.X
            local Y = DropPos.Y + DropSize.Y + 1
            if Y + ListSize.Y > View.Y then
                Y = math.max(4, DropPos.Y - ListSize.Y - 1)
            end
            if X + ListSize.X > View.X then
                X = math.max(4, View.X - ListSize.X - 4)
            end
            if X < 4 then X = 4 end
            if Y < 4 then Y = 4 end
            ListOuter.Position = UDim2.fromOffset(X, Y)
        end

        function Dropdown:OpenDropdown()
            if self.Disabled or ListOuter.Visible then return end
            if SearchBox and SearchBox.Text ~= '' then
                SearchBox.Text = '';
            end
            self.SearchText = '';
            ListOuter.Visible = true;
            Library.OpenedFrames[ListOuter] = true;
            DropdownArrow.Rotation = 180;
            self:BuildDropdownList();
            RecalculateListPosition();
        end

        function Dropdown:CloseDropdown()
            if SearchBox then
                -- Closing a searchable dropdown should also dismiss a keyboard that
                -- was opened by explicitly tapping its SearchBox.
                pcall(function() SearchBox:ReleaseFocus() end)
            end
            ListOuter.Visible = false;
            Library.OpenedFrames[ListOuter] = nil;
            DropdownArrow.Rotation = 0;
            DraggingSelection = false;
        end

        function Dropdown:OnChanged(Func)
            self.Changed = Func;
            Library:SafeCallback(Func, self.Value);
        end

        function Dropdown:SetValue(Val)
            if self.Multi then
                local Next = {};
                if type(Val) == 'table' then
                    for Key, Bool in next, Val do
                        local Candidate = Bool == true and Key or (type(Key) == 'number' and Bool or nil);
                        if Candidate ~= nil and ValueExists(Candidate) and not self.DisabledValues[Candidate] then
                            Next[Candidate] = true;
                        end
                    end
                end
                self.Value = Next;
            else
                if Val == nil then
                    self.Value = nil;
                elseif ValueExists(Val) and not self.DisabledValues[Val] then
                    self.Value = Val;
                end
            end

            if not Library.BatchUpdating then
                self:BuildDropdownList();
            end
            self:Display();
            self:RunChanged();
        end

        function Dropdown:SetValues(NewValues)
            if type(NewValues) ~= 'table' then return self end
            if #NewValues == 0 then
                self._DisplayValues = NewValues
                local Keys = {}
                for Key in next, NewValues do Keys[#Keys + 1] = Key end
                table.sort(Keys, function(a, b) return tostring(a) < tostring(b) end)
                self.Values = Keys
            else
                self._DisplayValues = nil
                self.Values = NewValues
            end
            if self.Multi then
                for Value in next, self.Value do
                    if not ValueExists(Value) then self.Value[Value] = nil end
                end
            elseif self.Value ~= nil and not ValueExists(self.Value) then
                self.Value = nil;
            end
            if not Library.BatchUpdating then self:BuildDropdownList() end
            self:Display();
            return self;
        end

        function Dropdown:AddValues(NewValues)
            if type(NewValues) ~= 'table' then return self end
            for _, Value in ipairs(NewValues) do
                if not ValueExists(Value) then table.insert(self.Values, Value) end
            end
            if not Library.BatchUpdating then self:BuildDropdownList() end
            return self;
        end

        function Dropdown:SetDisabledValues(NewValues)
            self.DisabledValues = {};
            self:AddDisabledValues(NewValues);
            return self;
        end

        function Dropdown:AddDisabledValues(NewValues)
            if type(NewValues) ~= 'table' then return self end
            for Key, Value in next, NewValues do
                if type(Key) == 'number' then
                    self.DisabledValues[Value] = true
                elseif Value then
                    self.DisabledValues[Key] = true
                end
            end
            self:RefreshButtons();
            return self;
        end

        function Dropdown:SetValueImages(NewValues)
            self.ValueImages = type(NewValues) == 'table' and NewValues or {};
            self:BuildDropdownList();
            return self;
        end

        function Dropdown:AddValueImages(NewValues)
            if type(NewValues) ~= 'table' then return end
            for Key, Value in next, NewValues do self.ValueImages[Key] = Value end
            self:BuildDropdownList();
        end

        function Dropdown:Select(Value, Silent)
            if not self.Multi then
                self:SetValue(Value);
                return;
            end
            if ValueExists(Value) and not self.DisabledValues[Value] then
                self.Value[Value] = true;
                self:Display();
                self:RefreshButtons();
                if not Silent then self:RunChanged() end
            end
        end

        function Dropdown:Deselect(Value, Silent)
            if not self.Multi then return end
            self.Value[Value] = nil;
            self:Display();
            self:RefreshButtons();
            if not Silent then self:RunChanged() end
        end

        function Dropdown:SelectAll(Search)
            local Query = Search and tostring(Search):lower() or '';
            if not self.Multi then return end
            for _, Value in ipairs(self.Values) do
                if Query == '' or ValueText(Value):lower():find(Query, 1, true) then
                    if not self.DisabledValues[Value] then self.Value[Value] = true end
                end
            end
            self:Display(); self:RefreshButtons(); self:RunChanged();
        end

        function Dropdown:DeselectAll(Search)
            local Query = Search and tostring(Search):lower() or '';
            if not self.Multi then return end
            if Query == '' then
                self.Value = {};
            else
                for _, Value in ipairs(self.Values) do
                    if ValueText(Value):lower():find(Query, 1, true) then self.Value[Value] = nil end
                end
            end
            self:Display(); self:RefreshButtons(); self:RunChanged();
        end

        function Dropdown:SetDisabled(Disabled)
            self.Disabled = Disabled == true;
            DropdownOuter.Active = not self.Disabled;
            if self.Disabled then self:CloseDropdown() end
            self:RefreshButtons();
        end

        function Dropdown:SetVisible(Visible)
            self.Visible = Visible == true;
            DropdownOuter.Visible = self.Visible;
            Groupbox:Resize();
        end

        function Dropdown:SetText(Text)
            self.Text = Text;
            -- Compact label is intentionally not rebuilt; preserve existing Linoria layout semantics.
        end

        function Dropdown:SetMaxVisibleItems(Count)
            self.MaxVisibleItems = math.clamp(tonumber(Count) or 8, 1, 40);
            self.MaxVisibleDropdownItems = self.MaxVisibleItems;
            self:BuildDropdownList();
        end

        function Dropdown:SetItemHeight(Height)
            self.ItemHeight = math.max(16, tonumber(Height) or 20);
            self:BuildDropdownList();
        end

        function Dropdown:SetMaxVisibleDropdownItems(Count) return self:SetMaxVisibleItems(Count) end
        function Dropdown:SetExpandable(Value) self.Expandable = Value ~= false; return self end
        function Dropdown:Expand() return self:OpenDropdown() end
        function Dropdown:Collapse() return self:CloseDropdown() end
        function Dropdown:ToggleExpanded() if ListOuter.Visible then self:CloseDropdown() else self:OpenDropdown() end return self end
        function Dropdown:SetSelectAllButtons(Value) self.SelectAllButtons = Value ~= false; return self end
        function Dropdown:SetExpandColumns(Count) self.ExpandColumns = math.max(1, tonumber(Count) or 1); return self end

        function Dropdown:SetSearchable(Value)
            Value = Value == true;
            if Value == self.Searchable then
                if SearchBox then SearchBox.Visible = Value end
                return self
            end
            self.Searchable = Value;
            self.SearchText = '';
            SearchBox.Text = '';
            SearchBox.Visible = Value;
            self:BuildDropdownList();
            return self;
        end

        DropdownOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(RecalculateListPosition);
        DropdownOuter:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
            RecalculateListPosition();
            if ListOuter.Visible then Dropdown:BuildDropdownList() end
        end);
        Scrolling:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
            if not ListOuter.Visible then return end
            if not Dropdown.Multi or not Dropdown.DragSelect then return end
        end);

        -- Giống lỗi "kéo xuống tự chọn" ở list item: trước đây bấm/mở dropdown xảy ra
        -- ngay khi vừa CHẠM XUỐNG (InputBegan), nên chỉ cần lỡ tay chạm qua dropdown
        -- lúc đang cuộn danh sách cũng làm nó tự bật ra. Giờ chỉ mở/đóng khi thả tay
        -- ra mà không di chuyển quá một khoảng nhỏ (đúng là một cú tap, không phải kéo).
        DropdownOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end
            if not Library:BeginGesture(Input) then return end
            local OverOpenedFrame = false
            local Pos = Input.Position
            for Frame in next, Library.OpenedFrames do
                local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
                if Pos.X >= AbsPos.X and Pos.X <= AbsPos.X + AbsSize.X and Pos.Y >= AbsPos.Y and Pos.Y <= AbsPos.Y + AbsSize.Y then
                    OverOpenedFrame = true
                    break
                end
            end
            if OverOpenedFrame then
                Library:EndGesture(Input)
                return
            end

            local PressStart = Input.Position;
            local Moved = false;
            local ThisInput = Input;
            local ChangedConn, EndedConn;

            ChangedConn = InputService.InputChanged:Connect(function(Change)
                if Change ~= ThisInput and not (Change.UserInputType == Enum.UserInputType.MouseMovement and ThisInput.UserInputType == Enum.UserInputType.MouseButton1) then return end
                if (Change.Position - PressStart).Magnitude > 6 then
                    Moved = true;
                end
            end);
            EndedConn = InputService.InputEnded:Connect(function(EndInput)
                if EndInput ~= ThisInput then return end
                if ChangedConn then ChangedConn:Disconnect(); end
                if EndedConn then EndedConn:Disconnect(); end
                Library:EndGesture(ThisInput)
                if not Moved then
                    if ListOuter.Visible then Dropdown:CloseDropdown() else Dropdown:OpenDropdown() end
                end
            end);
            Library:RegisterGestureCleanup(ThisInput, function()
                if ChangedConn then ChangedConn:Disconnect(); ChangedConn = nil end
                if EndedConn then EndedConn:Disconnect(); EndedConn = nil end
            end)
        end);

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                if not ListOuter.Visible then return end
                local Pos = Input.Position;
                local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize;
                local DropPos, DropSize = DropdownOuter.AbsolutePosition, DropdownOuter.AbsoluteSize;
                local OverDropdown = Pos.X >= DropPos.X and Pos.X <= DropPos.X + DropSize.X and Pos.Y >= DropPos.Y and Pos.Y <= DropPos.Y + DropSize.Y;
                local OverList = Pos.X >= AbsPos.X and Pos.X <= AbsPos.X + AbsSize.X and Pos.Y >= AbsPos.Y and Pos.Y <= AbsPos.Y + AbsSize.Y;
                if not OverDropdown and not OverList then
                    Dropdown:CloseDropdown();
                end
            end
        end));

        -- Defaults are applied before the first build so the initial UI is correct without duplicate rebuilds.
        if Info.Multi then
            if type(Info.Default) == 'table' then
                for _, Value in ipairs(Info.Default) do
                    if ValueExists(Value) and not Dropdown.DisabledValues[Value] then Dropdown.Value[Value] = true end
                end
            end
        elseif type(Info.Default) == 'string' or type(Info.Default) == 'number' then
            local DefaultValue = Info.Default
            if type(DefaultValue) == 'number' then
                local IndexedValue = Dropdown.Values[DefaultValue]
                if IndexedValue ~= nil then
                    DefaultValue = IndexedValue
                end
            end
            if ValueExists(DefaultValue) then Dropdown.Value = DefaultValue end
        end

        Dropdown._UI = {
            Outer = DropdownOuter;
            Inner = DropdownInner;
            ListOuter = ListOuter;
            Scrolling = Scrolling;
            ItemList = ItemList;
            SearchBox = SearchBox;
        };

        Dropdown:BuildDropdownList();
        Dropdown:Display();
        Groupbox:AddBlank(Info.BlankSize or 5);
        Groupbox:Resize();

        Options[Idx] = Dropdown;
        setmetatable(Dropdown, BaseAddons);

        return Dropdown;
    end;
    function Funcs:AddDependencyBox()
        local Depbox = {
            Dependencies = {};
        };
        
        local Groupbox = self;
        local Container = Groupbox.Container;

        local Holder = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, 0);
            Visible = false;
            Parent = Container;
        });
        local Frame = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 1, 0);
            Visible = true;
            Parent = Holder;
        });
        local Layout = Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Frame;
        });
        function Depbox:Resize()
            Holder.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y);
            Groupbox:Resize();
        end;

        Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            Depbox:Resize();
        end);
        Holder:GetPropertyChangedSignal('Visible'):Connect(function()
            Depbox:Resize();
        end);
        function Depbox:Update()
            for _, Dependency in next, Depbox.Dependencies do
                local Elem = Dependency[1];
                local Value = Dependency[2];

                if Elem.Type == 'Toggle' and Elem.Value ~= Value then
                    Holder.Visible = false;
                    Depbox:Resize();
                    return;
                end;
            end;

            Holder.Visible = true;
            Depbox:Resize();
        end;

        function Depbox:SetupDependencies(Dependencies)
            for _, Dependency in next, Dependencies do
                assert(type(Dependency) == 'table', 'SetupDependencies: Dependency is not of type `table`.');
                assert(Dependency[1], 'SetupDependencies: Dependency is missing element argument.');
                assert(Dependency[2] ~= nil, 'SetupDependencies: Dependency is missing value argument.');
            end;

            Depbox.Dependencies = Dependencies;
            if type(Depbox) == 'table' and type(Depbox.Update) == 'function' then Depbox:Update() end;
        end;

        Depbox.Container = Frame;

        setmetatable(Depbox, BaseGroupbox);

        table.insert(Library.DependencyBoxes, Depbox);

        return Depbox;
    end;

    function Funcs:SetCollapsed(Collapsed)
        self.Collapsed = not not Collapsed
        if self.Container then
            self.Container.Visible = not self.Collapsed
            if self.Resize then self:Resize() end
        end
        return self
    end

    function Funcs:ToggleCollapsed()
        return self:SetCollapsed(not self.Collapsed)
    end

    function Funcs:IsCollapsed()
        return self.Collapsed == true
    end

    function Funcs:AddParagraph(Text, DoesWrap)
        return self:AddLabel(Text, DoesWrap ~= false)
    end

    function Funcs:AddSection(Text)
        return self:AddLabel(Text, false)
    end

    function Funcs:AddKeybind(Idx, Info)
        return self:AddKeyPicker(Idx, Info)
    end

    BaseGroupbox.__index = Funcs;
    BaseGroupbox.__namecall = function(Table, Key, ...)
        return Funcs[Key](...);
    end;
end;
do
    Library.NotificationArea = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, Library.NotifyConfig.PositionX, 0, Library.NotifyConfig.PositionY);
        Size = UDim2.new(0, 300, 1, -Library.NotifyConfig.PositionY);
        ZIndex = 100;
        Parent = ScreenGui;
    });
    Library.NotifyScale = Library:Create('UIScale', {
        Scale = Library.DPIScale or 1;
        Parent = Library.NotificationArea;
    });
    Library.NotifLayout = Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Library.NotificationArea;
    });
    local function Library_UpdateNotifAlignment()
        local cfg = Library.NotifyConfig
        local area = Library.NotificationArea
        local layout = Library.NotifLayout

        area.Position = UDim2.new(0, cfg.PositionX, 0, cfg.PositionY)
        area.Size     = UDim2.new(0, 300, 1, -cfg.PositionY)

        local align = cfg.Alignment or 'Left'
        if align == 'Left' then
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            area.AnchorPoint = Vector2.new(0, 0)
        elseif align == 'Right' then
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            area.AnchorPoint = Vector2.new(0, 0)
        elseif align == 'Center' then
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            area.AnchorPoint = Vector2.new(0, 0)
        end
    end
    Library.UpdateNotifAlignment = Library_UpdateNotifAlignment
    Library_UpdateNotifAlignment()

    local WatermarkOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, 5);
        Size = UDim2.new(0, 213, 0, 20);
        ZIndex = 200;
        Visible = false;
        Parent = ScreenGui;
    });

    local WatermarkInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 201;
        Parent = WatermarkOuter;
    });
    Library:AddToRegistry(WatermarkInner, {
        BorderColor3 = 'AccentColor';
    });
    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 202;
        Parent = WatermarkInner;
    });
    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        });
        Rotation = -90;
        Parent = InnerFrame;
    });
    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            });
        end
    });
    local WatermarkLabel = Library:CreateLabel({
        Position = UDim2.new(0, 5, 0, 0);
        Size = UDim2.new(1, -10, 1, 0);
        TextSize = Library.FontSize;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 203;
        Parent = InnerFrame;
    });
    local WatermarkSegmentsFrame = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 5, 0, 0);
        Size = UDim2.new(1, -10, 1, 0);
        ZIndex = 204;
        Visible = false;
        Parent = InnerFrame;
    });
    Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        VerticalAlignment = Enum.VerticalAlignment.Center;
        Padding = UDim.new(0, 6);
        Parent = WatermarkSegmentsFrame;
    });
    Library.Watermark = WatermarkOuter;
    Library.WatermarkText = WatermarkLabel;
    Library.WatermarkSegmentsFrame = WatermarkSegmentsFrame;
    Library:MakeDraggable(Library.Watermark);
    WatermarkLabel.Text = '';

    local KeybindOuter = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0, 0.5);
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 10, 0.5, 0);
        Size = UDim2.new(0, 210, 0, 20);
        Visible = false;
        ZIndex = 100;
        Parent = ScreenGui;
    });
    Library:ApplyGlow(KeybindOuter);

    local KeybindInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = KeybindOuter;
    });
    Library:AddToRegistry(KeybindInner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);
    local ColorFrame = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 0, 2);
        ZIndex = 102;
        Parent = KeybindInner;
    });
    Library:AddToRegistry(ColorFrame, {
        BackgroundColor3 = 'AccentColor';
    }, true);
    local KeybindLabel = Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, 20);
        Position = UDim2.fromOffset(5, 2),
        TextXAlignment = Enum.TextXAlignment.Left,

        Text = 'Keybinds';
        ZIndex = 104;
        Parent = KeybindInner;
    });
    local KeybindContainer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 1, -20);
        Position = UDim2.new(0, 0, 0, 20);
        ZIndex = 1;
        Parent = KeybindInner;
    });
    Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = KeybindContainer;
    });
    Library:Create('UIPadding', {
        PaddingLeft = UDim.new(0, 5),
        Parent = KeybindContainer,
    })

    Library.KeybindFrame = KeybindOuter;
    Library.KeybindContainer = KeybindContainer;
    Library:MakeDraggable(KeybindOuter);
end;

function Library:SetUILocked(Bool)
    Library.UILocked = Bool == true
    if Library._MobileLockRefresh then
        pcall(Library._MobileLockRefresh)
    end
    return Library
end;

function Library:IsUILocked()
    return Library.UILocked == true
end;

function Library:SetKeybindMode(Mode)
    if Mode ~= 'All' and Mode ~= 'Active' and Mode ~= 'Toggled' then
        return Library
    end
    Library.KeybindMode = Mode
    Library:RefreshKeybinds()
    return Library
end

function Library:SetShowKeybinds(Visible)
    Library.ShowKeybinds = Visible == true
    if Library.ShowKeybinds then
        Library:RefreshKeybinds()
    elseif Library.KeybindFrame then
        Library.KeybindFrame.Visible = false
    end
    return Library
end

function Library:RefreshKeybinds()
    for _, kp in ipairs(Library.KeyPickerList) do
        if not kp.NoUI then
            local ok, err = pcall(function() kp:Update() end)
            if not ok and Library.DebugKeybinds then
                warn('[Library] Keybind refresh failed:', err)
            end
        end
    end
end

function Library:SetWatermarkVisibility(Bool)
    local Visible = Bool == true
    if Library.Watermark then
        Library.Watermark.Visible = Visible
    end
    if Library._WatermarkV2 and Library._WatermarkV2.Holder then
        Library._WatermarkV2.Holder.Visible = Visible
    end
end;

function Library:SetWatermark(Text)
    if Library._WatermarkV2 then
        local Holder = Library._WatermarkV2.Holder
        if Holder and Holder.Parent then Holder:Destroy() end
        Library._WatermarkV2 = nil
    end
    local X, Y = Library:GetTextBounds(Text, Library.Font, Library.FontSize);
    Library.Watermark.Size = UDim2.new(0, X + 15, 0, (Y * 1.5) + 3);
    Library:SetWatermarkVisibility(true)

    Library.WatermarkText.Text = Text;
end;
function Library:SetWatermarkSegments(Segments)
    if Library._WatermarkV2 then
        local Holder = Library._WatermarkV2.Holder
        if Holder and Holder.Parent then Holder:Destroy() end
        Library._WatermarkV2 = nil
    end
    if Library.Watermark then Library.Watermark.Visible = false end
    Segments = type(Segments) == 'table' and Segments or { Segments }
    local Frame = Library.WatermarkSegmentsFrame
    if not Frame then
        return Library:SetWatermark('')
    end

    for _, child in next, Frame:GetChildren() do
        if not child:IsA('UIListLayout') then
            child:Destroy()
        end
    end

    Library.WatermarkText.Visible = false
    Frame.Visible = true

    local totalWidth = 10
    local count = 0
    for _, segment in ipairs(Segments) do
        local value = segment
        local text = ''
        if type(segment) == 'table' then
            value = segment.Text or ''
        end
        if type(value) == 'function' then
            local ok, result = pcall(value)
            text = ok and tostring(result or '') or ''
        else
            text = tostring(value or '')
        end

        local label = Library:CreateLabel({
            AutomaticSize = Enum.AutomaticSize.X;
            Size = UDim2.fromOffset(0, 18);
            TextSize = Library.FontSize;
            Text = text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 205;
            Parent = Frame;
        })
        count += 1
        totalWidth += label.TextBounds.X + 6
    end

    Library.Watermark.Size = UDim2.fromOffset(math.max(100, totalWidth), 20)
    Library:SetWatermarkVisibility(true)

    Library._WatermarkSegments = Segments
    -- LƯU Ý: Library.Watermark là 1 Roblox Instance (Frame) thật, KHÔNG được gán
    -- thuộc tính tùy ý như .RefreshRate lên nó (Roblox sẽ báo lỗi "not a valid
    -- member of Frame" và crash). RefreshRate cho hệ thống segment cũ này được
    -- lưu riêng ở Library._LegacyWatermarkRefreshRate thay vì gán lên Instance.
    Library._LegacyWatermarkRefreshRate = Library._LegacyWatermarkRefreshRate or 1
    return Library.Watermark
end

function Library:RefreshWatermarkSegments()
    if Library._WatermarkSegments then
        return Library:SetWatermarkSegments(Library._WatermarkSegments)
    end
    return Library.Watermark
end

function Library:SetNotificationConfig(Config)
    if type(Config) ~= 'table' then return end
    for k, v in next, Config do
        if Library.NotifyConfig[k] ~= nil then Library.NotifyConfig[k] = v end
    end
    if Library.UpdateNotifAlignment then Library.UpdateNotifAlignment() end
end

function Library:NotifyHistory()
    return Library._NotificationHistory or {}
end

function Library:ClearNotificationHistory()
    Library._NotificationHistory = {}
end

function Library:Notify(Text, Time)
    Library._NotificationHistory = Library._NotificationHistory or {}
    table.insert(Library._NotificationHistory, { Text = tostring(Text), Time = os.clock() })
    if #Library._NotificationHistory > 100 then table.remove(Library._NotificationHistory, 1) end
    local cfg     = Library.NotifyConfig
    local barSide = cfg.BarSide   or 'Left'    
    local align   = cfg.Alignment or 'Left'    

    local XSize, YSize = Library:GetTextBounds(Text, Library.Font, Library.FontSize)
    YSize = YSize + 7

    local BAR_THIN  = 3   
    local BAR_THICK = 3   

    local innerPosX  = (barSide == 'Right') and (BAR_THIN + 1) or 1
    local innerPosY  = (barSide == 'Top') and BAR_THICK or 1
    local innerSizeW = (barSide == 'Left' or barSide == 'Right') and -(BAR_THIN + 2) or -2
    local innerSizeH = (barSide == 'Top' or barSide == 'Bottom') and -(BAR_THICK + 1) or -2

    local labelPosX  = (barSide == 'Left')  and BAR_THIN + 2 or 4
    local labelSizeW = (barSide == 'Left' or barSide == 'Right') and -(BAR_THIN + 4) or -4

    local outerAnchor = Vector2.new(0, 0)
    local outerPosX   = 0
    if align == 'Center' then
        outerAnchor = Vector2.new(0.5, 0)
        outerPosX   = 0  
    elseif align == 'Right' then
        outerAnchor = Vector2.new(1, 0)
        outerPosX   = 0
    end

    local NotifyOuter = Library:Create('Frame', {
        BackgroundTransparency = 1;
        AnchorPoint = outerAnchor;
        BorderColor3 = Color3.new(0, 0, 0);
        Position     = (align == 'Center')
            and UDim2.new(0.5, 0, 0, 0)
            or  (align == 'Right' and UDim2.new(1, 0, 0, 0) or UDim2.new(0, 0, 0, 0));
        Size = UDim2.new(0, 0, 0, YSize);
        ClipsDescendants = true;
        ZIndex = 100;
        Parent = Library.NotificationArea;
    });
    local NotifyInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = NotifyOuter;
    });
    Library:AddToRegistry(NotifyInner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);
    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, innerPosX, 0, innerPosY);
        Size     = UDim2.new(1, innerSizeW, 1, innerSizeH);
        ZIndex = 102;
        Parent = NotifyInner;
    });
    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        });
        Rotation = -90;
        Parent = InnerFrame;
    });
    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            });
        end
    });
    local NotifyLabel = Library:CreateLabel({
        Position = UDim2.new(0, labelPosX, 0, 0);
        Size     = UDim2.new(1, labelSizeW, 1, 0);
        Text     = Text;
        TextXAlignment = (align == 'Center')
            and Enum.TextXAlignment.Center
            or  Enum.TextXAlignment.Left;
        TextSize = Library.FontSize;
        ZIndex   = 103;
        Parent   = InnerFrame;
    });
    local AccentBar = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel  = 0;
        ZIndex           = 104;
        Parent           = NotifyOuter;
    });
    if barSide == 'Left' then
        AccentBar.Position = UDim2.new(0, -1, 0, -1)
        AccentBar.Size     = UDim2.new(0, BAR_THIN, 1, 2)
    elseif barSide == 'Right' then
        AccentBar.Position = UDim2.new(1, -BAR_THIN + 1, 0, -1)
        AccentBar.Size     = UDim2.new(0, BAR_THIN, 1, 2)
    elseif barSide == 'Top' then
        AccentBar.Position = UDim2.new(0, -1, 0, -1)
        AccentBar.Size     = UDim2.new(1, 2, 0, BAR_THICK)
    elseif barSide == 'Bottom' then
        AccentBar.Position = UDim2.new(0, -1, 1, -BAR_THICK + 1)
        AccentBar.Size     = UDim2.new(1, 2, 0, BAR_THICK)
    end

    Library:AddToRegistry(AccentBar, {
        BackgroundColor3 = 'AccentColor';
    }, true);
    local finalWidth = XSize + 8 + 4
    if barSide == 'Left' or barSide == 'Right' then
        finalWidth = finalWidth + BAR_THIN
    end
    pcall(NotifyOuter.TweenSize, NotifyOuter,
        UDim2.new(0, finalWidth, 0, YSize), 'Out', 'Quad', 0.4, true);
    task.spawn(function()
        task.wait(Time or 5);
        pcall(NotifyOuter.TweenSize, NotifyOuter,
            UDim2.new(0, 0, 0, YSize), 'Out', 'Quad', 0.4, true);
        task.wait(0.4);
        NotifyOuter:Destroy();
    end);
end;

function Library:CreateWindow(...)
    local Arguments = { ... }
    local Config = { AnchorPoint = Vector2.zero }

    if type(...) == 'table' then
        Config = ...;
    else
        Config.Title = Arguments[1]
        Config.AutoShow = Arguments[2] or false;
    end

    if type(Config.Title) ~= 'string' then Config.Title = 'No title' end
    if type(Config.TabPadding) ~= 'number' then Config.TabPadding = 0 end
    if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.2 end

    if typeof(Config.Size) ~= 'UDim2' then Config.Size = UDim2.fromOffset(550, 650) end
    if typeof(Config.Position) ~= 'UDim2' then Config.Position = UDim2.fromOffset(175, 50) end

    if InputService.TouchEnabled then
        local vp = workspace.CurrentCamera.ViewportSize
        local maxWidth = math.min(Config.Size.X.Offset, vp.X - 20)
      
        local maxHeight = math.min(Config.Size.Y.Offset, vp.Y - 60)
        Config.Size = UDim2.fromOffset(maxWidth, maxHeight)
    end

    if Config.Center then
        Config.AnchorPoint = Vector2.new(0.5, 0.5)
        Config.Position = UDim2.fromScale(0.5, 0.5)
    end

    Library._Windows = Library._Windows or {}
    local Window = {
        Tabs = {};
        AlwaysOnTop = Config.AlwaysOnTop == true;
        Minimizable = Config.Minimizable == true;
        Minimized = false;
    };

    local Outer = Library:Create('Frame', {
        AnchorPoint = Config.AnchorPoint,
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderSizePixel = 0;
        Position = Config.Position,
        Size = Config.Size,
        Visible = false;
        ZIndex = 1;
        Parent = ScreenGui;
    });
    local WindowScale = Library:Create('UIScale', { Scale = Library.DPIScale or 1, Parent = Outer })
    Window._Scale = WindowScale
    table.insert(Library._Windows, Window)
    Library:MakeDraggable(Outer, 25, true);

    local Inner = Library:Create('Frame', {
        Name = "Inner",
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 1;
        ClipsDescendants = true;
        Parent = Outer;
    });
    Library:AddToRegistry(Inner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });
    local WindowLabel = Library:CreateLabel({
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(1, 0, 0, 25);
        Text = Config.Title or '';
        RichText = true; 
        TextXAlignment = Enum.TextXAlignment.Center;
        ZIndex = 1;
        Parent = Inner;
    });
    local MapNameLabel = Library:CreateLabel({
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -7, 0, 0),
        Size = UDim2.new(0, 0, 0, 25),
        Text = 'Loading...',
        TextColor3 = Library.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 1,
        Parent = Inner;
    });
    Library:AddToRegistry(MapNameLabel, {
        TextColor3 = 'AccentColor';
    });
    task.spawn(function()
        local success, info = pcall(function()
            return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        end)
        if success and info and info.Name then
            MapNameLabel.Text = info.Name
        else
            MapNameLabel.Text = game.Name or "Unknown Map"
        end
    end)


    local TabBarOuter = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        Position = UDim2.new(0, 8, 0, 25);
        Size = UDim2.new(1, -16, 0, 29);
        ZIndex = 1;
        Parent = Inner;
    });
    Library:AddToRegistry(TabBarOuter, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
    });
    local TabBarInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Color3.new(0, 0, 0);
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 1;
        Parent = TabBarOuter;
    });
    Library:AddToRegistry(TabBarInner, {
        BackgroundColor3 = 'BackgroundColor';
    });
    -- The tab strip is a real horizontal ScrollingFrame. A plain Frame +
    -- UIListLayout lets tabs extend outside the visible window, which makes
    -- later tabs impossible to reach after the window is resized smaller.
    local TabArea = Library:Create('ScrollingFrame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 4, 0, 4);
        Size = UDim2.new(1, -8, 1, -8);
        CanvasSize = UDim2.fromOffset(0, 0);
        AutomaticCanvasSize = Enum.AutomaticSize.None;
        ScrollingDirection = Enum.ScrollingDirection.X;
        HorizontalScrollBarInset = Enum.ScrollBarInset.None;
        VerticalScrollBarInset = Enum.ScrollBarInset.None;
        ScrollBarThickness = 0;
        ScrollingEnabled = true;
        Active = true;
        ZIndex = 1;
        Parent = TabBarInner;
    });
    local TabListLayout = Library:Create('UIListLayout', {
        Padding = UDim.new(0, Config.TabPadding);
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = TabArea;
    });
    local function UpdateTabCanvas()
        local contentX = TabListLayout.AbsoluteContentSize.X
        local viewportX = math.max(0, TabArea.AbsoluteSize.X)
        local canvasX = math.max(contentX, viewportX)
        TabArea.CanvasSize = UDim2.fromOffset(canvasX + 2, 0)
    end
    Library:GiveSignal(TabListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(UpdateTabCanvas))
    Library:GiveSignal(TabArea:GetPropertyChangedSignal('AbsoluteSize'):Connect(UpdateTabCanvas))
    Library:GiveSignal(TabArea:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
        -- Keep the scroll position valid after a resize removes content.
        local maxX = math.max(0, TabArea.AbsoluteCanvasSize.X - TabArea.AbsoluteSize.X)
        if TabArea.CanvasPosition.X > maxX then
            TabArea.CanvasPosition = Vector2.new(maxX, 0)
        end
    end))
    local MainSectionOuter = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        Position = UDim2.new(0, 8, 0, 58);
        Size = UDim2.new(1, -16, 1, -66);
        ZIndex = 1;
        Parent = Inner;
    });
    Library:AddToRegistry(MainSectionOuter, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
    });

    Window.Footer = Config.Footer
    Window.CopyableFooter = Config.CopyableFooter == true
    if type(Config.Footer) == 'table' and #Config.Footer > 0 then
        MainSectionOuter.Size = UDim2.new(1, -16, 1, -88)
        local FooterFrame = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor,
            BorderColor3 = Library.OutlineColor,
            Position = UDim2.new(0, 8, 1, -28),
            Size = UDim2.new(1, -16, 0, 20),
            ZIndex = 8, Parent = Inner,
        })
        Library:AddToRegistry(FooterFrame, { BackgroundColor3='BackgroundColor', BorderColor3='OutlineColor' })
        local FooterRow = Library:Create('Frame', { BackgroundTransparency=1, Size=UDim2.new(1,-6,1,0), Position=UDim2.fromOffset(3,0), ZIndex=9, Parent=FooterFrame })
        Library:Create('UIListLayout', { FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder, VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0,4), Parent=FooterRow })
        local FooterParts = {}
        for _, Segment in ipairs(Config.Footer) do
            local Text = type(Segment)=='table' and tostring(Segment.Text or '') or tostring(Segment)
            FooterParts[#FooterParts+1]=Text
            local Copyable = type(Segment)=='table' and Segment.Copyable == true
            local CellProperties = {
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromOffset(0, 18),
                Text = Text,
                Font = Library.Font,
                TextSize = math.max(10, Library.FontSize - 2),
                TextColor3 = Library.FontColor,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10,
                Parent = FooterRow,
            }
            if Copyable then
                CellProperties.AutoButtonColor = false
            end
            local Cell = Library:Create(Copyable and 'TextButton' or 'TextLabel', CellProperties)
            Library:AddToRegistry(Cell,{TextColor3='FontColor'})
            if Copyable then
                Cell.MouseButton1Click:Connect(function()
                    local CopyText=type(Segment)=='table' and Segment.CopyText or Text
                    local fn=setclipboard or toclipboard; if fn then pcall(fn,tostring(CopyText or Text)) end
                end)
            end
        end
        Window.FooterFrame=FooterFrame
        Window.FooterText=table.concat(FooterParts,'')
    end
    local MainSectionInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Color3.new(0, 0, 0);
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 1;
        Parent = MainSectionOuter;
    });
    Library:AddToRegistry(MainSectionInner, {
        BackgroundColor3 = 'BackgroundColor';
    });
    local TabContainer = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        Position = UDim2.new(0, 8, 0, 8);
        Size = UDim2.new(1, -16, 1, -16);
        ZIndex = 2;
        Parent = MainSectionInner;
    });
    Library:AddToRegistry(TabContainer, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });
    Outer.ClipsDescendants = true;
    -- Corner-radius / rounded-corner decoration removed entirely per request:
    -- the window and its corner accent now always render as sharp/square
    -- corners, and SetCornerRadius below is a no-op kept only so existing
    -- calls to it don't error.
    if Window.Minimizable and Config.MinimizeKeybind then
        Library:GiveSignal(InputService.InputBegan:Connect(function(Input, Processed)
            if not Processed and Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Config.MinimizeKeybind then
                Window:SetMinimized(not Window.Minimized)
            end
        end))
    end
    function Window:SetWindowTitle(Title)
        WindowLabel.Text = Title;
    end;

    function Window:SetAlwaysOnTop(Enabled)
        Window.AlwaysOnTop = Enabled == true
        pcall(function() if sethiddenproperty then sethiddenproperty(ScreenGui, 'OnTopOfCoreBlur', Window.AlwaysOnTop) end end)
        pcall(function() if setscriptable then setscriptable(ScreenGui, 'OnTopOfCoreBlur', true); ScreenGui.OnTopOfCoreBlur = Window.AlwaysOnTop end end)
        return Window
    end

    function Window:SetCornerRadius(Radius)
        -- Đã xoá tính năng bo góc window theo yêu cầu — giữ hàm này lại làm no-op
        -- thật sự (không tạo UICorner, không đổi gì) để không crash nếu code cũ
        -- (hoặc Example.lua) còn lỡ gọi tới nó.
        return Window
    end

    function Window:SetMinimized(Minimized)
        Minimized = Minimized == true
        Window.Minimized = Minimized
        MainSectionOuter.Visible = not Minimized
        TabBarOuter.Visible = not Minimized
        return Window
    end
    function Window:Minimize() return Window:SetMinimized(true) end
    function Window:Restore() return Window:SetMinimized(false) end
    if Window.AlwaysOnTop then Window:SetAlwaysOnTop(true) end
    function Window:AddTab(Name, Icon)
        local TabInfo = type(Name) == 'table' and Name or { Name = Name, Icon = Icon };
        Name = tostring(TabInfo.Name or TabInfo.Text or 'Tab');
        local Tab = {
            Groupboxes = {};
            Tabboxes = {};
            Name = Name;
            Icon = TabInfo.Icon or TabInfo.IconName;
            Description = TabInfo.Description;
            SingleColumn = TabInfo.SingleColumn == true or TabInfo.Layout == 'Single' or TabInfo.Layout == 'Center';
        };

        local TabButtonWidth = Library:GetTextBounds(Name, Library.Font, Library.FontSize + 2);
        local TabButton = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            Size = UDim2.new(0, TabButtonWidth + 8 + 4, 1, 0);
            ZIndex = 1;
            Parent = TabArea;
        });
        Library:AddToRegistry(TabButton, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });
        local TabButtonLabel = Library:CreateLabel({
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, -1);
            Text = Name;
            ZIndex = 1;
            Parent = TabButton;
        });
        local TabIndicator = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 0, 2); 
            Visible = false; 
            ZIndex = 4;
            Parent = TabButton;
        });
        Library:AddToRegistry(TabIndicator, { BackgroundColor3 = 'AccentColor' });

        local Blocker = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(0, 0, 0, 0);
            Visible = false;
            Parent = TabButton;
        });
        local TabFrame = Library:Create('Frame', {
            Name = 'TabFrame',
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            Visible = false;
            ZIndex = 2;
            ClipsDescendants = true;
            Parent = TabContainer;
        });
        local LeftSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 8 - 1, 0, 8 - 1);
            Size = UDim2.new(0.5, -12 + 2, 1, -16);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = '';
            TopImage = '';
            ScrollBarThickness = 0;
            ZIndex = 2;
            Parent = TabFrame;
        });
        local RightSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(0.5, 4 + 1, 0, 8 - 1);
            Size = UDim2.new(0.5, -12 + 2, 1, -16);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = '';
            TopImage = '';
            ScrollBarThickness = 0;
            ZIndex = 2;
            Parent = TabFrame;
        });
        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = LeftSide;
        });
        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = RightSide;
        });
        if Tab.SingleColumn then
            LeftSide.Position = UDim2.new(0, 8, 0, 8)
            LeftSide.Size = UDim2.new(1, -16, 1, -16)
            RightSide.Visible = false
        end
        for _, Side in next, { LeftSide, RightSide } do
            Side:WaitForChild('UIListLayout'):GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                Side.CanvasSize = UDim2.fromOffset(0, Side.UIListLayout.AbsoluteContentSize.Y);
            end);
        end;

        -- Tab-level element facade: keeps ObsidianUltra-style examples usable while
        -- preserving Linoria's left/right groupbox model underneath.
        Tab._Root = Tab._Root or { Container = LeftSide }
        setmetatable(Tab._Root, BaseGroupbox)
        function Tab:AddLabel(...) return Tab._Root:AddLabel(...) end
        function Tab:AddButton(...) return Tab._Root:AddButton(...) end
        function Tab:AddToggle(...) return Tab._Root:AddToggle(...) end
        function Tab:AddCheckbox(...) return Tab._Root:AddToggle(...) end
        function Tab:AddSlider(...) return Tab._Root:AddSlider(...) end
        function Tab:AddDropdown(...) return Tab._Root:AddDropdown(...) end
        function Tab:AddInput(...) return Tab._Root:AddInput(...) end
        function Tab:AddDivider(...) return Tab._Root:AddDivider(...) end
        function Tab:AddBlank(...) return Tab._Root:AddBlank(...) end
        function Tab:AddColorPicker(...) return Tab._Root:AddColorPicker(...) end
        function Tab:AddKeyPicker(...) return Tab._Root:AddKeyPicker(...) end
        function Tab:AddKeybind(...) return Tab._Root:AddKeybind(...) end

        function Tab:ShowTab()
            for _, Tab in next, Window.Tabs do
                Tab:HideTab();
            end;

            Blocker.BackgroundTransparency = 0;
            TabButton.BackgroundColor3 = Library.MainColor;
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor';
            TabFrame.Visible = true;
            TabIndicator.Visible = true;
        end;
        function Tab:HideTab()
            Blocker.BackgroundTransparency = 1;
            TabButton.BackgroundColor3 = Library.BackgroundColor;
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor';
            TabFrame.Visible = false;
            TabIndicator.Visible = false;
        end;
        function Tab:SetLayoutOrder(Position)
            TabButton.LayoutOrder = Position;
        end;
        function Tab:AddGroupbox(Info)
            local Groupbox = {};
            local BoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 0, 507 + 2);
                ZIndex = 2;
                Parent = Tab.SingleColumn and LeftSide or (Info.Side == 1 and LeftSide or RightSide);
            });
            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });
            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                ZIndex = 4;
                Parent = BoxOuter;
            });
            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor';
            });
            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 2);
                ZIndex = 5;
                Parent = BoxInner;
            });
            Library:AddToRegistry(Highlight, {
                BackgroundColor3 = 'AccentColor';
            });
            local GroupboxLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 18);
                Position = UDim2.new(0, 0, 0, 2);
                TextSize = Library.FontSize;
                Text = Info.Name;
                TextXAlignment = Enum.TextXAlignment.Center;
                ZIndex = 5;
                Parent = BoxInner;
            });
            local Container = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 4, 0, 20);
                Size = UDim2.new(1, -4, 1, -20);
                ZIndex = 1;
                Parent = BoxInner;
            });
            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = Container;
            });
            function Groupbox:Resize()
                local Size = 0;
                for _, Element in next, Groupbox.Container:GetChildren() do
                    if (not Element:IsA('UIListLayout')) and Element.Visible then
                        Size = Size + Element.Size.Y.Offset;
                    end;
                end;

                BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2);
            end;

            Groupbox.Container = Container;
            setmetatable(Groupbox, BaseGroupbox);
            Groupbox:AddBlank(3);
            Groupbox:Resize();

            Tab.Groupboxes[Info.Name] = Groupbox;

            return Groupbox;
        end;

        function Tab:AddLeftGroupbox(Name, IconName)
            if type(Name) == 'table' then
                Name.Side = 1;
                return Tab:AddGroupbox(Name);
            end
            return Tab:AddGroupbox({ Side = 1; Name = Name; Icon = IconName; });
        end;

        function Tab:AddRightGroupbox(Name, IconName)
            if type(Name) == 'table' then
                Name.Side = 2;
                return Tab:AddGroupbox(Name);
            end
            return Tab:AddGroupbox({ Side = 2; Name = Name; Icon = IconName; });
        end;

        function Tab:AddTabbox(Info)
            local Tabbox = {
                Tabs = {};
            };

            local BoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 0, 0);
                ZIndex = 2;
                Parent = Info.Side == 1 and LeftSide or RightSide;
            });
            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });
            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                ZIndex = 4;
                Parent = BoxOuter;
            });
            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor';
            });
            local TabboxButtons = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 0, 0, 1);
                Size = UDim2.new(1, 0, 0, 18);
                ZIndex = 5;
                Parent = BoxInner;
            });
            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Left;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TabboxButtons;
            });
            function Tabbox:AddTab(Name)
                local Tab = {};
                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Color3.new(0, 0, 0);
                    Size = UDim2.new(0.5, 0, 1, 0);
                    ZIndex = 6;
                    Parent = TabboxButtons;
                });
                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor';
                });
                local TabHighlight = Library:Create('Frame', {
                    BackgroundColor3 = Library.AccentColor;
                    BorderSizePixel = 0;
                    Size = UDim2.new(1, 0, 0, 2);
                    Visible = false;
                    ZIndex = 10;
                    Parent = Button;
                });
                Library:AddToRegistry(TabHighlight, {
                    BackgroundColor3 = 'AccentColor';
                });
                local ButtonLabel = Library:CreateLabel({
                    Size = UDim2.new(1, 0, 1, 0);
                    TextSize = Library.FontSize;
                    Text = Name;
                    TextXAlignment = Enum.TextXAlignment.Center;
                    ZIndex = 7;
                    Parent = Button;
                });
                local Block = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor;
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 0, 1, 0);
                    Size = UDim2.new(1, 0, 0, 1);
                    Visible = false;
                    ZIndex = 9;
                    Parent = Button;
                });
                Library:AddToRegistry(Block, {
                    BackgroundColor3 = 'BackgroundColor';
                });
                local Container = Library:Create('Frame', {
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 4, 0, 20);
                    Size = UDim2.new(1, -4, 1, -20);
                    ZIndex = 1;
                    Visible = false;
                    Parent = BoxInner;
                });
                Library:Create('UIListLayout', {
                    FillDirection = Enum.FillDirection.Vertical;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Parent = Container;
                });
                function Tab:Show()
                    for _, Tab in next, Tabbox.Tabs do
                        Tab:Hide();
                    end;

                    Container.Visible = true;
                    Block.Visible = true;
                    TabHighlight.Visible = true;

                    Button.BackgroundColor3 = Library.BackgroundColor;
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';

                    Tab:Resize();
                end;
                function Tab:Hide()
                    Container.Visible = false;
                    Block.Visible = false;
                    TabHighlight.Visible = false;

                    Button.BackgroundColor3 = Library.MainColor;
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';
                end;
                function Tab:Resize()
                    local TabCount = 0;
                    for _, Tab in next, Tabbox.Tabs do
                        TabCount = TabCount + 1;
                    end;

                    for _, Button in next, TabboxButtons:GetChildren() do
                        if not Button:IsA('UIListLayout') then
                            Button.Size = UDim2.new(1 / TabCount, 0, 1, 0);
                        end;
                    end;

                    if (not Container.Visible) then
                        return;
                    end;

                    local Size = 0;

                    for _, Element in next, Tab.Container:GetChildren() do
                        if (not Element:IsA('UIListLayout')) and Element.Visible then
                            Size = Size + Element.Size.Y.Offset;
                        end;
                    end;

                    BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2);
                end;
                -- Cùng lỗi hệ thống: chuyển tab ngay khi chạm xuống khiến lỡ tay
                -- cuộn qua hàng tab cũng bị đổi tab. Chỉ đổi khi thả tay ra mà
                -- không di chuyển quá một khoảng nhỏ (tap thật, không phải kéo).
                Button.InputBegan:Connect(function(Input)
                    if (Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch) or Library:MouseIsOverOpenedFrame(Input.Position) then return end
                    if not Library:BeginGesture(Input) then return end

                    local PressStart = Input.Position;
                    local Moved = false;
                    local ThisInput = Input;
                    local ChangedConn, EndedConn;

                    ChangedConn = InputService.InputChanged:Connect(function(Change)
                        if Change ~= ThisInput and not (Change.UserInputType == Enum.UserInputType.MouseMovement and ThisInput.UserInputType == Enum.UserInputType.MouseButton1) then return end
                        if (Change.Position - PressStart).Magnitude > 6 then
                            Moved = true;
                        end
                    end);
                    EndedConn = InputService.InputEnded:Connect(function(EndInput)
                        if EndInput ~= ThisInput then return end
                        if ChangedConn then ChangedConn:Disconnect(); end
                        if EndedConn then EndedConn:Disconnect(); end
                        if not Moved and not Library:MouseIsOverOpenedFrame(EndInput.Position) then
                            Tab:Show();
                            Tab:Resize();
                        end
                    end);
                    Library:RegisterGestureCleanup(ThisInput, function()
                        if ChangedConn then ChangedConn:Disconnect(); ChangedConn = nil end
                        if EndedConn then EndedConn:Disconnect(); EndedConn = nil end
                    end)
                end);

                Tab.Container = Container;
                Tabbox.Tabs[Name] = Tab;

                setmetatable(Tab, BaseGroupbox);

                Tab:AddBlank(3);
                Tab:Resize();

                if #TabboxButtons:GetChildren() == 2 then
                    Tab:Show();
                end;

                return Tab;
            end;

            Tab.Tabboxes[Info.Name or ''] = Tabbox;

            return Tabbox;
        end;
        function Tab:AddLeftTabbox(Name)
            return Tab:AddTabbox({ Name = Name, Side = 1; });
        end;

        function Tab:AddRightTabbox(Name)
            return Tab:AddTabbox({ Name = Name, Side = 2; });
        end;

        function Tab:AddPlayerInfo(Idx, Info)
            Info = Info or {}
            local Player = Info.Player or Players.LocalPlayer
            local UserId = Info.UserId or (Player and Player.UserId) or 0
            local Height = tonumber(Info.Height) or 84
            local Holder = Library:Create('Frame', {BackgroundColor3 = Library.BackgroundColor, BorderColor3 = Library.OutlineColor, Size = UDim2.new(1,-10,0,Height), Position = UDim2.new(0,5,0,5), ZIndex=3, Parent=TabFrame})
            Library:AddToRegistry(Holder,{BackgroundColor3='BackgroundColor',BorderColor3='OutlineColor'})
            Library:Create('ImageLabel',{BackgroundTransparency=1,Size=UDim2.fromOffset(64,64),Position=UDim2.fromOffset(8,8),Image='rbxthumb://type=AvatarHeadShot&id='..tostring(UserId)..'&w=150&h=150',ZIndex=4,Parent=Holder})
            Library:CreateLabel({Position=UDim2.fromOffset(82,8),Size=UDim2.new(1,-90,0,22),Text=tostring(Info.Title or (Player and Player.DisplayName) or 'Player'),RichText=true,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4,Parent=Holder})
            local Desc=Info.Description; if type(Desc)=='table' then Desc=table.concat(Desc,'\n') end
            Library:CreateLabel({Position=UDim2.fromOffset(82,31),Size=UDim2.new(1,-90,0,Height-36),Text=tostring(Desc or (Player and ('@'..Player.Name) or '')),RichText=true,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,ZIndex=4,Parent=Holder})
            LeftSide.Position=UDim2.new(0,7,0,Height+12); LeftSide.Size=UDim2.new(0.5,-11,1,-(Height+20))
            RightSide.Position=UDim2.new(0.5,5,0,Height+12); RightSide.Size=UDim2.new(0.5,-11,1,-(Height+20))
            return Holder
        end

        -- SubTab compatibility: this library intentionally has NO nested SubTab UI.
        -- Older showcase scripts may still call AddSubTab(), so return the normal
        -- parent Tab instead. All content is placed into the tab's regular layout.
        function Tab:SetSubTabAlignment(_Alignment)
            return Tab
        end

        function Tab:AddSubTab(_Info)
            return Tab
        end

        -- Cùng lỗi hệ thống: đổi tab chính ngay khi chạm xuống khiến lỡ tay
        -- cuộn/kéo qua thanh tab cũng bị đổi tab. Chỉ đổi khi thả tay ra mà
        -- không di chuyển quá một khoảng nhỏ (tap thật, không phải kéo).
        TabButton.InputBegan:Connect(function(Input)
            if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end
            if not Library:BeginGesture(Input) then return end

            local PressStart = Input.Position;
            local Moved = false;
            local ThisInput = Input;
            local ChangedConn, EndedConn;

            ChangedConn = InputService.InputChanged:Connect(function(Change)
                if Change ~= ThisInput and not (Change.UserInputType == Enum.UserInputType.MouseMovement and ThisInput.UserInputType == Enum.UserInputType.MouseButton1) then return end
                if (Change.Position - PressStart).Magnitude > 6 then
                    Moved = true;
                end
            end);
            EndedConn = InputService.InputEnded:Connect(function(EndInput)
                if EndInput ~= ThisInput then return end
                if ChangedConn then ChangedConn:Disconnect(); end
                if EndedConn then EndedConn:Disconnect(); end
                Library:EndGesture(ThisInput)
                if not Moved then
                    Tab:ShowTab();
                end
            end);
            Library:RegisterGestureCleanup(ThisInput, function()
                if ChangedConn then ChangedConn:Disconnect(); ChangedConn = nil end
                if EndedConn then EndedConn:Disconnect(); EndedConn = nil end
            end)
        end);
        if #TabContainer:GetChildren() == 1 then
            Tab:ShowTab();
        end;
        Window.Tabs[Name] = Tab;
        return Tab;
    end;

    local ModalElement = Library:Create('TextButton', {
        BackgroundTransparency = 1;
        Size = UDim2.new(0, 0, 0, 0);
        Visible = true;
        Text = '';
        Modal = false;
        Parent = ScreenGui;
    });
    function Library:Toggle()
        if Library.Unloaded then return Library end
        Library.Toggled = not Library.Toggled;
        ModalElement.Modal = Library.Toggled;
        Outer.Visible = Library.Toggled;
        if Library.Toggled then
            if type(Drawing) == 'table' and type(Drawing.new) == 'function' then
            task.spawn(function()
                local State = InputService.MouseIconEnabled;
                local okCursor, Cursor = pcall(Drawing.new, 'Triangle')
                local okOutline, CursorOutline = pcall(Drawing.new, 'Triangle')
                if not okCursor or not Cursor or not okOutline or not CursorOutline then
                    if Cursor and type(Cursor.Remove) == 'function' then pcall(Cursor.Remove, Cursor) end
                    if CursorOutline and type(CursorOutline.Remove) == 'function' then pcall(CursorOutline.Remove, CursorOutline) end
                    return
                end

                Cursor.Thickness = 1;
                Cursor.Filled = true;
                Cursor.Visible = true;

                CursorOutline.Thickness = 1;
                CursorOutline.Filled = false;
                CursorOutline.Color = Color3.new(0, 0, 0);
                CursorOutline.Visible = true;

                while Library.Toggled and ScreenGui.Parent do
                    InputService.MouseIconEnabled = false;

                    local mPos = InputService:GetMouseLocation();
                    Cursor.Color = Library.AccentColor;
                    Cursor.PointA = Vector2.new(mPos.X, mPos.Y);
                    Cursor.PointB = Vector2.new(mPos.X + 16, mPos.Y + 6);
                    Cursor.PointC = Vector2.new(mPos.X + 6, mPos.Y + 16);
                    CursorOutline.PointA = Cursor.PointA;
                    CursorOutline.PointB = Cursor.PointB;
                    CursorOutline.PointC = Cursor.PointC;

                    RenderStepped:Wait();
                end;

                InputService.MouseIconEnabled = State;
                if Cursor and type(Cursor.Remove) == 'function' then pcall(Cursor.Remove, Cursor) end
                if CursorOutline and type(CursorOutline.Remove) == 'function' then pcall(CursorOutline.Remove, CursorOutline) end
            end);
        end;
        end;
        if Library.UseBlur then
            if Library.Toggled then
                Library.BlurEffect.Enabled = true
                Library.BlurEffect.Size = Library.BlurSize
            else
                Library.BlurEffect.Size = 0
                Library.BlurEffect.Enabled = false
            end
        else
            Library.BlurEffect.Size = 0
            Library.BlurEffect.Enabled = false
        end
    end

    Library:GiveSignal(InputService.InputBegan:Connect(function(Input, Processed)
        if Processed then
            return
        end
        if type(Library.ToggleKeybind) == 'table' and Library.ToggleKeybind.Type == 'KeyPicker' then
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Library.ToggleKeybind.Value then
                task.spawn(Library.Toggle)
            end
        elseif type(Library.ToggleKeybind) == 'string' then
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Library.ToggleKeybind then
                task.spawn(Library.Toggle)
            end
        elseif Input.KeyCode == Enum.KeyCode.RightControl or (Input.KeyCode == Enum.KeyCode.RightShift and (not Processed)) then
            task.spawn(Library.Toggle)
        end
    end))

    if Config.AutoShow then task.spawn(Library.Toggle) end

    -- Resize grip: MakeResizable already existed in the library but was never
    -- actually attached to any window, so there was no way to resize the UI
    -- at all. Add a small drag handle in the bottom-right corner. All of the
    -- window's internal frames (Inner, TabBarOuter, MainSectionOuter, etc.)
    -- already use relative UDim2 sizing against Outer, so they automatically
    -- follow when Outer.Size changes -- no extra layout code needed there.
    if Config.Resizable ~= false then
        local ResizeHandle = Library:Create('Frame', {
            Name = 'ResizeHandle',
            AnchorPoint = Vector2.new(1, 1),
            BackgroundTransparency = 1;
            Position = UDim2.new(1, -2, 1, -2);
            Size = UDim2.fromOffset(16, 16);
            ZIndex = 50;
            Parent = Outer;
            Active = true;
        })
        local ResizeGlyph = Library:Create('ImageLabel', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 1, 0);
            Image = 'http://www.roblox.com/asset/?id=6035047409';
            ImageColor3 = Library.OutlineColor;
            ImageTransparency = 0.25;
            Rotation = 90;
            ZIndex = 51;
            Parent = ResizeHandle;
        })
        Library:AddToRegistry(ResizeGlyph, { ImageColor3 = 'OutlineColor' });

        local MinSize = typeof(Config.MinSize) == 'Vector2' and Config.MinSize or Vector2.new(300, 200)
        Library:MakeResizable(Outer, ResizeHandle, function(NewSize)
            Window.Size = NewSize
        end, MinSize)

        Window.ResizeHandle = ResizeHandle
    end

    Window.Holder = Outer;
    return Window;
end;

local function OnPlayerChange()
    local PlayerList = GetPlayersString();
    for _, Value in next, Options do
        if type(Value) == 'table' and Value.Type == 'Dropdown' and Value.SpecialType == 'Player' then
            Value:SetValues(PlayerList);
        end;
    end;
end;

Library:GiveSignal(Players.PlayerAdded:Connect(OnPlayerChange));
Library:GiveSignal(Players.PlayerRemoving:Connect(OnPlayerChange));

if InputService.TouchEnabled then
    local MobileGui = Instance.new("ScreenGui")
    MobileGui.Name = "LinoriaMobileUI"
    MobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ProtectGui(MobileGui)
    MobileGui.Parent = CoreGui
    Library._MobileGui = MobileGui
    local MobileScale = Instance.new('UIScale')
    MobileScale.Scale = Library.DPIScale or 1
    MobileScale.Parent = MobileGui
    Library._MobileScale = MobileScale

    local BTN_W, BTN_H = 88, 30
    local BTN_GAP      = 40  

    local function CreateMobileButton(name, text, startPos)
        local Outer = Library:Create('Frame', {
            Name             = name .. "Outer",
            BackgroundColor3 = Library.OutlineColor,
            BorderSizePixel  = 0,
            Position         = startPos,
            Size             = UDim2.new(0, BTN_W, 0, BTN_H),
            ZIndex           = 300,
            Parent           = MobileGui,
            Active           = true,
        })
        Library:AddToRegistry(Outer, { BackgroundColor3 = 'OutlineColor' })

        local AccentFrame = Library:Create('Frame', {
            Name             = name .. "Accent",
            BackgroundColor3 = Library.AccentColor,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 1, 0, 1),
            Size             = UDim2.new(1, -2, 1, -2),
            ZIndex           = 301,
            Parent           = Outer,
        })
        Library:AddToRegistry(AccentFrame, { BackgroundColor3 = 'AccentColor' })

        local Inner = Library:Create('Frame', {
            Name             = name .. "Inner",
            BackgroundColor3 = Color3.fromRGB(8, 8, 12),
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 1, 0, 1),
            Size             = UDim2.new(1, -2, 1, -2),
            ZIndex           = 302,
            Parent           = AccentFrame,
        })

        local GradientOverlay = Library:Create('Frame', {
            Name             = name .. "Gradient",
            BackgroundColor3 = Color3.new(1, 1, 1), 
            BorderSizePixel  = 0,
            Size             = UDim2.new(1, 0, 1, 0),
            ZIndex           = 303,
            Parent           = Inner,
        })
        Library:Create('UIGradient', {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.90), 
                NumberSequenceKeypoint.new(1, 1.0)   
            }),
            Rotation = 90,
            Parent = GradientOverlay,
        })

        local Btn = Library:Create('TextButton', {
            Name                = name .. "Btn",
            BackgroundTransparency = 1,
            Size                = UDim2.new(1, 0, 1, 0),
            Font                = Enum.Font.Code,
            Text                = text,
            TextColor3          = Color3.fromRGB(255, 255, 255),
            TextSize            = Library.FontSize - 1,
            ZIndex              = 304,
            Parent              = Inner,
            Active              = true,
        })

        return Outer, Btn
    end

    local ToggleOuter, ToggleBtn = CreateMobileButton("Toggle", "Toggle UI",  UDim2.new(0, 10, 0, 10))
    local LockOuter,   LockBtn  = CreateMobileButton("Lock",   "Lock UI",  UDim2.new(0, 10, 0, 10 + BTN_H + (BTN_GAP - BTN_H)))

    -- Library.UILocked is the single source of truth for "is the UI locked".
    -- When true: the main window and draggable labels/buttons,
    -- these two mobile control buttons all stop being draggable (both on
    -- mobile touch and PC mouse). Only the ClickAction (tap-to-toggle /
    -- tap-to-lock) still works while locked, so you can always re-unlock.
    local function RefreshLockVisual()
        local Locked = Library.UILocked == true
        LockBtn.Text = Locked and "Unlock UI" or "Lock UI"
        LockBtn.TextColor3 = Locked
            and Library.AccentColor
            or  Color3.fromRGB(255, 255, 255)
    end
    Library._MobileLockRefresh = RefreshLockVisual
    RefreshLockVisual()

    local function BindMobileButtonAction(Btn, Outer, ClickAction)
        local dragging  = false
        local dragInput = nil
        local dragStart = nil
        local startPos  = nil
        local hasMoved  = false

        Btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                if not Library:BeginGesture(input) then return end
                dragging  = true
                hasMoved  = false
                dragStart = input.Position
                startPos  = Outer.Position
                dragInput = input

                local connection
                connection = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        Library:EndGesture(input)
                        -- Cả 2 nút (Toggle UI và Lock UI) phải LUÔN bấm được dù UI
                        -- đang bị khoá hay không — khoá chỉ nên chặn việc KÉO DI
                        -- CHUYỂN nút, không chặn việc BẤM nó. Trước đây nút Toggle UI
                        -- bị chặn bấm khi Library.UILocked=true (chỉ Lock mới được ưu
                        -- tiên), khiến người dùng tưởng nút bị "khoá cứng" luôn.
                        if not hasMoved then
                            ClickAction()
                        end
                    end
                end)
                Library:RegisterGestureCleanup(input, function()
                    dragging = false
                    if connection then
                        connection:Disconnect()
                        connection = nil
                    end
                end)
            end
        end)

        Library:GiveSignal(InputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                if delta.Magnitude > 10 then -- trước là 3px, quá nhạy khiến 1 cái chạm tay bình thường (luôn rung nhẹ vài px) bị hiểu nhầm là đang kéo, làm nút có cảm giác "không bấm được"/"bị khoá"
                    hasMoved = true
                end
                if (not Library.UILocked) and hasMoved then
                    Outer.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end
        end))
    end

    BindMobileButtonAction(ToggleBtn, ToggleOuter, function()
        if type(Library.Toggle) == 'function' then
            Library:Toggle()
        end
    end)

    BindMobileButtonAction(LockBtn, LockOuter, function()
        Library:SetUILocked(not Library.UILocked)
    end)

end

function BaseGroupbox:AddPlayerInfo(Idx, Info)
    Info = type(Info) == 'table' and Info or {}; local Player=Info.Player or Players.LocalPlayer; local UserId=Info.UserId or (Player and Player.UserId) or 0; local Height=tonumber(Info.Height) or 100
    local Holder=Library:Create('Frame',{BackgroundColor3=Library.BackgroundColor,BorderColor3=Library.OutlineColor,Size=UDim2.new(1,-4,0,Height),Parent=self.Container,ZIndex=5})
    Library:AddToRegistry(Holder,{BackgroundColor3='BackgroundColor',BorderColor3='OutlineColor'})
    Library:Create('ImageLabel',{BackgroundTransparency=1,Size=UDim2.fromOffset(math.max(48,Height-20),math.max(48,Height-20)),Position=UDim2.fromOffset(8,10),Image='rbxthumb://type=AvatarBust&id='..tostring(UserId)..'&w=150&h=150',Parent=Holder,ZIndex=6})
    local Desc=Info.Description; if type(Desc)=='table' then Desc=table.concat(Desc,'\n') end
    Library:CreateLabel({Position=UDim2.fromOffset(Height-4,10),Size=UDim2.new(1,-Height,0,24),Text=tostring(Info.Title or (Player and Player.DisplayName) or 'Player'),RichText=true,TextXAlignment=Enum.TextXAlignment.Left,Parent=Holder,ZIndex=6})
    Library:CreateLabel({Position=UDim2.fromOffset(Height-4,34),Size=UDim2.new(1,-Height,1,-40),Text=tostring(Desc or (Player and '@'..Player.Name or '')),RichText=true,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Parent=Holder,ZIndex=6})
    self:Resize(); return Holder
end

function BaseGroupbox:AddPriorityDropdown(Idx, Info)
    Info = Info or {}
    Info.Multi = true
    Info.AllowNull = true
    Info.Default = Info.Default or {}
    local dropdown = self:AddDropdown(Idx, Info)
    dropdown.Priority = true
    dropdown.Order = {}
    if type(Info.Default) == 'table' then
        if #Info.Default > 0 then
            for _, v in ipairs(Info.Default) do
                if table.find(dropdown.Values, v) and not dropdown.DisabledValues[v] then
                    table.insert(dropdown.Order, v)
                end
            end
        else
            for v, selected in next, Info.Default do
                if selected == true and table.find(dropdown.Values, v) and not dropdown.DisabledValues[v] then
                    table.insert(dropdown.Order, v)
                end
            end
        end
    end
    function dropdown:SetValue(Order)
        local values = type(Order) == 'table' and Order or {}
        self.Order = {}
        if #values > 0 then
            for _, v in ipairs(values) do
                if table.find(self.Values, v) and not self.DisabledValues[v] then table.insert(self.Order, v) end
            end
        else
            for v, selected in next, values do
                if selected == true and table.find(self.Values, v) and not self.DisabledValues[v] then table.insert(self.Order, v) end
            end
        end
        local selected = {}
        for _, v in ipairs(self.Order) do selected[v] = true end
        self.Value = selected
        self:BuildDropdownList(); self:Display()
        Library:SafeCallback(self.Callback, self.Order)
        Library:SafeCallback(self.Changed, self.Order)
    end
    function dropdown:GetValue() return self.Order end
    function dropdown:MoveUp(Value)
        local i = table.find(self.Order, Value); if not i or i <= 1 then return end
        self.Order[i], self.Order[i-1] = self.Order[i-1], self.Order[i]; self:SetValue(self.Order)
    end
    function dropdown:MoveDown(Value)
        local i = table.find(self.Order, Value); if not i or i >= #self.Order then return end
        self.Order[i], self.Order[i+1] = self.Order[i+1], self.Order[i]; self:SetValue(self.Order)
    end
    function dropdown:Remove(Value) self:Deselect(Value); self.Order = self.Order or {}; local i = table.find(self.Order, Value); if i then table.remove(self.Order, i) end end
    return dropdown
end

getgenv().Library = Library


-- Extended public helpers inspired by mature UI libraries, kept compatible with Linoria APIs.
--
-- AddWatermark(Segments):
--   * nil            -> ẩn watermark (dùng lại hệ thống text đơn giản cũ)
--   * string         -> watermark 1 dòng text đơn giản (hệ thống cũ, không đổi)
--   * table segments -> watermark nhiều "segment" (icon + text + player card),
--                        dùng hệ thống MỚI, tự quản lý riêng, KHÔNG đụng vào
--                        Library.Watermark (Frame Instance) để tránh lỗi gán
--                        thuộc tính lạ lên Instance (bug đã fix).
--
-- Segments = {
--   { Text = "chuỗi cố định" },
--   { Text = function() return "chuỗi động, tự refresh theo Watermark.RefreshRate" end },
--   { Icon = 6031097225, Text = "..." }, -- Icon chỉ nhận asset id số hoặc 'rbxassetid://...'/'http...'
--   { Player = SomePlayer, NameType = "Username" }, -- avatar + tên (mặc định DisplayName)
--   { Text = "CreU", Accent = true }, -- tô màu AccentColor thay vì FontColor
-- }
--
-- LƯU Ý: bản Library này không có bộ icon theo tên (kiểu "flame","cpu","wifi" của
-- Lucide icon pack). Icon dạng tên chữ thường sẽ không hiện icon nào (không lỗi,
-- chỉ đơn giản bỏ qua phần icon của segment đó) — chỉ Icon dạng số/asset id hoạt động.
function Library:AddWatermark(Segments)
    if Segments == nil then
        self:SetWatermark('')
        return self.Watermark
    elseif type(Segments) ~= 'table' then
        self:SetWatermark(tostring(Segments))
        return self.Watermark
    end

    return self:BuildWatermarkV2(Segments)
end

function Library:BuildWatermarkV2(Segments)
    if Library._WatermarkV2 then
        local Holder = Library._WatermarkV2.Holder
        if Holder and Holder.Parent then Holder:Destroy() end
        Library._WatermarkV2 = nil
    end
    if Library.Watermark then Library.Watermark.Visible = false end

    local Watermark = { RefreshRate = 1 }

    local PADDING = 12
    local HEIGHT = 20

    local Outer = Library:Create('Frame', {
        Name = 'WatermarkV2';
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 10, 0, 10);
        Size = UDim2.new(0, 0, 0, HEIGHT);
        ZIndex = 200;
        Parent = ScreenGui;
    });
    local Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 200;
        Parent = Outer;
    });
    Library:AddToRegistry(Inner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });

    local Layout = Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        VerticalAlignment = Enum.VerticalAlignment.Center;
        Padding = UDim.new(0, 5);
        Parent = Inner;
    });
    Library:Create('UIPadding', {
        PaddingLeft = UDim.new(0, 6);
        PaddingRight = UDim.new(0, 6);
        Parent = Inner;
    });

    local function ResolveIcon(IconValue)
        if type(IconValue) == 'number' then
            return 'rbxassetid://' .. tostring(IconValue);
        elseif type(IconValue) == 'string' then
            if IconValue:match('^rbxassetid://') or IconValue:match('^http') then
                return IconValue;
            end;
        end;
        return nil;
    end;

    local DynamicLabels = {};

    local function BuildSegment(Info, Order)
        if type(Info) ~= 'table' then
            Info = { Text = tostring(Info or '') }
        end

        local Holder = Library:Create('Frame', {
            BackgroundTransparency = 1;
            AutomaticSize = Enum.AutomaticSize.X;
            Size = UDim2.new(0, 0, 1, 0);
            LayoutOrder = Order;
            Parent = Inner;
        });
        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal;
            SortOrder = Enum.SortOrder.LayoutOrder;
            VerticalAlignment = Enum.VerticalAlignment.Center;
            Padding = UDim.new(0, 4);
            Parent = Holder;
        });

        if Order > 1 then
            Library:CreateLabel({
                Size = UDim2.new(0, 6, 1, 0);
                Text = '|';
                TextColor3 = Library.OutlineColor;
                TextSize = Library.FontSize;
                LayoutOrder = 0;
                Parent = Holder;
            });
        end;

        if Info.Player and type(Info.Player) == 'userdata' then
            local PlayerObject = Info.Player
            local Ok, Thumb = pcall(function()
                return Players:GetUserThumbnailAsync(PlayerObject.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48);
            end);

            local Avatar = Library:Create('ImageLabel', {
                BackgroundTransparency = 1;
                Size = UDim2.new(0, 16, 0, 16);
                Image = (Ok and Thumb) or '';
                LayoutOrder = 1;
                Parent = Holder;
            });
            Library:Create('UICorner', { CornerRadius = UDim.new(1, 0); Parent = Avatar });

            Library:CreateLabel({
                Size = UDim2.new(0, 0, 1, 0);
                AutomaticSize = Enum.AutomaticSize.X;
                Text = (Info.NameType == 'Username') and PlayerObject.Name or PlayerObject.DisplayName;
                TextSize = Library.FontSize;
                LayoutOrder = 2;
                Parent = Holder;
            });
            return;
        end;

        local IconImage = ResolveIcon(Info.Icon);
        if IconImage then
            Library:Create('ImageLabel', {
                BackgroundTransparency = 1;
                Size = UDim2.new(0, 13, 0, 13);
                Image = IconImage;
                ImageColor3 = Info.Accent and Library.AccentColor or Library.FontColor;
                LayoutOrder = 1;
                Parent = Holder;
            });
        end;

        local InitialText = Info.Text;
        if type(InitialText) == 'function' then
            local Ok, Result = pcall(InitialText);
            InitialText = (Ok and type(Result) == 'string') and Result or '';
        elseif type(InitialText) ~= 'string' then
            InitialText = '';
        end;

        local TextLabel = Library:CreateLabel({
            Size = UDim2.new(0, 0, 1, 0);
            AutomaticSize = Enum.AutomaticSize.X;
            Text = InitialText;
            TextColor3 = Info.Accent and Library.AccentColor or Library.FontColor;
            TextSize = Library.FontSize;
            LayoutOrder = 2;
            Parent = Holder;
        });
        if Info.Accent then
            Library:RemoveFromRegistry(TextLabel);
            Library:AddToRegistry(TextLabel, { TextColor3 = 'AccentColor' });
        end;

        if type(Info.Text) == 'function' then
            table.insert(DynamicLabels, { Label = TextLabel; Fn = Info.Text });
        end;
    end;

    for Idx, SegInfo in ipairs(Segments) do
        BuildSegment(SegInfo, Idx);
    end;

    Outer.Size = UDim2.new(0, Layout.AbsoluteContentSize.X + PADDING, 0, HEIGHT);
    Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        Outer.Size = UDim2.new(0, Layout.AbsoluteContentSize.X + PADDING, 0, HEIGHT);
    end);

    Library:MakeDraggable(Outer);

    if #DynamicLabels > 0 then
        task.spawn(function()
            while (not Library.Unloaded) and ScreenGui.Parent do
                for _, Entry in ipairs(DynamicLabels) do
                    local Ok, Result = pcall(Entry.Fn);
                    if Ok and type(Result) == 'string' then
                        Entry.Label.Text = Result;
                    end;
                end;
                task.wait(Watermark.RefreshRate or 1);
            end;
        end);
    end;

    Watermark.Holder = Outer;
    Library._WatermarkV2 = Watermark;
    return Watermark;
end

function Library:AddTooltip(InfoStr, DisabledInfoStr, HoverInstance, Variant)
    if typeof(HoverInstance) ~= 'Instance' and type(Variant) ~= 'nil' then
        HoverInstance, Variant = DisabledInfoStr, HoverInstance
        DisabledInfoStr = nil
    end
    if not HoverInstance then return nil end
    local ok, result = pcall(function()
        return self:AddToolTip(tostring(InfoStr or ''), HoverInstance)
    end)
    return ok and result or nil
end

function Library:MakeResizable(UI, DragFrame, Callback, MinSize)
    if not UI or not DragFrame then return nil end
    local SafeMin = typeof(MinSize) == 'Vector2' and MinSize or Vector2.new(180, 120)
    local MinX = math.max(1, SafeMin.X)
    local MinY = math.max(1, SafeMin.Y)

    local dragging = false
    local dragStart
    local startSize
    local changedConn
    local endedConn
    local activeInput

    local function stop()
        dragging = false
        if changedConn then
            changedConn:Disconnect()
            changedConn = nil
        end
        if endedConn then
            endedConn:Disconnect()
            endedConn = nil
        end
        local PreviousInput = activeInput
        activeInput = nil
        Library:EndGesture(PreviousInput)
        if Callback then self:SafeCallback(Callback, UI.Size) end
    end

    DragFrame.InputBegan:Connect(function(Input)
        if Library.UILocked then return end
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1
            and Input.UserInputType ~= Enum.UserInputType.Touch then return end
        -- If a previous resize gesture never got a matching InputEnded
        -- (edge case: input object destroyed mid-drag), don't leave stale
        -- connections running underneath a fresh one.
        if dragging then stop() end
        if not Library:BeginGesture(Input) then return end

        dragging = true
        activeInput = Input
        dragStart = Input.Position
        startSize = UI.Size

        changedConn = InputService.InputChanged:Connect(function(Change)
            if not dragging then return end
            -- Only react to the exact InputObject that started this resize
            -- (or a matching MouseMovement for mouse users) -- previously any
            -- moving input was accepted, which could cross-talk with other
            -- drags happening at the same time.
            if Change ~= activeInput
                and not (Change.UserInputType == Enum.UserInputType.MouseMovement
                    and activeInput.UserInputType == Enum.UserInputType.MouseButton1) then return end
            local Delta = Change.Position - dragStart
            local scale = 1
            local okScale, foundScale = pcall(GetAncestorUIScale, UI)
            if okScale and foundScale and type(foundScale.Scale) == 'number' and foundScale.Scale > 0 then
                scale = foundScale.Scale
            end
            local X = math.max(MinX, startSize.X.Offset + (Delta.X / scale))
            local Y = math.max(MinY, startSize.Y.Offset + (Delta.Y / scale))
            UI.Size = UDim2.new(startSize.X.Scale, X, startSize.Y.Scale, Y)
        end)

        endedConn = InputService.InputEnded:Connect(function(EndInput)
            -- Only the specific InputObject that started this resize may end
            -- it (same fix as MakeDraggable) -- previously any touch ending
            -- anywhere on screen would stop the resize prematurely.
            if EndInput == activeInput then
                stop()
            end
        end)
        Library:RegisterGestureCleanup(activeInput, function()
            if changedConn then changedConn:Disconnect(); changedConn = nil end
            if endedConn then endedConn:Disconnect(); endedConn = nil end
        end)
    end)

    return UI
end

function Library:AddDraggableLabel(...)
    local Params = select(1, ...)
    if type(Params) ~= 'table' then
        Params = { Text = tostring(Params or ''), Position = select(2, ...), Size = select(3, ...) }
    end
    local Label = self:Create('TextLabel', {
        BackgroundTransparency = 1,
        Size = Params.Size or UDim2.fromOffset(180, 20),
        Position = Params.Position or UDim2.fromOffset(10, 10),
        Text = Params.Text or '',
        Font = Params.Font or self.Font,
        TextSize = Params.TextSize or self.FontSize,
        TextColor3 = Params.TextColor3 or self.FontColor,
        TextXAlignment = Params.TextXAlignment or Enum.TextXAlignment.Left,
        Active = true,
        ZIndex = Params.ZIndex or 200,
        Parent = Params.Parent or self.ScreenGui,
    })
    self:AddToRegistry(Label, { TextColor3 = 'FontColor' })
    self:MakeDraggable(Label, Params.Cutoff or 40, false)
    return Label
end

function Library:AddDraggableButton(...)
    local Params = select(1, ...)
    local Callback
    if type(Params) ~= 'table' then
        Callback = select(2, ...)
        Params = { Text = tostring(Params or ''), Func = Callback }
    else
        Callback = Params.Callback or Params.Func
    end
    local Outer = self:Create('TextButton', {
        BackgroundColor3 = Params.BackgroundColor3 or self.MainColor,
        BorderColor3 = Params.BorderColor3 or self.OutlineColor,
        Size = Params.Size or UDim2.fromOffset(180, 22),
        Position = Params.Position or UDim2.fromOffset(10, 10),
        Text = Params.Text or '',
        Font = Params.Font or self.Font,
        TextSize = Params.TextSize or self.FontSize,
        TextColor3 = Params.TextColor3 or self.FontColor,
        Active = true,
        AutoButtonColor = false,
        ZIndex = Params.ZIndex or 200,
        Parent = Params.Parent or self.ScreenGui,
    })
    self:AddToRegistry(Outer, {
        BackgroundColor3 = 'MainColor',
        BorderColor3 = 'OutlineColor',
        TextColor3 = 'FontColor',
    })
    self:MakeDraggable(Outer, Params.Cutoff or 40, false)
    Outer.MouseButton1Click:Connect(function()
        if Callback then self:SafeCallback(Callback, Outer) end
    end)
    return Outer
end

function Library:AddDraggableImageButton(...)
    local Params = select(1, ...)
    if type(Params) ~= 'table' then Params = { Image = tostring(Params or '') } end
    local Button = self:Create('ImageButton', {
        BackgroundTransparency = Params.BackgroundTransparency == nil and 1 or Params.BackgroundTransparency,
        Size = Params.Size or UDim2.fromOffset(32, 32),
        Position = Params.Position or UDim2.fromOffset(10, 10),
        Image = Params.Image or '',
        ImageColor3 = Params.ImageColor3 or self.FontColor,
        AutoButtonColor = false,
        Active = true,
        ZIndex = Params.ZIndex or 200,
        Parent = Params.Parent or self.ScreenGui,
    })
    self:MakeDraggable(Button, Params.Cutoff or 40, false)
    if Params.Callback then
        Button.MouseButton1Click:Connect(function() self:SafeCallback(Params.Callback, Button) end)
    end
    return Button
end

-- Compatibility aliases commonly used by advanced Linoria-style scripts.
function BaseGroupbox:AddCheckbox(Idx, Info)
    return self:AddToggle(Idx, Info)
end

function BaseGroupbox:AddParagraph(Text, DoesWrap)
    return self:AddLabel(Text, DoesWrap ~= false)
end

function BaseGroupbox:AddSection(Text)
    return self:AddLabel(Text, false)
end

function BaseGroupbox:AddKeybind(Idx, Info)
    return self:AddKeyPicker(Idx, Info)
end


-- Compatibility helpers for the ObsidianUltra-style showcase, layered on the Linoria core.
function Library:SetNotifySide(Side)
    Side=tostring(Side or 'Right')
    Library.NotifySide=Side
    Library.NotifyConfig=Library.NotifyConfig or {}
    Library.NotifyConfig.Alignment=Side
    if Library.UpdateNotifAlignment then Library.UpdateNotifAlignment() end
    return Library
end
function Library:SetDPIScale(Value)
    if type(Value) == 'string' then
        Value = tonumber(Value:match('%-?%d+%.?%d*'))
    end
    local n=math.clamp(tonumber(Value) or 100,50,200)
    Library.DPIScale=n/100
    for _, Window in next, Library._Windows or {} do
        if Window and Window._Scale then
            Window._Scale.Scale=Library.DPIScale
        end
    end
    if Library._MobileScale then
        Library._MobileScale.Scale=Library.DPIScale
    end
    if Library.NotifyScale then
        Library.NotifyScale.Scale=Library.DPIScale
    end
    local LiveDropdownScales = {}
    for _, ScaleObject in next, Library._DropdownScales or {} do
        if ScaleObject and ScaleObject.Parent then
            local owner = GetAncestorUIScale(ScaleObject.Parent)
            ScaleObject.Scale = owner and owner.Scale or Library.DPIScale
            LiveDropdownScales[#LiveDropdownScales + 1] = ScaleObject
        end
    end
    Library._DropdownScales = LiveDropdownScales
    return Library
end
local _OrigNotify = Library.Notify
Library.Notify = function(self, Payload, Time)
    if type(Payload) == 'table' then
        local title=tostring(Payload.Title or '')
        local description=tostring(Payload.Description or Payload.Text or '')
        local text=description
        if title ~= '' then text=title .. (description ~= '' and '\n' or '') .. description end
        return _OrigNotify(self, text, Payload.Time or Time)
    end
    return _OrigNotify(self, Payload, Time)
end

local _OrigCreateWindow = Library.CreateWindow
Library.CreateWindow = function(self,...)
    local Window = _OrigCreateWindow(self,...)
    if Window and not Window.AddKeyTab then
        function Window:AddKeyTab(Name)
            local Tab=Window:AddTab(Name,'key'); Tab.IsKeyTab=true
            function Tab:AddKeyBox(Callback)
                local Box=Tab:AddLeftGroupbox('Key System','key')
                local InputIdx='KeyInput_'..tostring(math.random(100000,999999))
                Box:AddInput(InputIdx,{Text='Key',Placeholder='Enter key...'})
                Box:AddButton('Submit',function() local value=Options[InputIdx] and Options[InputIdx].Value or ''; if Callback then Library:SafeCallback(Callback,value) end end)
                return Box
            end
            return Tab
        end
    end
    return Window
end

-- Bridge direct compatibility methods into the existing Linoria BaseGroupbox __index table.
do
    local OriginalIndex = BaseGroupbox.__index
    BaseGroupbox.Resize = BaseGroupbox.Resize or function(self)
        return self
    end
    BaseGroupbox.__index = function(self, Key)
        local Method = OriginalIndex and OriginalIndex[Key]
        if Method ~= nil then return Method end
        return BaseGroupbox[Key]
    end
end

return Library
