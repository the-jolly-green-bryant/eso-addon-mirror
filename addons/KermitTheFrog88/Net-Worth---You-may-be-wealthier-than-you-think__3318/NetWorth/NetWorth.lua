local LAM2 = LibAddonMenu2
local hudtrackerpostinit = false
local HUDHidden = true
NetWorth = {}
NetWorth.name = "NetWorth" 
NetWorth.variableVersion = 1
NetWorth.version = "0.11"
NetWorth.savedVariables = 0
NetWorth.GroupList = {}
NetWorth.Default = {
	  OffsetX = 40,
	  OffsetY = 200,
	  HideInCombat = true,
	  Width = 500,
	  Height = 500,
	  PricingData = "Avg",
 }

function NetWorth.OnAddOnLoaded(event, addonName)
	if addonName ~= NetWorth.name then return end
	CHAT_SYSTEM:AddMessage("Start AddOnLoaded")
	NetWorth:Initialize()
end

function NetWorth:Initialize()

	NetWorth.CreateSettingsWindow()
	NetWorth.savedVariables = ZO_SavedVars:NewAccountWide("NetWorthVars", NetWorth.variableVersion, nil, NetWorth.Default, GetWorldName())

	NetWorthMain:ClearAnchors()
	NetWorthMain:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, NetWorth.savedVariables.OffsetX, NetWorth.savedVariables.OffsetY)

	NetWorthMain:SetHidden(true)
	NetWorthInfoWindow:SetHidden(true)

	NetWorth.inCombat = IsUnitInCombat("player")
	EVENT_MANAGER:RegisterForEvent(NetWorth.name, EVENT_PLAYER_COMBAT_STATE, NetWorth.OnPlayerCombatState)

	NetWorth.fragment1 = ZO_SimpleSceneFragment:New(NetWorthMain)
	NetWorth.fragment2 = ZO_SimpleSceneFragment:New(NetWorthInfoWindow)

	SLASH_COMMANDS["/networth"] = NetWorth.SlashCommands

	grandtotalLabel = WINDOW_MANAGER:CreateControl("NetWorthMainGrandTotalLabel", NetWorthMain, CT_LABEL)
	grandtotalLabel:SetFont("ZoFontAnnounceLarge")
	grandtotalLabel:SetAnchor(TOP, NetWorthMainTopDivider, BOTTOM, 0, 10)

	craftbagtotalLabel = WINDOW_MANAGER:CreateControl("NetWorthMainCraftTotalLabel", NetWorthMain, CT_LABEL)
	craftbagtotalLabel:SetFont("ZoFontAnnounceMedium")
	craftbagtotalLabel:SetAnchor(TOPLEFT, NetWorthMainGrandTotalLabel, BOTTOMLEFT, 0, 15)

	backpacktotalLabel = WINDOW_MANAGER:CreateControl("NetWorthMainBackPackTotalLabel", NetWorthMain, CT_LABEL)
	backpacktotalLabel:SetFont("ZoFontAnnounceMedium")
	backpacktotalLabel:SetAnchor(TOPLEFT, NetWorthMainCraftTotalLabel, BOTTOMLEFT, 0, 0)
	
	banktotalLabel = WINDOW_MANAGER:CreateControl("NetWorthMainBankTotalLabel", NetWorthMain, CT_LABEL)
	banktotalLabel:SetFont("ZoFontAnnounceMedium")
	banktotalLabel:SetAnchor(TOPLEFT, NetWorthMainBackPackTotalLabel, BOTTOMLEFT, 0, 0)
	
	equippeditemtotalLabel = WINDOW_MANAGER:CreateControl("NetWorthMainEquippedTotalLabel", NetWorthMain, CT_LABEL)
	equippeditemtotalLabel:SetFont("ZoFontAnnounceMedium")
	equippeditemtotalLabel:SetAnchor(TOPLEFT, NetWorthMainBankTotalLabel, BOTTOMLEFT, 0, 0)
	
	storagetotalLabel = WINDOW_MANAGER:CreateControl("NetWorthMainStorageTotalLabel", NetWorthMain, CT_LABEL)
	storagetotalLabel:SetFont("ZoFontAnnounceMedium")
	storagetotalLabel:SetAnchor(TOPLEFT, NetWorthMainEquippedTotalLabel, BOTTOMLEFT, 0, 0)
	
	bankedgoldtotalLabel = WINDOW_MANAGER:CreateControl("NetWorthMainBankedGoldTotalLabel", NetWorthMain, CT_LABEL)
	bankedgoldtotalLabel:SetFont("ZoFontAnnounceMedium")
	bankedgoldtotalLabel:SetAnchor(TOPLEFT, NetWorthMainStorageTotalLabel, BOTTOMLEFT, 0, 0)
	
	pocketchangetotalLabel = WINDOW_MANAGER:CreateControl("NetWorthMainPocketChangeTotalLabel", NetWorthMain, CT_LABEL)
	pocketchangetotalLabel:SetFont("ZoFontAnnounceMedium")
	pocketchangetotalLabel:SetAnchor(TOPLEFT, NetWorthMainBankedGoldTotalLabel, BOTTOMLEFT, 0, 0)
	
    currenthousetotalLabel = WINDOW_MANAGER:CreateControl("NetWorthMainCurrentHouseTotalLabel", NetWorthMain, CT_LABEL)
	currenthousetotalLabel:SetFont("ZoFontAnnounceMedium")
	currenthousetotalLabel:SetAnchor(TOPLEFT, NetWorthMainPocketChangeTotalLabel, BOTTOMLEFT, 0, 0)
	
	pricingdataLabel = WINDOW_MANAGER:CreateControl("NetWorthMainPricingLabel", NetWorthMain, CT_LABEL)
	pricingdataLabel:SetAnchor(TOPLEFT, NetWorthMainCurrentHouseTotalLabel, BOTTOMLEFT, 0, 50)
	pricingdataLabel:SetFont("ZoFontAnnounceMedium")
	
	infowindowButton = WINDOW_MANAGER:CreateControl("NetWorthInfoWindowButton", NetWorthMain, CT_BUTTON)
	infowindowButton:SetAnchor(BOTTOMRIGHT, NetWorthMain, BOTTOMRIGHT, 0, 0)
	infowindowButton:SetFont("ZoFontAnnounceMedium")
	infowindowButton:SetNormalTexture("esoui/art/buttons/info_up.dds")
	infowindowButton:SetPressedTexture("esoui/art/buttons/info_down.dds")
	infowindowButton:SetMouseOverTexture("esoui/art/buttons/info_over.dds")
		infowindowButton:SetHandler("OnMouseDown", 
		function(self) 
			HUD_SCENE:AddFragment(NetWorth.fragment2)
			HUD_UI_SCENE:AddFragment(NetWorth.fragment2)
			NetWorthInfoWindow:SetHidden(false) 
		end, 
	"NetWorthInfoWindowButton")
	infowindowButton:SetDimensions(50, 50)
	
	settingswindowButton = WINDOW_MANAGER:CreateControl("NetWorthSettingWindowButton", NetWorthMain, CT_BUTTON)
	settingswindowButton:SetAnchor(BOTTOMLEFT, NetWorthMain, BOTTOMLEFT, 0, 0)
	settingswindowButton:SetFont("ZoFontAnnounceMedium")
	settingswindowButton:SetNormalTexture("esoui/art/skillsadvisor/advisor_tabicon_settings_up.dds")
	settingswindowButton:SetPressedTexture("esoui/art/skillsadvisor/advisor_tabicon_settings_down.dds")
	settingswindowButton:SetMouseOverTexture("esoui/art/skillsadvisor/advisor_tabicon_settings_over.dds")
		settingswindowButton:SetHandler("OnMouseDown", 
		function(self) 
			LAM2:OpenToPanel(NetWorth.cntrlOptionsPanel)
		end, 
	"NetWorthInfoWindowButton")
	settingswindowButton:SetDimensions(50, 50)
	
	snarkLabel = WINDOW_MANAGER:CreateControl("NetWorthMainSnarkLabel", NetWorthMain, CT_LABEL)
	snarkLabel:SetAnchor(BOTTOM, NetWorthMain, BOTTOM, 0, 0)
	snarkLabel:SetFont("ZoFontAnnounceMedium")
	
	EVENT_MANAGER:UnregisterForEvent(NetWorth.name, EVENT_ADD_ON_LOADED)

