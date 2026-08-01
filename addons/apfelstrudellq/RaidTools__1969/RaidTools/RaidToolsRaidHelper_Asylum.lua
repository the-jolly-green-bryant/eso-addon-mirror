RaidToolsAsylum = {}

BOX = {}

ABILITY_MINIBOSS_SLEEP = 99990
ABILITY_MINIBOSS_ENRAGE = 101354

ABILITY_FELMS_MAIM 		= 95657
ABILITY_FELMS_TELEPORT_CHECK = 99139
ABILITY_FELMS_TELEPORT_STRIKE = 99138
ABILITY_FELMS_WRATH = 99037

ABILITY_LLOTHIS_BOLTS_CHANNELING = 95585
ABILITY_LLOTHIS_DEFILING_BLAST = 95545
ABILITY_LLOTHIS_TRANSMISSION = 99819

ABILITY_OLMS_HEAVEN_STORM = 98535
ABILITY_OLMS_FIELD = 100437
ABILITY_OLMS_SPHERE = 10298
ABILITY_OLMS_BREATH = 98683

local IS_VALID_FIGHT = false
local _bosses_defaults = {}
local bosses = {
	olms = {
		unit_id = false,
		last_kite = 0,
		last_breath = 0,
		last_field = 0
	},
	llothis = {
		unit_id = false,
		active = false,
		sleep_expires = nil,
		enrage = 0,
		last_bolts = 0,
		last_blast = 0,
		last_transmission = 0
	},
	felms = {
		unit_id = false,
		active = false,
		sleep_expires = nil,
		enrage = 0,
		teleportcd = 0,
		last_wrath = 0
	},
}
_bosses_defaults = ZO_DeepTableCopy(bosses, _bosses_defaults)
local sphere = {
	active = false,
	last = 0,
	last_death = 0,
	count = 0,
	units = {}
}
local player = {
	maim = 0
}

local function Time(s)
	return string.format("%ds", math.floor(s))
end

local function DetectUnit(unitId, unitName) -- local wrapper for LBF:DetectUnit()
	if not unitName and unitName == nil then return nil end
	local boss = RaidTools.LBF:DetectUnit(false, FixName(unitName))
	if boss ~= nil then 
		if string.match(boss.name:lower(), 'llothis') then
			bosses.llothis.unit_id = unitId
			if not bosses.llothis.active then
				bosses.llothis.active = true
				bosses.llothis.sleep_expires = GetGameTimeMilliseconds()
			end
			return 'llothis'

		elseif string.match(boss.name:lower(), 'felms') then
			bosses.felms.unit_id = unitId
			if not bosses.felms.active then
				bosses.felms.active = true
				bosses.felms.sleep_expires = GetGameTimeMilliseconds()
			end
			return 'felms'

		elseif string.match(boss.name:lower(), 'olms') then
			bosses.olms.unit_id = unitId
			return 'olms'
		end
	else
		local boss = RaidTools.LBF:DetectTrashUnit(unitId, FixName(unitName))
		if boss then
			if string.match(boss.name:lower(), 'llothis') then
				bosses.llothis.unit_id = unitId
				if not bosses.llothis.active then
					bosses.llothis.active = true
					bosses.llothis.sleep_expires = GetGameTimeMilliseconds()
				end
				return 'llothis'

			elseif string.match(boss.name:lower(), 'felms') then
				bosses.felms.unit_id = unitId
				if not bosses.felms.active then
					bosses.felms.active = true
					bosses.felms.sleep_expires = GetGameTimeMilliseconds()
				end
				return 'felms'
			end
		end
	end
	return nil
end

local function GetUnit(unit_id)
	if bosses.llothis.unit_id and unit_id == bosses.llothis.unit_id then
		return 'llothis'
	elseif bosses.felms.unit_id and unit_id == bosses.felms.unit_id then
		return 'felms'
	elseif bosses.olms.unit_id and unit_id == bosses.olms.unit_id then
		return 'olms'
	else
		return nil
	end
