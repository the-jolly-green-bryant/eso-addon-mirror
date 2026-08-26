TetsuDailyWritPrecrafter = TetsuDailyWritPrecrafter or {}
local L = TetsuDailyWritPrecrafter.L
if not L then return end

L.TITLE                   = "|cFFD700Tetsu's|r Daily Writ Precrafter"

L.OPTIONS_SECTION_LABEL   = "自動化"
L.OPTIONS_SECTION_TT      = "ゲームパッド向けの安全な自動化オプション。"
L.AUTO_QUEST_LABEL        = "クラフト依頼の自動受注・納品"
L.AUTO_QUEST_TT           = "掲示板から依頼を受け、箱で自動的に納品します。"
L.AUTO_BOX_LABEL          = "報酬箱を自動で開く"
L.AUTO_BOX_TT             = "デイリークエストの報酬コンテナがバッグに入ったらすぐに開きます。"

L.PRECRAFT_SECTION_LABEL  = "プレクラフト（このキャラクター）"
L.PRECRAFT_SECTION_TT     = "設定はこのキャラクターごとに保存されます。"
L.PRECRAFT_ENABLED_LABEL  = "将来分をプレクラフトする"
L.PRECRAFT_ENABLED_TT     = "有効時：R3で日替わりローテーションに従い数日分を作成。無効時：R3は進行中の依頼に必要なものだけ作成。"
L.PRECRAFT_DAYS_LABEL     = "何日分先まで"
L.PRECRAFT_DAYS_TT        = "何日分プレクラフトするか（今日を含む）。スライダー 1～10。"

L.KEYBIND_PRECRAFT        = "|c00FF00[R3]|r プレクラフト <<1>>日 (<<2>>個)"
L.KEYBIND_QUEST_CRAFT     = "|c00FF00[R3]|r 進行中の依頼を作成 (<<1>>個)"
L.KEYBIND_NOTHING         = "|c888888[R3]|r 作成するものなし"

L.CONFIRM_TITLE_PRECRAFT  = "デイリークエストのプレクラフト"
L.CONFIRM_PROMPT_PRECRAFT = "<<1>>日分のアイテムを作成しますか？（<<2>>個）"
L.CONFIRM_TITLE_QUEST     = "進行中の依頼を作成"
L.CONFIRM_PROMPT_QUEST    = "進行中の依頼に必要なアイテムを作成しますか？（<<1>>個）"

L.PROGRESS_CRAFTING       = "作成中..."
L.PROGRESS_STATUS         = "処理：<<1>> / <<2>>"

L.ERR_BAG_FULL            = "バッグの空きが足りません（約<<1>>スロット必要）。"
L.ERR_NO_STYLE            = "バッグまたはクラフトバッグに既知のスタイル素材がありません。"
L.ERR_MISSING_RUNES       = "付呪ルーンが不足しています（効力 / 本質 / Ta）。"
L.ERR_CANNOT_CRAFT        = "<<1>>を作成できません（素材・スタイル・スキル不足）。"
L.ERR_CRAFT_FAILED        = "作成失敗 (<<1>>/<<2>>)。スキップ。"
L.ERR_NOT_AT_STATION      = "クラフトステーションにいません。"
L.ERR_PROV_SKIP_UNKNOWN   = "スキップ（レシピ未習得）：<<1>>"
L.ERR_NOTHING_TO_CRAFT    = "作成するものがありません。"
L.ERR_NO_ACTIVE_WRIT      = "このステーションに対応する進行中のクラフト依頼がありません。"

L.PRECHECK_HEADER         = "|cFF6666[Tetsu's Daily Writ Precrafter]|r 素材不足。作成を中止しました："
L.PRECHECK_JOBS           = "キュー内のジョブ：|cFFFFFF<<1>>|r"
L.PRECHECK_LINE           = "  - |cFFD700<<1>>|r：必要 |cFFFFFF<<2>>|r、所持 |cFFFFFF<<3>>|r (|cFF6666-<<4>>|r)"
L.PRECHECK_ABORT          = "不足している素材を追加して、もう一度 R3 を押してください。"
L.PRECHECK_OK             = "素材チェック OK。|c00FF00<<1>>|r個を作成します..."

L.USING_QUEST_DATA        = "進行中の依頼データを使用。"
L.USING_PREDICTED         = "プレクラフトモード：<<1>>日分の日替わりローテーション。"
L.CRAFT_DONE              = "完了。作成：|c00FF00<<1>>|r、スキップ：|cFFFF00<<2>>|r。"
L.PATTERN_TODAY           = "今日のパターン：|cFFD700<<1>>|r"
