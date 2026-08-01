local GroupFDB = _G['GroupFDB']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Italian
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- Panel Strings.
L.GroupFDB_Title			= "Cibo e bevande di gruppo"
L.GroupFDB_GOpts			= "Opzioni globali"
L.GroupFDB_SGF				= "Monitora fotogrammi di gruppo"
L.GroupFDB_SGFD				= "Mostra il cibo delle icone delle bevande sui frame delle unità di gruppo."
L.GroupFDB_SRF				= "Monitorare i frame Raid"
L.GroupFDB_SRFD				= "Mostra il cibo delle icone delle bevande sui telai delle unità raid."
L.GroupFDB_SAB				= "Mostra indicatore di effetto attivo"
L.GroupFDB_SABD				= "Mostra l'icona per il cibo o bevande attiva sui telai di gruppo e RAID."
L.GroupFDB_SJB				= "Mostra indicatore dell'effetto spazzatura"
L.GroupFDB_SJBD				= "Mostra l'icona attiva per il cibo spazzatura o bevande sui telai di gruppo e RAID."
L.GroupFDB_SNB				= "Mostra indicatore dell'effetto mancante"
L.GroupFDB_SNBD				= "Mostra un'icona rossa sui telai di gruppo e RAID quando un membro non ha alcun cibo o bevande attiva."
L.GroupFDB_GMode			= "Modalità Buff gruppo"
L.GroupFDB_GModeD			= "Selezionare il modulo di supporto per i frame di unità di gruppo attualmente utilizzati. L'impostazione predefinita è il frame normale del gioco."
L.GroupFDB_RMode			= "Raid Buff Mode"
L.GroupFDB_RModeD			= "Seleziona il modulo di supporto per i frame dell'unità raid che usi attualmente. L'impostazione predefinita è il frame normale del gioco."
L.GroupFDB_GIS				= "Gruppo dimensione delle icone"
L.GroupFDB_GISD				= "Dimensione dell'icona cibo o bevanda quando visualizzato su telai di gruppo standard, come un multiplo di 8 pixel."
L.GroupFDB_RIS				= "Raid dimensioni delle icone"
L.GroupFDB_RISD				= "Dimensione dell'icona cibo o bevanda quando visualizzato su telai del raid normali, come un multiplo di 8 pixel."
L.GroupFDB_GXIO				= "Gruppo orizzontale icona Offset"
L.GroupFDB_GXIOD			= "Regola la posizione dell'icona cibo/bevanda della cornice del gruppo da sinistra a destra."
L.GroupFDB_GYIO				= "Gruppo verticale icona Offset"
L.GroupFDB_GYIOD			= "Regola la posizione del gruppo di alimenti/bevande icona del gruppo su e giù."
L.GroupFDB_RXIO				= "Raid Horizontal Icon Offset"
L.GroupFDB_RXIOD			= "Regola la posizione dell'icona cibo/bevanda della cornice del raid da sinistra a destra."
L.GroupFDB_RYIO				= "Raid verticale icona Offset"
L.GroupFDB_RYIOD			= "Regola la posizione dell'icona cibo/bevanda della cornice raid su e giù."

-- Group frame support options
L.GroupFDB_Mode1			= "Predefinito"
--L.GroupFDB_Mode2			= "Foundry Tactical Combat"
--L.GroupFDB_Mode3			= "Lui Extended"
--L.GroupFDB_Mode4			= "Bandits User Interface"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k,v in pairs(GroupFDB:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function GroupFDB:GetLanguage() -- set new language return
		return L
	end
end
