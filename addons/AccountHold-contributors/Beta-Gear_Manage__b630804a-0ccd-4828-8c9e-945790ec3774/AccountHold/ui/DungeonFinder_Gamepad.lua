-- AccountHold/ui/DungeonFinder_Gamepad.lua
--
-- "Quartermaster Dungeons": a Specific-Dungeons-style picker containing ONLY
-- the dungeons the player's Priorities plan says are worth running. Normal and
-- Veteran, a checkmark per row, Select All, X = Join Queue, Y = Quartermaster Queue.
--
-- =========================================================================
-- WHY THIS IS A DIALOG AND NOT A THIRD ENTRY IN THE REAL ACTIVITY FINDER
-- =========================================================================
-- The literal request was "add a 3rd entry to the gamepad Activity Finder".
-- That was investigated to the source and is NOT buildable safely. The
-- blocking evidence, in order of severity:
--
-- 1. A ROOT CATEGORY ENTRY CAN ONLY PUSH A SCENE.
--    zo_activityfinderroot_gamepad.lua:36-58 is the ONLY select handler for
--    the finder's category list. Its whole body is:
--        :47-49   if entryData.onShowingCallback then ... end
--        :51      SCENE_MANAGER:Push(entryData.sceneName)
--    There is no `callback` field on a category entry. A third entry would
--    therefore REQUIRE a custom gamepad scene -- the exact construct that has
--    already failed three times on this player's Xbox
--    (ui/PrioritiesScreen_Gamepad.lua:1060-1076). Approach A cannot be built
--    without rebuilding the thing that is known broken on the target hardware.
--
-- 2. THE CATEGORY LIST IS SORTED, NOT APPENDED.
--    zo_activityfinderroot_gamepad.lua:233-271 AddCategory installs
--    PrioritySort (:234-258) via list:SetSortFunction (:266) and then
--    list:Commit (:270). Inserting re-sorts BASE entries by numeric priority.
--    That is not append-only, and "3rd" is not even a position we could hold.
--
-- 3. EVERY CATEGORY ENTRY IS DEREFERENCED INSIDE BASE RENDER LOOPS.
--    :97-118 CategoryEntrySetup does data:AddIcon(data.data.menuIcon) and
--    .disabledMenuIcon unconditionally; :178-217 RefreshTooltip indexes
--    .activityFinderObject / .isZoneStories / .isGroupFinder; :289-300
--    IsCategoryLocked calls activityFinderObject:GetLevelLockInfo(). A
--    synthetic entry has to satisfy all of it or it throws during a redraw of
--    a screen the player cannot leave.
--
-- 4. THE LOCATION LIST IS UNREACHABLE.
--    zo_activityfindertemplate_gamepad.lua:398-549 RefreshView builds rows
--    through AddLocationEntry, a LOCAL function declared at :418 inside
--    RefreshView -- not hookable. Rows are ZO_ActivityFinderLocation_Specific
--    objects (zo_activityfinderroot_classes.lua:298-378) with ~20 required
--    methods, sourced only from
--    ZO_ACTIVITY_FINDER_ROOT_MANAGER:GetLocationsData (:486-492).
--
-- 5. INJECTED SELECTIONS GET WIPED.
--    zo_activityfindertemplate_gamepad.lua:383-396 RefreshHeaderAndView calls
--    ZO_ACTIVITY_FINDER_ROOT_MANAGER:ClearSelections() at :386;
--    zo_activityfinderroot_manager.lua:466-474 ClearAndUpdate calls it at :472
--    and is driven by ~15 events registered at :206-237 (level, CP, group,
--    quest, holiday, collectible, gamepad-mode change).
--
-- So: Approach B. This dialog IS the destination the player asked for; it is
-- simply reached from the Priorities X button instead of from a row inside the
-- base finder. Parametric gamepad DIALOGS are the one gamepad construct that
-- has worked first time on this hardware -- two already ship
-- (ui/PrioritiesSetsBook_Gamepad.lua, ui/ArmoryScreen_Gamepad.lua) -- and this
-- file follows them exactly.
--
-- =========================================================================
-- NORMAL vs VETERAN -- the answer, with citations
-- =========================================================================
-- The split is ACTIVITY TYPE. It is NOT SetVeteranDifficulty().
--
--   zo_dungeonfinder_manager.lua:31
--       ZO_ActivityFinderFilterModeData:New(LFG_ACTIVITY_DUNGEON,
--                                           LFG_ACTIVITY_MASTER_DUNGEON)
--     -- the Dungeon Finder's two activity types, in that order.
--
--   zo_activityfindertemplate_gamepad.lua:551-600 RefreshSpecificFilters
--     -- builds ONE TAB PER ACTIVITY TYPE, named GetString("SI_LFGACTIVITY",
--        activityType) (:568). Those tabs ARE "Normal" and "Veteran".
--
--   zo_activityfinderroot_classes.lua:303-314
--     -- a location is constructed from GetActivityIdByTypeAndIndex(
--        activityType, index): the difficulty is baked into the activityId.
--   zo_activityfinderroot_classes.lua:325-327
--     -- AddActivitySearchEntry() -> AddActivityFinderSpecificSearchEntry(
--        self:GetId()). The id is the ONLY thing submitted to the queue.
--   zo_activityfinderroot_manager.lua:617-636 StartSearch
--     -- ClearActivityFinderSearch(), then AddActivitySearchEntry() for every
--        selected location, then StartActivityFinderSearch(). Difficulty is
--        never mentioned.
--
--   veterandifficultysettings.lua:141-143 is the ONLY caller of
--   SetVeteranDifficulty, from a click on the group-difficulty toggle, gated
--   on CanPlayerChangeGroupDifficulty() (:18). That is the GROUP's difficulty
--   for walking into a dungeon manually. It has nothing to do with the finder
--   queue, and calling it here would silently change the player's group
--   settings. We do not call it.
--
-- Consequence for this file: we index dungeon names PER ACTIVITY TYPE and keep
-- two separate name->id maps. src/DungeonQueue.lua:BuildActivityIndex folds all
-- types into ONE map with "first match wins" (:150-155), which is correct for
-- its own "queue my whole plan" job but cannot express a Normal/Veteran split
-- -- so this file builds its own difficulty-scoped index using the same public
-- API and reuses DungeonQueue for the join key, the queue action and the roll.
--
-- =========================================================================
-- WHY THERE ARE NO REAL TABS
-- =========================================================================
-- A gamepad DIALOG cannot host a tab bar. zo_genericdialog_gamepad.lua
-- contains no reference to tabBarEntries and never calls
-- ZO_GamepadGenericHeader_Activate, so a dialog header never takes left/right
-- input; and ZO_GenericGamepadDialog_RefreshText does ZO_ClearTable(headerData)
-- at :414 before writing titleText (:415), so any tabBarEntries we injected
-- would be erased on the next text refresh. The gamepad-idiomatic equivalent
-- is an in-list toggle row, which is what the first row is. It is a ROW rather
-- than a keybind because A / B / X / Y / RESET are all spoken for and this
-- add-on has already crashed a console session by fighting over a keybind
-- (AccountHold/README.md, "Xbox / PS5 quick reference").
--
-- =========================================================================
-- KEYBINDS -- parity with the real finder
-- =========================================================================
--   A  DIALOG_PRIMARY    toggle the checkmark on the highlighted row.
--                        Exact parity: zo_activityfindertemplate_gamepad.lua
--                        :186-205, whose UI_SHORTCUT_PRIMARY callback is
--                        ZO_ACTIVITY_FINDER_ROOT_MANAGER:ToggleLocationSelected
--                        (:202).
--   B  DIALOG_NEGATIVE   close.
--   X  DIALOG_SECONDARY  Join Queue. Parity: the base finder puts JOIN QUEUE on
--                        UI_SHORTCUT_SECONDARY (:283-300).
--   Y  DIALOG_TERTIARY   Quartermaster Queue -> travel, reusing DungeonQueue.PickOne.
--   .  DIALOG_RESET      Select All / Clear All. A real dialog-layer action:
--                        ingame/globals/bindings.xml:749-751.
-- Every one is declared in the dialog's own `buttons` array so the BASE GAME
-- owns the descriptor and resolves collisions; KEYBIND_STRIP is never touched.
--
-- =========================================================================
-- OTHER BASE-GAME CONTRACT USED
-- =========================================================================
--   zo_dialog.lua:1207-1209                 RegisterCustomDialog -> ESO_Dialogs[name]
--   zo_dialog.lua:352-377                   ZO_Dialogs_ShowGamepadDialog (isGamepad only)
--   zo_dialog.lua:604-605                   dialogInfo.setup(dialog, ...) on every show
--   zo_dialog.lua:1247-1256                 blockDialogReleaseOnPress -> WE release
--   zo_genericdialog_gamepad.lua:692        setupFunc = ..._Setup for PARAMETRIC
--   zo_genericdialog_gamepad.lua:736        _Setup immediately walks parametricList
--   zo_genericdialog_gamepad.lua:745        templateData.setup called UNCONDITIONALLY
--   zo_genericdialog_gamepad.lua:782-855    RebuildEntryList
--   zo_genericdialog_gamepad.lua:785        ipairs over dialog.info.parametricList
--   zo_genericdialog_gamepad.lua:788-796    `visible` is read from templateData
--   zo_genericdialog_gamepad.lua:800-807    a `text` FUNCTION is ENTRY-LEVEL only
--   zo_genericdialog_gamepad.lua:816-819    templateData keys copied RAW onto entryData
--   zo_genericdialog_gamepad.lua:825-830    first-seen template defines the header template
--   zo_genericdialog_gamepad.lua:833-839    `header` is entry-level and static
--   zo_genericdialog_gamepad.lua:849-853    reselect=true -> Commit(), keeps the cursor
--   zo_gamepadentrydata.lua:391-393         SetSelected -> self.isSelected
--   zo_gamepadtemplatescommon.lua:420-422   data.isSelected -> status-indicator check
--
-- The checkmark is drawn as a TEXT PREFIX, not only via isSelected. Reason:
-- zo_gamepadtemplatescommon.lua:43 reads control.statusIndicator via
-- GetNamedChild("StatusIndicator"), and ZO_GamepadFullWidthLeftLabelEntryTemplate
-- (zo_gamepadtemplatescommon.xml:253) has no such child -- so the native check
-- would silently never render. We set isSelected anyway (it is free, it is
-- guarded by `if statusIndicator then` at :352, and it feeds narration), but the
-- text prefix is what the player actually sees.
--
-- ESO runs Lua 5.1: no goto, no //, no bitwise operators. Every ZOS global is
-- resolved BY NAME at call time and every base-game touch is pcall'd, so this
-- file LOADS under tests/zos_mock.lua with none of the ZO_* globals present.

