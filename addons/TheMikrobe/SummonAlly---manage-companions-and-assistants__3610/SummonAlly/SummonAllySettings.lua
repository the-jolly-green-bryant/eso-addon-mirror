--------------------
-- settings menu
--------------------
function SummonAlly.LoadSettings()

	local LAM = LibAddonMenu2

	local companionDropDown = {}
	for _,v in pairs(SummonAlly.savedVars.alliesTable.companionTable) do
		table.insert(companionDropDown, v)
	end

	local bankerDropDown = {}
	for _,v in pairs(SummonAlly.savedVars.alliesTable.bankerTable) do
		table.insert(bankerDropDown, v)
	end

	local merchantDropDown = {}
	for _,v in pairs(SummonAlly.savedVars.alliesTable.merchantTable) do
		table.insert(merchantDropDown, v)
	end

	local fenceDropDown = {}
	for _,v in pairs(SummonAlly.savedVars.alliesTable.fenceTable) do
		table.insert(fenceDropDown, v)
	end

	local armoryDropDown = {}
	for _,v in pairs(SummonAlly.savedVars.alliesTable.armoryTable) do
		table.insert(armoryDropDown, v)
	end

	local deconDropDown = {}
	for _,v in pairs(SummonAlly.savedVars.alliesTable.deconTable) do
		table.insert(deconDropDown, v)
	end

