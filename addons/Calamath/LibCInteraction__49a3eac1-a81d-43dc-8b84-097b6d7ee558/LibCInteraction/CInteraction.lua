--
-- CInteractionManager [CIM] : (LibCInteraction)
--
-- Copyright (c) 2022 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

-- ---------------------------------------------------------------------------------------
-- CT_MinimalAddonFramework: Minimal Add-on Framework Template Class            rel.1.1.12
-- ---------------------------------------------------------------------------------------
local CT_MinimalAddonFramework = ZO_Object:Subclass()
function CT_MinimalAddonFramework:New(...)
	local newObject = setmetatable({}, self)
	newObject:Initialize(...)
	newObject:ConfigDebug()
	newObject:OnInitialized(...)
	return newObject
end
function CT_MinimalAddonFramework:Initialize(name, attributes)
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
	self._external = {
		name = self.name or self._name, 
		version = self.version, 
		author = self.author, 
	}
	assert(not _G[name], name .. " is already loaded.")
	_G[name] = self._external
	EVENT_MANAGER:RegisterForEvent(self._name, EVENT_ADD_ON_LOADED, function(event, addonName)
		if addonName ~= self._name then return end
		EVENT_MANAGER:UnregisterForEvent(self._name, EVENT_ADD_ON_LOADED)
		self:OnAddOnLoaded(event, addonName)
		self._isInitialized = true
	end)
end
function CT_MinimalAddonFramework:ConfigDebug()
	local Dummy = function() end
	self.LDL = { Verbose = Dummy, Debug = Dummy, Info = Dummy, Warn = Dummy, Error = Dummy, }
	self._isDebugMode = false
end
function CT_MinimalAddonFramework:OnInitialized(name, attributes)
--  Available when overridden in an inherited class
end
function CT_MinimalAddonFramework:OnAddOnLoaded(event, addonName)
--  Should be Overridden
end

-- ---------------------------------------------------------------------------------------
-- CT_SimpleAddonFramework: Simple Add-on Framework Template Class              rel.1.1.12
-- ---------------------------------------------------------------------------------------
local CT_SimpleAddonFramework = CT_MinimalAddonFramework:Subclass()
function CT_SimpleAddonFramework:Initialize(name, attributes)
	CT_MinimalAddonFramework.Initialize(self, name, attributes)
	if self._external then
		self._class = {}
		self._shared = nil
		self._external.RegisterClassObject = function(_, ...) self:RegisterClassObject(...) end
	end
end
function CT_SimpleAddonFramework:ConfigDebug(auth)
	local debugMode = false
	auth = auth or self.authority
	if type(auth) == "table" then
		local key = HashString(GetDisplayName())
		for _, v in pairs(auth) do
			if key == v then debugMode = true end
		end
	end
	if debugMode then
		if not self._logger then
			if not IsConsoleUI() and LibDebugLogger then
				self._logger = LibDebugLogger(self._name)
			else
				local Printf = function(_, ...) df(...) end
				self._logger = { Verbose = Printf, Debug = Printf, Info = Printf, Warn = Printf, Error = Printf, }
			end
		end
		self.LDL = self._logger
	else
		local Dummy = function() end
		self.LDL = { Verbose = Dummy, Debug = Dummy, Info = Dummy, Warn = Dummy, Error = Dummy, }
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


