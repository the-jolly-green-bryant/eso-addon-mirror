-- =============================================================================
-- === OptimalWeave Language File: Japanese (jp.lua)                          ===
-- =============================================================================
--[[
    AddOn Name:         OptimalWeave
    File:               lang/jp.lua
    Description:        Japanese localization using ZO_CreateStringId
    Version:            1.17.0
    Author:             Orollas & VollständigerName
--]]
-- =============================================================================

-- =============================================================================
-- == PANEL & AUTHOR INFORMATION ===============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_PANEL_NAME", "|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r")
ZO_CreateStringId("OW_MENU_AUTHORS", "|cEE82EEO|r|cDD74ECr|r|cCD65EAo|r|cBC57E8l|r|cAB48E6l|r|c9B3AE4a|r|c8A2BE2s|r & |cFFD700Vo|r|cF7D418l|r|cF3D324l|r|cEFD130s|r|cEBD03Ctä|r|cE3CD54n|r|cE0CC60d|r|cDCCA6Ci|r|cD8C978g|r|cD4C784e|r|cD0C690r|r|cCCC49CNa|r|cC4C1B4me|r")
ZO_CreateStringId("OW_MENU_WEBSITE", "https://github.com/VollstaendigerName")

-- =============================================================================
-- == INFORMATION SECTION ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_INFO_HEADER", "情報 & 説明書")
ZO_CreateStringId("OW_MENU_INFO_TEXT", "グローバルクールダウン (GCD) は1000msです。OptimalWeaveは選択したモードに基づいてスキルのキューを管理します。以下の設定で動作をカスタマイズできます。")
ZO_CreateStringId("OW_MENU_MODE_HEADER", "基本メカニズム")
ZO_CreateStringId("OW_MENU_CONDITIONS_HEADER", "起動ルール")
ZO_CreateStringId("OW_MENU_ADVANCED_HEADER", "高度な制御")
ZO_CreateStringId("OW_MENU_PERFORMANCE_HEADER", "パフォーマンス設定")
ZO_CreateStringId("OW_MENU_MODE_ACTIVE", "アドオン有効")
ZO_CreateStringId("OW_MENU_MODE_INACTIVE", "アドオン無効")
ZO_CreateStringId("OW_MENU_DISABLED_TOOLTIP", "このオプションは現在無効です")
ZO_CreateStringId("OW_MENU_LATENCY_WARNING", "警告：高いレイテンシは入力遅延を引き起こす可能性があります！")

ZO_CreateStringId("OW_MENU_DISCLAIMER_LABEL", "|cFF0000免責事項|r") 
ZO_CreateStringId("OW_MENU_DISCLAIMER_TOOLTIP", "|cFF0000免責事項:|r 本アドオンはZeniMax Media Inc.と関係ありません。The Elder Scrolls®はZeniMax Media Inc.の登録商標です。")

-- =============================================================================
-- == CORE SETTINGS ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SETTINGS_HEADER", "基本設定")
ZO_CreateStringId("OW_MENU_MODE_LABEL", "動作モード")
ZO_CreateStringId("OW_MENU_MODE_TOOLTIP", "|c00FF00シーケンシャル:|r 軽攻撃の後にのみアビリティを使用できます。\n|cFF0000厳格:|r 完全ブロック。GCD中キュー不可\n|cFFFF00スマート:|r 軽攻撃がない場合のみキュー許可\n|c00FFFFなし:|r 無効")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_COND", "シーケンシャル")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_HARD", "厳格")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_SOFT", "スマート")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_NONE", "なし")
ZO_CreateStringId("OW_MENU_COMBAT_LABEL", "戦闘中のみ有効")
ZO_CreateStringId("OW_MENU_COMBAT_TOOLTIP", "戦闘中のみキューを管理")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_LABEL", "敵ターゲット必須")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_TOOLTIP", "敵ターゲット選択が必要")
ZO_CreateStringId("OW_MENU_BLOCKING_LABEL", "ブロック中無視")
ZO_CreateStringId("OW_MENU_BLOCKING_TOOLTIP", "ブロック中は制御を無効化")
ZO_CreateStringId("OW_MENU_GROUNDAOE_LABEL", "AoE二重発動防止")
ZO_CreateStringId("OW_MENU_GROUNDAOE_TOOLTIP", "エリアスキルの誤った二重発動を防止")
ZO_CreateStringId("OW_MENU_DISABLE_TANK", "タンク時無効")
ZO_CreateStringId("OW_MENU_DISABLE_TANK_TOOLTIP", "タンクロール時に自動無効")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL", "ヒーラー時無効")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL_TOOLTIP", "ヒーラーロール時に自動無効")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR", "バックバーで機能を無効化")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR_TOOLTIP", "バックバーでアドオンのほとんどの機能を無効化します。")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR", "バックバーでウィーブアシストを無効化")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR_TOOLTIP", "バックバーでウィーブアシスト（GCD管理）を無効化します。")

