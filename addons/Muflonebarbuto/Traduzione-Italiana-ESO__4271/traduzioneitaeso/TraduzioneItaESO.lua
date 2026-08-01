-- CONFIGURAZIONE DEBUG: Imposta a true per vedere i messaggi di debug in giallo, false per nasconderli
local mostraDebug = false

-- Funzione helper per i messaggi di debug
local function DebugLog(...)
    if mostraDebug and type(d) == "function" then
        d(...)
    end
end

-- ===========================================================================================
-- SafeLower
-- Lua :lower() NON e' UTF-8 safe: nell'ambiente ESO tratta i byte >= 128 come
-- Windows-1252/Latin-1 e li "abbassa" individualmente, corrompendo qualsiasi
-- carattere accentato multi-byte (es. "à" = byte 195,160 diventa altri byte
-- non piu' validi in UTF-8). Questo rompe qualunque lookup case-insensitive
-- su nomi italiani con accenti (es. "Tonico al Guaranà").
-- SafeLower minuscolizza SOLO le lettere ASCII A-Z e lascia intatto tutto
-- il resto (accenti, apostrofi, simboli), byte per byte.
-- ===========================================================================================
local function SafeLower(s)
    if not s or s == "" then return s end
    -- Fast-path: se la stringa e' pura ASCII (nessun byte >= 128), :lower()
    -- nativo (C) e' sicuro al 100% (niente accenti multi-byte da corrompere)
    -- ed e' ordini di grandezza piu' veloce del loop byte-per-byte sottostante.
    -- La stragrande maggioranza dei nomi oggetto/zone non ha accenti, quindi
    -- questo evita il loop lento nel caso comune.
    if not s:find("[\128-\255]") then
        return s:lower()
    end
    local out = {}
    for i = 1, #s do
        local b = s:byte(i)
        if b >= 65 and b <= 90 then
            out[i] = string.char(b + 32)
        else
            out[i] = s:sub(i, i)
        end
    end
    return table.concat(out)
end

-- ===========================================================================================
-- SafeTrim / SafeCollapseSpaces
-- Anche il pattern Lua %s (whitespace) NON e' UTF-8 safe in questo ambiente: il byte
-- 0xA0 (160) - che e' il SECONDO byte di quasi tutte le vocali accentate italiane in
-- UTF-8 (a=195,160  e=195,168  i=195,172  o=195,178  u=195,185) - viene classificato
-- come spazio bianco. Un gsub("%s+$","") su una stringa che finisce con una vocale
-- accentata (es. "Guaranà") taglia via quell'ultimo byte, lasciando una stringa UTF-8
-- troncata/invalida (bug diagnosticato su "Tonico al Guaranà" -> "tonico al guaranç").
-- SafeTrim/SafeCollapseSpaces operano SOLO sui whitespace ASCII veri: spazio, tab, CR, LF.
-- ===========================================================================================
local function SafeTrim(s)
    if not s or s == "" then return s end
    return (s:gsub("^[ \t\r\n]+", ""):gsub("[ \t\r\n]+$", ""))
end

local function SafeCollapseSpaces(s)
    if not s or s == "" then return s end
    return (s:gsub("[ \t]+", " "))
end

-- TraduzioneItaESO.lua
-- 1) Salviamo subito le tabelle dati caricate dal manifest prima che vengano sovrascritte
local _savedZoneTrans = type(TraduzioneItaESO)=="table" and TraduzioneItaESO.ZoneTranslations  or nil
local _savedNPCTrans  = type(TraduzioneItaESO)=="table" and TraduzioneItaESO.NPCTranslations   or nil
local _savedItemTrans = type(TraduzioneItaESO)=="table" and TraduzioneItaESO.ItemsTranslations  or nil

-- 2) assicuriamoci che esista già la tabella globale
TraduzioneItaESO = TraduzioneItaESO or {}
local addon = TraduzioneItaESO

local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        DebugLog("TraduzioneItaESO ERROR: " .. tostring(result))
        return nil
    end
    return result
end

local function UpdateMapName()
    if type(TraduzioneItaESO.UpdateMapName) == "function" and
       TraduzioneItaESO.UpdateMapName ~= UpdateMapName then
        TraduzioneItaESO.UpdateMapName()
    end
end

local function SafeEventHandler(eventCode, ...)
    SafeCall(UpdateMapName)
end

addon.name = "TraduzioneItaESO"
addon.displayName = "Traduzione Italiana ESO"
addon.version = "2.0.5-cleanup"
addon.pinType = "TraduzioneItaESOTamrielMapPinType"
addon.mapPinSnapToPins = false
addon.locations = {
-- Zone cosmiche: coordinate blobX/blobY trovate con /trackmouse sulla mappa Aurbis
[1] = { name = "Tamriel", alliance = 999, cosmic = true },
[2] = { name = "Glenumbra", cityName = "Daggerfall", alliance = ALLIANCE_DAGGERFALL_COVENANT, zoneOrder = 2, poi = 62 },
[3] = { name = "Rivenspire", cityName = "Shornhelm", alliance = ALLIANCE_DAGGERFALL_COVENANT, zoneOrder = 4, poi = 55, labelY = -0.0125 },
[4] = { name = "Stormhaven", cityName = "Wayrest", alliance = ALLIANCE_DAGGERFALL_COVENANT, zoneOrder = 3, poi = 56 },
[5] = { name = "Alik'r Desert", cityName = "Sentinel", alliance = ALLIANCE_DAGGERFALL_COVENANT, zoneOrder = 5, poi = 43, labelX = 0.01 },
[6] = { name = "Bangkorai", cityName = "Evermore", alliance = ALLIANCE_DAGGERFALL_COVENANT, zoneOrder = 6, poi = 33, labelY = 0.02 },
[7] = { name = "Grahtwood", cityName = "Elden Root", alliance = ALLIANCE_ALDMERI_DOMINION, zoneOrder = 3, poi = 214, labelX = -0.0125, labelY = -0.03 },
[8] = { name = "Malabal Tor", cityName = "Velyn Harbor", alliance = ALLIANCE_ALDMERI_DOMINION, zoneOrder = 5, poi = 102 },
[9] = { name = "Shadowfen", cityName = "Stormhold", alliance = ALLIANCE_EBONHEART_PACT, zoneOrder = 4, poi = 48 },
[10] = { name = "Deshaan", cityName = "Mournhold", alliance = ALLIANCE_EBONHEART_PACT, zoneOrder = 3, poi = 28 },
[11] = { name = "Stonefalls", cityName = "Davon's Watch", alliance = ALLIANCE_EBONHEART_PACT, zoneOrder = 2, poi = 65, labelY = 0.035 },
[12] = { name = "The Rift", cityName = "Riften", alliance = ALLIANCE_EBONHEART_PACT, zoneOrder = 6, poi = 109 },
[13] = { name = "Eastmarch", cityName = "Windhelm", alliance = ALLIANCE_EBONHEART_PACT, zoneOrder = 5, poi = 87, labelY = 0.0125 },
[14] = { name = "Cyrodiil", alliance = 100, blobX = 0.541, blobY = 0.446, cosmic = true, tamriel = true },
[15] = { name = "Auridon", cityName = "Vulkhel Guard", alliance = ALLIANCE_ALDMERI_DOMINION, zoneOrder = 2, poi = 177, labelX = -0.0125, labelY = -0.025 },
[16] = { name = "Greenshade", cityName = "Marbruk", alliance = ALLIANCE_ALDMERI_DOMINION, zoneOrder = 4, poi = 143, labelY = -0.025 },
[17] = { name = "Reaper's March", cityName = "Rawl'kha", alliance = ALLIANCE_ALDMERI_DOMINION, zoneOrder = 6, poi = 162 },
[18] = { name = "Bal Foyen", cityName = "Dhalmora", alliance = ALLIANCE_EBONHEART_PACT, zoneOrder = 1, poi = 173, offsetX = -0.05, offsetY = -0.1, labelX = -0.0175, labelY = -0.03 },
[19] = { name = "Stros M'Kai", cityName = "Port Hunding", alliance = ALLIANCE_DAGGERFALL_COVENANT, zoneOrder = 1, poi = 138 },
[20] = { name = "Betnikh", cityName = "Stonetooth Fortress", alliance = ALLIANCE_DAGGERFALL_COVENANT, zoneOrder = 1, poi = 181 },
[21] = { name = "Khenarthi's Roost", cityName = "Mistral", alliance = ALLIANCE_ALDMERI_DOMINION, zoneOrder = 1, poi = 142 },
[22] = { name = "Bleakrock Isle", cityName = "Bleakrock Village", alliance = ALLIANCE_EBONHEART_PACT, zoneOrder = 1, poi = 172, offsetX = 0, labelY = -0.020 },
[23] = { name = "Coldharbour", cityName = "The Hollow City", alliance = 100, cosmic = true, blobX = 0.13, blobY = 0.36 },
[24] = { name = "Aurbis", alliance = 999 },
[25] = { name = "Craglorn", cityName = "Belkarth", alliance = 100, poi = 220, labelX = -0.0125, labelY = -0.025 },
[26] = { name = "Imperial City", alliance = 100, labelX = -0.025 },
[27] = { name = "Wrothgar", cityName = "Orsinium", alliance = ALLIANCE_DAGGERFALL_COVENANT, poi = 244, labelX = 0.0125, labelY = -0.0125 },
[28] = { name = "Hew's Bane", cityName = "Abah's Landing", alliance = ALLIANCE_DAGGERFALL_COVENANT, poi = 255 },
[29] = { name = "Gold Coast", cityName = "Anvil", alliance = 100, poi = 251, labelX = 0.0125, labelY = -0.0125 },
[30] = { name = "Vvardenfell", cityName = "Vivec City", alliance = ALLIANCE_EBONHEART_PACT, poi = 284, offsetX = 0.005, offsetY = 0.005 },
[31] = { name = "Clockwork City", cityName = "Brass Fortress", alliance = ALLIANCE_EBONHEART_PACT, cosmic = true, blobX = 0.40, blobY = 0.88 },
[32] = { name = "Summerset", cityName = "Alinor", alliance = ALLIANCE_ALDMERI_DOMINION, poi = 355 },
[33] = { name = "Artaeum", cityName = "Artaeum", alliance = 100, cosmic = true, blobX = 0.72, blobY = 0.20 },
[34] = { name = "Murkmire", cityName = "Lilmoth", alliance = ALLIANCE_EBONHEART_PACT, poi = 374 },
[35] = { name = "Norg-Tzel", alliance = ALLIANCE_EBONHEART_PACT, hidden = true },
[36] = { name = "Northern Elsweyr", cityName = "Rimmen", alliance = ALLIANCE_ALDMERI_DOMINION, poi = 382, labelY = 0.0125 },
[37] = { name = "Southern Elsweyr", cityName = "Senchal", alliance = ALLIANCE_ALDMERI_DOMINION, poi = 402, labelY = -0.0125 },
[38] = { name = "Western Skyrim", cityName = "Solitude", alliance = ALLIANCE_EBONHEART_PACT, poi = 426 },
[39] = { name = "Blackreach: Greymoor Caverns", alliance = ALLIANCE_EBONHEART_PACT },
[40] = { name = "Blackreach", alliance = 999 },
[41] = { name = "Blackreach: Arkthzand Cavern", alliance = ALLIANCE_EBONHEART_PACT },
[42] = { name = "The Reach", cityName = "Markarth", alliance = ALLIANCE_EBONHEART_PACT, poi = 449, labelX = 0.025 },
[43] = { name = "Blackwood", cityName = "Leyawiin", alliance = 999, poi = 458 },
[44] = { name = "Fargrave", cityName = "The Brass Goblet", alliance = 999, cosmic = true, blobX = 0.72, blobY = 0.82 },
[45] = { name = "The Deadlands", alliance = 999, cosmic = true, blobX = 0.83, blobY = 0.62 },
[46] = { name = "High Isle", cityName = "Gonfalon Bay", alliance = ALLIANCE_DAGGERFALL_COVENANT, poi = 513, blobX = 0.058, blobY = 0.588 },
[47] = { name = "Fargrave City", alliance = 999, hidden = true },
[48] = { name = "Galen", cityName = "Vastyr", alliance = ALLIANCE_DAGGERFALL_COVENANT, poi = 529, blobX = 0.055, blobY = 0.561 },
[49] = { name = "Telvanni Peninsula", cityName = "Necrom", alliance = ALLIANCE_EBONHEART_PACT, poi = 536, labelX = 0.0125, labelY = -0.005 },
[50] = { name = "Apocrypha", cityName = "Cipher's Midden", alliance = 999, cosmic = true, blobX = 0.310, blobY = 0.199 },
[51] = { name = "Eyevea", cityName = "Eyevea", alliance = 999, cosmic = true, blobX = 0.13, blobY = 0.59 },
[52] = { name = "West Weald", cityName = "Skingrad", alliance = 999, poi = 558, cosmic = false, blobX = 0.383, blobY = 0.520 },
[53] = { name = "Eastern Solstice", cityName = "Eastern Solstice", alliance = 999, poi = 592 },
}

addon.color = {
    [ALLIANCE_DAGGERFALL_COVENANT] = ZO_ColorDef:New(0, 0.25, 1, 0.2),
    [ALLIANCE_ALDMERI_DOMINION] = ZO_ColorDef:New(1, 1, 0, 0.15),
    [ALLIANCE_EBONHEART_PACT] = ZO_ColorDef:New(1, 0, 0, 0.15)
}
addon.defaultColor = ZO_ColorDef:New(0, 0, 0, 0.25)
addon.transparentColor = ZO_ColorDef:New(0, 0, 0, 0)
addon.baseGameColor = ZO_ColorDef:New(0.5, 1, 0.5, 0.25)
addon.dlcGameColor = ZO_ColorDef:New(0.25, 0.25, 0.75, 0.35)

local em = GetEventManager()
local lookup = { fonts = {}, fontSizes = {}, colors = {}, fontNames = {}, fontValues = {}, nameToFont = {}, colorNames = {}, colorValues = {}, nameToColor = {} }

function addon:ApplyOpacity()
    local opacity = self.savedVars.opacity / 100
    self.color[ALLIANCE_DAGGERFALL_COVENANT]:SetAlpha(opacity * 1.25)
    self.color[ALLIANCE_ALDMERI_DOMINION]:SetAlpha(opacity)
    self.color[ALLIANCE_EBONHEART_PACT]:SetAlpha(opacity)
    self.defaultColor:SetAlpha(opacity)
    self.transparentColor:SetAlpha(opacity)
    self.baseGameColor:SetAlpha(opacity)
    self.dlcGameColor:SetAlpha(opacity * 1.2)
end

function addon:ApplyColors()
    if self.savedVars.color == "BaseGame" then
        self.GetColor = self.GetBaseGameColor
        self.GetDefaultColor = self.GetBaseGameColor
    elseif self.savedVars.color == "None" then
        self.GetColor = self.GetNoColor
        self.GetDefaultColor = self.GetNoColor
    else
        self.GetColor = self.GetAllianceColor
        self.GetDefaultColor = self.AllianceDefaultColor
    end
end

local function UpdateUIVisibility(hidden)
    if not addon.savedVars.enableUI then return end
    local uiControl = WINDOW_MANAGER:GetControlByName("TraduzioneItaESOUI")
    if uiControl then
        if addon.savedVars.hideDuringGameplay then
            uiControl:SetHidden(not hidden)
        else
            uiControl:SetHidden(false)
        end
    end
end

local function NormalizeName(s)
    if not s then return "" end
    s = s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    s = s:gsub("%s*%b()", "")
    s = s:gsub("%^i([%a%d_%-]+)", "||ITA_MARKER_%1||")
    s = s:gsub("%^[%a%d_%-]+", "")
    s = s:gsub("||ITA_MARKER_([%a%d_%-]+)||", "^i%1")
    s = SafeTrim(s)
    s = SafeLower(s)
    s = SafeCollapseSpaces(s)
    return s
end

