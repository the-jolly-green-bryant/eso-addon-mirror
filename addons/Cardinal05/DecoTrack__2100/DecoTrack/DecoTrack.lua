if not DecoTrack then DecoTrack = { } end
local DT = DecoTrack

if not DT.Interop then DT.Interop = { } end
local Interop = DT.Interop

local LAM

-- Add-on Data --

DT.ADDON_NAME =						"DecoTrack"
DT.ADDON_VERSION =					"2.7"
DT.ADDON_AUTHOR =					"@Cardinal05, @Architectura"

DT.JUMP_TIMEOUT =					1000 * 15
DT.UPDATE_DELAY =					1000 * 1
DT.UPDATE_NEXT_HOUSE_DELAY =		1000 * 1.5
DT.PRIORITY_SAVE_INTERVAL =			1000 * 60
DT.MAX_HOUSE_ID =					250

DT.DefaultSettings = { }

DT.BAG_IDS = { }
DT.BAG_IDS[ BAG_BACKPACK ] = true
DT.BAG_IDS[ BAG_BANK ] = true
DT.BAG_IDS[ BAG_SUBSCRIBER_BANK ] = true
DT.BAG_IDS[ BAG_FURNITURE_VAULT ] = true
DT.BAG_IDS[ BAG_HOUSE_BANK_EIGHT ] = true
DT.BAG_IDS[ BAG_HOUSE_BANK_FIVE ] = true
DT.BAG_IDS[ BAG_HOUSE_BANK_FOUR ] = true
DT.BAG_IDS[ BAG_HOUSE_BANK_NINE ] = true
DT.BAG_IDS[ BAG_HOUSE_BANK_ONE ] = true
DT.BAG_IDS[ BAG_HOUSE_BANK_SEVEN ] = true
DT.BAG_IDS[ BAG_HOUSE_BANK_SIX ] = true
DT.BAG_IDS[ BAG_HOUSE_BANK_TEN ] = true
DT.BAG_IDS[ BAG_HOUSE_BANK_THREE ] = true
DT.BAG_IDS[ BAG_HOUSE_BANK_TWO ] = true

DT.LIMITS = { }
DT.LIMITS[ HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_COLLECTIBLE ] = "Special Collectibles"
DT.LIMITS[ HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM ] = "Special Furnishings"
DT.LIMITS[ HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_COLLECTIBLE ] = "Collectible Furnishings"
DT.LIMITS[ HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM ] = "Traditional Furnishings"

DT.BOUND_TEXTURE = zo_iconFormat("esoui/art/tutorial/gamepad/gp_crowns.dds", 20, 20)
DT.UNBOUND_TEXTURE = zo_iconFormat("esoui/art/inventory/inventory_tradable_icon.dds", 16, 20)

DT.Data = nil
DT.JumpToHouseId = 0
DT.UpdateCount = 0
DT.IsDirty = false

local function requestPrioritySave()
	if GetAddOnManager then
		local manager = GetAddOnManager()

		if manager and manager.RequestAddOnSavedVariablesPrioritySave then
			manager:RequestAddOnSavedVariablesPrioritySave( DT.ADDON_NAME )
		end
	end
end

-- Utility Methods --

local function trim( s )
	if s then
		return s:gsub( "^%s*(.-)%s*$", "%1" )
	else
		return nil
	end
end

-- Housing Methods --

function DT.IsHouseOwner()
	return IsOwnerOfCurrentHouse()
end

function DT.IsBagAccessible( bagId )
	return not ( 0 == GetNumBagUsedSlots( bagId ) and 0 == GetBagUseableSize( bagId ) )
end

function DT.IsItemIdCollectible( itemId )
	local collectibleId = tonumber( itemId )
	if collectibleId then
		local cName = GetCollectibleName( collectibleId )
		local cLink = GetCollectibleLink( collectibleId )
		return "" ~= cName, cName, cLink
	end
	return false, "", ""
end

function DT.IsItemIdFurniture( itemId )
	local fLink = DT.GetFurnitureItemIdLink( itemId )
	if IsItemLinkPlaceableFurniture( fLink ) then
		local fName = GetItemLinkName( fLink )
		return true, fName, fLink
	end
	return false, nil, nil
end

function DT.GetFurnitureLink( id )
	local link, collectibleLink = GetPlacedFurnitureLink( id, LINK_STYLE_BRACKETS )
	if nil == link or "" == link then
		return collectibleLink
	end
	return link
end

function DT.GetFurnitureLinkItemId( link )
	if nil == link or "" == link then
		return nil
	end

	local startIndex

	if string.sub( link, 4, 9 ) == ":item:" then
		startIndex = 10
	elseif string.sub( link, 4, 16 ) == ":collectible:" then
		startIndex = 17
	else
		return link
	end

	local colonIndex = string.find( link, ":", startIndex + 1 )
	local pipeIndex = string.find( link, "|", startIndex + 1 )

	if nil == colonIndex and nil == pipeIndex then return nil end
	if nil ~= colonIndex and nil ~= pipeIndex then colonIndex = math.min( colonIndex, pipeIndex ) end

	return tonumber( string.sub( link, startIndex, ( nil ~= colonIndex and colonIndex or pipeIndex ) - 1 ) )
end

function DT.GetFurnitureItemId( id )
	local link = DT.GetFurnitureLink( id )
	return DT.GetFurnitureLinkItemId( link ), link
end

