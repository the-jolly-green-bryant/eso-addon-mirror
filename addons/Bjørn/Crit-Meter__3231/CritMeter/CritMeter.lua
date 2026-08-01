local namespace = 'CritMeter'
local isUIUnlocked = false
local isPlayerInCombat = false
local sv
local critDamage = 0
local cpCritMod = 0
local debuffCritMod = 0

local defaults = {
    x = 300,
    y = 300,
}

local targetDebuffs = {
    [142610] = 5, -- Flame Weakness
    [142652] = 5, -- Frost Weakness
    [142653] = 5, -- Shock Weakness
    [145975] = 10, -- Minor Brittle
    [145977] = 20, -- Major Brittle
}

local playerBuffs = {
    61746, -- Minor Force
    61747, -- Major Force
    79909, -- Minor Enervation
    127192, -- Senche's Bite
    154737, -- Sul-Xan Soulbound
    155150, -- Harpooner's Wading Kilt
    194875, -- Fated Fortune
}

local EM = EVENT_MANAGER

local function UpdateUI()
    local totalCritDamage = 50 + critDamage + cpCritMod + debuffCritMod
    local isCap = totalCritDamage / 125 >= 1
    local colour = isCap and {0.49, 0.72, 0.34} or {0.92, 0.27, 0.38}

    CritMeter_UI_Text:SetText(totalCritDamage)
    CritMeter_UI_Bar:SetWidth(isCap and 194 or 194 * totalCritDamage / 125)
    CritMeter_UI_Bar:SetColor(unpack(colour))
end

local function OnCritDamageUpdated(eventCode, ...)
    _, _, critDamage = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE)

    UpdateUI()
end

local function GetTargetDebuffs(...)
    if DoesUnitExist('reticleover') and not IsUnitPlayer('reticleover') then
        debuffCritMod = 0
        for i = 1, GetNumBuffs('reticleover') do
            local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo('reticleover', i)

            if targetDebuffs[abilityId] then debuffCritMod = debuffCritMod + targetDebuffs[abilityId] end
        end

        UpdateUI()
    end
end

local function OnCPChanged(eventCode, result)
    if result == CHAMPION_PURCHASE_SUCCESS then
        cpCritMod = 0
        for disciplineIndex = 4, 8 do
            local championSkillId = GetSlotBoundId(disciplineIndex, HOTBAR_CATEGORY_CHAMPION)

            -- Backstabber CP
            if championSkillId == 31 then cpCritMod = cpCritMod + 15 end
        end

        UpdateUI()
    end
end

local function OnCombatStateChanged(eventCode, inCombat)
    if isPlayerInCombat ~= inCombat then
        if inCombat then
            isPlayerInCombat = true
            EM:RegisterForUpdate(namespace, 200, GetTargetDebuffs)
        else
            zo_callLater(function()
                if not IsUnitInCombat('player') then
                    isPlayerInCombat = false
                    EM:UnregisterForUpdate(namespace)
                end
            end, 3000)
        end
    end
end

local function OnPlayerActivated(eventCode, initial)
    OnCPChanged(nil, CHAMPION_PURCHASE_SUCCESS)
    OnCritDamageUpdated()

    -- Player could be in combat after a reloadui
    local inCombat = IsUnitInCombat('player')
    OnCombatStateChanged(nil, inCombat)
end

function CritMeterOnMoveStop()
    sv.x, sv.y = CritMeter_UI:GetCenter()
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName == namespace then
        EM:UnregisterForEvent(addonName, eventCode)

        sv = ZO_SavedVars:NewAccountWide('CritMeterSV', 1, nil, defaults)

        CritMeter_UI:ClearAnchors()
        CritMeter_UI:SetAnchor(CENTER, GuiRoot, TOPLEFT, sv.x, sv.y)

        local fragment = ZO_SimpleSceneFragment:New(CritMeter_UI)
        HUD_SCENE:AddFragment(fragment)
        HUD_UI_SCENE:AddFragment(fragment)

        for index, abilityId in ipairs(playerBuffs) do
            local id = namespace .. abilityId
            EM:RegisterForEvent(id, EVENT_EFFECT_CHANGED, OnCritDamageUpdated)
            EM:AddFilterForEvent(id, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId, REGISTER_FILTER_UNIT_TAG, 'player')
        end

        -- Hidden (Archer's Mind)
        EM:RegisterForEvent(namespace .. 'Hidden', EVENT_COMBAT_EVENT, OnCritDamageUpdated)
        EM:AddFilterForEvent(namespace .. 'Hidden', EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 20309, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

        EM:RegisterForEvent(namespace .. 'Reticle', EVENT_RETICLE_TARGET_CHANGED, GetTargetDebuffs)

        -- True-Sworn Fury
        EM:RegisterForEvent(namespace .. 'Health', EVENT_POWER_UPDATE, OnCritDamageUpdated)
        EM:AddFilterForEvent(namespace .. 'Health', EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTPYE_HEALTH)

        EM:RegisterForEvent(namespace .. 'Gear', EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnCritDamageUpdated)
        EM:AddFilterForEvent(namespace .. 'Gear', EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

        -- Nightblade's Hemorrhage, Templar's Piercing Spear and Warden's Advanced Species passives require skill slotted
        EM:RegisterForEvent(namespace .. 'Skill', EVENT_ACTION_SLOT_UPDATED, OnCritDamageUpdated)
        EM:RegisterForEvent(namespace .. 'AllSkills', EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, OnCritDamageUpdated)
        EM:RegisterForEvent(namespace .. 'Hotbar', EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, OnCritDamageUpdated)

        EM:RegisterForEvent(namespace .. 'CPChanged', EVENT_CHAMPION_PURCHASE_RESULT, OnCPChanged)

        EM:RegisterForEvent(namespace .. 'CombatState', EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)

        EM:RegisterForEvent(namespace .. 'PlayerActivated', EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    end
end

EM:RegisterForEvent(namespace, EVENT_ADD_ON_LOADED, OnAddonLoaded)

SLASH_COMMANDS['/critmeter'] = function()
    isUIUnlocked = not isUIUnlocked

    CritMeter_UI:SetMouseEnabled(isUIUnlocked)
    CritMeter_UI:SetMovable(isUIUnlocked)
end