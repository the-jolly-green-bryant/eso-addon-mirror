local eventManager = GetEventManager()
local centerScreenAnnounce = CENTER_SCREEN_ANNOUNCE
local pairs = pairs
local tostring = tostring
local select = select
local GetFrameTimeSeconds = GetFrameTimeSeconds
local GetNumBuffs = GetNumBuffs
local GetUnitBuffInfo = GetUnitBuffInfo

local ADDON_EVENT_NAMESPACE = "MissingFoodDrinkCSA"

local CSA_LIFESPAN_MS = 3500
local WARNING_REMAINING_S = 60
local WARNING_POLL_INTERVAL_MS = 30000

-- Drink Buff Ability IDs
local IsDrinkBuff =
{
    [61322]  = true, -- Health Recovery
    [61325]  = true, -- Magicka Recovery
    [61328]  = true, -- Health & Magicka Recovery
    [61335]  = true, -- Health & Magicka Recovery
    [61340]  = true, -- Health & Stamina Recovery
    [61345]  = true, -- Magicka & Stamina Recovery
    [61350]  = true, -- All Primary Stat Recovery
    [66125]  = true, -- Increase Max Health
    [66132]  = true, -- Health Recovery (Alcoholic Drinks)
    [66137]  = true, -- Magicka Recovery (Tea)
    [66141]  = true, -- Stamina Recovery (Tonics)
    [66586]  = true, -- Health Recovery
    [66590]  = true, -- Magicka Recovery
    [66594]  = true, -- Stamina Recovery
    [68416]  = true, -- All Primary Stat Recovery (Crown Refreshing Drink)
    [72816]  = true, -- Red Frothgar
    [72965]  = true, -- Health and Stamina Recovery (Cyrodilic Field Brew)
    [72968]  = true, -- Health and Magicka Recovery (Cyrodilic Field Tea)
    [72971]  = true, -- Magicka and Stamina Recovery (Cyrodilic Field Tonic)
    [84700]  = true, -- 2h Witches event: Eyeballs
    [84704]  = true, -- 2h Witches event: Witchmother's Party Punch
    [84720]  = true, -- 2h Witches event: Eye Scream
    [84731]  = true, -- 2h Witches event: Witchmother's Potent Brew
    [84732]  = true, -- Increase Health Regen
    [84733]  = true, -- Increase Health Regen
    [84735]  = true, -- 2h Witches event: Double Bloody Mara
    [85497]  = true, -- All Primary Stat Recovery
    [86559]  = true, -- Hissmir Fish Eye Rye
    [86560]  = true, -- Stamina Recovery
    [86673]  = true, -- Lava Foot Soup & Saltrice
    [86674]  = true, -- Stamina Recovery
    [86677]  = true, -- Warning Fire (Bergama Warning Fire)
    [86678]  = true, -- Health Recovery
    [86746]  = true, -- Betnikh Spiked Ale (Betnikh Twice-Spiked Ale)
    [86747]  = true, -- Health Recovery
    [86791]  = true, -- Increase Stamina Recovery (Ice Bear Glow-Wine)
    [89957]  = true, -- Dubious Camoran Throne
    [92433]  = true, -- Health & Magicka Recovery
    [92476]  = true, -- Health & Stamina Recovery
    [100488] = true, -- Spring-Loaded Infusion
    [127531] = true, -- Disastrously Bloody Mara
    [127572] = true, -- Pack Leader's Bone Broth
    [148633] = true, -- Sparkling Mudcrab Apple Cider
}

-- Food Buff Ability IDs
local IsFoodBuff =
{
    [17407]  = true, -- Increase Max Health
    [17577]  = true, -- Increase Max Magicka & Stamina
    [17581]  = true, -- Increase All Primary Stats
    [17608]  = true, -- Magicka & Stamina Recovery
    [17614]  = true, -- All Primary Stat Recovery
    [61218]  = true, -- Increase All Primary Stats
    [61255]  = true, -- Increase Max Health & Stamina
    [61257]  = true, -- Increase Max Health & Magicka
    [61259]  = true, -- Increase Max Health
    [61260]  = true, -- Increase Max Magicka
    [61261]  = true, -- Increase Max Stamina
    [61294]  = true, -- Increase Max Magicka & Stamina
    [66128]  = true, -- Increase Max Magicka
    [66130]  = true, -- Increase Max Stamina
    [66551]  = true, -- Garlic and Pepper Venison Steak
    [66568]  = true, -- Increase Max Magicka
    [66576]  = true, -- Increase Max Stamina
    [68411]  = true, -- Crown store
    [72819]  = true, -- Tripe Trifle Pocket
    [72822]  = true, -- Blood Price Pie
    [72824]  = true, -- Smoked Bear Haunch
    [72956]  = true, -- Max Health and Stamina (Cyrodilic Field Tack)
    [72959]  = true, -- Max Health and Magicka (Cyrodilic Field Treat)
    [72961]  = true, -- Max Stamina and Magicka (Cyrodilic Field Bar)
    [84678]  = true, -- Increase Max Magicka
    [84681]  = true, -- Pumpkin Snack Skewer
    [84709]  = true, -- Crunchy Spider Skewer
    [84725]  = true, -- The Brains!
    [84736]  = true, -- Increase Max Health
    [85484]  = true, -- Increase All Primary Stats
    [86749]  = true, -- Mud Ball
    [86787]  = true, -- Rajhin's Sugar Claws
    [86789]  = true, -- Alcaire Festival Sword-Pie
    [89955]  = true, -- Candied Jester's Coins
    [89971]  = true, -- Jewels of Misrule
    [92435]  = true, -- Increase Health & Magicka
    [92437]  = true, -- Increase Health (but descriptions says max magicka)
    [92474]  = true, -- Increase Health & Stamina
    [92477]  = true, -- Increase Health (but descriptions says max magicka)
    [100498] = true, -- Clockwork Citrus Filet
    [100502] = true, -- Deregulated Mushroom Stew
    [107748] = true, -- Lure Allure
    [107789] = true, -- Artaeum Takeaway Broth
    [127537] = true, -- Increase Health (but descriptions says max magicka)
    [127578] = true, -- Increase Health (but descriptions says max magicka)
    [127596] = true, -- Bewitched Sugar Skulls
    [127619] = true, -- Increase Health (but descriptions says max magicka)
    [127736] = true, -- Increase Health (but descriptions says max magicka)
}

