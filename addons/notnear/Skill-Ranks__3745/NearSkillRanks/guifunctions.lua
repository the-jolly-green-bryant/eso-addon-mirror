NEAR_SR.gui = {}
local addon = NEAR_SR

local function FormatAbilityName(id)
	return zo_strformat("<<C:1>>", GetAbilityName(id))
end

local function FormatSkilLineName(id)
	return zo_strformat("<<C:1>>", GetSkillLineNameById(id))
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
addon.gui.selectedChar_charId = GetCurrentCharacterId()
addon.gui.selectedChar_classId = GetUnitClassId('player')
local selectedChar_name = nil
---------------------------------------------------------------------------------
local selected_skillType = SKILL_TYPE_CLASS
local selected_skillType_name = GetString(SI_SKILLTYPE1)
---------------------------------------------------------------------------------
local selected_skillLine = 1
local selected_skillLine_name = nil
---------------------------------------------------------------------------------
local selectedSkillLine_abilities_name = nil
local selectedSkillLine_abilities_rank = nil
---------------------------------------------------------------------------------
local skillTypesTable = {
	[SKILL_TYPE_CLASS] = GetString(SI_SKILLTYPE1),
	[SKILL_TYPE_WEAPON] = GetString(SI_SKILLTYPE2),
	[SKILL_TYPE_ARMOR] = GetString(SI_SKILLTYPE3),
	[SKILL_TYPE_WORLD] = GetString(SI_SKILLTYPE4),
	[SKILL_TYPE_GUILD] = GetString(SI_SKILLTYPE5),
	[SKILL_TYPE_AVA] = GetString(SI_SKILLTYPE6),
	-- [SKILL_TYPE_RACIAL] = GetString(SI_SKILLTYPE7),
	[addon.SKILL_TYPE_TRADESKILL] = GetString(SI_SKILLTYPE8),
}
---------------------------------------------------------------------------------
local skillLineMaxIndexes = {
	[SKILL_TYPE_CLASS] = 3,
	[SKILL_TYPE_WEAPON] = 6,
	[SKILL_TYPE_ARMOR] = 3,
	[SKILL_TYPE_WORLD] = 6,
	[SKILL_TYPE_GUILD] = 6,
	[SKILL_TYPE_AVA] = 3,
	-- [SKILL_TYPE_RACIAL] = 10,
	[addon.SKILL_TYPE_TRADESKILL] = 7,
}
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function buildData(numSkills)
	local notDiscovered = GetString(NEARSR_notdiscovered) .. "|r"
	local selectedChar_charId = addon.gui.selectedChar_charId
	local selectedChar_classId = addon.gui.selectedChar_classId
	local sv_skillLine
	local sd_skillLine

	if selected_skillType == SKILL_TYPE_CLASS then
		sv_skillLine = addon.ASV.char[selectedChar_charId][selected_skillType][selectedChar_classId][selected_skillLine]
		sd_skillLine = addon.skilldata[selected_skillType][selectedChar_classId][selected_skillLine]
	else
		sv_skillLine = addon.ASV.char[selectedChar_charId][selected_skillType][selected_skillLine]
		sd_skillLine = addon.skilldata[selected_skillType][selected_skillLine]
	end

	if not sv_skillLine.discovered == true then
		selectedSkillLine_abilities_name = notDiscovered
		selectedSkillLine_abilities_rank = ''
		return
	elseif numSkills == 0 then
		selectedSkillLine_abilities_name = FormatSkilLineName(sd_skillLine.id)
		selectedSkillLine_abilities_rank = 'Lv: ' .. sv_skillLine.rank
		return
	end

	local indent = '     '

	selectedSkillLine_abilities_name = FormatSkilLineName(sd_skillLine.id) .. '\n\n'
	for i = 1, numSkills do
		if sd_skillLine[i] ~= nil then
			selectedSkillLine_abilities_name = selectedSkillLine_abilities_name .. 'Name: ' .. FormatAbilityName(sd_skillLine[i][0].id) .. '\n'
			if sd_skillLine[i][1] ~= nil then
				selectedSkillLine_abilities_name = selectedSkillLine_abilities_name .. indent .. 'Name: ' .. FormatAbilityName(sd_skillLine[i][1].id) .. '\n'
			end
			if sd_skillLine[i][2] ~= nil then
				selectedSkillLine_abilities_name = selectedSkillLine_abilities_name .. indent .. 'Name: ' .. FormatAbilityName(sd_skillLine[i][2].id) .. '\n'
			end
			selectedSkillLine_abilities_name = selectedSkillLine_abilities_name .. '\n'
		end
	end

	--------------------------------------------------

	selectedSkillLine_abilities_rank = 'Lv: ' .. sv_skillLine.rank .. '\n\n'
	for i = 1, numSkills do
		if sv_skillLine[i] ~= nil then
			selectedSkillLine_abilities_rank = selectedSkillLine_abilities_rank .. 'Rank: ' .. sv_skillLine[i][0] .. '\n'
			if sv_skillLine[i][1] ~= nil then
				selectedSkillLine_abilities_rank = selectedSkillLine_abilities_rank .. 'Rank: ' .. sv_skillLine[i][1] .. '\n'
			end
			if sv_skillLine[i][2] ~= nil then
				selectedSkillLine_abilities_rank = selectedSkillLine_abilities_rank .. 'Rank: ' .. sv_skillLine[i][2] .. '\n'
			end
			selectedSkillLine_abilities_rank = selectedSkillLine_abilities_rank .. '\n'
		end
	end
