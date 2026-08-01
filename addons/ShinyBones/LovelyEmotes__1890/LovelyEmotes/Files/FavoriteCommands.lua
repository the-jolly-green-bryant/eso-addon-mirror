LE_FavoriteCommandsMenu = ZO_Object:New()

local _selectedData

local function RemoveEmptyData()
	local dataList = LovelyEmotes_Settings.SavedAccountVariables.FavoriteCommandsData

	for i = #dataList, 1, -1 do
		if dataList[i].Command == nil then
			table.remove(dataList, i)
		end
	end
end

local function UpdateListControl(menu, control, data)
	local buttonControl = control:GetNamedChild("CommandButton")
	local entry = data.Entry
	local savedAccountVariables = LovelyEmotes_Settings.SavedAccountVariables

	if entry.Command == nil then
		buttonControl:SetText(data.Index .. ": ---")
	else
		local displayName

		if entry.DisplayName == nil then
			displayName = entry.Command
		else
			if savedAccountVariables.ShowSlashNames == true and savedAccountVariables.FavoriteCommandsShowDisplayName == false then
				displayName = entry.Command
			else
				displayName = entry.DisplayName
			end
		end

		buttonControl:SetText(zo_strformat("<<1>>: <<2>>", data.Index, displayName))
	end

	buttonControl:SetHandler("OnClicked", function(control, button) menu:SelectData(data) end)
	control:GetNamedChild("DeleteButton"):SetHandler("OnClicked", function(control, button) menu:RemoveData(data.Index) end)
end

local function UpdateForceDisplayNameCheckbox(button)
	if LovelyEmotes_Settings.SavedAccountVariables.FavoriteCommandsShowDisplayName then
		button:SetNormalTexture("esoui/art/buttons/checkbox_checked.dds")
		button:SetDisabledTexture("esoui/art/buttons/checkbox_checked_disabled.dds")
		return
	end

	button:SetNormalTexture("esoui/art/buttons/checkbox_unchecked.dds")
	button:SetDisabledTexture("esoui/art/buttons/checkbox_disabled.dds")
end

function LE_FavoriteCommandsMenu:Initialize()
	RemoveEmptyData()

	self.MenuControl = LE_FavoriteCommandsWindow
	self.Fragment = ZO_HUDFadeSceneFragment:New(self.MenuControl, DEFAULT_SCENE_TRANSITION_TIME, DEFAULT_SCENE_TRANSITION_TIME)
	self.IsActive = false

	local listBoxControl = self.MenuControl:GetNamedChild("ListBox")
	self.ListControl = listBoxControl:GetNamedChild("List")
	ZO_ScrollList_AddDataType(self.ListControl, 1, "LE_FavoriteCommandTemplate", 25, function(control, data) UpdateListControl(self, control, data) end)

	self.AddButton = listBoxControl:GetNamedChild("AddButton")
	self.AddButton:SetHandler("OnClicked", function(control, button) self:AddData() end)

	self.ForceDisplayNameButton = listBoxControl:GetNamedChild("ForceDisplayNameCheckboxButton")
	self.ForceDisplayNameButton:SetHandler("OnClicked", function(control, button) self:ToggleForceDisplayName() end)
	UpdateForceDisplayNameCheckbox(self.ForceDisplayNameButton)

	self.MenuControl:GetNamedChild("CommandLabel"):SetText(GetString(SI_LOVELYEMOTES_FAVORITECOMMANDS_COMMAND))
	self.MenuControl:GetNamedChild("DisplayNameLabel"):SetText(GetString(SI_LOVELYEMOTES_FAVORITECOMMANDS_DISPLAY_NAME))
	listBoxControl:GetNamedChild("ForceDisplayNameLabel"):SetText(GetString(SI_LOVELYEMOTES_FAVORITECOMMANDS_FORCE_DISPLAY_NAME))

	self.SlotIndexLabel = self.MenuControl:GetNamedChild("SlotIndexLabel")
	self.CommandEditBox = self.MenuControl:GetNamedChild("CommandEditBox"):GetNamedChild("Edit")

	local displayNameEditBoxParent = self.MenuControl:GetNamedChild("DisplayNameEditBox")
	self.DisplayNameOptionalLabel = displayNameEditBoxParent:GetNamedChild("OptionalLabel")
	self.DisplayNameOptionalLabel:SetText(GetString(SI_LOVELYEMOTES_FAVORITECOMMANDS_OPTIONAL))
	self.DisplayNameEditBox = displayNameEditBoxParent:GetNamedChild("Edit")

	self.MenuControl:GetNamedChild("CloseButton"):SetHandler("OnClicked", function(control, button) self:Close() end)

	self.CommandEditBox:SetHandler("OnFocusLost", function()
		local command = self.CommandEditBox:GetText()
		if command == _selectedData.Entry.Command then return end

		if command == nil or command == "" then
			self:SelectData(_selectedData)
			return
		end

		local commandString, argumentString = command:match("(%S+)(.*)")
		command = string.lower(commandString) .. argumentString

		local firstCharacter = string.sub(command, 1, 1)
		if firstCharacter ~= "/" then
			command = "/" .. command
		end

		self.CommandEditBox:SetText(command)
		_selectedData.Entry.Command = command

		ZO_ScrollList_RefreshVisible(self.ListControl)
	end)

	self.DisplayNameEditBox:SetHandler("OnFocusGained", function()
		PlaySound("Click_Edit")
		self.DisplayNameOptionalLabel:SetHidden(true)
	end)

	self.DisplayNameEditBox:SetHandler("OnFocusLost", function()
		local displayName = self.DisplayNameEditBox:GetText()

		if displayName == nil or displayName == "" then
			_selectedData.Entry.DisplayName = nil
			self.DisplayNameOptionalLabel:SetHidden(false)
		else
			if displayName == _selectedData.Entry.DisplayName then return end
			_selectedData.Entry.DisplayName = displayName
		end

		ZO_ScrollList_RefreshVisible(self.ListControl)
	end)
