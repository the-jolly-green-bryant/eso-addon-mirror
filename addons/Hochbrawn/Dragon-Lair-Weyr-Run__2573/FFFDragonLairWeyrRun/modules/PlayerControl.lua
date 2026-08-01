local dlwr = FFFDragonLairWeyrRun
local classes = dlwr.classes

	
--local wm = GetWindowManager()


classes.PlayerControl = ZO_Object:Subclass()

local bagCache = {
	[BAG_BANK] = { lastIndex = 0, startIndex = -1 },
    [BAG_SUBSCRIBER_BANK] = {lastIndex = 0, startIndex = -1},
    [BAG_BACKPACK] = {},
    [BAG_GUILDBANK] = {lastIndex = nil, startIndex = nil},
    [BAG_VIRTUAL] = {lastIndex = nil, startIndex = nil}
}

local function GetMMValue(itemLink)
	if MasterMerchant ~= nil then
		local mmValue = MasterMerchant:itemStats(itemLink)["avgPrice"]
		if mmValue ~= nil then
			return mmValue
		end
	end
	
	if ArkadiusTradeTools ~= nil then
		local mmValue = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(itemLink)
		if mmValue ~= nil then
			return mmValue
		end
	end
	
	local _, vendorValue = GetItemLinkInfo(itemLink)
	if vendorValue ~= nil then 
		return vendorValue
	else 
		return 0
	end

	
end

function classes.PlayerControl:New(...)
    local controller = ZO_Object.New(self)
    controller:Init(...)
    return controller
end

function classes.PlayerControl:Init(index, scale)
    self.name = dlwr.name.."PlayerControl"..index
	self.wm = GetWindowManager()
	self.pc = nil
	self.BarMax = nil
	self.BarValue = {}
	self.BarGraph = {}
	self.pname = index
	self.playerName = ""
	-- AllValuedLoot is any type of loot that was desired
	self.AllValuedLoot = ItemList:New()
	-- CraftBagLoot holds key value of itemId, quantity stored in craftbag 
	self.CraftBagLoot = {}
	-- Guild Bank Deposited LootList
	self.GuildBankDeposits = ItemList:New()

	--self.LootList = {}
	self.BarMaxValue = 100
	self.BarMaxList ={100,200,500,1000,2000,5000,10000,20000,50000,100000,200000,500000,1000000,2000000,5000000,10000000}
    self.ControlScale = scale
	
		
	self:CreateControl(index,self.ControlScale)
	
end

function classes.PlayerControl:AddToMain(TLW, left, top)
	-- setting anchor to provided control at TOPLEFT (left, top)
	self.pc:ClearAnchors()
	self.pc:SetAnchor(TOPLEFT, TLW, TOPLEFT, left,top)
end

function classes.PlayerControl:InitPlayer(playername)
	self.playerName = playername
	-- set values back to zero/default
	-- AllValuedLoot is any type of loot that was desired
	self.AllValuedLoot = ItemList:New()
	-- CraftBagLoot holds key value of itemId, quantity stored in craftbag 
	self.CraftBagLoot = {}
	-- Guild Bank Deposited LootList
	self.GuildBankDeposits = ItemList:New()
	self.BarValue = {}
	self.BarMaxValue = 100
	-- reset bar graphs
	self.BarMax:SetText("Max = "..self.BarMaxValue)
	for i = 1,8 do
		self.BarGraph[i]:SetValue(0)
		self.BarGraph[i]:SetMinMax(0,self.BarMaxValue)
	end
	
	-- set labels
	self.lblPlayerName:SetText(playername)
	self.lblTotalValue:SetText("0".." g")
	-- show control
	self.pc:SetHidden(false)
	
end

function classes.PlayerControl:Show()
	self.pc:SetHidden(false)
end

function classes.PlayerControl:Hide()
	self.pc:SetHidden(true)
end


