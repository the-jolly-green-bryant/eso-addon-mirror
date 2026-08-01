local BT = BlockingTime
local LAM2 = LibAddonMenu2


function BT.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Blocking Time",
		displayName = BT.COL.OG .. "Blocking" .. BT.COL.END .. BT.COL.WH .. " Time" .. BT.COL.END,
		author = BT.COL.OG .. BT.author .. BT.COL.END .. BT.COL.WH .. " [EU]" .. BT.COL.END,
		version = BT.COL.OG .. BT.version .. BT.COL.END,
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local optionsData = {
		{
			type = "header",
			name = BT.COL.OG .. "General Options" .. BT.COL.END
		},
		{
			type = "checkbox",
			name = "MASTERSWITCH (Turns the entire addon ON/OFF)",
			tooltip = "Enables or disables all features of the addon. If disabled, no blocking time will be tracked or reported.",
			getFunc = function() return BT.SV.enableAddon end,
			setFunc = function(value)
				BT.SV.enableAddon = value
				if value == true then
					d(BT.COL.OG .. BT.chat .. BT.COL.END .. BT.COL.GN .. " Addon Enabled" .. BT.COL.END)
					EVENT_MANAGER:RegisterForEvent(BT.name.."EVENT_PLAYER_COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE, BT.CombatState)
				else
					d(BT.COL.OG .. BT.chat .. BT.COL.END .. BT.COL.RD .. " Addon Disabled" .. BT.COL.END)
					EVENT_MANAGER:UnregisterForEvent(BT.name.."EVENT_PLAYER_COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE)
                    EVENT_MANAGER:UnregisterForUpdate(BT.name.."UpdateBlockTime")
					EVENT_MANAGER:UnregisterForUpdate(BT.name.."PlayPenaltySound")
				end
			end,
			default = BT.default.isEnabled,
			width = "full"
		},
		{
			type = "slider",
			name = "Report: Minimum Fight Time |cff7f00 0 = OFF|r",
			tooltip = "Sets the minimum duration a fight must last (in seconds) for blocking statistics to be reported in chat. Fights shorter than this will not be reported.",
			min = 0,
			max = 120,
			step = 5,
			getFunc = function() return BT.SV.timeFightMin end,
			setFunc = function(value) BT.SV.timeFightMin = value end,
			disabled = function() return not BT.SV.enableAddon end,
			default = BT.default.timeFightMin,
			width = "full"
		},
		{
			type = "divider"
		},
		{
			type = "checkbox",
			name = "Enable for Tanks",
			tooltip = "Activates blocking time tracking and reporting when you are playing as a Tank.",
			getFunc = function() return BT.SV.isEnabledTank end,
			setFunc = function(value) BT.SV.isEnabledTank = value end,
			disabled = function() return not BT.SV.enableAddon end,
			default = BT.default.isEnabledTank,
			width = "full"
		},
		{
			type = "checkbox",
			name = "Enable for Heals",
			tooltip = "Activates blocking time tracking and reporting when you are playing as a Healer.",
			getFunc = function() return BT.SV.isEnabledHeal end,
			setFunc = function(value) BT.SV.isEnabledHeal = value end,
			disabled = function() return not BT.SV.enableAddon end,
			default = BT.default.isEnabledHeal,
			width = "full"
		},
		{
			type = "checkbox",
			name = "Enable for DPS",
			tooltip = "Activates blocking time tracking and reporting when you are playing as Damage Dealer (DPS).",
			getFunc = function() return BT.SV.isEnabledDPS end,
			setFunc = function(value) BT.SV.isEnabledDPS = value end,
			disabled = function() return not BT.SV.enableAddon end,
			default = BT.default.isEnabledDPS,
			width = "full"
		},
		{
			type = "checkbox",
			name = "Enable for Solo",
			tooltip = "Activates blocking time tracking and reporting when you are playing Solo (not in group).",
			getFunc = function() return BT.SV.isEnabledSolo end,
			setFunc = function(value) BT.SV.isEnabledSolo = value end,
			disabled = function() return not BT.SV.enableAddon end,
			default = BT.default.isEnabledSolo,
			width = "full"
		},
		{
			type = "divider"
		},
		{
			type = "slider",
			name = "Volume Penalty Click |cff7f00 0 = OFF|r",
			tooltip = "Volume of the penalty click. It's a reminder to drop your block from time to time. Starts at 2 sec.",
			min = 0,
			max = 30,
			step = 1,
			getFunc = function() return BT.SV.volumePenaltyClick end,
			setFunc = function(value) BT.SV.volumePenaltyClick = value end,
			disabled = function() return not BT.SV.enableAddon end,
			default = BT.default.volumePenaltyClick,
			width = "full"
		},
		{
			type = "button",
			name = "Play Penalty Sound",
			func = function()
				BT.penaltyQueue = 1
				BT.PlayPenaltySound()
			end,
			disabled = function() return not BT.SV.enableAddon end,
			width = "half"
		},
		{
			type = "divider"
		},
		{
			type = "description",
			text = "If you enjoy " .. BT.COL.OG .. "Blocking Time" .. BT.COL.END .. ", consider sharing your feedback or supporting its development. Your input and contributions are greatly appreciated!",
			width = "full"
		},
		{
			type = "button",
			name = "Feedback / Donate",
			tooltip = "Opens a mail to send feedback or donate to the author. <3",
			func = function()
				SCENE_MANAGER:Show('mailSend')
				zo_callLater(function()
					ZO_MailSendToField:SetText(BT.author)
					ZO_MailSendSubjectField:SetText("Blocking Time")
					ZO_MailSendBodyField:TakeFocus()
				end, 250)
			end,
			width = "full"
		}
	}
	BT.varAddonPanel = LAM2:RegisterAddonPanel(BlockingTime.name .. "Menu", panelData)
	LAM2:RegisterOptionControls(BlockingTime.name .. "Menu", optionsData)
end