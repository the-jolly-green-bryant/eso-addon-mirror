local SQA = {}
SQA.name = "QuickslotAddon"

-- Przechowywanie linku do przedmiotu w lokalnej tabeli dla optymalizacji
local ITEM_LINKS = {
    CORALRIPTIDE = "|H1:item:186547:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
    MK = "|H1:item:95452:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
    BAHSEI = "|H1:item:173591:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
}

function SQA.InitSavedVariables()
    local defaults = {
        dd_enableAddon = true,
        dd_enableStaminaQuickslot = false,
        dd_enableMagickaVsStamina = false,
        dd_enableCoralRiptideCheck = false, -- Nowa opcja
        dd_enableMKCheck = false, -- Nowa opcja
        dd_coralriptideMode_stamina = 20,
        dd_enableArcanistCheck = false,
        dd_enableCriticalHPCheck = false,
        dd_criticalHPThreshold = 30,
        dd_enableMagickaQuickslot = false, -- Nowa opcja
        dd_enableBahseiCheck = false, -- Nowa opcja
        dd_magickaThreshold = 20, -- Domyślny próg dla Magicki
        dd_staminaQuickslotLow = 2, -- Domyślnie stamina potion
        dd_staminaQuickslotHigh = 1, -- Domyślnie podstawowy quickslot
        dd_magickaQuickslotLow = 4, -- Domyślnie magicka potion
        dd_magickaQuickslotHigh = 5, -- Domyślnie podstawowy quickslot
        dd_magickaVsStaminaQuickslotLow = 4, -- Magicka vs Stamina (Stamina < Magicka)
        dd_magickaVsStaminaQuickslotHigh = 5, -- Magicka vs Stamina (Stamina > Magicka)
        dd_criticalHPQuickslot = 3, -- Domyślnie healing potion
    }
    SQA.savedVariables = ZO_SavedVars:NewCharacterIdSettings("SQASV", 1, nil, defaults)
end

function SQA.GetPowerValues()
    local currentStamina, maxStamina = GetUnitPower("player", POWERTYPE_STAMINA)
    local currentMagicka, maxMagicka = GetUnitPower("player", POWERTYPE_MAGICKA)
    local currentHP, maxHP = GetUnitPower("player", POWERTYPE_HEALTH)
    return {
        stamina = { current = currentStamina or 0, max = maxStamina or 1 },
        magicka = { current = currentMagicka or 0, max = maxMagicka or 1 },
        health = { current = currentHP or 0, max = maxHP or 1 },
    }
end

function SQA.OnAddonLoaded(event, addonName)
    if addonName ~= SQA.name then return end
    SQA.InitSavedVariables()
    SQA.CreateMenu()
    EVENT_MANAGER:RegisterForEvent(SQA.name, EVENT_PLAYER_COMBAT_STATE, SQA.OnCombatState)
end

function SQA.CheckSet(setItem)
    local _, _, _, numNormalEquipped, _, _, numPerfectedEquipped = GetItemLinkSetInfo(setItem, true)
    return (tonumber(numNormalEquipped) or 0) + (tonumber(numPerfectedEquipped) or 0)
end

function SQA.HasLowStamina()
    local power = SQA.GetPowerValues()
    return power.stamina.current < (power.stamina.max * SQA.savedVariables.dd_coralriptideMode_stamina / 100)
end

function SQA.HasLowMagicka()
    local power = SQA.GetPowerValues()
    return power.magicka.current < (power.magicka.max * SQA.savedVariables.dd_magickaThreshold / 100)
end

function SQA.HasCriticalHP()
    if not SQA.savedVariables.dd_enableCriticalHPCheck then return false end
    local power = SQA.GetPowerValues()
    return power.health.current < (power.health.max * SQA.savedVariables.dd_criticalHPThreshold / 100)
end

function SQA.MagickaVsStaminaCheck()
    if not SQA.savedVariables.dd_enableMagickaVsStamina or SQA.savedVariables.dd_enableStaminaQuickslot then return nil end
    
    local power = SQA.GetPowerValues()
    local staminaPercent = (power.stamina.current / power.stamina.max) * 100
    local magickaPercent = (power.magicka.current / power.magicka.max) * 100

    return (staminaPercent < magickaPercent) and 4 or 5
end

