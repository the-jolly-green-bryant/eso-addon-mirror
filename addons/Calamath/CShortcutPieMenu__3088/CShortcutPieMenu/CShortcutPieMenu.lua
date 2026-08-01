--
-- Calamath's Shortcut Pie Menu [CSPM]
--
-- Copyright (c) 2021 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--
-- Note :
-- This addon works that uses the library LibAddonMenu-2.0 by sirinsidiator, Seerah, released under the Artistic License 2.0
-- This addon works that uses the library LibCInteraction by Calamath, released under the Artistic License 2.0
-- This addon works that uses the library LibCPieMenu by Calamath, released under the Artistic License 2.0
-- You will need to obtain the above libraries separately.
--

-- ---------------------------------------------------------------------------------------
-- Checking dependencies
-- ---------------------------------------------------------------------------------------
local _EXTERNAL_DEPENDENCIES = {
	"LibAddonMenu2", 
	"LibCInteraction", 
	"LibCPieMenu", 
}
for _, objectName in pairs(_EXTERNAL_DEPENDENCIES) do
	assert(_G[objectName], "[CShortcutPieMenu] Fatal Error: " .. objectName .. " not found.")
end


-- ---------------------------------------------------------------------------------------
-- CT_SimpleAddonFramework: Simple Add-on Framework Template Class              rel.1.0.11
-- ---------------------------------------------------------------------------------------
local CT_SimpleAddonFramework = ZO_Object:Subclass()
function CT_SimpleAddonFramework:New(...)
	local newObject = setmetatable({}, self)
	newObject:Initialize(...)
	newObject:OnInitialized(...)
	return newObject
end
function CT_SimpleAddonFramework:Initialize(name, attributes)
	if type(name) ~= "string" or name == "" then return end
	self._name = name
	self._isInitialized = false
	if type(attributes) == "table" then
		for k, v in pairs(attributes) do
			if self[k] == nil then
				self[k] = v
			end
		end
	end
	self.authority = self.authority or {}
	self._class = {}
	self._shared = nil
	self._external = {
		name = self.name or self._name, 
		version = self.version, 
		author = self.author, 
		RegisterClassObject = function(_, ...) self:RegisterClassObject(...) end, 
	}
	assert(not _G[name], name .. " is already loaded.")
	_G[name] = self._external
	self:ConfigDebug()
	EVENT_MANAGER:RegisterForEvent(self._name, EVENT_ADD_ON_LOADED, function(event, addonName)
		if addonName ~= self._name then return end
		EVENT_MANAGER:UnregisterForEvent(self._name, EVENT_ADD_ON_LOADED)
		self:OnAddOnLoaded(event, addonName)
		self._isInitialized = true
	end)
end
function CT_SimpleAddonFramework:ConfigDebug(arg)
	local debugMode = false
	local key = HashString(GetDisplayName())
	if LibDebugLogger then
		for _, v in pairs(arg or self.authority or {}) do
			if key == v then debugMode = true end
		end
	end
	if debugMode then
		self._logger = self._logger or LibDebugLogger(self._name)
		self.LDL = self._logger
	else
		self.LDL = {
			Verbose = function() end, 
			Debug = function() end, 
			Info = function() end, 
			Warn = function() end, 
			Error = function() end, 
		}
	end
	self._isDebugMode = debugMode
end
function CT_SimpleAddonFramework:RegisterClassObject(className, classObject)
	if className and classObject and not self._class[className] then
		self._class[className] = classObject
		return true
	else
		return false
	end
end
function CT_SimpleAddonFramework:HasAvailableClass(className)
	if className then
		return self._class[className] ~= nil
	end
end
function CT_SimpleAddonFramework:CreateClassObject(className, ...)
	if className and self._class[className] then
		return self._class[className]:New(...)
	end
end
function CT_SimpleAddonFramework:OnInitialized(name, attributes)
--  Available when overridden in an inherited class
end
function CT_SimpleAddonFramework:OnAddOnLoaded(event, addonName)
--  Should be Overridden
end

-- ---------------------------------------------------------------------------------------
-- CT_AddonFramework: Add-on Framework Template Class for multiple modules      rel.1.0.11
-- ---------------------------------------------------------------------------------------
local CT_AddonFramework = CT_SimpleAddonFramework:Subclass()
function CT_AddonFramework:Initialize(name, attributes)
	CT_SimpleAddonFramework.Initialize(self, name, attributes)
	if not self._external then return end
	self._shared = {
		name = self._name, 
		version = self.version, 
		author = self.author, 
		LDL = self.LDL, 
		HasAvailableClass = function(_, ...) return self:HasAvailableClass(...) end, 
		CreateClassObject = function(_, ...) return self:CreateClassObject(...) end, 
		RegisterGlobalObject = function(_, ...) return self:RegisterGlobalObject(...) end, 
		RegisterSharedObject = function(_, ...) return self:RegisterSharedObject(...) end, 
		RegisterCallback = function(_, ...) return self:RegisterCallback(...) end, 
		UnregisterCallback = function(_, ...) return self:UnregisterCallback(...) end, 
		FireCallbacks = function(_, ...) return self:FireCallbacks(...) end, 
	}
	self._external.SetSharedEnvironment = function()
		-- This method is intended to be called in the main chunk and should not be called inside functions.
		self:EnableCustomEnvironment(self._env, 3)	-- [Main Chunk]: self._external:SetSharedEnvironment() -> self:EnableCustomEnvironment(t, 3) -> setfenv(3, t)
		return self._shared
	end
	self._external.FireCallbacks = function(_, ...) return self:FireCallbacks(...) end 
	if self._enableCallback then
		self._callbackObject = ZO_CallbackObject:New()
		self.RegisterCallback = function(self, ...)
			return self._callbackObject:RegisterCallback(...)
		end
		self.UnregisterCallback = function(self, ...)
			return self._callbackObject:UnregisterCallback(...)
		end
		self.FireCallbacks = function(self, ...)
			return self._callbackObject:FireCallbacks(...)
		end
	end
	if self._enableEnvironment then
		self:EnableCustomEnvironment(self._env, 4)	-- [Main Chunk]: self:New() -> self:Initialize() -> EnableCustomEnvironment(t, 4) -> setfenv(4, t)
	end
