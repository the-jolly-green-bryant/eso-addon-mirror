local strings = {
    ["SI_QUALITYSORT_AUTO"]        = "品質による自動ソート",
    ["SI_QUALITYSORT_EQUIP_SLOT"]  = "装備スロット (例： 胴体、肩、など)",
    ["SI_QUALITYSORT_SORT_ORDER"]  = "ソート順",
    ["SI_QUALITYSORT_STYLE"]       = "スタイル",
    ["SI_QUALITYSORT_SET"]         = "セットアイテム",
    ["SI_QUALITYSORT_ID"]          = "アイテムＩＤ",
    ["SI_QUALITYSORT_VOUCHERS"]    = "依頼達成証の枚数",
    ["SI_QUALITYSORT_MASTER_WRIT"] = "マスター依頼の要件",
    ["SI_QUALITYSORT_ASCENDING"]   = "昇順",
    ["SI_QUALITYSORT_DESCENDING"]  = "降順",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    QUALITYSORT_STRINGS[stringId] = value
end