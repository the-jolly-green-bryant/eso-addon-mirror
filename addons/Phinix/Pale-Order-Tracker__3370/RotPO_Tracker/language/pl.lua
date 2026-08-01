local RPOTracker = _G['RPOTracker']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Polish
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Panel Strings
--L.RPOTRACK_Title		= "|cFF9900Pale Order|r |cFEE854Tracker|r"
L.RPOTRACK_SOpts		= "Opcje samodzielnego śledzenia"
L.RPOTRACK_GOpts		= "Opcje śledzenia grupy"

-- Self Tracker Options
--L.RPOTRACK_Show		= "Show Tracker"
L.RPOTRACK_ShowD		= "Pokaż RotPO wyposażonego urządzenia do śledzenia stanu dla gracza."
L.RPOTRACK_Lock			= "Tracker blokady"
L.RPOTRACK_LockD		= "Po odblokowaniu możesz przesunąć tracker, aby zaoszczędzić nową pozycję."
L.RPOTRACK_ShowG		= "Pokaż zgrupowany"
L.RPOTRACK_ShowGD		= "Po zgrupowaniu pokaż RotPO wyposażonego statusu śledzenia odtwarzacza."
L.RPOTRACK_ShowBG		= "Pokaż tło"
L.RPOTRACK_ShowBGD		= "Pokaż czarne tło za ikonę trackera RotPO."
L.RPOTRACK_Label		= "Pokaż etykietę"
L.RPOTRACK_LabelD		= "Pokaż etykietę tekstową wskazującą procent RotPO na podstawie liczby obecnych członków grupy."
L.RPOTRACK_TScale		= "Skala śledzenia"
L.RPOTRACK_TScaleD		= "Skaluj wymiary ikony śledzenia."
L.RPOTRACK_LScale		= "Skala etykiet"
L.RPOTRACK_LScaleD		= "Skal wymiary etykiety tekstowej."
L.RPOTRACK_LabelX		= "Etykieta poziome przesunięcie"
L.RPOTRACK_LabelXD		= "Dostosuj pozycję etykiety tekstowej RotPO od lewej do prawej."
L.RPOTRACK_LabelY		= "Oznaczenie pionowego przesunięcia"
L.RPOTRACK_LabelYD		= "Dostosuj pozycję etykiety tekstowej RotPO w górę iw dół."

-- Group Tracker Options
L.RPOTRACK_SGF			= "Monitoruj ramki grupowe"
L.RPOTRACK_SGFD			= "Pokaż RotPO ikony klatek na rzecz jednostek grupy."
L.RPOTRACK_SRF			= "Monitoruj ramki RAID"
L.RPOTRACK_SRFD			= "Pokaż RotPO ikony na ramach jednostek RAID."
L.RPOTRACK_GIS			= "Rozmiar ikony grupy"
L.RPOTRACK_GISD			= "Rozmiar ikony RotPO, gdy jest wyświetlany na standardowych ramach grupowych."
L.RPOTRACK_RIS			= "Rozmiar ikony RAID"
L.RPOTRACK_RISD			= "Rozmiar ikony RotPO po wyświetleniu na standardowych ramach RAID."
L.RPOTRACK_GXIO			= "Przesunięcie ikony poziomej grupy"
L.RPOTRACK_GXIOD		= "Dostosuj pozycję ikonę grupy RotPO od lewej do prawej."
L.RPOTRACK_GYIO			= "Grupowe pionowe przesunięcie ikony"
L.RPOTRACK_GYIOD		= "Dostosuj pozycję ikonę ramki grupy RotPO w górę iw dół."
L.RPOTRACK_RXIO			= "RAID Horyzontal ikona ikona"
L.RPOTRACK_RXIOD		= "Dostosuj pozycję ikonę ramy RAID RotPO od lewej do prawej."
L.RPOTRACK_RYIO			= "Przesunięcie ikony pionowej RAID"
L.RPOTRACK_RYIOD		= "Dostosuj pozycję ikonę ramy RAID RotPO w górę iw dół."

-- 3rd Party Frame Options
L.RPOTRACK_Mode1		= "Domyślna"
--L.RPOTRACK_Mode2		= "Foundry Tactical Combat"
--L.RPOTRACK_Mode3		= "Lui Extended"
--L.RPOTRACK_Mode4		= "Bandits User Interface"
--L.RPOTRACK_Mode5		= "AUI"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'pl') then -- overwrite GetLanguage for new language
	for k, v in pairs(RPOTracker:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function RPOTracker:GetLanguage() -- set new language return
		return L
	end
end
