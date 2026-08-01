local ADDON = CraftingStationSpCpDisplayNinja
local LAM = LibAddonMenu2

ADDON.UI = ADDON.UI or {}

ADDON.UI.RootName = ADDON.NAME .. "_UI"

--------
-- local
--------

local buttonWidth = 48
local buttonHeight = 32

local function load()
	ADDON.UI.TopLevelControl = ADDON.UI.TopLevelControl or CraftingStationSpCpDisplayNinja_UI or {}
	ADDON.UI.ButtonBase = ADDON.UI.ButtonBase or CraftingStationSpCpDisplayNinja_UI_ButtonBase or {}
end

local function getButtonName(name)
	local newName = ADDON.UI.RootName .. "_" .. name
	--ADDON.develop("getButtonName: " .. newName)
	return newName
end

local SKILL_LINE =
{
	CP_ability_id = 142224,
	CP_skill_id = 83,--83 -- Meticulous Disassembly
	[CRAFTING_TYPE_BLACKSMITHING] = {
		skill_line_id = 79,
		base_ability_id = 70041,		-- "Metalworking"
		improve_ability_id = 48168,		-- "Temper Expertise"
		extract_ability_id = 48165,-- Lv3
		},
	[CRAFTING_TYPE_CLOTHIER] = {
		skill_line_id = 81,
		base_ability_id = 70044, 		-- "Tailoring"
		improve_ability_id = 48198,		-- "Tannin Expertise"
		extract_ability_id = 48195,-- Lv3
		},
	[CRAFTING_TYPE_WOODWORKING] = {
		skill_line_id = 80,
		base_ability_id = 70046, 		-- "Woodworking"
		improve_ability_id = 48177, 	-- "Resin Expertise"
		extract_ability_id = 48180,-- Lv3
		},
	[CRAFTING_TYPE_JEWELRYCRAFTING] = {
		skill_line_id = 141,
		base_ability_id = 103636, 		-- "Engraver"
		improve_ability_id = 103648,	-- "Platings Expertise"
		extract_ability_id = 103645,-- Lv3
		},
	[CRAFTING_TYPE_ALCHEMY] = {
		skill_line_id = 77,
		base_ability_id = 70043,		-- "Solvent Expertise"
		improve_ability_id = nil,		-- no blue/purple/gold in alchemy
		extract_ability_id = nil,
		},
	[CRAFTING_TYPE_ENCHANTING] = {
		skill_line_id = 78,
		base_ability_id = 70045,		-- "Potency Improvement" -- glyph level
		improve_ability_id = 46763,		-- "Aspect Improvement", allows gold Kuta
		extract_ability_id = 46769,-- Lv3
		},
	[CRAFTING_TYPE_PROVISIONING] = {
		skill_line_id = 76,
		base_ability_id = 44650, 		-- "Recipe Improvement" = recipe level
		improve_ability_id = 69953, 	-- "Recipe Quality", allows use of gold recipes
		extract_ability_id = nil,
		},
}

local function getCraftLevel(station)

	local skillLine = SKILL_LINE[station]
	local basicSkill, basicSkillMax, extractingSkill, extractingSkillMax,  improvingSkill, improvingSkillMax
	local skillType, skillIndex, abilityIndex, morphChoice, rankindex
	
	skillType, skillIndex, abilityIndex, morphChoice, rankindex = GetSpecificSkillAbilityKeysByAbilityId(skillLine.base_ability_id)
	if abilityIndex then
		basicSkill, basicSkillMax = GetSkillAbilityUpgradeInfo(skillType,skillIndex,abilityIndex)
	end

	skillType, skillIndex, abilityIndex, morphChoice, rankindex = GetSpecificSkillAbilityKeysByAbilityId(skillLine.extract_ability_id)
	if abilityIndex then
		extractingSkill, extractingSkillMax = GetSkillAbilityUpgradeInfo(skillType,skillIndex,abilityIndex)
	end

	skillType, skillIndex, abilityIndex, morphChoice, rankindex = GetSpecificSkillAbilityKeysByAbilityId(skillLine.improve_ability_id)
	if abilityIndex then
		improvingSkill, improvingSkillMax = GetSkillAbilityUpgradeInfo(skillType,skillIndex,abilityIndex)
	end

	return basicSkill, basicSkillMax, extractingSkill, extractingSkillMax,  improvingSkill, improvingSkillMax
