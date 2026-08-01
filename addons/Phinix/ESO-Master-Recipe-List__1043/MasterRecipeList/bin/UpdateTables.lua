local ESOMRL = _G['ESOMRL']
local L = ESOMRL.DB.Strings
local rND = ESOMRL.Round
local pGK = ESOMRL.GetKey

ESOMRL.AT.ProvisioningTable = {} -- initialize the dynamically generated active tables (AT)
ESOMRL.AT.ProvisioningKeys = {}
ESOMRL.AT.FurnitureTable = {}
ESOMRL.AT.FurnitureKeys = {}
ESOMRL.AT.IngredientTable = {}
ESOMRL.AT.ProvisioningTableFood1 = {}
ESOMRL.AT.ProvisioningTableFood2 = {}
ESOMRL.AT.ProvisioningTableFood3 = {}
ESOMRL.AT.ProvisioningTableFood4 = {}
ESOMRL.AT.ProvisioningTableFood5 = {}
ESOMRL.AT.ProvisioningTableFood6 = {}
ESOMRL.AT.ProvisioningTableFood7 = {}
ESOMRL.AT.ProvisioningTableDrinks1 = {}
ESOMRL.AT.ProvisioningTableDrinks2 = {}
ESOMRL.AT.ProvisioningTableDrinks3 = {}
ESOMRL.AT.ProvisioningTableDrinks4 = {}
ESOMRL.AT.ProvisioningTableDrinks5 = {}
ESOMRL.AT.ProvisioningTableDrinks6 = {}
ESOMRL.AT.ProvisioningTableDrinks7 = {}
ESOMRL.AT.ProvisioningTablePsijic = {}
ESOMRL.AT.ProvisioningTableOrsinium = {}
ESOMRL.AT.ProvisioningTableWitchesFestival = {}
ESOMRL.AT.ProvisioningTableNewLifeFestival = {}
ESOMRL.AT.ProvisioningTableJesterFestival = {}
ESOMRL.AT.ProvisioningTableClockworkCity = {}
ESOMRL.AT.ProvisioningDelicaciesDrinks = {}
ESOMRL.AT.ProvisioningDelicaciesFood = {}
ESOMRL.AT.FurnitureTableBlacksmithing1 = {}
ESOMRL.AT.FurnitureTableBlacksmithing2 = {}
ESOMRL.AT.FurnitureTableBlacksmithing3 = {}
ESOMRL.AT.FurnitureTableBlacksmithing4 = {}
ESOMRL.AT.FurnitureTableBlacksmithing5 = {}
ESOMRL.AT.FurnitureTableClothing1 = {}
ESOMRL.AT.FurnitureTableClothing2 = {}
ESOMRL.AT.FurnitureTableClothing3 = {}
ESOMRL.AT.FurnitureTableClothing4 = {}
ESOMRL.AT.FurnitureTableClothing5 = {}
ESOMRL.AT.FurnitureTableEnchanting1 = {}
ESOMRL.AT.FurnitureTableEnchanting2 = {}
ESOMRL.AT.FurnitureTableEnchanting3 = {}
ESOMRL.AT.FurnitureTableEnchanting4 = {}
ESOMRL.AT.FurnitureTableEnchanting5 = {}
ESOMRL.AT.FurnitureTableAlchemy1 = {}
ESOMRL.AT.FurnitureTableAlchemy2 = {}
ESOMRL.AT.FurnitureTableAlchemy3 = {}
ESOMRL.AT.FurnitureTableAlchemy4 = {}
ESOMRL.AT.FurnitureTableAlchemy5 = {}
ESOMRL.AT.FurnitureTableProvisioning1 = {}
ESOMRL.AT.FurnitureTableProvisioning2 = {}
ESOMRL.AT.FurnitureTableProvisioning3 = {}
ESOMRL.AT.FurnitureTableProvisioning4 = {}
ESOMRL.AT.FurnitureTableProvisioning5 = {}
ESOMRL.AT.FurnitureTableWoodworking1 = {}
ESOMRL.AT.FurnitureTableWoodworking2 = {}
ESOMRL.AT.FurnitureTableWoodworking3 = {}
ESOMRL.AT.FurnitureTableWoodworking4 = {}
ESOMRL.AT.FurnitureTableWoodworking5 = {}
ESOMRL.AT.FurnitureTableJewelry1 = {}
ESOMRL.AT.FurnitureTableJewelry2 = {}
ESOMRL.AT.FurnitureTableJewelry3 = {}
ESOMRL.AT.FurnitureTableJewelry4 = {}
ESOMRL.AT.FurnitureTableJewelry5 = {}

local tempFilter = {}
local updateRunning = false


local function ResetTables()
	for k, v in pairs(ESOMRL.AT) do
		ESOMRL.AT[k] = {}
	end
	for k, v in pairs(ESOMRL.ASV.mRecipeList) do
		ESOMRL.ASV.mRecipeList[k] = {}
	end
	ESOMRL.ASV.mRecipeList.Ingredients = ESOMRL.DB.DefaultVars(1)
	return
end

