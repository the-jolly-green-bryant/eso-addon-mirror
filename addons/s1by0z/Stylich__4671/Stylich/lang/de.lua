local STLLang = Stylich.Lang
STLLang.msg = STLLang.msg or {}
local m = STLLang.msg

-- Erscheinungs-Kategorien
m.CATEGORY_TYPE_COSTUME = 'Kostüme'
m.CATEGORY_TYPE_POLYMORPH = 'Verwandlungen'
m.CATEGORY_TYPE_SKIN = 'Erscheinungen'
m.CATEGORY_TYPE_PERSONALITY = 'Persönlichkeiten'
m.CATEGORY_TYPE_HAT = 'Kopfbedeckungen'
m.CATEGORY_TYPE_HAIR = 'Frisuren'
m.CATEGORY_TYPE_FACIAL_HAIR_HORNS = 'Gesichtsbehaarung'
m.CATEGORY_TYPE_FACIAL_ACCESSORY = 'Große Verzierungen'
m.CATEGORY_TYPE_PIERCING_JEWELRY = 'Kleine Verzierungen'
m.CATEGORY_TYPE_HEAD_MARKING = 'Kopfbemalungen'
m.CATEGORY_TYPE_BODY_MARKING = 'Körperbemalungen'
m.CATEGORY_TYPE_VANITY_PET = 'Friedlicher Begleiter'
m.CATEGORY_TYPE_MOUNT = 'Reittier'
m.GEAR_APPEARANCE = 'Aufmachung (Waffe)'

-- Beschriftungen
m.STYLE = 'Stil'
m.OUTFIT = 'Aufmachung'
m.TITLE = 'Titel'
m.HOTKEY = 'Tastenkürzel'
m.MEMENTO = 'Andenken'
m.REVEAL = 'Verzög.'
m.COMPANION = 'Begleiter'
m.COMPANION_NONE = '- Keiner -'
m.COMPANION_KEEP = '- Nicht ändern -'
m.WEAPONS = 'Waffen'
m.APPLY_SECTION = 'BEIM ANWENDEN'
m.OPTIONS = 'Optionen'

-- Auswahllisten
m.SLOT = 'Slot'
m.HOTKEY_NONE = '- Keine -'
m.MEMENTO_NONE = '- Keine -'
m.NO_OUTFIT = '- Keine Aufmachung -'
m.NO_TITLE = '- Kein Titel -'
m.WEAPON_UNEQUIP = 'Leerer Slot (wird abgelegt)'
m.WEAPON_NONE = 'Aktuelle Waffe behalten (dieser Slot bleibt unverändert)'

-- Optionen
m.OPT_SHOW_BUTTON = 'Schwebenden Knopf anzeigen'
m.OPT_SHOW_DROPDOWN = 'Schnellwechsel-Liste anzeigen'
m.OPT_LOCK_BUTTON = 'Position des schwebenden Knopfes sperren'
m.OPT_PLAY_MEMENTOS = 'Eingangs-Andenken beim Anwenden eines Stils abspielen'
m.OPT_HIDE_ON_MENUS = 'Stylich ausblenden, wenn ein Menü geöffnet ist'
m.OPT_CLOSE_COMBAT = 'Fenster beim Kampfbeginn schließen'
m.OPT_HELP =
	"|cFFAA33Einen Stil erstellen|r\n"..
	"- Stelle dein Aussehen im Spiel ein, dann drücke Aktualisieren, um es zu speichern.\n"..
	"- Oder ziehe eine Waffe aus deinem Inventar auf einen Waffen-Slot.\n"..
	"- Rechtsklick auf einen Waffen-Slot wechselt: leer (ablegen) oder behalten (Waffe unverändert).\n"..
	"- Wähle eine Aufmachung, einen Titel und ein Eingangs-Andenken aus den Listen.\n\n"..
	"|cFFAA33Eingangs-Andenken|r\n"..
	"Beim Anwenden eines Stils wird sein Andenken abgespielt, um die Änderung zu verbergen - dein neues Aussehen erscheint am Ende der Animation. Ist das Andenken noch in Abklingzeit, wechselt der Stil nicht (damit die Enthüllung immer stattfindet)."

-- Bestätigungsdialoge
m.CONFIRM_UPDATE_TITLE = 'Stil aktualisieren'
m.CONFIRM_UPDATE_TEXT = "«<<1>>» mit deinem aktuellen Aussehen überschreiben?"
m.CONFIRM_DELETE_TITLE = 'Stil löschen'
m.CONFIRM_DELETE_TEXT = "Den Stil «<<1>>» löschen?"

-- Knopf-Tooltips
m.TT_NEW = 'Neuer Stil'
m.TT_RENAME = 'Umbenennen / Eigenschaften'
m.TT_UPDATE = 'Vom aktuellen Aussehen aktualisieren'
m.TT_APPLY = 'Stil anwenden'
m.TT_DELETE = 'Stil löschen'
m.TT_OPTIONS = 'Optionen'
m.TT_REVEAL = 'Verzögerung, bevor dein neues Aussehen unter dem Eingangs-Andenken erscheint. Kürzer = schnellere Enthüllung; länger verbirgt das Andenken die Änderung länger. An die Dauer deines Andenkens anpassen.'

-- Tastenbelegungen
m.BIND_SHOW = 'Fenster öffnen/schließen'
m.BIND_SLOT = 'Stil aus Slot anwenden'

-- Chat-Nachrichten
m.MSG_NO_STYLE_SLOT = "Stylich: Slot <<1>> ist kein Stil zugewiesen."
m.MSG_CREATED = "Stylich: «<<1>>» erstellt."
m.MSG_MEMENTO_COOLDOWN = "Stylich: Eingangs-Andenken nicht bereit (<<1>>s) - Stil nicht angewendet."
m.MSG_WEAPON_NOT_FOUND = "Stylich: Waffe nicht gefunden: <<1>>."
m.MSG_WEAPON_DUP = "Stylich: Diese Waffe ist bereits einem anderen Slot zugewiesen."
m.MSG_WEAPON_ONLY = "Stylich: Hier können nur Waffen abgelegt werden."
m.MSG_NO_SPACE = "Stylich: Nicht genug Platz im Rucksack, um <<1>> abzulegen."
m.MSG_COMBAT_WEAPONS = "Stylich: Waffen können im Kampf nicht gewechselt werden."
