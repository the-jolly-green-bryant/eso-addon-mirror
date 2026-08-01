Mephisto = Mephisto or {}
local MP = Mephisto

MP.gui = MP.gui or {}
local MPG = MP.gui

function MP.GetSelectedPage( zone )
	if MP.pages[ zone.tag ] and MP.pages[ zone.tag ][ 0 ] then
		return MP.pages[ zone.tag ][ 0 ].selected
	end
	return nil
end

function MP.GetBossName( zone, index )
	if zone.bosses
		and zone.bosses[ index ]
		and zone.bosses[ index ].name
		and zone.bosses[ index ].name ~= GetString( MP_EMPTY ) then
		return zone.bosses[ index ].displayName or zone.bosses[ index ].name
	end
	return nil
end

function MP.ChangeItemLinkStyle( itemLink, linkStyle )
	return string.format( "%s%d%s", itemLink:sub( 1, 2 ), linkStyle, itemLink:sub( 4 ) )
end

function MP.CompareCP( setup )
	for slotIndex = 1, 12 do
		local savedSkillId = setup:GetCP()[ slotIndex ]
		local selectedSkilId = GetSlotBoundId( slotIndex, HOTBAR_CATEGORY_CHAMPION )
		if not savedSkillId or savedSkillId ~= selectedSkilId then
			return false
		end
	end
	return true
end

function MP.CheckGear( zone, pageId )
	local missingTable = {}
	local inventoryList = MP.GetItemLocation()
	for entry in MP.PageIterator( zone, pageId ) do
		local setup = Setup:FromStorage( zone.tag, pageId, entry.index )
		for _, gearSlot in ipairs( MP.GEARSLOTS ) do
			if gearSlot ~= EQUIP_SLOT_POISON and gearSlot ~= EQUIP_SLOT_BACKUP_POISON then
				local gear = setup:GetGearInSlot( gearSlot )
				if gear and gear.id ~= "0" then
					if not inventoryList[ gear.id ] then
						table.insert( missingTable, gear.link )

						-- sorts out duplicates
						inventoryList[ gear.id ] = 0
					end
				end
			end
		end
	end
	return missingTable
end

function MP.GetItemLocation()
	local inventoryList = {}
	for _, bag in ipairs( { BAG_WORN, BAG_BACKPACK } ) do
		for slot = 0, GetBagSize( bag ) do
			local lookupId = Id64ToString( GetItemUniqueId( bag, slot ) )
			inventoryList[ lookupId ] = {
				bag = bag,
				slot = slot,
			}
		end
	end
	return inventoryList
end

function MP.IsMythic( bag, slot )
	local _, _, _, _, _, _, _, _, itemType = GetItemInfo( bag, slot )
	if itemType == 6 then
		return true
	end
	return false
end

function MP.IsWipe()
	if not IsUnitGrouped( "player" ) then
		if IsUnitDeadOrReincarnating( "player" ) then
			return true
		end
		return false
	end
	for i = 1, GetGroupSize() do
		local groupTag = GetGroupUnitTagByIndex( i )
		if IsUnitOnline( groupTag ) then
			if not IsUnitDeadOrReincarnating( groupTag ) then
				return false
			end
		end
	end
	return true
end

function MP.Log( logMessage, logType, formatColor, ... )
	if MP.settings.printMessages == "chat" or MP.settings.printMessages == "alert" or MP.settings.printMessages == "announcement" then
		if not logType then logType = MP.LOGTYPES.NORMAL end
		if not formatColor then formatColor = "FFFFFF" end
		logMessage = string.format( logMessage, ... )
		logMessage = string.gsub( logMessage, "%[", "|c" .. formatColor .. "[" )
		logMessage = string.gsub( logMessage, "%]", "]|c" .. logType )
		logMessage = string.format( "|ca5cd84[|caca665M|ca91922P|ce4d09d]|r|c%s %s|r", logType, logMessage )

		if MP.settings.printMessages == "alert" then
			ZO_Alert( UI_ALERT_CATEGORY_ALERT, nil, logMessage )
		elseif MP.settings.printMessages == "announcement" then
			local sound = SOUNDS.NONE
			if logType == MP.LOGTYPES.ERROR then
				sound = SOUNDS.GENERAL_ALERT_ERROR
			end
			local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams( CSA_CATEGORY_MAJOR_TEXT,
																			  sound )
			messageParams:SetText( logMessage )
			messageParams:SetCSAType( CENTER_SCREEN_ANNOUNCE_TYPE_BATTLEGROUND_NEARING_VICTORY )
			CENTER_SCREEN_ANNOUNCE:AddMessageWithParams( messageParams )
		else
			CHAT_ROUTER:AddSystemMessage( logMessage )
		end
	end
end

function MP.GetTableLength( givenTable )
	local count = 0
	for _ in pairs( givenTable ) do
		count = count + 1
	end
	return count
end

