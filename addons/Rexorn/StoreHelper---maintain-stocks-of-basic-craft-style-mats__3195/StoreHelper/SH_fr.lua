local SH_localization  = {
 SH_mod_name = "StoreHelper"
,SH_display_name = "Store Helper"

,SH_bought_mats_msg     = "SH: acheté %u %s"										-- ie purchased 5 Flint
,SH_buy_reduced_msg     = "SH: réduire l'achat de %s de %u à %u - vérifier l'or"
,SH_PA_integration_msg  = "SH: PAJunk/Repair trouvé. SH va faire une pause 0,2s."


,SH_OptMenu_header_name = "Store Helper Options"
,SH_OptMenu_description = "Gardez un nombre minimum de tapis de style artisanal à portée de main. Tous les types achètent un tapis racial de toon pour s'assurer que l'achat de toon peut utiliser un tapis.\nCompte uniquement le sac d'artisanat, la banque et l'inventaire actuel des toons."
,SH_OptMenu_chk_UseToon_name	 = "Utiliser les paramètres du personnage"
,SH_OptMenu_chk_UseToon_tooltip  = "utiliser les paramètres de ce personnage au lieu des valeurs par défaut du compte"
,SH_OptMenu_chk_buy2chat_name    = "Acheter un message pour discuter"
,SH_OptMenu_chk_buy2chat_tooltip = "afficher les messages d'achat dans le chat"
,SH_OptMenu_AllTypes_name	 	 = "tous types de matériaux"
,SH_OptMenu_AllTypes_tooltip 	 = "si, après des achats de tapis spécifiques, le total des tapis < cela achète plus : 0-250\nIgnore le nickel sauf pour les caractères impériaux avec Ovr=Nickel."
,SH_OptMenu_AllTypes_desc		 = "Ce personnage achètera %s pour atteindre l'objectif Tous types."
,SH_OptMenu_ShowPA_AddFunc_name  = "Afficher les messages pour les autres interactions du modérateur"
,SH_OptMenu_ShowPA_AddFunc_tooltip = "Message si un délai est ajouté pour PersonalAssistant ou d'autres modules complémentaires, ajoutez des fonctions de magasin"

-- racial style mat names generated in main code using system calls -> no SH_OptMenu_*_name strings
,SH_OptMenu_box_genMat_tooltip	  = "min à garder en stock: 0-250 (utiliser la boîte pour> 250)"

,SH_OptMenu_Nickel_note = "          Compté uniquement pour la décision AllTypes si Impérial avec remplacement défini sur Nickel." 
,SH_OptMenu_Imp_override_name = "Imperial Race Tous les types de tapis Acheter Override" 
,SH_OptMenu_Imp_override_tooltip = "Le motif impérial est rare/cher, peu de personnages connaîtront le style.\nPour éviter d'acheter des tapis à usage limité, AllTypes acheter l'utilisera pour les impériaux afin de permettre le choix du tapis d'achat.\nN'impacte PAS la cible d'achat spécifique au nickel."
,SH_OptMenu_Imp_override_desc = "          N'a d'effet que sur les personnages impériaux."

,SH_err_add_for_store_no_addon_name = "SH: un autre addon a demandé à SH de gérer une fonction de stockage sans fournir le nom de l'addon"
,SH_err_add_for_store_no_func_desc  = "SH: %s a demandé à SH de gérer une fonction de stockage sans description pour l'avis de chargement"
,SH_err_add_for_store_not_func      = "SH: %s a demandé à SH de gérer une fonction de stockage mais n'a pas passé de fonction (%s)"
,SH_err_add_for_store_already_added = "SH: %s a demandé à SH d'ajouter (%s) qui était déjà inclus"
,SH_accepted_func	                = "SH: fonction d'achat acceptée %s(%s)"
		-- SH: accepted shopping function Bob(buy rune stones)

,SH_err_remove_func_no_addon_name	= "SH: un autre addon a demandé la suppression d'une fonction sans fournir le nom de l'addon"
,SH_err_remove_func_no_func_desc	= "SH: %s a demandé à SH de supprimer une fonction de stockage sans clé de description"
,SH_err_remove_func_not_func		= "SH: %s a demandé à SH de supprimer une fonction de stockage mais n'a pas passé de fonction"
,SH_err_remove_func_not_found		= "SH: %s a demandé à SH de supprimer (%s) mais la fonction n'a jamais été ajoutée ou déjà supprimée"
,SH_removed_func					= "SH: fonction d'achat supprimée %s(%s)"
,SH_cannot_find_alltypes_matID		= "SH: erreur fatale impossible de trouver alltypes_matID"

,SH_debug_msg_off = "SH: messages de débogage désactivés"
,SH_debug_msg_on  = "SH: messages de débogage sur"
,SH_debug_show_ap_entries        = "SH: le magasin prend des entrées de points d'alliance %u"
,SH_debug_show_gold_entries      = "SH: le magasin prend des entrées d'or %u"
,SH_debug_show_gold_only_entries = "SH: le magasin n'accepte que les entrées d'or %u"
,SH_debug_show_telvar_entries    = "SH: le magasin prend des entrées telvar %u"


-- if a new race is added define SH_style_*, SH_mat_* here
-- if you need a custom language not included by ZOS set SH_load_ZOS_names to false & fill in values
-- SH_style_* is just a display name
,SH_load_ZOS_names	= true
,SH_style_breton	= "custom style name"
,SH_style_redguard	= "custom style name"
,SH_style_orc		= "custom style name"
,SH_style_darkelf	= "custom style name"
,SH_style_nord		= "custom style name"
,SH_style_argonian	= "custom style name"
,SH_style_highelf	= "custom style name"
,SH_style_woodelf	= "custom style name"
,SH_style_khajiit	= "custom style name"
,SH_style_imperial	= "custom style name"

-- SH_mat_* is used for item matching in store entries.
-- custom mat name MUST match the name from GetStoreEntryInfo() not the formated name shown on the screen
,SH_mat_breton		= "custom mat name"
,SH_mat_redguard	= "custom mat name"
,SH_mat_orc			= "custom mat name"
,SH_mat_darkelf		= "custom mat name"
,SH_mat_nord		= "custom mat name"
,SH_mat_argonian	= "custom mat name"
,SH_mat_highelf		= "custom mat name"
,SH_mat_woodelf		= "custom mat name"
,SH_mat_khajiit		= "custom mat name"
,SH_mat_imperial	= "custom mat name"
-- MUST match the name from GetStoreEntryInfo() - REALLY
}

-- loaded SH main LUA first instead of second
-- quick store local into SH for use
ZO_ShallowTableCopy(SH_localization, StoreHelper.localization)


-- do NOT try to set pointer directly, for some reason it will clear addon
-- StoreHelper.localization = SH_localization

-- another way is copying the strings into the Global table with dup checking
-- probably more overhead than the shallow table copy
--[[ 
for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(StringId, 1)
end

other files use this to find the key on the _G table
for key, value in pairs(strings) do
	SafeAddString(_G[key], value, 1)
end

in code use GetString(xx)
]]
