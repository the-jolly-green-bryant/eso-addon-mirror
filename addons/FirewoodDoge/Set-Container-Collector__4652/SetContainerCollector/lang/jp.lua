local strings = {
  SI_SCC_TOOLTIP_PROGRESS = "コレクション: <<1>>/<<2>>",
  SI_SCC_TOOLTIP_AUTO_RESOLVED = "自動検出: <<1>>",
  SI_SCC_TOOLTIP_AUTO_RESOLVED_WITH_SLOT = "自動検出: <<1>>（<<2>>）",
  SI_SCC_TOOLTIP_AUTO_RESOLVED_SLOT_HEAD = "頭のみ",
  SI_SCC_TOOLTIP_AUTO_RESOLVED_SLOT_SHOULDERS = "肩のみ",
  SI_SCC_TOOLTIP_NO_DATA = "コンテナデータが未登録です。",
  SI_SCC_SLASH_POOL_USAGE = "使い方: /scc pool <poolKey>  (例: maj_mystery, ap_elite, battleground_merchant)",
  SI_SCC_SLASH_POOL_UNKNOWN = "不明なプール: <<1>>",
  SI_SCC_SLASH_POOL_RESULT = "<<1>>: <<2>>/<<3>>",
  SI_SCC_SETTINGS_DESCRIPTION = "装備コンテナのツールチップに、アカウント全体のセットコレクション進捗を表示します。",
  SI_SCC_SETTINGS_AUTO_RESOLVE = "未登録コンテナの自動解決",
  SI_SCC_SETTINGS_AUTO_RESOLVE_TT = "有効にすると、DB未登録の未鑑定セット箱をゲームAPI（ContainerSetInfo）から自動的に判別して進捗を表示します。",
  SI_SCC_SETTINGS_TOOLTIP_FONT_SIZE = "ツールチップの文字サイズ",
  SI_SCC_SETTINGS_TOOLTIP_FONT_SIZE_TT = "コンテナツールチップの進捗表示に使う文字サイズです。",
  SI_SCC_SETTINGS_SLASH_HELP = "/scc pool <key> — プール進捗を表示。/scc debuglink <itemLink> — コンテナリンクを調査。",
}

for stringId, stringValue in pairs(strings) do
  ZO_CreateStringId(stringId, stringValue)
  SafeAddVersion(stringId, 1)
end
