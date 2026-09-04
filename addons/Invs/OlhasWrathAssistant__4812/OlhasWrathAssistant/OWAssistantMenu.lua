function OWA_GetLanguageStrings()

    if OWA_SavedVariables.language == "ua" then
        return OWA_LANG_UA
    end

    return OWA_LANG_EN
end

function OWA_AddGuildButton(
    panel,
    LAM
)
    if not panel
        or not panel.info
        or not LAM
        or panel.owaGuildButton
    then
        return
    end

    local guildLabel = " Guild"

    if OWA_SavedVariables.language == "ua" then
        guildLabel = " Гільдія"
    end

    local guildLink =
        "|H1:guild:846944|hOlha's Wrath UA|h"

    local separatorLabel =
        WINDOW_MANAGER:CreateControl(
            nil,
            panel,
            CT_LABEL
        )

    separatorLabel:SetFont(
        LAM.util.L["PANEL_INFO_FONT"]
    )

    separatorLabel:SetColor(
        1,
        1,
        1,
        1
    )

    separatorLabel:SetText(" - ")

    separatorLabel:SetAnchor(
        TOPLEFT,
        panel.info,
        TOPRIGHT,
        0,
        0
    )

    local separatorWidth, separatorHeight =
        separatorLabel:GetTextDimensions()

    separatorLabel:SetDimensions(
        separatorWidth,
        separatorHeight
    )

    local guildButton =
        WINDOW_MANAGER:CreateControl(
            nil,
            panel,
            CT_BUTTON
        )

    guildButton:SetFont(
        LAM.util.L["PANEL_INFO_FONT"]
    )

    guildButton:SetAnchor(
        TOPLEFT,
        separatorLabel,
        TOPRIGHT,
        0,
        0
    )

    guildButton:SetText(guildLabel)

    guildButton:SetNormalFontColor(
        0.34,
        1,
        0.50,
        1
    )

    guildButton:SetMouseOverFontColor(
        1,
        1,
        1,
        1
    )

    guildButton:SetClickSound("Click")

    guildButton:SetHandler(
        "OnClicked",
        function()
            ZO_LinkHandler_OnLinkClicked(
                guildLink,
                MOUSE_BUTTON_INDEX_LEFT
            )
        end
    )

    local buttonWidth, buttonHeight =
        guildButton:GetLabelControl():GetTextDimensions()

    guildButton:SetDimensions(
        buttonWidth,
        buttonHeight
    )

    panel.owaGuildSeparator =
        separatorLabel

    panel.owaGuildButton =
        guildButton
end

function OWA_CreateSettings()

    local L = OWA_GetLanguageStrings()

    local panelData = {
        type = "panel",
        name = L.ADDON_NAME,
        displayName = L.ADDON_NAME,
        author = "|c57ff80@Invs|r",
        version = "|c57ff800.1.1|r",
    }

    local LAM = LibAddonMenu2

    if not LAM then
        d("[OWA] LibAddonMenu-2.0 not found.")
        return
    end

    local function DevelopmentCheckbox(
    name,
    warning,
    displayedValue
)
    return {
        type = "checkbox",
        name = name,

        getFunc = function()
            return displayedValue == true
        end,

        setFunc = function()
            -- Цей пункт заблокований.
        end,

        default = displayedValue == true,
        disabled = true,
        warning = warning,
    }
end

local options = {
    {
        type = "dropdown",
        name = L.LANGUAGE,

        choices = {
            L.ENGLISH,
            L.UKRAINIAN,
        },

        getFunc = function()
            if OWA_SavedVariables.language == "ua" then
                return L.UKRAINIAN
            end

            return L.ENGLISH
        end,

        setFunc = function(value)
            if value == L.UKRAINIAN then
                OWA_SavedVariables.language = "ua"
            else
                OWA_SavedVariables.language = "en"
            end
        end,

        default = L.ENGLISH,

        requiresReload = true,
        warning = L.RELOAD_UI_WARNING,
        reference = "OWAssistantLanguageDropdown",
    },

    DevelopmentCheckbox(
        L.ACCOUNT_WIDE,
        L.ACCOUNT_WIDE_IN_DEVELOPMENT,
        true
    ),

    DevelopmentCheckbox(
        L.BANKING,
        L.MODULE_IN_DEVELOPMENT,
        false
    ),

    {
        type = "checkbox",
        name = L.DECONSTRUCT,

        getFunc = function()
            return OWA_SavedVariables.deconstructEnabled
        end,

        setFunc = function(value)
            OWA_SavedVariables.deconstructEnabled = value
        end,

        default = true,

        requiresReload = true,
        warning = L.RELOAD_UI_WARNING,
        reference = "OWAssistantDeconstructCheckbox",
    },

    DevelopmentCheckbox(
        L.MERCHANT,
        L.MODULE_IN_DEVELOPMENT,
        false
    ),

    DevelopmentCheckbox(
        L.REPAIR,
        L.MODULE_IN_DEVELOPMENT,
        false
    ),
}
        

    local panel =
        LAM:RegisterAddonPanel(
            "OWAssistantSettings",
            panelData
        )

    OWA_AddGuildButton(
        panel,
        LAM
    )

    local function SetLocalizedReloadWarning(
        control
    )
        if not control or not control.warning then
            return
        end

        control.UpdateWarning = function(self)
            self.warning.data = {
                tooltipText =
                    L.RELOAD_UI_WARNING,
            }

            self.warning:SetHidden(false)
        end

        control:UpdateWarning()
    end

    CALLBACK_MANAGER:RegisterCallback(
        "LAM-PanelControlsCreated",
        function(createdPanel)
            if createdPanel ~= panel then
                return
            end

            SetLocalizedReloadWarning(
                OWAssistantLanguageDropdown
            )

            SetLocalizedReloadWarning(
                OWAssistantDeconstructCheckbox
            )
        end
    )

    LAM:RegisterOptionControls(
        "OWAssistantSettings",
        options
    )
end