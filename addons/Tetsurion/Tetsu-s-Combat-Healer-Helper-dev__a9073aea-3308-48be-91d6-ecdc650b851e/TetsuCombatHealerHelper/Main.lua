local ADDON_NAME = "TetsuCombatHealerHelper"
TetsuCombatHealerHelper = TetsuCombatHealerHelper or {}
local T = TetsuCombatHealerHelper

local defaultAccountVars = {
    enabled = true,
    iconSize = 40,
    prayerEnabled = true,
    prayerColor = { r = 1, g = 0.2, b = 0.2, a = 1 },
    ihColor = { r = 0.25, g = 0.95, b = 0.45, a = 1 },
    headExtraKey = "off",
    headExtraColor = { r = 1, g = 0.45, b = 0.15, a = 1 },
    hudList = true,
    worldPips = true,
    hudBuff1 = "powerfulAssault",
    hudBuff2 = "majorCourage",
    hudBuff3 = "echoingVigor",
    hudBuff4 = "off",
    hudBuff5 = "off",
    hudOffsetX = 0,
    hudOffsetY = 0,
    hudScale = 1,
    headHeight = 2.15,
    headMode = "auto",
}

local function OnEffectChanged(...)
    if T.Heads and T.Heads.OnEffectChanged then
        T.Heads.OnEffectChanged(...)
    end
end

local function OnCombatState(_, inCombat)
    if T.Heads and T.Heads.OnCombatState then
        T.Heads.OnCombatState(_, inCombat)
    end
end

local function OnPlayerActivated()
    if T.Puddle and T.Puddle.Hide then
        T.Puddle.Hide()
    end
    if T.Heads then
        if T.Heads.ScanGroupBuffs then T.Heads.ScanGroupBuffs() end
        T.Heads.RefreshAll()
    end
end

local function RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE, OnCombatState)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "EffGroup", EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "EffGroup", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "EffPlayer", EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "EffPlayer", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_JOINED, function()
        if T.Heads then
            if T.Heads.ScanGroupBuffs then T.Heads.ScanGroupBuffs() end
            T.Heads.RefreshAll()
        end
    end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_LEFT, function()
        if T.Heads then T.Heads.RefreshAll() end
    end)
    if EVENT_GROUP_UPDATE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_UPDATE, function()
            if T.Heads then
                if T.Heads.ScanGroupBuffs then T.Heads.ScanGroupBuffs() end
                T.Heads.RefreshAll()
            end
        end)
    end
    if EVENT_GROUP_MEMBER_CONNECTED_STATUS then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_CONNECTED_STATUS, function()
            if T.Heads then T.Heads.RefreshAll() end
        end)
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    T.savedVars = ZO_SavedVars:NewAccountWide(
        "TetsuCombatHealerHelperSavedVars",
        3,
        nil,
        defaultAccountVars
    )

    local function SanitizeKey(key)
        if key == "illustrious" or key == "prayer" then
            return "off"
        end
        return key
    end
    T.savedVars.headExtraKey = SanitizeKey(T.savedVars.headExtraKey)
    for i = 1, 5 do
        T.savedVars["hudBuff" .. i] = SanitizeKey(T.savedVars["hudBuff" .. i])
    end

    if T.RegisterSettings then
        T.RegisterSettings()
    end

    RegisterEvents()
    if T.Heads and T.Heads.Start then
        T.Heads.Start()
    end
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        pcall(function()
            CHAT_SYSTEM:AddMessage("|c3CFF8C[Tetsu CHH 1.3.2]|r Heads = missing heals. HUD = buffs present.")
        end)
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