function classes.PlayerControl:CreateControl(index,scale)
	
	-- create a top level Control and put it on the group window 
	self.pc = self.wm:CreateTopLevelWindow("FFFDragonLairWeyrRunPlayerControl" ..index )
	self.pc:SetDimensions(80*scale,156*scale)
	self.pc:SetResizeToFitDescendents(true)
	
	
	-- Set anchor will need updating when inserted by main lua
	self.pc:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 5,5)
	local font = "ZoFontGameSmall"
	if index == "Dragon 25" then 
		font = "ZoFontGameLarge"
	end
	local numberBars = 8
	local barColors = {
	[1] = {R = 0.447, G= 0.490, B = 1.000},
	[2] = {R = 0.588, G= 0.988, B = 1.000},
	[3] = {R = 1.000, G= 0.694, B = 0.494},
	[4] = {R = 0.867, G= 0.929, B = 0.969},
	[5] = {R = 0.557, G= 1.000, B = 0.541},
	[6] = {R = 1.000, G= 0.455, B = 0.478},
	[7] = {R = 1.000, G= 0.404, B = 0.000},
	[8] = {R = 0.627, G= 0.204, B = 0.988}
	}
	
	local PlayerBackDrop = self.wm:CreateControl("FFFDragonLairWeyrRunPlayerBackDrop"..index, self.pc, CT_BACKDROP)
	PlayerBackDrop:SetDimensions(80*scale,156*scale)
	PlayerBackDrop:SetEdgeColor(.996,.867,.678,.9)
	PlayerBackDrop:SetEdgeTexture("",1,1,2,0) 
	--SetEdgeTexture(string filename, number edgeFileWidth, number edgeFileHeight, number edgeSize, number edgeFilePadding)
	PlayerBackDrop:SetCenterColor(0.0,0.0,0.0)
	PlayerBackDrop:SetAnchor(TOPLEFT, self.pc, TOPLEFT,0,0)
	PlayerBackDrop:SetAlpha(0.4)
	PlayerBackDrop:SetDrawLayer(0)
	-- Add Bar Max value readout
	self.BarMax = self.wm:CreateControl("FFFDragonLairWeyrRunlblBarMax"..index, self.pc, CT_LABEL)
	self.BarMax:SetColor(.996,.867,.678,.9)
	self.BarMax:SetFont(font)
	self.BarMax:SetScale(1)
	self.BarMax:SetDimensions(75*scale,10*scale)
	self.BarMax:SetText("Max = "..self.BarMaxValue)
	self.BarMax:SetAnchor(TOPLEFT, self.pc, TOPLEFT,2*scale,1*scale)
	self.BarMax:SetDrawLayer(1)
	-- build bars
	for i = 1,8 do
		local tl = (1 + (i-1)*10)*scale
		self.BarGraph[i] = self.wm:CreateControl("FFFDragonLairWeyrRun"..i..index, self.pc, CT_STATUSBAR)
		self.BarGraph[i]:SetOrientation(ORIENTATION_VERTICAL)
		self.BarGraph[i]:SetMinMax(0,100)
		self.BarGraph[i]:SetDimensions(8*scale,100*scale)
		self.BarGraph[i]:SetColor(barColors[i].R,barColors[i].G,barColors[i].B)
		self.BarGraph[i]:SetAlpha(.6)
		self.BarGraph[i]:SetAnchor(TOPLEFT, self.pc, TOPLEFT, tl,14*scale)
		self.BarGraph[i]:SetDrawLayer(1)
	end
	
	-- setup labels that will be updated
	self.lblPlayerName = self.wm:CreateControl("FFFDragonLairWeyrRunlblPlayerName"..index, self.pc, CT_LABEL)
	self.lblPlayerName:SetColor(.996,.867,.678,.9)
	self.lblPlayerName:SetFont(font)
	self.lblPlayerName:SetScale(1)
	self.lblPlayerName:SetDimensions(75*scale,15*scale)
	self.lblPlayerName:SetText(index)
	self.lblPlayerName:SetAnchor(TOPLEFT, self.pc, TOPLEFT,2*scale,117*scale)
	self.lblPlayerName:SetDrawLayer(1)
	self.lblPlayerName:SetMouseEnabled(true)
	
	--
	self.lblTotalValue = self.wm:CreateControl("FFFDragonLairWeyrRunlblTotalValue"..index, self.pc, CT_LABEL)
	self.lblTotalValue:SetColor(.996,.867,.678,.9)
	self.lblTotalValue:SetFont(font)
	self.lblTotalValue:SetScale(1)
	self.lblTotalValue:SetDimensions(75*scale,15*scale)
	self.lblTotalValue:SetText("0 ".."g")
	self.lblTotalValue:SetAnchor(TOPLEFT, self.pc, TOPLEFT,2*scale,137*scale)
	self.lblTotalValue:SetDrawLayer(1)
	
	-- and hide until needed
	self.pc:SetHidden(true)
	
end 	


