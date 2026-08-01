local addon = IJA_COMPANION_UI
---------------------------------------------------------------------------------------------------------------
-- Debug
---------------------------------------------------------------------------------------------------------------
local debugOverride = true
local logLevel

local fmt
local function stfmt(ftSt, ...)
    ftSt = ftSt:gsub(', $', '')
	local g_strArgs = {}
	for i = 1, select("#", ...) do
		local currentArg = select(i, ...)
		local argType = type(currentArg)
		if argType == 'userdata' then 
			currentArg = currentArg.GetName and currentArg:GetName() or currentArg
		elseif argType == 'table' then
			currentArg = fmt(currentArg)
		end
		g_strArgs[i] = tostring(currentArg)
	end

	if #g_strArgs == 0 then
		return tostring(ftSt)
	else
		return string.format(ftSt, unpack(g_strArgs))
	end
end

fmt = function(formatString, ...)
	if type(formatString) == 'table' then
		local tbl, fmtStr = {}, '[table] {'
		
		for k, v in pairs(formatString) do
			k = string.format(type(k) == 'string' and '["%s"]' or '[%s]', k)
			if type(v) == 'string' then
				fmtStr = fmtStr .. k .. ' = "%s", '
			else
				fmtStr = fmtStr .. k .. ' = %s, '
			end
			table.insert(tbl, v)
		end
		if #tbl > 0 then
			fmtStr = fmtStr:gsub(', $', '') .. '}'
			return stfmt(fmtStr, unpack(tbl))
		end
		-- Table is empty.
		return stfmt(fmtStr .. '-empty-}', '')
    elseif type(formatString) == 'number' then
		formatString = tostring(formatString)
		
    elseif type(formatString) ~= 'string' then
		formatString = stfmt('%s', formatString)
	end
	
    return (stfmt(formatString, ...))
end

local logFunctions = {}
local logFunctionNames = {"Verbose", "Debug", "Info", "Warn", "Error"}
if LibDebugLogger then
	logLevel = debugOverride and LibDebugLogger.LOG_LEVEL_DEBUG or LibDebugLogger.LOG_LEVEL_INFO
	addon.logger = LibDebugLogger(addon.name)
	for _, logFunctionName in pairs(logFunctionNames) do
		logFunctions[logFunctionName] = function(self, ...) return self.logger[logFunctionName](self.logger, fmt(...)) end
		addon[logFunctionName] = logFunctions[logFunctionName]
	end
	addon.logger:SetMinLevelOverride(logLevel)
else
	for _, logFunctionName in pairs(logFunctionNames) do
		logFunctions[logFunctionName] = function(...) end
		addon[logFunctionName] = logFunctions[logFunctionName]
	end
end

function addon:CreateLogger(className, classTable)
	if addon.logger then
		classTable.logger = addon.logger:Create(className)
		classTable.logger:SetMinLevelOverride(addon.logLevel)
	end

	for logFunctionName, logFunction in pairs(logFunctions) do
		classTable[logFunctionName] = logFunction
	end
end

---------------------------------------------------------------------------------------------------------------
-- Experimental
---------------------------------------------------------------------------------------------------------------
--[[ About LibHaF:
	LibHaF is an experimental library which I am not ready to release. This file will allow me to use the modifications
	on this version of this addon I release without having to release LibHaF. This will allow me to test LibHaF more thoroughly
	and make changes without having to update this addon every time.
]]

