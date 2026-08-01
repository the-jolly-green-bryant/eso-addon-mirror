if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop

------------------------------------------------------------------------------------------------------------
-- Debug
------------------------------------------------------------------------------------------------------------

function FCOSS.debugAbility(abilityId)
    if abilityId ~= nil and PopupTooltip ~= nil then
        PopupTooltip:ClearLines()
        PopupTooltip:SetAbilityId(abilityId)
        PopupTooltip:SetHidden(false)
    end
end

function FCOSS.debugEvent(effectName, effectType)
    effectType = effectType or EFFECT_RESULT_FADED
    FCOSS.OnEventEffectChanged(nil, effectType, nil, effectName, "player")
end

function FCOSS.debugActiveBuffs()
    if DEBUG_ACTIVE_BUFFS and type(DEBUG_ACTIVE_BUFFS) == "function" then
        DEBUG_ACTIVE_BUFFS()
    else
        local numBuffsOnPlayer = GetNumBuffs("player")
        local name = ""
        d(FCOSS.locVars.preChatTextGreen .. "[debugActiveBuffs] START")
        for buffIndex = 1, numBuffsOnPlayer do
            --** _Returns:_ *string* _buffName_, *number* _timeStarted_, *number* _timeEnding_, *integer* _buffSlot_, *integer* _stackCount_, *textureName* _iconFilename_, *string* _buffType_, *[BuffEffectType|#BuffEffectType]* _effectType_, *[AbilityType|#AbilityType]* _abilityType_, *[StatusEffectType|#StatusEffectType]* _statusEffectType_, *integer* _abilityId_, *bool* _canClickOff_
            local buffName, startTime, endTime, buffSlot, stackCount, iconFile, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff = GetUnitBuffInfo("player", buffIndex)
            name = buffName
            --Remove trailing ^f endings etc...
            name = string.gsub(name, "%^.*", "")
            d("-> " .. name .. ", AbilityId: " .. tostring(abilityId))
        end
        d(FCOSS.locVars.preChatTextRed .. "[debugActiveBuffs] END")
    end
end

function FCOSS.debugDungeon()
    local abort = false
    local abortVar
    local isInDelve = false
    local isInPublicDungeon = false
    local isInGroupDungeon = false
    local isInRaid = IsPlayerInRaid()
    local isInGroup = IsUnitGrouped("player")
    local iconPath = ""
    local isInAnyDungeon = IsAnyGroupMemberInDungeon() -- returns true if not in group and in solo dungeon/delve
    --Check if user is in any dungeon
    if not isInGroup then
        isInDelve = isInAnyDungeon
    else
        local groupSize = GetGroupSize() --SMALL_GROUP_SIZE_THRESHOLD (4) / RAID_GROUP_SIZE_THRESHOLD (12) / GROUP_SIZE_MAX (24)
        isInDelve = isInAnyDungeon and not isInRaid and groupSize <= SMALL_GROUP_SIZE_THRESHOLD
    end
    local zoneIndex, poiIndex = GetCurrentSubZonePOIIndices()
    if zoneIndex == nil then abort = true abortVar = "zoneIndex" end
    if poiIndex == nil then abort = true abortVar = abortVar .. " poiIndex" end
    if poiIndex ~= nil then
        local _, _, _, iconPath = GetPOIMapInfo(zoneIndex, poiIndex)
        if iconPath:find("poi_delve") then
            -- in a delve
            isInDelve = true
        end
    end
    if iconPath == nil then iconPath = "n/a" end
    if not abort then
        isInPublicDungeon = IsPOIPublicDungeon(zoneIndex, poiIndex)
        isInGroupDungeon = IsPOIGroupDungeon(zoneIndex, poiIndex)
        if isInPublicDungeon then
            isInDelve = false
            isInGroupDungeon = false
        elseif isInGroupDungeon then
            isInDelve = false
            isInPublicDungeon = false
        end
        d("delve: " .. tostring(isInDelve) .. ", pubDung: " .. tostring(isInPublicDungeon) .. ", groupDun: " .. tostring(isInGroupDungeon) .. ", raid: " .. tostring(isInRaid) .. ", iconPath: " .. iconPath)
    else
        d("[Aborted] " .. abortVar .. "!, delve: " .. tostring(isInDelve) .. ", pubDung: " .. tostring(isInPublicDungeon) .. ", groupDun: " .. tostring(isInGroupDungeon) .. ", raid: " .. tostring(isInRaid) .. ", iconPath: " .. iconPath)
    end
end