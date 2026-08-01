-- TinydogsCraftingCalculator Item Builder UI LUA File
-- Last Updated June 29, 2024 by @tinydog
-- Created October 2015 by @tinydog

-- ESO Constants
local TCC_CRAFT_SKILL_IMPROVEMENT_INDEX = {
	["Blacksmithing"] = 6,
	["Clothing"] = 6,
	["Woodworking"] = 6,
	["Jewelry"] = 5,
}

local materialGroupNames = { "BlacksmithingBaseMaterials", "ClothingBaseMaterials", "WoodworkingBaseMaterials", "JewelryBaseMaterials", "TraitMaterials", "StyleMaterials", "BlacksmithingQualityMaterials", "ClothingQualityMaterials", "WoodworkingQualityMaterials", "JewelryQualityMaterials" }

function tcc_ResetItemBuilder()
	-- Level
	tcc_SetLevelSliderToPlayerLevel()
	tcc_SelectItemLevel()
	-- Armor / Weapon
	tcc.ItemBuilder.ItemType = nil
	tcc.ArmorCategorySelected = nil
	tcc.BodyPartSelected = nil
	tcc.OtherItemTypeSelected = nil
	for key, value in pairs(tcc.TexturePaths.ArmorCategories) do
		-- Equivalent to ternary operator:  (itemTypeName == key) ? "down" : "up" 
		texturePath = string.gsub(value, "%%", ((itemTypeName == key) and "down" or "up"))
		tccArmorRow:GetNamedChild(key):SetNormalTexture(texturePath)
	end
	for key, value in pairs(tcc.TexturePaths.BodyParts) do
		texturePath = string.gsub(value, "%%", ((itemTypeName == key) and "down" or "up"))
		tccArmorRow:GetNamedChild(key):SetNormalTexture(texturePath)
	end
	for key, value in pairs(tcc.TexturePaths.JewelryTypes) do
		texturePath = string.gsub(value, "%%", ((itemTypeName == key) and "down" or "up"))
		tccArmorRow:GetNamedChild(key):SetNormalTexture(texturePath)
	end
	for key, value in pairs(tcc.TexturePaths.OtherItemTypes) do
		texturePath = string.gsub(value, "%%", ((itemTypeName == key) and "down" or "up"))
		tccWeaponRow:GetNamedChild(key):SetNormalTexture(texturePath)
	end
	tcc_HideBorder(tccArmorRowArmorBorder) 
	tcc_HideBorder(tccArmorRowBodyPartBorder) 
	-- Trait
	tcc_SelectItemTrait(tccItemTraitRowNone)
	tccArmorTrait:SetHidden(false)
	tccWeaponTrait:SetHidden(true)
	tccJewelryTrait:SetHidden(true)
	-- Quality
	tcc_SelectItemQuality(tccItemQualityRowWhite)
	-- Style
	ZO_ComboBox_ObjectFromContainer(tccItemStyleDropdown):SetSelectedItem("Any")
	tcc_SelectItemStyle(tcc.RacialStyles[1])
	-- Set
	ZO_ComboBox_ObjectFromContainer(tccItemSetDropdown):SetSelectedItem("None")
	tcc_SelectItemSet(tcc.ItemSets[1])
	-- Finalize
	tcc_UpdateItemSummary()
	tcc_ListAllMaterials(tccMaterialsNeeded, nil)
end

function tcc_ItemLevelByName(levelName)
	for skillTier, itemLevel in pairs(tcc.ItemLevels) do
		if itemLevel.ItemLevel == levelName then return itemLevel end
	end
end

function tcc_GetLevelIndex(levelName)
	local levelNumeric, levelNameNumeric, lastIndex
	for index, itemLevel in pairs(tcc.ItemLevels) do
		if itemLevel.ItemLevel == tostring(levelName) then return index end
		-- Handle Champion Levels by removing the "CP"
		if itemLevel.SkillTier > 5 then 
			levelNumeric = string.sub(itemLevel.ItemLevel, 3)
			levelNameNumeric = string.sub(levelName, 3)
			levelNameNumeric = tonumber(levelNameNumeric)
		else
			levelNumeric = itemLevel.ItemLevel
			levelNameNumeric = tonumber(levelName)
		end
		levelNumeric = tonumber(levelNumeric)
		if levelNumeric ~= nil and levelNameNumeric ~= nil then
			if levelNumeric > levelNameNumeric then return index - 1 end
		end
		lastIndex = index
	end
	return lastIndex
end

function tcc_SetLevelSliderToPlayerLevel()
	tccLevelSlider:SetValue(tcc_GetLevelIndex(tcc_GetPlayerLevel()))
end

function tcc_SelectItemLevel()
	tcc.ItemBuilder.Level = tcc.ItemLevels[tccLevelSlider:GetValue()] --["ItemLevel"]
	tccLevelLabel:SetText("Level:  |cFFFFFF" .. tcc.ItemBuilder.Level["ItemLevel"] .. "|r")
	tcc_UpdateItemSummary()
end

function tcc_SelectItemType(itemTypeName)
	if itemTypeName == nil or itemTypeName == "" then return end
	local uncheckArmorCategory, uncheckBodyParts, uncheckJewelry, hideShirt, iconName, texturePath, isArmorTraitType, isWeaponTraitType, isJewelryTraitType
	if tcc.TexturePaths.ArmorCategories[itemTypeName] ~= nil then 
		tcc.ArmorCategorySelected = itemTypeName
		tcc.OtherItemTypeSelected = nil
		isArmorTraitType = true
		isWeaponTraitType = false
		isJewelryTraitType = false
		uncheckArmorCategory = true
		uncheckBodyParts = false
		uncheckJewelry = true
		if itemTypeName ~= "Light" and tcc.BodyPartSelected == "Shirt" then
			tcc.BodyPartSelected = nil
			uncheckBodyParts = true 
		end
		hideShirt = (itemTypeName ~= "Light")
		-- Update the body part tooltips for this armor type.
		for key, value in pairs(tcc.TexturePaths.BodyParts) do
			if tcc.ItemTypes[itemTypeName][key] ~= nil then 
				tccArmorRow:GetNamedChild(key):SetHandler("OnMouseEnter", function() tcc_ShowTextTooltip(tccArmorRow:GetNamedChild(key), tcc.ItemTypes[itemTypeName][key].BodyPart .. " (" .. tcc.ItemTypes[itemTypeName][key].ItemName .. ")") end)
			end
		end
	elseif tcc.TexturePaths.BodyParts[itemTypeName] ~= nil then
		tcc.BodyPartSelected = itemTypeName
		tcc.OtherItemTypeSelected = nil
		isArmorTraitType = true
		isWeaponTraitType = false
		isJewelryTraitType = false
		uncheckArmorCategory = false
		uncheckBodyParts = true
		uncheckJewelry = true
		hideShirt = tccArmorRow:GetNamedChild("Shirt"):IsHidden()
	elseif tcc.TexturePaths.JewelryTypes[itemTypeName] ~= nil then
		tcc.OtherItemTypeSelected = itemTypeName
		tcc.BodyPartSelected = nil
		tcc.ArmorCategorySelected = nil
		isArmorTraitType = false
		isWeaponTraitType = false
		isJewelryTraitType = true
		uncheckArmorCategory = true
		uncheckBodyParts = true
		uncheckJewelry = false
		hideShirt = true
		for key, value in pairs(tcc.TexturePaths.BodyParts) do
			tccArmorRow:GetNamedChild(key):SetHandler("OnMouseEnter", function() tcc_ShowTextTooltip(tccArmorRow:GetNamedChild(key), tcc.ItemTypes["Light"][key].BodyPart) end)
		end
	else
		tcc.OtherItemTypeSelected = itemTypeName
		tcc.BodyPartSelected = nil
		tcc.ArmorCategorySelected = nil
		isArmorTraitType = (itemTypeName == "Shield")
		isWeaponTraitType = (itemTypeName ~= "Shield")
		isJewelryTraitType = false
		uncheckArmorCategory = true
		uncheckBodyParts = true
		uncheckJewelry = true
		hideShirt = true
		-- Make the body part tooltips generic (use Light armor body part names because it includes Shirt).
		for key, value in pairs(tcc.TexturePaths.BodyParts) do
			tccArmorRow:GetNamedChild(key):SetHandler("OnMouseEnter", function() tcc_ShowTextTooltip(tccArmorRow:GetNamedChild(key), tcc.ItemTypes["Light"][key].BodyPart) end)
		end
	end
	tccArmorRow:GetNamedChild("Shirt"):SetHidden(hideShirt)
	tccArmorRow:GetNamedChild("Feet"):ClearAnchors()
	tccArmorRow:GetNamedChild("Feet"):SetAnchor(TOPLEFT, tccArmorRow:GetNamedChild("Chest"), TOPRIGHT, (hideShirt and 0 or tccArmorRow:GetNamedChild("Shirt"):GetWidth()), 0)
	
	if uncheckArmorCategory then
		for key, value in pairs(tcc.TexturePaths.ArmorCategories) do
			-- Equivalent to ternary operator:  (itemTypeName == key) ? "down" : "up" 
			texturePath = string.gsub(value, "%%", ((itemTypeName == key) and "down" or "up"))
			tccArmorRow:GetNamedChild(key):SetNormalTexture(texturePath)
		end
	end
	if uncheckBodyParts then
		for key, value in pairs(tcc.TexturePaths.BodyParts) do
			texturePath = string.gsub(value, "%%", ((itemTypeName == key) and "down" or "up"))
			tccArmorRow:GetNamedChild(key):SetNormalTexture(texturePath)
		end
	end
	if uncheckJewelry then
		for key, value in pairs(tcc.TexturePaths.JewelryTypes) do
			texturePath = string.gsub(value, "%%", ((itemTypeName == key) and "down" or "up"))
			tccArmorRow:GetNamedChild(key):SetNormalTexture(texturePath)
		end
	end
	for key, value in pairs(tcc.TexturePaths.OtherItemTypes) do
		texturePath = string.gsub(value, "%%", ((itemTypeName == key) and "down" or "up"))
		tccWeaponRow:GetNamedChild(key):SetNormalTexture(texturePath)
	end
	for key, value in pairs(tcc.TexturePaths.JewelryTypes) do
		texturePath = string.gsub(value, "%%", ((itemTypeName == key) and "down" or "up"))
		tccArmorRow:GetNamedChild(key):SetNormalTexture(texturePath)
	end
	
	-- Reset the Trait when switching between armor/weapon
	if isWeaponTraitType then
		if tccWeaponTrait:IsHidden() then tcc_SelectItemTrait(tccItemTraitRowNone) end
	elseif isJewelryTraitType then
		if tccJewelryTrait:IsHidden() then tcc_SelectItemTrait(tccItemTraitRowNone) end
		tcc_SelectItemStyleAny()
	else
		if tccArmorTrait:IsHidden() then tcc_SelectItemTrait(tccItemTraitRowNone) end
	end
	tccWeaponTrait:SetHidden(isWeaponTraitType == false)
	tccArmorTrait:SetHidden(isArmorTraitType == false)
	tccJewelryTrait:SetHidden(isJewelryTraitType == false)
	tccItemStyleRowLabel:SetHidden(isJewelryTraitType == true)
	tccItemStyleDropdown:SetHidden(isJewelryTraitType == true)

	-- Set the ItemType
	if tcc.OtherItemTypeSelected ~= nil then
		tcc.ItemBuilder.ItemType = tcc.ItemTypes[tcc.OtherItemTypeSelected]
	else
		if tcc.ArmorCategorySelected ~= nil and tcc.BodyPartSelected ~= nil then
			tcc.ItemBuilder.ItemType = tcc.ItemTypes[tcc.ArmorCategorySelected][tcc.BodyPartSelected]
		else
			tcc.ItemBuilder.ItemType = nil
		end
	end
	
	-- Red Border to indicate selection needed
	if tcc.BodyPartSelected ~= nil then
		if tcc.ArmorCategorySelected == nil then 
			tcc_DrawBorder(tccArmorRowArmorBorder, 1, 0, 0, 1, 2, 0) 
		else 
			tcc_HideBorder(tccArmorRowArmorBorder) 
		end
	end
	if tcc.ArmorCategorySelected ~= nil then
		if tcc.BodyPartSelected == nil then 
			tcc_DrawBorder(tccArmorRowBodyPartBorder, 1, 0, 0, 1, 2, 0) 
		else 
			tcc_HideBorder(tccArmorRowBodyPartBorder) 
		end
	end
	if tcc.OtherItemTypeSelected ~= nil then
		tcc_HideBorder(tccArmorRowArmorBorder) 
		tcc_HideBorder(tccArmorRowBodyPartBorder) 
	end

	tcc_UpdateItemSummary()
	--tccTestLabel:SetText(tccTestLabel:GetText() .. "\nafter\n")
