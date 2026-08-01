TaterTotal = {}
 
TaterTotal.name = "TaterTotal" 
TaterTotal.version = 0.1

-- important!
TaterTotal.TATER_ID = 33758

-- For plebs who don't like taters
-- TODO: make this part of the saved data
-- TaterTotal.CustomId = nil

-- for debugging
TaterTotal.TATER_MULTIPLIER = 1


-- Saved Data
TaterTotal.dataVersion = 1
TaterTotal.Default = {
	OffsetX = GuiRoot:GetWidth()/2,
	OffsetY = GuiRoot:GetHeight()/2,
	CustomID = TaterTotal.TATER_ID,
	DetailsHidden = false
}

 -- onload
function TaterTotal.OnAddOnLoaded(event, addonName)
	if addonName ~= TaterTotal.name then return end

	TaterTotal:Initialize()
end
 

-- Init
function TaterTotal:Initialize()
	-- Saved Data
	TaterTotal.savedData = ZO_SavedVars:NewAccountWide("TaterTotalData", TaterTotal.dataVersion, nil, TaterTotal.Default)
	
	-- Load settings
	TaterTotalView:ClearAnchors()
	TaterTotalView:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TaterTotal.savedData.OffsetX, TaterTotal.savedData.OffsetY)
	TaterTotal:RefreshUI()

	
	-- Scene Shenanigans
	TaterTotal.fragment = ZO_SimpleSceneFragment:New(TaterTotalView)
    HUD_SCENE:AddFragment(TaterTotal.fragment)
    HUD_UI_SCENE:AddFragment(TaterTotal.fragment)
	
	-- Item context menu
	local function TrackTotal(inventorySlot, slotActions)
		local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
		if bagId and slotIndex then
			AddCustomMenuItem("Track Total", function()
				local itemLink = GetItemLink(bagId, slotIndex) --:gsub("H0", "H1")
				local _, _, _, itemId, _ = ZO_LinkHandler_ParseLink(itemLink)
				itemId = tonumber(itemId)
				TaterTotal.savedData.CustomId = itemId  -- Save it!
				-- d("saved " .. itemId .. " " .. TaterTotal.savedData.CustomId)
				TaterTotal:RefreshUI()
			end , "")
		end
	end
	LibCustomMenu:RegisterContextMenu(TrackTotal, LibCustomMenu.CATEGORY_LATE)
	
	-- local function linkContextMenu(link, button, _, _, linkType)
		-- if button == MOUSE_BUTTON_INDEX_RIGHT and linkType == ITEM_LINK_TYPE then
		   -- local itemType = GetItemLinkItemType(link)
		   -- AddCustomMenuEntry(...)
		-- end
	-- end
    -- LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, linkContextMenu)

	-- Refresh UI layout
	TaterTotal:UpdateUI()
	
	-- unregister event
	EVENT_MANAGER:UnregisterForEvent(TaterTotal.name, EVENT_ADD_ON_LOADED)
end

local function ItemIdFromSlot(bagId, slotIndex)
	local link = GetItemLink(bagId, slotIndex)
	local _, _, _, itemID, _ = ZO_LinkHandler_ParseLink(link)
	return tonumber(itemID)
end 


local function CountTaters(bagId)
	-- d("Counting taters in: " .. bagId)
    local total = 0
	-- d("Checking " .. GetBagSize(bagId) .. " slots")
	local bagCache = SHARED_INVENTORY:GenerateFullSlotData(nil, bagId)
	local searchId = TaterTotal.savedData.CustomId or TaterTotal.TATER_ID
	-- d("search " .. TaterTotal.savedData.CustomId .. " " .. searchId)
	for index, data in pairs(bagCache) do
		-- d(data.slotIndex .. " " .. data.bagId)
		local itemID = ItemIdFromSlot(data.bagId, data.slotIndex)
		-- d(itemID)
		if(itemID == searchId) then
			-- d("Found " .. data.stackCount .. "taters")
            total = total + data.stackCount
        end
	end
	return total * TaterTotal.TATER_MULTIPLIER
end

local function FormatNumber(n)
	local k = n / 1000
	local m = n / 1000000
	
	if n < 1000 then
		return "" .. n
	elseif n < 10000 then
		return "" .. math.floor(k * 10) / 10 .. "k"
	elseif n < 1000000 then
		return "" .. math.floor(k) .. "k"
	elseif n < 10000000 then
		return "" .. math.floor(m * 10) / 10 .. "m"
	else
		return "" .. math.floor(m) .. "m"
	end
end


function TaterTotal:UpdateUI()
	TaterTotal:UpdateUI_Text()
	TaterTotal:UpdateUI_Size()
end


-- count potatoes and update text]
function TaterTotal:UpdateUI_Text()
	local taters_inv = CountTaters(BAG_BACKPACK)
	local taters_craft = CountTaters(BAG_VIRTUAL)
	local taters_bank = CountTaters(BAG_BANK) + CountTaters(BAG_SUBSCRIBER_BANK)
	local total_taters = taters_inv + taters_craft + taters_bank
	TaterTotalViewDetailsInventory:SetText("" .. FormatNumber(taters_inv))
	TaterTotalViewDetailsCraftbag:SetText("" .. FormatNumber(taters_craft))
	TaterTotalViewDetailsBank:SetText("" .. FormatNumber(taters_bank))
	TaterTotalViewCount:SetText("" .. total_taters)
