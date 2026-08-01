PDT = PDT or {}
PDT.name = "PersonalDpsTracker"

local startTime = 0 --milliseconds
local endTime = 0 --milliseconds
local fightTime = function () return (endTime-startTime)/1000 end --seconds
local bossNames = { }
local bossIsHealing = false
local damage = {
	bossAndTrash = {
		total = 0,
		dmgTypes = {
			directDMG = 0,
			dotDMG = 0,
			martialDMG = 0,
			magicalDMG = 0,
			areaDMG = 0,
			singleDMG = 0,
		},
	},
	boss = {
		total = 0,
		dmgTypes = {
			directDMG = 0,
			dotDMG = 0,
			martialDMG = 0,
			magicalDMG = 0,
			areaDMG = 0,
			singleDMG = 0,
		},
		totalHealth = 0,
		totalMaxHealth = 0,
	},
}

local function damageDealtFromEveryone()
	return damage.boss.totalMaxHealth - damage.boss.totalHealth
end

function PDT.resetDamage()
	--Reset other variables as well.
	startTime = 0
	endTime = 0
	bossNames = {}
	bossIsHealing = false

	damage = {
		bossAndTrash = {
			total = 0,
			dmgTypes = {
				directDMG = 0,
				dotDMG = 0,
				martialDMG = 0,
				magicalDMG = 0,
				areaDMG = 0,
				singleDMG = 0,
			},
		},
		boss = {
			total = 0,
			dmgTypes = {
				directDMG = 0,
				dotDMG = 0,
				martialDMG = 0,
				magicalDMG = 0,
				areaDMG = 0,
				singleDMG = 0,
			},
			totalHealth = 0,
			totalMaxHealth = 0,
		},
	}
end

local function getRawDPS(damage, duration)
	return damage/duration
end

local function formatNumber(number)
	if number < 1000 then
		return math.floor(number)
	elseif PDT.savedVariables.abbreviateNumber then
		return ZO_AbbreviateAndLocalizeNumber(number, PDT.savedVariables.precision, PDT.savedVariables.capitalization)
	else
		return ZO_CommaDelimitNumber(number)
	end
end

function PDT.updateText()

	local formattedString = ""

	if next(bossNames) == nil then --Check if nonlinear table is empty.
		formattedString = PDT.savedVariables.displayText
	else
		formattedString = PDT.savedVariables.displayText_Boss
	end

    if damage.boss.total ~= 0 then
		-- damage to boss
		formattedString = string.gsub(formattedString, "<b>",
			tostring(formatNumber(getRawDPS(damage.boss.total, fightTime()))))
		formattedString = string.gsub(formattedString, "<B>",
            tostring(formatNumber(damage.boss.total)))

		-- share of personal damage to boss relative to total damage dealt
		local asteriskIfHealing = ""
        if bossIsHealing then
            asteriskIfHealing = "%*"
        end

		local totalDamageDealt = damageDealtFromEveryone()
		local sharePercent = 0
		if totalDamageDealt > 0 then
			sharePercent = (damage.boss.total / totalDamageDealt) * 100
		end
		formattedString = string.gsub(formattedString, "<s>",
            tostring(string.format("%.1f", sharePercent)) .. "%%" .. asteriskIfHealing)

		if sharePercent > 110 then
			formattedString = string.gsub(formattedString, "<S>", "N/A" .. asteriskIfHealing)
		else
			formattedString = string.gsub(formattedString, "<S>",
				tostring("1/" .. string.format("%.1f", totalDamageDealt / damage.boss.total)) .. asteriskIfHealing)
		end
	else
		formattedString = string.gsub(formattedString, "<b>", "0")
		formattedString = string.gsub(formattedString, "<B>", "0")
		formattedString = string.gsub(formattedString, "<s>", "0")
		formattedString = string.gsub(formattedString, "<S>", "0")
	end

	if damage.bossAndTrash.total ~= 0 then
		formattedString = string.gsub(formattedString, "<d>", tostring(formatNumber(getRawDPS(damage.bossAndTrash.total, fightTime()))))
	else
		formattedString = string.gsub(formattedString, "<d>", "0")
		formattedString = string.gsub(formattedString, "<D>", "0")
	end
	formattedString = string.gsub(formattedString, "<D>", tostring(formatNumber(damage.bossAndTrash.total)))

	formattedString = string.gsub(formattedString, "<t>", tostring(ZO_FormatTime(fightTime(), TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS)))

	PersonalDpsTrackerLabel:SetText(formattedString)
