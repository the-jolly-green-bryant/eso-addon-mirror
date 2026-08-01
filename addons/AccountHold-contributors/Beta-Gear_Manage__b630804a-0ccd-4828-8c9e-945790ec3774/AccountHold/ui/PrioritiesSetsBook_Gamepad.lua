-- AccountHold/ui/PrioritiesSetsBook_Gamepad.lua
--
-- Adds an "Add to Priorities" / "Remove from Priorities" action to the Y
-- ("Options") dialog of the GAMEPAD Item Sets Book -- i.e. Collections ->
-- Item Sets, the screen where a player already sees every set, where its
-- pieces drop, and how many they have collected.
--
-- This is the surface that lets a player POPULATE the wishlist. Without it
-- Priorities can only ever display an empty list.
--
-- WHY THIS SURFACE INSTEAD OF THE PAUSE MENU
-- ------------------------------------------
-- The gamepad pause menu builds every top-level row through AddEntryToList
-- (zo_mainmenu_gamepad.lua:835-866) inside RefreshMainList (:868-896), and only
-- calls mainList:Commit() at :895 AFTER that loop has finished. OPTIONS and
-- LOG_OUT are entries 14 and 15 of that very same array (ZO_MENU_ENTRIES :4,
-- ZO_MENU_MAIN_ENTRIES :6-23). A Lua error thrown from an add-on row therefore
-- aborts the build BEFORE the commit and can leave a console player in a pause
-- menu with no way to log out. This module touches none of that.
--
-- WHY THIS IS SAFE
-- ----------------
--   * Append-only. We table.insert ONE entry onto the END of a plain Lua array
--     and never renumber, reorder, mutate or remove a base-game entry.
--   * No base-game method is wrapped or hooked. The dialog template re-walks
--     dialog.info.parametricList with ipairs on EVERY open
--     (zo_genericdialog_gamepad.lua:785), so a single insert is picked up
--     forever with no re-registration -- which also means we never overwrite
--     another add-on's registration, the known failure mode in this area.
--   * Identity is a STRING key on the entry, never an index. Install is
--     idempotent and teardown removes by identity only.
--   * We claim NO keybind. Y already belongs to the base game
--     (itemsetsbook_gamepad.lua:528-532); we add a row to the dialog it opens.
--     This matters: a colliding keybind does not merely assert, it calls
--     RemoveKeybindButton on the EXISTING descriptor (zo_keybindstrip.lua:342-343),
--     which can rip out Back. This add-on has already crashed a session once
--     that way (README.md, "Xbox / PS5 quick reference").
--   * Every callback we hand to the base game is internally pcall'd, so it can
--     never throw into the rebuild loop, and every one has a safe fallback.
--
-- BASE-GAME CONTRACT -- every line below was read from esoui/esoui @ master
-- ------------------------------------------------------------------------
--   globalvars.lua:7                       ESO_Dialogs = {}
--   zo_dialog.lua:1207-1209                RegisterCustomDialog -> ESO_Dialogs[name] = info
--   itemsetcollectionsmanager.lua:82       the dialog, registered at file scope (:241)
--   itemsetcollectionsmanager.lua:96       parametricList = { ... }
--   itemsetcollectionsmanager.lua:143-166  "Link in Chat": the entry we model ours on
--   itemsetcollectionsmanager.lua:149      base entries use ZO_SharedGamepadEntry_OnSetup
--   itemsetcollectionsmanager.lua:169      blockDialogReleaseOnPress = true -> WE must release
--   itemsetcollectionsmanager.lua:179-183  A -> targetData.callback(dialog)
--   itemsetsbook_gamepad.lua:528-540       Y = UI_SHORTCUT_TERTIARY -> ShowGamepadDialog(...)
--   itemsetsbook_gamepad.lua:537           selected piece is nil unless the GRID is active
--   zo_dialog.lua:483                      dialog.data = data, on every show
--   zo_genericdialog_gamepad.lua:745       data.setup is called UNCONDITIONALLY
--   zo_genericdialog_gamepad.lua:785       ipairs over dialog.info.parametricList
--   zo_genericdialog_gamepad.lua:791-795   `visible` is read from templateData
--   zo_genericdialog_gamepad.lua:801-807   `text` may be function(dialog) -- ENTRY LEVEL ONLY
--   zo_genericdialog_gamepad.lua:815-819   templateData keys are copied RAW onto entryData
--   zo_genericdialog_gamepad.lua:825-838   header template is fixed by first-seen entryTemplate
--
-- The text/visible split is subtle and easy to get backwards: `visible` is read
-- from templateData (:791) but a `text` FUNCTION is only evaluated at the entry
-- level (:801-807) -- a function placed in templateData would be copied across
-- raw (:815-819) and never called. The base game's own Link in Chat entry puts a
-- static string in templateData, which works only because it is not a function.
--
-- ESO runs Lua 5.1: no goto, no //, no bitwise operators. This file must LOAD
-- under tests/zos_mock.lua with none of the ZO_* globals present.

