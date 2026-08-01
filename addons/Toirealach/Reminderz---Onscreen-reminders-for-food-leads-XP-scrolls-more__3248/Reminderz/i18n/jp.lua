Reminderz = Reminderz or {}

local localization = {

    LOADED_STR = "%s %s %s",
    WAS_LOADED = "ロード済み",
    NOT_LOADED = "ロードされていません",

    DAILY_RESET = "毎日のリセットは %s にあります",
    TURN_IN = "PvP クエストを送信し、タスクと執筆を完了してください。",
    RESET_IS_NOW = "毎日のリセットが行われたところです",
    NO_FOOD_1 = "アクティブなバフフードはありません!",
    NO_FOOD_2 = "何か食べてください!",
    FOOD_RUNNING_OUT = "%s は %s 以内になくなります",
    NO_MAYHEM = "%s は終了しました。もう一度スクロールを使用してください!",
    LOW_BAG_SPACE = "在庫がほぼいっぱいです!",
    NO_BAG_SPACE = "在庫がいっぱいです!",
    GEAR_MISSING = "鎧と武器を確認してください! 何かが足りないです!",
    ARMOR_MISSING = "少なくとも 1 つの防具が装備されていません!",
    JEWELRY_MISSING = "少なくとも 1 つのジュエリーが装備されていません!",
    WEAPON_MISSING = "武器がありません!",
    MAIN_HAND = "あなたのメインハンド",
    OFF_HAND = "あなたのオフハンド",
    BACKUP = "バックアップ",
    IS_ENDING = "%s は %s で終わります",
    GO_FEED = "%s にいます。給餌中です!",
    VAMP_TOO_HIGH = "吸血症リマインダー: 現在のレベル > 希望のレベル",
    NO_XP_SCROLL = "アクティブな XP スクロールはありません!",
    XP_SCROLL_ENDING = "XP スクロールは %s で終了します",
    TELVAR_CAP_REACHED = "あなたは %d 個の Tel Var Stone を運んでいます。銀行に預けるべきです!",
    RESERVE_TOO_HIGH = "Tel'Var の予備数が多すぎます。運ばれているすべての Tel'Var ストーンが自動的に入金されます。",
    TELVAR_DEPOSITED = "%d Tel Var Stone が自動的に銀行に入金されました。",
    WAR_TORTES_MISSING = "アクティブなウォーケーキがありません!",
    WAR_TORTES_RUNNING_OUT = "あなたのウォーケーキは %s で終了します",
    ACHIEVEMENT_PROGRESS = "進捗状況: (%s/%s)",
    ACHIEVEMENT_AWARDED = "実績が完了しました!",
    NO_MUNDUS = "有効なムンダス ストーンがありません!",
    
    WARNING_RELOADUI = "警告: 変更が行われると、ユーザー インターフェイスは自動的にリロードされます。",
   
    ACCTWIDE_NAME = "アカウント全体の設定を使用する",
    ACCTWIDE_TOOLTIP = "この機能をオフにすると、各キャラクターは独自の記憶を持つようになります。",

    ALWAYS = "いつも",
    NEVER = "決して",
    IN_PVP = "PvP のみ",

    REMIND_INTERVAL_NAME = "リマインダー間の間隔:",
    REMIND_INTERVAL_TOOLTIP = "リマインダー間の間隔",
    FIRST_REMINDER_NAME = "最初のリマインダーまでの残り時間:",
    FIRST_REMINDER_TOOLTIP = "最初のリマインダーまでの残り時間",
    REMIND_COLOR_NAME = "リマインダーのテキストの色:",
    REMIND_COLOR_TOOLTIP = "チャットおよび画面上のこれらのリマインダーの色",
    REMIND_OFF_IN_HOUSES_NAME = "家にいる間はリマインダーはありません:",
    REMIND_OFF_IN_HOUSES_TOOLTIP = "自宅にいるときにこのリマインダーが不要な場合は、このオプションを ON に設定してください。",
    REMIND_ONLY_IN_DUNGEONS_NAME = "PvE リマインダーはダンジョン、レイドなどでのみ",
    REMIND_ONLY_IN_DUNGEONS_TOOLTIP = "ダンジョンやレイドなどで PvE リマインダーのみが必要な場合は ON に設定してください",
    
    HEADER_GENERAL = "一般",
    NAME_CHATBOX = "チャット ウィンドウにもリマインダーを表示",
    TOOLTIP_CHATBOX = "メインのチャット タブと画面にリマインダーを表示します。",
    NAME_OFFLINE = "オフライン モードでのウィスパー リマインダー",
    TOOLTIP_OFFLINE = "プレーヤーのステータスを「オフライン」に設定すると、ステータスを変更しない限り、今ささやいていた相手はあなたに応答できないことが通知されます。",
    NAME_SUPPRESS = "「アドオンが読み込まれました」というメッセージを抑制します",
    TOOLTIP_SUPPRESS = "アドオンが正常に読み込まれたことを示すチャット ウィンドウのメッセージを非表示にします。",
    NAME_DAILY_REWARD = "毎日の報酬を自動的に収集する",
    TOOLTIP_DAILY_REWARD = "毎日のログイン報酬が利用可能な場合は自動的に収集します",
    NAME_FREE_BAG_SLOTS = "以下の在庫スロットが空いたときのリマインダー:",
    TOOLTIP_FREE_BAG_SLOTS = "空き在庫スロットの数。これを下回ると、在庫スペースが少ないことが通知されます。ゼロは、在庫通知がオフになっていることを意味します。",
    NAME_MISSING_GEAR = "防具または武器が不足していることのリマインダー",
    TOOLTIP_MISSING_GEAR = "すべての防具や武器が装備されていない場合は覚えておいてください。",
    NAME_ACHIEVEMENTS = "実績の更新を表示",
    TOOLTIP_ACHIEVEMENTS = "実績の進行状況の更新をすべてチャット ウィンドウに表示する",
    
    HEADER_FOOD = "食べ物",
    NAME_REMIND_FOOD = "リマインダーを有効にする:",
    TOOLTIP_REMIND_FOOD = "食べ物がいつ使い果たされるか、いつ使い果たされるのかを覚えておいてください。",
   
    HEADER_LEADS = "アンティークの痕跡",
    NAME_REMIND_LEADS = "リードの有効期限が X 日後に切れるときのリマインダー:",
    TOOLTIP_REMIND_LEADS = "骨董品のリードが X 日後に期限切れになることを覚えておいてください。(0 = オフ)",
    LEADS_EXPIRING_FMT_MULTI = "複数の古遺物手がかりの有効",
    LEADS_EXPIRING_FMT_MULTI2 = "期限が切れます: %s",
    LEADS_EXPIRING_DAYS = "日",
    LEADS_EXPIRING_HOURS = "時間",

    HEADER_VAMPIRE = "吸血鬼レベル",
    NAME_REMIND_VAMPIRE = "リマインダーを有効にする:",
    TOOLTIP_REMIND_VAMPIRE = "吸血症レベルがいつ変化するか、そして変化した後を覚えておいてください。",
    NAME_REMIND_VAMP_IN_PVP = "PvP のみ:",
    TOOLTIP_REMIND_VAMP_IN_PVP = "ON の場合、リマインダーは PvP でのみ表示されます。OFF の場合、リマインダーは PvE でも表示されます。",
   
    HEADER_XP_SCROLLS = "XP スクロールとポーション",
    NAME_XP_SCROLLS = "リマインダーを有効にする:",
    TOOLTIP_XP_SCROLLS = "XP スクロールまたはポーションがいつ枯渇するか、またはいつ枯渇するかを覚えておいてください。",
   
    HEADER_TELVAR = "テルヴァールストーン",
    NAME_TELVAR = "この数の Tel Var Stone を覚えておいてください:",
    TOOLTIP_TELVAR = "指定された数を超えるテル ヴァー ストーンを所持している場合は覚えておいてください。",
    NAME_TELVAR_AUTODEPOSIT = "TelVar ストーンを自動的にデポジットします:",
    TOOLTIP_TELVAR_AUTODEPOSIT = "所持しているテル・ヴァール石が指定された数を超え、銀行家を訪問したときに自動的に預けます",
    NAME_TELVAR_RESERVE_AMT = "この数の Tel Var Stone を保持します:",
    TOOLTIP_TELVAR_RESERVE_AMT = "Tel Var ストーンを自動的にデポジットすると、その数値はボーナス乗数として保持されます。",
   
    HEADER_AP_SCROLLS = "AP スクロールとウォーパイ",
    NAME_AP_SCROLLS = "リマインダーを有効にする:",
    TOOLTIP_AP_SCROLLS = "ウォー ケーキまたは AP スクロールがいつ枯渇するか、またはいつ枯渇するかを覚えておいてください。",

}

if Reminderz.Localization and #localization == #Reminderz.Localization then
    ZO_ShallowTableCopy(localization, Reminderz.Localization)
end