AccountHold = AccountHold or {}
AccountHold.UI = AccountHold.UI or {}
AccountHold.UI.DungeonFinderGamepad = AccountHold.UI.DungeonFinderGamepad or {}

local Finder = AccountHold.UI.DungeonFinderGamepad

-- Our dialog. A STRING key in ESO_Dialogs, never an index into anything.
local DIALOG_NAME = "ACCOUNTHOLD_DUNGEON_FINDER_GAMEPAD"
-- One template for every row: zo_genericdialog_gamepad.lua:825-827 makes the
-- FIRST entry using a template define the header template for ALL of them.
local TEMPLATE    = "ZO_GamepadFullWidthLeftLabelEntryTemplate"

-- Difficulty identities are STRINGS. They key the selection table and the row
-- keys, and they are never derived from a numeric constant whose value can move
-- between API versions.
local NORMAL  = "normal"
local VETERAN = "veteran"

-- difficulty -> the LFG activity type global that provides it.
-- zo_dungeonfinder_manager.lua:31.
local TYPE_NAME_FOR_DIFFICULTY = {
    [NORMAL]  = "LFG_ACTIVITY_DUNGEON",
    [VETERAN] = "LFG_ACTIVITY_MASTER_DUNGEON",
}

-- Row kinds. Again strings, never positions: the action rows move whenever the
-- dungeon list changes length.
local ROW_DIFFICULTY = "difficulty"
local ROW_SELECT_ALL = "selectAll"
local ROW_DUNGEON    = "dungeon"
local ROW_MESSAGE    = "message"

Finder._DIALOG_NAME = DIALOG_NAME
Finder._TEMPLATE    = TEMPLATE

Finder.NORMAL  = NORMAL
Finder.VETERAN = VETERAN
Finder.DIFFICULTIES = { NORMAL, VETERAN }
Finder.TYPE_NAME_FOR_DIFFICULTY = TYPE_NAME_FOR_DIFFICULTY

Finder.ROW_DIFFICULTY = ROW_DIFFICULTY
Finder.ROW_SELECT_ALL = ROW_SELECT_ALL
Finder.ROW_DUNGEON    = ROW_DUNGEON
Finder.ROW_MESSAGE    = ROW_MESSAGE

-- ---------------------------------------------------------------------------
-- Guarded primitives
-- ---------------------------------------------------------------------------

local function L(id, fallback)
    if AccountHold and type(AccountHold.L) == "function" then
        local ok, s = pcall(AccountHold.L, id, fallback)
        if ok and type(s) == "string" and s ~= "" then return s end
    end
    return fallback
end

-- Resolve a global BY NAME at call time. Never cache: a constant's numeric
-- value is not published and can move between API versions, and a function may
-- not exist at all on the harness or an older client. Same doctrine as
-- src/Index.lua, src/BuildCreator.lua and ui/ArmoryScreen_Gamepad.lua.
local function gfn(name)
    local v = (type(_G) == "table") and _G[name] or nil
    if type(v) == "function" then return v end
    return nil
end

local function gtable(name)
    local v = (type(_G) == "table") and _G[name] or nil
    if type(v) == "table" then return v end
    return nil
end

local function gvalue(name)
    if type(_G) ~= "table" then return nil end
    return _G[name]
end

-- =============================================================================
-- userdata IS NOT table. READ THIS BEFORE ADDING ANOTHER type() GUARD.
-- =============================================================================
-- ESO exposes two completely different kinds of object to Lua:
--
--   * Lua CLASS INSTANCES (ZO_Object subclasses) -- SCENE_MANAGER, KEYBIND_STRIP,
--     ZO_Scene instances, ZO_GamepadEntryData instances, a parametric list
--     OBJECT. These are `table`.
--
--   * ENGINE OBJECTS -- every control, and the three C++ managers published by
--     esoui/libraries/globals/globalvars.lua:2-4:
--         WINDOW_MANAGER    = GetWindowManager()
--         ANIMATION_MANAGER = GetAnimationManager()
--         EVENT_MANAGER     = GetEventManager()
--     These are `userdata`. The base game itself relies on that distinction:
--         zo_keybindstrip.lua              type(x) == "userdata" -> a control
--         zo_contextmenus.lua SetMenuOwner type(owner) == "userdata"
--         craftingcreateslotanimation.lua  type(slot) == "userdata"
--         debugutils.lua mon()             type(moc()) == "userdata"
--
-- `type(x) == "table"` on either group is ALWAYS FALSE ON HARDWARE and always
-- TRUE under tests/zos_mock.lua, which models them as plain tables. That is the
-- exact shape of bug that has now been found FOUR times in this add-on:
--   1. PrioritiesScreen dialog setup       -> the list was never built.
--   2. Finder.Refresh below                -> the list never redrew on toggle.
--   3. Finder:ScheduleRetry below          -> the retry never fired on console.
--   4. PrioritiesMenu_Gamepad.lua:560      -> type(WINDOW_MANAGER) ~= "table"
--      returned false unconditionally, so the custom scene was NEVER CREATED.
--      That single line -- not any platform limitation -- is why "custom scenes
--      don't work on console" was believed for three releases.
--
-- Use gobject()/isControl() for anything that might be an engine object.
-- gtable() is ONLY for genuine Lua tables (ESO_Dialogs, GAMEPAD_DIALOGS,
-- SCENE_MANAGER, KEYBIND_STRIP, ZO_* class tables).
-- =============================================================================

