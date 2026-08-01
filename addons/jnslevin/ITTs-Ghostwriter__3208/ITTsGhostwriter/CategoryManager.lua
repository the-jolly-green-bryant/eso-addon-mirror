ITTsGhostwriter.CategoryManager = ZO_Object:Subclass()
local CategoryManager           = ITTsGhostwriter.CategoryManager
ITTsGhostwriter.Category        = CategoryManager:Subclass()
local Category                  = ITTsGhostwriter.Category
ITTsGhostwriter.Note            = Category:Subclass()
local Note                      = ITTsGhostwriter.Note
local PROTECTED_CATEGORY        = "Uncategorized"
-- I am painfully aware that none of this is needed. I could have done this whole thing with 5 little functions
-- But i wanted to learn so this addon is now the scapegoat for that
local function refreshTree()
    ITTsGhostwriter.UI:RefreshTree( ITTsGhostwriter.UI.tree )
end
---@param newName string: The name of the new category to be created
---@param newIconIndex number: The index of the icon to be used for the new category
local logger = GWLogger:New( "CategoryManager" )



function CategoryManager:New( ... )
    local instance      = ZO_Object.New( self )
    instance.categories = {} -- Add a table to store categories
    --instance.db = db --!this used to somehow work but im scared so im not touching it
    local args          = { ... }
    for i, arg in ipairs( args ) do
        instance[ "property" .. i ] = arg
    end
    logger:Log( 2, "Creating a new CategoryManager instance" )
    -- more logic here
    return instance
end

-- Add category in tree loop, if it exists in db but not in tree, add it to tree
-- if it doesnt exist in tree or db, add it to make a new one and save it to db
function CategoryManager:AddCategory( categoryData, REFRESH_TREE )
    local categoryName     = categoryData.name
    local existingCategory = self.categories[ categoryName ]
    local existingDB
    local category
    if not categoryData.entries then
        categoryData.entries = {}
    end
    if not self:IsCategoryNameValid( categoryName ) then
        logger:Log( 4, "AddCategory: Invalid category name provided. (%s)",
                    categoryName )
        return false
    end
    if not self:IsCategoryDataValid( categoryData ) then
        logger:Log( 4, "AddCategory: Invalid category data provided." )
        return false
    end

    if existingCategory then
        logger:Log( 3,
                    "Category %s already exists in instance. Recreating the instance.",
                    categoryName )
        category = Category:New( categoryName, categoryData.iconIndex,
                                 categoryData.priority,
                                 categoryData.treeNode, self )
        if not category then return false end
        return category
    end
    existingDB = ITTsGhostwriter.Vars.notes[ categoryName ]
    if existingDB then
        logger:Log( 3,
                    "Category %s already exists in database. Recreating the instance.",
                    categoryName )
        category = Category:New( categoryName, categoryData.iconIndex,
                                 categoryData.priority,
                                 categoryData.treeNode, self )
        if not category then
            logger:Log( 4, "Recreated category is nil" )
            return false
        end
        return category
    end


    --this only happens if no instance and no db entry exists
    category = Category:New( categoryName, categoryData.iconIndex,
                             categoryData.priority, categoryData.treeNode,
                             self )

    if not category then
        return false
    end

    self:SaveCategoryToDatabase( categoryName, categoryData )
    if not self.categories[ categoryName ] then
        self.categories[ categoryName ] = {}
    end -- this shouldnt be needed but better safe than sorry
    logger:Log( 2, "AddCategory: Saving category %s to database",
                categoryName )

    if REFRESH_TREE then
        logger:Log( 1, "Refresh tree is true, refreshing tree" )
        refreshTree()
    end

    return category
end

