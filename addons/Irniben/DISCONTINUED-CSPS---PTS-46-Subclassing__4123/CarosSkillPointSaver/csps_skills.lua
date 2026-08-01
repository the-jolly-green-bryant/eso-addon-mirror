local skillTable = CSPS.skillTable
local GS = GetString
local sdm = SKILLS_DATA_MANAGER
local ec = CSPS.ec
local skillForHB = false
local tryingToApplySkills = false
local skillLineIdsToExclude = { -- class and racial skill lines can be handled by line index
		[319] = true, -- weapons vengeance lines
		[320] = true,
		[321] = true,
		[322] = true,
		[323] = true,
		[324] = true,
		[71] = true, -- emperor
		[325] = true, -- assault vengeance
		[326] = true, -- support vengeance
	}
CSPS.skillLineIdsToExclude = skillLineIdsToExclude	
	
local skillTypes = {SKILL_TYPE_CLASS, SKILL_TYPE_WEAPON, SKILL_TYPE_ARMOR, SKILL_TYPE_WORLD, SKILL_TYPE_GUILD, SKILL_TYPE_AVA, SKILL_TYPE_RACIAL, SKILL_TYPE_TRADESKILL}

local cpColors = CSPS.cpColors

local mechanicFlagColors = {
	[COMBAT_MECHANIC_FLAGS_HEALTH] = cpColors[3],
	[COMBAT_MECHANIC_FLAGS_MAGICKA] =  cpColors[2],
	[COMBAT_MECHANIC_FLAGS_STAMINA] =  cpColors[1],
	[COMBAT_MECHANIC_FLAGS_ULTIMATE] =  cpColors[4],
	[COMBAT_MECHANIC_FLAGS_WEREWOLF] =  cpColors[5],
}

local function checkCustomStyles()
	local numChanges = 0
	local numLocked = 0
	for skillType, typeData in ipairs(skillTable) do
		for skillLineIndex, lineData in ipairs(typeData) do
			if lineData.zo_data:IsActive() then
				for skillIndex, skillData in ipairs(lineData) do
					if skillData.numSkillStyles and skillData.numSkillStyles > 0 then
						local activeCollectible = GetActiveProgressionSkillAbilityFxOverrideCollectibleId(skillData.progId)
						if activeCollectible ~= skillData.styleCollectible then
							if not skillData.styleCollectible or skillData.styleCollectible == 0 or IsCollectibleUnlocked(skillData.styleCollectible) then
								numChanges = numChanges + 1
							else
								numLocked = numLocked + 1
							end
						end
					end
				end
			end	
		end
	end	
	return numChanges, numLocked
end	

local function canCraftAbility(craftedAbilityId, scripts)
	if not IsCraftedAbilityUnlocked(craftedAbilityId) then return false end
	for _, scriptId in pairs(scripts) do
		if not scriptId or scriptId == 0 or not IsCraftedAbilityScriptUnlocked(scriptId) then return false end
	end
	return true
end

local function everythingScripted(scripts)
	for i=1,3 do
		if not scripts[i] or scripts[i] == 0 then return false end
	end
	return true
end

local function checkCraftedAbilites()
	local neededInk = 0
	local canCraftAll = true
	local notCraftable = 0
	local combinationsToScribe = {}
	for i=1, GetNumCraftedAbilities() do
		local craftedId = GetCraftedAbilityIdAtIndex(i)
		local skillType, skillLineIndex, skillIndex = GetSkillAbilityIndicesFromCraftedAbilityId(craftedId)
		local skEntry = skillTable[skillType][skillLineIndex][skillIndex]
		if #skEntry.scripts == 3 and everythingScripted(skEntry.scripts) then
			if IsScribableScriptCombinationForCraftedAbility(craftedId, unpack(skEntry.scripts)) then
				if canCraftAbility(craftedId, skEntry.scripts) then
					local costToScribe = GetCostToScribeScripts(craftedId, unpack(skEntry.scripts))
					neededInk = neededInk + costToScribe
					if costToScribe > 0 then table.insert(combinationsToScribe, {craftedId = craftedId, scripts=skEntry.scripts}) end
				else
					canCraftAll = false
					notCraftable = notCraftable + 1					
				end
			else
				canCraftAll = false
				notCraftable = notCraftable + 1
			end
		end
	end
	return combinationsToScribe, neededInk, canCraftAll, notCraftable
end

function CSPS.showApplySkillsTT(self)
	local combinationsToScribe, neededInk, canCraftAll, notCraftable =  checkCraftedAbilites()
	local myTooltip = GS(CSPS_Tooltiptext_Sk)

	if combinationsToScribe and #combinationsToScribe > 0 then
		if  GetCraftingInteractionType() == CRAFTING_TYPE_SCRIBING then
			myTooltip = string.format(GS(CSPS_ScribingGo), myTooltip, neededInk, GetItemLinkInventoryCount(GetScribingInkItemLink(), INVENTORY_COUNT_BAG_OPTION_BACKPACK_AND_BANK_AND_CRAFT_BAG))
		else
			myTooltip = string.format(GS(CSPS_ScribingGoToStation), myTooltip, neededInk)
		end
	end
	if notCraftable and notCraftable > 0 then myTooltip = string.format("%s\n%s", myTooltip, zo_strformat(GS(CSPS_CannotBeScribed), notCraftable)) end
	ZO_Tooltips_ShowTextTooltip(self, RIGHT, myTooltip)
end

