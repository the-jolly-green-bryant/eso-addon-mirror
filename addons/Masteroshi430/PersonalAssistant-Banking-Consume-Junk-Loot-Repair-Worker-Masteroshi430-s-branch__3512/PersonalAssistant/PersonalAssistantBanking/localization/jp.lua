local PAC = PersonalAssistant.Constants
local PABStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking Menu --
    SI_PA_MENU_BANKING_DESCRIPTION = "PABankingは、キャラクターのバックパックと銀行の間で、通貨、生産素材、その他のアイテムを移動させることができます",

    -- Currencies --
    SI_PA_MENU_BANKING_CURRENCY_HEADER = GetString(SI_INVENTORY_CURRENCIES),
    SI_PA_MENU_BANKING_CURRENCY_ENABLE = table.concat({GetString(SI_INVENTORY_CURRENCIES), "の自動銀行機能を有効にする"}),
    SI_PA_MENU_BANKING_CURRENCY_MINTOKEEP = "キャラクターに保持する最小額",
    SI_PA_MENU_BANKING_CURRENCY_MAXTOKEEP = "キャラクターに保持する最大額",

    -- Crafting Items --
    SI_PA_MENU_BANKING_CRAFTING_HEADER = "生産アイテム",
    SI_PA_MENU_BANKING_CRAFTING_ENABLE = "生産アイテムの自動銀行機能を有効にする",
    SI_PA_MENU_BANKING_CRAFTING_ENABLE_T = "各種生産アイテムの自動銀行預け入れ・引き出しを有効にしますか？",
    SI_PA_MENU_BANKING_CRAFTING_DESCRIPTION = "生産アイテムごとに個別の動作（預ける、引き出す、何もしない）を設定します",
    SI_PA_MENU_BANKING_CRAFTING_ESOPLUS_DESC = "ESO Plus会員の場合、すべての生産素材はクラフトバッグに無限に収納できるため、生産素材の預け入れ/引き出しは不要です",
    SI_PA_MENU_BANKING_CRAFTING_GLOBAL_MOVEMODE = "上記のすべての生産アイテムのドロップダウンを以下に変更",
    SI_PA_MENU_BANKING_CRAFTING_GLOBAL_MOVEMODE_T = "上記のすべての生産アイテムのドロップダウンの値を「銀行に預ける」、「バックパックに引き出す」、「何もしない」に一括変更します",

    -- Advanced Items --
    SI_PA_MENU_BANKING_ADVANCED_HEADER = "特殊アイテム",
    SI_PA_MENU_BANKING_ADVANCED_ENABLE = "特殊アイテムの自動銀行機能を有効にする",
    SI_PA_MENU_BANKING_ADVANCED_ENABLE_T = "各種特殊アイテムの自動銀行預け入れ・引き出しを有効にしますか？",
    SI_PA_MENU_BANKING_ADVANCED_DESCRIPTION = "特殊アイテムごとに個別の動作（預ける、引き出す、何もしない）を設定します",

    SI_PA_MENU_BANKING_ADVANCED_GLOBAL_MOVEMODE = "上記のすべての特殊アイテムのドロップダウンを以下に変更",
    SI_PA_MENU_BANKING_ADVANCED_GLOBAL_MOVEMODE_T = "上記のすべての特殊アイテムのドロップダウンの値を「銀行に預ける」、「バックパックに引き出す」、「何もしない」に一括変更します",

    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE8 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " 既知のモチーフ"}), 
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE29 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " 既知のレシピ"}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE3200 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " 既知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY)}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE3250 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " 既知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_PRIMARY)}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE3251 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " 既知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_SECONDARY)}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE3252 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " 既知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_TERTIARY)}),
	
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE171 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " 既知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK)}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE170 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " 既知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD)}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE177 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " 既知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING)}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE175 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " 既知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING)}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE172 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " 既知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING)}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE173 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " 既知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING)}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE174 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " 既知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING)}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE178 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " 既知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING)}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE176 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " 既知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING)}),
	
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_STYLE_PAGE = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " 既知のスタイルページ"}),
	
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE8 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " 未知のモチーフ"}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE29 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " 未知のレシピ"}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE3200 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " 未知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY)}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE3250 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " 未知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_PRIMARY)}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE3251 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " 未知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_SECONDARY)}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE3252 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " 未知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_TERTIARY)}),
	
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE171 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " 未知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK)}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE170 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " 未知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD)}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE177 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " 未知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING)}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE175 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " 未知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING)}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE172 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " 未知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING)}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE173 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " 未知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING)}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE174 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " 未知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING)}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE178 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " 未知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING)}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE176 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " 未知の", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING)}),
	
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_STYLE_PAGE = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " 未知のスタイルページ"}),

    -- Individual Items --
    SI_PA_MENU_BANKING_INDIVIDUAL_HEADER = "個別アイテム",
    SI_PA_MENU_BANKING_INDIVIDUAL_DISABLED_DESCRIPTION = table.concat({"カスタム銀行ルールの導入に伴い、「個別」設定はそちらに移行されました。 ", GetString(SI_PA_MENU_RULES_HOW_TO_ADD_PAB), "\n\n", GetString(SI_PA_MENU_RULES_HOW_TO_FIND_MENU)}),

    -- AvA Items --
    SI_PA_MENU_BANKING_AVA_HEADER = "対人戦（AvA）アイテム",
    SI_PA_MENU_BANKING_AVA_ENABLE = "対人戦アイテムの自動銀行機能を有効にする",
    SI_PA_MENU_BANKING_AVA_ENABLE_T = "各種同盟戦争（AvA）アイテムの自動銀行預け入れ・引き出しを有効にしますか？",
    SI_PA_MENU_BANKING_AVA_DESCRIPTION = "インベントリに保持したい各種同盟戦争（AvA）アイテムの数量を設定します",
    SI_PA_MENU_BANKING_AVA_OTHER_HEADER = "その他",

    -- Other Settings --
    SI_PA_MENU_BANKING_AUTO_ITEM_TRANSFER_EXECUTION = "PABankingのアイテム自動転送を実行",
    SI_PA_MENU_BANKING_AUTO_ITEM_TRANSFER_EXECUTION_T = "銀行アクセス時にバックパックと銀行の間ですべてのアイテム転送を自動的に実行しますか？オフにしている場合でも、銀行画面から手動でPABankingのアイテム転送を実行できます",

    SI_PA_MENU_BANKING_OTHER_DEPOSIT_STACKING = "預け入れ時のスタックルール",
    SI_PA_MENU_BANKING_OTHER_DEPOSIT_STACKING_T = "すべてのアイテムを預けるか、既存のスタックを完了できる場合のみ預けるか、またはアイテム1スタック制限まで預けるかを設定します",
    SI_PA_MENU_BANKING_OTHER_WITHDRAWAL_STACKING = "引き出し時のスタックルール",
    SI_PA_MENU_BANKING_OTHER_WITHDRAWAL_STACKING_T = "すべてのアイテムを引き出すか、既存のスタックを完了できる場合のみ引き出すか、またはアイテム1スタック制限まで引き出すかを設定します",

    SI_PA_MENU_BANKING_EXCLUDE_JUNK = "ジャンクとしてマークされたアイテムは移動しない",

    SI_PA_MENU_BANKING_OTHER_AUTOSTACKBAGS = "銀行を開いたときにすべてのアイテムを自動スタック",
    SI_PA_MENU_BANKING_OTHER_AUTOSTACKBAGS_T = "銀行にアクセスした際、銀行とバックパック内のすべてのアイテムを自動的にスタックしますか？整理整頓に役立ちます",

    -- Generic definitions for any type --
    SI_PA_MENU_BANKING_ANY_CURRENCY_ENABLE = "%s の預け入れ/引き出し",

    SI_PA_MENU_BANKING_ANY_KEEPINBACKPACK = "保持する数量",
    SI_PA_MENU_BANKING_ANY_KEEPINBACKPACK_T = "（数式演算子に基づいて）銀行またはバックパックに保持する数量を設定します",

    SI_PA_MENU_BANKING_ANY_MINTOKEEP_T = "キャラクターに常に保持する %s の最小数量。必要に応じて銀行から追加で引き出されます",
    SI_PA_MENU_BANKING_ANY_MAXTOKEEP_T = "キャラクターに常に保持する %s の最大数量。この数量を超える分はすべて銀行に預け入れられます",

    SI_PA_MENU_BANKING_ANY_GLOBAL_MOVEMODE_W = "この操作は取り消せません。個別に選択されたすべての値が失われます",


    -- =================================================================================================================
    -- == MAIN MENU TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking --
    SI_PA_MAINMENU_BANKING_HEADER = "銀行ルール",

    SI_PA_MAINMENU_BANKING_HEADER_CATEGORY = "C", -- First letter of "Category" (※日本語表示スペースの都合上「C」のまま維持)
    SI_PA_MAINMENU_BANKING_HEADER_BAG = "保管場所",
    SI_PA_MAINMENU_BANKING_HEADER_RULE = "ルール",
    SI_PA_MAINMENU_BANKING_HEADER_AMOUNT = "数量",
    SI_PA_MAINMENU_BANKING_HEADER_ITEM = "アイテム",
    SI_PA_MAINMENU_BANKING_HEADER_ACTIONS = "アクション",


    -- =================================================================================================================
    -- == OTHER STRINGS FOR MENU == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking Add Custom Rule Description --
    SI_PA_DIALOG_BANKING_BANK_EXACTLY_PRE = "%s に選択したアイテムがちょうど %d 個ある状態にする必要があります。",
    SI_PA_DIALOG_BANKING_BANK_LESSTHANOREQUAL_PRE = "%s に選択したアイテムが最大でも %d 個ある状態にする必要があります。",
    SI_PA_DIALOG_BANKING_BANK_GREATERTHANOREQUAL_PRE = "%s に選択したアイテムが最低でも %d 個ある状態にする必要があります。",
    SI_PA_DIALOG_BANKING_BANK_EXACTLY_NOTHING = "> %s 内に %d 個 => 何もしない。",
    SI_PA_DIALOG_BANKING_BANK_EXACTLY_DEPOSIT = "> %s 内に %d 個 => %s に %d 個になるまでアイテムを転送する。",
    SI_PA_DIALOG_BANKING_BANK_FROM_TO_NOTHING = "> %s 内に %d 〜 %d 個 => 何もしない。",
    SI_PA_DIALOG_BANKING_BANK_FROM_TO_DEPOSIT = "> %s 内に %d 〜 %d 個 => %s に %d 個になるまでアイテムを転送する。",
    SI_PA_DIALOG_BANKING_BANK_FROM_TO_WITHDRAW = "> %s 内に %d 〜 %d 個 => 残りが %d 個になるまで %s からアイテムを引き出す。",

    SI_PA_DIALOG_BANKING_BACKPACK_EXACTLY_PRE = "%s に選択したアイテムがちょうど %d 個ある状態にする必要があります。",
    SI_PA_DIALOG_BANKING_BACKPACK_LESSTHANOREQUAL_PRE = "%s に選択したアイテムが最大でも %d 個ある状態にする必要があります。",
    SI_PA_DIALOG_BANKING_BACKPACK_GREATERTHANOREQUAL_PRE = "%s に選択したアイテムが最低でも %d 個ある状態にする必要があります。",
    SI_PA_DIALOG_BANKING_BACKPACK_EXACTLY_NOTHING = "> %s 内に %d 個 => 何もしない。",
    SI_PA_DIALOG_BANKING_BACKPACK_EXACTLY_DEPOSIT = "> %s 内に %d 個 => %s に %d 個になるまでアイテムを転送する。",
    SI_PA_DIALOG_BANKING_BACKPACK_FROM_TO_NOTHING = "> %s 内に %d 〜 %d 個 => 何もしない。",
    SI_PA_DIALOG_BANKING_BACKPACK_FROM_TO_DEPOSIT = "> %s 内に %d 〜 %d 個 => %s に %d 個になるまでアイテムを転送する。",
    SI_PA_DIALOG_BANKING_BACKPACK_FROM_TO_WITHDRAW = "> %s 内に %d 〜 %d 個 => 残りが %d 個になるまで %s からアイテムを引き出す。",

    SI_PA_DIALOG_BANKING_EXPLANATION = "つまり、もしあなたが以下を所持している場合...",


    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking --
    SI_PA_CHAT_BANKING_FINISHED = "すべてのアイテム転送が完了しました",

    SI_PA_CHAT_BANKING_WITHDRAWAL_COMPLETE = "%s を引き出しました",
    SI_PA_CHAT_BANKING_WITHDRAWAL_PARTIAL_SOURCE = "%s / %s を引き出しました (銀行が空です)",
    SI_PA_CHAT_BANKING_WITHDRAWAL_PARTIAL_TARGET = "%s / %s を引き出しました (キャラクターの空き容量が不足しています)",

    SI_PA_CHAT_BANKING_DEPOSIT_COMPLETE = "%s を預け入れました",
    SI_PA_CHAT_BANKING_DEPOSIT_PARTIAL_SOURCE = "%s / %s を預け入れました (キャラクターのバックパックが空です)",
    SI_PA_CHAT_BANKING_DEPOSIT_PARTIAL_TARGET = "%s / %s を預け入れました (銀行の空き容量が不足しています)",

    SI_PA_CHAT_BANKING_ITEMS_MOVED_COMPLETE = "%d x %s を %s に移動しました",
    SI_PA_CHAT_BANKING_ITEMS_NOT_MOVED_OUTOFSPACE = "%s を %s に移動できませんでした。空き容量が不足しています！",
    SI_PA_CHAT_BANKING_ITEMS_NOT_MOVED_BANKCLOSED = "%s を %s に移動できませんでした。ウィンドウが閉じられました！",
    SI_PA_CHAT_BANKING_ITEMS_SKIPPED_LWC = "Dolgubon's Lazy Writ Crafterとの干渉を避けるため、一部のアイテムは預け入れされませんでした",

    SI_PA_CHAT_BANKING_RULES_ADDED = table.concat({"%s のルールが", PAC.COLOR.ORANGE:Colorize("追加"), "されました！"}),
    SI_PA_CHAT_BANKING_RULES_UPDATED = table.concat({"%s のルールが", PAC.COLOR.ORANGE:Colorize("更新"), "されました！"}),
    SI_PA_CHAT_BANKING_RULES_DELETED = table.concat({"%s のルールが", PAC.COLOR.ORANGE:Colorize("削除"), "されました！"}),
    SI_PA_CHAT_BANKING_RULES_ENABLED = table.concat({"%s のルールが", PAC.COLOR.ORANGE:Colorize("有効化"), "されました！"}),
    SI_PA_CHAT_BANKING_RULES_DISABLED = table.concat({"%s のルールが", PAC.COLOR.ORANGE:Colorize("無効化"), "されました！"}),


    -- =================================================================================================================
    -- == KEY BINDINGS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking --
    SI_BINDING_NAME_PA_BANKING_EXECUTE_ITEM_TRANSFERS = "PABankingを実行",
    SI_BINDING_NAME_PA_BANKING_EXECUTE_ITEM_TRANSFERS_PENDING = "PABanking実行中...",
}

