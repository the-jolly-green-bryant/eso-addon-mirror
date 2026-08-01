local APM = APMeter

local function BuildSettingsObject(db, default)

    local optionsData = {}
    local Spacer = {
        type = "description",
        title = "",
        text = [[
        ]]
    }

    optionsData[#optionsData+1] = Spacer
    optionsData[#optionsData+1] = {
        type = 'checkbox',
        name = 'Account Wide Settings',
        tooltip = 'Check for account wide addon settings',
        getFunc = function() return APM.db.settings.global end,
        setFunc = function(value)
    
            if value then
                APM.db = ZO_SavedVars:NewAccountWide('APMeterSettings', 2, nil, db_defaults)
            else
                APM.db = ZO_SavedVars:NewCharacterIdSettings('APMeterSettings', 2, GetWorldName(), db_defaults, nil)
            end
    
            db.settings.global = value
    
        end,
        requiresReload = true,
        default = true
    }

    local themeOptions = {}
    local themeList = APM.Theme.GetList()
    local innerThemeSubmenus = {}

    for i,value in ipairs(themeList) do

        local name = value.." Theme Options"

        innerThemeSubmenus[#innerThemeSubmenus + 1] = {
            type = "submenu",
            name = name,
            controls = APM.Theme.GetTheme(value).GetSettings(),
            reference = 'APM_innerThemeSettings_'..value
        }

    end

    themeOptions[#themeOptions + 1] = Spacer
    themeOptions[#themeOptions + 1] = {
        type = "description",
        title = "Set your Theme",
        text = [[Select a theme from the dropdown, there is a preview of the theme on the right hand side of the screen. One you've made your choice, you can click the "Active Theme" button below which will perform a |c9c9c9cReloadUI
        ]]
    }
    themeOptions[#themeOptions + 1] = Spacer
    themeOptions[#themeOptions + 1] = {
        type = "dropdown",
        name = "Theme",
        tooltip = "Select a theme and see the preview on the right hand side",
        choices = themeList,
        getFunc = function()
            db.settings.previewTheme = db.settings.selectedTheme

            zo_callLater(function()
                for i,value in ipairs(APM.Theme.GetList()) do
                    _G['APM_innerThemeSettings_'..value]:ClearAnchors()
                    _G['APM_innerThemeSettings_'..value]:SetAnchor(TOPLEFT, APM_ThemeAnchor, BOTTOMLEFT, 0, 15)
                    _G['APM_innerThemeSettings_'..value]:SetHidden(true)
                end
                _G['APM_innerThemeSettings_'..db.settings.selectedTheme]:SetHidden(false)
            end, 500)

            return db.settings.selectedTheme
        end,
        setFunc = function(value)
            db.settings.previewTheme = value
            for i,value in ipairs(APM.Theme.GetList()) do
                _G['APM_innerThemeSettings_'..value]:SetHidden(true)
            end
            _G['APM_innerThemeSettings_'..db.settings.previewTheme]:SetHidden(false)
            APM.Theme.SetPreview(db.settings.previewTheme)
            APM.Theme.Preview:StartPreview()
        end,
        width = "full",	--or "half" (optional)
        default = 'Modern',
        reference = 'APM_ThemeAnchor'
    }
    themeOptions[#themeOptions + 1] = Spacer

    for i, value in ipairs(innerThemeSubmenus) do

    themeOptions[#themeOptions + 1] = value

    end

    themeOptions[#themeOptions + 1] = Spacer
    themeOptions[#themeOptions + 1] = {
        type = "button",
        name = "Activate Theme",
        tooltip = "This will trigger a reloadUI to set the theme",
        func = function()
            db.settings.selectedTheme = db.settings.previewTheme
            ReloadUI()
        end,
        width = "full",	--or "full" (optional)
        warning = "Will need to reload the UI."
      }

    optionsData[#optionsData + 1] = Spacer

    local chatNotifications = {}

    chatNotifications[#chatNotifications + 1] = Spacer
    chatNotifications[#chatNotifications + 1] = {
        type = "checkbox",
        name = "Combat",
        tooltip = "Kills and Healing gain notifications",
        getFunc = function()
            return db.settings.apType.combat
        end,
        setFunc = function(value)
            db.settings.apType.combat = value
        end,
        default = default.apType.combat
    }
    chatNotifications[#chatNotifications + 1] = {
        type = "checkbox",
        name = "Repairs",
        getFunc = function()
            return db.settings.apType.repairs
        end,
        setFunc = function(value)
            db.settings.apType.repairs = value
        end,
        default = default.apType.repairs
    }
    chatNotifications[#chatNotifications + 1] = {
        type = "checkbox",
        name = "Defence ticks",
        getFunc = function()
            return db.settings.apType.defence
        end,
        setFunc = function(value)
            db.settings.apType.defence = value
        end,
        default = default.apType.defence
    }
    chatNotifications[#chatNotifications + 1] = {
        type = "checkbox",
        name = "Capture ticks",
        getFunc = function()
            return db.settings.apType.capture
        end,
        setFunc = function(value)
            db.settings.apType.capture = value
        end,
        default = default.apType.capture
    }
    chatNotifications[#chatNotifications + 1] = {
        type = "checkbox",
        name = "Quests",
        getFunc = function()
            return db.settings.apType.quests
        end,
        setFunc = function(value)
            db.settings.apType.quests = value
        end,
        default = default.apType.quests
    }
    chatNotifications[#chatNotifications + 1] = {
        type = "checkbox",
        name = "Matches",
        getFunc = function()
            return db.settings.apType.match
        end,
        setFunc = function(value)
            db.settings.apType.match = value
        end,
        default = default.apType.match
    }
    chatNotifications[#chatNotifications + 1] = {
        type = "checkbox",
        name = "Medals",
        getFunc = function()
            return db.settings.apType.medal
        end,
        setFunc = function(value)
            db.settings.apType.medal = value
        end,
        default = default.medal
    }
    chatNotifications[#chatNotifications + 1] = {
        type = "checkbox",
        name = "Resurrections",
        getFunc = function()
            return db.settings.apType.resurrections
        end,
        setFunc = function(value)
            db.settings.apType.resurrections = value
        end,
        default = default.apType.resurrections
    }
    chatNotifications[#chatNotifications + 1] = {
        type = "checkbox",
        name = "AP Streak",
        tooltip = "A tally of all AP earned before death",
        getFunc = function()
            return db.settings.apType.apstreak
        end,
        setFunc = function(value)
            db.settings.apType.apstreak = value
        end,
        default = default.apType.apstreak
    }
    chatNotifications[#chatNotifications + 1] = Spacer
    chatNotifications[#chatNotifications + 1] = {
        type = "description",
        title = "Notification minimal values",
        text = [[You can set minimal values of notifcations to display in your chat. For example, if you only want to display combat ap gains of 200 and above, you'd set 200 in the relative field below.
        ]]
    }
    chatNotifications[#chatNotifications + 1] = {
        type = "editbox",
        name = "Global minimal value",
        tooltip = "Will only notify in chat on ap gains that are over this value. Default is 0. kthxbai",
        getFunc = function()
            if tonumber(db.settings.minimalLimit) == nil then
                return default.globalMinimalLimit
            else
                return db.settings.minimalLimit
            end
        end,
        setFunc = function(value)
            if tonumber(value) ~= nil then
                db.settings.minimalLimit = tonumber(value)
            end
        end,
        default = default.minimalLimit
    }

    local buffNotifications = {}

    buffNotifications[#buffNotifications + 1] = Spacer
    buffNotifications[#buffNotifications+1] = {
		type = "header",
		name = "Torte Buff (AP Food)",
	}
    buffNotifications[#buffNotifications + 1] = Spacer
    buffNotifications[#buffNotifications + 1] = {
        type = "checkbox",
        name = "Food Buff Screen Alert",
        getFunc = function()
            return db.settings.notifications.cake_screen
        end,
        setFunc = function(value)
            db.settings.notifications.cake_screen = value
        end,
        default = default.notifications.cake_screen
    }
    buffNotifications[#buffNotifications + 1] = {
        type = "checkbox",
        name = "Food Buff Chat Alert",
        getFunc = function()
            return db.settings.notifications.cake_chat
        end,
        setFunc = function(value)
            db.settings.notifications.cake_chat = value
        end,
        default = default.notifications.cake_chat
    }

    buffNotifications[#buffNotifications + 1] = Spacer
    buffNotifications[#buffNotifications+1] = {
		type = "header",
		name = "Blessing of War (Delve Buff)",
	}
    buffNotifications[#buffNotifications + 1] = Spacer
    buffNotifications[#buffNotifications + 1] = {
        type = "checkbox",
        name = "Delve Buff Screen Alert",
        getFunc = function()
            return db.settings.notifications.delve_screen
        end,
        setFunc = function(value)
            db.settings.notifications.delve_screen = value
        end,
        default = default.notifications.delve_screen
    }
    buffNotifications[#buffNotifications + 1] = {
        type = "checkbox",
        name = "Delve Buff Chat Alert",
        getFunc = function()
            return db.settings.notifications.delve_chat
        end,
        setFunc = function(value)
            db.settings.notifications.delve_chat = value
        end,
        default = default.notifications.delve_chat
    }
    buffNotifications[#buffNotifications + 1] = Spacer
    buffNotifications[#buffNotifications+1] = {
		type = "header",
		name = "Pelinal's Ferocity (Event Scroll Buff)",
	}
    buffNotifications[#buffNotifications + 1] = Spacer
    buffNotifications[#buffNotifications + 1] = {
        type = "checkbox",
        name = "Pelinal Buff Screen Alert",
        getFunc = function()
            return db.settings.notifications.scroll_screen
        end,
        setFunc = function(value)
            db.settings.notifications.scroll_screen = value
        end,
        default = default.notifications.scroll_screen
    }
    buffNotifications[#buffNotifications + 1] = {
        type = "checkbox",
        name = "Pelinal Buff Chat Alert",
        getFunc = function()
            return db.settings.notifications.scroll_chat
        end,
        setFunc = function(value)
            db.settings.notifications.scroll_chat = value
        end,
        default = default.notifications.scroll_chat
    }

    optionsData[#optionsData + 1] = {
        type = "submenu",
        name = "Theme Options",
        controls = themeOptions,
        icon = "/esoui/art/miscellaneous/gamepad/gp_charnameicon.dds",
    }
    optionsData[#optionsData + 1] = {
        type = "submenu",
        name = "AP Notifcations",
        controls = chatNotifications,
        icon = "/esoui/art/currency/gamepad/gp_alliancepoints_64.dds",
    }
    optionsData[#optionsData + 1] = {
        type = "submenu",
        name = "Buff Notifications",
        controls = buffNotifications,
        icon = "/esoui/art/inventory/gamepad/gp_inventory_icon_all.dds",
    }

    optionsData[#optionsData + 1] = Spacer

    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Enable Killing Blow Animation",
        getFunc = function()
            return db.settings.enableFrame
        end,
        setFunc = function(value)
            db.settings.enableFrame = value
        end,
        default = default.enableFrame
    }
    optionsData[#optionsData + 1] = {
        type = "colorpicker",
        name = "Killing Blow Frame Colour",
        tooltip = "Color for Killing Blow Border",
        getFunc = function()
            return unpack(db.settings.frameColor)
        end,
        setFunc = function(r, g, b, a)
            db.settings.frameColor = {r, g, b, a}
            APM_KillingBlowScreenFrameOverlay:SetEdgeColor(ZO_ColorDef:New(r, g, b, a):UnpackRGBA())
        end,
        default = unpack(default.frameColor)
    }

    return optionsData

end

APM.BuildSettingsObject = BuildSettingsObject