function DT.GetFurnitureItemIdLink( itemId )
	itemId = tonumber( itemId )
	if nil == itemId then
		return nil
	end

	if 10000 > itemId then
		return "|H1:collectible:" .. tostring( itemId ) .. "|h|h"
	else
		return "|H1:item:" .. tostring( itemId ) .. string.rep( ":0", 20 ) .. "|h|h"
	end
end

function DT.GetFurnitureInfo( itemId )
	if nil == itemId then
		return nil
	end

	local category, link, isCollectible, name, subcategory

	isFurniture, name, link = DT.IsItemIdFurniture( itemId )
	if isFurniture then
		local categoryId, subcategoryId = GetFurnitureDataCategoryInfo( GetItemLinkFurnitureDataId( link ) )

		category = GetFurnitureCategoryInfo( categoryId )
		subcategory = GetFurnitureCategoryInfo( subcategoryId )

		return itemId, name, link, category, subcategory, itemId
	end

	isCollectible, name, link = DT.IsItemIdCollectible( itemId )
	if isCollectible then
		local collectibleId = GetCollectibleIdFromLink( link )
		local categoryId, subcategoryId = GetFurnitureDataCategoryInfo( GetCollectibleFurnitureDataId( collectibleId ) )

		category = GetFurnitureCategoryInfo( categoryId )
		subcategory = GetFurnitureCategoryInfo( subcategoryId )

		return itemId, name, link, category, subcategory, collectibleId
	end

	return nil
end

function DT.GetItemId( idOrLink )
	if idOrLink == nil then
		return nil
	end

	local itemId

	if "string" == type( idOrLink ) then
		itemId = DT.GetFurnitureLinkItemId( idOrLink )
	else
		itemId = DT.GetFurnitureItemId( idOrLink )
	end

	if nil ~= itemId then
		if not DT.IsItemIdCollectible( itemId ) then
			return itemId
		end
	end
end

function DT.GetLimitType( link )
	local itemId = DT.GetItemId( link )
	local dataId

	if GetCollectibleLink( itemId ) then
		dataId = GetCollectibleFurnitureDataId( itemId )
	else
		dataId = GetItemLinkFurnitureDataId( link )
	end

	if dataId then
		local _, _, _, limitType = GetFurnitureDataInfo( dataId )
		local limitName = DT.LIMITS[limitType]

		return limitName, limitType
	end
end

-- Object Constructors --

function DT.CreateHouse( iHouseId )
	local obj

	if nil ~= iHouseId then
		local collectibleId = GetCollectibleIdForHouse( iHouseId )
		local name = GetCollectibleName( collectibleId )
		local nickname = GetCollectibleNickname( collectibleId )
		if nil ~= nickname and "" ~= nickname then
			name = string.format( "%s (%s)", name, nickname )
		end
		obj = { HouseId = iHouseId, HouseName = name, ItemCount = 0, Items = { }, BoundItemCount = 0, BoundItems = { }, }
	end

	return obj
end

function DT.CreateBag( iBagId )
	local obj = nil 

	if iBagId ~= nil then
		local name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType, hint, isPlaceholder
		if iBagId == BAG_FURNITURE_VAULT then
			name = GetCollectibleName( GetFurnitureVaultCollectibleId() )
		elseif IsHouseBankBag( iBagId ) then
			local collectibleId = GetCollectibleForHouseBankBag( iBagId )
			name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType, hint, isPlaceholder = GetCollectibleInfo( collectibleId )
			name = name .. " (" .. GetCollectibleNickname( collectibleId ) .. ")"
		elseif iBagId == BAG_BACKPACK then
			name = GetUnitName( "player" )
			iBagId = GetCurrentCharacterId()
		else
			name = "Bank"
		end
		obj = { HouseId = "BAG" .. tostring( iBagId ), HouseName = name, ItemCount = 0, Items = { }, BoundItemCount = 0, BoundItems = { }, }
	end

	return obj
end

-- Data --

function DT.InitHouses( data )
	local version = data.Version
	local houses = data.Houses

	if nil == houses then
		houses = { }
		data.Houses = houses
	end

	if nil == version or 2 > version then
		for houseId, house in pairs( houses ) do
			local newItems = { }
			local count

			for _, itemId in pairs( house.Items ) do
				if "table" == type( itemId ) then
					if not DT.IsItemIdCollectible( itemId.I ) then
						itemId = itemId.I
					else
						itemId = nil
					end
				elseif DT.IsItemIdCollectible( itemId ) then
					itemId = nil
				end

				if nil ~= itemId then
					count = newItems[ itemId ]
					if nil == count then count = 0 end
					newItems[ itemId ] = count + 1
				end
			end

			house.Items = newItems
		end

		version = 2
		data.Version = version
	end

	if nil == version or 3 > version then
		for houseId, house in pairs( houses ) do
			house.Icon = nil
			house.CollectibleId = nil

			if not house.BoundItems then
				house.BoundItems = { }
			end
		end

		version = 3
		data.Version = version
	end
end

function DT.UpdateTooltip( control, link )
	local addenda, total = DT.GenerateTooltipInfo( link )

	if ( addenda and "" ~= addenda ) then
		ZO_Tooltip_AddDivider( control )
		control:AddLine( addenda, "$(MEDIUM_FONT)|$(KB_16)" )

		if total and "" ~= total then
			control:AddLine( total, "$(MEDIUM_FONT)|$(KB_16)", nil, nil, nil, nil, nil, TEXT_ALIGN_CENTER )
		end
	end
end

