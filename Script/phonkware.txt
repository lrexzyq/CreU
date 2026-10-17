-- Deobfuscated by Meow Hook (Nocta mystical.x0p)

(function()
	do
		local function fn7(arg)
			return arg
		end

		eli_inext = function(arg, arg2)
			local n = arg2 + 1
			local v = arg[n]
			if v ~= nil then
				return n, v
			end
		end

		eli_ipairs = function(arg)
			return eli_inext, arg, 0
		end

		eli_pairs = function(arg)
			return next, arg, nil
		end

		if not cloneref then
			cloneref = function(arg)
				return arg
			end
		end

		if hookfunction and newcclosure and getcallingscript then
			pcall(function()
				local v = nil

				local function fn8(arg, arg2)
					if type(arg2) == "table" and rawget(arg2, "__mode") == "kv" then
						local v2 = getcallingscript()
						if v2 and v2.Name == "MiscellaneousController" then
							return v(arg, {})
						end
					end

					return v(arg, arg2)
				end

				v = hookfunction
				v = v(setmetatable, newcclosure(fn8))
			end)

			pcall(function()
				local v = nil

				local function fn8(arg)
					if type(arg) == "table" then
						local v2 = getcallingscript()
						if v2 and v2.Name == "MiscellaneousController" then
							return 3
						end
					end

					return v(arg)
				end

				v = hookfunction
				v = v(rawlen, newcclosure(fn8))
			end)
		end

		print("[PhonkWare] antidetect ready")

		pcall(function()
			if not (hookfunction and newcclosure and getrenv) then
				return
			end
			local v = nil
			local v2 = newcclosure

			local function fn8(arg, arg2)
				if arg2 and typeof(arg2) == "table" and rawget(arg2, "__mode") == "kv" then
					if debug.traceback():find("MiscellaneousController") then
						return v({ 1, 2, 3 }, {})
					end
				end

				return v(arg, arg2)
			end

			v = hookfunction
			v = v(getrenv().setmetatable, v2(fn8))
		end)

		coroutine.wrap(function()
			pcall(function()
				local tbl2 = { "anticheat", "ac", "detection", "ban", "kick", "security", "moderation" }

				local function fn8(arg)
					arg.Disabled = true
				end

				local function fn9(arg)
					if arg:IsA("LocalScript") or arg:IsA("ModuleScript") then
						local v = string.lower(arg.Name)

						for _, v2 in eli_ipairs(tbl2) do
							if string.find(v, v2, 1, true) then
								pcall(fn8, arg)
								break
							end
						end
					end
				end

				local function fn10(descendant)
					pcall(fn9, descendant)
				end

				pcall(function()
					game.DescendantAdded:Connect(fn10)
				end)

				pcall(function()
					local descendants = game:GetDescendants()

					for i = 1, #descendants do
						fn10(descendants[i])

						if i % 4000 == 0 then
							task.wait()
						end
					end
				end)
			end)

			pcall(function()
				local NetworkClient = game:GetService("NetworkClient")

				if NetworkClient then
					NetworkClient.ChildAdded:Connect(function(child)
						pcall(function()
							local ok, result = pcall(function()
								return child.Name:lower()
							end)

							if ok and result then
								if result:find("anticheat") or result:find("detection") then
									pcall(function()
										child:Destroy()
									end)
								end
							end
						end)
					end)
				end
			end)
		end)()

		pcall(function()
			local remoteEvent = Instance.new("RemoteEvent")
			remoteEvent.Name = "ClientAlert"
			remoteEvent.Parent = LocalPlayer
		end)

		task.spawn(function()
			pcall(fn7(function()
				if type(getgc) ~= "function" then
					return
				end
				local localScript3 = game:GetService("ReplicatedFirst"):WaitForChild("LocalScript3", 10)
				local v = getgc(false)

				for i = 1, #v do
					local v2 = v[i]

					if type(v2) == "function" and (type(islclosure) ~= "function" or islclosure(v2)) then
						local ok, result = pcall(getfenv, v2)

						if ok and type(result) == "table" then
							local ok2, result2 = pcall(function()
								return rawget(result, "script")
							end)

							if ok2 and result2 and typeof(result2) == "Instance" then
								local ok3, result3 = pcall(tostring, result2)

								if ok3 and (result2 == localScript3 or type(result3) == "string" and result3:find("LoadingScreen")) then
									local ok4, result4 = pcall(debug.getconstants, v2)

									if ok4 and type(result4) == "table" then
										for _, v3 in eli_ipairs(result4) do
											if type(v3) == "string" and (v3:find("TakeTheL") or v3:find("ban") or v3:find("kick")) then
												pcall(function()
													hookfunction(v2, function()
													end)
												end)

												break
											end
										end
									end
								end
							end
						end
					end

					if i % 1500 == 0 then
						task.wait()
					end
				end
			end))
		end)

		local flag = true
		local tbl2 = { localscript3 = true, miscellaneouscontroller = true }
		local obj = setmetatable({}, { __mode = "k" })
		local v = nil

		pcall(function()
			if not (hookmetamethod and newcclosure and getcallingscript) then
				return
			end
			local v2 = hookmetamethod
			local v3 = game

			local v4 = table.pack(newcclosure(fn7(function(arg, arg2)
				if flag and (arg2 == "Name" or arg2 == "Text") then
					local v4 = getcallingscript()

					if v4 then
						local v5 = obj[v4]

						if v5 == nil then
							local ok, result = pcall(function()
								return tbl2[string.lower(v(v4, "Name"))] == true
							end)

							result = ok and result or false
							obj[v4] = result
							v5 = result
						end

						if v5 then
							return ""
						end
					end
				end

				return v(arg, arg2)
			end)))

			v4.n = 3 + v4.n - 1
			table.move(v4, 1, v4.n, 3, v4)
			v4[1] = v3
			v4[2] = "__index"
			v = v2(table.unpack(v4, 1, v4.n))
		end)

		getgenv().phonkware_set_antidetect = function(arg)
			flag = arg and true or false
		end
	end

	local now = os.clock()

	while game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen") do
		if not (os.clock() - now > 8) then
			task.wait(0.1)
			continue
		end
		break
	end

	getgenv().silent_load = false

	do
		local chunk, v = loadstring(game:HttpGet("https://raw.githubusercontent.com/Anonymus23231/thing/refs/heads/main/Lib") .. [[

getgenv().ThemeManager = ThemeManager
getgenv().SaveManager = SaveManager
getgenv().Trove = Trove
]])

		if not chunk then
			error("[PhonkWare] failed to compile lib: " .. tostring(v))
		end

		local ok, result = pcall(chunk)

		if not ok then
			error("[PhonkWare] failed to run lib: " .. tostring(result))
		end
	end

	local library
	library = getgenv().Library
	local themeManager
	themeManager = getgenv().ThemeManager
	local saveManager
	saveManager = getgenv().SaveManager
	local options, toggles, v, v2

	do
		local trove_ = getgenv().Trove

		if not library then
			error("[PhonkWare] Library missing after load")
		end

		if not trove_ then
			trove_ = {}
			trove_.__index = trove_

			trove_.new = function()
				return setmetatable({ _objects = {} }, trove_)
			end

			trove_.Add = function(arg, arg2)
				arg._objects[#arg._objects + 1] = arg2
				return arg2
			end

			trove_.Destroy = function(arg)
				for i = #arg._objects, 1, -1 do
					local v3 = arg._objects[i]

					pcall(function()
						if typeof(v3) == "RBXScriptConnection" then
							v3:Disconnect()
						elseif typeof(v3) == "Instance" then
							v3:Destroy()
						elseif type(v3) == "function" then
							v3()
						elseif type(v3) == "table" and v3.Destroy then
							v3:Destroy()
						end
					end)
				end

				arg._objects = {}
			end

			trove_.Clean = trove_.Destroy
		end

		themeManager = themeManager or {
			SetLibrary = function()
			end,
			SetFolder = function()
			end,
			BuildConfigSection = function()
			end,
			IgnoreThemeSettings = function()
			end,
		}

		saveManager = saveManager or {
			SetLibrary = function()
			end,
			SetFolder = function()
			end,
			BuildConfigSection = function()
			end,
			IgnoreThemeSettings = function()
			end,
			SetIgnoreIndexes = function()
			end,
			LoadAutoloadConfig = function()
			end,
		}

		getgenv().Library = library
		options = library.Options
		toggles = library.Toggles
		getgenv().silent_load = false

		getgenv().phonk_mobile_btns = getgenv().phonk_mobile_btns or {
			eu = false,
			aimbot = false,
			underground = false,
			tp = false,
			fly = false,
			freecam = false,
			ragebot = false,
			triggerbot = false,
			silent = false,
		}

		local function fn7()
			local currentCamera = workspace.CurrentCamera
			local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1920, 1080)
			return math.clamp(math.min(viewportSize.X / 1920, viewportSize.Y / 1080), 0.5, 1.4)
		end

		getgenv().phonk_ui_scale = fn7()

		getgenv().phonk_apply_ui_scale = function(parent)
			if not parent then
				return
			end
			local phonkUiScale = getgenv().phonk_ui_scale or fn7()
			local phonkUIScale = parent:FindFirstChild("PhonkUIScale")

			if not phonkUIScale then
				phonkUIScale = Instance.new("UIScale")
				phonkUIScale.Name = "PhonkUIScale"
				phonkUIScale.Parent = parent
			end

			phonkUIScale.Scale = phonkUiScale
		end

		local phonkUiScale = getgenv().phonk_ui_scale
		local floor = math.floor

		v = library:CreateWindow({
			Title = "PhonkWare | https://discord.gg/vHyaNt4QCT",
			AutoShow = false,
			SubTitle = "Rivals",
			Center = true,
			Resizable = true,
			Draggable = true,
			Size = UDim2.fromOffset(math.floor(740 * phonkUiScale), floor(660 * phonkUiScale)),
		})

		pcall(function()
			local screenGui = library.ScreenGui

			if screenGui then
				local phonkUIScale = screenGui:FindFirstChild("PhonkUIScale")

				if phonkUIScale then
					phonkUIScale:Destroy()
				end

				local uiScale = Instance.new("UIScale")
				uiScale.Name = "PhonkUIScale"
				uiScale.Scale = phonkUiScale
				uiScale.Parent = screenGui
			end
		end)

		pcall(function()
			local v3 = v
			local outer

			if v then
				outer = v.Outer
			else
				outer = v3
			end

			if not outer then
				return
			end
			local UserInputService = game:GetService("UserInputService")

			local function fn8()
				local absoluteSize = outer.AbsoluteSize
				local elisiumUiSize = { absoluteSize.X, absoluteSize.Y }
				getgenv().elisium_ui_size = elisiumUiSize
				local phonkUiSize = { absoluteSize.X, absoluteSize.Y }
				getgenv().phonk_ui_size = phonkUiSize

				pcall(function()
					if isfolder and not isfolder("phonkware") then
						makefolder("phonkware")
					end

					if writefile then
						writefile("phonkware/ui_size.txt", string.format("%d,%d", absoluteSize.X, absoluteSize.Y))
					end

					if isfolder and not isfolder("Elisium") then
						makefolder("Elisium")
					end

					if writefile then
						writefile("Elisium/ui_size.txt", string.format("%d,%d", absoluteSize.X, absoluteSize.Y))
					end
				end)
			end

			pcall(function()
				local phonkUiSize = getgenv().phonk_ui_size or getgenv().elisium_ui_size

				if not phonkUiSize and isfile and isfile("phonkware/ui_size.txt") then
					local txt = readfile("phonkware/ui_size.txt")
					local match, v4 = tostring(txt):match("(%d+),(%d+)")

					if match and v4 then
						phonkUiSize = {}
						local num = tonumber(match)
						local v5 = tonumber
						phonkUiSize[1] = num

						do
							local values = table.pack(v5(v4))
							table.move(values, 1, values.n, 2, phonkUiSize)
						end
					end
				end

				if type(phonkUiSize) == "table" and phonkUiSize[1] and phonkUiSize[2] then
					local clamp = math.clamp
					local v4 = phonkUiSize[2]
					outer.Size = UDim2.fromOffset(math.clamp(phonkUiSize[1], 280, 1200), clamp(v4, 240, 1000))
				end
			end)

			for _, descendant in ipairs(outer:GetDescendants()) do
				if descendant:IsA("TextButton") and (descendant.Name == "Handle" or descendant.Name:lower():find("resize")) then
					descendant.Size = UDim2.fromOffset(44, 44)
					descendant.ZIndex = 100
				end
			end

			if outer:FindFirstChild("PhonkResizeHandle") then
				outer.PhonkResizeHandle:Destroy()
			end

			local textButton = Instance.new("TextButton")
			textButton.Name = "PhonkResizeHandle"
			textButton.AnchorPoint = Vector2.new(1, 1)
			textButton.Position = UDim2.new(1, -2, 1, -2)
			textButton.Size = UDim2.fromOffset(48, 48)
			textButton.BackgroundColor3 = library.AccentColor or Color3.fromRGB(196, 30, 58)
			textButton.BackgroundTransparency = 0.35
			textButton.BorderSizePixel = 0
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.ZIndex = 120
			textButton.Active = true
			textButton.Parent = outer
			Instance.new("UICorner", textButton).CornerRadius = UDim.new(0, 8)
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Color = library.AccentColor or Color3.fromRGB(196, 30, 58)
			uiStroke.Thickness = 1.5
			uiStroke.Transparency = 0.2
			uiStroke.Parent = textButton

			for i = 1, 3 do
				local frame = Instance.new("Frame")
				frame.AnchorPoint = Vector2.new(1, 1)
				frame.Position = UDim2.new(1, -6, 1, -6 - (i - 1) * 7)
				frame.Size = UDim2.fromOffset(10 + (i - 1) * 6, 2)
				frame.BackgroundColor3 = Color3.new(1, 1, 1)
				frame.BackgroundTransparency = 0.25
				frame.BorderSizePixel = 0
				frame.ZIndex = 121
				frame.Parent = textButton
			end

			local flag = false
			local vector2 = nil
			local absoluteSize = nil

			local function fn9(arg)
				flag = true
				vector2 = Vector2.new(arg.Position.X, arg.Position.Y)
				absoluteSize = outer.AbsoluteSize
			end

			textButton.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					fn9(input)
				end
			end)

			local connection = UserInputService.InputChanged:Connect(function(input)
				if not flag then
					return
				end

				if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end
				local vector22 = Vector2.new(input.Position.X, input.Position.Y)
				local n = math.clamp(absoluteSize.X + vector22.X - vector2.X, 280, 1200)
				local n2 = math.clamp(absoluteSize.Y + vector22.Y - vector2.Y, 240, 1000)
				local floor2 = math.floor
				outer.Size = UDim2.fromOffset(math.floor(n), floor2(n2))
			end)

			local connection2 = UserInputService.InputEnded:Connect(function(input)
				if not flag then
					return
				end

				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					flag = false
					fn8()
				end
			end)

			if trove then
			end

			getgenv().phonk_resize_cleanup = function()
				pcall(function()
					connection:Disconnect()
				end)

				pcall(function()
					connection2:Disconnect()
				end)

				pcall(function()
					textButton:Destroy()
				end)
			end
		end)

		pcall(function()
			if workspace.CurrentCamera then
				trove = trove
			end
		end)

		if GLOBAL_TROVE then
			pcall(function()
				GLOBAL_TROVE:Destroy()
			end)
		end

		v2 = trove_.new()
		getgenv().GLOBAL_TROVE = v2

		pcall(function()
			local function fn8()
				local v3 = fn7()
				getgenv().phonk_ui_scale = v3
				local screenGui = library.ScreenGui

				if screenGui then
					local phonkUIScale = screenGui:FindFirstChild("PhonkUIScale")

					if not phonkUIScale then
						phonkUIScale = Instance.new("UIScale")
						phonkUIScale.Name = "PhonkUIScale"
						phonkUIScale.Parent = screenGui
					end

					phonkUIScale.Scale = v3
				end

				for _, v4 in ipairs({ "PhonkWare_MobileLogo", "PhonkWareKeySystem", "PhonkWareEUCounter" }) do
					local v5 = nil

					pcall(function()
						if gethui then
							v5 = gethui():FindFirstChild(v4)
						end
					end)

					if not v5 then
						pcall(function()
							v5 = game:GetService("CoreGui"):FindFirstChild(v4)
						end)
					end

					if v5 then
						local phonkUIScale = v5:FindFirstChild("PhonkUIScale")

						if not phonkUIScale then
							phonkUIScale = Instance.new("UIScale")
							phonkUIScale.Name = "PhonkUIScale"
							phonkUIScale.Parent = v5
						end

						phonkUIScale.Scale = v3
					end
				end
			end

			fn8()
			local currentCamera = workspace.CurrentCamera

			if currentCamera then
				v2:Add(currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fn8))
			end

			v2:Add(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
				task.wait()
				local currentCamera2 = workspace.CurrentCamera

				if currentCamera2 then
					v2:Add(currentCamera2:GetPropertyChangedSignal("ViewportSize"):Connect(fn8))
					fn8()
				end
			end))
		end)
	end

	library:OnUnload(function()
		pcall(function()
			GLOBAL_TROVE:Destroy()
		end)

		getgenv().Library = nil
	end)

	local v3
	v3 = cloneref(game:GetService("ReplicatedStorage"))
	local v4
	v4 = cloneref(game:GetService("Players"))
	local v5
	v5 = cloneref(game:GetService("RunService"))
	local v6
	v6 = cloneref(game:GetService("UserInputService"))
	local v7
	v7 = cloneref(game:GetService("Lighting"))
	local localPlayer2
	localPlayer2 = v4.LocalPlayer
	local currentCamera
	currentCamera = workspace.CurrentCamera
	local MechanicsController
	MechanicsController = require(localPlayer2.PlayerScripts.Controllers.MechanicsController)
	local CameraController
	CameraController = require(localPlayer2.PlayerScripts.Controllers.CameraController)
	local ItemLibrary
	ItemLibrary = require(v3.Modules.ItemLibrary)
	oldoffsets = oldoffsets or {}
	local tbl2

	tbl2 = {
		Combat = v:AddTab("combat"),
		Ragebot = v:AddTab("ragebot"),
		World = v:AddTab("world"),
		Visuals = v:AddTab("visuals"),
		Character = v:AddTab("character"),
		Misc = v:AddTab("misc"),
		Optimizations = v:AddTab("optimizations"),
		["UI Settings"] = v:AddTab("settings"),
	}

	getgenv().phonk = {
		world = {
			weather = { enable = false, color = Color3.fromRGB(255, 255, 255), rate = 100, type = "snow" },
			skybox = {
				enable = false,
				selected = "Deep Space",
				rotate = false,
				rotate_speed = 1,
				rotate_direction = "Horizontal",
				rotate_method = "Spin",
				remove_sun = false,
				remove_moon = false,
				remove_stars = false,
			},
			third_person = { enable = false },
			stretched_res = { enable = false, amount = 0.2 },
			fov_changer = { enable = false, fov = 80 },
		},
		death_effects = { enable = false, type = "Explosion", color = Color3.fromRGB(120, 81, 166) },
		disable_anims = { enable = false, select = {} },
		viewmodel_chams = {
			weapon_chams = {
				enable = false,
				color = Color3.fromRGB(255, 255, 255),
				material = "Neon",
				transparency = 0,
			},
			arm_chams = {
				enable = false,
				color = Color3.fromRGB(255, 255, 255),
				material = "Neon",
				transparency = 0,
				invisible = false,
			},
			weapon_highlight = {
				enable = false,
				color = Color3.fromRGB(255, 255, 255),
				transparency = 0.5,
				outline_color = Color3.fromRGB(255, 255, 255),
				outline_transparency = 0,
			},
			arm_highlight = {
				enable = false,
				color = Color3.fromRGB(255, 255, 255),
				transparency = 0.5,
				outline_color = Color3.fromRGB(255, 255, 255),
				outline_transparency = 0,
			},
		},
		slide_boost = { enable = false, speed = 60 },
		walkspeed = { enable = false, multiplier = 1.5 },
		fly = { enable = false, speed = 50 },
		freecam = { enable = false, speed = 20 },
		eu_counter = { enable = false },
		silent_aim = {
			enable = false,
			hit_part = "Head",
			fov_radius = 300,
			show_fov = true,
			fov_color = Color3.fromRGB(255, 255, 255),
		},
		ragebot = { enable = false, prediction = true, tp_duration = 0.15, y_offset = 3, team_check = true },
		no_arm = { enable = false },
		tp_player = { y_offset = 0, method = "closest", team_check = true, prediction = true },
		animation = { enable = false, select_animation = "Meditate", speed = 2 },
		optimizations = {
			no_particles = false,
			no_shadows = false,
			low_quality = false,
			no_postfx = false,
			no_textures = false,
			no_atmosphere = false,
			fps_cap_enable = false,
			fps_cap = 60,
		},
		device_spoof = { enable = false, type = "MouseKeyboard" },
		sound_spammer = { enable = false, type = "DoubleJump" },
		spoof = { level = { enable = false, value = 9 }, streak = { enable = false, value = 9 } },
		profile = { spoof_local = false, spoof_local_name = "", spoof_other = false, spoof_other_name = "" },
		char_spoof = { enable = false, selected = "", saved = {}, last_id = nil },
		infinite_double_jump = { enable = false },
		viewmodel_offsets = { enable = false, x = 0, y = 0, z = 0 },
		hitsounds = { enable = false, selected = "hitmarker", custom_id = "", volume = 1, pitch = 1 },
		remove_muzzle = { enable = false },
		remove_gun_sounds = { enable = false },
		damage_numbers = {
			enable = false,
			color1 = Color3.fromRGB(255, 80, 80),
			color2 = Color3.fromRGB(255, 200, 80),
			color_type = "Static",
			font = "GothamBold",
			text_size = 18,
			duration = 0.8,
			rise = 42,
			remove_ingame = true,
		},
		map_textures = { enable = false, material = "Neon", color = Color3.fromRGB(255, 255, 255) },
		unlock_all = { enable = false },
	}

	local phonk
	phonk = getgenv().phonk
	phonk.gun_mods = phonk.gun_mods or { enable = false }
	phonk.underground = phonk.underground or { enable = false, depth = 5.8 }
	phonk.fly = phonk.fly or { enable = false, speed = 50 }
	phonk.freecam = phonk.freecam or { enable = false, speed = 20 }
	phonk.eu_counter = phonk.eu_counter or { enable = false }

	phonk.silent_aim = phonk.silent_aim or {
		enable = false,
		hit_part = "Head",
		fov_radius = 300,
		show_fov = true,
		fov_color = Color3.fromRGB(255, 255, 255),
	}

	phonk.ragebot = phonk.ragebot or { enable = false, prediction = true, tp_duration = 0.15, y_offset = 3, team_check = true }

	phonk.crosshair = phonk.crosshair or {
		enable = false,
		style = "cross",
		lines = true,
		top_line = true,
		bottom_line = true,
		left_line = true,
		right_line = true,
		rotation = 0,
		length = 6,
		thickness = 1,
		gap = 3,
		color = Color3.fromRGB(0, 255, 170),
		outline = false,
		outline_color = Color3.fromRGB(0, 0, 0),
		dot = false,
		rotating = false,
		rotating_speed = 120,
		spread = false,
		spread_scale = 1,
		animation = false,
		animation_mode = "pulse",
		animation_speed = 3,
		fade = false,
		fade_color = Color3.fromRGB(255, 0, 170),
		follow_target = false,
		follow_source = "target",
		shimmer = false,
		shimmer_speed = 4,
		text_enable = false,
		text_content = "PhonkWare",
		text_font = "Plex",
		text_size = 16,
		text_offset = 18,
		text_color = Color3.fromRGB(255, 255, 255),
		text_outline = true,
		text_animation = false,
	}

	phonk.no_arm = phonk.no_arm or { enable = false }
	phonk.tp_player = phonk.tp_player or { y_offset = 0, method = "closest", team_check = true, prediction = true }

	if phonk.tp_player.prediction == nil then
		phonk.tp_player.prediction = true
	end

	phonk.char_spoof = phonk.char_spoof or { enable = false, selected = "", saved = {}, last_id = nil }

	phonk.targeting = phonk.targeting or {
		max_distance = 800,
		part = "Head",
		visible_only = false,
		riot_shield = false,
		anti_katana = false,
	}

	phonk.targeting.anti_katana = phonk.targeting.anti_katana or false

	phonk.aimbot = phonk.aimbot or {
		enable = false,
		show_fov = true,
		fov_radius = 180,
		fov_color = Color3.fromRGB(196, 30, 58),
		smoothing = 1,
		closest_part = false,
	}

	phonk.triggerbot = phonk.triggerbot or { enable = false, team_check = true, reaction_time = 0.05, shoot_delay = 0.1, max_distance = 500 }

	phonk.esp = phonk.esp or {
		enable = false,
		team_check = true,
		box = { enable = true, color = Color3.fromRGB(196, 30, 58), thickness = 1 },
		name = { enable = true, color = Color3.fromRGB(255, 255, 255) },
		health = { enable = true, color = Color3.fromRGB(80, 220, 80) },
		distance = { enable = true, color = Color3.fromRGB(200, 200, 200) },
		tracer = { enable = false, color = Color3.fromRGB(196, 30, 58), origin = "bottom" },
		highlight = {
			enable = true,
			fill_color = Color3.fromRGB(196, 30, 58),
			fill_transparency = 0.45,
			outline_color = Color3.fromRGB(255, 255, 255),
			outline_transparency = 0,
		},
		chams = {
			enable = false,
			material = "Neon",
			color = Color3.fromRGB(196, 30, 58),
			transparency = 0,
			ghost = false,
			strip_textures = false,
		},
	}

	phonk.world.atmosphere = phonk.world.atmosphere or {
		enable = false,
		density = 0.3,
		offset = 0.25,
		color = Color3.fromRGB(140, 40, 40),
		decay = Color3.fromRGB(80, 20, 20),
		glare = 0.2,
		haze = 1.5,
	}

	phonk.world.color_correction = phonk.world.color_correction or {
		enable = false,
		brightness = 0.05,
		contrast = 0.15,
		saturation = 0.1,
		tint = Color3.fromRGB(255, 180, 180),
	}

	do
		local flag = false

		local function phonkApplyGunMods()
			if not phonk.gun_mods.enable then
				return
			end
			local ok, result = pcall(require, v3.Modules.ItemLibrary)

			if ok and result and result.Items then
				for _, item in pairs(result.Items) do
					if typeof(item) == "table" then
						if item.ShootSpread ~= nil then
							item.ShootSpread = 0
						end

						if item.ShootAccuracy ~= nil then
							item.ShootAccuracy = 0
						end

						if item.ShootRecoil ~= nil then
							item.ShootRecoil = 0
						end

						if item.ShootCooldown ~= nil then
							item.ShootCooldown = 0.001
						end

						if item.ShootBurstCooldown ~= nil then
							item.ShootBurstCooldown = 0.001
						end

						if item.AttackCooldown ~= nil then
							item.AttackCooldown = 0
						end

						if item.SwingCooldown ~= nil then
							item.SwingCooldown = 0
						end

						if item.MeleeCooldown ~= nil then
							item.MeleeCooldown = 0
						end

						if item.Cooldown ~= nil then
							item.Cooldown = 0
						end

						if item.RecoveryTime ~= nil then
							item.RecoveryTime = 0
						end

						if item.ResetTime ~= nil then
							item.ResetTime = 0
						end
					end
				end
			end

			if not flag then
				local ClientItem = nil

				for i = 1, 5 do
					pcall(function()
						ClientItem = require(localPlayer2.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
					end)

					if not ClientItem then
						task.wait(0.1)
						continue
					end
					break
				end

				if ClientItem and ClientItem.Input then
					flag = true
					local input = ClientItem.Input

					ClientItem.Input = function(...)
						local v8 = table.pack(...)

						if phonk.gun_mods.enable then
							local tbl3 = { ... }

							if type(tbl3[1]) == "table" and tbl3[1].Info then
								tbl3[1].Info.ShootRecoil = 0
								tbl3[1].Info.ShootSpread = 0
								tbl3[1].Info.ProjectileSpeed = 99999999
								tbl3[1].Info.ShootCooldown = 0
								tbl3[1].Info.QuickShotCooldown = 0
							end

							return input(table.unpack(v8, 1, v8.n))
						end

						return input(...)
					end
				end
			end
		end

		v2:Add(v5.Heartbeat:Connect(function()
			if phonk.gun_mods.enable then
				phonkApplyGunMods()
			end
		end))

		pcall(function()
			local ok, result = pcall(function()
				return require(localPlayer2.PlayerScripts.Modules.ItemTypes.Gun)
			end)

			if ok and result and result.IsFullyAiming then
				local isFullyAiming = result.IsFullyAiming

				result.IsFullyAiming = function(arg, ...)
					if phonk.gun_mods.enable then
						return true
					end
					return isFullyAiming(arg, ...)
				end
			end
		end)

		getgenv().phonk_apply_gun_mods = phonkApplyGunMods
	end

	do
		local Utility = nil
		local EnumLibrary = nil
		local GameplayUtility = nil

		pcall(function()
			Utility = require(v3.Modules.Utility)
		end)

		pcall(function()
			EnumLibrary = require(v3.Modules.EnumLibrary)
		end)

		pcall(function()
			GameplayUtility = require(v3.Modules.GameplayUtility)
		end)

		local circle = nil

		pcall(function()
			circle = Drawing.new("Circle")
			circle.Thickness = 1
			circle.Filled = false
			circle.Visible = false

			v2:Add(function()
				pcall(function()
					circle:Remove()
				end)
			end)
		end)

		local function fn7()
			if not phonk.silent_aim.enable then
				return false
			end
			local phonkMobileBtns = getgenv().phonk_mobile_btns
			if phonkMobileBtns and phonkMobileBtns.silent then
				return true
			end
			local v8 = options
			local silentAimKey

			if options then
				silentAimKey = options.silent_aim_key
			else
				silentAimKey = v8
			end

			if not silentAimKey then
				return true
			end

			if type(silentAimKey.GetState) == "function" then
				local ok, result = pcall(function()
					return silentAimKey:GetState()
				end)

				if ok then
					return result == true
				end
			end

			if silentAimKey.Mode == "Always" then
				return true
			end

			if silentAimKey.Mode == "Toggle" then
				return silentAimKey.Toggled == true
			end

			if silentAimKey.Mode == "Hold" and silentAimKey.Value and silentAimKey.Value ~= "None" then
				local ok, result = pcall(function()
					return v6:IsKeyDown(Enum.KeyCode[silentAimKey.Value])
				end)

				return ok and result == true
			end

			return false
		end

		local function fn8()
			if not fn7() then
				return nil
			end
			local currentCamera2 = workspace.CurrentCamera
			if not currentCamera2 then
				return nil
			end
			local n = currentCamera2.ViewportSize / 2
			local fovRadius = phonk.silent_aim.fov_radius or 300
			local hitPart = phonk.silent_aim.hit_part or "Head"
			local v8 = nil

			for _, v9 in ipairs(game:GetService("CollectionService"):GetTagged("Entity")) do
				if v9 ~= localPlayer2.Character then
					local v10 = v9:FindFirstChild(hitPart, true)

					if not (not v10 or not v10:IsA("BasePart")) then
						local v11, v12 = currentCamera2:WorldToViewportPoint(v10.Position)

						if v12 then
							local magnitude = (Vector2.new(v11.X, v11.Y) - n).Magnitude

							if magnitude < fovRadius then
								fovRadius = magnitude
								v8 = v10
							end
						end
					end
				end
			end

			return v8
		end

		local function fn9(arg, arg2)
			if not Utility or not arg2 then
				return nil
			end
			local cFrame = arg2.CFrame

			return {
				[utf8.char(1)] = {
					[utf8.char(0)] = Utility:EncodeCFrame(CFrame.lookAt(arg, arg2.Position)),
					[utf8.char(1)] = Utility:EncodeCFrame(cFrame),
					[utf8.char(2)] = arg2,
					[utf8.char(3)] = Utility:EncodeCFrame(cFrame:ToObjectSpace(CFrame.new(arg2.Position))),
				},
			}
		end

		v2:Add(v5.RenderStepped:Connect(function()
			if not circle then
				return
			end
			local showFov = fn7() and phonk.silent_aim.show_fov
			circle.Visible = showFov and true or false
			if not showFov then
				return
			end
			local currentCamera2 = workspace.CurrentCamera
			if not currentCamera2 then
				return
			end
			circle.Position = currentCamera2.ViewportSize / 2
			circle.Radius = phonk.silent_aim.fov_radius or 300
			circle.Color = phonk.silent_aim.fov_color or Color3.new(1, 1, 1)
		end))

		pcall(function()
			if not GameplayUtility or not GameplayUtility.GetEntitiesFromRaycast then
				return
			end
			local getEntitiesFromRaycast = GameplayUtility.GetEntitiesFromRaycast

			GameplayUtility.GetEntitiesFromRaycast = function(arg, arg2, arg3, arg4, arg5, arg6, ...)
				if fn7() then
					local v8 = fn8()

					if v8 then
						local magnitude = (v8.Position - arg4).Magnitude
						arg5 = (v8.Position - arg4).Unit

						if magnitude > arg6 then
							arg6 = magnitude + 5
						end
					end
				end

				local v8 = table.pack(...)
				local v9 = getEntitiesFromRaycast
				v8.n = 7 + v8.n - 1
				table.move(v8, 1, v8.n, 7, v8)
				v8[1] = arg
				v8[2] = arg2
				v8[3] = arg3
				v8[4] = arg4
				v8[5] = arg5
				v8[6] = arg6
				return v9(table.unpack(v8, 1, v8.n))
			end
		end)

		pcall(function()
			local useItem = v3.Remotes.Replication.Fighter.UseItem
			if not useItem or type(hookfunction) ~= "function" then
				return
			end
			local v8 = nil

			local function fn10(arg, arg2, arg3, arg4, arg5, ...)
				if fn7() and EnumLibrary and arg3 == EnumLibrary:ToEnum("StartShooting") then
					local humanoidRootPart = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")
					local v9 = fn8()

					if humanoidRootPart and v9 then
						arg4 = fn9(humanoidRootPart.Position, v9) or arg4
					end
				end

				local v9 = v8
				local v10 = table.pack(...)
				v10.n = 6 + v10.n - 1
				table.move(v10, 1, v10.n, 6, v10)
				v10[1] = arg
				v10[2] = arg2
				v10[3] = arg3
				v10[4] = arg4
				v10[5] = arg5
				return v9(table.unpack(v10, 1, v10.n))
			end

			if type(newcclosure) == "function" then
				v8 = hookfunction
				v8 = v8(useItem.FireServer, newcclosure(fn10))
			else
				v8 = hookfunction
				v8 = v8(useItem.FireServer, fn10)
			end
		end)
	end

	pcall(function()
		local ok, result = pcall(function()
			return require(localPlayer2.PlayerScripts.Modules.ItemTypes.Gun)
		end)

		if ok and result and result.IsFullyAiming and not result.__phonk_sa_hooked then
			result.__phonk_sa_hooked = true
			local isFullyAiming = result.IsFullyAiming

			result.IsFullyAiming = function(arg, ...)
				if phonk.silent_aim.enable or phonk.gun_mods.enable then
					return true
				end
				return isFullyAiming(arg, ...)
			end
		end
	end)

	do
		local phonkUnderground = {
			active = false,
			saved_pos = nil,
			original_collide = {},
			last_key_state = false,
			tp_override = false,
		}

		getgenv().phonk_underground = phonkUnderground

		local function fn7(arg)
			local tbl3 = {}
			if not arg then
				return tbl3
			end

			for _, descendant in ipairs(arg:GetDescendants()) do
				if descendant:IsA("BasePart") then
					tbl3[#tbl3 + 1] = descendant
				end
			end

			return tbl3
		end

		local function fn8(arg, canCollide)
			for _, v8 in ipairs(arg) do
				pcall(function()
					v8.CanCollide = canCollide
				end)
			end
		end

		local function fn9(arg)
			local tbl3 = {}

			for _, v8 in ipairs(arg) do
				tbl3[v8] = v8.CanCollide
			end

			return tbl3
		end

		local function fn10(arg)
			for k, v8 in pairs(arg) do
				pcall(function()
					if k and k.Parent then
						k.CanCollide = v8
					end
				end)
			end
		end

		local function fn11(arg, arg2, arg3)
			local character = localPlayer2.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return
			end

			pcall(function()
				local n = humanoidRootPart.CFrame - humanoidRootPart.CFrame.Position
				humanoidRootPart.CFrame = CFrame.new(arg, arg2, arg3) * n
				humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
			end)
		end

		local function fn12()
			if phonkUnderground.saved_pos then
				fn11(phonkUnderground.saved_pos.X, phonkUnderground.saved_pos.Y, phonkUnderground.saved_pos.Z)
			end

			fn10(phonkUnderground.original_collide)
			phonkUnderground.original_collide = {}
			phonkUnderground.active = false
			phonkUnderground.saved_pos = nil
			phonkUnderground.tp_override = false
		end

		local function fn13()
			local character = localPlayer2.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return
			end
			phonkUnderground.saved_pos = humanoidRootPart.Position
			local v8 = fn7(character)
			phonkUnderground.original_collide = fn9(v8)
			fn8(v8, false)
			phonkUnderground.active = true
		end

		local function fn14(arg)
			local v8 = options[arg]
			if not v8 or not v8.GetState then
				return false
			end

			local ok, result = pcall(function()
				return v8:GetState()
			end)

			return ok and result == true
		end

		v2:Add(v5.Heartbeat:Connect(function()
			if not phonk.underground.enable then
				if phonkUnderground.active then
					fn12()
				end

				phonkUnderground.last_key_state = false
				return
			end

			local character = localPlayer2.Character

			if not (character and character:FindFirstChild("HumanoidRootPart")) then
				if phonkUnderground.active then
					phonkUnderground.active = false
					phonkUnderground.saved_pos = nil
					phonkUnderground.original_collide = {}
				end

				return
			end

			local phonkMobileBtns = getgenv().phonk_mobile_btns
			local ugKey = fn14("ug_key") or phonkMobileBtns and phonkMobileBtns.underground == true

			if ugKey and not phonk.underground.enable then
				phonk.underground.enable = true
			end

			if ugKey and not phonkUnderground.active then
				fn13()
			elseif not ugKey and phonkUnderground.active then
				fn12()
			end

			if phonkUnderground.active and phonkUnderground.saved_pos and not phonkUnderground.tp_override then
				local value

				if options and options.ug_depth and type(options.ug_depth.Value) == "number" then
					value = options.ug_depth.Value
				else
					local depth = phonk.underground and phonk.underground.depth
					value = 5.8

					if depth then
						value = phonk.underground.depth
					end
				end

				fn11(phonkUnderground.saved_pos.X, phonkUnderground.saved_pos.Y - value, phonkUnderground.saved_pos.Z)
				fn8(fn7(character), false)
			elseif phonkUnderground.active and phonkUnderground.tp_override then
				fn8(fn7(character), false)
			end
		end))

		v2:Add(localPlayer2.CharacterAdded:Connect(function()
			phonkUnderground.active = false
			phonkUnderground.saved_pos = nil
			phonkUnderground.original_collide = {}
			phonkUnderground.last_key_state = false
		end))

		v2:Add(function()
			if phonkUnderground.active then
				fn12()
			end
		end)
	end

	do
		local mouse = localPlayer2:GetMouse()
		local localFighter = nil

		task.spawn(function()
			for i = 1, 40 do
				pcall(function()
					localFighter = require(localPlayer2.PlayerScripts.Controllers.FighterController).LocalFighter
				end)

				if not localFighter then
					task.wait(0.25)
					continue
				end
				break
			end
		end)

		v2:Add(localPlayer2.CharacterAdded:Connect(function()
			task.wait(1)

			pcall(function()
				localFighter = require(localPlayer2.PlayerScripts.Controllers.FighterController).LocalFighter
			end)
		end))

		local function fn7(arg)
			if not arg then
				return false
			end
			return not workspace:FindPartOnRayWithIgnoreList(Ray.new(currentCamera.CFrame.Position, arg.Position - currentCamera.CFrame.Position), { localPlayer2.Character, arg.Parent })
		end

		local function fn8(arg)
			arg = arg and arg.Character
			if not arg then
				return false
			end

			for _, descendant in ipairs(arg:GetDescendants()) do
				if descendant:IsA("BasePart") and string.find(string.lower(descendant.Name), "riot") then
					return true
				end
			end

			return false
		end

		local tbl3 = {}

		local function fn9(arg)
			if tbl3[arg] then
				return true
			end

			local ok, result = pcall(function()
				return arg:GetAttribute("Deflecting")
			end)

			return ok and result == true
		end

		local function fn10()
			local ok, result = pcall(function()
				return require(localPlayer2.PlayerScripts.Modules.Items.Katana)
			end)

			if not ok or type(result) ~= "table" or not result._StartDeflecting then
				return
			end

			if result._phonk_hooked then
				return
			end
			result._phonk_hooked = true
			local startDeflecting = result._StartDeflecting

			result._StartDeflecting = function(...)
				local tbl4 = { ... }

				pcall(function()
					local v8 = tbl4[1]
					if type(v8) ~= "table" then
						return
					end
					local clientFighter = v8.ClientFighter
					clientFighter = clientFighter and clientFighter.Player

					if clientFighter then
						tbl3[clientFighter] = true
						local deflectDuration = v8.Info and v8.Info.DeflectDuration
						local n = 0.1

						if deflectDuration then
							n = v8.Info.DeflectDuration
						end

						task.delay(n, function()
							tbl3[clientFighter] = false
						end)
					end
				end)

				return startDeflecting(table.unpack(tbl4))
			end

			v2:Add(function()
				pcall(function()
					result._StartDeflecting = startDeflecting
				end)
			end)
		end

		task.spawn(function()
			for i = 1, 30 do
				fn10()

				if next then
					local ok, result = pcall(function()
						return require(localPlayer2.PlayerScripts.Modules.Items.Katana)
					end)

					if not (ok and result and result._phonk_hooked) then
						task.wait(0.5)
						continue
					end
				else
					task.wait(0.5)
					continue
				end

				break
			end
		end)

		v2:Add(localPlayer2.CharacterAdded:Connect(function()
			task.wait(1)
			fn10()
		end))

		local function fn11(arg)
			local vector2 = Vector2.new(mouse.X, mouse.Y)
			if not arg.Character then
				return nil
			end
			local huge = math.huge
			local v8 = nil

			for _, child in ipairs(arg.Character:GetChildren()) do
				if child:IsA("BasePart") then
					local v9, v10 = currentCamera:WorldToViewportPoint(child.Position)

					if v10 then
						local magnitude = (vector2 - Vector2.new(v9.X, v9.Y)).Magnitude

						if magnitude <= huge then
							huge = magnitude
							v8 = child
						end
					end
				end
			end

			return v8
		end

		local function fn12()
			local maxDistance = phonk.targeting.max_distance
			local vector2 = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2)
			local part = phonk.targeting.part or "Head"
			local fovRadius = phonk.aimbot.fov_radius or 180
			local v8 = nil

			for _, player in ipairs(v4:GetPlayers()) do
				if player ~= localPlayer2 and player.Character and player.Character:FindFirstChild(part) and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
					local flag = false

					if player:GetAttribute("TeamID") == localPlayer2:GetAttribute("TeamID") then
						flag = true
					end

					if not flag and phonk.targeting.anti_katana and fn9(player) then
						flag = true
					end

					if not flag and phonk.targeting.visible_only and not fn7(player.Character[part]) then
						flag = true
					end

					if not flag and phonk.targeting.riot_shield and fn8(player) then
						flag = true
					end

					if not flag then
						local v9, v10 = currentCamera:WorldToViewportPoint(player.Character[part].Position)

						if v10 then
							local magnitude = (vector2 - Vector2.new(v9.X, v9.Y)).Magnitude

							if magnitude < maxDistance and magnitude < fovRadius then
								maxDistance = magnitude
								v8 = player
							end
						end
					end
				end
			end

			return v8
		end

		local circle = nil

		if Drawing then
			circle = Drawing.new("Circle")
			circle.Thickness = 1
			circle.NumSides = 64
			circle.Filled = false
			circle.Visible = false

			v2:Add(function()
				pcall(function()
					circle:Remove()
				end)
			end)
		end

		local function fn13(arg)
			local v8 = options[arg]
			if not v8 then
				return false
			end

			if type(v8.GetState) == "function" then
				local ok, result = pcall(function()
					return v8:GetState()
				end)

				if ok then
					return result == true
				end
			end

			if v8.Mode == "Always" then
				return true
			end

			if v8.Mode == "Toggle" then
				return v8.Toggled == true
			end

			if v8.Mode == "Hold" and v8.Value and v8.Value ~= "None" then
				local ok, result = pcall(function()
					return v6:IsKeyDown(Enum.KeyCode[v8.Value])
				end)

				return ok and result == true
			end

			return false
		end

		v2:Add(v5.Heartbeat:Connect(function()
			if circle then
				if phonk.aimbot.enable and phonk.aimbot.show_fov then
					circle.Visible = true
					circle.Radius = phonk.aimbot.fov_radius or 180
					circle.Color = phonk.aimbot.fov_color or Color3.fromRGB(196, 30, 58)
					circle.Position = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2)
				else
					circle.Visible = false
				end
			end

			if not phonk.aimbot.enable then
				return
			end
			local phonkMobileBtns = getgenv().phonk_mobile_btns
			if not (fn13("aim_key") or phonkMobileBtns and phonkMobileBtns.aimbot == true) then
				return
			end
			local v8 = fn12()
			if not (v8 and v8.Character) then
				return
			end
			local part = phonk.targeting and phonk.targeting.part or "Head"
			local position

			if phonk.aimbot.closest_part then
				local v9 = fn11(v8)

				if v9 then
					position = v9.Position
				else
					local character = v8.Character
					position = nil

					if character:FindFirstChild(part) then
						position = v8.Character[part].Position
					end
				end
			else
				local v9 = v8.Character:FindFirstChild(part)
				position = nil

				if v9 then
					position = v9.Position
				end
			end

			if not position then
				return
			end
			local n = (101 - math.clamp(tonumber(phonk.aimbot.smoothing) or 1, 1, 100)) / 100
			local position2 = currentCamera.CFrame.Position
			local n2 = position - position2
			if n2.Magnitude < 0.001 then
				return
			end
			local unit = n2.Unit
			local v9 = currentCamera.CFrame.LookVector:Lerp(unit, n)

			if not (v9.Magnitude < 0.001) then
				unit = v9.Unit
			end

			local cframe = CFrame.lookAt(position2, position2 + unit)

			pcall(function()
				if CameraController and type(CameraController.MimicRotation) == "function" then
					CameraController:MimicRotation(cframe)
				end

				currentCamera.CFrame = cframe
			end)
		end))

		local tbl4 = { is_shooting = false }

		v2:Add(task.spawn(function()
			while true do
				task.wait(0.05)
				local phonkMobileBtns = getgenv().phonk_mobile_btns

				if phonk.triggerbot.enable or phonkMobileBtns and phonkMobileBtns.triggerbot then
					local v8 = workspace:FindPartOnRayWithIgnoreList(Ray.new(currentCamera.CFrame.Position, currentCamera.CFrame.LookVector * (phonk.triggerbot.max_distance or 2500)), { localPlayer2.Character })

					if v8 and v8.Parent and v8.Parent:FindFirstChildWhichIsA("Humanoid") and v8.Parent:FindFirstChildWhichIsA("Humanoid").Health > 0 then
						local playerFromCharacter = v4:GetPlayerFromCharacter(v8.Parent)
						if phonk.triggerbot.team_check and playerFromCharacter and playerFromCharacter:GetAttribute("TeamID") == localPlayer2:GetAttribute("TeamID") then
							tbl4.is_shooting = false
							continue
						end

						if not tbl4.is_shooting then
							task.wait(phonk.triggerbot.reaction_time)
							tbl4.is_shooting = true
						end

						if localFighter then
							pcall(function()
								if setthreadidentity then
									setthreadidentity(2)
								end

								localFighter:Input("StartShooting")

								if setthreadidentity then
									setthreadidentity(7)
								end
							end)

							task.wait(phonk.triggerbot.shoot_delay)
							continue
						end

						continue
					end

					tbl4.is_shooting = false
					continue
				end

				tbl4.is_shooting = false
			end
		end))
	end

	do
		local tbl3 = {}
		local tbl4 = {}
		local tbl5 = {}

		local tbl6 = {
			Neon = Enum.Material.Neon,
			ForceField = Enum.Material.ForceField,
			Glass = Enum.Material.Glass,
			Metal = Enum.Material.Metal,
			Ice = Enum.Material.Ice,
			Plastic = Enum.Material.Plastic,
		}

		local function fn7(player)
			if tbl3[player] then
				pcall(function()
					tbl3[player]:Destroy()
				end)

				tbl3[player] = nil
			end

			local v8 = tbl4[player]

			if v8 then
				for k, v9 in pairs(v8) do
					if k.Parent then
						local c = v9.c
						local t = v9.t
						local r = v9.r
						k.Material = v9.m
						k.Color = c
						k.Transparency = t
						k.Reflectance = r
					end
				end

				tbl4[player] = nil
			end

			local v9 = tbl5[player]

			if v9 then
				for _, v10 in pairs(v9) do
					pcall(function()
						if v10.Remove then
							v10:Remove()
						else
							v10:Destroy()
						end
					end)
				end

				tbl5[player] = nil
			end
		end

		local function phonkClearEsp()
			for k in pairs(tbl3) do
				fn7(k)
			end

			for k in pairs(tbl4) do
				fn7(k)
			end

			for k in pairs(tbl5) do
				fn7(k)
			end
		end

		local function fn8(arg)
			if tbl5[arg] then
				return tbl5[arg]
			end

			if not Drawing then
				return nil
			end

			local tbl7 = {
				box = Drawing.new("Square"),
				name = Drawing.new("Text"),
				health = Drawing.new("Text"),
				distance = Drawing.new("Text"),
				tracer = Drawing.new("Line"),
			}

			tbl7.box.Filled = false
			tbl7.box.Thickness = 1
			tbl7.name.Size = 14
			tbl7.name.Center = true
			tbl7.name.Outline = true
			tbl7.health.Size = 12
			tbl7.health.Center = true
			tbl7.health.Outline = true
			tbl7.distance.Size = 12
			tbl7.distance.Center = true
			tbl7.distance.Outline = true
			tbl7.tracer.Thickness = 1

			for _, v8 in pairs(tbl7) do
				v8.Visible = false
			end

			tbl5[arg] = tbl7
			return tbl7
		end

		local function fn9(arg)
			local character = arg and arg.Character
			if not character then
				return false
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			return humanoid and humanoid.Health > 0 and humanoidRootPart ~= nil
		end

		local function fn10(arg)
			if arg == localPlayer2 or not fn9(arg) then
				fn7(arg)
				return
			end

			if phonk.esp.team_check then
				if arg:GetAttribute("TeamID") == localPlayer2:GetAttribute("TeamID") then
					fn7(arg)
					return
				end
			end

			local character = arg.Character
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local head = character:FindFirstChild("Head")

			if phonk.esp.highlight.enable then
				local v8 = tbl3[arg]

				if not v8 or not v8.Parent then
					local highlight = Instance.new("Highlight")
					highlight.Name = "phonk_esp"
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.Parent = character
					tbl3[arg] = highlight
					v8 = highlight
				end

				v8.Adornee = character
				v8.FillColor = phonk.esp.highlight.fill_color
				v8.FillTransparency = phonk.esp.highlight.fill_transparency
				v8.OutlineColor = phonk.esp.highlight.outline_color
				v8.OutlineTransparency = phonk.esp.highlight.outline_transparency
			elseif tbl3[arg] then
				pcall(function()
					tbl3[arg]:Destroy()
				end)

				tbl3[arg] = nil
			end

			if phonk.esp.chams.enable then
				local tbl7 = tbl4[arg] or {}
				tbl4[arg] = tbl7
				local neon = tbl6[phonk.esp.chams.material] or Enum.Material.Neon
				local transparency = phonk.esp.chams.ghost and 0.55 or phonk.esp.chams.transparency or 0

				for _, descendant in ipairs(character:GetDescendants()) do
					if descendant:IsA("BasePart") and descendant.Transparency < 1 then
						if not tbl7[descendant] then
							tbl7[descendant] = { m = descendant.Material, c = descendant.Color, t = descendant.Transparency, r = descendant.Reflectance }
						end

						descendant.Material = neon
						descendant.Color = phonk.esp.chams.color
						descendant.Transparency = transparency
						descendant.Reflectance = 0

						if phonk.esp.chams.strip_textures then
							for _, child in ipairs(descendant:GetChildren()) do
								if child:IsA("Decal") or child:IsA("Texture") then
									child.Transparency = 1
								end
							end
						end
					end
				end
			elseif tbl4[arg] then
				for k, v8 in pairs(tbl4[arg]) do
					if k.Parent then
						local c = v8.c
						local t = v8.t
						local r = v8.r
						k.Material = v8.m
						k.Color = c
						k.Transparency = t
						k.Reflectance = r
					end
				end

				tbl4[arg] = nil
			end

			local v8 = fn8(arg)
			if not v8 then
				return
			end
			local v9, v10 = currentCamera:WorldToViewportPoint(humanoidRootPart.Position)

			if not v10 or v9.Z < 0 then
				for _, v11 in pairs(v8) do
					v11.Visible = false
				end

				return
			end

			local value = head and select(1, currentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))) or v9
			local n = math.max(math.abs(value.Y - select(1, currentCamera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))).Y), 8)
			local n2 = n * 0.55
			local n3 = v9.X - n2 / 2
			local y = value.Y

			if phonk.esp.box.enable then
				v8.box.Size = Vector2.new(n2, n)
				v8.box.Position = Vector2.new(n3, y)
				v8.box.Color = phonk.esp.box.color
				v8.box.Thickness = phonk.esp.box.thickness or 1
				v8.box.Visible = true
			else
				v8.box.Visible = false
			end

			if phonk.esp.name.enable then
				v8.name.Text = arg.DisplayName or arg.Name
				v8.name.Position = Vector2.new(v9.X, y - 15)
				v8.name.Color = phonk.esp.name.color
				v8.name.Visible = true
			else
				v8.name.Visible = false
			end

			if phonk.esp.health.enable then
				v8.health.Text = tostring(math.floor(humanoid.Health + 0.5))
				v8.health.Position = Vector2.new(n3 - 12, y + n * (1 - humanoid.Health / math.max(humanoid.MaxHealth, 1)))
				v8.health.Color = phonk.esp.health.color
				v8.health.Visible = true
			else
				v8.health.Visible = false
			end

			if phonk.esp.distance.enable then
				local humanoidRootPart2 = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")
				v8.distance.Text = string.format("%dst", math.floor((humanoidRootPart2 and (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude or 0) + 0.5))
				v8.distance.Position = Vector2.new(v9.X, y + n + 2)
				v8.distance.Color = phonk.esp.distance.color
				v8.distance.Visible = true
			else
				v8.distance.Visible = false
			end

			if phonk.esp.tracer.enable then
				local viewportSize = currentCamera.ViewportSize
				local vector2

				if phonk.esp.tracer.origin == "center" then
					vector2 = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
				elseif phonk.esp.tracer.origin == "mouse" then
					local mouseLocation = v6:GetMouseLocation()
					vector2 = Vector2.new(mouseLocation.X, mouseLocation.Y)
				else
					vector2 = Vector2.new(viewportSize.X / 2, viewportSize.Y)
				end

				v8.tracer.From = vector2
				v8.tracer.To = Vector2.new(v9.X, y + n)
				v8.tracer.Color = phonk.esp.tracer.color
				v8.tracer.Visible = true
			else
				v8.tracer.Visible = false
			end
		end

		v2:Add(v5.RenderStepped:Connect(function()
			if not phonk.esp.enable then
				phonkClearEsp()
				return
			end

			for _, player in ipairs(v4:GetPlayers()) do
				fn10(player)
			end

			for k in pairs(tbl5) do
				if not k.Parent then
					fn7(k)
				end
			end
		end))

		v2:Add(v4.PlayerRemoving:Connect(fn7))
		v2:Add(phonkClearEsp)
		getgenv().phonk_clear_esp = phonkClearEsp
	end

	do
		local atmosphere = v7:FindFirstChildOfClass("Atmosphere")

		if not atmosphere then
			atmosphere = Instance.new("Atmosphere")
			atmosphere.Parent = v7
		end

		local tbl3 = {
			Density = atmosphere.Density,
			Offset = atmosphere.Offset,
			Color = atmosphere.Color,
			Decay = atmosphere.Decay,
			Glare = atmosphere.Glare,
			Haze = atmosphere.Haze,
		}

		local phonkColorCorrection = v7:FindFirstChild("PhonkColorCorrection")

		if not phonkColorCorrection then
			phonkColorCorrection = Instance.new("ColorCorrectionEffect")
			phonkColorCorrection.Name = "PhonkColorCorrection"
			phonkColorCorrection.Enabled = false
			phonkColorCorrection.Parent = v7
		end

		local function phonkUpdateWorldFx()
			local atmosphere2 = phonk.world.atmosphere

			if atmosphere2 and atmosphere2.enable then
				local v8 = atmosphere
				local v9 = atmosphere
				local offset = atmosphere2.offset
				local color = atmosphere2.color
				atmosphere.Density = atmosphere2.density
				v8.Offset = offset
				v9.Color = color
				local v10 = atmosphere
				local v11 = atmosphere
				local decay = atmosphere2.decay
				local glare = atmosphere2.glare
				local haze = atmosphere2.haze
				atmosphere.Decay = decay
				v10.Glare = glare
				v11.Haze = haze
			else
				local v8 = atmosphere
				local v9 = atmosphere
				local offset = tbl3.Offset
				local color = tbl3.Color
				atmosphere.Density = tbl3.Density
				v8.Offset = offset
				v9.Color = color
				local v10 = atmosphere
				local v11 = atmosphere
				local glare = tbl3.Glare
				local haze = tbl3.Haze
				atmosphere.Decay = tbl3.Decay
				v10.Glare = glare
				v11.Haze = haze
			end

			local colorCorrection = phonk.world.color_correction

			if colorCorrection then
				phonkColorCorrection.Enabled = colorCorrection.enable == true

				if colorCorrection.enable then
					local v8 = phonkColorCorrection
					local v9 = phonkColorCorrection
					local v10 = phonkColorCorrection
					local brightness = colorCorrection.brightness
					local contrast = colorCorrection.contrast
					local saturation = colorCorrection.saturation
					local tint = colorCorrection.tint
					phonkColorCorrection.Brightness = brightness
					v8.Contrast = contrast
					v9.Saturation = saturation
					v10.TintColor = tint
				end
			end
		end

		getgenv().phonk_update_world_fx = phonkUpdateWorldFx

		v2:Add(v5.Heartbeat:Connect(function()
			local enable = phonk.world.atmosphere and phonk.world.atmosphere.enable
			local enable2

			if enable then
				enable2 = enable
			else
				enable2 = phonk.world.color_correction and phonk.world.color_correction.enable
			end

			if enable2 then
				phonkUpdateWorldFx()
			end
		end))
	end

	task.spawn(function()
		local ok, result = pcall(function()
			local request_ = syn and syn.request or http and http.request or request or http_request
			local body = nil

			if type(request_) == "function" then
				local v8 = request_({
					Url = "https://raw.githubusercontent.com/Username22477/Keys/refs/heads/main/Keys.txt",
					Method = "GET",
				})

				body = nil

				if type(v8) == "table" then
					body = v8.Body or v8.body
				end
			end

			if type(body) ~= "string" or body == "" then
				local ok, result = pcall(function()
					return game:HttpGet("https://raw.githubusercontent.com/Username22477/Keys/refs/heads/main/Keys.txt")
				end)

				if ok and type(result) == "string" then
					body = result
				end
			end

			if type(body) ~= "string" or body == "" then
				error("keys download failed (not a string)")
			end

			local chunk, v8 = loadstring(body)

			if type(chunk) ~= "function" then
				error("keys compile failed: " .. tostring(v8))
			end

			chunk()
		end)

		if not ok then
			warn("[PhonkWare] Unlock all skipped: " .. tostring(result))
		end
	end)

	task.spawn(function()
		pcall(function()
			local modules = v3:WaitForChild("Modules", 10)
			local controllers = localPlayer2:WaitForChild("PlayerScripts"):WaitForChild("Controllers", 10)
			if not modules or not controllers then
				return
			end
			local CosmeticLibrary = require(modules:WaitForChild("CosmeticLibrary"))
			local EmoteController = require(controllers:WaitForChild("EmoteController"))
			local FighterController = require(controllers:WaitForChild("FighterController"))
			local PlayerDataController = require(controllers:WaitForChild("PlayerDataController"))
			local flag = false
			local v8 = nil
			local v9 = nil
			local connection = nil
			local cameraMode = nil
			local cameraMinZoomDistance = nil

			local function fn7(arg)
				if not arg then
					return
				end

				if type(arg) == "table" then
					if type(arg.Fire) == "function" then
						pcall(function()
							arg:Fire()
						end)
					elseif type(arg.fire) == "function" then
						pcall(function()
							arg:fire()
						end)
					end
				elseif typeof(arg) == "Instance" and arg:IsA("BindableEvent") then
					pcall(function()
						arg:Fire()
					end)
				end
			end

			local function fn8()
				if not flag then
					return
				end
				flag = false
				v8 = nil

				pcall(function()
					if cameraMode ~= nil then
						localPlayer2.CameraMode = cameraMode
						cameraMode = nil
					end

					if cameraMinZoomDistance ~= nil then
						localPlayer2.CameraMinZoomDistance = cameraMinZoomDistance
						cameraMinZoomDistance = nil
					end
				end)

				local fighter = FighterController:GetFighter(localPlayer2)
				local entity = fighter and fighter.Entity

				if entity and entity.EmoteStatusChanged then
					fn7(entity.EmoteStatusChanged)
				end

				if v9 then
					pcall(function()
						v9:Destroy()
					end)

					v9 = nil
				end
			end

			local function fn9(arg)
				if not arg then
					return
				end
				local humanoid = arg:WaitForChild("Humanoid", 10)
				if not humanoid then
					return
				end

				if connection then
					connection:Disconnect()
					connection = nil
				end

				connection = humanoid.Running:Connect(function(arg2)
					if arg2 > 0.1 and flag then
						fn8()
					end
				end)

				v2:Add(connection)
			end

			if localPlayer2.Character then
				fn9(localPlayer2.Character)
			end

			v2:Add(localPlayer2.CharacterAdded:Connect(function(character)
				fn8()
				fn9(character)
			end))

			local ownsCosmetic = CosmeticLibrary.OwnsCosmetic

			CosmeticLibrary.OwnsCosmetic = function(arg, arg2, arg3)
				local v10 = CosmeticLibrary.Cosmetics[arg3]
				if v10 and v10.Type == "Emote" then
					return true
				end
				return ownsCosmetic(arg, arg2, arg3)
			end

			local canEmote = EmoteController.CanEmote

			EmoteController.CanEmote = function(arg, arg2)
				local ok, result = pcall(canEmote, arg, arg2)
				if ok and result then
					return true
				end
				local fighter = FighterController:GetFighter(localPlayer2)

				if fighter and fighter.IsLocalPlayer and fighter:IsAlive() then
					local entity = fighter.Entity
					if entity and not entity:Get("IsFrozen") then
						return true
					end
				end

				return false
			end

			local function fn10()
				local fighter = FighterController:GetFighter(localPlayer2)
				if fighter and fighter.IsLocalPlayer then
					return fighter.Entity
				end
				return nil
			end

			local isEmoting = nil
			local getCurrentEmote = nil
			local v10 = nil

			local function fn11()
				if v10 and isEmoting then
					pcall(function()
						v10.IsEmoting = isEmoting
					end)
				end

				if v10 and getCurrentEmote then
					pcall(function()
						v10.GetCurrentEmote = getCurrentEmote
					end)
				end

				v10 = nil
				isEmoting = nil
				getCurrentEmote = nil
			end

			local function fn12(arg)
				if not arg or v10 == arg then
					return
				end

				if v10 then
					fn11()
				end

				v10 = arg
				isEmoting = arg.IsEmoting
				getCurrentEmote = arg.GetCurrentEmote

				arg.IsEmoting = function(arg2, ...)
					if flag then
						return true
					end
					local v11 = table.pack(...)
					return isEmoting(arg2, table.unpack(v11, 1, v11.n))
				end

				arg.GetCurrentEmote = function(arg2, ...)
					if flag and v8 then
						return v8
					end
					return getCurrentEmote(arg2, ...)
				end
			end

			local useEmoteByName = EmoteController.UseEmoteByName

			EmoteController.UseEmoteByName = function(arg, arg2)
				fn8()
				local v11 = ownsCosmetic(CosmeticLibrary, PlayerDataController:Get("CosmeticInventory"), arg2)

				pcall(function()
					useEmoteByName(arg, arg2)
				end)

				if not v11 then
					task.spawn(function()
						local emotes = modules:FindFirstChild("Emotes")
						local v12 = emotes and emotes:FindFirstChild(arg2)
						local character = localPlayer2.Character
						local humanoid = character and character:FindFirstChildOfClass("Humanoid")

						if v12 and humanoid then
							task.wait(0.1)

							pcall(function()
								v9 = require(v12).new(humanoid)
								cameraMode = localPlayer2.CameraMode
								cameraMinZoomDistance = localPlayer2.CameraMinZoomDistance
								localPlayer2.CameraMode = Enum.CameraMode.Classic
								localPlayer2.CameraMinZoomDistance = 8
								flag = true
								v8 = v9
								local v13 = fn10()

								if v13 then
									fn12(v13)

									if v13.EmoteStatusChanged then
										fn7(v13.EmoteStatusChanged)
									end
								end

								task.defer(v9.Simulate, v9)
								v9.Destroying:Wait()

								if flag then
									fn8()
								end

								fn11()
							end)
						end
					end)
				end
			end

			print("[PhonkWare] Emote unlock ready")
		end)
	end)

	do
		local tbl3 = {
			hitmarker = "rbxassetid://133749572213659",
			fatality = "rbxassetid://6534947869",
			csgo = "rbxassetid://5764885315",
			rust = "rbxassetid://1255040462",
			bonk = "rbxassetid://5766898159",
		}

		local sound = Instance.new("Sound")
		sound.Volume = 1
		sound.Parent = game:GetService("SoundService")
		v2:Add(sound)
		local playHitmarkerSound = nil

		pcall(function()
			local ClientViewModel = require(localPlayer2.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem.ClientViewModel)
			playHitmarkerSound = ClientViewModel.PlayHitmarkerSound

			ClientViewModel.PlayHitmarkerSound = function(arg, arg2, arg3)
				if phonk.hitsounds.enable then
					local customId = phonk.hitsounds.custom_id

					if customId == "" then
						customId = tbl3[phonk.hitsounds.selected]
					end

					if customId and customId ~= "" then
						if not customId:find("rbxassetid://") and not customId:find("rbxasset://") then
							customId = "rbxassetid://" .. customId
						end

						sound.SoundId = customId
						sound.Volume = phonk.hitsounds.volume
						sound.PlaybackSpeed = phonk.hitsounds.pitch

						if sound.IsPlaying then
							sound:Stop()
						end

						sound.TimePosition = 0
						sound:Play()
					end

					return
				end

				if playHitmarkerSound then
					return playHitmarkerSound(arg, arg2, arg3)
				end
			end
		end)

		pcall(function()
			local Utility = require(v3.Modules.Utility)
			local playParticles = Utility.PlayParticles

			Utility.PlayParticles = function(arg, arg2)
				if phonk.remove_muzzle.enable and arg2 and arg2.Name == "_muzzle" then
					return
				end
				return playParticles(arg, arg2)
			end
		end)

		v2:Add(v5.Heartbeat:Connect(function()
			if not phonk.remove_gun_sounds.enable then
				return
			end
			local v8 = ipairs
			local SoundService = game:GetService("SoundService")

			for _, descendant in v8(SoundService:GetDescendants()) do
				if descendant:IsA("Sound") and descendant ~= sound then
					local v9 = string.lower(descendant.Name)

					if v9:find("shoot") or v9:find("gun") or v9:find("fire") or v9:find("muzzle") or v9:find("reload") then
						descendant.Volume = 0
					end
				end
			end

			local viewModels = workspace:FindFirstChild("ViewModels")

			if viewModels then
				for _, descendant in ipairs(viewModels:GetDescendants()) do
					if descendant:IsA("Sound") then
						local v9 = string.lower(descendant.Name)

						if v9:find("shoot") or v9:find("fire") or v9:find("reload") then
							descendant.Volume = 0
						end
					end
				end
			end
		end))
	end

	do
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "PhonkWareDamageNumbers"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 500

		pcall(function()
			screenGui.Parent = gethui and gethui() or game:GetService("CoreGui")
		end)

		if not screenGui.Parent then
			pcall(function()
				screenGui.Parent = localPlayer2:FindFirstChildOfClass("PlayerGui")
			end)
		end

		v2:Add(function()
			pcall(function()
				screenGui:Destroy()
			end)
		end)

		local function fn7(arg)
			local ok, result = pcall(function()
				return Enum.Font[arg]
			end)

			return ok and result or Enum.Font.GothamBold
		end

		local function fn8(arg, arg2, arg3)
			local damageNumbers = phonk.damage_numbers
			if not damageNumbers or not damageNumbers.enable or not arg3 then
				return
			end
			local currentCamera2 = workspace.CurrentCamera
			if not currentCamera2 then
				return
			end
			local v8, v9 = currentCamera2:WorldToViewportPoint(arg3)
			if not v9 then
				return
			end
			local textLabel = Instance.new("TextLabel")
			textLabel.BackgroundTransparency = 1
			textLabel.Size = UDim2.fromOffset(140, 26)
			textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			textLabel.Position = UDim2.fromOffset(v8.X, v8.Y)
			textLabel.Font = fn7(damageNumbers.font or "GothamBold")
			textLabel.TextSize = damageNumbers.text_size or 18
			textLabel.Text = "-" .. tostring(math.floor(arg2 + 0.5))
			textLabel.TextStrokeTransparency = 1
			textLabel.TextColor3 = damageNumbers.color1 or damageNumbers.color or Color3.fromRGB(255, 80, 80)
			textLabel.ZIndex = 10
			textLabel.Parent = screenGui
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Thickness = 1.5
			uiStroke.Color = Color3.new(0, 0, 0)
			uiStroke.Transparency = 0.15
			uiStroke.LineJoinMode = Enum.LineJoinMode.Round
			uiStroke.Parent = textLabel
			local uiScale = Instance.new("UIScale")
			uiScale.Scale = 0.5
			uiScale.Parent = textLabel

			if damageNumbers.color_type == "Gradient" then
				local uiGradient = Instance.new("UIGradient")
				local colorSequence = ColorSequence.new
				local tbl3 = {}
				local v10 = ColorSequenceKeypoint.new(0, damageNumbers.color1 or Color3.fromRGB(255, 80, 80))
				local new = ColorSequenceKeypoint.new
				local color2 = damageNumbers.color2 or Color3.fromRGB(255, 200, 80)
				local v11 = table.pack(new(1, color2))
				tbl3[1] = v10

				do
					local values = table.pack(table.unpack(v11, 1, v11.n))
					table.move(values, 1, values.n, 2, tbl3)
				end

				uiGradient.Color = colorSequence(tbl3)
				uiGradient.Rotation = 90
				uiGradient.Parent = textLabel
				textLabel.TextColor3 = Color3.new(1, 1, 1)
			end

			local x = v8.X
			local y = v8.Y
			local n = math.random(-14, 14)
			local now2 = tick()
			local duration = damageNumbers.duration or 0.8
			local rise = damageNumbers.rise or 42
			local connection = nil

			connection = v5.RenderStepped:Connect(function()
				local n2 = (tick() - now2) / duration

				if n2 >= 1 then
					connection:Disconnect()

					pcall(function()
						textLabel:Destroy()
					end)

					return
				end

				local n3 = 1 - (1 - n2) * (1 - n2)
				textLabel.Position = UDim2.fromOffset(x + n * n3, y - rise * n3)
				uiScale.Scale = 0.5 + 0.6 * math.min(n2 * 3, 1)
				local textTransparency = n2 > 0.55 and (n2 - 0.55) / 0.45 or 0
				textLabel.TextTransparency = textTransparency
				uiStroke.Transparency = 0.15 + textTransparency * 0.85
			end)
		end

		local function fn9()
			return (pcall(function()
				local localFighter = require(localPlayer2.PlayerScripts.Controllers.FighterController).LocalFighter
				if not localFighter or not localFighter.ReplicateFromServer then
					return
				end

				if localFighter._phonk_dmg_hooked then
					return
				end
				localFighter._phonk_dmg_hooked = true
				local replicateFromServer = localFighter.ReplicateFromServer

				localFighter.ReplicateFromServer = function(arg, arg2, ...)
					local v8 = table.pack(...)

					if arg2 ~= "DamageNumberEffect" then
						local v9 = table.pack(...)
						local v10 = replicateFromServer
						v9.n = 3 + v9.n - 1
						table.move(v9, 1, v9.n, 3, v9)
						v9[1] = arg
						v9[2] = arg2
						return v10(table.unpack(v9, 1, v9.n))
					end

					local tbl3 = { ... }
					local v9 = tbl3[1]
					local v10 = tbl3[2]
					local v11 = tbl3[3]

					if v9 and v10 then
						local parent = typeof(v9) == "Instance" and v9.Parent

						if parent and parent:FindFirstChildOfClass("Humanoid") then
							if phonk.damage_numbers.enable then
								local n = nil

								pcall(function()
									n = v9.Position + Vector3.new(0, v11 and 2.6 or 2.1, 0)
								end)

								if n then
									fn8(v4:GetPlayerFromCharacter(parent), v10, n)
								end
							end

							if phonk.damage_numbers.enable or phonk.damage_numbers.remove_ingame then
								return
							end
						end
					end

					return replicateFromServer(arg, arg2, table.unpack(v8, 1, v8.n))
				end
			end))
		end

		task.spawn(function()
			for i = 1, 60 do
				if not fn9() then
					task.wait(0.25)
					continue
				end
				break
			end
		end)

		v2:Add(localPlayer2.CharacterAdded:Connect(function()
			task.wait(0.8)

			pcall(function()
				local FighterController = require(localPlayer2.PlayerScripts.Controllers.FighterController)

				if FighterController.LocalFighter then
					FighterController.LocalFighter._phonk_dmg_hooked = nil
				end
			end)

			fn9()
		end))
	end

	do
		local tbl3 = {}

		local function fn7(arg)
			local value = rawget(arg, "Animator")
			if not value or tbl3[value] then
				return
			end
			tbl3[value] = true
			local v8 = getmetatable(value)
			local value2 = rawget(value, "PlayAnimation") or v8 and rawget(v8, "PlayAnimation")
			if not value2 then
				return
			end

			value.PlayAnimation = function(arg2, arg3, ...)
				local disableAnims = phonk.disable_anims

				if disableAnims.enable then
					local str = tostring(arg3):lower()
					local v9 = table.find(disableAnims.select, "shoot")
					local pos

					if v9 then
						pos = str:find("shoot") or str:find("fire")
					else
						pos = v9
					end

					if pos then
						return
					end

					if table.find(disableAnims.select, "reload") and str:find("reload") then
						return
					end

					if table.find(disableAnims.select, "equip") and str:find("equip") then
						return
					end

					if table.find(disableAnims.select, "attack") and str:find("attack") then
						return
					end

					if table.find(disableAnims.select, "charge") and str:find("charge") then
						return
					end

					if table.find(disableAnims.select, "throw") and str:find("throw") then
						return
					end
				end

				local v9 = table.pack(...)
				local v10 = value2
				v9.n = 3 + v9.n - 1
				table.move(v9, 1, v9.n, 3, v9)
				v9[1] = arg2
				v9[2] = arg3
				return v10(table.unpack(v9, 1, v9.n))
			end
		end

		local ClientViewModel = require(localPlayer2.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem.ClientViewModel)
		local update = ClientViewModel.Update

		ClientViewModel.Update = function(arg, arg2, arg3, arg4)
			if arg.ClientItem.ClientFighter.IsLocalPlayer then
				fn7(arg)
				local disableAnims = phonk.disable_anims

				if disableAnims.enable then
					if table.find(disableAnims.select, "bobbing") then
						arg._bobbing_value_spring.Value = Vector2.new(0, 0)
						arg._bobbing_value_spring.Target = Vector2.new(0, 0)
						arg._bobbing_speed_spring.Value = 0
						arg._bobbing_speed_spring.Target = 0
						arg._bobbing_tick = 0
					end

					if table.find(disableAnims.select, "landing") then
						arg._landing_spring.Value = 0
						arg._landing_spring.Target = 0
						arg._jump_spring.Value = 0
						arg._jump_spring.Target = 0
					end

					if table.find(disableAnims.select, "sway") then
						arg._sway_spring.Value = Vector2.new(0, 0)
						arg._sway_spring.Target = Vector2.new(0, 0)
						arg._tilt_spring.Value = Vector2.new(0, 0)
						arg._tilt_spring.Target = Vector2.new(0, 0)
					end

					if table.find(disableAnims.select, "equip") then
						arg._equip_spring.Position = arg._equip_spring.Target
						arg._equip_spring.Velocity = 0
					end

					if table.find(disableAnims.select, "inspect") then
						arg._inspect_spring.Position = arg._inspect_spring.Target
						arg._inspect_spring.Velocity = 0
					end

					if table.find(disableAnims.select, "sliding") and arg3 then
						arg3.IsSliding = false
					end

					if table.find(disableAnims.select, "shoot") then
						arg._recoil_spring.Value = Vector3.zero
						arg._recoil_spring.Target = Vector3.zero
						arg._unrecoil_spring.Value = Vector3.zero
						arg._unrecoil_spring.Target = Vector3.zero
					end

					if table.find(disableAnims.select, "impulse") then
						arg._impulse_position_spring.Value = Vector3.zero
						arg._impulse_position_spring.Target = Vector3.zero
					end

					if table.find(disableAnims.select, "aim") then
						arg._aim_spring.Position = arg._aim_spring.Target
						arg._aim_spring.Velocity = 0
					end

					if table.find(disableAnims.select, "sprint") and arg3 then
						arg3.IsActuallySprinting = false
					end
				end
			end

			return update(arg, arg2, arg3, arg4)
		end

		v2:Add(function()
			ClientViewModel.Update = update
		end)
	end

	do
		local tbl3 = { ParticleEmitter = true, Trail = true, Smoke = true, Fire = true, Sparkles = true }

		local tbl4 = {
			BloomEffect = true,
			BlurEffect = true,
			ColorCorrectionEffect = true,
			SunRaysEffect = true,
			DepthOfFieldEffect = true,
		}

		local obj = setmetatable({}, { __mode = "k" })
		local obj2 = setmetatable({}, { __mode = "k" })
		local obj3 = setmetatable({}, { __mode = "k" })

		local function fn7(arg, arg2)
			if not tbl3[arg.ClassName] then
				return
			end

			if arg2 then
				if obj[arg] == nil then
					obj[arg] = arg.Enabled
				end

				pcall(function()
					arg.Enabled = false
				end)
			elseif obj[arg] ~= nil then
				pcall(function()
					arg.Enabled = obj[arg]
				end)

				obj[arg] = nil
			end
		end

		local function fn8(arg, arg2)
			if not (arg:IsA("Decal") or arg:IsA("Texture")) then
				return
			end

			if arg2 then
				if obj2[arg] == nil then
					obj2[arg] = arg.Transparency
				end

				pcall(function()
					arg.Transparency = 1
				end)
			elseif obj2[arg] ~= nil then
				pcall(function()
					arg.Transparency = obj2[arg]
				end)

				obj2[arg] = nil
			end
		end

		local function fn9(arg, arg2)
			if not tbl4[arg.ClassName] then
				return
			end

			if arg2 then
				if obj3[arg] == nil then
					obj3[arg] = arg.Enabled
				end

				pcall(function()
					arg.Enabled = false
				end)
			elseif obj3[arg] ~= nil then
				pcall(function()
					arg.Enabled = obj3[arg]
				end)

				obj3[arg] = nil
			end
		end

		v2:Add(workspace.DescendantAdded:Connect(function(descendant)
			if phonk.optimizations.no_particles then
				fn7(descendant, true)
			end

			if phonk.optimizations.no_textures then
				fn8(descendant, true)
			end
		end))

		v2:Add(v7.DescendantAdded:Connect(function(descendant)
			if phonk.optimizations.no_postfx then
				fn9(descendant, true)
			end
		end))

		getgenv().phonk_apply_opt = function()
			local optimizations = phonk.optimizations

			if optimizations.no_shadows then
				pcall(function()
					v7.GlobalShadows = false
				end)
			end

			if optimizations.no_atmosphere then
				local atmosphere = v7:FindFirstChildOfClass("Atmosphere")

				if atmosphere then
					pcall(function()
						atmosphere.Density = 0
					end)
				end
			end

			if setfpscap then
				if optimizations.fps_cap_enable then
					pcall(setfpscap, optimizations.fps_cap)
				else
					pcall(setfpscap, 1000)
				end
			end

			task.spawn(function()
				if optimizations.no_particles or optimizations.no_textures then
					local descendants = workspace:GetDescendants()

					for i = 1, #descendants do
						if optimizations.no_particles then
							fn7(descendants[i], true)
						end

						if optimizations.no_textures then
							fn8(descendants[i], true)
						end

						if i % 800 == 0 then
							task.wait()
						end
					end
				end

				if optimizations.no_postfx then
					for _, descendant in ipairs(v7:GetDescendants()) do
						fn9(descendant, true)
					end
				end
			end)
		end
	end

	do
		local tbl3 = {}
		local connection = nil
		local flag = false

		local function fn7(arg)
			if tbl3[arg] then
				return
			end
			tbl3[arg] = { Material = arg.Material, Color = arg.Color }
		end

		local function fn8(arg)
			local v8 = tbl3[arg]

			if v8 and arg.Parent then
				arg.Material = v8.Material
				arg.Color = v8.Color
			end

			tbl3[arg] = nil
		end

		local function fn9(arg)
			if not arg:IsA("BasePart") then
				return
			end

			if arg:FindFirstChildOfClass("Humanoid") then
				return
			end

			if arg:IsDescendantOf(localPlayer2.Character) then
				return
			end
			fn7(arg)
			local v8 = Enum.Material[phonk.map_textures.material]

			if v8 then
				arg.Material = v8
			end

			arg.Color = phonk.map_textures.color
		end

		local function fn10()
			if flag then
				return
			end
			flag = true

			task.spawn(function()
				local descendants = workspace:GetDescendants()

				for i = 1, #descendants do
					fn9(descendants[i])

					if i % 500 == 0 then
						task.wait()
					end
				end

				flag = false
			end)
		end

		local function fn11()
			for k in pairs(tbl3) do
				fn8(k)
			end
		end

		v2:Add(function()
			if connection then
				connection:Disconnect()
			end

			fn11()
		end)

		getgenv().phonk_update_textures = function()
			if phonk.map_textures.enable then
				fn10()

				if not connection then
					connection = workspace.DescendantAdded:Connect(function(descendant)
						if phonk.map_textures.enable then
							fn9(descendant)
						end
					end)
				end
			else
				if connection then
					connection:Disconnect()
					connection = nil
				end

				fn11()
			end
		end
	end

	do
		local tbl3 = {
			["Deep Space"] = {
				Bk = "http://www.roblox.com/asset/?id=159248188",
				Dn = "http://www.roblox.com/asset/?id=159248183",
				Ft = "http://www.roblox.com/asset/?id=159248187",
				Lf = "http://www.roblox.com/asset/?id=159248173",
				Rt = "http://www.roblox.com/asset/?id=159248192",
				Up = "http://www.roblox.com/asset/?id=159248176",
			},
			["Purple Nebula"] = {
				Bk = "http://www.roblox.com/asset/?id=159454299",
				Dn = "http://www.roblox.com/asset/?id=159454296",
				Ft = "http://www.roblox.com/asset/?id=159454293",
				Lf = "http://www.roblox.com/asset/?id=159454286",
				Rt = "http://www.roblox.com/asset/?id=159454300",
				Up = "http://www.roblox.com/asset/?id=159454288",
			},
			Vaporwave = {
				Bk = "http://www.roblox.com/asset/?id=1417494030",
				Dn = "http://www.roblox.com/asset/?id=1417494146",
				Ft = "http://www.roblox.com/asset/?id=1417494030",
				Lf = "http://www.roblox.com/asset/?id=1417494030",
				Rt = "http://www.roblox.com/asset/?id=1417494030",
				Up = "http://www.roblox.com/asset/?id=1417494643",
			},
			Night = {
				Bk = "rbxassetid://48020371",
				Dn = "rbxassetid://48020144",
				Ft = "rbxassetid://48020234",
				Lf = "rbxassetid://48020211",
				Rt = "rbxassetid://48020254",
				Up = "rbxassetid://48020383",
			},
			Space = {
				Bk = "rbxassetid://149397692",
				Dn = "rbxassetid://149397686",
				Ft = "rbxassetid://149397697",
				Lf = "rbxassetid://149397684",
				Rt = "rbxassetid://149397688",
				Up = "rbxassetid://149397702",
			},
			Minecraft = {
				Bk = "rbxassetid://1876545003",
				Dn = "rbxassetid://1876544331",
				Ft = "rbxassetid://1876542941",
				Lf = "rbxassetid://1876543392",
				Rt = "rbxassetid://1876543764",
				Up = "rbxassetid://1876544642",
			},
			Sunset = {
				Bk = "rbxassetid://150939022",
				Dn = "rbxassetid://150939038",
				Ft = "rbxassetid://150939047",
				Lf = "rbxassetid://150939056",
				Rt = "rbxassetid://150939063",
				Up = "rbxassetid://150939082",
			},
			Default = {
				Bk = "rbxassetid://6444884337",
				Dn = "rbxassetid://6444884785",
				Ft = "rbxassetid://6444884337",
				Lf = "rbxassetid://6444884337",
				Rt = "rbxassetid://6444884337",
				Up = "rbxassetid://6412503613",
			},
		}

		local clone = nil

		pcall(function()
			local sky = v7:FindFirstChildOfClass("Sky")

			if sky then
				clone = sky:Clone()
			end
		end)

		getgenv().phonk_update_sky = function()
			for _, child in ipairs(v7:GetChildren()) do
				if child:IsA("Sky") then
					child:Destroy()
				end
			end

			local clone2

			if not phonk.world.skybox.enable then
				clone2 = nil

				if clone then
					clone2 = clone:Clone()
					clone2.Parent = v7
				end
			else
				local v8 = tbl3[phonk.world.skybox.selected]
				clone2 = nil

				if v8 then
					clone2 = Instance.new("Sky")
					clone2.SkyboxBk = v8.Bk
					clone2.SkyboxDn = v8.Dn
					clone2.SkyboxFt = v8.Ft
					clone2.SkyboxLf = v8.Lf
					clone2.SkyboxRt = v8.Rt
					clone2.SkyboxUp = v8.Up
					clone2.Parent = v7
				end
			end

			if clone2 then
				if phonk.world.skybox.remove_sun then
					clone2.SunTextureId = ""
				end

				if phonk.world.skybox.remove_moon then
					clone2.MoonTextureId = ""
				end

				if phonk.world.skybox.remove_stars then
					clone2.StarCount = 0
				end
			end
		end
	end

	local n = 0

	v2:Add(v5.Heartbeat:Connect(function(deltaTime)
		local sky = v7:FindFirstChildOfClass("Sky")

		if phonk.world.skybox.rotate and sky then
			n += deltaTime * phonk.world.skybox.rotate_speed * 0.5
			local n2

			if phonk.world.skybox.rotate_method == "Spin" then
				n2 = n * 20 % 360
			elseif phonk.world.skybox.rotate_method == "Wave" then
				n2 = math.sin(n) * 180
			else
				n2 = 0

				if phonk.world.skybox.rotate_method == "Alternate" then
					n2 = math.abs(n * 40 % 720 - 360) - 180
				end
			end

			local vector = Vector3.zero

			if phonk.world.skybox.rotate_direction == "Horizontal" then
				vector = Vector3.new(0, n2, 0)
			elseif phonk.world.skybox.rotate_direction == "Vertical" then
				vector = Vector3.new(n2, 0, 0)
			elseif phonk.world.skybox.rotate_direction == "Diagonal" then
				vector = Vector3.new(n2, n2, n2)
			end

			pcall(function()
				sky.SkyboxOrientation = vector
			end)
		end
	end))

	local tbl3
	tbl3 = {}

	do
		local snow = {}
		local numberSequence = NumberSequence.new
		local tbl4 = {}
		local v8 = NumberSequenceKeypoint.new(0, 0.7375)
		local v9 = NumberSequenceKeypoint.new(0.973, 0.76875)
		local new = NumberSequenceKeypoint.new
		tbl4[1] = v8
		tbl4[2] = v9

		do
			local values = table.pack(new(1, 1))
			table.move(values, 1, values.n, 3, tbl4)
		end

		snow.Transparency = numberSequence(tbl4)
		snow.Texture = "http://www.roblox.com/asset/?id=99851851"
		snow.SpreadAngle = Vector2.new(50, 50)
		snow.Speed = NumberRange.new(30, 30)
		snow.LightEmission = 10
		snow.Rate = 1000
		snow.EmissionDirection = Enum.NormalId.Bottom
		local numberSequence2 = NumberSequence.new
		local tbl5 = {}
		local v10 = NumberSequenceKeypoint.new(0, 0.331)
		local v11 = NumberSequenceKeypoint.new(0.551, 0.402)
		local new2 = NumberSequenceKeypoint.new
		tbl5[1] = v10
		tbl5[2] = v11

		do
			local values = table.pack(new2(1, 0.331))
			table.move(values, 1, values.n, 3, tbl5)
		end

		snow.Size = numberSequence2(tbl5)
		tbl3.snow = snow
	end

	do
		local rain = {
			Speed = NumberRange.new(60, 60),
			LockedToPart = true,
			Rate = 600,
			Texture = "rbxassetid://1822883048",
			EmissionDirection = Enum.NormalId.Bottom,
		}

		local numberSequence = NumberSequence.new
		local tbl4 = {}
		local v8 = NumberSequenceKeypoint.new(0, 1)
		local v9 = NumberSequenceKeypoint.new(0.25, 0.784)
		local v10 = NumberSequenceKeypoint.new(0.75, 0.784)
		local new = NumberSequenceKeypoint.new
		tbl4[1] = v8
		tbl4[2] = v9
		tbl4[3] = v10

		do
			local values = table.pack(new(1, 1))
			table.move(values, 1, values.n, 4, tbl4)
		end

		rain.Transparency = numberSequence(tbl4)
		rain.Lifetime = NumberRange.new(0.8, 0.8)
		rain.LightEmission = 0.05
		rain.LightInfluence = 0.9
		rain.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp
		local new2 = NumberSequenceKeypoint.new
		rain.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 10), new2(1, 10) })
		tbl3.rain = rain
	end

	do
		local new = NumberSequenceKeypoint.new

		local tbl4 = {
			LockedToPart = true,
			Rate = 500,
			Squash = NumberSequence.new({ NumberSequenceKeypoint.new(0, 3), new(1, 3) }),
			LightInfluence = 0.3,
		}

		local numberSequence = NumberSequence.new
		local tbl5 = {}
		local v8 = NumberSequenceKeypoint.new(0, 0)
		local v9 = NumberSequenceKeypoint.new(0.435, 0)
		local new2 = NumberSequenceKeypoint.new
		tbl5[1] = v8
		tbl5[2] = v9

		do
			local values = table.pack(new2(1, 0))
			table.move(values, 1, values.n, 3, tbl5)
		end

		tbl4.Transparency = numberSequence(tbl5)
		tbl4.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		tbl4.Speed = NumberRange.new(30, 50)
		tbl4.Lifetime = NumberRange.new(9, 9)
		tbl4.LightEmission = 0.5
		tbl4.Brightness = 2
		tbl4.EmissionDirection = Enum.NormalId.Bottom
		tbl4.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp
		local new3 = NumberSequenceKeypoint.new
		tbl4.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), new3(1, 0.2) })
		tbl3["light rain"] = tbl4
	end

	do
		local tbl4 = {}
		local type_ = phonk.world.weather and phonk.world.weather.type or "snow"

		if not tbl3[type_] then
			type_ = "snow"
		end

		local part = Instance.new("Part")
		part.Size = Vector3.new(40, 40, 85)
		part.CanCollide = false
		part.Massless = true
		part.Transparency = 1
		part.Anchored = true
		part.Name = "PhonkWareWeather"
		part.Parent = workspace
		local particleEmitter = Instance.new("ParticleEmitter")

		for k, v8 in pairs(tbl3[type_]) do
			pcall(function()
				particleEmitter[k] = v8
			end)
		end

		particleEmitter.Color = ColorSequence.new(phonk.world.weather and phonk.world.weather.color or Color3.new(1, 1, 1))
		particleEmitter.Enabled = false
		particleEmitter.Parent = part
		tbl4.part = part
		tbl4.emitter = particleEmitter
		tbl4.last_type = type_
		v2:Add(part)

		local function fn7()
			if tbl4.emitter then
				pcall(function()
					tbl4.emitter:Destroy()
				end)
			end

			local type_2 = phonk.world.weather and phonk.world.weather.type or "snow"

			if not tbl3[type_2] then
				type_2 = "snow"
			end

			local particleEmitter2 = Instance.new("ParticleEmitter")

			for k, v8 in pairs(tbl3[type_2]) do
				pcall(function()
					particleEmitter2[k] = v8
				end)
			end

			particleEmitter2.Color = ColorSequence.new(phonk.world.weather and phonk.world.weather.color or Color3.new(1, 1, 1))
			particleEmitter2.Enabled = true
			particleEmitter2.Parent = tbl4.part
			tbl4.emitter = particleEmitter2
			tbl4.last_type = type_2
		end

		getgenv().phonk_update_weather = function()
			if not phonk.world.weather or not phonk.world.weather.enable then
				if tbl4.emitter then
					tbl4.emitter.Enabled = false
				end

				return
			end

			if tbl4.last_type ~= phonk.world.weather.type then
				fn7()
			end

			if tbl4.emitter then
				tbl4.emitter.Enabled = true
				tbl4.emitter.Rate = phonk.world.weather.rate or 100
				tbl4.emitter.Color = ColorSequence.new(phonk.world.weather.color or Color3.new(1, 1, 1))
			end
		end

		v2:Add(v5.RenderStepped:Connect(function()
			if not phonk.world.weather or not phonk.world.weather.enable then
				if tbl4.emitter then
					tbl4.emitter.Enabled = false
				end

				return
			end

			if tbl4.last_type ~= phonk.world.weather.type then
				fn7()
			end

			tbl4.emitter.Enabled = true
			tbl4.emitter.Rate = phonk.world.weather.rate or 100
			tbl4.emitter.Color = ColorSequence.new(phonk.world.weather.color or Color3.new(1, 1, 1))

			if tbl4.part and currentCamera then
				tbl4.part.CFrame = CFrame.new(currentCamera.CFrame.Position + Vector3.new(0, 20, 0))
			end
		end))
	end

	do
		local function fn7(arg, displayName)
			if not arg or not displayName or displayName == "" then
				return
			end

			pcall(function()
				arg.DisplayName = displayName
			end)

			pcall(function()
				local character = arg.Character

				if character then
					local humanoid = character:FindFirstChildOfClass("Humanoid")

					if humanoid then
						humanoid.DisplayName = displayName
					end
				end
			end)
		end

		local function fn8()
			pcall(function()
				if phonk.spoof.level.enable then
					localPlayer2:SetAttribute("Level", phonk.spoof.level.value)
				end

				if phonk.spoof.streak.enable then
					localPlayer2:SetAttribute("StatisticDuelsWinStreak", phonk.spoof.streak.value)
				end
			end)
		end

		local function fn9()
			if phonk.profile.spoof_local and phonk.profile.spoof_local_name ~= "" then
				fn7(localPlayer2, phonk.profile.spoof_local_name)
			end

			if phonk.profile.spoof_other and phonk.profile.spoof_other_name ~= "" then
				for _, player in ipairs(v4:GetPlayers()) do
					if player ~= localPlayer2 then
						fn7(player, phonk.profile.spoof_other_name)
					end
				end
			end
		end

		v2:Add(v5.Heartbeat:Connect(function()
			fn8()
			fn9()
		end))

		v2:Add(v4.PlayerAdded:Connect(function(player)
			task.wait(0.5)

			if phonk.profile.spoof_other and phonk.profile.spoof_other_name ~= "" and player ~= localPlayer2 then
				fn7(player, phonk.profile.spoof_other_name)
			end
		end))

		v2:Add(localPlayer2.CharacterAdded:Connect(function()
			task.wait(0.3)
			fn9()
			fn8()
		end))
	end

	v2:Add(v5.Heartbeat:Connect(function()
		if phonk.infinite_double_jump.enable then
			pcall(function()
				MechanicsController._double_jumps_used = {}
			end)
		end

		if phonk.viewmodel_offsets.enable then
			for k, v8 in next, ItemLibrary.ViewModels, nil do
				if oldoffsets[k] then
					v8.RootPartOffset = CFrame.new(oldoffsets[k].X + phonk.viewmodel_offsets.x, oldoffsets[k].Y + phonk.viewmodel_offsets.y, oldoffsets[k].Z + phonk.viewmodel_offsets.z)
				end
			end
		end
	end))

	do
		local walkSpeed = 16
		local flag = false

		local function fn7(arg)
			if not phonk.walkspeed.enable then
				return
			end
			flag = true
			arg.WalkSpeed = walkSpeed * phonk.walkspeed.multiplier
			flag = false
		end

		local function fn8(arg)
			walkSpeed = arg.WalkSpeed

			v2:Add(arg:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
				if flag then
					return
				end
				walkSpeed = arg.WalkSpeed
				fn7(arg)
			end))

			fn7(arg)
		end

		local function fn9(character)
			local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)

			if humanoid then
				fn8(humanoid)
			end
		end

		if localPlayer2.Character then
			fn9(localPlayer2.Character)
		end

		v2:Add(localPlayer2.CharacterAdded:Connect(fn9))
		local flag2 = false

		v2:Add(v5.Heartbeat:Connect(function()
			local character = localPlayer2.Character
			character = character and character:FindFirstChildOfClass("Humanoid")
			if not character then
				return
			end

			if phonk.walkspeed.enable then
				flag2 = true
				local walkSpeed2 = walkSpeed * phonk.walkspeed.multiplier

				if math.abs(character.WalkSpeed - walkSpeed2) > 0.05 then
					flag = true
					character.WalkSpeed = walkSpeed2
					flag = false
				end
			elseif flag2 then
				flag2 = false
				flag = true
				character.WalkSpeed = walkSpeed
				flag = false
			end
		end))
	end

	v2:Add(v5.RenderStepped:Connect(function()
		if phonk.slide_boost.enable and MechanicsController.IsSliding then
			pcall(function()
				MechanicsController._sliding_velocity.Velocity = MechanicsController._sliding_velocity.Velocity.Unit * phonk.slide_boost.speed
			end)
		end
	end))

	do
		local flag = false
		local bodyVelocity = nil
		local bodyGyro = nil

		local function fn7()
			flag = false

			if bodyVelocity then
				pcall(function()
					bodyVelocity:Destroy()
				end)

				bodyVelocity = nil
			end

			if bodyGyro then
				pcall(function()
					bodyGyro:Destroy()
				end)

				bodyGyro = nil
			end

			local character = localPlayer2.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				pcall(function()
					humanoid.PlatformStand = false
				end)
			end

			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				pcall(function()
					humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				end)
			end
		end

		local function fn8(arg)
			local v8 = options[arg]
			if not v8 then
				return false
			end

			if type(v8.GetState) == "function" then
				local ok, result = pcall(function()
					return v8:GetState()
				end)

				if ok then
					return result == true
				end
			end

			if v8.Mode == "Hold" and v8.Value and v8.Value ~= "None" then
				local ok, result = pcall(function()
					return v6:IsKeyDown(Enum.KeyCode[v8.Value])
				end)

				return ok and result == true
			end

			if v8.Mode == "Always" then
				return true
			end

			if v8.Mode == "Toggle" then
				return v8.Toggled == true
			end
			return false
		end

		local function fn9()
			if not phonk.fly.enable then
				return false
			end
			local phonkMobileBtns = getgenv().phonk_mobile_btns
			if phonkMobileBtns and phonkMobileBtns.fly then
				return true
			end
			return fn8("fly_key")
		end

		v2:Add(v5.Heartbeat:Connect(function()
			local v8 = fn9()
			local character = localPlayer2.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if v8 and humanoidRootPart and humanoid then
				if not flag or not bodyVelocity or not bodyVelocity.Parent or not bodyGyro or not bodyGyro.Parent then
					fn7()
					flag = true
					bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Name = "PhonkWareFlyBV"
					bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
					bodyVelocity.Velocity = Vector3.zero
					bodyVelocity.Parent = humanoidRootPart
					bodyGyro = Instance.new("BodyGyro")
					bodyGyro.Name = "PhonkWareFlyBG"
					bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
					bodyGyro.P = 10000
					bodyGyro.Parent = humanoidRootPart

					pcall(function()
						humanoid.PlatformStand = true
					end)
				end

				local phonkMobileBtns = getgenv().phonk_mobile_btns
				phonkMobileBtns = phonkMobileBtns and phonkMobileBtns.fly
				local vector = Vector3.zero

				if v6:IsKeyDown(Enum.KeyCode.W) then
					vector = Vector3.zero + currentCamera.CFrame.LookVector
				end

				if v6:IsKeyDown(Enum.KeyCode.S) then
					vector -= currentCamera.CFrame.LookVector
				end

				if v6:IsKeyDown(Enum.KeyCode.A) then
					vector -= currentCamera.CFrame.RightVector
				end

				if v6:IsKeyDown(Enum.KeyCode.D) then
					vector += currentCamera.CFrame.RightVector
				end

				if v6:IsKeyDown(Enum.KeyCode.Space) then
					vector += Vector3.new(0, 1, 0)
				end

				if v6:IsKeyDown(Enum.KeyCode.LeftControl) or v6:IsKeyDown(Enum.KeyCode.LeftShift) then
					vector -= Vector3.new(0, 1, 0)
				end

				if phonkMobileBtns and vector.Magnitude < 0.05 then
					vector = humanoid.MoveDirection

					if not (vector.Magnitude > 0.05) then
						vector = Vector3.zero
					end
				end

				if vector.Magnitude > 0 then
					vector = vector.Unit * (phonk.fly.speed or 50)
				end

				if bodyVelocity and bodyVelocity.Parent then
					bodyVelocity.Velocity = vector
				end

				if bodyGyro and bodyGyro.Parent then
					pcall(function()
						bodyGyro.CFrame = currentCamera.CFrame
					end)
				end

				if bodyGyro and bodyGyro.Parent then
					bodyGyro.CFrame = currentCamera.CFrame
				end
			elseif flag then
				fn7()
			end
		end))

		v2:Add(v5.Heartbeat:Connect(function()
			if not phonk.fly.enable and flag then
				fn7()
			end
		end))

		v2:Add(localPlayer2.CharacterAdded:Connect(function()
			fn7()
		end))

		v2:Add(fn7)
	end

	do
		local flag = false
		local custom = Enum.CameraType.Custom
		local cameraSubject = nil
		local cFrame = nil
		local n2 = 0
		local n3 = 0

		local function fn7(arg)
			local v8 = options[arg]
			if not v8 then
				return false
			end

			if type(v8.GetState) == "function" then
				local ok, result = pcall(function()
					return v8:GetState()
				end)

				if ok then
					return result == true
				end
			end

			if v8.Mode == "Always" then
				return true
			end

			if v8.Mode == "Toggle" then
				return v8.Toggled == true
			end

			if v8.Mode == "Hold" and v8.Value and v8.Value ~= "None" then
				local ok, result = pcall(function()
					return v6:IsKeyDown(Enum.KeyCode[v8.Value])
				end)

				return ok and result == true
			end

			return false
		end

		local function fn8(arg)
			local y = arg.LookVector.Y
			return math.atan2(-arg.LookVector.X, -arg.LookVector.Z), (math.asin(math.clamp(y, -1, 1)))
		end

		local function fn9()
			if not flag then
				return
			end
			flag = false
			cFrame = nil

			pcall(function()
				v6.MouseBehavior = Enum.MouseBehavior.Default
				currentCamera.CameraType = custom or Enum.CameraType.Custom
				local character = localPlayer2.Character
				character = character and character:FindFirstChildOfClass("Humanoid")

				if character then
					currentCamera.CameraSubject = character
				elseif cameraSubject then
					currentCamera.CameraSubject = cameraSubject
				end
			end)
		end

		local function fn10()
			if flag then
				return
			end
			flag = true
			custom = currentCamera.CameraType
			cameraSubject = currentCamera.CameraSubject
			cFrame = currentCamera.CFrame
			local v8, v9 = fn8(cFrame)
			n2 = v8
			n3 = v9

			pcall(function()
				currentCamera.CameraType = Enum.CameraType.Scriptable
				currentCamera.CameraSubject = nil
				v6.MouseBehavior = Enum.MouseBehavior.LockCenter
			end)
		end

		v2:Add(v5.RenderStepped:Connect(function(deltaTime)
			local phonkMobileBtns = getgenv().phonk_mobile_btns

			if not (phonk.freecam.enable and (phonkMobileBtns and phonkMobileBtns.freecam or fn7("freecam_key"))) then
				if flag then
					fn9()
				end

				return
			end

			if not flag then
				fn10()
			end

			deltaTime = deltaTime or 0.016

			pcall(function()
				currentCamera.CameraType = Enum.CameraType.Scriptable
				currentCamera.CameraSubject = nil
			end)

			if not cFrame then
				cFrame = currentCamera.CFrame
				local v8, v9 = fn8(cFrame)
				n2 = v8
				n3 = v9
			end

			local mouseDelta = v6:GetMouseDelta()
			n2 -= math.rad(mouseDelta.X * 0.35)
			n3 = math.clamp(n3 - math.rad(mouseDelta.Y * 0.35), -1.5533430342749532, 1.5533430342749532)
			local n4 = CFrame.Angles(0, n2, 0) * CFrame.Angles(n3, 0, 0)
			local position = cFrame.Position
			local n5 = (phonk.freecam.speed or 50) * 0.15 * deltaTime * 60
			local lookVector = n4.LookVector
			local rightVector = n4.RightVector
			local vector = Vector3.zero

			if v6:IsKeyDown(Enum.KeyCode.W) then
				vector = Vector3.zero + lookVector
			end

			if v6:IsKeyDown(Enum.KeyCode.S) then
				vector -= lookVector
			end

			if v6:IsKeyDown(Enum.KeyCode.A) then
				vector -= rightVector
			end

			if v6:IsKeyDown(Enum.KeyCode.D) then
				vector += rightVector
			end

			if v6:IsKeyDown(Enum.KeyCode.Space) then
				vector += Vector3.new(0, 1, 0)
			end

			if v6:IsKeyDown(Enum.KeyCode.LeftControl) or v6:IsKeyDown(Enum.KeyCode.LeftShift) then
				vector -= Vector3.new(0, 1, 0)
			end

			if vector.Magnitude > 0 then
				position += vector.Unit * n5
			end

			cFrame = CFrame.new(position) * n4
			currentCamera.CFrame = cFrame
		end))

		pcall(function()
			v5:BindToRenderStep("PhonkWare_Freecam", Enum.RenderPriority.Camera.Value + 1, function()
				if flag and cFrame then
					pcall(function()
						currentCamera.CameraType = Enum.CameraType.Scriptable
						currentCamera.CameraSubject = nil
						currentCamera.CFrame = cFrame
					end)
				end
			end)
		end)

		v2:Add(localPlayer2.CharacterAdded:Connect(function()
			fn9()
		end))

		v2:Add(function()
			fn9()

			pcall(function()
				v5:UnbindFromRenderStep("PhonkWare_Freecam")
			end)
		end)
	end

	do
		local tbl4 = {
			"arm",
			"hand",
			"sleeve",
			"elbow",
			"wrist",
			"shoulder",
			"finger",
			"thumb",
			"glove",
			"leftarm",
			"rightarm",
		}

		local tbl5 = {}

		local function fn7(arg)
			local v8 = string.lower(arg.Name)

			for i = 1, #tbl4 do
				if string.find(v8, tbl4[i], 1, true) then
					return true
				end
			end

			return false
		end

		local function fn8()
			local firstPerson = workspace:FindFirstChild("ViewModels") and workspace.ViewModels:FindFirstChild("FirstPerson")
			if not firstPerson then
				return
			end

			for _, descendant in ipairs(firstPerson:GetDescendants()) do
				if descendant:IsA("BasePart") then
					if fn7(descendant) then
						if not tbl5[descendant] then
							tbl5[descendant] = { t = descendant.Transparency, ltm = descendant.LocalTransparencyModifier }
						end

						if phonk.no_arm.enable then
							descendant.Transparency = 1
							descendant.LocalTransparencyModifier = 1
						else
							local v8 = tbl5[descendant]

							if v8 then
								descendant.Transparency = v8.t
								descendant.LocalTransparencyModifier = v8.ltm
								tbl5[descendant] = nil
							end
						end
					end
				elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
					if fn7(descendant.Parent) then
						if phonk.no_arm.enable then
							descendant.Transparency = 1
						end
					end
				end
			end
		end

		v2:Add(v5.RenderStepped:Connect(function()
			fn8()
		end))

		v2:Add(function()
			for k, v8 in pairs(tbl5) do
				if k and k.Parent then
					pcall(function()
						k.Transparency = v8.t
						k.LocalTransparencyModifier = v8.ltm
					end)
				end
			end
		end)
	end

	do
		local function fn7(arg)
			if not arg or arg == localPlayer2 then
				return false
			end
			local character = arg.Character
			if not character then
				return false
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
				return false
			end

			if phonk.tp_player.team_check then
				local ok, result = pcall(function()
					return arg:GetAttribute("TeamID") == localPlayer2:GetAttribute("TeamID")
				end)

				if ok and result then
					return false
				end
			end

			return true
		end

		local function fn8()
			local method = phonk.tp_player.method or "closest"
			local humanoidRootPart = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")
			local vector2 = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2)
			local huge = math.huge
			local v8 = nil

			for _, player in ipairs(v4:GetPlayers()) do
				if fn7(player) then
					local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

					if method == "crosshair" then
						local v9, v10 = currentCamera:WorldToViewportPoint(humanoidRootPart2.Position)

						if v10 and v9.Z > 0 then
							local magnitude = (Vector2.new(v9.X, v9.Y) - vector2).Magnitude

							if magnitude < huge then
								huge = magnitude
								v8 = player
							end
						end
					elseif humanoidRootPart then
						local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude

						if magnitude < huge then
							huge = magnitude
							v8 = player
						end
					end
				end
			end

			return v8
		end

		local function fn9(arg)
			if not arg or not arg.Character then
				return false
			end
			local humanoidRootPart = arg.Character:FindFirstChild("HumanoidRootPart")
			local humanoidRootPart2 = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart or not humanoidRootPart2 then
				return false
			end
			local yOffset = phonk.tp_player.y_offset or 0

			if options and options.tp_y_offset and options.tp_y_offset.Value ~= nil then
				local yOffset2 = options.tp_y_offset.Value
				phonk.tp_player.y_offset = yOffset2
				yOffset = yOffset2
			end

			local n2 = tonumber(yOffset) or 0
			local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
			local lookVector = humanoidRootPart2.CFrame.LookVector
			local vector

			if phonk.tp_player.prediction then
				local magnitude = assemblyLinearVelocity.Magnitude
				local n3 = 0

				if magnitude > 0.5 then
					n3 = math.clamp(0.06 + magnitude * 0.004, 0.05, 0.28)
				end

				local n4 = humanoidRootPart.Position + assemblyLinearVelocity * n3
				vector = Vector3.new(n4.X, n4.Y + n2, n4.Z)
				local vector2 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)

				if vector2.Magnitude > 1 then
					lookVector = vector2.Unit
				end
			else
				local position = humanoidRootPart.Position
				vector = Vector3.new(position.X, position.Y + n2, position.Z)
			end

			pcall(function()
				if phonk.tp_player.prediction then
					humanoidRootPart2.AssemblyLinearVelocity = assemblyLinearVelocity
				else
					humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
				end

				humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
				humanoidRootPart2.CFrame = CFrame.new(vector, vector + lookVector)
				humanoidRootPart2.Position = vector
			end)

			pcall(function()
				local character = localPlayer2.Character

				if character and character.PivotTo then
					character:PivotTo(CFrame.new(vector, vector + lookVector))
				end
			end)

			return true
		end

		getgenv().phonk_tp_to_player = function(arg)
			if arg and arg ~= "" then
				for _, player in ipairs(v4:GetPlayers()) do
					if (player.Name == arg or player.DisplayName == arg) and fn7(player) then
						return fn9(player)
					end
				end

				return false
			end

			local v8 = fn8()
			if not v8 then
				return false
			end
			return fn9(v8)
		end
	end

	local flag = false

	v2:Add(v5.Heartbeat:Connect(function()
		local tpKey = options.tp_key
		local phonkMobileBtns = getgenv().phonk_mobile_btns
		local flag2

		if phonkMobileBtns and phonkMobileBtns.tp then
			flag2 = true
		else
			local getState = tpKey and tpKey.GetState
			flag2 = false

			if getState then
				local ok, result = pcall(function()
					return tpKey:GetState()
				end)

				flag2 = ok and result == true
			end
		end

		local phonkUnderground = getgenv().phonk_underground

		if flag2 then
			if phonkUnderground and phonkUnderground.active then
				phonkUnderground.tp_override = true
			end

			getgenv().phonk_tp_to_player()
		elseif flag and not flag2 then
			if phonkUnderground and phonkUnderground.active and phonkUnderground.saved_pos then
				phonkUnderground.tp_override = false
				local value

				if options and options.ug_depth and type(options.ug_depth.Value) == "number" then
					value = options.ug_depth.Value
				else
					local depth = phonk.underground and phonk.underground.depth
					value = 5.8

					if depth then
						value = phonk.underground.depth
					end
				end

				local humanoidRootPart = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					local n2 = phonkUnderground.saved_pos.Y - value

					pcall(function()
						humanoidRootPart.CFrame = CFrame.new(phonkUnderground.saved_pos.X, n2, phonkUnderground.saved_pos.Z)
						humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					end)
				end
			end
		end

		flag = flag2
	end))

	do
		local tbl4 = {
			active = false,
			stored_pos = nil,
			sky_base = nil,
			yaw_locked = false,
			locked_look = nil,
			weapon_cache = {},
			mode = "none",
			fc_active = false,
			fc_cf = nil,
		}

		local function fn7(arg)
			local v8 = options[arg]
			if not v8 then
				return false
			end

			if type(v8.GetState) == "function" then
				local ok, result = pcall(function()
					return v8:GetState()
				end)

				if ok then
					return result == true
				end
			end

			if v8.Mode == "Always" then
				return true
			end

			if v8.Mode == "Toggle" then
				return v8.Toggled == true
			end
			return false
		end

		local function fn8()
			local phonkMobileBtns = getgenv().phonk_mobile_btns

			if phonkMobileBtns and phonkMobileBtns.eu then
				if not phonk.eu_counter.enable then
					phonk.eu_counter.enable = true
				end

				return true
			end

			if not (phonk.eu_counter and phonk.eu_counter.enable) then
				return false
			end

			if not options.eu_counter_key then
				return false
			end
			return fn7("eu_counter_key") == true
		end

		local function fn9()
			local character = localPlayer2.Character
			return character and character:FindFirstChild("HumanoidRootPart")
		end

		local function fn10(arg, arg2, arg3)
			local v8 = fn9()
			if not v8 then
				return
			end

			pcall(function()
				v8.CFrame = CFrame.new(arg, arg2, arg3)
				v8.AssemblyLinearVelocity = Vector3.zero
				v8.AssemblyAngularVelocity = Vector3.zero
			end)
		end

		local function fn11()
			local viewModels = workspace:FindFirstChild("ViewModels")
			if not viewModels then
				return
			end
			local weaponCache = {}

			for _, child in ipairs(viewModels:GetChildren()) do
				local v8, v9 = string.match(child.Name, "^(.-) %- (.-) %-")

				if v8 and v9 then
					weaponCache[v8] = v9
				end
			end

			tbl4.weapon_cache = weaponCache
		end

		local function fn12(arg)
			if not arg then
				return nil
			end
			local v8 = tbl4.weapon_cache[arg.Name] or tbl4.weapon_cache[arg.DisplayName]
			if v8 then
				return v8
			end

			if arg.Character then
				for _, child in ipairs(arg.Character:GetChildren()) do
					if child:IsA("Tool") then
						return child.Name
					end
				end
			end

			return nil
		end

		local function fn13(arg)
			if not arg then
				return false
			end
			return string.lower(tostring(arg)) == "knife"
		end

		local function fn14(arg)
			if not arg or arg == localPlayer2 then
				return false
			end
			local character = arg.Character
			if not character then
				return false
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then
				return false
			end

			local ok, result = pcall(function()
				return arg:GetAttribute("TeamID") == localPlayer2:GetAttribute("TeamID")
			end)

			if ok and result then
				return false
			end
			return true
		end

		local function fn15()
			local v8 = fn9()
			if not v8 then
				return nil
			end
			local huge = math.huge
			local v9 = nil

			for _, player in ipairs(v4:GetPlayers()) do
				if fn14(player) then
					local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						local magnitude = (humanoidRootPart.Position - v8.Position).Magnitude

						if magnitude < huge then
							huge = magnitude
							v9 = player
						end
					end
				end
			end

			return v9
		end

		local function fn16()
			if options and options.ug_depth and type(options.ug_depth.Value) == "number" then
				return options.ug_depth.Value
			end
			return phonk.underground and phonk.underground.depth or 5.8
		end

		local function fn17()
			local v8 = fn9()
			if not v8 then
				return
			end

			if not tbl4.stored_pos then
				tbl4.stored_pos = v8.Position
			end

			local storedPos = tbl4.stored_pos
			fn10(storedPos.X, storedPos.Y - fn16(), storedPos.Z)
			tbl4.mode = "underground"
		end

		local function fn18()
			local v8 = fn9()
			if not v8 then
				return
			end

			if not tbl4.stored_pos then
				tbl4.stored_pos = v8.Position
			end

			local storedPos = tbl4.stored_pos
			local vector = Vector3.new((math.random() - 0.5) * 2, math.random() * 0.85 + 0.15, (math.random() - 0.5) * 2)
			local vector2

			if vector.Magnitude < 0.05 then
				vector2 = Vector3.new(0, 1, 0)
			else
				vector2 = vector.Unit
			end

			local n2 = storedPos + vector2 * (1000 + math.random() * 1500)
			local n3 = n2.X - storedPos.X
			local n4 = n2.Y - storedPos.Y
			local n5 = n2.Z - storedPos.Z

			if math.abs(n3) < 1000 then
				n3 = (n3 >= 0 and 1 or -1) * (1000 + math.random() * 500)
			end

			if math.abs(n4) < 1000 then
				n4 = 1000 + math.random() * 800
			end

			if math.abs(n5) < 1000 then
				n5 = (n5 >= 0 and 1 or -1) * (1000 + math.random() * 500)
			end

			local vector3 = Vector3.new(storedPos.X + n3, storedPos.Y + n4, storedPos.Z + n5)
			fn10(vector3.X, vector3.Y, vector3.Z)
			tbl4.mode = "sky"
		end

		local function fn19()
			if tbl4.yaw_locked then
				return
			end
			tbl4.yaw_locked = true

			pcall(function()
				local position = currentCamera.CFrame.Position
				tbl4.locked_look = CFrame.lookAt(position, position + Vector3.new(0, 1, 0))

				if CameraController and CameraController.MimicRotation then
					CameraController:MimicRotation(tbl4.locked_look)
				end

				currentCamera.CFrame = tbl4.locked_look
			end)
		end

		local function fn20()
			if tbl4.fc_active then
				return
			end
			tbl4.fc_active = true
			tbl4.fc_cf = currentCamera.CFrame

			pcall(function()
				currentCamera.CameraType = Enum.CameraType.Scriptable
				currentCamera.CameraSubject = nil
			end)
		end

		local function fn21()
			if not tbl4.fc_active then
				return
			end
			tbl4.fc_active = false
			tbl4.fc_cf = nil

			pcall(function()
				currentCamera.CameraType = Enum.CameraType.Custom
				local character = localPlayer2.Character
				character = character and character:FindFirstChildOfClass("Humanoid")

				if character then
					currentCamera.CameraSubject = character
				end
			end)
		end

		local function fn22()
			tbl4.active = false
			tbl4.mode = "none"
			tbl4.yaw_locked = false
			tbl4.locked_look = nil
			tbl4.sky_base = nil
			fn21()

			if tbl4.stored_pos then
				local storedPos = tbl4.stored_pos
				fn10(storedPos.X, storedPos.Y, storedPos.Z)
			end

			tbl4.stored_pos = nil
		end

		local screenGui = nil
		local frame = nil

		pcall(function()
			screenGui = Instance.new("ScreenGui")
			screenGui.Name = "PhonkWareEUCounter"
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.DisplayOrder = 50

			if gethui then
				screenGui.Parent = gethui()
			else
				screenGui.Parent = game:GetService("CoreGui")
			end

			local phonkUiScale = getgenv().phonk_ui_scale or 1
			local uiScale = Instance.new("UIScale")
			uiScale.Name = "PhonkUIScale"
			uiScale.Scale = phonkUiScale
			uiScale.Parent = screenGui
			frame = Instance.new("Frame")
			frame.AnchorPoint = Vector2.new(0.5, 0)
			frame.Position = UDim2.new(0.5, 0, 0, 72)
			frame.Size = UDim2.new(0, 0, 0, 40)
			frame.BackgroundTransparency = 1
			frame.Parent = screenGui
			v2:Add(screenGui)
		end)

		local str = "PHONKWARE UE COUNTER"
		local tbl5 = {}
		local textSize = 32
		local n2 = 20

		local function fn23()
			if not frame then
				return
			end

			if #tbl5 > 0 then
				return
			end
			local n3 = #str * n2
			frame.AnchorPoint = Vector2.new(0.5, 0)
			frame.Position = UDim2.new(0.5, 0, 0, 68)
			frame.Size = UDim2.new(0, n3, 0, textSize + 16)

			for i = 1, #str do
				local text = ("PHONKWARE UE COUNTER"):sub(i, i)
				local textLabel = Instance.new("TextLabel")
				textLabel.BackgroundTransparency = 1
				textLabel.Size = UDim2.new(0, 20, 1, 0)
				textLabel.Position = UDim2.new(0, (i - 1) * n2, 0, 0)
				textLabel.Font = Enum.Font.GothamBold
				textLabel.TextSize = textSize
				textLabel.Text = text
				textLabel.TextXAlignment = Enum.TextXAlignment.Center
				textLabel.TextYAlignment = Enum.TextYAlignment.Center
				textLabel.TextColor3 = library.AccentColor or Color3.fromRGB(196, 30, 58)
				textLabel.TextStrokeTransparency = 0.5
				textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
				textLabel.Parent = frame
				tbl5[i] = textLabel
			end
		end

		v2:Add(v5.RenderStepped:Connect(function()
			local v8 = fn8()

			if frame then
				frame.Visible = v8
			end

			if not v8 then
				return
			end
			fn23()
			local now2 = os.clock()
			local accentColor = library.AccentColor or Color3.fromRGB(196, 30, 58)

			for i, v9 in ipairs(tbl5) do
				v9.Position = UDim2.new(0, (i - 1) * n2, 0, math.sin(now2 * 4 + i * 0.4) * 8)
				v9.TextColor3 = accentColor
			end

			if tbl4.yaw_locked and tbl4.locked_look then
				pcall(function()
					local position = currentCamera.CFrame.Position
					local cframe = CFrame.lookAt(position, position + Vector3.new(0, 1, 0))
					tbl4.locked_look = cframe

					if CameraController and CameraController.MimicRotation then
						CameraController:MimicRotation(cframe)
					end
				end)
			end

			if tbl4.fc_active and tbl4.fc_cf then
				pcall(function()
					currentCamera.CameraType = Enum.CameraType.Scriptable
					currentCamera.CFrame = tbl4.fc_cf
				end)
			end
		end))

		v2:Add(v5.Heartbeat:Connect(function()
			if not fn8() then
				if tbl4.active then
					fn22()
				end

				return
			end

			if not tbl4.active then
				tbl4.active = true
				local v8 = fn9()

				if v8 then
					tbl4.stored_pos = v8.Position
				end

				fn19()
				fn20()

				if tbl4.fc_cf == nil then
					tbl4.fc_cf = currentCamera.CFrame
				end

				pcall(function()
					tbl4.fc_cf = tbl4.fc_cf * CFrame.new(0, 0.5, 0)
				end)
			end

			fn11()
			local v8 = fn15()
			if not v8 then
				fn17()
				return
			end
			local v9 = fn12(v8)

			if fn13(v9) then
				fn18()
			else
				fn17()
			end
		end))
	end

	do
		local tbl4 = {
			Meditate = "96579993895076",
			Orbit = "133811691098518",
			Floss = "72174079036035",
			OJ = "110064349530772",
			["Kicking Feet"] = "131879764029003",
			["Take the L"] = "112884830175040",
			Hype = "80055417516516",
		}

		phonk.animation = phonk.animation or { enable = false, select_animation = "Meditate", speed = 2, custom_id = "" }

		if not phonk.animation.select_animation or phonk.animation.select_animation == "" then
			phonk.animation.select_animation = "Meditate"
		end

		local v8 = nil
		local str = ""
		local n2 = 0

		local function fn7()
			if v8 then
				pcall(function()
					v8:Stop()
				end)

				v8 = nil
			end

			str = ""
		end

		v2:Add(v5.Heartbeat:Connect(function()
			if not pcall(function()
				if not phonk.animation.enable then
					fn7()
					return
				end
				local character = localPlayer2.Character
				if not character then
					fn7()
					return
				end
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if not humanoid then
					fn7()
					return
				end
				local animator = humanoid:FindFirstChildOfClass("Animator")
				if not animator then
					fn7()
					return
				end

				if v8 and not v8.IsPlaying then
					v8 = nil
					str = ""
				end

				local str2 = tbl4[phonk.animation.select_animation]
				local customId = phonk.animation.custom_id

				if type(customId) == "string" and customId ~= "" and tonumber(customId) then
					str2 = tostring(tonumber(customId))
				end

				if not str2 then
					return
				end
				local speed = phonk.animation.speed or 2

				if str2 ~= str then
					if v8 then
						pcall(function()
							v8:Stop()
						end)

						v8 = nil
					end

					str = str2

					local ok, result = pcall(function()
						return game:GetObjects("rbxassetid://" .. str2)
					end)

					local animation

					if ok and result and result[1] then
						animation = result[1]
					else
						animation = Instance.new("Animation")
						animation.AnimationId = "rbxassetid://" .. str2
					end

					local ok2, result2 = pcall(function()
						return animator:LoadAnimation(animation)
					end)

					if not ok2 or not result2 then
						str = ""
						return
					end
					v8 = result2

					pcall(function()
						v8.Priority = Enum.AnimationPriority.Action4
						v8:Play()
						v8:AdjustSpeed(speed)
					end)

					n2 = speed
				end

				if v8 and speed ~= n2 then
					pcall(function()
						v8:AdjustSpeed(speed)
					end)

					n2 = speed
				end
			end) then
				str = ""
			end
		end))

		v2:Add(fn7)
	end

	do
		local v8 = v3
		local Utility = nil
		local EnumLibrary = nil
		local FighterController = nil
		local SpectateController = nil

		pcall(function()
			Utility = require(v8.Modules.Utility)
		end)

		pcall(function()
			EnumLibrary = require(v8.Modules.EnumLibrary)
		end)

		pcall(function()
			FighterController = require(localPlayer2.PlayerScripts.Controllers.FighterController)
		end)

		pcall(function()
			SpectateController = require(localPlayer2.PlayerScripts.Controllers:WaitForChild("SpectateController"))
		end)

		local tbl4 = {
			active = false,
			mode = "voiding",
			target_name = "none",
			dots = 1,
			dots_dir = 1,
			dots_t = 0,
			last_fire = 0,
			fire_rate = 0.0005,
		}

		local tbl5 = {}

		local function fn7(arg)
			local v9 = options[arg]
			if not v9 then
				return false
			end

			if type(v9.GetState) == "function" then
				local ok, result = pcall(function()
					return v9:GetState()
				end)

				if ok then
					return result == true
				end
			end

			if v9.Mode == "Always" then
				return true
			end

			if v9.Mode == "Toggle" then
				return v9.Toggled == true
			end
			return false
		end

		local function fn8()
			if not (phonk.ragebot and phonk.ragebot.enable) then
				return false
			end
			local phonkMobileBtns = getgenv().phonk_mobile_btns
			if phonkMobileBtns and phonkMobileBtns.ragebot then
				return true
			end

			if options.ragebot_key then
				return fn7("ragebot_key")
			end
			return true
		end

		v4.PlayerRemoving:Connect(function(player)
			tbl5[player] = nil
		end)

		local function fn9()
			if not FighterController or not FighterController.Objects then
				return
			end

			for _, object in pairs(FighterController.Objects) do
				local player = object.Player

				if player then
					if not object.Entity or not object.Entity:IsAlive() or object:Get("IsSpectating") then
						tbl5[player] = false
					else
						local equippedItem = object.EquippedItem
						local flag2 = equippedItem and equippedItem.ViewModel and equippedItem.ViewModel.Name == "Katana"
						local flag3 = false

						if flag2 then
							flag3 = equippedItem._attack_cooldown and equippedItem._attack_cooldown > tick() or false
						end

						tbl5[player] = flag3
					end
				end
			end
		end

		local function fn10(arg)
			if arg == localPlayer2 then
				return false
			end

			if phonk.ragebot.team_check then
				if SpectateController then
					local currentDuelSubject = SpectateController.CurrentDuelSubject
					local dueler = currentDuelSubject and currentDuelSubject:GetDueler(localPlayer2)
					dueler = dueler and dueler:Get("TeamID") or nil

					if dueler and currentDuelSubject and currentDuelSubject.Duelers then
						for _, dueler2 in pairs(currentDuelSubject.Duelers) do
							if dueler2.Player == arg then
								return dueler2:Get("TeamID") ~= dueler
							end
						end
					end
				end

				local attribute = arg:GetAttribute("TeamID")
				local attribute2 = localPlayer2:GetAttribute("TeamID")
				if attribute and attribute2 then
					return attribute ~= attribute2
				end
			end

			return true
		end

		local function fn11()
			local character = localPlayer2.Character
			if not character then
				return nil, nil, nil
			end
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return nil, nil, nil
			end
			local n2 = 500
			local v9 = nil
			local v10 = nil
			local v11 = nil

			for _, player in ipairs(v4:GetPlayers()) do
				if fn10(player) then
					local character2 = player.Character

					if character2 then
						local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")
						local head = character2:FindFirstChild("Head")
						local humanoid = character2:FindFirstChildWhichIsA("Humanoid")

						if humanoidRootPart2 and head and humanoid and humanoid.Health > 0 then
							local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

							if magnitude < n2 then
								n2 = magnitude
								v9 = player
								v10 = humanoidRootPart2
								v11 = head
							end
						end
					end
				end
			end

			return v9, v10, v11
		end

		local function fn12(arg)
			if not arg then
				return false
			end
			local viewModels = workspace:FindFirstChild("ViewModels")
			if not viewModels then
				return false
			end
			local name = arg.Name

			for _, child in ipairs(viewModels:GetChildren()) do
				if child:IsA("Model") and string.find(child.Name, name, 1, true) and string.find(child.Name, "Knife", 1, true) then
					return true
				end
			end

			return false
		end

		local screenGui = nil
		local textLabel = nil

		pcall(function()
			screenGui = Instance.new("ScreenGui")
			screenGui.Name = "PhonkWareRagebotStatus"
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.DisplayOrder = 60

			if gethui then
				screenGui.Parent = gethui()
			else
				screenGui.Parent = game:GetService("CoreGui")
			end

			local phonkUiScale = getgenv().phonk_ui_scale or 1
			local uiScale = Instance.new("UIScale")
			uiScale.Name = "PhonkUIScale"
			uiScale.Scale = phonkUiScale
			uiScale.Parent = screenGui
			textLabel = Instance.new("TextLabel")
			textLabel.AnchorPoint = Vector2.new(0.5, 1)
			textLabel.Position = UDim2.new(0.5, 0, 1, -18)
			textLabel.Size = UDim2.new(0, 700, 0, 28)
			textLabel.BackgroundTransparency = 1
			textLabel.Font = Enum.Font.GothamMedium
			textLabel.TextSize = 16
			textLabel.TextColor3 = library.AccentColor or Color3.fromRGB(196, 30, 58)
			textLabel.TextStrokeTransparency = 0.5
			textLabel.Text = ""
			textLabel.Visible = false
			textLabel.Parent = screenGui
			v2:Add(screenGui)
		end)

		v2:Add(v5.Heartbeat:Connect(function()
			local v9 = fn8()
			tbl4.active = v9

			if not v9 then
				if textLabel then
					textLabel.Visible = false
				end

				tbl4.mode = "voiding"
				tbl4.target_name = "none"
				return
			end

			fn9()
			local v10, v11, v12 = fn11()
			local v13 = tbl4
			local displayName

			if v10 then
				displayName = v10.DisplayName or v10.Name
			else
				displayName = v10
			end

			v13.target_name = displayName or "none"
			local v14 = v11 and v12
			local cframe = nil

			if v14 then
				local yOffset = phonk.ragebot.y_offset or 3
				local position

				if fn12(v10) then
					position = (v11.CFrame * CFrame.new(0, math.max(yOffset + 3, 6), 0)).Position
				else
					local position2 = v11.Position

					if phonk.ragebot.prediction then
						local assemblyLinearVelocity = v11.AssemblyLinearVelocity
						local magnitude = assemblyLinearVelocity.Magnitude

						if magnitude > 0.35 then
							position2 += assemblyLinearVelocity * math.clamp(0.08 + magnitude * 0.006, 0.06, 0.4)
						end
					end

					local vector = Vector3.new(position2.X, position2.Y + yOffset, position2.Z)
					position = (CFrame.new(vector) * CFrame.new(0, 0, 2)).Position
				end

				cframe = CFrame.lookAt(position, v12.Position)
			end

			if cframe and localPlayer2.Character then
				local humanoidRootPart = localPlayer2.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					local cFrame = humanoidRootPart.CFrame
					local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
					local assemblyAngularVelocity = humanoidRootPart.AssemblyAngularVelocity
					humanoidRootPart.CFrame = cframe
					tbl4.mode = "ragebotting"

					v5:BindToRenderStep("PhonkWare_RageRestore", 101, function()
						if humanoidRootPart then
							humanoidRootPart.CFrame = cFrame
							humanoidRootPart.AssemblyLinearVelocity = assemblyLinearVelocity
							humanoidRootPart.AssemblyAngularVelocity = assemblyAngularVelocity
						end

						pcall(function()
							v5:UnbindFromRenderStep("PhonkWare_RageRestore")
						end)

						if tbl4.mode == "ragebotting" then
							tbl4.mode = "voiding"
						end
					end)
				end
			else
				tbl4.mode = "voiding"
			end

			if not v10 or not v12 or not v11 then
				return
			end

			if tbl5[v10] then
				return
			end

			if not FighterController or not FighterController.LocalFighter then
				return
			end
			local equippedItem = FighterController.LocalFighter.EquippedItem
			if not equippedItem then
				return
			end

			if not Utility or not EnumLibrary then
				return
			end
			local fireRate = tbl4.fire_rate
			local lastFire = tbl4.last_fire
			if tick() - lastFire < fireRate then
				return
			end
			tbl4.last_fire = tick()
			local position = cframe and cframe.Position or v11.Position
			local position2 = v12.Position
			local cframe2 = CFrame.lookAt(position, position2)
			local cFrame = v12.CFrame
			local v15 = v12.CFrame:ToObjectSpace(CFrame.new(position2 + Vector3.new((math.random() - 0.5) * 0.1, (math.random() - 0.5) * 0.1, (math.random() - 0.5) * 0.1)))

			local tbl6 = {
				[utf8.char(1)] = {
					[utf8.char(0)] = Utility:EncodeCFrame(cframe2),
					[utf8.char(1)] = Utility:EncodeCFrame(cFrame),
					[utf8.char(2)] = v12,
					[utf8.char(3)] = Utility:EncodeCFrame(v15),
				},
			}

			pcall(function()
				v8.Remotes.Replication.Fighter.UseItem:FireServer(equippedItem:Get("ObjectID"), EnumLibrary:ToEnum("StartShooting"), tbl6, nil)
			end)

			tbl4.mode = "ragebotting"
		end))

		v2:Add(v5.RenderStepped:Connect(function(deltaTime)
			if not tbl4.active then
				if textLabel then
					textLabel.Visible = false
				end

				return
			end

			tbl4.dots_t = tbl4.dots_t + (deltaTime or 0.016)

			if tbl4.dots_t >= 0.35 then
				tbl4.dots_t = 0
				tbl4.dots = tbl4.dots + tbl4.dots_dir

				if tbl4.dots >= 3 then
					tbl4.dots_dir = -1
				end

				if tbl4.dots <= 1 then
					tbl4.dots_dir = 1
				end
			end

			local str = string.rep(".", tbl4.dots)

			if textLabel then
				textLabel.Visible = true
				textLabel.TextColor3 = library.AccentColor or Color3.fromRGB(196, 30, 58)
				textLabel.Text = string.format("target : %s | %s%s", tbl4.target_name, tbl4.mode, str)
			end
		end))
	end

	tbl2.Ragebot:AddLeftGroupbox("gun mods"):AddToggle("gun_mods_enable", {
		Text = "enable (no spread / recoil)",
		Default = false,
		Callback = function(enable)
			phonk.gun_mods = phonk.gun_mods or {}
			phonk.gun_mods.enable = enable

			if enable and getgenv().phonk_apply_gun_mods then
				getgenv().phonk_apply_gun_mods()
			end
		end,
	})

	local v8 = tbl2.Ragebot:AddRightGroupbox("underground anti-aim")

	v8:AddToggle("ug_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.underground.enable = enable
		end,
	}):AddKeyPicker("ug_key", { Default = "Q", Text = "underground", Mode = "Toggle", SyncToggleState = false })

	v8:AddSlider("ug_depth", {
		Text = "depth",
		Default = 5.8,
		Min = 1,
		Max = 20,
		Rounding = 1,
		Callback = function(depth)
			phonk.underground.depth = depth
		end,
	})

	local v9 = tbl2.Ragebot:AddLeftGroupbox("tp on player")
	v9:AddLabel("tp key"):AddKeyPicker("tp_key", { Default = "T", Text = "tp", Mode = "Hold", SyncToggleState = false })

	v9:AddDropdown("tp_method", {
		Text = "method",
		Values = { "closest", "crosshair" },
		Default = "closest",
		Callback = function(method)
			phonk.tp_player.method = method
		end,
	})

	v9:AddToggle("tp_team", {
		Text = "team check",
		Default = true,
		Callback = function(teamCheck)
			phonk.tp_player.team_check = teamCheck
		end,
	})

	v9:AddToggle("tp_prediction", {
		Text = "prediction",
		Default = true,
		Callback = function(prediction)
			phonk.tp_player.prediction = prediction
		end,
	})

	v9:AddSlider("tp_y_offset", {
		Text = "y offset",
		Default = 0,
		Min = -10,
		Max = 10,
		Rounding = 1,
		Callback = function(yOffset)
			phonk.tp_player.y_offset = yOffset
		end,
	})

	local ragebot = tbl2.Ragebot:AddLeftGroupbox("ragebot")

	ragebot:AddToggle("ragebot_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.ragebot.enable = enable
		end,
	}):AddKeyPicker("ragebot_key", { Default = "R", Text = "ragebot", Mode = "Toggle", SyncToggleState = false })

	ragebot:AddToggle("ragebot_prediction", {
		Text = "prediction",
		Default = true,
		Callback = function(prediction)
			phonk.ragebot.prediction = prediction
		end,
	})

	ragebot:AddToggle("ragebot_team", {
		Text = "team check",
		Default = true,
		Callback = function(teamCheck)
			phonk.ragebot.team_check = teamCheck
		end,
	})

	ragebot:AddSlider("ragebot_duration", {
		Text = "tp duration",
		Default = 0.15,
		Min = 0.01,
		Max = 1,
		Rounding = 2,
		Suffix = "s",
		Callback = function(tpDuration)
			phonk.ragebot.tp_duration = tpDuration
		end,
	})

	ragebot:AddSlider("ragebot_yoff", {
		Text = "y offset",
		Default = 3,
		Min = -5,
		Max = 10,
		Rounding = 1,
		Callback = function(yOffset)
			phonk.ragebot.y_offset = yOffset
		end,
	})

	tbl2.Ragebot:AddRightGroupbox("UE Counter"):AddToggle("eu_counter_enable", {
		Text = "UE Counter",
		Default = false,
		Callback = function(enable)
			phonk.eu_counter.enable = enable
		end,
	}):AddKeyPicker("eu_counter_key", { Default = "X", Text = "UE Counter", Mode = "Toggle", SyncToggleState = false })

	local targeting = tbl2.Combat:AddLeftGroupbox("targeting")

	targeting:AddDropdown("tgt_part", {
		Text = "target part",
		Values = { "Head", "HumanoidRootPart", "UpperTorso" },
		Default = "Head",
		Callback = function(part)
			phonk.targeting.part = part
		end,
	})

	targeting:AddSlider("tgt_maxdist", {
		Text = "max distance",
		Default = 800,
		Min = 50,
		Max = 3000,
		Rounding = 0,
		Callback = function(maxDistance)
			phonk.targeting.max_distance = maxDistance
		end,
	})

	targeting:AddToggle("tgt_visible", {
		Text = "visible only",
		Default = false,
		Callback = function(visibleOnly)
			phonk.targeting.visible_only = visibleOnly
		end,
	})

	targeting:AddToggle("tgt_riot", {
		Text = "ignore riot shield",
		Default = false,
		Callback = function(riotShield)
			phonk.targeting.riot_shield = riotShield
		end,
	})

	targeting:AddToggle("tgt_anti_katana", {
		Text = "anti katana",
		Default = false,
		Callback = function(antiKatana)
			phonk.targeting.anti_katana = antiKatana
		end,
	})

	s32_2 = tbl2.Combat:AddRightGroupbox("silent aim")

	s32_2:AddToggle("silent_aim_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.silent_aim.enable = enable
		end,
	}):AddKeyPicker("silent_aim_key", { Default = "C", Text = "silent aim", Mode = "Toggle", SyncToggleState = false })

	s32_2:AddDropdown("silent_aim_part", {
		Text = "hit part",
		Values = { "Head", "HumanoidRootPart", "UpperTorso" },
		Default = "Head",
		Callback = function(hitPart)
			phonk.silent_aim.hit_part = hitPart
		end,
	})

	s32_2:AddToggle("silent_aim_fov_show", {
		Text = "show fov",
		Default = true,
		Callback = function(showFov)
			phonk.silent_aim.show_fov = showFov
		end,
	}):AddColorPicker("silent_aim_fov_color", {
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(fovColor)
			phonk.silent_aim.fov_color = fovColor
		end,
	})

	s32_2:AddSlider("silent_aim_fov", {
		Text = "fov radius",
		Default = 300,
		Min = 20,
		Max = 800,
		Rounding = 0,
		Callback = function(fovRadius)
			phonk.silent_aim.fov_radius = fovRadius
		end,
	})

	s32_3 = tbl2.Combat:AddLeftGroupbox("aimbot")

	s32_3:AddToggle("aim_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.aimbot.enable = enable
		end,
	}):AddKeyPicker("aim_key", { Default = "E", Text = "aimbot", Mode = "Hold", SyncToggleState = false })

	s32_3:AddToggle("aim_show_fov", {
		Text = "show fov",
		Default = true,
		Callback = function(showFov)
			phonk.aimbot.show_fov = showFov
		end,
	}):AddColorPicker("aim_fov_color", {
		Default = Color3.fromRGB(196, 30, 58),
		Callback = function(fovColor)
			phonk.aimbot.fov_color = fovColor
		end,
	})

	s32_3:AddSlider("aim_fov", {
		Text = "fov radius",
		Default = 180,
		Min = 20,
		Max = 800,
		Rounding = 0,
		Callback = function(fovRadius)
			phonk.aimbot.fov_radius = fovRadius
		end,
	})

	s32_3:AddSlider("aim_smooth", {
		Text = "smoothing",
		Default = 1,
		Min = 1,
		Max = 100,
		Rounding = 0,
		Callback = function(smoothing)
			phonk.aimbot.smoothing = smoothing
		end,
	})

	s32_3:AddToggle("aim_closest_part", {
		Text = "closest part",
		Default = false,
		Callback = function(closestPart)
			phonk.aimbot.closest_part = closestPart
		end,
	})

	s1_14 = tbl2.Combat:AddRightGroupbox("triggerbot")

	s1_14:AddToggle("trg_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.triggerbot.enable = enable
		end,
	})

	s1_14:AddToggle("trg_team", {
		Text = "team check",
		Default = true,
		Callback = function(teamCheck)
			phonk.triggerbot.team_check = teamCheck
		end,
	})

	s1_14:AddSlider("trg_react", {
		Text = "reaction time",
		Default = 0.05,
		Min = 0,
		Max = 0.5,
		Rounding = 2,
		Callback = function(reactionTime)
			phonk.triggerbot.reaction_time = reactionTime
		end,
	})

	s1_14:AddSlider("trg_delay", {
		Text = "shoot delay",
		Default = 0.1,
		Min = 0,
		Max = 1,
		Rounding = 2,
		Callback = function(shootDelay)
			phonk.triggerbot.shoot_delay = shootDelay
		end,
	})

	s1_14:AddSlider("trg_dist", {
		Text = "max distance",
		Default = 500,
		Min = 50,
		Max = 2500,
		Rounding = 0,
		Callback = function(maxDistance)
			phonk.triggerbot.max_distance = maxDistance
		end,
	})

	s32_4 = tbl2.Combat:AddRightGroupbox("esp")

	s32_4:AddToggle("esp_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.esp.enable = enable

			if not enable and getgenv().phonk_clear_esp then
				getgenv().phonk_clear_esp()
			end
		end,
	})

	s32_4:AddToggle("esp_team", {
		Text = "team check",
		Default = true,
		Callback = function(teamCheck)
			phonk.esp.team_check = teamCheck
		end,
	})

	s32_4:AddToggle("esp_hl", {
		Text = "highlight",
		Default = true,
		Callback = function(enable)
			phonk.esp.highlight.enable = enable
		end,
	}):AddColorPicker("esp_hl_fill", {
		Default = Color3.fromRGB(196, 30, 58),
		Callback = function(fillColor)
			phonk.esp.highlight.fill_color = fillColor
		end,
	})

	s32_4:AddSlider("esp_hl_ft", {
		Text = "fill transparency",
		Default = 0.45,
		Min = 0,
		Max = 1,
		Rounding = 2,
		Callback = function(fillTransparency)
			phonk.esp.highlight.fill_transparency = fillTransparency
		end,
	})

	s32_4:AddLabel("outline"):AddColorPicker("esp_hl_out", {
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(outlineColor)
			phonk.esp.highlight.outline_color = outlineColor
		end,
	})

	s32_4:AddToggle("esp_box", {
		Text = "box",
		Default = true,
		Callback = function(enable)
			phonk.esp.box.enable = enable
		end,
	}):AddColorPicker("esp_box_c", {
		Default = Color3.fromRGB(196, 30, 58),
		Callback = function(color)
			phonk.esp.box.color = color
		end,
	})

	s32_4:AddToggle("esp_name", {
		Text = "name",
		Default = true,
		Callback = function(enable)
			phonk.esp.name.enable = enable
		end,
	}):AddColorPicker("esp_name_c", {
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(color)
			phonk.esp.name.color = color
		end,
	})

	s32_4:AddToggle("esp_hp", {
		Text = "health",
		Default = true,
		Callback = function(enable)
			phonk.esp.health.enable = enable
		end,
	}):AddColorPicker("esp_hp_c", {
		Default = Color3.fromRGB(80, 220, 80),
		Callback = function(color)
			phonk.esp.health.color = color
		end,
	})

	s32_4:AddToggle("esp_dist", {
		Text = "distance",
		Default = true,
		Callback = function(enable)
			phonk.esp.distance.enable = enable
		end,
	}):AddColorPicker("esp_dist_c", {
		Default = Color3.fromRGB(200, 200, 200),
		Callback = function(color)
			phonk.esp.distance.color = color
		end,
	})

	s32_4:AddToggle("esp_tracer", {
		Text = "tracer",
		Default = false,
		Callback = function(enable)
			phonk.esp.tracer.enable = enable
		end,
	}):AddColorPicker("esp_tracer_c", {
		Default = Color3.fromRGB(196, 30, 58),
		Callback = function(color)
			phonk.esp.tracer.color = color
		end,
	})

	s32_4:AddDropdown("esp_tracer_o", {
		Text = "tracer origin",
		Values = { "bottom", "center", "mouse" },
		Default = "bottom",
		Callback = function(origin)
			phonk.esp.tracer.origin = origin
		end,
	})

	s32_4:AddToggle("esp_chams", {
		Text = "chams",
		Default = false,
		Callback = function(enable)
			phonk.esp.chams.enable = enable
		end,
	}):AddColorPicker("esp_chams_c", {
		Default = Color3.fromRGB(196, 30, 58),
		Callback = function(color)
			phonk.esp.chams.color = color
		end,
	})

	s32_4:AddDropdown("esp_chams_mat", {
		Text = "chams material",
		Values = { "Neon", "ForceField", "Glass", "Metal", "Ice", "Plastic" },
		Default = "Neon",
		Callback = function(material)
			phonk.esp.chams.material = material
		end,
	})

	s32_4:AddToggle("esp_chams_ghost", {
		Text = "ghost chams",
		Default = false,
		Callback = function(ghost)
			phonk.esp.chams.ghost = ghost
		end,
	})

	s32_4:AddToggle("esp_chams_strip", {
		Text = "strip textures",
		Default = false,
		Callback = function(stripTextures)
			phonk.esp.chams.strip_textures = stripTextures
		end,
	})

	s1_15 = tbl2.World
	s32_5 = s1_15:AddLeftGroupbox("viewmodel")

	s32_5:AddToggle("no_arm_enable", {
		Text = "no arm",
		Default = false,
		Callback = function(enable)
			phonk.no_arm.enable = enable
		end,
	})

	s32_5:AddLabel("hides viewmodel arms")
	s31_2 = s1_15:AddRightGroupbox("atmosphere")

	s12_17 = function()
		if getgenv().phonk_update_world_fx then
			getgenv().phonk_update_world_fx()
		end
	end

	s31_2:AddToggle("atm_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.world.atmosphere.enable = enable
			s12_17()
		end,
	})

	s31_2:AddSlider("atm_density", {
		Text = "density",
		Default = 0.3,
		Min = 0,
		Max = 1,
		Rounding = 2,
		Callback = function(density)
			phonk.world.atmosphere.density = density
			s12_17()
		end,
	})

	s31_2:AddSlider("atm_offset", {
		Text = "offset",
		Default = 0.25,
		Min = 0,
		Max = 1,
		Rounding = 2,
		Callback = function(offset)
			phonk.world.atmosphere.offset = offset
			s12_17()
		end,
	})

	s31_2:AddSlider("atm_glare", {
		Text = "glare",
		Default = 0.2,
		Min = 0,
		Max = 1,
		Rounding = 2,
		Callback = function(glare)
			phonk.world.atmosphere.glare = glare
			s12_17()
		end,
	})

	s31_2:AddSlider("atm_haze", {
		Text = "haze",
		Default = 1.5,
		Min = 0,
		Max = 10,
		Rounding = 1,
		Callback = function(haze)
			phonk.world.atmosphere.haze = haze
			s12_17()
		end,
	})

	s31_2:AddLabel("color"):AddColorPicker("atm_color", {
		Default = Color3.fromRGB(140, 40, 40),
		Callback = function(color)
			phonk.world.atmosphere.color = color
			s12_17()
		end,
	})

	s31_2:AddLabel("decay"):AddColorPicker("atm_decay", {
		Default = Color3.fromRGB(80, 20, 20),
		Callback = function(decay)
			phonk.world.atmosphere.decay = decay
			s12_17()
		end,
	})

	s1_16 = s1_15:AddRightGroupbox("color correction")

	s1_16:AddToggle("cc_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.world.color_correction.enable = enable
			s12_17()
		end,
	})

	s1_16:AddSlider("cc_bright", {
		Text = "brightness",
		Default = 0.05,
		Min = -1,
		Max = 1,
		Rounding = 2,
		Callback = function(brightness)
			phonk.world.color_correction.brightness = brightness
			s12_17()
		end,
	})

	s1_16:AddSlider("cc_contrast", {
		Text = "contrast",
		Default = 0.15,
		Min = -1,
		Max = 1,
		Rounding = 2,
		Callback = function(contrast)
			phonk.world.color_correction.contrast = contrast
			s12_17()
		end,
	})

	s1_16:AddSlider("cc_sat", {
		Text = "saturation",
		Default = 0.1,
		Min = -1,
		Max = 1,
		Rounding = 2,
		Callback = function(saturation)
			phonk.world.color_correction.saturation = saturation
			s12_17()
		end,
	})

	s1_16:AddLabel("tint"):AddColorPicker("cc_tint", {
		Default = Color3.fromRGB(255, 180, 180),
		Callback = function(tint)
			phonk.world.color_correction.tint = tint
			s12_17()
		end,
	})

	s1_17 = tbl2.Optimizations
	s34 = s1_17:AddLeftGroupbox("fps boost")

	s34:AddToggle("opt_no_particles", {
		Text = "remove particles & effects",
		Default = false,
		Callback = function(noParticles)
			phonk.optimizations.no_particles = noParticles
			getgenv().phonk_apply_opt()
		end,
	})

	s34:AddToggle("opt_no_shadows", {
		Text = "disable shadows",
		Default = false,
		Callback = function(noShadows)
			phonk.optimizations.no_shadows = noShadows
			getgenv().phonk_apply_opt()
		end,
	})

	s34:AddToggle("opt_no_postfx", {
		Text = "disable post processing",
		Default = false,
		Callback = function(noPostfx)
			phonk.optimizations.no_postfx = noPostfx
			getgenv().phonk_apply_opt()
		end,
	})

	s34:AddToggle("opt_no_atmosphere", {
		Text = "disable atmosphere & clouds",
		Default = false,
		Callback = function(noAtmosphere)
			phonk.optimizations.no_atmosphere = noAtmosphere
			getgenv().phonk_apply_opt()
		end,
	})

	s34:AddToggle("opt_no_textures", {
		Text = "remove textures",
		Default = false,
		Callback = function(noTextures)
			phonk.optimizations.no_textures = noTextures
			getgenv().phonk_apply_opt()
		end,
	})

	s34:AddButton("quick boost (all)", function()
		toggles.opt_no_particles:SetValue(true)
		toggles.opt_no_shadows:SetValue(true)
		toggles.opt_no_postfx:SetValue(true)
		toggles.opt_no_atmosphere:SetValue(true)
		toggles.opt_no_textures:SetValue(true)
		library:Notify("Applied fps boost", 3)
	end)

	s1_18 = s1_17:AddRightGroupbox("frame rate")

	s1_18:AddToggle("opt_fps_cap_enable", {
		Text = "limit fps",
		Default = false,
		Callback = function(fpsCapEnable)
			phonk.optimizations.fps_cap_enable = fpsCapEnable
			getgenv().phonk_apply_opt()
		end,
	})

	s1_18:AddSlider("opt_fps_cap", {
		Text = "fps limit",
		Default = 60,
		Min = 30,
		Max = 240,
		Rounding = 0,
		Callback = function(fpsCap)
			phonk.optimizations.fps_cap = fpsCap
			getgenv().phonk_apply_opt()
		end,
	})

	s1_19 = tbl2.Character
	s35 = s1_19:AddRightGroupbox("movement")

	s35:AddToggle("walkspeed_enable", {
		Text = "walkspeed",
		Default = false,
		Callback = function(enable)
			phonk.walkspeed.enable = enable
		end,
	})

	s35:AddSlider("walkspeed_multiplier", {
		Text = "multiplier",
		Default = 1.5,
		Min = 1,
		Max = 10,
		Rounding = 2,
		Suffix = "x",
		Callback = function(multiplier)
			phonk.walkspeed.multiplier = multiplier
		end,
	})

	s35:AddToggle("slide_boost_enable", {
		Text = "slide boost",
		Default = false,
		Callback = function(enable)
			phonk.slide_boost.enable = enable
		end,
	})

	s35:AddSlider("slide_boost_speed", {
		Text = "slide speed",
		Default = 60,
		Min = 1,
		Max = 200,
		Rounding = 0,
		Callback = function(speed)
			phonk.slide_boost.speed = speed
		end,
	})

	s35:AddToggle("infinite_double_jump_enable", {
		Text = "infinite double jump",
		Default = false,
		Callback = function(enable)
			phonk.infinite_double_jump.enable = enable
		end,
	})

	s35:AddToggle("fly_enable", {
		Text = "fly",
		Default = false,
		Callback = function(enable)
			phonk.fly.enable = enable
		end,
	}):AddKeyPicker("fly_key", { Default = "V", Text = "fly", Mode = "Hold", SyncToggleState = false })

	s35:AddSlider("fly_speed", {
		Text = "fly speed",
		Default = 50,
		Min = 5,
		Max = 250,
		Rounding = 0,
		Callback = function(speed)
			phonk.fly.speed = speed
		end,
	})

	s35:AddToggle("freecam_enable", {
		Text = "freecam",
		Default = false,
		Callback = function(enable)
			phonk.freecam.enable = enable
		end,
	}):AddKeyPicker("freecam_key", { Default = "B", Text = "freecam", Mode = "Toggle", SyncToggleState = false })

	s35:AddSlider("freecam_speed", {
		Text = "freecam speed",
		Default = 20,
		Min = 1,
		Max = 100,
		Rounding = 0,
		Callback = function(speed)
			phonk.freecam.speed = speed
		end,
	})

	s34_1 = s1_19:AddLeftGroupbox("viewmodel")

	s34_1:AddToggle("viewmodel_offsets_enable", {
		Text = "override viewmodel",
		Default = false,
		Callback = function(enable)
			phonk.viewmodel_offsets.enable = enable
			options.viewmodel_offset_x:SetVisible(enable)
			options.viewmodel_offset_y:SetVisible(enable)
			options.viewmodel_offset_z:SetVisible(enable)

			if enable then
				for k, v10 in next, ItemLibrary.ViewModels, nil do
					if v10.RootPartOffset then
						oldoffsets[k] = v10.RootPartOffset
					end
				end
			else
				for k, v10 in next, ItemLibrary.ViewModels, nil do
					if oldoffsets[k] then
						v10.RootPartOffset = oldoffsets[k]
					end
				end

				oldoffsets = {}
			end
		end,
	})

	s34_1:AddSlider("viewmodel_offset_x", {
		Text = "x",
		Default = 0,
		Min = -5,
		Max = 5,
		Rounding = 2,
		Visible = false,
		Callback = function(x)
			phonk.viewmodel_offsets.x = x
		end,
	})

	s34_1:AddSlider("viewmodel_offset_y", {
		Text = "y",
		Default = 0,
		Min = -5,
		Max = 5,
		Rounding = 2,
		Visible = false,
		Callback = function(y)
			phonk.viewmodel_offsets.y = y
		end,
	})

	s34_1:AddSlider("viewmodel_offset_z", {
		Text = "z",
		Default = 0,
		Min = -5,
		Max = 5,
		Rounding = 2,
		Visible = false,
		Callback = function(z)
			phonk.viewmodel_offsets.z = z
		end,
	})

	s1_20 = s1_19:AddLeftGroupbox("emote player")

	s1_20:AddToggle("animation_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.animation.enable = enable
		end,
	})

	s1_20:AddDropdown("animation_select", {
		Text = "emote",
		Values = { "Meditate", "Orbit", "Floss", "OJ", "Kicking Feet", "Take the L", "Hype" },
		Default = "Meditate",
		Callback = function(selectAnimation)
			phonk.animation.select_animation = selectAnimation
		end,
	})

	s1_20:AddInput("animation_custom_id", {
		Text = "custom id",
		Default = "",
		Placeholder = "id..",
		Callback = function(customId)
			phonk.animation.custom_id = customId or ""
		end,
	})

	s1_20:AddSlider("animation_speed", {
		Text = "speed",
		Default = 2,
		Min = 0.1,
		Max = 10,
		Rounding = 1,
		Callback = function(speed)
			phonk.animation.speed = speed
		end,
	})

	s3_28 = tbl2.Visuals
	s2_39 = s3_28:AddLeftTabbox()
	s1_21 = s2_39:AddTab("weapon")
	s2_40 = s2_39:AddTab("arms")

	s28_5 = function(arg, arg2, arg3, text)
		local str = "vm_" .. arg2
		local viewmodelChams = phonk.viewmodel_chams

		arg:AddToggle(str .. "_chams_enable", {
			Text = arg3,
			Default = false,
			Callback = function(enable)
				viewmodelChams[arg2 .. "_chams"].enable = enable
				options[str .. "_chams_material"]:SetVisible(enable)
				options[str .. "_chams_transparency"]:SetVisible(enable)

				if text then
					options[str .. "_chams_invisible"]:SetVisible(enable)
				end
			end,
		}):AddColorPicker(str .. "_chams_color", {
			Title = "color",
			Default = Color3.fromRGB(255, 255, 255),
			Callback = function(color)
				viewmodelChams[arg2 .. "_chams"].color = color
			end,
		})

		arg:AddDropdown(str .. "_chams_material", {
			Text = "material",
			Values = { "Neon", "ForceField", "Glass", "Metal", "Ice", "Glacier", "Foil", "Plastic" },
			Default = "Neon",
			Visible = false,
			Callback = function(material)
				viewmodelChams[arg2 .. "_chams"].material = material
			end,
		})

		arg:AddSlider(str .. "_chams_transparency", {
			Text = "transparency",
			Default = 0,
			Min = 0,
			Max = 1,
			Rounding = 2,
			Visible = false,
			Callback = function(transparency)
				viewmodelChams[arg2 .. "_chams"].transparency = transparency
			end,
		})

		if text then
			arg:AddToggle(str .. "_chams_invisible", {
				Text = "invisible arms",
				Default = false,
				Visible = false,
				Callback = function(invisible)
					viewmodelChams.arm_chams.invisible = invisible
				end,
			})
		end

		local v10 = arg
		local addToggle = v10.AddToggle
		local str2 = str .. "_highlight_enable"
		local tbl4 = {}
		text = text and "arm highlight" or "weapon highlight"
		tbl4.Text = text
		tbl4.Default = false

		tbl4.Callback = function(enable)
			viewmodelChams[arg2 .. "_highlight"].enable = enable
			options[str .. "_highlight_fill"]:SetVisible(enable)
			options[str .. "_highlight_outline"]:SetVisible(enable)
		end

		addToggle(v10, str2, tbl4):AddColorPicker(str .. "_highlight_color", {
			Title = "fill color",
			Default = Color3.fromRGB(255, 255, 255),
			Callback = function(color)
				viewmodelChams[arg2 .. "_highlight"].color = color
			end,
		})

		arg:AddSlider(str .. "_highlight_fill", {
			Text = "fill transparency",
			Default = 0.5,
			Min = 0,
			Max = 1,
			Rounding = 2,
			Visible = false,
			Callback = function(transparency)
				viewmodelChams[arg2 .. "_highlight"].transparency = transparency
			end,
		})
	end

	s28_5(s1_21, "weapon", "weapon chams", false)
	s28_5(s2_40, "arm", "arm chams", true)
	s36 = s3_28:AddLeftGroupbox("disable animation")

	s36:AddToggle("disable_anims_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.disable_anims.enable = enable
		end,
	})

	s36:AddDropdown("disable_anims_select", {
		Values = {
			"bobbing",
			"landing",
			"sway",
			"equip",
			"inspect",
			"sliding",
			"shoot",
			"impulse",
			"aim",
			"sprint",
			"reload",
			"attack",
			"charge",
			"throw",
		},
		Default = {},
		Multi = true,
		Text = "types",
		Callback = function(arg)
			local select_ = {}

			for k, v10 in next, arg, nil do
				local n2 = #select_ + 1
				v10 = type(k) == "number" and v10 or k
				select_[n2] = v10
			end

			phonk.disable_anims.select = select_
		end,
	})

	s37 = s3_28:AddLeftGroupbox("sounds")

	s37:AddToggle("hitsounds_enable", {
		Text = "custom hitsound",
		Default = false,
		Callback = function(enable)
			phonk.hitsounds.enable = enable
		end,
	})

	s37:AddDropdown("hitsounds_select", {
		Text = "preset",
		Values = { "hitmarker", "fatality", "csgo", "rust", "bonk" },
		Default = "hitmarker",
		Callback = function(selected)
			phonk.hitsounds.selected = selected
		end,
	})

	s37:AddInput("hitsounds_custom_id", {
		Text = "custom ID (empty = use preset)",
		Default = "",
		Placeholder = "rbxassetid://...",
		Callback = function(customId)
			phonk.hitsounds.custom_id = customId or ""
		end,
	})

	s37:AddSlider("hitsounds_volume", {
		Text = "volume",
		Default = 1,
		Min = 0,
		Max = 5,
		Rounding = 1,
		Callback = function(volume)
			phonk.hitsounds.volume = volume
		end,
	})

	s37:AddSlider("hitsounds_pitch", {
		Text = "pitch",
		Default = 1,
		Min = 0.5,
		Max = 2,
		Rounding = 1,
		Callback = function(pitch)
			phonk.hitsounds.pitch = pitch
		end,
	})

	s38 = s3_28:AddRightGroupbox("remove")

	s38:AddToggle("remove_muzzle_enable", {
		Text = "remove muzzle flash",
		Default = false,
		Callback = function(enable)
			phonk.remove_muzzle.enable = enable
		end,
	})

	s38:AddToggle("remove_gun_sounds_enable", {
		Text = "remove gun sounds",
		Default = false,
		Callback = function(enable)
			phonk.remove_gun_sounds.enable = enable
		end,
	})

	s39 = s3_28:AddRightGroupbox("damage numbers")

	s39:AddToggle("damage_numbers_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.damage_numbers.enable = enable
		end,
	}):AddColorPicker("damage_numbers_color1", {
		Default = Color3.fromRGB(255, 80, 80),
		Callback = function(color1)
			phonk.damage_numbers.color1 = color1
		end,
	}):AddColorPicker("damage_numbers_color2", {
		Default = Color3.fromRGB(255, 200, 80),
		Callback = function(color2)
			phonk.damage_numbers.color2 = color2
		end,
	})

	s39:AddToggle("damage_numbers_remove_ingame", {
		Text = "remove vanilla",
		Default = true,
		Callback = function(removeIngame)
			phonk.damage_numbers.remove_ingame = removeIngame
		end,
	})

	s39:AddDropdown("damage_numbers_color_type", {
		Text = "color type",
		Values = { "Static", "Gradient" },
		Default = "Static",
		Callback = function(colorType)
			phonk.damage_numbers.color_type = colorType
		end,
	})

	s39:AddSlider("damage_numbers_text_size", {
		Text = "text size",
		Default = 18,
		Min = 8,
		Max = 40,
		Rounding = 0,
		Callback = function(textSize)
			phonk.damage_numbers.text_size = textSize
		end,
	})

	s39:AddSlider("damage_numbers_duration", {
		Text = "duration",
		Default = 0.8,
		Min = 0.2,
		Max = 3,
		Rounding = 1,
		Callback = function(duration)
			phonk.damage_numbers.duration = duration
		end,
	})

	s39:AddSlider("damage_numbers_rise", {
		Text = "rise",
		Default = 42,
		Min = 0,
		Max = 120,
		Rounding = 0,
		Callback = function(rise)
			phonk.damage_numbers.rise = rise
		end,
	})

	s1_22 = s3_28:AddLeftTabbox()
	s41 = s1_22:AddTab("crosshair")

	s41:AddToggle("CrosshairEnable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.crosshair.enable = enable
		end,
	}):AddColorPicker("CrosshairColor", {
		Default = Color3.fromRGB(0, 255, 170),
		Callback = function(color)
			phonk.crosshair.color = color
		end,
	})

	s41:AddDropdown("CrosshairStyle", {
		Text = "style",
		Default = "cross",
		Values = { "cross", "x", "t", "circle", "dot" },
		Callback = function(style)
			phonk.crosshair.style = style
		end,
	})

	s41:AddToggle("CrosshairLines", {
		Text = "lines",
		Default = true,
		Callback = function(lines)
			phonk.crosshair.lines = lines
		end,
	})

	s41:AddSlider("CrosshairRotation", {
		Text = "rotation",
		Default = 0,
		Min = 0,
		Max = 360,
		Rounding = 0,
		Callback = function(rotation)
			phonk.crosshair.rotation = rotation
		end,
	})

	s41:AddSlider("CrosshairLength", {
		Text = "length",
		Default = 6,
		Min = 1,
		Max = 40,
		Rounding = 0,
		Callback = function(length)
			phonk.crosshair.length = length
		end,
	})

	s41:AddSlider("CrosshairThickness", {
		Text = "thickness",
		Default = 1,
		Min = 1,
		Max = 8,
		Rounding = 0,
		Callback = function(thickness)
			phonk.crosshair.thickness = thickness
		end,
	})

	s41:AddSlider("CrosshairGap", {
		Text = "gap",
		Default = 3,
		Min = 0,
		Max = 30,
		Rounding = 0,
		Callback = function(gap)
			phonk.crosshair.gap = gap
		end,
	})

	s41:AddToggle("CrosshairOutline", {
		Text = "outline",
		Default = false,
		Callback = function(outline)
			phonk.crosshair.outline = outline
		end,
	}):AddColorPicker("CrosshairOutlineColor", {
		Default = Color3.fromRGB(0, 0, 0),
		Callback = function(outlineColor)
			phonk.crosshair.outline_color = outlineColor
		end,
	})

	s41:AddToggle("CrosshairTopLine", {
		Text = "top line",
		Default = true,
		Callback = function(topLine)
			phonk.crosshair.top_line = topLine
		end,
	})

	s41:AddToggle("CrosshairBottomLine", {
		Text = "bottom line",
		Default = true,
		Callback = function(bottomLine)
			phonk.crosshair.bottom_line = bottomLine
		end,
	})

	s40 = s1_22:AddTab("lines")

	s40:AddToggle("CrosshairDot", {
		Text = "dot",
		Default = false,
		Callback = function(dot)
			phonk.crosshair.dot = dot
		end,
	})

	s40:AddToggle("CrosshairLeft", {
		Text = "left line",
		Default = true,
		Callback = function(leftLine)
			phonk.crosshair.left_line = leftLine
		end,
	})

	s40:AddToggle("CrosshairRight", {
		Text = "right line",
		Default = true,
		Callback = function(rightLine)
			phonk.crosshair.right_line = rightLine
		end,
	})

	s39_1 = s1_22:AddTab("effects")

	s39_1:AddToggle("CrosshairRotating", {
		Text = "rotating",
		Default = false,
		Callback = function(rotating)
			phonk.crosshair.rotating = rotating
		end,
	})

	s39_1:AddSlider("CrosshairRotatingSpeed", {
		Text = "speed",
		Default = 120,
		Min = 0,
		Max = 720,
		Rounding = 0,
		Suffix = "°/s",
		Callback = function(rotatingSpeed)
			phonk.crosshair.rotating_speed = rotatingSpeed
		end,
	})

	s39_1:AddToggle("CrosshairSpread", {
		Text = "spread",
		Default = false,
		Callback = function(spread)
			phonk.crosshair.spread = spread
		end,
	})

	s39_1:AddSlider("CrosshairSpreadScale", {
		Text = "spread scale",
		Default = 1,
		Min = 0,
		Max = 4,
		Rounding = 2,
		Callback = function(spreadScale)
			phonk.crosshair.spread_scale = spreadScale
		end,
	})

	s39_1:AddToggle("CrosshairAnimation", {
		Text = "animation",
		Default = false,
		Callback = function(animation)
			phonk.crosshair.animation = animation
		end,
	})

	s39_1:AddDropdown("CrosshairAnimationMode", {
		Text = "mode",
		Default = "pulse",
		Values = { "pulse", "breathe" },
		Callback = function(animationMode)
			phonk.crosshair.animation_mode = animationMode
		end,
	})

	s39_1:AddSlider("CrosshairAnimationSpeed", {
		Text = "speed",
		Default = 3,
		Min = 0.1,
		Max = 12,
		Rounding = 1,
		Callback = function(animationSpeed)
			phonk.crosshair.animation_speed = animationSpeed
		end,
	})

	s39_1:AddToggle("CrosshairFade", {
		Text = "fade color",
		Default = false,
		Callback = function(fade)
			phonk.crosshair.fade = fade
		end,
	}):AddColorPicker("CrosshairFadeColor", {
		Default = Color3.fromRGB(255, 0, 170),
		Callback = function(fadeColor)
			phonk.crosshair.fade_color = fadeColor
		end,
	})

	s39_1:AddToggle("CrosshairFollowTarget", {
		Text = "follow target",
		Default = false,
		Callback = function(followTarget)
			phonk.crosshair.follow_target = followTarget
		end,
	})

	s39_1:AddDropdown("CrosshairFollowSource", {
		Text = "follow source",
		Default = "target",
		Values = { "target", "gunpoint" },
		Callback = function(followSource)
			phonk.crosshair.follow_source = followSource
		end,
	})

	s39_1:AddToggle("CrosshairShimmer", {
		Text = "shimmer",
		Default = false,
		Callback = function(shimmer)
			phonk.crosshair.shimmer = shimmer
		end,
	})

	s39_1:AddSlider("CrosshairShimmerSpeed", {
		Text = "shimmer speed",
		Default = 4,
		Min = 0.1,
		Max = 12,
		Rounding = 1,
		Callback = function(shimmerSpeed)
			phonk.crosshair.shimmer_speed = shimmerSpeed
		end,
	})

	s1_23 = s1_22:AddTab("text")

	s1_23:AddToggle("CrosshairTextEnable", {
		Text = "enabled",
		Default = false,
		Callback = function(textEnable)
			phonk.crosshair.text_enable = textEnable
		end,
	}):AddColorPicker("CrosshairTextColor", {
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(textColor)
			phonk.crosshair.text_color = textColor
		end,
	})

	s1_23:AddInput("CrosshairTextContent", {
		Text = "content",
		Default = "PhonkWare",
		ClearTextOnFocus = false,
		Callback = function(textContent)
			phonk.crosshair.text_content = textContent
		end,
	})

	pcall(function()
		local crosshairTextContent = options.CrosshairTextContent

		if crosshairTextContent then
			if crosshairTextContent.SetValue then
				crosshairTextContent:SetValue("PhonkWare")
			end

			if crosshairTextContent.Value ~= nil then
				crosshairTextContent.Value = "PhonkWare"
			end
		end

		phonk.crosshair.text_content = "PhonkWare"
	end)

	s1_23:AddDropdown("CrosshairTextFont", {
		Text = "font",
		Default = "Plex",
		Values = { "UI", "System", "Plex", "Monospace", "Inconsolata" },
		Callback = function(textFont)
			phonk.crosshair.text_font = textFont
		end,
	})

	s1_23:AddSlider("CrosshairTextSize", {
		Text = "size",
		Default = 16,
		Min = 8,
		Max = 48,
		Rounding = 0,
		Callback = function(textSize)
			phonk.crosshair.text_size = textSize
		end,
	})

	s1_23:AddSlider("CrosshairTextOffset", {
		Text = "offset",
		Default = 18,
		Min = 0,
		Max = 120,
		Rounding = 0,
		Callback = function(textOffset)
			phonk.crosshair.text_offset = textOffset
		end,
	})

	s1_23:AddToggle("CrosshairTextOutline", {
		Text = "outline",
		Default = true,
		Callback = function(textOutline)
			phonk.crosshair.text_outline = textOutline
		end,
	})

	s1_23:AddToggle("CrosshairTextAnimation", {
		Text = "animation",
		Default = false,
		Callback = function(textAnimation)
			phonk.crosshair.text_animation = textAnimation
		end,
	})

	s1_24 = tbl2.World
	s45 = s1_24:AddRightGroupbox("map textures")

	s45:AddToggle("map_textures_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.map_textures.enable = enable
			getgenv().phonk_update_textures()
		end,
	}):AddColorPicker("map_textures_color", {
		Title = "color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(color)
			phonk.map_textures.color = color

			if phonk.map_textures.enable then
				getgenv().phonk_update_textures()
			end
		end,
	})

	s45:AddDropdown("map_textures_material", {
		Text = "material",
		Values = {
			"Neon",
			"ForceField",
			"Glass",
			"Metal",
			"Ice",
			"Glacier",
			"Foil",
			"Plastic",
			"Marble",
			"Granite",
			"Slate",
		},
		Default = "Neon",
		Callback = function(material)
			phonk.map_textures.material = material

			if phonk.map_textures.enable then
				getgenv().phonk_update_textures()
			end
		end,
	})

	s44 = s1_24:AddLeftGroupbox("camera")

	s44:AddToggle("third_person_enable", {
		Text = "third person",
		Default = false,
		Callback = function(enable)
			phonk.world.third_person.enable = enable

			pcall(function()
				if CameraController.SetThirdPersonOverride then
					CameraController:SetThirdPersonOverride(enable)
				end
			end)
		end,
	})

	s44:AddToggle("stretched_res_enable", {
		Text = "stretched res",
		Default = false,
		Callback = function(enable)
			phonk.world.stretched_res.enable = enable
		end,
	})

	s44:AddSlider("stretched_res_amount", {
		Text = "amount",
		Default = 0.2,
		Min = 0.1,
		Max = 1,
		Rounding = 2,
		Callback = function(amount)
			phonk.world.stretched_res.amount = amount
		end,
	})

	s44:AddToggle("fov_changer_enable", {
		Text = "fov changer",
		Default = false,
		Callback = function(enable)
			phonk.world.fov_changer.enable = enable
		end,
	})

	s44:AddSlider("fov_changer_fov", {
		Text = "fov",
		Default = 80,
		Min = 10,
		Max = 140,
		Rounding = 2,
		Callback = function(fov)
			phonk.world.fov_changer.fov = fov
		end,
	})

	s43 = s1_24:AddLeftGroupbox("weather")

	s43:AddToggle("weather_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.world.weather.enable = enable

			if getgenv().phonk_update_weather then
				getgenv().phonk_update_weather()
			end
		end,
	}):AddColorPicker("weather_color", {
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(color)
			phonk.world.weather.color = color

			if getgenv().phonk_update_weather then
				getgenv().phonk_update_weather()
			end
		end,
	})

	s43:AddDropdown("weather_type", {
		Text = "type",
		Values = { "snow", "rain", "light rain" },
		Default = "snow",
		Callback = function(type_)
			phonk.world.weather.type = type_

			if getgenv().phonk_update_weather then
				getgenv().phonk_update_weather()
			end
		end,
	})

	s43:AddSlider("weather_rate", {
		Text = "rate",
		Default = 100,
		Min = 1,
		Max = 400,
		Rounding = 0,
		Callback = function(rate)
			phonk.world.weather.rate = rate

			if getgenv().phonk_update_weather then
				getgenv().phonk_update_weather()
			end
		end,
	})

	s1_25 = s1_24:AddLeftGroupbox("skybox")

	s1_25:AddToggle("skybox_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.world.skybox.enable = enable
			getgenv().phonk_update_sky()
		end,
	})

	s1_25:AddDropdown("skybox_selected", {
		Values = {
			"Deep Space",
			"Purple Nebula",
			"Vaporwave",
			"Night",
			"Space",
			"Minecraft",
			"Sunset",
			"Default",
		},
		Default = "Deep Space",
		Text = "skybox",
		Callback = function(selected)
			phonk.world.skybox.selected = selected
			getgenv().phonk_update_sky()
		end,
	})

	s1_25:AddToggle("skybox_rotate", {
		Text = "rotate",
		Default = false,
		Callback = function(rotate)
			phonk.world.skybox.rotate = rotate
		end,
	})

	s1_25:AddSlider("skybox_rotate_speed", {
		Text = "rotate speed",
		Default = 1,
		Min = 0,
		Max = 100,
		Rounding = 1,
		Callback = function(rotateSpeed)
			phonk.world.skybox.rotate_speed = rotateSpeed
		end,
	})

	s1_25:AddDropdown("skybox_rotate_direction", {
		Text = "direction",
		Values = { "Horizontal", "Vertical", "Diagonal" },
		Default = "Horizontal",
		Callback = function(rotateDirection)
			phonk.world.skybox.rotate_direction = rotateDirection
		end,
	})

	s1_25:AddDropdown("skybox_rotate_method", {
		Text = "method",
		Values = { "Spin", "Wave", "Alternate" },
		Default = "Spin",
		Callback = function(rotateMethod)
			phonk.world.skybox.rotate_method = rotateMethod
		end,
	})

	s1_25:AddToggle("skybox_remove_sun", {
		Text = "remove sun",
		Default = false,
		Callback = function(removeSun)
			phonk.world.skybox.remove_sun = removeSun
			getgenv().phonk_update_sky()
		end,
	})

	s1_25:AddToggle("skybox_remove_moon", {
		Text = "remove moon",
		Default = false,
		Callback = function(removeMoon)
			phonk.world.skybox.remove_moon = removeMoon
			getgenv().phonk_update_sky()
		end,
	})

	s1_25:AddToggle("skybox_remove_stars", {
		Text = "remove stars",
		Default = false,
		Callback = function(removeStars)
			phonk.world.skybox.remove_stars = removeStars
			getgenv().phonk_update_sky()
		end,
	})

	s2_41 = v4
	s3_29 = {}

	s41_1 = {
		"LeftArm",
		"RightArm",
		"LeftUpperArm",
		"RightUpperArm",
		"LeftLowerArm",
		"RightLowerArm",
		"LeftHand",
		"RightHand",
	}

	s1_26 = function()
		phonk.char_spoof = phonk.char_spoof or { enable = false, selected = "", saved = {}, last_id = nil }

		if isfile and isfile("phonkware/char_spoof.json") then
			pcall(function()
				local json = readfile("phonkware/char_spoof.json")
				local data = game:GetService("HttpService"):JSONDecode(json)

				if type(data) == "table" then
					phonk.char_spoof.saved = data.saved or data or {}
				end
			end)
		end

		if type(phonk.char_spoof.saved) ~= "table" then
			phonk.char_spoof.saved = {}
		end
	end

	s456 = function()
		pcall(function()
			if not isfolder then
				return
			end

			if isfolder and not isfolder("phonkware") then
				makefolder("phonkware")
			end

			if writefile then
				writefile("phonkware/char_spoof.json", game:GetService("HttpService"):JSONEncode({ saved = phonk.char_spoof.saved }))
			end
		end)
	end

	s457 = function()
		local tbl4 = {}
		local v10 = ipairs
		local saved = phonk.char_spoof.saved or {}

		for _, v11 in v10(saved) do
			if v11 and v11.name then
				table.insert(tbl4, tostring(v11.name))
			end
		end

		return tbl4
	end

	s458 = function(arg)
		local v10 = ipairs
		local saved = phonk.char_spoof.saved or {}

		for _, v11 in v10(saved) do
			if v11 and tostring(v11.name) == tostring(arg) then
				return v11
			end
		end

		return nil
	end

	s459 = function(arg)
		local num = tonumber(arg)
		local v10 = ipairs
		local saved = phonk.char_spoof.saved or {}

		for _, v11 in v10(saved) do
			if v11 and tonumber(v11.id) == num then
				return v11
			end
		end

		return nil
	end

	s460 = function(arg)
		local num = tonumber(arg)
		if not num then
			return nil
		end
		local nameFromUserIdAsync = nil

		pcall(function()
			nameFromUserIdAsync = s2_41:GetNameFromUserIdAsync(num)
		end)

		return nameFromUserIdAsync
	end

	s461 = function(arg)
		local num = tonumber(arg)
		if not num then
			return nil
		end

		if s3_29[num] then
			return s3_29[num]
		end

		local ok, result = pcall(function()
			return s2_41:GetCharacterAppearanceAsync(num)
		end)

		if ok and result then
			s3_29[num] = result
			return result
		end
		return nil
	end

	s462 = function(arg)
		if not arg then
			return
		end

		for _, child in ipairs(arg:GetChildren()) do
			if child:IsA("Accessory") then
				local handle = child:FindFirstChild("Handle")

				if handle then
					local attachment = handle:FindFirstChildOfClass("Attachment")

					if attachment then
						local name = attachment.Name

						if string.find(name, "Hair") or string.find(name, "hair") then
							handle.Transparency = 1

							for _, descendant in ipairs(handle:GetDescendants()) do
								if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") or descendant:IsA("MeshPart") then
									pcall(function()
										descendant.Transparency = 1
									end)
								end
							end

							local specialMesh = handle:FindFirstChildOfClass("SpecialMesh")

							if specialMesh then
								pcall(function()
									specialMesh.Scale = Vector3.zero
								end)
							end
						end
					end
				end
			end
		end
	end

	s463 = function(arg, arg2)
		for _, v10 in ipairs(s41_1) do
			local v11 = arg2:FindFirstChild(v10)
			local v12 = arg:FindFirstChild(v10)

			if v11 and v12 and v11:IsA("BasePart") and v12:IsA("BasePart") then
				pcall(function()
					if v12:IsA("MeshPart") and v11:IsA("MeshPart") then
						v12.MeshId = v11.MeshId
						v12.TextureID = v11.TextureID
					end

					local specialMesh = v11:FindFirstChildOfClass("SpecialMesh")

					if specialMesh then
						for _, child in ipairs(v12:GetChildren()) do
							if child:IsA("SpecialMesh") then
								child:Destroy()
							end
						end

						specialMesh:Clone().Parent = v12
					end

					v12.Color = v11.Color
					v12.Material = v11.Material
					v12.Transparency = v11.Transparency
				end)
			end
		end
	end

	s464 = function(parent, arg)
		if not parent or not arg then
			return false
		end
		local num = tonumber(arg)
		local v10 = s461(num)

		if not v10 then
			pcall(function()
				library:Notify("char spoof: invalid id / failed load", 3)
			end)

			return false
		end

		task.spawn(function()
			pcall(function()
				local clone = v10:Clone()
				local tbl4 = {}

				for _, child in ipairs(clone:GetChildren()) do
					tbl4[child.Name] = true
				end

				for _, child in pairs(parent:GetChildren()) do
					if child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
						child:Destroy()
					end
				end

				for _, child in pairs(parent:GetChildren()) do
					if child:IsA("Accessory") and tbl4[child.Name] then
						child:Destroy()
					end
				end

				s462(parent)

				for _, child in pairs(clone:GetChildren()) do
					pcall(function()
						if child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") or child:IsA("BodyColors") or child:IsA("CharacterMesh") then
							child.Parent = parent
						elseif child:IsA("Accessory") then
							local handle = child:FindFirstChild("Handle")

							if handle then
								handle.CanCollide = false
								handle.Transparency = 0
								local attachment = handle:FindFirstChildOfClass("Attachment")

								if attachment then
									local v11 = parent:FindFirstChild(attachment.Name, true)

									if v11 then
										local weld = Instance.new("Weld")
										weld.Part0 = handle
										weld.Part1 = v11.Parent
										weld.C0 = attachment.CFrame
										weld.C1 = v11.CFrame
										weld.Parent = handle
									end
								end

								child.Parent = parent
							end
						end
					end)
				end

				s463(parent, clone)
				task.wait(0.5)

				if parent and parent.Parent then
					s462(parent)
				end

				task.wait(0.8)

				if parent and parent.Parent then
					s462(parent)
				end
			end)
		end)

		return true
	end

	getgenv().phonk_char_spoof_apply = function(arg)
		local lastId = tonumber(arg)

		if not lastId then
			pcall(function()
				library:Notify("char spoof: enter a valid user id", 2)
			end)

			return false
		end

		local charSpoof = s460(lastId)

		if not charSpoof then
			pcall(function()
				library:Notify("char spoof: could not resolve user id", 2)
			end)

			return false
		end

		if not s461(lastId) then
			pcall(function()
				library:Notify("char spoof: failed to load appearance", 2)
			end)

			return false
		end

		if not s459(lastId) then
			table.insert(phonk.char_spoof.saved, { id = lastId, name = charSpoof })
			s456()
		end

		phonk.char_spoof.selected = charSpoof
		phonk.char_spoof.last_id = lastId
		phonk.char_spoof.enable = true

		if localPlayer2.Character then
			s464(localPlayer2.Character, lastId)
		end

		pcall(function()
			library:Notify("char spoof: " .. charSpoof, 2)
		end)

		return true, charSpoof
	end

	getgenv().phonk_char_spoof_names = s457

	getgenv().phonk_char_spoof_refresh = function()
	end

	s1_26()

	v2:Add(localPlayer2.CharacterAdded:Connect(function(character)
		task.wait(0.6)
		if not phonk.char_spoof or not phonk.char_spoof.enable then
			return
		end
		local lastId = phonk.char_spoof.last_id
		local id

		if not lastId and phonk.char_spoof.selected then
			local v10 = s458(phonk.char_spoof.selected)

			if v10 then
				id = v10.id
			else
				id = lastId
			end
		else
			id = lastId
		end

		if id then
			s464(character, id)
		end
	end))

	task.spawn(function()
		task.wait(1)

		if phonk.char_spoof and phonk.char_spoof.enable and phonk.char_spoof.last_id and localPlayer2.Character then
			s464(localPlayer2.Character, phonk.char_spoof.last_id)
		end
	end)

	s3_30 = tbl2.Misc
	s2_42 = s3_30:AddLeftTabbox()
	s1_27 = s2_42:AddTab("device spoof")

	s1_27:AddToggle("device_spoof_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.device_spoof.enable = enable
		end,
	})

	s1_27:AddDropdown("device_spoof_type", {
		Text = "type",
		Values = { "Touch", "MouseKeyboard", "Gamepad", "VR" },
		Default = 2,
		Callback = function(type_)
			phonk.device_spoof.type = type_
		end,
	})

	s1_28 = s2_42:AddTab("sound spammer")

	s1_28:AddToggle("sound_spammer_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.sound_spammer.enable = enable
		end,
	})

	s1_28:AddDropdown("sound_spammer_type", {
		Text = "sound type",
		Values = { "DoubleJump", "Slide" },
		Default = 1,
		Callback = function(type_)
			phonk.sound_spammer.type = type_
		end,
	})

	s1_29 = s3_30:AddRightTabbox()
	s48 = s1_29:AddTab("streak")

	s48:AddToggle("streak_spoof_enable", {
		Text = "spoof",
		Default = false,
		Callback = function(enable)
			phonk.spoof.streak.enable = enable
		end,
	})

	s48:AddInput("streak_spoof_text", {
		Default = "9",
		Numeric = true,
		Text = "value",
		Callback = function(arg)
			local value = tonumber(arg)

			if value then
				phonk.spoof.streak.value = value
			end
		end,
	})

	s47 = s1_29:AddTab("level")

	s47:AddToggle("level_spoof_enable", {
		Text = "spoof",
		Default = false,
		Callback = function(enable)
			phonk.spoof.level.enable = enable
		end,
	})

	s47:AddInput("level_spoof_text", {
		Default = "9",
		Numeric = true,
		Text = "value",
		Callback = function(arg)
			local value = tonumber(arg)

			if value then
				phonk.spoof.level.value = value
			end
		end,
	})

	s46 = s1_29:AddTab("local")

	s46:AddToggle("name_spoof_local", {
		Text = "enable",
		Default = false,
		Callback = function(spoofLocal)
			phonk.profile.spoof_local = spoofLocal
		end,
	})

	s46:AddInput("name_spoof_local_value", {
		Default = "",
		Text = "username",
		Callback = function(spoofLocalName)
			phonk.profile.spoof_local_name = spoofLocalName or ""
		end,
	})

	s48_1 = s1_29:AddTab("other")

	s48_1:AddToggle("name_spoof_other", {
		Text = "enable",
		Default = false,
		Callback = function(spoofOther)
			phonk.profile.spoof_other = spoofOther
		end,
	})

	s48_1:AddInput("name_spoof_other_value", {
		Text = "username",
		Callback = function(spoofOtherName)
			phonk.profile.spoof_other_name = spoofOtherName or ""
		end,
	})

	s1_30 = s3_30:AddLeftGroupbox("character spoof")

	s1_30:AddToggle("char_spoof_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.char_spoof.enable = enable
			if not enable then
				return
			end
			local selected = phonk.char_spoof.selected

			if (not selected or selected == "" or selected == "(none saved)") and options.char_spoof_saved then
				selected = options.char_spoof_saved.Value
			end

			local lastId = phonk.char_spoof.last_id

			if selected and selected ~= "" and selected ~= "(none saved)" then
				local v10 = ipairs
				local saved = phonk.char_spoof.saved or {}

				for _, v11 in v10(saved) do
					if v11 and tostring(v11.name) == tostring(selected) then
						lastId = v11.id
						phonk.char_spoof.selected = selected
						phonk.char_spoof.last_id = lastId
						break
					end
				end
			end

			if lastId then
				pcall(function()
					getgenv().phonk_char_spoof_apply(lastId)
				end)
			else
				library:Notify("select a saved player first", 2)
			end
		end,
	})

	s2_43 = function()
		local phonkCharSpoofNames = getgenv().phonk_char_spoof_names and getgenv().phonk_char_spoof_names() or {}
		if #phonkCharSpoofNames == 0 then
			return { "(none saved)" }
		end
		return phonkCharSpoofNames
	end

	s1_30:AddDropdown("char_spoof_saved", {
		Text = "saved players",
		Values = s2_43(),
		Default = 1,
		Callback = function(selected)
			if not selected or selected == "(none saved)" then
				return
			end
			phonk.char_spoof.selected = selected
			local v10 = ipairs
			local saved = phonk.char_spoof.saved or {}

			for _, v11 in v10(saved) do
				if v11 and tostring(v11.name) == tostring(selected) then
					phonk.char_spoof.last_id = v11.id
					phonk.char_spoof.enable = true

					if toggles.char_spoof_enable then
						pcall(function()
							toggles.char_spoof_enable:SetValue(true)
						end)
					end

					pcall(function()
						local id = v11.id
						getgenv().phonk_char_spoof_apply(id)
					end)

					break
				end
			end
		end,
	})

	s1_30:AddInput("char_spoof_id", {
		Text = "user id",
		Default = "",
		Numeric = true,
		Placeholder = "roblox user id",
		Callback = function()
		end,
	})

	s1_30:AddButton("add / apply", function()
		local charSpoofId = options.char_spoof_id
		local num = tonumber(charSpoofId and (charSpoofId.Value or "") or "")

		if not num then
			local selected = phonk.char_spoof.selected

			if (not selected or selected == "" or selected == "(none saved)") and options.char_spoof_saved then
				selected = options.char_spoof_saved.Value
			end

			if selected and selected ~= "" and selected ~= "(none saved)" then
				local v10 = ipairs
				local saved = phonk.char_spoof.saved or {}

				for _, v11 in v10(saved) do
					if v11 and tostring(v11.name) == tostring(selected) then
						num = tonumber(v11.id)
						break
					end
				end
			end
		end

		if not num then
			library:Notify("select a saved player or enter a user id", 2)
			return
		end
		local v10, v11 = getgenv().phonk_char_spoof_apply(num)

		if v10 and options.char_spoof_saved then
			pcall(function()
				local v12 = getgenv().phonk_char_spoof_names()

				if options.char_spoof_saved.SetValues then
					options.char_spoof_saved:SetValues(v12)
				elseif options.char_spoof_saved.Values then
					options.char_spoof_saved.Values = v12
				end

				if v11 and options.char_spoof_saved.SetValue then
					options.char_spoof_saved:SetValue(v11)
				end
			end)

			if toggles.char_spoof_enable then
				pcall(function()
					toggles.char_spoof_enable:SetValue(true)
				end)
			end
		end
	end)

	s1_30:AddButton("remove selected", function()
		local selected = phonk.char_spoof.selected
		if not selected or selected == "" then
			return
		end
		local saved = {}
		local v10 = ipairs
		local saved2 = phonk.char_spoof.saved or {}

		for _, v11 in v10(saved2) do
			if v11 and tostring(v11.name) ~= tostring(selected) then
				table.insert(saved, v11)
			end
		end

		phonk.char_spoof.saved = saved

		pcall(function()
			if writefile then
				if isfolder and not isfolder("phonkware") then
					makefolder("phonkware")
				end

				writefile("phonkware/char_spoof.json", game:GetService("HttpService"):JSONEncode({ saved = saved }))
			end
		end)

		pcall(function()
			local tbl4 = getgenv().phonk_char_spoof_names()

			if #tbl4 == 0 then
				tbl4 = { "(none saved)" }
			end

			if options.char_spoof_saved and options.char_spoof_saved.SetValues then
				options.char_spoof_saved:SetValues(tbl4)
			end
		end)

		library:Notify("removed " .. tostring(selected), 2)
	end)

	s1_30:AddLabel("id empty = apply selected from dropdown")
	s51 = tbl2["UI Settings"]:AddLeftGroupbox("menu")
	s51:AddLabel("menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "menu keybind" })

	if options.MenuKeybind then
		library.ToggleKeybind = options.MenuKeybind
		library.MenuBindPickers = library.MenuBindPickers or {}
		table.insert(library.MenuBindPickers, options.MenuKeybind)
	end

	s51:AddToggle("silent_load_toggle", {
		Text = "silent load",
		Default = false,
		Callback = function(arg)
			getgenv().silent_load = arg and true or false

			pcall(function()
				if isfolder and not isfolder("phonkware") then
					makefolder("phonkware")
				end

				if writefile then
					writefile("phonkware/silent_load.txt", arg and "1" or "0")
				end
			end)

			if arg then
				pcall(function()
					if v and v.Outer then
						v.Outer.Visible = false
					end

					library.MenuOpen = false
				end)
			end
		end,
	})

	s51:AddLabel("silent load hides UI on next run")
	s2_45 = nil

	s3_31 = function()
		if s2_45 then
			pcall(function()
				s2_45:Destroy()
			end)

			s2_45 = nil
		end

		local phonkMobileBtns = getgenv().phonk_mobile_btns

		if phonkMobileBtns then
			phonkMobileBtns.eu = false
			phonkMobileBtns.aimbot = false
			phonkMobileBtns.underground = false
			phonkMobileBtns.tp = false
		end
	end

	s23 = function()
		return {
			accent = library.AccentColor or Color3.fromRGB(196, 30, 58),
			main = library.MainColor or Color3.fromRGB(18, 18, 18),
			bg = library.BackgroundColor or Color3.fromRGB(10, 10, 10),
			outline = library.OutlineColor or Color3.fromRGB(45, 40, 42),
			font = library.FontColor or Color3.fromRGB(235, 230, 230),
		}
	end

	s470 = function(arg)
		local flag2 = false
		local position = nil
		local position2 = nil

		arg.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				flag2 = true
				position = input.Position
				position2 = arg.Position
				local connection = nil

				connection = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						flag2 = false

						if connection then
							connection:Disconnect()
						end
					end
				end)
			end
		end)

		v6.InputChanged:Connect(function(input)
			if not flag2 or not position or not position2 then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local n2 = input.Position - position
				arg.Position = UDim2.new(position2.X.Scale, position2.X.Offset + n2.X, position2.Y.Scale, position2.Y.Offset + n2.Y)
			end
		end)
	end

	s471 = function(parent, name, text, text2, arg, position)
		local v10 = s23()
		local frame = Instance.new("Frame")
		frame.Name = name
		frame.Size = UDim2.fromOffset(112, 52)
		frame.Position = position
		frame.BackgroundColor3 = v10.bg
		frame.BorderSizePixel = 0
		frame.Active = true
		frame.Parent = parent
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = v10.outline
		uiStroke.Thickness = 1.2
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Parent = frame
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 10)
		uiPadding.PaddingRight = UDim.new(0, 10)
		uiPadding.PaddingTop = UDim.new(0, 8)
		uiPadding.PaddingBottom = UDim.new(0, 8)
		uiPadding.Parent = frame
		local frame2 = Instance.new("Frame")
		frame2.Name = "Strip"
		frame2.Size = UDim2.new(0, 3, 1, 0)
		frame2.Position = UDim2.fromOffset(-10, -8)
		frame2.BackgroundColor3 = v10.accent
		frame2.BorderSizePixel = 0
		frame2.Parent = frame
		Instance.new("UICorner", frame2).CornerRadius = UDim.new(0, 2)
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.Size = UDim2.new(1, 0, 0, 18)
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextSize = 14
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextColor3 = v10.font
		textLabel.Text = text
		textLabel.Parent = frame
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = "Sub"
		textLabel2.BackgroundTransparency = 1
		textLabel2.Position = UDim2.fromOffset(0, 20)
		textLabel2.Size = UDim2.new(1, 0, 0, 14)
		textLabel2.Font = Enum.Font.GothamMedium
		textLabel2.TextSize = 11
		textLabel2.TextXAlignment = Enum.TextXAlignment.Left
		textLabel2.TextColor3 = Color3.fromRGB(130, 125, 128)
		textLabel2.Text = text2
		textLabel2.Parent = frame
		local frame3 = Instance.new("Frame")
		frame3.Name = "Dot"
		frame3.AnchorPoint = Vector2.new(1, 0.5)
		frame3.Position = UDim2.new(1, 0, 0.5, 0)
		frame3.Size = UDim2.fromOffset(8, 8)
		frame3.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		frame3.BorderSizePixel = 0
		frame3.Parent = frame
		Instance.new("UICorner", frame3).CornerRadius = UDim.new(1, 0)
		local textButton = Instance.new("TextButton")
		textButton.Size = UDim2.fromScale(1, 1)
		textButton.Position = UDim2.fromOffset(-10, -8)
		textButton.Size = UDim2.new(1, 20, 1, 16)
		textButton.BackgroundTransparency = 1
		textButton.Text = ""
		textButton.ZIndex = 5
		textButton.Parent = frame

		local function fn7()
			local phonkMobileBtns = getgenv().phonk_mobile_btns
			phonkMobileBtns = phonkMobileBtns and phonkMobileBtns[arg]
			local v11 = s23()

			if phonkMobileBtns then
				frame.BackgroundColor3 = Color3.new(v11.bg.R * 0.7 + v11.accent.R * 0.15, v11.bg.G * 0.7 + v11.accent.G * 0.15, v11.bg.B * 0.7 + v11.accent.B * 0.15)
				uiStroke.Color = v11.accent
				frame2.BackgroundColor3 = v11.accent
				textLabel.TextColor3 = v11.accent
				textLabel2.Text = "ACTIVE"
				textLabel2.TextColor3 = v11.accent
				frame3.BackgroundColor3 = v11.accent
			else
				frame.BackgroundColor3 = v11.bg
				uiStroke.Color = v11.outline
				frame2.BackgroundColor3 = v11.outline
				textLabel.TextColor3 = v11.font
				textLabel2.Text = text2
				textLabel2.TextColor3 = Color3.fromRGB(130, 125, 128)
				frame3.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			end
		end

		fn7()

		textButton.MouseButton1Click:Connect(function()
			local phonkMobileBtns = getgenv().phonk_mobile_btns
			if not phonkMobileBtns then
				return
			end
			phonkMobileBtns[arg] = not phonkMobileBtns[arg]
			local v11 = phonkMobileBtns[arg]

			if arg == "eu" then
				phonk.eu_counter.enable = v11

				if toggles.eu_counter_enable then
					pcall(function()
						toggles.eu_counter_enable:SetValue(v11)
					end)
				end
			elseif arg == "aimbot" then
				phonk.aimbot.enable = v11

				if toggles.aim_enable then
					pcall(function()
						toggles.aim_enable:SetValue(v11)
					end)
				end
			elseif arg == "underground" then
				phonk.underground.enable = v11

				if options and options.ug_depth and type(options.ug_depth.Value) == "number" then
					phonk.underground.depth = options.ug_depth.Value
				end

				if toggles.ug_enable then
					pcall(function()
						toggles.ug_enable:SetValue(v11)
					end)
				end
			elseif arg ~= "tp" then
				if arg == "fly" then
					phonk.fly.enable = v11

					if toggles.fly_enable then
						pcall(function()
							toggles.fly_enable:SetValue(v11)
						end)
					end
				elseif arg == "freecam" then
					phonk.freecam.enable = v11

					if toggles.freecam_enable then
						pcall(function()
							toggles.freecam_enable:SetValue(v11)
						end)
					end
				elseif arg == "ragebot" then
					phonk.ragebot.enable = v11

					if toggles.ragebot_enable then
						pcall(function()
							toggles.ragebot_enable:SetValue(v11)
						end)
					end
				elseif arg == "triggerbot" then
					phonk.triggerbot.enable = v11

					if toggles.trg_enable then
						pcall(function()
							toggles.trg_enable:SetValue(v11)
						end)
					end
				elseif arg == "silent" then
					phonk.silent_aim.enable = v11

					if toggles.silent_aim_enable then
						pcall(function()
							toggles.silent_aim_enable:SetValue(v11)
						end)
					end
				end
			end

			fn7()
		end)

		s470(frame)
		return frame
	end

	s472 = function()
		s3_31()
		local v10 = s23()
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "PhonkWare_MobileLogo"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 50
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

		pcall(function()
			if gethui then
				screenGui.Parent = gethui()
			else
				screenGui.Parent = game:GetService("CoreGui")
			end
		end)

		pcall(function()
			local phonkUiScale = getgenv().phonk_ui_scale or 1
			local phonkUIScale = screenGui:FindFirstChild("PhonkUIScale") or Instance.new("UIScale")
			phonkUIScale.Name = "PhonkUIScale"
			phonkUIScale.Scale = phonkUiScale
			phonkUIScale.Parent = screenGui
		end)

		local frame = Instance.new("Frame")
		frame.Name = "MenuCard"
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.Position = UDim2.new(0.5, 0, 0, 12)
		frame.Size = UDim2.fromOffset(64, 64)
		frame.BackgroundColor3 = v10.bg
		frame.BorderSizePixel = 0
		frame.Active = true
		frame.Parent = screenGui
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = v10.accent
		uiStroke.Thickness = 2
		uiStroke.Parent = frame
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.BackgroundTransparency = 1
		imageLabel.Size = UDim2.fromScale(1.4, 1.4)
		imageLabel.Position = UDim2.fromScale(-0.2, -0.2)
		imageLabel.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		imageLabel.ImageTransparency = 1
		imageLabel.Parent = frame
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.Font = Enum.Font.GothamBlack
		textLabel.Text = "PW"
		textLabel.TextSize = 22
		textLabel.TextColor3 = v10.accent
		textLabel.TextStrokeColor3 = Color3.fromRGB(80, 0, 0)
		textLabel.TextStrokeTransparency = 0.5
		textLabel.Parent = frame
		local textButton = Instance.new("TextButton")
		textButton.Size = UDim2.fromScale(1, 1)
		textButton.BackgroundTransparency = 1
		textButton.Text = ""
		textButton.ZIndex = 5
		textButton.Parent = frame

		textButton.MouseButton1Click:Connect(function()
			pcall(function()
				library:Toggle()
			end)
		end)

		s470(frame)

		task.spawn(function()
			while screenGui.Parent do
				for i = 0, 30 do
					if screenGui.Parent then
						uiStroke.Transparency = 0.05 + i / 30 * 0.4
						task.wait(0.03)
						continue
					end

					break
				end

				for i = 0, 30 do
					if screenGui.Parent then
						uiStroke.Transparency = 0.45 - i / 30 * 0.4
						task.wait(0.03)
						continue
					end

					break
				end
			end
		end)

		s2_45 = screenGui

		if v2 and v2.Add then
			pcall(function()
				v2:Add(screenGui)
			end)
		end

		rebuild_mobile_feature_buttons()

		task.spawn(function()
			while screenGui.Parent do
				local btnUG = screenGui:FindFirstChild("BtnUG")

				if btnUG then
					local sub = btnUG:FindFirstChild("Sub")
					local phonkMobileBtns = getgenv().phonk_mobile_btns
					local flag2

					if sub then
						flag2 = not (phonkMobileBtns and phonkMobileBtns.underground)
					else
						flag2 = sub
					end

					if flag2 then
						local value

						if options and options.ug_depth and type(options.ug_depth.Value) == "number" then
							value = options.ug_depth.Value
						else
							local depth = phonk.underground and phonk.underground.depth
							value = 5.8

							if depth then
								value = phonk.underground.depth
							end
						end

						sub.Text = string.format("%.1f depth", value)
					end
				end

				task.wait(0.4)
			end
		end)
	end

	rebuild_mobile_feature_buttons = function()
		local v10 = s2_45
		if not v10 or not v10.Parent then
			return
		end

		for _, child in ipairs(v10:GetChildren()) do
			if child:IsA("Frame") and child.Name ~= "MenuCard" and child.Name:sub(1, 3) == "Btn" then
				pcall(function()
					child:Destroy()
				end)
			end
		end

		local function fn7(arg)
			local v11 = toggles and toggles[arg]
			if v11 and v11.Value == true then
				return true
			end
			return false
		end

		local str = "depth"

		pcall(function()
			if options and options.ug_depth and options.ug_depth.Value then
				str = string.format("%.1f", options.ug_depth.Value)
			elseif phonk.underground and phonk.underground.depth then
				str = string.format("%.1f", phonk.underground.depth)
			end
		end)

		local n2 = 14
		local n3 = 88
		local n4 = 120

		local function fn8()
			local udim2 = UDim2.new(0, n2, 0, n3)
			n2 += n4

			if n2 > 400 then
				n2 = 14
				n3 += 60
			end

			return udim2
		end

		if fn7("eu_counter_enable") or phonk.eu_counter and phonk.eu_counter.enable then
			local v11 = s471
			local v12 = fn8()
			v11(v10, "BtnEU", "UE Counter", "tap to toggle", "eu", v12)
		end

		local v11 = s471
		local v12 = fn8()
		v11(v10, "BtnAim", "Aimbot", "tap to toggle", "aimbot", v12)
		local v13 = s471
		local v14 = fn8()
		v13(v10, "BtnSA", "Silent Aim", "tap to toggle", "silent", v14)

		if fn7("ug_enable") or phonk.underground and phonk.underground.enable then
			local v15 = s471
			local v16 = fn8()
			v15(v10, "BtnUG", "Underground", str, "underground", v16)
		end

		if fn7("fly_enable") or phonk.fly and phonk.fly.enable then
			local v15 = s471
			local v16 = fn8()
			v15(v10, "BtnFly", "Fly", "tap to toggle", "fly", v16)
		end

		if fn7("freecam_enable") or phonk.freecam and phonk.freecam.enable then
			local v15 = s471
			local v16 = fn8()
			v15(v10, "BtnFC", "Freecam", "tap to toggle", "freecam", v16)
		end

		if fn7("ragebot_enable") or phonk.ragebot and phonk.ragebot.enable then
			local v15 = s471
			local v16 = fn8()
			v15(v10, "BtnRage", "Ragebot", "tap to toggle", "ragebot", v16)
		end

		if fn7("trg_enable") or phonk.triggerbot and phonk.triggerbot.enable then
			local v15 = s471
			local v16 = fn8()
			v15(v10, "BtnTrg", "Triggerbot", "tap to toggle", "triggerbot", v16)
		end

		local v15 = s471
		local v16 = fn8()
		v15(v10, "BtnTP", "TP Player", "hold/tap", "tp", v16)
	end

	s473 = rebuild_mobile_feature_buttons
	getgenv().phonk_rebuild_mobile_btns = s473
	getgenv().phonk_create_mobile_logo = s472
	getgenv().phonk_destroy_mobile_logo = s3_31

	s51:AddToggle("mobile_user_toggle", {
		Text = "Mobile User",
		Default = false,
		Callback = function(arg)
			if arg then
				s472()
			else
				s3_31()
			end
		end,
	})

	task.defer(function()
		for _, v10 in ipairs({
			"eu_counter_enable",
			"aim_enable",
			"ug_enable",
			"fly_enable",
			"freecam_enable",
			"ragebot_enable",
			"trg_enable",
			"silent_aim_enable",
		}) do
			local v11 = toggles
			local v12

			if toggles then
				v12 = toggles[v10]
			else
				v12 = v11
			end

			if v12 and v12.OnChanged then
				pcall(function()
					v12:OnChanged(function()
						if s2_45 and s2_45.Parent then
							rebuild_mobile_feature_buttons()
						end
					end)
				end)
			elseif v12 then
				pcall(function()
					local setValue = v12.SetValue

					if type(setValue) == "function" then
						v12.SetValue = function(arg, arg2, ...)
							local v13 = table.pack(...)
							local v14 = setValue
							v13.n = 3 + v13.n - 1
							table.move(v13, 1, v13.n, 3, v13)
							v13[1] = arg
							v13[2] = arg2
							local v15 = v14(table.unpack(v13, 1, v13.n))

							if s2_45 and s2_45.Parent then
								task.defer(rebuild_mobile_feature_buttons)
							end

							return v15
						end
					end
				end)
			end
		end

		task.spawn(function()
			local str = ""

			while true do
				task.wait(0.5)
				if not (s2_45 and s2_45.Parent) then
					str = ""
					continue
				end
				local concat = table.concat
				local tbl4 = {}
				local str2 = tostring(toggles.eu_counter_enable and toggles.eu_counter_enable.Value)
				local str3 = tostring(toggles.aim_enable and toggles.aim_enable.Value)
				local str4 = tostring(toggles.ug_enable and toggles.ug_enable.Value)
				local str5 = tostring(toggles.fly_enable and toggles.fly_enable.Value)
				local str6 = tostring(toggles.freecam_enable and toggles.freecam_enable.Value)
				local str7 = tostring(toggles.ragebot_enable and toggles.ragebot_enable.Value)
				local str8 = tostring(toggles.trg_enable and toggles.trg_enable.Value)
				local v10 = tostring
				local value = toggles.silent_aim_enable and toggles.silent_aim_enable.Value
				local v11 = table.pack(v10(value))
				tbl4[1] = str2
				tbl4[2] = str3
				tbl4[3] = str4
				tbl4[4] = str5
				tbl4[5] = str6
				tbl4[6] = str7
				tbl4[7] = str8

				do
					local values = table.pack(table.unpack(v11, 1, v11.n))
					table.move(values, 1, values.n, 8, tbl4)
				end

				local v12 = concat(tbl4, ",")
				if v12 == str then
					continue
				end
				rebuild_mobile_feature_buttons()
				str = v12
			end
		end)
	end)

	s51:AddLabel("logo button toggles menu (mobile)")

	s51:AddButton("unload", function()
		library:Unload()
	end)

	s473_1 = function()
		pcall(function()
			library.AccentColorDark = library:GetDarkerColor(library.AccentColor)
			library.AccentColorLight = library:GetLighterColor(library.AccentColor)
		end)

		pcall(function()
			library:UpdateColorsUsingRegistry()
		end)

		pcall(function()
			if library.RefreshThemedControls then
				library:RefreshThemedControls()
			end
		end)
	end

	s51_1 = tbl2["UI Settings"]:AddRightGroupbox("appearance")

	s51_1:AddLabel("accent / buttons"):AddColorPicker("ui_accent", {
		Default = library.AccentColor or Color3.fromHex("c41e3a"),
		Callback = function(accentColor)
			library.AccentColor = accentColor

			if library.OverlayGlowColor then
				library.OverlayGlowColor = accentColor
			end

			s473_1()
		end,
	})

	s51_1:AddLabel("font color"):AddColorPicker("ui_font", {
		Default = library.FontColor or Color3.fromHex("e0d4d6"),
		Callback = function(fontColor)
			library.FontColor = fontColor
			s473_1()
		end,
	})

	s51_1:AddLabel("main / boxes"):AddColorPicker("ui_main", {
		Default = library.MainColor or Color3.fromHex("121212"),
		Callback = function(mainColor)
			library.MainColor = mainColor
			s473_1()
		end,
	})

	s51_1:AddLabel("background"):AddColorPicker("ui_bg", {
		Default = library.BackgroundColor or Color3.fromHex("0a0a0a"),
		Callback = function(backgroundColor)
			library.BackgroundColor = backgroundColor
			s473_1()
		end,
	})

	s51_1:AddLabel("outline"):AddColorPicker("ui_outline", {
		Default = library.OutlineColor or Color3.new(0, 0, 0),
		Callback = function(outlineColor)
			library.OutlineColor = outlineColor
			s473_1()
		end,
	})

	s51_1:AddLabel("slider / gradient"):AddColorPicker("ui_gradient", {
		Default = library.GradientColor or Color3.fromHex("8b1a1a"),
		Callback = function(gradientColor)
			library.GradientColor = gradientColor
			s473_1()

			pcall(function()
				if library.UpdateAllGradientTexts then
					library:UpdateAllGradientTexts()
				end
			end)
		end,
	})

	s12_24 = {
		"Builder Sans ExtraBold",
		"Builder Sans Bold",
		"Builder Sans",
		"Code",
		"Gotham",
		"Gotham Bold",
		"Arial",
		"Roboto",
		"Source Sans",
		"Ubuntu",
	}

	pcall(function()
		if library.GetUIFontNames then
			local uiFontNames = library:GetUIFontNames()

			if type(uiFontNames) == "table" and #uiFontNames > 0 then
				s12_24 = uiFontNames
			end
		end
	end)

	s51_1:AddDropdown("ui_font_name", {
		Text = "font",
		Values = s12_24,
		Default = library.CurrentUIFont or s12_24[1],
		Callback = function(arg)
			pcall(function()
				if library.SetUIFont then
					library:SetUIFont(arg)
				end
			end)
		end,
	})

	themeManager:SetLibrary(library)
	saveManager:SetLibrary(library)
	library.SaveManager = saveManager
	saveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ConfigName", "SaveManager_ConfigList" })
	themeManager:SetFolder("phonkware")
	saveManager:SetFolder("phonkware/rivals")
	saveManager:BuildConfigSection(tbl2["UI Settings"])

	pcall(function()
		for _, option in pairs(options) do
			if type(option) == "table" and option.Type == "KeyPicker" and type(option.SetValue) == "function" then
				local setValue = option.SetValue

				option.SetValue = function(arg, value)
					if type(value) == "table" then
						if value[1] ~= nil then
							arg.Value = value[1]
						end

						if value[2] ~= nil then
							arg.Mode = value[2]
						end
					elseif type(value) == "string" then
						arg.Value = value
					end

					return setValue(arg, value)
				end
			end
		end
	end)

	pcall(function()
		saveManager:LoadAutoloadConfig()
	end)

	pcall(function()
		local function fn7(arg)
			if type(arg) ~= "table" or type(arg.OpenDropdown) ~= "function" or arg._phonk_mobile_patch then
				return
			end
			arg._phonk_mobile_patch = true
			local openDropdown = arg.OpenDropdown
			local closeDropdown = arg.CloseDropdown
			local n2 = 0

			arg.OpenDropdown = function(arg2, ...)
				n2 = os.clock() + 0.4
				local v10 = table.pack(...)
				local v11 = openDropdown
				v10.n = 2 + v10.n - 1
				table.move(v10, 1, v10.n, 2, v10)
				v10[1] = arg2
				local v12 = v11(table.unpack(v10, 1, v10.n))

				pcall(function()
					if arg2.ListOuter then
						arg2.ListOuter.Visible = true
						arg2.ListOuter.ZIndex = math.max(arg2.ListOuter.ZIndex or 20, 100)
					end
				end)

				return v12
			end

			if type(closeDropdown) == "function" then
				arg.CloseDropdown = function(arg2, ...)
					if os.clock() < n2 then
						return
					end
					return closeDropdown(arg2, ...)
				end
			end
		end

		local v10 = pairs
		local tbl4 = options or {}

		for _, v11 in v10(tbl4) do
			if type(v11) == "table" and type(v11.OpenDropdown) == "function" then
				fn7(v11)
			end
		end

		pcall(function()
			if library and library.ScreenGui then
				library.ScreenGui.DisplayOrder = math.max(library.ScreenGui.DisplayOrder or 0, 200)
				library.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
			end
		end)
	end)

	pcall(function()
		local flag2 = toggles and toggles.silent_load_toggle and toggles.silent_load_toggle.Value == true
		getgenv().silent_load = flag2 and true or false

		pcall(function()
			if writefile then
				if isfolder and not isfolder("phonkware") then
					makefolder("phonkware")
				end

				writefile("phonkware/silent_load.txt", flag2 and "1" or "0")
			end
		end)

		if flag2 then
			if v and v.Outer then
				v.Outer.Visible = false
			end

			library.MenuOpen = false
		else
			if v and v.Outer then
				v.Outer.Visible = true
			end

			if not library.MenuOpen then
				pcall(function()
					library:Toggle()
				end)
			end

			task.defer(function()
				if getgenv().silent_load then
					return
				end

				pcall(function()
					if v and v.Outer then
						v.Outer.Visible = true
					end

					if not library.MenuOpen then
						library:Toggle()
					end
				end)
			end)
		end

		if toggles and toggles.mobile_user_toggle and toggles.mobile_user_toggle.Value == true and getgenv().phonk_create_mobile_logo then
			getgenv().phonk_create_mobile_logo()
		end
	end)

	pcall(function()
		local crosshairTextContent = options and options.CrosshairTextContent
		local text

		if crosshairTextContent then
			text = crosshairTextContent.Value or crosshairTextContent.Text
		else
			text = crosshairTextContent
		end

		if type(text) == "string" and string.lower(text) == "elisium" then
			if crosshairTextContent.SetValue then
				crosshairTextContent:SetValue("PhonkWare")
			end

			crosshairTextContent.Value = "PhonkWare"
		end

		if phonk.crosshair and type(phonk.crosshair.text_content) == "string" and string.lower(phonk.crosshair.text_content) == "elisium" then
			phonk.crosshair.text_content = "PhonkWare"
		end

		if not phonk.crosshair.text_content or phonk.crosshair.text_content == "" then
			phonk.crosshair.text_content = "PhonkWare"
		end
	end)

	pcall(function()
		for _, option in pairs(options) do
			if type(option) == "table" and option.Type == "KeyPicker" then
				if option.Mode == "Toggle" or option.Mode == "Hold" then
					option.Toggled = false
				end

				if option.Update then
					pcall(function()
						option:Update()
					end)
				end
			end
		end
	end)

	pcall(function()
		if getgenv().phonk_underground then
			local phonkUnderground = getgenv().phonk_underground
			phonkUnderground.active = false
			phonkUnderground.tp_override = false
			phonkUnderground.saved_pos = nil
		end
	end)
end)()