end

function PDT.updateBannerText()
	if next(bossNames) == nil and damage.bossAndTrash.total ~= 0 then 
		DMGTypeBreakdownDirect:SetText("Direct: "..math.floor((damage.bossAndTrash.dmgTypes.directDMG/damage.bossAndTrash.total)*100).."%")
		DMGTypeBreakdownDOT:SetText("DOT: "..math.floor((damage.bossAndTrash.dmgTypes.dotDMG/damage.bossAndTrash.total)*100).."%")
		DMGTypeBreakdownMartial:SetText("Martial: "..math.floor((damage.bossAndTrash.dmgTypes.martialDMG/damage.bossAndTrash.total)*100).."%")
		DMGTypeBreakdownMagical:SetText("Magic: "..math.floor((damage.bossAndTrash.dmgTypes.magicalDMG/damage.bossAndTrash.total)*100).."%")
		DMGTypeBreakdownArea:SetText("Area: "..math.floor((damage.bossAndTrash.dmgTypes.areaDMG/damage.bossAndTrash.total)*100).."%")
		DMGTypeBreakdownSingle:SetText("ST: "..math.floor((damage.bossAndTrash.dmgTypes.singleDMG/damage.bossAndTrash.total)*100).."%")
	elseif next(bossNames) ~= nil and damage.boss.total ~= 0 then
		DMGTypeBreakdownDirect:SetText("Direct: "..math.floor((damage.boss.dmgTypes.directDMG/damage.boss.total)*100).."%".." ("..math.floor((damage.bossAndTrash.dmgTypes.directDMG/damage.bossAndTrash.total)*100).."%)")
		DMGTypeBreakdownDOT:SetText("DOT: "..math.floor((damage.boss.dmgTypes.dotDMG/damage.boss.total)*100).."%".." ("..math.floor((damage.bossAndTrash.dmgTypes.dotDMG/damage.bossAndTrash.total)*100).."%)")
		DMGTypeBreakdownMartial:SetText("Martial: "..math.floor((damage.boss.dmgTypes.martialDMG/damage.boss.total)*100).."%".." ("..math.floor((damage.bossAndTrash.dmgTypes.martialDMG/damage.bossAndTrash.total)*100).."%)")
		DMGTypeBreakdownMagical:SetText("Magic: "..math.floor((damage.boss.dmgTypes.magicalDMG/damage.boss.total)*100).."%".." ("..math.floor((damage.bossAndTrash.dmgTypes.magicalDMG/damage.bossAndTrash.total)*100).."%)")
		DMGTypeBreakdownArea:SetText("Area: "..math.floor((damage.boss.dmgTypes.areaDMG/damage.boss.total)*100).."%".." ("..math.floor((damage.bossAndTrash.dmgTypes.areaDMG/damage.bossAndTrash.total)*100).."%)")
		DMGTypeBreakdownSingle:SetText("ST: "..math.floor((damage.boss.dmgTypes.singleDMG/damage.boss.total)*100).."%".." ("..math.floor((damage.bossAndTrash.dmgTypes.singleDMG/damage.bossAndTrash.total)*100).."%)")
	else
		DMGTypeBreakdownDirect:SetText("Direct: 0%")
		DMGTypeBreakdownDOT:SetText("DOT: 0%")
		DMGTypeBreakdownMartial:SetText("Martial: 0%")
		DMGTypeBreakdownMagical:SetText("Magic: 0%")
		DMGTypeBreakdownArea:SetText("Area: 0%")
		DMGTypeBreakdownSingle:SetText("ST: 0%")
	end
