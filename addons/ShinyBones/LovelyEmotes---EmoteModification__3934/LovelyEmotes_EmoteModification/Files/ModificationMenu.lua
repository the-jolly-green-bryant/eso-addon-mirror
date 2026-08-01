LE_EmoteDataModMenu = ZO_Object:New()

local _availableEmotesIdDict
local _emoteList

local _tempEmoteDataEntries
local _selectedEmoteId

local function CreateAvailableEmotes()
	local numEmotes = GetNumEmotes()
	_availableEmotesIdDict = {}

	for i = 1, numEmotes do
		local slashName, categoryId, id, displayName = GetEmoteInfo(i)

		_availableEmotesIdDict[id] = {
			SlashName = slashName,
			ID = id,
			CategoryID = categoryId,
			TagString = string.lower(zo_strformat("<<1>> <<2>>", slashName, displayName)),
		}
	end
end

local function ShowAddPopup(self)
	local savedEntries = LovelyEmotes_EmoteDataMod.SavedAccountVariables.EmoteDataEntries
	local selectableEmotes = {}

	for id, emote in pairs(_availableEmotesIdDict) do
		if savedEntries[id] == nil then
			table.insert(selectableEmotes, emote)
		end
	end

	table.sort(selectableEmotes, function(firstValue, secondValue) return firstValue.SlashName < secondValue.SlashName end)

	if _emoteList == nil then
		_emoteList = LovelyEmotes_EmoteList_CreateNew("LE_EmoteModificationEmoteList")
		_emoteList.GetEntryNameFunc = function(emote) return zo_strformat("<<1>> (<<2>>)", emote.SlashName, emote.ID) end
		_emoteList:SetParent(self.AddOverlay:GetNamedChild("Box"), 0, function(button, data)
			self:AddEntry(data.ID)
			self.AddOverlay:SetHidden(true)
		end)
	end

	_emoteList.GetAvailableEmotesFunc = function() return selectableEmotes end

	_emoteList:ResetList()
	self.AddOverlay:SetHidden(false)
end

local function OnReplaceNameOnEditFocusLost(self)
	local cVarString = GetCVar("language.2")
	local displayName = self.ReplaceNameEdit:GetText()
	local entry = _tempEmoteDataEntries[_selectedEmoteId]

	if displayName == nil or displayName == "" then
		if entry.ReplaceName ~= nil then
			entry.ReplaceName[cVarString] = nil

			if LovelyEmotes_EmoteDataMod.IsTableEmpty(entry.ReplaceName) then
				entry.ReplaceName = nil
			end
		end
	else
		if entry.ReplaceName == nil then
			entry.ReplaceName = {}
		end

		entry.ReplaceName[cVarString] = displayName
	end
end

local function OnCleanButtonClicked(self)
	for id, entry in pairs(_tempEmoteDataEntries) do
		if LovelyEmotes_EmoteDataMod.IsTableEmpty(entry) == true or _availableEmotesIdDict[id] == nil then
			_tempEmoteDataEntries[id] = nil
		end
	end

	self:BuildEntryList()
	self:SelectEntry()
end

function LE_EmoteDataModMenu:AddEntry(emoteId)
	if _tempEmoteDataEntries[emoteId] ~= nil then return end
	_tempEmoteDataEntries[emoteId] = {}

	self:BuildEntryList()
	self:SelectEntry(emoteId)
end

function LE_EmoteDataModMenu:RemoveEntry(emoteId)
	_tempEmoteDataEntries[emoteId] = nil

	self:BuildEntryList()
	self:SelectEntry()
end

local function UpdateEntryListControl(menu, control, data)
	local buttonControl = control:GetNamedChild("CommandButton")

	buttonControl:SetText(zo_strformat(zo_strformat("<<1>> - <<2>>", data.EmoteID, data.SlashName)))

	buttonControl:SetHandler("OnClicked", function(control, button) menu:SelectEntry(data.EmoteID) end)
	control:GetNamedChild("DeleteButton"):SetHandler("OnClicked", function(control, button) menu:RemoveEntry(data.EmoteID) end)
end

