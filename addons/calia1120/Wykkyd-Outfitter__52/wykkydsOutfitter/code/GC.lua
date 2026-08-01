local _addon = WYK_Outfitter

local function TrickString(number) return tostring(number)..""; end
local function Unstring(packed) return tonumber( packed ); end
local function ForceToDoItWrong( a, b )
	if a == nil then a = "" end
	if b == nil then b = "" end
	return TrickString(a) == TrickString(b);
	-- I know AreId64sEqual has far greater precision for Id64 values. HOWEVER... since saving these values off to SavedVariables to build item sets results in precision loss, since these numbers won't properly convert to strings and ZOS saved variables don't persist id64 values... yeah. You can see I don't have many options.
end

_addon.GC.GearSets = {}

_addon.GC.Queue = {}
_addon.GC.HasQueue = false
_addon.Settings.GearSetsChanged = false
_addon.Settings.GearSetsChanged2 = false

local stripKey = "isitreallytimetogetdressed"
_addon.GC.NekkidKey = stripKey

_addon.GC.GetDressed = function()
	if _addon.Settings.GearSets["sets"] == nil then _addon.Settings.GearSets["sets"] = {} end
	local gear = _addon.GC.ParseGear(true)
	local numWorn = 0; for slot,id in pairs(gear) do if id ~= -1 then numWorn = numWorn + 1 end end
	if numWorn > 1 then _addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."   You've started dressing already, why not continue?"); return; end
	if _addon.Settings.GearSets["sets"][stripKey] == nil then _addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Can't find your former wardrobe. Did you bank it when you took up nudism?"); return; end
	_addon.GC.LoadCommands(stripKey)
end

local function OutAsStrings( gearset )
	local t = {}
	for es,id64 in pairs( gearset ) do t[es] = TrickString( id64 ); end
	return t
end
local function InAsId64( gearset )
	local t = {}
	for es,id64 in pairs( gearset ) do t[es] = Unstring( id64 ); end
	return t
end

_addon.GC.SaveCommands = function(idx)
	_addon.Settings.GearSetsChanged = true
	_addon.Settings.GearSetsChanged2 = true
	if _addon.GC.HasQueue then _addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Gear Queue Still Processing, Please Wait..."); return; end
	_addon.Settings.GearSets["sets"][idx] = OutAsStrings( _addon.GC.ParseGear() )
	if _addon.Settings.GearSets["sets"]["keys"] == nil then _addon.Settings.GearSets["sets"]["keys"] = {} end
	_addon:table_findRemove( _addon.Settings.GearSets["sets"]["keys"], idx )
	table.insert( _addon.Settings.GearSets["sets"]["keys"], idx )
	_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Gear Set '"..idx.."' Saved.")
end

local function putOn( slot, set )
	local eslot = _addon.GLOBAL.EquipSlot[slot]
	--d(eslot)
	local id = Unstring( set[ eslot ] )
	--d(eslot.." "..id)
	if Unstring( id ) == -1 then UnequipItem( eslot ); return; end
	local bag, pos = _addon.GC.FindItem( id )
	if TrickString(GetItemUniqueId( 0, _addon.GLOBAL.EquipBagSlot[eslot] ) ) ~= set[ eslot ] then
		EquipItem( bag, pos, eslot )
		--d(bag.." "..pos.." "..eslot)
	end
end
local quickQueue = {}
local queuePosition = 1
local function HandleQuickQueue()
	if queuePosition > _addon:GetCountOf( quickQueue ) then
		quickQueue = {}
		queuePosition = 1
		_addon.GC.HasQueue = false
		_addon:OnUpdateCallback( "OUTFITTER swap gear around" )
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Gear move COMPLETE!" )
		return
	end
	_addon.GC.HasQueue = true	
	putOn( quickQueue[queuePosition].slot, quickQueue[queuePosition].set )	
	queuePosition = queuePosition + 1
end

_addon.GC.LoadCommands = function(idx)
	if not idx then return end
	if not _addon.Settings.GearSets["sets"][idx] then _addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Gear Set '"..idx.."' Not Found!"); return end
	if _addon.GC.HasQueue then _addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Gear Queue Still Processing, Please Wait..." ); return; end
	
	_addon.GC.HasQueue = true
	_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Loading Gear Set '" .. idx .. "'")
	local targetGear = _addon.Settings.GearSets["sets"][idx] -- [slot] = id