local function FindEmptySlotInBag(targetBag)
	-- I got this from the FarmManager Addon.  Credit to @dirtdart
    if targetBag == BAG_GUILDBANK then
        bagCache[targetBag].startIndex = GetNextGuildBankSlotId(bagCache[targetBag].startIndex)
    elseif targetBag == BAG_VIRTUAL then
        bagCache[targetBag].startIndex = GetNextVirtualBagSlotId(bagCache[targetBag].startIndex)
    elseif targetBag == BAG_BACKPACK then
        for slotIndex = 0, (GetBagSize(targetBag) - 1) do
            if not SHARED_INVENTORY.bagCache[targetBag][slotIndex] and not bagCache[targetBag][slotIndex] then
                bagCache[targetBag][slotIndex] = true
                return slotIndex
            end
        end
    else
        if bagCache[targetBag].lastIndex == 0 then bagCache[targetBag].lastIndex = GetBagSize(targetBag) - 1 end
        if bagCache[targetBag].startIndex < bagCache[targetBag].lastIndex then 
            bagCache[targetBag].startIndex = bagCache[targetBag].startIndex + 1 
        else
            bagCache[targetBag].startIndex = nil
        end
    end
    return bagCache[targetBag].startIndex
end

function classes.PlayerControl:MoveItemToBackpack(ItemToMoveId, QuantityToMove)
	-- move a specific item and quantity to backpack
	if not HasCraftBagAccess() then return end
	local craftbag = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_VIRTUAL)
	if craftbag == nil then return end
	local CraftBagLootQuantity = self.CraftBagLoot[ItemToMoveId]
	
	for _, slotdata in pairs(craftbag)  do
		local itemLink = GetItemLink(BAG_VIRTUAL, slotdata.slotIndex)
		local cbItemId = GetItemLinkItemId(itemLink)
		if cbItemId == ItemToMoveId then
			-- found item so move quantity to backpack
			--d("found item in eso craftbag")
			local destSlot = FindEmptySlotInBag(BAG_BACKPACK)
			local cbQuanity = GetSlotStackSize(BAG_VIRTUAL, slotdata.slotIndex)
			if destSlot ~= nil then
				if cbQuanity < QuantityToMove then
					QuantityToMove = cbQuanity
				end
				CallSecureProtected("RequestMoveItem", BAG_VIRTUAL, slotdata.slotIndex, BAG_BACKPACK, destSlot,QuantityToMove)
				local QuantityRemainingInLoot = CraftBagLootQuantity - QuantityToMove
				-- reduce craftbagLoot list by amount moved as normal
				self.CraftBagLoot[cbItemId] = QuantityRemainingInLoot
				-- if the last one removed from list then remove by setting to nil
				if QuantityRemainingInLoot == 0 then
					self.CraftBagLoot[cbItemId] = nil
				end
				return destSlot
			end
		end
	end
	return nil
end



function classes.PlayerControl:MoveToBackpack()
	-- I used FarmManager to figure this out and a lot of self trials.
	if not HasCraftBagAccess() then return end
	local craftbag = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_VIRTUAL)
	if craftbag == nil then return end
	
	for _, slotdata in pairs(craftbag) do
		-- get items in slot of craft bag to get its itemlink and itemId
		-- Note: ItemLinks from a craftbag and from a looted item differ but the ID's are the same that is why you can not compare based on link
		--craftbag lady smock link
		--|H0:item:30158:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
		--lootlist lady smock link
		--|H0:item:30158:31:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
		local itemLink = GetItemLink(BAG_VIRTUAL, slotdata.slotIndex)
		local cbItemId = GetItemLinkItemId(itemLink)
		local itemQuantity = self.CraftBagLoot[cbItemId]
		-- check if itemLink matches item in CraftBagLoot
		-- if an item exists in the list with that itemId then CraftBagLoot is not nil.
		
		if itemQuantity ~=nil then
			-- move it to the backpack
			
			--local destSlot = FindEmptySlotInBag(BAG_BACKPACK)
			local destSlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
			
			if destSlot ~= nil then
			-- the move is a protected function so needs special call
			-- this does not check (yet) if the quantity in the craftbag is >= itemQuantity
			-- and will move the item in the slotindex of the virtual(craft)bag to the destination slot of the backpack.  
			-- note quantity greater than 200 will only move 200 at a time as that is the max for the backpack bagslot.
				if IsProtectedFunction("RequestMoveItem") then
					CallSecureProtected("RequestMoveItem", BAG_VIRTUAL, slotdata.slotIndex, BAG_BACKPACK, destSlot,itemQuantity)
				else
					RequestMoveItem(BAG_VIRTUAL, slotdata.slotIndex, BAG_BACKPACK,destSlot,itemQuantity)
				end
				--see how many got transfered.
				-- https://wiki.esoui.com/RequestMoveItem
				-- transfer does not complete instantly.  So unable to know how many transfered. Typical max for craft bag to backpack transfer is 200 so hardcoding here for now until it can be figured out.
				
				if itemQuantity > 200 then
					-- only the max for the destination slot will have moved 
					-- reduce looteditem quantity by the max
					itemQuantity = itemQuantity - 200
					self.CraftBagLoot[cbItemId] = itemQuantity
					-- should set a flag that you need to transfer again. or have transfer continue until all quantities are 0.
				else
					-- if not a full stack then full looted quantity was transfered.
					-- or reduced by the quantity available.
					itemQuantity = 0
					self.CraftBagLoot[cbItemId] = nil
					
				end
				-- Problem is that loop executes and nil's out craft items before move is completed.
				-- need to rewrite to monitor for inventory update.
			else
				d("No space left in backpack, make room and try again")
			end
			
		end
	end