-- food
function MP.FindFood( foodChoice )
	if not foodChoice then return nil end
	local consumables = MP.GetConsumableItems()
	for _, itemId in ipairs( foodChoice ) do
		if consumables[ itemId ] then
			return consumables[ itemId ]
		end
	end
	return nil
end

function MP.GetConsumableItems()
	local itemList = {}
	for slotIndex = 0, GetBagSize( BAG_BACKPACK ) do
		local itemType = GetItemType( BAG_BACKPACK, slotIndex )
		if itemType == ITEMTYPE_DRINK or itemType == ITEMTYPE_FOOD then
			local itemLink = GetItemLink( BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT )
			local itemId = GetItemLinkItemId( itemLink )
			itemList[ itemId ] = slotIndex
		end
	end
	return itemList
end

function MP.HasFoodIdRunning( itemId )
	for i = 1, GetNumBuffs( "player" ) do
		local abilityId = select( 11, GetUnitBuffInfo( "player", i ) )
		if MP.BUFFFOOD[ itemId ] == abilityId then
			return abilityId
		end
	end
	return false
end

function MP.HasFoodRunning()
	for i = 1, GetNumBuffs( "player" ) do
		local abilityId = select( 11, GetUnitBuffInfo( "player", i ) )
		if MP.lookupBuffFood[ abilityId ] then
			return abilityId
		end
	end
	return false
end

-- gui
function MPG.HidePage( hidden )
	if MPG.zones[ MP.selection.zone.tag ]
		and MPG.zones[ MP.selection.zone.tag ].scrollContainer then
		MPG.zones[ MP.selection.zone.tag ].scrollContainer:SetHidden( hidden )
	end
end

function MPG.SetSetupDisabled( zone, pageId, index, disabled )
	local setup = Setup:FromStorage( zone.tag, pageId, index )
	setup:SetDisabled( disabled )
	setup:ToStorage( zone.tag, pageId, index )
	MPG.RefreshSetup( zone, pageId, index )
end

function MPG.GetSortedZoneList()
	local zoneList = {}
	for _, zone in pairs( MP.zones ) do
		table.insert( zoneList, zone )
	end
	table.sort( zoneList, function( a, b ) return a.priority < b.priority end )
	return zoneList
end

function MPG.GearLinkTableToString( gearLinkTable )
	local gearText = {}
	for _, gear in ipairs( gearLinkTable ) do
		local itemQuality = GetItemLinkDisplayQuality( gear )
		local itemColor = GetItemQualityColor( itemQuality )
		local itemName = LocalizeString( "<<C:1>>", GetItemLinkName( gear ) )
		table.insert( gearText, itemColor:Colorize( itemName ) )
	end
	return table.concat( gearText, "\n" )
end

function MPG.SetTooltip( control, align, text )
	control:SetMouseEnabled( true )
	control:SetHandler( "OnMouseEnter", function( self )
		if text and text ~= "" then
			ZO_Tooltips_ShowTextTooltip( self, align, tostring( text ) )
		end
	end )
	control:SetHandler( "OnMouseExit", function( self )
		ZO_Tooltips_HideTextTooltip()
	end )
end

function MPG.ShowConfirmationDialog( name, dialogText, confirmCallback, cancelCallback )
	local uniqueId = string.format( "%s%s", "MephistoDialog", name )
	ESO_Dialogs[ uniqueId ] = {
		canQueue = true,
		uniqueIdentifier = uniqueId,
		title = { text = MP.displayName },
		mainText = { text = dialogText },
		buttons = {
			[ 1 ] = {
				text = SI_DIALOG_CONFIRM,
				callback = function()
					confirmCallback()
				end,
			},
			[ 2 ] = {
				text = SI_DIALOG_CANCEL,
				callback = function()
					if cancelCallback then
						cancelCallback()
					end
				end,
			},
		},
		setup = function() end,
	}
	ZO_Dialogs_ShowDialog( uniqueId, nil, { mainTextParams = {} } )
end

function MPG.ShowEditDialog( name, dialogText, initialText, confirmCallback, cancelCallback )
	local uniqueId = string.format( "%s%s", "MephistoDialog", name )
	ESO_Dialogs[ uniqueId ] = {
		canQueue = true,
		uniqueIdentifier = uniqueId,
		title = { text = MP.displayName },
		mainText = { text = dialogText },
		editBox = {},
		buttons = {
			[ 1 ] = {
				text = SI_DIALOG_CONFIRM,
				callback = function( dialog )
					local input = ZO_Dialogs_GetEditBoxText( dialog )
					confirmCallback( input )
				end,
			},
			[ 2 ] = {
				text = SI_DIALOG_CANCEL,
				callback = function()
					if cancelCallback then
						cancelCallback()
					end
				end,
			},
		},
		setup = function() end,
	}
	ZO_Dialogs_ShowDialog( uniqueId, nil, { mainTextParams = {}, initialEditText = initialText } )
end