-- ===========================================================================================
-- ItalianContraction
-- ===========================================================================================
local function ItalianContraction(marker, noun, isProper)
    if not marker then return nil, nil end

    marker = tostring(marker):lower()
    marker = marker:gsub("^i", "")
    marker = marker:gsub("[;%s]+", "-")
    marker = marker:gsub("%-+", "-")
    marker = marker:gsub("^%-", ""):gsub("%-$", "")

    local simpleMap = {
        f   = { gender = "f", number = "s" },
        m   = { gender = "m", number = "s" },
        mp  = { gender = "m", number = "p" },
        nps = { gender = "m", number = "p", scons = true },
        np  = { gender = "m", number = "p", vowel = true },
        pm  = { gender = "m", number = "p" },
        fp  = { gender = "f", number = "p" },
        pf  = { gender = "f", number = "p" },
        ma  = { gender = "m", number = "s", vowel = true },
        fa  = { gender = "f", number = "s", vowel = true },
        mh  = { gender = "m", number = "s", hmut = true },
        fh  = { gender = "f", number = "s", hmut = true },
        fs  = { gender = "f", number = "s", scons = true },
        ms  = { gender = "m", number = "s", scons = true },
        mz  = { gender = "m", number = "s", zgn = true },
        fz  = { gender = "f", number = "s", zgn = true },
        md  = { gender = "m", number = "s" },
        fd  = { gender = "f", number = "s" },
    }

    local flags = {}
    if simpleMap[marker] then
        local m = simpleMap[marker]
        if m.gender then flags[m.gender] = true end
        if m.number then flags[m.number] = true end
        if m.vowel  then flags["vowel"]  = true end
        if m.hmut   then flags["hmut"]   = true end
        if m.scons  then flags["scons"]  = true end
        if m.zgn    then flags["zgn"]    = true end
    else
        for part in marker:gmatch("([^%-]+)") do
            if part == "s" then flags["scons"] = true
            elseif part == "z" then flags["zgn"] = true
            elseif part == "a" then flags["vowel"] = true
            elseif part == "h" then flags["hmut"] = true
            else flags[part] = true end
        end
    end

    if isProper or flags["proper"] then
        flags["noArt"] = true
        flags["proper"] = true
    end

    local gender, number

    if flags["md"] or flags["fd"] then
        gender = flags["md"] and "m" or "f"
        number = "s"
    elseif flags["fp"] or flags["pf"] or (flags["f"] and flags["p"]) then
        gender, number = "f", "p"
    elseif flags["pm"] or flags["mp"] or flags["np"] or flags["nps"] or (flags["m"] and flags["p"]) then
        gender, number = "m", "p"
    elseif flags["m"] then
        gender = "m"
    elseif flags["f"] then
        gender = "f"
    end

    if not gender then gender = "m" end
    if not number then number = flags["p"] and "p" or "s" end

    if flags["invar"] or flags["noArt"] then return nil, nil end

    noun = SafeTrim(tostring(noun or ""))
    local cleanNoun = noun:gsub("^[^%a]+", "")
    local first = (cleanNoun and #cleanNoun > 0) and cleanNoun:sub(1,1):lower() or ""

    local function isVowel(ch)
        if not ch or ch == "" then return false end
        return ch:match("^[aeiouàèéìòùáíóúäëïöü]") ~= nil
    end

    local function startsWithSpecialConsonant(s)
        if not s or #s < 1 then return false end
        local a = s:sub(1,1):lower()
        local b = (#s >= 2) and s:sub(2,2):lower() or ""
        if a == "z" then return true end
        if a == "g" and b == "n" then return true end
        if a == "p" and (b == "s" or b == "n") then return true end
        if a == "s" and b ~= "" and not isVowel(b) then return true end
        if a == "x" or a == "y" then return true end
        return false
    end

    local forcedVowel = flags["vowel"] or flags["hmut"]
    local forcedScons = flags["scons"] or flags["zgn"]
    local cls_vowel = forcedVowel or isVowel(first)
    local cls_scons = forcedScons or startsWithSpecialConsonant(cleanNoun)

    local article
    if gender == "f" then
        if number == "p" then article = "le"
        else article = cls_vowel and "l'" or "la" end
    else
        if number == "p" then
            article = (cls_scons or cls_vowel) and "gli" or "i"
        else
            if cls_vowel then article = "l'"
            elseif cls_scons then article = "lo"
            else article = "il" end
        end
    end

    local contractions = {
        ["il"] = "del", ["lo"] = "dello", ["l'"] = "dell'",
        ["la"] = "della", ["i"] = "dei", ["gli"] = "degli", ["le"] = "delle"
    }
    local contraction = contractions[article] or ("di " .. (article or ""))
    return contraction, article
end

-- ===========================================================================================
-- ProcessMarkers
-- ===========================================================================================
local function ProcessMarkers(name, debug)
    if not name or name == "" then return name, {} end

    local function dlog(...)
        if debug and type(d) == "function" then d(...) end
    end

    local function trim(s)
        return SafeTrim(s)
    end

    local function extractNextToken(text)
        if not text or text == "" then return "" end
        local cleaned = text:gsub("^%s*%^[iI][%a%d_%-]+%s*", "")
        cleaned = cleaned:gsub("^%s*di%s+", "")
        cleaned = cleaned:gsub("^%s*del%s+", "")
        cleaned = cleaned:gsub("^%s*della%s+", "")
        cleaned = cleaned:gsub("^%s*dello%s+", "")
        cleaned = cleaned:gsub("^%s*dei%s+", "")
        cleaned = cleaned:gsub("^%s*degli%s+", "")
        cleaned = cleaned:gsub("^%s*delle%s+", "")
        local token = cleaned:match("^%s*([%w'-]+)")
        return token or ""
    end

    local function extractFirstWord(text)
        if not text or text == "" then return "" end
        local trimmed = trim(text)
        local first = trimmed:match("^([%w'-]+)")
        return first or ""
    end

    -- FIX: prima parola alfabetica reale, esclude numeri romani come "IV", "V", ecc.
    local function faw(text)
        if not text or text == "" then return "" end
        for tok in text:gmatch("[%w'%-]+") do
            if tok:match("^%a") and not tok:match("^[IVXLCDMivxlcdm]+$") then
                return tok
            end
        end
        return ""
    end

    local function joinArticleAndNoun(article, noun)
        if not article or article == "" then return noun end
        if not noun or noun == "" then return article end
        if article:sub(-1) == "'" then return article .. noun
        else return article .. " " .. noun end
    end

    local original = tostring(name)
    local prefix = original:match("^(%s*%-+%s*)") or ""
    local suffix = original:match("(%s*%-+%s*)$") or ""

    local center = original
    if prefix ~= "" then center = center:sub(#prefix + 1) end
    if suffix ~= "" and #center >= #suffix then
        center = center:sub(1, #center - #suffix)
    end
    center = trim(center)

    local originalCenter = center

    local s = center:gsub("%^[iI]([%a%d_%-]+)%-*", function(marker)
        return "^i" .. marker:gsub("%-+$", "")
    end)

    local foundMarkers = {}
    local startPos = 1

    while true do
        local markerStart, markerEnd, space, rawMarker = s:find("(%s*)%^[iI]([%a%d_%-]+)", startPos)
        if not markerStart then break end

        local cleanMarker = rawMarker:gsub("%-+$", ""):lower()
        local isProper = rawMarker:match("%u") ~= nil
        foundMarkers[cleanMarker] = true

        local beforeMarker = s:sub(1, markerStart - 1)
        local afterMarker  = s:sub(markerEnd + 1)

        dlog(string.format("ProcessMarkers: marker='%s' before='%s' after='%s'", cleanMarker, beforeMarker, afterMarker))

        local noun = extractNextToken(afterMarker)
        local nounForPhonetics

        if noun ~= "" then
            nounForPhonetics = noun
        else
            nounForPhonetics = extractFirstWord(originalCenter)
        end

        local lowerBefore = beforeMarker:lower()
        local lastDiStart, lastDiEnd
        local searchPos = 1

        while true do
            local diStart, diEnd = lowerBefore:find(" di ", searchPos, true)
            if not diStart then break end
            lastDiStart, lastDiEnd = diStart, diEnd
            searchPos = diEnd + 1
        end

        if not lastDiStart and lowerBefore:sub(1, 3) == "di " then
            lastDiStart, lastDiEnd = 1, 3
        end

        if lastDiStart then
            local betweenDiAndMarker = trim(beforeMarker:sub(lastDiEnd + 1))

            if betweenDiAndMarker == "" then
                local contraction, article = ItalianContraction(cleanMarker, nounForPhonetics, isProper)

                if contraction then
                    local beforeDi = (lastDiStart == 1) and "" or beforeMarker:sub(1, lastDiStart - 1)
                    local restTrimmed = trim(afterMarker)
                    local result = beforeDi
                    if result ~= "" then result = result .. " " end
                    result = result .. joinArticleAndNoun(contraction, restTrimmed)
                    s = result
                    originalCenter = result
                    startPos = #beforeDi + 1 + #contraction
                else
                    local restTrimmed = trim(afterMarker)
                    s = beforeMarker .. (restTrimmed ~= "" and restTrimmed or "")
                    originalCenter = s
                    startPos = #beforeMarker + 1
                end
            else
                local _, article = ItalianContraction(cleanMarker, nounForPhonetics, isProper)

                if article then
                    local restTrimmed = trim(afterMarker)
                    if restTrimmed == "" then
                        local trimmedBefore = trim(beforeMarker)
                        s = joinArticleAndNoun(article, trimmedBefore)
                        originalCenter = s
                        startPos = #article + 1
                    else
                        s = beforeMarker .. joinArticleAndNoun(article, restTrimmed)
                        originalCenter = s
                        startPos = #beforeMarker + #article + 1
                    end
                else
                    local restTrimmed = trim(afterMarker)
                    s = trim(beforeMarker) .. (restTrimmed ~= "" and (" " .. restTrimmed) or "")
                    originalCenter = s
                    startPos = #beforeMarker + 1
                end
            end
        else
            local trimmedBefore = trim(beforeMarker)
            local restTrimmed   = trim(afterMarker)
            local phoneticWord  = faw(trimmedBefore)
            if phoneticWord == "" then phoneticWord = faw(restTrimmed) end
            if phoneticWord == "" then phoneticWord = nounForPhonetics end

            local _, article = ItalianContraction(cleanMarker, phoneticWord, isProper)

            if article then
                if trimmedBefore == "" then
                    s = joinArticleAndNoun(article, restTrimmed)
                    originalCenter = s
                    startPos = #article + 1
                else
                    local joined = joinArticleAndNoun(article, trimmedBefore)
                    s = restTrimmed ~= "" and (joined .. " " .. restTrimmed) or joined
                    originalCenter = s
                    startPos = #article + 1
                end
            else
                s = trimmedBefore .. (restTrimmed ~= "" and (" " .. restTrimmed) or "")
                originalCenter = s
                startPos = #trimmedBefore + 1
            end
        end
    end

    s = s:gsub("%^[iI][%a%d_%-]+", "")
    s = SafeCollapseSpaces(SafeTrim(s))
    s = s:gsub("'%s+", "'")

    local finalResult = prefix .. s .. suffix
    dlog(string.format("ProcessMarkers: final='%s'", finalResult))
    return finalResult, foundMarkers
end

_G.ProcessMarkers = ProcessMarkers

-- ===========================================================================================
-- Cache per ProcessMarkers
-- Ogni nome con marcatori ^i viene elaborato una sola volta; le chiamate successive
-- (tipicamente decine per frame durante lo scroll dell'inventario) restituiscono
-- immediatamente il risultato già calcolato senza rieseguire tutta la logica.
-- La cache viene svuotata al reload UI, che è il ciclo di vita naturale dei nomi.
-- ===========================================================================================
local _markersCache     = {}
local _markersCacheSize = 0
local _MARKERS_CACHE_MAX = 2000  -- limite conservativo; un inventario pieno ha ~200-300 slot

local function ProcessMarkersCache(name, debug)
    -- Passa direttamente se non ci sono marcatori (fast-path già in ProcessMarkers,
    -- ma evitare anche il lookup in tabella quando sicuramente non serve)
    if not name or name == "" then return name, {} end
    -- debug=true bypassa la cache per non nascondere messaggi diagnostici
    if debug then return ProcessMarkers(name, debug) end

    local cached = _markersCache[name]
    if cached then return cached end

    local ok, result = pcall(ProcessMarkers, name)
    local finalResult = (ok and result) and result or name

    -- Evita crescita illimitata: reset semplice quando si supera il limite.
    -- Un reset è accettabile perché avviene al massimo poche volte per sessione.
    if _markersCacheSize >= _MARKERS_CACHE_MAX then
        _markersCache     = {}
        _markersCacheSize = 0
    end
    _markersCache[name]  = finalResult
    _markersCacheSize    = _markersCacheSize + 1
    return finalResult
end

local function PreprocessTable(tbl)
    if not tbl then return end
    for k, v in pairs(tbl) do
        if type(v) == "string" and v:find("%^[iI]") then
            local ok, cleaned = pcall(ProcessMarkers, v)
            if ok and cleaned and cleaned ~= "" then
                tbl[k] = cleaned
            end
        end
    end
end


-- ===========================================================================================
-- CleanMarkers
-- ===========================================================================================
local function CleanMarkers(text)
    if not text or type(text) ~= "string" then return text end
    if not text:find("%^[iI]") then return text end
    local ok, result = pcall(ProcessMarkers, text)
    if ok and result then return result end
    return text:gsub("%^[iI][%a%d_%-]+", "")
end

-- ===========================================================================================
-- ApplySafeStrings
-- ===========================================================================================
local applySafeStringsDone = false
local function ApplySafeStrings()
    if applySafeStringsDone then return end
    applySafeStringsDone = true

    local count, skipped = 0, 0
    for id = 1, 100000 do
        local ok, text = pcall(GetString, id)
        if ok and type(text) == "string" and text ~= "" and text:find("%^[iI]") then
            local ok2, cleaned = pcall(ProcessMarkers, text)
            if ok2 and cleaned and cleaned ~= text then
                local ok3 = pcall(SafeAddString, id, cleaned, 1)
                if ok3 then count = count + 1 else skipped = skipped + 1 end
            else
                local stripped = SafeCollapseSpaces(SafeTrim(text:gsub("%^[iI][%a%d_%-]+", "")))
                if stripped ~= text then
                    local ok3 = pcall(SafeAddString, id, stripped, 1)
                    if ok3 then count = count + 1 else skipped = skipped + 1 end
                end
            end
        end
    end
    DebugLog(string.format("[TraduzioneItaESO] ApplySafeStrings: %d modificate, %d skipped", count, skipped))
end

-- ===========================================================================================
-- Hook AddLine su tutti i tooltip
-- ===========================================================================================
local tooltipAddLineHooked = false
local function HookTooltipAddLines()
    if tooltipAddLineHooked then return end
    tooltipAddLineHooked = true

    local tooltips = {
        ItemTooltip, PopupTooltip,
        ComparativeTooltip1, ComparativeTooltip2,
        InformationTooltip, ZO_Tooltip,
    }
    for _, name in ipairs({
        "ZO_GamepadTooltip", "ZO_ItemTooltip",
        "ZO_InventoryTooltip", "ZO_MapTooltip",
    }) do
        local ctrl = _G[name]
        if ctrl then table.insert(tooltips, ctrl) end
    end

    for _, tooltip in ipairs(tooltips) do
        if tooltip and type(tooltip.AddLine) == "function" and not tooltip.__PMAddLineHooked then
            tooltip.__PMAddLineHooked = true
            local origAddLine = tooltip.AddLine
            tooltip.AddLine = function(self, text, ...)
                if type(text) == "string" and text:find("%^[iI]") then
                    text = CleanMarkers(text)
                end
                return origAddLine(self, text, ...)
            end
        end
    end
    DebugLog("[TraduzioneItaESO] HookTooltipAddLines completato")
end

-- ===========================================================================================
-- Hook lista missioni
-- ===========================================================================================
local function SanitizeQuestListEntry(control)
    if not control or not control.GetText or not control.SetText then return end
    local text = control:GetText()
    if text and (text:find("%^i") or text:find("%^I")) then
        control:SetText(ProcessMarkers(text))
    end
end

local function HookQuestListTree()
    local tree = ZO_QuestJournalNavigationTree
    if not tree then return end
    local function HookTreeEntry(control, data, open)
        SanitizeQuestListEntry(control:GetNamedChild("Label"))
    end
    tree:RegisterCallback("TreeEntrySetup", HookTreeEntry)
end

local function HookQuestListLabels()
    local container = ZO_QuestJournalNavigationContainerScrollChildContainer
    if not container then return end
    local numChildren = container:GetNumChildren()
    for i = 1, numChildren do
        local entry = container:GetChild(i)
        if entry then
            local label = entry:GetNamedChild("Label")
            if label and not label.__TradItaHooked then
                label.__TradItaHooked = true
                ZO_PostHook(label, "SetText", function(self, text)
                    if text and (text:find("%^i") or text:find("%^I")) then
                        local cleaned = ProcessMarkers(text)
                        if cleaned and cleaned ~= text then
                            label.__TradItaHooked = nil
                            self:SetText(cleaned)
                            label.__TradItaHooked = true
                        end
                    end
                end)
            end
        end
    end
end

EVENT_MANAGER:RegisterForEvent("TradItaESO_QuestListUpdated", EVENT_QUEST_LIST_UPDATED, function()
    zo_callLater(HookQuestListLabels, 50)
end)

-- ===========================================================================================
-- LoadTranslationTable
-- ===========================================================================================
local function LoadTranslationTable()
    addon.translationTable = {}
    addon.reverseTable = {}
    addon.npcTable = {}
    addon.npcReverseTable = {}

    local zoneTranslations = addon.ZoneTranslations or {}

    local function stripTag(s)
        if not s then return s end
        return (s:gsub("%s*%^[a-zA-Z0-9_%-]+", ""))
    end

    for k, v in pairs(zoneTranslations) do
        if type(k) == "string" and type(v) == "string" then
            local kClean = stripTag(k)
            local vClean = stripTag(v)
            local kNorm = NormalizeName(kClean)
            local vNorm = NormalizeName(vClean)
            if kClean ~= "" and vClean ~= "" then
                addon.translationTable[kNorm] = vClean
                addon.reverseTable[vClean] = k
            end
            addon.translationTable[vNorm] = kClean
            addon.reverseTable[kClean] = v
        end
    end

    -- Caricamento NPCTranslations
    local count = 0
    for k, v in pairs(addon.NPCTranslations or {}) do
        if type(k) == "string" and type(v) == "string" then
            local itClean = stripTag(k)
            local enClean = stripTag(v)
            local itDisplay = itClean
            if k:find("%^[iI]") then
                local ok, pm = pcall(ProcessMarkers, k)
                if ok and pm and pm ~= "" then itDisplay = pm end
            end
            if itClean ~= "" and enClean ~= "" then
                addon.npcTable[NormalizeName(itClean)] = { en = enClean, itDisplay = itDisplay }
                addon.npcReverseTable[NormalizeName(enClean)] = { it = itDisplay, itRaw = k }
            end
            count = count + 1
        end
    end
    DebugLog(string.format("[TraduzioneItaESO] NPC caricate: %d voci", count))
end

local function SetLanguage(lang)
    if lang ~= GetCVar("language.2") then
        SetCVar("IgnorePatcherLanguageSetting", 1)
        SetCVar("language.2", lang)
        ReloadUI()
    end
end

local function ShowLanguageNotification(lang)
    if not addon.savedVars.showNotifications then return end
    local texturePath = lang == "en" and "/TraduzioneItaESO/textures/flag_en.dds" or "/TraduzioneItaESO/textures/flag_it.dds"
    local message = lang == "en" and "Lingua impostata su Inglese" or "Lingua impostata su Italiano"
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, string.format("|t24:24:%s|t %s", texturePath, message))
end

local function RefreshUI()
    SafeCall(function()
        local uiControl = WINDOW_MANAGER:GetControlByName("TraduzioneItaESOUI")
        if not uiControl then
            uiControl = WINDOW_MANAGER:CreateTopLevelWindow("TraduzioneItaESOUI")
            uiControl:SetDimensions(68, 32)
            uiControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, addon.savedVars.offsetX, addon.savedVars.offsetY)
            uiControl:SetMovable(true)
            uiControl:SetMouseEnabled(true)
            uiControl:SetHandler("OnMoveStop", function()
                addon.savedVars.offsetX = uiControl:GetLeft()
                addon.savedVars.offsetY = uiControl:GetTop()
            end)
        end
        local flags = {"en", "it"}
        for i, flagCode in ipairs(flags) do
            local flagControl = WINDOW_MANAGER:GetControlByName("TraduzioneItaESO_FlagControl_" .. flagCode)
            if not flagControl then
                flagControl = WINDOW_MANAGER:CreateControl("TraduzioneItaESO_FlagControl_" .. flagCode, uiControl, CT_BUTTON)
                flagControl:SetDimensions(24, 24)
                flagControl:SetAnchor(LEFT, uiControl, LEFT, 8 + (i-1) * 32, 4)
                flagControl:SetNormalTexture("/TraduzioneItaESO/textures/flag_" .. flagCode .. ".dds")
                flagControl:SetPressedTexture("/TraduzioneItaESO/textures/flag_" .. flagCode .. ".dds")
                flagControl:SetMouseOverTexture("/TraduzioneItaESO/textures/flag_" .. flagCode .. ".dds")
                flagControl:SetDisabledTexture("/TraduzioneItaESO/textures/flag_" .. flagCode .. ".dds")
                flagControl:SetClickSound("Click")
                flagControl:SetHandler("OnClicked", function(self, button)
                    if button == MOUSE_BUTTON_INDEX_LEFT then
                        addon.savedVars.language = flagCode
                        ShowLanguageNotification(flagCode)
                        SetLanguage(flagCode)
                    end
                end)
            end
            flagControl:SetHidden(false)
            flagControl:SetAlpha(addon.savedVars.language == flagCode and 1.0 or 0.7)
        end
        UpdateUIVisibility(IsReticleHidden())
    end)
end

-- ===========================================================================================
-- ColorizeEnglish e GetBilingualText
-- ===========================================================================================
local function ColorizeEnglish(text)
    if not text or text == "" then return text end
    local hex = addon.savedVars.bilingualColor or "AAAFCB"
    return "|c" .. hex .. text .. "|r"
end

local function GetBilingualText(originalText)
    if not addon.savedVars.bilingualPOI or not originalText or originalText == "" then
        return originalText
    end
    if originalText:find("|c") then return originalText end
    local normalized = NormalizeName(originalText)
    local englishName = addon.translationTable[normalized] or originalText
    local italianOriginal = addon.reverseTable and addon.reverseTable[englishName] or originalText
    local cleaned = ProcessMarkers(italianOriginal)
    cleaned = cleaned:gsub("%^%a+", "")
    if englishName and cleaned ~= englishName and cleaned ~= "" then
        if addon.savedVars.bilingualNewLine then
            return cleaned .. "\n" .. ColorizeEnglish(englishName)
        else
            return cleaned .. " / " .. ColorizeEnglish(englishName)
        end
    else
        return cleaned
    end
end

-- ===========================================================================================
-- GetBilingualNPCName
-- ===========================================================================================
local function GetBilingualNPCName(rawName, withDashes)
    if not rawName or rawName == "" then return rawName end

    local itDisplay = rawName
    if rawName:find("%^[iI]") then
        local ok, pm = pcall(ProcessMarkers, rawName)
        if ok and pm and pm ~= "" then itDisplay = pm end
    end
    itDisplay = SafeCollapseSpaces(SafeTrim(itDisplay:gsub("%^%a+", "")))

    local npcEntry = nil
    if addon.npcTable then
        local rawClean = SafeCollapseSpaces(SafeTrim(rawName:gsub("%^%a[%a%d_%-]*", "")))
        npcEntry = addon.npcTable[NormalizeName(rawClean)]
        if not npcEntry then
            npcEntry = addon.npcTable[NormalizeName(itDisplay)]
        end
    end

    if not npcEntry then return itDisplay end

    local enName = npcEntry.en or itDisplay
    local lang = GetCVar and GetCVar("language.2") or "it"
    if lang == "en" then return enName end

    if addon.savedVars and addon.savedVars.bilingualNPCNames then
        if addon.savedVars.bilingualNewLine then
            if withDashes then
                return itDisplay .. "-\n-" .. ColorizeEnglish(enName)
            else
                return itDisplay .. "\n" .. ColorizeEnglish(enName)
            end
        else
            return itDisplay .. " / " .. ColorizeEnglish(enName)
        end
    end
    return itDisplay
end

-- ===========================================================================================
-- Hook POI / Shrine / Keep tooltips
-- ===========================================================================================
local _poiTooltipsHooked    = false
local _shrineTooltipsHooked = false
local _keepTooltipsHooked   = false

local function IsContextMenuOpen()
    if ZO_WorldMapMouseover and ZO_WorldMapMouseover:IsHidden() then return true end
    if ZO_WorldMapMouseContextMenu and not ZO_WorldMapMouseContextMenu:IsHidden() then return true end
    if ZO_Menu and not ZO_Menu:IsHidden() then return true end
    return false
end

local function HookPoiTooltips()
    if _poiTooltipsHooked then return end
    _poiTooltipsHooked = true

    local function AddBilingualName(pin)
        if not addon.savedVars.bilingualPOI then return end
        if IsContextMenuOpen() then return end
        local localizedName = ZO_WorldMapMouseoverName:GetText()
        local normalized = NormalizeName(localizedName)
        local englishName = addon.translationTable[normalized] or localizedName
        local italianOriginal = addon.reverseTable[englishName] or localizedName
        local cleanedLocalized = ProcessMarkers(italianOriginal)
        cleanedLocalized = cleanedLocalized:gsub("%^%a+", "")
        local locString = cleanedLocalized
        if englishName and cleanedLocalized ~= englishName then
            locString = addon.savedVars.bilingualNewLine
                and zo_strformat("<<1>>\n<<2>>", cleanedLocalized, ColorizeEnglish(englishName))
                or  zo_strformat("<<1>> / <<2>>", cleanedLocalized, ColorizeEnglish(englishName))
        end
        ZO_WorldMapMouseoverName:SetText(locString)
    end
    local CreatorPOISeen = ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_SEEN].creator
    ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_SEEN].creator = function(...)
        CreatorPOISeen(...) AddBilingualName(...)
    end
    local CreatorPOIComplete = ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_COMPLETE].creator
    ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_COMPLETE].creator = function(...)
        CreatorPOIComplete(...) AddBilingualName(...)
    end
