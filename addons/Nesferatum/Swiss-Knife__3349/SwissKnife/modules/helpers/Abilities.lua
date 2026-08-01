local SK = SwissKnife
local SKH = SK.HelperFunctions
local SKDA = SK.Data.abilities
local SKDC = SK.Data.common
local SM, SDM = SCENE_MANAGER, SKILLS_DATA_MANAGER

local ABILITY_NAME_DELIM = ". "

local function checkAbilityActive(id, data, correctionInterval)
	local active = false
	if SK.CurrentTimedAbility[id] == nil then
		zo_callLater(function()
			SK.CurrentTimedAbility[id] = {
				timeEnding = GetGameTimeSeconds() + data.time
			}
		end, correctionInterval)
	elseif SK.CurrentTimedAbility[id].timeEnding > GetGameTimeSeconds() then
		active = true
	else
		SK.CurrentTimedAbility[id] = nil
	end
	return active
end

local function checkExecution(hp, invert)
	if SK.savedVars.debugMode then
		if SKCI.currentTargetHP ~= nil then
			d("currentTargetHP "..SKCI.currentTargetHP)
		end
		d("hp execution limit "..hp)
	end
	if hp == 100 then return true end
	local active = false
	if SKCI ~= nil and SKCI.currentTargetHP ~= nil then
		active = (invert == nil and SKCI.currentTargetHP <= hp) or (invert ~= nil and SKCI.currentTargetHP >= hp)
	elseif invert ~= nil then
		active = true
	end
	if SK.savedVars.debugMode then
		if active and not invert then
			d("execution enabled")
		else
			d("execution disabled")
		end
	end
	return active
end

