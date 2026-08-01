--
-- CPieMenuManager [LCPM] : (LibCPieMenu)
--
-- Copyright (c) 2022 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--
-- Note :
-- This addon works that uses the library LibCInteraction by Calamath, released under the Artistic License 2.0
--

-- ---------------------------------------------------------------------------------------
-- Checking dependencies
-- ---------------------------------------------------------------------------------------
local _EXTERNAL_DEPENDENCIES = {
	"LibCInteraction", 
}
for _, objectName in pairs(_EXTERNAL_DEPENDENCIES) do
	assert(_G[objectName], "[LibCPieMenu] Fatal Error: " .. objectName .. " not found.")
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
-- CPieMenuManager (LibCPieMenu)
-- ---------------------------------------------------------------------------------------
local _SHARED_DEFINITIONS = {
	UI_NONE									= 0, 
	UI_OPEN									= 1, 
	UI_CLOSE								= 2, 
	UI_COPY									= 3, 
	UI_PASTE								= 4, 
	UI_CLEAR								= 5, 
	UI_RESET								= 6, 
	UI_PREVIEW								= 7, 
	UI_SELECT								= 8, 
	UI_CANCEL								= 9, 
	UI_EXECUTE								= 10, 

	MAX_USER_PRESET							= 10, 
	MENU_ITEMS_COUNT_DEFAULT				= 2, 
	ACTION_TYPE_NOTHING						= 0, 
	ACTION_TYPE_COLLECTIBLE					= 1, 
	ACTION_TYPE_EMOTE						= 2, 
	ACTION_TYPE_CHAT_COMMAND				= 3, 
	ACTION_TYPE_TRAVEL_TO_HOUSE				= 4, 
	ACTION_TYPE_PIE_MENU					= 5, 
	ACTION_TYPE_SHORTCUT					= 6, 
	ACTION_TYPE_COLLECTIBLE_APPEARANCE		= 11, 	-- alias of ACTION_TYPE_COLLECTIBLE
	ACTION_TYPE_SHORTCUT_ADDON				= 16, 	-- alias of ACTION_TYPE_SHORTCUT
	CATEGORY_NOTHING						= 0, 
	CATEGORY_IMMEDIATE_VALUE				= 1, 
	CATEGORY_C_ASSISTANT					= 11, 
	CATEGORY_C_COMPANION					= 12, 
	CATEGORY_C_MEMENTO						= 13, 
	CATEGORY_C_VANITY_PET					= 14, 
	CATEGORY_C_MOUNT						= 15, 
	CATEGORY_C_PERSONALITY					= 16, 
	CATEGORY_C_ABILITY_SKIN					= 17, 
	CATEGORY_C_TOOL							= 18, 
	CATEGORY_E_CEREMONIAL					= 31, 
	CATEGORY_E_CHEERS_AND_JEERS				= 32, 
	CATEGORY_E_EMOTION						= 33, 
	CATEGORY_E_ENTERTAINMENT				= 34, 
	CATEGORY_E_FOOD_AND_DRINK				= 35, 
	CATEGORY_E_GIVE_DIRECTIONS				= 36, 
	CATEGORY_E_PHYSICAL						= 37, 
	CATEGORY_E_POSES_AND_FIDGETS			= 38, 
	CATEGORY_E_PROP							= 39, 
	CATEGORY_E_SOCIAL						= 40, 
	CATEGORY_E_COLLECTED					= 41, 
	CATEGORY_H_UNLOCKED_HOUSE_INSIDE		= 51, 
	CATEGORY_H_UNLOCKED_HOUSE_OUTSIDE		= 52, 
	CATEGORY_P_OPEN_USER_PIE_MENU			= 61, 
	CATEGORY_P_OPEN_EXTERNAL_PIE_MENU		= 62, 
	CATEGORY_S_PIE_MENU_ADDON				= 71, 
	CATEGORY_S_MAIN_MENU					= 72, 
	CATEGORY_S_SYSTEM_MENU					= 73, 
	CATEGORY_S_USEFUL_SHORTCUT				= 74, 
	CATEGORY_C_HAT							= 81, 
	CATEGORY_C_HAIR							= 82, 
	CATEGORY_C_HEAD_MARKING					= 83, 
	CATEGORY_C_FACIAL_HAIR_HORNS			= 84, 
	CATEGORY_C_FACIAL_ACCESSORY				= 85, 
	CATEGORY_C_PIERCING_JEWELRY				= 86, 
	CATEGORY_C_COSTUME						= 87, 
	CATEGORY_C_BODY_MARKING					= 88, 
	CATEGORY_C_SKIN							= 89, 
	CATEGORY_C_POLYMORPH					= 90, 
	ACTION_VALUE_PRIMARY_HOUSE_ID			= -1, 
}
local _ENV = CT_AddonFramework:CreateCustomEnvironment(_SHARED_DEFINITIONS)
CT_AddonFramework:EnableCustomEnvironment(_ENV)


