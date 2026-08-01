TTCSP = {}

TTCSP.name = "TamrielTradeCentreSimplePrice"
TTCSP.version = "1.0"
TTCSP.throttle = {}
TTCSP.defaults = {
	miniumSellPrice = 10000,
	visibilityType  = "ALL",
	priceType = "AVERAGE",
	stackMultiplier = false
}

local TamrielTradeCentrePrice = TamrielTradeCentrePrice
local TamrielTradeCentre = TamrielTradeCentre

local LibAddonMenu2 = LibAddonMenu2

function TTCSP.Initialize(eventCode, addOnName)
	if TTCSP.name ~= addOnName then 
		return 
	end
		
	TTCSP.vars = ZO_SavedVars:NewAccountWide("TTCSPVars", 2, nil, TTCSP.defaults)
	
	TTCSP.InitializeConfiguration()
	TTCSP.InitializePlayerInventory()
	
	SecurePostHook(ZO_ScrollList_GetDataTypeTable(ZO_LootAlphaContainerList, 1), "setupCallback", TTCSP.InitializePlayerLoot)
end

-- Init config --
function TTCSP.InitializeConfiguration()
	local Panel = {
		type = "panel",
		name = "Tamriel Trade Centre Simple Price",
		author = "Kriax",
		version = TTCSP.version,
		registerForDefaults = true,
	}

	LibAddonMenu2:RegisterAddonPanel(TTCSP.name.."_LibAddonMenu2", Panel)
	
	local PanelData = {
		[1] = {
			type = "slider",
			name = "Minimum price desired for sales",
			tooltip = "Minimum price desired for sales",
			warning = "Will need to reload the UI.",
			getFunc = function() return TTCSP.vars.miniumSellPrice end,
			setFunc = function(value) TTCSP.vars.miniumSellPrice = value end,
			min = 1,
			max = 100000,
			default = TTCSP.defaults.miniumSellPrice
		},
		[2] = {
			type = "dropdown",
			name = "Change the display type",
			tooltip = "Change the display type",
			warning = "Will need to reload the UI.",
			choicesTooltips = {"Desired sell in green and other in red", "Desired sell showed only"},
			choices = {"ALL", "DESIRED_ONLY"},
			getFunc = function() return TTCSP.vars.visibilityType end,
			setFunc = function(value) TTCSP.vars.visibilityType = value end,
			default = TTCSP.defaults.visibilityType
		},
		[3] = {
			type = "checkbox",
			name = "Stack multiplier",
			tooltip = "Multiply the price by the number of items in the stack",
			warning = "Will need to reload the UI.",
			getFunc = function() return TTCSP.vars.stackMultiplier end,
			setFunc = function(value) TTCSP.vars.stackMultiplier = value end,
			default = TTCSP.defaults.stackMultiplier
		},
		[4] = {
			type = "dropdown",
			name = "Price type",
			tooltip = "Change the price type",
			warning = "Will need to reload the UI.",
			choicesTooltips = {"Average price", "TTC price"},
			choices = {"AVERAGE", "TTC"},
			getFunc = function() return TTCSP.vars.priceType end,
			setFunc = function(value) TTCSP.vars.priceType = value end,
			default = TTCSP.defaults.priceType
		}
	}

	LibAddonMenu2:RegisterOptionControls(TTCSP.name.."_LibAddonMenu2", PanelData)
end

-- Init player loot --
function TTCSP.InitializePlayerLoot(control, data)
	local itemLink = GetLootItemLink(data.lootId)
	TTCSP.DisplayPrice(control, itemLink, data.count, -6, -2)
end

-- Init player inventories --
function TTCSP.InitializePlayerInventory()
	for k,v in pairs(PLAYER_INVENTORY.inventories) do
		local listView = v.listView
		
		if (listView and listView.dataTypes and listView.dataTypes[1]) then
			-- setupCallback prehook on list view data --
			ZO_PreHook(listView.dataTypes[1], "setupCallback", 
				function(control, data) 
					local itemLink = GetItemLink(data.bagId, data.slotIndex)
					
					-- Displaying price by setting control, item link and ajust x y view --
					TTCSP.DisplayPrice(control, itemLink, data.stackCount, -6, 3)
				end
			 )
		end
	end
end

-- Display price --
function TTCSP.DisplayPrice(control, itemLink, numbItem, x, y)

	-- Got an invalid itemLink or invalid control --
	if(not itemLink or not control) then
		return
	end

	local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
	
	local marker = control:GetNamedChild(TTCSP.name)
	
	-- Marker is null, creating a new one --
	if (not marker) then
		marker = WINDOW_MANAGER:CreateControl(control:GetName() .. TTCSP.name, control, CT_LABEL)
	end
	
	marker:SetAnchor(BOTTOMRIGHT, nil, BOTTOMRIGHT, x, y)
	marker:SetFont("ZoFontGameBold")
		
	if(TTCSP.ItemCanSell(priceInfo)) then
		local price = 0
		local decimal = 0

		if(not TTCSP.vars.stackMultiplier) then
			numbItem = 1
		end
		
		if(TTCSP.vars.priceType == "AVERAGE") then 
			if(not priceInfo.Avg) then
				priceInfo.Avg = 0
			end
			
			price = priceInfo.Avg * numbItem
			marker:SetText(TamrielTradeCentre:FormatNumber(price))
		elseif (TTCSP.vars.priceType == "TTC") then 
			if(not priceInfo.SuggestedPrice) then
				priceInfo.SuggestedPrice = 0
			end
			
			price = priceInfo.SuggestedPrice * numbItem
			marker:SetText(TamrielTradeCentre:FormatNumber(price, 0) .. " ~ " .. TamrielTradeCentre:FormatNumber(price * 1.25, 0))
		end
		
		if (price ~= 0 and price >= TTCSP.vars.miniumSellPrice) then
			marker:SetColor(0, 1, 0, 1)
		else 
			if(TTCSP.vars.visibilityType == "ALL") then 
				marker:SetColor(1, 0, 0, 1)
			elseif(TTCSP.vars.visibilityType == "DESIRED_ONLY") then 
				marker:SetText("")
			end
		end 
	else
		marker:SetText("")
	end 
end

function TTCSP.ItemCanSell(priceInfo)
	if(priceInfo == nil) then
		return false
	end
	
	if(priceInfo.Avg == nil) then
		return false 
	end 

	return true
end
 
EVENT_MANAGER:RegisterForEvent("TTCSP", EVENT_ADD_ON_LOADED, TTCSP.Initialize)