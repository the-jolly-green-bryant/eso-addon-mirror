--[[ 
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
You can read the full terms at https://account.elderscrollsonline.com/add-on-terms

 The grids in this application are borrowed from the ScrollListExample from Librairan, and this addon was built with some great help from our ESOUI community.
  ]]
local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

CustomerList = ZO_SortFilterList:Subclass()
CustomerList.defaults = {}
TradeList = ZO_SortFilterList:Subclass()
TradeList.defaults = {}
TheirTradeItemsList = ZO_SortFilterList:Subclass()
TheirTradeItemsList.defaults = {}
MyTradeItemsList = ZO_SortFilterList:Subclass()
MyTradeItemsList.defaults = {}
TradingHousePurchasesList = ZO_SortFilterList:Subclass()
TradingHousePurchasesList.defaults = {}

TRADESMAN = {}
TRADESMAN.name = "TradesMan"
TRADESMAN.DEFAULT_TEXT = ZO_ColorDef:New(0.4627, 0.737, 0.7647, 1) -- scroll list row text color
TRADESMAN.RED_TEXT = ZO_ColorDef:New(255, 0, 0, 1) -- scroll list row text color
TRADESMAN.GREEN_TEXT = ZO_ColorDef:New(0, 255, 0, 1) -- scroll list row text color
TRADESMAN.CustomerList = nil
TRADESMAN.TradeList = nil
TRADESMAN.TheirTradeItemsList = nil
TRADESMAN.MyTradeItemsList = nil
TRADESMAN.TradingHousePurchasesList = nil

TRADESMAN.CoinageIcon = "/esoui/art/guild/guildhistory_indexicon_guildstore_up.dds"


TRADESMAN.DEFAULTEMPTYNOTESTEXT = "Enter notes about customer..."

TRADESMAN.Default = {
	OffsetX = 50,
	OffsetY = 75,
    Transactions = {},
	MyTraders = {},
	ShowCustomerWindowPopup = false,
	EnabledDebuggingOutput = false,
	SaveWindowLocation = true,
	TradeHistoryDays = 180,
	TradingHousePurchases = {},
	OpenTradingHouseWithMainWindow = false
}
--=======================START TRADE TRACKING INFO=======================================
local CurrentTransaction = {
	Name = "",
	Class = "",
    Race = "",
    Alliance = "",
    Level = "",
	TradeItems = {}
}

local MyCoinGiven, TheirCoinGiven,CurrentSelectedCustomerName,
MyCurrentTradeItems = {}, CurrentSelectedTradeIndex, SelectedTraderMan, CurrentPlayerName,SelectedGuildStorePurchaseTraderMan
local AllMyTraders = {}
local AllCustomerAccountIds = {}
local SearchedWhisperNames = {}
--=========================END TRADE TRACKING INFO=====================================

CustomerList.SORT_KEYS = {
		["name"] = {},
		["gender"] = {tiebreaker="name"},		
		["level"] = {tiebreaker="name"},
		["race"] = {tiebreaker="name"},
		["class"] = {tiebreaker="name"},
		["lasttrade"] = {tiebreaker="name"}
}
TradeList.SORT_KEYS = {		
		["tradeindex"] = {},
		["tradedate"] = {tiebreaker="tradeindex"},
		["mytrader"] = {tiebreaker="tradeindex"},
		["coinage"] = {tiebreaker="tradeindex"},
		["zone"] = {tiebreaker="tradeindex"}			
}
TheirTradeItemsList.SORT_KEYS = {
		["itemname"] = {}
}
MyTradeItemsList.SORT_KEYS = {	
		["itemname"] = {}
}
TradingHousePurchasesList.SORT_KEYS = {
		["purchasedate"] = {},	
		["itemname"] = {tiebreaker="purchasedate"},
		["price"] = {tiebreaker="purchasedate"},
		["avgprice"] = {tiebreaker="purchasedate"},	
		["guild"] = {tiebreaker="purchasedate"}	
}


-- The index consists of the item's required level, required vet
-- level, quality, and trait(if any), separated by colons.
function MakeIndexFromLink(itemLink)
  local levelReq = GetItemLinkRequiredLevel(itemLink)
  local vetReq = GetItemLinkRequiredVeteranRank(itemLink)
  local itemQuality = GetItemLinkQuality(itemLink)  
  local itemTrait = GetItemLinkTraitInfo(itemLink)
--  return "RequiredLevel: " .. levelReq .. " RequiredVeteranRank: " .. vetReq .. " ItemQuality: " .. itemQuality .. " ItemTrait: " .. itemTrait
  return levelReq .. ":" .. vetReq .. ":" .. itemQuality .. ":" .. itemTrait
end

function UpdateItemLink(itemLink)
		local linkTable = { ZO_LinkHandler_ParseLink(itemLink) }
			if #linkTable == 23 and linkTable[3] == ITEM_LINK_TYPE then
				linkTable[24] = linkTable[23]
				linkTable[23] = linkTable[22]
				linkTable[22] = "0"
				itemLink = ("|H%d:%s|h%s|h"):format(linkTable[2], table.concat(linkTable, ':', 3), linkTable[1])
			end
		return itemLink
 end
 
 local function ReadableTextNumber(num, places)
    local ret
    --local placeValue = ("%%.%df"):format(places or 0)
    local placeValue = ("%%.%df"):format(1)
	
	if not num then
        return 0
    elseif num >= 1000000000000 then
        ret = placeValue:format(num / 1000000000000) .. " trillion" -- trillion
    elseif num >= 1000000000 then
        ret = placeValue:format(num / 1000000000) .. " billion" -- billion
    elseif num >= 1000000 then
        ret = placeValue:format(num / 1000000) .. " million" -- million  
    else       
		  ret = string.gsub(num, "^(-?%d+)(%d%d%d)", '%1,%2')
		 --ret = placeValue:format(num)
    end
    return ret
end

--Thanks Garkin
local function ConvertToDisplayName(name)
local displayName
if IsDecoratedDisplayName(name) then
	displayName = name
else
	d("searching for account id for "..name)
	if IsFriend(name) then
		for i=1, GetNumFriends() do
			local _, characterName = GetFriendCharacterInfo(i)
			
			characterName = zo_strformat(SI_UNIT_NAME, characterName)
			--d(characterName)
		   if characterName == name then
				--d("this person is friend")
				displayName = GetFriendInfo(i)
				d("Friend Account ID set for: "..displayName)
				TRADESMAN.savedVariables.Transactions[name].AccountID = displayName
				break
		   end
		end
	end
	if not displayName then
		if not IsIgnored(name) then
			--d("ignore added for "..name)
			AddIgnore(name) --add player to the ignore list
			
			zo_callLater(function (displayName) 
			local ignoredDisplayName, _ = GetIgnoredInfo(GetNumIgnored()) --get display name of the last added ignored player
			TRADESMAN.savedVariables.Transactions[name].AccountID = ignoredDisplayName
			--d("ignoredDisplayName: "..ignoredDisplayName)
			RemoveIgnore(ignoredDisplayName)
			d("Account ID set for: "..ignoredDisplayName)
			end, 5000)
			 
		else
			d("Name is on the ignore list.")
		end
	end
end
return displayName
end

function CustomerList:New()
	local customers = ZO_SortFilterList.New(self, CustomerListContainer)
	
	customers.masterList = {}
	
 	ZO_ScrollList_AddDataType(customers.list, 1, "CustomerUnitRow", 30, function(control, data) customers:SetupUnitRow(control, data) end)
 	ZO_ScrollList_EnableHighlight(customers.list, "ZO_ThinListHighlight")	
 	customers.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, customers.currentSortKey, CustomerList.SORT_KEYS, customers.currentSortOrder) end
	customers.sortHeaderGroup:SelectHeaderByKey("name")
	customers:RefreshData()
		
	return customers
end

function TradeList:New()
	local trades = ZO_SortFilterList.New(self, TradeListContainer)	
	
	
	trades.masterList = {}
 	ZO_ScrollList_AddDataType(trades.list, 1, "TradeUnitRow", 30, function(control, data) trades:SetupUnitRow(control, data) end)
 	ZO_ScrollList_EnableHighlight(trades.list, "ZO_ThinListHighlight")
 	trades.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, trades.currentSortKey, TradeList.SORT_KEYS, trades.currentSortOrder) end
	trades.sortHeaderGroup:SelectHeaderByKey("tradeindex")
	trades:RefreshData()
	
	return trades
end

function TheirTradeItemsList:New()
	local trades = ZO_SortFilterList.New(self, TheirTradeItemsContainer)	
	
	trades.masterList = {}
 	ZO_ScrollList_AddDataType(trades.list, 1, "TradeItemRow", 30, function(control, data) trades:SetupUnitRow(control, data) end)
 	ZO_ScrollList_EnableHighlight(trades.list, "ZO_ThinListHighlight")
 	trades.sortFunction = function(listEntry1, listEntry2) 
	return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, trades.currentSortKey, TheirTradeItemsList.SORT_KEYS, trades.currentSortOrder) end
	trades.sortHeaderGroup:SelectHeaderByKey("itemname")
	trades:RefreshData()
	
	return trades
end

function TradingHousePurchasesList:New()
	local trades = ZO_SortFilterList.New(self, TradingHousePurchaseListContainer)	
	
	trades.masterList = {}
 	ZO_ScrollList_AddDataType(trades.list, 1, "TradingHouseItemUnitRow", 30, function(control, data) trades:SetupUnitRow(control, data) end)
 	ZO_ScrollList_EnableHighlight(trades.list, "ZO_ThinListHighlight")
 	trades.sortFunction = function(listEntry1, listEntry2) 
	return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, trades.currentSortKey, TradingHousePurchasesList.SORT_KEYS, trades.currentSortOrder) end
	trades.sortHeaderGroup:SelectHeaderByKey("purchasedate")
	trades:RefreshData()
	
	return trades
end



