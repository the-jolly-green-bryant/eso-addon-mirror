--[[ LibSavedVars protected members.
--]]

local LIBNAME      = "LibSavedVars"
local CLASSVERSION = 1.2

-- If a newer version of this class is already loaded, exit
local protected = LibSavedVars:LoadClass("Protected", CLASSVERSION)
if not protected then return end    -- don't bother to load older class code (or already loaded class code)
LibSavedVars.protected = protected

-- When set to true, enables verbose log messages in the chat window.  
local debugMode = false

--[[ functions borrowed (with permission) from LibSFUtils to perform string concatenation for debug messages. ]]
-- this version of tcstr actually executes functions passed in and converts the returns to a string. The original LibSFUtils
-- version converts a function to "<function>".
local function tcstr(pending, rslt, seen)
    while true do
        local n = #pending
        if n == 0 then
            return rslt
        end

        local v = pending[n]
        pending[n] = nil

        if v == nil then
            rslt[#rslt + 1] = "(nil)"

        elseif type(v) == "table" then
            if seen[v] then
                rslt[#rslt + 1] = "<cycle>"

            else
                seen[v] = true

                for k, v1 in pairs(v) do
                    pending[#pending + 1] = v1
                    pending[#pending + 1] = k
                end
            end

        elseif type(v) == "function" then
            rslt[#rslt + 1] = v() or "(nil)"

        else
            rslt[#rslt + 1] = tostring(v)
        end
    end
end

local rslt_pool = {}
local function str(...)
    for i = 1, #rslt_pool do
        rslt_pool[i] = nil
    end

    local pending = {}

    -- Push backwards because tcstr pops from the end
    for i = select("#", ...), 1, -1 do
        pending[#pending + 1] = select(i, ...)
    end

    tcstr(pending, rslt_pool, {})

    return table.concat(rslt_pool, " ")
end

--[[ ---------- end of borrowed LibSFUtils functions --------------- ]]

--[[ Gets a new merged table with all keys from table1 and table2. If the same key exists in both tables, 
     table1's value is used. Performs shallow copies to fill the merged table.
--]]
function protected.tableMerge(table1, table2)
    -- Early exit optimization: if table2 is invalid, only copy table1
    if not table2 or type(table2) ~= "table" then
        if not table1 or type(table1) ~= "table" then return {} end
        return ZO_ShallowTableCopy(table1)
    end

    local merged
    if not table1 or type(table1) ~= "table" then
        merged = {}
    else
        merged = ZO_ShallowTableCopy(table1)
    end

    for key2, value2 in pairs(table2) do
        if merged[key2] == nil then
            merged[key2] = value2
        end
    end
    return merged
end

--[[ Gets a new merged array table with all values from table1 and table2.
     The table2 values will be appended to table1 values with keys = #merged + key2.
     Performs shallow copies to fill the merged array.
--]]
function protected.arrayMerge(table1, table2)
    local merged
    if not table1 or type(table1) ~= "table" then
        merged = {}
    else
        merged = ZO_ShallowTableCopy(table1)
    end

    if type(table2) == "table" then
        local cnt = #merged
        -- Use ipairs for better performance on sequential arrays
        for idx, value2 in ipairs(table2) do
            merged[cnt + idx] = value2
        end
    end
    return merged
end

--[[ Recursively removes values from a raw saved variables table that are
     identical to their corresponding default values.

     This function modifies `tbl` in place, removing redundant data so that
     only values that differ from the defaults remain. Empty subtables are
     pruned after their contents have been trimmed.

     Parameters:
         tbl         (table) Raw saved variables table to trim.
         defaultTbl  (table) Table containing the default values.

     Notes:
         - `tbl` must be a plain Lua table (not a ZO_SavedVars proxy).
         - Only keys present in `defaultTbl` are considered for removal.
--]]
function protected.TrimDefaults(tbl, defaultTbl)
    if type(tbl) ~= "table" or type(defaultTbl) ~= "table" then
        return
    end

    for key, defaultValue in pairs(defaultTbl) do
        local value = rawget(tbl, key)

        if type(defaultValue) == "table" then
            if type(value) == "table" then
                protected.TrimDefaults(value, defaultValue)

                if next(value) == nil then
                    rawset(tbl, key, nil)
                end
            end

        elseif value == defaultValue then
            rawset(tbl, key, nil)
        end
    end
end

--[[ protected.CreatePath() traverses a nested table hierarchy and creates any 
    missing intermediate tables along the specified path. It is the counterpart 
    to protected.SearchPath(): whereas SearchPath() only locates existing paths, 
    CreatePath() guarantees that the complete path exists before returning the 
    destination table.

    This function is used throughout LibSavedVars whenever new SavedVariables 
    tables or namespaces must be created, particularly during initialization 
    and migration.

    Parameters
        Parameter	Description
        t	        Root table from which the path begins.
        ...	        Sequence of keys describing the desired path.
    Return Values
        current, container, containerKey

        For example,
            SavedVars
            +-- Default
                +-- @Player
                    +-- Settings

        current
            The table located at the final key.
            If any intermediate tables were missing, they have been created before this value is returned.

        container
            The parent table containing the final key.
            If "Settings" is the final key, container refers to
                SavedVars.Default["@Player"]

        containerKey
            The final key within the parent table.
            Using the previous example,
                containerKey == "Settings"

        Situation	        current	    container/parent	containerKey
        Created/found path	table	    containing table	final key
        Collision	        nil	        containing table	collision key
        Invalid root	    nil	        nil	                nil
        Nil key	            nil	        nil	                nil
--]]
function protected.CreatePath(t, ...)
    if type(t) ~= "table" then
        return nil, nil, nil
    end

    local current = t
    local container
    local containerKey

    local count = select("#", ...)

    for i = 1, count do
        local key = select(i, ...)

        if key == nil then
            return nil, nil, nil
        end

        if type(current) ~= "table" then
            return nil, nil, key
        end

        if current[key] == nil then
            current[key] = {}
        elseif type(current[key]) ~= "table" then
            -- Collision: existing value prevents traversal
            return nil, current, key
        end

        container = current
        containerKey = key
        current = current[key]
    end

    return current, container, containerKey
end

--[[ protected.GetSavedVarsPath() is the central routine that converts a logical saved variables 
    definition into the sequence of keys used to locate the data within the SavedVariables table.

    protected.GetSavedVarsTable() is commonly used to:
        * Locate an existing SavedVariables table without creating it.
        * Determine whether a SavedVariables path already exists.
        * Obtain the parent table and final key for subsequent updates.
        * Retrieve the canonical lookup path for later creation with protected.CreatePath().
        * Support migration and initialization routines that need to distinguish between an 
          existing table and one that must be created.
    Parameters
        _Parameter_	            _Description_
        savedVariableTableName	Global SavedVariables table name or the table itself.
        namespace	            Optional namespace beneath the character/account entry.
        profile	Profile name.   Defaults to "Default". Must be a string.
        displayName	            ESO account name (@User).
        characterName	        Character name. nil means account-wide settings.
        characterId	            Numeric character ID.
        characterKeyType	    Determines whether character settings are keyed by name or ID.

    protected.GetSavedVarsPath() is responsible for normalizing all saved-variable location information 
    into a consistent five-level path:

        SavedVariablesTable
        Profile (Default if omitted)
        Display Name (@Account)
        Player Key
            +- "$AccountWide"
            +- Character Name
            +- Character ID
        Namespace (optional)

    Return Values
        return
            rawSavedVarsTable,
            parent,
            key,
            savedVariableTable,
            { path1, path2, path3, path4 }


    Example:
        For example, given
            MyAddonSavedVars
            +- Default
                +- @Player
                    +- $AccountWide
                        +- Settings

        rawSavedVarsTable
            The SavedVariables table found at the requested path.
            Returns nil if the path does not yet exist.

        parent
            MyAddonSavedVars.Default["@Player"]["$AccountWide"]

        key
            Typically this is the namespace.
                key == "Settings"
            If no namespace was supplied, it may instead be the account-wide or character key.

        savedVariableTable
            Equivalent to
                _G[savedVariableTableName]
            after validation.

        Path Array
            The final return value is an array describing the lookup path.
                {
                    "Default",
                    "@Player",
                    "$AccountWide",
                    "Settings"
                }
            This is particularly useful for later calls to protected.CreatePath() when the 
            table must be created.
--]]
function protected.GetSavedVarsPath(savedVariableTableName, namespace, profile, displayName, characterName, characterId, characterKeyType)
    
    local savedVariableTable = protected.ValidateSavedVarsTable(savedVariableTableName)

    profile = profile or "Default"
    if type(profile) ~= "string" then
        error("Profile must be a string", 3)
    end

    local playerName
    if characterName == nil then
        playerName = "$AccountWide"
    else
        playerName = characterKeyType == ZO_SAVED_VARS_CHARACTER_NAME_KEY and characterName or characterId
    end    

    protected.zoDebug(debugMode, "GetSavedVarsPath returning ", tostring(savedVariableTable), profile, displayName, playerName, namespace)

    return savedVariableTable, profile, displayName, playerName, namespace
end

--[[ protected.GetSavedVarsTable() locates the raw SavedVariables table associated with 
        a particular LibSavedVars configuration. It combines the path-building performed by 
        protected.GetSavedVarsPath() with a lookup using protected.SearchPath(), returning 
        both the located table and information about where it exists within the SavedVariables 
        hierarchy.

    Unlike GetSavedVarsPath(), which only computes the lookup path, this function actually 
        attempts to retrieve the table from memory
--]]
function protected.GetSavedVarsTable(savedVariableTableName, namespace, profile, displayName, characterName, characterId, characterKeyType)
    
    local savedVariableTable, path1, path2, path3, path4 = 
        protected.GetSavedVarsPath(savedVariableTableName, namespace, profile, displayName, characterName, characterId, characterKeyType)
    
    local rawSavedVarsTable, parent, key = protected.SearchPath(savedVariableTable, path1, path2, path3, path4)
    return rawSavedVarsTable, parent, key, savedVariableTable, { path1, path2, path3, path4 }
end

--[[ Assuming the given value can be coerced to a boolean, returns the inverse of that value.
--]]
function protected.Invert(value) 
    return not value
end

--[[ protected.NilPack() packs a variable number of arguments into a table while preserving 
    both the number of arguments and any nil values.

    Unlike a simple table constructor ({...}), which loses trailing nil values and cannot 
    distinguish between omitted arguments and explicit nil arguments, NilPack() records the 
    original argument count so the values can later be restored exactly using protected.NilUnpack().

    Returns a table containing:

        Field	Description
        n	    The original number of arguments passed.
        1...n	The packed argument values.

    The n field is essential because Lua's length operator (#) cannot reliably determine the 
    length of tables containing nil values.
--]]
function protected.NilPack(...) 
    return {n=select('#', ...), ...}
end

function protected.NilUnpack(tbl) 
    return unpack(tbl, 1, tbl.n)
end

--[[ Variation of zo_savedvars.lua => SearchPath().
     Traverses a nested table hierarchy and returns the value at the final key,
     along with its containing table and the final key.

     Return values:
       value, parent, key

    Behavior
        Table (t)	Call	                    Returns
        {a={b=5}}	SearchPath(t,"a","b")	    5, t.a, "b"         Existing path
        {a={b=5}}	SearchPath(t,"a","b", nil)	5, t.a, "b"         Ignore final nil keys
        {a={}}	    SearchPath(t,"a","b")	    nil, t.a, "b"       Final key missing
        {a=5}	    SearchPath(t,"a","b")	    nil, nil, "b"       Non-table collision
        {}	        SearchPath(t,"a","b")	    nil, nil, "a"       Missing intermediate key
        nil         SearchPath(t,"a","b")       nil, nil, nil       Nil root table
        {a={b=5}}	SearchPath(t,nil,"b")	    nil, nil, nil       Intermediate nil key
        {b={}}	    SearchPath(t,"a","b")	    nil, nil, "b"       Missing intermediate key
--]]
function protected.SearchPath(t, ...)
    -- Root must be a table
    if type(t) ~= "table" then
        return nil, nil, nil
    end

    local count = select("#", ...)

    -- Remove trailing nil keys
    while count > 0 and select(count, ...) == nil do
        count = count - 1
    end

    -- Must have at least 1 key
    if count == 0 then
        return t, nil, nil
    end

    local current = t
    for i = 1, count do
        local key = select(i, ...)

        -- Nil key in the middle of a path is invalid
        if key == nil then
            return nil, nil, nil
        end

        if type(current) ~= "table" then
            return nil, nil, key
        end

        local isFinalKey = (i == count)
        if isFinalKey then
            return current[key], current, key
        end

        current = current[key]

        if current == nil then
            return nil, nil, key
        end
    end
end

--[[ protected.MaybeSetPath() assigns a value to an existing location within a nested table 
    hierarchy. Unlike protected.CreatePath(), it never creates missing tables. Instead, it 
    attempts to locate the specified path using protected.SearchPath() and performs the assignment 
    only if the parent table already exists.

    This makes the function a safe way to modify or remove an existing entry without accidentally 
    constructing new portions of the SavedVariables hierarchy.

    Parameters
        _Parameter_	_Description_
        t	        Root table from which the search begins.
        value	    Value to assign to the final key. May be nil to remove an entry.
        ...	        Sequence of keys describing the path to the destination.

    Return Value
        Returns the parent table containing the final key.
        If any intermediate level of the path does not exist, the function returns nil and no assignment is performed.
--]]
function protected.MaybeSetPath(t, value, ...)
    protected.zoDebug(debugMode, "MaybeSetPath ", table.concat({...}, " > "), " to ", value)

    local _, parent, lastKey = protected.SearchPath(t, ...)

    if parent ~= nil then
        parent[lastKey] = value
        protected.zoDebug(debugMode, parent, "[", lastKey, "] = ", value)
    end

    return parent
end

--[[ protected.Migrate() copies an existing SavedVariables table from one location to one 
    or more new SavedVariables locations. It is the core migration routine used by 
    LibSavedVars when changing the storage format, moving data to a new namespace, 
    converting between account-wide and character-specific settings, or introducing profiles.

    The function accepts a source SavedVariables definition and one or more destination 
    definitions. After validating each destination, it copies the source table to every 
    destination that does not already exist and marks the migrated data appropriately. 
    If the source has already been migrated, the function performs no data copy.

    Parameters
        defaultKeyType	    Optional default character key type used when the source or destination does not specify one.
        fromSavedVarsInfo	Source SavedVariables definition or an existing LSV_SavedVarsManager.
        toSavedVarsInfo1...	One or more destination SavedVariables definitions or managers.

    Each SavedVariables definition describes the table name, namespace, profile, 
    display name, and key type needed to locate the SavedVariables table.

    Return Values
        toSavedVarsManagers, fromSavedVarsManager

    toSavedVarsManagers
        An array of validated LSV_SavedVarsManager objects representing each destination.
        Returns nil if migration cannot be performed because the source table does not exist.

    fromSavedVarsManager
        The validated manager representing the source SavedVariables definition.
        This is returned regardless of whether migration actually copied any data.
--]]
function protected.Migrate(defaultKeyType, fromSavedVarsInfo, toSavedVarsInfo1, ...)

    local toSavedVarsInfoList = { ... }

    protected.zoDebug(debugMode, "protected.Migrate()")

    -- defaultKeyType is optional
    if type(defaultKeyType) == "table" then
        protected.zoDebug(debugMode, "defaultKeyType is a table. shift params")
        if toSavedVarsInfoList ~= nil then
            table.insert(toSavedVarsInfoList, 1, toSavedVarsInfo1)
        end
        toSavedVarsInfo1 = fromSavedVarsInfo
        fromSavedVarsInfo = defaultKeyType
        defaultKeyType = nil
        protected.zoDebug(debugMode, "defaultKeyType is now nil")
    end

    assert(fromSavedVarsInfo ~= nil, "Missing required parameter 'fromSavedVarsInfo'")
    assert(toSavedVarsInfo1 ~= nil, "Missing required parameter 'toSavedVarsInfo1'.")

    defaultKeyType = defaultKeyType or LIBSAVEDVARS_CHARACTER_NAME_KEY

    protected.zoDebug(debugMode, "defaultKeyType: ",
      (defaultKeyType == LIBSAVEDVARS_ACCOUNT_KEY and "Account-wide"
          or defaultKeyType == LIBSAVEDVARS_CHARACTER_ID_KEY and "Character-ID-specific"
          or "Character-Name-specific"))

    if fromSavedVarsInfo.keyType == nil then
        fromSavedVarsInfo.keyType = defaultKeyType
        protected.zoDebug(debugMode, "From saved vars keyType blank. Setting to default key type.")
    end

    -- Find the raw data table for the source saved vars
    local from = (getmetatable(fromSavedVarsInfo) == LSV_SavedVarsManager and fromSavedVarsInfo) 
                  or LSV_SavedVarsManager:New(fromSavedVarsInfo)
    from:LoadRawTableData()

    -- Don't bother migrating something that isn't there
    if not from.rawSavedVarsTable then
        protected.zoDebug(debugMode, "From raw saved vars table does not exist.  Halt migration.")
        return nil, from
    end

    -- guard against already migrated
    if from.rawSavedVarsTable.libSavedVarsMigrated
        or (from.rawSavedVarsTable[LIBNAME]
            and from.rawSavedVarsTable[LIBNAME].migrated)
    then
        protected.zoDebug(debugMode, "Already migrated. Skipping.")
        return nil, from
    end

    -- Validate destination parameters 
    table.insert(toSavedVarsInfoList, 1, toSavedVarsInfo1)

    protected.zoDebug(debugMode, "#savedVarsInfoList: ", #toSavedVarsInfoList)

    local toParams = { }
    for i, toSavedVarsInfo in ipairs(toSavedVarsInfoList) do
        toSavedVarsInfo.name = toSavedVarsInfo.name or from.name

        if not toSavedVarsInfo.keyType then
            toSavedVarsInfo.keyType = defaultKeyType
            protected.zoDebug(debugMode, "To saved vars ", i, " keyType is blank. Setting to default key type.")
        end
        local to = (getmetatable(toSavedVarsInfo) == LSV_SavedVarsManager and toSavedVarsInfo) 
                   or LSV_SavedVarsManager:New(toSavedVarsInfo)
        to:Validate()
        table.insert(toParams, to)
    end

    protected.zoDebug(debugMode, "Raw saved vars table was not previously migrated by LibSavedVars v2 or v3.")

    -- Fire any registered callbacks for migration start
    from:FireMigrateStartCallbacks()

    protected.zoDebug(debugMode, "Migrate start callbacks fired.")

    -- Copy the source table to each destination
    for i, to in ipairs(toParams) do

        protected.zoDebug(debugMode, "to (", to, ").table = ", to.table)

        -- Lookup path information
        to:LoadRawTableData()
        protected.zoDebug(debugMode, "To saved vars manager ", i, " raw table data loaded.")

        if not to.table then
            protected.zoDebug(debugMode, "To table is nil. How can this be, since we called Validate on it already?")
        end

        -- Create the destination table, if it doesn't exist
        if not to.rawSavedVarsTable then
            local _, rawSavedVarsTableParent, rawSavedVarsTableKey =
                protected.CreatePath(to.table, unpack(to.rawSavedVarsTablePath))
            to.rawSavedVarsTableParent = rawSavedVarsTableParent
            to.rawSavedVarsTableKey = rawSavedVarsTableKey
            to.rawSavedVarsTable = to.rawSavedVarsTableParent[to.rawSavedVarsTableKey]
            protected.zoDebug(debugMode, "To saved vars manager ", i, " raw table data did not exist.  Created.")
        end

        -- Copy the source table to the destination path
        if to.rawSavedVarsTableParent == nil then
            protected.zoDebug(debugMode, "Raw saved vars parent table does not exist.  CreatePath must have failed.")
        else
            protected.zoDebug(debugMode, "Setting to raw saved vars parent table ", i, 
                " (", to.rawSavedVarsTableParent, ") key ", to.rawSavedVarsTableKey,
                " to the from raw saved vars table (", from.rawSavedVarsTable, ")")
            LibSavedVars:DeepSavedVarsCopy(from.rawSavedVarsTable, to.rawSavedVarsTable, true)
            if type(to.rawSavedVarsTable) == "table" then
                to.rawSavedVarsTable.version = from.rawSavedVarsTable.version
            end
        end
    end
    from.rawSavedVarsTable.libSavedVarsMigrated = true

    return toParams, from
end

--[[ protected.MigrateToMegaserverProfiles() migrates an existing SavedVariables table 
    into one or more megaserver-specific profiles. It is a convenience wrapper around 
    protected.Migrate() that automatically creates a destination profile for each ESO 
    megaserver (such as NA and EU) or, optionally, only for the current megaserver.

    This function is primarily intended for addons that originally stored all settings 
    in a single profile but later adopt LibSavedVars' megaserver profile model. It 
    preserves existing user settings while creating the appropriate per-server 
    profile structure.
--]]
function protected.MigrateToMegaserverProfiles(defaultKeyType, fromSavedVarsInfo, copyToAllServers, toSavedVarsInfo)
    
    if defaultKeyType == nil then
        if fromSavedVarsInfo.keyType == nil then
            defaultKeyType            = LIBSAVEDVARS_CHARACTER_NAME_KEY
            fromSavedVarsInfo.keyType = LIBSAVEDVARS_CHARACTER_NAME_KEY
        else
            defaultKeyType = fromSavedVarsInfo.keyType
        end
    end
    
    if toSavedVarsInfo then
        if toSavedVarsInfo.keyType == nil then
            toSavedVarsInfo.keyType = defaultKeyType
        end
    else
        toSavedVarsInfo = ZO_DeepTableCopy(fromSavedVarsInfo)
        toSavedVarsInfo.keyType = defaultKeyType
    end
    
    local isAccountWide = toSavedVarsInfo.keyType == LIBSAVEDVARS_ACCOUNT_KEY
    
    protected.zoDebug(debugMode, "MigrateToMegaserverProfiles performing migration to ",
      (isAccountWide and "account-wide" 
          or toSavedVarsInfo.keyType == LIBSAVEDVARS_CHARACTER_ID_KEY and "character-ID-specific" 
          or "character-name-specific"), " settings.")
    
    local profiles
    if isAccountWide and (copyToAllServers == nil or copyToAllServers)  then
        profiles = LibSavedVars:GetWorldNames()
    else
        profiles = { GetWorldName() }
    end
    if not toSavedVarsInfo.profile then
        toSavedVarsInfo.profile = GetWorldName()
    elseif not ZO_IsElementInNumericallyIndexedTable(profiles, toSavedVarsInfo.profile) then
        table.insert(profiles, 1, toSavedVarsInfo.profile)
    end
    
    protected.zoDebug(debugMode, "#profiles: ", #profiles)
    
    local toSavedVarsInfoList = { }
    for _, profile in ipairs(profiles) do
        protected.zoDebug(debugMode, "profile: ", profile)
        local toProfileSavedVarsInfo = { }
        ZO_ShallowTableCopy(toSavedVarsInfo, toProfileSavedVarsInfo)
        setmetatable (toProfileSavedVarsInfo, getmetatable(toSavedVarsInfo))
        toProfileSavedVarsInfo.profile = profile
        table.insert(toSavedVarsInfoList, toProfileSavedVarsInfo)
    end
    
    protected.zoDebug(debugMode, "#toSavedVarsInfoList: ", #toSavedVarsInfoList)
    
    local toSavedVarsManagers, from = protected.Migrate(defaultKeyType, fromSavedVarsInfo, unpack(toSavedVarsInfoList))
    
    if not toSavedVarsManagers then
        protected.zoDebug(debugMode, "toSavedVarsManagers is nil. Exiting MegaServer profiles migration.")
        return nil, from
    end
    local toSavedVarsManagersByProfile = { }
    for i, to in ipairs(toSavedVarsManagers) do
        local profile = toSavedVarsInfoList[i].profile
        toSavedVarsManagersByProfile[profile] = to
        
        protected.zoDebug(debugMode, "Saved vars manager detected for ", to.name, " (", 
                _G[to.name], ") profile ", profile, ": path ", 
                (to.rawSavedVarsTablePath and table.concat(to.rawSavedVarsTablePath, " > ") or ""),
                " at index ", i)
    end
    return toSavedVarsManagersByProfile, from
end

--[[ protected.UnsetPath() removes a value from a nested table hierarchy and then 
    recursively removes any parent tables that become empty as a result. It provides 
    a safe cleanup mechanism for SavedVariables, ensuring that deleting a leaf node 
    does not leave behind empty tables.

    Unlike directly assigning nil to a table entry, UnsetPath() prunes the hierarchy 
    upward until it reaches a table that still contains other entries or the root of 
    the hierarchy.
--]]
function protected.UnsetPath(tbl, ...)
    if type(tbl) ~= "table" then return end

    local count = select("#", ...)
    if count == 0 then return end

    -- Use local stack tracking for better performance
    local parents = {}
    local keys = {}

    local current = tbl

    -- Walk to the parent of the final key.
    for i = 1, count - 1 do
        if type(current) ~= "table" then return end

        parents[i] = current
        keys[i] = select(i, ...)
        current = current[keys[i]]
    end

    if type(current) ~= "table" then return end

    -- Remove the leaf.
    current[select(count, ...)] = nil

    -- Prune empty ancestor tables upwards efficiently
    for i = count - 1, 1, -1 do
        -- Only prune if the child table is now empty
        if next(current) == nil then
            local parent = parents[i]
            parent[keys[i]] = nil
            current = parent
        else
            -- Stop pruning when we hit a table with content
            break
        end
    end
end

--[[ protected.ValidateSavedVarsTable() verifies that a SavedVariables table is valid 
    and returns it as a Lua table. The function accepts either a table reference or 
    the name of a global SavedVariables table. When given a table name that does not 
    yet exist, it automatically creates an empty global table.

    This function provides a consistent entry point for all LibSavedVars routines 
    that operate on SavedVariables, ensuring they always receive a valid table before 
    continuing.

    Return Value
        Returns a valid Lua table representing the SavedVariables root.
        If validation fails, the function returns nil.
--]]
function protected.ValidateSavedVarsTable(savedVariableTable)
    protected.zoDebug(debugMode, "ValidateSavedVarsTable(", savedVariableTable, ")")
    local svtype = type(savedVariableTable)
    local svTable = savedVariableTable
    if svtype == "string" then
        if _G[savedVariableTable] == nil then
            protected.zoDebug(debugMode, "No global of that name exists. Creating.")
            _G[savedVariableTable] = {}
        end
        svTable = _G[savedVariableTable]
    end

    if type(svTable) ~= "table" then
        return nil
        --error("Can only apply saved variables to a table", 3)
    end
    protected.zoDebug(debugMode, "ValidateSavedVarsTable returning ", svTable)
    return svTable
end

--[[ Outputs a formatted debug message when debug mode is enabled.

    Now is a thin wrapper around protected.zoDebug() where the force parameter is
    used as the debugMode parameter of zoDebug. The older function is provided for
    compatibility.
     
     Parameters
         message     string (required)
             The message text or an ESO `zo_strformat()` format string.
         
         force       boolean (optional)
             If `true`, the message is displayed even when debug mode is
             disabled. If `false` or `nil`, output occurs only when debug mode
             is enabled.
         
         ...         any (optional)
             Additional values used to replace `<<1>>`, `<<2>>`, etc. in the
             format string. Each value is converted to a string automatically.
     
     Returns
         None.
--]]
function protected.Debug(message, force, ...)
    if not force then return end

    protected.zoDebug(true, message, ...)
end
--[[ original version
function protected.Debug(message, force, ...)
    if not force and not debugMode then 
       return
    end
    if select("#", ...) > 0 then
        local params = {...}
        for i = 1,#params do
            params[i] = tostring(params[i])
        end
        message = zo_strformat(message, unpack(params))
    end
    message = zo_strformat("|c99CCEF<<1>>|r|cFFFFFF: <<2>>|r", "LibSavedVars", message)
    d(message)
end
--]]

--[[ Outputs a formatted debug message when the supplied debug mode flag is
     enabled.
     
     The function supports three message styles:
     
         1. Simple message
            protected.zoDebug(true, "Library initialized")
     
         2. Message concatenation
            protected.zoDebug(true, "Loaded ", count, " settings")
     
         3. ESO format strings
            protected.zoDebug(
                true,
                "Migrated <<1>> settings for <<2>>",
                count,
                accountName
            )
         4. Functions taking no parameters which return a single simple value
            (string, number, boolean, nil) when executed. Allows deferring
            execution to only when the debugMode is turned on.
            protected.zoDebug(true, function() return #uppertable end)
     
     When multiple arguments are supplied, the function checks whether the
     message contains ESO-style placeholders (`<<1>>`, `<<2>>`, etc.). If so,
     the message is formatted using `zo_strformat()`. Otherwise, all arguments
     are concatenated into a single string.
     
     All non-string values are automatically converted to strings.
     
     Output is prefixed with the library name and colorized for easier
     identification in the chat window.
     
     Parameters
         dbgMode     boolean (required)
             If `true`, the message is displayed. If `false` or `nil`, the
             function returns immediately without performing any formatting.
         
         message     any (required)
             The base message text, format string, or value to output.
         
         ...         any (optional)
             Additional values used either for concatenation or for replacing
             `<<1>>`, `<<2>>`, etc. in a format string.
     
     Returns
         None.
     
     Notes
         - Messages containing ESO format placeholders are processed with
           `zo_strformat()`.
         - Messages without placeholders are concatenated using the internal
           `str()` helper.
         - Output is sent through `d()`, which may be redirected by debugging
           libraries such as LibLogDebug.
--]]
--local prefix = zo_strformat("|c99CCEF[<<1>>]|r: ", LIBNAME)
local prefix = str("|c99CCEF[",LIBNAME,"]|r: ")
local function zoDebug(dbgMode, message, ...)
    -- Check debugMode once upfront to avoid unnecessary string operations
    if not dbgMode then return end
    if message == nil then return end

    if type(message) == "string" and message:find("<<%d+>>", 1) then
        -- contains <<number>>
        local paramCount = select("#", ...)
        local params = {}
        for i = 1, paramCount do
            params[i] = tostring((select(i, ...)))
        end
        message = zo_strformat(message, unpack(params))
        message = str(prefix, message)

    else
        -- not a format string
        message = str(prefix, message, ...)
    end

    d(message)      -- original sends to old chat d() func might be redirected by LibLogDebug
    --CHAT_SYSTEM.AddMessage(message)       -- goes to chat regardless of LibLogDebug
end
protected.zoDebug = zoDebug