do
	local function ShadowTooltipMethod( control, method, linkFunction )
		local original = control[method]

		control[method] = function( control, ... )
			if original then
				original( control, ... )
			end

			local link = linkFunction( ... )
			if link then
				DT.UpdateTooltip( control, link )
			end
		end
	end

	function DT.RegisterTooltips()
		ShadowTooltipMethod( PopupTooltip, "SetLink", function( link ) return link end )
		ShadowTooltipMethod( ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink )
		ShadowTooltipMethod( ItemTooltip, "SetBagItem", GetItemLink )
		ShadowTooltipMethod( ItemTooltip, "SetLootItem", GetLootItemLink )
		ShadowTooltipMethod( ItemTooltip, "SetStoreItem", GetStoreItemLink )
		ShadowTooltipMethod( ItemTooltip, "SetTradeItem", GetTradeItemLink )
		ShadowTooltipMethod( ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink )
		ShadowTooltipMethod( ItemTooltip, "SetPlacedFurniture", function( id ) return DT.GetFurnitureLink( id ) end )

		if AwesomeGuildStore then
			AwesomeGuildStore:RegisterCallback( AwesomeGuildStore.callback.AFTER_INITIAL_SETUP, function()
				ShadowTooltipMethod( ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink )
			end)
		else
			ShadowTooltipMethod( ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink )
		end
	end
end

function DT.Initialize()
	LAM = LibAddonMenu2

	local SAVED_VAR_VERSION = 1
	DT.Data = ZO_SavedVars:NewAccountWide( "DecoTrackSavedVars", SAVED_VAR_VERSION, nil, nil )
	DT.InitSettings()
	DT.InitHouses( DT.Data )
	DT.RegisterTooltips()

	SLASH_COMMANDS[ "/deco" ] = DT.SlashCommand
end

function DT.AddHouseItem( house, itemId, stackSize, bound )
	if house ~= nil and house.Items ~= nil and itemId ~= nil then
		stackSize = stackSize or 1

		house.Items[ itemId ] = ( house.Items[ itemId ] or 0 ) + stackSize
		house.ItemCount = ( house.ItemCount or 0 ) + stackSize

		if bound then
			house.BoundItems[ itemId ] = ( house.BoundItems[ itemId ] or 0 ) + stackSize
			house.BoundItemCount = ( house.BoundItemCount or 0 ) + stackSize
		else
			house.BoundItems[ itemId ] = ( house.BoundItems[ itemId ] or 0 )
			house.BoundItemCount = ( house.BoundItemCount or 0 )
		end
	end
end

do
	local CachedKeys = {}

	function DT.GetHouseByCollectibleId( collectibleId )
		collectibleId = tonumber( collectibleId )
		if collectibleId then
			local key = CachedKeys[collectibleId]

			if not key then
				local bagId = GetCollectibleBankAccessBag( collectibleId )
				if bagId then
					key = string.format( "BAG%d", bagId )
				end

				if not key then
					for houseId = 1, DT.MAX_HOUSE_ID do
						local houseCollectibleId = GetCollectibleIdForHouse( houseId )
						if houseCollectibleId == collectibleId then
							key = houseId
							break
						end
					end
				end

				if not key then
					local characterId = collectibleId
					key = string.format( "BAG%d", characterId )
				end

				if key then
					CachedKeys[collectibleId] = key
				end
			end

			return DT.Data.Houses[ key ]
		end

		return nil
	end
end

function DT.ResetEntireDatabase()
	DT.Data.Houses = { }
	DT.InitHouses( DT.Data )
end

-- Settings --

function DT.InitSettings()
	if not DT.Data.Settings then
		DT.Data.Settings = { }
	end

	local panelName = DT.ADDON_NAME .. "LAM"
	local panelData =
	{
		type = "panel",
		name = DT.ADDON_NAME,
		displayName = DT.ADDON_NAME .. " - Settings",
		author = DT.ADDON_AUTHOR,
		version = DT.ADDON_VERSION,
		slashCommand = "/decotracksettings",
		registerForRefresh = true,
		registerForDefaults = false,
	}
	DT.LAMPanel = LAM:RegisterAddonPanel( panelName, panelData )

	local options = { }

	table.insert( options, {
		type = "custom",
	} )

	table.insert( options, {
		type = "header",
		name = "Furniture Database",
	} )

	table.insert( options, {
		type = "button",
		name = "Update All Homes",
		func = function()
			if DT.UpdatingAllHouses then
				DT.SlashCommand( "cancel" )
			else
				DT.SlashCommand( "update" )
			end
			SCENE_MANAGER:HideCurrentScene()
		end,
		tooltip = "Automatically visits every home that you own in order to update your furniture database with the items placed in each home.\n\n" ..
			"NOTE:\n" ..
			"This is typically only necessary when " .. DT.ADDON_NAME .. " is first installed or after clearing and resetting the furniture database.\n\n" ..
			"Once each home has been visited once - by you or by using this feature - " .. DT.ADDON_NAME .. " automatically updates your database upon subsequent visits, provided that you keep the " .. DT.ADDON_NAME .. " add-on enabled for all characters.",
		disabled = false,
		requiresReload = false,
	} )

	table.insert( options, {
		type = "button",
		name = "Clear and Reset",
		func = function()
			DT.ResetEntireDatabase()
		end,
		tooltip = "Clears all furniture from your " .. DT.ADDON_NAME .. " database for your " .. GetDisplayName() .. " account, including your bank and characters, homes and storage chests.",
		disabled = false,
		isDangerous = true,
		requiresReload = true,
		warning = "Are you sure that you want to clear all furniture from your " .. DT.ADDON_NAME .. " database for your " .. GetDisplayName() .. " account, including your bank and characters, homes and storage chests?\n\n" ..
			"You should only do this if you wish to start DecoTrack over completely fresh as this will require you to once again log into each character and visit each of your homes in order to rebuild your furniture database.\n\n" ..
			"NOTE: This will require a UI reload.",
	} )

	table.insert( options, {
		type = "custom",
	} )

	for index, opt in ipairs( options ) do
		if "string" == type( opt.key ) and nil ~= opt.default then
			DT.SetDefaultSetting( opt.key, opt.default )
		end
	end

	LAM:RegisterOptionControls( panelName, options )
