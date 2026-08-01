local RC = _G['RollCallAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- French
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

--Strings for /toss.
L.RollCallToss1			= "Têtes."
L.RollCallToss2			= "Tails."
L.RollCallToss3			= " lance une Drake et il atterrit "
L.RollCallTossQ1		= "[Lancer] Utilisation: /toss option"
L.RollCallTossQ2		= "[Lancer] L'option valide est 2 (ce qui signifie une pièce recto verso)."
L.RollCallTossQ3		= "[Lancer] La défaut (quand aucune valeur/valeur invalide n'est entrée) est 2."

--Strings for /roll.
L.RollCallRoll1			= "[Lancez] sur "
L.RollCallRoll2			= " sur "
L.RollCallRoll3			= " par: "
L.RollCallRoll4			= " lance "
L.RollCallRoll5			= " lance un dé en bois et jette un "
L.RollCallRoll6			= " dés en bois et lance "
L.RollCallRollQ1		= "[Lancez] Utilisation: /roll option"
L.RollCallRollQ2		= "[Lancez] Les options valides sont 6, 10, 12, 18, 24, 50, 100 et 1000."
L.RollCallRollQ3		= "[Lancez] La défaut (lorsque aucune valeur/valeur invalide n'est entrée) est 100. Voir options."
L.RollCallRollQ4		= "[Lancez] Les valeurs 'spéciales' sont 6, 12, 18 et 24."

--Settings panel strings.
L.RollCallCharOpt		= "Options du personnage"
L.RollCallRollO			= "Option de rouleau par défaut"
L.RollCallRollOD		= "Choisissez le comportement par défaut lorsque vous tapez /roll par lui-même sans option numérique. La valeur par défaut est un déploiement standard de 100. Voir options."
L.RollCallOpt1			= "Lancer 1 dé."
L.RollCallOpt2			= "Lancez 2 dés."
L.RollCallOpt3			= "Lancez 3 dés."
L.RollCallOpt4			= "Lancez 4 dés."
L.RollCallOpt5			= "Lancez / 10"
L.RollCallOpt6			= "Lancez / 20"
L.RollCallOpt7			= "Lancez / 50"
L.RollCallOpt8			= "Lancez / 100"
L.RollCallOpt9			= "Lancez / 1000"
L.RollCallDC			= "Désactiver au combat"
L.RollCallDCD			= "Empêche RollCall de répondre aux pings si vous êtes en combat. Évite les spams indésirables lors des discussions en groupe où les pings sur les cartes sont fréquents à cause des addons de partage DPS."
L.RollCallCM			= "Activer le mode de discussion"
L.RollCallCMD			= "Activer l'envoi de la sortie (sans graphiques) vers le chat actif au lieu du groupe. REMARQUE: vous devrez toujours appuyer manuellement sur entrée pour publier en raison des limitations de l'API empêchant le spam par chat via des addons."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'fr') then -- overwrite GetLanguage for new language
	for k,v in pairs(RC:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function RC:GetLanguage() -- set new language return
		return L
	end
end
