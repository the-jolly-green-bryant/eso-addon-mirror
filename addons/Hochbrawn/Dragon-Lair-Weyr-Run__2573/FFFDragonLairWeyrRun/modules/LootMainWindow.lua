local dlwr = FFFDragonLairWeyrRun --addon name
local classes = dlwr.classes

classes.LootMainWindow = ZO_Object:Subclass()

local window = FFFDragonLairWeyrRunWindow  -- this is the name of the top level control in the xml file
local itemList = {}
local totalFarmed = 0



classes.LootMainWindow.SORT_KEYS = {
		["namelabel"] = {},
		["countslabel"] = {tiebreaker="name"},
		["pricelabel"] = {tiebreaker="name"}
}


local function ToGold(amount)
	return ZO_CurrencyControl_FormatCurrencyAndAppendIcon(amount, false, CURT_MONEY, false)
end

function classes.LootMainWindow:New()
    local object = ZO_Object.New(self)
    object:Init()
    return object
end

function classes.LootMainWindow:Init()
	--itemList is a control on the xml form
    itemList = window:GetNamedChild("DetailPanel"):GetNamedChild("ItemList")
    ZO_ScrollList_AddDataType(itemList, 1, "FFFDragonLairWeyrRunGUIItemListItemTemplate", 30, function(control, data) self:UpdateDataRow(control, data) end)
	
	
end

function classes.LootMainWindow:Show()
    window:SetHidden(false)
end

function classes.LootMainWindow:Hide()
    window:SetHidden(true)
end

function classes.LootMainWindow:ShowOwnItems(ShowOwn, ShowFarmed, playeritemList, playerName)
	totalFarmed = playeritemList.totalValue
	local btnLabel = window:GetNamedChild("ButtonShowOwnItems"):GetNamedChild("ButtonShowOwnLabel")
	local btnDepositLabel = window:GetNamedChild("ButtonShowDeposits"):GetNamedChild("ButtonShowDepositsLabel")
	if ShowOwn then
		--d("Showing Own Items")
		btnLabel:SetText(playerName)
	else
		--d("Showing Group Items")
		btnLabel:SetText("Group Items")
	end
	if ShowFarmed then
		btnDepositLabel:SetText("Farmed")
	else
		btnDepositLabel:SetText("Deposits")
	end
	
	
	ZO_ScrollList_Clear(itemList)
	ZO_ScrollList_Commit(itemList)
	local scrollData = ZO_ScrollList_GetDataList(itemList)
	
	for _,data in pairs(playeritemList.items) do
		--d(data.itemLink)
		scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(1, DetailEntry:New(data))
	end
	self.sortFunction = function(listEntry1,listEntry2) return listEntry1.data.totalValueFarmed > listEntry2.data.totalValueFarmed end
	table.sort(scrollData, self.sortFunction)
	ZO_ScrollList_Commit(itemList)
	
	window:GetNamedChild("TotalLabel"):SetText(ToGold(math.floor(totalFarmed or 0)))
	
end



function classes.LootMainWindow:UpdateDataRow(control, data)
	control:GetNamedChild("Icon"):SetTexture(data.texture)
	control:GetNamedChild("NameLabel"):SetText(zo_strformat('<<t:1>>', data.itemLink))
	control:GetNamedChild("CountsLabel"):SetText(data.quantityFarmed)
    control:GetNamedChild("PriceLabel"):SetText(ToGold(math.floor(data.totalValueFarmed)))
	window:GetNamedChild("TotalLabel"):SetText(ToGold(math.floor(totalFarmed or 0)))
	
end

function classes.LootMainWindow:OnItemFarmed(item, PlayerTotalFarmed)
	local scrollData = ZO_ScrollList_GetDataList(itemList)
	local found = false
	totalFarmed = PlayerTotalFarmed
	for _, itemData in pairs(scrollData) do
		if itemData.data.itemId == item.itemId then
            itemData.data:Add(item)--, actionType)
			found = true
			break
		end
	end

	if not found then
		local data = DetailEntry:New(item)--, actionType)
		scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(1, data)
	end
	self.sortFunction = function(listEntry1,listEntry2) return listEntry1.data.totalValueFarmed > listEntry2.data.totalValueFarmed end
	table.sort(scrollData, self.sortFunction)
	ZO_ScrollList_Commit(itemList)
    
end



function classes.LootMainWindow:Reset()
	local scrollData = ZO_ScrollList_GetDataList(itemList)
	ZO_ScrollList_Clear(itemList)
	ZO_ScrollList_Commit(itemList)
	window:GetNamedChild("TotalLabel"):SetText("")
	
end