--loaddata
function TradingHousePurchasesList:BuildMasterList()
	self.masterList = {}
	--buildpurchase
	local purchases = TRADESMAN.savedVariables.TradingHousePurchases
	--d("BuildMasterList")	ItemIcon	
	for purchaseIndex, purchaseObject in pairs(purchases) do
		
		    local avgPriceCalc = 0
			if purchaseObject.Price ~= nil and purchaseObject.ItemStack ~= nil then
				avgPriceCalc = purchaseObject.Price /  purchaseObject.ItemStack
			end
						
			local data = {itemname = purchaseObject.ItemName, itemlink = purchaseObject.ItemLink,price = purchaseObject.Price, itemstack = purchaseObject.ItemStack, 
			avgprice = avgPriceCalc or 0, purchasedate = purchaseObject.Date, seller = purchaseObject.ItemSeller, guild = purchaseObject.GuildName, itemicon = purchaseObject.ItemIcon}			
		
		if SelectedGuildStorePurchaseTraderMan == "ALL" then	
				--d(data)
				table.insert(self.masterList, data)		
		else
			if purchaseObject.MyTrader == SelectedGuildStorePurchaseTraderMan then	
				--d(data)
				table.insert(self.masterList, data)				
			end
		end
	end
end	


function MyTradeItemsList:New()
	local trades = ZO_SortFilterList.New(self, MyTradeItemsContainer)	
	trades.masterList = {}
 	ZO_ScrollList_AddDataType(trades.list, 1, "TradeItemRow", 30, function(control, data) trades:SetupUnitRow(control, data) end)
 	ZO_ScrollList_EnableHighlight(trades.list, "ZO_ThinListHighlight")
 	trades.sortFunction = function(listEntry1, listEntry2) 
	return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, trades.currentSortKey, MyTradeItemsList.SORT_KEYS, trades.currentSortOrder) end
	trades.sortHeaderGroup:SelectHeaderByKey("itemname")
	trades:RefreshData()
	return trades
end

function MyTradeItemsList:BuildMasterList()
	self.masterList = {}
	
    if ( CurrentSelectedTradeIndex and CurrentSelectedTradeIndex ~= "") 
	and ( CurrentSelectedCustomerName and CurrentSelectedCustomerName ~= "") then 
		
		local selectedTrade = TRADESMAN.savedVariables.Transactions[CurrentSelectedCustomerName].Trades[CurrentSelectedTradeIndex]
		
		for key, itemObject in pairs(selectedTrade.MyItems) do		 
			 local stack = (itemObject.Stack or "")
			 local link = (itemObject.Link or "")
			 local name = (itemObject.Name or "")
			 local coin = (itemObject.Coin or 0)
			 local icon = (itemObject.Icon or "")
			 
			 if coin ~= 0 then	 
				if (type(coin) ~= "number") then					
					coin = 0
				end	
			 end
							 
			if name ~= "" or coin > 0 then		
				local data = {itemicon = icon, itemname = name, itemcoin = coin, itemstack = stack, itemlink = link }
				
				table.insert(self.masterList, data)
			end
			
			end
		 end		
end	

function TheirTradeItemsList:BuildMasterList()
	self.masterList = {}
	--d(CurrentSelectedTradeIndex)
	--d(CurrentSelectedCustomerName)
				
    if ( CurrentSelectedTradeIndex and CurrentSelectedTradeIndex ~= "") 
	and ( CurrentSelectedCustomerName and CurrentSelectedCustomerName ~= "") then 
		
		--d(CurrentSelectedTradeIndex)
		
		local selectedTrade = TRADESMAN.savedVariables.Transactions[CurrentSelectedCustomerName].Trades[CurrentSelectedTradeIndex]
		--d(selectedTrade)
		for key, itemObject in pairs(selectedTrade.TheirItems) do
	 
		 local stack = (itemObject.Stack or "")
		 local link = (itemObject.Link or "")
		 local name = (itemObject.Name or "")
		 local coin = (itemObject.Coin or 0)
		 local icon = (itemObject.Icon or "")

			if coin ~= 0 then	 
				if (type(coin) ~= "number") then					
					coin = 0
				end	
			end			
		
			if name ~= "" or coin > 0 then
				local data = {itemicon = icon, itemname = name, itemcoin = coin, itemstack = stack, itemlink = link }
				table.insert(self.masterList, data)		
			end		
		 end			
	end
	
end

function CustomerList:BuildMasterList()
	self.masterList = {}
	
	local numberofDisplayDays = tonumber(TRADESMAN.savedVariables.TradeHistoryDays) -- (TRADESMAN.savedVariables.TradeHistoryDays * 86400000)
	--d("last display date:"..tostring(lastTradeDateToDisplay))
    local transactions = TRADESMAN.savedVariables.Transactions
		
	for charName, customerObject in pairs(transactions) do
		
		local displayLevel = ""
		
		if customerObject.Veteranrank == 0 or customerObject.Veteranrank == "" then
			displayLevel = (customerObject.Level or "")
		else
			if customerObject.Veteranrank ~= "" and customerObject.Veteranrank ~= nil then
				displayLevel = "CP "..(customerObject.Veteranrank or "")
			else 
				displayLevel = ""
			end	
		end
									
		local mostRecentTradeDate = 0000000000
		local customerForSelectedTrader = false
				
		
		-- check to see what the most recent trade date is and if this is a customer of the selected trader		
		for tradeKey, tradeObject in pairs(customerObject.Trades) do			
						
			if tradeObject.MyTrader == SelectedTraderMan then
				if  tradeObject.Date > mostRecentTradeDate then
					mostRecentTradeDate = tradeObject.Date
				end		
				--d("trade for: "..SelectedTraderMan)
				--d("trader: "..tradeObject.MyTrader)
				customerForSelectedTrader = true
			end		
		end	
		
				
		--local tradeDateDisplay = GetDateStringFromTimestamp(mostRecentTradeDate)	
			
		local data = {name = charName, gender = (customerObject.Gender or ""), level = (displayLevel or ""), race = (customerObject.Race or ""), 
					 class = (customerObject.Class or ""), alliance = (customerObject.Alliance or ""), accountid = (customerObject.AccountID or ""),
					 lasttrade = mostRecentTradeDate }
				
		if SelectedTraderMan ~= "ALL"  then
		
		 --if not (GetDiffBetweenTimeStamps(GetTimeStamp(), mostRecentTradeDate) < lastTradeDateToDisplay) then   
		--		d("not display")			
		 --end
		 --local secsSince = GetTimeStamp() - theTime
		  --zo_strformat(GetString(SK_TIME_DAYS), math.floor(secsSince / 86400.0))
			local secsSince = GetTimeStamp() - mostRecentTradeDate
			local daysSince = math.floor(secsSince / 86400.0) + 1;
			
			--d("d1: "..tradeDateDisplay)
			--d("d2: "..tostring( daysSince))
			--d("d1: "..tostring(secsSince))
			
			--d("d2:"..tostring(GetDiffBetweenTimeStamps(GetTimeStamp(), mostRecentTradeDate)))	
			
			if customerForSelectedTrader and daysSince <= numberofDisplayDays then			
				--d(GetDiffBetweenTimeStamps(GetTimeStamp(), mostRecentTradeDate))				
				table.insert(self.masterList, data)				
			end	
		else
			local lastTradeIndex = #TRADESMAN.savedVariables.Transactions[charName].Trades
			local tradeKeyIndex, tradeObjectDetail = pairs(TRADESMAN.savedVariables.Transactions[charName].Trades[lastTradeIndex])
			local secsSince = GetTimeStamp() - tradeObjectDetail.Date
			local daysSince = math.floor(secsSince / 86400.0) + 1;
			--d(tradeObjectDetail)
			--data.lasttrade = GetDateStringFromTimestamp(tradeObjectDetail.Date)	
			data.lasttrade = tradeObjectDetail.Date	
			
			--d(tostring(GetDiffBetweenTimeStamps(GetTimeStamp(), tradeObjectDetail.Date)))
			
			if daysSince <= numberofDisplayDays then
				table.insert(self.masterList, data)
			end		
			
		end
		
		
    end	
	--local sort_func = function( a,b ) return a.data.charName < b.data.charName end
	--table.sort( self.masterList, sort_func )
	
end

function TradeList:BuildMasterList()
	self.masterList = {}
	--d(CurrentSelectedCustomerName)
	
	local numberofDisplayDays = tonumber(TRADESMAN.savedVariables.TradeHistoryDays) -- (TRADESMAN.savedVariables.TradeHistoryDays * 86400000)
				
	if CurrentSelectedCustomerName and CurrentSelectedCustomerName ~= "" then 
		--d(CurrentSelectedCustomerName)
		local selectedCustomer = TRADESMAN.savedVariables.Transactions[CurrentSelectedCustomerName]	 	 
		for tradeKey, tradeObject in pairs(selectedCustomer.Trades) do    
				
			--local tradeDateDisplay = tradeObject.DisplayDate or GetDateStringFromTimestamp(tradeObject.Date)			
				--tradeDateDisplay = "Trade #"..(tostring(tradeKey)).." "..tradeDateDisplay
				
				local theirCoin = 0	
				for key, itemObject in pairs(tradeObject.TheirItems) do			 
					local coin = (itemObject.Coin or 0)
									 
					if coin ~= 0 then	 
						if (type(coin) == "number") then
							theirCoin = coin
							break	
						end	
					end	
				end	
				
				local myCoin = 0
				for key, itemObject in pairs(tradeObject.MyItems) do			 
					local coin = (itemObject.Coin or 0)
					if coin ~= 0 then	 
						if (type(coin) == "number") then
							myCoin = coin
							break	
						end	
					end	
				end									
			
				local data = {tradeindex = tradeKey, tradedate = tradeObject.Date,
				mytrader = (tradeObject.MyTrader or ""), coinage = (theirCoin - myCoin), zone = (tradeObject.Zone or "")}
				
				local secsSince = GetTimeStamp() - tradeObject.Date
				local daysSince = math.floor(secsSince / 86400.0) + 1;
				
				if daysSince <= numberofDisplayDays then
					if SelectedTraderMan ~= "ALL" then 	
						if(tradeObject.MyTrader == SelectedTraderMan) then						
							table.insert(self.masterList, data)
						end	
					else
						table.insert(self.masterList, data)
					end
				end				
		 end	 
	  end
end


function MyTradeItemsList:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
	
    for i = 1, #self.masterList do
        local data = self.masterList[i]
    	table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
    end    
end

function TheirTradeItemsList:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
	
    for i = 1, #self.masterList do
        local data = self.masterList[i]
    	table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
    end    
end

function CustomerList:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
	
    for i = 1, #self.masterList do
        local data = self.masterList[i]
    	table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
    end    
end

function TradeList:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
	
    for i = 1, #self.masterList do
        local data = self.masterList[i]
    	table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
    end    
end

function TradingHousePurchasesList:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
	
    for i = 1, #self.masterList do
        local data = self.masterList[i]
    	table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
    end    
