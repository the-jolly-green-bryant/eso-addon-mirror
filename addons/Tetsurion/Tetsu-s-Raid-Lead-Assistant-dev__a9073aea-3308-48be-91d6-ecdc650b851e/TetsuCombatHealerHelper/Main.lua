local ADDON_NAME = "TetsuCombatHealerHelper"
TetsuCombatHealerHelper = TetsuCombatHealerHelper or {}
local T = TetsuCombatHealerHelper

local defaultAccountVars = {
    enabled = true,
    hudList = true,
    hudBuff1 = "prayer",
    hudBuff2 = "powerfulAssault",
    hudBuff3 = "majorCourage",
    hudBuff4 = "off",
    hudBuff5 = "off",
    hudOffsetX = 0,
    hudOffsetY = 0,
    hudScale = 1,
    sortByRole = true,
    showHealCut = true,
    lowHpTanksOnly = true,
    lowHpPercent = 35,
    hudDotStyle = "solid",
    showRaidPanel = true,
    showBossPanel = true,
    debuffOnTarget = true,
    showPairPanels = true,
    pairOffsetX = 0,
    pairOffsetY = 0,
    oocAlpha = 70,
    customLabel = {},
    hudColColor1 = "green",
    hudColColor2 = "yellow",
    hudColColor3 = "cyan",
    hudColColor4 = "orange",
    hudColColor5 = "purple",
}

local function OnEffectChanged(...)
    if T.Hud and T.Hud.OnEffectChanged then
        T.Hud.OnEffectChanged(...)
    end
end

local function OnCombatState(_, inCombat)
    if T.Hud and T.Hud.OnCombatState then
        T.Hud.OnCombatState(_, inCombat)
    end
end

local function Refresh()
    if T.Hud then
        if T.Hud.ScanGroupBuffs then T.Hud.ScanGroupBuffs() end
        T.Hud.RefreshAll()
    end
end

local function RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE, OnCombatState)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "EffGroup", EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "EffGroup", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "EffPlayer", EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "EffPlayer", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "EffBoss", EVENT_EFFECT_CHANGED, function(...)
        if T.Panels and T.Panels.OnBossEffect then
            T.Panels.OnBossEffect(...)
        end
    end)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "EffBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")
    if EVENT_BOSSES_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_BOSSES_CHANGED, Refresh)
    end
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, Refresh)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_JOINED, Refresh)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_LEFT, function()
        if T.Hud then T.Hud.RefreshAll() end
    end)
    -- IH is a ground HoT: ticks often use ids that are not the skill id.
    -- Ability-id filters on EVENT_COMBAT_EVENT miss those on console.
    -- Listen to heal results only (not every swing), then match id or name.
    local healResults = {
        ACTION_RESULT_HOT_TICK,
        ACTION_RESULT_HOT_TICK_CRITICAL,
        ACTION_RESULT_HEAL,
        ACTION_RESULT_HEAL_CRIT,
        ACTION_RESULT_EFFECT_GAINED,
        ACTION_RESULT_EFFECT_GAINED_DURATION,
    }
    local registered = false
    if REGISTER_FILTER_COMBAT_RESULT then
        for i = 1, #healResults do
            local res = healResults[i]
            if res then
                local ns = ADDON_NAME .. "IHRes" .. tostring(res)
                EVENT_MANAGER:RegisterForEvent(ns, EVENT_COMBAT_EVENT, function(...)
                    if T.Hud and T.Hud.OnCombatEvent then
                        T.Hud.OnCombatEvent(...)
                    end
                end)
                EVENT_MANAGER:AddFilterForEvent(ns, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, res)
                registered = true
            end
        end
    end
    if not registered then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT, function(...)
            if T.Hud and T.Hud.OnCombatEvent then
                T.Hud.OnCombatEvent(...)
            end
        end)
    end
    if EVENT_GROUP_UPDATE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_UPDATE, Refresh)
    end
    if EVENT_GROUP_MEMBER_CONNECTED_STATUS then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_CONNECTED_STATUS, function()
            if T.Hud then T.Hud.RefreshAll() end
        end)
    end
    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function()
            if T.Hud then T.Hud.RefreshAll() end
            if T.Panels then T.Panels.Refresh() end
        end)
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    T.savedVars = ZO_SavedVars:NewAccountWide(
        "TetsuCombatHealerHelperSavedVars",
        5,
        nil,
        defaultAccountVars
    )
    local drop = {
        illustrious = true,
        vigor = true,
        echoingVigor = true,
        resolvingVigor = true,
        energyOrb = true,
        orbLockout = true,
    }
    for i = 1, 5 do
        local k = T.savedVars["hudBuff" .. i]
        if drop[k] then
            T.savedVars["hudBuff" .. i] = "off"
        end
    end
    T.savedVars.autoColumns = false
    -- Less-used boss pairs start off so the panel stays short.
    if T.savedVars.debuffPair_fracture == nil then T.savedVars.debuffPair_fracture = false end
    if T.savedVars.debuffPair_cowardice == nil then T.savedVars.debuffPair_cowardice = false end
    if T.savedVars.debuffPair_maim == nil then T.savedVars.debuffPair_maim = false end

    if T.RegisterSettings then
        T.RegisterSettings()
    end

    RegisterEvents()
    if T.Hud and T.Hud.Start then
        T.Hud.Start()
    end
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        pcall(function()
            -- no boot chat spam
        end)
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
