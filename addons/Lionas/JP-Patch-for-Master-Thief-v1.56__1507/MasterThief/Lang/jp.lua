---------------------------------------------
-- Japanese localization for MasterThief
---------------------------------------------
-- translated by Lionas

local localization_strings = {
	-- settings panel name
	MASTER_THIEF_NAME = "Master Thief",
	
	-- options checkboxes
	MASTER_THIEF_TEXT = "Master Thief全体を有効または無効にする",
	MT_SNEAK_MODE_NAME = "こそ泥モード",
	MT_SNEAK_MODE_TEXT = "有効だが隠れていない場合にセーフティーネットのように動作します。そのため、自動アイテム取得なしに全ての箱を調査することができます（現金箱を除く）。これはガードがあなたの周りにいる場合や盗めそうな何かを自動取得なしでただ覗きたい場合に便利です。こそ泥モードで自動取得が有効になっていてこの設定を完全にオフにしている場合は盗みます。",
	MT_SHOW_MESSAGEBOX_NAME = "メッセージフレームを表示する",
	MT_SHOW_MESSAGEBOX_TEXT = "移動と配置を許可するためスクリーンにメッセージフレームを表示することを強制します",
	MT_EXCLUDE_COMPARE_NAME = "自身のレシピの知識を共有する",
	MT_EXCLUDE_COMPARE_TEXT = "このオプションは他のキャラクターとの比較のために、あなたが知っている使用可能なレシピを作成します。無効にしている場合、他のプレイヤーキャラクターが知っているレシピが、このオプションを有効にしレシピの知識を共有するまで調査・比較され続けます。",
	MT_LOOT_UNKNOWN_RECIPES_NAME = "知らないレシピの取得を略奪する",
	MT_LOOT_UNKNOWN_RECIPES_TEXT = "品質のレベルに関わらず全ての不明なレシピを略奪する。オフにしている場合、設定している品質レベルかそれより高い場合のみ自動取得します。",
	MT_AUTOLOOT_FROM_LOOTLIST_NAME = "自動取得の略奪リスト",	
	MT_AUTOLOOT_FROM_LOOTLIST_TEXT = "アクティベートしている場合、略奪リストのアイテムを自動的に取得します。",
	
	-- options slider
	MT_MESSAGE_DELAY_NAME = "メッセージ遅延",
	MT_MESSAGE_DELAY_TEXT = "オンスクリーンのメッセージ遅延をミリ秒で設定します。1000単位 = 1秒です。",
	MT_FREE_SLOTS_LEFT_LIMIT_NAME = "警告するバッグの空きスロット閾値",
	MT_FREE_SLOTS_LEFT_LIMIT_TEXT = "残りの空きスロットに関する警告メッセージを表示するための、バッグの残スロットの最小値を設定します。",
	MT_MIN_SELL_PRICE_AUTOLOOT_NAME = "自動略奪する最小売価",
	MT_MIN_SELL_PRICE_AUTOLOOT_TEXT = "盗品の自動取得が有効にするための最小売価を設定します。レシピとモチーフが対象外であることに注意してください。これらは自動取得設定の外で制御され、一般的に常に自動的に略奪されます",

	-- options dropdown
	MT_RECIPE_QUALITY_NAME = "レシピの最低品質",
	MT_RECIPE_QUALITY_TEXT = "自動略奪のためのレシピの最小品質レベルを選択します。不明なレシピは以下の与えられたレベルが明示的に許可されている場合に限り自動取得されます。",
	MT_RECIPE_COLOR_GREEN = "緑",
	MT_RECIPE_COLOR_BLUE = "青",
	MT_RECIPE_COLOR_EPIC = "叙事詩",

	-- options submenu - announcements
	MT_SUB_ANNOUNCE_NAME = "告知",
	MT_SUB_ANNOUNCE_TEXT = "全ての告知",
	MT_SUB_ANNOUNCE_ONSCREENMSG_NAME = "オンスクリーンメッセージで告知する",
	MT_SUB_ANNOUNCE_ONSCREENMSG_TEXT = "オンスクリーンメッセージでレシピとモチーフを告知する",
	MT_SUB_ANNOUNCE_SPECIALS_NAME = "チャットで特別なアイテムを告知する",
	MT_SUB_ANNOUNCE_SPECIALS_TEXT = "チャットでレシピとモチーフを告知する。あなただけがこの告知を見ることができ、他のプレイヤーには共有されません。",
	MT_SUB_ANNOUNCE_REGULAR_NAME = "チャットに情報を告知する",
	MT_SUB_ANNOUNCE_REGULAR_TEXT = "ガード/洗浄に支払った額、売却したアイテム、賞金などのような情報をチャットに告知する",	
	MT_SUB_ANNOUNCE_USELESS_NAME = "ジャンクアイテムを告知する",
	MT_SUB_ANNOUNCE_USELESS_TEXT = "最低自動略奪価格制限によって定義されたジャンクアイテムを告知します。これらのアイテムは /mt_junk コマンドで一覧表示することができます。レシピとモチーフは含まれません。",
	MT_SUB_ANNOUNCE_BECAREFUL_NAME = "スニーク中に \"注意\" を告知する",
	MT_SUB_ANNOUNCE_BECAREFUL_TEXT = "完全に隠れるのにNPCの距離が十分でないために \"注意\" メッセージを表示します。これは完全に隠れて盗むことを助けるでしょう",	
	MT_SUB_ANNOUNCE_KNOWN_RECIPES_NAME = "既知のレシピを告知する",
	MT_SUB_ANNOUNCE_KNOWN_RECIPES_TEXT = "チャットに既知のレシピを略奪することのメッセージを表示する",	
	MT_SUB_ANNOUNCE_SELLS_TRANSFERS_NAME = "チャットに盗品/洗浄アイテムを告知する",
	MT_SUB_ANNOUNCE_SELLS_TRANSFERS_TEXT = "チャットに盗品売却と洗浄の取引に関するメッセージを表示する",	
	MT_SUB_ANNOUNCE_MAX_FENCER_LIMITS_NAME = "盗品商の制限を告知する",
	MT_SUB_ANNOUNCE_MAX_FENCER_LIMITS_TEXT = "盗品売却と洗浄の日制限に達した時にチャットにメッセージを表示する",

	-- Binding-Names
	MT_BIND_ONOFF_TEXT = "オン/オフをトグル",
	MT_BIND_TOGGLE_SNEAKMODE_TEXT = "こそ泥モードをトグル",		
	MT_BIND_SHOW_STATISTIC_TEXT = "統計を表示",	
	MT_BIND_SHOW_USELESS_TEXT = "ジャンクアイテムを表示",
	MT_BIND_TOGGLE_ATTACK_INNOCENTS_TEXT = "一般市民への攻撃をトグル",
	MT_BIND_TOGGLE_LOOTLIST_TEXT = "略奪リストを表示",

	-- Misc Text
	MT_MISC_TRASH_TEXT = "ジャンク: ",
	MT_MISC_SOLD_FOR = " 売る: ",
	MT_MISC_BOUNTY_IS = "賞金は ",
	MT_MISC_BOUNTY_REMOVED_FROM_BODY = "あなたの死体から全ての賞金が消えた!",
	MT_MISC_ALL_STOLEN_ITEMS_REMOVED = "ガードによって全ての盗品が除去されました!",
	MT_MISC_YOU_PAID_BOUNTY = "賞金を払いました: ",
	MT_MISC_YOU_SOLD_AN_ITEM_FOR = "盗品を売りました: ",
	MT_MISC_SNEAKMODE_ACTIVE = "こそ泥がアクティブ",
	MT_MISC_SNEAKMODE_SLEEPING = "こそ泥が非アクティブ",
	MT_MISC_BE_CAREFUL = "注意!",
	MT_MISC_MASTERTHIEF_OFF = "MasterThiefはオフです",
	MT_MISC_SNEAKMODE_ON = "スニークモードはオンです",
	MT_MISC_SNEAKMODE_OFF = "スニークモードはオフです",
	MT_MISC_IS_KNOWN = "既に知っています: ",
	MT_MISC_FREE_SLOTS_LEFT = "残りの空きスロット: ",
	MT_MISC_SELL_MAXIMUM_REACHED = "1日の最大売却数に達しました!",
	MT_MISC_TRANSFER_MAXIMUM_REACHED = "1日の最大洗浄数に達しました!",
	MT_MISC_ITEM_DESTROYED = "...破壊しました!",
	MT_MISC_LIST_USELESS_ITEMS = "ジャンクアイテムのリスト: ",
	MT_MISC_USELESS_ITEMS_FOUND = "ジャンクアイテムが見つかりました: ",
	MT_MISC_TYPE_COMMAND_DESTROY_ITEM = "これらを破壊するには /mt_junk を入力します",
	MT_MISC_NO_ITEMS_FOUND = "破壊するアイテムが見つかりません",
	MT_MISC_ITEMS_BELOW_VALUE_USELESS = "この売価以下のアイテムはジャンクです: ",
	MT_MISC_FOUND_ALOT_GOLD_TEXT = "ゴールドを略奪した。盗んだ: ",
	MT_MISC_ITS_KNOWN_BUT_WANTED_TEXT = "知っているが略奪した: ",

	-- Text for statistic on chat
	MT_MISC_HEADER_STATISTIC = "------ MasterThief 統計 ------",
	MT_MISC_STOLEN_VALUES_IN_BAG = "バッグ中の盗品の価値:",
	MT_MISC_STOLEN_VALUES_SOLD = "売却した盗品の価値:",
	MT_MISC_BOUNTY_PAID = "支払った賞金:",
	MT_MISC_ACCOUNT_TOTAL = "口座残高の合計:",
	MT_MISC_SELLS_MADE_TODAY = "今日売却した盗品アイテム:",
	MT_MISC_TRANSFERS_MADE_TODAY = "今日洗浄したアイテム:",

	--Text for command list on chat
	MT_MISC_MASTERTHIEF_COMMANDS = "MasterThief コマンド:",
	MT_MISC_MASTERTHIEF_LISTCOMMANDS = "全てのチャットコマンドを一覧表示する",
	MT_MISC_CMD_LIST_ALL_USELESS_ITEMS = "全てのジャンクアイテムを一覧表示する",
	MT_MISC_CMD_DESTROY_ALL_USELESS_ITEMS = "全てのジャンクアイテムを破壊する",
	MT_MISC_CMD_RESET_ALL_VALUES = "全ての価値/賞金をリセットする",
	MT_MISC_SYSTEM_ATTACK_INNOCENTS_OFF = "一般市民への攻撃はオフです",
	MT_MISC_SYSTEM_ATTACK_INNOCENTS_ON = "一般市民への攻撃はオンです",
	
	--Text for recipe/searchpool actions
	MT_MISC_RECIPES_ADDED_TO_SEARCHPOOL = " 比較のために共有されたレシピ",
	MT_MISC_RECIPES_REMOVED_FROM_SEARCHPOOL = " 比較のために共有されなかったレシピ",
	
	--Text for recipe tooltip
	MT_MISC_TOOLTIP_RECIPE_CHARS = "このレシピは知られています:",

	--Text for Lootlist
	MT_MISC_LOOTLIST_DELETE = " 略奪リストから除去された",
	MT_MISC_ITEM_ADDED = " 略奪リストに追加された",
	MT_MISC_ITEM_ALREADY_ON_LOOTLIST = "アイテムは既に略奪リストに含まれています",
	MT_MISC_WORTHFUL_ITEMS = "興味のあるアイテムの略奪リスト",
	MT_MISC_ITEM_TOOLTIP = "アイテムは略奪リストに含まれています",
	
	-- Text for Context-Menu
	MT_CONTEXTMENU_LOOT_MARK = "自動取得のためにマークする",	
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end