Bankir = Bankir or {}

local actionChoices = {
	[1] = GetString(BANKIR_MENU_MODE_DO_NOTHING),
	[2] = GetString(BANKIR_MENU_MODE_DEPOSIT),
	[3] = GetString(BANKIR_MENU_MODE_WITHDRAW),
	[4] = GetString(BANKIR_MENU_MODE_DEPOSIT_AND_WITHDRAW),
}

local qualityChoices = {
	[1] = GetItemQualityColor(1):Colorize(GetString("SI_ITEMQUALITY", 1)),
	[2] = GetItemQualityColor(2):Colorize(GetString("SI_ITEMQUALITY", 2)),
	[3] = GetItemQualityColor(3):Colorize(GetString("SI_ITEMQUALITY", 3)),
	[4] = GetItemQualityColor(4):Colorize(GetString("SI_ITEMQUALITY", 4)),
	[5] = GetItemQualityColor(5):Colorize(GetString("SI_ITEMQUALITY", 5)),
}

local function getSavedVarForIdType(idTypeStr)
	local selectedBagRules = Bankir.savedVars.rules[Bankir.Menu.selectedBankId]
	if idTypeStr == "itemType" then
		return selectedBagRules.byItemType
	elseif idTypeStr == "specializedItemType" then
		return selectedBagRules.bySpecializedItemType
	elseif idTypeStr == "itemId" then
		return selectedBagRules.byItemId
	end
end

local function getTypeChildrenLists(id, idTypeStr)
	local result
	if idTypeStr == "itemType" then
		if Bankir.Data.itemTypeChildrenItemIds[id] then
			result = result or {}
			table.insert(result, { idTypeStr = "itemId", list = Bankir.Data.itemTypeChildrenItemIds[id] })
		end
		if Bankir.Data.itemTypeChildrenSpecializedTypes[id] then
			result = result or {}
			table.insert(result, { idTypeStr = "specializedItemType", list = Bankir.Data.itemTypeChildrenSpecializedTypes[id] })
		end
	elseif idTypeStr == "specializedItemType" then
		if Bankir.Data.specializedItemTypeChildrenItemIds[id] then
			result = result or {}
			table.insert(result, { idTypeStr = "itemId", list = Bankir.Data.specializedItemTypeChildrenItemIds[id] })
		end
	end
	
	return result
end

local function getStacks(id, idTypeStr)
	local rule = getSavedVarForIdType(idTypeStr)[id]
	if rule then
		return rule.push, rule.pull
	else
		return 0, 0
	end
end

local function setStacks(value, action, id, idTypeStr)
	local ruleList = getSavedVarForIdType(idTypeStr)
	local oldValue
	if ruleList[id] then
		oldValue = ruleList[id][action]
	else
		ruleList[id] = { push = 0, pull = 0 }
	end
	
	if oldValue ~= value then
		ruleList[id][action] = value
		
		-- update children ids
		local childrenLists = getTypeChildrenLists(id, idTypeStr)
		if childrenLists then
			for _, list in ipairs(childrenLists) do
				for i, childId in ipairs(list.list) do
					setStacks(value, action, childId, list.idTypeStr)
				end
			end
		end
		-- update tween itemIds
		if idTypeStr == "itemId" and Bankir.Data.itemIdTweens[id] then
			for i, childId in ipairs(Bankir.Data.itemIdTweens[id]) do
				setStacks(value, action, childId, "itemId")
			end
		end
	end
	
	local anotherAction = action == "push" and "pull" or "push"
	if value == 0 and ruleList[id][anotherAction] == 0 then
		ruleList[id] = nil
	end
end

local function setQuality(value, id, idTypeStr)
	local ruleList = getSavedVarForIdType(idTypeStr)
	if ruleList[id] then
		ruleList[id].quality = value
	end
	-- update children too
	local childrenLists = getTypeChildrenLists(id, idTypeStr)
	if childrenLists then
		for _, list in ipairs(childrenLists) do
			for i, childId in ipairs(list.list) do
				setQuality(value, childId, list.idTypeStr)
			end
		end
	end
	-- update tween itemIds too
	if idTypeStr == "itemId" and Bankir.Data.itemIdTweens[id] then
		for i, childId in ipairs(Bankir.Data.itemIdTweens[id]) do
			setQuality(value, childId, "itemId")
		end
	end
