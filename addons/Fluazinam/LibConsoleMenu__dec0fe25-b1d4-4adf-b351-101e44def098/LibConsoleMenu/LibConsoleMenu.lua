if LibConsoleMenu then
	error("Library loaded already. Please remove all LibConsoleMenu in sub folders.")
end

LibConsoleMenu = {}
LibConsoleMenu.version = 102
local LibConsoleMenu = LibConsoleMenu

-----
-- Control Types
-----
LibConsoleMenu.CT_TOGGLE = 1
LibConsoleMenu.CT_SLIDER = 2
LibConsoleMenu.CT_EDITBOX = 3
LibConsoleMenu.CT_SELECTOR = 4
LibConsoleMenu.CT_DROPDOWN = 5
LibConsoleMenu.CT_CHECKLIST = 6
LibConsoleMenu.CT_COLORPICKER = 7
LibConsoleMenu.CT_ICONPICKER = 8
LibConsoleMenu.CT_BUTTON = 9
LibConsoleMenu.CT_SUBMENU = 10
-----

-- Shared handler tables (filled by ControlHandlers / controls/* modules).
LibConsoleMenu.changeControlStateFunctions = {}
LibConsoleMenu.updateControlFunctions = {}
LibConsoleMenu.createControlFunctions = {}
LibConsoleMenu.cleanControlFunctions = {}
LibConsoleMenu.setupControlFunctions = {}

-- Screen runtime (written by navigation).
LibConsoleMenu.currentMenu = nil
LibConsoleMenu.needUpdate = true

LibConsoleMenu.menus = {}
LibConsoleMenu.menuData = {}

local AddonMenu = ZO_Object:Subclass()
local Control = ZO_Object:Subclass()

LibConsoleMenu.AddonMenu = AddonMenu
LibConsoleMenu.Control = Control

-----
-- Control class - internal UI row for one option
-----
function Control:New(callbackManager, type)
	local object = ZO_Object.New(self)
	object.type = type
	object.callbackManager = callbackManager
	if object.callbackManager then
		object.callbackManager:RegisterCallback("ValueChanged", object.ValueChangedCallback, object)
	end
	return object
end

function Control:IsDisabled()
	return (self.disable == true) or (type(self.disable) == "function" and self.disable())
end

function Control:ValueChangedCallback(changedControl)
	if self == changedControl then
		return
	end

	if self.getFunction then
		self:SetValue(self.getFunction())
	end

	if self.type == LibConsoleMenu.CT_SUBMENU then
		return
	end

	self:SetEnabled(not self:IsDisabled())
end

function Control:SetAnchor(lastControl)
	-- Console parametric list owns layout; no manual anchoring.
end

function Control:ValueChanged(...)
	if type(self.setFunction) == "function" then
		self.setFunction(...)
	elseif type(self.clickHandler) == "function" then
		self.clickHandler(...)
	end
	if self.callbackManager then
		self.callbackManager:FireCallbacks("ValueChanged", self)
	end
end

function Control:GetValueOrCallback(arg)
	return type(arg) == "function" and arg(self) or arg
end

function Control:GetString(strOrId)
	return type(strOrId) == "number" and GetString(strOrId) or strOrId
end

function Control:SetValue(...)
	if not self.control or not self.control.SetValue then
		return
	end
	return self.control:SetValue(...)
end

function Control:ResetToDefaults()
	if self.ignoreDefault then
		return
	end
	if self.type == LibConsoleMenu.CT_SELECTOR or self.type == LibConsoleMenu.CT_DROPDOWN then
		local items = self:GetValueOrCallback(self.items) or {}
		local default = self.default
		local itemIndex = 1
		for i = 1, #items do
			local item = items[i]
			if item == default or item.name == default or item.data == default then
				itemIndex = i
				break
			end
		end
		local item = items[itemIndex]
		-- SetValue / FindIndexFromData match getFunction (display name) or item.data.
		self:SetValue(item and item.name or default)
		if self.control and self.setFunction then
			local combobox = self.control.GetDropDown and self.control:GetDropDown() or self.control.dropdown
			self.setFunction(combobox, item and item.name or default, item)
		end
	elseif self.type == LibConsoleMenu.CT_CHECKLIST then
		local default = self.default
		if type(default) ~= "table" then
			default = {}
		end
		local copy = {}
		for i = 1, #default do
			copy[i] = default[i]
		end
		self:SetValue(copy)
		if self.setFunction then
			self.setFunction(copy)
		end
	elseif self.type == LibConsoleMenu.CT_COLORPICKER then
		self:SetValue(unpack(self.default))
		self.setFunction(unpack(self.default))
	elseif self.type == LibConsoleMenu.CT_ICONPICKER then
		self:SetValue(self.default or 1)
		local combobox = self.control and self.control:GetDropDown()
		if self.texture then
			self.setFunction(combobox, self.default)
		else
			local items = self:GetValueOrCallback(self.items)
			self.setFunction(combobox, self.default, items and items[self.default])
		end
	elseif self.setFunction then
		self:SetValue(self.default)
		self.setFunction(self.default)
	end
end

function Control:GetHeight()
	return self.control:GetHeight() + 8
end
-----

-----
-- AddonMenu class - Add-ons menu entry + control list
-----
function AddonMenu:New(title, options)
	local object = ZO_Object.New(self)
	if type(options) == "table" then
		-- Page Defaults. Opt out with false.
		object.enableDefaults = options.enableDefaults ~= false
		-- Full-addon Reset. Opt in; requires resetFunc / resetFunction.
		object.enableReset = options.enableReset == true
		object.resetFunction = options.resetFunction
		object.author = options.author
		object.version = options.version
		object.category = options.category
		object.menuId = options.menuId or options.addonID
		-- Center submenu labels to match options-style headers (default: stock left nav look).
		object.centerSubmenus = options.centerSubmenus == true
		-- Unfocused toggles show only the active On/Off label (native). Opt out with false.
		object.collapseToggleLabels = options.collapseToggleLabels ~= false
		-- Unfocused sliders hide min/max/value labels. Opt out with false.
		object.collapseSliderLabels = options.collapseSliderLabels ~= false
		-- Always refresh sibling rows after a change (disabled callbacks, live values).
		object.callbackManager = ZO_CallbackObject:New()
	end
	object.title = title
	object.selected = false
	object.controls = {}
	return object
end

function AddonMenu:InsertControl(params, index)
	-- Append if invalid or empty index
	if index == nil or index < 1 then
		index = #self.controls + 1
	end

	local control = Control:New(self.callbackManager, params.type)
	table.insert(self.controls, index, control)
	control:Setup(params)

	return control, index
end

function AddonMenu:RefreshAfterControlsChange(playAnimation)
	-- Put insertions into proper sections.
	self:SetupSubmenus()

	-- Force the page to update immediately if currently showing.
	if self.selected then
		self:CreateControls()
	end
end

function AddonMenu:AddControl(params, index, playAnimation)
	-- Prevent an attempt at cleaning up the new control before it gets created.
	self:CleanUpIfSelected()

	local control, insertIndex = self:InsertControl(params, index)
	self:RefreshAfterControlsChange(playAnimation)

	return control, insertIndex
end

function AddonMenu:AddControls(params, index, playAnimation)
	self:CleanUpIfSelected()

	local base = #self.controls
	local ret = {}
	local indexes = {}
	for i = 1, #params do
		ret[i], indexes[i] = self:InsertControl(params[i], index)
		if index ~= nil and index > 0 then
			index = index + 1
		end
	end

	-- popAfterSubmenuIndex is relative to this compiled batch; bind live Control refs.
	for i = 1, #ret do
		local control = ret[i]
		local rel = control.popAfterSubmenuIndex
		if rel then
			control.popAfterSubmenu = self.controls[base + rel]
			control.popAfterSubmenuIndex = nil
		end
	end

	if #params > 0 then
		self:RefreshAfterControlsChange(playAnimation)
	end

	return ret, indexes
end

-- Removes up to count controls at index.
-- Always refreshes list to ensure proper cleanup.
function AddonMenu:RemoveControls(index, count, playAnimation)
	self:CleanUpIfSelected()
	local removedList = {}
	if not count then
		count = 1
	end
	for i = 1, count do
		if not self.controls[index] then
			break
		end
		table.insert(removedList, table.remove(self.controls, index))
	end

	if #removedList > 0 then
		self:RefreshAfterControlsChange(playAnimation)
	end

	return removedList
end

function AddonMenu:RemoveAllControls(playAnimation)
	self:CleanUpIfSelected()

	local oldList = {}
	while #self.controls > 0 do
		table.insert(oldList, table.remove(self.controls, 1))
	end

	if #oldList > 0 then
		self:RefreshAfterControlsChange(playAnimation)
	end

	return oldList
end

-- Find the index of the first control made from these params.
-- Uses shallow table comparisons. Prefer the return value of AddControl(s) when possible.
function AddonMenu:GetIndexOf(control, areParams)
	if areParams then
		local tempControl = Control:New(self.callbackManager, control.type)
		tempControl:Setup(control)
		control = tempControl
	end

	local isMatch = false
	for index, existing in pairs(self.controls) do
		isMatch = true
		for k, v in pairs(control) do
			local t = type(v)
			if t ~= "table" and t ~= "userdata" and existing[k] ~= v then
				isMatch = false
				break
			end
		end
		if isMatch then
			return index
		end
	end
	return nil
end

function AddonMenu:Select()
	if self.selected then
		return
	end
	CALLBACK_MANAGER:FireCallbacks("LibConsoleMenu_AddonSelected", self.title, self)
	self.selected = true
end

function AddonMenu:CleanUp()
	for i = 1, #self.controls do
		self.controls[i]:CleanUp()
	end
end

function AddonMenu:CleanUpIfSelected()
	if not self.selected then
		return
	end
	return self:CleanUp()
end

function AddonMenu:Clear()
	self.controls = {}
	self.selected = false
end
-----

-----
-- LibConsoleMenu singleton
-----
local function RemoveColorMarkup(title)
	title = zo_strgsub(title, "|[Cc][%w][%w][%w][%w][%w][%w]", "")
	title = zo_strgsub(title, "|[Rr]", "")
	return title
end

-- Used only by CreateAddonMenu (not author-facing).
local function CreateMenuInstance(self, title, options)
	title = RemoveColorMarkup(title)

	for i = 1, #self.menus do
		if self.menus[i].title == title then
			return self.menus[i]
		end
	end
	local menu = AddonMenu:New(title, options)
	table.insert(self.menus, menu)

	return menu
end

LibConsoleMenu._CreateMenuInstance = CreateMenuInstance

function LibConsoleMenu:Initialize()
	if self.initialized then
		return
	end
	if not IsConsoleUI() then
		return
	end

	self:CreateSharedMenuScene()
	self:CreateControlPools()
	self:CreateAddonList()

	self.initialized = true
end
