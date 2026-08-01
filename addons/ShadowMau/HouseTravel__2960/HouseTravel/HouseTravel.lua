-- ***** HouseTravel *****


--------------------------------------------------
-- Initialize addon variables
--------------------------------------------------
HouseTravel = {}
HouseTravel.name = "HouseTravel"
HouseTravel.slashCommand = "/htt"
HouseTravel.debug = true
HouseTravel.website = "https://www.esoui.com/downloads/info2960-HouseTravel.html"
HouseTravel.version = "1.0.1 (20210613)"
-- Changelog Notes Here


--------------------------------------------------
-- Link local variables to the in-game Globals
--------------------------------------------------
local middleButton = MOUSE_BUTTON_INDEX_MIDDLE
local rightButton = MOUSE_BUTTON_INDEX_RIGHT


--------------------------------------------------
-- Process the mouse button click
--------------------------------------------------	
function HouseTravel.OnWorldMapHouseRowClicked(control, button, upInside)
	local out = HouseTravel.DumpToDebug
	if not upInside then return true end -- Prevent the default function from running
	local data = ZO_ScrollList_GetData(control:GetParent())
	if button == middleButton then
		if data.unlocked then
			CHAT_SYSTEM:AddMessage("|c00E600"..HouseTravel.name.."|r has triggered a visit to "..data.houseName)
			RequestJumpToHouse(data.houseId, false)
		else
			CHAT_SYSTEM:AddMessage("|c00E600"..HouseTravel.name..":|r |cFF0000You do not own that house.|r  Entering Preview of "..data.houseName)
			RequestJumpToHouse(data.houseId, false)
		end
	elseif button == rightButton then
		if data.unlocked then
			CHAT_SYSTEM:AddMessage("|c00E600"..HouseTravel.name.."|r has triggered a travel to outside of "..data.houseName.." found in "..data.foundInZoneName)
			RequestJumpToHouse(data.houseId, true)
		end
	end
end


-- ***** Main *****


--------------------------------------------------
-- SlashCommand Debug - various debug and development information triggered by the slash command
--------------------------------------------------	
function HouseTravel.PingDebug()
	d("House Travel")
	
end


--------------------------------------------------
-- Check to see if this addon is the one loaded
--------------------------------------------------
function HouseTravel.OnAddOnLoaded(event, addonName)
	if addonName == HouseTravel.name then
		if HouseTravel.debug then SLASH_COMMANDS[HouseTravel.slashCommand] = HouseTravel.PingDebug end
		
		--------------------------------------------------
		-- Hook into the processing of mouse button clicks when the list of houses is shown on the World Map right side screen
		--------------------------------------------------	
		ZO_PreHook("ZO_WorldMapHouseRow_OnMouseUp", HouseTravel.OnWorldMapHouseRowClicked)
		
		EVENT_MANAGER:UnregisterForEvent(HouseTravel.name, EVENT_ADD_ON_LOADED)
	end
end


EVENT_MANAGER:RegisterForEvent(HouseTravel.name, EVENT_ADD_ON_LOADED, HouseTravel.OnAddOnLoaded)
