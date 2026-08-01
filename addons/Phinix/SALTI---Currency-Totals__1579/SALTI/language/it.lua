local SALTI = _G['SALTI']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Italian
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Strings
L.SALTI_Title					= "SALTI (Totali di valuta)"
L.SALTI_PTitle					= "SALTI - Totali di valuta"
L.SALTI_GOpts					= "Opzioni globali"
L.SALTI_COpts					= "Stato del personaggio"
L.SALTI_CCTrack					= "Traccia valuta caratteri"
L.SALTI_CCTrackD				= "Tieni traccia dei Gold, AP, Writ Vouchers e delle pietre Telvar del personaggio corrente. La disattivazione cancella i dati di valuta salvati di questo personaggio."
L.SALTI_TRACKWARN				= "ATTENZIONE: ricaricherà automaticamente l\'interfaccia utente!"
L.SALTI_IWPos					= "Usa posizione indipendente"
L.SALTI_IWPosD					= "Quando è abilitato, la posizione del tooltip della valuta popup sarà ovunque l\'ultima finestra posizionata come hotkey. Imposta una combinazione di tasti o digita /salti per mostrare/nascondere SALTI per configurare la posizione della finestra."
L.SALTI_SACIcon					= "Mostra icona Alleanza/Classe"
L.SALTI_SACIconD				= "Mostra un\'icona colorata accanto al nome di ogni personaggio tracciato che indica la loro Classe e l\'Alleanza a cui appartengono."
L.SALTI_SGC						= "Mostra valuta globale"
L.SALTI_SGCD					= "Visualizza il riepilogo delle valute del conto sotto i totali standard."
L.SALTI_GCS						= "Spaziatura in valuta globale"
L.SALTI_GCSD					= "Ampliare o accorciare lo spazio tra gli elementi di valuta globali."
L.SALTI_ALPHAN					= "Alfabetizza la lista dei nomi"
L.SALTI_ALPHAND					= "Se abilitato, l\'elenco delle valute dei caratteri tracciati sarà alfabetizzato. Altrimenti l\'elenco di caratteri corrisponde all\'ordine dei tuoi personaggi nella schermata di accesso."
L.SALTI_SGBGold					= "Mostra oro della banca della gilda"
L.SALTI_SGBGoldD				= "Mostra il riepilogo dell\'oro memorizzato nelle banche della tua gilda attuale nella descrizione sintetica dell\'oro (devi visitare ogni banca della gilda per popolare/aggiornare i valori dell\'oro)."
L.SALTI_DCChar					= "Elimina i dati del personaggio:"
L.SALTI_DELETE					= "ELIMINA"
L.SALTI_CDELD					= "Rimuovi il personaggio selezionato dal database di tracciamento. Se rimuovi un personaggio ancora esistente qui, verranno automaticamente impostati per non tracciare. Accedere come carattere e riattivare il tracciamento in Opzioni carattere per aggiungerli nuovamente al database."

-- General Strings
L.SALTI_BTotal					= "Sopraelevata:"
L.SALTI_ATotal					= "Totali del conto:"
L.SALTI_SOURCE					= "FONTE"
L.SALTI_CGlobal					= "Globale:"
L.SALTI_DBUpdate				= "Il database SALTI è stato resettato da questa versione.\nSi prega di accedere a ciascun personaggio per ricostruire."

-- Below must be the same as it appears on the in-game currency tab with the translation mod you are using:
--L.SALTI_ETHeader				= "event tickets"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k, v in pairs(SALTI:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function SALTI:GetLanguage() -- set new language return
		return L
	end
end