function CategoryManager:RemoveCategory( categoryName, moveEntries )
    logger:Log( 1, "RemoveCategory: Removing category %s", categoryName )
    if categoryName == PROTECTED_CATEGORY then
        logger:Log( 4,
                    "RemoveCategory: Tried to remove protected category %s",
                    categoryName )
        return false
    end
    -- Check if the category exists
    if not self.categories[ categoryName ] then
        logger:Log( 4,
                    "RemoveCategory: Attempted to remove a category that does not exist in the categories table. Category name: %s",
                    categoryName )
        return false
    end
    local category = self:GetCategory( categoryName )
    if not category then
        logger:Log( 4,
                    "RemoveCategory: Attempted to remove a category that could not be retrieved using GetCategory. Category name: %s",
                    categoryName )
        return false
    end

    if moveEntries then
        logger:Log( 1, "MoveEntries is true, moving entries to %s",
                    PROTECTED_CATEGORY )
        local success = self:MergeCategories( categoryName,
                                              PROTECTED_CATEGORY )
        if success then
            logger:Log( 1, "Succesfully moved entries from %s to %s",
                        categoryName, PROTECTED_CATEGORY )
            if self:IsCategoryEmpty( categoryName ) then
                self:DeleteCategory( categoryName )
            end
        else
            logger:Log( 4, "Failed to move entries from %s to %s",
                        categoryName, PROTECTED_CATEGORY )
            return false
        end
    else
        logger:Log( 1, "MoveEntries is false, clearing entries from %s",
                    categoryName )
        self:DeleteCategory( categoryName )
    end

    logger:Log( "Succesfully removed category %s", categoryName )
    return true
end

-- retrieve category instance by name
function CategoryManager:GetCategory( categoryName )
    logger:Log( 1, "GetCategory: Getting category %s", categoryName )
    if not self then
        logger:Log( 4, "GetCategory: CategoryManager does not exist." )
        return nil
    end
    if not self.categories then
        logger:Log( 4, "GetCategory: Categories table does not exist." )
        return nil
    end
    -- Check if the category exists
    if not self.categories[ categoryName ] then
        logger:Log( 4, "GetCategory: Category %s does not exist.",
                    categoryName )
        return nil
    end

    -- Return the category
    return self.categories[ categoryName ]
end

-- retrieve category instance by name same as above?
function CategoryManager:GetCategoryByName( categoryName )
    -- Check if the necessary parameter is provided and is of correct type
    if type( categoryName ) ~= "string" then
        logger:Log( 4, "GetCategoryByName: Invalid parameter provided: %s.",
                    categoryName )
        return nil
    end

    -- Directly access the category by its name
    local category = self.categories[ categoryName ]

    -- Check if the category exists
    if category then
        return category
    else
        logger:Log( 4, "GetCategoryByName: No category found with name: %s",
                    categoryName )
        return nil
    end
end

-- move note from a to b
function CategoryManager:MoveNoteToCategory(
    noteName,
    sourceCategoryName,
    targetCategoryName )
    -- Get the old category
    local source = self:GetCategory( sourceCategoryName )
    if not source then
        logger:Log( 4, " MoveNoteToCategory: Source does not exist." )
        return
    end

    -- Get the new category
    local target = self:GetCategory( targetCategoryName )
    if not target then
        logger:Log( 4, "MoveNoteToCategory: Target does not exist." )
        return
    end

    -- Get the note from the old category
    local note = source:GetNote( noteName )
    if not note then
        logger:Log( 4, "MoveNoteToCategory: Note does not exist." )
        return
    end
    local noteData = {
        name         = note.name,
        content      = note.content,
        categoryName = targetCategoryName,
        treeNode     = note.treeNode,
    }

    -- Add the note to the new category
    target:AddNote( noteData )
    -- Remove the note from the old category
    source:DeleteNote( noteName )

    logger:Log(
        "MoveNoteToCategory: Succesfully moved note %s from category %s to category %s",
        noteName, sourceCategoryName,
        targetCategoryName )
    refreshTree()
end

-- merge categories a into b
function CategoryManager:MergeCategories(
    sourceCategoryName,
    targetCategoryName )
    -- Get the source category
    local source = self:GetCategory( sourceCategoryName )
    if not source then
        logger:Log( 4, "MergeCategories: Source category %s does not exist.",
                    sourceCategoryName )
        return false
    end

    -- Get the target category
    local target = self:GetCategory( targetCategoryName )
    if not target then
        logger:Log( 4, "MergeCategories: Target category %s does not exist.",
                    targetCategoryName )
        return false
    end
    -- handle notes with the same name
    local sourceEntriesCopy = ZO_ShallowTableCopy( ITTsGhostwriter.Vars
        .notes[ sourceCategoryName ].entries )
    for key, value in pairs( sourceEntriesCopy ) do
        if ITTsGhostwriter.Vars.notes[ targetCategoryName ].entries[ key ] then
            local newKey = key .. "-Moved"
            -- If the new key already exists, append a unique identifier
            while ITTsGhostwriter.Vars.notes[ targetCategoryName ].entries[ newKey ] do
                newKey = newKey .. "-" .. tostring( os.time() )
            end
            sourceEntriesCopy[ newKey ] = value
            sourceEntriesCopy[ key ] = nil
        end
    end
    ZO_CombineNonContiguousTables(
        ITTsGhostwriter.Vars.notes[ targetCategoryName ].entries,
        sourceEntriesCopy )
    -- Clear the source category's entries
    local success = self:ClearEntries( sourceCategoryName )
    -- Merge the source category's entries into the target category
    if success then
        self:DeleteCategory( sourceCategoryName )
    else
        logger:Log( 4,
                    "MergeCategories: Failed to clear entries from category %s",
                    sourceCategoryName )
        return false
    end
    refreshTree()
    logger:Log( 2, "Succesfully merged category %s into category %s",
                sourceCategoryName, targetCategoryName )
    return true
