local strings = {
    OUTK_LEAVEINSTANCE_ZOS_REPORTS_NOT_IN_TRIAL = "Le ZOS signale que vous n'êtes actuellement pas dans un donjon ou un procès mais comme cette API semble instable, laissez-moi quand même essayer de vous en faire sortir.",
    OUTK_LEAVEINSTANCE_EXITING_INSTANCE = "Instance sortante",

    -- Key bindings
    SI_BINDING_NAME_TP_OUTKASTED_GUILD_HALL = "Téléport à la maison de guilde Outkasted",
    SI_BINDING_NAME_LEAVE_INSTANCE = "Laisser l'instance",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
