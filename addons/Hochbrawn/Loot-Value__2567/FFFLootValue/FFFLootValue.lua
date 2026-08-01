-- Create namespace for addon
FFFLootValue = {
    version = "0.0.0.3",
    name = "FFFLootValue",
    displayName = "Loot Value",
	goldStart = 0,
	MMTotalItemValue = 0,
	CollectedGold = 0,
	VendorTotalItemValue = 0,
	TotalGold = 0,
	freeBagSlots = 0,
	numBagSlots = 0,
	tlw = nil, --Top Level Window
	wm = GetWindowManager(),
	lblMMTIV = nil, --Mastermerchant Total Item Value
	lblTCG = nil,  -- Total Collected Gold
	lblVTIV = nil, --Vendor Item Value
	lblTG =nil --Total Player Gold
	
	
}


function FFFLootValue.OnAddOnLoaded(event, addonName)
    if addonName == FFFLootValue.name then 
		
		FFFLootValue.CreateControl()
		FFFLootValue.Init()
		EVENT_MANAGER:UnregisterForEvent(FFFLootValue.name, EVENT_ADD_ON_LOADED)
	end
    
end

function FFFLootValue.Init()
	-- setup control
	FFFLootValue.SetUpControl()
	-- set up saved variables
	FFFLootValue.savedVariables = ZO_SavedVars:New("FFFLootValueSavedVars",1,nil,{})
	FFFLootValue.RestorePosition()
	
end
function FFFLootValue.OnMoveStop()
	-- event handler for when top level window stops being dragged and we can save its location
	FFFLootValue.savedVariables.left = FFFLootValue.tlw:GetLeft()
	FFFLootValue.savedVariables.top = FFFLootValue.tlw:GetTop()
	
	
end

function FFFLootValue.RestorePosition()
	-- restore the position of the control to the last saved position
	local left = FFFLootValue.savedVariables.left
	local top = FFFLootValue.savedVariables.top
	FFFLootValue.tlw:ClearAnchors()
	FFFLootValue.tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function FFFLootValue.SetUpControl()
	-- Set initial values
	FFFLootValue.goldStart = GetCurrencyAmount(CURT_MONEY,CURRENCY_LOCATION_CHARACTER)
	FFFLootValue.lblTG:SetText(FFFLootValue.goldStart)
	FFFLootValue.lblMMTIV:SetText(math.floor(FFFLootValue.MMTotalItemValue))
	FFFLootValue.lblVTIV:SetText(FFFLootValue.VendorTotalItemValue)
	FFFLootValue.lblTCG:SetText(FFFLootValue.CollectedGold)
	-- get number of bag slots
	FFFLootValue.numBagSlots = GetBagUseableSize(BAG_BACKPACK)
	FFFLootValue.freeBagSlots = FFFLootValue.GetFreeBagSlots()
	FFFLootValue.lblBagSpace:SetText(FFFLootValue.freeBagSlots)
	--d(FFFLootValue.numBagSlots,FFFLootValue.freeBagSlots)
	FFFLootValue.lvBackDrop:SetCenterColor(1-(FFFLootValue.freeBagSlots/FFFLootValue.numBagSlots),0,0)
	FFFLootValue.lvBackDrop:SetAlpha(1-(FFFLootValue.freeBagSlots/FFFLootValue.numBagSlots))
end

function FFFLootValue.ResetValues()
	-- reset control
	FFFLootValue.MMTotalItemValue = 0
	FFFLootValue.VendorTotalItemValue = 0
	FFFLootValue.CollectedGold = 0
	FFFLootValue.SetUpControl()
	
	
end

function FFFLootValue.GetFreeBagSlots()
	local freeslots = 0
	i=0
	while( i <= FFFLootValue.numBagSlots)
	do
		if not HasItemInSlot(BAG_BACKPACK, i) then
			freeslots = freeslots + 1
		end
		i = i + 1
	end
	return freeslots
end