end

function NetWorth.CalculateAndDisplayNetWorth()


	local craftbagTotal = NetWorth.GetCraftBagTotal()
	local backpackTotal = NetWorth.GetBackPackTotal()
	local bankTotal = NetWorth.GetBankTotal()
	local esoplusbankTotal = NetWorth.GetEsoPlusBankTotal()
	local bagwornTotal = NetWorth.GetWornTotal()
	local currMoney = GetBankedCurrencyAmount(CURT_MONEY)
	local pocketChange = GetCarriedCurrencyAmount(CURT_MONEY)
	local storageTotal = NetWorth.GetStorageTotal()
	local currHouseTotal = NetWorth.GetHouseInventoryTotal()
	
	local bankGrandTotal = bankTotal + esoplusbankTotal
 	
	local grandTotal = craftbagTotal + backpackTotal + bankTotal + esoplusbankTotal + bagwornTotal + currMoney + storageTotal + pocketChange + currHouseTotal
	

	grandtotalLabel:SetText("|cf7e705Grand Total = "..ZO_CommaDelimitNumber(grandTotal).."|r |t32:32:esoui/art/loot/icon_goldcoin_pressed.dds|t")
	
	craftbagtotalLabel:SetText("Craft Bag Items = "..ZO_CommaDelimitNumber(craftbagTotal).." |t24:24:esoui/art/loot/icon_goldcoin_pressed.dds|t")
	
	backpacktotalLabel:SetText("Backpack Items = "..ZO_CommaDelimitNumber(backpackTotal).." |t24:24:esoui/art/loot/icon_goldcoin_pressed.dds|t")
	
	banktotalLabel:SetText("Bank Items = "..ZO_CommaDelimitNumber(bankGrandTotal).." |t24:24:esoui/art/loot/icon_goldcoin_pressed.dds|t")
	
	equippeditemtotalLabel:SetText("Equipped Items = "..ZO_CommaDelimitNumber(bagwornTotal).." |t24:24:esoui/art/loot/icon_goldcoin_pressed.dds|t")
	
	storagetotalLabel:SetText("Storage Items = "..ZO_CommaDelimitNumber(storageTotal).." |t24:24:esoui/art/loot/icon_goldcoin_pressed.dds|t")
	
	pocketchangetotalLabel:SetText("Pocket Change = "..ZO_CommaDelimitNumber(pocketChange).." |t24:24:esoui/art/loot/icon_goldcoin_pressed.dds|t")
	
	bankedgoldtotalLabel:SetText("Total Banked Gold = "..ZO_CommaDelimitNumber(currMoney).." |t24:24:esoui/art/loot/icon_goldcoin_pressed.dds|t")
	
	currenthousetotalLabel:SetText("House Furniture Total = "..ZO_CommaDelimitNumber(currHouseTotal).." |t24:24:esoui/art/loot/icon_goldcoin_pressed.dds|t")
	
	
	local ttcPricingData = ""
	
	if NetWorth.savedVariables.PricingData == "Avg" then
		ttcPricingData = "TTC Average Price"
	elseif NetWorth.savedVariables.PricingData == "Max" then
		ttcPricingData = "TTC Maximum Price"
	else
		ttcPricingData = "TTC Minimum Price"
	end
	
	pricingdataLabel:SetText("Pricing Data: "..ttcPricingData)

	if ( grandTotal >= 1000000 ) then
		snarkLabel:SetText("|cfc0317Thats a lot of gold!|r")
	elseif ( grandTotal >= 250000 ) then
		snarkLabel:SetText("|cfc0317Not bad, its a start.|r")
	else
		snarkLabel:SetText("|cfc0317Well, it could be worse.|r")
	end

	
	d("Net Worth = "..ZO_CommaDelimitNumber(grandTotal))
	
