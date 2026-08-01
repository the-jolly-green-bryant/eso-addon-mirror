
local LIBSI = LibStub:GetLibrary("LibSortIt-1.0")

------------------------------------------------------
-- Create Tables used in the addon --
------------------------------------------------------
SortIt = {}
SortIt.debug = {}

------------------------------------------------------
--  Initialize Constants --
------------------------------------------------------
SortIt.name 			= "SortIt"
--=======================================================================--
SortIt.version 			= 1.3 -- SAVED VAR VERSION -- DO NOT CHANGE THIS --
--=======================================================================--
SortIt.realVersion 		= 2.2
SortIt.SORTASC_HEADERNAME = "SortItToggleAsc"

---------------------------------------------------------
--  Colors  --
---------------------------------------------------------
local colorRed 			= "|cFF0000" 	-- Red
local colorYellow 		= "|cFFFF00" 	-- yellow
local colorGreen 		= "|c00FF00" 	-- green
local colorMagenta		= "|cFF00FF"	-- Magenta
local colorDrkOrange 	= "|cFFA500"	-- Dark Orange

---------------------------------------------------------
--  Get Inventory For Header Group  --
---------------------------------------------------------
local function GetInventoryForHeaderGroup(_SelectedHeaderGroup)
	local headerContainer = _SelectedHeaderGroup.headerContainer
	
	if headerContainer == ZO_PlayerInventorySortBy then
		return INVENTORY_BACKPACK
	elseif headerContainer == ZO_PlayerBankSortBy then
		return INVENTORY_BANK
	elseif headerContainer == ZO_GuildBankSortBy then
		return INVENTORY_GUILD_BANK
	end
end


----------------------------------------------------------------------------------------------
-- Hook the OnHeaderClicked so I can override what happens when the user clicks the main	--
-- Header (the one typically named "Name") in the inventories 								--
----------------------------------------------------------------------------------------------
local hCallback = ZO_SortHeaderGroup.OnHeaderClicked
function ZO_SortHeaderGroup:OnHeaderClicked(header, suppressCallbacks)
	local ClickedHeader = header -- Just for clarity, its the header they just clicked
	local selfHeaderGroup = self -- Just for clarity, its the headerGroup they just clicked
	
	--ZO_TradingHouseItemPaneSearchSortBy
	-- If its the guild store groupHeaderContainer, let the game handle the click & return
	if selfHeaderGroup.headerContainer ~= ZO_PlayerInventorySortBy and selfHeaderGroup.headerContainer ~= ZO_PlayerBankSortBy and selfHeaderGroup.headerContainer ~= ZO_GuildBankSortBy then
		hCallback(selfHeaderGroup, ClickedHeader, suppressCallbacks)
		return
	end
	
	local hSortItAscHeader = selfHeaderGroup.headerContainer:GetNamedChild(SortIt.SORTASC_HEADERNAME)
	local OldHeader = selfHeaderGroup.selectedSortHeader -- Just for clarity, its the old (last) header they clicked
	local iInventory = GetInventoryForHeaderGroup(selfHeaderGroup)
	local hNameHeader = selfHeaderGroup.headerContainer:GetNamedChild("Name")
	
	
	-- if its my Asc toggle header
	if ClickedHeader == hSortItAscHeader then
		-- Set clickedHeader to oldHeader, so game will think we clicked the same header &
		-- reverse the sort order for us.
		ClickedHeader = OldHeader
		
	-- If they clicked the "Name" header
	elseif ClickedHeader == hNameHeader then
		-- If the old header does not exist, or the old (last) header clicked was the "Name" header or the 
		-- old (last) header clicked was my SortItAscToggle header...we want to toggle the sortPack
		-- were doing this because if the last header clicked is not the clicked header or toggle Asc header
		-- then we don't want to switch sort packs, we just want the game to handle it & reset the same sortPack
		-- without toggling it.
		if not OldHeader or (OldHeader == ClickedHeader or OldHeader == hSortItAscHeader) then
			local sCurSortPackName = LIBSI:GetCurSortPackName(SortIt.name, iInventory)
			local tNextSortPack = LIBSI:GetNextSortPack(SortIt.name, sCurSortPackName)
			-- If there is not a nextSortPack, then no packs exist, resort to default header
			if not tNextSortPack then 
				ClickedHeader.key = "name"	-- Change the SortKey for the "Name" header to default
				selfHeaderGroup:SetHeaderNameForKey("name", "Name")	-- Set "Name" Header display text
				hSortItAscHeader.key = "name" 	-- Change SortKey for custom Asc toggle header
				--PLAYER_INVENTORY:ChangeSort("name", iInventory, selfHeaderGroup.sortDirection)
				--return
			--end
			else
				-- since I'm letting the game handle the header click, & were clicking the same header
				-- the game will try to reverse the sortHeaderGroup sortDirection. So instead of setting it to
				-- the starting sortOrder I have to set it to the opposite sort order, so when it reverses it
				-- We get the sortOrder we want. But we only have to do that for the headerGroups sortDirection.
				selfHeaderGroup.sortDirection = not tNextSortPack.startAscOrder
				ClickedHeader.sortDirection = tNextSortPack.startAscOrder -- Change to new sortPack starting sortDirection
				ClickedHeader.initialDirection = tNextSortPack.startAscOrder	-- Change to new sortPack starting sortDirection
				ClickedHeader.key = tNextSortPack.sortKeys[1].key	-- Change header sortKey
				selfHeaderGroup:SetHeaderNameForKey(tNextSortPack.sortKeys[1].key, tNextSortPack.displayName) -- Change header text
				-- LibSortIt keeps track of the current sort pack, but this addon needs to save the current sortpack as well
				-- to be able to reload it during log-ins & ui reloads 
				SortIt.SavedVariables.curPackName[iInventory] = tNextSortPack.displayName 
				-- Note this does NOT change the sort, it only initializes the sortData needed for the sort,
				-- creates the sortKeys for this sortPack & records this sortPack as the current sort pack. 
				-- Were letting the game handle the actual sort so it takes care of updating all of the 
				-- (rest of the) header/header group info for us
				LIBSI:ChangePack(SortIt.name, tNextSortPack.displayName, iInventory)
			end
			
		end
	end
	-- If the clicked header is not the old (last) header clicked...and the clicked header is not the toggle header
	-- Then the current sortKey for the inventory has changed. Update the toggle Headers sortKey so it always has
	-- the current sortKey. AND its not the guild store.
	if (ClickedHeader ~= OldHeader) and (ClickedHeader ~= hSortItAscHeader) and (ClickedHeader ~= ZO_TradingHouseManager) then
		-- Since I'm resetting the Clicked header when they click AscToggle header I dont really need this
		-- The game will never actually know the SortItAsc Header gets clicked, But its not a bad Idea to 
		-- keep its key current, since this is the SortKey it will toggle, just in case I decide to use it for something.
		hSortItAscHeader.key = ClickedHeader.key
	end
	
	-- I wrote the LibSortIt library to do sorting, but since I decided to hook into the header clicks
	-- and I don't want that to be part of the LibSortIt library...
	-- I decided it would probably be better to just let the game handle the actual sorting call so it keeps
	-- all of the header, header group, header icons, ect... info up to date for me.
	
	-- NOTE: Everything above falls through to this function call, regardless of what was clicked. We only needed to
	-- modify header/headerGroup info so the game will do what we want when the "real" 
	-- ZO_SortHeaderGroup:OnHeaderClicked(header, suppressCallbacks) is called. It is where the sort is going to 
	-- actually get changed
	-- All necessary changes made, now let the game handle the header click & sortChanges
	hCallback(selfHeaderGroup, ClickedHeader, suppressCallbacks)
