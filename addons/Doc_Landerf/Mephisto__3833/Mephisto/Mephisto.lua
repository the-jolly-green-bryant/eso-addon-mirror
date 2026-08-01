Mephisto = Mephisto or {}
local MP = Mephisto
local MPQ = MP.queue
local MPV = MP.validation

MP.name = "Mephisto"
MP.simpleName = "Mephisto"
MP.displayName =
"|ca5cd84M|caca665E|cae7A49P|ca91922H|cc2704DI|cd8b080S|ce1c895T|ce4d09dO|"
MP.version = "2.2.7"
MP.zones = {}
MP.currentIndex = 0

local cancelAnimation = false
local cpCooldown = 0
local wipeChangeCooldown = false
local bossLastName = "MP"
local blockTrash = nil
local logger = LibDebugLogger( MP.name )

function MP.GetSetupsAmount()
	local count = 0
	for _ in pairs( MP.setups[ MP.selection.zone.tag ][ MP.selection.pageId ] ) do
		count = count + 1
	end
	return count
end

function MP.LoadSetupAdjacent( direct )
	local zone = MP.selection.zone
	local pageId = MP.selection.pageId
	local newSetupId = MP.currentIndex + direct
	if newSetupId > MP.GetSetupsAmount() then newSetupId = 1 end
	if newSetupId < 1 then newSetupId = MP.GetSetupsAmount() end
	MP.LoadSetup( zone, pageId, newSetupId, false )
end

function MP.LoadSetup( zone, pageId, index, auto )
	if not zone or not pageId or not index then
		return false
	end

	local setup = Setup:FromStorage( zone.tag, pageId, index )

	if setup:IsEmpty() then
		if not auto then
			MP.Log( GetString( MP_MSG_EMPTYSETUP ), MP.LOGTYPES.INFO )
		end
		return false
	end

	if MP.settings.auto.gear then MP.LoadGear( setup ) end
	if MP.settings.auto.skills then MP.LoadSkills( setup ) end
	if MP.settings.auto.cp then MP.LoadCP( setup ) end
	if MP.settings.auto.food then MP.EatFood( setup ) end

	local pageName = MP.pages[ zone.tag ][ pageId ].name
	MP.gui.SetPanelText( zone.tag, pageName, setup:GetName() )

	local logMessage = IsUnitInCombat( "player" ) and GetString( MP_MSG_LOADINFIGHT ) or GetString( MP_MSG_LOADSETUP )
	local logColor = IsUnitInCombat( "player" ) and MP.LOGTYPES.INFO or MP.LOGTYPES.NORMAL
	MP.Log( logMessage, logColor, "FFFFFF", setup:GetName(), zone.name )

	setup:ExecuteCode( setup, zone, pageId, index, auto )
	MP.currentIndex = index
	MPV.SetupFailWorkaround()
	return true
end

function MP.LoadSetupCurrent( index, auto )
	local zone = MP.selection.zone
	local pageId = MP.selection.pageId
	MP.LoadSetup( zone, pageId, index, auto )
end

function MP.LoadSetupSubstitute( index )
	if not MP.zones[ "SUB" ] or not MP.pages[ "SUB" ] then return end
	MP.LoadSetup( MP.zones[ "SUB" ], MP.pages[ "SUB" ][ 0 ].selected, index, true )
end

function MP.SaveSetup( zone, pageId, index, skip )
	local setup = Setup:FromStorage( zone.tag, pageId, index )

	if not skip and not setup:IsEmpty() and MP.settings.overwriteWarning then
		MP.gui.ShowConfirmationDialog( "OverwriteConfirmation",
									   string.format( GetString( MP_OVERWRITESETUP_WARNING ), setup:GetName() ),
									   function()
										   MP.SaveSetup( zone, pageId, index, true )
									   end )
		return
	end

	if MP.settings.auto.gear then MP.SaveGear( setup ) end
	if MP.settings.auto.skills then MP.SaveSkills( setup ) end
	if MP.settings.auto.cp then MP.SaveCP( setup ) end
	if MP.settings.auto.food then MP.SaveFood( setup ) end

	setup:ToStorage( zone.tag, pageId, index )

	MP.gui.RefreshSetup( MP.gui.GetSetupControl( index ), setup )

	MP.Log( GetString( MP_MSG_SAVESETUP ), MP.LOGTYPES.NORMAL, "FFFFFF", setup:GetName() )
