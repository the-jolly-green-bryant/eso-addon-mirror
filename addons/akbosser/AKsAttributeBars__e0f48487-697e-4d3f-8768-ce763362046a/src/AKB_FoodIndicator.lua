-- ============================================================================
-- AKsAttributeBars - Food Buff Indicator Module (Cleaned Up Version)
-- ============================================================================
-- Shows a crafting bread icon when player has no food or drink buff active

-- luacheck: globals GetNumBuffs GetUnitBuffInfo GetGameTimeMilliseconds EVENT_MANAGER EVENT_EFFECT_CHANGED SLASH_COMMANDS WINDOW_MANAGER zo_callLater LibSlashCommander RIGHT LEFT CT_TEXTURE

local AKB = AKsAttributeBars

-- Local aliases (improve static analysis; real values supplied by ESO at runtime)
local _G = _G

-- Globals (ESO API): GetNumBuffs, GetUnitBuffInfo, GetGameTimeMilliseconds, EVENT_MANAGER, EVENT_EFFECT_CHANGED,
-- SLASH_COMMANDS, WINDOW_MANAGER, zo_callLater, LibSlashCommander, RIGHT, LEFT, CT_TEXTURE

-- Create FoodIndicator namespace
AKB.FoodIndicator = AKB.FoodIndicator or {}

-- Runtime Variables
local foodIndicatorWindow = nil
local foodIndicatorIcon = nil
local creationAttempts = 0
local MAX_CREATION_ATTEMPTS = 15  -- ~3s if interval 200ms
local EXTRA_FOOD_DRINK_IDS = {}
AKB.FoodIndicator._lastDetection = AKB.FoodIndicator._lastDetection or { hasFood=false, reason="INIT", matchedId=nil, matchedName=nil }
local FOOD_KEYWORDS = {"food","meal","feast","stew","soup","bread","cheese","pie","cake","fish","meat"}
local DRINK_KEYWORDS = {"drink","brew","wine","ale","mead","beer","tea","tonic"}

-- Known food and drink buff ability IDs (from LibFoodDrinkBuff)
-- This provides the most reliable detection method
local FOOD_DRINK_ABILITY_IDS = {
    -- Food buffs
    [17407] = "food", [17577] = "food", [17581] = "food", [17608] = "food", [17614] = "food",
    [61218] = "food", [61255] = "food", [61257] = "food", [61259] = "food", [61260] = "food",
    [61261] = "food", [61294] = "food", [66128] = "food", [66130] = "food", [66551] = "food",
    [66568] = "food", [66576] = "food", [68411] = "food", [72819] = "food", [72822] = "food",
    [72824] = "food", [72956] = "food", [72959] = "food", [72961] = "food", [84678] = "food",
    [84681] = "food", [84709] = "food", [84725] = "food", [84736] = "food", [85484] = "food",
    [86749] = "food", [86787] = "food", [86789] = "food", [89955] = "food", [89971] = "food",
    [92435] = "food", [92437] = "food", [92474] = "food", [92477] = "food", [100498] = "food",
    [100502] = "food", [107748] = "food", [107789] = "food", [127537] = "food", [127578] = "food",
    [127596] = "food", [127619] = "food", [127736] = "food",
    
    -- Drink buffs
    [61322] = "drink", [61325] = "drink", [61328] = "drink", [61335] = "drink", [61340] = "drink",
    [61345] = "drink", [61350] = "drink", [66125] = "drink", [66132] = "drink", [66137] = "drink",
    [66141] = "drink", [66586] = "drink", [66590] = "drink", [66594] = "drink", [68416] = "drink",
    [72816] = "drink", [72965] = "drink", [72968] = "drink", [72971] = "drink", [84700] = "drink",
    [84704] = "drink", [84720] = "drink", [84731] = "drink", [84732] = "drink", [84733] = "drink",
    [84735] = "drink", [85497] = "drink", [86559] = "drink", [86560] = "drink", [86673] = "drink",
    [86674] = "drink", [86677] = "drink", [86678] = "drink", [86746] = "drink", [86747] = "drink",
    [86791] = "drink", [89957] = "drink", [92433] = "drink", [92476] = "drink", [100488] = "drink",
    [127531] = "drink", [127572] = "drink", [148633] = "drink"
}

