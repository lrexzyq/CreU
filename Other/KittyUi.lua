if not LPH_OBFUSCATED then
	LPH_ENCFUNC = function(callback)
		return callback
	end
	LPH_NO_VIRTUALIZE = function(...)
		return ...
	end
	LPH_NO_UPVALUES = function(...)
		return ...
	end
	LPH_JIT_MAX = function(...)
		return ...
	end
	LPH_JIT = function(...)
		return ...
	end
end

local _cloneref = cloneref

local user_input_service = _cloneref(game:GetService('UserInputService'))
local tween_service = _cloneref(game:GetService('TweenService'))
local text_service = _cloneref(game:GetService('TextService'))
local http_service = _cloneref(game:GetService('HttpService'))
local core_gui = _cloneref(game:GetService('CoreGui'))
local debris = _cloneref(game:GetService('Debris'))

local _new_instance = Instance.new
local _new_tween_info = TweenInfo.new
local _new_udim = UDim.new
local _new_udim2 = UDim2.new
local _udim2_from_offset = UDim2.fromOffset
local _new_vector2 = Vector2.new

local _clamp = math.clamp
local _floor = math.floor
local _max = math.max
local _min = math.min

local _clear = table.clear
local _find = table.find
local _freeze = table.freeze
local _insert = table.insert
local _pack = table.pack
local _unpack = table.unpack

local _defer = task.defer
local _delay = task.delay
local _create_tween = tween_service.Create

local _pairs = pairs
local _pcall = pcall
local _tostring = tostring
local _type = type

local create_runtime_lua_key = function(left, right)
	return left .. right .. _tostring(game.GameId):sub(1, 0)
end

local lua_bridge_decryption_key =
	create_runtime_lua_key('ba372df66d4c9d0c2d193367a39ae77a', '56a173213cd71b164be6d19bf8c640d2')
local lua_export_decryption_key =
	create_runtime_lua_key('dc6ca3570f8d9a75a7558f26165b9274', '9565c346b9e4f19d8f7ac2a46ada1ac8')
local lua_sandbox_decryption_key =
	create_runtime_lua_key('aa1143ae1640d00049535f95a227d34d', '986d65cb6c300e7e11d97cfb990fd492')
local lua_loader_decryption_key =
	create_runtime_lua_key('e83f53ad24607d2fd2350345fd2d8265', 'c695310635c212e78fb389573ebf33a0')
local lua_register_decryption_key =
	create_runtime_lua_key('03bd60e589693d30b9f98cde0ac9bc77', '2ccde9534705153de1bf27f8b58c0db4')

local library = {
	_config = {},
	_flags = {},

	_current = nil,
}
library.__index = library

type tab_typeof = {
	_btn: TextButton,
	_left: ScrollingFrame,
	_right: ScrollingFrame,
	_active: boolean,
	_enabled: boolean,
	_title: string,
	_category: string?,
	_manager: any,
}

type runtime_default = {
	_tab: number,
	_tabs: { tab_typeof },
	_tab_registry: { [string]: { any } },
	_categories: { any },
	_category_registry: { [string]: { any } },
	_active_tab: tab_typeof?,
	_layout_order: number,
	_category_order: number,
	_manager_loaded: boolean,
	_type: string?,
	_config: { [string]: any },
	_flags: { [string]: any },
	_active_dropdowns: { any },
	_keybind_entries: { any },
	_keybind_list_visible: boolean,
	_is_mobile: boolean,
	_ui_scale: number,
	_label_text_size: number,
	_small_text_size: number,
	_ui_open: boolean,
	_dragging: boolean,
	_drag_start: Vector2?,
	_container_position: UDim2?,
	_ui: ScreenGui?,
	_container: Frame?,
	_sidebar: Frame?,
	_pin: Frame?,
	_tabs_container: ScrollingFrame?,
	_main_content: Frame?,
	_sections: Folder?,
	_topbar: Frame?,
	_ui_scale_object: UIScale?,
	_keybind_scale: UIScale?,
	_keybind_list_content: Frame?,
	_keybind_list_frame: Frame?,
	_notification_holder: Frame?,
	_notification_scale: UIScale?,
	_notification_order: number,
	_apply_scale: (() -> ())?,
	_lua_manager: any?,
}

type _runtime = typeof(setmetatable({} :: runtime_default, library))
type runtime_typeof = _runtime | typeof(library)

local interface_parent = (gethui and gethui()) or core_gui
local old_interface = interface_parent:FindFirstChild('_kittylol')

if old_interface then
	debris:AddItem(old_interface, 0)
end

local create_new = LPH_NO_VIRTUALIZE(function(class_name, properties)
	local instance = _new_instance(class_name)

	for property, value in properties do
		if property ~= 'Parent' then
			instance[property] = value
		end
	end

	instance.Parent = properties.Parent

	return instance
end)

local create_round = LPH_NO_VIRTUALIZE(function(instance, radius)
	return create_new('UICorner', {
		CornerRadius = _new_udim(0, radius),
		Parent = instance,
	})
end)

local create_pill = LPH_NO_VIRTUALIZE(function(instance)
	return create_new('UICorner', {
		CornerRadius = _new_udim(1, 0),
		Parent = instance,
	})
end)

local create_outline = LPH_NO_VIRTUALIZE(function(instance, refresh)
	local stroke = create_new('UIStroke', {
		Color = Color3.fromRGB(35, 35, 35),
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = instance,
	})

	if refresh then
		instance:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
			stroke.Enabled = false
			stroke.Enabled = true
		end)
	end

	return stroke
end)

local create_vertical_list = LPH_NO_VIRTUALIZE(function(instance, gap)
	return create_new('UIListLayout', {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = _new_udim(0, gap or 0),
		Parent = instance,
	})
end)

local create_padding = LPH_NO_VIRTUALIZE(function(instance, top, bottom, left, right)
	return create_new('UIPadding', {
		PaddingTop = _new_udim(0, top),
		PaddingBottom = _new_udim(0, bottom),
		PaddingLeft = _new_udim(0, left),
		PaddingRight = _new_udim(0, right),
		Parent = instance,
	})
end)

local create_label = LPH_NO_VIRTUALIZE(function(properties)
	properties.BackgroundTransparency = 1
	properties.FontFace =
		Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	properties.TextColor3 = properties.TextColor3 or Color3.fromRGB(180, 180, 180)
	properties.BorderSizePixel = 0

	return create_new('TextLabel', properties)
end)

local create_divider = LPH_NO_VIRTUALIZE(function(parent, position, size)
	return create_new('Frame', {
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		Position = position,
		Size = size,
		BorderSizePixel = 0,
		Parent = parent,
	})
end)

local normalize_name = LPH_NO_VIRTUALIZE(function(value)
	local normalized = string.lower(_tostring(value or ''))
	normalized = string.gsub(normalized, '^%s+', '')

	return string.gsub(normalized, '%s+$', '')
end)

local shallow_copy = LPH_NO_VIRTUALIZE(function(source)
	local copy = {}

	for index, value in source or {} do
		copy[index] = value
	end

	return copy
end)

local read_only = LPH_JIT_MAX(function(source)
	return _freeze(shallow_copy(source))
end)

local round_number = LPH_NO_VIRTUALIZE(function(number, decimals)
	local multiplier = 10 ^ (decimals or 0)

	return _floor(number * multiplier + 0.5 - (number < 0 and 1 or 0)) / multiplier
end)

local lua_internal_callbacks = {}
local lua_internal_exports = {}
local protect_lua_value

local dispatch_lua_internal = LPH_ENCFUNC(function(handle, ...)
	local callback = lua_internal_callbacks[handle]

	if _type(callback) ~= 'function' then
		error('internal function is no longer available', 2)
	end

	local results = _pack(callback(...))

	for index = 1, results.n do
		results[index] = protect_lua_value(results[index])
	end

	return _unpack(results, 1, results.n)
end, 'ba372df66d4c9d0c2d193367a39ae77a56a173213cd71b164be6d19bf8c640d2', lua_bridge_decryption_key)

protect_lua_value = LPH_ENCFUNC(function(value, visited)
	local value_type = _type(value)

	if value_type == 'function' then
		local handle = {}
		lua_internal_callbacks[handle] = value

		return LPH_NO_UPVALUES(function(...)
			return dispatch_lua_internal(handle, ...)
		end)
	end

	if value_type ~= 'table' then
		return value
	end

	visited = visited or {}

	if visited[value] then
		return visited[value]
	end

	local copy = {}
	visited[value] = copy

	for index, child in value do
		copy[protect_lua_value(index, visited)] = protect_lua_value(child, visited)
	end

	_freeze(copy)

	return copy
end, 'dc6ca3570f8d9a75a7558f26165b92749565c346b9e4f19d8f7ac2a46ada1ac8', lua_export_decryption_key)

if not isfolder('Kittylol') then
	makefolder('Kittylol')
end

if not isfolder('Kittylol/configs') then
	makefolder('Kittylol/configs')
end

if not isfolder('Kittylol/assets') then
	makefolder('Kittylol/assets')
end

if not isfolder('Kittylol/luas') then
	makefolder('Kittylol/luas')
end

function library._save(self: runtime_typeof)
	return true
end

function library._disabled_save(self: runtime_typeof)
	if not isfile(`Kittylol/configs/{game.GameId}.json`) then
		writefile(`Kittylol/configs/{game.GameId}.json`, http_service:JSONEncode({}))
	end

	for index, value in _pairs(self._flags) do
		self._config[index] = _type(value) == 'table' and http_service:JSONDecode(http_service:JSONEncode(value))
			or value
	end

	_pcall(function()
		writefile(`Kittylol/configs/{game.GameId}.json`, http_service:JSONEncode(self._config))
	end)
end

function library.load(self: runtime_typeof)
	return self._flags
end

function library.close_all_dropdowns(self: _runtime)
	for _, dropdown in self._active_dropdowns do
		if dropdown._state then
			dropdown:unfold()
		end
	end
end

library._new = function(runtime_type: string?): _runtime
	local is_mobile = user_input_service.TouchEnabled
		or not (user_input_service.KeyboardEnabled and user_input_service.MouseEnabled)
	local self = setmetatable({
		_tab = 0,
		_tabs = {},
		_tab_registry = {},
		_categories = {},
		_category_registry = {},
		_active_tab = nil,
		_layout_order = 0,
		_category_order = 0,
		_manager_loaded = false,
		_type = runtime_type,
		_config = library._config,
		_flags = library._flags,
		_active_dropdowns = {},
		_keybind_entries = {},
		_keybind_list_visible = false,
		_is_mobile = is_mobile,
		_ui_scale = 1,
		_label_text_size = is_mobile and 15 or 14,
		_small_text_size = is_mobile and 11 or 10,
		_ui_open = true,
		_dragging = false,
		_drag_start = nil,
		_container_position = nil,
		_ui = nil,
		_container = nil,
		_sidebar = nil,
		_pin = nil,
		_tabs_container = nil,
		_main_content = nil,
		_sections = nil,
		_topbar = nil,
		_ui_scale_object = nil,
		_keybind_scale = nil,
		_keybind_list_content = nil,
		_keybind_list_frame = nil,
		_notification_holder = nil,
		_notification_scale = nil,
		_notification_order = 0,
		_apply_scale = nil,
		_lua_manager = nil,
	}, library) :: _runtime

	library._current = self

	self:_init()
	self:_init_keybind_list()

	if self._apply_scale then
		self._apply_scale()
	end

	return self
end