end

local function ProcessBossSleep(unit_id, changeType, endTime)
	local boss = GetUnit(unit_id)
	if boss == 'llothis' then
		if changeType == EFFECT_RESULT_FADED then
			bosses.llothis.active = true
		elseif changeType == EFFECT_RESULT_GAINED then
			bosses.llothis.enrage = 0
			bosses.llothis.active = false
			bosses.llothis.sleep_expires = endTime * 1000
			--boss specifics
			bosses.llothis.defiling_blast = 0
		end
	elseif boss == 'felms' then
		if changeType == EFFECT_RESULT_FADED then
			bosses.felms.active = true
		elseif changeType == EFFECT_RESULT_GAINED then
			bosses.felms.enrage = 0
			bosses.felms.active = false
			bosses.felms.sleep_expires = endTime * 1000
		end
	end
end

local function ProcessBossEnrage(unit_id, changeType, stacks)
	local boss = GetUnit(unit_id)
	if boss == 'llothis' then
		if changeType == EFFECT_RESULT_FADED then
			bosses.llothis.enrage = 0
		else
			bosses.llothis.enrage = stacks
		end
	elseif boss == 'felms' then
		if changeType == EFFECT_RESULT_FADED then
			bosses.felms.enrage = 0
		else
			bosses.felms.enrage = stacks
		end
	end
end

local function ProcessMaimDebuff(endTime)
	player.maim = endTime * 1000
end

local function ProcessTeleportCheck(changeType, endTime, stackCount)
	if changeType == EFFECT_RESULT_FADED then return end
	if stackCount < 3 then return end
	bosses.felms.teleportcd = endTime * 1000
end

local function ProcessSphereSpawn(unit_id)
	if (GetGameTimeMilliseconds() - sphere.last) < 500 then return end
	sphere.last = GetGameTimeMilliseconds()
	sphere.active = true
	sphere.count = sphere.count + 1
	sphere.units[unit_id] = {spawn = GetGameTimeMilliseconds()}
end

local function ProcessSphereDeath(unit_id)
	sphere.count = sphere.count - 1
	sphere.last_death = GetGameTimeMilliseconds()
	if sphere.count == 0 then
		sphere.active = false
	elseif sphere.count < 0 then
		sphere.active = false
		sphere.count = 0
	end
	sphere.units[unit_id].death = GetGameTimeMilliseconds()
end

local function Reset()
	bosses = {
		olms = {
			unit_id = false,
			last_kite = 0,
			last_breath = 0,
			last_field = 0
		},
		llothis = {
			unit_id = false,
			active = false,
			sleep_expires = nil,
			enrage = 0,
			last_bolts = 0,
			last_blast = 0,
			last_transmission = 0
		},
		felms = {
			unit_id = false,
			active = false,
			sleep_expires = nil,
			enrage = 0,
			teleportcd = 0,
			last_wrath = 0
		},
	}
	sphere = {
		active = false,
		last = 0,
		last_death = 0,
		count = 0,
		units = {}
	}
	player = {
		maim = 0
	}
end

function RaidToolsAsylum.Init()
	CALLBACK_MANAGER:RegisterCallback("OnBossFightStart", function(boss, hardmode)
		Reset()
		if RaidTools.LBF:IsInRaidBossFight(TRIAL_ASYLUM_SANCTORIUM, true) then
			IS_VALID_FIGHT = true
			--d('AS '.. boss.name ..' BossFightStarted (HM: '..tostring(hardmode)..')')
			
			if RaidTools.storage.modules.as_helper then
				RaidToolsAsylum.Show()
				EVENT_MANAGER:RegisterForUpdate('RaidToolsAS', 1000, RaidToolsAsylum.Update)
			end
		end

	end)

	CALLBACK_MANAGER:RegisterCallback("OnBossFightOver", function(boss)
		IS_VALID_FIGHT = false
		if RaidTools.storage.modules.as_helper then
			EVENT_MANAGER:UnregisterForUpdate('RaidToolsAS')
			RaidToolsAsylum.Hide()
		end
	end)
	RaidToolsAsylum.BuildUI()