end

local function gui_CreateList_abilities()
	local selectedChar_charId = addon.gui.selectedChar_charId

	local utils = addon.utils

	-- check if there is data for that character, if not, clear shown data and send warning message
	if addon.ASV.char[selectedChar_charId] == nil then
		d(utils.dbg.default .. GetString(NEARSR_nodata))

		selectedSkillLine_abilities_name = utils.color.red .. GetString(NEARSR_nodata) .. "|r"
		selectedSkillLine_abilities_rank = ''
		return
	end

	--------------------------------------------------------------------------------
	-- 0 skills
	--------------------------------------------------------------------------------
	if selected_skillType == addon.SKILL_TYPE_TRADESKILL or
		(selected_skillType == SKILL_TYPE_WORLD and (selected_skillLine == 1 or selected_skillLine == 2 or selected_skillLine == 3)) or
		(selected_skillType == SKILL_TYPE_GUILD and (selected_skillLine == 1 or selected_skillLine == 5)) or
		(selected_skillType == SKILL_TYPE_AVA and selected_skillLine == 2) then
		buildData(0)

	--------------------------------------------------------------------------------
	-- 1 skills
	--------------------------------------------------------------------------------
	elseif selected_skillType == SKILL_TYPE_ARMOR then
		buildData(1)

	--------------------------------------------------------------------------------
	-- 4 skills
	--------------------------------------------------------------------------------
	elseif selected_skillType == SKILL_TYPE_WORLD and selected_skillLine == 4 then
		buildData(4)

	--------------------------------------------------------------------------------
	-- 5 skills
	--------------------------------------------------------------------------------
	elseif (selected_skillType == SKILL_TYPE_GUILD and selected_skillLine == 6) then
		buildData(5)

	--------------------------------------------------------------------------------
	-- 7 skills
	--------------------------------------------------------------------------------
	elseif selected_skillType == SKILL_TYPE_WEAPON then
		buildData(7)

	--------------------------------------------------------------------------------
	-- 6 skills
	--------------------------------------------------------------------------------
	else
		buildData(6)
	end
end

local function gui_UpdateList_abilities()
	gui_CreateList_abilities()

	NSR_GUI_MAIN_Abilities_Name:SetText(selectedSkillLine_abilities_name)
	NSR_GUI_MAIN_Abilities_Rank:SetText(selectedSkillLine_abilities_rank)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function SetSelectedSkillLine(stName)
	for i = 1, #addon.skillLine_Data do
		if stName == addon.skillLine_Data[i].name then
			selected_skillLine = addon.skillLine_Data[i].index
			break
		end
	end
end