end

local function nullToZero(nullableValue)
	if nullableValue == nil then
		return 0
	end

	return nullableValue
end

--------
-- in this ADDON use, protected
--------

ADDON.UI.Restore = function()
	ADDON.develop("UI.Restore")
	load()

	if (ADDON.SaveData.Display.ShowUI == nil or not ADDON.SaveData.Display.ShowUI) then
		ADDON.UI.TopLevelControl:SetHidden(true)
		return
	end

	ADDON.UI.TopLevelControl:ClearAnchors()
	ADDON.UI.TopLevelControl:SetAnchor(
		TOPLEFT,
		GuiRoot,
		TOPLEFT,
		ADDON.SaveData.Position.Left,
		ADDON.SaveData.Position.Top
	)

	local iconNum = 0

	local commandButtons = {
		"OpenSettings",
	}
	local levelDisplayButtons = {
		"BasicSkillLevel",
		"ExtractingSkillLevel",
		"MeticulousDisassemblyLevel",
		"ImprovingSkillLevel",
	}

	for key, button in ipairs(commandButtons) do
		local flagControl = GetControl(getButtonName(button))
		if (ADDON.SaveData.Display.Buttons[button]) then
			flagControl:SetAnchor(LEFT, ADDON.UI.TopLevelControl, LEFT, iconNum * buttonWidth, 0)
			iconNum = iconNum + 1
		end
		flagControl:SetHidden(not ADDON.SaveData.Display.Buttons[button])
	end
	for key, button in ipairs(levelDisplayButtons) do
		local flagControl = GetControl(getButtonName(button))
		if (ADDON.SaveData.Display.Buttons[button]) then
			flagControl:SetAnchor(LEFT, ADDON.UI.TopLevelControl, LEFT, iconNum * buttonWidth, 0)
			iconNum = iconNum + 1
		end
		flagControl:SetHidden(not ADDON.SaveData.Display.Buttons[button])
	end

	if (iconNum == 0) then
		--ADDON.UI.TopLevelControl:SetHidden(true)
		--return
	end

	ADDON.UI.TopLevelControl:SetDimensions(16 + iconNum * buttonWidth, 10 + buttonHeight)

	--ADDON.UI.Refresh()
end

