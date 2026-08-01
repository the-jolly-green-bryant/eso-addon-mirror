-- Addon Namespace
local BamCrit = {}
BamCrit.name = "BamCrit"
BamCrit.cmd_show = "/bam"
BamCrit.cmd_reset = "/bamreset"

-- ==========================================================
-- LOCALS & PERFORMANCE
-- ==========================================================
local PlaySound = PlaySound
local EM = EVENT_MANAGER 
local EVENT_COMBAT_EVENT = EVENT_COMBAT_EVENT

-- FILTER CONSTANTS (Nur Direct Crits vom Spieler)
local RES_CRIT_DMG = ACTION_RESULT_CRITICAL_DAMAGE
local RES_CRIT_HEAL = ACTION_RESULT_CRITICAL_HEAL
local FILT_UNIT = REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE
local FILT_RES = REGISTER_FILTER_COMBAT_RESULT
local UNIT_PLAYER = COMBAT_UNIT_TYPE_PLAYER

-- Cache Variables
local currentDmgSoundId = nil 
local currentHealSoundId = nil

-- UI Objects
local BamLabel = nil
local BamAnim = nil
local BamTLC = nil
local BamFlashControl = nil
local BamFlashTexture = nil
local BamFlashAnim = nil
local BamFlashAlphaAnim = nil

-- Words
local dmgWords = { "BAM!", "POW!", "WHAM!", "CRUSH!", "SMASH!", "BONK!", "ZAP!", "KABOOM!", "OUCH!" }
local healWords = { "LIFE!", "HEAL!", "SAVE!", "MEND!", "CURE!", "SHINE!", "GLOW!", "WOOSH!" }