end

function DT.SetDefaultSetting( settingName, value )
	if "string" == type( settingName ) and "" ~= settingName then
		DT.DefaultSettings[ settingName ] = value
	end
end

function DT.GetSetting( settingName, suppressDefault )
	local value = DT.Data.Settings[ settingName ]
	if nil == value and not suppressDefault then
		value = DT.DefaultSettings[ settingName ]
	end
	return value
end

function DT.SetSetting( settingName, value )
	DT.Data.Settings[ settingName ] = value
end

-- Search --

function DT.CreateSearchResults( sSearchText )
	return { ItemCount = 0, BoundItemCount = 0, SearchText = sSearchText, Categories = { } }
end

function DT.AddSearchResult( oResults, sContainerName, sItemCategory, sItemName, sLink, count, boundCount )
	if oResults ~= nil and sContainerName ~= nil and sItemName ~= nil then
		if not count then
			count = 1
		end

		oResults.ItemCount = oResults.ItemCount + count
		oResults.BoundItemCount = oResults.BoundItemCount + boundCount

		sItemCategory = sItemCategory or "Miscellaneous"
		sItemName = sItemName or ""
		sLink = sLink or ""
		sContainerName = sContainerName or ""

		local cat = oResults.Categories[ sItemCategory ]
		if not cat then
			cat = { Name = sItemCategory, NameLower = string.lower(sItemCategory), ItemCount = 0, BoundItemCount = 0, Items = { } }
			oResults.Categories[ sItemCategory ] = cat
		end
		cat.ItemCount = cat.ItemCount + count
		cat.BoundItemCount = cat.BoundItemCount + boundCount

		local item = cat.Items[ sItemName ]
		if not item then
			item = { ItemCount = 0, BoundItemCount = 0, ItemName = sItemName, NameLower = string.lower(sItemName), ItemLink = sLink, Containers = { }, BoundContainers = { }, }
			cat.Items[ sItemName ] = item
		end
		item.ItemCount = item.ItemCount + count
		item.BoundItemCount = item.BoundItemCount + boundCount

		item.Containers[ sContainerName ] = ( item.Containers[ sContainerName ] or 0 ) + count
		item.BoundContainers[ sContainerName ] = ( item.BoundContainers[ sContainerName ] or 0 ) + boundCount

		return true
	end

	return false
end

do
	local function CategoryComparer(left, right)
		return left.NameLower < right.NameLower
	end

	local function ItemComparer(left, right)
		return left.NameLower < right.NameLower
	end

	local function ContainerComparer(left, right)
		return left.NameLower < right.NameLower
	end

	function DT.SearchItems( itemName )
		EVENT_MANAGER:UnregisterForUpdate("DecoTrack_SearchItems")

		if DT.IsDirty then
			d( "One moment please..." )
			EVENT_MANAGER:RegisterForUpdate("DecoTrack_SearchItems", 2000, function() DT.SearchItems( itemName ) end)
			return
		end

		itemName = string.lower( itemName )
		local results = DT.CreateSearchResults( itemName )
		local bFound

		df( "%s is searching for '%s' ...", DT.ADDON_NAME, itemName )

		for zoneId, house in pairs( DT.Data.Houses ) do
			for itemId, count in pairs( house.Items ) do
				local _, name, link, category, subcategory = DT.GetFurnitureInfo( itemId )
				local boundCount = house.BoundItems[ itemId ] or 0

				bFound, _, _ = PlainStringFind( string.lower( name ), itemName )
				if bFound then
					DT.AddSearchResult( results, house.HouseName, category, name, link, count, boundCount )
				end

				if not bFound then
					bFound, _, _ = PlainStringFind( string.lower( category ), itemName )
					if bFound then
						DT.AddSearchResult( results, house.HouseName, category, name, link, count, boundCount )
					end
				end

				if not bFound then
					bFound, _, _ = PlainStringFind( string.lower( house.HouseName ), itemName )
					if bFound then
						DT.AddSearchResult( results, house.HouseName, category, name, link, count, boundCount )
					end
				end
			end
		end

		do
			local categories = results.Categories
			local newCategories = {}
			results.SortedCategories = newCategories
			for catName, cat in pairs(categories) do
				table.insert(newCategories, cat)

				local items = cat.Items
				local newItems = {}
				cat.SortedItems = newItems
				for itemKey, item in pairs(items) do
					table.insert(newItems, item)

					local containers = item.Containers
					local newContainers = {}
					item.SortedContainers = newContainers
					for containerName, count in pairs(containers) do
						table.insert(newContainers, { Name = containerName, NameLower = string.lower(containerName), ItemCount = count, BoundItemCount = item.BoundContainers[containerName] or 0 })
					end
					table.sort(newContainers, ContainerComparer)
				end
				table.sort(newItems, ItemComparer)
			end
			table.sort(newCategories, CategoryComparer)
		end

		for _, cat in ipairs(results.SortedCategories) do
			df(DT.GenerateItemCountLine("      " .. string.upper(cat.Name), cat.ItemCount, cat.BoundItemCount, 0))

			for _, item in ipairs(cat.SortedItems) do
				df(DT.GenerateItemCountLine(item.ItemLink, item.ItemCount, item.BoundItemCount, 0))

				for _, container in ipairs(item.SortedContainers) do
					df(DT.GenerateItemCountLine(container.Name, container.ItemCount, container.BoundItemCount, 1))
				end
			end
		end

		df(DT.GenerateItemCountLine("Total", results.ItemCount, results.BoundItemCount))
	end
