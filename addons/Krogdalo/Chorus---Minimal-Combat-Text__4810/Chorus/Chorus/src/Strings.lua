local EN = {
    TITLE = "Chorus",
    HELP = "/chorus            this help\n/chorus unlock     show and drag the column\n/chorus lock       lock it\n/chorus test       preview with synthetic hits\n/chorus summary    toggle the end-of-fight line\n/chorus fonts      list fonts\n/chorus font <key> set the font",
    UNLOCKED = "Chorus: unlocked. Drag the column, then /chorus lock.",
    LOCKED = "Chorus: locked.",
    SUMMARY_ON = "Chorus: fight summary on.", SUMMARY_OFF = "Chorus: fight summary off.",
    LUI_HINT = "Chorus: LuiExtended combat text is still on. Disable it under LuiExtended > Combat Text to avoid double numbers.",
    SUMMARY = "<<1>>  ·  <<2>> dps  ·  <<3>> <<4>>%",
    M_GENERAL = "Column", M_MOVE = "Move column", M_MOVE_DONE = "Done moving", M_MOVE_T = "Shows a static preview you can drag. Click again, or /chorus lock, when it sits right.", M_RESET = "Reset position", M_PREVIEW = "Preview",
    M_LINES = "Visible lines", M_SIZE_MIN = "Smallest size", M_SIZE_MAX = "Largest size",
    M_DWELL = "Dwell (ms)", M_DWELL_T = "How long an average hit stays. Heavy hits stay longer.",
    M_PETS = "Include pet damage", M_HEALING = "Show healing done", M_HEALING_T = "A second, quieter column to the left.",
    M_NAMES = "Ability name on top hits", M_NAMES_T = "Shows the ability name next to hits in the top 10 percent.",
    M_SUMMARY = "Fight summary", M_SUMMARY_T = "One line after combat: duration, dps, top ability.",
    M_CRIT_MARK = "Crit mark", M_COLOR = "Text color", M_COLOR_CRIT = "Crit color",
    M_FONT = "Font", M_FONT_T = "Built-in game faces, plus any font registered through LibMediaProvider (font packs).",
    FONT_SET = "Chorus: font set to <<1>>.", FONT_UNKNOWN = "Chorus: unknown font <<1>>. /chorus fonts lists them.", FONTS_HEAD = "Chorus fonts:",
    PREVIEW = "Preview",
}
local DE = {
    TITLE = "Chorus",
    HELP = "/chorus            diese Hilfe\n/chorus unlock     Spalte anzeigen und verschieben\n/chorus lock       fixieren\n/chorus test       Vorschau mit Beispieltreffern\n/chorus summary    Kampfzusammenfassung ein/aus\n/chorus fonts      Schriftarten auflisten\n/chorus font <key> Schriftart setzen",
    UNLOCKED = "Chorus: entsperrt. Spalte verschieben, dann /chorus lock.",
    LOCKED = "Chorus: fixiert.",
    SUMMARY_ON = "Chorus: Kampfzusammenfassung an.", SUMMARY_OFF = "Chorus: Kampfzusammenfassung aus.",
    LUI_HINT = "Chorus: LuiExtended-Kampftext ist noch aktiv. Unter LuiExtended > Kampftext deaktivieren, sonst doppelte Zahlen.",
    SUMMARY = "<<1>>  ·  <<2>> dps  ·  <<3>> <<4>>%",
    M_GENERAL = "Spalte", M_MOVE = "Spalte verschieben", M_MOVE_DONE = "Fertig", M_MOVE_T = "Zeigt eine feste Vorschau zum Verschieben. Nochmal klicken oder /chorus lock, wenn sie passt.", M_RESET = "Position zurücksetzen", M_PREVIEW = "Vorschau",
    M_LINES = "Sichtbare Zeilen", M_SIZE_MIN = "Kleinste Größe", M_SIZE_MAX = "Größte Größe",
    M_DWELL = "Verweildauer (ms)", M_DWELL_T = "Wie lange ein durchschnittlicher Treffer bleibt. Schwere bleiben länger.",
    M_PETS = "Begleiterschaden einbeziehen", M_HEALING = "Heilung anzeigen", M_HEALING_T = "Eine zweite, ruhigere Spalte links.",
    M_NAMES = "Fähigkeitsname bei Toptreffern", M_NAMES_T = "Zeigt den Namen neben Treffern in den oberen 10 Prozent.",
    M_SUMMARY = "Kampfzusammenfassung", M_SUMMARY_T = "Eine Zeile nach dem Kampf: Dauer, dps, beste Fähigkeit.",
    M_CRIT_MARK = "Krit-Markierung", M_COLOR = "Textfarbe", M_COLOR_CRIT = "Krit-Farbe",
    M_FONT = "Schriftart", M_FONT_T = "Schriften des Spiels sowie alle über LibMediaProvider registrierten (Font-Packs).",
    FONT_SET = "Chorus: Schriftart <<1>> gesetzt.", FONT_UNKNOWN = "Chorus: unbekannte Schriftart <<1>>. /chorus fonts zeigt alle.", FONTS_HEAD = "Chorus-Schriftarten:",
    PREVIEW = "Vorschau",
}
local S = Chorus.Strings
S.tables = { en = EN, de = DE }
S.lang = "en"
function S.SetLanguage(lang) S.lang = S.tables[lang] and lang or "en" end
function S.Get(key, ...)
    local text = (S.tables[S.lang] or EN)[key] or EN[key] or key
    if select("#", ...) > 0 then
        local args = { ... }
        text = text:gsub("<<(%d)>>", function(i) return tostring(args[tonumber(i)] or "") end)
    end
    return text
end