local function checkBuffAndStack(data, correctionInterval)
	local active, stacks = false, 0
	local delta = correctionInterval / 1000
	local buff = data.buff
	local ftBuff = data.ftBuff
	local allBuffs = data.allBuffs
	local buffCount = 0
	local castByPlayer = data.castByPlayer
	local isCascade = data.isCascade
	local isFT = data.isFT
	local hp = data.hp
	if hp ~= nil then return not checkExecution(hp, true) end
	if isCascade == nil then isCascade = SK.FALSE end
	if isCascade == SK.TRUE and isFT == SK.TRUE then delta = 0 end
	if ftBuff ~= nil and isFT == SK.TRUE and isCascade ~= SK.TRUE then buff = ftBuff end
	for idx = 1, GetNumBuffs("player") do
		local _, timeStarted, timeEnding, _, stackCount, _, _, _, _, _, abilityId, _, isCastByPlayer = GetUnitBuffInfo("player", idx)
		if allBuffs == nil then
			if buff == abilityId and (castByPlayer ~= SK.TRUE or (castByPlayer == SK.TRUE and isCastByPlayer)) then
				stacks = stackCount
				if timeEnding - delta > GetGameTimeSeconds() or timeStarted == timeEnding then
					active = true
				else
					break
				end
			end
		elseif SKH.isValueInList(allBuffs, abilityId) and (castByPlayer ~= SK.TRUE or (castByPlayer == SK.TRUE and
					isCastByPlayer))
			then
				if timeStarted == timeEnding or timeEnding - delta > GetGameTimeSeconds()  then
					buffCount = buffCount + 1
					if (isCascade ~= SK.TRUE and buffCount == #allBuffs) or (isCascade == SK.TRUE and isFT ~= SK.FALSE)
					then
						active = true
						break
					end
				end
			end
	end
	return active, stacks
end

local function checkDebuff(data, correctionInterval)
	local active = false
	local delta = correctionInterval / 1000
	local debuffCount = 0
	local ftDebuff = data.ftDebuff
	local allDebuffs = data.allDebuffs
	local isCascade = data.isCascade
	local castByPlayer = data.castByPlayer
	if isCascade == nil then isCascade = SK.FALSE end
	if isCascade == SK.TRUE then delta = 0 end
	if ftDebuff ~= nil then delta = 0 end
	if allDebuffs == nil or allDebuffs == {} then allDebuffs = {data.debuff, ftDebuff} end
	for idx = 1, GetNumBuffs("reticleover") do
		local _, timeStarted, timeEnding, _, _, _, _, _, _, _, abilityId, _, isCastByPlayer = GetUnitBuffInfo("reticleover", idx)
		if SKH.isValueInList(allDebuffs, abilityId) and (castByPlayer ~= SK.TRUE or (castByPlayer == SK.TRUE and
				isCastByPlayer))
		then
			if timeStarted == timeEnding or timeEnding - delta > GetGameTimeSeconds() then
				if isCascade == SK.TRUE then
					active = true
					break
				else
					debuffCount = debuffCount + 1
				end
			end
		end
	end
	return (ftDebuff == nil and debuffCount == #allDebuffs) or (ftDebuff ~= nil and debuffCount ~= 0) or active
end

local function checkAbilityReady(id)
	local data = SK.globalSV.automationBlockAbilities[id]
	if data.disabled == SK.TRUE then return true end
	local active = false
	local stacks = 0
	local correctionInterval = data.correctionInterval
	if correctionInterval == nil then correctionInterval = SK.savedVars.abilityEndCorrectionInterval end
	if data.buff ~= nil then
		active, stacks = checkBuffAndStack(data, correctionInterval)
	elseif data.debuff ~= nil or data.allDebuffs ~= nil then
		active = checkDebuff(data, correctionInterval)
	elseif data.time ~= nil then
		active = checkAbilityActive(id, data, correctionInterval)
	elseif data.hp ~= nil then -- execution phase
		active = checkExecution(data.hp)
	end
	local mode = data.mode
	if mode == SKDA.CAST_MODES.NOT_ACTIVE then
		return not active
	elseif mode == SKDA.CAST_MODES.PROC or mode == SKDA.CAST_MODES.PHASE then
		return active
	elseif mode == SKDA.CAST_MODES.STACK then
		return active and stacks == 4
	elseif mode == SKDA.CAST_MODES.AVA_LOCATION then
		return IsPlayerInAvAWorld() and not active
	end
end

local function CanUseActionSlots()
	if not SK.savedVars.isAutomationBlockAbilities then return true end
	if not ((not (IsGameCameraActive() or IsInteractionCameraActive() or IsProgrammableCameraActive()) or
		SM:IsShowing("hud")) and not IsUnitDead("player")) then return false end
	local iCanUseThis = true
	local n = tonumber(debug.traceback():match("ACTION_BUTTON_(%d)"))
	local id = GetSlotBoundId(n)
	if SK.savedVars.debugMode then
		d("slot ability id "..id)
		d("targets ==============")
		for idx = 1, GetNumBuffs("reticleover") do
			local buffName, timeStarted, timeEnding, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("reticleover", idx)
			d(""..buffName..": "..abilityId)
		end
		d("player ===============")
		for idx = 1, GetNumBuffs("player") do
			local buffName, timeStarted, timeEnding, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", idx)
			d(""..buffName..": "..abilityId)
			d("timeStarted "..timeStarted*1000)
			d("timeEnding "..timeEnding*1000)
		end
	end
	if id ~= nil and id > 0 and n >= SKILL_BAR_FIRST_SLOT_INDEX and n <= SKILL_BAR_LAST_SLOT_INDEX and
		SK.globalSV.automationBlockAbilities ~= nil and SKH.isKeyInTable(SK.globalSV.automationBlockAbilities, id)
	then
		iCanUseThis = checkAbilityReady(id)
	end
	return iCanUseThis
end

local function CharacterSkillsUpdate(presetName)
	if not presetName then presetName = GetString(SI_SK_AUT_TRACKED_ABILITIES_MAIN_PRESET) end
	SKH.setTableChild(SK.globalSV.trackedAccountsHotbarAbilities, {
	SK.AccName, SK.PlayerName, "classId" }, GetUnitClassId("player"))
	SKH.setTableChild(SK.globalSV.trackedAccountsHotbarAbilities, {
	SK.AccName, SK.PlayerName, "gender" }, GetUnitGender("player"))
	local hotbarData
	for hotbarIndex = 0,1 do
		hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(hotbarIndex)
		if hotbarData then
			for actionSlotIndex= SKILL_BAR_FIRST_SLOT_INDEX, SKILL_BAR_LAST_SLOT_INDEX do
				local id = 0
		        if hotbarData:GetSlotData(actionSlotIndex) then id = GetSlotBoundId(actionSlotIndex, hotbarIndex) end
				SKH.setTableChild(SK.globalSV.trackedAccountsHotbarAbilities, {
					SK.AccName, SK.PlayerName, "skills", presetName, hotbarIndex, actionSlotIndex - ACTION_BAR_FIRST_NORMAL_SLOT_INDEX}, id)
			end
		end
	end
end

local function addAbilityPreset(...)
	CharacterSkillsUpdate(...)
	SKMD.trackedAbilitiesList:Refresh()
--  EVENT_MANAGER:RegisterForEvent("SK_Abilities_Update_Hotbar", EVENT_SKILL_RESPEC_RESULT, HotbarRespecSkills)
end

local function setAbilitySlot(hotbarIndex, slotIndex, abilityId)
    local hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(hotbarIndex)
	if hotbarData then
		if abilityId ~= -1 then
		    local progressionData = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(tonumber(abilityId))
		    local skillData = progressionData:GetSkillData()
		    local skillPointAllocator = skillData:GetPointAllocator()
		    local isPurchased = skillPointAllocator:IsPurchased()
		    if isPurchased then
		        hotbarData:AssignSkillToSlotByAbilityId(slotIndex, tonumber(abilityId))
		    else
	            SKH.sendMessageToChat(
                    SK.COLORED_PREFIXES.SKW,
                    SI_SK_AUT_ABILITY_NOT_PURCHASED_MESSAGE,
	                SK.COLOR.WHITE:Colorize(progressionData.name)
                )
		    end
		else
		    hotbarData:ClearSlot(slotIndex)
		    PlaySound(SOUNDS.ABILITY_SLOT_CLEARED)
		end
	end
end

local function removeAbilityPreset(accName, ownerName, presetName)
	if SKH.hasTableChild(SK.globalSV.trackedAccountsHotbarAbilities, {accName, ownerName, "skills", presetName}) then
		SKH.setTableChild(SK.globalSV.trackedAccountsHotbarAbilities, {accName, ownerName, "skills", presetName}, nil)
	end
	SKMD.trackedAbilitiesList:Refresh()
end

local function exportAbilityPreset(data)
	local name = data.presetName..ABILITY_NAME_DELIM..data.className..ABILITY_NAME_DELIM..data.ownerName
	local linkData = SK.LINK_TYPES.ABILITIES_PRESET..";"..data.classId..";"..data.gender..";"..data.ownerName..";"..data.accName
	for i = 0,1 do
		for _, skillId in pairs(data.skillsData[i]) do
			linkData = linkData..";"..skillId
		end
	end
    local link = ZO_LinkHandler_CreateLink(name, nil, linkData, SK.LINK_TYPES.ABILITIES_PRESET)
	ZO_LinkHandler_InsertLink(link)
end

local function importAbilityPreset(link, apply)
    local _, _, data, name = link:match("|H(.-):(.-):(.-)|h(.-)|h")
    local _, classId, gender, ownerName, accName, s01, s02, s03, s04, s05, s06, s11, s12, s13, s14, s15, s16 = zo_strsplit(";", data)
	local skills = {
		[0] = {s01, s02, s03, s04, s05, s06},
		[1] = {s11, s12, s13, s14, s15, s16}
	}
    local presetName, _, _ = zo_strsplit(ABILITY_NAME_DELIM, name)
	presetName = string.sub(presetName, 2)
	for hotbarIndex = 0,1 do
		for skillIndex, skillId in ipairs(skills[hotbarIndex]) do
			local slotIndex = skillIndex + ACTION_BAR_FIRST_NORMAL_SLOT_INDEX
			if apply then
                setAbilitySlot(hotbarIndex, slotIndex, skillId)
			else
				SKH.setTableChild(SK.globalSV.trackedAccountsHotbarAbilities, {
					"@"..accName, ownerName, "skills", presetName, hotbarIndex, skillIndex}, tonumber(skillId))
			end
		end
	end
	if not apply then
		SKH.setTableChild(SK.globalSV.trackedAccountsHotbarAbilities, {
			"@"..accName, ownerName, "classId" }, tonumber(classId))
		SKH.setTableChild(SK.globalSV.trackedAccountsHotbarAbilities, {
			"@"..accName, ownerName, "gender" }, tonumber(gender))
		SKMD.trackedAbilitiesList:Refresh()
	end
end

local function getSkillLineInfo(skillType, skillLineIndex)
    local skillLineData = SDM:GetSkillLineDataByIndices(skillType, skillLineIndex)
    if skillLineData then
        return skillLineData:GetName(), skillLineData:GetCurrentRank(), skillLineData:IsAvailable(), skillLineData:GetId(), skillLineData:IsAdvised(), skillLineData:GetUnlockText(), skillLineData:IsActive(), skillLineData:IsDiscovered()
    end
    return "", 1, false, 0, false, "", false, false
end

local function conditionalRefreshAbilityList()
	if SKMD.isVisible and SKMD.mode == SKDC.MAIN_DIALOGUE_WATCHED_ABILITIES_MODE then
		SKMD.watchedAbilitiesList:Refresh()
	else
		SKMD.needRefreshAfterOpen = true
	end
end

local function addAbilityToggleItem(abilityId)
    if SK.globalSV.automationBlockAbilities ~= nil and
        SKH.isKeyInTable(SK.globalSV.automationBlockAbilities, abilityId)
    then
        local itemName = GetString(SI_SK_AUT_ABILITY_DISABLE_CONTROL_BUTTON)
        local toState = SK.TRUE
        if SK.globalSV.automationBlockAbilities[abilityId].disabled == SK.TRUE then
            itemName = GetString(SI_SK_AUT_ABILITY_ENABLE_CONTROL_BUTTON)
            toState = SK.FALSE
        end
        AddMenuItem(
            table.concat({
                SK.COLORED_PREFIXES.SKW,
                SKH.getFormattedText(itemName)
            }), function()
            SK.globalSV.automationBlockAbilities[abilityId].disabled = toState
            conditionalRefreshAbilityList()
        end)
    end
end
local function addAbilityEditItem(abilityId)
	if SK.globalSV.automationBlockAbilities ~= nil and
			SKH.isKeyInTable(SK.globalSV.automationBlockAbilities, abilityId)
	then
		AddMenuItem(
			table.concat({
				SK.COLORED_PREFIXES.SKW,
				SKH.getFormattedText(GetString(SI_SK_AUT_UNWANTED_LIST_EDIT_BUTTON))
			}), function()
			SKEA:Open(abilityId)
			conditionalRefreshAbilityList()
		end)
	end
end

local function addAbilityMenuItems(abilitySlot, buttonId)
    if not SK.savedVars.isAutomationBlockAbilities then return end
    local button = ZO_ActionBar_GetButton(abilitySlot.slotNum, abilitySlot.hotbarCategory)
	local id
	if button then
		local slotNum = button:GetSlot()
		if IsSlotUsed(slotNum, abilitySlot.hotbarCategory) and not IsActionSlotRestricted(slotNum, abilitySlot.hotbarCategory) then
			id = GetSlotBoundId(slotNum)
		end
	else
	    local self = abilitySlot.owner
	    if self.hotbar:AreHotbarEditsEnabled() then
		    local hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER:GetCurrentHotbar()
		    local slotData = hotbarData:GetSlotData(self.slotId)
		    if slotData and not slotData:IsEmpty() and not IsActionSlotRestricted(self.slotId, hotbarData:GetHotbarCategory()) then
	            id = GetSlotBoundId(self.slotId)
		    end
	    end
	end
    if id then
        zo_callLater(function()
            addAbilityToggleItem(id)
	        addAbilityEditItem(id)
	        ShowMenu(abilitySlot)
            return true
        end)
    end
end

-- Export helper functions
SK.HelperFunctions.CanUseActionSlots = CanUseActionSlots
SK.HelperFunctions.CharacterSkillsUpdate = CharacterSkillsUpdate
SK.HelperFunctions.addAbilityPreset = addAbilityPreset
SK.HelperFunctions.setAbilitySlot = setAbilitySlot
SK.HelperFunctions.removeAbilityPreset = removeAbilityPreset
SK.HelperFunctions.exportAbilityPreset = exportAbilityPreset
SK.HelperFunctions.importAbilityPreset = importAbilityPreset
SK.HelperFunctions.getSkillLineInfo = getSkillLineInfo
SK.HelperFunctions.addAbilityMenuItems = addAbilityMenuItems
