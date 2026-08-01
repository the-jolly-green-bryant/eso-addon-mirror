local CC = CombatCoordinates

---------------------------------------------------------------------------
-- CALCULATE FORWARD POSITION BASED ON PLAYER HEADING (FOR OFFSETS)
---------------------------------------------------------------------------
function CC.GetForwardPosition(unitTag, x, y, z, offset)
    local normalizedX, normalizedZ, heading, isShownInCurrentMap = GetMapPlayerPosition(unitTag)
    if not heading then return x, y, z end

    local targetX = x - offset * math.sin(heading)
    local targetZ = z - offset * math.cos(heading)

    return targetX, y, targetZ
end

---------------------------------------------------------------------------
-- IDENTIFY THE UNIT TAG FROM THE COMBAT EVENT
---------------------------------------------------------------------------
local function GetUnitTagFromCombatEvent(sourceName, sourceType)
    if sourceType == COMBAT_UNIT_TYPE_PLAYER then
        return "player"
    end
    return nil
end

---------------------------------------------------------------------------
-- HANDLE COMBAT EVENTS FOR SUPPORTED SKILLS
---------------------------------------------------------------------------
function CC.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if not CC.SV.enableAddon then return end

    local unitTag = GetUnitTagFromCombatEvent(sourceName, sourceType)
    if not unitTag or unitTag ~= "player" then return end

    local skillData = CC.supportedSkills[abilityId]
    if not skillData then return end

    local currentTime = GetGameTimeMilliseconds()
    local cooldownKey = unitTag .. "_" .. tostring(abilityId)
    local lastCast = CC.cooldowns[cooldownKey] or 0

    if currentTime > (lastCast + skillData.duration) then
        local zone, x, y, z = GetUnitRawWorldPosition(unitTag)
        if x and y and z then
            CC.cooldowns[cooldownKey] = currentTime

            -- FETCH SPECIFIC SETTINGS FOR THIS SKILL
            local radius, numSides, lineWidth, heightOffset = CC.GetVisualSettings()
            local offset = CC.SV.standardOffset
            local colorSelf = CC.SV.standardColorSelf

            local drawX, drawY, drawZ = CC.GetForwardPosition(unitTag, x, y, z, offset)

            CC.DrawEffectCircle(drawX, drawY, drawZ, radius, colorSelf, skillData.duration, numSides, lineWidth, heightOffset)

            if CC.protocol and CC.protocol:IsFinalized() then
                CC.protocol:Send({
                    skillId = abilityId,
                    x = drawX,
                    y = drawY,
                    z = drawZ
                })
                CC.Debug("Own cast detected (" .. skillData.name .. "). Coordinates sent to group.")
            end
        end
    end
end

---------------------------------------------------------------------------
-- ENABLE ADDON EVENTS
---------------------------------------------------------------------------
function CC.Enable()
    for skillId, skillData in pairs(CC.supportedSkills) do
        local namespace = CC.name .. "_" .. tostring(skillId)
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, CC.OnCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
        EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, skillId)
    end
end

---------------------------------------------------------------------------
-- DISABLE ADDON EVENTS
---------------------------------------------------------------------------
function CC.Disable()
    for skillId, skillData in pairs(CC.supportedSkills) do
        local namespace = CC.name .. "_" .. tostring(skillId)
        EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_COMBAT_EVENT)
    end

    if CC.ClearAllEffects then
        CC.ClearAllEffects()
    end
end