end

function MP.DeleteSetup( zone, pageId, index )
	local setup = Setup:FromStorage( zone.tag, pageId, index )
	local setupName = setup:GetName()

	if MP.setups[ zone.tag ]
		and MP.setups[ zone.tag ][ pageId ]
		and MP.setups[ zone.tag ][ pageId ][ index ] then
		table.remove( MP.setups[ zone.tag ][ pageId ], index )
	end

	MP.markers.BuildGearList()
	MP.conditions.LoadConditions()

	if zone.tag == MP.selection.zone.tag
		and pageId == MP.selection.pageId then
		MP.gui.BuildPage( zone, pageId )
	end

	MP.Log( GetString( MP_MSG_DELETESETUP ), MP.LOGTYPES.NORMAL, "FFFFFF", setupName )
end

function MP.ClearSetup( zone, pageId, index )
	local setup = Setup:FromStorage( zone.tag, pageId, index )
	local setupName = setup:GetName()

	setup:Clear()
	setup:SetName( setupName )
	setup:ToStorage( zone.tag, pageId, index )

	MP.markers.BuildGearList()
	MP.conditions.LoadConditions()

	if zone.tag == MP.selection.zone.tag
		and pageId == MP.selection.pageId then
		MP.gui.BuildPage( zone, pageId )
	end

	MP.Log( GetString( MP_MSG_DELETESETUP ), MP.LOGTYPES.NORMAL, "FFFFFF", setupName )
end

function MP.LoadSkills( setup )
	local delay = 0

	for hotbarCategory = 0, 1 do
		local hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar( hotbarCategory )
		local slotData = hotbarData:GetSlotData( 8 )

		-- wait until mythic get changed before changing ult if mythic is cryptcanon
		if slotData.abilityId == 195031 then
			delay = 600
		end
	end
	local skillTask = function()
		local skillTable = setup:GetSkills()
		for hotbarCategory = 0, 1 do
			for slotIndex = 3, 8 do
				local abilityId = skillTable[ hotbarCategory ][ slotIndex ]
				if abilityId and abilityId > 0 then
					MP.SlotSkill( hotbarCategory, slotIndex, abilityId )
				else
					if MP.settings.unequipEmpty then
						abilityId = 0
						MP.SlotSkill( hotbarCategory, slotIndex, 0 )
					end
				end
			end
		end
	end


	MPQ.Push( skillTask, delay )


	MP.prebuff.cache = {}
end

function MP.SlotSkill( hotbarCategory, slotIndex, abilityId )
	local hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar( hotbarCategory )
	-- if using cryptcanon dont slot skill, since cryptcanon does it on its own
	if abilityId == 195031 then
		return
	end
	if abilityId and abilityId > 0 then
		local progressionData = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId( abilityId )
		if progressionData
			and progressionData:GetSkillData()
			and progressionData:GetSkillData():IsPurchased() then
			hotbarData:AssignSkillToSlot( slotIndex, progressionData:GetSkillData() )
			return true
		else
			local abilityName = zo_strformat( "<<C:1>>", progressionData:GetName() )
			MP.Log( GetString( MP_MSG_SKILLENOENT ), MP.LOGTYPES.ERROR, "FFFFFF", abilityName )
			return false
		end
	else
		hotbarData:ClearSlot( slotIndex )
		return true
	end
end

