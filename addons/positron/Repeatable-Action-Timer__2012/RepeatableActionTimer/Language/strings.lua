local strings = {
    SI_RATMOD_NAME = "Action Timer",
    SI_RATMOD_FULL_NAME = "Repeatable Action Timer",
    SI_RATMOD_HINT = "This addon keeps track of when a repeatable action can be repeated.",
    SI_RATMOD_FADE_OUT = "Fade Out",
    SI_RATMOD_FADE_OUT_HINT = "Change the amount of time it takes an event to fade out.",
    SI_RATMOD_STABLES = "Stables",
    SI_RATMOD_STABLES_HINT = "Turn this off if you want to stop tracking Stable Master interactions.",
    SI_RATMOD_SHADOWY_SUPPLIER = "Shadowy Supplier",
    SI_RATMOD_SHADOWY_SUPPLIER_HINT = "Turn this off if you want to stop tracking Shadowy Supplier interactions.",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