local updaterName = SQA.name .. "_CoralRiptideStaminaPotionCheck"
function SQA.OnCombatState(event, inCombat)
    if inCombat then
        EVENT_MANAGER:UnregisterForUpdate(updaterName)
        EVENT_MANAGER:RegisterForUpdate(updaterName, 1000, SQA.Core)
    else
        EVENT_MANAGER:UnregisterForUpdate(updaterName)
    end
end

function SQA.Core()
    if not SQA.savedVariables.dd_enableAddon then
        EVENT_MANAGER:UnregisterForUpdate(updaterName)
        return
    end

    -- 1. Sprawdzenie krytycznego poziomu HP (najwyższy priorytet)
    if SQA.HasCriticalHP() then
        SetCurrentQuickslot(SQA.savedVariables.dd_criticalHPQuickslot) -- Dynamiczny wybór Quickslotu
        return
    end

    -- 2. Sprawdzenie Magicka vs Stamina Quickslot
    local quickslot = SQA.MagickaVsStaminaCheck()
    if quickslot then
        SetCurrentQuickslot(quickslot) -- Dynamiczny wybór Quickslotu (Magicka vs Stamina)
        return
    end

    -- 3. Sprawdzenie Stamina Quickslot (dawniej Coral Riptide Quickslot)
    if SQA.savedVariables.dd_enableStaminaQuickslot then
        local coralRiptideParts = SQA.CheckSet(ITEM_LINKS.CORALRIPTIDE)
        local mkParts = SQA.CheckSet(ITEM_LINKS.MK)

        -- Sprawdzenie, czy aktywne sprawdzanie zestawów (jeśli NIE aktywne → ignorujemy sprawdzanie setów)
        local checkCoral = SQA.savedVariables.dd_enableCoralRiptideCheck
        local checkMK = SQA.savedVariables.dd_enableMKCheck

        -- Jeśli włączone sprawdzanie Coral/MK, ale brak 3 części → addon NIE działa
        if (checkCoral and coralRiptideParts < 3) and (checkMK and mkParts < 3) then
            return
        end

        -- Sprawdzenie klasy Arcanist, jeśli opcja jest włączona
        if SQA.savedVariables.dd_enableArcanistCheck and GetUnitClassId("player") ~= 117 then
            return
        end

        -- Jeśli mamy wymagany zestaw LUB sprawdzanie zestawów jest wyłączone → addon działa
        if SQA.HasLowStamina() then
            SetCurrentQuickslot(SQA.savedVariables.dd_staminaQuickslotLow) -- Dynamiczny wybór Quickslotu dla niskiej staminy
        else
            SetCurrentQuickslot(SQA.savedVariables.dd_staminaQuickslotHigh) -- Dynamiczny wybór Quickslotu dla wysokiej staminy
        end

        return -- Jeśli używany jest Stamina Quickslot, reszta nie jest wykonywana
    end

    -- 4. Sprawdzenie Magicka Quickslot
    if SQA.savedVariables.dd_enableMagickaQuickslot then
        local bahseiParts = SQA.CheckSet(ITEM_LINKS.BAHSEI)

        -- Sprawdzenie, czy aktywne sprawdzanie Bahsei (jeśli NIE aktywne → ignorujemy sprawdzanie setów)
        local checkBahsei = SQA.savedVariables.dd_enableBahseiCheck

        -- Jeśli włączone sprawdzanie Bahsei, ale brak 3 części → addon NIE działa
        if checkBahsei and bahseiParts < 3 then
            return
        end

        -- Jeśli mamy wymagany zestaw LUB sprawdzanie zestawów jest wyłączone → addon działa
        if SQA.HasLowMagicka() then
            SetCurrentQuickslot(SQA.savedVariables.dd_magickaQuickslotLow) -- Dynamiczny wybór Quickslotu dla niskiej magicki
        else
            SetCurrentQuickslot(SQA.savedVariables.dd_magickaQuickslotHigh) -- Dynamiczny wybór Quickslotu dla wysokiej magicki
        end
    end
end

