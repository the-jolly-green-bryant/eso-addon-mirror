
WeaveDelayLog = {}
function WeaveDelayLog.new()
	local self = {}
	local playerActions = {}
	local pendingSkillActions = {}

	local ACTION_LIGHT_ATTACK       = 1
	local ACTION_SKILL_OFFSET       = 2
	local NORMAL_LATENCY_TIMEOUT_MS = 1000
	local HIGH_LATENCY_TIMEOUT_MS   = 1600

	local AVG_MISSED_PENALTY_MS  = 1000
	local AVG_DELAY_CLAMP_MIN_MS = 1
	local AVG_DELAY_CLAMP_MAX_MS = 1000

	local settings = {}
	settings.GCD                      = 1000
	settings.lightAttackTimeout       = NORMAL_LATENCY_TIMEOUT_MS
	settings.skillConfirmationEnabled = false

	local combatEndMarkerPosition = -1
	local combatEndTime           = -1

	local PRE_COMBAT_WINDOW_MS = 5000
	-- the ending fight's last weave can register shortly after the combat
	-- state event, past the marker; treat such stragglers as the old fight
	local COMBAT_END_GRACE_MS  = 500

	local combos           = {}
	local maxCombos        = 800
	local prevSkillEndTime = nil
	local pendingLaAction  = nil

	-- running average of the weave delay
	local avgSum, avgCount = 0, 0
	local avgPending       = {}
	local avgFirstLASeen   = false

	local function resetAverage()
		avgSum, avgCount = 0, 0
		avgPending       = {}
		avgFirstLASeen   = false
	end

	local function settleAveragePending(now)
		while avgPending[1] ~= nil and now - avgPending[1].la.time > settings.lightAttackTimeout do
			local combo = table.remove(avgPending, 1)
			if combo.la.confirmed then
				avgSum = avgSum + math.max(math.min(combo.delay, AVG_DELAY_CLAMP_MAX_MS), AVG_DELAY_CLAMP_MIN_MS)
			else
				avgSum = avgSum + AVG_MISSED_PENALTY_MS
			end
			avgCount = avgCount + 1
		end
	end

	function self.getAverageDelay()
		settleAveragePending(GetGameTimeMilliseconds())
		if avgCount == 0 then
			return nil
		end
		return avgSum / avgCount
	end

	local function trackAction(action)
		if action.slotId > ACTION_SKILL_OFFSET then
			local measured = prevSkillEndTime ~= nil
			local combo = {
				skill    = action,
				la       = pendingLaAction,
				delay    = measured and (action.time - prevSkillEndTime) or 0,
				measured = measured,
			}
			table.insert(combos, combo)
			if #combos > maxCombos then
				table.remove(combos, 1)
			end
			prevSkillEndTime = action.time + math.max((action.castTime or 0) + (action.channelTime or 0), settings.GCD)
			pendingLaAction  = nil
			return combo
		elseif action.slotId == ACTION_LIGHT_ATTACK and pendingLaAction == nil then
			pendingLaAction = action
		end
		return nil
	end

	local function rebuildCombos()
		combos           = {}
		prevSkillEndTime = nil
		pendingLaAction  = nil
		for i = 1, #playerActions do
			trackAction(playerActions[i])
		end
	end

	function self.registerAction(action)
		local idx = #playerActions + 1
		while idx > 1 and playerActions[idx - 1].time > action.time do
			idx = idx - 1
		end
		table.insert(playerActions, idx, action)
		if idx <= combatEndMarkerPosition then
			combatEndMarkerPosition = combatEndMarkerPosition + 1
		end

		if idx == #playerActions then
			local combo = trackAction(action)
			settleAveragePending(action.time)
			if combo ~= nil and combo.measured and avgFirstLASeen then
				if combo.la == nil then
					avgSum   = avgSum + AVG_MISSED_PENALTY_MS
					avgCount = avgCount + 1
				else
					table.insert(avgPending, combo)
				end
			end
			if action.slotId == ACTION_LIGHT_ATTACK then
				avgFirstLASeen = true
			end
		else
			rebuildCombos()
		end
	end

	function self.getCombos()
		return combos
	end

	function self.startCombat()
		local cutoff = GetGameTimeMilliseconds() - PRE_COMBAT_WINDOW_MS
		local newPlayerActions = {}
		for i = 1, #playerActions do
			local t = playerActions[i].time
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
			if pendingSkillActions[i].time >= cutoff then
				table.insert(newPendingSkillActions, pendingSkillActions[i])
			end
		end
		pendingSkillActions = newPendingSkillActions

		rebuildCombos()
		resetAverage()
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
		rebuildCombos()
		resetAverage()
	end

	function self.slotUsed(slotId)
		local t = GetGameTimeMilliseconds()
		local boundId = GetSlotBoundId(slotId)
		local _, castTime, channelTime = GetAbilityCastInfo(boundId)
		if IsCraftedAbilityScribed(boundId) then
			boundId = GetAbilityIdForCraftedAbilityId(boundId)
		end
		local action = {
			time        = t,
			slotId      = slotId,
			boundId     = boundId,
			castTime    = castTime,
			channelTime = channelTime,
			confirmed   = false,
			queued      = false,
			bashed      = false,
		}
		if settings.skillConfirmationEnabled and slotId > ACTION_SKILL_OFFSET then
			table.insert(pendingSkillActions, action)
		else
			self.registerAction(action)
		end
	end

	function self.confirmLightAttack()
		local t = GetGameTimeMilliseconds()
		for n = #playerActions, 1, -1 do
			local action = playerActions[n]
			if t - action.time > settings.lightAttackTimeout then
				break
			end
			if action.slotId == ACTION_LIGHT_ATTACK then
				action.confirmed = true
				break
			end
		end
	end

	function self.flagLightAttackQueued()
		local t = GetGameTimeMilliseconds()
		for n = #playerActions, 1, -1 do
			local action = playerActions[n]
			if t - action.time > settings.lightAttackTimeout then
				break
			end
			if action.slotId == ACTION_LIGHT_ATTACK then
				action.queued = true
				break
			end
		end
	end

	function self.confirmBash()
		local t = GetGameTimeMilliseconds()
		for n = #playerActions, 1, -1 do
			local action = playerActions[n]
			if t - action.time > settings.lightAttackTimeout then
				break
			end
			if action.slotId > ACTION_SKILL_OFFSET then
				action.bashed = true
				break
			end
		end
	end

	function self.resolvePendingSkill(abilityId, isError)
		local t = GetGameTimeMilliseconds()
		local n = 1
		while n <= #pendingSkillActions do
			local pending = pendingSkillActions[n]
			local timeout = settings.lightAttackTimeout + (pending.castTime or 0) + (pending.channelTime or 0)
			if t - pending.time > timeout then
				table.remove(pendingSkillActions, n)
			elseif pending.boundId == abilityId then
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

	function self.SetMaxCombos(n)
		maxCombos = n
		while #combos > maxCombos do
			table.remove(combos, 1)
		end
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