ZO_CreateStringId("OW_MENU_DEACTIVATE_IN_PVP_HEADER", "PvP無効化")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP", "PvPで機能を無効化")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP_TOOLTIP", "PvPエリアでアドオンのほとんどの機能を無効化します")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP", "PvPでウィーブアシストを無効化")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP_TOOLTIP", "PvPエリアでウィーブアシスト（GCD管理）を無効化します")

-- =============================================================================
-- == BLOCK ID SETTINGS ========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKED_HEADER", "ブロック済みスキル")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_LABEL", "新規IDブロック")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_TOOLTIP", "スキルIDを入力 (例: 134160)")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_LABEL", "現在ブロック中ID")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_TOOLTIP", "クリックで削除")

-- =============================================================================
-- == ADVANCED SETTINGS ========================================================
-- =============================================================================
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL", "瞬発バッファ (ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL_TOOLTIP", "瞬発スキルの安全マージン (0-100ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED", "チャネリングバッファ (ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED_TOOLTIP", "チャネリングスキルのバッファ (0-400ms)")
ZO_CreateStringId("OW_MENU_GCD_SLOT", "GCD検知スロット")
ZO_CreateStringId("OW_MENU_GCD_SLOT_TOOLTIP", "GCD検知用アクションバースロット (1-8)")
ZO_CreateStringId("OW_MENU_RESET_TIME_LABEL", "リセット時間（秒）")
ZO_CreateStringId("OW_MENU_RESET_TIME_TOOLTIP", "何もキャストしていない時間がこの秒数を超えるとトラッキングをリセット")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_LABEL", "自動GCDトラッキングスロット")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_TOOLTIP", "スロット3-8から最適なGCDトラッキングスロットを自動選択")
ZO_CreateStringId("OW_MENU_MIN_GCD", "最小GCD閾値 (ms)")
ZO_CreateStringId("OW_MENU_MIN_GCD_TOOLTIP", "検知する最小GCD時間 (0-20ms)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME", "基本キュー時間 (ms)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME_TOOLTIP", "デフォルト入力キュー窓 (100-2000ms)")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_LABEL", "武器切り替え時リセット")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_TOOLTIP", "武器切り替え時にGCDをリセット")
ZO_CreateStringId("OW_MENU_RESETONDODGE_LABEL", "回避時リセット")
ZO_CreateStringId("OW_MENU_RESETONDODGE_TOOLTIP", "回避時にGCDをリセット")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_LABEL", "武器自動抜刀")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_TOOLTIP", "戦闘中に武器を自動的に抜く")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_LABEL", "すべてリセット")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_TOOLTIP", "すべての設定をデフォルト値にリセットします")

-- =============================================================================
-- == LATENCY COMPENSATION =====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_LATENCY_HEADER", "レイテンシ補正")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_LABEL", "自動調整")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_TOOLTIP", "レイテンシに基づき自動調整。安定接続時推奨")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_LABEL", "手動レイテンシ (ms)")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_TOOLTIP", "不安定接続時は固定値使用 (0-200ms)")

-- =============================================================================
-- == (SUB)CLASS SETTINGS ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SUBCLASS_HEADER", "クラス/ギルド固有設定")
ZO_CreateStringId("OW_MENU_SUBCLASS_GRIMFOCUS", "グリムフォーカス")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS", "必要スタック数")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS_TOOLTIP", "起動に必要なスタック数 (推奨: 10)")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS", "全モーフをブロック")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS_TOOLTIP", "|cFF5555• レントレスフォーカス:|r 常時ブロック\n|cFFFF00• グリムフォーカス/マーシレスレゾルブ:|r 10スタック時のみ使用可能\n|cAAAAAA無効:|r デフォルト動作")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE", "カスタムスタックを有効化")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE_TOOLTIP", "|cFFD700有効:|r スタック設定を使用 \n|cAAAAAA無効:|r 10スタックまで常時ブロック\n")

