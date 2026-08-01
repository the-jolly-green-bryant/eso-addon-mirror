local stringsJP = {
    -- Name
    ABP_FENCE_NAME = "盗品商",
    ABP_RETRAIT_STATION_NAME = "変性台",
    ABP_VANITY_PETS_NAME = "非戦闘ペット",
    ABP_QUEST_NAME = string.format("%s (%s)", GetString(SI_ITEMTYPEDISPLAYCATEGORY8), "デイリー"),
    ABP_THIEVESTROVE_NAME = "盗賊の宝",
    -- Tooltip
    ABP_BANK_TOOLTIP = "銀行を開く時",
    ABP_GUILD_BANK_TOOLTIP = "ギルド銀行を開く時",
    ABP_STORE_TOOLTIP = "商人を開く時",
    ABP_GUILD_STORE_TOOLTIP = "ギルド商人を開く時",
    ABP_FENCE_TOOLTIP = "盗品商を開く時",
    ABP_CRAFT_STATION_TOOLTIP = "クラフト台に触れる時",
    ABP_RETRAIT_STATION_TOOLTIP = "変性台に触れる時",
    ABP_DYEING_STATION_TOOLTIP = "染色台に触れる時",
    ABP_WAYSHRINE_TOOLTIP = "旅の祠に触れる時",
    ABP_THIEVESTROVE_TOOLTIP = "盗賊の宝に触れる時",
    ABP_STEAL_TOOLTIP = "盗む時",
    ABP_VAMPIRE_TOOLTIP = "ヴァンパイアに変身する時",
    ABP_WEREWOLF_TOOLTIP = "ウェアウルフに変身する時",
    ABP_ARRESTED_TOOLTIP = "逮捕される時",
    ABP_TORCHBUG_TOOLTIP = "ホタル/蝶に触れる時",
    ABP_QUEST_TOOLTIP = "デイリークエストを受注/報告する時",
    ABP_STEALTH_TOOLTIP = "かがむ時",
    ABP_BEFORE_COMBAT_TOOLTIP = "戦闘に突入する時",
    ABP_AFTER_COMBAT_TOOLTIP = "戦闘を終える時",
    ABP_LOGOUT_TOOLTIP = "ログアウトする時",
    ABP_EXIT_TOOLTIP = "終了する時",
    ABP_NO_PETS_ALLOWED_NAME = "あらゆる状況で戦闘ペットを無効にする",
    -- Setting
    ABP_NOTIFICATION_PETS = "戦闘ペットが消えました！",
    ABP_NOTIFICATION_VANITY_PETS = "非戦闘ペットが消えました！",
    ABP_NOTIFICATION_ASSISTANTS = "助手が消えました！",
    ABP_NOTIFICATION_COMPANIONS = "コンパニオンが消えました！",
    ABP_NOTIFICATION_RESUMMON_VANITY_PETS = "非戦闘ペットが帰ってきました！",
    ABP_NOTIFICATION_RESUMMON_ASSISTANTS = "助手が帰ってきました！",
    ABP_NOTIFICATION_RESUMMON_COMPANIONS = "コンパニオンが帰ってきました！",
    -- Keybind
    SI_BINDING_NAME_BANISH_ALL = "全てを消す",
    SI_BINDING_NAME_BANISH_PETS = "戦闘ペットを消す",
    SI_BINDING_NAME_BANISH_VANITY_PETS = "非戦闘ペットを消す",
    SI_BINDING_NAME_BANISH_ASSISTANTS = "助手を消す",
    SI_BINDING_NAME_BANISH_COMPANIONS = "コンパニオンを消す",
    SI_BINDING_NAME_RESUMMON_ALL = "全てを再召還",
    SI_BINDING_NAME_RESUMMON_VANITY_PETS = "非戦闘ペットを再召還",
    SI_BINDING_NAME_RESUMMON_ASSISTANTS = "助手を再召還",
    SI_BINDING_NAME_RESUMMON_COMPANIONS = "コンパニオンを再召還",
    SI_BINDING_NAME_NO_PETS_ALLOWED = "'NO-PETS-ALLOWED'を切り替える",
}

for stringId, stringValue in pairs(stringsJP) do
    SafeAddString(_G[stringId], stringValue, 1)
end