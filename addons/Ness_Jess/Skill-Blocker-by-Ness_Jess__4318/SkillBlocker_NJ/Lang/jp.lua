-- -----------------------------------------------------------------------------
-- Lang/jp.lua
-- -----------------------------------------------------------------------------
local strings = {
    SKILLBLOCKER_NJ_UNLOCK_ALL                         = "すべてロック解除",
    SKILLBLOCKER_NJ_UNLOCKED                           = "ロック解除",
    SKILLBLOCKER_NJ_LOCKED                             = "ロック済み",
    SKILLBLOCKER_NJ_LOCKED_COMBAT                      = "戦闘中ロック",
    SKILLBLOCKER_NJ_LOCKED_ACTIVE                      = "アクティブ時ロック",
    SKILLBLOCKER_NJ_LOADED                             = "正常に読み込まれました",
    SKILLBLOCKER_NJ_LOCKED_WEREWOLF                    = "ウェアウルフ変身中にロック",

    SKILLBLOCKER_NJ_BLOCK_SETTINGS                     = "ブロック設定",
    SKILLBLOCKER_NJ_BLOCK_STACKS                       = "スタック数が次未満でブロック <",
    SKILLBLOCKER_NJ_BLOCK_CRUX                         = "クラックスが次未満でブロック <",
    SKILLBLOCKER_NJ_BLOCK_REVERSE                      = "クルクス ≥ ならブロック",
    SKILLBLOCKER_NJ_BLOCK_PROC                         = "<<1>>回目の発動までブロック",
    SKILLBLOCKER_NJ_BLOCK_HP                           = "ターゲットHPが次を超えたらブロック >",
    SKILLBLOCKER_NJ_BLOCK_ULTIMATE                     = "アルティメットが次未満でブロック < <<1>>",
    SKILLBLOCKER_NJ_BLOCK_DURATION                     = "<<1>>秒間ブロック",
    SKILLBLOCKER_NJ_BLOCK_DEBUFF                       = "<<1>>回目の爆発までブロック",

    SKILLBLOCKER_NJ_GENERAL_SETTINGS                   = "一般設定",
    SKILLBLOCKER_NJ_REMEMBER                           = "ロック状態を記憶する？",
    SKILLBLOCKER_NJ_SHOW_ALERT                         = "警告を表示",
    SKILLBLOCKER_NJ_ALERT_TOOLTIP                      = "ブロックされたスキルを使用しようとした際にシステム警告を表示する",

    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_SETTINGS         = "二重発動防止設定",
    SKILLBLOCKER_NJ_RESET_DOUBLE_CAST_LA               = "軽攻撃で防止解除",
    SKILLBLOCKER_NJ_RESET_DOUBLE_CAST_LA_TOOLTIP       = "有効にすると、軽攻撃（左クリック）で二重発動防止が即座に解除されます。",
    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_DURATION         = "防止期間",
    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_DURATION_TOOLTIP = "スキル使用後、再使用がブロックされる時間（秒）（0=∞）。",

    SKILLBLOCKER_NJ_MENU_ACTIVE_BLOCKS_TITLE           = "ブロック中のスキル一覧：",
    SKILLBLOCKER_NJ_MAIN_BAR                           = "メインバー：",
    SKILLBLOCKER_NJ_BACK_BAR                           = "バックバー：",

    SKILLBLOCKER_NJ_ACTION_ENABLE                      = "有効にする",
    SKILLBLOCKER_NJ_ACTION_DISABLE                     = "無効にする",

    SKILLBLOCKER_NJ_MENU_DOUBLE_CAST_TITLE             = "二重発動防止",
    SKILLBLOCKER_NJ_MENU_STACK_TITLE                   = "スタックによるブロック",
    SKILLBLOCKER_NJ_MENU_CRUX_TITLE                    = "クルクスによるブロック",
    SKILLBLOCKER_NJ_MENU_PROC_TITLE                    = "プロックによるブロック",
    SKILLBLOCKER_NJ_MENU_DEBUFF_TITLE                  = "スキルの「爆発」によるブロック",
    SKILLBLOCKER_NJ_MENU_ULTIMATE_TITLE                = "アルティメットによるブロック",
    SKILLBLOCKER_NJ_MENU_DURATION_TITLE                = "継続時間によるブロック",
    SKILLBLOCKER_NJ_MENU_HP_TITLE                      = "敵の体力によるブロック",
    SKILLBLOCKER_NJ_MENU_CRIMINAL_TITLE                = "「犯罪行為」をブロック",

    SKILLBLOCKER_NJ_DELETE_FROM_SLOT                   = "スロットから削除",

    SI_BINDING_NAME_SKILLBLOCKER_NJ_UNLOCK_ALL         = "すべてのスキルのロックを解除",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_1      = "ロック切替: スロット1",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_2      = "ロック切替: スロット2",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_3      = "ロック切替: スロット3",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_4      = "ロック切替: スロット4",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_5      = "ロック切替: スロット5",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_6      = "ロック切替: アルティメット",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end