end


------------------------------------------------------------
-- EVENT Functions	--
-------------------------------------------------------------
local function OnSlotUpdate( eventCode, _iBagId, _iSlotId, isNewItem, itemSoundCategory, updateReason) 
	if _iBagId ~= BAG_WORN  then
		-- was just used for testing
		LIBSI:UpdateBagData( _iBagId, _iSlotId, SortIt.SetData)
	end
end

local function InitializeInvData()
	LIBSI:InsertSortKeyData(INVENTORY_BACKPACK, SortIt.SetData)
	LIBSI:InsertSortKeyData(INVENTORY_BANK, SortIt.SetData)
	LIBSI:InsertSortKeyData(INVENTORY_GUILD_BANK, SortIt.SetData)
	--PLAYER_INVENTORY:RefreshAllInventorySlots(INVENTORY_GUILD_BANK)
	--PLAYER_INVENTORY:UpdateList(INVENTORY_GUILD_BANK)
end
local function OnPlayerActivated()
	-- Must be called after Keys & packs are created
	-- Calling in onPlayerActivated instead of on initialize, otherwise...
	-- Some game information gets overwritten as the game is still loading and messes up some
	-- of the initial sort and header/headerGroup info.
	SortIt.InitializeHeaders() 
	
	InitializeInvData() 		-- Then initialize/insert inventory data
	
	EVENT_MANAGER:UnregisterForEvent(SortIt.name, EVENT_PLAYER_ACTIVATED)
end
someglobalvar = true
----------------------------------------------
--  OnAddOnLoaded  --
----------------------------------------------
local function OnAddOnLoaded(_event, _sAddonName)
	if _sAddonName == SortIt.name then
		SortIt:Initialize()
	end
end


-------------------------------------------
--  Initialize Function --
-------------------------------------------
function SortIt:Initialize()
	self.SavedVariables = ZO_SavedVars:New("SortItSavedVariables", SortIt.version, nil, SortIt.PlayerDefaults)
	
	 -- Must be called before Creating the settings menu because it will try to access the sortKeys 
	 -- & sortPacks to populate the dropdown boxes
	SortIt.CreateSortKeys()		-- Must initialize SortKeys first
	SortIt.CreateSortPacks() 	-- Then Packs
	SortIt.CreateSettingsMenu()
end

------------------------------------------------
--  Register Events --
------------------------------------------------
EVENT_MANAGER:RegisterForEvent(SortIt.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(SortIt.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
EVENT_MANAGER:RegisterForEvent(SortIt.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnSlotUpdate)


 









