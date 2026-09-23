-- Text lives here, not in the screens. Japanese is the original; English is the fallback for
-- every other client language, because a German player reads it more easily than kanji.
-- Keys are stable; a missing translation falls back to Japanese rather than showing a key.
PBWT = PBWT or {}
local L={}; PBWT.Locale=L
L.DEFAULT='ja'
L.strings={ja={},en={}}
function L.Detect()
    local code=GetCVar and GetCVar('language.2')
    if not code or code=='' then return L.DEFAULT end
    if code=='jp' or code=='ja' then return 'ja' end
    return L.strings[code] and code or 'en'
end
function L.Use(language)
    L.current=L.strings[language] and language or L.Detect()
    return L.current
end
function L.Language() return L.current or L.Use(L.Detect()) end
-- L(key) returns the text; extra arguments are passed to string.format.
function PBWT.L(key,...)
    local language=L.Language()
    local text=L.strings[language] and L.strings[language][key]
    if text==nil then text=L.strings[L.DEFAULT][key] end
    if text==nil then return key end
    if select('#',...)>0 then return string.format(text,...) end
    return text
end
function L.Add(language,entries)
    L.strings[language]=L.strings[language] or {}
    for key,text in pairs(entries) do L.strings[language][key]=text end
end
-- Every key the add-on asks for must exist in the original; the check runs in the tests.
function L.Missing(language)
    local missing={}
    for key in pairs(L.strings[L.DEFAULT]) do
        if L.strings[language][key]==nil then missing[#missing+1]=key end
    end
    table.sort(missing)
    return missing
end