end

-- delete category
function CategoryManager:DeleteCategory( categoryName )
    if categoryName == PROTECTED_CATEGORY then
        logger:Log( 4,
                    "DeleteCategory: Tried to remove protected category %s",
                    categoryName )
        return false
    end
    -- Check if the category exists
    if not self.categories[ categoryName ] then
        logger:Log( 4, "DeleteCategory: Category %s does not exist.",
                    categoryName )
        return false
    end
    ITTsGhostwriter.Vars.notes[ categoryName ] = nil
    self.categories[ categoryName ] = nil
    refreshTree()
    return true
end

-- clear entries from category
function CategoryManager:ClearEntries( categoryName )
    logger:Log( 1, "ClearEntries: Clearing entries from category %s",
                categoryName )
    local category = self:GetCategory( categoryName )

    if not category then
        logger:Log( 5, "ClearEntries: Category %s does not exist.",
                    categoryName )
        return false
    end
    if not category.notes then
        logger:Log( 5,
                    "ClearEntries: Category %s does not have a notes table.",
                    categoryName )
        return false
    end
    local categoryEntries = category.notes
    -- removing entries from category one table up compared to db
    ZO_ClearTable( categoryEntries )
    ZO_ClearTable( ITTsGhostwriter.Vars.notes[ categoryName ].entries )
    refreshTree()
    if self:IsCategoryEmpty( categoryName ) then
        self:DeleteCategory( categoryName )
        logger:Log( "ClearEntries: Cleared entries from category %s",
                    categoryName )
    end
    return true
end

-- update categoryData and / or name
-- improvement available?
function CategoryManager:UpdateCategoryData( categoryName, newCategoryData )
    if not newCategoryData.entries then newCategoryData.entries = {} end
    if not CategoryManager:IsCategoryDataValid( newCategoryData ) then
        logger:Log( 4, "UpdateCategory: Invalid category data provided." )
        return false
    end
    logger:Log( 2, "UpdateCategory: Updating category %s data: %s", categoryName, newCategoryData )
    if newCategoryData.name == categoryName then
        -- If the name hasn't changed, just update the category data
        logger:Log( 1, "UpdateCategory: Updating data for category %s",
                    categoryName )
        self.categories[ categoryName ].iconIndex = newCategoryData
            .iconIndex
        ITTsGhostwriter.Vars.notes[ categoryName ].iconIndex = newCategoryData.iconIndex

        self.categories[ categoryName ].priority = newCategoryData
            .priority
        ITTsGhostwriter.Vars.notes[ categoryName ].priority = newCategoryData.priority
    else
        -- If the name has changed, perform the full update process
        logger:Log( 1, "UpdateCategory: Updating category %s", categoryName )

        -- Add the new category
        local addSuccess = self:AddCategory( newCategoryData )
        if not addSuccess then
            logger:Log( 4, "UpdateCategory: Failed to add category %s",
                        newCategoryData.name )
            return false
        end
        logger:Log( 2, "UpdateCategory: Moving entries from %s to %s",
                    categoryName, newCategoryData.name )

        local mergeSuccess = self:MergeCategories( categoryName,
                                                   newCategoryData.name )
        if not mergeSuccess then
            logger:Log( 4,
                        "UpdateCategory: Failed to move entries from %s to %s",
                        categoryName, newCategoryData.name )
            return false
        end
        logger:Log( 2, "UpdateCategory: Deleting %s", categoryName )
        if self:IsCategoryEmpty( categoryName ) then -- should be empty after calling mergecategories
            self:DeleteCategory( categoryName )
            logger:Log( 2,
                        "UpdateCategory: Category %s is not empty, not deleting",
                        categoryName )
        end
    end
    refreshTree()
    return true