end

function TradingHousePurchasesList:SortScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
end
function MyTradeItemsList:SortScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
end
function TheirTradeItemsList:SortScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
end
function CustomerList:SortScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
end
function TradeList:SortScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function TradingHousePurchasesList:SetupUnitRow(control, data)
	control.data = data
	control.itemname = GetControl(control, "Item")
	control.itemicon = GetControl(control, "ItemIcon")
	control.price = GetControl(control, "Price")
	control.avgprice = GetControl(control, "AvgPrice")
	control.purchasedate = GetControl(control, "PurchaseDate")
	--control.seller = GetControl(control, "Seller")
	control.guild = GetControl(control, "Guild")
	
	--control.seller:SetText(data.seller)
	local avgprice = 0
	if(data.avgprice ~= nil) then
		avgprice = data.avgprice
	end
	
	local price = 0
	if(data.price ~= nil) then
		price = data.price
	end
	
	control.avgprice:SetText(round(avgprice, 2))
	control.price:SetText(round(price, 2))
	
	control.purchasedate:SetText(GetDateStringFromTimestamp(data.purchasedate))	
	
	control.guild:SetText(data.guild)
	--control.itemname:SetText(data.itemlink.." x "..data.itemstack)
			
	control.itemname:SetText(data.itemname.." x "..data.itemstack)
		
		--enable mouse events for label:
		control.itemname:SetMouseEnabled(true)
		 			 
		--set handler for mouse click (actually this event is fired when mouse button is released, argument upInside indicated if button was released when cursor is still inside of the control):
		control.itemname:SetHandler("OnMouseUp", function(self, button, upInside, ctrl, alt, shift, command)
				if upInside then
					local displayLink = UpdateItemLink(data.itemlink)
					ZO_LinkHandler_OnLinkClicked(displayLink, button, self)
				end
			end)
			
		if data.itemicon ~= "" then
		
			control.itemicon:SetTexture(data.itemicon)	
			--enable mouse events for label:
			control.itemicon:SetMouseEnabled(true)
					 
			--set handler for mouse click (actually this event is fired when mouse button is released, argument upInside indicated if button was released when cursor is still inside of the control):
			control.itemicon:SetHandler("OnMouseUp", function(self, button, upInside, ctrl, alt, shift, command)
				if upInside then
					local displayLink = UpdateItemLink(data.itemlink)
					ZO_LinkHandler_OnLinkClicked(displayLink, button, self)
				end
			end)	
		else 
			control.itemicon:SetHidden(true)	
		end
		
	
	--d(data.itemlink.." x "..data.itemstack)

	control.itemname.normalColor = TRADESMAN.DEFAULT_TEXT
	control.price.normalColor = TRADESMAN.DEFAULT_TEXT
	control.avgprice.normalColor = TRADESMAN.DEFAULT_TEXT
	control.purchasedate.normalColor = TRADESMAN.DEFAULT_TEXT
	--control.seller.normalColor = TRADESMAN.DEFAULT_TEXT
	control.guild.normalColor = TRADESMAN.DEFAULT_TEXT

	ZO_SortFilterList.SetupRow(self, control, data)
end

function MyTradeItemsList:SetupUnitRow(control, data)

--local data = {itemicon = icon, itemname = name, itemcoin = coin, itemstack = stack, itemlink = link }
	--d(data)
	control.data = data
	control.itemname = GetControl(control, "ItemName")
	control.itemicon = GetControl(control, "ItemIcon")
		
	if data.itemicon ~= "" and data.itemlink ~= "" then
		control.itemicon:SetTexture(data.itemicon)		
		control.itemname:SetText(data.itemname.." x "..data.itemstack)
		
		--enable mouse events for label:
		control.itemname:SetMouseEnabled(true)
		 			 
		--set handler for mouse click (actually this event is fired when mouse button is released, argument upInside indicated if button was released when cursor is still inside of the control):
		control.itemname:SetHandler("OnMouseUp", function(self, button, upInside, ctrl, alt, shift, command)
				if upInside then
					local displayLink = UpdateItemLink(data.itemlink)
					ZO_LinkHandler_OnLinkClicked(displayLink, button, self)
				end
			end)
		--enable mouse events for label:
		control.itemicon:SetMouseEnabled(true)
		 			 
		--set handler for mouse click (actually this event is fired when mouse button is released, argument upInside indicated if button was released when cursor is still inside of the control):
		control.itemicon:SetHandler("OnMouseUp", function(self, button, upInside, ctrl, alt, shift, command)
				if upInside then
					local displayLink = UpdateItemLink(data.itemlink)
					ZO_LinkHandler_OnLinkClicked(displayLink, button, self)
				end
			end)	

	else
		if data.itemcoin > 0 then
			--if data.itemcoin > 0 then
				local coinage = string.gsub(data.itemcoin, "^(-?%d+)(%d%d%d)", '%1,%2')
			
				--control.itemstack:SetText(coinage)
				control.itemicon:SetTexture(TRADESMAN.CoinageIcon)
				control.itemname:SetText(coinage)
				control.itemicon:SetMouseEnabled(false)
				control.itemname:SetMouseEnabled(false)
			--else
			--	control.itemname:SetHidden(true)
			--end				
		end
	end
	
	control.itemname.normalColor = TRADESMAN.DEFAULT_TEXT
	
	ZO_SortFilterList.SetupRow(self, control, data)
end

function TheirTradeItemsList:SetupUnitRow(control, data)

--local data = {itemicon = icon, itemname = name, itemcoin = coin, itemstack = stack, itemlink = link }
	--d(data)
	control.data = data
	control.itemname = GetControl(control, "ItemName")
	control.itemicon = GetControl(control, "ItemIcon")
	
	--control.itemstack = GetControl(control, "ItemStack")
	
	
	if data.itemicon ~= "" and data.itemlink ~= "" then
		control.itemicon:SetTexture(data.itemicon)		
		control.itemname:SetText(data.itemname.." x "..data.itemstack)
		
		--enable mouse events for label:
		control.itemname:SetMouseEnabled(true)
		

		--set handler for mouse click (actually this event is fired when mouse button is released, argument upInside indicated if button was released when cursor is still inside of the control):
		control.itemname:SetHandler("OnMouseUp", function(self, button, upInside, ctrl, alt, shift, command)
				if upInside then
					local displayLink = UpdateItemLink(data.itemlink)
					ZO_LinkHandler_OnLinkClicked(displayLink, button, self)
				end
			end)
		--enable mouse events for label:
		control.itemicon:SetMouseEnabled(true)
		 
		--set handler for mouse click (actually this event is fired when mouse button is released, argument upInside indicated if button was released when cursor is still inside of the control):
		control.itemicon:SetHandler("OnMouseUp", function(self, button, upInside, ctrl, alt, shift, command)
				if upInside then
					local displayLink = UpdateItemLink(data.itemlink)
					ZO_LinkHandler_OnLinkClicked(displayLink, button, self)
				end
			end)	
			
	else
		if data.itemcoin ~= "" then
			--if data.itemcoin > 0 then
				local coinage = string.gsub(data.itemcoin, "^(-?%d+)(%d%d%d)", '%1,%2')
			
				--control.itemstack:SetText(coinage)
				control.itemicon:SetTexture(TRADESMAN.CoinageIcon)
				control.itemname:SetText(coinage)
				control.itemicon:SetMouseEnabled(false)
				control.itemname:SetMouseEnabled(false)
			--else
			--	control.itemname:SetHidden(true)
			--end

				
		end
	end
	
	control.itemname.normalColor = TRADESMAN.DEFAULT_TEXT
	
	ZO_SortFilterList.SetupRow(self, control, data)
end


