GLAFarmManager = {}
 
GLAFarmManager.name = "GLAFarmManager"
GLAFarmManager.version = "0.2"
GLAFarmManager.varVersion = "0.3"

GLAFarmManager.default = {
			["craftMats"] = {
				},
			["runs"]={},
			["activeRun"]=""
		}

local SavedVars = {}

local function load()
	return ZO_SavedVars:NewAccountWide("GLAFarmManagerVariables", GLAFarmManager.varVersion, nil, GLAFarmManager.default)
end

local function Initialize()
	SavedVars = load()
end

local function locate( t, value )
	for _,v in pairs(t) do
	  if v == value then
			return true
	  end
	end
	return false
end

local function getCraftingMatsNames ()
	local i = 1
	if HasCraftBagAccess() then
		for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do  
			local _,_,_,itemID = ZO_LinkHandler_ParseLink((GetItemLink(BAG_VIRTUAL, index)))
			i = i+1
			if(locate(SavedVars.craftMats, itemID)==false) then
				table.insert(SavedVars.craftMats, itemID)
			end
		end
	end
end


local function getPrice(itemLink)
	local _,_,_,itemID = ZO_LinkHandler_ParseLink(itemLink)
	--if TamrielTradeCentrePrice then
		local t = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
		if t and t.SuggestedPrice then
			return t.SuggestedPrice, false
		end
	--end
	local default =GetItemLinkValue(itemLink)
	return default, true
end

local function handleItem(itemLink, quantity)
	local _,_,_,itemID = ZO_LinkHandler_ParseLink(itemLink)
	if(SavedVars["runs"][SavedVars["activeRun"]][itemID]~=nil)then
		local totalQ = (SavedVars["runs"][SavedVars["activeRun"]][itemID]["count"]+quantity)
		--d("Increment:"..itemLink.." for run "..SavedVars["activeRun"].." total "..totalQ.." value "..SavedVars["runs"][SavedVars["activeRun"]][itemID]["count"]*SavedVars["runs"][SavedVars["activeRun"]][itemID]["price"])
		SavedVars["runs"][SavedVars["activeRun"]][itemID]["count"] = totalQ
	else				
		local price = getPrice(itemLink)
		--d("Add:"..itemLink.." for run "..SavedVars["activeRun"].." value "..(price*quantity))
		SavedVars["runs"][SavedVars["activeRun"]][itemID]={["count"]=quantity,["link"]=itemLink, ["price"]=getPrice(itemLink)}
	end
end