end
function CT_AddonFramework:ConfigDebug(arg)
	CT_SimpleAddonFramework.ConfigDebug(self, arg)
	if self._shared then
		self._shared.LDL = self.LDL
	end
end
function CT_AddonFramework:CreateCustomEnvironment(t, parent)	-- helper function
-- This method is intended to be called in the main chunk and should not be called inside functions.
	return setmetatable(type(t) == "table" and t or {}, { __index = type(parent) == "table" and parent or getfenv and type(getfenv) == "function" and getfenv(2) or _ENV or _G, })
end
function CT_AddonFramework:EnableCustomEnvironment(t, stackLevel)	-- helper function
	local stackLevel = type(stackLevel) == "number" and stackLevel > 1 and stackLevel or type(ZO_GetCallstackFunctionNames) == "function" and #(ZO_GetCallstackFunctionNames()) + 1 or 2
	local env = type(t) == "table" and t or type(self._env) == "table" and self._env
	if env then
		if setfenv and type(setfenv) == "function" then
			setfenv(stackLevel, env)
		else
			_ENV = env
		end
	end
end
function CT_AddonFramework:RegisterGlobalObject(objectName, globalObject)
	if objectName and globalObject and _G[objectName] == nil then
		_G[objectName] = globalObject
		return true
	else
		return false
	end
end
function CT_AddonFramework:RegisterSharedObject(objectName, sharedObject)
	if objectName and sharedObject and self._env and not self._env[objectName] then
		self._env[objectName] = sharedObject
		return true
	else
		return false
	end
end
function CT_AddonFramework:RegisterCallback(...)
-- stub: Method name reserved
end
function CT_AddonFramework:UnregisterCallback(...)
-- stub: Method name reserved
end
function CT_AddonFramework:FireCallbacks(...)
-- stub: Method name reserved
end


-- ---------------------------------------------------------------------------------------
-- CShortcutPieMenu
-- ---------------------------------------------------------------------------------------
local _SHARED_DEFINITIONS = {
	ActionNames = {
		"CSPM_PIE_MENU_INTERACTION", 
		"CSPM_PIE_MENU_SECONDARY", 
		"CSPM_PIE_MENU_TERTIARY", 
		"CSPM_PIE_MENU_QUATERNARY", 
		"CSPM_PIE_MENU_QUINARY", 
	}, 
	ActionNameAlias = {
		["CSPM_UIMODE_PIE_MENU_INTERACTION"]	= "CSPM_PIE_MENU_INTERACTION", 
		["CSPM_UIMODE_PIE_MENU_SECONDARY"]		= "CSPM_PIE_MENU_SECONDARY", 
		["CSPM_UIMODE_PIE_MENU_TERTIARY"]		= "CSPM_PIE_MENU_TERTIARY", 
		["CSPM_UIMODE_PIE_MENU_QUATERNARY"]		= "CSPM_PIE_MENU_QUATERNARY", 
		["CSPM_UIMODE_PIE_MENU_QUINARY"]		= "CSPM_PIE_MENU_QUINARY", 
	}, 
	ActionName_To_KeybindsId = {
		["CSPM_PIE_MENU_INTERACTION"]			= 1, 
		["CSPM_PIE_MENU_SECONDARY"]				= 2, 
		["CSPM_PIE_MENU_TERTIARY"]				= 3, 
		["CSPM_PIE_MENU_QUATERNARY"]			= 4, 
		["CSPM_PIE_MENU_QUINARY"]				= 5, 
		["CSPM_UIMODE_PIE_MENU_INTERACTION"]	= 1, 
		["CSPM_UIMODE_PIE_MENU_SECONDARY"]		= 2, 
		["CSPM_UIMODE_PIE_MENU_TERTIARY"]		= 3, 
		["CSPM_UIMODE_PIE_MENU_QUATERNARY"]		= 4, 
		["CSPM_UIMODE_PIE_MENU_QUINARY"]		= 5, 
	}, 
}
local LCPM = LibCPieMenu:SetSharedEnvironment()
local _ENV = CT_AddonFramework:CreateCustomEnvironment(_SHARED_DEFINITIONS)
local CSPM = CT_AddonFramework:New("CShortcutPieMenu", {
	name = "CShortcutPieMenu", 
	version = "1.5.3", 
	author = "Calamath", 
	savedVarsPieMenuEditor = "CShortcutPieMenuDB", 
	savedVarsPieMenuManager = "CShortcutPieMenuSV", 
	savedVarsVersion = 1, 
	authority = {2973583419,210970542}, 
	_env = _ENV, 
	_enableEnvironment = true, 
})
-- ---------------------------------------------------------------------------------------
local L = GetString
local LibCPieMenu = LibCPieMenu
local LibCInteraction = LibCInteraction