function library._init(self: _runtime)
	set_thread_identity(6)

	local _main = create_new('ScreenGui', {
		Name = '_kittylol',
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = interface_parent,
	})

	if syn and syn.protect_gui then
		syn.protect_gui(_main)
	end

	self._ui = _main

	local container = create_new('Frame', {
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		AnchorPoint = _new_vector2(0.5, 0.5),
		Position = _new_udim2(0.5, 0, 0.5, 0),
		Size = _new_udim2(0, 0, 0, 0),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Active = true,
		Parent = _main,
	})

	create_round(container, 8)
	create_outline(container)

	_create_tween(tween_service, container, _new_tween_info(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = _udim2_from_offset(600, 400),
	}):Play()

	local ui_scale = create_new('UIScale', {
		Parent = container,
	})

	self._ui_scale_object = ui_scale

	local notification_holder = create_new('Frame', {
		Name = '_notifications',
		BackgroundTransparency = 1,
		AnchorPoint = _new_vector2(0.5, 1),
		Position = _new_udim2(0.5, 0, 0.5, 178),
		Size = _new_udim2(0, 560, 0, 180),
		BorderSizePixel = 0,
		ZIndex = 199,
		Parent = _main,
	})

	create_new('UIListLayout', {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = _new_udim(0, 6),
		Parent = notification_holder,
	})

	local notification_scale = create_new('UIScale', {
		Scale = self._ui_scale,
		Parent = notification_holder,
	})

	self._notification_holder = notification_holder
	self._notification_scale = notification_scale

	local apply_scale = LPH_NO_VIRTUALIZE(function()
		if self._is_mobile then
			local viewport_size = workspace.CurrentCamera.ViewportSize

			if self._ui and self._ui.AbsoluteSize.Y > 0 then
				viewport_size = self._ui.AbsoluteSize
			end

			local screen_scale = (viewport_size.X / 1400) * 1.4375
			self._ui_scale = _clamp(
				_min(screen_scale, (viewport_size.X * 0.95) / 600, (viewport_size.Y * 0.95) / 400),
				0.503125,
				1.4375
			)
		else
			self._ui_scale = 1
		end

		local scale = self._ui_scale

		ui_scale.Scale = scale

		if self._keybind_scale then
			self._keybind_scale.Scale = scale
		end

		if self._notification_holder and self._notification_scale then
			self._notification_holder.Position = _new_udim2(0.5, 0, 0.5, 178 * scale)
			self._notification_scale.Scale = scale
		end

		_defer(function()
			if self._active_tab and self._pin then
				local button = self._active_tab._btn
				local pin_y = (button.AbsolutePosition.Y - self._sidebar.AbsolutePosition.Y + button.AbsoluteSize.Y / 2)
						/ self._ui_scale
					- 8
				self._pin.Position = _new_udim2(0, 10, 0, pin_y)
			end
		end)
	end)

	self._apply_scale = apply_scale

	apply_scale()

	workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(function()
		_defer(apply_scale)
	end)

	local _toggle_gui = create_new('ScreenGui', {
		Name = '_kittylol_toggle',
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = _main,
	})

	local mobile_toggle = create_new('TextButton', {
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		AnchorPoint = _new_vector2(0, 0),
		Position = _new_udim2(0, 18, 0, 54),
		Size = _new_udim2(0, 44, 0, 44),
		Text = '',
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Visible = true,
		Active = true,
		ZIndex = 100,
		Parent = _toggle_gui,
	})

	create_round(mobile_toggle, 999)
	create_outline(mobile_toggle)

	create_new('ImageLabel', {
		BackgroundTransparency = 1,
		AnchorPoint = _new_vector2(0.5, 0.5),
		Position = _new_udim2(0.5, 0, 0.5, 0),
		Size = _new_udim2(0, 20, 0, 20),
		Image = 'rbxassetid://138939930772180',
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = 101,
		Parent = mobile_toggle,
	})

	local sidebar = create_new('Frame', {
		BackgroundTransparency = 1,
		Size = _new_udim2(0, 160, 1, 0),
		Parent = container,
	})

	create_divider(sidebar, _new_udim2(1, -1, 0, 48), _new_udim2(0, 1, 1, -48))

	local logo_area = create_new('Frame', {
		BackgroundTransparency = 1,
		Size = _new_udim2(1, 0, 0, 48),
		Parent = sidebar,
	})

	create_label({
		Position = _new_udim2(0, (10 + 10), 0, 0),
		Size = _new_udim2(1, -((10 + 10) + 10), 1, 0),
		Text = 'Kittylol',
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = self._is_mobile and 18 or 17,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = logo_area,
	})

	create_divider(logo_area, _new_udim2(0, 0, 1, -1), _new_udim2(1, 0, 0, 1))

	local pin = create_new('Frame', {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = _new_udim2(0, 10, 0, 0),
		Size = _new_udim2(0, 4, 0, 16),
		BorderSizePixel = 0,
		ZIndex = 50,
		Parent = sidebar,
	})

	create_pill(pin)

	local tabs_container = create_new('ScrollingFrame', {
		BackgroundTransparency = 1,
		Position = _new_udim2(0, 0, 0, 48),
		Size = _new_udim2(1, 0, 1, -48),
		CanvasSize = _new_udim2(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0,
		Parent = sidebar,
	})

	tabs_container.ScrollBarThickness = 0
	tabs_container.ScrollBarImageTransparency = 1
	tabs_container.VerticalScrollBarInset = Enum.ScrollBarInset.None
	tabs_container.HorizontalScrollBarInset = Enum.ScrollBarInset.None
	tabs_container.ClipsDescendants = true
	create_padding(tabs_container, 6, 16, 10, 10)
	create_vertical_list(tabs_container, 6)

	tabs_container:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
		if self._active_tab then
			local button = self._active_tab._btn
			local pin_y = (button.AbsolutePosition.Y - self._sidebar.AbsolutePosition.Y + button.AbsoluteSize.Y / 2)
					/ self._ui_scale
				- 8
			pin.Position = _new_udim2(0, 10, 0, pin_y)
		end
	end)

	local main_content = create_new('Frame', {
		BackgroundTransparency = 1,
		Position = _new_udim2(0, 160, 0, 0),
		Size = _new_udim2(0, (600 - 160), 1, 0),
		Parent = container,
	})

	local topbar = create_new('Frame', {
		BackgroundTransparency = 1,
		Size = _new_udim2(1, 0, 0, 48),
		ZIndex = 5,
		Parent = main_content,
	})

	local topbar_divider = create_divider(topbar, _new_udim2(0, 0, 1, -1), _new_udim2(1, 0, 0, 1))
	topbar_divider.ZIndex = 6

	local get_custom_asset = getcustomasset or getsynasset

	if get_custom_asset and self._type == '_limited' then
		_pcall(function()
			local cached = isfile('Kittylol/assets/succubus.png') and readfile('Kittylol/assets/succubus.png') or nil

			if not cached or cached:sub(2, 4) ~= 'PNG' then
				local content =
					game:HttpGet('https://raw.githubusercontent.com/retilin/Kittylol/refs/heads/main/assets/succubus.png')

				if content and content:sub(2, 4) == 'PNG' then
					writefile('Kittylol/assets/succubus.png', content)
				end
			end
		end)

		local logo_loaded, logo_asset = _pcall(function()
			return get_custom_asset('Kittylol/assets/succubus.png')
		end)

		if logo_loaded and logo_asset and logo_asset ~= '' then
			create_new('ImageLabel', {
				BackgroundTransparency = 1,
				AnchorPoint = _new_vector2(1, 0.5),
				Position = _new_udim2(1, -16, 0.5, 0),
				Size = _new_udim2(0, 34, 0, 34),
				Image = logo_asset,
				ImageColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex = 6,
				Parent = topbar,
			})
		end
	end

	local sections_viewport = create_new('Frame', {
		BackgroundTransparency = 1,
		Position = _new_udim2(0, 0, 0, 48),
		Size = _new_udim2(1, 0, 1, -48),
		ClipsDescendants = true,
		Parent = main_content,
	})

	local sections = create_new('Folder', {
		Parent = sections_viewport,
	})

	local input_ended_connection = nil

	local on_drag = LPH_JIT_MAX(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self._dragging = true

			self._drag_start = input.Position
			self._container_position = container.Position

			self:close_all_dropdowns()

			if input_ended_connection then
				input_ended_connection:Disconnect()
				input_ended_connection = nil
			end

			input_ended_connection = input.Changed:Connect(function()
				if input.UserInputState ~= Enum.UserInputState.End then
					return
				end

				if input_ended_connection then
					input_ended_connection:Disconnect()
					input_ended_connection = nil
				end

				self._dragging = false
			end)
		end
	end)

	local drag = LPH_JIT_MAX(function(input)
		if not self._dragging then
			return
		end

		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			local scale = self._ui_scale
			local delta = (input.Position - self._drag_start) / scale

			_create_tween(tween_service, container, _new_tween_info(0.2), {
				Position = (_new_udim2(
					self._container_position.X.Scale,
					self._container_position.X.Offset + delta.X,
					self._container_position.Y.Scale,
					self._container_position.Y.Offset + delta.Y
				)),
			}):Play()
		end
	end)

	container.InputBegan:Connect(on_drag)
	user_input_service.InputChanged:Connect(drag)

	function self:change_visibility(state)
		if state then
			container.Visible = true

			_create_tween(
				tween_service,
				container,
				_new_tween_info(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Size = _udim2_from_offset(600, 400),
				}
			):Play()
		else
			self:close_all_dropdowns()

			_create_tween(
				tween_service,
				container,
				_new_tween_info(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Size = _new_udim2(0, 0, 0, 0),
				}
			):Play()

			_delay(0.5, function()
				if not self._ui_open then
					container.Visible = false
				end
			end)
		end
	end

	user_input_service.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		local minimize_flag = self._flags.minimize
		local minimize_key = Enum.KeyCode.Insert

		if minimize_flag then
			local success, result = _pcall(function()
				return Enum.KeyCode[minimize_flag]
			end)

			if success then
				minimize_key = result
			end
		end

		if input.KeyCode == minimize_key then
			self._ui_open = not self._ui_open

			self:change_visibility(self._ui_open)
		end
	end)

	mobile_toggle.MouseButton1Click:Connect(function()
		self._ui_open = not self._ui_open

		self:change_visibility(self._ui_open)
	end)

	self._container = container
	self._sidebar = sidebar
	self._pin = pin

	self._tabs_container = tabs_container
	self._main_content = main_content
	self._sections = sections
	self._topbar = topbar
end

function library.update_tabs(self: _runtime, tab: tab_typeof)
	for _, tab_data in self._tabs do
		local btn = tab_data._btn

		local tab_icon = btn:FindFirstChildWhichIsA('ImageLabel')
		local tab_label = btn:FindFirstChildWhichIsA('TextLabel')

		if tab_data == tab then
			tab_data._active = true

			_create_tween(tween_service, btn, _new_tween_info(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0,
			}):Play()

			if tab_label then
				_create_tween(
					tween_service,
					tab_label,
					_new_tween_info(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						TextColor3 = Color3.fromRGB(255, 255, 255),
					}
				):Play()
			end

			if tab_icon then
				_create_tween(
					tween_service,
					tab_icon,
					_new_tween_info(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						ImageColor3 = Color3.fromRGB(255, 255, 255),
					}
				):Play()
			end

			local target_y = (btn.AbsolutePosition.Y - self._sidebar.AbsolutePosition.Y + btn.AbsoluteSize.Y / 2)
					/ self._ui_scale
				- 8

			if self._pin.BackgroundTransparency == 1 then
				self._pin.Position = _new_udim2(0, 10, 0, target_y)
				self._pin.BackgroundTransparency = 0
			else
				_create_tween(
					tween_service,
					self._pin,
					_new_tween_info(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Position = _new_udim2(0, 10, 0, target_y),
					}
				):Play()
			end

			continue
		end

		if tab_data._active then
			tab_data._active = false

			_create_tween(tween_service, btn, _new_tween_info(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1,
			}):Play()

			if tab_label then
				_create_tween(
					tween_service,
					tab_label,
					_new_tween_info(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						TextColor3 = Color3.fromRGB(180, 180, 180),
					}
				):Play()
			end

			if tab_icon then
				_create_tween(
					tween_service,
					tab_icon,
					_new_tween_info(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						ImageColor3 = Color3.fromRGB(180, 180, 180),
					}
				):Play()
			end
		end
	end
end

function library.update_sections(self: _runtime, left_section: ScrollingFrame, right_section: ScrollingFrame)
	for _, object in self._sections:GetChildren() do
		if object == left_section or object == right_section then
			object.Visible = true

			continue
		end

		object.Visible = false
	end
end