--
	quickQueue = {}; queuePosition = 1;
	quickQueue[1] = { slot="EQUIP_SLOT_RING1", set=targetGear, }
	quickQueue[2] = { slot="EQUIP_SLOT_RING2", set=targetGear, }
	quickQueue[3] = { slot="EQUIP_SLOT_MAIN_HAND", set=targetGear, }
	quickQueue[4] = { slot="EQUIP_SLOT_BACKUP_MAIN", set=targetGear, }
	quickQueue[5] = { slot="EQUIP_SLOT_OFF_HAND", set=targetGear, }
	quickQueue[6] = { slot="EQUIP_SLOT_BACKUP_OFF", set=targetGear, }
	quickQueue[7] = { slot="EQUIP_SLOT_COSTUME", set=targetGear, }
	quickQueue[8] = { slot="EQUIP_SLOT_HEAD", set=targetGear, }
	quickQueue[9] = { slot="EQUIP_SLOT_NECK", set=targetGear, }
	quickQueue[10] = { slot="EQUIP_SLOT_SHOULDERS", set=targetGear, }
	quickQueue[11] = { slot="EQUIP_SLOT_CHEST", set=targetGear, }
	quickQueue[12] = { slot="EQUIP_SLOT_WAIST", set=targetGear, }
	quickQueue[13] = { slot="EQUIP_SLOT_LEGS", set=targetGear, }
	quickQueue[14] = { slot="EQUIP_SLOT_FEET", set=targetGear, }
	quickQueue[15] = { slot="EQUIP_SLOT_HAND", set=targetGear, }
	--
	_addon:OnUpdateCallback( "OUTFITTER swap gear around", function() HandleQuickQueue() end, .1 )
end

_addon.GC.StripNaked = function()
	if _addon.Settings.GearSets["sets"] == nil then _addon.Settings.GearSets["sets"] = {} end
	local gear = _addon.GC.ParseGear(true)
	local numWorn = 0; for slot,id in pairs(gear) do if id ~= -1 then numWorn = numWorn + 1 end end
	if numWorn == 0 then _addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  You're already naked. Can't you feel the breeze?"); return; end
	_addon.Settings.GearSets["sets"][stripKey] = gear
	_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Going full monty...")
	nekkersSet = {}
	for ii = 0, 21, 1 do
		nekkersSet[ii] = "-1"
	end
	quickQueue = {}; queuePosition = 1;
	quickQueue[1] = { slot="EQUIP_SLOT_RING1", set=nekkersSet, }
	quickQueue[2] = { slot="EQUIP_SLOT_RING2", set=nekkersSet, }
	quickQueue[3] = { slot="EQUIP_SLOT_MAIN_HAND", set=nekkersSet, }
	quickQueue[4] = { slot="EQUIP_SLOT_BACKUP_MAIN", set=nekkersSet, }
	quickQueue[5] = { slot="EQUIP_SLOT_OFF_HAND", set=nekkersSet, }
	quickQueue[6] = { slot="EQUIP_SLOT_BACKUP_OFF", set=nekkersSet, }
	quickQueue[7] = { slot="EQUIP_SLOT_COSTUME", set=nekkersSet, }
	quickQueue[8] = { slot="EQUIP_SLOT_HEAD", set=nekkersSet, }
	quickQueue[9] = { slot="EQUIP_SLOT_NECK", set=nekkersSet, }
	quickQueue[10] = { slot="EQUIP_SLOT_SHOULDERS", set=nekkersSet, }
	quickQueue[11] = { slot="EQUIP_SLOT_CHEST", set=nekkersSet, }
	quickQueue[12] = { slot="EQUIP_SLOT_WAIST", set=nekkersSet, }
	quickQueue[13] = { slot="EQUIP_SLOT_LEGS", set=nekkersSet, }
	quickQueue[14] = { slot="EQUIP_SLOT_FEET", set=nekkersSet, }
	quickQueue[15] = { slot="EQUIP_SLOT_HAND", set=nekkersSet, }
	--[[
	quickQueue[16] = { slot="EQUIP_SLOT_RING1", set=nekkersSet, }
	quickQueue[17] = { slot="EQUIP_SLOT_RING2", set=nekkersSet, }
	quickQueue[18] = { slot="EQUIP_SLOT_MAIN_HAND", set=nekkersSet, }
	quickQueue[19] = { slot="EQUIP_SLOT_BACKUP_MAIN", set=nekkersSet, }
	quickQueue[20] = { slot="EQUIP_SLOT_OFF_HAND", set=nekkersSet, }
	quickQueue[21] = { slot="EQUIP_SLOT_BACKUP_OFF", set=nekkersSet, }
	quickQueue[22] = { slot="EQUIP_SLOT_COSTUME", set=nekkersSet, }
	quickQueue[23] = { slot="EQUIP_SLOT_HEAD", set=nekkersSet, }
	quickQueue[24] = { slot="EQUIP_SLOT_NECK", set=nekkersSet, }
	quickQueue[25] = { slot="EQUIP_SLOT_SHOULDERS", set=nekkersSet, }
	quickQueue[26] = { slot="EQUIP_SLOT_CHEST", set=nekkersSet, }
	quickQueue[27] = { slot="EQUIP_SLOT_WAIST", set=nekkersSet, }
	quickQueue[28] = { slot="EQUIP_SLOT_LEGS", set=nekkersSet, }
	quickQueue[29] = { slot="EQUIP_SLOT_FEET", set=nekkersSet, }
	quickQueue[30] = { slot="EQUIP_SLOT_HAND", set=nekkersSet, }
	--]]
	_addon:OnUpdateCallback( "OUTFITTER swap gear around", function() HandleQuickQueue() end, .15 )
