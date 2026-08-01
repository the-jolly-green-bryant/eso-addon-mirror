-- Translated by: PersonalAssistant Localization Team (Japanese Translation)

local PAC = PersonalAssistant.Constants
local PAJStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAJunk Menu --
    SI_PA_MENU_JUNK_DESCRIPTION = "PAJunkは、クラフトされたアイテムまたはメールから受け取ったアイテムを除き、ルールに一致したアイテムを自動的にジャンクに分類します。",

    -- Standard Items --
    SI_PA_MENU_JUNK_STANDARD_ITEMS_HEADER = "標準アイテム",
    SI_PA_MENU_JUNK_AUTOMARK_ENABLE = "ジャンクの自動マークを有効化",
    SI_PA_MENU_JUNK_AUTOMARK_ENABLE_T = "「標準アイテム」にのみ適用されます。カスタムジャンクルールには適用されません。無効にしたい場合はカスタムルール設定で個別に設定してください。",

    SI_PA_MENU_JUNK_TRASH_AUTOMARK = table.concat({"[", GetString("SI_ITEMTYPE", ITEMTYPE_TRASH), "] を自動マーク"}),
    SI_PA_MENU_JUNK_TRASH_AUTOMARK_T = table.concat({"[", GetString("SI_ITEMTYPE", ITEMTYPE_TRASH), "] を自動的にジャンクとしてマークします。"}),
    SI_PA_MENU_JUNK_TRASH_EXCLUDE_ITEMS_DESC = table.concat({"以下の場合、[", GetString("SI_ITEMTYPE", ITEMTYPE_TRASH), "] のジャンクマークを除外する:"}),
    SI_PA_MENU_JUNK_TRASH_EXCLUDE_NIBBLES_AND_BITS = table.concat({"> デイリークエストに必要： ", PAC.COLOR.YELLOW:Colorize("Nibbles and Bits")}),
    SI_PA_MENU_JUNK_TRASH_EXCLUDE_NIBBLES_AND_BITS_T = table.concat({PAC.COLOR.YELLOW:Colorize("クエスト場所: "), PAC.COLOR.ORANGE:Colorize("クロックワーク・シティ"), "\n有効にすると、以下のアイテムがジャンクとしてマークされなくなります:\n[甲殻 (Carapace)]\n[デイドラの外皮 (Daedra Husks)]\n[汚れたハイド (Dirty Hide)]"}),
    SI_PA_MENU_JUNK_TRASH_EXCLUDE_MORSELS_AND_PECKS = table.concat({"> デイリークエストに必要： ", PAC.COLOR.YELLOW:Colorize("Morsels and Pecks")}),
    SI_PA_MENU_JUNK_TRASH_EXCLUDE_MORSELS_AND_PECKS_T = table.concat({PAC.COLOR.YELLOW:Colorize("クエスト場所: "), PAC.COLOR.ORANGE:Colorize("クロックワーク・シティ"), "\n有効にすると、以下のアイテムがジャンクとしてマークされなくなります:\n[元素のエッセンス (Elemental Essence)]\n[しなやかな根 (Supple Roots)]\n[エクトプラズム (Ectoplasm)]"}),

    SI_PA_MENU_JUNK_COLLECTIBLES_AUTOMARK = table.concat({"[", GetString("SI_ITEMSELLINFORMATION", ITEM_SELL_INFORMATION_PRIORITY_SELL), "] を自動マーク"}),
    SI_PA_MENU_JUNK_COLLECTIBLES_AUTOMARK_T = table.concat({"[", GetString("SI_ITEMSELLINFORMATION", ITEM_SELL_INFORMATION_PRIORITY_SELL), "]（換金用アイテム）の特性を持つアイテムを自動的にジャンクとしてマークします。"}),
    SI_PA_MENU_JUNK_COLLECTIBLES_EXCLUDE_ITEMS_DESC = table.concat({"以下の場合、[", GetString("SI_ITEMSELLINFORMATION", ITEM_SELL_INFORMATION_PRIORITY_SELL), "] のジャンクマークを除外する:"}),
    SI_PA_MENU_JUNK_COLLECTIBLES_EXCLUDE_RARE_FISH = table.concat({"> [", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH), "] がイベントクエスト ", PAC.COLOR.YELLOW:Colorize("「魚の恵みの祝宴」") , "に必要"}),
    SI_PA_MENU_JUNK_COLLECTIBLES_EXCLUDE_RARE_FISH_T = table.concat({PAC.COLOR.YELLOW:Colorize("イベント: "), PAC.COLOR.ORANGE:Colorize("ニュー・ライフ・フェスティバル"), "（冬季開催）\n有効にすると、すべての [", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH), "] がジャンクとしてマークされなくなります。"}),

    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_AUTOMARK = table.concat({"[", GetString("SI_ITEMTYPE", ITEMTYPE_TREASURE), "] を自動マーク"}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_AUTOMARK_T = table.concat({"[", GetString("SI_ITEMTYPE", ITEMTYPE_TREASURE), "] を自動的にジャンクとしてマークします。"}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_ITEMS_DESC = table.concat({"以下の場合、[", GetString("SI_ITEMTYPE", ITEMTYPE_TREASURE), "] のジャンクマークまたは破壊を除外する:"}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_LEISURE = table.concat({"> デイリークエストに必要： ", PAC.COLOR.YELLOW:Colorize("A Matter of Leisure")}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_LEISURE_T = table.concat({PAC.COLOR.YELLOW:Colorize("クエスト場所: "), PAC.COLOR.ORANGE:Colorize("クロックワーク・シティ"), "\n有効にすると、以下のアイテムがジャンクとしてマークされなくなります:\n[子供のおもちゃ]\n[人形]\n[ゲーム]"}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_RESPECT = table.concat({"> デイリークエストに必要： ", PAC.COLOR.YELLOW:Colorize("A Matter of Respect")}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_RESPECT_T = table.concat({PAC.COLOR.YELLOW:Colorize("クエスト場所: "), PAC.COLOR.ORANGE:Colorize("クロックワーク・シティ"), "\n有効にすると、以下のアイテムがジャンクとしてマークされなくなります:\n[食器類]\n[コップ類]\n[皿と調理器具]"}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_TRIBUTES = table.concat({"> デイリークエストに必要： ", PAC.COLOR.YELLOW:Colorize("A Matter of Tributes")}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_TRIBUTES_T = table.concat({PAC.COLOR.YELLOW:Colorize("クエスト場所: "), PAC.COLOR.ORANGE:Colorize("クロックワーク・シティ"), "\n有効にすると、以下のアイテムがジャンクとしてマークされなくなります:\n[化粧品]\n[身だしなみ用品]"}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_THE_COVETOUS_COUNTESS = table.concat({"> デイリークエストに必要： ", PAC.COLOR.YELLOW:Colorize("The Covetous Countess")}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_THE_COVETOUS_COUNTESS_T = table.concat({PAC.COLOR.YELLOW:Colorize("クエスト場所: "), PAC.COLOR.ORANGE:Colorize("盗賊ギルド"), "\n有効にすると、以下のアイテムがジャンクとしてマークされなくなります:\n[化粧品]\n[織物 (リネン類)]\n[ワードローブアクセサリー]\n\n[コップ類]\n[食器類]\n[皿と調理器具]\n\n[ゲーム]\n[人形]\n[彫像]\n\n[書物] ＆ [筆記用具]\n[地図]\n\n[儀式用具]\n[奇妙な品]"}),

    -- Stolen Items --
    SI_PA_MENU_JUNK_AUTOMARK_STOLEN_HEADER = "盗品",
    SI_PA_MENU_JUNK_ACTION_STOLEN_PLACEHOLDER = "%s",

    -- Custom Items --
    SI_PA_MENU_JUNK_CUSTOM_ITEMS_HEADER = "カスタムアイテム",
    SI_PA_MENU_JUNK_CUSTOM_ITEMS_DESCRIPTION = table.concat({GetString(SI_PA_MENU_RULES_HOW_TO_ADD_PAJ), "\n\n", GetString(SI_PA_MENU_RULES_HOW_TO_FIND_MENU)}),

    -- Quest Items --
    SI_PA_MENU_JUNK_QUEST_ITEMS_HEADER = "クエスト用盗品の保護",
    SI_PA_MENU_JUNK_QUEST_CLOCKWORK_CITY_HEADER = "クロックワーク・シティ",
    SI_PA_MENU_JUNK_QUEST_THIEVES_GUILD_HEADER = "盗賊ギルド",
    SI_PA_MENU_JUNK_QUEST_NEW_LIFE_FESTIVAL_HEADER = "ニュー・ライフ・フェスティバル",

    -- Auto-Sell --
    SI_PA_MENU_JUNK_AUTO_SELL_JUNK_HEADER = "ジャンクの自動売却",

    -- Auto-Launder --
    SI_PA_MENU_JUNK_AUTO_LAUNDER_HEADER = "盗品の自動盗品洗浄",
    SI_PA_MENU_JUNK_AUTO_LAUNDER = "自動盗品洗浄を有効化",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_LOCKPICKS = "ロックピックを洗浄する？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_INGREDIENTS = "料理の食材を洗浄する？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_MATERIALS = "クラフト素材を洗浄する？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_CRAFTING_BOOSTERS = "強化素材（ブースター）を洗浄する？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_ENCHANTING_RUNES = "付呪のルーンを洗浄する？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_GLYPHS = "グリフを洗浄する？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_FURNISHING = "家具と設計図を洗浄する？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_SOULGEMS = "ソウルジェムを洗浄する？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_TREASURES = "お宝を洗浄する？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_TREASURE_MAPS = "古びた地図を洗浄する？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_RECIPES = "レシピや設計図を洗浄する？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_MOTIFS = "モチーフのページを洗浄する？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_EDICTS = "免罪符を洗浄する？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_CONTAINERS = "コンテナを洗浄する？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_REPAIR_KITS = "修理キットを洗浄する？",

    -- Auto-Destroy --
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_HEADER = "ジャンクの自動破壊",
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK = "自動ジャンク破壊を有効化",
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_T = "入手したアイテムがジャンクの条件を満たし、その価値や品質が設定された閾値以下の場合、自動的に破壊します。この操作は取り消せません！",
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_W = "警告: この設定を有効にすると、条件に合致するアイテムは確認ダイアログなしで直接破壊されます！\n破壊されたアイテムは永遠に失われます！\n自己責任でご利用ください！",

    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_JUNK_HEADER = "一般のジャンク",
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_MAX_VALUE_THRESHOLD = "売却価値が以下の場合:",
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_MAX_VALUE_THRESHOLD_T = "売却価値がこの設定値以下のジャンクのみ自動破壊します。破壊されたアイテムは元に戻せません。",
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_MAX_QUALITY_THRESHOLD = "かつ品質が以下の場合:",
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_MAX_QUALITY_THRESHOLD_T = "品質がこの設定値以下のジャンクのみ自動破壊します。破壊されたアイテムは元に戻せません。",
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_EXCLUSION_DISCLAIMER = "例外：未既知のアイテム（未学習のレシピ、モチーフ、スタイルページなど）は、売却価値や品質の閾値を下回っていても自動破壊されません。",

    -- Stolen Junk --
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_JUNK_HEADER = "盗品ジャンク",
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK = "盗品ジャンクの自動破壊を有効化",
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_T = "入手した盗品がジャンクの条件を満たし、その価値や品質が設定された閾値以下の場合、自動的に破壊します。この操作は取り消せません！",
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_MAX_VALUE_THRESHOLD = "盗品売却価値が以下の場合:",
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_MAX_VALUE_THRESHOLD_T = "盗品売却価格がこの設定値以下のジャンクのみ自動破壊します。破壊されたアイテムは元に戻せません。",
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_MAX_QUALITY_THRESHOLD = "かつ品質が以下の場合:",
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_MAX_QUALITY_THRESHOLD_T = "品質がこの設定値以下のジャンクのみ自動破壊します。破壊されたアイテムは元に戻せません。",

    -- Other Settings --
    SI_PA_MENU_JUNK_MAILBOX_IGNORE = "メールから受け取ったアイテムを保護",
    SI_PA_MENU_JUNK_MAILBOX_IGNORE_T = "メールから回収したアイテムは、絶対にジャンクとしてマークされません。",
    SI_PA_MENU_JUNK_CRAFTED_IGNORE = "クラフトしたアイテムを保護",
    SI_PA_MENU_JUNK_CRAFTED_IGNORE_T = "プレイヤー自身がクラフトしたアイテムは、絶対にジャンクとしてマークされません。",
    SI_PA_MENU_JUNK_AUTOSELL_JUNK = "商人または盗品商でジャンクを自動売却",
    SI_PA_MENU_JUNK_AUTOSELL_JUNK_PIRHARRI = "密輸業者（助手）への自動売却を許可",
    SI_PA_MENU_JUNK_AUTOSELL_JUNK_PIRHARRI_W = "密輸業者（助手）を介して売却する場合、35%の取引手数料（密輸手数料）が差し引かれます。",

    SI_PA_MENU_JUNK_KEYBINDINGS_HEADER = "キーバインド設定",
    SI_PA_MENU_JUNK_KEYBINDINGS_MARK_UNMARK_JUNK_ENABLE = "「ジャンクとしてマーク」キーバインドを有効化",
    SI_PA_MENU_JUNK_KEYBINDINGS_MARK_UNMARK_JUNK_SHOW = "「ジャンクとしてマーク」キーバインドを表示",
    SI_PA_MENU_JUNK_KEYBINDINGS_MARK_UNMARK_PERM_JUNK_ENABLE = "「恒久的にジャンクに登録」キーバインドを有効化",
    SI_PA_MENU_JUNK_KEYBINDINGS_MARK_UNMARK_PERM_JUNK_SHOW = "「恒久的にジャンクに登録」キーバインドを表示",
    SI_PA_MENU_JUNK_KEYBINDINGS_DESTROY_ITEM_ENABLE = "「アイテムを破壊」キーバインドを有効化",
    SI_PA_MENU_JUNK_KEYBINDINGS_DESTROY_ITEM_ENABLE_W = "警告: このキーバインドを使用すると、確認ダイアログなしでアイテムが即座に直接破壊されます！\nこの破壊は取り消せません！\n自己責任でご利用ください！",
    SI_PA_MENU_JUNK_KEYBINDINGS_DESTROY_ITEM_SHOW = "「アイテムを破壊」キーバインドを表示",
    SI_PA_MENU_JUNK_KEYBINDINGS_EXCLUDE_DESCRIPTION = "以下の場合、「アイテムを破壊」キーバインドを無効にする:",
    SI_PA_MENU_JUNK_KEYBINDINGS_DESTROY_QUALITY_THRESHOLD = "> 指定以上の品質",
    SI_PA_MENU_JUNK_KEYBINDINGS_DESTROY_UNKNOWN = "> 研究/学習可能な未習得アイテム",

    -- General texts used across: Weapons, Armor, Jewelry
    SI_PA_MENU_JUNK_AUTOMARK_QUALITY_THRESHOLD = "%s の自動マーク対象品質（以下）",
    SI_PA_MENU_JUNK_AUTOMARK_QUALITY_THRESHOLD_T = "%s の品質が選択された品質以下の場合、自動的にジャンクとしてマークします。",
    SI_PA_MENU_JUNK_AUTOMARK_ORNATE = table.concat({"%s の [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE), "] 特性を自動マーク"}),
    SI_PA_MENU_JUNK_AUTOMARK_ORNATE_T = table.concat({"%s の [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE), "]（オルネイト／高価：売却価格上昇）特性を持つアイテムをジャンクにマークしますか？"}),
    SI_PA_MENU_JUNK_AUTOMARK_INTRICATE = table.concat({"%s の [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE), "] 特性を自動マーク"}),
    SI_PA_MENU_JUNK_AUTOMARK_INTRICATE_T = table.concat({"%s の [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE), "]（イントリケイト／複雑：分解経験値上昇）特性を持つアイテムをジャンクにマークしますか？"}),
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_SETS = "%s のセット装備を含める",
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_SETS_T = "オフにすると、セット装備に属していない %s のみが自動ジャンクマークの対象になります。",
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_KNOWN_TRAITS = "%s の研究済み特性を含める",
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_KNOWN_TRAITS_T = "オフにすると、特性なし、または未研究の特性を持つ %s のみが自動ジャンクマークの対象になります。",
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_UNKNOWN_TRAITS = "%s の未研究特性を含める",
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_UNKNOWN_TRAITS_T = "オフにすると、特性なし、または研究済みの特性を持つ %s のみが自動ジャンクマークの対象になります。",


    -- =================================================================================================================
    -- == MAIN MENU TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAJunk --
    SI_PA_MAINMENU_JUNK_HEADER = "ジャンクルールリスト",

    SI_PA_MAINMENU_JUNK_HEADER_ITEM = "アイテム",
    SI_PA_MAINMENU_JUNK_HEADER_JUNK_COUNT = "ジャンク回数",
    SI_PA_MAINMENU_JUNK_HEADER_LAST_JUNK = "最後にマークした日時",
    SI_PA_MAINMENU_JUNK_HEADER_RULE_ADDED = "ルール追加日",
    SI_PA_MAINMENU_JUNK_HEADER_ACTIONS = "操作",

    SI_PA_MAINMENU_JUNK_ROW_NEVER_JUNKED = "履歴なし",


    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAJunk --
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_TRASH = table.concat({"%s をジャンクバッグに移動しました（理由: ", PAC.COLOR.ORANGE:Colorize(GetString("SI_ITEMTYPE", ITEMTYPE_TRASH)), "）"}),
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_ORNATE = table.concat({"%s をジャンクバッグに移動しました（理由: ", PAC.COLOR.ORANGE:Colorize(GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE)), "）"}),
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_INTRICATE = table.concat({"%s をジャンクバッグに移動しました（理由: ", PAC.COLOR.ORANGE:Colorize(GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE)), "）"}),
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_QUALITY = table.concat({"%s をジャンクバッグに移動しました（理由: ", PAC.COLOR.ORANGE:Colorize("品質"), "）"}),
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_MERCHANT = table.concat({"%s をジャンクバッグに移動しました（理由: ", PAC.COLOR.ORANGE:Colorize("換金用"), "）"}),
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_TREASURE = table.concat({"%s をジャンクバッグに移動しました（理由: ", PAC.COLOR.ORANGE:Colorize("お宝"), "）"}),
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_KEYBINDING = table.concat({"%s をジャンクバッグに移動しました（理由: ", PAC.COLOR.ORANGE:Colorize("手動操作"), "）"}),
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_STOLEN = table.concat({"%s をジャンクバッグに移動しました（理由: ", PAC.COLOR.ORANGE:Colorize("盗品"), "）"}),
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_PERMANENT = table.concat({"%s をジャンクバッグに移動しました（理由: ", PAC.COLOR.ORANGE:Colorize("個別恒久ルール"), "）"}),

    SI_PA_CHAT_JUNK_DESTROYED_KEYBINDING = table.concat({PAC.COLOR.ORANGE_RED:Colorize("破壊しました:"), " %d x %s"}),
    SI_PA_CHAT_JUNK_DESTROYED_ALWAYS = table.concat({PAC.COLOR.ORANGE_RED:Colorize("破壊しました:"), " %d x %s（理由: ", PAC.COLOR.ORANGE:Colorize("常に破壊"), "）"}),
    SI_PA_CHAT_JUNK_DESTROYED_CRITERIA_MATCH = table.concat({PAC.COLOR.ORANGE_RED:Colorize("破壊しました:"), " %d x %s（売却価格: %s）"}),
    SI_PA_CHAT_JUNK_AUTO_LAUNDERED = table.concat({PAC.COLOR.ORANGE_RED:Colorize("盗品を洗浄しました:"), " %d x %s (洗浄費用: %s)"}),

    SI_PA_CHAT_JUNK_DESTROY_ON = table.concat({"自動ジャンク破壊：", PAC.COLOR.RED:Colorize("オン")}),
    SI_PA_CHAT_JUNK_DESTROY_OFF = table.concat({"自動ジャンク破壊：", PAC.COLOR.GREEN:Colorize("オフ")}),
    SI_PA_CHAT_JUNK_DESTROY_STOLEN_ON = table.concat({"盗品の自動ジャンク破壊：", PAC.COLOR.RED:Colorize("オン")}),
    SI_PA_CHAT_JUNK_DESTROY_STOLEN_OFF = table.concat({"盗品の自動ジャンク破壊：", PAC.COLOR.GREEN:Colorize("オフ")}),

    SI_PA_CHAT_JUNK_SOLD_ITEMS_INFO = "ジャンクを売却しました。総額: %s",
    SI_PA_CHAT_JUNK_FENCE_LIMIT_HOURS = table.concat({GetString("SI_STOREFAILURE", STORE_FAILURE_AT_FENCE_LIMIT), "。あと約 %d 時間お待ちください。"}),
    SI_PA_CHAT_JUNK_FENCE_LIMIT_MINUTES = table.concat({GetString("SI_STOREFAILURE", STORE_FAILURE_AT_FENCE_LIMIT), "。あと約 %d 分お待ちください。"}),
    SI_PA_CHAT_JUNK_FENCE_ITEM_WORTHLESS = table.concat({"%s を売却できませんでした。 ", GetString("SI_STOREFAILURE", STORE_FAILURE_WORTHLESS_TO_FENCE)}),
    SI_PA_CHAT_JUNK_CANNOT_SELL_ITEM = "%s を売却できませんでした。",

    SI_PA_CHAT_JUNK_RULES_ADDED = table.concat({"%s を恒久ジャンクルールに", PAC.COLOR.ORANGE:Colorize("登録しました")}),
    SI_PA_CHAT_JUNK_RULES_DELETED = table.concat({"%s を恒久ジャンクルールから", PAC.COLOR.ORANGE:Colorize("削除しました")}),


    -- =================================================================================================================
    -- == KEY BINDINGS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- Addon Keybindings menu --
    SI_BINDING_NAME_PA_JUNK_TOGGLE_ITEM = "ジャンクの切り替え",
    SI_BINDING_NAME_PA_JUNK_PERMANENT_TOGGLE_ITEM = "恒久ジャンクルールの切り替え",
    SI_BINDING_NAME_PA_JUNK_DESTROY_ITEM = "アイテムを破壊",

    -- Actual keybindings --
    SI_PA_ITEM_ACTION_MARK_AS_PERM_JUNK = "恒久ジャンクルールに追加",
    SI_PA_ITEM_ACTION_UNMARK_AS_PERM_JUNK = "恒久ジャンクルールから削除",


    -- =================================================================================================================
    -- == OTHER STRINGS == --   !!! NEED TO BE AN EXACT MATCH WITH THE "TAG" ON THE ITEM !!!
    -- -----------------------------------------------------------------------------------------------------------------
    -- Quest: "A Matter of Leisure"
    SI_PA_TREASURE_ITEM_TAG_DESC_TOYS = "子供のおもちゃ",
    SI_PA_TREASURE_ITEM_TAG_DESC_DOLLS = "人形",
    SI_PA_TREASURE_ITEM_TAG_DESC_GAMES = "ゲーム",

    -- Quest: "A Matter of Respect"
    SI_PA_TREASURE_ITEM_TAG_DESC_UTENSILS = "食器類",
    SI_PA_TREASURE_ITEM_TAG_DESC_DRINKWARE = "コップ類",
    SI_PA_TREASURE_ITEM_TAG_DESC_DISHES_COOKWARE = "皿と調理器具",

    -- Quest: "A Matter of Tributes"
    SI_PA_TREASURE_ITEM_TAG_DESC_COSMETICS = "化粧品",
    SI_PA_TREASURE_ITEM_TAG_DESC_GROOMING = "身だしなみ用品",

    -- Quest: "The Covetous Countess" (only additional tags)
    SI_PA_TREASURE_ITEM_TAG_DESC_LINENS = "織物",
    SI_PA_TREASURE_ITEM_TAG_DESC_ACCESSORIES = "ワードローブアクセサリー",
    SI_PA_TREASURE_ITEM_TAG_DESC_STATUES = "彫像",
    SI_PA_TREASURE_ITEM_TAG_DESC_WRITINGS = "書物",
    SI_PA_TREASURE_ITEM_TAG_DESC_SCRIVENER = "筆記用具",
    SI_PA_TREASURE_ITEM_TAG_DESC_MAPS = "地図",
    SI_PA_TREASURE_ITEM_TAG_DESC_RITUAL_OBJECTS = "儀式用具",
    SI_PA_TREASURE_ITEM_TAG_DESC_ODDITIES = "奇妙な品",

    -- OTHERS: Not yet used
    SI_PA_TREASURE_ITEM_TAG_DESC_INSTRUMENTS = "楽器",
    SI_PA_TREASURE_ITEM_TAG_DESC_ARTWORK = "美術品",
    SI_PA_TREASURE_ITEM_TAG_DESC_DECOR = "壁の装飾品",
    SI_PA_TREASURE_ITEM_TAG_DESC_TRIFLES_ORNAMENTS = "つまらない品と装飾品",
    SI_PA_TREASURE_ITEM_TAG_DESC_DEVICES = "装置",
    SI_PA_TREASURE_ITEM_TAG_DESC_SMITHING = "鍛冶用具",
    SI_PA_TREASURE_ITEM_TAG_DESC_TOOLS = "工具",
    SI_PA_TREASURE_ITEM_TAG_DESC_MEDICAL_SUPPLIES = "医療用品",
    SI_PA_TREASURE_ITEM_TAG_DESC_CURIOSITIES = "魔法の骨董品",
    SI_PA_TREASURE_ITEM_TAG_DESC_FURNISHINGS = "家具用品",
    SI_PA_TREASURE_ITEM_TAG_DESC_LIGHTS = "照明器具",


    -- =================================================================================================================
    -- PAJunk Menu --
    -- Fix wrong endings of headers and fix unused collectibles translation
    SI_PA_MENU_JUNK_COLLECTIBLES_HEADER = zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_COLLECTIBLE), 2),
    SI_PA_MENU_JUNK_WEAPONS_HEADER = zo_strformat(GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WEAPONS), 1),
    SI_PA_MENU_JUNK_ARMOR_HEADER= zo_strformat(GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ARMOR), 1),
    SI_PA_MENU_JUNK_JEWELRY_HEADER = zo_strformat(GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRY), 1),
}

for key, value in pairs(PAJStrings) do
    SafeAddString(_G[key], value, 1)
end