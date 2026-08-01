local strings = {
    LAH_LIGHT_ATTACK = "Обычная атака",
    LAH_HEAVY_ATTACK = "Силовая атака",
}

for key, value in pairs(strings) do
   ZO_CreateStringId(key, value)
   SafeAddVersion(key, 1)
end
