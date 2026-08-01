
-- Locale-specific strings
if not UNBOXER_STRINGS["SI_UNBOXER_AUTOLOOT"] then
    UNBOXER_STRINGS["SI_UNBOXER_AUTOLOOT"]            = "• "..GetString(SI_INTERFACE_OPTIONS_LOOT_USE_AUTOLOOT)
end
if not UNBOXER_STRINGS["SI_UNBOXER_SUMMARY"] then
    UNBOXER_STRINGS["SI_UNBOXER_SUMMARY"]             = "• "..GetString(SI_JOURNAL_PROGRESS_SUMMARY)
end
UNBOXER_STRINGS["SI_UNBOXER_CRAFTING_REWARDS"]       = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES212) .. "/" .. GetString(SI_JOURNAL_MENU_QUESTS)
UNBOXER_STRINGS["SI_UNBOXER_TRANSMUTATION"]          = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES211)
UNBOXER_STRINGS["SI_UNBOXER_LEGERDEMAIN"]            = zo_strformat("<<1>>", GetSkillLineNameById and GetSkillLineNameById(111) or GetSkillLineName(GetSkillLineIndicesFromSkillLineId(111)))
UNBOXER_STRINGS["SI_UNBOXER_TEL_VAR_STONES"]         = GetString(SI_GAMEPAD_INVENTORY_TELVAR_STONES)
UNBOXER_STRINGS["SI_UNBOXER_CYRODIIL_LOWER"]         = LocaleAwareToLower(zo_strformat("<<1>>", GetZoneNameById(181)))
UNBOXER_STRINGS["SI_UNBOXER_COLORED_PREFIX_TOOLTIP"] = zo_strformat(UNBOXER_STRINGS["SI_UNBOXER_COLORED_PREFIX_TOOLTIP"],
                                                                    UNBOXER_STRINGS["SI_UNBOXER_COLORED"],
                                                                    UNBOXER_STRINGS["SI_UNBOXER_COLORED_SHORT"])

for stringId, defaultValue in pairs(UNBOXER_DEFAULT_STRINGS) do
    local value = UNBOXER_STRINGS[stringId] or defaultValue
    ZO_CreateStringId(stringId, value)
    ZO_CreateStringId(stringId .. "_DEFAULT", defaultValue)
end
ZO_CreateStringId("SI_BINDING_NAME_UNBOX_ALL", GetString(SI_UNBOXER_UNBOX_ALL) .. "/" .. GetString(SI_UNBOXER_CANCEL))

UNBOXER_STRINGS = nil
UNBOXER_DEFAULT_STRINGS = nil