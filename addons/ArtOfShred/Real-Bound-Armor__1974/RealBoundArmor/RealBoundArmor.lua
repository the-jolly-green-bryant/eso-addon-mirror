------------------
-- LUIE namespace
RealBoundArmor   = {}
RealBoundArmor.name        = "RealBoundArmor"
RealBoundArmor.author      = "ArtOfShred"
RealBoundArmor.version     = "2.3"
RealBoundArmor.website     = "http://www.esoui.com/downloads/info1974-RealBoundArmor.html"
RealBoundArmor.components  = {}

-- Saved variables options
RealBoundArmor.SV          = nil
RealBoundArmor.SVVer       = 2
RealBoundArmor.SVName      = "RBA"

-- Default Settings
RealBoundArmor.D = {
    OutfitOn               = 2,
    OutfitOff              = 1,
}

-- Settings Menu Dropdown Options
local OutfitChoicesOptions = { "No Outfit", "Outfit 1", "Outfit 2", "Outfit 3", "Outfit 4", "Outfit 5", "Outfit 6", "Outfit 7", "Outfit 8", "Outfit 9", "Outfit 10" }
local OutfitChoicesData = { ["No Outfit"] = 1, ["Outfit 1"] = 2, ["Outfit 2"] = 3, ["Outfit 3"] = 4, ["Outfit 4"] = 5, ["Outfit 5"] = 6, ["Outfit 6"] = 7, ["Outfit 7"] = 8, ["Outfit 8"] = 9, ["Outfit 9"] = 10, ["Outfit 10"] = 11 }

local ArmorIds = {
    [24158] = true, -- Bound Armor
    [24165] = true, -- Bound Armaments
    [24163] = true, -- Bound Aegis
}

-- Load saved settings
local function RealBoundArmor_LoadSavedVars()
    -- Addon options
    RealBoundArmor.SV = ZO_SavedVars:NewAccountWide(RealBoundArmor.SVName, RealBoundArmor.SVVer, nil, RealBoundArmor.D)
end

-- Equip the outfit we have selected for one of the abilities being on.
local function EquipActiveOutfit()
    if RealBoundArmor.SV.OutfitOn > 1 then
        EquipOutfit(RealBoundArmor.SV.OutfitOn - 1)
    else
        UnequipOutfit()
    end
end

-- Equip the outfit we have selected for one of the abilities being off.
local function EquipInactiveOutfit()
    if RealBoundArmor.SV.OutfitOff > 1 then
        EquipOutfit(RealBoundArmor.SV.OutfitOff - 1)
    else
        UnequipOutfit()
    end
end

-- Called with a 50ms delay when one of the ids fades in order to check first if the ability was recast before making any changes.
local function CheckRemoveArmor(onLoad)
    local foundBuff
    -- Check for one of the buffs.
    for i = 1, GetNumBuffs("player") do
        local abilityId = select(11, GetUnitBuffInfo("player", i) )
        for k,v in pairs (ArmorIds) do
            if k == abilityId then
                foundBuff = true
                break
            end
        end
    end
    -- If the buff isn't found then run the function to set outfit to remove.
    if foundBuff and onLoad then
        EquipActiveOutfit()
    else
        EquipInactiveOutfit()
    end
end

-- EVENT_EFFECT_CHANGED Handler
local function RealBoundArmor_OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, castByPlayer)
    if changeType == EFFECT_RESULT_FADED then
        -- Call this with a slight delay, just in case the player refreshes the ability we don't want to try to unequip the outfit.
        zo_callLater(CheckRemoveArmor, 50)
    else
        EquipActiveOutfit()
    end
end

-- EVENT_PLAYER_ACTIVATED Handler
-- Runs any time this event fires, just in case for example, one of the abilities fades when the player is teleporting to a Wayshrine.
local function RealBoundArmor_OnPlayerActivated()
    CheckRemoveArmor(true)
end

-- Register filtered events for the relevant abilities & register a handler for EVENT_PLAYER_ACTIVATED
local function RealBoundArmor_RegisterEvents()
    local counter = 1
    for abilityId, _ in pairs (ArmorIds) do
       EVENT_MANAGER:RegisterForEvent(RealBoundArmor.name .. counter, EVENT_EFFECT_CHANGED, RealBoundArmor_OnEffectChanged)
       EVENT_MANAGER:AddFilterForEvent(RealBoundArmor.name .. counter, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)
       counter = counter + 1
    end
    EVENT_MANAGER:RegisterForEvent(RealBoundArmor.name, EVENT_PLAYER_ACTIVATED, RealBoundArmor_OnPlayerActivated)
end

local function RealBoundArmor_CreateSettings()

    -- Load LibAddonMenu
    local LAM2 = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = "Real Bound Armor",
        displayName = zo_strformat("Real Bound Armor", GetString(SI_GAME_MENU_SETTINGS)),
        author = RealBoundArmor.author,
        version = RealBoundArmor.version,
        website = RealBoundArmor.website,
        slashCommand = "/rbaset",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {}

    optionsData[#optionsData + 1] = {
        type = "dropdown",
        name = "Outfit - Bound Armor Activated",
        tooltip = "Choose the outfit slot to switch to when Bound Armor is activated.",
        choices = OutfitChoicesOptions,
        getFunc = function() return OutfitChoicesOptions[RealBoundArmor.SV.OutfitOn] end,
        setFunc = function(value) RealBoundArmor.SV.OutfitOn = OutfitChoicesData[value] end,
        width = "full",
        default = RealBoundArmor.D.OutfitOn,
    }
    optionsData[#optionsData + 1] = {
        type = "dropdown",
        name = "Outfit - Bound Armor Deactivated",
        tooltip = "Choose the outfit slot to switch to when Bound Armor is deactivated.",
        choices = OutfitChoicesOptions,
        getFunc = function() return OutfitChoicesOptions[RealBoundArmor.SV.OutfitOff] end,
        setFunc = function(value) RealBoundArmor.SV.OutfitOff = OutfitChoicesData[value] end,
        width = "full",
        default = RealBoundArmor.D.OutfitOff,
    }

    LAM2:RegisterAddonPanel('RealBoundArmorAddonOptions', panelData)
    LAM2:RegisterOptionControls('RealBoundArmorAddonOptions', optionsData)

end

-- Initialization
local function RealBoundArmor_OnAddOnLoaded(eventCode, addonName)
    -- Only initialize our own addon
    if RealBoundArmor.name ~= addonName then
        return
    end
    -- Once we know it's ours, lets unregister the event listener
    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
    -- Load saved variables
    RealBoundArmor_LoadSavedVars()
    -- Create settings menu for our addon
    RealBoundArmor_CreateSettings()

    -- Only register events if we're playing a Sorcerer
    local class = GetUnitClassId("player") 
    if class == 2 then
        -- Register global event listeners
        RealBoundArmor_RegisterEvents()
    end
end

-- Hook initialization
EVENT_MANAGER:RegisterForEvent(RealBoundArmor.name, EVENT_ADD_ON_LOADED, RealBoundArmor_OnAddOnLoaded)
