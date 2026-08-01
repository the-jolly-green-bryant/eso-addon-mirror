local BookSetGamepad = Librarium_LoreLibraryBookSetGamepad:Subclass()

function BookSetGamepad:New(...)
	return Librarium_LoreLibraryBookSetGamepad.New(self, ...)
end

function BookSetGamepad:Initialize(control)
	Librarium_LoreLibraryBookSetGamepad.Initialize(self, control)
	self.bookListIndex = 1

	LIBRARIUM_GAMEPAD_BOOK_SET_FRAGMENT = ZO_SimpleSceneFragment:New(Librarium_Gamepad_BookSet)
	LIBRARIUM_GAMEPAD_BOOK_SET_FRAGMENT:SetHideOnSceneHidden(true)

	local LIBRARIUM_BOOKSET_SCENE_GAMEPAD = ZO_Scene:New("librariumBookSetGamepad", SCENE_MANAGER)
	LIBRARIUM_BOOKSET_SCENE_GAMEPAD:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
	LIBRARIUM_BOOKSET_SCENE_GAMEPAD:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
	LIBRARIUM_BOOKSET_SCENE_GAMEPAD:AddFragment(LIBRARIUM_GAMEPAD_BOOK_SET_FRAGMENT)
	LIBRARIUM_BOOKSET_SCENE_GAMEPAD:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
	LIBRARIUM_BOOKSET_SCENE_GAMEPAD:AddFragment(MINIMIZE_CHAT_FRAGMENT)
	LIBRARIUM_BOOKSET_SCENE_GAMEPAD:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)

	local function OnStateChanged(...)
		self:OnStateChanged(...)
	end
	LIBRARIUM_BOOKSET_SCENE_GAMEPAD:RegisterCallback("StateChange", OnStateChanged)
end

----------
----------

local CHOOSE_YOUR_OWN_ADVNTR_CAT_ID = 4
local MAIL_ROOM_CATEGORY_ID = 5
local function OpenLoreBookGamepad(title, body, medium ,showTitle, ignoreSound)
	LORE_READER:Show(title, body, medium, showTitle)
	PlaySound(Librarium.BookSounds[medium].OpenSound)
	SCENE_MANAGER:Push("gamepad_loreReaderLoreLibrary")
end

local adventurePoints = 0
local function AppendAdventuresEnding(body, pageIndex)
	if type(body) ~= "table" then d("Error") return end

	local endingIndex, endingBody
	local max = 0 local min = 0
	for key, value in pairs(body["Endings"]) do
		if tonumber(key) > max then max = tonumber(key) end
		if tonumber(key) < min then min = tonumber(key) end
	end

	if adventurePoints >= max then endingIndex = tostring(max)
	elseif adventurePoints <= min then endingIndex = tostring(min)
	else endingIndex = tostring(0) end

	endingBody = zo_strformat("<<1>>\n\n<<2>>", body[pageIndex][1], body["Endings"][endingIndex][1])

	return endingBody
end

function BookSetGamepad:SetupAdventures(catIndex, colIndex, bookIndex, pageIndex, body)

	local adventuresKeybindStripDescriptor =
	{
		-- Option1
		{
			alignment = KEYBIND_STRIP_ALIGN_CENTER,
			name = body[pageIndex].Option1[2],
			keybind = "UI_SHORTCUT_PRIMARY",
			visible = function() return true end, --return catIndex == CHOOSE_YOUR_OWN_ADVNTR_CAT_ID end,
			callback = function()
				PlaySound(SOUNDS.BOOK_PAGE_TURN)
				if body[pageIndex].Option1.points then 
					adventurePoints = adventurePoints + body[pageIndex].Option1.points
				elseif body[pageIndex].Option1[1] ~= GetString(LIBRARIUM_ADVENTURES_RESTART_BOOK) then
					adventurePoints = 0

				end
				local pageIndex = body[pageIndex].Option1[1]
				self:ReadGamepadBook(catIndex, colIndex, bookIndex, pageIndex)
			end,
		},
		-- Option2
		{
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
            name = body[pageIndex].Option2[2],
            keybind = "UI_SHORTCUT_SECONDARY",
            visible = function() return catIndex == CHOOSE_YOUR_OWN_ADVNTR_CAT_ID and body[pageIndex].Option2[2] ~= GetString(LIBRARIUM_ADVENTURES_CLOSE_BOOK) end,
            callback = function()
				PlaySound(SOUNDS.BOOK_PAGE_TURN)
				if body[pageIndex].Option2.points then 
					adventurePoints = adventurePoints + body[pageIndex].Option2.points 
				end
				local pageIndex = body[pageIndex].Option2[1]
				self:ReadGamepadBook(catIndex, colIndex, bookIndex, pageIndex)
            end,
		},
	}

	if LORE_READER.gamepadKeybindStripDescriptor and catIndex == CHOOSE_YOUR_OWN_ADVNTR_CAT_ID then
		KEYBIND_STRIP:AddKeybindButtonGroup(adventuresKeybindStripDescriptor)
	end
