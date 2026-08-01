Volette = {
	name = "Volette",
	author = "@FeynmanRules",
	hq = {},
	contacts = {
		items={},
	},
	travel = {},
	savings = {},
}

function Volette.Initialize()
	local saved_variables_hq_default = {
		CraftHqUserId = "",
		ParseHqUserId = "",
	}
	local saved_variables_contacts_default = {
		enabled = true,
		playerList = {},
		pos = {
			top = nil,
			left = nil,
		},
		pinned = {},
	}
	local saved_variables_travel_default = {
		wayshrineHouse = Volette.travel.autoChoice
	}
	local saved_variables_savings_default = {
		goldSavingsEnabled = false,
		goldSavingsEnabledFor = {},
		telVarSavingsEnabled = false,
		telVarSavingsEnabledFor = {},
		apSavingsEnabled = false,
		apSavingsEnabledFor = {},
		voucherSavingsEnabled = false,
		voucherSavingsEnabledFor = {},
		minimumGoldAmount = 200000,
		maximumGoldAmount = 300000,
		minimumTelVarAmount = 1000,
		maximumTelVarAmount = 1000,
		minimumAPAmount = 0,
		maximumAPAmount = 0,
		minimumVoucherAmount = 1000,
		maximumVoucherAmount = 1000,
	}
	Volette.InitializeCharactersList()
	for _, characterId in pairs(Volette.charactersList) do
		saved_variables_savings_default.goldSavingsEnabledFor[characterId] = true
		saved_variables_savings_default.telVarSavingsEnabledFor[characterId] = true
		saved_variables_savings_default.apSavingsEnabledFor[characterId] = true
		saved_variables_savings_default.voucherSavingsEnabledFor[characterId] = true
	end

	Volette.hq.SavedVariables = ZO_SavedVars:NewAccountWide(
		"VoletteSavedVariables", 1, "hq", saved_variables_hq_default
	)
	Volette.contacts.savedVariables = ZO_SavedVars:NewAccountWide(
		"VoletteSavedVariables", 1, "contacts", saved_variables_contacts_default
	)
	Volette.travel.savedVariables = ZO_SavedVars:NewAccountWide(
		"VoletteSavedVariables", 1, "travel", saved_variables_travel_default
	)
	Volette.savings.savedVariables = ZO_SavedVars:NewAccountWide(
		"VoletteSavedVariables", 2, "savings", saved_variables_savings_default
	)
	Volette.savings.UpdateSavedVariables()

	Volette.InitializeConfirmReloadDialog()
	Volette.LoadSlashCommands()
	Volette.InitializeSettings()

	if Volette.contacts.savedVariables.enabled then
		VoletteContactsMenu.Initialize()
		Volette.contacts.registerState = true
	else
		Volette.contacts.registerState = false
	end
	local characterId = GetCurrentCharacterId()
	if (
		Volette.savings.savedVariables.goldSavingsEnabled and Volette.savings.savedVariables.goldSavingsEnabledFor[characterId]
		or Volette.savings.savedVariables.telVarSavingsEnabled and Volette.savings.savedVariables.telVarSavingsEnabledFor[characterId]
		or Volette.savings.savedVariables.telVarSavingsEnabled and Volette.savings.savedVariables.apSavingsEnabledFor[characterId]
		or Volette.savings.savedVariables.voucherSavingsEnabled and Volette.savings.savedVariables.voucherSavingsEnabledFor[characterId]
	) then
		EVENT_MANAGER:RegisterForEvent(Volette.name, EVENT_OPEN_BANK, Volette.savings.OnBankOpened)
	end

end

function Volette.OnAddonLoaded(event, addonName)
	if addonName == Volette.name then
		Volette.Initialize()
		EVENT_MANAGER:UnregisterForEvent(Volette.name, EVENT_ADD_ON_LOADED)
	end
end

function Volette.OnContactsMenuMoveStop()
	Volette.contacts.SaveContactsMenuPosition()
end


EVENT_MANAGER:RegisterForEvent(Volette.name, EVENT_ADD_ON_LOADED, Volette.OnAddonLoaded)
