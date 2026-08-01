local addonId = "LibUnitTracker"
local class = ZO_InitializingObject:Subclass()

local offlineName = "Offline"

function class:Initialize(name)
    self.name = name
    self.addonData = self:getAddonData()

    self.displayNameResolver = libUnitTrackerDisplayNameResolver:New(self)

    self.units = {}
    self.deadUnits = {}
    self.groupUnits = {}
    self.bossUnits = {}
    self.group = {}
    self.unitTags = {}

    self.groupUpdateHandler = LibHandler:Limiter(function()
        self:updateGroup()
    end, 50, true)

    self:eventHandlers()
end

function class:updateGroup()
    self.group = {}
    self.unitTags = {}

    for index = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(index)
        if DoesUnitExist(unitTag) then
            local unit = {
                index = index,
                tag = unitTag,
                rawName = GetRawUnitName(unitTag),
                name = ZO_CachedStrFormat(SI_UNIT_NAME, GetRawUnitName(unitTag)),
                displayName = GetUnitDisplayName(unitTag),
                classId = GetUnitClassId(unitTag),
                gender = GetUnitGender(unitTag),
                level = GetUnitLevel(unitTag),
                championPoints = GetUnitChampionPoints(unitTag),
                alliance = GetUnitAlliance(unitTag),
                raceId = GetUnitRaceId(unitTag),
                isOnline = IsUnitOnline(unitTag),
                isLeader = IsUnitGroupLeader(unitTag),
                isPlayer = AreUnitsEqual(unitTag, "player"),
            }
            self.group[index] = unit
            self.unitTags[unitTag] = unit.name
        end
    end
end

function class:eventHandlers()
    self.units = {}
    self.deadUnits = {}
    self.groupUnits = {}
    self.bossUnits = {}

    self:updateGroup()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_EFFECT_CHANGED, function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
        self.units[unitId] = self:ResolveName(unitName, self.units[unitId])
        if self:isGroupUnitTag(unitTag) then
            self.groupUnits[unitId] = self:ResolveName(unitName, self.groupUnits[unitId])
        end
        if self:isBossUnitTag(unitTag) then
            self.bossUnits[unitId] = self:ResolveName(unitName, self.bossUnits[unitId])
        end
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, function(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
        self.units[sourceUnitId] = self:ResolveName(sourceName, self.units[sourceUnitId])
        self.units[targetUnitId] = self:ResolveName(targetName, self.units[targetUnitId])
        if result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP then
            self.deadUnits[targetUnitId] = true
        end
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(eventCode, initial)
        self.units = {}
        self.deadUnits = {}
        self.groupUnits = {}
        self.bossUnits = {}
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BOSSES_CHANGED, function(eventCode)
        self.bossUnits = {}
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_JOINED, function(eventCode, memberCharacterName, memberDisplayName, isLocalPlayer)
        self.groupUpdateHandler:Trigger()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_LEFT, function(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
        self.groupUpdateHandler:Trigger()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_UPDATE, function(eventCode)
        self.groupUpdateHandler:Trigger()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_UNIT_CHARACTER_NAME_CHANGED, function(eventCode, unitTag)
        if self:isGroupUnitTag(unitTag) then
            self.groupUpdateHandler:Trigger()
        end
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_UNIT_CREATED, function(eventCode, unitTag)
        if self:isGroupUnitTag(unitTag) then
            self.groupUpdateHandler:Trigger()
        end
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_UNIT_DESTROYED, function(eventCode, unitTag)
        if self:isGroupUnitTag(unitTag) then
            self.groupUpdateHandler:Trigger()
        end
    end)
end

function class:GetUnitNameByUnitId(unitId)
    return self.units[unitId]
end

function class:GetDisplayNameByUnitName(unitName)
    return self.displayNameResolver:GetDisplayName(unitName)
end

function class:GetDisplayNameByUnitId(unitId)
    return self.displayNameResolver:GetDisplayName(self.units[unitId])
end

function class:GetUnitByUnitTag(unitTag)
    return self.unitTags[unitTag]
end

function class:GetGroup()
    return self.group
end

function class:IsDead(unitId)
    return self.deadUnits[unitId] == true
end

function class:IsBoss(unitId)
    return self.bossUnits[unitId] ~= nil
end

function class:IsGroup(unitId)
    return self.groupUnits[unitId] ~= nil
end

function class:isGroupUnitTag(unitTag)
    local start, _ = unitTag:find("^group%d+$")

    return start == 1
end

function class:isBossUnitTag(unitTag)
    local start, _ = unitTag:find("^boss%d+$")

    return start == 1
end

function class:ResolveName(...)
    local args = { ... }
    for i = 1, #args do
        local name = args[i]
        name = (name == nil or name == offlineName) and "" or ZO_CachedStrFormat(SI_UNIT_NAME, name)
        if name ~= "" then
            return name
        end
    end

    return ""
end

function class:getAddonData()
    for index = 1, GetAddOnManager():GetNumAddOns() do
        local name, title, author, description, enabled, state, isOutOfDate, isLibrary = GetAddOnManager():GetAddOnInfo(index)
        if name == self.name then
            return {
                name = name,
                title = title,
                author = author,
                version = GetAddOnManager():GetAddOnVersion(index),
                directoryPath = GetAddOnManager():GetAddOnRootDirectoryPath(index),
                resolveFilePath = function(relativePath)
                    local str, _ = string.format("%s%s", GetAddOnManager():GetAddOnRootDirectoryPath(index), relativePath):gsub("user:/AddOns", "", 1)
                    return str
                end
            }
        end
    end

    return nil
end

EVENT_MANAGER:RegisterForEvent(addonId, EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName ~= addonId then
        return
    end
    assert(not _G[addonId], string.format("'%s' has already been loaded", addonId))
    _G[addonId] = class:New(addonId)
    EVENT_MANAGER:UnregisterForEvent(addonId, EVENT_ADD_ON_LOADED)
end)