-- BAG_BACKPACK 1
-- BAG_BANK 2
-- BAG_BUYBACK 4
-- BAG_DELETE 17
-- BAG_GUILDBANK 3
-- BAG_HOUSE_BANK_EIGHT 14
-- BAG_HOUSE_BANK_FIVE 11
-- BAG_HOUSE_BANK_FOUR 10
-- BAG_HOUSE_BANK_NINE 15
-- BAG_HOUSE_BANK_ONE 7
-- BAG_HOUSE_BANK_SEVEN 13
-- BAG_HOUSE_BANK_SIX 12
-- BAG_HOUSE_BANK_TEN 16
-- BAG_HOUSE_BANK_THREE 9
-- BAG_HOUSE_BANK_TWO 8
-- BAG_SUBSCRIBER_BANK 6
-- BAG_VIRTUAL 5
-- BAG_WORN 0


end

function NetWorth.GetStorageTotal()

	local bags = {
				BAG_HOUSE_BANK_ONE,
				BAG_HOUSE_BANK_TWO,
				BAG_HOUSE_BANK_THREE,
				BAG_HOUSE_BANK_FOUR,
				BAG_HOUSE_BANK_FIVE,
				BAG_HOUSE_BANK_SIX,
				BAG_HOUSE_BANK_SEVEN,
				BAG_HOUSE_BANK_EIGHT,
				BAG_HOUSE_BANK_NINE,
				BAG_HOUSE_BANK_TEN
				}
				
	local bagTotal = 0
	
	for k,bag in pairs(bags) do
		if bag ~= nil and k ~= nil then
			for index, data in pairs(SHARED_INVENTORY:GetOrCreateBagCache(bag))do 
				if data ~= nil then
					local itemLink = GetItemLink(bag,data.slotIndex)
					local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
					local name = GetItemName(bag, data.slotIndex)
					local icon, stack, sellPrice, meetsUsageRequirment, locked, equipType, itemStyleId, quality = GetItemInfo(bag, data.slotIndex)
					local stackprice = 0
					local isBound = IsItemLinkBound(itemLink)
					
					if name ~= "" then
						if priceInfo ~= nil and isBound ~= true  then 
							if NetWorth.savedVariables.PricingData == "Avg" then
								stackprice = priceInfo.Avg * stack
								bagTotal = bagTotal + stackprice
							elseif NetWorth.savedVariables.PricingData == "Max" then
								stackprice = priceInfo.Max * stack
								bagTotal = bagTotal + stackprice
							else
								stackprice = priceInfo.Min * stack
								bagTotal = bagTotal + stackprice
							end
						else
							stackprice = sellPrice * stack
							bagTotal = bagTotal + stackprice
						end
					end
					
				end	
			end
		end
	
	end
	
	return bagTotal

