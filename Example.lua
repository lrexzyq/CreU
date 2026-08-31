--[[
    CreU / Linoria-style UI — Complete Example / Feature Showcase

    Layout:
        1. Bootstrap ......... load Library + ThemeManager + SaveManager
        2. Window ............ create the window
        3. Home tab .......... realistic controls
        4. Elements tab ...... component/API catalogue
        5. Single Column ...... long-form groupbox layout
        6. Sub Tabs .......... tabbox demonstration
        7. Key System ........ keybind + key state
        8. Overlays .......... watermark + draggable widgets
        9. UI Settings ....... menu/theme/config controls

    Notes:
        - This example targets the current CreU Library API, not an external UI library.
        - Advanced dropdowns support long lists, search, multi-select and disabled values.
        - SaveManager uses batched config loading to avoid startup callback storms.
]]

--// 1. Bootstrap \\

local Repo = "https://raw.githubusercontent.com/lrexzyq/CreU/main/"
local Library = loadstring(game:HttpGet(Repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(Repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(Repo .. "addons/SaveManager.lua"))()

local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local function Log(...)
    print("[CreU Example]", ...)
end

--// 2. Window \\

local Window = Library:CreateWindow({
    Title = "CreU UI Showcase",
    Size = UDim2.fromOffset(680, 650),
    Center = true,
    AutoShow = true,
    TabPadding = 6,
})

-- The current library accepts string tabs; object-style metadata is also accepted.
local Tabs = {
    Home = Window:AddTab({ Name = "Home", Description = "Overview and realistic controls" }),
    Elements = Window:AddTab({ Name = "Elements", Description = "Component catalogue" }),
    Single = Window:AddTab({ Name = "Single Column", SingleColumn = true, Description = "Focused long-form layout" }),
    Advanced = Window:AddTab({ Name = "Advanced", Description = "Dropdowns, tabboxes and utilities" }),
    Settings = Window:AddTab({ Name = "UI Settings", Description = "Menu, theme and config" }),
}

--// 3. Home tab \\

do
    local Combat = Tabs.Home:AddLeftGroupbox("Combat")

    Combat:AddToggle("SilentAim", {
        Text = "Silent Aim",
        Tooltip = "Example toggle with a synchronized key picker",
        Default = false,
    }):AddKeyPicker("SilentAimKey", {
        Default = "MB2",
        Mode = "Hold",
        Text = "Silent Aim",
        SyncToggleState = false,
    })

    Combat:AddSlider("SilentAimFov", {
        Text = "FOV",
        Default = 90,
        Min = 0,
        Max = 360,
        Rounding = 0,
        Suffix = "°",
        Prefix = "",
    })

    Combat:AddDropdown("SilentAimPart", {
        Text = "Hit Part",
        Values = { "Head", "HumanoidRootPart", "Torso" },
        Default = 1,
    })

    local Visuals = Tabs.Home:AddRightGroupbox("Visuals")

    Visuals:AddToggle("EspEnabled", {
        Text = "Player ESP",
        Default = true,
    }):AddColorPicker("EspColor", {
        Default = Color3.fromRGB(0, 255, 140),
        Title = "ESP Color",
    })

    Visuals:AddSlider("EspDistance", {
        Text = "Max Distance",
        Default = 500,
        Min = 50,
        Max = 2000,
        Rounding = 0,
        Suffix = " studs",
    })

    Visuals:AddDropdown("EspFeatures", {
        Text = "ESP Features",
        Values = { "Box", "Name", "Distance", "Health", "Tracer" },
        Default = { "Box", "Name" },
        Multi = true,
        Searchable = false,
        SelectAllButtons = true,
    })

    Toggles.SilentAim:OnChanged(function(value)
        Log("SilentAim:", value)
    end)

    Options.EspColor:OnChanged(function(value)
        Log("ESP color:", value)
    end)
end

--// 4. Elements tab \\
-- One family per groupbox so this tab doubles as an API reference.
do
    local Buttons = Tabs.Elements:AddLeftGroupbox("Buttons")
    Buttons:AddButton({
        Text = "Normal Button",
        Tooltip = "Runs a callback",
        Func = function()
            Log("Normal button clicked")
        end,
    }):AddButton({
        Text = "Sub Button",
        Func = function()
            Log("Sub button clicked")
        end,
    })

    Buttons:AddButton({
        Text = "Disabled Button",
        Disabled = true,
        DisabledTooltip = "This button is disabled",
        Func = function()
            Log("Should never run")
        end,
    })

    local TogglesBox = Tabs.Elements:AddLeftGroupbox("Toggles")
    TogglesBox:AddToggle("DemoToggle", {
        Text = "A Toggle",
        Tooltip = "Normal toggle",
        Default = true,
    })
    TogglesBox:AddCheckbox("DemoCheckbox", {
        Text = "A Checkbox",
        Default = false,
    })
    TogglesBox:AddToggle("RiskyToggle", {
        Text = "Risky Toggle",
        Risky = true,
        Default = false,
    })

    local Labels = Tabs.Elements:AddLeftGroupbox("Labels & Input")
    Labels:AddLabel("Plain label")
    Labels:AddParagraph("Wrapped paragraph text can be used for descriptions, documentation and notes.", true)
    Labels:AddDivider()
    Labels:AddInput("DemoInput", {
        Text = "Textbox",
        Default = "type here",
        Placeholder = "placeholder",
        Finished = false,
    })

    local Sliders = Tabs.Elements:AddRightGroupbox("Sliders")
    Sliders:AddSlider("DemoSlider", {
        Text = "Basic slider",
        Default = 2,
        Min = 0,
        Max = 5,
        Rounding = 1,
    })

    local AdvancedSlider = Sliders:AddSlider("AdvancedSlider", {
        Text = "Advanced slider",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Prefix = "~ ",
        Suffix = "%",
    })
    AdvancedSlider:SetPrefix("")
    AdvancedSlider:SetSuffix("%")
    AdvancedSlider:SetMin(0)
    AdvancedSlider:SetMax(100)

    local Pickers = Tabs.Elements:AddRightGroupbox("Pickers")
    Pickers:AddLabel("Color"):AddColorPicker("DemoColor", {
        Default = Color3.fromRGB(90, 180, 255),
        Title = "Demo Color",
        Transparency = 0,
    })
    Pickers:AddLabel("Keybind"):AddKeyPicker("DemoKey", {
        Default = "X",
        Mode = "Toggle",
        Text = "Demo Key",
    })
end

--// 5. Single Column tab \\
-- The current core does not switch the live column geometry at runtime, so use one side.
do
    local Farm = Tabs.Single:AddLeftGroupbox("Auto Farm")
    Farm:AddLabel("This page intentionally uses one side for long-form controls.", true)
    Farm:AddToggle("FarmEnabled", {
        Text = "Enable Auto Farm",
        Default = false,
    })
    Farm:AddDropdown("FarmMode", {
        Text = "Farm Mode",
        Values = { "Nearest", "Strongest", "Fastest", "Safest" },
        Default = 1,
    })
    Farm:AddSlider("FarmDelay", {
        Text = "Loop Delay",
        Default = 250,
        Min = 0,
        Max = 1000,
        Rounding = 0,
        Suffix = " ms",
    })
    Farm:AddInput("FarmTarget", {
        Text = "Target Filter",
        Placeholder = "optional",
    })
end

--// 6. Advanced tab \\
-- Tabbox gives nested tabs; advanced dropdowns are the main stress test.
do
    local Dropdowns = Tabs.Advanced:AddLeftGroupbox("Advanced Dropdowns")

    Dropdowns:AddDropdown("BasicDropdown", {
        Text = "Basic",
        Values = { "This", "is", "a", "dropdown" },
        Default = 1,
    })

    Dropdowns:AddDropdown("SearchableDropdown", {
        Text = "Searchable",
        Values = {
            "Alpha", "Bravo", "Charlie", "Delta", "Echo",
            "Foxtrot", "Golf", "Hotel", "India", "Juliett",
            "Kilo", "Lima", "Mike", "November", "Oscar",
        },
        Default = 1,
        Searchable = true,
        MaxVisibleItems = 8,
    })

    Dropdowns:AddDropdown("MultiDropdown", {
        Text = "Multi Select",
        Values = { "ESP", "Aimbot", "Crosshair", "Radar", "Tracers" },
        Default = { "ESP", "Aimbot" },
        Multi = true,
        Searchable = true,
        SelectAllButtons = true,
        MaxVisibleItems = 8,
    })

    Dropdowns:AddDropdown("LongDropdown", {
        Text = "Long List",
        Values = (function()
            local result = {}
            for _, material in ipairs(Enum.Material:GetEnumItems()) do
                result[#result + 1] = material.Name
            end
            return result
        end)(),
        Default = 1,
        Multi = true,
        Searchable = true,
        MaxVisibleItems = 10,
        ItemHeight = 20,
    })

    Dropdowns:AddDropdown("DisabledDropdown", {
        Text = "Disabled Values",
        Values = { "Available", "Locked", "Experimental", "Hidden" },
        Default = 1,
        DisabledValues = { "Locked", "Hidden" },
    })

    local Nested = Tabs.Advanced:AddRightTabbox("Nested Tabbox")
    local TabA = Nested:AddTab("Controls")
    TabA:AddToggle("NestedToggle", { Text = "Nested toggle", Default = true })
    TabA:AddSlider("NestedSlider", {
        Text = "Nested slider",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
    })

    local TabB = Nested:AddTab("Utilities")
    TabB:AddButton({
        Text = "Refresh long list",
        Func = function()
            Options.LongDropdown:SetValues(Options.LongDropdown.Values)
        end,
    })
    TabB:AddLabel("Tabboxes can keep compact groups of related controls.", true)

    -- Advanced API calls are safe to exercise directly.
    Options.MultiDropdown:Select("Radar", true)
    Options.MultiDropdown:Deselect("Aimbot", true)
    Options.MultiDropdown:SelectAll()
    Options.MultiDropdown:DeselectAll("cross")
    Options.SearchableDropdown:SetMaxVisibleItems(10)
    Options.SearchableDropdown:SetSearchable(true)
    Options.LongDropdown:SetItemHeight(20)
end

--// 7. Key System \\
-- A normal keybind is used here because this build does not require a separate key-gate tab.
do
    local KeyGroup = Tabs.Advanced:AddRightGroupbox("Key System")
    KeyGroup:AddLabel("Example key: Banana", true)
    KeyGroup:AddInput("KeyInput", {
        Text = "Enter Key",
        Placeholder = "Banana",
    })
    KeyGroup:AddButton({
        Text = "Check Key",
        Func = function()
            local received = tostring(Options.KeyInput.Value or "")
            local success = received == "Banana"
            Log("Key check:", received, success)
            Library:Notify("Key System: Received=" .. received .. " | Success=" .. tostring(success), 3)
        end,
    })
end

--// 8. Overlays \\

do
    Library:AddDraggableLabel({
        Text = "Crefy — draggable overlay",
        Position = UDim2.fromOffset(12, 36),
        Size = UDim2.fromOffset(220, 20),
    })

    Library:AddDraggableButton({
        Text = "Overlay Action",
        Position = UDim2.fromOffset(12, 62),
        Size = UDim2.fromOffset(140, 24),
        Func = function()
            Library:Notify("Overlay Action clicked", 2)
        end,
    })

    Library:AddWatermark({
        "Crefy | ",
        "UI Showcase | ",
        function()
            local ping = 0
            pcall(function()
                ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
            end)
            return tostring(ping) .. " ms"
        end,
        " | ",
        function()
            return os.date("%H:%M:%S")
        end,
    })
end

--// 9. UI Settings tab \\

do
    local Menu = Tabs.Settings:AddLeftGroupbox("Menu")

    Menu:AddToggle("KeybindMenuOpen", {
        Text = "Open Keybind Menu",
        Default = Library.KeybindFrame.Visible,
        Callback = function(value)
            Library.KeybindFrame.Visible = value
        end,
    })

    Menu:AddToggle("ShowCustomCursor", {
        Text = "Custom Cursor",
        Default = false,
        Callback = function(value)
            Library.ShowCustomCursor = value
        end,
    })

    Menu:AddDropdown("KeybindMode", {
        Text = "Keybind Filter",
        Values = { "All", "Active", "Toggled" },
        Default = "All",
        Callback = function(value)
            Library:SetKeybindMode(value)
        end,
    })

    Menu:AddSlider("FontSize", {
        Text = "Font Size",
        Default = Library.FontSize,
        Min = 10,
        Max = 22,
        Rounding = 0,
        Callback = function(value)
            Library:SetFontSize(value)
        end,
    })

    Menu:AddButton({
        Text = "Show Notification History",
        Func = function()
            local history = Library:NotifyHistory()
            Log("Notification history count:", #history)
            Library:Notify("History entries: " .. tostring(#history), 2)
        end,
    })

    Menu:AddButton({
        Text = "Unload UI",
        Func = function()
            Library:Unload()
        end,
    })

    -- Theme + config managers share exactly the same Library instance.
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)

    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "KeybindMode", "MenuKeybind" })

    ThemeManager:SetFolder("Crefy")
    SaveManager:SetFolder("Crefy")
    SaveManager:SetSubFolder("specific-game")

    ThemeManager:ApplyToTab(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    -- Safe autoload: loading is batched and callback storms are throttled.
    SaveManager:LoadAutoloadConfig()
end

Library:OnUnload(function()
    Log("Crefy showcase unloaded")
end)