-- Check if player has any active food or drink buffs (records detection details)
local function HasFoodOrDrinkBuff()
    if not _G["GetNumBuffs"] or not _G["GetUnitBuffInfo"] then
        return false
    end
    
    local numBuffs = _G["GetNumBuffs"]("player")
    if not numBuffs or numBuffs == 0 then
        return false
    end
    
    local currentTime = _G["GetGameTimeMilliseconds"] and _G["GetGameTimeMilliseconds"]() or 0
    local last = { hasFood=false, reason="NONE", matchedId=nil, matchedName=nil }
    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId = _G["GetUnitBuffInfo"]("player", i)
        if buffName and abilityId then
            -- Primary: direct ID match (ignore timeEnding validity for known IDs)
            if FOOD_DRINK_ABILITY_IDS[abilityId] then
                last = { hasFood=true, reason="KNOWN_ID", matchedId=abilityId, matchedName=buffName }
                AKB.FoodIndicator._lastDetection = last
                return true
            elseif EXTRA_FOOD_DRINK_IDS[abilityId] then
                last = { hasFood=true, reason="EXTRA_ID", matchedId=abilityId, matchedName=buffName }
                AKB.FoodIndicator._lastDetection = last
                return true
            end

            -- Only proceed to fallback keyword logic if we have a meaningful long duration remaining
            local remainingOK = false
            if timeEnding and timeEnding > currentTime then
                local remaining = timeEnding - currentTime
                if remaining > 900000 then -- >15 minutes
                    remainingOK = true
                end
            end
            if remainingOK then
                local lowerName = string.lower(buffName)
                for _, kw in ipairs(FOOD_KEYWORDS) do
                    if string.find(lowerName, kw) then
                        last = { hasFood=true, reason="FALLBACK_FOOD_"..kw, matchedId=abilityId, matchedName=buffName }
                        AKB.FoodIndicator._lastDetection = last
                        return true
                    end
                end
                for _, kw in ipairs(DRINK_KEYWORDS) do
                    if string.find(lowerName, kw) then
                        last = { hasFood=true, reason="FALLBACK_DRINK_"..kw, matchedId=abilityId, matchedName=buffName }
                        AKB.FoodIndicator._lastDetection = last
                        return true
                    end
                end
            end
        end
    end
    AKB.FoodIndicator._lastDetection = last
    return false
end

-- Update the visibility of the food indicator
local function UpdateFoodIndicatorVisibility()
    if not foodIndicatorWindow then
        return
    end
    
    local hasFood = HasFoodOrDrinkBuff()
    local shouldShowIndicator = not hasFood  -- Show icon when NO food/drink buff
    
    -- Check if UI should be hidden (respect menu visibility settings)
    local uiShouldBeHidden = false
    if AKB.Events and AKB.Events.IsAnyMenuOpen then
        local success, menuOpen = pcall(AKB.Events.IsAnyMenuOpen)
        if success then
            uiShouldBeHidden = menuOpen
        end
    end
    
    -- Also check if bars should be hidden due to "hide when full and out of combat" setting
    local barsShouldBeHidden = false
    if AKB.Settings and AKB.Settings.Get and AKB.UI and AKB.UI.Manager and AKB.UI.Manager.AreAllAttributesFull then
        local settings = AKB.Settings.Get()
        if settings and settings.hideWhenFullAndOutOfCombat then
            local allFull = AKB.UI.Manager.AreAllAttributesFull()
            local inCombat = IsUnitInCombat and IsUnitInCombat("player")
            barsShouldBeHidden = allFull and not inCombat
        end
    end
    
    -- Final decision: show if (no food buff) AND (UI should be visible) AND (bars should be visible)
    local shouldShow = shouldShowIndicator and not uiShouldBeHidden and not barsShouldBeHidden
    
    -- Update visibility directly (only if state actually changes to avoid redundant calls)
    if foodIndicatorWindow:IsHidden() == shouldShow then
        foodIndicatorWindow:SetHidden(not shouldShow)
    end

end

-- Event handler for buff changes
local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag)
    if unitTag == "player" then
        -- Update immediately with small delay for buff system stability
        zo_callLater(UpdateFoodIndicatorVisibility, 50)
    end
end

