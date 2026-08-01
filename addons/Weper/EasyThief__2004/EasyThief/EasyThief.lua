local color = {}
color["white"] = "|cFFFFFF"
color["lightblue"] = "|c57D5FF"
color["red"] = "|cFF0000"
color["yellow"] = "|cF6FF00"
color["green"] = "|c00FF44"

EasyThief = {
	name = "EasyThief",
	version = "0.9.4",
	itemType = "",
	treasureMode = "",
	showSells = "",
	showLaunders = "",
	showFenceResetTime = "",

	defaultSettings = {
		itemType = 56,
		treasureMode = false, -- If it's false, the AddOn will show all stolen items. If it's true, the AddOn will show only the (stolen) treasure items. (Treasure items are the items with the "Treasure" text.)
		showInfoAfterStealing = true,
		showSells = true,
		showLaunders = true,
		showFenceResetTime = true,
	},
	
	savedSettings = {}, 
}

local et = EasyThief

function EasyThief:Initialize()
	et.savedSettings = ZO_SavedVars:NewAccountWide("EasyThief_SavedVars", self.version, nil, self.defaultSettings)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LOOT_UPDATED, self.OnLootOpen)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, self.OnLoot)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LOOT_CLOSED, self.OnLootClose)
	EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
	
	self.looting = false
	self.foundStolenItem = false

	et:LoadSettings()
end

function et:LoadSettings()
	et.itemType = et.savedSettings.itemType
	et.treasureMode = et.savedSettings.treasureMode
	et.showInfoAfterStealing = et.savedSettings.showInfoAfterStealing
	et.showSells = et.savedSettings.showSells
	et.showLaunders = et.savedSettings.showLaunders
	et.showFenceResetTime = et.savedSettings.showFenceResetTime
end

function et.OnLootOpen(event)
	et.looting = true
	et.foundStolenItem = false
end