-- ---------------------------------------------------------------------------------------
-- CInteractionManager (LibCInteraction)
-- ---------------------------------------------------------------------------------------
-- This class provides a generic framework for detecting specific input patterns based on down/up events of keybinding actions.
--
local isMouseSupportedUI = not IsConsoleUI()
local IsModifierKeyDown = {
	[KEY_CTRL] = function() return IsControlKeyDown() end, 
	[KEY_ALT] = function() return IsAltKeyDown() end, 
	[KEY_SHIFT] = function() return IsShiftKeyDown() end, 
	[KEY_COMMAND] = function() return IsCommandKeyDown() end, 
	[KEY_GAMEPAD_LEFT_TRIGGER] = function() return GetGamepadLeftTriggerMagnitude() > 0.2 end, 
	[KEY_GAMEPAD_RIGHT_TRIGGER] = function() return GetGamepadRightTriggerMagnitude() > 0.2 end, 
}
local IsMouseButtonSupported = {
	[MOUSE_BUTTON_INDEX_INVALID] = false, 
	[MOUSE_BUTTON_INDEX_LEFT] = isMouseSupportedUI, 
	[MOUSE_BUTTON_INDEX_RIGHT] = isMouseSupportedUI, 
	[MOUSE_BUTTON_INDEX_MIDDLE] = isMouseSupportedUI, 
	[MOUSE_BUTTON_INDEX_BUTTON_4] = isMouseSupportedUI, 
	[MOUSE_BUTTON_INDEX_BUTTON_5] = isMouseSupportedUI, 
	[MOUSE_BUTTON_INDEX_LEFT_AND_RIGHT] = isMouseSupportedUI, 
}
local CInteractionManager = CT_SimpleAddonFramework:Subclass()
function CInteractionManager:OnInitialized()
	self.timerLender = WINDOW_MANAGER:CreateControl("CIM_UI_TimerLender", GuiRoot, CT_CONTROL)
	self.timers = {}
	self.interactions = {}	-- Numerically indexed table of interaction class objects registered by action name.　(self.interactions["Action Name"] = { [1] = interaction1, [2] = interaction2, ... })
	self.timerPool = ZO_ControlPool:New("CIM_InteractionTimer", self.timerLender)
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

	self.mouseButtonActionNames = {}
	for mouseButtonIndex, isSupported in pairs(IsMouseButtonSupported) do
		if isSupported then
			self.mouseButtonActionNames[mouseButtonIndex] = "CIM_MouseButtonInteraction" .. tostring(mouseButtonIndex)
		end
	end
	self:InitializeAPI()
end

function CInteractionManager:RegisterInteractionClass(interactionType, class, timerRequired)
	local result = CT_SimpleAddonFramework.RegisterClassObject(self, interactionType, class)
	if result then
		self.timerRequired[interactionType] = timerRequired or false
	end
end

function CInteractionManager:GetSupportedModifierKeys()
	local t = {}
	for keyCode in pairs(self.supportedModifierKeys) do
		table.insert(t, keyCode)
	end
	return t
end

function CInteractionManager:IsSupportedModifierKey(keyCode)
	return self.supportedModifierKeys[keyCode] ~= nil
end

function CInteractionManager:GetMouseButtonActionName(mouseButtonIndex)
	return self.mouseButtonActionNames[mouseButtonIndex]
end

function CInteractionManager:IsSupportedMouseButton(mouseButtonIndex)
	return self.mouseButtonActionNames[mouseButtonIndex] ~= nil
end

function CInteractionManager:AcquireTimer()
	local timer, key = self.timerPool:AcquireObject()
	timer.key = key
	self.timers[key] = timer
	return timer
end

function CInteractionManager:RemoveTimer(key)
	if self.timers[key] then
		self.timerPool:ReleaseObject(self.timers[key])
		self.timers[key] = nil
	end
end

function CInteractionManager:RegisterInteraction(actionNameOrNames, data)
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

function CInteractionManager:RegisterInteractionForMultipleActions(actionNameTable, data)
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

function CInteractionManager:HandleKeybindDown(actionName, ...)
	if actionName and self.interactions[actionName] then
		for _, interaction in ipairs(self.interactions[actionName]) do
			interaction:OnKeyDown(actionName, ...)
		end
	end
end

function CInteractionManager:HandleKeybindUp(actionName, ...)
	if actionName and self.interactions[actionName] then
		for _, interaction in ipairs(self.interactions[actionName]) do
			interaction:OnKeyUp(actionName, ...)
		end
	end
end

-- Utility function
-- This is a control handler order-compatible version of ZO_PropagateHandler, with the ability to propagate only to the handler with a specific namespace.
function CInteractionManager.PropagateHandler(propagateTo, eventName, namespace, ...)
	if propagateTo then
		-- At present, the only way to get arbitrary handlers for the same event registered to a control is to use the handler namespace as a key.
		local handler = propagateTo:GetHandler(eventName, namespace)
		if handler then
			handler(propagateTo, ...)
			return true
		end
	end
	return false
end

-- API section
function CInteractionManager:InitializeAPI()
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

-- Utility functions not facing end-users
--
-- * LibCInteraction.PropagateHandler(*object* _propagateTo_, *string* _eventName_, *string:nilable* _namespace_, ...)
-- where ... are the handler args after self
-- This is a control handler order-compatible version of ZO_PropagateHandler, with the ability to propagate only to the handler with a specific namespace.
	self._external.PropagateHandler = function(...)
		return self.PropagateHandler(...)
	end

