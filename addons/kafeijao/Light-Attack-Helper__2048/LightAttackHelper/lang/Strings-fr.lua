local strings = {
    LAH_LIGHT_ATTACK = "Attaque légère",
    LAH_HEAVY_ATTACK = "Attaque lourde",
}

for key, value in pairs(strings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end
