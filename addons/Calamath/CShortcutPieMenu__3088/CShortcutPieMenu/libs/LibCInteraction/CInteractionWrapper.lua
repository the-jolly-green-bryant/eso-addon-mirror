--
-- CInteractionWrapperManager [CIWM] : (LibCInteraction)
--
-- Copyright (c) 2022 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

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
-- CInteractionWrapperManager (LibCInteraction)
-- ---------------------------------------------------------------------------------------
-- This class provides a generic framework for detecting specific input patterns based on down/up events of keybinding actions.
--
local IsModifierKeyDown = {
	[KEY_CTRL] = function() return IsControlKeyDown() end, 
	[KEY_ALT] = function() return IsAltKeyDown() end, 
	[KEY_SHIFT] = function() return IsShiftKeyDown() end, 
	[KEY_COMMAND] = function() return IsCommandKeyDown() end, 
	[KEY_GAMEPAD_LEFT_TRIGGER] = function() return GetGamepadLeftTriggerMagnitude() > 0.2 end, 
	[KEY_GAMEPAD_RIGHT_TRIGGER] = function() return GetGamepadRightTriggerMagnitude() > 0.2 end, 
}
local CInteractionWrapperManager = CT_SimpleAddonFramework:Subclass()
function CInteractionWrapperManager:OnInitialized()
	self.timerLender = WINDOW_MANAGER:CreateControl("CIWM_UI_TimerLender", GuiRoot, CT_CONTROL)
	self.timers = {}
	self.interactions = {}	-- Numerically indexed table of interaction wrapper class objects registered by action name.　(self.interactions["Action Name"] = { [1] = interaction1, [2] = interactino2, ... })
	self.timerPool = ZO_ControlPool:New("CIWM_InteractionTimer", self.timerLender)
	self.timerPool:SetCustomResetBehavior(function(control)
		control:SetParent(self.timerLender)
		control:ClearAnchors()
		control:SetHidden(true)
		control:SetHandler("OnUpdate", nil)
	end)
	self.timerRequired = {}

	self.supportedModifierKeys = {}
	for keyCode in pairs(IsModifierKeyDown) do
		self.supportedModifierKeys[keyCode] = true
	end

	self:InitializeAPI()
end

function CInteractionWrapperManager:RegisterInteractionWrapperClass(interactionType, class, timerRequired)
	local result = CT_SimpleAddonFramework.RegisterClassObject(self, interactionType, class)
	if result then
		self.timerRequired[interactionType] = timerRequired or false
	end
end

function CInteractionWrapperManager:GetSupportedModifierKeys()
	local t = {}
	for keyCode in pairs(self.supportedModifierKeys) do
		table.insert(t, keyCode)
	end
	return t
end

function CInteractionWrapperManager:IsSupportedModifierKey(keyCode)
	return self.supportedModifierKeys[keyCode] ~= nil
end

function CInteractionWrapperManager:AcquireTimer()
	local timer, key = self.timerPool:AcquireObject()
	timer.key = key
	self.timers[key] = timer
	return timer
end

function CInteractionWrapperManager:RemoveTimer(key)
	if self.timers[key] then
		self.timerPool:ReleaseObject(self.timers[key])
		self.timers[key] = nil
	end
end

function CInteractionWrapperManager:RegisterInteraction(actionNameOrNames, data)
	if type(actionNameOrNames) == "table" then
		return self:RegisterInteractionForMultipleActions(actionNameOrNames, data)
	end
	local actionName = type(actionNameOrNames) == "string" and actionNameOrNames
	local interactionType = type(data) == "table" and data.type
	if actionName and interactionType and self:HasAvailableClass(interactionType) then
		local timerControl = self.timerRequired[interactionType] and self:AcquireTimer()
		local interaction = self:CreateClassObject(interactionType, timerControl, actionName, data)
		if not self.interactions[actionName] then
			self.interactions[actionName] = {}
		end
		table.insert(self.interactions[actionName], interaction)
		return interaction
	end
end

function CInteractionWrapperManager:RegisterInteractionForMultipleActions(actionNameTable, data)
	local interactionType = type(data) == "table" and data.type
	if type(actionNameTable) == "table" and interactionType and self:HasAvailableClass(interactionType) then
		local timerControl = self.timerRequired[interactionType] and self:AcquireTimer()
		local interaction = self:CreateClassObject(interactionType, timerControl, actionNameTable, data)
		for _, actionName in ipairs(actionNameTable) do
			if not self.interactions[actionName] then
				self.interactions[actionName] = {}
			end
			table.insert(self.interactions[actionName], interaction)
		end
		return interaction
	end
end

function CInteractionWrapperManager:HandleKeybindDown(actionName, ...)
	if self.interactions[actionName] then
		for _, interaction in ipairs(self.interactions[actionName]) do
			interaction:OnKeyDown(actionName, ...)
		end
	end
end

function CInteractionWrapperManager:HandleKeybindUp(actionName, ...)
	if self.interactions[actionName] then
		for _, interaction in ipairs(self.interactions[actionName]) do
			interaction:OnKeyUp(actionName, ...)
		end
	end
