-- TinydogsCraftingCalculator XP Calculator UI LUA File
-- Last Updated June 27, 2024 by @tinydog
-- Created October 2015 by @tinydog

local TCC_XP_TABLE_NAME = "XpTable"
local TCC_ENCHANTING_XP_TABLE_NAME = "EnchantingXpTable"
-- local TCC_ALCHEMY_XP_TABLE_NAME = "AlchemyXpTable"
-- local TCC_PROVISIONING_XP_TABLE_NAME = "ProvisioningXpTable"
local TCC_COL_SKILL_TIER = 1
local TCC_COL_NUM_XP_ITEMS = 2
local TCC_COL_MATS_PER_ITEM = 3
local TCC_COL_TOTAL_MATS = 4
local TCC_COL_COST_OF_MATERIALS = 5 
local TCC_COL_ENCH_POTENCY = 3
local TCC_COL_ENCH_ESSENCE = 4
local TCC_COL_ENCH_ASPECT = 5
local TCC_COL_ENCH_COST_OF_MATERIALS = 6
-- local TCC_COL_ALCH_SOLVENT = 3
-- local TCC_COL_ALCH_REAGENT = 4
-- local TCC_COL_PROV_EXAMPLE = 3
-- local TCC_COL_PROV_INGREDIENTS = 4
-- local TCC_COL_PROV_COST_OF_MATERIALS = 5
local TCC_CRAFTING_XP_NEEDED_LABEL = "% XP needed:"
--local TCC_CURRENT_SKILL_LEVEL_LABEL = "Current % skill level:"
local TCC_PASSIVES_TITLE = "% Passive Abilities"
local TCC_NUMBER_OF_ITEMS_LABEL = "Number of Items You Need\nTo %"
local TCC_QUALITY_TEXTURE_FOLDER = "TinydogsCraftingCalculator/images/quality/"

-- ESO Constants
local TCC_CHAMPION_SKILL_INDEX_INSPIRATION_BOOST = 72
local TCC_RACIAL_SKILLS_INDEX = 1
local TCC_RACIAL_SKILL_ORC_CRAFTSMAN_INDEX = 1

-- Race table courtesy Garkin.
local raceTable = {
   ["Breton"] = "breton",
   ["Bretone"] = "breton", --de, male
   ["Bretonin"] = "breton", --de, female
   ["Bréton"] = "breton", --fr, male
   ["Brétonne"] = "breton", --fr, female
   ["Orc"] = "orc",
   ["Ork"] = "orc", --de, male/female
   ["Orque"] = "orc", --fr, male/female
   ["Redguard"] = "redguard",
   ["Rothwardone"] = "redguard", --de, male
   ["Rothwardonin"] = "redguard", --de, female
   ["Rougegarde"] = "redguard", --fr, male/female
   ["High Elf"] = "altmer",
   ["Hochelf"] = "altmer", --de, male
   ["Hochelfin"] = "altmer", --de, female
   ["Haut-Elfe"] = "altmer", --fr, male
   ["Haute-Elfe"] = "altmer", --fr, female
   ["Wood Elf"] = "bosmer",
   ["Waldelf"] = "bosmer", --de, male
   ["Waldelfin"] = "bosmer", --de, female
   ["Elfe des bois"] = "bosmer", --fr, male/female
   ["Khajiit"] = "khajiit",
   ["Argonian"] = "argonian",
   ["Argonier"] = "argonian", --de, male
   ["Argonierin"] = "argonian", --de, female
   ["Argonien"] = "argonian", --fr, male
   ["Argonienne"] = "argonian", --fr, female
   ["Dark Elf"] = "dunmer",
   ["Dunkelelf"] = "dunmer", --de, male
   ["Dunkelelfin"] = "dunmer", --de, female
   ["Elfe Noir"] = "dunmer", --fr, male
   ["Elfe Noire"] = "dunmer", --fr, female
   ["Nord"] = "nord",
   ["Nordique"] = "nord", --fr, male/female
   ["Imperial"] = "imperial",
   ["Kaiserlicher"] = "imperial", --de, male
   ["Kaiserliche"] = "imperial", --de, female
   ["Impérial"] = "imperial", --fr, male
   ["Impériale"] = "imperial", --fr, female
}

function tcc_InitXPModifiers()
	-- tccInspBoostDropdown
	tcc_InitInspBoostDropdown(tccInspBoostControl)
	
	-- tccEsoPlusCheckbox
	tcc_InitCheckbox(tccEsoPlusCheckbox, tcc_PopulateXpTable, "ESO Plus?", "ESO Plus membership adds 10% to all XP/Inspiration", IsESOPlusSubscriber())
	
	-- tccOrcCraftsmanCheckbox
	local isOrc = (raceTable[GetUnitRace("player")] == "orc")
	local hasAbility = tcc_GetAbilityRank(SKILL_TYPE_RACIAL, TCC_RACIAL_SKILLS_INDEX, TCC_RACIAL_SKILL_ORC_CRAFTSMAN_INDEX)
	local hasCraftsman = (isOrc and hasAbility)
	tcc_InitCheckbox(tccOrcCraftsmanCheckbox, tcc_PopulateXpTable, "Orc Craftsman?", "The Craftsman Orcish racial skill adds 10% to Inspiration", hasCraftsman)
end

function tcc_InitInspBoostDropdown(rowControl)
	local inspBoostLabel = tcc_GetOrCreateControlFromVirtual(rowControl, "tccInspBoostLabel", "tccRowLabelTemplate")
	inspBoostLabel:ClearAnchors()
	inspBoostLabel:SetAnchor(TOPRIGHT, rowControl, TOPRIGHT, 0, 0)
	inspBoostLabel:SetText("Inspiration Boost?")
	local inspBoostDropdown = tcc_GetOrCreateControlFromVirtual(rowControl, "tccInspBoostDropdown", "tccDropdownTemplate")
	inspBoostDropdown:SetDimensions(40, 25)
	inspBoostDropdown:ClearAnchors()
	inspBoostDropdown:SetAnchor(BOTTOMRIGHT, rowControl, BOTTOMRIGHT, 0, 0)
	inspBoostDropdown.m_comboBox:SetSortsItems(false)
	inspBoostDropdown.m_comboBox:SetFont("tcc_ZoFontTooltipSubtitleSmall")
	local inspBoostDropdownLabel = tcc_GetOrCreateControlFromVirtual(rowControl, "tccInspBoostDropdownLabel", "tccRowLabelTemplate")
	inspBoostDropdownLabel:ClearAnchors()
	inspBoostDropdownLabel:SetAnchor(RIGHT, inspBoostDropdown, LEFT, -5, 0)
	inspBoostDropdownLabel:SetText("Stage:")
	local dropdown = ZO_ComboBox_ObjectFromContainer(inspBoostDropdown)
	dropdown:AddItem(dropdown:CreateItemEntry("0", function() tcc_PopulateXpTable() end))
	dropdown:AddItem(dropdown:CreateItemEntry("1", function() tcc_PopulateXpTable() end))
	dropdown:AddItem(dropdown:CreateItemEntry("2", function() tcc_PopulateXpTable() end))
	dropdown:AddItem(dropdown:CreateItemEntry("3", function() tcc_PopulateXpTable() end))
	dropdown:SetSelectedItem(tostring(math.floor(GetNumPointsSpentOnChampionSkill(TCC_CHAMPION_SKILL_INDEX_INSPIRATION_BOOST)/15)))
	tcc_RegisterTextTooltip(rowControl, "The Inspiration Boost champion skill (under Craft) increases Inspiration by 10% per stage")
end


function tcc_SelectCraft(craftName)
	tcc.CraftSelected = craftName
	tcc.SavedVars.Local.CraftSelected = craftName
	tcc_ExpandShrinkCalculatorWindow()
	tccChooseCraftBlacksmithing:SetDesaturation("Blacksmithing" == craftName and 0.0 or 1.0)
	tccChooseCraftClothing:SetDesaturation("Clothing" == craftName and 0.0 or 1.0)
	tccChooseCraftLeatherworking:SetDesaturation("Leatherworking" == craftName and 0.0 or 1.0)
	tccChooseCraftWoodworking:SetDesaturation("Woodworking" == craftName and 0.0 or 1.0)
	tccChooseCraftEnchanting:SetDesaturation("Enchanting" == craftName and 0.0 or 1.0)
	tccChooseCraftJewelry:SetDesaturation("Jewelry" == craftName and 0.0 or 1.0)
	-- tccChooseCraftAlchemy:SetDesaturation("Alchemy" == craftName and 0.0 or 1.0)
	-- tccChooseCraftProvisioning:SetDesaturation("Provisioning" == craftName and 0.0 or 1.0)
	tccCraftingXpNeededLabel:SetText(string.gsub(TCC_CRAFTING_XP_NEEDED_LABEL, "%%", craftName))
	-- tccXpCreateOrDeconRow:SetHidden(tcc.CraftSelected == "Alchemy" or tcc.CraftSelected == "Provisioning")
	tccXpItemQualityRow:SetHidden(tcc.CreateOrDeconSelected == "Create" and tcc.CraftSelected ~= "Enchanting") 
		--or tcc.CraftSelected == "Alchemy" or tcc.CraftSelected == "Provisioning")
	--if craftName == "Jewelry" then tcc_SelectXpQuality(tccXpItemQualityWhite, "White") end
	--if craftName == "Alchemy" or craftName == "Provisioning" then tcc_SelectCreateOrDecon(tccXpCreateButton, "Create") end
	tcc_UpdateCurrentCraftingSkillAndXp()
	tcc_UpdateXpNeededForDesiredSkillLevel()
	tcc_PopulateXpTable()
	-- Update Passives *after* populating the XP table, so its height can be adjusted properly.
	tccPassivesTitle:SetText(string.gsub(TCC_PASSIVES_TITLE, "%%", craftName))
	if tccPassivesInfoBox:IsHidden() == false then tcc_PopulatePassivesInfoBox() end
end

function tcc_UpdateCurrentCraftingSkillAndXp()
	local lastXp, nextXp, currentXp = GetSkillLineXPInfo(SKILL_TYPE_TRADESKILL, tcc.Crafts[tcc.CraftSelected].SkillIndex)
	tcc.Crafts[tcc.CraftSelected].CurrentXp = currentXp
	local skillLevel, progressXp = tcc_GetSkillLevelAndProgressFromXp(currentXp)
	tccCurrentCraftingSkillLevel:SetText(skillLevel)
	tccCurrentCraftingSkillLevelProgress:SetText(progressXp)
end