-- True for anything the engine could hand us: a control, a manager, or the
-- mock's table stand-in. Never rejects on container type alone.
local function isControl(v)
    local t = type(v)
    return (t == "userdata" or t == "table") and true or false
end
Finder._IsControl = isControl

-- Resolve a global that may be a Lua table OR an engine userdata object.
local function gobject(name)
    if type(_G) ~= "table" then return nil end
    local v = _G[name]
    if isControl(v) then return v end
    return nil
end
Finder._GObject = gobject

-- Read a method off a possibly-userdata object without ever throwing. Indexing
-- userdata goes through a C metatable, so it is pcall'd.
local function method(obj, name)
    if not isControl(obj) then return nil end
    local ok, fn = pcall(function() return obj[name] end)
    if ok and type(fn) == "function" then return fn end
    return nil
end
Finder._Method = method

-- Lua 5.1 forbids `...` inside a nested closure, so the varargs are forwarded
-- straight to pcall rather than captured.
local function diag(level, fmt, ...)
    local addonRef = Finder.addon or AccountHold
    if type(addonRef) ~= "table" or type(addonRef.Diagnostic) ~= "function" then
        return
    end
    pcall(addonRef.Diagnostic, addonRef, level, "[dungeonfinder] " .. tostring(fmt), ...)
end

local function alert(message)
    if type(message) ~= "string" or message == "" then return end
    local notify = AccountHold and AccountHold.Notify
    if notify and type(notify.Alert) == "function" then
        if pcall(function() notify:Alert(message) end) then return end
    end
    if AccountHold and type(AccountHold.Log) == "function" then
        pcall(AccountHold.Log, AccountHold, "%s", message)
    end
end

local function dungeonQueue()
    local DQ = AccountHold and AccountHold.DungeonQueue
    if type(DQ) == "table" then return DQ end
    return nil
end

-- ---------------------------------------------------------------------------
-- PURE HELPERS -- ZO-free, and therefore the only testable surface under the
-- mock, which has no UI globals at all.
-- ---------------------------------------------------------------------------

-- Fold a display name to a comparison key. Delegates to DungeonQueue so the two
-- modules can never drift apart on the join; the inline copy is only the
-- fallback for a load order where DungeonQueue is absent.
function Finder.NormalizeName(s)
    local DQ = dungeonQueue()
    if DQ and type(DQ.NormalizeName) == "function" then
        local ok, key = pcall(DQ.NormalizeName, s)
        if ok then return key end
    end
    if type(s) ~= "string" then return nil end
    local out = string.gsub(string.lower(s), "[^%w]", "")
    if out == "" then return nil end
    return out
end

function Finder.IsDifficulty(d)
    return d == NORMAL or d == VETERAN
end

function Finder.OtherDifficulty(d)
    if d == VETERAN then return NORMAL end
    return VETERAN
end

-- The selection key. Difficulty-scoped so Normal and Veteran versions of the
-- same dungeon are independent rows (they are different activityIds and queue
-- differently), and so ONE selection table can hold both tabs at once.
function Finder.MakeRowKey(difficulty, activityId)
    if not Finder.IsDifficulty(difficulty) then return nil end
    local id = tonumber(activityId)
    if not id then return nil end
    return difficulty .. ":" .. tostring(id)
end

-- Merge one activity's (name -> id) pair into a per-difficulty index.
--
-- Registers the folded raw name, and ADDITIONALLY registers the name with a
-- leading "veteran" token stripped. GetActivityName returns the raw name and
-- ZO_ActivityFinderLocation_Specific:InitializeFormattedNames
-- (zo_activityfinderroot_classes.lua:316-323) shows that the veteran marker is
-- applied at DISPLAY time -- but if a locale ever bakes it into the raw name,
-- an unprefixed alias inside a difficulty-scoped map is unambiguous and keeps
-- the join working. First write wins, so a real name never loses to an alias.
function Finder.AddToIndex(index, name, activityId)
    if type(index) ~= "table" then return false end
    local id = tonumber(activityId)
    if not id then return false end

    local key = Finder.NormalizeName(name)
    if not key then return false end
    if index[key] == nil then index[key] = id end

    local stripped = string.gsub(key, "^veteran", "")
    if stripped ~= key and stripped ~= "" and index[stripped] == nil then
        index[stripped] = id
    end
    return true
end

function Finder.NewIndex()
    return { [NORMAL] = {}, [VETERAN] = {} }
end

-- Turn the Priorities plan into rows for ONE difficulty.
--
-- Returns (rows, unmatched). `unmatched` counts plan activities that describe
-- no queueable dungeon at this difficulty -- overland zones, crafting sites and
-- the synthetic "source unknown" row all legitimately land there. We report
-- that number rather than silently showing a subset: a player who prioritised
-- five things and sees three needs to know why.
function Finder.BuildRows(plan, index, difficulty)
    local rows, unmatched = {}, 0
    if not Finder.IsDifficulty(difficulty) then return rows, unmatched end
    if type(plan) ~= "table" then return rows, unmatched end

    local byName = (type(index) == "table") and index[difficulty] or nil
    if type(byName) ~= "table" then byName = {} end

    local seen = {}
    for i = 1, #plan do
        local activity = plan[i]
        local activityId = nil
        if type(activity) == "table" and activity.activityKey ~= "unknown" then
            local key = Finder.NormalizeName(activity.activityName)
            if key then activityId = byName[key] end
        end

        if activityId then
            local rowKey = Finder.MakeRowKey(difficulty, activityId)
            if rowKey and not seen[rowKey] then
                seen[rowKey] = true
                rows[#rows + 1] = {
                    rowType     = ROW_DUNGEON,
                    key         = rowKey,
                    difficulty  = difficulty,
                    activityId  = activityId,
                    name        = activity.activityName,
                    activity    = activity,
                    outstanding = tonumber(activity.outstanding) or 0,
                }
            end
        else
            unmatched = unmatched + 1
        end
    end
    return rows, unmatched
end

-- Selection state. A plain string-keyed set; never an array, so nothing depends
-- on row order and a rebuild cannot renumber a player's choices.
function Finder.NewSelection()
    return {}
end

function Finder.IsSelected(selection, key)
    if type(selection) ~= "table" or key == nil then return false end
    return selection[key] == true
end

function Finder.SetSelected(selection, key, on)
    if type(selection) ~= "table" or key == nil then return false end
    if on then
        selection[key] = true
    else
        selection[key] = nil
    end
    return selection[key] == true
end

function Finder.ToggleSelection(selection, key)
    if type(selection) ~= "table" or key == nil then return false end
    return Finder.SetSelected(selection, key, not Finder.IsSelected(selection, key))
end

function Finder.CountSelected(selection, rows)
    if type(selection) ~= "table" or type(rows) ~= "table" then return 0 end
    local n = 0
    for i = 1, #rows do
        local row = rows[i]
        if type(row) == "table" and Finder.IsSelected(selection, row.key) then
            n = n + 1
        end
    end
    return n
end

-- True only when there is at least one row AND every one of them is checked.
-- An empty list is NOT "all selected": that would make the Select All row read
-- "Clear All" with nothing to clear.
function Finder.AreAllSelected(selection, rows)
    if type(rows) ~= "table" or #rows == 0 then return false end
    return Finder.CountSelected(selection, rows) == #rows
end

function Finder.SelectAll(selection, rows, on)
    if type(selection) ~= "table" or type(rows) ~= "table" then return 0 end
    local n = 0
    for i = 1, #rows do
        local row = rows[i]
        if type(row) == "table" and row.key ~= nil then
            Finder.SetSelected(selection, row.key, on and true or false)
            n = n + 1
        end
    end
    return n
