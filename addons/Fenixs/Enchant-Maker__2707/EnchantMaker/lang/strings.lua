local strings = {
    ENCHANTMAKER_MADE_WITH                      = "Made with: ",
    ENCHANTMAKER_CHECK_ALL                      = "Check all",
    ENCHANTMAKER_UNCHECK_ALL                    = "Uncheck all",
    ENCHANTMAKER_SEARCH                         = "Search",
    ENCHANTMAKER_SEARCH_AGAIN                   = "Search again",
    ENCHANTMAKER_POTENCY_HAVE                   = "Potency:",
    ENCHANTMAKER_ESSENCE_HAVE                   = "Essence:",
    ENCHANTMAKER_ASPECT_HAVE                    = "Aspect:",
    ENCHANTMAKER_SEARCH_RESULTS                 = "Search Results",
    ENCHANTMAKER_SHOW                           = "Show",
    ENCHANTMAKER_NEXXT                          = "Next",
    ENCHANTMAKER_PREVIOUS                       = "Previous",
    ENCHANTMAKER_USE_MISSING_RUNESTONES_SHORT   = "Include missing runestones",
    ENCHANTMAKER_USE_MISSING_RUNESTONES_LONG    = "Check this to search for enchantments that use runestones you do not have.",
    ENCHANTMAKER_USE_MISSING_RUNESTONES_WARNING = "Enabling this turns off automatic adding of runestones to table!",
    ENCHANTMAKER_USE_UNKNOWN_SKILL_SHORT        = "Include unknown skill",
    ENCHANTMAKER_USE_UNKNOWN_SKILL_LONG         = "Check this to search for enchantments that you lack the skill for.",
    ENCHANTMAKER_USE_UNKNOWN_TRAITS_SHORT       = "Include unknown translations in searches",
    ENCHANTMAKER_USE_UNKNOWN_TRAITS_LONG        = "Check this to include unknown translations in your searches.",
    ENCHANTMAKER_TRAINING_SHORT                 = "Unknown translations only",
    ENCHANTMAKER_TRAINING_LONG                  = "Only do enchanting that results in new known translations.",
    ENCHANTMAKER_TRAINING_WARNING               = "This will hide all results that do not result in learning a new translation!",
    ENCHANTMAKER_SAME_WINDOW_COORDS_SHORT       = "Windows in same positions",
    ENCHANTMAKER_SAME_WINDOW_COORDS_LONG        = "Check this to make the results window appear in the same position as the search window.",
    ENCHANTMAKER_REQUIRES_POTENCY               = "Requires Potency Improvement",
    ENCHANTMAKER_REQUIRES_ASPECT                = "Requires Aspect Improvement",
    ENCHANTMAKER_USE_TOP_POTENCY_RUNES          = "Use only top level potency runes",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