end

local divider = {
	type = "divider",
	width = "full",
	height = 5,
	alpha = 1.0,
}

local dividerSmall = {
	type = "divider",
	width = "half",
	height = 5,
	alpha = 0.5,
}

local dividerInvisible = {
	type = "divider",
	width = "full",
	height = 5,
	alpha = 0.0,
}

local function makeHeader(title)
	return {
		type = "header",
		name = title,
	}
end

local function makeBankSelector()
	if #Bankir.Data.bankBagNames == 1 then
		return nil end
	
	return {
		type = "dropdown",
		name = GetString(BANKIR_MENU_BANK_SELECT),
		tooltip = GetString(BANKIR_MENU_BANK_SELECT_DESC),
		width = "full",
		choices = Bankir.Data.bankBagNames,
		getFunc = function()
			return Bankir.Data.bankBagNames[Bankir.Menu.selectedBankIndex]
		end,
		setFunc = function(selectedChoice)
			for index, name in ipairs(Bankir.Data.bankBagNames) do
				if name == selectedChoice then
					Bankir.Menu.selectedBankIndex = index
					Bankir.Menu.selectedBankId = Bankir.Data.bankBagIds[index]
					break
				end
			end
		end,
	}
end

local function makeCurrencyTab(currencyTypes)
	local controls = {}
	for i, currencyType in ipairs(currencyTypes) do
		--pre-declare so the functions of these two know about each other
		local checkbox1, checkbox2, slider
		checkbox1 = {
			type = "checkbox",
			name = zo_strformat(GetString(BANKIR_MENU_CURRENCY_DEPOSIT), GetCurrencyName(currencyType),
				ZO_Currency_GetPlatformFormattedCurrencyIcon(currencyType)),
			tooltip = GetString(BANKIR_MENU_CURRENCY_DEPOSIT_DESC),
			width = "full",
			getFunc = function()
				if Bankir.savedVars.rules[Bankir.Menu.selectedBankId].currency then
					return Bankir.savedVars.rules[Bankir.Menu.selectedBankId].currency[currencyType].push
				else
					return false
				end
			end,
			setFunc = function(value)
				Bankir.savedVars.rules[Bankir.Menu.selectedBankId].currency[currencyType].push = value
			end,
			disabled = function()
				if not Bankir.savedVars.rules[Bankir.Menu.selectedBankId].currency then
					return true
				elseif Bankir.Menu.selectedBankId ~= BAG_BANK and currencyType ~= CURT_MONEY then
					return true
				end
			end,
		}
		checkbox2 = {
			type = "checkbox",
			name = zo_strformat(GetString(BANKIR_MENU_CURRENCY_WITHDRAW), GetCurrencyName(currencyType),
				ZO_Currency_GetPlatformFormattedCurrencyIcon(currencyType)),
			tooltip = GetString(BANKIR_MENU_CURRENCY_WITHDRAW_DESC),
			width = "full",
			getFunc = function()
				if Bankir.savedVars.rules[Bankir.Menu.selectedBankId].currency then
					return Bankir.savedVars.rules[Bankir.Menu.selectedBankId].currency[currencyType].pull
				else
					return false
				end
			end,
			setFunc = function(value)
				Bankir.savedVars.rules[Bankir.Menu.selectedBankId].currency[currencyType].pull = value
			end,
			disabled = function()
				if not Bankir.savedVars.rules[Bankir.Menu.selectedBankId].currency then
					return true
				elseif Bankir.Menu.selectedBankId ~= BAG_BANK and currencyType ~= CURT_MONEY then
					return true
				end
			end,
		}
		slider = {
			type = "slider",
			name = GetString(BANKIR_MENU_CURRENCY_AMOUNT),
			tooltip = GetString(BANKIR_MENU_CURRENCY_AMOUNT_DESC),
			min = 0,
			max = 100000,
			step = 500,
			width = "full",
			getFunc = function()
				if Bankir.savedVars.rules[Bankir.Menu.selectedBankId].currency then
					return Bankir.savedVars.rules[Bankir.Menu.selectedBankId].currency[currencyType].amount
				else
					return 0
				end
			end,
			setFunc = function(value)
				Bankir.savedVars.rules[Bankir.Menu.selectedBankId].currency[currencyType].amount = value
			end,
			disabled = function()
				if not Bankir.savedVars.rules[Bankir.Menu.selectedBankId].currency then
					return true
				elseif Bankir.Menu.selectedBankId ~= BAG_BANK and currencyType ~= CURT_MONEY then
					return true
				elseif not Bankir.savedVars.rules[Bankir.Menu.selectedBankId].currency[currencyType].push
				and not Bankir.savedVars.rules[Bankir.Menu.selectedBankId].currency[currencyType].pull then
					return true
				end
			end,
		}
		table.insert(controls, checkbox1)
		table.insert(controls, checkbox2)
		table.insert(controls, slider)
		table.insert(controls, divider)
	end
	return controls
