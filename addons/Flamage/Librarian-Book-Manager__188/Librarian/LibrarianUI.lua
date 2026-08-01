function Librarian:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor =
    {
        {
            alignment = KEYBIND_STRIP_ALIGN_RIGHT,
            name = GetString(SI_LORE_LIBRARY_READ),
            keybind = "UI_SHORTCUT_PRIMARY",
            visible = function()
                return self.mouseOverRow
            end,
            callback = function()
                self:ReadBook(self.mouseOverRow.data)
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_RIGHT,
            name = function()
                if not self.mouseOverRow then return nil end
                local book = self:FindBook(self.mouseOverRow.data.bookId)
                if book.unread then
                    return GetString(LIBRARIAN_MARK_READ)
                else
                    return GetString(LIBRARIAN_MARK_UNREAD)
                end
            end,
            keybind = "UI_SHORTCUT_SECONDARY",
            visible = function()
                return self.mouseOverRow
            end,
            callback = function()
                local book = self:FindBook(self.mouseOverRow.data.bookId)
                self:ToggleReadBook(book)
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_RIGHT,
            name = GetString(LIBRARIAN_GO_TO_CATEGORY),
            keybind = "UI_SHORTCUT_TERTIARY",
            visible = function()
                return self.mouseOverRow and self:CanOpenCollection(self.mouseOverRow.data.categoryIndex, self.mouseOverRow.data.collectionIndex)
            end,
            callback = function()
                self:OpenCollection(self.mouseOverRow.data.categoryIndex, self.mouseOverRow.data.collectionIndex, self.mouseOverRow.data.bookIndex)
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = GetString(LIBRARIAN_DELETE_BOOK),
            keybind = "UI_SHORTCUT_NEGATIVE",
            visible = function()
                return self.mouseOverRow
                    and (not self.mouseOverRow.data.categoryIndex
                        or not self.mouseOverRow.data.collectionIndex
                        or self.mouseOverRow.data.categoryIndex == self.constants.CUSTOM_CATEGORY)
            end,
            callback = function()
                self.potentialBookIdToDelete = self.mouseOverRow.data.bookId
                ZO_Dialogs_ShowPlatformDialog("LIBRARIAN_DELETE_BOOK", {bookId = self.mouseOverRow.data.bookId}, {mainTextParams = {self.mouseOverRow.data.title}})
            end,
        }
    }
end

function Librarian:InitializeScene()
    if not LIBRARIAN_SCENE then
        LIBRARIAN_TITLE_FRAGMENT = ZO_SetTitleFragment:New(LIBRARIAN_WINDOW_TITLE_LIBRARIAN)
        LIBRARIAN_SCENE = ZO_Scene:New("librarian", SCENE_MANAGER)
        LIBRARIAN_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
        if self.settings.enableCharacterSpin then
            LIBRARIAN_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
        end
        LIBRARIAN_SCENE:AddFragment(ZO_FadeSceneFragment:New(LibrarianFrame))
        LIBRARIAN_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
        LIBRARIAN_SCENE:AddFragment(TITLE_FRAGMENT)
        LIBRARIAN_SCENE:AddFragment(LIBRARIAN_TITLE_FRAGMENT)
        LIBRARIAN_SCENE:AddFragment(CODEX_WINDOW_SOUNDS)

        LIBRARIAN_SCENE:RegisterCallback("StateChange",
            function(oldState, newState)
                if(newState == SCENE_SHOWING) then
                    KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
                elseif(newState == SCENE_HIDDEN) then
                    KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
                end
            end)
    end
end

function Librarian:BuildMasterList()
    local function ShouldDisplayBook(book)
        if not self.settings.showHiddenBook then
            local category, collection, bookIndex = self:GetLoreBookIndicesFromBookId(book.bookId)
            if category and collection then
                if self:IsLoreCollectionHidden(category, collection) then
                    return false
                elseif not self.settings.showAllBooks then
                    -- I don't know how, but I ended up with some book in Librarian which are not considered as known by the game (Jubilee Cake Voucher)
                    -- Maybe because it is an event book and is added/removed at each event ?
                    -- Anyway, if it isn't known, then we should hide it when showHiddenBook is on to have a consistent count between Librarian and LoreLibrary
                    _, known = self:GetBookInfo(category, collection, bookIndex)
                    if not known then
                        return false
                    end
                end
            else
                return false
            end
        end

        if book.bookId > self.constants.CUSTOM_BOOK_ID_START then
            local category, collection = self:GetLoreBookIndicesFromBookId(book.bookId)
            if not category or not collection then
                return false
            end
        end
        return true
    end

    for i, book in ipairs(self.books) do
        if ShouldDisplayBook(book) then
            if not self.masterList[i] then
                self.masterList[i] = {}
            end

            local data = self.masterList[i]
            for k,v in pairs(book) do
				if k == "body" then
					data[k] = table.concat(book.body)
				else
					data[k] = v
				end
            end

            -- because we reuse the same list between 2 refresh, the data may already be filled up so no need to recompute it, these won't change
            if not data.categoryIndex or not data.collectionIndex or not data.bookIndex then
                data.categoryIndex, data.collectionIndex, data.bookIndex = self:GetLoreBookIndicesFromBookId(book.bookId)
            end
            if data.categoryIndex and data.collectionIndex and data.bookIndex and (not data.title or not data.body or not data.category) then
                data.title, data.body = self:GetBookTitleAndBody(data.categoryIndex, data.collectionIndex, data.bookIndex)
                data.category = self:GetLoreCollectionName(data.categoryIndex, data.collectionIndex)
            end

            if not data.category or data.category == "" then
                if not data.categoryIndex or not data.collectionIndex
                    or (data.categoryIndex == 2 and data.collectionIndex == 3) then -- Category for "Crafting Motif 15: Dwemer Style" which is never shown
                    data.category = GetString(LIBRARIAN_NO_CATEGORY)
                else
                    data.category = GetString(LIBRARIAN_LOCKED_CATEGORY)
                end
            end

            if not data.wordCount or data.wordCount == 0 then
                local wordCount = 0
                if data.body then
                    for w in data.body:gmatch("%S+") do
                        wordCount = wordCount + 1
                    end
                end
                data.wordCount = wordCount
            end

            data.type = self.constants.LIBRARIAN_SEARCH
            local characterBook = self:FindCharacterBook(book.bookId)
            if characterBook then
                data.seenByCurrentCharacter = true
                data.timeStamp = characterBook.timeStamp
            else
                data.seenByCurrentCharacter = false
                data.timeStamp = book.timeStamp
            end
        else
            self.masterList[i] = nil
        end
    end
