-- BuildTracker_Data.lua
--
-- Build CRUD (create/read/update/delete) and per-slot set assignment.
-- This is pure data logic with no UI dependency, so it can be exercised
-- entirely through slash commands while the full paperdoll UI doesn't exist yet.

BuildTracker = BuildTracker or {}
BuildTracker.Data = {}

local Data = BuildTracker.Data
local sv -- shorthand to the live SavedVariables table, set in Initialize

-- ---------------------------------------------------------------------------
-- Bootstrapping
-- ---------------------------------------------------------------------------

local DEFAULT_SAVED_VARS = {
    version = BuildTracker.savedVarsVersion,
    builds = {},      -- [buildId] = buildTable
    settings = {
        notifyOnLoot = true,       -- master toggle, see BuildTracker_Notifications.lua
        notifyOnLootSelf = true,   -- alert when you personally loot a needed piece
        notifyOnLootGroup = true,  -- alert when a groupmate loots one (Need/Greed, Round Robin)
        -- Gold for your own loot, light blue for a groupmate's - distinct at
        -- a glance in a busy dungeon chat log. Stored as 0-1 floats to match
        -- LibAddonMenu-2.0's colorpicker getFunc/setFunc signature directly.
        selfLootColor = { r = 1, g = 0.84, b = 0 },
        groupLootColor = { r = 0.3, g = 0.7, b = 1 },
        showDebugCommands = false, -- hides the /bt debug* diagnostic commands from PrintUsage() until opted into
        lastSelectedBuildId = nil, -- last build shown in the paperdoll, see GetDefaultBuildId
    },
}

function Data.Initialize()
    -- Account-wide saved vars so a build made on one character is visible on
    -- all of them - that's almost certainly what users expect from a build
    -- planner. ZO_SavedVars handles the namespacing/versioning boilerplate.
    BuildTracker_SavedVariables = BuildTracker_SavedVariables or {}
    sv = ZO_SavedVars:NewAccountWide("BuildTracker_SavedVariables", BuildTracker.savedVarsVersion, nil, DEFAULT_SAVED_VARS)
    Data.sv = sv
end

-- Finds the lowest unused positive integer id, so deleting build #1 means
-- the next created build fills that gap instead of always growing the
-- highest number. Safe to do because nothing else in the addon stores a
-- build id anywhere outside the builds table itself; if a future feature
-- ever keeps a standing reference to "the active build's id" or similar,
-- this would need revisiting so a deleted+reused id can't silently point
-- a stale reference at the wrong build.
local function GetNextAvailableId()
    local n = 1
    while sv.builds[tostring(n)] do
        n = n + 1
    end
    return tostring(n)
end

-- ---------------------------------------------------------------------------
-- Build CRUD
-- ---------------------------------------------------------------------------

-- Returns the new build's id.
function Data.CreateBuild(name)
    name = (name and name ~= "") and name or "Unnamed Build"
    local id = GetNextAvailableId()

    sv.builds[id] = {
        id = id,
        name = name,
        created = GetTimeStamp(),
        modified = GetTimeStamp(),
        slots = {},   -- [equipSlotId] = { setId = n, itemId = n, equipType = n, armorType = n, weaponType = n }
        notes = "",
    }

    CALLBACK_MANAGER:FireCallbacks(BuildTracker.EVENTS.BUILD_CREATED, id)
    BuildTracker.Debug("Created build %s (%s)", id, name)
    return id
end

