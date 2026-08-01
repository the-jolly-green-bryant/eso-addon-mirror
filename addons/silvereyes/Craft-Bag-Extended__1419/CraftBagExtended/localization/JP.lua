local strings = {
    ["SI_CBE_AND"]                                             = "と",
    ["SI_CBE_WORD_BREAK"]                                      = "",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    CRAFTBAGEXTENDED_STRINGS[stringId] = value
end