local function gui_CreateList_SkillLine()
	local selectedChar_charId = addon.gui.selectedChar_charId
	local selectedChar_classId = addon.gui.selectedChar_classId

	local sv = addon.ASV.settings
	local sv_char = addon.ASV.char[selectedChar_charId]

	NSR_GUI_MAIN_skilldata_SkillLine.comboBox = NSR_GUI_MAIN_skilldata_SkillLine.comboBox or ZO_ComboBox_ObjectFromContainer(NSR_GUI_MAIN_skilldata:GetNamedChild("_SkillLine"))
	local NSR_comboBox = NSR_GUI_MAIN_skilldata_SkillLine.comboBox

	addon.skillLine_Names = {}
	addon.skillLine_Data = {}
	-- check if there's data for that character
	if sv_char == nil then
		local unknown = 'No data'

		addon.skillLine_Names[1] = unknown
		addon.skillLine_Data[1] = {
			name = unknown,
			index = 1,
		}

		selected_skillLine = addon.skillLine_Data[1].index
		selected_skillLine_name = addon.skillLine_Data[1].name
	else
		local function color(skillType, skillLine)
			if skillType ~= SKILL_TYPE_CLASS then
				local discovered = sv_char[skillType][skillLine].discovered
				if discovered == false then
					return NEAR_SR.utils.color.grey
				else
					return ''
				end
			else
				local discovered = sv_char[skillType][selectedChar_classId][skillLine].discovered
				if discovered == false then
					return NEAR_SR.utils.color.grey
				else
					return ''
				end
			end
		end

		local prefix, mid = "Lv ", ' '

		for skillLineIndex = 1, skillLineMaxIndexes[selected_skillType], 1 do
			if selected_skillType ~= SKILL_TYPE_CLASS then
				local sv_skillLine = sv_char[selected_skillType][skillLineIndex]

				local skillLineName = FormatSkilLineName(addon.skilldata[selected_skillType][skillLineIndex].id)
				local skillLineRank = sv_skillLine.rank

				local skillLineData = color(selected_skillType, skillLineIndex) .. prefix .. skillLineRank .. mid .. skillLineName

				addon.skillLine_Names[skillLineIndex] = skillLineData
				addon.skillLine_Data[skillLineIndex] = {
					name = skillLineData,
					index = skillLineIndex,
				}

				if selected_skillLine == addon.skillLine_Data[skillLineIndex].index then
					selected_skillLine_name = addon.skillLine_Data[skillLineIndex].name
				end
			elseif selected_skillType == SKILL_TYPE_CLASS then
				local sv_skillLine = sv_char[selected_skillType][selectedChar_classId][skillLineIndex]

				local skillLineName = FormatSkilLineName(addon.skilldata[selected_skillType][selectedChar_classId][skillLineIndex].id)
				local skillLineRank = sv_skillLine.rank

				local skillLineData = color(selected_skillType, skillLineIndex) .. prefix .. skillLineRank .. mid .. skillLineName

				addon.skillLine_Names[skillLineIndex] = skillLineData
				addon.skillLine_Data[skillLineIndex] = {
					name = skillLineData,
					index = skillLineIndex,
				}

				if selected_skillLine == addon.skillLine_Data[skillLineIndex].index then
					selected_skillLine_name = addon.skillLine_Data[skillLineIndex].name
				end
			else
				--[[ Debug ]] if sv.debug then d('error at CreateList_SkillLine()') end
			end
		end
	end

	local function OnItemSelect(_, choiceText, choice)
		SetSelectedSkillLine(choiceText)

		gui_UpdateList_abilities()
		-- PlaySound(SOUNDS.POSITIVE_CLICK)
	end

	NSR_comboBox:SetSortsItems(false)

	for k, _ in ipairs(addon.skillLine_Names) do
		NSR_comboBox:AddItem(NSR_comboBox:CreateItemEntry(addon.skillLine_Names[k], OnItemSelect))
		if addon.skillLine_Names[k] == selected_skillLine_name then
			NSR_comboBox:SetSelectedItem(addon.skillLine_Names[k])
		end
	end
end

local function gui_UpdateList_SkillLine(setIndex)
	local NSR_comboBox = NSR_GUI_MAIN_skilldata_SkillLine.comboBox

	if setIndex then
		selected_skillLine = 1
		NSR_comboBox:SetSelectedItem(selected_skillLine_name)
	end

	-- purge previous data
	addon.skillLine_Names = nil
	addon.skillLine_Data = nil
	NSR_comboBox:ClearItems()

	gui_CreateList_SkillLine()

	NSR_comboBox:UpdateItems()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function SetSelectedSkillType(stName)
	for i = 1, #addon.skillType_Data do
		if stName == addon.skillType_Data[i].name then
			selected_skillType = addon.skillType_Data[i].index
			break
		end
	end
end