-- ---------------------------------------------------------------------------------------
-- CShortcutPieMenu savedata (default)
-- ---------------------------------------------------------------------------------------
-- PieMenu Slot
local CSPM_SLOT_DATA_DEFAULT = {
	type = ACTION_TYPE_NOTHING, 
	category = CATEGORY_NOTHING, 
	value = 0, 
} 

-- CShortcutPieMenu PieMenuEditor Config (AccountWide / User-customizable PieMenu Preset)
local CSPM_DB_DEFAULT = {
	preset = {
		[1] = {
			id = 1, 
			name = "", 
			menuItemsCount = MENU_ITEMS_COUNT_DEFAULT, 
			visual = {
				showIconFrame = true, 
				showSlotLabel = true, 
				showPresetName = false, 
				style = "gamepad", 
				size = 350, 
			}, 
			slot = {
				[1] = ZO_ShallowTableCopy(CSPM_SLOT_DATA_DEFAULT), 
				[2] = ZO_ShallowTableCopy(CSPM_SLOT_DATA_DEFAULT), 
			}, 
		}, 
	}, 
}

-- CShortcutPieMenu PieMenuManager Config
local CSPM_SV_DEFAULT = {
	accountWide = true, 
	menuAttributes = {
		allowActivateInUIMode = true, 
		allowClickable = true, 
		centeringAtMouseCursor = false, 
		timeToHoldKey = 250, 
		mouseDeltaScaleFactorInUIMode = 1, 
	}, 
	keybinds = {
		[1] = 1, 	-- Primary Action
		[2] = 0, 	-- Secondary Action
		[3] = 0, 	-- Tertiary Action
		[4] = 0, 	-- Quaternary Action
		[5] = 0, 	-- Quinary Action
	}, 
}

function CSPM:RegisterCallback(...)
	-- Since callback management has transferred to LibCPieMenu, we pass it to LibCPieMenu.
	return LCPM and LCPM.RegisterCallback and LCPM:RegisterCallback(...)
end

function CSPM:FireCallbacks(...)
	-- Since callback management has transferred to LibCPieMenu, we pass it to LibCPieMenu.
	return LCPM and LCPM.UnregisterCallback and LCPM:UnregisterCallback(...)
end

function CSPM:FireCallbacks(...)
	-- Since callback management has transferred to LibCPieMenu, we pass it to LibCPieMenu.
	return LCPM and LCPM.FireCallbacks and LCPM:FireCallbacks(...)
end

function CSPM:OnAddOnLoaded()
	self.lang = GetCVar("Language.2")
	self.isGamepad = IsInGamepadPreferredMode()

	-- PieMenuEditor Config (AccountWide / User-customizable PieMenu Preset)
	self.db = ZO_SavedVars:NewAccountWide(self.savedVarsPieMenuEditor, 1, nil, CSPM_DB_DEFAULT)
	self:ValidateConfigDataDB()

	-- PieMenuManager Config (Preset Allocation)
	self.svCurrent = {}
	self.svAccount = ZO_SavedVars:NewAccountWide(self.savedVarsPieMenuManager, 1, nil, CSPM_SV_DEFAULT, GetWorldName())
	self:ValidateConfigDataSV(self.svAccount)
	if self.svAccount.accountWide then
		self.svCurrent = self.svAccount
	else
		self.svCharacter = ZO_SavedVars:NewCharacterIdSettings(self.savedVarsPieMenuManager, 1, nil, CSPM_SV_DEFAULT, GetWorldName())
		self:ValidateConfigDataSV(self.svCharacter)
		self.svCurrent = self.svCharacter
	end

	-- Data Management
	self.shortcutDataManager = GetShortcutDataManager()
	self.pieMenuDataManager = GetPieMenuDataManager()
	self.pieMenuDataManager:RegisterUserPieMenuPresetTable(self.db.preset)

	-- UI Section
	self.activePresetId = 0
	self.topmostPieMenu = nil
