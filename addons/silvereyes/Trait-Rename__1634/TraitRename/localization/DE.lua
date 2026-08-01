-- German strings TBD
local strings = {
    ["SI_PREPOSTEROUS_TEXT_TOOLTIP_FORMAT"] = "All references to the <<z:2>> trait '<<1>>' will be replaced with this custom text.",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    PREPOSTEROUS_STRINGS[stringId] = value
end