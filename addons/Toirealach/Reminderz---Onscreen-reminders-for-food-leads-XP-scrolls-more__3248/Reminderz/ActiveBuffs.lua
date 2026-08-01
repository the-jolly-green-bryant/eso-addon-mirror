-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Get a table of the buffs active on the given unit tag.
-- The index of parameters of a given buff are the ESO parameters returned in 
-- GetUnitBuffInfo() as strings.
-- So to get the buff name of the 3rd buff:
--
-- local buffs = GetBuffs() -- defaults to "player" unitTag
-- d(string.format("The name of the player's third buff is %s", buffs[3]["buffName"]))
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

BuffInfo = {

			["buffName"] = "",
			["timeStarted"] = 0,
			["timeEnding"] = 0,
			["buffSlot"] = 0,
			["stackCount"] = 0,
			["iconFilename"] = "",
			["buffType"] = 0,
			["effectType"] = 0,
			["abilityType"] = 0,
			["statusEffectType"] = 0,
			["abilityId"] = 0,
			["canClickOff"] = 0,
			["castByPlayer"] = 0

}
   
function GetBuffs(unitTag)
	
	local buffs = {}
	unitTag = unitTag or "player"
	
	for b = 0, GetNumBuffs(unitTag) do
	
		local buffName, 					--
					timeStarted, 				--
					timeEnding, 				--
					buffSlot, 					--
					stackCount, 				--
					iconFilename,				--
					buffType, 					--
					effectType, 				--
					abilityType, 				--
					statusEffectType, 	--
					abilityId, 					--
					canClickOff, 				--
					castByPlayer 				--
						= GetUnitBuffInfo(unitTag, b)
		
		buffs[b] = {
		
			["buffName"] = buffName,
			["timeStarted"] = timeStarted,
			["timeEnding"] = timeEnding,
			["buffSlot"] = buffSlot,
			["stackCount"] = stackCount,
			["iconFilename"] = iconFilename,
			["buffType"] = buffType,
			["effectType"] = effectType,
			["abilityType"] = abilityType,
			["statusEffectType"] = statusEffectType,
			["abilityId"] = abilityId,
			["canClickOff"] = canClickOff,
			["castByPlayer"] = castByPlayer
		}
		
	end
	return buffs
end 

-- Returns a BuffInfo table for the active buff with the given ability ID or nil if not found
function GetActiveBuff(abilityID)
	assert(abilityID ~= nil, "abilityID cannot be nil")
	local buffs = GetBuffs()
	for i, b in pairs(buffs) do
		if b["abilityId"] == abilityID then return b end
	end
	return nil
end


