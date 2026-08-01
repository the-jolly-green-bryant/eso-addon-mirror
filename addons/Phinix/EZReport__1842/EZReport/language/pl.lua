local EZReport = _G['EZReport']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Polish
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Labels
L.EZReport_GOpts				= "Opcje globalne"
L.EZReport_TIcon				= "Pokaż ikonę raportowanego celu"
L.EZReport_DTime				= "Pokaż czas raportowania celu"
L.EZReport_RCooldown			= "Raportowanie czasu odnowienia"
L.EZReport_RCooldownM			= "EZReport został już zgłoszony: raportowanie czasu odnowienia jest włączone."
L.EZReport_OutputChat			= "Pokaż wiadomości czatu"
L.EZReport_12HourFormat			= "Format godziny 12-godzinnej"
L.EZReport_IncPrev				= "Dołącz poprzednie dane raportu"
L.EZReport_DCategory			= "Domyślna kategoria"
L.EZReport_DReason				= "Domyślny powód"
L.EZReport_Reset				= "Resetuj historię raportów"
L.EZReport_Clear				= "JASNY"

-- Target Reported Colors
L.EZReport_RColorS				= "Kolory zgłaszane przez cel"
L.EZReport_RColor1				= "Kolor ogólny"
L.EZReport_RColor2				= "Zły kolor nazwy"
L.EZReport_RColor3				= "Kolor toksyczny"
L.EZReport_RColor4				= "Kolor oszustwa"
L.EZReport_RColor5				= "Alt Reported Colour"

-- Addon Setting Tooltips
L.EZReport_TIconT				= "Pokaż ikonę wskazującą cele, które wcześniej zgłosiłeś. Pasuje do ikon widocznych przy wyborze kategorii w oknie raportu."
L.EZReport_DTimeT				= "Pokaż czas, w którym cel był ostatnio raportowany obok ikony Raportowane cele. Jeśli bieżący znak nigdy nie został zgłoszony, pokazuje ostatni czas, w którym zgłoszono jakąkolwiek postać na jego koncie."
L.EZReport_RCooldownT			= "Po włączeniu zapobiega zgłaszaniu skrótów klawiszowych, jeśli cel został już zgłoszony dzisiaj. Pomocne przy zgłaszaniu dużych grup botów, aby można było spamować keybind, a system raportowania będzie aktywowany tylko wtedy, gdy masz cel, którego jeszcze nie zgłosiłeś."
L.EZReport_OutputChatT			= "Wyświetla komunikaty informacyjne związane z różnymi funkcjami dodatków na czacie."
L.EZReport_12HourFormatT		= "Po włączeniu wygenerowane znaczniki czasu będą używać formatu godziny 12 godzin (godzina plus AM lub PM). Wyłączenie tej opcji spowoduje wyświetlenie 24-godzinnego formatu „czasu wojskowego”."
L.EZReport_IncPrevT				= "Obejmuje datę, godzinę i dane o poprzednich raportach o tym charakterze lub znanych znakach podczas wysyłania raportu."
L.EZReport_DCategoryT			= "Wybierz domyślną podkategorię, aby automatycznie wybrać podczas otwierania okna raportu."
L.EZReport_DReasonT				= "Dołącz wybrany powód w sekcji szczegółów niestandardowych okna raportowania. Opcja ręczna (domyślna) polega na pozostawieniu tego pustego pola, aby wpisać go ręcznie."
L.EZReport_ResetT				= "Wyczyść całą bazę danych wcześniej zgłoszonych znaków i kont."
L.EZReport_ResetM				= "Baza danych EZReport została zresetowana."

-- Category List
L.EZReport_CatList1				= "Złe imię"
L.EZReport_CatList2				= "Dokuczanie"
L.EZReport_CatList3				= "Oszukiwanie"
L.EZReport_CatList4				= "Inny"
L.EZReport_CatList5				= "Brak (domyślnie)"

