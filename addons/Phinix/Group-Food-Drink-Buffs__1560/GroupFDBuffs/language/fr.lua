local GroupFDB = _G['GroupFDB']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- French
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- Panel Strings.
L.GroupFDB_Title			= "Groupe Food & Drink Buffs"
L.GroupFDB_GOpts			= "Options globales"
L.GroupFDB_SGF				= "Surveiller cadres de groupe"
L.GroupFDB_SGFD				= "Affichez les icônes de nourriture ou de boisson sur les cadres des unités de groupe."
L.GroupFDB_SRF				= "Surveiller cadres de raid"
L.GroupFDB_SRFD				= "Affichez les icônes de nourriture ou de boisson sur les cadres des unités de raid."
L.GroupFDB_SAB				= "Afficher l'indicateur d'effet actif"
L.GroupFDB_SABD				= "Montrez l'icône de la nourriture ou de la boisson active sur les cadres de groupe et de raid."
L.GroupFDB_SJB				= "Afficher indicateur de l'effet indésirable"
L.GroupFDB_SJBD				= "Afficher l'icône de la nourriture d'ordure active ou verre sur les cadres du groupe et du raid."
L.GroupFDB_SNB				= "Afficher l'indicateur d'effet manquant"
L.GroupFDB_SNBD				= "Montrez une icône rouge sur les cadres de groupe et de raid lorsqu'un membre n'a pas de nourriture ou de boisson active."
L.GroupFDB_GMode			= "Mode buff de groupe"
L.GroupFDB_GModeD			= "Sélectionnez le module de support pour les cadres de groupe que vous utilisez actuellement. Par défaut sont les cadres normaux du jeu."
L.GroupFDB_RMode			= "Mode Raid Buff"
L.GroupFDB_RModeD			= "Sélectionnez le module de support pour les cadres d'unité RAID que vous utilisez actuellement. Par défaut sont les cadres normaux du jeu."
L.GroupFDB_GIS				= "Taille de l'icône de groupe"
L.GroupFDB_GISD				= "Taille de l'icône de nourriture ou de boisson affichée sur les cadres de groupe standard, comme un multiple de 8 pixels."
L.GroupFDB_RIS				= "Taille de l'icône Raid"
L.GroupFDB_RISD				= "Taille de l'icône de nourriture ou de boisson affichée sur les cadres de raid standard, comme un multiple de 8 pixels."
L.GroupFDB_GXIO				= "Décalage d'icônes horizontal de groupe"
L.GroupFDB_GXIOD			= "Règle la position de l'icône de nourriture/boisson du cadre de groupe de gauche à droite."
L.GroupFDB_GYIO				= "Décalage d'icônes verticales de groupe"
L.GroupFDB_GYIOD			= "Règle la position de l’icône aliments/boissons du groupe en haut et en bas."
L.GroupFDB_RXIO				= "Raid Horizontal Icon Offset"
L.GroupFDB_RXIOD			= "Ajuste la position de l'icône de nourriture/boisson du cadre de raid de gauche à droite."
L.GroupFDB_RYIO				= "Décalage d'icônes verticales de raid"
L.GroupFDB_RYIOD			= "Règle la position de l'icône de nourriture/boisson du cadre de raid de haut en bas"

-- Group frame support options
L.GroupFDB_Mode1			= "Défaut"
--L.GroupFDB_Mode2			= "Foundry Tactical Combat"
--L.GroupFDB_Mode3			= "Lui Extended"
--L.GroupFDB_Mode4			= "Bandits User Interface"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'fr') then -- overwrite GetLanguage for new language
	for k,v in pairs(GroupFDB:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function GroupFDB:GetLanguage() -- set new language return
		return L
	end
end