--	self.rootMenu = self:CreateClassObject("PieMenuController", CSPM_UI_Root_Pie, "CSPM_SelectableItemRadialMenuEntryTemplate", "CSPM_RadialMenuAnimation", "SelectableItemRadialMenuEntryAnimation", self.svCurrent.menuAttributes)
	self.rootMenu = LibCPieMenu:CreatePieMenuController(CSPM_UI_Root_Pie, self.svCurrent.menuAttributes)
	self.rootMenu:SetOnSelectionChangedCallback(function(...) self:OnSelectionChangedCallback(...) end)
	self.rootMenu:SetPopulateMenuCallback(function(...) self:PopulateMenuCallback(...) end)
	self:RegisterInteraction(self.rootMenu)

	self.menuEditorPanel = self:CreateClassObject("PieMenuEditorPanel", "CSPM_lamOptionsMenuEditor", self.db, self.db, CSPM_DB_DEFAULT)
	self.menuManagerPanel = self:CreateClassObject("PieMenuManagerPanel", "CSPM_lamOptionsManager", self.svCurrent, self.svAccount, CSPM_SV_DEFAULT)

	-- Events
	self:RegisterEvents()

	-- Bindings
	self:InitializeKeybinds()

	-- Interaction
	self.holdDownInteractionKey = false
	self.requestedPresetId = 0

	-- API
	self:InitializeAPI()

	self.LDL:Debug("Initialized")
end

function CSPM:ValidateConfigDataDB()
	for k, v in pairs(self.db.preset) do
		if v.id == nil								then v.id = k 														end
		if v.name == nil							then v.name = ""													end
		if v.menuItemsCount == nil					then v.menuItemsCount = MENU_ITEMS_COUNT_DEFAULT					end
		if v.visual == nil							then v.visual = {}													end
		if v.visual.showIconFrame == nil			then v.visual.showIconFrame			= CSPM_DB_DEFAULT.preset[1].visual.showIconFrame			end
		if v.visual.showSlotLabel == nil			then v.visual.showSlotLabel			= CSPM_DB_DEFAULT.preset[1].visual.showSlotLabel			end
		if v.visual.showPresetName == nil			then v.visual.showPresetName		= CSPM_DB_DEFAULT.preset[1].visual.showPresetName			end
		if v.visual.style == nil					then v.visual.style					= CSPM_DB_DEFAULT.preset[1].visual.style					end
		if v.visual.size == nil						then v.visual.size					= CSPM_DB_DEFAULT.preset[1].visual.size						end
		if v.slot == nil							then v.slot = ZO_ShallowTableCopy(CSPM_DB_DEFAULT.prest[1].slot)	end

		-- migrate to the new format	(Ver.0.10.2)
		if v.visual.showTrackGamepad ~= nil			then v.visual.style 				= (v.visual.showTrackGamepad == true) and "gamepad" or "quickslot"		v.visual.showTrackGamepad = nil		v.visual.showTrackQuickslot = nil		end
	end
end

function CSPM:ValidateConfigDataSV(sv)
	if sv.accountWide == nil						then sv.accountWide						= CSPM_SV_DEFAULT.accountWide 								end
	if sv.menuAttributes == nil						then sv.menuAttributes					= ZO_ShallowTableCopy(CSPM_SV_DEFAULT.menuAttributes)		end
	for i = 1, #CSPM_SV_DEFAULT.keybinds do
		if sv.keybinds[i] == nil					then sv.keybinds[i]						= CSPM_SV_DEFAULT.keybinds[i]								end
	end

	-- migrate to the new format	(Ver.0.10.2)
	if sv.allowActivateInUIMode ~= nil				then sv.menuAttributes.allowActivateInUIMode			= sv.allowActivateInUIMode				sv.allowActivateInUIMode = nil			 end
	if sv.allowClickable ~= nil						then sv.menuAttributes.allowClickable 					= sv.allowClickable						sv.allowClickable = nil					 end
	if sv.centeringAtMouseCursor ~= nil				then sv.menuAttributes.centeringAtMouseCursor		 	= sv.centeringAtMouseCursor				sv.centeringAtMouseCursor = nil			 end
	if sv.timeToHoldKey ~= nil						then sv.menuAttributes.timeToHoldKey 					= sv.timeToHoldKey						sv.timeToHoldKey = nil					 end
	if sv.mouseDeltaScaleFactorInUIMode ~= nil		then sv.menuAttributes.mouseDeltaScaleFactorInUIMode	= sv.mouseDeltaScaleFactorInUIMode		sv.mouseDeltaScaleFactorInUIMode = nil	 end
end

function CSPM:RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(event, initial)
		EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED)		-- Only after the first login/reloadUI.
	
		-- UI setting panel initialization
		self.menuEditorPanel:InitializeSettingPanel()
		self.menuManagerPanel:InitializeSettingPanel()
	end)
end

function CSPM:CopyKeybinds(sourceActionName, destActionName)
	local layer, category, action = GetActionIndicesFromName(destActionName)
	if layer and category and action then
		if IsProtectedFunction("UnbindAllKeysFromAction") then
			CallSecureProtected("UnbindAllKeysFromAction", layer, category, action)
		else
			UnbindAllKeysFromAction(layer, category, action)
		end
	else
		return
	end
	layer, category, action = GetActionIndicesFromName(sourceActionName)
	if layer and category and action then
		for i = 1, GetMaxBindingsPerAction() do
			local key, mod1, mod2, mod3, mod4 = GetActionBindingInfo(layer, category, action, i)
			CreateDefaultActionBind(destActionName, key, mod1, mod2, mod3, mod4)
		end
	else
		return
	end
	if self.keybinds then
		self.keybinds[sourceActionName] = destActionName
	end
	return true
