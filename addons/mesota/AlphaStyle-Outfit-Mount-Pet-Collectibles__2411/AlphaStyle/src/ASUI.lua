-- Helper
local SM = SCENE_MANAGER
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local OFMGR = ZO_OUTFIT_MANAGER
local ZOSF = zo_strformat

-- locals
local STYLE_BG_COLOR = ZO_ColorDef:New(0, 0, 0, 0.2)
local STYLE_BORDER_COLOR = ZO_ColorDef:New(0xFC, 0xFC, 0xFC, 0.5)
local DUMMY_CATEGORY_COSTUME = 999
local STILESETS_DATA = 5
local MSG = ASLang.msg



-- AlphaStyle App
ASApp = {}

-- Meta
ASApp.name = 'AlphaStyle'
ASApp.displayname = 'AlphaStyle'
ASApp.version = 'v1.0.0'
ASApp.author = 'mesota'

-- Update Event Queue
ASApp.Jobs = {}                -- List of jobs to be executed in the OnUpdate event. Element of form {JOB_TYPE, BAG, SLOT}
ASApp.NextEventTime = 0        -- Time for the next event

-- AlphaStyle UI
ASUI = {}
ASUI.detailControls = {}
ASUI.currentStyleSetId = false


--- Writes trace messages to the console
-- fmt with %d, %s,
local function trace(fmt, ...)
	if ASModel.isDebug then
		d(string.format(fmt, ...))
    end
end

function ASUI.SetCurrentStyleSetId(id)
	ASUI.currentStyleSetId = id
end

function ASUI.GetCurrentStyleSetId()
	return ASUI.currentStyleSetId
end

----------------------------- Helper

local function CreateBuildSectionLabel (parent, sectionId, previousCtrl, anchorPoint, relPoint, xOffset, yOffset)
	local sectionInfo = SET_SECTIONS[sectionId]

	local buildSectionLabelCtrl = WM:CreateControlFromVirtual("$(parent)_"..sectionInfo[2], parent, 'AS_SectionLabelTemplate')
	buildSectionLabelCtrl:SetAnchor(anchorPoint, previousCtrl, relPoint, xOffset, yOffset)

	buildSectionLabelCtrl:GetNamedChild("Label"):SetText(sectionInfo[1])
	buildSectionLabelCtrl:GetNamedChild("Label"):SetHorizontalAlignment(TEXT_ALIGN_LEFT)

	return buildSectionLabelCtrl
end


function ASUI.HideDetails()
	for _, ctrl in pairs(ASUI.detailControls) do
		ctrl:SetHidden(true)
	end
end

function ASUI.ShowEditorTooltip(control, msg) 
	InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -5)
	SetTooltipText(InformationTooltip, msg)
end

function ASUI.HideEditorTooltip() 
	ClearTooltip(InformationTooltip)	
end



function ASUI.ListColls()
	
	for categoryIndex=1, GetNumCollectibleCategories() do

		local name, numSubCatgories, numCollectibles, unlockedCollectibles = GetCollectibleCategoryInfo(categoryIndex)

		if numSubCatgories > 0 then
			for subCategoryIndex=1, numSubCatgories do
			
				local subCategoryName, subCategoryNumCollectibles, subCategoryUnlockedCollectibles = GetCollectibleSubCategoryInfo(categoryIndex, subCategoryIndex)

				local catId = GetCollectibleCategoryId(categoryIndex, subCategoryIndex)

				d("Cat: "..name.."/"..subCategoryName.." CatIndex: "..categoryIndex.."/"..subCategoryIndex.." CatId: "..catId)
		
				--[[
				for collectibleIndex=1, subCategoryNumCollectibles do
				
					local collectibleId = GetCollectibleId(categoryIndex, subCategoryIndex, collectibleIndex)
					local collectibleName, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(collectibleId)

					d("Cat: "..name.." SC: "..subCategoryName.." Col: "..collectibleName)
				end
			--]]
			end
		else
			local catId = GetCollectibleCategoryId(categoryIndex, nil)
			d("Cat: "..name.." CatIndex: "..categoryIndex.." CatId: "..catId)
		end
	end
				
end


