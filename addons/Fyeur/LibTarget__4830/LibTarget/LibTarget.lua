
-- ------------------
-- Information Addon
-- ------------------

LibTarget = LibTarget or {}
local LibTG = LibTarget

LibTG.Name            = "LibTarget"
LibTG.DisplayName     = "LibTarget"
LibTG.Version         = "1.0"
LibTG.Author          = "|c159324Fyeur|r"


-- ---------------
-- Valeur général
-- ---------------

local TARGET_UPDATE = 300              -- Intervalle de mise à jour de la cible en ms (0.3 sec)
local TgUpdActive  = false             -- Indique si le tracking de cible est actuellement actif (events enregistrés)
local TgChActive  = false              -- Indique si le changement de cible est actuellement actif (events enregistrés)
local PlayerTgUpdActive  = false

LibTG.Tracking        = false          -- Indique si l'utilisateur a activé le tracking via Tracker()
LibTG.TargetUpdate    = false          -- Vrai si la cible actuelle fait partie de la MobList
LibTG.LastSwapInfo    = {}             -- Dernière donnée d'échange reçu
LibTG.SwapingInfo     = {}             -- Dernières données échangées pour chaque mob et chaque utilisateur
LibTG.MobPosList      = {}             -- Liste des positions des mobs trackés
LibTG.MobList         = {}             -- Liste des mobs à surveiller (format : "nom" = n°Mob,)

-- Structure de données pour l'encodage/décodage des informations transmises
-- Format : {valeur_initiale, nb_bits, nom_du_champ}
LibTG.MobData = {
	{0, 24, "maxLife"},
	{0, 24, "currentLife"},
	{0, 24, "PosX"},
	{0, 24, "PosZ"},
	{0, 16, "Ang"},
	{0, 8,  "Mob"},
	{0, 8,  "Buff"},
}

LibTG.PlayerData = {
	{0, 16, "Ulti"},
	{0, 8, "Stam"},
	{0, 8, "Magie"},
}



-- --------------------------------------------------
-- Déclenchée à chaque changement de cible (réticule)
-- --------------------------------------------------

function LibTG.OnTargetChanged()
	-- Activer/Désactiver LibTG.TargetUpdate en fonction de la MobList
	if DoesUnitExist("reticleover") then
		mobName = GetUnitName("reticleover")
		LibTG.TargetUpdate = LibTG.MobList[mobName] and true or false
	else
		LibTG.TargetUpdate = false
	end

	-- Cas 1 : Activer target update si mob dans le reticule correspond a mobList
	--if LibTG.TargetUpdate and not TgUpdActive then
	--	LibTG.SendingTargetData()                                   -- Envoie immédiatement les données
	--	EVENT_MANAGER:RegisterForUpdate(LibTG.Name .. "_TARGET_UPDATE", TARGET_UPDATE, LibTG.SendingTargetData)
	--	TgUpdActive = true

	-- Cas 2 : Désactiver target update si aucun mob dans le reticule correspond a mobList et target update déjà activé
	--elseif not LibTG.TargetUpdate and TgUpdActive then
	--	EVENT_MANAGER:UnregisterForUpdate(LibTG.Name .. "_TARGET_UPDATE")
	---	TgUpdActive = false
	--end
end



-- ------------------------------------------------------------------
-- Gère l'activation/désactivation du tracking selon l'état du groupe
-- Appelée sur JOIN, LEFT et PLAYER_ACTIVATED
-- ------------------------------------------------------------------

function LibTG.GroupCheck(eventCode, _, _, isLocalPlayer)
	-- Si intégration/exclution de groupe, chargement de zone, ou appel via LibTG.Tracker
	if isLocalPlayer or eventCode == 13021 then
		-- Cas 1 : Si le joueur est en groupe et le tracking est demandé, mais non activé -> Activer
		if IsUnitGrouped("player") and LibTG.Tracking and not TgChActive then
			EVENT_MANAGER:RegisterForEvent(LibTG.Name, EVENT_RETICLE_TARGET_CHANGED, LibTG.OnTargetChanged)
			TgChActive = true

		-- Cas 2 : Si le joueur n'est plus en groupe ou le tracking plus demandé -> désactiver
		elseif not IsUnitGrouped("player") or not LibTG.Tracking then
			-- Cas 2.1 : Si le target change est activé -> désactiver
			if TgChActive then 
				EVENT_MANAGER:UnregisterForEvent(LibTG.Name, EVENT_RETICLE_TARGET_CHANGED)
				TgChActive = false
			end

			-- Cas 2.2 : Si le target update est activé -> désactiver
			if TgUpdActive then
				EVENT_MANAGER:UnregisterForUpdate(LibTG.Name .. "_TARGET_UPDATE")
				TgUpdActive = false
			end
		end
	end
	
	if IsUnitGrouped("player") and not PlayerTgUpdActive then
		EVENT_MANAGER:RegisterForUpdate(LibTG.Name .. "_PLAYER_TARGET_UPDATE", TARGET_UPDATE, LibTG.SendingTargetData)
		PlayerTgUpdActive = true
	elseif not IsUnitGrouped("player") and PlayerTgUpdActive then
		EVENT_MANAGER:RegisterForUpdate(LibTG.Name .. "_PLAYER_TARGET_UPDATE", TARGET_UPDATE, LibTG.SendingTargetData)
		PlayerTgUpdActive = false
	end
end



-- ---------------------------------------------------------------
-- API publique : active/désactive le tracking et définit la liste
-- des mobs à surveiller.
--   StartTracking : booléen
--   mobNameList   : table de strings ou table de {nom, n°mob}
--   LibTG.MobPosList : Stock l'information final "n°mob" = {}
-- ---------------------------------------------------------------

function LibTG.Tracker(StartTracking, mobNameList)
	LibTG.Tracking = StartTracking
	if type(mobNameList) == "table" then
		for i, v in ipairs(mobNameList) do
			if type(v) == "table" and #v == 2 then
				if type(v[1]) == "string" and type(v[2]) == "number" then
					LibTG.MobList[v[1]] = v[2]
					LibTG.MobPosList[v[2]] = {}
					LibTG.SwapingInfo[v[2]] = {}
				end
			end
		end
	end
	LibTG.GroupCheck(_, _, _, StartTracking)
end



--[[
 * Master Initialization Function
 * ------------------------------
 * EVENT: EVENT ADD ON LOADED
 * ------------------------------
]]--

function Initialize(event, addonName)

	-- Vérification de l'addon chargé
	if addonName ~= LibTG.Name then return end
	EVENT_MANAGER:UnregisterForEvent(LibTG.Name, EVENT_ADD_ON_LOADED)
	
	if LibTG.RegisterLGBHandler then LibTG:RegisterLGBHandler() end
	
	-- EVENT_GROUP_MEMBER : Surveillance si le joueur intégre ou quite un groupe
	EVENT_MANAGER:RegisterForEvent(LibTG.Name, EVENT_GROUP_MEMBER_LEFT,   LibTG.GroupCheck)
	EVENT_MANAGER:RegisterForEvent(LibTG.Name, EVENT_GROUP_MEMBER_JOINED, LibTG.GroupCheck)
	-- PLAYER_ACTIVATED : Garantit l'init si reloadui alors que le joueur est déjà dans un groupe
	EVENT_MANAGER:RegisterForEvent(LibTG.Name, EVENT_PLAYER_ACTIVATED,    LibTG.GroupCheck)
end

-- Initialization to EVENT_ADD_ON_LOADED
EVENT_MANAGER:RegisterForEvent(LibTG.Name, EVENT_ADD_ON_LOADED, Initialize)
