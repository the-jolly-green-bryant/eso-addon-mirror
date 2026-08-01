local EZReport = _G['EZReport']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Italian
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Labels
L.EZReport_GOpts				= "Opzioni globali"
L.EZReport_TIcon				= "Mostra icona referenziata"
L.EZReport_DTime				= "Mostra il tempo previsto per il target"
L.EZReport_RCooldown			= "Segnalazione del cooldown"
L.EZReport_RCooldownM			= "EZReport già segnalato oggi: Reporting Cooldown è abilitato."
L.EZReport_OutputChat			= "Mostra messaggi chat"
L.EZReport_12HourFormat			= "Formato 12 ore"
L.EZReport_IncPrev				= "Includi dati report precedenti"
L.EZReport_DCategory			= "Categoria predefinita"
L.EZReport_DReason				= "Motivo predefinito"
L.EZReport_Reset				= "Reimposta cronologia report"
L.EZReport_Clear				= "CHIARO"

-- Target Reported Colors
L.EZReport_RColorS				= "Colore target segnalato"
L.EZReport_RColor1				= "Colore generico"
L.EZReport_RColor2				= "Colore del nome errato"
L.EZReport_RColor3				= "Colore tossico"
L.EZReport_RColor4				= "Colore imbrogliare"
L.EZReport_RColor5				= "Colore Alt segnalato"

-- Addon Setting Tooltips
L.EZReport_TIconT				= "Mostra un'icona che indica gli obiettivi che hai segnalato in precedenza. Corrisponde alle icone visualizzate quando si sceglie una categoria nella finestra del rapporto."
L.EZReport_DTimeT				= "Mostra l'ora in cui è stato segnalato l'ultimo target accanto all'icona referenziata. Se il personaggio corrente non è mai stato riportato, mostra l'ultima volta in cui è stato segnalato qualsiasi personaggio sul proprio account."
L.EZReport_RCooldownT			= "Se abilitato, impedisce la segnalazione di hotkey se hai già segnalato il target oggi. Utile quando si riportano gruppi di robot di grandi dimensioni in modo da poter inviare spam alla combinazione di tasti e il sistema di report si attiverà solo quando si dispone di una destinazione che non è ancora stata segnalata."
L.EZReport_OutputChatT			= "Visualizza messaggi informativi relativi a varie funzioni di aggiunta in chat."
L.EZReport_12HourFormatT		= "Se abilitato, i timestamp generati utilizzeranno il formato 12 ore (ora più AM o PM). Spegnendolo visualizzerai il formato 'orario militare' 24 ore."
L.EZReport_IncPrevT				= "Include data, ora e dati sui nomi di rapporti precedenti di questo personaggio o di quelli noti quando si invia un rapporto."
L.EZReport_DCategoryT			= "Scegli la sottocategoria predefinita da selezionare automaticamente all'apertura della finestra del rapporto."
L.EZReport_DReasonT				= "Includere il motivo selezionato nella sezione dei dettagli personalizzati della finestra di segnalazione. L'opzione manuale (predefinita) è lasciare questo campo vuoto per poterlo digitare manualmente."
L.EZReport_ResetT				= "Cancella l'intero database di personaggi e account precedentemente segnalati."
L.EZReport_ResetM				= "Il database EZReport è stato ripristinato."

-- Category List
L.EZReport_CatList1				= "Nome brutto"
L.EZReport_CatList2				= "molestia"
L.EZReport_CatList3				= "Imbrogliare"
L.EZReport_CatList4				= "Altro"
L.EZReport_CatList5				= "Nessuno (predefinito)"

-- Reason List
L.EZReport_ReasonList1			= "Botting"
L.EZReport_ReasonList2			= "sfruttando"
L.EZReport_ReasonList3			= "molestia"
L.EZReport_ReasonList4			= "Manuale (predefinito)"

-- Chat List
L.EZReport_CReason1				= "Rapporto generico"
L.EZReport_CReason2				= "Nome brutto"
L.EZReport_CReason3				= "Comportamento tossico"
L.EZReport_CReason4				= "Imbrogliare"

-- Chat Strings
L.EZReport_RepT					= "Segnalato:"
L.EZReport_RepC					= "Personaggio segnalato:"
L.EZReport_Unkn					= "account sconosciuto"
L.EZReport_Now					= "adesso:"
L.EZReport_Char					= "personaggio:"
L.EZReport_For					= "per:"
L.EZReport_NoMatch				= "Nessun risultato trovato."

-- Info Panel
L.EZReport_RAcct				= "Segnala account: "
L.EZReport_RAlts				= "Alti precedentemente segnalati: "

-- General Strings
L.EZReport_RLast				= "Segnala l'ultimo bersaglio giocatore"
L.EZReport_RHistory				= "Target Report History"
L.EZReport_ROpen				= "Apri la finestra principale"
L.EZReport_Reason				= "Motivo (facoltativo):"
L.EZReport_CName				= "Nome del personaggio:"
L.EZReport_AName				= "Nome utente:"
L.EZReport_MLoc					= "Carta geografica:"
L.EZReport_Coords				= "coordinate:"
L.EZReport_Time					= "Appuntamento:"
L.EZReport_CButton				= "Chiaro"
L.EZReport_Today				= "Oggi"
L.EZReport_Updated				= "Il database EZReport è stato aggiornato."
L.EZReport_AccUnavail			= "Account non disponibile"
L.EZReport_LocUnavail			= "Posizione non disponibile"
L.EZReport_Wayshrine			= "Wayshrine"
L.EZReport_Accounts				= "Rapporti per conto"
L.EZReport_Characters			= "Rapporti per carattere"
L.EZReport_Locations			= "Rapporti per posizione"
L.EZReport_Generated			= "Generato: EZReport di Phinix"
L.EZReport_Previous				= "Precedentemente segnalato:"
L.EZReport_Confirm				= "Conferma cancellazione"
L.EZReport_Cancel				= "Annulla"
L.EZReport_Delete				= "Elimina"

-- Tooltip strings
L.EZReport_TTShow				= "Clicca per mostrare il riepilogo del rapporto."
L.EZReport_TTClick				= "Fare clic nel campo risultato e premere:"
L.EZReport_TTSelect1			= "Ctrl + A"
L.EZReport_TTSelect2			= " per selezionare tutto."
L.EZReport_TTCopy1				= "Ctrl + C"
L.EZReport_TTCopy2				= " copiare."
L.EZReport_TTPaste1				= "Ctrl + V"
L.EZReport_TTPaste2				= " incollare altrove."
L.EZReport_TTAccounts			= "Passa alla visualizzazione degli account."
L.EZReport_TTCharacters			= "Passa alla visualizzazione dei caratteri."
L.EZReport_TTEMode				= "Passa alla modalità di modifica del database."
L.EZReport_TTRMode				= "Passa alla modalità di rapporto testo."
L.EZReport_TTCEntry1			= "Sinistra-clic"
L.EZReport_TTCEntry2			= " per mostrare le voci dei personaggi."
L.EZReport_TTAEntry1			= "Maiusc+Sinistra-clic"
L.EZReport_TTAEntry2			= " per mostrare le voci del conto."
L.EZReport_TTDEntry1			= "Pulsante destro del mouse"
L.EZReport_TTDEntry2			= " per cancellare la voce selezionata."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k, v in pairs(EZReport:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function EZReport:GetLanguage() -- set new language return
		return L
	end
end
