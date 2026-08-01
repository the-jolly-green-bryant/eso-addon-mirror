local LSBStrings = {
    LIBSHIFTERBOX_ALLREADY_LOADED   = "すでにロードされています",
    LIBSHIFTERBOX_EMPTY             = "空の"
}

for key, value in pairs(LSBStrings) do
    SafeAddString(_G[key], value, 1)
end