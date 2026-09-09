local TT = TamrielicTongues

TT.Locale = {}

local PREFIX = "SI_TAMRIELIC_TONGUES_"

-- English establishes every ID first; matching locale files override only
-- translated entries, leaving untranslated entries in English.
---@param language string
---@param strings table<string, string>
---@param version? integer
function TT.Locale:Register(language, strings, version)
    if language ~= "en" and language ~= GetCVar("language.2") then
        return
    end

    for key, text in pairs(strings) do
        local name = PREFIX .. key
        if language == "en" then
            ZO_CreateStringId(name, text)
        else
            local id = _G[name]
            assert(id, "Unknown localization key: " .. key)
            SafeAddString(id, text, version or 1)
        end
    end
end

---@param key string
---@param ... any
---@return string
function TT.Locale:Get(key, ...)
    local id = _G[PREFIX .. key]
    assert(id, "Unknown localization key: " .. key)
    local text = GetString(id)
    if select("#", ...) == 0 then
        return text
    end
    return zo_strformat(text, ...)
end

---@param profile {id: string, name: string}
---@return string
function TT.Locale:LanguageName(profile)
    local id = _G[PREFIX .. "LANGUAGE_" .. string.upper(profile.id)]
    return id and GetString(id) or profile.name
end

---@param profile {id: string, race: string}
---@return string
function TT.Locale:RaceName(profile)
    local id = _G[PREFIX .. "RACE_" .. string.upper(profile.id)]
    return id and GetString(id) or profile.race
end
