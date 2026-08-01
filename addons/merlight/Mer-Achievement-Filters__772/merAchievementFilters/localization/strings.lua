local function CreateString(stringId, stringValue, stringVersion)
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(_G[stringId], stringVersion)
end

CreateString("SI_MER_ACHIEVEMENT_FILTER_SHOW_STARTED", "Show Started", 1)
CreateString("SI_MER_ACHIEVEMENT_FILTER_WITH_DYE", "With Dye", 1)
CreateString("SI_MER_ACHIEVEMENT_FILTER_WITH_ITEM", "With Item", 1)
CreateString("SI_MER_ACHIEVEMENT_FILTER_WITH_TITLE", "With Title", 1)
