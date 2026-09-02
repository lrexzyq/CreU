--enjoy!
local Repo = "https://raw.githubusercontent.com/lrexzyq/CreU/main/"
local Library = loadstring(game:HttpGet(Repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(Repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(Repo .. "addons/SaveManager.lua"))()

local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

local Options = Library.Options
local Toggles = Library.Toggles

local function Log(...)
    print("[MONLEO Example]", ...)
end

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "MONLEO Showcase",
    Icon = 95816097006870,
    ShowCustomCursor = true,
    NotifySide = "Right",
    Minimizable = true,
    MinimizeKeybind = Enum.KeyCode.RightBracket,
    Center = true,
    Size = UDim2.fromOffset(700, 600),
    Footer = {
        "MONLEO | ",
        { Text = "Full Example", Copyable = true },
        " | UserId: ",
        { Text = tostring(LocalPlayer.UserId), Copyable = true },
    },
    CopyableFooter = true,
})

Window:SetAlwaysOnTop(true)

local Tabs = {
    Home = Window:AddTab({ Name = "Home", Icon = "user", Description = "Overview and common controls" }),
    Elements = Window:AddTab({ Name = "Elements", Icon = "layout-grid", Description = "Full element showcase" }),
    Advanced = Window:AddTab({ Name = "Advanced", Icon = "sliders-horizontal", Description = "Advanced dropdown/keybind tests" }),
    Single = Window:AddTab({ Name = "Single Column", Icon = "square", Description = "Single-column layout", SingleColumn = true }),
    Key = Window:AddKeyTab("Key System"),
    Settings = Window:AddTab({ Name = "Settings", Icon = "settings", Description = "Theme and configuration managers" }),
}

--// HOME

do
    Tabs.Home:AddPlayerInfo("HomeBanner", {
        Player = LocalPlayer,
        Title = "Welcome to <b>MONLEO</b>",
        Description = {
            "Linoria-compatible UI core",
            "Normal and searchable dropdowns",
            "Mobile-friendly search focus",
            "Themes, configs, keybinds and watermark",
        },
        Height = 95,
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
        Default = "MONLEO",
        Placeholder = "Type something...",
        ClearTextOnFocus = false,
        Finished = false,
    })

    General:AddButton({
        Text = "Show Notification",
        Tooltip = "Tests Library:Notify",
        Func = function()
            local value = Options.DemoText and Options.DemoText.Value or "MONLEO"
            Library:Notify("Hello from MONLEO: " .. tostring(value), 3)
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
        Values = { "Box", "Name", "Distance", "Health", "Tracer" },
        Default = { "Box", "Name" },
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

--// BASIC ELEMENTS

do
    local Buttons = Tabs.Elements:AddLeftGroupbox("Buttons", "mouse-pointer-click")
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
        Func = function() end,
    })

    local TogglesBox = Tabs.Elements:AddLeftGroupbox("Toggles", "toggle-left")
    TogglesBox:AddToggle("BasicToggle", { Text = "Basic Toggle", Default = true })
    TogglesBox:AddCheckbox("BasicCheckbox", { Text = "Checkbox", Default = false })
    TogglesBox:AddToggle("RiskyToggle", { Text = "Risky Toggle", Risky = true, Default = false })

    local Labels = Tabs.Elements:AddLeftGroupbox("Labels", "text")
    Labels:AddLabel("Normal label")
    Labels:AddLabel("Wrapped label with a longer message to test layout and resizing.", true)
    Labels:AddDivider()
    Labels:AddParagraph("Paragraph-style content with wrapping.", true)

    local Sliders = Tabs.Elements:AddLeftGroupbox("Sliders", "sliders-horizontal")
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

    local Inputs = Tabs.Elements:AddLeftGroupbox("Inputs", "keyboard")
    Inputs:AddInput("TextInput", {
        Text = "Textbox",
        Default = "Type here",
        Placeholder = "Placeholder",
        ClearTextOnFocus = true,
        Finished = false,
        Numeric = false,
    })
    Inputs:AddInput("NumericInput", {
        Text = "Numeric Input",
        Default = "123",
        Placeholder = "Numbers only",
        Numeric = true,
        Finished = false,
    })
