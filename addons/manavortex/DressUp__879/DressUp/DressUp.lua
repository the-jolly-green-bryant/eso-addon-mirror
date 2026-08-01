DressUp = DressUp or {}
local DressUp = DressUp 

function DressUp.Init(event, addonName)
	if addonName ~= "DressUp" then return end
	
	DressUp.defaults = {
		Sets = {}
	}
		
	-- load saved variables
	DressUp.Settings = ZO_SavedVars:New("DressUpSavedVars", 1, nil, DressUp.defaults)
	
	if not DressUp.Settings.Sets["Standard"] then DressUp.standard() end
		
	SLASH_COMMANDS["/dressup"] = DressUp.SlashCommands

	
	EVENT_MANAGER:RegisterForEvent("DressUp",  EVENT_LINKED_WORLD_POSITION_CHANGED, DressUp.load)
	
end	

function DressUp.SlashCommands(cmd)

	if (cmd == "") then
    	d("[DressUp]: Usage - ")
    	d("	/DressUp save: saves the robe you're wearing.")
		d("	/DressUp clear: clears all items for the zone.")
		d("	/DressUp standard: Sets your business outfit.")
    	d(" 	")
	elseif (cmd == "save") then d("saving set") DressUp.save() 
	elseif (cmd == "clear") then d("clearing set") DressUp.clear() 
	elseif (cmd == "standard") then d("saving standard set") DressUp.standard() end
	


end

function DressUp.save()

	local chestItem = GetItemLink(BAG_WORN, 2, LINK_STYLE_DEFAULT)
	DressUp.Settings.Sets[GetMapName()] = chestItem	
	
end

function DressUp.load()
	local set = DressUp.getSet()

	if set then 
		local findMe = DressUp.findItem(set)
		if findMe then 
			local itemNumber = tonumber(findMe)
			
			EquipItem(BAG_BACKPACK, tonumber(findMe), EQUIP_SLOT_CHEST) 
			
		end
	end
	
end

function DressUp.getSet()
	
	local key = GetMapName()
	
	if DressUp.Settings.Sets[key] then
		return DressUp.Settings.Sets[key]
	elseif DressUp.Settings.Sets["Standard"] then
		return DressUp.Settings.Sets["Standard"]
	else
		return nil
	end

end

function DressUp.standard()

	local chestItem = GetItemLink(BAG_WORN, 2, LINK_STYLE_DEFAULT)
	DressUp.Settings.Sets["Standard"] = chestItem	
	
end

function DressUp.findItem(itemLink)

	local backpackItem
	local backpackSlots = GetBagSize and GetBagSize(bag) or select(2, GetBagInfo(bag))
	
	for i=1, backpackSlots do 
		backpackItem = GetItemLink(BAG_BACKPACK, i, LINK_STYLE_DEFAULT)
		if string.match(backpackItem, itemLink) then 
			return i 
		end
	end
	
end

function DressUp.clear()

	local zoneName = GetMapName() 
	DressUp.Settings.Sets[zoneName] = {}
	
end

-- initialize addon
EVENT_MANAGER:RegisterForEvent("DressUp", EVENT_ADD_ON_LOADED, DressUp.Init)