end

-- Every checked row, ACROSS BOTH DIFFICULTIES, in DungeonQueue's entry shape
-- ({ activity, activityId, name }) so it can be handed straight to
-- DungeonQueue:QueueFor / DungeonQueue.PickOne.
--
-- Both tabs on purpose: ActivityFinderRoot_Manager:StartSearch
-- (zo_activityfinderroot_manager.lua:617-636) walks EVERY entry in
-- sortedLocationsData, so the base game likewise queues Normal and Veteran
-- selections together, and switching tabs there does not clear selections
-- (FilterByActivity, zo_activityfindertemplate_gamepad.lua:358-361, calls only
-- RefreshView -- never RefreshHeaderAndView, which is the one that clears).
function Finder.SelectedEntries(selection, rowsByDifficulty)
    local entries = {}
    if type(selection) ~= "table" or type(rowsByDifficulty) ~= "table" then
        return entries
    end
    local seen = {}
    for i = 1, #Finder.DIFFICULTIES do
        local difficulty = Finder.DIFFICULTIES[i]
        local rows = rowsByDifficulty[difficulty]
        if type(rows) == "table" then
            for j = 1, #rows do
                local row = rows[j]
                if type(row) == "table"
                   and Finder.IsSelected(selection, row.key)
                   and not seen[row.key] then
                    seen[row.key] = true
                    entries[#entries + 1] = {
                        activity   = row.activity,
                        activityId = row.activityId,
                        name       = row.name,
                        difficulty = row.difficulty,
                    }
                end
            end
        end
    end
    return entries
end

-- The checkmark. See the header for why this is text and not only isSelected.
function Finder.CheckMark(selected)
    if selected then
        return L("SI_ACCOUNTHOLD_DF_CHECKED", "[X] ")
    end
    return L("SI_ACCOUNTHOLD_DF_UNCHECKED", "[  ] ")
end

function Finder.DifficultyName(difficulty)
    if difficulty == VETERAN then
        return L("SI_ACCOUNTHOLD_DF_VETERAN", "Veteran")
    end
    return L("SI_ACCOUNTHOLD_DF_NORMAL", "Normal")
end

-- One dungeon row's label: checkmark, name, and the outstanding-piece count
-- that is the entire reason the dungeon is on the plan.
function Finder.RowLabel(row, selected)
    if type(row) ~= "table" then return "" end
    local name = row.name
    if type(name) ~= "string" or name == "" then
        name = L("SI_ACCOUNTHOLD_DF_UNNAMED", "Unknown dungeon")
    end
    local label = Finder.CheckMark(selected) .. name
    local outstanding = tonumber(row.outstanding) or 0
    if outstanding > 0 then
        label = label .. "  (" .. string.format(
            L("SI_ACCOUNTHOLD_DF_OUTSTANDING", "%d needed"), outstanding) .. ")"
    end
    return label
end

