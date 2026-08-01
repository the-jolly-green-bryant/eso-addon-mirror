HardModeReminders = HardModeReminders or {}
local HMR = HardModeReminders

HMR.EventLoggerVars = {}

function HMR:IsUnitDead(unitTag)
	return IsUnitDead(unitTag)
end

function HMR:DoesUnitExist(unitTag)
	return DoesUnitExist(unitTag)
end

function HMR:IsUnitInCombat(unitTag)
	return IsUnitInCombat(unitTag)
end

function HMR:GetUnitPower(unitTag, POWERTYPE_HEALTH)
	return GetUnitPower(unitTag, POWERTYPE_HEALTH)
end

function HMR:GetUnitWorldPosition(unitTag)
	return GetUnitWorldPosition(unitTag)
end

function HMR:RegisterForUpdate(...)
	EVENT_MANAGER:RegisterForUpdate(...)
end

function HMR:UnregisterForUpdate(...)
	EVENT_MANAGER:UnregisterForUpdate(...)
end

function HMR:RegisterForEvent(...)
	EVENT_MANAGER:RegisterForEvent(...)
end

function HMR:AddFilterForEvent(...)
	EVENT_MANAGER:AddFilterForEvent(...)
end

function HMR:UnregisterForEvent(...)
	EVENT_MANAGER:UnregisterForEvent(...)
end

function HMR:GetUnitZoneIndex(unitTag)
	return GetUnitZoneIndex(unitTag)
end

function HMR:IsUnitOnline(unitTag)
	return IsUnitOnline(unitTag)
end

function HMR:IsUnitGrouped(unitTag)
	return IsUnitGrouped(unitTag)
end

function HMR:GetCurrentZoneDungeonDifficulty()
	return GetCurrentZoneDungeonDifficulty()
end

function HMR:GetPlayerActiveSubzoneName()
	return GetPlayerActiveSubzoneName()
end

function HMR:GetCurrentMapId()
	return GetCurrentMapId()
end

function HMR:GetUnitName(unitTag)
	return GetUnitName(unitTag)
end

function HMR:GetUnitRawWorldPosition(unitTag)
	return GetUnitRawWorldPosition(unitTag)
end