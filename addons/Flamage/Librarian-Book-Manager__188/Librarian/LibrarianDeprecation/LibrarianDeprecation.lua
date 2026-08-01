LibrarianDeprecation = {}

local function DeepCopy(originalTable)
    local copyTable
    if type(originalTable) == 'table' then
        copyTable = {}
        for key, value in pairs(originalTable) do
            copyTable[key] = DeepCopy(value)
        end
    else
        copyTable = originalTable
    end
    return copyTable
end

local function GetNextBookIndex(bookIndexes)
    if bookIndexes.bookIndex >= bookIndexes.totalBooks then
        if bookIndexes.collectionIndex >= bookIndexes.numCollections then
            if bookIndexes.categoryIndex >= GetNumLoreCategories() then
                return false
            else
                bookIndexes.categoryIndex = bookIndexes.categoryIndex + 1
                bookIndexes.numCollections = select(2, GetLoreCategoryInfo(bookIndexes.categoryIndex))
                bookIndexes.collectionIndex = 0
            end
        end
        bookIndexes.collectionIndex = bookIndexes.collectionIndex + 1
        bookIndexes.totalBooks = select(4, GetLoreCollectionInfo(bookIndexes.categoryIndex, bookIndexes.collectionIndex))
        bookIndexes.bookIndex = 0
    end
    bookIndexes.bookIndex = bookIndexes.bookIndex + 1
    return true
end

