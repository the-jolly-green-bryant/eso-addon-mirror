local PAC = PersonalAssistant.Constants
local PAStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- Profile Settings --
    SI_PA_MENU_PROFILE_PLEASE_SELECT = "<プロファイルを選択してください>",
    SI_PA_MENU_PROFILE_ACTIVE = "有効なプロファイル",
    SI_PA_MENU_PROFILE_ACTIVE_T = "PersonalAssistantで有効にするプロファイルを選択します。選択されたプロファイルに保存されているすべての設定が自動的に読み込まれ、変更も同じ場所に保存されます。",
    SI_PA_MENU_PROFILE_ACTIVE_RENAME = "有効なプロファイルの名前を変更",

    -- Create Profiles --
    SI_PA_MENU_PROFILE_CREATE_NEW = "新規プロファイル作成",
    SI_PA_MENU_PROFILE_CREATE_NEW_DESC = table.concat({"注意: 作成できるプロファイルは最大 ", PAC.GENERAL.MAX_PROFILES, " 個までです。"}),

    -- Copy Profiles --
    SI_PA_MENU_PROFILE_COPY_FROM_DESC = "既存のプロファイルから現在のアクティブなプロファイルに設定をコピーします。",
    SI_PA_MENU_PROFILE_COPY_FROM = "プロファイルからコピー",
    SI_PA_MENU_PROFILE_COPY_FROM_CONFIRM = "コピーを確認",
    SI_PA_MENU_PROFILE_COPY_FROM_CONFIRM_W = "これにより、アクティブなプロファイルの設定が選択したプロファイルの設定で上書きされます。本当に実行しますか？ \n\n注意: 有効化されているPersonalAssistantモジュールの設定のみがコピーされます。",

    -- Delete Profiles --
    SI_PA_MENU_PROFILE_DELETE_DESC = "データベースから使用されていない既存のプロファイルを削除して容量を節約し、SavedVariablesファイルをクリーンアップします。",
    SI_PA_MENU_PROFILE_DELETE = "プロファイルの削除",
    SI_PA_MENU_PROFILE_DELETE_CONFIRM = "削除を確認",
    SI_PA_MENU_PROFILE_DELETE_CONFIRM_W = "これにより、すべてのキャラクターで選択したプロファイルが削除されます。本当に実行しますか？",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Rules Menu --
    SI_PA_MENU_RULES_HOW_TO_ADD_PAB = "アイテムの預け入れ・引き出し用の新しいルールを作成するには、インベントリまたは銀行にあるアイテムを右クリックし、コンテキストメニューから以下を選択します:\n> PA Banking > 新しいルールを追加",
    SI_PA_MENU_RULES_HOW_TO_ADD_PAJ = "アイテムを永久にガラクタとしてマークする新しいルールを作成するには、インベントリまたは銀行にあるアイテムを右クリックし、コンテキストメニューから以下を選択します:\n> PA Junk > 永久にガラクタとしてマーク",
    SI_PA_MENU_RULES_HOW_TO_FIND_MENU = table.concat({"有効なすべてのルールは、[Alt]キーで開くトップメインメニューのアイコン、チャットコマンド ", PAC.COLOR.YELLOW:Colorize("/parules"), "、またはこのボタンをクリックして確認できます:"}),
    SI_PA_MENU_RULES_HOW_TO_CREATE = "新しいルールの作成方法",

    SI_PA_MENU_DANGEROUS_SETTING = "警告: 危険な設定です！自己責任で使用してください！",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Generic Menu --
    SI_PA_MENU_OTHER_SETTINGS_HEADER = "その他の設定",

    SI_PA_MENU_SILENT_MODE = "サイレントモード (すべてのチャットメッセージを非表示)",

    SI_PA_MENU_NOT_YET_IMPLEMENTED = table.concat({PAC.COLORS.RED, "未実装です！"}),


    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAGeneral --
    SI_PA_CHAT_GENERAL_NEW_PROFILE_CREATED = table.concat({" 新しいプロファイル ", PAC.COLOR.WHITE:Colorize("%s"), " が作成され、有効化されました！"}),
    SI_PA_CHAT_GENERAL_SELECTED_PROFILE_COPIED = table.concat({" プロファイル ", PAC.COLOR.WHITE:Colorize("%s"), " の設定が、アクティブなプロファイル ", PAC.COLOR.WHITE:Colorize("%s"), " に", PAC.COLOR.ORANGE_RED:Colorize("コピー"), "されました。"}),
    SI_PA_CHAT_GENERAL_SELECTED_PROFILE_DELETED = table.concat({" 選択されたプロファイル ", PAC.COLOR.WHITE:Colorize("%s"), " が", PAC.COLOR.ORANGE_RED:Colorize("削除されました！")}),

    SI_PA_CHAT_GENERAL_TELEPORT_NO_PRIMARY_HOUSE = table.concat({"最初に家を ", PAC.COLOR.ORANGE_RED:Colorize("主要な家"), " として選択する必要があります"}),
    SI_PA_CHAT_GENERAL_TELEPORT_ZONE_PREVENTED = table.concat({"現在のエリアからは、家へのファストトラベルが ", PAC.COLOR.ORANGE_RED:Colorize("許可されていません")}),


    -- =================================================================================================================
    -- == OTHER STRINGS FOR MENU == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAGeneral --
    SI_PA_PROFILE = "プロファイル",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Name Spaces --
    SI_PA_NS_BAG_EQUIPMENT = "", -- not required so far
    SI_PA_NS_BAG_BACKPACK = "バッグ",
    SI_PA_NS_BAG_BANK = "銀行",
    SI_PA_NS_BAG_SUBSCRIBER_BANK = "ESO Plus銀行",
    SI_PA_NS_BAG_VIRTUAL = "生産バッグ",
    SI_PA_NS_BAG_HOUSE_BANK = "収納箱",
    SI_PA_NS_BAG_HOUSE_BANK_NR = "収納箱 (%d)",
    SI_PA_NS_BAG_UNKNOWN = "不明",

    -- -----------------------------------------------------------------------------------------------------------------
    -- ItemTypes (Custom Singluar/Plural definition) --
    SI_PA_ITEMTYPE4 = "<<1[食料/食料]>>",
    SI_PA_ITEMTYPE5 = "<<1[トロフィー/トロフィー]>>",
    SI_PA_ITEMTYPE7 = "<<1[ポーション/ポーション]>>",
    SI_PA_ITEMTYPE8 = "<<1[モチーフ/モチーフ]>>",
    SI_PA_ITEMTYPE10 = "<<1[材料/材料]>>",
    SI_PA_ITEMTYPE12 = "<<1[飲料/飲料]>>",
    SI_PA_ITEMTYPE16 = "<<1[餌/餌]>>",
    SI_PA_ITEMTYPE19 = "<<1[ソウルジェム/ソウルジェム]>>",
    SI_PA_ITEMTYPE22 = "<<1[ロックピック/ロックピック]>>",
    SI_PA_ITEMTYPE29 = "<<1[レシピ/レシピ]>>",
    SI_PA_ITEMTYPE30 = "<<1[毒/毒]>>",
    SI_PA_ITEMTYPE33 = "<<1[溶媒/溶媒]>>",
    SI_PA_ITEMTYPE34 = "<<1[コレクション/コレクション]>>",
    SI_PA_ITEMTYPE47 = "<<1[同盟戦争修理キット/同盟戦争修理キット]>>",
    SI_PA_ITEMTYPE56 = "<<1[財宝/財宝]>>",
    SI_PA_ITEMTYPE60 = "<<1[マスター依頼/マスター依頼]>>",

    -- -----------------------------------------------------------------------------------------------------------------
    -- SpecializedItemTypes (Custom Singluar/Plural definition) --
    SI_PA_SPECIALIZEDITEMTYPE102 = "<<1[断片/断片]>>",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Master Writs based on CraftingType (Custom definition) --
    SI_PA_MASTERWRIT_CRAFTINGTYPE0 = table.concat({"その他の依頼 (", GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_OTHER), ")"}),
    SI_PA_MASTERWRIT_CRAFTINGTYPE1 = "封印された鍛冶の依頼",
    SI_PA_MASTERWRIT_CRAFTINGTYPE2 = "封印された仕立ての依頼",
    SI_PA_MASTERWRIT_CRAFTINGTYPE3 = "封印された付呪の依頼",
    SI_PA_MASTERWRIT_CRAFTINGTYPE4 = "封印された錬金術の依頼",
    SI_PA_MASTERWRIT_CRAFTINGTYPE5 = "封印された調理の依頼",
    SI_PA_MASTERWRIT_CRAFTINGTYPE6 = "封印された木工の依頼",
    SI_PA_MASTERWRIT_CRAFTINGTYPE7 = "封印されたジュエリーの依頼",

    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking --
    SI_PA_BANKING_MOVE_MODE_DONOTHING = "何もしない",
    SI_PA_BANKING_MOVE_MODE_TOBANK = "銀行へ預ける",
    SI_PA_BANKING_MOVE_MODE_TOBACKPACK = "バッグへ取り出す",

    SI_PA_MENU_BANKING_ADVANCED_GLYPHS = "グリフ",
    SI_PA_MENU_BANKING_ADVANCED_INTRICATE_ITEMS = "複雑アイテム",
    SI_PA_MENU_BANKING_ADVANCED_ORNATE_ITEMS = "装飾アイテム",

    SI_PA_MENU_BANKING_REPAIRKIT = "修理キット",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Operators --
    SI_PA_REL_OPERATOR_T = "このアイテムの数学演算子を選択します",
    SI_PA_REL_BACKPACK_EQUAL = "バッグ数量 ==",
    SI_PA_REL_BACKPACK_LESSTHAN = "バッグ数量 <", -- not used so far
    SI_PA_REL_BACKPACK_LESSTHANEQUAL = "バッグ数量 <=",
    SI_PA_REL_BACKPACK_GREATERTHAN = "バッグ数量 >", -- not used so far
    SI_PA_REL_BACKPACK_GREATERTHANEQUAL = "バッグ数量 >=",
    SI_PA_REL_BANK_EQUAL = "銀行数量 ==",
    SI_PA_REL_BANK_LESSTHAN = "銀行数量 <", -- not used so far
    SI_PA_REL_BANK_LESSTHANOREQUAL = "銀行数量 <=",
    SI_PA_REL_BANK_GREATERTHAN = "銀行数量 >", -- not used so far
    SI_PA_REL_BANK_GREATERTHANOREQUAL = "銀行数量 >=",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Operator Tooltip --
    SI_PA_REL_BACKPACK_EQUAL_T = "バッグ数量が等しい (==)",
    SI_PA_REL_BACKPACK_LESSTHAN_T = "バッグ数量が未満 (<)", -- not used so far
    SI_PA_REL_BACKPACK_LESSTHANOREQUAL_T = "バッグ数量が以下 (<=)",
    SI_PA_REL_BACKPACK_GREATERTHAN_T = "バッグ数量が超える (>)", -- not used so far
    SI_PA_REL_BACKPACK_GREATERTHANOREQUAL_T = "バッグ数量が以上 (>=)",
    SI_PA_REL_BANK_EQUAL_T = "銀行数量が等しい (==)",
    SI_PA_REL_BANK_LESSTHAN_T = "銀行数量が未満 (<)", -- not used so far
    SI_PA_REL_BANK_LESSTHANOREQUAL_T = "銀行数量が以下 (<=)",
    SI_PA_REL_BANK_GREATERTHAN_T = "銀行数量が超える (>)", -- not used so far
    SI_PA_REL_BANK_GREATERTHANOREQUAL_T = "銀行数量が以上 (>=)",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Text Operators --
    SI_PA_REL_TEXT_OPERATOR0 = "-",
    SI_PA_REL_TEXT_OPERATOR1 = "数量がぴったり",
    SI_PA_REL_TEXT_OPERATOR2 = "数量が未満", -- not used so far
    SI_PA_REL_TEXT_OPERATOR3 = "数量が最大でも",
    SI_PA_REL_TEXT_OPERATOR4 = "数量が超える", -- not used so far
    SI_PA_REL_TEXT_OPERATOR5 = "数量が少なくとも",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Stacking types --
    SI_PA_ST_MOVE_FULL = "すべて移動する", -- 0: Full deposit
    SI_PA_ST_MOVE_INCOMPLETE_STACKS_ONLY = "既存のスタックのみを補充する", -- 1: Fill existing stacks
    SI_PA_ST_MOVE_ONE_STACK_ONLY = "アイテムごとに1スタックまでに制限する", -- 2: Deposit to the limit of one stack

    -- -----------------------------------------------------------------------------------------------------------------
    -- Icon Positions --
    SI_PA_POSITION_AUTO = "自動",
    SI_PA_POSITION_MANUAL = "手動",

    -- -----------------------------------------------------------------------------------------------------------------
    -- PAJunk --
    SI_PA_ITEM_ACTION_NOTHING = "何もしない",
    SI_PA_ITEM_ACTION_LAUNDER = "盗品商で洗浄", -- not used so far
    SI_PA_ITEM_ACTION_MARK_AS_JUNK = "ガラクタとしてマーク",
    SI_PA_ITEM_ACTION_JUNK_DESTROY_WORTHLESS = "ガラクタとしてマーク、または価値がなければ破壊",
    SI_PA_ITEM_ACTION_DESTROY_ALWAYS = "常に破壊",


    -- =================================================================================================================
    -- == CUSTOM SUB MENU == --
    -- -----------------------------------------------------------------------------------------------------------------
    SI_PA_SUBMENU_PAB_ADD_RULE = "新しいルールを追加",
    SI_PA_SUBMENU_PAB_EDIT_RULE = "ルールを変更",
    SI_PA_SUBMENU_PAB_DELETE_RULE = "ルールを削除",
    SI_PA_SUBMENU_PAB_ENABLE_RULE = "ルールを有効化",
    SI_PA_SUBMENU_PAB_DISABLE_RULE = "ルールを無効化",
    SI_PA_SUBMENU_PAB_ADD_RULE_BUTTON = "追加",
    SI_PA_SUBMENU_PAB_UPDATE_RULE_BUTTON = "保存",
    SI_PA_SUBMENU_PAB_DELETE_RULE_BUTTON = "削除",
    SI_PA_SUBMENU_PAB_NO_RULES = "銀行ルールがまだ定義されていません",
    SI_PA_SUBMENU_PAB_DISCLAIMER = "免責事項: これらのカスタム銀行ルールは、他のすべての自動銀行ルール (クラフト、特別、および同盟戦争アイテム) が先に実行された後に処理されます。",

    SI_PA_SUBMENU_PAJ_MARK_PERM_JUNK = "永久にガラクタとしてマーク",
    SI_PA_SUBMENU_PAJ_UNMARK_PERM_JUNK = "永久なガラクタとしてのマークを解除",
    SI_PA_SUBMENU_PAJ_NO_RULES = "永久的なガラクタルールがまだ定義されていません",


    -- =================================================================================================================
    -- == KEY BINDINGS == --
    -- -----------------------------------------------------------------------------------------------------------------
    SI_KEYBINDINGS_CATEGORY_PA_PROFILES = "|cFFD700P|rersonal|cFFD700A|rssistant プロファイル",
    SI_KEYBINDINGS_CATEGORY_PA_MENU = "|cFFD700P|rersonal|cFFD700A|rssistant メニュー",

    SI_BINDING_NAME_PA_RULES_MAIN_MENU = "PersonalAssistant ルール",
    SI_BINDING_NAME_PA_RULES_TOGGLE_WINDOW = "銀行/ガラクタルールメニューの表示切り替え",
    SI_BINDING_NAME_PA_TRAVEL_TO_HOUSE = "主要な家にトラベルする",
}

for key, value in pairs(PAStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end