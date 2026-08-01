----------------------------------------------
--              Remember  Junk              --
--      Edda's super tiny junk handler      --
----------------------------------------------

-- Main objects
RJ = {}
RJ.Memory = {}
RJ.Options = {}
RJ.User = {}
RJ.User.Memory = {}
RJ.User.Options = {}

-- Init main vars
RJ.name = "RememberJunk"
RJ.niceName = " »"
RJ.command = "/rj"
RJ.version = 1.10
RJ.varVersion = 1
RJ.bankEvent = 0
RJ.craftEvent = false
RJ.trackDelay = 50

-- Options
RJ.User.Options.Verbous = true;

-- Init
function RJ.Initialize(eventCode, addOnName)

	-- Verify Add-On
	if (addOnName ~= RJ.name) then return end
	
	-- Load user's variables
	RJ.User = ZO_SavedVars:New("RJMem", math.floor(RJ.varVersion), nil, RJ.User, nil);
	
	-- Register the slash command handler
	SLASH_COMMANDS[RJ.command] = RJ.SlashCommands;
	
	-- Shortcuts
	setmetatable (RJ.Memory, {__index = RJ.User.Memory})
	setmetatable (RJ.Options, {__index = RJ.User.Options})
	
	-- Attach Event listeners
	EVENT_MANAGER:RegisterForEvent(RJ.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, RJ.RememberJunk);
	EVENT_MANAGER:RegisterForEvent(RJ.name, EVENT_CRAFT_STARTED, function () RJ.craftEvent = true end);
	EVENT_MANAGER:RegisterForEvent(RJ.name, EVENT_CRAFT_COMPLETED, function () RJ.craftEvent = false end);
	
	return true
end

-- Main loop
function RJ.DoNothing() return nil end

-- Remember junk func
function RJ.RememberJunk (eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
	
	if updateReason == INVENTORY_UPDATE_REASON_DURABILITY_CHANGE then return false end
	
	-- Register bank event
	if bagId == BAG_BANK then RJ.bankEvent = GetGameTimeMilliseconds() return false end
	
	if bagId == BAG_BACKPACK then
	
		-- Item data
		local itemData = {
			["itemId"] = select(4, ZO_LinkHandler_ParseLink(GetItemLink(bagId, slotId))),
			["itemName"] = GetItemName(bagId, slotId),
			["itemLink"] = GetItemLink(bagId, slotId),
			["timestamp"] = GetTimeStamp()
		}
			
		-- Loot or deconstruction
		if not IsItemJunk(bagId, slotId) and RJ.User.Memory[itemData.itemId] ~=nil and isNewItem then
		
			SetItemIsJunk(bagId, slotId, true)
			if RJ.User.Options.Verbous then d(RJ.niceName .. " |cffffff[" .. itemData.itemLink .. "]|r moved to junk !") end
			
		-- Bank pulls
		elseif GetGameTimeMilliseconds() - RJ.bankEvent < RJ.trackDelay and not IsItemJunk(bagId, slotId) and RJ.User.Memory[itemData.itemId] ~= nil and not isNewItem then
		
			SetItemIsJunk(bagId, slotId, true)
			if RJ.User.Options.Verbous then d(RJ.niceName .. " |cffffff[" .. itemData.itemLink .. "]|r moved to junk !") end
		
		-- Manually inserting new junk item
		elseif IsItemJunk(bagId, slotId) and RJ.User.Memory[itemData.itemId] == nil and not isNewItem then
			
			RJ.User.Memory[itemData.itemId] = itemData;
			if RJ.User.Options.Verbous then d(RJ.niceName .. " |cffffff[" .. itemData.itemLink .. "]|r added to junklist.") end
			
		-- Manually removing junk items
		elseif not IsItemJunk(bagId, slotId) and RJ.User.Memory[itemData.itemId] ~= nil and not isNewItem and not RJ.craftEvent then
		
			RJ.User.Memory[itemData.itemId] = nil
			if RJ.User.Options.Verbous then d(RJ.niceName .. " |cffffff[" .. itemData.itemLink .. "]|r removed from junklist.") end
		end
	end
	
	return nil
end

-- Count table size
function RJ.Count (t)
	if type(t) ~= "table" then return false end
	if next(t) == nil then return 0 end
	local count = 0;
	for k, v in pairs(t) do
		if rawget(t, k) ~= nil then count = count + 1 end
	end
	return count;
end

-- Display junk list func
function RJ.DisplayJunk ()
	if RJ.Count(RJ.User.Memory) > 0 then
		for k, v in pairs(RJ.User.Memory) do
			d(RJ.niceName .. " |cffffff[" .. v["itemLink"] .. "]|r marked as junk.")
		end
	else d(RJ.niceName .. " Junk list is empty.") end
	return nil
end

-- Clear junk list func
function RJ.clear ()
	if RJ.Count(RJ.User.Memory) > 0 then
		for k, v in pairs(RJ.User.Memory) do
			RJ.User.Memory[k] = nil
		end
		d(RJ.niceName .. " Junk list cleared.");
	else d(RJ.niceName .. " Junk list is empty.") end
end

function RJ.SlashCommands(text)
	if text == 'list' then RJ.DisplayJunk() end
	if text == 'clear' then RJ.clear() end
	if text == 'verbous' then
		RJ.User.Options.Verbous = not RJ.User.Options.Verbous
		d("Verbous mode now set to " .. tostring(RJ.User.Options.Verbous));
	end
	return nil
end

-- Hook initialization onto the ADD_ON_LOADED event
EVENT_MANAGER:RegisterForEvent(RJ.name, EVENT_ADD_ON_LOADED, RJ.Initialize);
