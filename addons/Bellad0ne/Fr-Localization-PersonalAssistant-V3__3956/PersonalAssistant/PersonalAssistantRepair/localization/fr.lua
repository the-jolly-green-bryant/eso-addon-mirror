local PAC = PersonalAssistant.Constants
local PARStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PARepair Menu --
    SI_PA_MENU_REPAIR_DESCRIPTION = "PARepair répare votre armure et recharge vos armes pour vous, à un marchand ou sur le champ de bataille",

    -- Equipped Items --
    SI_PA_MENU_REPAIR_EQUIPPED_HEADER = "Objets équipés",
    SI_PA_MENU_REPAIR_ENABLE = "Activer la réparation auto pour les objets équipés",

    SI_PA_MENU_REPAIR_GOLD_HEADER = table.concat({"Réparer avec de l'", GetCurrencyName(CURT_MONEY)}),
    SI_PA_MENU_REPAIR_GOLD_ENABLE = table.concat({"Réparer les objets équipés avec de l'or ?"}),
    SI_PA_MENU_REPAIR_GOLD_ENABLE_T = "En visitant un marchand, tous les objets équipés en dessous du seuil de durabilité défini seront automatiquement réparés",
    SI_PA_MENU_REPAIR_GOLD_DURABILITY = "Seuil de durabilité en %",
    SI_PA_MENU_REPAIR_GOLD_DURABILITY_T = "Réparer les objets équipés seulement s'ils sont en-dessous du seuil de durabilité",

    SI_PA_MENU_REPAIR_REPAIRKIT_HEADER = table.concat({"Réparer avec des ", GetString(SI_PA_MENU_BANKING_REPAIRKIT)}),
    SI_PA_MENU_REPAIR_REPAIRKIT_ENABLE = table.concat({"Réparer les objets équipés avec des nécessaires"}), -- GetString(SI_PA_MENU_BANKING_REPAIRKIT), " ?"}), -- It was too long
    SI_PA_MENU_REPAIR_REPAIRKIT_ENABLE_T = "Sur le champ de bataille, tous les objets équipés en dessous du seuil de durabilité défini seront automatiquement réparés",
	SI_PA_MENU_REPAIR_REPAIRKIT_DEFAULT_KIT = "Kit de réparation par défaut",
	SI_PA_MENU_REPAIR_REPAIRKIT_DEFAULT_KIT_T = "Votre kit de réparation par défaut sera utilisé en premier lors de la réparation des objets",
	SI_PA_MENU_REPAIR_REPAIRKIT_GROUP = "Utiliser les kits de réparation de groupe",
	SI_PA_MENU_REPAIR_REPAIRKIT_GROUP_T = "Les kits de réparation de groupe seront utilisés en premier lors de la réparation des objets lorsque vous êtes en groupe",
    SI_PA_MENU_REPAIR_REPAIRKIT_DURABILITY = "Seuil de durabilité en %",
    SI_PA_MENU_REPAIR_REPAIRKIT_DURABILITY_T = "Réparer les objets équipés seulement s'ils sont en-dessous du seuil de durabilité",
    SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_WARNING = "Avertir sur quantité restante faible",-- table.concat({"Avertir quand il reste peu de ", GetString(SI_PA_MENU_BANKING_REPAIRKIT)}), -- It was too long
    SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_WARNING_T = table.concat({"Afficher un avertissement dans la fenêtre de chat s'il vous reste peu de ", GetString(SI_PA_MENU_BANKING_REPAIRKIT), ". Si vous n'en avez plus du tout, un rappel sera affiché au maximum toutes les 10 minutes."}),
    SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_THRESHOLD = "    Seuil de “quantité faible”", -- spaces in the beginning are needed as otherwise the options are too close to each other
    SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_THRESHOLD_T = table.concat({"Si la quantité restante de ", GetString(SI_PA_MENU_BANKING_REPAIRKIT), " est en dessous du seuil, un message sera affiché dans la fenêtre de chat"}),

    SI_PA_MENU_REPAIR_RECHARGE_HEADER = table.concat({"Recharger les armes avec des ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2)}),
    SI_PA_MENU_REPAIR_RECHARGE_ENABLE = table.concat({"Recharger les armes avec des pierres d'âme ?"}),
    SI_PA_MENU_REPAIR_RECHARGE_ENABLE_T = "Recharge les armes équipées quand elles sont complétement déchargées. Cela utilisera par défaut les Pierres d'âme sélectionnées ci-dessous.",
    SI_PA_MENU_REPAIR_RECHARGE_DEFAULT_GEM = "Pierre d'âme par défaut",
    SI_PA_MENU_REPAIR_RECHARGE_DEFAULT_GEM_T = "Vos pierres d'âme par défaut seront les premières utilisées pour recharger les armes.",
    SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_WARNING = "Avertir si la quantité restante est faible", -- table.concat({"Avertir quand peu de ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2)}),
    SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_WARNING_T = table.concat({"Afficher un avertissement dans la fenêtre de chat s'il vous reste peu de ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2), ". Si vous n'en avez plus du tout, un rappel sera affiché au maximum toutes les 10 minutes."}),
    SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_THRESHOLD = "    Seuil de “quantité faible”", -- spaces in the beginning are needed as otherwise the options are too close to each other
    SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_THRESHOLD_T = table.concat({"Si la quantité restante de ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2), " est en dessous du seuil, un message sera affiché dans la fenêtre de chat"}),

    -- Inventory Items --
    SI_PA_MENU_REPAIR_INVENTORY_HEADER = "Objets dans l'inventaire",
    SI_PA_MENU_REPAIR_INVENTORY_ENABLE = "Réparer automatiquement les objets dans l'inventaire",

    SI_PA_MENU_REPAIR_GOLD_INVENTORY_ENABLE = "Réparer les objets dans l'inventaire avec de l'or ?",
    SI_PA_MENU_REPAIR_GOLD_INVENTORY_ENABLE_T = "En visitant un marchand, tous les objets dans l'inventaire en dessous du seuil de durabilité défini seront automatiquement réparés",
    SI_PA_MENU_REPAIR_GOLD_INVENTORY_DURABILITY = "Seuil de durabilité en %",
    SI_PA_MENU_REPAIR_GOLD_INVENTORY_DURABILITY_T = "Réparer les objets dans l'inventaire seulement s'ils sont en-dessous du seuil de durabilité",

	-- Buy repair kits --
	SI_PA_MENU_BUY_REPAIR_KITS_HEADER = "Acheter des kits de réparation",
	SI_PA_MENU_BUY_REPAIR_KITS_ENABLE = "Activer l'achat automatique de kits de réparation",
    
	-- Dynamic Buy item menus --
	SI_PA_MENU_BUY_ITEM_HEADER = "Acheter %s",
	SI_PA_MENU_BUY_ITEM_ENABLE = "Acheter automatiquement %s ?",
	SI_PA_MENU_BUY_ITEM_ENABLE_T = "Lors de la visite d'un marchand, les %s manquants seront achetés automatiquement",
	SI_PA_MENU_BUY_ITEM_THRESHOLD = "Seuil d'inventaire de %s",
	SI_PA_MENU_BUY_ITEM_THRESHOLD_T = "Lorsque votre quantité de %s est inférieure à ce seuil, la quantité manquante sera achetée",
	SI_PA_MENU_BUY_ITEM_PRIORITY = "Priorité de la devise pour %s",
	SI_PA_MENU_BUY_ITEM_PRIORITY_T = "Sélectionnez quelle devise sera utilisée en premier pour essayer d'acheter %s",
    
	-- Buy Soul Gems --
	SI_PA_MENU_BUY_SOUL_GEMS_HEADER = "Acheter des gemmes d'âme et des crochets",
	SI_PA_MENU_BUY_SOUL_GEMS_ENABLE = "Activer l'achat automatique de gemmes d'âme et de crochets",
    
	-- Buy Siege Items --
	SI_PA_MENU_BUY_SIEGE_ITEMS_HEADER = "Acheter "..GetString(SI_ITEMTYPEDISPLAYCATEGORY32),
	SI_PA_MENU_BUY_SIEGE_ITEMS_ENABLE = "Activer l'achat automatique de "..GetString(SI_ITEMTYPEDISPLAYCATEGORY32),
	
    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PARepair --
    SI_PA_CHAT_REPAIR_SUMMARY_FULL = "Réparation des objets équipés effectuée pour %s",
    SI_PA_CHAT_REPAIR_SUMMARY_PARTIAL = "Réparation des objets équipés effectuée pour %s (%s manquant)",

    SI_PA_CHAT_REPAIR_SUMMARY_INVENTORY_FULL = "Réparation des objets dans l'inventaire effectuée pour %s",
    SI_PA_CHAT_REPAIR_SUMMARY_INVENTORY_PARTIAL = "Réparation des objets dans l'inventaire effectuée pour %s (%s manquant)",

    SI_PA_CHAT_REPAIR_REPAIRKIT_REPAIRED = table.concat({"Réparation de %s ", PAC.COLORS.WHITE, "(%d%%)", PAC.COLORS.DEFAULT, " effectuée avec %s"}),
    SI_PA_CHAT_REPAIR_REPAIRKIT_REPAIRED_ALL = table.concat({"Réparation de %s ", PAC.COLORS.WHITE, "(%d%%)", PAC.COLORS.DEFAULT, " et tous les autres objets avec %s"}),
	
	SI_PA_CHAT_BUY_SUMMARY_BOUGHT = "Acheté %s x %s pour %s",
	SI_PA_CHAT_BUY_SUMMARY_MISSING = "Impossible d'acheter %s pour %s (%s manquant)",
	
}

for key, value in pairs(PARStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end
