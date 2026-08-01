KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.AntiSpud = KyzderpsDerps.AntiSpud or {}
local Spud = KyzderpsDerps.AntiSpud

---------------------------------------------------------------------
-- Is this a food buff?
-- RaidNotifier uses heuristics (many API calls) and a blacklist
-- JoGroup uses a set list. I will copy this because more efficient
---------------------------------------------------------------------
local FOOD_BUFFS = {
    [61259] = true,
    [61260] = true,
    [61261] = true,
    [61322] = true,
    [61325] = true,
    [61328] = true,
    [61257] = true,
    [61255] = true,
    [61294] = true,
    [72816] = true,
    [61340] = true,
    [61345] = true,
    [61218] = true,
    [61350] = true,
    [72822] = true,
    [72816] = true,
    [72819] = true,
    [72824] = true,
    -- crown store
    [68411] = true,
    [68416] = true,
    -- 2h Witches event
    [84681] = true,
    [84709] = true,
    [84725] = true,
    [84678] = true,
    [84704] = true,
    [84720] = true,
    [84700] = true,
    [84731] = true,
    [84735] = true,
    -- new years event
    [86791] = true,
    [86787] = true,
    [86673] = true,
    [86749] = true,
    [86677] = true,
    [86789] = true,
    [84678] = true,
    [86559] = true,
    [86746] = true,
    -- jesters festival
    [84678] = true,
    [89957] = true,
    [89955] = true,
    [89971] = true,
    -- pvp foods
    [72956] = true,
    [72959] = true,
    [72961] = true,
    [72965] = true,
    [72968] = true,
    [72971] = true,
    -- clockwork
    [100498] = true,
    [100488] = true,
    [100502] = true,
    -- summerset    
    [107789] = true,
    [107748] = true,
    -- garbage crown crate foods
    [92474] = true,
    [92435] = true,
    [92476] = true,
    [92433] = true,
    -- more witches festival
    [127531] = true,
    [127572] = true,
    [127596] = true,
}

local function IsFoodBuff(abilityId)
    return FOOD_BUFFS[abilityId]
end

---------------------------------------------------------------------
-- Whether the user is in a PvE, PvP, or boss area
---------------------------------------------------------------------
local function IsInNeedFoodArea()
    local currentState = Spud.GetCurrentState()
    if (Spud.IsCurrentStateAnyPVE() and KyzderpsDerps.savedOptions.antispud.food.pve) then
        return true
    end

    if (Spud.IsCurrentStateAnyPVP() and KyzderpsDerps.savedOptions.antispud.food.pvp) then
        return true
    end

    -- Overland bosses etc.
    if (DoesUnitExist("boss1") and KyzderpsDerps.savedOptions.antispud.food.boss) then
        return true
    end

    return false
end

---------------------------------------------------------------------
-- Text-only update for warning countdown
---------------------------------------------------------------------
local function UpdateWarningCountdown(timeEnding)
    local remaining = timeEnding - GetGameTimeSeconds()

    if (remaining < 0) then
        -- Theoretically this shouldn't happen because the food ending event will have fired
        EVENT_MANAGER:UnregisterForUpdate(KyzderpsDerps.name .. "AntiSpudFoodUpdateCountdown")
        Spud.Display(nil, Spud.FOOD)
        return
    end

    Spud.Display("You could eat another bite in " .. ZO_FormatCountdownTimer(remaining), Spud.FOOD)
end


---------------------------------------------------------------------
-- Check all of the user's buffs for food
---------------------------------------------------------------------
local function CheckAllFood(reason)
    if (reason) then
        KyzderpsDerps:dbg("checking food: " .. reason)
    end

    for i = 1, GetNumBuffs("player") do
        local _, _, timeEnding, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        -- Has food...
        if (IsFoodBuff(abilityId)) then
            local remaining = timeEnding - GetGameTimeSeconds()

            -- ... and above threshold for warning = no display
            if (remaining / 60 > KyzderpsDerps.savedOptions.antispud.food.prewarn) then
                EVENT_MANAGER:UnregisterForUpdate(KyzderpsDerps.name .. "AntiSpudFoodUpdateCountdown")
                Spud.Display(nil, Spud.FOOD)
                return
            end

            if (IsInNeedFoodArea() and (not IsUnitInCombat("player") or KyzderpsDerps.savedOptions.antispud.food.prewarnInCombat)) then
                -- Otherwise, warn and continually update the text (don't want to call
                -- the entire function repeatedly to check buffs)
                Spud.Display("You could eat another bite in " .. ZO_FormatCountdownTimer(remaining), Spud.FOOD)
                EVENT_MANAGER:UnregisterForUpdate(KyzderpsDerps.name .. "AntiSpudFoodUpdateCountdown")
                EVENT_MANAGER:RegisterForUpdate(KyzderpsDerps.name .. "AntiSpudFoodUpdateCountdown", 1000, function()
                    UpdateWarningCountdown(timeEnding)
                end)
                return
            end

            EVENT_MANAGER:UnregisterForUpdate(KyzderpsDerps.name .. "AntiSpudFoodUpdateCountdown")
            Spud.Display(nil, Spud.FOOD)
            return
        end
    end

    if (IsInNeedFoodArea()) then
        EVENT_MANAGER:UnregisterForUpdate(KyzderpsDerps.name .. "AntiSpudFoodUpdateCountdown")
        Spud.Display("You are positively famished", Spud.FOOD)
        return
    end

    EVENT_MANAGER:UnregisterForUpdate(KyzderpsDerps.name .. "AntiSpudFoodUpdateCountdown")
    Spud.Display(nil, Spud.FOOD)
