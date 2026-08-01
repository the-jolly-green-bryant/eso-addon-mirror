local PAC = PersonalAssistant.Constants
local PAStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- Welcome Messages --
    SI_PA_WELCOME_NO_SUPPORT = "がお手伝いします！ - 言語 [%s] のローカライズは（まだ）利用できません",
    SI_PA_WELCOME_SUPPORT = "がお手伝いします！",
    SI_PA_WELCOME_PLEASE_SELECT_PROFILE = table.concat({"へようこそ！ まずはアドオン設定に移動し、プロフィールを選択してください。よろしくお願いいたします :-)"}),


    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    SI_PA_MENU_GENERAL_DESCRIPTION = "PersonalAssistantは、ESOのプレイをより便利に、快適にすることを目的とした様々な機能のコレクションです。\n\n各モジュールにはアカウント共通のプロフィールリストがあり、キャラクターごとにどのアクティブプロフィールを使用するか選択できます。",

    -- -----------------------------------------------------------------------------------------------------------------
    -- General Settings --
    SI_PA_MENU_GENERAL_HEADER = "一般設定",
    SI_PA_MENU_GENERAL_SHOW_WELCOME = "歓迎メッセージを表示する",

    SI_PA_MENU_GENERAL_TELEPORT_HEADER = "ハウジング",
    SI_PA_MENU_GENERAL_TELEPORT_PRIMARY_HOUSE = table.concat({PAC.ICONS.OTHERS.HOME.NORMAL, " 自宅へ旅する"}),
    SI_PA_MENU_GENERAL_TELEPORT_PRIMARY_HOUSE_W = "現在の場所がファストトラベル可能な場合、登録されているプライベートハウス（お気に入り）へのテレポートを開始します！",
    SI_PA_MENU_GENERAL_TELEPORT_OUTSIDE = "邸宅の外へ旅する",
    SI_PA_MENU_GENERAL_TELEPORT_OUTSIDE_T = "オフにすると、代わりに邸宅の内部へとテレポートします",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Admin Settings --
    SI_PA_MENU_ADMIN_HEADER = "管理者設定",
}

for key, value in pairs(PAStrings) do
    SafeAddString(_G[key], value, 1)
end