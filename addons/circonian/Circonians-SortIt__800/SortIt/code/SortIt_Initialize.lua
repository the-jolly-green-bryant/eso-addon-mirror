
local LIBSI = LibStub:GetLibrary("LibSortIt-1.0")

local SORT_ARROW_UP = "EsoUI/Art/Miscellaneous/list_sortUp.dds"
local SORT_ARROW_DOWN = "EsoUI/Art/Miscellaneous/list_sortDown.dds"
local SORT_ARROW_OFFSET_X = 2
local sortArrowAlignments =
{
    [TEXT_ALIGN_LEFT] = function(arrow, header, textWidth) 
                            arrow:SetAnchor(LEFT, header, LEFT, textWidth + SORT_ARROW_OFFSET_X, 0)
                        end,
    [TEXT_ALIGN_RIGHT] =    function(arrow, header, textWidth) 
                                arrow:SetAnchor(LEFT, header, RIGHT, SORT_ARROW_OFFSET_X, 0)
                            end,
    [TEXT_ALIGN_CENTER] =   function(arrow, header, textWidth) 
                                arrow:SetAnchor(LEFT, header, CENTER, textWidth * 0.5 + SORT_ARROW_OFFSET_X, 0)
                            end,
}

local function CreateSortOrderToggleHeaders()
	local cBankToggleHeaderName = ZO_PlayerBankSortBy:GetName()..(SortIt.SORTASC_HEADERNAME)
	local cBankToggleHeader = WINDOW_MANAGER:CreateControlFromVirtual(cBankToggleHeaderName, ZO_PlayerBankSortBy, "ZO_SortHeaderIcon")
	cBankToggleHeader:SetDimensions(30, 50)
	cBankToggleHeader:SetAnchor(RIGHT, ZO_PlayerBankSortByName, LEFT, -25, -5)
	ZO_SortHeader_SetTooltip(cBankToggleHeader, "Toggle Sort Direction", RIGHT, -20, 0)
	ZO_SortHeader_InitializeArrowHeader(cBankToggleHeader, "name", ZO_SORT_ORDER_UP)
	PLAYER_INVENTORY.inventories[INVENTORY_BANK].sortHeaders:AddHeader(cBankToggleHeader)
	cBankToggleHeader.initialDirection = true

	local cInvToggleHeaderName = ZO_PlayerInventorySortBy:GetName()..(SortIt.SORTASC_HEADERNAME)
	local cInvToggleHeader = WINDOW_MANAGER:CreateControlFromVirtual(cInvToggleHeaderName, ZO_PlayerInventorySortBy, "ZO_SortHeaderIcon")
	cInvToggleHeader:SetDimensions(30, 50)
	cInvToggleHeader:SetAnchor(RIGHT, ZO_PlayerInventorySortByName, LEFT, -25, -5)
	ZO_SortHeader_SetTooltip(cInvToggleHeader, "Toggle Sort Direction", RIGHT, -20, 0)
	ZO_SortHeader_InitializeArrowHeader(cInvToggleHeader, "name", ZO_SORT_ORDER_UP)
	PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].sortHeaders:AddHeader(cInvToggleHeader)
	cInvToggleHeader.initialDirection = true
	
	local cGuildBankToggleHeaderName = ZO_GuildBankSortBy:GetName()..(SortIt.SORTASC_HEADERNAME)
	local cGuildBankToggleHeader = WINDOW_MANAGER:CreateControlFromVirtual(cGuildBankToggleHeaderName, ZO_GuildBankSortBy, "ZO_SortHeaderIcon")
	cGuildBankToggleHeader:SetDimensions(30, 50)
	cGuildBankToggleHeader:SetAnchor(RIGHT, ZO_GuildBankSortByName, LEFT, -25, -5)
	ZO_SortHeader_SetTooltip(cGuildBankToggleHeader, "Toggle Sort Direction", RIGHT, -20, 0)
	ZO_SortHeader_InitializeArrowHeader(cGuildBankToggleHeader, "name", ZO_SORT_ORDER_UP)
	PLAYER_INVENTORY.inventories[INVENTORY_GUILD_BANK ].sortHeaders:AddHeader(cGuildBankToggleHeader)
	cGuildBankToggleHeader.initialDirection = true
