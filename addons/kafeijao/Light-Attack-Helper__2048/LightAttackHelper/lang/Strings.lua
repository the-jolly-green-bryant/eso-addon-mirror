local strings = {
    LAH_LIGHT_ATTACK = "Light Attack",
    LAH_HEAVY_ATTACK = "Heavy Attack",
}

for key, value in pairs(strings) do
   ZO_CreateStringId(key, value)
   SafeAddVersion(key, 1)
end
