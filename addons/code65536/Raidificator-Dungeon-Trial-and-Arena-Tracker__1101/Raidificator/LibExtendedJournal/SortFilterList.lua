local Internal = LibExtendedJournalInternal
local Public = LibExtendedJournal


--------------------------------------------------------------------------------
-- Context Menu
--------------------------------------------------------------------------------

local NOP = function() end

local DefaultActionButton = {
	keybind = "UI_SHORTCUT_PRIMARY",
	alignment = KEYBIND_STRIP_ALIGN_RIGHT,
}

function Internal.CleanupDefaultActionButton( )
	KEYBIND_STRIP:RemoveKeybindButton(DefaultActionButton)
end


--------------------------------------------------------------------------------
-- ExtendedJournalSortFilterList
--------------------------------------------------------------------------------

ExtendedJournalSortFilterList = ZO_SortFilterList:Subclass()
local ExtendedJournalSortFilterList = ExtendedJournalSortFilterList

function ExtendedJournalSortFilterList:New( control, contextMenuItems, ... )
	local list = ZO_SortFilterList.New(self, control)
	list.frame = control
	list.contextMenuItems = contextMenuItems
	list:Setup(...)
	if (type(Internal.altModeList) == "function") then
		local listControl = control:GetNamedChild("List")
		if (listControl) then
			Internal.altModeList(listControl)
		end
	end
	return list
end

function ExtendedJournalSortFilterList:SortScrollList( )
	if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
		table.sort(ZO_ScrollList_GetDataList(self.list), self.sortFunction)
	end
	self:RefreshVisible()
end

function ExtendedJournalSortFilterList:Row_OnMouseEnter( control )
	ZO_SortFilterList.Row_OnMouseEnter(self, control)
	Internal.CleanupDefaultActionButton()

	local menuItems = self.contextMenuItems
	if (menuItems and #menuItems >= 1) then
		local label, action = menuItems[1](ZO_ScrollList_GetData(control))
		if (type(action) == "function") then
			DefaultActionButton.name = GetString(label)
			DefaultActionButton.callback = action
			KEYBIND_STRIP:AddKeybindButton(DefaultActionButton)
		end
	end
end

function ExtendedJournalSortFilterList:Row_OnMouseExit( control )
	ZO_SortFilterList.Row_OnMouseExit(self, control)
	Internal.CleanupDefaultActionButton()
end

function ExtendedJournalSortFilterList:Row_OnMouseUp( control, button, upInside )
	local menuItems = self.contextMenuItems
	if (menuItems and #menuItems >= 1 and upInside) then
		local data = ZO_ScrollList_GetData(control)
		if (button == MOUSE_BUTTON_INDEX_LEFT) then
			-- LMB: Invoke the first context menu item
			local _, action = menuItems[1](data)
			if (type(action) == "function") then action() end
		elseif (button == MOUSE_BUTTON_INDEX_RIGHT) then
			-- RMB: Open the context menu
			ClearMenu()
			for _, func in ipairs(menuItems) do
				local label, action = func(data)
				if (label and type(action) == "function") then
					AddMenuItem(Internal.GetString(label), action)
				elseif (type(action) == "number" or type(action) == "string") then
					AddMenuItem(string.format((type(action) == "number") and "%s: %d" or "%s: %s", label, action), NOP, nil, nil, ZO_DISABLED_TEXT, nil, nil, nil, nil, nil, nil, false)
				end
			end
			self:ShowMenu(control)
		end
	end
end

function ExtendedJournalSortFilterList:InitializeSearch( typeId )
	local search = ZO_StringSearch:New()

	search:AddProcessor(typeId, function( stringSearch, data, searchTerm, ... )
		local invert = false

		-- Invert the results if the "-" modifier prefix is specified
		if (zo_strlen(searchTerm) > 1 and searchTerm:sub(1, 1) == "-") then
			searchTerm = searchTerm:sub(2)
			invert = true
		end

		local result = self:ProcessItemEntry(stringSearch, data, searchTerm, ...)
		if (invert) then result = not result end
		return result
	end)

	return search
end

function ExtendedJournalSortFilterList:UpdateState( )
	self:RefreshFilters()
end

do
	local function AddEntry( object, label, id, data, callback )
		local entry = ZO_ComboBox:CreateItemEntry(label, callback)
		entry.id = id
		entry.data = data
		object:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
	end

	local function UpdateWidth( object )
		if (object.m_container and object.m_containerWidth) then
			zo_callLater(function()
				object.m_containerWidth = object.m_container:GetWidth()
			end, 50)
		end
	end

	function ExtendedJournalSortFilterList:InitializeComboBox( object, items, initialIndex, allowInitialCallback, callback )
		if (object.SetHeight) then
			object:SetHeight(610)
		end
		object:SetSortsItems(false)
		object:ClearItems()

		local callbackWrapper = function( ... )
			UpdateWidth(object)
			if (callback) then
				callback(...)
			else
				self:UpdateState()
			end
		end

		if (items.list) then
			-- Premade list
			for i, item in ipairs(items.list) do
				local label = (items.key) and item[items.key] or item
				local data = (items.dataKey) and item[items.dataKey]
				AddEntry(object, label, i, data, callbackWrapper)
			end
		elseif (items.prefix and items.max) then
			-- String ID list
			for i = 1, items.max do
				AddEntry(object, GetString(items.prefix, i), i, nil, callbackWrapper)
			end
		end

		Public.SelectComboBoxItemByIndex(object, initialIndex, not allowInitialCallback)

		if (not allowInitialCallback) then
			UpdateWidth(object)
		end
	end
end