local function resolve_runtime(self: runtime_typeof): _runtime?
	if self ~= library and _type(self) == 'table' and self._tabs then
		return self :: _runtime
	end

	return library._current
end

function library._find_category(self: runtime_typeof, name: string)
	local runtime = resolve_runtime(self)

	if not runtime then
		return nil
	end

	local matches = runtime._category_registry[normalize_name(name)]

	return matches and matches[1] or nil
end

function library._find_tab(self: runtime_typeof, name: string, category_name: string?)
	local runtime = resolve_runtime(self)

	if not runtime then
		return nil
	end

	local matches = runtime._tab_registry[normalize_name(name)]

	if not matches then
		return nil
	end

	if category_name then
		local normalized_category = normalize_name(category_name)

		for _, tab_manager in matches do
			if normalize_name(tab_manager._category) == normalized_category then
				return tab_manager
			end
		end

		return nil
	end

	return matches[1]
end

function library._find_group(self: runtime_typeof, tab_manager: any, name: string, side: string?)
	if not tab_manager then
		return nil
	end

	local matches = tab_manager._group_registry[normalize_name(name)]

	if not matches then
		return nil
	end

	if side then
		for _, group_manager in matches do
			if group_manager._side == normalize_name(side) then
				return group_manager
			end
		end

		return nil
	end

	if #matches == 1 then
		return matches[1]
	end

	return nil
end

function library.create_category(self: _runtime, name: string)
	local runtime = self

	self._category_order = (self._category_order or 0) + 1
	self._layout_order = 0

	local category_index = self._category_order
	local base_order = category_index * 1000

	local category = create_label({
		Name = name,
		LayoutOrder = base_order,
		Size = _new_udim2(1, 0, 0, category_index == 1 and 19 or 26),
		Text = name:upper(),
		TextSize = runtime._small_text_size + 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Bottom,
		TextTransparency = 0.2,
		Parent = self._tabs_container,
	})

	create_padding(category, 0, 4, 10, 0)

	local category_manager = {
		_label = category,
		_name = name,

		_base_order = base_order,
		_tab_count = 0,
	}

	function category_manager:create_tab(title, icon)
		self._tab_count += 1

		return runtime:create_tab(title, icon, self._base_order + self._tab_count, self._name)
	end

	_insert(self._categories, category_manager)

	local category_name = normalize_name(name)
	self._category_registry[category_name] = self._category_registry[category_name] or {}
	_insert(self._category_registry[category_name], category_manager)

	return category_manager
end

