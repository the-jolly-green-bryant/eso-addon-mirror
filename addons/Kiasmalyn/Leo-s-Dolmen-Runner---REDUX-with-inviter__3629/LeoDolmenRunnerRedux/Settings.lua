LeoDolmenRunnerRedux_Settings = ZO_Object:Subclass()
local LAM = LibAddonMenu2

function LeoDolmenRunnerRedux_Settings:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function LeoDolmenRunnerRedux_Settings:Initialize()
end

function LeoDolmenRunnerRedux_Settings:CreatePanel()
    local OptionsName = "LeoDolmenRunnerReduxOptions"
    local panelData = {
        type = "panel",
        name = LeoDolmenRunnerRedux.name,
        slashCommand = "/ldropt",
        displayName = "|c39B027" .. LeoDolmenRunnerRedux.displayName .. "|r",
        author = "@LeandroSilva and @Kiasmalyn",
        version = LeoDolmenRunnerRedux.version,
        registerForRefresh = true,
        registerForDefaults = true,
        website = "https://www.esoui.com/downloads/info3629-LeosDolmenRunner-REDUX.html"
    }
    LAM:RegisterAddonPanel(OptionsName, panelData)

    local optionsData = {
        {
            type = "header",
            name = "|c3f7fffRunner|r"
        }, {
            type = "checkbox",
            name = "Auto dismiss assistants",
            default = true,
            width = "full",
            getFunc = function()
                return LeoDolmenRunnerRedux.settings.runner.autoDismiss
            end,
            setFunc = function(value)
                LeoDolmenRunnerRedux.settings.runner.autoDismiss = value
            end,
        }, {
            type = "checkbox",
            name = "Auto reapply holiday buff",
            default = true,
            width = "full",
            getFunc = function()
                return LeoDolmenRunnerRedux.settings.runner.reapplyBuff
            end,
            setFunc = function(value)
                LeoDolmenRunnerRedux.settings.runner.reapplyBuff = value
            end,
        }, {
            type = "header",
            name = "|c3f7fffAuto Inviter|r"
        }, {
            type = "checkbox",
            name = "Auto kick offline",
            default = true,
            width = "full",
            getFunc = function()
                return LeoDolmenRunnerRedux.settings.inviter.autoKick
            end,
            setFunc = function(value)
                LeoDolmenRunnerRedux.settings.inviter.autoKick = value
            end,
        }, {
            name = "Auto kick delay (secs)",
            type = "slider",
            getFunc = function()
                return LeoDolmenRunnerRedux.settings.inviter.kickDelay
            end,
            setFunc = function(value)
                LeoDolmenRunnerRedux.settings.inviter.kickDelay = value
            end,
            min = 10,
            max = 600,
            default = 60,
        }, {
            name = "Max group size",
            type = "dropdown",
            choices = { 4, 12, 24 },
            getFunc = function()
                return LeoDolmenRunnerRedux.settings.inviter.maxSize
            end,
            setFunc = function(value)
                LeoDolmenRunnerRedux.settings.inviter.maxSize = value
            end,
            default = 12,
        }, {
            type = "checkbox",
            name = "Enable Blacklist",
            default = true,
            width = "full",
            getFunc = function()
                return LeoDolmenRunnerRedux.settings.inviter.enableBlacklist
            end,
            setFunc = function(value)
                LeoDolmenRunnerRedux.settings.inviter.enableBlacklist = value
            end,
        }
    }
    LAM:RegisterOptionControls(OptionsName, optionsData)
end

function LeoDolmenRunnerRedux_Settings_OnMouseEnter(control, tooltip)
    InitializeTooltip(InformationTooltip, control, BOTTOMLEFT, 0, -2, TOPLEFT)
    SetTooltipText(InformationTooltip, tooltip)
end
