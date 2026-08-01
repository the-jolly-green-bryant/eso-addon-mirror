WinterQueensSurveyBanker = {
	name = "WinterQueensSurveyBanker",
}

local GS = GetString
local myZoneName = ""
local rawZoneName = ""
local depositOther = false
local lastZone = 0
local currentZone = 0
local currentCharData = {}
local hookedToPA = false
local arrows = {
	[false] = "|c7be4bc→|r",
	[true] = "|ce48b7b←|r",
}

local specialNames = {
	[104] = "alik'r",
	[1286] = "deadlands",
	[1161] = "graumoorkaverne",
}

local function checkItem(bagId, slotId)
	local myLink = ""
	myLink = GetItemLink(bagId, slotId)
	local itemType, specialItemType = GetItemLinkItemType(myLink)
	if itemType == ITEMTYPE_TROPHY and specialItemType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT or specialItemType == SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP then
		local itemName = string.lower(zo_strformat("<<C:1>>", GetItemLinkName(myLink)))
		local isForThisZone = false
		if string.find(itemName, string.lower(myZoneName)) or
			string.find(rawZoneName, "%^") and string.find(itemName, string.lower(string.sub(rawZoneName, 1, string.find(rawZoneName, "%^")-1))) or
			specialNames[currentZone] and string.find(itemName, specialNames[currentZone]) then
				isForThisZone = true 
		end
		if (isForThisZone and not depositOther) or (depositOther and not isForThisZone) then 
			local stackCountBackpack, stackCountBank = GetItemLinkStacks(myLink)
			if specialItemType == SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP and 
				((depositOther and stackCountBank > 0) or (stackCountBackpack > 0 and not depositOther)) then
					return false
			end
			return myLink 
		end
	end
	return false
end
	

local function takeBankItems()
	
	local myPosition = 1
	local myCount = 0
	local myCountBack = 0
	local theSource = BAG_BANK
	depositOther = false
	local myZone = GetUnitWorldPosition("player")
	local myZoneTries = 0
	while GetParentZoneId(myZone) ~= myZone and myZoneTries < 42 do
		myZone = GetParentZoneId(myZone)
		myZoneTries = myZoneTries + 1
	end
	rawZoneName = GetZoneNameById(myZone)
	myZoneName = zo_strformat("<<C:1>>", rawZoneName)
	currentZone =  myZone
	if myZoneName == "" then return end

	
	for slotIt=0, GetBagSize(BAG_BANK) do
		if checkItem(BAG_BANK, slotIt) then myCount = myCount + 1 end
	end
	for slotIt=0, GetBagSize(BAG_SUBSCRIBER_BANK) do
		if checkItem(BAG_SUBSCRIBER_BANK, slotIt) then myCount = myCount + 1 end
	end
	depositOther = true
	for slotIt=0, GetBagSize(BAG_BACKPACK) do
		if checkItem(BAG_BACKPACK, slotIt) then myCountBack = myCountBack + 1 end
	end
	depositOther = false
	if myCount > 0 then d(string.format(GS(WinterQueensSurveyBanker_Transferring), myZoneName)) end
	local function transferItem(sourceSlot, destBag)
		local destSlot = FindFirstEmptySlotInBag(destBag)
		local _, stackSize = GetItemInfo(theSource, sourceSlot)
		if not destSlot then return false end
		if IsProtectedFunction("RequestMoveItem") then
			CallSecureProtected("RequestMoveItem", theSource, sourceSlot, destBag, destSlot, stackSize)
		else
			RequestMoveItem(theSource, sourceSlot, destBag, destSlot, stackSize)
		end
		return true
	end
	
	local  function transferNext()
		for slotIt=0, GetBagSize(theSource) do
			local myLink = checkItem(theSource, slotIt)
			if myLink then
				local _, stackSize = GetItemInfo(theSource, slotIt)
				if stackSize > 1 then myLink = string.format("%s(%sx)", myLink, stackSize) end
				d(string.format(GS(WinterQueensSurveyBanker_XoutofY), arrows[depositOther], myPosition, myCount, myLink))
				myPosition = myPosition + 1
				local destBag = BAG_BACKPACK
				if depositOther then destBag = BAG_BANK end
				local inventoryFull = false
				if not transferItem(slotIt, destBag) then 
					if depositOther and destBag == BAG_BANK then
						destBag = BAG_SUBSCRIBER_BANK
						if not transferItem(slotIt, destBag) then
							d(GS(WinterQueensSurveyBanker_NotEnoughSpace)) 
							inventoryFull = true
						end
					else
						d(GS(WinterQueensSurveyBanker_NotEnoughSpace))
						inventoryFull = true
					end
				end
				if not inventoryFull then
					local myTries = 1
					local function checkSlot(myTries)
						myTries = myTries + 1
						zo_callLater(function()
							if GetItemId(theSource, slotIt) ~= 0 then
								if myTries < 20 and GetInteractionType() == INTERACTION_BANK then 
									checkSlot(myTries) 
								else
									d(GS(WinterQueensSurveyBanker_TransferFail))
								end
							else
								transferNext()
							end
						end, 50)
					end
					checkSlot(myTries)
				end
				return
			end
		end
		-- the next code is only executed if nothing was found
		if theSource == BAG_BANK then 
			theSource = BAG_SUBSCRIBER_BANK 
			transferNext() 
		elseif theSource == BAG_SUBSCRIBER_BANK then 
			if myCountBack == 0 then return end
			theSource = BAG_BACKPACK 
			d(string.format(GS(WinterQueensSurveyBanker_Depositing), myZoneName))
			depositOther = true 
			myPosition = 1 
			myCount = myCountBack 
			transferNext() 
		end
	end
	transferNext()
	
end

