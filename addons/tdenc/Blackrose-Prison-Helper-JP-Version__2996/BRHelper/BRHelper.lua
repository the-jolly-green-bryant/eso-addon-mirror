BRHelper = {
	name = "BRHelper",
	version = "1.0.6",
	varVersion = 1, -- savedVariables version

	uiLocked = true,

	defaultSettings = {
		win1Color = {1, 0, 0, 1},
		win2Color = {0, 1, 0, 1},
		win3Color = {0, 1, 1, 1},

		showWaveInfo = true,
		showArrow = true,
		arrowColor = {1, 0, 1, 1},
		arrowScale = 1.5,

		trackBatSwarm = true,
		enableBatSwarmCountdown = true,

		trackVoid = true,
		trackChillSpear = true,
		trackBarrageOfStone = true,

		enableChatMessages = true,
	},
}

local BR = BRHelper

local currentRound = 0
local currentWave = 0

local lastPortalSpawn = 0

local reticleCount = 0

local takingAimList = {}
local heavyAttackList = {}
local barrageOfStoneList = {}
local voidList = {}

local meteorCount = 0
local shockwaveCount = 0
local chillSpearCount = 0
local spiritScreamCount = 0

local nextBatSwarm = 0

local bossWaveText = {}
-- Tames-the-Beast
bossWaveText[111315] = "トロール"
bossWaveText[111329] = "ワマス"
bossWaveText[111332] = "ハジ・モタ"
-- Lady Minara
bossWaveText[114213] = "注入者"
bossWaveText[114223] = "コロッサス"
bossWaveText[114230] = "コロッサス + 注入者"
bossWaveText[114236] = "コロッサス + |cFF00002x|r 注入者"

function BR.Initialize()

	-- Retrieve savedVariables
	BR.savedVariables = ZO_SavedVars:NewAccountWide("BRHelperSavedVariables", BR.varVersion, nil, BR.defaultSettings)

	LibSimpleArrow.CreateTexture()
	BR.UpdateArrowStyle()

	-- Build a Settings menu on addon settings tab
	BR.BuildMenu(BR.savedVariables)

	-- Restore colors and positions
	BR.RestorePosition()
	BR.RestoreColors()

	EVENT_MANAGER:RegisterForEvent(BR.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, BR.PlayerActivated)

end

function BR.OnAddOnLoaded(event, addonName)

	if addonName == BR.name then
		BR.Initialize()
	end

end

function BR.UpdateArrowStyle()

	LibSimpleArrow.ApplyStyle(BR.name .. "/texture/arrow2.dds", BR.savedVariables.arrowColor, BR.savedVariables.arrowScale)

end

function BR.PlayerActivated()

	LibUnits2.RefreshUnits()

	BR.HideControls()
	BRHelperWave:SetHidden(true)

	if GetZoneId(GetUnitZoneIndex("player")) == 1082 then

		-- Register events

		EVENT_MANAGER:RegisterForEvent(BR.name .. "Combat", EVENT_PLAYER_COMBAT_STATE, BR.PlayerCombatState)
		EVENT_MANAGER:RegisterForEvent(BR.name .. "Announcement", EVENT_DISPLAY_ANNOUNCEMENT, BR.Announcement)

		-- Interrupt & Stun
		EVENT_MANAGER:RegisterForEvent(BR.name .. "Interrupt", EVENT_COMBAT_EVENT, BR.Interrupt)
		EVENT_MANAGER:AddFilterForEvent(BR.name .. "Interrupt", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_INTERRUPT)
		EVENT_MANAGER:RegisterForEvent(BR.name .. "Stun", EVENT_COMBAT_EVENT, BR.Interrupt)
		EVENT_MANAGER:AddFilterForEvent(BR.name .. "Stun", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_STUNNED)

		-- Death
		EVENT_MANAGER:RegisterForEvent(BR.name .. "Death", EVENT_COMBAT_EVENT, BR.Death)
		EVENT_MANAGER:AddFilterForEvent(BR.name .. "Death", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED)
		EVENT_MANAGER:RegisterForEvent(BR.name .. "DeathXP", EVENT_COMBAT_EVENT, BR.Death)
		EVENT_MANAGER:AddFilterForEvent(BR.name .. "DeathXP", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED_XP)

		-- Boss wave spawns
		for k, v in pairs(bossWaveText) do
			EVENT_MANAGER:RegisterForEvent(BR.name .. "BossWaveSpawn" .. k, EVENT_COMBAT_EVENT, BR.BossWaveSpawn)
			EVENT_MANAGER:AddFilterForEvent(BR.name .. "BossWaveSpawn" .. k, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k)
		end

		-- Abilities
		for k, v in pairs(BRHelperAbilities) do
			EVENT_MANAGER:RegisterForEvent(BR.name .. "Ability" .. k, EVENT_COMBAT_EVENT, v)
			EVENT_MANAGER:AddFilterForEvent(BR.name .. "Ability" .. k, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k)
		end

	else

		-- Unregister events

		EVENT_MANAGER:UnregisterForEvent(BR.name .. "Combat", EVENT_PLAYER_COMBAT_STATE)
		EVENT_MANAGER:UnregisterForEvent(BR.name .. "Announcement", EVENT_DISPLAY_ANNOUNCEMENT)

		EVENT_MANAGER:UnregisterForEvent(BR.name .. "Interrupt", EVENT_COMBAT_EVENT)
		EVENT_MANAGER:UnregisterForEvent(BR.name .. "Stun", EVENT_COMBAT_EVENT)

		EVENT_MANAGER:UnregisterForEvent(BR.name .. "Death", EVENT_COMBAT_EVENT)
		EVENT_MANAGER:UnregisterForEvent(BR.name .. "DeathXP", EVENT_COMBAT_EVENT)

		for k, v in pairs(bossWaveText) do
			EVENT_MANAGER:UnregisterForEvent(BR.name .. "BossWaveSpawn" .. k, EVENT_COMBAT_EVENT)
		end

		for k, v in pairs(BRHelperAbilities) do
			EVENT_MANAGER:UnregisterForEvent(BR.name .. "Ability" .. k, EVENT_COMBAT_EVENT)
		end

	end

