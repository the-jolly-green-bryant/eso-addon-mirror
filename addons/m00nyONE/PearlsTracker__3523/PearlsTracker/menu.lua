PearlsTracker = PearlsTracker or {}
PearlsTracker.menu = PearlsTracker.menu or {}

local PT = PearlsTracker

function PT.donate()
    SCENE_MANAGER:Show('mailSend')
    zo_callLater(
            function()
                -- fill out messagebox
                ZO_MailSendToField:SetText("@m00nyONE")
                ZO_MailSendSubjectField:SetText("Donation for PearlsTracker")
                QueueMoneyAttachment(1)
                ZO_MailSendBodyField:TakeFocus()
            end,
            250)
end

function PT.menu.createAddonMenu()
    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = PT.name,
        displayName = "|cFFFF00PearlsTracker|r",
        version = "".. PT.version,
        author = PT.author,
        donation = PT.donate,
        website = "https://www.esoui.com/downloads/author-67051.html",
        feedback = "https://www.esoui.com/downloads/info3523-PearlsTracker.html#comments",
        slashCommand = "/ptsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(PT.name.."Options", panelData)

    local options = {
        {
            type = "header",
            name = "General Settings"
        },
        {
          type = "checkbox",
          name = "enable",
          tooltip = "Enable/Disable PearlsTracker.",
          getFunc = function() return PT.SV.enabled end,
          setFunc = function(value)
              PT.SV.enabled = value
              if PT.SV.enabled then
                  PT.Enable()
              else
                  PT.Disable()
              end
          end,
          default = true,
          width = "full",
        },
        --{
        --    type = "checkbox",
        --    name = "unlock UI",
        --    tooltip = "Automatically hides when a menu or other screen is opened.",
        --    getFunc = function() return not PT.SV.autoHide end,
        --    setFunc = function(value)
        --        PT.SV.autoHide = not value
        --        if PT.SV.autoHide then
        --            PT.isHidden = true
        --            PT.UnregisterAutoHide()
        --            PT.RegisterAutoHide()
        --        else
        --            PT.isHidden = false
        --            PT.UnregisterAutoHide()
        --        end
        --    end,
        --    default = true,
        --    width = "full",
        --},
        {
            type = "slider",
            name = "update interval",
            tooltip = "Rate at which informations should be updated.",
            getFunc = function() return PT.SV.updateInterval end,
            setFunc = function(value) PT.SV.updateInterval = value end,
            min = 100,
            max = 1000,
            step = 2,
            default = 500,
            width = "full",
            requiresReload = true,
        },
        {
            type = "divider",
        },
        --{
        --    type = "header",
        --    name = "resource & colors"
        --},
        {
            type = "checkbox",
            name = "show resource",
            tooltip = "Show main resource in percent under the main icon.",
            getFunc = function()
                return not PT.SV.resource.hide
            end,
            setFunc = function(value)
                PT.SV.resource.hide = not value
                PT.icon.HideResource(PT.SV.resource.hide)
            end,
            default = true,
            width = "full",
        },
        {
            type = "slider",
            name = "resource font size",
            tooltip = "Font size of the resource text.",
            getFunc = function()
                return PT.SV.resource.fontSize
            end,
            setFunc = function(value)
                PT.SV.resource.fontSize = value
                PT.icon.SetResourceFontSize(value)
            end,
            min = 10,
            max = 72,
            step = 2,
            default = 40,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Below 30% Color",
            tooltip = "Color when Pearls can proc.",
            getFunc = function() return unpack(PT.SV.colors.belowThreshold) end,
            setFunc = function(r,g,b,a)
                PT.SV.colors.belowThreshold = {r,g,b,a}
            end,
            default = {0, 1, 0, 1}
        },
        {
            type = "colorpicker",
            name = "Above 30% Color",
            tooltip = "Color when Pearls can't proc.",
            getFunc = function() return unpack(PT.SV.colors.aboveThreshold) end,
            setFunc = function(r,g,b,a)
                PT.SV.colors.aboveThreshold = {r,g,b,a}
            end,
            default = {1, 0, 0, 1}
        },
        {
            type = "divider",
        },
        {
            type = "checkbox",
            name = "show ulti gained",
            tooltip = "Show ulti gained in points next to the main icon.",
            getFunc = function()
                return not PT.SV.ultiGain.hide
            end,
            setFunc = function(value)
                PT.SV.ultiGain.hide = not value
                PT.icon.HideUltiGain(PT.SV.ultiGain.hide)
                if PT.SV.ultiGain.hide then
                    PT.UnregisterUltiGain()
                else
                    PT.RegisterUltiGain()
                end
            end,
            default = true,
            width = "full",
        },
        {
            type = "checkbox",
            name = "reset ulti gained on combat",
            tooltip = "resets ulti points gained on entering combat.",
            getFunc = function()
                return PT.SV.ResetUltiGainOnEnterCombat
            end,
            setFunc = function(value)
                PT.SV.ResetUltiGainOnEnterCombat = value
            end,
            default = true,
            disabled = true,
            width = "full",
        },
        {
            type = "slider",
            name = "ulti gained font size",
            tooltip = "Font size of the ulti gained text.",
            getFunc = function()
                return PT.SV.ultiGain.fontSize
            end,
            setFunc = function(value)
                PT.SV.ultiGain.fontSize = value
                PT.icon.SetUltiGainFontSize(value)
            end,
            min = 10,
            max = 72,
            step = 2,
            default = 30,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "ulti gained color",
            tooltip = "Text color of the ulti gained.",
            getFunc = function() return unpack(PT.SV.colors.ultiGain) end,
            setFunc = function(r,g,b,a)
                PT.SV.colors.ultiGain = {r,g,b,a}
            end,
            default = {1, 1, 0, 1}
        },

    }

    LAM:RegisterOptionControls(PT.name.."Options", options)
end

