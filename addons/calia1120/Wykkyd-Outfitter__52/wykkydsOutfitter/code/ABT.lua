local _addon = WYK_Outfitter

_addon.ABT.HasQueue = false
_addon.ABT.Queue = nil
_addon.ABT.GCInUse = true
_addon.ABT.FirstSetPending = false
_addon.ABT.SecondSetPending = false
_addon.Settings.SkillSetsChanged = false
_addon.Settings.SkillSetsChanged2 = false

local weaponSwapLevel = GetWeaponSwapUnlockedLevel()

local skillTypes = {
	SKILL_TYPE_ARMOR,
	SKILL_TYPE_AVA,
	SKILL_TYPE_CLASS,
	SKILL_TYPE_GUILD,
	SKILL_TYPE_NONE,
	SKILL_TYPE_RACIAL,
	SKILL_TYPE_WEAPON,
	SKILL_TYPE_WORLD,
}

local ImpulseSkillIdTable = {
	[42957] 	= 42957,		-- Impulse (no staff)
	[42958] 	= 42957,		-- Fire Impulse
	[42960] 	= 42957,		-- shock Impulse
	[42959] 	= 42957,		-- frost ring
	
	[42976] 	= 42975,		-- fire ring
	[42978] 	= 42975,		-- frost ring
	[42980] 	= 42975,		-- lightning ring
	[42975] 	= 42975,		-- elemental ring (no staff)
	
	[42997] 	= 42996,		-- flame pulsar
	[42999] 	= 42996,		-- frost pulsar
	[43001] 	= 42996,		-- Storm pulsar
	[42996] 	= 42996,		-- pulsar (no staff)

	--[29091] 	= 29091,		-- Destructive Touch (no staff)  --2015 pre 2.2.4
	[40964]     = 40964,        -- Destructive Touch (no staff)  --
	[40965] 	= 40964,		-- Flame Touch
	[40967] 	= 40964, 		-- Frost Touch
	[40970] 	= 40964,		-- Shock Touch

	[41006] 	= 41006,		-- Destructive Clench (no staff)
	[41009] 	= 41006,		-- Flame Clench
	[41013] 	= 41006, 		-- Frost Clench
	[41016] 	= 41006,		-- Shock Clench

	[41047] 	= 41047,		-- Destructive Reach (no staff)
	[41048] 	= 41047,		-- Flame Reach
	[41051] 	= 41047,		-- Frost Reach
	[41054] 	= 41047,		-- Shock Reach

	--[28858] 	= 28858,		-- Wall of Elements (no staff)
	[41658] 	= 41658,		-- Wall of Elements (no staff)
	[41659] 	= 41658,		-- Wall of Fire
	[41663] 	= 41658,		-- Wall of Frost
	[41668] 	= 41658,		-- wall of Storms

	[41711] 	= 41711,		-- Unstable Wall of Elements (no staff)
	[41712] 	= 41711,		-- Wall of Fire
	[41717] 	= 41711,		-- Wall of Frost
	[41723] 	= 41711,		-- Wall of Storms

	[41769] 	= 41769,		-- Elemental Blockade (no staff)
	[41770] 	= 41769, 		-- Blockade of Fire
	[41771] 	= 41769,		-- Blockade of Frost
	[41772] 	= 41769,		-- Blockade of Storms	
}