end

do
	local NormalColor = ZO_ColorDef:New( GetInterfaceColor( INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL ) )
	local SelectedColor = ZO_ColorDef:New( GetInterfaceColor( INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED ) )

	function DT.GenerateItemCountLine( label, totalCount, boundCount, indent )
		totalCount, boundCount = totalCount or 0, boundCount or 0
		local unboundCount = totalCount - boundCount
		local unboundString = unboundCount <= 0 and "" or tostring( unboundCount ) .. DT.UNBOUND_TEXTURE
		local boundString = boundCount <= 0 and "" or tostring( boundCount ) .. DT.BOUND_TEXTURE
		local nameString = NormalColor:Colorize( string.format( "%s%s", indent and indent > 0 and "+ " or "", label or "" ) )
		local quantityString = SelectedColor:Colorize( string.format( " x%s%s|r", unboundString, boundString ) )
		return nameString .. quantityString
	end
end

function DT.GenerateTooltipInfo( itemLink )
	local tooltip = {}
	local total, totalBound, totalString = 0, 0, ""

	if itemLink and DT.Data and DT.Data.Houses then
		local itemId = DT.GetItemId( itemLink )

		if itemId then
			for zoneId, house in pairs( DT.Data.Houses ) do
				if house.Items then
					local count = house.Items[itemId]
					if count and 0 < count then
						local boundCount = house.BoundItems[itemId] or 0
						total = total + count
						totalBound = totalBound + boundCount
						table.insert( tooltip, DT.GenerateItemCountLine( house.HouseName, count, boundCount ) )
					end
				end
			end
		end
	end

	if 1 < #tooltip then
		table.sort( tooltip )

		if 0 < total then
			totalString = DT.GenerateItemCountLine( "Total", total, totalBound )
		end
	end

	return table.concat( tooltip, "\n" ), totalString
end

-- Slash Commands --

