local strings = {
    OUTK_LEAVEINSTANCE_ZOS_REPORTS_NOT_IN_TRIAL = "ZOS reports you're currently not inside a dungeon or trial but since this API seems unstable let me try to get you out anyway.",
    OUTK_LEAVEINSTANCE_EXITING_INSTANCE = "Exiting instance",

    -- Key bindings
    SI_BINDING_NAME_TP_OUTKASTED_GUILD_HALL = "Teleport to Outkasted guild house",
    SI_BINDING_NAME_LEAVE_INSTANCE = "Leave instance",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
