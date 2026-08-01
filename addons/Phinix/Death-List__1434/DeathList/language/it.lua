local DLAddon = _G['DLAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Italian
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.DLAddon_UnitAdded			= "aggiunto alla lista della morte."
L.DLAddon_ToAddPlayers		= "Devi abilitare l'opzione per aggiungere giocatori alla lista della morte."
L.DLAddon_NotAttackable		= "Target non attaccabile."
L.DLAddon_NoGuards			= "Non puoi aggiungere guardie invulnerabili alla lista della morte."
L.DLAddon_ListCleared		= "Tutti gli obiettivi della lista della morte sono stati cancellati."
L.DLAddon_ListEmpty			= "Non ci sono nomi nella tua lista di morte."
L.DLAddon_Removed			= "è stato rimosso dalla tua lista di morte."
L.DLAddon_NoExist			= "Il bersaglio non esiste nella tua lista di morte."

-- Settings panel
L.DLAddon_ShowMarker		= "Mostra il carattere di marcatura"
L.DLAddon_ShowMarkerTip		= "Mostra il nome del personaggio che ha aggiunto il bersaglio alla lista della morte."
L.DLAddon_MarkPlayers		= "Permetti di segnare i giocatori"
L.DLAddon_MarkPlayersTip	= "Ti permette di aggiungere altri giocatori alla lista della morte."
L.DLAddon_ShowDebug			= "Mostra debug"
L.DLAddon_ShowDebugTip		= "Mostra le notifiche di chat quando si eseguono le funzioni Elenco Morte."
L.DLAddon_MarkColor			= "Scegli il colore dell'icona"
L.DLAddon_MarkColorTip		= "Imposta il colore per l'icona bersaglio contrassegnata come Lista di morte."
L.DLAddon_TextColor			= "Scegli il colore del testo"
L.DLAddon_TextColorTip		= "Imposta il colore per il nome del personaggio che ha aggiunto il bersaglio alla lista della morte."
L.DLAddon_MarkSize			= "Scegli la dimensione dell'icona"
L.DLAddon_MarkSizeTip		= "Imposta la dimensione della lista delle vittime contrassegnata dall'icona bersaglio."
L.DLAddon_ChatCommants		= "Comandi di chat"
L.DLAddon_PrintList			= "Stampa il contenuto della tua lista di morte."
L.DLAddon_RemoveName		= "Rimuovi il nome specificato dalla lista della morte (senza virgolette)."
L.DLAddon_ClearList			= "Cancella tutti i bersagli dalla tua lista di morte."
L.DLAddon_Name				= "Nome"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k,v in pairs(DLAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function DLAddon:GetLanguage() -- set new language return
		return L
	end
end