end

-- check if category name is valid
function CategoryManager:IsCategoryNameValid( categoryName )
    -- Check if the category name is provided, is a string, and is not empty
    if not categoryName or type( categoryName ) ~= "string" or categoryName == "" then
        logger:Log( 4,
                    "NameValidation: Invalid category name. Provided value: '%s'. Category name must be a non-empty string.",
                    tostring( categoryName ) )
        return false
    end


    -- Check if a category with the same name already exists
    if self.categories and self.categories[ categoryName ] then
        logger:Log( 4,
                    "NameValidation: Category name conflict. A category with the name '%s' already exists.",
                    categoryName )
        return false
    end

    logger:Log( 1, "NameValidation: Category name '%s' is valid.",
                categoryName )
    return true
end

-- check if category is empty
function CategoryManager:IsCategoryEmpty( categoryName )
    -- Check if the category exists
    if not self.categories[ categoryName ] then
        logger:Log( 4, "IsEmpty: Category %s does not exist.", categoryName )
        return false
    end

    -- Check if the category has any notes
    if not self.categories[ categoryName ].notes then
        logger:Log( 4, "IsEmpty: Category %s does not have a notes table.",
                    categoryName )
        return false
    end

    if ZO_IsTableEmpty( self.categories[ categoryName ].notes ) then
        logger:Log( 1, "IsEmpty: Category %s is empty.", categoryName )
        return true
    end

    logger:Log( 1, "IsEmpty: Category %s is not empty.", categoryName )
    return false
end

function CategoryManager:IsCategoryDataValid( categoryData )
    -- Check if the category data is provided and is a table
    if type( categoryData ) ~= "table" then
        logger:Log( 4, "DataValidation: Invalid category data provided." )
        return false
    end

    -- Check if the category data has the required fields
    -- We could maybe not check the entries.. they will be made anyway. for now its fine
    if not categoryData.entries or type( categoryData.entries ) ~= "table" then
        logger:Log( 4,
                    "DataValidation: Category data does not contain 'entries' or 'entries' is not a table." )
    elseif not categoryData.priority or type( categoryData.priority ) ~= "number" then
        logger:Log( 4,
                    "DataValidation: Category data does not contain 'priority' or 'priority' is not a number." )
    elseif not categoryData.iconIndex or type( categoryData.iconIndex ) ~= "number" then
        logger:Log( 4,
                    "DataValidation: Category data does not contain 'iconIndex' or 'iconIndex' is not a number." )
    else
        logger:Log( 1, "DataValidation: Category data is valid." )
        return true
    end
    return false
end

-- get all category instances
function CategoryManager:GetAllCategories()
    -- Return the categories table
    return self.categories
end

-- get all category names
function CategoryManager:GetAllCategoryNames()
    local names = {}
    for name, _ in pairs( self.categories ) do
        table.insert( names, name )
    end
    return names
end

-- save category to db
function CategoryManager:SaveCategoryToDatabase( categoryName, categoryData )
    logger:Log( 1,
                "SaveCategoryToDatabase: Saving category %s to database / categoryIconIndex: %s",
                categoryName,
                categoryData.iconIndex )

    -- Check if the category already exists in the database
    local categoryInDb = ITTsGhostwriter.Vars.notes[ categoryName ]
    if categoryInDb then
        logger:Log( 1,
                    "SaveCategoryToDatabase: Category %s exists in the database",
                    categoryName )
        -- Update only specific fields and keep the rest of the data intact
        categoryInDb.iconIndex = categoryData.iconIndex
        categoryInDb.name      = categoryData.name
        categoryInDb.priority  = categoryData.priority
        if self.categories[ categoryName ] then
            self.categories[ categoryName ].iconIndex = categoryData
                .iconIndex
            self.categories[ categoryName ].name = categoryData.name
            self.categories[ categoryName ].priority = categoryData
                .priority
        end
    else
        logger:Log( 1,
                    "SaveCategoryToDatabase: Category %s does not exist in the database. Creating a new one.",
                    categoryName )
        -- If the category doesn't exist in the database, create a new one
        ITTsGhostwriter.Vars.notes[ categoryName ] = categoryData
    end
end

