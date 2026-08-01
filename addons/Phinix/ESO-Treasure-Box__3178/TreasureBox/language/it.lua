local TBoxAddon = _G['TBoxAddon']
local pTC = TBoxAddon.TColor
TBoxAddon.DB = {}
TBoxAddon.AT = {}
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Italian
-- (Requires human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- General
	L.TBoxAddon_SEARCHBOX				= "Cerca il tesoro per nome."
	L.TBoxAddon_CLOSE					= "Chiudi Treasure Box"
	L.TBoxAddon_TITLE					= "Treasure Box"
	L.TBoxAddon_RECENT					= "Ultimi trovati:"
	L.TBoxAddon_FAVZONE					= "Top Zona:"
	L.TBoxAddon_UPDATE1					= "[TBox]: Database di Treasure Box aggiornato."
	L.TBoxAddon_UPDATE2					= "[TBox]: Si prega /reloadui per completare."
	L.TBoxAddon_UPDATE3					= "[TBox]: Per favore, aspetta..."
	L.TBoxAddon_NOCATEGORY				= "Senza categoria"
	L.TBoxAddon_RESETSEARCH				= "Fare clic sul pulsante per resettare ricerca a testo.\n\n"..pTC("FFFFFF", "NOTA: ").."Altri filtri sono mantenuti."
	L.TBoxAddon_TFOUNDOFF				= pTC("00FF00", "Mostra solo trovato").." è"..pTC("FFFFFF", " ON").."\n\nClicca per attivare mostrando tutti i tesori fatto che siano stati trovati o no."
	L.TBoxAddon_TFOUNDON				= pTC("00FF00", "Mostra solo trovato").." è"..pTC("FFFFFF", " OFF").."\n\nClicca per mostrare solo i tesori che hai trovato su uno dei tuoi personaggi."
	L.TBoxAddon_RESETFILTER				= "Ripristina filtri"
	L.TBoxAddon_RQUALITYS1				= "Mostra solo "
	L.TBoxAddon_RQUALITYS2				= " e gli elementi di qualità superiore nell'elenco Trovati di recente."
	L.TBoxAddon_UPDATING				= "[TBox]: Aggiornamento del database Treasure Box, non riavviare..."

-- Navigation
	L.TBoxAddon_TFOUND					= "Tesoro trovato:"
	L.TBoxAddon_QUALITYHEAD				= "Qualità del tesoro:"
	L.TBoxAddon_TIMEHEAD				= "Tempo trovato:"
	L.TBoxAddon_TIMEDAYS1				= "Ultimi"
	L.TBoxAddon_TIMEDAYS2				= "giorni"
	L.TBoxAddon_ANY						= "Tutto"
	L.TBoxAddon_ALLTYPES				= "Categoria: Tutto"
	L.TBoxAddon_ALLZONES				= "Trovato in: Tutto"
	L.TBoxAddon_ANYFOUND				= "Trovato da: Tutto"
	L.TBoxAddon_QUALITYS				= "Mostra qualità: "
	L.TBoxAddon_QUALITY1				= "Normal"
	L.TBoxAddon_QUALITY2				= "Fine"
	L.TBoxAddon_QUALITY3				= "Superior"
	L.TBoxAddon_QUALITY4				= "Epic"
	L.TBoxAddon_QUALITY5				= "Legendary"
	L.TBoxAddon_FINZONES				= "Trovato In Zone:"
	L.TBoxAddon_LFOUNDIN				= "Ultimo trovato in: "
	L.TBoxAddon_LFOUNDBY				= "Ultimo trovato da: "
	L.TBoxAddon_FOUNDON					= "Ultimo trovato il: "
	L.TBoxAddon_TOTALF					= "Totale trovato: "
	L.TBoxAddon_NEVER					= "Mai"
	L.TBoxAddon_NONE					= "Nessuna"
	L.TBoxAddon_UNKNOWN					= "Sconosciuta"
	L.TBoxAddon_SALPHA					= "Ordina in ordine alfabetico"
	L.TBoxAddon_SFOUND					= "Ordina per numero trovato"

-- Settings
	L.TBoxAddon_GOPTS					= "Opzioni generali"
	L.TBoxAddon_CHARALPHA				= "Elenco dei caratteri Sort"
	L.TBoxAddon_CHARALPHAT				= "Abilitato mostra l'elenco dei caratteri in ordine alfabetico. Altrimenti usa l'ordine di selezione del personaggio del gioco.\n\n"..pTC("FFFFFF", "NOTA: ").."Il gioco restituisce solo l'ordine di CREAZIONE del personaggio. Non tiene traccia dei caratteri riordinati manualmente."
	L.TBoxAddon_USTIME					= "12 Tempo Hour"
	L.TBoxAddon_USTIMET					= "Quando abilitati, i timestamp per i tesori trovati in precedenza verranno mostrati in 12 ore con am/pm dopo l'orario. Disattiva per mostrare in 24 ore (militare)."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k, v in pairs(TBoxAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function TBoxAddon:GetLanguage() -- set new language return
		return L
	end
end