-- * LibCInteraction.PropagateHandlerToParent(*string* _eventName_, *string:nilable* _namespace_, *object* _propagateFromControl_, ...)
-- where ... are the handler args after self
-- This is a control handler order-compatible version of ZO_PropagateHandlerToParent, with the ability to propagate only to the handler with a specific namespace.
-- For when you want to propagate to the control's parent without breaking self out of the args
-- LibCInteraction.PropagateHandlerToParent("OnMouseUp", namespace, ...)
	self._external.PropagateHandlerToParent = function(eventName, namespace, propagateFromControl, ...)
		return self.PropagateHandler(propagateFromControl:GetParent(), eventName, namespace, ...)
	end

-- * LibCInteraction.PropagateHandlerFromControl(*object* _propagateToControl_, *string* _eventName_, *string:nilable* _namespace_, *object* _propagateFromControl_, ...)
-- where ... are the handler args after self
-- This is a control handler order-compatible version of ZO_PropagateHandlerFromControl, with the ability to propagate only to the handler with a specific namespace.
-- For when you want to propagate without breaking self out of the args
-- LibCInteraction.PropagateHandlerFromControl(self:GetParent():GetParent(), "OnMouseUp", namespace, ...)
	self._external.PropagateHandlerFromControl = function(propagateToControl, eventName, namespace, propagateFromControl, ...)
		return self.PropagateHandler(propagateToControl, eventName, namespace, ...)
	end

-- * LibCInteraction.SupportedMouseButtonIterator()
-- ** _Returns:_ *function* _validMouseButtonIndexIterator_
	self._external.SupportedMouseButtonIterator = function()
		return pairs(self.mouseButtonActionNames)
	end

