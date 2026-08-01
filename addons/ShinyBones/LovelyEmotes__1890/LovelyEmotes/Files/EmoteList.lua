local LE_EmoteList = ZO_Object:Subclass()

local _buttonTemplates = {
	"LE_EmoteTextButtonTemplate",
	"LE_EmoteDefaultButtonTemplate",
}

LE_EmoteList_DirtyID_None = 0
LE_EmoteList_DirtyID_VisibleItems = 1
LE_EmoteList_DirtyID_List = 2

local function UpdateCategories(self)
	local function OnCategoryChanged(id)
		ZO_ScrollList_HideAllCategories(self.ListControl)
		ZO_ScrollList_ShowCategory(self.ListControl, id)
		ZO_ScrollList_ResetToTop(self.ListControl)
	end

	local function OnShowAll()
		ZO_ScrollList_HideAllCategories(self.ListControl)

		for i = #self.TempCategories, 1, -1  do
			ZO_ScrollList_ShowCategory(self.ListControl, self.TempCategories[i].ID)
		end

		ZO_ScrollList_ResetToTop(self.ListControl)
	end

	self.CategoryBox:ClearItems()
	table.sort(self.TempCategories, function(firstValue, secondValue) return firstValue.DisplayName < secondValue.DisplayName end)

	local firstEntry = self.CategoryBox:CreateItemEntry(GetString(SI_MARKETFILTERVIEW1), OnShowAll)
	self.CategoryBox:AddItem(firstEntry)

	for i, v in ipairs(self.TempCategories) do
		local entry = self.CategoryBox:CreateItemEntry(v.DisplayName, function()
			OnCategoryChanged(v.ID)
		end)
		self.CategoryBox:AddItem(entry)
	end

	self.CategoryBox:SelectFirstItem()
end

local function UpdateList(self, emoteList)
	ZO_ScrollList_Clear(self.ListControl)
	ZO_ClearNumericallyIndexedTable(self.TempCategories)
	local collectedCategories = {}

	for i, emote in ipairs(emoteList) do
		local categoryId = emote.CategoryID

		table.insert(self.DataList, ZO_ScrollList_CreateDataEntry(1, emote, categoryId))

		if not collectedCategories[categoryId] then
			collectedCategories[categoryId] = true

			table.insert(self.TempCategories, {
				DisplayName = LovelyEmotes.GetCategoryNameByID(categoryId),
				ID = categoryId,
			} )

			ZO_ScrollList_AddCategory(self.ListControl, categoryId)
		end
	end

	ZO_ScrollList_Commit(self.ListControl, self.DataList)
	UpdateCategories(self)
end

function LE_EmoteList:New(controlName)
	local emoteList = ZO_Object.New(self)
	emoteList:Initialize(controlName)
	return emoteList
end

