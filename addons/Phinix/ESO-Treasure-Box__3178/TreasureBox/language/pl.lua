local TBoxAddon = _G['TBoxAddon']
local pTC = TBoxAddon.TColor
TBoxAddon.DB = {}
TBoxAddon.AT = {}
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Polish
-- (Requires human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- General
	L.TBoxAddon_SEARCHBOX				= "Szukaj skarbu według nazwy."
	L.TBoxAddon_CLOSE					= "Blisko Treasure Box"
	L.TBoxAddon_TITLE					= "Treasure Box"
	L.TBoxAddon_RECENT					= "Ostatnio znalezione:"
	L.TBoxAddon_FAVZONE					= "Top Strefa:"
	L.TBoxAddon_UPDATE1					= "[TBox]: Zaktualizowano bazę danych Treasure Box."
	L.TBoxAddon_UPDATE2					= "[TBox]: Proszę /reloadui, aby zakończyć."
	L.TBoxAddon_UPDATE3					= "[TBox]: Proszę czekać..."
	L.TBoxAddon_NOCATEGORY				= "Bez kategorii"
	L.TBoxAddon_RESETSEARCH				= "Kliknij przycisk, aby zresetować wyszukiwanie tekstu.\n\n"..pTC("FFFFFF", "NUTA: ").."Inne filtry są utrzymywane."
	L.TBoxAddon_TFOUNDOFF				= pTC("00FF00", "Pokaż tylko znalezione").." jest"..pTC("FFFFFF", " ON").."\n\nKliknij, aby przełączyć wyświetlanie WSZYSTKICH skarbów, niezależnie od tego, czy je znalazłeś, czy nie."
	L.TBoxAddon_TFOUNDON				= pTC("00FF00", "Pokaż tylko znalezione").." jest"..pTC("FFFFFF", " OFF").."\n\nKliknij, aby wyświetlić tylko skarby, które znalazłeś przy jednej ze swoich postaci."
	L.TBoxAddon_RESETFILTER				= "Zresetuj filtry"
	L.TBoxAddon_RQUALITYS1				= "Pokaż tylko "
	L.TBoxAddon_RQUALITYS2				= " oraz przedmioty wyższej jakości z listy Ostatnio znalezione."
	L.TBoxAddon_UPDATING				= "[TBox]: Treasure Box aktualizacja bazy danych, nie uruchamiaj się ponownie..."

-- Navigation
	L.TBoxAddon_TFOUND					= "Odnaleziony skarb:"
	L.TBoxAddon_QUALITYHEAD				= "Jakość skarbów:"
	L.TBoxAddon_TIMEHEAD				= "Czas znaleziony:"
	L.TBoxAddon_TIMEDAYS1				= "Ostatnie"
	L.TBoxAddon_TIMEDAYS2				= "dni"
	L.TBoxAddon_ANY						= "Byle"
	L.TBoxAddon_ALLTYPES				= "Kategoria: Byle"
	L.TBoxAddon_ALLZONES				= "Znalezione w: Byle"
	L.TBoxAddon_ANYFOUND				= "Znalezione przez: Byle"
	L.TBoxAddon_QUALITYS				= "Pokaż jakość: "
	L.TBoxAddon_QUALITY1				= "Normal"
	L.TBoxAddon_QUALITY2				= "Fine"
	L.TBoxAddon_QUALITY3				= "Superior"
	L.TBoxAddon_QUALITY4				= "Epic"
	L.TBoxAddon_QUALITY5				= "Legendary"
	L.TBoxAddon_FINZONES				= "Znaleziony w strefach:"
	L.TBoxAddon_LFOUNDIN				= "Ostatnio znaleziono w: "
	L.TBoxAddon_LFOUNDBY				= "Ostatnio znaleziony przez: "
	L.TBoxAddon_FOUNDON					= "Ostatnio odnaleziono dnia: "
	L.TBoxAddon_TOTALF					= "Łącznie znalezione: "
	L.TBoxAddon_NEVER					= "Nigdy"
	L.TBoxAddon_NONE					= "Nic"
	L.TBoxAddon_UNKNOWN					= "Nieznany"
	L.TBoxAddon_SALPHA					= "Sortuj alfabetycznie"
	L.TBoxAddon_SFOUND					= "Sortuj według liczby znaleziono"

-- Settings
	L.TBoxAddon_GOPTS					= "Opcje ogólne"
	L.TBoxAddon_CHARALPHA				= "Sortuj listę znaków"
	L.TBoxAddon_CHARALPHAT				= "Włączone wyświetla listę znaków alfabetycznie. W przeciwnym razie używa kolejności wyboru postaci w grze.\n\n"..pTC("FFFFFF", "NUTA: ").."Gra zwraca tylko kolejność tworzenia postaci. Nie śledzi ręcznie zmienionych kolejności znaków."
	L.TBoxAddon_USTIME					= "12 godzinny czas"
	L.TBoxAddon_USTIMET					= "Po włączeniu znaczniki czasu dla wcześniej znalezionych skarbów będą wyświetlane w ciągu 12 godzin z godziną am/pm po tym czasie. Wyłącz, aby wyświetlić za 24 godziny (wojskowe)."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'pl') then -- overwrite GetLanguage for new language
	for k, v in pairs(TBoxAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function TBoxAddon:GetLanguage() -- set new language return
		return L
	end
end
