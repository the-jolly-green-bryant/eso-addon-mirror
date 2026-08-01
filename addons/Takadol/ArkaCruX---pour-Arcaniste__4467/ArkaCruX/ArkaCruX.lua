-- =============================================================================
-- ArkaCruX --
-- =============================================================================

ArkaCruX = ArkaCruX or {}
local AC = ArkaCruX

AC.name = "ArkaCruX"
AC.version = "1.6"
AC.abilityId = 184220 -- Crux Tracker Ability ID
local EM = EVENT_MANAGER

-- Modules
AC.Debug = {}
AC.Language = {}
AC.Settings = {}
AC.UI = {}
AC.Events = {}
AC.State = {
    stacks = 0,
    maxStacks = 3,
    inCombat = false,
}
AC.isInitialized = false

-- -----------------------------------------------------------------------------
-- Debug
-- -----------------------------------------------------------------------------
AC.Debug.level = 0

function AC.Debug:Say(...)
    local prefix = "[" .. AC.name .. "] "
    d(prefix .. zo_strformat(...))
end

function AC.Debug:Trace(level, ...)
    if level <= self.level then
        self:Say(...)
    end
end

-- -----------------------------------------------------------------------------
-- Langues
-- -----------------------------------------------------------------------------
ArkaCruX_LanguageData = ArkaCruX_LanguageData or {} -- Sécurité : empêche le crash si les fichiers de langue sont absents
AC.Language.translationPrefix = "CRUX_COUNTER_"

function AC.Language:GetString(shortName, contextId)
    local key = self.translationPrefix .. shortName
    if _G[key] then
        return GetString(_G[key], contextId or 0)
    else
        return shortName
    end
end

function AC.Language:Apply(langCode)
    local data = ArkaCruX_LanguageData[langCode]
    if not data then 
        -- Fallback to English if specified language is missing
        data = ArkaCruX_LanguageData["en"]
        if not data then return end
    end
    
    for key, value in pairs(data) do
        ZO_CreateStringId(key, value)
        SafeAddVersion(key, 1)
    end
end

function AC.Language:Setup()
    local lang = AC.Settings:Get("language")
    if not lang or lang == "" then
        lang = GetCVar("language.2")
    end

    if not ArkaCruX_LanguageData[lang] then
        AC.Debug:Trace(1, "Translation for '<<1>>' not found. Falling back to English.", lang)
        lang = "en"
    end

    self:Apply(lang)
end

-- -----------------------------------------------------------------------------
-- Menu
-- -----------------------------------------------------------------------------
-- Définition des sons disponibles pour le menu
local gameSounds = {
    ["SOUND_NONE"] = SOUNDS.NONE,
    ["SOUND_TIMER_ALERT_DEFAULT"] = SOUNDS.BATTLEGROUND_COUNTDOWN_FINISH,
    ["SOUND_MAX_CRUX_DEFAULT"] = SOUNDS.DEATH_RECAP_KILLING_BLOW_SHOWN,
    ["SOUND_QUEST_TIMER"] = SOUNDS.UI_QUEST_TIMER_WARNING,
    ["SOUND_ABILITY_READY"] = SOUNDS.ABILITY_ULTIMATE_READY,
    ["SOUND_LEVEL_UP"] = SOUNDS.LEVEL_UP,
    ["SOUND_QUEST_OBJECTIVE"] = SOUNDS.QUEST_OBJECTIVE_COMPLETE,
    ["SOUND_GLYPH_PLACED"] = SOUNDS.ENCHANTING_POTENCY_RUNE_PLACED,
    ["SOUND_GLYPH_REMOVED"] = SOUNDS.ENCHANTING_WEAPON_GLYPH_REMOVED,
    ["SOUND_POTION_DRINK"] = SOUNDS.POTION_DRINK,
    ["SOUND_POISON_USE"] = SOUNDS.POISON_USE,
    ["SOUND_ACHIEVEMENT"] = SOUNDS.ACHIEVEMENT_UNLOCKED,
    ["SOUND_LOCATION_DISCOVERED"] = SOUNDS.LOCATION_DISCOVERED,
    ["SOUND_LOREBOOK"] = SOUNDS.LOREBOOK_COLLECTED,
    ["SOUND_GROUP_INVITE"] = SOUNDS.GROUP_INVITE_RECEIVED,
    ["SOUND_WHISPER"] = SOUNDS.CHAT_WHISPER_RECEIVED,
    ["SOUND_NOTIFICATION"] = SOUNDS.NOTIFICATION_RECEIVED,
    ["SOUND_MENU_CLICK"] = SOUNDS.MENU_CLICK,
    ["SOUND_ERROR"] = SOUNDS.GENERAL_ERROR,
    ["SOUND_PARRY"] = SOUNDS.PARRY,
    ["SOUND_BLOCK"] = SOUNDS.BLOCK,
    ["SOUND_DODGE"] = SOUNDS.DODGE,
    ["SOUND_CRITICAL_STRIKE"] = SOUNDS.CRITICAL_STRIKE,
    ["SOUND_DEATH"] = SOUNDS.PLAYER_DEATH,
    ["SOUND_REVIVED"] = SOUNDS.PLAYER_REVIVED,
    ["SOUND_MOUNT"] = SOUNDS.MOUNT_RIDE,
    ["SOUND_REPAIR"] = SOUNDS.REPAIR_ITEM,
    ["SOUND_DECONSTRUCT"] = SOUNDS.DECONSTRUCT_ITEM,
    ["SOUND_CRAFTING_COMPLETE"] = SOUNDS.CRAFTING_COMPLETE
}
local sounds = {} -- Noms traduits pour l'affichage
local soundValues = {} -- Clés non traduites pour la sauvegarde
local rotationSpeedFactor = 24000
local rotationDirectionChoices = {}
local rotationDirectionValues = { "CCW", "CW" }

-- Couleurs
local veryLightGreen = ZO_ColorDef:New(0.7176470588, 1, 0.7764705882, 1)
local lightGreen     = ZO_ColorDef:New(0.7176470588, 1, 0.4862745098, 1)
local mediumGreen    = ZO_ColorDef:New(0.6784313725, 0.9607843137, 0.4509803921, 1)
local alertRed       = ZO_ColorDef:New(1, 0.2, 0.2, 1)
local baseColor      = ZO_ColorDef:New(1, 1, 1, 1) -- Le fameux "blanc de base" (R, V, B, A)

AC.Settings.settings = {}
AC.Settings.dbVersion = 1
AC.Settings.savedVariables = "ArkaCruXData"
AC.Settings.defaults = {
    useAccountSettings = true,
    hiddenForCharacter = false,
    language        = "",
    top             = 0,
    left            = 0,
    hideOutOfCombat = false,
    locked          = false,
    lockToReticle   = false,
    size            = 128,
    elements        = {
        runes      = {
            enabled       = true,
            rotate        = true,
            rotationSpeed = 9600,
            rotationDirection = "CCW",
            keepUpright   = true,
            useUniqueColors = false,
            useColor1     = true,
            color1        = lightGreen,
            useColor2     = true,
            color2        = mediumGreen,
            useColor3     = true,
            color3        = veryLightGreen,
            runeTexture   = "art/fx/texture/arcanist_trianglerune_01.dds",
            runeOpacity   = 1,
        },
    },
    timer = {
        enabled = true,
        size = 48,
        color = veryLightGreen,
        fontFace = "$(BOLD_FONT)",
        alertColor = alertRed,
    },
    sounds          = {
        maxCrux    = {
            enabled = true,
            name    = "SOUND_MAX_CRUX_DEFAULT",
            volume  = 100,
        },
        timerAlert = {
            enabled = true,
            name    = "SOUND_TIMER_ALERT_DEFAULT",
            volume  = 100,
        },
    },
}

function AC.Settings:SavePosition(top, left)
    AC.Debug:Trace(2, "Saving position <<1>> x <<2>>", top, left)
    self.settings.top = top
    self.settings.left = left
end

function AC.Settings:GetSoundForType(type)
    local sound = self.settings.sounds[type].name
    local volume = self.settings.sounds[type].volume
    return sound, volume
end

-- Helpers pour les réglages
local optionsData = {}
ArkaCruX_LockButton = nil
ArkaCruX_MoveToCenterButton = nil

local onPlayerChanged -- Déclaration anticipée pour qu'elle soit visible par previewWidget
local OnUpdate        -- Déclaration anticipée pour qu'elle soit visible par previewWidget

local function moveToCenter()
    ArkaCruX_Display:Unhide()
    ArkaCruX_Display:MoveToCenter()
    AC.Settings:SavePosition(0, 0)
end

local function setLocked(isLocked)
    AC.Settings.settings.locked = isLocked
    ArkaCruX_Display:SetMovable(not isLocked)
end

local function getLocked() return AC.Settings.settings.locked end
local function getLockToReticle() return AC.Settings.settings.lockToReticle end

local function getLockUnlockButtonText()
    if getLocked() or getLockToReticle() then
        return AC.Language:GetString("SETTINGS_UNLOCK")
    else
        return AC.Language:GetString("SETTINGS_LOCK")
    end
