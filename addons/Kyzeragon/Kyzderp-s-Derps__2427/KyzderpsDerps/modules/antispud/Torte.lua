KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.AntiSpud = KyzderpsDerps.AntiSpud or {}
local Spud = KyzderpsDerps.AntiSpud

---------------------------------------------------------------------
-- Is this a torte buff?
---------------------------------------------------------------------
local TORTE_BUFFS = {
    [147687] = true, -- Colovian War Torte
    [147733] = true, -- Molten War Torte
    [147734] = true, -- White-Gold War Torte
    [137733] = true, -- Alliance War Skill Line Scroll, Major
    [147466] = true, -- Alliance Skill Gain -- TODO: verify, from uesp
    [147467] = true, -- Alliance Skill Gain, Grand -- TODO: verify, from uesp
    [147797] = true, -- Alliance Skill Gain 150% Boost -- TODO: verify, from uesp
}

local function IsTorteBuff(abilityId)
    return TORTE_BUFFS[abilityId]
end

---------------------------------------------------------------------
-- Whether the user is in a PvE, PvP, or boss area
---------------------------------------------------------------------
local function IsInNeedTorteArea()
    return Spud.GetCurrentState() == Spud.PVP and KyzderpsDerps.savedOptions.antispud.torte
end

---------------------------------------------------------------------
-- Check all of the user's buffs for torte
---------------------------------------------------------------------
local function CheckAllTorte()
    for i = 1, GetNumBuffs("player") do
        local _, _, timeEnding, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if (IsTorteBuff(abilityId)) then
            Spud.Display(nil, Spud.TORTE)
            return
        end
    end

    if (IsInNeedTorteArea()) then
        Spud.Display("You don't have torte buff on", Spud.TORTE)
        return
    end

    Spud.Display(nil, Spud.TORTE)
end

---------------------------------------------------------------------
-- State or effect change
-- When any change, we should check if user has a torte buff
---------------------------------------------------------------------
local function OnSpudStateChanged(oldState, newState)
    CheckAllTorte()
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
    if (not IsTorteBuff(abilityId)) then return end
    KyzderpsDerps:dbg(string.format("%s %s (%d)", RESULT_TO_STRING[changeType], GetAbilityName(abilityId), abilityId))
    CheckAllTorte()
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Spud.InitializeTorte()
    KyzderpsDerps:dbg("    Initializing AntiSpud Torte...")

    Spud.Display(nil, Spud.TORTE)

    Spud.RegisterStateListener("Torte", OnSpudStateChanged)

    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "AntiSpudTorteEffect", EVENT_EFFECT_CHANGED)
    if (KyzderpsDerps.savedOptions.antispud.torte) then
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "AntiSpudTorteEffect", EVENT_EFFECT_CHANGED, OnEffectChanged)
        EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "AntiSpudTorteEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")

        CheckAllTorte()
    end
end