AccountHold = AccountHold or {}
AccountHold.UI = AccountHold.UI or {}
AccountHold.UI.PrioritiesSetsBookGamepad = AccountHold.UI.PrioritiesSetsBookGamepad or {}

local Book = AccountHold.UI.PrioritiesSetsBookGamepad

-- itemsetsbook_gamepad.lua:540 -- the dialog the Y keybind opens.
local DIALOG_NAME = "GAMEPAD_ITEM_SETS_BOOK_OPTIONS_DIALOG"
-- Our identity marker. A STRING key, never a numeric index.
local MARKER      = "accountHoldPrioritiesEntry"
-- Separate marker for the QoL row (epic 0008): the two features are gated
-- independently, so each must be independently findable and removable.
local QOL_MARKER  = "accountHoldQolClearNewEntry"
-- itemsetcollectionsmanager.lua:143 -- reuse the base template so the
-- first-seen-template header quirk (zo_genericdialog_gamepad.lua:825-827)
-- stays consistent with the rest of the dialog.
local TEMPLATE    = "ZO_GamepadFullWidthLeftLabelEntryTemplate"

-- Test seams, mirroring Menu._ENTRY_ID in the sibling file.
Book._DIALOG_NAME = DIALOG_NAME
Book._MARKER      = MARKER
Book._QOL_MARKER  = QOL_MARKER
Book._TEMPLATE    = TEMPLATE

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

-- Priorities:Add rejects anything that is not tonumber(setId) > 0
-- (src/Priorities.lua:100-101). Mirror that rule at the boundary so a bad id
-- never reaches the model.
local function positiveSetId(v)
    local n = tonumber(v)
    if n and n > 0 then return n end
    return nil
end

-- Reading a field off a ZO_DataSourceObject runs a metatable __index FUNCTION
-- (baseobject.lua:173-184), which can throw. Never index one unguarded.
local function field(obj, key)
    if type(obj) ~= "table" then return nil end
    local ok, v = pcall(function() return obj[key] end)
    if ok then return v end
    return nil
end

local function callMethod(obj, name)
    local fn = field(obj, name)
    if type(fn) ~= "function" then return nil end
    local ok, v = pcall(fn, obj)
    if ok then return v end
    return nil
end

-- ---------------------------------------------------------------------------
-- THE ACCESSOR -- pure, ZO-free, testable
-- ---------------------------------------------------------------------------
-- Everything in this module depends on resolving the highlighted row to a set.
--
-- The Y callback (itemsetsbook_gamepad.lua:535-540) captures
-- gridListPanelList:GetSelectedData() and passes it as
-- data.selectedItemSetCollectionPieceData; zo_dialog.lua:483 parks that on
-- dialog.data. Grid cells carry the piece as their dataSource
-- (itemsetsbook_shared.lua:317) and data-source delegation
-- (baseobject.lua:173-184) makes :GetSetId() resolve through to
-- itemsetcollectionsdata.lua:19-21 -> :250-252 -> self.itemSetId.
--
-- The player therefore selects a PIECE and we prioritise its whole SET, which
-- is the intended behaviour: the grid has no "select the set" row.
--
-- Returns nil when the left-hand category list has focus rather than the grid
-- (itemsetsbook_gamepad.lua:537) -- there is no single set there, so the row
-- must hide. Failing closed is correct, not a limitation.
function Book.SetIdFromDialogData(data)
    if type(data) ~= "table" then return nil end

    local piece = field(data, "selectedItemSetCollectionPieceData")
    if type(piece) ~= "table" then return nil end

    -- Primary: itemsetcollectionsdata.lua:19-21
    local setId = positiveSetId(callMethod(piece, "GetSetId"))
    if setId then return setId end

    -- Fallback A: the grid group header this cell sits under.
    -- itemsetsbook_shared.lua:318 attaches gridHeaderData; :310 gives that
    -- header the ZO_ItemSetCollectionData as its dataSource.
    setId = positiveSetId(callMethod(field(piece, "gridHeaderData"), "GetId"))
    if setId then return setId end

    -- Fallback B: the collection object itself.
    -- itemsetcollectionsdata.lua:27-29 -> :250-252
    setId = positiveSetId(callMethod(callMethod(piece, "GetItemSetCollectionData"), "GetId"))
    if setId then return setId end

    return nil
