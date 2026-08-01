local addon = Near_SkillBlockerBanner
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param abilityId integer
---@param msg_pvp boolean
---@param block_pvp boolean
---@return boolean
local function HandlePvP(abilityId, msg_pvp, block_pvp)
	local sv = Near_SkillBlockerBanner.ASV

	local str_unreg = GetString(NEARSB_unregistered)

	local block = true

	-- check if its not blocking the skill in pvp zones and not blocking everything in pvp
	if not block_pvp and not NEAR_SB.ASV.blockPvP then
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

--[[ ---@return boolean
local function HandleCombat()
	local unitTag = 'player'
	local isInCombat = IsUnitInCombat(unitTag)

	local blockHandler = isInCombat ~= nil and isInCombat or false

	return blockHandler
end ]]

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function buffExists(ability)
	local unitTag = 'player'
	local buffs = addon.buffdata[ability]

    if not buffs then return false end

	for buffIndex = 1, GetNumBuffs(unitTag) do
		local _, _, _, _, _, _, _, _, _, _, buffAbilityId, _, castByPlayer = GetUnitBuffInfo(unitTag, buffIndex)
		if buffs[buffAbilityId] and castByPlayer then
			return true
		end
	end

	return false
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param ability integer
---@param abilityId integer
---@param msg_pvp boolean
---@param block_pvp boolean
---@param block_inCombat boolean
---@return boolean
function Near_SkillBlockerBanner.suppressCheck(ability, abilityId, msg_pvp, block_pvp, block_inCombat)
	local block = false

	if not NEAR_SB.ASV.suppressBlock and buffExists(ability) then
		if block_inCombat then
			block = IsUnitInCombat("player")
		end
		-- check status of blockPvP and overrides the handler if needed
		if not block_inCombat or (block_inCombat and block) then
			block = HandlePvP(abilityId, msg_pvp, block_pvp)
		end
	end

	return block
end