end

function BookSetGamepad:ReadGamepadBook(catIndex, colIndex, bookIndex, pageIndex)
	local title = LIBRARIUM_LORE_LIBRARY:GetBookInfo(catIndex, colIndex, bookIndex)
	local body, medium, showTitle, titleFont, bodyFont = LIBRARIUM_LORE_LIBRARY:ReadLibraryBook(catIndex, colIndex, bookIndex)

	if catIndex == CHOOSE_YOUR_OWN_ADVNTR_CAT_ID then
		local pageIndex = pageIndex
		if not pageIndex then pageIndex = 1 end

		if tostring(pageIndex):find("End") then
			local endingBody = AppendAdventuresEnding(body, pageIndex)
			OpenLoreBookGamepad(title, endingBody, medium, showTitle)
		else
			OpenLoreBookGamepad(title, body[pageIndex][1], medium, showTitle)
		end

		self:SetupAdventures(catIndex, colIndex, bookIndex, pageIndex, body)
		
		return
	end

	OpenLoreBookGamepad(title, body, medium, showTitle)
end

function BookSetGamepad:InitializeKeybindStripDescriptors()
	self.keybindStripDescriptor =
	{
		alignment = KEYBIND_STRIP_ALIGN_LEFT,
		-- Back
		KEYBIND_STRIP:GetDefaultGamepadBackButtonDescriptor(),
		-- Read book
		{
			name = GetString(SI_LORE_LIBRARY_READ),
			keybind = "UI_SHORTCUT_PRIMARY",
			callback = function()
				local selectedData = self.itemList:GetTargetData()
				if selectedData and selectedData.bookIndex then
					if selectedData.enabled then
						local title = LIBRARIUM_LORE_LIBRARY:GetBookInfo(self.categoryIndex, self.collectionIndex, selectedData.bookIndex)
						local body, medium, showTitle, titleFont, bodyFont = LIBRARIUM_LORE_LIBRARY:ReadLibraryBook(self.categoryIndex, self.collectionIndex, selectedData.bookIndex)

						if self.categoryIndex == CHOOSE_YOUR_OWN_ADVNTR_CAT_ID then
							local pageIndex = 1

							self:ReadGamepadBook(self.categoryIndex, self.collectionIndex, selectedData.bookIndex, pageIndex)
							self:SetupAdventures(self.categoryIndex, self.collectionIndex, selectedData.bookIndex, pageIndex, body)

							return
						end

						self:ReadGamepadBook(self.categoryIndex, self.collectionIndex, selectedData.bookIndex)
					else
						ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(SI_LORE_LIBRARY_UNKNOWN_BOOK, selectedData.text))
					end
				end
			end,
			enabled = function()
				local selectedData = self.itemList:GetTargetData()
				return selectedData and selectedData.enabled
			end,
		},
		-- Delete Custom Book
		{
			alignment = KEYBIND_STRIP_ALIGN_RIGHT,
			name = GetString(LIBRARIUM_EDITOR_DELETE_CUSTOM_BOOK),
			keybind = "UI_SHORTCUT_TERTIARY",
			visible = function() local selectedData = self.itemList:GetTargetData() return selectedData and selectedData.bookIndex and (self.categoryIndex == MAIL_ROOM_CATEGORY_ID) end,
			callback = function()
				local selectedData = self.itemList:GetTargetData()

				LibrariumBooks.tempCatIndex = self.categoryIndex
				LibrariumBooks.tempColIndex = self.collectionIndex
				LibrariumBooks.tempBookIndex = selectedData.bookIndex

				if self.categoryIndex == MAIL_ROOM_CATEGORY_ID then
					ZO_Dialogs_ShowDialog("LIBRARIUM_EDITOR_CONFIRM_DELETE_SAVED_MAIL")
				end
			end,
		},
	}

	-- Jump to next section.
	ZO_Gamepad_AddListTriggerKeybindDescriptors(self.keybindStripDescriptor, self:GetMainList())
