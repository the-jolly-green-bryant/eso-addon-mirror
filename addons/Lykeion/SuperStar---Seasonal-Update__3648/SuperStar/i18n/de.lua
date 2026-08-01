--[[
Author: Ayantir
Updated by Lykeion
Filename: de.lua
Version: 6.0.0

Many thanks to Baertram :)

]]--

-- Used in XML

local strings = {
SI_BINDING_NAME_SUPERSTAR_SHOW_PANEL			= "Zeige/Verstecke SuperStar",

SUPERSTAR_RESPECFAV_SP							= "Fertigkeiten neu verteilen",
SUPERSTAR_RESPECFAV_CP							= "Champion Punkte neu verteilen",
SUPERSTAR_SAVEFAV									= "Sichere Favorit",
SUPERSTAR_VIEWFAV									= "Zeige Fertigkeiten",
SUPERSTAR_VIEWHASH									= "Zeige Favorit",
SUPERSTAR_UPDATEHASH                                  = "Aktualisiert Favorit",
SUPERSTAR_REMFAV									= "Lösche Favorit",
SUPERSTAR_FAVNAME									= "Favorit Name",

SUPERSTAR_CSA_RESPECDONE_TITLE					= "Neuverteilung abgeschlossen",
SUPERSTAR_CSA_RESPECDONE_POINTS				= "<<1>> Fertigkeiten zugewiesen",
SUPERSTAR_CSA_RESPEC_INPROGRESS				= "Neuveteilung im Gange",
SUPERSTAR_CSA_RESPEC_TIME						= "Dieser Vorgang sollte in etwa <<1>> <<1[Minute/Minute/Minuten]>> dauern",

SUPERSTAR_RESPEC_SPTITLE							= "Neuverteilung der |cFF0000Fertigkeiten|r mit Template:\n\n <<1>>",
SUPERSTAR_RESPEC_CPTITLE							= "Neuverteilung der|cFF0000Champion Punkte|r mit Template:\n\n <<1>>",

SUPERSTAR_RESPEC_ERROR1							= "Kann Fertigkeiten nicht neu verteilen! Ungültige Klasse",
SUPERSTAR_RESPEC_ERROR2							= "Warnung: Die aktuellen Fertigkeitspunkte sind geringer als die Anforderungen der Vorlage. Respec kann unvollständig sein",
SUPERSTAR_RESPEC_ERROR3							= "Warnung: Die Rasse in diesem Build ist nicht identisch. Die Rassen Fertigkeitspukte werden NICHT gesetzt!",
SUPERSTAR_RESPEC_ERROR5							= "Kann Champion Punkte nicht neu verteilen! Du bist noch kein Champion",
SUPERSTAR_RESPEC_ERROR6							= "Kann Champion Punkte nicht neu verteilen! Nicht genug Champion Punkte",

SUPERSTAR_RESPEC_SKILLLINES_MISSING			= "Warnung: Folgende Fertigkeitslinien wurden noch nicht freigeschaltet und können nicht gesetzt werden",
SUPERSTAR_RESPEC_CPREQUIRED						= "Dieses Template wird <<1>> Champions Punkte setzen",

SUPERSTAR_RESPEC_INPROGRESS1					= "Klassen Fertigkeiten wurden gesetzt",
SUPERSTAR_RESPEC_INPROGRESS2					= "Waffen Fertikeiten wurden gesetzt",
SUPERSTAR_RESPEC_INPROGRESS3					= "Rüstungs Fertikeiten wurden gesetzt",
SUPERSTAR_RESPEC_INPROGRESS4					= "Welt Fertikeiten wurden gesetzt",
SUPERSTAR_RESPEC_INPROGRESS5					= "Gilden Fertikeiten wurden gesetzt",
SUPERSTAR_RESPEC_INPROGRESS6					= "Allianz Krieg Fertikeitenwurden gesetzt",
SUPERSTAR_RESPEC_INPROGRESS7					= "Rassen Fertikeiten wurden gesetzt",
SUPERSTAR_RESPEC_INPROGRESS8					= "Handel Fertikeiten wurden gesetzt",

SUPERSTAR_IMPORT_MENU_TITLE						= "Importieren",
SUPERSTAR_FAVORITES_MENU_TITLE					= "Favoriten",
SUPERSTAR_RESPEC_MENU_TITLE						= "Neuverteilung",
SUPERSTAR_SCRIBING_MENU_TITLE				= "Schriftlehre Simulator",

SUPERSTAR_XML_BUTTON_SHARE				= "Superstar teilen (/sss)",
SUPERSTAR_XML_BUTTON_SHARE_LINK				= "Teilen mit In-Game Links (/ssl)",

SUPERSTAR_DIALOG_SPRESPEC_TITLE					= "Setze Fertigkeitspunkte",
SUPERSTAR_DIALOG_SPRESPEC_TEXT					= "Fertigkeitspunkte des ausgewählten Templates setzen?",

SUPERSTAR_DIALOG_REINIT_SKB_ATTR_CP_TITLE       ="Setze FertigkeitenBuilder zurück",
SUPERSTAR_DIALOG_REINIT_SKB_ATTR_CP_TEXT		="Dies setzt den FertigkeitenBuilder zurück, was die Attribut- und Champion Punkte betrifft.\n\nDies wird ebenso die Werte zurücksetzen.\n\nZum Zurücksetzen einer Fertigkeit bitte lediglich das Symbol mit der rechten Maustaste anklicken!.",

SUPERSTAR_DIALOG_CPRESPEC_NOCOST_TEXT			="Dies setzt die Champion Punkte zurück.\n\nDieser Vorgang wird nichts kosten.",

	
SUPERSTAR_QUEUE_SCRIBING						= "Warteschlange für Schriftlehre",
SUPERSTAR_CLEAR_QUEUE							= "Warteschlange löschen",

SUPERSTAR_DIALOG_QUEUE_REJECTED_TITLE			= "Warteschlange Abgelehnt",
SUPERSTAR_DIALOG_QUEUE_REJECTED_TEXT			= "Die Fertigkeit in der Warteschlange wird automatisch hergestellt, wenn du das nächste Mal den Schriftlehre-Altar benutzt.\nÄltere Fertigkeiten in der Warteschlange würden durch neuere Fertigkeiten, die dasselbe Grimoire verwenden, überschrieben werden\n\nEinige der aktuell ausgewählten Fähigkeiten sind noch nicht freigeschaltet, man kann sie nicht zur Schriftlehre-Warteschlange hinzufügen",
SUPERSTAR_DIALOG_QUEUE_FOR_SCRIBING_TEXT		= "Die Fertigkeit in der Warteschlange wird automatisch hergestellt, wenn du das nächste Mal den Schriftlehre-Altar benutzt.\nÄltere Fertigkeiten in der Warteschlange würden durch neuere Fertigkeiten, die dasselbe Grimoire verwenden, überschrieben werden\n\nDu bist dabei, deine aktuell ausgewählten Fertigkeiten in die Warteschlange zu stellen",
SUPERSTAR_DIALOG_CLEAR_QUEUE_TEXT		        = "Sie sind dabei, die Fertigkeiten zu löschen, die der Schriftlehre-Warteschlange hinzugefügt wurden\n\nWenn Sie Schriftlehre-Altar das nächste Mal verwenden, wird keine Fertigkeit automatisch hergestellt",
SUPERSTAR_DIALOG_MAJOR_UPDATE_TEXT              = "SuperStar wurde für Update 50 aktualisiert!\n\nDas Addon unterstützt jetzt die <<1>>-Anzeige.\nDie SuperStar-Link-Funktion wurde ebenfalls überarbeitet. Sie ist jetzt stabiler und bereit für die kommenden Klassenüberarbeitungen.",

-- Chatbox Info:
SUPERSTAR_CHATBOX_PRINT			        		= "Klicken Sie zur Ansicht",
SUPERSTAR_CHATBOX_QUEUE_INFO			        = "|c215895[Super|cCC922FStar]|r <<1>> Fähigkeiten in der Warteschlange, <<2>> Tinte, die verbraucht werden soll, Eigenes <<3>>",
SUPERSTAR_CHATBOX_QUEUE_WARN			        = "|c215895[Super|cCC922FStar]|r <<1>> Fähigkeiten in der Warteschlange, <<2>> Tinte, die verbraucht werden soll, Eigenes <<3>>",
SUPERSTAR_CHATBOX_QUEUE_ABORTED		            = "|c215895[Super|cCC922FStar]|r Auto Schriftlehre wurde wegen einer Unterbrechung abgebrochen. Die Warteschlange wurde geleert",
SUPERSTAR_CHATBOX_QUEUE_CANCELED		        = "|c215895[Super|cCC922FStar]|r Auto Schriftlehre wurde wegen Mangel an Tinte gestrichen. Benötige <<1>>, eigenes <<2>>",
SUPERSTAR_CHATBOX_TEMPLATE_OUTDATED		        = "|c215895[Super|cCC922FStar]|r Die Vorlage ist veraltet, bitte erstellen Sie sie neu",
SUPERSTAR_CHATBOX_SUPERSTAR_OUTDATED		    = "|c215895[Super|cCC922FStar]|r Nicht auflösbare SuperStar-Links. Möglicherweise verwenden Sie oder die andere Partei nicht die neueste Version von SuperStar, oder einige Zeichen im Link wurden durch das Chat-Zensursystem blockiert",

SUPERSTAR_XML_SKILL_BUILD				= 		"Skill-Builder",
SUPERSTAR_XML_SKILL_BUILD_EXPLAIN				= "Wählen Sie hier Ihre Rasse aus, um Ihren Skill-Build zu erstellen.Sie können den Build als Vorlage für zukünftige Respecs speichern.\n\nVollständige Unterstützung für Unterklassen! Fügen Sie beliebige Klassen-Skilllinien zu Ihrem Build hinzu. SuperStar erkennt und wendet automatisch alle verfügbaren Klassenfähigkeiten beim Respec an",
SUPERSTAR_SCENE_SKILL_RACE_LABEL				= "Rasse",

SUPERSTAR_XML_CUSTOMIZABLE						= "Verteilt",
SUPERSTAR_XML_GRANTED								= "Gewährt",
SUPERSTAR_XML_TOTAL								= "Gesamt",
SUPERSTAR_XML_BUTTON_FAV							= "Favorit",
SUPERSTAR_XML_BUTTON_FAV_WITH_CP				= "Speichern mit CP",
SUPERSTAR_XML_BUTTON_EXPORT						= "Export",
SUPERSTAR_XML_NEWBUILD							= "Neues Build:",
SUPERSTAR_XML_BUTTON_RESPEC						= "Neuverteilung",

SUPERSTAR_XML_IMPORT_EXPLAIN					= "Importiere andere Builds mit diesem Formular.\n\nBuilds können Champion Punkte, Fertigkeitspunkte sowie Attribute enthalten.",
SUPERSTAR_XML_FAVORITES_EXPLAIN				= "Du kannst gespeicherte Vorlagen verwenden, um automatisch zu respecen. Es wird empfohlen, ein Basis-Build im Voraus in der Waffenkammer zu speichern, damit jedes Mal eine andere Vorlage verwendet werden kann. \n\nBitte beachte, dass der Respec Gold kostet, wenn er Champion-Punkte beinhaltet.",

SUPERSTAR_XML_SKILLPOINTS						= "Fertigkeitspunkte",
SUPERSTAR_XML_CHAMPIONPOINTS					= "Championpunkte",

SUPERSTAR_XML_DMG									= "Schaden",
SUPERSTAR_XML_CRIT									= "Krit / %",
SUPERSTAR_XML_PENE									= "Durchdringung",
SUPERSTAR_XML_RESIST								= "Widerstand / ",

--SUPERSTAR_MAELSTROM_WEAPON						= "Mahlstrom",
SUPERSTAR_DESC_ENCHANT_MAX						= " Maximale[s]?",

SUPERSTAR_IMPORT_ATTR_DISABLED					= "Inkl. Attribute",
SUPERSTAR_IMPORT_ATTR_ENABLED					= "Ohne Attribute",
SUPERSTAR_IMPORT_SP_DISABLED					= "Inkl. Fertigkeitspunkte",
SUPERSTAR_IMPORT_SP_ENABLED						= "Ohne Fertigkeitspunkte",
SUPERSTAR_IMPORT_CP_DISABLED					= "Inkl. Champion Punkte",
SUPERSTAR_IMPORT_CP_ENABLED						= "Ohne Champion Punkte",
SUPERSTAR_IMPORT_BUILD_OK						= "Zeige Fertigkeiten dieses Builds",
SUPERSTAR_IMPORT_BUILD_NO_SKILLS				= "Dieses Build hat keine Fertigkeiten gesetzt",
SUPERSTAR_IMPORT_BUILD_NOK						= "Build fehlerhaft! Überprüfe deinen Hash Code",
SUPERSTAR_IMPORT_BUILD_LABEL					= "Importiere einen Build: Füge deinen Hash ein",
SUPERSTAR_IMPORT_MYBUILD							= "Mein Build",

--SUPERSTAR_XML_SWITCH_PLACEHOLDER				= "Tausche Waffen für Nebenhand Leiste",

SUPERSTAR_XML_FAVORITES_HEADER_NAME				= "Name",
SUPERSTAR_XML_FAVORITES_HEADER_CP				= "CP",
SUPERSTAR_XML_FAVORITES_HEADER_SP				= "SP",
SUPERSTAR_XML_FAVORITES_HEADER_ATTR				= "Attr",
SUPERSTAR_EQUIP_SET_BONUS      = "Set",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end

ZO_CreateStringId("SUPERSTAR_SLOTNAME20"						, "Haupthand (Res)",1 ) -- No EN
ZO_CreateStringId("SUPERSTAR_SLOTNAME21"						, "Nebenhand (Res)",1 )-- No EN