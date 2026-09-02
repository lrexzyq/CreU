local HttpService = game:GetService("HttpService")

local ThemeManager = {}

do
    local ThemeFields = {
        "FontColor",
        "MainColor",
        "AccentColor",
        "BackgroundColor",
        "OutlineColor",
    }

    local function Trim(Value)
        if type(Value) ~= "string" then
            return Value
        end
        return Value:gsub("^%s+", ""):gsub("%s+$", "")
    end

    local function IsSafeThemeName(Name)
        if type(Name) ~= "string" then
            return false
        end

        Name = Trim(Name)

        if Name == "" then
            return false
        end

        if Name:find("[/\\]") or Name:find("%.%.", 1, true) or Name:find('[<>:"|%?%*]') then
            return false
        end

        if Name:sub(1, 1) == "." then
            return false
        end

        return true
    end

    local function GetOptions(Self)
        local Library = Self.Library
        if not Library then
            return nil
        end

        if type(Library.Options) == "table" then
            return Library.Options
        end

        return nil
    end

    local function Notify(Self, Text, Time)
        local Library = Self.Library
        if Library and type(Library.Notify) == "function" then
            pcall(Library.Notify, Library, Text, Time)
        end
    end

    local function IsColor(Value)
        return typeof(Value) == "Color3"
    end

    local function ColorToHex(Value)
        if not IsColor(Value) then
            return nil
        end

        local Ok, Result = pcall(function()
            return Value:ToHex()
        end)

        if Ok and type(Result) == "string" then
            return Result
        end

        return nil
    end

    local function SetColorOption(Option, Color)
        if not Option then
            return false
        end

        if type(Option.SetValueRGB) == "function" then
            local Ok = pcall(Option.SetValueRGB, Option, Color)
            return Ok
        end

        return false
    end

    ThemeManager.Folder = "LinoriaLibSettings"
    ThemeManager.Library = nil
    ThemeManager.DefaultTheme = "Default"
    ThemeManager._ApplyingTheme = false

    ThemeManager.BuiltInThemes = {
        ["Default"] = {1, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1c1c1c","AccentColor":"0055ff","BackgroundColor":"141414","OutlineColor":"323232"}')},
        ["BBot"] = {2, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1e1e","AccentColor":"7e48a3","BackgroundColor":"232323","OutlineColor":"141414"}')},
        ["Fatality"] = {3, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1842","AccentColor":"c50754","BackgroundColor":"191335","OutlineColor":"3c355d"}')},
        ["Jester"] = {4, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"db4467","BackgroundColor":"1c1c1c","OutlineColor":"373737"}')},
        ["Mint"] = {5, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"3db488","BackgroundColor":"1c1c1c","OutlineColor":"373737"}')},
        ["Tokyo Night"] = {6, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"191925","AccentColor":"6759b3","BackgroundColor":"16161f","OutlineColor":"323232"}')},
        ["Ubuntu"] = {7, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"3e3e3e","AccentColor":"e2581e","BackgroundColor":"323232","OutlineColor":"191919"}')},
        ["Quartz"] = {8, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"232330","AccentColor":"426e87","BackgroundColor":"1d1b26","OutlineColor":"27232f"}')},
        ["Creep"] = {9, HttpService:JSONDecode('{"FontColor":"c5c3c3","MainColor":"000000","AccentColor":"ffffff","BackgroundColor":"000000","OutlineColor":"27232f"}')},
        ["Ue"] = {10, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"181818","AccentColor":"4777b6","BackgroundColor":"141414","OutlineColor":"1f1f1f"}')},
    }

    function ThemeManager:GetOption(Name)
        local Options = GetOptions(self)
        return Options and Options[Name] or nil
    end

    function ThemeManager:ApplyTheme(Theme)
        Theme = Trim(Theme)

        if type(Theme) ~= "string" or not IsSafeThemeName(Theme) or not self.Library then
            return false
        end

        local CustomData = self:GetCustomTheme(Theme)
        local BuiltIn = self.BuiltInThemes[Theme]
        local Scheme = CustomData or (BuiltIn and BuiltIn[2])

        if type(Scheme) ~= "table" then
            return false
        end

        self._ApplyingTheme = true

        local Changed = false
        local Options = GetOptions(self)

        for _, Field in ipairs(ThemeFields) do
            local Hex = Scheme[Field]

            if type(Hex) == "string" then
                local Ok, Color = pcall(Color3.fromHex, Hex)

                if Ok and IsColor(Color) then
                    self.Library[Field] = Color

                    if Options then
                        SetColorOption(Options[Field], Color)
                    end

                    Changed = true
                end
            end
        end

        self._ApplyingTheme = false

        if not Changed then
            return false
        end

        self:ThemeUpdate()
        return true
    end

    function ThemeManager:ThemeUpdate()
        if not self.Library then
            return false
        end

        local Options = GetOptions(self)

        if Options then
            for _, Field in ipairs(ThemeFields) do
                local Option = Options[Field]

                if Option and IsColor(Option.Value) then
                    self.Library[Field] = Option.Value
                end
            end
        end

        if IsColor(self.Library.AccentColor) and type(self.Library.GetDarkerColor) == "function" then
            local Ok, Dark = pcall(self.Library.GetDarkerColor, self.Library, self.Library.AccentColor)
            if Ok and IsColor(Dark) then
                self.Library.AccentColorDark = Dark
            end
        end

        if type(self.Library.UpdateColorsUsingRegistry) == "function" then
            pcall(self.Library.UpdateColorsUsingRegistry, self.Library)
        end

        return true
    end

    function ThemeManager:LoadDefault()
        local Theme = self.DefaultTheme
        local IsBuiltIn = true
        local Path = self.Folder .. "/themes/default.txt"

        local Content
        local OkRead, Result = pcall(function()
            if isfile(Path) then
                return readfile(Path)
            end
        end)

        if OkRead and type(Result) == "string" then
            Content = Trim(Result)
        end

        if Content and Content ~= "" then
            if self.BuiltInThemes[Content] then
                Theme = Content
            elseif self:GetCustomTheme(Content) then
                Theme = Content
                IsBuiltIn = false
            end
        elseif self.BuiltInThemes[self.DefaultTheme] then
            Theme = self.DefaultTheme
        end

        local Options = GetOptions(self)

        if IsBuiltIn then
            local List = Options and Options.ThemeManager_ThemeList
            if List and type(List.SetValue) == "function" then
                pcall(List.SetValue, List, Theme)
            else
                self:ApplyTheme(Theme)
            end
        else
            self:ApplyTheme(Theme)

            local CustomList = Options and Options.ThemeManager_CustomThemeList
            if CustomList and type(CustomList.SetValue) == "function" then
                pcall(CustomList.SetValue, CustomList, Theme)
            end
        end

        return Theme
    end

    function ThemeManager:SaveDefault(Theme)
        Theme = Trim(Theme)

        if type(Theme) ~= "string" or not IsSafeThemeName(Theme) then
            return false, "invalid theme"
        end

        if not self.BuiltInThemes[Theme] and not self:GetCustomTheme(Theme) then
            return false, "theme does not exist"
        end

        local Ok, Err = pcall(writefile, self.Folder .. "/themes/default.txt", Theme)
        if not Ok then
            return false, Err
        end

        return true
    end

    function ThemeManager:CreateThemeManager(Groupbox)
        assert(self.Library, "Must set ThemeManager.Library first!")
        assert(Groupbox, "ThemeManager requires a groupbox")

        local Options = GetOptions(self)
        assert(Options, "Library.Options is unavailable")

        Groupbox:AddLabel("Background color"):AddColorPicker("BackgroundColor", {
            Default = self.Library.BackgroundColor
        })
        Groupbox:AddLabel("Main color"):AddColorPicker("MainColor", {
            Default = self.Library.MainColor
        })
        Groupbox:AddLabel("Accent color"):AddColorPicker("AccentColor", {
            Default = self.Library.AccentColor
        })
        Groupbox:AddLabel("Outline color"):AddColorPicker("OutlineColor", {
            Default = self.Library.OutlineColor
        })
        Groupbox:AddLabel("Font color"):AddColorPicker("FontColor", {
            Default = self.Library.FontColor
        })

        local Themes = {}
        for Name, Data in next, self.BuiltInThemes do
            if type(Data) == "table" then
                Themes[#Themes + 1] = Name
            end
        end

        table.sort(Themes, function(A, B)
            local IA = self.BuiltInThemes[A][1]
            local IB = self.BuiltInThemes[B][1]
            if IA == IB then
                return A < B
            end
            return IA < IB
        end)

        Groupbox:AddDivider()
        Groupbox:AddDropdown("ThemeManager_ThemeList", {
            Text = "Theme list",
            Values = Themes,
            Default = self.DefaultTheme,
            Searchable = true,
            MaxVisibleItems = 6,
            ItemHeight = 18
        })

        Groupbox:AddButton("Set as default", function()
            local List = self:GetOption("ThemeManager_ThemeList")
            local Theme = List and List.Value
            local Ok, Err = self:SaveDefault(Theme)

            if Ok then
                Notify(self, string.format("Set default theme to %q", Theme))
            else
                Notify(self, "Failed to set default theme: " .. tostring(Err), 3)
            end
        end)

        Groupbox:AddDivider()
        Groupbox:AddInput("ThemeManager_CustomThemeName", {
            Text = "Custom theme name",
            Placeholder = "Theme name",
            ClearTextOnFocus = false
        })

        Groupbox:AddDropdown("ThemeManager_CustomThemeList", {
            Text = "Custom themes",
            Values = self:ReloadCustomThemes(),
            AllowNull = true,
            Default = nil,
            Searchable = true,
            MaxVisibleItems = 6,
            ItemHeight = 18
        })

        Groupbox:AddDivider()

        Groupbox:AddButton("Save theme", function()
            local NameOption = self:GetOption("ThemeManager_CustomThemeName")
            local List = self:GetOption("ThemeManager_CustomThemeList")
            local Name = NameOption and NameOption.Value

            local Ok, Err = self:SaveCustomTheme(Name)

            if not Ok then
                Notify(self, tostring(Err), 3)
                return
            end

            if List and type(List.SetValues) == "function" then
                pcall(List.SetValues, List, self:ReloadCustomThemes())
            end
            if List and type(List.SetValue) == "function" then
                pcall(List.SetValue, List, Name)
            end

            Notify(self, string.format("Saved theme %q", Name))
        end)

        Groupbox:AddButton("Load theme", function()
            local List = self:GetOption("ThemeManager_CustomThemeList")
            local Name = List and List.Value

            if type(Name) ~= "string" or Name == "" then
                Notify(self, "Select a custom theme first", 3)
                return
            end

            if not self:ApplyTheme(Name) then
                Notify(self, "Failed to load theme", 3)
            end
        end)

        Groupbox:AddButton("Refresh list", function()
            local List = self:GetOption("ThemeManager_CustomThemeList")
            if List and type(List.SetValues) == "function" then
                pcall(List.SetValues, List, self:ReloadCustomThemes())
            end
            if List and type(List.SetValue) == "function" then
                pcall(List.SetValue, List, nil)
            end
        end)

        Groupbox:AddButton("Set custom as default", function()
            local List = self:GetOption("ThemeManager_CustomThemeList")
            local Name = List and List.Value
            local Ok, Err = self:SaveDefault(Name)

            if Ok then
                Notify(self, string.format("Set default theme to %q", Name))
            else
                Notify(self, "Failed to set default theme: " .. tostring(Err), 3)
            end
        end)

        local function UpdateTheme()
            if not self._ApplyingTheme then
                self:ThemeUpdate()
            end
        end

        for _, Field in ipairs(ThemeFields) do
            local Option = Options[Field]
            if Option and type(Option.OnChanged) == "function" then
                Option:OnChanged(UpdateTheme)
            end
        end

        self:LoadDefault()
    end

    function ThemeManager:GetCustomTheme(File)
        if type(File) ~= "string" then
            return nil
        end

        local Name = Trim(File):gsub("%.json$", "")

        if not IsSafeThemeName(Name) then
            return nil
        end

        local Path = self.Folder .. "/themes/" .. Name .. ".json"

        local OkExists, Exists = pcall(isfile, Path)
        if not OkExists or not Exists then
            return nil
        end

        local OkRead, Raw = pcall(readfile, Path)
        if not OkRead or type(Raw) ~= "string" then
            return nil
        end

        local OkDecode, Data = pcall(HttpService.JSONDecode, HttpService, Raw)
        if not OkDecode or type(Data) ~= "table" then
            return nil
        end

        for _, Field in ipairs(ThemeFields) do
            if type(Data[Field]) ~= "string" then
                return nil
            end

            local OkColor = pcall(Color3.fromHex, Data[Field])
            if not OkColor then
                return nil
            end
        end

        return Data
    end

    function ThemeManager:SaveCustomTheme(File)
        File = Trim(File)

        if type(File) ~= "string" or not IsSafeThemeName(File) then
            return false, "invalid theme name"
        end

        if self.BuiltInThemes[File] then
            return false, "theme name conflicts with built-in theme"
        end

        local Options = GetOptions(self)
        if not Options then
            return false, "Library.Options is unavailable"
        end

        local Theme = {}

        for _, Field in ipairs(ThemeFields) do
            local Option = Options[Field]
            local Hex = Option and ColorToHex(Option.Value)

            if not Hex then
                return false, "invalid color option: " .. Field
            end

            Theme[Field] = Hex
        end

        local OkEncode, Encoded = pcall(HttpService.JSONEncode, HttpService, Theme)
        if not OkEncode then
            return false, "failed to encode theme"
        end

        local Path = self.Folder .. "/themes/" .. File .. ".json"
        local OkWrite, Err = pcall(writefile, Path, Encoded)

        if not OkWrite then
            return false, "failed to save theme: " .. tostring(Err)
        end

        return true
    end

    function ThemeManager:ReloadCustomThemes()
        local Ok, List = pcall(listfiles, self.Folder .. "/themes")
        if not Ok or type(List) ~= "table" then
            return {}
        end

        local Out = {}
        local Seen = {}

        for i = 1, #List do
            local File = tostring(List[i])
            local Name = File:match("([^/\\]+)%.json$")

            if Name and IsSafeThemeName(Name) and not self.BuiltInThemes[Name] and not Seen[Name] then
                if self:GetCustomTheme(Name) then
                    Seen[Name] = true
                    Out[#Out + 1] = Name
                end
            end
        end

        table.sort(Out)
        return Out
    end

    function ThemeManager:SetLibrary(Library)
        assert(type(Library) == "table", "ThemeManager:SetLibrary requires a Library")
        assert(type(Library.Options) == "table", "ThemeManager requires Library.Options")
        self.Library = Library
        return self
    end

    function ThemeManager:BuildFolderTree()
        if type(self.Folder) ~= "string" or self.Folder == "" then
            return false
        end

        local Parts = self.Folder:split("/")
        local Paths = {}

        for Index = 1, #Parts do
            local Path = table.concat(Parts, "/", 1, Index)
            if Path ~= "" then
                Paths[#Paths + 1] = Path
            end
        end

        Paths[#Paths + 1] = self.Folder .. "/themes"
        Paths[#Paths + 1] = self.Folder .. "/settings"

        for _, Path in ipairs(Paths) do
            local Ok, Exists = pcall(isfolder, Path)
            if Ok and not Exists then
                pcall(makefolder, Path)
            end
        end

        return true
    end

    function ThemeManager:SetFolder(Folder)
        if type(Folder) ~= "string" then
            return self
        end

        Folder = Trim(Folder)

        if Folder ~= "" and not Folder:find("%.%.", 1, true) and not Folder:find('[<>:"|%?%*]') then
            self.Folder = Folder:gsub('[/\\]+', '/')
            self:BuildFolderTree()
        end

        return self
    end

    function ThemeManager:CreateGroupBox(Tab)
        assert(self.Library, "Must set ThemeManager.Library first!")
        assert(Tab, "ThemeManager.CreateGroupBox requires a tab!")
        return Tab:AddLeftGroupbox("Themes")
    end

    function ThemeManager:ApplyToTab(Tab)
        assert(self.Library, "Must set ThemeManager.Library first!")
        local Groupbox = self:CreateGroupBox(Tab)
        self:CreateThemeManager(Groupbox)
        return Groupbox
    end

    function ThemeManager:ApplyToGroupbox(Groupbox)
        assert(self.Library, "Must set ThemeManager.Library first!")
        self:CreateThemeManager(Groupbox)
        return Groupbox
    end

    ThemeManager:BuildFolderTree()
end

return ThemeManager
