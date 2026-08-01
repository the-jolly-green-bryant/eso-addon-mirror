--[[
Title:   Edit Window
Version: 1.1.2
Author:  @Skotharr-do [PC/EU]
--]]

IC.EditWindow = {}

local CHAT_MAX_BYTES = 350
local MAX_CHARACTERS = CHAT_MAX_BYTES - IC.Keywords.Default.BYTE_COUNT

local editWindow = {
		MARGIN = 10,
		ID = 'ic.edit',
		open = false
	}

local function HasContentChanges()
	local description = editWindow.descriptionDropDown:GetSelectedItemData().description
	local dropDownEntry = editWindow.outfitDropDown:GetSelectedItemData()
	if dropDownEntry ~= nil and description.outfitIndex ~= dropDownEntry.outfitIndex then
		return true
	end
	
	local text = description.text
	if text == nil then
		text = ''
	end
	if editWindow.text:GetText() ~= text then
		return true
	end

	return false
end

local function IsFittingChat(message)
	return message:len() + IC.Keywords.Default.BYTE_COUNT <= CHAT_MAX_BYTES
end

function IC.EditWindow.SetWidth(width)
	IC.CharacterWide.GetEditWindow().width = width
	editWindow.window:SetWidth(width)
	
	local childWidth = width - 2 * editWindow.MARGIN
	editWindow.title:SetWidth(childWidth)
	editWindow.descriptionControl:SetWidth(childWidth)
	editWindow.divider:SetWidth(childWidth)
	editWindow.outfitControl:SetWidth(childWidth)
	editWindow.buttonControl:SetWidth(childWidth)
	editWindow.textBackdrop:SetWidth(childWidth)
	
	local buttonWidth = childWidth / 3
	editWindow.saveButton:SetWidth(buttonWidth)
	editWindow.copyButton:SetWidth(buttonWidth)
	editWindow.resetButton:SetWidth(buttonWidth)
end

function IC.EditWindow.GetWidth()
	return IC.CharacterWide.GetEditWindow().width
end

function IC.EditWindow.SetHeight(height)
	IC.CharacterWide.GetEditWindow().height = height
	editWindow.window:SetHeight(height)
end

function IC.EditWindow.GetHeight()
	return IC.CharacterWide.GetEditWindow().height
end

function IC.EditWindow.UpdateTitle()
	local hints = ''
	if HasContentChanges() then
		hints = hints..GetString(SI_INCHARACTER_UI_EDIT_WINDOW_TITLE_UNSAVED)
	end
	if not IsFittingChat(editWindow.text:GetText()) then
		hints = hints..GetString(SI_INCHARACTER_UI_EDIT_WINDOW_TITLE_TOO_LONG)
	end
	editWindow.title:SetText(zo_strformat(GetString(SI_INCHARACTER_UI_EDIT_WINDOW_TITLE), hints))
end

function IC.EditWindow.ChangeOutfitDropDownEntryName(outfitIndex, newName)
	local dropDown = editWindow.outfitDropDown
	local entries = dropDown:GetItems()
	for void, entry in pairs(entries) do
		if entry.outfitIndex == outfitIndex then
			entry.name = newName
			if entry == dropDown:GetSelectedItemData() then
				dropDown:SelectItem(entry, true) -- true: do not trigger callback
			end
			break
		end
	end
end

local function OnOutfitEntrySelected(control, text, entry)
	IC.EditWindow.UpdateTitle()
end

local function FillOutfitDropDownFiltered(currentOutfitIndex)
	local dropDown = editWindow.outfitDropDown
	
	function CreateDropDownEntry(text, outfitIndex)
		-- only this or any free outfit slot
		if currentOutfitIndex == outfitIndex or not IC.CharacterWide.IsOutfitIndexAssigned(outfitIndex) then
			local entry = dropDown:CreateItemEntry(text, OnOutfitEntrySelected)
			entry.outfitIndex = outfitIndex
			dropDown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
		end
	end

	dropDown:ClearItems()
	CreateDropDownEntry(GetString(SI_INCHARACTER_UI_EDIT_WINDOW_OUTFIT_NOT_ASSIGNED), nil) -- no slot selected
	CreateDropDownEntry(GetString(SI_INCHARACTER_UI_EDIT_WINDOW_OUTFIT_SLOT_NO_OUTFIT), 0) -- 'No Outfit' slot
	-- add all real outfit slots, filtered
	for index = 1, GetNumUnlockedOutfits() do
		local name = GetOutfitName(index)
		if name == nil or name == '' then
			name = zo_strformat(GetString(SI_OUTFIT_NO_NICKNAME_FORMAT), index)
		end
		CreateDropDownEntry(name, index)
	end
	dropDown:UpdateItems()