function DT.SlashCommand( commandArgs )
	local options = { }
    local searchResult = { string.match( commandArgs, "^(%S*)%s*(.-)$" ) }

    for i, v in pairs( searchResult ) do
        if v ~= nil and v ~= "" then
            options[ #options + 1 ] = string.lower( v )
        end
    end

	if #options == 0 then
		local slash = "/deco"

		df( "%s Commands...", DT.ADDON_NAME )
		d( "__________________________" )
		d( "GENERAL" )
		df( "%s update", slash )
		df( "  Automatically visits every house that you own," )
		df( "  updating the furniture database for each house." )
		df( "%s totals", slash )
		df( "  Reports item count totals for each character, house and bank." )
		d( "__________________________" )
		d( "SEARCHES" )
		df( "%s item", slash )
		df( "  Searches all items for the specified item name." )
		df( "  You may also use part of the item name." )
		df( "%s bank", slash )
		df( "  Searches all items in your bank." )
		df( "%s category", slash )
		df( "  Searches all items in the specified category." )
		df( "  You may use part of the category name." )
		df( "%s character", slash )
		df( "  Searches all items in the specified character's inventory." )
		df( "%s coffer", slash )
		df( "  Searches all items in the specified house storage coffer or chest." )
		df( "  You may use part of the coffer or chest's name or nickname." )
		df( "%s house", slash )
		df( "  Searches all items in the specified house." )
		df( "  You may use part of the house name." )
		df( "|r\nDecoTrack version " .. DT.ADDON_VERSION .. " installed." )

		return
	end

	if "update" == options[1] then
		DT.UpdateAllHouses()
		return
	end

	if "total" == options[1] or "totals" == options[1] then
		DT.ReportTotals()
		return
	end

	if "cancel" == options[1] then
		if DT.UpdatingAllHouses then
			df( "Update process has been aborted." )
			DT.UpdatingAllHouses = nil
			EVENT_MANAGER:UnregisterForEvent( DT.ADDON_NAME, EVENT_ADD_ON_LOADED )
			CancelCast()

			return
		end

		df( "There is no update in progress." )
		return
	end

	DT.SearchItems( commandArgs )
end

-- Housing --

function DT.UpdateNextHouse()
	if nil == DT.UpdatingAllHouses then return end
	EVENT_MANAGER:UnregisterForUpdate( "DT.OnJumpFailed" )

	local house = DT.UpdatingAllHouses[ 1 ]
	if nil == house then
		d( " " )
		df( "%s has finished updating the furniture inventory database for all houses.", DT.ADDON_NAME )
		d( "The game will reload in 10 seconds to save your furniture data to disk." )

		DT.Data.UpdateCompleted = true
		DT.UpdatingAllHouses = nil
		ReloadUI()

		return
	end

	d( " " )
	df( "%s's next stop: %s (%d houses remaining)", DT.ADDON_NAME, house.HouseName, #DT.UpdatingAllHouses )
	df( "Type |cffffff/DECO CANCEL|r at any time to abort." )

	if GetCurrentZoneHouseId() == house.HouseId then
		d( " " )
		d( "Nevermind! You're already here. Moving on to the next house..." )
		table.remove( DT.UpdatingAllHouses, 1 )
		zo_callLater( DT.UpdateNextHouse, 1000 )
	else
		DT.JumpToHouseId = house.HouseId
		EVENT_MANAGER:RegisterForUpdate( DT.ADDON_NAME .. "JumpFailed", DT.JUMP_TIMEOUT, DT.OnJumpFailed )
		RequestJumpToHouse( house.HouseId )
	end
end

function DT.UpdateAllHouses()
	if nil ~= DT.UpdatingAllHouses then
		df( "An update is already in progress." )
		df( "Type |cffffff/DECO CANCEL|r at any time to abort." )
		return
	end

	DT.UpdatingAllHouses = { }
	DT.UpdatingAllHousesJumpFailures = 0

	for houseId = 1, DT.MAX_HOUSE_ID do
		local collectibleId = GetCollectibleIdForHouse( houseId )
		if nil ~= collectibleId and 0 ~= collectibleId then
			if IsCollectibleUnlocked( collectibleId ) then
				local houseName = GetCollectibleName( collectibleId )
				table.insert( DT.UpdatingAllHouses, { HouseId = houseId, HouseName = houseName } )
			end
		end
	end

	if 0 >= #DT.UpdatingAllHouses then
		df( "You currently do not own any houses." )
		DT.UpdatingAllHouses = nil
		return
	end

	df( "%s is visiting each of your homes to update the furniture database.", DT.ADDON_NAME )
	DT.UpdateNextHouse()
end

function DT.UpdateCurrentHouse()
	if DT.IsHouseOwner() ~= true then return nil end

	local houseId = GetCurrentZoneHouseId()
	local house = DT.CreateHouse( houseId )
	local furnitureId = nil
	local itemId = nil

	repeat
		furnitureId = GetNextPlacedHousingFurnitureId( furnitureId )
		if furnitureId ~= nil then
			itemId = DT.GetItemId( furnitureId )
			if nil ~= itemId then
				local link = GetPlacedFurnitureLink( furnitureId )
				local bound = IsItemLinkBound( link )
				DT.AddHouseItem( house, itemId, nil, bound )
			end
		end
	until furnitureId == nil

	DT.Data.Houses[ house.HouseId ] = house
	DT.hasVisitedAllOwnedHomes = nil
end

function DT.UpdateBag( bagId )
	if nil == bagId or not DT.BAG_IDS[ bagId ] then return end
	if not DT.IsBagAccessible( bagId ) then return end
	if bagId == BAG_SUBSCRIBER_BANK then bagId = BAG_BANK end

	local house = DT.CreateBag( bagId )

	for slotIndex = 0, GetBagSize( bagId ) - 1 do
		if IsItemPlaceableFurniture( bagId, slotIndex ) then
			local itemId = GetItemId( bagId, slotIndex )
			local stackSize = GetSlotStackSize( bagId, slotIndex )
			if nil ~= itemId and "" ~= itemId and 0 ~= itemId then
				local link = GetItemLink( bagId, slotIndex )
				local bound = IsItemLinkBound( link )
				DT.AddHouseItem( house, itemId, stackSize, bound )
			end
		end
	end

	if bagId == BAG_BANK then
		bagId = BAG_SUBSCRIBER_BANK

		for slotIndex = 0, GetBagSize( bagId ) - 1 do
			if IsItemPlaceableFurniture( bagId, slotIndex ) then
				local itemId = GetItemId( bagId, slotIndex )
				local stackSize = GetSlotStackSize( bagId, slotIndex )
				if nil ~= itemId and "" ~= itemId and 0 ~= itemId then
					local link = GetItemLink( bagId, slotIndex )
					local bound = IsItemLinkBound( link )
					DT.AddHouseItem( house, itemId, stackSize, bound )
				end
			end
		end

		DT.Data.Houses[ "BAG" .. tostring( BAG_SUBSCRIBER_BANK ) ] = nil
	end

	DT.Data.Houses[ house.HouseId ] = house
end

function DT.DeferredPrioritySave()
	EVENT_MANAGER:UnregisterForUpdate( "DecoTrack.PrioritySave" )
	requestPrioritySave()
end

function DT.UpdateCallback()
	EVENT_MANAGER:UnregisterForUpdate( "DecoTrack.Update" )
	DT.UpdateCurrentHouse()

	for bagId, _ in pairs( DT.BAG_IDS ) do
		if bagId ~= BAG_SUBSCRIBER_BANK then
			DT.UpdateBag( bagId )
		end
	end

	DT.IsDirty = false
	DT.UpdateCount = 0
	EVENT_MANAGER:RegisterForUpdate( "DecoTrack.PrioritySave", DT.PRIORITY_SAVE_INTERVAL, DT.DeferredPrioritySave )
	Interop.CallbackManager:OnFullUpdate()

	return house
end

function DT.QueueUpdate( changeCount )
	EVENT_MANAGER:UnregisterForUpdate( "DecoTrack.Update" )
	DT.UpdateCount = DT.UpdateCount + 1
	DT.IsDirty = true
	EVENT_MANAGER:RegisterForUpdate( "DecoTrack.Update", DT.UPDATE_DELAY, DT.UpdateCallback )
end

function DT.GetItemTotals()
	local itemCounts = { }
	local boundItemCounts = { }
	local totalCount = 0

	for houseId, house in pairs( DT.Data.Houses ) do
		if tostring( houseId ) ~= "BAG" .. tostring( BAG_SUBSCRIBER_BANK ) then
			for itemId, count in pairs( house.Items ) do
				totalCount = totalCount + count
				itemCounts[ itemId ] = ( itemCounts[ itemId ] or 0 ) + count
				boundItemCounts[ itemId ] = ( boundItemCounts[ itemId ] or 0 ) + ( house.BoundItems[ itemId ] or 0 )
			end
		end
	end

	return totalCount, itemCounts, boundItemCounts
end

function DT.ReportTotals()
	local total, totalBound = 0, 0
	local totals = { }

	for houseId, house in pairs( DT.Data.Houses ) do
		if house.HouseName and house.ItemCount and 0 < house.ItemCount then
			table.insert( totals, { house.HouseName or "", house.ItemCount or 0, house.BoundItemCount or 0 } )
			total = total + ( house.ItemCount or 0 )
			totalBound = totalBound + ( house.BoundItemCount or 0 )
		end
	end

	table.sort( totals, function( a, b ) return a[1] < b[1] end )

	d( "__________________" )
	d( "Total Items Report" )
	d( "__________________" )

	for _, entry in ipairs( totals ) do
		df( "|c00ffff%s |cffffff(|cffff00%d|cffffff item%s, %s|cffff00%d|cffffff)", entry[1], entry[2], 1 == entry[2] and "" or "s", DT.BOUND_TEXTURE, entry[3] )
	end

	df( "|c00ffff* Total items |cffff00%d%s |cffffff(|cffff00%d%s |cffffff) |c00ffff*", ( total - totalBound ), DT.UNBOUND_TEXTURE, totalBound, DT.BOUND_TEXTURE )
end

-- Interoperability --

local CALLBACK_MANAGER = ZO_CallbackObject:Subclass()
Interop.CallbackManager = CALLBACK_MANAGER:New()

function Interop.CallbackManager:OnFullUpdate()
	if not self.IsFiringCallbacks then
		self.IsFiringCallbacks = true
		self:FireCallbacks("FullUpdate", self)
		self.IsFiringCallbacks = false
	end
end

function Interop.GetAPI()
	return 5
end

function Interop.GetCountsByItemId( pItemId )
	local containers = { }
	local boundContainers = { }

	if nil == pItemId then
		return containers, boundContainers
	end

	for containerId, container in pairs( DT.Data.Houses ) do
		local count = container.Items[ pItemId ]
		if nil ~= count then
			containers[ container.HouseName ] = count
		end

		local boundCount = container.BoundItems[ pItemId ]
		if nil ~= boundCount then
			boundContainers[ container.HouseName ] = boundCount
		end
	end

	return containers, boundContainers
end

function Interop.AddSearchResult( results, category, link, count, boundCount, containerName )
	local categoryObj = results.Categories[ category ]
	if not categoryObj then
		categoryObj = { Count = 0, BoundCount = 0, Items = { } }
		results.Categories[ category ] = categoryObj
	end

	local itemObj = categoryObj.Items[ link ]
	if not itemObj then
		itemObj = { Count = 0, BoundCount = 0, Containers = { }, BoundContainers = { }, }
		categoryObj.Items[ link ] = itemObj
	end

	results.Count = results.Count + count
	results.BoundCount = results.BoundCount + boundCount
	categoryObj.Count = categoryObj.Count + count
	categoryObj.BoundCount = categoryObj.BoundCount + boundCount
	itemObj.Count = itemObj.Count + count
	itemObj.BoundCount = itemObj.BoundCount + boundCount
	itemObj.Containers[ containerName ] = count
	itemObj.BoundContainers[ containerName ] = boundCount
end

local function CompileFilter( filter )
	if not filter then return end

	filter = string.lower( trim( filter ) )
	if "" == filter then return end

	filter = string.gsub( string.gsub( filter, "\+ +", "\+" ), "\- +", "\-" )

	local terms = { SplitString( " ", filter ) }
	if not terms then
		return
	end

	local anyTerms, includeTerms, excludeTerms = { }, { }, { }
	local term

	for index = 1, #terms do
		term = trim( terms[index] )

		if term and "" ~= term then
			if "-" == string.sub( term, 1, 1 ) then
				term = string.sub( term, 2 )
				table.insert( excludeTerms, term )
			elseif "+" == string.sub( 1, 1 ) then
				term = string.sub( term, 2 )
				table.insert( includeTerms, term )
			else
				-- table.insert( anyTerms, term )
				table.insert( includeTerms, term )
			end
		end
	end

	return { anyTerms, includeTerms, excludeTerms }
end

local function IsMatch( compiledFilter, expression )
	if not compiledFilter then return true end

	local anyTerms, include, exclude = compiledFilter[1], compiledFilter[2], compiledFilter[3]
	local hasAny = 0 == #anyTerms

	expression = string.lower( trim( expression or "" ) )

	for index = 1, #anyTerms do
		if PlainStringFind( expression, anyTerms[index] ) then
			hasAny = true
			break
		end
	end

	if not hasAny then
		return false
	end

	for index = 1, #include do
		if not PlainStringFind( expression, include[index] ) then
			return false
		end
	end

	for index = 1, #exclude do
		if PlainStringFind( expression, exclude[index] ) then
			return false
		end
	end

	return true
end

function Interop.Search( search )
	local results = { Count = 0, BoundCount = 0, Categories = { } }
	local matched

	if nil == search then return results end
	local filter = CompileFilter( search )
	local name, link, category, subcategory

	for containerId, container in pairs( DT.Data.Houses ) do
		for itemId, count in pairs( container.Items ) do
			_, name, link, category, subcategory = DT.GetFurnitureInfo( itemId )

			if IsMatch( filter, string.format( "%s\n%s\n%s", tostring( name ), tostring( category ), tostring( container.HouseName ) ) ) then
				local boundCount = container.BoundItems[ itemId ] or 0
				Interop.AddSearchResult( results, category, link, count, boundCount, container.HouseName )
			end
		end
	end

	return results
end

function Interop.HasVisitedAllOwnedHomes()
	if nil == DT.hasVisitedAllOwnedHomes then
		DT.hasVisitedAllOwnedHomes = {}

		for houseId = 1, DT.MAX_HOUSE_ID do
			local collectibleId = GetCollectibleIdForHouse( houseId )
			if 0 ~= collectibleId and IsCollectibleUnlocked( collectibleId ) then
				local house = DT.Data.Houses[houseId]
				if not house or nil == house.ItemCount or nil == house.BoundItemCount then
					table.insert(DT.hasVisitedAllOwnedHomes, houseId)
				end
			end
		end
	end

	return #DT.hasVisitedAllOwnedHomes == 0
end

-- Event Handlers --

function DT.OnAddOnLoaded( event, addonName )
	if addonName == DT.ADDON_NAME then
		EVENT_MANAGER:UnregisterForEvent( DT.ADDON_NAME, EVENT_ADD_ON_LOADED )
		DT.Initialize()
	end
end

function DT.OnPlayerActivated()
	DT.QueueUpdate( 0 )

	if DT.Data.UpdateCompleted then
		DT.Data.UpdateCompleted = false
		d( "DecoTrack has updated your furniture inventory for all of your homes." )
		d( "Please remember to also do the following:" )
		d( " - Visit the bank to update its inventory." )
		d( " - Open each house storage chest and coffer to update their inventories." )
		d( " - Enable DecoTrack for each character and log in with them to update their inventories." )
	elseif DT.UpdatingAllHouses then
		EVENT_MANAGER:UnregisterForUpdate( DT.ADDON_NAME .. "JumpFailed", DT.JUMP_TIMEOUT, DT.OnJumpFailed )

		DT.UpdatingAllHousesJumpFailures = 0
		table.remove( DT.UpdatingAllHouses, 1 )

		zo_callLater( DT.UpdateNextHouse, DT.UPDATE_NEXT_HOUSE_DELAY )
	end
end

function DT.OnFurniturePlaced()
	DT.QueueUpdate( 1 )
end

function DT.OnFurnitureRemoved()
	DT.QueueUpdate( -1 )
end

function DT.OnCollectibleUpdated( eventId, collectibleId )
	local data = DT.Data
	if data then
		local house = DT.GetHouseByCollectibleId( collectibleId )
		if house then
			local name = GetCollectibleName( collectibleId )
			local nickname = GetCollectibleNickname( collectibleId )
			if nil ~= nickname and "" ~= nickname then
				name = string.format( "%s (%s)", name, nickname )
			end
			house.HouseName = name
		end
	end
end

function DT.OnBankAccess( event, bagId )
	if nil ~= bagId and DT.BAG_IDS[ bagId ] then
		DT.QueueUpdate( 0 )
	end
end

function DT.OnItemSlotChanged( event, bagId, slotId, isNew, itemSoundCategory, updateReason, stackCountChange )
	DT.QueueUpdate( stackCountChange )
end

function DT.OnJumpFailedCallback()
	EVENT_MANAGER:UnregisterForUpdate( "DT.OnJumpFailed" )

	if DT.UpdatingAllHouses then
		if GetCurrentZoneHouseId() ~= DT.JumpToHouseId then
			df( "Jump failed." )

			if 5 >= DT.UpdatingAllHousesJumpFailures then
				DT.UpdatingAllHousesJumpFailures = DT.UpdatingAllHousesJumpFailures + 1
				df( "Retrying jump to next house (Attempt %d)...", DT.UpdatingAllHousesJumpFailures )
				zo_callLater( DT.UpdateNextHouse, DT.UPDATE_NEXT_HOUSE_DELAY )

				return
			end

			df( "Too many attempts have failed. Process will resume after you leave this zone." )
			df( "Type |cffffff/DECO CANCEL|r at any time to abort." )
		end
	end
end

function DT.OnJumpFailed()
	EVENT_MANAGER:RegisterForUpdate( "DT.OnJumpFailed", 2000, DT.OnJumpFailedCallback )
end

-- Event Subscriptions --

EVENT_MANAGER:RegisterForEvent( DT.ADDON_NAME, EVENT_ADD_ON_LOADED, DT.OnAddOnLoaded )
EVENT_MANAGER:RegisterForEvent( DT.ADDON_NAME, EVENT_PLAYER_ACTIVATED, DT.OnPlayerActivated )
EVENT_MANAGER:RegisterForEvent( DT.ADDON_NAME, EVENT_HOUSING_FURNITURE_PLACED, DT.OnFurniturePlaced )
EVENT_MANAGER:RegisterForEvent( DT.ADDON_NAME, EVENT_HOUSING_FURNITURE_REMOVED, DT.OnFurnitureRemoved )
EVENT_MANAGER:RegisterForEvent( DT.ADDON_NAME, EVENT_COLLECTIBLE_UPDATED, DT.OnCollectibleUpdated )
EVENT_MANAGER:RegisterForEvent( DT.ADDON_NAME, EVENT_JUMP_FAILED, DT.OnJumpFailed )
EVENT_MANAGER:RegisterForEvent( DT.ADDON_NAME, EVENT_OPEN_BANK, DT.OnBankAccess )
EVENT_MANAGER:RegisterForEvent( DT.ADDON_NAME, EVENT_CLOSE_BANK, DT.OnBankAccess )
EVENT_MANAGER:RegisterForEvent( DT.ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, DT.OnItemSlotChanged )