end

function tcc_SelectItemTrait(iconControl)
	tcc.ItemBuilder.Trait = iconControl.IconData
	tccItemTraitRowNone:SetNormalTexture("/esoui/art/hud/radialicon_cancel_" .. (iconControl == tccItemTraitRowNone and "over" or "up") .. ".dds")
	tccItemTraitRowSelected:ClearAnchors()
	tccItemTraitRowSelected:SetAnchor(TOP, iconControl, BOTTOM, 0, 0)
	tcc_UpdateItemSummary()
end

function tcc_SelectItemQuality(iconControl)
	tcc.ItemBuilder.Quality = iconControl.IconData
	for i = 1, tccItemQualityRow:GetNumChildren() do
		icon = tccItemQualityRow:GetChild(i)
		if icon:GetName() ~= iconControl:GetParent():GetName() .. "Label" and icon:GetName() ~= iconControl:GetParent():GetName() .. "Selected" then 
			icon:SetNormalTexture(iconControl == icon and icon.IconData.SelectedTexture or icon.IconData.NormalTexture)
			tccItemQualityRowSelected:ClearAnchors()
			tccItemQualityRowSelected:SetAnchor(TOP, iconControl, BOTTOM, 0, 0)
		end
	end
	tcc_UpdateItemSummary()
end

function tcc_SelectItemStyle(itemStyle)
	tcc.ItemBuilder.Style = itemStyle
	tcc_UpdateItemSummary()
end

function tcc_SelectItemSet(itemSet)
	tcc.ItemBuilder.Set = itemSet
	tcc_UpdateItemSummary()
end

function tcc_GetItemText(itemBuilder)
	if itemBuilder == nil then return "" end
	if itemBuilder.Level == nil or itemBuilder.ItemType == nil then return "" end
	local summary = ""
	local itemName = ""
	summary = "Level |cFFFF00" .. itemBuilder.Level["ItemLevel"] .. "|r "
	if itemBuilder.ItemType["ItemCategory"] ~= "" then itemName = itemBuilder.ItemType["ItemCategory"] .. " " end
	itemName = itemName .. itemBuilder.ItemType["ItemName"]
	summary = summary .. itemName
	if itemBuilder.Trait.Key ~= "None" then summary = summary .. ", |cFA8E23" .. itemBuilder.Trait.Name .. "|r" end
	if itemBuilder.Quality.Key ~= "White" then summary = summary .. ", |c" .. itemBuilder.Quality.ColorCode .. itemBuilder.Quality.Key .. "|r quality" end
	if itemBuilder.Style.Key ~= "Any" then summary = summary .. ", |cCCAD6A" .. itemBuilder.Style.Name .. "|r style" end
	if itemBuilder.Set.ShortName ~= "None" then summary = summary .. ", |c90C1D4" .. itemBuilder.Set.LongName .. "|r set" end
	return summary, itemName
end

function tcc_UpdateItemSummary()
	local summary = ""
	if tcc.ItemBuilder.Level ~= nil and tcc.ItemBuilder.ItemType ~= nil then
		local materials = tcc_GetMaterialsNeededForItem(tcc.ItemBuilder.Level, tcc.ItemBuilder.ItemType, tcc.ItemBuilder.Trait, tcc.ItemBuilder.Style, tcc.ItemBuilder.Quality)
		tcc.ItemBuilder.ItemMaterials = materials
		tcc_ListAllMaterials(tccMaterialsNeeded, { materials })
	end
	tcc.ItemBuilder.ItemText, tcc.ItemBuilder.ItemName = tcc_GetItemText(tcc.ItemBuilder)
	tccItemSummary:SetText(tcc.ItemBuilder.ItemText)
	tccAddToOrder:SetHidden(tccItemSummary:GetText() == "")
end

-- Displays icons for all materials in the itemMaterialSets array
-- Note: itemMaterialSets is an *array* of the objects returned by tcc_GetMaterialsNeededForItem().
function tcc_ListAllMaterials(parent, itemMaterialSets)
	if parent == nil then return end
	-- Reset the horizontal scroll list item positions
	if parent == tccTotalMaterialsNeededForOrder then
		tccTotalMaterialsNeededForOrder:GetNamedChild("ListItems"):ClearAnchors()
		tccTotalMaterialsNeededForOrder:GetNamedChild("ListItems"):SetAnchor(TOPLEFT, tccTotalMaterialsNeededForOrder, TOPLEFT, 32, 4)
	end
	-- Clear the list
	for i = 1, parent:GetNumChildren() do 
		if parent:GetChild(i):GetNumChildren() > 0 then
			for j = 1, parent:GetChild(i):GetNumChildren() do
				parent:GetChild(i):GetChild(j).Active = false
				parent:GetChild(i):GetChild(j):SetHidden(true)
			end
		end
		parent:GetChild(i).Active = false
		parent:GetChild(i):SetHidden(true) 
	end
	-- Generate a "master list" of materials (combine like-materials, sum quantities, and regroup as we want them displayed).
	local collatedMaterialsList = tcc_GetCollatedMaterialsList(itemMaterialSets)
	-- List each of the material groups in sequence
	local anchorControl = parent
	for i, materialGroupName in ipairs(materialGroupNames) do
		if collatedMaterialsList[materialGroupName] ~= nil and table.getn(collatedMaterialsList[materialGroupName]) > 0 then 
			anchorControl = tcc_ListMaterials(parent, anchorControl, collatedMaterialsList[materialGroupName], materialGroupName) 
		end
	end
end

-- Lists one array of materials.
function tcc_ListMaterials(parent, anchorControl, materials, listName)
	for i, material in ipairs(materials) do
		anchorControl = tcc_ListMaterial(parent, anchorControl, material, listName, i)
	end
	return anchorControl
end

