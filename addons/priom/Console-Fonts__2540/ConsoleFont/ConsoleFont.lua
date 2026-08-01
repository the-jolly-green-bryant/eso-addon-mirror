local CF = ConsoleFont or {}

CF.name = "ConsoleFont"
CF.displayName = "ConsoleFont"
CF.version = "1.0"

CF.defaults =
{
    useCustomFont = false,
    replaceChatFont = false,

    SCTOutline = true,
    NameplateOutline = true,

    uiScale = 1.2,
    chatScale = 1.4,

    customUiScale = 0.9,
    customChatScale = 1.2,

    compassTextScale = 1.2,
}

local ppCompatInitialized = false
local chatUpdaterInitialized = false
local originalPPFont = nil

local gamepadFont_Light_Default = "EsoUI/Common/Fonts/ftn47.slug"
local gamepadFont_Medium_Default = "EsoUI/Common/Fonts/ftn57.slug"
local gamepadFont_Bold_Default = "EsoUI/Common/Fonts/ftn87.slug"
local customFont = "ConsoleFont/Fonts/GothamNarrowUltra.slug"

local gamepadFont_Light = gamepadFont_Light_Default
local gamepadFont_Medium = gamepadFont_Medium_Default
local gamepadFont_Bold = gamepadFont_Bold_Default
local chat_font = gamepadFont_Medium

local THICK = "soft-shadow-thick"
local NONE = "none"
local OUTLINE = "outline"

local chat_style = THICK
local ui_size_multiplier = 1.2
local chat_size_multiplier = 1.4

local SCT_FONT_STYLE = FONT_STYLE_OUTLINE
local NAMEPLATE_FONT_STYLE = FONT_STYLE_OUTLINE
local SCT_STYLE = OUTLINE

local FONT_REPLACEMENTS = {}

local function ScaleSize(size, multiplier)
    return zo_round(size * (multiplier or ui_size_multiplier))
end

local function BuildFont(fontPath, size, style, multiplier)
    return string.format("%s|%s|%s", fontPath, ScaleSize(size, multiplier), style or THICK)
end

local function SetFontObject(fontObject, fontPath, size, style, multiplier)
    if fontObject and fontObject.SetFont then
        fontObject:SetFont(BuildFont(fontPath, size, style, multiplier))
    end
end

function CF:ApplySettings()
    local sv = self.SV or self.defaults

    gamepadFont_Light = gamepadFont_Light_Default
    gamepadFont_Medium = gamepadFont_Medium_Default
    gamepadFont_Bold = gamepadFont_Bold_Default

    SCT_FONT_STYLE = sv.SCTOutline and FONT_STYLE_OUTLINE or FONT_STYLE_SOFT_SHADOW_THICK
    NAMEPLATE_FONT_STYLE = sv.NameplateOutline and FONT_STYLE_OUTLINE or FONT_STYLE_SOFT_SHADOW_THICK
    SCT_STYLE = OUTLINE

    ui_size_multiplier = sv.uiScale
    chat_size_multiplier = sv.chatScale

    if sv.useCustomFont then
        gamepadFont_Light = customFont
        gamepadFont_Medium = customFont
        gamepadFont_Bold = customFont

        SCT_FONT_STYLE = FONT_STYLE_SOFT_SHADOW_THICK
        NAMEPLATE_FONT_STYLE = FONT_STYLE_SOFT_SHADOW_THICK
        SCT_STYLE = THICK

        ui_size_multiplier = sv.customUiScale
        chat_size_multiplier = sv.customChatScale
    end

    if sv.replaceChatFont then
        chat_font = gamepadFont_Medium
        chat_style = THICK
    else
        chat_font = "EsoUI/Common/Fonts/Univers67.slug"
        chat_style = THICK
    end

    FONT_REPLACEMENTS =
    {
        ["EsoUI/Common/Fonts/Univers47.slug"] = gamepadFont_Light,
        ["EsoUI/Common/Fonts/Univers57.slug"] = gamepadFont_Medium,
        ["EsoUI/Common/Fonts/Univers67.slug"] = gamepadFont_Bold,
        ["EsoUI/Common/Fonts/Univers77.slug"] = gamepadFont_Bold,
    }
end

local function ReplaceFontObject(fontObject)
    if not fontObject or not fontObject.GetFontInfo or not fontObject.SetFont then return end

    local fontPath, size = fontObject:GetFontInfo()
    local replacement = FONT_REPLACEMENTS[fontPath]

    if replacement then
        fontObject:SetFont(BuildFont(replacement, size, THICK, ui_size_multiplier))
    end
end

