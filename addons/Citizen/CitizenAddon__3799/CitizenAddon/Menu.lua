CitizenAddonMenu = {
    name = "CitizenAddonMenu",
}

--Refresh specefic option
function CitizenAddonMenu.UpdateTheOption(key, list)
    if key==nil or list==nil then
        return
    end
    key:UpdateChoices(list)
end

--Menu creator
function CitizenAddonMenu.AddonMenu()
    local menuOptions = {
        type = "panel",
        name = CitizenAddon.name,
        displayName = CitizenAddon.name,
        author = "|cfa9c1bCitizen|r",
        version = "1.1.04",
        slashCommand = "/citim",
        registerForRefresh = true,
        registerForDefaults = false,
    }
    local dataTable = {
        {--Addon description
            type = "description",
            text = "Citizen's home made addon cuz I can, why not?, use |cffff00/citi|r to get list of commands"
        },
        {------
            type = "divider",
        },
        {--Show/Hide notifications sample button
            type = "button",
            name = "Show/Hide notification UI",
            width = "half",
            func =
                function()
                    CitizenNotifier.ShowAndHideSample()
                end,
        },
        {--General Options
            type = "header",
            name = "|cbfffffGeneral Options|r",
        },
        {--Real Time Clock
            type = "checkbox",
            name = "Real Time Clock",
            tooltip = "Shows IRL clock based on your PC time zone",
            getFunc =
                function()
                    return CitizenAddon.generalOptions.realTimeClock.active
                end,
            setFunc =
                function(value)
                    CitizenAddon.generalOptions.realTimeClock.active = value
                end,
            warning = "|cff0000Request reload UI|r",
        },
        {--Addon manager
            type = "submenu",
            name = "Addon manager",
            controls = {
                {--Description of check and print required libraries
                    type = "description",
                    title = "Print the name of useless Libraries",
                    width = "half",
                },
                {--Check and print required libraries
                    type = "button",
                    name = "Addons dependencies",
                    tooltip = "Will print the name of Libraries that you have active but no current active addon required it in the chat box",
                    width = "half",
                    func =
                        function ()
                            CitizenAddonManager.CheckRequiredLibraries()
                        end
                },
                { ------
                    type = "divider",
                },
                {--Active Addons counter
                    type = "checkbox",
                    name = "Active addons counter",
                    tooltip = "Show amount of Active/All addons in ADD-ONS menu",
                    getFunc =
                        function()
                            return CitizenAddon.generalOptions.addonManager.activeAddonsCounter
                        end,
                    setFunc =
                        function(value)
                            CitizenAddon.generalOptions.addonManager.activeAddonsCounter = value
                        end,
                    warning = "|cff0000Request reload UI|r |cffffff|||r This option may interfere with |cffff00Addon Selector|r, we suggest that let this option off if you are using |cffff00Addon Selector|r",
                },
            },
        },
        {--Marker
            type = "submenu",
            name = "Marker",
            controls = {
                {--ElmsMarkers's icons list
                    type = "iconpicker",
                    name = "ElmsMarkers Icons",
                    choices = CitizenFunctions.TableSpliter(CitizenMarker.iconData, 1, 70),
                    tooltip = "This icons |c00ff00ARE|r capble to share by Import/Export String to other people who have |cffff00ElmsMarkers v1.1.0|r",
                    sort = "name-up",
                    maxColumns = 5,
                    visibleRows = 6,
                    iconSize = 64,
                    getFunc =
                        function()
                            return CitizenMarker.iconData[CitizenAddon.generalOptions.marker.selectedIconTexture]
                        end,
                    setFunc =
                        function(value)
                            CitizenAddon.generalOptions.marker.selectedIconTexture = CitizenMarker.reverseIconData[value]
                        end,
                },
                {--Citizen's icons list
                    type = "iconpicker",
                    name = "Citizen Icons",
                    choices = CitizenFunctions.TableSpliter(CitizenMarker.iconData, 71, #CitizenMarker.iconData),
                    tooltip = "This icons will |cff0000NOT|r be shared by Import/Export String to other people who have |cffff00ElmsMarkers|r Addon, |c00ff00ONLY|r the people who have |cffff00CitizenAdddon|r will recive them",
                    sort = "name-up",
                    maxColumns = 5,
                    visibleRows = 6,
                    iconSize = 64,
                    getFunc =
                        function()
                            return CitizenMarker.iconData[CitizenAddon.generalOptions.marker.selectedIconTexture]
                        end,
                    setFunc =
                        function(value)
                            CitizenAddon.generalOptions.marker.selectedIconTexture = CitizenMarker.reverseIconData[value]
                        end,
                },
                {--OSI icon size
                    type = "slider",
                    name = "Icon size",
                    min = 32,
                    max = 256,
                    step = 4,
                    tooltip = "Default is 84",
                    getFunc =
                        function()
                            return CitizenAddon.generalOptions.marker.OsiIconSize
                        end,
                    setFunc =
                        function(value)
                            CitizenAddon.generalOptions.marker.OsiIconSize = value
                            CitizenMarker.PlayerActivated()
                        end,
                },
                {--Remove nearest mark
                    type = "button",
                    name = "Remove nearest mark",
                    tooltip = "Can be done by |cffff00/citi r|r",
                    width = "half",
                    func =
                        function()
                            CitizenMarker.RemoveNearestMarker()
                        end,
                },
                {--Place marker at character location
                    type = "button",
                    name = "Place marker here",
                    tooltip = "Can be done by |cffff00/citi p|r",
                    width = "half",
                    func =
                        function()
                            CitizenMarker.PlaceAtMe()
                        end,
                },
                {--Import/Export String
                    type = "header",
                    name = "Import/Export String",
                },
                {--Import/Export String box
                    type = "editbox",
                    name = "Config",
                    tooltip = "You can Import/Export String from/to |cffff00ElmsMarkers|r",
                    isMultiline = true,
                    isExtraWide = true,
                    getFunc =
                        function()
                            return CitizenAddon.generalOptions.marker.configString
                        end,
                    setFunc =
                        function(value)
                            CitizenAddon.generalOptions.marker.configString = value
                        end,
                },
                {--Import key
                    type = "button",
                    name = "Import",
                    tooltip = "Import a config string for this zone",
                    func =
                        function()
                            CitizenMarker.ImportConfigString()
                        end,
                },
                { ------
                    type = "divider",
                },
                {--Check box to unlock clear zone marks button
                    type = "checkbox",
                    name = "Unlock clear button",
                    getFunc =
                        function()
                            return CitizenMarker.clearLock
                        end,
                    setFunc =
                        function(value)
                            CitizenMarker.clearLock = value
                        end,
                },
                {--Clear zone marks
                    type = "button",
                    name = "Clear Zone",
                    tooltip = "This will clear all markers from this zone",
                    isDangerous = true,
                    func =
                        function()
                            CitizenMarker.ClearZone()
                        end,
                    warning = "|cff0000This act is irreversible!|r",
                    disabled =
                        function()
                            return not CitizenMarker.clearLock
                        end,
                },
            },
        },
        {--Combat Options
            type = "header",
            name = "|cbfffffCombat Options|r",
        },
        {--Am I Blocking
            type = "checkbox",
            name = "Am I Blocking?",
            tooltip = "Show a shield icon when ever you are actually blocking because who trust ZOS?",
            getFunc =
                function()
                    return CitizenAddon.combatOptions.amIBlocking.active
                end,
            setFunc =
                function(value)
                    CitizenAddon.combatOptions.amIBlocking.active = value
                end,
            warning = "|cff0000Request reload UI|r",
        },
        {--Show/Hide Am I Blocking UI
            type = "button",
            name = "Show/Hide Blocking UI",
            width = "full",
            func =
                function()
                    if CitizenAmIBlocking.hideUi then
                        CitizenAmIBlocking.hideUi = false
                    else
                        CitizenAmIBlocking.hideUi = true
                    end
                end,
            disabled =
                function()
                    return not CitizenAddon.combatOptions.amIBlocking.active
                end,
        },
        {------
            type = "divider",
        },
        {--Resistance Meter
            type = "checkbox",
            name = "Resistance Meter",
            tooltip = "Show a box with status of your current Physical and Spell Resistance",
            getFunc =
                function()
                    return CitizenAddon.combatOptions.resistanceMeter.active
                end,
            setFunc =
                function(value)
                    CitizenAddon.combatOptions.resistanceMeter.active = value
                end,
            warning = "|cff0000Request reload UI|r",
        },
        {--Show/Hide Resistance Meter UI
            type = "button",
            name = "Lock/Unlock Meter UI",
            width = "full",
            func =
                function()
                    if CitizenResistanceMeter.lockUi then
                        CitizenResistanceMeter.lockUi = false
                        CitizenRM:SetMovable(true)
                    else
                        CitizenResistanceMeter.lockUi = true
                        CitizenRM:SetMovable(false)
                    end
                end,
            disabled =
                function()
                    return not CitizenAddon.combatOptions.resistanceMeter.active
                end,
        },
        {------
            type = "divider",
        },
        {--Nearby Members
            type = "checkbox",
            name = "Nearby Members",
            tooltip = "Shows the amount of group members in the chosen range |cffffff|||r It |cff0000EXCLUDE|r dead members",
            getFunc =
                function()
                    return CitizenAddon.combatOptions.nearbyMembers.active
                end,
            setFunc =
                function(value)
                    CitizenAddon.combatOptions.nearbyMembers.active = value
                end,
            warning = "|cff0000Request reload UI|r",
        },
        {--Range of Nearby Members
            type = "slider",
            name = "Range",
            min = 5,
            max = 36,
            step = 1,
            getFunc =
                function()
                    return CitizenAddon.combatOptions.nearbyMembers.range
                end,
            setFunc =
                function(value)
                    CitizenAddon.combatOptions.nearbyMembers.range = value
                    CitizenNM_Range:SetText(value .."m")
                end,
            disabled =
                function()
                    return not CitizenAddon.combatOptions.nearbyMembers.active
                end,
        },
        {--DD Only mode for Nearby Members
            type = "checkbox",
            name = "DD Only mode",
            tooltip = "Only count amount of group members who are marked as DD",
            getFunc =
                function()
                    return CitizenAddon.combatOptions.nearbyMembers.DdOnly
                end,
            setFunc =
                function(value)
                    CitizenNM_DD:Hidden(not value)
                    CitizenAddon.combatOptions.nearbyMembers.DdOnly = value
                end,
            disabled =
                function()
                    return not CitizenAddon.combatOptions.nearbyMembers.active
                end,
        },
        {--Show/Hide Nearby Members UI
            type = "button",
            name = "Lock/Unlock Meter UI",
            width = "full",
            func =
                function()
                    if CitizenNearbyMembers.lockUi then
                        CitizenNearbyMembers.lockUi = false
                        CitizenNM:SetMovable(true)
                    else
                        CitizenNearbyMembers.lockUi = true
                        CitizenNM:SetMovable(false)
                    end
                end,
            disabled =
                function()
                    return not CitizenAddon.combatOptions.nearbyMembers.active
                end,
        },
        {--Trials/Dungeons
            type = "header",
            name = "|cbfffffTrials|r/|cbfffffDungeons|r",
        },
        {--Cloudrest
            type = "submenu",
            name = "Cloudrest",
            controls = {
                {--Siroria Flare OSI
                    type = "checkbox",
                    name = "Siroria Flare OSI",
                    warning = "|cff0000Request reload UI|r",
                    getFunc =
                        function()
                            return CitizenAddon.PVEcontent.CR.siroriaFlareOsi
                        end,
                    setFunc =
                        function(value)
                            CitizenAddon.PVEcontent.CR.siroriaFlareOsi = value
                        end,
                },
                {--Siroria Flare OSI icon size
                    type = "slider",
                    name = "Siroria Flare OSI icon size",
                    min = 32,
                    max = 256,
                    step = 4,
                    tooltip = "Default is 128",
                    getFunc =
                        function()
                            return CitizenAddon.PVEcontent.CR.siroriaFlareOsiIconSize
                        end,
                    setFunc =
                        function(value)
                            CitizenAddon.PVEcontent.CR.siroriaFlareOsiIconSize = value
                        end,
                    disabled =
                        function()
                            if CitizenAddon.PVEcontent.CR.siroriaFlareOsi then
                                return false
                            else
                                return true
                            end
                        end,
                },
                {------
                    type = "divider",
                },
                {--Galenwe Hoarfrost OSI
                    type = "checkbox",
                    name = "Galenwe Hoarfrost OSI",
                    warning = "|cff0000Request reload UI|r",
                    getFunc =
                        function()
                            return CitizenAddon.PVEcontent.CR.galenweHoarfrostOsi
                        end,
                    setFunc =
                        function(value)
                            CitizenAddon.PVEcontent.CR.galenweHoarfrostOsi = value
                        end,
                },
                {--Galenwe Hoarfrost OSI icon size
                    type = "slider",
                    name = "Galenwe Hoarfrost OSI icon size",
                    min = 32,
                    max = 256,
                    step = 4,
                    tooltip = "Default is 128",
                    getFunc =
                        function()
                            return CitizenAddon.PVEcontent.CR.galenweHoarfrostOsiIconSize
                        end,
                    setFunc =
                        function(value)
                            CitizenAddon.PVEcontent.CR.galenweHoarfrostOsiIconSize = value
                        end,
                    disabled =
                        function()
                            if CitizenAddon.PVEcontent.CR.galenweHoarfrostOsi then
                                return false
                            else
                                return true
                            end
                        end,
                },
            },
        },
        {--Blackrose Prison
            type = "submenu",
            name = "Blackrose Prison",
            controls = {
                {--Adds spawn location OSI
                    type = "checkbox",
                    name = "Adds spawn locations OSI |cffff00BETA|r",
                    tooltip = "Not being in Stage zone when fight begin, wiping when someone is in the team but not in BRP, and some other things that is not supposed happen in a BRP clear run, might cause bugs; majory of bugs will get fix when new Round/new Stage begin, you can thank ZOS for this problems",
                    getFunc =
                        function()
                            return CitizenAddon.PVEcontent.BRP.waveIcons.active
                        end,
                    setFunc =
                        function(value)
                            CitizenAddon.PVEcontent.BRP.waveIcons.active = value
                        end,
                    warning = "|cff0000Request reload UI|r",
                },
                {--Adds spawn location OSI icon size
                    type = "slider",
                    name = "Adds spawn location OSI icon size",
                    min = 32,
                    max = 256,
                    step = 4,
                    tooltip = "Default is 128 |cffffff|||r Big adds have a +24 and small adds have a -24",
                    getFunc =
                        function()
                            return CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize
                        end,
                    setFunc =
                        function(value)
                            CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize = value
                        end,
                    disabled =
                        function()
                            return not CitizenAddon.PVEcontent.BRP.waveIcons.active
                        end,
                },
                {--OSI duration in second
                    type = "slider",
                    name = "Icon's duration after the wave spawned",
                    min = 3,
                    max = 15,
                    step = 1,
                    tooltip = "Default is 8s",
                    getFunc =
                        function()
                            return CitizenAddon.PVEcontent.BRP.waveIcons.duration/1000
                        end,
                    setFunc =
                        function(value)
                            CitizenAddon.PVEcontent.BRP.waveIcons.duration = value*1000
                        end,
                    disabled =
                        function()
                            return not CitizenAddon.PVEcontent.BRP.waveIcons.active
                        end,
                },
            },
        },
        {--Sunspire
            type = "submenu",
            name = "Sunspire",
            controls = {
                {--Bosses Fly Tracker
                    type = "checkbox",
                    name = "Bosses Fly Tracker",
                    tooltip = "Fly and Land tracker for All the bosses with Nahvi's portals",
                    warning = "|cff0000Request reload UI|r",
                    getFunc =
                        function()
                            return CitizenAddon.PVEcontent.SS.bossFlyTracker
                        end,
                    setFunc =
                        function(value)
                            CitizenAddon.PVEcontent.SS.bossFlyTracker = value
                        end,
                },
                {--Lokkestiiz section
                    type = "submenu",
                    name = CitizenFunctions.AddIconToString("Lokkestiiz", "/esoui/art/icons/achievement_els_sunspire_flavor_2.dds"),
                    controls = {
                        {--Laser beam count down
                            type = "checkbox",
                            name = "Laser beam timer",
                            tooltip = "Show a count down 10s before Laser beam",
                            warning = "|cff0000Request reload UI|r",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.SS.lokke.beamTimer
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.SS.lokke.beamTimer = value
                                end,
                        },
                        {--Laser beam OSI
                            type = "checkbox",
                            name = "Laser beam OSI locations",
                            tooltip = "Shows a floating icon for Laser beam standing positions |cffffff|||r It's synced with |cffff00CrutchAlerts|r",
                            warning = "|cff0000Request reload UI|r",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.SS.lokke.beamOsi
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.SS.lokke.beamOsi = value
                                end,
                        },
                        {--Is solo heal
                            type = "checkbox",
                            name = "Solo healer mode",
                            tooltip = "Change icon to match with a 9DD 1Healer Team |cffffff|||r It's synced with |cffff00CrutchAlerts|r",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.SS.lokke.soloHeal
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.SS.lokke.soloHeal = value
                                end,
                            disabled =
                                function()
                                    return not CitizenAddon.PVEcontent.SS.lokke.beamOsi
                                end,
                        },
                        {--Laser beam OSI icon size
                            type = "slider",
                            name = "Laser beam OSI locations icon size",
                            min = 32,
                            max = 256,
                            step = 4,
                            tooltip = "Default is 128",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.SS.lokke.beamOsiIconSize
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.SS.lokke.beamOsiIconSize = value
                                end,
                            disabled =
                                function()
                                    return not CitizenAddon.PVEcontent.SS.lokke.beamOsi
                                end,
                        }
                    }
                },
                {--Nahviintaas section
                    type = "submenu",
                    name = CitizenFunctions.AddIconToString("Nahviintaas", "/esoui/art/icons/achievement_els_sunspire_flavor_3.dds"),
                    controls = {
                        {--Statue Stone Fist on CombatAlerts
                            type = "checkbox",
                            name = "Statue Stone Fist alert",
                            tooltip = "Uses CombatAlerts progress bar",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.SS.nahvi.statueStoneFist
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.SS.nahvi.statueStoneFist = value
                                end
                        },
                        {------
                            type = "divider",
                        },
                        {--Portal entrance timer
                            type = "checkbox",
                            name = "Portal entrance timer",
                            tooltip = "Show a count down for duration of time shift portal",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.SS.nahvi.portalEntranceTimer
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.SS.nahvi.portalEntranceTimer = value
                                end
                        },
                        {--Portal wipe timer
                            type = "checkbox",
                            name = "Portal duration timer",
                            tooltip = "Shows how long left till portal wipe",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.SS.nahvi.portalWipeTimer
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.SS.nahvi.portalWipeTimer = value
                                end
                        },
                        {--Eternal servant Interrupt
                            type = "checkbox",
                            name = "Eternal servant Interrupt alert",
                            tooltip = "Sound alert and uses CombatAlerts progress bar",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.SS.nahvi.portalInterrupt
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.SS.nahvi.portalInterrupt = value
                                end
                        },
                    },
                },
            },   
        },
        {--Rockgrove
            type = "submenu",
            name = "Rockgrove",
            controls = {
                {--Oax section
                    type = "submenu",
                    name = CitizenFunctions.AddIconToString("Oaxiltso", "/esoui/art/icons/achievement_u30_vtrial_b1_hardmode.dds"),
                    controls = {
                        {--Poison OSI
                            type = "checkbox",
                            name = "Poison OSI",
                            warning = "|cff0000Request reload UI|r",
                            tooltip = "Green arrow with countdown above the preson who have Poison",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.RG.oax.poisonOsi
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.RG.oax.poisonOsi = value
                                end,
                        },
                        {--Poison OSI icon size
                            type = "slider",
                            name = "Poison OSI icon size",
                            min = 32,
                            max = 256,
                            step = 4,
                            tooltip = "Default is 128",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.RG.oax.poisonOsiIconSize
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.RG.oax.poisonOsiIconSize = value
                                end,
                            disabled =
                                function()
                                    return not CitizenAddon.PVEcontent.RG.oax.poisonOsiIconSize
                                end,
                        },
                    }
                },
                {--Bahsei section
                    type = "submenu",
                    name = CitizenFunctions.AddIconToString("Bahsei", "/esoui/art/icons/achievement_u30_vtrial_b2_hardmode.dds"),
                    controls = {
                        {--Death touch OSI
                            type = "checkbox",
                            name = "Death touch OSI",
                            warning = "|cff0000Request reload UI|r",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.RG.bahsei.deathTouchOsi
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.RG.bahsei.deathTouchOsi = value
                                end,
                        },
                        {--Death touch OSI icon size
                            type = "slider",
                            name = "Death touch OSI icon size",
                            min = 32,
                            max = 256,
                            step = 4,
                            tooltip = "Default is 128",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.RG.bahsei.deathTouchOsiIconSize
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.RG.bahsei.deathTouchOsiIconSize = value
                                end,
                            disabled =
                                function()
                                    return not CitizenAddon.PVEcontent.RG.bahsei.deathTouchOsi
                                end,
                        },
                        {------
                            type = "divider",
                        },
                        {--Bleed OSI
                            type = "checkbox",
                            name = "Bleed OSI",
                            tooltip = "Red arrow with timer on top of the player who have Bleed",
                            warning = "|cff0000Request reload UI|r",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.RG.bahsei.bleedOsi
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.RG.bahsei.bleedOsi = value
                                end,
                        },
                        {--Bleed OSI icon size
                            type = "slider",
                            name = "Bleed OSI icon size",
                            min = 32,
                            max = 256,
                            step = 4,
                            tooltip = "Default is 128",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.RG.bahsei.bleedOsiIconSize
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.RG.bahsei.bleedOsiIconSize = value
                                end,
                            disabled =
                                function()
                                    return not CitizenAddon.PVEcontent.RG.bahsei.bleedOsi
                                end,
                        },
                        {------
                            type = "divider",
                        },
                        {--Bleed tracker
                            type = "checkbox",
                            name = "Bleed tracker",
                            tooltip = "Show a count down for bleeds",
                            warning = "|cff0000Request reload UI|r",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.RG.bahsei.bleedTracker
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.RG.bahsei.bleedTracker = value
                                end,
                        },
                        {--ONLY off tank tracker
                            type = "checkbox",
                            name = "ONLY track Off-Tank",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.RG.bahsei.offTankOnly
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.RG.bahsei.offTankOnly = value
                                end,
                            warning = "Bleed OSI will not be off-tank only",
                            disabled =
                                function()
                                    return not CitizenAddon.PVEcontent.RG.bahsei.bleedTracker
                                end,
                        },
                        {--Off Tank ID
                            type = "dropdown",
                            name = "ID of Off-Tank",
                            choices = CitizenAddon.group.unitDisplayName,
                            scrollable = true,
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.RG.bahsei.offTankDisplayName
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.RG.bahsei.offTankDisplayName = value
                                end,
                            disabled =
                                function()
                                    if CitizenAddon.PVEcontent.RG.bahsei.bleedTracker and CitizenAddon.PVEcontent.RG.bahsei.offTankOnly then
                                        return false
                                    else
                                        return true
                                    end
                                end,
                            reference = "CITIZEN_RG_BAHSEI_OFF_TANK_ID",
                        },
                        {------
                            type = "divider",
                        },
                        {--Mouldering taint tracker
                            type = "checkbox",
                            name = "Mouldering taint tracker",
                            tooltip = "Shows stack and timer for Mouldering taint",
                            warning = "|cff0000Request reload UI|r",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.RG.bahsei.moulderingTaint
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.RG.bahsei.moulderingTaint = value
                                end,
                        },
                    }
                },
            },
        },
        {--Coral Aerie
            type = "submenu",
            name = "Coral Aerie",
            controls = {
                {--Varallion section
                    type = "submenu",
                    name = CitizenFunctions.AddIconToString("Varallion", "/esoui/art/icons/u33_dun1_perfectnonmeta.dds"),
                    controls = {
                        {--Mind Link OSI
                            type = "checkbox",
                            name = "Mind Link OSI",
                            warning = "|cff0000Request reload UI|r",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.CA.varallion.mindLinkOsi
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.CA.varallion.mindLinkOsi = value
                                end,
                        },
                        {--Mind Link OSI icon size
                            type = "slider",
                            name = "Mind Link OSI icon size",
                            min = 32,
                            max = 256,
                            step = 4,
                            tooltip = "Default is 128",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.CA.varallion.mindLinkOsiIconSize
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.CA.varallion.mindLinkOsiIconSize = value
                                end,
                            disabled =
                                function()
                                    return not CitizenAddon.PVEcontent.CA.varallion.mindLinkOsi
                                end,
                        },
                    },
                },
            },
        },
        {--Dreadsail Reef
            type = "submenu",
            name = "Dreadsail Reef",
            controls = {
                {--Trash
                    type = "submenu",
                    name = CitizenFunctions.AddIconToString("Trash", "/esoui/art/icons/u34_vtrialkillmonstersa.dds"),
                    controls = {
                        {--BrewMaster Potion OSI and alert
                            type = "checkbox",
                            name = "BrewMaster Potion OSI and alert",
                            warning = "|cff0000Request reload UI|r",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.DSR.trash.brewMasterPotionOsi
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.DSR.trash.brewMasterPotionOsi = value
                                end,
                        },
                        {--BrewMaster Potion OSI icon size
                            type = "slider",
                            name = "BrewMaster Potion OSI icon size",
                            min = 32,
                            max = 256,
                            step = 4,
                            tooltip = "Default is 164",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.DSR.trash.brewMasterPotionOsiIconSize
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.DSR.trash.brewMasterPotionOsiIconSize = value
                                end,
                            disabled =
                                function()
                                    return not CitizenAddon.PVEcontent.DSR.trash.brewMasterPotionOsi
                                end,
                        },
                    },
                },
                {--Lylanar & Turlassil
                    type = "submenu",
                    name = CitizenFunctions.AddIconToString("Lylanar & Turlassil", "/esoui/art/icons/u34_vtrial_b1_hardmode.dds"),
                    controls = {
                        {--Ice and Fire brand OSI
                            type = "checkbox",
                            name = "Ice and Fire brand OSI",
                            warning = "|cff0000Request reload UI|r",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.DSR.lyAndTu.iceAndFireBrandOsi
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.DSR.lyAndTu.iceAndFireBrandOsi = value
                                end,
                        },
                        {--Ice and Fire brand OSI Size
                            type = "slider",
                            name = "Ice and Fire brand OSI icon size",
                            min = 32,
                            max = 256,
                            step = 4,
                            tooltip = "Default is 128",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.DSR.lyAndTu.iceAndFireBrandOsiIconSize
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.DSR.lyAndTu.iceAndFireBrandOsiIconSize = value
                                end,
                            disabled =
                                function()
                                    return not CitizenAddon.PVEcontent.DSR.lyAndTu.iceAndFireBrandOsi
                                end,
                        },
                    },
                },
                {--Reef Guardian
                    type = "submenu",
                    name = CitizenFunctions.AddIconToString("Reef Guardian", "/esoui/art/icons/u34_vtrial_b2_hardmode.dds"),
                    controls = {
                        {--Acid Reflux on CombatAlerts
                            type = "checkbox",
                            name = "Acid Reflux progress bar",
                            tooltip = "Uses CombatAlerts progress bar",
                            warning = "|cff0000Request reload UI|r",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.DSR.reef.acidReflux
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.DSR.reef.acidReflux = value
                                end
                        }
                    },
                },
                {--Tideborn Taleria
                    type = "submenu",
                    name = CitizenFunctions.AddIconToString("Tideborn Taleria", "/esoui/art/icons/u34_vtrial_all_hardmode.dds"),
                    controls = {
                        {--Clock numbers on map OSI
                            type = "checkbox",
                            name = "Clock numbers on map",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsi
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsi = value
                                end,
                            warning = "|cff0000Request reload UI|r",
                        },
                        {--Clock numbers OSI size
                            type = "slider",
                            name = "Clock numbers icon size",
                            min = 32,
                            max = 256,
                            step = 4,
                            tooltip = "Default is 84",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize = value
                                end,
                            disabled =
                                function()
                                    return not CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsi
                                end,
                        },
                        {------
                            type = "divider",
                        },
                        {--Behemoth hack attack
                            type = "checkbox",
                            name = "Behemoth hack attack alert",
                            tooltip = "Sound alert and uses CombatAlerts progress bar",
                            warning = "|cff0000Request reload UI|r",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.DSR.taleria.behemothHack
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.DSR.taleria.behemothHack = value
                                end
                        },
                        {--Behemoth crush attack
                            type = "checkbox",
                            name = "Behemoth crush attacks alert",
                            tooltip = "Sound alert and uses CombatAlerts progress bar",
                            warning = "|cff0000Request reload UI|r",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.DSR.taleria.behemothCrush
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.DSR.taleria.behemothCrush = value
                                end
                        },
                        {--Siren Lure Of The Sea
                            type = "checkbox",
                            name = "Siren Lure Of The Sea progress bar and sound alert",
                            tooltip = "uses CombatAlerts progress bar",
                            warning = "|cff0000Request reload UI|r",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.DSR.taleria.sirenLureOfTheSea
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.DSR.taleria.sirenLureOfTheSea = value
                                end
                        },
                        {--Sea Boiler Aspect Of Terror
                            type = "checkbox",
                            name = "Sea Boiler Aspect Of Terror progress bar and sound alert",
                            tooltip = "uses CombatAlerts progress bar",
                            warning = "|cff0000Request reload UI|r",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.DSR.taleria.seaBoilerAspectOfTerror
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.DSR.taleria.seaBoilerAspectOfTerror = value
                                end
                        },
                    },
                },
            },
        },
        {--Sanity's Edge
            type = "submenu",
            name = "Sanity's Edge",
            controls = {
                {--Yaseyla
                    type = "submenu",
                    name = CitizenFunctions.AddIconToString("Yaseyla", "/esoui/art/icons/achievement_u38_vtrial_b1_hardmode.dds"),
                    controls = {
                        {--True shot alert
                            type = "checkbox",
                            name = "Archers TrueShot alert",
                            tooltip = "Play sound and give an alert when an archer is charging TrueShot",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.SE.yaseyla.archerTrueShot
                                end,
                            setFunc =
                                function(newValue)
                                    CitizenAddon.PVEcontent.SE.yaseyla.archerTrueShot = newValue
                                end,
                        },
                    },
                },
                {--Archwizard and Chimera
                    type = "submenu",
                    name = CitizenFunctions.AddIconToString("Archwizard and Chimera", "/esoui/art/icons/achievement_u38_vtrial_b2_hardmode.dds"),
                    controls = {
                        {--Crystal numbers OSI
                            type = "checkbox",
                            name = "Crystal numbers OSI",
                            tooltip = "Shows numeric floating icons for crystals in portals |cffffff|||r It's synced with |cffff00SanitysEdgeHelper|r",
                            warning = "|cff0000Request reload UI|r",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOSI
                                end,
                            setFunc =
                                function(newValue)
                                    CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOSI = newValue
                                end,
                        },
                        {--Crystal numbers OSI icon size
                            type = "slider",
                            name = "Crystal numbers OSI icon size",
                            min = 32,
                            max = 256,
                            step = 4,
                            tooltip = "Default is 128",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize
                                end,
                            setFunc =
                                function(value)
                                    CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize = value
                                end,
                            disabled =
                                function()
                                    return not CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOSI
                                end,
                        }
                    },
                },
                {--Ansuul
                    type = "submenu",
                    name = CitizenFunctions.AddIconToString("Ansuul", "/esoui/art/icons/achievement_u38_vtrial_all_hardmode.dds"),
                    controls = {
                        {--Banish tracker
                            type = "checkbox",
                            name = "Banish tracker",
                            getFunc =
                                function()
                                    return CitizenAddon.PVEcontent.SE.ansuul.banishTracker
                                end,
                            setFunc =
                                function(newValue)
                                    CitizenAddon.PVEcontent.SE.ansuul.banishTracker = newValue
                                end,
                        },
                    },
                },
            },
        },
        {--Footer
            type = "header",
            name = "|cbfffffInformations|r",
        },
        {--Info
            type = "description",
            text = "|cff0000ALPHA|r Means it is under develope and may not work properly\n|cffff00BETA|r Means it is done but it is not fully tested, it is more likely to work without any problem"
        },
        {--Credits
            type = "button",
            name = "Show/Hide Credits",
            width = "half",
            func =
                function()
                    if Citizen_Addon_Credits:IsHidden() then
                        Citizen_Addon_Credits:SetHidden(false)
                    else
                        Citizen_Addon_Credits:SetHidden(true)
                    end
                end,
        },
        {--Log
            type = "editbox",
            name = "Log",
            isMultiline = false,
            isExtraWide = false,
            width = "half",
            getFunc =
                function()
                    return CitizenAddon.log
                end,
            setFunc =
                function(value)
                    CitizenAddon.log = value
                end,
        },
}

    CitizenAddonMenu.PanelID = LibAddonMenu2:RegisterAddonPanel(CitizenAddonMenu.name .."Options", menuOptions)
	LibAddonMenu2:RegisterOptionControls(CitizenAddonMenu.name .."Options", dataTable)
end


-------------------------------------------------------------------- |cffffff|||r
----SE /esoui/art/icons/achievement_u38_vtrial_meta.dds
--TR /esoui/art/icons/achievement_u38_mainquest_4.dds
--MI /esoui/art/icons/achievement_u38_weboss2.dds
--B1 /esoui/art/icons/achievement_u38_vtrial_b1_hardmode.dds
--B2 /esoui/art/icons/achievement_u38_vtrial_b2_hardmode.dds
--B3 /esoui/art/icons/achievement_u38_vtrial_all_hardmode.dds
--------------------------------------------------------------------
----DSR /esoui/art/icons/u34_trial_veteran_bosses.dds
--TR /esoui/art/icons/u34_vtrialkillmonstersa.dds
--MI /esoui/art/icons/u34_vtrial_flavor_4.dds
--B1 /esoui/art/icons/u34_vtrial_b1_hardmode.dds
--B2 /esoui/art/icons/u34_vtrial_b2_hardmode.dds
--B3 /esoui/art/icons/u34_vtrial_all_hardmode.dds
--------------------------------------------------------------------
----CA /esoui/art/icons/u33_dun1_hard_mode_meta.dds
--TR /esoui/art/icons/u33_dun1_killmonstersa.dds
--MI /esoui/art/icons/u33_dun1_flavorg.dds
--B1 /esoui/art/icons/u33_dun1_hard_mode_b1.dds
--B2 /esoui/art/icons/u33_dun1_hard_mode_b2.dds
--B3 /esoui/art/icons/u33_dun1_perfectnonmeta.dds
--------------------------------------------------------------------
----SWR /esoui/art/icons/u33_dun2_flavorf.dds
--TR /esoui/art/icons/u33_dun2_killmonstersa.dds
--MI /esoui/art/icons/u33_dun2_flavora.dds
--B1 /esoui/art/icons/u33_dun2_hard_mode_b1.dds
--B2 /esoui/art/icons/u33_dun2_hard_mode_b2.dds
--B3 /esoui/art/icons/u33_dun2_hard_mode_final.dds
--------------------------------------------------------------------
----RG /esoui/art/icons/achievement_u30_vtrial_meta.dds
--TR /esoui/art/icons/achievement_u30_vtrialkillmonstersa.dds
--MI /esoui/art/icons/achievement_u30_solo_daily_1.dds
--B1 /esoui/art/icons/achievement_u30_vtrial_b1_hardmode.dds
--B2 /esoui/art/icons/achievement_u30_vtrial_b2_hardmode.dds
--B3 /esoui/art/icons/achievement_u30_vtrial_all_hardmode.dds
--------------------------------------------------------------------
----SS /esoui/art/icons/achievement_els_sunspire_hardmode_all.dds
--TR /esoui/art/icons/achievement_els_lrgzn_groupboss_meta.dds
--B1 /esoui/art/icons/achievement_els_sunspire_flavor_2.dds
--B2 /esoui/art/icons/achievement_els_sunspire_flavor_1.dds
--B3 /esoui/art/icons/achievement_els_sunspire_flavor_3.dds
