ArchiveAdvisor = ArchiveAdvisor or {}
local ADDON = ArchiveAdvisor

ADDON.Settings = {}
ADDON.Settings.SAVED_VARIABLES_NAME = "ArchiveAdvisorSavedVars"
ADDON.Settings.SAVED_VARIABLES_VERSION = 1

local DEFAULTS = {
    recommendationsEnabled = true,
    recommendationStyle = "Balanced",
    showAvatarProgress = true,
}

local function OpenDonationMail()
    local opened = false
    local ok = pcall(function()
        if MAIN_MENU_KEYBOARD and type(MAIN_MENU_KEYBOARD.ShowScene) == "function" then
            MAIN_MENU_KEYBOARD:ShowScene("mailSend")
            opened = true
        end
        if ZO_MailSendToField and type(ZO_MailSendToField.SetText) == "function" then
            ZO_MailSendToField:SetText("@NPViral")
        end
        if ZO_MailSendSubjectField and type(ZO_MailSendSubjectField.SetText) == "function" then
            ZO_MailSendSubjectField:SetText("Skooma Fund")
        end
        if ZO_MailSendBodyField and type(ZO_MailSendBodyField.SetText) == "function" then
            ZO_MailSendBodyField:SetText("Thanks for Archive Advisor!")
        end
    end)

    if not ok or not opened then
        CHAT_SYSTEM:AddMessage("Could not open mail automatically. Send gold manually to @NPViral.")
    end
end

function ADDON.Settings:Initialize()
    ADDON.savedVariables = ZO_SavedVars:NewAccountWide(
        self.SAVED_VARIABLES_NAME,
        self.SAVED_VARIABLES_VERSION,
        nil,
        DEFAULTS
    )

    local LAM = LibAddonMenu2
    local panelName = "ArchiveAdvisorOptions"

    LAM:RegisterAddonPanel(panelName, {
        type = "panel",
        name = "Archive Advisor",
        displayName = "Archive Advisor",
        author = "@NPViral",
        version = ADDON.version,
        registerForRefresh = true,
        registerForDefaults = true,
    })

    local function MakeDonationButtonFullWidth(panel)
        if panel:GetName() ~= panelName then
            return
        end

        local control = ArchiveAdvisorDonationControl
        if control and control.button then
            control.button:ClearAnchors()
            control.button:SetAnchor(CENTER, control, CENTER)
            control.button:SetWidth(control:GetWidth())
        end

        CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", MakeDonationButtonFullWidth)
    end
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", MakeDonationButtonFullWidth)

    LAM:RegisterOptionControls(panelName, {
        {
            type = "description",
            text = "Archive Advisor marks the Verse or Vision that best fits your current build and Archive run.",
        },
        {
            type = "header",
            name = "Recommendations",
        },
        {
            type = "checkbox",
            name = "Recommendations",
            tooltip = "Show the checkmark and a short reason on the recommended Verse or Vision.",
            getFunc = function() return ADDON.savedVariables.recommendationsEnabled end,
            setFunc = function(value)
                ADDON.savedVariables.recommendationsEnabled = value
                ADDON:RefreshVisibleSelector()
            end,
            default = DEFAULTS.recommendationsEnabled,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Recommendation Style",
            tooltip = "Balanced weighs choices normally. Damage leans toward offensive choices. Survival leans toward defensive choices.",
            choices = { "Balanced", "Damage", "Survival" },
            getFunc = function() return ADDON.savedVariables.recommendationStyle end,
            setFunc = function(value)
                ADDON.savedVariables.recommendationStyle = value
                ADDON:RefreshVisibleSelector()
            end,
            default = DEFAULTS.recommendationStyle,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Avatar Progress",
            tooltip = "Show 1/3, 2/3, or 3/3 on Avatar Vision pieces to track set completion.",
            getFunc = function() return ADDON.savedVariables.showAvatarProgress end,
            setFunc = function(value)
                ADDON.savedVariables.showAvatarProgress = value
                ADDON:RefreshVisibleSelector()
            end,
            default = DEFAULTS.showAvatarProgress,
            width = "full",
        },
        {
            type = "header",
            name = "Support",
        },
        {
            type = "button",
            name = "Feeling generous?",
            tooltip = "Donations keep the skooma flowing.",
            func = OpenDonationMail,
            width = "full",
            reference = "ArchiveAdvisorDonationControl",
        },
    })
end
