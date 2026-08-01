local CWMAddon = _G['CWMAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Italian
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- General strings
L.CWMAddon_Reload			= "Ricarica UI"
L.CWMAddon_Clear			= "Cancella chat"
L.CWMAddon_ClearT			= "Cancella la finestra di chat corrente."
L.CWMAddon_Toggle			= "Attiva/disattiva la finestra di chat"
L.CWMAddon_Online			= "Attiva lo stato in linea"
L.CWMAddon_RBox				= "Vuoi ricaricare l'interfaccia utente?"

-- Settings panel
L.CWMAddon_Title			= "Gestore della finestra di chat"
L.CWMAddon_AutoHide			= "Nascondi automaticamente la finestra di chat"
L.CWMAddon_AutoHideT		= "Riduce al minimo la finestra di chat durante l'accesso, la modifica delle zone o il ricaricamento dell'interfaccia utente."
L.CWMAddon_RemState			= "Ricorda lo stato della chat"
L.CWMAddon_RemStateT		= "Sostituisce l'opzione successiva mantenendo lo stato di chat precedente tra le schermate di caricamento."
L.CWMAddon_RButton			= "Aggiungi pulsante Ricarica/Cancella"
L.CWMAddon_RButtonT			= "Aggiunge un pulsante alla finestra della chat per ricaricare l'interfaccia utente o fare clic tenendo premuto il tasto Maiusc per cancellare la chat corrente."
L.CWMAddon_ROffset			= "Tasto di ricarica offset"
L.CWMAddon_ROffsetT			= "Modificare la posizione orizzontale del pulsante Ricarica quando la chat è massimizzata (per la compatibilità con altri addon)."
L.CWMAddon_RConfirm			= "Conferma Ricarica interfaccia utente"
L.CWMAddon_RConfirmT		= "Aggiunge una casella di conferma quando si fa clic sul pulsante Ricarica interfaccia utente per evitare ricariche accidentali."
L.CWMAddon_SButton			= "Aggiungi il menu di stato del giocatore"
L.CWMAddon_SButtonT			= "Aggiunge il menu di selezione dello stato online del giocatore alla finestra della chat."
L.CWMAddon_SChat			= "Cambia stato nella chat"
L.CWMAddon_SChatT			= "Mostra lo stato online del giocatore nella chat quando viene modificato dalla combinazione di tasti o da un altro metodo."
L.CWMAddon_SOffset			= "Offset dello stato"
L.CWMAddon_SOffsetT			= "Modificare la posizione orizzontale dell'indicatore di stato online quando la chat è massimizzata (per la compatibilità con altri addon)."
L.CWMAddon_Extras			= "Opzioni extra"
L.CWMAddon_DConfirm			= "Conferma eliminazione semplice"
L.CWMAddon_DConfirmT		= "Elimina la necessità di digitare 'DELETE' quando si eliminano determinate cose. Otterrai invece una casella per fare clic su Sì o No."
L.CWMAddon_HideFriend		= "Nascondi il login e logout amico"
L.CWMAddon_HideFriendT		= "Prevenire amico login e messaggi di stato di logout di apparire in chat."
L.CWMAddon_TutorialOff		= "Disattiva i tutorial"
L.CWMAddon_TutorialOffT		= "Disattiva automaticamente i tutorial popup all'accesso (e quando si abilita questa opzione). Può essere riattivato dalle impostazioni di gioco."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k,v in pairs(CWMAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function CWMAddon:GetLanguage() -- set new language return
		return L
	end
end