end

function TaterTotal:UpdateTextSize(element, left, top)
	left = left or 0
	top = top or 0

	local h = element:GetTextHeight() + top
	if(h ~= element:GetHeight()) then
		element:SetHeight(h)
	end
	local w = element:GetTextWidth() + left
	if(w ~= element:GetWidth()) then
		element:SetWidth(w)
	end

	return w, h
end

-- Set sizes and stuff for the UI
function TaterTotal:UpdateUI_Size()

	-- set sizes
	local maxWidth, totalHeight = 0, 0
    local spacing = 6
	local margin = 24
	
	maxWidth = math.max(maxWidth, TaterTotalViewDetailsInventoryLabel:GetTextWidth() + TaterTotalViewDetailsInventory:GetTextWidth() + spacing)
	maxWidth = math.max(maxWidth, TaterTotalViewDetailsBankLabel:GetTextWidth() + TaterTotalViewDetailsBank:GetTextWidth() + spacing)
	maxWidth = math.max(maxWidth, TaterTotalViewDetailsCraftbagLabel:GetTextWidth() + TaterTotalViewDetailsCraftbag:GetTextWidth() + spacing)
	maxWidth = maxWidth -- + margin * 2
	
	TaterTotalViewDetailsInventoryLabel:SetWidth(maxWidth)
	TaterTotalViewDetailsInventory:SetWidth(maxWidth)
	TaterTotalViewDetailsBankLabel:SetWidth(maxWidth)
	TaterTotalViewDetailsBank:SetWidth(maxWidth)
	TaterTotalViewDetailsCraftbagLabel:SetWidth(maxWidth)
	TaterTotalViewDetailsCraftbag:SetWidth(maxWidth)
	
	TaterTotalViewDetailsSpacer:SetWidth(maxWidth + margin * 2)
end

function TaterTotal:SaveLocation()
	TaterTotal.savedData.OffsetX = TaterTotalView:GetLeft()
	TaterTotal.savedData.OffsetY = TaterTotalView:GetTop()
end

-- This shouldn't be called often, only when UI settings have changed
function TaterTotal:RefreshUI()
	-- the game does weird stuff with resizing the gui depending on which quadrant of the screen it's in
	-- so, save position and size info first...
	local left = TaterTotalView:GetLeft()
	local top = TaterTotalView:GetTop()
	local width = TaterTotalView:GetWidth()
	local height = TaterTotalView:GetHeight()
	
	if TaterTotal.savedData.DetailsHidden then
		TaterTotalViewDetails:SetHidden(true)
		TaterTotalViewDetails:SetExcludeFromResizeToFitExtents(true)
		TaterTotalViewSpacer:ClearAnchors()
		TaterTotalViewSpacer:SetAnchor(TOP, TaterTotalViewCount, BOTTOM, 0, 0)
	else
		TaterTotalViewDetails:SetHidden(false)
		TaterTotalViewDetails:SetExcludeFromResizeToFitExtents(false)
		TaterTotalViewSpacer:ClearAnchors()
		TaterTotalViewSpacer:SetAnchor(TOP, TaterTotalViewDetails, BOTTOM, 0, 0)
	end
	
	-- custom item
	if TaterTotal.savedData.CustomId == TaterTotal.TATER_ID or TaterTotal.savedData.CustomId == nil then
		TaterTotalViewTitle:SetText("Tater Total")
		TaterTotalViewLink:SetHidden(true)
		TaterTotalViewLink:SetExcludeFromResizeToFitExtents(true)
		TaterTotalViewCount:ClearAnchors()
		TaterTotalViewCount:SetAnchor(TOP, TaterTotalViewTitle, BOTTOM, 0, 0)
	else
		TaterTotalViewTitle:SetText("|l0:1:0:-25%:2:ffffff|lTater|l Total")
		local cleanLink = "|H1:item:" .. TaterTotal.savedData.CustomId .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
		TaterTotalViewLink:SetText(cleanLink)
		TaterTotalViewLink:SetHidden(false)
		TaterTotalViewLink:SetExcludeFromResizeToFitExtents(false)
		TaterTotalViewCount:ClearAnchors()
		TaterTotalViewCount:SetAnchor(TOP, TaterTotalViewLink, BOTTOM, 0, 0)
	end
	
	-- ... and when we're done realign the gui to the top center of where it was before
	-- TODO!
	
	TaterTotal:UpdateUI()
end

function TaterTotal:ToggleDetails()
	-- toggle saved value
	TaterTotal.savedData.DetailsHidden = not TaterTotalViewDetails:IsHidden()
	-- and apply it
	TaterTotal:RefreshUI()
end


-- Register Events
EVENT_MANAGER:RegisterForEvent(TaterTotal.name, EVENT_ADD_ON_LOADED, TaterTotal.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(TaterTotal.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, TaterTotal.UpdateUI)


-- Chat Commands

SLASH_COMMANDS["/tatercount"] = function (extra)
	TaterTotal:UpdateUI()
end

SLASH_COMMANDS["/moretaters"] = function (extra)
	TaterTotal.TATER_MULTIPLIER = 2 * TaterTotal.TATER_MULTIPLIER
	TaterTotal:UpdateUI()
end