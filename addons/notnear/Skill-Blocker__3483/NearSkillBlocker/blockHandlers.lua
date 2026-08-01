local addon = NEAR_SB
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function checkCombatAndBracingConditions(isInCombat, isBracing, block_notInCombat, block_inCombat, block_isBracing)
	if not block_notInCombat and not block_inCombat and not block_isBracing then
		return nil
	else
		local result = (block_notInCombat and not isInCombat and not block_isBracing) or
			(block_notInCombat and not isInCombat and block_isBracing and isBracing) or
			(block_inCombat and isInCombat and not block_isBracing) or
			(block_inCombat and isInCombat and block_isBracing and isBracing) or
			(block_isBracing and isBracing and not block_notInCombat and not block_inCombat)
		return result
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local wwTransformationIds = {[32455] = true, [39075] = true, [39076] = true}

local function checkWerewolfTransformConditions(abilityId)
    if not wwTransformationIds[abilityId] then
        return true
    end

    return IsPlayerInWerewolfForm()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function HandlePvP(abilityId, msg_pvp, block_pvp)
	local sv = NEAR_SB.ASV

	local str_unreg = GetString(NEARSB_unregistered)

	local block = true

	-- check if its not blocking the skill in pvp zones and not blocking everything in pvp
	if not block_pvp and not sv.blockPvP then
		local abilityName = GetAbilityName(abilityId)

		-- check if player is in a pvp zone
		if IsPlayerInAvAWorld() or IsActiveWorldBattleground() then
			block = false

			-- send this only the first time after entering pvp zone
			if sv.message and msg_pvp then
				local message = str_unreg .. abilityName .. ' *PvP'
				addon.AddMessage(message)
				msg_pvp = false
			end
		else
			block = true
			msg_pvp = true
		end
	end

	return block
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function HandleRecasts(abilityId, msg_pvp, block_pvp, block_notInCombat, block_inCombat, block_isBracing)
	local sv = NEAR_SB.ASV
	local unitTag = 'player'
	local isInCombat = IsUnitInCombat(unitTag)
	local isBracing = IsBlockActive()
	local blockHandler = false

	local function UpdateRecastHandler(slotNum)
		local timeRemainingMS = GetActionSlotEffectTimeRemaining(slotNum)
		local thresholdMS = sv.recastTimeRemainingThreshold * 1000
		blockHandler = timeRemainingMS > thresholdMS
	end

	for slotNum = 3, 8 do
		if abilityId == GetSlotBoundId(slotNum) then
			UpdateRecastHandler(slotNum)
			break
		end
	end

	local combatorbracing = checkCombatAndBracingConditions(isInCombat, isBracing, block_notInCombat, block_inCombat, block_isBracing)

	if blockHandler == true and combatorbracing ~= nil then
		blockHandler = combatorbracing
	end

	if blockHandler == true then
		blockHandler = checkWerewolfTransformConditions(abilityId)
	end

	if blockHandler == true then
		blockHandler = HandlePvP(abilityId, msg_pvp, block_pvp)
	end

	return blockHandler
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function HandleBlock(abilityId, msg_pvp, block_pvp)
	local blockHandler = checkWerewolfTransformConditions(abilityId)

	if blockHandler == true then
		blockHandler = HandlePvP(abilityId, msg_pvp, block_pvp)
	end

	return blockHandler
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function HandleCombatAndBracing(abilityId, msg_pvp, block_pvp, block_notInCombat, block_inCombat, block_isBracing)
	local unitTag = 'player'
	local isInCombat = IsUnitInCombat(unitTag)
	local isBracing = IsBlockActive()

	local combatorbracing = checkCombatAndBracingConditions(isInCombat, isBracing, block_notInCombat, block_inCombat, block_isBracing)

	local blockHandler = combatorbracing ~= nil and combatorbracing or false

	if blockHandler == true then
		blockHandler = checkWerewolfTransformConditions(abilityId)
	end

	if blockHandler == true then
		blockHandler = HandlePvP(abilityId, msg_pvp, block_pvp)
	end

	return blockHandler
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function HandleOnCrux(blockType, abilityId, msg_pvp, block_pvp, block_notInCombat, block_inCombat, block_isBracing)
	local unitTag = 'player'
	local isInCombat = IsUnitInCombat(unitTag)
	local isBracing = IsBlockActive()
	local blockHandler = false
	local buffExists = false

	for buffIndex = 1, GetNumBuffs(unitTag) do
		local _, _, _, _, stackCount, _, _, _, _, _, buffAbilityId, _, _ = GetUnitBuffInfo(unitTag, buffIndex)
		if buffAbilityId == 184220 then -- Crux abilityId = 184220
			buffExists = true
			if (blockType == 4 and stackCount == 3) or (blockType == 5 and not (stackCount == 3)) then
				blockHandler = true
			end
			break
		end
	end

	if blockType == 5 and not buffExists then
		blockHandler = true
	end

	local combatorbracing = checkCombatAndBracingConditions(isInCombat, isBracing, block_notInCombat, block_inCombat, block_isBracing)

	if blockHandler == true and combatorbracing ~= nil then
		blockHandler = combatorbracing
	end

	if blockHandler == true then
		blockHandler = HandlePvP(abilityId, msg_pvp, block_pvp)
	end

	return blockHandler
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local stackAbilityIds = {
	['24165'] = 203447, -- Bound Armaments
	['117624'] = 117625, -- Venom Skull
	['123699'] = 117625, -- Venom Skull
	['123704'] = 117625, -- Venom Skull
}