function CustomerList:SetupUnitRow(control, data)
	control.data = data
	control.name = GetControl(control, "Name")
	control.race = GetControl(control, "Race")
	--control.class = GetControl(control, "Class")
	
	control.gender = GetControl(control, "Gender")	
	--control.alliance = GetControl(control, "Alliance")
	control.alliance = GetControl(control, "AllianceIcon")
	control.class = GetControl(control, "ClassIcon")
	control.whisper = GetControl(control, "WhisperIcon")
	control.group = GetControl(control, "GroupIcon")
	control.friend = GetControl(control, "FriendIcon")
	control.accountid = GetControl(control, "GetAccountId")
	
	control.level = GetControl(control, "Level")
	control.level:SetText(data.level)
	
	control.lasttrade = GetControl(control, "LastTrade")
	--control.lasttrade:SetText(data.lasttrade)
	
	control.lasttrade:SetText(GetDateStringFromTimestamp(data.lasttrade))
			
	control.name:SetText(data.name)
	control.race:SetText(data.race)
	--control.class:SetText(data.class)

	control.gender:SetText(data.gender)	
	--control.alliance:SetText(data.alliance)
	
	if data.alliance ~= "" then
		control.alliance:SetTexture(GetAllianceIconName(data.alliance))
		control.alliance:SetHidden(false)
		control.alliance:SetMouseEnabled(true)
		
		local allianceName = GetAllianceName(data.alliance)
		--set handler for mouse enter:
		control.alliance:SetHandler("OnMouseEnter", function(self)
			 ZO_Tooltips_ShowTextTooltip(self, TOP, allianceName)
			end)
		 
		--set handler for mouse exit:
		control.alliance:SetHandler("OnMouseExit", function(self)
				 ZO_Tooltips_HideTextTooltip()
			end)		
	else
		control.alliance:SetHidden(true)
	end
	
	if data.class ~= "" then
		--d(class)
		control.class:SetHidden(false)
		control.class:SetTexture(GetClassIconName(data.class))
		control.class:SetMouseEnabled(true)
		--set handler for mouse enter:
		control.class:SetHandler("OnMouseEnter", function(self)
			 ZO_Tooltips_ShowTextTooltip(self, TOP, data.class)
			end)
		 
		--set handler for mouse exit:
		control.class:SetHandler("OnMouseExit", function(self)
				 ZO_Tooltips_HideTextTooltip()
			end)
	else
		control.class:SetHidden(true)
	end
	
	control.whisper:SetMouseEnabled(true)
				
	control.whisper:SetHandler("OnMouseUp", function(self)
		CHAT_SYSTEM:StartTextEntry("", CHAT_CHANNEL_WHISPER,data.name)
	end)
	control.whisper:SetHandler("OnMouseEnter", function(self)
		 ZO_Tooltips_ShowTextTooltip(self, TOP, "Whisper "..data.name)
	end)
	
	control.whisper:SetHandler("OnMouseExit", function(self)
		 ZO_Tooltips_HideTextTooltip()
	end)
	
	local isPlayerMyFriend, playerStatus
	isPlayerMyFriend = false
	playerStatus = PLAYER_STATUS_OFFLINE
		
	--d("status:"..tostring(status))
	--d("online:"..tostring(PLAYER_STATUS_ONLINE))
	--d("offline:"..tostring(PLAYER_STATUS_OFFLINE))
	
	if IsFriend(data.name) then
			isPlayerMyFriend = true
			for index = 1, GetNumFriends() do
				local name, status, lastOnline
				name, note, status, lastOnline = GetFriendInfo(index)
				if name == account then 					
					playerStatus = status
					--d(tostring(status))					
					break 
				end
			end
	
	end
	
	--TODO: only allow group invites for online friends
	--if (isPlayerMyFriend and playerStatus == PLAYER_STATUS_ONLINE) and (CurrentPlayerName == SelectedTraderMan and SelectedTraderMan ~= "ALL") then	
	if (CurrentPlayerName == SelectedTraderMan and SelectedTraderMan ~= "ALL") then	
	
		control.group:SetHidden(false)
		control.group:SetMouseEnabled(true)
					
		control.group:SetHandler("OnMouseUp", function(self)
			GroupInviteByName(data.name)
			--GroupInvite(data.name)			
		end)
		control.group:SetHandler("OnMouseEnter", function(self)
			ZO_Tooltips_ShowTextTooltip(self, TOP, "Invite "..data.name.." to group")
		end)
			 
		control.group:SetHandler("OnMouseExit", function(self)
				 ZO_Tooltips_HideTextTooltip()
			end)	
	else
		control.group:SetHidden(true)
	end 
	
	--we are already friends :)	
	if isPlayerMyFriend then
		control.friend:SetHidden(true)
	else
		control.friend:SetHidden(false)
		control.friend:SetMouseEnabled(true)
				
		control.friend:SetHandler("OnMouseUp", function(self)
			RequestFriend(data.name,"")
		end)
		control.friend:SetHandler("OnMouseEnter", function(self)
			ZO_Tooltips_ShowTextTooltip(self, TOP, "Send Friend Request to "..data.name)
		end)
			 
		control.friend:SetHandler("OnMouseExit", function(self)
			 ZO_Tooltips_HideTextTooltip()
		end)
	end
	
	
	if data.accountid == "" then
		control.accountid:SetHidden(false)
		control.accountid:SetMouseEnabled(true)
					
		control.accountid:SetHandler("OnMouseUp", function(self)
			ConvertToDisplayName(data.name)
		end)
		control.accountid:SetHandler("OnMouseEnter", function(self)
			 ZO_Tooltips_ShowTextTooltip(self, TOP, "Get Account ID for "..data.name)
		end)
		 
		control.accountid:SetHandler("OnMouseExit", function(self)
			 ZO_Tooltips_HideTextTooltip()
		end)
	
	else
		control.accountid:SetHidden(true)
	end
	
	control.name.normalColor = TRADESMAN.DEFAULT_TEXT
	control.race.normalColor = TRADESMAN.DEFAULT_TEXT	
	control.gender.normalColor = TRADESMAN.DEFAULT_TEXT
	control.level.normalColor = TRADESMAN.DEFAULT_TEXT

	ZO_SortFilterList.SetupRow(self, control, data)
end

function TradeList:SetupUnitRow(control, data)
	control.data = data
	control.tradedate = GetControl(control, "TradeDate")
	control.mytrader = GetControl(control, "MyTrader")
	control.coinage = GetControl(control, "Coinage")
	control.tradeindex = GetControl(control, "TradeIndex")
	control.zone = GetControl(control, "Zone")
	
	control.zone:SetText(data.zone)	
	control.tradedate:SetText(GetDateStringFromTimestamp(data.tradedate))
	control.mytrader:SetText(data.mytrader)
	control.tradeindex:SetText(data.tradeindex)
		
	local coinage = string.gsub(data.coinage, "^(-?%d+)(%d%d%d)", '%1,%2')
		
	control.coinage:SetText(coinage)
	
	if data.coinage ~= nil and data.coinage ~= "" then
	
		--local coinValue = tonumber(data.coinage)
		local coinValue = data.coinage
		
		if coinValue == 0 then
			control.coinage.normalColor = TRADESMAN.DEFAULT_TEXT
			--control.tradedate.normalColor = TRADESMAN.DEFAULT_TEXT
			--control.mytrader.normalColor = TRADESMAN.DEFAULT_TEXT
		elseif coinValue > 0 then		
			control.coinage.normalColor = TRADESMAN.GREEN_TEXT
			--control.tradedate.normalColor = TRADESMAN.GREEN_TEXT
			--control.mytrader.normalColor = TRADESMAN.GREEN_TEXT
		else		
			control.coinage.normalColor = TRADESMAN.RED_TEXT
			--control.tradedate.normalColor = TRADESMAN.RED_TEXT
			--control.mytrader.normalColor = TRADESMAN.RED_TEXT
		end	
	else
		control.coinage.normalColor = TRADESMAN.DEFAULT_TEXT	
	end

	control.tradedate.normalColor = TRADESMAN.DEFAULT_TEXT
	control.mytrader.normalColor = TRADESMAN.DEFAULT_TEXT
	control.tradeindex.normalColor = TRADESMAN.DEFAULT_TEXT
	control.zone.normalColor = TRADESMAN.DEFAULT_TEXT
	
	ZO_SortFilterList.SetupRow(self, control, data)
end

function MyTradeItemsList:Refresh()
	self:RefreshData()
end
function TheirTradeItemsList:Refresh()
	self:RefreshData()
end

function CustomerList:Refresh()
	self:RefreshData()
end

function TradeList:Refresh()
	self:RefreshData()
end

function TradingHousePurchasesList:Refresh()
	self:RefreshData()
end

function TRADESMAN.MouseEnter(control)
	TRADESMAN.CustomerList:Row_OnMouseEnter(control)
end

function TRADESMAN.MouseExit(control)
	TRADESMAN.CustomerList:Row_OnMouseExit(control)
end

function TRADESMAN.MouseUp(control, button, upInside)
	local name = control.data.name
--	local gender = control.data.gender
--	local class = control.data.class
--	local race = control.data.race
--	local zone = control.data.zone
--	local gender = control.data.gender	
--	local alliance = control.data.alliance
--	local level = control.data.level
	--d(name)
	
	SetSelectedCustomerInfo(name)
end

function SetSelectedCustomerInfo(name)

	local selectedCustomer = TRADESMAN.savedVariables.Transactions[name]
	CurrentSelectedCustomerName = name
	
	--TRADESMAN.TRADESMANNotesLabel:SetText("NOTES FOR: "..CurrentSelectedCustomerName)
	
	--SelectedCustomerNameDisplay:SetText("CUSTOMER NAME: "..CurrentSelectedCustomerName)
	SelectedCustomerNameDisplay:SetText(string.upper(CurrentSelectedCustomerName))
	
	local notes = selectedCustomer.Notes or ""
	
	if notes == "" then
		TRADESMAN.TRADESMANCustomerNotesText:SetText(TRADESMAN.DEFAULTEMPTYNOTESTEXT)
	else
		TRADESMAN.TRADESMANCustomerNotesText:SetText(selectedCustomer.Notes)
	end	
	
	--d(selectedCustomer)
	
	TRADESMAN.TradeList:Refresh()
	
	CurrentSelectedTradeIndex = ""
	TRADESMAN.TheirTradeItemsList:Refresh()	
	TRADESMAN.MyTradeItemsList:Refresh()
		
	TradeItemsListContainer:SetHidden(false)		
	MyTradeItemsContainer:SetHidden(false)	
		
	--local lastTradeIndex = #TRADESMAN.savedVariables.Transactions[CurrentSelectedCustomerName].Trades	
	SetSelectedTradeDetails()
	
	TRADESMAN.TheirTradeItemsList:Refresh()	
	TRADESMAN.MyTradeItemsList:Refresh()


end

function SetSelectedTradeDetails()
	--HERE
	--d("Selected Customer"..CurrentSelectedCustomerName)
	--local selectedTrade = TRADESMAN.savedVariables.Transactions[CurrentSelectedCustomerName].Trades[CurrentSelectedTradeIndex]
	local lastTradeIndex = 0

	if SelectedTraderMan == "ALL" then
		lastTradeIndex = #TRADESMAN.savedVariables.Transactions[CurrentSelectedCustomerName].Trades
	else
		for tradeKey, tradeObject in pairs(TRADESMAN.savedVariables.Transactions[CurrentSelectedCustomerName].Trades) do  
			if tradeKey > lastTradeIndex and tradeObject.MyTrader == SelectedTraderMan then
				lastTradeIndex = tradeKey
			end			
		end		
	end
			
	--local lastTradeIndex = #TRADESMAN.savedVariables.Transactions[CurrentSelectedCustomerName].Trades
	local tradeKey, tradeObject = pairs(TRADESMAN.savedVariables.Transactions[CurrentSelectedCustomerName].Trades[lastTradeIndex])
	  
	local tmdisplayDate = tradeObject.DisplayDate or GetDateStringFromTimestamp(tradeObject.Date)			
	local tradeDateDisplay = "TRADE #"..(tostring(lastTradeIndex)).." - "..tmdisplayDate
													
	SelectedTradeDetailsInfo:SetText(tradeDateDisplay)

	CurrentSelectedTradeIndex = lastTradeIndex
	
end

function TRADESMAN.TradesMouseUp(control, button, upInside)

	--TradeItemsListContainer:SetHidden(false)		
	--MyTradeItemsContainer:SetHidden(false)	
	local tradedate = control.data.tradedate
	local tradeindex = control.data.tradeindex
	--d("Trade Index: "..tostring(tradeindex))
	
	CurrentSelectedTradeIndex = tradeindex
	
	SelectedTradeDetailsInfo:SetText("TRADE #"..tostring(tradeindex).." - "..GetDateStringFromTimestamp(tradedate))
	
	TRADESMAN.TheirTradeItemsList:Refresh()
	TRADESMAN.MyTradeItemsList:Refresh()
end

function TRADESMAN.TradesMouseEnter(control)
	TRADESMAN.CustomerList:Row_OnMouseEnter(control)
end