function ASUI.ShowTooltip(parent)
	local catType = parent["StyleCategoryType"]

	if not catType then return end

	local currentId = ASUI.GetCurrentStyleSetId()
	local style = ASModel.GetStyleById(currentId)

	if not style then return end

	ClearTooltip(ItemTooltip)
	local offsetX = parent:GetParent():GetLeft() - parent:GetLeft() - 5
	InitializeTooltip(ItemTooltip, parent, RIGHT, offsetX, 0, LEFT)

	if catType == DUMMY_CATEGORY_COSTUME then
		local costume = style.Costume
		if costume and costume.id ~= 0 then
			local SHOW_NICKNAME, SHOW_PURCHASABLE_HINT, SHOW_BLOCK_REASON = true, true, true
			ItemTooltip:SetLink(costume.link)
		else 
			SetTooltipText(ItemTooltip, MSG.GEAR_APPEARANCE)
		end
	else
		local colId = style.Collectibles[catType]

		if colId and colId ~= 0 then
			local SHOW_NICKNAME, SHOW_PURCHASABLE_HINT, SHOW_BLOCK_REASON = true, true, true
			ItemTooltip:SetCollectible(colId, SHOW_NICKNAME, SHOW_PURCHASABLE_HINT, SHOW_BLOCK_REASON)
		else
			local name, texttureName = ASModel.GetCatInfoByCatType(catType)

			SetTooltipText(ItemTooltip, name)
		end
	end
end

function ASUI.HideTooltip(parent)
	ASUI.HideEditorTooltip() 
	ClearTooltip(ItemTooltip)
end

--[[
function ASUI.HandleNameChanged(editCtrl)
	local currentId = ASUI.GetCurrentStyleSetId()
	local style = ASModel.GetStyleById(currentId)

	if not style then return end

	-- update model
	style.Name = editCtrl:GetText()

	-- update UI
	local listControl = WM:GetControlByName('AS_MainListDetailListContainerList')
	local ctrl = ZO_ScrollList_GetSelectedControl(listControl)

	local nameControl = GetControl(ctrl, "Name")
	nameControl:SetText(style.Name)
end
--]]


function ASUI.InitStyleSetDetails()
	ASUI.detailControls.styleSetDetailsControl = WM:GetControlByName('AS_MainListDetailDetailContainerDetailsStyleSetDetails')
	ASUI.detailControls.styleSetDetailsControl:SetHidden(true)

	local function CreateStyleItemCtrl (catType, previousCtrl, anchorPoint, relPoint, xOffset, yOffset)
		local styleSetItemCtrl = WM:CreateControlFromVirtual("AS_StyleSetItem_"..catType, ASUI.detailControls.styleSetDetailsControl, 'AS_SetItemTemplate')
		styleSetItemCtrl:SetAnchor(anchorPoint, previousCtrl, relPoint, xOffset, yOffset)
		local itemCtrl = styleSetItemCtrl:GetNamedChild('Icon')

		-- tooltip
		itemCtrl:SetHandler('OnMouseEnter',function(self) ASUI.ShowTooltip(self) end)
		itemCtrl:SetHandler('OnMouseExit',function(self) ASUI.HideTooltip(self) end)
		itemCtrl["StyleCategoryType"] = catType
	
		return styleSetItemCtrl
	end

	local firstRowOffset = 40
	local rowOffset = 10
	local colSpacing = 10


	-- Title
	local titleCtrl = WM:CreateControlFromVirtual("AS_StyleSetTitle", ASUI.detailControls.styleSetDetailsControl, 'AS_SetLabelTemplate')
	titleCtrl:SetAnchor(TOPLEFT, ASUI.detailControls.styleSetDetailsControl, TOPLEFT, 5, rowOffset)
	titleCtrl:SetAnchor(BOTTOMRIGHT, ASUI.detailControls.styleSetDetailsControl, TOPRIGHT, -5, rowOffset+30)

	-- OUtfit
	local outfitCtrl = WM:CreateControlFromVirtual("AS_StyleSetOutfit", ASUI.detailControls.styleSetDetailsControl, 'AS_SetLabelTemplate')
	outfitCtrl:SetAnchor(TOPLEFT, titleCtrl, BOTTOMLEFT, 0, rowOffset)
	outfitCtrl:SetAnchor(BOTTOMRIGHT, titleCtrl, BOTTOMRIGHT, 0, rowOffset+30)


	-- Collectibles
	local categories = ASModel.GetCategories()

	local counter = 1
	local prevControl = CreateStyleItemCtrl(categories[1], outfitCtrl, TOPLEFT, BOTTOMLEFT, 0, rowOffset)
	local firstOfRow = prevControl

	for categoryIndex = 2, #categories do
		if counter % 4 > 0 then
			prevControl = CreateStyleItemCtrl(categories[categoryIndex], prevControl, TOPLEFT, TOPRIGHT, colSpacing, 0)
		else
			prevControl = CreateStyleItemCtrl(categories[categoryIndex], firstOfRow, TOPLEFT, BOTTOMLEFT, 0, rowOffset)
			firstOfRow = prevControl
		end
		counter = counter + 1
	end

	-- Costume (Gear)
	if counter % 4 > 0 then
		CreateStyleItemCtrl(DUMMY_CATEGORY_COSTUME, prevControl, TOPLEFT, TOPRIGHT, colSpacing, 0)
	else 
		CreateStyleItemCtrl(DUMMY_CATEGORY_COSTUME, firstOfRow, TOPLEFT, BOTTOMLEFT, 0, rowOffset)
	end
