-- Author: Momorodah

MomosSN.style = {}

table.insert(MomosSN.defaultVariables.stickyNotes, ZO_DeepTableCopy(MomosSN.defaultSN, nil))
-- Define sticky notes table so we can keep track of and reference all the sticky notes
MomosSN.stickyNotes = {}
-- Define controlList for populating ControlList later
MomosSN.controlList = {}

function MomosSN.style:Initialize()
	-- Create a top level control to house all the sticky notes
	MomosSN.root = WINDOW_MANAGER:CreateTopLevelWindow("MomosSN_root")

	local fragment = ZO_HUDFadeSceneFragment:New(MomosSN.root, nil, 0)
	--local fragment = ZO_SimpleSceneFragment:New(MomosSN.root, nil, 0)
	HUD_SCENE:AddFragment(fragment)
	HUD_UI_SCENE:AddFragment(fragment)
	MomosSN.root:ClearAnchors()
	MomosSN.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT)

	-- Create Sticky note control list for showing/hiding individual notes
	MomosSN.style:CreateControlList()
	
	for key, SNTable in ipairs(MomosSN.savedVariables.stickyNotes) do
		stickyNoteControls = MomosSN.style:CreateSN(SNTable)
		table.insert(MomosSN.stickyNotes, stickyNoteControls)
		
		table.insert(MomosSN.controlList, {
		SNTable = SNTable,
		stickyNoteControls = stickyNoteControls,
		})
	end
	
	-- Populate controlList
	MomosSN.style:UpdateScrollList(MomosSN.controlListControls.scrollList, MomosSN.controlList, 1)
end

