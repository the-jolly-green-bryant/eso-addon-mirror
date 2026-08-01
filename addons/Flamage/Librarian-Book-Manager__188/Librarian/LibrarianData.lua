function Librarian:ImportFromLoreLibrary()
    self.unreadPerCollections = {}
    local hasImportedBooks = false
    local chatEnabled = self.settings.chatEnabled
    local alertEnabled = self.settings.alertEnabled
    self.settings.chatEnabled = true
    self.settings.alertEnabled = false
    local identifier = "LibrarianLoreImport"
    local em = GetEventManager()
    local function endSearch()
        em:UnregisterForUpdate(identifier)
        self.settings.chatEnabled = chatEnabled
        self.settings.alertEnabled = alertEnabled
        if hasImportedBooks then
            self:RefreshAllData()
        else
            self:RefreshLoreLibraryData()
        end
    end

    local categoryIndex, collectionIndex, bookIndex = 0, 0, 0
    local numCollections, totalBooks = 0, 0
    local function step()
        if bookIndex >= totalBooks then
            if collectionIndex >= numCollections then
                if categoryIndex >= self:GetNumLoreCategories() then
                    endSearch()
                    return false
                else
                    categoryIndex = categoryIndex + 1
                    local loreCategoryName
                    numCollections = self:GetLoreCollectionCount(categoryIndex)
                    collectionIndex = 0
                end
            end
            collectionIndex = collectionIndex + 1
            totalBooks = self:GetLoreCollectionTotalBook(categoryIndex, collectionIndex)
            bookIndex = 0

            if totalBooks == 0 then
                -- if there is no book in this collection, it is probably an obsolete collection so let's skip it instead of crashing later here
                return true
            end
        end
        bookIndex = bookIndex + 1
        local title, known, bookId = self:GetBookInfo(categoryIndex, collectionIndex, bookIndex)
        if known then
            local book = self:FindBook(bookId)
            local characterBook = self:FindCharacterBook(bookId)
            if book and characterBook and book.unread then
                self:AddUnreadBookInCollection(categoryIndex, collectionIndex)
            elseif not characterBook then
                local newBook = { bookId = bookId, title = title }
                self:AddBook(newBook, false)
                hasImportedBooks = true
            end
        end
        return true
    end

    local function steps()
        local gettime = GetGameTimeMilliseconds
        local start = gettime()
        -- do as much as possible in 5ms
        while ((gettime() - start) < 5) and step() do
        end
    end
    em:RegisterForUpdate(identifier, 0, steps)
end

function Librarian:FindCharacterBook(bookId)
    if not self.characterBooks then
        return nil
    end

    if self.characterBooksCache[bookId] then
        return self.characterBooksCache[bookId]
    end

    for _,book in ipairs(self.characterBooks) do
        if book.bookId == bookId then
            self.characterBooksCache[bookId] = book
            return book
        end
    end

    return nil
end

function Librarian:FindBook(bookId)
    for _,book in ipairs(self.books) do
        if book.bookId == bookId then
            return book
        end
    end
end

function Librarian:AddBookToGlobalSave(book)
    book.timeStamp = GetTimeStamp()
    book.unread = true

    local categoryIndex, collectionIndex, bookIndex = self:GetLoreBookIndicesFromBookId(book.bookId)
    if categoryIndex and collectionIndex and bookIndex then
        -- if these indexes exist in the API, this mean that we will be able to get these info when needed (so no need to save them)
        book.title = nil
        book.body = nil
        book.medium = nil
        book.showTitle = nil
    else
        local newBody = book.body
        book.body = {}
        while string.len(newBody) > 1024 do
            table.insert(book.body, string.sub(newBody, 0, 1024))
            newBody = string.sub(newBody, 1025)
        end
        table.insert(book.body, newBody)
    end

    table.insert(self.books, book)

    for index, bookIdToDelete in ipairs(self.globalSavedVars.deletedBooks) do
        if bookIdToDelete == book.bookId then
            table.remove(self.globalSavedVars.deletedBooks, index)
            break
        end
    end
end