-- get category by note name
function CategoryManager:GetCategoryByNoteName( noteName )
    -- Iterate over all categories
    for _, category in pairs( self.categories ) do
        -- Iterate over all notes in the category
        for _, note in pairs( category.notes ) do
            -- If the note name matches the given note name
            if note.name == noteName then
                -- Return the category of the note
                return category
            end
        end
    end

    -- If no note with the given name was found, return nil
    return nil
end

-- update categorydata if different
function CategoryManager:UpdateCategoryIfDifferent(
    categoryName,
    newCategoryData )
    -- Check if the category exists
    if not self:DoesCategoryExist( categoryName ) then
        logger:Log( 4,
                    "UpdateCategoryIfDifferent: Category %s does not exist.",
                    categoryName )
        return false
    end

    local category = self.categories[ categoryName ]

    -- Check if the new data is different from the current data
    local isDifferent = false
    for key, value in pairs( newCategoryData ) do
        if category[ key ] ~= value then
            isDifferent = true
            break
        end
    end

    -- If the new data is different, update the category
    if isDifferent then
        for key, value in pairs( newCategoryData ) do
            category[ key ] = value
        end
    end
    return true
end

function CategoryManager:DoesCategoryExist( categoryName )
    for key, _ in pairs( self.categories ) do
        if key == categoryName then
            return true
        end
    end
    return false
end

function CategoryManager:GetNumberOfNotesInCategory( categoryName )
    logger:Log( 1,
                "GetNumberOfNotesInCategory: Getting number of notes in category %s",
                categoryName )
    -- Check if the category exists
    if not self.categories[ categoryName ] then
        logger:Log( 4,
                    "GetNumberOfNotesInCategory: Attempted to access a category that does not exist. Category name: %s",
                    categoryName )
        return nil
    end

    -- Get the category
    local category = self.categories[ categoryName ]
    logger:Log( 1, "GetNumberOfNotesInCategory: Category %s exists",
                categoryName )
    -- Return the number of notes in the category
    local count = NonContiguousCount( category.notes )
    local testCount = 0
    for _ in pairs( category.notes ) do
        testCount = testCount + 1
    end
    logger:Log( 1,
                "GetNumberOfNotesInCategory: Category %s has %d notes testCount: %s",
                categoryName, count, testCount )
    return count
end

----------------
----Category----
----------------
--This should only be called by AddCategory
function Category:New( name, iconIndex, priority, treeNode, manager )
    -- Check if the necessary parameters are provided and are of correct type
    if type( name ) ~= "string" or type( iconIndex ) ~= "number" or type( priority ) ~= "number" then
        logger:Log( 4,
                    "Invalid parameters provided for creating a new Category instance. Name type: %s, IconIndex type: %s, Priority type: %s",
                    type( name ), type( iconIndex ), type( priority ) )
        return nil
    end
    if manager then
        logger:Log( 1, "Manager exists" )
    else
        logger:Log( 5, "Manager does not exist" )
    end
    local instance             = ZO_Object.New( self )
    instance.name              = name
    instance.iconIndex         = iconIndex
    instance.priority          = priority
    instance.notes             = {}
    instance.treeNode          = treeNode
    instance.manager           = manager

    --instance.db = manager.db[ name ] --!this used to somehow work but im scared so im not touching it

    manager.categories[ name ] = instance
    logger:Log( 2, "Creating a new Category instance with name: " .. name )
    return instance
end

--check db and instance for existing note, if not create new note
function Category:AddNote( noteData )
    if not noteData or type( noteData.name ) ~= "string" or type( noteData.content ) ~= "string" then
        logger:Log( 4,
                    "Invalid parameters provided for adding a new note. NoteData type: %s",
                    type( noteData ) )
        return nil
    end

    logger:Log( 1,
                "AddNote: Adding a new note to category %s / noteData is %s",
                self.name, noteData.name )
    local noteName = noteData.name
    local existingNote = self.notes[ noteName ]
    local existingDB = ITTsGhostwriter.Vars.notes[ self.name ].entries
        [ noteName ]
    local newNote

    logger:Log( 1, "AddNote: Adding a new note (%s)", noteName )

    if existingNote then
        logger:Log( 3,
                    "Note %s already exists in instance. Recreating the instance.",
                    noteName )
        newNote = Note:New( noteName, noteData.content, self.name,
                            noteData.treeNode, self )
        if not newNote then
            logger:Log( 4, "Recreated note is nil" )
            return nil
        end
        return newNote
    end

    if existingDB then
        logger:Log( 3,
                    "Note %s already exists in database. Recreating the instance.",
                    noteName )
        newNote = Note:New( noteName, noteData.content, self.name,
                            noteData.treeNode, self )
        if not newNote then
            logger:Log( 4, "Recreated note is nil" )
            return nil
        end
        return newNote
    end

    logger:Log( 1, "AddNote: Creating a new note with name: %s", noteName )
    newNote = Note:New( noteName, noteData.content, self.name,
                        noteData.treeNode, self )

    if not newNote then
        logger:Log( 4, "Created note is nil" )
        return nil
    end

    -- Add the new note to the notes table
    self.notes[ noteName ] = newNote

    logger:Log( 1, "Adding a new note to this category: " .. self.name )
    local data = {
        name = noteName,
        content = noteData.content,
        categoryName = self.name,
    }
    newNote:SaveNoteToDatabase( data )

    return newNote