function CSPS.getAbilityStats(skillData, fillTable)
	if skillData.passive then return false end
	fillTable = fillTable or {}
	local statList = {}
	
	local abilityId = skillData.craftedId and GetCraftedAbilityRepresentativeAbilityId(skillData.craftedId, "player") or GetSpecificSkillAbilityInfo(skillData.type, skillData.line, skillData.index, skillData.morph, skillData.rank)
	


    local function GetNextAbilityMechanicFlagIter(abilityId)
        return function(_, lastFlag)
            return GetNextAbilityMechanicFlag(abilityId, lastFlag)
        end
    end
   
	-- channel/cast time
	local channeled, castTime, channelTime = GetAbilityCastInfo(abilityId)
	
	if channeled then
		channelTime = ZO_SELECTED_TEXT:Colorize(ZO_FormatTimeMilliseconds(channelTime, TIME_FORMAT_STYLE_CHANNEL_TIME, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE))
		table.insert(statList, string.format("%s: %s", GS(SI_ABILITY_TOOLTIP_CHANNEL_TIME_LABEL), channelTime))
		fillTable.channelTime = channelTime
	else
		castTime = ZO_SELECTED_TEXT:Colorize(ZO_FormatTimeMilliseconds(castTime, TIME_FORMAT_STYLE_CAST_TIME, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE))
		table.insert(statList, string.format("%s: %s", GS(SI_ABILITY_TOOLTIP_CAST_TIME_LABEL), castTime))
		fillTable.castTime = castTime
	end
	
	-- target
	local targetDescription = GetAbilityTargetDescription(abilityId)
	if targetDescription then
		targetDescription = ZO_SELECTED_TEXT:Colorize(targetDescription)
		table.insert(statList, string.format("%s: %s", GS(SI_ABILITY_TOOLTIP_TARGET_TYPE_LABEL), targetDescription))
		fillTable.targetDescription = targetDescription
	end

	--Range
	local minRangeCM, maxRangeCM = GetAbilityRange(abilityId)
	if maxRangeCM and maxRangeCM > 0 then
		local rangeValue = minRangeCM == 0 and zo_strformat(SI_ABILITY_TOOLTIP_RANGE, FormatFloatRelevantFraction(maxRangeCM / 100)) or zo_strformat(SI_ABILITY_TOOLTIP_MIN_TO_MAX_RANGE, FormatFloatRelevantFraction(minRangeCM / 100), FormatFloatRelevantFraction(maxRangeCM / 100))
		rangeValue = ZO_SELECTED_TEXT:Colorize(rangeValue)
		table.insert(statList, string.format("%s: %s", GS(SI_ABILITY_TOOLTIP_RANGE_LABEL), rangeValue))
		fillTable.range = rangeValue
	end

	--Radius/Distance
	local radiusCM = GetAbilityRadius(abilityId)
	local angleDistanceCM = GetAbilityAngleDistance(abilityId)
	if radiusCM and radiusCM > 0 then
		if angleDistanceCM and angleDistanceCM > 0 then
			fillTable.radius = ZO_SELECTED_TEXT:Colorize(zo_strformat(SI_ABILITY_TOOLTIP_AOE_DIMENSIONS, FormatFloatRelevantFraction(radiusCM / 100), FormatFloatRelevantFraction(angleDistanceCM * 2 / 100)))
			table.insert(statList, string.format("%s: %s", GS(SI_ABILITY_TOOLTIP_AREA_LABEL), fillTable.radius))
		else
			fillTable.radius = ZO_SELECTED_TEXT:Colorize(zo_strformat(SI_ABILITY_TOOLTIP_RADIUS, FormatFloatRelevantFraction(radiusCM / 100)))
			table.insert(statList, string.format("%s: %s", GS(SI_ABILITY_TOOLTIP_RADIUS_LABEL), fillTable.radius))
		end
	end

	--Duration
	if IsAbilityDurationToggled(abilityId) then
		table.insert(statList, string.format("%s: %s", GS(SI_ABILITY_TOOLTIP_DURATION_LABEL), ZO_SELECTED_TEXT:Colorize(GS(SI_ABILITY_TOOLTIP_TOGGLE_DURATION))))
		fillTable.duration = ZO_SELECTED_TEXT:Colorize(GS(SI_ABILITY_TOOLTIP_TOGGLE_DURATION))
	else
		local durationMS = GetAbilityDuration(abilityId, overrideActiveRank, overrideCasterUnitTag)
		if durationMS and durationMS > 0 then
			fillTable.duration = ZO_SELECTED_TEXT:Colorize(ZO_FormatTimeMilliseconds(durationMS, TIME_FORMAT_STYLE_DURATION, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE))
			table.insert(statList, string.format("%s: %s", GS(SI_ABILITY_TOOLTIP_DURATION_LABEL), fillTable.duration))
		end
	end

	--Cooldown
	local cooldownMS = GetAbilityCooldown(abilityId)
	if cooldownMS and cooldownMS > 0 then
		fillTable.cooldown = ZO_SELECTED_TEXT:Colorize(ZO_FormatTimeMilliseconds(cooldownMS, TIME_FORMAT_STYLE_DURATION, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE))
		table.insert(statList, string.format("%s: %s", GS(SI_ABILITY_TOOLTIP_COOLDOWN), fillTable.cooldown))
	end

	--Cost
	if not skillData.craftedId then
		for mFlag in GetNextAbilityMechanicFlagIter(abilityId) do
			local cost = GetAbilityCost(abilityId, mFlag)
			if cost and cost > 0 then
				local mechanicName = GS("SI_COMBATMECHANICFLAGS", mFlag)
				local costString = zo_strformat(SI_ABILITY_TOOLTIP_RESOURCE_COST, cost, mechanicName)
				if mechanicFlagColors[mFlag] then costString = mechanicFlagColors[mFlag]:Colorize(costString) end
				table.insert(statList, string.format("%s: %s", GS(SI_ABILITY_TOOLTIP_RESOURCE_COST_LABEL), costString))
				fillTable.cost = fillTable.cost or {}
				fillTable.cost[mFlag] = costString
			end
		end

		for mFlag in GetNextAbilityMechanicFlagIter(abilityId) do
			local cost, chargeFrequencyMS = GetAbilityCostOverTime(abilityId, mFlag)
			if cost and cost > 0 then
				local mechanicName = GS("SI_COMBATMECHANICFLAGS", mFlag)

				if mechanicFlagColors[mFlag] then 
					cost = mechanicFlagColors[mFlag]:Colorize(cost) 
					mechanicName = mechanicFlagColors[mFlag]:Colorize(mechanicName) 
				end

				local formattedChargeFrequency = ZO_SELECTED_TEXT:Colorize(ZO_FormatTimeMilliseconds(chargeFrequencyMS, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE))
				local costOverTimeString = zo_strformat(SI_ABILITY_TOOLTIP_RESOURCE_COST_OVER_TIME, cost, mechanicName, formattedChargeFrequency)
				
				table.insert(statList, string.format("%s: %s", GS(SI_ABILITY_TOOLTIP_RESOURCE_COST_LABEL), costOverTimeString))
				fillTable.costOverTime = fillTable.costOverTime or {}
				fillTable.costOverTime[mFlag] = costOverTimeString
			end
		end    
	
	else
		local cost, mFlag, isCostPerTick = GetAbilityBaseCostInfo(abilityId, nil, "player")
		if not mFlag then return statList end -- sometimes returns nil, then a few seconds later it doesn't...
		if isCostPerTick then
		
			local costPerTick = GetAbilityCostPerTick(abilityId, mFlag)
			local frequencyMS = GetAbilityFrequencyMS(abilityId, "player")
			local mechanicName = GS("SI_COMBATMECHANICFLAGS", mFlag)

			if mechanicFlagColors[mFlag] then 
				costPerTick = mechanicFlagColors[mFlag]:Colorize(costPerTick) 
				mechanicName = mechanicFlagColors[mFlag]:Colorize(mechanicName) 
			end

			local formattedChargeFrequency = ZO_SELECTED_TEXT:Colorize(ZO_FormatTimeMilliseconds(frequencyMS, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE))
			local costOverTimeString = zo_strformat(SI_ABILITY_TOOLTIP_RESOURCE_COST_OVER_TIME, costPerTick, mechanicName, formattedChargeFrequency)
			
			table.insert(statList, string.format("%s: %s", GS(SI_ABILITY_TOOLTIP_RESOURCE_COST_LABEL), costOverTimeString))
			fillTable.costOverTime = fillTable.costOverTime or {}
			fillTable.costOverTime[mFlag] = costOverTimeString

		else
			local mechanicName = GS("SI_COMBATMECHANICFLAGS", mFlag)
			local costString = zo_strformat(SI_ABILITY_TOOLTIP_RESOURCE_COST, cost, mechanicName)
			if mechanicFlagColors[mFlag] then costString = mechanicFlagColors[mFlag]:Colorize(costString) end
			table.insert(statList, string.format("%s: %s", GS(SI_ABILITY_TOOLTIP_RESOURCE_COST_LABEL), costString))
			fillTable.cost = fillTable.cost or {}
			fillTable.cost[mFlag] = costString
		end
	end
	
	return statList