function tcc_ValidateCraftingSkillLevel(control)
	if control == nil then return false end
	local maxSkillLevels = table.getn(tcc.CraftingXpNeededForSkillLevel[tcc.CraftSelected])
	local skillLevel = tcc_EnforcePositiveIntegerValue(control)
	if skillLevel == nil or skillLevel < 1 then 
		control:SetText("")
		control:TakeFocus()
		return false
	elseif skillLevel > maxSkillLevels then
		skillLevel = maxSkillLevels
		control:SetText(maxSkillLevels)
	end
	local progressXp = tonumber(tccCurrentCraftingSkillLevelProgress:GetText())
	if progressXp == nil then
		tccCurrentCraftingSkillLevelProgress:SetText("0")
		progressXp = 0
	end
	local currentSkillLevel = tonumber(tccCurrentCraftingSkillLevel:GetText())
	local desiredSkillLevel = tonumber(tccDesiredCraftingSkillLevel:GetText())
	if currentSkillLevel ~= nil and desiredSkillLevel ~= nil then 
		tcc.Crafts[tcc.CraftSelected].CurrentXp = tcc_GetXpForCraftingSkillLevel(currentSkillLevel) + progressXp
		tcc_UpdateXpNeededForDesiredSkillLevel()
		tcc_PopulateXpTable()
	end
	return true
end

function tcc_ValidateCraftingSkillLevelProgress(control)
	if control == nil then return false end
	local progressXp = tcc_EnforcePositiveIntegerValue(control)
	if progressXp == nil then
		control:SetText("0")
		progressXp = 0
	end
	if progressXp < 0 then
		control:SetText("")
		control:TakeFocus()
		return false
	end
	progressXp = math.ceil(progressXp)
	control:SetText(progressXp)
	local currentSkillLevel = tonumber(tccCurrentCraftingSkillLevel:GetText())
	local desiredSkillLevel = tonumber(tccDesiredCraftingSkillLevel:GetText())
	if currentSkillLevel ~= nil and desiredSkillLevel ~= nil then 
		tcc.Crafts[tcc.CraftSelected].CurrentXp = tcc_GetXpForCraftingSkillLevel(currentSkillLevel) + progressXp
		tcc_UpdateXpNeededForDesiredSkillLevel()
		tcc_PopulateXpTable()
	end
	return true
end

function tcc_UpdateXpNeededForDesiredSkillLevel()
	local desiredSkillLevel = tonumber(tccDesiredCraftingSkillLevel:GetText()) --tccDesiredCraftingSkillLevelSlider:GetValue()
	local targetXp = tcc_GetXpForCraftingSkillLevel(desiredSkillLevel)
	if targetXp <= tcc.Crafts[tcc.CraftSelected].CurrentXp then
		tccDesiredCraftingSkillLevelXpNeeded:SetText("None!")
		tccCraftingXpNeeded:SetText("")
	else
		tccDesiredCraftingSkillLevelXpNeeded:SetText(tcc_CommaValue(targetXp - tcc.Crafts[tcc.CraftSelected].CurrentXp))
		tccCraftingXpNeeded:SetText(targetXp - tcc.Crafts[tcc.CraftSelected].CurrentXp)
	end
	if tccPassivesInfoBox:IsHidden() == false then tcc_PopulatePassivesInfoBox() end
	tcc_PopulateXpTable()
end

function tcc_TogglePassivesInfoBox()
	tccPassivesInfoBox:SetHidden(tccPassivesInfoBox:IsHidden() == false)
	tccTogglePassivesButton:SetText((tccPassivesInfoBox:IsHidden() and "Show" or "Hide") .. " Passives")
	if tccPassivesInfoBox:IsHidden() == false then tcc_PopulatePassivesInfoBox() end
end

function tcc_PopulatePassivesInfoBox()
	-- tcc_CraftingPassiveObj(nameGeneric, name, description, texture, rankAvailableAtSkillLevelArray)
	local child, row, rowLabel, icon, iconTexture, rankTbl, colWidths
	local currentRank, cellLabel
	local currentSkillLevel = tonumber(tccCurrentCraftingSkillLevel:GetText())
	if currentSkillLevel == nil then currentSkillLevel = 0 end
	local anchor = tccPassivesFrame
	-- Hide any existing info
	if tccPassivesFrame:GetNumChildren() > 0 then
		for i = 1, tccPassivesFrame:GetNumChildren() do
			tccPassivesFrame:GetChild(i):SetHidden(true)
		end
	end
	for abilityIndex, passive in ipairs(tcc.Crafts[tcc.CraftSelected].Passives) do
		name = passive.Name
		row = tcc_GetOrCreateControl(tccPassivesFrame, "tccPassive" .. name, CT_CONTROL)
		row:SetAnchor(TOPLEFT, anchor, (anchor == tccPassivesFrame and TOPLEFT or BOTTOMLEFT), 0, (anchor == tccPassivesFrame and 15 or 10))
		row:SetDimensions(tccPassivesFrame:GetWidth(), 64)
		row:SetHidden(false)
		anchor = row
		icon = tcc_GetOrCreateControl(row, row:GetName() .. "Icon", CT_BUTTON)
		icon:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
		icon:SetDimensions(50, 50)
        icon:SetNormalTexture("EsoUI/Art/ActionBar/passiveAbilityFrame_round_up.dds")
        icon:SetPressedTexture("EsoUI/Art/ActionBar/passiveAbilityFrame_round_up.dds")
        icon:SetMouseOverTexture(nil)
        icon:SetDisabledTexture("EsoUI/Art/ActionBar/passiveAbilityFrame_round_up.dds")
		iconTexture = tcc_GetOrCreateControl(icon, icon:GetName() .. "Texture", CT_TEXTURE)
		iconTexture:SetAnchor(TOPLEFT, icon, TOPLEFT, 0, 0)
		iconTexture:SetDimensions(50, 50)
		iconTexture:SetTexture(passive.Texture)
		tcc_RegisterSkillAbilityTooltip(icon, SKILL_TYPE_TRADESKILL, tcc.Crafts[tcc.CraftSelected].SkillIndex, abilityIndex)
		rowLabel = tcc_GetOrCreateControl(row, row:GetName() .. "Label", CT_LABEL)
		rowLabel:SetAnchor(TOPLEFT, icon, TOPRIGHT, 5, -15)
		rowLabel:SetFont("tcc_ZoFontBookRubbingSmallShadow")
		rowLabel:SetColor(1, 1, 1, 1)
		rowLabel:SetText(passive.Name)
		colWidths = {159}
		for i = 1, table.getn(passive.RankAvailableAtSkillLevelArray) do
			table.insert(colWidths, 27)
		end
		rankTbl = tcc_DrawTable(row, row:GetName() .. "Ranks", 2, colWidths, false)
		rankTbl:SetAnchor(TOPLEFT, rowLabel, BOTTOMLEFT, 0, 1)
		rankTbl.CellLabels[1][1]:SetText("Ability rank:")
		rankTbl.CellLabels[2][1]:SetText("Available at skill level:")
		for rank, skillLevel in ipairs(passive.RankAvailableAtSkillLevelArray) do
			currentRank = tcc_GetCurrentAbilityRank(SKILL_TYPE_TRADESKILL, tcc.Crafts[tcc.CraftSelected].SkillIndex, abilityIndex)
			-- If there's only one tier of skill rank (e.g., Alchemy's Laboratory Use), then we have to use a different method of determining whether the player has it.
			if currentRank == nil then
				--currentRank = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(SKILL_TYPE_TRADESKILL, tcc.Crafts[tcc.CraftSelected].SkillIndex).orderedSkills[abilityIndex].isPurchased == true and 1 or 0
				currentRank = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(SKILL_TYPE_TRADESKILL, tcc.Crafts[tcc.CraftSelected].SkillIndex).orderedSkills[abilityIndex]:GetNumPointsAllocated()
			end
			cellLabel = rankTbl.CellLabels[1][rank+1]
			if currentRank >= rank then 
				cellLabel:SetColor(0, 1, 0, 1) 
				tcc_RegisterTextTooltip(cellLabel:GetParent(), "You have purchased this rank")
			else 
				cellLabel:SetColor(0.81, 0.86, 0.74, 1) 
				tcc_RegisterTextTooltip(cellLabel:GetParent(), "You have not yet purchased this rank")
			end
			cellLabel:SetText(rank)
			cellLabel = rankTbl.CellLabels[2][rank+1]
			cellLabel:SetFont("tcc_ZoFontWindowSubtitleSmall")
			if currentSkillLevel >= skillLevel then cellLabel:SetColor(0, 1, 0, 1) else cellLabel:SetColor(0.81, 0.86, 0.74, 1) end
			cellLabel:SetText(skillLevel)
			tcc_RegisterTextTooltip(cellLabel, "Set desired skill level to " .. skillLevel, true)
			cellLabel:SetHandler("OnMouseDown", function() 
					tccDesiredCraftingSkillLevel:SetText(skillLevel)
					tcc_UpdateXpNeededForDesiredSkillLevel()
				end)
		end
	end
	tccPassivesInfoBox:SetHeight(tcc_GetLastVisibleChild(tccPassivesFrame):GetBottom() - tccPassivesInfoBox:GetTop())
end

function tcc_SelectCreateOrDecon(control, createOrDecon)
	tcc.CreateOrDeconSelected = createOrDecon
	tccXpCreateButton:SetNormalTexture(string.gsub(tcc.TexturePaths["Create"], "%%", ((createOrDecon == "Create") and "down" or "up")))
	tccXpDeconButton:SetNormalTexture(string.gsub(tcc.TexturePaths["Deconstruct"], "%%", ((createOrDecon == "Deconstruct") and "down" or "up")))
	tccXpItemQualityRow:SetHidden(createOrDecon == "Create" and tcc.CraftSelected ~= "Enchanting")
	if createOrDecon == "Create" and tcc.CraftSelected ~= "Enchanting" then
		tcc_SelectXpQuality(tccXpItemQualityWhite, "White")
	else
		tcc_PopulateXpTable()
	end
end

function tcc_SelectXpQuality(control, quality)
	tcc.XpQualitySelected = tcc.ItemQuality[quality]
	tccXpItemQualityWhite:SetNormalTexture(TCC_QUALITY_TEXTURE_FOLDER .. "white_" .. (quality == "White" and "down" or "up") .. ".dds")
	tccXpItemQualityGreen:SetNormalTexture(TCC_QUALITY_TEXTURE_FOLDER .. "green_" .. (quality == "Green" and "down" or "up") .. ".dds")
	tccXpItemQualityBlue:SetNormalTexture(TCC_QUALITY_TEXTURE_FOLDER .. "blue_" .. (quality == "Blue" and "down" or "up") .. ".dds")
	tccXpItemQualityPurple:SetNormalTexture(TCC_QUALITY_TEXTURE_FOLDER .. "purple_" .. (quality == "Purple" and "down" or "up") .. ".dds")
	tcc_PopulateXpTable()
