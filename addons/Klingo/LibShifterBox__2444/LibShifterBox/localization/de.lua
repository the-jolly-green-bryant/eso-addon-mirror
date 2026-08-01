local LSBStrings = {
    LIBSHIFTERBOX_ALLREADY_LOADED   = "Ist bereits geladen",
    LIBSHIFTERBOX_EMPTY             = "leer",
    LIBSHIFTERBOX_DRAG_MULTIPLE     = " und <<1[keine weitere Zeile/1 weitere Zeile/$d weitere Zeilen]>>",
}

for key, value in pairs(LSBStrings) do
    SafeAddString(_G[key], value, 1)
end