local function parseArgs(extra)
	local options = {}
    local searchResult = { string.match(extra,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	return options
end

local function startRun(extra)	
	getCraftingMatsNames()
	local arg = parseArgs(extra)
	local runName = "default"
	
	if(#arg>0) then
		runName = arg[1]
	end
	
	SavedVars["activeRun"] = runName
	d("StartingRun:"..SavedVars["activeRun"])
	SavedVars.runs[SavedVars["activeRun"]]={}
end

local function countItems()
	local cnt=0;
	if(SavedVars["runs"][SavedVars["activeRun"]]==nil)	then return 0 end
	for _,v in pairs(SavedVars["runs"][SavedVars["activeRun"]]) do
		cnt=cnt+1
	end
	return cnt
end

local function processRunItems()
	if(countItems()==0) then
		SavedVars["runs"][SavedVars["activeRun"]]=nil	
		SavedVars["activeRun"]=""
		return true
	end	
	if HasCraftBagAccess() then
		for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do			
			local link = GetItemLink(BAG_VIRTUAL, index)
			--d("Checking item "..tostring(link))
			local _,_,_,itemID = ZO_LinkHandler_ParseLink(link)
			local item = SavedVars["runs"][SavedVars["activeRun"]][itemID]
			if(item~=nil) then
				local amnt =math.min(200,item["count"])
				local slot = FindFirstEmptySlotInBag(BAG_BACKPACK)
				if(slot) then
					d("Retrieving "..amnt.." "..tostring(link))
					if IsProtectedFunction("RequestMoveItem") then
						CallSecureProtected("RequestMoveItem", BAG_VIRTUAL, data.slotIndex,BAG_BACKPACK,slot,amnt)
					else
						RequestMoveItem(BAG_VIRTUAL, data.slotIndex, BAG_BACKPACK,slot,amnt)
					end
					if(amnt<200) then
						SavedVars["runs"][SavedVars["activeRun"]][itemID]=nil
					else
						SavedVars["runs"][SavedVars["activeRun"]][itemID]["count"]=(SavedVars["runs"][SavedVars["activeRun"]][itemID]["count"]-200)
					end
					zo_callLater(function() processRunItems() end,500)
					break
				else
					d("No empty inventory slots")
					break
				end
			end
		end
	else
		d("ESO+ required")
	end
end

local function endRun()

	if(SavedVars["runs"] == nil) then d("No runs") return true end
	if(SavedVars["runs"][SavedVars["activeRun"]] == nil) then d("Run does not exist") return end
	processRunItems()
end

local function selectRun(extra)
	local args = parseArgs(extra)
	
	if(#args==0) then d("Run name required") end
	if(SavedVars==nil) then init() end
	if(SavedVars["runs"] == nil) then d("No runs") return true end
	if(SavedVars["runs"][args[1]] == nil) then d("Run does not exist") return end
	
	SavedVars["activeRun"] = args[1]
	d("SelectingRun:"..SavedVars["activeRun"])
end

local function getRun()
	if(SavedVars["runs"] == nil) then d("No runs") end
	
	d("ActiveRun:"..SavedVars["activeRun"])
end

local function listRuns()
	d("Open runs")
	if(SavedVars["runs"] == nil) then d("No runs") return true end
	
	for k,v in pairs(SavedVars["runs"]) do
		d(k)
	end
end

local function checkRun()
	if(SavedVars["runs"] == nil) then d("No runs") return true end
	if(SavedVars["runs"][SavedVars["activeRun"]] == nil) then d("Run does not exist") return end
	
	d("Stats for run "..SavedVars["activeRun"])
	local worth=0;
	for _,v in pairs(SavedVars["runs"][SavedVars["activeRun"]]) do
		local iprice =(v["count"]*v["price"])
		d(v["link"]..":"..v["count"].." value "..iprice)
		worth = (worth+iprice)
	end
	d("Total value:"..worth)
end

local function cleanRun()
	if(SavedVars["runs"] == nil) then d("No runs") return true end
	if(SavedVars["runs"][SavedVars["activeRun"]] == nil) then d("Run does not exist") return end
	
	d("Clean up run "..SavedVars["activeRun"])
	SavedVars["runs"][SavedVars["activeRun"]] = {}
end

local function totalWorth()
	local amnt = 0 
	for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do	
		local link = GetItemLink(BAG_VIRTUAL, index)
		amnt = (amnt + (data.stackCount*getPrice(link)))
	end
	d("Total acc material price "..amnt)
end

local function startRun(extra)	
	getCraftingMatsNames()
	local arg = parseArgs(extra)
	local runName = "default"
	
	if(#arg>0) then
		runName = arg[1]
	end
	
	SavedVars["activeRun"] = runName
	d("StartingRun:"..SavedVars["activeRun"])
	if(SavedVars.runs[SavedVars["activeRun"]] ~= nil or countItems()>0) then		
		d("Run already exists, set as active")
	else
		SavedVars.runs[SavedVars["activeRun"]]={}
	end
end

local function OnLootReceived(eventCode, lootedBy, itemLink, quantity, itemSound, lootType, isStolen)
	if(SavedVars["runs"] == nil) then return true end
	if(SavedVars["runs"][SavedVars["activeRun"]] == nil) then return end
	
	local _,_,_,itemID = ZO_LinkHandler_ParseLink(itemLink)
	if(locate(SavedVars.craftMats, itemID)) then
		handleItem(itemLink, quantity)
	else
		getCraftingMatsNames()
		if(locate(SavedVars.craftMats, itemID)) then
			handleItem(itemLink, quantity)				
		end
	end
end

local function OnAddOnLoaded(event, addonName)
   if addonName ~= GLAFarmManager.name then return end
 
	Initialize()
end

SLASH_COMMANDS["/glabegin"] = function(extra) startRun(extra) end
SLASH_COMMANDS["/glaend"] = function() endRun() end
SLASH_COMMANDS["/glaclean"] = function() cleanRun() end
SLASH_COMMANDS["/glaselect"] = function(extra) selectRun(extra) end
SLASH_COMMANDS["/glaactive"] = function() getRun() end
SLASH_COMMANDS["/glastats"] = function() checkRun() end
SLASH_COMMANDS["/glalist"] = function() listRuns() end
SLASH_COMMANDS["/glaworth"] = function() totalWorth() end

EVENT_MANAGER:RegisterForEvent(GLAFarmManager.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(GLAFarmManager.name, EVENT_LOOT_RECEIVED , OnLootReceived)