function MP.SaveSkills( setup )
	local skillTable = {}

	for hotbarCategory = 0, 1 do
		skillTable[ hotbarCategory ] = {}
		for slotIndex = 3, 8 do
			local hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar( hotbarCategory )
			local slotData = hotbarData:GetSlotData( slotIndex )
			local abilityId = 0
			-- Cant save cryptcanons special ult.
			if slotData.abilityId == 195031 then
				abilityId = slotData.abilityId
			elseif
				not slotData:IsEmpty() then -- check if there is even a spell
				abilityId = slotData:GetEffectiveAbilityId()
			end

			skillTable[ hotbarCategory ][ slotIndex ] = abilityId
		end
	end

	setup:SetSkills( skillTable )
	--end
end

function MP.AreSkillsEqual( abilityId1, abilityId2 ) -- gets base abilityIds first, then compares
	if abilityId1 == abilityId2 then return true end

	local baseMorphAbilityId1 = MP.GetBaseAbilityId( previousAbilityId )
	if not baseMorphAbilityId1 then return end

	local baseMorphAbilityId2 = MP.GetBaseAbilityId( previousAbilityId )
	if not baseMorphAbilityId2 then return end

	if baseMorphAbilityId1 == baseMorphAbilityId2 then
		return true
	end
	return false
end

function MP.GetBaseAbilityId( abilityId )
	if abilityId == 0 then return 0 end
	local playerSkillProgressionData = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId( abilityId )
	if not playerSkillProgressionData then
		return nil
	end
	local baseMorphData = playerSkillProgressionData:GetSkillData():GetMorphData( MORPH_SLOT_BASE )
	return baseMorphData:GetAbilityId()
end

function MP.LoadGear( setup )
	if GetNumBagFreeSlots( BAG_BACKPACK ) == 0 then
		MP.Log( GetString( MP_MSG_FULLINV ), MP.LOGTYPES.INFO )
	end

	local itemTaskList = {}
	local inventoryList = MP.GetItemLocation()

	-- unequip mythic if needed
	local mythicDelay = 0
	if setup:GetMythic() then
		local mythicSlot = MP.HasMythic()
		local mythicId = Id64ToString( GetItemUniqueId( BAG_WORN, mythicSlot ) )
		local _, gear = setup:GetMythic()
		if mythicSlot and mythicId ~= gear.id then
			mythicDelay = 500
			table.insert( itemTaskList, {
				sourceBag = BAG_WORN,
				sourceSlot = mythicSlot,
				destBag = BAG_BACKPACK,
				destSlot = nil,
				itemId = mythicId,
			} )
		end
	end

	for _, gearSlot in ipairs( MP.GEARSLOTS ) do
		local gear = setup:GetGearInSlot( gearSlot )

		if gear then
			if gearSlot == EQUIP_SLOT_POISON or gearSlot == EQUIP_SLOT_BACKUP_POISON then
				-- handle poisons
				local lookupLink = GetItemLink( BAG_WORN, gearSlot, LINK_STYLE_DEFAULT )
				if lookupLink ~= gear.link then
					MP.poison.EquipPoisons( gear.link, gearSlot )
				end
			else
				-- equip item (if not already equipped)
				local lookupId = Id64ToString( GetItemUniqueId( BAG_WORN, gearSlot ) )

				if lookupId ~= gear.id then
					if inventoryList[ gear.id ] then
						local bag, slot = inventoryList[ gear.id ].bag, inventoryList[ gear.id ].slot

						local delay = MP.IsMythic( bag, slot ) and mythicDelay or 0
						local workaround = gearSlot == EQUIP_SLOT_BACKUP_MAIN and slot == EQUIP_SLOT_MAIN_HAND
						if workaround then
							-- Front to back
							-- Be sure to give enough time so backbar can find new location
							delay = delay + 500
						end


						table.insert( itemTaskList, {
							sourceBag = bag,
							sourceSlot = slot,
							destBag = BAG_WORN,
							destSlot = gearSlot,
							delay = delay,
							itemId = gear.id,
							workaround = workaround,
						} )
					else
						MP.Log( GetString( MP_MSG_GEARENOENT ), MP.LOGTYPES.ERROR, nil,
								MP.ChangeItemLinkStyle( gear.link, LINK_STYLE_BRACKETS ) )
					end
				end
			end
		else
			-- unequip if option is set to true, but ignore tabards if set to do so
			if MP.settings.unequipEmpty and (gearSlot ~= EQUIP_SLOT_COSTUME or ((gearSlot == EQUIP_SLOT_COSTUME) and MP.settings.ignoreTabards == false)) then
				table.insert( itemTaskList, {
					sourceBag = BAG_WORN,
					sourceSlot = gearSlot,
					destBag = BAG_BACKPACK,
					destSlot = nil,
				} )
			end
		end
	end
	MP.MoveItems( itemTaskList )