end

function PDT.onNewBosses(code, forceReset)
	for i = 1, 12 do
		local tempTag = "boss"..i
		local name = zo_strformat(SI_UNIT_NAME, GetUnitName(tempTag))
		if DoesUnitExist(tempTag) and not bossNames[name] then
			bossNames[name] = true
		end
	end
end

local function ChangePlayerCombatState(event, inCombat)

	if inCombat then
		if startTime == 0 then startTime = GetGameTimeMilliseconds() end
		
		--Ensure that all bosses are being appropriately tracked.
		PDT.onNewBosses(_, _)
	else
		zo_callLater(function()
			
			--If the player is out of combat for less than a second, ignore it & don't reset anything.
			if IsUnitInCombat("player") then return end
			
			local totalBossHP, totalMaxBossHP = 0, 0
			for i = 1, 12 do
				local bossTag = "boss"..i
				if DoesUnitExist(bossTag) then
					local bossHP, maxBossHP, _ = GetUnitPower(bossTag, COMBAT_MECHANIC_FLAGS_HEALTH)
					totalBossHP = totalBossHP + bossHP
					totalMaxBossHP = totalMaxBossHP + maxBossHP
				end
			end

			if totalMaxBossHP > 0 then
				local ratio = totalBossHP/totalMaxBossHP
				if ratio <= 0 or ratio >= 1 then
					--Boss is dead or reset (group wipe)
					--Reset variables
					PDT.resetDamage()
				end
				--Else: player is dead but boss isn't
			else
				--Not a boss fight.
				--Reset variables
				PDT.resetDamage()
			end
		end, 1000)
	end
end

local function onRevive(code)
	local totalBossHP, totalMaxBossHP = 0, 0
	for i = 1, 12 do
		local bossTag = "boss"..i
		if DoesUnitExist(bossTag) then
			local bossHP, maxBossHP, _ = GetUnitPower(bossTag, COMBAT_MECHANIC_FLAGS_HEALTH)
			totalBossHP = totalBossHP + bossHP
			totalMaxBossHP = totalMaxBossHP + maxBossHP
		end
	end

	if totalMaxBossHP > 0 then
		local ratio = totalBossHP/totalMaxBossHP
		if ratio <= 0 or ratio >= 1 then
			--Boss is dead or reset (after group wipe or clear)
			--Reset variables
			PDT.resetDamage()
		end
		--Else: player revived during bossfight. Don't reset variables
	else
		--Not a boss fight.
		--Reset variables
		PDT.resetDamage()
	end
end