local skillIconCrosswalk = {
	["ability_destructionstaff_005.dds"] = "ability_destructionstaff_005.dds",
	["ability_destructionstaff_002.dds"] = "ability_destructionstaff_002.dds",
	["ability_destructionstaff_008.dds"] = "ability_destructionstaff_008.dds",
	["ability_destructionstaff_007.dds"] = "ability_destructionstaff_005.dds",
	["ability_destructionstaff_004.dds"] = "ability_destructionstaff_002.dds",
	["ability_destructionstaff_010.dds"] = "ability_destructionstaff_008.dds",
	["ability_destructionstaff_006.dds"] = "ability_destructionstaff_005.dds",
	["ability_destructionstaff_003.dds"] = "ability_destructionstaff_002.dds",
	["ability_destructionstaff_009.dds"] = "ability_destructionstaff_008.dds",
}
GLOBAL_TABLE = {}
_addon.ABT.saveSet = function( idx )
	_addon.Settings.SkillSetsChanged = true
	_addon.Settings.SkillSetsChanged2 = true
	if _addon.Settings.SkillSets["sets"] == nil then _addon.Settings.SkillSets["sets"] = {} end
	if _addon.Settings.SkillSets["sets"][ idx ] == nil then _addon.Settings.SkillSets["sets"][ idx ] = {} end
	local pairIndex, isLocked = GetActiveWeaponPairInfo()
	_addon.Settings.SkillSets["sets"][ idx ][ pairIndex ] = {}
	
	for slotNum = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX+1, ACTION_BAR_ULTIMATE_SLOT_INDEX+1 do
		if IsSlotUsed(slotNum) then
			local sn = GetSlotName(slotNum)
			local slotAbilityId = GetSlotBoundId(slotNum)
			slotAbilityId = ImpulseSkillIdTable[slotAbilityId] or slotAbilityId
			for skillTypeIndex = 1, GetNumSkillTypes() do
				for skillLineIndex = 1, GetNumSkillLines(skillTypeIndex) do
					for abilityIndex = 1, GetNumAbilities(skillTypeIndex, skillLineIndex) do
						local skillAbilityId = GetSkillAbilityId(skillTypeIndex, skillLineIndex, abilityIndex, false)
						if skillAbilityId ~= 0 then
						--	d("slot-->"..GetSlotName(3)..": "..GetSlotBoundId(3))                         ---------------------------------------------------------						
						end
						if skillAbilityId == slotAbilityId then
						--	d("slot-->"..GetSlotName(3)..": "..GetSlotBoundId(3))                         ---------------------------------------------------------
							_addon.Settings.SkillSets["sets"][ idx ][ pairIndex ][slotNum] = {
								slotNum = slotNum,
								name = sn,
								skillType = skillTypeIndex,
								skillLine = skillLineIndex,
								ability = abilityIndex
							}
						end
					end
				end
			end
		end
	end
	if _addon.Settings.SkillSets["sets"]["keys"] == nil then _addon.Settings.SkillSets["sets"]["keys"] = {} end
	_addon:table_findRemove( _addon.Settings.SkillSets["sets"]["keys"], idx )
	table.insert( _addon.Settings.SkillSets["sets"]["keys"], idx )
	_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Saved Action Bar Set '" .. idx .. "', For Weapon " .. pairIndex)
end

_addon.ABT.queueSwap = function( pairIndex, skillTypeIndex, skillLineIndex, abilityIndex, slotIndex )
	if _addon.ABT.Queue == nil then _addon.ABT.Queue = {} end
	local idx = _addon:GetNextOf( _addon.ABT.Queue )
	_addon.ABT.Queue[ idx ] = {
		pair = pairIndex,
		skillType = skillTypeIndex,
		skillLine = skillLineIndex, 
		ability = abilityIndex,
		slot = slotIndex,
		done = false,
	}
	_addon.ABT.HasQueue = true
end