for key, value in pairs(PABStrings) do
    SafeAddString(_G[key], value, 1)
end


local PABGenericStrings = {
    -- =================================================================================================================
    -- Language independent texts (do not need to be translated/copied to other languages --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking Menu --
    SI_PA_MENU_BANKING_CURRENCY_GOLD_HEADER = GetCurrencyName(CURT_MONEY),
    SI_PA_MENU_BANKING_CURRENCY_ALLIANCE_HEADER = GetCurrencyName(CURT_ALLIANCE_POINTS),
    SI_PA_MENU_BANKING_CURRENCY_TELVAR_HEADER = GetCurrencyName(CURT_TELVAR_STONES),
    SI_PA_MENU_BANKING_CURRENCY_WRIT_HEADER = GetCurrencyName(CURT_WRIT_VOUCHERS),

    SI_PA_MENU_BANKING_ADVANCED_MOTIF_HEADER = zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), 2),
    SI_PA_MENU_BANKING_ADVANCED_RECIPE_HEADER = table.concat({zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_RECIPE).."/"..GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3), 2)}),
    SI_PA_MENU_BANKING_ADVANCED_MASTER_WRITS_HEADER = zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_MASTER_WRIT), 2),
    SI_PA_MENU_BANKING_ADVANCED_HOLIDAY_WRITS_HEADER = zo_strformat("<<m:1>>", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_HOLIDAY_WRIT)),
    SI_PA_MENU_BANKING_ADVANCED_GLYPHS_HEADER = GetString(SI_PA_MENU_BANKING_ADVANCED_GLYPHS),
    SI_PA_MENU_BANKING_ADVANCED_LIQUIDS_HEADER = table.concat({zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_POTION), 2), " & ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_POISON), 2)}),
    SI_PA_MENU_BANKING_ADVANCED_FOOD_DRINKS_HEADER = table.concat({zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_FOOD), 2), " & ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_DRINK), 2)}),
    SI_PA_MENU_BANKING_ADVANCED_TROPHIES_TREASURE_MAPS_HEADER = table.concat({zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_TROPHY), 2), ": ", zo_strformat("<<m:1>>", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP)), " & ", zo_strformat("<<m:1>>", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_TRIBUTE_CLUE))}),
    SI_PA_MENU_BANKING_ADVANCED_TROPHIES_FRAGMENTS_HEADER = table.concat({zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_TROPHY), 2), ": ", zo_strformat(GetString("SI_PA_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT), 2)}),
    SI_PA_MENU_BANKING_ADVANCED_TROPHIES_SURVEY_REPORTS_HEADER = table.concat({zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_TROPHY), 2), ": ", zo_strformat("<<m:1>>", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT))}),
    SI_PA_MENU_BANKING_ADVANCED_INTRICATE_ITEMS_HEADER = GetString(SI_PA_MENU_BANKING_ADVANCED_INTRICATE_ITEMS),
    SI_PA_MENU_BANKING_ADVANCED_ORNATE_ITEMS_HEADER = GetString(SI_PA_MENU_BANKING_ADVANCED_ORNATE_ITEMS),

    SI_PA_MENU_BANKING_AVA_SIEGE_BALLISTA_HEADER = GetString("SI_SIEGETYPE", SIEGE_TYPE_BALLISTA),
    SI_PA_MENU_BANKING_AVA_SIEGE_CATAPULT_HEADER = GetString("SI_SIEGETYPE", SIEGE_TYPE_CATAPULT),
    SI_PA_MENU_BANKING_AVA_SIEGE_TREBUCHET_HEADER = GetString("SI_SIEGETYPE", SIEGE_TYPE_TREBUCHET),
    SI_PA_MENU_BANKING_AVA_SIEGE_RAM_HEADER = GetString("SI_SIEGETYPE", SIEGE_TYPE_RAM),
    SI_PA_MENU_BANKING_AVA_SIEGE_OIL_HEADER = GetString("SI_SIEGETYPE", SIEGE_TYPE_OIL),
    SI_PA_MENU_BANKING_AVA_SIEGE_GRAVEYARD_HEADER = GetString("SI_SIEGETYPE", SIEGE_TYPE_GRAVEYARD),
    SI_PA_MENU_BANKING_AVA_REPAIR_HEADER = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_AVA_REPAIR),


    -- =================================================================================================================
    -- == OTHER STRINGS FOR MENU == --
    -- -----------------------------------------------------------------------------------------------------------------
}

for key, value in pairs(PABGenericStrings) do
    SafeAddString(_G[key], value, 1)
end