end

local function FormatTakingAimList()

	local countdownList = {}
	local countdownListFormatted = {}
	local t = GetGameTimeMilliseconds()

	for unitId, timestamp in pairs(takingAimList) do
		if timestamp > t then
			table.insert(countdownList, timestamp - t)
		end
	end

	if #countdownList > 0 then
		table.sort(countdownList)
		for _, value in ipairs(countdownList) do
			local strformat = value > 1000 and "|cFFFFFF%0.1f|r" or "|cFF0000%0.1f|r"
			table.insert(countdownListFormatted, string.format(strformat, value / 1000))
		end
		return table.concat(countdownListFormatted, " / ")
	else
		return nil
	end

end

local function FormatHeavyAttackList()

	local countdownList = {}
	local countdownListFormatted = {}
	local t = GetGameTimeMilliseconds()

	for _, value in ipairs(heavyAttackList) do
		if value[1] > t then
			table.insert(countdownList, {value[1] - t, value[2]})
		end
	end

	if #countdownList > 0 then
		table.sort(countdownList, function(a, b) return a[1] < b[1] end)
		for _, value in ipairs(countdownList) do
			local strformat = "|c" .. value[2] .. "%0.1f|r"
			table.insert(countdownListFormatted, string.format(strformat, value[1] / 1000))
		end
		return table.concat(countdownListFormatted, " / ")
	else
		return nil
	end

end

local function FormatBarrageOfStoneList()

	local countdownList = {}
	local countdownListFormatted = {}
	local t = GetGameTimeMilliseconds()

	for unitId, timestamp in pairs(barrageOfStoneList) do
		if timestamp + 1000 > t then
			table.insert(countdownList, timestamp - t)
		end
	end

	if #countdownList > 0 then
		table.sort(countdownList)
		for _, value in ipairs(countdownList) do
			local strformat = value > 0 and "|cFFFF00%0.1f|r" or "|cFF0000%0.1f|r"
			table.insert(countdownListFormatted, string.format(strformat, math.max(0, value / 1000)))
		end
		return table.concat(countdownListFormatted, " / ")
	else
		return nil
	end

end

local function FormatVoidList()

	local countdownList = {}
	local countdownListFormatted = {}
	local t = GetGameTimeMilliseconds()

	for unitId, timestamp in pairs(voidList) do
		if timestamp + 500 > t then
			table.insert(countdownList, timestamp - t)
		end
	end

	if #countdownList > 0 then
		table.sort(countdownList)
		for _, value in ipairs(countdownList) do
			local strformat = value > 0 and "|cFFFF00%0.1f|r" or "|cFF0000%0.1f|r"
			table.insert(countdownListFormatted, string.format(strformat, math.max(0, value / 1000)))
		end
		return table.concat(countdownListFormatted, " / ")
	else
		return nil
	end

end

local function GetCurrentStage()

	local x, y = GetMapPlayerPosition('player');

	if x > 0.54 and x < 0.64 and y > 0.79 and y < 0.89 then
		return 1
	elseif x > 0.3 and x < 0.4 and y > 0.69 and y < 0.8 then
		return 2
	elseif x > 0.41 and x < 0.52 and y > 0.43 and y < 0.53 then
		return 3
	elseif x > 0.63 and x < 0.73 and y > 0.22 and y < 0.32 then
		return 4
	elseif x > 0.4 and x < 0.5 and y > 0.08 and y < 0.18 then
		return 5
	else
		return 0
	end

end

