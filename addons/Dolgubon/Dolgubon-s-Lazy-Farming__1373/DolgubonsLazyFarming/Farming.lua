
DolgubonFarming = {}

DolgubonFarming.default = {
	["craftBag"] = {[1] = "hi"},
	["length"] = 0,
	["start"] = 0,
	["end"] = 0,
	["saved"] = false,
	["retrievedItems"] = {},
	["saveRetrieval"] = false,
	["valueFilter"] = 0,
}
local total = 0
DolgubonFarming.version = 2
DolgubonFarming.name = "DolgubonsLazyFarming"
DolgubonFarming.paused = false
local savedVars = {}

local function out(text)
	DolgubonFarmingToolOutput:SetText(text)
end

function DolgubonFarming:Initialize()

	DolgubonFarming.savedVars = ZO_SavedVars:NewAccountWide("dolgubonsfarmingvars", DolgubonFarming.version, nil, DolgubonFarming.default)

		local buttonInfo = 
	{0,5000,50000, "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7CZ3LW6E66NAU&source=url",{"https://www.patreon.com/Dolgubon", "Patreon"}
	}
	local feedbackString = "If you found a bug, have a request or a suggestion, or simply wish to donate, send a mail. You can also donate through Paypal or on Patreon"
	if GetWorldName() == "NA Megaserver" then
		buttonInfo[#buttonInfo+1] = { function()JumpToSpecificHouse( "@Dolgubon", 36) end, "Visit Maze 1"}
		buttonInfo[#buttonInfo+1] = { function()JumpToSpecificHouse( "@Dolgubon", 9) end, "Visit Maze 2"}
		feedbackString = "If you found a bug, have a request or a suggestion, or simply wish to donate, send a mail. You can also check out my house, or donate through Paypal or on Patreon."
	end

	if LibFeedback then
		local showButton, feedbackWindow = LibFeedback:initializeFeedbackWindow(DolgubonFarming, "Dolgubon's Lazy Farmer",DolgubonFarmingTool, "@Dolgubon", 
		{BOTTOMRIGHT, DolgubonFarmingTool, BOTTOMRIGHT,-50,-50}, 
		buttonInfo, 
		feedbackString)
	end
	DolgubonFarmingToolValueFilterInput:SetText(DolgubonFarming.savedVars["valueFilter"])

end


local function saveBag ()
	local craftBag = {}
	local i = 1
	if HasCraftBagAccess() then
		for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do  
			craftBag[i] = {["name"] = data.name, ["quantity"] = data.stackCount,}
			i = i+1
		end
	end
	DolgubonFarming.savedVars.craftBag = craftBag
	DolgubonFarming.savedVars.saved = true
	DolgubonFarming.savedVars.retrievedItems = {}
	DolgubonFarming.savedVars.startTime = GetTimeStamp()
	out("Craft bag has been saved. While it will work without doing so,\nit is suggested that you /reloadui, and back up the saved variables file.")
end

local function findItem(data)
	for i = 1, #DolgubonFarming.savedVars.craftBag do
		if data.name == DolgubonFarming.savedVars.craftBag[i]["name"] then
			if data.stackCount > DolgubonFarming.savedVars.craftBag[i]["quantity"] then
				return true, data.stackCount - DolgubonFarming.savedVars.craftBag[i]["quantity"]
			else
				return false, 0
			end
		end
	end
	return true, data.stackCount
end



local function getPrice(itemLink)
	
	if LibPrice then 
		local price  = LibPrice.ItemLinkToPriceGold(itemLink)
		if price then
			return price, false
		end
	end
	if MasterMerchant then
		local itemID = tonumber(string.match(itemLink, '|H.-:item:(.-):'))
		local itemIndex = MasterMerchant.makeIndexFromLink(itemLink)
		local price = MasterMerchant:toolTipStats(itemID, itemIndex, true, nil, false)['avgPrice']
		if price then
			return price, false
		end 
	end
	if TamrielTradeCentrePrice then
		local t = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
		if t and t.SuggestedPrice then
			return t.SuggestedPrice, false
		end
	end
	local default =GetItemLinkValue(itemLink)
	return default, true
end
local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end
local showTotal = false
local function endFarming (withdrawItems)
	
	if DolgubonFarming.savedVars.saved then	
		local movedOne = false
		if HasCraftBagAccess() then
			for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do 
				local move, amount = findItem(data)
				local itemLink = GetItemLink(BAG_VIRTUAL, data.slotIndex, 0)
				local unitPrice, wasDefaultPrice = getPrice(itemLink)
				local price = unitPrice * amount
				if type(tonumber(DolgubonFarming.savedVars["valueFilter"])) == "number" and tonumber(DolgubonFarming.savedVars["valueFilter"])>unitPrice then
					d("Skipped "..itemLink.." since price of "..unitPrice.." is less than filter price ("..tonumber(DolgubonFarming.savedVars["valueFilter"])..")")
				else
					
					if withdrawItems then
						amount = math.min(200, amount)
						price = unitPrice * amount
					end
					if move then
						local emptySlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
						if emptySlot then
							if not movedOne then
								
								total = price + total
								price = round(price, 2)
								if withdrawItems then
									if IsProtectedFunction("RequestMoveItem") then
										CallSecureProtected("RequestMoveItem", BAG_VIRTUAL, data.slotIndex,BAG_BACKPACK,emptySlot,amount)
									else
										RequestMoveItem(BAG_VIRTUAL, data.slotIndex, BAG_BACKPACK,emptySlot,amount)
									end
								end
								if not wasDefaultPrice then
									showTotal = true
									if withdrawItems then
										d("Dolgubon's Farming Tool retrieved "..tostring(amount).." "..itemLink..", valued at "..price)
									else
										d("Dolgubon's Farming Tool: You farmed "..tostring(amount).." "..itemLink..", valued at "..price)
									end
								else
									if withdrawItems then
										d("Dolgubon's Farming Tool retrieved "..tostring(amount).." "..itemLink..".")
									else
										d("Dolgubon's Farming Tool: You farmed "..tostring(amount).." "..itemLink..".")
									end
								end
								if DolgubonFarming.savedVars.saveRetrieval then
									table.insert(DolgubonFarming.savedVars.retrievedItems, {["name"] = GetItemLinkName(itemLink),["amount"] = amount, ["price"] = price/amount, ["type"] = {GetItemLinkItemType(itemLink)},})
								end
								if withdrawItems then
									zo_callLater(function() endFarming(withdrawItems) end,500)
									movedOne = true 
									return true
								end
							end
						else
							d("You do not have enough inventory space to retrieve all items. Please make some more space, then select 'Get Items' again.")
							return true
						end
					end
				end
			end
		end
	end
	if not showTotal and not withdrawItems and total > 0  then
		d("You didn't retrieve items, but there is no pricing addon turned on!")
	end
	total = math.floor(total+0.5)
	if showTotal then
		d("Dolgubon's Lazy Farmer has retrieved or listed all items, valued at "..total.."g.")
	else
		d("Dolgubon's Lazy Farmer has retrieved or listed all items.")
	end
	local currentTime = GetTimeStamp()
	local timeFarming = currentTime - DolgubonFarming.savedVars.startTime
	d("Your farm took "..math.floor(timeFarming/3600).." hours "..math.floor((timeFarming%3600)/60).." minutes and "..(timeFarming%60).." seconds")

	total = 0

end

--not actually implemented atm, still working the kinks out.
local function pauseFarming ()
	if DolgubonFarming.paused then
		DolgubonFarmingToolPauseFarming:SetText("Pause Farming")
		local craftBag = DolgubonFarming.savedVars.craftBag
		for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do
			local place
			for i = 1, #craftBag do
				if data.name == craftBag[i]["name"] then
					place = i
					craftBag[i]["quantity"] = data.stackCount - craftBag[i]["paused"]+craftBag[i]["quantity"]
				end
			end
		end
		DolgubonFarming.paused = false
	else
		DolgubonFarmingToolPauseFarming:SetText("Resume Farming")
		DolgubonFarming.paused = true
		local craftBag = DolgubonFarming.savedVars.craftBag
		if HasCraftBagAccess() then
			for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do
				local saved = false
				for j = 1, #craftBag do
					if data.name == craftBag[j]["name"] then
						craftBag[j]["paused"] = data.stackCount
						saved = true
					end
				end
				if not saved then
					craftBag[#craftBag+1] = {["name"] = data.name, ["quantity"] = 0, ["paused"] = data.stackCount,}
				end
			end
		end
		DolgubonFarming.savedVars.craftBag = craftBag
	end
end

local function closeWindow ()

	DolgubonFarmingTool:SetHidden(not DolgubonFarmingTool:IsHidden())

end



DolgubonFarming.endFarming = endFarming 
DolgubonFarming.save = saveBag
DolgubonFarming.pauseFarming = pauseFarming
DolgubonFarming.close = closeWindow

local function slashcommand (input)
	closeWindow()
end

SLASH_COMMANDS["/dft"] = slashcommand
SLASH_COMMANDS["/dolgubonfarmingtool"] = slashcommand
SLASH_COMMANDS["/dolgubonfarming"] = slashcommand
SLASH_COMMANDS["/farmingtool"] = slashcommand
SLASH_COMMANDS["/dftretrievesavetoggle"] = function() d("Allretrieved items will now be saved") DolgubonFarming.savedVars.saveRetrieval = not DolgubonFarming.savedVars.saveRetrieval end


function DolgubonFarming.OnAddOnLoaded(event, addonName)
	
  if addonName == DolgubonFarming.name then
    DolgubonFarming:Initialize()
    closeWindow()
  end
end 




EVENT_MANAGER:RegisterForEvent(DolgubonFarming.name, EVENT_ADD_ON_LOADED, DolgubonFarming.OnAddOnLoaded)