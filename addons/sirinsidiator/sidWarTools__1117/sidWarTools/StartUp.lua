local ADDON_NAME = "sidWarTools"
sidWarTools = {}

local nextEventHandleIndex = 1

local function RegisterForEvent(event, callback)
	local eventHandleName = ADDON_NAME .. nextEventHandleIndex
	EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
	nextEventHandleIndex = nextEventHandleIndex + 1
	return eventHandleName
end

local function RegisterForCombatResult(result, callback)
	local eventHandleName = ADDON_NAME .. nextEventHandleIndex
	nextEventHandleIndex = nextEventHandleIndex + 1
	EVENT_MANAGER:RegisterForEvent(eventHandleName, EVENT_COMBAT_EVENT, callback)
	EVENT_MANAGER:AddFilterForEvent(eventHandleName, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, result)
	return eventHandleName
end

local function UnregisterForEvent(event, name)
	EVENT_MANAGER:UnregisterForEvent(name, event)
end

local function WrapFunction(object, functionName, wrapper)
	if(type(object) == "string") then
		wrapper = functionName
		functionName = object
		object = _G
	end
	local originalFunction = object[functionName]
	object[functionName] = function(...) return wrapper(originalFunction, ...) end
end

local function OnAddonLoaded(callback)
	local eventHandle = ""
	eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
		if(name ~= ADDON_NAME) then return end
		callback()
		UnregisterForEvent(event, name)
	end)
end

sidWarTools.RegisterForEvent = RegisterForEvent
sidWarTools.RegisterForCombatResult = RegisterForCombatResult
sidWarTools.UnregisterForEvent = UnregisterForEvent
sidWarTools.WrapFunction = WrapFunction
-----------------------------------------------------------------------------------------

local function InitializeChampionBarTooltip(saveData)
    if(saveData.enhanceChampionBarTooltip) then
        local cpBarType = PLAYER_PROGRESS_BAR.barTypeClasses[PPB_CLASS_CP]
        local ENLIGHTENMENT_PER_INCREASE_PER_DAY = 100000 * (GetEnlightenedMultiplier() + 1)
        local MAX_ENLIGHTENMENT_POOL_SIZE = 12 * ENLIGHTENMENT_PER_INCREASE_PER_DAY
        local ENLIGHTENMENT_CRITICAL_FORMAT = " (|cff0000%.0f%%|cffffff)"
        local ENLIGHTENMENT_NORMAL_FORMAT = " (%.0f%%)"
        function cpBarType:GetEnlightenedTooltip()
            local level = self:GetLevel()
            local levelSize = self:GetLevelSize(level)
            if levelSize then
                local poolSize = self:GetEnlightenedPool()
                local percent = poolSize * 100 / MAX_ENLIGHTENMENT_POOL_SIZE
                local nextPoint = GetChampionPointAttributeForRank(level + 1)
                local pointName = ZO_Champion_GetUnformattedConstellationGroupNameFromAttribute(nextPoint)
                local poolSizePercentFormat = (MAX_ENLIGHTENMENT_POOL_SIZE - ENLIGHTENMENT_PER_INCREASE_PER_DAY) < poolSize and ENLIGHTENMENT_CRITICAL_FORMAT or ENLIGHTENMENT_NORMAL_FORMAT
                local finalFormat = GetString(SI_EXPERIENCE_CHAMPION_ENLIGHTENED_TOOLTIP):gsub("<<1(.*)>>", "<<1%1>><<2>>")
                return string.format(zo_strformat(finalFormat, ZO_CommaDelimitNumber(poolSize), poolSizePercentFormat), percent)
            else
                return GetString(SI_EXPERIENCE_CHAMPION_ENLIGHTENED_TOOLTIP_MAXED)
            end
        end
    end
end

OnAddonLoaded(function()
	local saveData = sidWarTools.LoadSettings()
	sidWarTools.InitializeKeepClaimDialogFixes(saveData)
	sidWarTools.InitializeKeepNotifications(saveData)
	sidWarTools.InitializeKillNotifications(saveData)
	sidWarTools.InitializeQuickslotFixes(saveData)
	sidWarTools.InitializeCampaignBrowser(saveData)
	sidWarTools.InitializeMapObjectivesTab(saveData)
	sidWarTools.InitializeAttributeBars(saveData.attributeBars)
	sidWarTools.InitializeResurrectionNotification(saveData)
	sidWarTools.InitializeObjectiveLevelDisplay(saveData)
	sidWarTools.InitializeStealthIndicator(saveData)
	sidWarTools.InitializeAbilityLinkMenuEntries(saveData)
	InitializeChampionBarTooltip(saveData)

	local function Moisturize()
		if(not IsPlayerMoving()) then
			SLASH_COMMANDS["/bucketsplash"]()
			zo_callLater(Moisturize, 1500)
		end
	end
	SLASH_COMMANDS["/keepmoist"] = Moisturize
end)
