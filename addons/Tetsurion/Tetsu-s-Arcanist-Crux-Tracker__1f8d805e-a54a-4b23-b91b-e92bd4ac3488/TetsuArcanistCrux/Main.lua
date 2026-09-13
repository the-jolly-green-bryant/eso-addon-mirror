local ADDON_NAME = "TetsuArcanistCrux"
TetsuArcanistCrux = TetsuArcanistCrux or {}
local T = TetsuArcanistCrux

T.VERSION = "1.0.14"

local defaultAccountVars = {
    showIcons = true,
    showNumber = false,
    showBar = true,
    iconLayout = "triangle",
    iconSize = 30,
    iconX = 0,
    iconY = 0,
    iconRadius = 50,
    numberSize = 42,
    numberX = 0,
    numberY = 0,
    barAlpha2 = 20,
    barAlpha3 = 40,
    combatOnly = true,
    iconAlpha12 = 50,
    iconAlpha3 = 100,
    numAlpha12 = 50,
    numAlpha3 = 100,
    color2 = { 1.00, 0.85, 0.15, 1 },
    color3 = { 0.95, 0.18, 0.16, 1 },
    soundEnabled = true,
    soundId = "kill",
    soundVolume = 2,
}

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    T.savedVars = ZO_SavedVars:NewAccountWide(
        "TetsuArcanistCruxSavedVars",
        1,
        nil,
        defaultAccountVars
    )

    local v = T.savedVars
    if type(v.color2) ~= "table" then v.color2 = { 1.00, 0.85, 0.15, 1 } end
    if type(v.color3) ~= "table" then v.color3 = { 0.95, 0.18, 0.16, 1 } end
    if v.defaultsRev == nil or v.defaultsRev < 2 then
        if v.iconLayout == nil or v.iconLayout == "rowH" then
            v.iconLayout = "triangle"
        end
        if v.iconSize == nil or v.iconSize == 48 then v.iconSize = 30 end
        if v.iconY == nil or v.iconY == 90 then v.iconY = 0 end
        if v.iconRadius == nil or v.iconRadius == 72 then v.iconRadius = 50 end
        if v.iconX == nil then v.iconX = 0 end
        if v.numberX == nil then v.numberX = 0 end
        if v.numberY == nil then v.numberY = 0 end
        if v.showIcons == nil then v.showIcons = true end
        if v.showBar == nil then v.showBar = true end
        if v.showNumber == nil then v.showNumber = false end
        v.defaultsRev = 2
    end
    if v.defaultsRev < 3 then
        if v.barAlpha2 == nil or v.barAlpha2 == 30 then v.barAlpha2 = 20 end
        if v.barAlpha3 == nil or v.barAlpha3 == 70 then v.barAlpha3 = 40 end
        v.defaultsRev = 3
    end
    if v.iconLayout ~= "rowH" and v.iconLayout ~= "rowV" and v.iconLayout ~= "triangle" then
        v.iconLayout = "triangle"
    end
    if v.soundId == nil then v.soundId = "kill" end
    if v.soundVolume == nil then v.soundVolume = 2 end
    if v.combatOnly == nil then v.combatOnly = true end
    if v.iconAlpha12 == nil then v.iconAlpha12 = 50 end
    if v.iconAlpha3 == nil then v.iconAlpha3 = 100 end
    if v.numAlpha12 == nil then v.numAlpha12 = 50 end
    if v.numAlpha3 == nil then v.numAlpha3 = 100 end
    if v.barAlpha2 == nil then v.barAlpha2 = 20 end
    if v.barAlpha3 == nil then v.barAlpha3 = 40 end

    if T.RegisterSettings then T.RegisterSettings() end
    if T.UIStart then T.UIStart() end
    if T.TrackerStart then T.TrackerStart() end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
