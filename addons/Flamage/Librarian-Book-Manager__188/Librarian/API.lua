--[[
Hello fellow addon developper,
You will find bellow a way of adding custom book to Librarian.
Prerequisite: To be sure your addon gets loaded after Librarian the easiest way is to add an optional dependency from your addon to Librarian
If you are not used to it, you can copy this line to your Addon.txt file:
## OptionalDependsOn: Librarian
]]

--[[
LIBRARIAN:RegisterNewCategory(name, totalBooks, GetBookInfo, OpenCategory)
* Should be called at the end of your addon initialization

- categoryIdentifier (*string*) : Identifier that will be used to identify your category from outside of the addon (save or API)
    You can use the same as the english name if you want
- name (*string*) : Name of the category that will be displayed in the "Category" column
- totalBooks (*integer*) : Total number of books in the category. Will be used when initializing Librarian with all the known book of your addon.
    If you want to disable this feature you can give 0 and the rest of the addon should still work)
- GetBookInfo (*function*) : It is the main function that will be used to retrieve data for a book
    The bookIndex is an index starting from 1 to the total number of book or the maximum bookIndex received by the OnBookDisplayed function (it can't be more than 10000 though)
    Prototype:
    * GetBookInfo(*integer* bookIndex)
    ** _Returns:_ *string* _title_, *bool* _known_, *string* _body_, *[BookMedium|#BookMedium]* _medium_, *bool* _showTitle_
- OpenCategory (*function*, optional) : This is called when the player press the key to "Go to Category" from Librarian.
    So you should open your UI with the given book selected if you can.
    You can give nil instead, then the option won't be shown to the player
    Prototype:
    * OpenCategory(*integer* bookIndex)
]]

function Librarian:RegisterNewCategory(categoryIdentifier, name, totalBooks, GetBookInfo, OpenCategory)
    if not self.globalSavedVars.registeredCollectionList then
        self.globalSavedVars.registeredCollectionList = {}
        self.globalSavedVars.nextCollectionToRegister = 1
    end

    if not self.globalSavedVars.registeredCollectionList[categoryIdentifier] then
        self.globalSavedVars.registeredCollectionList[categoryIdentifier] = self.globalSavedVars.nextCollectionToRegister
        self.globalSavedVars.nextCollectionToRegister = self.globalSavedVars.nextCollectionToRegister + 1
    end

    local newCollection = {
        collectionId = categoryIdentifier,
        name = name,
        totalBooks = totalBooks,
        GetBookInfo = GetBookInfo,
        OpenCategory = OpenCategory,
    }
    self.registeredCollection[self.globalSavedVars.registeredCollectionList[categoryIdentifier]] = newCollection
    self:RefreshData()
end

--[[
LIBRARIAN:OnBookDisplayed(categoryIdentifier, bookIndex)
* Should be called when displaying a book with LoreReader UI
* It will add the displayed book to Librarian and activate the read/unread icon and actions to lore reader


- categoryIdentifier (string) : Identifier of the category you used when registering your new category
- bookIndex (*integer*) : Index of the book shown in LoreReader and it will then be used with the GetBookInfo function you registered with your category
]]

function Librarian:OnBookDisplayed(categoryIdentifier, bookIndex)
    for collectionIndex, collection in pairs(self.registeredCollection) do
        if collection.collectionId == categoryIdentifier then
            local title, _, body, medium, showTitle = collection.GetBookInfo(bookIndex)
            if title and body and medium then
                local bookId = self:GetCustomBookIdFromIndices(collectionIndex, bookIndex)
                Librarian.OnShowBook(eventCode, title, body, medium, showTitle, bookId)
            end
            return
        end
    end
end

----------------------------------------------------------------------------------------------------------
-- INTERNAL (shouldn't be called from outside)
--
-- Functions below are here to be able to switch between ESO official API and registered custom categories
----------------------------------------------------------------------------------------------------------

Librarian.constants.CUSTOM_CATEGORY = GetNumLoreCategories() + 1
Librarian.constants.CUSTOM_BOOK_ID_START = 200000
Librarian.constants.MAX_BOOK_PER_CUSTOM_COLLECTION = 10000
Librarian.registeredCollection = {}

function Librarian:IsMainGameCategory(categoryIndex)
    return not categoryIndex or categoryIndex < self.constants.CUSTOM_CATEGORY
end

function Librarian:GetNumLoreCategories()
    if next(self.registeredCollection) == nil then
        return GetNumLoreCategories()
    else
        return Librarian.constants.CUSTOM_CATEGORY
    end
end

function Librarian:GetLoreCollectionCount(categoryIndex)
    if self.IsMainGameCategory(categoryIndex) then
        return select(2, GetLoreCategoryInfo(categoryIndex))
    else
        assert(categoryIndex == self.constants.CUSTOM_CATEGORY)
        return self.globalSavedVars.nextCollectionToRegister - 1
    end
end

function Librarian:GetLoreCollectionName(categoryIndex, collectionIndex)
    if self.IsMainGameCategory(categoryIndex) then
        return select(1, GetLoreCollectionInfo(categoryIndex, collectionIndex))
    else
        assert(categoryIndex == self.constants.CUSTOM_CATEGORY)
        local collection = self.registeredCollection[collectionIndex]
        assert(collection)
        return collection.name
    end
end

function Librarian:GetLoreCollectionTotalBook(categoryIndex, collectionIndex)
    if self.IsMainGameCategory(categoryIndex) then
        return select(4, GetLoreCollectionInfo(categoryIndex, collectionIndex))
    else
        assert(categoryIndex == self.constants.CUSTOM_CATEGORY)
        local collection = self.registeredCollection[collectionIndex]
        if collection then
            return collection.totalBooks
        end
    end
    return 0
end

function Librarian:IsLoreCollectionHidden(categoryIndex, collectionIndex)
    if self.IsMainGameCategory(categoryIndex) then
        return select(5, GetLoreCollectionInfo(categoryIndex, collectionIndex))
    else
        assert(categoryIndex == self.constants.CUSTOM_CATEGORY)
        assert(self.registeredCollection[collectionIndex])
        return false
    end
end

function Librarian:CanOpenCollection(categoryIndex, collectionIndex)
    if categoryIndex and collectionIndex then
        if categoryIndex < self.constants.CUSTOM_CATEGORY then
            return collectionIndex ~= nil and not self:IsLoreCollectionHidden(categoryIndex, collectionIndex)
        else
            assert(categoryIndex == self.constants.CUSTOM_CATEGORY)
            local collection = self.registeredCollection[collectionIndex]
            assert(collection)
            return type(collection.OpenCategory) == "function"
        end
    end
    return false
end

function Librarian:OpenCollection(categoryIndex, collectionIndex, bookIndex)
    if self.IsMainGameCategory(categoryIndex) then
        local collectionId = select(7, GetLoreCollectionInfo(categoryIndex, collectionIndex))
        LORE_LIBRARY:SetCollectionIdToSelect(collectionId)
        MAIN_MENU_KEYBOARD:ShowScene("loreLibrary")
    else
        assert(categoryIndex == self.constants.CUSTOM_CATEGORY)
        local collection = self.registeredCollection[collectionIndex]
        assert(collection)
        collection.OpenCategory(bookIndex)
    end
end

function Librarian:GetBookInfo(categoryIndex, collectionIndex, bookIndex)
    if self.IsMainGameCategory(categoryIndex) then
        local title, _, known, bookId = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
        return title, known, bookId
    else
        assert(categoryIndex == self.constants.CUSTOM_CATEGORY)
        local collection = self.registeredCollection[collectionIndex]
        assert(collection)
        local title, known = collection.GetBookInfo(bookIndex)
        local bookId = self:GetCustomBookIdFromIndices(collectionIndex, bookIndex)
        return title, known, bookId
    end
end

function Librarian:GetCustomBookIdFromIndices(collectionIndex, bookIndex)
    return self.constants.CUSTOM_BOOK_ID_START + collectionIndex * self.constants.MAX_BOOK_PER_CUSTOM_COLLECTION + bookIndex
end

function Librarian:GetLoreBookIndicesFromBookId(bookId)
    if bookId < self.constants.CUSTOM_BOOK_ID_START then
        return GetLoreBookIndicesFromBookId(bookId)
    else
        local bookIndexAndCollection = bookId - self.constants.CUSTOM_BOOK_ID_START
        local collectionIndex = math.floor(bookIndexAndCollection / self.constants.MAX_BOOK_PER_CUSTOM_COLLECTION)
        if self.registeredCollection[collectionIndex] then
            local bookIndex = bookIndexAndCollection - (collectionIndex * self.constants.MAX_BOOK_PER_CUSTOM_COLLECTION)
            return self.constants.CUSTOM_CATEGORY, collectionIndex, bookIndex
        end
    end

    return nil, nil, nil
end

function Librarian:ReadLoreBook(categoryIndex, collectionIndex, bookIndex)
    if self.IsMainGameCategory(categoryIndex) then
        return ReadLoreBook(categoryIndex, collectionIndex, bookIndex)
    else
        assert(categoryIndex == self.constants.CUSTOM_CATEGORY)
        local collection = self.registeredCollection[collectionIndex]
        assert(collection)
        local _, _, body, medium, showTitle = collection.GetBookInfo(bookIndex)
        return body, medium, showTitle
    end
end

function Librarian:GetBookTitleAndBody(categoryIndex, collectionIndex, bookIndex)
    if self.IsMainGameCategory(categoryIndex) then
        local title = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
        local body = ReadLoreBook(categoryIndex, collectionIndex, bookIndex)
        return title, body
    else
        assert(categoryIndex == self.constants.CUSTOM_CATEGORY)
        local collection = self.registeredCollection[collectionIndex]
        assert(collection)
        local title, _, body = collection.GetBookInfo(bookIndex)
        return title, body
    end
end