end

function MP.GetFreeSlots( bag )
	local freeSlotMap = {}
	for slot in ZO_IterateBagSlots( bag ) do
		local itemId = GetItemId( bag, slot )
		if itemId == 0 then
			table.insert( freeSlotMap, slot )
		end
	end
	return freeSlotMap
end

function MP.MoveItems( itemTaskList )
	for _, item in ipairs( itemTaskList ) do
		local itemTask = function()
			if not item.destSlot then
				item.destSlot = FindFirstEmptySlotInBag( item.destBag )
			end

			if not item.sourceSlot or item.workaround then
				local newLocation = MP.GetItemLocation()[ item.itemId ]
				if not newLocation then return end
				item.sourceBag = newLocation.bag
				item.sourceSlot = newLocation.slot
			end

			if not item.sourceSlot or not item.destSlot then return end

			--local itemId = Id64ToString(GetItemUniqueId(item.sourceBag, item.sourceSlot))
			--local itemLink = GetItemLink(item.sourceBag, item.sourceSlot, LINK_STYLE_BRACKETS)

			if item.destBag == BAG_WORN then
				EquipItem( item.sourceBag, item.sourceSlot, item.destSlot )
			else
				CallSecureProtected( "RequestMoveItem", item.sourceBag, item.sourceSlot, item.destBag, item.destSlot, 1 )
			end
		end

		MPQ.Push( itemTask, item.delay )
	end
end

function MP.HasMythic()
	for _, gearSlot in ipairs( MP.GEARSLOTS ) do
		if MP.IsMythic( BAG_WORN, gearSlot ) then
			return gearSlot
		end
	end
	return nil
end

function MP.Undress( itemTaskList )
	if GetNumBagFreeSlots( BAG_BACKPACK ) == 0 then
		MP.Log( GetString( MP_MSG_FULLINV ), MP.LOGTYPES.INFO )
	end

	if not itemTaskList or type( itemTaskList ) ~= "table" then
		local freeSlotMap = MP.GetFreeSlots( BAG_BACKPACK )
		itemTaskList = {}
		for _, gearSlot in ipairs( MP.GEARSLOTS ) do
			local _, stack = GetItemInfo( BAG_WORN, gearSlot )
			if stack > 0 then
				table.insert( itemTaskList, {
					sourceBag = BAG_WORN,
					sourceSlot = gearSlot,
					destBag = BAG_BACKPACK,
					destSlot = table.remove( freeSlotMap ),
					f = "m",
				} )
			end
		end
	end

	MP.MoveItems( itemTaskList )
end

function MP.SaveGear( setup )
	local gearTable = { mythic = nil }
	for _, gearSlot in ipairs( MP.GEARSLOTS ) do
		gearTable[ gearSlot ] = {
			id = Id64ToString( GetItemUniqueId( BAG_WORN, gearSlot ) ),
			link = GetItemLink( BAG_WORN, gearSlot, LINK_STYLE_DEFAULT ),
		}
		if MP.IsMythic( BAG_WORN, gearSlot ) then
			gearTable.mythic = gearSlot
		end
		if GetItemLinkItemType( gearTable[ gearSlot ].link ) == ITEMTYPE_TABARD then
			gearTable[ gearSlot ].creator = GetItemCreatorName( BAG_WORN, gearSlot )
		end
	end
	setup:SetGear( gearTable )
end

