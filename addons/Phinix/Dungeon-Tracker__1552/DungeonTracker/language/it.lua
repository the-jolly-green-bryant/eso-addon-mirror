local DTAddon = _G['DTAddon']
local L = {}

--------------------------------------------------------------------------------------------------------------------
-- Italian (Needs human translation!)
--------------------------------------------------------------------------------------------------------------------

-- General Strings
--	L.DTAddon_Title			= "Tracciamento Prigione"
	L.DTAddon_CNorm			= "Completato normale: "
	L.DTAddon_CVet			= "Veterano completato: "
	L.DTAddon_CNormI		= "Completato normale I: "
	L.DTAddon_CNormII		= "Completato Normale II: "
	L.DTAddon_CVetI			= "Veterano I completato: "
	L.DTAddon_CVetII		= "Completato Veteran II: "
L.DTAddon_CGChal		= "Gruppo Challenge Skillpoint"
	L.DTAddon_CDBoss		= "Tutti i Capos sconfitti: "
	L.DTAddon_Unlock		= "Sblocca a livello: "
L.DTAddon_True			= "Vero"
L.DTAddon_False			= "Falso"
L.DTAddon_None			= "Nessuna"
L.DTAddon_MQOPT1		= "Tutti i caratteri"
L.DTAddon_MQOPT2		= "Carattere attuale"
L.DTAddon_MQOPT3		= "Non visualizzare"
	L.DTAddon_CTOPT1		= "Mostra entrambi"
	L.DTAddon_CTOPT2		= "Solo completato"
	L.DTAddon_CTOPT3		= "Solo incompleto"
L.DTAddon_QComp			= "Missione completata: "
L.DTAddon_QCompI		= "Missione I completata: "
L.DTAddon_QCompII		= "Missione II completata: "
L.DTAddon_AWide			= " (A livello di conto)"
L.DTAddon_QMQ			= "Seleziona missioni incomplete"
L.DTAddon_QMQTip		= "Seleziona i sotterranei per i quali il personaggio attuale non ha ancora completato la ricerca del punto di abilità."
L.DTAddon_QMQVTip		= "Se controllato, la versione veterana di Dungeon viene selezionata per completare le missioni dei punti di abilità (non consigliati).\n\n|cffffffNOTA|r: La missione per i punti di abilità è la stessa in modalità normale e veterana e può essere completata una sola volta."

-- Account Options
	L.DTAddon_SHMComp		= "Mostra il completamento della modalità Difficile"
L.DTAddon_SHMCompD		= "Mostra un'icona Se hai completato il veterano selezionato Dungeon o Trial Hard Mode Achievement."
	L.DTAddon_STTComp		= "Mostra completamento prova a tempo"
L.DTAddon_STTCompD		= "Mostra un'icona se hai completato il dungeon veterano selezionato o il successo del tempo di prova."
	L.DTAddon_SNDComp		= "Non mostrare il completamento della morte"
L.DTAddon_SNDCompD		= "Mostra un'icona Se hai completato il Dungeon veterano selezionato o il processo di prova senza morte."
L.DTAddon_SGFComp		= "Completamento della fazione di dungeon di gruppo"
L.DTAddon_SGFCompD		= "Mostra i progressi attuali verso il completamento di tutti i dungeon di gruppo nella fazione del dungeon evidenziato."
	L.DTAddon_SLFGt			= "LFG: Mostra Completamento del Prigione"
L.DTAddon_SLFGtD		= "Mostra le informazioni sui risultati nel tooltip di Group Finder."
	L.DTAddon_SLFGd			= "LFG: Mostra la Descrizione del Prigione"
	L.DTAddon_SLFGdD		= "Mostra la descrizione del gioco del prigione sulle descrizioni dei comandi LFG. Questo è normalmente nascosto."
	L.DTAddon_SNComp		= "MAPPA: Completamento dungeon del gruppo normale"
