RaidToolsModule_DeathAlert = {}

function RaidToolsModule_DeathAlert.OnDeathStateChange(eventCode, unitTag, isDead)
	if not RaidTools.storage.modules.death_alert then return end
	if not string.match(unitTag, 'group') then return end
	if not isDead then return end
	if GetUnitName(unitTag) == NAME then return end
	local is_dd, is_heal, is_tank = GetGroupMemberRoles(unitTag)
	if RaidTools.storage.config.hide_dd_deaths and is_dd then return end
	local message = 'Died. Resurrect!|r'
	if is_heal then
		message = '|c'.. CLR.cancer.hex ..'Healer ' .. message
	elseif is_tank then
		message = '|c'.. CLR.soft.hex ..'Tank ' .. message
	else
		message = '|c'.. CLR.white.hex ..'DD ' .. message
	end
	PlaySound(SOUNDS.RAID_TRIAL_FAILED)
	RaidTools.Announcement(message)
end