local function SortSubTables(sTable, sCats)
	local iTable = {}
	local oTable = {}
	local NameKeys = {}
	local LS = {}
	local LSnames = {}
	local CP = {}
	local CPnames = {}
	local AL = {}
	local ALnames = {}

	if sCats then
		for k, v in pairs(sTable) do
			local _, _, _, _, hasScaling, minLevel, maxLevel, isChampionPoints, _ = GetItemLinkOnUseAbilityInfo(v.item)
			local iName = zo_strformat("<<t:1>>",GetItemLinkName(v.item))
			local fMin = string.format("%02.0f", tostring(minLevel)) -- concatenation to sort by level range

			if not hasScaling then
				AL[#AL + 1] = iName
				ALnames[iName] = v
			else
				if not isChampionPoints then
					LS[#LS + 1] = fMin..iName
					LSnames[fMin..iName] = v
				else
					CP[#CP + 1] = fMin..iName
					CPnames[fMin..iName] = v
				end
			end
		end
		table.sort(LS)
		table.sort(CP)
		table.sort(AL)

		for i = 1, #LS do
			oTable[#oTable + 1] = LSnames[LS[i]]
		end
		for i = 1, #CP do
			oTable[#oTable + 1] = CPnames[CP[i]]
		end
		for i = 1, #AL do
			oTable[#oTable + 1] = ALnames[AL[i]]
		end
		return oTable
	else
		for k, v in pairs(sTable) do
			local iName = zo_strformat("<<t:1>>",GetItemLinkName(v.item))
			iTable[#iTable + 1] = iName
			NameKeys[iName] = v
		end
		table.sort(iTable)
	
		for i = 1, #iTable do
			oTable[i] = NameKeys[iTable[i]]
		end
		return oTable
	end
end

local function UpdateSavedVariables(rebuild)
	for k, v in pairs(ESOMRL.AT.ProvisioningKeys) do
		if ESOMRL.ASV.mRecipeList.Provisioning[v.ID] == nil then
			ESOMRL.ASV.mRecipeList.Provisioning[v.ID] = v.rInd
		end
	end
	for k, v in pairs(ESOMRL.AT.FurnitureKeys) do
		if ESOMRL.ASV.mRecipeList.Furniture[v.ID] == nil then
			ESOMRL.ASV.mRecipeList.Furniture[v.ID] = v.rInd
		end
	end
	for k, v in pairs(ESOMRL.AT.IngredientTable) do
		if ESOMRL.ASV.mRecipeList.Ingredients[k] == nil then
			ESOMRL.ASV.mRecipeList.Ingredients[k] = v.icon
		end
	end

	ESOMRL.ASV.aOpts.APIversion = GetAPIVersion()
	ESOMRL.InitCheck = 2
	updateRunning = false

	if rebuild then
		ESOMRL.ResetPending = true

		zo_callLater(function()
			d(L.ESOMRL_UPDATE1)
			d(L.ESOMRL_UPDATE2)
		--	ReloadUI() 
		end, 5000)
	end
end

local function FinalizeMainTables(rebuild)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Sort tables based on contents.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- send each generated sub-table to the sorting function for processing if it contains data
	if #ESOMRL.AT.ProvisioningTableFood1 > 0 then ESOMRL.AT.ProvisioningTableFood1 = SortSubTables(ESOMRL.AT.ProvisioningTableFood1, true) end
	if #ESOMRL.AT.ProvisioningTableFood2 > 0 then ESOMRL.AT.ProvisioningTableFood2 = SortSubTables(ESOMRL.AT.ProvisioningTableFood2, true) end
	if #ESOMRL.AT.ProvisioningTableFood3 > 0 then ESOMRL.AT.ProvisioningTableFood3 = SortSubTables(ESOMRL.AT.ProvisioningTableFood3, true) end
	if #ESOMRL.AT.ProvisioningTableFood4 > 0 then ESOMRL.AT.ProvisioningTableFood4 = SortSubTables(ESOMRL.AT.ProvisioningTableFood4, true) end
	if #ESOMRL.AT.ProvisioningTableFood5 > 0 then ESOMRL.AT.ProvisioningTableFood5 = SortSubTables(ESOMRL.AT.ProvisioningTableFood5, true) end
	if #ESOMRL.AT.ProvisioningTableFood6 > 0 then ESOMRL.AT.ProvisioningTableFood6 = SortSubTables(ESOMRL.AT.ProvisioningTableFood6, true) end
	if #ESOMRL.AT.ProvisioningTableFood7 > 0 then ESOMRL.AT.ProvisioningTableFood7 = SortSubTables(ESOMRL.AT.ProvisioningTableFood7, true) end
	if #ESOMRL.AT.ProvisioningTableDrinks1 > 0 then ESOMRL.AT.ProvisioningTableDrinks1 = SortSubTables(ESOMRL.AT.ProvisioningTableDrinks1, true) end
	if #ESOMRL.AT.ProvisioningTableDrinks2 > 0 then ESOMRL.AT.ProvisioningTableDrinks2 = SortSubTables(ESOMRL.AT.ProvisioningTableDrinks2, true) end
	if #ESOMRL.AT.ProvisioningTableDrinks3 > 0 then ESOMRL.AT.ProvisioningTableDrinks3 = SortSubTables(ESOMRL.AT.ProvisioningTableDrinks3, true) end
	if #ESOMRL.AT.ProvisioningTableDrinks4 > 0 then ESOMRL.AT.ProvisioningTableDrinks4 = SortSubTables(ESOMRL.AT.ProvisioningTableDrinks4, true) end
	if #ESOMRL.AT.ProvisioningTableDrinks5 > 0 then ESOMRL.AT.ProvisioningTableDrinks5 = SortSubTables(ESOMRL.AT.ProvisioningTableDrinks5, true) end
	if #ESOMRL.AT.ProvisioningTableDrinks6 > 0 then ESOMRL.AT.ProvisioningTableDrinks6 = SortSubTables(ESOMRL.AT.ProvisioningTableDrinks6, true) end
	if #ESOMRL.AT.ProvisioningTableDrinks7 > 0 then ESOMRL.AT.ProvisioningTableDrinks7 = SortSubTables(ESOMRL.AT.ProvisioningTableDrinks7, true) end
	if #ESOMRL.AT.ProvisioningTablePsijic > 0 then ESOMRL.AT.ProvisioningTablePsijic = SortSubTables(ESOMRL.AT.ProvisioningTablePsijic) end
	if #ESOMRL.AT.ProvisioningTableOrsinium > 0 then ESOMRL.AT.ProvisioningTableOrsinium = SortSubTables(ESOMRL.AT.ProvisioningTableOrsinium) end
	if #ESOMRL.AT.ProvisioningTableWitchesFestival > 0 then ESOMRL.AT.ProvisioningTableWitchesFestival = SortSubTables(ESOMRL.AT.ProvisioningTableWitchesFestival) end
	if #ESOMRL.AT.ProvisioningTableNewLifeFestival > 0 then ESOMRL.AT.ProvisioningTableNewLifeFestival = SortSubTables(ESOMRL.AT.ProvisioningTableNewLifeFestival) end
	if #ESOMRL.AT.ProvisioningTableJesterFestival > 0 then ESOMRL.AT.ProvisioningTableJesterFestival = SortSubTables(ESOMRL.AT.ProvisioningTableJesterFestival) end
	if #ESOMRL.AT.ProvisioningTableClockworkCity > 0 then ESOMRL.AT.ProvisioningTableClockworkCity = SortSubTables(ESOMRL.AT.ProvisioningTableClockworkCity) end
	if #ESOMRL.AT.ProvisioningDelicaciesDrinks > 0 then ESOMRL.AT.ProvisioningDelicaciesDrinks = SortSubTables(ESOMRL.AT.ProvisioningDelicaciesDrinks) end
	if #ESOMRL.AT.ProvisioningDelicaciesFood > 0 then ESOMRL.AT.ProvisioningDelicaciesFood = SortSubTables(ESOMRL.AT.ProvisioningDelicaciesFood) end
	if #ESOMRL.AT.FurnitureTableBlacksmithing1 > 0 then ESOMRL.AT.FurnitureTableBlacksmithing1 = SortSubTables(ESOMRL.AT.FurnitureTableBlacksmithing1) end
	if #ESOMRL.AT.FurnitureTableBlacksmithing2 > 0 then ESOMRL.AT.FurnitureTableBlacksmithing2 = SortSubTables(ESOMRL.AT.FurnitureTableBlacksmithing2) end
	if #ESOMRL.AT.FurnitureTableBlacksmithing3 > 0 then ESOMRL.AT.FurnitureTableBlacksmithing3 = SortSubTables(ESOMRL.AT.FurnitureTableBlacksmithing3) end
	if #ESOMRL.AT.FurnitureTableBlacksmithing4 > 0 then ESOMRL.AT.FurnitureTableBlacksmithing4 = SortSubTables(ESOMRL.AT.FurnitureTableBlacksmithing4) end
	if #ESOMRL.AT.FurnitureTableBlacksmithing5 > 0 then ESOMRL.AT.FurnitureTableBlacksmithing5 = SortSubTables(ESOMRL.AT.FurnitureTableBlacksmithing5) end
	if #ESOMRL.AT.FurnitureTableClothing1 > 0 then ESOMRL.AT.FurnitureTableClothing1 = SortSubTables(ESOMRL.AT.FurnitureTableClothing1) end
	if #ESOMRL.AT.FurnitureTableClothing2 > 0 then ESOMRL.AT.FurnitureTableClothing2 = SortSubTables(ESOMRL.AT.FurnitureTableClothing2) end
	if #ESOMRL.AT.FurnitureTableClothing3 > 0 then ESOMRL.AT.FurnitureTableClothing3 = SortSubTables(ESOMRL.AT.FurnitureTableClothing3) end
	if #ESOMRL.AT.FurnitureTableClothing4 > 0 then ESOMRL.AT.FurnitureTableClothing4 = SortSubTables(ESOMRL.AT.FurnitureTableClothing4) end
	if #ESOMRL.AT.FurnitureTableClothing5 > 0 then ESOMRL.AT.FurnitureTableClothing5 = SortSubTables(ESOMRL.AT.FurnitureTableClothing5) end
	if #ESOMRL.AT.FurnitureTableEnchanting1 > 0 then ESOMRL.AT.FurnitureTableEnchanting1 = SortSubTables(ESOMRL.AT.FurnitureTableEnchanting1) end
	if #ESOMRL.AT.FurnitureTableEnchanting2 > 0 then ESOMRL.AT.FurnitureTableEnchanting2 = SortSubTables(ESOMRL.AT.FurnitureTableEnchanting2) end
	if #ESOMRL.AT.FurnitureTableEnchanting3 > 0 then ESOMRL.AT.FurnitureTableEnchanting3 = SortSubTables(ESOMRL.AT.FurnitureTableEnchanting3) end
	if #ESOMRL.AT.FurnitureTableEnchanting4 > 0 then ESOMRL.AT.FurnitureTableEnchanting4 = SortSubTables(ESOMRL.AT.FurnitureTableEnchanting4) end
	if #ESOMRL.AT.FurnitureTableEnchanting5 > 0 then ESOMRL.AT.FurnitureTableEnchanting5 = SortSubTables(ESOMRL.AT.FurnitureTableEnchanting5) end
	if #ESOMRL.AT.FurnitureTableAlchemy1 > 0 then ESOMRL.AT.FurnitureTableAlchemy1 = SortSubTables(ESOMRL.AT.FurnitureTableAlchemy1) end
	if #ESOMRL.AT.FurnitureTableAlchemy2 > 0 then ESOMRL.AT.FurnitureTableAlchemy2 = SortSubTables(ESOMRL.AT.FurnitureTableAlchemy2) end
	if #ESOMRL.AT.FurnitureTableAlchemy3 > 0 then ESOMRL.AT.FurnitureTableAlchemy3 = SortSubTables(ESOMRL.AT.FurnitureTableAlchemy3) end
	if #ESOMRL.AT.FurnitureTableAlchemy4 > 0 then ESOMRL.AT.FurnitureTableAlchemy4 = SortSubTables(ESOMRL.AT.FurnitureTableAlchemy4) end
	if #ESOMRL.AT.FurnitureTableAlchemy5 > 0 then ESOMRL.AT.FurnitureTableAlchemy5 = SortSubTables(ESOMRL.AT.FurnitureTableAlchemy5) end
	if #ESOMRL.AT.FurnitureTableProvisioning1 > 0 then ESOMRL.AT.FurnitureTableProvisioning1 = SortSubTables(ESOMRL.AT.FurnitureTableProvisioning1) end
	if #ESOMRL.AT.FurnitureTableProvisioning2 > 0 then ESOMRL.AT.FurnitureTableProvisioning2 = SortSubTables(ESOMRL.AT.FurnitureTableProvisioning2) end
	if #ESOMRL.AT.FurnitureTableProvisioning3 > 0 then ESOMRL.AT.FurnitureTableProvisioning3 = SortSubTables(ESOMRL.AT.FurnitureTableProvisioning3) end
	if #ESOMRL.AT.FurnitureTableProvisioning4 > 0 then ESOMRL.AT.FurnitureTableProvisioning4 = SortSubTables(ESOMRL.AT.FurnitureTableProvisioning4) end
	if #ESOMRL.AT.FurnitureTableProvisioning5 > 0 then ESOMRL.AT.FurnitureTableProvisioning5 = SortSubTables(ESOMRL.AT.FurnitureTableProvisioning5) end
	if #ESOMRL.AT.FurnitureTableWoodworking1 > 0 then ESOMRL.AT.FurnitureTableWoodworking1 = SortSubTables(ESOMRL.AT.FurnitureTableWoodworking1) end
	if #ESOMRL.AT.FurnitureTableWoodworking2 > 0 then ESOMRL.AT.FurnitureTableWoodworking2 = SortSubTables(ESOMRL.AT.FurnitureTableWoodworking2) end
	if #ESOMRL.AT.FurnitureTableWoodworking3 > 0 then ESOMRL.AT.FurnitureTableWoodworking3 = SortSubTables(ESOMRL.AT.FurnitureTableWoodworking3) end
	if #ESOMRL.AT.FurnitureTableWoodworking4 > 0 then ESOMRL.AT.FurnitureTableWoodworking4 = SortSubTables(ESOMRL.AT.FurnitureTableWoodworking4) end
	if #ESOMRL.AT.FurnitureTableWoodworking5 > 0 then ESOMRL.AT.FurnitureTableWoodworking5 = SortSubTables(ESOMRL.AT.FurnitureTableWoodworking5) end
	if #ESOMRL.AT.FurnitureTableJewelry1 > 0 then ESOMRL.AT.FurnitureTableJewelry1 = SortSubTables(ESOMRL.AT.FurnitureTableJewelry1) end
	if #ESOMRL.AT.FurnitureTableJewelry2 > 0 then ESOMRL.AT.FurnitureTableJewelry2 = SortSubTables(ESOMRL.AT.FurnitureTableJewelry2) end
	if #ESOMRL.AT.FurnitureTableJewelry3 > 0 then ESOMRL.AT.FurnitureTableJewelry3 = SortSubTables(ESOMRL.AT.FurnitureTableJewelry3) end
	if #ESOMRL.AT.FurnitureTableJewelry4 > 0 then ESOMRL.AT.FurnitureTableJewelry4 = SortSubTables(ESOMRL.AT.FurnitureTableJewelry4) end
	if #ESOMRL.AT.FurnitureTableJewelry5 > 0 then ESOMRL.AT.FurnitureTableJewelry5 = SortSubTables(ESOMRL.AT.FurnitureTableJewelry5) end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Build ingredient panel grid
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Build ingredient panel grid from current (or updated) database

	local hOffset = 6
	local vOffset = 10
	local ingRows = 10
	local cWidth = 42	-- width of a single ingredient grid column
	local tColumns		-- total number of columns
	local tWidth		-- total width of the ingredient grid
	local wDiff			-- horizontal offset to center grid
	local tIcons		-- total number of ingredients
	local tOld = {}
	local tNew = {}
	local cTable = {}
	local cCounter

	local function SortIngTable(sTable)
		local NameKeys = {}
		local iTable = {}
		local oTable = {}

		for k, v in pairs(sTable) do
			local iName = zo_strformat("<<t:1>>",GetItemLinkName(v.link))
			iTable[#iTable + 1] = iName
			NameKeys[iName] = v
		end
		table.sort(iTable)

		for i = 1, #iTable do
			oTable[i] = NameKeys[iTable[i]]
		end
		return oTable
	end

	for k, v in pairs(ESOMRL.AT.IngredientTable) do
		if v.itier == 0 then
			tOld[#tOld + 1] = v
		else 
			tNew[#tNew + 1] = v
		end
	end
	tOld = SortIngTable(tOld)
	tNew = SortIngTable(tNew)
	for k, v in ipairs(tOld) do cTable[#cTable + 1] = v end
	for k, v in ipairs(tNew) do cTable[#cTable + 1] = v end

-- calculate offset needed to center ingredient grid in available space of the app
	tIcons = #cTable
	cWidth = 42
	tColumns = rND(tIcons / ingRows, 0)
	tColumns = (tIcons / ingRows <= tColumns) and tColumns or tColumns + 1
	tWidth = cWidth * tColumns + (tColumns - 1) * hOffset
	tWidth = (ESOMRL_MainFrameIngredientsFrame:GetWidth() - tWidth) / 2
	wDiff = (tWidth >= 0) and tWidth or 0

	for k, v in ipairs(cTable) do
		local nrId = GetItemLinkItemId(v.link)
		local testLoad = ESOMRL_MainFrameIngredientsFrame:GetNamedChild('IBoverlay'..tostring(nrId))
		local oControl
		local iControl
		local bControl
		if testLoad == nil then
			oControl = WINDOW_MANAGER:CreateControl('ESOMRL_MainFrameIngredientsFrameIBoverlay'..tostring(nrId), ESOMRL_MainFrameIngredientsFrame, CT_TEXTURE)
			iControl = WINDOW_MANAGER:CreateControl('ESOMRL_MainFrameIngredientsFrameIBicon'..tostring(nrId), ESOMRL_MainFrameIngredientsFrame, CT_TEXTURE)
			bControl = WINDOW_MANAGER:CreateControl('ESOMRL_MainFrameIngredientsFrameIBbutton'..tostring(nrId), ESOMRL_MainFrameIngredientsFrame, CT_BUTTON)
			oControl:SetTexture('/MasterRecipeList/bin/textures/tracking_igv.dds')
			oControl:SetHidden(true)
			oControl:SetWidth(16)
			oControl:SetHeight(16)
			oControl:SetParent(iControl)
			iControl:SetWidth(34)
			iControl:SetHeight(34)
			iControl:SetTexture(v.icon)
			iControl:SetParent(bControl)
			bControl:SetWidth(42)
			bControl:SetHeight(42)
			bControl:SetParent(ESOMRL_MainFrameIngredientsFrame)
		else
			oControl = ESOMRL_MainFrameIngredientsFrame:GetNamedChild('IBoverlay'..tostring(nrId))
			iControl = ESOMRL_MainFrameIngredientsFrame:GetNamedChild('IBicon'..tostring(nrId))
			bControl = ESOMRL_MainFrameIngredientsFrame:GetNamedChild('IBbutton'..tostring(nrId))
		end

		if k == 1 then
			bControl:SetAnchor(TOPLEFT, ESOMRL_MainFrameIngredientsFrame, TOPLEFT, wDiff, 0)
			cCounter = 1
		elseif k == cCounter + ingRows then
			bControl:SetAnchor(TOPLEFT, GetControl('ESOMRL_MainFrameIngredientsFrameIBbutton'..tostring(GetItemLinkItemId(cTable[k-ingRows].link))), TOPRIGHT, hOffset, 0)
			cCounter = cCounter + ingRows
		else
			bControl:SetAnchor(TOPLEFT, GetControl('ESOMRL_MainFrameIngredientsFrameIBbutton'..tostring(GetItemLinkItemId(cTable[k-1].link))), BOTTOMLEFT, 0, vOffset)
		end
		iControl:SetAnchor(CENTER, bControl, CENTER, 0, 0)
		oControl:SetAnchor(BOTTOMLEFT, iControl, BOTTOMLEFT, 0, 0)	
		iControl:SetDrawLayer(DL_CONTROLS)
		oControl:SetDrawLayer(DL_OVERLAY)
		bControl:SetHandler("OnMouseEnter", function() ESOMRL.XMLNavigation(201, oControl, iControl, 1, nrId) end)
		bControl:SetHandler("OnMouseExit", function() ESOMRL.XMLNavigation(201, oControl, iControl, 2, nrId) end)
		bControl:SetHandler("OnMouseDown", function() ESOMRL.XMLNavigation(201, oControl, iControl, 3, nrId) end)
		bControl:SetHandler("OnMouseUp", function(self, button, upInside) if (upInside) then ESOMRL.XMLNavigation(201, oControl, iControl, 4, nrId) end end)
	end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Finalize various settings
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate the crafting station tooltip position default values
	for k, v in pairs(ESOMRL.DB.SkillTypes) do
		if ESOMRL.ASV.aOpts.sttx[k] == nil then ESOMRL.ASV.aOpts.sttx[k] = 0 end
		if ESOMRL.ASV.aOpts.stty[k] == nil then ESOMRL.ASV.aOpts.stty[k] = 0 end
	end

-- Initialize additional saved-variable-based lookup tables after database is built
	ESOMRL.DB.StationChecking = {
		[1] = {tr = ESOMRL.AT.ProvisioningTableFood1, cv = 1},
		[2] = {tr = ESOMRL.AT.ProvisioningTableFood2, cv = 1},
		[3] = {tr = ESOMRL.AT.ProvisioningTableFood3, cv = 1},
		[4] = {tr = ESOMRL.AT.ProvisioningTableFood4, cv = 2},
		[5] = {tr = ESOMRL.AT.ProvisioningTableFood5, cv = 2},
		[6] = {tr = ESOMRL.AT.ProvisioningTableFood6, cv = 2},
		[7] = {tr = ESOMRL.AT.ProvisioningTableFood7, cv = 3},
		[8] = {tr = ESOMRL.AT.ProvisioningTableDrinks1, cv = 1},
		[9] = {tr = ESOMRL.AT.ProvisioningTableDrinks2, cv = 1},
		[10] = {tr = ESOMRL.AT.ProvisioningTableDrinks3, cv = 1},
		[11] = {tr = ESOMRL.AT.ProvisioningTableDrinks4, cv = 2},
		[12] = {tr = ESOMRL.AT.ProvisioningTableDrinks5, cv = 2},
		[13] = {tr = ESOMRL.AT.ProvisioningTableDrinks6, cv = 2},
		[14] = {tr = ESOMRL.AT.ProvisioningTableDrinks7, cv = 3},
		[15] = {tr = ESOMRL.AT.ProvisioningDelicaciesDrinks, cv = 4},
		[16] = {tr = ESOMRL.AT.ProvisioningDelicaciesFood, cv = 4},
	}
	ESOMRL.DB.ProvisioningSubLists = {
		[1] =	{sDB = ESOMRL.AT.ProvisioningTableFood1},
		[2] =	{sDB = ESOMRL.AT.ProvisioningTableFood2},
		[3] =	{sDB = ESOMRL.AT.ProvisioningTableFood3},
		[4] =	{sDB = ESOMRL.AT.ProvisioningTableFood4},
		[5] =	{sDB = ESOMRL.AT.ProvisioningTableFood5},
		[6] =	{sDB = ESOMRL.AT.ProvisioningTableFood6},
		[7] =	{sDB = ESOMRL.AT.ProvisioningTableFood7},
		[8] =	{sDB = ESOMRL.AT.ProvisioningTableDrinks1},
		[9] =	{sDB = ESOMRL.AT.ProvisioningTableDrinks2},
		[10] =	{sDB = ESOMRL.AT.ProvisioningTableDrinks3},
		[11] =	{sDB = ESOMRL.AT.ProvisioningTableDrinks4},
		[12] =	{sDB = ESOMRL.AT.ProvisioningTableDrinks5},
		[13] =	{sDB = ESOMRL.AT.ProvisioningTableDrinks6},
		[14] =	{sDB = ESOMRL.AT.ProvisioningTableDrinks7},
		[15] =	{sDB = ESOMRL.AT.ProvisioningDelicaciesDrinks},
		[16] =	{sDB = ESOMRL.AT.ProvisioningDelicaciesFood},
		[17] =	{sDB = ESOMRL.AT.ProvisioningTablePsijic},
		[18] =	{sDB = ESOMRL.AT.ProvisioningTableOrsinium},
		[19] =	{sDB = ESOMRL.AT.ProvisioningTableWitchesFestival},
		[20] =	{sDB = ESOMRL.AT.ProvisioningTableNewLifeFestival},
		[21] =	{sDB = ESOMRL.AT.ProvisioningTableJesterFestival},
		[22] =	{sDB = ESOMRL.AT.ProvisioningTableClockworkCity},
	}
	ESOMRL.DB.FurnitureSubLists = {
		[101] = {sDB = ESOMRL.AT.FurnitureTableAlchemy1, pos = 1},
		[102] = {sDB = ESOMRL.AT.FurnitureTableAlchemy2, pos = 2},
		[103] = {sDB = ESOMRL.AT.FurnitureTableAlchemy3, pos = 3},
		[104] = {sDB = ESOMRL.AT.FurnitureTableAlchemy4, pos = 4},
		[105] = {sDB = ESOMRL.AT.FurnitureTableAlchemy5, pos = 5},
		[106] = {sDB = ESOMRL.AT.FurnitureTableBlacksmithing1, pos = 6},
		[107] = {sDB = ESOMRL.AT.FurnitureTableBlacksmithing2, pos = 7},
		[108] = {sDB = ESOMRL.AT.FurnitureTableBlacksmithing3, pos = 8},
		[109] = {sDB = ESOMRL.AT.FurnitureTableBlacksmithing4, pos = 9},
		[110] = {sDB = ESOMRL.AT.FurnitureTableBlacksmithing5, pos = 10},
		[111] = {sDB = ESOMRL.AT.FurnitureTableClothing1, pos = 11},
		[112] = {sDB = ESOMRL.AT.FurnitureTableClothing2, pos = 12},
		[113] = {sDB = ESOMRL.AT.FurnitureTableClothing3, pos = 13},
		[114] = {sDB = ESOMRL.AT.FurnitureTableClothing4, pos = 14},
		[115] = {sDB = ESOMRL.AT.FurnitureTableClothing5, pos = 15},
		[116] = {sDB = ESOMRL.AT.FurnitureTableEnchanting1, pos = 16},
		[117] = {sDB = ESOMRL.AT.FurnitureTableEnchanting2, pos = 17},
		[118] = {sDB = ESOMRL.AT.FurnitureTableEnchanting3, pos = 18},
		[119] = {sDB = ESOMRL.AT.FurnitureTableEnchanting4, pos = 19},
		[120] = {sDB = ESOMRL.AT.FurnitureTableEnchanting5, pos = 20},
		[121] = {sDB = ESOMRL.AT.FurnitureTableProvisioning1, pos = 21},
		[122] = {sDB = ESOMRL.AT.FurnitureTableProvisioning2, pos = 22},
		[123] = {sDB = ESOMRL.AT.FurnitureTableProvisioning3, pos = 23},
		[124] = {sDB = ESOMRL.AT.FurnitureTableProvisioning4, pos = 24},
		[125] = {sDB = ESOMRL.AT.FurnitureTableProvisioning5, pos = 25},
		[126] = {sDB = ESOMRL.AT.FurnitureTableWoodworking1, pos = 26},
		[127] = {sDB = ESOMRL.AT.FurnitureTableWoodworking2, pos = 27},
		[128] = {sDB = ESOMRL.AT.FurnitureTableWoodworking3, pos = 28},
		[129] = {sDB = ESOMRL.AT.FurnitureTableWoodworking4, pos = 29},
		[130] = {sDB = ESOMRL.AT.FurnitureTableWoodworking5, pos = 30},
		[131] = {sDB = ESOMRL.AT.FurnitureTableJewelry1, pos = 31},
		[132] = {sDB = ESOMRL.AT.FurnitureTableJewelry2, pos = 32},
		[133] = {sDB = ESOMRL.AT.FurnitureTableJewelry3, pos = 33},
		[134] = {sDB = ESOMRL.AT.FurnitureTableJewelry4, pos = 34},
		[135] = {sDB = ESOMRL.AT.FurnitureTableJewelry5, pos = 35},
	}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Initialize saved variable structure and clear old obsolete data
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	for k, v in pairs(ESOMRL.AT.ProvisioningTable) do -- initialized saved vars for current existing game provisioning recipes
		local nrId = GetItemLinkItemId(v.item)
		if ESOMRL.CSV.pRecipeTrack[nrId] == nil then
			ESOMRL.CSV.pRecipeTrack[nrId] = 0
		end
	end
	for k, v in pairs(ESOMRL.AT.ProvisioningTable) do
		local nrId = GetItemLinkItemId(v.item)
		if ESOMRL.ASV.pRecipeKnown[nrId] == nil then
			ESOMRL.ASV.pRecipeKnown[nrId] = {IDs = {}}
		end
	end

	for k, v in pairs(ESOMRL.AT.FurnitureTable) do -- initialized saved vars for current existing game furniture
		local nrId = GetItemLinkItemId(v.item)
		if ESOMRL.CSV.fRecipeTrack[nrId] == nil then
			ESOMRL.CSV.fRecipeTrack[nrId] = 0
		end
	end
	for k, v in pairs(ESOMRL.AT.FurnitureTable) do
		local nrId = GetItemLinkItemId(v.item)
		if ESOMRL.ASV.fRecipeKnown[nrId] == nil then
			ESOMRL.ASV.fRecipeKnown[nrId] = {IDs = {}}
		end
	end

	for k, v in pairs(ESOMRL.AT.IngredientTable) do -- initialized saved vars for current existing game ingredients
		if ESOMRL.ASV.aIngTrack[k] == nil then
			ESOMRL.ASV.aIngTrack[k] = 0
		end
	end

-- clear old database tracking data for items no longer in the game from the saved variables
	for k, v in pairs(ESOMRL.CSV.pRecipeTrack) do -- clear out old provisioning recipes
		if ESOMRL.AT.ProvisioningKeys[k] == nil then
			ESOMRL.CSV.pRecipeTrack[k] = nil
		end
	end
	for k, v in pairs(ESOMRL.ASV.pRecipeKnown) do
		if ESOMRL.AT.ProvisioningKeys[k] == nil then
			ESOMRL.ASV.pRecipeKnown[k] = nil
		end
	end
	for k, v in pairs(ESOMRL.CSV.fRecipeTrack) do -- clear out old furniture recipes
		if ESOMRL.AT.FurnitureKeys[k] == nil then
			ESOMRL.CSV.fRecipeTrack[k] = nil
		end
	end
	for k, v in pairs(ESOMRL.ASV.fRecipeKnown) do
		if ESOMRL.AT.FurnitureKeys[k] == nil then
			ESOMRL.ASV.fRecipeKnown[k] = nil
		end
	end
	for k, v in pairs(ESOMRL.ASV.aIngTrack) do -- clear out old ingredients
		if ESOMRL.AT.IngredientTable[k] == nil then
			ESOMRL.ASV.aIngTrack[k] = nil
		end
	end

	UpdateSavedVariables(rebuild)
end

local function ProcessItemLink(sLink, rebuild, rId)
	local rLink = GetItemLinkRecipeResultItemLink(sLink)
	local _, _, _, _, hasScaling, minLevel, maxLevel, isChampionPoints, _ = GetItemLinkOnUseAbilityInfo(rLink)
	local rLow = (isChampionPoints) and "\(".."|t24:24:/esoui/art/treeicons/gamepad/achievement_categoryicon_champion.dds|t"..tostring(minLevel) or "\("..L.ESOMRL_LEVEL.." "..tostring(minLevel)
	local rHigh = (isChampionPoints) and "-"..tostring(maxLevel).." " or "-"..tostring(maxLevel).." "
	local sTypeText = ZO_GetSpecializedItemTypeText(GetItemLinkItemType(sLink))
	local _, sType = GetItemLinkItemType(sLink)
	local _, rType = GetItemLinkItemType(rLink)
	local nsId = GetItemLinkItemId(sLink)
	local nrId = GetItemLinkItemId(rLink)
	local qTable = {
		[1] = 106,
		[2] = 102,
		[3] = 103,
		[4] = 104,
		[5] = 105,
	}
	local validRecipe = true

	if rebuild and (sType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD or sType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK) then -- check provisioning recipes for old "Bound Recipe" duplicates
		local sName = zo_strformat("<<t:1>>",GetItemLinkName(sLink))
		if string.find(sName, "Bound Recipe:") ~= nil then validRecipe = false end -- these are the same in all client languages and will probably be removed eventually by ZOS
	end

	if validRecipe and not tempFilter[nrId] then

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Food & Drink Tables
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		if sType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD or sType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK then
			local insert = {ID = nsId, link = sLink, item = rLink, nrId = nrId, writ = 0, track = 0}
			local tlevel = (hasScaling) and rLow..rHigh..sTypeText:gsub(L.ESOMRL_Recipe,'').."\)" or "\("..L.ESOMRL_ANY.." "..sTypeText:gsub(L.ESOMRL_Recipe,'').."\)"

			ESOMRL.AT.ProvisioningTable[nsId] = {link = sLink, item = rLink, nrId = nrId, level = tlevel} -- build the main provisioning recipe database indexed by recipe ID
			ESOMRL.AT.ProvisioningKeys[nrId] = {ID = nsId, rInd = (rId ~= nil) and rId or 0} -- build the provisioning keys reverse lookup database
			tempFilter[nrId] = true

			local function CheckType(data) -- assign special recipes to appropriate "Delicacies" category based on type
				if sType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD then
					table.insert(ESOMRL.AT.ProvisioningDelicaciesFood, #ESOMRL.AT.ProvisioningDelicaciesFood + 1, data)
				elseif sType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK then
					table.insert(ESOMRL.AT.ProvisioningDelicaciesDrinks, #ESOMRL.AT.ProvisioningDelicaciesDrinks + 1, data)
				end
			end

		-- populate special tables for UI effect plus add to the 'Delicacies' food or drink category as appropriate
			if ESOMRL.DB.ProvisioningPsijic[nsId] then
				table.insert(ESOMRL.AT.ProvisioningTablePsijic, #ESOMRL.AT.ProvisioningTablePsijic + 1, insert)
				CheckType(insert)
			elseif ESOMRL.DB.ProvisioningOrsinium[nsId] then
				table.insert(ESOMRL.AT.ProvisioningTableOrsinium, #ESOMRL.AT.ProvisioningTableOrsinium + 1, insert)
				CheckType(insert)
			elseif ESOMRL.DB.ProvisioningWitchesFestival[nsId] then
				table.insert(ESOMRL.AT.ProvisioningTableWitchesFestival, #ESOMRL.AT.ProvisioningTableWitchesFestival + 1, insert)
				CheckType(insert)
			elseif ESOMRL.DB.ProvisioningNewLifeFestival[nsId] then
				table.insert(ESOMRL.AT.ProvisioningTableNewLifeFestival, #ESOMRL.AT.ProvisioningTableNewLifeFestival + 1, insert)
				CheckType(insert)
			elseif ESOMRL.DB.ProvisioningJesterFestival[nsId] then
				table.insert(ESOMRL.AT.ProvisioningTableJesterFestival, #ESOMRL.AT.ProvisioningTableJesterFestival + 1, insert)
				CheckType(insert)
			elseif ESOMRL.DB.ProvisioningClockworkCity[nsId] then
				table.insert(ESOMRL.AT.ProvisioningTableClockworkCity, #ESOMRL.AT.ProvisioningTableClockworkCity + 1, insert)
				CheckType(insert)

		-- https://wiki.esoui.com/Constant_Values
		-- SPECIALIZED_ITEMTYPE_FOOD_ENTREMET								6
		-- SPECIALIZED_ITEMTYPE_FOOD_FRUIT									2
		-- SPECIALIZED_ITEMTYPE_FOOD_GOURMET								7
		-- SPECIALIZED_ITEMTYPE_FOOD_MEAT									1
		-- SPECIALIZED_ITEMTYPE_FOOD_RAGOUT									5
		-- SPECIALIZED_ITEMTYPE_FOOD_SAVOURY								4
		-- SPECIALIZED_ITEMTYPE_FOOD_UNIQUE									8
		-- SPECIALIZED_ITEMTYPE_FOOD_VEGETABLE								3 
		-- SPECIALIZED_ITEMTYPE_DRINK_ALCOHOLIC								20
		-- SPECIALIZED_ITEMTYPE_DRINK_CORDIAL_TEA							25
		-- SPECIALIZED_ITEMTYPE_DRINK_DISTILLATE							26
		-- SPECIALIZED_ITEMTYPE_DRINK_LIQUEUR								23
		-- SPECIALIZED_ITEMTYPE_DRINK_TEA									21
		-- SPECIALIZED_ITEMTYPE_DRINK_TINCTURE								24
		-- SPECIALIZED_ITEMTYPE_DRINK_TONIC									22
		-- SPECIALIZED_ITEMTYPE_DRINK_UNIQUE								27
		-- SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK			171
		-- SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD			170
		-- SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING		172
		-- SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING			173
		-- SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING		174
		-- SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING			175
		-- SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING		176 
		-- SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING		177 
		-- SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING	178

		-- populate the individual food and drink sub categories
			elseif rType == SPECIALIZED_ITEMTYPE_FOOD_MEAT then -- Meat Dish
				table.insert(ESOMRL.AT.ProvisioningTableFood1, #ESOMRL.AT.ProvisioningTableFood1 + 1, insert)
			elseif rType == SPECIALIZED_ITEMTYPE_FOOD_FRUIT then -- Fruit Dish
				table.insert(ESOMRL.AT.ProvisioningTableFood2, #ESOMRL.AT.ProvisioningTableFood2 + 1, insert)
			elseif rType == SPECIALIZED_ITEMTYPE_FOOD_VEGETABLE then -- Vegetable Dish
				table.insert(ESOMRL.AT.ProvisioningTableFood3, #ESOMRL.AT.ProvisioningTableFood3 + 1, insert)
			elseif rType == SPECIALIZED_ITEMTYPE_FOOD_SAVOURY then -- Savoury Dish
				table.insert(ESOMRL.AT.ProvisioningTableFood4, #ESOMRL.AT.ProvisioningTableFood4 + 1, insert)
			elseif rType == SPECIALIZED_ITEMTYPE_FOOD_RAGOUT then -- Ragout Dish
				table.insert(ESOMRL.AT.ProvisioningTableFood5, #ESOMRL.AT.ProvisioningTableFood5 + 1, insert)
			elseif rType == SPECIALIZED_ITEMTYPE_FOOD_ENTREMET then -- Entremet Dish
				table.insert(ESOMRL.AT.ProvisioningTableFood6, #ESOMRL.AT.ProvisioningTableFood6 + 1, insert)
			elseif rType == SPECIALIZED_ITEMTYPE_FOOD_GOURMET then -- Gourmet Dish
				table.insert(ESOMRL.AT.ProvisioningTableFood7, #ESOMRL.AT.ProvisioningTableFood7 + 1, insert)
			elseif rType == SPECIALIZED_ITEMTYPE_DRINK_ALCOHOLIC then -- Alcoholic Beverage
				table.insert(ESOMRL.AT.ProvisioningTableDrinks1, #ESOMRL.AT.ProvisioningTableDrinks1 + 1, insert)
			elseif rType == SPECIALIZED_ITEMTYPE_DRINK_TEA then -- Tea Beverage
				table.insert(ESOMRL.AT.ProvisioningTableDrinks2, #ESOMRL.AT.ProvisioningTableDrinks2 + 1, insert)
			elseif rType == SPECIALIZED_ITEMTYPE_DRINK_TONIC then -- Tonic Beverage
				table.insert(ESOMRL.AT.ProvisioningTableDrinks3, #ESOMRL.AT.ProvisioningTableDrinks3 + 1, insert)
			elseif rType == SPECIALIZED_ITEMTYPE_DRINK_LIQUEUR then -- Liqueur Beverage
				table.insert(ESOMRL.AT.ProvisioningTableDrinks4, #ESOMRL.AT.ProvisioningTableDrinks4 + 1, insert)
			elseif rType == SPECIALIZED_ITEMTYPE_DRINK_TINCTURE then -- Tincture Beverage
				table.insert(ESOMRL.AT.ProvisioningTableDrinks5, #ESOMRL.AT.ProvisioningTableDrinks5 + 1, insert)
			elseif rType == SPECIALIZED_ITEMTYPE_DRINK_CORDIAL_TEA then -- Cordial Tea Beverage
				table.insert(ESOMRL.AT.ProvisioningTableDrinks6, #ESOMRL.AT.ProvisioningTableDrinks6 + 1, insert)
			elseif rType == SPECIALIZED_ITEMTYPE_DRINK_DISTILLATE then -- Distillate Beverage
				table.insert(ESOMRL.AT.ProvisioningTableDrinks7, #ESOMRL.AT.ProvisioningTableDrinks7 + 1, insert)

		-- try to catch any leftovers that slip through categories or have erroneous database info somewhere
			elseif sType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD then
				table.insert(ESOMRL.AT.ProvisioningDelicaciesFood, #ESOMRL.AT.ProvisioningDelicaciesFood + 1, insert)
			elseif sType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK then
				table.insert(ESOMRL.AT.ProvisioningDelicaciesDrinks, #ESOMRL.AT.ProvisioningDelicaciesDrinks + 1, insert)
		--	else -- Debug possible errors
		--		d("rType: "..rType.." - ".."sType: "..sType.." - "..rLink)
			end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Furniture Tables
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		elseif sType == SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING or sType == SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING or sType == SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING or sType == SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING or sType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING or sType == SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING or sType == SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING then
			local insert = {ID = nsId, link = sLink, item = rLink, nrId = nrId}
			local cType = GetItemLinkRecipeCraftingSkillType(sLink)
			local qLevel = GetItemLinkQuality(sLink)

			ESOMRL.AT.FurnitureTable[nsId] = {link = sLink, item = rLink, nrId = nrId, list = qTable[qLevel]} -- build the main furniture recipe database indexed by recipe ID
			ESOMRL.AT.FurnitureKeys[nrId] = {ID = nsId, rInd = (rId ~= nil) and rId or 0, track = 0} -- build the furniture keys reverse lookup database
			tempFilter[nrId] = true

		-- populate all of the furniture categories by craft and quality level
			if cType == CRAFTING_TYPE_BLACKSMITHING then -- Blacksmithing
				if qLevel == 1 then
					table.insert(ESOMRL.AT.FurnitureTableBlacksmithing1, #ESOMRL.AT.FurnitureTableBlacksmithing1 + 1, insert)
				elseif qLevel == 2 then
					table.insert(ESOMRL.AT.FurnitureTableBlacksmithing2, #ESOMRL.AT.FurnitureTableBlacksmithing2 + 1, insert)
				elseif qLevel == 3 then
					table.insert(ESOMRL.AT.FurnitureTableBlacksmithing3, #ESOMRL.AT.FurnitureTableBlacksmithing3 + 1, insert)
				elseif qLevel == 4 then
					table.insert(ESOMRL.AT.FurnitureTableBlacksmithing4, #ESOMRL.AT.FurnitureTableBlacksmithing4 + 1, insert)
				elseif qLevel == 5 then
					table.insert(ESOMRL.AT.FurnitureTableBlacksmithing5, #ESOMRL.AT.FurnitureTableBlacksmithing5 + 1, insert)
				end
			elseif cType == CRAFTING_TYPE_CLOTHIER then -- Clothing
				if qLevel == 1 then
					table.insert(ESOMRL.AT.FurnitureTableClothing1, #ESOMRL.AT.FurnitureTableClothing1 + 1, insert)
				elseif qLevel == 2 then
					table.insert(ESOMRL.AT.FurnitureTableClothing2, #ESOMRL.AT.FurnitureTableClothing2 + 1, insert)
				elseif qLevel == 3 then
					table.insert(ESOMRL.AT.FurnitureTableClothing3, #ESOMRL.AT.FurnitureTableClothing3 + 1, insert)
				elseif qLevel == 4 then
					table.insert(ESOMRL.AT.FurnitureTableClothing4, #ESOMRL.AT.FurnitureTableClothing4 + 1, insert)
				elseif qLevel == 5 then
					table.insert(ESOMRL.AT.FurnitureTableClothing5, #ESOMRL.AT.FurnitureTableClothing5 + 1, insert)
				end
			elseif cType == CRAFTING_TYPE_ENCHANTING then -- Enchanting
				if qLevel == 1 then
					table.insert(ESOMRL.AT.FurnitureTableEnchanting1, #ESOMRL.AT.FurnitureTableEnchanting1 + 1, insert)
				elseif qLevel == 2 then
					table.insert(ESOMRL.AT.FurnitureTableEnchanting2, #ESOMRL.AT.FurnitureTableEnchanting2 + 1, insert)
				elseif qLevel == 3 then
					table.insert(ESOMRL.AT.FurnitureTableEnchanting3, #ESOMRL.AT.FurnitureTableEnchanting3 + 1, insert)
				elseif qLevel == 4 then
					table.insert(ESOMRL.AT.FurnitureTableEnchanting4, #ESOMRL.AT.FurnitureTableEnchanting4 + 1, insert)
				elseif qLevel == 5 then
					table.insert(ESOMRL.AT.FurnitureTableEnchanting5, #ESOMRL.AT.FurnitureTableEnchanting5 + 1, insert)
				end
			elseif cType == CRAFTING_TYPE_ALCHEMY then -- Alchemy
				if qLevel == 1 then
					table.insert(ESOMRL.AT.FurnitureTableAlchemy1, #ESOMRL.AT.FurnitureTableAlchemy1 + 1, insert)
				elseif qLevel == 2 then
					table.insert(ESOMRL.AT.FurnitureTableAlchemy2, #ESOMRL.AT.FurnitureTableAlchemy2 + 1, insert)
				elseif qLevel == 3 then
					table.insert(ESOMRL.AT.FurnitureTableAlchemy3, #ESOMRL.AT.FurnitureTableAlchemy3 + 1, insert)
				elseif qLevel == 4 then
					table.insert(ESOMRL.AT.FurnitureTableAlchemy4, #ESOMRL.AT.FurnitureTableAlchemy4 + 1, insert)
				elseif qLevel == 5 then
					table.insert(ESOMRL.AT.FurnitureTableAlchemy5, #ESOMRL.AT.FurnitureTableAlchemy5 + 1, insert)
				end
			elseif cType == CRAFTING_TYPE_PROVISIONING then -- Provisioning
				if qLevel == 1 then
					table.insert(ESOMRL.AT.FurnitureTableProvisioning1, #ESOMRL.AT.FurnitureTableProvisioning1 + 1, insert)
				elseif qLevel == 2 then
					table.insert(ESOMRL.AT.FurnitureTableProvisioning2, #ESOMRL.AT.FurnitureTableProvisioning2 + 1, insert)
				elseif qLevel == 3 then
					table.insert(ESOMRL.AT.FurnitureTableProvisioning3, #ESOMRL.AT.FurnitureTableProvisioning3 + 1, insert)
				elseif qLevel == 4 then
					table.insert(ESOMRL.AT.FurnitureTableProvisioning4, #ESOMRL.AT.FurnitureTableProvisioning4 + 1, insert)
				elseif qLevel == 5 then
					table.insert(ESOMRL.AT.FurnitureTableProvisioning5, #ESOMRL.AT.FurnitureTableProvisioning5 + 1, insert)
				end
			elseif cType == CRAFTING_TYPE_WOODWORKING then -- Woodworking
				if qLevel == 1 then
					table.insert(ESOMRL.AT.FurnitureTableWoodworking1, #ESOMRL.AT.FurnitureTableWoodworking1 + 1, insert)
				elseif qLevel == 2 then
					table.insert(ESOMRL.AT.FurnitureTableWoodworking2, #ESOMRL.AT.FurnitureTableWoodworking2 + 1, insert)
				elseif qLevel == 3 then
					table.insert(ESOMRL.AT.FurnitureTableWoodworking3, #ESOMRL.AT.FurnitureTableWoodworking3 + 1, insert)
				elseif qLevel == 4 then
					table.insert(ESOMRL.AT.FurnitureTableWoodworking4, #ESOMRL.AT.FurnitureTableWoodworking4 + 1, insert)
				elseif qLevel == 5 then
					table.insert(ESOMRL.AT.FurnitureTableWoodworking5, #ESOMRL.AT.FurnitureTableWoodworking5 + 1, insert)
				end
			elseif cType == CRAFTING_TYPE_JEWELRYCRAFTING then -- Jewelry Crafting
				if qLevel == 1 then
					table.insert(ESOMRL.AT.FurnitureTableJewelry1, #ESOMRL.AT.FurnitureTableJewelry1 + 1, insert)
				elseif qLevel == 2 then
					table.insert(ESOMRL.AT.FurnitureTableJewelry2, #ESOMRL.AT.FurnitureTableJewelry2 + 1, insert)
				elseif qLevel == 3 then
					table.insert(ESOMRL.AT.FurnitureTableJewelry3, #ESOMRL.AT.FurnitureTableJewelry3 + 1, insert)
				elseif qLevel == 4 then
					table.insert(ESOMRL.AT.FurnitureTableJewelry4, #ESOMRL.AT.FurnitureTableJewelry4 + 1, insert)
				elseif qLevel == 5 then
					table.insert(ESOMRL.AT.FurnitureTableJewelry5, #ESOMRL.AT.FurnitureTableJewelry5 + 1, insert)
				end
	--		else -- Debug possible errors
	--			d("cType: "..cType.." - "..rLink)
			end
	--	else -- Debug possible errors
	--		d("sType: "..sType.." - "..rLink)
		end
	end
	return
end

local function RebuildStarter(stage)
	local ingDefaults = ESOMRL.DB.DefaultVars(1)
	local tempInt = (stage == 1) and 0 or 1
	local IdLow = (25000 * stage) - 25000
	local IdHigh = 25000 * stage
	local sMax = 12

	if stage == 1 then ResetTables() end

	for i = IdLow, IdHigh, 1 do
		local ssId = i+tempInt
		local sLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", ssId)
		local itemType, specializedItemType = GetItemLinkItemType(sLink)

		if itemType == ITEMTYPE_RECIPE then
			ProcessItemLink(sLink, true)
		end

		if i == IdHigh then
			if stage == sMax then

				for recipeListIndex = 1, GetNumRecipeLists() do -- populate the recipe list index
					local _, numRecipes = GetRecipeListInfo(recipeListIndex)
					for recipeIndex = 1, numRecipes do
						local known, recipeName = GetRecipeInfo(recipeListIndex, recipeIndex) -- this returns the name even if you don't know the recipe
						if known then -- only process known recipes
							local itemLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex) -- NOTE: this returns "" for recipes you don't know!
							local rId = GetItemLinkItemId(itemLink)
							if ESOMRL.AT.ProvisioningKeys[rId] then
								ESOMRL.AT.ProvisioningKeys[rId].rInd = recipeListIndex
							elseif ESOMRL.AT.FurnitureKeys[rId] then
								ESOMRL.AT.FurnitureKeys[rId].rInd = recipeListIndex
							end
						end
					end
				end

				local function CheckList(data) -- update the ingredient database with all current usable food/drink/furniture ingredients
					local ingnumber = GetItemLinkRecipeNumIngredients(data.link)
					for i = 1, ingnumber do
						local ingLink = GetItemLinkRecipeIngredientItemLink(data.link, i)
						local ingIcon = GetItemLinkIcon(ingLink)
						local ingID = GetItemLinkItemId(ingLink)
						if ESOMRL.AT.IngredientTable[ingID] == nil then
							ESOMRL.AT.IngredientTable[ingID] = {itier = 1, link = ingLink, icon = ingIcon}
						end
					end
				end
				for ingID, ingIcon in pairs(ESOMRL.ASV.mRecipeList.Ingredients) do -- maintain 'itier' of 0 for preset list of 50 'original' game ingredients (1 for others)
					local iT = (ingDefaults[ingID] == nil) and 1 or 0
					local ingLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", ingID)
					if ESOMRL.AT.IngredientTable[ingID] == nil then
						ESOMRL.AT.IngredientTable[ingID] = {itier = iT, link = ingLink, icon = ingIcon}
					end
				end
				for k, v in pairs(ESOMRL.AT.ProvisioningTable) do
					CheckList(v)
				end
				for k, v in pairs(ESOMRL.AT.FurnitureTable) do
					CheckList(v)
				end

				FinalizeMainTables(true)
				return
			else
				zo_callLater(function() RebuildStarter(stage+1) end, 500)
				return
			end
		end
	end
end

local function UpdateStarter()
	local ingDefaults = ESOMRL.DB.DefaultVars(1)
	for nsId, rId in pairs(ESOMRL.ASV.mRecipeList.Provisioning) do -- use saved variables instead of full game ID search to build DB when update not required (speed)
		local sLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", nsId)
		ProcessItemLink(sLink, false, rId)
	end
	for nsId, rId in pairs(ESOMRL.ASV.mRecipeList.Furniture) do
		local sLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", nsId)
		ProcessItemLink(sLink, false, rId)
	end

	for ingID, ingIcon in pairs(ESOMRL.ASV.mRecipeList.Ingredients) do -- maintain 'itier' of 0 for preset list of 50 'original' game ingredients (1 for others)
		local iT = (ingDefaults[ingID] == nil) and 1 or 0
		local ingLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", ingID)
		if ESOMRL.AT.IngredientTable[ingID] == nil then
			ESOMRL.AT.IngredientTable[ingID] = {itier = iT, link = ingLink, icon = ingIcon}
		end
	end

	FinalizeMainTables(false)
	return
end

function ESOMRL.DB.InitTables(rebuild)
	if not updateRunning then
		tempFilter = {}
		updateRunning = true

	-- only run the slower functions to completely rebuild the database if API version changes or user manually runs "/mrl update"
		if (rebuild) then
			d(L.ESOMRL_UPDATE3)
			RebuildStarter(1)
		else
			local cAPIversion = ESOMRL.ASV.aOpts.APIversion
			if cAPIversion and cAPIversion == GetAPIVersion() then
				UpdateStarter()
			else
				d(L.ESOMRL_UPDATE3)
				RebuildStarter(1)
			end
		end
	end
end