end

local function SelectOutfitDropDownEntry(outfitIndex, triggerCallback)
	local dropDown = editWindow.outfitDropDown
	local entries = dropDown:GetItems()
	for void, entry in pairs(entries) do
		if entry.outfitIndex == outfitIndex then
			dropDown:SelectItem(entry, not triggerCallback)
			break
		end
	end
end

local function OnKeyNumberEntrySelected(control, text, entry)
	editWindow.descriptionDropDown:GetSelectedItemData().description.keyNumber = entry.keyNumber
end

local function FillKeyNumberDropDownFiltered(currentKeyNumber)
	local dropDown = editWindow.keyNumberDropDown
	
	function CreateDropDownEntry(text, keyNumber)
		-- only this or any free key number
		if currentKeyNumber == keyNumber or not IC.CharacterWide.IsKeyNumberAssigned(keyNumber) then
			local entry = dropDown:CreateItemEntry(text, OnKeyNumberEntrySelected)
			entry.keyNumber = keyNumber
			dropDown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
		end
	end

	dropDown:ClearItems()
	CreateDropDownEntry(GetString(SI_INCHARACTER_UI_EDIT_WINDOW_NO_KEY_SLOT), nil) -- no key selected
	-- add all key numbers, filtered
	for index = 0, 9 do
		CreateDropDownEntry(zo_strformat(GetString(SI_INCHARACTER_UI_EDIT_WINDOW_KEY_SLOT), index + 1), index)
	end
	dropDown:UpdateItems()
end

local function SelectKeyNumberDropDownEntry(keyNumber, triggerCallback)
	local dropDown = editWindow.keyNumberDropDown
	local entries = dropDown:GetItems()
	for void, entry in pairs(entries) do
		if entry.keyNumber == keyNumber then
			dropDown:SelectItem(entry, not triggerCallback)
			break
		end
	end
end

function IC.EditWindow.UpdateVisibility()
	editWindow.window:SetHidden(IC.UI.menuVisible or not editWindow.open)
end

local function SaveContents()
	local description = editWindow.descriptionDropDown:GetSelectedItemData().description;
	description.outfitIndex = editWindow.outfitDropDown:GetSelectedItemData().outfitIndex
	description.text = editWindow.text:GetText()
	IC.EditWindow.UpdateTitle()
end

local function SaveAndCopyTextToChat()
	SaveContents()
	IC.EditWindow.Close()
	IC.CharacterWide.WriteToChatInput(editWindow.descriptionDropDown:GetSelectedItemData().description)
end

local function ResetContents()
	local description = editWindow.descriptionDropDown:GetSelectedItemData().description
	editWindow.descriptionEditControl:SetHidden(true)
	FillOutfitDropDownFiltered(description.outfitIndex)
	SelectOutfitDropDownEntry(description.outfitIndex, false)
	local text = description.text
	if text == nil then
		text = ''
	end
	editWindow.text:SetText(text)
end

local function UpdateContents()
	if not HasContentChanges() then
		ResetContents()
	end
end

local function ChangeDescriptionDropDownEntryName(entry, newName)
	local dropDown = editWindow.descriptionDropDown
	local description = IC.CharacterWide.MoveDescription(entry.name, newName)
	description.name = newName
	entry.name = newName
	entry.description = description
	if entry == dropDown:GetSelectedItemData() then
		dropDown:SelectItem(entry, true) -- true: do not trigger callback
	end
	dropDown:UpdateItems()
end

function IC.EditWindow.SelectDescriptionDropDownEntry(name, triggerCallback)
	local dropDown = editWindow.descriptionDropDown
	local entries = dropDown:GetItems()
	for void, entry in pairs(entries) do
		if entry.name == name then
			dropDown:SelectItem(entry, not triggerCallback)
			break
		end
	end
end

local function OnDescriptionEntrySelected(control, text, entry)
	IC.CharacterWide.SetCurrentDescriptionKey(text)
	ResetContents()
end

local function FillDescriptionDropDown()
	local dropDown = editWindow.descriptionDropDown
	dropDown:ClearItems()
	local descriptions = IC.CharacterWide.GetDescriptions()
	for void, description in pairs(descriptions) do
		local entry = dropDown:CreateItemEntry(description.name, OnDescriptionEntrySelected)
		entry.description = description
		dropDown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
	end
	dropDown:UpdateItems()