end

local function makeQualityDropdown(id, idTypeStr, modeDropdown)
	return {
		type = "dropdown",
		name = GetString(BANKIR_MENU_QUALITY_SELECT),
		tooltip = GetString(BANKIR_MENU_QUALITY_SELECT_DESC),
		width = "full",
		choices = qualityChoices,
		getFunc = function()
			local ruleList = getSavedVarForIdType(idTypeStr)
			local neededQuality = 1
			if ruleList[id] then
				neededQuality = ruleList[id].quality or 1
			end
			if neededQuality == 0 then neededQuality = 1 end
			return qualityChoices[neededQuality]
		end,
		setFunc = function(selectedChoice)
			for i = 1, #qualityChoices do
				if qualityChoices[i] == selectedChoice then
					setQuality(i, id, idTypeStr)
				end
			end
		end,
	}
end

local function makeProfilesSubmenu()
	local controls = {
		{
			type = "dropdown",
			name = GetString(BANKIR_MENU_PROFILE_SELECT),
			tooltip = GetString(BANKIR_MENU_PROFILE_SELECT_DESC),
			width = "full",
			reference = "BankirMenuProfilesDropdown",
			choices = Bankir.Profiles.getProfilesNames(),
			getFunc = function() return Bankir.savedVarsCharacter.profile end,
			setFunc = function(selectedChoice)
				Bankir.Profiles.setCurrentProfile(selectedChoice)
			end,
		},
		{
			type = "editbox",
			name = GetString(BANKIR_MENU_PROFILE_EDIT_NAME),
			width = "full",
			getFunc = function() return Bankir.savedVarsCharacter.profile end,
			setFunc = function(text)
				Bankir.Profiles.updateCurrentProfileName(Bankir.savedVarsCharacter.profile, text)
				_G["BankirMenuProfilesDropdown"]:UpdateChoices(Bankir.Profiles.getProfilesNames())
			end,
			isMultiline = false,
		},
		{
			type = "button",
			name = GetString(BANKIR_MENU_PROFILE_NEW),
			func = function()
				Bankir.Profiles.createNewProfile("New profile")
				_G["BankirMenuProfilesDropdown"]:UpdateChoices(Bankir.Profiles.getProfilesNames())
			end,
			width = "full",
		},
		{
			type = "button",
			name = GetString(BANKIR_MENU_PROFILE_COPY),
			tooltip = GetString(BANKIR_MENU_PROFILE_COPY_DESC),
			func = function()
				Bankir.Profiles.copyCurrentProfile()
				_G["BankirMenuProfilesDropdown"]:UpdateChoices(Bankir.Profiles.getProfilesNames())
			end,
			width = "full",
		},
		{
			type = "button",
			name = GetString(BANKIR_MENU_PROFILE_DELETE),
			func = function()
				Bankir.Profiles.deleteCurrentProfile()
				_G["BankirMenuProfilesDropdown"]:UpdateChoices(Bankir.Profiles.getProfilesNames())
			end,
			width = "full",
			isDangerous = true,
			warning = GetString(BANKIR_MENU_PROFILE_DELETE_WARNING),
			disabled = function() return #Bankir.Profiles.getProfilesNames() == 1 end,
		},
	}
	return {
		type = "submenu",
		name = GetString(BANKIR_MENU_PROFILES),
		controls = controls,
	}