end

-- ---------------------------------------------------------------------------
-- Placement -- pure, ZO-free, testable
-- ---------------------------------------------------------------------------

-- Returns (index, alreadyPresent). We ALWAYS append at #list + 1 so every base
-- entry keeps its position; unlike the pause menu there is no anchor to find
-- and no reason to insert anywhere else. Returns nil on an unusable list so the
-- caller fails closed.
function Book.FindEntryIndex(parametricList, marker)
    if type(parametricList) ~= "table" then return nil, false end
    if marker == nil then return nil, false end
    for i = 1, #parametricList do
        local e = parametricList[i]
        if type(e) == "table" and e[marker] then return i, true end
    end
    return #parametricList + 1, false
end

-- ---------------------------------------------------------------------------
-- Priorities bridge
-- ---------------------------------------------------------------------------

local function kindSet()
    local P = AccountHold and AccountHold.Priorities
    if type(P) == "table" and type(P.KIND_SET) == "string" then return P.KIND_SET end
    return "set"
end

-- Ship-time gate: decides whether we INSTALL at all (src/Features.lua REGISTRY).
local function featureAvailable()
    local f = AccountHold and AccountHold.Features
    if type(f) ~= "table" or type(f.REGISTRY) ~= "table" then return true end
    local reg = f.REGISTRY.priorities
    if type(reg) ~= "table" then return true end
    return reg.available ~= false
end

-- Runtime gate: decides whether the row is VISIBLE. Can change from the
-- settings panel without a reload, so it is checked per open.
local function featureEnabled()
    local f = AccountHold and AccountHold.Features
    if type(f) ~= "table" or type(f.IsEnabled) ~= "function" then return true end
    local ok, v = pcall(f.IsEnabled, f, "priorities")
    return (ok and v) and true or false
end

-- The QoL actions are a SEPARATE feature (epic 0008) with its own gate, so a
-- player can keep Priorities and drop the conveniences, or the reverse.
local function qolAvailable()
    local f = AccountHold and AccountHold.Features
    if type(f) ~= "table" or type(f.REGISTRY) ~= "table" then return true end
    local reg = f.REGISTRY.qol
    if type(reg) ~= "table" then return true end
    return reg.available ~= false
end

local function qolEnabled()
    local f = AccountHold and AccountHold.Features
    if type(f) ~= "table" or type(f.IsEnabled) ~= "function" then return true end
    local ok, v = pcall(f.IsEnabled, f, "qol")
    return (ok and v) and true or false
end

function Book.FindSetRecord(setId)
    setId = positiveSetId(setId)
    if not setId then return nil end
    local P = AccountHold and AccountHold.Priorities
    if type(P) ~= "table" or type(P.List) ~= "function" then return nil end
    local ok, list = pcall(P.List, P)
    if not ok or type(list) ~= "table" then return nil end
    for i = 1, #list do
        local rec = list[i]
        if type(rec) == "table" and rec.kind == kindSet()
           and tonumber(rec.setId) == setId then
            return rec
        end
    end
    return nil
end

-- Returns "added" | "removed" | nil. Never throws.
function Book.Toggle(setId)
    setId = positiveSetId(setId)
    if not setId then return nil end
    local P = AccountHold and AccountHold.Priorities
    if type(P) ~= "table" then return nil end

    local existing = Book.FindSetRecord(setId)
    if existing then
        if type(P.Remove) ~= "function" then return nil end
        local ok, removed = pcall(P.Remove, P, existing.id)
        if ok and removed then return "removed" end
        return nil
    end

    if type(P.Add) ~= "function" then return nil end
    local ok, rec = pcall(P.Add, P, { kind = kindSet(), setId = setId })
    if ok and type(rec) == "table" then return "added" end
    return nil
