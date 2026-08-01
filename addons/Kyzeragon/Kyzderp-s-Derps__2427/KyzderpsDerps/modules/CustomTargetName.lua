KyzderpsDerps = KyzderpsDerps or {}

local attributeVisuals = {
    [ATTRIBUTE_VISUAL_AUTOMATIC] = "AUTOMATIC",
    [ATTRIBUTE_VISUAL_DECREASED_MAX_POWER] = "DECREASED_MAX_POWER",
    [ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER] = "DECREASED_REGEN_POWER",
    [ATTRIBUTE_VISUAL_DECREASED_STAT] = "DECREASED_STAT",
    [ATTRIBUTE_VISUAL_INCREASED_MAX_POWER] = "INCREASED_MAX_POWER",
    [ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER] = "INCREASED_REGEN_POWER",
    [ATTRIBUTE_VISUAL_INCREASED_STAT] = "INCREASED_STAT",
    [ATTRIBUTE_VISUAL_NONE] = "NONE",
    [ATTRIBUTE_VISUAL_POSSESSION] = "POSSESSION",
    [ATTRIBUTE_VISUAL_POWER_SHIELDING] = "POWER_SHIELDING",
    [ATTRIBUTE_VISUAL_TRAUMA] = "TRAUMA",
    [ATTRIBUTE_VISUAL_UNWAVERING_POWER] = "UNWAVERING_POWER",
}

local derivedStats = {
    [STAT_ARMOR_RATING] = "ARMOR_RATING",
    [STAT_ATTACK_POWER] = "ATTACK_POWER",
    [STAT_BLOCK] = "BLOCK",
    [STAT_CRITICAL_RESISTANCE] = "CRITICAL_RESISTANCE",
    [STAT_CRITICAL_STRIKE] = "CRITICAL_STRIKE",
    [STAT_DAMAGE_RESIST_COLD] = "DAMAGE_RESIST_COLD",
    [STAT_DAMAGE_RESIST_DISEASE] = "DAMAGE_RESIST_DISEASE",
    [STAT_DAMAGE_RESIST_DROWN] = "DAMAGE_RESIST_DROWN",
    [STAT_DAMAGE_RESIST_EARTH] = "DAMAGE_RESIST_EARTH",
    [STAT_DAMAGE_RESIST_FIRE] = "DAMAGE_RESIST_FIRE",
    [STAT_DAMAGE_RESIST_GENERIC] = "DAMAGE_RESIST_GENERIC",
    [STAT_DAMAGE_RESIST_MAGIC] = "DAMAGE_RESIST_MAGIC",
    [STAT_DAMAGE_RESIST_OBLIVION] = "DAMAGE_RESIST_OBLIVION",
    [STAT_DAMAGE_RESIST_PHYSICAL] = "DAMAGE_RESIST_PHYSICAL",
    [STAT_DAMAGE_RESIST_POISON] = "DAMAGE_RESIST_POISON",
    [STAT_DAMAGE_RESIST_SHOCK] = "DAMAGE_RESIST_SHOCK",
    [STAT_DAMAGE_RESIST_START] = "DAMAGE_RESIST_START",
    [STAT_DODGE] = "DODGE",
    [STAT_HEALING_DONE] = "HEALING_DONE",
    [STAT_HEALING_TAKEN] = "HEALING_TAKEN",
    [STAT_HEALTH_MAX] = "HEALTH_MAX",
    [STAT_HEALTH_REGEN_COMBAT] = "HEALTH_REGEN_COMBAT",
    [STAT_HEALTH_REGEN_IDLE] = "HEALTH_REGEN_IDLE",
    [STAT_MAGICKA_MAX] = "MAGICKA_MAX",
    [STAT_MAGICKA_REGEN_COMBAT] = "MAGICKA_REGEN_COMBAT",
    [STAT_MAGICKA_REGEN_IDLE] = "MAGICKA_REGEN_IDLE",
    [STAT_MISS] = "MISS",
    [STAT_MITIGATION] = "MITIGATION",
    [STAT_MOUNT_STAMINA_MAX] = "MOUNT_STAMINA_MAX",
    [STAT_MOUNT_STAMINA_REGEN_COMBAT] = "MOUNT_STAMINA_REGEN_COMBAT",
    [STAT_MOUNT_STAMINA_REGEN_MOVING] = "MOUNT_STAMINA_REGEN_MOVING",
    [STAT_NONE] = "NONE",
    [STAT_PHYSICAL_PENETRATION] = "PHYSICAL_PENETRATION",
    [STAT_PHYSICAL_RESIST] = "PHYSICAL_RESIST",
    [STAT_POWER] = "POWER",
    [STAT_SPELL_CRITICAL] = "SPELL_CRITICAL",
    [STAT_SPELL_MITIGATION] = "SPELL_MITIGATION",
    [STAT_SPELL_PENETRATION] = "SPELL_PENETRATION",
    [STAT_SPELL_POWER] = "SPELL_POWER",
    [STAT_SPELL_RESIST] = "SPELL_RESIST",
    [STAT_STAMINA_MAX] = "STAMINA_MAX",
    [STAT_STAMINA_REGEN_COMBAT] = "STAMINA_REGEN_COMBAT",
    [STAT_STAMINA_REGEN_IDLE] = "STAMINA_REGEN_IDLE",
    [STAT_WEAPON_AND_SPELL_DAMAGE] = "WEAPON_AND_SPELL_DAMAGE",
}

