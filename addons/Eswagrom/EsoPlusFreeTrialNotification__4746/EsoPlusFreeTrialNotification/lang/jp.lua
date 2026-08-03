-- Локальная таблица строк — ТРЕБОВАНИЕ ESOUI!
local strings = {
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_AVAILABLE"] = "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|c00FF00サブスクリプション利用可能|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_UNAVAILABLE"] = "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|cFF0000サブスクリプション利用不可|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_LIBADDOMENU"] = "|cFF0000[ESO Plus]|r LibAddonMenu-2.0 が見つかりません。確認してインストールしてください。",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_STRING_MENU"] = "|cCCECC0日付|r                |c98FB98ステータス|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM"] = "|cEEEE00@Eswagromに聞いてみよう...|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_A"] = "|c2DF5F8[@Eswagrom] ささやく: こんにちは、今サブスクリプションが利用可能です使用してください|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_C"] = "|c5EB9D7[@Eswagrom]: こんにちは、無料体験サブスクリプションについてどうですか？|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_B"] = "|c2DF5F8[@Eswagrom] ささやく: こんにちは、現在サブスクリプションは利用できません -_-|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION"] = "チャットに通知を送信",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION_A"] = "|c00FF00オフの場合、サブスクリプションに関するチャットメッセージは自動的に送信されず、手動チェック /esoplus のみになります。|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_FONT"] = "テーブル内のフォントサイズ",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_FONT_A"] = "|c00FF00ステータス履歴ウィンドウのフォントサイズを変更します（8から24まで）|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY"] = "サブスクリプション記録テーブル",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_A"] = "|c00FF00無料体験サブスクリプションの情報を表示する別ウィンドウを開きます|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_LOCK"] = "ウィンドウ位置を固定",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_LOCK_A"] = "|c00FF00画面上でウィンドウをドラッグできないようにします|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_AAA"] = "背景の透明度",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_BBB"] = "ウィンドウ位置をリセット",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CCC"] = "ステータス履歴を更新",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_UPDATE_WINDOW_H"] = "|c00FF00履歴テーブルウィンドウでバグが発生した場合は更新してください、解決するかもしれません。|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_AVA"] = "利用可能",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_UNAVA"] = "利用不可",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES"] = "記録用の行数",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES_A"] = "|c00FF00SavedVariables履歴ファイルに保存される行数 [ファイルサイズと記録期間に影響し、制限到達時は上書きされます]（100から5000までの可能な行数）|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_RESET_WINDOW"] = "|cEEEE00ウィンドウ位置がリセットされました。|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME"] = "|c00FF00EsoPlus記録|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS"] = "|cFF6347設定をリセット!!!|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS_A"] = "|cFF6347全てのアドオン設定を「インストール直後」の状態に戻します。ウィンドウ位置、サイズ、透明度、フォント、表示可否、行数（記録された制限以上の行を削除!!! 初期値2000行）と履歴をリセットします。|r",
    
    -- Информационное сабменю
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS"] = "|c00FF00アドオンについての情報|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_A"] = "|c9999FF/esoplus|r |cFF6347手動チェックのためチャットに入力！|r このアドオンは無料体験サブスクリプションの受領記録を保存するため、いつアクティベートされたか、あるいは存在しなかったかを常に正確に知ることができます。デフォルトでは履歴は最大2000エントリを保存します。実際には何を意味するのでしょう？テーブル内の各レコードは1日あたり1行を占めます。したがって、2000行の制限は約2000/365≈5.48年の期間をカバーします。言い換えれば、アドオンはサブスクリプション履歴を五年半近く保存します。",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AA"] = "|c00FF00このアドオンが使用するapi|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAA"] = "API（Application Programming Interface）— は、アドオンがゲームサーバーと対話するための一連のルールです。簡単に言えば、その機能範囲を定義する許可されたコマンドのリストです。実装には以下のメソッドが使用されました：",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AB"] = "|c00FF00* HasEsoPlusFreeTrialNotification()|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAB"] = "** _Returns:_ *bool* _hasFreeTrialNotification_",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AC"] = "|c00FF00* ClearEsoPlusFreeTrialNotification()|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAC"] = "このアドオンには履歴レコード用のユーザー表を呼び出すボタンをバインドする機能はありません。なぜならアドオンは純粋に情報提供目的だからです。この表はほとんど必要ありません。作者はゲームの制限（カスタムキー用に100スロットしか利用できない）のため、不要な要素でそれらを占有しないよう意図的にそのようなボタンを追加しませんでした。",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AD"] = "|c00FF00自動チェック機能!!!|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAD"] = "|c9999FFAサブスクリプションステータスの自動チェックは15分ごとに実行され、アドオン設定に関係なく行われます。これは同じ日に少し遅れてサブスクリプションがアクティベートされた場合でもステータスを見逃さないようにするためであり、チェック機能はシステムに負荷をかけません。このタイマーはパフォーマンスに完全に安全です。理由は次の通りです：|r |cFFFFC5実行頻度 15分ごと — これはゲームエンジンにとって非常に稀です。比較のため：ESOクライアント自体は毎秒数千のイベント（アニメーション、レンダリング、ネットワークパケット）を処理します。15分ごとの関数は海への一滴です。- ここでの操作はすべて論理的です：組み込みAPI（HasEsoPlus...）によるアカウントステータスの読み取り、ローカルテーブル（Lua table）の操作、そしてチャットへのメッセージ出力（d()）。重い計算、大規模配列のループ、ファイルやネットワークへの呼び出しはありません。ZO_SavedVars、d()、ClearEsoPlus... のような呼び出しはZOS開発者によって最適化されており、マイクロ秒で実行されます。|r |cffd700Ping|r はインターネット接続品質とESOサーバーの負荷によって決まります。クライアントのローカルLuaタイマーは、ゲーム自身が既に行っている以上にサーバーにデータを送信しません。HasEsoPlusFreeTrialNotification()関数はアカウントステータスのキャッシュを使用しています — 追加のネットワークトラフィックを作成しません。|c1E90FF他のアドオンとの比較。|r 多くの人気アドオンははるかに頻繁なタイマーを使用しています：|cADD8E6- Inventory Insight|r — インベントリを開くたびにチェック；|cADD8E6- Combat Metrics|r — 戦闘のティックごとに分析（毎秒数十回）；- 標準UI要素は毎秒60回以上更新されます。この|cADD8E6タイマー|r 900秒はこの背景に対して「時代に一度」のように見えます。",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_GENERAL_INFORMATION_ESOPLUS"] = "|ccdfff3情報|r"
}

-- Регистрация всех строк одним циклом — ТРЕБОВАНИЕ ESOUI!
for stringId, text in pairs(strings) do
    ZO_CreateStringId(stringId, text)
end