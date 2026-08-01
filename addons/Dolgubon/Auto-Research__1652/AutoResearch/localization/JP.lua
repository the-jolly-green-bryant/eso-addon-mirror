local strings = {
    ["SI_AUTORESEARCH_BAGS"]                   = "研究に使う装備を探すバッグ",
    ["SI_AUTORESEARCH_STYLES"]                 = "研究に使ってよいスタイル",
    ["SI_AUTORESEARCH_SETS"]                   = "研究に使ってよいアイテムセット",
    ["SI_AUTORESEARCH_CHAT_MESSAGES"]          = "チャットメッセージ",
    ["SI_AUTORESEARCH_SHORT_PREFIX"]           = "短いプレフィックスを使用",
    ["SI_AUTORESEARCH_SHORT_PREFIX_TOOLTIP"]   = "チャットメッセージの先頭にAutoResearchではなくARを付けます。",
    ["SI_AUTORESEARCH_COLORED_PREFIX"]         = "AutoResearch 1の文字色のプレフィックスを使用",
    ["SI_AUTORESEARCH_COLORED_PREFIX_TOOLTIP"] = "チャットメッセージのプレフィックスの表示に、チャットメッセージの色ではなく、AutoResearch 1の青色（|c99CCEFAutoResearch|rまたは|c99CCEFAR|r）を使用します。",
    ["SI_AUTORESEARCH_CHAT_USE_SYSTEM_COLOR"]  = "システムメッセージと同じ色を使用する",
    ["SI_AUTORESEARCH_CHAT_COLOR"]             = "チャットメッセージの色",
    ["SI_AUTORESEARCH_WORD_DELIMITER"]         = "",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    AUTORESEARCH_STRINGS[stringId] = value
end