local function gui_CreateList_SkillType()
	NSR_GUI_MAIN_skilldata_SkillType.comboBox = NSR_GUI_MAIN_skilldata_SkillType.comboBox or ZO_ComboBox_ObjectFromContainer(NSR_GUI_MAIN_skilldata:GetNamedChild("_SkillType"))
	local NSR_comboBox = NSR_GUI_MAIN_skilldata_SkillType.comboBox

	addon.skillType_Names = {}
	addon.skillType_Data = {}
	for key, value in ipairs(skillTypesTable) do
		addon.skillType_Names[key] = value
		addon.skillType_Data[key] = {
			name = value,
			index = key,
		}
	end

	local function OnItemSelect(_, choiceText, choice)
		SetSelectedSkillType(choiceText)

		gui_UpdateList_SkillLine(true)
		gui_UpdateList_abilities()
		-- PlaySound(SOUNDS.POSITIVE_CLICK)
	end

	NSR_comboBox:SetSortsItems(false)

	for k, _ in ipairs(addon.skillType_Names) do
		NSR_comboBox:AddItem(NSR_comboBox:CreateItemEntry(addon.skillType_Names[k], OnItemSelect))
		if addon.skillType_Names[k] == selected_skillType_name then
			NSR_comboBox:SetSelectedItem(addon.skillType_Names[k])
		end
	end
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- skill line quick view functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

NEAR_SR.gui.quick = {}
local first_time = true
local selected_page = 1
---------------------------------------------------------------------------------

local function quick_CreateListChar()
	for i, charData in ipairs(addon.charData) do
		local name = charData.charName

		local control = GetControl("NSR_QUICK_MAIN_List_Row" .. i .. "_Name")
		control:SetText(name)

		if charData.charId == GetCurrentCharacterId() then
			local r, g, b, a = 0.4, 0.698, 1, 1
			control:SetColor(r, g, b, a) -- #66b2ff
		end
	end
end

local function quick_CreateList(page)
	local function updateRanks(skillTypes)
		for i, charData in ipairs(addon.charData) do
			local charId = charData.charId
			local classId = charData.classId
			local i2 = 0

			for _, skillType in ipairs(skillTypes) do
				local charSkillData = addon.ASV.char[charId] and addon.ASV.char[charId][skillType]
				if not charSkillData then
					charSkillData = {} -- Define an empty table if the data is not available
				end

				for skillLineIndex = 1, skillLineMaxIndexes[skillType] do
					local rank
					if skillType == SKILL_TYPE_CLASS then
						if charSkillData[classId] and charSkillData[classId][skillLineIndex] then
							rank = charSkillData[classId][skillLineIndex].discovered and charSkillData[classId][skillLineIndex].rank or "-"
						else
							rank = "NA"
						end
					else
						if charSkillData[skillLineIndex] then
							rank = charSkillData[skillLineIndex].discovered and charSkillData[skillLineIndex].rank or "-"
						else
							rank = "NA"
						end
					end

					local r, g, b, a
					if type(rank) == "number" then
						local skillLineMaxRank = addon.func.GetSkillLineMaxRank(skillType, skillLineIndex)
						local progress = rank / skillLineMaxRank
						if progress == 1 then
							r, g, b, a = 0.75, 0.75, 0.75, 1
						else
							r, g, b, a = 1 - progress, 0.7 * progress, 0, 1
						end
					else
						r, g, b, a = 0.267, 0.267, 0.267, 1
					end

					i2 = i2 + 1
					local control = GetControl("NSR_QUICK_MAIN_List_Row" .. i .. "_Skill" .. i2)
					control:SetText(rank)
					control:SetColor(r, g, b, a)

					-- Exit the loop early if we've reached the end of the available skills
					if i2 == 19 then
						break
					end
				end
			end

			-- Clear remaining skill cells if fewer than 19 skills are present
			for i2 = i2 + 1, 19 do
				local control = GetControl("NSR_QUICK_MAIN_List_Row" .. i .. "_Skill" .. i2)
				control:SetText("")
			end
		end
	end

	if page == 1 then
		local skillTypes = {SKILL_TYPE_CLASS, SKILL_TYPE_WEAPON, SKILL_TYPE_ARMOR, addon.SKILL_TYPE_TRADESKILL}
		updateRanks(skillTypes)
	elseif page == 2 then
		local skillTypes = {SKILL_TYPE_WORLD, SKILL_TYPE_GUILD, SKILL_TYPE_AVA}
		updateRanks(skillTypes)
	end
end

