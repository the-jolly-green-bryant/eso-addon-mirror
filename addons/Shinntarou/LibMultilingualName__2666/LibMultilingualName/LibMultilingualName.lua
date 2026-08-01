LibMultilingualName = LibMultilingualName or {}
local LIB = LibMultilingualName -- local name
local LMN = LIB -- Lib Multilingual Name

local clientLangCode = nil

local function contains(table, val)
    for i=1,#table do
        if table[i] == val then
            return true
        end
    end
    return false
end

--------
-- Public Methods, Consts
--------

LIB.NAME = "LibMultilingualName"
LIB.VERSION = "1.2.48"

LMN.CODE_ENGLISH = "en"
LMN.CODE_JAPANESE = "jp"
LMN.CODE_GERMAN = "de"
LMN.CODE_FRENCH = "fr"
LMN.CODE_RUSSIAN = "ru"
LMN.CODE_SPANISH = "es" -- Spanish
LMN.CODE_CHINESE = "zh" -- Chinese

LMN.ALL_LANG_CODES = {}
LMN.ALL_LANG_CODES[1] = LMN.CODE_ENGLISH
LMN.ALL_LANG_CODES[2] = LMN.CODE_JAPANESE
LMN.ALL_LANG_CODES[3] = LMN.CODE_GERMAN
LMN.ALL_LANG_CODES[4] = LMN.CODE_FRENCH
LMN.ALL_LANG_CODES[5] = LMN.CODE_RUSSIAN
LMN.ALL_LANG_CODES[6] = LMN.CODE_SPANISH
LMN.ALL_LANG_CODES[7] = LMN.CODE_CHINESE

LMN.ALL_LANGUAGE_NAMES = {}
LMN.ALL_LANGUAGE_NAMES[1] = "English"--LMN.CODE_ENGLISH,
LMN.ALL_LANGUAGE_NAMES[2] = "Japanese"--LMN.CODE_JAPANESE,
LMN.ALL_LANGUAGE_NAMES[3] = "German"--LMN.CODE_GERMAN,
LMN.ALL_LANGUAGE_NAMES[4] = "French"--LMN.CODE_FRENCH,
LMN.ALL_LANGUAGE_NAMES[5] = "Russian"--LMN.CODE_RUSSIAN,
LMN.ALL_LANGUAGE_NAMES[6] = "Spanish"--LMN.CODE_SPANISH,
LMN.ALL_LANGUAGE_NAMES[7] = "Chinese"--LMN.CODE_CHINESE

function LIB.createTableOfLangCodeToYourValue(defaultValue, specificValues)
    local data = {}
    for _index, _language_name in ipairs(LMN.ALL_LANGUAGE_NAMES) do
        local _langCode = LMN.ALL_LANG_CODES[_index]
        local _value = defaultValue
        if type(specificValues) == 'table' and specificValues[_langCode] ~= nil then
            _value = specificValues[_langCode]
        end
        data[_langCode] = _value
    end

    return data
end

LMN.LOADED_LANG_CODES = {}
LMN.DUMMY_LANG_CODES = {
    ["ja"] = LMN.CODE_JAPANESE,
}

function LIB.IsLoaded(langCode)
    return contains(LMN.LOADED_LANG_CODES, langCode)
end

function LIB.GetClientLangCode()
    if clientLangCode == nil then
        clientLangCode = string.lower(GetCVar("language.2"))
    end

    return clientLangCode
end

--------
-- Register
--------

local function onLibraryLoaded(event, name)
    if (name ~= LIB.NAME) then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(LIB.NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(LIB.NAME, EVENT_ADD_ON_LOADED, onLibraryLoaded)
