local AO = AutoOffline

---------------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------------
function AO.CreateSettings()
    local LAM2 = LibAddonMenu2
    if not LAM2 then return end

    local panelName = "Auto Offline"
    local user = GetUnitDisplayName("player")
    if user == AO.AUTHOR then panelName = "[Dev] " .. panelName end

    local panelData = {
        type = "panel",
        name = panelName,
        displayName = "|cFF7F00Auto|r |cFFFFFFOffline|r",
        author = "|cFF7F00" .. AO.AUTHOR .. "|r |cFFFFFF[EU]|r",
        version = AO.VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "checkbox",
            name = "|cFF7F00MASTERSWITCH|r (Turns the entire addon ON/OFF)",
            tooltip = "Enables or disables the entire addon.",
            getFunc = function() return AO.SV.enableAddon end,
            setFunc = function(value)
                AO.SV.enableAddon = value
                if value then AO.Enable() else AO.Disable() end
            end,
            default = AO.default.enableAddon,
        },
        {
            type = "divider",
        },
        {
            type = "checkbox",
            name = "Set Offline on Logout",
            tooltip = "Sets your status to offline right before logout.",
            getFunc = function() return AO.SV.enableOnLogout end,
            setFunc = function(value) AO.SV.enableOnLogout = value end,
            default = AO.default.enableOnLogout,
            disabled = function() return not AO.SV.enableAddon end,
        },
        {
            type = "divider",
        },
        {
            type = "dropdown",
            name = "Prompt Frequency",
            tooltip = "Select how often you want to be prompted.",
            choices = {"Every Hour", "On Every Login", "Once Per Hour On Login", "Once Per Day On Login", "Disabled"},
            getFunc = function() return AO.SV.promptFrequency end,
            setFunc = function(value)
                AO.SV.promptFrequency = value
                EVENT_MANAGER:UnregisterForUpdate(AO.NAME .. "HOURLY_CHECK")
                if value == "Every Hour" then
                    EVENT_MANAGER:RegisterForUpdate(AO.NAME .. "HOURLY_CHECK", 3600000, AO.CheckStatusDelayed)
                end
            end,
            default = AO.default.promptFrequency,
            disabled = function() return not AO.SV.enableAddon end,
        },
        {
            type = "slider",
            name = "Prompt Delay (sec)",
            tooltip = "How many seconds to wait after login.",
            min = 0, max = 30, step = 1, decimals = 0,
            getFunc = function() return AO.SV.delayPromt / 1000 end,
            setFunc = function(value) AO.SV.delayPromt = value * 1000 end,
            default = AO.default.delayPromt / 1000,
            disabled = function() return not AO.SV.enableAddon end,
        },
        {
            type = "divider",
        },
        {
            type = "description",
            text = "If you enjoy |cFF7F00Auto Offline|r, consider sharing your feedback or supporting its development. Your input and contributions are greatly appreciated!",
            width = "full"
        },
        {
            type = "button",
            name = "Feedback / Donate",
            tooltip = "Opens a mail to send feedback or donate to the author. <3",
            func = function()
                if IsConsoleUI() then
                    d(string.format("%s |cFFFFFFFeedback via Mail is currently only supported on PC.|r", AO.CHAT))
                    return
                end
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(function()
                    ZO_MailSendToField:SetText(AO.AUTHOR)
                    ZO_MailSendSubjectField:SetText("Auto Offline")
                    ZO_MailSendBodyField:TakeFocus()
                end, 250)
            end,
            width = "half"
        },
    }

    LAM2:RegisterAddonPanel(AO.NAME .. "Menu", panelData)
    LAM2:RegisterOptionControls(AO.NAME .. "Menu", optionsData)
end