local HttpService = game:GetService('HttpService')

local SaveManager = {} do
    SaveManager.Folder = 'LinoriaLibSettings'
    SaveManager.Ignore = {}
    SaveManager.LoadBatchSize = 20
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

    local function SafeCallGlobal(Name, ...)
        if Name == 'readfile' then
            if type(readfile) ~= 'function' then return false, nil end
            return pcall(readfile, ...)
        elseif Name == 'writefile' then
            if type(writefile) ~= 'function' then return false, nil end
            return pcall(writefile, ...)
        elseif Name == 'isfile' then
            if type(isfile) ~= 'function' then return false, nil end
            return pcall(isfile, ...)
        elseif Name == 'isfolder' then
            if type(isfolder) ~= 'function' then return false, nil end
            return pcall(isfolder, ...)
        elseif Name == 'makefolder' then
            if type(makefolder) ~= 'function' then return false, nil end
            return pcall(makefolder, ...)
        elseif Name == 'delfile' then
            if type(delfile) ~= 'function' then return false, nil end
            return pcall(delfile, ...)
        elseif Name == 'listfiles' then
            if type(listfiles) ~= 'function' then return false, nil end
            return pcall(listfiles, ...)
        end
        return false, nil
    end

    local function SafeReadFile(Path)
        local Ok, Result = SafeCallGlobal('readfile', Path)
        return Ok and Result or nil
    end

    local function SafeWriteFile(Path, Data)
        return SafeCallGlobal('writefile', Path, Data)
    end

    local function SafeIsFile(Path)
        local Ok, Result = SafeCallGlobal('isfile', Path)
        return Ok and Result == true
    end

    local function SafeIsFolder(Path)
        local Ok, Result = SafeCallGlobal('isfolder', Path)
        return Ok and Result == true
    end

    local function SafeMakeFolder(Path)
        return SafeCallGlobal('makefolder', Path)
    end

    local function SafeDeleteFile(Path)
        return SafeCallGlobal('delfile', Path)
    end

    local function SafeListFiles(Path)
        local Ok, Result = SafeCallGlobal('listfiles', Path)
        return Ok and type(Result) == 'table' and Result or nil
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
            local exists = SafeIsFolder(current); local ok = true
            if ok and exists then
                continue
            end
            SafeMakeFolder(current)
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

    SaveManager.Parser = {
        Toggle = {
            Save = function(idx, object)
                return { type = 'Toggle', idx = idx, value = object.Value == true }
            end,
            Load = function(idx, data)
                if type(data) ~= 'table' then return end
                local toggles = GetToggles()
                local toggle = toggles and toggles[idx]
                if toggle and type(toggle.SetValue) == 'function' then
                    toggle:SetValue(data.value == true)
                end
            end,
        },
        Slider = {
            Save = function(idx, object)
                return { type = 'Slider', idx = idx, value = tostring(object.Value) }
            end,
            Load = function(idx, data)
                if type(data) ~= 'table' then return end
                local options = GetOptions()
                local option = options and options[idx]
                if option and type(option.SetValue) == 'function' then
                    option:SetValue(data.value)
                end
            end,
        },
        Dropdown = {
            Save = function(idx, object)
                return {
                    type = 'Dropdown',
                    idx = idx,
                    value = object.Value,
                    multi = object.Multi == true,
                }
            end,
            Load = function(idx, data)
                if type(data) ~= 'table' then return end
                local options = GetOptions()
                local option = options and options[idx]
                if option and type(option.SetValue) == 'function' then
                    option:SetValue(data.value)
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
                if type(data) ~= 'table' then return end
                local options = GetOptions()
                local option = options and options[idx]
                if not option or type(option.SetValueRGB) ~= 'function' or type(data.value) ~= 'string' then
                    return
                end

                local ok, color = pcall(Color3.fromHex, data.value)
                if ok and color then
                    option:SetValueRGB(color, tonumber(data.transparency) or 0)
                end
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
                if type(data) ~= 'table' then return end
                local options = GetOptions()
                local option = options and options[idx]
                if option and type(option.SetValue) == 'function' then
                    option:SetValue({ data.key or data.value or 'None', data.mode or 'Toggle' })
                end
            end,
        },
        Input = {
            Save = function(idx, object)
                return { type = 'Input', idx = idx, text = tostring(object.Value or '') }
            end,
            Load = function(idx, data)
                if type(data) ~= 'table' then return end
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

        local options = GetOptions()
        local toggles = GetToggles()
        if not options or not toggles then
            return false, 'Library.Options/Toggles unavailable'
        end

        EnsureFolderTree(self.Folder .. '/settings')
        local fullPath = self.Folder .. '/settings/' .. name .. '.json'
        local data = { objects = {} }

        -- Theme selection is app state, not just a color value. Persist the
        -- active theme name so an autoloaded config can restore a custom theme
        -- even when the color pickers themselves are intentionally ignored.
        local library = self.Library
        if library and type(library.ThemeManager) == 'table' then
            local currentTheme = library.ThemeManager.CurrentTheme
            if type(currentTheme) == 'string' and currentTheme ~= '' then
                data.theme = currentTheme
            end
        end

        for idx, toggle in next, toggles do
            if self.Ignore[idx] then
                continue
            end

            local parser = type(toggle) == 'table' and self.Parser[toggle.Type]
            if parser and type(parser.Save) == 'function' then
                local ok, object = pcall(parser.Save, idx, toggle)
                if not ok then
                    return false, 'failed to serialize toggle ' .. tostring(idx)
                end
                if object then
                    data.objects[#data.objects + 1] = object
                end
            end
        end

        for idx, option in next, options do
            if self.Ignore[idx] then
                continue
            end

            local parser = type(option) == 'table' and self.Parser[option.Type]
            if parser and type(parser.Save) == 'function' then
                local ok, object = pcall(parser.Save, idx, option)
                if not ok then
                    return false, 'failed to serialize option ' .. tostring(idx)
                end
                if object then
                    data.objects[#data.objects + 1] = object
                end
            end
        end

        local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not success then
            return false, 'failed to encode data'
        end

        local okWrite, writeErr = SafeWriteFile(fullPath, encoded)
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
        local okExists, exists = true, SafeIsFile(file)
        if not okExists or not exists then
            return false, 'invalid file'
        end

        local success, err = SafeDeleteFile(file)
        if not success then
            return false, 'failed to delete file: ' .. tostring(err)
        end

        local autoloadPath = self.Folder .. '/settings/autoload.txt'
        local current = SafeReadFile(autoloadPath); local okRead = current ~= nil
        if okRead and Trim(current) == name then
            SafeDeleteFile(autoloadPath)
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

    function SaveManager:Load(name)
        name = Trim(name)
        if not IsSafeName(name) then
            return false, 'invalid config name'
        end

        if self.Loading then
            return false, 'config loading already in progress'
        end

        local file = self.Folder .. '/settings/' .. name .. '.json'
        local okExists, exists = true, SafeIsFile(file)
        if not okExists or not exists then
            return false, 'invalid file'
        end

        local raw = SafeReadFile(file); local okRead = raw ~= nil
        if not okRead or type(raw) ~= 'string' then
            return false, 'read error'
        end

        local success, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if not success or type(decoded) ~= 'table' or type(decoded.objects) ~= 'table' then
            return false, 'decode error'
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

                -- Apply the saved theme last so config fields cannot overwrite it.
                local savedTheme = type(decoded.theme) == 'string' and decoded.theme or nil
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

            if ok then
                self.CurrentConfig = name
            end

            -- Always restore the UI batching state, even if an unexpected error
            -- happens outside an individual parser's protected call.
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
        end)

        return true
    end

    function SaveManager:IgnoreThemeSettings()
        return self:SetIgnoreIndexes({
            'BackgroundColor', 'MainColor', 'AccentColor', 'OutlineColor', 'FontColor',
            'ThemeManager_ThemeList', 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName',
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

        local list = SafeListFiles(self.Folder .. '/settings'); local ok = list ~= nil
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
        local okExists, exists = true, SafeIsFile(path)
        if not okExists or not exists then
            return false, 'no autoload config'
        end

        local rawName = SafeReadFile(path); local okRead = rawName ~= nil
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
            local okWrite, writeErr = SafeWriteFile(path, name)
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

        local name = SafeReadFile(self.Folder .. '/settings/autoload.txt'); local okRead = name ~= nil
        if okRead and type(name) == 'string' and IsSafeName(Trim(name)) then
            self.AutoloadLabel:SetText('Current autoload config: ' .. Trim(name))
        end

        self:BuildUploadSection(tab)
        self:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigName' })

        return section
    end

    local STORE_URL = 'https://config-hub--z1bje.replit.app/api'
    local RATE_FILE = 'creepcc/entities/zone_last_upload.txt'
    local HWID_FILE = 'creepcc/entities/zone_hwid.txt'

    local function ensureDirectories()
        pcall(function()
            if not isfolder('creepcc') then makefolder('creepcc') end
            if not isfolder('creepcc/entities') then makefolder('creepcc/entities') end
        end)
    end

    local function execRequest(options)
        local fn = (syn and syn.request) or (http and http.request) or (type(request) == 'function' and request) or nil
        if not fn then return nil end
        local ok, result = pcall(fn, options)
        return ok and result or nil
    end

    local function storePost(path, body)
        local encoded
        local okEncode, result = pcall(HttpService.JSONEncode, HttpService, body)
        if not okEncode then return nil, nil end
        encoded = result

        local response = execRequest({
            Url = STORE_URL .. path,
            Method = 'POST',
            Headers = { ['Content-Type'] = 'application/json' },
            Body = encoded,
        })

        if response then
            return response.StatusCode, response.Body
        end
        return nil, nil
    end

    local function getHWID()
        ensureDirectories()

        local cached = SafeReadFile(HWID_FILE); local okCached = cached ~= nil
        if okCached and type(cached) == 'string' and #cached > 4 then
            return cached
        end

        local id
        if type(syn) == 'table' and type(syn.get_hwid) == 'function' then
            local ok, value = pcall(syn.get_hwid)
            if ok then id = value end
        elseif type(get_hwid) == 'function' then
            local ok, value = pcall(get_hwid)
            if ok then id = value end
        end

        if id == nil then
            local players = game:GetService('Players')
            id = players.LocalPlayer and players.LocalPlayer.UserId or game.PlaceId
        end

        id = tostring(id)
        SafeWriteFile(HWID_FILE, id)
        return id
    end

    local HOUR = 3600

    local function getSecondsUntilNextUpload()
        ensureDirectories()
        local raw = SafeReadFile(RATE_FILE); local okRead = raw ~= nil
        if not okRead then return 0 end

        local lastTime = tonumber(raw)
        if not lastTime then return 0 end

        local elapsed = os.time() - lastTime
        return elapsed >= HOUR and 0 or (HOUR - elapsed)
    end

    local function markUploadTime()
        ensureDirectories()
        SafeWriteFile(RATE_FILE, tostring(os.time()))
    end

    function SaveManager:BuildUploadSection(tab)
        assert(self.Library, 'Must set SaveManager.Library')
        assert(tab, 'Must set a valid tab')

        local UploadGroup = tab:AddRightGroupbox('Upload')

        UploadGroup:AddInput('UploadName', {
            Text = 'Config Name',
            Default = '',
            Placeholder = 'e.g. my_rage_config',
        })
        UploadGroup:AddInput('UploadAuthor', {
            Text = 'Your Name',
            Default = '',
            Placeholder = 'your username',
        })
        UploadGroup:AddInput('UploadDesc', {
            Text = 'Description',
            Default = '',
            Placeholder = 'optional',
        })

        local localCfgDropdown
        local function refreshLocalConfigs()
            local configs = self:RefreshConfigList(true)
            if localCfgDropdown then
                pcall(localCfgDropdown.SetValues, localCfgDropdown, configs)
                if #configs > 0 then
                    pcall(localCfgDropdown.SetValue, localCfgDropdown, configs[1])
                else
                    pcall(localCfgDropdown.SetValue, localCfgDropdown, nil)
                end
            end
        end

        local configs = self:RefreshConfigList()
        localCfgDropdown = UploadGroup:AddDropdown('UploadLocalDropdown', {
            Text = 'Select Config',
            Default = nil,
            Values = configs,
            AllowNull = true,
            Searchable = true,
            MaxVisibleItems = 8,
            ItemHeight = 18,
        })

        UploadGroup:AddButton('Refresh Configs', function()
            refreshLocalConfigs()
            Notify('Local config list refreshed')
        end)

        UploadGroup:AddButton('Upload to Store', function()
            local options = GetOptions()
            local selectedOption = options and options.UploadLocalDropdown
            local nameOption = options and options.UploadName
            local authorOption = options and options.UploadAuthor
            local descOption = options and options.UploadDesc

            local selectedCfg = Trim(selectedOption and selectedOption.Value or '')
            local name = Trim(nameOption and nameOption.Value or '')
            local author = Trim(authorOption and authorOption.Value or '')
            local desc = descOption and tostring(descOption.Value or '') or ''

            if not IsSafeName(selectedCfg) then
                return Notify('Select a local config first', 2)
            end
            if not IsSafeName(name) then
                return Notify('Enter a valid config name', 2)
            end
            if author == '' then
                return Notify('Enter your name', 2)
            end

            local waitTime = getSecondsUntilNextUpload()
            if waitTime > 0 then
                local mins = math.ceil(waitTime / 60)
                return Notify(string.format('Rate limited — wait %d more minute%s', mins, mins == 1 and '' or 's'), 3)
            end

            local filePath = self.Folder .. '/settings/' .. selectedCfg .. '.json'
            local okFile, exists = true, SafeIsFile(filePath)
            if not okFile or not exists then
                return Notify('Config file not found: ' .. selectedCfg, 3)
            end

            local raw = SafeReadFile(filePath); local okRead = raw ~= nil
            if not okRead or type(raw) ~= 'string' then
                return Notify('Failed to read config file', 3)
            end

            local okDecode, configData = pcall(HttpService.JSONDecode, HttpService, raw)
            if not okDecode or type(configData) ~= 'table' then
                return Notify('Failed to decode config file', 3)
            end

            local status, responseBody = storePost('/configs', {
                name = name,
                author = author,
                description = desc,
                hwid = getHWID(),
                data = configData,
            })

            if not responseBody then
                return Notify('Upload failed — no response', 3)
            end

            local okResponse, decoded = pcall(HttpService.JSONDecode, HttpService, responseBody)
            if status == 429 then
                return Notify((okResponse and decoded and decoded.error) or 'Rate limited', 3)
            end

            if status == 201 and okResponse and type(decoded) == 'table' and decoded.id then
                markUploadTime()
                return Notify(string.format('Uploaded! ID %s — share with friends', tostring(decoded.id)))
            end

            Notify((okResponse and decoded and decoded.error) or 'Upload failed', 3)
        end)

        UploadGroup:AddButton('Copy Config Hub URL', function()
            local fn = setclipboard or toclipboard
            if type(fn) == 'function' then
                local ok = pcall(fn, 'https://config-hub--z1bje.replit.app')
                if ok then
                    return Notify('Copied Config Hub URL to clipboard!')
                end
            end
            Notify('Your executor does not support clipboard copying.', 3)
        end)

        self:SetIgnoreIndexes({ 'UploadName', 'UploadAuthor', 'UploadDesc', 'UploadLocalDropdown' })
        return UploadGroup
    end

    function SaveManager:BuildFullConfigTab(window)
        assert(window, 'Must set a valid window')
        local ConfigsTab = window:AddTab('Configs')
        self:BuildConfigSection(ConfigsTab)
        return ConfigsTab
    end

    -- Do not call an instance method with an undefined global `self` while
    -- the module is being required. Folder creation happens after SetFolder(),
    -- once the caller has configured the manager.
end

return SaveManager