local function initialize()
	do
		-- this version will iterate any number index, including decimals and below 1. (example[-∞] to example[∞])
		-- including tables where indices are not consecutive. 1,2,4,7
		-- if there are non numeric indexes in table, they will be skipped without preventing table iterations. -- not currently true
		-- removed the type check due to causing errors
		local function getIndexList(t)
			local indexList = {}
			for k,v in pairs(t) do
				table.insert(indexList, k)
			end
			table.sort(indexList, function(a, b) return a < b end)
			return indexList
		end
		function ZO_FilteredNumericallyIndexedTableIterator(tbl, filterFunctions)
			local indexList = getIndexList(tbl)
			local numFilters = filterFunctions and #filterFunctions or 0
			local index = 0
			local count = #indexList
			if numFilters > 0  then
				return function()
					index = index + 1
					while index <= count do
						local passesFilter = true
						local data = tbl[indexList[index]]
						if data ~= nil then
							for filterIndex = 1, numFilters do
								if not filterFunctions[filterIndex](data) then
									passesFilter = false
									break
								end
							end
							if passesFilter then
								return index, data
							else
								index = index + 1
							end
						else
							index = index + 1
						end
					end
				end
			else
				return function()
					index = index + 1
					while index <= count do
						local data = tbl[indexList[index]]
						if data ~= nil then
							return index, data
						else
							index = index + 1
						end
					end
				end
			end
		end
	end

	---------------------------------------------------------------------------------------------------------------
	local HookManager = {}
	function HookManager:RegisterForPreHook(name, ...)
		return ZO_PreHook(...)
	end 
	function HookManager:RegisterForPostHook(name, ...)
		return ZO_PostHook(...)
	end

	function HookManager:RegisterForPreHookHandler(name, ...)
		return ZO_PreHookHandler(...)
	end 
	function HookManager:RegisterForPostHookHandler(name, ...)
		return ZO_PostHookHandler(...)
	end

	for k, fnName in pairs({'UnregisterForPreHook', 'UnregisterForPostHook', 'UnregisterForPreHookHandler', 'UnregisterForPostHookHandler'}) do
		HookManager[fnName] = function() return false end
	end

	if not JO_HOOK_MANAGER then JO_HOOK_MANAGER = HookManager end

	---------------------------------------------------------------------------------------------------------------
	-- 
	---------------------------------------------------------------------------------------------------------------
	local UpdateBuffer = ZO_InitializingObject:Subclass()

	function UpdateBuffer:Initialize(id, func, enabled, delay)
		self.updateName = "JO_UpdateBuffer_" .. id
		self.enabled = enabled == nil and true or enabled
		self:SetDelay(delay)
		
		self.CallbackFn = func
	end

	function UpdateBuffer:OnUpdate(...)
		local params = {...}
		EVENT_MANAGER:UnregisterForUpdate(self.updateName)
		
		local function OnUpdateHandler()
			EVENT_MANAGER:UnregisterForUpdate(self.updateName)
			self:CallbackFn(unpack(params))
		end
		
		local enabled = self.enabled
		
		if type(self.enabled) == 'function' then
			enabled = self.enabled()
		end
		
		if enabled then
			EVENT_MANAGER:RegisterForUpdate(self.updateName, self.delay, OnUpdateHandler)
		end
	end

	function UpdateBuffer:SetDelay(delay)
		delay = delay or 100
		self.delay = delay
	end

	function UpdateBuffer:SetEnabled(enabled)
		self.enabled = enabled
	end

	function UpdateBuffer:SetEnabledFunciton(enabledFn)
		self.enabled = enabledFn
	end

	JO_UpdateBuffer = UpdateBuffer

	function JO_UpdateBuffer_Simple(id, func)
		local updateName = "JO_UpdateBuffer_Simple_" .. id

		return function(...)
			local params = {...}
			EVENT_MANAGER:UnregisterForUpdate(updateName)
			
			local function OnUpdateHandler()
				EVENT_MANAGER:UnregisterForUpdate(updateName)
				func(unpack(params))
			end
			
			EVENT_MANAGER:RegisterForUpdate(updateName, 100, OnUpdateHandler)
		end
	end

	---------------------------------------------------------------------------------------------------------------
	-- Modifications to allow disabling interactions
	---------------------------------------------------------------------------------------------------------------
	local lib_reticle = RETICLE
	local lib_fishing_manager = FISHING_MANAGER
	local lib_fishing_gamepad = FISHING_GAMEPAD
	local lib_fishing_keyboard = FISHING_KEYBOARD

	function lib_reticle:GetInteractPromptVisible()
		if self.interactionDisabled then
			return false
		end
		return not self.interact:IsHidden()
	end

	function lib_fishing_manager:StartInteraction()
		if lib_reticle.interactionDisabled then
			return true
		end
		
		self.gamepad = IsInGamepadPreferredMode()
		if self.gamepad then
			return lib_fishing_gamepad:StartInteraction()
		else
			return lib_fishing_keyboard:StartInteraction()
		end
	end

	lib_reticle.actionFilters = {}

	function lib_reticle:SetInteractionDisabled(disabled)
		self.interactionDisabled = disabled
	end

	function lib_reticle:RegisterActionDisabledFilter(registerdName, action, filter)
		if not self.actionFilters[action] then self.actionFilters[action] = {} end
		self.actionFilters[action][registerdName] = filter
		return filter
	end

	function lib_reticle:UnregisterActionDisabledFilter(registerdName, action)
		if self.actionFilters[action] and self.actionFilters[action][registerdName] then
			self.actionFilters[action][registerdName] = nil
		end
	end

	function lib_reticle:GetActionFilters(action)
		return self.actionFilters[action]
	end

	function lib_reticle:IsInteractionDisabled(currentFrameTimeSeconds)
		local action, interactableName = GetGameCameraInteractableActionInfo()
	--	logger:Debug('function IsInteractionDisabled: action = %s, interactableName = %s, interactionBlocked = %s, interactionDisabled = %s', action, interactableName, self.interactionBlocked, self.interactionDisabled)
		if action == nil then return self.interactionDisabled end
		local actionFilters = self:GetActionFilters(action)
		
		if actionFilters then
			for registeredName, actionFilter in pairs(actionFilters) do
			--	logger:Debug('-- actionFilter: registeredName = %s, actionFilter Returns = %s', registeredName, actionFilter(action, interactableName, currentFrameTimeSeconds))
				if actionFilter(action, interactableName, currentFrameTimeSeconds) then
					return true
				end
			end
		end
		return false
	end

	JO_HOOK_MANAGER:RegisterForPostHook(addon.name, lib_reticle, "TryHandlingInteraction", function(self, interactionPossible, currentFrameTimeSeconds)
		if not interactionPossible then return end
		self.interactionDisabled = self:IsInteractionDisabled(currentFrameTimeSeconds)
		if self.interactionDisabled and not self.interactionBlocked then
			self.interactionBlocked = self.interactionDisabled
		end
	--	logger:Debug('self.interactionBlocked = %s', self.interactionBlocked)
	end)

	---------------------------------------------------------------------------------------------------------------
	-- jo_callLaters
	---------------------------------------------------------------------------------------------------------------
	jo_callLater = function(id, func, ms, ...)
		local params = {...}
		if ms == nil then ms = 0 end
		local name = "JO_CallLater_".. id
		EVENT_MANAGER:UnregisterForUpdate(name)
		
		EVENT_MANAGER:RegisterForUpdate(name, ms,
			function()
				EVENT_MANAGER:UnregisterForUpdate(name)
				func(unpack(params))
			end)
		return id
	end

	jo_callLaterOnScene = function(id, sceneName, func, ...)
		local params = {...}
		if not sceneName or type(sceneName) ~= 'string' then return end
		
		local updateName = "JO_CallLaterOnScene_" .. id
		EVENT_MANAGER:UnregisterForUpdate(updateName)
		
		local function OnUpdateHandler()
			if SCENE_MANAGER:GetCurrentSceneName() == sceneName then
				EVENT_MANAGER:UnregisterForUpdate(updateName)
				func(unpack(params))
			end
		end
		
		EVENT_MANAGER:RegisterForUpdate(updateName, 100, OnUpdateHandler)
	end

	jo_callLaterOnNextScene = function(id, func, ...)
		local params = {...}
		local sceneName = SCENE_MANAGER:GetCurrentSceneName()
		local updateName = "JO_CallLaterOnNextScene_" .. id
		EVENT_MANAGER:UnregisterForUpdate(updateName)
		
		local function OnUpdateHandler()
			if SCENE_MANAGER:GetCurrentSceneName() ~= sceneName then
				EVENT_MANAGER:UnregisterForUpdate(updateName)
				func(unpack(params))
			end
		end
		
		EVENT_MANAGER:RegisterForUpdate(updateName, 100, OnUpdateHandler)
	end
end

if not JO_UpdateBuffer_Simple then initialize() end