local function autoBank()
	if not currentCharData.autoBank then return end
	if PersonalAssistant and PersonalAssistant.Banking then
		if not hookedToPA then
			ZO_PostHook(PersonalAssistant.Banking, "println", 
				function(theString) 
					if currentCharData.autoBank and theString == SI_PA_CHAT_BANKING_FINISHED then 
						if GetInteractionType() ~= INTERACTION_BANK then return end
						WinterQueensSurveyBanker.wqsb() 
					end
				end)
			hookedToPA = true
		end
	else
		takeBankItems()
	end	
end

function WinterQueensSurveyBanker.wqsb()
	if GetInteractionType() == INTERACTION_BANK then takeBankItems() return end
end
	
function WinterQueensSurveyBanker.OnAddonLoaded(event, addonName)
	if addonName == WinterQueensSurveyBanker.name then
		WinterQueensSurveyBanker:Initialize()
	end
end

function WinterQueensSurveyBanker.OnPlayerActivated(_, initialLogin)
	if not currentCharData.remindMe then return end
	if initialLogin then
		zo_callLater(function() WinterQueensSurveyBanker.OnPlayerActivated() end, 4200)
		return
	end
	local myZone = GetUnitWorldPosition("player")
	if myZone == lastZone then return end
	if myZone ~= GetParentZoneId(myZone) then return end
	lastZone = myZone
	rawZoneName = GetZoneNameById(myZone)
	myZoneName = zo_strformat("<<C:1>>", rawZoneName)
	currentZone = myZone
	
	depositOther = false
	local myCount = 0
	for slotIt=0, GetBagSize(BAG_BANK) do
		if checkItem(BAG_BANK, slotIt) then 
			local _, stackSize = GetItemInfo(BAG_BANK, slotIt)
			myCount = myCount + stackSize 
		end
	end
	for slotIt=0, GetBagSize(BAG_SUBSCRIBER_BANK) do
		if checkItem(BAG_SUBSCRIBER_BANK, slotIt) then 
			local _, stackSize = GetItemInfo(BAG_SUBSCRIBER_BANK, slotIt)
			myCount = myCount + stackSize 
		end
	end
	if myCount > 0 then
		d(zo_strformat(GS(WinterQueensSurveyBanker_GoToBank), myCount, GetZoneNameById(myZone)))
	end
end


function WinterQueensSurveyBanker:Initialize()
	local serverName = GetWorldName()
	WinterQueensSurveyBanker.sV = ZO_SavedVars:NewAccountWide("WQSBSavedVariables", 1, nil, {}, serverName) -- account wide
	local currentCharId = GetCurrentCharacterId()
	WinterQueensSurveyBanker.sV.charData = WinterQueensSurveyBanker.sV.charData or {}
	WinterQueensSurveyBanker.sV.charData[currentCharId] = WinterQueensSurveyBanker.sV.charData[currentCharId] or {}
	currentCharData = WinterQueensSurveyBanker.sV.charData[currentCharId]
	currentCharData.autoBank = currentCharData.autoBank or false
	currentCharData.remindMe = currentCharData.remindMe or false
	
	local panelData = {
		type = "panel",
		name = "Winterqueen's Survey Banker",
		displayName = "|c7be4bcWinterqueen|r's Survey Banker", 
		registerForRefresh = true,
    }

	local optionsData = {
		{
			type = "checkbox",
			name = GS(WinterQueensSurveyBanker_RemindMe),
			width = "full",
			default = 0,
			getFunc = function() return currentCharData.remindMe end,
			setFunc = function(value) 
				currentCharData.remindMe = value 
				if value then
					EVENT_MANAGER:RegisterForEvent(WinterQueensSurveyBanker.name.."OnActivated",  EVENT_PLAYER_ACTIVATED, WinterQueensSurveyBanker.OnPlayerActivated)
				else
					EVENT_MANAGER:UnregisterForEvent(WinterQueensSurveyBanker.name.."OnActivated",  EVENT_PLAYER_ACTIVATED)
				end
			end,
		},
		{
			type = "checkbox",
			name = GS(WinterQueensSurveyBanker_AutoBank),
			width = "full",
			default = 0,
			getFunc = function() return currentCharData.autoBank end,
			setFunc = function(value) 
					currentCharData.autoBank = value 
					if value then
						EVENT_MANAGER:RegisterForEvent(WinterQueensSurveyBanker.name.."OnBank",  EVENT_OPEN_BANK, autoBank)
					else
						EVENT_MANAGER:UnregisterForEvent(WinterQueensSurveyBanker.name.."OnBank",  EVENT_OPEN_BANK)
					end
				end,
		},
	}
	local LAM = LibAddonMenu2
    LAM:RegisterAddonPanel("WQSBOptions", panelData)
	LAM:RegisterOptionControls("WQSBOptions", optionsData)
	
	if currentCharData.remindMe then
		EVENT_MANAGER:RegisterForEvent(WinterQueensSurveyBanker.name.."OnActivated",  EVENT_PLAYER_ACTIVATED, WinterQueensSurveyBanker.OnPlayerActivated)
	end
	if currentCharData.autoBank then
		EVENT_MANAGER:RegisterForEvent(WinterQueensSurveyBanker.name.."OnBank",  EVENT_OPEN_BANK, autoBank)
	end
	EVENT_MANAGER:UnregisterForEvent(WinterQueensSurveyBanker.name.."OnLoad", EVENT_ADD_ON_LOADED)	
end

SLASH_COMMANDS["/wqsb"] = WinterQueensSurveyBanker.wqsb

EVENT_MANAGER:RegisterForEvent(WinterQueensSurveyBanker.name.."OnLoad", EVENT_ADD_ON_LOADED, WinterQueensSurveyBanker.OnAddonLoaded)