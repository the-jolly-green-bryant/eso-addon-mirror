local SHR_localization  = {
 SHR_mod_name = "StoreHelperRune"
,SHR_display_name = "Store Helper Rune"

,SHR_purchased_msg      = "SHR: куплен %u %s"								-- ie purchased 5 Jora
,SHR_buy_reduced_msg    = "SHR: уменьшение покупки %s с %u до %u — проверьте золото"
,SHR_load_not_accepted  = "SHR: StoreHelper не загрузил функции SHR"
,SHR_add_for_store_desc = "покупайте руны силы, используемые в базовых записях, когда это необходимо."	-- SH will show this when adding SHRune

,SHR_OptMenu_header_name = "Store Helper Rune Параметры"
,SHR_OptMenu_description = "Сохраняйте минимальное количество рун силы для основных заказов.\nУчитываются только сумки для рукоделия, банк и текущий инвентарь мультяшек."
,SHR_OptMenu_chk_UseToon_name	  = "Использовать настройки персонажа"
,SHR_OptMenu_chk_UseToon_tooltip  = "используйте настройки для этого мультяшка вместо настроек учетной записи по умолчанию"

,SHR_OptMenu_box_genRune_tooltip  = "минута на складе: 0-50 (использовать коробку для >50)"


-- these are only used for display purposes
,SHR_OptMenu_craft_block_description = "Дополнительные руны, необходимые для создания глифов для заказов."
,SHR_opt_Jora	= "Jora"
,SHR_opt_Jera	= "Jera"
,SHR_opt_Odra	= "Odra"
,SHR_opt_Edora	= "Edora"
,SHR_opt_Pora	= "Pora"
,SHR_opt_Rera	= "Rera"
,SHR_opt_Derado	= "Derado"
,SHR_opt_Rekura	= "Rekura"
,SHR_opt_Kura	= "Kura"
,SHR_opt_Rejera	= "Rejera"

--[[ not used in basic writs
,SHR_opt_Porade	= "Porade"		L1 inferior
,SHR_opt_Jejora	= "Jejora"		L2 slight
,SHR_opt_Pojora	= "Pojora"		L3 lesser
,SHR_opt_Jaera	= "Jaera"		L4 average
,SHR_opt_Denara	= "Denara"		L5 major
]]

,SHR_OptMenu_handin_description = "Субтрактивные руны, необходимые для сдачи в приказах"
,SHR_opt_Jode	= "Jode"
,SHR_opt_Ode	= "Ode"
,SHR_opt_Jayde	= "Jayde"
,SHR_opt_Pojode	= "Pojode"
,SHR_opt_Idode	= "Idode"
,SHR_opt_Kedeko	= "Kedeko"
,SHR_opt_Rede	= "Rede"
,SHR_opt_Jehade	= "Jehade"

-- these must match the internal store table name for language
-- go to a store that sells runes and use /shr_storedump to get names
-- do NOT change name from dump value, not even capitalization
-- stables can persist even across /reloadui but many stores clear on close
,SHR_store_Jora		= "Jora"
,SHR_store_Jera		= "Jera"
,SHR_store_Odra		= "Odra"
,SHR_store_Edora	= "Edora"
,SHR_store_Pora		= "Pora"
,SHR_store_Rera		= "Rera"
,SHR_store_Derado	= "Derado"
,SHR_store_Rekura	= "Rekura"
,SHR_store_Kura		= "Kura"
,SHR_store_Rejera	= "Rejera"

,SHR_store_Jode		= "Jode"
,SHR_store_Ode		= "Ode"
,SHR_store_Jayde	= "Jayde"
,SHR_store_Pojode	= "Pojode"
,SHR_store_Idode	= "Idode"
,SHR_store_Kedeko	= "Kedeko"
,SHR_store_Rede		= "Rede"
,SHR_store_Jehade	= "Jehade"





-- we might be able to get these using
-- local link = ('|H1:item:%u:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h'):format(id)
-- local name = GetItemLinkName(link)
-- and passing in the itemID_Jora fields

}

-- loaded SHR main LUA first instead of second
-- quick store local into SHR for use
ZO_ShallowTableCopy(SHR_localization, StoreHelperRune.localization)

-- do NOT try to set pointer directly, for some reason it will clear addon
-- StoreHelperRune.localization = SHR_localization

