Bankir = Bankir or {}

local function onTabButtonClick(button, v1, alt)
	local tabIndex = button.tabIndex
	local panel = button.parentPanel
	
	for x = 1, #panel.vTabs.buttons do
		if x == tabIndex then
			panel.vTabs.buttons[x]:SetState(1, true)
		else
			panel.vTabs.buttons[x]:SetState(0)
		end
	end
	
	for id, p in pairs(panel.vTabs.panels) do
		p:SetHidden(id ~= tabIndex)
	end
	
	if not panel.vTabs.panels[tabIndex].vTabs.created then
		Bankir.createWidgets(panel.vTabs.panels[tabIndex])
	end
end

local function onTabButtonMouseEnter(button)
	if button.title then
		ZO_Tooltips_ShowTextTooltip(button, TOP, button.title)
	end
end

local function onTabButtonMouseExit()
	ZO_Tooltips_HideTextTooltip()
end

function Bankir.createTabs(panel, buttonType, tabsData)
	-- use existing table in case this panel is a tab panel itself
	panel.vTabs = panel.vTabs or {}
	
	if panel.vTabs.buttons or panel.vTabs.panels or panel.vTabs.widgets then
		d("Uhm... " .. panel.vTabs.name .. " already has widgets but you tried to create tabs with " .. tabsData[1].title)
		return
	end
	
	local panelWidth = panel:GetWidth()
	local buttonWidth, buttonsInLine
	if buttonType == "text" then
		buttonsInLine = math.min(#tabsData, 3) -- 3 or less
		buttonWidth = panelWidth / buttonsInLine
	elseif buttonType == "icon" then
		buttonsInLine = math.floor(panelWidth / 38)
		buttonWidth = 38
	end
	
	local buttonsHeight = math.ceil(#tabsData / buttonsInLine) * 38
	if panel.vTabs.header then
		buttonsHeight = buttonsHeight + 50 -- +header height (roughly)
	end
	
	panel.vTabs.buttonsHeight = buttonsHeight
	panel.vTabs.buttons = {}
	panel.vTabs.panels = {}
	
	local WM = GetWindowManager()
	local btn, btnName, pnl, hOffset, vOffset, tabHeader, tabHeaderDivider
	-- prepare name prefix for buttons and tab panels
	local panelName = ""
	if panel.vTabs.name then
		panelName = panel.vTabs.name
	else
		panelName = "BankirTab"
	end
	
	for i = 1, #tabsData do
		btnName = string.format("%s_%s_Button", panelName, i)
		btn = WM:CreateControlFromVirtual(btnName, panel, "ZO_DefaultButton")
		if buttonType == "text" then
			btn:SetText(tabsData[i].title)
		elseif buttonType == "icon" then
			btn.title = tabsData[i].title
			btn:SetNormalTexture(tabsData[i].iconNormal)
			btn:SetPressedTexture(tabsData[i].iconPressed)
		end
		
		btn.tabIndex = i
		if i == 1 then
			btn:SetState(1, true)
		end
		btn.parentPanel = panel
		btn:SetWidth(buttonWidth)
		hOffset = (buttonWidth) * ((i - 1) % buttonsInLine)
		vOffset = math.floor((i - 1) / buttonsInLine) * 34
		if panel.vTabs.header then
			vOffset = vOffset + 50 -- +header height (roughly)
		end
		btn:SetAnchor(TOPLEFT, panel, TOPLEFT, hOffset, vOffset)

		btn:SetHandler("OnClicked", onTabButtonClick)
		btn:SetHandler("OnMouseEnter", onTabButtonMouseEnter)
		btn:SetHandler("OnMouseExit", onTabButtonMouseExit)
		
		panel.vTabs.buttons[i] = btn

		pnl = WM:CreateControl(nil, panel, CT_CONTROL)
		pnl.panel = panel
		pnl:SetWidth(panelWidth)
		pnl:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, panel.vTabs.buttonsHeight)
		pnl.vTabs = {}
		pnl.vTabs.widgets = tabsData[i].widgets
		
		tabHeader = LAMCreateControl.header(pnl, {
			type = 'header',
			name = tabsData[i].title,
		})
		tabHeader:SetAnchor(TOPLEFT, pnl, TOPLEFT, 0, 0)
		tabHeader.panel = pnl
		
		tabHeaderDivider = LAMCreateControl.divider(pnl, {
			type = 'divider',
			height = 20,
		})
		tabHeaderDivider:SetAnchor(TOPLEFT, tabHeader, BOTTOMLEFT, 0, 0)
		tabHeaderDivider.panel = pnl
		
		pnl.vTabs.header = tabHeaderDivider -- as starting point for widgets
		
		pnl.vTabs.name = string.format("%s_%s_Panel", panelName, i)
		
		if i ~= 1 then
			pnl:SetHidden(true)
		end
		
		panel.vTabs.panels[i] = pnl
	end
	
	return panel.vTabs
end

function Bankir.createWidgets(panel)
	local lastAddedControl = panel.vTabs.header
	
	if panel.vTabs.widgets then
		for entry, widgetData in ipairs(panel.vTabs.widgets) do
			local widget = LAMCreateControl[widgetData.type](panel, widgetData)
			
			if widget:GetWidth() <= panel:GetWidth() / 2 and lastAddedControl.half then
				widget:SetAnchor(TOPLEFT, lastAddedControl, TOPRIGHT, 40, 0)
				lastAddedControl.half = false
			else
				widget:SetAnchor(TOPLEFT, lastAddedControl, BOTTOMLEFT, 0, 5)
				lastAddedControl = widget
				lastAddedControl.half = widget:GetWidth() <= panel:GetWidth() / 2
			end
		end
	end
	
	-- flag for buttons, to create on click only when needed
	panel.vTabs.created = true
	
	-- show first child panel too
	if panel.vTabs.panels then
		Bankir.createWidgets(panel.vTabs.panels[1])
	end
end

--[[
	How to use:
	
	function onPanelCreated(panel)
		if (panel ~= myAddonPanel) then return end

		local panel = _G["myCustomPanel"]
		
		local buttonType = "text" -- or "icon"
		
		local data = {
			{
				title = "Tab 1 title",
				icon = "icon1_%s.dds", -- two existing icon files: icon1_up.dds, icon1_down.dds
				widgets = -- array of LAM widgets for tab 1
			},
			... same for tab2, tab3, etc.
		}
		
		local panelTabsData = BankirTabs.createTabs(panel, buttonType, data)
		-- panelTabsData has:
			.name -- name of tab panel
			.buttons -- tabs switch buttons array
			.panels -- tabs panels array
		
		-- trigger the widgets creation
		BankirTabs.createWidgets(panel)
	end
	
	local optionsData = {
		{
			type = "custom",
			reference = "myCustomPanel",
		},
	}
	
	LAM:RegisterOptionControls(addonPanelGlobalRef, optionsData)
	
	CALLBACK_MANAGER:RegisterCallback('LAM-PanelControlsCreated', onPanelCreated)
]]--