-- Displays the quantity and icon for a single material.
function tcc_ListMaterial(parent, anchorControl, material, listName, listIndex)
	local anchorPoint, anchorRelativePoint, anchorOffsetX, anchorOffsetY = 0
	if anchorControl == nil or anchorControl == parent then 
		anchorControl = parent
		anchorPoint = TOPLEFT
		anchorRelativePoint = TOPLEFT
		anchorOffsetX = 0
	else
		anchorPoint = LEFT
		anchorRelativePoint = RIGHT
		anchorOffsetX = 5
	end
	local matFrame = tcc_GetOrCreateControl(parent, parent:GetName() .. listName .. "_Mat" .. listIndex, CT_CONTROL)
	matFrame:ClearAnchors()
	matFrame:SetAnchor(anchorPoint, anchorControl, anchorRelativePoint, anchorOffsetX, anchorOffsetY)
	matFrame:SetHidden(false)
	matFrame.Active = true
	local qtyLabel = tcc_GetOrCreateControl(matFrame, matFrame:GetName() .. "Qty", CT_LABEL)
	qtyLabel:SetFont("tcc_ZoFontBookRubbingSmallShadow")
	qtyLabel:SetText(material.MaterialTotalQuantity)
	qtyLabel:ClearAnchors()
	qtyLabel:SetAnchor(TOPLEFT, matFrame, TOPLEFT, 0, 0)
	qtyLabel:SetHidden(false)
	-- tcc_CreateLinkEnabledIcon(parent, controlName, itemLink, texturePath, width, height, anchorPoint, anchorRelativeTo, anchorRelativePoint, anchorOffsetX, anchorOffsetY, additionalTooltipText)
	local matIcon, matTexture = tcc_CreateLinkEnabledIcon(matFrame, matFrame:GetName() .. "Icon", material.MaterialLink, material.MaterialTexture, 26, 26, LEFT, qtyLabel, RIGHT, 0, 0)
	matIcon.ItemName = material.MaterialName
	matIcon.Active = true
	-- Display refineable sub-components for materials, if applicable.
	if tcc.MaterialSubComponents[material.MaterialKey] ~= nil then
		local subOpenParen = tcc_GetOrCreateControl(matFrame, matFrame:GetName() .. "SubOpenParen", CT_LABEL)
		subOpenParen:SetFont("tcc_ZoFontBookRubbingSmallShadow")
		subOpenParen:SetText("(")
		subOpenParen:ClearAnchors()
		subOpenParen:SetAnchor(LEFT, matIcon, RIGHT, 0, 0)
		subOpenParen:SetHidden(false)
		local subQtyLabel = tcc_GetOrCreateControl(matFrame, matFrame:GetName() .. "SubQty", CT_LABEL)
		subQtyLabel:SetFont("tcc_ZoFontBookRubbingSmallShadow")
		subQtyLabel:SetText(tostring(material.MaterialTotalQuantity * tcc.MaterialSubComponents[material.MaterialKey].ComponentMaterialQuantity))
		subQtyLabel:ClearAnchors()
		subQtyLabel:SetAnchor(LEFT, subOpenParen, RIGHT, 0, 0)
		subQtyLabel:SetHidden(false)
		local subMatIcon, subMatTexture = tcc_CreateLinkEnabledIcon(matFrame, matFrame:GetName() .. "SubIcon", tcc.MaterialSubComponents[material.MaterialKey].ComponentMaterialLink, tcc.MaterialSubComponents[material.MaterialKey].ComponentMaterialTexture, 26, 26, LEFT, subQtyLabel, RIGHT, 0, 0)
		subMatIcon.ItemName = tcc.MaterialSubComponents[material.MaterialKey].ComponentMaterialName
		subMatIcon.Active = true
		local subCloseParen = tcc_GetOrCreateControl(matFrame, matFrame:GetName() .. "SubCloseParen", CT_LABEL)
		subCloseParen:SetFont("tcc_ZoFontBookRubbingSmallShadow")
		subCloseParen:SetText(")  ")
		subCloseParen:ClearAnchors()
		subCloseParen:SetAnchor(LEFT, subMatIcon, RIGHT, 0, 0)
		subCloseParen:SetHidden(false)
		matFrame:SetWidth(subCloseParen:GetRight() - matFrame:GetLeft())
	else
		matFrame:SetWidth(matIcon:GetRight() - matFrame:GetLeft())
	end
	matFrame:SetHeight(26)
	return matFrame
end

function tcc_AddMaterialToMaterialsArray(materialsArray, material)
	if material == nil then return materialsArray end
	if materialsArray == nil then materialsArray = {} end
	local numMaterials = table.getn(materialsArray)
	if materialsArray == nil or numMaterials == 0 then 
		materialsArray = { material } 
		return materialsArray
	end
	for i = 1, numMaterials do
		-- If the material Link matches, add the quantity.
		if materialsArray[i].MaterialLink == material.MaterialLink then
			materialsArray[i].MaterialTotalQuantity = materialsArray[i].MaterialTotalQuantity + material.MaterialTotalQuantity
			return materialsArray
		end
	end
	-- If no matching material found, just append to the array.
	table.insert(materialsArray, material)
	return materialsArray
end

-- Returns an itemMaterialSet
function tcc_GetMaterialsNeededForItem(itemLevel, itemType, itemTrait, itemStyle, itemQuality)
	local baseQtyTypeIdentifier
	if itemType["MaterialCategory"] == "Jewelry" then
		baseQtyTypeIdentifier = itemType["Key"]
	else
		baseQtyTypeIdentifier = itemType["MaterialCategory"]
	end
	local materialQty = itemLevel["BaseQty" .. baseQtyTypeIdentifier] + itemType[itemLevel["QtyModifierType"]]
	local itemMaterials
	if itemType["MaterialCategory"] == "Jewelry" then
		itemMaterials = tcc.JewelryItemMaterials[itemLevel["SkillTierJewelry"]]
	else
		itemMaterials = tcc.ItemMaterials[itemLevel["SkillTier"]]
	end
	local materialName = itemMaterials["MaterialName" .. itemType["MaterialCategory"]]
	local materialLink = itemMaterials["MaterialLink" .. itemType["MaterialCategory"]]
	local materialTexture = itemMaterials["MaterialTexture" .. itemType["MaterialCategory"]]
	local traitMaterial, styleMaterial
	local qualityMaterials = {}
	-- tcc_IconObj(iconType, key, name, shortName, itemLink, normalTexture, mouseOverTexture, selectedTexture)
	-- tcc_MaterialObj(materialKey, materialName, craftName, materialQuantity, materialLink, materialTexture)
	if itemTrait ~= nil and itemTrait.Key ~= "None" then traitMaterial = tcc_MaterialObj(itemTrait.Key, itemTrait.MaterialName, nil, 1, itemTrait.ItemLink, itemTrait.NormalTexture) end
	if itemStyle ~= nil and itemStyle.Key ~= "Any" then styleMaterial = tcc_MaterialObj(itemStyle.Key, itemStyle.MaterialName, nil, 1, itemStyle.ItemLink, itemStyle.NormalTexture) end
	if itemQuality ~= nil and itemQuality.Key ~= "White" then 
		for i = 2, table.getn(tcc.ItemQualityNames) do
			table.insert(qualityMaterials, tcc.QualityMats[itemType.CraftName][tcc.ItemQualityNames[i]])
			if tcc.ItemQualityNames[i] == itemQuality.Key then break end
		end
	end
	return {
		BaseMaterial = tcc_MaterialObj(materialName, materialName, itemType.CraftName, materialQty, materialLink, materialTexture),
		TraitMaterial = traitMaterial,
		StyleMaterial = styleMaterial,
		QualityGreenMaterial = qualityMaterials[1],
		QualityBlueMaterial = qualityMaterials[2],
		QualityPurpleMaterial = qualityMaterials[3],
		QualityGoldMaterial = qualityMaterials[4],
	}
end

-- Generate a "master list" of materials (combine like-materials, sum quantities, and regroup as we want them displayed).
-- Note: itemMaterialSets is an *array* of the objects returned by tcc_GetMaterialsNeededForItem().
function tcc_GetCollatedMaterialsList(itemMaterialSets)
	local collatedMaterialsList = {}
	if itemMaterialSets == nil or table.getn(itemMaterialSets) == 0 then return collatedMaterialsList end
	for i, materialGroupName in ipairs(materialGroupNames) do
		collatedMaterialsList[materialGroupName] = {}
	end
	local itemMaterialSetsCopy = tcc_DeepCopyTable(itemMaterialSets)
	for i, itemMaterialSet in ipairs(itemMaterialSetsCopy) do
		collatedMaterialsList[itemMaterialSet.BaseMaterial.CraftName .. "BaseMaterials"] = tcc_AddMaterialToMaterialsArray(collatedMaterialsList[itemMaterialSet.BaseMaterial.CraftName .. "BaseMaterials"], itemMaterialSet.BaseMaterial)
		collatedMaterialsList["TraitMaterials"] = tcc_AddMaterialToMaterialsArray(collatedMaterialsList["TraitMaterials"], itemMaterialSet.TraitMaterial)
		collatedMaterialsList["StyleMaterials"] = tcc_AddMaterialToMaterialsArray(collatedMaterialsList["StyleMaterials"], itemMaterialSet.StyleMaterial)
		if itemMaterialSet.QualityGreenMaterial ~= nil then collatedMaterialsList[itemMaterialSet.QualityGreenMaterial.CraftName .. "QualityMaterials"] = tcc_AddMaterialToMaterialsArray(collatedMaterialsList[itemMaterialSet.QualityGreenMaterial.CraftName .. "QualityMaterials"], itemMaterialSet.QualityGreenMaterial) end
		if itemMaterialSet.QualityBlueMaterial ~= nil then collatedMaterialsList[itemMaterialSet.QualityBlueMaterial.CraftName .. "QualityMaterials"] = tcc_AddMaterialToMaterialsArray(collatedMaterialsList[itemMaterialSet.QualityBlueMaterial.CraftName .. "QualityMaterials"], itemMaterialSet.QualityBlueMaterial) end
		if itemMaterialSet.QualityPurpleMaterial ~= nil then collatedMaterialsList[itemMaterialSet.QualityPurpleMaterial.CraftName .. "QualityMaterials"] = tcc_AddMaterialToMaterialsArray(collatedMaterialsList[itemMaterialSet.QualityPurpleMaterial.CraftName .. "QualityMaterials"], itemMaterialSet.QualityPurpleMaterial) end
		if itemMaterialSet.QualityGoldMaterial ~= nil then collatedMaterialsList[itemMaterialSet.QualityGoldMaterial.CraftName .. "QualityMaterials"] = tcc_AddMaterialToMaterialsArray(collatedMaterialsList[itemMaterialSet.QualityGoldMaterial.CraftName .. "QualityMaterials"], itemMaterialSet.QualityGoldMaterial) end
	end
	return collatedMaterialsList
end

-- Groups all required order item materials into an array of arrays
function tcc_GetOrderItemMaterialSets()
	local itemMaterialSets = {}
    local datalist = ZO_ScrollList_GetDataList(tccOrderList)
	for listIdx, listItem in ipairs(datalist) do
		table.insert(itemMaterialSets, listItem.data.ItemMaterials)
	end
	return itemMaterialSets
end

function tcc_ToggleImprovementSkillsBox()
	tccImprovementSkillsBox:SetHidden(tccImprovementSkillsBox:IsHidden() == false)
	tccToggleImprovementSkillsButton:SetText((tccImprovementSkillsBox:IsHidden() and "Show" or "Hide") .. " Item Improvement Skills")
	if tccImprovementSkillsBox:IsHidden() == false then tcc_PopulateImprovementSkillsBox() end
end