-- Deletes a build and renumbers every higher-numbered build down by one, so
-- ids stay dense/consecutive instead of leaving a gap (deleting #5 out of
-- #1-8 makes the old #6 the new #5, old #7 the new #6, etc.) - user-
-- requested, so a numbered list stays easy to reason about after deletions.
-- Safe to do (per the id-reuse note on GetNextAvailableId above) since
-- nothing holds a build id across calls except sv.settings.lastSelectedBuildId,
-- which is remapped below.
function Data.DeleteBuild(buildId)
    if not sv.builds[buildId] then
        return false, "No build with that id"
    end
    sv.builds[buildId] = nil

    local deletedNum = tonumber(buildId)
    local toShiftDown = {}
    for idStr, build in pairs(sv.builds) do
        local num = tonumber(idStr)
        if num > deletedNum then
            table.insert(toShiftDown, { oldIdStr = idStr, num = num, build = build })
        end
    end
    table.sort(toShiftDown, function(a, b) return a.num < b.num end)

    -- Ascending order matters: each shift frees its old key before the next
    -- (higher) entry tries to claim it, so there's never a key collision.
    local oldToNew = {}
    for _, entry in ipairs(toShiftDown) do
        local newIdStr = tostring(entry.num - 1)
        sv.builds[entry.oldIdStr] = nil
        entry.build.id = newIdStr
        sv.builds[newIdStr] = entry.build
        oldToNew[entry.oldIdStr] = newIdStr
    end

    if sv.settings.lastSelectedBuildId == buildId then
        sv.settings.lastSelectedBuildId = nil
    elseif oldToNew[sv.settings.lastSelectedBuildId] then
        sv.settings.lastSelectedBuildId = oldToNew[sv.settings.lastSelectedBuildId]
    end

    CALLBACK_MANAGER:FireCallbacks(BuildTracker.EVENTS.BUILD_DELETED, buildId)
    return true
end

-- Deletes buildId and returns the id of whichever build now occupies the
-- same position in the sorted list (or the new last entry if the deleted
-- build was last, or nil if none remain) - lets a delete button stay "in
-- place" for quick mass-deletes instead of jumping back to the first build
-- every time.
function Data.DeleteBuildAndGetNext(buildId)
    local before = Data.GetAllBuildsSorted()
    local deletedIndex
    for i, b in ipairs(before) do
        if b.id == buildId then
            deletedIndex = i
            break
        end
    end

    local ok, err = Data.DeleteBuild(buildId)
    if not ok then return nil, err end
    if not deletedIndex then return nil end -- shouldn't happen; buildId existed a moment ago

    local after = Data.GetAllBuildsSorted()
    if #after == 0 then return nil end
    return after[math.min(deletedIndex, #after)].id
end

function Data.DuplicateBuild(buildId, newName)
    local original = sv.builds[buildId]
    if not original then
        return nil, "No build with that id"
    end

    local newId = GetNextAvailableId()

    local copy = ZO_DeepTableCopy(original)
    copy.id = newId
    copy.name = (newName and newName ~= "") and newName or (original.name .. " (Copy)")
    copy.created = GetTimeStamp()
    copy.modified = GetTimeStamp()

    sv.builds[newId] = copy
    CALLBACK_MANAGER:FireCallbacks(BuildTracker.EVENTS.BUILD_CREATED, newId)
    return newId
end

function Data.RenameBuild(buildId, newName)
    local build = sv.builds[buildId]
    if not build then
        return false, "No build with that id"
    end
    if not newName or newName == "" then
        return false, "Name cannot be empty"
    end
    build.name = newName
    build.modified = GetTimeStamp()
    CALLBACK_MANAGER:FireCallbacks(BuildTracker.EVENTS.BUILD_RENAMED, buildId)
    return true
end

function Data.GetBuild(buildId)
    return sv.builds[buildId]
end

-- Returns an array of {id=, name=, modified=} sorted by build id (numeric,
-- ascending) - so builds show up in the order they were created rather than
-- reshuffling alphabetically as names change.
function Data.GetAllBuildsSorted()
    local list = {}
    for id, build in pairs(sv.builds) do
        table.insert(list, { id = id, name = build.name, modified = build.modified })
    end
    table.sort(list, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
    return list
end

-- Remembers which build was last shown in the paperdoll, so reopening it
-- (new session or otherwise) picks up where the user left off instead of
-- always resetting to the same default. Persisted account-wide like
-- everything else in this addon.
function Data.GetLastSelectedBuildId()
    local id = sv.settings.lastSelectedBuildId
    if id and Data.GetBuild(id) then
        return id
    end
    return nil -- unset, or the remembered build was since deleted
end

function Data.SetLastSelectedBuildId(buildId)
    sv.settings.lastSelectedBuildId = buildId
end

-- Loot-alert settings (BuildTracker_Notifications.lua) - three independent
-- flags rather than one nested table, matching this file's existing flat
-- sv.settings.* style. Exposed as getter/setter pairs (rather than letting
-- other files reach into sv directly, which is private to this file) so
-- they can be handed straight to LibAddonMenu-2.0 as getFunc/setFunc.
function Data.GetNotifyOnLoot() return sv.settings.notifyOnLoot end
function Data.SetNotifyOnLoot(value) sv.settings.notifyOnLoot = value end
function Data.GetNotifyOnLootSelf() return sv.settings.notifyOnLootSelf end
function Data.SetNotifyOnLootSelf(value) sv.settings.notifyOnLootSelf = value end
function Data.GetNotifyOnLootGroup() return sv.settings.notifyOnLootGroup end
function Data.SetNotifyOnLootGroup(value) sv.settings.notifyOnLootGroup = value end

-- Alert text colors, one per looter (self vs groupmate) - returned/accepted
-- as separate r,g,b floats (0-1) to match LibAddonMenu-2.0's colorpicker
-- getFunc/setFunc signature exactly, so these can be handed to it directly.
function Data.GetSelfLootColor()
    local c = sv.settings.selfLootColor
    return c.r, c.g, c.b
end
function Data.SetSelfLootColor(r, g, b)
    sv.settings.selfLootColor.r, sv.settings.selfLootColor.g, sv.settings.selfLootColor.b = r, g, b
end
function Data.GetGroupLootColor()
    local c = sv.settings.groupLootColor
    return c.r, c.g, c.b
end
function Data.SetGroupLootColor(r, g, b)
    sv.settings.groupLootColor.r, sv.settings.groupLootColor.g, sv.settings.groupLootColor.b = r, g, b
end

-- Whether the /bt debug* diagnostic commands (debuglibsets, debugitem,
-- debugfindpiece, debugcollection, debugsetitems, debugsource) are listed
-- in PrintUsage() - kept functional either way (still callable directly),
-- just hidden from the default help text so testers who don't need them
-- aren't confronted with a wall of troubleshooting commands.
function Data.GetShowDebugCommands() return sv.settings.showDebugCommands end
function Data.SetShowDebugCommands(value) sv.settings.showDebugCommands = value end

-- Default target for anything that opens the paperdoll without an explicit
-- buildId - the /bt paperdoll slash command and the (optional, unbound by
-- default) paperdoll keybind both need this. Prefers the remembered last
-- selection; falls back to the first (lowest id) build, not the most
-- recently created one, so a freshly-opened dropdown starts at its own
-- first entry rather than always landing on the newest build at the bottom
-- of the list.
function Data.GetDefaultBuildId()
    local remembered = Data.GetLastSelectedBuildId()
    if remembered then return remembered end

    local builds = Data.GetAllBuildsSorted()
    if #builds == 0 then return nil end
    return builds[1].id
end

-- ---------------------------------------------------------------------------
-- Slot assignment
-- ---------------------------------------------------------------------------

-- equipType is the ESO EQUIP_TYPE_* constant. armorType and weaponType are
-- mutually exclusive, both optional (pass nil for jewelry, or to let
-- LibSets default to the set's only/first weight - see
-- BuildTracker.Sets.GetItemIdForSlot for why that default is usually fine).
function Data.SetBuildSlot(buildId, equipSlotId, setId, equipType, armorType, weaponType)
    local build = sv.builds[buildId]
    if not build then
        return false, "No build with that id"
    end

    if not BuildTracker.Sets.SetExists(setId) then
        return false, "Unknown setId " .. tostring(setId)
    end

    local itemId = BuildTracker.Sets.GetItemIdForSlot(setId, equipSlotId, equipType, armorType, weaponType)
    if not itemId then
        return false, "That set has no item for slot " .. tostring(BuildTracker.SLOT_NAMES[equipSlotId] or equipSlotId)
            .. " (if this set has multiple weights/weapon types, try specifying one)"
    end

    build.slots[equipSlotId] = {
        setId = setId,
        itemId = itemId,
        equipType = equipType,
        armorType = armorType,
        weaponType = weaponType,
    }
    build.modified = GetTimeStamp()

    CALLBACK_MANAGER:FireCallbacks(BuildTracker.EVENTS.SLOT_SET, buildId, equipSlotId)
    CALLBACK_MANAGER:FireCallbacks(BuildTracker.EVENTS.BUILD_CHANGED, buildId)
    return true
end

-- Optional trait tag for an already-assigned slot (Divines, Precise, etc.) -
-- purely a display note, unlike equipType/armorType/weaponType above. Real
-- ESO trait doesn't change which itemId you need (you retrait an existing
-- piece at a Transmutation station instead of needing a different item), so
-- this never touches Sets.GetItemIdForSlot/resolution - it's just stored
-- alongside the slot's setId/itemId and shown in the tooltip
-- (BuildTracker_SlotOptionsUI.lua). Pass nil to clear a previously-set trait.
function Data.SetBuildSlotTrait(buildId, equipSlotId, traitType)
    local build = sv.builds[buildId]
    local slotData = build and build.slots[equipSlotId]
    if not slotData then
        return false, "Slot has no assigned set yet"
    end

    slotData.traitType = traitType
    build.modified = GetTimeStamp()
    CALLBACK_MANAGER:FireCallbacks(BuildTracker.EVENTS.SLOT_SET, buildId, equipSlotId)
    CALLBACK_MANAGER:FireCallbacks(BuildTracker.EVENTS.BUILD_CHANGED, buildId)
    return true
end

-- Optional enchantment (glyph effect) tag for an already-assigned slot -
-- same "display note" reasoning as SetBuildSlotTrait: doesn't affect which
-- itemId is needed, just stored alongside it and shown in the tooltip
-- (BuildTracker_SlotOptionsUI.lua). Pass nil to clear a previously-set
-- enchantment.
function Data.SetBuildSlotEnchant(buildId, equipSlotId, enchantId)
    local build = sv.builds[buildId]
    local slotData = build and build.slots[equipSlotId]
    if not slotData then
        return false, "Slot has no assigned set yet"
    end

    slotData.enchantId = enchantId
    build.modified = GetTimeStamp()
    CALLBACK_MANAGER:FireCallbacks(BuildTracker.EVENTS.SLOT_SET, buildId, equipSlotId)
    CALLBACK_MANAGER:FireCallbacks(BuildTracker.EVENTS.BUILD_CHANGED, buildId)
    return true
end

-- Sets a slot directly from a known itemId, bypassing LibSets.GetSetItemId
-- resolution entirely. Use this when LibSets resolves the wrong itemId for
-- a particular set (seen in practice - likely a stale/legacy itemId in its
-- static data table for a set that's since been renumbered). setId and
-- setName are derived straight from the item itself via GetItemLinkSetInfo,
-- so this stays internally consistent even though it skips LibSets.
--
-- equipType/armorType/weaponType are intentionally left unset for slots
-- assigned this way, since we no longer need them to resolve anything.
function Data.SetBuildSlotByItemId(buildId, equipSlotId, itemId)
    local build = sv.builds[buildId]
    if not build then
        return false, "No build with that id"
    end

    local itemLink = BuildTracker.Sets.BuildItemLink(itemId)
    if not itemLink then
        return false, "Could not build an itemLink for itemId " .. tostring(itemId)
    end

    local ok, hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = pcall(GetItemLinkSetInfo, itemLink, false)
    if not ok or not hasSet then
        return false, "itemId " .. tostring(itemId) .. " doesn't appear to be part of a set"
    end

    build.slots[equipSlotId] = {
        setId = setId,
        itemId = itemId,
    }
    build.modified = GetTimeStamp()

    CALLBACK_MANAGER:FireCallbacks(BuildTracker.EVENTS.SLOT_SET, buildId, equipSlotId)
    CALLBACK_MANAGER:FireCallbacks(BuildTracker.EVENTS.BUILD_CHANGED, buildId)
    return true
end

function Data.ClearBuildSlot(buildId, equipSlotId)
    local build = sv.builds[buildId]
    if not build then
        return false, "No build with that id"
    end
    build.slots[equipSlotId] = nil
    build.modified = GetTimeStamp()
    CALLBACK_MANAGER:FireCallbacks(BuildTracker.EVENTS.SLOT_CLEARED, buildId, equipSlotId)
    CALLBACK_MANAGER:FireCallbacks(BuildTracker.EVENTS.BUILD_CHANGED, buildId)
    return true
end

-- Flattened, de-duplicated list of every itemId a build requires - this is
-- exactly the input the ownership scanner and the (future) loot notifier need.
function Data.GetRequiredItemIds(buildId)
    local build = sv.builds[buildId]
    if not build then return {} end

    local seen = {}
    local itemIds = {}
    for _, slotData in pairs(build.slots) do
        if slotData.itemId and not seen[slotData.itemId] then
            seen[slotData.itemId] = true
            table.insert(itemIds, slotData.itemId)
        end
    end
    return itemIds
end
