local EVENT_NAMESPACE = 'IMP_PERMAGLOW_EVENT_NAMESPACE'

local GRIM_FOCUS = {
    [61902] = true,
    [61927] = true,
    [61919] = true,
}

local EFFECTS = {
    [61902] = 122585,
    [61927] = 122587,
    [61919] = 122586,
}


local HOTBAR
local SLOT_INDEX
local ABILITY_ID
local EFFECT_ID
local DELAY_DURATION = 150


-- local REMOVED_MS


local function isGlowing()
    for i = 1, GetNumBuffs('player') do
        local buffName, startTime, endTime, buffSlot, stackCount, iconFile, deprecatedBuffType, effectType, abilityType, statusEffectType, abilityId, canClickOff = GetUnitBuffInfo("player", i)

        if abilityId == EFFECT_ID then
            -- df('GLOWING: %s - %d, %d stacks, can click off: %s', buffName, abilityId, stackCount, tostring(canClickOff))
            return true
        end
    end
end

local function directCheck()
    local slotData = HOTBAR:GetSlotData(SLOT_INDEX)
    if slotData:IsEmpty() then
        -- d('Ability slot is empty')
        HOTBAR:AssignSkillToSlotByAbilityId(SLOT_INDEX, ABILITY_ID)
    end
end

local function onCombatState(_, inCombat)
    if inCombat then return end

    if isGlowing() then
        HOTBAR:ClearSlot(SLOT_INDEX)
        -- REMOVED_MS = GetGameTimeMilliseconds()

        zo_callLater(function()
            local result = HOTBAR:AssignSkillToSlotByAbilityId(SLOT_INDEX, ABILITY_ID)
            -- df('Slotting the skill, result: %s', tostring(result))
        end, DELAY_DURATION)
    end

    zo_callLater(directCheck, DELAY_DURATION + 500)
end

--[[
local function onEffectChanged(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    local ms = GetGameTimeMilliseconds()

    if unitTag ~= 'player' then return end
    -- if changeType ~= EFFECT_RESULT_FADED then return end
    if abilityId ~= EFFECT_ID then return end

    local result = HOTBAR:AssignSkillToSlotByAbilityId(SLOT_INDEX, ABILITY_ID)
    -- df('Slotting the skill, result: %s', tostring(result))

    -- df('Skill returned back in %d ms', ms - REMOVED_MS)
end
--]]

local function detectGrimFocus()
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE)

    for hotbarCategory = HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP do
        local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(hotbarCategory)

        for slotIndex = 3, 7 do
            local slotData = hotbar:GetSlotData(slotIndex)
            if not slotData:IsEmpty() then
                local abilityId = slotData:GetEffectiveAbilityId()
                if GRIM_FOCUS[abilityId] then
                    -- df('%d - %d', slotIndex, slotData:GetEffectiveAbilityId())
                    HOTBAR = hotbar
                    SLOT_INDEX = slotIndex
                    ABILITY_ID = abilityId
                    EFFECT_ID = EFFECTS[abilityId]

                    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE, onCombatState)
                    -- d('Grim focus detected, feature enabled')

                    return
                end
            end
        end
    end

    -- d('Grim focus not found, feature disabled')
end

local function Setup()
    detectGrimFocus()

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, detectGrimFocus)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ABILITY_LIST_CHANGED, detectGrimFocus)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_SKILL_RESPEC_RESULT, detectGrimFocus)

    onCombatState(nil, IsUnitInCombat('player'))
end

local function Unsetup()
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ABILITY_LIST_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_SKILL_RESPEC_RESULT)

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE)
end

-- ----------------------------------------------------------------------------

local feature = {}

function feature.Setup(addon)
    if not addon.savedVariables.permaglow.enabled then return end
    Setup()
end

function feature.GetSettingsControl(addon)
    return {
        {
            type = 'checkbox',
            name = 'Autoremove Grim Focus glow',
            getFunc = function() return addon.savedVariables.permaglow.enabled end,
            setFunc = function(value)
                Unsetup()
                addon.savedVariables.permaglow.enabled = value
                if value then Setup() end
            end,
            -- requiresReload = true,
        },
    }
end


assert(ImpifiedUI, 'ImpifiedUI not found')
ImpifiedUI:AddFeature(feature)
