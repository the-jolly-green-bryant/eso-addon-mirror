-- LibFurnitureCatalogue - Furniture Catalogue database library, startup file

local MAJOR, MINOR = "LibFurnitureCatalogue", 1001000 -- AUTOREPLACED with AddOnVersion

-- set up key maps for "id -> SI_" (used in locale files)
local lib = _G[MAJOR] or {}
_G[MAJOR] = lib
lib.Internal = lib.Internal or {}
lib.Internal.StringKeys = lib.Internal.StringKeys or {}
lib.Internal.RegisterStrings = lib.Internal.RegisterStrings
  or function(strings)
    local keys = lib.Internal.StringKeys
    for stringId, stringValue in pairs(strings) do
      ZO_CreateStringId(stringId, stringValue)
      SafeAddVersion(stringId, 1)
      keys[_G[stringId]] = stringId
    end
  end

if lib.version and lib.version >= MINOR then
  return
end

lib.version = MINOR
lib.name = MAJOR
_G[MAJOR] = lib

lib.API = lib.API or {} -- public API for DB queries and stuff
lib.Internal = lib.Internal or {} -- internal use only

---Single furniture entry, returned by GetEntry and Query.Find
---
---"NOT PROMISED" = delivered but not subject to change
---
---A stored row holds only infos that the game cannot tell us directly: sources, update version, blueprint of an item.
---
--- `origin` is derived from `sources` and the two category fields from the item itself, through one metatable shared by every row (it is the primary source as compatibility attribute)
---
---GetEntry copies the row and puts `origin` onto the copy (copy iterates with `pairs` and `pairs` cannot see derived fields)
---
--- The category fields are not added, use GetFurnitureCategories, or game functions
---@class FurCEntry
---@field id integer the itemId this entry is stored under
---@field sources table<FurCItemSource, boolean> every source this item has, plus the ones a fine-grained source was carved from
---@field origin FurCItemSource NOT PROMISED, top-ranked source, derived from `sources`
---@field version integer game version when the item was added
---@field blueprint integer|nil blueprint itemId, when craftable
---@field furnCategory integer NOT PROMISED, derived. Furniture category id (0 = no category). Absent from a copy
---@field furnSubcategory integer NOT PROMISED, derived. Furniture subcategory id. Absent from a copy
---@field recipeListIndex integer|nil NOT PROMISED. Set only on rows the recipe scan found, pairs with recipeIndex
---@field recipeIndex integer|nil NOT PROMISED. Set only on rows the recipe scan found, pairs with recipeListIndex
---@field compatSources integer|nil NOT PROMISED, deprecated. Bitmask of the `sources` members that exist only for deprecated calls, absent when nothing was injected. Use Internal.Compat.IsInjected to check

-- Runtime furniture database, built per session by the scanner: DB[itemId] = FurCEntry
---@type table<integer, FurCEntry>
lib.Internal.DB = lib.Internal.DB or {}

-- Mark DB dirty after write
lib.Internal.DBRevision = lib.Internal.DBRevision or 0

---@alias LFCDBState "uninitialized"|"building"|"ready"|"failed"

-- DB lifecycle for listeners
local lifecycle = lib.Internal.Lifecycle or {}
lib.Internal.Lifecycle = lifecycle
lifecycle.State = lifecycle.State
  or {
    UNINITIALIZED = "uninitialized",
    BUILDING = "building",
    READY = "ready",
    FAILED = "failed",
  }
lifecycle.current = lifecycle.current
  or (lib.Internal.DBReady == true and lifecycle.State.READY or lifecycle.State.UNINITIALIZED)
lifecycle.readyWaiters = lifecycle.readyWaiters or {}
lifecycle.callbacks = lifecycle.callbacks or {}
lifecycle.notifying = lifecycle.notifying == true
lib.Internal.DBReady = lifecycle.current == lifecycle.State.READY

-- Legacy alias, same table
FurC = FurC or {}
FurC.DB = lib.Internal.DB

-- Optional LibDebugLogger
local noop = function() end
local fallbackLogger = setmetatable({}, {
  __index = function()
    return noop
  end,
})
local logger
function lib.Internal.GetLogger()
  if not logger and LibDebugLogger then
    logger = LibDebugLogger(MAJOR)
  end
  return logger or fallbackLogger
end
