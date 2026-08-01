local PAC = PersonalAssistant.Constants
local PAIStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAIntegration Menu --
    SI_PA_MENU_INTEGRATION_DESCRIPTION = "PAIntegrationは、PersonalAssistantアドオンの機能を、Dolgubon's Lazy Writ CrafterやFCO ItemSaverなどの他のサードパーティ製アドオンと統合することができます", 
    SI_PA_MENU_INTEGRATION_NOTHING_AVAILABLE = "現在、PAIntegrationが対応しているアドオンがインストール、または有効化されていません", 
	
    -- Character Knowledge --
    SI_PA_MENU_INTEGRATION_CK_CHARACTER = "既知とする対象キャラクター", 
    SI_PA_MENU_INTEGRATION_CK_ENABLE = "Character Knowledgeとの統合を有効化", 
    SI_PA_MENU_INTEGRATION_CK_ENABLE_T = table.concat({"Character Knowledgeを使用して、", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE), "または", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), "が既知であるかを判定します"}), 
    SI_PA_MENU_INTEGRATION_CK_INITIALIZING = "Character Knowledgeを初期化中...", 

    -- Dolgubon's Lazy Writ Crafter --
    SI_PA_MENU_INTEGRATION_LWC_COMPATIBILITY = "Dolgubon's Lazy Writ Crafterとの互換性", 
    SI_PA_MENU_INTEGRATION_LWC_COMPATIBILITY_T = "デイリークラフト（デイリー依頼）のクエストがアクティブで、かつDolgubon's Lazy Writ Crafterの「依頼アイテムを引き出す」が有効な場合、該当するアイテムに対する「銀行に預ける」設定は無視されます。これは、引き出したアイテムがすぐに再預入されてしまうのを防ぐためです", 

    -- FCO ItemSaver --
    SI_PA_MENU_INTEGRATION_FCOIS_LOCKED_PREVENT_SELLING = "ロックされたアイテムの自動売却を防ぐ", 
    SI_PA_MENU_INTEGRATION_FCOIS_LOCKED_PREVENT_MOVING = "ロックされたアイテムの移動を防ぐ", 
    SI_PA_MENU_INTEGRATION_FCOIS_LOCKED_PREVENT_MOVING_T = "オンにすると、FCO ItemSaverでロックされているアイテムは、銀行への預け入れも銀行からの引き出しも行われなくなります", 
    SI_PA_MENU_INTEGRATION_FCOIS_SELL_AUTOSELL_MARKED = "マークされたアイテムを商人/盗品商で自動売却する", 
    SI_PA_MENU_INTEGRATION_FCOIS_ITEM_MOVE_MARKED = "銀行アクセス時にマークされたアイテムを移動する", 


    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAIntegration --


    -- =================================================================================================================
    -- == OTHER STRINGS FOR MENU == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAIntegration Menu --
    SI_PA_MENU_INTEGRATION_PAB_REQUIRED = "PABankingが有効化されると、追加の設定が表示されます", 
    SI_PA_MENU_INTEGRATION_PAJ_REQUIRED = "PAJunkが有効化されると、追加の設定が表示されます", 

    SI_PA_MENU_INTEGRATION_MORE_TO_COME = "将来のアップデートで、さらなるFCO ItemSaverとの統合機能が追加される予定です", 
}

for key, value in pairs(PAIStrings) do
    SafeAddString(_G[key], value, 1)
end


local PAIGenericStrings = {
    -- =================================================================================================================
    -- Language independent texts (do not need to be translated/copied to other languages --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------

    -- Character Knowledge
    SI_PA_MENU_INTEGRATION_CK_HEADER = "Character Knowledge", 
	
    -- Dolgubon's Lazy Writ Crafter --
    SI_PA_MENU_INTEGRATION_LWC_HEADER = "Dolgubon's Lazy Writ Crafter", 

    -- FCO ItemSaver --
    SI_PA_MENU_INTEGRATION_FCOIS_HEADER = "FCO Item Saver", 
}

for key, value in pairs(PAIGenericStrings) do
    ZO_CreateStringId(key, value) 
    SafeAddVersion(key, 1) 
end