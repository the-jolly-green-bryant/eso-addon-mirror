function OWBanking_CreateSettings()

    if not OWA_SavedVariables.bankingEnabled then
        return
    end

    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local L = OWA_GetLanguageStrings()
    local panelId = "OWBankingSettings"

    local panel =
        LAM:RegisterAddonPanel(
            panelId,
            {
                type = "panel",
                name = "OWBanking",
                displayName = L.BANKING,
                author = "|c57ff80@Invs|r",
                version = "|c57ff800.1.1|r",
            }
        )

    OWA_AddGuildButton(
        panel,
        LAM
    )

    LAM:RegisterOptionControls(panelId, {
        {
            type = "description",
            text = "OWBanking settings will be added here.",
        },
    })
end