local function NotifyNewWave()

	local s = GetCurrentStage()
	local r = currentRound
	local w = currentWave

	local dps = LFG_ROLE_DPS
	local tank = LFG_ROLE_TANK
	local heal = LFG_ROLE_HEAL
	local all = 0

	local msg = {}
	local arr = {}

	-- STAGE 1
	if s == 1 then

		if r == 1 and w == 2 then
			msg[all] = "|cFFFF00クリーヴァー [東]|r"
			arr[all] = {0.63297873735428, 0.83144944906235}
		end

		if r == 1 and w == 3 then
			msg[all] = "|cFFFF00ドレッド・ナイト [東]|r"
			arr[all] = {0.63364362716675, 0.82380318641663}
		end

		if r == 2 and w == 1 then
			msg[all] = "|cFFFF00メイジ [南]|r"
			arr[all] = {0.60073137283325, 0.88331115245819}
		end

		if r == 3 and w == 1 then
			msg[all] = "|cFFFF00クリーヴァー [東]|r"
			arr[all] = {0.63364362716675, 0.82380318641663}
		end

		if r == 3 and w == 2 then
			msg[all] = "|cFFFF00メイジ [北]|r"
			arr[all] = {0.57945477962494, 0.79787236452103}
		end

		if r == 3 and w == 3 then
			msg[all] = "|cFFFF00メイジ [北]|r"
			arr[all] = {0.60039895772934, 0.796875}
		end

		if r == 4 and w == 2 then
			msg[dps] = "クリーヴァー無視, 2xメイジ優先"

			msg[heal] = "|cFF00FF2x|r |cFFFF00メイジ [北・南]|r"
			arr[heal] = {0.57945477962494, 0.79787236452103}

			msg[tank] = "|cFF00FF2x|r |cFFFF00メイジ [北・南]|r"
			arr[tank] = {0.57413566112518, 0.87965422868729}
		end
		if r == 4 and w == 3 then msg[all] = "|c00FF00最終ウェーブ!|r" end

	-- STAGE 2
	elseif s == 2 then

		if r == 1 and w == 2 then msg[all] = "|cFF00FF2x|r |cFF0000クロコダイル!|r" end
		if r == 1 and w == 3 then
			msg[all] = "|cFFFF00アーチャー [北]|r"
			arr[all] = {0.33743351697922, 0.70545214414597}
		end

		if r == 2 and w == 2 then msg[all] = "|cFF0000ハジ・モタ + クロコダイル!|r" end
		if r == 2 and w == 3 then
			msg[heal] = "|cFFFF00アーチャー [北]|r"
			arr[heal] = {0.33743351697922, 0.70545214414597}

			msg[all] = "アーチャー [北] + 蜘蛛"
		end

		if r == 3 and w == 1 then msg[all] = "トロール, 2x 蜘蛛, 2x 鳥" end
		if r == 3 and w == 2 then msg[all] = "|cFF00FF2x|r |cFF0000クロコダイル + トロール!|r" end
		if r == 3 and w == 3 then
			msg[heal] = "|cFFFF00アーチャー [東]|r"
			arr[heal] = {0.3916223347187, 0.734375}

			msg[all] = "トロール + アーチャー [東]"
		end

		if r == 4 and w == 1 then msg[all] = "|cFF00FF2x|r |cFF0000クロコダイル!|r" end
		if r == 4 and w == 2 then
			msg[heal] = "|cFF00FF2x|r |cFFFF00アーチャー [東・西]|r"
			arr[heal] = {0.390625, 0.75797873735428}

			arr[tank] = {0.30684840679169, 0.7516622543335}

			msg[all] = "|c00FF002x アーチャー, 後でワマス（最終ウェーブ!）|r"
		end

		if r == 5 and w == 1 then msg[all] = "60% ハジ・モタ, 40% ワマス" end

	-- STAGE 3
	elseif s == 3 then

		if r == 1 and w == 2 then msg[all] = "|cFF00FF3x|r |cFF0000注入者!|r" end
		if r == 1 and w == 3 then msg[all] = "|cFF0000ガーゴイル|r + |cFF00FF2x|r |cFF0000注入者!|r" end

		if r == 2 and w == 1 then msg[all] = "|cFF00FF2x|r |cFF0000注入者!|r" end
		if r == 2 and w == 3 then msg[all] = "|cFF0000ガーゴイル!|r" end

		if r == 3 and w == 1 then msg[all] = "|cFF00FF2x|r |cFF0000注入者|r + 2x 氷メイジ" end
		if r == 3 and w == 2 then msg[all] = "|cFF0000ガーゴイル!|r" end
		if r == 3 and w == 3 then msg[all] = "|cFF0000注入者|r [北]" end

		if r == 4 and w == 3 then msg[all] = "|c00FF00最終ウェーブ!|r" end

		if r == 5 and w == 1 then BR.StartBatSwarmCountdown(18000) end

	-- STAGE 4
	elseif s == 4 then

		if r == 1 and w == 1 then
			msg[all] = "|cFFFF00クリーヴァー [北]|r"
			arr[all] = {0.67619681358337, 0.22639627754688}
		end
		if r == 1 and w == 2 then
			msg[all] = "|cFF0000クロコダイル + 3x メイジ|r"
			arr[heal] = {0.64128988981247, 0.28125}
		end
		if r == 1 and w == 3 then
			msg[all] = "|cFFFF00アーチャー [北]|r"
			arr[all] = {0.67619681358337, 0.22639627754688}
		end

		if r == 2 and w == 1 then
			msg[all] = "|cFFFF00メイジ [西]|r"
			arr[all] = {0.64128988981247, 0.28125}
		end
		if r == 2 and w == 3 then
			arr[heal] = {0.64128988981247, 0.28125}
			arr[tank] = {0.72373670339584, 0.28457447886467}
			msg[all] = "|cFF0000ボス + 2x メイジ!|r"
		end

		if r == 3 and w == 1 then
			msg[all] = "|cFFFF00アーチャー [北]|r"
			arr[all] = {0.67619681358337, 0.22639627754688}
		end
		if r == 3 and w == 2 then msg[all] = "|cFF0000ハジ・モタ|r + 蜘蛛" end
		if r == 3 and w == 3 then msg[all] = "|cFF0000ボス + 2x クロコダイル!|r" end

		if r == 4 and w == 2 then msg[all] = "|cFF0000ガーゴイル + 2x 注入者!|r" end
		if r == 4 and w == 3 then
			arr[heal] = {0.64128988981247, 0.28125}
			msg[all] = "|cFF0000ボス + 2x メイジ!|r"
			BR.StartBatSwarmCountdown(18000)
		end

		if r == 5 and w == 3 then
			msg[tank] = "|cFF0000レディ・ミナラ|r"
			BR.StartBatSwarmCountdown(18000)
		end

	-- STAGE 5
	elseif s == 5 then

		if r == 1 and w == 1 then msg[all] = "|cFF00FF2x|r |cFF0000メイジ!|r" end
		if r == 1 and w == 2 then msg[all] = "|cFF00FF2x|r |cFF0000メイジ!|r" end

		if r == 2 and w == 3 then msg[all] = "|cFF00FF2x|r |cFF0000メイジ!|r" end

		if r == 3 and w == 1 then msg[all] = "|cFF00FF2x|r |cFF0000メイジ!|r" end

		if r == 4 and w == 1 then msg[all] = "|cFF00FF2x|r |cFF0000メイジ!|r" end
		if r == 4 and w == 3 then msg[all] = "|cFF00FF2x|r |cFF0000メイジ!|r" end
		--if r == 4 and w == 3 then msg[all] = "|c00FF00最終ウェーブ!|r" end

	end

	-- Show message and arrow

	local role = GetSelectedLFGRole()
	local m, a

	if msg[role] then m = msg[role] end
	if arr[role] then a = arr[role] end
	if not m and msg[all] then m = msg[all] end
	if not a and arr[all] then a = arr[all] end

	if BR.savedVariables.showWaveInfo and m then
		BR.ShowWave(m)
		PlaySound(SOUNDS.TELVAR_GAINED)
		zo_callLater(function() BR.HideWave() end, 5000)
	end

	if BR.savedVariables.showArrow and a then
		LibSimpleArrow.SetTarget(a)
		LibSimpleArrow.ShowArrow()
		zo_callLater(function() LibSimpleArrow.HideArrow() end, 5000)
	end

	if BR.savedVariables.enableChatMessages then
		d(string.format("アリーナ: %s. ラウンド: %s. ウェーブ: %s.", s, r, w))
	end