function MP.LoadCP( setup )
	if #setup:GetCP() == 0 then
		return
	end

	if MP.CompareCP( setup ) then
		return
	end

	local cpTask = function()
		-- fixes animation call with nil
		if CHAMPION_PERKS_SCENE:GetState() == "shown" then
			CHAMPION_PERKS:PrepareStarConfirmAnimation()
			cancelAnimation = false
		else
			cancelAnimation = true
		end
		PrepareChampionPurchaseRequest()
		for slotIndex = 1, 12 do
			local starId = setup:GetCP()[ slotIndex ]
			if starId and starId > 0 then
				local skillPoints = GetNumPointsSpentOnChampionSkill( starId )
				if skillPoints > 0 then
					AddHotbarSlotToChampionPurchaseRequest( slotIndex, starId )
				else
					MP.Log( GetString( MP_MSG_CPENOENT ), MP.LOGTYPES.ERROR, MP.CPCOLOR[ slotIndex ],
							zo_strformat( "<<C:1>>", GetChampionSkillName( starId ) ) )
				end
			else
				if MP.settings.unequipEmpty then
					AddHotbarSlotToChampionPurchaseRequest( slotIndex, 0 )
				end
			end
		end
		SendChampionPurchaseRequest()
	end

	if cpCooldown > 0 then
		zo_callLater( function()
						  MPQ.Push( cpTask )
						  MP.Log( GetString( MP_MSG_CPCOOLDOWNOVER ), MP.LOGTYPES.INFO )
					  end, cpCooldown * 1000 )
		MP.Log( GetString( MP_MSG_CPCOOLDOWN ), MP.LOGTYPES.INFO, nil, tostring( cpCooldown ) )
		return
	end

	MPQ.Push( cpTask )
end

function MP.SaveCP( setup )
	local cpTable = {}
	for slotIndex = 1, 12 do
		cpTable[ slotIndex ] = GetSlotBoundId( slotIndex, HOTBAR_CATEGORY_CHAMPION )
	end
	setup:SetCP( cpTable )
end

function MP.UpdateCPCooldown()
	if cpCooldown > 0 then
		cpCooldown = cpCooldown - 1
		return
	end
	cpCooldown = 0
	EVENT_MANAGER:UnregisterForUpdate( MP.name .. "CPCooldownLoop" )
end

function MP.EatFood( setup )
	local savedFood = setup:GetFood()
	if not savedFood.id then return end

	local currentFood = MP.HasFoodRunning()
	if MP.BUFFFOOD[ savedFood.id ] == currentFood then
		-- same bufffood, dont renew it
		return
	end

	local foodChoice = MP.lookupBuffFood[ MP.BUFFFOOD[ savedFood.id ] ]

	foodTask = function()
		local foodIndex = MP.FindFood( foodChoice )
		if not foodIndex then
			MP.Log( GetString( MP_MSG_FOODENOENT ), MP.LOGTYPES.ERROR )
			return
		end
		CallSecureProtected( "UseItem", BAG_BACKPACK, foodIndex )

		-- check if eaten
		-- API cannot track sprinting
		zo_callLater( function()
						  if not MP.HasFoodIdRunning( savedFood.id ) then
							  MPQ.Push( foodTask )
						  end
					  end, 1000 )
	end
	MPQ.Push( foodTask )
end

function MP.SaveFood( setup, foodIndex )
	if not foodIndex then
		local currentFood = MP.HasFoodRunning()
		local foodChoice = MP.lookupBuffFood[ currentFood ]
		foodIndex = MP.FindFood( foodChoice )
		if not foodIndex then
			MP.Log( GetString( MP_MSG_NOFOODRUNNING ), MP.LOGTYPES.INFO )
			return
		end
	end

	local foodLink = GetItemLink( BAG_BACKPACK, foodIndex, LINK_STYLE_DEFAULT )
	local foodId = GetItemLinkItemId( foodLink )

	setup:SetFood( {
		link = foodLink,
		id = foodId,
	} )
end