end

function CInteractionWrapperManager:InitializeAPI()
	-- Removing unnecessary APIs
	self._external.RegisterClassObject = nil

--
-- ---- LibCInteraction API Reference
--
-- * LibCInteraction:GetSupportedModifierKeys()
-- ** _Returns:_ *table* _keyCodeList_
	self._external.GetSupportedModifierKeys = function()
		return self:GetSupportedModifierKeys()
	end

-- * LibCInteraction:IsSupportedModifierKey(*[KeyCode|#KeyCode]* _keyCode_)
-- ** _Returns:_ *bool* _isSupported_
	self._external.IsSupportedModifierKey = function(_, keyCode)
		return self:IsSupportedModifierKey(keyCode)
	end

-- * LibCInteraction:RegisterInteraction([*string* or *table*] _actionNameOrNames_, *table* _interactionDataTable_)
-- ** _Returns:_ *object:nilable* _interactionWrapperObject_
	self._external.RegisterInteraction = function(_, actionNameOrNames, data)
		return self:RegisterInteraction(actionNameOrNames, data)
	end

-- * LibCInteraction:HandleKeybindDown(*string* _actionName_)
	self._external.HandleKeybindDown = function(_, actionName, ...)
		return self:HandleKeybindDown(actionName, ...)
	end

-- * LibCInteraction:HandleKeybindUp(*string* _actionName_)
	self._external.HandleKeybindUp = function(_, actionName, ...)
		return self:HandleKeybindUp(actionName, ...)
	end
end

local INTERACTION_WRAPPER_MANAGER = CInteractionWrapperManager:New("LibCInteraction", {
	name = "LibCInteraction", 
	version = "1.1.0", 
	author = "Calamath", 
--	authority = {2973583419,210970542}, 
})


-- ---------------------------------------------------------------------------------------
-- Interaction Wrapper Base Class
-- ---------------------------------------------------------------------------------------
-- The base class for the interaction wrapper class, which defines internal parameters and interfaces.
-- It simply passes the key-down and key-up events of keybinding actions to callbacks without conditions.
-- If creating a custom interaction wrapper class, you must inherit this and override interactionType with a unique string.
--
local CBaseInteractionWrapper = ZO_InitializingObject:Subclass()
function CBaseInteractionWrapper:Initialize(control, actionName, data)
	self.control = control
	if self.control then
		self.control:SetHidden(true)	-- disable timer
	end
	self.interactionType = "base"
	self.actionName = actionName	-- string of action name or numerically indexed table of action names.
	self:SetKeyDownCallback(data.keyDownCallback)
	self:SetKeyUpCallback(data.keyUpCallback)
	self:SetStartedCallback(data.startedCallback)
	self:SetPerformedCallback(data.performedCallback)
	self:SetCanceledCallback(data.canceledCallback)
	self:SetEndedCallback(data.endedCallback)
	self:SetEnabled(data.enabled or (data.enabled == nil))
	self.multipleInput = data.multipleInput
	self.duration = 0

	self.currentAction = nil
	self.isStarted = false
	self.isPerformed = false
	self.isCanceled = false
	self.startTime = nil
	self.endTime = nil
	self.targetTime = nil
end
function CBaseInteractionWrapper:GetValue(value, ...)
	if type(value) == "function" then
		return value(...)
	else
		return value
	end
end
function CBaseInteractionWrapper:GetCurrentActionName()
	return self.currentAction
end
function CBaseInteractionWrapper:GetHoldTime()
	if self.startTime then
		local endTime = self.endTime or GetFrameTimeMilliseconds()
		return endTime - self.startTime
	else
		return 0
	end
end
function CBaseInteractionWrapper:SetKeyDownCallback(callback)
	self.keyDownCallback = callback
end
function CBaseInteractionWrapper:SetKeyUpCallback(callback)
	self.keyUpCallback = callback
end
function CBaseInteractionWrapper:SetStartedCallback(callback)
	self.startedCallback = callback
end
function CBaseInteractionWrapper:SetPerformedCallback(callback)
	self.performedCallback = callback
end
function CBaseInteractionWrapper:SetCanceledCallback(callback)
	self.canceledCallback = callback
end
function CBaseInteractionWrapper:SetEndedCallback(callback)
	self.endedCallback = callback
end
function CBaseInteractionWrapper:SetEnabled(enabled)
	self.enabled = enabled
end
function CBaseInteractionWrapper:EnableTimer()
	if self.control then
		self.control:SetHidden(false)
	end
end
function CBaseInteractionWrapper:DisableTimer()
	if self.control then
		self.control:SetHidden(true)
	end
end
function CBaseInteractionWrapper:IsModifierKeyDown(keyCode)
	return keyCode and IsModifierKeyDown[keyCode] and IsModifierKeyDown[keyCode]() or false
end
function CBaseInteractionWrapper:Reset()
-- Should be Overridden if needed
	self:DisableTimer()
	self.currentAction = nil
	self.isStarted = false
	self.isPerformed = false
	self.isCanceled = false
	self.startTime = nil
	self.endTime = nil
	self.targetTime = nil
end
function CBaseInteractionWrapper:OnKeyDown(actionName, ...)
--  Should be Overridden if needed
	if self.keyDownCallback then
		self.keyDownCallback(self, ...)
	end
	self:StartInteraction(actionName)
end
function CBaseInteractionWrapper:StartInteraction(actionName)
	if self:PrerequisiteForStarting(actionName) then
		self.isStarted = true
		self.currentAction = actionName
		self.startTime = GetFrameTimeMilliseconds()
		self:OnStarted()
		return true
	end
end
function CBaseInteractionWrapper:PrerequisiteForStarting(actionName)
--  Should be Overridden if needed
	return not self.isStarted and self:GetValue(self.enabled)
end
function CBaseInteractionWrapper:OnStarted()
--  Should be Overridden if needed
	if self.startedCallback then
		self.startedCallback(self)
	end
end
function CBaseInteractionWrapper:OnKeyUp(actionName, ...)
--  Should be Overridden if needed
	if self.keyUpCallback then
		self.keyUpCallback(self, ...)
	end
	self:EndInteraction(actionName)
end
function CBaseInteractionWrapper:EndInteraction(actionName)
	actionName = actionName or self.currentAction
	if self:PrerequisiteForEnding(actionName) then
		self.endTime = GetFrameTimeMilliseconds()
		self:OnEnded()
		self:Reset()
		return true
	end
end
function CBaseInteractionWrapper:PrerequisiteForEnding(actionName)
--  Should be Overridden if needed
	return self.isStarted
end
function CBaseInteractionWrapper:OnEnded()
--  Should be Overridden if needed
	if self.endedCallback then
		self.endedCallback(self)
	end
end
function CBaseInteractionWrapper:OnUpdate()
--  Should be Overridden if needed
end

INTERACTION_WRAPPER_MANAGER:RegisterInteractionWrapperClass("base", CBaseInteractionWrapper, false)


-- ---------------------------------------------------------------------------------------
-- Press Interaction Wrapper Class
-- ---------------------------------------------------------------------------------------
-- The press interaction class can detect both press and release timing of key bindings.
-- 
local CPressInteractionWrapper = CBaseInteractionWrapper:Subclass()
function CPressInteractionWrapper:Initialize(control, actionName, data)
	CBaseInteractionWrapper.Initialize(self, control, actionName, data)
	self.interactionType = "press"
end
function CPressInteractionWrapper:PrerequisiteForEnding(actionName)
	return self.isStarted and not (self.multipleInput and self.currentAction ~= actionName)
end

INTERACTION_WRAPPER_MANAGER:RegisterInteractionWrapperClass("press", CPressInteractionWrapper, false)


-- ---------------------------------------------------------------------------------------
-- Hold Interaction Wrapper Class
-- ---------------------------------------------------------------------------------------
-- The hold interaction class can detect input patterns where a key binding has been pressed for more than a certain period of time.
-- When the hold time reaches the holdTime parameter, it triggers the perfomedCallback; if the hold time is less than that, it triggers the canceledCallback instead.
-- Basically, it is suitable for detecting input patterns such as quick slot wheel activation in vanilla UI.
--
local CHoldInteractionWrapper = CBaseInteractionWrapper:Subclass()
function CHoldInteractionWrapper:Initialize(control, actionName, data)
	CBaseInteractionWrapper.Initialize(self, control, actionName, data)
	self.interactionType = "hold"
	self.duration = data.holdTime or 200
	self.control:SetHandler("OnUpdate", function(control, time)
		self:OnUpdate(control, time)
	end)
end
function CHoldInteractionWrapper:PrerequisiteForStarting()
	return not self.isPerformed and not self.isStarted and self:GetValue(self.enabled)
end
function CHoldInteractionWrapper:OnStarted()
	self.targetTime = self.startTime + self:GetValue(self.duration)
	self:EnableTimer()
	CBaseInteractionWrapper.OnStarted(self)
end
function CHoldInteractionWrapper:PrerequisiteForEnding(actionName)
	return self.isStarted and not (self.multipleInput and self.currentAction ~= actionName)
end
function CHoldInteractionWrapper:OnEnded()
	if not self.isPerformed then
		self.isCanceled = true
		if self.canceledCallback then
			self.canceledCallback(self)
		end
	end
	CBaseInteractionWrapper.OnEnded(self)
end
function CHoldInteractionWrapper:OnUpdate()
--	d(GetFrameTimeMilliseconds())	-- debug
	if self.targetTime and GetFrameTimeMilliseconds() > self.targetTime then
		self.targetTime = nil
		if not self.isPerformed then
			self.isPerformed = true
			if self.performedCallback then
				self.performedCallback(self)
			end
		end
	end
end

INTERACTION_WRAPPER_MANAGER:RegisterInteractionWrapperClass("hold", CHoldInteractionWrapper, true)


