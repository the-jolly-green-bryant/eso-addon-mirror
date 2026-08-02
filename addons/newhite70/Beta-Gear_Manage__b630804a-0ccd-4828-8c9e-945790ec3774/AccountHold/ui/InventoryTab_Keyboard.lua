-- Quartermaster/ui/InventoryTab_Keyboard.lua
--
-- Adds a third tab — "Account Gear" — to the keyboard inventory window
-- alongside Inventory and Craft Bag. Uses the canonical pattern from
-- esoui/ingame/inventory/inventorymenubar.lua:
--
--   INVENTORY_MENU_BAR.modeBar:Add(<key>, <fragments>, <buttonData>, <keybinds>)
--
-- The fragment is a ZO_FadeSceneFragment wrapping our XML-defined
-- AccountHold_AccountGearPanel control. When our tab is selected,
-- INVENTORY_FRAGMENT (the standard backpack pane) is hidden and our
-- panel takes its place inside ZO_PlayerInventory.
--
-- Filter UX matches the guild store: search box (PC), filter dropdowns
-- for set / trait / quality / equip-slot / bound, sortable column
-- headers, scrollable list. Each row exposes Reserve Item / Reserve Set /
-- Cancel Hold actions: "Reserve Item" reserves the concrete item/stack and
-- "Reserve Set" reserves one set-level hold keyed by setId. There is no
-- set-vs-per-piece chooser.

AccountHold = AccountHold or {}
AccountHold.UI = AccountHold.UI or {}
AccountHold.UI.InventoryTabKeyboard = AccountHold.UI.InventoryTabKeyboard or {}

local Tab = AccountHold.UI.InventoryTabKeyboard

local TAB_KEY        = "AccountHold_AccountGearTab"
local CONTROL_NAME   = "AccountHold_AccountGearPanel"