end

local function getLockUnlockTooltipText()
    if getLockToReticle() then
        return AC.Language:GetString("SETTINGS_LOCK_TO_RETICLE_WARNING")
    else
        return AC.Language:GetString("SETTINGS_LOCK_DESC")
    end
end

local function getMoveToCenterTooltipText()
    if getLockToReticle() then
        return AC.Language:GetString("SETTINGS_LOCK_TO_RETICLE_WARNING")
    else
        return AC.Language:GetString("SETTINGS_MOVE_TO_CENTER_DESC")
    end
end

local function previewWidget()
    if not ArkaCruX_Display then return end
    ArkaCruX_Display:StartPreview()
end

local function toggleLocked(control)
    setLocked(not getLocked())
    if control then
        control:SetText(getLockUnlockButtonText())
    elseif ArkaCruX_LockButton and ArkaCruX_LockButton.button then
        ArkaCruX_LockButton.button:SetText(getLockUnlockButtonText())
    end
end

-- Fonctions globales pour les raccourcis clavier (Bindings)
function ArkaCruX_ToggleLock()
    toggleLocked()
end

function ArkaCruX_ResetPosition()
    moveToCenter()
end

local function setLockToReticle(state)
    local lam = LibAddonMenu2 -- Récupération dynamique pour éviter les variables vides
    if state then
        moveToCenter()
    else
        ArkaCruX_Display:SetPosition(AC.Settings.settings.top, AC.Settings.settings.left)
    end
    setLocked(state)
    AC.Settings.settings.lockToReticle = state

    if ArkaCruX_LockButton and ArkaCruX_LockButton.button and lam then
        ArkaCruX_LockButton.button.data = { tooltipText = lam.util.GetStringFromValue(getLockUnlockTooltipText()) }
        ArkaCruX_LockButton.button:SetText(getLockUnlockButtonText())
    end
    if ArkaCruX_MoveToCenterButton and ArkaCruX_MoveToCenterButton.button and lam then
        ArkaCruX_MoveToCenterButton.button.data = { tooltipText = lam.util.GetStringFromValue(getMoveToCenterTooltipText()) }
    end
end

local function setHideOutOfCombat(hide)
    AC.Settings.settings.hideOutOfCombat = hide
    if hide then
        AC.Events:RegisterForCombat()
    else
        AC.Events:UnregisterForCombat()
    end
end

local function getHideOutOfCombat() return AC.Settings.settings.hideOutOfCombat end

local function setSize(value)
    AC.Settings.settings.size = value
    ArkaCruX_Display:SetSize(value)
end

local function getSize() return AC.Settings.settings.size end

local function setElementEnabled(element, enabled)    
    if element == "runes" and ArkaCruX_Display and ArkaCruX_Display.rota then
        ArkaCruX_Display.rota:SetEnabled(enabled)
        local el = AC.Settings:GetElement("runes")
        if el then ArkaCruX_Display.rota:SetRotationEnabled(el.rotate) end
    end    
    if AC.Settings.settings.elements and AC.Settings.settings.elements[element] then
        AC.Settings.settings.elements[element].enabled = enabled
    end
end

local function getElementEnabled(element)
    -- Protection contre le crash (Error 331) : si la sauvegarde est vide, on renvoie faux par défaut
    local el = AC.Settings:GetElement(element)
    return el and el.enabled or false
end

local function setElementRotate(element, rotate)
    if element == "runes" and ArkaCruX_Display and ArkaCruX_Display.rota then
        ArkaCruX_Display.rota:SetRotationEnabled(rotate)
    end
    if AC.Settings.settings.elements and AC.Settings.settings.elements[element] then
        AC.Settings.settings.elements[element].rotate = rotate
    end
end

local function getElementRotate(element)
    local el = AC.Settings:GetElement(element)
    return el and el.rotate or false
end

local function getKeepUpright()
    local el = AC.Settings:GetElement("runes")
    return el and el.keepUpright
end

local function setKeepUpright(value)
    if AC.Settings.settings.elements.runes then AC.Settings.settings.elements.runes.keepUpright = value end
    if ArkaCruX_Display and ArkaCruX_Display.rota then ArkaCruX_Display.rota:SetKeepUpright(value) end
end

