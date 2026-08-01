local PAC = PersonalAssistant.Constants
local PARStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PARepair Menu --
    SI_PA_MENU_REPAIR_DESCRIPTION = "PARepair & Restockは商人での取引時やフィールド上などで、防具の自動修理や武器の充填（チャージ）を自動的に行い、商人から便利なアイテムを自動で補充することもできます。",

    -- Equipped Items --
    SI_PA_MENU_REPAIR_EQUIPPED_HEADER = "装備中のアイテム",
    SI_PA_MENU_REPAIR_ENABLE = "装備中アイテムの自動修理を有効にする",

    SI_PA_MENU_REPAIR_GOLD_HEADER = table.concat({"修理に使用：", GetCurrencyName(CURT_MONEY)}),
    SI_PA_MENU_REPAIR_GOLD_ENABLE = table.concat({"装備中のアイテムを ", GetCurrencyName(CURT_MONEY), " で修理しますか？"}),
    SI_PA_MENU_REPAIR_GOLD_ENABLE_T = "商人を訪れた際、設定された耐久度のしきい値以下になっている装備中のアイテムをすべて自動的に修理します",
    SI_PA_MENU_REPAIR_GOLD_DURABILITY = "耐久度のしきい値（%）",
    SI_PA_MENU_REPAIR_GOLD_DURABILITY_T = "装備中のアイテムの耐久度が、設定されたしきい値以下である場合のみ修理します",

    SI_PA_MENU_REPAIR_REPAIRKIT_HEADER = table.concat({"修理に使用：", GetString(SI_PA_MENU_BANKING_REPAIRKIT)}),
    SI_PA_MENU_REPAIR_REPAIRKIT_ENABLE = table.concat({"装備中のアイテムを ", GetString(SI_PA_MENU_BANKING_REPAIRKIT), " で修理しますか？"}),
    SI_PA_MENU_REPAIR_REPAIRKIT_ENABLE_T = "フィールド上にいる際、設定された耐久度のしきい値以下になっている装備中のアイテムを自動的に修理します",
    SI_PA_MENU_REPAIR_REPAIRKIT_DEFAULT_KIT = "優先して使用する修理キット",
    SI_PA_MENU_REPAIR_REPAIRKIT_DEFAULT_KIT_T = "アイテムを修理する際、ここで設定した優先修理キットが最初に使用されます",
    SI_PA_MENU_REPAIR_REPAIRKIT_GROUP = "グループ修理キットを使用する",
    SI_PA_MENU_REPAIR_REPAIRKIT_GROUP_T = "グループを結成している際、修理を行うとグループ修理キットが優先して使用されます",
    SI_PA_MENU_REPAIR_REPAIRKIT_DURABILITY = "耐久度のしきい値（%）",
    SI_PA_MENU_REPAIR_REPAIRKIT_DURABILITY_T = "装備中のアイテムの耐久度が、設定されたしきい値以下である場合のみ修理します",
    SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_WARNING = table.concat({GetString(SI_PA_MENU_BANKING_REPAIRKIT), "が残り少なくなったら警告する"}),
    SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_WARNING_T = table.concat({GetString(SI_PA_MENU_BANKING_REPAIRKIT), "の残数が少なくなった際にチャット欄に警告を表示します。完全に在庫が切れた場合は、最大で10分に1回警告を行います。"}),
    SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_THRESHOLD = "修理キットのしきい値",
    SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_THRESHOLD_T = table.concat({"残りの ", GetString(SI_PA_MENU_BANKING_REPAIRKIT), " の数がこのしきい値を下回ると、チャット欄にメッセージが表示されます"}),

    SI_PA_MENU_REPAIR_RECHARGE_HEADER = table.concat({"武器の充填に使用：", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2)}),
    SI_PA_MENU_REPAIR_RECHARGE_ENABLE = table.concat({"装備中の武器を ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2), " で自動チャージしますか？"}),
    SI_PA_MENU_REPAIR_RECHARGE_ENABLE_T = "装備中の武器のチャージ量がゼロになった際、自動的に再チャージを行います。まずは以下で優先設定されているソウルジェムが最初に使用されます。",
    SI_PA_MENU_REPAIR_RECHARGE_DEFAULT_GEM = "優先して使用するソウルジェム",
    SI_PA_MENU_REPAIR_RECHARGE_DEFAULT_GEM_T = "武器をチャージする際、ここで設定した優先ソウルジェムが最初に使用されます。",
    SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_WARNING = table.concat({zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2), "が残り少なくなったら警告する"}),
    SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_WARNING_T = table.concat({zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2), "の残数が少なくなった際にチャット欄に警告を表示します。完全に在庫が切れた場合は、最大で10分に1回警告を行います。"}),
    SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_THRESHOLD = table.concat({GetString("SI_ITEMTYPE", ITEMTYPE_SOUL_GEM), "のしきい値"}),
    SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_THRESHOLD_T = table.concat({"残りの ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2), " の数がこのしきい値を下回ると、チャット欄にメッセージが表示されます"}),

    -- Inventory Items --
    SI_PA_MENU_REPAIR_INVENTORY_HEADER = "所持品内のアイテム",
    SI_PA_MENU_REPAIR_INVENTORY_ENABLE = "所持品内アイテムの自動修理を有効にする",

    SI_PA_MENU_REPAIR_GOLD_INVENTORY_ENABLE = table.concat({"所持品内のアイテムを ", GetCurrencyName(CURT_MONEY), " で修理しますか？"}),
    SI_PA_MENU_REPAIR_GOLD_INVENTORY_ENABLE_T = "商人を訪れた際、設定された耐久度のしきい値以下になっている所持品内のアイテムをすべて自動的に修理します",
    SI_PA_MENU_REPAIR_GOLD_INVENTORY_DURABILITY = "耐久度のしきい値（%）",
    SI_PA_MENU_REPAIR_GOLD_INVENTORY_DURABILITY_T = "所持品内のアイテムの耐久度が、設定されたしきい値以下である場合のみ修理します",
	
    -- Buy repair kits --
    SI_PA_MENU_BUY_REPAIR_KITS_HEADER = "修理キットの購入",
    SI_PA_MENU_BUY_REPAIR_KITS_ENABLE = "修理キットの自動購入を有効化",
	
    -- Dynamic Buy item menus --
    SI_PA_MENU_BUY_ITEM_HEADER = "%s の購入",
    SI_PA_MENU_BUY_ITEM_ENABLE = "%s を自動購入しますか？",
    SI_PA_MENU_BUY_ITEM_ENABLE_T = "商人を訪れた際、不足している %s を自動的に購入します",
    SI_PA_MENU_BUY_ITEM_THRESHOLD = "%s の所持しきい値",
    SI_PA_MENU_BUY_ITEM_THRESHOLD_T = "所持している %s の数がこのしきい値を下回った場合、不足分を自動で購入します",
    SI_PA_MENU_BUY_ITEM_PRIORITY = "%s 購入通貨の優先順位",
    SI_PA_MENU_BUY_ITEM_PRIORITY_T = "%s を購入しようとする際に、どの通貨を優先して使用するか選択します",	
	
    -- Buy Soul Gems --
    SI_PA_MENU_BUY_SOUL_GEMS_HEADER = "ソウルジェム＆ロックピックの購入",
    SI_PA_MENU_BUY_SOUL_GEMS_ENABLE = "ソウルジェム＆ロックピックの自動購入を有効化",	
	
    -- Buy Siege Items -- 
    SI_PA_MENU_BUY_SIEGE_ITEMS_HEADER = GetString(SI_ITEMTYPEDISPLAYCATEGORY32) .. "の購入",
    SI_PA_MENU_BUY_SIEGE_ITEMS_ENABLE = "自動購入を有効化：" .. GetString(SI_ITEMTYPEDISPLAYCATEGORY32),
	
	

    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PARepair --
    SI_PA_CHAT_REPAIR_SUMMARY_FULL = "装備中のアイテムを %s で修理しました",
    SI_PA_CHAT_REPAIR_SUMMARY_PARTIAL = "装備中のアイテムを %s で修理しました（%s 不足）",

    SI_PA_CHAT_REPAIR_SUMMARY_INVENTORY_FULL = "所持品内のアイテムを %s で修理しました",
    SI_PA_CHAT_REPAIR_SUMMARY_INVENTORY_PARTIAL = "所持品内のアイテムを %s で修理しました（%s 不足）",

    SI_PA_CHAT_REPAIR_REPAIRKIT_REPAIRED = table.concat({"%s ", PAC.COLORS.WHITE, "(%d%%)", PAC.COLORS.DEFAULT, " を %s で修理しました"}),
    SI_PA_CHAT_REPAIR_REPAIRKIT_REPAIRED_ALL = table.concat({"%s ", PAC.COLORS.WHITE, "(%d%%)", PAC.COLORS.DEFAULT, " およびその他すべてのアイテムを %s で修理しました"}),
	
    SI_PA_CHAT_BUY_SUMMARY_BOUGHT = "%s を %s 個、%s で購入しました",
    SI_PA_CHAT_BUY_SUMMARY_MISSING = "%s を %s で購入できませんでした（%s 不足）",
	
}

for key, value in pairs(PARStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end


local PARGenericStrings = {
    -- =================================================================================================================
    -- Language independent texts (do not need to be translated/copied to other languages --

    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    SI_PA_CHAT_REPAIR_CHARGE_WEAPON = "%s (%d%% --> %d%%) - %s",
}

for key, value in pairs(PARGenericStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end