end


--[[ Equipment Table Functions ]]--

function tcc_InitCraftingXpTable()
	local tbl
	local numRows = 11 --1 + table.getn(tcc.Crafts[tcc.CraftSelected].CraftingXp)
	local row = 1
	if tcc.Tables == nil then tcc.Tables = {} end
	if tcc.Tables[TCC_XP_TABLE_NAME] == nil then
		local colWidths
		if tcc.IntegrateMM then
			colWidths = {45, 265, 130, 152, 86}
		else
			colWidths = {45, 265, 130, 152}
		end
		tbl = tcc_DrawTable(tccXpTableFrame, TCC_XP_TABLE_NAME, numRows, colWidths, true)
	else
		tbl = tcc.Tables[TCC_XP_TABLE_NAME]
	end
	tbl.CellLabels[row][TCC_COL_SKILL_TIER]:SetText("Skill\nTier")
	tbl.CellLabels[row][TCC_COL_NUM_XP_ITEMS]:SetText(string.gsub(TCC_NUMBER_OF_ITEMS_LABEL, "%%", tcc.CreateOrDeconSelected))
	tbl.CellLabels[row][TCC_COL_MATS_PER_ITEM]:SetText("Materials To\nCraft Each Item")
	tbl.CellLabels[row][TCC_COL_TOTAL_MATS]:SetText("Total Materials\nFor All Items")
	if tcc.IntegrateMM then
		tbl.CellLabels[row][TCC_COL_COST_OF_MATERIALS]:SetText("|cFF00FFCost*|r of\nMaterials")
		tcc_RegisterTextTooltip(tbl.CellLabels[row][TCC_COL_COST_OF_MATERIALS], "* Based on the average price reported by\n   Master Merchant")
	end
	for skillTier = 1, 10 do
		row = row + 1
		tbl.CellLabels[row][TCC_COL_SKILL_TIER]:SetText(skillTier)
		tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_NUM_XP_ITEMS])
		tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_MATS_PER_ITEM])
		tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_TOTAL_MATS])
		if tcc.IntegrateMM then 
			tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_COST_OF_MATERIALS])
		end
		tcc_SetRowHidden(tbl, row, row > table.getn(tcc.Crafts[tcc.CraftSelected].CraftingXp) + 1)
	end
	tcc_ExpandShrinkCalculatorWindow()
end

function tcc_PopulateXpTable()
	local xpNeeded = tcc_EnforcePositiveIntegerValue(tccCraftingXpNeeded)
	if tcc.CraftSelected == "Enchanting" then
		tcc_PopulateEnchantingXpTable()
		return
	end
	-- if tcc.CraftSelected == "Alchemy" then
		-- tcc_PopulateAlchemyXpTable()
		-- return
	-- end
	-- if tcc.CraftSelected == "Provisioning" then
		-- tcc_PopulateProvisioningXpTable()
		-- return
	-- end
	local craftName = tcc.CraftSelected
	tcc_InitCraftingXpTable()
	if tcc.Tables[TCC_ENCHANTING_XP_TABLE_NAME] ~= nil then tcc.Tables[TCC_ENCHANTING_XP_TABLE_NAME]:SetHidden(true) end
	-- if tcc.Tables[TCC_ALCHEMY_XP_TABLE_NAME] ~= nil then tcc.Tables[TCC_ALCHEMY_XP_TABLE_NAME]:SetHidden(true) end
	-- if tcc.Tables[TCC_PROVISIONING_XP_TABLE_NAME] ~= nil then tcc.Tables[TCC_PROVISIONING_XP_TABLE_NAME]:SetHidden(true) end
	tcc.Tables[TCC_XP_TABLE_NAME]:SetHidden(false)

	-- Stop here if no xpNeeded
	if xpNeeded == nil or xpNeeded == "" then
		tccCraftingXpNeeded:TakeFocus()
		return
	end

	local itemLevel, numItems, material
	local currentSkillLevel, desiredSkillLevel, xpNeededForNextLevel, xpPerItemAdjusted, numItemsForSkillLevel
	local progressXpCurrentLevel, xpMax, xpNew, xpOverflowToNextLvl, numItemsUnadjusted, numItemsWasted
	local craft = tcc.Crafts[craftName]
	local itemType = tcc.ItemTypes[craft.OptimalItemType]
	-- Inspiration Boost adds 10% inspiration per stage, stages 1-3; 0 means no bonus.
	local inspirationBoostMultiplier = 1 + (tonumber("0." .. tccInspBoostDropdown.m_comboBox.currentSelectedItemText))
	local esoPlusMultiplier = (ZO_CheckButton_IsChecked(tccEsoPlusCheckbox) and 1.1 or 1)
	local orcCraftsmanMultiplier = (ZO_CheckButton_IsChecked(tccOrcCraftsmanCheckbox) and 1.1 or 1)
	local multiplier = inspirationBoostMultiplier * esoPlusMultiplier * orcCraftsmanMultiplier
	local currentSkillLevel = tonumber(tccCurrentCraftingSkillLevel:GetText())
	local desiredSkillLevel = tonumber(tccDesiredCraftingSkillLevel:GetText())
	local progressXp = tonumber(tccCurrentCraftingSkillLevelProgress:GetText())
	for skillTier, craftingXp in pairs(craft.CraftingXp) do
		itemLevel = tcc_ItemLevelByName(craftingXp.OptimalItemLvl)
		material = tcc_GetMaterialsNeededForItem(itemLevel, itemType).BaseMaterial
		xpPerItem = craftingXp[tcc.CreateOrDeconSelected .. "Xp" .. (tcc.CreateOrDeconSelected == "Deconstruct" and tcc.XpQualitySelected.Key or "")]
		xpPerItem = math.floor(xpPerItem * multiplier)
		numItems = 0
		numItemsWasted = 0
		
		-- Only populate the cells in this row if there's a positive XP value.
			
		if xpPerItem > 0 then
			-- Default values, assuming there is no max decon XP cap involved.
			numItems = math.ceil(xpNeeded / xpPerItem)
			numItemsUnadjusted = numItems

			-- If the decon XP for this item exceeds the MaxXpPerDecon for the player's current skill level, 
			-- step through each of the skill levels one by one and determine how many items are required.
			if craft.MaxXpPerDecon ~= nil and craft.MaxXpPerDecon[currentSkillLevel] ~= nil then 
				xpMax = math.floor(craft.MaxXpPerDecon[currentSkillLevel] * multiplier)
				if xpMax <= xpPerItem then 
					numItems = 0
					progressXpCurrentLevel = progressXp
					for skillLevel = currentSkillLevel, desiredSkillLevel - 1 do
						xpNeededForNextLevel = tcc.CraftingXpNeededForSkillLevel[tcc.CraftSelected][skillLevel + 1] - progressXpCurrentLevel
						xpPerItemAdjusted = xpPerItem
						if craft.MaxXpPerDecon[skillLevel] ~= nil then
							xpMax = math.floor(craft.MaxXpPerDecon[skillLevel] * multiplier)
							if xpMax <= xpPerItem then xpPerItemAdjusted = xpMax end
						end
						numItemsForSkillLevel = math.ceil(xpNeededForNextLevel / xpPerItemAdjusted)
						numItems = numItems + numItemsForSkillLevel
						xpNew = numItemsForSkillLevel * xpPerItemAdjusted
						xpOverflowToNextLvl = xpNew - xpNeededForNextLevel
						progressXpCurrentLevel = xpOverflowToNextLvl
					end
				end
			end
			
			if numItemsUnadjusted < numItems then
				numItemsWasted = numItems - numItemsUnadjusted
			else
				numItemsWasted = 0
			end
		
			totalMatQty = material.MaterialQuantity * numItems
			tcc_PopulateXpCell_NumberOfItems(skillTier, itemLevel, craftingXp, numItems, numItemsWasted)
			tcc_PopulateXpCell_PerItemMaterials(craftName, skillTier, itemLevel, material.MaterialQuantity, material.MaterialLink, material.MaterialTexture)
			tcc_PopulateXpCell_TotalMaterials(craftName, skillTier, totalMatQty, material.MaterialLink, material.MaterialTexture, numItems)
			if tcc.IntegrateMM then tcc_PopulateXpCell_CostOfMaterials(craftName, skillTier, numItems, totalMatQty, material.MaterialLink) end
		end
	
	end  -- next skillTier, craftingXp
	if tcc.IntegrateMM then tcc_HighlightLowestValueInTableColumn(tcc.Tables[TCC_XP_TABLE_NAME], TCC_COL_COST_OF_MATERIALS) end
end

function tcc_PopulateXpCell_NumberOfItems(skillTier, itemLevel, craftingXp, numItems, numItemsWasted)
	local cellLabel, itemQtyLabel, itemLvlLabel, itemLinkLabel
	cellLabel = tcc.Tables[TCC_XP_TABLE_NAME].CellLabels[tonumber(skillTier)+1][TCC_COL_NUM_XP_ITEMS]
	itemQtyLabel = tcc_GetOrCreateControl(cellLabel, cellLabel:GetName() .. "_ItemQty", CT_LABEL)
	itemQtyLabel:ClearAnchors()
	itemQtyLabel:SetAnchor(TOPLEFT, cellLabel, TOPLEFT, 0, 0)
	itemQtyLabel:SetFont(tcc.FONT_TABLE_CELL_HEAVY)
	if numItemsWasted > 0 then
		itemQtyLabel:SetText("|cFF0000" .. tcc_CommaValue(numItems) .. "*|r")
		local itemQtyTooltip = "Item level/quality is too high to receive full decon XP at current skill level " .. tccCurrentCraftingSkillLevel:GetText() .. "!\n" .. tostring(numItemsWasted) .. " more items have been added to the total, to make up the difference."
		tcc_RegisterTextTooltip(itemQtyLabel, itemQtyTooltip)
	else
		itemQtyLabel:SetText("|c00FF00" .. tcc_CommaValue(numItems) .. "|r")
		tcc_UnregisterTooltip(itemQtyLabel)
	end
	itemLvlLabel = tcc_GetOrCreateControl(cellLabel, cellLabel:GetName() .. "_ItemLevel", CT_LABEL)
	itemLvlLabel:ClearAnchors()
	itemLvlLabel:SetAnchor(LEFT, itemQtyLabel, RIGHT, 4, 0)
	itemLvlLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	itemLvlLabel:SetColor(0.81, 0.86, 0.74, 1)
	itemLvlLabel:SetText("Level |cFFFF00" .. itemLevel.ItemLevel .. "|r")
	itemLinkLabel = tcc_GetOrCreateControlFromVirtual(cellLabel, cellLabel:GetName() .. "_ItemLink", "tccLinkEnabledLabelTemplate")
	itemLinkLabel:ClearAnchors()
	itemLinkLabel:SetAnchor(LEFT, itemLvlLabel, RIGHT, 4, 0)
	itemLinkLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	itemLinkLabel:SetText(craftingXp["ItemLink" .. tcc.XpQualitySelected.Key])
	tcc_RegisterItemTooltip(itemLinkLabel, craftingXp["ItemLink" .. tcc.XpQualitySelected.Key])