L.DTAddon_SNCompD		= "Mostra se hai completato il dungeon o la prova in modalità normale nella descrizione comando."
	L.DTAddon_SVComp		= "MAPPA: Completamento dungeon del gruppo veterano"
L.DTAddon_SVCompD		= "Mostra se hai completato il dungeon o la prova in modalità Veterano nella descrizione comandi."
L.DTAddon_SGCCompM		= "MAPPA: "
L.DTAddon_SGCComp		= "Skillpoint del dungeon pubblico"
L.DTAddon_SGCCompD		= "Mostra se il tuo personaggio attuale ha completato la sfida del Gruppo Punto Punto di Dungeon Public Point nel tooltip."
L.DTAddon_SDBComp		= "MAPPA: Completamento del capo pubblico Dungeon"
L.DTAddon_SDBCompD		= "Mostra se hai sconfitto tutti i capi dei dungeon pubblici nel tooltip."
L.DTAddon_SDFComp		= "MAPPA: Completamento della fazione pubblica Dungeon"
L.DTAddon_SDFCompD		= "Mostra i progressi attuali verso il completamento di tutti i dungeon pubblici nel raggiungimento della fazione."
L.DTAddon_CNColor		= "Colore finito:"
L.DTAddon_CNColorD		= "Seleziona il colore per lo stato di completamento o i nomi dei personaggi che hanno completato la missione del dungeon skillpoint."
L.DTAddon_NNColor		= "Colore incompleto:"
L.DTAddon_NNColorD		= "Seleziona il colore per lo stato di completamento o i nomi dei personaggi che NON hanno completato la missione del dungeon skillpoint."
L.DTAddon_QCompHead		= "Completamento missione del dungeon"
L.DTAddon_QCompS		= "Mostra missioni del dungeon"
L.DTAddon_QCompSD		= "Scegli se mostrare lo stato di completamento della missione del dungeon. Seleziona se mostrare lo stato di tutti i caratteri o solo quello corrente.\n\nNOTA: dovrai accedere a ciascun personaggio almeno una volta affinché vengano visualizzati nell'elenco di tutti i personaggi."
L.DTAddon_CTDROPDOWN	= "Formato per il testo di completamento"
L.DTAddon_CTDROPDOWND	= "Se mostri tutti i personaggi, scegli se mostrare solo quelli che hanno completato la ricerca dei punti abilità del dungeon, solo quelli che non l'hanno fatto o entrambi (predefinito)."
L.DTAddon_ALPHAN		= "Alfabetizza l'elenco dei nomi"
L.DTAddon_ALPHAND		= "Quando abilitati, gli elenchi di completamento delle descrizioni comandi saranno in ordine alfabetico. Altrimenti l'ordine dell'elenco corrisponde all'ordine di creazione dei tuoi personaggi."
L.DTAddon_CHighlight	= "Evidenzia il carattere corrente"
L.DTAddon_CHighlightD	= "Mostra un asterisco (*) e utilizzare il colore del risultato del carattere corrente per evidenziare Dungeon Quest Completamento per il tuo carattere registrato corrente quando si mostra l'elenco."
L.DTAddon_HColor		= "Colore del carattere corrente"
L.DTAddon_HColorD		= "Cambia il colore per evidenziare il carattere corrente nell'elenco dei nomi per il completamento di Dungeon Quest."

-- Character Tracking
L.DTAddon_CharTracking	= "Monitoraggio dei personaggi"
L.DTAddon_TrackChar		= "Traccia il personaggio attuale"
L.DTAddon_TrackCharD	= "Include il personaggio attualmente connesso nel riepilogo del completamento della missione quando "..L.DTAddon_QCompS.." è impostato su "..L.DTAddon_MQOPT1..". Riattivalo mentre sei connesso per aggiungerlo di nuovo."
L.DTAddon_TrackWarn		= "ATTENZIONE: l'interfaccia utente verrà ricaricata automaticamente!"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k,v in pairs(DTAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function DTAddon:GetLanguage() -- set new language return
		return L
	end
end
