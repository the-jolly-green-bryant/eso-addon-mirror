-- RdK Group Tool Util
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.util = RdKGTool.util or {}

local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.roster = RdKGToolUtil.roster or {}
local RdKGToolRoster = RdKGToolUtil.roster
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu

RdKGToolUtil.callbackReportName = RdKGTool.addonName .. "Report"

RdKGToolUtil.state = {}
RdKGToolUtil.state.parameterPreHooks = {}
RdKGToolUtil.state.parameterPostHooks = {}
RdKGToolUtil.state.preHooks = {}
RdKGToolUtil.state.postHooks = {}
RdKGToolUtil.state.conditionalPreHooks = {}

--functions
--General
function RdKGToolUtil.Initialize()
	RdKGToolUtil.chatSystem.Initialize()
	RdKGToolUtil.roster.Initialize()
	RdKGToolUtil.group.Initialize()
	RdKGToolUtil.groupMenu.Initialize()
	RdKGToolUtil.sound.Initialize()
	RdKGToolUtil.ultimates.Initialize()
	RdKGToolUtil.networking.Initialize()
	RdKGToolUtil.versioning.Initialize()
	RdKGToolUtil.sb.Initialize()
	RdKGToolUtil.allianceColor.Initialize()
	RdKGToolUtil.cyrodiil.Initialize()
	RdKGToolUtil.moving3DObjects.Initialize()
end

function RdKGToolUtil.GetMenu()
	local menu = {
		[1] = {
			type = "header",
			name = RdKGToolMenu.constants.UTIL_HEADER,
			width = "full",
		}
	}
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolUtil.networking.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolUtil.group.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolUtil.allianceColor.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolUtil.chatSystem.GetMenu())
	return menu
end

function RdKGToolUtil.GetDefaults()
	local defaults = {}
		defaults.chatSystem = RdKGToolUtil.chatSystem.GetDefaults()
		defaults.networking = RdKGToolUtil.networking.GetDefaults()
		defaults.group = RdKGToolUtil.group.GetDefaults()
		defaults.groupMenu = RdKGToolUtil.groupMenu.GetDefaults()
		defaults.allianceColor = RdKGToolUtil.allianceColor.GetDefaults()
		defaults.moving3DObjects = RdKGToolUtil.moving3DObjects.GetDefaults()
	return defaults
end

--callbacks
function RdKGToolUtil.ReportFailed(eventCode, reason)
	if eventCode == EVENT_MAIL_SEND_FAILED then
		EVENT_MANAGER:UnregisterForEvent(RdKGToolUtil.callbackReportName, EVENT_MAIL_SEND_FAILED)
		EVENT_MANAGER:UnregisterForEvent(RdKGToolUtil.callbackReportName, EVENT_MAIL_SEND_SUCCESS)
		RdKGTool.vars.acc.reported = false
	end
end

function RdKGToolUtil.ReportSuccess()
	if eventCode == EVENT_MAIL_SEND_SUCCESS then
		EVENT_MANAGER:UnregisterForEvent(RdKGToolUtil.callbackReportName, EVENT_MAIL_SEND_FAILED)
		EVENT_MANAGER:UnregisterForEvent(RdKGToolUtil.callbackReportName, EVENT_MAIL_SEND_SUCCESS)
		RdKGTool.vars.acc.reported = true
	end
end

--Util
function RdKGToolUtil.DeepCopy(target, source)
	if source ~= nil and target ~= nil and type(source) == "table" then
		for key, value in pairs(source) do
			if type(source[key]) == "table" then
				if target[key] == nil or type(target[key]) ~= "table" then
					target[key] = {}
				end
				RdKGToolUtil.DeepCopy(target[key], source[key])
			else 
				target[key] = source[key]
			end
		end
	end
end

function RdKGToolUtil.ColorRgbToParams(color)
	return color.r, color.g, color.b
end

function RdKGToolUtil.ColorRgbaToParams(color)
	return color.r, color.g, color.b, color.a
end

function RdKGToolUtil.HookTableContainsEntry(hookName, hookTable)
	local containsName = false
	if hookName ~= nil and hookTable ~= nil then
		for i = 1, #hookTable do
			if hookTable[i].hookName == hookName then
				containsName = true
				break
			end
		end
	end
	return containsName
end

function RdKGToolUtil.RemoveHook(hookName, hookTable)
	if hookName ~= nil and hookTable ~= nil then
		for i = 1, #hookTable do
			if hookTable[i].hookName == hookName then
				if hookTable[i].object == nil then
					_G[hookTable[i].fn] = hookTable[i].origFn
				else
					hookTable[i].object[hookTable[i].fn] = hookTable[i].origFn
				end
				table.remove(hookTable, i)
				break
			end
		end
	end
end

function RdKGToolUtil.PreHook(hookName, object, fn, callback)
	if RdKGToolUtil.HookTableContainsEntry(hookName, RdKGToolUtil.state.preHooks) == false then
		local entry = {}
		entry.hookName = hookName
		entry.fn = fn
		entry.object = object
		entry.callback = callback
		if object == nil then
			entry.origFn = _G[fn]
		else
			entry.origFn = object[fn]
		end
		local hook = function(...)
			callback(...)
			return entry.origFn(...)
		end
		if object == nil then
			_G[fn] = hook
		else
			object[fn] = hook
		end
		table.insert(RdKGToolUtil.state.preHooks, entry)
	end