function TRADESMAN.TradesMouseExit(control)
	TRADESMAN.CustomerList:Row_OnMouseExit(control)
end

local function SetToolTip(ctrl, text, placement)
    ctrl:SetHandler("OnMouseEnter", function(self)
        ZO_Tooltips_ShowTextTooltip(self, placement, text)
    end)
    ctrl:SetHandler("OnMouseExit", function(self)
        ZO_Tooltips_HideTextTooltip()
    end)
end

function trimstring(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function GetCalculateTraderTotals(selectedTrader)
	
	local goldSpent = 0
	local goldEarned = 0
	local largestSale = 0
	for customerKey, customerObject in pairs(TRADESMAN.savedVariables.Transactions) do   
	
	local accountIdName = customerObject.AccountID or ""
	--there
	if accountIdName ~= "" then
		if not AllCustomerAccountIds[customerKey] then
			local customerAccountIdInfo = { accountID = accountIdName, customerName = customerKey}
			--d(customerAccountIdInfo)
			AllCustomerAccountIds[customerKey] = {}						
			table.insert(AllCustomerAccountIds[customerKey], customerAccountIdInfo)
		end 
	end
	for tradeKey, tradeObject in pairs(customerObject.Trades) do   
				
			if tradeObject.MyTrader == selectedTrader then
			
				for key, tradeItem in pairs(tradeObject.TheirItems) do
				 local coin = (tradeItem.Coin or 0)
				 
					if coin ~= 0 then	 
						if (type(coin) ~= "number") then					
							coin = 0
						end	
					end	
					
					if coin > largestSale then
						largestSale = coin
					end
										
						goldEarned = goldEarned + coin											
				 end	
				
				for key, tradeItem in pairs(tradeObject.MyItems) do
				 local coin = (tradeItem.Coin or 0)
				 
					if coin ~= 0 then	 
						if (type(coin) ~= "number") then					
							coin = 0
						end	
					end												
						goldSpent = goldSpent + coin						
				 end	
				
			end		 
		end
	end
			
	local traderNumbers = { 
           totalGoldEarned = goldEarned,
           totalGoldSpent = goldSpent,
		   biggestSale = largestSale
           }
	
	return traderNumbers		
end


function SetTraderTotals(selectedTrader)

if selectedTrader ~= "ALL" then
	SelectedTraderTotalSpent:SetHidden(false)
	SelectedTraderLargestSale:SetHidden(false)
	SelectedTraderTotalEarned:SetHidden(false)
	
	local traderTotals = GetCalculateTraderTotals(selectedTrader)	

	--local biggestSale = string.gsub(traderTotals.biggestSale, "^(-?%d+)(%d%d%d)", '%1,%2')
	local biggestSale = ReadableTextNumber(traderTotals.biggestSale)
	SelectedTraderLargestSale:SetText("Largest Sale: "..biggestSale)
			
	--local totalGoldEarned = string.gsub(traderTotals.totalGoldEarned, "^(-?%d+)(%d%d%d)", '%1,%2')
	local totalGoldEarned = ReadableTextNumber(traderTotals.totalGoldEarned)
	SelectedTraderTotalEarned:SetText("Gold Earned: "..totalGoldEarned)
	
	--local totalGoldSpent = string.gsub(traderTotals.totalGoldSpent, "^(-?%d+)(%d%d%d)", '%1,%2')
	local totalGoldSpent = ReadableTextNumber(traderTotals.totalGoldSpent)
	SelectedTraderTotalSpent:SetText("Gold Spent: "..totalGoldSpent)
else
	SelectedTraderTotalSpent:SetHidden(true)
	SelectedTraderLargestSale:SetHidden(true)
	SelectedTraderTotalEarned:SetHidden(true)
end

end

function hex2rgb(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2),16)/255, tonumber("0x"..hex:sub(3,4),16)/255, tonumber("0x"..hex:sub(5,6),16)/255
end

function TRADESMAN.CreateGuildStorePurchaseWindow()
	TRADESMAN.TradingHousePurchasesList = TradingHousePurchasesList:New()
	
	
	TRADESMAN.MyTradingHouseTradersDropdown = WINDOW_MANAGER:CreateControlFromVirtual("MyTradingHouseTradersDropdown", TradingHousePurchasesWindow, "ZO_StatsDropdownRow")
    TRADESMAN.MyTradingHouseTradersDropdown:SetAnchor(TOPLEFT, TradingHousePurchasesWindow, TOPLEFT, 20, 0)  
	
	local traderDropdown = TRADESMAN.MyTradingHouseTradersDropdown:GetNamedChild("Dropdown")
    traderDropdown:SetWidth(220)	
	SetToolTip(traderDropdown, "Select a Trader", RIGHT) 
		
    local function OnGuildStoreTraderItemSelect(_, selectedName, choice)  	
		SelectedGuildStorePurchaseTraderMan = selectedName
					
		TRADESMAN.TradingHousePurchasesList:Refresh()
		
	end	
		
	local defaultAllGuildPurchasesTrader = TRADESMAN.MyTradingHouseTradersDropdown.dropdown:CreateItemEntry("ALL", OnGuildStoreTraderItemSelect)
    TRADESMAN.MyTradingHouseTradersDropdown.dropdown:AddItem(defaultAllGuildPurchasesTrader)
	
	for k, traderName in pairs(TRADESMAN.savedVariables.MyTraders) do
		local dropDownItem = TRADESMAN.MyTradingHouseTradersDropdown.dropdown:CreateItemEntry(traderName, OnGuildStoreTraderItemSelect)
		TRADESMAN.MyTradingHouseTradersDropdown.dropdown:AddItem(dropDownItem)
	end
	
	local playerName = zo_strformat(SI_UNIT_NAME, GetUnitName("player"))
	TRADESMAN.MyTradingHouseTradersDropdown.dropdown:SetSelectedItem(playerName)  
	
	SelectedGuildStorePurchaseTraderMan = playerName
					
	TRADESMAN.TradingHousePurchasesList:Refresh()
	
	TRADESMAN.TRADESMANTradingHouseClose = WINDOW_MANAGER:CreateControl("TRADESMANTradingHouseCloseButton", TradingHousePurchasesWindow, CT_BUTTON)
    TRADESMAN.TRADESMANTradingHouseClose:SetDimensions(28, 28)
    TRADESMAN.TRADESMANTradingHouseClose:SetAnchor(TOPRIGHT, TradingHousePurchasesWindow, TOPRIGHT, 0 , 0)
    TRADESMAN.TRADESMANTradingHouseClose:SetState(BSTATE_NORMAL)
    TRADESMAN.TRADESMANTradingHouseClose:SetMouseOverBlendMode(0)	
    TRADESMAN.TRADESMANTradingHouseClose:SetEnabled(true)
	TRADESMAN.TRADESMANTradingHouseClose:SetPressedTexture("/esoui/art/buttons/cancel_down.dds")
    TRADESMAN.TRADESMANTradingHouseClose:SetNormalTexture("/esoui/art/buttons/cancel_up.dds")
    TRADESMAN.TRADESMANTradingHouseClose:SetMouseOverTexture("/esoui/art/buttons/cancel_over.dds")
    TRADESMAN.TRADESMANTradingHouseClose:SetHandler("OnClicked", function(self) TRADESMAN.ShowGuildstorePurchaseWindow() end)
	SetToolTip(TRADESMAN.TRADESMANTradingHouseClose,"Close", RIGHT) 
	
	TradingHousePurchasesWindow:ClearAnchors()
	TradingHousePurchasesWindow:SetAnchor(TOPLEFT, TRADESMANWindow, TOPRIGHT, 0, 0)		
end

 function TRADESMAN.ShowGuildstorePurchaseWindow()
    if (TradingHousePurchasesWindow:IsHidden()) then 
	    --SetGameCameraUIMode(true)	   
        TradingHousePurchasesWindow:SetHidden(false) 	
		--CENTER_SCREEN_ANNOUNCE:AddMessage(1, CSA_EVENT_SMALL_TEXT , nil, "A customer has whispered you", nil, nil, nil, nil, nil)
    else    
		--SetGameCameraUIMode(false)		
        TradingHousePurchasesWindow:SetHidden(true)    
    end
end