function library.create_tab(self: _runtime, title: string, icon: string | number?, layout_order: number?, category_name: string?)
	local tab_manager = {
		_title = title,
		_category = category_name,
		_groups = {},
		_group_registry = {},
	}
	local runtime = self

	icon = icon or 'rbxassetid://10709812159'
	if _type(icon) == 'number' then
		icon = `rbxassetid://{icon}`
	elseif _type(icon) == 'string' and icon:match('^%d+$') then
		icon = `rbxassetid://{icon}`
	end

	if icon == 'rbxassetid://10709798164' then
		icon = 'rbxassetid://10709812159'
	end

	if not layout_order then
		self._layout_order += 1
		layout_order = self._category_order * 1000 + self._layout_order
	end

	local first_tab = #self._tabs == 0

	local tab_button = create_new('TextButton', {
		Name = title,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 1,
		LayoutOrder = layout_order,
		Size = _new_udim2(1, 0, 0, 32),
		Text = '',
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = self._tabs_container,
	})

	create_round(tab_button, 6)

	create_new('ImageLabel', {
		BackgroundTransparency = 1,
		AnchorPoint = _new_vector2(0, 0.5),
		Position = _new_udim2(0, 10, 0.5, 0),
		Size = _new_udim2(0, 16, 0, 16),
		Image = icon,
		ImageColor3 = Color3.fromRGB(180, 180, 180),
		Parent = tab_button,
	})

	create_label({
		Position = _new_udim2(0, (10 + 16 + 8), 0, 0),
		Size = _new_udim2(1, -((10 + 16 + 8) + 10), 1, 0),
		Text = title,
		TextSize = runtime._label_text_size,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = tab_button,
	})

	local function create_section(column_x)
		local section = create_new('ScrollingFrame', {
			BackgroundTransparency = 1,
			Position = _new_udim2(0, column_x - 2, 0, 0),
			Size = _new_udim2(0, ((600 - 160 - 16 * 2 - 12) / 2) + 4, 1, 0),
			CanvasSize = _new_udim2(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
			Visible = false,
			Parent = self._sections,
		})

		section.ScrollBarThickness = 0
		section.ScrollBarImageTransparency = 1
		section.VerticalScrollBarInset = Enum.ScrollBarInset.None
		section.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		section.ClipsDescendants = true
		create_padding(section, 16, 16, 2, 2)
		create_vertical_list(section, 12)

		return section
	end

	local left_section = create_section(16)
	local right_section = create_section(16 + ((600 - 160 - 16 * 2 - 12) / 2) + 12)

	local tab_data = {
		_btn = tab_button,
		_left = left_section,
		_right = right_section,

		_active = false,
		_enabled = true,
		_title = title,
		_category = category_name,
		_manager = tab_manager,
	}

	tab_manager._data = tab_data

	_insert(self._tabs, tab_data)

	self._tab += 1

	if first_tab then
		self:update_tabs(tab_data)
		self:update_sections(left_section, right_section)

		self._active_tab = tab_data
	end

	tab_button.MouseButton1Click:Connect(function()
		if not tab_data._enabled then
			return
		end

		self._active_tab = tab_data

		self:update_tabs(tab_data)
		self:update_sections(left_section, right_section)
	end)

	function tab_manager:set_enabled(state)
		local enabled = state == true

		tab_data._enabled = enabled
		tab_button.Active = enabled
		tab_button.Selectable = enabled

		local tab_icon = tab_button:FindFirstChildWhichIsA('ImageLabel')
		local tab_label = tab_button:FindFirstChildWhichIsA('TextLabel')

		if tab_icon then
			tab_icon.ImageTransparency = enabled and 0 or 0.65
		end

		if tab_label then
			tab_label.TextTransparency = enabled and 0 or 0.65
		end

		if not enabled and runtime._active_tab == tab_data then
			for _, candidate in runtime._tabs do
				if candidate ~= tab_data and candidate._enabled then
					runtime._active_tab = candidate
					runtime:update_tabs(candidate)
					runtime:update_sections(candidate._left, candidate._right)

					break
				end
			end
		end
	end

	function tab_manager:is_enabled()
		return tab_data._enabled
	end

	function tab_manager:create_group(title, side)
		local group_values = {}

		if _type(title) == 'table' then
			group_values = title
		else
			group_values.title = title
			group_values.side = side
		end

		group_values.title = group_values.title or 'group'
		group_values.side = (group_values.side == 'right') and 'right' or 'left'

		local group_manager = {
			_size = 0,
			_order = 0,
			_title = group_values.title,
			_side = group_values.side,
			_tab = tab_manager,
		}

		local function next_row_order()
			group_manager._order += 1

			return group_manager._order
		end

		local group_frame = create_new('Frame', {
			BackgroundColor3 = Color3.fromRGB(22, 22, 22),
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = _new_udim2(1, 0, 0, 0),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Parent = (group_values.side == 'left' and left_section or right_section),
		})

		group_manager._frame = group_frame

		create_round(group_frame, 8)
		create_outline(group_frame, true)
		create_padding(group_frame, 12, 12, 12, 12)
		create_vertical_list(group_frame, 8)

		create_label({
			LayoutOrder = 0,
			Size = _new_udim2(1, 0, 0, 12),
			Text = _tostring(group_values.title):upper(),
			TextSize = runtime._small_text_size + 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 0.2,
			Parent = group_frame,
		})

		function group_manager:create_toggle(flag, _values)
			if _type(flag) == 'table' then
				_values = flag
				flag = _values.flag
			end

			local state = _values.default or _values.Default or false

			local toggle_frame = create_new('Frame', {
				BackgroundTransparency = 1,
				LayoutOrder = next_row_order(),
				Size = _new_udim2(1, 0, 0, 24),
				Parent = group_frame,
			})

			local toggle_label = create_label({
				Size = _new_udim2(1, -(30 + 10), 1, 0),
				Text = _values.title,
				TextSize = runtime._label_text_size,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = toggle_frame,
			})

			local switch_background = create_new('Frame', {
				BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				AnchorPoint = _new_vector2(1, 0.5),
				Position = _new_udim2(1, 0, 0.5, 0),
				Size = _new_udim2(0, 30, 0, 18),
				BorderSizePixel = 0,
				Parent = toggle_frame,
			})

			create_pill(switch_background)

			local knob_inset = (18 - 12) / 2
			local knob_off = _new_udim2(0, knob_inset, 0.5, 0)
			local knob_on = _new_udim2(0, 30 - 12 - knob_inset, 0.5, 0)

			local switch_knob = create_new('Frame', {
				BackgroundColor3 = Color3.fromRGB(180, 180, 180),
				AnchorPoint = _new_vector2(0, 0.5),
				Position = knob_off,
				Size = _new_udim2(0, 12, 0, 12),
				BorderSizePixel = 0,
				Parent = switch_background,
			})

			create_pill(switch_knob)

			local toggle_tween_info = _new_tween_info(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			local toggle_tweens = {}

			local cancel_toggle_tweens = LPH_NO_VIRTUALIZE(function()
				for _, tween in toggle_tweens do
					tween:Cancel()
				end

				_clear(toggle_tweens)
			end)

			local play_toggle_tween = LPH_NO_VIRTUALIZE(function(instance, properties)
				local tween = _create_tween(tween_service, instance, toggle_tween_info, properties)
				_insert(toggle_tweens, tween)

				tween:Play()
			end)

			local apply_toggle = LPH_JIT_MAX(function(animate)
				local bg_color = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)
				local knob_color = state and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(180, 180, 180)
				local knob_pos = state and knob_on or knob_off
				local label_color = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)

				cancel_toggle_tweens()

				if animate then
					play_toggle_tween(switch_background, { BackgroundColor3 = bg_color })
					play_toggle_tween(switch_knob, { Position = knob_pos, BackgroundColor3 = knob_color })
					play_toggle_tween(toggle_label, { TextColor3 = label_color })
				else
					switch_background.BackgroundColor3 = bg_color
					switch_knob.Position = knob_pos

					switch_knob.BackgroundColor3 = knob_color
					toggle_label.TextColor3 = label_color
				end
			end)

			local set_toggle = LPH_JIT_MAX(function(value, animate)
				state = value

				apply_toggle(animate)

				runtime._flags[flag] = state
				runtime:_save()

				if _values.callback then
					_values.callback(state)
				end

				if _values.is_keybind then
					runtime:update_keybind_list()
				end
			end)

			local click_button = create_new('TextButton', {
				BackgroundTransparency = 1,
				Size = _new_udim2(1, 0, 1, 0),
				Text = '',
				Parent = toggle_frame,
			})

			if _values.is_keybind and not runtime._is_mobile then
				local bind_text_size = runtime._label_text_size
				local bind_right = 30 + 4

				toggle_label.Size = _new_udim2(1, -(bind_right + 24 + 8), 1, 0)

				local bind_button = create_new('TextButton', {
					BackgroundColor3 = Color3.fromRGB(40, 40, 40),
					AnchorPoint = _new_vector2(1, 0.5),
					Position = _new_udim2(1, -bind_right, 0.5, 0),
					Size = _new_udim2(0, 24, 0, 22),
					Text = '',
					AutoButtonColor = false,
					BorderSizePixel = 0,
					ZIndex = 2,
					Parent = toggle_frame,
				})

				create_round(bind_button, 6)

				local bind_icon = create_new('ImageLabel', {
					BackgroundTransparency = 1,
					AnchorPoint = _new_vector2(0.5, 0.5),
					Position = _new_udim2(0.5, 0, 0.5, 0),
					Size = _new_udim2(0, 14, 0, 14),
					Image = 'rbxassetid://10709818996',
					ImageColor3 = Color3.fromRGB(180, 180, 180),
					Parent = bind_button,
				})

				local bind_text = create_label({
					Size = _new_udim2(1, 0, 1, 0),
					Text = '',
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = bind_text_size,
					Visible = false,
					Parent = bind_button,
				})

				local fit_bind_button = LPH_NO_VIRTUALIZE(function(key_name)
					local text_width = text_service:GetTextSize(
						key_name,
						bind_text_size,
						Enum.Font.GothamSemibold,
						_new_vector2(1000, 22)
					).X
					local bind_width = _max(24, text_width + 12)

					bind_button.Size = _new_udim2(0, bind_width, 0, 22)
					toggle_label.Size = _new_udim2(1, -(bind_right + bind_width + 8), 1, 0)
				end)

				local bind_flag = `{flag}_key`

				local key = nil
				local picking = false

				if runtime._flags[bind_flag] ~= nil then
					local success, result = _pcall(function()
						return Enum.KeyCode[runtime._flags[bind_flag]]
					end)

					if success then
						key = result

						bind_icon.Visible = false
						bind_text.Visible = true
						bind_text.Text = key.Name

						fit_bind_button(key.Name)
					end
				end

				bind_button.MouseButton1Click:Connect(function()
					picking = true
					bind_icon.Visible = false
					bind_text.Visible = true
					bind_text.Text = '...'
					bind_button.Size = _new_udim2(0, 24, 0, 22)
					toggle_label.Size = _new_udim2(1, -(bind_right + 24 + 8), 1, 0)

					_create_tween(tween_service, bind_button, _new_tween_info(0.2), {
						BackgroundColor3 = Color3.fromRGB(45, 45, 45),
					}):Play()
				end)

				user_input_service.InputBegan:Connect(function(input, processed)
					if picking then
						if input.UserInputType == Enum.UserInputType.Keyboard then
							key = input.KeyCode

							bind_text.Text = key.Name
							picking = false

							fit_bind_button(key.Name)

							_create_tween(tween_service, bind_button, _new_tween_info(0.2), {
								BackgroundColor3 = Color3.fromRGB(40, 40, 40),
							}):Play()

							runtime._flags[bind_flag] = key.Name
							runtime:_save()

							for _, entry in runtime._keybind_entries do
								if entry.flag == flag then
									entry.key_name = key.Name

									break
								end
							end

							runtime:update_keybind_list()
						end
					elseif not processed and key and input.KeyCode == key then
						set_toggle(not state, true)
					end
				end)
			end

			if runtime._flags[flag] ~= nil then
				state = runtime._flags[flag]
			end

			apply_toggle(false)

			if _values.is_keybind and not runtime._is_mobile then
				local bind_flag = `{flag}_key`
				local initial_key_name = nil

				if runtime._flags[bind_flag] ~= nil then
					local success, result = _pcall(function()
						return Enum.KeyCode[runtime._flags[bind_flag]]
					end)

					if success then
						initial_key_name = result.Name
					end
				end

				_insert(runtime._keybind_entries, {
					flag = flag,
					title = _values.title,
					key_name = initial_key_name,
				})

				runtime:update_keybind_list()
			end

			click_button.MouseButton1Click:Connect(function()
				set_toggle(not state, true)
			end)
		end

		function group_manager:create_slider(flag, _values)
			if _type(flag) == 'table' then
				_values = flag
				flag = _values.flag
			end

			local default = _values.default

			if runtime._flags[flag] ~= nil then
				default = runtime._flags[flag]
			end

			local value = default

			local slider_frame = create_new('Frame', {
				BackgroundTransparency = 1,
				LayoutOrder = next_row_order(),
				Size = _new_udim2(1, 0, 0, 30),
				Parent = group_frame,
			})

			create_label({
				Size = _new_udim2(1, -56, 0, 16),
				Text = _values.title,
				TextSize = runtime._label_text_size,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = slider_frame,
			})

			local value_label = create_label({
				AnchorPoint = _new_vector2(1, 0),
				Position = _new_udim2(1, 0, 0, 0),
				Size = _new_udim2(0, 48, 0, 16),
				Text = _tostring(default),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = runtime._label_text_size,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = slider_frame,
			})

			local track_button = create_new('TextButton', {
				BackgroundTransparency = 1,
				Position = _new_udim2(0, 0, 0, 16),
				Size = _new_udim2(1, 0, 1, -16),
				Text = '',
				AutoButtonColor = false,
				BorderSizePixel = 0,
				Parent = slider_frame,
			})

			local track_background = create_new('Frame', {
				BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				AnchorPoint = _new_vector2(0, 0.5),
				Position = _new_udim2(0, 0, 0.5, 0),
				Size = _new_udim2(1, 0, 0, 6),
				BorderSizePixel = 0,
				Parent = track_button,
			})

			create_pill(track_background)

			local track_fill = create_new('Frame', {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Size = _new_udim2(
					(_clamp((value - _values.minimum) / (_values.maximum - _values.minimum), 0, 1)),
					0,
					1,
					0
				),
				BorderSizePixel = 0,
				Parent = track_background,
			})

			create_pill(track_fill)

			local knob = create_new('Frame', {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				AnchorPoint = _new_vector2(0.5, 0.5),
				Position = _new_udim2(1, 0, 0.5, 0),
				Size = _new_udim2(0, 12, 0, 12),
				BorderSizePixel = 0,
				Parent = track_fill,
			})

			create_pill(knob)

			local slider_dragging = false

			local update_slider = LPH_JIT_MAX(function(input)
				local position = _clamp(
					(input.Position.X - track_background.AbsolutePosition.X) / track_background.AbsoluteSize.X,
					0,
					1
				)
				local raw_value = _values.minimum + ((_values.maximum - _values.minimum) * position)

				value = round_number(raw_value, _values.rounding and 1 or 0)

				value_label.Text = _tostring(value)

				_create_tween(tween_service, track_fill, _new_tween_info(0.1), {
					Size = _new_udim2(position, 0, 1, 0),
				}):Play()

				runtime._flags[flag] = value
				runtime:_save()

				if _values.callback then
					_values.callback(value)
				end
			end)

			track_button.InputBegan:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					slider_dragging = true

					update_slider(input)
				end
			end)

			user_input_service.InputEnded:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					slider_dragging = false
				end
			end)

			user_input_service.InputChanged:Connect(function(input)
				if
					slider_dragging
					and (
						input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
					)
				then
					update_slider(input)
				end
			end)
		end

		function group_manager:create_button(flag, _values)
			if _type(flag) == 'table' then
				_values = flag
			end

			local button = create_new('TextButton', {
				BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				LayoutOrder = next_row_order(),
				Size = _new_udim2(1, 0, 0, 26),
				FontFace = Font.new(
					'rbxasset://fonts/families/GothamSSm.json',
					Enum.FontWeight.SemiBold,
					Enum.FontStyle.Normal
				),
				Text = _values.title,
				TextColor3 = Color3.fromRGB(180, 180, 180),
				TextSize = runtime._label_text_size,
				AutoButtonColor = false,
				BorderSizePixel = 0,
				Parent = group_frame,
			})

			create_round(button, 6)

			button.MouseButton1Click:Connect(function()
				button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

				_create_tween(tween_service, button, _new_tween_info(0.2), {
					BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				}):Play()

				_values.callback()
			end)
		end

		function group_manager:create_textbox(flag, _values)
			if _type(flag) == 'table' then
				_values = flag
				flag = _values.flag
			end

			_values = _values or {}

			local box_height = _max(24, tonumber(_values.height) or 56)
			local raw_value = _tostring(_values.default or '')
			local textbox_frame = create_new('Frame', {
				BackgroundTransparency = 1,
				LayoutOrder = next_row_order(),
				Size = _new_udim2(1, 0, 0, box_height + 20),
				Visible = _values.visible ~= false,
				Parent = group_frame,
			})

			create_label({
				Size = _new_udim2(1, 0, 0, 16),
				Text = _values.title or 'Text',
				TextSize = runtime._label_text_size,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = textbox_frame,
			})

			local textbox = create_new('TextBox', {
				BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				Position = _new_udim2(0, 0, 0, 20),
				Size = _new_udim2(1, 0, 0, box_height),
				ClearTextOnFocus = false,
				MultiLine = _values.multi_line ~= false,
				PlaceholderText = _values.placeholder or '',
				PlaceholderColor3 = Color3.fromRGB(180, 180, 180),
				Text = raw_value,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = _values.compact and runtime._label_text_size or runtime._small_text_size,
				TextTransparency = 0.1,
				TextWrapped = false,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = _values.compact and Enum.TextYAlignment.Center or Enum.TextYAlignment.Top,
				FontFace = Font.new(
					'rbxasset://fonts/families/GothamSSm.json',
					Enum.FontWeight.SemiBold,
					Enum.FontStyle.Normal
				),
				BorderSizePixel = 0,
				Parent = textbox_frame,
			})

			create_round(textbox, 6)
			create_padding(textbox, 0, 0, 10, 10)

			local changing_text = false
			local rendered_value = raw_value

			local render_value = LPH_NO_VIRTUALIZE(function()
				local displayed_value = raw_value

				if _values.display then
					local display_success, transformed = _pcall(_values.display, raw_value)

					if display_success and transformed ~= nil then
						displayed_value = _tostring(transformed)
					end
				end

				rendered_value = displayed_value
				changing_text = true
				textbox.Text = displayed_value
				changing_text = false
			end)

			textbox:GetPropertyChangedSignal('Text'):Connect(function()
				if changing_text or textbox.Text == rendered_value then
					return
				end

				raw_value = textbox.Text
				render_value()
			end)

			render_value()

			textbox.FocusLost:Connect(function(enter_pressed)
				if flag then
					runtime._flags[flag] = raw_value
					runtime:_save()
				end

				if _values.callback then
					_values.callback(raw_value, enter_pressed)
				end
			end)

			local textbox_manager = {}

			function textbox_manager:get_value()
				return raw_value
			end

			function textbox_manager:get_display_value()
				return textbox.Text
			end

			function textbox_manager:set_value(value)
				raw_value = _tostring(value or '')
				render_value()
			end

			function textbox_manager:clear()
				self:set_value('')
			end

			function textbox_manager:focus()
				textbox:CaptureFocus()
			end

			function textbox_manager:set_visible(state)
				textbox_frame.Visible = state == true
			end

			function textbox_manager:is_visible()
				return textbox_frame.Visible
			end

			return textbox_manager
		end

		function group_manager:create_dropdown(flag, _values)
			if _type(flag) == 'table' then
				_values = flag
				flag = _values.flag
			end

			_values = _values or {}
			_values.options = _values.options or {}

			local is_multi = _values.multi_dropdown or _values.multi or false
			local hide_selected_option = _values.hide_selected_option == true and not is_multi
			local dropdown_manager = {
				_state = false,
				_locked_open = false,
				_size = 0,
				_content_height = 0,
				_options = {},
				_option_buttons = {},
				_selected = {},
			}

			local default = _values.default or (is_multi and {} or _values.options[1])

			if flag and runtime._flags[flag] ~= nil then
				default = runtime._flags[flag]
			end

			if is_multi and _type(default) == 'table' then
				for _index, value in _pairs(default) do
					if _type(_index) == 'string' and value == true then
						dropdown_manager._selected[_index] = true
					elseif _type(value) == 'string' then
						dropdown_manager._selected[value] = true
					end
				end
			end

			local dropdown_frame = create_new('Frame', {
				BackgroundTransparency = 1,
				LayoutOrder = next_row_order(),
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = _new_udim2(1, 0, 0, 0),
				ClipsDescendants = true,
				Parent = group_frame,
			})

			create_vertical_list(dropdown_frame, 4)

			create_label({
				LayoutOrder = 0,
				Size = _new_udim2(1, 0, 0, 16),
				Text = _values.title,
				TextSize = runtime._label_text_size,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = dropdown_frame,
			})

			local select_box = create_new('Frame', {
				BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				LayoutOrder = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = _new_udim2(1, 0, 0, 0),
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Parent = dropdown_frame,
			})

			create_round(select_box, 6)
			create_vertical_list(select_box)

			local header = create_new('Frame', {
				BackgroundTransparency = 1,
				LayoutOrder = 0,
				Size = _new_udim2(1, 0, 0, 24),
				Parent = select_box,
			})

			local selected_text = create_label({
				Position = _new_udim2(0, 10, 0, 0),
				Size = _new_udim2(1, _values.hide_icon and -20 or -32, 1, 0),
				Text = '',
				TextSize = runtime._label_text_size,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = header,
			})

			create_new('UIGradient', {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.7, 0),
					NumberSequenceKeypoint.new(0.9, 0.5),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Parent = selected_text,
			})

			if not _values.hide_icon then
				create_new('ImageLabel', {
					BackgroundTransparency = 1,
					AnchorPoint = _new_vector2(1, 0.5),
					Position = _new_udim2(1, -10, 0.5, 0),
					Size = _new_udim2(0, 12, 0, 12),
					Image = 'rbxassetid://10734899821',
					ImageColor3 = Color3.fromRGB(180, 180, 180),
					Parent = header,
				})
			end

			local options_list = create_new('ScrollingFrame', {
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Size = _new_udim2(1, 0, 0, 0),
				CanvasSize = _new_udim2(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				BorderSizePixel = 0,
				Parent = select_box,
			})

			options_list.ScrollBarThickness = 0
			options_list.ScrollBarImageTransparency = 1
			options_list.VerticalScrollBarInset = Enum.ScrollBarInset.None
			options_list.HorizontalScrollBarInset = Enum.ScrollBarInset.None
			options_list.ClipsDescendants = true
			create_vertical_list(options_list)

			local update_size = LPH_NO_VIRTUALIZE(function()
				local visible_options = 0

				for _, option in dropdown_manager._options do
					if not hide_selected_option or option ~= default then
						visible_options += 1
					end
				end

				local content_height = visible_options * 24

				dropdown_manager._content_height = content_height
				dropdown_manager._size = _min(content_height, 5 * 24)

				if dropdown_manager._state then
					options_list.Size = _new_udim2(1, 0, 0, dropdown_manager._size)
				end
			end)

			local update_selected_text = LPH_NO_VIRTUALIZE(function()
				if not is_multi then
					selected_text.Text = _tostring(default or _values.empty_text or 'None')
					selected_text.TextColor3 = default and Color3.fromRGB(255, 255, 255)
						or Color3.fromRGB(180, 180, 180)
					selected_text.TextTransparency = default and 0.2 or 0

					return
				end

				local selected = ''

				for option, value in _pairs(dropdown_manager._selected) do
					if value then
						selected = selected .. option .. ', '
					end
				end

				selected_text.Text = selected == '' and 'None' or selected:sub(1, -3)
			end)

			local update_option_labels = LPH_NO_VIRTUALIZE(function()
				for _, child in options_list:GetChildren() do
					if child:IsA('TextButton') then
						local option_label = child:FindFirstChildWhichIsA('TextLabel')

						if option_label then
							local selected = is_multi and dropdown_manager._selected[option_label.Text]
								or option_label.Text == default

							child.Visible = not hide_selected_option or not selected
							option_label.TextColor3 = selected and Color3.fromRGB(255, 255, 255)
								or Color3.fromRGB(180, 180, 180)
							option_label.TextTransparency = selected and 0.2 or 0.5
						end
					end
				end

				update_size()
			end)

			local save_selection = LPH_JIT(function(value)
				if flag then
					runtime._flags[flag] = value
					runtime:_save()
				end

				if _values.callback then
					_values.callback(value)
				end
			end)

			local select_option = LPH_JIT_MAX(function(object)
				if is_multi then
					dropdown_manager._selected[object] = not dropdown_manager._selected[object]

					local selected = {}

					for option, value in _pairs(dropdown_manager._selected) do
						if value then
							selected[option] = true
						end
					end

					update_selected_text()
					update_option_labels()
					save_selection(selected)

					return
				end

				default = object

				update_selected_text()
				update_option_labels()
				dropdown_manager:unfold(false)
				save_selection(object)
			end)

			local add_option = LPH_NO_VIRTUALIZE(function(object)
				object = _tostring(object)

				if _find(dropdown_manager._options, object) then
					return
				end

				_insert(dropdown_manager._options, object)

				local option_button = create_new('TextButton', {
					BackgroundTransparency = 1,
					LayoutOrder = #dropdown_manager._options,
					Size = _new_udim2(1, 0, 0, 24),
					Text = '',
					Visible = not hide_selected_option or object ~= default,
					AutoButtonColor = false,
					Parent = options_list,
				})
				dropdown_manager._option_buttons[object] = option_button

				local selected = is_multi and dropdown_manager._selected[object] or object == default
				local option_label = create_label({
					Position = _new_udim2(0, 10, 0, 0),
					Size = _new_udim2(1, -20, 1, 0),
					Text = object,
					TextColor3 = selected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180),
					TextSize = runtime._label_text_size,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextTransparency = selected and 0.2 or 0.5,
					Parent = option_button,
				})

				option_button.MouseEnter:Connect(function()
					_create_tween(tween_service, option_label, _new_tween_info(0.2), {
						TextTransparency = 0,
					}):Play()
				end)

				option_button.MouseLeave:Connect(function()
					local current_selected = is_multi and dropdown_manager._selected[object] or object == default

					_create_tween(tween_service, option_label, _new_tween_info(0.2), {
						TextTransparency = current_selected and 0.2 or 0.5,
					}):Play()
				end)

				option_button.MouseButton1Click:Connect(function()
					select_option(object)
				end)

				update_size()
			end)

			function dropdown_manager:set_options(options, selected)
				for _, child in options_list:GetChildren() do
					if child:IsA('TextButton') then
						child:Destroy()
					end
				end

				_clear(self._options)
				_clear(self._option_buttons)

				for _, option in options or {} do
					add_option(option)
				end

				if is_multi then
					_clear(self._selected)

					if _type(selected) == 'table' then
						for index, value in _pairs(selected) do
							if _type(index) == 'string' and value == true then
								self._selected[index] = true
							elseif _type(value) == 'string' then
								self._selected[value] = true
							end
						end
					end
				else
					if selected and _find(self._options, _tostring(selected)) then
						default = _tostring(selected)
					elseif not _find(self._options, default) then
						default = self._options[1]
					end
				end

				update_size()
				update_selected_text()
				update_option_labels()
			end

			function dropdown_manager:add_option(option, select_added)
				add_option(option)

				if select_added then
					self:set_value(option, true)
				end
			end

			function dropdown_manager:set_value(value, silent)
				if is_multi then
					_clear(self._selected)

					if _type(value) == 'table' then
						for index, selected in _pairs(value) do
							if _type(index) == 'string' and selected == true then
								self._selected[index] = true
							elseif _type(selected) == 'string' then
								self._selected[selected] = true
							end
						end
					end

					update_selected_text()
					update_option_labels()

					if not silent then
						save_selection(shallow_copy(self._selected))
					end

					return
				end

				value = _tostring(value)

				if not _find(self._options, value) then
					return false
				end

				default = value
				update_selected_text()
				update_option_labels()

				if not silent then
					save_selection(value)
				end

				return true
			end

			function dropdown_manager:get_value()
				return is_multi and shallow_copy(self._selected) or default
			end

			function dropdown_manager:unfold(force_state)
				local opening = force_state

				if opening == nil then
					opening = not self._state
				end

				if self._locked_open and not opening then
					return
				end

				if opening == self._state then
					return
				end

				if opening then
					for _, dropdown in runtime._active_dropdowns do
						if dropdown ~= self and dropdown._state then
							dropdown:unfold(false)
						end
					end
				end

				self._state = opening

				if self._state then
					options_list.CanvasPosition = _new_vector2(0, 0)

					_create_tween(
						tween_service,
						options_list,
						_new_tween_info(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Size = _new_udim2(1, 0, 0, self._size),
						}
					):Play()
				else
					_create_tween(
						tween_service,
						options_list,
						_new_tween_info(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Size = _new_udim2(1, 0, 0, 0),
						}
					):Play()

					_delay(0.5, function()
						if not self._state then
							options_list.CanvasPosition = _new_vector2(0, 0)
						end
					end)
				end
			end

			function dropdown_manager:set_locked_open(state)
				self._locked_open = state == true

				if self._locked_open then
					self:unfold(true)
				end
			end

			local header_button = create_new('TextButton', {
				BackgroundTransparency = 1,
				Size = _new_udim2(1, 0, 1, 0),
				Text = '',
				ZIndex = 10,
				Parent = header,
			})

			header_button.MouseButton1Click:Connect(function()
				dropdown_manager:unfold()
			end)

			for _, option in _values.options do
				add_option(option)
			end

			update_selected_text()
			update_option_labels()

			_insert(runtime._active_dropdowns, dropdown_manager)

			return dropdown_manager
		end

		function group_manager:create_keybind(flag, _values)
			if _type(flag) == 'table' then
				_values = flag
				flag = _values.flag
			end

			local default = _values.default or Enum.KeyCode.E

			if runtime._flags[flag] ~= nil then
				local success, result = _pcall(function()
					return Enum.KeyCode[runtime._flags[flag]]
				end)

				if success then
					default = result
				end
			end

			local key = default
			local picking = false

			local keybind_frame = create_new('Frame', {
				BackgroundTransparency = 1,
				LayoutOrder = next_row_order(),
				Size = _new_udim2(1, 0, 0, 24),
				Parent = group_frame,
			})

			create_label({
				Size = _new_udim2(0.5, 0, 1, 0),
				Text = _values.title,
				TextSize = runtime._label_text_size,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = keybind_frame,
			})

			local bind_button = create_new('TextButton', {
				BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				AnchorPoint = _new_vector2(1, 0.5),
				Position = _new_udim2(1, 0, 0.5, 0),
				Size = _new_udim2(0, 36, 0, 22),
				AutomaticSize = Enum.AutomaticSize.X,
				FontFace = Font.new(
					'rbxasset://fonts/families/GothamSSm.json',
					Enum.FontWeight.SemiBold,
					Enum.FontStyle.Normal
				),
				Text = key.Name,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = runtime._label_text_size,
				AutoButtonColor = false,
				BorderSizePixel = 0,
				Parent = keybind_frame,
			})

			create_round(bind_button, 6)
			create_padding(bind_button, 0, 0, 8, 8)

			bind_button.MouseButton1Click:Connect(function()
				picking = true
				bind_button.Text = '...'

				_create_tween(tween_service, bind_button, _new_tween_info(0.2), {
					BackgroundColor3 = Color3.fromRGB(45, 45, 45),
				}):Play()
			end)

			user_input_service.InputBegan:Connect(function(input, processed)
				if picking then
					if input.UserInputType == Enum.UserInputType.Keyboard then
						key = input.KeyCode

						bind_button.Text = key.Name
						picking = false

						_create_tween(tween_service, bind_button, _new_tween_info(0.2), {
							BackgroundColor3 = Color3.fromRGB(40, 40, 40),
						}):Play()

						runtime._flags[flag] = key.Name
						runtime:_save()
					end
				elseif not processed and input.KeyCode == key then
					if _values.callback then
						_values.callback()
					end
				end
			end)
		end

		_insert(tab_manager._groups, group_manager)

		local group_name = normalize_name(group_values.title)
		tab_manager._group_registry[group_name] = tab_manager._group_registry[group_name] or {}
		_insert(tab_manager._group_registry[group_name], group_manager)

		return group_manager
	end

	local tab_name = normalize_name(title)
	self._tab_registry[tab_name] = self._tab_registry[tab_name] or {}
	_insert(self._tab_registry[tab_name], tab_manager)

	return tab_manager