local attributes = {
    [ATTRIBUTE_HEALTH] = "HEALTH",
    [ATTRIBUTE_MAGICKA] = "MAGICKA",
    [ATTRIBUTE_NONE] = "NONE",
    [ATTRIBUTE_STAMINA] = "STAMINA",
}

-- EVENT_RETICLE_TARGET_CHANGED(number eventCode)
local function OnReticleTargetChanged()
    local targetName = GetUnitName("reticleover")

    if (targetName == "") then
        if (KyzderpsDerps.savedOptions.customTargetFrame.move == false) then
            CustomTargetCustomName:SetHidden(true)
        end
        return
    end

    local customName = ""
    local customColor = {1,1,1}

    ------------------------------------------------------------
    -- 1 means player
    if (GetUnitType("reticleover") == 1) then
        targetName = GetUnitDisplayName("reticleover")
        if (not KyzderpsDerps.savedOptions.customTargetFrame.player.enable) then
            if (KyzderpsDerps.savedOptions.customTargetFrame.move == false) then
                CustomTargetCustomName:SetHidden(true)
            end
            return
        end

        local entry = KyzderpsDerps.savedValues.customTargetFrame.playerCustom[targetName]
        if (entry) then
            customName = entry.customName
            customColor = entry.color
        elseif (not KyzderpsDerps.savedOptions.customTargetFrame.player.useFilter) then
            -- If no custom name is found, leave it empty if the filter is on
            -- If filter is not on, then we display the regular target name
            customName = targetName
        end

        if (customName ~= "") then
            KyzderpsDerps.recentPlayer = targetName
        end

    ------------------------------------------------------------
    else -- NPCs
        KyzderpsDerps.recentNpc = targetName
        if (not KyzderpsDerps.savedOptions.customTargetFrame.npc.enable) then
            if (KyzderpsDerps.savedOptions.customTargetFrame.move == false) then
                CustomTargetCustomName:SetHidden(true)
            end
            return
        end

        local entry = KyzderpsDerps.savedValues.customTargetFrame.npcCustom[targetName]
        if (entry) then
            customName = entry.customName
            customColor = entry.color
        elseif (not KyzderpsDerps.savedOptions.customTargetFrame.npc.useFilter) then
            -- If no custom name is found, leave it empty if the filter is on
            -- If filter is not on, then we display the regular target name
            customName = targetName
        end

        if (customName ~= "") then
            KyzderpsDerps.recentNpc = targetName
        end
    end

    ------------------------------------------------------------
    -- Display/Hide
    if (customName ~= "") then
        CustomTargetCustomName:SetHidden(false)
        CustomTargetCustomNameLabel:SetText(customName)
        CustomTargetCustomNameLabel:SetColor(unpack(customColor))

        -- Display attribute visualizer
        local line = ""
        -- if (KyzderpsDerps.savedOptions.general.experimental) then
        --     local effectInfos = {GetAllUnitAttributeVisualizerEffectInfo("reticleover")}
        --     for i = 1, 12 do
        --         local j = (i - 1) * 6 + 1
        --         if (effectInfos[j]) then
        --             local unitAttributeVisual = effectInfos[j]
        --             local statType = effectInfos[j + 1]
        --             local attributeType = effectInfos[j + 2]
        --             local powerType = effectInfos[j + 3]
        --             local value = effectInfos[j + 4]
        --             local maxValue = effectInfos[j + 5]
        --             line = line .. string.format("%s %s %s %s %d %d\n",
        --                 attributeVisuals[unitAttributeVisual], derivedStats[statType], attributes[attributeType], mechanicTypes[powerType], value, maxValue)
        --         end
        --     end
        -- end
        CustomTargetCustomNameVisual:SetText(line)

    elseif (KyzderpsDerps.savedOptions.customTargetFrame.move == false) then
        CustomTargetCustomName:SetHidden(true)
    end
end

---------------------------------------------------------------------
function KyzderpsDerps.InitializeCustomTargetName()
    KyzderpsDerps:dbg("    Initializing CustomTargetName module...")

    -- Register
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name, EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "CustomTargetPlayerActivated", EVENT_PLAYER_ACTIVATED, OnReticleTargetChanged)

    -- Position
    CustomTargetCustomName:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        KyzderpsDerps.savedValues.customTargetFrame.x,
        KyzderpsDerps.savedValues.customTargetFrame.y)
    CustomTargetCustomNameLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", KyzderpsDerps.savedOptions.customTargetFrame.size))
end