function LE_EmoteList:Initialize(controlName)
	self.GetAvailableEmotesFunc = function() return LovelyEmotes.AvailableEmotes end
	self.GetEntryNameFunc = LovelyEmotes.GetEmoteDisplayName
	self.DirtyID = LE_EmoteList_DirtyID_None

	self.BaseControl = CreateControlFromVirtual(controlName, GuiRoot, "LE_EmoteListControl")

	local searchControl = self.BaseControl:GetNamedChild("Search")

	self.ListControl = self.BaseControl:GetNamedChild("List")
	self.EditControl = searchControl:GetNamedChild("Box"):GetNamedChild("Edit")

	self.CategoryBoxControl = self.BaseControl:GetNamedChild("CategoryBox")
	self.CategoryBox = ZO_ComboBox_ObjectFromContainer(self.CategoryBoxControl)
	self.CategoryBox:SetSortsItems(false)

	self.TempCategories = {}

	local function SetupCallback(control, data)
		if data.ID < 0 and LovelyEmotes_Settings.SavedAccountVariables.FavoriteCommandsShowDisplayName then
			control:SetText(data.DisplayName)
		else
			control:SetText(self.GetEntryNameFunc(data))
		end

		control:SetHandler("OnClicked", function(control, button) self.ListItemOnClick(button, data) end)

		local collectibleId = GetEmoteCollectibleId(data.Index)

		if not LovelyEmotes_Settings.SavedAccountVariables.HighlightLockedEmotes or not collectibleId or IsCollectibleUnlocked(collectibleId) then
			control:SetEnabled(true)
			control:SetNormalFontColor(LovelyEmotes.GetEmoteTextColor(data))
		else
			control:SetEnabled(false)
		end
	end

	ZO_ScrollList_AddDataType(self.ListControl, 1, _buttonTemplates[LovelyEmotes_Settings.SavedAccountVariables.EmoteListButtonDesign], 25, SetupCallback)
	self.DataList = ZO_ScrollList_GetDataList(self.ListControl)

	local startSearch = function()
		self:SearchByTag(self.EditControl:GetText())
		self.EditControl:LoseFocus()
	end

	self.EditControl:SetHandler("OnEnter", startSearch)
	searchControl:GetNamedChild("Button"):SetHandler("OnClicked", startSearch)
	searchControl:GetNamedChild("ResetButton"):SetHandler("OnClicked", function() self:ResetList() end)

	self.BaseControl:SetHandler("OnEffectivelyShown", function()
		if self.DirtyID == LE_EmoteList_DirtyID_None then return end

		if self.DirtyID == LE_EmoteList_DirtyID_List then self:ResetList()
		elseif self.DirtyID == LE_EmoteList_DirtyID_VisibleItems then self:RefreshVisible() end

		self.DirtyID = LE_EmoteList_DirtyID_None
	end)

	LovelyEmotes_EventSystem.AddListener(LE_EVENT_EmotesOverriddenUpdated, function()
		if self.BaseControl:IsHidden() == true then
			self:SetDirty(LE_EmoteList_DirtyID_VisibleItems)
			return
		end

		self:RefreshVisible()
	end)

	LovelyEmotes_EventSystem.AddListener(LE_EVENT_AvailableEmotesUpdated, function()
		if self.BaseControl:IsHidden() == true then
			self:SetDirty(LE_EmoteList_DirtyID_List)
			return
		end

		self:ResetList()
	end)
end

function LE_EmoteList:SearchByTag(text)
	if text == nil or text == "" then
		self:ResetList()
		return
	end

	text = string.lower(text)
	local newEmoteList = {}
	local availableEmotes = self.GetAvailableEmotesFunc()

	for i,v in ipairs(availableEmotes) do
		if string.match(v.TagString, text) then
			table.insert(newEmoteList, v)
		end
	end

	UpdateList(self, newEmoteList)
end

function LE_EmoteList:SetDirty(dirtyID)
	if self.DirtyID < dirtyID then self.DirtyID = dirtyID end
end

function LE_EmoteList:ResetList()
	UpdateList(self, self.GetAvailableEmotesFunc())
	self.EditControl:Clear()
end

function LE_EmoteList:SelectCategoryShowAll()
	self.CategoryBox:SelectFirstItem()
end

function LE_EmoteList:RefreshVisible()
	ZO_ScrollList_RefreshVisible(self.ListControl)
end

function LE_EmoteList:ResetToTop()
	ZO_ScrollList_ResetToTop(self.ListControl)
end

function LE_EmoteList:SetParent(newParentControl, offsetY, onClickFunc)
	self.BaseControl:ClearAnchors()
	self.BaseControl:SetParent(newParentControl)
	self.BaseControl:SetAnchor(TOPLEFT, newParentControl, TOPLEFT, 0, offsetY)
	self.BaseControl:SetAnchor(BOTTOMRIGHT, newParentControl, BOTTOMRIGHT, 0, 0)

	self.ListItemOnClick = onClickFunc

	self.CategoryBox.m_containerWidth = self.CategoryBoxControl:GetWidth() -- ComboBox workround for dynamic width

	self:ResetList()
end

function LE_EmoteList:CompareParent(control)
	return self.BaseControl:GetParent() == control
end

function LE_EmoteList:ShowSlashNames(value)
	if value then
		self.GetEntryNameFunc = LovelyEmotes.GetEmoteSlashName
	else
		self.GetEntryNameFunc = LovelyEmotes.GetEmoteDisplayName
	end
end

function LovelyEmotes_EmoteList_CreateNew(controlName)
	return LE_EmoteList:New(controlName)
end