end

function CSPM:ResetObsoleteKeybinds()
	local ObsoleteActionNames = {
		"CSPM_KEY_MOUSE_LEFT", 
		"CSPM_KEY_MOUSE_LEFTRIGHT", 
		"CSPM_KEY_MOUSE_MIDDLE", 
		"CSPM_KEY_MOUSE_RIGHT", 
		"CSPM_KEY_MOUSEWHEEL_DOWN", 
		"CSPM_KEY_MOUSEWHEEL_UP", 
		"CSPM_KEY_MOUSE_4", 
		"CSPM_KEY_MOUSE_5", 
		"CSPM_KEY_GAMEPAD_BUTTON_1", 
		"CSPM_KEY_GAMEPAD_BUTTON_2", 
		"CSPM_KEY_GAMEPAD_BUTTON_3", 
		"CSPM_KEY_GAMEPAD_BUTTON_4", 
	}
	for _, actionName in pairs(ObsoleteActionNames) do
		local layer, category, action = GetActionIndicesFromName(actionName)
		if layer and category and action then
			if IsProtectedFunction("UnbindAllKeysFromAction") then
				CallSecureProtected("UnbindAllKeysFromAction", layer, category, action)
			else
				UnbindAllKeysFromAction(layer, category, action)
			end
		end
	end
end

function CSPM:InitializeKeybinds()
	self.keybinds = self.keybinds or {}
	for destActionName, sourceActionName in pairs(ActionNameAlias) do
		self:CopyKeybinds(sourceActionName, destActionName)
	end
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_KEYBINDING_CLEARED, function(event, layerIndex, categoryIndex, actionIndex, bindingIndex)
		local actionName = GetActionInfo(layerIndex, categoryIndex, actionIndex)
		if self.keybinds[actionName] then
			self:CopyKeybinds(actionName, self.keybinds[actionName])	-- Rebuild due to setting changes
		end
	end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_KEYBINDING_SET, function(event, layerIndex, categoryIndex, actionIndex, bindingIndex)
		local actionName = GetActionInfo(layerIndex, categoryIndex, actionIndex)
		if self.keybinds[actionName] then
			self:CopyKeybinds(actionName, self.keybinds[actionName])	-- Rebuild due to setting changes
		end
	end)

	--  In previous versions, we had set key bindings for these actions, so we try to unbind to restore custom keybinds slots.
	self:ResetObsoleteKeybinds()
end

function CSPM:RegisterInteraction(pieMenu)
	if not pieMenu then return end
	local pieMenuHoldInteraction = {
		type = "hold", 
		enabled = function()
			return not pieMenu:IsInteracting() and pieMenu:PrepareForInteraction()
		end, 
		multipleInput = true, 
		keyDownCallback = function(interaction, presetId)
			interaction.presetId = presetId
		end, 
		holdTime = function()
			return self.svCurrent.menuAttributes.timeToHoldKey
		end, 
		startedCallback = function(interaction)
			self.holdDownInteractionKey = true
			self.requestedPresetId = interaction.presetId
		end, 
		endedCallback = function(interaction)
			if interaction.isPerformed then
				pieMenu:StopInteraction(false)
				self:ClearActivePresetId()
				self:SetTopmostPieMenu(nil)
			end
			interaction.presetId = 0
			self.holdDownInteractionKey = false
			self.requestedPresetId = 0
		end, 
		performedCallback = function()
			if not pieMenu:IsInteracting() then
				self:SetActivePresetId(self.requestedPresetId)
				pieMenu:ShowMenu()
				self:SetTopmostPieMenu(pieMenu)
			end
		end, 
		canceledCallback = function()
			self.holdDownInteractionKey = false
			self.requestedPresetId = 0
		end, 
	}
	pieMenu.interactions = pieMenu.interactions or {}
	table.insert(pieMenu.interactions, LibCInteraction:RegisterInteraction(ActionNames, pieMenuHoldInteraction))

	pieMenu:RegisterBindings(KEY_GAMEPAD_BUTTON_1, function(menu) menu:SelectCurrentEntry() end)
	pieMenu:RegisterBindings(KEY_GAMEPAD_BUTTON_2, function(menu) menu:CancelInteraction() end)
	pieMenu:RegisterBindings(KEY_ESCAPE, function(menu) menu:ForceExitInteraction() end)
	pieMenu:RegisterBindings(KEY_MOUSE_LEFT, function(menu) menu:SelectCurrentEntry() end)
	pieMenu:RegisterBindings(KEY_MOUSE_RIGHT, function(menu) menu:CancelInteraction() end)
end

function CSPM:GetActivePresetId()
	return self.activePresetId
end

function CSPM:SetActivePresetId(presetId)
	self.activePresetId = presetId
end

function CSPM:ClearActivePresetId()
	self.activePresetId = 0
end

function CSPM:GetTopmostPieMenu()
	return self.topmostPieMenu
end

function CSPM:SetTopmostPieMenu(pieMenu)
	self.topmostPieMenu = pieMenu
end