end

function library.update_keybind_list(self: _runtime)
	if not self._keybind_list_content or not self._keybind_list_frame then
		return
	end

	for _, child in self._keybind_list_content:GetChildren() do
		if child:IsA('Frame') then
			child:Destroy()
		end
	end

	local has_any = false

	for _, entry in self._keybind_entries do
		if entry.key_name and entry.key_name ~= '' then
			has_any = true

			local row = create_new('Frame', {
				BackgroundTransparency = 1,
				Size = _new_udim2(1, 0, 0, 24),
				Parent = self._keybind_list_content,
			})

			local is_enabled = self._flags[entry.flag]
			local display_text = `[ {entry.key_name} ]`
			local text_color = is_enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)

			local info_width = text_service:GetTextSize(
				display_text,
				14,
				Enum.Font.GothamSemibold,
				_new_vector2(1000, 24)
			).X + 4

			create_label({
				Size = _new_udim2(1, -(info_width + 10), 1, 0),
				Text = entry.title,
				TextColor3 = text_color,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = row,
			})

			create_label({
				AnchorPoint = _new_vector2(1, 0.5),
				Position = _new_udim2(1, 0, 0.5, 0),
				Size = _new_udim2(0, info_width, 0, 18),
				Text = display_text,
				TextColor3 = text_color,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = row,
			})
		end
	end

	if self._keybind_list_visible and has_any then
		self._keybind_list_frame.Visible = true
	else
		self._keybind_list_frame.Visible = false
	end