_addon.ABT.doSwap = function()
	if _addon.ABT.HasQueue then
		if _addon.ABT.Queue == nil then _addon.ABT.HasQueue = false; return end
		if IsUnitInCombat( "player" ) then return end
		if _addon.GC.HasQueue then return end
		local pairIndex, isLocked = GetActiveWeaponPairInfo()
		--if isLocked then return end
		for idx,set in pairs(_addon.ABT.Queue) do
			if pairIndex == _addon.ABT.Queue[ idx ].pair then
				if not set.done then
					SlotSkillAbilityInSlot( set.skillType, set.skillLine, set.ability, set.slot )
					_addon.ABT.Queue[ idx ].done = true
					return
				end
			end 
		end
		if pairIndex == 1 and _addon.ABT.FirstSetPending then 
			_addon.ABT.FirstSetPending = false
			if _addon.ABT.SecondSetPending then
				_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Weapon 1 Loaded, Swap Bars to Continue...")
			else
				_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Weapon 1 Loaded, Bars Complete...")
			end
		elseif pairIndex == 2 and _addon.ABT.SecondSetPending then 
			_addon.ABT.SecondSetPending = false 
			if _addon.ABT.FirstSetPending then
				_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Weapon 2 Loaded, Swap Bars to Continue...")
			else
				_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Weapon 2 Loaded, Bars Complete...")
			end
		end
		_addon.ABT.HasQueue = not (_addon.ABT.FirstSetPending == false and _addon.ABT.SecondSetPending == false)
		if not _addon.ABT.HasQueue then _addon.ABT.Queue = nil; end
	end
end
	
_addon.ABT.loadSet = function( idx )
	if _addon.Settings.SkillSets["sets"] == nil then _addon.Settings.SkillSets["sets"] = {} end
	if _addon.Settings.SkillSets["sets"][ idx ] == nil then _addon.Settings.SkillSets["sets"][ idx ] = {} end
	local canSwapWeapons = GetUnitLevel( "player" ) >= weaponSwapLevel
	local pairIndex, isLocked = GetActiveWeaponPairInfo()
	--if isLocked then return end        -------------------------------------
	if pairIndex == 1 then
		_addon.ABT.FirstSetPending = (_addon.Settings.SkillSets["sets"][ idx ][ 1 ] ~= nil)
		if canSwapWeapons then
			_addon.ABT.SecondSetPending = (_addon.Settings.SkillSets["sets"][ idx ][ 2 ] ~= nil)
		end
	else
		_addon.ABT.SecondSetPending = (_addon.Settings.SkillSets["sets"][ idx ][ 2 ] ~= nil)
		_addon.ABT.FirstSetPending = (_addon.Settings.SkillSets["sets"][ idx ][ 1 ] ~= nil)
	end
	if _addon.Settings.SkillSets["sets"][ idx ] ~= nil then
		local set = _addon.Settings.SkillSets["sets"][ idx ]
		for pi = 1, 2, 1 do
			if pi == 1 and _addon.ABT.FirstSetPending 
			or pi == 2 and _addon.ABT.SecondSetPending 
			then
				if set[ pi ] ~= nil then
					--for ii = 1, 2, 1 do
						for s = 3, 8, 1 do
							if set[ pi ][s] ~= nil then
								if set[ pi ][s].skillType ~= nil
								and set[ pi ][s].skillLine ~= nil
								and set[ pi ][s].ability ~= nil
								then
									_addon.ABT.queueSwap( pi, set[ pi ][s].skillType, set[ pi ][s].skillLine, set[ pi ][s].ability, s )
								end
							end
						end
					--end
				end
			end
		end
	end
	if _addon.ABT.Queue ~= nil then 
		--_addon.ABT.HasQueue = true 
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Loading Action Bar Set '" .. idx .. "'")
	end
end

_addon.ABT.clearSet = function( idx )
	_addon.Settings.SkillSetsChanged = true
	_addon.Settings.SkillSetsChanged2 = true
	if _addon.Settings.SkillSets["sets"] == nil then _addon.Settings.SkillSets["sets"] = {} end
	_addon.Settings.SkillSets["sets"][ idx ] = nil
	if _addon.Settings.SkillSets["sets"]["keys"] == nil then _addon.Settings.SkillSets["sets"]["keys"] = {} end
	_addon:table_findRemove( _addon.Settings.SkillSets["sets"]["keys"], idx )
	_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  Deleted Saved Bar Set '" .. idx .. "'")
end