local function quick_UpdateList(page)
	selected_page = page

	-- Determine which control to show based on the selected page
	local showPage1 = (page == 1)

	-- Show/hide the appropriate controls
	local controlSkills1 = GetControl("NSR_QUICK_HEADER_Skills1")
	local controlSkills2 = GetControl("NSR_QUICK_HEADER_Skills2")
	controlSkills1:SetHidden(not showPage1)
	controlSkills2:SetHidden(showPage1)

	-- Update page textures based on the selected page
	local controlPage1 = GetControl("NSR_QUICK_PAGE_Page1")
	local controlPage2 = GetControl("NSR_QUICK_PAGE_Page2")
	if showPage1 then
		controlPage1:SetNormalTexture("/esoui/art/guild/tabicon_roster_down.dds")
		controlPage2:SetNormalTexture("/esoui/art/guild/tabicon_roster_up.dds")
	else
		controlPage1:SetNormalTexture("/esoui/art/guild/tabicon_roster_up.dds")
		controlPage2:SetNormalTexture("/esoui/art/guild/tabicon_roster_down.dds")
	end

	-- Update controls information based on selected page
	quick_CreateList(page)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function quick_CreateLines()
	for i = 0, 19 do
		local parent = "NSR_QUICK_HEADER"
		local control = GetControl(parent)
		control:CreateControl(parent .. "_line" .. i, CT_LINE)

		control = control:GetNamedChild("_line" .. i)
		control:SetColor(0.267, 0.267, 0.267, 1.0)
		control:SetPixelRoundingEnabled(true)
		control:SetThickness(2)

		local offsetX = i == 0 and 200 or i * 30 + 200
		control:SetAnchor(TOPLEFT, GetControl("NSR_QUICK_HEADER"), TOPLEFT, offsetX, 0)
		control:SetAnchor(BOTTOMLEFT, GetControl("NSR_QUICK_MAIN"), BOTTOMLEFT, offsetX, 0)
	end

	for i = 0, #addon.charData do
		local parent = "NSR_QUICK_MAIN"
		local control = GetControl(parent)
		control:CreateControl(parent .. "_line" .. i, CT_LINE)

		control = control:GetNamedChild("_line" .. i)
		control:SetColor(0.267, 0.267, 0.267, 1.0)
		control:SetPixelRoundingEnabled(true)
		control:SetThickness(2)

		local offsetY = i == 0 and 0 or i * 30
		control:SetAnchor(TOPLEFT, GetControl("NSR_QUICK_MAIN"), TOPLEFT, 10, offsetY)
		control:SetAnchor(TOPRIGHT, GetControl("NSR_QUICK_MAIN"), TOPRIGHT, 0, offsetY)
	end
end

local function quick_CreateControls()
	CreateControl("NSR_QUICK_MAIN_" .. "List", GetControl("NSR_QUICK_MAIN"), CT_CONTROL)
	local control = GetControl("NSR_QUICK_MAIN_List")
	control:SetAnchor(TOPLEFT, GetControl("NSR_QUICK_MAIN"), TOPLEFT, 0, 0)
	control:SetResizeToFitDescendents(true)

	local previous_control = control

	for i = 1, #addon.charData do
		CreateControl("NSR_QUICK_MAIN_List_Row" .. i, GetControl("NSR_QUICK_MAIN_List"), CT_CONTROL)

		local targetControl = previous_control
		local targetPos = i == 1 and TOPLEFT or BOTTOMLEFT
		local offsetX = i == 1 and 20 or 0
		control = GetControl("NSR_QUICK_MAIN_List_Row" .. i)
		control:SetAnchor(TOPLEFT, targetControl, targetPos, offsetX, 0)
		control:SetResizeToFitDescendents(true)
		control:SetDimensionConstraints(0, 30)

		previous_control = control
	end

	previous_control = nil

	for i = 1, #addon.charData do
		CreateControl("NSR_QUICK_MAIN_List_Row" .. i .. "_Name", GetControl("NSR_QUICK_MAIN_List_Row" .. i), CT_LABEL)
		local targetControl = i == 1 and GetControl("NSR_QUICK_MAIN_List_Row" .. i) or previous_control
		local targetPos = i == 1 and TOPLEFT or BOTTOMLEFT
		control = GetControl("NSR_QUICK_MAIN_List_Row" .. i .. "_Name")
		control:SetAnchor(TOPLEFT, targetControl, targetPos, 0, 0)
		control:SetDimensions(180, 30)
		control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		control:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		control:SetFont("ZoFontGameMedium")

		previous_control = control

		local previous_control_skill = nil

		for i2 = 1, 19 do
			CreateControl("NSR_QUICK_MAIN_List_Row" .. i .. "_Skill" .. i2, GetControl("NSR_QUICK_MAIN_List_Row" .. i), CT_LABEL)
			targetControl = previous_control_skill or previous_control
			control = GetControl("NSR_QUICK_MAIN_List_Row" .. i .. "_Skill" .. i2)
			control:SetAnchor(TOPLEFT, targetControl, TOPRIGHT, 0, 0)
			control:SetDimensions(30, 30)
			control:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
			control:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			control:SetFont("ZoFontGameMedium")

			previous_control_skill = control
		end
	end
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- unranked window functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