function LE_EmoteDataModMenu:Initialize()
	self.MenuControl = LE_EmoteDataModWindow
	self.Fragment = ZO_HUDFadeSceneFragment:New(self.MenuControl, DEFAULT_SCENE_TRANSITION_TIME, DEFAULT_SCENE_TRANSITION_TIME)

	local listBoxControl = self.MenuControl:GetNamedChild("ListBox")
	self.ListControl = listBoxControl:GetNamedChild("List")
	ZO_ScrollList_AddDataType(self.ListControl, 1, "LE_FavoriteCommandTemplate", 25, function(control, data) UpdateEntryListControl(self, control, data) end)

	local addButton = listBoxControl:GetNamedChild("AddButton")
	addButton:SetHandler("OnClicked", function(control, button) ShowAddPopup(self) end)

	local cleanButton = listBoxControl:GetNamedChild("CleanButton")
	cleanButton:SetText(GetString(SI_LE_EMOTEDATAMOD_CLEAN))
	cleanButton:SetHandler("OnClicked", function(control, button) OnCleanButtonClicked(self) end)

	local cancelButton = self.MenuControl:GetNamedChild("CancelButton")
	cancelButton:SetHandler("OnClicked", function(control, button) self:Hide() end)

	local applyButton = self.MenuControl:GetNamedChild("ApplyButton")
	applyButton:SetHandler("OnClicked", function(control, button) LovelyEmotes_EmoteDataMod.ApplyMofifiedEmoteData(_tempEmoteDataEntries, true) end)

	self.SelectedEntryLabel = self.MenuControl:GetNamedChild("SelectedEntryLabel")
	self.EntryBox = self.MenuControl:GetNamedChild("EntryBox")

	self.EntryBox:GetNamedChild("ReplaceNameLabel"):SetText(GetString(SI_LE_EMOTEDATAMOD_REPLACE_NAME))
	self.ReplaceNameEdit = self.EntryBox:GetNamedChild("ReplaceNameEditBox"):GetNamedChild("Edit")
	self.ReplaceNameEdit:SetHandler("OnFocusLost", function() OnReplaceNameOnEditFocusLost(self) end)

	self.AddOverlay = self.MenuControl:GetNamedChild("AddOverlay")

	local function SetupButtonTooltip(control, text)
		control:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(control, TOP, text) end)
		control:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
	end

	SetupButtonTooltip(addButton, GetString(SI_LE_EMOTEDATAMOD_ADD_BUTTON_TOOLTIP))
	SetupButtonTooltip(applyButton, GetString(SI_LE_EMOTEDATAMOD_APPLY_BUTTON_TOOLTIP))
	SetupButtonTooltip(cleanButton, GetString(SI_LE_EMOTEDATAMOD_CLEAN_BUTTON_TOOLTIP))
	SetupButtonTooltip(cancelButton, GetString(SI_LE_EMOTEDATAMOD_CANCEL_BUTTON_TOOLTIP))
end

function LE_EmoteDataModMenu:BuildEntryList()
	ZO_ScrollList_Clear(self.ListControl)
	ZO_ScrollList_AddCategory(self.ListControl, 1)
	local dataList = ZO_ScrollList_GetDataList(self.ListControl)

	local emote
	local slashName

	for emoteId, entry in pairs(_tempEmoteDataEntries) do
		emote = _availableEmotesIdDict[emoteId]

		if emote ~= nil then
			slashName = emote.SlashName
		else
			slashName = "???"
		end

		local data = {
			EmoteID = emoteId,
			SlashName = slashName
		}

		table.insert(dataList, ZO_ScrollList_CreateDataEntry(1, data, 1))
	end

	table.sort(dataList, function(first, second)
		return first.data.SlashName < second.data.SlashName
	end)

	ZO_ScrollList_Commit(self.ListControl, dataList)
end

function LE_EmoteDataModMenu:SelectEntry(emoteId)
	local entry = _tempEmoteDataEntries[emoteId]
	local emote = _availableEmotesIdDict[emoteId]

	if entry == nil or emote == nil then
		_selectedEmoteId = nil
		self.SelectedEntryLabel:SetText(GetString(SI_LE_EMOTEDATAMOD_SELECT_OR_ADD))
		self.EntryBox:SetHidden(true)
		return
	end

	_selectedEmoteId = emoteId

	self.SelectedEntryLabel:SetText(zo_strformat("<<1>> (<<2>>)", emote.SlashName, emoteId))

	if entry.ReplaceName ~= nil then
		self.ReplaceNameEdit:SetText(entry.ReplaceName[GetCVar("language.2")])
	else
		self.ReplaceNameEdit:SetText("")
	end

	self.EntryBox:SetHidden(false)
end

function LE_EmoteDataModMenu:Show()
	if LE_Invisible:IsHidden() or self.IsActive then return end
	self.IsActive = true

	if self.MenuControl == nil then
		self:Initialize()
	end

	CreateAvailableEmotes()
	_tempEmoteDataEntries = ZO_DeepTableCopy(LovelyEmotes_EmoteDataMod.SavedAccountVariables.EmoteDataEntries)
    self:BuildEntryList()
	self:SelectEntry()
	LovelyEmotes.PlayWindowOpenSound()

	self.Fragment:Show()
	HUD_SCENE:AddFragment(self.Fragment)
	HUD_UI_SCENE:AddFragment(self.Fragment)

	if not SCENE_MANAGER:IsInUIMode() then
		SCENE_MANAGER:OnToggleHUDUIBinding()
	end
end

function LE_EmoteDataModMenu:Hide()
	if not self.IsActive then return end
	self.IsActive = false

	_tempEmoteDataEntries = nil
	_availableEmotesIdDict = nil

	LovelyEmotes.PlayWindowCloseSound()

	self.Fragment:Hide()
	HUD_SCENE:RemoveFragment(self.Fragment)
	HUD_UI_SCENE:RemoveFragment(self.Fragment)
end
