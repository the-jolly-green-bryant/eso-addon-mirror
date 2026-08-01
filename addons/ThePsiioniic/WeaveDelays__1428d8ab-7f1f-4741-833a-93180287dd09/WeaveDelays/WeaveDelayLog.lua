
WeaveDelayLog = {}
function WeaveDelayLog.new()
    local self = {}
    local playerActions = {}
    local pendingSkillActions = {}

    local ACTION_LIGHT_ATTACK       = 1
    local ACTION_SKILL_OFFSET       = 2
    local NORMAL_LATENCY_TIMEOUT_MS = 1000
    local HIGH_LATENCY_TIMEOUT_MS   = 1600

    local PA_IDX_TIME         = 1
    local PA_IDX_BAR_INDEX    = 2
    local PA_IDX_SLOT_ID      = 3
    local PA_IDX_BOUND_ID     = 4
    local PA_IDX_CAST_TIME    = 6
    local PA_IDX_CHANNEL_TIME = 7
    local PA_IDX_LA_CONFIRMED = 9
    local PA_IDX_LA_QUEUED    = 10
    local PA_IDX_BASH         = 11

	-- index for weapon bar, 0 is the one active when addon is loaded
	local activeBarIndex         = 0
	local activeBarIndexReversed = false
	local skillBarIndex          = nil

	local settings = {}
	settings.GCD                     = 1000
	settings.lightAttackTimeout      = NORMAL_LATENCY_TIMEOUT_MS
	settings.skillConfirmationEnabled = false

	local combatEndMarkerPosition = -1
	local combatEndTime           = -1

	local PRE_COMBAT_WINDOW_MS = 5000
	-- the ending fight's last weave can register shortly after the combat
	-- state event, past the marker; treat such stragglers as the old fight
	local COMBAT_END_GRACE_MS  = 500

	function self.startCombat()
		local cutoff = GetGameTimeMilliseconds() - PRE_COMBAT_WINDOW_MS
		local newPlayerActions = {}
		for i = 1, #playerActions do
			local t = playerActions[i][PA_IDX_TIME]
			if i > combatEndMarkerPosition and t >= cutoff
					and (combatEndTime < 0 or t > combatEndTime + COMBAT_END_GRACE_MS) then
				table.insert(newPlayerActions, playerActions[i])
			end
		end
		playerActions = newPlayerActions
		combatEndMarkerPosition = -1
		combatEndTime = -1

		local newPendingSkillActions = {}
		for i = 1, #pendingSkillActions do
			if pendingSkillActions[i][PA_IDX_TIME] >= cutoff then
				table.insert(newPendingSkillActions, pendingSkillActions[i])
			end
		end
		pendingSkillActions = newPendingSkillActions
	end

	function self.endCombat()
		combatEndMarkerPosition = #playerActions
		combatEndTime = GetGameTimeMilliseconds()
	end

	function self.reset()
		playerActions = {}
		pendingSkillActions = {}
		combatEndMarkerPosition = -1
		combatEndTime = -1
	end

    function self.registerAction(playerAction)
		if activeBarIndex ~= nil then
			local idx = #playerActions + 1
			while idx > 1 and playerActions[idx - 1][PA_IDX_TIME] > playerAction[PA_IDX_TIME] do
				idx = idx - 1
			end
			table.insert(playerActions, idx, playerAction)
			if idx <= combatEndMarkerPosition then
				combatEndMarkerPosition = combatEndMarkerPosition + 1
			end
		end
    end

	function self.getLastCombos(numCombos)
		local combos = {}
		local skillCastTime, skillIndex, boundID, lightAttackRegistered, lightAttackConfirmed, lightAttackQueued, duration, bashed = nil,0,0,false,false,false,0,false
		local combo = nil
		local playerAction
		local n = #playerActions
		while n > 0 do
			playerAction = playerActions[n]
			if playerAction[PA_IDX_SLOT_ID] > ACTION_SKILL_OFFSET then
				if skillCastTime ~= nil then
					combo = {skillIndex, boundID, skillCastTime - playerAction[PA_IDX_TIME] - duration, lightAttackRegistered, lightAttackConfirmed, lightAttackQueued, skillCastTime, playerAction[PA_IDX_BAR_INDEX], bashed}
					table.insert(combos, combo)
					if #combos >= numCombos then
						break
					end
				end
				skillCastTime = playerAction[PA_IDX_TIME]
				skillIndex    = playerAction[PA_IDX_SLOT_ID] - ACTION_SKILL_OFFSET
				boundID       = playerAction[PA_IDX_BOUND_ID]
				duration      = math.max((playerAction[PA_IDX_CAST_TIME] or 0) + (playerAction[PA_IDX_CHANNEL_TIME] or 0), settings.GCD)

				lightAttackRegistered = false
				lightAttackConfirmed  = false
				lightAttackQueued     = false
				bashed                = playerAction[PA_IDX_BASH]
			elseif playerAction[PA_IDX_SLOT_ID] == ACTION_LIGHT_ATTACK then
				lightAttackRegistered = true
				lightAttackConfirmed  = playerAction[PA_IDX_LA_CONFIRMED]
				lightAttackQueued     = playerAction[PA_IDX_LA_QUEUED]
			end
			n = n - 1
		end
		if #combos < numCombos and skillCastTime ~= nil then
			local barIdx = playerActions[1] ~= nil and playerActions[1][PA_IDX_BAR_INDEX] or 0
			combo = {skillIndex, boundID, 0, lightAttackRegistered, lightAttackConfirmed, lightAttackQueued, skillCastTime, barIdx, bashed}
			table.insert(combos, combo)
		end

		return combos
	end

    function self.slotUsed(slotId)
		local t = GetGameTimeMilliseconds()
		local boundId = GetSlotBoundId(slotId)
		local channeled, castTime, channelTime = GetAbilityCastInfo(boundId)
		if IsCraftedAbilityScribed(boundId) then
			boundId = GetAbilityIdForCraftedAbilityId(boundId)
		end
		local action = {t, activeBarIndex, slotId, boundId, channeled, castTime, channelTime, 0, false, false, false}
		if settings.skillConfirmationEnabled and slotId > ACTION_SKILL_OFFSET then
			table.insert(pendingSkillActions, action)
		else
			self.registerAction(action)
		end
	end

	function self.confirmLightAttack()
		local t = GetGameTimeMilliseconds()
		local n = #playerActions
		while n > 0 do
			if t - playerActions[n][PA_IDX_TIME] > settings.lightAttackTimeout then
				break
			end
			if playerActions[n][PA_IDX_SLOT_ID] == ACTION_LIGHT_ATTACK then
				playerActions[n][PA_IDX_LA_CONFIRMED] = true
				break
			end
			n = n - 1
		end
	end

	function self.flagLightAttackQueued()
		local t = GetGameTimeMilliseconds()
		local n = #playerActions
		while n > 0 do
			if t - playerActions[n][PA_IDX_TIME] > settings.lightAttackTimeout then
				break
			end
			if playerActions[n][PA_IDX_SLOT_ID] == ACTION_LIGHT_ATTACK then
				playerActions[n][PA_IDX_LA_QUEUED] = true
				break
			end
			n = n - 1
		end
	end

	function self.confirmBash()
		local t = GetGameTimeMilliseconds()
		local n = #playerActions
		while n > 0 do
			if t - playerActions[n][PA_IDX_TIME] > settings.lightAttackTimeout then
				break
			end
			if playerActions[n][PA_IDX_SLOT_ID] > ACTION_SKILL_OFFSET then
				playerActions[n][PA_IDX_BASH] = true
				break
			end
			n = n - 1
		end
	end

	function self.resolvePendingSkill(abilityId, isError)
		local t = GetGameTimeMilliseconds()
		local n = 1
		while n <= #pendingSkillActions do
			local pending = pendingSkillActions[n]
			local timeout = settings.lightAttackTimeout + (pending[PA_IDX_CAST_TIME] or 0) + (pending[PA_IDX_CHANNEL_TIME] or 0)
			if t - pending[PA_IDX_TIME] > timeout then
				table.remove(pendingSkillActions, n)
			elseif pending[PA_IDX_BOUND_ID] == abilityId then
				table.remove(pendingSkillActions, n)
				if not isError then
					self.registerAction(pending)
				end
				return true
			else
				n = n + 1
			end
		end
		return false
	end

	function self.weaponSwap(activeWeaponPair)
		if skillBarIndex == nil then
			if activeWeaponPair == 2 then
				skillBarIndex = {[0]=0, [1]=0, [2]=1}
				activeBarIndexReversed = false
			else
				skillBarIndex = {[0]=0, [1]=1, [2]=0}
				activeBarIndexReversed = true
			end
		end
		activeBarIndex = skillBarIndex[activeWeaponPair]
	end

	function self.SetSkillConfirmationEnabled(enabled)
		settings.skillConfirmationEnabled = enabled
	end

	function self.SetHighLatencyMode(enabled)
		if enabled then
			settings.lightAttackTimeout = HIGH_LATENCY_TIMEOUT_MS
		else
			settings.lightAttackTimeout = NORMAL_LATENCY_TIMEOUT_MS
		end
	end

	return self
end