local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, _log, sourceUnitID, targetUnitID, abilityID, overflow)
	if hitValue > 0 and
		(sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET or sourceType == COMBAT_UNIT_TYPE_PLAYER_COMPANION) and
		(targetType == COMBAT_UNIT_TYPE_NONE or targetType == COMBAT_UNIT_TYPE_TARGET_DUMMY) and
		( result == ACTION_RESULT_DOT_TICK or
		  result == ACTION_RESULT_DOT_TICK_CRITICAL  or
		  result == ACTION_RESULT_CRITICAL_DAMAGE or
		  result == ACTION_RESULT_DAMAGE or
		  result == ACTION_RESULT_BLOCKED_DAMAGE or
		  result == ACTION_RESULT_DAMAGE_SHIELDED or
		  result == ACTION_RESULT_PRECISE_DAMAGE or
		  result == ACTION_RESULT_WRECKING_DAMAGE)
	then
		
		targetName = zo_strformat(SI_UNIT_NAME, targetName)

		if startTime == 0 then startTime = GetGameTimeMilliseconds() end
			
			
		damage.bossAndTrash.total = damage.bossAndTrash.total + hitValue

		--Record damage types for banner
		if result == ACTION_RESULT_DOT_TICK or result == ACTION_RESULT_DOT_TICK_CRITICAL then
			damage.bossAndTrash.dmgTypes.dotDMG = damage.bossAndTrash.dmgTypes.dotDMG + hitValue
		else
			damage.bossAndTrash.dmgTypes.directDMG = damage.bossAndTrash.dmgTypes.directDMG + hitValue
		end
		if damageType == DAMAGE_TYPE_BLEED or
			damageType == DAMAGE_TYPE_DISEASE or
			damageType == DAMAGE_TYPE_PHYSICAL or
			damageType == DAMAGE_TYPE_POISON then
				damage.bossAndTrash.dmgTypes.martialDMG = damage.bossAndTrash.dmgTypes.martialDMG + hitValue
		elseif damageType == DAMAGE_TYPE_MAGIC or
			damageType == DAMAGE_TYPE_SHOCK or
			damageType == DAMAGE_TYPE_FIRE or
			damageType == DAMAGE_TYPE_COLD then
				damage.bossAndTrash.dmgTypes.magicalDMG = damage.bossAndTrash.dmgTypes.magicalDMG + hitValue
		end
		if PDT.areaIDs[abilityID] then
			damage.bossAndTrash.dmgTypes.areaDMG = damage.bossAndTrash.dmgTypes.areaDMG + hitValue
		else
			damage.bossAndTrash.dmgTypes.singleDMG = damage.bossAndTrash.dmgTypes.singleDMG + hitValue
		end

		if bossNames[targetName] then
			damage.boss.total = damage.boss.total + hitValue

			--Record damage types for banner
			if result == ACTION_RESULT_DOT_TICK or result == ACTION_RESULT_DOT_TICK_CRITICAL then
				damage.boss.dmgTypes.dotDMG = damage.boss.dmgTypes.dotDMG + hitValue
			else
				damage.boss.dmgTypes.directDMG = damage.boss.dmgTypes.directDMG + hitValue
			end
			if damageType == DAMAGE_TYPE_BLEED or
				damageType == DAMAGE_TYPE_DISEASE or
				damageType == DAMAGE_TYPE_PHYSICAL or
				damageType == DAMAGE_TYPE_POISON then
					damage.boss.dmgTypes.martialDMG = damage.boss.dmgTypes.martialDMG + hitValue
			elseif damageType == DAMAGE_TYPE_MAGIC or
				damageType == DAMAGE_TYPE_SHOCK or
				damageType == DAMAGE_TYPE_FIRE or
				damageType == DAMAGE_TYPE_COLD then
					damage.boss.dmgTypes.magicalDMG = damage.boss.dmgTypes.magicalDMG + hitValue
			end
			if PDT.areaIDs[abilityID] then
				damage.boss.dmgTypes.areaDMG = damage.boss.dmgTypes.areaDMG + hitValue
			else
				damage.boss.dmgTypes.singleDMG = damage.boss.dmgTypes.singleDMG + hitValue
			end


			local totalBossHP, totalMaxBossHP = 0, 0
			for i = 1, 12 do
				local bossTag = "boss" .. i
				if DoesUnitExist(bossTag) then
					local bossHP, maxBossHP, _ = GetUnitPower(bossTag, COMBAT_MECHANIC_FLAGS_HEALTH)
					totalBossHP = totalBossHP + bossHP
					totalMaxBossHP = totalMaxBossHP + maxBossHP
				end
			end
			local damageDealtBefore = damageDealtFromEveryone()
			damage.boss.totalHealth = totalBossHP
			damage.boss.totalMaxHealth = totalMaxBossHP
			local damageDealtAfter = damageDealtFromEveryone()
			if damageDealtBefore > damageDealtAfter or result == ACTION_RESULT_DAMAGE_SHIELDED then
				bossIsHealing = true
			end
		end
		
		endTime = GetGameTimeMilliseconds()
		
		if PDT.savedVariables.isHidden == false then PDT.updateText() end
		if PDT.savedVariables.banner_hidden == false then PDT.updateBannerText() end
	end