ADDON.UI.CraftBegin = function(craftSkill)
	ADDON.develop("CraftBegin")
	ADDON.develop(craftSkill)

	local basicSkill = ""
	local basicSkillMax = ""
	local extractingSkill = ""
	local extractingSkillMax = ""
	local improvingSkill = ""
	local improvingSkillMax = ""
	local cp = ""
	local cpMax = ""
	local mustCheck = true
	local craftingName = ""
	local mustCpCheck = true

	if craftSkill == CRAFTING_TYPE_BLACKSMITHING  then
		craftingName = "B]"
		basicSkill, basicSkillMax, extractingSkill, extractingSkillMax,  improvingSkill, improvingSkillMax = getCraftLevel(CRAFTING_TYPE_BLACKSMITHING)
	elseif craftSkill == CRAFTING_TYPE_CLOTHIER  then
		craftingName = "C]"
		basicSkill, basicSkillMax, extractingSkill, extractingSkillMax,  improvingSkill, improvingSkillMax = getCraftLevel(CRAFTING_TYPE_CLOTHIER)
	elseif craftSkill == CRAFTING_TYPE_WOODWORKING  then
		craftingName = "W]"
		basicSkill, basicSkillMax, extractingSkill, extractingSkillMax,  improvingSkill, improvingSkillMax = getCraftLevel(CRAFTING_TYPE_WOODWORKING)
	elseif craftSkill == CRAFTING_TYPE_ENCHANTING  then
		craftingName = "E]"
		mustCpCheck = false
		basicSkill, basicSkillMax, extractingSkill, extractingSkillMax,  improvingSkill, improvingSkillMax = getCraftLevel(CRAFTING_TYPE_ENCHANTING)
	elseif craftSkill == CRAFTING_TYPE_JEWELRYCRAFTING  then
		craftingName = "J]"
		basicSkill, basicSkillMax, extractingSkill, extractingSkillMax,  improvingSkill, improvingSkillMax = getCraftLevel(CRAFTING_TYPE_JEWELRYCRAFTING)
	elseif craftSkill == CRAFTING_TYPE_INVALID  then
		craftingName = "Assistant]"

		local basicSkillTemp, basicSkillMaxTemp, extractingSkillTemp, extractingSkillMaxTemp,  improvingSkillTemp, improvingSkillMaxTemp

		basicSkillTemp, basicSkillMaxTemp, extractingSkillTemp, extractingSkillMaxTemp,  improvingSkillTemp, improvingSkillMaxTemp = getCraftLevel(CRAFTING_TYPE_BLACKSMITHING)
		basicSkill = basicSkill .. basicSkillTemp .. ","
		basicSkillMax = basicSkillMax .. basicSkillMaxTemp .. ","
		extractingSkill = extractingSkill .. extractingSkillTemp .. ","
		extractingSkillMax = extractingSkillMax .. extractingSkillMaxTemp .. ","
		improvingSkill = improvingSkill .. improvingSkillTemp .. ","
		improvingSkillMax = improvingSkillMax .. improvingSkillMaxTemp .. ","

		basicSkillTemp, basicSkillMaxTemp, extractingSkillTemp, extractingSkillMaxTemp,  improvingSkillTemp, improvingSkillMaxTemp = getCraftLevel(CRAFTING_TYPE_CLOTHIER)
		basicSkill = basicSkill .. basicSkillTemp .. ","
		basicSkillMax = basicSkillMax .. basicSkillMaxTemp .. ","
		extractingSkill = extractingSkill .. extractingSkillTemp .. ","
		extractingSkillMax = extractingSkillMax .. extractingSkillMaxTemp .. ","
		improvingSkill = improvingSkill .. improvingSkillTemp .. ","
		improvingSkillMax = improvingSkillMax .. improvingSkillMaxTemp .. ","

		basicSkillTemp, basicSkillMaxTemp, extractingSkillTemp, extractingSkillMaxTemp,  improvingSkillTemp, improvingSkillMaxTemp = getCraftLevel(CRAFTING_TYPE_WOODWORKING)
		basicSkill = basicSkill .. basicSkillTemp .. ","
		basicSkillMax = basicSkillMax .. basicSkillMaxTemp .. ","
		extractingSkill = extractingSkill .. extractingSkillTemp .. ","
		extractingSkillMax = extractingSkillMax .. extractingSkillMaxTemp .. ","
		improvingSkill = improvingSkill .. improvingSkillTemp .. ","
		improvingSkillMax = improvingSkillMax .. improvingSkillMaxTemp .. ","

		basicSkillTemp, basicSkillMaxTemp, extractingSkillTemp, extractingSkillMaxTemp,  improvingSkillTemp, improvingSkillMaxTemp = getCraftLevel(CRAFTING_TYPE_ENCHANTING)
		basicSkill = basicSkill .. basicSkillTemp .. ","
		basicSkillMax = basicSkillMax .. basicSkillMaxTemp .. ","
		extractingSkill = extractingSkill .. extractingSkillTemp .. ","
		extractingSkillMax = extractingSkillMax .. extractingSkillMaxTemp .. ","
		improvingSkill = improvingSkill .. improvingSkillTemp .. ","
		improvingSkillMax = improvingSkillMax .. improvingSkillMaxTemp .. ","

		basicSkillTemp, basicSkillMaxTemp, extractingSkillTemp, extractingSkillMaxTemp,  improvingSkillTemp, improvingSkillMaxTemp = getCraftLevel(CRAFTING_TYPE_JEWELRYCRAFTING)
		basicSkill = basicSkill .. basicSkillTemp
		basicSkillMax = basicSkillMax .. basicSkillMaxTemp
		extractingSkill = extractingSkill .. extractingSkillTemp
		extractingSkillMax = extractingSkillMax .. extractingSkillMaxTemp
		improvingSkill = improvingSkill .. improvingSkillTemp
		improvingSkillMax = improvingSkillMax .. improvingSkillMaxTemp

	else
		mustCheck = false
	end

	cp = GetNumPointsSpentOnChampionSkill(SKILL_LINE.CP_skill_id)
	cpMax = GetChampionSkillMaxPoints(SKILL_LINE.CP_skill_id)
	--[[
	
	-- slots
	local start, nd = 1,4--GetAssignableChampionBarStartAndEndSlots()
	local i
	for i=start, nd do
		local starId = GetSlotBoundId(i, HOTBAR_CATEGORY_CHAMPION)
		local slottedChampionAbilityId = GetChampionAbilityId(starId)
		if SKILL_LINE.CP_ability_id == slottedChampionAbilityId then
			cp = 1
			break
		end
	end
	]]

	
	ADDON.develop("basicSkill:" .. basicSkill)
	ADDON.develop("basicSkillMax:" .. basicSkillMax)
	ADDON.develop("extractingSkill:" .. extractingSkill)
	ADDON.develop("extractingSkillMax:" .. extractingSkillMax)
	ADDON.develop("improvingSkill:" .. improvingSkill)
	ADDON.develop("improvingSkillMax:" .. improvingSkillMax)
	ADDON.develop("cp:" .. cp)
	ADDON.develop("cpMax:" .. cpMax)

	if basicSkillMax == "" then
		basicSkillMax = nil
	end
	if improvingSkillMax == "" then
		improvingSkillMax = nil
	end
	if extractingSkillMax == "" then
		extractingSkillMax = nil
	end

	if mustCheck then	

		ADDON.develop("mustCheck!")
		local warningMessageList = {}

		-- display GUI 
		if (ADDON.SaveData.Display["ShowUI"]) then
			local GUIControl
			local color
			local colorNg = "|cFF0000"
			local colorOk = "|c00DD22"
			local colorNormal = "|cFFFFFF"
			local colorEnd = "|r"

			if basicSkillMax == nil then
				color = colorNormal
			elseif basicSkill == basicSkillMax then
				color = colorOk
			else
				color = colorNg
			end
			GUIControl = GetControl(getButtonName("BasicSkillLevel"))
			GUIControl:SetText(string.format("%s%s%s%s", "Ba ", color, tostring(nullToZero(basicSkill)), colorEnd))

			if extractingSkillMax == nil then
				color = colorNormal
			elseif extractingSkill == extractingSkillMax then
				color = colorOk
			else
				color = colorNg
			end
			GUIControl = GetControl(getButtonName("ExtractingSkillLevel"))
			GUIControl:SetText(string.format("%s%s%s%s", "Ex ", color, tostring(nullToZero(extractingSkill)), colorEnd))

			if mustCpCheck == false then
				color = colorNormal
			elseif cp == cpMax then
				color = colorOk
			else
				color = colorNg
			end
			GUIControl = GetControl(getButtonName("MeticulousDisassemblyLevel"))
			GUIControl:SetText(string.format("%s%s%s%s", "CP ", color, tostring(nullToZero(cp)), colorEnd))

			if improvingSkillMax == nil then
				color = colorNormal
			elseif improvingSkill == improvingSkillMax then
				color = colorOk
			else
				color = colorNg
			end
			GUIControl = GetControl(getButtonName("ImprovingSkillLevel"))
			GUIControl:SetText(string.format("%s%s%s%s", "Im ", color, tostring(nullToZero(improvingSkill)), colorEnd))

			ADDON.UI.TopLevelControl:SetHidden(false)
		end

		local saveDataCheckTarget = ADDON.SaveData.CheckTarget[craftSkill]

		if (saveDataCheckTarget.MeticulousDisassemblyLevel) then
			if (mustCpCheck) then
				if cpMax ~= cp then
					warningMessageList[#warningMessageList + 1] = "CP"
				end
			end
		end
		if (saveDataCheckTarget.BasicSkillLevel) then
			if (basicSkillMax ~= nil) then
				if basicSkillMax ~= basicSkill then
					warningMessageList[#warningMessageList + 1] = "Ba"
				end
			end
		end
		if (saveDataCheckTarget.ExtractingSkillLevel) then
			if (extractingSkillMax ~= nil) then
				if extractingSkillMax ~= extractingSkill then
					warningMessageList[#warningMessageList + 1] =  "Ex"
				end
			end
		end
		if (saveDataCheckTarget.ImprovingSkillLevel) then
			if (improvingSkillMax ~= nil) then
				if improvingSkillMax ~= improvingSkill then
					warningMessageList[#warningMessageList + 1] = "Im"
				end
			end
		end

		-- warning
		if (#warningMessageList > 0) then
			local warningMessageAll = craftingName .. ADDON.SaveData.Messages.CheckResultIsBad --"どうしてスキルがないんですか？"
			for key, warningMessage in ipairs(warningMessageList) do
				warningMessageAll = warningMessageAll .. warningMessage .. " "
			end
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, warningMessageAll)

			if (ADDON.SaveData.ShowSkillInfoOnWarning[craftSkill]) then
				ADDON.develop("ShowSkillInfoOnWarning")
				ADDON.SystemMessage("basicSkill:" .. basicSkill, true)
				ADDON.SystemMessage("basicSkillMax:" .. basicSkillMax, true)
				ADDON.SystemMessage("extractingSkill:" .. extractingSkill, true)
				ADDON.SystemMessage("extractingSkillMax:" .. extractingSkillMax, true)
				ADDON.SystemMessage("improvingSkill:" .. improvingSkill, true)
				ADDON.SystemMessage("improvingSkillMax:" .. improvingSkillMax, true)
				ADDON.SystemMessage("cp:" .. cp, true)
				ADDON.SystemMessage("cpMax:" .. cpMax, true)
			end
		else
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.POSITIVE_CLICK, craftingName .. ADDON.SaveData.Messages.CheckResultIsGood) -- "スキル！ヨシ！"
		end
	else
		-- Not Check target crafting station. dismiss GUI.
		ADDON.develop("mustCheck is false. SetHidden(true)")
		ADDON.UI.TopLevelControl:SetHidden(true)
	end
end

ADDON.UI.CraftEnd = function()
	ADDON.develop("CraftEnd. SetHidden(true)")
	ADDON.UI.TopLevelControl:SetHidden(true)
end

--------
-- UI, defined without namespace
--------

CraftingStationSpCpDisplayNinja_UI_SavePosition = function()
	ADDON.develop("UI_SavePosition")
	load()

	local defaultSaveData = ADDON.GetDefaultSaveData()

	local left = ADDON.UI.TopLevelControl:GetLeft() or defaultSaveData.Position.Left
	local top = ADDON.UI.TopLevelControl:GetTop() or defaultSaveData.Position.Top
	ADDON.SaveData.Position = {
		["Left"] = left,
		["Top"] = top,
	}
end

CraftingStationSpCpDisplayNinja_UI_OnClickOpenSettings = function()
	ADDON.develop("UI_OnClickOpenSettings")

	LAM:OpenToPanel(ADDON.SettingsPanel)
end

CraftingStationSpCpDisplayNinja_UI_OnClickLevelDisplay = function()
	ADDON.develop("UI_OnClickLevelDisplay")
end