end

function LE_FavoriteCommandsMenu:BuildList()
	ZO_ScrollList_Clear(self.ListControl)
	ZO_ScrollList_AddCategory(self.ListControl, 1)
	local dataList = ZO_ScrollList_GetDataList(self.ListControl)

	local savedDataList = LovelyEmotes_Settings.SavedAccountVariables.FavoriteCommandsData
	local dataCount = #savedDataList

	for i = 1, dataCount do
		local data = {
			Index = i,
			Entry = savedDataList[i],
		}

		table.insert(dataList, ZO_ScrollList_CreateDataEntry(1, data, 1))
	end

	ZO_ScrollList_Commit(self.ListControl, dataList)
	self.AddButton:SetEnabled(dataCount < 100)

	return dataCount
end

function LE_FavoriteCommandsMenu:AddData()
	self:SelectData(nil)
	table.insert(LovelyEmotes_Settings.SavedAccountVariables.FavoriteCommandsData, {})
	ZO_ScrollList_ScrollDataIntoView(self.ListControl, self:BuildList())
end

function LE_FavoriteCommandsMenu:RemoveData(index)
	table.remove(LovelyEmotes_Settings.SavedAccountVariables.FavoriteCommandsData, index)
	self:BuildList()
	self:SelectData(nil)
end

function LE_FavoriteCommandsMenu:TryRefreshList()
	if self.IsActive == false then return end
	ZO_ScrollList_RefreshVisible(self.ListControl)
end

function LE_FavoriteCommandsMenu:SelectData(data)
	_selectedData = data

	if data == nil then
		self.SlotIndexLabel:SetText(GetString(SI_LOVELYEMOTES_FAVORITECOMMANDS_SELECTED_SLOT_EMPTY))

		self.CommandEditBox:SetText(nil)
		self.DisplayNameEditBox:SetText(nil)

		self.CommandEditBox:SetHidden(true)
		self.DisplayNameEditBox:SetHidden(true)
		self.DisplayNameOptionalLabel:SetHidden(false)

		return
	end

	self.SlotIndexLabel:SetText(GetString(SI_LOVELYEMOTES_FAVORITECOMMANDS_SELECTED_SLOT) .. data.Index)
	self.CommandEditBox:SetHidden(false)
	self.DisplayNameEditBox:SetHidden(false)

	local entry = data.Entry

	self.CommandEditBox:SetText(entry.Command)
	if entry.Command == nil then
		self.CommandEditBox:TakeFocus()
	end

	self.DisplayNameEditBox:SetText(entry.DisplayName)
	self.DisplayNameOptionalLabel:SetHidden(entry.DisplayName ~= nil)
end

function LE_FavoriteCommandsMenu:Open()
	if LE_Invisible:IsHidden() or self.IsActive == true then return end
	self.IsActive = true

	LovelyEmotes.PlayWindowOpenSound()
    self:BuildList()
    self:SelectData(nil)

	self.Fragment:Show()
	HUD_SCENE:AddFragment(self.Fragment)
	HUD_UI_SCENE:AddFragment(self.Fragment)

	if SCENE_MANAGER:IsInUIMode() then return end
	SCENE_MANAGER:OnToggleHUDUIBinding()
end

function LE_FavoriteCommandsMenu:Close()
	if self.IsActive == false then return end
	self.IsActive = false

	_selectedData = nil
	RemoveEmptyData()

	LovelyEmotes.PlayWindowCloseSound()
	LovelyEmotes.ReinitializeAvailableEmotes()

	self.Fragment:Hide()
	HUD_SCENE:RemoveFragment(self.Fragment)
	HUD_UI_SCENE:RemoveFragment(self.Fragment)
end

function LE_FavoriteCommandsMenu:ToggleForceDisplayName()
	local savedAccountVariables = LovelyEmotes_Settings.SavedAccountVariables
	savedAccountVariables.FavoriteCommandsShowDisplayName = not savedAccountVariables.FavoriteCommandsShowDisplayName

	UpdateForceDisplayNameCheckbox(self.ForceDisplayNameButton)
	ZO_ScrollList_RefreshVisible(self.ListControl)
end