end

function tcc_PopulateXpCell_PerItemMaterials(craftName, skillTier, itemLevel, materialQty, materialLink, materialTexture)
	local matsPerItemText, matsPerItemTooltip, matsPerItemFont, minimumLevel
	if craftName ~= "Jewelry" then
		minimumLevel = tcc.ItemMaterials[tonumber(skillTier)].MinimumLevel
	else
		minimumLevel = tcc.JewelryItemMaterials[tonumber(skillTier)].MinimumLevel
	end
	if itemLevel.ItemLevel ~= minimumLevel then		-- Non-default mat quantity
		matsPerItemText = "|cFF00FF" .. tcc_CommaValue(materialQty) .. "*|r"
		matsPerItemTooltip = "* Non-Default Quantity"
		matsPerItemFont = tcc.FONT_TABLE_CELL_HEAVY
	else
		matsPerItemText = "|c00FF00" .. tcc_CommaValue(materialQty) .. "|r"
		matsPerItemTooltip = ""
		matsPerItemFont = tcc.FONT_TABLE_CELL_MEDIUM
	end
	local cellLabel = tcc.Tables[TCC_XP_TABLE_NAME].CellLabels[tonumber(skillTier)+1][TCC_COL_MATS_PER_ITEM]
	local materialQtyLabel = tcc_GetOrCreateControl(cellLabel, cellLabel:GetName() .. "_MatQty", CT_LABEL)
	materialQtyLabel:ClearAnchors()
	materialQtyLabel:SetAnchor(TOPLEFT, cellLabel, TOPLEFT, 0, 0)
	materialQtyLabel:SetFont(matsPerItemFont)
	materialQtyLabel:SetText(matsPerItemText)
	materialQtyLabel:SetDimensions(24, 16)
	local materialIcon, materialIconTexture = tcc_CreateLinkEnabledIcon(cellLabel, cellLabel:GetName() .. "_MatIcon", materialLink, materialTexture, 20, 20, LEFT, materialQtyLabel, RIGHT, 0, 1)
	if matsPerItemTooltip ~= "" then
		tcc_RegisterTextTooltip(materialQtyLabel, matsPerItemTooltip)
	else
		tcc_UnregisterTooltip(materialQtyLabel)
	end
	-- Per Item Tempers Needed
	local tooltipText, greenIcon, greenIconTexture, blueIcon, blueIconTexture, purpleIcon, purpleIconTexture
	if tcc.XpQualitySelected.Index >= 2 then  -- At least Green quality
		local greenQtyLabel = tcc_GetOrCreateControl(cellLabel, cellLabel:GetName() .. "_GreenQty", CT_LABEL)
		greenQtyLabel:ClearAnchors()
		greenQtyLabel:SetAnchor(LEFT, materialIcon, RIGHT, 5, 0)
		greenQtyLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
		greenQtyLabel:SetColor(0.81, 0.86, 0.74, 1)
		greenQtyLabel:SetText("+") -- |c00FF00" .. tcc.QualityMats[craftName]["Green"].MaterialQuantity .. "|r")
		tooltipText = "|c00FF00" .. tcc.QualityMats[craftName]["Green"].MaterialQuantity .. "|r " .. tcc.QualityMats[craftName]["Green"].MaterialName
		greenIcon, greenIconTexture = tcc_CreateLinkEnabledIcon(cellLabel, cellLabel:GetName() .. "_GreenIcon", tcc.QualityMats[craftName]["Green"].MaterialLink, tcc.QualityMats[craftName]["Green"].MaterialTexture, 20, 20, LEFT, greenQtyLabel, RIGHT, 1, 0, tooltipText)
	end
	if tcc.XpQualitySelected.Index >= 3 then  -- At least Blue quality
		tooltipText = "|c00FF00" .. tcc.QualityMats[craftName]["Blue"].MaterialQuantity .. "|r " .. tcc.QualityMats[craftName]["Blue"].MaterialName
		blueIcon, blueIconTexture = tcc_CreateLinkEnabledIcon(cellLabel, cellLabel:GetName() .. "_BlueIcon", tcc.QualityMats[craftName]["Blue"].MaterialLink, tcc.QualityMats[craftName]["Blue"].MaterialTexture, 20, 20, LEFT, greenIconTexture, RIGHT, 1, 0, tooltipText)
	end
	if tcc.XpQualitySelected.Index >= 4 then  -- At least Purple quality
		tooltipText = "|c00FF00" .. tcc.QualityMats[craftName]["Purple"].MaterialQuantity .. "|r " .. tcc.QualityMats[craftName]["Purple"].MaterialName
		purpleIcon, purpleIconTexture = tcc_CreateLinkEnabledIcon(cellLabel, cellLabel:GetName() .. "_PurpleIcon", tcc.QualityMats[craftName]["Purple"].MaterialLink, tcc.QualityMats[craftName]["Purple"].MaterialTexture, 20, 20, LEFT, blueIconTexture, RIGHT, 1, 0, tooltipText)
	end
end

function tcc_PopulateXpCell_TotalMaterials(craftName, skillTier, totalMatQty, materialLink, materialTexture, numItems)
	local cellLabel = tcc.Tables[TCC_XP_TABLE_NAME].CellLabels[tonumber(skillTier)+1][TCC_COL_TOTAL_MATS]
	local totalMaterialQtyLabel = tcc_GetOrCreateControl(cellLabel, cellLabel:GetName() .. "_MatQty", CT_LABEL)
	totalMaterialQtyLabel:ClearAnchors()
	totalMaterialQtyLabel:SetAnchor(TOPLEFT, cellLabel, TOPLEFT, 0, 0)
	totalMaterialQtyLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	totalMaterialQtyLabel:SetText("|c00FF00" .. tcc_CommaValue(totalMatQty) .. "|r")
	if skillTier == 1 then 	-- Tier 1 will always require the largest quantity of materials, and thus the widest label.
		tcc.totalMaterialQtyWidth = totalMaterialQtyLabel:GetWidth() 
	else
		totalMaterialQtyLabel:SetDimensions(tcc.totalMaterialQtyWidth, 20)
	end
	local totalMaterialIcon, totalMaterialIconTexture = tcc_CreateLinkEnabledIcon(cellLabel, cellLabel:GetName() .. "_MatIcon", materialLink, materialTexture, 20, 20, LEFT, totalMaterialQtyLabel, RIGHT, 4, -1)
	-- Total Tempers Needed
	local tooltipText, totalGreenIcon, totalGreenIconTexture, totalBlueIcon, totalBlueIconTexture, totalPurpleIcon, totalPurpleIconTexture
	if tcc.XpQualitySelected.Index >= 2 then  -- At least Green quality
		local totalGreenQtyLabel = tcc_GetOrCreateControl(cellLabel, cellLabel:GetName() .. "_GreenQty", CT_LABEL)
		totalGreenQtyLabel:ClearAnchors()
		totalGreenQtyLabel:SetAnchor(LEFT, totalMaterialIcon, RIGHT, 5, 0)
		totalGreenQtyLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
		totalGreenQtyLabel:SetColor(0.81, 0.86, 0.74, 1)
		totalGreenQtyLabel:SetText("+") -- |c00FF00" .. tcc_CommaValue(tcc.QualityMats[craftName]["Green"].MaterialQuantity * numItems) .. "|r")
		--if skillTier == 1 then 	-- Tier 1 will always require the largest quantity of materials, and thus the widest label.
		--	tcc.totalGreenQtyWidth = totalGreenQtyLabel:GetWidth() 
		--else
		--	totalGreenQtyLabel:SetDimensions(tcc.totalGreenQtyWidth, 20)
		--end
		tooltipText = "|c00FF00" .. tcc_CommaValue(tcc.QualityMats[craftName]["Green"].MaterialQuantity * numItems) .. "|r " .. tcc.QualityMats[craftName]["Green"].MaterialName
		totalGreenIcon, totalGreenIconTexture = tcc_CreateLinkEnabledIcon(cellLabel, cellLabel:GetName() .. "_GreenIcon", tcc.QualityMats[craftName]["Green"].MaterialLink, tcc.QualityMats[craftName]["Green"].MaterialTexture, 20, 20, LEFT, totalGreenQtyLabel, RIGHT, 1, 0, tooltipText)
	end
	if tcc.XpQualitySelected.Index >= 3 then  -- At least Blue quality
		tooltipText = "|c00FF00" .. tcc_CommaValue(tcc.QualityMats[craftName]["Blue"].MaterialQuantity * numItems) .. "|r " .. tcc.QualityMats[craftName]["Blue"].MaterialName
		totalBlueIcon, totalBlueIconTexture = tcc_CreateLinkEnabledIcon(cellLabel, cellLabel:GetName() .. "_BlueIcon", tcc.QualityMats[craftName]["Blue"].MaterialLink, tcc.QualityMats[craftName]["Blue"].MaterialTexture, 20, 20, LEFT, totalGreenIconTexture, RIGHT, 1, 0, tooltipText)
	end
	if tcc.XpQualitySelected.Index >= 4 then  -- At least Purple quality
		tooltipText = "|c00FF00" .. tcc_CommaValue(tcc.QualityMats[craftName]["Purple"].MaterialQuantity * numItems) .. "|r " .. tcc.QualityMats[craftName]["Purple"].MaterialName
		totalPurpleIcon, totalPurpleIconTexture = tcc_CreateLinkEnabledIcon(cellLabel, cellLabel:GetName() .. "_PurpleIcon", tcc.QualityMats[craftName]["Purple"].MaterialLink, tcc.QualityMats[craftName]["Purple"].MaterialTexture, 20, 20, LEFT, totalBlueIconTexture, RIGHT, 1, 0, tooltipText)
	end
end