function tcc_PopulateImprovementSkillsBox()
	tcc.ItemBuilder.SelectedImprovementRank = {
		["Blacksmithing"] = tcc_GetCurrentAbilityRank(SKILL_TYPE_TRADESKILL, tcc.Crafts["Blacksmithing"].SkillIndex, TCC_CRAFT_SKILL_IMPROVEMENT_INDEX["Blacksmithing"]),
		["Clothing"] = tcc_GetCurrentAbilityRank(SKILL_TYPE_TRADESKILL, tcc.Crafts["Clothing"].SkillIndex, TCC_CRAFT_SKILL_IMPROVEMENT_INDEX["Clothing"]),
		["Woodworking"] = tcc_GetCurrentAbilityRank(SKILL_TYPE_TRADESKILL, tcc.Crafts["Woodworking"].SkillIndex, TCC_CRAFT_SKILL_IMPROVEMENT_INDEX["Woodworking"]),
		["Jewelry"] = tcc_GetCurrentAbilityRank(SKILL_TYPE_TRADESKILL, tcc.Crafts["Jewelry"].SkillIndex, TCC_CRAFT_SKILL_IMPROVEMENT_INDEX["Jewelry"]),
	}
	tccImprovementSkillsSubtitle:SetText("Choose the crafter's item improvement skill that\nwill be used to calculate how many improvement\nmaterials are needed (Tempering Alloy, etc.)")
	local currentSkillLevel = tonumber(tccCurrentCraftingSkillLevel:GetText())
	if currentSkillLevel == nil then currentSkillLevel = 0 end
	-- Hide any existing info
	if tccImprovementSkillsFrame:GetNumChildren() > 0 then
		for i = 1, tccImprovementSkillsFrame:GetNumChildren() do
			tccImprovementSkillsFrame:GetChild(i):SetHidden(true)
		end
	end
	local anchor
	anchor = tcc_PopulateImprovementSkillForCraft(tcc.Crafts["Blacksmithing"], currentSkillLevel, tccImprovementSkillsFrame)
	anchor = tcc_PopulateImprovementSkillForCraft(tcc.Crafts["Clothing"], currentSkillLevel, anchor)
	anchor = tcc_PopulateImprovementSkillForCraft(tcc.Crafts["Woodworking"], currentSkillLevel, anchor)
	anchor = tcc_PopulateImprovementSkillForCraft(tcc.Crafts["Jewelry"], currentSkillLevel, anchor)
end

function tcc_PopulateImprovementSkillForCraft(craft, currentSkillLevel, anchor)
	-- tcc_CraftingPassiveObj(nameGeneric, name, description, texture, rankAvailableAtSkillLevelArray)
	local child, row, rowLabel, icon, iconTexture, rankTbl, colWidths, matTbl, matLbl
	local numRanks, currentRank, cellLabel, tooltip
	local passive = craft.Passives[TCC_CRAFT_SKILL_IMPROVEMENT_INDEX[craft.CraftName]]
	local name = passive.Name
	row = tcc_GetOrCreateControl(tccImprovementSkillsFrame, "tccImprovementSkill" .. name, CT_CONTROL)
	row:SetAnchor(TOPLEFT, anchor, (anchor == tccImprovementSkillsFrame and TOPLEFT or BOTTOMLEFT), 0, 17) --(anchor == tccImprovementSkillsFrame and 15 or 10))
	row:SetDimensions(tccImprovementSkillsFrame:GetWidth(), 64)
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
	tcc_RegisterSkillAbilityTooltip(icon, SKILL_TYPE_TRADESKILL, craft.SkillIndex, TCC_CRAFT_SKILL_IMPROVEMENT_INDEX[craft.CraftName])
	rowLabel = tcc_GetOrCreateControl(row, row:GetName() .. "Label", CT_LABEL)
	rowLabel:SetAnchor(TOPLEFT, icon, TOPRIGHT, 5, -15)
	rowLabel:SetFont("tcc_ZoFontBookRubbingSmallShadow")
	rowLabel:SetColor(1, 1, 1, 1)
	rowLabel:SetText(craft.CraftName .. " " .. passive.Name)
	numRanks = table.getn(passive.RankAvailableAtSkillLevelArray)
	colWidths = {100}				-- Row header
	for i = 0, numRanks do
		table.insert(colWidths, 27)	-- Rank cell
	end
	--table.insert(colWidths, 160)	-- Per Upgrade cell
	-- tcc_DrawTable(parent, tableName, numRows, colWidthsArray, hasHeaderRow)
	rankTbl = tcc_DrawTable(row, row:GetName() .. "Ranks", 1, colWidths, false)
	rankTbl:SetAnchor(TOPLEFT, rowLabel, BOTTOMLEFT, 0, 1)
	rankTbl.CellLabels[1][1]:SetText("Ability rank:")
	matLbl = tcc_GetOrCreateControl(row, row:GetName() .. "Mats", CT_LABEL)
	matLbl:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	matLbl:SetColor(0.81, 0.86, 0.74, 1)
	matLbl:ClearAnchors()
	matLbl:SetAnchor(TOPLEFT, rankTbl.CellLabels[1][1], BOTTOMLEFT, 0, 6)
	matLbl:SetText("Per upgrade: ")
	for rank = 0, table.getn(passive.RankAvailableAtSkillLevelArray) do
		currentRank = tcc_GetCurrentAbilityRank(SKILL_TYPE_TRADESKILL, craft.SkillIndex, TCC_CRAFT_SKILL_IMPROVEMENT_INDEX[craft.CraftName])
		cellLabel = rankTbl.CellLabels[1][rank+2]
		cellLabel:GetParent():SetHandler("OnMouseDown", function() tcc_SelectImprovementSkillRank(craft.CraftName, rank, rankTbl, matLbl) end)
		if rank == 0 then 
			cellLabel:SetColor(0, 1, 0, 1)
			--tooltip = ""
		else
			if currentRank >= rank then 
				cellLabel:SetColor(0, 1, 0, 1) 
				--tooltip = "Your character has purchased this rank."
			else
				cellLabel:SetColor(0.81, 0.86, 0.74, 1) 
				--tooltip = "Your character has not yet purchased this rank."
			end
		end
		--if tcc.ItemBuilder.SelectedImprovementRank[craft.CraftName] == rank then
		--	-- SetCenterColor(number r, number g, number b, number a)
		--	cellLabel:GetParent():SetCenterColor(1, 0.5, 0, 1)
		--	tooltip = tooltip .. (tooltip == "" and "" or "\n") .. "THIS IS THE SELECTED SKILL RANK for calculating improvement material quantities."
		--else
		--	tooltip = tooltip .. (tooltip == "" and "" or "\n") .. "Click to select this skill rank for calculating improvement material quantities."
		--end
		--tcc_RegisterTextTooltip(cellLabel:GetParent(), tooltip)
		cellLabel:SetText(rank)
	end
	tcc_SelectImprovementSkillRank(craft.CraftName, tcc.ItemBuilder.SelectedImprovementRank[craft.CraftName], rankTbl, matLbl)
	-- smithImprovementMatQtyIndex = 1 + tcc_GetCurrentAbilityRank(SKILL_TYPE_TRADESKILL, TCC_SKILL_INDEX_BLACKSMITHING, 6)
	return anchor
end