end



function ASUI.UpdateStyleSetDetails()
	trace("UpdateStyleSetDetails")

	local function UpdateControl(ctrl, texttureName, centerColor, edgeColor)
		local itemCtrl = ctrl:GetNamedChild('Icon')
		local bgCtrl = ctrl:GetNamedChild('BG')
		ctrl:SetHidden(false)
		itemCtrl:SetNormalTexture(texttureName)
		bgCtrl:SetCenterColor(centerColor:UnpackRGBA())
		bgCtrl:SetEdgeColor(edgeColor:UnpackRGBA())
	end


	local currentId = ASUI.GetCurrentStyleSetId()
	local style = ASModel.GetStyleById(currentId)

	if not style then return end

	-- Update Title
	local titleName = "<No Title>"

	if style.TitleId and style.TitleId ~= ASModel.NO_TITLE_ID then
        titleName = GetTitle(style.TitleId)
	end

	if style.IgnoreTitle then
		titleName = titleName.." (ignored)"
	end


	local titleCtrl = WM:GetControlByName('AS_StyleSetTitle'):GetNamedChild('Label')
	titleCtrl:SetText(titleName)
	
	-- Update Outfit
	local outfitName = "<No Outfit>"
	local outfitManipulator = OFMGR:GetOutfitManipulator(GAMEPLAY_ACTOR_CATEGORY_PLAYER, style.OutfitId)
	
	if outfitManipulator then
		outfitName = outfitManipulator:GetOutfitName()
	end
	local labelCtrl = WM:GetControlByName('AS_StyleSetOutfit'):GetNamedChild('Label')
	labelCtrl:SetText(outfitName)

	-- Update Collectibles
	local categories = ASModel.GetCategories()

	local texttureName
	local centerColor = STYLE_BG_COLOR
	local edgeColor = STYLE_BORDER_COLOR

	for categoryIndex = 1, #categories do
		local colId = style.Collectibles[categories[categoryIndex]]

		local styleSetItemCtrl = WM:GetControlByName("AS_StyleSetItem_"..categories[categoryIndex])

		if colId and colId ~= 0 then
			local name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType = GetCollectibleInfo(colId)
			texttureName = icon
		else
			local _
			_, texttureName = ASModel.GetCatInfoByCatType(categories[categoryIndex])

			if texttureName == "" then
				texttureName = "esoui/art/buttons/decline_up.dds"
			end
		end

		UpdateControl (styleSetItemCtrl, texttureName, centerColor, edgeColor)
	end
	
	-- costume (gear)
	texttureName = "/esoui/art/restyle/gamepad/gp_dyes_tabicon_outfitstyledye.dds"

	local styleSetItemCtrl = WM:GetControlByName("AS_StyleSetItem_"..DUMMY_CATEGORY_COSTUME)

	local costume = style.Costume
	if costume and costume.id ~= 0 then
		texttureName = GetItemLinkIcon(costume.link)
	end

	UpdateControl (styleSetItemCtrl, texttureName, centerColor, edgeColor)
end

function ASUI.OnListAdd()
	trace('OnListAdd')
	ASModel.NewStyle()
	ASUI.ShowStyleSetsTab()
end

function ASUI.OnListDelete()
	trace('OnListDelete')
	ASModel.DeleteStyle (ASUI.GetCurrentStyleSetId())
	ASUI.ShowStyleSetsTab()
end

function ASUI.OnReloadStyle()
	trace('OnReloadStyle')
	ASModel.ReloadStyle (ASUI.GetCurrentStyleSetId())
	ASUI.ShowStyleSetsTab()
end

function ASUI.OnEditStyleProperties()
	trace('OnEditStyleProperties')
	local currentId = ASUI.GetCurrentStyleSetId()
	if not currentId then
		return
	end

	ZO_Dialogs_ShowDialog("AS_EDIT_STYLE_PROPERTIES_DIALOG", {})
end

function ASUI.OnUseStyle()
	trace('OnUseStyle')
	ASModel.LoadStyleById(ASUI.GetCurrentStyleSetId())
end