-- * LibCInteraction:GetMouseButtonActionName(*[MouseButtonIndex|#MouseButtonIndex]* _mouseButtonIndex_)
-- ** _Returns:_ *string:nilable* _actionName_
	self._external.GetMouseButtonActionName = function(_, mouseButtonIndex)
		return self:GetMouseButtonActionName(mouseButtonIndex)
	end

-- * LibCInteraction:IsSupportedMouseButton(*[MouseButtonIndex|#MouseButtonIndex]* _mouseButtonIndex_)
-- ** _Returns:_ *bool* _isSupported_
	self._external.IsSupportedMouseButton = function(_, mouseButtonIndex)
		return self:IsSupportedMouseButton(mouseButtonIndex)
	end
end

local INTERACTION_MANAGER = CInteractionManager:New("LibCInteraction", {
	name = "LibCInteraction", 
	version = "1.4.2", 
	author = "Calamath", 
--	authority = {2973583419,210970542}, 
})


-- ---------------------------------------------------------------------------------------
-- Interaction Base Class
-- ---------------------------------------------------------------------------------------
-- The base class for the interaction class, which defines internal parameters and interfaces.
-- It simply passes the key-down and key-up events of keybinding actions to callbacks without conditions.
-- If creating a custom interaction class, you must inherit this and override interactionType with a unique string.
--
local CInteraction_Base = ZO_InitializingObject:Subclass()
function CInteraction_Base:Initialize(control, actionName, data)
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
	if type(data.customFactoryFunction) == "function" then
		data.customFactoryFunction(self)	-- Signature: factoryFunction(interactionBeingCreated)
	end
end
function CInteraction_Base:GetValue(value, ...)
	if type(value) == "function" then
		return value(...)
	else
		return value
	end
end
function CInteraction_Base:GetCurrentActionName()
	return self.currentAction
end
function CInteraction_Base:GetHoldTime()
	if self.startTime then
		local endTime = self.endTime or GetFrameTimeMilliseconds()
		return endTime - self.startTime
	else
		return 0
	end
end
function CInteraction_Base:SetKeyDownCallback(callback)
	self.keyDownCallback = callback
end
function CInteraction_Base:SetKeyUpCallback(callback)
	self.keyUpCallback = callback
end
function CInteraction_Base:SetStartedCallback(callback)
	self.startedCallback = callback
end
function CInteraction_Base:SetPerformedCallback(callback)
	self.performedCallback = callback
end
function CInteraction_Base:SetCanceledCallback(callback)
	self.canceledCallback = callback
end
function CInteraction_Base:SetEndedCallback(callback)
	self.endedCallback = callback
end
function CInteraction_Base:SetEnabled(enabled)
	self.enabled = enabled
end
function CInteraction_Base:EnableTimer()
	if self.control then
		self.control:SetHidden(false)
	end
end
function CInteraction_Base:DisableTimer()
	if self.control then
		self.control:SetHidden(true)
	end
end
function CInteraction_Base:IsModifierKeyDown(keyCode)
	return keyCode and IsModifierKeyDown[keyCode] and IsModifierKeyDown[keyCode]() or false
end
function CInteraction_Base:Reset()
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
function CInteraction_Base:OnKeyDown(actionName, ...)
--  Should be Overridden if needed
	if self.keyDownCallback then
		self.keyDownCallback(self, ...)
	end
	self:StartInteraction(actionName)
end
function CInteraction_Base:StartInteraction(actionName)
	if self:PrerequisiteForStarting(actionName) then
		self.isStarted = true
		self.currentAction = actionName
		self.startTime = GetFrameTimeMilliseconds()
		self:OnStarted()
		return true
	end
end
function CInteraction_Base:PrerequisiteForStarting(actionName)
--  Should be Overridden if needed
	return not self.isStarted and self:GetValue(self.enabled)
end
function CInteraction_Base:OnStarted()
--  Should be Overridden if needed
	if self.startedCallback then
		self.startedCallback(self)
	end
end
function CInteraction_Base:OnKeyUp(actionName, ...)
--  Should be Overridden if needed
	if self.keyUpCallback then
		self.keyUpCallback(self, ...)
	end
	self:EndInteraction(actionName)
end
function CInteraction_Base:EndInteraction(actionName)
	actionName = actionName or self.currentAction
	if self:PrerequisiteForEnding(actionName) then
		self.endTime = GetFrameTimeMilliseconds()
		self:OnEnded()
		self:Reset()
		return true
	end
end
function CInteraction_Base:Terminate()
	self.endTime = GetFrameTimeMilliseconds()
	self:OnEnded()
	self:Reset()
end
function CInteraction_Base:PrerequisiteForEnding(actionName)
--  Should be Overridden if needed
	return self.isStarted
end
function CInteraction_Base:OnEnded()
--  Should be Overridden if needed
	if self.endedCallback then
		self.endedCallback(self)
	end
end
function CInteraction_Base:OnUpdate()
--  Should be Overridden if needed
end

INTERACTION_MANAGER:RegisterInteractionClass("base", CInteraction_Base, false)


-- ---------------------------------------------------------------------------------------
-- Press Interaction Class
-- ---------------------------------------------------------------------------------------
-- The press interaction class can detect both press and release timing of key bindings.
-- There is no requirement on how long you hold down the key bindings.
--
local CPressInteraction = CInteraction_Base:Subclass()
function CPressInteraction:Initialize(control, actionName, data)
	CInteraction_Base.Initialize(self, control, actionName, data)
	self.interactionType = "press"
end
function CPressInteraction:PrerequisiteForEnding(actionName)
	return self.isStarted and not (self.multipleInput and self.currentAction ~= actionName)
end

INTERACTION_MANAGER:RegisterInteractionClass("press", CPressInteraction, false)


-- ---------------------------------------------------------------------------------------
-- Hold Interaction Class
-- ---------------------------------------------------------------------------------------
-- The hold interaction class can detect input patterns where a key binding has been pressed for more than a certain period of time.
-- When the hold time reaches the holdTime parameter, it triggers the perfomedCallback; if the hold time is less than that, it triggers the canceledCallback instead.
-- Basically, it is suitable for detecting input patterns such as quick slot wheel activation in vanilla UI.
--
local CHoldInteraction = CInteraction_Base:Subclass()
function CHoldInteraction:Initialize(control, actionName, data)
	CInteraction_Base.Initialize(self, control, actionName, data)
	self.interactionType = "hold"
	self.duration = data.holdTime or 200
	self.control:SetHandler("OnUpdate", function(control, time)
		self:OnUpdate(control, time)
	end)
end
function CHoldInteraction:PrerequisiteForStarting()
	return not self.isPerformed and not self.isStarted and self:GetValue(self.enabled)
end
function CHoldInteraction:OnStarted()
	self.targetTime = self.startTime + self:GetValue(self.duration)
	self:EnableTimer()
	CInteraction_Base.OnStarted(self)
end
function CHoldInteraction:PrerequisiteForEnding(actionName)
	return self.isStarted and not (self.multipleInput and self.currentAction ~= actionName)
end
function CHoldInteraction:OnEnded()
	if not self.isPerformed then
		self.isCanceled = true
		if self.canceledCallback then
			self.canceledCallback(self)
		end
	end
	CInteraction_Base.OnEnded(self)
end
function CHoldInteraction:OnUpdate()
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

INTERACTION_MANAGER:RegisterInteractionClass("hold", CHoldInteraction, true)

