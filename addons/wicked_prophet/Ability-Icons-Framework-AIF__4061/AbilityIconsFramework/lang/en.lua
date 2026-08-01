local strings = {
    HP_POTION_NAME_3 = "Sip of Heroism",
    HP_POTION_NAME_10 = "Tincture of Heroism",
    HP_POTION_NAME_20 = "Dram of Heroism",
    HP_POTION_NAME_30 = "Potion of Heroism",
    HP_POTION_NAME_40 = "Solution of Heroism",
    HP_POTION_NAME_CP10 = "Elixir of Heroism",
    HP_POTION_NAME_CP50 = "Panacea of Heroism",
    HP_POTION_NAME_CP100 = "Distillate of Heroism",
    HP_POTION_NAME_CP150 = "Essence of Heroism",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end 