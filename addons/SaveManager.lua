local HttpService = game:GetService('HttpService')

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

local SaveManager = {} do
    SaveManager.Folder = 'LinoriaLibSettings'
    SaveManager.Ignore = {}
    SaveManager.LoadBatchSize = 20
    SaveManager.MaxLoadObjects = 2000
    SaveManager._ConfigListCache = nil
    SaveManager.Loading = false
    SaveManager.CurrentConfig = nil
    SaveManager.Library = nil
    SaveManager.AutoloadLabel = nil

    local function Trim(value)
        if type(value) ~= 'string' then
            return value
        end
        return value:gsub('^%s+', ''):gsub('%s+$', '')
    end

    local function IsSafeName(name)
        if type(name) ~= 'string' then return false end
        name = Trim(name)
        if name == '' then return false end
        if name:find('[/\\]') then return false end
        if name:find('%.%.', 1, true) then return false end
        if name:find('[<>:"|%?%*]') then return false end
        if name:sub(1, 1) == '.' then return false end
        if name:sub(-5):lower() == '.json' then return false end
        return true
    end

    local function EnsureFolderTree(folder)
        if type(folder) ~= 'string' or folder == '' then
            return false
        end

        local normalized = folder:gsub('[/\\]+', '/')
        normalized = normalized:gsub('/+$', '')
        if normalized == '' then
            return false
        end

        local current = ''
        for part in normalized:gmatch('[^/]+') do
            current = current == '' and part or (current .. '/' .. part)
            local ok, exists = pcall(isfolder, current)
            if ok and exists then
                continue
            end
            pcall(makefolder, current)
        end

        return true
    end

    local function GetOptions()
        local library = SaveManager.Library
        if library and type(library.Options) == 'table' then
            return library.Options
        end

        if type(getgenv) == 'function' then
            local ok, env = pcall(getgenv)
            if ok and type(env) == 'table' and type(env.Options) == 'table' then
                return env.Options
            end
        end

        return nil
    end

    local function GetToggles()
        local library = SaveManager.Library
        if library and type(library.Toggles) == 'table' then
            return library.Toggles
        end

        if type(getgenv) == 'function' then
            local ok, env = pcall(getgenv)
            if ok and type(env) == 'table' and type(env.Toggles) == 'table' then
                return env.Toggles
            end
        end

        return nil
    end

    local function Notify(message, duration)
        local library = SaveManager.Library
        if library and type(library.Notify) == 'function' then
            pcall(library.Notify, library, tostring(message), duration)
        end
    end

    -- Imported/loaded config data is untrusted input (it may come from a
    -- pasted string authored by someone else). `idx` must be a non-empty
    -- string before it's used to index Options/Toggles, otherwise a
    -- malformed or hand-edited config could pass a table/number/boolean
    -- through as a key.
    local function IsValidIdx(idx)
        return type(idx) == 'string' and idx ~= ''
    end

    local KeyPickerModes = { Toggle = true, Always = true, Hold = true }

    SaveManager.Parser = {
        Toggle = {
            Save = function(idx, object)
                return { type = 'Toggle', idx = idx, value = object.Value == true }
            end,
            Load = function(idx, data)
                if not IsValidIdx(idx) or type(data) ~= 'table' then
                    return
                end

                local toggles = GetToggles()
                local toggle = toggles and toggles[idx]
                if toggle and type(toggle.SetValue) == 'function' then
                    toggle:SetValue(data.value == true)
                end
            end,
        },
        Slider = {
            Save = function(idx, object)
                local value = object.Value
                if type(value) ~= 'number' and type(value) ~= 'string' then
                    return nil
                end
                return { type = 'Slider', idx = idx, value = tostring(value) }
            end,
            Load = function(idx, data)
                if not IsValidIdx(idx) or type(data) ~= 'table' then
                    return
                end

                -- data.value must resolve to a real number; a table, nil,
                -- or non-numeric string from a hand-edited config should
                -- be rejected here rather than silently passed through.
                local numericValue = tonumber(data.value)
                if not numericValue then
                    return
                end

                local options = GetOptions()
                local option = options and options[idx]
                if option and type(option.SetValue) == 'function' then
                    option:SetValue(numericValue)
                end
            end,
        },
        Dropdown = {
            Save = function(idx, object)
                local data = {
                    type = 'Dropdown',
                    idx = idx,
                    value = object.Value,
                    multi = object.Multi == true,
                }

                -- PriorityDropdown (AddPriorityDropdown) reuses Type ==
                -- 'Dropdown' but tracks an additional ordered list
                -- (`Order`) on top of the plain selection set, and its
                -- overridden `SetValue` expects that ordered array back,
                -- not the unordered `{[value]=true}` set. Persist `Order`
                -- separately so re-ordering survives a save/load round
                -- trip instead of silently collapsing to whatever order
                -- `next()` happens to iterate the set in.
                if object.Priority == true and type(object.Order) == 'table' then
                    local order = {}
                    for i, v in ipairs(object.Order) do
                        order[i] = v
                    end
                    data.order = order
                    data.priority = true
                end

                return data
            end,
            Load = function(idx, data)
                if not IsValidIdx(idx) or type(data) ~= 'table' then
                    return
                end

                local options = GetOptions()
                local option = options and options[idx]
                if not option or type(option.SetValue) ~= 'function' then
                    return
                end

                local isMulti = data.multi == true

                -- PriorityDropdown: prefer the ordered `order` list when
                -- present (current-format configs). `SetValue` on a
                -- PriorityDropdown accepts either an ordered array or an
                -- unordered set, so a config saved before this field
                -- existed still falls through to the normal multi-select
                -- handling below instead of failing to load.
                if data.priority == true and type(data.order) == 'table' then
                    local cleanedOrder = {}
                    for _, v in ipairs(data.order) do
                        if type(v) == 'string' then
                            cleanedOrder[#cleanedOrder + 1] = v
                        end
                    end
                    option:SetValue(cleanedOrder)
                    return
                end

                local value = data.value

                if isMulti then
                    -- Multi-select expects a set table of { [string] = true }.
                    -- A pasted/edited config could hand us a plain string,
                    -- a number, or a set with non-string/non-boolean
                    -- entries (e.g. after a lossy JSON round-trip); rebuild
                    -- a clean set instead of forwarding it as-is.
                    if type(value) ~= 'table' then
                        return
                    end

                    local cleaned = {}
                    local any = false
                    for key, flag in next, value do
                        if type(key) == 'string' and flag == true then
                            cleaned[key] = true
                            any = true
                        end
                    end

                    -- An explicitly empty multi-selection is valid (clears
                    -- the dropdown); only bail out if nothing usable came
                    -- through AND the source table wasn't already empty.
                    if not any and next(value) ~= nil then
                        return
                    end

                    option:SetValue(cleaned)
                else
                    -- Single-select expects a bare string, or nil to clear.
                    if value ~= nil and type(value) ~= 'string' then
                        return
                    end

                    option:SetValue(value)
                end
            end,
        },
        ColorPicker = {
            Save = function(idx, object)
                local value = object.Value
                local ok, hex = pcall(function() return value:ToHex() end)
                if not ok then
                    return nil
                end
                return {
                    type = 'ColorPicker',
                    idx = idx,
                    value = hex,
                    transparency = tonumber(object.Transparency) or 0,
                }
            end,
            Load = function(idx, data)
                if not IsValidIdx(idx) or type(data) ~= 'table' then
                    return
                end

                local options = GetOptions()
                local option = options and options[idx]
                if not option or type(option.SetValueRGB) ~= 'function' or type(data.value) ~= 'string' then
                    return
                end

                -- Require a plausible hex string (3-8 hex digits, optional
                -- leading '#') before handing it to Color3.fromHex, rather
                -- than relying solely on pcall to catch malformed input.
                local hex = data.value
                if not hex:match('^#?%x+$') or #(hex:gsub('^#', '')) < 3 then
                    return
                end

                local ok, color = pcall(Color3.fromHex, hex)
                if not ok or not color then
                    return
                end

                local transparency = tonumber(data.transparency) or 0
                transparency = math.clamp(transparency, 0, 1)

                option:SetValueRGB(color, transparency)
            end,
        },
        KeyPicker = {
            Save = function(idx, object)
                return {
                    type = 'KeyPicker',
                    idx = idx,
                    mode = object.Mode,
                    key = object.Value,
                }
            end,
            Load = function(idx, data)
                if not IsValidIdx(idx) or type(data) ~= 'table' then
                    return
                end

                local options = GetOptions()
                local option = options and options[idx]
                if not option or type(option.SetValue) ~= 'function' then
                    return
                end

                -- key must be a non-empty string (or 'None'); mode must be
                -- one of the three modes Library actually recognizes.
                -- `data.value` is kept only as a legacy fallback for
                -- configs written before `key` existed.
                local key = data.key or data.value
                if type(key) ~= 'string' or key == '' then
                    key = 'None'
                end

                local mode = data.mode
                if type(mode) ~= 'string' or not KeyPickerModes[mode] then
                    mode = 'Toggle'
                end

                option:SetValue({ key, mode })
            end,
        },
        Input = {
            Save = function(idx, object)
                local value = object.Value
                if value ~= nil and type(value) ~= 'string' and type(value) ~= 'number' and type(value) ~= 'boolean' then
                    return nil
                end
                return { type = 'Input', idx = idx, text = tostring(value or '') }
            end,
            Load = function(idx, data)
                if not IsValidIdx(idx) or type(data) ~= 'table' then
                    return
                end

                local options = GetOptions()
                local option = options and options[idx]
                if option and type(data.text) == 'string' and type(option.SetValue) == 'function' then
                    option:SetValue(data.text)
                end
            end,
        },
    }

    function SaveManager:SetIgnoreIndexes(list)
        if type(list) ~= 'table' then
            return self
        end

        for _, key in next, list do
            self.Ignore[key] = true
        end
        return self
    end

    function SaveManager:SetFolder(folder)
        if type(folder) ~= 'string' then
            return self
        end

        folder = Trim(folder)
        if folder == '' or folder:find('%.%.', 1, true) or folder:find('[<>:"|%?%*]') then
            return self
        end

        self.Folder = folder:gsub('[/\\]+', '/')
        self._ConfigListCache = nil
        self.CurrentConfig = nil
        self:BuildFolderTree()
        return self
    end

    function SaveManager:SetSubFolder(folder)
        if type(folder) ~= 'string' then
            return self.Folder
        end

        local sub = Trim(folder):gsub('^[/\\]+', ''):gsub('[/\\]+$', '')
        if sub == '' or sub:find('%.%.', 1, true) or sub:find('[/\\]') or sub:find('[<>:"|%?%*]') then
            return self.Folder
        end

        self.Folder = self.Folder:gsub('[/\\]+$', '') .. '/' .. sub
        self._ConfigListCache = nil
        self.CurrentConfig = nil
        self:BuildFolderTree()
        return self.Folder
    end

    function SaveManager:_BuildData()
        local options = GetOptions()
        local toggles = GetToggles()
        if not options or not toggles then
            return nil, 'Library.Options/Toggles unavailable'
        end

        local data = { objects = {} }

        local library = self.Library
        if library and type(library.ThemeManager) == 'table' then
            local currentTheme = library.ThemeManager.CurrentTheme
            if type(currentTheme) == 'string' and currentTheme ~= '' then
                data.theme = currentTheme
            end
        end

        for idx, toggle in next, toggles do
            if type(idx) ~= 'string' or self.Ignore[idx] then
                continue
            end

            local parser = type(toggle) == 'table' and self.Parser[toggle.Type]
            if parser and type(parser.Save) == 'function' then
                local ok, object = pcall(parser.Save, idx, toggle)
                if not ok then
                    return nil, 'failed to serialize toggle ' .. tostring(idx)
                end
                if object then
                    data.objects[#data.objects + 1] = object
                end
            end
        end

        for idx, option in next, options do
            if type(idx) ~= 'string' or self.Ignore[idx] then
                continue
            end

            local parser = type(option) == 'table' and self.Parser[option.Type]
            if parser and type(parser.Save) == 'function' then
                local ok, object = pcall(parser.Save, idx, option)
                if not ok then
                    return nil, 'failed to serialize option ' .. tostring(idx)
                end
                if object then
                    data.objects[#data.objects + 1] = object
                end
            end
        end

        return data
    end

    function SaveManager:Save(name)
        if name == nil then
            name = self.CurrentConfig
        end

        name = Trim(name)
        if not IsSafeName(name) then
            return false, 'invalid config name'
        end

        if self.Loading then
            return false, 'config loading already in progress'
        end

        local data, buildErr = self:_BuildData()
        if not data then
            return false, buildErr
        end

        EnsureFolderTree(self.Folder .. '/settings')
        local fullPath = self.Folder .. '/settings/' .. name .. '.json'

        local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not success then
            return false, 'failed to encode data'
        end

        local okWrite, writeErr = pcall(writefile, fullPath, encoded)
        if not okWrite then
            return false, 'failed to write config: ' .. tostring(writeErr)
        end

        self.CurrentConfig = name
        self._ConfigListCache = nil
        return true
    end

    function SaveManager:Delete(name)
        name = Trim(name)
        if not IsSafeName(name) then
            return false, 'invalid config name'
        end

        local file = self.Folder .. '/settings/' .. name .. '.json'
        local okExists, exists = pcall(isfile, file)
        if not okExists or not exists then
            return false, 'invalid file'
        end

        local success, err = pcall(delfile, file)
        if not success then
            return false, 'failed to delete file: ' .. tostring(err)
        end

        local autoloadPath = self.Folder .. '/settings/autoload.txt'
        local okRead, current = pcall(readfile, autoloadPath)
        if okRead and Trim(current) == name then
            pcall(delfile, autoloadPath)
            if self.AutoloadLabel and type(self.AutoloadLabel.SetText) == 'function' then
                self.AutoloadLabel:SetText('Current autoload config: none')
            end
        end

        if self.CurrentConfig == name then
            self.CurrentConfig = nil
        end

        self._ConfigListCache = nil
        return true
    end

    function SaveManager:_ApplyData(decoded, onDone)
        if self.Loading then
            if onDone then onDone(false, 'config loading already in progress') end
            return false, 'config loading already in progress'
        end

        if type(decoded) ~= 'table' or type(decoded.objects) ~= 'table' then
            if onDone then onDone(false, 'decode error') end
            return false, 'decode error'
        end

        -- Guard against a malformed/malicious config claiming an
        -- unreasonable number of objects (e.g. a huge array of junk
        -- entries), which would otherwise stall the UI thread across many
        -- batches even though each individual entry is cheap to skip.
        local maxObjects = math.max(1, math.floor(tonumber(self.MaxLoadObjects) or 2000))
        if #decoded.objects > maxObjects then
            local err = string.format('config has too many entries (%d > %d)', #decoded.objects, maxObjects)
            if onDone then onDone(false, err) end
            return false, err
        end

        self.Loading = true

        task.spawn(function()
            local library = self.Library
            local previousBatch = library and library.BatchUpdating or false
            local parserErrors = {}
            local ok, loadError = xpcall(function()
                if library then
                    library.BatchUpdating = true
                end

                local batch = math.max(1, math.floor(tonumber(self.LoadBatchSize) or 20))
                local processed = 0

                for _, object in next, decoded.objects do
                    if type(object) == 'table' then
                        local parser = self.Parser[object.type]
                        if parser and type(parser.Load) == 'function' then
                            local parserOk, parserErr = pcall(parser.Load, object.idx, object)
                            if not parserOk then
                                parserErrors[#parserErrors + 1] = tostring(object.idx) .. ': ' .. tostring(parserErr)
                            end
                        end
                    end

                    processed += 1
                    if processed % batch == 0 then
                        if library then library.BatchUpdating = previousBatch end
                        task.wait()
                        if library then library.BatchUpdating = true end
                    end
                end

                -- Normalize a missing/blank theme to nil so we don't call
                -- ApplyTheme('') and surface a spurious "theme unavailable"
                -- notification for configs that simply have no theme set.
                local savedTheme = type(decoded.theme) == 'string' and Trim(decoded.theme) or nil
                if savedTheme == '' then
                    savedTheme = nil
                end
                local manager = library and library.ThemeManager
                if manager and savedTheme and type(manager.ApplyTheme) == 'function' then
                    local themeOk, applied = pcall(manager.ApplyTheme, manager, savedTheme)
                    if not themeOk or applied ~= true then
                        Notify('Saved theme ' .. tostring(savedTheme) .. ' is unavailable; kept config colors.', 3)
                    end
                end
            end, function(err)
                return tostring(err)
            end)

            if ok and #parserErrors > 0 then
                ok = false
                loadError = 'one or more config entries failed: ' .. table.concat(parserErrors, '; ')
            end

            if library then
                library.BatchUpdating = previousBatch
                if type(library.RefreshBatchedUI) == 'function' then
                    pcall(library.RefreshBatchedUI, library)
                elseif type(library.UpdateDependencyBoxes) == 'function' then
                    pcall(library.UpdateDependencyBoxes, library)
                end
            end

            self.Loading = false
            if not ok then
                Notify('Failed to finish loading config: ' .. tostring(loadError), 3)
            end
            if onDone then onDone(ok, loadError) end
        end)

        return true
    end

    function SaveManager:Load(name)
        name = Trim(name)
        if not IsSafeName(name) then
            return false, 'invalid config name'
        end

        if self.Loading then
            return false, 'config loading already in progress'
        end

        local file = self.Folder .. '/settings/' .. name .. '.json'
        local okExists, exists = pcall(isfile, file)
        if not okExists or not exists then
            return false, 'invalid file'
        end

        local okRead, raw = pcall(readfile, file)
        if not okRead or type(raw) ~= 'string' then
            return false, 'read error'
        end

        local success, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if not success or type(decoded) ~= 'table' or type(decoded.objects) ~= 'table' then
            return false, 'decode error'
        end

        return self:_ApplyData(decoded, function(ok)
            if ok then
                self.CurrentConfig = name
            end
        end)
    end

    function SaveManager:Export()
        local data, buildErr = self:_BuildData()
        if not data then
            return nil, buildErr
        end

        local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not success then
            return nil, 'failed to encode data'
        end

        local okEncode, b64 = pcall(Base64Encode, encoded)
        if not okEncode then
            return nil, 'failed to encode string'
        end

        local exportString = 'CREU1:' .. b64

        local clip = setclipboard or toclipboard
        if type(clip) == 'function' then
            pcall(clip, exportString)
        end

        return exportString
    end

    -- Only version prefixes this SaveManager actually knows how to read.
    -- A future/foreign prefix (e.g. 'CREU2:') must be rejected explicitly
    -- rather than silently accepted and decoded as if it were CREU1 --
    -- schema drift between versions could otherwise apply garbage values.
    local KnownExportPrefixes = { CREU1 = true }

    -- Hard ceiling on the raw import string length, before any decoding
    -- work happens. This is a cheap first line of defense against being
    -- handed an absurdly large paste (accidental or otherwise) that would
    -- waste time/memory in Base64Decode/JSONDecode before validation.
    SaveManager.MaxImportStringLength = 200000

    function SaveManager:Import(exportString)
        if type(exportString) ~= 'string' then
            return false, 'no config string provided'
        end

        exportString = Trim(exportString)
        if exportString == '' then
            return false, 'no config string provided'
        end

        local maxLen = math.max(1, math.floor(tonumber(self.MaxImportStringLength) or 200000))
        if #exportString > maxLen then
            return false, 'config string is too long'
        end

        local payload = exportString
        local prefix = exportString:match('^(CREU%d+):')
        if prefix then
            if not KnownExportPrefixes[prefix] then
                return false, 'unsupported config version: ' .. prefix
            end
            payload = exportString:sub(#prefix + 2)
        end

        if payload == '' then
            return false, 'invalid config string'
        end

        local okDecode64, raw = pcall(Base64Decode, payload)
        if not okDecode64 or type(raw) ~= 'string' or raw == '' then
            return false, 'invalid config string'
        end

        local okDecode, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if not okDecode or type(decoded) ~= 'table' or type(decoded.objects) ~= 'table' then
            return false, 'invalid or corrupted config string'
        end

        return self:_ApplyData(decoded, function(ok)
            if ok then
                self.CurrentConfig = nil
            end
        end)
    end

    function SaveManager:IgnoreThemeSettings()
        return self:SetIgnoreIndexes({
            'BackgroundColor', 'MainColor', 'AccentColor', 'OutlineColor', 'FontColor',
            'ThemeManager_ThemeList', 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName',
            'ThemeManager_ImportString',
        })
    end

    function SaveManager:BuildFolderTree()
        EnsureFolderTree(self.Folder)
        EnsureFolderTree(self.Folder .. '/themes')
        EnsureFolderTree(self.Folder .. '/settings')
        return self
    end

    function SaveManager:RefreshConfigList(force)
        if not force and self._ConfigListCache then
            return table.clone(self._ConfigListCache)
        end

        local ok, list = pcall(listfiles, self.Folder .. '/settings')
        if not ok or type(list) ~= 'table' then
            self._ConfigListCache = {}
            return {}
        end

        local out = {}
        local seen = {}

        for i = 1, #list do
            local file = tostring(list[i])
            local name = file:match('([^/\\]+)%.json$')
            if name and IsSafeName(name) and not seen[name] then
                seen[name] = true
                out[#out + 1] = name
            end
        end

        table.sort(out)
        self._ConfigListCache = out
        return table.clone(out)
    end

    function SaveManager:SetLibrary(library)
        assert(type(library) == 'table', 'Must set SaveManager.Library')
        assert(type(library.Options) == 'table' and type(library.Toggles) == 'table', 'SaveManager requires Library.Options and Library.Toggles')

        self.Library = library
        library.SaveManager = self
        return self
    end

    function SaveManager:LoadAutoloadConfig()
        local path = self.Folder .. '/settings/autoload.txt'
        local okExists, exists = pcall(isfile, path)
        if not okExists or not exists then
            return false, 'no autoload config'
        end

        local okRead, rawName = pcall(readfile, path)
        if not okRead or type(rawName) ~= 'string' then
            Notify('Invalid autoload config', 3)
            return false, 'read error'
        end

        local name = Trim(rawName)
        if not IsSafeName(name) then
            Notify('Invalid autoload config', 3)
            return false, 'invalid autoload config'
        end

        local success, err = self:Load(name)
        if not success then
            Notify('Failed to load autoload config: ' .. tostring(err), 3)
            return false, err
        end

        Notify(string.format('Auto loaded config %q', name))
        return true
    end

    function SaveManager:BuildConfigSection(tab)
        assert(self.Library, 'Must set SaveManager.Library')
        assert(tab, 'Must set a valid tab')

        local section = tab:AddRightGroupbox('Configuration')

        section:AddInput('SaveManager_ConfigName', { Text = 'Config name', Placeholder = 'Config name' })
        section:AddDropdown('SaveManager_ConfigList', {
            Text = 'Config list',
            Values = self:RefreshConfigList(),
            AllowNull = true,
            Default = nil,
            Searchable = true,
            MaxVisibleItems = 8,
            ItemHeight = 18,
        })

        section:AddDivider()

        section:AddButton('Create config', function()
            local options = GetOptions()
            local input = options and options.SaveManager_ConfigName
            local name = input and input.Value

            local success, err = self:Save(name)
            if not success then
                return Notify('Failed to save config: ' .. tostring(err), 3)
            end

            local list = options and options.SaveManager_ConfigList
            if list then
                pcall(list.SetValues, list, self:RefreshConfigList(true))
                pcall(list.SetValue, list, name)
            end

            Notify(string.format('Created config %q', name))
        end)

        section:AddButton('Load config', function()
            local options = GetOptions()
            local list = options and options.SaveManager_ConfigList
            local name = list and list.Value

            local success, err = self:Load(name)
            if not success then
                return Notify('Failed to load config: ' .. tostring(err), 3)
            end

            Notify(string.format('Loading config %q...', name))
        end)

        section:AddButton('Overwrite config', function()
            local options = GetOptions()
            local list = options and options.SaveManager_ConfigList
            local name = list and list.Value

            local success, err = self:Save(name)
            if not success then
                return Notify('Failed to overwrite config: ' .. tostring(err), 3)
            end

            Notify(string.format('Overwrote config %q', name))
        end)

        section:AddButton({
            Text = 'Delete config',
            DoubleClick = true,
            Func = function()
                local options = GetOptions()
                local list = options and options.SaveManager_ConfigList
                local name = list and list.Value

                local success, err = self:Delete(name)
                if not success then
                    return Notify('Failed to delete config: ' .. tostring(err), 3)
                end

                if list then
                    pcall(list.SetValues, list, self:RefreshConfigList(true))
                    pcall(list.SetValue, list, nil)
                end

                Notify(string.format('Deleted config %q', name))
            end,
        })

        section:AddButton('Refresh list', function()
            local options = GetOptions()
            local list = options and options.SaveManager_ConfigList
            if list then
                pcall(list.SetValues, list, self:RefreshConfigList(true))
                pcall(list.SetValue, list, nil)
            end
        end)

        section:AddButton('Set as autoload', function()
            local options = GetOptions()
            local list = options and options.SaveManager_ConfigList
            local name = list and list.Value
            name = Trim(name)

            if not IsSafeName(name) then
                return Notify('Select a config first', 2)
            end

            local path = self.Folder .. '/settings/autoload.txt'
            local okWrite, writeErr = pcall(writefile, path, name)
            if not okWrite then
                return Notify('Failed to set autoload: ' .. tostring(writeErr), 3)
            end

            self.CurrentConfig = name
            if self.AutoloadLabel and type(self.AutoloadLabel.SetText) == 'function' then
                self.AutoloadLabel:SetText('Current autoload config: ' .. name)
            end

            Notify(string.format('Set %q to auto load', name))
        end)

        self.AutoloadLabel = section:AddLabel('Current autoload config: none', true)

        local okRead, name = pcall(readfile, self.Folder .. '/settings/autoload.txt')
        if okRead and type(name) == 'string' and IsSafeName(Trim(name)) then
            self.AutoloadLabel:SetText('Current autoload config: ' .. Trim(name))
        end

        self:BuildImportExportSection(tab)
        -- REMOVED: BuildUploadSection (config-hub--z1bje.replit.app upload
        -- feature) — the backing web service is down, so this was removed
        -- rather than left as a dead "Upload" button.
        self:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigName' })

        return section
    end

    function SaveManager:BuildImportExportSection(tab)
        assert(self.Library, 'Must set SaveManager.Library')
        assert(tab, 'Must set a valid tab')

        local IOGroup = tab:AddLeftGroupbox('Import / Export')

        IOGroup:AddButton('Export current config to clipboard', function()
            local exportString, err = self:Export()
            if not exportString then
                return Notify('Failed to export config: ' .. tostring(err), 3)
            end

            local clip = setclipboard or toclipboard
            if type(clip) ~= 'function' then
                return Notify('Config exported, but your executor lacks clipboard support. Copy it from the Import box below.', 4)
            end

            Notify('Config copied to clipboard! Share it with anyone.')
        end)

        IOGroup:AddInput('SaveManager_ImportString', {
            Text = 'Config string',
            Placeholder = 'Paste an exported config string here...',
            Default = '',
        })

        IOGroup:AddButton('Import from string', function()
            local options = GetOptions()
            local input = options and options.SaveManager_ImportString
            local raw = input and input.Value

            local success, err = self:Import(raw)
            if not success then
                return Notify('Failed to import config: ' .. tostring(err), 3)
            end

            Notify('Importing config...')
        end)

        IOGroup:AddButton('Import from clipboard', function()
            local getClip = getclipboard or readclipboard
            if type(getClip) ~= 'function' then
                return Notify('Your executor does not support reading the clipboard. Paste it into the box instead.', 3)
            end

            local okRead, clipContent = pcall(getClip)
            if not okRead or type(clipContent) ~= 'string' or clipContent == '' then
                return Notify('Clipboard is empty or unreadable', 3)
            end

            local success, err = self:Import(clipContent)
            if not success then
                return Notify('Failed to import config: ' .. tostring(err), 3)
            end

            Notify('Importing config from clipboard...')
        end)

        self:SetIgnoreIndexes({ 'SaveManager_ImportString' })
        return IOGroup
    end


    function SaveManager:BuildFullConfigTab(window)
        assert(window, 'Must set a valid window')
        local ConfigsTab = window:AddTab('Configs')
        self:BuildConfigSection(ConfigsTab)
        return ConfigsTab
    end

end

return SaveManager