end

function library._init_keybind_list(self: _runtime)
	local keybind_list = create_new('Frame', {
		Name = '_keybind_list',
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		Position = _new_udim2(0, 16, 0.2, 0),
		Size = _new_udim2(0, 250, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false,
		Active = true,
		Parent = self._ui,
	})

	local keybind_scale = create_new('UIScale', {
		Scale = self._ui_scale,
		Parent = keybind_list,
	})

	self._keybind_scale = keybind_scale

	create_round(keybind_list, 4)
	create_outline(keybind_list, true)
	create_vertical_list(keybind_list)

	local keybind_list_header = create_new('Frame', {
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		Size = _new_udim2(1, 0, 0, 32),
		Parent = keybind_list,
	})

	create_new('ImageLabel', {
		BackgroundTransparency = 1,
		AnchorPoint = _new_vector2(0, 0.5),
		Position = _new_udim2(0, 12, 0.5, 0),
		Size = _new_udim2(0, 14, 0, 14),
		Image = 'rbxassetid://10723416765',
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		Parent = keybind_list_header,
	})

	create_label({
		Size = _new_udim2(1, 0, 1, 0),
		Text = 'Keybinds',
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = keybind_list_header,
	})

	create_divider(keybind_list_header, _new_udim2(0, 0, 1, -1), _new_udim2(1, 0, 0, 1))

	local keybind_content = create_new('Frame', {
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = _new_udim2(1, 0, 0, 0),
		Parent = keybind_list,
	})

	create_vertical_list(keybind_content, 2)
	create_padding(keybind_content, 6, 8, 12, 12)

	self._keybind_list_frame = keybind_list
	self._keybind_list_content = keybind_content

	local keybind_dragging = false
	local keybind_drag_start = nil
	local keybind_list_position = nil

	keybind_list.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			keybind_dragging = true

			keybind_drag_start = input.Position
			keybind_list_position = keybind_list.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					keybind_dragging = false
				end
			end)
		end
	end)

	user_input_service.InputChanged:Connect(function(input)
		if not keybind_dragging then
			return
		end

		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			local scale = self._ui_scale
			local delta = (input.Position - keybind_drag_start) / scale

			_create_tween(tween_service, keybind_list, _new_tween_info(0.15), {
				Position = _new_udim2(
					keybind_list_position.X.Scale,
					keybind_list_position.X.Offset + delta.X,
					keybind_list_position.Y.Scale,
					keybind_list_position.Y.Offset + delta.Y
				),
			}):Play()
		end
	end)
end

