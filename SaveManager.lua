local httpService = game:GetService('HttpService')

local SaveManager = {} do
	SaveManager.Folder = 'LinoriaLibSettings'
	SaveManager.Ignore = {}
	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = 'Toggle', idx = idx, value = object.Value } 
			end,
			Load = function(idx, data)
				if Toggles[idx] then 
					Toggles[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = 'Slider', idx = idx, value = tostring(object.Value) }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = 'Dropdown', idx = idx, value = object.Value, mutli = object.Multi }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		},
		ColorPicker = {
			Save = function(idx, object)
				return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
				end
			end,
		},
		KeyPicker = {
			Save = function(idx, object)
				return { type = 'KeyPicker', idx = idx, mode = object.Mode, key = object.Value }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue({ data.key, data.mode })
				end
			end,
		},
		Input = {
			Save = function(idx, object)
				return { type = 'Input', idx = idx, text = object.Value }
			end,
			Load = function(idx, data)
				if Options[idx] and type(data.text) == 'string' then
					Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function SaveManager:Save(name)
		if not name then
			return false, 'no config file is selected'
		end

		local fullPath = self.Folder .. '/settings/' .. name .. '.json'

		local data = {
			objects = {}
		}

		for idx, toggle in next, Toggles do
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
		end

		for idx, option in next, Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end	

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return false, 'failed to encode data'
		end

		writefile(fullPath, encoded)
		return true
	end

	function SaveManager:Load(name)
		if not name then
			return false, 'no config file is selected'
		end
		
		local file = self.Folder .. '/settings/' .. name .. '.json'
		if not isfile(file) then return false, 'invalid file' end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then return false, 'decode error' end

		for idx, option in next, decoded.objects do
			if self.Parser[option.type] then
				task.spawn(function() self.Parser[option.type].Load(option.idx, option) end) -- task.spawn() so the config loading wont get stuck.
			end
		end

		return true
	end

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", -- themes
			"ThemeManager_ThemeList", 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName', -- themes
		})
	end

	function SaveManager:BuildFolderTree()
		local paths = {
			self.Folder,
			self.Folder .. '/themes',
			self.Folder .. '/settings'
		}

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function SaveManager:RefreshConfigList()
		local list = listfiles(self.Folder .. '/settings')

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				-- i hate this but it has to be done ...

				local pos = file:find('.json', 1, true)
				local start = pos

				local char = file:sub(pos, pos)
				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1, start - 1))
				end
			end
		end
		
		return out
	end

	function SaveManager:SetLibrary(library)
		self.Library = library
	end

	function SaveManager:LoadAutoloadConfig()
		if isfile(self.Folder .. '/settings/autoload.txt') then
			local name = readfile(self.Folder .. '/settings/autoload.txt')

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify('Failed to load autoload config: ' .. err)
			end

			self.Library:Notify(string.format('Auto loaded config %q', name))
		end
	end

	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, 'Must set SaveManager.Library')

		local section = tab:AddRightGroupbox('Configuration')

		section:AddInput('SaveManager_ConfigName',    { Text = 'Config name' })
		section:AddDropdown('SaveManager_ConfigList', { Text = 'Config list', Values = self:RefreshConfigList(), AllowNull = true })

		section:AddDivider()

		section:AddButton('Create config', function()
			local name = Options.SaveManager_ConfigName.Value

			if name:gsub(' ', '') == '' then 
				return self.Library:Notify('Invalid config name (empty)', 2)
			end

			local success, err = self:Save(name)
			if not success then
				return self.Library:Notify('Failed to save config: ' .. err)
			end

			self.Library:Notify(string.format('Created config %q', name))

			Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			Options.SaveManager_ConfigList:SetValue(nil)
		end):AddButton('Load config', function()
			local name = Options.SaveManager_ConfigList.Value

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify('Failed to load config: ' .. err)
			end

			self.Library:Notify(string.format('Loaded config %q', name))
		end)

		section:AddButton('Overwrite config', function()
			local name = Options.SaveManager_ConfigList.Value

			local success, err = self:Save(name)
			if not success then
				return self.Library:Notify('Failed to overwrite config: ' .. err)
			end

			self.Library:Notify(string.format('Overwrote config %q', name))
		end)

		section:AddButton('Refresh list', function()
			Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			Options.SaveManager_ConfigList:SetValue(nil)
		end)

		section:AddButton('Set as autoload', function()
			local name = Options.SaveManager_ConfigList.Value
			writefile(self.Folder .. '/settings/autoload.txt', name)
			SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. name)
			self.Library:Notify(string.format('Set %q to auto load', name))
		end)

		SaveManager.AutoloadLabel = section:AddLabel('Current autoload config: none', true)

		if isfile(self.Folder .. '/settings/autoload.txt') then
			local name = readfile(self.Folder .. '/settings/autoload.txt')
			SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. name)
		end

		-- Build Cloud Upload section directly below Configuration on the right side
		self:BuildUploadSection(tab)

		SaveManager:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigName' })
	end

	-- ── Cloud / Store Config Upload System ────────────────────────
	local STORE_URL = "https://config-hub--z1bje.replit.app/api"
	local RATE_FILE = "creepcc/entities/zone_last_upload.txt"
	local HWID_FILE = "creepcc/entities/zone_hwid.txt"

	local function ensureDirectories()
		if not isfolder("creepcc") then pcall(makefolder, "creepcc") end
		if not isfolder("creepcc/entities") then pcall(makefolder, "creepcc/entities") end
	end

	local function execRequest(options)
		local fn = (syn and syn.request) or (http and http.request) or (type(request) == "function" and request) or nil
		if not fn then return nil end
		local ok, res = pcall(fn, options)
		return (ok and res) or nil
	end

	local function storePost(path, body)
		local res = execRequest({
			Url = STORE_URL .. path,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = httpService:JSONEncode(body),
		})
		if res then return res.StatusCode, res.Body end
		return nil, nil
	end

	local function getHWID()
		ensureDirectories()
		if isfile(HWID_FILE) then
			local cached = readfile(HWID_FILE)
			if cached and #cached > 4 then return cached end
		end
		local id = (type(syn) == "table" and type(syn.get_hwid) == "function" and syn.get_hwid())
			or (type(get_hwid) == "function" and get_hwid())
			or tostring(game:GetService("Players").LocalPlayer.UserId)
		pcall(function() writefile(HWID_FILE, tostring(id)) end)
		return tostring(id)
	end

	local HOUR = 3600
	local function getSecondsUntilNextUpload()
		ensureDirectories()
		if not isfile(RATE_FILE) then return 0 end
		local lastTime = tonumber(readfile(RATE_FILE))
		if not lastTime then return 0 end
		local elapsed = os.time() - lastTime
		return elapsed >= HOUR and 0 or (HOUR - elapsed)
	end

	local function markUploadTime()
		ensureDirectories()
		pcall(function() writefile(RATE_FILE, tostring(os.time())) end)
	end

	function SaveManager:BuildUploadSection(tab)
		assert(self.Library, 'Must set SaveManager.Library')

		local UploadGroup = tab:AddRightGroupbox("Upload")

		UploadGroup:AddInput("UploadName", {
			Text = "Config Name",
			Default = "",
			Placeholder = "e.g. my_rage_config",
		})
		UploadGroup:AddInput("UploadAuthor", {
			Text = "Your Name",
			Default = "",
			Placeholder = "your username",
		})
		UploadGroup:AddInput("UploadDesc", {
			Text = "Description",
			Default = "",
			Placeholder = "optional",
		})

		local localCfgDropdown = nil
		local function refreshLocalConfigs()
			local cfgs = self:RefreshConfigList() or {}
			if localCfgDropdown then
				localCfgDropdown:SetValues(cfgs)
				if #cfgs > 0 then
					localCfgDropdown:SetValue(cfgs[1])
				end
			end
		end

		localCfgDropdown = UploadGroup:AddDropdown("UploadLocalDropdown", {
			Text = "Select Config",
			Default = 1,
			Values = self:RefreshConfigList() or { "" },
		})

		UploadGroup:AddButton("Refresh Configs", function()
			refreshLocalConfigs()
			self.Library:Notify("Local config list refreshed")
		end)

		UploadGroup:AddButton("Upload to Store", function()
			local selectedCfg = Options.UploadLocalDropdown.Value or ""
			local name = Options.UploadName.Value or ""
			local author = Options.UploadAuthor.Value or ""
			local desc = Options.UploadDesc.Value or ""

			if selectedCfg == "" then
				self.Library:Notify("Select a local config first")
				return
			end
			if name == "" then
				self.Library:Notify("Enter a config name")
				return
			end
			if author == "" then
				self.Library:Notify("Enter your name")
				return
			end

			local wait = getSecondsUntilNextUpload()
			if wait > 0 then
				local mins = math.ceil(wait / 60)
				self.Library:Notify(string.format("Rate limited — wait %d more minute%s", mins, mins == 1 and "" or "s"))
				return
			end

			local filePath = self.Folder .. "/settings/" .. selectedCfg .. ".json"
			if not isfile(filePath) then
				self.Library:Notify("Config file not found: " .. selectedCfg)
				return
			end

			local ok2, configData = pcall(function() return httpService:JSONDecode(readfile(filePath)) end)
			if not ok2 or not configData then
				self.Library:Notify("Failed to read config file")
				return
			end

			local status, raw = storePost("/configs", {
				name = name,
				author = author,
				description = desc,
				hwid = getHWID(),
				data = configData,
			})

			if not raw then
				self.Library:Notify("Upload failed — no response")
				return
			end

			local ok3, decoded = pcall(function() return httpService:JSONDecode(raw) end)
			if status == 429 then
				self.Library:Notify((ok3 and decoded and decoded.error) or "Rate limited")
				return
			end

			if status == 201 and ok3 and decoded and decoded.id then
				markUploadTime()
				self.Library:Notify(string.format("Uploaded! ID %d — share with friends", decoded.id))
			else
				self.Library:Notify((ok3 and decoded and decoded.error) or "Upload failed")
			end
		end)

		UploadGroup:AddButton("Copy Config Hub URL", function()
			local fn = setclipboard or toclipboard
			if fn then
				fn("https://config-hub--z1bje.replit.app")
				self.Library:Notify("Copied Config Hub URL to clipboard!")
			else
				self.Library:Notify("Your executor does not support clipboard copying.")
			end
		end)

		SaveManager:SetIgnoreIndexes({ 'UploadName', 'UploadAuthor', 'UploadDesc', 'UploadLocalDropdown' })

		task.spawn(function()
			task.wait(0.5)
			pcall(refreshLocalConfigs)
		end)
	end

	-- Optional helper to build both Upload (left) and Config (right) tabs at once
	function SaveManager:BuildFullConfigTab(window)
		local ConfigsTab = window:AddTab("Configs")
		self:BuildUploadSection(ConfigsTab)
		self:BuildConfigSection(ConfigsTab)
		return ConfigsTab
	end

	SaveManager:BuildFolderTree()
end

return SaveManager