function CF:ReplaceGlobalFonts()
    if IsInGamepadPreferredMode() and not self.SV.useCustomFont then return end

    for key, value in zo_insecurePairs(_G) do
        if type(key) == "string"
            and key:find("^Zo")
            and type(value) == "userdata"
            and value.SetFont
            and value.GetFontInfo
        then
            ReplaceFontObject(value)
        end
    end
end

function CF:ChangeChatFonts()
    local baseFontSize = GetChatFontSize()
    local scaledFontSize = ScaleSize(baseFontSize, chat_size_multiplier)
    local fontName = string.format("%s|%s|%s", chat_font, scaledFontSize, chat_style)

    CHAT_SYSTEM:SetFontSize(scaledFontSize)

    zo_callLater(function()
        ZoFontEditChat:SetFont(fontName)
        ZoFontChat:SetFont(fontName)
    end, 50)
end

function CF:UpdateSCTFonts()
    SetSCTKeyboardFont(
        BuildFont(gamepadFont_Bold, 46, OUTLINE, ui_size_multiplier),
        SCT_FONT_STYLE
    )

    SetNameplateKeyboardFont(
        BuildFont(gamepadFont_Medium, 22, OUTLINE, ui_size_multiplier),
        NAMEPLATE_FONT_STYLE
    )

    CF:ChangeChatFonts()
    CF:UpdateTooltipFonts()
    CF:UpdateExtraFonts()
    CF:UpdateCompassFonts()
end

function CF:UpdateGamepadSCT()
    SetSCTGamepadFont(
        BuildFont(gamepadFont_Bold, 46, OUTLINE, ui_size_multiplier),
        SCT_FONT_STYLE
    )

    SetNameplateGamepadFont(
        BuildFont(gamepadFont_Medium, 28, OUTLINE, ui_size_multiplier),
        NAMEPLATE_FONT_STYLE
    )

    CF:UpdateCompassFonts()
end

function CF:UpdateTooltipFonts()
    SetFontObject(ZoFontTooltipTitle, gamepadFont_Medium, 25, OUTLINE, ui_size_multiplier)
    SetFontObject(ZoFontTooltipSubtitle, gamepadFont_Medium, 24, OUTLINE, ui_size_multiplier)
end

function CF:UpdateCompassFonts()
    if ZO_CompassCenterOverPinLabel then
        ZO_CompassCenterOverPinLabel:SetScale(CF.SV.compassTextScale)
        ZO_CompassCenterOverPinLabel:SetFont(BuildFont(gamepadFont_Bold, 18, SCT_STYLE, ui_size_multiplier))
    end
end

function CF:UpdateExtraFonts()
    SetFontObject(ZoFontGame, gamepadFont_Medium, 18, THICK, ui_size_multiplier)
    SetFontObject(ZoFontHeader, gamepadFont_Bold, 22, THICK, ui_size_multiplier)
    SetFontObject(ZoFontCallout, gamepadFont_Bold, 26, THICK, ui_size_multiplier)
    SetFontObject(ZoFontEdit, gamepadFont_Medium, 18, THICK, ui_size_multiplier)

    SetFontObject(ZoFontConversationName, gamepadFont_Bold, 24, OUTLINE, ui_size_multiplier)
    SetFontObject(ZoFontConversationOption, gamepadFont_Medium, 22, THICK, ui_size_multiplier)
    SetFontObject(ZoFontConversationQuestReward, gamepadFont_Medium, 20, THICK, ui_size_multiplier)

    SetFontObject(ZoFontBookPaper, gamepadFont_Medium, 22, NONE, ui_size_multiplier)
    SetFontObject(ZoFontBookSkin, gamepadFont_Medium, 22, NONE, ui_size_multiplier)
    SetFontObject(ZoFontBookRubbing, gamepadFont_Medium, 22, NONE, ui_size_multiplier)
    SetFontObject(ZoFontBookLetter, gamepadFont_Medium, 22, NONE, ui_size_multiplier)
    SetFontObject(ZoFontBookNote, gamepadFont_Medium, 22, NONE, ui_size_multiplier)
    SetFontObject(ZoFontBookScroll, gamepadFont_Medium, 22, NONE, ui_size_multiplier)
    SetFontObject(ZoFontBookTablet, gamepadFont_Medium, 22, NONE, ui_size_multiplier)
end

function CF:RefreshFontsForCurrentMode()
    self:ApplySettings()

    zo_callLater(function()
        if IsInGamepadPreferredMode() then
            CF:UpdateGamepadSCT()
        else
            CF:ReplaceGlobalFonts()
            CF:UpdateSCTFonts()
        end

        CF:UpdateTooltipFonts()
        CF:UpdateExtraFonts()
        CF:UpdateCompassFonts()
        CF:OverridePPFonts()
    end, 250)