local function GetBookIdWithTitle(librarian, title)
    -- list of book that aren't part of the eidetic memory
    if title == "Adventurers Wanted!" then
        return 4552
    elseif title == "Behold Khunzar-ri's Ambition" then
        return 5925
    elseif title == "Behold Khunzar-ri's Betrayal" then
        return 5673
    elseif title == "Behold Khunzar-ri's Guile" then
        return 5724
    elseif title == "Behold the Lunar Champion" then
        return 5669
    elseif title == "Beldorr's Note" then
        return 2933
    elseif title == "Bounty: Dragons!" then
        return 5708
    elseif title == "Cadwell's Personal Anthem" then
        return 2517
    elseif title == "Crumpled Note" then
        return 2925
    elseif title == "Crumpled Nursery Rhyme" then
        return 5460
    elseif title == "Details on the Midyear Mayhem" then
        return 4591
    elseif title == "Diviner's Journal" then
        return 4048
    elseif title == "Engraved Pedestal" then
        return 4006
    elseif title == "Excavation Orders" then
        return 4047
    elseif title == "Falsehoods and Fallacies of the Eight" then
        return 1279
    elseif title == "Firuth's Writ" then
        return 4042
    elseif title == "From the Exalted Viper" then -- real name is "From the Regent of Fanged Fury"
        return 2644
    elseif title == "The Ghostly Stag" then
        return 138
    elseif title == "Guardian's Decree" then
        return 4050
    elseif title == "The Indrik's Glade" then
        return 5027
    elseif title == "Journal of the King's Seneschal" then
        return 2015
    elseif title == "Journal of Ulrich" then
        return 132
    elseif title == "Journal's Final Pages" then
        return 2942
    elseif title == "Jubilee Cake Voucher" then
        return 6215
    elseif title == "Keeper's Letter" then
        return 4851
    elseif title == "Khasaad's Treasure Map" then
        return 727
    elseif title == "Laughing Moons Ledger" then
        return 1566
    elseif title == "Legend of Shalug the Shark" then
        return 3285
    elseif title == "Letter From Ember" then
        return 7292
    elseif title == "Letter From Isobel" then
        return 7293
    elseif title == "Mezhun's Field Journal" then
        return 2796
    elseif title == "Nerulean's Guide to Phantoms Vol. II" then
        return 3049
    elseif title == "Ode to a Torchbug" then
        return 2954
    elseif title == "On Soul Shriven, vol 3" then
        return 1551
    elseif title == "An Orc Weaponsmith In Murkmire, Part 1" then -- real name is "From Wrothgar to Lilmoth: A Smith's Tale, Vol 1"
        return 2850
    elseif title == "An Orc Weaponsmith In Murkmire, Part 2" then -- real name is "From Wrothgar to Lilmoth: A Smith's Tale, Vol 2"
        return 2851
    elseif title == "An Orc Weaponsmith In Murkmire, Part 3" then -- real name is "From Wrothgar to Lilmoth: A Smith's Tale, Vol 3"
        return 2852
    elseif title == "Orcthane's Orders" then
        return 439
    elseif title == "Plea to Maximinus" then
        return 2659
    elseif title == "PRISONER: CLARISSE LAURENT" then
        return 2908
    elseif title == "PRISONER: RAYNOR VANOS" then
        return 2907
    elseif title == "PRISONER: TELENGER" then
        return 2909
    elseif title == "Report on Dominion Activities" then
        return 147
    elseif title == "Royal Messenger's Fate" then
        return 2701
    elseif title == "Seeking New Members!" then
        return 7168
    elseif title == "Six Are the Walking Ways" then
        return 4445
    elseif title == "The Song of the Word" then
        return 4446
    elseif title == "Southern Elsweyr Needs You!" then
        return 5697
    elseif title == "Statue of Amminus Entius" then
        return 3419
    elseif title == "Statue of Cavor Merula" then
        return 3416
    elseif title == "Statue of Justia Desticus" then
        return 3417
    elseif title == "Statue of Rusio Olo" then
        return 3418
    elseif title == "Terran's Notes" then
        return 3047
    elseif title == "The Tomb of Ja'darri" then
        return 5737
    elseif title == "Torag ag Krazak, Uz" then
        return 3089
    elseif title == "Tribute Challengers - Novice Tournament" then
        return 7169
    elseif title == "Ushutha's Journal" then
        return 3162
    elseif title == "The Year 2920, Vol. 28" then
        return 2945
    elseif title == "Shrine of Mother Morrowind" then
        return 4495
    elseif title == "My Dearest Love" then
        return 4115
    elseif title == "Crafting Motif 69: Dead-Water Chest Pieces" then
        return 5335
    elseif title == "Crafting Motif 16: Glass Style" then
        return 3174
    elseif title == "Bravil,  Part 1" then
        return 792
    elseif title == "Tharayyas' Journal, Entry 10" then
        return 1399
    elseif title == "The True Nature of Orcs (Banned Ed.)" then
        return 13
    elseif title == "Guild Memo on Soul Trapping" then
        return 240
    elseif title == "Crafting Motif 15: Dwemer Chests" then -- Crafting Motif 15: Dwemer Chests Pieces
        return 2861
    elseif title == "Crafting Motif 15: Dwemer" then
        return 2856
    elseif title == "Crafting Motif 16: Glass Style" then
        return 3174
    elseif title == "Crafting Motif 37: Ebony Style" then
        return 3592

    elseif title == "Crafting Motif 51: Redoran Axes" then -- Crafting Motif 52
        return 4649
    elseif title == "Crafting Motif 51: Redoran Belts" then
        return 4650
    elseif title == "Crafting Motif 51: Redoran Boots" then
        return 4651
    elseif title == "Crafting Motif 51: Redoran Bows" then
        return 4652
    elseif title == "Crafting Motif 51: Redoran Chests" then
        return 4653
    elseif title == "Crafting Motif 51: Redoran Daggers" then
        return 4654
    elseif title == "Crafting Motif 51: Redoran Gloves" then
        return 4655
    elseif title == "Crafting Motif 51: Redoran Helmets" then
        return 4656
    elseif title == "Crafting Motif 51: Redoran Legs" then
        return 4657
    elseif title == "Crafting Motif 51: Redoran Maces" then
        return 4658
    elseif title == "Crafting Motif 51: Redoran Shields" then
        return 4659
    elseif title == "Crafting Motif 51: Redoran Shoulders" then
        return 4660
    elseif title == "Crafting Motif 51: Redoran Staves" then
        return 4661
    elseif title == "Crafting Motif 51: Redoran Swords" then
        return 4662

    elseif title == "Crafting Motif 52: Hlaalu Axes" then -- Crafting Motif 51
        return 4633
    elseif title == "Crafting Motif 52: Hlaalu Belts" then
        return 4634
    elseif title == "Crafting Motif 52: Hlaalu Boots" then
        return 4635
    elseif title == "Crafting Motif 52: Hlaalu Bows" then
        return 4636
    elseif title == "Crafting Motif 52: Hlaalu Chests" then
        return 4637
    elseif title == "Crafting Motif 52: Hlaalu Daggers" then
        return 4638
    elseif title == "Crafting Motif 52: Hlaalu Gloves" then
        return 4639
    elseif title == "Crafting Motif 52: Hlaalu Helmets" then
        return 4640
    elseif title == "Crafting Motif 52: Hlaalu Legs" then
        return 4641
    elseif title == "Crafting Motif 52: Hlaalu Maces" then
        return 4642
    elseif title == "Crafting Motif 52: Hlaalu Shields" then
        return 4643
    elseif title == "Crafting Motif 52: Hlaalu Shoulders" then
        return 4644
    elseif title == "Crafting Motif 52: Hlaalu Staves" then
        return 4645
    elseif title == "Crafting Motif 52: Hlaalu Swords" then
        return 4646

    elseif title == "Crafting Motif 56: Apostle Chest Pieces" then
        return 4748
    elseif title == "Crafting Motif 56: Apostle Shoulder Armor" then
        return 4755

    elseif title == "Crafting Motif 56: Ebonshadow Axes" then -- Crafting Motif 57
        return 4774
    elseif title == "Crafting Motif 56: Ebonshadow Belts" then
        return 4775
    elseif title == "Crafting Motif 56: Ebonshadow Boots" then
        return 4776
    elseif title == "Crafting Motif 56: Ebonshadow Bows" then
        return 4777
    elseif title == "Crafting Motif 56: Ebonshadow Chests" then
        return 4778
    elseif title == "Crafting Motif 56: Ebonshadow Daggers" then
        return 4779
    elseif title == "Crafting Motif 56: Ebonshadow Gloves" then
        return 4780
    elseif title == "Crafting Motif 56: Ebonshadow Helmets" then
        return 4781
    elseif title == "Crafting Motif 56: Ebonshadow Leg Greaves" then
        return 4782
    elseif title == "Crafting Motif 56: Ebonshadow Maces" then
        return 4783
    elseif title == "Crafting Motif 56: Ebonshadow Shields" then
        return 4784
    elseif title == "Crafting Motif 56: Ebonshadow Shoulders" then
        return 4785
    elseif title == "Crafting Motif 56: Ebonshadow Staves" then
        return 4786
    elseif title == "Crafting Motif 56: Ebonshadow Swords" then
        return 4787
    end

    if not librarian.globalSavedVars.failedDeprecation then
        librarian.globalSavedVars.failedDeprecation = { librarianBookId = 100000, bookList = {} }
    end

    for _, book in ipairs(librarian.globalSavedVars.failedDeprecation.bookList) do
        if book.title == title then
            return book.bookId
        end
    end

    local nextBookId = librarian.globalSavedVars.failedDeprecation.librarianBookId
    local newFailedDeprecation = { title = title, bookId = nextBookId }
    table.insert(librarian.globalSavedVars.failedDeprecation.bookList, newFailedDeprecation)
    librarian.globalSavedVars.failedDeprecation.librarianBookId = nextBookId + 1

    return nextBookId
