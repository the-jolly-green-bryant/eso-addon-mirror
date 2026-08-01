SavedVariablesManager = {
	name = "SavedVariablesManager",
	version = "1.0",
	db = {}, -- saved variables map (user friendly name => lua table name)
}

local M = SavedVariablesManager
local NAME = M.name
local SV = nil -- saved variables
local EM = EVENT_MANAGER

local profile = "Default" -- atm we handle only the default profile (are there even addons that use several profiles?)

local WORLD = GetWorldName()
if WORLD == "EU Megaserver" then
	WORLD = "EU"
elseif WORLD == "NA Megaserver" then
	WORLD = "NA"
end

-- There is no way to automatically match saved variables tables and their addons, so by default we just show table names of loaded saved variables.
-- Ideally, each addon should register its saved variables by calling SavedVariablesManager.Register("AddonName", "TableName"),
-- but I doubt anyone will bother. So here is the list of custom aliases for some addons.
-- Most saved variables don't even needed aliases, because they have obvious names.
local aliases = {
	["HodorReflexesSV"] = "Hodor Reflexes",
	["AGX2_Account"] = "Alpha Gear (Account)",
	["AGX2_Character"] = "Alpha Gear (Character)",
	-- Excluded tables.
	["ZO_Ingame_SavedVariables"] = false, -- ZOS stuff
	["CombatAlertsSavedVariables"] = false, -- everything is global
}