end

function CF:SetupChatFontUpdater()
    if chatUpdaterInitialized then return end
    chatUpdaterInitialized = true

    ZO_PreHook("SetChatFontSize", function()
        zo_callLater(function()
            CF:ChangeChatFonts()
        end, 50)
    end)

    EVENT_MANAGER:RegisterForEvent(CF.name .. "ChatUpdater", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function()
            CF:ChangeChatFonts()
        end, 500)
    end)
end

function CF:OverridePPFonts()
    if not PP or not PP.f then return end

    PP.f.u57 = gamepadFont_Medium
    PP.f.u67 = gamepadFont_Bold
end

function CF:SetupPerfectPixelCompat()
    if ppCompatInitialized then return end
    if not PP then return end

    ppCompatInitialized = true
    CF:OverridePPFonts()

    if PP.Font and not originalPPFont then
        originalPPFont = PP.Font

        PP.Font = function(control, font, size, style, ...)
            if font == PP.f.u57 or font == PP.f.u67 or font == gamepadFont_Medium or font == gamepadFont_Bold then
                size = ScaleSize(size, ui_size_multiplier)
            end

            if CF.SV.useCustomFont and style == "outline" then
                style = THICK
            end

            return originalPPFont(control, font, size, style, ...)
        end
    end

    ZO_PreHook(PP, "Core", function()
        CF:OverridePPFonts()
        return false
    end)

    ZO_PostHook(PP, "compass", function()
        CF:OverridePPFonts()

        local compassSize = ScaleSize(20, ui_size_multiplier)
        local compassFont = ZO_CreateFontString(gamepadFont_Bold, compassSize, SCT_FONT_STYLE)

        COMPASS.container:SetCardinalDirection(GetString(SI_COMPASS_NORTH_ABBREVIATION), compassFont, CARDINAL_DIRECTION_NORTH)
        COMPASS.container:SetCardinalDirection(GetString(SI_COMPASS_EAST_ABBREVIATION), compassFont, CARDINAL_DIRECTION_EAST)
        COMPASS.container:SetCardinalDirection(GetString(SI_COMPASS_WEST_ABBREVIATION), compassFont, CARDINAL_DIRECTION_WEST)
        COMPASS.container:SetCardinalDirection(GetString(SI_COMPASS_SOUTH_ABBREVIATION), compassFont, CARDINAL_DIRECTION_SOUTH)

        if PP.Font then
            PP.Font(ZO_BossBarHealthText, gamepadFont_Bold, ScaleSize(18, ui_size_multiplier), THICK)
        end
    end)

    ZO_PostHook(PP, "keybindStrip", function()
        CF:OverridePPFonts()

        local nameSize = ScaleSize(18, ui_size_multiplier)
        local keySize = ScaleSize(16, ui_size_multiplier)

        KEYBIND_STRIP_STANDARD_STYLE.nameFont = BuildFont(gamepadFont_Bold, nameSize, THICK, 1)
        KEYBIND_STRIP_STANDARD_STYLE.keyFont = BuildFont(gamepadFont_Medium, keySize, THICK, 1)

        KEYBIND_STRIP_CHAMPION_KEYBOARD_STYLE.nameFont = BuildFont(gamepadFont_Bold, nameSize, THICK, 1)
        KEYBIND_STRIP_CHAMPION_KEYBOARD_STYLE.keyFont = BuildFont(gamepadFont_Medium, keySize, THICK, 1)
    end)
end