end

local function HookShrineTooltips()
    if _shrineTooltipsHooked then return end
    _shrineTooltipsHooked = true

    local function AddEnglishToTooltip()
        if not addon.savedVars.bilingualPOI then return end
        if IsContextMenuOpen() then return end
        local localized = ZO_WorldMapMouseoverName:GetText()
        local italianPart = localized:match("^(.-)%|%|c") or localized
        italianPart = SafeTrim(italianPart)
        local englishPart = localized:match("%|%|c%x+(.-)%|%|r") or ""
        englishPart = SafeTrim(englishPart)
        if italianPart == "" or englishPart == "" then return end
        italianPart = ProcessMarkers(italianPart)
        italianPart = italianPart:gsub("%^%a+", "")
        local text
        if addon.savedVars.bilingualNewLine then
            text = italianPart .. "\n" .. ColorizeEnglish(englishPart)
        else
            text = italianPart .. " / " .. ColorizeEnglish(englishPart)
        end
        ZO_WorldMapMouseoverName:SetText(text)
    end
    local orig1 = ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE].creator
    ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE].creator = function(...)
        orig1(...) AddEnglishToTooltip()
    end
    local orig2 = ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE_CURRENT_LOC].creator
    ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE_CURRENT_LOC].creator = function(...)
        orig2(...) AddEnglishToTooltip()
    end
end

local function HookKeepTooltips()
    if _keepTooltipsHooked then return end
    _keepTooltipsHooked = true

    local function ModifyKeepTooltip(self, keepId)
        if not addon.savedVars.bilingualPOI then return end
        if IsContextMenuOpen() then return end
        local keepName = GetKeepName(keepId)
        local cleanedKeepName = ProcessMarkers(keepName)
        cleanedKeepName = cleanedKeepName and cleanedKeepName:gsub("%^%a+", "") or keepName
        local normalized = NormalizeName(keepName)
        local englishKeepName = addon.translationTable[normalized] or cleanedKeepName
        local nameLabel = self:GetNamedChild("Name")
        local displayText = cleanedKeepName
        if englishKeepName and cleanedKeepName ~= englishKeepName then
            displayText = addon.savedVars.bilingualNewLine
                and zo_strformat("<<1>>\n<<2>>", cleanedKeepName, ColorizeEnglish(englishKeepName))
                or  zo_strformat("<<1>> / <<2>>", cleanedKeepName, ColorizeEnglish(englishKeepName))
        end
        nameLabel:SetText(displayText)
    end
    local SetKeep = ZO_KeepTooltip.SetKeep
    ZO_KeepTooltip.SetKeep = function(self, keepId, ...)
        SetKeep(self, keepId, ...) ModifyKeepTooltip(self, keepId)
    end
    local RefreshKeep = ZO_KeepTooltip.RefreshKeepInfo
    ZO_KeepTooltip.RefreshKeepInfo = function(self, ...)
        RefreshKeep(self, ...)
        if self.keepId and self.battlegroundContext and self.historyPercent then
            ModifyKeepTooltip(self, self.keepId)
        end
    end
end

-- ===========================================================================================
-- Quest list sanitize
-- ===========================================================================================
local function TradItaESO_SanitizeQuestList()
    local container = ZO_QuestJournalNavigationContainerScrollChildContainer
    if not container then return end
    local numChildren = container:GetNumChildren()
    for i = 1, numChildren do
        local entry = container:GetChild(i)
        if entry and entry.label and entry.label.GetText then
            local txt = entry.label:GetText()
            if txt and txt:find("%^i") then
                local clean = TraduzioneItaESO.ProcessMarkers(txt)
                if clean and clean ~= txt then entry.label:SetText(clean) end
            end
        end
    end
end

ZO_PreHookHandler(ZO_QuestJournal, "OnShow", function()
    zo_callLater(HookQuestListTree, 50)
    zo_callLater(HookQuestListLabels, 50)
    zo_callLater(TradItaESO_SanitizeQuestList, 100)
end)

-- ===========================================================================================
-- Mouseover mappa
-- ===========================================================================================
local function TryHookSetText()
    if not ZO_WorldMapMouseoverName or not ZO_WorldMapMouseoverName.SetText then return false end
    if ZO_WorldMapMouseoverName._OrigSetText then return true end
    ZO_WorldMapMouseoverName._OrigSetText = ZO_WorldMapMouseoverName.SetText
    ZO_WorldMapMouseoverName.SetText = function(self, text, ...)
        local newText = GetBilingualText(text)
        pcall(self._OrigSetText, self, newText, ...)
    end
    return true
end

local updaterRegistered = false
local function StartUpdater()
    if updaterRegistered then return end
    updaterRegistered = true
    local function CheckMouseover()
        if not ZO_WorldMapMouseoverName or ZO_WorldMap:IsHidden() then return end
        if ZO_WorldMapMouseover and ZO_WorldMapMouseover:IsHidden() then return end
        local text = ZO_WorldMapMouseoverName:GetText() or ""
        local newText = GetBilingualText(text)
        if newText ~= text then
            SafeCall(function() ZO_WorldMapMouseoverName:SetText(newText) end)
        end
    end
    EVENT_MANAGER:RegisterForUpdate(addon.name .. "_Updater", 100, CheckMouseover)
end