--------------------
	local panelData = {
		type = "panel",
		name = SummonAlly.name,
		displayName = SummonAlly.name,
		author = SummonAlly.author,
		version = SummonAlly.version,
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local optionsTable = {}

	table.insert(optionsTable,
		{
			type = "checkbox",
			name = GetString(SUMMONALLY_ACCOUNTWIDE),
			tooltip = GetString(SUMMONALLY_ACCOUNTWIDE_TT),
			getFunc = function()
				return SummonAlly.savedVars.accountWide
			end,
			setFunc = function(value)
				SummonAlly.characterSavedVars.accountWide = value
				SummonAlly.accountSavedVars.accountWide = value
			end,
			width = "full",
			requiresReload = true,
			warning = GetString(SUMMONALLY_ACCOUNTWIDE_WARN),
		}
	)

--companions
--------------------
	table.insert(optionsTable,
		{
			type = "header",
			name = GetString(SUMMONALLY_H_COMPANIONS),
			width = "full",
		}
	)
	table.insert(optionsTable,
		{
			type = "dropdown",
			name = GetString(SUMMONALLY_PREFERRED_COMPANION),
			tooltip = GetString(SUMMONALLY_PREFERRED_COMPANION_TT),
			choices = companionDropDown,
			getFunc = function()
				return SummonAlly.savedVars.companionPreferred --/SummonAlly.savedVars.companionNamePreferred
			end,
			setFunc = function(value)
				SummonAlly.savedVars.companionPreferred = value
				end,
			width = "full",
			warning = GetString(SUMMONALLY_PREFERRED_COMPANION_WARN),
		}
	)

--companion settings
--------------------
--reactions
	table.insert(optionsTable, {
		type = "submenu",
		name = GetString(SI_INTERFACE_OPTIONS_COMPANION_REACTIONS),
		tooltip = GetString(SI_INTERFACE_OPTIONS_COMPANION_REACTIONS_TOOLTIP),
		controls = {
			[1] = {
				type = "checkbox",
				name = GetString(SUMMONALLY_COMPANION_REACTIONS),
				tooltip = GetString(SUMMONALLY_COMPANION_REACTIONS_TT),
				getFunc = function()
					return SummonAlly.savedVars.autoCompanionReactions
				end,
				setFunc = function(value)
					SummonAlly.savedVars.autoCompanionReactions = value
					SummonAlly.CompanionSettings()
				end,
				width = "full",
			},
			[2] = {
				type = "dropdown",
				name = GetCollectibleInfo(9245),					--Bastian Hallix
				choices = {GetString(SI_COMPANIONREACTIONFREQUENCYRATE3), GetString(SI_COMPANIONREACTIONFREQUENCYRATE0), GetString(SI_COMPANIONREACTIONFREQUENCYRATE1), GetString(SI_COMPANIONREACTIONFREQUENCYRATE2)},
				getFunc = function()
					return SummonAlly.savedVars.bastianReactions
				end,
				setFunc = function(value)
					SummonAlly.savedVars.bastianReactions = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
			[3] = {
				type = "dropdown",
				name = GetCollectibleInfo(9353),					--Mirri Elendis
				choices = {GetString(SI_COMPANIONREACTIONFREQUENCYRATE3), GetString(SI_COMPANIONREACTIONFREQUENCYRATE0), GetString(SI_COMPANIONREACTIONFREQUENCYRATE1), GetString(SI_COMPANIONREACTIONFREQUENCYRATE2)},
				getFunc = function()
					return SummonAlly.savedVars.mirriReactions
				end,
				setFunc = function(value)
					SummonAlly.savedVars.mirriReactions = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
			[4] = {
				type = "dropdown",
				name = GetCollectibleInfo(9911),					--Ember
				choices = {GetString(SI_COMPANIONREACTIONFREQUENCYRATE3), GetString(SI_COMPANIONREACTIONFREQUENCYRATE0), GetString(SI_COMPANIONREACTIONFREQUENCYRATE1), GetString(SI_COMPANIONREACTIONFREQUENCYRATE2)},
				getFunc = function()
					return SummonAlly.savedVars.emberReactions
				end,
				setFunc = function(value)
					SummonAlly.savedVars.emberReactions = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
			[5] = {
				type = "dropdown",
				name = GetCollectibleInfo(9912),					--Isobel Veloise
				choices = {GetString(SI_COMPANIONREACTIONFREQUENCYRATE3), GetString(SI_COMPANIONREACTIONFREQUENCYRATE0), GetString(SI_COMPANIONREACTIONFREQUENCYRATE1), GetString(SI_COMPANIONREACTIONFREQUENCYRATE2)},
				getFunc = function()
					return SummonAlly.savedVars.isobelReactions
				end,
				setFunc = function(value)
					SummonAlly.savedVars.isobelReactions = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
			[6] = {
				type = "dropdown",
				name = GetCollectibleInfo(11113),					--Sharp-as-Night
				choices = {GetString(SI_COMPANIONREACTIONFREQUENCYRATE3), GetString(SI_COMPANIONREACTIONFREQUENCYRATE0), GetString(SI_COMPANIONREACTIONFREQUENCYRATE1), GetString(SI_COMPANIONREACTIONFREQUENCYRATE2)},
				getFunc = function()
					return SummonAlly.savedVars.sharpReactions
				end,
				setFunc = function(value)
					SummonAlly.savedVars.sharpReactions = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
			[7] = {
				type = "dropdown",
				name = GetCollectibleInfo(11114),					--Azandar al-Cybiades
				choices = {GetString(SI_COMPANIONREACTIONFREQUENCYRATE3), GetString(SI_COMPANIONREACTIONFREQUENCYRATE0), GetString(SI_COMPANIONREACTIONFREQUENCYRATE1), GetString(SI_COMPANIONREACTIONFREQUENCYRATE2)},
				getFunc = function()
					return SummonAlly.savedVars.azandarReactions
				end,
				setFunc = function(value)
					SummonAlly.savedVars.azandarReactions = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
		},
	})

--passenger
	table.insert(optionsTable, {
		type = "submenu",
		name = GetString(SI_INTERFACE_OPTIONS_COMPANION_PASSENGER_PREFERENCE),
		tooltip = GetString(SI_INTERFACE_OPTIONS_COMPANION_PASSENGER_PREFERENCE_TOOLTIP),
		controls = {
			[1] = {
				type = "checkbox",
				name = GetString(SUMMONALLY_COMPANION_PASSENGER),
				tooltip = GetString(SUMMONALLY_COMPANION_PASSENGER_TT),
				getFunc = function()
					return SummonAlly.savedVars.autoCompanionPassenger
				end,
				setFunc = function(value)
					SummonAlly.savedVars.autoCompanionPassenger = value
					SummonAlly.CompanionSettings()
				end,
				width = "full",
			},
			[2] = {
				type = "dropdown",
				name = GetCollectibleInfo(9245),					--Bastian Hallix
				choices = {GetString(SI_COMPANIONPASSENGERPREFERENCE0), GetString(SI_COMPANIONPASSENGERPREFERENCE1), GetString(SI_COMPANIONPASSENGERPREFERENCE2)},
				getFunc = function()
					return SummonAlly.savedVars.bastianPassenger
				end,
				setFunc = function(value)
					SummonAlly.savedVars.bastianPassenger = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
			[3] = {
				type = "dropdown",
				name = GetCollectibleInfo(9353),					--Mirri Elendis
				choices = {GetString(SI_COMPANIONPASSENGERPREFERENCE0), GetString(SI_COMPANIONPASSENGERPREFERENCE1), GetString(SI_COMPANIONPASSENGERPREFERENCE2)},
				getFunc = function()
					return SummonAlly.savedVars.mirriPassenger
				end,
				setFunc = function(value)
					SummonAlly.savedVars.mirriPassenger = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
			[4] = {
				type = "dropdown",
				name = GetCollectibleInfo(9911),					--Ember
				choices = {GetString(SI_COMPANIONPASSENGERPREFERENCE0), GetString(SI_COMPANIONPASSENGERPREFERENCE1), GetString(SI_COMPANIONPASSENGERPREFERENCE2)},
				getFunc = function()
					return SummonAlly.savedVars.emberPassenger
				end,
				setFunc = function(value)
					SummonAlly.savedVars.emberPassenger = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
			[5] = {
				type = "dropdown",
				name = GetCollectibleInfo(9912),					--Isobel Veloise
				choices = {GetString(SI_COMPANIONPASSENGERPREFERENCE0), GetString(SI_COMPANIONPASSENGERPREFERENCE1), GetString(SI_COMPANIONPASSENGERPREFERENCE2)},
				getFunc = function()
					return SummonAlly.savedVars.isobelPassenger
				end,
				setFunc = function(value)
					SummonAlly.savedVars.isobelPassenger = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
			[6] = {
				type = "dropdown",
				name = GetCollectibleInfo(11113),					--Sharp-as-Night
				choices = {GetString(SI_COMPANIONPASSENGERPREFERENCE0), GetString(SI_COMPANIONPASSENGERPREFERENCE1), GetString(SI_COMPANIONPASSENGERPREFERENCE2)},
				getFunc = function()
					return SummonAlly.savedVars.sharpPassenger
				end,
				setFunc = function(value)
					SummonAlly.savedVars.sharpPassenger = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
			[7] = {
				type = "dropdown",
				name = GetCollectibleInfo(11114),					--Azandar al-Cybiades
				choices = {GetString(SI_COMPANIONPASSENGERPREFERENCE0), GetString(SI_COMPANIONPASSENGERPREFERENCE1), GetString(SI_COMPANIONPASSENGERPREFERENCE2)},
				getFunc = function()
					return SummonAlly.savedVars.azandarPassenger
				end,
				setFunc = function(value)
					SummonAlly.savedVars.azandarPassenger = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
		},
	})

--ultimate
	table.insert(optionsTable, {
		type = "submenu",
		name = GetString(SI_INTERFACE_OPTIONS_COMBAT_ALLOW_COMPANION_AUTO_ULTIMATE),
		tooltip = GetString(SI_INTERFACE_OPTIONS_COMBAT_ALLOW_COMPANION_AUTO_ULTIMATE_TOOLTIP),
		controls = {
			[1] = {
				type = "checkbox",
				name = GetString(SUMMONALLY_COMPANION_ULTIMATE),
				tooltip = GetString(SUMMONALLY_COMPANION_ULTIMATE_TT),
				getFunc = function()
					return SummonAlly.savedVars.autoCompanionUltimate
				end,
				setFunc = function(value)
					SummonAlly.savedVars.autoCompanionUltimate = value
					SummonAlly.CompanionSettings()
				end,
				width = "full",
			},
			[2] = {
				type = "checkbox",
				name = GetCollectibleInfo(9245),					--Bastian Hallix
				getFunc = function()
					return SummonAlly.savedVars.bastianUltimate
				end,
				setFunc = function(value)
					SummonAlly.savedVars.bastianUltimate = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
			[3] = {
				type = "checkbox",
				name = GetCollectibleInfo(9353),					--Mirri Elendis
				getFunc = function()
					return SummonAlly.savedVars.mirriUltimate
				end,
				setFunc = function(value)
					SummonAlly.savedVars.mirriUltimate = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
			[4] = {
				type = "checkbox",
				name = GetCollectibleInfo(9911),					--Ember
				getFunc = function()
					return SummonAlly.savedVars.emberUltimate
				end,
				setFunc = function(value)
					SummonAlly.savedVars.emberUltimate = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
			[5] = {
				type = "checkbox",
				name = GetCollectibleInfo(9912),					--Isobel Veloise
				getFunc = function()
					return SummonAlly.savedVars.isobelUltimate
				end,
				setFunc = function(value)
					SummonAlly.savedVars.isobelUltimate = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
			[6] = {
				type = "checkbox",
				name = GetCollectibleInfo(11113),					--Sharp-as-Night
				getFunc = function()
					return SummonAlly.savedVars.sharpUltimate
				end,
				setFunc = function(value)
					SummonAlly.savedVars.sharpUltimate = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
			[7] = {
				type = "checkbox",
				name = GetCollectibleInfo(11114),					--Azandar al-Cybiades
				getFunc = function()
					return SummonAlly.savedVars.azandarUltimate
				end,
				setFunc = function(value)
					SummonAlly.savedVars.azandarUltimate = value
					SummonAlly.CompanionSettings()
				end,
				width = "half",
			},
		},
	})

--assistants
--------------------
	table.insert(optionsTable,
		{
			type = "header",
			name = GetString(SUMMONALLY_H_ASSISTANTS),
			width = "full",
		}
	)
	table.insert(optionsTable,
		{
			type = "dropdown",
			name = GetString(SUMMONALLY_PREFERRED_BANKER),
			tooltip = GetString(SUMMONALLY_PREFERRED_BANKER_TT),
			choices = bankerDropDown,
			getFunc = function()
				return SummonAlly.savedVars.bankerPreferred
			end,
			setFunc = function(value)
				SummonAlly.savedVars.bankerPreferred = value
			end,
			width = "half",
			warning = GetString(SUMMONALLY_PREFERRED_BANKER_WARN),
		}
	)
	table.insert(optionsTable,
		{
			type = "dropdown",
			name = GetString(SUMMONALLY_PREFERRED_MERCHANT),
			tooltip = GetString(SUMMONALLY_PREFERRED_MERCHANT_TT),
			choices = merchantDropDown,
			getFunc = function()
				return SummonAlly.savedVars.merchantPreferred
			end,
			setFunc = function(value)
				SummonAlly.savedVars.merchantPreferred = value
			end,
			width = "half",
			warning = GetString(SUMMONALLY_PREFERRED_MERCHANT_WARN),
		}
	)
	table.insert(optionsTable,
		{
			type = "dropdown",
			name = GetString(SUMMONALLY_PREFERRED_FENCE),
			tooltip = GetString(SUMMONALLY_PREFERRED_FENCE_TT),
			choices = fenceDropDown,
			getFunc = function()
				return SummonAlly.savedVars.fencePreferred
			end,
			setFunc = function(value)
				SummonAlly.savedVars.fencePreferred = value
			end,
			width = "half",
			warning = GetString(SUMMONALLY_PREFERRED_FENCE_WARN),
		}
	)
	table.insert(optionsTable,
		{
			type = "dropdown",
			name = GetString(SUMMONALLY_PREFERRED_ARMORY),
			tooltip = GetString(SUMMONALLY_PREFERRED_ARMORY_TT),
			choices = armoryDropDown,
			getFunc = function()
				return SummonAlly.savedVars.armoryPreferred
			end,
			setFunc = function(value)
				SummonAlly.savedVars.armoryPreferred = value
			end,
			width = "half",
			warning = GetString(SUMMONALLY_PREFERRED_ARMORY_WARN),
		}
	)
	table.insert(optionsTable,
		{
			type = "dropdown",
			name = GetString(SUMMONALLY_PREFERRED_DECON),
			tooltip = GetString(SUMMONALLY_PREFERRED_DECON_TT),
			choices = deconDropDown,
			getFunc = function()
				return SummonAlly.savedVars.deconPreferred
			end,
			setFunc = function(value)
				SummonAlly.savedVars.deconPreferred = value
			end,
			width = "half",
			warning = GetString(SUMMONALLY_PREFERRED_DECON_WARN),
		}
	)

	LAM:RegisterAddonPanel(SummonAlly.menuName, panelData)
	LAM:RegisterOptionControls(SummonAlly.menuName, optionsTable)
end