NEAR_SR.gui.unranked = {}
local unranked_abilities_name = ''
local unranked_abilities_rank = ''
local curses_text = ''
---------------------------------------------------------------------------------

local function unranked_setupControls()
	local scrollContainer = NSR_UNRANKED_MAIN:GetNamedChild("ScrollChild")
	local abilities = CreateControl(scrollContainer:GetName() .. "_Abilities", scrollContainer, CT_CONTROL)
	abilities:SetResizeToFitDescendents(true)
	abilities:SetAnchor(TOPLEFT, scrollContainer)

	local name = CreateControl(abilities:GetName() .. "_Name", abilities, CT_LABEL)
	name:SetAnchor(TOPLEFT, abilities)
	name:SetFont("ZoFontGameMedium")

	local rank = CreateControl(abilities:GetName() .. "_Rank", abilities, CT_LABEL)
	rank:SetAnchor(TOPLEFT, name, TOPRIGHT, 20)
	rank:SetFont("ZoFontGameMedium")

	local curse = CreateControl(abilities:GetName() .. "_Curses", abilities, CT_LABEL)
	curse:SetAnchor(TOPLEFT, name, BOTTOMLEFT)
	curse:SetFont("ZoFontGameMedium")
	curse:SetColor(0.68, 0, 0)
end

---------------------------------------------------------------------------------

local function getEquippedAbilities()
	local abilities = {}

	for hotbarCategory = 0, 1 do
		for slotIndex = 3, 8 do
			local hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(hotbarCategory)
			local slotData = hotbarData:GetSlotData(slotIndex)
			local abilityId = 0

			if not slotData:IsEmpty() then
				abilityId = slotData:GetEffectiveAbilityId()
			end

			abilities[abilityId] = true
		end
	end

	return abilities
end

local function handleVariants(equippedAbilities, morphData)
	if equippedAbilities[morphData.id] then return true end
	local i = 1
	while true do
		local variantId = morphData["id" .. i]
		if variantId == nil then break end
		if equippedAbilities[variantId] then return true end
		i = i + 1
	end
	return false
end

