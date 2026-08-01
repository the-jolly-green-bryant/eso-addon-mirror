local RPOTracker = _G['RPOTracker']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- German
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Panel Strings
--	L.RPOTRACK_Title		= "|cFF9900Pale Order|r |cFEE854Tracker|r"
L.RPOTRACK_SOpts		= "Selbstverfolgungsoptionen"
L.RPOTRACK_GOpts		= "Gruppen -Trackeroptionen"

-- Self Tracker Options
L.RPOTRACK_Show			= "Tracker anzeigen"
L.RPOTRACK_ShowD		= "Zeigen Sie den RotPO ausgestatteten Status -Tracker für den Spieler an."
L.RPOTRACK_Lock			= "Sperre Tracker"
L.RPOTRACK_LockD		= "Wenn Sie entsperrt sind, können Sie den Tracker bewegen, um eine neue Position zu speichern."
L.RPOTRACK_ShowG		= "Show gruppiert"
L.RPOTRACK_ShowGD		= "Zeigen Sie den RotPO ausgestatteten Status -Tracker für den Spieler, wenn sie gruppiert werden."
L.RPOTRACK_ShowBG		= "Hintergrund zeigen"
L.RPOTRACK_ShowBGD		= "Zeigen Sie einen schwarzen Hintergrund hinter dem RotPO-Tracker -Symbol."
L.RPOTRACK_Label		= "Label anzeigen"
L.RPOTRACK_LabelD		= "Zeigen Sie ein Textetikett an, das die Stärke von Prozent RotPO anhand der Anzahl der vorhandenen Gruppenmitglieder angibt."
L.RPOTRACK_TScale		= "Tracker -Skala"
L.RPOTRACK_TScaleD		= "Skalieren Sie die Abmessungen für das Tracker -Symbol."
L.RPOTRACK_LScale		= "Etikettenskala"
L.RPOTRACK_LScaleD		= "Skalieren Sie die Dimensionen für die Textbezeichnung."
L.RPOTRACK_LabelX		= "Beschriftung horizontaler Offset"
L.RPOTRACK_LabelXD		= "Passen Sie die Position des RotPO Textetiketts von links nach rechts an."
L.RPOTRACK_LabelY		= "Beschriftung vertikaler Offset"
L.RPOTRACK_LabelYD		= "Passen Sie die Position des RotPO Textetiketts nach oben und unten an."

-- Group Tracker Options
L.RPOTRACK_SGF			= "Gruppenrahmen überwachen"
L.RPOTRACK_SGFD			= "Zeigen Sie RotPO-Symbol für Gruppeneinheitsrahmen."
L.RPOTRACK_SRF			= "Überwachung raid-Rahmen"
L.RPOTRACK_SRFD			= "Zeigen Sie RotPO Icon auf raid-Einheitsrahmen."
L.RPOTRACK_GIS			= "Gruppen -Symbolgröße"
L.RPOTRACK_GISD			= "Größe des RotPO-Symbols bei Standardgruppenrahmen."
L.RPOTRACK_RIS			= "Raid-Symbolgröße"
L.RPOTRACK_RISD			= "Größe des RotPO-Symbols bei Standard raid-Frames."
L.RPOTRACK_GXIO			= "Gruppenhorizontales Symbolversatz"
L.RPOTRACK_GXIOD		= "Passen Sie die Position des Gruppenrahmens RotPO-Symbol von links nach rechts an."
L.RPOTRACK_GYIO			= "Gruppe vertikaler Symbolversatz"
L.RPOTRACK_GYIOD		= "Passen Sie die Position des Gruppenrahmens RotPO-Symbol nach oben und unten an."
L.RPOTRACK_RXIO			= "RAID Horizontal Icon Offset"
L.RPOTRACK_RXIOD		= "Stellen Sie die Position des raid-Rahmens RotPO-Symbol von links nach rechts ein."
L.RPOTRACK_RYIO			= "Vertikaler Icon -Versatz von Raid"
L.RPOTRACK_RYIOD		= "Passen Sie die Position des raid-Rahmens RotPO-Symbol auf und ab an."

-- 3rd Party Frame Options
L.RPOTRACK_Mode1		= "Standard"
--L.RPOTRACK_Mode2		= "Foundry Tactical Combat"
--L.RPOTRACK_Mode3		= "Lui Extended"
--L.RPOTRACK_Mode4		= "Bandits User Interface"
--L.RPOTRACK_Mode5		= "AUI"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k, v in pairs(RPOTracker:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function RPOTracker:GetLanguage() -- set new language return
		return L
	end
end
