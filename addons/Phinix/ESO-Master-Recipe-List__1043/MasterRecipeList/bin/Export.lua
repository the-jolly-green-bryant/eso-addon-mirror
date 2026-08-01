local L = ESOMRL.DB.Strings
local knownDB = {}
local unknownDB = {}
local datalist = {}
local currentPage = 1
local exportMode = 0
local exportCheck = 0

local qualityText = {
	[1]= {hex = "ffffff", color = "(White)"},
	[2]= {hex = "00ff00", color = "(Green)"},
	[3]= {hex = "3a92ff", color = "(Blue)"},
	[4]= {hex = "a02ef7", color = "(Purple)"},
	[5]= {hex = "eeca2a", color = "(Gold)"},
}

local foodCategory = {
	[SPECIALIZED_ITEMTYPE_FOOD_MEAT] = "Meat Dish",
    [SPECIALIZED_ITEMTYPE_FOOD_FRUIT] = "Fruit Dish",
    [SPECIALIZED_ITEMTYPE_FOOD_VEGETABLE] = "Vegetable Dish",
    [SPECIALIZED_ITEMTYPE_FOOD_SAVOURY] = "Savoury Dish",
    [SPECIALIZED_ITEMTYPE_FOOD_RAGOUT] = "Ragout Dish",
    [SPECIALIZED_ITEMTYPE_FOOD_ENTREMET] = "Entremet Dish",
    [SPECIALIZED_ITEMTYPE_FOOD_GOURMET] = "Gourmet Dish",
    [SPECIALIZED_ITEMTYPE_DRINK_ALCOHOLIC] = "Alcoholic Beverage",
    [SPECIALIZED_ITEMTYPE_DRINK_TEA] = "Tea Beverage",
    [SPECIALIZED_ITEMTYPE_DRINK_TONIC] = "Tonic Beverage",
    [SPECIALIZED_ITEMTYPE_DRINK_LIQUEUR] = "Liqueur Beverage",
    [SPECIALIZED_ITEMTYPE_DRINK_TINCTURE] = "Tincture Beverage",
    [SPECIALIZED_ITEMTYPE_DRINK_CORDIAL_TEA] = "Cordial Tea Beverage",
    [SPECIALIZED_ITEMTYPE_DRINK_DISTILLATE] = "Distillate Beverage",
}

local skillType = {
	[CRAFTING_TYPE_BLACKSMITHING] = "Blacksmithing",
	[CRAFTING_TYPE_CLOTHIER] = "Clothing",
	[CRAFTING_TYPE_ENCHANTING] = "Enchanting",
	[CRAFTING_TYPE_ALCHEMY] = "Alchemy",
	[CRAFTING_TYPE_PROVISIONING] = "Provisioning",
	[CRAFTING_TYPE_WOODWORKING] = "Woodworking",
	[CRAFTING_TYPE_JEWELRYCRAFTING] = "Jewelry Crafting",
}

