--[[ LibSavedVars saved vars manager class.
     
     LSV_SavedVarsManager:New()
--]]

local LIBNAME      = "LibSavedVars"
local CLASSNAME    = "SavedVarsManager"
local CLASSVERSION = 1.3

-- If a newer version of this class is already loaded, exit
local class, protected = LibSavedVars:LoadClass(CLASSNAME, CLASSVERSION)
if not class then return end
LSV_SavedVarsManager = class

local debugMode = false
local nextId = 1
local extraLazyLoadParams = {}
local extraMigrateParams = {}
local versionUpdateQueue = {}
local managerRegistry = {}


local function localizeMigrateStart(id)
    return LIBNAME.."MigrateStart"..tostring(id)
end
local function localizeLazyLoad(id)
    return LIBNAME.."LazyLoad"..tostring(id)
end

-- Local methods
local fillDefaults, fireLazyLoadCallbacks, onLogout, onLogoutCanceled, unregisterAllLazyLoadCallbacks, 
        unregisterAllMigrateStartCallbacks


---------------------------------------
--
--       Public Methods
-- 
---------------------------------------
--[[ Enables trimming of default values for this saved variables manager.
     
     When enabled, default-valued settings are removed from the raw SavedVariables table during
     logout, allowing ESO to reconstruct them from the defaults table the next time the saved
     variables are loaded. This reduces the size of the SavedVariables file by storing only values
     that differ from their defaults.
     
     If trimming removes every setting from the raw SavedVariables table (other than internal
     metadata such as the version number or last character name), the corresponding SavedVariables
     path is removed entirely.
     
     If logout is canceled after trimming has occurred, the default values are restored
     automatically before gameplay resumes.
     
     Returns:
         The current LSV_SavedVarsManager instance.
     
     Notes:
         - The associated defaults table is specified when the manager is created.
         - Existing settings continue to behave normally when accessed through ZO_SavedVars, even
           when they are omitted from the raw SavedVariables table.
--]]
function LSV_SavedVarsManager:EnableDefaultsTrimming()
    self.isDefaultsTrimmingEnabled = true
    return self
end

--[[ Determines whether this manager's profile is a megaserver profile.
     
     Returns whether the manager's profile name matches one of the megaserver profile names
     recognized by LibSavedVars (for example, "NA Megaserver" or "EU Megaserver"). This is used
     internally to distinguish world-specific profiles from ordinary user-defined profiles when
     loading, migrating, and managing saved variables.
     
     Returns:
         true  if the profile is one of the megaserver profiles returned by
               LibSavedVars:GetWorldNames().
         false otherwise.
     
     Notes:
         - Comparison is performed against the list returned by LibSavedVars:GetWorldNames().
         - A profile with the same text as a world name is considered a megaserver profile.
         - The result depends solely on the profile name and does not verify that the current
           player is logged into that megaserver.
--]]
function LSV_SavedVarsManager:IsProfileWorldName()
    local isProfileWorldName = ZO_IsElementInNumericallyIndexedTable(LibSavedVars:GetWorldNames(), self.profile)
    protected.zoDebug(debugMode, "LSV_SavedVarsManager:IsProfileWorldName() == ", isProfileWorldName,
        " (self.profile==", self.profile, ")")
    return isProfileWorldName
end