end

function NetWorth.GetWornTotal()

	local bag = BAG_WORN
	local bagTotal = 0
	local bagSize = GetBagSize(bag)
	
	
	for i=1,bagSize do
	 
		local itemLink = GetItemLink(bag, i)
	 	local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
		local name = GetItemName(bag, i)
		local icon, stack, sellPrice, meetsUsageRequirment, locked, equipType, itemStyleId, quality = GetItemInfo(bag, i)
		local stackprice = 0
		local isBound = IsItemLinkBound(itemLink)
		
		if name ~= "" then
			if priceInfo ~= nil and isBound ~= true then 
				if NetWorth.savedVariables.PricingData == "Avg" then
					stackprice = priceInfo.Avg * stack
					bagTotal = bagTotal + stackprice
				elseif NetWorth.savedVariables.PricingData == "Max" then
					stackprice = priceInfo.Max * stack
					bagTotal = bagTotal + stackprice
				else
					stackprice = priceInfo.Min * stack
					bagTotal = bagTotal + stackprice
				end
			else
				stackprice = sellPrice * stack
				bagTotal = bagTotal + stackprice
			end
		end
		
	end
	
	return bagTotal

end

function NetWorth.GetEsoPlusBankTotal()

	local bag = BAG_SUBSCRIBER_BANK
	local bagTotal = 0
	local bagSize = GetBagSize(bag)
	
	
	for i=1,bagSize do
	 
		local itemLink = GetItemLink(bag, i)
	 	local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
		local name = GetItemName(bag, i)
		local icon, stack, sellPrice, meetsUsageRequirment, locked, equipType, itemStyleId, quality = GetItemInfo(bag, i)
		local stackprice = 0
		local isBound = IsItemLinkBound(itemLink)
		
		if name ~= "" then
			if priceInfo ~= nil and isBound ~= true then 
				if NetWorth.savedVariables.PricingData == "Avg" then
					stackprice = priceInfo.Avg * stack
					bagTotal = bagTotal + stackprice
				elseif NetWorth.savedVariables.PricingData == "Max" then
					stackprice = priceInfo.Max * stack
					bagTotal = bagTotal + stackprice
				else
					stackprice = priceInfo.Min * stack
					bagTotal = bagTotal + stackprice
				end
			else
				stackprice = sellPrice * stack
				bagTotal = bagTotal + stackprice
			end
		end
		
	end
	
	return bagTotal

end

