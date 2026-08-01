local PAC = PersonalAssistant.Constants
local PAWStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAWorker Menu --
    SI_PA_MENU_WORKER_DESCRIPTION = "PAWorkerは、アイテムの解体、素材の精製、および特性の研究を自動的に行うことができます",
	
    SI_PA_MENU_WORKER_METICULOUS_ENABLE = "「入念な分解」のチェック",
    SI_PA_MENU_WORKER_METICULOUS_ENABLE_T = "「入念な分解」のチャンピオンシステム・パッシブがスロットされていない場合、自動解体と精製を行わないようにします",
    SI_PA_MENU_WORKER_CHECK_EXTRACTION_ENABLE = "「抽出」パッシブのチェック",
    SI_PA_MENU_WORKER_CHECK_EXTRACTION_ENABLE_T = "対応するクラフトスキルの「抽出」パッシブが最大ランクに達していない場合、自動解体と精製を行わないようにします",

    -- auto refine --
    SI_PA_MENU_WORKER_AUTOREFINE_HEADER = "素材の自動精製",
    SI_PA_MENU_WORKER_AUTOREFINE_ENABLE = "素材の自動精製を有効にする",
    SI_PA_MENU_WORKER_AUTOREFINE_ENABLE_T = "クラフト素材を自動的に精製します",
	
    -- auto Deconstruct --
    SI_PA_MENU_WORKER_AUTODECONSTRUCT_HEADER = "アイテムの自動解体",
    SI_PA_MENU_WORKER_AUTODECONSTRUCT_ENABLE = "アイテムの自動解体を有効にする",
    SI_PA_MENU_WORKER_AUTODECONSTRUCT_ENABLE_T = "アイテムを自動的に解体します",
	
    SI_PA_MENU_WORKER_PROTECT_BANK_ENABLE = "銀行保管アイテムの保護",
    SI_PA_MENU_WORKER_PROTECT_BANK_ENABLE_T = "銀行に預けられているアイテムが自動解体されないよう二重に保護します",
	
    SI_PA_MENU_WORKER_PROTECT_UNCOLLECTED_SET_ITEMS_ENABLE = "未登録セットアイテムの保護",
    SI_PA_MENU_WORKER_PROTECT_UNCOLLECTED_SET_ITEMS_ENABLE_T = "セットコレクションに登録されていないセットアイテムを自動解体から保護します",
	
    -- auto research trait --
    SI_PA_MENU_WORKER_AUTORESEARCHTRAITS_HEADER = "特性の自動研究",
    SI_PA_MENU_WORKER_AUTORESEARCHTRAITS_ENABLE = "特性の自動研究を有効にする",
    SI_PA_MENU_WORKER_AUTORESEARCHTRAITS_ENABLE_T = "未研究の特性を自動的に研究します",
	
    -- General texts used across: Weapons, Armor, Jewelry
    SI_PA_MENU_WORKER_AUTOMARK_QUALITY_THRESHOLD = "設定以下の品質の %s を自動解体",
    SI_PA_MENU_WORKER_AUTOMARK_QUALITY_THRESHOLD_T = "選択した品質、またはそれ以下の品質の %s を自動的に解体します",
    SI_PA_MENU_WORKER_AUTOMARK_INTRICATE = table.concat({"[", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE), "] 特性を持つ %s を自動解体"}),
    SI_PA_MENU_WORKER_AUTOMARK_INTRICATE_T = table.concat({"[", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE), "] 特性（生産のインスピレーション増加）を持つ %s を自動的に解体しますか？"}),
    SI_PA_MENU_WORKER_AUTOMARK_ORNATE = table.concat({"[", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE), "] 特性を持つ %s を自動解体"}),
    SI_PA_MENU_WORKER_AUTOMARK_ORNATE_T = table.concat({"[", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE), "] 特性（売却価格増加）を持つ %s を自動的に解体しますか？"}),
    SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_SETS = "セットの一部である %s も解体する",
    SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_SETS_T = "オフに設定されている場合、セットに属して「いない」 %s のみが自動解体の対象になります",
    SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_KNOWN_TRAITS = "研究済みの特性を持つ %s も解体する",
    SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_KNOWN_TRAITS_T = "オフに設定されている場合、特性なし、または未研究の特性を持つ %s のみが自動解体の対象になります",
    SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_UNKNOWN_TRAITS = "未研究の特性を持つ %s も解体する",
    SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_UNKNOWN_TRAITS_T = "オフに設定されている場合、特性なし、または研究済みの特性を持つ %s のみが自動解体の対象になります",



    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAWorker deconstruct--
    SI_PA_CHAT_ITEM_DECONSTRUCTED = "%s を解体しました",
    SI_PA_CHAT_ALREADY_GOT_ITEM_WITH_TRAIT = "研究可能な特性を持つ別の %s がすでに存在するため、この %s を解体します",
    SI_PA_CHAT_ITEM_REFINED = "%s を精製しました",
    SI_PA_CHAT_ITEM_RESEARCHED = "%s を使用して、%s の %s (%s) 特性の研究を開始しました",
    SI_PA_CHAT_RESEARCH_FULL = "研究枠が上限 (%s/%s) に達しているため、%s の %s 特性を研究できませんでした",
    SI_PA_CHAT_RESEARCH_BUSY = "すでに %s に関する別の特性を研究中であるため、%s 特性を研究できませんでした",
    SI_PA_CHAT_NO_METICULOUS = "「入念な分解」パッシブがスロットされていないため、自動解体および精製がブロックされました",
    SI_PA_CHAT_NO_EXTRACTION = "「%s」パッシブが最大ランクではないため、自動解体および精製がブロックされました",
    SI_PA_CHAT_NO_EXTRACTION_FOR_ITEM = "「%s」パッシブが最大ランクではないため、%s の自動解体を行いませんでした",
    SI_PA_CHAT_CRAFTING_QUEST = "進行中のデイリークラフト依頼（%s）があるため、自動解体、精製、および研究が保留されました",

}

for key, value in pairs(PAWStrings) do
    SafeAddString(_G[key], value, 1)
end


local PAWGenericStrings = {
    -- =================================================================================================================
    -- Language independent texts (do not need to be translated/copied to other languages --

    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    --SI_PA_CHAT_Consume_CHARGE_WEAPON = "%s (%d%% --> %d%%) - %s",
}

for key, value in pairs(PAWGenericStrings) do
    SafeAddString(_G[key], value, 1)
end