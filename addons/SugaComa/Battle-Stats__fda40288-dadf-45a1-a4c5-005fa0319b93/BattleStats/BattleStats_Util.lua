BattleStats = BattleStats or {}
BattleStats.Util = BattleStats.Util or {}
local Util = BattleStats.Util

-- API MAP (verified in esoui-11.2.6/ESOUIDocumentation.txt)
-- Functions (signatures):
--   GetPlayerStat(DerivedStats derivedStat, StatBonusOption statBonusOption) -> integer value
--   IsUnitInCombat(string unitTag) -> bool
--   GetFrameTimeMilliseconds() -> integer
--   GetGameTimeMilliseconds() -> integer
--   WINDOW_MANAGER:CreateTopLevelWindow(string name)
--   WINDOW_MANAGER:CreateControl(string name, object parent, ControlType type)
--   Control:SetMovable(bool isMovable)
--   Control:SetHandler(string handlerName, function callback, string name, ControlHandlerOrder order, string targetName)
--   Control:StartMoving()
--   Control:StopMovingOrResizing()
--   Control:GetCenter()
--   EVENT_MANAGER:RegisterForEvent(string name, integer event, function callback, bool doOnce)
--   EVENT_MANAGER:UnregisterForEvent(string name, integer event)
--   EVENT_MANAGER:RegisterForUpdate(string name, integer minInterval, function callback)
--   EVENT_MANAGER:UnregisterForUpdate(string name)
-- Events (signatures):
--   EVENT_PLAYER_COMBAT_STATE(bool inCombat)
--   EVENT_EFFECT_CHANGED(EffectResult changeType, integer effectSlot, string effectName, string unitTag, number beginTime, number endTime, integer stackCount, string iconName, string deprecatedBuffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, integer unitId, integer abilityId, CombatUnitType sourceType)
--   EVENT_STATS_UPDATED(string unitTag)
--   EVENT_POWER_UPDATE(string unitTag, luaindex powerIndex, CombatMechanicFlags powerType, integer powerValue, integer powerMax, integer powerEffectiveMax)
--   EVENT_INVENTORY_SINGLE_SLOT_UPDATE(Bag bagId, integer slotIndex, bool isNewItem, ItemUISoundCategory itemSoundCategory, integer inventoryUpdateReason, integer stackCountChange, string triggeredByCharacterName, string triggeredByDisplayName, bool isLastUpdateForMessage, BonusDropSource bonusDropSource)
--   EVENT_ACTIVE_WEAPON_PAIR_CHANGED(ActiveWeaponPair activeWeaponPair, bool locked)
--   EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED(bool didActiveHotbarChange, bool shouldUpdateAbilityAssignments, HotBarCategory activeHotbarCategory)
--   EVENT_PLAYER_ACTIVATED(bool initial)
--   SCENE_MANAGER:IsShowing(string sceneName) -> bool
--   HUD_SCENE:IsShowing() -> bool
--   HUD_UI_SCENE:IsShowing() -> bool
-- Missing in docs:
--   GetPlayerMagickaRecovery, GetPlayerStaminaRecovery, GetPlayerHealthRecovery, GetPlayerWeaponAndSpellDamage, GetPlayerResistance,
--   GetPlayerStatValue, GetPlayerAttribute, GetUnitPowerRegen, EVENT_ATTRIBUTE_UPDATE
-- Fallbacks:
--   Use GetPlayerStat with STAT_*_REGEN_COMBAT/IDLE, STAT_ATTACK_POWER, STAT_SPELL_POWER, STAT_PHYSICAL_RESIST, STAT_SPELL_RESIST.
--   If STAT_ATTACK_POWER or STAT_SPELL_POWER missing, fall back to STAT_WEAPON_AND_SPELL_DAMAGE.
--   If any function/constant missing, show "N/A".

Util._missingOnce = Util._missingOnce or {}

function Util.HasFunction(name)
    return type(_G[name]) == "function"
end

function Util.HasGlobal(name)
    return _G[name] ~= nil
end

function Util.Debug(msg)
    if BattleStats and BattleStats.SV and BattleStats.SV.debug == true then
        d("BattleStats: " .. tostring(msg))
    end
end

function Util.DebugMissing(kind, name)
    local key = tostring(kind) .. ":" .. tostring(name)
    if Util._missingOnce[key] then return end
    Util._missingOnce[key] = true
    Util.Debug("Missing " .. tostring(kind) .. " -> " .. tostring(name))
end

function Util.ChatMsg(text)
    local msg = tostring(text or "")
    if msg == "" then return end
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage(msg)
    else
        d(msg)
    end
end

function Util.NowMs()
    if Util.HasFunction("GetFrameTimeMilliseconds") then
        return GetFrameTimeMilliseconds()
    end
    if Util.HasFunction("GetGameTimeMilliseconds") then
        return GetGameTimeMilliseconds()
    end
    return 0
end

function Util.GetDerivedStatValue(statName)
    if not Util.HasFunction("GetPlayerStat") then
        Util.DebugMissing("function", "GetPlayerStat")
        return nil
    end
    local statConst = _G[statName]
    if statConst == nil then
        Util.DebugMissing("stat", statName)
        return nil
    end
    local opt = _G.STAT_BONUS_OPTION_APPLY_BONUS
    if opt == nil then
        Util.DebugMissing("stat", "STAT_BONUS_OPTION_APPLY_BONUS")
        return nil
    end
    return GetPlayerStat(statConst, opt)
end

function Util.GetWeaponDamage()
    local value = Util.GetDerivedStatValue("STAT_ATTACK_POWER")
    if value == nil then
        value = Util.GetDerivedStatValue("STAT_WEAPON_AND_SPELL_DAMAGE")
    end
    return value
end

function Util.GetSpellDamage()
    local value = Util.GetDerivedStatValue("STAT_SPELL_POWER")
    if value == nil then
        value = Util.GetDerivedStatValue("STAT_WEAPON_AND_SPELL_DAMAGE")
    end
    return value
end

function Util.GetRegenValue(combatStatName, idleStatName)
    local value = Util.GetDerivedStatValue(combatStatName)
    if value == nil then
        value = Util.GetDerivedStatValue(idleStatName)
    end
    return value
end

function Util.FormatValue(value)
    if value == nil then return "N/A" end
    local num = tonumber(value)
    if not num then return tostring(value) end
    return tostring(math.floor(num + 0.5))
end

function Util.IsGameplayHUDActive()
    if SCENE_MANAGER and SCENE_MANAGER.IsShowing then
        if SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui") then
            return true
        end
        if SCENE_MANAGER.GetHUDSceneName then
            local hudName = SCENE_MANAGER:GetHUDSceneName()
            if hudName and SCENE_MANAGER:IsShowing(hudName) then return true end
        end
        if SCENE_MANAGER.GetHUDUISceneName then
            local hudUiName = SCENE_MANAGER:GetHUDUISceneName()
            if hudUiName and SCENE_MANAGER:IsShowing(hudUiName) then return true end
        end
    end
    if HUD_SCENE and HUD_SCENE.IsShowing and HUD_SCENE:IsShowing() then
        return true
    end
    if HUD_UI_SCENE and HUD_UI_SCENE.IsShowing and HUD_UI_SCENE:IsShowing() then
        return true
    end
    return false
end