end

-- delete note from category
function Category:DeleteNote( noteName )
    -- Check if the note exists
    if not self.notes[ noteName ] then
        logger:Log( 4,
                    "Note " ..
                    noteName .. " does not exist in this category." )
        return false
    end

    -- Remove the note from the notes table
    self.notes[ noteName ] = nil
    ITTsGhostwriter.Vars.notes[ self.name ].entries[ noteName ] = nil

    logger:Log( 2, "Deleting note %s from category %s", noteName, self.name )
    refreshTree()
    return true
end

function Category:GetAllNotes()
    return self.notes
end

function Category:GetAllNoteNames()
    local names = {}
    logger:Log( 3, "Getting note names for category: %s", self.name )
    for _, note in pairs( self.notes ) do
        logger:Log( 3, "Note instance: %s", tostring( note ) )
        logger:Log( 3, "Note name: %s", note.name )
        table.insert( names, note.name )
    end
    logger:Log( 3, "Returning names: %s", table.concat( names, ", " ) )
    return names
end

-- retrieve note by name
function Category:GetNote( noteName )
    -- Check if the note exists
    if not self.notes[ noteName ] then
        logger:Log( 4,
                    "Note " ..
                    noteName .. " does not exist in this category." )
        return nil
    end

    -- Return the note
    return self.notes[ noteName ]
end

function Category:GetName()
    return self.name
end

function Category:GetIconIndex()
    return self.iconIndex
end

function Category:GetPriority()
    return self.priority
end

function Category:GetTreeNode()
    return self.treeNode
end

function Category:GetManagerInstance()
    return self.manager
end

-- retrieve data for current instance
function Category:GetData()
    return {
        name      = self.name,
        iconIndex = self.iconIndex,
        priority  = self.priority,
        treeNode  = self.treeNode,
        manager   = self.manager,
    }
end

--------------
----Note------
--------------
-- make new note. take name content categoryname treeNode and instance of category
--this should only be called by category:AddNote
function Note:New( name, content, categoryName, treeNode, categoryInstance )
    -- Check if the necessary parameters are provided and are of correct type
    if type( name ) ~= "string" then
        logger:Log( 4,
                    "Invalid parameter provided for 'name'. Expected a string, got " ..
                    type( name ) )
        return nil
    end

    if type( content ) ~= "string" then
        logger:Log( 4,
                    "Invalid parameter provided for 'content'. Expected a string, got " ..
                    type( content ) )
        return nil
    end

    local instance                 = ZO_Object.New( self )
    instance.name                  = name
    instance.content               = content
    instance.categoryName          = categoryName
    instance.treeNode              = treeNode
    instance.categoryInstance      = categoryInstance
    categoryInstance.notes[ name ] = instance
    --instance.db = categoryInstance.db.entries--!this used to somehow work but im scared so im not touching it
    categoryInstance.notes[ name ] = instance
    logger:Log( 1, "Creating a new Note instance with name: " .. name )
    return instance
end

function Note:GetName()
    return self.name
end

function Note:GetContent()
    return self.content
end

function Note:GetCategory()
    return self.categoryName
end

function Note:GetTreeNode()
    return self.treeNode
end

function Note:GetCategoryInstance()
    return self.categoryInstance
end

function Note:GetManagerInstance()
    return self.categoryInstance.manager
end