--[[ Fires all registered migrate-start callbacks for this saved variables manager.
     
     This method is called immediately before a saved variables migration begins. It loads the
     manager's raw SavedVariables table, invokes every callback previously registered with
     RegisterMigrateStartCallback(), and then automatically unregisters those callbacks so they
     are executed only once.
     
     Each callback receives the raw SavedVariables table being migrated, followed by any
     additional parameters supplied when the callback was registered.
     
     Callback signature:
         function(rawSavedVarsTable, ...)
     
     or, when a callback object was supplied as the first registration parameter:
         function(self, rawSavedVarsTable, ...)
     
     Returns:
         None.
     
     Notes:
         - The raw SavedVariables table is loaded before callbacks are fired.
         - Callbacks are fired through CALLBACK_MANAGER using this manager's unique migration
           callback scope.
         - After all callbacks have been invoked, every callback registered for this manager is
           automatically unregistered.
         - This method is intended for internal use by the migration framework and is normally
           called by protected.Migrate().
--]]
function LSV_SavedVarsManager:FireMigrateStartCallbacks()
    local scope = localizeMigrateStart(self.id)
    protected.zoDebug(debugMode, "LSV_SavedVarsManager:FireMigrateStartCallbacks() scope=", scope)
    local params = extraMigrateParams[self.id]
    local rawSavedVarsTable = self:LoadRawTableData()
    CALLBACK_MANAGER:FireCallbacks(scope, rawSavedVarsTable, params and protected.NilUnpack(params))
    unregisterAllMigrateStartCallbacks(self)
end

--[[ This method ensures that the manager has access to the underlying raw 
    SavedVariables table stored by Elder Scrolls Online. It implements caching 
    optimization if the table references have already been resolved in a previous 
    call, it returns cached values instead of re-querying the game's SavedVariables system.

    Return Values
        Value	Type	      Description
        1	    table	      The raw SavedVariables table containing all persisted settings data
        2	    table	      Parent table object where the raw table resides
        3	    string	      Key name identifying this saved variable within its parent
        4	    table/array	  Path components representing the full hierarchy path to the saved vars table

    Common Use Cases
        * Migration operations - Used internally during version updates and settings 
            migrations to access raw data before applying transforms
        * Settings removal/rename - Called by RemoveSettings() and RenameSettings() 
            to modify the underlying saved vars directly
        * Trimming defaults - Used during logout to compare against default values 
            and prune redundant data 
--]]
function LSV_SavedVarsManager:LoadRawTableData()

    local completeCache =
        (self.rawSavedVarsTable
        and self.rawSavedVarsTableParent
        and self.rawSavedVarsTableKey
        and self.rawSavedVarsTablePath)

    if completeCache then
        return self.rawSavedVarsTable, self.rawSavedVarsTableParent,
               self.rawSavedVarsTableKey, self.rawSavedVarsTablePath
    end

    if not self.table then
        self:Validate()
    end

    if self.keyType == LIBSAVEDVARS_ACCOUNT_KEY then
        self.rawSavedVarsTable, self.rawSavedVarsTableParent, self.rawSavedVarsTableKey, _, self.rawSavedVarsTablePath =
            protected.GetSavedVarsTable(self.name, self.namespace,
                self.profile, self.displayName)
    else
        self.rawSavedVarsTable, self.rawSavedVarsTableParent, self.rawSavedVarsTableKey, _, self.rawSavedVarsTablePath =
            protected.GetSavedVarsTable(self.name, self.namespace, self.profile,
                self.displayName, self.characterName, self.characterId, self.keyType)
    end

    return self.rawSavedVarsTable, self.rawSavedVarsTableParent,
           self.rawSavedVarsTableKey, self.rawSavedVarsTablePath
end

--[[ Get the ZO_SavedVars table that is behind the proxy.]]
function LSV_SavedVarsManager:GetSVTable()
    if not self.table then
        self:Validate()
    end
    return self.table
end

--[[ Registers a callback function to be called whenever a ZO_SavedVars instance is lazy loaded by accessing the 
    savedVars property.
    
    callback:              The callback function to call.  It should have the signature function(savedVarsManager), 
                           where savedVarsManager is the LSV_SavedVarsManager instance doing the lazy loading.
              
    param1:                (optional) if provided and not nil, this will be sent as the first parameter to your 
                                      callback, e.g. function(param1, savedVarsManager).
                                      If you want to call a "self" method, pass in the object instance for the method.
                                      
    ...:                   (optional) Any additional parameters you provide will be passed to the callback after the
                                      savedVarsManager parameter when the lazy load event fires.
                                      e.g. function(param1, savedVarsManager, param2, param3, param4).
--]]
function LSV_SavedVarsManager:RegisterLazyLoadCallback(callback, param1, ...)
    local scope = localizeLazyLoad(self.id)
    protected.zoDebug(debugMode, "LSV_SavedVarsManager:RegisterLazyLoadCallback() scope=", scope)
    if select('#', ...) > 0 then
        extraLazyLoadParams[self.id] = protected.NilPack(...)
    end
    CALLBACK_MANAGER:RegisterCallback(scope, callback, param1)
    return scope