function MP.SetupIterator()
	local setupList = {}
	for _, zone in ipairs( MP.gui.GetSortedZoneList() ) do
		if MP.setups[ zone.tag ] then
			for pageId, _ in ipairs( MP.setups[ zone.tag ] ) do
				if MP.setups[ zone.tag ][ pageId ] then
					for index, setup in ipairs( MP.setups[ zone.tag ][ pageId ] ) do
						if setup then
							table.insert( setupList, { zone = zone, pageId = pageId, index = index, setup = setup } )
						end
					end
				end
			end
		end
	end

	local i = 0
	return function()
		i = i + 1
		return setupList[ i ]
	end
end

function MP.PageIterator( zone, pageId )
	local setupList = {}
	if MP.setups[ zone.tag ] and MP.setups[ zone.tag ][ pageId ] then
		for index, setup in ipairs( MP.setups[ zone.tag ][ pageId ] ) do
			if setup then
				table.insert( setupList, { zone = zone, pageId = pageId, index = index, setup = setup } )
			end
		end
	end

	local i = 0
	return function()
		i = i + 1
		return setupList[ i ]
	end
end

function MP.OnBossChange( _, isBoss, manualBossName )
	if IsUnitInCombat( "player" ) and not manualBossName then
		return
	end

	if WasRaidSuccessful() then
		return
	end

	local bossName = GetUnitName( "boss1" )
	local sideBoss = GetUnitName( "boss2" )

	if manualBossName then
		bossName = manualBossName
	end

	if bossName == GetString( MP_TRASH ) then
		bossName = ""
	end

	if #bossName == 0 and #sideBoss > 0 then
		bossName = sideBoss
	end

	if blockTrash and #bossName == 0 then
		--d("Trash is being blocked.")
		return
	end

	if #bossName > 0 and not IsUnitInCombat( "player" ) then
		--d("Changed to boss. Block trash for 6s.")
		if blockTrash then
			--d("Boss detected. Remove trash blockade. #" .. bossName)
			zo_removeCallLater( blockTrash )
			blockTrash = nil
		end
		--d("New trash blockade.")
		blockTrash = zo_callLater( function()
									   --d("Trash blockade over.")
									   blockTrash = nil
									   --MP.OnBossChange(_, true, manualBossName)
									   MP.OnBossChange( _, true, nil )
								   end, 6000 )
	end

	if bossName == bossLastName then
		return
	end

	if wipeChangeCooldown or MP.IsWipe() then
		return
	end

	--d("BOSS: " .. bossName)

	bossLastName = bossName
	zo_callLater( function()
					  MP.currentZone.OnBossChange( bossName )
				  end, 500 )
end

function MP.OnZoneChange( _, _ )
	local isFirstZoneAfterReload = (MP.currentZoneId == 0)
	local zone, x, y, z = GetUnitWorldPosition( "player" )
	if zone == MP.currentZoneId then
		-- no zone change
		return
	end
	MP.currentZoneId = zone

	-- reset old zone
	MP.currentZone.Reset()
	MP.conditions.ResetCache()

	if MP.lookupZones[ zone ] then
		MP.currentZone = MP.lookupZones[ zone ]
	else
		MP.currentZone = MP.zones[ "GEN" ]
	end

	bossLastName = "MP"

	zo_callLater( function()
					  -- init new zone
					  MP.currentZone.Init()
					  -- change ui if loaded, only swap if trial zone
					  if isFirstZoneAfterReload or MP.currentZone.tag ~= "GEN" then
						  MP.gui.OnZoneSelect( MP.currentZone )
					  end

					  if MP.settings.fixes.surfingWeapons then
						  MP.fixes.FixSurfingWeapons()
					  end

					  if MP.settings.autoEquipSetups
						  and not isFirstZoneAfterReload
						  and MP.currentZone.tag ~= "PVP" then
						  -- equip first setup
						  local firstSetupName = MP.currentZone.bosses[ 1 ]
						  if firstSetupName then
							  MP.OnBossChange( _, false, firstSetupName.name )
						  end
					  end
				  end, 250 )
end

