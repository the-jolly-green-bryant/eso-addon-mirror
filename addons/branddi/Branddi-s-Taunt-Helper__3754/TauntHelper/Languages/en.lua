local localization_strings = {

    SI_BINDING_NAME_TAUNTHELPER_ADDTARGET = "Add custom target (developers)",
    SI_BINDING_NAME_TAUNTHELPER_DUMPDATA = "Dump data to chat (developers)",
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end