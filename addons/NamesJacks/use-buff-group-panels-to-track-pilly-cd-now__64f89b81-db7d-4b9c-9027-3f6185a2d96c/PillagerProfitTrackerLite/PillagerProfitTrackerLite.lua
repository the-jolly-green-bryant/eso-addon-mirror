local PillagerProfitTracker = {}

local COOLDOWN_DURATION = 45
local PILLAGER_PROFIT_GEAR_BUFF_ID = 186835

local cooldownRemaining = 0
local isOnCooldown = false

local DEFAULT_FONT = "ZoFontGamepad34"

local function CreateUI()
    PillagerProfitTracker.label = WINDOW_MANAGER:CreateControl(nil, ZO_CompassFrame, CT_LABEL)
    local label = PillagerProfitTracker.label
    label:SetFont(DEFAULT_FONT)
    label:SetText("Pillager's Profit Cooldown: Ready")
    label:SetHidden(false)
    label:SetMovable(false)
    label:SetMouseEnabled(false)
    label:SetClampedToScreen(true)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 240, 945)

    PillagerProfitTracker.icon = WINDOW_MANAGER:CreateControl(nil, ZO_CompassFrame, CT_TEXTURE)
    local icon = PillagerProfitTracker.icon
    icon:SetDimensions(40, 40)
    icon:SetAnchor(LEFT, label, RIGHT, 10, 0)
    icon:SetHidden(true)
    icon:SetTexture("PillagerProfitTrackerLite/pillagers_profit_icon.dds")

    EVENT_MANAGER:RegisterForUpdate("PillagerProfitTrackerLabelUpdate", 500, function()
        if isOnCooldown then
            label:SetText("Pillager's Profit Cooldown: " .. cooldownRemaining .. "s")
        else
            label:SetText("Pillager's Profit Cooldown: Ready")
        end
    end)
end

local function StartCooldown()
    cooldownRemaining = COOLDOWN_DURATION
    isOnCooldown = true
    EVENT_MANAGER:UnregisterForUpdate("PillagerProfitCooldownTick")
    EVENT_MANAGER:RegisterForUpdate("PillagerProfitCooldownTick", 1000, function()
        cooldownRemaining = cooldownRemaining - 1
        if cooldownRemaining <= 0 then
            cooldownRemaining = 0
            isOnCooldown = false
            EVENT_MANAGER:UnregisterForUpdate("PillagerProfitCooldownTick")
        end
    end)
end

local function OnUltimateUsed(eventCode, slotNum)
    if slotNum == 8 then
        StartCooldown()
    end
end

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount,
                               iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if abilityId == PILLAGER_PROFIT_GEAR_BUFF_ID and PillagerProfitTracker.icon then
        if changeType == EFFECT_RESULT_GAINED then
            PillagerProfitTracker.icon:SetHidden(false)
        elseif changeType == EFFECT_RESULT_FADED then
            PillagerProfitTracker.icon:SetHidden(true)
        end
    end
end

function PillagerProfitTracker.OnAddOnLoaded(event, addonName)
    if addonName == "PillagerProfitTrackerLite" then
        CreateUI()
        EVENT_MANAGER:RegisterForEvent("PillagerProfitUltimate", EVENT_ACTION_SLOT_ABILITY_USED, OnUltimateUsed)
        EVENT_MANAGER:RegisterForEvent("PillagerProfitTrackerEffect", EVENT_EFFECT_CHANGED, OnEffectChanged)
        EVENT_MANAGER:AddFilterForEvent("PillagerProfitTrackerEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        EVENT_MANAGER:UnregisterForEvent("PillagerProfitTrackerLiteLoaded", EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent("PillagerProfitTrackerLiteLoaded", EVENT_ADD_ON_LOADED, PillagerProfitTracker.OnAddOnLoaded)