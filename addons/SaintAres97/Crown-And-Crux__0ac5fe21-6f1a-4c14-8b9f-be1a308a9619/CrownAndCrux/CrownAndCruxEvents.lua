CrownAndCruxEvents = {}

local M = CrownAndCruxEvents
local EM = EVENT_MANAGER

local CRUX_BUFF_ABILITY_ID = 184220


local function Fade(control, show)
    if not control then return end
    control:SetHidden(false)
    control:SetAlpha(show and 1 or 0)   -- instant on/off
end


-- ---------------------------------------------------------------------------
-- Update the UI label
-- ---------------------------------------------------------------------------
local function UpdateCruxDisplay()
    local count = CrownAndCrux.State:GetStacks()

    local prev = CrownAndCrux.State.prevStacks
    if count == CrownAndCrux.State.maxStacks and prev < count then
        PlaySound(SOUNDS.DEATH_RECAP_KILLING_BLOW_SHOWN)
    end

    --------------------------------------------------------------------------
    -- show the frame only when count > 0
    --------------------------------------------------------------------------
    local always = CrownAndCrux.saved.alwaysShow
    local shouldShow = always or (count > 0)

    if CrownAndCruxUI then
        CrownAndCruxUI:SetHidden(not shouldShow)
    end

    -- If hidden, no need to update icons/label
    if not shouldShow then
        if CrownAndCruxUIIcon1 then CrownAndCruxUIIcon1:SetHidden(true) end
        if CrownAndCruxUIIcon2 then CrownAndCruxUIIcon2:SetHidden(true) end
        if CrownAndCruxUIIcon3 then CrownAndCruxUIIcon3:SetHidden(true) end
        return
    end

    -- ── Update label text ──────────────────────────────────────────────────
    if CrownAndCruxUICruxLabel then
        CrownAndCruxUICruxLabel:SetText(tostring(count))
    end

    -- ── Show required icons ───────────────────────────────────────────────
    if CrownAndCruxUIIcon1 then CrownAndCruxUIIcon1:SetHidden(count < 1) end
    if CrownAndCruxUIIcon2 then CrownAndCruxUIIcon2:SetHidden(count < 2) end
    if CrownAndCruxUIIcon3 then CrownAndCruxUIIcon3:SetHidden(count < 3) end

    -- ── Glow fade logic ───────────────────────────────────────────────────
    local atMax = (count == CrownAndCrux.State.maxStacks)

    -- Icon1 layers
    Fade(CrownAndCruxUIIcon1Glow,      atMax)

    -- Icon2 layers
    Fade(CrownAndCruxUIIcon2Glow,      atMax)

    -- Icon3 layers
    Fade(CrownAndCruxUIIcon3Glow,      atMax)
end



-- ---------------------------------------------------------------------------
-- Forcefully update Crux stacks by scanning all player buffs
-- ---------------------------------------------------------------------------
local function RefreshCrux()
    local found = false
    for i = 1, GetNumBuffs("player") do
        local _, _, _, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if abilityId == CRUX_BUFF_ABILITY_ID then
            CrownAndCrux.State:SetStacks(stackCount)
            found = true
            break
        end
    end

    if not found then
        CrownAndCrux.State:ClearStacks()
    end

    UpdateCruxDisplay()
end

-- ---------------------------------------------------------------------------
-- When Crux buff changes (gain/loss in real time)
-- ---------------------------------------------------------------------------
local function OnCruxEffectChanged(_, changeType, _, _, _, _, _, stackCount)
    if changeType == EFFECT_RESULT_FADED then
        CrownAndCrux.State:SetStacks(0)
    else
        CrownAndCrux.State:SetStacks(stackCount)
    end
    UpdateCruxDisplay()
end

-- ---------------------------------------------------------------------------
-- General player state change (zone, login, death, revive)
-- ---------------------------------------------------------------------------
local function OnPlayerStateChanged()
    RefreshCrux()
end

---------------------------------------------------------------------------
--  Public helper: refresh visibility (called by settings panel)
---------------------------------------------------------------------------
function CrownAndCruxEvents.Refresh()
    RefreshCrux()          -- local function defined earlier in this file
end


-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function M:Initialize()
    EM:RegisterForEvent("CrownAndCrux_Activated", EVENT_PLAYER_ACTIVATED, OnPlayerStateChanged)
    EM:RegisterForEvent("CrownAndCrux_ZoneUpdate", EVENT_ZONE_UPDATE, OnPlayerStateChanged)
    EM:RegisterForEvent("CrownAndCrux_PlayerDead", EVENT_PLAYER_DEAD, OnPlayerStateChanged)
    EM:RegisterForEvent("CrownAndCrux_PlayerAlive", EVENT_PLAYER_ALIVE, OnPlayerStateChanged)

    EM:RegisterForEvent("CrownAndCrux_Effect", EVENT_EFFECT_CHANGED, OnCruxEffectChanged)
    EM:AddFilterForEvent("CrownAndCrux_Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, CRUX_BUFF_ABILITY_ID)
    EM:AddFilterForEvent("CrownAndCrux_Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
end
