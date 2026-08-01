RaidToolsModule_DeathRecap = {}

function RaidToolsModule_DeathRecap.OnDeathStateChange(eventCode, unitTag, isDead)
	if not RaidTools.storage.modules.death_recap then return end
	if not string.match(unitTag, 'group') then return end
	if not isDead then return end
	if GetUnitName(unitTag) ~= NAME then return end
	local attack_name, attack_damage, attack_icon, was_killing_blow, _, attack_ability_id, attacker_name, castTimeAgoMS, durationMS, numAttackHits, message
	local attacks = {}
	for i = 1, GetNumKillingAttacks() do
		attack_name, attack_damage, attack_icon, was_killing_blow, castTimeAgoMS, durationMS, numAttackHits, attack_ability_id = GetKillingAttackInfo(i)
		table.insert(attacks, {
			index = i,
			attack_name = attack_name,
			attack_damage = attack_damage,
			attack_icon = attack_icon,
			wasKillingBlow = was_killing_blow,
    		lastUpdateAgoMS = castTimeAgoMS - durationMS,
    		num_attack_hits = numAttackHits
		})
	end
	
	table.sort(attacks, SortAttacks)

	RaidTools.BrandedMessage('DeathRecap:')
	for _, data in ipairs(attacks) do
		local attacker_string = 'World'
		if DoesKillingAttackHaveAttacker(data.index) then
			local raw_name, _, _, _, is_player, is_boss, _, mob_name, attacker_name = GetKillingAttackerInfo(data.index)
			if is_player then
				attacker_string = '|c'..CLR.health.hex..attacker_name..'|r' -- UserID
			else
				attacker_string = FixName(raw_name) -- Mobs
			end
		end
		message = string.format('%s: |cffffff%s - %s damage|r', attacker_string, data.attack_name, data.attack_damage)
		if data.wasKillingBlow then
			message = message .. ' (KillingBlow)'
		end
		if data.num_attack_hits > 1 then
			message = data.num_attack_hits ..'x '.. message
		end

		RaidTools.BaseMessage('|t16:16:'.. data.attack_icon ..'|t|r '..message)
	end
end