end

function RdKGToolUtil.RemovePreHook(hookName)
	if hookName ~= nil then
		RdKGToolUtil.RemoveHook(hookName, RdKGToolUtil.state.preHooks)
	end
end

function RdKGToolUtil.PostHook(hookName, object, fn, callback)
	if RdKGToolUtil.HookTableContainsEntry(hookName, RdKGToolUtil.state.postHooks) == false then
		local entry = {}
		entry.hookName = hookName
		entry.fn = fn
		entry.object = object
		entry.callback = callback
		if object == nil then
			entry.origFn = _G[fn]
		else
			entry.origFn = object[fn]
		end
		local hook = function(...)
			entry.origFn(...)
			return callback(...)
		end
		if object == nil then
			_G[fn] = hook
		else
			object[fn] = hook
		end
		table.insert(RdKGToolUtil.state.postHooks, entry)
	end
end

function RdKGToolUtil.RemovePostHook(hookName)
	if hookName ~= nil then
		RdKGToolUtil.RemoveHook(hookName, RdKGToolUtil.state.postHooks)
	end
end

function RdKGToolUtil.AddConditionalPreHook(hookName, object, fn, callback, defaultValues)
	if RdKGToolUtil.HookTableContainsEntry(hookName, RdKGToolUtil.state.conditionalPreHooks) == false then
		local entry = {}
		entry.hookName = hookName
		entry.fn = fn
		entry.object = object
		entry.callback = callback
		if object == nil then
			entry.origFn = _G[fn]
		else
			entry.origFn = object[fn]
		end
		local hook = function(...)
			local executeOriginalFunction = callback(...)
			if executeOriginalFunction == true then
				return entry.origFn(...)
			else
				if defaultValues ~= nil and type(defaultValues) == "table" then
					return unpack(defaultValues)
				elseif defaultValues ~= nil then
					return defaultValues
				else
					return nil
				end
			end
		end
		if object == nil then
			_G[fn] = hook
		else
			object[fn] = hook
		end
		table.insert(RdKGToolUtil.state.conditionalPreHooks, entry)
	end
end

function RdKGToolUtil.RemoveConditionalPreHook(hookName)
	if hookName ~= nil then
		RdKGToolUtil.RemoveHook(hookName, RdKGToolUtil.state.conditionalPreHooks)
	end
end

function RdKGToolUtil.ParameterPreHook(hookName, object, fn, callback)
	if RdKGToolUtil.HookTableContainsEntry(hookName, RdKGToolUtil.state.parameterPreHooks) == false then
		local entry = {}
		entry.hookName = hookName
		entry.fn = fn
		entry.object = object
		entry.callback = callback
		if object == nil then
			entry.origFn = _G[fn]
		else
			entry.origFn = object[fn]
		end
		local hook = function(...)
			return entry.origFn(callback(...))
		end
		if object == nil then
			_G[fn] = hook
		else
			object[fn] = hook
		end
		table.insert(RdKGToolUtil.state.parameterPreHooks, entry)
	end
end

function RdKGToolUtil.RemoveParameterPreHook(hookName)
	if hookName ~= nil then
		RdKGToolUtil.RemoveHook(hookName, RdKGToolUtil.state.parameterPreHooks)
	end
end

function RdKGToolUtil.ParameterPostHook(hookName, object, fn, callback)	
	if RdKGToolUtil.HookTableContainsEntry(hookName, RdKGToolUtil.state.parameterPostHooks) == false then
		local entry = {}
		entry.hookName = hookName
		entry.fn = fn
		entry.object = object
		entry.callback = callback
		if object == nil then
			entry.origFn = _G[fn]
		else
			entry.origFn = object[fn]
		end
		local hook = function(...)
			return callback(entry.origFn(...))
		end
		if object == nil then
			_G[fn] = hook
		else
			object[fn] = hook
		end
		table.insert(RdKGToolUtil.state.parameterPostHooks, entry)
	end
end

function RdKGToolUtil.RemoveParameterPostHook(hookName)
	if hookName ~= nil then
		RdKGToolUtil.RemoveHook(hookName, RdKGToolUtil.state.parameterPostHooks)
	end
end

--Player, Character, Group
function RdKGToolUtil.IsInPvPArea()
	if IsPlayerInAvAWorld() == true then
		return true
	end
	if IsInAvAZone() == true then
		return true
	end	
	if IsInImperialCity() == true then
		return true
	end
	if IsInCyrodiil() == true then
		return true
	end
	if IsActiveWorldBattleground() == true then
		return true
	end
	return false
end

function RdKGToolUtil.IsInCyrodiil()
	if IsInCyrodiil() == true then
		return true
	elseif IsInCyrodiil() == false and IsPlayerInAvAWorld() == true and IsInAvAZone() == true and IsInImperialCity() == false and IsActiveWorldBattleground() == false then
		return true
	else
		return false
	end
end

function RdKGToolUtil.GetUnitTagFromGroupMemberName(name)
	local size = GetGroupSize()
	for i = 1, size do
		local tag = GetGroupUnitTagByIndex(i)
        if GetUnitName(tag) == name then
            return tag
        end
	end
	return nil
end


--UI