function tcc_PopulateXpCell_CostOfMaterials(craftName, skillTier, numItems, totalMatQty, materialLink)
	local totalCost, totalCostText
	local avgPrice = MasterMerchant:itemStats(materialLink)["avgPrice"]
	if avgPrice == nil then
		totalCostText = "?"
	else
		totalCost = totalMatQty * math.ceil(avgPrice)
		if tcc.XpQualitySelected.Index >= 2 then  -- At least Green quality
			avgPrice = MasterMerchant:itemStats(tcc.QualityMats[craftName]["Green"].MaterialLink)["avgPrice"]
			if avgPrice ~= nil then 
				totalCost = totalCost + (tcc.QualityMats[craftName]["Green"].MaterialQuantity * numItems * math.ceil(avgPrice)) 
			end
		end
		if tcc.XpQualitySelected.Index >= 3 then  -- At least Blue quality
			avgPrice = MasterMerchant:itemStats(tcc.QualityMats[craftName]["Blue"].MaterialLink)["avgPrice"]
			if avgPrice ~= nil then 
				totalCost = totalCost + (tcc.QualityMats[craftName]["Blue"].MaterialQuantity * numItems * math.ceil(avgPrice)) 
			end
		end
		if tcc.XpQualitySelected.Index >= 4 then  -- At least Purple quality
			avgPrice = MasterMerchant:itemStats(tcc.QualityMats[craftName]["Purple"].MaterialLink)["avgPrice"]
			if avgPrice ~= nil then 
				totalCost = totalCost + (tcc.QualityMats[craftName]["Purple"].MaterialQuantity * numItems * math.ceil(avgPrice)) 
			end
		end
		totalCostText = tcc_CommaValue(tostring(totalCost)) .. "g"
	end
	tcc.Tables[TCC_XP_TABLE_NAME].CellLabels[tonumber(skillTier)+1][TCC_COL_COST_OF_MATERIALS].Value = totalCost
	tcc.Tables[TCC_XP_TABLE_NAME].CellLabels[tonumber(skillTier)+1][TCC_COL_COST_OF_MATERIALS]:SetText(totalCostText)
end


--[[ Enchanting Table Functions ]]--

function tcc_InitEnchantingXpTable()
	-- skillTier, description, potencyAdditiveName, potencySubtractiveName, levelMin, levelMax, createXpWhite, deconstructXpWhite,
	-- createXpGreen, deconstructXpGreen, createXpBlue, deconstructXpBlue, createXpPurple, deconstructXpPurple, 
	-- potencyAdditiveLink, potencySubtractiveLink, itemLinkWhite, itemLinkGreen, itemLinkBlue, itemLinkPurple
	local tbl
	local numRows = 1 + table.getn(tcc.Crafts[tcc.CraftSelected].CraftingXp)
	local row = 1
	if tcc.Tables == nil then tcc.Tables = {} end
	if tcc.Tables[TCC_ENCHANTING_XP_TABLE_NAME] == nil then
		local colWidths
		if tcc.IntegrateMM then
			colWidths = {45, 335, 78, 72, 62, 86}
		else
			colWidths = {45, 335, 78, 72, 62}
		end
		tbl = tcc_DrawTable(tccXpTableFrame, TCC_ENCHANTING_XP_TABLE_NAME, numRows, colWidths, true)
	else
		tbl = tcc.Tables[TCC_ENCHANTING_XP_TABLE_NAME]
	end
	tbl.CellLabels[row][TCC_COL_SKILL_TIER]:SetText("Skill\nTier")
	tbl.CellLabels[row][TCC_COL_NUM_XP_ITEMS]:SetText(string.gsub(string.gsub(TCC_NUMBER_OF_ITEMS_LABEL, "%%", tcc.CreateOrDeconSelected), "Items", "|cFF00FFItems*|r"))
	tcc_RegisterTextTooltip(tbl.CellLabels[row][TCC_COL_NUM_XP_ITEMS], "* Can be any type of glyph of the same\n   Potency level (additive or subtractive,\n   using any Essence rune).\n   They will all yield the same XP.")
	tbl.CellLabels[row][TCC_COL_ENCH_POTENCY]:SetText("Potency\nRune")
	tbl.CellLabels[row][TCC_COL_ENCH_ESSENCE]:SetText("Essence\nRune")
	tbl.CellLabels[row][TCC_COL_ENCH_ASPECT]:SetText("Aspect\nRune")
	if tcc.IntegrateMM then
		tbl.CellLabels[row][TCC_COL_ENCH_COST_OF_MATERIALS]:SetText("|cFF00FFCost*|r of\nMaterials")
		tcc_RegisterTextTooltip(tbl.CellLabels[row][TCC_COL_ENCH_COST_OF_MATERIALS], "* Based on the average component prices\n   reported by Master Merchant")
	end
	for rowIndex, craftingXp in ipairs(tcc.Crafts[tcc.CraftSelected].CraftingXp) do
		row = row + 1
		tbl.CellLabels[row][TCC_COL_SKILL_TIER]:SetText(craftingXp.SkillTier)
		tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_NUM_XP_ITEMS])
		tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_ENCH_POTENCY])
		tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_ENCH_ESSENCE])
		tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_ENCH_ASPECT])
		if tcc.IntegrateMM then 
			tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_ENCH_COST_OF_MATERIALS])
		end
	end
	tcc_ExpandShrinkCalculatorWindow()
end

function tcc_PopulateEnchantingXpTable()
	local xpNeeded = tcc_EnforcePositiveIntegerValue(tccCraftingXpNeeded)
	local craftName = tcc.CraftSelected
	tcc_InitEnchantingXpTable()
	if tcc.Tables[TCC_XP_TABLE_NAME] ~= nil then tcc.Tables[TCC_XP_TABLE_NAME]:SetHidden(true) end
	-- if tcc.Tables[TCC_ALCHEMY_XP_TABLE_NAME] ~= nil then tcc.Tables[TCC_ALCHEMY_XP_TABLE_NAME]:SetHidden(true) end
	-- if tcc.Tables[TCC_PROVISIONING_XP_TABLE_NAME] ~= nil then tcc.Tables[TCC_PROVISIONING_XP_TABLE_NAME]:SetHidden(true) end
	tcc.Tables[TCC_ENCHANTING_XP_TABLE_NAME]:SetHidden(false)

	-- Stop here if no xpNeeded
	if xpNeeded == nil or xpNeeded == "" then
		tccCraftingXpNeeded:TakeFocus()
		return
	end

	local itemLevel, numItems
	local currentSkillLevel, desiredSkillLevel, xpNeededForNextLevel, xpPerItemAdjusted, numItemsForSkillLevel
	local progressXpCurrentLevel, xpMax, xpNew, xpOverflowToNextLvl, numItemsUnadjusted, numItemsWasted
	local craft = tcc.Crafts[craftName]
	local itemType = tcc.ItemTypes[craft.OptimalItemType]
	local inspirationBoostMultiplier = 1 --(ZO_CheckButton_IsChecked(tccInspirationBoostCheckbox) and 1.2 or 1)  -- TODO: Disabled until I figure out the new champion skill syntax
	local esoPlusMultiplier = (ZO_CheckButton_IsChecked(tccEsoPlusCheckbox) and 1.1 or 1)
	local orcCraftsmanMultiplier = (ZO_CheckButton_IsChecked(tccOrcCraftsmanCheckbox) and 1.1 or 1)
	local multiplier = inspirationBoostMultiplier * esoPlusMultiplier * orcCraftsmanMultiplier
	local currentSkillLevel = tonumber(tccCurrentCraftingSkillLevel:GetText())
	local desiredSkillLevel = tonumber(tccDesiredCraftingSkillLevel:GetText())
	local progressXp = tonumber(tccCurrentCraftingSkillLevelProgress:GetText())
	for xpIndex, craftingXp in ipairs(craft.CraftingXp) do

		-- Only populate the cells in this row if there's a positive XP value.
		xpPerItem = craftingXp[tcc.CreateOrDeconSelected .. "Xp" .. tcc.XpQualitySelected.Key]
		xpPerItem = math.floor(xpPerItem * multiplier)
		numItems = 0
		numItemsWasted = 0

		if xpPerItem > 0 then
			-- Default values, assuming there is no max decon XP cap involved.
			numItems = math.ceil(xpNeeded / xpPerItem)
			numItemsUnadjusted = numItems

			-- If the decon XP for this item exceeds the MaxXpPerDecon for the player's current skill level, 
			-- step through each of the skill levels one by one and determine how many items are required.
			if craft.MaxXpPerDecon ~= nil and craft.MaxXpPerDecon[currentSkillLevel] ~= nil then 
				xpMax = math.floor(craft.MaxXpPerDecon[currentSkillLevel] * multiplier)
				if xpMax <= xpPerItem then 
					numItems = 0
					progressXpCurrentLevel = progressXp
					for skillLevel = currentSkillLevel, desiredSkillLevel - 1 do
						xpNeededForNextLevel = tcc.CraftingXpNeededForSkillLevel[tcc.CraftSelected][skillLevel + 1] - progressXpCurrentLevel
						xpPerItemAdjusted = xpPerItem
						if craft.MaxXpPerDecon[skillLevel] ~= nil then
							xpMax = math.floor(craft.MaxXpPerDecon[skillLevel] * multiplier)
							if xpMax <= xpPerItem then xpPerItemAdjusted = xpMax end
						end
						numItemsForSkillLevel = math.ceil(xpNeededForNextLevel / xpPerItemAdjusted)
						numItems = numItems + numItemsForSkillLevel
						xpNew = numItemsForSkillLevel * xpPerItemAdjusted
						xpOverflowToNextLvl = xpNew - xpNeededForNextLevel
						progressXpCurrentLevel = xpOverflowToNextLvl
					end
				end
			end
			
			if numItemsUnadjusted < numItems then
				numItemsWasted = numItems - numItemsUnadjusted
			else
				numItemsWasted = 0
			end
	
			tcc_PopulateEnchantingXpCell_NumberOfItems(xpIndex, craftingXp, numItems, numItemsWasted)
			tcc_PopulateEnchantingXpCell_Potency(xpIndex, craftingXp)
			tcc_PopulateEnchantingXpCell_Essence(xpIndex, craftingXp)
			tcc_PopulateEnchantingXpCell_Aspect(xpIndex, craftingXp)
			if tcc.IntegrateMM then tcc_PopulateEnchantingXpCell_CostOfMaterials(xpIndex, craftingXp, numItems) end
		end
		
	end  -- next skillTier, craftingXp
	if tcc.IntegrateMM then tcc_HighlightLowestValueInTableColumn(tcc.Tables[TCC_ENCHANTING_XP_TABLE_NAME], TCC_COL_ENCH_COST_OF_MATERIALS) end
end

