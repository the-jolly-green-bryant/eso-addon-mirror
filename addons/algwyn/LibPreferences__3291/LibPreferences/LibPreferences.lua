--- @alias LAM2GetterFn fun(): any
--- @alias LAM2SetterFn fun(value:any)
--- @alias AccountWideGetterFn fun(self:Preferences): LAM2GetterFn
--- @alias AccountWideSetterFn fun(self:Preferences): LAM2SetterFn
--- @alias GetterFn fun(self:Preferences, name:string): LAM2GetterFn
--- @alias IsEqualGetterFn fun(self:Preferences, name:string, value:any): LAM2GetterFn
--- @alias SetterFn fun(self:Preferences, name:string): LAM2SetterFn
--- @alias IsAccountWideFn fun(self:Preferences): boolean
--- @alias SetAccountWideFn fun(self:Preferences, toggle:boolean)

--- @class LibPreferencesOptions
--- savedVariables version (default 1)
--- @field version number
--- savedVariables profile (default GetWorldName() value)
--- @field profile string
--- savedVariables namespace (default nil)
--- @field namespace string|nil

--- @class LibPreferences
--- @field options LibPreferencesOptions
LibPreferences = {
  options = {
    version = 1,
    profile = GetWorldName(),
    namespace = nil,
  }
}

--- @class PreferencesManager
--- @field account table
--- @field character table
--- @field active table
local PreferencesManager = {}

--- @class Preferences
--- returns true if the preferences are set as account-wide
--- @field IsAccountWide IsAccountWideFn
--- sets if the preferences should be character or account-wide
--- @field SetAccountWide SetAccountWideFn
--- yields a function that returns the preference value
--- @field Getter GetterFn
--- yields a function that returns true if the preference matches the value
--- @field IsEqualGetter IsEqualGetterFn
--- returns a function that sets the preference value
--- @field Setter SetterFn
--- returns a function that checks if the preferences are set to account-wide
--- @field AccountWideGetter AccountWideGetterFn
--- returns a function that sets the preferences to account- of character-wide
--- @field AccountWideSetter AccountWideSetterFn

--- @generic T1 : table, T2 : table
--- @param t1 T1
--- @param t2 T2
--- @return T1|T2
local function tableMerge(t1,t2)
  for key, value in pairs(t2) do
    if type(value) == "table" and type(t1[key] or false) == "table" then
      tableMerge(t1[key], t2[key])
    else
      t1[key] = value
    end
  end
  return t1
end

local function tableMergeLeft(...)
  local target = select(1, ...)
  for i = 2, select("#", ...), 1 do
    tableMerge(target, select(i, ...))
  end
  return target
end

function PreferencesManager:IsAccountWide()
  return self.active == self.account
end

function PreferencesManager:SetAccountWide(toggle)
  self.character.accountWide = toggle
  if toggle == true then
    self.active = self.account
  else
    self.active = self.character
  end
end

function PreferencesManager:AccountWideGetter()
  return function()
    return self:IsAccountWide()
  end
end

function PreferencesManager:AccountWideSetter()
  return function(toggle)
    return self:SetAccountWide(toggle)
  end
end

function PreferencesManager:Getter(name)
  return function()
    return self.active[name]
  end
end

function PreferencesManager:Setter(name)
  return function(value)
    self.active[name] = value
  end
end

function PreferencesManager:IsEqualGetter(name, value)
  return function()
    return self.active[name] == value
  end
end

function PreferencesManager:__index(key)
  if PreferencesManager[key] then
    return PreferencesManager[key]
  end

  return self.active[key]
end

function PreferencesManager:__newindex(key, value)
  -- set both if this is a new variable
  if self.account[key] == nil and self.character[key] == nil then
    self.account[key] = value
    self.character[key] = value
  else
    self.active[key] = value
  end
end

--- @generic T : table
--- @param savedVariableTable string
--- @param defaults T|nil
--- @param options LibPreferencesOptions
--- @return T|Preferences
function LibPreferences.New(savedVariableTable, defaults, options)
  assert(savedVariableTable, "savedVariableTable must be provided")
  assert(type(savedVariableTable) == "string", "savedVariableTable must be a string")
  assert(string.len(savedVariableTable or "") > 0, "savedVariableTable must be a non-empty string")
  assert(type(defaults) == "nil" or type(defaults) == "table", "defaults must be a table or nil")
  assert(type(options) == "nil" or type(options) == "table", "options must be a table or nil")

  defaults = defaults or {}
  options = tableMergeLeft({}, LibPreferences.options, options or {})

  local accountDefaults = tableMerge({}, defaults)
  local characterDefaults = tableMerge({ accountWide = false }, defaults)
  --- @type LibPreferencesOptions
  local preferences = {
    account = ZO_SavedVars:NewAccountWide(
      savedVariableTable,
      options.version,
      options.namespace,
      accountDefaults,
      options.profile
    ),
    character = ZO_SavedVars:NewCharacterIdSettings(
      savedVariableTable,
      options.version,
      options.namespace,
      characterDefaults,
      options.profile
    ),
  }

  if preferences.character.accountWide == true then
    preferences.active = preferences.account
  else
    preferences.active = preferences.character
  end

  setmetatable(preferences, PreferencesManager)

  return preferences
end
