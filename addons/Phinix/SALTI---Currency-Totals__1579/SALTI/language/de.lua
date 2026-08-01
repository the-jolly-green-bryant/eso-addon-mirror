local SALTI = _G['SALTI']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- German
-- (Non-indented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Strings
L.SALTI_Title					= "SALTI (Währungssummen)"
L.SALTI_PTitle					= "SALTI - Währungssummen"
L.SALTI_GOpts					= "Globale optionen"
L.SALTI_COpts					= "Charakterstatus"
L.SALTI_CCTrack					= "Track-Währung."
L.SALTI_CCTrackD				= "Verfolgen Sie den aktuellen Charakter Gold, AP, Writ Gutscheine und Telvar Steine. Wenn Sie dies deaktivieren, werden die gespeicherten Währungsdaten des Zeichens gelöscht."
L.SALTI_TRACKWARN				= "WARNUNG: Wird die Benutzeroberfläche automatisch neu laden!"
L.SALTI_IWPos					= "Verwenden Sie eine unabhängige Position."
L.SALTI_IWPosD					= "Wenn aktiviert, wird die Position der Popup-Währung Tooltip überall dort sein, wo das Hotkey-umgeschaltete Fenster zuletzt positioniert wurde. Setzen Sie einen Keybind oder geben Sie /salti ein, um SALTI anzuzeigen/auszublenden, um die Fensterposition zu konfigurieren."
L.SALTI_SACIcon					= "Zeige Allianz/Klassen-Ikone."
L.SALTI_SACIconD				= "Zeigt ein farbiges Symbol neben dem Namen jedes verfolgten Charakters an, in dem sie ihre Klasse und die Allianz angeben, zu der sie gehören."
L.SALTI_SGC						= "Globale Währung anzeigen"
L.SALTI_SGCD					= "Zeigen Sie die Zusammenfassung der kontoweiten Währungen unter den Standardsummen an."
L.SALTI_GCS						= "Global Währungsabstand"
L.SALTI_GCSD					= "Den Raum zwischen globalen Währungsgegenständen erweitern oder verkürzen."
L.SALTI_ALPHAN					= "Alphabetisch Namensliste"
L.SALTI_ALPHAND					= "Wenn diese Option aktiviert ist, wird die Liste der Währungen für verfolgte Zeichen alphabetisch sortiert. Andernfalls stimmt die Liste der Zeichen mit der Reihenfolge Ihrer Zeichen auf dem Anmeldebildschirm überein."
L.SALTI_SGBGold					= "Gildenbank Gold anzeigen"
L.SALTI_SGBGoldD				= "Zeigen Sie die Zusammenfassung des Goldes, das in Ihren aktuellen Gildenbanken gespeichert ist, in der Goldzusammenfassung Tooltip (muss jede Gildenbank besuchen, um Goldwerte zu bevölkern/zu aktualisieren)."
L.SALTI_DCChar					= "Löschen der Daten des Charakters:"
L.SALTI_DELETE					= "LÖSCHEN"
L.SALTI_CDELD					= "Entfernen Sie das ausgewählte Zeichen aus der Tracking-Datenbank. Wenn Sie hier ein noch vorhandenes Zeichen entfernen, werden diese automatisch so eingestellt, dass sie nicht nachverfolgt werden. Logge dich als Charakter ein und aktiviere das Tracking erneut unter Zeichenoptionen, um sie wieder zur Datenbank hinzuzufügen."

-- General Strings
L.SALTI_BTotal					= "Bankiert:"
L.SALTI_ATotal					= "Konto Summen:"
L.SALTI_SOURCE					= "QUELLE"
L.SALTI_CGlobal					= "Global:"
L.SALTI_DBUpdate				= "Die SALTI-Datenbank wurde auf diese Version zurückgesetzt.\nBitte melden Sie sich bei jedem Zeichen an, um es neu zu erstellen."
L.SALTI_ETICKETS				= "ereignisscheine"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k, v in pairs(SALTI:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function SALTI:GetLanguage() -- set new language return
		return L
	end
end
