NEAR_SB.defaults = {}
local addon = NEAR_SB
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

NEAR_SB.defaults = {
	message = false,
	blockPvP = true,
	showError = true,
	suppressBlock = false,
	suppressBlockReset = false,
	cmdMessageType = 1,
	cmdMessageSound = true,
	recastTimeRemainingThreshold = 0,
	abilityBarHideTimers = false,
}

NEAR_SB.defaults.skilldata = {} -- Toggle block skills/messages

local function createSkillEntry(addCrux, addStacks)
	local data = { block = false, block_recast = false, block_notInCombat = false, block_inCombat = false, block_isBracing = false, pvp = true, msg = { re_cast = false, pvp = true, } }

	if addCrux then
		data.block_onMaxCrux = false
		data.block_onNotMaxCrux = false
	end

	if addStacks then
		data.block_onStacksEqual = false
		data.stacks = 1
	end

	return {
		[0] = data,
		[1] = data,
		[2] = data
	}
end

local shouldAddStacks = {
	['24165'] = true,  -- Bound Armaments
	['117624'] = true, -- Venom Skull
}

for _, skillType in ipairs({ 'class', 'weapon', 'armor', 'world', 'guild', 'ava' }) do
	NEAR_SB.defaults.skilldata[skillType] = {}

	for skillLine, v in pairs(addon.skilldata[skillType]) do
		NEAR_SB.defaults.skilldata[skillType][skillLine] = {}

		local addCrux
		if skillLine == 'Herald' or skillLine == 'Soldier' or skillLine == 'Curative' then
			addCrux = true
		end

		for ability in pairs(v) do
			if type(ability) == 'number' then
				local addStacks
				for _, value in ipairs(addon.skilldata[skillType][skillLine][ability]) do
					if shouldAddStacks[tostring(value.id)] then
						addStacks = true
						break
					end
				end

				NEAR_SB.defaults.skilldata[skillType][skillLine][ability] = createSkillEntry(addCrux, addStacks)
			end
		end
	end
end