-- Reason List
L.EZReport_ReasonList1			= "Botting"
L.EZReport_ReasonList2			= "Wykorzystanie"
L.EZReport_ReasonList3			= "Dokuczanie"
L.EZReport_ReasonList4			= "Ręcznie (domyślnie)"

-- Chat List
L.EZReport_CReason1				= "Raport ogólny"
L.EZReport_CReason2				= "Złe imię"
L.EZReport_CReason3				= "Toksyczne zachowanie"
L.EZReport_CReason4				= "Oszukiwanie"

-- Chat Strings
L.EZReport_RepT					= "Zgłoszone:"
L.EZReport_RepC					= "Zgłoszony charakter:"
L.EZReport_Unkn					= "nieznane konto"
L.EZReport_Now					= "teraz:"
L.EZReport_Char					= "postać:"
L.EZReport_For					= "dla:"
L.EZReport_NoMatch				= "Nie znaleziono żadnego meczu."

-- Info Panel
L.EZReport_RAcct				= "Konto raportu: "
L.EZReport_RAlts				= "Uprzednio zgłoszone alty: "

-- General Strings
L.EZReport_RLast				= "Zgłoś ostatni cel gracza"
L.EZReport_RHistory				= "Historia raportu docelowego"
L.EZReport_ROpen				= "Otwórz okno główne"
L.EZReport_Reason				= "Powód (opcjonalnie):"
L.EZReport_CName				= "Imię postaci:"
L.EZReport_AName				= "Nazwa konta:"
L.EZReport_MLoc					= "Mapa:"
L.EZReport_Coords				= "Coords:"
L.EZReport_Time					= "Data / godzina:"
L.EZReport_CButton				= "Jasny"
L.EZReport_Today				= "Dzisiaj"
L.EZReport_Updated				= "Baza danych EZReport została zaktualizowana."
L.EZReport_AccUnavail			= "Konto niedostępne"
L.EZReport_LocUnavail			= "Lokalizacja niedostępna"
L.EZReport_Wayshrine			= "Wayshrine"
L.EZReport_Accounts				= "Raporty według konta"
L.EZReport_Characters			= "Raporty według postaci"
L.EZReport_Locations			= "Raporty według lokalizacji"
L.EZReport_Generated			= "Wygenerowano: EZReport by Phinix"
L.EZReport_Previous				= "Wcześniej zgłoszony:"
L.EZReport_Confirm				= "Potwierdź usunięcie"
L.EZReport_Cancel				= "Anuluj"
L.EZReport_Delete				= "Kasować"

-- Tooltip strings
L.EZReport_TTShow				= "Kliknij, aby wyświetlić podsumowanie raportu."
L.EZReport_TTClick				= "Kliknij pole wyników i naciśnij:"
L.EZReport_TTSelect1			= "Ctrl+A"
L.EZReport_TTSelect2			= " aby wybrać wszystko."
L.EZReport_TTCopy1				= "Ctrl+C"
L.EZReport_TTCopy2				= " kopiować."
L.EZReport_TTPaste1				= "Ctrl + V"
L.EZReport_TTPaste2				= " wkleić gdzie indziej."
L.EZReport_TTAccounts			= "Przełącz na wyświetlanie kont."
L.EZReport_TTCharacters			= "Przełącz na wyświetlanie znaków."
L.EZReport_TTEMode				= "Przełącz do trybu edycji bazy danych."
L.EZReport_TTRMode				= "Przełącz na tryb raportu tekstowego."
L.EZReport_TTCEntry1			= "Lewy przycisk myszy"
L.EZReport_TTCEntry2			= " aby pokazać wpisy postaci."
L.EZReport_TTAEntry1			= "Shift+Lewy przycisk myszy"
L.EZReport_TTAEntry2			= " aby wyświetlić wpisy konta."
L.EZReport_TTDEntry1			= "Kliknij prawym przyciskiem myszy"
L.EZReport_TTDEntry2			= " aby usunąć wybrany wpis."


------------------------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'pl') then -- overwrite GetLanguage for new language
	for k, v in pairs(EZReport:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function EZReport:GetLanguage() -- set new locale return
		return L
	end
end