local function GetRandomWord(list)
    return list[math.random(1, #list)]
end

-- ==========================================================
-- LOCALIZATION
-- ==========================================================
local clientLang = GetCVar("language.2")
local L = {}

local strings_en = {
    ["MENU_NAME"] = "|cFF0000Bam|rCrit Settings",
    ["DMG_HEADER"] = "Critical Damage", ["HEAL_HEADER"] = "Critical Healing",
    ["HS_DMG_HEADER"] = "Highscore: Damage", ["HS_HEAL_HEADER"] = "Highscore: Healing",
    ["ENABLE_DMG"] = "Sound Enabled", ["ENABLE_HEAL"] = "Sound Enabled",
    ["ENABLE_TEXT_DMG"] = "Popup Enabled", ["ENABLE_TEXT_HEAL"] = "Popup Enabled",
    ["ENABLE_FLASH_DMG"] = "Flash Enabled", ["ENABLE_FLASH_HEAL"] = "Flash Enabled",
    ["ENABLE_HS"] = "Track Highscore", ["ENABLE_FLASH_HS"] = "Highscore Flash",
    ["DD_DMG_NAME"] = "Sound File", ["DD_HEAL_NAME"] = "Sound File",
    ["COL_TEXT"] = "Popup Color", ["COL_FLASH"] = "Flash Color", ["COL_HS"] = "Highscore Color",
    ["BRIGHTNESS"] = "Flash Brightness",
    ["BTN_TEST_DMG"] = "Test Damage", ["BTN_TEST_HEAL"] = "Test Heal", 
    ["BTN_RESET"] = "Reset Record",
    ["LOADED_MSG"] = "BamCrit 1.2.1 loaded! (Direct Hits Only)",
    ["NEW_RECORD"] = "NEW RECORD!",
    ["HS_DMG"] = "Damage Record: ", ["HS_HEAL"] = "Healing Record: ",
    ["MSG_RESET"] = "All Highscores have been reset!",
}
local strings_de = {
    ["MENU_NAME"] = "|cFF0000Bam|rCrit Einstellungen",
    ["DMG_HEADER"] = "Kritischer Schaden", ["HEAL_HEADER"] = "Kritische Heilung",
    ["HS_DMG_HEADER"] = "Highscore: Schaden", ["HS_HEAL_HEADER"] = "Highscore: Heilung",
    ["ENABLE_DMG"] = "Sound an", ["ENABLE_HEAL"] = "Sound an",
    ["ENABLE_TEXT_DMG"] = "Popup an", ["ENABLE_TEXT_HEAL"] = "Popup an",
    ["ENABLE_FLASH_DMG"] = "Blitz an", ["ENABLE_FLASH_HEAL"] = "Blitz an",
    ["ENABLE_HS"] = "Highscore aktivieren", ["ENABLE_FLASH_HS"] = "Rekord-Blitz an",
    ["DD_DMG_NAME"] = "Sound-Datei", ["DD_HEAL_NAME"] = "Sound-Datei",
    ["COL_TEXT"] = "Popup Farbe", ["COL_FLASH"] = "Blitz Farbe", ["COL_HS"] = "Highscore Farbe",
    ["BRIGHTNESS"] = "Blitz Helligkeit",
    ["BTN_TEST_DMG"] = "Schaden testen", ["BTN_TEST_HEAL"] = "Heilung testen", 
    ["BTN_RESET"] = "Rekord zurücksetzen",
    ["LOADED_MSG"] = "BamCrit 1.2.1 geladen! (Nur Direkttreffer)",
    ["NEW_RECORD"] = "NEUER REKORD!",
    ["HS_DMG"] = "Schaden-Rekord: ", ["HS_HEAL"] = "Heil-Rekord: ",
    ["MSG_RESET"] = "Alle Highscores wurden zurückgesetzt!",
}
local strings_fr = {
    ["MENU_NAME"] = "Paramètres |cFF0000Bam|rCrit",
    ["DMG_HEADER"] = "Dégâts Critiques", ["HEAL_HEADER"] = "Soins Critiques",
    ["HS_DMG_HEADER"] = "Record: Dégâts", ["HS_HEAL_HEADER"] = "Record: Soins",
    ["ENABLE_DMG"] = "Son actif", ["ENABLE_HEAL"] = "Son actif",
    ["ENABLE_TEXT_DMG"] = "Popup actif", ["ENABLE_TEXT_HEAL"] = "Popup actif",
    ["ENABLE_FLASH_DMG"] = "Flash actif", ["ENABLE_FLASH_HEAL"] = "Flash actif",
    ["ENABLE_HS"] = "Activer Highscore", ["ENABLE_FLASH_HS"] = "Flash Record actif",
    ["DD_DMG_NAME"] = "Fichier Son", ["DD_HEAL_NAME"] = "Fichier Son",
    ["COL_TEXT"] = "Couleur Popup", ["COL_FLASH"] = "Couleur Flash", ["COL_HS"] = "Couleur Record",
    ["BRIGHTNESS"] = "Luminosité Flash",
    ["BTN_TEST_DMG"] = "Tester Dégâts", ["BTN_TEST_HEAL"] = "Tester Soins", 
    ["BTN_RESET"] = "Réinitialiser Record",
    ["LOADED_MSG"] = "BamCrit 1.2.1 chargé ! (Coups directs)",
    ["NEW_RECORD"] = "NOUVEAU RECORD!",
    ["HS_DMG"] = "Record Dégâts : ", ["HS_HEAL"] = "Record Soins : ",
    ["MSG_RESET"] = "Tous les records ont été réinitialisés !",
}

if clientLang == "de" then L = strings_de elseif clientLang == "fr" then L = strings_fr else L = strings_en end

-- ==========================================================
-- DATA
-- ==========================================================
local defaults = { 
    -- Damage
    dmgEnabled = true, dmgSound = "Gong",
    dmgTextEnabled = true, dmgTextColor = {r=1, g=0.2, b=0, a=1},
    dmgFlashEnabled = true, dmgFlashColor = {r=1, g=0.2, b=0, a=1}, dmgFlashAlpha = 0.2,
    -- Heal
    healEnabled = true, healSound = "Bell",
    healTextEnabled = true, healTextColor = {r=0, g=1, b=0.2, a=1},
    healFlashEnabled = true, healFlashColor = {r=0, g=1, b=0.2, a=1}, healFlashAlpha = 0.2,
    -- Highscore Damage
    hsDmgEnabled = true, hsDmgColor = {r=1, g=0.85, b=0, a=1},
    hsDmgFlashEnabled = true, hsDmgFlashAlpha = 0.5, maxDmgRecord = 0,
    -- Highscore Heal
    hsHealEnabled = true, hsHealColor = {r=0.5, g=1, b=0.5, a=1},
    hsHealFlashEnabled = true, hsHealFlashAlpha = 0.5, maxHealRecord = 0
}

local soundLookup = {
    ["Gong"] = SOUNDS.DUEL_START, ["Coins"] = SOUNDS.TELVAR_TRANSACT,
    ["Achievement"] = SOUNDS.ACHIEVEMENT_AWARDED, ["Ultimate"] = SOUNDS.ABILITY_ULTIMATE_READY,
    ["Bell"] = SOUNDS.OBJECTIVE_DISCOVERED,
}
local HS_SOUND = SOUNDS.EMPEROR_CORONATION_IMPERIAL

local displayNames = {
    ["Gong"] = "Gong", ["Coins"] = "Cha-Ching", ["Achievement"] = "Achievement",
    ["Ultimate"] = "Ultimate", ["Bell"] = "Bell",
}
local sortOrder = { "Gong", "Coins", "Achievement", "Ultimate", "Bell" }
local menuChoices = {}
local menuValues = {}
for _, id in ipairs(sortOrder) do table.insert(menuValues, id); table.insert(menuChoices, displayNames[id]) end

-- ==========================================================
-- UI SYSTEM
-- ==========================================================
local function SetupUI()
    -- POPUP
    local tlc = WINDOW_MANAGER:CreateTopLevelWindow("BamCrit_TopLevel")
    tlc:SetClampedToScreen(true) tlc:SetMouseEnabled(false) tlc:SetMovable(false)
    tlc:SetDimensions(300, 100) tlc:SetAnchor(CENTER, GuiRoot, CENTER, 0, -200) tlc:SetHidden(true)

    local label = WINDOW_MANAGER:CreateControl("BamCrit_Label", tlc, CT_LABEL)
    label:SetFont("ZoFontWinH1") label:SetScale(2.5) label:SetAnchor(CENTER, tlc, CENTER, 0, 0) label:SetText("BAM!")
    
    local anim = ANIMATION_MANAGER:CreateTimeline()
    local alpha = anim:InsertAnimation(ANIMATION_ALPHA, tlc)
    alpha:SetAlphaValues(1, 0) alpha:SetDuration(1200) alpha:SetEasingFunction(ZO_EaseInQuadratic)
    local scale = anim:InsertAnimation(ANIMATION_SCALE, label)
    scale:SetScaleValues(0.5, 1.2) scale:SetDuration(200) scale:SetEasingFunction(ZO_EaseOutBack)

    BamLabel = label BamAnim = anim BamTLC = tlc

    -- FLASH
    local flash = WINDOW_MANAGER:CreateTopLevelWindow("BamCrit_FlashTL")
    flash:SetAnchorFill(GuiRoot) flash:SetDrawLayer(DL_BACKGROUND) flash:SetHidden(true)
    local texture = WINDOW_MANAGER:CreateControl("BamCrit_FlashTex", flash, CT_TEXTURE)
    texture:SetAnchorFill(flash) texture:SetColor(1, 1, 1, 1)

    local fAnim = ANIMATION_MANAGER:CreateTimeline()
    local fAlpha = fAnim:InsertAnimation(ANIMATION_ALPHA, flash)
    fAlpha:SetAlphaValues(0.2, 0) fAlpha:SetDuration(350) fAlpha:SetEasingFunction(ZO_EaseOutQuadratic)

    BamFlashControl = flash BamFlashTexture = texture BamFlashAnim = fAnim BamFlashAlphaAnim = fAlpha
end

local function ShowPopup(text, colorTbl)
    if not BamLabel then return end
    BamLabel:SetText(text) BamLabel:SetColor(colorTbl.r, colorTbl.g, colorTbl.b, 1)
    BamTLC:SetHidden(false) BamAnim:PlayFromStart()
end

local function ShowFlash(colorTbl, maxAlpha)
    if not BamFlashControl then return end
    BamFlashTexture:SetColor(colorTbl.r, colorTbl.g, colorTbl.b, 1)
    BamFlashAlphaAnim:SetAlphaValues(maxAlpha, 0)
    BamFlashControl:SetHidden(false) BamFlashAnim:PlayFromStart()
end

-- ==========================================================
-- LOGIC (DIRECT HITS ONLY)
-- ==========================================================

local function OnCritDamage(...)
    local damageAmount = select(11, ...)
    
    -- Highscore Check
    local isNewRecord = false
    if BamCrit.savedVariables.hsDmgEnabled and damageAmount and damageAmount > BamCrit.savedVariables.maxDmgRecord then
        BamCrit.savedVariables.maxDmgRecord = damageAmount
        isNewRecord = true
    end

    if isNewRecord then
        PlaySound(HS_SOUND)
        local text = L["NEW_RECORD"] .. "\n" .. damageAmount
        ShowPopup(text, BamCrit.savedVariables.hsDmgColor)
        if BamCrit.savedVariables.hsDmgFlashEnabled then ShowFlash(BamCrit.savedVariables.hsDmgColor, BamCrit.savedVariables.hsDmgFlashAlpha) end
        return
    end

    -- Normal
    if BamCrit.savedVariables.dmgEnabled and currentDmgSoundId then PlaySound(currentDmgSoundId) end
    if BamCrit.savedVariables.dmgTextEnabled then ShowPopup(GetRandomWord(dmgWords), BamCrit.savedVariables.dmgTextColor) end
    if BamCrit.savedVariables.dmgFlashEnabled then ShowFlash(BamCrit.savedVariables.dmgFlashColor, BamCrit.savedVariables.dmgFlashAlpha) end
end

local function OnCritHeal(...)
    local healAmount = select(11, ...) 
    local overflow = select(18, ...)  
    

    local effectiveHeal = healAmount - (overflow or 0)


    if effectiveHeal <= 0 then return end

    local isNewRecord = false
    if BamCrit.savedVariables.hsHealEnabled and effectiveHeal > BamCrit.savedVariables.maxHealRecord then
        BamCrit.savedVariables.maxHealRecord = effectiveHeal
        isNewRecord = true
    end

    if isNewRecord then
        PlaySound(HS_SOUND)
        local text = L["NEW_RECORD"] .. "\n" .. effectiveHeal
        ShowPopup(text, BamCrit.savedVariables.hsHealColor)
        if BamCrit.savedVariables.hsHealFlashEnabled then 
            ShowFlash(BamCrit.savedVariables.hsHealColor, BamCrit.savedVariables.hsHealFlashAlpha) 
        end
        return
    end

    if BamCrit.savedVariables.healEnabled and currentHealSoundId then PlaySound(currentHealSoundId) end
    if BamCrit.savedVariables.healTextEnabled then ShowPopup(GetRandomWord(healWords), BamCrit.savedVariables.healTextColor) end
    if BamCrit.savedVariables.healFlashEnabled then ShowFlash(BamCrit.savedVariables.healFlashColor, BamCrit.savedVariables.healFlashAlpha) end
end

local function UpdateEventRegistration()
    EM:UnregisterForEvent(BamCrit.name .. "_DMG", EVENT_COMBAT_EVENT)
    EM:UnregisterForEvent(BamCrit.name .. "_HEAL", EVENT_COMBAT_EVENT)

    currentDmgSoundId = soundLookup[BamCrit.savedVariables.dmgSound] or soundLookup[defaults.dmgSound]
    currentHealSoundId = soundLookup[BamCrit.savedVariables.healSound] or soundLookup[defaults.healSound]

    -- DAMAGE (Only Player, Only Direct Critical)
    if BamCrit.savedVariables.dmgEnabled or BamCrit.savedVariables.dmgTextEnabled or BamCrit.savedVariables.dmgFlashEnabled or BamCrit.savedVariables.hsDmgEnabled then
        EM:RegisterForEvent(BamCrit.name .. "_DMG", EVENT_COMBAT_EVENT, OnCritDamage)
        EM:AddFilterForEvent(BamCrit.name .. "_DMG", EVENT_COMBAT_EVENT, 
            FILT_UNIT, UNIT_PLAYER, 
            FILT_RES, RES_CRIT_DMG) 
    end

    -- HEAL (Only Player, Only Direct Critical)
    if BamCrit.savedVariables.healEnabled or BamCrit.savedVariables.healTextEnabled or BamCrit.savedVariables.healFlashEnabled or BamCrit.savedVariables.hsHealEnabled then
        EM:RegisterForEvent(BamCrit.name .. "_HEAL", EVENT_COMBAT_EVENT, OnCritHeal)
        EM:AddFilterForEvent(BamCrit.name .. "_HEAL", EVENT_COMBAT_EVENT, 
            FILT_UNIT, UNIT_PLAYER, 
            FILT_RES, RES_CRIT_HEAL)
    end
end

-- ==========================================================
-- MENU
-- ==========================================================
local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end
    local panelData = { type = "panel", name = "BamCrit", displayName = L["MENU_NAME"], author = "Fadosch", version = "1.2.1" }
    LAM:RegisterAddonPanel("BamCritOptions", panelData)
    LAM:RegisterOptionControls("BamCritOptions", {
        -- HIGHSCORES
        { type = "header", name = L["HS_DMG_HEADER"] },
        { type = "checkbox", name = L["ENABLE_HS"], getFunc = function() return BamCrit.savedVariables.hsDmgEnabled end, setFunc = function(v) BamCrit.savedVariables.hsDmgEnabled = v; UpdateEventRegistration() end },
        { type = "checkbox", name = L["ENABLE_FLASH_HS"], getFunc = function() return BamCrit.savedVariables.hsDmgFlashEnabled end, setFunc = function(v) BamCrit.savedVariables.hsDmgFlashEnabled = v end },
        { type = "colorpicker", name = L["COL_HS"], getFunc = function() return BamCrit.savedVariables.hsDmgColor.r, BamCrit.savedVariables.hsDmgColor.g, BamCrit.savedVariables.hsDmgColor.b, BamCrit.savedVariables.hsDmgColor.a end, setFunc = function(r,g,b,a) BamCrit.savedVariables.hsDmgColor = {r=r, g=g, b=b, a=a} end, disabled = function() return not BamCrit.savedVariables.hsDmgEnabled end },
        { type = "slider", name = L["BRIGHTNESS"], min = 0.1, max = 1.0, step = 0.05, decimals = 2, getFunc = function() return BamCrit.savedVariables.hsDmgFlashAlpha end, setFunc = function(v) BamCrit.savedVariables.hsDmgFlashAlpha = v end, disabled = function() return not BamCrit.savedVariables.hsDmgFlashEnabled end },
        { type = "button", name = L["BTN_RESET"], func = function() BamCrit.savedVariables.maxDmgRecord = 0; d("BamCrit: Damage Highscore reset!") end },

        { type = "header", name = L["HS_HEAL_HEADER"] },
        { type = "checkbox", name = L["ENABLE_HS"], getFunc = function() return BamCrit.savedVariables.hsHealEnabled end, setFunc = function(v) BamCrit.savedVariables.hsHealEnabled = v; UpdateEventRegistration() end },
        { type = "checkbox", name = L["ENABLE_FLASH_HS"], getFunc = function() return BamCrit.savedVariables.hsHealFlashEnabled end, setFunc = function(v) BamCrit.savedVariables.hsHealFlashEnabled = v end },
        { type = "colorpicker", name = L["COL_HS"], getFunc = function() return BamCrit.savedVariables.hsHealColor.r, BamCrit.savedVariables.hsHealColor.g, BamCrit.savedVariables.hsHealColor.b, BamCrit.savedVariables.hsHealColor.a end, setFunc = function(r,g,b,a) BamCrit.savedVariables.hsHealColor = {r=r, g=g, b=b, a=a} end, disabled = function() return not BamCrit.savedVariables.hsHealEnabled end },
        { type = "slider", name = L["BRIGHTNESS"], min = 0.1, max = 1.0, step = 0.05, decimals = 2, getFunc = function() return BamCrit.savedVariables.hsHealFlashAlpha end, setFunc = function(v) BamCrit.savedVariables.hsHealFlashAlpha = v end, disabled = function() return not BamCrit.savedVariables.hsHealFlashEnabled end },
        { type = "button", name = L["BTN_RESET"], func = function() BamCrit.savedVariables.maxHealRecord = 0; d("BamCrit: Healing Highscore reset!") end },

        -- NORMAL SETTINGS
        { type = "header", name = L["DMG_HEADER"] },
        { type = "checkbox", name = L["ENABLE_DMG"], getFunc = function() return BamCrit.savedVariables.dmgEnabled end, setFunc = function(v) BamCrit.savedVariables.dmgEnabled = v; UpdateEventRegistration() end },
        { type = "dropdown", name = L["DD_DMG_NAME"], choices = menuChoices, choicesValues = menuValues, getFunc = function() return BamCrit.savedVariables.dmgSound end, setFunc = function(v) BamCrit.savedVariables.dmgSound = v; UpdateEventRegistration(); if currentDmgSoundId then PlaySound(currentDmgSoundId) end end, disabled = function() return not BamCrit.savedVariables.dmgEnabled end },
        { type = "checkbox", name = L["ENABLE_TEXT_DMG"], getFunc = function() return BamCrit.savedVariables.dmgTextEnabled end, setFunc = function(v) BamCrit.savedVariables.dmgTextEnabled = v; UpdateEventRegistration() end },
        { type = "colorpicker", name = L["COL_TEXT"], getFunc = function() return BamCrit.savedVariables.dmgTextColor.r, BamCrit.savedVariables.dmgTextColor.g, BamCrit.savedVariables.dmgTextColor.b, BamCrit.savedVariables.dmgTextColor.a end, setFunc = function(r,g,b,a) BamCrit.savedVariables.dmgTextColor = {r=r, g=g, b=b, a=a} end, disabled = function() return not BamCrit.savedVariables.dmgTextEnabled end },
        { type = "checkbox", name = L["ENABLE_FLASH_DMG"], getFunc = function() return BamCrit.savedVariables.dmgFlashEnabled end, setFunc = function(v) BamCrit.savedVariables.dmgFlashEnabled = v; UpdateEventRegistration() end },
        { type = "colorpicker", name = L["COL_FLASH"], getFunc = function() return BamCrit.savedVariables.dmgFlashColor.r, BamCrit.savedVariables.dmgFlashColor.g, BamCrit.savedVariables.dmgFlashColor.b, BamCrit.savedVariables.dmgFlashColor.a end, setFunc = function(r,g,b,a) BamCrit.savedVariables.dmgFlashColor = {r=r, g=g, b=b, a=a} end, disabled = function() return not BamCrit.savedVariables.dmgFlashEnabled end },
        { type = "slider", name = L["BRIGHTNESS"], min = 0.1, max = 1.0, step = 0.05, decimals = 2, getFunc = function() return BamCrit.savedVariables.dmgFlashAlpha end, setFunc = function(v) BamCrit.savedVariables.dmgFlashAlpha = v end, disabled = function() return not BamCrit.savedVariables.dmgFlashEnabled end },
        { type = "button", name = L["BTN_TEST_DMG"], func = function() if currentDmgSoundId then PlaySound(currentDmgSoundId) end ShowPopup("TEST BAM!", BamCrit.savedVariables.dmgTextColor) ShowFlash(BamCrit.savedVariables.dmgFlashColor, BamCrit.savedVariables.dmgFlashAlpha) end },
        
        { type = "header", name = L["HEAL_HEADER"] },
        { type = "checkbox", name = L["ENABLE_HEAL"], getFunc = function() return BamCrit.savedVariables.healEnabled end, setFunc = function(v) BamCrit.savedVariables.healEnabled = v; UpdateEventRegistration() end },
        { type = "dropdown", name = L["DD_HEAL_NAME"], choices = menuChoices, choicesValues = menuValues, getFunc = function() return BamCrit.savedVariables.healSound end, setFunc = function(v) BamCrit.savedVariables.healSound = v; UpdateEventRegistration(); if currentHealSoundId then PlaySound(currentHealSoundId) end end, disabled = function() return not BamCrit.savedVariables.healEnabled end },
        { type = "checkbox", name = L["ENABLE_TEXT_HEAL"], getFunc = function() return BamCrit.savedVariables.healTextEnabled end, setFunc = function(v) BamCrit.savedVariables.healTextEnabled = v; UpdateEventRegistration() end },
        { type = "colorpicker", name = L["COL_TEXT"], getFunc = function() return BamCrit.savedVariables.healTextColor.r, BamCrit.savedVariables.healTextColor.g, BamCrit.savedVariables.healTextColor.b, BamCrit.savedVariables.healTextColor.a end, setFunc = function(r,g,b,a) BamCrit.savedVariables.healTextColor = {r=r, g=g, b=b, a=a} end, disabled = function() return not BamCrit.savedVariables.healTextEnabled end },
        { type = "checkbox", name = L["ENABLE_FLASH_HEAL"], getFunc = function() return BamCrit.savedVariables.healFlashEnabled end, setFunc = function(v) BamCrit.savedVariables.healFlashEnabled = v; UpdateEventRegistration() end },
        { type = "colorpicker", name = L["COL_FLASH"], getFunc = function() return BamCrit.savedVariables.healFlashColor.r, BamCrit.savedVariables.healFlashColor.g, BamCrit.savedVariables.healFlashColor.b, BamCrit.savedVariables.healFlashColor.a end, setFunc = function(r,g,b,a) BamCrit.savedVariables.healFlashColor = {r=r, g=g, b=b, a=a} end, disabled = function() return not BamCrit.savedVariables.healFlashEnabled end },
        { type = "slider", name = L["BRIGHTNESS"], min = 0.1, max = 1.0, step = 0.05, decimals = 2, getFunc = function() return BamCrit.savedVariables.healFlashAlpha end, setFunc = function(v) BamCrit.savedVariables.healFlashAlpha = v end, disabled = function() return not BamCrit.savedVariables.healFlashEnabled end },
        { type = "button", name = L["BTN_TEST_HEAL"], func = function() if currentHealSoundId then PlaySound(currentHealSoundId) end ShowPopup("TEST LIFE!", BamCrit.savedVariables.healTextColor) ShowFlash(BamCrit.savedVariables.healFlashColor, BamCrit.savedVariables.healFlashAlpha) end },
    })
end

-- ==========================================================
-- INIT
-- ==========================================================
function BamCrit.OnAddOnLoaded(_, addonName)
    if addonName ~= BamCrit.name then return end
    EM:UnregisterForEvent(BamCrit.name, EVENT_ADD_ON_LOADED)
    
    BamCrit.savedVariables = ZO_SavedVars:NewAccountWide("BamCritVars", 1, nil, defaults, GetWorldName())
    
    SetupUI() 
    CreateSettingsMenu()
    UpdateEventRegistration() 
    
    SLASH_COMMANDS[BamCrit.cmd_show] = function()
        d("|cFFFF00" .. L["HS_DMG"] .. BamCrit.savedVariables.maxDmgRecord .. "|r")
        d("|c00FF00" .. L["HS_HEAL"] .. BamCrit.savedVariables.maxHealRecord .. "|r")
    end

    SLASH_COMMANDS[BamCrit.cmd_reset] = function()
        BamCrit.savedVariables.maxDmgRecord = 0
        BamCrit.savedVariables.maxHealRecord = 0
        d("|cFF0000[BamCrit]|r " .. L["MSG_RESET"])
    end

    d(L["LOADED_MSG"])
end

EM:RegisterForEvent(BamCrit.name, EVENT_ADD_ON_LOADED, BamCrit.OnAddOnLoaded)