function tcc_SelectImprovementSkillRank(craftName, selectedRank, rankTbl, perUpgradeLabel)
	tcc.ItemBuilder.SelectedImprovementRank[craftName] = selectedRank
	local improvementMatQtyIndex = 1 + selectedRank
	-- Equivalent to ternary operator:  (itemTypeName == key) ? "down" : "up" 
	local greenQty = 	tcc.ItemQuality.Green.UpgradeMatQtyPerImprovementPassiveRank[improvementMatQtyIndex]
	local blueQty = 	tcc.ItemQuality.Blue.UpgradeMatQtyPerImprovementPassiveRank[improvementMatQtyIndex]
	local purpleQty = 	tcc.ItemQuality.Purple.UpgradeMatQtyPerImprovementPassiveRank[improvementMatQtyIndex]
	local goldQty = 	tcc.ItemQuality.Gold.UpgradeMatQtyPerImprovementPassiveRank[improvementMatQtyIndex]
	local greenQtyLabel, blueQtyLabel, purpleQtyLabel, goldQtyLabel
	local greenIcon, greenIconTexture, blueIcon, blueIconTexture, purpleIcon, purpleIconTexture, goldIcon, goldIconTexture
	local rank, cellLabel, tooltip
	
	-- Update the QualityMats material quantities
	tcc.QualityMats[craftName].Green.MaterialQuantity =  tcc.ItemQuality.Green.UpgradeMatQtyPerImprovementPassiveRank[1 + selectedRank]
	tcc.QualityMats[craftName].Blue.MaterialQuantity =   tcc.ItemQuality.Blue.UpgradeMatQtyPerImprovementPassiveRank[1 + selectedRank]
	tcc.QualityMats[craftName].Purple.MaterialQuantity = tcc.ItemQuality.Purple.UpgradeMatQtyPerImprovementPassiveRank[1 + selectedRank]
	tcc.QualityMats[craftName].Gold.MaterialQuantity =   tcc.ItemQuality.Gold.UpgradeMatQtyPerImprovementPassiveRank[1 + selectedRank]
	tcc.QualityMats[craftName].Green.MaterialTotalQuantity =  tcc.QualityMats[craftName].Green.MaterialQuantity
	tcc.QualityMats[craftName].Blue.MaterialTotalQuantity =   tcc.QualityMats[craftName].Blue.MaterialQuantity
	tcc.QualityMats[craftName].Purple.MaterialTotalQuantity = tcc.QualityMats[craftName].Purple.MaterialQuantity
	tcc.QualityMats[craftName].Gold.MaterialTotalQuantity =   tcc.QualityMats[craftName].Gold.MaterialQuantity

	-- Highlight the selected rank
	for rank = 0, 3 do
		cellLabel = rankTbl.CellLabels[1][rank+2]
		if selectedRank == rank then
			-- SetCenterColor(number r, number g, number b, number a)
			cellLabel:GetParent():SetCenterColor(1, 0.5, 0, 1)
			tooltip = "THIS IS THE SELECTED SKILL RANK for calculating improvement material quantities."
		else
			cellLabel:GetParent():SetCenterColor(0, 0, 0, 0)
			tooltip = "Click to select this skill rank for calculating improvement material quantities."
		end
		tcc_RegisterTextTooltip(cellLabel:GetParent(), tooltip)
	end

	greenQtyLabel = tcc_GetOrCreateControl(perUpgradeLabel, perUpgradeLabel:GetName() .. "_GreenQty", CT_LABEL)
	greenQtyLabel:ClearAnchors()
	greenQtyLabel:SetAnchor(LEFT, perUpgradeLabel, RIGHT, 10, 0)
	greenQtyLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	greenQtyLabel:SetColor(0, 1, 0, 1) --(0.81, 0.86, 0.74, 1)
	greenQtyLabel:SetText(greenQty)
	-- tcc_CreateLinkEnabledIcon(parent, controlName, itemLink, texturePath, width, height, anchorPoint, anchorRelativeTo, anchorRelativePoint, anchorOffsetX, anchorOffsetY, additionalTooltipText)
	greenIcon, greenIconTexture = tcc_CreateLinkEnabledIcon(perUpgradeLabel, perUpgradeLabel:GetName() .. "_GreenIcon", tcc.QualityMats[craftName]["Green"].MaterialLink, tcc.QualityMats[craftName]["Green"].MaterialTexture, 20, 20, LEFT, greenQtyLabel, RIGHT, 1, 0, nil)
	blueQtyLabel = tcc_GetOrCreateControl(perUpgradeLabel, perUpgradeLabel:GetName() .. "_BlueQty", CT_LABEL)
	blueQtyLabel:ClearAnchors()
	blueQtyLabel:SetAnchor(LEFT, greenIconTexture, RIGHT, 5, 0)
	blueQtyLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	blueQtyLabel:SetColor(0.2, 0.2, 1, 1) --(0.81, 0.86, 0.74, 1)
	blueQtyLabel:SetText(blueQty)
	blueIcon, blueIconTexture = tcc_CreateLinkEnabledIcon(perUpgradeLabel, perUpgradeLabel:GetName() .. "_BlueIcon", tcc.QualityMats[craftName]["Blue"].MaterialLink, tcc.QualityMats[craftName]["Blue"].MaterialTexture, 20, 20, LEFT, blueQtyLabel, RIGHT, 1, 0, nil)
	purpleQtyLabel = tcc_GetOrCreateControl(perUpgradeLabel, perUpgradeLabel:GetName() .. "_PurpleQty", CT_LABEL)
	purpleQtyLabel:ClearAnchors()
	purpleQtyLabel:SetAnchor(LEFT, blueIconTexture, RIGHT, 5, 0)
	purpleQtyLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	purpleQtyLabel:SetColor(1, 0, 1, 1) --(0.81, 0.86, 0.74, 1)
	purpleQtyLabel:SetText(purpleQty)
	purpleIcon, purpleIconTexture = tcc_CreateLinkEnabledIcon(perUpgradeLabel, perUpgradeLabel:GetName() .. "_PurpleIcon", tcc.QualityMats[craftName]["Purple"].MaterialLink, tcc.QualityMats[craftName]["Purple"].MaterialTexture, 20, 20, LEFT, purpleQtyLabel, RIGHT, 1, 0, nil)
	goldQtyLabel = tcc_GetOrCreateControl(perUpgradeLabel, perUpgradeLabel:GetName() .. "_GoldQty", CT_LABEL)
	goldQtyLabel:ClearAnchors()
	goldQtyLabel:SetAnchor(LEFT, purpleIconTexture, RIGHT, 5, 0)
	goldQtyLabel:SetFont(tcc.FONT_TABLE_CELL_MEDIUM)
	goldQtyLabel:SetColor(1, 1, 0, 1) --(0.81, 0.86, 0.74, 1)
	goldQtyLabel:SetText(goldQty)
	goldIcon, goldIconTexture = tcc_CreateLinkEnabledIcon(perUpgradeLabel, perUpgradeLabel:GetName() .. "_GoldIcon", tcc.QualityMats[craftName]["Gold"].MaterialLink, tcc.QualityMats[craftName]["Gold"].MaterialTexture, 20, 20, LEFT, goldQtyLabel, RIGHT, 1, 0, nil)
	
	-- Update the Item Builder item and all Item Order items
	tcc_UpdateItemSummary()
	tcc_UpdateOrderItemMaterialQuantities()
end

function tcc_InitItemTraitIcons(rowControl)
	local label = tcc_GetOrCreateControlFromVirtual(rowControl, rowControl:GetName() .. "Label", "tccRowLabelTemplate")
	label:SetText("Trait: ")
	local anchorControl = label
	-- tcc_InitIcon(parentControl, anchorControl, iconData, onClickFunction)
	tcc.ItemTraitIcons = { tcc_InitIcon(rowControl, anchorControl, tcc.ItemTraits["None"], tcc_SelectItemTrait) }
	anchorControl = tcc.ItemTraitIcons[1]
	for traitTypeName, traits in pairs(tcc.ItemTraits) do
		if traitTypeName == "Armor" or traitTypeName == "Weapon" or traitTypeName == "Jewelry" then
			anchorControl = tcc.ItemTraitIcons[1]
			local traitFrame = tcc_GetOrCreateControl(rowControl, "tcc" .. traitTypeName .. "Trait", CT_CONTROL)
			traitFrame:SetDimensions(285, 32)
			traitFrame:SetAnchor(LEFT, anchorControl, RIGHT, 0, 0)
			for i, trait in ipairs(traits) do
				local icon = tcc_InitIcon(traitFrame, anchorControl, trait, tcc_SelectItemTrait)
				table.insert(tcc.ItemTraitIcons, icon)
				anchorControl = icon
			end
			if traitTypeName ~= "Armor" then traitFrame:SetHidden(true) end
		end
	end
	local selected = tcc_GetOrCreateControlFromVirtual(rowControl, rowControl:GetName() .. "Selected", "tccSelectedArrowTemplate")
	selected:SetAnchor(TOP, tcc.ItemTraitIcons[1], BOTTOM, 0, 0)
end

function tcc_InitItemQualityIcons(rowControl)
	local label = tcc_GetOrCreateControlFromVirtual(rowControl, rowControl:GetName() .. "Label", "tccRowLabelTemplate")
	label:SetText("Quality: ")
	tcc.ItemQualityIcons = { }
	local anchorControl = label
	for i, qualityName in ipairs(tcc.ItemQualityNames) do
		-- tcc_InitIcon(parentControl, anchorControl, iconData, onClickFunction)
		local icon = tcc_InitIcon(rowControl, anchorControl, tcc.ItemQuality[qualityName], tcc_SelectItemQuality)
		table.insert(tcc.ItemQualityIcons, icon)
		anchorControl = icon
	end
	local selected = tcc_GetOrCreateControlFromVirtual(rowControl, rowControl:GetName() .. "Selected", "tccSelectedArrowTemplate")
	selected:SetAnchor(TOP, tcc.ItemQualityIcons[1], BOTTOM, 0, 0)
end

function tcc_InitRacialStyleDropdown(rowControl)
	local label = tcc_GetOrCreateControlFromVirtual(rowControl, rowControl:GetName() .. "Label", "tccRowLabelTemplate")
	label:SetText("Racial Style: ")
	local itemStyleDropdown = tcc_GetOrCreateControlFromVirtual(rowControl, "tccItemStyleDropdown", "tccDropdownTemplate")
	itemStyleDropdown:SetDimensions(250, 25)
	itemStyleDropdown:ClearAnchors()
	itemStyleDropdown:SetAnchor(LEFT, label, RIGHT, 5, 0)
	itemStyleDropdown.m_comboBox:SetSortsItems(false)
	itemStyleDropdown.m_comboBox:SetFont("tcc_ZoFontTooltipSubtitleSmall")
	local dropdown = ZO_ComboBox_ObjectFromContainer(itemStyleDropdown)
	--local anyStyle
	for i, itemStyle in ipairs(tcc.RacialStyles) do
		--if itemStyle.Name == "Any" then anyStyle = itemStyle end
		local itemEntry = dropdown:CreateItemEntry(itemStyle.Name, function() tcc_SelectItemStyle(itemStyle) end)
		itemEntry.ItemStyle = itemStyle
		dropdown:AddItem(itemEntry)
	end
	--dropdown:SetSelectedItem("Any")
	--tcc_SelectItemStyle(anyStyle)
	tcc_SelectItemStyleAny()
end

function tcc_SelectItemStyleAny()
	local dropdown = ZO_ComboBox_ObjectFromContainer(tccItemStyleDropdown)
	for i, itemStyle in ipairs(tcc.RacialStyles) do
		if itemStyle.Name == "Any" then anyStyle = itemStyle end
	end
	dropdown:SetSelectedItem("Any")
	tcc_SelectItemStyle(anyStyle)
end

function tcc_InitItemSetDropdown(rowControl)
	local itemSetDropdown = tcc_GetOrCreateControlFromVirtual(rowControl, "tccItemSetDropdown", "tccDropdownTemplate")
	itemSetDropdown:SetDimensions(250, 25)
	itemSetDropdown:ClearAnchors()
	itemSetDropdown:SetAnchor(TOPRIGHT, rowControl, TOPRIGHT, -10, 0)
	itemSetDropdown.m_comboBox:SetSortsItems(false)
	itemSetDropdown.m_comboBox:SetFont("tcc_ZoFontTooltipSubtitleSmall")
	local itemSetDropdownLabel = tcc_GetOrCreateControlFromVirtual(rowControl, "tccItemSetDropdownLabel", "tccRowLabelTemplate")
	itemSetDropdownLabel:ClearAnchors()
	itemSetDropdownLabel:SetAnchor(RIGHT, itemSetDropdown, LEFT, -5, 0)
	itemSetDropdownLabel:SetText("Set:")
	local dropdown = ZO_ComboBox_ObjectFromContainer(itemSetDropdown)
	local noSet
	for i, itemSet in ipairs(tcc.ItemSets) do
		if itemSet.ShortName == "None" then noSet = itemSet end
		local itemEntry = dropdown:CreateItemEntry(itemSet.LongName, function() tcc_SelectItemSet(itemSet) end)
		itemEntry.ItemSet = itemSet
		dropdown:AddItem(itemEntry)
	end
	dropdown:SetSelectedItem("None")
	tcc_SelectItemSet(noSet)
end

function tcc_CopyOrderToMail()
	local summary = tcc_GetOrderSummaryText("\n", false)
	if summary ~= "" then tcc_PasteToMail("", "TCC: Order Summary", summary) end
end

function tcc_CopyOrderToChat()
	local summary = tcc_GetOrderSummaryText("; ", true)
	if summary ~= "" then tcc_PasteToChat(summary) end
