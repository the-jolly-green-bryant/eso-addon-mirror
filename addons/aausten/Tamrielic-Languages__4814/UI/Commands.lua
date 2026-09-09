local TT = TamrielicTongues

TT.Commands = {}

local function splitFirst(value)
    value = TT.Normalizer:Trim(value or "")
    if value == "" then
        return "", ""
    end

    local first, rest = value:match("^(%S+)%s*(.*)$")
    return first or "", rest or ""
end

function TT.Commands:PrintStatus()
    TT:Print(TT.Locale:Get(
        "STATUS",
        TT.ChatMenu:GetActiveLanguageLabel(),
        TT.Locale:Get(TT.saved.showTranslations and "ON" or "OFF")
    ))
end

function TT.Commands:PrintLanguages()
    TT:Print(TT.Locale:Get("LANGUAGES_HEADER"))
    for _, profile in ipairs(TT.Registry:GetOrdered()) do
        TT:Print(TT.Locale:Get("LANGUAGE_ENTRY", profile.id, TT.Locale:LanguageName(profile), TT.Locale:RaceName(profile)))
    end
    TT:Print(TT.Locale:Get("COMMON_ENTRY"))
end

function TT.Commands:SetLanguage(argument)
    argument = TT.Normalizer:Trim(argument or "")
    if argument == "" then
        self:PrintStatus()
        return
    end

    local resolved = TT.Registry:ResolveId(argument)
    if not resolved then
        TT:Print(TT.Locale:Get("UNKNOWN_LANGUAGE", argument))
        return
    end

    TT.Settings:SetActiveLanguage(resolved)
    TT:Print(TT.Locale:Get("NOW_SPEAKING", TT.ChatMenu:GetActiveLanguageLabel()))
end

function TT.Commands:Test(argument)
    local language, text = splitFirst(argument)
    if language == "" or text == "" then
        TT:Print(TT.Locale:Get("TEST_USAGE"))
        return
    end

    local encoded, errorMessage, encodedProfile = TT.Translator:Encode(language, text)
    if not encoded then
        TT:Print(errorMessage or TT.Locale:Get("TEST_FAILED"))
        return
    end

    local decoded = encodedProfile and TT.Translator:Decode(encoded) or encoded
    local languageName = encodedProfile and TT.Locale:LanguageName(encodedProfile) or TT.Locale:Get("COMMON_NAME")
    TT:Print(TT.Locale:Get("TEST_RESULT", languageName, encoded))
    TT:Print(TT.Locale:Get("ROUND_TRIP", tostring(decoded)))
end

function TT.Commands:HandleTT(argument)
    local command, rest = splitFirst(argument)
    command = string.lower(command)

    if command == "" or command == "status" then
        self:PrintStatus()
    elseif command == "settings" then
        TT.Settings:Open()
    elseif command == "help" then
        TT:Print(TT.Locale:Get("HELP"))
    elseif command == "languages" or command == "langs" then
        self:PrintLanguages()
    elseif command == "test" then
        self:Test(rest)
    elseif command == "translations" then
        local value = string.lower(TT.Normalizer:Trim(rest))
        if value == "on" then
            TT.Settings:SetTranslationsEnabled(true)
            TT:Print(TT.Locale:Get("TRANSLATIONS_ON"))
        elseif value == "off" then
            TT.Settings:SetTranslationsEnabled(false)
            TT:Print(TT.Locale:Get("TRANSLATIONS_OFF"))
        else
            TT:Print(TT.Locale:Get("TRANSLATIONS_USAGE"))
        end
    elseif command == "about" then
        TT:Print(TT.Locale:Get("ABOUT", TT.VERSION))
    else
        TT:Print(TT.Locale:Get("HELP"))
    end
end

function TT.Commands:Initialize()
    SLASH_COMMANDS["/lang"] = function(argument)
        TT.Commands:SetLanguage(argument)
    end

    SLASH_COMMANDS["/tt"] = function(argument)
        TT.Commands:HandleTT(argument)
    end
end