local function buildDataUnranked(sv_character, selectedChar_charId)
	unranked_abilities_name = ''
	unranked_abilities_rank = ''
	curses_text = ''
	local indent = '     '
	local colorEquipped = addon.utils.color.darkGreen
	local equippedAbilities = getEquippedAbilities()
	local discoveredVampirism = true
	local discoveredLycanthropy = true

	for skillTypeIndex, skillType in ipairs(sv_character) do
		if skillTypeIndex == NEAR_SR.SKILL_TYPE_TRADESKILL then break end

		local skillTypeHeaderAdded = false

		if skillTypeIndex == SKILL_TYPE_CLASS then
			for classId, classData in pairs(skillType) do
				for skillLineIndex, skillLine in ipairs(classData) do
					local skillLineHeaderAdded = false
					for abilityIndex = 1, 7 do
						if skillLine[abilityIndex] ~= nil then
							for morphIndex = 0, 2 do
								local morphRank = sv_character[skillTypeIndex][classId][skillLineIndex][abilityIndex][morphIndex]
								if morphRank < 4 then
									if not skillTypeHeaderAdded then
										if unranked_abilities_name ~= '' then
											unranked_abilities_name = unranked_abilities_name .. '\n'
											unranked_abilities_rank = unranked_abilities_rank .. '\n'
										end
										unranked_abilities_name = unranked_abilities_name .. 'Skill Type: ' .. skillTypesTable[skillTypeIndex]
										skillTypeHeaderAdded = true
									end

									if not skillLineHeaderAdded then
										unranked_abilities_name = unranked_abilities_name .. '\n' .. indent .. 'Skill Line: ' .. FormatSkilLineName(addon.skilldata[skillTypeIndex][classId][skillLineIndex].id) .. '\n'
										unranked_abilities_rank = unranked_abilities_rank .. '\n\n'
										skillLineHeaderAdded = true
									end

									local morphData = addon.skilldata[skillTypeIndex][classId][skillLineIndex][abilityIndex][morphIndex]

									if selectedChar_charId == GetCurrentCharacterId() and handleVariants(equippedAbilities, morphData) then
										unranked_abilities_name = unranked_abilities_name .. indent .. indent .. colorEquipped .. FormatAbilityName(morphData.id) .. '|r\n'
									else
										unranked_abilities_name = unranked_abilities_name .. indent .. indent .. FormatAbilityName(morphData.id) .. '\n'
									end

									unranked_abilities_rank = unranked_abilities_rank .. 'Rank: ' .. morphRank .. '\n'
								end
							end
						end
					end
				end
			end
		else
			for skillLineIndex, skillLine in ipairs(skillType) do
				local skillLineHeaderAdded = false

				if skillTypeIndex == SKILL_TYPE_WORLD and (skillLineIndex == 5 or skillLineIndex == 6) and sv_character[skillTypeIndex][skillLineIndex].discovered == false then
					if skillLineIndex == 5 then
						discoveredVampirism = false
					elseif skillLineIndex == 6 then
						discoveredLycanthropy = false
					end
				else
					for abilityIndex = 1, 7 do
						if skillLine[abilityIndex] ~= nil then
							for morphIndex = 0, 2 do
								local morphRank = sv_character[skillTypeIndex][skillLineIndex][abilityIndex][morphIndex]
								if morphRank < 4 then
									if not skillTypeHeaderAdded then
										if unranked_abilities_name ~= '' then
											unranked_abilities_name = unranked_abilities_name .. '\n'
											unranked_abilities_rank = unranked_abilities_rank .. '\n'
										end
										unranked_abilities_name = unranked_abilities_name .. 'Skill Type: ' .. skillTypesTable[skillTypeIndex]
										skillTypeHeaderAdded = true
									end

									if not skillLineHeaderAdded then
										unranked_abilities_name = unranked_abilities_name .. '\n' .. indent .. 'Skill Line: ' .. FormatSkilLineName(addon.skilldata[skillTypeIndex][skillLineIndex].id) .. '\n'
										unranked_abilities_rank = unranked_abilities_rank .. '\n\n'
										skillLineHeaderAdded = true
									end

									local morphData = addon.skilldata[skillTypeIndex][skillLineIndex][abilityIndex][morphIndex]

									if selectedChar_charId == GetCurrentCharacterId() and handleVariants(equippedAbilities, morphData) then
										unranked_abilities_name = unranked_abilities_name .. indent .. indent .. colorEquipped .. FormatAbilityName(morphData.id) .. '|r\n'
									else
										unranked_abilities_name = unranked_abilities_name .. indent .. indent .. FormatAbilityName(morphData.id) .. '\n'
									end

									unranked_abilities_rank = unranked_abilities_rank .. 'Rank: ' .. morphRank .. '\n'
								end
							end
						end
					end
				end
			end
		end
	end

	if unranked_abilities_name == '' then
		unranked_abilities_name = GetString(NEARSR_completed)
	end

	if discoveredVampirism == false then
		curses_text = GetString(NEARSR_vampirism)
	end

	if discoveredLycanthropy == false then
		if curses_text ~= '' then
			curses_text = curses_text .. '\n'
		end
		curses_text = curses_text .. GetString(NEARSR_lycanthropy)
	end
end

local function unranked_CreateList_abilities()
	local selectedChar_charId = addon.gui.selectedChar_charId

	local utils = addon.utils

	-- check if there is data for that character, if not, clear shown data and send warning message
	if addon.ASV.char[selectedChar_charId] == nil then
		d(utils.dbg.default .. GetString(NEARSR_nodata))

		unranked_abilities_name = utils.color.red .. GetString(NEARSR_nodata) .. "|r"
		unranked_abilities_rank = ''
		curses_text = ''
		return
	end

	buildDataUnranked(addon.ASV.char[selectedChar_charId], selectedChar_charId)
end

