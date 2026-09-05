local HttpService = game:GetService("HttpService")

local Base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function Base64Encode(data)
    local result = {}
    local byteCount = #data

    for i = 1, byteCount, 3 do
        local b1, b2, b3 = data:byte(i, i + 2)
        b2 = b2 or 0
        b3 = b3 or 0

        local n = b1 * 65536 + b2 * 256 + b3

        local c1 = math.floor(n / 262144) % 64
        local c2 = math.floor(n / 4096) % 64
        local c3 = math.floor(n / 64) % 64
        local c4 = n % 64

        result[#result + 1] = Base64Chars:sub(c1 + 1, c1 + 1)
        result[#result + 1] = Base64Chars:sub(c2 + 1, c2 + 1)
        result[#result + 1] = (i + 1 <= byteCount) and Base64Chars:sub(c3 + 1, c3 + 1) or '='
        result[#result + 1] = (i + 2 <= byteCount) and Base64Chars:sub(c4 + 1, c4 + 1) or '='
    end

    return table.concat(result)
end

local Base64Lookup = {}
for i = 1, #Base64Chars do
    Base64Lookup[Base64Chars:sub(i, i)] = i - 1
end

local function Base64Decode(data)
    data = data:gsub('[^%w%+%/%=]', '')
    local result = {}
    local i = 1
    local len = #data

    while i <= len do
        local c1 = Base64Lookup[data:sub(i, i)]
        local c2 = Base64Lookup[data:sub(i + 1, i + 1)]
        local c3Char = data:sub(i + 2, i + 2)
        local c4Char = data:sub(i + 3, i + 3)
        local c3 = c3Char ~= '=' and Base64Lookup[c3Char] or nil
        local c4 = c4Char ~= '=' and Base64Lookup[c4Char] or nil

        if not c1 or not c2 then
            break
        end

        local n = c1 * 262144 + c2 * 4096 + (c3 or 0) * 64 + (c4 or 0)

        local b1 = math.floor(n / 65536) % 256
        local b2 = math.floor(n / 256) % 256
        local b3 = n % 256

        result[#result + 1] = string.char(b1)
        if c3 then result[#result + 1] = string.char(b2) end
        if c4 then result[#result + 1] = string.char(b3) end

        i = i + 4
    end

    return table.concat(result)
end

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
            local Ok, Result = pcall(Option.SetValueRGB, Option, Color)
            return Ok and Result ~= false
        end

        return false
    end

    ThemeManager.Folder = "LinoriaLibSettings"
    ThemeManager.Library = nil
    ThemeManager.DefaultTheme = "Default"
    ThemeManager.CurrentTheme = nil
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

        local BuiltIn = self.BuiltInThemes[Theme]
        local CustomData = BuiltIn and nil or self:GetCustomTheme(Theme)
        local Scheme = (BuiltIn and BuiltIn[2]) or CustomData

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
            self._ApplyingTheme = false
            return false
        end

        self.CurrentTheme = Theme
        self:ThemeUpdate()
        self._ApplyingTheme = false
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

        local Applied = self:ApplyTheme(Theme)
        if not Applied then
            Theme = self.DefaultTheme
            IsBuiltIn = true
            self:ApplyTheme(Theme)
        end

        if IsBuiltIn then
            local List = Options and Options.ThemeManager_ThemeList
            local CustomList = Options and Options.ThemeManager_CustomThemeList
            if List and type(List.SetValue) == "function" and List.Value ~= Theme then
                pcall(List.SetValue, List, Theme)
            end
            if CustomList and type(CustomList.SetValue) == "function" and CustomList.Value ~= nil then
                pcall(CustomList.SetValue, CustomList, nil)
            end
        else
            local List = Options and Options.ThemeManager_CustomThemeList
            local BuiltInList = Options and Options.ThemeManager_ThemeList
            if List and type(List.SetValue) == "function" and List.Value ~= Theme then
                pcall(List.SetValue, List, Theme)
            end
            if BuiltInList and type(BuiltInList.SetValue) == "function" and BuiltInList.Value ~= nil then
                pcall(BuiltInList.SetValue, BuiltInList, nil)
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

        if not self:BuildFolderTree() then
            return false, "failed to prepare theme folder"
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

        local BuiltInList = self:GetOption("ThemeManager_ThemeList")
        if BuiltInList and type(BuiltInList.OnChanged) == "function" then
            BuiltInList:OnChanged(function(Value)
                if not self._ApplyingTheme and type(Value) == "string" and Value ~= "" then
                    self:ApplyTheme(Value)
                end
            end)
        end

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

        local CustomThemeList = self:GetOption("ThemeManager_CustomThemeList")
        if CustomThemeList and type(CustomThemeList.OnChanged) == "function" then
            CustomThemeList:OnChanged(function(Value)
                if not self._ApplyingTheme and type(Value) == "string" and Value ~= "" then
                    self:ApplyTheme(Value)
                end
            end)
        end

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

        Groupbox:AddDivider()

        Groupbox:AddButton("Export current theme to clipboard", function()
            local ExportString, Err = self:Export()
            if not ExportString then
                Notify(self, "Failed to export theme: " .. tostring(Err), 3)
                return
            end

            local Clip = setclipboard or toclipboard
            if type(Clip) ~= "function" then
                Notify(self, "Theme exported, but your executor lacks clipboard support. Copy it from the Import box below.", 4)
                return
            end

            Notify(self, "Theme copied to clipboard! Share it with anyone.")
        end)

        Groupbox:AddInput("ThemeManager_ImportString", {
            Text = "Theme string",
            Placeholder = "Paste an exported theme string here...",
            Default = ""
        })

        -- Import always applies live only, never touching disk. This is
        -- deliberately independent of whatever is currently sitting in
        -- the "Custom theme name" input (used by the unrelated "Save
        -- theme" button above) -- reusing that leftover text here would
        -- mean an import could silently overwrite a saved theme file the
        -- person never intended to touch, just because they'd typed a
        -- name into that box earlier for something else. Saving an
        -- imported theme is a separate, explicit action below.
        Groupbox:AddButton("Import from string", function()
            local Input = self:GetOption("ThemeManager_ImportString")
            local Raw = Input and Input.Value

            local Ok, Err = self:Import(Raw)
            if not Ok then
                Notify(self, "Failed to import theme: " .. tostring(Err), 3)
                return
            end

            Notify(self, "Theme imported")
        end)

        Groupbox:AddButton("Import from clipboard", function()
            local GetClip = getclipboard or readclipboard
            if type(GetClip) ~= "function" then
                Notify(self, "Your executor does not support reading the clipboard. Paste it into the box instead.", 3)
                return
            end

            local OkRead, ClipContent = pcall(GetClip)
            if not OkRead or type(ClipContent) ~= "string" or ClipContent == "" then
                Notify(self, "Clipboard is empty or unreadable", 3)
                return
            end

            local Ok, Err = self:Import(ClipContent)
            if not Ok then
                Notify(self, "Failed to import theme: " .. tostring(Err), 3)
                return
            end

            Notify(self, "Theme imported from clipboard")
        end)

        -- Explicit, separate action for "import this string AND save it
        -- as a named custom theme" -- requires the name box to actually
        -- be filled in on purpose, rather than inferring intent to save
        -- from whatever text happens to be sitting there.
        Groupbox:AddButton("Import and save as", function()
            local Input = self:GetOption("ThemeManager_ImportString")
            local NameOption = self:GetOption("ThemeManager_CustomThemeName")
            local Raw = Input and Input.Value
            local Name = NameOption and NameOption.Value

            if type(Name) ~= "string" or Trim(Name) == "" then
                Notify(self, "Enter a custom theme name first", 2)
                return
            end

            local Ok, Result = self:Import(Raw, Name)
            if not Ok then
                Notify(self, "Failed to import theme: " .. tostring(Result), 3)
                return
            end

            local List = self:GetOption("ThemeManager_CustomThemeList")
            if List and type(List.SetValues) == "function" then
                pcall(List.SetValues, List, self:ReloadCustomThemes())
            end
            if List and type(List.SetValue) == "function" then
                pcall(List.SetValue, List, Result)
            end

            Notify(self, string.format("Imported and saved theme %q", Result))
        end)

        local function UpdateTheme()
            if self._ApplyingTheme then
                return
            end

            self.CurrentTheme = nil
            local BuiltInList = Options.ThemeManager_ThemeList
            local CustomList = Options.ThemeManager_CustomThemeList
            if BuiltInList and type(BuiltInList.SetValue) == "function" and BuiltInList.Value ~= nil then
                pcall(BuiltInList.SetValue, BuiltInList, nil)
            end
            if CustomList and type(CustomList.SetValue) == "function" and CustomList.Value ~= nil then
                pcall(CustomList.SetValue, CustomList, nil)
            end
            self:ThemeUpdate()
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

    -- Only version prefixes this ThemeManager actually knows how to read.
    -- Deliberately a different prefix from SaveManager's 'CREU' export
    -- strings, so a string copy-pasted into the wrong box (theme string
    -- into config import, or vice versa) is rejected immediately instead
    -- of being decoded as if it were the right kind of data.
    local KnownThemeExportPrefixes = { CRUT1 = true }
    ThemeManager.MaxImportStringLength = 20000

    function ThemeManager:Export(Theme)
        Theme = Trim(Theme)

        local Scheme
        if type(Theme) == "string" and Theme ~= "" then
            if not IsSafeThemeName(Theme) then
                return nil, "invalid theme name"
            end

            local BuiltIn = self.BuiltInThemes[Theme]
            Scheme = (BuiltIn and BuiltIn[2]) or self:GetCustomTheme(Theme)

            if type(Scheme) ~= "table" then
                return nil, "theme does not exist"
            end
        else
            -- No name given: export the colors currently applied, the
            -- same source ApplyTheme reads from and SaveCustomTheme
            -- writes from, so "export current" always matches what the
            -- user is actually looking at right now.
            local Options = GetOptions(self)
            Scheme = {}

            for _, Field in ipairs(ThemeFields) do
                local Option = Options and Options[Field]
                local Hex = Option and ColorToHex(Option.Value)
                    or (IsColor(self.Library[Field]) and ColorToHex(self.Library[Field]))

                if not Hex then
                    return nil, "invalid color option: " .. Field
                end

                Scheme[Field] = Hex
            end
        end

        -- Re-validate every field is a hex string Color3.fromHex accepts,
        -- regardless of source (built-in table, theme file, or live
        -- options) -- this is the same shape check GetCustomTheme applies
        -- to files loaded from disk, applied here uniformly before we
        -- ever hand the data out as a shareable string.
        local Data = {}
        for _, Field in ipairs(ThemeFields) do
            local Hex = Scheme[Field]
            if type(Hex) ~= "string" then
                return nil, "missing color: " .. Field
            end

            local Ok = pcall(Color3.fromHex, Hex)
            if not Ok then
                return nil, "invalid color: " .. Field
            end

            Data[Field] = Hex
        end

        local OkEncode, Encoded = pcall(HttpService.JSONEncode, HttpService, Data)
        if not OkEncode then
            return nil, "failed to encode theme"
        end

        local OkB64, B64 = pcall(Base64Encode, Encoded)
        if not OkB64 then
            return nil, "failed to encode string"
        end

        local ExportString = "CRUT1:" .. B64

        local Clip = setclipboard or toclipboard
        if type(Clip) == "function" then
            pcall(Clip, ExportString)
        end

        return ExportString
    end

    function ThemeManager:Import(ExportString, SaveAsName)
        if type(ExportString) ~= "string" then
            return false, "no theme string provided"
        end

        ExportString = Trim(ExportString)
        if ExportString == "" then
            return false, "no theme string provided"
        end

        local MaxLen = math.max(1, math.floor(tonumber(self.MaxImportStringLength) or 20000))
        if #ExportString > MaxLen then
            return false, "theme string is too long"
        end

        local Payload = ExportString
        local Prefix = ExportString:match("^(CRUT%d+):")
        if Prefix then
            if not KnownThemeExportPrefixes[Prefix] then
                return false, "unsupported theme version: " .. Prefix
            end
            Payload = ExportString:sub(#Prefix + 2)
        end

        if Payload == "" then
            return false, "invalid theme string"
        end

        local OkB64, Raw = pcall(Base64Decode, Payload)
        if not OkB64 or type(Raw) ~= "string" or Raw == "" then
            return false, "invalid theme string"
        end

        local OkDecode, Decoded = pcall(HttpService.JSONDecode, HttpService, Raw)
        if not OkDecode or type(Decoded) ~= "table" then
            return false, "invalid or corrupted theme string"
        end

        -- Every field must be present and a hex string Color3.fromHex
        -- accepts before we touch anything -- reject the whole import
        -- rather than applying a partial/mismatched theme.
        for _, Field in ipairs(ThemeFields) do
            if type(Decoded[Field]) ~= "string" then
                return false, "theme string is missing " .. Field
            end

            local Ok = pcall(Color3.fromHex, Decoded[Field])
            if not Ok then
                return false, "theme string has an invalid " .. Field
            end
        end

        if type(SaveAsName) == "string" and Trim(SaveAsName) ~= "" then
            local Name = Trim(SaveAsName)
            if not IsSafeThemeName(Name) then
                return false, "invalid theme name"
            end
            if self.BuiltInThemes[Name] then
                return false, "theme name conflicts with built-in theme"
            end

            local Clean = {}
            for _, Field in ipairs(ThemeFields) do
                Clean[Field] = Decoded[Field]
            end

            local OkEncode, Encoded = pcall(HttpService.JSONEncode, HttpService, Clean)
            if not OkEncode then
                return false, "failed to encode theme"
            end

            if not self:BuildFolderTree() then
                return false, "failed to prepare theme folder"
            end

            local Path = self.Folder .. "/themes/" .. Name .. ".json"
            local OkWrite, Err = pcall(writefile, Path, Encoded)
            if not OkWrite then
                return false, "failed to save theme: " .. tostring(Err)
            end

            if not self:ApplyTheme(Name) then
                return false, "saved theme, but failed to apply it"
            end

            return true, Name
        end

        -- No name given: apply directly without persisting to disk. This
        -- mirrors ApplyTheme's field loop rather than calling ApplyTheme
        -- itself, since ApplyTheme only knows how to look up themes by
        -- name (built-in or already-saved custom) -- an unsaved imported
        -- theme has neither.
        self._ApplyingTheme = true

        local Options = GetOptions(self)
        local Changed = false

        for _, Field in ipairs(ThemeFields) do
            local Ok, Color = pcall(Color3.fromHex, Decoded[Field])
            if Ok and IsColor(Color) then
                self.Library[Field] = Color
                if Options then
                    SetColorOption(Options[Field], Color)
                end
                Changed = true
            end
        end

        self._ApplyingTheme = false

        if not Changed then
            return false, "theme string had no usable colors"
        end

        self.CurrentTheme = nil

        -- Neither dropdown reflects an unsaved, directly-applied theme
        -- (it has no name to match), so clear their selection the same
        -- way the manual color-picker path does via UpdateTheme --
        -- otherwise the UI would keep showing a stale theme name while
        -- the actual colors have already changed underneath it.
        if Options then
            local BuiltInList = Options.ThemeManager_ThemeList
            local CustomList = Options.ThemeManager_CustomThemeList
            if BuiltInList and type(BuiltInList.SetValue) == "function" and BuiltInList.Value ~= nil then
                pcall(BuiltInList.SetValue, BuiltInList, nil)
            end
            if CustomList and type(CustomList.SetValue) == "function" and CustomList.Value ~= nil then
                pcall(CustomList.SetValue, CustomList, nil)
            end
        end

        self:ThemeUpdate()
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

        Library.ThemeManager = self
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

