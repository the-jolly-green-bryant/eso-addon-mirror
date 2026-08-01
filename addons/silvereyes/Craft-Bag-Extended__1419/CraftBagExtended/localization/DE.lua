local strings = {
    ["SI_CBE_AND"]                                             = " und ",
    ["SI_CBE_PRIMARY_ACTIONS_USE_DEFAULT"]                     = "Def. Wert gilt für Schnell-Verstauen/Auspacken",
    ["SI_CBE_PRIMARY_ACTIONS_USE_DEFAULT_TOOLTIP"]             = "Die Default Checkbox im Verstauen/Auspacken Popup betrifft auch das Schnell-Verstauen/Auspacken. Wenn die Checkbox aktiviert wird, werden auch die Schnell-Verstauen/Auspacken Vorgänge diese Menge verwenden.\n\nWenn du diese Option deaktivierst, dann wird beim Schnell-Verstauen/Auspacken die komplette Menge des Materials verschoben!",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    CRAFTBAGEXTENDED_STRINGS[stringId] = value
end