function MP.RegisterEvents()
	EVENT_MANAGER:UnregisterForEvent( MP.name, EVENT_ADD_ON_LOADED )

	-- repair cp animation
	ZO_PreHook( CHAMPION_PERKS, "StartStarConfirmAnimation", function()
		if cancelAnimation then
			cancelAnimation = false
			return true
		end
	end )

	-- cp cooldown
	EVENT_MANAGER:RegisterForEvent( MP.name, EVENT_CHAMPION_PURCHASE_RESULT, function( _, result )
		if result == CHAMPION_PURCHASE_SUCCESS then
			cpCooldown = 31
			EVENT_MANAGER:RegisterForUpdate( MP.name .. "CPCooldownLoop", 1000, MP.UpdateCPCooldown )
		end
	end )

	-- check for wipe
	EVENT_MANAGER:RegisterForEvent( MP.name, EVENT_UNIT_DEATH_STATE_CHANGED, function( _, unitTag, isDead )
		if not isDead then return end
		if not IsUnitGrouped( "player" ) and unitTag ~= "player" then return end
		if IsUnitGrouped( "player" ) and unitTag:sub( 1, 1 ) ~= "g" then return end

		if not wipeChangeCooldown and MP.IsWipe() then
			wipeChangeCooldown = true
			zo_callLater( function()
							  wipeChangeCooldown = false
						  end, 15000 )
		end
	end )

	EVENT_MANAGER:RegisterForEvent( MP.name, EVENT_PLAYER_ACTIVATED, MP.OnZoneChange )
	EVENT_MANAGER:RegisterForEvent( MP.name, EVENT_BOSSES_CHANGED, MP.OnBossChange )
end

function MP.Init()
	MP.lookupZones = {}
	for _, zone in pairs( MP.zones ) do
		zone.lookupBosses = {}
		for i, boss in ipairs( zone.bosses ) do
			zone.lookupBosses[ boss.name ] = i
		end

		-- support multiple zones per entry
		if type( zone.id ) == "table" then
			for zoneId in pairs( zone.id ) do
				MP.lookupZones[ zoneId ] = zone
			end
		else
			MP.lookupZones[ zone.id ] = zone
		end
	end

	MP.lookupBuffFood = {}
	for itemId, abilityId in pairs( MP.BUFFFOOD ) do
		if not MP.lookupBuffFood[ abilityId ] then
			MP.lookupBuffFood[ abilityId ] = {}
		end
		table.insert( MP.lookupBuffFood[ abilityId ], itemId )
	end

	for i, trait in ipairs( MP.TRAITS ) do
		local char = tostring( MP.PREVIEW.CHARACTERS[ i ] )
		MP.PREVIEW.TRAITS[ trait ] = char
		MP.PREVIEW.TRAITS[ char ] = trait
	end

	local bufffoodCache = {}
	for food, _ in pairs( MP.BUFFFOOD ) do
		table.insert( bufffoodCache, food )
	end
	table.sort( bufffoodCache )
	for i, food in ipairs( bufffoodCache ) do
		local char = tostring( MP.PREVIEW.CHARACTERS[ i ] )
		MP.PREVIEW.FOOD[ food ] = char
		MP.PREVIEW.FOOD[ char ] = food
	end

	MP.currentZone = MP.zones[ "GEN" ]
	MP.currentZoneId = 0

	MP.selection = {
		zone = MP.zones[ "GEN" ],
		pageId = 1
	}
end

function MP.OnAddOnLoaded( _, addonName )
	if addonName ~= MP.name then return end

	-- Refactor this
	MP.Init()
	MP.menu.Init()
	MP.queue.Init()
	MP.gui.Init()
	MP.conditions.Init()
	MP.transfer.Init()
	MP.repair.Init()
	MP.poison.Init()
	MP.prebuff.Init()
	MP.banking.Init()
	MP.food.Init()
	MP.markers.Init()
	MP.preview.Init()
	MP.code.Init()
	MP.fixes.Init()

	MP.RegisterEvents()
end

EVENT_MANAGER:RegisterForEvent( MP.name, EVENT_ADD_ON_LOADED, MP.OnAddOnLoaded )
