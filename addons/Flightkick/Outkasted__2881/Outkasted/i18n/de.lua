local strings = {
    OUTK_LEAVEINSTANCE_ZOS_REPORTS_NOT_IN_TRIAL = "ZOS meldet, dass Sie sich derzeit nicht in einem Dungeon oder einer Prüfung befinden, aber da diese API instabil zu sein scheint, lassen Sie mich trotzdem versuchen, Sie herauszuholen.",
    OUTK_LEAVEINSTANCE_EXITING_INSTANCE = "Verlassen der Instanz",

    -- Key bindings
    SI_BINDING_NAME_TP_OUTKASTED_GUILD_HALL = "Teleport zum Gildenhaus von Outkasted",
    SI_BINDING_NAME_LEAVE_INSTANCE = "Instanz verlassen",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