end

-- Drag and drop functions for hotbars ---
function CSPS.onSkillDrag(i, j, k)
	skillForHB = {i,j,k,IsSkillAbilityUltimate(i,j,k)}
end

function CSPS.onHbIconDrag(myBar, icon)

	if CSPS.werewolfMode then myBar = 3 end
	
	local thisSkill = CSPS.hbTables[myBar][icon]
	if thisSkill ~= nil then
		local i = thisSkill[1]
		local j = thisSkill[2]
		local k = thisSkill[3]
		skillForHB = {i,j,k,IsSkillAbilityUltimate(i,j,k)}
	end
end


function CSPS.onHbIconReceive(myBar, icon)
	if not skillForHB then return end 
	if icon == 6 and skillForHB[4] == false then return end
	if icon < 6 and skillForHB[4] == true then return end
	
	local i = skillForHB[1]
	local j = skillForHB[2]
	local k = skillForHB[3]
	
	if IsWerewolfSkillLineById(GetSkillLineId(i, j)) then
		-- if not CSPS.werewolfMode then return end -- can slot werewolf skills on any bar
	else
		if CSPS.werewolfMode then return end
	end
	
	if CSPS.werewolfMode then myBar = 3 end
	
	CSPS.hbSkillRemove(myBar, icon)
	local indOld = skillTable[i][j][k].hb[myBar]
	if 	indOld ~= nil then
			CSPS.hbTables[myBar][indOld] = nil
	end
	CSPS.hbTables[myBar][icon] = {i, j, k}
	skillTable[i][j][k].hb[myBar] = icon
	skillForHB = false
	CSPS.hbPopulate()
	CSPS.unsavedChanges = true
	CSPS.showElement("apply", true)
	CSPS.showElement("save", true)
end

function CSPS.hbSkillRemove(myBar, icon)
	if CSPS.werewolfMode then myBar = 3 end
	if CSPS.hbTables[myBar][icon] ~= nil then
		local i = CSPS.hbTables[myBar][icon][1] 
		local j = CSPS.hbTables[myBar][icon][2] 
		local k = CSPS.hbTables[myBar][icon][3]
		skillTable[i][j][k].hb[myBar] = nil
		CSPS.hbTables[myBar][icon] = nil
	end
	CSPS.hbPopulate()
	CSPS.unsavedChanges = true
	CSPS.showElement("apply", true)
	CSPS.showElement("save", true)
end