-- Build Control
function FFFLootValue.CreateControl()
	-- Top level window
	FFFLootValue.tlw = FFFLootValue.wm:CreateTopLevelWindow("lvTLW")
	FFFLootValue.tlw:SetDimensions(200,85)
	FFFLootValue.tlw:SetResizeToFitDescendents(true)
	FFFLootValue.tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 200,200) -- a default start position for tlw
	FFFLootValue.tlw:SetMovable(true)
	FFFLootValue.tlw:SetMouseEnabled(true)
	-- setup handler to deal with new location after move
	FFFLootValue.tlw:SetHandler("OnMoveStop", FFFLootValue.OnMoveStop)
	--setup back drop
	FFFLootValue.lvBackDrop = FFFLootValue.wm:CreateControl("lvBackDrop", FFFLootValue.tlw, CT_BACKDROP)
	FFFLootValue.lvBackDrop:SetEdgeColor(.9,.89,.68,.9)
	FFFLootValue.lvBackDrop:SetEdgeTexture("",1,1,2,0) 
	--SetEdgeTexture(string filename, number edgeFileWidth, number edgeFileHeight, number edgeSize, number edgeFilePadding)
	FFFLootValue.lvBackDrop:SetCenterColor(0,0,0)
	FFFLootValue.lvBackDrop:SetAnchor(TOPLEFT, FFFLootValue.tlw, TOPLEFT,0,0)
	FFFLootValue.lvBackDrop:SetDimensions(200,85)
	FFFLootValue.lvBackDrop:SetAlpha(0.1)
	FFFLootValue.lvBackDrop:SetDrawLayer(0)
	-- set none updating labels
	local lblItem = FFFLootValue.wm:CreateControl("lblItem", FFFLootValue.tlw, CT_LABEL)
	lblItem:SetColor(0.9,0.8,0.7,1)
	lblItem:SetFont("ZoFontGameSmall")
	lblItem:SetScale(1)
	lblItem:SetDimensions(60,15)
	lblItem:SetText("ITEM $")
	lblItem:SetAnchor(TOPLEFT,FFFLootValue.tlw, TOPLEFT,80,5)
	lblItem:SetDrawLayer(1)
	local lblGold = FFFLootValue.wm:CreateControl("lblGold", FFFLootValue.tlw, CT_LABEL)
	lblGold:SetColor(0.9,0.8,0.7,1)
	lblGold:SetFont("ZoFontGameSmall")
	lblGold:SetScale(1)
	lblGold:SetDimensions(60,15)
	lblGold:SetText("GOLD")
	lblGold:SetAnchor(TOPLEFT,FFFLootValue.tlw, TOPLEFT,150,5)
	lblGold:SetDrawLayer(1)
	local lblMMValue = FFFLootValue.wm:CreateControl("lblMMValue", FFFLootValue.tlw, CT_LABEL)
	lblMMValue:SetColor(0.9,0.8,0.7,1)
	lblMMValue:SetFont("ZoFontGameSmall")
	lblMMValue:SetScale(1)
	lblMMValue:SetDimensions(60,15)
	lblMMValue:SetText("MM")
	lblMMValue:SetAnchor(TOPLEFT,FFFLootValue.tlw, TOPLEFT,10,25)
	lblMMValue:SetDrawLayer(1)
	local lblVendorValue = FFFLootValue.wm:CreateControl("lblVendorValue", FFFLootValue.tlw, CT_LABEL)
	lblVendorValue:SetColor(0.9,0.8,0.7,1)
	lblVendorValue:SetFont("ZoFontGameSmall")
	lblVendorValue:SetScale(1)
	lblVendorValue:SetDimensions(60,15)
	lblVendorValue:SetText("Vendor")
	lblVendorValue:SetAnchor(TOPLEFT,FFFLootValue.tlw, TOPLEFT,10,45)
	lblVendorValue:SetDrawLayer(1)
	local lblFreeSlots = FFFLootValue.wm:CreateControl("lblFreeSlots", FFFLootValue.tlw, CT_LABEL)
	lblFreeSlots:SetColor(0.9,0.8,0.7,1)
	lblFreeSlots:SetFont("ZoFontGameSmall")
	lblFreeSlots:SetScale(1)
	lblFreeSlots:SetDimensions(60,15)
	lblFreeSlots:SetText("Bag Space")
	lblFreeSlots:SetAnchor(TOPLEFT,FFFLootValue.tlw, TOPLEFT,10,65)
	lblFreeSlots:SetDrawLayer(1)
	-- setup labels that will be updated
	FFFLootValue.lblMMTIV = FFFLootValue.wm:CreateControl("lblMMTIV", FFFLootValue.tlw, CT_LABEL)
	FFFLootValue.lblMMTIV:SetColor(0.9,0.8,0.7,1)
	FFFLootValue.lblMMTIV:SetFont("ZoFontGameSmall")
	FFFLootValue.lblMMTIV:SetScale(1)
	FFFLootValue.lblMMTIV:SetDimensions(60,15)
	FFFLootValue.lblMMTIV:SetText("0")
	FFFLootValue.lblMMTIV:SetAnchor(TOPLEFT,FFFLootValue.tlw, TOPLEFT,80,25)
	FFFLootValue.lblMMTIV:SetDrawLayer(1)
	--
	FFFLootValue.lblTCG = FFFLootValue.wm:CreateControl("lblTCG", FFFLootValue.tlw, CT_LABEL)
	FFFLootValue.lblTCG:SetColor(0.9,0.8,0.7,1)
	FFFLootValue.lblTCG:SetFont("ZoFontGameSmall")
	FFFLootValue.lblTCG:SetScale(1)
	FFFLootValue.lblTCG:SetDimensions(60,15)
	FFFLootValue.lblTCG:SetText("0")
	FFFLootValue.lblTCG:SetAnchor(TOPLEFT,FFFLootValue.tlw, TOPLEFT,150,25)
	FFFLootValue.lblTCG:SetDrawLayer(1)
	--
	FFFLootValue.lblVTIV = FFFLootValue.wm:CreateControl("lblVTIV", FFFLootValue.tlw, CT_LABEL)
	FFFLootValue.lblVTIV:SetColor(0.9,0.8,0.7,1)
	FFFLootValue.lblVTIV:SetFont("ZoFontGameSmall")
	FFFLootValue.lblVTIV:SetScale(1)
	FFFLootValue.lblVTIV:SetDimensions(60,15)
	FFFLootValue.lblVTIV:SetText("0")
	FFFLootValue.lblVTIV:SetAnchor(TOPLEFT,FFFLootValue.tlw, TOPLEFT,80,45)
	FFFLootValue.lblVTIV:SetDrawLayer(1)
	--
	FFFLootValue.lblTG = FFFLootValue.wm:CreateControl("lblTG", FFFLootValue.tlw, CT_LABEL)
	FFFLootValue.lblTG:SetColor(0.9,0.8,0.7,1)
	FFFLootValue.lblTG:SetFont("ZoFontGameSmall")
	FFFLootValue.lblTG:SetScale(1)
	FFFLootValue.lblTG:SetDimensions(60,15)
	FFFLootValue.lblTG:SetText("0")
	FFFLootValue.lblTG:SetAnchor(TOPLEFT,FFFLootValue.tlw, TOPLEFT,150,45)
	FFFLootValue.lblTG:SetDrawLayer(1)
	--Bag space
	FFFLootValue.lblBagSpace = FFFLootValue.wm:CreateControl("lblBagSpace", FFFLootValue.tlw, CT_LABEL)
	FFFLootValue.lblBagSpace:SetColor(0.9,0.8,0.7,1)
	FFFLootValue.lblBagSpace:SetFont("ZoFontGameSmall")
	FFFLootValue.lblBagSpace:SetScale(1)
	FFFLootValue.lblBagSpace:SetDimensions(60,15)
	FFFLootValue.lblBagSpace:SetText("0")
	FFFLootValue.lblBagSpace:SetAnchor(TOPLEFT,FFFLootValue.tlw, TOPLEFT,80,65)
	FFFLootValue.lblBagSpace:SetDrawLayer(1)
	-- Add Reset Button
	FFFLootValue.btnReset = FFFLootValue.wm:CreateControl("btnReset", FFFLootValue.tlw, CT_LABEL)
	FFFLootValue.btnReset:SetColor(0.9,0.8,0.7,1)
	FFFLootValue.btnReset:SetFont("ZoFontGameSmall")
	FFFLootValue.btnReset:SetScale(1)
	FFFLootValue.btnReset:SetDimensions(50,15)
	FFFLootValue.btnReset:SetText("RESET")
	FFFLootValue.btnReset:SetAnchor(TOPLEFT,FFFLootValue.tlw, TOPLEFT,10,5)
	FFFLootValue.btnReset:SetDrawLayer(1)
	FFFLootValue.btnReset:SetMouseEnabled(true)
	FFFLootValue.btnReset:SetMovable(false)
	FFFLootValue.btnReset:SetHandler("OnMouseDown", FFFLootValue.ResetValues)
	
	
