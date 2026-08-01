------------------------------------------------
-- French localization for IsJustaGamepadInventory
------------------------------------------------
local strings = {
	--	SI_IJA_GPINVENTORY_Title = "|cFF00FFIsJusta|r |cffffffMenu Manette Optimisé|r"
	 
		SI_IJA_GPINVENTORY_CATEGORIES_HEADER            = "Catégories ordonnées",
		SI_IJA_GPINVENTORY_CATEGORIE_OPTIONS            = "Options des catégories",
		SI_IJA_GPINVENTORY_BANK_OPTIONS                 = "Option de tri pour la banque",
	 
		SI_IJA_GPINVENTORY_SORTBANK_WITHDRAW            = "Retrait à la banque",
		SI_IJA_GPINVENTORY_SORTBANK_WITHDRAW_TOOLTIP    = "Activé: Place les éléments de la catégorie \"Camelote\" à la fin de la liste de dépot de la banque.",
	 
		SI_IJA_GPINVENTORY_SORTBANK_DEPOSIT             = "Dépot à la banque",
		SI_IJA_GPINVENTORY_SORTBANK_DEPOSIT_TOOLTIP     = "Activé: Place les éléments de la catégorie \"Camelote\" à la fin de la liste de retrait de la banque.",
}

for stringId, stringValue in pairs(strings) do
	SafeAddString(stringId, stringValue)
end

IJA_GPINVENTORY_LOCALIZEDSTRINGS.useCategory 		= "Utiliser la catégorie <<1>>"
IJA_GPINVENTORY_LOCALIZEDSTRINGS.useCategoryTooltip = "Activé: ajoute une catégorie dynamique pour <<1>>."

local tooltips = {}
tooltips.container		= "Sélection du container"
tooltips.junk			= "Objets marqués comme Camelote"
tooltips.repairKits		= "Kits de réparation"
tooltips.siege			= "Objets Guerre d'alliances"
tooltips.stolen			= "Objets volés"
tooltips.treasures		= "Trésors \"Vendre à un vendeur\""
tooltips.writs			= "Commandes d'artisanat"

local localizedStrings = {
	[ITEMFILTERTYPE_CONTAINER] = {
		tooltip = tooltips.container:lower()
	},
	[ITEMFILTERTYPE_FOOD_DRINK] = {
	},
	[ITEMFILTERTYPE_JUNK] = {
		tooltip = tooltips.junk:lower()
	},
	[ITEMFILTERTYPE_MAPS] = {
	},
	[ITEMFILTERTYPE_POTION] = {
	},
	[ITEMFILTERTYPE_RECIPE_STYLE_PAGE] = {
	},
	[ITEMFILTERTYPE_REPAIR] = {
		tooltip = tooltips.repairKits:lower()
	},
	[ITEMFILTERTYPE_SIEGE] = {
		tooltip = tooltips.siege:lower()
	},
	[ITEMFILTERTYPE_STOLEN] = {
		tooltip = tooltips.stolen:lower()
	},
	[ITEMFILTERTYPE_TREASURE] = {
		tooltip = tooltips.treasures:lower()
	},
	[ITEMFILTERTYPE_WRIT] = {
		tooltip = tooltips.writs:lower()
	},
	[ITEMFILTERTYPE_FRAGMENT] = {
	},
}

for itemFilterType, info in pairs(localizedStrings) do
	if info.category then
		IJA_GPINVENTORY_LOCALIZEDSTRINGS[itemFilterType].category = info.category
	end	
	if info.tooltip then
		IJA_GPINVENTORY_LOCALIZEDSTRINGS[itemFilterType].tooltip =  info.tooltip
	end
end