function ASUI.OnInitMain()
    trace('OnInitMain')
    SM:RegisterTopLevel(AS_Main, true)

	ASUI.InitStyleSetDetails()
	-- zo_callLater(ASUI.ShowStyleSetsTab, 1000)
	-- zo_callLater(ASUI.ListColls, 1000)
end

function ASUI.OnHighlightItem (control, isHighlighted)
	-- trace('OnHighlightItem!')
end

function ASUI.SimpleRow_OnMouseEnter(rowControl)
	-- list:EnterRow(rowControl)
	--d("Item MouseEnter")
	local listControl = WM:GetControlByName('AS_MainListDetailListContainerList')
	ZO_ScrollList_MouseEnter(listControl, rowControl)
end

function ASUI.SimpleRow_OnMouseExit(rowControl)
	-- list:ExitRow(rowControl)
	--d("Item MouseExit")
	local listControl = WM:GetControlByName('AS_MainListDetailListContainerList')
	ZO_ScrollList_MouseExit(listControl, rowControl)
end

function ASUI.SimpleRow_OnMouseUp(rowControl, button, upInside)
	--local data = ZO_ScrollList_GetData(rowControl)
	--d("Item selected: "..data.name)
	if upInside then
		local listControl = WM:GetControlByName('AS_MainListDetailListContainerList')
		ZO_ScrollList_MouseClick(listControl, rowControl)
	end
end


function ASUI.OnSelectItem (previouslySelectedData, selectedData, reselectingDuringRebuild)

	if selectedData then
		trace("Item selected: "..selectedData.name)

		ASUI.SetCurrentStyleSetId(selectedData.id)
		ASUI.UpdateStyleSetDetails()
		--ASModel.LoadStyleById(selectedData.id)
	end
end


function ASUI.IsDataEqual(data1, data2)
	return data1.id == data2.id
end


function ASUI.FillMainList(dataType, setData) 

	local function SetupSimpleRow(control, data)
		local nameControl = GetControl(control, "Name")
		nameControl:SetText(data.name)
	end

	local listControl = WM:GetControlByName('AS_MainListDetailListContainerList')

	ZO_ScrollList_AddDataType(listControl, dataType, "AS_SimpleRow", 30, SetupSimpleRow)
	ZO_ScrollList_EnableHighlight(listControl, "ZO_ThinListHighlight", ASUI.OnHighlightItem)
	ZO_ScrollList_EnableSelection(listControl, "ZO_ThinListHighlight", ASUI.OnSelectItem)
	ZO_ScrollList_SetEqualityFunction(listControl, dataType, ASUI.IsDataEqual)

	local scrollData = ZO_ScrollList_GetDataList(listControl)
	-- scrollData:SetAlternateRowBackgrounds(true)

	ZO_ScrollList_Clear(listControl)
	
	local selectedData = {}
	local currentId = ASUI.GetCurrentStyleSetId()

	for i = 1, #setData do
		local data = setData[i]
		scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(dataType, data)

		if data.id == currentId or i == 1 then 
			selectedData = data
		end
	end

	ASUI.SetCurrentStyleSetId(selectedData.id)

	ZO_ScrollList_Commit(listControl)	
	ZO_ScrollList_SelectData(listControl, selectedData)
end



function ASUI.ShowStyleSetsTab() 
	trace('ShowStyleSetsTab')

	local styleData = ASModel.GetStylesSorted() 

	ASUI.FillMainList (STILESETS_DATA, styleData)
	-- Show panel and update contents
	ASUI.detailControls.styleSetDetailsControl:SetHidden(false)
	ASUI.UpdateStyleSetDetails()
end

function ASUI.ToggleDebug(extra)
    ASModel.isDebug = not ASModel.isDebug
    if ASModel.isDebug then
        d("AlphaStyle: debug messages ON")
    else
        d("AlphaStyle: debug messages OFF")
    end
end

function ASUI.ToggleMain(extra)
    trace('ToggleMain')
	SM:ToggleTopLevel(AS_Main)
	if not AS_Main:IsHidden() then
		ASUI.ShowStyleSetsTab() 
	end
end

function ASUI.HideMain()
	trace('HideMain')
	SM:ToggleTopLevel(AS_Main)
end

function ASUI.StoreStyle(name)
    if not name or name == '' then
        d("AlphaStyle: you must provide a name for the style to store")
        return
    end

	ASModel.StoreStyleByName(name)
	if not AS_Main:IsHidden() then
		ASUI.ShowStyleSetsTab() 
	end
end

function ASUI.LoadStyle(name)
    if not name or name == '' then
        d("AlphaStyle: you must provide a name for the style to load")
        return
    end

    ASModel.LoadStyleByName (name)
end

