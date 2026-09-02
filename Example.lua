--// Bootstrap
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
    print("[CreU Example]", ...)
end

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "CreU Showcase",
    Icon = 95816097006870,
    ShowCustomCursor = true,
    NotifySide = "Right",
    Footer = {
        "CreU | ",
        { Text = "Example", Copyable = true },
        " | ",
        { Text = "UserId", Copyable = true, CopyText = tostring(LocalPlayer.UserId) },
    },
    CopyableFooter = true,
    FuzzySearch = true,
    SearchValues = true,
    SearchKeybind = Enum.KeyCode.F,
    Minimizable = true,
    MinimizeKeybind = Enum.KeyCode.RightBracket,
    CornerRadius = 6,
})
Window:SetAlwaysOnTop(true)

local Tabs = {
    Home = Window:AddTab({ Name = "Home", Icon = "user", Description = "Overview & main features" }),
    Elements = Window:AddTab({ Name = "Elements", Icon = "layout-grid", Description = "Every element type" }),
    Single = Window:AddTab({ Name = "Single Column", Icon = "square", Description = "One centered column", SingleColumn = true }),
    Key = Window:AddKeyTab("Key System"),
    Settings = Window:AddTab({ Name = "UI Settings", Icon = "settings", Description = "Configure the menu" }),
}

do
    Tabs.Home:AddPlayerInfo("HomeBanner", {
        Player = LocalPlayer,
        Title = "Welcome to <b>CreU</b>",
        Description = {
            "Linoria-compatible UI core",
            "Searchable, multi and long dropdowns",
            "Watermark, keybinds, nested layouts and config managers",
        },
        Height = 84,
    })

    Tabs.Home:AddRightGroupbox("Profile", "user"):AddPlayerInfo("HomeProfile", {
        Player = LocalPlayer,
        ThumbnailType = "Bust",
        Height = 160,
    })

    local Combat = Tabs.Home:AddLeftGroupbox("Combat", "swords")
    Combat:AddToggle("SilentAim", {
        Text = "Silent Aim", Tooltip = "Demo toggle", Default = false,
    }):AddKeyPicker("SilentAimKey", {
        Default = "MB2", Mode = "Hold", Text = "Silent Aim", SyncToggleState = false,
    })
    Combat:AddSlider("SilentAimFov", {
        Text = "FOV", Default = 90, Min = 0, Max = 360, Rounding = 0, Suffix = "°",
    })
    Combat:AddDropdown("SilentAimPart", {
        Text = "Hit Part", Values = { "Head", "HumanoidRootPart", "Torso" }, Default = 1,
    })

    local Visuals = Tabs.Home:AddRightGroupbox("Visuals", "eye")
    Visuals:AddToggle("EspEnabled", { Text = "Player ESP", Default = true })
        :AddColorPicker("EspColor", { Default = Color3.fromRGB(0, 255, 140), Title = "ESP Color" })
    Visuals:AddSlider("EspDistance", {
        Text = "Max Distance", Default = 500, Min = 50, Max = 2000, Rounding = 0, Suffix = " studs",
    })
    Visuals:AddDropdown("EspParts", {
        Text = "ESP Features", Values = { "Box", "Name", "Distance", "Health", "Tracer" },
        Default = 1, Multi = true, Searchable = true, SelectAllButtons = true,
    })

    Toggles.SilentAim:OnChanged(function()
        Log("SilentAim:", Toggles.SilentAim.Value)
    end)
    Toggles.EspEnabled:OnChanged(function()
        Log("EspEnabled:", Toggles.EspEnabled.Value)
    end)
    Options.EspColor:OnChanged(function()
        Log("EspColor:", Options.EspColor.Value)
    end)
end

