-- English is the fallback. German is selected only for a German ESO UI client.
local UF = UnknownFilter

local STRINGS = {
    en = {
        filter = "Filter",
        autoPaging = "Auto-Paging",
        on = "On",
        off = "Off",

        modeOff = "Off",
        modeGear = "Gear",
        modeLearn = "Learnables",
        modeMotif = "Motifs",
        modeCollect = "Collectibles",

        modeGearLong = "Unknown: Gear (Weapons/Armor/Jewelry)",
        modeLearnLong = "Unknown: Learnables",
        modeMotifLong = "Unknown: Motifs",
        modeCollectLong = "Unknown: Collectibles",
        modeOffLong = "Unknown: Off",

        emptyFilteredPage = "No unknown items on this page. Use the native page controls to continue.",
        emptyFilteredPageAuto = "No unknown items on this page. Loading the next page automatically...",
        autoLoadingNextPage = "Loading the next page automatically...",

        notInitialized = "Not initialized",
        currentPageRebuilt = "Current page rebuilt",
        nextPageRequested = "Next page requested",
        noNextPage = "No next page",
        previousPageRequested = "Previous page requested",
        noPreviousPage = "No previous page",
        usage = "usage",
    },
    de = {
        filter = "Filter",
        autoPaging = "Auto-Blättern",
        on = "An",
        off = "Aus",

        modeOff = "Aus",
        modeGear = "Ausrüstung",
        modeLearn = "Erlernbares",
        modeMotif = "Handwerksstile",
        modeCollect = "Sammlungsstücke",

        modeGearLong = "Unbekannt: Ausrüstung (Waffen/Rüstung/Schmuck)",
        modeLearnLong = "Unbekannt: Erlernbares",
        modeMotifLong = "Unbekannt: Handwerksstile",
        modeCollectLong = "Unbekannt: Sammlungsstücke",
        modeOffLong = "Unbekannt: Aus",

        emptyFilteredPage = "Keine unbekannten Gegenstände auf dieser Seite. Mit den Seitentasten fortfahren.",
        emptyFilteredPageAuto = "Keine unbekannten Gegenstände auf dieser Seite. Die nächste Seite wird automatisch geladen...",
        autoLoadingNextPage = "Die nächste Seite wird automatisch geladen...",

        notInitialized = "Nicht initialisiert",
        currentPageRebuilt = "Aktuelle Seite neu aufgebaut",
        nextPageRequested = "Nächste Seite angefordert",
        noNextPage = "Keine nächste Seite",
        previousPageRequested = "Vorherige Seite angefordert",
        noPreviousPage = "Keine vorherige Seite",
        usage = "Verwendung",
    },
}

function UF:SelectLanguage(language)
    language = tostring(language or ""):lower()
    if language:sub(1, 2) ~= "de" then
        language = "en"
    else
        language = "de"
    end

    self.clientLanguage = language
    self.localizedStrings = STRINGS[language]
end

function UF:InitializeLocalization()
    local language = "en"
    if GetCVar then
        local ok, detectedLanguage = pcall(GetCVar, "language.2")
        if ok and type(detectedLanguage) == "string" then
            language = detectedLanguage
        end
    end
    self:SelectLanguage(language)
end

function UF:T(key)
    local localized = self.localizedStrings or STRINGS.en
    return localized[key] or STRINGS.en[key] or tostring(key)
end

function UF:StateLabel(enabled)
    return self:T(enabled and "on" or "off")
end

UF:InitializeLocalization()