end


function FFFLootValue.OnLootReceived(event, lootedBy, itemName, quantity, itemSound, lootType, isMe ,isPickPocketLoot, questicon, itemId,isStolen)
	--EVENT_LOOT_RECEIVED (number eventCode, string receivedBy, string itemName, number quantity, ItemUISoundCategory soundCategory, LootItemType lootType, boolean self, boolean isPickpocketLoot, string questItemIcon, number itemId, boolean isStolen)
	if not isMe then return end
	-- adjust back color to indicate how full bag is. (becomes redder as it fills)
	FFFLootValue.freeBagSlots = FFFLootValue.GetFreeBagSlots()
	FFFLootValue.lblBagSpace:SetText(FFFLootValue.freeBagSlots)
	FFFLootValue.lvBackDrop:SetCenterColor(1-(FFFLootValue.freeBagSlots/FFFLootValue.numBagSlots),0,0)
	FFFLootValue.lvBackDrop:SetAlpha(1-(FFFLootValue.freeBagSlots/FFFLootValue.numBagSlots))
	
	local MMitemValue = GetMMValue(itemName)
	local VitemValue = GetVValue(itemName)
	
	FFFLootValue.MMTotalItemValue = FFFLootValue.MMTotalItemValue + MMitemValue * quantity
	FFFLootValue.lblMMTIV:SetText(math.floor(FFFLootValue.MMTotalItemValue))
	
	FFFLootValue.VendorTotalItemValue = FFFLootValue.VendorTotalItemValue + VitemValue * quantity
	FFFLootValue.lblVTIV:SetText(FFFLootValue.VendorTotalItemValue)
	