end

local function makeDropdownAndSlider(id, idTypeStr)
	-- pre-declare so the functions of these two know about each other
	local dropdown, label, sliderPush, sliderPull
	
	-- prepare name for dropdown
	local name = Bankir.Functions.getNameOfType(id, idTypeStr)
	name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name) -- make first char uppercase
	if getTypeChildrenLists(id, idTypeStr) then
		name = name .. " - " .. GetString(SI_INVENTORY_WALLET_ALL_FILTER) -- "Name of type - All"
	end
	
	label = {
		type = "description",
		title = name,
		width = "full",
	}
	dropdown = {
		type = "dropdown",
		name = name,
		tooltip = name,
		width = "full",
		choices = actionChoices,
		getFunc = function()
			local ruleList = getSavedVarForIdType(idTypeStr)
			if ruleList[id] then
				return actionChoices[2]
			else return actionChoices[1] end
		end,
		setFunc = function(selectedChoice)
			local stacksPush, stacksPull = getStacks(id, idTypeStr, selectedChoice)
			setStacks(stacksPush, "push", id, idTypeStr, selectedChoice)
		end,
	}
	sliderPush = {
		type = "slider",
		name = GetString(BANKIR_MENU_MAX_STACKS_TO_PUSH),
		tooltip = GetString(BANKIR_MENU_MAX_STACKS_DESC),
		min = 0,
		max = 200,
		step = 1,
		width = "full",
		getFunc = function()
			return select(1, getStacks(id, idTypeStr))
		end,
		setFunc = function(value)
			setStacks(value, "push", id, idTypeStr)
		end,
	}
	sliderPull = {
		type = "slider",
		name = GetString(BANKIR_MENU_MIN_ITEMS_TO_PULL),
		tooltip = GetString(BANKIR_MENU_MIN_ITEMS_DESC),
		min = 0,
		max = 100,
		step = 1,
		width = "full",
		getFunc = function()
			return select(2, getStacks(id, idTypeStr))
		end,
		setFunc = function(value)
			setStacks(value, "pull", id, idTypeStr)
		end,
	}
	return dropdown, label, sliderPush, sliderPull
end

local function makeWidgetsForTypes(idTypeStr, ids)
	local controls = {}
	for i, id in ipairs(ids) do
		local dropdown, label, sliderPush, sliderPull = makeDropdownAndSlider(id, idTypeStr)
		--table.insert(controls, dropdown)
		table.insert(controls, label)
		table.insert(controls, sliderPush)
		table.insert(controls, sliderPull)
		local isQualityRuled = false
		if idTypeStr == "itemType" then
			for i = 1, #Bankir.Data.qualityRuledItemTypes do
				if Bankir.Data.qualityRuledItemTypes[i] == id then
					isQualityRuled = true
					local qualityDropdown = makeQualityDropdown(id, idTypeStr, dropdown)
					table.insert(controls, qualityDropdown)
				end
			end
		end
		local childrenLists = getTypeChildrenLists(id, idTypeStr)
		if childrenLists then
			for _, list in ipairs(childrenLists) do
				table.insert(controls, dividerInvisible)
				for i, childId in ipairs(list.list) do
					local dropdown, label, sliderPush, sliderPull = makeDropdownAndSlider(childId, list.idTypeStr)
					table.insert(controls, dividerSmall)
					--table.insert(controls, dropdown)
					table.insert(controls, label)
					table.insert(controls, sliderPush)
					table.insert(controls, sliderPull)
					if isQualityRuled then
						local qualityDropdown = makeQualityDropdown(childId, list.idTypeStr, dropdown)
						table.insert(controls, qualityDropdown)
					end
				end
			end
		end
		table.insert(controls, dividerInvisible)
		table.insert(controls, divider)
	end
	return controls
end

Bankir.MenuBuildFunctions = {
	divider = divider,
	makeHeader = makeHeader,
	makeProfilesSubmenu = makeProfilesSubmenu,
	makeBankSelector = makeBankSelector,
	makeCurrencyTab = makeCurrencyTab,
	makeWidgetsForTypes = makeWidgetsForTypes,
}