function TRADESMAN.CreatePrimaryWindow()	
	
	
	local playerName = zo_strformat(SI_UNIT_NAME, GetUnitName("player"))
	
	CurrentPlayerName = playerName
	SelectedTraderMan = playerName
	
	SetTraderTotals(playerName)
	
	
	TRADESMAN.CustomerList = CustomerList:New()
		
	TradeItemsListContainer:SetHidden(true)	
	MyTradeItemsContainer:SetHidden(true)
	
	TRADESMAN.TradeList = TradeList:New()
		
	TRADESMAN.TheirTradeItemsList = TheirTradeItemsList:New()
	TRADESMAN.MyTradeItemsList = MyTradeItemsList:New()
		
	TRADESMAN.MyTradersDropdown = WINDOW_MANAGER:CreateControlFromVirtual("MyTradersDropdown", TRADESMANWindow, "ZO_StatsDropdownRow")
    TRADESMAN.MyTradersDropdown:SetAnchor(LEFT, TRADESMANWindow, TOPLEFT, -100, 20)  
	
	local traderDropdown = TRADESMAN.MyTradersDropdown:GetNamedChild("Dropdown")
    traderDropdown:SetWidth(220)	
	SetToolTip(traderDropdown, "Select a Trader", RIGHT) 
		
    local function OnTraderItemSelect(_, selectedName, choice)  	
		SelectedTraderMan = selectedName
		
		SetTraderTotals(selectedName)
				
		TRADESMAN.CustomerList:Refresh()
		
		SelectedTradeDetailsInfo:SetText("")
		SelectedCustomerNameDisplay:SetText("")
		
		CurrentSelectedCustomerName = ""
		TRADESMAN.TradeList:Refresh()
		
		CurrentSelectedTradeIndex = ""
		TRADESMAN.TheirTradeItemsList:Refresh()	
		TRADESMAN.MyTradeItemsList:Refresh()
		
	end	
		
	local defaultAllTrader = TRADESMAN.MyTradersDropdown.dropdown:CreateItemEntry("ALL", OnTraderItemSelect)
    TRADESMAN.MyTradersDropdown.dropdown:AddItem(defaultAllTrader)
	
	for k, traderName in pairs(TRADESMAN.savedVariables.MyTraders) do
		local dropDownItem = TRADESMAN.MyTradersDropdown.dropdown:CreateItemEntry(traderName, OnTraderItemSelect)
		TRADESMAN.MyTradersDropdown.dropdown:AddItem(dropDownItem)
	end
	
	--local playerName = zo_strformat(SI_UNIT_NAME, GetUnitName("player"))
	TRADESMAN.MyTradersDropdown.dropdown:SetSelectedItem(playerName)  
     	
	TRADESMAN.TRADESMANTradingHouseOpen = WINDOW_MANAGER:CreateControlFromVirtual("TRADESMANTradingHouseOpen", TRADESMANWindow, "ZO_DefaultButton")
	TRADESMAN.TRADESMANTradingHouseOpen:SetText("Guild Store Purchases")
	TRADESMAN.TRADESMANTradingHouseOpen:SetAnchor(LEFT, TRADESMAN.MyTradersDropdown, RIGHT, 10, 0)
	TRADESMAN.TRADESMANTradingHouseOpen:SetWidth(200)
	SetToolTip(TRADESMAN.TRADESMANTradingHouseOpen, "Open Guild Store Purchases", RIGHT)
	TRADESMAN.TRADESMANTradingHouseOpen:SetFont("ZoFontGameBold")
	TRADESMAN.TRADESMANTradingHouseOpen:SetHandler("OnClicked", function() 		
		  if (TradingHousePurchasesWindow:IsHidden()) then 
			--TRADESMAN.CreateGuildStorePurchaseWindow()			
			TRADESMAN.ShowGuildstorePurchaseWindow()		
		  end			
	end)	
		
		
	TRADESMAN.TRADESMANNotesLabel = WINDOW_MANAGER:CreateControl("TRADESMANNotesLabel", TRADESMANWindow, CT_LABEL)
    TRADESMAN.TRADESMANNotesLabel:SetAnchor(TOPLEFT, TRADESMANWindowMiddleDivider, CENTER, 110, 5)
    TRADESMAN.TRADESMANNotesLabel:SetFont("ZoFontGameLargeBold")
	TRADESMAN.TRADESMANNotesLabel:SetColor(hex2rgb("#3a92ff"))
			
    TRADESMAN.TRADESMANNotesLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT) 
    TRADESMAN.TRADESMANNotesLabel:SetText("NOTES:")
			
	TRADESMAN.TRADESMANCustomerNotesBG = WINDOW_MANAGER:CreateControlFromVirtual("TRADESMANCustomerNotesBG", TRADESMANWindow, "ZO_EditBackdrop")
	TRADESMAN.TRADESMANCustomerNotesBG:SetDimensions(320, 140)	
	TRADESMAN.TRADESMANCustomerNotesBG:SetAnchor(TOPLEFT, TRADESMANWindowMiddleDivider, CENTER, 110, 26)
	
	TRADESMAN.TRADESMANCustomerNotesText = WINDOW_MANAGER:CreateControlFromVirtual("TRADESMANCustomerNotesText", TRADESMAN.TRADESMANCustomerNotesBG, "ZO_DefaultEditMultiLineForBackdrop")
	TRADESMAN.TRADESMANCustomerNotesText:SetMaxInputChars(1000)
	TRADESMAN.TRADESMANCustomerNotesText:SetHandler("OnFocusGained", function() 
		local notesText = TRADESMAN.TRADESMANCustomerNotesText:GetText()
		if notesText == TRADESMAN.DEFAULTEMPTYNOTESTEXT then
			TRADESMAN.TRADESMANCustomerNotesText:SetText("")
		end		
		
	end)
	TRADESMAN.TRADESMANCustomerNotesText:SetHandler("OnFocusLost", function() 
		local notesText = TRADESMAN.TRADESMANCustomerNotesText:GetText()
		if notesText == "" then
			TRADESMAN.TRADESMANCustomerNotesText:SetText(TRADESMAN.DEFAULTEMPTYNOTESTEXT)
		end		
	end)	
	
	TRADESMAN.TRADESMANCustomerNotesText:SetText(TRADESMAN.DEFAULTEMPTYNOTESTEXT)
		
	TRADESMAN.TRADESMANSave = WINDOW_MANAGER:CreateControlFromVirtual("TRADESMANSave", TRADESMANWindow, "ZO_DefaultButton")
	TRADESMAN.TRADESMANSave:SetText("SAVE")
	TRADESMAN.TRADESMANSave:SetAnchor(BOTTOMRIGHT, TRADESMAN.TRADESMANCustomerNotesBG, BOTTOMRIGHT, 0, 35)
	TRADESMAN.TRADESMANSave:SetWidth(75)
	SetToolTip(TRADESMAN.TRADESMANSave, "Save Customer Notes", LEFT)
	TRADESMAN.TRADESMANSave:SetFont("ZoFontGameBold")
	TRADESMAN.TRADESMANSave:SetHandler("OnClicked", function() 		
		if TRADESMAN.savedVariables.Transactions[CurrentSelectedCustomerName] then
			local notesText = TRADESMAN.TRADESMANCustomerNotesText:GetText()
			if notesText ~= "" then		
				--notesText = notesText:gsub("\","")
				TRADESMAN.savedVariables.Transactions[CurrentSelectedCustomerName].Notes = notesText
			end				
		end				
	end)
			    
						 
    TRADESMAN.TRADESMANClose = WINDOW_MANAGER:CreateControl("TRADESMANWindowButtonCloseAddon", TRADESMANWindow, CT_BUTTON)
    TRADESMAN.TRADESMANClose:SetDimensions(28, 28)
    TRADESMAN.TRADESMANClose:SetAnchor(TOPRIGHT, TRADESMANWindow, TOPRIGHT, 0 , 0)
    TRADESMAN.TRADESMANClose:SetState(BSTATE_NORMAL)
    TRADESMAN.TRADESMANClose:SetMouseOverBlendMode(0)	
    TRADESMAN.TRADESMANClose:SetEnabled(true)
	TRADESMAN.TRADESMANClose:SetPressedTexture("/esoui/art/buttons/cancel_down.dds")
    TRADESMAN.TRADESMANClose:SetNormalTexture("/esoui/art/buttons/cancel_up.dds")
    TRADESMAN.TRADESMANClose:SetMouseOverTexture("/esoui/art/buttons/cancel_over.dds")
    TRADESMAN.TRADESMANClose:SetHandler("OnClicked", function(self) TRADESMAN.ShowPrimaryWindow() end)
	SetToolTip(TRADESMAN.TRADESMANClose,"Close TRADESMAN", RIGHT) 
			
	TRADESMANWindow:ClearAnchors()
	TRADESMANWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TRADESMAN.savedVariables.OffsetX, TRADESMAN.savedVariables.OffsetY)		
end

function TRADESMAN.SaveWindowLocation()
	TRADESMAN.savedVariables.OffsetX = TRADESMANWindow:GetLeft()
	TRADESMAN.savedVariables.OffsetY = TRADESMANWindow:GetTop()
end
--function TRADESMAN.SaveTradingHousePurchaseWindowLocation()
	--TRADESMAN.savedVariables.TradingHousePurchasesOffsetX = TradingHousePurchasesWindow:GetLeft()
	--TRADESMAN.savedVariables.TradingHousePurchasesOffsetY = TradingHousePurchasesWindow:GetTop()
--end
function TRADESMAN.ClearTradeHistoryDetails()
	TRADESMAN.savedVariables.Transactions = { }
	d("saved variables cleared")	
end
function TRADESMAN.CreateOptionsWindow()

   local panel = {
		type = "panel",
		name = "TradesMan",
		author = "@Argusus",
		version = "2.1b",
		slashCommand = "/tmsettings",
		registerForRefresh = true
	}
	
		local optionsData = {
--		[1] = {
--			type = "header",
--			name = "Settings",
--		},
--		 [2] = {
 --         type = "checkbox",
 --         name = "Debugging Enabled",
 --         tooltip = "Enable Debugging Output?",
 --        getFunc = function() return TRADESMAN.savedVariables.EnabledDebuggingOutput end,
 --         setFunc = function(value) TRADESMAN.savedVariables.EnabledDebuggingOutput = value end,
 --    },
		 [1] = {
          type = "checkbox",
          name = "Display customer trades on whisper",
          tooltip = "Display TRADESMAN window on customer whisper?",
          getFunc = function() return TRADESMAN.savedVariables.ShowCustomerWindowPopup end,
          setFunc = function(value) TRADESMAN.savedVariables.ShowCustomerWindowPopup = value end
       },
		 [2] = {
          type = "checkbox",
          name = "Remember window location",
          tooltip = "Remember window location after moving?",
          getFunc = function() return TRADESMAN.savedVariables.SaveWindowLocation end,
          setFunc = function(value) TRADESMAN.savedVariables.SaveWindowLocation = value end
       },
		 [3] = {
          type = "dropdown",
          name = "Number of days to save trade history",
          tooltip = "Any trades older than the selected choice will not be saved.",
          getFunc = function() return TRADESMAN.savedVariables.TradeHistoryDays end,
          setFunc = function(value) TRADESMAN.savedVariables.TradeHistoryDays = value end,
		   choices = {"15","30","60","90","120","150","180"}
       },
		 [4] = {
          type = "checkbox",
          name = "Open and Close Guild Store Purchases with Main Window",
          tooltip = "Open and Close Guild Store Purchases with Main Window?",
          getFunc = function() return TRADESMAN.savedVariables.OpenTradingHouseWithMainWindow end,
          setFunc = function(value) TRADESMAN.savedVariables.OpenTradingHouseWithMainWindow = value end
       }
--	   ,
--		 [4] = {
--         type = "button",
--          name = "Clear Trade History",
--         tooltip = "This will reset your trade history.",
--          func  = function() return true end,
--		 -- func  = TRADESMAN.ClearTradeHistoryDetails(),        
---		   warning  = "WARNING: this cannot be reversed!"
 --      }
		}
				
	LAM:RegisterAddonPanel("TRADESMANPanel", panel)
	LAM:RegisterOptionControls("TRADESMANPanel", optionsData)

end

function TRADESMAN.TradeItemAdded(eventCode, who, tradeIndex, itemSoundCategory)
  
