local ov = GlByGrhmForOverview

local win = "character"
ov.ctrl.subHeader[win] = {}
ov.ctrl.control[win] = {}

local ctrl = {}
ctrl.infoName = {}
ctrl.infoValue = {}
ctrl.statsName = {}
ctrl.statsValue = {}
ctrl.powerName = {}
ctrl.powerValue = {}
ctrl.resiName = {}
ctrl.resiValue = {}
ctrl.buffIcon = {}
ctrl.buffName = {}

local buffNum = 16

function ov.createCharacter()

	ov.backdrop("info", win, 515, 85, 0, 30)
	ov.backdrop("cps", win, 515, 25, 0, -3, "info", TOPLEFT, BOTTOMLEFT)
	ov.backdrop("points", win, 515, 25, 0, -3, "cps", TOPLEFT, BOTTOMLEFT)
	ov.backdrop("stats", win, 515, 65, 0, -3, "points", TOPLEFT, BOTTOMLEFT)
	ov.backdrop("power", win, 515, 65, 0, -3, "stats", TOPLEFT, BOTTOMLEFT)
	ov.backdrop("resi", win, 515, 45, 0, -3, "power", TOPLEFT, BOTTOMLEFT)
	ov.backdrop("buff", win, 515, 35, 0, -3, "resi", TOPLEFT, BOTTOMLEFT)
	
	ov.createSubheader("buff" ,win ,TOP, TOP, 0, 3, zo_strformat("<<1>>", GetString(SI_STATS_ACTIVE_EFFECTS)), "buff")
	
	local spacerX = 0
	local spacerY = 0
	
	for i = 1, 8 do 

		ctrl.infoName[i] = ov.ctrl.wm:CreateControl(string.format("OverviewInfoName-%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.infoName[i]:SetAnchor(TOPLEFT, ov.ctrl.control[win]["info"], TOPLEFT, 5 + spacerX, 5 + spacerY)
		ctrl.infoName[i]:SetFont(ov.font.element)
		ctrl.infoName[i]:SetWrapMode(ELLIPSIS)
		ctrl.infoName[i]:SetColor(ov.getColor("gold"))
		
		ctrl.infoValue[i] = ov.ctrl.wm:CreateControl(string.format("OverviewInfoValue-%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.infoValue[i]:SetAnchor(TOPRIGHT, ov.ctrl.control[win]["info"], TOPLEFT, 250 + spacerX, 5 + spacerY)
		ctrl.infoValue[i]:SetFont(ov.font.element)
		ctrl.infoValue[i]:SetWrapMode(ELLIPSIS)
		ctrl.infoValue[i]:SetColor(ov.getColor("white"))
		
		if spacerX == 0 then
			spacerX = spacerX + 260
		else
			spacerX = 0
			spacerY = spacerY + 20
		end
	end
	
	spacerX = 0
	spacerY = 0
	
	for i = 1, 6 do 

		ctrl.statsName[i] = ov.ctrl.wm:CreateControl(string.format("OverviewStatsName-%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.statsName[i]:SetAnchor(TOPLEFT, ov.ctrl.control[win]["stats"], TOPLEFT, 5 + spacerX, 5 + spacerY)
		ctrl.statsName[i]:SetFont(ov.font.element)
		ctrl.statsName[i]:SetWrapMode(ELLIPSIS)
		ctrl.statsName[i]:SetColor(ov.getColor("gold"))
		
		ctrl.statsValue[i] = ov.ctrl.wm:CreateControl(string.format("OverviewStatsValue-%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.statsValue[i]:SetAnchor(TOPRIGHT, ov.ctrl.control[win]["stats"], TOPLEFT, 250 + spacerX, 5 + spacerY)
		ctrl.statsValue[i]:SetFont(ov.font.element)
		ctrl.statsValue[i]:SetWrapMode(ELLIPSIS)
		ctrl.statsValue[i]:SetColor(ov.getColor("white"))
		
		if spacerX == 0 then
			spacerX = spacerX + 260
		else
			spacerX = 0
			spacerY = spacerY + 20
		end
	end
	
	spacerX = 0
	spacerY = 0
	
	ctrl.cps = ov.ctrl.wm:CreateControl(string.format("OverviewCps-%s", win), ov.ctrl.tlw[win], CT_LABEL )
	ctrl.cps:SetAnchor(TOP, ov.ctrl.control[win]["cps"], TOP, 5, 5)
	ctrl.cps:SetFont(ov.font.element)
	ctrl.cps:SetWrapMode(ELLIPSIS)
	ctrl.cps:SetColor(ov.getColor("gold"))
	ctrl.cps:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	ctrl.cps:SetText(GetString(SI_CAMPAIGNLEVELREQUIREMENTTYPE2))
	
	ctrl.pointsName = ov.ctrl.wm:CreateControl(string.format("OverviewPointsName-%s", win), ov.ctrl.tlw[win], CT_LABEL )
	ctrl.pointsName:SetAnchor(TOPLEFT, ov.ctrl.control[win]["points"], TOPLEFT, 5, 5)
	ctrl.pointsName:SetFont(ov.font.element)
	ctrl.pointsName:SetWrapMode(ELLIPSIS)
	ctrl.pointsName:SetColor(ov.getColor("gold"))
	ctrl.pointsName:SetText(string.sub(GetString(SI_STATS_AVAILABLE_POINTS), 0, -2))
	
	ctrl.pointsValue = ov.ctrl.wm:CreateControl(string.format("OverviewPointsValue-%s", win), ov.ctrl.tlw[win], CT_LABEL )
	ctrl.pointsValue:SetAnchor(TOPRIGHT, ov.ctrl.control[win]["points"], TOPLEFT, 510, 5)
	ctrl.pointsValue:SetFont(ov.font.element)
	ctrl.pointsValue:SetWrapMode(ELLIPSIS)
	ctrl.pointsValue:SetColor(ov.getColor("white"))
	
	for i = 1, 6 do 

		ctrl.powerName[i] = ov.ctrl.wm:CreateControl(string.format("OverviewPowerName-%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.powerName[i]:SetAnchor(TOPLEFT, ov.ctrl.control[win]["power"], TOPLEFT, 5 + spacerX, 5 + spacerY)
		ctrl.powerName[i]:SetFont(ov.font.element)
		ctrl.powerName[i]:SetWrapMode(ELLIPSIS)
		ctrl.powerName[i]:SetColor(ov.getColor("gold"))
		
		ctrl.powerValue[i] = ov.ctrl.wm:CreateControl(string.format("OverviewPowerValue-%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.powerValue[i]:SetAnchor(TOPRIGHT, ov.ctrl.control[win]["power"], TOPLEFT, 250 + spacerX, 5 + spacerY)
		ctrl.powerValue[i]:SetFont(ov.font.element)
		ctrl.powerValue[i]:SetWrapMode(ELLIPSIS)
		ctrl.powerValue[i]:SetColor(ov.getColor("white"))
		
		if spacerX == 0 then
			spacerX = spacerX + 260
		else
			spacerX = 0
			spacerY = spacerY + 20
		end
	end
	
	spacerX = 0
	spacerY = 0
	
	for i = 1, 3 do 

		ctrl.resiName[i] = ov.ctrl.wm:CreateControl(string.format("OverviewResiName-%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.resiName[i]:SetAnchor(TOPLEFT, ov.ctrl.control[win]["resi"], TOPLEFT, 5 + spacerX, 5 + spacerY)
		ctrl.resiName[i]:SetFont(ov.font.element)
		ctrl.resiName[i]:SetWrapMode(ELLIPSIS)
		ctrl.resiName[i]:SetColor(ov.getColor("gold"))
		
		ctrl.resiValue[i] = ov.ctrl.wm:CreateControl(string.format("OverviewResiValue-%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.resiValue[i]:SetAnchor(TOPRIGHT, ov.ctrl.control[win]["resi"], TOPLEFT, 250 + spacerX, 5 + spacerY)
		ctrl.resiValue[i]:SetFont(ov.font.element)
		ctrl.resiValue[i]:SetWrapMode(ELLIPSIS)
		ctrl.resiValue[i]:SetColor(ov.getColor("white"))
		
		if spacerX == 0 then
			spacerX = spacerX + 260
		else
			spacerX = 0
			spacerY = spacerY + 20
		end
	end
	
	ctrl.infoName[1]:SetText(GetString(SI_INVENTORY_SORT_TYPE_NAME))
	ctrl.infoName[2]:SetText(GetString(SI_STATS_TITLE))
	ctrl.infoName[3]:SetText(GetString(SI_COLLECTIBLERESTRICTIONTYPE1))
	ctrl.infoName[4]:SetText(GetString(SI_SKILLTYPE1))
	ctrl.infoName[5]:SetText(GetString(SI_EXPERIENCE_LEVEL_LABEL))
	ctrl.infoName[6]:SetText(GetString(SI_SOCIAL_LIST_PANEL_HEADER_ZONE))
	ctrl.infoName[7]:SetText(GetString(SI_COLLECTIBLERESTRICTIONTYPE2))
	ctrl.infoName[8]:SetText(GetString(SI_STATS_ALLIANCE_RANK))
	
	
	ctrl.statsName[1]:SetText(GetString(SI_DERIVEDSTATS4))
	ctrl.statsName[2]:SetText(GetString(SI_DERIVEDSTATS5))
	ctrl.statsName[3]:SetText(GetString(SI_DERIVEDSTATS7))
	ctrl.statsName[4]:SetText(GetString(SI_DERIVEDSTATS9))
	ctrl.statsName[5]:SetText(GetString(SI_DERIVEDSTATS29))
	ctrl.statsName[6]:SetText(GetString(SI_DERIVEDSTATS30))
	
	ctrl.powerName[1]:SetText(GetString(SI_DERIVEDSTATS25))
	ctrl.powerName[2]:SetText(GetString(SI_DERIVEDSTATS35))
	ctrl.powerName[3]:SetText(GetString(SI_DERIVEDSTATS34))
	ctrl.powerName[4]:SetText(GetString(SI_DERIVEDSTATS33))
	ctrl.powerName[5]:SetText(GetString(SI_DERIVEDSTATS23))
	ctrl.powerName[6]:SetText(GetString(SI_DERIVEDSTATS16))
	
	ctrl.resiName[1]:SetText(GetString(SI_DERIVEDSTATS44))
	ctrl.resiName[2]:SetText(GetString(SI_DERIVEDSTATS38))
	ctrl.resiName[3]:SetText(GetString(SI_DERIVEDSTATS24))

	spacerX = 0
	spacerY = 0

	for i = 1, buffNum do 
		ctrl.buffIcon[i] = ov.ctrl.wm:CreateControl(string.format("OverviewBuffIcon%d-%s", i, win), ov.ctrl.tlw[win], CT_TEXTURE)
		ctrl.buffIcon[i]:SetAnchor(TOPLEFT, ov.ctrl.control[win]["buff"], TOPLEFT, 5 + spacerX, 30 + spacerY) 
		ctrl.buffIcon[i]:SetDimensions(24, 24)
		
		ctrl.buffName[i] = ov.ctrl.wm:CreateControl(string.format("OverviewBuffName-%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.buffName[i]:SetAnchor(TOPLEFT, ctrl.buffIcon[i], TOPRIGHT, 5, 0)
		ctrl.buffName[i]:SetDimensions(200, 20)
		ctrl.buffName[i]:SetFont(ov.font.element)
		ctrl.buffName[i]:SetWrapMode(ELLIPSIS)
		ctrl.buffName[i]:SetColor(ov.getColor("white"))
		
		if spacerX == 0 then
			spacerX = spacerX + 260
		else
			spacerX = 0
			spacerY = spacerY + 25
		end	
	end
end

--Sordrak: Created new updateCharacterFill function
function ov.updateCharacterFill(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
	if eventCode == EVENT_EFFECT_CHANGED and unitTag == "player" and IsUnitInCombat("player") == false then
		ov.characterFill()
	end
end

function ov.characterFill()

	ctrl.infoValue[1]:SetText(zo_strformat("<<C:1>>", GetUnitName("player")))
	ctrl.infoValue[2]:SetText(zo_strformat("<<C:1>>", GetUnitTitle("player")))
	ctrl.infoValue[3]:SetText(zo_strformat("<<C:1>>", GetUnitRace("player")))
	ctrl.infoValue[4]:SetText(zo_strformat("<<C:1>>", GetUnitClass("player")))
	ctrl.infoValue[5]:SetText(zo_strformat("<<C:1>>", GetUnitLevel("player")))
	local championText = ""
	if not DoesCurrentCampaignRulesetAllowChampionPoints() then
		championText = zo_strformat(" |cFFFF00<<c:1>>|r", GetString(SI_LFGACTIVITY7))
	end
	ctrl.infoValue[6]:SetText(zo_strformat("<<C:1>>", GetUnitZone("player"), championText))
	ctrl.infoValue[7]:SetText(zo_strformat("<<!aC:1>>", GetString("SI_ALLIANCE", GetUnitAlliance("player"))))
	ctrl.infoValue[8]:SetText(zo_strformat("<<C:1>>", GetUnitAvARank("player")))

	local cpAdd = ""
	if not DoesCurrentCampaignRulesetAllowChampionPoints() and ov.isInPvPArea() then
		cpAdd = zo_strformat(" |cFF0000<<z:1>>|r", GetString(SI_MARKET_SUBSCRIPTION_PAGE_SUBSCRIPTION_STATUS_NOT_ACTIVE)) 
	end
	ctrl.cps:SetText(zo_strformat("<<C:1>> |cFFFFFF<<C:2>>|r <<3>>", GetString(SI_CAMPAIGNLEVELREQUIREMENTTYPE2), GetPlayerChampionPointsEarned(), cpAdd))
	
	--GetAttributeSpentPoints(ATTRIBUTE_MAGICKA)
	
	ctrl.statsValue[1]:SetText(GetPlayerStat(STAT_MAGICKA_MAX, STAT_BONUS_OPTION_APPLY_BONUS))
	ctrl.statsValue[2]:SetText(GetPlayerStat(STAT_MAGICKA_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS))
	ctrl.statsValue[3]:SetText(GetPlayerStat(STAT_HEALTH_MAX, STAT_BONUS_OPTION_APPLY_BONUS))
	ctrl.statsValue[4]:SetText(GetPlayerStat(STAT_HEALTH_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS))
	ctrl.statsValue[5]:SetText(GetPlayerStat(STAT_STAMINA_MAX, STAT_BONUS_OPTION_APPLY_BONUS))
	ctrl.statsValue[6]:SetText(GetPlayerStat(STAT_STAMINA_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS))
	
	ctrl.pointsValue:SetText(string.format("|c88AAFF%s|r %s     |cFF7700%s|r %s     |c88FF99%s|r %s", 
	GetString(SI_ATTRIBUTES2), GetAttributeSpentPoints(ATTRIBUTE_MAGICKA),
	GetString(SI_ATTRIBUTES1), GetAttributeSpentPoints(ATTRIBUTE_HEALTH),
	GetString(SI_ATTRIBUTES3), GetAttributeSpentPoints(ATTRIBUTE_STAMINA)))
	
	ctrl.powerValue[1]:SetText(GetPlayerStat(STAT_SPELL_POWER, STAT_BONUS_OPTION_APPLY_BONUS))
	ctrl.powerValue[2]:SetText(GetPlayerStat(STAT_POWER, STAT_BONUS_OPTION_APPLY_BONUS))
	ctrl.powerValue[3]:SetText(GetPlayerStat(STAT_SPELL_PENETRATION, STAT_BONUS_OPTION_APPLY_BONUS))
	ctrl.powerValue[4]:SetText(GetPlayerStat(STAT_PHYSICAL_PENETRATION, STAT_BONUS_OPTION_APPLY_BONUS))
	ctrl.powerValue[5]:SetText(zo_strformat("<<1>> %", GetCriticalStrikeChance(GetPlayerStat(STAT_SPELL_CRITICAL, STAT_BONUS_OPTION_APPLY_BONUS))))
	ctrl.powerValue[6]:SetText(zo_strformat("<<1>> %", GetCriticalStrikeChance(GetPlayerStat(STAT_CRITICAL_STRIKE, STAT_BONUS_OPTION_APPLY_BONUS))))
	
	ctrl.resiValue[1]:SetText(GetPlayerStat(STAT_SPELL_RESIST, STAT_BONUS_OPTION_APPLY_BONUS))
	ctrl.resiValue[2]:SetText(GetPlayerStat(STAT_PHYSICAL_RESIST, STAT_BONUS_OPTION_APPLY_BONUS))
	ctrl.resiValue[3]:SetText(GetPlayerStat(STAT_CRITICAL_RESISTANCE, STAT_BONUS_OPTION_APPLY_BONUS))
	
	
	local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff = GetUnitBuffInfo("player" , 0)

	for i = 1, buffNum do
		ctrl.buffIcon[i]:SetHidden(true)
		ctrl.buffName[i]:SetText("")
	end
	local row = 2 
	local ci = 1
	local spacerY = 0
	for bi = 1, GetNumBuffs("player") do
		if ci <= buffNum then
			buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff = GetUnitBuffInfo("player" , bi)
			if abilityId ~= 63601 then
				ctrl.buffIcon[ci]:SetHidden(false)
				ctrl.buffIcon[ci]:SetTexture(iconFilename)
				ctrl.buffName[ci]:SetText(zo_strformat("<<C:1>>", buffName))
				ci = ci + 1

				if ci == row then
					spacerY = spacerY + 25
					row = row + 2
				end
				ov.ctrl.control[win]["buff"]:SetHeight(40 + spacerY)
			end
		end	
	end
end