--[[
    Uelinoria — Full Example / Feature Showcase

    Includes:
      1. Bootstrap
      2. Window + tabs
      3. Home / player info / combat / visuals
      4. Full element catalogue
      5. Single-column layout
      6. Sub Tabs + nested Tabbox
      7. Key System
      8. Watermark + draggable widgets
      9. UI settings + ThemeManager + SaveManager

    Build the UI first, then wire non-trivial logic through Options/Toggles.
]]

--// 1. Bootstrap \\--

local Repo = "https://raw.githubusercontent.com/lrexzyq/CreU/main/"
local Library = loadstring(game:HttpGet(Repo .. "Library.lua"))()

-- The example expects the enhanced CreU Library API bundled with this package.
-- Fail clearly instead of producing a cryptic error inside CreateWindow when an
-- older Library.lua is still published on the repository.
assert(type(Library) == "table", "CreU: Library.lua did not return a Library table.")
assert(type(Library.SetWatermark) == "function", "CreU: remote Library.lua is outdated; upload the bundled Library.lua to lrexzyq/CreU/main.")
assert(type(Library.AddWatermark) == "function", "CreU: remote Library.lua is missing AddWatermark; upload the bundled Library.lua to lrexzyq/CreU/main.")
local ThemeManager = loadstring(game:HttpGet(Repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(Repo .. "addons/SaveManager.lua"))()

local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

local Options = Library.Options
local Toggles = Library.Toggles

local function Log(...)
    print("[Uelinoria Example]", ...)
end


--// 2. Window \\--

local Window = Library:CreateWindow({
    Title = "Uelinoria",
    Icon = 95816097006870,
    NotifySide = "Right",

    Footer = {
        "version: example |",
        { Text = "Uelinoria", Copyable = true },
        "|",
        { Text = "user id", Copyable = true, CopyText = tostring(LocalPlayer.UserId) },
    },
    CopyableFooter = true,

    Minimizable = true,
    MinimizeKeybind = Enum.KeyCode.RightBracket,
})

local Tabs = {
    Home = Window:AddTab({ Name = "Home", Description = "Overview & main features" }),
    Elements = Window:AddTab({ Name = "Elements", Description = "Every element type" }),
    Single = Window:AddTab({ Name = "Single Column", Description = "One centered column", SingleColumn = true }),
    SubTabs = Window:AddTab({ Name = "Sub Tabs", Description = "Tabs inside a tab" }),
    Key = Window:AddKeyTab("Key System"),
    Settings = Window:AddTab({ Name = "UI Settings", Description = "Theme, config and menu settings" }),
}

--// 3. Home tab \\--

do
    Tabs.Home:AddPlayerInfo("HomeBanner", {
        Title = "Welcome to the <b>Uelinoria</b> example",
        Description = {
            '<font color="#8f6bff">Home</font> — player card + realistic features',
            '<font color="#8f6bff">Elements</font> — every element family',
            '<font color="#8f6bff">Single Column</font> — full-width layout',
            '<font color="#8f6bff">Sub Tabs / Key / Settings</font> — advanced features',
        },
        ThumbnailType = "HeadShot",
        Height = 84,
    })

    Tabs.Home:AddRightGroupbox("Profile"):AddPlayerInfo("HomeProfile", {
        ThumbnailType = "Bust",
        Height = 190,
    })

    local Combat = Tabs.Home:AddLeftGroupbox("Combat")

    Combat:AddToggle("SilentAim", {
        Text = "Silent Aim",
        Tooltip = "Demo feature toggle",
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

    Visuals:AddDropdown("EspParts", {
        Text = "ESP Features",
        Values = { "Box", "Name", "Distance", "Health", "Tracer" },
        Default = 1,
        Multi = true,
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

--// 4. Elements tab \\--

do
    local Buttons = Tabs.Elements:AddLeftGroupbox("Buttons")

    Buttons:AddButton({
        Text = "Button",
        Tooltip = "A normal button",
        Func = function()
            Log("Button clicked")
            Library:Notify({ Title = "Button", Description = "Button clicked!", Time = 2 })
        end,
    }):AddButton({
        Text = "Sub button",
        Tooltip = "Requires a double click",
        DoubleClick = true,
        Func = function()
            Log("Sub button clicked")
        end,
    })

    Buttons:AddButton({
        Text = "Disabled button",
        Disabled = true,
        DisabledTooltip = "I am disabled!",
        Func = function()
            Log("unreachable")
        end,
    })

    local Toggle = Tabs.Elements:AddLeftGroupbox("Toggles & Checkboxes")

    Toggle:AddToggle("DemoToggle", {
        Text = "A toggle",
        Tooltip = "Hover tooltip",
        Default = true,
    })

    Toggle:AddCheckbox("DemoCheckbox", {
        Text = "A checkbox",
        Default = false,
    })

    Toggle:AddToggle("RiskyToggle", {
        Text = "A risky toggle",
        Risky = true,
        Default = false,
    })

    Toggles.DemoToggle:OnChanged(function()
        Log("DemoToggle:", Toggles.DemoToggle.Value)
    end)

    local Labels = Tabs.Elements:AddLeftGroupbox("Labels")
    Labels:AddLabel("A plain label")
    Labels:AddLabel("A label that wraps its own text across multiple lines.", true)
    Labels:AddDivider()
    Labels:AddLabel("LabelWithIdx", {
        Text = "A label with an index",
        DoesWrap = true,
    })

    local Sliders = Tabs.Elements:AddLeftGroupbox("Sliders")

    Sliders:AddSlider("DemoSlider", {
        Text = "A slider",
        Default = 2,
        Min = 0,
        Max = 5,
        Rounding = 1,
    })

    Sliders:AddSlider("FormattedSlider", {
        Text = "A formatted slider",
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
        end,
    })

    Options.DemoSlider:OnChanged(function()
        Log("DemoSlider:", Options.DemoSlider.Value)
    end)

    local Inputs = Tabs.Elements:AddLeftGroupbox("Inputs")

    Inputs:AddInput("DemoInput", {
        Text = "A textbox",
        Default = "type here",
        Placeholder = "Placeholder text",
        ClearTextOnFocus = true,
        Finished = false,
        Numeric = false,
    })

    Options.DemoInput:OnChanged(function()
        Log("DemoInput:", Options.DemoInput.Value)
    end)

    local Pickers = Tabs.Elements:AddLeftGroupbox("Pickers")

    Pickers:AddLabel("Colour"):AddColorPicker("DemoColor", {
        Default = Color3.fromRGB(0, 255, 0),
        Title = "A colour",
        Transparency = 0,
    })

    Options.DemoColor:OnChanged(function()
        Log("DemoColor:", Options.DemoColor.Value, "alpha", Options.DemoColor.Transparency)
    end)

    Pickers:AddLabel("Toggle keybind"):AddKeyPicker("DemoKey", {
        Default = "MB2",
        Mode = "Toggle",
        Text = "A toggle keybind",
    })

    Options.DemoKey:OnClick(function()
        Log("DemoKey toggled:", Options.DemoKey:GetState())
    end)

    local Pressed = 0
    Pickers:AddLabel("Press keybind"):AddKeyPicker("DemoPressKey", {
        Default = "X",
        Mode = "Press",
        Text = "A press keybind",
        Callback = function()
            Pressed += 1
            Log("DemoPressKey pressed x" .. Pressed)
        end,
    })

    local Dropdowns = Tabs.Elements:AddRightGroupbox("Dropdowns")

    Dropdowns:AddDropdown("BasicDropdown", {
        Text = "Basic",
        Values = { "This", "is", "a", "dropdown" },
        Default = 1,
        Expandable = true,
        ExpandColumns = 2,
    })

    Options.BasicDropdown:OnChanged(function()
        Log("BasicDropdown:", Options.BasicDropdown.Value)
    end)

    Dropdowns:AddDropdown("SearchableDropdown", {
        Text = "Searchable",
        Values = { "This", "is", "a", "searchable", "dropdown" },
        Default = 1,
        Searchable = true,
    })

    Dropdowns:AddDropdown("MultiDropdown", {
        Text = "Multi select",
        Values = { "This", "is", "a", "dropdown" },
        Default = 1,
        Multi = true,
        SelectAllButtons = true,
        DragSelect = true,
    })

    Options.MultiDropdown:SetValue({ This = true, is = true })

    Dropdowns:AddDropdown("DictionaryDropdown", {
        Text = "Dictionary",
        Values = {
            item01 = "Excalibur",
            item05 = "Aegis Shield",
            item06 = "Wooden Club",
        },
        Default = "item01",
        Multi = true,
        DisabledValues = { "item05" },
    })

    Dropdowns:AddDropdown("LongDropdown", {
        Text = "Long list",
        Values = (function()
            local Names = {}
            for _, Material in Enum.Material:GetEnumItems() do
                table.insert(Names, Material.Name)
            end
            return Names
        end)(),
        Default = 1,
        Multi = true,
        Searchable = true,
        MaxVisibleDropdownItems = 10,
        ExpandColumns = 3,
    })

    Dropdowns:AddDropdown("PlayerDropdown", {
        Text = "Players",
        SpecialType = "Player",
        ExcludeLocalPlayer = true,
    })

    Dropdowns:AddDropdown("TeamDropdown", {
        Text = "Teams",
        SpecialType = "Team",
    })

    Dropdowns:AddDropdown("DisabledDropdown", {
        Text = "Disabled",
        Values = { "This", "is", "a", "dropdown" },
        Default = 1,
        Disabled = true,
        DisabledTooltip = "I am disabled!",
    })

    local TabBox = Tabs.Elements:AddRightTabbox("Tabbox")

    local TabOne = TabBox:AddTab("Tab 1")
    TabOne:AddToggle("TabboxToggle1", { Text = "Tab 1 toggle" })

    local TabTwo = TabBox:AddTab("Tab 2")
    TabTwo:AddToggle("TabboxToggle2", { Text = "Tab 2 toggle" })
end

--// 5. Single Column tab \\--

do
    local Farm = Tabs.Single:AddGroupbox({
        Name = "Auto Farm",
        IconName = "sprout",
    })

    Farm:AddToggle("SingleFarmEnabled", {
        Text = "Enable Auto Farm",
        Default = false,
    })

    Farm:AddDropdown("SingleFarmMode", {
        Text = "Mode",
        Values = { "Nearest", "Strongest", "Fastest" },
        Default = 1,
    })

    Farm:AddSlider("SingleFarmDelay", {
        Text = "Loop Delay",
        Default = 250,
        Min = 0,
        Max = 1000,
        Rounding = 0,
        Suffix = "ms",
    })

    local Info = Tabs.Single:AddGroupbox({
        Name = "Notes",
        IconName = "info",
    })

    Info:AddLabel(
        "Both groupboxes span the full width because this tab is single column.",
        true
    )

    Info:AddButton({
        Text = "A full-width button",
        Func = function()
            Log("Single-column button clicked")
        end,
    })
end

--// 6. Sub Tabs tab \\--

do
    Tabs.SubTabs:SetSubTabAlignment("Center")

    local Overview = Tabs.SubTabs:AddSubTab({ Name = "Overview" })
    local Layout = Tabs.SubTabs:AddSubTab({ Name = "Layout" })
    local Nested = Tabs.SubTabs:AddSubTab({ Name = "Nested" })

    local About = Overview:AddLeftGroupbox("About Sub Tabs")
    About:AddLabel("Click the buttons above to switch sub tab.", true)
    About:AddLabel("Each sub tab keeps its own controls.", true)
    About:AddToggle("SubOverviewToggle", {
        Text = "A toggle lives here",
        Default = true,
    })

    local Actions = Overview:AddRightGroupbox("Actions")
    Actions:AddButton({
        Text = "Send a notification",
        Func = function()
            Library:Notify({
                Title = "Sub Tabs",
                Description = "Hello from the Overview sub tab!",
                Time = 3,
            })
        end,
    })

    local Left = Layout:AddLeftGroupbox("Left column")
    Left:AddSlider("SubLayoutSlider", {
        Text = "A slider",
        Default = 40,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
    })

    Left:AddDropdown("SubLayoutDropdown", {
        Text = "A dropdown",
        Values = { "Option A", "Option B", "Option C" },
        Default = 1,
    })

    local Right = Layout:AddRightGroupbox("Right column")
    Right:AddInput("SubLayoutInput", {
        Text = "A textbox",
        Placeholder = "type here",
    })

    Right:AddToggle("SubLayoutToggle", {
        Text = "A toggle",
        Default = false,
    })

    local Box = Nested:AddLeftTabbox("A Tabbox")

    local TabA = Box:AddTab("Tab A")
    TabA:AddToggle("SubNestedToggleA", {
        Text = "Tab A toggle",
    })

    TabA:AddButton({
        Text = "Tab A button",
        Func = function()
            Log("Nested Tab A button")
        end,
    })

    local TabB = Box:AddTab("Tab B")
    TabB:AddSlider("SubNestedSlider", {
        Text = "Tab B slider",
        Default = 5,
        Min = 0,
        Max = 10,
        Rounding = 0,
    })

    Nested:AddRightGroupbox("Notes")
        :AddLabel("A tabbox can nest inside a sub tab, a groupbox, anywhere.", true)
end

--// 7. Key System tab \\--

do
    Tabs.Key:AddLabel({
        Text = "Key: Banana",
        DoesWrap = true,
        Size = 16,
    })

    Tabs.Key:AddKeyBox(function(ReceivedKey)
        local Success = ReceivedKey == "Banana"

        Log("Key check —", ReceivedKey, "| success:", Success)

        Library:Notify({
            Title = "Key System",
            Description = "Received: " .. tostring(ReceivedKey)
                .. "\nSuccess: " .. tostring(Success),
            Time = 4,
        })
    end)
end

--// 8. Overlays \\--

do
    Library:AddDraggableLabel("This is a Draggable Label")

    local Watermark = Library:AddWatermark({
        { Player = LocalPlayer },
        { Icon = 95816097006870, Text = "Uelinoria", Accent = true },
        {
            Icon = 95816097006870,
            Text = function()
                return (identifyexecutor and identifyexecutor()) or "Unknown"
            end,
        },
        {
            Icon = 95816097006870,
            Text = function()
                local Ping = 0
                pcall(function()
                    Ping = math.floor(
                        Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5
                    )
                end)
                return string.format("%d ms", Ping)
            end,
        },
        {
            Icon = 95816097006870,
            Text = function()
                return os.date("%H:%M")
            end,
        },
    })

    Watermark.RefreshRate = 1
end

--// 9. UI Settings + managers \\--

do
    local Menu = Tabs.Settings:AddLeftGroupbox("Menu")

    Menu:AddToggle("KeybindMenuOpen", {
        Text = "Open Keybind Menu",
        Default = Library.KeybindFrame.Visible,
        Callback = function(Value)
            Library.KeybindFrame.Visible = Value
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
            Library:SetDPIScale(tonumber(Value:gsub("%%", "")))
        end,
    })

    Menu:AddToggle("UILocked", {
        Text = "Lock UI",
        Default = false,
        Callback = function(Value)
            Library:SetUILocked(Value)
        end,
    })

    Menu:AddDivider()

    Menu:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
        Default = "RightShift",
        NoUI = true,
        Text = "Menu keybind",
    })

    Menu:AddButton("Unload", function()
        Library:Unload()
    end)

    Library.ToggleKeybind = Options.MenuKeybind

    -- ThemeManager
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("Uelinoria")

    -- SaveManager
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({
        "MenuKeybind",
        "KeybindMenuOpen",
        "AlwaysOnTop",
        "NotificationSide",
        "DPIScale",
        "UILocked",
    })
    SaveManager:SetFolder("Uelinoria/specific-game")
    SaveManager:SetSubFolder(tostring(game.PlaceId))

    SaveManager:BuildConfigSection(Tabs.Settings)
    ThemeManager:ApplyToTab(Tabs.Settings)

    -- Load the config marked for autoload, if one exists.
    SaveManager:LoadAutoloadConfig()
end

Library:OnUnload(function()
    Log("Uelinoria unloaded.")
end)