function CSPM:OnSelectionChangedCallback(menu, slotIndex, data)
--	self.LDL:Debug("OnSelectionChangedCallback() : %s", slotIndex)
end

function CSPM:AddMenuEntry(pieMenu, name, inactiveIcon, activeIcon, callback, data)
	if pieMenu and pieMenu.AddMenuEntry then
		pieMenu:AddMenuEntry(name, inactiveIcon, activeIcon, callback, data)
	end
end

function CSPM:AddMenuEntryWithShortcut(pieMenu, shortcutId, visualData)
	-- pieMenu    : (required) CSPM_PieMenuController class object
	-- shortcutId : (required) registered shortcutId for Shortcut Manager
	-- visualData : (optional) nilable PieMenu visual data table to reference if not specified in shortcut data.
	--		visualData.showIconFrame : boolean - whether to show the icon frame texture.
	--		visualData.showSlotLabel : boolean - whether to show the slot display name label.
	local shortcutId = shortcutId or "!CSPM_invalid_slot"
	local shortcutData = GetShortcutData(shortcutId) or GetShortcutData("!CSPM_invalid_slot")
	if pieMenu and pieMenu.AddMenuEntry then
		local data = self.shortcutDataManager:EncodeMenuEntry(shortcutData, pieMenu:GetNumMenuEntries() + 1)
		-- fail safe
		if data.showIconFrame == nil then
			if visualData then
				data.showIconFrame = visualData.showIconFrame
			else
				data.showIconFrame = CSPM_DB_DEFAULT.preset[1].visual.showIconFrame
			end
		end
		if data.showSlotLabel == nil then
			if visualData then
				data.showSlotLabel = visualData.showSlotLabel
			else
				data.showSlotLabel = CSPM_DB_DEFAULT.preset[1].visual.showIconFrame
			end
		end
		data.slotData.type = data.slotData.type or ACTION_TYPE_SHORTCUT
		data.slotData.category = data.slotData.category or CATEGORY_NOTHING
		data.slotData.value = data.slotData.value or shortcutId

		local entryName = (data.nameColor and type(data.nameColor) == "table") and { data.name, { r = data.nameColor[1], g = data.nameColor[2], b = data.nameColor[3], }, } or data.name
		pieMenu:AddMenuEntry(entryName, data.icon, data.activeIcon, function() return self:OnSelectionExecutionCallback(data) end, data)
	end
end

