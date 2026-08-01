local DTAddon = _G['DTAddon']
local L = {}

--------------------------------------------------------------------------------------------------------------------
-- German translation by ESOUI.com user Baertram. (Non-indented lines still need human translation!)
--------------------------------------------------------------------------------------------------------------------

-- General Strings
--	L.DTAddon_Title			= "Verlies Verfolgung"
	L.DTAddon_CNorm			= "Abgeschlossen Normal: "
	L.DTAddon_CVet			= "Abgeschlossener Veteran: "
	L.DTAddon_CNormI		= "Abgeschlossen Normal I: "
	L.DTAddon_CNormII		= "Abgeschlossen Normal II: "
	L.DTAddon_CVetI			= "Abgeschlossener Veteran I: "
	L.DTAddon_CVetII		= "Abgeschlossener Veteran II: "
L.DTAddon_CGChal		= "Gruppe Challenge Skillpoint"
	L.DTAddon_CDBoss		= "Alle Bosse Besiegt: "
L.DTAddon_Unlock		= "Freigeschaltet auf Stufe: "
L.DTAddon_True			= "Wahr"
L.DTAddon_False			= "Falsch"
L.DTAddon_None			= "Keiner"
L.DTAddon_MQOPT1		= "Alle Charaktere"
L.DTAddon_MQOPT2		= "Aktueller Charakter"
L.DTAddon_MQOPT3		= "Nicht anzeigen"
L.DTAddon_CTOPT1		= "Zeig beides"
L.DTAddon_CTOPT2		= "Nur abgeschlossen"
L.DTAddon_CTOPT3		= "Nur unvollständig"
L.DTAddon_QComp			= "Quest abgeschlossen: "
L.DTAddon_QCompI		= "Aufgabe I vollständig: "
L.DTAddon_QCompII		= "Aufgabe II vollständig:: "
L.DTAddon_AWide			= " (Kontoweit)"
L.DTAddon_QMQ			= "Wählen Sie unvollständige Quests"
L.DTAddon_QMQTip		= "Wählen Sie Dungeons aus, für die der aktuelle Charakter die Skill Point Quest noch nicht abgeschlossen hat."
L.DTAddon_QMQVTip		= "Wenn es überprüft wird, wird die Veteranenversion von Dungeons ausgewählt, um Skill Point Quests zu vervollständigen (nicht empfohlen).\n\n|cffffffNOTIZ|r: Die Skill Point Quest ist im normalen und veteranen Modus gleich und kann nur einmal fertiggestellt werden."

