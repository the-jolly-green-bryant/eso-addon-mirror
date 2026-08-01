
LeoDolmenRunner_Settings = ZO_Object:Subclass()
local LAM = LibAddonMenu2

function LeoDolmenRunner_Settings:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function LeoDolmenRunner_Settings:Initialize()
end

function LeoDolmenRunner_Settings:CreatePanel()
    local OptionsName = "LeoDolmenRunnerOptions"
    local panelData = {
        type = "panel",
        name = LeoDolmenRunner.name,
        slashCommand = "/ldropt",
        displayName = "|c39B027"..LeoDolmenRunner.displayName.."|r",
        author = "@LeandroSilva",
        version = LeoDolmenRunner.version,
        registerForRefresh = true,
        registerForDefaults = true,
        website = "https://www.esoui.com/downloads/info2534-LeosDolmenRunner.html"
    }
    LAM:RegisterAddonPanel(OptionsName, panelData)

    local optionsData = {
        {
            type = "header",
            name = "|c3f7fffRunner|r"
        },{
            type = "checkbox",
            name = "Auto dismiss assistants",
            default = true,
            width = "full",
            getFunc = function() return LeoDolmenRunner.settings.runner.autoDismiss end,
            setFunc = function(value) LeoDolmenRunner.settings.runner.autoDismiss = value end,
        },{
            type = "checkbox",
            name = "Auto reapply holiday buff",
            default = true,
            width = "full",
            getFunc = function() return LeoDolmenRunner.settings.runner.reapplyBuff end,
            setFunc = function(value) LeoDolmenRunner.settings.runner.reapplyBuff = value end,
        },{
            type = "header",
            name = "|c3f7fffAuto Inviter|r"
        },{
            type = "checkbox",
            name = "Auto kick offline",
            default = true,
            width = "full",
            getFunc = function() return LeoDolmenRunner.settings.inviter.autoKick end,
            setFunc = function(value) LeoDolmenRunner.settings.inviter.autoKick = value end,
        },{
            name = "Auto kick delay (secs)",
            type = "slider",
            getFunc = function() return LeoDolmenRunner.settings.inviter.kickDelay end,
            setFunc = function(value) LeoDolmenRunner.settings.inviter.kickDelay = value end,
            min = 10,
            max = 600,
            default = 60,
        },{
            name = "Max group size",
            type = "dropdown",
            choices = {4, 12, 24},
            getFunc = function() return LeoDolmenRunner.settings.inviter.maxSize end,
            setFunc = function(value) LeoDolmenRunner.settings.inviter.maxSize = value end,
            default = 24,
        },{
            type = "checkbox",
            name = "Enable Blacklist",
            default = true,
            width = "full",
            getFunc = function() return LeoDolmenRunner.settings.inviter.enableBlacklist end,
            setFunc = function(value) LeoDolmenRunner.settings.inviter.enableBlacklist = value end,
        }
    }
    LAM:RegisterOptionControls(OptionsName, optionsData)
end

function LeoDolmenRunner_Settings_OnMouseEnter(control, tooltip)
    InitializeTooltip(InformationTooltip, control, BOTTOMLEFT, 0, -2, TOPLEFT)
    SetTooltipText(InformationTooltip, tooltip)
end