-- == BLOCK GUILDS SETTINGS ===================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_GUILDS", "ギルド")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS", "戦士ギルドのハンタースキルをブロック")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS_TOOLTIP", "戦士ギルドのハンタースキル（エキスパートハンター、カモフラージドハンター、イビルハンター）の全モーフをブロック")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS", "魔術師ギルドの光スキルをブロック")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS_TOOLTIP", "光スキル（メイジライト、インナーライト、レディアントメイジライト）の全モーフをブロック")

ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS", "PvPで無効")
ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS_TOOLTIP", "PvPエリアでハンター/ライトスキルブロックを無効化")

-- == BLOCK MOLTEN WHIP SETTINGS ===============================================
ZO_CreateStringId("OW_MENU_SUBCLASS_MOLTENWHIP", "モルテンホイップ")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK", "モルテンホイップスキルをブロック")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK_TOOLTIP", "3スタックを失わないようにモルテンホイップスキルをブロックします")

-- == BLOCK FATECARVER SETTINGS ================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_FATECARVER", "アルカニスト フェイトカーバー")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS", "フェイトカーバー発動ブロック")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS_TOOLTIP", "条件満了まで発動をブロック")
ZO_CreateStringId("OW_MENU_CRUX_STACKS", "必要クラックススタック")
ZO_CreateStringId("OW_MENU_CRUX_STACKS_TOOLTIP", "発動に必要な最小クラックス数 (推奨: 3)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM", "HPしきい値 (%)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOLTIP", "HPがこの値を下回るとフェイトカーバーのブロックを無効化")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE", "フェイトカーバーのHPチェックを有効化")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE_TOOLTIP", "HPが低い場合にフェイトカーバーのブロックを無効化")

ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM", "スタミナしきい値 (%)")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOLTIP", "スタミナが低い場合にフェイトカーバーのブロックを無効化")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE", "フェイトカーバーのスタミナチェックを有効化")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE_TOOLTIP", "スタミナが低い場合にフェイトカーバーのブロックを無効化")

-- == BLOCK CEPHALIARCH'S FLAIL SETTINGS =======================================
ZO_CreateStringId("OW_MENU_SUBCLASS_CEPHALIARCHSFLAIL", "セファリアークのフレイル")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL", "セファリアークのフレイルをブロック")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL_TOOLTIP", "クルックススタックが3の時、セファリアークのフレイルをブロックします")

-- == BLOCK TENTACULAR DREAD SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_TENTACULAR", "テンタキュラルドレッド")
ZO_CreateStringId("OW_MENU_TENTACULAR", "テンタキュラルドレッドをブロック")
ZO_CreateStringId("OW_MENU_TENTACULAR_TOOLTIP", "条件が満たされるまでテンタキュラルドレッドスキルをブロックします")

-- == Execute Check Settings ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_HEADER", "エグゼキュートチェック")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE", "エグゼキュートチェックを有効にする")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE_TOOLTIP", "エグゼキュートチェック機能を有効または無効にします")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD", "エグゼキュートしきい値 (%)")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD_TOOLTIP", "ターゲットの体力パーセンテージがこの値を下回るとエグゼキュート呪文が許可されます")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELLS_HEADER", "エグゼキュート呪文")

-- == Grouped Execute Spells ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS", "光輝の破壊, 光輝の栄光, 光輝の抑圧")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS_TOOLTIP", "ターゲットがエグゼキュート範囲に達するまで光輝の破壊モーフをブロックします")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS", "アサシンズブレイド, 貫刺, キラーズブレイド")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS_TOOLTIP", "ターゲットがエグゼキュート範囲に達するまでアサシンズブレイドモーフをブロックします")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS", "魔術師の憤怒, 魔術師の激昂, 無尽の激昂")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS_TOOLTIP", "ターゲットが執行範囲になるまで魔術師の激昂のモーフをブロックします")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS", "反転斬り, 反転スライス, 処刑人")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS_TOOLTIP", "ターゲットが執行範囲になるまで反転斬りのモーフをブロックします")

-- == Work in progress ================================================
ZO_CreateStringId("OW_WIP", "WIP")