end

--// ADVANCED / DROPDOWNS

do
    local Dropdowns = Tabs.Advanced:AddLeftGroupbox("Dropdowns", "chevron-down")

    Dropdowns:AddDropdown("BasicDropdown", {
        Text = "Normal Dropdown",
        Values = { "Alpha", "Bravo", "Charlie", "Delta" },
        Default = 1,
    })

    Dropdowns:AddDropdown("SearchableDropdown", {
        Text = "Searchable Dropdown",
        Values = {
            "Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf",
            "Hotel", "India", "Juliett", "Kilo", "Lima", "Mike", "November", "Oscar",
        },
        Default = 1,
        Searchable = true,
        MaxVisibleItems = 8,
    })

    Dropdowns:AddDropdown("MultiDropdown", {
        Text = "Multi Select",
        Values = { "Box", "Name", "Distance", "Health", "Tracer" },
        Default = { "Box", "Name" },
        Multi = true,
        Searchable = true,
        SelectAllButtons = true,
    })

    Dropdowns:AddDropdown("DictionaryDropdown", {
        Text = "Dictionary Values",
        Values = {
            item01 = "Excalibur",
            item05 = "Aegis Shield",
            item06 = "Wooden Club",
        },
        Default = "item01",
        DisabledValues = { "item05" },
    })

    local Materials = {}
    for _, Material in ipairs(Enum.Material:GetEnumItems()) do
        Materials[#Materials + 1] = Material.Name
    end

    Dropdowns:AddDropdown("LongDropdown", {
        Text = "Long List",
        Values = Materials,
        Default = 1,
        Multi = true,
        Searchable = true,
        MaxVisibleItems = 10,
    })

    local Priority = Tabs.Advanced:AddRightGroupbox("Priority / Special", "list-ordered")
    Priority:AddPriorityDropdown("PriorityDropdown", {
        Text = "Priority Dropdown",
        Values = { "Critical", "High", "Medium", "Low" },
        Default = { "Critical", "High" },
        Searchable = true,
    })

    Priority:AddDropdown("PlayerDropdown", {
        Text = "Players",
        SpecialType = "Player",
        AllowNull = true,
    })

    Priority:AddDropdown("TeamDropdown", {
        Text = "Teams",
        SpecialType = "Team",
        AllowNull = true,
    })

    Priority:AddDropdown("DisabledDropdown", {
        Text = "Disabled Dropdown",
        Values = { "One", "Two", "Three" },
        Default = 1,
        Disabled = true,
        DisabledTooltip = "Disabled demo",
    })

    local Pickers = Tabs.Advanced:AddRightGroupbox("Pickers", "palette")
    Pickers:AddLabel("Color Picker"):AddColorPicker("DemoColor", {
        Default = Color3.fromRGB(0, 255, 0),
        Title = "Demo Color",
        Transparency = 0,
    })
    Pickers:AddLabel("Toggle Keybind"):AddKeyPicker("DemoKey", {
        Default = "F7",
        Mode = "Toggle",
        Text = "Demo Keybind",
    })
    Pickers:AddLabel("Hold Keybind"):AddKeyPicker("HoldKey", {
        Default = "E",
        Mode = "Hold",
        Text = "Hold Keybind",
    })
    Pickers:AddLabel("Press Callback"):AddKeyPicker("PressKey", {
        Default = "X",
        Mode = "Toggle",
        Text = "Press Callback",
        Callback = function(Value)
            Log("Press key callback:", Value)
        end,
    })

    local Tabbox = Tabs.Advanced:AddRightTabbox("Tabbox")
    local TabOne = Tabbox:AddTab("Tab 1")
    TabOne:AddToggle("TabboxToggle", { Text = "Tab 1 Toggle", Default = false })
    local TabTwo = Tabbox:AddTab("Tab 2")
    TabTwo:AddSlider("TabboxSlider", { Text = "Tab 2 Slider", Default = 5, Min = 0, Max = 10, Rounding = 0 })
end

--// SINGLE COLUMN

do
    local Farm = Tabs.Single:AddGroupbox({ Name = "Single Column Demo", IconName = "layout-dashboard" })
    Farm:AddToggle("SingleToggle", { Text = "Single Column Toggle", Default = false })
    Farm:AddDropdown("SingleMode", {
        Text = "Single Column Mode",
        Values = { "Nearest", "Strongest", "Fastest" },
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
    Farm:AddButton({ Text = "Single Column Button", Func = function() Log("Single column button") end })
    Farm:AddLabel("This tab uses the library's single-column layout.", true)
end

--// KEY SYSTEM

do
    Tabs.Key:AddLabel({
        Text = "Enter the key below. The demo accepts: Banana",
        DoesWrap = true,
    })
    Tabs.Key:AddKeyBox(function(ReceivedKey)
        local success = ReceivedKey == "Banana"
        Library:Notify("Received key: " .. tostring(ReceivedKey) .. " | Success: " .. tostring(success), 4)
    end)
end

--// WATERMARK / DRAGGABLE LABEL

do
    Library:AddDraggableLabel({
        Text = "MONLEO Draggable Label",
        Position = UDim2.fromOffset(12, 12),
    })

    local Watermark = Library:AddWatermark({
        { Player = LocalPlayer },
        { Icon = "flame", Text = "MONLEO", Accent = true },
        { Icon = "cpu", Text = function()
            if type(identifyexecutor) == "function" then
                local Ok, Result = pcall(identifyexecutor)
                if Ok and Result then
                    return tostring(Result)
                end
            end
            return "Unknown"
        end },
        { Icon = "wifi", Text = function()
            local Ping = 0
            pcall(function()
                Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
            end)
            return string.format("%d ms", Ping)
        end },
        { Icon = "clock", Text = function()
            return os.date("%H:%M:%S")
        end },
    })
    if Watermark then
        Watermark.RefreshRate = 1
    end
end

--// SETTINGS + THEME + SAVE MANAGER

do
    local Menu = Tabs.Settings:AddLeftGroupbox("Menu", "wrench")

    Menu:AddToggle("CustomCursor", {
        Text = "Custom Cursor",
        Default = Library.ShowCustomCursor == true,
        Callback = function(Value)
            Library.ShowCustomCursor = Value
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

    Menu:AddDropdown("NotificationSide", {
        Text = "Notification Side",
        Values = { "Left", "Right" },
        Default = "Right",
        Callback = function(Value)
            Library:SetNotifySide(Value)
        end,
    })

    Menu:AddDropdown("DPIScale", {
        Text = "DPI Scale",
        Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
        Default = "100%",
        Callback = function(Value)
            local NumericValue = tonumber(tostring(Value):gsub("%%", ""))
            if NumericValue then
                Library:SetDPIScale(NumericValue)
            end
        end,
    })

    Menu:AddLabel("Menu Bind"):AddKeyPicker("MenuKeybind", {
        Default = "RightShift",
        NoUI = true,
        Text = "Menu Keybind",
    })

    Menu:AddButton({
        Text = "Test Notification",
        Func = function()
            Library:Notify("MONLEO notification test", 3)
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
    ThemeManager:SetFolder("MONLEO")
    ThemeManager:ApplyToTab(Tabs.Settings)

    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    SaveManager:SetFolder("MONLEO/specific-game")
    SaveManager:SetSubFolder("specific-place")
    SaveManager:BuildConfigSection(Tabs.Settings)

    SaveManager:LoadAutoloadConfig()
end

--// Startup message
Library:Notify("MONLEO Full Example loaded successfully", 3)

Library:OnUnload(function()
    Log("MONLEO Example unloaded")
end)
