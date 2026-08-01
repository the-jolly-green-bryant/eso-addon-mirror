local RPOTracker = _G['RPOTracker']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Italian
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Panel Strings
--L.RPOTRACK_Title		= "|cFF9900Pale Order|r |cFEE854Tracker|r"
L.RPOTRACK_SOpts		= "Opzioni di auto -tracker"
L.RPOTRACK_GOpts		= "Opzioni di tracker del gruppo"

-- Self Tracker Options
--L.RPOTRACK_Show		= "Show Tracker"
L.RPOTRACK_ShowD		= "Mostra il tracker di stato attrezzato RotPO per il giocatore."
--L.RPOTRACK_Lock		= "Lock Tracker"
L.RPOTRACK_LockD		= "Se sbloccato è possibile spostare il tracker per salvare una nuova posizione."
L.RPOTRACK_ShowG		= "Mostra raggruppato"
L.RPOTRACK_ShowGD		= "Mostra il tracker di stato attrezzato RotPO per il giocatore quando raggruppato."
L.RPOTRACK_ShowBG		= "Mostra lo sfondo"
L.RPOTRACK_ShowBGD		= "Mostra uno sfondo nero dietro l'icona del tracker RotPO."
L.RPOTRACK_Label		= "Mostra l'etichetta"
L.RPOTRACK_LabelD		= "Mostra un'etichetta di testo che indica la percentuale di forza RotPO in base al numero di membri del gruppo presenti."
L.RPOTRACK_TScale		= "Scala del tracker"
L.RPOTRACK_TScaleD		= "Ridimensionare le dimensioni per l'icona del tracker."
L.RPOTRACK_LScale		= "Scala delle etichette"
L.RPOTRACK_LScaleD		= "Ridimensionare le dimensioni per l'etichetta di testo."
L.RPOTRACK_LabelX		= "Etichettare l'offset orizzontale"
L.RPOTRACK_LabelXD		= "Regola la posizione dell'etichetta di testo RotPO da sinistra a destra."
L.RPOTRACK_LabelY		= "Etichetta l'offset verticale"
L.RPOTRACK_LabelYD		= "Regola la posizione dell'etichetta di testo RotPO su e giù."

-- Group Tracker Options
L.RPOTRACK_SGF			= "Monitorare i frame del gruppo"
L.RPOTRACK_SGFD			= "Mostra icona RotPO per frame di unità di gruppo."
L.RPOTRACK_SRF			= "Monitorare i telai raid"
L.RPOTRACK_SRFD			= "Mostra icona RotPO su frame unità raid."
L.RPOTRACK_GIS			= "Dimensione dell'icona di gruppo"
L.RPOTRACK_GISD			= "Dimensione dell'icona RotPO Se visualizzata su frame di gruppo standard."
L.RPOTRACK_RIS			= "Dimensione dell'icona raid"
L.RPOTRACK_RISD			= "Dimensione dell'icona RotPO Se visualizzata su frame raid standard."
L.RPOTRACK_GXIO			= "Offset icona orizzontale di gruppo"
L.RPOTRACK_GXIOD		= "Regola la posizione dell'icona del frame di gruppo RotPO da sinistra a destra."
L.RPOTRACK_GYIO			= "Offset di icona verticale di gruppo"
L.RPOTRACK_GYIOD		= "Regola la posizione dell'icona del frame di gruppo RotPO su e giù."
L.RPOTRACK_RXIO			= "Offset icona orizzontale raid"
L.RPOTRACK_RXIOD		= "Regola la posizione dell'icona del telaio raid RotPO da sinistra a destra."
L.RPOTRACK_RYIO			= "Offset icona verticale raid"
L.RPOTRACK_RYIOD		= "Regola la posizione dell'icona del telaio raid RotPO su e giù."

-- 3rd Party Frame Options
L.RPOTRACK_Mode1		= "Predefinito"
--L.RPOTRACK_Mode2		= "Foundry Tactical Combat"
--L.RPOTRACK_Mode3		= "Lui Extended"
--L.RPOTRACK_Mode4		= "Bandits User Interface"
--L.RPOTRACK_Mode5		= "AUI"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k, v in pairs(RPOTracker:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function RPOTracker:GetLanguage() -- set new language return
		return L
	end
end