-- Account Options
L.DTAddon_SHMComp		= "Show Hard-Modus-Abschluss"
L.DTAddon_SHMCompD		= "Zeigen Sie ein Symbol, wenn Sie den ausgewählten Veteranen-Dungeon- oder Probe-Hard-Modus-Leistungs-Errungenschaften abgeschlossen haben."
L.DTAddon_STTComp		= "Zeigen Sie Abschluss des Testzeitraums"
L.DTAddon_STTCompD		= "Zeigen Sie ein Symbol, wenn Sie den ausgewählten Veteranen-Dungeon oder den zeitgesteuerten Leistungszielen abgeschlossen haben."
L.DTAddon_SNDComp		= "Zeige keine Todesbeendigung"
L.DTAddon_SNDCompD		= "Zeigen Sie ein Symbol, wenn Sie den ausgewählten Veteranen-Dungeon abgeschlossen haben oder keine Todeserreichung erfolgen."
L.DTAddon_SGFComp		= "Gruppen-Dungeon-Fraktion-Fertigstellung"
L.DTAddon_SGFCompD		= "Zeigen Sie den aktuellen Fortschritt auf, um alle Gruppen-Dungeons in der Fraktion des hervorgehobenen Dungeons abzuschließen."
L.DTAddon_SLFGt			= "LFG: Zeigt die Fertigstellung des Verlies"
L.DTAddon_SLFGtD		= "Errungenschaftsinformationen im GROUP-Finder-Tooltip anzeigen."
L.DTAddon_SLFGd			= "LFG: Zeige Verlies Beschreibung"
L.DTAddon_SLFGdD		= "Zeigen Sie die Spielbeschreibung des Spiels in den LFG-Tooltips an. Dies ist normalerweise verborgen."
L.DTAddon_SNComp		= "KARTE: Normale Gruppe Dungeon-Fertigstellung"
L.DTAddon_SNCompD		= "Show, wenn Sie den Dungeon oder die Testversion im Normalmodus in der Tooltip abgeschlossen haben."
L.DTAddon_SVComp		= "KARTE: Veteranengruppe Dungeon Fertigstellung"
L.DTAddon_SVCompD		= "Show, wenn Sie den Dungeon oder die Testversion im Veteran-Modus in der Tooltip abgeschlossen haben."
L.DTAddon_SGCCompM		= "KARTE: "
L.DTAddon_SGCComp		= "Öffentlicher Dungeon Skillpoint"
L.DTAddon_SGCCompD		= "Wenn Ihr aktueller Charakter die öffentliche Dungeon SkillPoint Group Challenge im Tooltip abgeschlossen hat."
L.DTAddon_SDBComp		= "KARTE: Öffentlicher Dungeon-Boss-Fertigstellung"
L.DTAddon_SDBCompD		= "Show, wenn Sie alle Bosse des öffentlichen Dungeons in der Toilatip besiegt haben."
L.DTAddon_SDFComp		= "KARTE: Öffentliche Dungeon-Fraktion-Fertigstellung"
L.DTAddon_SDFCompD		= "Zeigen Sie den aktuellen Fortschritt auf, um alle öffentlichen Dungeons in der Fraktionserreichung abzuschließen."
L.DTAddon_CNColor		= "Fertige Farbe:"
L.DTAddon_CNColorD		= "Wählen Sie die Farbe für den Abschlussstatus oder die Namen der Charaktere, die die Dungeon-Skillpoint-Quest abgeschlossen haben."
L.DTAddon_NNColor		= "Unvollständige Farbe:"
L.DTAddon_NNColorD		= "Wählen Sie die Farbe für den Abschlussstatus oder die Namen der Charaktere, die die Dungeon-Skillpoint-Quest NICHT abgeschlossen haben."
L.DTAddon_QCompHead		= "Dungeon-Quest-Abschluss"
L.DTAddon_QCompS		= "Verlies-Quests anzeigen"
L.DTAddon_QCompSD		= "Wählen Sie aus, ob der Abschlussstatus von Dungeon-Quests angezeigt werden soll. Wählen Sie aus, ob der Status aller Charaktere oder nur der aktuelle angezeigt werden soll.\n\nHINWEIS: Sie müssen sich bei jedem Charakter mindestens einmal anmelden, damit er in der Liste aller Charaktere angezeigt wird."
L.DTAddon_CTDROPDOWN	= "Format für den Vervollständigungstext"
L.DTAddon_CTDROPDOWND	= "Wenn alle Charaktere angezeigt werden, wählen Sie aus, ob nur diejenigen angezeigt werden sollen, die die Dungeon-Skillpoint-Quest abgeschlossen haben, nur diejenigen, die dies nicht getan haben, oder beides (Standard)."
L.DTAddon_ALPHAN		= "Namensliste alphabetisch sortieren"
L.DTAddon_ALPHAND		= "Wenn diese Option aktiviert ist, werden die Tooltip-Vervollständigungslisten alphabetisch geordnet. Andernfalls stimmt die Reihenfolge der Liste mit der Reihenfolge der Erstellung Ihrer Charaktere überein."
L.DTAddon_CHighlight	= "Aktueller Charakter hervorheben"
L.DTAddon_CHighlightD	= "Zeigen Sie ein Sternchen (*) und verwenden Sie die aktuelle Zeichenerreichungsfarbe, um den Dungeon-Quest-Abschluss für Ihr aktuelles angemeldeter Zeichen zu markieren, wenn Sie die Liste anzeigen."
L.DTAddon_HColor		= "Aktuelle Zeichenfarbe"
L.DTAddon_HColorD		= "Ändern Sie die Farbe, um Ihr aktuelles Zeichen in der Liste der Namen für Dungeon Quest abgeschlossen zu markieren."

-- Character Tracking
L.DTAddon_CharTracking	= "Zeichenverfolgung"
L.DTAddon_TrackChar		= "Aktuellen Charakter verfolgen"
L.DTAddon_TrackCharD	= "Schließen Sie den aktuell angemeldeten Charakter in die Quest-Abschlusszusammenfassung ein, wenn "..L.DTAddon_QCompS.." auf "..L.DTAddon_MQOPT1.." eingestellt ist. Aktivieren Sie die Funktion erneut, während Sie angemeldet sind, um sie wieder hinzuzufügen."
L.DTAddon_TrackWarn		= "WARNUNG: Die Benutzeroberfläche wird automatisch neu geladen!"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k,v in pairs(DTAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function DTAddon:GetLanguage() -- set new language return
		return L
	end
end