local function PopulateExportList() -- Populates the selectable export data scroll list based on options.
	ESOMRL_ExportFrame_ListFrame_TextBox:SetText("")
	local isFurn
	local tData
	local newline = ""
	local tText = ""
	local tIndex = 1
	knownDB = {}
	unknownDB = {}
	datalist = {}

	if (exportMode == 0) then
		tData = ESOMRL.AT.ProvisioningTable
		isFurn = false
	else
		tData = ESOMRL.AT.FurnitureTable
		isFurn = true
	end

	local kIn = 0
	local uIn = 0

	for k, v in pairs(tData) do
		if (IsItemLinkRecipeKnown(v.link)) then
			kIn = kIn + 1
			knownDB[kIn] = {link = v.link, item = v.item}
		else
			uIn = uIn + 1
			unknownDB[uIn] = {link = v.link, item = v.item}
		end
	end

	local tList = (exportCheck == 0) and knownDB or unknownDB

	for i = 1, #tList do
		local item = tList[i].item
		local link = tList[i].link
		local qval = GetItemLinkQuality(link)
		local name = zo_strformat("<<t:1>>",GetItemLinkName(item))
		local cType = GetItemLinkRecipeCraftingSkillType(link)
		local station = (skillType[cType] ~= nil) and skillType[cType] or "Station Unknown"
		local quality1 = (qualityText[qval] ~= nil) and qualityText[qval].hex or "Unknown Quality"
		local quality2 = (qualityText[qval] ~= nil) and qualityText[qval].color or ""
		local category = ""
		local level1 = ""
		local level2 = ""

		if (isFurn) then
			local categoryId, subcategoryId = GetFurnitureDataCategoryInfo(GetItemLinkFurnitureDataId(item))
			category = GetFurnitureCategoryName(categoryId).." - "..GetFurnitureCategoryName(subcategoryId)..";"..station
		else
			local _, rType = GetItemLinkItemType(item)
			local sTypeText = ZO_GetSpecializedItemTypeText(GetItemLinkItemType(link))
			local _, _, _, _, hasScaling, minLevel, maxLevel, isChampionPoints, _ = GetItemLinkOnUseAbilityInfo(item)
			local rLow = (isChampionPoints) and "\(".."CP "..tostring(minLevel) or "\("..L.ESOMRL_LEVEL.." "..tostring(minLevel)
			local rHigh = "-"..tostring(maxLevel).."\)"
			level1 = (hasScaling) and rLow..rHigh..";" or "\("..L.ESOMRL_ANY.."\);"
			level2 = sTypeText:gsub(L.ESOMRL_Recipe,'')..";"

			if foodCategory[rType] ~= nil then
				category = foodCategory[rType]
			else
				category = "Special"
			end
		end

	-- game text box limited to ~29,000 characters so large exports must be stored in pages
		if datalist[tIndex] == nil then datalist[tIndex] = "" end
		if string.len(tText) > 28000 then
			tText = tText..name..";"..category..";"..level1..level2..quality1..";"..quality2
			datalist[tIndex] = tText
			tIndex = tIndex + 1
			tText = ""
		elseif i == #tList then
			tText = tText..name..";"..category..";"..level1..level2..quality1..";"..quality2
			datalist[tIndex] = tText
		else
			tText = tText..name..";"..category..";"..level1..level2..quality1..";"..quality2.."\r\n"
			datalist[tIndex] = tText
		end
	end

	currentPage = 1
	ESOMRL_ExportFrame_PageLabel:SetText("Page 1/"..tostring(#datalist))
	ESOMRL_ExportFrame_ListFrame_TextBox:SetText(datalist[currentPage])
end

local function PageResult(option, mode)
	if option == 1 then
		if mode == 1 then
			InitializeTooltip(InformationTooltip, ESOMRL_ExportFrame, TOPLEFT, 10, -8, TOPRIGHT)
			SetTooltipText(InformationTooltip, "Next Page")
		elseif mode == 2 then
			InitializeTooltip(InformationTooltip, ESOMRL_ExportFrame, TOPLEFT, 10, -8, TOPRIGHT)
			SetTooltipText(InformationTooltip, "Previous Page")
		end
	elseif option == 2 then
		ClearTooltip(InformationTooltip)
	elseif option == 3 then
		local pages = #datalist
		if mode == 1 then -- next page
			if currentPage < pages then
				currentPage = currentPage + 1
				ESOMRL_ExportFrame_PageLabel:SetText("Page "..tostring(currentPage).."/"..tostring(pages))
				ESOMRL_ExportFrame_ListFrame_TextBox:SetText(datalist[currentPage])
			end
		elseif mode == 2 then -- previous page
			if currentPage > 1 then
				currentPage = currentPage - 1
				ESOMRL_ExportFrame_PageLabel:SetText("Page "..tostring(currentPage).."/"..tostring(pages))
				ESOMRL_ExportFrame_ListFrame_TextBox:SetText(datalist[currentPage])
			end
		end
	end
end

local function ToggleMode(option, mode) -- Select the export mode, food or furniture.
	if option == 1 then
		if mode == 1 then
			InitializeTooltip(InformationTooltip, ESOMRL_ExportFrame, TOPLEFT, 10, -8, TOPRIGHT)
			SetTooltipText(InformationTooltip, "Food Export")
		elseif mode == 2 then
			InitializeTooltip(InformationTooltip, ESOMRL_ExportFrame, TOPLEFT, 10, -8, TOPRIGHT)
			SetTooltipText(InformationTooltip, "Furniture Export")
		end
	elseif option == 2 then
		if exportMode == 0 then
			ESOMRL_ExportFrameFoodButton:SetNormalTexture("/esoui/art/treeicons/provisioner_indexicon_stew_down.dds")
			ESOMRL_ExportFrameFurnitureButton:SetNormalTexture("/esoui/art/treeicons/collection_indexicon_furnishings_up.dds")
		else
			ESOMRL_ExportFrameFoodButton:SetNormalTexture("/esoui/art/treeicons/provisioner_indexicon_stew_up.dds")
			ESOMRL_ExportFrameFurnitureButton:SetNormalTexture("/esoui/art/treeicons/collection_indexicon_furnishings_down.dds")
		end
		ClearTooltip(InformationTooltip)
	elseif option == 3 then
		if exportMode == 0 and mode == 2 then
			exportMode = 1
		elseif exportMode == 1 and mode == 1 then
			exportMode = 0
		end
		PopulateExportList()
	end
end

local function ToggleCheck(option, mode) -- Select the export mode, known or unknown.
	if option == 1 then
		if mode == 1 then
			InitializeTooltip(InformationTooltip, ESOMRL_ExportFrame, TOPLEFT, 10, -8, TOPRIGHT)
			SetTooltipText(InformationTooltip, "Export Known")
		elseif mode == 2 then
			InitializeTooltip(InformationTooltip, ESOMRL_ExportFrame, TOPLEFT, 10, -8, TOPRIGHT)
			SetTooltipText(InformationTooltip, "Export Unknown")
		end
	elseif option == 2 then
		ClearTooltip(InformationTooltip)
	elseif option == 3 then
		if exportCheck == 0 and mode == 2 then
			ZO_CheckButton_SetCheckState(ESOMRL_ExportFrameKnownBox, false)
			ZO_CheckButton_SetCheckState(ESOMRL_ExportFrameUnknownBox, true)
			exportCheck = 1
		elseif exportCheck == 1 and mode == 1 then
			ZO_CheckButton_SetCheckState(ESOMRL_ExportFrameKnownBox, true)
			ZO_CheckButton_SetCheckState(ESOMRL_ExportFrameUnknownBox, false)
			exportCheck = 0
		end
		PopulateExportList()
	end
end

local function RestorePosition() -- Restores export window position when opened.
	local left = ESOMRL.ASV.export_xpos
	local top = ESOMRL.ASV.export_ypos
	ESOMRL_ExportFrame:ClearAnchors()
	ESOMRL_ExportFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

local function OnMoveStop() -- Saves export window position when moved.
	ESOMRL.ASV.export_xpos = ESOMRL_ExportFrame:GetLeft()
	ESOMRL.ASV.export_ypos = ESOMRL_ExportFrame:GetTop()
end

local function CloseExport(option) -- Closes the export window and returns cursor control.
	if option == 1 then
		InitializeTooltip(InformationTooltip, ESOMRL_ExportFrame, TOPLEFT, 10, -8, TOPRIGHT)
		SetTooltipText(InformationTooltip, "Close")
	elseif option == 2 then
		ClearTooltip(InformationTooltip)
	elseif option == 3 then
		SCENE_MANAGER:HideTopLevel(ESOMRL_ExportFrame)
	end
end

local function ShowExport() -- Show the data export GUI.
	local control = GetControl('ESOMRL_ExportFrame')
	if ( control:IsHidden() ) then
		SCENE_MANAGER:ShowTopLevel(ESOMRL_ExportFrame)
		if exportMode == 0 then
			ESOMRL_ExportFrameFoodButton:SetNormalTexture("/esoui/art/treeicons/provisioner_indexicon_stew_down.dds")
			ESOMRL_ExportFrameFurnitureButton:SetNormalTexture("/esoui/art/treeicons/collection_indexicon_furnishings_up.dds")
		else
			ESOMRL_ExportFrameFoodButton:SetNormalTexture("/esoui/art/treeicons/provisioner_indexicon_stew_up.dds")
			ESOMRL_ExportFrameFurnitureButton:SetNormalTexture("/esoui/art/treeicons/collection_indexicon_furnishings_down.dds")
		end
		if exportCheck == 0 then
			ZO_CheckButton_SetCheckState(ESOMRL_ExportFrameKnownBox, true)
			ZO_CheckButton_SetCheckState(ESOMRL_ExportFrameUnknownBox, false)
		elseif exportCheck == 1 then
			ZO_CheckButton_SetCheckState(ESOMRL_ExportFrameKnownBox, false)
			ZO_CheckButton_SetCheckState(ESOMRL_ExportFrameUnknownBox, true)
		end
		PopulateExportList()
		RestorePosition()
	else
		SCENE_MANAGER:HideTopLevel(ESOMRL_ExportFrame)
	end
end

------------------------------------------------------------------------------------------------------------------------------------
-- Handle function calls from XML.
------------------------------------------------------------------------------------------------------------------------------------
function ESOMRL.XMLExport(option, n1, n2)
	if option == 101 then
		OnMoveStop()
	elseif option == 102 then
		CloseExport(n1)
	elseif option == 103 then
		PageResult(n1, n2)
	elseif option == 104 then
		ToggleMode(n1, n2)
	elseif option == 105 then
		ToggleCheck(n1, n2)
	end
end

SCENE_MANAGER:RegisterTopLevel(ESOMRL_ExportFrame, false)
SLASH_COMMANDS['/mrlexport'] = function() ShowExport() end