function NetWorth.GetBankTotal()

	local bag = BAG_BANK
	local bagTotal = 0
	local bagSize = GetBagSize(bag)
	
	
	for i=1,bagSize do
	 
		local itemLink = GetItemLink(bag, i)
	 	local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
		local name = GetItemName(bag, i)
		local icon, stack, sellPrice, meetsUsageRequirment, locked, equipType, itemStyleId, quality = GetItemInfo(bag, i)
		local stackprice = 0
		local isBound = IsItemLinkBound(itemLink)
		
		if name ~= "" then
			if priceInfo ~= nil and isBound ~= true then 
				if NetWorth.savedVariables.PricingData == "Avg" then
					stackprice = priceInfo.Avg * stack
					bagTotal = bagTotal + stackprice
				elseif NetWorth.savedVariables.PricingData == "Max" then
					stackprice = priceInfo.Max * stack
					bagTotal = bagTotal + stackprice
				else
					stackprice = priceInfo.Min * stack
					bagTotal = bagTotal + stackprice
				end
			else
				stackprice = sellPrice * stack
				bagTotal = bagTotal + stackprice
			end
		end
		
	end
	
	return bagTotal

end

function NetWorth.GetBackPackTotal()

	local bag = BAG_BACKPACK
	local bagTotal = 0
	local bagSize = GetBagSize(bag)
	
	for i=1,bagSize do
	 
		local itemLink = GetItemLink(bag, i)
	 	local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
		local name = GetItemName(bag, i)
		local icon, stack, sellPrice, meetsUsageRequirment, locked, equipType, itemStyleId, quality = GetItemInfo(bag, i)
		local stackprice = 0
		local isBound = IsItemLinkBound(itemLink)
		
		if name ~= "" then
			if priceInfo ~= nil and isBound ~= true then 
				if NetWorth.savedVariables.PricingData == "Avg" then
					stackprice = priceInfo.Avg * stack
					bagTotal = bagTotal + stackprice
				elseif NetWorth.savedVariables.PricingData == "Max" then
					stackprice = priceInfo.Max * stack
					bagTotal = bagTotal + stackprice
				else
					stackprice = priceInfo.Min * stack
					bagTotal = bagTotal + stackprice
				end
			else
				stackprice = sellPrice * stack
				bagTotal = bagTotal + stackprice
			end
		end
	end
	
	return bagTotal

end

function NetWorth.GetCraftBagTotal()
	
	local bag = BAG_VIRTUAL
	local bagTotal = 0

	for index, data in pairs(SHARED_INVENTORY.bagCache[bag])do 
		if data ~= nil then
			local itemLink = GetItemLink(bag,data.slotIndex)
			local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
			local name = GetItemName(bag, data.slotIndex)
			local icon, stack, sellPrice, meetsUsageRequirment, locked, equipType, itemStyleId, quality = GetItemInfo(bag, data.slotIndex)
			local stackprice = 0
			local isBound = IsItemLinkBound(itemLink)
			
			if name ~= "" then
			if priceInfo ~= nil and isBound ~= true then 
					if NetWorth.savedVariables.PricingData == "Avg" then
						stackprice = priceInfo.Avg * stack
						bagTotal = bagTotal + stackprice
					elseif NetWorth.savedVariables.PricingData == "Max" then
						stackprice = priceInfo.Max * stack
						bagTotal = bagTotal + stackprice
					else
						stackprice = priceInfo.Min * stack
						bagTotal = bagTotal + stackprice
					end
				else
					stackprice = sellPrice * stack
					bagTotal = bagTotal + stackprice
				end
			end
			
		end	
	end
	
	return bagTotal

end

function NetWorth.GetHouseInventoryTotal()

	local houseTotal = 0
	local inHouse = GetCurrentZoneHouseId()
	
	if inHouse ~= 0 and IsOwnerOfCurrentHouse() then
		for index,data in pairs (SHARED_FURNITURE.retrievableFurniture) do
			itemLink,_ = GetPlacedFurnitureLink(data['retrievableFurnitureId'])
			priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
			if itemLink ~= '' then
				if IsItemLinkBound(itemLink) ~= true and  priceInfo ~= nil then
					if NetWorth.savedVariables.PricingData == "Avg" then
						houseTotal = houseTotal + priceInfo.Avg
					elseif NetWorth.savedVariables.PricingData == "Max" then
						houseTotal = houseTotal + priceInfo.Max
					else
						houseTotal = houseTotal + priceInfo.Min
					end
				--Need to add a section to calculate value of bound housing items (Maybe, do I?  Do we care?  Are we caring about that?)  
				end

			end
		end
	end
	
	return houseTotal
	
	