end

local function fragmentChange(oldState, newState)
	if newState == SCENE_FRAGMENT_SHOWN then
		PersonalDpsTracker:SetHidden(PDT.savedVariables.isHidden)
		DMGTypeBreakdown:SetHidden(PDT.savedVariables.banner_hidden)
	elseif newState == SCENE_FRAGMENT_HIDDEN then
		PersonalDpsTracker:SetHidden(true)
		DMGTypeBreakdown:SetHidden(true)
	end
end

function PDT.Initialize()

	PDT.defaults = {
		colorR = 1.0,
		colorG = 1.0,
		colorB = 1.0,
		colorA = 1.0,

		fontSize = 25,
		fontStyle = "GAMEPAD_MEDIUM_FONT",
		fontWeight = "soft-shadow-thick",

		displayText = "[<t>]: <d>, <D>",
		displayText_Boss = "[<t>]: <b>, <B> (<d>, <D>)",

		abbreviateNumber = true,
		precision = 1,
		capitalization = false,

		isHidden = false,
		alignment = TOPLEFT,
		alignmentName = "Left",
		offset_x = 0,
		offset_y = 0,

		banner_hidden = true,
		banner_offset_x = 0,
		banner_offset_y = 0,
	}
	
	--Load and apply saved variables
	PDT.savedVariables = ZO_SavedVars:NewAccountWide("PDTSavedVariables", 1, nil, PDT.defaults, GetWorldName())
	PersonalDpsTracker:SetHidden(PDT.savedVariables.isHidden)
	PersonalDpsTrackerLabel:SetColor(PDT.savedVariables.colorR, PDT.savedVariables.colorG, PDT.savedVariables.colorB)
	PersonalDpsTrackerLabel:SetAlpha(PDT.savedVariables.colorA)
	PersonalDpsTrackerLabel:SetFont(string.format("$(%s)|%s|%s", PDT.savedVariables.fontStyle, PDT.savedVariables.fontSize, PDT.savedVariables.fontWeight))
	PersonalDpsTracker:ClearAnchors()
	PersonalDpsTracker:SetAnchor(PDT.savedVariables.alignment, GuiRoot, TOPLEFT, PDT.savedVariables.offset_x, PDT.savedVariables.offset_y)
	
	DMGTypeBreakdown:SetHidden(PDT.savedVariables.banner_hidden)
	DMGTypeBreakdown:ClearAnchors()
	DMGTypeBreakdown:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PDT.savedVariables.banner_offset_x, PDT.savedVariables.banner_offset_y)
			
	HUD_FRAGMENT:RegisterCallback("StateChange", fragmentChange)
	
	PDT.setupSettings()
	
	PDT.onNewBosses(_, _)
	PDT.updateText()
	
	EVENT_MANAGER:RegisterForEvent(PDT.name, EVENT_PLAYER_COMBAT_STATE, ChangePlayerCombatState)
	EVENT_MANAGER:RegisterForEvent(PDT.name, EVENT_COMBAT_EVENT, OnCombatEvent)
	EVENT_MANAGER:RegisterForEvent(PDT.name, EVENT_BOSSES_CHANGED, PDT.onNewBosses)
	EVENT_MANAGER:RegisterForEvent(PDT.name, EVENT_PLAYER_ALIVE, onRevive)
end

function PDT.OnAddOnLoaded(event, addonName)
	if addonName == PDT.name then
		PDT.Initialize()
		EVENT_MANAGER:UnregisterForEvent(PDT.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(PDT.name, EVENT_ADD_ON_LOADED, PDT.OnAddOnLoaded)