end

function tcc_CopyOrderToClipboard()
	local summary = tcc_GetOrderSummaryText("\n", true)
	if summary ~= "" then tcc_CopyToClipboard(summary) end
end

function tcc_CopyMaterialsToMail()
	local summary = tcc_GetMaterialsSummaryText("\n", 8)
	if summary ~= "" then tcc_PasteToMail("", "TCC: Summary of Materials Needed", summary) end
end

function tcc_CopyMaterialsToChat()
	local summary = tcc_GetMaterialsSummaryText(", ", 4)
	if summary ~= "" then tcc_PasteToChat(summary) end
end

function tcc_CopyMaterialsToClipboard()
	local summary = tcc_GetMaterialsSummaryText("\n", 0)
	if summary ~= "" then tcc_CopyToClipboard(summary) end
end

function tcc_GetOrderSummaryText(delimiter, stripColors)
	local summary = ""
    local datalist = ZO_ScrollList_GetDataList(tccOrderList)
	for listIdx, listItem in ipairs(datalist) do
		if listIdx > 1 then summary = summary .. delimiter end
		if listItem.data.ItemQty > 1 then summary = summary .. "(" .. (stripColors and listItem.data.ItemQty or "|c00FF00" .. listItem.data.ItemQty .. "|r") .. ") " end
		summary = summary .. (stripColors and tcc_StripColorTags(listItem.data.ItemText) or listItem.data.ItemText)
	end
	if tcc.IntegrateMM and summary ~= "" and tccTotalMaterialsCost:GetText() ~= "-" then
		summary = summary .. delimiter .. "Total MM Price: " .. tccTotalMaterialsCost:GetText() .. "g"
	end
	return summary
end

function tcc_GetMaterialsSummaryText(delimiter, maxLinks)
	local summary = ""
	collatedMaterialsList = tcc_GetCollatedMaterialsList(tcc_GetOrderItemMaterialSets())
	local numLinks = 0
	for i, materialGroupName in ipairs(materialGroupNames) do
		if collatedMaterialsList[materialGroupName] ~= nil and table.getn(collatedMaterialsList[materialGroupName]) > 0 then 
			for j, material in ipairs(collatedMaterialsList[materialGroupName]) do
				if summary ~= "" then summary = summary .. delimiter end
				summary = summary .. material.MaterialTotalQuantity .. " "
				if maxLinks ~= nil and numLinks >= maxLinks then 
					summary = summary .. material.MaterialName 
				else 
					summary = summary .. material.MaterialLink 
					numLinks = numLinks + 1
				end
				-- Display refineable sub-components for materials, if applicable.
				local component = tcc.MaterialSubComponents[material.MaterialKey]
				if component ~= nil then
					summary = summary .. " (or " .. (component.ComponentMaterialQuantity * material.MaterialTotalQuantity) .. " "
					if maxLinks ~= nil and numLinks >= maxLinks then 
						summary = summary .. component.ComponentMaterialName
					else
						summary = summary .. component.ComponentMaterialLink
						numLinks = numLinks + 1
					end
					summary = summary .. ")"
				end
			end
		end
	end
	if tcc.IntegrateMM and summary ~= "" and tccTotalMaterialsCost:GetText() ~= "-" then
		summary = summary .. delimiter .. "Total MM Price: " .. tccTotalMaterialsCost:GetText() .. "g"
	end
	return summary
end


--[[ Total Materials Required Horizontal Scroll List Functions ]]--

function tcc_UpdateHorizontalScrollListDisplay(scrollListControl)
	if scrollListControl == nil then return end
	if scrollListControl:GetNumChildren() == nil or scrollListControl:GetNumChildren() == 0 then return end
	local left = scrollListControl:GetNamedChild("LeftArrow")
	local right = scrollListControl:GetNamedChild("RightArrow")
	local items = scrollListControl:GetNamedChild("ListItems")
	local hideLeft = true
	local hideRight = true
	if items:GetNumChildren() > 0 then
		-- Note: The leftmost icon might not be at array index 1, and the rightmost icon might not be at the max array index!
		local minLeft = 5000
		local maxRight = 0
		for i = 1, items:GetNumChildren() do
			local item = items:GetChild(i)
			if item.Active and item:GetLeft() < minLeft then minLeft = item:GetLeft() end
			if item.Active and item:GetRight() > maxRight then maxRight = item:GetRight() end
			item:SetHidden(item:GetLeft() < left:GetRight() or item:GetRight() > right:GetLeft())
		end
		hideLeft = (minLeft >= left:GetRight())
		hideRight = (maxRight <= right:GetLeft())
	end
	left:SetHidden(hideLeft)
	right:SetHidden(hideRight)
end

function tcc_ShiftHorizontalScrollList(arrowControl)
	local parent = arrowControl:GetParent()
	local items = parent:GetNamedChild("ListItems")
	if items:GetNumChildren() == 0 then return end
	local shiftLeft = (string.find(arrowControl:GetName(), "RightArrow") ~= nil)
	local shiftRight = (string.find(arrowControl:GetName(), "LeftArrow") ~= nil)
	--if string.match(arrowControl:GetName(), "RightArrow") then directionMultiplier = -1 end
	local shiftX = 0
	-- Get the width of the leftmost item to be shown/hidden; this will be the amount we'll shift by
	for i = 1, items:GetNumChildren() do
		local item = items:GetChild(i)
		if item:IsHidden() == false then
			if shiftLeft and items:GetChild(i+1) ~= nil then shiftX = -1 * (items:GetChild(i+1):GetLeft() - item:GetLeft()) end
			if shiftRight and i > 1 then shiftX = item:GetLeft() - items:GetChild(i-1):GetLeft() end
			break
		end
	end
	--tccTestLabel:SetText("shiftLeft = " .. tostring(shiftLeft) .. "\nshiftRight = " .. tostring(shiftRight) .. "\nshiftX = " .. shiftX)
	-- Move the entire item list
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = items:GetAnchor(0)
	items:ClearAnchors()
	if isValidAnchor then items:SetAnchor(point, relativeTo, relativePoint, offsetX + shiftX, offsetY) end
	tcc_UpdateHorizontalScrollListDisplay(parent)
end


--[[ Order Item List Functions ]]--

function tcc_ClearOrder()
    local datalist = ZO_ScrollList_GetDataList(tccOrderList)
	for listIdx = table.getn(datalist), 1, -1 do table.remove(datalist, listIdx) end
	ZO_ScrollList_Commit(tccOrderList, datalist)
	tcc_UpdateOrderItemMaterials()
end

function tcc_RemoveOrderItem(control)
	local rowControl = control:GetParent()
    local datalist = ZO_ScrollList_GetDataList(tccOrderList)
	for listIdx = table.getn(datalist), 1, -1 do
		local listItem = datalist[listIdx]
		if listItem.data.ItemText == rowControl.ItemText then
			table.remove(datalist, listIdx)
			ZO_ScrollList_Commit(tccOrderList, datalist)
			tcc_UpdateOrderItemMaterials()
			return
		end
	end
end

function tcc_SetOrderItem(control, data)
	-- tccOrderList1Row1 .. "Item"
	control.ItemText = data.ItemText
	local qtyEditBox = control:GetNamedChild("Qty"):GetNamedChild("BG"):GetNamedChild("Value")
	local levelLabel = control:GetNamedChild("Level"):GetNamedChild("Text")
	-- TODO: Implement dropdowns in the Item Order grid.
	--[[
	local levelCell = control:GetNamedChild("Level")
	local levelDropdown = tcc_GetOrCreateControlFromVirtual(levelCell, control:GetName() .. "LevelText", "tccDropdownTemplate")
	levelDropdown:SetDimensions(levelCell:GetWidth(), levelCell:GetHeight())
	levelDropdown:ClearAnchors()
	levelDropdown:SetAnchor(TOPLEFT)
	levelDropdown:SetAnchor(BOTTOMRIGHT)
	levelDropdown:GetNamedChild("BG"):SetHidden(true)
	levelDropdown.m_comboBox:SetSortsItems(false)
	levelDropdown.m_comboBox:SetFont("tcc_ZoFontTooltipSubtitleSmall")
	local dropdown = ZO_ComboBox_ObjectFromContainer(levelDropdown)
	--local selectedLevel
	for i, itemLevel in ipairs(tcc.ItemLevels) do
		--if tcc.ItemLevels.ItemLevel == data.ItemLevel then selectedLevel = tcc.ItemLevels.ItemLevel end
		local dropdownItem = dropdown:CreateItemEntry(itemLevel.ItemLevel, nil) --function() tcc_SelectItemSet(itemLevel.ItemLevel) end)
		dropdownItem.ItemLevel = itemLevel.ItemLevel
		dropdown:AddItem(dropdownItem)
	end
	dropdown:SetSelectedItem(data.ItemLevel)
	--tcc_SelectItemSet(selectedLevel)
	]]
	local itemLabel = control:GetNamedChild("Item"):GetNamedChild("Text")
	local traitLabel = control:GetNamedChild("Trait"):GetNamedChild("Text")
	local qualityLabel = control:GetNamedChild("Quality"):GetNamedChild("Text")
	local styleLabel = control:GetNamedChild("Style"):GetNamedChild("Text")
	local setLabel = control:GetNamedChild("Set"):GetNamedChild("Text")
	qtyEditBox:SetText(data.ItemQty)
	levelLabel:SetText(data.ItemLevel)
	itemLabel:SetText(data.ItemName)
	traitLabel:SetText(data.ItemTrait)
	qualityLabel:SetText(data.ItemQuality)
	styleLabel:SetText(data.ItemStyle)
	setLabel:SetText(data.ItemSet)
end