local CPieMenuManager = CT_AddonFramework:Subclass()
function CPieMenuManager:OnInitialized()
	self.activePresetId = 0
	self.topmostPieMenu = nil

	self:InitializeAPI()
end

function CPieMenuManager:OnAddOnLoaded()
	local LCPM_HUD_Interceptor_ActionNames = {
		["LCPM_HUD_KEY_MOUSE_LEFT"] = { KEY_MOUSE_LEFT, }, 
		["LCPM_HUD_KEY_MOUSE_LEFTRIGHT"] = { KEY_MOUSE_LEFTRIGHT, }, 
		["LCPM_HUD_KEY_MOUSE_MIDDLE"] = { KEY_MOUSE_MIDDLE, }, 
		["LCPM_HUD_KEY_MOUSE_RIGHT"] = { KEY_MOUSE_RIGHT, }, 
		["LCPM_HUD_KEY_MOUSEWHEEL_DOWN"] = { KEY_MOUSEWHEEL_DOWN, }, 
		["LCPM_HUD_KEY_MOUSEWHEEL_UP"] = { KEY_MOUSEWHEEL_UP, }, 
		["LCPM_HUD_KEY_MOUSE_4"] = { KEY_MOUSE_4, }, 
		["LCPM_HUD_KEY_MOUSE_5"] = { KEY_MOUSE_5, }, 
		["LCPM_HUD_KEY_GAMEPAD_BUTTON_1"] = { KEY_GAMEPAD_BUTTON_1, }, 
		["LCPM_HUD_KEY_GAMEPAD_BUTTON_2"] = { KEY_GAMEPAD_BUTTON_2, }, 
		["LCPM_HUD_KEY_GAMEPAD_BUTTON_3"] = { KEY_GAMEPAD_BUTTON_3, }, 
		["LCPM_HUD_KEY_GAMEPAD_BUTTON_4"] = { KEY_GAMEPAD_BUTTON_4, }, 
	}
	-- Data Management
	self.shortcutDataManager = GetShortcutDataManager()
	self.pieMenuDataManager = GetPieMenuDataManager()

	-- Pie Menu Action Layer Keybindings
	for actionName, v in pairs(LCPM_HUD_Interceptor_ActionNames) do
		local layer, category, action = GetActionIndicesFromName(actionName)
		if layer and category and action then
			if IsProtectedFunction("UnbindAllKeysFromAction") then
				CallSecureProtected("UnbindAllKeysFromAction", layer, category, action)
			else
				UnbindAllKeysFromAction(layer, category, action)
			end
			CreateDefaultActionBind(actionName, v[1], v[2], v[3], v[4], v[5])
		end
	end
end

function CPieMenuManager:GetActivePresetId()
	return self.activePresetId
end

function CPieMenuManager:SetActivePresetId(presetId)
	self.activePresetId = presetId
end

function CPieMenuManager:ClearActivePresetId()
	self.activePresetId = 0
end

function CPieMenuManager:GetTopmostPieMenu()
	return self.topmostPieMenu
end

function CPieMenuManager:SetTopmostPieMenu(pieMenu)
	self.topmostPieMenu = pieMenu
end

function CPieMenuManager:CreatePieMenuController(control, overriddenAttrib)
	return self:CreateCustomPieMenuController(control, "LCPM_SelectableItemRadialMenuEntryTemplate", "LCPM_RadialMenuAnimation", "SelectableItemRadialMenuEntryAnimation", overriddenAttrib)
end

function CPieMenuManager:CreateCustomPieMenuController(control, entryTemplate, animationTemplate, entryAnimationTemplate, overriddenAttrib)
	local pieMenu = self:CreateClassObject("PieMenuController", control, entryTemplate, animationTemplate, entryAnimationTemplate, overriddenAttrib)
	return pieMenu
end

function CPieMenuManager:InitializeAPI()
	-- Removing unnecessary APIs
--	self._external.RegisterClassObject = nil

--
-- ---- LibCPieMenu API Reference
--
-- * LibCPieMenu:CreatePieMenuController(control, overriddenAttrib)
-- ** _Returns:_ *table* _pieMenuController_
	self._external.CreatePieMenuController = function(_, ...)
		return self:CreatePieMenuController(...)
	end

-- * LibCPieMenu:RegisterPieMenu(*string* _presetId_, *table* _pieMenuData)
-- NOTE: The first character of the presetId must begin with something other than an exclamation mark. (! : exclamation mark)
	self._external.RegisterPieMenu = function(_, presetId, pieMenuData)
		local pieMenuDataManager = self.pieMenuDataManager or GetPieMenuDataManager()
		return pieMenuDataManager:RegisterExternalPieMenu(presetId, pieMenuData)
	end
end


-- ---------------------------------------------------------------------------------------
-- Name Space
-- ---------------------------------------------------------------------------------------
local PIE_MENU_MANAGER = CPieMenuManager:New("LibCPieMenu", {
	name = "LibCPieMenu", 
	version = "1.5.3", 
	author = "Calamath", 
	authority = {2973583419,210970542}, 
	_env = _ENV, 
	_enableCallback = true, 
})