local function unranked_UpdateList_abilities()
	unranked_CreateList_abilities()

	local control = NSR_UNRANKED_MAIN:GetNamedChild("ScrollChild")
	control = control:GetNamedChild("_Abilities")

	control:GetNamedChild("_Name"):SetText(unranked_abilities_name)
	control:GetNamedChild("_Rank"):SetText(unranked_abilities_rank)
	control:GetNamedChild("_Curses"):SetText(curses_text)
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function SetSelectedChar(charName)
	for i = 1, #addon.charData do
		if charName == addon.charData[i].charName then
			addon.gui.selectedChar_charId = addon.charData[i].charId
			addon.gui.selectedChar_classId = addon.charData[i].classId
			break
		end
	end
end

local function gui_CreateList_Char(control)
	local sv = addon.ASV.settings

	control.comboBox = control.comboBox or ZO_ComboBox_ObjectFromContainer(control:GetNamedChild("_CharList"))
	local NSR_comboBox = control.comboBox

	addon.charNames = {}
	addon.charData = {}
	for k, _ in ipairs(sv.charInfo) do
		addon.charNames[k] = sv.charInfo[k].charName
		addon.charData[k] = {
			charId = sv.charInfo[k].charId,
			charName = sv.charInfo[k].charName,
			classId = sv.charInfo[k].classId,
		}

		if GetCurrentCharacterId() == addon.charData[k].charId then
			selectedChar_name = addon.charData[k].charName
			addon.gui.selectedChar_charId = addon.charData[k].charId
			addon.gui.selectedChar_classId = addon.charData[k].classId
		end
	end

	local function OnItemSelect(_, choiceText, choice)
		SetSelectedChar(choiceText)

		gui_UpdateList_SkillLine()
		gui_UpdateList_abilities()
		if GetControl(NSR_comboBox) ~= NSR_GUI_MAIN_skilldata_CharList then
			local ctrl = GetControl("NSR_GUI_MAIN_skilldata_CharListSelectedItemText")
			ctrl:SetText(choiceText)
		end

		unranked_UpdateList_abilities()
		if GetControl(NSR_comboBox) ~= NSR_UNRANKED_CharList then
			local ctrl = GetControl("NSR_UNRANKED_CharListSelectedItemText")
			ctrl:SetText(choiceText)
		end

		-- PlaySound(SOUNDS.POSITIVE_CLICK)
	end

	NSR_comboBox:SetSortsItems(false)

	for k, _ in ipairs(addon.charNames) do
		NSR_comboBox:AddItem(NSR_comboBox:CreateItemEntry(addon.charNames[k], OnItemSelect))
		if addon.charNames[k] == selectedChar_name then
			NSR_comboBox:SetSelectedItem(addon.charNames[k])
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

function NEAR_SR.gui.Init()
	gui_CreateList_Char(NSR_GUI_MAIN_skilldata)
	gui_CreateList_SkillType()
	gui_CreateList_SkillLine()

	local control = GetControl("NSR_GUI_MAIN_skilldata_ShowQuick")
	control:SetText(GetString(NEARSR_quick))

	addon.gui.quick.Init()
	addon.gui.unranked.Init()
end

-- Show or hide the window
function NEAR_SR.gui.ToggleWindow()
	NSR_GUI:ToggleHidden()
end

-- OnShow update window data
function NEAR_SR.gui.OnShow()
	gui_UpdateList_SkillLine()
	gui_UpdateList_abilities()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

function NEAR_SR.gui.quick.Init()
	quick_CreateControls()
	quick_CreateLines()
	quick_CreateListChar()
end

-- Show or hide the window
function NEAR_SR.gui.quick.ToggleWindow()
	NSR_QUICK:ToggleHidden()
end

-- OnShow update window data
function NEAR_SR.gui.quick.OnShow()
	if first_time then
		-- add a margin bellow
		local control = GetControl("NSR_QUICK")
		local current = control:GetHeight()
		control:SetHeight(current + 10)

		first_time = false
	end

	quick_UpdateList(selected_page)
end

function NEAR_SR.gui.quick.OnClicked(page)
	quick_UpdateList(page)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

function NEAR_SR.gui.unranked.Init()
	unranked_setupControls()
	gui_CreateList_Char(NSR_UNRANKED)
end

-- Show or hide the window
function NEAR_SR.gui.unranked.ToggleWindow()
	NSR_UNRANKED:ToggleHidden()
end

-- OnShow update window data
function NEAR_SR.gui.unranked.OnShow()
	unranked_UpdateList_abilities()
end
