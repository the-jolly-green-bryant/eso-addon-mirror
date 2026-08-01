local LAM = LibAddonMenu2
TelVarSaver = TelVarSaver or {}
local TVS = TelVarSaver
-- Creating LAM2 MENU --
function TVS.CreateSettingsMenu()
	local panelName = "TelVar Saver"
	local panelData = {
		type = "panel",
		name = TVS.name,
		displayName = panelName,
		author = TVS.author,
		version = TVS.version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local options = {}

	table.insert(options, {
		type = "header",
		name = "Chat Notifications",
	})

	table.insert(options, {
		type = "checkbox",
		name = "Chat notifications (master)",
		tooltip = "Master switch for all TelVarSaver chat messages. When off, nothing below is printed.",
		default = TVS.defaults.notifications,
		getFunc = function() return TVS.SV.notifications end,
		setFunc = function(value) TVS.SV.notifications = value end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Bank notifications",
		tooltip = "Deposits and withdrawals: auto/manual deposit and withdraw messages, and bank-related warnings.",
		default = TVS.defaults.notifyBank,
		disabled = function() return TVS.SV.notifications == false end,
		getFunc = function() return TVS.SV.notifyBank end,
		setFunc = function(value) TVS.SV.notifyBank = value end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Auto-leave notifications",
		tooltip = "Messages when you toggle 'Auto leave when Tel Var limit reached' on or off.",
		default = TVS.defaults.notifyAutoLeave,
		disabled = function() return TVS.SV.notifications == false end,
		getFunc = function() return TVS.SV.notifyAutoLeave end,
		setFunc = function(value) TVS.SV.notifyAutoLeave = value end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Queue / campaign notifications",
		tooltip = "Messages about queuing, entering campaigns, queue blocks, and kicking offline group members.",
		default = TVS.defaults.notifyQueue,
		disabled = function() return TVS.SV.notifications == false end,
		getFunc = function() return TVS.SV.notifyQueue end,
		setFunc = function(value) TVS.SV.notifyQueue = value end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Sigil notifications",
		tooltip = "Messages when Sigils of Imperial Retreat are auto-purchased at a vendor.",
		default = TVS.defaults.notifySigil,
		disabled = function() return TVS.SV.notifications == false end,
		getFunc = function() return TVS.SV.notifySigil end,
		setFunc = function(value) TVS.SV.notifySigil = value end,
	})

	table.insert(options, {
		type = "header",
		name = "Time/Life Savers",
	})

	table.insert(options, {
		type = "checkbox",
		name = "Auto loot imperial fragments",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Determines if the addon will auto loot imperial fragments when opening a loot menu",
		default = TVS.defaults.AutoLootKeyFrags,
		getFunc = function() return TVS.SV.AutoLootKeyFrags end,
		setFunc = function(value) TVS.SV.AutoLootKeyFrags = value end,
	})
	table.insert(options, {
		type = "checkbox",
		name = "Auto loot gold in IC",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Determines if the addon will auto loot gold when opening a loot menu",
		default = TVS.defaults.AutoLootGold,
		getFunc = function() return TVS.SV.AutoLootGold end,
		setFunc = function(value) TVS.SV.AutoLootGold = value end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Auto loot Tel Var (containers and chests) in IC",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Determines if the addon will auto loot Tel Var when opening a loot menu",
		default = TVS.defaults.AutoLootTelvar,
		getFunc = function() return TVS.SV.AutoLootTelvar end,
		setFunc = function(value) TVS.SV.AutoLootTelvar = value end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Skip bank dialog in IC",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Will skip the bank dialog if you're in IC.",
		default = TVS.defaults.SkipBankDialog,
		getFunc = function() return TVS.SV.SkipBankDialog end,
		setFunc = function(value) TVS.SV.SkipBankDialog = value end,
	})

	table.insert(options, {
		type = "header",
		name = "Auto Deposits and Withdraw from bank",
	})

	table.insert(options, {
		type = "checkbox",
		name = "Auto deposit Tel Var into bank",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "If your current carried Tel Var exceeds your desired amount, deposit the excess",
		default = TVS.defaults.AutoDepoTelvar,
		getFunc = function() return TVS.SV.AutoDepoTelvar end,
		setFunc = function(value)
			TVS.SV.AutoDepoTelvar = value
			TVS.UpdateBankControls()
		end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Auto withdraw Tel Var from bank",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "If your current carried Tel Var is below your desired amount, withdraw the amount to reach it",
		default = TVS.defaults.AutoWithdrawTelvar,
		getFunc = function() return TVS.SV.AutoWithdrawTelvar end,
		setFunc = function(value)
			TVS.SV.AutoWithdrawTelvar = value
			TVS.UpdateBankControls()
		end,
	})

	table.insert(options, {
		type = "editbox",
		name = "Desired carried Tel Var ",
		tooltip = "The amount you want to carry (for auto depos and withdraws)",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		default = TVS.defaults.DesiredTelvarAmount,
		getFunc = function() return TVS.SV.DesiredTelvarAmount end,
		setFunc = function(text)
			local amount = tonumber(text)
			if not amount then amount = TVS.SV.DesiredTelvarAmount end
			-- If you really really really want to take out more than 10k for some reason with this addon, remove the if statement at your own risk
			if (amount < 0) or (amount > 10000) then
				amount = 0
				d("Invalid amount. Must be between 0 and 10000")
			end
			TVS.SV.DesiredTelvarAmount = amount
			TVS.UpdateBankControls()
		end,
	})

	table.insert(options, {
		type = "header",
		name = "Bank Menu",
	})

	table.insert(options, {
		type = "checkbox",
		name = "Bank Scene",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Determines if the bank scene shows up or not",
		default = TVS.defaults.BankScene,
		getFunc = function() return TVS.SV.BankScene end,
		setFunc = function(value)
			if value == false then TVS.HideUi() end
			TVS.SV.BankScene = value
		end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Draggable",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "",
		default = TVS.defaults.draggable,
		getFunc = function() return TVS.SV.draggable end,
		setFunc = function(value)
			TVS.SV.draggable = value
			TVS.UpdateAnchors()
		end,
	})

	table.insert(options, {
		type = "header",
		name = "Auto-Leave Widget",
	})

	table.insert(options, {
		type = "description",
		text = "Toggles 'Auto leave when Tel Var limit reached' on/off without opening this menu. It shows your Tel Var limit in green when on, red when off. Yellow if you have too much Tel Var",
	})

	
	table.insert(options, {
		type = "checkbox",
		name = "Show button",
		tooltip = "Shows a small draggable icon that toggles 'Auto leave when Tel Var limit reached' on/off without opening this menu.",
		default = TVS.defaults.AutoLeaveToggleShow,
		getFunc = function() return TVS.SV.AutoLeaveToggleShow end,
		setFunc = function(value)
			TVS.SV.AutoLeaveToggleShow = value
			TVS.RefreshAutoLeaveToggleVisibility()
		end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Draggable",
		tooltip = "Determines if the on-screen Auto-Leave toggle button can be dragged.",
		default = TVS.defaults.AutoLeaveToggleDragable,
		getFunc = function() return TVS.SV.AutoLeaveToggleDragable end,
		setFunc = function(value)
			TVS.SV.AutoLeaveToggleDragable = value
			TVS.UpdateAutoLeaveTogglePosition()
		end,
	})

	table.insert(options, {
		type = "button",
		name = "Reset Auto-Leave toggle position",
		func = function()
			TVS.SV.AutoLeaveToggleX = TVS.defaults.AutoLeaveToggleX
			TVS.SV.AutoLeaveToggleY = TVS.defaults.AutoLeaveToggleY
			TVS.UpdateAutoLeaveTogglePosition()
		end,
	})

	table.insert(options, {
		type = "header",
		name = "Sigil of Imperial Retreat",
	})

	

	table.insert(options, {
		type = "description",
		text = "Shows a brief on-screen reminder to restock Sigils of Imperial Retreat each time you load into Imperial City while low, and can auto-purchase them or withdraw from your bank.",
	})

	table.insert(options, {
		type = "description",
		text = "Tel Var Saver also provides a keybind to quickly use a Sigil of Imperial Retreat from your quickbar",
	})
	
	table.insert(options, {
		type = "checkbox",
		name = "Show on-screen reminder",
		tooltip = "On-screen reminder when you load into IC low on Sigils.",
		default = TVS.defaults.SigilReminderEnabled,
		getFunc = function() return TVS.SV.SigilReminderEnabled end,
		setFunc = function(value) TVS.SV.SigilReminderEnabled = value end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Hide reminder in safe zones",
		tooltip = "Don't show the reminder while in an IC safe zone.",
		default = TVS.defaults.SigilReminderHideInSafeZone,
		disabled = function() return TVS.SV.SigilReminderEnabled == false end,
		getFunc = function() return TVS.SV.SigilReminderHideInSafeZone end,
		setFunc = function(value)
			TVS.SV.SigilReminderHideInSafeZone = value
			if value == true then TVS.SV.SigilReminderHideInNonSafeZone = false end
		end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Hide reminder outside safe zones",
		tooltip = "Only show the reminder while in an IC safe zone.",
		default = TVS.defaults.SigilReminderHideInNonSafeZone,
		disabled = function() return TVS.SV.SigilReminderEnabled == false end,
		getFunc = function() return TVS.SV.SigilReminderHideInNonSafeZone end,
		setFunc = function(value)
			TVS.SV.SigilReminderHideInNonSafeZone = value
			if value == true then TVS.SV.SigilReminderHideInSafeZone = false end
		end,
	})

	table.insert(options, {
		type = "slider",
		name = "Remind when Sigils below",
		tooltip = "Remind when carried Sigils drop below this.",
		min = 1,
		max = 20,
		step = 1,
		default = TVS.defaults.SigilReminderThreshold,
		disabled = function() return TVS.SV.SigilReminderEnabled == false end,
		getFunc = function() return TVS.SV.SigilReminderThreshold end,
		setFunc = function(value) TVS.SV.SigilReminderThreshold = value end,
	})

	table.insert(options, {
		type = "slider",
		name = "Reminder duration (seconds)",
		tooltip = "How long the reminder stays before fading.",
		min = 0,
		max = 15,
		step = 1,
		default = TVS.defaults.SigilReminderDurationS,
		disabled = function() return TVS.SV.SigilReminderEnabled == false end,
		getFunc = function() return TVS.SV.SigilReminderDurationS end,
		setFunc = function(value) TVS.SV.SigilReminderDurationS = value end,
	})

	table.insert(options, {
		type = "colorpicker",
		name = "Reminder color",
		tooltip = "Text color of the reminder.",
		default = TVS.defaults.SigilReminderColor,
		disabled = function() return TVS.SV.SigilReminderEnabled == false end,
		getFunc = function()
			local c = TVS.SV.SigilReminderColor
			return c[1], c[2], c[3], c[4]
		end,
		setFunc = function(r, g, b, a) TVS.SV.SigilReminderColor = { r, g, b, a } end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Reminder sound",
		tooltip = "Play a sound when the reminder appears.",
		default = TVS.defaults.SigilReminderSoundEnabled,
		disabled = function() return TVS.SV.SigilReminderEnabled == false end,
		getFunc = function() return TVS.SV.SigilReminderSoundEnabled end,
		setFunc = function(value) TVS.SV.SigilReminderSoundEnabled = value end,
	})

	local soundNames, soundKeys = {}, {}
	for _, choice in ipairs(TVS.SIGIL_SOUND_CHOICES) do
		table.insert(soundNames, choice.label)
		table.insert(soundKeys, choice.key)
	end
	table.insert(options, {
		type = "dropdown",
		name = "Sound",
		tooltip = "Which sound to play.",
		choices = soundNames,
		choicesValues = soundKeys,
		default = TVS.defaults.SigilReminderSound,
		disabled = function()
			return (TVS.SV.SigilReminderEnabled == false) or (TVS.SV.SigilReminderSoundEnabled == false)
		end,
		getFunc = function() return TVS.SV.SigilReminderSound end,
		setFunc = function(value)
			TVS.SV.SigilReminderSound = value
			if SOUNDS[value] then PlaySound(SOUNDS[value]) end
		end,
	})

	table.insert(options, {
		type = "button",
		name = "Preview reminder",
		tooltip = "Preview the reminder now.",
		disabled = function() return TVS.SV.SigilReminderEnabled == false end,
		func = function() TVS.TestSigilReminder() end,
	})

	table.insert(options, {
		type = "slider",
		name = "Desired Sigils to carry",
		tooltip = "Target Sigils to keep. Used by bank withdraw and auto-purchase.",
		min = 1,
		max = 100,
		step = 1,
		default = TVS.defaults.SigilDesiredAmount,
		getFunc = function() return TVS.SV.SigilDesiredAmount end,
		setFunc = function(value) TVS.SV.SigilDesiredAmount = value end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Withdraw from bank when opening bank",
		tooltip = "On bank open, withdraw Sigils to reach your target.",
		default = TVS.defaults.SigilBankWithdraw,
		getFunc = function() return TVS.SV.SigilBankWithdraw end,
		setFunc = function(value) TVS.SV.SigilBankWithdraw = value end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Auto-purchase at vendor",
		tooltip = "At a Sigil vendor, buy enough to reach your target.",
		default = TVS.defaults.SigilAutoBuyEnabled,
		getFunc = function() return TVS.SV.SigilAutoBuyEnabled end,
		setFunc = function(value) TVS.SV.SigilAutoBuyEnabled = value end,
	})

	table.insert(options, {
		type = "slider",
		name = "Max AP to spend per purchase (0 = no cap)",
		tooltip = "Skip the purchase if it costs more than this. 0 = no cap.",
		min = 0,
		max = 100000,
		step = 1000,
		default = TVS.defaults.SigilMaxSpendAP,
		disabled = function() return TVS.SV.SigilAutoBuyEnabled == false end,
		getFunc = function() return TVS.SV.SigilMaxSpendAP end,
		setFunc = function(value) TVS.SV.SigilMaxSpendAP = value end,
	})

	table.insert(options, {
		type = "slider",
		name = "Don't buy if AP below (0 = ignore)",
		tooltip = "Don't buy if your AP is under this. 0 = ignore.",
		min = 0,
		max = 100000,
		step = 1000,
		default = TVS.defaults.SigilMinAPReserve,
		disabled = function() return TVS.SV.SigilAutoBuyEnabled == false end,
		getFunc = function() return TVS.SV.SigilMinAPReserve end,
		setFunc = function(value) TVS.SV.SigilMinAPReserve = value end,
	})

	table.insert(options, {
		type = "header",
		name = "[DEPRECATED] Campaign Options",
	})
	local function GetDynamicCampaignChoices(requireIC)
		local names = {}
		local values = {}

		local n = GetNumSelectionCampaigns()
		for i = 1, n do
			local id = GetSelectionCampaignId(i)
			if (type(id) == "number") and (IsImperialCityCampaign(id) == requireIC) then
				if DoesPlayerMeetCampaignRequirements(id) == true then
					table.insert(names, GetCampaignName(id))
					table.insert(values, id)
				end
			end
		end

		return names, values
	end

	local icChoices, icChoiceValues = GetDynamicCampaignChoices(true)
	local function GetAlternativeICCampaignId(excludedId, fallbackId)
		for _, id in ipairs(icChoiceValues) do
			if id ~= excludedId then return id end
		end
		if fallbackId ~= excludedId then return fallbackId end
		return nil
	end

	table.insert(options, {
		type = "description",
		text = "Update 50: You can no longer queue into either Imperial City or Cyrodiil campaigns with more than "
			.. tostring(GetTelVarQueueThreshold())
			.. ""
			.. " | "
			.. TVS.TELVAR_CHAT_ICON,
	})

	table.insert(options, {
		type = "description",
		text = "Therefore settings below may not work as expected or be very useful at all.",
	})

	table.insert(options, {
		type = "description",
		text = "If you have any useful tips, suggestions, workarounds or feature requests feel free to add a comment on the ESOUI page",
	})

	table.insert(options, {
		type = "dropdown",
		name = "Home Campaign",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Your primary IC campaign. If your current campaign is not home, TelVarSaver will queue this one first.",
		choices = icChoices,
		choicesValues = icChoiceValues,
		default = TVS.defaults.ICCamp,
		getFunc = function() return TVS.GetHomeCampaignId() end,
		setFunc = function(value)
			TVS.SV.ICCamp = value
			if TVS.SV.ICCamp == TVS.SV.EscapeCamp then
				local newEscape = GetAlternativeICCampaignId(TVS.SV.ICCamp, TVS.defaults.EscapeCamp)
				if newEscape ~= nil then
					TVS.SV.EscapeCamp = newEscape
					LAM.util.ShowConfirmationDialog(
						"Campaigns must be different",
						"Home Campaign cannot match Escape Campaign. Escape was changed automatically.",
						function() end
					)
				else
					LAM.util.ShowConfirmationDialog(
						"No alternate IC campaign",
						"Only one eligible IC campaign is available right now, so Home/Escape cannot be separated.",
						function() end
					)
				end
			end
		end,
	})

	table.insert(options, {
		type = "dropdown",
		name = "Escape Campaign",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Used when you are already in Home Campaign and Smart IC queue picker is disabled.",
		choices = icChoices,
		choicesValues = icChoiceValues,
		default = TVS.defaults.EscapeCamp,
		getFunc = function() return TVS.GetEscapeICCampaignId() end,
		setFunc = function(value)
			TVS.SV.EscapeCamp = value
			if TVS.SV.EscapeCamp == TVS.SV.ICCamp then
				local newHome = GetAlternativeICCampaignId(TVS.SV.EscapeCamp, TVS.defaults.ICCamp)
				if newHome ~= nil then
					TVS.SV.ICCamp = newHome
					LAM.util.ShowConfirmationDialog(
						"Campaigns must be different",
						"Escape Campaign cannot match Home Campaign. Home was changed automatically.",
						function() end
					)
				else
					LAM.util.ShowConfirmationDialog(
						"No alternate IC campaign",
						"Only one eligible IC campaign is available right now, so Home/Escape cannot be separated.",
						function() end
					)
				end
			end
		end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Auto leave when Tel Var limit reached",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Only triggers if you gain Tel Var, and the limit exceeds the set amount below. Won't trigger if you withdraw from your bank or something so be careful",
		default = TVS.defaults.AutoQueueOut,
		getFunc = function() return TVS.SV.AutoQueueOut end,
		setFunc = function(value)
			TVS.SV.AutoQueueOut = value
			TVS.UpdateAutoLeaveToggleVisual()
		end,
	})

	table.insert(options, {
		type = "editbox",
		name = "Tel Var limit (max " .. tostring(GetTelVarQueueThreshold()) .. ")",
		tooltip = "If you kill a mob or player and your Tel Var gained exceeds this int, you will queue out",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		default = TVS.defaults.TelvarCap,
		getFunc = function() return TVS.SV.TelvarCap end,
		setFunc = function(text)
			local value = tonumber(text)
			if not value then value = TVS.SV.TelvarCap end
			if value <= 0 then value = 1 end
			if value > GetTelVarQueueThreshold() then value = GetTelVarQueueThreshold() end
			TVS.SV.TelvarCap = value
			TVS.UpdateAutoLeaveToggleVisual()
		end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Smart IC queue picker",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "When leaving Imperial City, dynamically pick the best campaign using the live campaign list (eligibility, Tel Var restriction, and lowest queue wait time).",
		default = TVS.defaults.SmartQueuePicker,
		getFunc = function() return TVS.SV.SmartQueuePicker end,
		setFunc = function(value) TVS.SV.SmartQueuePicker = value end,
	})
	table.insert(options, {
		type = "checkbox",
		name = "Allow Cyrodiil campaigns (Smart Queue)",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "If off, Smart Queue will only consider Imperial City campaigns. If on, it may pick Cyrodiil campaigns too (based on lowest queue wait time), as long as your current Tel Var amount does not prevent queuing for that campaign.",
		default = TVS.defaults.AllowCyrodiilCampaigns,
		getFunc = function() return TVS.SV.AllowCyrodiilCampaigns end,
		setFunc = function(value) TVS.SV.AllowCyrodiilCampaigns = value end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Auto accept queue",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Do you want the queue to auto accept? Unneeded if you already have kill counter's auto accept enabled.",
		default = TVS.defaults.AutoAcceptQueue,
		getFunc = function() return TVS.SV.AutoAcceptQueue end,
		setFunc = function(value)
			TVS.SV.AutoAcceptQueue = value
			TVS.AutoQueueControl()
		end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Auto kick offline (IMPORTANT) ",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "To group queue you need to have no offline members in your group. By having this disabled, you will not be able to queue if you have an offline person in your group",
		default = TVS.defaults.AutoKickOffline,
		getFunc = function() return TVS.SV.AutoKickOffline end,
		setFunc = function(value) TVS.SV.AutoKickOffline = value end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Group queue ",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Determines if you group queue if you're the group leader when you hit the keybind or reach your cap",
		default = TVS.defaults.GroupQueue,
		getFunc = function() return TVS.SV.GroupQueue end,
		setFunc = function(value) TVS.SV.GroupQueue = value end,
	})

	table.insert(options, {
		type = "description",
		text = "Check your controls for the keybind, it's unbound by default",
	})

	table.insert(options, {
		type = "checkbox",
		name = "Disable keybind in PVE",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Prevents accidental queueing if you accidentally hit the key in a PVE zone",
		default = TVS.defaults.DisableKeybindInPVE,
		getFunc = function() return TVS.SV.DisableKeybindInPVE end,
		setFunc = function(value) TVS.SV.DisableKeybindInPVE = value end,
	})

	table.insert(options, {
		type = "button",
		name = "reset position to defaults",
		func = function()
			TVS.SV.locationy = TVS.defaults.locationy
			TVS.SV.locationx = TVS.defaults.locationx
			TVS.UpdateAnchors()
		end,
	})

	table.insert(options, {
		type = "button",
		name = "reset ALL SETTINGS",
		func = function()
			LAM.util.ShowConfirmationDialog("Reset all settings to defaults?", "Requires a UI reload", function()
				zo_callLater(function()
					-- lol
					TVS.SV.locationy = TVS.defaults.locationy
					TVS.SV.locationx = TVS.defaults.locationx
					TVS.UpdateAnchors()

					TVS.SV.AutoKickOffline = TVS.defaults.AutoKickOffline
					TVS.SV.LastICCamp = TVS.defaults.LastICCamp
					TVS.SV.AutoAcceptQueue = TVS.defaults.AutoAcceptQueue
					TVS.SV.SkipBankDialog = TVS.defaults.SkipBankDialog
					TVS.SV.AutoLootGold = TVS.defaults.AutoLootGold
					TVS.SV.AutoLootTelvar = TVS.defaults.AutoLootTelvar
					TVS.SV.AutoLootKeyFrags = TVS.defaults.AutoLootKeyFrags
					TVS.SV.notifications = TVS.defaults.notifications
					TVS.SV.notifyBank = TVS.defaults.notifyBank
					TVS.SV.notifyAutoLeave = TVS.defaults.notifyAutoLeave
					TVS.SV.notifyQueue = TVS.defaults.notifyQueue
					TVS.SV.draggable = TVS.defaults.draggable
					TVS.SV.locationx = TVS.defaults.locationx
					TVS.SV.locationy = TVS.defaults.locationy
					TVS.SV.BankScene = TVS.defaults.BankScene
					TVS.SV.AutoDepoTelvar = TVS.defaults.AutoDepoTelvar
					TVS.SV.AutoWithdrawTelvar = TVS.defaults.AutoWithdrawTelvar
					TVS.SV.DesiredTelvarAmount = TVS.defaults.DesiredTelvarAmount
					TVS.SV.ICCamp = TVS.defaults.ICCamp
					TVS.SV.EscapeCamp = TVS.defaults.EscapeCamp
					TVS.SV.AutoQueueOut = TVS.defaults.AutoQueueOut
					TVS.SV.TelvarCap = TVS.defaults.TelvarCap
					TVS.SV.GroupQueue = TVS.defaults.GroupQueue
					TVS.SV.DisableKeybindInPVE = TVS.defaults.DisableKeybindInPVE
					TVS.SV.SmartQueuePicker = TVS.defaults.SmartQueuePicker
					TVS.SV.AllowCyrodiilCampaigns = TVS.defaults.AllowCyrodiilCampaigns
					TVS.SV.AutoLeaveToggleShow = TVS.defaults.AutoLeaveToggleShow
					TVS.SV.AutoLeaveToggleDragable = TVS.defaults.AutoLeaveToggleDragable
					TVS.SV.AutoLeaveToggleX = TVS.defaults.AutoLeaveToggleX
					TVS.SV.AutoLeaveToggleY = TVS.defaults.AutoLeaveToggleY
					TVS.SV.SigilReminderEnabled = TVS.defaults.SigilReminderEnabled
					TVS.SV.SigilReminderHideInSafeZone = TVS.defaults.SigilReminderHideInSafeZone
					TVS.SV.SigilReminderHideInNonSafeZone = TVS.defaults.SigilReminderHideInNonSafeZone
					TVS.SV.SigilReminderThreshold = TVS.defaults.SigilReminderThreshold
					TVS.SV.SigilReminderDurationS = TVS.defaults.SigilReminderDurationS
					TVS.SV.SigilReminderColor = {
						TVS.defaults.SigilReminderColor[1],
						TVS.defaults.SigilReminderColor[2],
						TVS.defaults.SigilReminderColor[3],
						TVS.defaults.SigilReminderColor[4],
					}
					TVS.SV.SigilReminderSoundEnabled = TVS.defaults.SigilReminderSoundEnabled
					TVS.SV.SigilReminderSound = TVS.defaults.SigilReminderSound
					TVS.SV.SigilAutoBuyEnabled = TVS.defaults.SigilAutoBuyEnabled
					TVS.SV.SigilDesiredAmount = TVS.defaults.SigilDesiredAmount
					TVS.SV.SigilMaxSpendAP = TVS.defaults.SigilMaxSpendAP
					TVS.SV.SigilMinAPReserve = TVS.defaults.SigilMinAPReserve
					TVS.SV.SigilBankWithdraw = TVS.defaults.SigilBankWithdraw
					TVS.SV.notifySigil = TVS.defaults.notifySigil
					ReloadUI()
				end, 100)
			end)
		end,
	})

	-- Registering Panel and Options
	TVS.settingsPanel = LAM:RegisterAddonPanel(panelName, panelData)
	LAM:RegisterOptionControls(panelName, options)
end