function SQA.CreateMenu()
    if not LibAddonMenu2 then return end
    
    local panelData = {
        type = "panel",
        name = "Quickslot Addon",
        displayName = "|cFF0000Quick|c00FF00Slot|c0000FFAddon|r",
        author = "@xHouston",
        version = "1.6",
        slashCommand = "/qa",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LibAddonMenu2:RegisterAddonPanel(SQA.name .. "Options", panelData)

    local optionsData = {
        { type = "header", name = "General Settings" },
        {
            type = "checkbox",
            name = "Enable Addon",
            getFunc = function() return SQA.savedVariables.dd_enableAddon end,
            setFunc = function(value) SQA.savedVariables.dd_enableAddon = value end,
            tooltip = "Enable or disable the addon",
            width = "full",
        },
        
        { type = "header", name = "|c00FF00Stamina Quickslot|r" },
        {
            type = "checkbox",
            name = "Enable Stamina Quickslot",
            getFunc = function() return SQA.savedVariables.dd_enableStaminaQuickslot end,
            setFunc = function(value) 
                SQA.savedVariables.dd_enableStaminaQuickslot = value
                if value then 
                    SQA.savedVariables.dd_enableMagickaQuickslot = false
                    SQA.savedVariables.dd_enableMagickaVsStamina = false
                end
            end,
            tooltip = "Automatically switches between Quickslot 1 and Quickslot 2 based on stamina levels.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Stamina Quickslot Low",
            choices = {"1", "2", "3", "4", "5", "6", "7", "8"},
            getFunc = function() return tostring(SQA.savedVariables.dd_staminaQuickslotLow) end,
            setFunc = function(value) SQA.savedVariables.dd_staminaQuickslotLow = tonumber(value) end,
            tooltip = "Select which quickslot will be used when stamina is low.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Stamina Quickslot High",
            choices = {"1", "2", "3", "4", "5", "6", "7", "8"},
            getFunc = function() return tostring(SQA.savedVariables.dd_staminaQuickslotHigh) end,
            setFunc = function(value) SQA.savedVariables.dd_staminaQuickslotHigh = tonumber(value) end,
            tooltip = "Select which quickslot will be used when stamina is above the threshold.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable Coral Riptide Checking",
            getFunc = function() return SQA.savedVariables.dd_enableCoralRiptideCheck end,
            setFunc = function(value) SQA.savedVariables.dd_enableCoralRiptideCheck = value end,
            tooltip = "If enabled, the addon will require at least 3 pieces of the Coral Riptide set to activate Stamina Quickslot.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable MK Checking",
            getFunc = function() return SQA.savedVariables.dd_enableMKCheck end,
            setFunc = function(value) SQA.savedVariables.dd_enableMKCheck = value end,
            tooltip = "If enabled, the addon will require at least 3 pieces of the MK set to activate Stamina Quickslot.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Only Arcanist Class",
            getFunc = function() return SQA.savedVariables.dd_enableArcanistCheck end,
            setFunc = function(value) SQA.savedVariables.dd_enableArcanistCheck = value end,
            tooltip = "If enabled, addon only works for Arcanist. If disabled, it works for all classes.",
            width = "full",
        },
        {
            type = "slider",
            name = "Stamina Threshold (%)",
            getFunc = function() return SQA.savedVariables.dd_coralriptideMode_stamina end,
            setFunc = function(value) SQA.savedVariables.dd_coralriptideMode_stamina = value end,
            min = 0,
            max = 100,
            default = 20,
            width = "full",
        },
        { type = "header", name = "|c0000FFMagicka Quickslot|r" },
        {
            type = "checkbox",
            name = "Enable Magicka Quickslot",
            getFunc = function() return SQA.savedVariables.dd_enableMagickaQuickslot end,
            setFunc = function(value) 
                SQA.savedVariables.dd_enableMagickaQuickslot = value
                if value then 
                    SQA.savedVariables.dd_enableStaminaQuickslot = false
                    SQA.savedVariables.dd_enableMagickaVsStamina = false
                end
            end,
            tooltip = "Automatically switches between Quickslot 1 and Quickslot 6 based on magicka levels.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Magicka Quickslot Low",
            choices = {"1", "2", "3", "4", "5", "6", "7", "8"},
            getFunc = function() return tostring(SQA.savedVariables.dd_magickaQuickslotLow) end,
            setFunc = function(value) SQA.savedVariables.dd_magickaQuickslotLow = tonumber(value) end,
            tooltip = "Select which quickslot will be used when magicka is low.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Magicka Quickslot High",
            choices = {"1", "2", "3", "4", "5", "6", "7", "8"},
            getFunc = function() return tostring(SQA.savedVariables.dd_magickaQuickslotHigh) end,
            setFunc = function(value) SQA.savedVariables.dd_magickaQuickslotHigh = tonumber(value) end,
            tooltip = "Select which quickslot will be used when magicka is above the threshold.",
            width = "full",
        },        
        {
            type = "checkbox",
            name = "Enable Bahsei Checking",
            getFunc = function() return SQA.savedVariables.dd_enableBahseiCheck end,
            setFunc = function(value) SQA.savedVariables.dd_enableBahseiCheck = value end,
            tooltip = "If enabled, requires at least 3 pieces of Bahsei's Mania to activate Magicka Quickslot.",
            width = "full",
        },
        {
            type = "slider",
            name = "Magicka Threshold (%)",
            getFunc = function() return SQA.savedVariables.dd_magickaThreshold end,
            setFunc = function(value) SQA.savedVariables.dd_magickaThreshold = value end,
            min = 0,
            max = 100,
            default = 20,
            width = "full",
        },
        
        { type = "header", name = "|c0000FFMagicka|r vs |c00FF00Stamina|r Quickslot" },
        {
            type = "checkbox",
            name = "Enable Magicka vs Stamina Quickslot",
            getFunc = function() return SQA.savedVariables.dd_enableMagickaVsStamina end,
            setFunc = function(value) 
                SQA.savedVariables.dd_enableMagickaVsStamina = value
                if value then 
                    SQA.savedVariables.dd_enableStaminaQuickslot = false
                    SQA.savedVariables.dd_enableMagickaQuickslot = false
                end
            end,
            tooltip = "If enabled, the addon will switch to quickslot 4 if stamina is lower than magicka, or quickslot 5 otherwise.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Magicka vs Stamina Quickslot (Stamina < Magicka)",
            choices = {"1", "2", "3", "4", "5", "6", "7", "8"},
            getFunc = function() return tostring(SQA.savedVariables.dd_magickaVsStaminaQuickslotLow) end,
            setFunc = function(value) SQA.savedVariables.dd_magickaVsStaminaQuickslotLow = tonumber(value) end,
            tooltip = "Select which quickslot will be used when stamina is lower than magicka.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Magicka vs Stamina Quickslot (Stamina > Magicka)",
            choices = {"1", "2", "3", "4", "5", "6", "7", "8"},
            getFunc = function() return tostring(SQA.savedVariables.dd_magickaVsStaminaQuickslotHigh) end,
            setFunc = function(value) SQA.savedVariables.dd_magickaVsStaminaQuickslotHigh = tonumber(value) end,
            tooltip = "Select which quickslot will be used when stamina is higher than magicka.",
            width = "full",
        },        
        { type = "header", name = "|cFF0000Critical HP Quickslot|r" },
        {
            type = "checkbox",
            name = "Enable Critical HP Quickslot",
            getFunc = function() return SQA.savedVariables.dd_enableCriticalHPCheck end,
            setFunc = function(value) SQA.savedVariables.dd_enableCriticalHPCheck = value end,
            tooltip = "If enabled, the addon will switch to a healing potion quickslot 3 when HP falls below the set threshold.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Critical HP Quickslot",
            choices = {"1", "2", "3", "4", "5", "6", "7", "8"},
            getFunc = function() return tostring(SQA.savedVariables.dd_criticalHPQuickslot) end,
            setFunc = function(value) SQA.savedVariables.dd_criticalHPQuickslot = tonumber(value) end,
            tooltip = "Select which quickslot will be used when HP is critically low.",
            width = "full",
        },        
        {
            type = "slider",
            name = "Critical HP Threshold (%)",
            getFunc = function() return SQA.savedVariables.dd_criticalHPThreshold end,
            setFunc = function(value) SQA.savedVariables.dd_criticalHPThreshold = value end,
            min = 0,
            max = 100,
            default = 30,
            width = "full",
        }
    }
    LibAddonMenu2:RegisterOptionControls(SQA.name .. "Options", optionsData)
end

EVENT_MANAGER:RegisterForEvent(SQA.name, EVENT_ADD_ON_LOADED, SQA.OnAddonLoaded)