-- ===========================================================================================
-- Tooltip oggetti inventario
-- ===========================================================================================
-- ===========================================================================================
-- Lookup ITA->ENG pre-calcolato per AddTestLineToTooltip
-- PRIMA: ogni tooltip (= ogni hover durante lo scroll dell'inventario) eseguiva
-- un ciclo "for key,value in pairs(...)" su TUTTA la tabella ItemsTranslations
-- (circa 30.000 voci) con gsub+lower su ogni chiave -> lag pesante allo scroll.
-- ORA: la tabella viene normalizzata UNA SOLA VOLTA al caricamento e poi
-- ogni hover fa solo un lookup O(1) per chiave già pulita/minuscola.
-- ===========================================================================================
local _itemNameLookup = nil

local function BuildItemNameLookup()
    local result = {}
    local function addFromTable(translationTable)
        if not translationTable then return end
        for key, value in pairs(translationTable) do
            if type(key) == "string" and type(value) == "string" then
                local cleanedKey = SafeLower(SafeTrim(key:gsub("%^%a+", "")))
                if result[cleanedKey] == nil then
                    result[cleanedKey] = value
                end
                -- Fix TTC: gestisce chiavi e valori singolare||plurale
                if cleanedKey:find("||", 1, true) and value:find("||", 1, true) then
                    local k1, k2 = cleanedKey:match("^(.-)%|%|(.-)$")
                    local v1, v2 = value:match("^(.-)%|%|(.-)$")
                    if k1 and v1 and result[k1] == nil then result[k1] = v1 end
                    if k2 and v2 and result[k2] == nil then result[k2] = v2 end
                end
            end
        end
    end
    addFromTable(addon.ItemsTranslations)
    addFromTable(TraduzioneItaESO and TraduzioneItaESO.ItemsTranslations)
    return result
end

-- ===========================================================================================
-- sortedZones: lista zone ordinata dalla piu' lunga alla piu' corta (per evitare che
-- "Porto" matchi prima di "Porto Gelido"), con le forme lowercase pre-calcolate.
-- PRIMA: veniva ricostruita da zero E riordinata (table.sort) ad ogni singolo hover
-- sull'inventario -> costo O(N log N) ripetuto in continuazione durante lo scroll.
-- ORA: costruita una sola volta alla prima chiamata e tenuta in cache.
-- ===========================================================================================
local _sortedZonesCache = nil
local function GetSortedZones()
    if _sortedZonesCache then return _sortedZonesCache end
    local sortedZones = {}
    for itZone, enZone in pairs(addon.ZoneTranslations or {}) do
        local cleaned = itZone:gsub("%^%a+", "")
        local zoneWithSpaces = SafeLower(cleaned)
        sortedZones[#sortedZones + 1] = {
            it = cleaned,
            en = enZone,
            zoneWithSpaces = zoneWithSpaces,
            zoneNorm = zoneWithSpaces:gsub("%s+", ""),
        }
    end
    table.sort(sortedZones, function(a, b) return #a.it > #b.it end)
    _sortedZonesCache = sortedZones
    return sortedZones
end

local function AddTestLineToTooltip(tooltip, bagId, slotIndex, itemLink)
    if not addon.savedVars.showEnglishItemNames then return end
    local itemName
    if itemLink then
        itemName = GetItemLinkName(itemLink)
    elseif bagId and slotIndex then
        itemName = GetItemName(bagId, slotIndex)
    else
        return
    end

    local cleanedItemName = itemName:gsub("%^%a+", "")
    -- Rimuove un eventuale prefisso "romano " in testa (es. "IX ")
    cleanedItemName = cleanedItemName:gsub("^%s*[IVXLCDM]+%s+", "")
    -- Rimuove un eventuale suffisso " romano" in coda (es. " IX")
    cleanedItemName = cleanedItemName:gsub("%s+[IVXLCDM]+%s*$", "")
    local englishItemName = nil

    if not _itemNameLookup then
        _itemNameLookup = BuildItemNameLookup()
    end

    -- Lookup diretto (chiave già pulita) poi lookup O(1) case-insensitive
    local matchSource = "nessuno"
    if addon.ItemsTranslations and addon.ItemsTranslations[cleanedItemName] then
        englishItemName = addon.ItemsTranslations[cleanedItemName]
        matchSource = "addon.ItemsTranslations (diretto)"
    elseif TraduzioneItaESO and TraduzioneItaESO.ItemsTranslations and TraduzioneItaESO.ItemsTranslations[cleanedItemName] then
        englishItemName = TraduzioneItaESO.ItemsTranslations[cleanedItemName]
        matchSource = "TraduzioneItaESO.ItemsTranslations (diretto)"
    else
        englishItemName = _itemNameLookup[SafeLower(cleanedItemName)]
        matchSource = "_itemNameLookup (fallback lowercase)"
    end

    if mostraDebug then
        DebugLog(string.format("[TTLTT] raw='%s' cleaned='%s' (byte len=%d) match='%s' via=%s",
            tostring(itemName), tostring(cleanedItemName), #cleanedItemName, tostring(englishItemName), matchSource))
    end

    if englishItemName and englishItemName ~= cleanedItemName then
        -- Pulizia marker grammaticali (es. ^n, ^m, ^f) dal nome inglese prima di mostrarlo
        local cleanedEnglishName = SafeTrim(englishItemName:gsub("%^%a+", ""))
        tooltip:AddLine("", "", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
        tooltip:AddLine(ColorizeEnglish(cleanedEnglishName), "", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
        return
    end




-- Estrai la parte dopo ":" nel nome oggetto (es. "Ricerca Alchemica: Porto Gelido I" -> "Porto Gelido I")
local itemSuffix = cleanedItemName:match(":%s*(.+)$") or cleanedItemName
local itemSuffixLower = SafeLower(itemSuffix)

local sortedZones = GetSortedZones()
for _, zoneEntry in ipairs(sortedZones) do
    local cleanedItZone = zoneEntry.it
    local enZone        = zoneEntry.en

    -- Confronto: la zona deve apparire nel suffisso (dopo i ":"), case-insensitive
    -- (zoneNorm/zoneWithSpaces sono pre-calcolati una sola volta in GetSortedZones,
    -- non ricalcolati ad ogni hover)
    local zoneNorm        = zoneEntry.zoneNorm
    local zoneWithSpaces  = zoneEntry.zoneWithSpaces
    local suffixNoSp   = itemSuffixLower:gsub("%s+", "")

    local found = false
    -- Caso 1: "Porto Gelido" dentro "Porto Gelido I" (con spazi)
    if itemSuffixLower:find(zoneWithSpaces, 1, true) then
        found = true
    -- Caso 2: "PaludeOmbrosa" dentro "PaludeOmbrosa I" (senza spazi nella chiave)
    elseif suffixNoSp:find(zoneNorm, 1, true) then
        found = true
    end

    if found then
        local enItemName = cleanedItemName

        -- Sostituzione 1: zona con spazi dentro nome originale (case-insensitive manuale)
        -- Usiamo plain find per individuare la posizione, poi sostituiamo
        local lowerItem = SafeLower(cleanedItemName)
        local s, e = lowerItem:find(zoneWithSpaces, 1, true)
        if s then
            enItemName = cleanedItemName:sub(1, s-1) .. enZone .. cleanedItemName:sub(e+1)
        else
            -- Sostituzione 2: zona senza spazi (es. "PaludeOmbrosa") - zoneNorm gia' cache
            local s2, e2 = lowerItem:find(zoneNorm, 1, true)
            if s2 then
                enItemName = cleanedItemName:sub(1, s2-1) .. enZone .. cleanedItemName:sub(e2+1)
            end
        end

        if enItemName ~= cleanedItemName then
            -- Pulizia marker grammaticali dal nome inglese prima di mostrarlo
            local cleanedEnItemName = SafeTrim(enItemName:gsub("%^%a+", ""))
            tooltip:AddLine("", "", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
            tooltip:AddLine(ColorizeEnglish(cleanedEnItemName), "", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
        end
        return
    end
end






end

ZO_PostHook(ItemTooltip, "SetBagItem", function(self, bagId, slotIndex)
    AddTestLineToTooltip(self, bagId, slotIndex, nil)
end)
ZO_PostHook(ItemTooltip, "SetLink", function(self, itemLink)
    AddTestLineToTooltip(self, nil, nil, itemLink)
end)

if GAMEPAD_TOOLTIPS then
    local gamepadTooltip = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
    if gamepadTooltip then
        ZO_PostHook(gamepadTooltip, "SetBagItem", function(self, bagId, slotIndex)
            AddTestLineToTooltip(self, bagId, slotIndex, nil)
        end)
        ZO_PostHook(gamepadTooltip, "SetLink", function(self, itemLink)
            AddTestLineToTooltip(self, nil, nil, itemLink)
        end)
    end
end


-- Hook aggiuntivi tooltip item (banca, loot, crafting, mail, trading house)
ZO_PostHook(ItemTooltip, "SetBuybackItem", function(self, slotIndex)
    AddTestLineToTooltip(self, BAG_BUYBACK, slotIndex, nil)
end)
ZO_PostHook(ItemTooltip, "SetStoreItem", function(self, slotIndex)
    local itemLink = GetStoreItemLink(slotIndex)
    AddTestLineToTooltip(self, nil, nil, itemLink)
end)
ZO_PostHook(ItemTooltip, "SetWornItem", function(self, equipSlot)
    AddTestLineToTooltip(self, BAG_WORN, equipSlot, nil)
end)
ZO_PostHook(ItemTooltip, "SetQuestReward", function(self, questIndex, rewardIndex)
    local itemLink = GetQuestRewardItemLink(questIndex, rewardIndex)
    AddTestLineToTooltip(self, nil, nil, itemLink)
end)
ZO_PostHook(ItemTooltip, "SetAttachedMailItem", function(self, mailId, attachIndex)
    local itemLink = GetAttachedItemLink(mailId, attachIndex)
    AddTestLineToTooltip(self, nil, nil, itemLink)
end)
ZO_PostHook(ItemTooltip, "SetTradingHouseItem", function(self, tradingHouseIndex)
    local itemLink = GetTradingHouseSearchResultItemLink(tradingHouseIndex)
    AddTestLineToTooltip(self, nil, nil, itemLink)
end)
ZO_PostHook(ItemTooltip, "SetCraftingResultItem", function(self, ...)
    local itemLink = GetSmithingPatternResultLink(...)
    if itemLink then AddTestLineToTooltip(self, nil, nil, itemLink) end
end)

-- ===========================================================================================
-- Hook Item Set Collections (Sticker Book)
-- La finestra usa ItemTooltip:SetItemSetCollectionPieceLink(itemLink, hideTrait)
-- ===========================================================================================
local function HookLayoutGenericItem()
    ZO_PostHook(ItemTooltip, "SetItemSetCollectionPieceLink", function(self, itemLink, hideTrait)
        if not itemLink or itemLink == "" then return end
        if not addon.savedVars or not addon.savedVars.showEnglishItemNames then return end
        AddTestLineToTooltip(self, nil, nil, itemLink)
    end)
    DebugLog("[TraduzioneItaESO] Hook SetItemSetCollectionPieceLink installato")
end







-- ===========================================================================================
-- Ricerca bilingue inventario (EN→IT e IT→EN)
-- ===========================================================================================
local _bilingualSearchHooked = false

local function BuildReverseSearchTable()
    local reverse = {}
    local src = addon.ItemsTranslations or TraduzioneItaESO.ItemsTranslations or {}
    for itaName, engName in pairs(src) do
        if type(itaName) == "string" and type(engName) == "string" then
            local key = engName:lower():gsub("%^%a+", "")
            if not reverse[key] then
                reverse[key] = SafeLower(itaName):gsub("%^%a+", "")
            end
        end
    end
    return reverse
end

local function HookBilingualSearch()
    if _bilingualSearchHooked then return end
    if not PLAYER_INVENTORY or not PLAYER_INVENTORY.inventories then return end

    local reverseTable = BuildReverseSearchTable()
    local origDoesItemPassFilter = PLAYER_INVENTORY.DoesItemPassFilter
    if not origDoesItemPassFilter then return end

    PLAYER_INVENTORY.DoesItemPassFilter = function(self, bagId, slotIndex, ...)
        local result = origDoesItemPassFilter(self, bagId, slotIndex, ...)
        if result then return true end
        if not addon.savedVars.enableBilingualSearch then return false end

        local searchText = nil
        if self.searchBox and type(self.searchBox.GetText) == "function" then
            searchText = self.searchBox:GetText()
        end
        if not searchText or searchText == "" then return false end

        local searchLower = SafeLower(searchText):gsub("%^%a+", "")
        local itemName = GetItemName(bagId, slotIndex)
        if not itemName then return false end
        local itemLower = SafeLower(itemName):gsub("%^%a+", "")

        local itaEquivalent = reverseTable[searchLower]
        if itaEquivalent and itemLower:find(itaEquivalent, 1, true) then
            return true
        end
        for engLower, itaLower in pairs(reverseTable) do
            if engLower:find(searchLower, 1, true) then
                if itemLower:find(itaLower, 1, true) then
                    return true
                end
            end
        end
        return false
    end

    _bilingualSearchHooked = true
    DebugLog("[TraduzioneItaESO] Ricerca bilingue inventario attivata")
end

-- ===========================================================================================
-- Ricerca bilingue Trading House (IT→EN prima dell'invio al server)
-- ===========================================================================================
-- ===========================================================================================
-- Ricerca bilingue Trading House (hook diretto sulla searchbox)
-- ===========================================================================================
local function HookTradingHouseSearch()

local function GetITtoEN(italianText)
    if not italianText or italianText == "" then return italianText end
    local src = addon.ItemsTranslations or TraduzioneItaESO.ItemsTranslations or {}
    local itaLower = SafeLower(italianText)

    -- 1) Match esatto
    for ita, eng in pairs(src) do
        if type(ita) == "string" and SafeLower(ita) == itaLower then
            DebugLog("[TraduzioneItaESO] Match esatto: " .. ita .. " → " .. eng)
            return eng
        end
    end

    -- 2) Mappa frequenza: per ogni parola inglese conta quante volte appare
    -- nelle voci italiane che contengono il termine cercato
    if #itaLower >= 4 then
        local engWordFreq = {}

        for ita, eng in pairs(src) do
            if type(ita) == "string" and type(eng) == "string" then
                local itaL = SafeLower(ita)
                local matched = false
                for word in itaL:gmatch("%a+") do
                    if word:sub(1, #itaLower) == itaLower then
                        matched = true
                        break
                    end
                end
                if matched then
                    for engWord in eng:gmatch("%a+") do
                        if #engWord >= 3 then
                            local ew = engWord:lower()
                            engWordFreq[ew] = (engWordFreq[ew] or 0) + 1
                        end
                    end
                end
            end
        end

        -- Trova la parola inglese più frequente
        local bestWord = nil
        local bestCount = 0
        for word, count in pairs(engWordFreq) do
            if count > bestCount then
                bestCount = count
                bestWord = word
            end
        end

        if bestWord then
            -- Capitalizza la prima lettera
            local result = bestWord:sub(1,1):upper() .. bestWord:sub(2)
            DebugLog("[TraduzioneItaESO] Match frequenza: '" .. italianText .. "' → '" .. result .. "' (" .. bestCount .. " voci)")
            return result
        end
    end

    DebugLog("[TraduzioneItaESO] Nessun match per: " .. italianText)
    return italianText
end

    local function TranslateSearchBox()
        if not addon.savedVars.enableBilingualSearch then return end
        local searchBox = WINDOW_MANAGER:GetControlByName("ZO_TradingHouseItemNameSearchBox")
        if not searchBox then return end
        local currentText = searchBox:GetText()
        if not currentText or currentText == "" then return end
        local translated = GetITtoEN(currentText)
        if translated ~= currentText then
            searchBox:SetText(translated)
            DebugLog("[TraduzioneItaESO] TH search: '" .. currentText .. "' → '" .. translated .. "'")
        end
    end

    -- Hook OnEnter sulla searchbox (tasto Invio)
local searchBox = WINDOW_MANAGER:GetControlByName("ZO_TradingHouseItemNameSearchBox")
    if searchBox then
        -- Hook OnEnter (tasto Invio)
        local origEnter = searchBox:GetHandler("OnEnter")
        searchBox:SetHandler("OnEnter", function(self, ...)
            TranslateSearchBox()
            if origEnter then return origEnter(self, ...) end
        end)

        -- Hook OnTextChanged: traduce dopo 300ms di pausa nella scrittura
        local timerName = "TraduzioneItaESO_THSearchDelay"
        local origTextChanged = searchBox:GetHandler("OnTextChanged")
        searchBox:SetHandler("OnTextChanged", function(self, ...)
            if origTextChanged then origTextChanged(self, ...) end
            -- Cancella il timer precedente e ne crea uno nuovo
            EVENT_MANAGER:UnregisterForUpdate(timerName)
            EVENT_MANAGER:RegisterForUpdate(timerName, 300, function()
                EVENT_MANAGER:UnregisterForUpdate(timerName)
                TranslateSearchBox()
            end)
        end)

        DebugLog("[TraduzioneItaESO] Hook searchbox attivato (Enter + TextChanged)")
    else
        DebugLog("[TraduzioneItaESO] SearchBox non trovata al setup")
    end

    DebugLog("[TraduzioneItaESO] HookTradingHouseSearch completato")
end

EVENT_MANAGER:RegisterForEvent("TraduzioneItaESO_THSearch", EVENT_PLAYER_ACTIVATED, function()
    EVENT_MANAGER:UnregisterForEvent("TraduzioneItaESO_THSearch", EVENT_PLAYER_ACTIVATED)
    zo_callLater(function() HookTradingHouseSearch() end, 3000)
end)

EVENT_MANAGER:RegisterForEvent("TraduzioneItaESO_BilingualSearch", EVENT_PLAYER_ACTIVATED, function()
    EVENT_MANAGER:UnregisterForEvent("TraduzioneItaESO_BilingualSearch", EVENT_PLAYER_ACTIVATED)
    zo_callLater(function() HookBilingualSearch() end, 2000)
end)







-- ===========================================================================================
-- Pulizia nome NPC nel reticle
-- ===========================================================================================
local function CleanReticleName(control)
    if not control or type(control.GetText) ~= "function" or type(control.SetText) ~= "function" then return end
    local ok, txt = pcall(control.GetText, control)
    if ok and txt and txt:find("%^i") then
        local ok2, cleaned = pcall(ProcessMarkers, txt)
        if ok2 and cleaned and cleaned ~= txt then
            control:SetText(cleaned)
        end
    end
end

local reticleControl = RETICLE.interactContext or WINDOW_MANAGER:GetControlByName("ZO_ReticleContainerInteractContext")
if reticleControl then
    ZO_PostHook(reticleControl, "SetText", function(self, text)
        if text and text:find("%^i") then CleanReticleName(self) end
    end)
end

ZO_PostHook(RETICLE, "UpdateInteractText", function(self)
    local control = self.interactContext or WINDOW_MANAGER:GetControlByName("ZO_ReticleContainerInteractContext")
    CleanReticleName(control)
end)

zo_callLater(function()
    local control = RETICLE.interactContext or WINDOW_MANAGER:GetControlByName("ZO_ReticleContainerInteractContext")
    CleanReticleName(control)
end, 500)

-- ===========================================================================================
-- Integrazione TTC
-- ===========================================================================================
function addon:InitializeTTCIntegration()
    EVENT_MANAGER:RegisterForEvent("TraduzioneItaESO_TTC", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
        if addonName == "TamrielTradeCentre" then
            EVENT_MANAGER:UnregisterForEvent("TraduzioneItaESO_TTC", EVENT_ADD_ON_LOADED)
            zo_callLater(function() self:SetupTTCIntegration() end, 5000)
        end
    end)
    EVENT_MANAGER:RegisterForEvent("TraduzioneItaESO_TTC_PA", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent("TraduzioneItaESO_TTC_PA", EVENT_PLAYER_ACTIVATED)
        zo_callLater(function()
            if TamrielTradeCentre and TamrielTradeCentre.ItemLookUpTable then
                self:SetupTTCIntegration()
            end
        end, 2000)
    end)
end

function addon:SetupTTCIntegration()
    if not TamrielTradeCentre then
        DebugLog("[TTC-IT] TamrielTradeCentre non trovato")
        return
    end
    if not TamrielTradeCentre.ItemLookUpTable then
        DebugLog("[TTC-IT] ItemLookUpTable non trovata - TTC non ancora pronto, riprovo...")
        zo_callLater(function() self:SetupTTCIntegration() end, 3000)
        return
    end
    DebugLog("[TTC-IT] TamrielTradeCentre trovato con ItemLookUpTable!")

    local itemTrans = TraduzioneItaESO and TraduzioneItaESO.ItemsTranslations
    if not itemTrans then
        DebugLog("[TTC-IT] ERRORE: ItemsTranslations non trovato!")
        return
    end

    local transCount = 0
    for _ in pairs(itemTrans) do transCount = transCount + 1 end

    if transCount == 0 then
        DebugLog("[TTC-IT] ItemsTranslations vuoto - riprovo tra 3s...")
        zo_callLater(function() self:SetupTTCIntegration() end, 3000)
        return
    end

    DebugLog(string.format("[TTC-IT] %d traduzioni italiano→inglese disponibili", transCount))

    local ttcTable = TamrielTradeCentre.ItemLookUpTable
    local ttcCount = 0
    for _ in pairs(ttcTable) do ttcCount = ttcCount + 1 end
    DebugLog(string.format("[TTC-IT] ItemLookUpTable TTC ha %d voci (inglese)", ttcCount))

    if not ttcTable.__ITA_SUFFIX_METATABLE then
        setmetatable(ttcTable, {
            __index = function(t, key)
                if type(key) ~= "string" then return nil end
                local stripped = key:gsub("%^[%a%d_%-]+$", "")
                if stripped ~= key then
                    return rawget(t, stripped)
                end
                return nil
            end
        })
        ttcTable.__ITA_SUFFIX_METATABLE = true
    end

    -- Genera varianti di maiuscole/minuscole di una stringa per essere tolleranti
    -- a eventuali incongruenze fra la capitalizzazione usata nel dizionario e quella
    -- realmente mostrata dal client (es. "Tonico al Guaranà" nel dizionario vs
    -- "Tonico al guaranà" mostrato in gioco). Copre: come scritta, tutta minuscola,
    -- e "sentence case" (solo la prima lettera maiuscola).
    local function GenerateCaseVariants(s)
        local variants, seen = {}, {}
        local function add(v)
            if v and v ~= "" and not seen[v] then
                seen[v] = true
                variants[#variants + 1] = v
            end
        end
        if not s or s == "" then return variants end
        add(s)
        local lowerS = SafeLower(s)
        add(lowerS)
        local firstChar, rest = lowerS:match("^(.)(.*)$")
        -- Applica la variante "prima lettera maiuscola" solo se il primo byte è
        -- una lettera ASCII semplice: se fosse l'inizio di un carattere UTF-8
        -- multi-byte (es. una vocale accentata), :upper() lo corromperebbe.
        if firstChar and firstChar:byte() < 128 then
            add(firstChar:upper() .. rest)
        end
        return variants
    end

    -- ===========================================================================================
    -- Elaborazione a lotti (batch) invece che sincrona su tutta la tabella in un frame solo.
    -- PRIMA: questo loop girava su TUTTE le voci di itemTrans (decine di migliaia con
    -- UpdateItemTranslations.py) in un singolo frame -> freeze di diversi secondi al login.
    -- ORA: le chiavi vengono raccolte una volta (economico), poi processate BATCH_SIZE
    -- alla volta, un lotto per frame via zo_callLater, cosi' il lavoro si spalma su
    -- piu' frame senza mai bloccare il thread principale abbastanza da farsi notare.
    -- ===========================================================================================
    local BATCH_SIZE = 300

    local keys = {}
    for itaName in pairs(itemTrans) do
        keys[#keys + 1] = itaName
    end

    local added, skipped, notInTTC = 0, 0, 0
    local idx = 0

    local function FinishTTCIntegration()
        DebugLog(string.format("[TTC-IT] Voci italiane aggiunte: %d | già presenti: %d | inglese non in TTC: %d",
            added, skipped, notInTTC))

        if added == 0 and notInTTC > (transCount * 0.9) then
            DebugLog("[TTC-IT] ATTENZIONE: quasi nessuna traduzione trovata in TTC.")
            DebugLog("[TTC-IT] Verifica che il database prezzi TTC sia scaricato dal sito.")
        else
            DebugLog("[TTC-IT] Integrazione completata! I prezzi TTC sono ora visibili in italiano.")
        end

        self:FinalizeTTCItemInfoHook()
    end

    local function ProcessBatch()
        local processedInThisBatch = 0
        while idx < #keys and processedInThisBatch < BATCH_SIZE do
            idx = idx + 1
            processedInThisBatch = processedInThisBatch + 1
            local itaName = keys[idx]
            local engName = itemTrans[itaName]
            if type(itaName) == "string" and type(engName) == "string" then
                local engKey    = string.lower(engName)
                local priceData = ttcTable[engKey]
                if priceData then
                    local stripped = itaName:gsub("%^[%a%d_%-]+$", "")
                    local candidateKeys = GenerateCaseVariants(itaName)
                    if stripped ~= itaName then
                        for _, v in ipairs(GenerateCaseVariants(stripped)) do
                            candidateKeys[#candidateKeys + 1] = v
                        end
                    end
                    for _, key in ipairs(candidateKeys) do
                        -- inserisce sia la variante esatta sia la sua forma minuscola,
                        -- per coprire sia un TTC che confronta case-sensitive sia uno
                        -- che normalizza tutto in minuscolo prima del lookup
                        for _, finalKey in ipairs({ key, SafeLower(key) }) do
                            if not ttcTable[finalKey] then
                                ttcTable[finalKey] = priceData
                                added = added + 1
                            else
                                skipped = skipped + 1
                            end
                        end
                    end
                else
                    notInTTC = notInTTC + 1
                end
            end
        end

        if idx < #keys then
            zo_callLater(ProcessBatch, 0)
        else
            FinishTTCIntegration()
        end
    end

    ProcessBatch()
end

function addon:FinalizeTTCItemInfoHook()
    if TamrielTradeCentre_ItemInfo and not TamrielTradeCentre_ItemInfo.__ITA_HOOKED then
        TamrielTradeCentre_ItemInfo.__ITA_HOOKED = true
        local origLookup = TamrielTradeCentre_ItemInfo.NameSpecializedItemTypeToItemID
        TamrielTradeCentre_ItemInfo.NameSpecializedItemTypeToItemID = function(self, itemName, specializedItemType)
            local result = origLookup(self, itemName, specializedItemType)
            if result then return result end
            if itemName then
                -- Estrae il prefisso romano (es. "IX" da "IX Veleno...")
                local romanPrefix = itemName:match("^%s*([IVXLCDM]+)%s+")
                -- Pulisce da prefisso romano e marker, normalizza lowercase
                local cleanedIta = itemName:gsub("%^%a+", "")
                cleanedIta = SafeLower(cleanedIta:gsub("^%s*[IVXLCDM]+%s+", ""))
                -- Usa _itemNameLookup che ha chiavi già normalizzate (lowercase, senza marker)
                if not _itemNameLookup then
                    _itemNameLookup = BuildItemNameLookup()
                end
                local engName = _itemNameLookup[cleanedIta]
                if engName then
                    local engLower = engName:lower()
                    -- Prima prova con romano estratto in coda (tier corretto)
                    if romanPrefix then
                        result = origLookup(self, engName .. " " .. romanPrefix, specializedItemType)
                        if result then return result end
                        result = origLookup(self, engLower .. " " .. romanPrefix:lower(), specializedItemType)
                        if result then return result end
                    end
                    -- Fallback senza romano
                    result = origLookup(self, engName, specializedItemType)
                    if result then return result end
                    result = origLookup(self, engLower, specializedItemType)
                    if result then return result end
                end
            end
            return nil
        end
        DebugLog("[TTC-IT] Hook NameSpecializedItemTypeToItemID applicato")
    end

    local successUI, translationsUI = pcall(dofile, "AddOns/TraduzioneItaESO/addon/TamrielTradeCentreIT/it.lua")
    if successUI and type(translationsUI) == "table" then
        if TamrielTradeCentre.Strings then
            for key, value in pairs(translationsUI) do
                TamrielTradeCentre.Strings[key] = value
            end
        end
    end
end

-- ===========================================================================================
-- HookTTCItemNames
-- ===========================================================================================
function addon:HookTTCItemNames()
    if _G.__TraduzioneItaESO_ItemHookApplied then return end
    _G.__TraduzioneItaESO_ItemHookApplied = true

    -- PERFORMANCE: la lingua non cambia mai a runtime senza /reloadui,
    -- quindi calcoliamo il flag una volta sola invece di chiamare GetCVar()
    -- ad ogni GetItemName/GetItemLinkName (che ESO chiama decine di volte
    -- per frame durante lo scroll dell'inventario).
    local _isItalianCache = nil
    local function isItalian()
        if _isItalianCache == nil then
            _isItalianCache = (GetCVar("language.2") == "it")
        end
        return _isItalianCache
    end
    -- Helper inline: controlla marcatori e usa la cache
    local function applyMarkers(name)
        if name and (name:find("%^i", 1, true) or name:find("%^I", 1, true)) then
            return ProcessMarkersCache(name)
        end
        return name
    end

    local originalGetItemLinkName = GetItemLinkName
    GetItemLinkName = function(itemLink)
        local name = originalGetItemLinkName(itemLink)
        if not isItalian() then return name end
        return applyMarkers(name)
    end

    local originalGetItemName = GetItemName
    GetItemName = function(bagId, slotIndex)
        local name = originalGetItemName(bagId, slotIndex)
        if not isItalian() then return name end
        return applyMarkers(name)
    end

    if GetItemSetName then
        local originalGetItemSetName = GetItemSetName
        GetItemSetName = function(...)
            local name = originalGetItemSetName(...)
            if not isItalian() then return name end
            return applyMarkers(name)
        end
    end

    if GetItemLinkSetInfo then
        local originalGetItemLinkSetInfo = GetItemLinkSetInfo
        GetItemLinkSetInfo = function(itemLink, ...)
            local setId, name, numBonuses, numEquipped, maxEquipped, isOverrideSet =
                originalGetItemLinkSetInfo(itemLink, ...)
            if not isItalian() then
                return setId, name, numBonuses, numEquipped, maxEquipped, isOverrideSet
            end
            name = applyMarkers(name)
            return setId, name, numBonuses, numEquipped, maxEquipped, isOverrideSet
        end
    end

    if GetUnitName then
        local originalGetUnitName = GetUnitName
        GetUnitName = function(unitTag)
            local name = originalGetUnitName(unitTag)
            if not isItalian() then return name end
            return applyMarkers(name)
        end
    end

    if GetZoneName then
        local originalGetZoneName = GetZoneName
        GetZoneName = function(...)
            local name = originalGetZoneName(...)
            if not isItalian() then return name end
            return applyMarkers(name)
        end
    end

    if GetMapName then
        local originalGetMapName = GetMapName
        GetMapName = function(...)
            local name = originalGetMapName(...)
            if not isItalian() then return name end
            return applyMarkers(name)
        end
    end

    DebugLog("[TraduzioneItaESO] HookTTCItemNames completato")
end

SLASH_COMMANDS["/ttccheck"] = function()
    d("=== STATO INTEGRAZIONE TTC ===")
    if not TamrielTradeCentre then
        d("❌ TamrielTradeCentre non trovato - TTC non è caricato")
        return
    end
    d("✅ TamrielTradeCentre trovato")
    if not TamrielTradeCentre.ItemLookUpTable then
        d("❌ ItemLookUpTable non trovata - database prezzi TTC vuoto?")
        d("   Scarica il database dal sito tamrieltradecentre.com")
        return
    end
    local ttcCount = 0
    for _ in pairs(TamrielTradeCentre.ItemLookUpTable) do ttcCount = ttcCount + 1 end
    d(string.format("✅ ItemLookUpTable: %d voci totali", ttcCount))
    local testItems = {
        ["cardo benedetto"] = "blessed thistle",
        ["vetro"] = "glass",
        ["pietra di anima"] = "soul gem",
    }
    local found = 0
    for ita, eng in pairs(testItems) do
        local itaData = TamrielTradeCentre.ItemLookUpTable[ita]
        local engData = TamrielTradeCentre.ItemLookUpTable[eng]
        if itaData then
            d(string.format("  ✅ '%s' trovato in tabella", ita))
            found = found + 1
        elseif engData then
            d(string.format("  ⚠️  '%s' NON trovato (ma '%s' inglese sì) - integrazione non ancora applicata", ita, eng))
        else
            d(string.format("  ❌ né '%s' né '%s' in tabella", ita, eng))
        end
    end
    if found > 0 then
        d("✅ Integrazione italiana ATTIVA - i prezzi dovrebbero apparire")
    else
        d("❌ Integrazione italiana NON attiva - richiama /ttcreload")
    end
    d("=== FINE ===")
end

SLASH_COMMANDS["/ttcreload"] = function()
    d("[TTC-IT] Riapplico integrazione TTC...")
    if not TamrielTradeCentre or not TamrielTradeCentre.ItemLookUpTable then
        d("[TTC-IT] TTC non disponibile - assicurati che TTC sia abilitato")
        return
    end
    if TamrielTradeCentre_ItemInfo then
        TamrielTradeCentre_ItemInfo.__ITA_HOOKED = nil
    end
    TraduzioneItaESO:SetupTTCIntegration()
end

SLASH_COMMANDS["/ttctest"] = function()
    d("=== TEST TTC TRADUZIONI ===")
    if not TraduzioneItaESO or not TraduzioneItaESO.ItemsTranslations then
        d("ERRORE: ItemsTranslations non esiste!")
        return
    end
    local count = 0
    for ita, eng in pairs(TraduzioneItaESO.ItemsTranslations) do
        count = count + 1
        if count <= 5 then d(string.format("  '%s' = '%s'", ita, eng)) end
    end
    d(string.format("Totale: %d traduzioni", count))
end

-- ===========================================================================================

-- ===========================================================================================
-- HOOK STAZIONE DI RICOSTRUZIONE / TRASMUTAZIONE
-- ===========================================================================================
-- Controlla se un controllo è una slot trascinabile (abilità, action bar, ecc.)
-- Questi controlli NON vanno mai toccati con SetText perché ESO li gestisce
-- in secure context e qualsiasi SetText da codice addon contamina lo stack
-- causando: "Attempt to access a private function 'PickupAbilityById' from insecure code"
local function IsSecureSlotControl(control)
    if type(control.GetName) ~= "function" then return false end
    local ok, name = pcall(control.GetName, control)
    if not ok or type(name) ~= "string" then return false end
    -- Esclude qualsiasi controllo il cui nome contenga "Slot" (slot abilità, action slot, ecc.)
    if name:find("Slot") then return true end
    -- Esclude i controlli della lista skill
    if name:find("SkillList") or name:find("SkillRow") or name:find("AbilitySlot") then return true end
    return false
end

local function ScanAndFixMarkersInControl(control, depth)
    if not control or (depth or 0) > 12 then return end
    -- Non toccare mai i controlli slot: sono gestiti in secure context da ESO
    if IsSecureSlotControl(control) then return end
    if type(control.GetText) == "function" and type(control.SetText) == "function" then
        local ok, txt = pcall(control.GetText, control)
        if ok and type(txt) == "string" and (txt:find("%^i") or txt:find("%^I")) then
            local ok2, cleaned = pcall(ProcessMarkers, txt)
            if ok2 and cleaned and cleaned ~= txt then
                pcall(function() control:SetText(cleaned) end)
            else
                local stripped = SafeCollapseSpaces(SafeTrim(txt:gsub("%^[iI][%a%d_%-]+", "")))
                if stripped ~= txt then
                    pcall(function() control:SetText(stripped) end)
                end
            end
        end
    end
    if type(control.GetNumChildren) == "function" then
        local ok, num = pcall(control.GetNumChildren, control)
        if ok and num and num > 0 then
            for i = 1, num do
                local ok2, child = pcall(control.GetChild, control, i)
                if ok2 and child then
                    ScanAndFixMarkersInControl(child, (depth or 0) + 1)
                end
            end
        end
    end
end

local function HookReconstructionAndTransmutationUI()
    local panelNames = {
        "ZO_RetraitStation_KeyboardTopLevel",
        "ZO_RetraitStation_GamepadTopLevel",
        "ZO_SmithingTopLevel",
    }

    local reconstructionUpdateRunning = false

    local function StopReconstructionScan()
        if reconstructionUpdateRunning then
            EVENT_MANAGER:UnregisterForUpdate("TraduzioneItaESO_ReconstructionScan")
            reconstructionUpdateRunning = false
        end
    end

    local function ScanAllPanels()
        for _, name in ipairs(panelNames) do
            local panel = WINDOW_MANAGER:GetControlByName(name)
            if panel and not panel:IsHidden() then
                ScanAndFixMarkersInControl(panel)
            end
        end
    end

    local function StartReconstructionScan()
        if reconstructionUpdateRunning then return end
        reconstructionUpdateRunning = true
        EVENT_MANAGER:RegisterForUpdate("TraduzioneItaESO_ReconstructionScan", 400, function()
            local anyVisible = false
            for _, name in ipairs(panelNames) do
                local panel = WINDOW_MANAGER:GetControlByName(name)
                if panel and not panel:IsHidden() then
                    anyVisible = true
                    ScanAndFixMarkersInControl(panel)
                end
            end
            if not anyVisible then StopReconstructionScan() end
        end)
    end

    EVENT_MANAGER:RegisterForEvent(
        "TraduzioneItaESO_CraftingStation",
        EVENT_CRAFTING_STATION_INTERACT,
        function()
            zo_callLater(function()
                ScanAllPanels()
                StartReconstructionScan()
            end, 300)
        end)

    EVENT_MANAGER:RegisterForEvent(
        "TraduzioneItaESO_CraftingEnd",
        EVENT_END_CRAFTING_STATION_INTERACT,
        function()
            StopReconstructionScan()
        end)

    zo_callLater(function()
        for _, name in ipairs(panelNames) do
            local panel = WINDOW_MANAGER:GetControlByName(name)
            if panel then
                ZO_PreHookHandler(panel, "OnShow", function()
                    zo_callLater(function()
                        ScanAndFixMarkersInControl(panel)
                        StartReconstructionScan()
                    end, 200)
                end)
                ZO_PreHookHandler(panel, "OnHide", function()
                    StopReconstructionScan()
                end)
            end
        end
    end, 2000)

    -- =========================================================================
    -- Ricerca bilingue stazione di ricostruzione: EN->IT
    -- Stesso approccio di HookBilingualSearch per l'inventario:
    -- hook su DoesSetPassTextFilter senza modificare il testo nella searchbox
    -- =========================================================================
    local _setSearchHooked = false
    local function HookSmithingSetSearch()
        if _setSearchHooked then return end
        if not addon.savedVars or not addon.savedVars.enableBilingualSearch then return end

        local reverseTable = BuildReverseSearchTable()
        if not next(reverseTable) then
            DebugLog("[Trans-IT] reverseTable vuota, riprovo dopo")
            return
        end

        if not SMITHING or not SMITHING.setContainer then
            DebugLog("[Trans-IT] SMITHING.setContainer non trovato")
            return
        end

        local setContainer = SMITHING.setContainer
        local SEARCH_BOX = "ZO_SmithingTopLevelSetContainerSearchBox"

        -- Cerca il metodo di filtro testo sul setContainer
        local filterMethodName = nil
        for _, n in ipairs({"DoesSetPassTextFilter","DoesSetPassFilter","PassesTextFilter","DoesDataPassFilter","MatchesFilter"}) do
            if type(setContainer[n]) == "function" then
                filterMethodName = n
                break
            end
        end

        if filterMethodName then
            local origFilter = setContainer[filterMethodName]
            setContainer[filterMethodName] = function(self, setData, ...)
                -- Prima prova il filtro originale (cerca in italiano)
                local result = origFilter(self, setData, ...)
                if result then return true end
                if not addon.savedVars.enableBilingualSearch then return false end

                -- Leggi il testo cercato
                local box = WINDOW_MANAGER:GetControlByName(SEARCH_BOX)
                if not box then return false end
                local ok, searchText = pcall(box.GetText, box)
                if not ok or not searchText or searchText == "" then return false end

                local searchLower = SafeLower(searchText):gsub("%^%a+", "")
                local setName = setData and (setData.name or setData.setName)
                if not setName then return false end
                local setLower = SafeLower(setName):gsub("%^%a+", "")

                -- Match esatto EN->IT
                local itaEquivalent = reverseTable[searchLower]
                if itaEquivalent and setLower:find(itaEquivalent, 1, true) then
                    return true
                end
                -- Match parziale EN->IT (es. "blood" trova tutti i set con "sangue")
                for engLower, itaLower in pairs(reverseTable) do
                    if engLower:find(searchLower, 1, true) then
                        if setLower:find(itaLower, 1, true) then
                            return true
                        end
                    end
                end
                return false
            end
            _setSearchHooked = true
            DebugLog("[Trans-IT] Hook " .. filterMethodName .. " attivato su SMITHING.setContainer")
        else
            DebugLog("[Trans-IT] Nessun metodo di filtro trovato su setContainer")
        end
    end

    -- Aggancia quando si apre la stazione (SMITHING viene inizializzato lazy)
    EVENT_MANAGER:RegisterForEvent(
        "TraduzioneItaESO_SetSearch",
        EVENT_CRAFTING_STATION_INTERACT,
        function()
            if not _setSearchHooked then
                zo_callLater(HookSmithingSetSearch, 500)
            end
        end)
    zo_callLater(HookSmithingSetSearch, 2000)
end

-- ===========================================================================================
-- InitSettings
-- ===========================================================================================
function addon:InitSettings()
    local LAM = LibAddonMenu2
    if not LAM then return end
local panelData = {
    type = "panel",
    name = "Traduzione Italiana ESO",
    displayName = "|cFFD700Traduzione Italiana ESO|r",
    author = "Muflonebarbuto |cAAAAAA& Zer81|r",
    version = addon.version,
    slashCommand = "/itaeso",
    registerForRefresh = true,
    registerForDefaults = true
}

    local function OnOffLabel(value)
        return value and "Abilitato" or "Disabilitato"
    end

    -- FIX: costruiamo le liste font/colore PRIMA di optionsData.
    -- IMPORTANTE: svuotiamo e ripopoliamo le tabelle ESISTENTI (non ne creiamo
    -- di nuove) cosi i riferimenti dentro optionsData/choicesFunc restano validi
    -- anche se InitSettings viene richiamata piu volte (EVENT_PLAYER_ACTIVATED).
    for k in pairs(lookup.fontNames) do lookup.fontNames[k] = nil end
    for k in pairs(lookup.fontValues) do lookup.fontValues[k] = nil end
    for k in pairs(lookup.nameToFont) do lookup.nameToFont[k] = nil end
    for _, item in pairs(lookup.fonts) do
        table.insert(lookup.fontNames,  item.name)
        table.insert(lookup.fontValues, item.data)
        lookup.nameToFont[item.name] = item.data
    end
    for k in pairs(lookup.colorNames) do lookup.colorNames[k] = nil end
    for k in pairs(lookup.colorValues) do lookup.colorValues[k] = nil end
    for k in pairs(lookup.nameToColor) do lookup.nameToColor[k] = nil end
    for _, item in pairs(lookup.colors) do
        table.insert(lookup.colorNames,  item.name)
        table.insert(lookup.colorValues, item.data)
        lookup.nameToColor[item.name] = item.data
    end

    local optionsData = {
        { type = "dropdown", name = "Seleziona Lingua", choices = {"Italiano", "Inglese"}, choicesValues = {"it", "en"},
          getFunc = function() return self.savedVars.language end,
          setFunc = function(value) self.savedVars.language = value ShowLanguageNotification(value) SetLanguage(value) end,
          tooltip = "Scegli la lingua del gioco.", requiresReload = true },
        { type = "checkbox", name = "Mostra Notifiche",
          tooltip = function() return "Abilita o disabilita notifiche. Stato: " .. OnOffLabel(self.savedVars.showNotifications) end,
          getFunc = function() return self.savedVars.showNotifications end,
          setFunc = function(value) self.savedVars.showNotifications = value end },
        { type = "checkbox", name = "Mostra Bandierine UI",
          tooltip = function() return "Abilita le bandierine. Stato: " .. OnOffLabel(self.savedVars.enableUI) end,
          getFunc = function() return self.savedVars.enableUI end,
          setFunc = function(value) self.savedVars.enableUI = value UpdateUIVisibility(IsReticleHidden()) end },
        { type = "checkbox", name = "Nascondi Bandierine durante Gameplay",
          tooltip = function() return "Nascondi le bandierine col mirino. Stato: " .. OnOffLabel(self.savedVars.hideDuringGameplay) end,
          getFunc = function() return self.savedVars.hideDuringGameplay end,
          setFunc = function(value) self.savedVars.hideDuringGameplay = value UpdateUIVisibility(IsReticleHidden()) end },
        { type = "checkbox", name = "Nomi Bilingui sulla Mappa",
          tooltip = function() return "Mostra nomi bilingui. Stato: " .. OnOffLabel(self.savedVars.bilingualMapNames) end,
          getFunc = function() return self.savedVars.bilingualMapNames end,
          setFunc = function(value) self.savedVars.bilingualMapNames = value UpdateMapName()
              if GetCurrentMapIndex() == TAMRIEL_MAP_INDEX then SafeCall(function() self:RenderMap(self.savedVars.showLocations) end) end end },
        { type = "checkbox", name = "Usa Nomi Inglesi su Tamriel",
          tooltip = function() return "Nomi inglesi su Tamriel. Stato: " .. OnOffLabel(self.savedVars.useEnglishNames) end,
          getFunc = function() return self.savedVars.useEnglishNames end,
          setFunc = function(value) self.savedVars.useEnglishNames = value
              if GetCurrentMapIndex() == TAMRIEL_MAP_INDEX then SafeCall(function() self:RenderMap(self.savedVars.showLocations) end) end end },
        { type = "checkbox", name = "Mostra Regioni su Tamriel",
          tooltip = function() return "Mostra regioni. Stato: " .. OnOffLabel(self.savedVars.showLocations) end,
          getFunc = function() return self.savedVars.showLocations end,
          setFunc = function(value) self.savedVars.showLocations = value
              if GetCurrentMapIndex() == TAMRIEL_MAP_INDEX then SafeCall(function() self:RenderMap(value) end) end end },
        { type = "checkbox", name = "Mostra Nomi Città su Tamriel",
          tooltip = function() return "Mostra città. Stato: " .. OnOffLabel(self.savedVars.showCitiesNames) end,
          getFunc = function() return self.savedVars.showCitiesNames end,
          setFunc = function(value) self.savedVars.showCitiesNames = value
              if GetCurrentMapIndex() == TAMRIEL_MAP_INDEX then SafeCall(function() self:RenderMap(self.savedVars.showLocations) end) end end },
        { type = "checkbox", name = "Nascondi Wayshrine su Tamriel",
          tooltip = function() return "Nascondi wayshrine. Stato: " .. OnOffLabel(self.savedVars.hidePinsOnTamriel) end,
          getFunc = function() return self.savedVars.hidePinsOnTamriel end,
          setFunc = function(value) self.savedVars.hidePinsOnTamriel = value
              SafeCall(function()
                  if GetCurrentMapIndex and GetCurrentMapIndex() == TAMRIEL_MAP_INDEX then
                      local pinMgr = ZO_WorldMap_GetPinManager and ZO_WorldMap_GetPinManager()
                      if pinMgr and pinMgr.SetPinGroupShown then
                          pinMgr:SetPinGroupShown(MAP_FILTER_WAYSHRINES, not value)
                      end
                  end
              end) end },
        { type = "checkbox", name = "Nomi Bilingui NPC (Italiano / English)",
          tooltip = function() return "Mostra nome italiano e inglese per NPC e nemici. Stato: " .. OnOffLabel(self.savedVars.bilingualNPCNames) end,
          getFunc = function() return self.savedVars.bilingualNPCNames end,
          setFunc = function(value) self.savedVars.bilingualNPCNames = value end },
        { type = "checkbox", name = "Nomi Bilingui nei Tooltips (POI/Keeps/Shrines)",
          tooltip = function() return "Tooltip bilingui. Stato: " .. OnOffLabel(self.savedVars.bilingualPOI) end,
          getFunc = function() return self.savedVars.bilingualPOI end,
          setFunc = function(value) self.savedVars.bilingualPOI = value
              SafeCall(function()
                  if value then
                      HookPoiTooltips()
                      HookShrineTooltips()
                      HookKeepTooltips()
                  end
                  if type(ZO_WorldMap_RefreshAllPOIs) == "function" then ZO_WorldMap_RefreshAllPOIs() end
              end) end },
        { type = "checkbox", name = "Nome Inglese su Nuova Linea",
          tooltip = function() return "Nuova linea. Stato: " .. OnOffLabel(self.savedVars.bilingualNewLine) end,
          getFunc = function() return self.savedVars.bilingualNewLine end,
          setFunc = function(value) self.savedVars.bilingualNewLine = value
              if GetCurrentMapIndex() == TAMRIEL_MAP_INDEX then SafeCall(function() self:RenderMap(self.savedVars.showLocations) end) end end,
          disabled = function() return not self.savedVars.bilingualPOI and not self.savedVars.bilingualMapNames end },
        { type = "colorpicker", name = "Colore Nome Inglese",
          tooltip = "Colore per il nome inglese.",
          getFunc = function() return ZO_ColorDef:New(self.savedVars.bilingualColor):UnpackRGBA() end,
          setFunc = function(r, g, b, a) self.savedVars.bilingualColor = ZO_ColorDef:New(r, g, b, a):ToHex()
              if GetCurrentMapIndex() == TAMRIEL_MAP_INDEX then SafeCall(function() self:RenderMap(self.savedVars.showLocations) end) end end,
          default = ZO_ColorDef:New("FFFFFF"),
          disabled = function() return not self.savedVars.bilingualPOI and not self.savedVars.bilingualMapNames end },
        { type = "dropdown", name = "Font Mappa",
          choicesFunc = function() return lookup.fontNames end,
          choices = lookup.fontNames, choicesValues = lookup.fontValues,
          getFunc = function() return self.savedVars.titleFont end,
          setFunc = function(value) self.savedVars.titleFont = value self:createFont()
              if GetCurrentMapIndex() == TAMRIEL_MAP_INDEX then SafeCall(function() self:RenderMap(self.savedVars.showLocations) end) end end },
        { type = "dropdown", name = "Colore Regioni",
          choicesFunc = function() return lookup.colorNames end,
          choices = lookup.colorNames, choicesValues = lookup.colorValues,
          getFunc = function() return self.savedVars.color end,
          setFunc = function(value) self.savedVars.color = value self:ApplyColors() self:ApplyOpacity()
              if GetCurrentMapIndex() == TAMRIEL_MAP_INDEX then SafeCall(function() self:RenderMap(self.savedVars.showLocations) end) end end },
        { type = "slider", name = GetString(SI_COLOR_PICKER_ALPHA), min = 0, max = 100, step = 1,
          getFunc = function() return self.savedVars.opacity end,
          setFunc = function(value) self.savedVars.opacity = value self:ApplyOpacity()
              if GetCurrentMapIndex() == TAMRIEL_MAP_INDEX then SafeCall(function() self:RenderMap(self.savedVars.showLocations) end) end end },
        { type = "checkbox", name = "LinguaIA (Traduzione Alternativa)",
          tooltip = function() return "Traduzione alternativa. Stato: " .. OnOffLabel(self.savedVars.linguaIA) end,
          getFunc = function() return self.savedVars.linguaIA end,
          setFunc = function(value) self.savedVars.linguaIA = value end },
        { type = "checkbox", name = "Mostra Inglese Oggetti Inventario",
          tooltip = "Mostra nome inglese nei tooltip item.",
          getFunc = function() return self.savedVars.showEnglishItemNames end,
          setFunc = function(value) self.savedVars.showEnglishItemNames = value end, default = true },
		{ type = "checkbox", name = "Ricerca Bilingue Inventario (IT/EN)",
          tooltip = "Cerca gli oggetti per nome italiano o inglese nella barra di ricerca dell'inventario e della banca.",
          getFunc = function() return self.savedVars.enableBilingualSearch ~= false end,
          setFunc = function(value) self.savedVars.enableBilingualSearch = value end,
          default = true },		  
        { type = "header", name = "Integrazioni Addon" },
        { type = "checkbox", name = "Integrazione DolgubonsLazyWritCreator",
          tooltip = "Traduce DolgubonsLazyWritCreator. Richiede riavvio UI.",
          getFunc = function() return self.savedVars.enableDLWCaddon ~= false end,
          setFunc = function(value) self.savedVars.enableDLWCaddon = value end,
          requiresReload = true, width = "full" },
        { type = "texture", image = "/TraduzioneItaESO/textures/flag_it.dds", imageWidth = 24, imageHeight = 24, width = "half" },
        { type = "texture", image = "/TraduzioneItaESO/textures/flag_en.dds", imageWidth = 24, imageHeight = 24, width = "half" },
    }

    LAM:RegisterAddonPanel(addon.name .. "Options", panelData)
    LAM:RegisterOptionControls(addon.name .. "Options", optionsData)

    self:createFont()
    self:ApplyColors()
    self:ApplyOpacity()
end

-- ===========================================================================================
-- createFont
-- ===========================================================================================
function addon:createFont()
    local size, sizeCity = unpack(lookup.fontSizes[self.savedVars.titleFont] or {18, 14})
    self.titleFont = string.format("$(%s)|%i|soft-shadow-thick", self.savedVars.titleFont, size)
    self.cityFont  = string.format("$(%s)|%i|soft-shadow-thick", self.savedVars.titleFont, sizeCity)
end

-- ===========================================================================================
-- MapBlobManager
-- ===========================================================================================
local MapBlobManager = ZO_ObjectPool:Subclass()
addon.MapBlobManager = MapBlobManager

local function MapOverlayControlFactory(pool, controlNamePrefix, templateName, parent)
    local overlayControl = ZO_ObjectPool_CreateNamedControl(controlNamePrefix, "VotansTamrielBlobControl", pool, parent)
    overlayControl:SetAlpha(0)
    ZO_AlphaAnimation:New(overlayControl)
    overlayControl.label = overlayControl:GetNamedChild("Location")
    overlayControl.city  = overlayControl:GetNamedChild("City")
    overlayControl:SetMouseEnabled(false)
    overlayControl.label:SetMouseEnabled(false)
    overlayControl.city:SetMouseEnabled(false)
    return overlayControl
end

function MapBlobManager:New(blobContainer)
    local blobFactory = function(pool)
        return MapOverlayControlFactory(pool, "VotansTamrielMapBlob", "VotansTamrielBlobControl", blobContainer)
    end
    return ZO_ObjectPool.New(self, blobFactory, ZO_ObjectPool_DefaultResetControl)
end

local function NormalizedLabelDataToUI(x, y)
    local w, h = ZO_WorldMapContainer:GetDimensions()
    return (x or 0) * w, (y or 0) * h
end

local function NormalizedBlobDataToUI(blobWidth, blobHeight, blobXOffset, blobYOffset)
    local w, h = ZO_WorldMapContainer:GetDimensions()
    return blobWidth * w, blobHeight * h, blobXOffset * w, blobYOffset * h
end

local function ShowMapTexture(textureControl, textureName, width, height, offsetX, offsetY)
    textureControl:SetTexture(textureName)
    textureControl:SetDimensions(width, height)
    textureControl:SetSimpleAnchorParent(offsetX, offsetY)
    textureControl:SetAlpha(1)
    textureControl:SetHidden(false)
end

local textureChanged
function MapBlobManager:Update(normalizedMouseX, normalizedMouseY)
    local locationName, textureFile, widthN, heightN, locXN, locYN = GetMapMouseoverInfo(normalizedMouseX, normalizedMouseY)
    local textureUIWidth, textureUIHeight, textureXOffset, textureYOffset = NormalizedBlobDataToUI(widthN, heightN, locXN, locYN)
    if self.m_zoom ~= ZO_WorldMap_GetPanAndZoom():GetCurrentCurvedZoom() then
        self.m_zoom = ZO_WorldMap_GetPanAndZoom():GetCurrentCurvedZoom()
        textureChanged = true
    end
    if textureChanged then
        if textureFile ~= "" then
            local blob = self:AcquireObject(textureFile)
            if blob then
                ShowMapTexture(blob, textureFile, textureUIWidth, textureUIHeight, textureXOffset, textureYOffset)
                blob.label:SetFont(addon.titleFont)
                blob.label:SetAlpha(math.max(0, 3 - self.m_zoom * 2.2))
                return blob
            end
        end
    end
end

-- ===========================================================================================
-- ForceBlobForLocation
-- ===========================================================================================
function MapBlobManager:ForceBlob(blobKey, queryX, queryY)
    local w, h = ZO_WorldMapContainer:GetDimensions()
    local blob = self:AcquireObject(blobKey)
    if not blob then return nil end
    blob:SetTexture("")
    blob:SetDimensions(1, 1)
    blob:SetSimpleAnchorParent(queryX * w, queryY * h)
    blob:SetAlpha(1)
    blob:SetHidden(false)
    blob.label:SetFont(addon.titleFont)
    blob.label:SetAlpha(math.max(0, 3 - (self.m_zoom or 1) * 2.2))
    return blob
end

function addon:GetAllianceColor(location)
    return self.color[location.alliance] or self.defaultColor
end
function addon:AllianceDefaultColor()
    return self.defaultColor
end
function addon:GetNoColor(location)
    return self.transparentColor
end
function addon:GetBaseGameColor(location)
    return location and (location.index < 27 or location.index == 30) and self.baseGameColor or self.dlcGameColor
end

-- ===========================================================================================
-- RenderMap
-- ===========================================================================================
function addon:RenderMap(isTamriel)
    local positions = self.positions
    local gps = LibGPS3
    if not gps then return end
    local bm = self.blobManager
    local hidePins = not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_WAYSHRINES)
    local showCities, showLocations = self.savedVars.showCitiesNames, self.savedVars.showLocations
    local currentLang = GetCVar("language.2")

    for i, pos in pairs(positions) do
        local location = self.locations[i]
        if location then
            local x, y = pos:GetOffset()
            local w, h = pos:GetScale()
            x, y = x + w / 2, y + h / 2

            local isCosmic     = (location.cosmic == true)
            local isTam        = (isTamriel == true)
            local hasFixedBlob = (location.blobX ~= nil and location.blobY ~= nil)
            local hasValidPos  = (x > 0 and x < 1 and y > 0 and y < 1)
            local isCyrodiilOnTamriel = (isCosmic and hasFixedBlob and isTam and location.tamriel == true)

            local shouldRender = false
            if hasValidPos and ((not isCosmic) == isTam) then
                shouldRender = true
            elseif isCosmic and (not isTam) and hasFixedBlob and not hasValidPos then
                shouldRender = true
            elseif (not isCosmic) and hasFixedBlob and isTam and not hasValidPos then
                shouldRender = true
            elseif isCyrodiilOnTamriel then
                shouldRender = true
            end

            if shouldRender then
                local queryX = location.blobX or (x + (location.offsetX or 0))
                local queryY = location.blobY or (y + (location.offsetY or 0))

                local blob
                if isCyrodiilOnTamriel then
                    blob = bm:ForceBlob("cyrodiil_tamriel_blob_" .. i, queryX, queryY)
                else
                    blob = bm:Update(queryX, queryY)
                end

                if blob then
                    do
                        local englishName = location.name or ""
                        local italianName = TraduzioneItaESO.reverseTable and TraduzioneItaESO.reverseTable[englishName] or nil
                        local cleanedItalian = italianName and italianName:gsub("%^%a+", "") or nil
                        if TraduzioneItaESO.savedVars and TraduzioneItaESO.savedVars.bilingualMapNames and cleanedItalian and cleanedItalian ~= "" and cleanedItalian ~= englishName then
                            if TraduzioneItaESO.savedVars.bilingualNewLine then
                                blob.label:SetText(ZO_CachedStrFormat(SI_WORLD_MAP_LOCATION_NAME, englishName) .. "\n" .. cleanedItalian)
                            else
                                blob.label:SetText(ZO_CachedStrFormat(SI_WORLD_MAP_LOCATION_NAME, englishName) .. " (" .. cleanedItalian .. ")")
                            end
                        else
                            blob.label:SetText(ZO_CachedStrFormat(SI_WORLD_MAP_LOCATION_NAME, englishName))
                        end
                    end

                    blob.label:SetHidden(not showLocations)
                    if showLocations then
                        local locXN, locYN = NormalizedLabelDataToUI(location.labelX, location.labelY)
                        blob.label:SetAnchor(CENTER, nil, CENTER, locXN, locYN)
                    end

                    local color = self:GetColor(location)
                    local r, g, b, a = color:UnpackRGBA()
                    blob:SetColor(1, 1, 1, 1, a)
                    blob:SetColor(2, r, g, b, a)
                    blob:SetColor(3, r, g, b, a)
                    blob:SetColor(4, r, g, b, a)

                    if location.hidden then blob.label:SetText("") end

                    blob.city:SetFont(self.cityFont)
                    local cityEnglish = location.cityName or ""
                    local cityItalian = self.reverseTable[cityEnglish] or cityEnglish
                    local cleanedCityItalian = cityItalian:gsub("%^%a+", "")
                    local cityText = currentLang == "it" and cleanedCityItalian or cityEnglish
                    if currentLang == "it" then
                        if self.savedVars.bilingualMapNames and self.translationTable[cleanedCityItalian] and cleanedCityItalian ~= self.translationTable[cleanedCityItalian] then
                            cityText = self.savedVars.bilingualNewLine
                                and zo_strformat("<<1>>\n<<2>>", cleanedCityItalian, ColorizeEnglish(self.translationTable[cleanedCityItalian]))
                                or  zo_strformat("<<1>> (<<2>>)", cleanedCityItalian, ColorizeEnglish(self.translationTable[cleanedCityItalian]))
                        elseif self.savedVars.useEnglishNames then
                            cityText = self.translationTable[cleanedCityItalian] or cleanedCityItalian
                        end
                    end
                    blob.city:SetText(ZO_CachedStrFormat("<<!AC:1>>", cityText))

                    if location.poi and showCities then
                        local _, known, localX, localY = GetFastTravelNodeInfo(location.poi)
                        if known then
                            location.poiGlobalX = localX
                            location.poiGlobalY = localY
                        end
                        local locXN = location.poiGlobalX
                        local locYN = location.poiGlobalY
                        local labelX, labelY = x + (location.labelX or 0), y + (location.labelY or 0)
                        local labelUIX, labelUIY = NormalizedLabelDataToUI(labelX, labelY)
                        local poiUIX, poiUIY = NormalizedLabelDataToUI(locXN, locYN)
                        poiUIY = poiUIY + (hidePins and -6 or 13)
                        local w2, h1 = blob.label:GetDimensions()
                        local overlapH1, overlapH2 = h1 * 2 / 3, h1 / 3
                        if showLocations and blob.label:GetAlpha() > 0.1
                            and ((labelUIY - overlapH1) < poiUIY and (labelUIY + overlapH2) > poiUIY)
                            and ((labelUIX - 64) < poiUIX and (labelUIX + 64) > poiUIX) then
                            blob.city:SetAnchor(TOP, blob.label, BOTTOM, 0, -3)
                        else
                            blob.city:SetAnchor(TOP, ZO_WorldMapContainer, TOPLEFT, poiUIX, poiUIY)
                        end
                    elseif isCyrodiilOnTamriel and location.cityName and showCities then
                        blob.city:SetAnchor(TOP, blob.label, BOTTOM, 0, 2)
                    elseif location.cosmic and location.cityName and showCities then
                        blob.city:SetAnchor(TOP, blob.label, BOTTOM, 0, 2)
                    elseif hasFixedBlob and location.cityName and showCities then
                        blob.city:SetAnchor(TOP, blob.label, BOTTOM, 0, 2)
                    else
                        blob.city:ClearAnchors()
                    end
                    blob.city:SetHidden(not location.cityName or not self.savedVars.showCitiesNames)
                end
            end
        end
    end

    if GetCurrentMapIndex() == TAMRIEL_MAP_INDEX and self.savedVars.hidePinsOnTamriel then
        ZO_WorldMap_GetPinManager():SetPinGroupShown(MAP_FILTER_WAYSHRINES, false)
    end
end

function addon:Hide()
    self.blobManager:ReleaseAllObjects()
end

function addon:HookPOIPins()
    local GetCurrentMapIndex = GetCurrentMapIndex
    local panZoom = ZO_WorldMap_GetPanAndZoom()
    local function HookPinSize(data)
        local orgMetaTable = getmetatable(data)
        local orgSize = data.size or 40
        local orgTint = data.tint or ZO_DEFAULT_COLOR
        data.size, data.tint = nil, nil
        local newMetaTable = {}
        setmetatable(newMetaTable, orgMetaTable)
        local alter = {}
        alter.size = function()
            return GetCurrentMapIndex() == 1 and (orgSize * panZoom:GetCurrentNormalizedZoom()) or orgSize
        end
        newMetaTable.__index = function(data, key)
            return alter[key] and alter[key](data) or newMetaTable[key]
        end
        newMetaTable.__newindex = function(data, key, value)
            if key == "size" then orgSize = value return
            elseif key == "tint" then orgTint = value return end
            return rawset(data, key, value)
        end
        setmetatable(data, newMetaTable)
    end
    HookPinSize(ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE])
    HookPinSize(ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE_CURRENT_LOC])
end



-- ===========================================================================================
-- InitializeMap
-- ===========================================================================================
local _cosmicPlaceholderMeta = {}
_cosmicPlaceholderMeta.__index = _cosmicPlaceholderMeta
function _cosmicPlaceholderMeta:GetOffset() return 0.5, 0.5 end
function _cosmicPlaceholderMeta:GetScale()  return 0.001, 0.001 end

local function MakeCosmicPlaceholder()
    return setmetatable({}, _cosmicPlaceholderMeta)
end

function addon:InitializeMap()
    self:InitSettings()
    local gps = LibGPS3
    local positions = {}

    -- Mappa nomi italiani (restituiti da GetMapName() quando il gioco è in IT)
    -- verso l'indice corretto in self.locations[].
    -- Necessaria perché ESO restituisce nomi tradotti e gli indici non coincidono
    -- con quelli dell'array locations[] (specialmente dopo i=34).
    local itToLocIdx = {
        -- i=35 in gioco = Northern Elsweyr (locations[36])
        ["elsweyr settentrionale"]                      = 36,
        -- i=36 in gioco = Southern Elsweyr (locations[37])
        ["elsweyr meridionale"]                         = 37,
        ["elsweyr meridionale^f"]                       = 37,
        -- i=37 in gioco = Western Skyrim (locations[38])
        ["skyrim occidentale"]                          = 38,
        -- i=38 in gioco = Blackreach: Greymoor Caverns (locations[39])
        ["confine oscuro: caverne di greymoor"]         = 39,
        -- i=39 in gioco = Blackreach (locations[40])
        ["confine oscuro"]                              = 40,
        -- i=40 in gioco = Blackreach: Arkthzand Cavern (locations[41])
        ["confine oscuro: caverna di arkthzand"]        = 41,
        -- i=41 in gioco = The Reach (locations[42])
        ["le terre alte"]                               = 42,
        ["le terre alte^n"]                             = 42,
        -- i=42 in gioco = Blackwood (locations[43])
        ["bosco nero"]                                  = 43,
        ["bosco nero^m"]                                = 43,
        -- i=43 in gioco = Blackwood ('cava^F' = Leyawiin area) (locations[43])
        ["cava^f"]                                      = 43,
        -- i=44 in gioco = The Deadlands 'Terre morte' (locations[45])
        -- NB: Fargrave (locations[44]) è cosmico, non appare nella lista mappe
        ["terre morte"]                                 = 45,
        -- i=45 in gioco = High Isle (locations[46])
        ["l'isola alta e amenos"]                       = 46,
        -- i=46 in gioco = Fargrave City 'Distretto...' (locations[47], hidden)
        ["distretto della città di cava"]               = 47,
        -- i=47 in gioco = Galen 'Galen e Y'ffelon' (locations[48])
        -- varianti apostrofo: dritto, curvo UTF-8, senza
        ["galen e y'ffelon"]                            = 48,
        ["galen e y\xe2\x80\x99ffelon"]                = 48,
        ["galen e yffelon"]                             = 48,
        -- i=48 in gioco = Telvanni Peninsula (locations[49])
        ["penisola telvanni"]                           = 49,
        -- i=49 in gioco = Apocrypha (locations[50])
        ["apocrypha^f"]                                 = 50,
        ["apocrypha"]                                   = 50,
        -- i=50 in gioco = West Weald (locations[52])
        ["selva di ponente"]                            = 52,
        -- i=51 in gioco = Eyevea (locations[51]) - fallback i=51 già corretto
        ["eyevea"]                                      = 51,
        -- i=52 in gioco = Eastern Solstice (locations[53])
        ["solstizio"]                                   = 53,
    }

    if gps then gps:PushCurrentMap() end
    for i = 1, GetNumMaps() do
        SetMapToMapListIndex(i)
        local measurement
        if gps then measurement = gps:GetCurrentMapMeasurement() end

        -- Determina l'indice corretto in self.locations[]
        -- Prima cerca per nome IT, poi fallback all'indice numerico
        local rawName = GetMapName() or ""
        local locIdx = itToLocIdx[SafeLower(rawName)] or i

        if measurement and measurement:IsValid() then
            positions[locIdx] = positions[locIdx] or measurement
            local location = self.locations[locIdx]
            if location then
                location.index = i
                if location.poi then
                    local _, known, localX, localY = GetFastTravelNodeInfo(location.poi)
                    if known then
                        location.poiGlobalX = localX
                        location.poiGlobalY = localY
                    end
                end
            end
        else
            local location = self.locations[locIdx]
            if location then
                location.index = i
                if location.blobX and location.blobY then
                    positions[locIdx] = positions[locIdx] or MakeCosmicPlaceholder()
                end
            end
        end
    end
    -- Forza i placeholder per le zone cosmiche che non appaiono nella lista mappe
    -- (es. Fargrave non ha un indice proprio nel loop GetNumMaps)
    for locIdx, loc in ipairs(self.locations) do
        if loc.cosmic and loc.blobX and loc.blobY and not positions[locIdx] then
            positions[locIdx] = MakeCosmicPlaceholder()
        end
    end

    self.positions = positions
    if gps then gps:PopCurrentMap() end

    local blobContainer = ZO_WorldMapContainer
    if not self.blobManager then
        self.blobManager = MapBlobManager:New(blobContainer)
    end
    self.layout = { level = 30, size = 32, insetX = 4, insetY = 4, texture = "" }

    local TAMRIEL_MAP_INDEX = GetMapIndexById(27)
    local AURBIS_MAP_INDEX  = GetMapIndexById(439)

    local function LayoutPins(pinManager)
        self:Hide()
        local mapIndex = GetCurrentMapIndex()
        if mapIndex == TAMRIEL_MAP_INDEX or mapIndex == AURBIS_MAP_INDEX then
            textureChanged = true
            SafeCall(function() self:RenderMap(mapIndex == TAMRIEL_MAP_INDEX) end)
            textureChanged = false
        end
    end

    ZO_WorldMap_GetPinManager():AddCustomPin(self.pinType, LayoutPins, LayoutPins, self.layout)
    self.pinTypeId = _G[self.pinType]
    ZO_WorldMap_GetPinManager():SetCustomPinEnabled(self.pinTypeId, true)
end

function addon:AddFont(font, displayText, size, sizeCity)
    lookup.fonts[#lookup.fonts + 1] = {name = displayText, data = font}
    lookup.fontSizes[font] = {size or 18, sizeCity or 14}
end

-- Nomi font e colori fissi in italiano: non dipendono da addon esterni
-- (GetString(SI_VOTANS_TAMRIEL_MAP_FONT_*) ritorna "" se Votan's Tamriel Map
-- non e' installato, causando dropdown senza etichetta / errori LAM2)
addon:AddFont("", "Predefinito")
addon:AddFont("MEDIUM_FONT", "Medio")
addon:AddFont("BOLD_FONT", "Grassetto")
addon:AddFont("CHAT_FONT", "Chat")
addon:AddFont("GAMEPAD_LIGHT_FONT", "Gamepad Leggero", 22, 18)
addon:AddFont("GAMEPAD_MEDIUM_FONT", "Gamepad Medio", 22, 18)
addon:AddFont("GAMEPAD_BOLD_FONT", "Gamepad Grassetto", 22, 18)
addon:AddFont("ANTIQUE_FONT", "Antico")
addon:AddFont("HANDWRITTEN_FONT", "Scritto a Mano", 16, 12)
addon:AddFont("STONE_TABLET_FONT", "Tavola di Pietra", 14, 10)

local function AddColor(color, displayText)
    lookup.colors[#lookup.colors + 1] = {name = displayText, data = color}
end
AddColor("Alliance", "Alleanza")
AddColor("BaseGame", "GiocoBase/DLC")
AddColor("None", "Nessuno")


em:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= addon.name then return end
    em:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
    addon:Initialize()
end)

-- ===========================================================================================
-- Initialize
-- ===========================================================================================
function addon:Initialize()
    DebugLog(string.format("[TraduzioneItaESO] Caricato v%s", addon.version))
    TraduzioneItaESO_Vars = TraduzioneItaESO_Vars or {}
    self.savedVars = ZO_SavedVars:NewAccountWide("TraduzioneItaESO_Vars", 1, nil, {
        language = "it",
        showNotifications = true,
        enableUI = true,
        hideDuringGameplay = true,
        bilingualMapNames = true,
        bilingualNPCNames = true,
        useEnglishNames = true,
        showLocations = true,
        showCitiesNames = true,
        bilingualPOI = true,
        bilingualNewLine = true,
        bilingualColor = "FFFFFF",
        hidePinsOnTamriel = true,
        opacity = 50,
        titleFont = "ANTIQUE_FONT",
        color = "Alliance",
        linguaIA = true,
        showEnglishItemNames = true,
        enableDLWCaddon = true,
        enableTTCaddon = true,
		enableBilingualSearch = true,
    })


-- Integrazione DolgubonsLazyWritCreator
    if self.savedVars.enableDLWCaddon ~= false then
        EVENT_MANAGER:RegisterForEvent("TraduzioneItaESO_DLWC", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "DolgubonsLazyWritCreator" then
                EVENT_MANAGER:UnregisterForEvent("TraduzioneItaESO_DLWC", EVENT_ADD_ON_LOADED)
                -- Applica le traduzioni italiane SOLO se la lingua è impostata su italiano
                if GetCVar("language.2") ~= "it" then
                    DebugLog("TraduzioneItaESO: DolgubonsLazyWritCreator - lingua EN, traduzioni non applicate")
                    return
                end
                zo_callLater(function()
                    -- Non applicare traduzioni italiane se la lingua è inglese
                    if GetCVar("language.2") ~= "it" then
                        DebugLog("TraduzioneItaESO: DolgubonsLazyWritCreator saltato (lingua EN)")
                        return
                    end
                    local success, translations = pcall(dofile, "AddOns/TraduzioneItaESO/addon/DolgubonsLazyWritCreatorIT/it.lua")
                    if success and translations and WritCreater and WritCreater.Strings then
                        for key, value in pairs(translations) do
                            WritCreater.Strings[key] = value
                        end
                        DebugLog("TraduzioneItaESO: DolgubonsLazyWritCreator tradotto in italiano")
                    end
                end, 1000)
            end
        end)
    end

    -- Integrazione TTC
    if self.savedVars.enableTTCaddon ~= false then
        self:InitializeTTCIntegration()
    end

    self:HookTTCItemNames()
    ApplySafeStrings()
    HookTooltipAddLines()
	HookLayoutGenericItem()

    -- Ripristino tabelle dati salvate prima del reset della tabella globale
    addon.ZoneTranslations  = _savedZoneTrans  or addon.ZoneTranslations  or {}
    addon.NPCTranslations   = _savedNPCTrans   or addon.NPCTranslations   or {}
    addon.ItemsTranslations = _savedItemTrans  or addon.ItemsTranslations or {}

    PreprocessTable(addon.ItemsTranslations)
    PreprocessTable(addon.ZoneTranslations)
    PreprocessTable(addon.NPCTranslations)
    TraduzioneItaESO.ItemsTranslations = addon.ItemsTranslations
    TraduzioneItaESO.ZoneTranslations  = addon.ZoneTranslations
    TraduzioneItaESO.NPCTranslations   = addon.NPCTranslations




    LoadTranslationTable()

    -- Override GetUnitName con supporto NPC bilingue
    do
        local _origGetUnitName = GetUnitName
        GetUnitName = function(unitTag)
            local name = _origGetUnitName(unitTag)
            if not name or name == "" then return name end
            local isDlg = (unitTag == "interact")
            local ok2, display = pcall(GetBilingualNPCName, name, isDlg)
            if ok2 and display and display ~= "" then return display end
            if name:find("%^[iI]") then
                local ok, c = pcall(ProcessMarkers, name)
                if ok and c then name = c end
            end
            name = name:gsub("%^%a+", "")
            return name
        end
    end

    local currentLang = GetCVar("language.2")
    if currentLang == "it" and self.savedVars.linguaIA then
        SafeCall(function()
            dofile("AddOns/TraduzioneItaESO/gamedata/lang/lang/it.lang")
            dofile("AddOns/TraduzioneItaESO/esoui/lang/it_client.str")
            dofile("AddOns/TraduzioneItaESO/esoui/lang/ir_pregame.str")
        end)
    end

    if self.savedVars.bilingualPOI then
        HookShrineTooltips()
        HookPoiTooltips()
        HookKeepTooltips()
    end

    HookReconstructionAndTransmutationUI()
    RefreshUI()

    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_RETICLE_HIDDEN_UPDATE, function(eventCode, hidden)
        UpdateUIVisibility(hidden)
    end)

    if self.savedVars.bilingualMapNames or self.savedVars.useEnglishNames then
        EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ZONE_UPDATE, SafeEventHandler)
        EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_MAP_CHUNK_INFO_RECEIVED, SafeEventHandler)
        ZO_PreHook(ZO_WorldMap, "OnShow", function() SafeCall(UpdateMapName) end)
        ZO_PreHook(ZO_WorldMap, "OnHidden", function() SafeCall(function() addon:Hide() end) end)
        addon.lastZoom = ZO_WorldMap_GetPanAndZoom():GetCurrentCurvedZoom()

        EVENT_MANAGER:RegisterForUpdate(addon.name .. "_MapUpdate", 50, function()
            if ZO_WorldMap:IsHidden() then return end
            local tamrielIdx = GetMapIndexById(27)
            local aurbisIdx  = GetMapIndexById(439)
            local currentIdx = GetCurrentMapIndex()
            if currentIdx ~= tamrielIdx and currentIdx ~= aurbisIdx then
                SafeCall(function() addon:Hide() end)
                return
            end
            local currentZoom = ZO_WorldMap_GetPanAndZoom():GetCurrentCurvedZoom()
            if math.abs(currentZoom - addon.lastZoom) > 0.001 then
                addon.lastZoom = currentZoom
                SafeCall(function() addon:RenderMap(addon.savedVars.showLocations) end)
            end
        end)
    end

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, SafeEventHandler)

    SafeCall(UpdateMapName)
    addon:InitializeMap()

    local hooked = TryHookSetText()
    if not hooked then
        StartUpdater()
        zo_callLater(function()
            if TryHookSetText() then
                EVENT_MANAGER:UnregisterForUpdate(addon.name .. "_Updater")
            end
        end, 1000)
    end


    local hooked = TryHookSetText()
    if not hooked then
        StartUpdater()
        zo_callLater(function()
            if TryHookSetText() then
                EVENT_MANAGER:UnregisterForUpdate(addon.name .. "_Updater")
            end
        end, 1000)
    end

    -- NOTA: il hook su zo_strformat e la scansione runtime della skill window
    -- sono stati rimossi perché qualsiasi SetText su controlli della skill window
    -- (anche indiretto tramite timer o hook) causa taint permanente sulle slot,
    -- rompendo il drag delle abilità con:
    -- "Attempt to access a private function 'PickupAbilityById' from insecure code"
    -- I nomi delle abilità sono già tradotti da item_it.lua/npc_it.lua al caricamento.

    zo_callLater(function()
        local function patchFrame(f)
            if not f or f.__TradItaNameHooked then return end
            f.__TradItaNameHooked = true
            for _, m in ipairs({"UpdateName", "UpdateAll", "OnUnitCreated"}) do
                if type(f[m]) == "function" then
                    ZO_PostHook(f, m, function(self)
                        local tag = (type(self) == "table" and self.unitTag) or "reticleover"
                        if not DoesUnitExist(tag) then return end
                        local nc = _G["ZO_TargetUnitFrame" .. tag .. "Name"]
                                or WINDOW_MANAGER:GetControlByName("ZO_TargetUnitFrame" .. tag .. "Name")
                        if nc and nc.GetText and nc.SetText then
                            local ok, cur = pcall(nc.GetText, nc)
                            if ok and cur and cur ~= "" and cur:find("%^") then
                                local disp = GetBilingualNPCName(cur)
                                if disp ~= cur then pcall(nc.SetText, nc, disp) end
                            end
                        end
                    end)
                end
            end
        end
        patchFrame(ZO_TargetUnitFramereticleover)
        if TARGET_UNIT_FRAMES then
            for _, frame in pairs(TARGET_UNIT_FRAMES.unitFrames or {}) do patchFrame(frame) end
        end
    end, 2000)

    -- =========================================================================
    -- Pulizia nomi NPC nel reticle
    -- =========================================================================
    local boia = { counter = 0, lastUnit = nil, Label = nil, updateId = nil, modified = {}, requestNextDump = false }

    local LMP = nil
    if type(LibAddonProvider) ~= "nil" then
        LMP = LibAddonProvider
    elseif LibStub then
        local ok, lib = pcall(function() return LibStub("LibMediaProvider-1.0") end)
        if ok then LMP = lib end
    end

    local function Norm(s)
        return SafeLower(SafeTrim(tostring(s or "")))
    end

    local function CreateLabel()
        local wm = WINDOW_MANAGER
        if not wm or not GuiRoot then return nil end
        local lbl = wm:CreateControl("NPC_Clean_FontLabel", GuiRoot, CT_LABEL)
        if not lbl then return nil end
        pcall(function() lbl:SetColor(1, 1, 1, 1) end)
        pcall(function() lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER) end)
        pcall(function() lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER) end)
        pcall(function() lbl:SetHidden(true) end)
        pcall(function() if lbl.SetDimensions then lbl:SetDimensions(420, 28) end end)
        pcall(function() if lbl.SetDrawLevel then lbl:SetDrawLevel(2000) end end)
        if LMP and type(LMP.Fetch) == "function" then
            local ok, font = pcall(function() return LMP:Fetch("font", "Univers 57") end)
            if ok and font then pcall(function() lbl:SetFont(font) end)
            else pcall(function() lbl:SetFont("ZoFontGameLarge") end) end
        else
            pcall(function() lbl:SetFont("ZoFontGameLarge") end)
        end
        return lbl
    end

    local function EnsureLabel()
        if not boia.Label then boia.Label = CreateLabel() end
        return boia.Label
    end

    local function MarkModified(ctrl)
        if not ctrl then return end
        local id = tostring(ctrl)
        if not boia.modified[id] then
            boia.modified[id] = {
                ctrl = ctrl,
                wasHidden = (ctrl.IsHidden and pcall(ctrl.IsHidden, ctrl) and ctrl:IsHidden()) or nil,
                wasText   = (ctrl.GetText  and (pcall(ctrl.GetText,  ctrl) and ctrl:GetText()  or nil)) or nil,
                wasAlpha  = (ctrl.GetAlpha and (pcall(ctrl.GetAlpha, ctrl) and ctrl:GetAlpha() or nil)) or nil,
            }
        end
    end

    local function OverwriteControlText(ctrl, newText)
        if not ctrl then return false end
        MarkModified(ctrl)
        if ctrl.SetText then pcall(ctrl.SetText, ctrl, newText) return true end
        if ctrl.SetHidden then pcall(ctrl.SetHidden, ctrl, true) end
        if ctrl.SetAlpha  then pcall(ctrl.SetAlpha,  ctrl, 0)    end
        return false
    end

    local function HideTargetFrameNames(orig, replacementText)
        local targetNorm = Norm(orig)
        local found = 0
        if ZO_TargetUnitFrame then
            local function recurse(control)
                if not control then return end
                if control.GetText then
                    local ok, text = pcall(control.GetText, control)
                    if ok and text and tostring(text) ~= "" then
                        if Norm(text):find(targetNorm, 1, true) then
                            if OverwriteControlText(control, replacementText) then found = found + 1 end
                        end
                    end
                end
                local num = control.GetNumChildren and control:GetNumChildren() or 0
                for i = 1, num do
                    local ok2, child = pcall(control.GetChild, control, i)
                    if ok2 and child then recurse(child) end
                end
            end
            recurse(ZO_TargetUnitFrame)
            local parent = ZO_TargetUnitFrame:GetParent()
            if parent then recurse(parent) end
        end
        return found
    end

    local function HideGlobalNameLabels(targetNameNorm, replacementText)
        if not targetNameNorm or targetNameNorm == "" then return 0 end
        local found = 0
        local function recurse(control)
            if not control then return end
            if control.GetText then
                local ok, text = pcall(control.GetText, control)
                if ok and text and tostring(text) ~= "" then
                    if Norm(text):find(targetNameNorm, 1, true) then
                        if OverwriteControlText(control, replacementText) then found = found + 1 end
                    end
                end
            end
            local num = control.GetNumChildren and control:GetNumChildren() or 0
            for i = 1, num do
                local ok2, child = pcall(control.GetChild, control, i)
                if ok2 and child then recurse(child) end
            end
        end
        recurse(GuiRoot)
        return found
    end

    local function RestoreModified()
        for k, v in pairs(boia.modified) do
            local c = v.ctrl
            if c then
                if v.wasText   ~= nil and c.SetText   then pcall(c.SetText,   c, v.wasText)   end
                if v.wasHidden ~= nil and c.SetHidden then pcall(c.SetHidden, c, v.wasHidden) end
                if v.wasAlpha  ~= nil and c.SetAlpha  then pcall(c.SetAlpha,  c, v.wasAlpha)  end
            end
        end
        boia.modified = {}
    end

    local function WriteCleanName()
        local ctrl = ZO_TargetUnitFramereticleoverName
        if not ctrl or not ctrl.SetText then return false end
        local unit = "reticleover"
        if not DoesUnitExist(unit) then return false end
        local orig = GetUnitName(unit) or ""
        local cleaned = ProcessMarkers(orig)
        pcall(ctrl.SetText, ctrl, cleaned)
        return true
    end

    local function UpdateLabel()
        local unit = "reticleover"
        if not DoesUnitExist(unit) then
            if boia.Label then boia.Label:SetHidden(true) end
            boia.lastUnit = nil
            RestoreModified()
            return
        end
        local orig    = GetUnitName(unit) or ""
        local cleaned = ProcessMarkers(orig)
        local wroteDirect = WriteCleanName()
        if not wroteDirect then
            if ZO_TargetUnitName          and ZO_TargetUnitName.SetHidden          then pcall(ZO_TargetUnitName.SetHidden,          ZO_TargetUnitName,          true) end
            if ZO_TargetUnitNameContainer and ZO_TargetUnitNameContainer.SetHidden then pcall(ZO_TargetUnitNameContainer.SetHidden, ZO_TargetUnitNameContainer, true) end
            if ZO_TargetUnitNameLabel     and ZO_TargetUnitNameLabel.SetHidden     then pcall(ZO_TargetUnitNameLabel.SetHidden,     ZO_TargetUnitNameLabel,     true) end
            local found1 = HideTargetFrameNames(orig, cleaned)
            if found1 == 0 then
                HideGlobalNameLabels(Norm(orig), cleaned)
            end
        end
        local lbl = EnsureLabel()
        if lbl then
            if ZO_TargetUnitFrame and not ZO_TargetUnitFrame:IsHidden() then
                lbl:ClearAnchors()
                lbl:SetAnchor(CENTER, ZO_TargetUnitFrame, CENTER, 0, 0)
            else
                lbl:ClearAnchors()
                lbl:SetAnchor(TOP, GuiRoot, TOP, 0, 50)
            end
            lbl:SetText(cleaned)
            lbl:SetHidden(false)
        end
        boia.lastUnit = unit
    end

    local function OnUpdateTimer()
        if DoesUnitExist("reticleover") then
            UpdateLabel()
        else
            if boia.updateId then
                EVENT_MANAGER:UnregisterForUpdate(boia.updateId)
                boia.updateId = nil
            end
        end
    end

    local function OnTargetChanged()
        if not boia.updateId then
            EVENT_MANAGER:RegisterForUpdate(addon.name .. "_NPC_CLEAN_FAST", 200, OnUpdateTimer)
            boia.updateId = addon.name .. "_NPC_CLEAN_FAST"
        end
        UpdateLabel()
    end

    EnsureLabel()
    EVENT_MANAGER:RegisterForEvent(addon.name .. "_NPC_CLEAN", EVENT_RETICLE_TARGET_CHANGED, OnTargetChanged)
    EVENT_MANAGER:RegisterForUpdate(addon.name .. "_NPC_CLEAN_TIMER", 2000, function()
        if DoesUnitExist("reticleover") then UpdateLabel() end
    end)

end -- fine Initialize

-- ===========================================================================================


-- Hook DungeonFinder Keyboard - Nomi Bilingui IT + EN
-- Fix veteran: il testo contiene |t...texture...|t (icona scudo) prima del nome.
-- Bisogna rimuovere i tag |t...|t prima del lookup e poi ricostruire con l'inglese.
-- ===========================================================================================

local _lfgCache = nil

local function GetLfgCache()
    if _lfgCache then return _lfgCache end
    _lfgCache = {}
    if addon and addon.translationTable then
        for k, v in pairs(addon.translationTable) do
            _lfgCache[k] = v
        end
    end
    if addon and addon.ZoneTranslations then
        for itZone, enZone in pairs(addon.ZoneTranslations) do
            if type(itZone) == "string" and type(enZone) == "string" then
                local norm = NormalizeName(SafeTrim(itZone:gsub("%^%a+","")))
                if norm ~= "" and not _lfgCache[norm] then
                    _lfgCache[norm] = enZone
                end
            end
        end
    end
    return _lfgCache
end

-- Estrae il prefisso texture (|t...|t) e il nome pulito da un testo ESO
local function SplitTextureAndName(txt)
    if not txt then return "", "" end
    -- Cerca prefisso |t....|t seguito da spazio e nome
    local prefix, name = txt:match("^(|t[^|]+|t%s*)(.*)")
    if prefix then
        return prefix, SafeTrim(name)
    end
    return "", SafeTrim(txt)
end

-- Pulisce il nome per il lookup: rimuove color codes, texture tags, markers
local function CleanForLookup(name)
    if not name then return "" end
    name = name:gsub("|c%x%x%x%x%x%x",""):gsub("|r","")
    name = name:gsub("|t[^|]+|t","")
    name = name:gsub("%^%a+","")
    name = name:gsub("\n.*","")
    name = name:gsub("%s*%(%s*[Vv]eteran%s*%)%s*$",""):gsub("%s*[Vv]eteran%s*$","")
    return SafeTrim(name)
end

local function LfgBilingual(txt)
    if not txt or txt == "" then return txt end
    -- Separa eventuale prefisso texture (icona scudo veterano) dal nome
    local prefix, name = SplitTextureAndName(txt)
    local clean = CleanForLookup(name ~= "" and name or txt)
    if clean == "" then return txt end
    if type(NormalizeName) ~= "function" then return prefix .. clean end
    local englishName = GetLfgCache()[NormalizeName(clean)]
    if not englishName or englishName == clean then return prefix .. clean end
    local hex = (addon and addon.savedVars and addon.savedVars.bilingualColor) or "AAAFCB"
    -- Sempre su riga singola per non ridurre l'altezza delle voci nella lista
    return prefix .. clean .. " |c" .. hex .. "(" .. englishName .. ")|r"
end

local function LfgTranslateEntry(entry)
    if not entry then return end
    local textCtrl = entry:GetNamedChild("Text")
    if not textCtrl then
        local ok, num = pcall(entry.GetNumChildren, entry)
        if ok and num then
            for i = 1, num do
                local ok2, child = pcall(entry.GetChild, entry, i)
                if ok2 and child and type(child.GetText) == "function" then
                    local ok3, t = pcall(child.GetText, child)
                    if ok3 and t and t ~= "" then textCtrl = child break end
                end
            end
        end
    end
    if not textCtrl or type(textCtrl.GetText) ~= "function" then return end
    local ok, txt = pcall(textCtrl.GetText, textCtrl)
    if not ok or not txt or txt == "" then return end
    -- Salta se già tradotto (contiene il nostro colore)
    if txt:find("|c" .. ((addon and addon.savedVars and addon.savedVars.bilingualColor) or "AAAFCB")) then return end
    local bilingual = LfgBilingual(txt)
    if bilingual and bilingual ~= txt then
        pcall(textCtrl.SetText, textCtrl, bilingual)
    end
end

local _lfgTimerRunning = false
local BASE = "ZO_DungeonFinder_KeyboardListSectionScrollChildZO_ActivityFinderTemplateNavigationEntry_Keyboard"

local function LfgScanAllDirect()
    for i = 1, 200 do
        local entry = WINDOW_MANAGER:GetControlByName(BASE .. i)
        if not entry then break end
        LfgTranslateEntry(entry)
    end
    local sg = WINDOW_MANAGER:GetControlByName("ZO_DungeonFinder_KeyboardSingularSectionTitle")
    if sg and type(sg.GetText) == "function" then
        local ok, txt = pcall(sg.GetText, sg)
        if ok and txt and txt ~= "" then
            local bil = LfgBilingual(txt)
            if bil ~= txt then pcall(sg.SetText, sg, bil) end
        end
    end
end

local function StartTimer()
    if _lfgTimerRunning then return end
    _lfgTimerRunning = true
    EVENT_MANAGER:RegisterForUpdate("TraduzioneItaESO_LFG", 500, function()
        local panel = WINDOW_MANAGER:GetControlByName("ZO_DungeonFinder_Keyboard")
        if panel and not panel:IsHidden() then
            LfgScanAllDirect()
        else
            EVENT_MANAGER:UnregisterForUpdate("TraduzioneItaESO_LFG")
            _lfgTimerRunning = false
        end
    end)
end

local function StopTimer()
    EVENT_MANAGER:UnregisterForUpdate("TraduzioneItaESO_LFG")
    _lfgTimerRunning = false
end

zo_callLater(function()
    local panel = WINDOW_MANAGER:GetControlByName("ZO_DungeonFinder_Keyboard")
    if not panel then return end
    ZO_PreHookHandler(panel, "OnShow", function()
        _lfgCache = nil
        zo_callLater(function() LfgScanAllDirect() StartTimer() end, 400)
    end)
    ZO_PreHookHandler(panel, "OnHide", StopTimer)
    if not panel:IsHidden() then
        zo_callLater(function() LfgScanAllDirect() StartTimer() end, 600)
    end
end, 3000)

-- Slash commands
-- ===========================================================================================
SLASH_COMMANDS["/itaesoit"] = function()
    addon.savedVars.language = "it"
    ShowLanguageNotification("it")
    SetLanguage("it")
end
SLASH_COMMANDS["/itaesoen"] = function()
    addon.savedVars.language = "en"
    ShowLanguageNotification("en")
    SetLanguage("en")
end
SLASH_COMMANDS["/itaeso"] = function()
    if LibAddonMenu2 then LibAddonMenu2:OpenToPanel(addon.name .. "Options") end
end
SLASH_COMMANDS["/testitaeso"] = function()
    SafeCall(UpdateMapName)
    SafeCall(function() addon:RenderMap(addon.savedVars.showLocations) end)
end
SLASH_COMMANDS["/testtable"] = function()
    local count = 0
    for _ in pairs(addon.translationTable or {}) do count = count + 1 end
    d("translationTable entries: " .. count)
end
SLASH_COMMANDS["/pmtest"] = function(param)
    local input = tostring(param or "")
    d("PMTEST input: [" .. input .. "]")
    if type(_G.ProcessMarkers) == "function" then
        local ok, out = pcall(_G.ProcessMarkers, input)
        if ok then d("PMTEST output: [" .. tostring(out) .. "]")
        else d("PMTEST error: " .. tostring(out)) end
    else
        d("PMTEST: ProcessMarkers non definita")
    end
end

-- ===========================================================================================
-- /debugaurbis
-- ===========================================================================================
SLASH_COMMANDS["/debugaurbis"] = function()
    d("=== DEBUG ZONE COSMICHE (Aurbis) ===")
    local positions = addon.positions or {}
    for i, loc in pairs(addon.locations) do
        if loc.cosmic then
            local pos = positions[i]
            local gpsInfo = "NO GPS"
            if pos then
                local ox, oy = pos:GetOffset()
                local sx, sy = pos:GetScale()
                local cx = ox + sx / 2
                local cy = oy + sy / 2
                gpsInfo = string.format("GPS ok → cx=%.4f cy=%.4f", cx, cy)
            end
            d(string.format("  [%d] '%s' blobX=%s blobY=%s  %s",
                i,
                tostring(loc.name),
                tostring(loc.blobX),
                tostring(loc.blobY),
                gpsInfo))
        end
    end
    d("=== FINE ===")
end

-- ===========================================================================================
-- /trackmouse
-- ===========================================================================================
local trackMouseRunning = false
SLASH_COMMANDS["/trackmouse"] = function()
    if trackMouseRunning then
        EVENT_MANAGER:UnregisterForUpdate("TradIta_TrackMouse")
        trackMouseRunning = false
        d("[TrackMouse] Fermato.")
        return
    end
    trackMouseRunning = true
    d("[TrackMouse] Avviato - passa il mouse sui cerchi senza nome.")
    EVENT_MANAGER:RegisterForUpdate("TradIta_TrackMouse", 500, function()
        if not ZO_WorldMap or ZO_WorldMap:IsHidden() then return end
        local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()
        local mouseX, mouseY = GetUIMousePosition()
        local containerLeft = ZO_WorldMapContainer:GetLeft()
        local containerTop  = ZO_WorldMapContainer:GetTop()
        local normX = (mouseX - containerLeft) / mapWidth
        local normY = (mouseY - containerTop)  / mapHeight
        if normX < 0 or normX > 1 or normY < 0 or normY > 1 then return end
        local locName, texFile = GetMapMouseoverInfo(normX, normY)
        local tex = (texFile and texFile ~= "") and texFile:match("([^/]+)$") or "NESSUNA"
        d(string.format("nX=%.3f nY=%.3f  loc='%s'  tex='%s'", normX, normY, tostring(locName), tex))
    end)
end
SLASH_COMMANDS["/debugmappe"] = function()
    local gps = LibGPS3
    if not gps then d("LibGPS3 non trovato") return end
    d("=== DEBUG MAPPE - inizio scansione ===")
    local results = {}
    -- Indice inverso: nome location -> indice in addon.locations
    local locationsByName = {}
    for locIdx, loc in ipairs(addon.locations) do
        if loc.name then
            locationsByName[loc.name:lower()] = locIdx
        end
    end
    gps:PushCurrentMap()
    for i = 1, GetNumMaps() do
        SetMapToMapListIndex(i)
        local mapName = GetMapName() or ""
        local locIdx = locationsByName[mapName:lower()]
        if locIdx then
            local msg = string.format("i=%d '%s' -> locations[%d] '%s' OK", i, mapName, locIdx, addon.locations[locIdx].name)
            table.insert(results, msg)
            -- Evidenzia i casi dove l'indice non coincide
            if locIdx ~= i then
                d("|cFFFF00MISMATCH: " .. msg .. "|r")
            end
        else
            -- Controlla se c'è una location con indice i (fallback)
            local loc = addon.locations[i]
            if loc then
                local msg = string.format("i=%d '%s' NOMATCH -> locations[%d]='%s'", i, mapName, i, loc.name)
                table.insert(results, msg)
            end
        end
    end
    gps:PopCurrentMap()
    -- Mostra location senza match
    d("--- Zone senza match per nome ---")
    for locIdx, loc in ipairs(addon.locations) do
        local found = false
        for _, r in ipairs(results) do
            if r:find("locations%[" .. locIdx .. "%]") then found = true break end
        end
        if not found then
            d(string.format("|cFF4444locations[%d] '%s' NON TROVATA|r", locIdx, loc.name or "?"))
        end
    end
    -- Salva tutto
    TraduzioneItaESO_Vars = TraduzioneItaESO_Vars or {}
    TraduzioneItaESO_Vars["debugmappe"] = results
    d("=== FINE - " .. #results .. " risultati salvati in debugmappe ===")
    d("Usa: /script for _,v in ipairs(TraduzioneItaESO_Vars['debugmappe'] or {}) do d(v) end")
end

SLASH_COMMANDS["/debugindici"] = function()
    local gps = LibGPS3
    if not gps then d("LibGPS3 non trovato") return end
    local results = {}
    gps:PushCurrentMap()
    for i = 1, GetNumMaps() do
        SetMapToMapListIndex(i)
        local name = GetMapName() or "NIL"
        local loc = addon.locations[i]
        local locName = loc and loc.name or "NESSUNA"
        local line = string.format("i=%d game='%s' loc='%s'%s", 
            i, name, locName,
            (locName ~= "NESSUNA" and name ~= locName and name:lower() ~= locName:lower()) and " <<MISMATCH>>" or "")
        table.insert(results, line)
    end
    gps:PopCurrentMap()
    TraduzioneItaESO_Vars = TraduzioneItaESO_Vars or {}
    TraduzioneItaESO_Vars["debugindici"] = results
    d("Salvato debugindici (" .. #results .. " righe) - fai /reloadui")
    d("Poi: /script for _,v in ipairs(TraduzioneItaESO_Vars['debugindici'] or {}) do d(v) end")
end