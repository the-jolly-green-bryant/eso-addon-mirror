if LibConsoleMenu then
	error("Library loaded already. Please remove all LibConsoleMenu in sub folders.")
end

LibConsoleMenu = {}
LibConsoleMenu.version = 84
local LibConsoleMenu = LibConsoleMenu

-----
-- Control Types
-----
LibConsoleMenu.CT_TOGGLE = 1
LibConsoleMenu.CT_SLIDER = 2
LibConsoleMenu.CT_EDIT = 3
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

-- Screen runtime (written by Settings / navigation).
LibConsoleMenu.currentSettings = nil
LibConsoleMenu.needUpdate = true

LibConsoleMenu.addons = {}

local AddonSettings = ZO_Object:Subclass()
local AddonSettingsControl = ZO_Object:Subclass()

LibConsoleMenu.AddonSettings = AddonSettings
LibConsoleMenu.AddonSettingsControl = AddonSettingsControl

-----
-- AddonSettingsControl class - represents single option control
-----
function AddonSettingsControl:New(callbackManager, type)
	local object = ZO_Object.New(self)
	object.type = type
	object.callbackManager = callbackManager
	if object.callbackManager then
		object.callbackManager:RegisterCallback("ValueChanged", object.SettingValueChangedCallback, object)
	end
	return object
end

function AddonSettingsControl:IsDisabled()
	return (self.disable == true) or (type(self.disable) == "function" and self.disable())
end

function AddonSettingsControl:SettingValueChangedCallback(changedSetting)
	if self == changedSetting then
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

function AddonSettingsControl:SetAnchor(lastControl)
	-- Console parametric list owns layout; no manual anchoring.
end

function AddonSettingsControl:ValueChanged(...)
	if type(self.setFunction) == "function" then
		self.setFunction(...)
	elseif type(self.clickHandler) == "function" then
		self.clickHandler(...)
	end
	if self.callbackManager then
		self.callbackManager:FireCallbacks("ValueChanged", self)
	end
end

function AddonSettingsControl:GetValueOrCallback(arg)
	return type(arg) == "function" and arg(self) or arg
end

function AddonSettingsControl:GetString(strOrId)
	return type(strOrId) == "number" and GetString(strOrId) or strOrId
end

function AddonSettingsControl:SetValue(...)
	if not self.control or not self.control.SetValue then
		return
	end
	return self.control:SetValue(...)
end

function AddonSettingsControl:ResetToDefaults()
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

function AddonSettingsControl:GetHeight()
	return self.control:GetHeight() + 8
end
-----

-----
-- AddonSettings class - represents addon settings panel
-----
function AddonSettings:New(name, options)
	local object = ZO_Object.New(self)
	if type(options) == "table" then
		object.allowDefaults = options.allowDefaults
		object.defaultsFunction = options.defaultsFunction
		object.author = options.author
		object.version = options.version
		object.category = options.category
		object.addonID = options.addonID
		-- Center submenu labels to match options-style headers (default: stock left nav look).
		object.centerSubmenus = options.centerSubmenus == true
		-- Unfocused toggles show only the active On/Off label (native). Opt out with false.
		object.collapseToggleLabels = options.collapseToggleLabels ~= false
		-- Unfocused sliders hide min/max/value labels. Opt out with false.
		object.collapseSliderLabels = options.collapseSliderLabels ~= false
		if options.allowRefresh then
			object.callbackManager = ZO_CallbackObject:New()
		end
	end
	object.name = name
	object.selected = false
	object.settings = {}
	return object
end

function AddonSettings:InsertSetting(params, index)
	--Append if invalid or empty index
	if index == nil or index < 1 then
		index = #self.settings + 1
	end

	local setting = AddonSettingsControl:New(self.callbackManager, params.type)
	table.insert(self.settings, index, setting)
	setting:SetupControl(params)

	return setting, index
end

function AddonSettings:RefreshAfterSettingsChange(playAnimation)
	--Put insertions into proper sections.
	self:SetupSubmenus()

	--Force the settings page to update immediately if currently showing.
	if self.selected then
		self:CreateControls()
	end
