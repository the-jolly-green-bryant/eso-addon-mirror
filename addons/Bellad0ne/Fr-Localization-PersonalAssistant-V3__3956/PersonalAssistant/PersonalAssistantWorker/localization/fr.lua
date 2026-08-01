local PAC = PersonalAssistant.Constants
local PAWStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
	-- PAWorker Menu --
	SI_PA_MENU_WORKER_DESCRIPTION = "PAWorker peut déconstruire des objets ou raffiner des matériaux automatiquement",

	SI_PA_MENU_WORKER_METICULOUS_ENABLE = "Vérification méticuleuse de la déconstruction",
	SI_PA_MENU_WORKER_METICULOUS_ENABLE_T = "Empêche la déconstruction/raffinage si la déconstruction méticuleuse n'est pas équipée",
	SI_PA_MENU_WORKER_CHECK_EXTRACTION_ENABLE = "Vérification du passif d'extraction",
	SI_PA_MENU_WORKER_CHECK_EXTRACTION_ENABLE_T = "Empêche la déconstruction/raffinage si le passif d'extraction correspondant à la compétence d'artisanat n'est pas maximisé",

	-- auto refine --
	SI_PA_MENU_WORKER_AUTOREFINE_HEADER = "Raffiner les matériaux automatiquement",
	SI_PA_MENU_WORKER_AUTOREFINE_ENABLE = "Activer le raffinage automatique des matériaux",
	SI_PA_MENU_WORKER_AUTOREFINE_ENABLE_T = "Raffiner automatiquement les matériaux",

	-- auto Deconstruct --
	SI_PA_MENU_WORKER_AUTODECONSTRUCT_HEADER = "Déconstruire les objets automatiquement",
	SI_PA_MENU_WORKER_AUTODECONSTRUCT_ENABLE = "Activer la déconstruction automatique des objets",
	SI_PA_MENU_WORKER_AUTODECONSTRUCT_ENABLE_T = "Déconstruire automatiquement les objets",

	SI_PA_MENU_WORKER_PROTECT_BANK_ENABLE = "Protéger les objets en banque",
	SI_PA_MENU_WORKER_PROTECT_BANK_ENABLE_T = "2e protection pour les objets en banque",

	-- auto research trait --
	SI_PA_MENU_WORKER_AUTORESEARCHTRAITS_HEADER = "Recherche automatique des traits",
	SI_PA_MENU_WORKER_AUTORESEARCHTRAITS_ENABLE = "Activer la recherche automatique des traits",
	SI_PA_MENU_WORKER_AUTORESEARCHTRAITS_ENABLE_T = "Recherche automatique des traits",

	-- General texts used across: Weapons, Armor, Jewelry
	SI_PA_MENU_WORKER_AUTOMARK_QUALITY_THRESHOLD = "%s avec une qualité égale ou inférieure à",
	SI_PA_MENU_WORKER_AUTOMARK_QUALITY_THRESHOLD_T = "Déconstruire les %s de qualité sélectionnée ou inférieure",
	SI_PA_MENU_WORKER_AUTOMARK_INTRICATE = table.concat({"Déconstruire les %s avec le trait [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE), "]"}),
	SI_PA_MENU_WORKER_AUTOMARK_INTRICATE_T = table.concat({"Déconstruire les %s avec le trait [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE), "] (Inspiration accrue) ?"}),
	SI_PA_MENU_WORKER_AUTOMARK_ORNATE = table.concat({"Déconstruire les %s avec le trait [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE), "]"}),
	SI_PA_MENU_WORKER_AUTOMARK_ORNATE_T = table.concat({"Déconstruire les %s avec le trait [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE), "] (Prix de vente augmenté) ?"}),
	SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_SETS = "Déconstruire les %s faisant partie d'un ensemble",
	SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_SETS_T = "Si désactivé, seuls les %s ne faisant PAS partie d'un ensemble seront déconstruits",
	SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_KNOWN_TRAITS = "Déconstruire les %s avec des traits connus",
	SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_KNOWN_TRAITS_T = "Si désactivé, seuls les %s sans traits ou avec des traits inconnus seront déconstruits",
	SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_UNKNOWN_TRAITS = "Déconstruire les %s avec des traits inconnus",
	SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_UNKNOWN_TRAITS_T = "Si désactivé, seuls les %s sans traits ou avec des traits connus seront déconstruits",

    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAWorker deconstruct--
	SI_PA_CHAT_ITEM_DECONSTRUCTED = "%s a été déconstruit",
	SI_PA_CHAT_ITEM_REFINED = "%s a été raffiné",
	SI_PA_CHAT_ITEM_RESEARCHED = "%s a été utilisé pour rechercher le trait %s (%s) pour %s",
	SI_PA_CHAT_RESEARCH_FULL = "Impossible de rechercher le trait %s pour %s car %s/%s emplacements de recherche sont occupés",
	SI_PA_CHAT_NO_METICULOUS = "La déconstruction/raffinage automatique est bloquée car la déconstruction méticuleuse n'est pas équipée",
	SI_PA_CHAT_NO_EXTRACTION = "La déconstruction/raffinage automatique est bloquée car %s n'est pas maximisé",
	SI_PA_CHAT_NO_EXTRACTION_FOR_ITEM = "%s n'est pas maximisé, donc %s n'a pas été déconstruit automatiquement",
	SI_PA_CHAT_CRAFTING_QUEST = "La déconstruction/raffinage/recherche automatique est bloquée car vous avez une quête d'artisanat en cours",

}

for key, value in pairs(PAWStrings) do
    SafeAddString(_G[key], value, 1)
end