function Note:GetData()
    return {
        name             = self.name,
        content          = self.content,
        categoryName     = self.categoryName,
        treeNode         = self.treeNode,
        categoryInstance = self.categoryInstance,
    }
end

function Note:SaveNoteToDatabase( note )
    if not self:ValidateNote( note ) then
        logger:Log( 4, "Invalid note or category, returning" )
        return false
    end

    logger:Log( 3, "SaveNoteToDatabase: Note name: %s, Note content: %s",
                note.name, note.content )

    ITTsGhostwriter.Vars.notes[ self.categoryName ].entries[ note.name ] =
        note.content
    --refreshTree() --! crashed me a few times but now i added a check to not add notes which already exist. should be fine but also not needed to refresh the tree here

    return true
end

function Note:GetEntryTable()
    -- Check if the category exists in the database
    if not ITTsGhostwriter.Vars.notes[ self.categoryName ].entries then
        logger:Log( 4,
                    "GetEntryTable: Category %s does not exist in the database.",
                    self.categoryName )
        return nil
    end
    -- Return the entry table
    return ITTsGhostwriter.Vars.notes[ self.categoryName ].entries
end

function Note:ValidateNote( note )
    -- Check if the note has a valid name and category
    if not note.name or note.name == "" then
        logger:Log( 4,
                    "ValidateNote: Invalid note name. Provided value: '%s'. Note name must be a non-empty string.",
                    tostring( note.name ) )
        return false
    end



    logger:Log( 1,
                "ValidateNote: Note is valid. Saving Note name: '%s', Category name: '%s'.",
                note.name, note.categoryName )
    return true
end

------------
--Initiate--
------------
function CategoryManager.Initialize()
    logger.logger:SetEnabled( ITTsGhostwriter.Vars.debugMode )
end

------------
--Testing---
------------
local testLogger = GWLogger:New( "TestCategoryManager" )
local testDb = {
    [ "Category1" ] = {
        name = "Category1",
        iconIndex = 1,
        priority = 1,
        treeNode = {}
    },
    [ "Category2" ] = {
        name = "Category2",
        iconIndex = 2,
        priority = 2,
        treeNode = {}
    },
    [ "Category3" ] = {
        name = "Category3",
        iconIndex = 3,
        priority = 3,
        treeNode = {}
    },
}
local function testAddCategory()
    local manager = CategoryManager:New( testDb )
    local categoryData = {
        name      = "Test",
        iconIndex = 1,
        priority  = 1,
        treeNode  = {
        }
    }

    -- Test adding a new category
    local result = manager:AddCategory( categoryData )
    if result then
        testLogger:Log( 3, "AddCategory: Successfully added new category" )
    else
        testLogger:Log( 5, "AddCategory: Failed to add new category" )
    end

    -- Test adding a category that already exists
    result = manager:AddCategory( categoryData )
    if result then
        testLogger:Log( 5,
                        "AddCategory: Added a category that already exists" )
    else
        testLogger:Log( 3,
                        "AddCategory: Successfully prevented adding a category that already exists" )
    end
end

local function testUpdateCategory()
    local manager = CategoryManager:New( testDb )
    local categoryData = {
        name      = "Test",
        iconIndex = 1,
        priority  = 1,
        treeNode  = {
        }
    }
    manager:AddCategory( categoryData )

    -- Test updating a category
    local newCategoryData = {
        name      = "NewTest",
        iconIndex = 2,
        priority  = 2,
        treeNode  = {
        }
    }
    local result = manager:UpdateCategoryData( "Test", newCategoryData )
    if result then
        testLogger:Log( 3, "UpdateCategory: Successfully updated category" )
    else
        testLogger:Log( 5, "UpdateCategory: Failed to update category" )
    end
    local newCategoryData2 = {
        name      = "Test",
        iconIndex = 2,
        priority  = 2,
        treeNode  = {
        }
    }
    local result2 = manager:UpdateCategoryData( "Test", newCategoryData2 )
    if result2 then
        testLogger:Log( 5,
                        "UpdateCategory: Added a category with the same name" )
    else
        testLogger:Log( 3,
                        "UpdateCategory: Succesfully prevented adding a category with the same name" )
    end
    -- Test updating a category that doesn't exist
    result = manager:UpdateCategoryData( "Nonexistent", newCategoryData )
    if result then
        testLogger:Log( 5,
                        "UpdateCategory: Updated a category that doesn't exist" )
    else
        testLogger:Log( 3,
                        "UpdateCategory: Successfully prevented updating a category that doesn't exist" )
    end
