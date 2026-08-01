CombatCloud_CombatEventListener = CombatCloud_EventListener:Subclass()
local C = CombatCloudConstants
local callLater = zo_callLater

local isWarned = {
    combat          = false,
    cleanse         = false,
    disoriented     = false,
    feared          = false,
    offBalanced     = false,
    silenced        = false,
    stunned         = false,
}

function CombatCloud_CombatEventListener:New()
    local obj = CombatCloud_EventListener:New()
    obj:RegisterForEvent(EVENT_COMBAT_EVENT, function(...) self:OnEvent(...) end)
    obj:RegisterForEvent(EVENT_PLAYER_COMBAT_STATE, function() self:CombatState() end)
    return obj
end

function CombatCloud_CombatEventListener:OnEvent(...)
    local resultType, isError, abilityName, abilityGraphic, abilityAction_slotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId = ...
    local S, combatType, togglesInOut = CombatCloudSettings, nil, nil
---------------------------------------------------------------------------------------------------------------------------------------
    --//INCOMING OUTGOING DIRECION//--
---------------------------------------------------------------------------------------------------------------------------------------
    if (C.isPlayer[targetType]) then --Incoming
        combatType = C.combatType.INCOMING
        togglesInOut = S.toggles.incoming
    elseif (C.isPlayer[sourceType]) then --Outgoing
        combatType = C.combatType.OUTGOING
        togglesInOut = S.toggles.outgoing
    else return end
---------------------------------------------------------------------------------------------------------------------------------------
    --//RESULTS//--
---------------------------------------------------------------------------------------------------------------------------------------
    --Damage
    local isDamage, isDot
        = C.isDamage[resultType], C.isDot[resultType]
    --Healing
    local isHealing, isHot
        = C.isHealing[resultType], C.isHot[resultType]
    --Energize & Drain
    local isEnergize, isDrain
        = C.isEnergize[resultType], C.isDrain[resultType]
    --Mitigation
    local isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted
        = C.isMiss[resultType], C.isImmune[resultType], C.isParried[resultType], C.isReflected[resultType], C.isDamageShield[resultType], C.isDodged[resultType], C.isBlocked[resultType], C.isInterrupted[resultType]
    --Crowd Control
    local isDisoriented, isFeared, isOffBalanced, isSilenced, isStunned
        = C.isDisoriented[resultType], C.isFeared[resultType], C.isOffBalanced[resultType], C.isSilenced[resultType], C.isStunned[resultType]
---------------------------------------------------------------------------------------------------------------------------------------
    --//COMBAT TRIGGERS//--
---------------------------------------------------------------------------------------------------------------------------------------
    if (isDodged and togglesInOut.showDodged) or
       (isMiss and togglesInOut.showMiss) or
       (isImmune and togglesInOut.showImmune) or
       (isReflected and S.toggles.outgoing.showReflected) or --If incoming is allowed, it will display whenever you cast reflect spells but with just outgoing it displays whenever incoming damage is reflected
       (isDamageShield and togglesInOut.showDamageShield) or
       (isParried and togglesInOut.showParried) or
       (isBlocked and togglesInOut.showBlocked) or
       (isInterrupted and togglesInOut.showInterrupted) or
       (isDot and togglesInOut.showDot) or
       (isHot and togglesInOut.showHot) or
       (isHealing and togglesInOut.showHealing) or
       (isDamage and togglesInOut.showDamage) or
       (isEnergize and togglesInOut.showEnergize and (powerType == POWERTYPE_MAGICKA or powerType == POWERTYPE_STAMINA)) or
       (isEnergize and togglesInOut.showUltimateEnergize and powerType == POWERTYPE_ULTIMATE) or
       (isDrain and togglesInOut.showDrain and not (abilityName == "Sprint Drain") and (powerType == POWERTYPE_MAGICKA or powerType == POWERTYPE_STAMINA)) then
            if (S.toggles.inCombatOnly and isWarned.combat) or (not S.toggles.inCombatOnly) then --Check if 'in combat only' is ticked
                self:TriggerEvent(C.eventType.COMBAT, combatType, powerType, hitValue, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, C.isCritical[resultType])
            end
    end
---------------------------------------------------------------------------------------------------------------------------------------
    --//CROWD CONTROL & CLEANSE TRIGGERS//--
---------------------------------------------------------------------------------------------------------------------------------------
    if (isWarned.combat) then --Only show CC/Debuff events when in combat
        --Cleanse
        if (isDot and S.toggles.showAlertCleanse and not isWarned.cleanse and not C.isPlayer[sourceType]) then
            self:TriggerEvent(C.eventType.ALERT, C.alertType.CLEANSE, nil)
            isWarned.cleanse = true
            callLater(function() isWarned.cleanse = false end, 5000) --5 second buffer
        end
        --Disoriented
        if (isDisoriented and togglesInOut.showDisoriented) then
            if (isWarned.disoriented) then
                PlaySound('Ability_Failed') --will play a sound every disoriented event afterwards, as any failed action during a CC retriggers the event, causing text flood if buttons are spammed
            else
                self:TriggerEvent(C.eventType.CROWDCONTROL, C.crowdControlType.DISORIENTED, combatType)
                isWarned.disoriented = true
                callLater(function() isWarned.disoriented = false end, 1000) end --1 second buffer
        end
        --Feared
        if (isFeared and togglesInOut.showFeared) then
            if (isWarned.feared) then
                PlaySound('Ability_Failed')
            else
                self:TriggerEvent(C.eventType.CROWDCONTROL, C.crowdControlType.FEARED, combatType)
                isWarned.feared = true
                callLater(function() isWarned.feared = false end, 1000) end --1 second buffer
        end
        --OffBalanced
        if (isOffBalanced and togglesInOut.showOffBalanced) then
            if (isWarned.offBalanced) then
                PlaySound('Ability_Failed')
            else
                self:TriggerEvent(C.eventType.CROWDCONTROL, C.crowdControlType.OFFBALANCED, combatType)
                isWarned.offBalanced = true
                callLater(function() isWarned.offBalanced = false end, 1000) end --1 second buffer
        end
        --Silenced
        if (isSilenced and togglesInOut.showSilenced) then
            if (isWarned.silenced) then
                PlaySound('Ability_Failed')
            else
                self:TriggerEvent(C.eventType.CROWDCONTROL, C.crowdControlType.SILENCED, combatType)
                isWarned.silenced = true
                callLater(function() isWarned.silenced = false end, 1000) end --1 second buffer
        end
        --Stunned
        if (isStunned and togglesInOut.showStunned) then
            if (isWarned.stunned) then
                PlaySound('Ability_Failed')
            else
                self:TriggerEvent(C.eventType.CROWDCONTROL, C.crowdControlType.STUNNED, combatType)
                isWarned.stunned = true
                callLater(function() isWarned.stunned = false end, 1000) end --1 second buffer
        end
    end
end

---------------------------------------------------------------------------------------------------------------------------------------
    --//COMBAT STATE EVENTS & TRIGGERS//--
---------------------------------------------------------------------------------------------------------------------------------------
function CombatCloud_CombatEventListener:CombatState(inCombat)
    local S = CombatCloudSettings

    if not isWarned.combat then
        isWarned.combat = true
        if S.toggles.showInCombat then
            self:TriggerEvent(C.eventType.POINT, C.pointType.IN_COMBAT, nil)
        end
    else
        isWarned.combat = false
        if S.toggles.showOutCombat then
            self:TriggerEvent(C.eventType.POINT, C.pointType.OUT_COMBAT, nil)
        end
    end
end