end

function NetWorth.SlashCommands(extra)

	if extra_arguments == nil or extra_arguments == '' then
		NetWorthMain:SetHidden(false)
		HUD_SCENE:AddFragment(NetWorth.fragment1)
		HUD_UI_SCENE:AddFragment(NetWorth.fragment1)
		NetWorth.CalculateAndDisplayNetWorth()
	else
	--do extra stuff
		NetWorthMain:SetHidden(false)
		HUD_SCENE:AddFragment(NetWorth.fragment1)
		HUD_UI_SCENE:AddFragment(NetWorth.fragment1)
	end

end

function NetWorth.ButtonCloseMainOnClicked()

	HUD_SCENE:RemoveFragment(NetWorth.fragment1)
	HUD_UI_SCENE:RemoveFragment(NetWorth.fragment1)
	NetWorthMain:SetHidden(true)
	
	HUD_SCENE:RemoveFragment(NetWorth.fragment2)
	HUD_UI_SCENE:RemoveFragment(NetWorth.fragment2)
	NetWorthInfoWindow:SetHidden(true)

end

function NetWorth.ButtonCloseInfoWindowOnClicked()

	HUD_SCENE:RemoveFragment(NetWorth.fragment2)
	HUD_UI_SCENE:RemoveFragment(NetWorth.fragment2)
	NetWorthInfoWindow:SetHidden(true)

end

function NetWorth.OnPlayerCombatState(event, inCombat)


	if NetWorth.savedVariables.HideInCombat then
		if inCombat then
			HUD_SCENE:RemoveFragment(NetWorth.fragment1)
			HUD_UI_SCENE:RemoveFragment(NetWorth.fragment1)
			NetWorthMain:SetHidden(inCombat)
			
			HUD_SCENE:RemoveFragment(NetWorth.fragment2)
			HUD_UI_SCENE:RemoveFragment(NetWorth.fragment2)
			NetWorthInfoWindow:SetHidden(inCombat)
		else 
			--do nothing
		end
	end


end

EVENT_MANAGER:RegisterForEvent(NetWorth.name, EVENT_ADD_ON_LOADED, NetWorth.OnAddOnLoaded)

function NetWorth.CreateSettingsWindow()

	local panelData = {
		type = "panel",
		name = "Net Worth",
		displayName = "Net Worth",
		author = "KermitTheFrog88",
		version = NetWorth.version,
		slashCommand = "/networth",
		registerForRefresh = true,
		registerForDefaults = true,
		website = "https://www.esoui.com/downloads/info3318-NetWorth-Youmaybewealthierthanyouthink.html",  --update url
		feedback = "https://www.esoui.com/downloads/info3318-NetWorth-Youmaybewealthierthanyouthink.html#comments", --update url
		donation = "https://www.esoui.com/downloads/info3318-NetWorth-Youmaybewealthierthanyouthink.html",  --Add in game mail function
	}
	
	NetWorth.cntrlOptionsPanel = LAM2:RegisterAddonPanel("Net_Worth", panelData)
	
	local optionsData={
		[1] = {
			type = "header",
			name = "Settings",
		},
		[2] = {
			type = "description",
			text = "Settings to control the Net Worth interface",
		},
		[3] = {
			type = "checkbox",
			name = "Hide interface when in combat.",
			tooltip = "If set to ON the Net Worth windows will be hidden when in combat",
			default = false,
			getFunc = function() return NetWorth.savedVariables.HideInCombat end,
			setFunc = function(newValue)
				NetWorth.savedVariables.HideInCombat = newValue
				end,
		},
		[4] = {
			type = "dropdown",
			name = "TTC pricing data",
			tooltip = "Select which category of TTC pricing data we use to calculate net worth (TTC = Tamriel Trade Center)",
			choices = {"Avg", "Max", "Min"},
			getFunc = function() return NetWorth.savedVariables.PricingData end,
			setFunc = function(newValue) 
				NetWorth.savedVariables.PricingData = newValue 
				end,
		},
	}
	
	LAM2:RegisterOptionControls("Net_Worth", optionsData)

	
end

function NetWorth.SaveLocWindow()

	NetWorth.savedVariables.OffsetX = NetWorthMain:GetLeft()
	NetWorth.savedVariables.OffsetY = NetWorthMain:GetTop()
end