local function HandleOnStacks(skillType, skillLine, ability, morph, abilityId, msg_pvp, block_pvp, block_notInCombat, block_inCombat, block_isBracing)
	local sv_skilldata = NEAR_SB.ASV.skilldata[skillType]
	local unitTag = 'player'
	local isInCombat = IsUnitInCombat(unitTag)
	local isBracing = IsBlockActive()
	local blockHandler = false
	local stacks = sv_skilldata[skillLine][ability][morph].stacks
	local stackAbilityId = stackAbilityIds[tostring(abilityId)]
	local buffExists = false

	for buffIndex = 1, GetNumBuffs(unitTag) do
		local _, _, _, _, stackCount, _, _, _, _, _, buffAbilityId, _, _ = GetUnitBuffInfo(unitTag, buffIndex)
		if buffAbilityId == stackAbilityId then
			buffExists = true
			if not (stackCount == stacks) then
				blockHandler = true
			end
			break
		end
	end

	if not buffExists then -- for Venom Skull, Bound Armaments can't be used anyways if theres no buff
		blockHandler = true
	end

	local combatorbracing = checkCombatAndBracingConditions(isInCombat, isBracing, block_notInCombat, block_inCombat, block_isBracing)

	if blockHandler == true and combatorbracing ~= nil then
		blockHandler = combatorbracing
	end

	if blockHandler == true then
		blockHandler = HandlePvP(abilityId, msg_pvp, block_pvp)
	end

	return blockHandler
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param skillType string
---@param skillLine string|integer
---@param ability integer
---@param morph integer
---@param abilityId integer|nil
---@param blockType integer
---@param block_notInCombat boolean
---@param block_inCombat boolean
---@param block_isBracing boolean
---@return boolean
function NEAR_SB.suppressCheck(blockType, skillType, skillLine, ability, morph, abilityId, msg_pvp, block_pvp, block_notInCombat, block_inCombat, block_isBracing)
	local sv = NEAR_SB.ASV
	local block = false

	if not sv.suppressBlock then
		if blockType == 1 then
			block = HandleBlock(abilityId, msg_pvp, block_pvp)
		elseif blockType == 2 then
			block = HandleCombatAndBracing(abilityId, msg_pvp, block_pvp, block_notInCombat, block_inCombat, block_isBracing)
		elseif blockType == 3 then
			block = HandleRecasts(abilityId, msg_pvp, block_pvp, block_notInCombat, block_inCombat, block_isBracing)
		elseif blockType == 4 or blockType == 5 then
			block = HandleOnCrux(blockType, abilityId, msg_pvp, block_pvp, block_notInCombat, block_inCombat, block_isBracing)
		elseif blockType == 6 then
			block = HandleOnStacks(skillType, skillLine, ability, morph, abilityId, msg_pvp, block_pvp, block_notInCombat, block_inCombat, block_isBracing)
		end
	end

	return block
end