function CSPS.hbSkillTT(control, myBar, icon)
	if CSPS.werewolfMode then myBar = 3 end
	
	local r,g,b =  ZO_NORMAL_TEXT:UnpackRGB()
	if CSPS.hbTables[myBar][icon] ~= nil then
		local i, j, k = unpack(CSPS.hbTables[myBar][icon])
		local skillData = skillTable[i][j][k]
		CSPS.showSkTT(control, i,j,k, skillData.morph, skillData.rank, skillData.errorCode, skillData, BOTTOM, true)		
		InformationTooltip:AddLine(string.format("|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t: %s", GS(SI_GAMEPAD_SKILLS_ASSIGN)), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		InformationTooltip:AddLine(string.format("|t26:26:esoui/art/miscellaneous/icon_rmb.dds|t: %s", GS(SI_ABILITY_ACTION_CLEAR_SLOT)), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	else 
		ZO_Tooltips_ShowTextTooltip(control, TOP, string.format("|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t: %s", GS(SI_GAMEPAD_SKILLS_ASSIGN)))
	end
end

function CSPS.hbSkillMenu(myBar, icon)
	ClearMenu()
	for skillType, typeData in ipairs(CSPS.skillTable) do
		local typeContent = {}
		for skillLineIndex, lineData in ipairs(typeData) do
			if not skillLineIdsToExclude[lineData.zo_data.id] and not (skillType == 1 and skillLineIndex > 3) then
				local anySkillsInLine = false
				for skillIndex, skillData in ipairs(lineData) do
					if skillData.purchased and not skillData.passive and skillData.hb[myBar] ~= icon then
						local isUlti = IsSkillAbilityUltimate(skillType, skillLineIndex, skillIndex)
						if isUlti and icon == 6 or not isUlti and icon < 6 then
						
							local skIcon = skillData.morph and skillData.morph > 0 and skillData.morphTextures[skillData.morph] or skillData.texture
							local skName = skillData.morph and skillData.morph > 0 and skillData.morphNames[skillData.morph] or skillData.name
							skName = string.format("|t20:20:%s|t %s", skIcon, skName)
							table.insert(typeContent, {label = skName, callback =
								function()
									skillForHB = {skillType, skillLineIndex, skillIndex, isUlti}
									CSPS.onHbIconReceive(myBar, icon)
								end, tooltip = 
								function(control, inside) 
									if not inside then return end 
									--CSPS.showSkTT(control, skillType, skillLineIndex, skillIndex, skillData.morph, skillData.rank, skillData.errorCode, skillData, LEFT, true)	
								end})
							anySkillsInLine = true
							-- local menuItemControl = ZO_Menu.items[#ZO_Menu.items].item 
							-- menuItemControl.onEnter = function() CSPS.showCpTT(menuItemControl, skillData, funcValue and funcValue(skillData) or nil, false, false, 15) end
							-- menuItemControl.onExit = function() ZO_Tooltips_HideTextTooltip() end
						end
					end
				end
				if anySkillsInLine then table.insert(typeContent, {label = "-", callback = function() end}) end
			end
		end
		if #typeContent > 0 then 
			if typeContent[#typeContent].label == "-" then typeContent[#typeContent] = nil end
			AddCustomSubMenuItem(GS("SI_SKILLTYPE", skillType), typeContent) 
		end
	end
	ShowMenu() 
end

local function refreshSkillPointSum()
	skillTable:sumUpSkills()
	CSPSWindowIncludeSkLabel:SetText(string.format("%s (%s/%s)", GetString(SI_CHARACTER_MENU_SKILLS), skillTable.pointsToSpend, GetAvailableSkillPoints()))
end

-- plus and minus functions for skills from the list

function CSPS.changeSkillLine(skillType, orderedIndex)

	ClearMenu()
	
	--GetSkillLineId(*[SkillType|#SkillType]* _skillType_, *luaindex* _skillLineIndex_)
	local activeLines = {}
	local activeClasses = {}
	local myClass = GetUnitClassId("player")
	local numMyClass = 0
	local clickedClassId = 0
	
	for i, v in pairs(CSPS.currentClassSkillLines) do 
		activeLines[v] = true 
		local lineClass = GetSkillLineClassId(1, v)
		if i == orderedIndex then clickedClassId = lineClass end
		if lineClass == myClass then
			numMyClass = numMyClass + 1
		elseif i ~= orderedIndex then 
			activeClasses[lineClass] = true 
		end
	end
	-- if numMyClass == 1 and clickedClassId = myClass then return end
	
	
	local orderedClasses = {GetUnitClassId("player")}
	
	for classIndex = 1, GetNumClasses() do
		local classId = GetClassIdByIndex(classIndex)
		if classId ~= orderedClasses[1] then table.insert(orderedClasses, classId) end
	end
	
	for _, classId in pairs(orderedClasses) do
		local classContent = {}
		
		-- * GetClassInfo(*luaindex* _index_)
		--** _Returns:_ *integer* _classId_, *string* _lore_, *textureName* _normalIconKeyboard_, *textureName* _pressedIconKeyboard_, *textureName* _mouseoverIconKeyboard_, *bool* _isSelectable_, *textureName* _ingameIconKeyboard_, *textureName* _ingameIconGamepad_, *textureName* _normalIconGamepad_, *textureName* _pressedIconGamepad_
		
		local _, _, classIcon = GetClassInfo(GetClassIndexById(classId))
		
		local className = zo_strformat("|t26:26:<<1>>|t <<C:2>>", classIcon, GetClassName(GetUnitGender("player"), classId))
		if not activeClasses[classId] and not (numMyClass == 1 and clickedClassId == myClass and classId ~= myClass) then
		
			for i=1, GetNumSkillLinesForClass(classId) do
				local skillLineId = GetSkillLineIdForClass(classId, i)
				local _, skillLineIndex = GetSkillLineIndicesFromSkillLineId(skillLineId)
				
				if not activeLines[skillLineIndex] then
					local _, lineTexture = GetSkillAbilityInfo(1, skillLineIndex, 1)
					table.insert(classContent, {
						label = zo_strformat("|t24:24:<<1>>|t <<C:2>>", lineTexture, GetSkillLineNameById(skillLineId)), 
						callback =
							function()
								CSPS.removeSkillLine(1, CSPS.currentClassSkillLines[orderedIndex])
								CSPS.currentClassSkillLines[orderedIndex] = skillLineIndex
								table.sort(CSPS.currentClassSkillLines) -- so the order will be the same as in vanilla ui
								CSPS.refreshTree()
							end, 
						tooltip = 
							function(control, inside) 
								if not inside then return end 
							end
						})
				end
			end
			
			if #classContent > 0 then 
				AddCustomSubMenuItem(className, classContent) 
			end
		end
	end
	ShowMenu() 
end

function CSPS.minusClickSkill(theSkill, ctrl, alt, shift)
	local myShiftKey = CSPS.savedVariables.settings.jumpShiftKey or 7
	myShiftKey = myShiftKey == 7 and shift or myShiftKey == 4 and ctrl or myShiftKey == 5 and alt or false
	if not theSkill.passive then		-- progression skill?
		theSkill.morph = theSkill.morph or 0
		if myShiftKey or theSkill.morph == 0 then -- delete if not morphed
			theSkill.purchased = false
			for myBar = 1, 3 do
				if theSkill.hb[myBar] ~= nil then CSPS.hbSkillRemove(myBar, theSkill.hb[myBar]) end
			end
		else
			theSkill.morph = theSkill.morph - 1 -- if morphed change/remove morph
		end
	else		-- Passive
		if not myShiftKey and theSkill.rank > 1 then -- if rank > 1 substract 1
			theSkill.rank = theSkill.rank - 1
		else
			theSkill.purchased = false -- otherwise delete
		end
	end

	theSkill:setPoints()
	theSkill.lineData:sumUpSkills()
	theSkill.typeData:sumUpSkills()
	
	refreshSkillPointSum()
	CSPS.hbPopulate()
	 CSPS.refreshTree()
	CSPS.showElement("apply", true)
	CSPS.showElement("save", true)
	CSPS.unsavedChanges = true
end

function CSPS.minusClickSkillLine(skTyp, skLin, shift)
	local name = GS("SI_SKILLTYPE", skTyp)
	if skLin ~= nil then name = skillTable[skTyp][skLin].name end
	ZO_Dialogs_ShowDialog(CSPS.name.."_OkCancelDiag", 
		{returnFunc = function() CSPS.removeSkillLine(skTyp, skLin) end},  
		{mainTextParams = {zo_strformat(GS(CSPS_MSG_DeleteSkillType), name)}, titleParams = {GS(CSPS_MyWindowTitle)}})
end

function CSPS.removeSkillLine(skTyp, skLin)
	local typeData = skillTable[skTyp]
	for lineIndex, skillLine in ipairs(typeData) do
		if not skLin or skLin == lineIndex then
			for _, skillData in ipairs(skillLine) do
				if skillData.purchased then
					skillData.purchased = false
					skillData:setPoints()
					if not skillData.purchased then
						for myBar = 1, 3 do
							if skillData.hb[myBar] ~= nil then CSPS.hbSkillRemove(myBar, skillData.hb[myBar]) end
						end	
					end
				end
			end
			skillLine:sumUpSkills()
		end
	end
	typeData:sumUpSkills()
	refreshSkillPointSum()
	CSPS.refreshTree()
end

function CSPS.plusClickSkillLine(skillType, skillLineIndex, shift)
	local typeData = skillTable[skillType]
	for lineIndex, skillLine in ipairs(typeData) do
		if not skillLineIndex or skillLineIndex == lineIndex then
			for _, skillData in ipairs(skillLine) do
				if skillData.passive then
					skillData.purchased = true
					skillData.rank = 42 -- will be reduced to max rank in the next function call
					skillData:setPoints()
				end
			end
			skillLine:sumUpSkills()
		end
	end
	typeData:sumUpSkills()
	refreshSkillPointSum()
	CSPS.refreshTree()
end



function CSPS.plusClickSkill(theSkill, ctrl, alt, shift)
	local myShiftKey = CSPS.savedVariables.settings.jumpShiftKey or 7
	myShiftKey = myShiftKey == 7 and shift or myShiftKey == 4 and ctrl or myShiftKey == 5 and alt or false
	
	if theSkill.purchased == false then	-- Skill is not purchased?
			theSkill.purchased = true
			theSkill.rank = theSkill.passive and (myShiftKey and 42 or 1) or nil	-- 42 will later be reduced to the maxRank
			theSkill.morph = not theSkill.passive and 0 or nil
	else
		
		if not theSkill.passive then
			theSkill.morph = theSkill.morph + 1
		else
			theSkill.rank = myShiftKey and 42 or theSkill.rank + 1
		end
	end
	theSkill:setPoints()
	theSkill.lineData:sumUpSkills()
	theSkill.typeData:sumUpSkills()

	refreshSkillPointSum()
	CSPS.refreshTree()
	CSPS.showElement("apply", true)
	CSPS.showElement("save", true)
	CSPS.unsavedChanges = true
end


local function setPointsActive(self)
	-- ec = {correct = 1, wrongMorph = 2, rankHigher = 3, skillLocked = 4, rankLocked = 5, morphLocked = 6, lineNotActive = 7}
	local currentlyPurchased = self.zo_data:GetPointAllocator():IsPurchased()
	local currentMorph = self.zo_data:GetCurrentSkillProgressionKey() 
	local lineUnlocked = self.lineData.zo_data:IsActive() and self.zo_data:MeetsLinePurchaseRequirement()
	local points = self.autoGrant and 0 or 1
	local pointMulti = self.type == 1 and self.line > 3 and 2 or 1
	
	self.morph = self.morph or 0
	self.morph = self.morph > 2 and 2 or self.morph
	self.maxRaMo = self.morph == 2
	points = self.morph > 0 and points + 1 or points
	if not lineUnlocked then
		if self.type == 1 and self.line > 3 then
			if self.zo_data:MeetsLineRankPurchaseRequirement() then
				self.pointsToSpend = points * pointMulti
				self.error = (not self.lineData.zo_data:IsActive()) and ec.lineNotActive or nil
			else
				self.pointsToSpend = 0
				self.error = ec.skillLocked
			end
		else
			self.pointsToSpend = 0
			self.error = not (self.autoGrant and self.morph == 0) and ec.skillLocked
		end
	elseif currentlyPurchased then
		if currentMorph > 0 and currentMorph ~= self.morph then
			self.pointsToSpend = 0
			self.error = ec.wrongMorph
		elseif currentMorph == self.morph then
			self.pointsToSpend = 0
			self.error = ec.correct
		else
			self.pointsToSpend = 1 * pointMulti
		end
	else
		self.pointsToSpend = points * pointMulti
	end
	if lineUnlocked and self.morph > 0 and not self.zo_data:GetProgressionData(self.morph):IsUnlocked() then 
		self.error = ec.morphLocked 
		self.pointsToSpend = lineUnlocked and (points - 1) * pointMulti or 0
	end
	return points * pointMulti
end

local function setPointsPassive(self)
	local maxRank = self.zo_data:GetNumRanks()
	local currentlyPurchased = self.zo_data:GetPointAllocator():IsPurchased()
	local currentRank = self.zo_data:GetCurrentSkillProgressionKey()
	local lineUnlocked = self.lineData.zo_data:IsActive() and self.zo_data:MeetsLinePurchaseRequirement()
	local points = self.autoGrant and 0 or 1
	local pointMulti = self.type == 1 and self.line > 3 and 2 or 1
	
	self.maxRaMo = self.rank >= maxRank
	self.rank = self.rank <= maxRank and self.rank or maxRank
	self.rank = self.rank > 0 and self.rank or 1
	points = points + self.rank - 1
	if not lineUnlocked then
		if self.type == 1 and (self.line > 3 or not self.lineData.zo_data:IsActive()) then
			if self.zo_data:MeetsLineRankPurchaseRequirement() then
				self.pointsToSpend = points * pointMulti
				self.error = (not self.lineData.zo_data:IsActive()) and ec.lineNotActive or nil
			else
				self.pointsToSpend = 0
				self.error = ec.skillLocked
			end
		else
			self.pointsToSpend = 0
			self.error = not (self.autoGrant and self.rank == 1) and ec.skillLocked
		end
	elseif currentlyPurchased then
		if currentRank > self.rank then
			self.pointsToSpend = 0
			self.error = ec.rankHigher
		elseif currentRank == self.rank then
			self.pointsToSpend = 0
			self.error = ec.correct
		else
			self.pointsToSpend = (self.rank - currentRank) * pointMulti
		end
	else
		self.pointsToSpend = points * pointMulti
	end
	if lineUnlocked and not self.zo_data:GetProgressionData(self.rank):IsUnlocked() and not (self.autoGrant and self.rank == 1) then 
		local possibleRank = 0 -- will only be used for skill points to invest
		for i=1, self.rank do
			if self.zo_data:GetProgressionData(i):IsUnlocked() then
				possibleRank = i
			else
				break
			end
		end
		self.pointsToSpend = possibleRank > currentRank and (possibleRank - currentRank) * pointMulti or 0
		self.error = ec.rankLocked 
	end
	return points * pointMulti
end

local function setPoints(self)
	self.error = nil
	if not self.purchased then 
		self.points = 0 
		self.pointsToSpend = 0
		self.maxRaMo = false
		self.rank = 1
		self.morph = not self.passive and 0 or nil
		if self.autoGrant then self.purchased = true else return end  
	end
	
	self.points = not self.craftedId and (self.passive and setPointsPassive(self) or setPointsActive(self)) or 0
end

local function sumUpSkills(self)
	local points = 0
	local pointsToSpend = 0
	local errorSums = {0,0,0,0,0,0,0,0}
	for i, v in ipairs(self) do
		points = v.points and points + v.points or points
		pointsToSpend = v.pointsToSpend and pointsToSpend + v.pointsToSpend or pointsToSpend
		if v.error then 
			errorSums[v.error] = errorSums[v.error] or 0
			errorSums[v.error] = errorSums[v.error] + 1
		elseif v.errorSums then 
			for j, w in pairs(v.errorSums) do
				errorSums[j] = errorSums[j] or 0
				errorSums[j] = errorSums[j] + v.errorSums[j]
			end
		end
	end
	self.points = points
	self.pointsToSpend = pointsToSpend
	self.errorSums = errorSums
end

function CSPS.createSkillTable()
	skillTable.sumUpSkills = sumUpSkills
	local skillLineIdsToExclude = {}
	for skillType=1, #skillTypes do
		skillTable[skillType] = {sumUpSkills = sumUpSkills}
		local skillTypeData = skillTable[skillType]
		for skillLineIndex = 1, GetNumSkillLines(skillType) do
			-- stop after your own race skilllines and exclude class vengeance skill lines
			-- other vengeance skill lines and emperor will be excluded in the tree itself but will be stored anyway
			
			if skillType==1 and skillLineIndex==GetNumClasses()*3+1  --class vengeance
				or skillType==7 and skillLineIndex==2 -- racial 
				then break end
			
			local zoSkillLineData = sdm:GetSkillLineDataByIndices(skillType, skillLineIndex)
			skillTypeData[skillLineIndex] = {name = zoSkillLineData:GetFormattedName(), type = skillType, sumUpSkills = sumUpSkills, zo_data = zoSkillLineData, points = 0, line = skillLineIndex, id = zoSkillLineData:GetId()}
			
			local skillLineData = skillTypeData[skillLineIndex]
			
			if IsWerewolfSkillLineById(GetSkillLineId(skillType, skillLineIndex)) then 
				skillLineData["isWerewolf"] = true 
				skillTypeData["isWerewolfParent"] = true
			end
						
			for skillIndex = 1, GetNumSkillAbilities(skillType, skillLineIndex) do
				local zoSkillData = zoSkillLineData:GetSkillDataByIndex(skillIndex)
				
				skillLineData[skillIndex] = {
					type = skillType,
					line = skillLineIndex,
					index = skillIndex,
					typeData = skillTypeData,
					lineData = skillLineData,
					autoGrant = zoSkillData:IsAutoGrant(),
					setPoints = setPoints,
					zo_data = zoSkillData,
					passive = zoSkillData:IsPassive(),
					craftedId = zoSkillData.craftedAbilityId,
					progId = zoSkillData.progressionId,
					numSkillStyles = zoSkillData.skillProgressions and zoSkillData.skillProgressions[0] and zoSkillData.skillProgressions[0].numSkillStyles,
				}
				
		
				local skEntry = skillLineData[skillIndex]				
				
				local baseData = not zoSkillData.craftedAbilityId and (skEntry.passive and zoSkillData:GetRankData(1) or zoSkillData:GetMorphData(MORPH_SLOT_BASE))
				
				if zoSkillData.craftedAbilityId then 
					skEntry.name = zo_strformat("<<C:1>>", GetCraftedAbilityDisplayName(zoSkillData.craftedAbilityId))
					skEntry.texture = GetCraftedAbilityIcon(zoSkillData.craftedAbilityId)
					skEntry.scripts = {}
				else
					skEntry.name = baseData:GetFormattedName()
					skEntry.texture = baseData:GetIcon()		
					
					if not skEntry.passive then
						skEntry.morphNames = {zoSkillData:GetMorphData(MORPH_SLOT_MORPH_1):GetFormattedName(), zoSkillData:GetMorphData(MORPH_SLOT_MORPH_2):GetFormattedName()}
						skEntry.morphTextures = {zoSkillData:GetMorphData(MORPH_SLOT_MORPH_1):GetIcon(), zoSkillData:GetMorphData(MORPH_SLOT_MORPH_2):GetIcon()}
					end
				end
				
				skEntry.morph = not skEntry.passive and 0 or nil
				skEntry.points = 0
				skEntry.auxListIndex = 0
				skEntry.maxRaMo = false
				skEntry.rank = 1
				skEntry.hb = {}
				skEntry.purchased = false
			end
			skillLineData:sumUpSkills()
		end
		skillTypeData:sumUpSkills()
	end
	refreshSkillPointSum()
end

function CSPS.resetSkills()
	for skillType, skillTypeData in ipairs(skillTable) do
		for skillLineIndex, skillLineData in ipairs(skillTypeData) do
			for skillIndex, skEntry in ipairs(skillLineData) do
				skEntry.purchased = skEntry.autoGrant
				if skEntry.craftedId then 
					skEntry.scripts = {}
					skEntry.purchased = true
					skEntry.name = zo_strformat("<<C:1>>", GetAbilityName(GetCraftedAbilityRepresentativeAbilityId(skEntry.craftedId), ""))
				end
				skEntry.rank = 1
				skEntry.morph = (skEntry.craftedId or not skEntry.passive) and 0 or nil
				skEntry.styleCollectible = nil
				skEntry:setPoints()
			end	
			skillLineData:sumUpSkills()
		end
		skillTypeData:sumUpSkills()
	end			
	refreshSkillPointSum()
end

function CSPS.getActiveClassSkillLines()
	local activeClassSkillLines = {}
	local isClassSkillLineActive = {}
		
	for skillType, skillTypeData in ipairs(skillTable) do
		for skillLineIndex, skillLineData in ipairs(skillTypeData) do
			if skillType == 1 and skillLineData.zo_data:IsActive() then 
				table.insert(activeClassSkillLines, skillLineIndex) 
				isClassSkillLineActive[skillLineIndex] = true
			end
		end
	end
	return activeClassSkillLines, isClassSkillLineActive
end

function CSPS.readCurrentSkills()
	CSPS.currentClassSkillLines = {}
		
	for skillType, skillTypeData in ipairs(skillTable) do
		for skillLineIndex, skillLineData in ipairs(skillTypeData) do
			if skillType == 1 and skillLineData.zo_data:IsActive() then table.insert(CSPS.currentClassSkillLines, skillLineIndex) end
			for skillIndex, skEntry in ipairs(skillLineData) do
				skEntry.purchased = skEntry.zo_data:GetPointAllocator():IsPurchased()
				if skEntry.craftedId then 
					skEntry.purchased = true 
					skEntry.scripts = {GetCraftedAbilityActiveScriptIds(skEntry.craftedId)}	
					skEntry.name = zo_strformat("<<C:1>>", GetAbilityName(GetCraftedAbilityRepresentativeAbilityId(skEntry.craftedId), "player"))
					
				end
				if skEntry.numSkillStyles then
					skEntry.styleCollectible = GetActiveProgressionSkillAbilityFxOverrideCollectibleId(skEntry.progId)
				end
				skEntry.morph = skEntry.craftedId and 0 or skEntry.purchased and not skEntry.passive and skEntry.zo_data:GetCurrentSkillProgressionKey() or nil
				skEntry.rank = skEntry.craftedId and 1 or skEntry.purchased and skEntry.passive and skEntry.zo_data:GetCurrentSkillProgressionKey() or 1
					
				skEntry:setPoints()	
			end	
			skillLineData:sumUpSkills()
		end
		skillTypeData:sumUpSkills()
	end			
	refreshSkillPointSum()
end

function CSPS.hbLinkToSkills(hbTables)
	for hbIndex, singleHotbarTable in pairs(hbTables) do
		for slotIndex, skillParams in pairs(singleHotbarTable) do
			local skillType, skillLine, skillIndex = unpack(skillParams)
			if #skillParams > 0 and (skillType ~= 1 or skillLine < 4) then
				local skillEntry = skillTable[skillType][skillLine][skillIndex]
				skillEntry.hb = skillEntry.hb or {}
				skillEntry.hb[hbIndex] = slotIndex
			end
		end
	end
end

function CSPS.refreshSkillSumsAndErrors()
	for skillType, typeData in ipairs(skillTable) do
		for skillLineIndex, lineData in ipairs(typeData) do
			for skillIndex, skillData in ipairs(lineData) do
				skillData:setPoints()
			end
			lineData:sumUpSkills()
		end
		typeData:sumUpSkills()
	end
	refreshSkillPointSum()
end

local function applySkillLines()

	local SLAM = SKILL_LINE_ASSIGNMENT_MANAGER -- haha, SLAM! if only it worked as well as it sounds :-)
	SLAM:Reset()
	
	local activeClassSkillLines, isClassSkillLineActive = CSPS.getActiveClassSkillLines()
	local skillLinesInBuild, skillLinesToActivate, skillLinesToDeactivate = {}, {}, {}
			
	for _, skillLine in pairs(CSPS.currentClassSkillLines) do
		skillLinesInBuild[skillLine] = true
		if not isClassSkillLineActive[skillLine] then table.insert(skillLinesToActivate, skillLine) end
	end
	
	if #skillLinesToActivate == 0 then return true, false, {} end

	if not SKILLS_AND_ACTION_BAR_MANAGER:DoesSkillPointAllocationModeAllowSkillLineRespec() then 
		CSPS.post(GS(SI_RESPECRESULT66))
		return false, false, {} 
	end
	
	for _, skillLine in pairs(activeClassSkillLines) do
		if not skillLinesInBuild[skillLine] then 
			table.insert(skillLinesToDeactivate, skillLine)
		end
	end
	
	table.sort(skillLinesToActivate)
	table.sort(skillLinesToDeactivate)
	
	local slA, slD, slT = {}, {}, {}
	local futureLines = {}
	-- PrepareSkillPointAllocationRequest(SKILLS_AND_ACTION_BAR_MANAGER.skillPointAllocationMode, SKILLS_AND_ACTION_BAR_MANAGER.skillRespecPaymentType)
	
	for i=1,3 do
		if skillLinesToDeactivate[i] then 
			local lineData = skillTable[1][skillLinesToDeactivate[i]].zo_data
			
			if false and lineData:IsInTraining() then
				--d("Untrain:"..lineData.name)
				table.insert(slD, lineData:GetId())
				--d(SLAM:UntrainSkillLine(lineData))
			else
				table.insert(slD, lineData:GetId())
				--d(SLAM:DeactivateSkillLine(lineData))
			end
		end
		if skillLinesToActivate[i] then
			local lineData = skillTable[1][skillLinesToActivate[i]].zo_data
			if lineData:GetCurrentRank() ~= 50 and skillLinesToActivate[i] > 3 then
				--AddTrainingToAllocationRequest(lineData.GetId())
				table.insert(slT, lineData:GetId())
				futureLines[skillLinesToActivate[i]] = true
				--d(SLAM:TrainSkillLine(lineData))
			else
				table.insert(slA, lineData:GetId())
				futureLines[skillLinesToActivate[i]] = true
				--d(SLAM:ActivateSkillLine(lineData))
			end
		end
	end
	--DeactivateSkillLinesInAllocationRequest(unpack(slD))
	--ActivateSkillLinesInAllocationRequest(unpack(slA))
	
	if SKILLS_DATA_MANAGER:GetNumSkillLinesInTraining() + #slT > MAX_SKILL_LINES_IN_TRAINING then
		CSPS.post(GS(SI_SKILLS_SUBCLASSING_TRAINING_TOOLTIP_FORMATTER_INFO))
		return false, false, {}
	end
	
	SLAM.pendingTrainingLines = slT
	SLAM.pendingDeactivationLines = slD
	SLAM.pendingActivationLines = slA

	return true, true, futureLines
	-- SendSkillPointAllocationRequest()
end

local function applySkillsGo(callAfterSkillChange, ignoreStyles, ignoreLines)
	local doSend = false
	local lineChangeSuccess = true
	local futureLines = {}
	if GetAPIVersion() >= 101046 and not ignoreLines then 
		lineChangeSuccess, doSend, futureLines = applySkillLines() 
		if not lineChangeSuccess then return end
	end
	
	if SKILLS_AND_ACTION_BAR_MANAGER:GetSkillPointAllocationMode() == SKILL_POINT_ALLOCATION_MODE_FULL then
		SKILL_POINT_ALLOCATION_MANAGER:ClearPointsOnAllSkillLines()
		if doSend then 
			SKILLS_AND_ACTION_BAR_MANAGER:ApplyChanges() 
			zo_callLater(function() applySkillsGo(callAfterSkillChange, ignoreStyles, true) end, 500)
			return
		end
	end
	
	local collectiblesToUse = {}
	for skillType, typeData in ipairs(skillTable) do
		for skillLineIndex, lineData in ipairs(typeData) do
			if lineData.zo_data:IsActive() or skillType == 1 and futureLines[lineIndex] then
				for skillIndex, skillData in ipairs(lineData) do
					if skillData.purchased then
						skillData.zo_data:GetPointAllocator():Purchase()
						if skillData.passive then
							skillData.rank = skillData.rank or 0
							local j = skillData.zo_data:GetCurrentSkillProgressionKey() or 1
							while j < skillData.rank do
								skillData.zo_data:GetPointAllocator():IncreaseRank()
								j = j + 1
							end
						else
							skillData.zo_data:GetPointAllocator():Morph(skillData.morph)
						end
					end
					if skillData.numSkillStyles and skillData.numSkillStyles > 0 and not ignoreStyles then
						local activeCollectible = GetActiveProgressionSkillAbilityFxOverrideCollectibleId(skillData.progId)
						if activeCollectible ~= skillData.styleCollectible then
							if skillData.styleCollectible and skillData.styleCollectible ~= 0 then
								table.insert(collectiblesToUse, skillData.styleCollectible)
							elseif activeCollectible and activeCollectible ~= 0 then
								table.insert(collectiblesToUse, activeCollectible)
							end
						end
					end
				end
			end	
		end
	end	
		
	for _, collectibleId in pairs(collectiblesToUse) do
		UseCollectible(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
	end
		
	tryingToApplySkills = true
	zo_callLater(function() tryingToApplySkills = false CSPS.refreshSkillSumsAndErrors()  CSPS.refreshTree() if callAfterSkillChange then callAfterSkillChange() end end, 500)	
end


local function applyCraftedAbilities(applySkillsAfterScribing, callAfterSkillChange, ignoreStyles)
	local combinationsToScribe, neededInk = checkCraftedAbilites()
	local function finishedScribing()
		if applySkillsAfterScribing then applySkillsGo(callAfterSkillChange, ignoreStyles) end
	end
	if #combinationsToScribe == 0 then CSPS.post(GS(CSPS_NothingToScribe)) finishedScribing() return false end
	if not IsScribingEnabled()  then CSPS.post(GS(SI_COLLECTIBLEUNLOCKSTATE0)) finishedScribing() return false end
	if neededInk > GetItemLinkInventoryCount(GetScribingInkItemLink(), INVENTORY_COUNT_BAG_OPTION_BACKPACK_AND_BANK_AND_CRAFT_BAG) then
		CSPS.post(GS(SI_TRADESKILLRESULT14))
		finishedScribing()
		return false
	end
	
	local lastScribed = false
	local function scribeNext()
		local nextCombi = combinationsToScribe[1]
		lastScribed = nextCombi.craftedId
		CSPS.post(zo_strformat(GS(CSPS_ScribeGo), GetAbilityName(GetCraftedAbilityRepresentativeAbilityId(lastScribed), "")))
		RequestScribe(nextCombi.craftedId, unpack(nextCombi.scripts))
		table.remove(combinationsToScribe, 1)
	end
	EVENT_MANAGER:RegisterForEvent(CSPS.name.."_AbilityCraftingSuccess", EVENT_CRAFT_COMPLETED,
		function(_, craft) 
			if craft ~= CRAFTING_TYPE_SCRIBING then return end 
			if #combinationsToScribe == 0 then
				EVENT_MANAGER:UnregisterForEvent(CSPS.name.."_AbilityCraftingSuccess", EVENT_CRAFT_COMPLETED)
				EVENT_MANAGER:UnregisterForEvent(CSPS.name.."_AbilityCraftingFailed", EVENT_CRAFT_FAILED)
				finishedScribing()
				return
			end
			scribeNext() 
		end)
	EVENT_MANAGER:RegisterForEvent(CSPS.name.."_AbilityCraftingFailed", EVENT_CRAFT_FAILED, function(_, tradeSkillResult) 
		CSPS.post(GS("SI_TRADESKILLRESULT", tradeSkillResult))
		EVENT_MANAGER:UnregisterForEvent(CSPS.name.."_AbilityCraftingSuccess", EVENT_CRAFT_COMPLETED)
		EVENT_MANAGER:UnregisterForEvent(CSPS.name.."_AbilityCraftingFailed", EVENT_CRAFT_FAILED)
	end)
	scribeNext()
end

function CSPS.applySkills(skipDiag, callAfterSkillChange, ignoreStyles)
	if not CSPS.tabEx then return end
	refreshSkillPointSum()
	local sumConflicts = 0
	for i, v in pairs(skillTable.errorSums) do
		if i ~= ec.correct then sumConflicts = sumConflicts + v end
	end
	local myParameters =	{
		GetAvailableSkillPoints(), 
		skillTable.pointsToSpend, 
		sumConflicts, 
		skillTable.errorSums[ec.skillLocked], 
		skillTable.errorSums[ec.wrongMorph],
		skillTable.errorSums[ec.rankHigher],
		skillTable.errorSums[ec.rankLocked] + skillTable.errorSums[ec.morphLocked],
	}
	local doScribe = false
	local diagText = string.format(GS(CSPS_MSG_ConfirmApply), unpack(myParameters))
	
	local numChanges, numLocked = checkCustomStyles()
	if numChanges > 0 or numLocked > 0 then
		diagText = string.format(GS(CSPS_CustomStyles), numChanges, numLocked, diagText)
	end
	
	if GetCraftingInteractionType() == CRAFTING_TYPE_SCRIBING then 
		local combinationsToScribe, neededInk, _, notCraftable = checkCraftedAbilites()
		if combinationsToScribe and #combinationsToScribe > 0 then
			doScribe = true
			if neededInk > GetItemLinkInventoryCount(GetScribingInkItemLink(), INVENTORY_COUNT_BAG_OPTION_BACKPACK_AND_BANK_AND_CRAFT_BAG) then
				diagText = string.format("%s\n\n%s", GS(CSPS_ScribeNotEnough), diagText)
			else
				diagText = string.format("%s\n\n%s", string.format(GS(CSPS_ScribingDiag), #combinationsToScribe, neededInk), diagText)
			end
		end
		if notCraftable and notCraftable > 0 then 
			diagText = string.format("%s\n\n%s", CSPS.colors.red:Colorize(zo_strformat(GS(CSPS_CannotBeScribed), notCraftable)), diagText)
		end
		
	end
		
	if not skipDiag or sumConflicts > 0 then
		ZO_Dialogs_ShowDialog(CSPS.name.."_OkCancelDiag", 
				{
					returnFunc = function() 
						if doScribe then
							applyCraftedAbilities(applySkillsAfterScribing, callAfterSkillChange)
						else
							applySkillsGo(callAfterSkillChange, ignoreStyles) 
						end
						end,
				},
				{
					mainTextParams = {diagText}, 
					titleParams = {GS(CSPS_MyWindowTitle)}
				}
			)
	else
		if doScribe then
			applyCraftedAbilities(applySkillsAfterScribing, callAfterSkillChange)
		else
			applySkillsGo(callAfterSkillChange, ignoreStyles) 
		end
	end
end


function CSPS.hbEmpty(barIndex)
	CSPS.hbTables[barIndex] = CSPS.hbTables[barIndex] or {}
	for j=1, 6 do
		if CSPS.hbTables[barIndex][j] ~= nil then
			
			local skTyp, skLin, skId = unpack(CSPS.hbTables[barIndex][j])
			if not skTyp == 0 and skLin == 0 and skId == 0 then
				skillTable[skTyp][skLin][skId].hb[barIndex] = nil
			end
		end
	end
    CSPS.hbTables[barIndex] = {}
end


function CSPS.hbRead()
	local hotBarCats = {HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP, HOTBAR_CATEGORY_WEREWOLF}
	
    for barIndex, barCategory in pairs(hotBarCats) do
		CSPS.hbEmpty(barIndex)
		
		local hbManager = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(barCategory)
        for i = 1, 6 do
			local slotData = hbManager:GetSlotData(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + i)
            local skillData = slotData and slotData:GetPlayerSkillData()
			if skillData then 
				local skTyp, skLin, skId = skillData:GetIndices()
				CSPS.hbTables[barIndex][i] = {skTyp, skLin, skId} 
				skillTable[skTyp][skLin][skId].hb[barIndex] =  i
			end
		end
			
    end
end

function CSPS.hbApply()
	for i,v in pairs(CSPS.hbTables) do
		local hbCat = i < 3 and i-1 or HOTBAR_CATEGORY_WEREWOLF
		local hbManager = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(hbCat)
		for j, w in pairs(v) do
			local theSkillData = sdm:GetSkillDataByIndices(w[1], w[2],w[3])
			if theSkillData:IsPurchased() and (not theSkillData.craftedAbilityId or IsCraftedAbilityScribed(theSkillData.craftedAbilityId)) then hbManager:AssignSkillToSlot(j+2, theSkillData) end
		end
	end
end

function CSPS.hbPopulate()
	local function populateSingleBar(indBar, indCtr)
		local ctrBar = CSPSWindowFooter:GetNamedChild(string.format("Bar%s", indCtr))
		for ind2=1,6 do
			local ctrSkill = ctrBar:GetNamedChild(string.format("Icon%s", ind2))
			local ijk = CSPS.hbTables[indBar][ind2]
			if ijk ~= nil then
				local i, j, k = unpack(ijk)
				local skillEntry = skillTable[i][j][k]
				ctrSkill:SetTexture(skillEntry.morph == 0 and skillEntry.texture or skillEntry.morphTextures[skillEntry.morph])
				ctrSkill:SetColor(1,1,1)
			else 
				ctrSkill:SetTexture(nil)
				ctrSkill:SetColor(0.141,0.141,0.141)
			end
		end
	end
	if CSPS.werewolfMode then
		CSPSWindowFooterBar2:SetHidden(true)
		populateSingleBar(3, 1)
	else
		CSPSWindowFooterBar2:SetHidden(false)
		for ind1= 1, 2 do
			populateSingleBar(ind1, ind1)
		end
	end

end

EVENT_MANAGER:RegisterForEvent(CSPS.name.."SkillsUpdate", EVENT_SKILL_POINTS_CHANGED, 
	function(_, _, _, _, _, reason) 
		if #skillTable > 0 and not tryingToApplySkills then 
			local reasons = {[SKILL_POINT_CHANGE_REASON_PURCHASE] = true, [SKILL_POINT_CHANGE_REASON_SKILL_RESET] = true, [SKILL_POINT_CHANGE_REASON_SKILL_RESPEC] = true}
			--d("Reason: "..reason)
			if reasons[reason] then
				CSPS.refreshSkillSumsAndErrors() 
				CSPS.setMundus() -- refresh mundus box in case of armory reset
				if not CSPSWindow:IsHidden() then 
					CSPS.refreshTree() 
				end
			else
				refreshSkillPointSum()
			end
		end 
	end)