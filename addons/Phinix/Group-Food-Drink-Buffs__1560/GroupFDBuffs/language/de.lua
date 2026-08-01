local GroupFDB = _G['GroupFDB']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- German (Thanks to ESOUI.com users Scootworks & Baertram for the translation!)
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- Panel Strings.
	L.GroupFDB_Title		= "Essen und Trinken in Gruppen"
	L.GroupFDB_GOpts		= "Globale Optionen"
L.GroupFDB_SGF				= "Gruppenbilder überwachen"
	L.GroupFDB_SGFD			= "Zeige Essen/Trinken Getränksymbole auf dem Gruppenrahmen."
	L.GroupFDB_SRF			= "Raid-Frames überwachen"
	L.GroupFDB_SRFD			= "Zeige Essen/Trinken Getränksymbole auf dem Schlachtzug Gruppenrahmen."
	L.GroupFDB_SAB			= "Aktiven Speisen/Getränke Buff anzeigen"
	L.GroupFDB_SABD			= "Zeigt euch im Gruppen-/Raidgruppenfenster die aktiven Speisen/Getränke Buffs an."
	L.GroupFDB_SJB			= "Ungeeignete Speisen/Getränke Buff anzeigen"
	L.GroupFDB_SJBD			= "Zeigt euch im Gruppen-/Raidgruppenfenster die aktiven aber ungeeigneten (Trödel/Junk) Speisen/Getränke Buffs an."
	L.GroupFDB_SNB			= "Fehlenden Speisen/Getränke Buff anzeigen"
	L.GroupFDB_SNBD			= "Ein rotes Symbol im Gruppen-/Raidgruppenfenster anzeigen, falls ein Mitglied keine Speise oder kein Getränk aktiv hat."
	L.GroupFDB_GMode		= "Gruppen Buff-Modus"
L.GroupFDB_GModeD			= "Wählen Sie das Unterstützungsmodul für die aktuell verwendeten Gruppenblöcke aus. Standard sind die normalen Frames des Spiels."
L.GroupFDB_RMode			= "Raid Buff-Modus"
L.GroupFDB_RModeD			= "Wählen Sie das Unterstützungsmodul für die derzeit verwendeten Schlachtfeldeinheiten aus. Standard sind die normalen Frames des Spiels."
	L.GroupFDB_GIS			= "Symbolgrösse im Gruppenfenster"
	L.GroupFDB_GISD			= "Legt die Symbolgrösse des Speisen/Getränke Buff Symbols im Gruppenfenster fest. Der Wert ist ein Multiplikator von 8 Pixel."
	L.GroupFDB_RIS			= "Symbolgrösse Raidgruppenfenster"
	L.GroupFDB_RISD			= "Legt die Symbolgrösse des Speisen/Getränke Buff Symbols im Raidgruppenfenster fest. Der Wert ist ein Multiplikator von 8 Pixel."
L.GroupFDB_GXIO				= "Horizontaler Symbolversatz der Gruppe"
L.GroupFDB_GXIOD			= "Passt die Position des Speisen/Getränke-Symbols des Gruppenrahmens von links nach rechts an."
L.GroupFDB_GYIO				= "Vertikaler Symbolversatz der Gruppe"
	L.GroupFDB_GYIOD			= "Passt die Position des Speisen/Getränke-Symbols des Gruppenrahmens nach oben und unten an."
L.GroupFDB_RXIO				= "Horizontaler Symbolversatz für Raid"
L.GroupFDB_RXIOD			= "Passt die Position des Speisen/Getränke-Symbols des Schlachtzugsrahmens von links nach rechts an."
L.GroupFDB_RYIO				= "Vertikaler Symbolversatz für Raid"
L.GroupFDB_RYIOD			= "Passt die Position des Speisen/Getränke-Symbols des Schlachtfeldrahmens nach oben und unten an."

-- Group frame support options
L.GroupFDB_Mode1			= "Standard"
--L.GroupFDB_Mode2			= "Foundry Tactical Combat"
--L.GroupFDB_Mode3			= "Lui Extended"
--L.GroupFDB_Mode4			= "Bandits User Interface"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k,v in pairs(GroupFDB:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function GroupFDB:GetLanguage() -- set new language return
		return L
	end
end