local function IsFoodOrDrinkBuff(abilityId)
    return abilityId and (IsFoodBuff[abilityId] or IsDrinkBuff[abilityId])
end

local function HasFoodOrDrinkBuff()
    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local abilityId = select(11, GetUnitBuffInfo("player", i))
        if IsFoodOrDrinkBuff(abilityId) then
            return true
        end
    end
    return false
end

local function RegisterEffectChangedForAbilityId(abilityId, callback)
    local eventHandleName = ADDON_EVENT_NAMESPACE .. "_Effect_" .. tostring(abilityId)
    eventManager:RegisterForEvent(eventHandleName, EVENT_EFFECT_CHANGED, callback)
    eventManager:AddFilterForEvent(eventHandleName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId, REGISTER_FILTER_UNIT_TAG, "player")
    return eventHandleName
end

local function ShowMissingBuffCSA()
    local messageParams = centerScreenAnnounce:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, nil)
    messageParams:SetText("Missing Food/Drink Buff", nil)
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
    messageParams:SetLifespanMS(CSA_LIFESPAN_MS)
    centerScreenAnnounce:AddMessageWithParams(messageParams)
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, "Missing Food/Drink Buff")
end

local function ShowOneMinuteLeftCSA()
    local messageParams = centerScreenAnnounce:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.BATTLEGROUND_ONE_MINUTE_WARNING)
    messageParams:SetText("Food/Drink Buff: 1 Minute Left", nil)
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
    messageParams:SetLifespanMS(CSA_LIFESPAN_MS)
    centerScreenAnnounce:AddMessageWithParams(messageParams)
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, "Food/Drink Buff: 1 Minute Left")
end

-- Buff instances we have already shown the 1-minute warning for (key = abilityId .. "_" .. endTime).
local warnedOneMinuteLeft = {}

local function CheckFoodDrinkBuffWarning()
    local nowS = GetFrameTimeSeconds()
    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local _, startTime, endTime, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if IsFoodOrDrinkBuff(abilityId) then
            local duration = endTime - startTime
            if duration > 0 then
                local remainingS = endTime - nowS
                if remainingS > 0 and remainingS <= WARNING_REMAINING_S then
                    local key = tostring(abilityId) .. "_" .. tostring(endTime)
                    if not warnedOneMinuteLeft[key] then
                        warnedOneMinuteLeft[key] = true
                        ShowOneMinuteLeftCSA()
                    end
                end
            end
        end
    end
end

local function OnEffectChanged(_, changeType)
    if changeType ~= EFFECT_RESULT_FADED then
        return
    end
    ShowMissingBuffCSA()
end

local function OnPlayerActivated()
    if not HasFoodOrDrinkBuff() then
        ShowMissingBuffCSA()
    end
end

eventManager:RegisterForEvent(ADDON_EVENT_NAMESPACE, EVENT_ADD_ON_LOADED, function (eventId, addonName)
    -- Only initialize our own addon
    if addonName == ADDON_EVENT_NAMESPACE then
        -- -----------------------------------------------------------------------------
        for abilityId in pairs(IsFoodBuff) do
            RegisterEffectChangedForAbilityId(abilityId, OnEffectChanged)
        end
        for abilityId in pairs(IsDrinkBuff) do
            RegisterEffectChangedForAbilityId(abilityId, OnEffectChanged)
        end
        -- -----------------------------------------------------------------------------
        eventManager:RegisterForEvent(ADDON_EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
        -- -----------------------------------------------------------------------------
        eventManager:RegisterForUpdate(ADDON_EVENT_NAMESPACE .. "_WarningPoll", WARNING_POLL_INTERVAL_MS, CheckFoodDrinkBuffWarning)
        -- -----------------------------------------------------------------------------
        eventManager:UnregisterForEvent(addonName, eventId)
    end
end)