-- GetTradeItemInfo
--: string name, textureName icon, number stack, number quality, string creatorName, number sellPrice, boolean meetsUsageRequirement, number EquipType equipType, number ItemStyle itemStyle
local name, textureName, stack, quality, creatorName = GetTradeItemInfo(who, tradeIndex)
local link = GetTradeItemLink(who, tradeIndex, LINK_STYLE_BRACKETS)
local icon, sellPrice, meetsUsageRequirement, equipType, itemStyle = GetItemLinkInfo(link)
local itemType = GetItemLinkItemType(link)
local linkIndex = MakeIndexFromLink(link)


--.. " Quality:" .. quality
--d("Item Add: who: " .. who .. " Trade index: " .. tradeIndex)
--d("Item name:" .. name)
--d("Item Count:" .. stack)
--d("Item Quality:" .. quality)
--d("Item name 2:" .. zo_strformat("<<tx:1>>", link))
--d("Item name 3:" .. zo_strformat("<<t:1>>", link))

local itemObject = {
 Stack = stack,
 Link = zo_strformat(SI_ITEM_FORMAT_STR_TEXT1, link),
 Name = zo_strformat("<<t:1>>", link),
 Icon = icon,
 Style = itemStyle,
 ItemType = itemType,
 ItemLink = linkIndex
}

-- trade enum - who
--TRADE_ME
--TRADE_THEM
if who == TRADE_ME then
    table.insert(MyCurrentTradeItems, tradeIndex, itemObject) 
else 
	table.insert(CurrentTransaction.TradeItems, tradeIndex, itemObject) 
end

end

function TRADESMAN.TradeItemRemoved(eventCode, who, tradeIndex, itemSoundCategory)
   
--local name, quality, stack = GetTradeItemInfo(who, tradeIndex)
 
--d("Item Removed: who: " .. who .. " Trade index: " .. tradeIndex)
--d("Item:" .. name)
--d("Item Count:" .. stack)
--d("Item Quality:" .. quality)

	if who == TRADE_ME then
		table.remove(MyCurrentTradeItems, tradeIndex) 
	else 
		table.remove(CurrentTransaction.TradeItems, tradeIndex) 
	end
end

function TRADESMAN.TradeComplete(eventCode)

 local timeStampVar = GetTimeStamp()
	
 --d("Trade Completed")
 --d("Traded with: " .. CurrentTransaction.Name)
	if (not TRADESMAN.savedVariables.Transactions[CurrentTransaction.Name]) then
		TRADESMAN.savedVariables.Transactions[CurrentTransaction.Name] = { }
		TRADESMAN.savedVariables.Transactions[CurrentTransaction.Name].Trades = {}		
		TRADESMAN.savedVariables.Transactions[CurrentTransaction.Name].Notes = ""
	end
	--only set these if the values exist
	if CurrentTransaction.Class ~= "" and CurrentTransaction.Race ~= "" and CurrentTransaction.Alliance ~= "" then
		TRADESMAN.savedVariables.Transactions[CurrentTransaction.Name].Class = CurrentTransaction.Class
		TRADESMAN.savedVariables.Transactions[CurrentTransaction.Name].Race = CurrentTransaction.Race
		TRADESMAN.savedVariables.Transactions[CurrentTransaction.Name].Alliance = CurrentTransaction.Alliance
		TRADESMAN.savedVariables.Transactions[CurrentTransaction.Name].Level = CurrentTransaction.Level
	
		TRADESMAN.savedVariables.Transactions[CurrentTransaction.Name].Gender = CurrentTransaction.Gender
		TRADESMAN.savedVariables.Transactions[CurrentTransaction.Name].Veteranrank = CurrentTransaction.Veteranrank
	end
	   
	--init the AccountID to empty, we can update later
	if TRADESMAN.savedVariables.Transactions[CurrentTransaction.Name].AccountID == "" then
		TRADESMAN.savedVariables.Transactions[CurrentTransaction.Name].AccountID = ""	
	end	
		  
	  if (type(MyCoinGiven) == "number") then	
		local myCoinObject = {		
		 Coin = MyCoinGiven
		}  
		--d("my coin"..MyCoinGiven)
	    table.insert(MyCurrentTradeItems, myCoinObject) 
	 end
	 	 
	 if (type(TheirCoinGiven) == "number") then	
		local theirCoinObj = {		
		  Coin = TheirCoinGiven
		}  
		--d("their coin"..TheirCoinGiven)
		table.insert(CurrentTransaction.TradeItems, theirCoinObj) 
	 end
     local mySalesman = zo_strformat(SI_UNIT_NAME, GetUnitName("player"))
		
	 local thisTrade = {
			Date = timeStampVar,
			DisplayDate = GetDateStringFromTimestamp(timeStampVar),
			MyItems = MyCurrentTradeItems,
			TheirItems = CurrentTransaction.TradeItems,
			MyTrader = mySalesman,
			Zone = GetMapName()
		}
		--save trade data
		table.insert(TRADESMAN.savedVariables.Transactions[CurrentTransaction.Name].Trades, thisTrade) 

		--save new trader if needed
		local addNewTrader = true
		for k, v in pairs(TRADESMAN.savedVariables.MyTraders) do
			if v == mySalesman then 
			addNewTrader = false 
			break 
			end
		end
		if addNewTrader then 
			table.insert(TRADESMAN.savedVariables.MyTraders, mySalesman) 
		end
			
    --reset current vars
	ClearCurrentTradeItems()
end

function ClearCurrentTradeItems()
    CurrentTransaction.Name = ""
	CurrentTransaction.Gender = ""
	CurrentTransaction.Veteranrank = ""
	CurrentTransaction.Class = ""
	CurrentTransaction.Race = ""
	CurrentTransaction.Alliance = ""
	CurrentTransaction.Level = ""
	CurrentTransaction.TradeItems = {}
	MyCurrentTradeItems = {}
	MyCoinGiven = 0
    TheirCoinGiven = 0
end

function TRADESMAN.TradeFailed(eventCode, reason)
 --d("Trade Failed Reason: " .. reason)
end
function TRADESMAN.TradeCancelled(eventCode, cancelerName)
	 --d("Canceller Name: " .. cancelerName)  
	ClearCurrentTradeItems()
end
function TRADESMAN.TradeInviteAccepted(eventCode)	
	--d("Trade Invite Accepted")
	MyCurrentTradeItems = {}
end
function TRADESMAN.TradeInviteWaiting(eventCode, inviter)
 --d("Invited Considering: " .. inviter)   

	 
	 local playername = GetUnitName("reticleover") 
	 local reticleTargetName = zo_strformat(SI_UNIT_NAME, playername) 
	 local class = GetUnitClass("reticleover") 
	 --1=Dragon Knight, 2=Sorcerer, 3=Nightblade, 6=Templar
	 --local classId = GetUnitClassId(playername)
	 local level = GetUnitLevel("reticleover") 
	 local alliance = GetUnitAlliance("reticleover") 
	 local race = GetUnitRace("reticleover")  
	 local gender = GetUnitGender("reticleover") 
	 local veteranrank = GetUnitVeteranRank("reticleover") 
	 
	 local genderName
	 
	if gender == 2 then
	  genderName = "Male"
	else
	  genderName = "Female"
	end

	local currentCustomer = zo_strformat(SI_UNIT_NAME, inviter)
	--d(DecorateDisplayName(inviter))
	--only attempt to set the details if we have at least the class and race of the customer
	--this prevents clearing out the details after we already have it
	--make sure we are pointing at the person we are trading with.
	if class ~= "" and race ~= "" and reticleTargetName == currentCustomer then
	 CurrentTransaction.Gender = genderName
	 CurrentTransaction.Veteranrank = veteranrank
	 CurrentTransaction.Class = class
	 CurrentTransaction.Race = race
	 CurrentTransaction.Alliance = alliance 
	 CurrentTransaction.Level = level
	end

 CurrentTransaction.Name = currentCustomer
 --d( "inviter " .. currentCustomer)
end
function TRADESMAN.MoneyChanged(eventCode, who, money)
 --d("Money changed: " .. who.. " Money: " .. money)  
	if who == TRADE_ME then
		
		if money == 0 then
			MyCoinGiven = 0
		else
			MyCoinGiven = money  
		end			
	else     	
		if money == 0 then
			TheirCoinGiven = 0 
		else
			TheirCoinGiven = money  
		end
	end
end


function GetAllianceIconName(alliance)

	local returnValue = ""

	if alliance == ALLIANCE_ALDMERI_DOMINION then
		returnValue = "aldmeri"    
	elseif alliance == ALLIANCE_DAGGERFALL_COVENANT then
		 returnValue = "daggefall"  
	elseif alliance == ALLIANCE_EBONHEART_PACT then
		 returnValue = "ebonheart"  
	end

	return "/esoui/art/campaign/overview_allianceicon_" .. returnValue .. ".dds"
end

function GetClassIconName(class)
	
	local returnValue = ""
	
	class = string.lower(class)
	
	if class == "" then return returnValue end
		
	local isNB, _, _ = PlainStringFind(class, "night")
	local isSC, _, _ = PlainStringFind(class, "sorc")
	local isTP, _, _ = PlainStringFind(class, "temp")
	local isWard, _, _ = PlainStringFind(class, "ward")
	local isDK, _, _ = PlainStringFind(class, "dragon")
		
	if isDK then
		returnValue = "dragonknight"    
	elseif isNB then
		 returnValue = "nightblade"  
	elseif isSC then
		 returnValue = "sorcerer"  
	elseif isTP then
		 returnValue = "templar" 	
	elseif isWard then
		 returnValue = "warden" 	
	end

	returnValue = "/esoui/art/icons/class/class_" .. returnValue .. ".dds"
		
	return returnValue
	
end

function TRADESMAN.ChatCallback(eventCode, messageType, fromName, message, isFromCustomerService)
 
	--local playerName = zo_strformat(SI_UNIT_NAME, GetUnitName("player"))
	
--	if messageType == CHAT_CHANNEL_WHISPER  then
--			local category = GetChannelCategoryFromChannel(CHAT_CHANNEL_WHISPER)
--			d("CHAT_CHANNEL_WHISPER:"..tostring(category))	
--			d("messageType:"..tostring(messageType))				
--		end
	
