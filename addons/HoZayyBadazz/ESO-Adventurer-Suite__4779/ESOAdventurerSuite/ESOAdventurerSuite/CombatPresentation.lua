-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.CombatPresentation = EPC.CombatPresentation or {}
local P = EPC.CombatPresentation

local function setSettingSafe(settingType, settingId, value)
    if type(SetSetting) ~= "function" or settingType == nil or settingId == nil then return false end
    local ok = pcall(SetSetting, settingType, settingId, tostring(value))
    return ok
end

function P:ApplyEnemyHealthBars()
    if not EPC.saved or EPC.saved.showEnemyOverheadHealthBars == false then return end
    if SETTING_TYPE_NAMEPLATES == nil then return end

    -- Master health-bar switch plus hostile NPC/player bars. The per-unit settings
    -- use ESO's Always choice so nearby enemies remain readable even when they are
    -- not the current reticle target.
    if NAMEPLATE_TYPE_ALL_HEALTHBARS ~= nil then
        setSettingSafe(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_HEALTHBARS, 1)
    end
    if NAMEPLATE_CHOICE_ALWAYS ~= nil then
        if NAMEPLATE_TYPE_ENEMY_NPC_HEALTHBARS ~= nil then
            setSettingSafe(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ENEMY_NPC_HEALTHBARS, NAMEPLATE_CHOICE_ALWAYS)
        end
        if NAMEPLATE_TYPE_ENEMY_PLAYER_HEALTHBARS ~= nil then
            setSettingSafe(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ENEMY_PLAYER_HEALTHBARS, NAMEPLATE_CHOICE_ALWAYS)
        end
    end
end

function P:ApplyOutgoingDamageNumbers()
    if not EPC.saved or EPC.saved.showOutgoingDamageNumbers == false then return end
    if SETTING_TYPE_COMBAT == nil then return end

    local enabled = 1
    if COMBAT_SETTING_SCROLLING_COMBAT_TEXT_ENABLED ~= nil then
        setSettingSafe(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCROLLING_COMBAT_TEXT_ENABLED, enabled)
    end
    if COMBAT_SETTING_SCT_OUTGOING_ENABLED ~= nil then
        setSettingSafe(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_ENABLED, enabled)
    end
    if COMBAT_SETTING_SCT_OUTGOING_DAMAGE_ENABLED ~= nil then
        setSettingSafe(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_DAMAGE_ENABLED, enabled)
    end
    if COMBAT_SETTING_SCT_OUTGOING_DOT_ENABLED ~= nil then
        setSettingSafe(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_DOT_ENABLED, enabled)
    end
    -- Sorcerer and other pet builds should see their pet hits too.
    if COMBAT_SETTING_SCT_OUTGOING_PET_DAMAGE_ENABLED ~= nil then
        setSettingSafe(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_PET_DAMAGE_ENABLED, enabled)
    end
    if COMBAT_SETTING_SCT_OUTGOING_PET_DOT_ENABLED ~= nil then
        setSettingSafe(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_PET_DOT_ENABLED, enabled)
    end
end

function P:ApplyCombatStatusEffects()
    if not EPC.saved or EPC.saved.showCombatStatusEffects == false then return end

    -- ESO's outgoing SCT status-effect channel covers combat feedback such as
    -- applied crowd control/debuff/status messages (including taunt feedback
    -- when the game emits it through SCT). Keep target debuffs visible too.
    if SETTING_TYPE_COMBAT ~= nil then
        local enabled = 1
        if COMBAT_SETTING_SCROLLING_COMBAT_TEXT_ENABLED ~= nil then
            setSettingSafe(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCROLLING_COMBAT_TEXT_ENABLED, enabled)
        end
        if COMBAT_SETTING_SCT_OUTGOING_ENABLED ~= nil then
            setSettingSafe(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_ENABLED, enabled)
        end
        if COMBAT_SETTING_SCT_OUTGOING_STATUS_EFFECTS_ENABLED ~= nil then
            setSettingSafe(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_STATUS_EFFECTS_ENABLED, enabled)
        end
        if COMBAT_SETTING_SCT_INCOMING_ENABLED ~= nil then
            setSettingSafe(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_INCOMING_ENABLED, enabled)
        end
        if COMBAT_SETTING_SCT_INCOMING_STATUS_EFFECTS_ENABLED ~= nil then
            setSettingSafe(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_INCOMING_STATUS_EFFECTS_ENABLED, enabled)
        end
    end

    -- Do NOT turn ESO's native buff/debuff HUD back on here. The Suite already
    -- renders those effects inside its Player/Target frames, so enabling the
    -- stock buff frame creates a second, visually identical row of abilities.
    -- Scrolling combat status text above is independent and remains enabled.
    -- Explicitly hide the stock buff/debuff containers while either custom unit
    -- frame is enabled, including for users whose setting was forced to ALWAYS
    -- SHOW by v0.24.24-v0.24.27.
    if SETTING_TYPE_BUFFS ~= nil and BUFFS_SETTING_ALL_ENABLED ~= nil then
        local suiteOwnsAuraDisplay = EPC.saved and
            (EPC.saved.showPlayerFrame ~= false or EPC.saved.showTargetFrame ~= false)
        if suiteOwnsAuraDisplay and BUFF_DEBUFF_ENABLED_CHOICE_DONT_SHOW ~= nil then
            setSettingSafe(SETTING_TYPE_BUFFS, BUFFS_SETTING_ALL_ENABLED, BUFF_DEBUFF_ENABLED_CHOICE_DONT_SHOW)
        end
    end
end

function P:Apply()
    self:ApplyEnemyHealthBars()
    self:ApplyOutgoingDamageNumbers()
    self:ApplyCombatStatusEffects()
end

function P:Refresh()
    self:Apply()
end

function P:Initialize()
    self:Apply()
    if EVENT_MANAGER and EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(EPC.name .. "_CombatPresentation", EVENT_PLAYER_ACTIVATED, function()
            P:Apply()
        end)
    end
end