--[[ Fonctions d'activation des couleurs ]]--
local function getRuneColorEnabled(stack)
    local runes = AC.Settings:GetElement("runes")
    return runes and runes["useColor" .. stack] or false
end

local function setRuneColorEnabled(stack, enabled)
    local runes = AC.Settings:GetElement("runes")
    if runes then runes["useColor" .. stack] = enabled end
    if ArkaCruX_Display then ArkaCruX_Display:ApplySettings() end
end

--[[ Fonctions de couleur des runes ]]--
local function getUseUniqueRuneColors()
    local runes = AC.Settings:GetElement("runes")
    return runes and runes.useUniqueColors or false
end

local function setUseUniqueRuneColors(useUnique)
    local runes = AC.Settings:GetElement("runes")
    if runes then runes.useUniqueColors = useUnique end
    if ArkaCruX_Display then ArkaCruX_Display:ApplySettings() end
end

local function getRuneColor(stack)
    local runes = AC.Settings:GetElement("runes")
    if not runes then return baseColor end
    local colorKey = "color" .. stack
    if runes[colorKey] then return ZO_ColorDef:New(runes[colorKey]) end
    return baseColor
end

local function setRuneColor(stack, color)
    local r, g, b, a = color:UnpackRGBA()
    local runes = AC.Settings:GetElement("runes")
    if runes then
        local colorKey = "color" .. stack
        runes[colorKey] = { r=r, g=g, b=b, a=a }
    end
    if ArkaCruX_Display then ArkaCruX_Display:ApplySettings() end
end

local function getDefaultRuneColor(stack)
    local colorKey = "color" .. stack
    return AC.Settings.defaults.elements.runes[colorKey]
end

local function resetRuneColor(stack)
    setRuneColor(stack, getDefaultRuneColor(stack))
end

-- =============================================================================
-- CONFIGURATION DES TEXTURES DE RUNES (Liste Déroulante)
-- =============================================================================

-- Ces tables seront remplies avec les traductions dans Settings:Setup
local runeTextureChoices = {}
local runeTextureValues = {}

local function getRuneTexture()
    return AC.Settings.settings.elements.runes.runeTexture
end

local function areRuneColorSettingsDisabled()
    if not getElementEnabled("runes") then return true end

    local currentTexture = getRuneTexture()
    if not currentTexture then return false end

    local lowerTexture = string.lower(currentTexture)
    -- Désactiver les options de couleur pour les textures spécifiques (Drapeaux)
    if string.find(lowerTexture, "/fr.dds", 1, true) or
        string.find(lowerTexture, "/de.dds", 1, true) or
        string.find(lowerTexture, "/ru.dds", 1, true) or
        string.find(lowerTexture, "/es.dds", 1, true) or
        string.find(lowerTexture, "/en.dds", 1, true) then
        return true
    end

    return false
end

local function setRuneTexture(path)
    AC.Settings.settings.elements.runes.runeTexture = path
    if ArkaCruX_Display and ArkaCruX_Display.rota then
        ArkaCruX_Display.rota:SetRuneTexture(path)
    end

    if areRuneColorSettingsDisabled() and getUseUniqueRuneColors() then
        setUseUniqueRuneColors(false)
    end

    local lam = LibAddonMenu2
    if lam and lam.RefreshAddonPanel then
        lam:RefreshAddonPanel(AC.name)
    end
end

local function getRuneOpacity()
    return (AC.Settings.settings.elements.runes.runeOpacity or 1) * 100
end

local function setRuneOpacity(value)
    local opacity = value / 100
    AC.Settings.settings.elements.runes.runeOpacity = opacity
    if ArkaCruX_Display and ArkaCruX_Display.rota then
        ArkaCruX_Display.rota:SetRuneOpacity(opacity)
    end
end

--[ Fonctions du minuteur ]--
local function getTimerEnabled()
    return AC.Settings.settings.timer and AC.Settings.settings.timer.enabled or false
end

local function setTimerEnabled(enabled)
    if AC.Settings.settings.timer then AC.Settings.settings.timer.enabled = enabled end
    if ArkaCruX_Display then ArkaCruX_Display:SetTimerEnabled(enabled) end
end

local function getTimerSize()
    return AC.Settings.settings.timer and AC.Settings.settings.timer.size or 48
end

local function setTimerSize(size)
    if AC.Settings.settings.timer then AC.Settings.settings.timer.size = size end
    if ArkaCruX_Display then ArkaCruX_Display:SetTimerSize(size) end
end

local function getTimerColor()
    if not AC.Settings.settings then return ZO_ColorDef:New(1, 1, 1, 1) end -- Fallback
    local timer = AC.Settings.settings.timer
    if timer and timer.color then return ZO_ColorDef:New(timer.color) end
    return ZO_ColorDef:New(1, 1, 1, 1)
end

local function setTimerColor(color)
    local r, g, b, a = color:UnpackRGBA()
    if AC.Settings.settings.timer then AC.Settings.settings.timer.color = {r=r, g=g, b=b, a=a} end
    if ArkaCruX_Display then ArkaCruX_Display:SetTimerColor(color) end
end

local fontStyles = {} -- Sera rempli dans Settings:Setup
local fontStyleValues = { "$(MEDIUM_FONT)", "$(BOLD_FONT)", "$(ANTIQUE_FONT)", "$(HANDWRITTEN_FONT)", "$(GAMEPAD_BOLD_FONT)" }

local function getTimerFontFace()
    return AC.Settings.settings.timer and AC.Settings.settings.timer.fontFace or "$(BOLD_FONT)"
end

local function setTimerFontFace(font)
    if AC.Settings.settings.timer then 
        AC.Settings.settings.timer.fontFace = font 
    end
    if ArkaCruX_Display then ArkaCruX_Display:UpdateTimerFont() end
end

local function getTimerAlertColor()
    if not AC.Settings.settings then return ZO_ColorDef:New(1, 0.2, 0.2, 1) end -- Fallback
    local timer = AC.Settings.settings.timer
    if timer and timer.alertColor then return ZO_ColorDef:New(timer.alertColor) end
    return ZO_ColorDef:New(1, 0.2, 0.2, 1)
end

local function setTimerAlertColor(color)
    local r, g, b, a = color:UnpackRGBA()
    if AC.Settings.settings.timer then AC.Settings.settings.timer.alertColor = {r=r, g=g, b=b, a=a} end
end

local function getRotationSpeed()
    local speed = AC.Settings.settings.elements.runes.rotationSpeed
    local inverted = rotationSpeedFactor - speed
    local percent = inverted / rotationSpeedFactor
    return percent * 100
end

local function setRotationSpeed(value)
    local percent = value / 100
    local speed = rotationSpeedFactor - (rotationSpeedFactor * percent)
    AC.Settings.settings.elements.runes.rotationSpeed = speed
    if ArkaCruX_Display and ArkaCruX_Display.rota then
        ArkaCruX_Display.rota:SetRotationDuration(speed)
    end
end

local function setRotationDirection(value)
    AC.Settings.settings.elements.runes.rotationDirection = value
    if ArkaCruX_Display and ArkaCruX_Display.rota then
        ArkaCruX_Display.rota:SetRotationDirection(value)
    end
end

local function setSoundEnabled(type, enabled) if AC.Settings.settings.sounds[type] then AC.Settings.settings.sounds[type].enabled = enabled end end
local function getSound(type) return AC.Settings.settings.sounds[type] and AC.Settings.settings.sounds[type].name end
local function setSound(type, soundName) if AC.Settings.settings.sounds[type] then AC.Settings.settings.sounds[type].name = soundName end end
local function getVolume(type) return AC.Settings.settings.sounds[type] and AC.Settings.settings.sounds[type].volume end
local function setVolume(type, volume) if AC.Settings.settings.sounds[type] then AC.Settings.settings.sounds[type].volume = volume end end

local function getResetTooltip()
    if AC.Settings.characterVars.useAccountSettings then
        return AC.Language:GetString("SETTINGS_RESET_ALL_DESC_ACCOUNT")
    else
        return AC.Language:GetString("SETTINGS_RESET_ALL_DESC_CHAR")
    end
end

local function resetAllSettings()
    if not ZO_Dialogs_IsDialogRegistered("ARKACRUX_RESET_CONFIRM") then
        ZO_Dialogs_RegisterCustomDialog("ARKACRUX_RESET_CONFIRM", {
            title = { text = AC.Language:GetString("SETTINGS_RESET_CONFIRM_TITLE") },
            mainText = { text = function() 
                if AC.Settings.characterVars.useAccountSettings then
                    return AC.Language:GetString("SETTINGS_RESET_CONFIRM_TEXT_ACCOUNT")
                else
                    return AC.Language:GetString("SETTINGS_RESET_CONFIRM_TEXT_CHAR")
                end
            end },
            buttons = {
                {
                    text = SI_DIALOG_CONFIRM,
                    callback = function()
                        local isAccount = AC.Settings.characterVars.useAccountSettings
                        ZO_ClearTable(AC.Settings.settings)
                        -- Si on était en mode "Personnage", on force le maintien de ce mode après le reset
                        if not isAccount then AC.Settings.characterVars.useAccountSettings = false end
                        ReloadUI()
                    end,
                },
                { text = SI_DIALOG_CANCEL }
            }
        })
    end
    ZO_Dialogs_ShowDialog("ARKACRUX_RESET_CONFIRM")
end

-- Tables d'options
local displayOptions = {
    { type = "header", name = function() return AC.Language:GetString("SETTINGS_SAVE_HEADER") end, width = "full" },
    { type = "dropdown", name = "Langue / Language", 
        choices = {"fr", "en", "de", "es", "ru"},
        getFunc = function()
            local val = AC.Settings:Get("language") 
            return (val == "" and GetCVar("language.2")) or val 
        end,
        setFunc = function(value) AC.Settings:Get()["language"] = value; AC.Language:Setup(); populateSounds(); populateDropdowns(); ReloadUI() end,
        width = "full", warning = "Reload UI" },
    { type = "checkbox", name = function() return AC.Language:GetString("SETTINGS_USE_ACCOUNT_WIDE") end, 

        tooltip = function() return AC.Language:GetString("SETTINGS_USE_ACCOUNT_WIDE_DESC") end,
        getFunc = function() return AC.Settings.characterVars.useAccountSettings end,
        setFunc = function(value) 
            AC.Settings.characterVars.useAccountSettings = value 
            AC.Settings:UpdateSettingsSource()
            ArkaCruX_Display:ApplySettings()
        end, 
        width = "full" 
    },
    { type = "checkbox", name = function() return AC.Language:GetString("SETTINGS_HIDE_ON_CHAR") end, 
        tooltip = function() return AC.Language:GetString("SETTINGS_HIDE_ON_CHAR_DESC") end, 
        getFunc = function() return AC.Settings.characterVars.hiddenForCharacter end, 
        setFunc = function(value) AC.Settings.characterVars.hiddenForCharacter = value; ArkaCruX_Display:UpdateVisibility() end, width = "full" 
    },
    { type = "header", name = function() return AC.Language:GetString("SETTINGS_DISPLAY_HEADER") end, width = "full" },
    { type = "button", name = function() return AC.Language:GetString("SETTINGS_SHOW_TO_MOVE") end, tooltip = function() return AC.Language:GetString("SETTINGS_SHOW_TO_MOVE_DESC") end, func = previewWidget, width = "full" },
    { type = "button", name = getLockUnlockButtonText, tooltip = getLockUnlockTooltipText, disabled = getLockToReticle, func = toggleLocked, width = "half", reference = "ArkaCruX_LockButton" },
    { type = "button", name = function() return AC.Language:GetString("SETTINGS_MOVE_TO_CENTER") end, tooltip = getMoveToCenterTooltipText, disabled = getLockToReticle, func = moveToCenter, width = "half", reference = "ArkaCruX_MoveToCenterButton" },
    { type = "checkbox", name = function() return AC.Language:GetString("SETTINGS_LOCK_TO_RETICLE") end, tooltip = function() return AC.Language:GetString("SETTINGS_LOCK_TO_RETICLE_DESC") end, getFunc = getLockToReticle, setFunc = setLockToReticle, width = "full" },
    { type = "checkbox", name = function() return AC.Language:GetString("SETTINGS_HIDE_OUT_OF_COMBAT") end, tooltip = function() return AC.Language:GetString("SETTINGS_HIDE_OUT_OF_COMBAT_DESC") end, getFunc = getHideOutOfCombat, setFunc = setHideOutOfCombat, width = "full" },
    { type = "slider", name = function() return AC.Language:GetString("SETTINGS_SIZE") end, tooltip = function() return AC.Language:GetString("SETTINGS_SIZE_DESC") end, min = 16, max = 512, step = 16, default = AC.Settings.defaults.size, getFunc = getSize, setFunc = setSize, width = "full" },
    { type = "button", name = function() return AC.Language:GetString("SETTINGS_RESET_ALL") end, tooltip = getResetTooltip, func = resetAllSettings, width = "full", warning = function() return AC.Language:GetString("SETTINGS_RESET_ALL_WARNING") end },
}

local styleOptions = {
    { type = "header", name = function() return AC.Language:GetString("SETTINGS_STYLE_HEADER") end, width = "full" },
    -- Minuteur
    { type = "checkbox", name = function() return AC.Language:GetString("SETTINGS_STYLE_TIMER_SHOW") end, getFunc = getTimerEnabled, setFunc = setTimerEnabled, width = "full" },
    { type = "slider", name = function() return AC.Language:GetString("SETTINGS_STYLE_TIMER_SIZE") end, min = 12, max = 40, step = 2, getFunc = getTimerSize, setFunc = setTimerSize, disabled = function() return not getTimerEnabled() end, width = "half" },
    { type = "colorpicker", name = function() return AC.Language:GetString("SETTINGS_STYLE_TIMER_COLOR") end, getFunc = function() return getTimerColor():UnpackRGBA() end, setFunc = function(r,g,b,a) setTimerColor(ZO_ColorDef:New(r,g,b,a)) end, disabled = function() return not getTimerEnabled() end, width = "half" },
    { type = "dropdown", name = function() return AC.Language:GetString("SETTINGS_STYLE_TIMER_FONT") end, choices = fontStyles, choicesValues = fontStyleValues, getFunc = getTimerFontFace, setFunc = setTimerFontFace, disabled = function() return not getTimerEnabled() end, width = "half" },
    { type = "colorpicker", name = function() return AC.Language:GetString("SETTINGS_TIMER_ALERT_COLOR") end, getFunc = function() return getTimerAlertColor():UnpackRGBA() end, setFunc = function(r,g,b,a) setTimerAlertColor(ZO_ColorDef:New(r,g,b,a)) end, disabled = function() return not getTimerEnabled() end, width = "half" },
    { type = "divider" },
    -- Runes
    { type = "checkbox", name = function() return AC.Language:GetString("SETTINGS_STYLE_CRUX_RUNES") end, tooltip = function() return AC.Language:GetString("SETTINGS_STYLE_CRUX_RUNES_DESC") end, getFunc = function() return getElementEnabled("runes") end, setFunc = function(e) setElementEnabled("runes", e) end, width = "half" },
    { type = "checkbox", name = function() return AC.Language:GetString("SETTINGS_STYLE_ROTATE") end, tooltip = function() return AC.Language:GetString("SETTINGS_STYLE_CRUX_RUNES_ROTATE_DESC") end, getFunc = function() return getElementRotate("runes") end, setFunc = function(e) setElementRotate("runes", e) end, width = "half", disabled = function() return not getElementEnabled("runes") end },
    { type = "slider", name = function() return AC.Language:GetString("SETTINGS_STYLE_CRUX_RUNES_ROTATION_SPEED") end, min = 5, max = 95, step = 5, tooltip = function() return AC.Language:GetString("SETTINGS_STYLE_CRUX_RUNES_ROTATION_SPEED_DESC") end, getFunc = getRotationSpeed, setFunc = setRotationSpeed, width = "half", default = AC.Settings.defaults.elements.runes.rotationSpeed, disabled = function() return not getElementEnabled("runes") or not getElementRotate("runes") end },
    { type = "dropdown", name = function() return AC.Language:GetString("SETTINGS_STYLE_ROTATION_DIRECTION") end, choices = rotationDirectionChoices, choicesValues = rotationDirectionValues, getFunc = function() return AC.Settings.settings.elements.runes.rotationDirection end, setFunc = setRotationDirection, width = "half", disabled = function() return not getElementEnabled("runes") or not getElementRotate("runes") end },
    { type = "checkbox", name = function() return AC.Language:GetString("SETTINGS_STYLE_KEEP_UPRIGHT") end, tooltip = function() return AC.Language:GetString("SETTINGS_STYLE_KEEP_UPRIGHT_DESC") end, getFunc = getKeepUpright, setFunc = setKeepUpright, width = "full", disabled = function() return not getElementEnabled("runes") or not getElementRotate("runes") end },
    { type = "slider", name = function() return AC.Language:GetString("SETTINGS_STYLE_RUNE_OPACITY") end, min = 0, max = 100, step = 5, getFunc = getRuneOpacity, setFunc = setRuneOpacity, width = "full", disabled = function() return not getElementEnabled("runes") end },
    { type = "dropdown", name = function() return AC.Language:GetString("SETTINGS_STYLE_RUNE_TEXTURE") end, choices = runeTextureChoices, choicesValues = runeTextureValues, getFunc = getRuneTexture, setFunc = setRuneTexture, disabled = function() return not getElementEnabled("runes") end, width = "full" },
    { type = "checkbox", name = function() return AC.Language:GetString("SETTINGS_STYLE_RUNE_UNIQUE_COLORS") end, getFunc = getUseUniqueRuneColors, setFunc = setUseUniqueRuneColors, disabled = areRuneColorSettingsDisabled, width = "full" },
    { type = "checkbox", name = function() return AC.Language:GetString("SETTINGS_STYLE_RUNE_COLOR_1") end, getFunc = function() return getRuneColorEnabled(1) end, setFunc = function(v) setRuneColorEnabled(1, v) end, disabled = areRuneColorSettingsDisabled, width = "half" },
    { type = "colorpicker", name = " ", getFunc = function() return getRuneColor(1):UnpackRGBA() end, setFunc = function(r,g,b,a) setRuneColor(1, ZO_ColorDef:New(r,g,b,a)) end, default = getDefaultRuneColor(1), disabled = function() return areRuneColorSettingsDisabled() or not getRuneColorEnabled(1) end, width = "half" },
    { type = "button", name = function() return AC.Language:GetString("SETTINGS_RESET") end, func = function() resetRuneColor(1) end, width = "full", disabled = function() return not getElementEnabled("runes") end },
    
    { type = "checkbox", name = function() return AC.Language:GetString("SETTINGS_STYLE_RUNE_COLOR_2") end, getFunc = function() return getRuneColorEnabled(2) end, setFunc = function(v) setRuneColorEnabled(2, v) end, disabled = function() return areRuneColorSettingsDisabled() or not getUseUniqueRuneColors() end, width = "half" },
    { type = "colorpicker", name = " ", getFunc = function() return getRuneColor(2):UnpackRGBA() end, setFunc = function(r,g,b,a) setRuneColor(2, ZO_ColorDef:New(r,g,b,a)) end, default = getDefaultRuneColor(2), disabled = function() return areRuneColorSettingsDisabled() or not getUseUniqueRuneColors() or not getRuneColorEnabled(2) end, width = "half" },
    { type = "button", name = function() return AC.Language:GetString("SETTINGS_RESET") end, func = function() resetRuneColor(2) end, width = "full", disabled = function() return not getElementEnabled("runes") or not getUseUniqueRuneColors() end },

    { type = "checkbox", name = function() return AC.Language:GetString("SETTINGS_STYLE_RUNE_COLOR_3") end, getFunc = function() return getRuneColorEnabled(3) end, setFunc = function(v) setRuneColorEnabled(3, v) end, disabled = function() return areRuneColorSettingsDisabled() or not getUseUniqueRuneColors() end, width = "half" },
    { type = "colorpicker", name = " ", getFunc = function() return getRuneColor(3):UnpackRGBA() end, setFunc = function(r,g,b,a) setRuneColor(3, ZO_ColorDef:New(r,g,b,a)) end, default = getDefaultRuneColor(3), disabled = function() return areRuneColorSettingsDisabled() or not getUseUniqueRuneColors() or not getRuneColorEnabled(3) end, width = "half" },
    { type = "button", name = function() return AC.Language:GetString("SETTINGS_RESET") end, func = function() resetRuneColor(3) end, width = "full", disabled = function() return not getElementEnabled("runes") or not getUseUniqueRuneColors() end },
}

local soundOptions = {
    { type = "header", name = function() return AC.Language:GetString("SETTINGS_SOUNDS_HEADER") end, width = "full" },
    -- Alerte Minuteur
    { type = "checkbox", name = function() return AC.Language:GetString("SETTINGS_SOUNDS_TIMER_ALERT") end, tooltip = function() return AC.Language:GetString("SETTINGS_SOUNDS_TIMER_ALERT_DESC") end, getFunc = function() return AC.Settings:GetSoundEnabled("timerAlert") end, setFunc = function(s) setSoundEnabled("timerAlert", s) end, width = "full" },
    { type = "dropdown", name = "", choices = sounds, choicesValues = soundValues, getFunc = function() return getSound("timerAlert") end, setFunc = function(s) setSound("timerAlert", s) end, width = "half", scrollable = true, disabled = function() return not AC.Settings:GetSoundEnabled("timerAlert") end },
    { type = "slider", name = "", min = 0, max = 200, step = 10, getFunc = function() return getVolume("timerAlert") end, setFunc = function(v) setVolume("timerAlert", v) end, width = "half", default = AC.Settings.defaults.sounds.timerAlert.volume, disabled = function() return not AC.Settings:GetSoundEnabled("timerAlert") end },
    { type = "button", name = function() return AC.Language:GetString("SETTINGS_SOUNDS_PLAY") end, func = function() AC.UI:PlaySoundForType("timerAlert") end, width = "full", disabled = function() return not AC.Settings:GetSoundEnabled("timerAlert") end },
    { type = "divider" },
    -- Max Crux
    { type = "checkbox", name = function() return AC.Language:GetString("SETTINGS_SOUNDS_MAXIMUM_CRUX") end, tooltip = function() return AC.Language:GetString("SETTINGS_SOUNDS_MAXIMUM_CRUX_DESC") end, getFunc = function() return AC.Settings:GetSoundEnabled("maxCrux") end, setFunc = function(s) setSoundEnabled("maxCrux", s) end, width = "full" },
    { type = "dropdown", name = "", choices = sounds, choicesValues = soundValues, getFunc = function() return getSound("maxCrux") end, setFunc = function(s) setSound("maxCrux", s) end, width = "half", scrollable = true, disabled = function() return not AC.Settings:GetSoundEnabled("maxCrux") end },
    { type = "slider", name = "", min = 0, max = 200, step = 10, getFunc = function() return getVolume("maxCrux") end, setFunc = function(v) setVolume("maxCrux", v) end, width = "half", default = AC.Settings.defaults.sounds.maxCrux.volume, disabled = function() return not AC.Settings:GetSoundEnabled("maxCrux") end },
    { type = "button", name = function() return AC.Language:GetString("SETTINGS_SOUNDS_PLAY") end, func = function() AC.UI:PlaySoundForType("maxCrux") end, width = "full", disabled = function() return not AC.Settings:GetSoundEnabled("maxCrux") end },
}

local function addToMenu(options)
    for _, option in pairs(options) do
        table.insert(optionsData, option)
    end
end

function AC.Settings:BuildMenu()
    -- 3. Construction du Menu
    -- On vide la table optionsData pour éviter les doublons en cas de rechargement
    for k in pairs(optionsData) do optionsData[k] = nil end
    
    addToMenu(displayOptions)
    addToMenu(styleOptions)
    addToMenu(soundOptions)

    local lam = LibAddonMenu2
    if lam then
        local panelData = {
            type               = "panel",
            name               = "ArkaCruX",
            displayName        = "ArkaCruX",
            author             = AC.name .. " Team",
            version            = AC.version,
            registerForRefresh = true,
            slashCommand       = "/arkacrux",
        }
        lam:RegisterAddonPanel(AC.name, panelData)
        lam:RegisterOptionControls(AC.name, optionsData)
    end
end

local function populateSounds()
    -- Vider les tables avant de les remplir
    for k in pairs(sounds) do sounds[k] = nil end
    for k in pairs(soundValues) do soundValues[k] = nil end

    local tempSounds = {}
    for key, _ in pairs(gameSounds) do
        table.insert(tempSounds, {
            key = key,
            translated = AC.Language:GetString(key)
        })
    end

    -- Trier par nom traduit
    table.sort(tempSounds, function(a, b) return a.translated < b.translated end)

    -- Remplir les tables finales
    for _, soundInfo in ipairs(tempSounds) do
        table.insert(sounds, soundInfo.translated)
        table.insert(soundValues, soundInfo.key)
    end
end

local function populateDropdowns()
    -- 1. Polices
    for k in pairs(fontStyles) do fontStyles[k] = nil end
    fontStyles[1] = "Standard (Univers)"
    fontStyles[2] = "Standard Gras"
    fontStyles[3] = "Serif (Trajan - Défaut)"
    fontStyles[4] = "Manuscrit (Skyrim)"
    fontStyles[5] = "Gamepad (Gras)"

    -- Sens de rotation
    for k in pairs(rotationDirectionChoices) do rotationDirectionChoices[k] = nil end
    rotationDirectionChoices[1] = AC.Language:GetString("SETTINGS_STYLE_ROTATION_DIRECTION_CCW")
    rotationDirectionChoices[2] = AC.Language:GetString("SETTINGS_STYLE_ROTATION_DIRECTION_CW")

    -- 2. Textures de runes
    -- On vide et on refait pour être propre
    for k in pairs(runeTextureChoices) do runeTextureChoices[k] = nil end
    for k in pairs(runeTextureValues) do runeTextureValues[k] = nil end
    
    local function addTexture(name, path)
        table.insert(runeTextureChoices, name)
        table.insert(runeTextureValues, path)
    end

    -- Le premier choix est traduit, les autres sont des noms de fichiers ou codes
    addTexture(AC.Language:GetString("SETTINGS_STYLE_TEXTURE_DEFAULT"), "art/fx/texture/arcanist_trianglerune_01.dds")
    addTexture("Runes1", "ArkaCruX/textures/Runes1.dds")
    addTexture("Runes2", "ArkaCruX/textures/Runes2.dds")

    local otherTextures = {
        "Fr.dds", "De.dds", "Ru.dds", "Es.dds", "En.dds",
        "croix.dds", "flamme.dds", "octo.dds", "pentagramme.dds",
        "pizza.dds", "soleil.dds", "tribal.dds", "triangle.dds",
        "triangle2.dds", "pentagramme1.dds", "pentagramme2.dds",
        "molecule.dds", "infini.dds", "fenix.dds", "etoile.dds",
        "dead.dds", "etoile1.dds"
    
    }
    for _, tex in ipairs(otherTextures) do
        addTexture(tex, "ArkaCruX/textures/" .. tex)
    end
end

function AC.Settings:GetDefault(key)
    if key == nil then return self.defaults end
    return self.defaults[key]
end

function AC.Settings:Get(key)
    if key == nil then return self.settings end
    if self.settings[key] ~= nil then return self.settings[key] end
    return self:GetDefault(key)
end

function AC.Settings:GetElement(element)
    local elements = self:Get("elements")
    if not elements then return nil end
    return elements[element]
end

function AC.Settings:GetSoundEnabled(type)
    return self.settings.sounds[type].enabled
end

function AC.Settings:Setup()
    -- 1. Chargement des deux types de variables (Compte et Personnage)
    self.accountVars = ZO_SavedVars:NewAccountWide(self.savedVariables, self.dbVersion, nil, self.defaults)
    self.characterVars = ZO_SavedVars:NewCharacterIdSettings(self.savedVariables, self.dbVersion, nil, self.defaults)

    -- Fonction pour basculer la source des réglages
    function self:UpdateSettingsSource()
        if self.characterVars.useAccountSettings then
            self.settings = self.accountVars
        else
            self.settings = self.characterVars
        end
    end
    self:UpdateSettingsSource()

    -- 2. Fusion intelligente
    -- S'assure que toutes les options par défaut existent dans les réglages actuels
    -- (Indispensable lors des mises à jour d'addon ajoutant de nouvelles options)
    local function EnsureOptionsExist(settings, defaults)
        if type(settings) ~= "table" or type(defaults) ~= "table" then return end
        
        for key, defaultVal in pairs(defaults) do
            if type(defaultVal) == "table" then
                if type(settings[key]) ~= "table" then
                    -- La sous-section n'existe pas, on la copie entièrement
                    settings[key] = ZO_DeepTableCopy(defaultVal)
                else
                    -- La sous-section existe, on descend d'un niveau
                    EnsureOptionsExist(settings[key], defaultVal)
                end
            elseif settings[key] == nil then
                -- La valeur simple n'existe pas, on met la valeur par défaut
                settings[key] = defaultVal
            end
        end
    end
    
    EnsureOptionsExist(self.accountVars, self.defaults)
    EnsureOptionsExist(self.characterVars, self.defaults)

end

-- -----------------------------------------------------------------------------
-- Interface
-- -----------------------------------------------------------------------------
function AC.UI:PlaySound(soundKey, volume)
    AC.Debug:Trace(3, "Playing sound <<1>> at volume <<2>>", soundKey, volume)
    local soundId = gameSounds[soundKey]
    if not soundId then
        AC.Debug:Trace(1, "Warning: Sound key '<<1>>' not found.", soundKey)
        return
    end

    for _ = 0, volume, 10 do
        PlaySound(soundId)
    end
end

function AC.UI:PlaySoundForType(type)
    if AC.Settings:GetSoundEnabled(type) then
        local soundKey = AC.Settings.settings.sounds[type].name
        local volume = AC.Settings.settings.sounds[type].volume
        self:PlaySound(soundKey, volume)
    end
end

-- -----------------------------------------------------------------------------
-- Etat
-- -----------------------------------------------------------------------------
function AC.State:SetStacks(count, playSound)
    if playSound == nil then playSound = true end
    local previousStacks = self.stacks
    self.stacks = count

    -- Optimisation : Activer/Désactiver la boucle de mise à jour du timer seulement si nécessaire
    if AC.isInitialized then
        if count > 0 then
            EM:RegisterForUpdate(AC.name .. "_OnUpdate", 100, OnUpdate)
        else
            EM:UnregisterForUpdate(AC.name .. "_OnUpdate")
            if ArkaCruX_Display and type(ArkaCruX_Display) == "table" then
                ArkaCruX_Display:UpdateTimer("")
                ArkaCruX_Display:SetTimerColor(getTimerColor())
            end
        end
    end

    if count == previousStacks then return end
    AC.Debug:Trace(2, "Updating Crux: <<1>> -> <<2>>", previousStacks, count)

    if ArkaCruX_Display and type(ArkaCruX_Display) == "table" then
        ArkaCruX_Display:UpdateCount(count)
        ArkaCruX_Display:UpdateVisibility()
    else
        AC.Debug:Trace(1, "Warning: ArkaCruX_Display not available during stack update")
    end

    if playSound and count == self.maxStacks and previousStacks < self.maxStacks then
        local soundToPlay = "maxCrux"
        AC.UI:PlaySoundForType(soundToPlay)
    end
end

function AC.State:ClearStacks()
    self:SetStacks(0)
end

function AC.State:SetInCombat(inCombat)
    self.inCombat = inCombat
end

-- -----------------------------------------------------------------------------
-- Runes
-- -----------------------------------------------------------------------------
local AM = ANIMATION_MANAGER
local rotaRadius = 32

-- Classe ArkaCruX_Rune
ArkaCruX_Rune = ZO_InitializingObject:Subclass()

function ArkaCruX_Rune:Initialize(control, num)
    self.control = control
    self.number = num
    self.startingRotation = 180 + (num - 1) * 120 -- Répartition en triangle équilatéral (0, 120, 240 décalé pour le sommet)

    -- Note : Les noms des enfants "Smoke", "Glow", "Rune" doivent exister dans le XML
    self.smoke = {
        control = self.control:GetNamedChild("Smoke"),
        timeline = AM:CreateTimelineFromVirtual("ArkaCruX_CruxSmokeDontBreatheThis", self.control:GetNamedChild("Smoke")),
    }
    self.glow = self.control:GetNamedChild("Glow")
    self.rune = self.control:GetNamedChild("Rune")

    self:SetRotation2D(self.startingRotation)

    -- Les animations correspondent aux noms des modèles originaux
    self.timelines = {
        fadeIn   = AM:CreateTimelineFromVirtual("ArkaCruX_CruxFadeIn", self.control),
        fadeOut  = AM:CreateTimelineFromVirtual("ArkaCruX_CruxFadeOut", self.control),
        rotation = AM:CreateTimelineFromVirtual("ArkaCruX_RotateControlCW", self.control),
    }
    self.timelines.rotation:PlayInstantlyToStart() -- Force la rotation à 0 via l'animation

    self.timelines.fadeOut:SetHandler("OnStop", function()
        self:SetRotation2D(self.startingRotation)
        self.smoke.timeline:Stop()
    end)
    self.timelines.fadeIn:SetHandler("OnPlay", function()
        self.smoke.timeline:PlayFromStart()
    end)

    control.OnHidden = function() self.smoke.timeline:Stop() end
    control.OnShow = function() self.smoke.timeline:PlayFromStart() end
end

function ArkaCruX_Rune:SetColor(color)
    if areRuneColorSettingsDisabled() then
        self.rune:SetColor(1, 1, 1, 1) -- Pas de teinte de couleur
        self.glow:SetHidden(true)       -- On cache le halo pour éviter la couleur parasite
        self.smoke.control:SetHidden(true) -- On cache la fumée
    else
        self.rune:SetColor(color:UnpackRGBA())
        self.glow:SetHidden(false)
        self.smoke.control:SetHidden(false)
        self.glow:SetColor(color:UnpackRGBA())
        self.smoke.control:SetColor(color:UnpackRGBA())
    end
end

function ArkaCruX_Rune:SetTexture(path)
    self.rune:SetTexture(path)
    -- Applique la logique de couleur (cacher glow/smoke) si on change vers une texture de langue
    self:SetColor(ZO_ColorDef:New(1,1,1,1)) -- Couleur dummy, la logique interne de SetColor fera le travail
end

function ArkaCruX_Rune:SetOpacity(alpha)
    self.rune:SetAlpha(alpha)
end

function ArkaCruX_Rune:PlayRotation() 
    self.timelines.rotation:PlayFromStart() 
end

function ArkaCruX_Rune:StopRotation()
    self.timelines.rotation:PlayInstantlyToStart()
    self.timelines.rotation:Stop()
end
function ArkaCruX_Rune:Show() self.timelines.fadeIn:PlayFromStart() end
function ArkaCruX_Rune:Hide() self.timelines.fadeOut:PlayFromStart() end
function ArkaCruX_Rune:HideInstantly() self.timelines.fadeOut:PlayInstantlyToEnd() end
function ArkaCruX_Rune:PlayPositionShift() self.timelines.swoop:PlayFromStart() end
function ArkaCruX_Rune:SetRotation2D(degrees)
    local x, y = ZO_Rotate2D(math.rad(degrees), 0, rotaRadius)
    local parent = self.control:GetParent()
    self.control:SetAnchor(CENTER, parent, CENTER, x, y)
end

function ArkaCruX_Rune:SetRotationDirection(parentDirection, duration)
    -- Pour que la rune reste droite, elle doit tourner dans le sens inverse du conteneur
    local runeDirection = (parentDirection == "CCW") and "CW" or "CCW"
    local virtualName = "ArkaCruX_RotateControl" .. runeDirection
    
    if self.timelines.rotation then self.timelines.rotation:Stop() end
    self.timelines.rotation = AM:CreateTimelineFromVirtual(virtualName, self.control)
    
    -- Remise à zéro explicite via l'animation
    self.timelines.rotation:PlayInstantlyToStart()
    
    -- On réapplique la durée car recréer la timeline réinitialise les paramètres
    if duration then self:SetDuration(duration) end
end

function ArkaCruX_Rune:SetDuration(duration)
    self.timelines.rotation:GetFirstAnimation():SetDuration(duration)
end

function ArkaCruX_Rune:SetKeepUpright(keepUpright)
    self.keepUpright = keepUpright
    if not keepUpright then
        if self.timelines.rotation then
            -- On arrête l'animation de contre-rotation
            self.timelines.rotation:Stop()
            -- On force la remise à zéro visuelle en allant au début de l'animation (qui est à 0°)
            self.timelines.rotation:PlayInstantlyToStart()
        end
    end
end

function ArkaCruX_Rune:IsShowing() return self.control:GetAlpha() == 1 end

-- -----------------------------------------------------------------------------
-- Rotation
-- -----------------------------------------------------------------------------
-- Classe ArkaCruX_Rota
ArkaCruX_Rota = ZO_InitializingObject:Subclass()

function ArkaCruX_Rota:Initialize(control)
    self.control = control
    self.runes = {}
    local settings = AC.Settings:GetElement("runes")
    self.enabled = settings.enabled
    self.rotationEnabled = settings.rotate
    self.rotationSpeed = settings.rotationSpeed
    self.keepUpright = settings.keepUpright

    self:InitializeRunes()
    self.timeline = AM:CreateTimelineFromVirtual("ArkaCruX_RotateControlCCW", self.control)
end

function ArkaCruX_Rota:ApplySettings()
    local runes = AC.Settings:GetElement("runes")
    self:SetEnabled(runes.enabled)
    self:SetRotationEnabled(runes.rotate)
    self:SetRotationDuration(runes.rotationSpeed)
    self:SetRotationDirection(runes.rotationDirection or "CCW")
    self:SetKeepUpright(runes.keepUpright)
    self:UpdateRuneColors(AC.State.stacks)
    self:SetRuneTexture(getRuneTexture())
    self:SetRuneOpacity(runes.runeOpacity or 1)
end

function ArkaCruX_Rota:SetRotationDirection(direction)
    if self.direction == direction and self.timeline then return end
    self.direction = direction
    
    if self.timeline then self.timeline:Stop() end
    
    local virtualName = "ArkaCruX_RotateControl" .. direction
    self.timeline = AM:CreateTimelineFromVirtual(virtualName, self.control)

    -- Remise à zéro explicite du conteneur via l'animation
    self.timeline:PlayInstantlyToStart()
    
    
    -- Appliquer la vitesse actuelle
    self.timeline:GetFirstAnimation():SetDuration(self.rotationSpeed)
    
    -- Mettre à jour les enfants (Runes)
    self:ForRunes(function(_, rune) rune:SetRotationDirection(direction, self.rotationSpeed) end)
    self:ForRunes(function(_, rune) rune:SetKeepUpright(self.keepUpright) end)

    if self.enabled and self.rotationEnabled then self:PlayFromStart() end
end

function ArkaCruX_Rota:SetEnabled(enabled)
    self.enabled = enabled
    self:SetHidden(not enabled)
end

function ArkaCruX_Rota:UpdateRuneColors(count)
    local runesSettings = AC.Settings:GetElement("runes")
    if not runesSettings then return end

    local targetIndex = 1
    if runesSettings.useUniqueColors and not areRuneColorSettingsDisabled() then
        local found = false
        for i = count, 1, -1 do
            if runesSettings["useColor" .. i] then
                targetIndex = i
                found = true
                break
            end
        end
        if not found then targetIndex = 1 end
    end

    local color = getRuneColor(targetIndex)
    local isEnabled = runesSettings["useColor" .. targetIndex]

    if not isEnabled then color = baseColor end
    self:ForRunes(function(_, rune) rune:SetColor(color) end)
end

function ArkaCruX_Rota:SetRuneTexture(path)
    -- D'abord on met à jour la texture et l'état des couleurs (Glow/Smoke cachés si besoin)
    self:ForRunes(function(_, rune) rune:SetTexture(path) end)
    -- Ensuite on force une mise à jour des couleurs pour être sûr que tout est synchro
    self:UpdateRuneColors(AC.State.stacks)
end

function ArkaCruX_Rota:SetRuneOpacity(alpha)
    self:ForRunes(function(_, rune) rune:SetOpacity(alpha) end)
end

function ArkaCruX_Rota:SetKeepUpright(val)
    self.keepUpright = val
    self:ForRunes(function(_, rune) rune:SetKeepUpright(val) end)
    if self.enabled and self.rotationEnabled then self:PlayFromStart() end
end

function ArkaCruX_Rota:SetRotationEnabled(rotationEnabled)
    self.rotationEnabled = rotationEnabled
    if self.enabled and rotationEnabled then self:PlayFromStart() else self:Stop() end
end

function ArkaCruX_Rota:SetHidden(hidden)
    self.control:SetHidden(hidden)
    if not hidden and self.enabled and self.rotationEnabled then self:PlayFromStart() else self:Stop() end
end

function ArkaCruX_Rota:ForRunes(callback)
    for index, rune in ipairs(self.runes) do callback(index, rune) end
end

function ArkaCruX_Rota:UpdateCount(count)
    self:UpdateRuneColors(count)

    for i = 1, #self.runes do
        local rune = self.runes[i]
        if i <= count then
            if not rune:IsShowing() then rune:Show() end
        else
            if rune:IsShowing() then rune:Hide() end
        end
    end

end

function ArkaCruX_Rota:SetRotationDuration(duration)
    self.rotationSpeed = duration
    for _, rune in ipairs(self.runes) do if rune.SetDuration then rune:SetDuration(duration) end end
    self.timeline:GetFirstAnimation():SetDuration(duration)
end

function ArkaCruX_Rota:PlayFromStart() 
    -- On démarre manuellement les runes juste avant le cercle pour une synchro parfaite
    self:ForRunes(function(_, rune) 
        if self.keepUpright then rune:PlayRotation() end 
    end)
    self.timeline:PlayFromStart() 
end

function ArkaCruX_Rota:Stop()
    self:ForRunes(function(_, rune) rune:StopRotation() end)
    self.timeline:PlayInstantlyToStart()
    self.timeline:Stop()
end

function ArkaCruX_Rota:InitializeRunes()
    for i = 1, self.control:GetNumChildren(), 1 do
        local child = self.control:GetNamedChild("Crux" .. i)
        self.runes[i] = ArkaCruX_Rune:New(child, i)
    end
end

-- -----------------------------------------------------------------------------
-- Widget
-- -----------------------------------------------------------------------------
local WM = WINDOW_MANAGER

ArkaCruX_Widget = ZO_InitializingObject:Subclass()

function ArkaCruX_Widget:Initialize(control)
    self.control = control
    self.fragment = nil
    self.hideOutOfCombat = AC.Settings:Get("hideOutOfCombat")
    self.locked = AC.Settings:Get("locked")
    self.isPreviewing = false

    self.rota = ArkaCruX_Rota:New(control:GetNamedChild("Rota"))
    self.timer = control:GetNamedChild("Timer")

    self:InitializeValidateButton()
    self:SetHandlers()
end

function ArkaCruX_Widget:SetTimerEnabled(enabled) self.timer:SetHidden(not enabled) end
function ArkaCruX_Widget:SetTimerColor(color) self.timer:SetColor(color:UnpackRGBA()) end
function ArkaCruX_Widget:SetTimerSize(size) 
    if AC.Settings.settings.timer then AC.Settings.settings.timer.size = size end
    self:UpdateTimerFont() 
end
function ArkaCruX_Widget:UpdateTimerFont()
    local s = AC.Settings.settings.timer
    local face = s.fontFace or "$(BOLD_FONT)"
    if face == "ZoFontWinH1" then face = "$(BOLD_FONT)" end -- Compatibilité pour les anciens réglages
    self.timer:SetFont(face .. "|" .. (s.size or 48) .. "|outline")
end
function ArkaCruX_Widget:UpdateTimer(text) self.timer:SetText(text) end

function ArkaCruX_Widget:ApplySettings()
    local settings = AC.Settings:Get()
    self:SetPosition(settings.top, settings.left)
    self:SetMovable(not settings.locked)
    self:SetSize(settings.size)
    AC.Events:UpdateCombatState()

    local timerSettings = AC.Settings:Get("timer")
    if timerSettings then
        self:SetTimerEnabled(timerSettings.enabled)
        self:SetTimerColor(ZO_ColorDef:New(timerSettings.color))
        self:UpdateTimerFont()
    end

    self.rota:ApplySettings()
    
    local currentCount = (self.isPreviewing) and 3 or (AC.State.stacks or 0)
    self:UpdateCount(currentCount)
end

function ArkaCruX_Widget:InitializeValidateButton()
    local WM = WINDOW_MANAGER
    self.validateBtn = WM:CreateControlFromVirtual(nil, self.control, "ZO_DefaultButton")
    self.validateBtn:SetText(AC.Language:GetString("VALIDATE"))
    self.validateBtn:SetAnchor(TOP, self.control, BOTTOM, 0, 10)
    self.validateBtn:SetHandler("OnClicked", function() self:EndPreview() end)
    self.validateBtn:SetDimensions(80, 32)
    self.validateBtn:SetHidden(true)
end

function ArkaCruX_Widget:StartPreview()
    self.isPreviewing = true
    -- Déverrouiller le widget pour permettre le déplacement
    setLocked(false)
    if ArkaCruX_LockButton and ArkaCruX_LockButton.button then
        ArkaCruX_LockButton.button:SetText(getLockUnlockButtonText())
    end
    self:RemoveSceneFragments()
    self:Unhide()
    
    self.previewTextTimer = 6.0 -- Pour le texte du compte à rebours
    self.previewCruxTimer = 9.0 -- Pour le cycle des charges de Crux
    self.currentPreviewCrux = 0 -- Pour forcer la première mise à jour

    EM:RegisterForUpdate("ArkaCruX_PreviewLoop", 100, function() self:OnPreviewUpdate() end)
    if self.validateBtn then 
        self.validateBtn:SetText(AC.Language:GetString("VALIDATE")) -- Assurez-vous que le texte est correct
        self.validateBtn:SetHidden(false) 
    end
end

function ArkaCruX_Widget:OnPreviewUpdate()
    -- Mettre à jour et boucler le minuteur pour le cycle des Crux
    self.previewCruxTimer = self.previewCruxTimer - 0.1
    if self.previewCruxTimer <= 0.1 then self.previewCruxTimer = 9.0 end
    
    -- Déterminer le nombre de Crux à afficher
    local cruxCountToShow
    if self.previewCruxTimer > 6.0 then
        cruxCountToShow = 1
    elseif self.previewCruxTimer > 3.0 then
        cruxCountToShow = 2
    else
        cruxCountToShow = 3
    end
    if self.currentPreviewCrux ~= cruxCountToShow then
        self.currentPreviewCrux = cruxCountToShow
        self:UpdateCount(cruxCountToShow)
    end

    -- Mettre à jour et boucler le minuteur pour le texte
    self.previewTextTimer = self.previewTextTimer - 0.1
    if self.previewTextTimer <= 0 then self.previewTextTimer = 6.0 end
    local remaining = self.previewTextTimer
    self:UpdateTimer(string.format("%.0fs", remaining))
    if remaining < 5 then
        self:SetTimerColor(getTimerAlertColor())
    else
        self:SetTimerColor(getTimerColor())
    end
end

function ArkaCruX_Widget:EndPreview()
    self.isPreviewing = false
    EM:UnregisterForUpdate("ArkaCruX_PreviewLoop")
    self.currentPreviewCrux = nil

    if self.validateBtn then self.validateBtn:SetHidden(true) end

    -- Verrouiller le widget à sa nouvelle position
    setLocked(true)
    if ArkaCruX_LockButton and ArkaCruX_LockButton.button then
        ArkaCruX_LockButton.button:SetText(getLockUnlockButtonText())
    end

    self:Hide()

    -- Revenir à l'état d'affichage normal
    AC.State.stacks = -1 -- Force la mise à jour dans SetStacks
    onPlayerChanged()
end

function ArkaCruX_Widget:UpdateVisibility()
    if self.isPreviewing then return end

    -- Priorité absolue : Cacher sur ce personnage spécifique
    if AC.Settings.characterVars.hiddenForCharacter then
        self:RemoveSceneFragments()
        return
    end

    local shouldBeVisible = false
    if not AC.Settings:Get("hideOutOfCombat") then
        shouldBeVisible = true
    elseif AC.State.inCombat then
        shouldBeVisible = true
    elseif AC.State.stacks > 0 then
        shouldBeVisible = true
    end

    if shouldBeVisible then
        self:AddSceneFragments()
    else
        self:RemoveSceneFragments()
    end
end

function ArkaCruX_Widget:Hide() if not self.control:IsHidden() then self.control:SetHidden(true) end end
function ArkaCruX_Widget:Unhide() if self.control:IsHidden() then self.control:SetHidden(false) end end

function ArkaCruX_Widget:SetPosition(top, left)
    self.control:ClearAnchors()
    self.control:SetAnchor(CENTER, GuiRoot, CENTER, left, top)
end

function ArkaCruX_Widget:MoveToCenter() self:SetPosition(0, 0) end

function ArkaCruX_Widget:SetHandlers()
    self.control.OnMoveStop = function()
        local centerX, centerY = self.control:GetCenter()
        local parentCenterX, parentCenterY = self.control:GetParent():GetCenter()
        local top, left = centerY - parentCenterY, centerX - parentCenterX
        AC.Settings:SavePosition(top, left)
    end
    self.control:SetHandler("OnMouseEnter", function()
        if AC.Settings:Get("locked") then return end
        WM:SetMouseCursor(MOUSE_CURSOR_PAN)
    end)
    self.control:SetHandler("OnMouseExit", function()
        if AC.Settings:Get("locked") then return end
        WM:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
    end)
end

function ArkaCruX_Widget:SetSize(size) self:SetScale(size / AC.Settings:GetDefault("size")) end
function ArkaCruX_Widget:SetScale(scale) self.control:SetScale(scale) end

function ArkaCruX_Widget:AddSceneFragments()
    if self.fragment ~= nil then return end
    self.fragment = ZO_SimpleSceneFragment:New(self.control)
    HUD_UI_SCENE:AddFragment(self.fragment)
    HUD_SCENE:AddFragment(self.fragment)
end

function ArkaCruX_Widget:RemoveSceneFragments()
    if self.fragment == nil then return end
    HUD_UI_SCENE:RemoveFragment(self.fragment)
    HUD_SCENE:RemoveFragment(self.fragment)
    self.fragment = nil
end

function ArkaCruX_Widget:UpdateCount(count)
    self.rota:UpdateCount(count)
end

function ArkaCruX_Widget:SetMovable(movable)
    self.locked = not movable
    self.control:SetMovable(movable)
    self.control:SetMouseEnabled(movable)
end

-- Hooks XML Globaux
function ArkaCruX_Widget_OnInitialized(control)
    ArkaCruX_Display = ArkaCruX_Widget:New(control)
end

function ArkaCruX_Widget_OnMoveStop(self)
    self.OnMoveStop()
end

-- -----------------------------------------------------------------------------
-- Evenements
-- -----------------------------------------------------------------------------
-- AC.Events is defined at top
local hasPlayedAlertSound = false

local function getEventNamespace(event) return AC.name .. event end

local function onEffectChanged(_, changeType, _, _, _, _, _, stackCount)
    if changeType == EFFECT_RESULT_FADED then
        AC.State:ClearStacks()
        return
    end
    AC.State:SetStacks(stackCount)
end

local function onCombatChanged(_, inCombat)
    AC.State:SetInCombat(inCombat)
    
    -- Sécurité : Si l'affichage n'est pas encore prêt, on ne fait rien
    if not ArkaCruX_Display or type(ArkaCruX_Display) ~= "table" then return end

    ArkaCruX_Display:UpdateVisibility()
end

function AC.Events:UpdateCombatState()
    onCombatChanged(nil, IsUnitInCombat("player"))
end

function AC.Events:Listen(namespace, event, callbackFunc)
    EM:RegisterForEvent(getEventNamespace(namespace), event, callbackFunc)
end

function AC.Events:Unlisten(namespace, event)
    EM:UnregisterForEvent(getEventNamespace(namespace), event)
end

function AC.Events:AddFilter(namespace, event, filterType, filterValue, ...)
    EM:AddFilterForEvent(getEventNamespace(namespace), event, filterType, filterValue, ...)
end

function OnUpdate()
    if not ArkaCruX_Display or type(ArkaCruX_Display) ~= "table" or ArkaCruX_Display.isPreviewing then return end

    local hasCrux = false
    for i = 1, GetNumBuffs("player") do
        local _, _, endTime, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if abilityId == AC.abilityId then
            hasCrux = true
            local remaining = endTime - GetGameTimeSeconds()
            if remaining > 0 then
                ArkaCruX_Display:UpdateTimer(string.format("%.0fs", remaining))
                -- Change la couleur du timer s'il reste moins de 5 secondes
                if remaining < 5 then
                    ArkaCruX_Display:SetTimerColor(getTimerAlertColor())
                    if not hasPlayedAlertSound then
                        AC.UI:PlaySoundForType("timerAlert")
                        hasPlayedAlertSound = true
                    end
                else
                    ArkaCruX_Display:SetTimerColor(getTimerColor())
                    hasPlayedAlertSound = false
                end
            else
                ArkaCruX_Display:UpdateTimer("")
                ArkaCruX_Display:SetTimerColor(getTimerColor())
                hasPlayedAlertSound = false
            end
            break
        end
    end

    if not hasCrux then
        ArkaCruX_Display:UpdateTimer("")
        ArkaCruX_Display:SetTimerColor(getTimerColor())
        hasPlayedAlertSound = false
    end
end

function onPlayerChanged()
    AC.Events:UpdateCombatState()

    local foundCrux = false
    local stackCount = 0
    for i = 1, GetNumBuffs("player") do
        local _, _, _, _, stacks, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if abilityId == AC.abilityId then
            foundCrux = true
            stackCount = stacks
            break
        end
    end
    -- Met à jour l'état sans jouer de son, car c'est une synchronisation
    AC.State:SetStacks(stackCount, false)

    OnUpdate() -- Force une mise à jour pour obtenir les stacks initiaux
end

function AC.Events:RegisterForCombat()
    self:UpdateCombatState()
    self:Listen("CombatState", EVENT_PLAYER_COMBAT_STATE, onCombatChanged)
end

function AC.Events:UnregisterForCombat()
    self:Unlisten("CombatState", EVENT_PLAYER_COMBAT_STATE)
    self:UpdateCombatState()
end

function AC.Events:RegisterEvents()
    self:Listen("EffectChanged", EVENT_EFFECT_CHANGED, onEffectChanged)
    self:AddFilter("EffectChanged", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, AC.abilityId, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    self:Unlisten("PlayerDead", EVENT_PLAYER_DEAD) -- Evite les doublons au /reloadui
    self:Listen("PlayerDead", EVENT_PLAYER_DEAD, onPlayerChanged)
    self:Listen("PlayerAlive", EVENT_PLAYER_ALIVE, onPlayerChanged)
    self:Listen("PlayerActivated", EVENT_PLAYER_ACTIVATED, onPlayerChanged)
    self:Listen("ZoneUpdated", EVENT_ZONE_UPDATE, onPlayerChanged)
    self:Unlisten("CombatState", EVENT_PLAYER_COMBAT_STATE) -- Evite les doublons au /reloadui

    if AC.Settings:Get("hideOutOfCombat") then
        self:RegisterForCombat()
    end

end

-- -----------------------------------------------------------------------------
-- Initialisation
-- -----------------------------------------------------------------------------
local initNs = AC.name .. "_Init"

local function unregister()
    EM:UnregisterForEvent(initNs, EVENT_ADD_ON_LOADED)
end

local function init(_, addonName)
    if addonName ~= AC.name then return end
    unregister()

    -- 1. Charger les paramètres (SavedVars) en premier pour récupérer les préférences (ex: langue)
    if AC.Settings and AC.Settings.Setup then
        AC.Settings:Setup()
    else
        d("|cFF0000[ArkaCruX] Erreur Critique: Module Settings manquant.|r")
    end

    -- 2. Charger la langue (en utilisant les paramètres chargés)
    if AC.Language and AC.Language.Setup then
        AC.Language:Setup()
        populateSounds() -- Populate sounds after language setup
        populateDropdowns() -- Populate dropdowns after language setup
    end

    if AC.Settings and AC.Settings.BuildMenu then
        AC.Settings:BuildMenu()
    end

    -- 3. Enregistrer les événements du jeu
    if AC.Events and AC.Events.RegisterEvents then
        AC.Events:RegisterEvents()
    end

    -- 4. Initialiser l'affichage graphique
    -- On vérifie que ArkaCruX_Display est bien l'objet Lua (table) et pas juste le contrôle XML (userdata)
    -- Si c'est "userdata", cela signifie que le fichier XML a créé le contrôle mais que le Lua ne l'a pas encore "enveloppé".
    if ArkaCruX_Display and type(ArkaCruX_Display) == "table" and ArkaCruX_Display.ApplySettings then
        ArkaCruX_Display:ApplySettings()
    else
        AC.Debug:Trace(1, "Interface pas encore prête, tentative différée...")
        -- On réessaie dans 500ms, le temps que tout se charge
        zo_callLater(function()
            if ArkaCruX_Display and type(ArkaCruX_Display) == "table" and ArkaCruX_Display.ApplySettings then
                ArkaCruX_Display:ApplySettings()
            end
        end, 500)
    end

    AC.isInitialized = true
    AC.Debug:Say("Addon chargé avec succès.")
end

EM:RegisterForEvent(initNs, EVENT_ADD_ON_LOADED, init)