-- Returns a nested table by path (list of keys).
-- (copied from https://github.com/esoui/esoui/blob/master/esoui/libraries/utility/zo_savedvars.lua#L74 )
local function SearchPath(t, ...)
	if type(t) ~= "table" then return end
    local current = t
    for i = 1, select("#", ...) do
        local key = select(i, ...)
        if key ~= nil then
            if not current[key] then
                return
            end
            current = current[key]
        end
    end
    return current
end

-- Creates a nested table by path (creates needed keys if they are missing).
local function CreatePath(t, ...)
	if type(t) ~= "table" then return end
    local current = t
    local container
    local containerKey
    for i=1, select("#", ...) do
        local key = select(i, ...)
        if key ~= nil then
            if not current[key] then
                current[key] = {}
            end
            container = current
            containerKey = key
            current = current[key]
        end
    end

    return current, container, containerKey
end

-- Assigns new value to path inside table t.
local function SetPath(t, value, ...)
	if type(t) ~= "table" then return end
    if value ~= nil then
        CreatePath(t, ...)
    end
    local current = t
    local parent
    local lastKey
    for i = 1, select("#", ...) do
        local key = select(i, ...)
        if key ~= nil then
            lastKey = key
            parent = current
            if current == nil then
                return false
            end
            current = current[key]
        end
    end
    if parent ~= nil then
		if type(value) == "table" then
			-- Create a new table, because we don't need anything from the old one,
			-- but we also don't simply assign the new value to be able to modify the new table separately.
			local t = {}
			for k, v in pairs(value) do
				t[k] = v
			end
			-- We don't want to override $LastCharacterName value when copying character tables.
			-- If parent doesn't have this key, then nil will be assigned, which means the new key in t won't be created.
			t["$LastCharacterName"] = parent[lastKey]["$LastCharacterName"]
			parent[lastKey] = t
		else
			parent[lastKey] = value
		end
		return true
    end
	return false
end

-- Register a new addon and its saved variables.
-- Some addons can have multiple tables of saved variables. In this case just give them different (sensible) names, e.g.:
-- MyAddon (General) => MyAddon_SavedVariables1, MyAddon (Notifications) => MyAddon_SavedVariables2.
function M.Register(addonName, tableName)
	if not tableName then
		tableName = addonName
		if aliases[addonName] then
			addonName = aliases[addonName]
		end
	end
	if aliases[tableName] ~= false and _G[tableName] and _G[tableName][profile] then
		if M.db[tableName] then M.db[tableName] = nil end
		M.db[addonName] = tableName
	end
end

-- Loaded addons and their saved variables.
function M.GetAddons()
	return M.db
end

-- Returns saved variables for addon.
function M.GetTable(addonName)
	return _G[M.db[addonName]]
end

-- Returns a sorted table of @ names.
function M.GetUsers(addonName)
	local t = SearchPath(M.GetTable(addonName), profile) or {}
	local res = {}
	for k in pairs(t) do
		table.insert(res, k)
	end
	table.sort(res)
	return res
end

-- Returns a sorted table of characters.
-- Each character is a table containing character's id, name and full name (server + name).
-- If character's id is not present, then it's replaced with name.
function M.GetCharacters(addonName, user)
	local t = SearchPath(M.GetTable(addonName), profile, user) or {}
	local res = {}
	for k, v in pairs(t) do
		table.insert(res, {id = k, name = v["$LastCharacterName"] or k, full_name = M.GetCharacterName(k, v["$LastCharacterName"])})
	end
	table.sort(res, function(a, b)
		if a.full_name == b.full_name then return a.id < b.id else return a.full_name < b.full_name end
	end)
	return res
end

-- Returns character's name by its id + server name if it's a known character.
function M.GetCharacterName(character, default)
	local data = SV.characters[character]
	if data then
		return string.format("[%s] %s", data.server or "?", data.name or default or character)
	else
		return default or character
	end
end

-- We detect namespaces by the presence of the "version" key in a subtable.
function M.GetNamespaces(addonName, user, character, includeGlobal)
	local t = SearchPath(M.GetTable(addonName), profile, user, character) or {}
	local res = {}
	if includeGlobal then table.insert(res, "*") end
	for k, v in pairs(t) do
		if type(v) == "table" and v["version"] then
			table.insert(res, k)
		end
	end
	table.sort(res)
	return res
end

-- Copy source character to target.
function M.CopyCharacter(addonName, sourceUser, sourceCharacter, targetUser, targetCharacter, namespace)
	if namespace == "*" or namespace == "" then namespace = nil end
	local t = M.GetTable(addonName)
	local v = SearchPath(t, profile, sourceUser, sourceCharacter, namespace) -- value to assign
	if v then
		return SetPath(t, v, profile, targetUser, targetCharacter, namespace)
	end
	return false
end

-- Delete all saved variables for a specified character.
function M.DeleteCharacter(addonName, user, char)
	return SetPath(M.GetTable(addonName), nil, profile, user, char)
end

-- Rename oldName account to newName in ALL saved variables.
function M.RenameUser(oldName, newName)
	local n = 0
	for k in pairs(M.db) do
		local t = M.GetTable(k)
		-- Traverse profiles, although there is usually only the Default one.
		for _, p in pairs(t) do
			if p[oldName] then
				p[newName] = p[oldName]
				p[oldName] = nil
				n = n + 1
			end
		end
	end
	return n
end

-- Delete account from ALL saved variables.
function M.DeleteUser(name)
	local n = 0
	for k in pairs(M.db) do
		local t = M.GetTable(k)
		-- Traverse profiles, although there is usually only the Default one.
		for _, p in pairs(t) do
			if p[name] then
				p[name] = nil
				n = n + 1
			end
		end
	end
	return n
end

local function Initialize()
	-- Saved variables.
	-- We don't need account/character settings, so just use a simple global table.
	if not SavedVariablesManager_Data then SavedVariablesManager_Data = {} end
	SV = SavedVariablesManager_Data

	-- Update player's characters.
	-- We remember them to append server name to each character to avoid ambiguity.
	if not SV.characters then SV.characters = {} end
	for i = 1, GetNumCharacters() do
	   local name, _, _, classId, _, _, id = GetCharacterInfo(i)
	   SV.characters[id] = {name = zo_strformat("<<1>>", name), class = classId, order = i, server = WORLD}
	end

	-- Settings menu.
	M.BuildMenu(SavedVariablesManager_Data)
end

local function OnAddOnLoaded(event, addonName)
	if addonName == NAME then
		EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
		Initialize()
	end
end

EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- Build a list of loaded saved variables by hooking ZO_SavedVars methods.
local function hook(_, savedVariableTable)
	M.Register(savedVariableTable)
end
ZO_PreHook(ZO_SavedVars, "New", hook)
ZO_PreHook(ZO_SavedVars, "NewAccountWide", hook)
ZO_PreHook(ZO_SavedVars, "NewCharacterNameSettings", hook)
ZO_PreHook(ZO_SavedVars, "NewCharacterIdSettings", hook)