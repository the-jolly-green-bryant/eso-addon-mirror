CraftBagMon = {}
CraftBagMon.default = {
	["craftBag"] = {[1] = "CBM"},
	["saved"] = false,
	["delta"] = 0,
}

CraftBagMon.name = "CraftBagMonitor"
CraftBagMon.version = 1.21
CraftBagMonVer = 1.21

local lastTotal = 0
local savedVars = {}

function CraftBagMon:Initialize()

	CraftBagMon.savedVars = ZO_SavedVars:NewAccountWide("craftbagmon_vars", CraftBagMon.version, nil, CraftBagMon.default)

end

local function saveBagState()
	local craftBag = {}
	local i = 1
	if HasCraftBagAccess() then
		for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do  
			craftBag[i] = {["name"] = data.name, ["quantity"] = data.stackCount,}
			i = i+1
		end
	end
	CraftBagMon.savedVars.craftBag = craftBag
	if CraftBagMon.savedVars.saved then
		CraftBagMon.savedVars.delta = lastTotal
		d("- " .. GetString(SI_CRAFTBAG_MON_CRAFT_BAG_RESET_MESSAGE) .. " -")
	else
		-- Display this in case of first time initilization.
		CraftBagMon.savedVars.delta = 0
		d("- " .. GetString(SI_CRAFTBAG_MON_CRAFT_BAG_INIT_MESSAGE) .. " -")
	end
	CraftBagMon.savedVars.saved = true
end


local function findItem( data )
	for i = 1, #CraftBagMon.savedVars.craftBag do
		if data.name == CraftBagMon.savedVars.craftBag[i]["name"] then
			if data.stackCount > CraftBagMon.savedVars.craftBag[i]["quantity"] then
				return true, (data.stackCount - CraftBagMon.savedVars.craftBag[i]["quantity"])
			else
				return false, 0
			end
		end
	end
	return true, data.stackCount
end


--Grabs pricing from Master Merchant
local function getMMPrice( itemLink )
	if MasterMerchant then
		local itemID = tonumber(string.match(itemLink, '|H.-:item:(.-):'))
		local itemIndex = MasterMerchant.makeIndexFromLink(itemLink)
		local price = MasterMerchant:toolTipStats(itemID, itemIndex, true, nil, false)['avgPrice']
		if price then
			return price
		else
			return 0
		end 
	else
		return 0
	end
end

local function help()
	d(GetString(SI_CRAFTBAG_MON_SLASHCMD_INFO))
	d("  " .. GetString(SI_CRAFTBAG_MON_SLASHCMD_LIST))
	d("  " .. GetString(SI_CRAFTBAG_MON_SLASHCMD_SUMMARY))
	d("  " .. GetString(SI_CRAFTBAG_MON_SLASHCMD_RESET))
	d("  " .. GetString(SI_CRAFTBAG_MON_SLASHCMD_HELP))
end


local function listItems( summary )
	if CraftBagMon.savedVars.saved then
		local lastTotal = CraftBagMon.savedVars.delta
		local total=0
		local collectedNewItem = false
		if HasCraftBagAccess() then
			for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do
				local status, quantity = findItem(data)
				if status then
					if not collectedNewItem and summary == 0 then
						d(GetString(SI_CRAFTBAG_MON) .. ": " .. GetString(SI_CRAFTBAG_MON_CRAFT_BAG_LIST_HEADER_MESSAGE))
					end
					collectedNewItem = true
					local itemLink = GetItemLink(BAG_VIRTUAL, data.slotIndex, 0)
					local itemprice = getMMPrice(itemLink)
					local itempricetotal = getMMPrice(itemLink)*quantity
					total = total + itempricetotal
					itemprice = math.floor(itemprice*100+0.5)/100
					itempricetotal = math.ceil(itempricetotal-0.5)
					if MasterMerchant then
						if summary == 0 then
							d(itemLink.." ("..tostring(quantity)..") at "..itemprice.." ea = "..itempricetotal.."")
						end
					else
						if summary == 0 then
							d(itemLink.." ("..tostring(quantity)..")")
						end
					end
				end
			end
			total = math.floor(total+0.5)
			if collectedNewItem then
				delta = total - lastTotal
				if MasterMerchant then
					if delta == 0 then
						d(GetString(SI_CRAFTBAG_MON_CRAFT_BAG_LIST_MESSAGE) .. ": ".. total .. "g")
					else
						d(GetString(SI_CRAFTBAG_MON_CRAFT_BAG_LIST_MESSAGE) .. ": ".. total .. "g / [+" .. delta .. "g " .. GetString(SI_CRAFTBAG_MON_CRAFT_BAG_DELTA_MESSAGE) .. "]")
					end
					--d("Total: " .. total .. " - Last Total: " .. lastTotal .. " - Delta: " .. delta)
					lastTotal = total
					CraftBagMon.savedVars.delta = lastTotal
				end
			else
				d(GetString(SI_CRAFTBAG_MON) .. ": " .. GetString(SI_CRAFTBAG_MON_CRAFT_BAG_NO_ITEMS_MESSAGE))
			end
		else
			d(GetString(SI_CRAFTBAG_MON_CRAFT_BAG_NO_PLUS_MESSAGE))
		end
	else
		-- First time use, save bag.
		saveBagState()
	end
end


local function itemsReport()
	return listItems( 0 )
end


local function itemsSummary()
	return listItems( 1 )
end


function CraftBagMon.OnAddOnLoaded(event, addonName)
  if addonName == CraftBagMon.name then
    CraftBagMon:Initialize()
  end
end 

SLASH_COMMANDS["/cbm"] = help
SLASH_COMMANDS["/cbml"] = itemsReport
SLASH_COMMANDS["/cbms"] = itemsSummary
SLASH_COMMANDS["/cbmr"] = saveBagState

EVENT_MANAGER:RegisterForEvent(CraftBagMon.name, EVENT_ADD_ON_LOADED, CraftBagMon.OnAddOnLoaded)