function tcc_PopulateEnchantingXpCell_NumberOfItems(xpIndex, craftingXp, numItems, numItemsWasted)
	-- skillTier, description, potencyAdditiveName, potencySubtractiveName, levelMin, levelMax, createXpWhite, deconstructXpWhite,
	-- createXpGreen, deconstructXpGreen, createXpBlue, deconstructXpBlue, createXpPurple, deconstructXpPurple, 
	-- potencyAdditiveLink, potencySubtractiveLink, itemLinkWhite, itemLinkGreen, itemLinkBlue, itemLinkPurple
	local cellLabel = tcc.Tables[TCC_ENCHANTING_XP_TABLE_NAME].CellLabels[xpIndex+1][TCC_COL_NUM_XP_ITEMS]
	local itemQtyLabel = tcc_GetOrCreateControl(cellLabel, cellLabel:GetName() .. "_ItemQty", CT_LABEL)
	itemQtyLabel:ClearAnchors()
	itemQtyLabel:SetAnchor(TOPLEFT, cellLabel, TOPLEFT, 0, 0)
	itemQtyLabel:SetFont(tcc.FONT_TABLE_CELL_HEAVY)
	if numItemsWasted > 0 then
		itemQtyLabel:SetText("|cFF0000" .. tcc_CommaValue(numItems) .. "*|r")
		local itemQtyTooltip = "Item level/quality is too high to receive full decon XP at current skill level " .. tccCurrentCraftingSkillLevel:GetText() .. "!\n" .. tostring(numItemsWasted) .. " more items have been added to the total, to make up the difference."
		tcc_RegisterTextTooltip(itemQtyLabel, itemQtyTooltip)
	else
		itemQtyLabel:SetText("|c00FF00" .. tcc_CommaValue(numItems) .. "|r")
		tcc_UnregisterTooltip(itemQtyLabel)
	end
	local itemLvlLabel = tcc_GetOrCreateControl(cellLabel, cellLabel:GetName() .. "_ItemLvl", CT_LABEL)
	itemLvlLabel:ClearAnchors()
	itemLvlLabel:SetAnchor(LEFT, itemQtyLabel, RIGHT, 4, 0)
	itemLvlLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	itemLvlLabel:SetColor(0.81, 0.86, 0.74, 1)
	itemLvlLabel:SetText("Level |cFFFF00" .. craftingXp.LevelMin .. "|r" .. (craftingXp.LevelMax ~= craftingXp.LevelMin and "-|cFFFF00" .. craftingXp.LevelMax .. "|r" or ""))
	-- Syntax:  tcc_GetOrCreateControlFromVirtual(parent, controlName, virtualControlName)
	local itemLinkLabel = tcc_GetOrCreateControlFromVirtual(cellLabel, cellLabel:GetName() .. "_ItemLink", "tccLinkEnabledLabelTemplate")
	itemLinkLabel:ClearAnchors()
	itemLinkLabel:SetAnchor(LEFT, itemLvlLabel, RIGHT, 4, 0)
	itemLinkLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	itemLinkLabel:SetText(craftingXp["ItemLink" .. tcc.XpQualitySelected.Key])
	tcc_RegisterItemTooltip(itemLinkLabel, craftingXp["ItemLink" .. tcc.XpQualitySelected.Key])
end

function tcc_PopulateEnchantingXpCell_Potency(xpIndex, craftingXp)
	--local cellLabel, orLabel, potencyNegIcon --, essenceIcon, aspectIcon, asteriskLabel, potencyPosIcon
	local cellLabel = tcc.Tables[TCC_ENCHANTING_XP_TABLE_NAME].CellLabels[xpIndex+1][TCC_COL_ENCH_POTENCY]

	-- Syntax:  tcc_CreateLinkEnabledIcon(parent, controlName, itemLink, texturePath, width, height, 
	--              anchorPoint, anchorRelativeTo, anchorRelativePoint, anchorOffsetX, anchorOffsetY)
	-- Returns: The linked Label control, and a Texture control.
	local potencyPosIcon, potencyPosIconTexture = tcc_CreateLinkEnabledIcon(cellLabel, cellLabel:GetName() .. "_PotencyPosIcon", craftingXp.PotencyAdditiveLink, craftingXp.PotencyAdditiveTexture, 20, 20, TOPLEFT, cellLabel, TOPLEFT, 0, 0)
	local orLabel = tcc_GetOrCreateControl(cellLabel, cellLabel:GetName() .. "_Or", CT_LABEL)
	orLabel:ClearAnchors()
	orLabel:SetAnchor(LEFT, potencyPosIcon, RIGHT, 4, 0)
	orLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	orLabel:SetColor(0.81, 0.86, 0.74, 1)
	orLabel:SetText("or")
	local potencyNegIcon, potencyNegIconTexture = tcc_CreateLinkEnabledIcon(cellLabel, cellLabel:GetName() .. "_PotencyNegIcon", craftingXp.PotencySubtractiveLink, craftingXp.PotencySubtractiveTexture, 20, 20, LEFT, orLabel, RIGHT, 4, 0)
end

function tcc_PopulateEnchantingXpCell_Essence(xpIndex)
	local cellLabel = tcc.Tables[TCC_ENCHANTING_XP_TABLE_NAME].CellLabels[xpIndex+1][TCC_COL_ENCH_ESSENCE]
	local essenceIcon, essenceIconTexture = tcc_CreateLinkEnabledIcon(cellLabel, cellLabel:GetName() .. "_EssenceIcon", tcc.EssenceRunes["Dekeipa"].ItemLink, tcc.EssenceRunes["Dekeipa"].ItemTexture, 20, 20, TOPLEFT, cellLabel, TOPLEFT, 0, 0)
	local orLabel = tcc_GetOrCreateControl(cellLabel, cellLabel:GetName() .. "_Or", CT_LABEL)
	orLabel:ClearAnchors()
	orLabel:SetAnchor(LEFT, essenceIcon, RIGHT, 4, 0)
	orLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	orLabel:SetColor(0.81, 0.86, 0.74, 1)
	orLabel:SetText("(any)")
end

function tcc_PopulateEnchantingXpCell_Aspect(xpIndex)
	local cellLabel, aspectIcon
	cellLabel = tcc.Tables[TCC_ENCHANTING_XP_TABLE_NAME].CellLabels[xpIndex+1][TCC_COL_ENCH_ASPECT]
	local aspectIcon, aspectIconTexture = tcc_CreateLinkEnabledIcon(cellLabel, cellLabel:GetName() .. "_AspectIcon", tcc.QualityMats[tcc.CraftSelected][tcc.XpQualitySelected.Key].MaterialLink, tcc.QualityMats[tcc.CraftSelected][tcc.XpQualitySelected.Key].MaterialTexture, 20, 20, TOPLEFT, cellLabel, TOPLEFT, 0, 0)
end

function tcc_PopulateEnchantingXpCell_CostOfMaterials(xpIndex, craftingXp, numItems)
	local potencyPosPrice = MasterMerchant:itemStats(craftingXp.PotencyAdditiveLink)["avgPrice"]
	local potencyNegPrice = MasterMerchant:itemStats(craftingXp.PotencySubtractiveLink)["avgPrice"]
	local essencePrice = MasterMerchant:itemStats(tcc.EssenceRunes["Dekeipa"].ItemLink)["avgPrice"]
	local aspectPrice = MasterMerchant:itemStats(tcc.QualityMats[tcc.CraftSelected][tcc.XpQualitySelected.Key].MaterialLink)["avgPrice"]
	potencyPosPrice = (potencyPosPrice ~= nil and potencyPosPrice or 0)
	potencyNegPrice = (potencyNegPrice ~= nil and potencyNegPrice or 0)
	local potencyPrice = (potencyPosPrice < potencyNegPrice and potencyPosPrice or potencyNegPrice)
	essencePrice = (essencePrice ~= nil and essencePrice or 0)
	aspectPrice = (aspectPrice ~= nil and aspectPrice or 0)
	local totalCost = (potencyPrice + essencePrice + aspectPrice) * numItems
	local totalCostText = ""
	if totalCost == 0 then
		totalCostText = "?"
	else
		totalCostText = tcc_CommaValue(tostring(math.ceil(totalCost))) .. "g"
	end
	tcc.Tables[TCC_ENCHANTING_XP_TABLE_NAME].CellLabels[xpIndex+1][TCC_COL_ENCH_COST_OF_MATERIALS].Value = totalCost
	tcc.Tables[TCC_ENCHANTING_XP_TABLE_NAME].CellLabels[xpIndex+1][TCC_COL_ENCH_COST_OF_MATERIALS]:SetText(totalCostText)
end


--[[ Alchemy Table Functions ]]--

-- function tcc_InitAlchemyXpTable()
	-- -- skillTier, itemLevel, createXp, potionSolventName, potionDescription, poisonSolventName, poisonDescription, potionSolventLink, poisonSolventLink, 
	-- --   itemLinkPotion, itemLinkPoison, potionSolventTexture, poisonSolventTexture
	-- local tbl
	-- local numRows = 1 + table.getn(tcc.Crafts[tcc.CraftSelected].CraftingXp)
	-- local row = 1
	-- if tcc.Tables == nil then tcc.Tables = {} end
	-- if tcc.Tables[TCC_ALCHEMY_XP_TABLE_NAME] == nil then
		-- local colWidths
		-- colWidths = {45, 335, 80, 100}
		-- tbl = tcc_DrawTable(tccXpTableFrame, TCC_ALCHEMY_XP_TABLE_NAME, numRows, colWidths, true)
	-- else
		-- tbl = tcc.Tables[TCC_ALCHEMY_XP_TABLE_NAME]
	-- end
	-- tbl.CellLabels[row][TCC_COL_SKILL_TIER]:SetText("Skill\nTier")
	-- tbl.CellLabels[row][TCC_COL_NUM_XP_ITEMS]:SetText(string.gsub(string.gsub(TCC_NUMBER_OF_ITEMS_LABEL, "%%", tcc.CreateOrDeconSelected), "Items", "|cFF00FFItems*|r"))
	-- tcc_RegisterTextTooltip(tbl.CellLabels[row][TCC_COL_NUM_XP_ITEMS], "* Any Potion or Poison of the same level,\n   using any 2 compatible reagents.\n   Using 3 reagents will yield the same XP.")
	-- tbl.CellLabels[row][TCC_COL_ALCH_SOLVENT]:SetText("Solvent")
	-- tbl.CellLabels[row][TCC_COL_ALCH_REAGENT]:SetText("Reagents")
	-- for rowIndex, craftingXp in ipairs(tcc.Crafts[tcc.CraftSelected].CraftingXp) do
		-- row = row + 1
		-- tbl.CellLabels[row][TCC_COL_SKILL_TIER]:SetText(craftingXp.SkillTier)
		-- tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_NUM_XP_ITEMS])
		-- tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_ALCH_SOLVENT])
		-- tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_ALCH_REAGENT])
	-- end
	-- tcc_ExpandShrinkCalculatorWindow()
