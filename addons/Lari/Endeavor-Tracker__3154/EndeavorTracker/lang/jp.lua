---------------------------------------------------
-- JAPANESE LOCALIZATION FOR ENDEAVOR TRACKER --
---------------------------------------------------

-- SafeAddString(SI_TIMEDACTIVITYTYPE0, "デイリー", 0)
-- SafeAddString(SI_TIMEDACTIVITYTYPE1, "ウィークリー", 1)

ZO_CreateStringId("ENDEAVOR_TRACKER_Misc_HighEndeavorReward", "高い報酬")
ZO_CreateStringId("ENDEAVOR_TRACKER_Misc_Rewards", "報酬")

-- DEFAULTS --
ZO_CreateStringId("ENDEAVOR_TRACKER_DefaultsDisplaySettings1", "オフ")
ZO_CreateStringId("ENDEAVOR_TRACKER_DefaultsDisplaySettings2", "行方不明のエンデバー")
ZO_CreateStringId("ENDEAVOR_TRACKER_DefaultsDisplaySettings3", "行方不明のデイリーエンデバーのみ")
ZO_CreateStringId("ENDEAVOR_TRACKER_DefaultsDisplaySettings4", "行方不明のウィークリーエンデバーのみ")
ZO_CreateStringId("ENDEAVOR_TRACKER_DefaultsDisplaySettings5", "常にオン")

-- PANEL --
ZO_CreateStringId("ENDEAVOR_TRACKER_HeaderEndeavorsCompleted", "<<1>>エンデバー：完了")
ZO_CreateStringId("ENDEAVOR_TRACKER_HeaderEndeavorsInProgress", "<<1>>エンデバー：進行中")
ZO_CreateStringId("ENDEAVOR_TRACKER_HeaderEndeavorsNotStarted", "<<1>>エンデバー：未開始")

-- CHAT MESSAGES --
ZO_CreateStringId("ENDEAVOR_TRACKER_ChatMsgEndeavorProgress", "<<1>>エンデバーの進歩")
ZO_CreateStringId("ENDEAVOR_TRACKER_ChatMsgEndeavorCompleted", "<<1>>エンデバーを完了")
ZO_CreateStringId("ENDEAVOR_TRACKER_ChatMsgNewEndeavorsAvailable", "新しいエンデバーが利用可能です！")
ZO_CreateStringId("ENDEAVOR_TRACKER_ChatMsgListRefreshed", "エンデバーのリストが更新されました！")

-- SETTINGS MENU --
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsTogglePanel", "|cECB8A2/et|r |c7E7E7E- エンデバートラッカーのパネルを表示/非表示する|r")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsToggleHistory", "|cECB8A2/ethistory|r |c7E7E7E- エンデバーの歴史を表示/非表示する|r")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsToggleSettings", "|cECB8A2/ethelp|r |c7E7E7E- これらの設定を開きる|r")

ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsFeedbackButton", "フィードバックを送信する")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsFeedbackTooltip", "バグレポート、フィードバック、提案をメールで送ってください！")

ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsHeaderDisplayOptions", "表示オプション")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsDisplayInCombat", "戦闘中に表示する")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsDisplayInDungeons", "ダンジョンと試練で表示する")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsDisplayInCyroAndBGs", "シロディール、帝都とバトルグラウンドで表示する")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsDisplayShortcutIcon", "ショートカットアイコンを表示する")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsDisplayCheckboxes", "チェックボックスを表示する")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsDisplayTimeRemaining", "リセットまでの残り時間を見る")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsHideCompleted", "完了したセクションを自動的に表示または非表示にする")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsShowPanel", "エンデバートラッカーパネルの表示設定")

ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsHeaderCustomization", "カスタマイズオプション")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsFontSize", "フォントサイズを変更する")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsDisplayBackground", "背景のテクスチャを表示する")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsBackdropAlpha", "背景の不透明度")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsColorCompleted", "完了したエンデバー")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsColorInProgress", "進行中のエンデバー")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsColorNotStartedHeader", "開始されていないエンデバー（ヘッダー）")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsColorNotStartedList", "開始されていないエンデバー（リスト）")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsPanelAnchor", "下からパネルをアンカーする")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsPanelAnchorTooltip", "有効にすると、Endeavor Tracker のパネルは下ではなく上に垂直に成長します。")

ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsHeaderChatOptions", "チャットオプション")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsPostProgressUpdates", "エンデバーの進捗状況の更新をチャットに投稿する")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsPostCompletionMessage", "エンデバーの完了をチャットに投稿する")

-- TOOLTIPS --
ZO_CreateStringId("ENDEAVOR_TRACKER_TooltipRefresh", "エンデバーのリストを更新する")
ZO_CreateStringId("ENDEAVOR_TRACKER_TooltipHistoryButton", "エンデバーの歴史")
ZO_CreateStringId("ENDEAVOR_TRACKER_TooltipEndeavorTotal", "合計エンデバーシール\n（クリックしてストアを開く）")
ZO_CreateStringId("ENDEAVOR_TRACKER_TooltipDailyExpandButton", "デイリーエンデバーを見る")
ZO_CreateStringId("ENDEAVOR_TRACKER_TooltipDailyCollapseButton", "デイリーエンデバーを隠す")
ZO_CreateStringId("ENDEAVOR_TRACKER_TooltipWeeklyExpandButton", "ウィークリーエンデバーを見る")
ZO_CreateStringId("ENDEAVOR_TRACKER_TooltipWeeklyCollapseButton", "ウィークリーエンデバーを隠す")

-- BINDINGS --
ZO_CreateStringId("SI_BINDING_NAME_ENDEAVOR_TRACKER_TOGGLE", "エンデバートラッカーを表示/非表示する")

-- HISTORY PANEL
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelDailiesButton", "完成したデイリー")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelWeekliesButton", "完成したウィークリー")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStatsButton", "統計")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelTrackingDate", "|cC5C29E以来の追跡：|r ")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelTrackingDateTooltip", "値は推定値であり、正確でない場合があります。")

ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelHeaderDate", "日付")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelHeaderName", "名前")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelHeaderRewards", "報酬")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelHeaderMisc", "その他")

ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_TotalDailyCompleted", "完了したデイリーエンデバー")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_TotalWeeklyCompleted", "完了したウィークリーエンデバー")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_TotalSealsDailies", "デイリーエンデバーからの合計シール")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_TotalSealsWeeklies", "ウィークリーエンデバーからの合計シール")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_AverageSealsDailies", "デイリーエンデバーからの平均シール")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_AverageSealsWeeklies", "ウィークリーエンデバーからの平均シール")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_MostSealsDailies", "単一のデイリーエンデバーから取得したほとんどのシール")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_MostSealsWeeklies", "単一のウィークリーエンデバーから取得したほとんどのシール")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_TotalLifetimeSeals", "生涯に取得したエンデバーシール")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_TotalSealsSpent", "合計で費やしたエンデバーシール")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_CurrentTotalSeals", "現在の合計エンデバーシール")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_TotalGoldAcquired", "エンデバーから取得した合計ゴールド")