function library.notify(self: runtime_typeof, message)
	self = resolve_runtime(self)

	if not self or not self._notification_holder then
		return
	end

	local text = _tostring(message or ''):gsub('[\r\n]+', ' '):gsub('^%s+', ''):gsub('%s+$', '')

	if text == '' then
		return
	end

	local text_width =
		text_service:GetTextSize(text, self._label_text_size, Enum.Font.GothamSemibold, _new_vector2(1000, 26)).X
	local width = _clamp(text_width + 24, 72, 540)

	self._notification_order += 1

	local notification = create_new('Frame', {
		Name = '_notification',
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		BackgroundTransparency = 1,
		LayoutOrder = self._notification_order,
		Size = _new_udim2(0, width - 12, 0, 0),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 200,
		Parent = self._notification_holder,
	})

	create_round(notification, 6)

	local notification_outline = create_outline(notification)
	notification_outline.Transparency = 1

	local notification_label = create_label({
		Position = _new_udim2(0, 10, 0, 0),
		Size = _new_udim2(1, -20, 1, 0),
		Text = text,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = self._label_text_size,
		TextTransparency = 1,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 201,
		Parent = notification,
	})

	_create_tween(
		tween_service,
		notification,
		_new_tween_info(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			BackgroundTransparency = 0,
			Size = _new_udim2(0, width, 0, 26),
		}
	):Play()
	_create_tween(
		tween_service,
		notification_label,
		_new_tween_info(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			TextTransparency = 0.1,
		}
	):Play()
	_create_tween(
		tween_service,
		notification_outline,
		_new_tween_info(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			Transparency = 0,
		}
	):Play()

	_delay(2.7, function()
		if not notification.Parent then
			return
		end

		_create_tween(
			tween_service,
			notification,
			_new_tween_info(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{
				BackgroundTransparency = 1,
				Size = _new_udim2(0, width - 12, 0, 0),
			}
		):Play()
		_create_tween(
			tween_service,
			notification_label,
			_new_tween_info(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{
				TextTransparency = 1,
			}
		):Play()
		_create_tween(
			tween_service,
			notification_outline,
			_new_tween_info(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{
				Transparency = 1,
			}
		):Play()
	end)

	_delay(3, function()
		if notification.Parent then
			notification:Destroy()
		end
	end)
end

local LUA_EMPTY_TEXT = '...'
local LUA_STORE_VERSION = 3
local LUA_CONTROL_METHODS = {
	toggle = 'create_toggle',
	slider = 'create_slider',
	dropdown = 'create_dropdown',
	button = 'create_button',
	keybind = 'create_keybind',
}

local show_lua_message = LPH_NO_VIRTUALIZE(function(message)
	local runtime = library._current

	if runtime then
		_defer(function()
			runtime:notify(message)
		end)
	end
end)

local lua_warning = LPH_JIT(function(message)
	warn(message)
	show_lua_message(message)
end)

local lua_notice = LPH_JIT(function(message)
	print(message)
	show_lua_message(message)
end)

local trim_lua_name = LPH_NO_VIRTUALIZE(function(value)
	local name = _tostring(value or ''):gsub('^%s+', ''):gsub('%s+$', '')

	return name:sub(1, 48)
end)

local source_lua_name = LPH_JIT_MAX(function(source)
	local searchable = source:gsub('%-%-%[%[.-%]%]', '')

	for line in searchable:gmatch('[^\r\n]+') do
		local code = line:gsub('%-%-.*$', '')
		local assignment = code:match('^%s*local%s+lua_name%s*=%s*(.+)$') or code:match('^%s*lua_name%s*=%s*(.+)$')

		if assignment then
			local quote = assignment:sub(1, 1)

			if quote == "'" or quote:byte() == 34 then
				local closing_quote = assignment:find(quote, 2, true)

				if closing_quote then
					local name = trim_lua_name(assignment:sub(2, closing_quote - 1))

					if name ~= '' then
						return name
					end
				end
			end
		end
	end

	return nil
end)

local lua_file_name = LPH_JIT(function(name)
	local stem = normalize_name(name):gsub('[^%w]+', '_'):gsub('_+', '_'):gsub('^_+', ''):gsub('_+$', '')

	if stem == '' then
		stem = 'lua'
	end

	return `{stem:sub(1, 40)}.lua`
end)

local lua_source_path = LPH_NO_VIRTUALIZE(function(file_name)
	return `Kittylol/luas/{file_name}`
end)

local valid_lua_file_name = LPH_NO_VIRTUALIZE(function(file_name)
	return _type(file_name) == 'string' and file_name:match('^[%w_%-]+%.lua$') ~= nil
end)

local lua_store_path = LPH_NO_VIRTUALIZE(function()
	return `Kittylol/luas/{game.GameId}.json`
end)

local read_lua_store = LPH_JIT(function()
	local store = {
		version = LUA_STORE_VERSION,
		selected = nil,
		entries = {},
		loaded = {},
		legacy_loaded = false,
	}
	local decoded = {}
	local names = {}
	local files = {}
	local store_path = lua_store_path()
	local has_store = isfile(store_path)

	if has_store then
		local success, result = _pcall(function()
			return http_service:JSONDecode(readfile(store_path))
		end)

		if success and _type(result) == 'table' then
			decoded = result
		else
			lua_warning('the saved Lua list is invalid; files will be discovered again')
		end
	end

	local function add_entry(file_name, source)
		if not valid_lua_file_name(file_name) or files[normalize_name(file_name)] or _type(source) ~= 'string' then
			return false
		end

		local declared_name = source_lua_name(source)

		if not declared_name then
			return false
		end

		local name = declared_name
		local suffix = 2

		while names[normalize_name(name)] do
			name = `{declared_name} ({suffix})`
			suffix += 1
		end

		names[normalize_name(name)] = true
		files[normalize_name(file_name)] = true

		_insert(store.entries, {
			name = name,
			file = file_name,
			source = source,
		})

		return true
	end

	for _, entry in decoded.entries or {} do
		if _type(entry) == 'table' then
			local source = nil
			local file_name = entry.file

			if
				valid_lua_file_name(file_name)
				and not files[normalize_name(file_name)]
				and isfile(lua_source_path(file_name))
			then
				local read_success, file_source = _pcall(readfile, lua_source_path(file_name))

				if read_success and _type(file_source) == 'string' then
					source = file_source
				end
			elseif _type(entry.source) == 'string' then
				source = entry.source

				local declared_name = source_lua_name(source)

				if declared_name then
					local base_file = lua_file_name(declared_name)
					local stem = base_file:sub(1, -5)
					local suffix = 2

					file_name = base_file

					while files[normalize_name(file_name)] or isfile(lua_source_path(file_name)) do
						file_name = `{stem}_{suffix}.lua`
						suffix += 1
					end

					local write_success = _pcall(writefile, lua_source_path(file_name), source)

					if write_success then
						store.migrated = true
					else
						source = nil
					end
				end
			end

			add_entry(file_name, source)
		end
	end

	local discovered_paths = {}

	if _type(listfiles) == 'function' then
		local list_success, paths = _pcall(listfiles, 'Kittylol/luas')

		if list_success and _type(paths) == 'table' then
			for _, path in paths do
				_insert(discovered_paths, _tostring(path))
			end
		end
	end

	table.sort(discovered_paths)

	for _, path in discovered_paths do
		local normalized_path = path:gsub('\\', '/')
		local file_name = normalized_path:match('([^/]+)$')

		if valid_lua_file_name(file_name) and not files[normalize_name(file_name)] then
			local read_success, source = _pcall(readfile, path)

			if not read_success then
				read_success, source = _pcall(readfile, lua_source_path(file_name))
			end

			if read_success and add_entry(file_name, source) then
				store.discovered = true
			end
		end
	end

	if _type(decoded.selected) == 'string' then
		store.selected = decoded.selected
	end

	if _type(decoded.loaded) == 'table' then
		for _, identifier in decoded.loaded do
			if _type(identifier) == 'string' then
				_insert(store.loaded, identifier)
			end
		end
	elseif store.selected then
		_insert(store.loaded, store.selected)
	end

	store.legacy_loaded = has_store and decoded.version ~= LUA_STORE_VERSION

	if store.legacy_loaded then
		store.migrated = true
	end

	return store
end)

local save_lua_store = LPH_JIT(function(manager)
	local encoded_entries = {}
	local encoded_loaded = {}

	for _, entry in manager._entries do
		_insert(encoded_entries, {
			name = entry.name,
			file = entry.file,
		})

		if manager._auto_load_files[normalize_name(entry.file)] then
			_insert(encoded_loaded, entry.file)
		end
	end

	local success, message = _pcall(function()
		writefile(
			lua_store_path(),
			http_service:JSONEncode({
				version = LUA_STORE_VERSION,
				selected = manager._selected,
				entries = encoded_entries,
				loaded = encoded_loaded,
			})
		)
	end)

	if not success then
		lua_warning(`could not save the Lua list: {_tostring(message)}`)
	end

	return success
end)

local unique_lua_name = LPH_NO_VIRTUALIZE(function(manager, preferred)
	local base_name = trim_lua_name(preferred)

	local name = base_name
	local suffix = 2

	while manager._by_name[normalize_name(name)] do
		name = `{base_name} ({suffix})`
		suffix += 1
	end

	return name
end)

local unique_lua_file = LPH_NO_VIRTUALIZE(function(manager, name)
	local base_file = lua_file_name(name)
	local stem = base_file:sub(1, -5)
	local file_name = base_file
	local suffix = 2

	while manager._by_file[normalize_name(file_name)] or isfile(lua_source_path(file_name)) do
		file_name = `{stem}_{suffix}.lua`
		suffix += 1
	end

	return file_name
end)

local normalize_import_source = LPH_JIT_MAX(function(source)
	if _type(source) ~= 'string' or source:match('^%s*$') then
		return nil
	end

	if source:sub(1, 3) == '\239\187\191' then
		source = source:sub(4)
	end

	local fenced_source = source:match('^%s*```[^\r\n]*[\r\n]+(.-)[\r\n]+```%s*$')

	return fenced_source or source
end)

local compile_lua_source = LPH_JIT_MAX(function(source, chunk_name)
	if _type(loadstring) ~= 'function' then
		return nil, 'this executor does not provide loadstring'
	end

	local success, chunk, compile_error = _pcall(loadstring, source, chunk_name)

	if success and _type(chunk) == 'function' then
		return chunk
	end

	local retry_success, retry_chunk, retry_error = _pcall(loadstring, source)

	if retry_success and _type(retry_chunk) == 'function' then
		return retry_chunk
	end

	return nil, _tostring(retry_error or compile_error or chunk or retry_chunk or 'unknown compile error')
end)

local safe_callback = LPH_JIT_MAX(function(lua_name, callback)
	if _type(callback) ~= 'function' then
		return nil
	end

	return function(...)
		local arguments = _pack(...)
		local success, message = _pcall(function()
			callback(_unpack(arguments, 1, arguments.n))
		end)

		if not success then
			lua_warning(`{lua_name} callback failed: {_tostring(message)}`)
		end
	end
end)

local normalize_control_values = LPH_JIT_MAX(function(entry, control_type, raw_value)
	local values = nil

	if control_type == 'toggle' then
		if _type(raw_value) == 'boolean' then
			values = { default = raw_value }
		elseif _type(raw_value) == 'table' then
			values = shallow_copy(raw_value)
		else
			return nil, 'toggle value must be a boolean or table'
		end

		values.default = values.default == true or values.Default == true
	elseif control_type == 'slider' then
		if _type(raw_value) ~= 'table' then
			return nil, 'slider value must contain minimum, maximum and default'
		end

		values = shallow_copy(raw_value)
		values.minimum = values.minimum or values.min
		values.maximum = values.maximum or values.max

		if
			_type(values.minimum) ~= 'number'
			or _type(values.maximum) ~= 'number'
			or values.minimum >= values.maximum
		then
			return nil, 'slider minimum and maximum are invalid'
		end

		values.default = values.default or values.minimum

		if _type(values.default) ~= 'number' then
			return nil, 'slider default must be a number'
		end

		values.default = _clamp(values.default, values.minimum, values.maximum)
	elseif control_type == 'dropdown' then
		if _type(raw_value) ~= 'table' then
			return nil, 'dropdown value must contain an options table'
		end

		if raw_value.options then
			values = shallow_copy(raw_value)
		else
			values = { options = shallow_copy(raw_value) }
		end

		if _type(values.options) ~= 'table' or #values.options == 0 then
			return nil, 'dropdown options cannot be empty'
		end

		local options = {}

		for _, option in values.options do
			_insert(options, _tostring(option))
		end

		values.options = options
		values.default = values.default or options[1]

		if not (values.multi_dropdown or values.multi) then
			values.default = _tostring(values.default)

			if not _find(options, values.default) then
				values.default = options[1]
			end
		end
	elseif control_type == 'button' then
		if _type(raw_value) == 'function' then
			values = { callback = raw_value }
		elseif _type(raw_value) == 'table' then
			values = shallow_copy(raw_value)
		else
			return nil, 'button value must be a callback or table'
		end

		if _type(values.callback) ~= 'function' then
			return nil, 'button value must include a callback'
		end
	elseif control_type == 'keybind' then
		if _type(raw_value) == 'table' then
			values = shallow_copy(raw_value)
		else
			values = { default = raw_value }
		end

		if _type(values.default) == 'string' then
			local key_name = values.default
			values.default = Enum.KeyCode[key_name]

			if not values.default then
				return nil, `keybind key '{key_name}' does not exist`
			end
		end

		values.default = values.default or Enum.KeyCode.E

		local valid_key, key_name = _pcall(function()
			return values.default.Name
		end)

		if not valid_key or _type(key_name) ~= 'string' then
			return nil, 'keybind default must be an Enum.KeyCode'
		end
	end

	if values.callback then
		values.callback = safe_callback(entry.name, values.callback)
	end

	return values
end)

local control_flag = LPH_NO_VIRTUALIZE(function(entry, definition, index)
	local name = _tostring(definition.flag or definition.name or definition.title or 'control')

	name = normalize_name(name):gsub('[^%w_%-]', '_')

	return `__lua_{game.GameId}_{normalize_name(entry.name):gsub('[^%w_%-]', '_')}_{name}_{index}`
end)

local validate_lua_definition = LPH_JIT_MAX(function(runtime, entry, queued, index)
	local definition = queued.definition

	if _type(definition) ~= 'table' then
		return nil, `function #{index} must be a table`
	end

	local control_type = normalize_name(
		definition.type or definition.control or definition.kind or definition.function_type
	):gsub('^create_', '')
	local method = LUA_CONTROL_METHODS[control_type]

	if not method then
		return nil, `function #{index} has an unsupported type`
	end

	local name = trim_lua_name(definition.name or definition.title)

	if name == '' then
		return nil, `function #{index} must include a name`
	end

	local raw_value = definition.value

	if raw_value == nil then
		raw_value = definition.values
	end

	if raw_value == nil then
		return nil, `{name} must include a value`
	end

	local values, values_error = normalize_control_values(entry, control_type, raw_value)

	if not values then
		return nil, `{name}: {values_error}`
	end

	values.title = name
	values.flag = control_flag(entry, definition, index)

	local group_value = definition.group
	local group_name = nil
	local side = definition.side

	if _type(group_value) == 'table' then
		group_name = group_value.name or group_value.title
		side = side or group_value.side
	else
		group_name = group_value
	end

	group_name = trim_lua_name(group_name)

	if group_name == '' then
		return nil, `{name} must include a group`
	end

	if queued.target == 'menu' then
		local tab_name = trim_lua_name(definition.tab)

		if tab_name == '' then
			return nil, `{name} must include an existing tab when using require('../menu')`
		end

		local tab_manager = runtime:_find_tab(tab_name, definition.category)

		if not tab_manager then
			return nil, `{name}: tab '{tab_name}' does not exist`
		end

		side = side and normalize_name(side) or nil

		if side and side ~= 'left' and side ~= 'right' then
			return nil, `{name}: side must be 'left' or 'right'`
		end

		local group_manager = runtime:_find_group(tab_manager, group_name, side)

		if not group_manager then
			return nil, `{name}: group '{group_name}' was not found or is ambiguous`
		end

		return {
			target = 'menu',
			group = group_manager,
			method = method,
			flag = values.flag,
			values = values,
		}
	end

	side = normalize_name(side)

	if side ~= 'left' and side ~= 'right' then
		return nil, `{name}: side must be 'left' or 'right' for the Lua tab`
	end

	return {
		target = 'lua',
		group_name = group_name,
		group_key = `{normalize_name(group_name)}::{side}`,
		side = side,
		method = method,
		flag = values.flag,
		values = values,
	}
end)

local build_lua_environment = LPH_ENCFUNC(function(queued)
	local accepting = true
	local menu_requested = false

	local function queue(target, definition, defaults)
		if not accepting then
			error('menu functions can only be created while the Lua is loading', 2)
		end

		if _type(definition) ~= 'table' then
			error('a function definition table is required', 2)
		end

		local copy = shallow_copy(definition)

		for index, value in defaults or {} do
			if copy[index] == nil then
				copy[index] = value
			end
		end

		queued[#queued + 1] = {
			target = target,
			definition = copy,
		}

		return #queued
	end

	local function attach_creators(api, target, defaults)
		api.create = LPH_NO_UPVALUES(function(first, second)
			return queue(target, second ~= nil and second or first, defaults)
		end)
		api.add = api.create

		for control_type in LUA_CONTROL_METHODS do
			api[`create_{control_type}`] = LPH_NO_UPVALUES(function(first, second)
				local definition = second ~= nil and second or first

				if _type(definition) ~= 'table' then
					error('a function definition table is required', 2)
				end

				definition = shallow_copy(definition)
				definition.type = control_type

				return queue(target, definition, defaults)
			end)
		end
	end

	local default_api = {}
	attach_creators(default_api, 'lua')
	default_api = read_only(default_api)

	local menu_api = {}
	attach_creators(menu_api, 'menu')

	menu_api.group = LPH_NO_UPVALUES(function(first, tab_name, group_name, side)
		if _type(first) == 'string' then
			side = group_name
			group_name = tab_name
			tab_name = first
		end

		local builder = {}
		attach_creators(builder, 'menu', {
			tab = tab_name,
			group = group_name,
			side = side,
		})

		return read_only(builder)
	end)

	menu_api = read_only(menu_api)

	local internals = read_only(lua_internal_exports)
	local custom_require = LPH_NO_UPVALUES(function(module_name)
		if _type(module_name) ~= 'string' then
			error('Kittylol Lua require expects a string path', 2)
		end

		local path = string.gsub(normalize_name(module_name), '\\', '/')

		if path == '../menu' or path == './menu' or path == 'menu' then
			menu_requested = true

			return menu_api
		end

		if path == '../internals' or path == './internals' or path == 'internals' then
			return internals
		end

		error(`module '{module_name}' is not available`, 2)
	end)

	local environment = {
		assert = assert,
		error = error,
		getmetatable = getmetatable,
		ipairs = ipairs,
		next = next,
		pairs = pairs,
		pcall = pcall,
		print = print,
		rawequal = rawequal,
		rawget = rawget,
		select = select,
		tonumber = tonumber,
		tostring = tostring,
		type = type,
		typeof = typeof,
		unpack = unpack or _unpack,
		warn = warn,
		xpcall = xpcall,
		bit32 = bit32 and read_only(bit32) or nil,
		coroutine = coroutine and read_only(coroutine) or nil,
		math = read_only(math),
		os = os and read_only(os) or nil,
		string = read_only(string),
		table = read_only(table),
		task = read_only(task),
		utf8 = utf8 and read_only(utf8) or nil,
		cloneref = _cloneref,
		game = game,
		workspace = workspace,
		Enum = Enum,
		Axes = Axes,
		BrickColor = BrickColor,
		CFrame = CFrame,
		Color3 = Color3,
		ColorSequence = ColorSequence,
		ColorSequenceKeypoint = ColorSequenceKeypoint,
		DateTime = DateTime,
		Faces = Faces,
		Font = Font,
		Instance = Instance,
		NumberRange = NumberRange,
		NumberSequence = NumberSequence,
		NumberSequenceKeypoint = NumberSequenceKeypoint,
		OverlapParams = OverlapParams,
		PhysicalProperties = PhysicalProperties,
		Random = Random,
		Ray = Ray,
		RaycastParams = RaycastParams,
		Rect = Rect,
		Region3 = Region3,
		TweenInfo = TweenInfo,
		UDim = UDim,
		UDim2 = UDim2,
		Vector2 = Vector2,
		Vector3 = Vector3,
		require = custom_require,
		lua = default_api,
	}

	environment.create = LPH_NO_UPVALUES(function(definition)
		return queue('lua', definition)
	end)
	environment.create_function = environment.create

	for control_type in LUA_CONTROL_METHODS do
		environment[`create_{control_type}`] = LPH_NO_UPVALUES(function(definition)
			definition = shallow_copy(definition)
			definition.type = control_type

			return queue('lua', definition)
		end)
	end

	local function finish()
		accepting = false
	end

	local function queue_returned(result)
		if _type(result) ~= 'table' then
			return
		end

		local definitions = result.functions

		if _type(definitions) == 'table' then
			for _, definition in definitions do
				local target = menu_requested and _type(definition) == 'table' and definition.tab and 'menu' or 'lua'
				queue(target, definition)
			end

			return
		end

		if #result > 0 then
			for _, definition in result do
				local target = menu_requested and _type(definition) == 'table' and definition.tab and 'menu' or 'lua'
				queue(target, definition)
			end

			return
		end

		if result.type or result.control or result.kind or result.function_type then
			local target = menu_requested and result.tab and 'menu' or 'lua'
			queue(target, result)
		end
	end

	return environment, finish, queue_returned
end, 'aa1143ae1640d00049535f95a227d34d986d65cb6c300e7e11d97cfb990fd492', lua_sandbox_decryption_key)

library._load_lua_entry = LPH_ENCFUNC(function(self: _runtime, manager, entry)
	local file_key = normalize_name(entry.file)

	if manager._loaded[file_key] then
		return true
	end

	if _type(setfenv) ~= 'function' then
		return false, 'the executor must support loadstring and setfenv'
	end

	local chunk, compile_error = compile_lua_source(entry.source, `@Kittylol/{entry.name}`)

	if not chunk then
		return false, _tostring(compile_error)
	end

	local queued = {}
	local environment, finish, queue_returned = build_lua_environment(queued)
	local environment_ok, environment_error = _pcall(setfenv, chunk, environment)

	if not environment_ok then
		finish()

		return false, _tostring(environment_error)
	end

	local success, result = _pcall(chunk)

	if not success then
		finish()

		return false, _tostring(result)
	end

	local return_success, return_error = _pcall(queue_returned, result)
	finish()

	if not return_success then
		return false, _tostring(return_error)
	end

	local prepared = {}

	for index, definition in queued do
		local control, validation_error = validate_lua_definition(self, entry, definition, index)

		if not control then
			return false, validation_error
		end

		_insert(prepared, control)
	end

	local created_in_lua_tab = 0

	for _, control in prepared do
		local group_manager = control.group

		if control.target == 'lua' then
			group_manager = manager._lua_groups[control.group_key]

			if not group_manager then
				group_manager = manager._lua_tab:create_group(control.group_name, control.side)
				manager._lua_groups[control.group_key] = group_manager
			end

			created_in_lua_tab += 1
		end

		local create_control = group_manager[control.method]
		local create_success, create_error = _pcall(create_control, group_manager, control.flag, control.values)

		if not create_success then
			return false, _tostring(create_error)
		end
	end

	manager._lua_control_count += created_in_lua_tab
	manager._loaded[file_key] = true

	if manager._lua_control_count > 0 then
		manager._lua_tab:set_enabled(true)
	end

	return true
end, 'e83f53ad24607d2fd2350345fd2d8265c695310635c212e78fb389573ebf33a0', lua_loader_decryption_key)

library.register_lua_internals = LPH_ENCFUNC(function(_self: runtime_typeof, internals)
	if _type(internals) ~= 'table' then
		error('register_lua_internals expects a table', 2)
	end

	for name, value in internals do
		if _type(name) ~= 'string' then
			error('internal names must be strings', 2)
		end

		lua_internal_exports[name] = protect_lua_value(value)
	end
end, '03bd60e589693d30b9f98cde0ac9bc772ccde9534705153de1bf27f8b58c0db4', lua_register_decryption_key)

function library.load_manager(self: runtime_typeof)
	self = resolve_runtime(self) or library._new()

	if self._manager_loaded then
		return self._lua_manager
	end

	local menu_category = self:_find_category('menu') or self:create_category('menu')
	local configs = self:_find_tab('Configs', 'menu') or menu_category:create_tab('Configs', 'rbxassetid://10734941499')

	if not self._is_mobile then
		local interface_group = self:_find_group(configs, 'interface', 'left')

		if not interface_group then
			interface_group = configs:create_group('interface', 'left')

			interface_group:create_keybind('minimize', {
				title = 'Minimize',
				default = Enum.KeyCode.Insert,
			})

			interface_group:create_toggle('keybind_list', {
				title = 'Keybind List',
				default = false,
				callback = function(state)
					self._keybind_list_visible = state
					self:update_keybind_list()
				end,
			})
		end

		if self._flags.keybind_list then
			self._keybind_list_visible = true
			self:update_keybind_list()
		end
	end

	local lua_tab = self:_find_tab('Lua', 'menu')

	if not lua_tab then
		lua_tab = menu_category:create_tab('Lua', 'rbxassetid://10709781717')

		local lua_order = configs._data._btn.LayoutOrder + 1

		for _, tab_data in self._tabs do
			if
				tab_data._manager ~= lua_tab
				and normalize_name(tab_data._category) == 'menu'
				and tab_data._btn.LayoutOrder >= lua_order
			then
				tab_data._btn.LayoutOrder += 1
			end
		end

		lua_tab._data._btn.LayoutOrder = lua_order
	end

	lua_tab:set_enabled(false)

	local lua_side = self._is_mobile and 'left' or 'right'
	local lua_group = self:_find_group(configs, 'lua', lua_side) or configs:create_group('lua', lua_side)
	local store = read_lua_store()
	local manager = {
		_instance = self,
		_lua_tab = lua_tab,
		_lua_groups = {},
		_lua_control_count = 0,
		_entries = {},
		_by_name = {},
		_by_file = {},
		_loaded = {},
		_auto_load_files = {},
		_selected = nil,
		_auto_load = self._flags.__kittylol_lua_auto_load == true,
	}

	for _, entry in store.entries do
		_insert(manager._entries, entry)
		manager._by_name[normalize_name(entry.name)] = entry
		manager._by_file[normalize_name(entry.file)] = entry
	end

	if store.legacy_loaded then
		for _, entry in manager._entries do
			manager._auto_load_files[normalize_name(entry.file)] = true
		end
	else
		for _, identifier in store.loaded do
			local key = normalize_name(identifier)
			local entry = manager._by_file[key] or manager._by_name[key]

			if entry then
				manager._auto_load_files[normalize_name(entry.file)] = true
			end
		end
	end

	if store.selected and manager._by_name[normalize_name(store.selected)] then
		manager._selected = manager._by_name[normalize_name(store.selected)].name
	elseif manager._entries[1] then
		manager._selected = manager._entries[1].name
	end

	local function lua_files()
		local files = {}

		for _, entry in manager._entries do
			_insert(files, entry.file)
		end

		return files
	end

	local function selected_lua_file()
		local entry = manager._selected and manager._by_name[normalize_name(manager._selected)] or nil

		return entry and entry.file or nil
	end

	local selector = lua_group:create_dropdown('__kittylol_lua_selected', {
		title = 'Luas',
		options = lua_files(),
		default = selected_lua_file(),
		empty_text = LUA_EMPTY_TEXT,
		hide_icon = true,
		hide_selected_option = true,
		callback = function(selected)
			local entry = manager._by_file[normalize_name(selected)]

			manager._selected = entry and entry.name or nil
			save_lua_store(manager)
		end,
	})

	manager._selector = selector

	local function refresh_lua_selector(selected)
		if selected then
			local entry = manager._by_name[normalize_name(selected)]

			manager._selected = entry and entry.name or manager._selected
		end

		selector:set_options(lua_files(), selected_lua_file())

		if #manager._entries > 0 then
			selector:set_locked_open(true)
			selector:unfold(true)
		else
			selector:set_locked_open(false)
			selector:unfold(false)
		end
	end

	manager.refresh_dropdown = refresh_lua_selector
	refresh_lua_selector(manager._selected)

	if store.migrated or store.discovered then
		save_lua_store(manager)
	end

	local function load_selected()
		if not manager._selected then
			lua_warning('select or import a Lua before loading')

			return false
		end

		local entry = manager._by_name[normalize_name(manager._selected)]

		if not entry then
			lua_warning('the selected Lua no longer exists')

			return false
		end

		local success, message = self:_load_lua_entry(manager, entry)

		if not success then
			lua_warning(`{entry.name} could not be loaded: {_tostring(message)}`)
		else
			local file_key = normalize_name(entry.file)

			if not manager._auto_load_files[file_key] then
				manager._auto_load_files[file_key] = true
				save_lua_store(manager)
			end
		end

		return success
	end

	local function load_saved()
		for _, entry in manager._entries do
			if manager._auto_load_files[normalize_name(entry.file)] then
				local success, message = self:_load_lua_entry(manager, entry)

				if not success then
					lua_warning(`{entry.name} could not be auto loaded: {_tostring(message)}`)
				end
			end
		end
	end

	local paste_box = nil

	local function import_pasted_source()
		local source = paste_box and normalize_import_source(paste_box:get_value()) or nil

		if not source then
			paste_box:focus()
			lua_warning("paste the Lua source into 'Paste Lua' before importing")

			return false
		end

		local declared_name = source_lua_name(source)

		if not declared_name then
			lua_warning("import failed: add lua_name = 'example' to the Lua source")

			return false
		end

		local chunk, compile_error = compile_lua_source(source, '@Kittylol/import')

		if not chunk then
			lua_warning(`import failed: {_tostring(compile_error)}`)

			return false
		end

		for _, entry in manager._entries do
			if entry.source == source then
				manager._selected = entry.name
				refresh_lua_selector(entry.name)
				save_lua_store(manager)
				lua_notice(`selected existing Lua: {entry.name}`)
				paste_box:clear()

				return true
			end
		end

		local name = unique_lua_name(manager, declared_name)
		local file_name = unique_lua_file(manager, name)
		local write_success, write_error = _pcall(writefile, lua_source_path(file_name), source)

		if not write_success then
			lua_warning(`import failed while saving {file_name}: {_tostring(write_error)}`)

			return false
		end

		local entry = {
			name = name,
			file = file_name,
			source = source,
		}

		_insert(manager._entries, entry)
		manager._by_name[normalize_name(name)] = entry
		manager._by_file[normalize_name(file_name)] = entry
		manager._selected = name

		refresh_lua_selector(name)
		save_lua_store(manager)
		lua_notice(`imported {name} as {file_name}`)
		paste_box:clear()

		return true
	end

	local function import_paste()
		local success, result = _pcall(import_pasted_source)

		if not success then
			lua_warning(`import failed unexpectedly: {_tostring(result)}`)

			return false
		end

		return result
	end

	lua_group:create_button({
		title = 'Load',
		callback = load_selected,
	})

	lua_group:create_toggle('__kittylol_lua_auto_load', {
		title = 'Auto Load',
		default = false,
		callback = function(state)
			manager._auto_load = state

			if state then
				_defer(load_saved)
			end
		end,
	})

	local function pasted_lua_file(source)
		source = normalize_import_source(source)

		if not source then
			return ''
		end

		for _, entry in manager._entries do
			if entry.source == source then
				return entry.file
			end
		end

		local declared_name = source_lua_name(source)

		if not declared_name then
			return nil
		end

		return unique_lua_file(manager, unique_lua_name(manager, declared_name))
	end

	paste_box = lua_group:create_textbox({
		title = 'Paste Lua',
		placeholder = LUA_EMPTY_TEXT,
		height = 24,
		compact = true,
		display = pasted_lua_file,
	})
	manager._paste_box = paste_box

	lua_group:create_button({
		title = 'Import',
		callback = import_paste,
	})

	manager.load = load_selected
	manager.import = import_paste

	self._lua_manager = manager
	self._manager_loaded = true

	if manager._auto_load then
		_defer(load_saved)
	end

	return manager
end

return library