-- end

-- function tcc_PopulateAlchemyXpTable()
	-- local xpNeeded = tcc_EnforcePositiveIntegerValue(tccCraftingXpNeeded)
	-- tcc_InitAlchemyXpTable()
	-- if tcc.Tables[TCC_XP_TABLE_NAME] ~= nil then tcc.Tables[TCC_XP_TABLE_NAME]:SetHidden(true) end
	-- if tcc.Tables[TCC_ENCHANTING_XP_TABLE_NAME] ~= nil then tcc.Tables[TCC_ENCHANTING_XP_TABLE_NAME]:SetHidden(true) end
	-- if tcc.Tables[TCC_PROVISIONING_XP_TABLE_NAME] ~= nil then tcc.Tables[TCC_PROVISIONING_XP_TABLE_NAME]:SetHidden(true) end
	-- tcc.Tables[TCC_ALCHEMY_XP_TABLE_NAME]:SetHidden(false)

	-- -- Stop here if no xpNeeded
	-- if xpNeeded == nil or xpNeeded == "" then
		-- tccCraftingXpNeeded:TakeFocus()
		-- return
	-- end

	-- -- skillTier, itemLevel, createXp, potionSolventName, potionDescription, poisonSolventName, poisonDescription, potionSolventLink, poisonSolventLink, 
	-- --   itemLinkPotion, itemLinkPoison, potionSolventTexture, poisonSolventTexture
		-- --tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_NUM_XP_ITEMS])
		-- --tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_ALCH_SOLVENT])
		-- --tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_ALCH_REAGENT])
	-- local numItems
	-- local currentSkillLevel, desiredSkillLevel
	-- local inspirationBoostMultiplier = (ZO_CheckButton_IsChecked(tccInspirationBoostCheckbox) and 1.2 or 1)
	-- local esoPlusMultiplier = (ZO_CheckButton_IsChecked(tccEsoPlusCheckbox) and 1.1 or 1)
	-- local orcCraftsmanMultiplier = (ZO_CheckButton_IsChecked(tccOrcCraftsmanCheckbox) and 1.1 or 1)
	-- local multiplier = inspirationBoostMultiplier * esoPlusMultiplier * orcCraftsmanMultiplier
	-- local currentSkillLevel = tonumber(tccCurrentCraftingSkillLevel:GetText())
	-- local desiredSkillLevel = tonumber(tccDesiredCraftingSkillLevel:GetText())
	-- local progressXp = tonumber(tccCurrentCraftingSkillLevelProgress:GetText())
	-- for xpIndex, craftingXp in ipairs(tcc.Crafts[tcc.CraftSelected].CraftingXp) do
		-- -- Only populate the cells in this row if there's a positive XP value.
		-- xpPerItem = craftingXp[tcc.CreateOrDeconSelected .. "Xp"]
		-- xpPerItem = math.floor(xpPerItem * multiplier)

		-- numItems = math.ceil(xpNeeded / xpPerItem)
		-- -- math.huge is "infinity", the result of dividing by zero.
		-- if numItems == math.huge then numItems = 0 end
		-- tcc_PopulateAlchemyXpCell_NumberOfItems(xpIndex, craftingXp, numItems)
		-- tcc_PopulateAlchemyXpCell_Solvent(xpIndex, craftingXp)
		-- if xpPerItem > 0 then
			-- tcc_PopulateAlchemyXpCell_Reagent(xpIndex, craftingXp)
		-- end
	-- end  -- next skillTier, craftingXp
-- end

-- function tcc_PopulateAlchemyXpCell_NumberOfItems(xpIndex, craftingXp, numItems)
	-- -- skillTier, itemLevel, createXp, potionSolventName, potionDescription, poisonSolventName, poisonDescription, potionSolventLink, poisonSolventLink, 
	-- --   itemLinkPotion, itemLinkPoison, potionSolventTexture, poisonSolventTexture
	-- local cellLabel = tcc.Tables[TCC_ALCHEMY_XP_TABLE_NAME].CellLabels[xpIndex+1][TCC_COL_NUM_XP_ITEMS]
	-- local itemQtyLabel = tcc_GetOrCreateControl(cellLabel, cellLabel:GetName() .. "_ItemQty", CT_LABEL)
	-- itemQtyLabel:ClearAnchors()
	-- itemQtyLabel:SetAnchor(TOPLEFT, cellLabel, TOPLEFT, 0, 0)
	-- itemQtyLabel:SetFont(tcc.FONT_TABLE_CELL_HEAVY)
	-- itemQtyLabel:SetText("|c00FF00" .. tcc_CommaValue(numItems) .. "|r")
	-- tcc_UnregisterTooltip(itemQtyLabel)
	-- local itemLvlLabel = tcc_GetOrCreateControl(cellLabel, cellLabel:GetName() .. "_ItemLvl", CT_LABEL)
	-- itemLvlLabel:ClearAnchors()
	-- itemLvlLabel:SetAnchor(LEFT, itemQtyLabel, RIGHT, 4, 0)
	-- itemLvlLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	-- itemLvlLabel:SetColor(0.81, 0.86, 0.74, 1)
	-- itemLvlLabel:SetText("Level |cFFFF00" .. craftingXp.ItemLevel .. "|r")
	-- -- Syntax:  tcc_GetOrCreateControlFromVirtual(parent, controlName, virtualControlName)
	-- local itemLinkLabel = tcc_GetOrCreateControlFromVirtual(cellLabel, cellLabel:GetName() .. "_ItemLink", "tccLinkEnabledLabelTemplate")
	-- itemLinkLabel:ClearAnchors()
	-- itemLinkLabel:SetAnchor(LEFT, itemLvlLabel, RIGHT, 4, 0)
	-- itemLinkLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	-- itemLinkLabel:SetText(craftingXp["ItemLinkPotion"])
	-- tcc_RegisterItemTooltip(itemLinkLabel, craftingXp["ItemLinkPotion"])
-- end

-- function tcc_PopulateAlchemyXpCell_Solvent(xpIndex, craftingXp)
	-- local cellLabel = tcc.Tables[TCC_ALCHEMY_XP_TABLE_NAME].CellLabels[xpIndex+1][TCC_COL_ALCH_SOLVENT]

	-- -- Syntax:  tcc_CreateLinkEnabledIcon(parent, controlName, itemLink, texturePath, width, height, 
	-- --              anchorPoint, anchorRelativeTo, anchorRelativePoint, anchorOffsetX, anchorOffsetY)
	-- -- Returns: The linked Label control, and a Texture control.
	-- local potionSolventIcon, potionSolventIconTexture = tcc_CreateLinkEnabledIcon(cellLabel, cellLabel:GetName() .. "_PotionSolventIcon", craftingXp.PotionSolventLink, craftingXp.PotionSolventTexture, 20, 20, TOPLEFT, cellLabel, TOPLEFT, 0, 0)
	-- local orLabel = tcc_GetOrCreateControl(cellLabel, cellLabel:GetName() .. "_Or", CT_LABEL)
	-- orLabel:ClearAnchors()
	-- orLabel:SetAnchor(LEFT, potionSolventIcon, RIGHT, 4, 0)
	-- orLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	-- orLabel:SetColor(0.81, 0.86, 0.74, 1)
	-- orLabel:SetText("or")
	-- local poisonSolventIcon, poisonSolventIconTexture = tcc_CreateLinkEnabledIcon(cellLabel, cellLabel:GetName() .. "_PoisonSolventIcon", craftingXp.PoisonSolventLink, craftingXp.PoisonSolventTexture, 20, 20, LEFT, orLabel, RIGHT, 4, 0)
-- end

-- function tcc_PopulateAlchemyXpCell_Reagent(xpIndex)
	-- local cellLabel = tcc.Tables[TCC_ALCHEMY_XP_TABLE_NAME].CellLabels[xpIndex+1][TCC_COL_ALCH_REAGENT]
	-- cellLabel:SetText("|t20:20:/esoui/art/icons/crafting_mushroom_blue_entoloma_cap_r1.dds|t|t20:20:/esoui/art/icons/crafting_mushroom_luminous_russula_r1.dds|t (any 2)")
-- end


--[[ Provisioning Table Functions ]]--

-- function tcc_InitProvisioningXpTable()
	-- -- skillTier, itemLevel, createXp, potionSolventName, potionDescription, poisonSolventName, poisonDescription, potionSolventLink, poisonSolventLink, 
	-- --   itemLinkPotion, itemLinkPoison, potionSolventTexture, poisonSolventTexture
	-- local tbl
	-- local numRows = 1 + table.getn(tcc.Crafts[tcc.CraftSelected].CraftingXp)
	-- local row = 1
	-- if tcc.Tables == nil then tcc.Tables = {} end
	-- if tcc.Tables[TCC_PROVISIONING_XP_TABLE_NAME] == nil then
		-- local colWidths
		-- if tcc.IntegrateMM then 
			-- colWidths = {45, 268, 145, 100, 98}
		-- else
			-- colWidths = {45, 268, 145, 100}
		-- end
		-- tbl = tcc_DrawTable(tccXpTableFrame, TCC_PROVISIONING_XP_TABLE_NAME, numRows, colWidths, true)
	-- else
		-- tbl = tcc.Tables[TCC_PROVISIONING_XP_TABLE_NAME]
	-- end
	-- tbl.CellLabels[row][TCC_COL_SKILL_TIER]:SetText("Skill\nTier")
	-- tbl.CellLabels[row][TCC_COL_NUM_XP_ITEMS]:SetText(string.gsub(string.gsub(TCC_NUMBER_OF_ITEMS_LABEL, "%%", tcc.CreateOrDeconSelected), "Items", "|cFF00FFItems*|r"))
	-- tcc_RegisterTextTooltip(tbl.CellLabels[row][TCC_COL_NUM_XP_ITEMS], "* Any Green Food or Drink recipe\n   of the specified level.\n   Blue or Purple recipes do not yield\n   any more XP than green.")
	-- tbl.CellLabels[row][TCC_COL_PROV_EXAMPLE]:SetText("Recipe\n(example)")
	-- tbl.CellLabels[row][TCC_COL_PROV_INGREDIENTS]:SetText("Ingredients\n(example)")
	-- if tcc.IntegrateMM then
		-- tbl.CellLabels[row][TCC_COL_PROV_COST_OF_MATERIALS]:SetText("|cFF00FFCost*|r of\nIngredients")
		-- tcc_RegisterTextTooltip(tbl.CellLabels[row][TCC_COL_PROV_COST_OF_MATERIALS], "* Based on the average price reported by\n   Master Merchant")
	-- end
	-- for rowIndex, craftingXp in ipairs(tcc.Crafts[tcc.CraftSelected].CraftingXp) do
		-- row = row + 1
		-- tbl.CellLabels[row][TCC_COL_SKILL_TIER]:SetText(craftingXp.SkillTier)
		-- tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_NUM_XP_ITEMS])
		-- tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_PROV_EXAMPLE])
		-- tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_PROV_INGREDIENTS])
		-- if tcc.IntegrateMM then tcc_ClearTableCell(tbl.CellLabels[row][TCC_COL_PROV_COST_OF_MATERIALS]) end
	-- end
	-- tcc_ExpandShrinkCalculatorWindow()
