local Recharge = Recharge

local eventName = Recharge.eventName

--Build the addon's LAM 2.0 settings menu
--Create the settings panel object of libAddonMenu 2.0

local serverName = GetWorldName()
local accountName = GetDisplayName()

local println = Recharge.Println
local TryParsePercent = Recharge.TryParsePercent

local function ARC_BuildAddonMenu()
	--LibAddonMenu-2.0
	local LAM = LibAddonMenu2
	if LAM == nil then return end

	local ARC_settings = 	Recharge.settings
	local ARC_defSettings = Recharge.defaultSettings

	local panelData = {
		type 				= 'panel',
		name 				= Recharge.name,
		displayName 		= Recharge.displayName,
		author 				= Recharge.author,
		version 			= Recharge.version,
		registerForRefresh 	= true,
		registerForDefaults = true,
		slashCommand 		= "/recharge",
        website 			= Recharge.website,
	}

	LAM:RegisterAddonPanel(eventName .. "_LAM", panelData)

	local optionsTable =
    {	-- BEGIN OF OPTIONS TABLE

--Description of the addon
		{
			type = "description",
			text = GetString(ARC_LAM_ADDON_DESC),
		},
		--Use accountwide settings
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_ACCOUNTWIDE),
			tooltip = GetString(ARC_LAM_OPTION_ACCOUNTWIDE_TT),
			getFunc = function() return AutoRecharge_SavedVariables[serverName][accountName]['$AccountWide']["Settings"]["AccountWide"] end,
			setFunc = function(value) AutoRecharge_SavedVariables[serverName][accountName]['$AccountWide']["Settings"]["AccountWide"] = value end,
			requiresReload = true,
			default = ARC_defSettings.AccountWide,
		},

		--Automatic recharging
		{
        	type = "header",
        	name = GetString(ARC_LAM_HEADER_AUTO_CHARGE),
        },
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_AUTO_RECHARGE),
			tooltip = GetString(ARC_LAM_OPTION_AUTO_RECHARGE_TT),
			getFunc = function() return ARC_settings.chargeEnabled end,
			setFunc = function(value) ARC_settings.chargeEnabled = value end,
            default = ARC_defSettings.chargeEnabled,
            width="half",
		},
		{
			type = "slider",
			name = GetString(ARC_LAM_OPTION_AUTO_RECHARGE_DELAY),
			tooltip = GetString(ARC_LAM_OPTION_AUTO_RECHARGE_DELAY_TT),
			min = 0,
			max = 1500,
			step = 10,
			getFunc = function() return ARC_settings.rechargeDelay end,
			setFunc = function(value)
				ARC_settings.rechargeDelay = value
			end,
			width="full",
			default = ARC_defSettings.rechargeDelay,
			disabled = function() return not ARC_settings.chargeEnabled end,
		},
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_AUTO_RECHARGE_IN_COMBAT),
			tooltip = GetString(ARC_LAM_OPTION_AUTO_RECHARGE_IN_COMBAT_TT),
			getFunc = function() return ARC_settings.chargeDuringCombat end,
			setFunc = function(value) ARC_settings.chargeDuringCombat = value end,
			default = ARC_defSettings.chargeDuringCombat,
			width="half",
		},
 		{
			type = "slider",
			name = GetString(ARC_LAM_OPTION_AUTO_RECHARGE_MIN_TH),
			tooltip = GetString(ARC_LAM_OPTION_AUTO_RECHARGE_MIN_TH_TT),
			min = 0,
			max = 99,
			getFunc = function() return (ARC_settings.minChargePercent*100) end,
			setFunc = function(percent)
					local percentage = TryParsePercent(percent)
					if percentage ~= nil and percentage >= 0 and percentage < 1 then
						ARC_settings.minChargePercent = percentage
	                    if ARC_settings.chatOutput then println(GetString(ARC_CHATOUPUT_MIN_CHARGE),tostring(percent),"%") end
                    end
 				end,
            width="full",
			default = (ARC_defSettings.minChargePercent*100),
            disabled = function() return not ARC_settings.chargeEnabled end,
		},
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_AUTO_RECHARGE_ON_WEAPON_PAIR_CHANGE),
			tooltip = GetString(ARC_LAM_OPTION_AUTO_RECHARGE_ON_WEAPON_PAIR_CHANGE_TT),
			getFunc = function() return ARC_settings.chargeOnWeaponChange end,
			setFunc = function(value) ARC_settings.chargeOnWeaponChange = value end,
			default = ARC_defSettings.chargeOnWeaponChange,
			requiresReload = true,
			width="half",
		},
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_AUTO_RECHARGE_ON_WEAPON_PAIR_CHANGE_ONLY_IN_COMBAT),
			tooltip = GetString(ARC_LAM_OPTION_AUTO_RECHARGE_ON_WEAPON_PAIR_CHANGE_ONLY_IN_COMBAT_TT),
			getFunc = function() return ARC_settings.chargeOnWeaponChangeOnlyInCombat end,
			setFunc = function(value) ARC_settings.chargeOnWeaponChangeOnlyInCombat = value end,
			default = ARC_defSettings.chargeOnWeaponChangeOnlyInCombat,
			disabled = function() return not ARC_settings.chargeOnWeaponChange end,
			width="half",
		},
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_USE_CROWN_STORE_SOULGEMS_FIRST),
			tooltip = GetString(ARC_LAM_OPTION_USE_CROWN_STORE_SOULGEMS_FIRST_TT),
			getFunc = function() return ARC_settings.useCrownSoulgemsFirst end,
			setFunc = function(value) ARC_settings.useCrownSoulgemsFirst = value end,
			default = ARC_defSettings.useCrownSoulgemsFirst,
			--disabled = function() return ARC_settings.dontUseCrownSoulgems end,
			width="full",
		},

		--Automatic repairing
		{
        	type = "header",
        	name = GetString(ARC_LAM_HEADER_AUTO_REPAIR),
        },
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_AUTO_REPAIR),
			tooltip = GetString(ARC_LAM_OPTION_AUTO_REPAIR_TT),
			getFunc = function() return ARC_settings.repairEnabled end,
			setFunc = function(value) ARC_settings.repairEnabled = value end,
            default = ARC_defSettings.repairEnabled,
            width="half",
		},
		{
			type = "slider",
			name = GetString(ARC_LAM_OPTION_AUTO_REPAIR_DELAY),
			tooltip = GetString(ARC_LAM_OPTION_AUTO_REPAIR_DELAY_TT),
			min = 0,
			max = 1500,
			step = 10,
			getFunc = function() return ARC_settings.repairDelay end,
			setFunc = function(value)
				ARC_settings.repairDelay = value
			end,
			width="full",
			default = ARC_defSettings.repairDelay,
			disabled = function() return not ARC_settings.repairEnabled end,
		},
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_AUTO_REPAIR_IN_COMBAT),
			tooltip = GetString(ARC_LAM_OPTION_AUTO_REPAIR_IN_COMBAT_TT),
			getFunc = function() return ARC_settings.repairDuringCombat end,
			setFunc = function(value) ARC_settings.repairDuringCombat = value end,
			default = ARC_defSettings.repairDuringCombat,
			width="half",
		},
 		{
			type = "slider",
			name = GetString(ARC_LAM_OPTION_AUTO_REPAIR_MIN_TH),
			tooltip = GetString(ARC_LAM_OPTION_AUTO_REPAIR_MIN_TH_TT),
			min = 0,
			max = 99,
			step = 1,
			getFunc = function() return (ARC_settings.minConditionPercent*100) end,
			setFunc = function(percent)
				local percentage = TryParsePercent(percent)
				if percentage ~= nil and percentage >= 0 and percentage < 1 then
					ARC_settings.minConditionPercent = percentage
				else
					--Error fallback value: Repair at 50%
					percentage = 0.5
					percent = 50
					ARC_settings.minConditionPercent = percentage
				end
				if ARC_settings.chatOutput then println(GetString(ARC_CHATOUPUT_MIN_CONDITION),tostring(percent),"%") end
			end,
            width="half",
			default = (ARC_defSettings.minConditionPercent*100),
            disabled = function() return not ARC_settings.repairEnabled end,
		},
        {
            type = "checkbox",
            name = GetString(ARC_LAM_OPTION_SHOW_REPAIR_KITS_LEFT_AT_VENDOR),
            tooltip = GetString(ARC_LAM_OPTION_SHOW_REPAIR_KITS_LEFT_AT_VENDOR_TT),
            getFunc = function() return ARC_settings.showRepairKitsLeftAtVendor end,
            setFunc = function(value) ARC_settings.showRepairKitsLeftAtVendor = value end,
            default = ARC_settings.showRepairKitsLeftAtVendor,
            width="half",
        },
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_USE_REPAIR_KITS_FOR_ITEM_LEVEL),
			tooltip = GetString(ARC_LAM_OPTION_USE_REPAIR_KITS_FOR_ITEM_LEVEL_TT),
			getFunc = function() return ARC_settings.useRepairKitForItemLevel end,
			setFunc = function(value) ARC_settings.useRepairKitForItemLevel = value end,
			default = ARC_defSettings.useRepairKitForItemLevel,
			width="half",
		},
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_DO_NOT_USE_CROWN_STORE_REPAIR_KITS),
			tooltip = GetString(ARC_LAM_OPTION_DO_NOT_USE_CROWN_STORE_REPAIR_KITS_TT),
			getFunc = function() return ARC_settings.dontUseCrownRepairKits end,
			setFunc = function(value) ARC_settings.dontUseCrownRepairKits = value end,
			default = ARC_defSettings.dontUseCrownRepairKits,
			width="full",
		},
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_USE_CROWN_STORE_REPAIR_KITS_FIRST),
			tooltip = GetString(ARC_LAM_OPTION_USE_CROWN_STORE_REPAIR_KITS_FIRST_TT),
			getFunc = function() return ARC_settings.useCrownRepairKitsFirst end,
			setFunc = function(value) ARC_settings.useCrownRepairKitsFirst = value end,
			default = ARC_defSettings.useCrownRepairKitsFirst,
			disabled = function() return ARC_settings.dontUseCrownRepairKits end,
			width="full",
		},


		--Chat output
		{
        	type = "header",
        	name = GetString(ARC_LAM_HEADER_CHATOUTPUT),
        },
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_SHOW_CHAT_MSG),
			tooltip = GetString(ARC_LAM_OPTION_SHOW_CHAT_MSG_TT),
			getFunc = function() return ARC_settings.chatOutput end,
			setFunc = function(value) ARC_settings.chatOutput = value end,
            default = ARC_defSettings.chatOutput,
            width="half",
		},
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_SUPPRESS_CHAT_MSG_NOTHING),
			tooltip = GetString(ARC_LAM_OPTION_SUPPRESS_CHAT_MSG_NOTHING_TT),
			getFunc = function() return ARC_settings.chatOutputSuppressNothingMessages end,
			setFunc = function(value) ARC_settings.chatOutputSuppressNothingMessages = value end,
            default = ARC_defSettings.chatOutputSuppressNothingMessages,
            disabled = function() return not ARC_settings.chatOutput end,
            width="half",
		},
		--Onscreen messages
		{
        	type = "header",
        	name = GetString(ARC_LAM_HEADER_ALERT),
        },
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT),
			tooltip = GetString(ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT_TT),
			getFunc = function() return ARC_settings.alertRepairKitsEmpty end,
			setFunc = function(value) ARC_settings.alertRepairKitsEmpty = value end,
            default = ARC_defSettings.alertRepairKitsEmpty,
            width="full",
		},
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT_LOGIN),
			tooltip = GetString(ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT_LOGIN_TT),
			getFunc = function() return ARC_settings.alertRepairKitsEmptyOnLogin end,
			setFunc = function(value) ARC_settings.alertRepairKitsEmptyOnLogin = value end,
            default = ARC_defSettings.alertRepairKitsEmptyOnLogin,
            width="full",
		},
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT_VENDOR),
			tooltip = GetString(ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT_VENDOR_TT),
			getFunc = function() return ARC_settings.alertRepairKitsEmptyOnVendorOpen end,
			setFunc = function(value) ARC_settings.alertRepairKitsEmptyOnVendorOpen = value end,
            default = ARC_defSettings.alertRepairKitsEmptyOnVendorOpen,
            width="full",
		},

		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_ALERT_SOON_EMPTY_REPAIRKIT),
			tooltip = GetString(ARC_LAM_OPTION_ALERT_SOON_EMPTY_REPAIRKIT_TT),
			getFunc = function() return ARC_settings.alertRepairKitsSoonEmpty end,
			setFunc = function(value) ARC_settings.alertRepairKitsSoonEmpty = value end,
            default = ARC_defSettings.alertRepairKitsSoonEmpty,
            width="half",
		},
 		{
			type = "slider",
			name = GetString(ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT_TH),
			tooltip = GetString(ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT_TH_TT),
			min = 1,
			max = 100,
			getFunc = function() return ARC_settings.alertRepairKitsSoonEmptyThreshold end,
			setFunc = function(value)
						ARC_settings.alertRepairKitsSoonEmptyThreshold = value
						if ARC_settings.chatOutput then println(GetString(ARC_CHATOUPUT_REPAIRKITS_EMPTY_THRESHOLD),tostring(value)) end
 				end,
            width="half",
			default = ARC_defSettings.alertRepairKitsSoonEmptyThreshold,
            disabled = function() return not ARC_settings.alertRepairKitsSoonEmpty end,
		},
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_ALERT_RELOADUI_LOGIN_ZONING),
			tooltip = GetString(ARC_LAM_OPTION_ALERT_RELOADUI_LOGIN_ZONING_TT),
			getFunc = function() return ARC_settings.alertRepairKitsSoonEmptyOnLogin end,
			setFunc = function(value) ARC_settings.alertRepairKitsSoonEmptyOnLogin = value end,
            default = ARC_defSettings.alertRepairKitsSoonEmptyOnLogin,
			disabled = function() return not ARC_settings.alertRepairKitsSoonEmpty end,
            width="full",
		},
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_ALERT_VENDOR),
			tooltip = GetString(ARC_LAM_OPTION_ALERT_VENDOR_TT),
			getFunc = function() return ARC_settings.alertRepairKitsSoonEmptyOnVendorOpen end,
			setFunc = function(value) ARC_settings.alertRepairKitsSoonEmptyOnVendorOpen = value end,
            default = ARC_defSettings.alertRepairKitsSoonEmptyOnVendorOpen,
			disabled = function() return not ARC_settings.alertRepairKitsSoonEmpty end,
            width="full",
		},


		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_ALERT_EMPTY_SOULGEM),
			tooltip = GetString(ARC_LAM_OPTION_ALERT_EMPTY_SOULGEM_TT),
			getFunc = function() return ARC_settings.alertSoulGemsEmpty end,
			setFunc = function(value) ARC_settings.alertSoulGemsEmpty = value end,
            default = ARC_defSettings.alertSoulGemsEmpty,
            width="full",
		},
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_ALERT_SOON_EMPTY_SOULGEM),
			tooltip = GetString(ARC_LAM_OPTION_ALERT_SOON_EMPTY_SOULGEM_TT),
			getFunc = function() return ARC_settings.alertSoulGemsSoonEmpty end,
			setFunc = function(value) ARC_settings.alertSoulGemsSoonEmpty = value end,
            default = ARC_defSettings.alertSoulGemsSoonEmpty,
            width="half",
		},
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_ALERT_EMPTY_SOULGEM_LOGIN),
			tooltip = GetString(ARC_LAM_OPTION_ALERT_EMPTY_SOULGEM_LOGIN_TT),
			getFunc = function() return ARC_settings.alertSoulGemsEmptyOnLogin end,
			setFunc = function(value) ARC_settings.alertSoulGemsEmptyOnLogin = value end,
            default = ARC_defSettings.alertSoulGemsEmptyOnLogin,
            width="full",
		},
 		{
			type = "slider",
			name = GetString(ARC_LAM_OPTION_ALERT_EMPTY_SOULGEM_TH),
			tooltip = GetString(SI_ARC_LAM_OPTION_ALERT_EMPTY_SOULGEM_TH_TT),
			min = 1,
			max = 100,
			getFunc = function() return ARC_settings.alertSoulGemsSoonEmptyThreshold end,
			setFunc = function(value)
				ARC_settings.alertSoulGemsSoonEmptyThreshold = value
				if ARC_settings.chatOutput then println(GetString(ARC_CHATOUPUT_SOULGEMS_EMPTY_THRESHOLD),tostring(value)) end
			end,
            width="half",
			default = ARC_defSettings.alertSoulGemsSoonEmptyThreshold,
            disabled = function() return not ARC_settings.alertSoulGemsSoonEmpty end,
		},
		{
			type = "checkbox",
			name = GetString(ARC_LAM_OPTION_ALERT_RELOADUI_LOGIN_ZONING),
			tooltip = GetString(ARC_LAM_OPTION_ALERT_RELOADUI_LOGIN_ZONING_TT),
			getFunc = function() return ARC_settings.alertSoulGemsSoonEmptyOnLogin end,
			setFunc = function(value) ARC_settings.alertSoulGemsSoonEmptyOnLogin = value end,
            default = ARC_defSettings.alertSoulGemsSoonEmptyOnLogin,
			disabled = function() return not ARC_settings.alertSoulGemsSoonEmpty end,
            width="full",
		},

		--ODebug mode
		{
        	type = "header",
        	name = "Debug mode",
        },
		{
			type = "checkbox",
			name = "Debug mode",
			tooltip = "Debug mode",
			getFunc = function() return Recharge.debug end,
			setFunc = function(value) Recharge.debug = value end,
            default = Recharge.debug,
            width="full",
		},

    } -- END OF OPTIONS TABLE
	LAM:RegisterOptionControls(eventName .. "_LAM", optionsTable)

end

Recharge.BuildSettingsMenu = ARC_BuildAddonMenu