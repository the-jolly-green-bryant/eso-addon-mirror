NewDialogOrderMenu = NewDialogOrderMenu or {}

function NewDialogOrderMenu.CreateSettingsMenu(numPriorities)
	local LAM = LibAddonMenu2
	local labels = {}
	
	--Register the Options panel with LAM
	local panelData =
	{
		type = "panel",
		name = NewDialogOrder.name,
		version = NewDialogOrder.version,
		author = NewDialogOrder.author,
		registerForRefresh = true,
	}
	local addonPanel = LAM:RegisterAddonPanel("NewDialogOrder_Settings", panelData)
	
	local numUnmanaged = 0
	for key, val in pairs(NewDialogOrder.savedVars.ignore) do
		numUnmanaged = numUnmanaged + 1
	end
	
	local choices = { GetString(NEW_DIALOG_ORDER_UNMANAGED) }
	for i = 1, numPriorities do
		choices[i + 1] = i
	end
	
	local function getKeyByValue(data, value)
		for key, val in pairs(data) do
			if val == value then return key end
		end
	end
	
	local function getStringForChatterOptionType(optionType)
		--use official localization constants
		if optionType == CHATTER_START_SHOP then
			return GetString(SI_INTERACT_OPTION_STORE)
		elseif optionType == CHATTER_START_BANK then
			return GetString(SI_INTERACT_OPTION_BANK)
		elseif optionType == CHATTER_START_GUILDBANK then
			return GetString(SI_INTERACT_OPTION_GUILDBANK)
		elseif optionType == CHATTER_START_TRADINGHOUSE then
			return GetString(SI_INTERACT_OPTION_TRADING_HOUSE)
		elseif optionType == CHATTER_START_BUY_BAG_SPACE then
			return GetString(SI_INTERACT_OPTION_BUY_BAG_SPACE)
		elseif optionType == CHATTER_START_STABLE then
			return GetString(SI_INTERACT_OPTION_STABLE)
		else
			--try to find a string like NEW_DIALOG_ORDER_600 for optionType 600 in the /lang files
			return GetString("NEW_DIALOG_ORDER_", optionType)
		end
	end
	
	local function getOptionIndexName(index)
		local key = getKeyByValue(NewDialogOrder.savedVars.priorities, index)
		if NewDialogOrder.savedVars.ignore[key] then
			return "--. " .. getStringForChatterOptionType(key)
		else
			return index .. ". " .. getStringForChatterOptionType(key)
		end
	end
	
	local function swap(index1, index2)
		if index1 == index2 then return end
		
		local key1, val1, key2, val2
		for key, val in pairs(NewDialogOrder.savedVars.priorities) do
			if val == index1 then
				key1 = key
				val1 = val
			elseif val == index2 then
				key2 = key
				val2 = val
			end
		end
		NewDialogOrder.savedVars.priorities[key1] = val2
		NewDialogOrder.savedVars.priorities[key2] = val1
	end
	
	local function arrayMove(index1, index2)
		if index1 == index2 then return end
		
		local diff = index2 - index1
		local step = diff > 0 and 1 or -1
		
		for i = 0, diff - step, step do
			swap(index1 + i, index1 + i + step)
		end
	end
	
	local function updateBtns()
		for i = 1, numPriorities do
			labels[i]:SetText(getOptionIndexName(i))
		end
	end
	
	local function makeSubMenuForPriorities()
		controls = {}
		table.insert(controls, {
			type = "description",
			text = GetString(NEW_DIALOG_ORDER_MANAGE_DESC),
		})
		table.insert(controls, {
			type = "custom",
			reference = "NewDialogOrderCustomPanel",
		})
		return {
			type = "submenu",
			name = GetString(NEW_DIALOG_ORDER_PRIORITY_ORDER),
			controls = controls,
			disabled = function() return NewDialogOrder.savedVars.customize == false end,
		}
	end
	
	local function onPanelCreated(panel)
		if (panel ~= addonPanel) then return end -- only proceed if this is our settings panel

		local mainPanel = _G["NewDialogOrderCustomPanel"]
		local panelWidth = addonPanel:GetWidth()
		mainPanel:SetWidth(panelWidth)
		
		local vOffset = 0
		local label, labelName, dropdown, divider
		
		for i = 1, numPriorities do
			labelName = string.format("NewDialogOrder_Button_%d", i)
			label = WINDOW_MANAGER:CreateControl(btnName, mainPanel, CT_LABEL)
			label:SetWidth(panelWidth / 2)
			label:SetFont("ZoFontWinH4")
			label:SetText(getOptionIndexName(i))
			if i == 1 then
				label:SetAnchor(TOPLEFT, mainPanel, TOPLEFT, 0, 20)
			else
				label:SetAnchor(TOPLEFT, divider, BOTTOMLEFT, 0, 10)
			end
			table.insert(labels, label)
			
			dropdown = LAMCreateControl.dropdown(mainPanel, {
				type = "dropdown",
				name = "",
				tooltip = "",
				width = "full",
				choices = choices,
				getFunc = function()
					if i <= numPriorities - numUnmanaged then
						return i
					else
						return GetString(NEW_DIALOG_ORDER_UNMANAGED)
					end
				end,
				setFunc = function(selectedChoice)
					local key = getKeyByValue(NewDialogOrder.savedVars.priorities, i)
					if selectedChoice == GetString(NEW_DIALOG_ORDER_UNMANAGED) then
						if i <= numPriorities - numUnmanaged then
							NewDialogOrder.savedVars.ignore[key] = true
							arrayMove(i, numPriorities - numUnmanaged)
							numUnmanaged = numUnmanaged + 1
							updateBtns()
							panel:RefreshPanel()
						end
					else
						if i > numPriorities - numUnmanaged then
							NewDialogOrder.savedVars.ignore[key] = nil
							numUnmanaged = numUnmanaged - 1
						end
						selectedChoice = tonumber(selectedChoice)
						if selectedChoice > numPriorities - numUnmanaged then
							selectedChoice = numPriorities - numUnmanaged
						end
						arrayMove(i, selectedChoice)
						updateBtns()
						panel:RefreshPanel()
					end
				end,
			})
			dropdown:SetAnchor(TOPLEFT, label, TOPLEFT, 0, 0)
			dropdown.panel = mainPanel

			divider = LAMCreateControl.divider(mainPanel, {
				type = "divider",
				width = "full",
				height = 10,
				alpha = 0.5,
			})
			divider:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, 0)
		end
		
		updateBtns()
	end
	
	--Set the actual panel data
	local optionsData = {
		{
			type = "checkbox",
			name = GetString(NEW_DIALOG_ORDER_USE_ACCOUNTWIDE),
			getFunc = function() return NewDialogOrderSavedVariables.Default[GetDisplayName()]['$AccountWide'].useAccountWide end,
			setFunc = function(value)
				NewDialogOrderSavedVariables.Default[GetDisplayName()]['$AccountWide'].useAccountWide = value
			end,
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = GetString(NEW_DIALOG_ORDER_UNREAD_TO_FRONT),
			tooltip = GetString(NEW_DIALOG_ORDER_UNREAD_TO_FRONT_DESC),
			getFunc = function() return NewDialogOrder.savedVars.unreadToFront end,
			setFunc = function(value)
				NewDialogOrder.savedVars.unreadToFront = value
			end,
		},
		{
			type = "checkbox",
			name = GetString(NEW_DIALOG_ORDER_KEEP_CONVERSATION),
			tooltip = GetString(NEW_DIALOG_ORDER_KEEP_CONVERSATION_DESC),
			getFunc = function() return NewDialogOrder.savedVars.keepConversation end,
			setFunc = function(value)
				NewDialogOrder.savedVars.keepConversation = value
			end,
		},
		{
			type = "checkbox",
			name = GetString(NEW_DIALOG_ORDER_CUSTOMIZE),
			tooltip = GetString(NEW_DIALOG_ORDER_CUSTOMIZE_DESC),
			getFunc = function() return NewDialogOrder.savedVars.customize end,
			setFunc = function(value)
				NewDialogOrder.savedVars.customize = value
			end,
		},
		makeSubMenuForPriorities(),
	}
	
	LAM:RegisterOptionControls("NewDialogOrder_Settings", optionsData)
	
	CALLBACK_MANAGER:RegisterCallback('LAM-PanelControlsCreated', onPanelCreated)
end