end 

function classes.PlayerControl:SubtractFromAllValuedLoot(itemId, quantity)
	local itemRemoved = self.AllValuedLoot:Subtract(itemId, quantity)
	local groupTotal = self.AllValuedLoot:ItemListTotal()
	self.lblTotalValue:SetText(math.floor(groupTotal).." g")
	return itemRemoved
end

function classes.PlayerControl:SubtractFromCraftBagLoot(itemId, quantity)
	local craftbagCount = self.CraftBagLoot[itemId]
	if craftbagCount ~= nil then
		if craftbagCount - quantity <= 0 then
			self.CraftBagLoot[itemId] = nil
		else
			self.CraftBagLoot[itemId] = craftbagCount - quantity
		end
	end
	
end



function classes.PlayerControl:AddToAllValuedLoot(itemName, quantity, bar)
	-- added valued item to lootedlist (note LootedLoot is an ItemList)
	local item = self.AllValuedLoot:Add(itemName, quantity, bar)
	-- item has value of item and a total value of items farmed for the player
	-- LootMainWindow needs to update the item and the group total value farmed.

	local groupTotal = self.AllValuedLoot:ItemListTotal()
	--classes.LootMainWindow:OnItemFarmed(item,groupTotal)
	
	self.lblTotalValue:SetText(math.floor(groupTotal).." g")
	return item
end

function classes.PlayerControl:AddToCraftBagLoot(itemName, quantity)
	-- add ItemId and quantity of itemName
	-- note that the craftbagLoot is only for Me (players[1])
	local itemId = GetItemLinkItemId(itemName)
	local itemQuantity = self.CraftBagLoot[itemId]
	if itemQuantity == nil then
		-- need to add it to list
		self.CraftBagLoot[itemId] = quantity
	else
		-- item exists need to increase quantity
		self.CraftBagLoot[itemId] = itemQuantity + quantity
	end
end

function classes.PlayerControl:AddToGuildBankDeposits(itemName, quantity, bar)
	-- added valued item to GuildBankDeposits (note GuildBankDeposits is an ItemList)
	local item = self.GuildBankDeposits:Add(itemName, quantity, bar)
	-- item has value of item and a total value of items farmed for the player
	
	return item
end

function classes.PlayerControl:IsCraftBagLootEmpty()
	-- when transfering to backpack the max is limited to the bag slot max of 200.
	-- so need to loop over list until empty.  This checks if empty.
	local cbl = self.CraftBagLoot
		
	if next(cbl) == nil then
		-- ie starting at the beginning if the next item in the list is not there so empty
		return true
	else 
		return false
	end

end


function classes.PlayerControl:UpdateBar(item)
	local BarToUpdate = item.bar
	local itemValue = item.incrementValue
	if self.BarValue[BarToUpdate] == nil then
		self.BarValue[BarToUpdate] = 0
	end
	self.BarValue[BarToUpdate] = self.BarValue[BarToUpdate] + itemValue
	if self.BarValue[BarToUpdate] < 0 then self.BarValue[BarToUpdate] = 0 end
	-- may want to have the max reduce when items are removed but not done at this time.
	local bot,top = self.BarGraph[BarToUpdate]:GetMinMax()
	if self.BarValue[BarToUpdate] > top then
		for _,value in pairs(self.BarMaxList) do
			if value > self.BarValue[BarToUpdate] then
				self.BarMax:SetText("Max = "..value)
				for key, barGraph in pairs(self.BarGraph) do
					self.BarGraph[key]:SetMinMax(0,value)
				end
				break
			end
		end
	end
	self.BarGraph[BarToUpdate]:SetValue(self.BarValue[BarToUpdate])
	
end