function et.OnLoot(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
	if bagId ~= BAG_BACKPACK or not isNewItem then return end
		
	if IsItemStolen(bagId, slotId) and isNewItem then
		et.foundStolenItem = true
		
		if not et.looting and et.showInfoAfterStealing then
			et:StolenItems(et.showLaunders, et.showSells, et.showFenceResetTime)
		end
	end
	
end

function et.OnLootClose(event)
	if et.foundStolenItem and et.showInfoAfterStealing then
		et:StolenItems(et.showLaunders, et.showSells, et.showFenceResetTime)
	end
	et.foundStolenItem = false
	et.looting = false
end


function EasyThief.OnAddOnLoaded(event, addonName)
	if addonName == EasyThief.name then
		EasyThief:Initialize()
	end
end


function et:GetItems()
	local items = 0
	local price = 0
	local bonus = ZO_Fence_Manager:GetHagglingBonus()
	local bagSize = GetBagSize(BAG_BACKPACK) 
	
	local slot for slot = 0, bagSize, 1 do 
		if IsItemStolen(BAG_BACKPACK, slot) then 
			if et.treasureMode then
				local itemType = GetItemLinkItemType(GetItemLink(BAG_BACKPACK, slot, 0))
				if (itemType == tonumber(et.itemType)) then
					items, price = et:GetCurrentItem(items, price, slot, bonus)
				end
			else
				items, price = et:GetCurrentItem(items, price, slot, bonus)
			end
		end
	end

	return items, price
end

function et:GetCurrentItem(items, price, slot, bonus)
	local icon, stack, sellPrice = GetItemInfo(BAG_BACKPACK, slot)
	local itemPrice = 0
	
	if (bonus > 0) then
		itemPrice = math.floor(sellPrice + (sellPrice / 100) * bonus)
	else
		itemPrice = sellPrice
	end

	items = items + stack
	price = price + (itemPrice * stack)	
	
	return items, price
end


function et:CmdMsg(command, description)
	d(color.lightblue .. command .. color.yellow .. " - " .. color.white .. description)
end

function et:Commands()
	d(color.white .. "---- " .. color.red .. " Easy" .. color.yellow .. "Thief " .. color.lightblue .. "commands " .. color.white .."----")
	et:CmdMsg("/et help - /et commands", "Displays all commands.")
	et:CmdMsg("/et settings", "Displays the settings of the AddOn.")
	et:CmdMsg("/et treasure", "Enable or disable the \"Only Treasure\" mode. If enabled, only the number of treasures will be shown.")
	et:CmdMsg("/et info", "Enable or disable displaying information after stealing.")
	et:CmdMsg("/et launders", "Enable or disable displaying launders.")
	et:CmdMsg("/et sells", "Enable or disable displaying sells.")
	et:CmdMsg("/et fence", "Enable or disable displaying fence reset time.")
	et:CmdMsg("/et", "Displays information about your stolen items.")
	et:CmdMsg("/ethief - /easythief", "You can replace /et in every command with /ethief or /easythief.")
end

function et:ShowSettings()
	d(color.white .. "---- " .. color.red .. " Easy" .. color.yellow .. "Thief " .. color.lightblue .. "settings " .. color.white .."----")
	d(color.lightblue .. "Treasure mode" .. color.white .. ": " .. (et.treasureMode and ("" .. color.green .. "Enabled") or ("" .. color.red .. "Disabled")))
	d(color.lightblue .. "Displaying information after stealing" .. color.white .. ": " .. (et.showInfoAfterStealing and ("" .. color.green .. "Enabled") or ("" .. color.red .. "Disabled")))
	d(color.lightblue .. "Displaying launders" .. color.white .. ": " .. (et.showLaunders and ("" .. color.green .. "Enabled") or ("" .. color.red .. "Disabled")))
	d(color.lightblue .. "Displaying sells" .. color.white .. ": " .. (et.showSells and ("" .. color.green .. "Enabled") or ("" .. color.red .. "Disabled")))
	d(color.lightblue .. "Displaying fence reset time" .. color.white .. ": " .. (et.showFenceResetTime and ("" .. color.green .. "Enabled") or ("" .. color.red .. "Disabled")))
end

function et:StolenItems(showLaunders, showSells, showFenceResetTime)
	local items, price = et:GetItems()
	
	d(color.white .. "---------- " .. color.red .. " Easy" .. color.yellow .. "Thief " .. color.white .."----------")
	if showFenceResetTime then et:ShowFenceResetTime() end
	if showLaunders then et:ShowLaunders() end
	if showSells then et:ShowSells() end

	d(color.lightblue .. "Stolen items" .. color.white .. ":" ..color.red .. " " .. items .. color.white .. " - " .. color.lightblue .. "Gold" .. color.white .. ": " .. color.yellow .. price)
	et:ShowSellsLeft(items)
end

function et:ShowSellsLeft(items)
	local totalSells, sellsUsed, sellResetTimeSeconds = GetFenceSellTransactionInfo()
	local sellsLeft = (totalSells - sellsUsed - items) > 0 and totalSells - sellsUsed - items or 0
	
	d(color.lightblue .. "Estimated sells left" .. color.white .. ": " .. color.red .. sellsLeft)
end

function et:ShowFenceResetTime()
	local totalSells, sellsUsed, sellResetTimeSeconds = GetFenceSellTransactionInfo()
	local sellHours = math.floor(sellResetTimeSeconds / 3600)
	local sellMinutes = math.floor(sellResetTimeSeconds / 60) - (sellHours * 60)
	local sellSeconds = sellResetTimeSeconds - (sellMinutes * 60) - (sellHours * 3600)
	
	d(color.lightblue .. "Fence reset time" .. color.white .. ": " .. color.red .. sellHours .. color.yellow .. ":" .. color.red .. sellMinutes .. color.yellow .. ":" .. color.red .. sellSeconds)
end

function et:ShowSells()
	local totalSells, sellsUsed, sellResetTimeSeconds = GetFenceSellTransactionInfo()
	
	d(color.red .. "Sells" .. color.white .. ": " .. color.lightblue .. "Total" .. color.white .. ": " .. color.red .. totalSells .. color.white .. " - " .. color.lightblue .. "Used" .. color.white .. ": " .. color.red .. sellsUsed)
end

function et:ShowLaunders()
	local totalLaunders, laundersUsed, launderResetTimeSeconds = GetFenceLaunderTransactionInfo()
	
	d(color.red .. "Launders" .. color.white .. ": " .. color.lightblue .. "Total" .. color.white .. ": " .. color.red .. totalLaunders .. color.white .. " - " .. color.lightblue .. "Used" .. color.white .. ": " .. color.red .. laundersUsed)
end

function et:CommandManager(input)
	if (input == "help" or input == "commands") then et:Commands() 
	elseif (input == "settings") then et:ShowSettings()
	elseif (input == "treasure") then et.treasureMode = et:SetVariable(et.treasureMode, "Treasure mode") et:SaveSettings()
	elseif (input == "info") then et.showInfoAfterStealing = et:SetVariable(et.showInfoAfterStealing, "Displaying information after stealing") et:SaveSettings()
	elseif (input == "launders") then et.showLaunders = et:SetVariable(et.showLaunders, "Displaying launders") et:SaveSettings()
	elseif (input == "sells") then et.showSells = et:SetVariable(et.showSells, "Displaying sells") et:SaveSettings()
	elseif (input == "fence") then et.showFenceResetTime = et:SetVariable(et.showFenceResetTime, "Displaying fence reset time") et:SaveSettings()
	else et:StolenItems(et.showLaunders, et.showSells, et.showFenceResetTime) end
end

function et:SetVariable(variable, message)
	if variable then
		d(color.red .. message .. " disabled.")
		return false
	elseif not variable then
		d(color.green .. message .. " enabled.")
		return true
	end
end

function et:SaveSettings()
	if et.savedSettings.treasureMode ~= et.treasureMode then
		et.savedSettings.treasureMode = et.treasureMode
	end
	if et.savedSettings.showInfoAfterStealing ~= et.showInfoAfterStealing then
		et.savedSettings.showInfoAfterStealing = et.showInfoAfterStealing
	end
	if et.savedSettings.showSells ~= et.showSells then
		et.savedSettings.showSells = et.showSells
	end
	if et.savedSettings.showLaunders ~= et.showLaunders then
		et.savedSettings.showLaunders = et.showLaunders	
	end
	if et.savedSettings.showFenceResetTime ~= et.showFenceResetTime then
		et.savedSettings.showFenceResetTime = et.showFenceResetTime	
	end
end



SLASH_COMMANDS["/easythief"] = function(cmd) et:CommandManager(cmd) end
SLASH_COMMANDS["/et"] = function(cmd) et:CommandManager(cmd) end
SLASH_COMMANDS["/ethief"] = function(cmd) et:CommandManager(cmd) end

EVENT_MANAGER:RegisterForEvent(EasyThief.name, EVENT_ADD_ON_LOADED, EasyThief.OnAddOnLoaded)