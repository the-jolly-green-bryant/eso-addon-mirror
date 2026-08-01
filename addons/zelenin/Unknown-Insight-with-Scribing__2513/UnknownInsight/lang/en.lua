local localization_strings = {
    SI_BINDING_NAME_UNKNOWN_INSIGHT_TOGGLE = "Toggle Unknown Insight",
}

for stringId, stringValue in pairs(localization_strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end