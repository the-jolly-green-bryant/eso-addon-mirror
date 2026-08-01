local PMAddon = _G['PMAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Italian
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.PMAddon_GLOBAL			= "OPZIONI GLOBALI"
L.PMAddon_LOCK				= "Posizione di blocco"
L.PMAddon_LOCKTIP			= "Previene lo spostamento della finestra di configurazione del veleno."
L.PMAddon_BACK				= "Nascondi sfondo"
L.PMAddon_BACKTIP			= "Nasconde lo sfondo della finestra di configurazione del veleno."
L.PMAddon_ICONS				= "Mostra icone equipaggia"
L.PMAddon_ICONSTIP			= "Mostra gli indicatori delle icone per i tuoi veleni delle armi attive e inattive quando assegnati a uno slot preferito."
L.PMAddon_THEME				= "Equipaggiare il tema dell'icona"
L.PMAddon_THEMETIP			= "Scegli lo stile per gli indicatori di veleno equipaggiati."
L.PMAddon_STYLE1			= "Frontiere"
L.PMAddon_STYLE2			= "Controlli"
L.PMAddon_DEBUG				= "Mostra testo di debug"
L.PMAddon_DEBUGTIP			= "Mostra un testo descrittivo nella chat quando accadono certe cose."
L.PMAddon_Tooltip			= "Fare clic tenendo premuto Maiusc per assegnare il veleno equipaggiato allo slot. Fare clic con il tasto destro per cancellare."

-- Keybind strings
L.PMAddon_KBT				= "Attiva/disattiva la finestra di configurazione veleno"
L.PMAddon_KB1				= "Equipaggia/disgiungi lo slot 1 veleno"
L.PMAddon_KB2				= "Equipaggia/disgiungi lo slot 2 veleno"
L.PMAddon_KB3				= "Equipaggia/disgiungi lo slot 3 veleno"
L.PMAddon_KB4				= "Equipaggia/disgiungi lo slot 4 veleno"

-- Debug strings
L.PMAddon_PNE				= "Il veleno desiderato non è più nelle tue borse."
L.PMAddon_NPE				= "L'arma attiva non ha veleno attrezzato da assegnare."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k,v in pairs(PMAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function PMAddon:GetLanguage() -- set new language return
		return L
	end
end