end

function LibrarianDeprecation:UpdateSavedVariables(librarian)
    -- before version 3.0 there was no saveVersion
    -- In this version, the bookId is now used as identifier instead of the title (because several book have the same title)
    if not librarian.globalSavedVars.saveVersion then
        librarian.globalSavedVars.saveVersion = 2

        -- let's copy the current save into another file just in case something wrong happen during deprecation
        local backupGlobalSavedVars = ZO_SavedVars:NewAccountWide("LibrarianDeprecation_SavedVariables_Backup", 1, nil, {}, nil)
        backupGlobalSavedVars.books = DeepCopy(librarian.books)

        -- if this player doesn't know any book yet, no need to go further
        if next(librarian.books) ~= nil then
            local GetLoreBookInfo = GetLoreBookInfo
            local bookIndexes = {
                categoryIndex = 0,
                collectionIndex = 0,
                bookIndex = 0,
                numCollections = 0,
                totalBooks = 0,
            }
            while true do
                if not GetNextBookIndex(bookIndexes) then
                    break
                end

                local title, _, _, bookId = GetLoreBookInfo(bookIndexes.categoryIndex, bookIndexes.collectionIndex, bookIndexes.bookIndex)
                local book = nil
                for _,bookIt in pairs(librarian.books) do
                    if bookIt.title == title then
                        book = bookIt
                        break
                    end
                end
                if book then
                    if not book.bookId then
                        book.bookId = bookId
                    else -- there is a collision (2 books with same name) so we add an entry for the new one
                        local newBook = { bookId = bookId, title = title }
                        librarian:AddBookToGlobalSave(newBook)
                        newBook.timeStamp = book.timeStamp
                    end
                end
            end

            -- now we can erase all the field that are useless (ESO API is performant enough to get these data only when needed)
            -- it will also help keeping the save small and avoid issues with corrupted save
            for _,book in pairs(librarian.books) do
                if book.bookId then
                    book.title = nil
                    book.body = nil
                    book.medium = nil
                    book.showTitle = nil
                else
                    book.bookId = GetBookIdWithTitle(librarian, book.title)

                    local categoryIndex, collectionIndex, bookIndex = GetLoreBookIndicesFromBookId(book.bookId)
                    if categoryIndex and collectionIndex and bookIndex then -- the deprecation found a valid book, so we can erase the content of this one as well
                        book.title = nil
                        book.body = nil
                        book.medium = nil
                        book.showTitle = nil
                    end
                end
                book.wordCount = nil -- it will be computed when building the list (it will allow to switch language and this will still be acurate)
            end
        end
    elseif librarian.globalSavedVars.saveVersion == 1 then
        librarian.globalSavedVars.saveVersion = 2
        
        -- copy the backup save which was inside the Librarian file for version 1 in LibrarianDeprecation file
        local previousBackupGlobalSavedVars = ZO_SavedVars:NewAccountWide("Librarian_SavedVariables_Backup", 1, nil, {}, nil)
        if previousBackupGlobalSavedVars.books then
            local newBackupGlobalSavedVars = ZO_SavedVars:NewAccountWide("LibrarianDeprecation_SavedVariables_Backup", 1, nil, {}, nil)
            newBackupGlobalSavedVars.books = previousBackupGlobalSavedVars.books
            previousBackupGlobalSavedVars.books = nil
        end
    end

    if not librarian.localSavedVars.saveVersion then
        librarian.localSavedVars.saveVersion = 2

        -- let's copy the current save into another file just in case something wrong happen during deprecation
        local backupLocalSavedVars = ZO_SavedVars:New("LibrarianDeprecation_SavedVariables_Backup", 1, nil, {}, nil)
        backupLocalSavedVars.characterBooks = DeepCopy(librarian.characterBooks)

        local GetLoreBookInfo = GetLoreBookInfo
        local bookIndexes = {
            categoryIndex = 0,
            collectionIndex = 0,
            bookIndex = 0,
            numCollections = 0,
            totalBooks = 0,
        }
        while true do
            if not GetNextBookIndex(bookIndexes) then
                break
            end

            local title, _, known, bookId = GetLoreBookInfo(bookIndexes.categoryIndex, bookIndexes.collectionIndex, bookIndexes.bookIndex)

            if known then
                local characterBook = nil
                for _,characterBookIt in ipairs(librarian.characterBooks) do
                    if characterBookIt.title == title then
                        characterBook = characterBookIt
                        break
                    end
                end

                if characterBook then
                    if not characterBook.bookId then
                        characterBook.bookId = bookId
                    else
                        local newCharacterBook = { title = title, timeStamp = characterBook.timeStamp, bookId = bookId }
                        table.insert(librarian.characterBooks, newCharacterBook)
                    end
                end
            end
        end

        -- now we can remove the title from the characterBooks and rely only on the bookId (it saves space)
        for _,characterBook in ipairs(librarian.characterBooks) do
            if characterBook.bookId then
                characterBook.title = nil
            else
                characterBook.bookId = GetBookIdWithTitle(librarian, characterBook.title)

                local categoryIndex, collectionIndex, bookIndex = GetLoreBookIndicesFromBookId(characterBook.bookId)
                if categoryIndex and collectionIndex and bookIndex then -- the deprecation found a valid book, so we can erase the content of this one as well
                    characterBook.title = nil
                end
            end
        end
    elseif librarian.localSavedVars.saveVersion == 1 then
        librarian.localSavedVars.saveVersion = 2
        
        -- copy the backup save which was inside the Librarian file for version 1 in LibrarianDeprecation file
        local previousBackupLocalSavedVars = ZO_SavedVars:New("Librarian_SavedVariables_Backup", 1, nil, {}, nil)
        if previousBackupLocalSavedVars.characterBooks then
            local newBackupLocalSavedVars = ZO_SavedVars:New("LibrarianDeprecation_SavedVariables_Backup", 1, nil, {}, nil)
            newBackupLocalSavedVars.characterBooks = previousBackupLocalSavedVars.characterBooks
            previousBackupLocalSavedVars.characterBooks = nil
        end
    end
end