end

function Librarian:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    local bookCount = 0
    local unreadCount = 0
    local searchTerm = self.searchBox:GetText()
    for _, data in pairs(self.masterList) do
        if self.settings.showAllBooks or data.seenByCurrentCharacter then
            if(searchTerm == "" or self.search:IsMatch(searchTerm, data)) then
                table.insert(scrollData, ZO_ScrollList_CreateDataEntry(self.constants.LIBRARIAN_DATA, data))
                bookCount = bookCount + 1
                if data.unread then unreadCount = unreadCount + 1 end
            end
        end
    end

    local message = string.format(GetString(LIBRARIAN_BOOK_COUNT), bookCount)
    if unreadCount > 0 then message = string.format(GetString(LIBRARIAN_UNREAD_COUNT), message, unreadCount) end
    LibrarianFrameBookCount:SetText(message)
end

function Librarian:SortScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
end

function Librarian:SetupBookRow(control, data)
    control.data = data
    control.unread = GetControl(control, "Unread")
    control.found = GetControl(control, "Found")
    control.title = GetControl(control, "Title")
    control.category = GetControl(control, "Category")
    control.wordCount = GetControl(control, "WordCount")

    control.unread.nonRecolorable = true
    if data.unread then control.unread:SetAlpha(1) else control.unread:SetAlpha(0) end

    control.found.normalColor = ZO_NORMAL_TEXT
    control.found:SetText(self:FormatClockTime(data.timeStamp))

    control.title.normalColor = ZO_NORMAL_TEXT
    control.title:SetText(data.title)

    control.category.normalColor = ZO_NORMAL_TEXT
    control.category:SetText(data.category)

    control.wordCount.normalColor = ZO_NORMAL_TEXT
    control.wordCount:SetText(data.wordCount)

    ZO_SortFilterList.SetupRow(self, control, data)
end

function Librarian:ProcessBookEntry(stringSearch, data, searchTerm, cache)
    local lowerSearchTerm = searchTerm:lower()

    if data.title and zo_plainstrfind(data.title:lower(), lowerSearchTerm) then
        return true
    end

    if not self.searchOnlyTitle and data.body and zo_plainstrfind(data.body:lower(), lowerSearchTerm) then
        return true
    end

    return false
end

function Librarian:Toggle()
    if LibrarianFrame:IsControlHidden() then
        SCENE_MANAGER:Show("librarian")
    else
        SCENE_MANAGER:Hide("librarian")
    end
end

function Librarian:FormatClockTime(time)
    local midnightSeconds = GetSecondsSinceMidnight()
    local utcSeconds = GetTimeStamp() % 86400
    local offset = midnightSeconds - utcSeconds
    if offset < -43200 then
        offset = offset + 86400
    end

    local dateString = GetDateStringFromTimestamp(time)
    local timeString = ZO_FormatTime((time + offset) % 86400, TIME_FORMAT_STYLE_CLOCK_TIME, self.settings.timeFormat)
    return string.format("%s %s", dateString, timeString)
end

function Librarian:OnSearchTextChanged()
    ZO_EditDefaultText_OnTextChanged(self.searchBox)

    -- Let's wait a little bit before updating the filters if the player didn't have time to enter its full string yet
    -- Because if we try to update the filters too much it sometimes crash
    local TIME_BEFORE_UPDATING_FILTERS = 600 -- ms
    self.lastTimeSearchModified = GetGameTimeMilliseconds()
    local function TryRefreshFilters()
        if self.lastTimeSearchModified + TIME_BEFORE_UPDATING_FILTERS <= GetGameTimeMilliseconds() then
            self:RefreshFilters()
        end
    end
    zo_callLater(TryRefreshFilters, TIME_BEFORE_UPDATING_FILTERS)
end

function Librarian.OnMouseEnterRow(control)
    LIBRARIAN:Row_OnMouseEnter(control)
end

function Librarian.OnMouseExitRow(control)
    LIBRARIAN:Row_OnMouseExit(control)
end

function Librarian.OnMouseUpRow(control, button, upInside)
    LIBRARIAN:ReadBook(control.data)
end
