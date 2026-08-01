local DMT = DeadMansTally


---------------------------------------------------------------------
local function StartsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

local function EndsWith(str, suffix)
    return string.sub(str, #str - #suffix + 1) == suffix
end


---------------------------------------------------------------------
local function SaveDeathSub(subtable, name)
    if (not subtable[name]) then
        subtable[name] = 0
    end
    subtable[name] = subtable[name] + 1
end

local dmtLFCPFilter
local function SaveDeath(tagType, name)
    if (name == "") then
        name = "[Empty name]"
    end

    if (dmtLFCPFilter) then
        dmtLFCPFilter:AddMessage(string.format("%s death: %s", tagType, name))
    end

    SaveDeathSub(DMT.svs.foreverDeaths[tagType], name)
    SaveDeathSub(DMT.svs.currentDeaths[tagType], name)
    DMT.UpdateAll()
end


---------------------------------------------------------------------
local function OnDeathStateChanged(_, unitTag, isDead)
    if (not isDead) then return end

    if (unitTag == "player") then
        if (IsUnitGrouped("player")) then return end -- Ignore grouped player, group death will cover it
        SaveDeath("ungroupedplayer", GetUnitDisplayName(unitTag))
        return
    end

    if (StartsWith(unitTag, "playerpet")) then
        SaveDeath("playerpet", GetUnitName(unitTag))
        return
    end

    if (StartsWith(unitTag, "boss")) then
        SaveDeath("boss", GetUnitName(unitTag))
        return
    end

    if (unitTag == "companion") then
        SaveDeath("companion", GetUnitName(unitTag))
        return
    end

    if (StartsWith(unitTag, "group")) then
        if (EndsWith(unitTag, "companion")) then
            if (not AreUnitsEqual(unitTag, "companion")) then -- Ignore self companion in group, companion will cover it
                SaveDeath("groupcompanion", GetUnitName(unitTag))
            end
        else
            SaveDeath("group", GetUnitDisplayName(unitTag))
        end
        return
    end
end

function DMT.InitializeCore()
    EVENT_MANAGER:RegisterForEvent(DMT.name .. "Death", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)

    -- Debug chat
    if (LibFilteredChatPanel) then
        dmtLFCPFilter = LibFilteredChatPanel:CreateFilter(DMT.name, "/esoui/art/icons/mapkey/mapkey_groupboss.dds", {0.5, 0.5, 0.5}, false)
    end
end