function CF:SetupOptions()
    if not LibAddonMenu2 then return end

    local panelData =
    {
        type = "panel",
        name = CF.displayName,
        displayName = CF.displayName,
        author = "Priom",
        version = CF.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LibAddonMenu2:RegisterAddonPanel("ConsoleFontOptions", panelData)

    local options =
    {
        {
            type = "checkbox",
            name = "Use custom font",
            tooltip = "Use the bundled Gotham Narrow Ultra font instead of ESO gamepad fonts. Requires reload to fully restore replaced font objects.",
            getFunc = function() return CF.SV.useCustomFont end,
            setFunc = function(value)
                CF.SV.useCustomFont = value
                ReloadUI()
            end,
            default = CF.defaults.useCustomFont,
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = "Replace chat font",
            tooltip = "Use the selected ConsoleFont font for chat instead of Univers.",
            getFunc = function() return CF.SV.replaceChatFont end,
            setFunc = function(value)
                CF.SV.replaceChatFont = value
                CF:ApplySettings()

                zo_callLater(function()
                    CF:ChangeChatFonts()
                end, 50)

                zo_callLater(function()
                    CF:ChangeChatFonts()
                end, 250)

                zo_callLater(function()
                    CF:ChangeChatFonts()
                end, 1000)
            end,
            default = CF.defaults.replaceChatFont,
        },
        {
            type = "checkbox",
            name = "Combat text outline",
            disabled = function() return CF.SV.useCustomFont end,
            getFunc = function() return CF.SV.SCTOutline end,
            setFunc = function(value)
                CF.SV.SCTOutline = value
                CF:RefreshFontsForCurrentMode()
            end,
            default = CF.defaults.SCTOutline,
        },
        {
            type = "checkbox",
            name = "Nameplate outline",
            disabled = function() return CF.SV.useCustomFont end,
            getFunc = function() return CF.SV.NameplateOutline end,
            setFunc = function(value)
                CF.SV.NameplateOutline = value
                CF:RefreshFontsForCurrentMode()
            end,
            default = CF.defaults.NameplateOutline,
        },
        {
            type = "slider",
            name = "UI font scale",
            min = 0.7,
            max = 1.8,
            step = 0.1,
            getFunc = function() return CF.SV.uiScale end,
            setFunc = function(value)
                CF.SV.uiScale = value
                if not CF.SV.useCustomFont then
                    CF:RefreshFontsForCurrentMode()
                end
            end,
            default = CF.defaults.uiScale,
            formatFunc = function(value)
                return string.format("%.1f", value)
            end,
        },
        {
            type = "slider",
            name = "Chat font scale",
            min = 0.7,
            max = 2.2,
            step = 0.1,
            getFunc = function() return CF.SV.chatScale end,
            setFunc = function(value)
                CF.SV.chatScale = value
                if not CF.SV.useCustomFont then
                    CF:ApplySettings()
                    CF:ChangeChatFonts()
                end
            end,
            default = CF.defaults.chatScale,
            formatFunc = function(value)
                return string.format("%.1f", value)
            end,
        },
        {
            type = "slider",
            name = "Custom UI font scale",
            min = 0.5,
            max = 1.5,
            step = 0.1,
            getFunc = function() return CF.SV.customUiScale end,
            setFunc = function(value)
                CF.SV.customUiScale = value
                if CF.SV.useCustomFont then
                    CF:RefreshFontsForCurrentMode()
                end
            end,
            default = CF.defaults.customUiScale,
            formatFunc = function(value)
                return string.format("%.1f", value)
            end,
        },
        {
            type = "slider",
            name = "Custom chat font scale",
            min = 0.5,
            max = 2.0,
            step = 0.1,
            getFunc = function() return CF.SV.customChatScale end,
            setFunc = function(value)
                CF.SV.customChatScale = value
                if CF.SV.useCustomFont then
                    CF:ApplySettings()
                    CF:ChangeChatFonts()
                end
            end,
            default = CF.defaults.customChatScale,
            formatFunc = function(value)
                return string.format("%.1f", value)
            end,
        },
        {
            type = "slider",
            name = "Compass center text scale",
            min = 0.8,
            max = 1.8,
            step = 0.1,
            getFunc = function() return CF.SV.compassTextScale end,
            setFunc = function(value)
                CF.SV.compassTextScale = value
                CF:UpdateCompassFonts()
            end,
            default = CF.defaults.compassTextScale,
            formatFunc = function(value)
                return string.format("%.1f", value)
            end,
        },
    }

    LibAddonMenu2:RegisterOptionControls("ConsoleFontOptions", options)
end

function CF:Initialize()
    self.SV = ZO_SavedVars:NewAccountWide("ConsoleFontSavedVariables", 1, nil, self.defaults)

    CF:ApplySettings()
    CF:ReplaceGlobalFonts()
    CF:SetupOptions()
    CF:SetupChatFontUpdater()
    CF:SetupPerfectPixelCompat()
    CF:RefreshFontsForCurrentMode()
end

function CF:SetupEvents(toggle)
    if toggle then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function()
            CF:RefreshFontsForCurrentMode()
        end)

        EVENT_MANAGER:RegisterForEvent(self.name .. "GamepadMode", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function()
            CF:RefreshFontsForCurrentMode()
        end)
    else
        EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED)
        EVENT_MANAGER:UnregisterForEvent(self.name .. "GamepadMode", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED)
    end
end

function CF.OnAddonLoaded(event, addonName)
    if addonName == CF.name then
        CF:Initialize()
        CF:SetupEvents(true)
    end

    if addonName == "PerfectPixel" or addonName == "PerfectPixel_Cp" or PP then
        CF:SetupPerfectPixelCompat()
    end
end

EVENT_MANAGER:RegisterForEvent(CF.name, EVENT_ADD_ON_LOADED, CF.OnAddonLoaded)