-- =============================================================================
-- == WEAPON SETTINGS ==========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEADER", "武器タイプに基づく無効化")

ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON", "武器タイプでウィーブアシストを無効化")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON_TOOLTIP", "選択した武器タイプでウィーブアシスト（GCD管理）のみを無効化します")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON", "武器タイプで機能を無効化")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON_TOOLTIP", "選択した武器タイプでアドオンのほとんどの機能を無効化します")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE", "斧")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE_TOOLTIP", "斧装備時に無効化")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER", "ハンマー")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER_TOOLTIP", "ハンマー装備時に無効化")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD", "剣")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD_TOOLTIP", "剣装備時に無効化")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER", "ダガー")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER_TOOLTIP", "ダガー装備時に無効化")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD", "両手剣")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD_TOOLTIP", "両手剣装備時に無効化")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE", "両手斧")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE_TOOLTIP", "両手斧装備時に無効化")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER", "両手ハンマー")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER_TOOLTIP", "両手ハンマー装備時に無効化")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW", "弓")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW_TOOLTIP", "弓装備時に無効化")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF", "炎の杖")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF_TOOLTIP", "炎の杖装備時に無効化")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF", "氷の杖")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF_TOOLTIP", "氷の杖装備時に無効化")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF", "雷の杖")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF_TOOLTIP", "雷の杖装備時に無効化")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF", "癒しの杖")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF_TOOLTIP", "癒しの杖装備時に無効化")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD", "盾")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD_TOOLTIP", "盾装備時に無効化")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE", "ルーン")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE_TOOLTIP", "ルーン装備時に無効化")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE", "武器なし")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE_TOOLTIP", "武器未装備時に無効化")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED", "予約済み武器")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED_TOOLTIP", "予約済み武器タイプ装備時に無効化")

-- =============================================================================
-- == CUSTOM BLOCK LIST SETTINGS ==============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLIST_HEADER", "カスタムブロックリスト")
ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_HEADER", "カスタムブロックリスト")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_DESC", "スペルIDを追加して使用をブロックします。アクションバーのスロットを右クリックしてスペルを追加することもできます（リロードが必要）")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_LABEL", "スキルID")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP", "数値のスキルIDを入力してください（例：185805）")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_ADD_BUTTON", "ブロックリストに追加")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_LIST_HEADER", "ブロック済みスキル:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST", "カスタムブロックリストを有効化")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_TOOLTIP", "カスタムブロックリスト機能を有効または無効にします")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SV_DESC", "SavedVariablesファイルを確認:\n customBlockList = {\n   [SpellID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK", "ブロックリストの健康チェックを有効にする")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "有効にすると、ブロックリスト内のスペルは、あなたの健康がしきい値を超えている場合にのみブロックされます。")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT", "ブロックリストの健康しきい値 (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "ブロックリストのスペルは、あなたの健康がこのパーセンテージを超えている場合にのみブロックされます。")

-- =============================================================================
-- == CUSTOM RECAST BLOCK LIST SETTINGS ========================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLERECASTBLOCK_HEADER", "カスタム再発動ブロックリスト")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_DESC", "残りの効果時間がしきい値を下回るまで再キャストをブロックするスペルIDを追加します。アクションバーのスロットを右クリックしてスペルを追加することもできます（リロードが必要）。")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_LABEL", "スキルID")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_TOOLTIP", "数値のスキルIDを入力してください（例：185805）")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_ADD_BUTTON", "再発動ブロックリストに追加")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_LIST_HEADER", "再発動ブロック済みスキル:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST", "カスタム再発動ブロックリストを有効化")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_TOOLTIP", "カスタム再発動ブロックリスト機能を有効または無効にします")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME", "再発動ブロック時間 (s)")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME_TOOLTIP", "再発動ブロックリスト内のスキルを再発動できる時間（秒）（1.0 = 1秒）")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SV_DESC", "SavedVariablesファイルを確認:\n customRecastBlockList = {\n   [SpellID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK", "再キャストブロックリストの健康チェックを有効にする")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "有効にすると、再キャストブロックリスト内のスペルは、あなたの健康がしきい値を超えている場合にのみブロックされます。")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT", "再キャストブロックリストの健康しきい値 (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "再キャストブロックリストのスペルは、あなたの健康がこのパーセンテージを超えている場合にのみブロックされます。")

-- =============================================================================

ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_MAIN_TEXT", "スキルIDが追加/削除されました。これ以上スキルを追加または削除しない場合は、変更を表示するためにUIをリロードしてください。")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_YES", "UIをリロード")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_LATER", "後で")

ZO_CreateStringId("OW_MENU_DIALOG_BUTTON_OK", "OK")
ZO_CreateStringId("OW_MENU_INVALID_ID_DIALOG_MAIN_TEXT", "エラー: 有効なスキルIDを入力してください")
ZO_CreateStringId("OW_MENU_ID_NOT_EXIST_DIALOG_MAIN_TEXT", "スキルIDが存在しません")
ZO_CreateStringId("OW_MENU_ID_IS_IN_SV_DIALOG_MAIN_TEXT", "スキルIDはすでにブロックリストにあります")

