--[[
todo:
custom rotations & LAM
add more skills & classes
show queue
gcd tracker on an icon like https://www.esoui.com/downloads/info2627-GlobalCooldownMonitor.html
add support for ults
add support for potions
add casting/channeling indicator (combined w/ gcd tracker)
clear the skills that are not actually slotted
]]
Rotations = Rotations or {}
Rotations.name = "Rotations"
Rotations.AbilityTimers = {}
Rotations.AbilityKeyMap = {}
Rotations.AbilityBars = {}

function Rotations.OnUpdate(self, time)
    local isUnitInReticleInvulnerable =
        GetUnitAttributeVisualizerEffectInfo(
        "reticleover",
        ATTRIBUTE_VISUAL_UNWAVERING_POWER,
        STAT_MITIGATION,
        ATTRIBUTE_HEALTH,
        POWERTYPE_HEALTH
    )
    local isEnemyInReticle =
        DoesUnitExist("reticleover") and IsUnitAttackable("reticleover") and (not IsUnitDead("reticleover")) and
        (not AreUnitsCurrentlyAllied("player", "reticleover")) and
        (not isUnitInReticleInvulnerable)
    local reticleEnemyHpPercent = 0
    if isEnemyInReticle then
        local currentEnemyHealth, maxEnemyHealth, effectiveEnemyMaxHealth =
            GetUnitPower("reticleover", POWERTYPE_HEALTH)
        reticleEnemyHpPercent = currentEnemyHealth / maxEnemyHealth
    end

    local activeBar = GetActiveWeaponPairInfo()
    for i = 3, 7 do
        local abilityId = GetSlotBoundId(i)
        --d(abilityId)
        Rotations.AbilityKeyMap[abilityId] = GetKeyName(GetActionBindingInfo(1, 2, i + 7, 1))
        Rotations.AbilityTimers[abilityId] = Rotations.AbilityTimers[abilityId] or 0
        Rotations.AbilityBars[abilityId] = activeBar
    end

    Rotations.ActivePlayerBuffs = {}
    local numberOfPlayerBuffs = GetNumBuffs("player")
    for i = 0, numberOfPlayerBuffs do
        local buffName, _, _, _, stackCount, _, _, _, _, _, abilityId, _ = GetUnitBuffInfo("player", i)
        --d(abilityId .. ' ' .. buffName .. ' ' .. stackCount)
        if abilityId == 61920 then
            --Merciless Resolve stack
            if stackCount >= 4 then
                Rotations.ActivePlayerBuffs[abilityId] = true
            end
        elseif abilityId == 122658 then
            --Seething Fury stack
            if stackCount == 3 then
                Rotations.ActivePlayerBuffs[abilityId] = true
            end
        else
            Rotations.ActivePlayerBuffs[abilityId] = true
        end
    end

    --clear merciless resolve proc if the buff is absent (it expired or was just casted)
    if (Rotations.ActivePlayerBuffs[61920] == nil) then
        Rotations.AbilityTimers[61930] = nil
    else
        Rotations.AbilityTimers[61930] = 0
    end

    --clear crystal shards proc if the buff is absent (it expired or was just casted)
    if (Rotations.ActivePlayerBuffs[46327] == nil) then
        Rotations.AbilityTimers[114716] = nil
    else
        Rotations.AbilityTimers[114716] = 0
    end

    --procs keys
    --merciless resolve
    Rotations.AbilityKeyMap[61930] = Rotations.AbilityKeyMap[61919]
    --crystal shards
    Rotations.AbilityKeyMap[114716] = Rotations.AbilityKeyMap[46324]

    local abilityIdToCastNext = -1

    --[[
    local quickSlotId = GetCurrentQuickslot()
	local quickSlotAbilityId = GetSlotBoundId(quickSlotId)
    if (quickSlotAbilityId ~= 0) and (GetSlotItemCount(quickSlotId) > 0) then
        quickSlotCooldown, _ = GetSlotCooldownInfo(quickSlotId)
		if quickSlotCooldown == 0 then
			abilityIdToCastNext = quickSlotAbilityId
		end
    end
	]]
    if abilityIdToCastNext == -1 then
        --if we have molten whip and 3 stacks of seething fury
        if (Rotations.AbilityKeyMap[20805] ~= nil) and (Rotations.ActivePlayerBuffs[122658]) then
            abilityIdToCastNext = 20805
        end
    end

    if abilityIdToCastNext == -1 then
        for k, v in pairs(Rotations.Dots) do
            if
                (Rotations.AbilityTimers[v] ~= nil) and (Rotations.AbilityTimers[v] < time) and
                    not Rotations.ShouldDropAbilityDueToHpPercent(v, reticleEnemyHpPercent)
             then
                abilityIdToCastNext = v
                break
            end
        end
    end

    --no dots left to cast
    if abilityIdToCastNext == -1 then
        for k, v in pairs(Rotations.Spammables) do
            if
                (Rotations.AbilityKeyMap[v] ~= nil) and --skill is present in the skillbar
                    (not Rotations.ShouldDropAbilityDueToHpPercent(v, reticleEnemyHpPercent))
             then
                abilityIdToCastNext = v
                break
            end
        end
    end

    if isEnemyInReticle and abilityIdToCastNext ~= -1 then
        RotationsQueueControl:SetAlpha(1)
        local abilityToCastIsOnDifferentBar = Rotations.AbilityBars[abilityIdToCastNext] ~= activeBar
        RotationsQueueControlKey:SetText(Rotations.AbilityKeyMap[abilityIdToCastNext])
        RotationsQueueControlAlert:SetTexture(GetAbilityIcon(abilityIdToCastNext))
        RotationsQueueControlBarSwap:SetAlpha(abilityToCastIsOnDifferentBar and 0.75 or 0)
    else
        RotationsQueueControl:SetAlpha(0)
    end
end

function Rotations.ShouldDropAbilityDueToHpPercent(abilityId, reticleEnemyHpPercent)
    local hpPercentToDropAbility = Rotations.SkillsToDropAtHpPercent[abilityId]
    if hpPercentToDropAbility == nil then
        return false
    end
    return reticleEnemyHpPercent <= hpPercentToDropAbility
end

function Rotations.OnActionSlotAbilityUsed(eventCode, slotNum)
    if (slotNum == 1) or (slotNum == 2) then
        return
    end
    local abilityId = GetSlotBoundId(slotNum)
    local duration = GetAbilityDuration(abilityId) / 1000
    if Rotations.AdditionalSkillDurations[abilityId] ~= nil then
        duration = Rotations.AdditionalSkillDurations[abilityId]
    end
    Rotations.AbilityTimers[abilityId] = (GetGameTimeMilliseconds() / 1000) + duration
end

function Rotations.OnPlayerActivated()
    for i = 3, 7 do
        for _, hotbarCategory in pairs({HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP}) do
            local abilityId = GetSlotBoundId(i, hotbarCategory)
            Rotations.AbilityKeyMap[abilityId] = GetKeyName(GetActionBindingInfo(1, 2, i + 7, 1))
            Rotations.AbilityTimers[abilityId] = 0
            Rotations.AbilityBars[abilityId] = (hotbarCategory == HOTBAR_CATEGORY_PRIMARY) and 1 or 2
        end
    end
end

function Rotations:Initialize()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTION_SLOT_ABILITY_USED, self.OnActionSlotAbilityUsed)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, self.OnPlayerActivated)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
end

function Rotations.OnAddOnLoaded(_, addonName)
    if addonName == Rotations.name then
        Rotations:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(Rotations.name, EVENT_ADD_ON_LOADED, Rotations.OnAddOnLoaded)