do
    local Buttons = Tabs.Elements:AddLeftGroupbox("Buttons", "mouse-pointer-click")
    Buttons:AddButton({ Text = "Button", Tooltip = "Normal button", Func = function() Log("Button clicked") end })
        :AddButton({ Text = "Sub button", DoubleClick = true, Func = function() Log("Sub button clicked") end })
    Buttons:AddButton({ Text = "Disabled button", Disabled = true, DisabledTooltip = "Disabled", Func = function() end })

    local ToggleBox = Tabs.Elements:AddLeftGroupbox("Toggles", "toggle-left")
    ToggleBox:AddToggle("DemoToggle", { Text = "A toggle", Tooltip = "Hover tooltip", Default = true })
    ToggleBox:AddCheckbox("DemoCheckbox", { Text = "A checkbox", Default = false })
    ToggleBox:AddToggle("RiskyToggle", { Text = "A risky toggle", Risky = true, Default = false })

    local Labels = Tabs.Elements:AddLeftGroupbox("Labels", "text")
    Labels:AddLabel("A plain label")
    Labels:AddLabel("A wrapped label with multiple lines.", true)
    Labels:AddDivider()

    local Sliders = Tabs.Elements:AddLeftGroupbox("Sliders", "sliders-horizontal")
    Sliders:AddSlider("DemoSlider", { Text = "Basic slider", Default = 2, Min = 0, Max = 5, Rounding = 1 })
    Sliders:AddSlider("FormattedSlider", {
        Text = "Formatted slider", Default = 3, Min = 0, Max = 5, Rounding = 0,
        FormatDisplayValue = function(Slider, Value)
            if Value == Slider.Max then return "Everything" end
            if Value == Slider.Min then return "Nothing" end
        end,
    })

    local Inputs = Tabs.Elements:AddLeftGroupbox("Inputs", "keyboard")
    Inputs:AddInput("DemoInput", {
        Text = "Textbox", Default = "type here", Placeholder = "Placeholder text",
        ClearTextOnFocus = true, Finished = false, Numeric = false,
    })

    local Pickers = Tabs.Elements:AddLeftGroupbox("Pickers", "palette")
    Pickers:AddLabel("Colour"):AddColorPicker("DemoColor", {
        Default = Color3.fromRGB(0, 255, 0), Title = "Demo colour", Transparency = 0,
    })
    Pickers:AddLabel("Toggle keybind"):AddKeyPicker("DemoKey", {
        Default = "MB2", Mode = "Toggle", Text = "Demo keybind",
    })
    Pickers:AddLabel("Press keybind"):AddKeyPicker("DemoPressKey", {
        Default = "X", Mode = "Toggle", Text = "Press keybind", Callback = function() Log("Pressed") end,
    })

    local Dropdowns = Tabs.Elements:AddRightGroupbox("Advanced Dropdowns", "chevron-down")
    Dropdowns:AddDropdown("BasicDropdown", {
        Text = "Basic", Values = { "Alpha", "Bravo", "Charlie", "Delta" }, Default = 1,
        Expandable = true, ExpandColumns = 2,
    })
    Dropdowns:AddDropdown("SearchableDropdown", {
        Text = "Searchable",
        Values = { "Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliett", "Kilo", "Lima", "Mike", "November", "Oscar" },
        Default = 1, Searchable = true, MaxVisibleItems = 8,
    })
    Dropdowns:AddDropdown("MultiDropdown", {
        Text = "Multi select", Values = { "Box", "Name", "Distance", "Health", "Tracer" },
        Default = { "Box", "Name" }, Multi = true, Searchable = true, SelectAllButtons = true,
    })
    Dropdowns:AddDropdown("DictionaryDropdown", {
        Text = "Dictionary", Values = { item01 = "Excalibur", item05 = "Aegis Shield", item06 = "Wooden Club" },
        Default = "item01", Multi = true, DisabledValues = { "item05" },
    })
    local Materials = {}
    for _, Material in ipairs(Enum.Material:GetEnumItems()) do
        Materials[#Materials + 1] = Material.Name
    end
    Dropdowns:AddDropdown("LongDropdown", {
        Text = "Long list", Values = Materials, Default = 1, Multi = true,
        Searchable = true, MaxVisibleDropdownItems = 10, ItemHeight = 20,
    })
    Dropdowns:AddDropdown("PlayerDropdown", { Text = "Players", SpecialType = "Player" })
    Dropdowns:AddDropdown("TeamDropdown", { Text = "Teams", SpecialType = "Team" })
    Dropdowns:AddDropdown("DisabledDropdown", {
        Text = "Disabled", Values = { "One", "Two", "Three" }, Default = 1,
        Disabled = true, DisabledTooltip = "Disabled demo",
    })
    Dropdowns:AddPriorityDropdown("PriorityDropdown", {
        Text = "Priority order", Values = { "Critical", "High", "Medium", "Low" }, Default = { "Critical", "High" }, Searchable = true,
    })

    local TabBox = Tabs.Elements:AddRightTabbox("Tabbox")
    local TabOne = TabBox:AddTab("Tab 1")
    TabOne:AddToggle("TabboxToggle1", { Text = "Tab 1 toggle" })
    local TabTwo = TabBox:AddTab("Tab 2")
    TabTwo:AddSlider("TabboxSlider", { Text = "Tab 2 slider", Default = 5, Min = 0, Max = 10, Rounding = 0 })
end

do
    local Farm = Tabs.Single:AddGroupbox({ Name = "Auto Farm", IconName = "sprout" })
    Farm:AddToggle("SingleFarmEnabled", { Text = "Enable Auto Farm", Default = false })
    Farm:AddDropdown("SingleFarmMode", { Text = "Mode", Values = { "Nearest", "Strongest", "Fastest" }, Default = 1 })
    Farm:AddSlider("SingleFarmDelay", { Text = "Loop Delay", Default = 250, Min = 0, Max = 1000, Rounding = 0, Suffix = "ms" })

    local Notes = Tabs.Single:AddGroupbox({ Name = "Notes", IconName = "info" })
    Notes:AddLabel("This tab uses a single centered column.", true)
    Notes:AddButton({ Text = "Full-width button", Func = function() Log("Single-column button") end })
end

do
    Tabs.Key:AddLabel({ Text = "Enter key to test the key gate.", DoesWrap = true })
    Tabs.Key:AddKeyBox(function(ReceivedKey)
        Library:Notify({
            Title = "Key System",
            Description = "Received: " .. tostring(ReceivedKey) .. "\nSuccess: " .. tostring(ReceivedKey == "Banana"),
            Time = 4,
        })
    end)
end

do
    Library:AddDraggableLabel({ Text = "CreU Draggable Label", Position = UDim2.fromOffset(12, 12) })
    local Watermark = Library:AddWatermark({
        { Player = LocalPlayer },
        { Icon = "flame", Text = "CreU", Accent = true },
        { Icon = "cpu", Text = function() return (identifyexecutor and identifyexecutor()) or "Unknown" end },
        { Icon = "wifi", Text = function()
            local Ping = 0
            pcall(function()
                Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
            end)
            return string.format("%d ms", Ping)
        end },
        { Icon = "clock", Text = function() return os.date("%H:%M") end },
    })
    if Watermark then
        Watermark.RefreshRate = 1
    end
end

do
    local Menu = Tabs.Settings:AddLeftGroupbox("Menu", "wrench")
    Menu:AddToggle("ShowCustomCursor", {
        Text = "Custom Cursor", Default = Library.ShowCustomCursor,
        Callback = function(Value) Library.ShowCustomCursor = Value end,
    })
    Menu:AddToggle("ShowKeybinds", {
        Text = "Show Keybinds", Default = Library.ShowKeybinds ~= false,
        Callback = function(Value) Library:SetShowKeybinds(Value) end,
    })
    Menu:AddToggle("AlwaysOnTop", {
        Text = "Always On Top", Default = Window.AlwaysOnTop,
        Callback = function(Value) Window:SetAlwaysOnTop(Value) end,
    })
    Menu:AddDropdown("NotificationSide", {
        Text = "Notification Side", Values = { "Left", "Right" }, Default = "Right",
        Callback = function(Value) Library:SetNotifySide(Value) end,
    })
    Menu:AddDropdown("DPIScale", {
        Text = "DPI Scale", Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" }, Default = "100%",
        Callback = function(Value)
            local NumericValue = tonumber((Value:gsub("%%", "")))
            if NumericValue then
                Library:SetDPIScale(NumericValue)
            end
        end,
    })
    Menu:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Menu:AddButton({ Text = "Unload", Func = function() Library:Unload() end })

    Library.ToggleKeybind = Options.MenuKeybind
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    ThemeManager:SetFolder("CreU")
    SaveManager:SetFolder("CreU/specific-game")
    SaveManager:SetSubFolder("specific-place")
    SaveManager:BuildConfigSection(Tabs.Settings)

    ThemeManager:ApplyToTab(Tabs.Settings)
    SaveManager:LoadAutoloadConfig()
end

Library:OnUnload(function()
    Log("Unloaded.")
end)
