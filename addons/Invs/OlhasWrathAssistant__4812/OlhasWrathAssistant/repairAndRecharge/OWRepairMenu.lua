function OWRepair_CreateSettings()
    if not OWA_SavedVariables.repairEnabled then return end

    local LAM = LibAddonMenu2
    if not LAM then return end

    local L = OWA_GetLanguageStrings()
    local panelId = "OWRepairSettings"

    local panel =
        LAM:RegisterAddonPanel(
            panelId,
            {
                type = "panel",
                name = "OWRepair&Recharge",
                displayName = L.REPAIR,
                author = "|c57ff80@Invs|r",
                version = "|c57ff800.1.1|r",
            }
        )

    OWA_AddGuildButton(
        panel,
        LAM
    )

    LAM:RegisterOptionControls(panelId, {
        { type = "description", text = "OWRepair settings will be added here." },
    })
end