function tcc_AddItemToOrder(itemQty, itemBuilder)
	if itemBuilder == nil then return end
	if itemBuilder.Level == nil or itemBuilder.ItemType == nil then return end
    local datalist = ZO_ScrollList_GetDataList(tccOrderList)
	for listIdx, listItem in ipairs(datalist) do
		if listItem.data.ItemText == itemBuilder.ItemText then
			listItem.data.ItemQty = tonumber(listItem.data.ItemQty) + tonumber(itemQty)
			ZO_ScrollList_Commit(tccOrderList, datalist)
			ZO_ScrollList_ScrollDataIntoView(tccOrderList, listIdx)
			tcc_UpdateMaterialsQty(datalist, listItem)
			return
		end
	end
	-- use a copy of the ItemBuilder, so we don't skew the original material quantities
	local itemBuilderCopy = tcc_DeepCopyTable(itemBuilder)
	-- Syntax:  ZO_ScrollList_CreateDataEntry(typeId, data, categoryId)
	datalist[table.getn(datalist) + 1] = ZO_ScrollList_CreateDataEntry(
		1, { 
			ItemText = itemBuilderCopy.ItemText,
			ItemType = itemBuilderCopy.ItemType,
			ItemQty = itemQty, 
			ItemLevel = itemBuilderCopy.Level.ItemLevel,
			ItemName = itemBuilderCopy.ItemName,
			ItemTrait = (itemBuilderCopy.Trait.Name ~= "None" and itemBuilderCopy.Trait.Name or "|cFFFFFF(none)|r"),
			ItemQuality = "|c" .. itemBuilderCopy.Quality.ColorCode .. itemBuilderCopy.Quality.Key .. "|r",
			ItemStyle = (itemBuilderCopy.Style.ShortName ~= "Any" and itemBuilderCopy.Style.ShortName or "|cFFFFFF(any)|r"),
			ItemSet = (itemBuilderCopy.Set.ShortName ~= "None" and itemBuilderCopy.Set.ShortName or "|cFFFFFF(none)|r"),
			ItemMaterials = itemBuilderCopy.ItemMaterials,
		}, 1
	)
	ZO_ScrollList_Commit(tccOrderList, datalist)
	tcc_UpdateOrderItemMaterials()
end

function tcc_SaveOrderItemListData(datalist)
	tcc.SavedVars[tcc.SavedVars.Global.Scope.ItemOrder].OrderItemData = tcc_BuildOrderListData(datalist)
end

function tcc_BuildOrderListData(datalist)
	local listItems = {}
	if datalist ~= nil then
		for listIdx, listItem in ipairs(datalist) do
			local itemData = {
				ItemText = listItem.data.ItemText,
				ItemType = listItem.data.ItemType, 
				ItemQty = listItem.data.ItemQty, 
				ItemLevel = listItem.data.ItemLevel,
				ItemName = listItem.data.ItemName,
				ItemTrait = listItem.data.ItemTrait,
				ItemQuality = listItem.data.ItemQuality,
				ItemStyle = listItem.data.ItemStyle,
				ItemSet = listItem.data.ItemSet,
				ItemMaterials = listItem.data.ItemMaterials,
			}
			table.insert(listItems, itemData)
		end
	end
	return listItems
end

function tcc_LoadOrderItemListData()
	tcc_PopulateOrderItemListData(tcc.SavedVars[tcc.SavedVars.Global.Scope.ItemOrder].OrderItemData)
	--ZO_ScrollList_Clear(tccOrderList)
    --local datalist = ZO_ScrollList_GetDataList(tccOrderList)
	--if tcc.SavedVars[tcc.SavedVars.Global.Scope.ItemOrder].OrderItemData ~= nil then
	--	for listIdx, listItem in ipairs(tcc.SavedVars[tcc.SavedVars.Global.Scope.ItemOrder].OrderItemData) do
	--		datalist[listIdx] = ZO_ScrollList_CreateDataEntry(
	--			1, { 
	--				ItemText = listItem.ItemText,
	--				ItemType = listItem.ItemType, 
	--				ItemQty = listItem.ItemQty, 
	--				ItemLevel = listItem.ItemLevel,
	--				ItemName = listItem.ItemName,
	--				ItemTrait = listItem.ItemTrait,
	--				ItemQuality = listItem.ItemQuality,
	--				ItemStyle = listItem.ItemStyle,
	--				ItemSet = listItem.ItemSet,
	--				ItemMaterials = listItem.ItemMaterials,
	--			}, 1
	--		)
	--	end
	--end
	--ZO_ScrollList_Commit(tccOrderList, datalist)
	--tcc_UpdateOrderItemMaterials()
end

function tcc_PopulateOrderItemListData(orderItemData)
	ZO_ScrollList_Clear(tccOrderList)
    local datalist = ZO_ScrollList_GetDataList(tccOrderList)
	if orderItemData ~= nil then
		for listIdx, listItem in ipairs(orderItemData) do
			datalist[listIdx] = ZO_ScrollList_CreateDataEntry(
				1, { 
					ItemText = listItem.ItemText,
					ItemType = listItem.ItemType, 
					ItemQty = listItem.ItemQty, 
					ItemLevel = listItem.ItemLevel,
					ItemName = listItem.ItemName,
					ItemTrait = listItem.ItemTrait,
					ItemQuality = listItem.ItemQuality,
					ItemStyle = listItem.ItemStyle,
					ItemSet = listItem.ItemSet,
					ItemMaterials = listItem.ItemMaterials,
				}, 1
			)
		end
	end
	ZO_ScrollList_Commit(tccOrderList, datalist)
	tcc_UpdateOrderItemMaterials()
end

-- Update Item Order material quantities, if the selected Improvement Skill was changed
function tcc_UpdateOrderItemMaterialQuantities()
    local datalist = ZO_ScrollList_GetDataList(tccOrderList)
	for listIdx, listItem in ipairs(datalist) do
		if listItem.data.ItemMaterials.QualityGreenMaterial ~= nil then listItem.data.ItemMaterials.QualityGreenMaterial.MaterialQuantity = tcc.QualityMats[listItem.data.ItemMaterials.QualityGreenMaterial.CraftName].Green.MaterialQuantity end
		if listItem.data.ItemMaterials.QualityBlueMaterial ~= nil then listItem.data.ItemMaterials.QualityBlueMaterial.MaterialQuantity = tcc.QualityMats[listItem.data.ItemMaterials.QualityBlueMaterial.CraftName].Blue.MaterialQuantity end
		if listItem.data.ItemMaterials.QualityPurpleMaterial ~= nil then listItem.data.ItemMaterials.QualityPurpleMaterial.MaterialQuantity = tcc.QualityMats[listItem.data.ItemMaterials.QualityPurpleMaterial.CraftName].Purple.MaterialQuantity end
		if listItem.data.ItemMaterials.QualityGoldMaterial ~= nil then listItem.data.ItemMaterials.QualityGoldMaterial.MaterialQuantity = tcc.QualityMats[listItem.data.ItemMaterials.QualityGoldMaterial.CraftName].Gold.MaterialQuantity end
		tcc_UpdateMaterialsQty(datalist, listItem)
	end
	for listIdx, listItem in ipairs(ZO_ScrollList_GetDataList(tccOrderList)) do tcc_UpdateMaterialsQty(ZO_ScrollList_GetDataList(tccOrderList), listItem) end
end

-- Update the underlying datalist with the edited Qty value.
function tcc_UpdateOrderItemQty(qtyEditBoxControl)
    local datalist = ZO_ScrollList_GetDataList(tccOrderList)
	for listIdx, listItem in ipairs(datalist) do
		if listItem.data.ItemText == qtyEditBoxControl:GetParent():GetParent():GetParent().ItemText then 
			listItem.data.ItemQty = tonumber(qtyEditBoxControl:GetText())
			tcc_UpdateMaterialsQty(datalist, listItem)
		end
	end
end

function tcc_UpdateMaterialsQty(datalist, listItem)
	if tcc.Updating ~= nil and tcc.Updating == true then return end
	tcc.Updating = true
		listItem.data.ItemMaterials.BaseMaterial.MaterialTotalQuantity = listItem.data.ItemMaterials.BaseMaterial.MaterialQuantity * listItem.data.ItemQty
		if listItem.data.ItemMaterials.TraitMaterial ~= nil then listItem.data.ItemMaterials.TraitMaterial.MaterialTotalQuantity = listItem.data.ItemMaterials.TraitMaterial.MaterialQuantity * listItem.data.ItemQty end
		if listItem.data.ItemMaterials.StyleMaterial ~= nil then listItem.data.ItemMaterials.StyleMaterial.MaterialTotalQuantity = listItem.data.ItemMaterials.StyleMaterial.MaterialQuantity * listItem.data.ItemQty end
		if listItem.data.ItemMaterials.QualityGreenMaterial ~= nil then listItem.data.ItemMaterials.QualityGreenMaterial.MaterialTotalQuantity = listItem.data.ItemMaterials.QualityGreenMaterial.MaterialQuantity * listItem.data.ItemQty end
		if listItem.data.ItemMaterials.QualityBlueMaterial ~= nil then listItem.data.ItemMaterials.QualityBlueMaterial.MaterialTotalQuantity = listItem.data.ItemMaterials.QualityBlueMaterial.MaterialQuantity * listItem.data.ItemQty end
		if listItem.data.ItemMaterials.QualityPurpleMaterial ~= nil then listItem.data.ItemMaterials.QualityPurpleMaterial.MaterialTotalQuantity = listItem.data.ItemMaterials.QualityPurpleMaterial.MaterialQuantity * listItem.data.ItemQty end
		if listItem.data.ItemMaterials.QualityGoldMaterial ~= nil then listItem.data.ItemMaterials.QualityGoldMaterial.MaterialTotalQuantity = listItem.data.ItemMaterials.QualityGoldMaterial.MaterialQuantity * listItem.data.ItemQty end
		ZO_ScrollList_Commit(tccOrderList, datalist)
		tcc_UpdateOrderItemMaterials()
	tcc.Updating = false
end

function tcc_UpdateOrderItemMaterials()
    local datalist = ZO_ScrollList_GetDataList(tccOrderList)
	tcc.NumOrderItems = table.getn(datalist)
	tccOrderListFrameHeader:SetHidden(tcc.NumOrderItems == 0)
	tccOrderListFrameFooter:SetHidden(tcc.NumOrderItems == 0)
	tccOrderTitleRow:GetNamedChild("Clipboard"):SetHidden(tcc.NumOrderItems == 0)
	tccOrderTitleRow:GetNamedChild("Chat"):SetHidden(tcc.NumOrderItems == 0)
	tccOrderTitleRow:GetNamedChild("Mail"):SetHidden(tcc.NumOrderItems == 0)
	tccOrderTitleRow:GetNamedChild("Clear"):SetHidden(tcc.NumOrderItems == 0)
	tcc_ListAllMaterials(tccTotalMaterialsNeededForOrder:GetNamedChild("ListItems"), tcc_GetOrderItemMaterialSets())
	-- Hide the overflowed material icons, if any
	tcc_UpdateHorizontalScrollListDisplay(tccTotalMaterialsNeededForOrder)
	-- Save the order items to SavedVariables
	tcc_SaveOrderItemListData(datalist)
	-- Master Merchant integration
	if tcc.IntegrateMM then tcc_CalculateTotalCostOfMaterials(tccTotalMaterialsCost, tccTotalMaterialsNeededForOrder:GetNamedChild("ListItems")) end