end

function Book.LabelFor(setId)
    if Book.FindSetRecord(setId) then
        return L("SI_ACCOUNTHOLD_PRIO_SETSBOOK_REMOVE", "Remove from Priorities")
    end
    return L("SI_ACCOUNTHOLD_PRIO_SETSBOOK_ADD", "Add to Priorities")
end

-- Console players cannot read Lua errors and the chat window is easy to miss,
-- so confirm through the same alert surface the rest of the add-on uses.
local function announce(result, setId)
    local msg
    if result == "added" then
        msg = L("SI_ACCOUNTHOLD_PRIO_SETSBOOK_ADDED", "Added to Priorities.")
    elseif result == "removed" then
        msg = L("SI_ACCOUNTHOLD_PRIO_SETSBOOK_REMOVED", "Removed from Priorities.")
    else
        return
    end

    local name
    if type(GetItemSetName) == "function" then
        local ok, n = pcall(GetItemSetName, setId)
        if ok and type(n) == "string" and n ~= "" then name = n end
    end
    if name then msg = name .. " - " .. msg end

    local N = AccountHold and AccountHold.Notify
    if type(N) == "table" and type(N.Alert) == "function" then
        if pcall(N.Alert, N, msg) then return end
    end
    if AccountHold and type(AccountHold.Log) == "function" then
        pcall(AccountHold.Log, AccountHold, "%s", msg)
    end
end

-- ---------------------------------------------------------------------------
-- QoL: clear "new piece" notifications
-- ---------------------------------------------------------------------------
-- The Item Sets Book marks freshly-acquired pieces as NEW and surfaces that as
-- a badge on Collections, on the Item Sets entry, and on every affected set.
-- There is no base-game "mark all as seen", so a player who has been away comes
-- back to a book covered in markers and has to visit each one.
--
-- VERIFIED API CONTRACT (ESOUIDocumentation.txt, esoui/esoui @ master -- none
-- carry the *protected* marker):
--   DoesItemSetCollectionsHaveAnyNewPieces()
--   GetNextItemSetCollectionId(integer:nilable lastItemSetId)   -- iterator
--   ItemSetCollectionHasNewPieces(integer itemSetId)
--   GetNumItemSetCollectionPieces(integer itemSetId)
--   GetItemSetCollectionPieceInfo(integer itemSetId, luaindex index) -> pieceId, slot
--   IsItemSetCollectionSlotNew(integer itemSetId, slot)
--   ClearItemSetCollectionSlotNew(integer itemSetId, slot, bool sendUpdate)
--
-- The base game clears exactly one slot at a time via
-- ZO_ItemSetCollectionPieceData:ClearNew (itemsetcollectionsdata.lua:126-128),
-- passing `not dontBroadcast` as sendUpdate. We clear MANY, so we suppress the
-- broadcast on every call and fire a single update on the last one -- otherwise
-- a player with hundreds of new pieces triggers hundreds of UI refreshes.

-- Walk every set that has new pieces and hand each new slot to `visit`.
-- Returns the number of new slots seen. `visit` may be nil to just count.
--
-- The iterator is bounded: GetNextItemSetCollectionId returning a value we have
-- already seen (or never terminating) would otherwise hang the client, and a
-- hung console session is unrecoverable without a hard restart.
function Book.ForEachNewPiece(visit)
    if type(GetNextItemSetCollectionId) ~= "function"
       or type(ItemSetCollectionHasNewPieces) ~= "function"
       or type(GetNumItemSetCollectionPieces) ~= "function"
       or type(GetItemSetCollectionPieceInfo) ~= "function"
       or type(IsItemSetCollectionSlotNew) ~= "function" then
        return 0
    end

    local count, guard, seen = 0, 0, {}
    local setId
    local okNext, nextId = pcall(GetNextItemSetCollectionId, nil)
    setId = okNext and nextId or nil

    while setId ~= nil do
        guard = guard + 1
        if guard > 5000 or seen[setId] then break end   -- bounded: never hang
        seen[setId] = true

        local okHas, hasNew = pcall(ItemSetCollectionHasNewPieces, setId)
        if okHas and hasNew then
            local okNum, numPieces = pcall(GetNumItemSetCollectionPieces, setId)
            if okNum and type(numPieces) == "number" then
                for i = 1, numPieces do
                    local okInfo, _pieceId, slot = pcall(GetItemSetCollectionPieceInfo, setId, i)
                    if okInfo and slot ~= nil then
                        local okNew, isNew = pcall(IsItemSetCollectionSlotNew, setId, slot)
                        if okNew and isNew then
                            count = count + 1
                            if type(visit) == "function" then
                                pcall(visit, setId, slot)
                            end
                        end
                    end
                end
            end
        end

        local okStep, stepId = pcall(GetNextItemSetCollectionId, setId)
        setId = okStep and stepId or nil
    end
    return count
