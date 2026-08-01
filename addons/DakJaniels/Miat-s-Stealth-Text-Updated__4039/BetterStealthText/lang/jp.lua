local strings =
{
    -- Main state strings
    BETTERSTEALTHTEXT_INVISIBLE = "透明",
    BETTERSTEALTHTEXT_REVEALED = "暴露",
    BETTERSTEALTHTEXT_HIDING = "隠れる中",

    -- Addon menu and option strings
    BETTERSTEALTHTEXT_ADDON_NAME = "Miatの忍びテキスト",
    BETTERSTEALTHTEXT_ADDON_OPTIONS = "Miatの忍びテキストオプション",
    BETTERSTEALTHTEXT_ADDON_ENABLED = "アドオン有効",
    BETTERSTEALTHTEXT_ADDON_ENABLED_TOOLTIP = "オン - 有効、オフ - 無効",
    BETTERSTEALTHTEXT_ACCOUNTWIDE = "全キャラクター共通設定",
    BETTERSTEALTHTEXT_ACCOUNTWIDE_TOOLTIP = "オン - 各キャラクターに同じ設定を使用、オフ - 各キャラクターに個別の設定",
    BETTERSTEALTHTEXT_ACCOUNTWIDE_WARNING = "このオプションを有効にするとUIが再読み込みされます",
    BETTERSTEALTHTEXT_DISPLAY_OPTIONS = "表示オプション",
    BETTERSTEALTHTEXT_SCALE = "忍びテキストの拡大率を設定 (%)",
    BETTERSTEALTHTEXT_SCALE_TOOLTIP = "アイコンとテキストの拡大率は元のサイズの50%から400%までです",
    BETTERSTEALTHTEXT_STEALTH_COLORS_OPTIONS = "忍び色オプション",
    BETTERSTEALTHTEXT_SAME_HIDDEN_INVISIBLE = "隠れと透明状態に同じ色を使用",
    BETTERSTEALTHTEXT_SAME_HIDDEN_INVISIBLE_TOOLTIP = "オン - 有効（隠れの色が透明に適用される）、オフ - 無効（隠れと透明に個別の設定）",
    BETTERSTEALTHTEXT_HIDDEN_COLOR = "隠れ状態の色を選択",
    BETTERSTEALTHTEXT_HIDDEN_COLOR_TOOLTIP = "隠れ忍び状態のテキスト色を選択",
    BETTERSTEALTHTEXT_INVISIBLE_COLOR = "透明状態の色を選択",
    BETTERSTEALTHTEXT_INVISIBLE_COLOR_TOOLTIP = "透明忍び状態のテキスト色を選択",
    BETTERSTEALTHTEXT_SAME_ALMOST_HIDDEN_INVISIBLE = "ほぼ発見された隠れと透明状態に同じ色を使用",
    BETTERSTEALTHTEXT_SAME_ALMOST_HIDDEN_INVISIBLE_TOOLTIP = "オン - 有効（隠れの色が透明に適用される）ほぼ発見状態、オフ - 無効（隠れと透明に個別の設定）ほぼ発見状態",
    BETTERSTEALTHTEXT_HIDDEN_ALMOST_COLOR = "ほぼ発見された隠れ状態の色を選択",
    BETTERSTEALTHTEXT_HIDDEN_ALMOST_COLOR_TOOLTIP = "ほぼ発見された隠れ忍び状態のテキスト色を選択",
    BETTERSTEALTHTEXT_INVISIBLE_ALMOST_COLOR = "ほぼ発見された透明状態の色を選択",
    BETTERSTEALTHTEXT_INVISIBLE_ALMOST_COLOR_TOOLTIP = "ほぼ発見された透明忍び状態のテキスト色を選択",
    BETTERSTEALTHTEXT_ENABLE_HIDING = "'隠れる中'テキストを有効にする",
    BETTERSTEALTHTEXT_ENABLE_HIDING_TOOLTIP = "オン - 有効、オフ - 無効",
    BETTERSTEALTHTEXT_HIDING_COLOR = "隠れる中状態の色を選択",
    BETTERSTEALTHTEXT_HIDING_COLOR_TOOLTIP = "隠れる中忍び状態のテキスト色を選択",
    BETTERSTEALTHTEXT_DETECTED_COLOR = "発見状態の色を選択",
    BETTERSTEALTHTEXT_DETECTED_COLOR_TOOLTIP = "発見忍び状態のテキスト色を選択",
    BETTERSTEALTHTEXT_REVEALED_COLOR = "暴露状態の色を選択",
    BETTERSTEALTHTEXT_REVEALED_COLOR_TOOLTIP = "暴露忍び状態のテキスト色を選択",
    BETTERSTEALTHTEXT_DISGUISE_COLORS_OPTIONS = "変装色オプション",
    BETTERSTEALTHTEXT_DISGUISED_COLOR = "変装状態の色を選択",
    BETTERSTEALTHTEXT_DISGUISED_COLOR_TOOLTIP = "変装状態のテキスト色を選択",
    BETTERSTEALTHTEXT_SUSPICIOUS_COLOR = "疑わしい状態の色を選択",
    BETTERSTEALTHTEXT_SUSPICIOUS_COLOR_TOOLTIP = "疑わしい変装状態のテキスト色を選択",
    BETTERSTEALTHTEXT_DANGER_COLOR = "危険状態の色を選択",
    BETTERSTEALTHTEXT_DANGER_COLOR_TOOLTIP = "危険変装状態のテキスト色を選択",
    BETTERSTEALTHTEXT_DISCOVERED_COLOR = "発覚状態の色を選択",
    BETTERSTEALTHTEXT_DISCOVERED_COLOR_TOOLTIP = "発覚変装状態のテキスト色を選択"
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