end


local function InitializeHeader(_iInventory)
	-- Get the headerGroup, "Name" header, "NameName" header, custom toggle header, & the Arrow control
	-- for this inventory
	local HeaderGroup = PLAYER_INVENTORY.inventories[_iInventory].sortHeaders
	local hNameHeader = HeaderGroup.headerContainer:GetNamedChild("Name")
	local hNameNameHeader = hNameHeader:GetNamedChild("Name")
	local hSortItAscHeader = HeaderGroup.headerContainer:GetNamedChild(SORTASC_HEADERNAME)
	local hArrowHeader = HeaderGroup.headerContainer:GetNamedChild("Arrow")
	
	-- Get Pack name for last pack in use & it's sort pack
	local sStartingBackpackSort = SortIt.SavedVariables.curPackName[_iInventory]
	local curSortPack = LIBSI:GetCurSortPack(SortIt.name, sStartingBackpackSort)
	
	if curSortPack then 
		-- Set the display text & sort key for the "Name" sort header
		-- Set up the sort direction & initial sort direction for the header & headerGroup
		HeaderGroup:SetHeaderNameForKey("name", curSortPack.displayName) -- must do first before changing the key
		HeaderGroup.sortDirection = curSortPack.startAscOrder
		hNameHeader.key = curSortPack.sortKeys[1].key
		hNameHeader.sortDirection = curSortPack.startAscOrder
		hNameHeader.initialDirection = curSortPack.startAscOrder
		hSortItAscHeader.initialDirection = curSortPack.startAscOrder
		-- Set the inventories current sortOrder to match
		local inventory 	 = PLAYER_INVENTORY.inventories[_iInventory]
		inventory.currentSortOrder = curSortPack.startAscOrder
		
		-- Set the starting SortKey for my Ascending direction toggle header
		hSortItAscHeader.key = curSortPack.sortKeys[1].key
		-- Now that the header & headerGroup info is set, change the sort
		LIBSI:ChangeSort(SortIt.name, sStartingBackpackSort, _iInventory, curSortPack.startAscOrder)
	end
	-- NOTE: If the curPack doesn't exist, there are no sortPacks, so we don't need to set the Sort
	-- The game automatically sets it up as the default "Name" header, but we still want to
	-- Fix the arrows. But this needs to be AFTER the above code, because if the sortPack existed
	-- we changed the headerGroup.sortDirection, so that had to be done before the below code.
	-- Unhide & fix the alignment, texture, and re-anchor the sortDirection Arrow 
    local textWidth = hNameNameHeader:GetTextDimensions()
    local alignmentFn = sortArrowAlignments[hNameNameHeader:GetHorizontalAlignment()]
    hArrowHeader:SetHidden(false)
	
    if(HeaderGroup.sortDirection == ZO_SORT_ORDER_UP) then
        hArrowHeader:SetTexture(SORT_ARROW_UP)
    else
        hArrowHeader:SetTexture(SORT_ARROW_DOWN)
    end
    if(alignmentFn) then
        hArrowHeader:ClearAnchors()
        alignmentFn(hArrowHeader, hNameHeader, textWidth)
    end
	
	if _iInventory == INVENTORY_BACKPACK then
		-- Initially selected SortHeader is the "New" child, that messes up the first click on my header
		-- Change it to the "Name" child Sortheader, Only the backpack Inv has the new header
		-- so only need to change it for the backpack, the rest start with the "Name" child selected
		HeaderGroup.selectedSortHeader = hNameHeader
		-- Hide the "New" header column from all views
		local tabFilters = PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].tabFilters
		for _, filter in pairs(tabFilters) do
			filter.hiddenColumns["age"] = true
		end
	end
end


function SortIt.InitializeHeaders()
	CreateSortOrderToggleHeaders() -- must be called first so others can access the toggle headers
	InitializeHeader(INVENTORY_BACKPACK)
	InitializeHeader(INVENTORY_BANK)
	InitializeHeader(INVENTORY_GUILD_BANK)
end










