local strings = {
    OUTK_LEAVEINSTANCE_ZOS_REPORTS_NOT_IN_TRIAL = "Игра сообщает, что вы в настоящее время не в подземелье или на испытании, но т.к. этот API по-видимому нестабилен, я попробую вас вытащить.",
    OUTK_LEAVEINSTANCE_EXITING_INSTANCE = "В процессе выхода",

    -- Key bindings
    SI_BINDING_NAME_TP_OUTKASTED_GUILD_HALL = "Переместиться в гильдхолл",
    SI_BINDING_NAME_LEAVE_INSTANCE = "Покинуть местоположение",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