end

-- How many pieces are currently flagged new.
function Book.CountNewPieces()
    return Book.ForEachNewPiece(nil)
end

-- Clear every "new" flag. Returns the number cleared.
function Book.ClearAllNewPieces()
    if type(ClearItemSetCollectionSlotNew) ~= "function" then return 0 end

    -- Collect first, then clear. Mutating the flags while iterating the same
    -- collection is asking for the iterator to skip entries.
    local pending = {}
    Book.ForEachNewPiece(function(setId, slot)
        pending[#pending + 1] = { setId = setId, slot = slot }
    end)

    for i = 1, #pending do
        local p = pending[i]
        -- sendUpdate only on the LAST one: one refresh, not N.
        local sendUpdate = (i == #pending)
        pcall(ClearItemSetCollectionSlotNew, p.setId, p.slot, sendUpdate)
    end
    return #pending
end

-- ---------------------------------------------------------------------------
-- Install / teardown
-- ---------------------------------------------------------------------------

function Book:Initialize(addonRef)
    self.addon = addonRef

    local function warn(fmt, ...)
        if addonRef and addonRef.Diagnostic then
            addonRef:Diagnostic("warn", "[priorities/setsbook] " .. fmt, ...)
        end
    end
    local function info(fmt, ...)
        if addonRef and addonRef.Diagnostic then
            addonRef:Diagnostic("info", "[priorities/setsbook] " .. fmt, ...)
        end
    end

    self._warn, self._info = warn, info

    -- MIGRATED TO src/core/Surface.lua.
    --
    -- The two rows this module installs are SEPARATE FEATURES with separate
    -- gates and separate markers, and they are now registered as two
    -- independent surfaces. Previously they were not independent in practice:
    -- Initialize opened with
    --
    --     if not featureAvailable() then ... return end     -- 'priorities'
    --
    -- and the QoL install sat BELOW that return, so switching `priorities` off
    -- silently took the `qol` row with it. Verified before this change:
    -- with priorities registry-unavailable and qol both available and enabled,
    -- zero QoL rows installed. The comment three lines further down already
    -- asserted the two were independent; the control flow disagreed.
    --
    -- Surface owns the gate check per Sync, so each row now lives or dies on
    -- its own feature. If Surface is absent this falls back to the direct
    -- install path below, so the module still works standalone.
    -- Surface owns the LIFECYCLE here, not the gate.
    --
    -- Both rows are registered WITHOUT a `feature`, deliberately. This module
    -- installs its rows once and gates them per-open through each row's own
    -- `visible` closure (featureEnabled / qolEnabled), so a settings toggle
    -- takes effect with no reload and no re-install. Surface's `feature` field
    -- gates at INSTALL time, which for a row that can hide itself cheaply is
    -- the wrong layer -- it would rip the row out and put it back instead of
    -- flipping a boolean.
    --
    -- Install-time gating IS right for a surface that cannot hide itself
    -- cheaply: a whole scene, or a keybind that would otherwise occupy a slot.
    -- ui/CollectionsClearAll_Gamepad.lua is that shape. Picking the wrong layer
    -- is a real hazard, so it is written down rather than left to be rederived.
    --
    -- What Surface gives this module is the rest of the lifecycle: independent
    -- install and teardown per row, retry on a not-yet-ready dialog, and a
    -- single place that can answer "why is my row missing".
    local S = AccountHold and AccountHold.Core and AccountHold.Core.Surface
    if type(S) == "table" and type(S.Register) == "function" then
        S.Register({
            id     = "priorities/setsbookRow",
            attach = function() return Book:_AttachPriorities() end,
            detach = function() Book:_DetachByMarker(MARKER) end,
        })
        S.Register({
            id     = "qol/setsbookClearNew",
            attach = function() return Book:_AttachQol() end,
            detach = function() Book:_DetachByMarker(QOL_MARKER) end,
        })
        S.Sync()
        return
    end

    self:_AttachPriorities()
    self:_AttachQol()
end

-- Shared environment resolution. Returns dialogInfo, sharedSetup, or nil when
-- the base-game dialog is not (yet) usable -- which is a "not right now", not a
-- "never", so callers return nil and let Surface retry.
function Book:_ResolveDialog()
    local warn = self._warn or function() end

    -- globalvars.lua:7
    if type(ESO_Dialogs) ~= "table" then
        warn("ESO_Dialogs unavailable - Item Sets action NOT added.")
        return nil
    end

    -- itemsetcollectionsmanager.lua:82, registered at :241 (file scope, before
    -- any add-on runs), so this should already be present on first try.
    local dialogInfo = ESO_Dialogs[DIALOG_NAME]
    if type(dialogInfo) ~= "table" or type(dialogInfo.parametricList) ~= "table" then
        warn("Dialog '%s' not registered - Item Sets action NOT added.", DIALOG_NAME)
        return nil
    end

    -- zo_genericdialog_gamepad.lua:745 calls data.setup UNCONDITIONALLY, so an
    -- entry without one throws inside the base rebuild loop. No setup helper,
    -- no entry. (itemsetcollectionsmanager.lua:149)
    if type(ZO_SharedGamepadEntry_OnSetup) ~= "function" then
        warn("ZO_SharedGamepadEntry_OnSetup unavailable - Item Sets action NOT added.")
        return nil
    end

    return dialogInfo, ZO_SharedGamepadEntry_OnSetup
end

-- Remove every row carrying `marker`. Teardown by IDENTITY only, never index.
function Book:_DetachByMarker(marker)
    if type(ESO_Dialogs) ~= "table" then return end
    local dialogInfo = ESO_Dialogs[DIALOG_NAME]
    if type(dialogInfo) ~= "table" or type(dialogInfo.parametricList) ~= "table" then return end
    pcall(function()
        local list = dialogInfo.parametricList
        for i = #list, 1, -1 do
            local e = list[i]
            if type(e) == "table" and e[marker] then table.remove(list, i) end
        end
    end)
    if marker == MARKER then
        self._entry     = nil
        self._installed = nil
    else
        self._qolEntry = nil
    end
end

-- The "Add to Priorities" row. Returns a handle on success, nil to retry.
--
-- `false` (never retry) is returned when the feature is not IMPLEMENTED in the
-- code registry, which no amount of retrying can change -- as distinct from the
-- dialog not being ready yet.
function Book:_AttachPriorities()
    local warn = self._warn or function() end
    local info = self._info or function() end

    if not featureAvailable() then
        info("Feature 'priorities' unavailable - Item Sets action NOT added.")
        return false
    end

    local dialogInfo, sharedSetup = self:_ResolveDialog()
    if dialogInfo == nil then return nil end

    local index, present = Book.FindEntryIndex(dialogInfo.parametricList, MARKER)
    if present then
        info("Item Sets action already present; skipping.")
        self._installed = true
        return self._entry or true
    end
    if not index then
        warn("parametricList unusable - Item Sets action NOT added.")
        return nil
    end

    local fallbackLabel = L("SI_ACCOUNTHOLD_PRIO_SETSBOOK_ADD", "Add to Priorities")

    local entry = {
        template = TEMPLATE,

        -- Our OWN header. The base "Actions" header is a static string
        -- (itemsetcollectionsmanager.lua:165) applied via entryData:SetHeader
        -- (zo_genericdialog_gamepad.lua:838) and cannot be made conditional, so
        -- reusing it would render "Actions" twice.
        header = L("SI_ACCOUNTHOLD_PRIO_SETSBOOK_HEADER", "Quartermaster"),

        -- zo_genericdialog_gamepad.lua:801-807. A text FUNCTION is only
        -- evaluated at the entry level -- see the note in this file's header.
        -- Runs inside the base rebuild loop, so it must NEVER throw.
        text = function(dialog)
            local ok, s = pcall(function()
                return Book.LabelFor(Book.SetIdFromDialogData(dialog and dialog.data))
            end)
            if ok and type(s) == "string" and s ~= "" then return s end
            return fallbackLabel
        end,

        templateData = {
            setup = sharedSetup,

            -- zo_genericdialog_gamepad.lua:791-795. Fail closed: no resolvable
            -- set (category list focused, or grid inactive per
            -- itemsetsbook_gamepad.lua:537) means hide -- exactly how the base
            -- game hides Link in Chat (itemsetcollectionsmanager.lua:157-162).
            visible = function(dialog)
                local ok, res = pcall(function()
                    if not featureEnabled() then return false end
                    return Book.SetIdFromDialogData(dialog and dialog.data) ~= nil
                end)
                return (ok and res) and true or false
            end,

            -- itemsetcollectionsmanager.lua:179-183 routes the A button here.
            callback = function(dialog)
                pcall(function()
                    local setId = Book.SetIdFromDialogData(dialog and dialog.data)
                    if setId then announce(Book.Toggle(setId), setId) end
                end)
                -- blockDialogReleaseOnPress = true
                -- (itemsetcollectionsmanager.lua:169) means A does NOT close the
                -- dialog; release it ourselves, as Link in Chat does at :154.
                if type(ZO_Dialogs_ReleaseDialogOnButtonPress) == "function" then
                    pcall(ZO_Dialogs_ReleaseDialogOnButtonPress, DIALOG_NAME)
                end
            end,
        },
    }
    entry[MARKER] = true
    entry.templateData[MARKER] = true

    local okInsert = pcall(function()
        table.insert(dialogInfo.parametricList, index, entry)
    end)
    if not okInsert then
        warn("table.insert into parametricList failed - Item Sets action NOT added.")
        return nil
    end

    self._entry     = entry
    self._installed = true
    info("Item Sets 'Add to Priorities' action installed at parametricList[%d].", index)
    return entry
end

-- The QoL "Clear new item notifications" row. Gated on `qol`, entirely
-- independently of the Priorities row above.
function Book:_AttachQol()
    local warn = self._warn or function() end
    local info = self._info or function() end

    if not qolAvailable() then
        info("Feature 'qol' unavailable - clear-notifications action NOT added.")
        return false
    end

    local dialogInfo, sharedSetup = self:_ResolveDialog()
    if dialogInfo == nil then return nil end

    self:_InstallClearNewEntry(dialogInfo, sharedSetup, warn, info)
    return self._qolEntry or true
end

-- "Clear new item notifications" — QoL (epic 0008).
--
-- Installed independently of the Priorities action so the two features can be
-- enabled separately. Same append-only, string-marked discipline.
function Book:_InstallClearNewEntry(dialogInfo, sharedSetup, warn, info)
    if not qolAvailable() then
        info("Feature 'qol' unavailable - clear-notifications action NOT added.")
        return
    end

    local index, present = Book.FindEntryIndex(dialogInfo.parametricList, QOL_MARKER)
    if present then return end
    if not index then return end

    local fallbackLabel = L("SI_ACCOUNTHOLD_QOL_CLEAR_NEW", "Clear new item notifications")

    local entry = {
        template = TEMPLATE,
        header   = L("SI_ACCOUNTHOLD_PRIO_SETSBOOK_HEADER", "Quartermaster"),

        -- Show the count, so the action is honest about whether it will do
        -- anything before the player commits to it.
        text = function()
            local ok, n = pcall(Book.CountNewPieces)
            local count = (ok and type(n) == "number") and n or 0
            local okFmt, s = pcall(string.format,
                L("SI_ACCOUNTHOLD_QOL_CLEAR_NEW_N", "Clear new item notifications (%d)"), count)
            if okFmt and type(s) == "string" then return s end
            return fallbackLabel
        end,

        templateData = {
            setup = sharedSetup,

            -- Visible whenever the FEATURE is on, even at zero.
            --
            -- This previously also hid when nothing was marked new, on the
            -- reasoning that an inert action is worse than an absent one. In
            -- practice that is indistinguishable from the feature being broken,
            -- and this add-on has a long history of surfaces silently not
            -- appearing. Showing "(0)" answers the question; showing nothing
            -- raises it.
            visible = function()
                local ok, res = pcall(qolEnabled)
                return (ok and res) and true or false
            end,

            callback = function()
                pcall(function()
                    local cleared = Book.ClearAllNewPieces()
                    local msg
                    if cleared and cleared > 0 then
                        msg = string.format(
                            L("SI_ACCOUNTHOLD_QOL_CLEARED_N", "Cleared %d new-item marker(s)."),
                            cleared)
                    else
                        msg = L("SI_ACCOUNTHOLD_QOL_CLEARED_NONE", "Nothing was marked new.")
                    end
                    local N = AccountHold and AccountHold.Notify
                    if type(N) == "table" and type(N.Alert) == "function" then
                        if pcall(N.Alert, N, msg) then return end
                    end
                    if AccountHold and type(AccountHold.Log) == "function" then
                        pcall(AccountHold.Log, AccountHold, "%s", msg)
                    end
                end)
                if type(ZO_Dialogs_ReleaseDialogOnButtonPress) == "function" then
                    pcall(ZO_Dialogs_ReleaseDialogOnButtonPress, DIALOG_NAME)
                end
            end,
        },
    }
    entry[QOL_MARKER] = true
    entry.templateData[QOL_MARKER] = true

    if not pcall(function() table.insert(dialogInfo.parametricList, index, entry) end) then
        warn("table.insert failed - clear-notifications action NOT added.")
        return
    end
    self._qolEntry = entry
    info("Item Sets 'Clear new notifications' action installed at parametricList[%d].", index)
end

-- Remove by identity only -- never by index, never by position.
function Book:Teardown()
    -- Drop the Surface registrations FIRST, and unconditionally. Surface.Remove
    -- detaches if installed, so this both removes the rows and clears the
    -- recorded state -- otherwise a later Sync would believe rows were still
    -- present and never reinstall them. Done before the ESO_Dialogs guard
    -- below, because the registration must be cleared even when the dialog has
    -- gone away.
    local S = AccountHold and AccountHold.Core and AccountHold.Core.Surface
    if type(S) == "table" and type(S.Remove) == "function" then
        pcall(S.Remove, "priorities/setsbookRow")
        pcall(S.Remove, "qol/setsbookClearNew")
    end

    -- Belt and braces: sweep by marker regardless. Surface only knows about
    -- rows IT installed, and this module predates it -- a row left by an
    -- earlier build, or by the standalone fallback path in Initialize, must
    -- still be removable.
    if type(ESO_Dialogs) ~= "table" then return end
    local dialogInfo = ESO_Dialogs[DIALOG_NAME]
    if type(dialogInfo) ~= "table" or type(dialogInfo.parametricList) ~= "table" then return end
    pcall(function()
        local list = dialogInfo.parametricList
        for i = #list, 1, -1 do
            local e = list[i]
            if type(e) == "table" and (e[MARKER] or e[QOL_MARKER]) then table.remove(list, i) end
        end
    end)
    self._entry     = nil
    self._qolEntry  = nil
    self._installed = nil
end

-- The dialog is registered at base-UI load (itemsetcollectionsmanager.lua:241),
-- so Initialize normally succeeds on the first attempt. Retry once on player
-- activation anyway, mirroring PrioritiesMenu_Gamepad -- the install is
-- idempotent, so a successful first pass makes this a no-op.
function Book:ScheduleRetry(addonRef)
    if EVENT_MANAGER == nil or type(EVENT_MANAGER.RegisterForEvent) ~= "function" then
        return
    end
    if not EVENT_PLAYER_ACTIVATED then return end
    local name = ((addonRef and addonRef.name) or "AccountHold") .. "_PrioritiesSetsBookRetry"
    pcall(function()
        EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_ACTIVATED, function()
            if Book._installed then
                pcall(function() EVENT_MANAGER:UnregisterForEvent(name, EVENT_PLAYER_ACTIVATED) end)
                return
            end
            pcall(function() Book:Initialize(addonRef) end)
        end)
    end)
end
