function Volette.InitializeSettings()
	local panelName = "VoletteSettingsPanel"

	local panelData = {
		type = "panel",
		name = Volette.name,
		author = Volette.author,
		registerForRefresh = true,
	}

	local LAM = LibAddonMenu2
	local panel = LAM:RegisterAddonPanel(panelName, panelData)

	local optionsData = {
		[1] = {
			type = "checkbox",
			name =  GetString(VOLETTE_CONTACTS_ENABLE),
			tooltip = GetString(VOLETTE_CONTACTS_ENABLE_TOOLTIP),
			getFunc = function()
				return Volette.contacts.savedVariables.enabled
			end,
			setFunc = function(value) Volette.contacts.Enable(value) end,
			warning = GetString(VOLETTE_REQUIRES_RELOADUI),
		},
		[2] = {
			type = "editbox",
			name = GetString(VOLETTE_HQ_OWNER_CRAFT),
			getFunc = function()
				return Volette.hq.SavedVariables.CraftHqUserId
			end,
			setFunc = function(value)
				Volette.hq.SavedVariables.CraftHqUserId = value
			end,
		},
		[3] = {
			type = "editbox",
			name = GetString(VOLETTE_HQ_OWNER_PARSE),
			getFunc = function()
				return Volette.hq.SavedVariables.ParseHqUserId
			end,
			setFunc = function(value)
				Volette.hq.SavedVariables.ParseHqUserId = value
			end,
		},
		[4] = {
			type = "dropdown",
			name = GetString(VOLETTE_TRAVEL_WAYSHRINE_CHOICE),
			tooltip = GetString(VOLETTE_TRAVEL_WAYSHRINE_CHOICE_TOOLTIP),
			choices = Volette.travel.wayshrineHouses,
			getFunc = function()
				return Volette.travel.savedVariables.wayshrineHouse
			end,
			setFunc = function(value)
				Volette.travel.savedVariables.wayshrineHouse = value
			end,
		},
		[5] = {
			type = "submenu",
			name = GetString(VOLETTE_SAVINGS_SUBMENU_TITLE),
			controls = {
				[1] = {
					type = "description",
					text = GetString(VOLETTE_SAVINGS_SUBMENU_DESCRIPTION),
				},
				[2] = {
					type = "submenu",
					name = GetString(SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS),
					controls = {
						[1] = {
							type = "checkbox",
							name =  GetString(VOLETTE_SAVINGS_ENABLE),
							tooltip = GetString(VOLETTE_SAVINGS_ENABLE_TOOLTIP),
							getFunc = function() return Volette.savings.savedVariables.goldSavingsEnabled end,
							setFunc = function(value) Volette.savings.EnableGoldSavings(value) end,
						},
						[2] = {
							type = "slider",
							name = GetString(VOLETTE_SAVINGS_MINIMUM_AMOUNT),
							tooltip = VOLETTE_SAVINGS_MINIMUM_AMOUNT_TOOLTIP,
							min=0,
							max=1000000,
							step = 10000,
							getFunc = function() return Volette.savings.GetMinimumGoldAmount() end,
							setFunc = function(value) Volette.savings.SetMinimumGoldAmount(value) end,
							disabled = function() return not Volette.savings.savedVariables.goldSavingsEnabled end,
						},
						[3] = {
							type = "slider",
							name = GetString(VOLETTE_SAVINGS_MAXIMUM_AMOUNT),
							tooltip = VOLETTE_SAVINGS_MAXIMUM_AMOUNT_TOOLTIP,
							min=0,
							max=1000000,
							step = 10000,
							getFunc = function()
								return Volette.savings.savedVariables.maximumGoldAmount
							end,
							setFunc = function(value) Volette.savings.savedVariables.maximumGoldAmount = value end,
							disabled = function() return not Volette.savings.savedVariables.goldSavingsEnabled end,
						},
						[4] = {
							type = "divider",
						},
						[5] = {
							type = "description",
							text = GetString(VOLETTE_SAVINGS_ENABLE_FOR_DESCRIPTION),
						},
					},
				},
				[3] = {
					type = "submenu",
					name = GetString(SI_GAMEPAD_INVENTORY_TELVAR_STONES),
					controls = {
						[1] = {
							type = "checkbox",
							name =  GetString(VOLETTE_SAVINGS_ENABLE),
							tooltip = GetString(VOLETTE_SAVINGS_ENABLE_TOOLTIP),
							getFunc = function() return Volette.savings.savedVariables.telVarSavingsEnabled end,
							setFunc = function(value) Volette.savings.EnableTelVarSavings(value) end,
						},
						[2] = {
							type = "slider",
							name = GetString(VOLETTE_SAVINGS_MINIMUM_AMOUNT),
							tooltip = VOLETTE_SAVINGS_MINIMUM_AMOUNT_TOOLTIP,
							min=0,
							max=100000,
							step = 1000,
							getFunc = function() return Volette.savings.GetMinimumTelVarAmount() end,
							setFunc = function(value) Volette.savings.SetMinimumTelVarAmount(value) end,
							disabled = function() return not Volette.savings.savedVariables.telVarSavingsEnabled end,
						},
						[3] = {
							type = "slider",
							name = GetString(VOLETTE_SAVINGS_MAXIMUM_AMOUNT),
							tooltip = VOLETTE_SAVINGS_MAXIMUM_AMOUNT_TOOLTIP,
							min=0,
							max=100000,
							step = 1000,
							getFunc = function()
								return Volette.savings.savedVariables.maximumTelVarAmount
							end,
							setFunc = function(value) Volette.savings.savedVariables.maximumTelVarAmount = value end,
							disabled = function() return not Volette.savings.savedVariables.telVarSavingsEnabled end,
						},
						[4] = {
							type = "divider",
						},
						[5] = {
							type = "description",
							text = GetString(VOLETTE_SAVINGS_ENABLE_FOR_DESCRIPTION),
						},
					},
				},
				[4] = {
					type = "submenu",
					name = GetString(SI_GAMEPAD_INVENTORY_ALLIANCE_POINTS),
					controls = {
						[1] = {
							type = "checkbox",
							name =  GetString(VOLETTE_SAVINGS_ENABLE),
							tooltip = GetString(VOLETTE_SAVINGS_ENABLE_TOOLTIP),
							getFunc = function() return Volette.savings.savedVariables.apSavingsEnabled end,
							setFunc = function(value) Volette.savings.EnableAPSavings(value) end,
						},
						[2] = {
							type = "slider",
							name = GetString(VOLETTE_SAVINGS_MINIMUM_AMOUNT),
							tooltip = VOLETTE_SAVINGS_MINIMUM_AMOUNT_TOOLTIP,
							min=0,
							max=1000000,
							step = 10000,
							getFunc = function() return Volette.savings.GetMinimumAPAmount() end,
							setFunc = function(value) Volette.savings.SetMinimumAPAmount(value) end,
							disabled = function() return not Volette.savings.savedVariables.apSavingsEnabled end,
						},
						[3] = {
							type = "slider",
							name = GetString(VOLETTE_SAVINGS_MAXIMUM_AMOUNT),
							tooltip = VOLETTE_SAVINGS_MAXIMUM_AMOUNT_TOOLTIP,
							min=0,
							max=1000000,
							step = 10000,
							getFunc = function()
								return Volette.savings.savedVariables.maximumAPAmount
							end,
							setFunc = function(value) Volette.savings.savedVariables.maximumAPAmount = value end,
							disabled = function() return not Volette.savings.savedVariables.apSavingsEnabled end,
						},
						[4] = {
							type = "divider",
						},
						[5] = {
							type = "description",
							text = GetString(VOLETTE_SAVINGS_ENABLE_FOR_DESCRIPTION),
						},
					},
				},
				[5] = {
					type = "submenu",
					name = zo_strformat(SI_WRIT_VOUCHER_FORMAT),
					controls = {
						[1] = {
							type = "checkbox",
							name =  GetString(VOLETTE_SAVINGS_ENABLE),
							tooltip = GetString(VOLETTE_SAVINGS_ENABLE_TOOLTIP),
							getFunc = function() return Volette.savings.savedVariables.voucherSavingsEnabled end,
							setFunc = function(value) Volette.savings.EnableVoucherSavings(value) end,
						},
						[2] = {
							type = "slider",
							name = GetString(VOLETTE_SAVINGS_MINIMUM_AMOUNT),
							tooltip = VOLETTE_SAVINGS_MINIMUM_AMOUNT_TOOLTIP,
							min=0,
							max=100000,
							step = 500,
							getFunc = function() return Volette.savings.GetMinimumVoucherAmount() end,
							setFunc = function(value) Volette.savings.SetMinimumVoucherAmount(value) end,
							disabled = function() return not Volette.savings.savedVariables.voucherSavingsEnabled end,
						},
						[3] = {
							type = "slider",
							name = GetString(VOLETTE_SAVINGS_MAXIMUM_AMOUNT),
							tooltip = VOLETTE_SAVINGS_MAXIMUM_AMOUNT_TOOLTIP,
							min=0,
							max=100000,
							step = 500,
							getFunc = function()
								return Volette.savings.savedVariables.maximumVoucherAmount
							end,
							setFunc = function(value) Volette.savings.savedVariables.maximumVoucherAmount = value end,
							disabled = function() return not Volette.savings.savedVariables.voucherSavingsEnabled end,
						},
						[4] = {
							type = "divider",
						},
						[5] = {
							type = "description",
							text = GetString(VOLETTE_SAVINGS_ENABLE_FOR_DESCRIPTION),
						},
					},
				},
			},
		},
	}

	for characterName, characterId in pairs(Volette.charactersList) do
		table.insert(optionsData[5].controls[2].controls, {
			type = "checkbox",
			name = characterName,
			getFunc = function()
				return Volette.savings.savedVariables.goldSavingsEnabledFor[characterId]
			end,
			setFunc = function(value)
				Volette.savings.EnableTelVarSavings(nil, value)
			end,
			disabled = function() return not Volette.savings.savedVariables.goldSavingsEnabled end,
		})

		table.insert(optionsData[5].controls[3].controls, {
			type = "checkbox",
			name = characterName,
			getFunc = function()
				return Volette.savings.savedVariables.telVarSavingsEnabledFor[characterId]
			end,
			setFunc = function(value)
				Volette.savings.EnableTelVarSavings(nil, value)
			end,
			disabled = function() return not Volette.savings.savedVariables.telVarSavingsEnabled end,
		})

		table.insert(optionsData[5].controls[4].controls, {
			type = "checkbox",
			name = characterName,
			getFunc = function()
				return Volette.savings.savedVariables.apSavingsEnabledFor[characterId]
			end,
			setFunc = function(value)
				Volette.savings.EnableAPSavings(nil, value)
			end,
			disabled = function() return not Volette.savings.savedVariables.apSavingsEnabled end,
		})

		table.insert(optionsData[5].controls[5].controls, {
			type = "checkbox",
			name = characterName,
			getFunc = function()
				return Volette.savings.savedVariables.voucherSavingsEnabledFor[characterId]
			end,
			setFunc = function(value)
				Volette.savings.EnableVoucherSavings(nil, value)
			end,
			disabled = function() return not Volette.savings.savedVariables.voucherSavingsEnabled end,
		})
	end

	LAM:RegisterOptionControls(panelName, optionsData)
end