function CSPM:PopulateMenuCallback(pieMenu)
--	self.LDL:Debug("PopulateMenuCallback()")
	local presetId = self:GetActivePresetId()
	local presetData = self.pieMenuDataManager:GetPieMenuData(presetId)
	if type(presetData) ~= "table" then return end

	local visualData = presetData.visual or {}
	pieMenu:SetupPieMenuPresetName(presetData.name, visualData.showPresetName)
	pieMenu:SetupPieMenuVisual(visualData.style, visualData.size)

	for i = 1, GetValue(presetData.menuItemsCount) do
		local actionType = ACTION_TYPE_NOTHING
		local cspmCategoryId = CATEGORY_NOTHING
		local actionValue = 0
		local data = {}
		local isValid = false
		if type(presetData.slot[i]) == "table" then
			actionType = GetActionType(presetData.slot[i].type)
			cspmCategoryId = GetValue(presetData.slot[i].category)
			actionValue = GetValue(presetData.slot[i].value) or 0
			if actionType == ACTION_TYPE_SHORTCUT then
				if type(actionValue) == "string" then
					data = self.shortcutDataManager:EncodeMenuEntry(actionValue, i)
				else
					data = self.shortcutDataManager:EncodeMenuEntry(presetData.slot[i], i)	-- for embedded shortcut data
				end
			else
				data = {
					index = i, 
					itemCount = nil, 
					statusIcon = nil, 
					activeStatusIcon = nil, 
				}
				data.name, data.nameColor = GetDefaultSlotName(actionType, cspmCategoryId, actionValue)
				data.icon = GetDefaultSlotIcon(actionType, cspmCategoryId, actionValue)
				data.activeIcon = data.icon
			end
			if data.showIconFrame == nil then
				data.showIconFrame = visualData.showIconFrame
			end
			if data.showSlotLabel == nil then
				data.showSlotLabel = visualData.showSlotLabel
			end
			isValid = data.name ~= ""
		end

		if actionType == ACTION_TYPE_COLLECTIBLE then
			if IsCollectibleActive(actionValue, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
				data.statusIcon = UI_Icon.CHECK
			elseif GetCollectibleUnlockStateById(actionValue) == COLLECTIBLE_UNLOCK_STATE_LOCKED or IsCollectibleBlocked(actionValue) then
				data.statusIcon = UI_Icon.BLOCKED
				data.iconAttributes = { iconDesaturation = 1, }
			end
			data.cooldownRemaining, data.cooldownDuration  = GetCollectibleCooldownAndDuration(actionValue)
		end
		if actionType == ACTION_TYPE_TRAVEL_TO_HOUSE and actionValue == ACTION_VALUE_PRIMARY_HOUSE_ID then
			-- override the display name and icon according to the current primary house setting.
			local primaryHouseId = GetHousingPrimaryHouse()
			if primaryHouseId ~= 0 then
				local primaryHouseName = zo_strformat(L(SI_HOUSING_BOOK_PRIMARY_RESIDENCE_FORMATTER), GetCollectibleName(GetCollectibleIdForHouse(primaryHouseId)))		-- "Primary Residence: |cffffff<<1>>|r"
				if cspmCategoryId == CATEGORY_H_UNLOCKED_HOUSE_INSIDE then
					data.name = zo_strformat(L(SI_GAMEPAD_WORLD_MAP_TRAVEL_TO_HOUSE_INSIDE), primaryHouseName)		-- "<<1>> (inside)"
				elseif cspmCategoryId == CATEGORY_H_UNLOCKED_HOUSE_OUTSIDE then
					data.name = zo_strformat(L(SI_GAMEPAD_WORLD_MAP_TRAVEL_TO_HOUSE_OUTSIDE), primaryHouseName)	-- "<<1>> (outside)"
				end
				data.icon = GetCollectibleIcon(GetCollectibleIdForHouse(primaryHouseId))
				data.activeIcon = data.icon
			end
		end
		if actionType == ACTION_TYPE_PIE_MENU then
			local selectionButton = IsInGamepadPreferredMode() and UI_Icon.GAMEPAD_1 or UI_Icon.MOUSE_LMB
			data.activeStatusIcon = { selectionButton, selectionButton, }	-- for blinking icon
			-- override the display name of user pie menu according to its user defined preset name.
			local pieMenuName = GetPieMenuInfo(actionValue)
			if IsUserPieMenu(actionValue) and pieMenuName and pieMenuName ~= "" then
				data.name = zo_strformat(L(SI_CSPM_PRESET_NAME_FORMATTER), actionValue, pieMenuName)
			end
		end

		if isValid then
			if IsUserPieMenu(presetId) then
				data.slotData = presetData.slot[i] or {}
				-- override the display name, if slot name data exists
				local replacementName = GetValue(data.slotData.name)
				if type(replacementName) == "string" and replacementName ~= "" then
					data.name = replacementName
				end
				-- override the icon, if slot icon data exists
				local replacementIcon = GetValue(data.slotData.icon)
				if type(replacementIcon) == "string" and replacementIcon ~= "" then
					data.icon = replacementIcon
					data.activeIcon = replacementIcon
					data.resizeIconToFitFile = nil
				end
			end
			local entryName = (data.nameColor and type(data.nameColor) == "table") and { data.name, { r = data.nameColor[1], g = data.nameColor[2], b = data.nameColor[3], }, } or data.name
			self:AddMenuEntry(pieMenu, entryName, data.icon, data.activeIcon, function() return self:OnSelectionExecutionCallback(data) end, data)
		else
			self:AddMenuEntryWithShortcut(pieMenu, "!CSPM_invalid_slot_thus_open_piemenu_editor", visualData)
		end
	end

	-- Entry Cancel Slot
	if not presetData.suppressCancelSlot then
		self:AddMenuEntryWithShortcut(pieMenu, "!CSPM_cancel_slot", visualData)
	end
end
-- ------------------------------------------------

do
	local ExecuteSlotAction = {		-- you cannot use 'self' within this block.
		[ACTION_TYPE_NOTHING] = function(actionTypeId, categoryId, actionValue, data)
			return
		end, 
		[ACTION_TYPE_COLLECTIBLE] = function(_, _, actionValue, _)
			-- actionValue : collectibleId
			if actionValue > 0 then
				UseCollectible(actionValue, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
			end
		end, 
		[ACTION_TYPE_EMOTE] = function(_, _, actionValue, _)
			-- actionValue : emoteId
			if actionValue > 0 then
				local emoteIndex = GetEmoteIndex(actionValue)
				if emoteIndex then
					PlayEmoteByIndex(emoteIndex)
				end
			end
		end, 
		[ACTION_TYPE_CHAT_COMMAND] = function(_, _, actionValue, _)
			-- actionValue : chatCommandString
			local command, args = string.match(actionValue, "^(%S+)% *(.*)")
			CSPM.LDL:Debug("chat command : %s, argments : %s", tostring(command), tostring(args))
			if SLASH_COMMANDS[command] then
				SLASH_COMMANDS[command](args)
			else
				df("[CSPM] error : slash command '%s' not found", tostring(command))
			end
		end, 
		[ACTION_TYPE_TRAVEL_TO_HOUSE] = function(_, categoryId, actionValue, _)
			-- actionValue : houseId
			local houseId = actionValue
			local jumpOutside = false
			if actionValue == ACTION_VALUE_PRIMARY_HOUSE_ID then
				houseId = GetHousingPrimaryHouse()
			end
			if categoryId == CATEGORY_H_UNLOCKED_HOUSE_OUTSIDE then
				jumpOutside = true
			end
			RequestJumpToHouse(houseId, jumpOutside)
		end, 
		[ACTION_TYPE_PIE_MENU] = function(_, _, actionValue, _)
			-- actionValue : presetId
			if CSPM.holdDownInteractionKey then
				CSPM:ChangeTopmostPieMenu(actionValue)
				return true	-- If the callback returns true it means that the callback requested continuous processing.
			else
				d("At the moment, opening the nested pie menu only works when you perform a selection with the mouse or gamepad.")
			end
		end, 
		[ACTION_TYPE_SHORTCUT] = function(_, _, actionValue, data)
			-- actionValue : shortcutId
			local shortcutData = GetShortcutData(actionValue)
			if shortcutData and type(shortcutData.callback) == "function" then
				shortcutData.callback(data)
			end
		end, 
	}
	setmetatable(ExecuteSlotAction, { __index = function(self, key) return rawget(self, ACTION_TYPE_NOTHING) end, })

	function CSPM:OnSelectionExecutionCallback(data)
		local slotData = data.slotData or {}
		local actionType = GetActionType(slotData.type)
		local cspmCategoryId = GetValue(slotData.category)
		local actionValue = GetValue(slotData.value) or 0

		if data.callback and type(data.callback) == "function" then
			return data.callback(data)	-- for embedded shortcut data
		else
			return ExecuteSlotAction[actionType](actionType, cspmCategoryId, actionValue, data)
		end
	end
end


function CSPM:HandleKeybindDown(actionName)
	self.LDL:Debug("HandleKeybindDown: %s", tostring(actionName))
	local actionName = ActionNameAlias[actionName] or actionName	-- There are multiple action layers for activating the root pie menu, but we will consolidate them here.
	local keybindsId = ActionName_To_KeybindsId[actionName or ""]
	local presetId = self.svCurrent.keybinds[keybindsId or 0]
	if presetId and presetId ~= 0 and DoesPieMenuDataExist(presetId) then
		LibCInteraction:HandleKeybindDown(actionName, presetId)
	end
end

--[[
function CSPM:StartRootPieMenuInteraction(presetId, actionName)
	local actionName = 
	self.LDL:Debug("TryStartingRootPieMenuInteraction(%s)", tostring(presetId))
	if presetId ~= 0 and DoesPieMenuDataExist(presetId) then
		self.rootMenu:SetAllowActivateInUIMode(self.svCurrent.allowActivateInUIMode)
		self.rootMenu:SetCenteringAtMouseCursor(self.svCurrent.centeringAtMouseCursor)
		self.rootMenu:SetAllowClickable(self.svCurrent.allowClickable)
		self.rootMenu:SetTimeToHoldKey(self.svCurrent.timeToHoldKey)
		self.rootMenu:SetMouseDeltaScaleFactorInUIMode(self.svCurrent.mouseDeltaScaleFactorInUIMode)
		LibCInteraction:HandleKeybindDown(actionName, presetId)
	end
end
]]


function CSPM:HandleKeybindUp(actionName)
	self.LDL:Debug("HandleKeybindUp: %s", tostring(actionName))
	local actionName = ActionNameAlias[actionName] or actionName	-- There are multiple action layers for activating the root pie menu, but we will consolidate them here.
	local keybindsId = ActionName_To_KeybindsId[actionName or ""]
	local presetId = self.svCurrent.keybinds[keybindsId or 0]
	if presetId and presetId ~= 0 and DoesPieMenuDataExist(presetId) then
		LibCInteraction:HandleKeybindUp(actionName)
	end
end

function CSPM:ChangeTopmostPieMenu(newPresetId)
	local pieMenu = self:GetTopmostPieMenu()
	if pieMenu then
		if newPresetId and newPresetId ~= 0 and DoesPieMenuDataExist(newPresetId) then
			self:SetActivePresetId(newPresetId)
			pieMenu:RefreshMenu()
			return true
		end
	end
end

function CSPM:EndPieMenuInteraction(pieMenu, clearSelection)
-- pieMenu : pieMenuController object
	self.LDL:Debug("EndPieMenuInteraction(%s)", tostring(clearSelection))
	if pieMenu then
		pieMenu:StopInteraction(clearSelection)
		self:ClearActivePresetId()
		for k, interaction in pairs(pieMenu.interactions) do
			interaction:Reset()
		end
	end
end

function CSPM:CancelPieMenuInteraction(pieMenu)
	self:EndPieMenuInteraction(pieMenu, true)
end

function CSPM:InitializeAPI()

	-- Bindings
	self._external.HandleKeybindDown = function(_, actionName, ...)
		return self:HandleKeybindDown(actionName, ...)
	end
	self._external.HandleKeybindUp = function(_, actionName, ...)
		return self:HandleKeybindUp(actionName, ...)
	end


	-- APIs
	self._external.GetActivePresetId = function()
		return self.activePresetId
	end

	self._external.OpenPieMenuEditorPanel = function(_, presetId, slotId)
		self.menuEditorPanel:OpenSettingPanel(presetId, slotId)
	end

	self._external.OpenPieMenuManagerPanel = function()
		self.menuManagerPanel:OpenSettingPanel()
	end
end


-- ---------------------------------------------------------------------------------------
-- Chat commands
-- ---------------------------------------------------------------------------------------
SLASH_COMMANDS["/cspm.debug"] = function(arg) if arg ~= "" then CSPM:ConfigDebug({tonumber(arg)}) end end
