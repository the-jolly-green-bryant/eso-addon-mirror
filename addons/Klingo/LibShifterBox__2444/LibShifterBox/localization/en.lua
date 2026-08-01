local LSBStrings = {
    LIBSHIFTERBOX_ALLREADY_LOADED   = "Is already loaded",
    LIBSHIFTERBOX_EMPTY             = "empty",
    LIBSHIFTERBOX_DRAG_MULTIPLE     = " and <<1[no further rows/1 further row/$d further rows]>>",
}

for key, value in pairs(LSBStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end