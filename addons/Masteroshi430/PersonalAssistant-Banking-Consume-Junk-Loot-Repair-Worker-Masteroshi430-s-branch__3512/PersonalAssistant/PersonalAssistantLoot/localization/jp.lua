local PAC = PersonalAssistant.Constants
local PALStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    SI_PA_MENU_LOOT_DESCRIPTION = "PALootは、未習得のレシピやモチーフ、研究していない特性など、特に関心のあるアイテムについて通知することができます",

    -- PALoot Loot Events --
    SI_PA_MENU_LOOT_EVENTS_HEADER = "戦利品イベント（アイテムを拾った際のアクション）",
    SI_PA_MENU_LOOT_EVENTS_ENABLE = "戦利品イベントを有効化",
	
    -- PALoot Loot Auto Loot --
    SI_PA_MENU_AUTO_LOOT_HEADER = "スマート自動ルート（空き容量低下、盗品など）",
    SI_PA_MENU_AUTO_LOOT_ENABLE = "自動ルートを有効化",

    -- Loot Recipes
    SI_PA_MENU_LOOT_RECIPES_HEADER = table.concat({"ルート時の挙動：", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_RECIPE).."/"..GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3), 2)}),
    SI_PA_MENU_LOOT_RECIPES_UNKNOWN_MSG = table.concat({"> ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE).."/"..GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3), "が未習得の場合"}),
    SI_PA_MENU_LOOT_RECIPES_UNKNOWN_MSG_T = table.concat({"このキャラクターがまだ習得していない ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE).."/"..GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3), " を拾った際、チャット欄にメッセージを表示します"}),
    
    SI_PA_MENU_LOOT_AUTO_LEARN_RECIPES = table.concat({"自動で習得する：", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE)}),
    SI_PA_MENU_LOOT_AUTO_LEARN_RECIPES_T = table.concat({"このキャラクターがまだ習得していない ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE), " を拾った際、自動的に使用して習得します"}),	
	
    SI_PA_MENU_LOOT_AUTO_LEARN_FURNISHING_PLAN = table.concat({"自動で習得する：", GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3)}),
    SI_PA_MENU_LOOT_AUTO_LEARN_FURNISHING_PLAN_T = table.concat({"このキャラクターがまだ習得していない ", GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3), " を拾った際、自動的に使用して習得します"}),
	
    -- Loot Scribing Scripts & Grimoires
    SI_PA_MENU_LOOT_SCRIBING_SCRIPTS_HEADER = table.concat({"ルート時の挙動：", zo_strformat(GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT),2), "/", zo_strformat(GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY, 2))}),
    SI_PA_MENU_LOOT_SCRIBING_SCRIPTS_UNKNOWN_MSG = table.concat({"> ", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT).."/"..GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY), "が未習得の場合"}),
    SI_PA_MENU_LOOT_SCRIBING_SCRIPTS_UNKNOWN_MSG_T = table.concat({"このキャラクターがまだ習得していない ", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT).."/"..GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY), " を拾った際、チャット欄にメッセージを表示します"}),
    
    SI_PA_MENU_LOOT_AUTO_LEARN_SCRIBING_SCRIPTS = table.concat({"自動で習得する：", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT)}),
    SI_PA_MENU_LOOT_AUTO_LEARN_SCRIBING_SCRIPTS_T = table.concat({"このキャラクターがまだ習得していない ", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT), " を拾った際、自動的に使用して習得します"}),
	
    SI_PA_MENU_LOOT_AUTO_LEARN_SCRIBING_GRIMOIRES = table.concat({"自動で習得する：", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY)}),
    SI_PA_MENU_LOOT_AUTO_LEARN_SCRIBING_GRIMOIRES_T = table.concat({"このキャラクターがまだ習得していない ", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY), " を拾った際、自動的に使用して習得します"}),

    -- Loot Motifs & Style Pages
    SI_PA_MENU_LOOT_STYLES_HEADER = "ルート時の挙動：スタイル",
	
    SI_PA_MENU_LOOT_MOTIFS_UNKNOWN_MSG = table.concat({"> ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), "が未習得の場合"}),
    SI_PA_MENU_LOOT_MOTIFS_UNKNOWN_MSG_T = table.concat({"このキャラクターがまだ習得していない ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), " を拾った際、チャット欄にメッセージを表示します"}),
 
    SI_PA_MENU_LOOT_STYLEPAGES_UNKNOWN_MSG = table.concat({"> ", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE), "が未習得の場合"}),
    SI_PA_MENU_LOOT_STYLEPAGES_UNKNOWN_MSG_T = table.concat({"このキャラクターがまだ習得していない ", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE), " を拾った際、チャット欄にメッセージを表示します"}), 
	
    SI_PA_MENU_LOOT_AUTO_LEARN_MOTIFS = table.concat({"自動で習得する：", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF)}),
    SI_PA_MENU_LOOT_AUTO_LEARN_MOTIFS_T = table.concat({"このキャラクターがまだ習得していない ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), " を拾った際、自動的に使用して習得します"}),

    SI_PA_MENU_LOOT_AUTO_LEARN_STYLEPAGES = table.concat({"自動で習得する：", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE)}),
    SI_PA_MENU_LOOT_AUTO_LEARN_STYLEPAGES_T = table.concat({"このキャラクターがまだ習得していない ", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE), " を拾った際、自動的に使用して習得します"}),


    -- Loot Equipment (Apparel, Weapons & Jewelries)
    SI_PA_MENU_LOOT_APPARELWEAPONS_HEADER = "ルート時の挙動：装備品",
    SI_PA_MENU_LOOT_APPARELWEAPONS_UNKNOWN_MSG = "> 特性がまだ研究されていない場合",
    SI_PA_MENU_LOOT_APPARELWEAPONS_UNKNOWN_MSG_T = table.concat({"このキャラクターがまだ研究していない特性を持つ ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ARMOR), "、", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WEAPONS), "、または ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRY), " を拾った際、チャット欄にメッセージを表示します"}),
    SI_PA_MENU_LOOT_APPARELWEAPONS_UNCOLLECTED_MSG = "> セットアイテムが未コレクションの場合",
    SI_PA_MENU_LOOT_APPARELWEAPONS_UNCOLLECTED_MSG_T = table.concat({"セットコレクションにまだ登録されていないセットの一部である ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ARMOR), "、", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WEAPONS), "、または ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRY), " を拾った際、チャット欄にメッセージを表示します"}),
    SI_PA_MENU_LOOT_APPARELWEAPONS_AUTOBIND = "未登録のセットアイテムを自動結合する",
    SI_PA_MENU_LOOT_APPARELWEAPONS_AUTOBIND_T = table.concat({"セットコレクションにまだ登録されていないセットの一部である ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ARMOR), "、", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WEAPONS), "、または ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRY), " を拾った際、自動的に結合（バインド）してコレクションへ登録します"}),

    -- Loot Companion Items
    SI_PA_MENU_LOOT_COMPANION_ITEMS_HEADER = table.concat({"ルート時の挙動：", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COMPANION)}),
    SI_PA_MENU_LOOT_COMPANION_ITEMS_QUALITY_THRESHOLD = table.concat({"> 特定の品質以上の ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COMPANION), " を拾った場合"}),
    SI_PA_MENU_LOOT_COMPANION_ITEMS_QUALITY_THRESHOLD_T = table.concat({"設定した品質以上の ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COMPANION), " を拾った際、チャット欄にメッセージを表示します"}),

    -- Auto Fillet common fish
    SI_PA_MENU_LOOT_AUTO_FILLET_HEADER = table.concat({"ルート時の挙動：", GetString("SI_ITEMTYPE", ITEMTYPE_FISH)}),
    SI_PA_MENU_LOOT_AUTO_FILLET = "一般的な魚を自動でさばく",
    SI_PA_MENU_LOOT_AUTO_FILLET_T = "「魚」や「完璧な魚卵」を入手するために、一般的な魚を自動的にさばきます",
	
    -- Auto Combine collectibles
    SI_PA_MENU_LOOT_AUTO_COMBINE_HEADER = table.concat({"ルート時の挙動：", GetString(SI_SPECIALIZEDITEMTYPE109)}),
    SI_PA_MENU_LOOT_AUTO_COMBINE = "未ロックのコレクションの破片を自動合成する",
    SI_PA_MENU_LOOT_AUTO_COMBINE_T = "コレクションをアンロックするために、収集品のフラグメント（破片）を自動的に合成します",


    -- Inventory space warning --
    SI_PA_MENU_LOOT_LOW_INVENTORY_WARNING = "所持品の空き容量低下時に警告",
    SI_PA_MENU_LOOT_LOW_INVENTORY_WARNING_T = "所持品の空き容量が少なくなった際、チャット欄に警告を表示します",
    SI_PA_MENU_LOOT_LOW_INVENTORY_THRESHOLD = "所持品空き容量のしきい値",
    SI_PA_MENU_LOOT_LOW_INVENTORY_THRESHOLD_T = "残りの空きスロット数がこの数値以下になった場合、チャット欄にメッセージを表示します",

    -- PALoot Mark Items --
    SI_PA_MENU_LOOT_ICONS_HEADER = "アイテムアイコン",
    SI_PA_MENU_LOOT_ICONS_ENABLE = "アイテムにアイコンを表示する",
    SI_PA_MENU_LOOT_ICONS_ANY_SHOW_TOOLTIP = "アイコンのツールチップを表示する",
	
    -- mark known as junk --
    SI_PA_MENU_LOOT_AUTO_MARK_AS_JUNK_KNOWN = "既知のアイテムを自動でジャンクとしてマークする",
    SI_PA_MENU_LOOT_AUTO_MARK_AS_JUNK_KNOWN_T = "既知のアイテムを自動でジャンクとしてマークし、商人へ自動売却できるようにします",

    -- Mark Recipes --
    SI_PA_MENU_LOOT_ICONS_RECIPES_HEADER = table.concat({"アイコン表示設定：", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_RECIPE), 2)}),
    SI_PA_MENU_LOOT_ICONS_RECIPE_SHOW_KNOWN = table.concat({"> ", PAC.ICONS.OTHERS.KNOWN.NORMAL, " ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE), "がすでに既知の場合"}),
    SI_PA_MENU_LOOT_ICONS_RECIPE_SHOW_UNKNOWN = table.concat({"> ", PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE), "がまだ未知の場合"}),
	
    -- Mark scribing --
    SI_PA_MENU_LOOT_ICONS_SCRIBING_HEADER = table.concat({"アイコン表示設定：", GetString(SI_NOTIFICATIONTYPE20), " ", GetString(SI_ITEMTYPE73), "/", GetString(SI_ITEMTYPE72)}),
    SI_PA_MENU_LOOT_ICONS_SCRIBING_SHOW_KNOWN = table.concat({"> ", PAC.ICONS.OTHERS.KNOWN.NORMAL, " ", GetString(SI_NOTIFICATIONTYPE20), " ", GetString(SI_ITEMTYPE73), "/", GetString(SI_ITEMTYPE72), "がすでに既知の場合"}),
    SI_PA_MENU_LOOT_ICONS_SCRIBING_SHOW_UNKNOWN = table.concat({"> ", PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " ", GetString(SI_NOTIFICATIONTYPE20), " ", GetString(SI_ITEMTYPE73), "/", GetString(SI_ITEMTYPE72), "がまだ未知の場合"}),

    -- Mark Motifs and Style Page Containers --
    SI_PA_MENU_LOOT_ICONS_STYLES_HEADER = "アイコン表示設定：スタイル",
    SI_PA_MENU_LOOT_ICONS_MOTIFS_SHOW_KNOWN = table.concat({"> ", PAC.ICONS.OTHERS.KNOWN.NORMAL, " ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), "がすでに既知の場合"}),
    SI_PA_MENU_LOOT_ICONS_MOTIFS_SHOW_UNKNOWN = table.concat({"> ", PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), "がまだ未知の場合"}),
    SI_PA_MENU_LOOT_ICONS_STYLEPAGES_SHOW_KNOWN = table.concat({"> ", PAC.ICONS.OTHERS.KNOWN.NORMAL, " ", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE), "がすでに既知の場合"}),
    SI_PA_MENU_LOOT_ICONS_STYLEPAGES_SHOW_UNKNOWN = table.concat({"> ", PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " ", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE), "がまだ未知の場合"}),

    -- Mark Equipment (Apparel, Weapons & Jewelries) --
    SI_PA_MENU_LOOT_ICONS_APPARELWEAPONS_HEADER = "アイコン表示設定：装備品",
    SI_PA_MENU_LOOT_ICONS_APPARELWEAPONS_SHOW_KNOWN = table.concat({"> ", PAC.ICONS.OTHERS.KNOWN.NORMAL, " アイテム特性がすでに研究済みのとき"}),
    SI_PA_MENU_LOOT_ICONS_APPARELWEAPONS_SHOW_UNKNOWN = table.concat({"> ", PAC.ICONS.OTHERS.NOT_RESEARCHED.NORMAL, " アイテム特性がまだ研究されていない（未知の）とき"}),
    SI_PA_MENU_LOOT_ICONS_APPARELWEAPONS_SET_UNCOLLECTED = table.concat({"> ", PAC.ICONS.OTHERS.UNCOLLECTED.NORMAL, " セットコレクションにアイテムが登録されていない（未収集の）とき"}),

    -- Mark Companion Items --
    SI_PA_MENU_LOOT_ICONS_MARK_COMPANION_ITEMS_HEADER = table.concat({"アイコン表示設定：", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COMPANION)}),
    SI_PA_MENU_LOOT_ICONS_MARK_COMPANION_ITEMS_SHOW_ALL = table.concat({"> ", PAC.ICONS.OTHERS.COMPANION.NORMAL, " 同行者のアイテムであるとき"}),

    -- Item Icon Positioning --
    SI_PA_MENU_LOOT_ICONS_POSITIONING_DESCRIPTION = "以下より、アイテムアイコンの表示位置やサイズを調整できます",
    SI_PA_MENU_LOOT_ICONS_KNOWN_UNKNOWN_HEADER = "既知 / 未知",
    SI_PA_MENU_LOOT_ICONS_SET_COLLECTION_HEADER = "未収集セット",
    SI_PA_MENU_LOOT_ICONS_COMPANION_ITEMS_HEADER = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COMPANION),

    SI_PA_MENU_LOOT_ICONS_SIZE_LIST = "アイコンサイズ（リスト表示）",
    SI_PA_MENU_LOOT_ICONS_SIZE_LIST_T = "アイテムがリスト形式で表示される場所での既知/未知アイコンのサイズを設定します",
    SI_PA_MENU_LOOT_ICONS_SIZE_GRID = "アイコンサイズ（グリッド表示）",
    SI_PA_MENU_LOOT_ICONS_SIZE_GRID_T = "アイテムがグリッド形式で表示される場所での既知/未知アイコンのサイズを設定します",

    SI_PA_MENU_LOOT_ICONS_X_OFFSET_LIST = "アイコンのX位置オフセット（リスト表示）",
    SI_PA_MENU_LOOT_ICONS_X_OFFSET_LIST_T = "リスト表示における既知/未知アイコンの横方向の表示位置を調整します",
    SI_PA_MENU_LOOT_ICONS_Y_OFFSET_LIST = "アイコンのY位置オフセット（リスト表示）",
    SI_PA_MENU_LOOT_ICONS_Y_OFFSET_LIST_T = "リスト表示における既知/未知アイコンの縦方向の表示位置を調整します",

    SI_PA_MENU_LOOT_ICONS_X_OFFSET_GRID = "アイコンのX位置オフセット（グリッド表示）",
    SI_PA_MENU_LOOT_ICONS_X_OFFSET_GRID_T = "グリッド表示における既知/未知アイコンの横方向の表示位置を調整します",
    SI_PA_MENU_LOOT_ICONS_Y_OFFSET_GRID = "アイコンのY位置オフセット（グリッド表示）",
    SI_PA_MENU_LOOT_ICONS_Y_OFFSET_GRID_T = "グリッド表示における既知/未知アイコンの縦方向の表示位置を調整します",


    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PALoot --
    SI_PA_CHAT_LOOT_RECIPE_UNKNOWN = table.concat({PAC.ICONS.OTHERS.UNKNOWN.SMALL, "%s は", PAC.COLORS.ORANGE,"習得可能", PAC.COLORS.DEFAULT, "です！"}),
    SI_PA_CHAT_LOOT_MOTIF_UNKNOWN = table.concat({PAC.ICONS.OTHERS.UNKNOWN.SMALL, "%s は", PAC.COLORS.ORANGE,"習得可能", PAC.COLORS.DEFAULT, "です！"}),
    SI_PA_CHAT_LOOT_SCRIBING_SCRIPT_UNKNOWN = table.concat({PAC.ICONS.OTHERS.UNKNOWN.SMALL, "%s は", PAC.COLORS.ORANGE,"習得可能", PAC.COLORS.DEFAULT, "です！"}),
    SI_PA_CHAT_LOOT_TRAIT_UNKNOWN = table.concat({PAC.ICONS.OTHERS.UNKNOWN.SMALL, "%s は研究可能な特性 [", PAC.COLORS.ORANGE,"%s", PAC.COLORS.DEFAULT,"] を持っています！"}),
    SI_PA_CHAT_LOOT_SET_UNCOLLECTED = table.concat({PAC.ICONS.OTHERS.UNCOLLECTED.SMALL, "%s はセットコレクションに登録されていません！"}),
    SI_PA_CHAT_LOOT_COMPANION_ITEM = table.concat({PAC.ICONS.OTHERS.COMPANION.SMALL, "%s 新しい同行者アイテム（特性：", PAC.COLOR.WHITE:Colorize("%s"), "）を獲得しました！"}),
    SI_PA_CHAT_LOOT_AUTO_FILLET = "%s を自動的にさばいています。",
	

    SI_PA_PATTERN_INVENTORY_COUNT = table.concat({"%s所持品の空きが <<1[", PAC.COLORS.WHITE,"ありません/残りわずか ", PAC.COLORS.WHITE, "%d個/残りわずか ", PAC.COLORS.WHITE, "%d個]>> しかありません！"}),
    SI_PA_PATTERN_REPAIRKIT_COUNT = table.concat({"%s修理キットの残りが <<1[", PAC.COLORS.WHITE,"ありません/残りわずか ", PAC.COLORS.WHITE, "%d個/残りわずか ", PAC.COLORS.WHITE, "%d個]>> しかありません！"}),
    SI_PA_PATTERN_SOULGEM_COUNT = table.concat({"%sソウルジェムの残りが <<1[", PAC.COLORS.WHITE,"ありません/残りわずか ", PAC.COLORS.WHITE, "%d個/残りわずか ", PAC.COLORS.WHITE, "%d個]>> しかありません！"}),


    -- =================================================================================================================
    -- == OTHER STRINGS FOR MENU == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PALoot --
    SI_PA_DISPLAY_A_MESSAGE_WHEN = "以下の場合にメッセージを表示する . . .",
    SI_PA_MARK_WITH = "以下でマークする . . .",
    SI_PA_ITEM_KNOWN = "すでに習得済み（既知）",
    SI_PA_ITEM_UNKNOWN = "未習得（未知）",
    SI_PA_ITEM_OTHERUNKNOWN = "他のキャラクターで未習得",
    SI_PA_ITEM_UNCOLLECTED = "未収集",
    SI_PA_ITEM_COMPANION_ITEM = "同行者のアイテム"
}

for key, value in pairs(PALStrings) do
    SafeAddString(_G[key], value, 1)
end