end

function BR.Announcement(_, title, _)

	if title == 'Final Round' or title == 'Letzte Runde' or title == 'Dernière manche' or title == 'Последний раунд' or title == '最終ラウンド' then
		currentRound = 5
		currentWave = 0
	else
		local round = string.match(title, '^.+(%d)$')
		if round then
			currentRound = tonumber(round)
			currentWave = 0
		end
	end

end

function BR.PortalSpawn(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_EFFECT_GAINED then

		local t = GetGameTimeMilliseconds()

		if t - lastPortalSpawn > 2000 then
			currentWave = currentWave + 1
			NotifyNewWave()
		end

		lastPortalSpawn = t

	end

end

function BR.TakingAim(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER then

		takingAimList[sourceUnitId] = GetGameTimeMilliseconds() + hitValue

		BR.ShowReticle(string.format('スナイプ: %s', FormatTakingAimList()))
		PlaySound(SOUNDS.DUEL_START)

		EVENT_MANAGER:UnregisterForUpdate("BRTakingAimTimer")
		EVENT_MANAGER:RegisterForUpdate("BRTakingAimTimer", 100, BR.TakingAimTimer)

	end

end

function BR.TakingAimTimer()

	local text = FormatTakingAimList()

	if not text or text == "" then
		EVENT_MANAGER:UnregisterForUpdate("BRTakingAimTimer")
		BR.HideReticle()
	else
		BR.ShowReticle(string.format('スナイプ: %s', text))
	end

end

function BR.HeavyAttack(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if targetType ~= COMBAT_UNIT_TYPE_PLAYER or hitValue < 100 then return end

	if result == ACTION_RESULT_BEGIN then

		local color = "FFFF00"
		if string.find(sourceName, 'ガーゴイル') then color = "FF0000"
		elseif string.find(sourceName, 'ミナラ') then color = "FFFF00"
		elseif string.find(sourceName, 'コロッサス') then color = "00FFFF"
		elseif string.find(sourceName, '捕虜') then color = "FFFF00"
		elseif string.find(sourceName, 'ドラキー') then color = "FFFF00" end

		table.insert(heavyAttackList, {GetGameTimeMilliseconds() + hitValue, color})

		BR.HeavyAttackTimer()
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

		EVENT_MANAGER:UnregisterForUpdate("BRHeavyAttackTimer")
		EVENT_MANAGER:RegisterForUpdate("BRHeavyAttackTimer", 100, BR.HeavyAttackTimer)

	end

end

function BR.HeavyAttackTimer()

	local text = FormatHeavyAttackList()

	if not text or text == "" then
		EVENT_MANAGER:UnregisterForUpdate("BRHeavyAttackTimer")
		BR.HideReticle()
	else
		BR.ShowReticle(string.format('重攻撃: %s', text))
	end

end

function BR.Interrupt(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	-- interrupted taking aim
	if takingAimList[targetUnitId] then
		takingAimList[targetUnitId] = 0
	end

end

function BR.Death(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	-- taking aim caster is dead
	if takingAimList[targetUnitId] then
		takingAimList[targetUnitId] = 0
	end

	if string.find(targetName, 'ミナラ') then nextBatSwarm = 0 end

end

function BR.LavaWhip(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER then

		BRHelper.ShowReticle('溶岩のムチ!')
		PlaySound(SOUNDS.DUEL_START)

		zo_callLater(function() BR.HideReticle() end , 1800)

	end

end

-- First boss Meteors
function BR.Meteor(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_EFFECT_GAINED and targetType == COMBAT_UNIT_TYPE_PLAYER then

		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

		meteorCount = 3900
		EVENT_MANAGER:UnregisterForUpdate("BRMeteorTimer")
		EVENT_MANAGER:RegisterForUpdate("BRMeteorTimer", 100, BR.MeteorTick)

		BR.MeteorTick()

	end

end

function BR.MeteorTick()

	if meteorCount < 0 then
		EVENT_MANAGER:UnregisterForUpdate("BRMeteorTimer")
		BR.HideWin1()
	else
		local color = meteorCount > 1500 and 'FFFFFF' or 'FF8800'
		BR.ShowWin1(string.format('メテオ: |c%s%0.1f|r', color, meteorCount / 1000))
	end
	meteorCount = meteorCount - 100

end

function BR.Shockwave(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_BEGIN then

		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

		shockwaveCount = 2000
		EVENT_MANAGER:UnregisterForUpdate("BRShockwaveTimer")
		EVENT_MANAGER:RegisterForUpdate("BRShockwaveTimer", 100, BR.ShockwaveTick)

		BR.ShockwaveTick()

	end

end

function BR.ShockwaveTick()

	if shockwaveCount <= 0 then
		EVENT_MANAGER:UnregisterForUpdate("BRShockwaveTimer")
		PlaySound(SOUNDS.DUEL_START)
		BR.ShowWin3('|cFFFF00ロール回避 / ブロック!|r')
		zo_callLater(function() BR.HideWin3() end , 1000)
	else
		local color = shockwaveCount > 1000 and 'FFFF00' or 'FF6600'
		BR.ShowWin3(string.format('ショックウェーブ: |c%s%0.1f|r', color, shockwaveCount / 1000))
	end
	shockwaveCount = shockwaveCount - 100

end

function BR.ImpendingStorm(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_BEGIN then

		BR.ShowWin2('ワマスストーム!')
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

		zo_callLater(function() BR.HideWin2() end , 2000)

	end

end

function BR.BugBomb(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_BEGIN then

		if targetType == COMBAT_UNIT_TYPE_PLAYER then
			targetName = '自分'
		elseif not targetName or targetName == "" then
			targetName = LibUnits2.GetNameForUnitId(targetUnitId)
		end

		BR.ShowWin1(zo_strformat('スタック先: |cFFFFFF<<1>>|r', targetName == "" and "?" or targetName))
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

		zo_callLater(function() BR.HideWin1() end , 5000)

	end

end

function BR.FocalQuake(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_BEGIN and hitValue == 800 then

		BR.ShowWin1('ガーゴイル踏み付け!')
		PlaySound(SOUNDS.DUEL_START)

		zo_callLater(function() BR.HideWin1() end , 2000)

	end

end

function BR.ExplosiveBash(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER then

		BR.ShowReticle('爆発強撃!')
		PlaySound(SOUNDS.DUEL_START)

		zo_callLater(function() BR.HideReticle() end , 1500)

	end

end

function BR.MinarasCurse(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER then

		if hitValue == 2000 then
			BRHelper.ShowWin1('呪い')
			PlaySound(SOUNDS.DUEL_START)
			zo_callLater(function() BR.HideWin1() end , 4000)
		elseif hitValue == 6000 then
			BRHelper.ShowWin1('呪われた! |cFFFF00浄化エリアへ!|r')
		end

	end

end

function BR.DrainEssence(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and hitValue == 500 then

		BR.ShowReticle('打破!')
		zo_callLater(function() BR.HideReticle() end , 3000)
		PlaySound(SOUNDS.DUEL_START)

	elseif result == ACTION_RESULT_EFFECT_FADED then

		BR.HideReticle()

	end

end

function BR.BatSwarm(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if not BR.savedVariables.trackBatSwarm then return end

	if result == ACTION_RESULT_BEGIN --[[and targetType == COMBAT_UNIT_TYPE_PLAYER]] then

		BR.ShowWin2('蝙蝠の群れ |cFFFFFF- 回避!|r')
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
		zo_callLater(function() BR.HideWin2() end , 2000)

		local s = GetCurrentStage()
		if s == 3 then
			BR.StartBatSwarmCountdown(36000)
		elseif s == 4 then
			BR.StartBatSwarmCountdown(28000)
		end

	end

end

function BR.StartBatSwarmCountdown(delta)

	if not BR.savedVariables.enableBatSwarmCountdown then return end

	nextBatSwarm = GetGameTimeMilliseconds() + delta
	EVENT_MANAGER:UnregisterForUpdate("BRBatSwarmTimer")
	EVENT_MANAGER:RegisterForUpdate("BRBatSwarmTimer", 500, BR.BatSwarmTick)

	BR.BatSwarmTick()

end

function BR.BatSwarmTick()

	local t = GetGameTimeMilliseconds()

	if t - nextBatSwarm >= 15000 then
		EVENT_MANAGER:UnregisterForUpdate("BRBatSwarmTimer")
		BR.HideWin2()
	elseif nextBatSwarm - t <= 10000 then
		local color = nextBatSwarm - t > 3000 and 'FFFF00' or 'FF6600'
		BR.ShowWin2(string.format('蝙蝠の群れ: |c%s%d|r', color, math.max(0, (nextBatSwarm - t) / 1000)), 0.8)
	end

end

function BR.StoneTotem(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_EFFECT_GAINED then

		BRHelper.ShowWin3('石トーテム!')
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

		zo_callLater(function() BR.HideWin3() end , 3000)

	end

end

function BR.DefilingEruption(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_EFFECT_GAINED then

		BR.ShowWin2('汚染間欠泉!')
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

		zo_callLater(function() BR.HideWin2() end , 5000)

	end

end

function BR.ChillSpearCast(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if not BR.savedVariables.trackChillSpear then return end

	if result == ACTION_RESULT_BEGIN and hitValue > 1 then

		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

		chillSpearCount = hitValue == nil and 1333 or hitValue
		EVENT_MANAGER:UnregisterForUpdate("BRChillSpearTimer")
		EVENT_MANAGER:RegisterForUpdate("BRChillSpearTimer", 100, BR.ChillSpearTick)

		BR.ChillSpearTick()

	end

end

function BR.ChillSpear(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if not BR.savedVariables.trackChillSpear then return end

	if result == ACTION_RESULT_EFFECT_GAINED and targetType == COMBAT_UNIT_TYPE_PLAYER and hitValue == 1 then

		EVENT_MANAGER:UnregisterForUpdate("BRChillSpearTimer")
		BRHelper.ShowReticle('|cFF0000ロール回避 / ブロック|r')
		zo_callLater(function() BR.HideReticle() end , 1000)
		PlaySound(SOUNDS.DUEL_START)

	end

end

function BR.ChillSpearTick()

	if chillSpearCount < 0 then
		EVENT_MANAGER:UnregisterForUpdate("BRChillSpearTimer")
		BR.HideReticle()
	else
		BR.ShowReticle(string.format('冷気の槍: |cFF8800%0.1f|r', chillSpearCount / 1000))
	end
	chillSpearCount = chillSpearCount - 100

end

function BR.HauntingSpectre(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER then

		BRHelper.ShowWin1('祟りの亡霊 - |cFFFF00バッシュ!|r')
		zo_callLater(function() BR.HideWin1() end , 2000)
		PlaySound(SOUNDS.DUEL_START)

	end

end

function BR.Void(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if not BR.savedVariables.trackVoid then return end

	if result == ACTION_RESULT_BEGIN then

		voidList[#voidList + 1] = GetGameTimeMilliseconds() + hitValue

		BRHelper.ShowWin1(string.format('虚無: %s', FormatVoidList()))
		PlaySound(SOUNDS.DUEL_START)

		EVENT_MANAGER:UnregisterForUpdate("BRVoidTimer")
		EVENT_MANAGER:RegisterForUpdate("BRVoidTimer", 100, BR.VoidTimer)

	end

end

function BR.VoidTimer()

	local text = FormatVoidList()

	if not text or text == "" then
		EVENT_MANAGER:UnregisterForUpdate("BRVoidTimer")
		BR.HideWin1()
	else
		BRHelper.ShowWin1(string.format('虚無: %s', text))
	end

end

function BR.BarrageOfStone(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if not BR.savedVariables.trackBarrageOfStone then return end

	if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and hitValue == 1000 then

		barrageOfStoneList[#barrageOfStoneList + 1] = GetGameTimeMilliseconds() + hitValue + 100

		BR.ShowReticle(string.format('投石: %s', FormatBarrageOfStoneList()))
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

		EVENT_MANAGER:UnregisterForUpdate("BRBarrageOfStoneTimer")
		EVENT_MANAGER:RegisterForUpdate("BRBarrageOfStoneTimer", 100, BR.BarrageOfStoneTimer)

	end

end

function BR.BarrageOfStoneTimer()

	local text = FormatBarrageOfStoneList()

	if not text or text == "" then
		EVENT_MANAGER:UnregisterForUpdate("BRBarrageOfStoneTimer")
		BR.HideReticle()
	else
		BR.ShowReticle(string.format('投石: %s', text))
	end

end

function BR.SpiritScream(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_BEGIN then

		spiritScreamCount = hitValue
		EVENT_MANAGER:UnregisterForUpdate("BRSpiritScreamTimer")
		EVENT_MANAGER:RegisterForUpdate("BRSpiritScreamTimer", 100, BR.SpiritScreamTick)

		BR.SpiritScreamTick()

	end

end

function BR.SpiritScreamTick()

	if spiritScreamCount <= 0 then
		EVENT_MANAGER:UnregisterForUpdate("BRSpiritScreamTimer")
		BR.HideWin2()
	else
		local color = spiritScreamCount > 1000 and 'FFFF00' or 'FF6600'
		BR.ShowWin2(string.format('魂の叫び: |c%s%0.1f|r', color, spiritScreamCount / 1000))
	end
	spiritScreamCount = spiritScreamCount - 100

end

function BR.BossWaveSpawn(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_EFFECT_GAINED and bossWaveText[abilityId] then

		BRHelperWave:SetHidden(false)
		BRHelperWave_Label:SetText(string.format("|cFFFF00%s|r", bossWaveText[abilityId]))

		PlaySound(SOUNDS.TELVAR_GAINED)
		zo_callLater(function() BR.HideWave() end, 5000)

	end

end

function BR.RumblingSmash(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_BEGIN and hitValue == 2000 then

		if targetType == COMBAT_UNIT_TYPE_PLAYER then
			targetName = '自分'
		elseif not targetName or targetName == "" then
			targetName = LibUnits2.GetNameForUnitId(targetUnitId)
		end

		BR.ShowWin1(zo_strformat('スマッシュ対象 |cFFFFFF<<1>>|r', targetName == "" and "?" or targetName))

		zo_callLater(function() BR.HideWin1() end , 4000)

	end

end

function BR.ShowReticle(text, subtext)

	BRHelperReticle:SetHidden(false)
	BRHelperReticle:SetAlpha(1)

	if (text ~= nil) then
		BRHelperReticle_Label:SetText(text)
	end

	if (subtext ~= nil) then
		BRHelperReticle_Sublabel:SetText(subtext)
	end

end

function BR.HideReticle()

	BRHelperReticle:SetHidden(true)

end

function BR.ShowWave(text)

	BRHelperWave:SetHidden(false)

	if text ~= nil then
		BRHelperWave_Label:SetText(string.format("|c666666(%d.%d)|r %s", currentRound, currentWave, text))
	end

end

function BR.HideWave()

	BRHelperWave:SetHidden(true)

end

function BR.ShowWin1(text)

	BRHelperWin1:SetHidden(false)

	if (text ~= nil) then
		BRHelperWin1_Label:SetText(text)
	end

end

function BR.HideWin1()

	BRHelperWin1:SetHidden(true)

end

function BR.ShowWin2(text, alpha)

	BRHelperWin2:SetHidden(false)
	BRHelperWin2:SetAlpha(alpha and alpha or 1)

	if (text ~= nil) then
		BRHelperWin2_Label:SetText(text)
	end

end

function BR.HideWin2()

	BRHelperWin2:SetHidden(true)

end

function BR.ShowWin3(text)

	BRHelperWin3:SetHidden(false)

	if (text ~= nil) then
		BRHelperWin3_Label:SetText(text)
	end

end

function BR.HideWin3()

	BRHelperWin3:SetHidden(true)

end

function BR.HideControls()

	BRHelperReticle:SetHidden(true)

	BRHelperWin1:SetHidden(true)
	BRHelperWin2:SetHidden(true)
	BRHelperWin3:SetHidden(true)

end

function BR.PlayerCombatState()

	if IsUnitInCombat("player") then
		--d("|cFF0000COMBAT START|r")
		BR.StartMonitoringFight()
	else
		--d("|c00FF00COMBAT END|r")
		BR.StopMonitoringFight()
	end

end

function BR.StartMonitoringFight()

	BR.ResetFight()

end

function BR.StopMonitoringFight()

	BR.ResetFight()

	nextBatSwarm = 0 -- stop bat swarm timer

end

function BR.ResetFight()

	BR.HideControls()

	takingAimList = {}
	heavyAttackList = {}
	barrageOfStoneList = {}
	voidList = {}

end

function BR.UnlockUI()

	BR.ShowWave("|cFF0000ワマス|r 出現!")
	BR.ShowWin1("危険な通知")
	BR.ShowWin2("重要な通知")
	BR.ShowWin3("その他の通知")

	BR.uiLocked = false

end

function BR.LockUI()

	BR.HideWave()
	BR.HideWin1()
	BR.HideWin2()
	BR.HideWin3()

	BR.uiLocked = true

end

function BR.RestorePosition()

	--[[
	local waveLeft = BR.savedVariables.waveLeft
	local waveTop = BR.savedVariables.waveTop

	local win1Left = BR.savedVariables.win1Left
	local win1Top = BR.savedVariables.win1Top

	local win2Left = BR.savedVariables.win2Left
	local win2Top = BR.savedVariables.win2Top

	local win3Left = BR.savedVariables.win3Left
	local win3Top = BR.savedVariables.win3Top

	if waveLeft or waveTop then
		BRHelperWave:ClearAnchors()
		BRHelperWave:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, waveLeft, waveTop)
	end

	if win1Left or win1Top then
		BRHelperWin1:ClearAnchors()
		BRHelperWin1:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, win1Left, win1Top)
	end

	if win2Left or win2Top then
		BRHelperWin2:ClearAnchors()
		BRHelperWin2:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, win2Left, win2Top)
	end

	if win3Left or win3Top then
		BRHelperWin3:ClearAnchors()
		BRHelperWin3:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, win3Left, win3Top)
	end
	]]

	local waveCenterX = BR.savedVariables.waveCenterX
	local waveCenterY = BR.savedVariables.waveCenterY

	local win1CenterX = BR.savedVariables.win1CenterX
	local win1CenterY = BR.savedVariables.win1CenterY

	local win2CenterX = BR.savedVariables.win2CenterX
	local win2CenterY = BR.savedVariables.win2CenterY

	local win3CenterX = BR.savedVariables.win3CenterX
	local win3CenterY = BR.savedVariables.win3CenterY

	if waveCenterX or waveCenterY then
		BRHelperWave:ClearAnchors()
		BRHelperWave:SetAnchor(CENTER, GuiRoot, TOPLEFT, waveCenterX, waveCenterY)
	end

	if win1CenterX or win1CenterY then
		BRHelperWin1:ClearAnchors()
		BRHelperWin1:SetAnchor(CENTER, GuiRoot, TOPLEFT, win1CenterX, win1CenterY)
	end

	if win2CenterX or win2CenterY then
		BRHelperWin2:ClearAnchors()
		BRHelperWin2:SetAnchor(CENTER, GuiRoot, TOPLEFT, win2CenterX, win2CenterY)
	end

	if win3CenterX or win3CenterY then
		BRHelperWin3:ClearAnchors()
		BRHelperWin3:SetAnchor(CENTER, GuiRoot, TOPLEFT, win3CenterX, win3CenterY)
	end

end

function BR.RestoreColors()

	BRHelperWin1_Label:SetColor(unpack(BR.savedVariables.win1Color))
	BRHelperWin2_Label:SetColor(unpack(BR.savedVariables.win2Color))
	BRHelperWin3_Label:SetColor(unpack(BR.savedVariables.win3Color))

end

function BR.WaveOnMoveStop()

	--[[
	BR.savedVariables.waveLeft = BRHelperWave:GetLeft()
	BR.savedVariables.waveTop = BRHelperWave:GetTop()
	]]

	BR.savedVariables.waveCenterX, BR.savedVariables.waveCenterY = BRHelperWave:GetCenter()

	BRHelperWave:ClearAnchors()
	BRHelperWave:SetAnchor(CENTER, GuiRoot, TOPLEFT, BR.savedVariables.waveCenterX, BR.savedVariables.waveCenterY)

end

function BR.Win1OnMoveStop()

	--[[
	BR.savedVariables.win1Left = BRHelperWin1:GetLeft()
	BR.savedVariables.win1Top = BRHelperWin1:GetTop()
	]]

	BR.savedVariables.win1CenterX, BR.savedVariables.win1CenterY = BRHelperWin1:GetCenter()

	BRHelperWin1:ClearAnchors()
	BRHelperWin1:SetAnchor(CENTER, GuiRoot, TOPLEFT, BR.savedVariables.win1CenterX, BR.savedVariables.win1CenterY)

end

function BR.Win2OnMoveStop()

	--[[
	BR.savedVariables.win1Left = BRHelperWin1:GetLeft()
	BR.savedVariables.win1Top = BRHelperWin1:GetTop()
	]]

	BR.savedVariables.win2CenterX, BR.savedVariables.win2CenterY = BRHelperWin2:GetCenter()

	BRHelperWin2:ClearAnchors()
	BRHelperWin2:SetAnchor(CENTER, GuiRoot, TOPLEFT, BR.savedVariables.win2CenterX, BR.savedVariables.win2CenterY)

end

function BR.Win3OnMoveStop()

	--[[
	BR.savedVariables.win3Left = BRHelperWin3:GetLeft()
	BR.savedVariables.win3Top = BRHelperWin3:GetTop()
	]]

	BR.savedVariables.win3CenterX, BR.savedVariables.win3CenterY = BRHelperWin3:GetCenter()

	BRHelperWin3:ClearAnchors()
	BRHelperWin3:SetAnchor(CENTER, GuiRoot, TOPLEFT, BR.savedVariables.win3CenterX, BR.savedVariables.win3CenterY)

end

EVENT_MANAGER:RegisterForEvent(BR.name, EVENT_ADD_ON_LOADED, BR.OnAddOnLoaded)