function MomosSN.style:CreateControlList()
	local controlListControls = {}

	-- Backdrop
	local backdrop = MomosSN.root:CreateControl("MomosSN_Backdrop_ControlList", CT_BACKDROP)
	controlListControls.backdrop = backdrop
	backdrop:SetMouseEnabled(true)
	backdrop:SetMovable(true)
	backdrop:SetClampedToScreen(true)
	backdrop:SetResizeHandleSize(5)
	backdrop:ClearAnchors()
	backdrop:SetAnchor(TOPLEFT, MomosSN.root, TOPLEFT, MomosSN.savedVariables.controlListX, MomosSN.savedVariables.controlListY)
	
	backdrop:SetCenterColor(0, 0, 0, 0.6)
	backdrop:SetEdgeColor(0, 0, 0, 0)

	-- Backdrop handlers
	backdrop:SetHandler("OnMoveStop", function(control)
		MomosSN.style:SaveControlListPosition()
	end)
	backdrop:SetHandler("OnResizeStop", function(control)
		MomosSN.style:StopControlListResize()
	end)

	-- Label
	local label = backdrop:CreateControl("MomosSN_Label_ControlList", CT_LABEL)
	controlListControls.label = label
	label:SetFont("$(HANDWRITTEN_FONT)|" .. MomosSN.controlListLabelHeight)
	label:SetColor(1,1,1,1)
	label:SetText("Sticky Notes")
	label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	label:ClearAnchors()
	label:SetAnchor(TOP, backdrop, TOP)

	-- ScrollList
	-- Source: https://www.esoui.com/downloads/info569-ScrollListExample.html#info
	local scrollList = WINDOW_MANAGER:CreateControlFromVirtual("MomosSN_list_ControlList", backdrop, "ZO_ScrollList")
	controlListControls.scrollList = scrollList
	-- Anchor the top of the scrollList to the bottom of the label so they don't overlap
	scrollList:SetAnchor(TOP, label, BOTTOM)
	-- Create data type
	local typeId = 1
	local templateName = "ZO_SelectableLabel"
	local height = 25 -- height of the row, not the window
	local setupFunction = MomosSN.style.LayoutRow
	local hideCallback = nil
	local dataTypeSelectSound = nil
	local resetControlCallback = nil
	local selectTemplate = "ZO_ThinListHighlight"
	local selectCallback = MomosSN.style.OnRowSelect
	
	ZO_ScrollList_AddDataType(scrollList, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
	ZO_ScrollList_EnableSelection(scrollList, selectTemplate, selectCallback)
	
	MomosSN.controlListControls = controlListControls
	
	-- Set dimensions for all controls
	MomosSN.style.SetControlListDimensions()
	
	-- Hide by default
	MomosSN.style:ToggleControlList()
end

function MomosSN.style.ToggleControlList()
	MomosSN.controlListControls.backdrop:SetHidden(not MomosSN.controlListControls.backdrop:IsHidden())
end

function MomosSN.style.ToggleControlListWithMouse()
	MomosSN.style.ToggleControlList()
	-- Toggle mouse (if only there was a way to check if the mouse is actually shown or not..?)
	SCENE_MANAGER:OnToggleHUDUIBinding()
end

function MomosSN.style.ToggleSN(stickyNoteControls, SNTable)
	stickyNoteControls.backdrop:SetHidden(not stickyNoteControls.backdrop:IsHidden())
	-- Update sn hidden status in savedVariables
	SNTable.hidden = stickyNoteControls.backdrop:IsHidden()
end

function MomosSN.style:OnRowSelect(previouslySelectedData, selectedData, reselectingDuringRebuild)
    if not selectedData then return end
    UseCollectible(selectedData.index)
end

function MomosSN.style.LayoutRow(rowControl, data, scrollList)
	rowControl:SetFont("$(STONE_TABLET_FONT)|16")
	rowControl:SetMaxLineCount(1)
	rowControl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	local textString = ""
	if data.SNTable.hidden then	textString = "|c" .. MomosSN.hiddenFontColour .. data.SNTable.name .. "|r"
	else textString = "|c" .. MomosSN.shownFontColour .. data.SNTable.name .. "|r" end
	
	rowControl:SetText(textString)
	rowControl:SetHandler("OnMouseUp", function() MomosSN.style.ToggleViaControlList(data.stickyNoteControls, data.SNTable, rowControl) end)
end

-- We use this function to change the colour of the text to match hidden status..
function MomosSN.style.ToggleViaControlList(stickyNoteControls, SNTable, rowControl)
	MomosSN.style.ToggleSN(stickyNoteControls, SNTable)

	local textString = ""
	if SNTable.hidden then textString = "|c" .. MomosSN.hiddenFontColour .. SNTable.name .. "|r"
	else textString = "|c" .. MomosSN.shownFontColour .. SNTable.name .. "|r" end
	rowControl:SetText(textString)
end

function MomosSN.style:UpdateScrollList(control, data, rowType)
	local dataList = ZO_ScrollList_GetDataList(control)
	
	-- Do we really need to clear it when we only populate the list once during it's lifetime? (should test this..)
	ZO_ScrollList_Clear(control)
	
	for key, value in ipairs(data) do
		local entry = ZO_ScrollList_CreateDataEntry(rowType, value)
		table.insert(dataList, entry)
	end
	
	table.sort(dataList, function(a,b) return a.data.SNTable.name < b.data.SNTable.name end)
	 
	-- Redraw the scroll list.
	ZO_ScrollList_Commit(control)
end

function MomosSN.style:CreateSN(SNTable)
	local stickyNoteControls = {}
	
	-- Backdrop
	local backdrop = MomosSN.root:CreateControl("MomosSN_Backdrop_" .. SNTable.identifier, CT_BACKDROP)
	stickyNoteControls.backdrop = backdrop
	backdrop:SetMouseEnabled(true)
	backdrop:SetMovable(true)
	backdrop:SetClampedToScreen(true)
	backdrop:SetResizeHandleSize(5)
	backdrop:ClearAnchors()
	backdrop:SetAnchor(TOPLEFT, MomosSN.root, TOPLEFT, SNTable.x, SNTable.y)
	-- Backdrop handlers
	backdrop:SetHandler("OnMoveStop", function(control)
		MomosSN.style:SaveSNPosition(stickyNoteControls, SNTable)
	end)
	backdrop:SetHandler("OnResizeStart", function(control)
		MomosSN.style:StartSNResize(stickyNoteControls, SNTable)
	end)

	backdrop:SetHandler("OnResizeStop", function(control)
		MomosSN.style:StopSNResize(stickyNoteControls, SNTable)
	end)
	-- Restore hidden status
	backdrop:SetHidden(SNTable.hidden)

	-- Label
	local label = backdrop:CreateControl("MomosSN_Label_" .. SNTable.identifier, CT_LABEL)
	stickyNoteControls.label = label
	label:SetFont("$(" .. MomosSN.helpers:ConvertFontNameString(SNTable.headerFontName) .. ")|" .. SNTable.headerFontSize)
	label:SetColor(unpack(SNTable.headerFontColor))
	label:SetText(SNTable.name)
	label:SetHorizontalAlignment(MomosSN.helpers:ConvertTextAlignString(SNTable.headerFontAlignment))
	label:ClearAnchors()
	label:SetAnchor(TOP, backdrop, TOP)

	-- Editbox
	local editbox = backdrop:CreateControl("MomosSN_Editbox_" .. SNTable.identifier, CT_EDITBOX)
	stickyNoteControls.editbox = editbox
	ApplyTemplateToControl(editbox, "ZO_DefaultEditMultiLineForBackdrop")
	editbox:SetFont("$(" .. MomosSN.helpers:ConvertFontNameString(SNTable.contentFontName) .. ")|" .. SNTable.contentFontSize)
	editbox:SetColor(unpack(SNTable.contentFontColor))
	editbox:SetMouseEnabled(true)
	editbox:SetEditEnabled(true)
	editbox:SetMultiLine(true)
	editbox:SetNewLineEnabled(true)
	editbox:SetPasteEnabled(true)
	editbox:SetCopyEnabled(true)
	editbox:SetText(SNTable.text)
	editbox:SetMaxInputChars(1950)
	editbox:ClearAnchors()
	-- Anchor the top of the editbox to the bottom of the label so they don't overlap
	editbox:SetAnchor(TOP, label, BOTTOM)
	editbox:SetHandler("OnFocusLost", function(control)
		SNTable.text = control:GetText()
	end)
		
	-- Background texture
	if SNTable.backgroundEnabled then
		MomosSN.style:AddBackgroundTexture(stickyNoteControls, SNTable)
		backdrop:SetCenterColor(0,0,0,0)
		backdrop:SetEdgeColor(0,0,0,0)
	else
		backdrop:SetCenterColor(unpack(SNTable.centerColor))
		backdrop:SetEdgeColor(unpack(SNTable.edgeColor))
	end

	-- Icon texture
	MomosSN.style:AddIconTexture(stickyNoteControls, SNTable)

	-- Set dimensions for all controls
	MomosSN.style.SetSNDimensions(stickyNoteControls, SNTable)

	return stickyNoteControls
end

function MomosSN.style:StartSNResize(stickyNoteControls, SNTable)
	-- Add resizing background colour for visuals if background texture is active
	if SNTable.backgroundEnabled then
		stickyNoteControls.backdrop:SetCenterColor(1,1,1,0.5)
		stickyNoteControls.bgTexture:SetHidden(true)
	end
end

function MomosSN.style:StopSNResize(stickyNoteControls, SNTable)
	local width, height = stickyNoteControls.backdrop:GetDimensions()
	SNTable.width = width
	SNTable.height = height
	
	MomosSN.style.SetSNDimensions(stickyNoteControls, SNTable)
	
	-- Remove resizing background colour if background texture is active
	if SNTable.backgroundEnabled then
		stickyNoteControls.backdrop:SetCenterColor(1,1,1,0)
		stickyNoteControls.bgTexture:SetHidden(false)
	end
	
	-- Save the position again since it has shifted with the resizing
	MomosSN.style:SaveSNPosition(stickyNoteControls, SNTable)
end

function MomosSN.style.SetSNDimensions(stickyNoteControls, SNTable)
	-- Backdrop
	stickyNoteControls.backdrop:SetDimensions(SNTable.width, SNTable.height)
	-- Label
	stickyNoteControls.label:SetDimensions(SNTable.width, SNTable.headerFontSize)
	-- Editbox
	stickyNoteControls.editbox:SetDimensions(SNTable.width - 10, SNTable.height - SNTable.headerFontSize - 10)
	-- Texture
	if stickyNoteControls.bgTexture ~= nil then
		MomosSN.style:SetBackgroundDimensions(stickyNoteControls.bgTexture, SNTable)
	end
end

function MomosSN.style:SaveSNPosition(stickyNoteControls, SNTable)
	local x, y = stickyNoteControls.backdrop:GetScreenRect()
	SNTable.x = x
	SNTable.y = y
end

function MomosSN.style.SetControlListDimensions()
	-- Backdrop
	MomosSN.controlListControls.backdrop:SetDimensions(MomosSN.savedVariables.controlListWidth, MomosSN.savedVariables.controlListHeight)
	-- Label
	MomosSN.controlListControls.label:SetDimensions(MomosSN.savedVariables.controlListWidth, MomosSN.controlListLabelHeight + 5)
	-- ScrollList
	MomosSN.controlListControls.scrollList:SetDimensions(MomosSN.savedVariables.controlListWidth, MomosSN.savedVariables.controlListHeight - MomosSN.controlListLabelHeight - 10)
end

function MomosSN.style:SaveControlListPosition()
	local x, y = MomosSN.controlListControls.backdrop:GetScreenRect()
	MomosSN.savedVariables.controlListX = x
	MomosSN.savedVariables.controlListY = y
end

function MomosSN.style:StopControlListResize()
	local width, height = MomosSN.controlListControls.backdrop:GetDimensions()
	MomosSN.savedVariables.controlListWidth = width
	MomosSN.savedVariables.controlListHeight = height
	
	MomosSN.style.SetControlListDimensions()
	
	-- Save the position again since it has shifted with the resizing
	MomosSN.style:SaveControlListPosition()
end

-- AddBackgroundTexture
function MomosSN.style:AddBackgroundTexture(stickyNoteControls, SNTable)
	local bgTexture = WINDOW_MANAGER:CreateControl("MomosSN_background_" .. SNTable.identifier, stickyNoteControls.backdrop, CT_TEXTURE)
	
	local textureData = MomosSN.backgrounds[SNTable.backgroundName]
	if textureData == nil then return end

	if textureData.filePath ~= "" then
		bgTexture:SetTexture(textureData.filePath)
		stickyNoteControls.bgTexture = bgTexture
		bgTexture:SetAnchor(CENTER, stickyNoteControls.backdrop, CENTER, 0, 0)
		MomosSN.style:SetBackgroundDimensions(bgTexture, SNTable)
		
		-- Keep the background texture behind all other controls
		bgTexture:SetDrawTier(DT_LOW)
	end
end
-- SetBackgroundDimensions
function MomosSN.style:SetBackgroundDimensions(texture, SNTable)
	local textureData = MomosSN.backgrounds[SNTable.backgroundName]

	if textureData == nil then return end

	local fdW = 1024
	local fdH = 1024
	local widthMod = fdW / textureData.properWidth
	local heightMod = fdH / textureData.properHeight
	texture:SetDimensions(SNTable.width * widthMod, SNTable.height * heightMod)
end

function MomosSN.style:AddIconTexture(stickyNoteControls, SNTable)
	local iconTexture = WINDOW_MANAGER:CreateControl("MomosSN_icon_" .. SNTable.identifier, stickyNoteControls.backdrop, CT_TEXTURE)

	local textureData = MomosSN.icons[SNTable.iconName]
	if textureData == nil then return end

	if textureData.filePath ~= "" then
		iconTexture:SetTexture(textureData.filePath)
		stickyNoteControls.iconTexture = iconTexture
		iconTexture:SetDimensions(SNTable.iconScale * 8, SNTable.iconScale * 8)
		iconTexture:SetAnchor(MomosSN.helpers:ConvertAnchorString(SNTable.iconAnchor), stickyNoteControls.editbox,
			MomosSN.helpers:ConvertAnchorString(SNTable.iconAnchor), SNTable.iconOffsetX, SNTable.iconOffsetY)
		if SNTable.iconColorEnabled then
			iconTexture:SetColor(unpack(SNTable.iconColor))
		end
		-- Keep the icon texture in front of the background texture
		iconTexture:SetDrawTier(DT_MEDIUM)
		-- Enable mouse for icon so we can listen for OnMouseDown event
		iconTexture:SetMouseEnabled(true)
		-- Icon handlers
		iconTexture:SetHandler("OnMouseDown", function(control)
			MomosSN.style:ToggleControlList()
		end)

	end
end