-- The complete row list for the current view: two action rows, then the
-- dungeons, or a single explanatory row when there is nothing to show.
--
-- Pure, so the whole screen layout can be asserted without any UI framework.
function Finder.BuildViewRows(difficulty, rowsByDifficulty, selection, unmatchedByDifficulty)
    local out = {}
    if not Finder.IsDifficulty(difficulty) then difficulty = NORMAL end

    local rows = nil
    if type(rowsByDifficulty) == "table" then rows = rowsByDifficulty[difficulty] end
    if type(rows) ~= "table" then rows = {} end

    local allSelected = Finder.AreAllSelected(selection, rows)

    out[#out + 1] = {
        rowType    = ROW_DIFFICULTY,
        key        = "action:difficulty",
        header     = L("SI_ACCOUNTHOLD_DF_TITLE", "Quartermaster Dungeons"),
        difficulty = difficulty,
        label      = string.format(
            L("SI_ACCOUNTHOLD_DF_DIFFICULTY_ROW", "Difficulty: %s  (A to switch)"),
            Finder.DifficultyName(difficulty)),
    }

    local selectAllLabel
    if allSelected then
        selectAllLabel = L("SI_ACCOUNTHOLD_DF_CLEAR_ALL", "Clear All")
    else
        selectAllLabel = L("SI_ACCOUNTHOLD_DF_SELECT_ALL", "Select All")
    end
    out[#out + 1] = {
        rowType    = ROW_SELECT_ALL,
        key        = "action:selectAll",
        difficulty = difficulty,
        turnOn     = not allSelected,
        label      = selectAllLabel,
    }

    if #rows == 0 then
        local unmatched = 0
        if type(unmatchedByDifficulty) == "table" then
            unmatched = tonumber(unmatchedByDifficulty[difficulty]) or 0
        end
        local message
        if unmatched > 0 then
            -- There IS a plan; nothing on it is a dungeon at this difficulty.
            message = string.format(
                L("SI_ACCOUNTHOLD_DF_NONE_AT_DIFFICULTY",
                  "Nothing on your plan is a %s dungeon. %d prioritised activity(s) are not queueable dungeons."),
                Finder.DifficultyName(difficulty), unmatched)
        else
            message = L("SI_ACCOUNTHOLD_DF_EMPTY",
                "Nothing prioritised yet. Collections > Item Sets, highlight a set piece, press Y.")
        end
        out[#out + 1] = {
            rowType = ROW_MESSAGE,
            key     = "message:empty",
            header  = Finder.DifficultyName(difficulty),
            label   = message,
        }
        return out
    end

    for i = 1, #rows do
        local row = rows[i]
        if type(row) == "table" then
            local selected = Finder.IsSelected(selection, row.key)
            local view = {
                rowType     = ROW_DUNGEON,
                key         = row.key,
                difficulty  = row.difficulty,
                activityId  = row.activityId,
                name        = row.name,
                activity    = row.activity,
                outstanding = row.outstanding,
                selected    = selected,
                label       = Finder.RowLabel(row, selected),
            }
            if i == 1 then view.header = Finder.DifficultyName(difficulty) end
            out[#out + 1] = view
        end
    end
    return out
end

-- Summary line under the title. Honest about what will actually be queued.
function Finder.SummaryText(selection, rowsByDifficulty)
    local entries = Finder.SelectedEntries(selection, rowsByDifficulty)
    if #entries == 0 then
        return L("SI_ACCOUNTHOLD_DF_SUMMARY_NONE",
                 "Nothing selected. A checks a dungeon, X queues for every checked dungeon.")
    end
    return string.format(
        L("SI_ACCOUNTHOLD_DF_SUMMARY", "%d dungeon(s) checked."), #entries)
end

-- ---------------------------------------------------------------------------
-- Model -- the ZO-touching half
-- ---------------------------------------------------------------------------

-- Build { normal = { [foldedName] = activityId }, veteran = { ... } }.
--
-- Uses only the enumeration API, none of which is *protected*:
--   GetNumActivitiesByType(LFGActivity)          -> integer
--   GetActivityIdByTypeAndIndex(LFGActivity, i)  -> integer
--   GetActivityName(activityId)                  -> string
-- Returns fully-formed empty tables (never nil) when the API is absent, so a
-- caller cannot tell "no client API" from "no matches" and both fail closed to
-- an honest empty state.
function Finder.BuildDifficultyIndex()
    local index = Finder.NewIndex()

    local getNum  = gfn("GetNumActivitiesByType")
    local getId   = gfn("GetActivityIdByTypeAndIndex")
    local getName = gfn("GetActivityName")
    if not getNum or not getId or not getName then
        diag("info", "Activity enumeration API unavailable - no dungeons can be listed.")
        return index
    end

    for i = 1, #Finder.DIFFICULTIES do
        local difficulty   = Finder.DIFFICULTIES[i]
        local activityType = gvalue(TYPE_NAME_FOR_DIFFICULTY[difficulty])
        if activityType ~= nil then
            local okCount, count = pcall(getNum, activityType)
            if okCount and type(count) == "number" then
                for j = 1, count do
                    local okId, activityId = pcall(getId, activityType, j)
                    if okId and type(activityId) == "number" then
                        local okName, name = pcall(getName, activityId)
                        if okName then
                            Finder.AddToIndex(index[difficulty], name, activityId)
                        end
                    end
                end
            end
        else
            diag("warn", "%s is not defined on this client - %s dungeons unavailable.",
                 tostring(TYPE_NAME_FOR_DIFFICULTY[difficulty]), difficulty)
        end
    end
    return index
end

-- Rebuild rows for BOTH difficulties from the current Priorities plan.
-- Selections survive because they are keyed by difficulty+activityId, not by
-- position, and a dungeon that leaves the plan simply stops being rendered.
function Finder.RefreshModel()
    local plan = {}
    local P = AccountHold and AccountHold.Priorities
    if type(P) == "table" and type(P.BuildPlan) == "function" then
        local ok, built = pcall(P.BuildPlan, P)
        if ok and type(built) == "table" then plan = built end
    end

    local index = Finder.BuildDifficultyIndex()
    local rowsByDifficulty, unmatchedByDifficulty = {}, {}
    for i = 1, #Finder.DIFFICULTIES do
        local difficulty = Finder.DIFFICULTIES[i]
        local rows, unmatched = Finder.BuildRows(plan, index, difficulty)
        rowsByDifficulty[difficulty]      = rows
        unmatchedByDifficulty[difficulty] = unmatched
    end

    Finder._index                 = index
    Finder._rows                  = rowsByDifficulty
    Finder._unmatched             = unmatchedByDifficulty
    Finder._planSize              = #plan
    return rowsByDifficulty, unmatchedByDifficulty
end

function Finder.CurrentDifficulty()
    if Finder.IsDifficulty(Finder._difficulty) then return Finder._difficulty end
    return NORMAL
end

function Finder.CurrentRows()
    local rows = Finder._rows
    if type(rows) ~= "table" then return {} end
    local list = rows[Finder.CurrentDifficulty()]
    if type(list) ~= "table" then return {} end
    return list
end

function Finder.Selection()
    if type(Finder._selection) ~= "table" then
        Finder._selection = Finder.NewSelection()
    end
    return Finder._selection
end

-- Reset everything that is per-visit. Called on open and on close, so a stale
-- selection can never survive into a session where the plan has changed.
function Finder.ResetState()
    Finder._difficulty = NORMAL
    Finder._selection  = Finder.NewSelection()
    Finder._rows       = nil
    Finder._unmatched  = nil
end

-- ---------------------------------------------------------------------------
-- Row activation (A) -- pure decision, impure effect
-- ---------------------------------------------------------------------------

-- Decide what A does on a row. Returns a machine key so the decision is
-- testable without a dialog: "difficulty" | "selectAll" | "toggle" | nil.
function Finder.ActivateRow(viewRow)
    if type(viewRow) ~= "table" then return nil end

    if viewRow.rowType == ROW_DIFFICULTY then
        Finder._difficulty = Finder.OtherDifficulty(Finder.CurrentDifficulty())
        return "difficulty"
    end

    if viewRow.rowType == ROW_SELECT_ALL then
        Finder.SelectAll(Finder.Selection(), Finder.CurrentRows(), viewRow.turnOn and true or false)
        return "selectAll"
    end

    if viewRow.rowType == ROW_DUNGEON and viewRow.key ~= nil then
        Finder.ToggleSelection(Finder.Selection(), viewRow.key)
        return "toggle"
    end

    return nil
end

-- ---------------------------------------------------------------------------
-- Actions
-- ---------------------------------------------------------------------------

-- The queue is already in flight? The base game refuses in exactly this case
-- (ActivityFinderRoot_Manager:StartSearch, zo_activityfinderroot_manager.lua
-- :618-620, via IsCurrentlySearchingForGroup). We mirror it with the documented
-- status accessor, and with IsCurrentlySearchingForGroup when it exists.
function Finder.IsAlreadyQueued()
    local searching = gfn("IsCurrentlySearchingForGroup")
    if searching then
        local ok, v = pcall(searching)
        if ok and v then return true end
    end
    local status = gfn("GetActivityFinderStatus")
    if status then
        local ok, v = pcall(status)
        if ok then
            local queued = gvalue("ACTIVITY_FINDER_STATUS_QUEUED")
            local ready  = gvalue("ACTIVITY_FINDER_STATUS_READY_CHECK")
            if queued ~= nil and v == queued then return true end
            if ready ~= nil and v == ready then return true end
        end
    end
    return false
end

-- X. Queue for every checked dungeon across both difficulties.
-- Returns (queued, reason) -- the same contract DungeonQueue:QueueFor uses.
function Finder.JoinQueue()
    local entries = Finder.SelectedEntries(Finder.Selection(), Finder._rows)
    if #entries == 0 then
        alert(L("SI_ACCOUNTHOLD_DF_QUEUE_NOTHING",
                "Check at least one dungeon first (A)."))
        return 0, "empty"
    end

    if Finder.IsAlreadyQueued() then
        alert(L("SI_ACCOUNTHOLD_DF_ALREADY_QUEUED",
                "You are already in the activity queue. Leave it first."))
        return 0, "already_queued"
    end

    local DQ = dungeonQueue()
    if not DQ or type(DQ.QueueFor) ~= "function" then
        diag("error", "DungeonQueue unavailable - cannot queue.")
        alert(L("SI_ACCOUNTHOLD_DF_QUEUE_NO_API",
                "The activity finder is unavailable on this client."))
        return 0, "no_api"
    end

    local ok, queued, reason = pcall(DQ.QueueFor, DQ, entries)
    if not ok then
        diag("error", "QueueFor threw: %s", tostring(queued))
        alert(L("SI_ACCOUNTHOLD_DF_QUEUE_NO_API",
                "The activity finder is unavailable on this client."))
        return 0, "no_api"
    end

    queued = tonumber(queued) or 0
    if queued > 0 then
        alert(string.format(
            L("SI_ACCOUNTHOLD_DF_QUEUED", "Queued for %d dungeon(s)."), queued))
        return queued
    end

    if reason == "no_api" then
        alert(L("SI_ACCOUNTHOLD_DF_QUEUE_NO_API",
                "The activity finder is unavailable on this client."))
    else
        alert(L("SI_ACCOUNTHOLD_DF_QUEUE_FAILED",
                "The queue could not be started."))
    end
    return 0, reason
end

-- Y. Pick ONE of the checked dungeons and TRAVEL there.
--
-- "Quartermaster Queue", not "Random": it is only random if everything is
-- checked. It picks from what the player SELECTED. `roll` is injectable so the
-- bound is provable in tests instead of sampled.
--
-- It used to only SHOW the map, which is why the player reported it "seems to
-- want to spin, but still is unable to take me to the specified dungeon".
-- A deliberate Y press IS the explicit player confirmation Travel:TravelTo
-- requires (src/Travel.lua, "THE CHOKEPOINT"), so it now travels, and falls back
-- to the map ONLY when travel is refused -- saying why, every time.
--
-- The decision matrix and the wording are shared with the in-finder tab
-- (ui/DungeonFinderScene_Gamepad.lua: Tab.PlanQueueTravel / Tab.QueueTravelText)
-- so the two surfaces can never behave differently.
function Finder.QuartermasterQueue(roll)
    local entries = Finder.SelectedEntries(Finder.Selection(), Finder._rows)
    if #entries == 0 then
        alert(L("SI_ACCOUNTHOLD_DF_QUEUE_NOTHING",
                "Check at least one dungeon first (A)."))
        return nil, "empty"
    end

    local DQ = dungeonQueue()
    if not DQ or type(DQ.PickOne) ~= "function" then
        alert(L("SI_ACCOUNTHOLD_DF_QM_QUEUE_NO_PICKER",
                "Quartermaster Queue is unavailable: the picker did not load."))
        diag("error", "DungeonQueue.PickOne unavailable - cannot pick.")
        return nil, "no_api"
    end

    local okPick, pick = pcall(DQ.PickOne, entries, roll)
    if not okPick or type(pick) ~= "table" then
        alert(L("SI_ACCOUNTHOLD_DF_QM_QUEUE_NO_PICK",
                "Quartermaster Queue could not pick a dungeon."))
        return nil, "empty"
    end

    local Tab = AccountHold and AccountHold.UI and AccountHold.UI.DungeonFinderTabGamepad
    if type(Tab) ~= "table" or type(Tab.PlanQueueTravel) ~= "function"
       or type(Tab.QueueTravelText) ~= "function" or type(Tab._TravelAdapter) ~= "function" then
        alert(string.format(
            L("SI_ACCOUNTHOLD_DF_QM_QUEUE_NO_API",
              "Quartermaster Queue: %s. Travel is unavailable right now."),
            tostring(pick.name)))
        return pick, "no_travel"
    end

    -- Every Travel entry point is multi-return and the adapter captures all of
    -- them: (nodeIndex, matchKind), (canTravel, reason), (performed, reason),
    -- (shown, reason). Collapsing any one of those is what made this silent.
    local okPlan, action, detail = pcall(Tab.PlanQueueTravel, pick, Tab._TravelAdapter())
    if not okPlan then
        action, detail = "failed", { name = pick.name, reason = "no_api" }
    end

    local okText, text = pcall(Tab.QueueTravelText, action, detail)
    alert(okText and text or tostring(action))
    return pick, action, detail
end

-- Kept so anything still calling the old name keeps working.
Finder.RandomTravel = Finder.QuartermasterQueue

-- ---------------------------------------------------------------------------
-- Dialog plumbing
-- ---------------------------------------------------------------------------

-- ZO_Dialogs_RegisterCustomDialog stores OUR table straight into ESO_Dialogs
-- (zo_dialog.lua:1207-1209) and ZO_Dialogs_ShowDialog copies that same
-- reference onto dialog.info (:482), so all three handles are the same object.
-- ESO_Dialogs is read first because it is the one the game dereferences; the
-- local reference is the fallback for a client (or harness) that keeps its
-- registry elsewhere.
local function dialogInfo()
    local dialogs = gtable("ESO_Dialogs")
    if dialogs and type(dialogs[DIALOG_NAME]) == "table" then
        return dialogs[DIALOG_NAME]
    end
    if type(Finder._info) == "table" then return Finder._info end
    return nil
end

-- View rows -> parametricList entries. `sharedSetup` is
-- ZO_SharedGamepadEntry_OnSetup, passed in rather than looked up so this stays
-- callable (and assertable) with a stub.
function Finder.RenderEntries(viewRows, sharedSetup)
    local out = {}
    if type(viewRows) ~= "table" then return out end
    for i = 1, #viewRows do
        local view = viewRows[i]
        if type(view) == "table" then
            local entry = {
                template = TEMPLATE,
                -- zo_genericdialog_gamepad.lua:800-807. A plain string: the
                -- whole list is rebuilt on every toggle, so there is no state a
                -- text function could see that this string does not reflect.
                text   = view.label or "",
                header = view.header,
                templateData = {
                    -- :745 calls this UNCONDITIONALLY. An entry without it
                    -- throws inside the base rebuild loop.
                    setup = sharedSetup,
                    -- :816-819 copies this raw onto the entry data, which is
                    -- what ZO_GamepadEntryData:SetSelected would have written
                    -- (zo_gamepadentrydata.lua:391-393). Renders a check on
                    -- templates that own a StatusIndicator; harmless on ones
                    -- that do not (zo_gamepadtemplatescommon.lua:352).
                    isSelected = view.selected and true or false,
                    accountHoldFinderRow = view,
                },
            }
            out[#out + 1] = entry
        end
    end
    return out
end

-- Replace our OWN parametricList in place. The base rebuild loop re-walks
-- dialog.info.parametricList with ipairs on every rebuild
-- (zo_genericdialog_gamepad.lua:785), so swapping the contents and asking for a
-- rebuild is all a toggle needs. Nothing here touches base-game data.
function Finder.PopulateList()
    local info = dialogInfo()
    if not info or type(info.parametricList) ~= "table" then return false end

    local sharedSetup = gfn("ZO_SharedGamepadEntry_OnSetup")
    if not sharedSetup then return false end

    local viewRows = Finder.BuildViewRows(
        Finder.CurrentDifficulty(), Finder._rows, Finder.Selection(), Finder._unmatched)
    local entries = Finder.RenderEntries(viewRows, sharedSetup)

    local list = info.parametricList
    for i = #list, 1, -1 do list[i] = nil end
    for i = 1, #entries do list[i] = entries[i] end
    return true
end

-- Redraw the dialog that is already open. Called after every toggle, every
-- Select All and every difficulty switch, so the list can never show stale
-- checkmarks.
function Finder.Refresh(dialog)
    dialog = dialog or Finder._dialog
    if not Finder.PopulateList() then return false end
    -- WAS `type(dialog) ~= "table"`. `dialog` is the dialog CONTROL
    -- (ZO_GamepadDialogPara, userdata on hardware), so that test was always
    -- true on console: the entries table was rewritten but RefreshText,
    -- RebuildEntryList and RefreshKeybinds never ran, and the list on screen
    -- kept the checkmarks it opened with. See the userdata banner above.
    if not isControl(dialog) then return false end

    local refreshText = gfn("ZO_GenericGamepadDialog_RefreshText")
    if refreshText then
        pcall(refreshText, dialog,
              L("SI_ACCOUNTHOLD_DF_TITLE", "Quartermaster Dungeons"),
              Finder.SummaryText(Finder.Selection(), Finder._rows))
    end

    local rebuild = gfn("ZO_GenericParametricListGamepadDialogTemplate_RebuildEntryList")
    if rebuild then
        -- reselect = true -> Commit() rather than CommitWithoutReselect()
        -- (zo_genericdialog_gamepad.lua:849-853), which keeps the cursor on the
        -- row the player just checked instead of snapping to the top.
        local NO_LIMIT, RESELECT = nil, true
        local ok, err = pcall(rebuild, dialog, NO_LIMIT, RESELECT)
        if not ok then
            diag("error", "RebuildEntryList failed: %s", tostring(err))
            return false
        end
    end

    -- X / Y / RESET appear only when there is something to act on, so the strip
    -- has to be re-evaluated after every selection change
    -- (zo_genericdialog_gamepad.lua:277-279).
    local refreshKeybinds = gfn("ZO_GenericGamepadDialog_RefreshKeybinds")
    if refreshKeybinds then pcall(refreshKeybinds, dialog) end

    -- A rebuild clears and re-commits the list; make sure it is still taking
    -- input. Guarded because these are methods on a base-game object.
    pcall(function()
        local list = dialog.entryList
        if type(list) == "table" and type(list.Activate) == "function" then
            if type(list.IsActive) ~= "function" or not list:IsActive() then
                list:Activate()
            end
        end
    end)
    return true
end

local function release()
    local f = gfn("ZO_Dialogs_ReleaseDialogOnButtonPress")
    if f then pcall(f, DIALOG_NAME) end
end

local function targetRow(dialog)
    local row
    pcall(function()
        local list = dialog and dialog.entryList
        if type(list) == "table" and type(list.GetTargetData) == "function" then
            local data = list:GetTargetData()
            if type(data) == "table" then row = data.accountHoldFinderRow end
        end
    end)
    return row
end

local function anySelected()
    local ok, v = pcall(function()
        return #Finder.SelectedEntries(Finder.Selection(), Finder._rows) > 0
    end)
    return (ok and v) and true or false
end

-- ---------------------------------------------------------------------------
-- Feature gates
-- ---------------------------------------------------------------------------

-- Ship-time gate: decides whether we REGISTER at all.
function Finder.IsAvailable()
    local f = AccountHold and AccountHold.Features
    if type(f) ~= "table" or type(f.REGISTRY) ~= "table" then return true end
    local reg = f.REGISTRY.priorities
    if type(reg) ~= "table" then return true end
    return reg.available ~= false
end

-- Runtime gate: can change from the settings panel without a reload, so it is
-- checked on every open.
function Finder.IsEnabled()
    local f = AccountHold and AccountHold.Features
    if type(f) ~= "table" or type(f.IsEnabled) ~= "function" then return true end
    local ok, v = pcall(f.IsEnabled, f, "priorities")
    return (ok and v) and true or false
end

-- ---------------------------------------------------------------------------
-- Registration
-- ---------------------------------------------------------------------------

function Finder.Register()
    if Finder._registered then return true end

    local register = gfn("ZO_Dialogs_RegisterCustomDialog")
    if not register then
        diag("warn", "ZO_Dialogs_RegisterCustomDialog unavailable - NOT registered.")
        return false
    end

    local gamepadDialogs = gtable("GAMEPAD_DIALOGS")
    if not gamepadDialogs or gamepadDialogs.PARAMETRIC == nil then
        diag("warn", "GAMEPAD_DIALOGS.PARAMETRIC unavailable - NOT registered.")
        return false
    end

    -- zo_genericdialog_gamepad.lua:745 -- an entry with no setup throws inside
    -- the base rebuild loop, so no shared setup helper means no dialog at all.
    if not gfn("ZO_SharedGamepadEntry_OnSetup") then
        diag("warn", "ZO_SharedGamepadEntry_OnSetup unavailable - NOT registered.")
        return false
    end

    local info = {
        gamepadInfo = {
            dialogType = gamepadDialogs.PARAMETRIC,
            -- ZO_Dialogs_ShowGamepadDialog drops the request outright if no
            -- scene is showing (zo_dialog.lua:356-377). We are opened from
            -- another dialog's keybind, so landing mid-transition is likely and
            -- a silently-dropped request is precisely the failure this add-on
            -- has already shipped three times. This makes the base game re-issue
            -- the show once the next scene is up (:358-371).
            allowShowOnNextScene = true,
        },

        -- Show rather than drop when the Priorities dialog is still up
        -- (zo_dialog.lua:435-440). The queue drains on hide (:977-981).
        canQueue = true,

        -- zo_dialog.lua:1247-1256 -- WE decide when this closes, so A can toggle
        -- a checkmark without tearing the screen down.
        blockDialogReleaseOnPress = true,

        title    = { text = L("SI_ACCOUNTHOLD_DF_TITLE", "Quartermaster Dungeons") },
        mainText = { text = "" },

        -- Reached when the show request could not be honoured at all
        -- (zo_dialog.lua:373-376). A console player has no error log, so
        -- without this the feature just "does nothing".
        noChoiceCallback = function()
            diag("warn", "Show request was dropped -- no scene was showing.")
        end,

        -- REQUIRED. zo_dialog.lua:604-605 calls dialogInfo.setup(dialog, ...) on
        -- every show, and for a PARAMETRIC gamepad dialog it is dialog:setupFunc()
        -- -- assigned ZO_GenericParametricListGamepadDialogTemplate_Setup at
        -- zo_genericdialog_gamepad.lua:692 -- that actually BUILDS the entry list
        -- from parametricList. Omitting this is why an earlier dialog in this
        -- add-on opened COMPLETELY EMPTY.
        setup = function(dialog)
            Finder._dialog = dialog
            local refreshText = gfn("ZO_GenericGamepadDialog_RefreshText")
            if refreshText then
                pcall(refreshText, dialog,
                      L("SI_ACCOUNTHOLD_DF_TITLE", "Quartermaster Dungeons"),
                      Finder.SummaryText(Finder.Selection(), Finder._rows))
            end
            -- The list must be populated BEFORE setupFunc runs: setupFunc walks
            -- dialog.info.parametricList immediately
            -- (zo_genericdialog_gamepad.lua:736).
            Finder.PopulateList()
            if type(dialog.setupFunc) == "function" then
                pcall(dialog.setupFunc, dialog)
            end
        end,

        -- Rebuilt wholesale on every change; registered empty so the very first
        -- Show cannot race the first PopulateList.
        parametricList = {},

        buttons = {
            {
                -- A. Parity with the base finder, whose UI_SHORTCUT_PRIMARY
                -- callback is ToggleLocationSelected
                -- (zo_activityfindertemplate_gamepad.lua:186-205).
                keybind  = "DIALOG_PRIMARY",
                text     = L("SI_ACCOUNTHOLD_DF_SELECT", "Select"),
                callback = function(dialog)
                    pcall(function()
                        local row = targetRow(dialog)
                        if row then Finder.ActivateRow(row) end
                    end)
                    Finder.Refresh(dialog)
                end,
            },
            {
                keybind  = "DIALOG_NEGATIVE",
                text     = L("SI_ACCOUNTHOLD_DF_BACK", "Back"),
                callback = function()
                    release()
                end,
            },
            {
                -- X. The base finder puts JOIN QUEUE on UI_SHORTCUT_SECONDARY
                -- (zo_activityfindertemplate_gamepad.lua:283-300); inside a
                -- dialog the same physical button is DIALOG_SECONDARY
                -- (ingame/globals/bindings.xml:737-739).
                keybind = "DIALOG_SECONDARY",
                text    = L("SI_ACCOUNTHOLD_DF_JOIN_QUEUE", "Join Queue"),
                visible = function() return anySelected() end,
                callback = function(dialog)
                    local queued = 0
                    pcall(function() queued = Finder.JoinQueue() or 0 end)
                    if queued > 0 then
                        release()
                    else
                        Finder.Refresh(dialog)
                    end
                end,
            },
            {
                -- Y.
                keybind = "DIALOG_TERTIARY",
                text    = L("SI_ACCOUNTHOLD_DF_QM_QUEUE", "Quartermaster Queue"),
                visible = function() return anySelected() end,
                callback = function()
                    pcall(function() Finder.QuartermasterQueue() end)
                    -- Travel (or the world map) is about to take over the
                    -- screen; leaving a dialog underneath would strand the player.
                    release()
                end,
            },
            {
                -- A real dialog-layer action: ingame/globals/bindings.xml:749-751.
                keybind = "DIALOG_RESET",
                text    = function()
                    local ok, all = pcall(function()
                        return Finder.AreAllSelected(Finder.Selection(), Finder.CurrentRows())
                    end)
                    if ok and all then
                        return L("SI_ACCOUNTHOLD_DF_CLEAR_ALL", "Clear All")
                    end
                    return L("SI_ACCOUNTHOLD_DF_SELECT_ALL", "Select All")
                end,
                visible = function()
                    local ok, v = pcall(function() return #Finder.CurrentRows() > 0 end)
                    return (ok and v) and true or false
                end,
                callback = function(dialog)
                    pcall(function()
                        local rows = Finder.CurrentRows()
                        local turnOn = not Finder.AreAllSelected(Finder.Selection(), rows)
                        Finder.SelectAll(Finder.Selection(), rows, turnOn)
                    end)
                    Finder.Refresh(dialog)
                end,
            },
        },

        -- Closed by any route (B, DIALOG_CLOSE, a scene change): drop the
        -- per-visit state so the next open starts clean.
        finishedCallback = function()
            Finder._dialog = nil
            Finder.ResetState()
        end,
    }

    local ok, err = pcall(register, DIALOG_NAME, info)
    if not ok then
        diag("error", "Dialog registration failed: %s", tostring(err))
        return false
    end

    Finder._registered = true
    Finder._info       = info
    diag("info", "Dialog '%s' registered.", DIALOG_NAME)
    return true
end

-- ---------------------------------------------------------------------------
-- PUBLIC ENTRY POINT
-- ---------------------------------------------------------------------------
-- AccountHold.UI.DungeonFinderGamepad:Show()
--
-- Call this from the Priorities dialog's X button. Returns true when the dialog
-- was actually asked to show. Every refusal path both logs a diagnostic
-- (console players can dump those) and raises an alert, so a player who pressed
-- a button always gets an answer.
function Finder:Show()
    if not Finder.IsAvailable() then
        diag("warn", "Feature 'priorities' is not available in this build.")
        alert(L("SI_ACCOUNTHOLD_DF_UNAVAILABLE",
                "Quartermaster Dungeons is not available in this version."))
        return false
    end
    if not Finder.IsEnabled() then
        diag("info", "Feature 'priorities' is switched off for this account.")
        alert(L("SI_ACCOUNTHOLD_DF_DISABLED",
                "Priorities is switched off. Turn it on in the add-on settings."))
        return false
    end

    if not Finder.Register() then
        alert(L("SI_ACCOUNTHOLD_DF_NO_DIALOG",
                "Quartermaster Dungeons could not open on this client."))
        return false
    end

    -- Both surfaces are gamepad-only: the native category lives in the GAMEPAD
    -- Activity Finder, and GAMEPAD_DIALOGS.PARAMETRIC only renders down the
    -- isGamepad path (zo_dialog.lua:352-357). Refuse clearly rather than push a
    -- gamepad scene over a keyboard UI or open an empty box.
    local gamepad = gfn("IsInGamepadPreferredMode")
    if gamepad then
        local ok, on = pcall(gamepad)
        if ok and not on then
            diag("info", "Requested in keyboard mode; refusing to show a gamepad screen.")
            alert(L("SI_ACCOUNTHOLD_DF_GAMEPAD_ONLY",
                    "Quartermaster Dungeons is a gamepad screen. Switch to gamepad mode to use it."))
            return false
        end
    end

    -- PREFER THE NATIVE SURFACE.
    --
    -- The requirement is that this lives inside the in-game gamepad Activity /
    -- Dungeon Finder, not in a floating dialog. ui/DungeonFinderScene_Gamepad.lua
    -- appends a THIRD ROW, "Quartermaster Dungeons", to that screen's own
    -- category list right under the base game's "Random Dungeons" and "Specific
    -- Dungeons" (zo_activityfindertemplate_gamepad.lua:94-117), and fills the
    -- finder's own entry list when it is chosen. When it is installed, Show()
    -- just navigates to the real Dungeon Finder so there is exactly ONE
    -- Quartermaster Dungeons surface however the player reached it. The dialog
    -- below stays as the fallback for a client where the row could not be added.
    local nav = AccountHold and AccountHold.UI and AccountHold.UI.DungeonFinderTabGamepad
    if type(nav) ~= "table" then
        nav = AccountHold and AccountHold.UI and AccountHold.UI.DungeonFinderSceneGamepad
    end
    if type(nav) == "table" and type(nav.Open) == "function" then
        local okNav, opened = pcall(function() return nav.Open() end)
        if okNav and opened then
            diag("info", "Opened the native gamepad Dungeon Finder on the Quartermaster row.")
            return true
        end
        diag("info", "Native row unavailable (%s); falling back to the dialog.",
             tostring(nav._lastFailure or "not installed"))
    end

    -- This is a GAMEPAD parametric dialog. The gamepad-mode gate is above,
    -- shared with the native path.
    Finder.ResetState()
    -- Populate BEFORE the show so the first rebuild has rows even if `setup`
    -- were ever to be skipped.
    Finder.RefreshModel()
    Finder.PopulateList()

    -- Never open onto a blank screen. BuildViewRows always emits at least the
    -- two action rows plus an explanatory message row, but if the plan yields
    -- no dungeon at EITHER difficulty there is nothing to act on, so say so
    -- with an alert as well -- the player pressed a button and deserves words.
    local rows = Finder._rows or {}
    local total = 0
    for i = 1, #Finder.DIFFICULTIES do
        local list = rows[Finder.DIFFICULTIES[i]]
        if type(list) == "table" then total = total + #list end
    end
    if total == 0 then
        if (Finder._planSize or 0) == 0 then
            alert(L("SI_ACCOUNTHOLD_DF_EMPTY",
                    "Nothing prioritised yet. Collections > Item Sets, highlight a set piece, press Y."))
        else
            alert(L("SI_ACCOUNTHOLD_DF_NO_DUNGEONS",
                    "Nothing on your plan is a queueable dungeon."))
        end
    end

    local show = gfn("ZO_Dialogs_ShowGamepadDialog")
    if show then
        local ok, err = pcall(show, DIALOG_NAME, {})
        if ok then return true end
        diag("error", "ZO_Dialogs_ShowGamepadDialog failed: %s", tostring(err))
    end

    local showAny = gfn("ZO_Dialogs_ShowDialog")
    if showAny then
        local IS_GAMEPAD = true
        local ok, err = pcall(showAny, DIALOG_NAME, {}, nil, IS_GAMEPAD)
        if ok then return true end
        diag("error", "ZO_Dialogs_ShowDialog failed: %s", tostring(err))
    end

    alert(L("SI_ACCOUNTHOLD_DF_NO_DIALOG",
            "Quartermaster Dungeons could not open on this client."))
    return false
end

-- ---------------------------------------------------------------------------
-- Lifecycle
-- ---------------------------------------------------------------------------

function Finder:Initialize(addonRef)
    self.addon = addonRef
    Finder.ResetState()

    if not Finder.IsAvailable() then
        diag("info", "Feature 'priorities' unavailable - dialog NOT registered.")
        return
    end
    -- Registration is idempotent and costs nothing at runtime, so it happens at
    -- load; Show() re-attempts it anyway if the base UI was not ready yet.
    Finder.Register()
end

-- EVENT_ADD_ON_LOADED is the earliest possible moment and does not guarantee the
-- gamepad dialog framework is stood up. Registration fails closed, so retry once
-- the player is in the world; it is idempotent, so a successful first attempt
-- makes this a no-op. Mirrors ArmoryScreen_Gamepad:ScheduleRetry.
function Finder:ScheduleRetry(addonRef)
    -- WAS `gtable("EVENT_MANAGER")`. EVENT_MANAGER is GetEventManager()
    -- (globalvars.lua:4) -- an engine object, i.e. USERDATA. gtable() returned
    -- nil for it on every console session, so this function returned on its
    -- first line and the retry NEVER RAN on the platform it exists for.
    local em = gobject("EVENT_MANAGER")
    local register = method(em, "RegisterForEvent")
    if not register then return end
    local playerActivated = gvalue("EVENT_PLAYER_ACTIVATED")
    if playerActivated == nil then return end

    local name = ((addonRef and addonRef.name) or "AccountHold") .. "_DungeonFinderRetry"
    pcall(function()
        em:RegisterForEvent(name, playerActivated, function()
            -- The native Dungeon Finder ROW is the real goal; the dialog is
            -- only the fallback surface. Retry BOTH until each succeeds once.
            local nav = AccountHold and AccountHold.UI
                        and (AccountHold.UI.DungeonFinderTabGamepad
                             or AccountHold.UI.DungeonFinderSceneGamepad)
            local navDone = true
            if type(nav) == "table" and type(nav.Install) == "function" then
                if nav.IsEnabled and nav.IsEnabled() then
                    navDone = true
                else
                    local okNav, installed = pcall(function() return nav.Install() end)
                    navDone = (okNav and installed) and true or false
                end
            end
            if Finder._registered and navDone then
                local unregister = method(em, "UnregisterForEvent")
                if unregister then
                    pcall(function() em:UnregisterForEvent(name, playerActivated) end)
                end
                return
            end
            if not Finder._registered then
                pcall(function() Finder:Initialize(addonRef) end)
            end
        end)
    end)
end