end

function IC.EditWindow.OpenAndFocus()
	editWindow.open = true
	IC.EditWindow.UpdateVisibility()
	UpdateContents()
	if not editWindow.window:IsHidden() then
		editWindow.text:TakeFocus()
		SetGameCameraUIMode(true)
	end
end

function IC.EditWindow.Close()
	editWindow.open = false
	IC.EditWindow.UpdateVisibility()
end

function IC.EditWindow.IsOpen()
	return editWindow.open
end

local function OnWindowMoveStop(window)
	local savedEditWindow = IC.CharacterWide.GetEditWindow()
	savedEditWindow.left = window:GetLeft()
	savedEditWindow.top = window:GetTop()
end

function IC.EditWindow.Create()
	local savedEditWindow = IC.CharacterWide.GetEditWindow()
	local MARGIN = editWindow.MARGIN
	local DefaultDescriptionControlHeight = 30
	local windowWidth = savedEditWindow.width
	local windowHeight = savedEditWindow.height
	local childWidth = windowWidth - 2 * MARGIN
	local buttonWidth = childWidth / 3

	local window = WINDOW_MANAGER:CreateTopLevelWindow(editWindow.ID..'.window')
	window:SetHidden(true)
	window:SetResizeToFitDescendents(true)
	if savedEditWindow.left == nil or savedEditWindow.top == nil then
		window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	else
		window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedEditWindow.left, savedEditWindow.top)
	end
	window:SetClampedToScreen(true)
	window:SetMovable(true)
	window:SetMouseEnabled(true)
	window:SetDimensions(windowWidth, windowHeight)
	window:SetHandler('OnMoveStop', OnWindowMoveStop)
	editWindow.window = window
	
	local closeButton = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.closeButton', window, 'ZO_CloseButton')
	closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -MARGIN, MARGIN)
	closeButton:SetHandler('OnClicked', IC.EditWindow.Close)
	
	local backdrop = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.backdrop', window, 'ZO_DefaultBackdrop')
	backdrop:SetAnchorFill(window)
	
	local title = WINDOW_MANAGER:CreateControl(editWindow.ID..'.title', window, CT_LABEL)
	title:SetAnchor(TOP, window, TOP, 0, MARGIN)
	title:SetWidth(childWidth)
	title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	title:SetFont('ZoFontWinH3')
	title:SetText(GetString(SI_INCHARACTER_UI_EDIT_WINDOW_TITLE))
	editWindow.title = title
	
	local descriptionControl = WINDOW_MANAGER:CreateControl(editWindow.ID..'.description', window, CT_CONTROL)
	descriptionControl:SetAnchor(TOP, title, BOTTOM, 0, MARGIN)
	descriptionControl:SetDimensions(childWidth, DefaultDescriptionControlHeight)
	editWindow.descriptionControl = descriptionControl

	local descriptionEditControl = WINDOW_MANAGER:CreateControl(editWindow.ID..'.descriptionEdit', descriptionControl, CT_CONTROL)
	descriptionEditControl:SetAnchor(TOP, descriptionControl, CENTER, 0, 0)
	descriptionEditControl:SetAnchor(BOTTOM, descriptionControl, BOTTOM, 0, 0)
	descriptionEditControl:SetWidth(descriptionControl:GetWidth())
	descriptionEditControl:SetHidden(true)
	editWindow.descriptionEditControl = descriptionEditControl
	
	local descriptionButtonControl = WINDOW_MANAGER:CreateControl(editWindow.ID..'.descriptionButtons', descriptionEditControl, CT_CONTROL)
	descriptionButtonControl:SetAnchorFill(descriptionEditControl)
	
	function CreateEditControl(labelText, id, parent, createTextInput)
		local container = {}
		
		local control = WINDOW_MANAGER:CreateControl(editWindow.ID..'.'..id..'Control', parent, CT_CONTROL)
		control:SetAnchorFill(parent)
		container.control = control
		
		local label = WINDOW_MANAGER:CreateControl(editWindow.ID..'.'..id..'Label', control, CT_LABEL)
		label:SetAnchor(LEFT, control, LEFT, 0, 0)
		label:SetHeight(control:GetHeight())
		label:SetFont('ZoFontGame')
		label:SetText(labelText)
		
		local cancelButton = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.'..id..'CancelButton', control, 'SavingEditBoxCancelButton')
		cancelButton:SetAnchor(RIGHT, control, RIGHT, 0, 0)
		cancelButton:SetHandler('OnClicked', function()
			descriptionButtonControl:SetHidden(false)
			control:SetHidden(true)
		end)
		
		local acceptButton = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.'..id..'AcceptButton', control, 'SavingEditBoxSaveButton')
		acceptButton:SetAnchor(RIGHT, cancelButton, LEFT, 0, 0)
		container.acceptButton = acceptButton
	
		if createTextInput then
			local backdrop = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.'..id..'Backdrop', control, 'ZO_EditBackdrop')
			backdrop:SetAnchor(LEFT, label, RIGHT, MARGIN, 0)
			backdrop:SetAnchor(RIGHT, acceptButton, LEFT, 0, 0)
			backdrop:GetHeight(control:GetHeight())
	
			local input = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.'..id..'Input', control, 'ZO_DefaultEditForBackdrop')
			input:SetAnchorFill(backdrop)
			input:SetFont('ZoFontGame')
			input:SetText('')
			input:SetMaxInputChars(30)
			input:SetNewLineEnabled(false)
			input:SetMultiLine(false)
			input:SetCopyEnabled(true)
			input:SetPasteEnabled(true)
			container.input = input
			
			control:SetHandler('OnEffectivelyShown', function() input:TakeFocus() end)
			control:SetHandler('OnEffectivelyHidden', function() input:SetText('') end)
		end
		
		return container
	end
	
	local addContainer = CreateEditControl(GetString(SI_INCHARACTER_UI_EDIT_WINDOW_LABEL_ADD), 'add', descriptionEditControl, true)
	addContainer.acceptButton:SetHandler('OnClicked', function()
		local name = addContainer.input:GetText()
		if IC.CharacterWide.FindDescriptionByKey(name) == nil then
			local description = IC.CharacterWide.AcquireDescriptions(name)
			IC.CharacterWide.InitializeDescription(description, name)
			FillDescriptionDropDown()
			IC.EditWindow.SelectDescriptionDropDownEntry(name, true)
			descriptionEditControl:SetHidden(true)
		end
	end)
	addContainer.input:SetHandler('OnTextChanged', function() addContainer.acceptButton:SetEnabled(not IC.CharacterWide.HasDescription(addContainer.input:GetText())) end)
	
	local deleteContainer = CreateEditControl(GetString(SI_INCHARACTER_UI_EDIT_WINDOW_LABEL_DELETE), 'delete', descriptionEditControl, false)	
	local renameContainer = CreateEditControl(GetString(SI_INCHARACTER_UI_EDIT_WINDOW_LABEL_RENAME), 'rename', descriptionEditControl, true)
	
	descriptionEditControl:SetHandler('OnEffectivelyShown', function()
		descriptionControl:SetHeight(DefaultDescriptionControlHeight * 2)
		descriptionButtonControl:SetHidden(false)
		addContainer.control:SetHidden(true)
		deleteContainer.control:SetHidden(true)
		renameContainer.control:SetHidden(true)
	end)
	
	descriptionEditControl:SetHandler('OnEffectivelyHidden', function()
		descriptionControl:SetHeight(DefaultDescriptionControlHeight)
		descriptionButtonControl:SetHidden(true)
		addContainer.control:SetHidden(true)
		deleteContainer.control:SetHidden(true)
		renameContainer.control:SetHidden(true)
	end)
	
	local descriptionEditButton = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.descriptionEditButton', descriptionControl, 'SavingEditBoxModifyButton')
	descriptionEditButton:SetAnchor(TOPRIGHT, descriptionControl, TOPRIGHT, 0, 0)
	descriptionEditButton:SetHandler('OnClicked', function()
		descriptionEditControl:SetHidden(not descriptionEditControl:IsHidden())
	end)
	
	local descriptionComboBox = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.descriptionComboBox', descriptionControl, 'ZO_ComboBox')
	descriptionComboBox:SetAnchor(TOPLEFT, descriptionControl, TOPLEFT, 0, 0)
	descriptionComboBox:SetAnchor(RIGHT, descriptionEditButton, LEFT, 0, 0)
	descriptionComboBox:SetHeight(descriptionControl:GetHeight())
	local descriptionDropDown = ZO_ComboBox_ObjectFromContainer(descriptionComboBox)
	descriptionDropDown:SetSortOrder(ZO_SORT_ORDER_UP, ZO_SORT_BY_NAME)
	descriptionDropDown:SetSortsItems(true)
	editWindow.descriptionDropDown = descriptionDropDown
	
	deleteContainer.acceptButton:SetHandler('OnClicked', function()
		local entry = descriptionDropDown:GetSelectedItemData()
		IC.CharacterWide.DeleteDescription(entry.name)
		FillDescriptionDropDown()
		descriptionDropDown:SelectFirstItem()
		descriptionEditControl:SetHidden(true)
	end)
	
	renameContainer.acceptButton:SetHandler('OnClicked', function()
		local name = renameContainer.input:GetText()
		if name == descriptionDropDown:GetSelectedItemData().name then
			descriptionEditControl:SetHidden(true)
		elseif IC.CharacterWide.FindDescriptionByKey(name) == nil then
			ChangeDescriptionDropDownEntryName(descriptionDropDown:GetSelectedItemData(), name)
			IC.CharacterWide.SetCurrentDescriptionKey(name)
			descriptionEditControl:SetHidden(true)
		end
	end)
	renameContainer.input:SetHandler('OnTextChanged', function() renameContainer.acceptButton:SetEnabled(not IC.CharacterWide.HasDescription(renameContainer.input:GetText())) end)
	
	local descriptionButtonWidth = descriptionButtonControl:GetWidth() / 4
	
	local addButton = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.addButton', descriptionButtonControl, 'ZO_DefaultButton')
	addButton:SetAnchor(BOTTOMLEFT, descriptionButtonControl, BOTTOMLEFT, 0, 0)
	addButton:SetWidth(descriptionButtonWidth)
	addButton:SetText(GetString(SI_INCHARACTER_UI_EDIT_WINDOW_BUTTON_ADD))
	addButton:SetHandler('OnClicked', function()
		descriptionButtonControl:SetHidden(true)
		addContainer.control:SetHidden(false)
	end)
	
	local deleteButton = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.deleteButton', descriptionButtonControl, 'ZO_DefaultButton')
	deleteButton:SetAnchor(BOTTOMRIGHT, descriptionButtonControl, BOTTOM, 0, 0)
	deleteButton:SetWidth(descriptionButtonWidth)
	deleteButton:SetText(GetString(SI_INCHARACTER_UI_EDIT_WINDOW_BUTTON_DELETE))
	deleteButton:SetHandler('OnClicked', function()
		descriptionButtonControl:SetHidden(true)
		deleteContainer.control:SetHidden(false)
	end)
	
	descriptionButtonControl:SetHandler('OnEffectivelyShown', function()
		local descriptionsCount = IC.CharacterWide.GetDescriptionCount()
		addButton:SetEnabled(descriptionsCount <= 10)
		deleteButton:SetEnabled(descriptionsCount > 1)
		local keyNumber = descriptionDropDown:GetSelectedItemData().description.keyNumber
		FillKeyNumberDropDownFiltered(keyNumber)
		SelectKeyNumberDropDownEntry(keyNumber, false)
	end)
	
	local renameButton = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.renameButton', descriptionButtonControl, 'ZO_DefaultButton')
	renameButton:SetAnchor(BOTTOMLEFT, descriptionButtonControl, BOTTOM, 0, 0)
	renameButton:SetWidth(descriptionButtonWidth)
	renameButton:SetText(GetString(SI_INCHARACTER_UI_EDIT_WINDOW_BUTTON_RENAME))
	renameButton:SetHandler('OnClicked', function()
		descriptionButtonControl:SetHidden(true)
		renameContainer.input:SetText(descriptionDropDown:GetSelectedItemData().name)
		renameContainer.control:SetHidden(false)
	end)
	
	local keyNumberComboBox = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.keyNumberComboBox', descriptionButtonControl, 'ZO_ComboBox')
	keyNumberComboBox:SetAnchor(BOTTOMRIGHT, descriptionButtonControl, BOTTOMRIGHT, 0, 0)
	keyNumberComboBox:SetWidth(descriptionButtonWidth)
	local keyNumberDropDown = ZO_ComboBox_ObjectFromContainer(keyNumberComboBox)
	keyNumberDropDown:SetSortsItems(false)
	editWindow.keyNumberDropDown = keyNumberDropDown
	
	local divider = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.divider', descriptionControl, 'ZO_DynamicHorizontalDivider')
	divider:SetAnchor(TOP, descriptionControl, BOTTOM, 0, MARGIN)
	divider:SetDimensions(childWidth, 5)
	editWindow.divider = divider
	
	local outfitControl = WINDOW_MANAGER:CreateControl(editWindow.ID..'.outfit', window, CT_CONTROL)
	outfitControl:SetAnchor(TOP, divider, BOTTOM, 0, MARGIN)
	outfitControl:SetDimensions(childWidth, 30)
	editWindow.outfitControl = outfitControl
	
	local outfitLabel = WINDOW_MANAGER:CreateControl(editWindow.ID..'.outfitLabel', outfitControl, CT_LABEL)
	outfitLabel:SetAnchor(LEFT, outfitControl, LEFT, 0, 0)
	outfitLabel:SetFont('ZoFontGame')
	outfitLabel:SetText(GetString(SI_INCHARACTER_UI_EDIT_WINDOW_OUTFIT_LABEL))
	
	local outfitComboBox = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.outfitComboBox', outfitControl, 'ZO_ComboBox')
	outfitComboBox:SetAnchor(LEFT, outfitLabel, RIGHT, MARGIN, 0)
	outfitComboBox:SetAnchor(RIGHT, outfitControl, RIGHT, 0, 0)
	local outfitDropDown = ZO_ComboBox_ObjectFromContainer(outfitComboBox)
	outfitDropDown:SetSortsItems(false)
	editWindow.outfitDropDown = outfitDropDown
	
	local buttonControl = WINDOW_MANAGER:CreateControl(editWindow.ID..'.buttons', window, CT_CONTROL)
	buttonControl:SetAnchor(BOTTOM, window, BOTTOM, 0, -MARGIN)
	buttonControl:SetDimensions(childWidth, 30)
	editWindow.buttonControl = buttonControl
	
	local saveButton = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.saveButton', buttonControl, 'ZO_DefaultButton')
	saveButton:SetAnchor(CENTER, buttonControl, CENTER, 0, 0)
	saveButton:SetDimensions(buttonWidth, buttonControl:GetHeight())
	saveButton:SetText(GetString(SI_INCHARACTER_UI_EDIT_WINDOW_BUTTON_SAVE))
	saveButton:SetHandler('OnClicked', SaveContents)
	editWindow.saveButton = saveButton
	
	local copyButton = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.copyButton', buttonControl, 'ZO_DefaultButton')
	copyButton:SetAnchor(LEFT, buttonControl, LEFT, 0, 0)
	copyButton:SetDimensions(buttonWidth, buttonControl:GetHeight())
	copyButton:SetText(GetString(SI_INCHARACTER_UI_EDIT_WINDOW_BUTTON_SAVE_AND_COPY))
	copyButton:SetHandler('OnClicked', SaveAndCopyTextToChat)
	editWindow.copyButton = copyButton
	
	local resetButton = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.resetButton', buttonControl, 'ZO_DefaultButton')
	resetButton:SetAnchor(RIGHT, buttonControl, RIGHT, 0, 0)
	resetButton:SetDimensions(buttonWidth, buttonControl:GetHeight())
	resetButton:SetText(GetString(SI_INCHARACTER_UI_EDIT_WINDOW_BUTTON_RESET))
	resetButton:SetHandler('OnClicked', ResetContents)
	editWindow.resetButton = resetButton
	
	local textBackdrop = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.textBackdrop', window, 'ZO_MultiLineEditBackdrop_Keyboard')
	textBackdrop:SetAnchor(TOP, outfitControl, BOTTOM, 0, MARGIN / 2)
	textBackdrop:SetAnchor(BOTTOM, buttonControl, TOP, 0, -MARGIN)
	textBackdrop:SetWidth(childWidth)
	editWindow.textBackdrop = textBackdrop

	local text = WINDOW_MANAGER:CreateControlFromVirtual(editWindow.ID..'.text', textBackdrop, 'ZO_DefaultEditForBackdrop')
	text:SetAnchorFill(textBackdrop)
	text:SetFont('ZoFontChat')
	text:SetText('')
	text:SetMaxInputChars(MAX_CHARACTERS)
	text:SetNewLineEnabled(false)
	text:SetMultiLine(true)
	text:SetCopyEnabled(true)
	text:SetPasteEnabled(true)
	text:SetHandler('OnTextChanged', IC.EditWindow.UpdateTitle)
	editWindow.text = text
	
	FillDescriptionDropDown()
	IC.EditWindow.SelectDescriptionDropDownEntry(IC.CharacterWide.GetCurrentDescriptionKey(), true)
	
	ResetContents()
end