local strings = {
    ["SI_CBE_AND"]                                             = " и ",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    CRAFTBAGEXTENDED_STRINGS[stringId] = value
end