end
local function testMergeCategories()
    local manager = CategoryManager:New( testDb )
    local categoryData1 = {
        name      = "Test1",
        iconIndex = 1,
        priority  = 1,
        treeNode  = {
        }
    }
    local categoryData2 = {
        name      = "Test2",
        iconIndex = 2,
        priority  = 2,
        treeNode  = {
        }
    }
    manager:AddCategory( categoryData1 )
    manager:AddCategory( categoryData2 )

    -- Test merging two categories
    local result = manager:MergeCategories( "Test1", "Test2" )
    if result then
        testLogger:Log( 3, "MergeCategories: Successfully merged categories" )
    else
        testLogger:Log( 5, "MergeCategories: Failed to merge categories" )
    end

    -- Test merging a category that doesn't exist
    result = manager:MergeCategories( "Test1", "Nonexistent" )
    if result then
        testLogger:Log( 5,
                        "MergeCategories: Merged a category that doesn't exist" )
    else
        testLogger:Log( 3,
                        "MergeCategories: Successfully prevented merging a category that doesn't exist" )
    end
end



local function testDeleteCategory()
    local manager = CategoryManager:New( testDb )
    local categoryData = {
        name      = "Test",
        iconIndex = 1,
        priority  = 1,
        treeNode  = {
        }
    }
    manager:AddCategory( categoryData )

    -- Test deleting a category
    local result = manager:DeleteCategory( "Test" )
    if result then
        testLogger:Log( 3, "DeleteCategory: Successfully deleted category" )
    else
        testLogger:Log( 5, "DeleteCategory: Failed to delete category" )
    end

    -- Test deleting a category that doesn't exist
    result = manager:DeleteCategory( "Nonexistent" )
    if result then
        testLogger:Log( 5,
                        "DeleteCategory: Deleted a category that doesn't exist" )
    else
        testLogger:Log( 3,
                        "DeleteCategory: Successfully prevented deleting a category that doesn't exist" )
    end
end
local testDb2 = {
    [ "Category1" ] = {
        name      = "Category1",
        iconIndex = 1,
        priority  = 1,
        treeNode  = {},
        entries   = {
            [ "test1" ] = "test",
            [ "test2" ] = "test",
            [ "test3" ] = "test",
            [ "test4" ] = "test",
            [ "test5" ] = "test",
        }
    },
    [ "Category2" ] = {
        name      = "Category2",
        iconIndex = 2,
        priority  = 2,
        treeNode  = {}
    },
    [ "Category3" ] = {
        name      = "Category3",
        iconIndex = 3,
        priority  = 3,
        treeNode  = {}
    },
}
local function testClearEntries()
    local manager = CategoryManager:New( testDb2 )
    local newCategoryName = "Category1"
    local t = testDb2[ newCategoryName ]
    local categoryData = {
        name = t.name,
        iconIndex = t.iconIndex,
        priority = t.priority,
        treeNode = t.treeNode,
        entries = t.entries
    }
    testLogger:Log( 2, "ClearEntries: Adding a new category with name: %s",
                    t.name )
    manager:IsCategoryDataValid( categoryData )
    manager:AddCategory( categoryData )


    -- Test clearing entries from a category
    local result = manager:ClearEntries( newCategoryName )
    if result then
        testLogger:Log( 3,
                        "ClearEntries: Successfully cleared entries from category" )
    else
        testLogger:Log( 5,
                        "ClearEntries: Failed to clear entries from category" )
    end

    -- Test clearing entries from a category that doesn't exist
    result = manager:ClearEntries( "Nonexistent" )
    if result then
        testLogger:Log( 5,
                        "ClearEntries: Cleared entries from a category that doesn't exist" )
    else
        testLogger:Log( 3,
                        "ClearEntries: Successfully prevented clearing entries from a category that doesn't exist" )
    end
    if ZO_IsTableEmpty( t.entries ) then
        testLogger:Log( 3, "ClearEntries: Category %s is empty",
                        newCategoryName )
    else
        testLogger:Log( 5, "ClearEntries: Category %s is not empty",
                        newCategoryName )
    end
end

-- Run the tests
function ITTsGhostwriter.TestCategoryManager()
    testAddCategory()
    testUpdateCategory()
    testDeleteCategory()
    testMergeCategories()
    testClearEntries()
end