--	if messageType == CHAT_CHANNEL_PARTY  then
--		
--	local category = GetChannelCategoryFromChannel(CHAT_CHANNEL_PARTY)
--		d("CHAT_CHANNEL_PARTY:"..tostring(category))
--		d("messageType:"..tostring(messageType))	
--	end
		
     if messageType == CHAT_CHANNEL_WHISPER and CurrentPlayerName ~= fromName then
		local pstPerson, isCustomer
		if not IsDecoratedDisplayName(fromName) then
			pstPerson = zo_strformat(SI_UNIT_NAME, fromName)	
		else 
			pstPerson = fromName
		end  
		
		--d(messageType)	
		--d(SearchedWhisperNames)
			--only check to see if the pst person is a customer the first message from them, display window and select if so.
			if not SearchedWhisperNames[pstPerson] then	
				local customerKeyName = "" 		
				SearchedWhisperNames[pstPerson] = {}		
				
				isCustomer = false
							
				table.insert(SearchedWhisperNames[pstPerson], pstPerson)
				--d("pst name added to list")
					
				--d(pstPerson.." - whispered you")	
				for charName, charValues in pairs(AllCustomerAccountIds) do
					local accountName = charValues.AccountID or ""
					local customerName = charValues.customerName or ""
					
					if(customerName == pstPerson or accountName == pstPerson) then
						isCustomer = true	
						customerKeyName = customerName
						--d("customer whisper you")
						break
					end			
				end	
				--d("pstPerson "..pstPerson)
				--d("is customer "..tostring(isCustomer))
										
				--try to find if not customer
				if not isCustomer then --and not SearchedWhisperNames[pstPerson]
				
					--d("searching trades for customer status")
					
					for charName, charValues in pairs(TRADESMAN.savedVariables.Transactions) do
						local accountName = charValues.AccountID or ""
						if(accountName == pstPerson) then
							isCustomer = true
							customerKeyName = charName
							--TRADESMAN.savedVariables.Transactions[CurrentTransaction.Name]
							local customerAccountIdInfo = { accountID = accountName, customerName = customerKeyName}
							--d(customerAccountIdInfo)
							AllCustomerAccountIds[customerKeyName] = {}						
							
							table.insert(AllCustomerAccountIds[customerKeyName], customerAccountIdInfo)
							break
						end				
					end					
				end	
											
				if isCustomer then
					if (TRADESMANWindow:IsHidden()) then 
						SetSelectedCustomerInfo(customerKeyName)
						SetGameCameraUIMode(true)	   
						TRADESMANWindow:SetHidden(false)
					end
					--d(pstPerson.." -  A customer just whispered you")
				end	

				
					
				else
					--d("pst name exists in list")
				end 			
		end
end
 
 function TRADESMAN.ShowPrimaryWindow()
    if (TRADESMANWindow:IsHidden()) then 
	    SetGameCameraUIMode(true)	   
        TRADESMANWindow:SetHidden(false) 	
		
		if TRADESMAN.savedVariables.OpenTradingHouseWithMainWindow then
			 TradingHousePurchasesWindow:SetHidden(false) 	
		end	
		--CENTER_SCREEN_ANNOUNCE:AddMessage(1, CSA_EVENT_SMALL_TEXT , nil, "A customer has whispered you", nil, nil, nil, nil, nil)
    else    
		SetGameCameraUIMode(false)		
        TRADESMANWindow:SetHidden(true)
		if TRADESMAN.savedVariables.OpenTradingHouseWithMainWindow then
			TradingHousePurchasesWindow:SetHidden(true)
		end		
    end
end

-- do all this when the addon is loaded
function TRADESMAN.OnAddOnLoaded(eventCode, addOnName)

	if addOnName ~= TRADESMAN.name then return end

		TRADESMAN.savedVariables = ZO_SavedVars:NewAccountWide("TRADESMANVars", 1, nil, TRADESMAN.Default)
			
		if TRADESMAN.savedVariables.TradeHistoryDays == nil then
			 TRADESMAN.savedVariables.TradeHistoryDays = 180
		end
		
		if TRADESMAN.savedVariables.TradingHousePurchases == nil then
			TRADESMAN.savedVariables.TradingHousePurchases = { }				
		end
	
		
	-- Register Keybinding
    ZO_CreateStringId("SI_BINDING_NAME_SHOWWINDOW_ESOCRM", "Toggle TRADESMAN")

	TRADESMAN.CreatePrimaryWindow()
	TRADESMAN.CreateOptionsWindow()
	TRADESMAN.CreateGuildStorePurchaseWindow()		
	--only hookup event if needed
	if TRADESMAN.savedVariables.ShowCustomerWindowPopup then
		--(integer eventCode, integer messageType, string fromName, string text)
		EVENT_MANAGER:RegisterForEvent(TRADESMAN.name, EVENT_CHAT_MESSAGE_CHANNEL, TRADESMAN.ChatCallback)
	end	

	--TODO: clear out trades older than the selected option.	
	
end

local tradeHouseItemPurchase = {}

function TRADESMAN.HouseResponseReceived(eventCode, responseType, result)  
	--d("responseType "..tostring(responseType))
	--d("result "..tostring(result))
	if responseType == TRADING_HOUSE_RESULT_PURCHASE_PENDING and result == TRADING_HOUSE_RESULT_SUCCESS then
		 -- d("You purchased a new item: "..tradeHouseItemName)
		 -- d("Item Link: "..tradeHouseItemLink)	
		 		 
		local timeStampVar = GetTimeStamp()

		local thisPurchase = {
		Date = timeStampVar,
		DisplayDate = GetDateStringFromTimestamp(timeStampVar),		
		ItemName = tradeHouseItemPurchase.ItemName,
		ItemStack = tradeHouseItemPurchase.Stack,
		ItemQuality = tradeHouseItemPurchase.Quality,
		ItemLink = tradeHouseItemPurchase.ItemLink,
		ItemSeller = tradeHouseItemPurchase.Seller,
		MyTrader = zo_strformat(SI_UNIT_NAME, GetUnitName("player")),
		Price = tradeHouseItemPurchase.Price,
		GuildName = tradeHouseItemPurchase.GuildName,
		ItemIcon = tradeHouseItemPurchase.Icon
		}
		--d(thisPurchase.ItemSeller)
		--zo_strformat(SI_UNIT_NAME, tradeHouseItemSellername) 		
		--save purchase data
		table.insert(TRADESMAN.savedVariables.TradingHousePurchases, thisPurchase) 
		  		  		  
	end
	
	
end

function TRADESMAN.HouseConfirmItemPurchase(eventcode,pendingPurchaseIndex)
	
	local guildId,guildName,guildAlliance = GetCurrentTradingHouseGuildDetails()	
	
  	local icon,itemName,quality, stack,sellerName,timeRemaining,purchasePrice = GetTradingHouseSearchResultItemInfo(pendingPurchaseIndex)
	local itemLink = GetTradingHouseSearchResultItemLink(pendingPurchaseIndex, LINK_STYLE_BRACKETS)
	
	tradeHouseItemPurchase.ItemLink = zo_strformat(SI_ITEM_FORMAT_STR_TEXT1, itemLink)
	tradeHouseItemPurchase.ItemName = zo_strformat("<<tx:1>>", itemLink)
	tradeHouseItemPurchase.Icon = icon
	tradeHouseItemPurchase.Quality = quality
	tradeHouseItemPurchase.Stack = stack
	tradeHouseItemPurchase.Seller = zo_strformat("<<tx:1>>", sellerName)
	tradeHouseItemPurchase.Price = purchasePrice
	tradeHouseItemPurchase.GuildName = guildName
	--d(guildName)
	--d(zo_strformat("<<tx:1>>", sellerName))
    
	--d("HouseConfirmItemPurchase")	
	--d("itemName "..tradeHouseItemName)
	--d("itemLink "..tradeHouseItemLink)
end

SLASH_COMMANDS["/tradesman"] = TRADESMAN.ShowPrimaryWindow
SLASH_COMMANDS["/tm"] = TRADESMAN.ShowPrimaryWindow
SLASH_COMMANDS["/tmguildstore"] = TRADESMAN.ShowGuildstorePurchaseWindow



--EVENT_TRADE_ITEM_ADDED (integer eventCode, integer who, integer tradeIndex, integer itemSoundCategory)
EVENT_MANAGER:RegisterForEvent(TRADESMAN.name, EVENT_TRADE_ITEM_ADDED, TRADESMAN.TradeItemAdded)
--EVENT_TRADE_ITEM_REMOVED (integer eventCode, integer who, integer tradeIndex, integer itemSoundCategory)
EVENT_MANAGER:RegisterForEvent(TRADESMAN.name, EVENT_TRADE_ITEM_REMOVED, TRADESMAN.TradeItemRemoved)
--EVENT_TRADE_SUCCEEDED (integer eventCode)
EVENT_MANAGER:RegisterForEvent(TRADESMAN.name, EVENT_TRADE_SUCCEEDED, TRADESMAN.TradeComplete)

--EVENT_TRADE_FAILED (integer eventCode, string reason)
EVENT_MANAGER:RegisterForEvent(TRADESMAN.name, EVENT_TRADE_FAILED, TRADESMAN.TradeFailed)
--EVENT_TRADE_CANCELED (integer eventCode, string cancelerName)
EVENT_MANAGER:RegisterForEvent(TRADESMAN.name, EVENT_TRADE_CANCELED, TRADESMAN.TradeCancelled)
--EVENT_TRADE_INVITE_ACCEPTED (integer eventCode)
EVENT_MANAGER:RegisterForEvent(TRADESMAN.name, EVENT_TRADE_INVITE_ACCEPTED, TRADESMAN.TradeInviteAccepted)

--integer eventCode, integer pendingPurchaseIndex)
EVENT_MANAGER:RegisterForEvent(TRADESMAN.name, EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE, TRADESMAN.HouseConfirmItemPurchase)

--integer eventCode, integer pendingPurchaseIndex)
EVENT_MANAGER:RegisterForEvent(TRADESMAN.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, TRADESMAN.HouseResponseReceived)




--(integer eventCode, string inviter)
EVENT_MANAGER:RegisterForEvent(TRADESMAN.name, EVENT_TRADE_INVITE_WAITING, TRADESMAN.TradeInviteWaiting)
--(integer eventCode, string inviter)
EVENT_MANAGER:RegisterForEvent(TRADESMAN.name, EVENT_TRADE_INVITE_CONSIDERING, TRADESMAN.TradeInviteWaiting)

--EVENT_TRADE_MONEY_CHANGED (integer eventCode, integer who, integer money)
EVENT_MANAGER:RegisterForEvent(TRADESMAN.name, EVENT_TRADE_MONEY_CHANGED, TRADESMAN.MoneyChanged)

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(TRADESMAN.name, EVENT_ADD_ON_LOADED, TRADESMAN.OnAddOnLoaded)