end

function RaidToolsAsylum.OnEffectChanged(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	--if unitTag == 'player' or string.match(unitTag, 'group') or unitTag == 'recticleover' then return end
	--if not string.match(unitTag, 'group') then return end.
	--d(string.format('changeType: %s, effectName: %s, unitTag: %s, stackCount: %s, buffType: %s, effectType: %s, abilityType: %s, statusEffectType: %s, unitName: %s, unitId: %s, abilityId: %s, sourceType: %s',
	--	changeType, effectName, unitTag, stackCount, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType
	--))
	if not IS_VALID_FIGHT then return end
	DetectUnit(unitId, unitName)

	if abilityId == ABILITY_MINIBOSS_SLEEP then ProcessBossSleep(unitId, changeType, endTime)
	elseif abilityId == ABILITY_MINIBOSS_ENRAGE then ProcessBossEnrage(unitId, changeType, stackCount) 
	elseif abilityId == ABILITY_FELMS_MAIM and unitTag == 'player' then ProcessMaimDebuff(endTime)
	elseif abilityId == ABILITY_FELMS_TELEPORT_CHECK then ProcessTeleportCheck(changeType, endTime, stackCount)
	elseif abilityId == ABILITY_FELMS_WRATH then
		bosses.felms.last_wrath = GetGameTimeMilliseconds()
		--d('player notify incoming wrath')
	end
	
end

function RaidToolsAsylum.OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	--d(string.format('result: %s, abilityName: %s, sourceName: %s, sourceType: %s, sourceUnitId: %s, abilityId: %s, targetUnitId: %s, targetName: %s', result, abilityName, sourceName, sourceType, sourceUnitId, abilityId,targetUnitId, targetName))
	if not IS_VALID_FIGHT then return end
	DetectUnit(unitId, sourceName)
	DetectUnit(unitId, targetName)
	if result == ACTION_RESULT_BEGIN then
		if abilityId == ABILITY_OLMS_HEAVEN_STORM then 
			bosses.olms.last_kite = GetGameTimeMilliseconds()
			--d('player alert kite')
			--if RaidTools.storage.config.asui.notify.heaven_storm then
			--	RaidTools.Announcement(FixName(GetAbilityName(abilityId))..' Kite!')
			--end
		elseif abilityId == ABILITY_FELMS_TELEPORT_STRIKE and targetType == COMBAT_UNIT_TYPE_PLAYER then 
			-- player alert incoming teleport strike
			--d('player alert incoming teleport strike')
			--if RaidTools.storage.config.asui.notify.teleport_strikes then
			--	RaidTools.Announcement('Incoming '..FixName(GetAbilityName(abilityId)))
			--end
		elseif abilityId == ABILITY_LLOTHIS_BOLTS_CHANNELING then
			-- player alert incoming bolts
			--d('player alert incoming bolts')
			--if RaidTools.storage.config.asui.notify.bolts then
			--	RaidTools.Announcement('|c'..CLR.cancer.hex..FixName(GetAbilityName(abilityId))..' Interrupt!')
			--end
			bosses.llothis.last_bolts = GetGameTimeMilliseconds()
		elseif abilityId == ABILITY_OLMS_BREATH then
			if GetGameTimeMilliseconds() - bosses.olms.last_breath > 3500 then
				--d('player alert incoming breath')
				bosses.olms.last_breath = GetGameTimeMilliseconds()
			end
		elseif abilityId == ABILITY_LLOTHIS_DEFILING_BLAST then
			--d('player alert incoming blast')
			bosses.llothis.last_blast = GetGameTimeMilliseconds()
		elseif abilityId == ABILITY_LLOTHIS_TRANSMISSION then
			--d('LLOTHIS TRANSMISSION')
			bosses.llothis.last_transmission = GetGameTimeMilliseconds()
		end
	elseif result == ACTION_RESULT_EFFECT_GAINED then
		if abilityId == ABILITY_OLMS_FIELD then
			--d('player alert incoming lightning aoe')
			bosses.olms.last_field = GetGameTimeMilliseconds()
		elseif abilityId == ABILITY_OLMS_SPHERE then 
			ProcessSphereSpawn(targetUnitId)
			--if RaidTools.storage.config.asui.notify.sphere_spawn then
			--	RaidTools.Announcement('|c'..CLR.cancer.hex..'Protector spawned!')
			--end
		end
	elseif result == ACTION_RESULT_DIED then
		if sphere.units[targetUnitId] then 
			ProcessSphereDeath(targetUnitId)
		end
	end
end

function RaidToolsAsylum.Update()
	local prefix, suffix = '', ''
	local time
	if not bosses.felms.active then
		RaidToolsAsylum.UIResetFelms()
		if bosses.felms.sleep_expires and bosses.felms.sleep_expires > 0 then
			time = ((GetGameTimeMilliseconds() - bosses.felms.sleep_expires)/1000)*-1
			if time < 10 then
				prefix = '|c008000'
			elseif time > 20 then
				prefix = '|cFF7401'
			else
				prefix = ''
			end
			BOX.felms.timer:SetText(string.format('%s %s', prefix, Time(time)))
		end

	else
		time = (GetGameTimeMilliseconds() - bosses.felms.sleep_expires)/1000
		if time > 200 then  -- 2 Minutes, 30 seconds
			prefix = '|c850000'
		elseif time > 170 then
			prefix = '|cFF7401'
		elseif time > 150 then
			prefix = '|cE3E300'
		else
			prefix = ''
		end
		if bosses.felms.enrage > 0 then
			suffix = ' (Enrage Lvl: '..bosses.felms.enrage..')'
		end
		BOX.felms:SetText(string.format('%s Felms%s', prefix, suffix))
		BOX.felms.timer:SetText(string.format('%s %s', prefix, Time(time)))

		time = (bosses.felms.teleportcd - GetGameTimeMilliseconds())/1000
		if time < 0 then time = 0 end
		if time < 3 then
			prefix = '|cFF7401'
		else
			prefix = ''
		end
		BOX.felms.jump:SetText(string.format('%s %s', prefix, Time(time)))

		time = (GetGameTimeMilliseconds() - bosses.felms.last_wrath)/1000
		if time < 0 or time > 60 then 
			prefix = '|cFF7401'
			time = 0 
			BOX.felms.wrath:SetText(string.format('%s %s', prefix, Time(time)))
		else
			if time > 12 then
				prefix = '|cFF7401'
			elseif time > 8 then
				prefix = '|cE3E300'
			else
				prefix = ''
			end

			BOX.felms.wrath:SetText(string.format('%s %s', prefix, Time(time)))
		end
	end

	if not bosses.llothis.active then
		RaidToolsAsylum.UIResetLlothis()
		if bosses.llothis.sleep_expires and bosses.llothis.sleep_expires > 0 then
			time = ((GetGameTimeMilliseconds() - bosses.llothis.sleep_expires)/1000)*-1
			if time < 10 then
				prefix = '|c008000'
			elseif time > 20 then
				prefix = '|cFF7401'
			else
				prefix = ''
			end
			BOX.llothis.timer:SetText(string.format('%s %s', prefix, Time(time)))
		end
	else
		time = (GetGameTimeMilliseconds() - bosses.llothis.sleep_expires)/1000
		if time > 200 then  -- 2 Minutes, 30 seconds
			prefix = '|c850000'
		elseif time > 170 then
			prefix = '|cFF7401'
		elseif time > 150 then
			prefix = '|cE3E300'
		else
			prefix = ''
		end
		if bosses.llothis.enrage > 0 then
			suffix = ' (Enrage Lvl: '..bosses.llothis.enrage..')'
		end
		BOX.llothis:SetText(string.format('%s Llothis%s', prefix, suffix))
		BOX.llothis.timer:SetText(string.format('%s %s', prefix, Time(time)))

		time = (GetGameTimeMilliseconds() - bosses.llothis.last_transmission) / 1000
		if time > 60 or time < 0 then 
			time = 0 
			prefix = '|c850000'
		else
			if time > 30 then -- jump between 25 and 35
				prefix = '|c850000'
			elseif time > 23 then
				prefix = '|cFF7401'
			else
				prefix = ''
			end
		end
		BOX.llothis.jump:SetText(string.format('%s %s', prefix, Time(time)))

		time = (GetGameTimeMilliseconds() - bosses.llothis.last_bolts) / 1000
		if time > 60 or time < 0 then 
			time = 0 
			prefix = '|c850000'
		else
			if time > 15 then 
				prefix = '|c850000'
			elseif time > 10 then
				prefix = '|cFF7401'
			else
				prefix = ''
			end
		end
		BOX.llothis.bolts:SetText(string.format('%s %s', prefix, Time(time)))

		time = (GetGameTimeMilliseconds() - bosses.llothis.last_blast) / 1000
		if time > 60 or time < 0 then 
			time = 0 
			prefix = '|c850000'
		else
			if time > 21 then 
				prefix = '|c850000'
			elseif time > 18 then
				prefix = '|cFF7401'
			else
				prefix = ''
			end
		end
		BOX.llothis.blast:SetText(string.format('%s %s', prefix, Time(time)))
	end

	if bosses.olms.last_kite and bosses.olms.last_kite > 0 then
		time = (GetGameTimeMilliseconds() - bosses.olms.last_kite)/1000
		if time > 30 then
			prefix = '|c850000'
		elseif time > 20 then
			prefix = '|cFF7401'
		else
			prefix = ''
		end
		BOX.kite:SetText(string.format('%s %s', prefix, Time(time)))
	end

	if bosses.olms.last_field and bosses.olms.last_field > 0 then
		time = (GetGameTimeMilliseconds() - bosses.olms.last_field)/1000
		if time > 10 then
			prefix = '|c850000'
		elseif time > 8 then
			prefix = '|cFF7401'
		else
			prefix = ''
		end
		BOX.field:SetText(string.format('%s %s', prefix, Time(time)))
	end

	if sphere.active then	
		time = (GetGameTimeMilliseconds() - sphere.last)/1000
		if time > 70 then
			prefix = '|c850000'
		elseif time > 50 then
			prefix = '|cFF7401'
		else
			prefix = ''
		end
		BOX.sphere:SetText(string.format('%s %s', prefix, Time(time)))
	elseif sphere.last_death > 0 then
		time = (GetGameTimeMilliseconds() - sphere.last_death)/1000
		if time < 10 then
			prefix = '|c008000'
		else
			prefix = '|cFF7401'
		end
		BOX.sphere:SetText(string.format('%s %s', prefix, Time(time)))
	end
end

function RaidToolsAsylum.UIReset()
	RaidToolsAsylum.UIResetFelms()
	RaidToolsAsylum.UIResetLlothis()
	RaidToolsAsylum.UIResetGeneral()
end

function RaidToolsAsylum.UIResetFelms()
	BOX.felms:SetText('|c808080 Felms')
	BOX.felms.timer:SetText('|c808080 ----')
	BOX.felms.jump:SetText('|c808080 ----')
	BOX.felms.wrath:SetText('|c808080 ----')
end

function RaidToolsAsylum.UIResetLlothis()
	BOX.llothis:SetText('|c808080 Llothis')
	BOX.llothis.timer:SetText('|c808080 ----')
	BOX.llothis.bolts:SetText('|c808080 ----')
	BOX.llothis.blast:SetText('|c808080 ----')
	BOX.llothis.jump:SetText('|c808080 ----')
end

function RaidToolsAsylum.UIResetGeneral()
	BOX.kite:SetText(' ----')
	BOX.field:SetText(' ----')
	BOX.sphere:SetText(' ----')
end

function RaidToolsAsylum.Show()
	--if RaidTools.storage and not RaidTools.storage.modules.status_bar then return end
	RaidToolsAsylum.UIReset()
	BOX.fragment:SetHiddenForReason("HideRaidToolvAS", false)
end

function RaidToolsAsylum.Hide()
	BOX.fragment:SetHiddenForReason("HideRaidToolvAS", true)
end

local function OnBaseGUIMoveStop()
	local x, y = RaidTools.storage.config.asui.x, RaidTools.storage.config.asui.y
	RaidTools.storage.config.asui.x = BOX:GetLeft()
	RaidTools.storage.config.asui.y = BOX:GetTop()
	RaidTools.DebugMessage(string.format('RaidToolsAsylum UI Moved: %s, %s -> %s, %s', x, y, RaidTools.storage.config.asui.x, RaidTools.storage.config.asui.y))
end

function RaidToolsAsylum.BuildUI()
	BOX = RaidTools.WM:CreateTopLevelWindow("RaidToolsvASUI")
	BOX:SetDimensions(300, 180)
	BOX:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RaidTools.storage.config.asui.x, RaidTools.storage.config.asui.y)
	BOX:SetClampedToScreen(true)
	BOX:SetMouseEnabled(true)
	BOX:SetMovable(true)
	BOX:SetHidden(true)
	BOX:SetAlpha(1)
	BOX:SetHandler("OnMoveStop", OnBaseGUIMoveStop)

	BOX.background = RaidTools.WM:CreateControl(nil, BOX, CT_BACKDROP)
	BOX.background:SetAnchorFill(BOX)
	BOX.background:SetEdgeTexture(nil, 1, 1, 1.0, 1.0)
	BOX.background:SetCenterColor(0.0, 0.0, 0.0, 0.6)
	if RaidTools.storage.config.asui.border then
		BOX.background:SetEdgeColor(255, 255, 255, 0.8)
	else
		BOX.background:SetEdgeColor(255, 255, 255, 0.0)
	end

	local _, _, _, speed_icon = GetAchievementInfo(1576)
	local _, _, _, olms_icon = GetAchievementInfo(2075)
	local _, _, _, jump_icon = GetAchievementInfo(1331)
	local _, _, _, bolts_icon = GetAchievementInfo(1548)
	local _, _, _, cone_icon = GetAchievementInfo(1958)
	local _, _, _, wrath_icon = GetAchievementInfo(2083)

	local _, _, sphere_icon = GetCollectibleInfo(1232)
	
	local x = {
		[0] = 5,
		[1] = 40,
		[2] = 100,
		[3] = 135,
		[4] = 195,
		[5] = 230
	}

	local y = {
		[1] = 30,
		[0] = 92,
		[2] = 140
	}
	--
	-- LLOTHIS
	--
	BOX.llothis = RaidTools.WM:CreateControl(nil, BOX, CT_LABEL)
	BOX.llothis:SetDimensions(300, 200)
	BOX.llothis:SetAnchor(TOPLEFT, BOX, TOPLEFT, 5, 65)
	BOX.llothis:SetFont('ZoFontConversationOption')
	BOX.llothis:SetHidden(false)
	BOX.llothis:SetText('Llothis')

	BOX.llothis.timer = RaidTools.WM:CreateControl(nil, BOX, CT_LABEL)
	BOX.llothis.timer:SetDimensions(300, 200)
	BOX.llothis.timer:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[1], y[0])
	BOX.llothis.timer:SetFont('ZoFontConversationOption')
	BOX.llothis.timer:SetText('00:00')

	BOX.llothis.timer.icon = RaidTools.WM:CreateControl(nil, BOX, CT_TEXTURE)
	BOX.llothis.timer.icon:SetDimensions(28, 28)
	BOX.llothis.timer.icon:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[0], y[0])
	BOX.llothis.timer.icon:SetTexture(speed_icon)

	BOX.llothis.bolts = RaidTools.WM:CreateControl(nil, BOX, CT_LABEL)
	BOX.llothis.bolts:SetDimensions(300, 200)
	BOX.llothis.bolts:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[3], y[0]+10)
	BOX.llothis.bolts:SetFont('ZoFontConversationOption')
	BOX.llothis.bolts:SetText('00:00')

	BOX.llothis.bolts.icon = RaidTools.WM:CreateControl(nil, BOX, CT_TEXTURE)
	BOX.llothis.bolts.icon:SetDimensions(22, 22)
	BOX.llothis.bolts.icon:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[2], y[0]+12)
	BOX.llothis.bolts.icon:SetTexture(bolts_icon)

	BOX.llothis.blast = RaidTools.WM:CreateControl(nil, BOX, CT_LABEL)
	BOX.llothis.blast:SetDimensions(300, 200)
	BOX.llothis.blast:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[5], y[0])
	BOX.llothis.blast:SetFont('ZoFontConversationOption')
	BOX.llothis.blast:SetText('00:00')

	BOX.llothis.blast.icon = RaidTools.WM:CreateControl(nil, BOX, CT_TEXTURE)
	BOX.llothis.blast.icon:SetDimensions(25, 25)
	BOX.llothis.blast.icon:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[4], y[0])
	BOX.llothis.blast.icon:SetTexture(cone_icon)

	BOX.llothis.jump = RaidTools.WM:CreateControl(nil, BOX, CT_LABEL)
	BOX.llothis.jump:SetDimensions(300, 200)
	BOX.llothis.jump:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[3], y[0]-15)
	BOX.llothis.jump:SetFont('ZoFontConversationOption')
	BOX.llothis.jump:SetText('00:00')

	BOX.llothis.jump.icon = RaidTools.WM:CreateControl(nil, BOX, CT_TEXTURE)
	BOX.llothis.jump.icon:SetDimensions(22, 22)
	BOX.llothis.jump.icon:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[2], y[0]-12)
	BOX.llothis.jump.icon:SetTexture(jump_icon)

	--
	-- FELMS
	--
	BOX.felms = RaidTools.WM:CreateControl(nil, BOX, CT_LABEL)
	BOX.felms:SetDimensions(300, 200)
	BOX.felms:SetAnchor(TOPLEFT, BOX, TOPLEFT, 5, 3)
	BOX.felms:SetFont('ZoFontConversationOption')
	BOX.felms:SetHidden(false)
	BOX.felms:SetText('Felms')

	BOX.felms.timer = RaidTools.WM:CreateControl(nil, BOX, CT_LABEL)
	BOX.felms.timer:SetDimensions(300, 200)
	BOX.felms.timer:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[1], y[1])
	BOX.felms.timer:SetFont('ZoFontConversationOption')
	BOX.felms.timer:SetText('00:00')

	BOX.felms.timer.icon = RaidTools.WM:CreateControl(nil, BOX, CT_TEXTURE)
	BOX.felms.timer.icon:SetDimensions(28, 28)
	BOX.felms.timer.icon:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[0], y[1])
	BOX.felms.timer.icon:SetTexture(speed_icon)

	BOX.felms.jump = RaidTools.WM:CreateControl(nil, BOX, CT_LABEL)
	BOX.felms.jump:SetDimensions(300, 200)
	BOX.felms.jump:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[5], y[1])
	BOX.felms.jump:SetFont('ZoFontConversationOption')
	BOX.felms.jump:SetText('00:00')

	BOX.felms.jump.icon = RaidTools.WM:CreateControl(nil, BOX, CT_TEXTURE)
	BOX.felms.jump.icon:SetDimensions(28, 28)
	BOX.felms.jump.icon:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[4], y[1])
	BOX.felms.jump.icon:SetTexture(jump_icon)

	BOX.felms.wrath = RaidTools.WM:CreateControl(nil, BOX, CT_LABEL)
	BOX.felms.wrath:SetDimensions(300, 200)
	BOX.felms.wrath:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[3], y[1])
	BOX.felms.wrath:SetFont('ZoFontConversationOption')
	BOX.felms.wrath:SetText('00:00')

	BOX.felms.wrath.icon = RaidTools.WM:CreateControl(nil, BOX, CT_TEXTURE)
	BOX.felms.wrath.icon:SetDimensions(28, 28)
	BOX.felms.wrath.icon:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[2], y[1])
	BOX.felms.wrath.icon:SetTexture(wrath_icon)

	--
	-- Seperator
	--
	BOX.sep = WINDOW_MANAGER:CreateControl("MyAddonTopDivider", BOX, CT_TEXTURE)
	BOX.sep:SetDimensions(350, 3)
	BOX.sep:SetAnchor(TOPLEFT, BOX, TOPLEFT, 0, 130)
	BOX.sep:SetTexture("/esoui/art/quest/questjournal_divider.dds")
	BOX.sep:SetColor(1, 1, 1, 1)

	--
	-- OLMS / GENERAL
	--
	BOX.kite = RaidTools.WM:CreateControl(nil, BOX, CT_LABEL)
	BOX.kite:SetDimensions(300, 200)
	BOX.kite:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[1], y[2])
	BOX.kite:SetFont('ZoFontConversationOption')
	BOX.kite:SetHidden(false)
	BOX.kite:SetText('00:00')

	BOX.kite.icon = RaidTools.WM:CreateControl(nil, BOX, CT_TEXTURE)
	BOX.kite.icon:SetDimensions(28, 28)
	BOX.kite.icon:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[0], y[2])
	BOX.kite.icon:SetTexture(olms_icon)

	BOX.field = RaidTools.WM:CreateControl(nil, BOX, CT_LABEL)
	BOX.field:SetDimensions(300, 200)
	BOX.field:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[3], y[2])
	BOX.field:SetFont('ZoFontConversationOption')
	BOX.field:SetHidden(false)
	BOX.field:SetText('00:00')

	BOX.field.icon = RaidTools.WM:CreateControl(nil, BOX, CT_TEXTURE)
	BOX.field.icon:SetDimensions(28, 28)
	BOX.field.icon:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[2], y[2])
	BOX.field.icon:SetTexture('/esoui/art/icons/death_recap_shock_aoe.dds')

	BOX.sphere = RaidTools.WM:CreateControl(nil, BOX, CT_LABEL)
	BOX.sphere:SetDimensions(300, 200)
	BOX.sphere:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[5], y[2])
	BOX.sphere:SetFont('ZoFontConversationOption')
	BOX.sphere:SetHidden(false)
	BOX.sphere:SetText('00:00')

	BOX.sphere.icon = RaidTools.WM:CreateControl(nil, BOX, CT_TEXTURE)
	BOX.sphere.icon:SetDimensions(28, 28)
	BOX.sphere.icon:SetAnchor(TOPLEFT, BOX, TOPLEFT, x[4], y[2])
	BOX.sphere.icon:SetTexture(sphere_icon)

	BOX.fragment = ZO_HUDFadeSceneFragment:New(BOX)
	HUD_SCENE:AddFragment(BOX.fragment)
    HUD_UI_SCENE:AddFragment(BOX.fragment)

    RaidToolsAsylum.UIReset()
    RaidToolsAsylum.Hide()
end