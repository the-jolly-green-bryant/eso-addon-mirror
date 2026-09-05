OWAssistant = {
    name = "OWAssistant",
    addonName = "OlhasWrathAssistant",
    version = "0.1.2",
    Localization = {
        defaultLanguage = "en",
        languages = {},
        order = {},
    },
}

local owa = OWAssistant
local localization = owa.Localization

function owa.RegisterLanguage(code, displayName, strings)
    if not localization.languages[code] then
        localization.languages[code] = {
            displayName = displayName,
            strings = {},
        }
        table.insert(localization.order, code)
    end

    local language = localization.languages[code]
    language.displayName = displayName or language.displayName

    for key, value in pairs(strings or {}) do
        language.strings[key] = value
    end
end

function owa.AddLanguageStrings(code, strings, prefix)
    local language = localization.languages[code]
    if not language then
        return
    end

    local function AddStrings(values, currentPrefix)
        for key, value in pairs(values) do
            local fullKey = currentPrefix and (currentPrefix .. "_" .. key) or key
            if type(value) == "table" then
                AddStrings(value, fullKey)
            else
                language.strings[fullKey] = value
            end
        end
    end

    AddStrings(strings or {}, prefix)
end

function owa.GetLanguageCode()
    local savedLanguage = owa.savedVariables
        and owa.savedVariables.language

    if localization.languages[savedLanguage] then
        return savedLanguage
    end

    local clientLanguage = GetCVar("language.2")
    if localization.languages[clientLanguage] then
        return clientLanguage
    end

    return localization.defaultLanguage
end

function owa.GetString(key)
    local selected = localization.languages[owa.GetLanguageCode()]
    local fallback = localization.languages[localization.defaultLanguage]

    return (selected and selected.strings[key])
        or (fallback and fallback.strings[key])
        or key
end

function owa.GetLanguageChoices()
    local choices = {}
    local values = {}

    for _, code in ipairs(localization.order) do
        local language = localization.languages[code]
        table.insert(choices, language.displayName)
        table.insert(values, code)
    end

    return choices, values
end

local ADDON_NAME = owa.addonName

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        ADDON_NAME,
        EVENT_ADD_ON_LOADED
    )

    owa.Initialize()
end

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)