end


--[[ Registers a callback function to be called whenever a migration is started.
    
    callback:              The callback function to call.  It should have the signature function(rawSavedVarsTable), 
                           where rawSavedVarsTable is the Lua table used to store the saved vars being migrated.
              
    param1:                (optional) if provided and not nil, this will be sent as the first parameter to your 
                                      callback, e.g. function(param1, rawSavedVarsTable).
                                      If you want to call a "self" method, pass in the object instance for the method.
                                      
    ...:                   (optional) Any additional parameters you provide will be passed to the callback after the
                                      rawSavedVarsTable parameter when the migrate start event fires.
                                      e.g. function(param1, rawSavedVarsTable, param2, param3, param4).
--]]
function LSV_SavedVarsManager:RegisterMigrateStartCallback(callback, param1, ...)
    local scope = localizeMigrateStart(self.id)
    protected.zoDebug(debugMode, "LSV_SavedVarsManager:RegisterMigrateStartCallback() scope=", scope)
    if select('#', ...) > 0 then
        extraMigrateParams[self.id] = protected.NilPack(...)
    end
    CALLBACK_MANAGER:RegisterCallback(scope, callback, param1)
end

function LSV_SavedVarsManager:SetDebugMode(enable)
    debugMode = enable
    return self
end
function LSV_SavedVarsManager:GetDebugMode()
    return debugMode
end

