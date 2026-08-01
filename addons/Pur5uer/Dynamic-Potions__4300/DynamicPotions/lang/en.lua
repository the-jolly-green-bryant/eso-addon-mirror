local strings = {
    DP_TIER_3 = "Sip",
    DP_TIER_10 = "Tincture",
    DP_TIER_20 = "Dram",
    DP_TIER_30 = "Potion",
    DP_TIER_40 = "Solution",
    DP_TIER_60 = "Elixir",
    DP_TIER_100 = "Panacea",
    DP_TIER_150 = "Distillate",
    DP_TIER_200 = "Essence",
}

for id, text in pairs(strings) do
    ZO_CreateStringId(id, text)
    SafeAddVersion(id, 1)
end