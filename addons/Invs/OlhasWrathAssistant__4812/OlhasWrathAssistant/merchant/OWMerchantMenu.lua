function OWMerchant_CreateSettings()

    if not OWA_SavedVariables.merchantEnabled then
        return
    end

    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local L = OWA_GetLanguageStrings()
    local panelId = "OWMerchantSettings"

    local panel =
        LAM:RegisterAddonPanel(
            panelId,
            {
                type = "panel",
                name = "OWMerchant",
                displayName = L.MERCHANT,
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
            text = "OWMerchant settings will be added here.",
        },
    })
end