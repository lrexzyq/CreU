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

-- Library.DebugCreateErrors: warns in the console if a Create() call fails.
Library.DebugCreateErrors = true
-- Library.NotifyOnError: SafeCallback shows a notification if a user callback errors.
Library.NotifyOnError = true
-- Library.AutoSaveEnabled: when true, AttemptSave() (called after every option
-- change) writes the current config automatically instead of only on manual Save.
Library.AutoSaveEnabled = true

local Window = Library:CreateWindow({
    Title = "CreU Showcase",
    Minimizable = true,
    MinimizeKeybind = Enum.KeyCode.RightBracket,
    Center = true,
    Size = UDim2.fromOffset(700, 600),
    AutoShow = true,
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
Library:SetNotifySide("Right")

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
        -- AddKeyPicker chained onto a Toggle lets the user bind a key
        -- (here F6) to press instead of clicking the toggle. Mode
        -- "Toggle" means pressing the key flips it on/off, same as
        -- clicking (as opposed to "Hold", which keeps it on only while
        -- the key is held down).
        Default = "F6",
        Mode = "Toggle",
        Text = "Demo Toggle",
        -- SyncToggleState: whether pressing this key should also flip
        -- the actual DemoEnabled Toggle above (calling its own callback
        -- too), not just this keybind's own Callback/Clicked. false here
        -- means the key press only fires this KeyPicker's own callback --
        -- the DemoEnabled toggle itself is left completely untouched, as
        -- if the two were unrelated. Set true to make the key act as a
        -- real alternate way of clicking the toggle.
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
        -- Multi: lets the user pick more than one value at once (a
        -- checklist instead of a single choice) -- the dropdown stays
        -- open and shows checkmarks next to every selected value.
        Multi = true,
        -- Searchable: adds a text box at the top of the dropdown list so
        -- the user can type to filter down to matching values instead of
        -- scrolling through everything. Most useful once a dropdown has
        -- more than a handful of options.
        Searchable = true,
        -- SelectAllButtons: only meaningful together with Multi -- adds
        -- "Select All" / "Deselect All" buttons above the list so the
        -- user doesn't have to click every option one by one.
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
        -- DoubleClick: the button won't run its Func on the first click --
        -- it shows a confirmation state instead, and only runs Func if
        -- clicked again within a short window. Useful for destructive
        -- actions (delete, reset, unload) where an accidental single
        -- click shouldn't trigger anything.
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

    -- Risky: purely visual -- tints the toggle's label text with
    -- Library.RiskColor (red by default) as a warning to the user that
    -- this feature is risky to use (e.g. more likely to get flagged,
    -- more likely to break something). It doesn't add any confirmation
    -- prompt or block the toggle -- it just colors the text differently.
    TogglesBox:AddToggle("RiskyToggle", {
        Text = "Risky Toggle",
        Default = false,
        Risky = true,
    })

    TogglesBox:AddButton({
        Text = "Read Value / Update Tooltip",
        Tooltip = "Demonstrates Funcs:GetValue() and Funcs:SetTooltip()",
        Func = function()
            Log("BasicToggle value via GetValue():", Toggles.BasicToggle:GetValue())
            Toggles.BasicToggle:SetTooltip("Tooltip updated via SetTooltip() at " .. os.date("%H:%M:%S"))
        end,
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
        -- Compact: uses a smaller/tighter visual layout for the slider,
        -- for groupboxes with limited space where the normal-sized
        -- slider would feel too spread out.
        Compact = true,
    })

    Sliders:AddSlider("HiddenMaxSlider", {
        Text = "Hidden Max",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
        -- HideMax: only shows the slider's current value, not "current /
        -- max" (e.g. "50%" instead of "50 / 100%"). Useful when the max
        -- is an implementation detail the user doesn't need to see.
        HideMax = true,
    })

    Sliders:AddButton({
        Text = "Widen Basic Slider Range",
        Tooltip = "Demonstrates chainable SetMin/SetMax/SetPrefix/SetSuffix",
        Func = function()
            Options.BasicSlider:SetMin(0):SetMax(10)
            Options.CompactSlider:SetPrefix("~"):SetSuffix("% done")
        end,
    })

    local Inputs = Tabs.Elements:AddLeftGroupbox(
        "Inputs",
        "keyboard"
    )

    Inputs:AddInput("TextInput", {
        Text = "Textbox",
        Default = "Type here",
        Placeholder = "Placeholder",
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

    Inputs:AddMultiTextbox("NotesInput", {
        Text = "Multi-line Notes",
        Default = "Type multiple lines here...",
        Placeholder = "Notes, scripts, JSON, etc.",
        Height = 70,
        Finished = false,
        Tooltip = "Same Value/SetValue contract as AddInput, saved the same way",
    })

    local NewControls = Tabs.Elements:AddRightGroupbox(
        "New Controls",
        "sparkles"
    )

    NewControls:AddRangeSlider("PriceRange", {
        Text = "Price Range",
        Min = 0,
        Max = 1000,
        Rounding = 0,
        Prefix = "$",
        Default = { 100, 400 },
        Callback = function(Low, High)
            Log("PriceRange changed:", Low, "-", High)
        end,
    })

    local Progress = NewControls:AddProgressBar({
        Text = "Download Progress",
        Default = 0,
    })

    NewControls:AddButton({
        Text = "Simulate Progress",
        Tooltip = "Animates the progress bar above from 0% to 100%",
        Func = function()
            task.spawn(function()
                for i = 0, 100, 5 do
                    Progress:SetProgress(i)
                    task.wait(0.05)
                end
            end)
        end,
    })

    NewControls:AddImage({
        Text = "Preview Image",
        Image = "rbxassetid://6031302930",
        Height = 90,
    })

    NewControls:AddButton({
        Text = "Show Toast With Actions",
        Tooltip = "Demonstrates Library:NotifyWithActions",
        Func = function()
            Library:NotifyWithActions("Delete this config?", {
                {
                    Text = "Undo",
                    Callback = function() Log("Undo pressed") end,
                },
                {
                    Text = "Confirm",
                    Callback = function() Log("Confirm pressed") end,
                },
            }, 8)
        end,
    })

    NewControls:AddButton({
        Text = "Show Confirm Dialog",
        Tooltip = "Demonstrates Library:Confirm (modal Yes/No)",
        Func = function()
            Library:Confirm({
                Title = "Reset Settings",
                Text = "This will reset all settings to their defaults. Continue?",
                ConfirmText = "Reset",
                CancelText = "Cancel",
            }, function(Result)
                Log("Confirm dialog result:", Result)
                Library:Notify(Result and "Settings reset!" or "Cancelled.", 3)
            end)
        end,
    })

    NewControls:AddButton({
        Text = "Show Loading Overlay",
        Tooltip = "Demonstrates Library:ShowLoading / Handle:Hide",
        Func = function()
            task.spawn(function()
                local Loading = Library:ShowLoading("Fetching data...")
                task.wait(1)
                Loading:SetText("Almost done...")
                task.wait(1)
                Loading:Hide()
                Library:Notify("Done!", 2)
            end)
        end,
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
        -- Expandable / ExpandColumns: accepted and stored by AddDropdown
        -- (there's even Dropdown:SetExpandable()/:SetExpandColumns() to
        -- change them later), but at the time of writing nothing in
        -- Library.lua actually reads these fields back to change how the
        -- dropdown renders -- setting them currently has no visible
        -- effect. Left here as-is rather than removed, since a future
        -- Library.lua update may wire them up.
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
        -- DragSelect: only works together with Multi -- lets the user
        -- click-and-drag across multiple items to select/deselect them
        -- all in one motion, instead of clicking each one individually.
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
        Tooltip = "This dropdown is disabled",
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

    Dropdowns:AddButton({
        Text = "Multi Select: Select All / Deselect All",
        Tooltip = "Demonstrates Dropdown:SelectAll() / DeselectAll()",
        Func = function()
            Options.MultiDropdown:SelectAll()
            task.wait(1)
            Options.MultiDropdown:DeselectAll()
            Options.MultiDropdown:Select("Box")
            Options.MultiDropdown:Select("Name")
        end,
    })

    Dropdowns:AddButton({
        Text = "Add Value + Search + Expand",
        Tooltip = "Demonstrates AddValues, SetSearch, SetMaxVisibleItems and ToggleExpanded",
        Func = function()
            Options.LongDropdown:AddValues({ "CustomMaterial" })
            Options.SearchableDropdown:SetSearch("Ki")
            Options.SearchableDropdown:SetMaxVisibleItems(5)
            Options.SearchableDropdown:ToggleExpanded()
        end,
    })

    local DictionaryValuesToggled = false

    Dropdowns:AddButton({
        Text = "Toggle Extra Disabled Value",
        Tooltip = "Demonstrates AddDisabledValues / ClearDisabledValues",
        Func = function()
            DictionaryValuesToggled = not DictionaryValuesToggled

            if DictionaryValuesToggled then
                Options.DictionaryDropdown:AddDisabledValues({ "item06" })
            else
                Options.DictionaryDropdown:ClearDisabledValues()
            end
        end,
    })

    Dropdowns:AddButton({
        Text = "Reset Basic Dropdown Values",
        Tooltip = "Demonstrates Dropdown:SetValues() and Refresh()",
        Func = function()
            Options.BasicDropdown:SetValues({ "Alpha", "Bravo", "Charlie", "Delta", "Echo" })
            Options.BasicDropdown:Refresh()
        end,
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

    Priority:AddButton({
        Text = "Move 'High' Priority Up",
        Tooltip = "Demonstrates PriorityDropdown:MoveUp() and :GetValue()",
        Func = function()
            Options.PriorityDropdown:MoveUp("High")
            Log("Priority order:", table.concat(Options.PriorityDropdown:GetValue(), ", "))
        end,
    })

    local SpecialDropdownsVisible = true

    Priority:AddButton({
        Text = "Toggle Player/Team Dropdown Visibility",
        Tooltip = "Demonstrates Dropdown:SetVisible()",
        Func = function()
            SpecialDropdownsVisible = not SpecialDropdownsVisible
            Options.PlayerDropdown:SetVisible(SpecialDropdownsVisible)
            Options.TeamDropdown:SetVisible(SpecialDropdownsVisible)
        end,
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
            -- NoUI: the key still works normally when pressed (Toggle
            -- mode fires here same as any other keybind), it just never
            -- appears in the on-screen Keybinds list (the small panel
            -- showing currently-bound keys). Useful for keys you don't
            -- want cluttering that list, or want to keep less obvious.
            NoUI = true,
        }
    )

    -- AddKeybind is an alias of AddKeyPicker, callable directly on a groupbox.
    Pickers:AddKeybind("AliasKey", {
        Default = "G",
        Mode = "Toggle",
        Text = "AddKeybind Alias",
    })

    Pickers:AddButton({
        Text = "Set Demo Color to Red",
        Tooltip = "Demonstrates ColorPicker:SetValueRGB()",
        Func = function()
            Options.DemoColor:SetValueRGB(Color3.fromRGB(255, 0, 0))
        end,
    })

    Pickers:AddButton({
        Text = "Open Demo Keybind Picker",
        Tooltip = "Demonstrates KeyPicker:DoClick()",
        Func = function()
            Options.DemoKey:DoClick()
        end,
    })

    Options.DemoKey:OnClick(function()
        Log("DemoKey picker was clicked")
    end)

    Options.DemoColorAlpha:OnTransparencyChanged(function(Transparency)
        Log("DemoColorAlpha transparency:", Transparency)
    end)
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

    local RowColumn1, RowColumn2 = LayoutLeft:AddRow(2)

    RowColumn1:AddToggle("RowToggle", {
        Text = "Row Toggle",
        Default = false,
    })

    RowColumn2:AddSlider("RowSlider", {
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

    -- Nested Tabbox: a THIRD tab level living inside "Tab 1" above,
    -- matching the reference screenshot's structure (top-level tab ->
    -- sub-tab strip -> another sub-tab strip nested inside one of the
    -- sub-tabs). Funcs:AddTabbox works on any BaseGroupbox-shaped
    -- container, including a Tabbox's own sub-tab, so this nests freely.
    TabOne:AddLabel("Nested tabbox (3rd level):", true)
    local InnerTabbox = TabOne:AddTabbox("Weapon Category")

    local GeneralTab = InnerTabbox:AddTab("General")
    GeneralTab:AddToggle("NestedGeneralToggle", {
        Text = "General Setting",
        Default = false,
    })

    local PrimaryTab = InnerTabbox:AddTab("Primary")
    PrimaryTab:AddSlider("NestedPrimarySlider", {
        Text = "Primary Slider",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
    })

    local SecondaryTab = InnerTabbox:AddTab("Secondary")
    SecondaryTab:AddDropdown("NestedSecondaryDropdown", {
        Text = "Secondary Mode",
        Values = { "Semi", "Auto" },
        Default = 1,
    })

    local MeleeTab = InnerTabbox:AddTab("Melee")
    MeleeTab:AddCheckbox("NestedMeleeCheckbox", {
        Text = "Melee Checkbox",
        Default = false,
    })

    local UtilityTab = InnerTabbox:AddTab("Utility")
    UtilityTab:AddInput("NestedUtilityInput", {
        Text = "Utility Input",
        Placeholder = "Type here...",
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
    -- WHAT IS A "KEY SYSTEM"? A gate that only lets the script's
    -- features be used after the user enters a correct key/password.
    -- Scripts commonly use this to control who gets access (e.g. paid
    -- users, Discord members, whitelisted testers) without needing a
    -- real login system -- the accepted key(s) are just checked locally
    -- against a list written into the script itself.
    --
    -- NOTE: AddKeyBox (used further below) is the original simple
    -- key-entry widget -- a control living inside a normal tab that just
    -- reports the submitted key via callback; it doesn't hide/gate
    -- anything on its own. It's independent of AddKeyBoxUnlock below
    -- (which locks only the groupboxes on this specific tab), and of the
    -- separate full-window Config.KeySystem gate that Library:CreateWindow
    -- still supports (just not used in this example) -- see Library.lua.
    --
    -- AddKeyBoxUnlock: everything added to THIS tab via
    -- Tab:AddLeftGroupbox/AddRightGroupbox AFTER this call starts out
    -- hidden -- exactly like AddDependencyBox content -- and is revealed
    -- once a valid key is submitted (or GetKeyLink is used to copy a
    -- link for where to obtain one, mirroring how key-system provider
    -- links usually work: the accepted key(s) live in the script, while
    -- the public-facing "get key" link can point anywhere, e.g. Discord).
    Tabs.Key:AddKeyBoxUnlock({
        Title = "Unlock Features",
        Text = "Key",
        Placeholder = "Enter key to unlock...",
        Note = "Demo keys: \"Banana\" or \"Coconut\"",
        Key = { "Banana", "Coconut" },
        SaveKey = true,
        FolderName = "CreUShowcase",
        FileName = "tabkey",
        GetKeyLink = "https://discord.gg/NdpYnJuuN4",
        Callback = function(ReceivedKey)
            Library:Notify("Unlocked with key: " .. tostring(ReceivedKey), 4)
        end,
    })

    -- Added AFTER AddKeyBoxUnlock, so this whole groupbox (and every
    -- control in it) stays hidden until the key above is accepted.
    local Locked = Tabs.Key:AddLeftGroupbox("Unlocked Controls", "unlock")

    Locked:AddToggle("KeyUnlockedToggle", {
        Text = "Feature Toggle",
        Default = false,
    })

    Locked:AddSlider("KeyUnlockedSlider", {
        Text = "Feature Slider",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
    })

    Locked:AddDropdown("KeyUnlockedDropdown", {
        Text = "Feature Dropdown",
        Values = { "Option A", "Option B", "Option C" },
        Default = 1,
    })

    Locked:AddInput("KeyUnlockedInput", {
        Text = "Feature Input",
        Placeholder = "Type here...",
    })

    Locked:AddButton({
        Text = "Feature Button",
        Func = function()
            Library:Notify("This button was behind the key lock!", 3)
        end,
    })

    -- AddRow: two side-by-side sub-groupboxes, still hidden until the key
    -- above is accepted since Locked itself is hidden.
    local RowLeft, RowRight = Locked:AddRow(2)
    RowLeft:AddLabel("Row - Left side")
    RowLeft:AddToggle("KeyUnlockedRowToggle", {
        Text = "Row Toggle",
        Default = false,
    })
    RowRight:AddLabel("Row - Right side")
    RowRight:AddSlider("KeyUnlockedRowSlider", {
        Text = "Row Slider",
        Default = 25,
        Min = 0,
        Max = 100,
        Rounding = 0,
    })

    -- AddDependencyBox: content only shows once BOTH the key above is
    -- accepted (Locked is visible) AND KeyUnlockedToggle is on.
    Locked:AddDivider()
    Locked:AddLabel("Dependency box (also needs Feature Toggle above ON):")
    local KeyDepBox = Locked:AddDependencyBox()
    KeyDepBox:SetupDependencies({
        { Toggles.KeyUnlockedToggle, true },
    })
    KeyDepBox:AddLabel("This only shows when unlocked AND the toggle is on.")
    KeyDepBox:AddButton({
        Text = "Dependency Button",
        Func = function()
            Library:Notify("Both conditions were met!", 3)
        end,
    })

    -- Second groupbox on this tab, covering every remaining control type
    -- the library supports -- also created via the wrapped
    -- AddRightGroupbox above, so it starts hidden and unlocks together
    -- with Locked.
    local LockedRight = Tabs.Key:AddRightGroupbox("More Unlocked Controls", "sparkles")

    LockedRight:AddPlayerInfo("KeyUnlockedPlayerInfo", {
        Player = LocalPlayer,
        Title = "Player Info Card",
        Description = { "Shown only once unlocked" },
    })

    LockedRight:AddCheckbox("KeyUnlockedCheckbox", {
        Text = "Feature Checkbox",
        Default = false,
    })

    LockedRight:AddLabel("Color Picker"):AddColorPicker("KeyUnlockedColor", {
        Default = Color3.fromRGB(0, 255, 140),
        Title = "Feature Color",
        Transparency = 0,
    })

    LockedRight:AddLabel("Color Picker (Alpha)"):AddColorPickerAlpha("KeyUnlockedColorAlpha", {
        Default = Color3.fromRGB(255, 170, 0),
        Title = "Feature Color Alpha",
    })

    LockedRight:AddLabel("Keybind"):AddKeyPicker("KeyUnlockedKeybind", {
        Default = "None",
        Mode = "Toggle",
        Text = "Feature Keybind",
    })

    LockedRight:AddPriorityDropdown("KeyUnlockedPriority", {
        Text = "Priority Dropdown",
        Values = { "Critical", "High", "Medium", "Low" },
        Default = { "High" },
        Searchable = true,
        SelectAllButtons = true,
    })

    LockedRight:AddMultiTextbox("KeyUnlockedNotes", {
        Text = "Multi-line Notes",
        Default = "",
        Placeholder = "Type multiple lines here...",
        Height = 60,
        Finished = false,
    })

    LockedRight:AddRangeSlider("KeyUnlockedRange", {
        Text = "Feature Range",
        Min = 0,
        Max = 1000,
        Rounding = 0,
        Prefix = "$",
        Default = { 100, 400 },
    })

    local KeyProgress = LockedRight:AddProgressBar({
        Text = "Feature Progress",
        Default = 0,
    })
    LockedRight:AddButton({
        Text = "Simulate Progress",
        Func = function()
            task.spawn(function()
                for i = 0, 100, 5 do
                    KeyProgress:SetProgress(i)
                    task.wait(0.05)
                end
            end)
        end,
    })

    LockedRight:AddImage({
        Text = "Feature Preview Image",
        Image = "rbxassetid://6031302930",
        Height = 70,
    })

    LockedRight:AddSection("Section header")
    LockedRight:AddParagraph("This is a paragraph control, also part of the locked tab's full control set.", true)
    LockedRight:AddBlank(6)
    LockedRight:AddDivider()

    LockedRight:AddKeybind("KeyUnlockedKeybindAlias", {
        Default = "None",
        Mode = "Toggle",
        Text = "Keybind (via AddKeybind alias)",
    })
end

do
    local DraggableLabel = Library:AddDraggableLabel({
        Text = "CreU Draggable Label",
        Position = UDim2.fromOffset(12, 12),
    })
    Library:AddTooltip("Drag me anywhere on screen", nil, DraggableLabel)

    Library:AddDraggableButton({
        Text = "Quick Notify",
        Position = UDim2.fromOffset(12, 40),
        Func = function()
            Library:Notify("Quick notify button pressed", 2)
        end,
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

    Library:OnUnload(function()
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

    Menu:AddToggle("NotifyOnError", {
        Text = "Notify On Callback Error",
        Default = Library.NotifyOnError == true,

        Callback = function(Value)
            Library.NotifyOnError = Value
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

    local Utilities = Tabs.Settings:AddRightGroupbox("Library Utilities", "wrench")

    Utilities:AddSection("Appearance")

    Utilities:AddSlider("UtilFontSize", {
        Text = "Font Size",
        Default = Library.FontSize or 14,
        Min = 10,
        Max = 20,
        Rounding = 0,
        Callback = function(Value)
            Library:SetFontSize(Value)
        end,
    })

    Utilities:AddSection("Keybinds")

    Utilities:AddDropdown("UtilKeybindMode", {
        Text = "Keybind Mode",
        Values = { "All", "Toggle", "Hold", "Always" },
        Default = Library.KeybindMode or "All",
        Callback = function(Value)
            Library:SetKeybindMode(Value)
        end,
    })

    Utilities:AddButton({
        Text = "Refresh Keybinds",
        Tooltip = "Demonstrates Library:RefreshKeybinds()",
        Func = function()
            Library:RefreshKeybinds()
        end,
    })

    Utilities:AddSection("Notifications")

    Utilities:AddButton({
        Text = "Print Notification History",
        Tooltip = "Demonstrates Library:NotifyHistory()",
        Func = function()
            Log("Notification history count:", #Library:NotifyHistory())
        end,
    })

    Utilities:AddButton({
        Text = "Clear Notification History",
        Tooltip = "Demonstrates Library:ClearNotificationHistory()",
        Func = function()
            Library:ClearNotificationHistory()
            Log("Notification history cleared")
        end,
    })

    Utilities:AddButton({
        Text = "Shift Notification Position",
        Tooltip = "Demonstrates Library:SetNotificationConfig()",
        Func = function()
            Library:SetNotificationConfig({ PositionY = 60 })
        end,
    })

    Library.ToggleKeybind = Options.MenuKeybind

    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("CreU")
    ThemeManager:ApplyToTab(Tabs.Settings)

    SaveManager:SetLibrary(Library)
    -- IgnoreThemeSettings: tells SaveManager to leave color/theme-related
    -- options (BackgroundColor, AccentColor, the theme dropdown, etc.)
    -- out of its own saved configs. Those are already handled separately
    -- by ThemeManager above -- without this, saving/loading a SaveManager
    -- config could fight with ThemeManager over which one controls the
    -- UI's colors.
    SaveManager:IgnoreThemeSettings()

    -- SetIgnoreIndexes: the general-purpose version of the above -- lists
    -- specific option Idx values that should never be written into or
    -- read back from SaveManager configs. MenuKeybind is excluded here so
    -- switching configs never changes which key opens the menu itself.
    SaveManager:SetIgnoreIndexes({
        "MenuKeybind",
    })

    SaveManager:SetFolder("CreU/specific-game")
    SaveManager:SetSubFolder("specific-place")

    -- NOTE: the old duplicate call to SaveManager:BuildUploadSection() was
    -- removed here (it was called a second time even though
    -- BuildConfigSection already called it once, creating two "Upload"
    -- groupboxes). The upload feature itself has since been removed from
    -- SaveManager.lua because its backing web service is offline.
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