end

function BookSetGamepad:SetupList(list)
	list:AddDataTemplate("ZO_GamepadSubMenuEntryTemplate", ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction)
	list:AddDataTemplateWithHeader("ZO_GamepadSubMenuEntryTemplate", ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "ZO_GamepadMenuEntryHeaderTemplate")
end

function BookSetGamepad:Push(libraryData)
	local bookListIndex = libraryData.bookListIndex or 1
	local categoryIndex = libraryData.categoryIndex
	local collectionIndex = libraryData.collectionIndex
	if (self.bookListIndex ~= bookListIndex) or (self.categoryIndex ~= categoryIndex) or (self.collectionIndex ~= collectionIndex) then
		self.dirty = true
	end

	self.libraryData = libraryData
	self.bookListIndex = bookListIndex
	self.categoryIndex = categoryIndex
	self.collectionIndex = collectionIndex
	SCENE_MANAGER:Push("librariumBookSetGamepad")
end

local function BookSorter(left, right)
	if left.enabled == right.enabled then
		return left.name < right.name
	end

	return left.enabled
end

function BookSetGamepad:PerformUpdate()
	self.dirty = false

	self.itemList:Clear()

	-- Get the list of books we need to show.
	local categoryIndex = self.categoryIndex
	local collectionIndex = self.collectionIndex
	local collectionName, description, numKnownBooks, totalBooks, hidden = LIBRARIUM_LORE_LIBRARY:GetCollectionInfo(categoryIndex, collectionIndex)
	local books = {}
	local knownBooks = 0
	for bookIndex = 1, totalBooks do
		local title, icon, known = LIBRARIUM_LORE_LIBRARY:GetBookInfo(categoryIndex, collectionIndex, bookIndex)
		books[#books + 1] = { bookIndex = bookIndex, name=title, icon=icon, enabled=known }
		if known then
			knownBooks = knownBooks + 1
		end
	end

	table.sort(books, BookSorter)

	-- Add the books to the list.
	for i, bookData in ipairs(books) do
		local entryData = ZO_GamepadEntryData:New(bookData.name, bookData.icon)
		entryData.bookIndex = bookData.bookIndex
		entryData.bookListIndex = i
		entryData.enabled = bookData.enabled
		entryData:SetFontScaleOnSelection(false)
		entryData:SetShowUnselectedSublabels(true)

		if bookData.enabled then
			entryData:SetNameColors(ZO_SELECTED_TEXT, ZO_CONTRAST_TEXT)
			entryData:SetIconDesaturation(0)
		else
			entryData:SetNameColors(ZO_DISABLED_TEXT, ZO_DISABLED_TEXT)
			entryData:SetIconDesaturation(1)
		end

		self.itemList:AddEntry("ZO_GamepadSubMenuEntryTemplate", entryData)
	end

	self.itemList:CommitWithoutReselect()
	self.itemList:SetSelectedIndexWithoutAnimation(self.bookListIndex)

	-- Update the collection count label.
	self.headerData.data1HeaderText = GetString(SI_GAMEPAD_LORE_LIBRARY_TOTAL_COLLECTED_TITLE)
	self.headerData.data1Text = zo_strformat(SI_GAMEPAD_LORE_LIBRARY_TOTAL_COLLECTED, knownBooks, totalBooks)

	-- Update the key bindings.
	KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)

	-- Update the header.
	self.headerData.titleText = collectionName
	ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)
end

function BookSetGamepad:OnSelectionChanged(_, selectedData)
	self.libraryData.bookListIndex = selectedData.bookListIndex
end

function Librarium_Gamepad_BookSet_OnInitialize(control)
	LIBRARIUM_BOOK_SET_GAMEPAD = BookSetGamepad:New(control)
end
