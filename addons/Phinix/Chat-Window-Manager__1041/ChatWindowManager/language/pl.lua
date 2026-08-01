local CWMAddon = _G['CWMAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Polish
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- General strings
L.CWMAddon_Reload			= "Przeładować UI"
L.CWMAddon_Clear			= "Wyczyść czat"
L.CWMAddon_ClearT			= "Wyczyść obecne okno czatu."
L.CWMAddon_Toggle			= "Przełącz okno czatu"
L.CWMAddon_Online			= "Przełącz stan online"
L.CWMAddon_RBox				= "Czy chcesz ponownie załadować interfejs użytkownika?"

-- Settings panel
L.CWMAddon_Title			= "Menedżer okna rozmowy"
L.CWMAddon_AutoHide			= "Automatyczne ukrywanie okna czatu"
L.CWMAddon_AutoHideT		= "Minimalizuje okno czatu podczas logowania, zmiany stref lub przeładowania UI."
L.CWMAddon_RemState			= "Zapamiętaj stan czatu"
L.CWMAddon_RemStateT		= "Zastąp następną opcję, utrzymując poprzedni stan czatu między ekranami załadunkowymi."
L.CWMAddon_RButton			= "Dodaj przycisk Odśwież/Wyczyść"
L.CWMAddon_RButtonT			= "Dodaje przycisk do okna czatu, aby ponownie załadować interfejs użytkownika, lub kliknij z wciśniętym klawiszem Shift, aby wyczyścić bieżący czat."
L.CWMAddon_ROffset			= "Przesunięcie przesunięcia."
L.CWMAddon_ROffsetT			= "Zmień poziomą pozycję przycisku przeładowywania, gdy czat jest zmaksymalizowany (do zgodności z innymi dodatkami)."
L.CWMAddon_RConfirm			= "Potwierdź przeładowanie UI"
L.CWMAddon_RConfirmT		= "Dodaje okno potwierdzenia po kliknięciu przycisku Wczytaj ponownie interfejs użytkownika, aby uniknąć przypadkowego ponownego załadowania."
L.CWMAddon_SButton			= "Dodaj menu statusu gracza"
L.CWMAddon_SButtonT			= "Dodaje menu wyboru statusu online gracza do okna czatu."
L.CWMAddon_SChat			= "Przełącz status w czacie"
L.CWMAddon_SChatT			= "Pokaż status gracza online na czacie po zmianie przez klawisz lub inną metodę."
L.CWMAddon_SOffset			= "Przesunięcie statusu"
L.CWMAddon_SOffsetT			= "Zmień poziomą pozycję wskaźnika stanu online, gdy czat jest zmaksymalizowany (do kompatybilności z innymi dodatkami)."
L.CWMAddon_Extras			= "Dodatkowe opcje"
L.CWMAddon_DConfirm			= "Proste usuwanie Potwierdź"
L.CWMAddon_DConfirmT		= "Eliminuje konieczność wpisywania 'DELETE' podczas usuwania niektórych rzeczy. Zamiast tego otrzymasz pole do kliknięcia Tak lub Nie."
L.CWMAddon_HideFriend		= "Ukryj Friend Zaloguj & Wyloguj"
L.CWMAddon_HideFriendT		= "Zapobiegaj znajomym logowaniu/wylogowaniu komunikaty pojawiające się na czacie."
L.CWMAddon_TutorialOff		= "Wyłącz samouczki"
L.CWMAddon_TutorialOffT		= "Automatycznie wyłączaj wyskakujące samouczki podczas logowania (i podczas włączania tej opcji). Można ponownie włączyć w ustawieniach rozgrywki."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'pl') then -- overwrite GetLanguage for new language
	for k,v in pairs(CWMAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function CWMAddon:GetLanguage() -- set new language return
		return L
	end
end
