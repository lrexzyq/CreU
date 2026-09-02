--enjoy!

local Repo = "https://raw.githubusercontent.com/lrexzyq/CreU/main/"

local Library = loadstring(game:HttpGet(Repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(Repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(Repo .. "addons/SaveManager.lua"))()

local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Options = Library.Options
local Toggles = Library.Toggles

local function Log(...)
    print("[CreU Example]", ...)
end

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true
Library.DebugCreateErrors = true

local Window = Library:CreateWindow({
    Title = "CreU Showcase",
    Icon = 95816097006870,
    ShowCustomCursor = true,
    NotifySide = "Right",
    Minimizable = true,
    MinimizeKeybind = Enum.KeyCode.RightBracket,
    Center = true,
    Size = UDim2.fromOffset(700, 600),
    Footer = {
        "CreU | ",
        {
            Text = "Full Example",
            Copyable = true
        },
        " | UserId: ",
        {
            Text = tostring(LocalPlayer.UserId),
            Copyable = true
        }
    },
    CopyableFooter = true,
})

Window:SetAlwaysOnTop(true)

local Tabs = {
    Home = Window:AddTab({
        Name = "Home",
        Icon = "user",
        Description = "Overview and common controls",
    }),

    Elements = Window:AddTab({
        Name = "Elements",
        Icon = "layout-grid",
        Description = "Full element showcase",
    }),

    Advanced = Window:AddTab({
        Name = "Advanced",
        Icon = "sliders-horizontal",
        Description = "Advanced dropdown/keybind tests",
    }),

    Dependency = Window:AddTab({
        Name = "Dependency",
        Icon = "git-branch",
        Description = "DependencyBox demonstrations",
    }),

    Layout = Window:AddTab({
        Name = "Layout",
        Icon = "panels-top-left",
        Description = "Rows, tabboxes and collapsible groups",
    }),

    Single = Window:AddTab({
        Name = "Single Column",
        Icon = "square",
        Description = "Single-column layout",
        SingleColumn = true,
    }),

    Key = Window:AddKeyTab("Key System"),

    Settings = Window:AddTab({
        Name = "Settings",
        Icon = "settings",
        Description = "Theme and configuration managers",
    }),
}

do
    Tabs.Home:AddPlayerInfo("HomeBanner", {
        Player = LocalPlayer,
        Title = "Welcome to <b>CreU</b>",
        Description = {
            "Linoria-compatible UI core",
            "Normal and searchable dropdowns",
            "Mobile-friendly search focus",
            "Dependencies, priorities and layouts",
            "Themes, configs, keybinds and watermark",
        },
        Height = 100,
    })

    local General = Tabs.Home:AddLeftGroupbox("General", "home")

    General:AddToggle("DemoEnabled", {
        Text = "Demo Toggle",
        Tooltip = "Basic toggle saved by SaveManager",
        Default = true,
    }):AddKeyPicker("DemoEnabledKey", {
        Default = "F6",
        Mode = "Toggle",
        Text = "Demo Toggle",
        SyncToggleState = false,
    })

    General:AddSlider("DemoValue", {
        Text = "Demo Value",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
    })

    General:AddInput("DemoText", {
        Text = "Demo Input",
        Default = "CreU",
        Placeholder = "Type something...",
        ClearTextOnFocus = false,
        Finished = false,
    })

    General:AddButton({
        Text = "Show Notification",
        Tooltip = "Tests Library:Notify",
        Func = function()
            local Value = Options.DemoText and Options.DemoText.Value or "CreU"
            Library:Notify("Hello from CreU: " .. tostring(Value), 3)
        end,
    })

    local Visuals = Tabs.Home:AddRightGroupbox("Visuals", "eye")

    Visuals:AddToggle("VisualEnabled", {
        Text = "Visuals Enabled",
        Default = true,
    }):AddColorPicker("VisualColor", {
        Default = Color3.fromRGB(0, 255, 140),
        Title = "Visual Color",
        Transparency = 0,
    })

    Visuals:AddSlider("VisualDistance", {
        Text = "Max Distance",
        Default = 500,
        Min = 50,
        Max = 2000,
        Rounding = 0,
        Suffix = " studs",
    })

    Visuals:AddDropdown("VisualFeatures", {
        Text = "Visual Features",
        Values = {
            "Box",
            "Name",
            "Distance",
            "Health",
            "Tracer",
        },
        Default = {
            "Box",
            "Name",
        },
        Multi = true,
        Searchable = true,
        SelectAllButtons = true,
    })

    Toggles.DemoEnabled:OnChanged(function()
        Log("DemoEnabled:", Toggles.DemoEnabled.Value)
    end)

    Options.DemoValue:OnChanged(function()
        Log("DemoValue:", Options.DemoValue.Value)
    end)

    Options.VisualColor:OnChanged(function()
        Log("VisualColor:", Options.VisualColor.Value)
    end)
end

do
    local Buttons = Tabs.Elements:AddLeftGroupbox(
        "Buttons",
        "mouse-pointer-click"
    )

    Buttons:AddButton({
        Text = "Normal Button",
        Tooltip = "Normal single-click button",
        Func = function()
            Log("Normal button clicked")
        end,
    })

    Buttons:AddButton({
        Text = "Double-click Button",
        DoubleClick = true,
        Tooltip = "Requires a second click",
        Func = function()
            Library:Notify("Double-click button activated", 2)
        end,
    })

    Buttons:AddButton({
        Text = "Disabled Button",
        Disabled = true,
        DisabledTooltip = "This button is disabled",
        Func = function()
        end,
    })

    local TogglesBox = Tabs.Elements:AddLeftGroupbox(
        "Toggles / Checkbox",
        "toggle-left"
    )

    TogglesBox:AddToggle("BasicToggle", {
        Text = "Basic Toggle",
        Default = true,
    })

    TogglesBox:AddCheckbox("BasicCheckbox", {
        Text = "Checkbox Alias",
        Default = false,
    })

    TogglesBox:AddToggle("RiskyToggle", {
        Text = "Risky Toggle",
        Default = false,
        Risky = true,
    })

    local Labels = Tabs.Elements:AddLeftGroupbox(
        "Labels",
        "text"
    )

    Labels:AddLabel("Normal label")

    Labels:AddLabel(
        "Wrapped label with a longer message to test layout and resizing.",
        true
    )

    Labels:AddDivider()

    Labels:AddParagraph(
        "Paragraph-style content with wrapping.",
        true
    )

    local Sliders = Tabs.Elements:AddLeftGroupbox(
        "Sliders",
        "sliders-horizontal"
    )

    Sliders:AddSlider("BasicSlider", {
        Text = "Basic Slider",
        Default = 2,
        Min = 0,
        Max = 5,
        Rounding = 1,
    })

    Sliders:AddSlider("FormattedSlider", {
        Text = "Formatted Slider",
        Default = 3,
        Min = 0,
        Max = 5,
        Rounding = 0,
        FormatDisplayValue = function(Slider, Value)
            if Value == Slider.Max then
                return "Everything"
            end

            if Value == Slider.Min then
                return "Nothing"
            end

            return tostring(Value)
        end,
    })

    Sliders:AddSlider("CompactSlider", {
        Text = "Compact",
        Default = 25,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Prefix = "",
        Suffix = "%",
        Compact = true,
    })

    Sliders:AddSlider("HiddenMaxSlider", {
        Text = "Hidden Max",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
        HideMax = true,
    })

    local Inputs = Tabs.Elements:AddLeftGroupbox(
        "Inputs",
        "keyboard"
    )

    Inputs:AddInput("TextInput", {
        Text = "Textbox",
        Default = "Type here",
        Placeholder = "Placeholder",
        ClearTextOnFocus = true,
        Finished = false,
        Numeric = false,
        MaxLength = 32,
    })

    Inputs:AddInput("NumericInput", {
        Text = "Numeric Input",
        Default = "123",
        Placeholder = "Numbers only",
        Numeric = true,
        Finished = false,
    })
end

do
    local Dropdowns = Tabs.Advanced:AddLeftGroupbox(
        "Dropdowns",
        "chevron-down"
    )

    Dropdowns:AddDropdown("BasicDropdown", {
        Text = "Normal Dropdown",
        Values = {
            "Alpha",
            "Bravo",
            "Charlie",
            "Delta",
        },
        Default = 1,
    })

    Dropdowns:AddDropdown("SearchableDropdown", {
        Text = "Searchable Dropdown",
        Values = {
            "Alpha",
            "Bravo",
            "Charlie",
            "Delta",
            "Echo",
            "Foxtrot",
            "Golf",
            "Hotel",
            "India",
            "Juliett",
            "Kilo",
            "Lima",
            "Mike",
            "November",
            "Oscar",
        },
        Default = 1,
        Searchable = true,
        Search = true,
        Placeholder = "Search items...",
        MaxVisibleItems = 8,
        ItemHeight = 20,
        Expandable = true,
        ExpandColumns = 1,
    })

    Dropdowns:AddDropdown("MultiDropdown", {
        Text = "Multi Select",
        Values = {
            "Box",
            "Name",
            "Distance",
            "Health",
            "Tracer",
        },
        Default = {
            "Box",
            "Name",
        },
        Multi = true,
        Searchable = true,
        SelectAllButtons = true,
        DragSelect = true,
    })

    Dropdowns:AddDropdown("DictionaryDropdown", {
        Text = "Dictionary Values",
        Values = {
            item01 = "Excalibur",
            item05 = "Aegis Shield",
            item06 = "Wooden Club",
        },
        Default = "item01",
        DisabledValues = {
            "item05",
        },
    })

    Dropdowns:AddDropdown("VisibleDropdown", {
        Text = "Visible Control",
        Values = {
            "Enabled",
            "Disabled",
        },
        Default = 1,
        Visible = true,
    })

    Dropdowns:AddDropdown("DisabledDemoDropdown", {
        Text = "Disabled Dropdown",
        Values = {
            "One",
            "Two",
            "Three",
        },
        Default = 1,
        Disabled = true,
        DisabledTooltip = "Disabled demo",
    })

    local Materials = {}

    for _, Material in ipairs(Enum.Material:GetEnumItems()) do
        Materials[#Materials + 1] = Material.Name
    end

    Dropdowns:AddDropdown("LongDropdown", {
        Text = "Long Material List",
        Values = Materials,
        Default = 1,
        Multi = true,
        Searchable = true,
        MaxVisibleItems = 10,
        MaxVisibleDropdownItems = 10,
    })

    local Priority = Tabs.Advanced:AddRightGroupbox(
        "Priority / Special",
        "list-ordered"
    )

    Priority:AddPriorityDropdown("PriorityDropdown", {
        Text = "Priority Dropdown",
        Values = {
            "Critical",
            "High",
            "Medium",
            "Low",
        },
        Default = {
            "Critical",
            "High",
        },
        Searchable = true,
        SelectAllButtons = true,
    })

    Priority:AddDropdown("PlayerDropdown", {
        Text = "Players",
        SpecialType = "Player",
        AllowNull = true,
        Searchable = true,
    })

    Priority:AddDropdown("TeamDropdown", {
        Text = "Teams",
        SpecialType = "Team",
        AllowNull = true,
        Searchable = true,
    })

    local Pickers = Tabs.Advanced:AddRightGroupbox(
        "Color / Key Pickers",
        "palette"
    )

    Pickers:AddLabel("Color Picker"):AddColorPicker(
        "DemoColor",
        {
            Default = Color3.fromRGB(0, 255, 0),
            Title = "Demo Color",
            Transparency = 0,
        }
    )

    Pickers:AddLabel("Color Picker Alpha"):AddColorPickerAlpha(
        "DemoColorAlpha",
        {
            Default = Color3.fromRGB(255, 170, 0),
            Title = "Alpha Color",
        }
    )

    Pickers:AddLabel("Toggle Keybind"):AddKeyPicker(
        "DemoKey",
        {
            Default = "F7",
            Mode = "Toggle",
            Text = "Demo Keybind",
        }
    )

    Pickers:AddLabel("Hold Keybind"):AddKeyPicker(
        "HoldKey",
        {
            Default = "E",
            Mode = "Hold",
            Text = "Hold Keybind",
        }
    )

    Pickers:AddLabel("Always Keybind"):AddKeyPicker(
        "AlwaysKey",
        {
            Default = "F8",
            Mode = "Always",
            Text = "Always Keybind",
        }
    )

    Pickers:AddLabel("Press Callback"):AddKeyPicker(
        "PressKey",
        {
            Default = "X",
            Mode = "Toggle",
            Text = "Press Callback",
            Callback = function(Value)
                Log("Press key callback:", Value)
            end,
            ChangedCallback = function(Value)
                Log("Key changed:", Value)
            end,
        }
    )

    Pickers:AddLabel("No UI Key"):AddKeyPicker(
        "NoUIKey",
        {
            Default = "F9",
            Mode = "Toggle",
            Text = "No UI Key",
            NoUI = true,
        }
    )
end

do
    local BasicDependency = Tabs.Dependency:AddLeftGroupbox(
        "Basic Dependency",
        "git-branch"
    )

    BasicDependency:AddToggle("DependencyMaster", {
        Text = "Enable dependent controls",
        Default = false,
        Tooltip = "Turn this on to reveal the DependencyBox",
    })

    local Depbox = BasicDependency:AddDependencyBox()

    Depbox:AddLabel(
        "The controls below are visible only while the master toggle is enabled.",
        true
    )

    Depbox:AddToggle("DependentToggle", {
        Text = "Dependent Toggle",
        Default = false,
    })

    Depbox:AddSlider("DependentSlider", {
        Text = "Dependent Slider",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
    })

    Depbox:AddDropdown("DependentDropdown", {
        Text = "Dependent Dropdown",
        Values = {
            "Option A",
            "Option B",
            "Option C",
        },
        Default = 1,
    })

    Depbox:AddInput("DependentInput", {
        Text = "Dependent Input",
        Default = "Dependency",
        Placeholder = "Only visible when enabled",
    })

    Depbox:AddLabel("Dependent color"):AddColorPicker(
        "DependentColor",
        {
            Default = Color3.fromRGB(120, 180, 255),
            Title = "Dependency Color",
            Transparency = 0,
        }
    )

    Depbox:SetupDependencies({
        {
            Toggles.DependencyMaster,
            true,
        },
    })

    local MultiDependency = Tabs.Dependency:AddRightGroupbox(
        "Multiple Dependencies",
        "git-merge"
    )

    MultiDependency:AddToggle("DependencyA", {
        Text = "Dependency A",
        Default = false,
    })

    MultiDependency:AddToggle("DependencyB", {
        Text = "Dependency B",
        Default = false,
    })

    local MultiDepbox = MultiDependency:AddDependencyBox()

    MultiDepbox:AddLabel(
        "Both toggles must be enabled.",
        true
    )

    MultiDepbox:AddToggle("BothDependentToggle", {
        Text = "Both Conditions Met",
        Default = false,
    })

    MultiDepbox:AddSlider("BothDependentSlider", {
        Text = "Advanced Slider",
        Default = 5,
        Min = 0,
        Max = 10,
        Rounding = 0,
    })

    MultiDepbox:SetupDependencies({
        {
            Toggles.DependencyA,
            true,
        },
        {
            Toggles.DependencyB,
            true,
        },
    })
end

do
    local LayoutLeft = Tabs.Layout:AddLeftGroupbox(
        "Layouts",
        "panels-top-left"
    )

    LayoutLeft:AddLabel(
        "This section demonstrates Row and collapsed controls.",
        true
    )

    local Row = LayoutLeft:AddRow(2)

    Row:AddToggle("RowToggle", {
        Text = "Row Toggle",
        Default = false,
    })

    Row:AddSlider("RowSlider", {
        Text = "Row Slider",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
    })

    LayoutLeft:AddDivider()

    LayoutLeft:AddToggle("CollapsedDemoToggle", {
        Text = "Toggle inside groupbox",
        Default = false,
    })

    local Collapsed = Tabs.Layout:AddRightGroupbox(
        "Collapsible Groupbox",
        "chevrons-down-up"
    )

    Collapsed:AddLabel(
        "This whole groupbox can be collapsed.",
        true
    )

    Collapsed:AddToggle("CollapsedToggle", {
        Text = "Collapsed Toggle",
        Default = false,
    })

    Collapsed:AddSlider("CollapsedSlider", {
        Text = "Collapsed Slider",
        Default = 25,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
    })

    Collapsed:AddDropdown("CollapsedDropdown", {
        Text = "Collapsed Dropdown",
        Values = {
            "One",
            "Two",
            "Three",
        },
        Default = 1,
    })

    Collapsed:AddButton({
        Text = "Collapse / Expand",
        Func = function()
            Collapsed:ToggleCollapsed()
        end,
    })

    local Tabbox = Tabs.Layout:AddRightTabbox("Tabbox Showcase")

    local TabOne = Tabbox:AddTab("Tab 1")

    TabOne:AddLabel("First internal tab", true)

    TabOne:AddToggle("TabboxToggle", {
        Text = "Tab 1 Toggle",
        Default = false,
    })

    TabOne:AddSlider("TabboxSlider", {
        Text = "Tab 1 Slider",
        Default = 5,
        Min = 0,
        Max = 10,
        Rounding = 0,
    })

    local TabTwo = Tabbox:AddTab("Tab 2")

    TabTwo:AddLabel("Second internal tab", true)

    TabTwo:AddDropdown("TabboxDropdown", {
        Text = "Tab 2 Dropdown",
        Values = {
            "Alpha",
            "Bravo",
            "Charlie",
        },
        Default = 1,
    })

    TabTwo:AddInput("TabboxInput", {
        Text = "Tab 2 Input",
        Default = "Hello",
        Placeholder = "Input...",
    })
end

do
    local Farm = Tabs.Single:AddGroupbox({
        Name = "Single Column Demo",
        IconName = "layout-dashboard",
    })

    Farm:AddToggle("SingleToggle", {
        Text = "Single Column Toggle",
        Default = false,
    })

    Farm:AddDropdown("SingleMode", {
        Text = "Single Column Mode",
        Values = {
            "Nearest",
            "Strongest",
            "Fastest",
        },
        Default = 1,
    })

    Farm:AddSlider("SingleDelay", {
        Text = "Loop Delay",
        Default = 250,
        Min = 0,
        Max = 1000,
        Rounding = 0,
        Suffix = " ms",
    })

    Farm:AddInput("SingleInput", {
        Text = "Single Input",
        Default = "CreU",
        Placeholder = "Text...",
    })

    Farm:AddButton({
        Text = "Single Column Button",
        Func = function()
            Log("Single column button")
        end,
    })

    Farm:AddLabel(
        "This tab uses the library's single-column layout.",
        true
    )
end

do
    Tabs.Key:AddLabel({
        Text = "Enter the key below. The demo accepts: Banana",
        DoesWrap = true,
    })

    Tabs.Key:AddKeyBox(function(ReceivedKey)
        local Success = ReceivedKey == "Banana"

        Library:Notify(
            "Received key: "
                .. tostring(ReceivedKey)
                .. " | Success: "
                .. tostring(Success),
            4
        )
    end)
end

do
    Library:AddDraggableLabel({
        Text = "CreU Draggable Label",
        Position = UDim2.fromOffset(12, 12),
    })

    local FPS = 0
    local FrameCount = 0
    local LastFPSUpdate = os.clock()

    local FPSConnection = RunService.RenderStepped:Connect(function()
        FrameCount += 1

        local Now = os.clock()
        local Delta = Now - LastFPSUpdate

        if Delta >= 1 then
            FPS = math.floor((FrameCount / Delta) + 0.5)
            FrameCount = 0
            LastFPSUpdate = Now
        end
    end)

    local Watermark = Library:AddWatermark({
        {
            Text = "Watermark",
            Accent = true,
        },

        {
            Icon = 95816097006870,
            Text = "CreU Showcase",
            Accent = true,
        },

        {
            Icon = "user",
            Text = function()
                return LocalPlayer.Name
            end,
        },

        {
            Icon = "activity",
            Text = function()
                return string.format("%d FPS", FPS)
            end,
        },

        {
            Icon = "wifi",
            Text = function()
                local Ping = 0

                pcall(function()
                    Ping = math.floor(
                        Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
                            + 0.5
                    )
                end)

                return string.format("%d ms", Ping)
            end,
        },

        {
            Icon = "clock",
            Text = function()
                return os.date("%H:%M:%S")
            end,
        },

        {
            Text = "--enjoy!",
            Accent = true,
        },
    })

    if Watermark then
        Watermark.RefreshRate = 1
    end

    Library.OnUnload(function()
        if FPSConnection then
            FPSConnection:Disconnect()
            FPSConnection = nil
        end
    end)
end

do
    local Menu = Tabs.Settings:AddLeftGroupbox(
        "Menu",
        "wrench"
    )

    Menu:AddToggle("CustomCursor", {
        Text = "Custom Cursor",
        Default = Library.ShowCustomCursor == true,

        Callback = function(Value)
            Library.ShowCustomCursor = Value
        end,
    })

    Menu:AddToggle("Watermark", {
        Text = "Watermark",
        Default = Library.WatermarkEnabled ~= false,

        Callback = function(Value)
            Library.WatermarkEnabled = Value

            if Library.SetWatermarkVisibility then
                Library:SetWatermarkVisibility(Value)
            elseif Library.SetWatermarkVisible then
                Library:SetWatermarkVisible(Value)
            end
        end,
    })

    Menu:AddToggle("ShowKeybinds", {
        Text = "Show Keybinds",
        Default = Library.ShowKeybinds ~= false,

        Callback = function(Value)
            Library:SetShowKeybinds(Value)
        end,
    })

    Menu:AddToggle("AlwaysOnTop", {
        Text = "Always On Top",
        Default = Window.AlwaysOnTop,

        Callback = function(Value)
            Window:SetAlwaysOnTop(Value)
        end,
    })

    Menu:AddToggle("UseBlur", {
        Text = "UI Blur",
        Default = Library.UseBlur == true,

        Callback = function(Value)
            Library.UseBlur = Value

            if Library.UpdateBlur then
                Library:UpdateBlur()
            end
        end,
    })

    Menu:AddSlider("BlurSize", {
        Text = "Blur Size",
        Default = Library.BlurSize or 15,
        Min = 1,
        Max = 40,
        Rounding = 0,

        Callback = function(Value)
            Library.BlurSize = Value

            if Library.UpdateBlur then
                Library:UpdateBlur()
            end
        end,
    })

    Menu:AddDropdown("NotificationSide", {
        Text = "Notification Side",

        Values = {
            "Left",
            "Right",
        },

        Default = "Right",

        Callback = function(Value)
            Library:SetNotifySide(Value)
        end,
    })

    Menu:AddLabel("Menu Bind"):AddKeyPicker(
        "MenuKeybind",
        {
            Default = "RightShift",
            NoUI = true,
            Text = "Menu Keybind",
        }
    )

    Menu:AddButton({
        Text = "Test Notification",

        Func = function()
            Library:Notify(
                "CreU notification test",
                3
            )
        end,
    })

    Menu:AddButton({
        Text = "Unload",

        Func = function()
            Library:Unload()
        end,
    })

    Library.ToggleKeybind = Options.MenuKeybind

    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("CreU")
    ThemeManager:ApplyToTab(Tabs.Settings)

    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()

    SaveManager:SetIgnoreIndexes({
        "MenuKeybind",
    })

    SaveManager:SetFolder("CreU/specific-game")
    SaveManager:SetSubFolder("specific-place")

    SaveManager:BuildConfigSection(
        Tabs.Settings
    )

    SaveManager:LoadAutoloadConfig()
end

if Toggles.DependencyMaster then
    Toggles.DependencyMaster:OnChanged(function(Value)
        Log("DependencyMaster:", Value)
    end)
end

if Options.BasicDropdown then
    Options.BasicDropdown:OnChanged(function(Value)
        Log("BasicDropdown:", Value)
    end)
end

if Options.MultiDropdown then
    Options.MultiDropdown:OnChanged(function(Value)
        Log("MultiDropdown:", Value)
    end)
end

if Options.PriorityDropdown then
    Options.PriorityDropdown:OnChanged(function(Value)
        Log("PriorityDropdown:", Value)
    end)
end

if Options.DemoColorAlpha then
    Options.DemoColorAlpha:OnChanged(function(Value)
        Log("DemoColorAlpha:", Value)
    end)
end

Library:Notify(
    "CreU Full Example loaded successfully",
    3
)

Library:OnUnload(function()
    Log("CreU Example unloaded")
end)