-- end

-- function tcc_PopulateProvisioningXpTable()
	-- local xpNeeded = tcc_EnforcePositiveIntegerValue(tccCraftingXpNeeded)
	-- tcc_InitProvisioningXpTable()
	-- if tcc.Tables[TCC_XP_TABLE_NAME] ~= nil then tcc.Tables[TCC_XP_TABLE_NAME]:SetHidden(true) end
	-- if tcc.Tables[TCC_ENCHANTING_XP_TABLE_NAME] ~= nil then tcc.Tables[TCC_ENCHANTING_XP_TABLE_NAME]:SetHidden(true) end
	-- if tcc.Tables[TCC_ALCHEMY_XP_TABLE_NAME] ~= nil then tcc.Tables[TCC_ALCHEMY_XP_TABLE_NAME]:SetHidden(true) end
	-- tcc.Tables[TCC_PROVISIONING_XP_TABLE_NAME]:SetHidden(false)

	-- -- Stop here if no xpNeeded
	-- if xpNeeded == nil or xpNeeded == "" then
		-- tccCraftingXpNeeded:TakeFocus()
		-- return
	-- end

	-- local numItems
	-- local currentSkillLevel, desiredSkillLevel
	-- local inspirationBoostMultiplier = (ZO_CheckButton_IsChecked(tccInspirationBoostCheckbox) and 1.2 or 1)
	-- local esoPlusMultiplier = (ZO_CheckButton_IsChecked(tccEsoPlusCheckbox) and 1.1 or 1)
	-- local orcCraftsmanMultiplier = (ZO_CheckButton_IsChecked(tccOrcCraftsmanCheckbox) and 1.1 or 1)
	-- local multiplier = inspirationBoostMultiplier * esoPlusMultiplier * orcCraftsmanMultiplier
	-- local currentSkillLevel = tonumber(tccCurrentCraftingSkillLevel:GetText())
	-- local desiredSkillLevel = tonumber(tccDesiredCraftingSkillLevel:GetText())
	-- local progressXp = tonumber(tccCurrentCraftingSkillLevelProgress:GetText())
	-- for xpIndex, craftingXp in ipairs(tcc.Crafts[tcc.CraftSelected].CraftingXp) do
		-- -- Only populate the cells in this row if there's a positive XP value.
		-- xpPerItem = craftingXp[tcc.CreateOrDeconSelected .. "Xp"]
		-- xpPerItem = math.floor(xpPerItem * multiplier)

		-- numItems = math.ceil(xpNeeded / xpPerItem)
		-- -- math.huge is "infinity", the result of dividing by zero.
		-- if numItems == math.huge then numItems = 0 end
		-- tcc_PopulateProvisioningXpCell_NumberOfItems(xpIndex, craftingXp, numItems)
		-- tcc_PopulateProvisioningXpCell_Example(xpIndex, craftingXp)
		-- tcc_PopulateProvisioningXpCell_Ingredients(xpIndex, craftingXp)
		-- if tcc.IntegrateMM and numItems > 0 then tcc_PopulateProvisioningXpCell_CostOfMaterials(xpIndex, craftingXp, numItems) end
	-- end  -- next skillTier, craftingXp
	-- if tcc.IntegrateMM then tcc_HighlightLowestValueInTableColumn(tcc.Tables[TCC_PROVISIONING_XP_TABLE_NAME], TCC_COL_PROV_COST_OF_MATERIALS) end
-- end

-- function tcc_PopulateProvisioningXpCell_NumberOfItems(xpIndex, craftingXp, numItems)
	-- local cellLabel = tcc.Tables[TCC_PROVISIONING_XP_TABLE_NAME].CellLabels[xpIndex+1][TCC_COL_NUM_XP_ITEMS]
	-- local itemQtyLabel = tcc_GetOrCreateControl(cellLabel, cellLabel:GetName() .. "_ItemQty", CT_LABEL)
	-- itemQtyLabel:ClearAnchors()
	-- itemQtyLabel:SetAnchor(TOPLEFT, cellLabel, TOPLEFT, 0, 0)
	-- itemQtyLabel:SetFont(tcc.FONT_TABLE_CELL_HEAVY)
	-- itemQtyLabel:SetText("|c00FF00" .. tcc_CommaValue(numItems) .. "|r")
	-- tcc_UnregisterTooltip(itemQtyLabel)
	-- local itemLvlLabel = tcc_GetOrCreateControl(cellLabel, cellLabel:GetName() .. "_ItemLvl", CT_LABEL)
	-- itemLvlLabel:ClearAnchors()
	-- itemLvlLabel:SetAnchor(LEFT, itemQtyLabel, RIGHT, 4, 0)
	-- itemLvlLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	-- itemLvlLabel:SetColor(0.81, 0.86, 0.74, 1)
	-- itemLvlLabel:SetText("Level |cFFFF00" .. craftingXp.ItemLevel .. "|r |c00FF00Green|r Food or Drink (any)")
-- end

-- function tcc_PopulateProvisioningXpCell_Example(xpIndex, craftingXp)
	-- -- skillTier, itemLevel, createXp, itemLinkExample, ingredientLinkArray, ingredientTextureArray
	-- local cellLabel = tcc.Tables[TCC_PROVISIONING_XP_TABLE_NAME].CellLabels[xpIndex+1][TCC_COL_PROV_EXAMPLE]
	-- -- Syntax:  tcc_GetOrCreateControlFromVirtual(parent, controlName, virtualControlName)
	-- local itemLinkLabel = tcc_GetOrCreateControlFromVirtual(cellLabel, cellLabel:GetName() .. "_ItemLink", "tccLinkEnabledLabelTemplate")
	-- itemLinkLabel:ClearAnchors()
	-- itemLinkLabel:SetAnchor(TOPLEFT, cellLabel, TOPLEFT, 0, 0)
	-- itemLinkLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	-- itemLinkLabel:SetText(craftingXp.ItemLinkExample)
	-- tcc_RegisterItemTooltip(itemLinkLabel, craftingXp.ItemLinkExample)
-- end

-- function tcc_PopulateProvisioningXpCell_Ingredients(xpIndex, craftingXp)
	-- local cellLabel = tcc.Tables[TCC_PROVISIONING_XP_TABLE_NAME].CellLabels[xpIndex+1][TCC_COL_PROV_INGREDIENTS]
	-- for ingIndex, ingredientLink in ipairs(craftingXp.IngredientLinkArray) do
		-- local ingredientTexture = craftingXp.IngredientTextureArray[ingIndex]
		-- -- Syntax:  tcc_CreateLinkEnabledIcon(parent, controlName, itemLink, texturePath, width, height, 
		-- --              anchorPoint, anchorRelativeTo, anchorRelativePoint, anchorOffsetX, anchorOffsetY)
		-- -- Returns: The linked Label control, and a Texture control.
		-- local ingredientIcon, ingredientIconTexture = tcc_CreateLinkEnabledIcon(cellLabel, cellLabel:GetName().."_IngredientIcon"..ingIndex, ingredientLink, ingredientTexture, 20, 20, TOPLEFT, cellLabel, TOPLEFT, 22*(ingIndex-1), 0)
	-- end
-- end

-- function tcc_PopulateProvisioningXpCell_CostOfMaterials(xpIndex, craftingXp, numItems)
	-- local totalCost = 0
	-- for ingIndex, ingredientLink in ipairs(craftingXp.IngredientLinkArray) do
		-- local ingPrice = MasterMerchant:itemStats(ingredientLink)["avgPrice"]
		-- if ingPrice ~= nil then totalCost = totalCost + ingPrice end
	-- end
	-- totalCost = ingPrice * numItems
	-- local totalCostText = ""
	-- if totalCost == 0 then
		-- totalCostText = "?"
	-- else
		-- totalCostText = tcc_CommaValue(tostring(math.ceil(totalCost))) .. "g"
	-- end
	-- tcc.Tables[TCC_PROVISIONING_XP_TABLE_NAME].CellLabels[xpIndex+1][TCC_COL_PROV_COST_OF_MATERIALS].Value = totalCost
	-- tcc.Tables[TCC_PROVISIONING_XP_TABLE_NAME].CellLabels[xpIndex+1][TCC_COL_PROV_COST_OF_MATERIALS]:SetText(totalCostText)
-- end


--[[ Utility Functions ]]--

function tcc_GetCurrentAbilityRank(skillType, skillIndex, abilityIndex)
	-- GetSkillAbilityUpgradeInfo uses GetSkillLineInfo(skillType, skillIndex), which uses SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(skillType, skillLineIndex), and returns: 
	--	SkillName, SkillCurrentRank, SkillIsAvailable, SkillId(), SkillIsAdvised, SkillUnlockText, SkillIsActive, SkillIsDiscovered
	local currentUpgradeLevel, maxUpgradeLevel = GetSkillAbilityUpgradeInfo(skillType, skillIndex, abilityIndex)
	return currentUpgradeLevel
end

function tcc_GetSkillLevelAndProgressFromXp(craftingXp)
	local totalXp = 0
	for skillLevel, levelXp in ipairs(tcc.CraftingXpNeededForSkillLevel[tcc.CraftSelected]) do
		if totalXp + levelXp > craftingXp then
			return skillLevel - 1, craftingXp - totalXp
		elseif totalXp + levelXp == craftingXp then
			return skillLevel, 0
		end
		totalXp = totalXp + levelXp
	end
end

function tcc_GetXpForCraftingSkillLevel(craftingSkillLevel)
	local targetXp = 0
	for skillLevel, levelXp in ipairs(tcc.CraftingXpNeededForSkillLevel[tcc.CraftSelected]) do
		targetXp = targetXp + levelXp
		if skillLevel == craftingSkillLevel then return targetXp end
	end
end