end

_addon.GC.ClearCommands = function(idx)
	_addon.Settings.GearSetsChanged = true
	_addon.Settings.GearSetsChanged2 = true
	if _addon.GC.HasQueue then _addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Gear Queue Still Processing, Please Wait..."); return; end
	if _addon.Settings.GearSets["sets"][idx] then _addon.Settings.GearSets["sets"][idx] = nil end
	if _addon.Settings.GearSets["sets"]["keys"] == nil then _addon.Settings.GearSets["sets"]["keys"] = {} end
	_addon:table_findRemove( _addon.Settings.GearSets["sets"]["keys"], idx )
	_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Gear Set '"..idx.."' cleared.")
end

_addon.GC.ParseGear = function(force, parse)
	if not force and _addon.GC.HasQueue then _addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Gear Queue Still Processing, Please Wait..."); return; end
	local gearFound = {}
	for k,es in pairs(_addon.GC.EquipSlot) do
		local icon, slotHasItem, sellPrice, isHeldSlot, isHeldNow, locked = GetEquippedItemInfo(es)
		local slot = _addon.GC.EquipSlotBagSlot[k]
		if slotHasItem then
			local id = GetItemUniqueId( 0, slot )
			--if parse and id then _addon:Print( slot .. " - " .. Id64ToString(id) ) end
			if parse and id then _addon:Print( slot .. " - " .. id ) end
			if id then gearFound[es] = id else gearFound[es] = nil end
		else
			if parse then _addon:Print( slot .. " - Empty" ) end
			gearFound[es] = -1
		end
	end
	return gearFound
end

_addon.GC.ParseBags = function(force, parse)
	if not force and _addon.GC.HasQueue then _addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Gear Queue Still Processing, Please Wait..."); return; end
	local gearFound = {}
	local maxBags = GetMaxBags()
	local num = 0
	for bag = 1, maxBags, 1 do
		local slots = GetBagSize(bag)
		for slot = 0, slots, 1 do
			local nn = GetItemUniqueId( bag, slot )
			if nn ~= nil then
				num = num + 1
				if parse then _addon:Print( "["..num.."]".. bag ..".".. slot .. " - " .. nn ) end
				local id, detail = _addon.GC.GetBagSlotDetails( bag, slot)
				if id then gearFound[id] = detail end
			end
		end
	end
	return gearFound
end

_addon.GC.FindItem = function( id )
	local maxBags = GetMaxBags()
	for bb = 0, maxBags, 1 do
		local slots = GetBagSize(bb)
		for ss = 0, slots, 1 do
			local nn = GetItemUniqueId( bb, ss )
			if nn ~= nil then
				if ForceToDoItWrong( id, nn ) then
					return bb, ss
				end
			end
		end
	end
	return nil, nil
end

_addon.GC.SameItem = function( a, b )
	if a == nil or b == nil then return false end
	return a == b
end

_addon.GC.ParseIDs = function()
	for x = 0, 6, 1 do
		for y = 0, 100, 1 do
			local nn = GetItemUniqueId( x, y )
			if nn ~= nil then
				_addon:Print("bag: "..x.." slot: "..y.." = "..nn)
			end
		end
	end
end

_addon.GC.GetBagSlotDetails = function( bag, slot )
	local gearFound = {}
	gearFound["name"] = GetItemName( bag, slot )
	gearFound["id"] = GetItemUniqueId( bag, slot )
	return bag.."."..slot, gearFound
end

_addon.GC.GetGearSlotDetails = function( bag, slot, targetSlot )
	local gearFound = {}
	gearFound["bag"] = bag
	gearFound["slot"] = slot
	gearFound["targetSlot"] = targetSlot
	gearFound["id"] = GetItemUniqueId( bag, slot )
	return targetSlot, gearFound
end
