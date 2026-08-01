EldenRingUI = EldenRingUI or {}
EldenRingUI.SimpleFoodTracker = EldenRingUI.SimpleFoodTracker or {}
local SimpleFoodTracker = EldenRingUI.SimpleFoodTracker
SimpleFoodTracker.name = "ERUI_SimpleFoodTracker"

local trackedFoods = {
    [127596] = true, -- Bewitched Sugar Skulls
    [61261] = true,  -- Max Stamina
    [86673] = true,  -- Max Stamina and Stam Regen
    [61255] = true,  -- Max Stamina and Max Health
    [61260] = true,  -- Max Magicka
    [84720] = true,  -- Max Magicka and Max Regen
    [61257] = true,  -- Max Magicka and Max Health
    [89955] = true,  -- Candied Jester's Coins
    [84709] = true,  -- Crunchy Spider Skewer
    [89971] = true,  -- Jewels of Misrule
    [72824] = true,  -- Smoked Bear Haunch
}

function SimpleFoodTracker.UpdateFood()
    local currentFood = "No Food Active"
    local numBuffs = GetNumBuffs("player")
    
    for i = 1, numBuffs do
        local buffName, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        
        if trackedFoods[abilityId] then
            currentFood = buffName:gsub("^%l", string.upper)
            break
        end
    end
    
    SimpleFoodTrackerWindowLabel:SetText(currentFood)
    SimpleFoodTrackerWindowLabel:SetAlpha(0.85)
end

function SimpleFoodTracker.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)

    if unitTag ~= "player" then return end
    
    if trackedFoods[abilityId] then
        if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
            local currentFood = effectName:gsub("^%l", string.upper)
            SimpleFoodTrackerWindowLabel:SetText(currentFood)
            SimpleFoodTrackerWindowLabel:SetAlpha(0.85)
            
        elseif changeType == EFFECT_RESULT_FADED then
            SimpleFoodTracker.UpdateFood()
        end
    end
end

function SimpleFoodTracker.OnAddOnLoaded(eventCode, addonName)
    if addonName == "EldenRingUI" then
        EVENT_MANAGER:UnregisterForEvent(SimpleFoodTracker.name, EVENT_ADD_ON_LOADED)

        local fragment = ZO_HUDFadeSceneFragment:New(SimpleFoodTrackerWindow)
        HUD_SCENE:AddFragment(fragment)
        HUD_UI_SCENE:AddFragment(fragment)

        SimpleFoodTracker.UpdateFood()
        
        EVENT_MANAGER:RegisterForEvent(SimpleFoodTracker.name, EVENT_EFFECT_CHANGED, SimpleFoodTracker.OnEffectChanged)
        EVENT_MANAGER:AddFilterForEvent(SimpleFoodTracker.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    end
end

EVENT_MANAGER:RegisterForEvent(SimpleFoodTracker.name, EVENT_ADD_ON_LOADED, SimpleFoodTracker.OnAddOnLoaded)