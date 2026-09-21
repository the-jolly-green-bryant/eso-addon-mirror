GrimSuite = GrimSuite or {}
local GS = GrimSuite

GS.name = "GrimSuite"
GS.version = "1.2.1"

GS.SV = {
    gcd = 1000,
    showGCD = true,
    showWeave = true,
    gcdX = 780,
    gcdY = 500,
    gcdWidth = 360,
    gcdHeight = 18,
    weaveX = 780,
    weaveY = 530,
    weaveWidth = 360,
    weaveHeight = 34,
    weaveAverageX = 258,
    weaveAverageY = 0,
    attributesX = 0,
    attributesY = 0,
}

local function LoadSavedVars()
    GS.Saved = ZO_SavedVars:NewAccountWide("GrimSuiteSavedVars", 1, nil, GS.SV)
end

local function Initialize()
    LoadSavedVars()
    GS.Combat:Initialize()
    GS.ActionBar:Initialize()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= GS.name then return end
    EVENT_MANAGER:UnregisterForEvent(GS.name .. "_Load")
    Initialize()
end

EVENT_MANAGER:RegisterForEvent(GS.name .. "_Load", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
