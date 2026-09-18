TamrielCalendar = TamrielCalendar or {}
local TC = TamrielCalendar

local de = {
    days = {"Sandas", "Morndas", "Tirdas", "Middas", "Turdas", "Fredas", "Loredas"},
    shortDays = {"Sa", "Mo", "Ti", "Mi", "Tu", "Fr", "Lo"},
    months = {"Morgenstern", "Sonnendämmerung", "Erstsaat", "Regenhand", "Zweitsaat", "Mittjahr", "Sonnenerhöhung", "Letzte Saat", "Herzfeuer", "Eisfall", "Sonnenuntergang", "Abendstern"},
    realMonths = {"Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"},
    signs = {"Das Ritual", "Die Liebenden", "Der Fürst", "Der Magier", "Der Schatten", "Das Ross", "Der Lehrling", "Der Krieger", "Die Fürstin", "Der Turm", "Der Atronach", "Die Diebin", "Die Schlange"},
    moonPhases = {"Neumond", "Zunehmende Sichel", "Erstes Viertel", "Zunehmender Mond", "Vollmond", "Abnehmender Mond", "Letztes Viertel", "Abnehmende Sichel"},
    yearSuffix = "Jahr der 2. Ära",
    monthPrefix = "Monat",
    signPrefix = "Sternzeichen:",
    stripFormat = "%s, %d. %s %d | %s | %02d:%02d",
    titleHoliday = "Feiertag:",
    btnPrev = "Zurück",
    btnNext = "Weiter",
    hNames = {
        nl = "Neujahrsfest",
        hd = "Herztag",
        aj = "ESO-Jubiläum",
        jd = "Tag der Narren",
        zz = "Tag von Zenithar",
        my = "Mittjahr-Feier",
        wf = "Hexenfest",
        ud = "Kriegerfest"
    }
}

for k, v in pairs(de) do
    TC.L[k] = v
end