function Librarian:AddBook(book, refreshDataRightAway)
    if not self:FindCharacterBook(book.bookId) then
        local bookTitle = book.title -- storing it because AddBookToGlobalSave will delete it if we can retrieve it thanks to ESO API
        local foundBook = self:FindBook(book.bookId)
        if foundBook then
            book = foundBook
        else
            self:AddBookToGlobalSave(book)
        end

        local characterBook = { bookId = book.bookId, timeStamp = GetTimeStamp() }
        table.insert(self.characterBooks, characterBook)

        if book.unread then
            local categoryIndex, collectionIndex = self:GetLoreBookIndicesFromBookId(book.bookId)
            if categoryIndex and collectionIndex then
                self:AddUnreadBookInCollection(categoryIndex, collectionIndex)
            end
        end

        if refreshDataRightAway then
            self:RefreshAllData()
        end

        if self.settings.alertEnabled then
           --CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_SKILL_RANK_UPDATE, CSA_EVENT_LARGE_TEXT, SOUNDS.BOOK_ACQUIRED, GetString(SI_LIBRARIAN_NEW_BOOK_FOUND))
            local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_EVENT_LARGE_TEXT, SOUNDS.BOOK_ACQUIRED)
            params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT )
            params:SetText(GetString(LIBRARIAN_NEW_BOOK_FOUND))
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
        end
        if self.settings.chatEnabled then
            d(string.format(GetString(LIBRARIAN_NEW_BOOK_FOUND_WITH_TITLE), bookTitle))
        end

        self.newBookCount = self.newBookCount + 1
        if self.settings.reloadReminderBookCount and self.settings.reloadReminderBookCount > 0 and self.settings.reloadReminderBookCount <= self.newBookCount then
            d(GetString(LIBRARIAN_RELOAD_REMINDER))
        end
    end
end

function Librarian:RemoveBook(bookId)
    for _, bookIdToDelete in ipairs(self.globalSavedVars.deletedBooks) do
        if bookIdToDelete == bookId then
            d("Couldn't delete book, it is already beeing deleted")
            return
        end
    end

    table.insert(self.globalSavedVars.deletedBooks, bookId)

    for index ,book in ipairs(self.books) do
        if book.bookId == bookId then
            table.remove(self.books, index)
            break
        end
    end

    self.characterBooksCache[bookId] = nil
    self:RemoveCharacterBook(bookId)

    -- Clean the master list to be sure the entry is removed from the display as well
    self.masterList = {}
    self:RefreshAllData()
end

function Librarian:RemoveCharacterBook(bookId)
    for index ,book in ipairs(self.characterBooks) do
        if book.bookId == bookId then
            table.remove(self.characterBooks, index)
            break
        end
    end
end

function Librarian:AddUnreadBookInCollection(categoryIndex, collectionIndex)
    if not self.unreadPerCollections[categoryIndex] then self.unreadPerCollections[categoryIndex] = {} end
    if not self.unreadPerCollections[categoryIndex][collectionIndex] then self.unreadPerCollections[categoryIndex][collectionIndex] = 0 end
    self.unreadPerCollections[categoryIndex][collectionIndex] = self.unreadPerCollections[categoryIndex][collectionIndex] + 1
end

function Librarian:ToggleReadBook(book)
    book.unread = not book.unread

    local categoryIndex, collectionIndex = self:GetLoreBookIndicesFromBookId(book.bookId)
    if categoryIndex and collectionIndex then
        if not self.unreadPerCollections[categoryIndex] then self.unreadPerCollections[categoryIndex] = {} end
        if not self.unreadPerCollections[categoryIndex][collectionIndex] then self.unreadPerCollections[categoryIndex][collectionIndex] = 0 end
        if book.unread then
            self.unreadPerCollections[categoryIndex][collectionIndex] = self.unreadPerCollections[categoryIndex][collectionIndex] + 1
        elseif self.unreadPerCollections[categoryIndex][collectionIndex] > 0 then
            self.unreadPerCollections[categoryIndex][collectionIndex] = self.unreadPerCollections[categoryIndex][collectionIndex] - 1
        end
    end

    self:RefreshAllData()
end