-- =============================================================================
-- == RESOURCE-BASED BLOCK LIST SETTINGS =======================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_RESOURCE_HEADER", "リソースベースのブロックリスト")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_RESOURCE_DESC", "スキルIDを追加して、プライマリリソース（マジカまたはスタミナ）がしきい値を下回ったときにブロックします。アクションバースロットを右クリックしてスキルを追加することもできます（リロードが必要です）。")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST", "リソースベースのブロックリストを有効にする")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST_TOOLTIP", "リソースベースのブロックリスト機能を有効または無効にします")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK", "リソースチェックを有効にする")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK_TOOLTIP", "有効にすると、リソースブロックリスト内のスキルは、プライマリリソース（マジカまたはスタミナ）がしきい値より上の場合にのみブロックされます。")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT", "リソースしきい値 (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT_TOOLTIP", "リソースブロックリストのスキルは、プライマリリソース（マジカまたはスタミナ）がこのパーセンテージより上の場合にのみブロックされます。")
ZO_CreateStringId("OW_MENU_RESOURCE_BLOCK_SPELL", "スキル：")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK", "マジカチェック")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK_TOOLTIP", "このスキルにマジカベースのブロックを有効にする")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE", "マジカがしきい値を下回ったときにブロック")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE_TOOLTIP", "マジカがしきい値を下回ったときにスキルをブロックします（チェックを外すと、下回っている場合のみ許可します）")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD", "マジカしきい値 (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD_TOOLTIP", "マジカのパーセンテージしきい値")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK", "スタミナチェック")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK_TOOLTIP", "このスキルにスタミナベースのブロックを有効にする")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE", "スタミナがしきい値を下回ったときにブロック")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE_TOOLTIP", "スタミナがしきい値を下回ったときにスキルをブロックします（チェックを外すと、下回っている場合のみ許可します）")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD", "スタミナしきい値 (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD_TOOLTIP", "スタミナのパーセンテージしきい値")

-- =============================================================================
-- == KEYBINDINGS LOCALIZATION =================================================
-- =============================================================================

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_OPTIMALWEAVE", "|c6D6D6DOpti|r|c8A8A8AmalWea|r|cC4C4C4ve|r")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_MODE", "モード切替（厳格/スマート/無効）")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_BLOCK_LIST", "カスタムブロックリスト切替")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_RECAST_BLOCK_LIST", "カスタム再発動ブロックリスト切替")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_FEATURES", "バックバー機能無効化切替")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_WEAVE_ASSIST", "バックバーウィーブアシスト無効化切替")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_EXECUTE_CHECK", "エグゼキュートチェック切替")

-- =============================================================================
-- == REMOVE BUTTON ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_BUTTON", "削除")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_TOOLTIP", "このスキルをブロックリストから削除します（/reloaduiが必要）")

-- =============================================================================
-- == SETTIINGS MODE ===========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_MODE_SELECTION_LABEL", "設定モード")
ZO_CreateStringId("OW_MENU_MODE_SELECTION_TOOLTIP", "設定をこのアカウントのすべてのキャラクターで共有するか（アカウント全体）、各キャラクターごとに個別に保存するか（キャラクターごと）を選択します。")
ZO_CreateStringId("OW_MENU_MODE_ACCOUNTWIDE", "アカウント全体")
ZO_CreateStringId("OW_MENU_MODE_PERCHARACTER", "キャラクターごと")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_SETTINGS_MAIN_TEXT", "設定モードが変更されました。変更を適用するためにUIをリロードしますか？")

-- =============================================================================
-- == IN COMBAT MENU BLOCKING ==================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU", "戦闘中に直前のメニューをブロック")
ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU_TOOLTIP", "戦闘中に直前のメニュー (ALT) が開くのを防ぎます。")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU", "戦闘中にキャラクターメニューをブロック")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU_TOOLTIP", "戦闘中にキャラクターメニュー (C) が開くのを防ぎます。")

-- =============================================================================
-- == GCD DISPLAY ==============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SHOW_GCD_LABEL", "グローバルクールダウン (GCD) を表示")
ZO_CreateStringId("OW_MENU_SHOW_GCD_TOOLTIP", "アクションバーの上に GCD インジケーター（ZOS 提供）を表示します。")

-- =============================================================================
-- == BLOCKLIST COMBAT ONLY ====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_LABEL", "戦闘中のみブロックリストを有効化")
ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_TOOLTIP", "カスタムブロックリストは戦闘中のみ有効になります。戦闘外ではすべてのブロックリストが無効になります。")

-- =============================================================================
-- === END OF JAPANESE LOCALIZATION ============================================
-- =============================================================================