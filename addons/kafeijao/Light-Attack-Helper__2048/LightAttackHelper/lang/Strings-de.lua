local strings = {
    LAH_LIGHT_ATTACK = "leichter", -- translate: "light"
    LAH_HEAVY_ATTACK = "schwerer", -- translate: "heavy"
}

for key, value in pairs(strings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end