end


---------------------------------------------------------------------
-- State, effect, or bosses change
-- When any change, we should check if user has a food buff
---------------------------------------------------------------------
local function OnSpudStateChanged(oldState, newState)
    CheckAllFood("spud state changed")
end

local RESULT_TO_STRING = {
    [EFFECT_RESULT_FADED] = "FADED",
    [EFFECT_RESULT_FULL_REFRESH] = "FULL_REFRESH",
    [EFFECT_RESULT_GAINED] = "GAINED",
    [EFFECT_RESULT_TRANSFER] = "TRANSFER",
    [EFFECT_RESULT_UPDATED] = "UPDATED",
}

local function OnEffectChanged(_, changeType, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    if (changeType ~= EFFECT_RESULT_GAINED and changeType ~= EFFECT_RESULT_FADED) then return end
    if (not IsFoodBuff(abilityId)) then return end
    KyzderpsDerps:dbg(string.format("%s %s (%d)", RESULT_TO_STRING[changeType], GetAbilityName(abilityId), abilityId))
    CheckAllFood("food effect changed")
end

local function GetUnitNameIfExists(unitTag)
    if (DoesUnitExist(unitTag)) then
        return GetUnitName(unitTag)
    end
end

local prevBosses = ""
local function OnBossesChanged()
    local bossHash = ""

    for i = 1, BOSS_RANK_ITERATION_END do
        local name = GetUnitNameIfExists("boss" .. tostring(i))
        if (name and name ~= "") then
            bossHash = bossHash .. name
        end
    end

    -- Only trigger off bosses truly changing (sometimes the event fires for no apparent reason?)
    if (bossHash ~= prevBosses) then
        prevBosses = bossHash
        CheckAllFood("bosses changed")
    end
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Spud.InitializeFood()
    KyzderpsDerps:dbg("    Initializing AntiSpud Food...")

    Spud.Display(nil, Spud.FOOD)

    Spud.RegisterStateListener("Food", OnSpudStateChanged)

    local checkFood = KyzderpsDerps.savedOptions.antispud.food.pve or KyzderpsDerps.savedOptions.antispud.food.pvp or KyzderpsDerps.savedOptions.antispud.food.boss

    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "AntiSpudFoodEffect", EVENT_EFFECT_CHANGED)
    if (checkFood) then
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "AntiSpudFoodEffect", EVENT_EFFECT_CHANGED, OnEffectChanged)
        EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "AntiSpudFoodEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")

        CheckAllFood("initial")
    end

    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "AntiSpudFoodBossChanged", EVENT_BOSSES_CHANGED)
    if (checkFood and KyzderpsDerps.savedOptions.antispud.food.boss) then
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "AntiSpudFoodBossChanged", EVENT_BOSSES_CHANGED, OnBossesChanged)
    end

    -- Check every 20 seconds
    EVENT_MANAGER:UnregisterForUpdate(KyzderpsDerps.name .. "AntiSpudFoodUpdate")
    if (checkFood and KyzderpsDerps.savedOptions.antispud.food.prewarn > 0) then
        EVENT_MANAGER:RegisterForUpdate(KyzderpsDerps.name .. "AntiSpudFoodUpdate", 20000, function() CheckAllFood() end)
    end

    -- Listen for combat state to avoid showing warning in combat
    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "AntiSpudFoodCombat", EVENT_PLAYER_COMBAT_STATE)
    if (checkFood and KyzderpsDerps.savedOptions.antispud.food.prewarn > 0 and not KyzderpsDerps.savedOptions.antispud.food.prewarnInCombat) then
        -- Combat state timeout, because sometimes it gets spammed
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "AntiSpudFoodCombat", EVENT_PLAYER_COMBAT_STATE, function()
            EVENT_MANAGER:RegisterForUpdate(KyzderpsDerps.name .. "AntiSpudFoodCombatTimeout", 1000, function()
                EVENT_MANAGER:UnregisterForUpdate(KyzderpsDerps.name .. "AntiSpudFoodCombatTimeout")
                CheckAllFood("combat timeout")
            end)
        end)
    end
end