end


--[[ Saved Order List Functions ]]--

function tcc_ShowLoadSaveDialog()
	-- 6/2017 - Overlay is currently broken, in that it blocks the Load/Save dialog.
	-- Syntax: tcc_ShowOverlay(control, r, g, b, a, blockControl)
	--tcc_ShowOverlay(tccUI, 0, 0, 0, 0.8, true)
	tccLoadSaveItemOrder:ClearAnchors()
	--tccLoadSaveItemOrder:SetAnchor(BOTTOMRIGHT, tccOrderTitleRowLoadSave, TOPRIGHT, 25, 0)
	tccLoadSaveItemOrder:SetAnchor(TOPLEFT, tccUI, TOPLEFT, 0, 0)
	tccLoadSaveItemOrder:SetAnchor(BOTTOMRIGHT, tccUI, BOTTOMRIGHT, 0, 0)
	tccLoadSaveItemOrder:BringWindowToTop()
	tccLoadSaveItemOrder:SetHidden(false)
	tccLoadSaveItemOrderTitle:SetText(tcc.NumOrderItems == 0 and "Load Item Order" or "Load/Save Item Order")
	tccAddSavedOrder:SetHidden(tcc.NumOrderItems == 0)
	tccAddSavedOrderButton:SetHidden(tcc.NumOrderItems == 0)
end

function tcc_HideLoadSaveDialog()
	tcc_HideOverlay(tccUI)
	tccLoadSaveItemOrder:SetHidden(true)
end

function tcc_DeleteSavedOrder(orderName)
    local datalist = ZO_ScrollList_GetDataList(tccSavedOrderList)
	for listIdx = table.getn(datalist), 1, -1 do
		local listItem = datalist[listIdx]
		if listItem.data.OrderName == orderName then
			table.remove(datalist, listIdx)
			ZO_ScrollList_Commit(tccSavedOrderList, datalist)
			break
		end
	end
	tcc_SaveSavedOrderListData(datalist)
	tcc_DeleteSavedOrderItemData(orderName)
end

function tcc_LoadSavedOrder(orderName)
	if tcc.SavedVars.Global.SavedOrderItemData == nil then return end
	local orderItemData = tcc.SavedVars.Global.SavedOrderItemData[orderName]
	if orderItemData == nil then return end
	tcc_PopulateOrderItemListData(orderItemData)
	tcc_ShowLoadSaveDialog()
end

function tcc_ReplaceSavedOrder(orderName)
	if orderName == nil or orderName == "" then return end
	tcc_DeleteSavedOrder(orderName)
	tccAddSavedOrderName:SetText(orderName)
	tcc_AddSavedOrderToList()
end

function tcc_SetSavedOrder(rowControl, data)
	-- tccSavedOrderList1Row1 .. "Item"
	local itemLabel = rowControl:GetNamedChild("Item"):GetNamedChild("OrderName")
	local menuButton = rowControl:GetNamedChild("Menu")
	itemLabel:SetText(data.OrderName)
	tcc_RegisterTextTooltip(itemLabel, data.OrderSummary, true)
	menuButton:SetHandler("OnMouseEnter", function() tcc_HighlightText(this) end)
	menuButton:SetHandler("OnMouseExit", function() tcc_UnHighlightText(this) end)
end

function tcc_AddSavedOrderToList()
	local orderName = tccAddSavedOrderName:GetText()
	if orderName == "" then 
		PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
		-- Syntax: tcc_DrawBorder(control, r, g, b, a, thickness, offset)
		tcc_DrawBorder(tccAddSavedOrder, 1, 0, 0, 1, 1, 0)
		tccAddSavedOrderName:TakeFocus()
		return 
	else
		tcc_HideBorder(tccAddSavedOrder)
	end
    local datalist = ZO_ScrollList_GetDataList(tccSavedOrderList)
	-- Make sure this order name isn't already in the list
	for listIdx, listItem in ipairs(datalist) do
		if listItem.data.OrderName == orderName then 
			PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
			tcc_DrawBorder(tccAddSavedOrder, 1, 0, 0, 1, 1, 0)
			ZO_ScrollList_ScrollDataIntoView(tccSavedOrderList, listIdx)
			tccAddSavedOrderName:TakeFocus()
			return
		end
	end
	-- Syntax:  ZO_ScrollList_CreateDataEntry(typeId, data, categoryId)
	datalist[table.getn(datalist) + 1] = ZO_ScrollList_CreateDataEntry(
		1, { 
			OrderName = orderName,
			OrderSummary = tcc_GetOrderSummaryText("\n", false),
		}, 1
	)
	ZO_ScrollList_Commit(tccSavedOrderList, datalist)
	tcc_SaveSavedOrderListData(datalist)
	-- TODO: Optimize the way item data is stored in SavedVars.
	tcc_SaveSavedOrderItemData(orderName)
	tccAddSavedOrderName:SetText("")
end

function tcc_SaveSavedOrderListData(datalist)
	local listItems = {}
	if datalist ~= nil then
		for listIdx, listItem in ipairs(datalist) do
			local itemData = {
				OrderName = listItem.data.OrderName,
				OrderSummary = listItem.data.OrderSummary,
			}
			table.insert(listItems, itemData)
		end
	end
	tcc.SavedVars.Global.SavedOrderListData = listItems
end

function tcc_SaveSavedOrderItemData(orderName)
	if tcc.SavedVars.Global.SavedOrderItemData == nil then tcc.SavedVars.Global.SavedOrderItemData = {} end
	tcc.SavedVars.Global.SavedOrderItemData[orderName] = tcc_BuildOrderListData(ZO_ScrollList_GetDataList(tccOrderList))
end

function tcc_DeleteSavedOrderItemData(orderName)
	if tcc.SavedVars.Global.SavedOrderItemData ~= nil then tcc.SavedVars.Global.SavedOrderItemData[orderName] = nil end
end

function tcc_LoadSavedOrderListData()
	ZO_ScrollList_Clear(tccSavedOrderList)
    local datalist = ZO_ScrollList_GetDataList(tccSavedOrderList)
	if tcc.SavedVars.Global.SavedOrderListData ~= nil then
		-- Syntax: tcc_Sort(tableOrArray, indexOrFieldName)
		tcc_Sort(tcc.SavedVars.Global.SavedOrderListData, "OrderName")
		for listIdx, listItem in ipairs(tcc.SavedVars.Global.SavedOrderListData) do
			datalist[listIdx] = ZO_ScrollList_CreateDataEntry(
				1, { 
					OrderName = listItem.OrderName,
					OrderSummary = listItem.OrderSummary,
				}, 1
			)
		end
	end
	ZO_ScrollList_Commit(tccSavedOrderList, datalist)
end


--[[ Master Merchant Integration Functions ]]--

function tcc_CalculateTotalCostOfMaterials(labelControl, itemListControl)
	if labelControl == nil or itemListControl == nil then return end
	local tooltip = ""
	local totalCost = 0
	if itemListControl:GetNumChildren() > 0 then
		for i = 1, itemListControl:GetNumChildren() do
			local matFrame = itemListControl:GetChild(i)
			if matFrame:GetNamedChild("Qty") ~= nil and matFrame:GetNamedChild("Icon") ~= nil and matFrame:GetNamedChild("Icon").ItemLink ~= nil and matFrame.Active then
				local matQty = tonumber(matFrame:GetNamedChild("Qty"):GetText())
				local matLink = matFrame:GetNamedChild("Icon").ItemLink
				local matCost = MasterMerchant:itemStats(matLink)["avgPrice"]
				local matName = matFrame:GetNamedChild("Icon").ItemName
				matCost = (matCost ~= nil and math.ceil(matCost) or 0)
				local matTotalCost = matCost * matQty
				local subMatQty, subMatLink, subMatName, subMatCost
				local subMatTotalCost = 0
				if matFrame:GetNamedChild("SubQty") ~= nil and matFrame:GetNamedChild("SubIcon") ~= nil and matFrame:GetNamedChild("SubIcon").ItemLink ~= nil and matFrame:GetNamedChild("SubIcon").Active then
					subMatQty = tonumber(matFrame:GetNamedChild("SubQty"):GetText())
					subMatLink = matFrame:GetNamedChild("SubIcon").ItemLink
					subMatCost = MasterMerchant:itemStats(subMatLink)["avgPrice"]
					subMatCost = (subMatCost ~= nil and math.ceil(subMatCost) or 0)
					subMatTotalCost = subMatCost * subMatQty
					subMatName = matFrame:GetNamedChild("SubIcon").ItemName
				end
				local cheaperPrice = ((subMatTotalCost > 0 and (subMatTotalCost < matTotalCost or matTotalCost <= 0)) and subMatTotalCost or matTotalCost)
				totalCost = totalCost + cheaperPrice
				if tooltip ~= "" then tooltip = tooltip .. "\n" end
				if cheaperPrice == matTotalCost then
					tooltip = tooltip .. "|c00FF00" .. matQty .. "|r " .. matName .. " * |cFFAA00" .. matCost .. "g|r each = |cFFFF00" .. cheaperPrice .. "g|r"
				else
					tooltip = tooltip .. "|c00FF00" .. subMatQty .. "|r " .. subMatName .. " * |cFFAA00" .. subMatCost .. "g|r each = |cFFFF00" .. cheaperPrice .. "g|r"
				end
			end
		end
	end
	labelControl:SetText((totalCost == 0) and "-" or tcc_CommaValue(totalCost))
	if totalCost > 0 then
		tcc_RegisterTextTooltip(labelControl, tooltip)
	else
		tcc_UnregisterTooltip(labelControl)
	end
	return totalCost
end


