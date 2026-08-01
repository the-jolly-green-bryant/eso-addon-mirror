local strings = {
    LAH_LIGHT_ATTACK = "軽攻撃",
    LAH_HEAVY_ATTACK = "重攻撃",
}

for key, value in pairs(strings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end