-- Create the food indicator UI element
function AKB.FoodIndicator.CreateFoodIndicator(force)
    if AKB and AKB.Settings and AKB.Settings.Get and not AKB.Settings.Get("showFoodDrinkReminder") then
        -- Respect user setting; ensure destroyed if disabled
        AKB.FoodIndicator.DestroyFoodIndicator()
        return nil
    end
    -- Prevent infinite recursion
    creationAttempts = creationAttempts + 1

    -- If already exists and not forcing, just update
    if foodIndicatorWindow and not force then
        UpdateFoodIndicatorVisibility()
        return foodIndicatorWindow
    end

    -- Need bars health window
    local bars = AKB.UI and AKB.UI.Manager and AKB.UI.Manager.GetPlayerBars and AKB.UI.Manager.GetPlayerBars() or nil
    local healthBarWindow = bars and bars.health and bars.health.window or nil
    if not healthBarWindow then
        if creationAttempts <= MAX_CREATION_ATTEMPTS then
            if zo_callLater then
                zo_callLater(function() AKB.FoodIndicator.CreateFoodIndicator(force) end, 200)
            end
        else
            -- Give up silently after max attempts
        end
        return nil
    end

    -- Clean up any existing indicator (if forcing)
    AKB.FoodIndicator.DestroyFoodIndicator()

    local iconSize = 32
    local iconOffset = 10
    local uniqueName = AKB.Utils.GenerateUniqueName("FoodIndicator")
    local wm = _G["WINDOW_MANAGER"]
    if not wm or not wm.CreateTopLevelWindow then return nil end
    foodIndicatorWindow = wm:CreateTopLevelWindow(uniqueName)
    if not foodIndicatorWindow then return nil end

    -- Basic window config
    pcall(function()
    local RIGHT_CONST = _G["RIGHT"]
    local LEFT_CONST = _G["LEFT"]
    foodIndicatorWindow:SetDimensions(iconSize, iconSize)
    foodIndicatorWindow:SetAnchor(RIGHT_CONST, healthBarWindow, LEFT_CONST, -iconOffset, 0)
        foodIndicatorWindow:SetClampedToScreen(true)
        foodIndicatorWindow:SetMouseEnabled(false)
        foodIndicatorWindow:SetMovable(false)
        foodIndicatorWindow:SetHidden(true)
    end)

    -- Create icon
    if wm and wm.CreateControl then
        local CT_TEXTURE_CONST = _G["CT_TEXTURE"]
        foodIndicatorIcon = wm:CreateControl(nil, foodIndicatorWindow, CT_TEXTURE_CONST)
    end
    if not foodIndicatorIcon then
        AKB.FoodIndicator.DestroyFoodIndicator()
        return nil
    end
    pcall(function()
        foodIndicatorIcon:SetAnchorFill(foodIndicatorWindow)
        foodIndicatorIcon:SetTexture("EsoUI/Art/Icons/crafting_bread_001.dds")
        foodIndicatorIcon:SetColor(1, 1, 1, 1)
    end)

    -- Register events once
    if _G["EVENT_MANAGER"] then
        _G["EVENT_MANAGER"]:UnregisterForEvent(AKB.name .. "_FoodIndicator", _G["EVENT_EFFECT_CHANGED"]) -- avoid duplicate
        _G["EVENT_MANAGER"]:RegisterForEvent(AKB.name .. "_FoodIndicator", _G["EVENT_EFFECT_CHANGED"], OnEffectChanged)
        _G["EVENT_MANAGER"]:UnregisterForUpdate(AKB.name .. "_FoodPeriodicCheck")
        _G["EVENT_MANAGER"]:RegisterForUpdate(AKB.name .. "_FoodPeriodicCheck", 4000, UpdateFoodIndicatorVisibility)
    end

    -- Initial update
    UpdateFoodIndicatorVisibility()
    return foodIndicatorWindow
end

-- Destroy the food indicator
function AKB.FoodIndicator.DestroyFoodIndicator()
    creationAttempts = 0
    -- Unregister events
    if _G["EVENT_MANAGER"] then
        _G["EVENT_MANAGER"]:UnregisterForEvent(AKB.name .. "_FoodIndicator", _G["EVENT_EFFECT_CHANGED"])
        _G["EVENT_MANAGER"]:UnregisterForUpdate(AKB.name .. "_FoodPeriodicCheck")
    end
    
    -- Clean up UI elements
    if foodIndicatorIcon then
        foodIndicatorIcon:SetHidden(true)
        foodIndicatorIcon = nil
    end
    
    if foodIndicatorWindow then
        foodIndicatorWindow:SetHidden(true)
        foodIndicatorWindow = nil
    end
end

-- Public API functions
function AKB.FoodIndicator.UpdateVisibility()
    UpdateFoodIndicatorVisibility()
end

function AKB.FoodIndicator.HasFoodBuff()
    return HasFoodOrDrinkBuff()
end

-- Initialize the food indicator module
function AKB.FoodIndicator.Initialize()
    -- Auto-attempt creation shortly after init (in case bars already exist)
    if _G["zo_callLater"] then
        _G["zo_callLater"](function() AKB.FoodIndicator.CreateFoodIndicator(false) end, 500)
    else
        AKB.FoodIndicator.CreateFoodIndicator(false)
    end
end