end

function FFFLootValue.OnMoneyReceived(event, newAmount, oldAmount, CurrencyChangeReason)
	--EVENT_MONEY_UPDATE (number eventCode, number newMoney, number oldMoney, CurrencyChangeReason reason)
	
	FFFLootValue.CollectedGold = newAmount - FFFLootValue.goldStart
	FFFLootValue.lblTCG:SetText(FFFLootValue.CollectedGold)
	FFFLootValue.lblTG:SetText(newAmount)
	
	
end



function GetMMValue(itemLink)
	if MasterMerchant ~= nil then
		local mmValue = MasterMerchant:itemStats(itemLink)["avgPrice"]
		if mmValue ~= nil then
			return mmValue
		end
	
	end
	-- GetItemLinkInfo(string itemLink)
	--Returns: string icon, number sellPrice, boolean meetsUsageRequirement, number EquipType equipType, number itemStyleId
	local _, vendorValue = GetItemLinkInfo(itemLink)

	return vendorValue
end

function GetVValue(itemLink)
	-- GetItemLinkInfo(string itemLink)
	--Returns: string icon, number sellPrice, boolean meetsUsageRequirement, number EquipType equipType, number itemStyleId
	local _, itemValue = GetItemLinkInfo(itemLink)
	return itemValue
		
	
end



EVENT_MANAGER:RegisterForEvent(FFFLootValue.name, EVENT_ADD_ON_LOADED, FFFLootValue.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(FFFLootValue.name, EVENT_LOOT_RECEIVED, FFFLootValue.OnLootReceived)
EVENT_MANAGER:RegisterForEvent(FFFLootValue.name, EVENT_MONEY_UPDATE, FFFLootValue.OnMoneyReceived)