--[[ Provides a controlled mechanism to delete settings during migration or 
    cleanup operations. The method includes automatic version checking to 
    ensure it only executes when the saved vars are below the target version 
    threshold, and queues the operation for persistence across logout.

    When one or more settings are removed, the manager records the supplied 
    version as the pending saved-vars version. The version is written during 
    logout so the migration is not repeated on subsequent loads.

    Parameters
        Parameter	        Type	                    Description
        version	            number (required)	        Target version number that triggers this removal. 
                                                        Settings are only removed if current saved vars 
                                                        version is below this value.
        settingsToRemove	string or table (required)	Either a single setting name (as string) OR a table/list 
                                                        of setting names to remove
        ...	                variadic (optional)	        Additional setting names appended to form the full 
                                                        removal list

        Note: If settingsToRemove is a string, the variadic arguments (...) become additional entries 
        in a constructed table. This allows flexible calling conventions:

            RemoveSettings(5, "mySetting")                  ? removes "mySetting"
            RemoveSettings(5, {"a", "b", "c"})              ? removes all three settings
            RemoveSettings(5, "first", "second", "third")   ? removes all three via varargs
--]]
function LSV_SavedVarsManager:RemoveSettings(version, settingsToRemove, ...)
    local verType = type(version)
    assert(verType == "number",
        "Invalid type for argument 'version'. Expected 'number'. Got '" .. verType .. "' instead.")

    local srType = type(settingsToRemove)

    if srType ~= "string" and srType ~= "table" then
        return self
    end

    local settings = {}

    if srType == "string" then
        settings[1] = settingsToRemove
    else
        for _, setting in ipairs(settingsToRemove) do
            settings[#settings + 1] = setting
        end
    end

    for _, setting in ipairs({...}) do
        settings[#settings + 1] = setting
    end
    settingsToRemove = settings

    local rawDataTable = self:LoadRawTableData()
    if not rawDataTable then
        protected.zoDebug(debugMode, "Saved vars don't exist. Skipping ", self.rawSavedVarsTablePath)
        return self

    elseif (rawDataTable.version or 0) >= version then
        protected.zoDebug(debugMode, "Version check passed. Skipping ", function() return table.concat({self.rawSavedVarsTablePath}, " > ") end)
        return self
    end
    protected.zoDebug(debugMode, "Raw data table at ", self.rawSavedVarsTablePath, function() 
        return " has ".. NonContiguousCount(rawDataTable) .. " items." end)
    for _, settingToRemove in ipairs(settingsToRemove) do
        protected.zoDebug(debugMode, "Setting rawDataTable['" , settingToRemove, "'] = nil")
        rawDataTable[settingToRemove] = nil
    end
    protected.zoDebug(debugMode, "Raw data table at ", self.rawSavedVarsTablePath,
        " has ", NonContiguousCount(rawDataTable), " items.")
    protected.zoDebug(debugMode, #settingsToRemove, " settings removed.")

    if not self.pendingVersion or self.pendingVersion < version then
        self.pendingVersion = version
        versionUpdateQueue[self.id] = self
    end

    return self
end

--[[ Enables structured refactoring of saved variable schemas during migrations 
    by providing a safe mechanism to rename configuration keys while optionally 
    transforming their associated values. The method ensures idempotent execution 
    through version checking.

    Parameters
        Parameter	Type	            Description
        version	    number optional	    Target version number that triggers this rename. If renameMap 
                                        is provided as the first argument (as a table), this parameter 
                                        is assumed absent. Only executes if current saved vars version 
                                        is below this value.
        renameMap	table (required)	Dictionary mapping old setting names ? new setting names. Each 
                                        key-value pair represents {["oldName"] = "newName"}
        callback	function optional	Transformation function applied to each value during the rename 
                                        operation. Signature: function(originalValue) ? transformedValue
    Returns
        Value	Type	Description
        self	    object	The manager instance itself (enables method chaining)
--]]
function LSV_SavedVarsManager:RenameSettings(version, renameMap, callback)

    if type(version) == "table" then
        renameMap = version
        version = nil
    end

    if version then
        if not self.version or self.version < version then
            self.version = version
        end
    end

    local rawDataTable = self:LoadRawTableData()

    if not rawDataTable then
        return self
    elseif version and rawDataTable.version and rawDataTable.version >= version then
        return self
    end

    local count = 0

    for oldSetting, newSetting in pairs(renameMap) do
        if rawDataTable[oldSetting] ~= nil then
            local value = rawDataTable[oldSetting]

            if callback then
                value = callback(value)
            end

            rawDataTable[newSetting] = value
            rawDataTable[oldSetting] = nil
            count = count + 1
        end
    end

    if version then
        if not self.pendingVersion or self.pendingVersion < version then
            self.pendingVersion = version
            versionUpdateQueue[self.id] = self
        end
    end

    return self
end

--[[ Convenience wrapper that renames setting keys while simultaneously inverting 
    their boolean values in a single atomic operation. Designed specifically for 
    migration scenarios where setting semantics have been negated.

    Parameters
        Parameter	Type	            Description
        version	    number (required)	Target version number that triggers this rename. 
                                        Only executes if current saved vars version is below this value.
        renameMap	table (required)	Dictionary mapping old setting names ? new setting 
                                        names. Each key-value pair represents {["oldName"] = "newName"}
    Returns
        Value	Type	Description
        self	    object	The manager instance itself (enables method chaining)
--]]
function LSV_SavedVarsManager:RenameSettingsAndInvert(version, renameMap)
    protected.zoDebug(debugMode, "LSV_SavedVarsManager:RenameSettingsAndInvert(<<1>>, <<2>>)", version, renameMap)
    return self:RenameSettings(version, renameMap, protected.Invert)
end

--[[ Handles logout processing for this saved variables manager.

     Performs manager-specific cleanup before ESO writes saved variables:
       - Trims values that match their configured defaults.
       - Removes empty saved variable branches after trimming.

     This method operates on the manager's raw saved variable table and
     modifies it in place.

     Notes:
       - The manager must have defaults trimming enabled for cleanup to occur.
       - Raw table access is used intentionally to avoid triggering saved
         variable proxy metatables.
--]]
function LSV_SavedVarsManager:OnLogout()
    if not self.isDefaultsTrimmingEnabled then
        return self
    end

    local rawDataTable, _, _, rawSavedVarsTablePath =
        LSV_SavedVarsManager.LoadRawTableData(self)

    local defaults = self.trimDefaults

    if not rawDataTable or not defaults then
        return self
    end

    protected.TrimDefaults(rawDataTable, defaults)

    -- Remove empty saved variable branches
    local nextKey = nil

    repeat
        nextKey = next(rawDataTable, nextKey)
    until nextKey ~= "version"
        and nextKey ~= "$LastCharacterName"

    if nextKey == nil then
        rawDataTable.version = nil
        rawDataTable["$LastCharacterName"] = nil

        protected.UnsetPath(
            self.table,
            unpack(rawSavedVarsTablePath)
        )
    end
    return self
end

--[[ Applies a pending saved variable version update before logout.

     If a version update has been queued for this manager, the new version
     number is written directly to the raw saved variable table and the
     pending update is cleared.

     Pending versions are deferred until logout so that version changes are
     persisted only after the associated migration or initialization work
     has completed.

     Notes:
       - Updates the raw saved variable storage directly.
       - Safe to call when no pending version exists.
--]]
function LSV_SavedVarsManager:UpdatePendingVersion()
    local pendingVersion = rawget(self, "pendingVersion")

    if not pendingVersion then
        return
    end

    local rawDataTable =
        LSV_SavedVarsManager.LoadRawTableData(self)

    if rawDataTable then
        rawDataTable.version = pendingVersion
    end

    rawset(self, "pendingVersion", nil)
end

--[[ Removes a callback registration for when a ZO_SavedVars instance is lazy loaded by accessing the savedVars property.
    
    callback: The callback function to unregister.
--]]
function LSV_SavedVarsManager:UnregisterLazyLoadCallback(callback)
    local scope = localizeLazyLoad(self.id)
    protected.zoDebug(debugMode, "LSV_SavedVarsManager:UnregisterLazyLoadCallback() scope=", scope)
    CALLBACK_MANAGER:UnregisterCallback(scope, callback)
    extraLazyLoadParams[self.id] = nil
end

--[[ Removes a callback registration for when a migration is started on the given raw saved vars data table.
    
    callback:              The callback function to unregister.
--]]
function LSV_SavedVarsManager:UnregisterMigrateStartCallback(callback)
    local scope = localizeMigrateStart(self.id)
    protected.zoDebug(debugMode, "LSV_SavedVarsManager:UnregisterMigrateStartCallback() scope=", scope)
    CALLBACK_MANAGER:UnregisterCallback(scope, callback)
    extraMigrateParams[self.id] = nil
end

--[[ Validates that the configured SavedVariables table name corresponds to a 
    real, accessible ESO saved variables table, and caches the result for future 
    operations. This initialization check ensures the manager has a valid reference 
    before any read/write operations occur.

    Performs safety validation and lazy-initialization of the manager's table 
    field. By verifying the saved vars table exists before attempting access, 
    this method prevents runtime errors when working with misspelled or non-existent 
    variable namespaces. Results are cached to avoid repeated validation overhead.

    Returns
        Value	Type	    Description
        1	    boolean	    true upon successful validation (failure throws assertion error instead)
        2	    object	    The manager instance itself (enables method chaining)
--]]
function LSV_SavedVarsManager:Validate()
    protected.zoDebug(debugMode, "LSV_SavedVarsManager:Validate()")

    if rawget(self, "table") then
        return true, self
    end

    local savedVarsTable = protected.ValidateSavedVarsTable(rawget(self, "name"))
    if not savedVarsTable then 
        rawset(self, "table", nil)
        return false, self
    end
    rawset(self, "table", savedVarsTable)

    return true, self
end

--[[ Upgrades the saved vars tracked by this loader to the given version number.  
     Has no effect on saved vars at or above the given version.
     
     version:         Settings are only upgraded on saved vars below this version number.
     
     onVersionUpdate: Upgrade script function with the signature function(rawDataTable) end to be run before updating
                      saved vars version.  You can run any settings transforms in here.
--]]
function LSV_SavedVarsManager:Version(version, onVersionUpdate)

    protected.zoDebug(debugMode, "LSV_SavedVarsManager:Version(<<1>>, <<2>>)", version, onVersionUpdate)

    if not self.version or self.version < version then
        self.version = version
    end

    local rawDataTable = self:LoadRawTableData()
    if not rawDataTable then
        protected.zoDebug(debugMode, "Saved vars don't exist. Skipping ", table.concat({self.rawSavedVarsTablePath}, " > "))
        return self

    elseif rawDataTable.version and rawDataTable.version >= version then
        protected.zoDebug(debugMode, "Version check failed. Skipping.")
        return self
    end

    if onVersionUpdate then
        onVersionUpdate(rawDataTable)
    end

    if not self.pendingVersion or self.pendingVersion < version then
        self.pendingVersion = version
        versionUpdateQueue[self.id] = self
    end

    return self
end



---------------------------------------
--
--       Meta methods
-- 
---------------------------------------

--[[ Metamethod implementing lazy creation of the ZO_SavedVars proxy.

    The SavedVarsManager delays construction of the underlying ZO_SavedVars
    object until the `savedVars` field is first accessed. This avoids creating
    unnecessary SavedVariables objects for managers that are only used for
    migration, inspection, or other operations that work directly with the raw
    SavedVariables table.

    When the `savedVars` field is requested, this method:

        1. Validates the SavedVariables table definition.
        2. Applies any pending SavedVariables version update to the raw table.
        3. Creates the appropriate ZO_SavedVars object (account-wide or
           character-specific).
        4. Caches the proxy on the manager.
        5. Fires lazy-load callbacks.
        6. Returns the cached proxy.

    Subsequent accesses return the cached object directly without repeating
    initialization.

    Special Fields
        savedVars       (LSV_SavedVarsManager.savedVars)
            Returns the lazily created ZO_SavedVars proxy used for normal
            settings access. This object provides ESO's metatable-based
            defaults handling and automatic SavedVariables behavior.

    Pending Version Handling
        Migration methods such as RemoveSettings() and RenameSettings() queue
        version updates by storing them in `pendingVersion`. Immediately before
        constructing the ZO_SavedVars proxy, this method writes the pending
        version into the raw SavedVariables table (if one exists), ensuring the
        migration version is persisted while avoiding unnecessary creation of
        the proxy during migration.

    Notes
        * Accessing any manager field other than `savedVars` behaves like a
          normal table lookup.

        * Direct migration and maintenance operations should work with
          LoadRawTableData() rather than the `savedVars` proxy whenever
          metatable behavior is not desired.
--]]
function LSV_SavedVarsManager.__index(manager, key)    

    if not manager or key == nil then
        return
    end

    if key ~= "savedVars" then
        --return class methods and fields, not instance fields
        return LSV_SavedVarsManager[key]
    end

    -- Lazily construct the ZO_SavedVars proxy table (.savedVars).

    if not rawget(manager, "table") then
        manager:Validate()
    end

    local pendingVersion = rawget(manager, "pendingVersion")
    if pendingVersion then
        local rawSavedVarsTable = LSV_SavedVarsManager.LoadRawTableData(manager)
        if rawSavedVarsTable then
            rawSavedVarsTable.version = pendingVersion
        end
        rawset(manager, "pendingVersion", nil)
        versionUpdateQueue[manager.id] = nil
    end

    local savedVars
    if rawget(manager, "keyType") == LIBSAVEDVARS_ACCOUNT_KEY then
        protected.zoDebug(debugMode, "Lazy loading new account wide saved vars.")
        savedVars = ZO_SavedVars:NewAccountWide(rawget(manager, "name"), rawget(manager, "version"), 
                                                rawget(manager, "namespace"), rawget(manager, "defaults"), 
                                                rawget(manager, "profile"), rawget(manager, "displayName"))
    else
        protected.zoDebug(debugMode, "Lazy loading new character-specific saved vars.")
        savedVars = ZO_SavedVars:New(rawget(manager, "name"), rawget(manager, "version"), rawget(manager, "namespace"), 
                                     rawget(manager, "defaults"), rawget(manager, "profile"), rawget(manager, "displayName"), 
                                     rawget(manager, "characterName"), rawget(manager, "characterId"), 
                                     rawget(manager, "keyType"))
    end

    rawset(manager, "savedVars", savedVars)

    fireLazyLoadCallbacks(manager)

    return savedVars
end


---------------------------------------
--
--       Constructors
-- 
---------------------------------------
function LSV_SavedVarsManager:New(data)

    local manager = {
        id                      = nextId,
        name                    = data.name,
        keyType                 = data.keyType or LIBSAVEDVARS_CHARACTER_NAME_KEY,
        version                 = data.version or 1,
        defaults                = data.defaults or {},
        trimDefaults            = data.trimDefaults or data.defaults or {},
        namespace               = data.namespace,
        profile                 = data.profile,
        displayName             = data.displayName or GetDisplayName(),
        table                   = data.table,
        rawSavedVarsTable       = data.rawSavedVarsTable,
        rawSavedVarsTableParent = data.rawSavedVarsTableParent,
        rawSavedVarsTableKey    = data.rawSavedVarsTableKey,
        rawSavedVarsTablePath   = data.rawSavedVarsTablePath,
    }
    if manager.keyType ~= LIBSAVEDVARS_ACCOUNT_KEY then
        manager.characterName = data.characterName or GetUnitName("player")
        manager.characterId   = data.characterId or GetCurrentCharacterId()
    end

    setmetatable(manager, self)

    protected.zoDebug(debugMode, "LSV_SavedVarsManager:New() returning ", manager, " with [table] field = ", manager.table)
    managerRegistry[nextId] = manager

    nextId = nextId + 1

    return manager
end


--[[ Ensures that the underlying raw SavedVariables table exists and returns
    references to it. Unlike LoadRawTableData(), which only searches for an
    existing SavedVariables hierarchy, this method guarantees that the complete
    path has been created before returning.

    The method first attempts to locate the SavedVariables table using
    LoadRawTableData(). If the table already exists, the cached references are
    returned immediately. Otherwise, the required hierarchy is created using
    protected.CreatePath(), the resulting references are cached on the manager,
    and the newly created table is returned.

    This method is intended for operations that must be able to write to the
    underlying SavedVariables structure, even when no settings have previously
    been saved.

    Return Values
        Value   Type        Description
        1       table       The raw SavedVariables table. Guaranteed to exist
                            after this call.
        2       table       Parent table containing the raw SavedVariables table.
        3       string      Key identifying the raw SavedVariables table within
                            its parent.
        4       table       Array containing the SavedVariables lookup path.

    Common Use Cases
        * Initializing a new SavedVariables hierarchy during first use.
        * Creating namespaces before writing migrated settings.
        * Ensuring a destination table exists before copying or importing data.
        * Logout processing that writes changes back to SavedVariables.
        * Any operation that requires writable access to the raw SavedVariables
          table.

    Notes
        * If the SavedVariables table already exists, no new tables are created.
        * The returned table is cached on the manager so subsequent calls avoid
          repeating the lookup or creation process.
        * This method complements LoadRawTableData():
            - LoadRawTableData() locates existing SavedVariables only.
            - EnsureRawTableData() locates the SavedVariables table or creates
                    the complete hierarchy if it does not yet exist.
--]]
function LSV_SavedVarsManager:EnsureRawTableData()

    local raw, parent, key, path = self:LoadRawTableData()
    if raw then
        return raw, parent, key, path
    end

    local savedVars, path1, path2, path3, path4 =
        protected.GetSavedVarsPath(self.name, self.namespace, self.profile,
            self.displayName, self.characterName, self.characterId, self.keyType)

    local created, createdParent, createdKey =
        protected.CreatePath(savedVars, path1, path2, path3, path4)

    self.rawSavedVarsTable       = created
    self.rawSavedVarsTableParent = createdParent
    self.rawSavedVarsTableKey    = createdKey
    self.rawSavedVarsTablePath   = { path1, path2, path3, path4 }

    return created, createdParent, createdKey,
           self.rawSavedVarsTablePath
end



---------------------------------------
--
--       Private Methods
-- 
---------------------------------------
--[[ Recursively populates missing keys in a target table with values from 
    a defaults template. Preserves all existing values while only filling 
    gaps where data is absent, making it ideal for initializing saved variables 
    structures and restoring trimmed defaults after cancelled operations.

    Implements deep merge functionality for configuration restoration. Unlike 
    simple table assignment, this function intelligently navigates nested 
    structures to ensure complete schema conformity without overwriting 
    user-modified settings. Critical for maintaining backwards compatibility 
    when new optional settings are added to addons.
--]]
function fillDefaults(table, defaults)
    if table == nil or type(table) ~= "table" or defaults == nil then
        return
    end
    protected.zoDebug(debugMode, "LSV_SavedVarsManager.fillDefaults(<<1>>, <<2>>)", table, defaults)
    for key, defaultValue in pairs(defaults) do
        if type(defaultValue) == "table" then
            if table[key] == nil then
                table[key] = {}
            end
            fillDefaults(table[key], defaultValue)

        elseif table[key] == nil then
            table[key] = defaultValue
        end
    end
end

--[[ Private helper function that executes all registered lazy-load callbacks 
    associated with a given manager instance, then automatically cleans up 
    their registrations. Triggered when .savedVars property is first accessed 
    on an LSV_SavedVarsManager.

    Implements the event dispatch mechanism for the lazy-loading lifecycle. 
    Ensures addon authors receive notification precisely when their saved 
    variables manager transitions from unloaded to loaded state�typically 
    occurring at first property access rather than at game startup. Automatic 
    cleanup prevents duplicate firing or memory leaks from lingering registrations.
--]]
function fireLazyLoadCallbacks(self)
    local scope = localizeLazyLoad(self.id)
    protected.zoDebug(debugMode, "LSV_SavedVarsManager:fireLazyLoadCallbacks() scope=", scope)
    local params = extraLazyLoadParams[self.id]
    CALLBACK_MANAGER:FireCallbacks(scope, params and protected.NilUnpack(params))
    unregisterAllLazyLoadCallbacks(self)
end

--[[ Update pending version and trim defaults for each of the managers.
--]]
function onLogout()
    for _, manager in pairs(versionUpdateQueue) do
        manager:UpdatePendingVersion()
    end

    versionUpdateQueue = {}

    for _, manager in pairs(managerRegistry) do
        manager:OnLogout()
    end
end

function onLogoutCanceled()
    protected.zoDebug(debugMode, "LSV_SavedVarsManager.onLogoutCanceled()")
    for id, savedVarsManager in pairs(managerRegistry) do
        if savedVarsManager.isDefaultsTrimmingEnabled then
            local rawDataTable, _, _, rawSavedVarsTablePath = LSV_SavedVarsManager.LoadRawTableData(savedVarsManager)
            local defaults = savedVarsManager.trimDefaults
            if rawDataTable and defaults then
                fillDefaults(rawDataTable, defaults)
            end
        end
    end
end

function unregisterAllLazyLoadCallbacks(self)
    local scope = localizeLazyLoad(self.id)
    protected.zoDebug(debugMode, "LSV_SavedVarsManager:unregisterAllLazyLoadCallbacks() scope=", scope)
    CALLBACK_MANAGER:UnregisterAllCallbacks(scope)
    extraLazyLoadParams[self.id] = nil
end

function unregisterAllMigrateStartCallbacks(self)
    local scope = localizeMigrateStart(self.id)
    protected.zoDebug(debugMode, "LSV_SavedVarsManager:unregisterAllMigrateStartCallbacks() scope=", scope)
    CALLBACK_MANAGER:UnregisterAllCallbacks(scope)
    extraMigrateParams[self.id] = nil
end

ZO_PreHook("Logout", onLogout)
ZO_PreHook("Quit", onLogout)
ZO_PreHook("CancelLogout", onLogoutCanceled)