CombatFPSBooster = CombatFPSBooster or {}
CombatFPSBooster.L = CombatFPSBooster.L or {}

local function IsGerman()
    local lang = GetCVar("language.2")
    if not lang or lang == "" then lang = GetCVar("Language.lang") end
    if (not lang or lang == "") and GetLanguage then lang = GetLanguage() end
    if lang then
        lang = string.lower(lang)
        return lang == "de" or string.sub(lang, 1, 2) == "de"
    end
    return false
end

if IsGerman() then
    CombatFPSBooster.L.TITLE          = "Tetsu's Combat FPS Booster"
    CombatFPSBooster.L.HIDE_INSTANCE   = "HUD im gesamten Dungeon ausblenden"
    CombatFPSBooster.L.HIDE_INSTANCE_TT= "Wenn aktiv: Kompass und Quest-Tracker bleiben im Gruppen-Dungeon, Trial, der Arena oder dem Endlosen Archiv die ganze Zeit ausgeblendet. XP, Beute und Bildschirm-Ankündigungen nur im Kampf. Delven und öffentliche Verliese werden ignoriert."

    CombatFPSBooster.L.WHOLE_WHERE       = "Wo der Modus „ganzes Verlies“ gilt"
    CombatFPSBooster.L.WHOLE_WHERE_TT    = "Wo Kompass und Questtracker zwischen Kämpfen versteckt bleiben, falls diese Optionen an sind. EP, Gold, Loot und CSA nur im Kampf. In Cyrodiil bleibt der Kompass sichtbar."
    CombatFPSBooster.L.WHOLE_DUNGEON     = "Verliese und Prüfungen"
    CombatFPSBooster.L.WHOLE_DUNGEON_TT  = "Gruppenverliese und Prüfungen."
    CombatFPSBooster.L.WHOLE_ARENA       = "Arenen"
    CombatFPSBooster.L.WHOLE_ARENA_TT    = "Mahlstrom, Drachenstern, Vateshran, Schwarzdorn."
    CombatFPSBooster.L.WHOLE_ARCHIVE     = "Unendliches Archiv"
    CombatFPSBooster.L.WHOLE_ARCHIVE_TT  = "Läufe im Unendlichen Archiv."
    CombatFPSBooster.L.WHOLE_BG          = "Schlachtfelder"
    CombatFPSBooster.L.WHOLE_BG_TT       = "Schlachtfeld-Matches. Addon-Presets werden hier nicht gewechselt."
    CombatFPSBooster.L.WHOLE_CYRO        = "Cyrodiil und Kaiserstadt"
    CombatFPSBooster.L.WHOLE_CYRO_TT     = "Allianzkrieg. Kompass bleibt sichtbar; nur der Questtracker kann zwischen Kämpfen versteckt bleiben."
    CombatFPSBooster.L.PRESET_APPLY_PVP  = "Combat FPS Booster: Preset kann in Cyrodiil oder auf Schlachtfeldern nicht angewendet werden."
    CombatFPSBooster.L.HIDE_COMPASS   = "Kompass im Kampf ausblenden"
    CombatFPSBooster.L.HIDE_COMPASS_TT= "Blendet den Kompass im Kampf vollständig aus, um die CPU zu entlasten."
    CombatFPSBooster.L.HIDE_QUESTS    = "Quest-Tracker im Kampf ausblenden"
    CombatFPSBooster.L.HIDE_QUESTS_TT = "Blendet aktive Quests während des Kampfes aus."
    CombatFPSBooster.L.HIDE_ALERTS    = "Benachrichtigungen im Kampf ausblenden"
    CombatFPSBooster.L.HIDE_ALERTS_TT = "Blendet XP, Gold und Beute nur im Kampf aus. Der Modus 'ganzer Dungeon' hält sie zwischen Kämpfen nicht versteckt."
    CombatFPSBooster.L.FILTER_MASTER    = "Im Dungeon nur benötigte Addons"
    CombatFPSBooster.L.FILTER_MASTER_TT = "Filter pro Charakter. Beim Betreten von Gruppen-Dungeon, Trial, Arena oder Endlosem Archiv wird das aktuelle Addon-Set gespeichert, nur markierte Addons bleiben an, UI wird neu geladen. Beim Verlassen wird das alte Set wiederhergestellt. Delven und öffentliche Verliese werden ignoriert."
    CombatFPSBooster.L.FILTER_ITEM_TT   = "An = Addon im Dungeon behalten. Aus = im Dungeon deaktivieren. Gesperrt, bis die Option oben aktiv ist."
    CombatFPSBooster.L.FILTER_EMPTY_WARN= "Combat FPS Booster: Dungeon-Filter ist an, aber kein Addon ist als benötigt markiert. Nichts wurde geändert."
    CombatFPSBooster.L.FILTER_APPLY     = "Combat FPS Booster: Addon-Preset wird aktiviert: "
    CombatFPSBooster.L.FILTER_APPLY_TAIL = ", UI wird neu geladen."
    CombatFPSBooster.L.FILTER_RESTORE   = "Combat FPS Booster: vorheriges Addon-Setup wird wiederhergestellt, UI wird neu geladen."
    CombatFPSBooster.L.FILTER_NOAPI     = "Combat FPS Booster: Addon-Status konnte nicht geändert werden. Kein erneutes Neuladen."
    CombatFPSBooster.L.FILTER_SECTION   = "Addons im Dungeon"
    CombatFPSBooster.L.FILTER_SECTION_TT= "Welche installierten Addons im Dungeon oder Trial aktiv bleiben."
    CombatFPSBooster.L.PRESET_SELECT    = "Preset"
    CombatFPSBooster.L.PRESET_SELECT_TT = "Gespeicherte Addon-Sets. Die Presets gelten für das ganze Konto."
    CombatFPSBooster.L.PRESET_NAME      = "Preset-Name"
    CombatFPSBooster.L.PRESET_NAME_TT   = "Name zum Speichern. Gleicher Name überschreibt das Preset."
    CombatFPSBooster.L.PRESET_SAVE      = "Preset speichern"
    CombatFPSBooster.L.PRESET_SAVE_BTN  = "Speichern"
    CombatFPSBooster.L.PRESET_SAVE_TT   = "Aktuelle An/Aus-Werte unter diesem Namen speichern."
    CombatFPSBooster.L.PRESET_DELETE    = "Preset löschen"
    CombatFPSBooster.L.PRESET_DELETE_BTN= "Löschen"
    CombatFPSBooster.L.PRESET_DELETE_TT = "Gewähltes Preset löschen. Das letzte Preset kann nicht gelöscht werden."
    CombatFPSBooster.L.PRESET_DIVIDER   = "──────── Addons ────────"
    CombatFPSBooster.L.PRESET_SAVED     = "Combat FPS Booster: Preset gespeichert: "
    CombatFPSBooster.L.PRESET_DELETED   = "Combat FPS Booster: Preset gelöscht: "
    CombatFPSBooster.L.PRESET_LAST      = "Combat FPS Booster: Das letzte Preset kann nicht gelöscht werden."
    CombatFPSBooster.L.PRESET_NOW       = "Combat FPS Booster: aktives Preset: "
    CombatFPSBooster.L.HIDE_CSA       = "Ankündigungen im Kampf ausblenden"
    CombatFPSBooster.L.HIDE_CSA_TT    = "Blendet große Bildschirmmeldungen nur im Kampf aus. Nicht für den ganzen Dungeon."

end