end

function AddonSettings:AddSetting(params, index, playAnimation)
	--Prevent an attempt at cleaning up the new control before it gets created.
	self:CleanUpIfSelected()

	local setting, insertIndex = self:InsertSetting(params, index)
	self:RefreshAfterSettingsChange(playAnimation)

	return setting, insertIndex
end

function AddonSettings:AddSettings(params, index, playAnimation)
	--It should be possible to set for i = (index or 1), #params + index and let the indexes be
	--built into the returned table, but that might be less intuitive to iterate through.
	self:CleanUpIfSelected()

	local ret = {}
	local indexes = {}
	for i = 1, #params do
		ret[i], indexes[i] = self:InsertSetting(params[i], index)
		if index ~= nil and index > 0 then
			index = index + 1
		end --Increment the index to add them in-order, not reverse order.
	end

	if #params > 0 then
		self:RefreshAfterSettingsChange(playAnimation)
	end

	return ret, indexes
end

--removes up to count settings at index.
--always refreshes list to ensure proper cleanup.
function AddonSettings:RemoveSettings(index, count, playAnimation)
	--It is important to cleanup before removing from table or else we can get stuck with the controls forever.
	self:CleanUpIfSelected()
	local removedSettingsList = {}
	if not count then
		count = 1
	end
	for i = 1, count do
		if not self.settings[index] then
			break
		end
		table.insert(removedSettingsList, table.remove(self.settings, index))
	end

	if #removedSettingsList > 0 then
		self:RefreshAfterSettingsChange(playAnimation)
	end

	return removedSettingsList
end

--removes all settings
--always refreshes list to ensure proper cleanup.
function AddonSettings:RemoveAllSettings(playAnimation)
	self:CleanUpIfSelected()

	local oldSettingsList = {}
	while #self.settings > 0 do
		table.insert(oldSettingsList, table.remove(self.settings, 1))
	end

	if #oldSettingsList > 0 then
		self:RefreshAfterSettingsChange(playAnimation)
	end

	return oldSettingsList
end

--Find the index of the first setting made from these params.
--This uses shallow table comparisons, which feels very unoptimal.
--If a setting's index position is static, it would be better to use the return value of AddSetting(s)
function AddonSettings:GetIndexOf(setting, areParams)
	if areParams then
		local tempSetting = AddonSettingsControl:New(self.callbackManager, setting.type)
		tempSetting:SetupControl(setting)
		setting = tempSetting
	end

	local isMatch = false
	for index, existing in pairs(self.settings) do
		isMatch = true
		for k, v in pairs(setting) do
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

function AddonSettings:Select()
	if self.selected then
		return
	end
	CALLBACK_MANAGER:FireCallbacks("LibConsoleMenu_AddonSelected", self.name, self)
	self.selected = true
end

function AddonSettings:CleanUp()
	for i = 1, #self.settings do
		self.settings[i]:CleanUp()
	end
end

function AddonSettings:CleanUpIfSelected()
	if not self.selected then
		return
	end
	return self:CleanUp()
end

function AddonSettings:Clear()
	self.settings = {}
	self.selected = false
end
-----

-----
-- LibConsoleMenu singleton
-----
local function RemoveColorMarkup(name)
	name = zo_strgsub(name, "|[Cc][%w][%w][%w][%w][%w][%w]", "")
	name = zo_strgsub(name, "|[Rr]", "")
	return name
end

function LibConsoleMenu:AddAddon(name, options)
	name = RemoveColorMarkup(name)

	for i = 1, #self.addons do
		if self.addons[i].name == name then
			return self.addons[i]
		end
	end
	local addonSettings = AddonSettings:New(name, options)
	table.insert(self.addons, addonSettings)

	return addonSettings
end

function LibConsoleMenu:Initialize()
	if self.initialized then
		return
	end
	if not IsConsoleUI() then
		return
	end

	self:CreateAddonSettingsPanel()
	self:CreateControlPools()
	self:CreateAddonList()

	self.initialized = true
end