-- Sort header data type for the scroll list.
local DATA_TYPE_ROW  = 1
local ROW_HEIGHT     = 30
-- Real per-row template (P2 #13). XML lives in ui/AccountHold.xml as
-- AccountHold_GearRow with named children Icon / Name / Set / Trait /
-- Quality / Loc. The previous single-text-line fake-column row has been
-- removed entirely.
local ROW_TEMPLATE   = "AccountHold_GearRow"

-- Sort key declarations for ZO_SortFilterList. The keys must match the
-- field names on each masterList entry that we want to sort by.
--
-- caseInsensitive is REQUIRED on every string key: ZO_TableOrderingFunction
-- (esoui/libraries/utility/zo_tableutils.lua) only calls zo_strlower when that
-- flag is set, otherwise it does a raw byte compare, which sorts every
-- capitalized name ahead of every lowercase one and pushes accented names past
-- "Z". Every tiebreaker chain terminates at `name`, which declares none of its
-- own -- ZO_TableOrderingFunction recurses through tiebreaker, so a cycle
-- (name -> locName -> name) would overflow the stack on the first tie.
local SORT_KEYS = {
    name      = { caseInsensitive = true },
    setName   = { caseInsensitive = true, tiebreaker = "name" },
    traitName = { caseInsensitive = true, tiebreaker = "name" },
    quality   = { tiebreaker = "name", isNumeric = true },
    locName   = { caseInsensitive = true, tiebreaker = "name" },
}

-- Expose the sort-key table so the mock harness can assert the caseInsensitive
-- flags and the acyclic tiebreaker chains without the real UI framework.
-- (Consistent with InventoryTab_Gamepad's Tab._Blade test-visible internal.)
Tab._SortKeys = SORT_KEYS

-- Column descriptors used by both the XML row template (widths must
-- match) and the ZO_SortHeader_Initialize calls below. Keep these in
-- sync with the AccountHold_GearRow template in ui/AccountHold.xml.
local SORT_COLUMNS = {
    { key = "name",      width = 220, alignment = TEXT_ALIGN_LEFT,  string = "SI_ACCOUNTHOLD_COL_NAME"     },
    { key = "setName",   width = 140, alignment = TEXT_ALIGN_LEFT,  string = "SI_ACCOUNTHOLD_COL_SET"      },
    { key = "traitName", width = 90,  alignment = TEXT_ALIGN_LEFT,  string = "SI_ACCOUNTHOLD_COL_TRAIT"    },
    { key = "quality",   width = 60,  alignment = TEXT_ALIGN_RIGHT, string = "SI_ACCOUNTHOLD_COL_QUALITY"  },
    { key = "locName",   width = 120, alignment = TEXT_ALIGN_LEFT,  string = "SI_ACCOUNTHOLD_COL_LOCATION" },
}

-- ---------------------------------------------------------------------------
-- Gear-itemtype gate (matches user choice: armor + weapons + jewelry)
-- ---------------------------------------------------------------------------
local function isGear(entry)
    if not entry then return false end
    local t = entry.itemType
    if not t then return false end
    if ITEMTYPE_ARMOR  and t == ITEMTYPE_ARMOR  then return true end
    if ITEMTYPE_WEAPON and t == ITEMTYPE_WEAPON then return true end
    -- ESO has historically modelled jewelry under ITEMTYPE_ARMOR with a
    -- specialized armorType, so the above already catches rings/necklaces.
    -- Some live builds expose ITEMTYPE_JEWELRY explicitly; honour it too.
    if ITEMTYPE_JEWELRY and t == ITEMTYPE_JEWELRY then return true end
    return false
end

-- Localized quality label ("Legendary", "Epic", ...) for the Quality column.
-- The column previously printed the raw enum integer, which made a correctly
-- sorted list look unsorted because the numbers carry no meaning to the player.
-- Sorting still uses the numeric `quality` field, so order is unaffected.
local function qualityLabel(quality)
    if type(quality) ~= "number" then return "-" end
    if type(GetString) == "function" then
        local ok, v = pcall(GetString, "SI_ITEMQUALITY", quality)
        if ok and type(v) == "string" and v ~= "" then return v end
    end
    return tostring(quality)
end

-- ---------------------------------------------------------------------------
-- ZO_SortFilterList subclass — guarded so console builds (which still
-- pull in this file via the manifest) don't error if the global is absent.
-- ---------------------------------------------------------------------------
local GearList

if ZO_SortFilterList and ZO_SortFilterList.Subclass then
    GearList = ZO_SortFilterList:Subclass()

    function GearList:New(control, addonRef)
        local o = ZO_SortFilterList.New(self, control)
        o.addon  = addonRef
        o.filter = {}                  -- live filter table
        -- currentSortKey / currentSortOrder are the fields the framework's own
        -- ZO_SortFilterList:OnSortHeaderClicked writes, so the header group can
        -- drive us directly instead of us shadowing its state in a second pair.
        o.currentSortKey   = "name"
        o.currentSortOrder = ZO_SORT_ORDER_UP
        ZO_ScrollList_AddDataType(o.list, DATA_TYPE_ROW,
            ROW_TEMPLATE, ROW_HEIGHT,
            function(rowControl, data) o:SetupRow(rowControl, data) end)
        ZO_ScrollList_EnableHighlight(o.list, "ZO_ThinListHighlight")
        return o
    end

    -- NOTE: ZO_SORT_ORDER_DOWN is the boolean `false` (zo_tableutils.lua), so
    -- `order or ZO_SORT_ORDER_UP` would quietly rewrite every descending sort
    -- into an ascending one. Only a genuine nil may fall back to UP.
    function GearList:SetSort(key, order)
        if key == nil or SORT_KEYS[key] == nil then key = "name" end
        if order == nil then order = ZO_SORT_ORDER_UP end
        self.currentSortKey   = key
        self.currentSortOrder = order
        self:RefreshSort()
    end

    function GearList:BuildMasterList()
        self.masterList = {}
        if not (self.addon.Index and self.addon.Index.Query) then return end
        -- All item categories (mirrors the guild bank), narrowed by the
        -- category dropdown via filter.categoryKey.
        local rows = self.addon.Index:Query(self.filter)
        local index = self.addon.Index
        for _, row in ipairs(rows) do
            local e = row.entry
            self.masterList[#self.masterList + 1] = {
                icon      = e.icon or "",
                name      = e.name or "",
                setName   = e.setName or "",
                traitName = e.traitName or "",
                -- Resolved the same way Index:Query's quality filter resolves
                -- it, so a row whose cached quality is missing still sorts by
                -- its real quality instead of collapsing to 0.
                quality   = (index.GetEntryQuality and index:GetEntryQuality(e)) or e.quality or 0,
                count     = e.stackCount or 0,
                locName   = row.locationLabel or "",
                row       = row,
            }
        end
    end

    function GearList:FilterScrollList()
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        ZO_ClearNumericallyIndexedTable(scrollData)
        for _, item in ipairs(self.masterList) do
            scrollData[#scrollData + 1] =
                ZO_ScrollList_CreateDataEntry(DATA_TYPE_ROW, item)
        end
    end

    function GearList:SortScrollList()
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        -- ZO_TableOrderingFunction indexes sortKeys[sortKey] with no nil guard,
        -- so an unrecognised key (a stale header, or a column removed from
        -- SORT_COLUMNS) would hard-error mid-sort. Clamp to a known key first.
        local key = self.currentSortKey
        if key == nil or SORT_KEYS[key] == nil then key = "name" end
        local order = self.currentSortOrder
        if order == nil then order = ZO_SORT_ORDER_UP end
        table.sort(scrollData, function(a, b)
            return ZO_TableOrderingFunction(a.data, b.data, key, SORT_KEYS, order)
        end)
    end

    -- Render one row. P2 #13: rows are real multi-control templates with
    -- icon + per-column labels, not a single tab-separated label. The
    -- ZO_ScrollList framework calls SetupRow for each visible row; the
    -- named children in AccountHold_GearRow are populated here.
    function GearList:SetupRow(rowControl, data)
        local entry = data.row.entry
        rowControl.dataEntry = data        -- so our action callbacks can find it

        local icon = rowControl:GetNamedChild("Icon")
        if icon and icon.SetTexture then
            icon:SetTexture(data.icon ~= "" and data.icon or "/esoui/art/icons/icon_missing.dds")
        end

        local function setLabel(name, text)
            local lbl = rowControl:GetNamedChild(name)
            if lbl and lbl.SetText then lbl:SetText(text or "") end
        end
        local nameText = data.name
        if data.count and data.count > 1 then
            nameText = string.format("%s (x%d)", data.name, data.count)
        end
        setLabel("Name",    nameText)
        setLabel("Set",     (data.setName ~= "" and data.setName) or "-")
        setLabel("Trait",   (data.traitName ~= "" and data.traitName) or "-")
        setLabel("Quality", qualityLabel(data.quality))
        setLabel("Loc",     data.locName)

        rowControl:SetMouseEnabled(true)
        rowControl:SetHandler("OnMouseEnter", function()
            if entry.itemLink and ItemTooltip then
                InitializeTooltip(ItemTooltip, rowControl, RIGHT, -10, 0)
                ItemTooltip:SetLink(entry.itemLink)
            end
        end)
        rowControl:SetHandler("OnMouseExit", function()
            if ClearTooltip then ClearTooltip(ItemTooltip) end
        end)
        rowControl:SetHandler("OnMouseUp", function(_, button, upInside)
            if upInside and Tab.OnRowClicked then
                Tab:OnRowClicked(data.row)
            end
        end)
    end
end

-- ---------------------------------------------------------------------------
-- Tab module
-- ---------------------------------------------------------------------------

function Tab:Initialize(addonRef)
    self.addon = addonRef

    -- Console / gamepad-only environments don't load the keyboard inventory
    -- module, so the menu-bar globals are nil. Skip silently — the gamepad
    -- counterpart in InventoryTab_Gamepad.lua provides the equivalent UX.
    if not INVENTORY_MENU_BAR or not INVENTORY_MENU_BAR.modeBar then return end
    if IsConsoleUI and IsConsoleUI() then return end
    -- IsConsoleUI() is NOT sufficient. A PC player in GAMEPAD MODE reports
    -- console=false while running the gamepad UI, so this keyboard-only module
    -- ran anyway and threw during init ("UI.InventoryTabKeyboard failed"),
    -- which safeCall swallowed -- silently removing the tab and every surface
    -- initialised after it in that pass. The gamepad blade already covers this
    -- mode, so skipping is the correct behaviour, not a workaround.
    if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then return end

    local control = _G[CONTROL_NAME]
    if not control then
        addonRef:Debug("Account Gear panel control missing — XML not loaded?")
        return
    end

    -- Build our scene fragment. ZO_FadeSceneFragment fades the control in
    -- and out automatically when the fragment is added/removed via the
    -- modeBar selection. The fragment is parented to nothing visually;
    -- visibility is driven entirely by SHOWING / HIDDEN scene state.
    self.fragment = ZO_FadeSceneFragment:New(control)

    -- Tab button data — same shape as the built-in Inventory / Craft Bag
    -- tab descriptors (see esoui inventorymenubar.lua CreateButtonData).
    -- Use the armor icon since we filter to gear.
    local buttonData = {
        descriptor   = TAB_KEY,
        normal       = "EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds",
        pressed      = "EsoUI/Art/Inventory/inventory_tabIcon_armor_down.dds",
        highlight    = "EsoUI/Art/Inventory/inventory_tabIcon_armor_over.dds",
        clickSound   = SOUNDS.QUICKSLOT_CLOSE,
        callback     = function(...) INVENTORY_MENU_BAR:OnButtonClicked(...) end,
    }

    -- Append our tab. Group with the same layout fragment the built-in
    -- backpack and craft-bag tabs use so the menu bar / divider stay
    -- consistent.
    INVENTORY_MENU_BAR.modeBar:Add(
        TAB_KEY,
        { self.fragment, BACKPACK_MENU_BAR_LAYOUT_FRAGMENT },
        buttonData,
        nil)

    -- Build the inner UI now that the fragment is registered.
    self:_BuildContent(control)

    -- Refresh the list any time scanner data changes, but only while our tab is
    -- actually visible -- otherwise a background inventory change would rebuild
    -- a hidden list (a full re-query) for nothing.
    if addonRef.Index and addonRef.Index.RegisterChangeCallback then
        addonRef.Index:RegisterChangeCallback(function()
            if self.fragment and self.fragment.GetState
               and self.fragment:GetState() ~= SCENE_FRAGMENT_SHOWN then
                return
            end
            self:Refresh()
        end)
    end

    -- Ensure the holds summary stays current when holds are placed/cancelled.
    self:_RefreshSummary()
end

function Tab:_BuildContent(control)
    -- Search box (PC has free-text input; on console SupportsFreeTextSearch
    -- returns false, in which case we hide the search container — but this
    -- module only runs on PC, so unconditionally wire it).
    local search = control:GetNamedChild("SearchContainerEdit")
    if search then
        search:SetText("")
        search:SetHandler("OnTextChanged", function(editBox)
            if self.gearList then
                self.gearList.filter.text = editBox:GetText()
                self.gearList:RefreshFilters()
            end
        end)
    end

    -- Filter dropdowns row. Each dropdown narrows the masterList by one
    -- field. We build these with ZO_ComboBox_ObjectFromContainer using
    -- inline-created child controls so we don't need extra XML virtual
    -- templates. If ZO_ComboBox is unavailable (very old build), the row
    -- stays empty and the user can still search by text.
    self:_BuildFilterRow(control:GetNamedChild("Filters"))

    -- Scroll list. ZO_SortFilterList:InitializeSortFilterList resolves its own
    -- children from the control it is given -- self.list = GetNamedChild("List")
    -- and the "Headers" container it builds the sort header group from -- so it
    -- must be handed the PANEL, not the list. Passing the list control made it
    -- look for <panel>ListList, leaving self.list nil and erroring on the first
    -- ZO_ScrollList call.
    if GearList and control:GetNamedChild("List") then
        self.gearList = GearList:New(control, self.addon)
    end

    -- Sort headers. Built AFTER the list so each column can be registered with
    -- the ZO_SortHeaderGroup the base class already created for "Headers".
    self:_BuildHeaders(control:GetNamedChild("Headers"))

    -- Action buttons.
    local actions = control:GetNamedChild("Actions")
    if actions then
        local placeBtn  = actions:GetNamedChild("PlaceHold")
        local setBtn    = actions:GetNamedChild("PlaceSetHold")
        local cancelBtn = actions:GetNamedChild("CancelHold")
        local refreshBtn = actions:GetNamedChild("Refresh")
        if placeBtn then
            placeBtn:SetText(GetString(SI_ACCOUNTHOLD_BTN_PLACE_ITEM_HOLD))
            placeBtn:SetHandler("OnClicked", function() self:OnPlaceHoldClicked() end)
        end
        if setBtn then
            setBtn:SetText(GetString(SI_ACCOUNTHOLD_BTN_PLACE_SET_HOLD))
            setBtn:SetHandler("OnClicked", function() self:OnPlaceSetHoldClicked() end)
        end
        if cancelBtn then
            cancelBtn:SetText(GetString(SI_ACCOUNTHOLD_BTN_CANCEL_HOLD))
            cancelBtn:SetHandler("OnClicked", function() self:OnCancelHoldClicked() end)
        end
        if refreshBtn then
            refreshBtn:SetText(GetString(SI_ACCOUNTHOLD_BTN_REFRESH))
            refreshBtn:SetHandler("OnClicked", function() self:Refresh() end)
        end
    end
end

-- ---------------------------------------------------------------------------
-- Filter row
-- ---------------------------------------------------------------------------
function Tab:_BuildFilterRow(parent)
    if not parent or not ZO_ComboBox_ObjectFromContainer then return end
    -- We don't define XML for the dropdowns; create them programmatically
    -- via WINDOW_MANAGER. Each combo is anchored relative to the previous
    -- one so the row stays compact.
    local function addCombo(name, width, prevAnchor, items, onSelect)
        local combo = WINDOW_MANAGER:CreateControlFromVirtual(
            parent:GetName() .. name, parent, "ZO_ComboBox")
        combo:SetWidth(width)
        if prevAnchor then
            combo:SetAnchor(LEFT, prevAnchor, RIGHT, 6, 0)
        else
            combo:SetAnchor(LEFT, parent, LEFT, 0, 0)
        end
        local box = ZO_ComboBox_ObjectFromContainer(combo)
        box:ClearItems()
        for _, item in ipairs(items) do
            box:AddItem(box:CreateItemEntry(item.label, function(_, _, entry)
                if onSelect then onSelect(entry.label) end
                if self.gearList then self.gearList:RefreshFilters() end
            end))
        end
        box:SelectFirstItem()
        return combo
    end

    -- Category filter (guild-bank-style: All / Weapons / Armor / ...).
    -- This is the primary way to narrow across ALL item categories now that
    -- the blade lists everything, not just gear.
    local categories = { { label = GetString(SI_ACCOUNTHOLD_CAT_ALL), key = "all" } }
    if self.addon.Index and self.addon.Index.GetCategories then
        categories = self.addon.Index:GetCategories() or categories
    end
    local catCombo = addCombo("Category", 150, nil, categories, function(label)
        self.gearList.filter.categoryKey = "all"
        for _, c in ipairs(categories) do
            if c.label == label then self.gearList.filter.categoryKey = c.key end
        end
    end)

    -- Set filter (built dynamically from currently-known sets).
    local sets = { { label = GetString(SI_ACCOUNTHOLD_FILTER_ALL) } }
    if self.addon.Index and self.addon.Index.GetKnownSets then
        for _, s in ipairs(self.addon.Index:GetKnownSets()) do
            sets[#sets + 1] = { label = s.name, setId = s.setId }
        end
    end
    local setCombo = addCombo("Set", 160, catCombo, sets, function(label)
        self.gearList.filter.setName = (label ~= GetString(SI_ACCOUNTHOLD_FILTER_ALL)) and label or nil
        -- Resolve setId from chosen label.
        self.gearList.filter.setId = nil
        for _, s in ipairs(sets) do
            if s.label == label then self.gearList.filter.setId = s.setId end
        end
    end)

    -- Trait filter.
    local traits = { { label = GetString(SI_ACCOUNTHOLD_FILTER_ALL) } }
    if self.addon.Index and self.addon.Index.GetKnownTraits then
        for _, t in ipairs(self.addon.Index:GetKnownTraits()) do
            traits[#traits + 1] = { label = t.name, traitType = t.traitType }
        end
    end
    local traitCombo = addCombo("Trait", 140, setCombo, traits, function(label)
        self.gearList.filter.traitType = nil
        for _, t in ipairs(traits) do
            if t.label == label then self.gearList.filter.traitType = t.traitType end
        end
    end)

    -- Quality filter. Use the game's own quality-tier strings
    -- (SI_ITEMQUALITY0..SI_ITEMQUALITY5) so the dropdown is localized to
    -- whatever client locale the user is running.
    local qualities = { { label = GetString(SI_ACCOUNTHOLD_FILTER_ALL) } }
    for q = 0, 5 do
        local sid = _G["SI_ITEMQUALITY" .. q]
        local label = (sid and GetString(sid)) or tostring(q)
        qualities[#qualities + 1] = { label = label, value = q }
    end
    local qualityCombo = addCombo("Quality", 130, traitCombo, qualities, function(label)
        self.gearList.filter.quality = nil
        for _, q in ipairs(qualities) do
            if q.label == label then self.gearList.filter.quality = q.value end
        end
    end)

    -- Bound filter.
    local boundOptions = {
        { label = GetString(SI_ACCOUNTHOLD_FILTER_ALL),         value = nil },
        { label = GetString(SI_ACCOUNTHOLD_FILTER_BOUND_ONLY),  value = "boundOnly" },
        { label = GetString(SI_ACCOUNTHOLD_FILTER_UNBOUND_ONLY),value = "unboundOnly" },
    }
    addCombo("Bound", 130, qualityCombo, boundOptions, function(label)
        self.gearList.filter.bound = nil
        for _, b in ipairs(boundOptions) do
            if b.label == label then self.gearList.filter.bound = b.value end
        end
    end)
end

-- ---------------------------------------------------------------------------
-- Sort headers (P2 #13)
-- Build a real ZO_SortHeaderGroup so clicking a column header actually
-- sorts the list and shows the up/down arrow indicator. Uses the canonical
-- ZO_SortHeader_Initialize per-column wiring; falls back to plain buttons
-- only when the framework helpers aren't present (very old game build).
--
-- Two things here are load-bearing and were previously missing:
--
--  1. We REUSE the group ZO_SortFilterList:InitializeSortFilterList already
--     built for the panel's "Headers" child. Constructing a second group over
--     the same container makes a second "<Headers>Arrow" control from the same
--     virtual template under a name that already exists, and leaves the list
--     listening on a group that owns no headers.
--  2. ZO_SortHeader_Initialize does NOT join a header to a group -- read the
--     real implementation (esoui/libraries/zo_sortheadergroup): it only sets
--     control.key / initialDirection / name. It is ZO_SortHeaderGroup:AddHeader
--     that appends to sortHeaders AND sets control.sortHeaderGroup. Without it
--     ZO_SortHeader_OnMouseUp finds no group and clicking a column does
--     nothing, ZO_SortHeader_OnMouseEnter errors indexing a nil group, and
--     SelectHeaderByKey can never resolve a header.
-- ---------------------------------------------------------------------------
function Tab:_BuildHeaders(headerControl)
    if not headerControl or not ZO_SortHeaderGroup then return end

    -- Prefer the group the base class made; only build one if it's absent.
    local group = self.gearList and self.gearList.sortHeaderGroup
    local ownsGroup = false
    if not group then
        group = ZO_SortHeaderGroup:New(headerControl, true)
        ownsGroup = true
    end
    self.headers = group

    local prev
    for _, col in ipairs(SORT_COLUMNS) do
        local btn
        if WINDOW_MANAGER and WINDOW_MANAGER.CreateControlFromVirtual then
            btn = WINDOW_MANAGER:CreateControlFromVirtual(
                headerControl:GetName() .. "_" .. col.key,
                headerControl, "ZO_SortHeader")
        end
        -- ZO_SortHeader virtual template not available — fall back to a
        -- plain button so the column header is still visible and clickable.
        if not btn and WINDOW_MANAGER and WINDOW_MANAGER.CreateControl then
            btn = WINDOW_MANAGER:CreateControl(
                headerControl:GetName() .. "_" .. col.key,
                headerControl, CT_BUTTON or 0)
        end
        if btn then
            btn:SetDimensions(col.width, 22)
            if prev then
                btn:SetAnchor(LEFT, prev, RIGHT, 4, 0)
            else
                btn:SetAnchor(LEFT, headerControl, LEFT, 0, 0)
            end
            local label = (col.string and _G[col.string] and GetString(_G[col.string])) or col.key
            if ZO_SortHeader_Initialize and group.AddHeader then
                -- Canonical wiring: set the label, key, alignment and font...
                ZO_SortHeader_Initialize(btn, label, col.key,
                    ZO_SORT_ORDER_UP,
                    col.alignment or TEXT_ALIGN_LEFT,
                    "ZoFontGameMedium")
                -- ...then actually join the group, which is what makes the
                -- header clickable and hover-safe.
                group:AddHeader(btn)
            else
                if btn.SetFont then btn:SetFont("ZoFontGameMedium") end
                if btn.SetText then btn:SetText(label) end
                btn:SetHandler("OnClicked", function()
                    if self.gearList then
                        local nextOrder = (self.gearList.currentSortKey == col.key
                            and self.gearList.currentSortOrder == ZO_SORT_ORDER_UP)
                            and ZO_SORT_ORDER_DOWN or ZO_SORT_ORDER_UP
                        self.gearList:SetSort(col.key, nextOrder)
                    end
                end)
            end
            prev = btn
        end
    end

    -- The base class already routes HEADER_CLICKED into the list's
    -- OnSortHeaderClicked (which sets currentSortKey/currentSortOrder and calls
    -- RefreshSort). Only wire our own callback when we built the group, or the
    -- list would sort twice per click.
    if ownsGroup and group.RegisterCallback then
        group:RegisterCallback("HeaderClicked",
            function(key, order)
                if self.gearList then
                    self.gearList:SetSort(key, order)
                end
            end)
    end

    -- Show "Name" as the active column. SUPPRESS_CALLBACKS avoids a redundant
    -- sort before the list has any data.
    if group.SelectHeaderByKey then
        local SUPPRESS_CALLBACKS, FORCE_RESELECT = true, true
        group:SelectHeaderByKey("name", SUPPRESS_CALLBACKS, FORCE_RESELECT)
    end
end

-- ---------------------------------------------------------------------------
-- Selection + actions
-- ---------------------------------------------------------------------------

function Tab:OnRowClicked(row)
    self.selectedRow = row
end

function Tab:OnPlaceHoldClicked()
    local row = self.selectedRow
    if not row then return end
    local entry = row.entry
    -- P1 #9: craft-bag rows are already account-wide; placing a hold on
    -- them is meaningless. Refuse and surface the same disabled subtitle
    -- the gamepad keystrip uses.
    if row.isCraftBag then
        if self.addon and self.addon.Log then
            self.addon:Log(GetString(SI_ACCOUNTHOLD_DISABLED_CRAFT_BAG))
        end
        return
    end
    if entry and entry.isCharacterBound then
        if self.addon and self.addon.Log then
            self.addon:Log(GetString(SI_ACCOUNTHOLD_DISABLED_BOUND))
        end
        return
    end
    -- Reserve exactly the highlighted concrete item/stack. There is no
    -- set-vs-per-piece chooser: set holds are placed from the separate
    -- "Reserve Set" button (OnPlaceSetHoldClicked). BeginPlaceHold first checks
    -- for an existing item reservation and prompts to override it.
    if self.addon.UI and self.addon.UI.HoldDialog
       and self.addon.UI.HoldDialog.BeginPlaceHold then
        self.addon.UI.HoldDialog:BeginPlaceHold(row, "item")
    end
    self:_RefreshSummary()
end

-- Reserve one set-level hold keyed by the selected row's setId. Mirrors the
-- gamepad (X) action. Enabled only for gear that carries a set bonus; the
-- button is wired in Build() and simply no-ops on a non-set row.
function Tab:OnPlaceSetHoldClicked()
    local row = self.selectedRow
    if not row or not row.entry then return end
    if row.isCraftBag then
        if self.addon and self.addon.Log then
            self.addon:Log(GetString(SI_ACCOUNTHOLD_DISABLED_CRAFT_BAG))
        end
        return
    end
    if row.entry.isCharacterBound then
        if self.addon and self.addon.Log then
            self.addon:Log(GetString(SI_ACCOUNTHOLD_DISABLED_BOUND))
        end
        return
    end
    if not (row.entry.setId and row.entry.setId ~= 0) then return end
    if self.addon.UI and self.addon.UI.HoldDialog
       and self.addon.UI.HoldDialog.BeginPlaceHold then
        self.addon.UI.HoldDialog:BeginPlaceHold(row, "set")
    end
    self:_RefreshSummary()
end

function Tab:OnCancelHoldClicked()
    local row = self.selectedRow
    if not row then return end
    -- Find any active hold whose itemSignature OR setId matches this row.
    -- Cancel all matching open holds — keeps the UX simple ("clear the
    -- holds for this thing").
    if not (self.addon.sv and self.addon.sv.holds) then return end
    local cancelled = 0
    for id, hold in pairs(self.addon.sv.holds) do
        if hold.status ~= "delivered" and hold.status ~= "cancelled" then
            local match = false
            if hold.holdType == "item"
               and hold.itemSignature == row.entry.itemSignature then
                match = true
            elseif hold.holdType == "set"
               and hold.setId == row.entry.setId then
                match = true
            end
            if match then
                self.addon.Holds:Cancel(id)
                cancelled = cancelled + 1
            end
        end
    end
    if cancelled > 0 then
        self.addon:Log(GetString(SI_ACCOUNTHOLD_LOG_CANCELLED_N):format(cancelled))
    end
    self:_RefreshSummary()
    self:Refresh()
end

function Tab:Refresh()
    if self.gearList then self.gearList:RefreshData() end
    self:_RefreshSummary()
end

function Tab:_RefreshSummary()
    local control = _G[CONTROL_NAME]
    if not control then return end
    local label = control:GetNamedChild("HoldsSummary")
    if not label then return end
    local active = 0
    if self.addon.sv and self.addon.sv.holds then
        for _, h in pairs(self.addon.sv.holds) do
            if h.status ~= "delivered" and h.status ~= "cancelled" then
                active = active + 1
            end
        end
    end
    label:SetText(GetString(SI_ACCOUNTHOLD_SUMMARY_HOLDS):format(active))
end
