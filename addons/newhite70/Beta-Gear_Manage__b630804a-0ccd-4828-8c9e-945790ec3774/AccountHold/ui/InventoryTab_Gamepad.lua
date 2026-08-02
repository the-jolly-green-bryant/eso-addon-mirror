-- Quartermaster/ui/InventoryTab_Gamepad.lua
--
-- Console / gamepad equivalent of the keyboard "Account Gear" tab.
--
-- The gamepad inventory (ZO_GamepadInventory / GAMEPAD_INVENTORY, scene
-- gamepad_inventory_root) is a ZO_Gamepad_ParametricList_Screen. Its built-in
-- header tabs (Items / Craft Bag) are NOT separate scenes: each tab's callback
-- calls ZO_GamepadInventory:SwitchActiveList(<listDescriptor>), which swaps the
-- active parametric list IN PLACE within the one inventory scene (see ESOUI
-- esoui/ingame/inventory/gamepad/gamepadinventory.lua:300 and the base class
-- esoui/common/gamepad/zo_gamepadparametricscrolllistscreen.lua:164 / :209).
--
-- Our third tab therefore works the SAME way rather than launching a foreign
-- scene (which corrupted the inventory's tab state and broke the menu on
-- reopen). We:
--   1. Register our own managed list on the inventory via its own AddList()
--      framework. AddList builds the list on a proper XML-templated container
--      (ZO_Gamepad_ParametricList_Screen_ListContainer), so — unlike a
--      hand-rolled runtime control — it has a valid async render pass and
--      cannot crash the session.
--   2. Make our tab a first-class list descriptor by wrapping SwitchActiveList
--      so it understands ACCOUNT_HOLD_LIST, exactly like the built-in enums.
--   3. Wrap RefreshHeader so the header keeps showing the tab strip (with our
--      tab) while our list is current — the stock RefreshHeader would fall
--      through to itemListHeaderData, which has no tabBarEntries.
--
-- Because our list is a normal list descriptor, the framework's own show/hide
-- handling (SwitchActiveList(nil) on hide, SwitchActiveList(previousListType)
-- on show) restores/returns to it correctly — no separate scene, no corruption.

AccountHold = AccountHold or {}
AccountHold.UI = AccountHold.UI or {}
AccountHold.UI.InventoryTabGamepad = AccountHold.UI.InventoryTabGamepad or {}

local Tab = AccountHold.UI.InventoryTabGamepad

-- Our synthetic list descriptor. Built-in descriptors (INVENTORY_CATEGORY_LIST
-- etc) are numbers, so a string can never collide with them.
local ACCOUNT_HOLD_LIST = "ACCOUNT_HOLD_INVENTORY_LIST"

-- Name used for our list inside GAMEPAD_INVENTORY.lists (AddList reserves
-- "Main"; any other name is fine).
local LIST_NAME = "AccountHold"

-- Row template for ITEM rows. The stock gamepad inventory registers and adds
-- ZO_GamepadItemSubEntryTemplate for every item row (esoui/esoui@master
-- esoui/ingame/inventory/gamepad/gamepadinventory.lua:1153, :1154, :1349,
-- :1351; the shared list helper defaults to the same template at
-- esoui/ingame/inventory/gamepad/inventorylist_gamepad.lua:1). Its label
-- inherits ZO_GamepadSubMenuEntryLabelTemplate — ZoFontGamepad34 with NO
-- modifyTextType (esoui/common/gamepad/zo_gamepadtemplatescommon.xml:188) —
-- and its icon carries a SubStatusIcon child for the locked / BoP-tradeable
-- overlay (:283-287).
--
-- ZO_GamepadItemEntryTemplate, which we used to use for items, resolves to
-- ZO_GamepadMenuEntryLabelTemplate instead: modifyTextType="UPPERCASE"
-- (:212) and no SubStatusIcon. That is the whole reason our item names
-- SHOUTED while the native Items tab did not. It is what the native CATEGORY
-- list uses (gamepadinventory.lua:982-984), not the item list.
--
-- The fallback is retained so a client that cannot resolve the sub-entry
-- template degrades to exactly what we shipped before instead of an empty tab.
local ITEM_ROW_TEMPLATE          = "ZO_GamepadItemSubEntryTemplate"
local ITEM_ROW_TEMPLATE_FALLBACK = "ZO_GamepadItemEntryTemplate"

-- Keep any error text we surface to chat to a single short line. The user
-- relies on short debug lines being findable — never dump a multi-line
-- traceback into chat. Collapses newlines and caps length.
local function shortErr(err)
    local s = tostring(err or "")
    s = s:gsub("[\r\n].*$", "")   -- keep only the first line
    if #s > 120 then s = s:sub(1, 117) .. "..." end
    return s
end

-- ---------------------------------------------------------------------------
-- Native row / tooltip visuals: PURE helpers
-- ---------------------------------------------------------------------------
-- Deliberately free of ZO_* globals (every base-game call is behind a type
-- check, with an injection point for the mock harness) so these are the
-- testable surface for how a row LOOKS. Every rule below is taken from the
-- published UI source, esoui/esoui@master:
--
--   * Names reach a native row already formatted with
--     zo_strformat(SI_TOOLTIP_ITEM_NAME, rawName)
--     (esoui/ingame/inventory/sharedinventory.lua:625), and the tooltip title
--     formats identically (esoui/publicallingames/tooltip/itemtooltips.lua:32).
--     Our Scanner caches the RAW GetItemName result (src/Scanner.lua:103), so
--     an unformatted name can render with its "^Fn"/"^m" gender+article
--     markers still attached.
--   * A native row is coloured by DISPLAY quality, not functional quality:
--     InitializeInventoryVisualData does
--     SetNameColors(self:GetColorsBasedOnQuality(self.displayQuality or self.quality))
--     (esoui/common/gamepad/zo_gamepadentrydata.lua:32) and
--     GetColorsBasedOnQuality is GetItemQualityColor / GetDimItemQualityColor
--     (:209-214). Our Scanner caches FUNCTIONAL quality (src/Scanner.lua:105),
--     so we re-resolve the display value off the item link when we can.
--   * Secondary detail belongs in SUB LABELS, never concatenated into the
--     name. The row label is a single ELLIPSIS-clipped line
--     (zo_gamepadtemplatescommon.xml:188), so folding a location or a status
--     into it eats the item name itself at TV distance. The native precedent
--     for an item row with an always-visible sub label is
--     InitializeTradingHouseVisualData (zo_gamepadentrydata.lua:48-52):
--     SetSubLabelColors(ZO_NORMAL_TEXT) + SetShowUnselectedSublabels(true).
-- ---------------------------------------------------------------------------

-- Format a raw item name the way the base game does. `formatter` is an
-- injection point: the mock harness has no zo_strformat, so tests pass their
-- own to exercise the real branch.
function Tab.FormatItemName(name, formatter)
    if type(name) ~= "string" or name == "" then return "" end
    formatter = formatter or (type(zo_strformat) == "function" and zo_strformat) or nil
    if type(formatter) ~= "function" then return name end
    -- SI_TOOLTIP_ITEM_NAME is the id the base game uses for item names. Fall
    -- back to its literal expansion so a client (or harness) without the
    -- string id registered still strips the markers instead of erroring.
    local fmt = SI_TOOLTIP_ITEM_NAME
    if fmt == nil then fmt = "<<t:1>>" end
    local ok, out = pcall(formatter, fmt, name)
    if ok and type(out) == "string" and out ~= "" then return out end
    return name
end

-- The quality a native row COLOURS by: display quality, resolved live off the
-- item link, falling back to whatever the Scanner cached. `overrides` is a
-- table of stand-in API functions for tests.
function Tab.ResolveDisplayQuality(entry, overrides)
    if type(entry) ~= "table" then return nil end
    if type(entry.displayQuality) == "number" then return entry.displayQuality end
    overrides = type(overrides) == "table" and overrides or {}
    local link   = entry.itemLink
    local hasLink = type(link) == "string" and link ~= ""
    local function ask(fn)
        if type(fn) ~= "function" or not hasLink then return nil end
        local ok, q = pcall(fn, link)
        if ok and type(q) == "number" then return q end
        return nil
    end
    local q = ask(overrides.display or GetItemLinkDisplayQuality)
    if q then return q end
    if type(entry.quality) == "number" then return entry.quality end
    return ask(overrides.functional or GetItemLinkFunctionalQuality)
        or ask(overrides.legacy or GetItemLinkQuality)
end

-- Split a row into the two things the gamepad template renders separately: the
-- single-line NAME, and the sub labels beneath it. ONLY the item name may end
-- up in the name; everything else is a sub label (see the TV-distance note
-- above). Returns (text, subLabels).
--
-- The location sub label is OPTIONAL and defaults OFF. The player asked for the
-- location to live on the tooltip rather than under every row in the scrolling
-- blade -- but explicitly asked that the code stay so it can be switched back
-- on. It is therefore a setting, not a deletion. The tooltip always shows the
-- location regardless (see UpdateTooltip); this only controls the row.
function Tab.RowLabels(row, formatter, showLocation)
    row = type(row) == "table" and row or {}
    local e = type(row.entry) == "table" and row.entry or {}
    local text = Tab.FormatItemName(e.name, formatter)
    if text == "" then text = "?" end
    local subLabels = {}
    if showLocation and type(row.locationLabel) == "string" and row.locationLabel ~= "" then
        subLabels[#subLabels + 1] = row.locationLabel
    end
    return text, subLabels
end

-- Read the row-location setting. Defaults FALSE (tooltip only), which is what
-- the player asked for; guarded so a missing SavedVariables key can never
-- error a repaint.
function Tab.ShowRowLocation()
    local a = AccountHold
    local sv = a and a.sv
    local s  = sv and sv.settings
    if type(s) ~= "table" then return false end
    return s.showRowLocation == true
end

-- Can this row be handed to LayoutBagItem? `liveLink` is the item link
-- currently sitting in that bag slot (nil when unknown / unreadable).
--
-- Native lays the highlighted inventory row out with
-- GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_LEFT_TOOLTIP, bagId, slotIndex)
-- (gamepadinventory.lua:1133), which is a RICHER card than the link-only one:
-- LayoutBagItem adds the player-locked marker, the crafter's name, the
-- bind-on-pickup trade timer and the armory-build lines, and counts the stack
-- the way that bag counts it (itemtooltips.lua:1686-1727). But it reads the
-- LIVE slot, so it is only correct while the slot still holds the very item
-- this row describes. Rows for another character's items — and any slot that
-- has since been emptied or swapped — must keep the link-only card.
function Tab.RowHasLiveSlot(row, liveLink)
    if type(row) ~= "table" then return false end
    if not row.isLocal then return false end
    if type(row.bagId) ~= "number" or type(row.slotIndex) ~= "number" then return false end
    local e = type(row.entry) == "table" and row.entry or {}
    if type(e.itemLink) ~= "string" or e.itemLink == "" then return false end
    return liveLink == e.itemLink
end

-- Read the item link a live bag slot currently holds. Returns nil when the bag
-- is not readable (another character's bag, a closed bank, no API).
local function liveItemLink(bagId, slotIndex)
    if type(GetItemLink) ~= "function" then return nil end
    if type(bagId) ~= "number" or type(slotIndex) ~= "number" then return nil end
    local style = (type(LINK_STYLE_DEFAULT) == "number") and LINK_STYLE_DEFAULT or nil
    local ok, link = pcall(GetItemLink, bagId, slotIndex, style)
    if ok and type(link) == "string" and link ~= "" then return link end
    return nil
end

-- ---------------------------------------------------------------------------
-- Blade: the Quartermaster content that lives inside the inventory scene as an
-- in-place list. There is exactly one instance (Tab._blade).
-- ---------------------------------------------------------------------------
local Blade = {}
Blade.__index = Blade

function Blade.New(addonRef)
    local o = setmetatable({}, Blade)
    o.addon        = addonRef
    o.filter       = {}
    o.rows         = {}
    o.categories   = nil
    o.categoryIndex = 1
    o.sortKey      = "name"
    o.list         = nil
    o.keybinds     = nil
    return o
end

-- Expose the Blade class so the mock harness can build a blade in isolation and
-- assert its A/X/Y keybind contract without standing up the whole gamepad
-- inventory scene. (Consistent with the other test-visible internals such as
-- Tab._records / Tab:_ActivateTab.)
Tab._Blade = Blade

function Blade:EnsureCategories()
    if not self.categories and self.addon.Index and self.addon.Index.GetCategories then
        self.categories = self.addon.Index:GetCategories() or {}
    end
    self.categories = self.categories or { { key = "all", label = "All" } }
end

function Blade:CurrentCategoryLabel()
    self:EnsureCategories()
    local c = self.categories[self.categoryIndex]
    return c and c.label or "All"
end

-- The current category's key ("all", "weapon", "armor", "consumable", ...).
function Blade:_CurrentCategoryKey()
    self:EnsureCategories()
    return (self.categories[self.categoryIndex] or {}).key or "all"
end

-- Whether the current category can contain gear (weapons / armor / jewelry).
-- "all" counts as gear-bearing because the unfiltered list may include
-- equipment; "equipped" is gear by definition (worn pieces only). Used for the
-- Set filter's visibility.
function Blade:_CategoryHasGear()
    local k = self:_CurrentCategoryKey()
    return k == "all" or k == "equipped" or k == "weapon" or k == "armor"
        or k == "jewelry" or k == "companion"
end

-- The ITEM_TRAIT_TYPE_CATEGORY_* that applies to the current category, or nil
-- when traits don't apply (all / consumables / materials / glyphs / ...).
-- Drives the Trait filter's visibility AND its option list so the traits shown
-- are the ones the guild store shows for that category (weapon vs armor vs
-- jewelry traits).
function Blade:_TraitCategoryForCurrent()
    local k = self:_CurrentCategoryKey()
    if k == "weapon"  then return _G["ITEM_TRAIT_TYPE_CATEGORY_WEAPON"] end
    if k == "armor"   then return _G["ITEM_TRAIT_TYPE_CATEGORY_ARMOR"] end
    if k == "jewelry" then return _G["ITEM_TRAIT_TYPE_CATEGORY_JEWELRY"] end
    return nil
end

function Blade:_TraitKindForCurrent()
    local k = self:_CurrentCategoryKey()
    if k == "weapon" then return "weapon" end
    if k == "armor" then return "armor" end
    if k == "jewelry" then return "jewelry" end
    if k == "companion" then
        if self.filter.companionType == "weapon" then return "companionWeapon" end
        if self.filter.companionType == "armor" then return "companionArmor" end
        if self.filter.companionType == "jewelry" then return "companionJewelry" end
    end
    return nil
end

function Blade:CycleCategory()
    self:EnsureCategories()
    self.categoryIndex = (self.categoryIndex % #self.categories) + 1
    self:Populate()
    -- Re-sync the keybind labels (the category cycle button shows the next
    -- category name) now that the filter changed.
    if type(GAMEPAD_INVENTORY) == "table" and GAMEPAD_INVENTORY.RefreshKeybinds then
        pcall(function() GAMEPAD_INVENTORY:RefreshKeybinds() end)
    end
end

-- The highlighted row (drives Place/Cancel Hold). Reads the entry the
-- parametric list currently targets; each entry carries its source row.
function Blade:GetSelectedRow()
    local list = self.list
    if not (list and list.GetTargetData) then return nil end
    local data = list:GetTargetData()
    return data and data.accountHoldRow or nil
end

-- Build an O(1) lookup of the account's ACTIVE holds, keyed by the two things
-- a row can match on. Repainting the list used to mean rescanning every hold
-- for every row (O(rows x holds)); with a few hundred rows and a busy hold
-- table that is a visible hitch on a repaint. Built once per Populate.
function Blade:_BuildHoldLookup()
    local bySignature, bySet = {}, {}
    local holds = self.addon and self.addon.sv and self.addon.sv.holds
    if type(holds) == "table" then
        for _, hold in pairs(holds) do
            local status = hold.status
            if status ~= "delivered" and status ~= "cancelled" then
                if hold.holdType == "item" and hold.itemSignature then
                    bySignature[hold.itemSignature] = bySignature[hold.itemSignature] or hold
                elseif hold.holdType == "set" and hold.setId then
                    bySet[hold.setId] = bySet[hold.setId] or hold
                end
            end
        end
    end
    return { bySignature = bySignature, bySet = bySet }
end

-- Does this row's item carry an active hold? Pure given a lookup table.
function Tab.RowIsReserved(row, lookup)
    if type(row) ~= "table" or type(lookup) ~= "table" then return false end
    local e = type(row.entry) == "table" and row.entry or {}
    local bySig = type(lookup.bySignature) == "table" and lookup.bySignature or {}
    local bySet = type(lookup.bySet) == "table" and lookup.bySet or {}
    if e.itemSignature ~= nil and bySig[e.itemSignature] ~= nil then return true end
    if e.setId ~= nil and bySet[e.setId] ~= nil then return true end
    return false
end

-- Return a short, human-readable hold/reservation status for the item on this
-- row, the name of the character the item is reserved FOR, and — when the
-- match came from a SET hold — the name of that set. Returns nil when the item
-- has no active hold. There is no per-item helper in the Holds module, so we
-- scan the hold table and match on itemSignature (item holds) or setId (set
-- holds). Active == not delivered/cancelled.
--
-- The set name is returned separately because a set reservation is satisfied by
-- ANY piece of the set. Showing only "Reserved" on a single piece reads as a
-- reservation for that one item, which is exactly backwards: every other
-- character carrying a piece of that set should be depositing it.
function Blade:HoldStatusLabel(row)
    local e = row and row.entry
    if not e then return nil end
    local holds = self.addon.sv and self.addon.sv.holds
    if type(holds) ~= "table" then return nil end
    for _, hold in pairs(holds) do
        local status = hold.status
        if status ~= "delivered" and status ~= "cancelled" then
            local match, setName = false, nil
            if hold.holdType == "item" and hold.itemSignature
               and hold.itemSignature == e.itemSignature then
                match = true
            elseif hold.holdType == "set" and hold.setId and e.setId
               and hold.setId == e.setId then
                match = true
                -- Prefer the live API; fall back to the name the Scanner
                -- recorded on the entry so this still reads correctly under the
                -- mock harness and on any client where the API is absent.
                if type(GetItemSetName) == "function" then
                    local ok, n = pcall(GetItemSetName, hold.setId)
                    if ok and type(n) == "string" and n ~= "" then setName = n end
                end
                if not setName and type(e.setName) == "string" and e.setName ~= "" then
                    setName = e.setName
                end
            end
            if match then
                -- Name of the character this item is reserved FOR. Read the
                -- record table directly (NOT GetCharacterRecord, which would
                -- fabricate a record under the current character's name for an
                -- unknown id).
                local holderId = hold.targetCharacterId or hold.requestedByCharacterId
                local holderName
                if holderId and self.addon.sv and self.addon.sv.characters then
                    local rec = self.addon.sv.characters[holderId]
                    holderName = rec and rec.name
                end
                -- Collapse the internal status enum (open / awaiting_deposit /
                -- in_transit:<container> / ...) into a friendly indicator.
                local label
                if status == "open" then
                    label = GetString(SI_ACCOUNTHOLD_STATUS_RESERVED)
                elseif status == "awaiting_deposit" then
                    label = GetString(SI_ACCOUNTHOLD_STATUS_AWAITING)
                elseif type(status) == "string" and status:sub(1, 10) == "in_transit" then
                    label = GetString(SI_ACCOUNTHOLD_STATUS_IN_TRANSIT)
                else
                    label = GetString(SI_ACCOUNTHOLD_STATUS_RESERVED)
                end
                -- Name the set on the status word itself, so the player sees
                -- "Reserved: Rush of Agony" rather than a bare "Reserved" that
                -- looks like it applies only to this one piece.
                if setName then
                    label = string.format(GetString(SI_ACCOUNTHOLD_STATUS_SET_SUFFIX),
                                          label, setName)
                end
                return label, holderName, setName
            end
        end
    end
    return nil
end

-- Build one of our custom tooltip lines. Every step is guarded: a missing
-- string id, a missing zo_strformat or a bad substitution must drop the LINE,
-- never the whole tooltip (and never the inventory screen behind it).
local function tooltipLine(stringId, ...)
    local pattern
    if type(GetString) == "function" and stringId ~= nil then
        local ok, s = pcall(GetString, stringId)
        if ok and type(s) == "string" and s ~= "" then pattern = s end
    end
    if type(pattern) ~= "string" then return nil end
    if type(zo_strformat) == "function" then
        local ok, out = pcall(zo_strformat, pattern, ...)
        if ok and type(out) == "string" and out ~= "" then return out end
    end
    -- No formatter (or it refused the pattern): show the unsubstituted string
    -- rather than nothing, so the line still tells the player which field it is.
    return pattern
end

-- Lay out the highlighted item's full detail on the gamepad item tooltip, just
-- like the native inventory does, then append our own lines at the BOTTOM of
-- the card: where the item currently lives (which character/bank) and any
-- hold/reservation status. (These previously sat just below the item name, but
-- that slot collided with other add-ons, so they were moved back to the
-- bottom.) All custom work is pcall-guarded so a tooltip-style mismatch
-- degrades to the plain item card rather than crashing the session.
--
-- Native reference: ZO_GamepadInventory:UpdateItemLeftTooltip
-- (esoui/ingame/inventory/gamepad/gamepadinventory.lua:1122-1146) — the item
-- card goes on GAMEPAD_LEFT_TOOLTIP via LayoutBagItem, an equipped row also
-- gets a status-rail label, and everything else clears the status label. The
-- equipped comparison is a SEPARATE right-tooltip concern, driven off the same
-- selection callback (:1162 UpdateItemLeftTooltip and :1169 UpdateRightTooltip
-- -> :1610 ZO_LayoutBagItemEquippedComparison).
function Blade:UpdateTooltip(selectedData)
    if GAMEPAD_TOOLTIPS == nil then return end
    -- The native craft-bag/inventory tab paints its item card on the RIGHT
    -- tooltip. When the player scrolls onto our tab that stale card lingers
    -- (Bug: leftover "Alkahest" on the first row), so we clear the RIGHT
    -- tooltip on every target change before we (maybe) repaint it below.
    pcall(function() GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP) end)
    -- The native category browser sets the LEFT tooltip status label (e.g.
    -- "Currencies" for the currency row). The Layout* calls do not reset it,
    -- so that stale header would sit above our item popup.
    pcall(function() GAMEPAD_TOOLTIPS:ClearStatusLabel(GAMEPAD_LEFT_TOOLTIP) end)
    local row = selectedData and selectedData.accountHoldRow
    if not row or not row.entry or not row.entry.itemLink then
        pcall(function() GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_LEFT_TOOLTIP) end)
        return
    end
    local e = row.entry

    local itemLink, stackCount = e.itemLink, e.stackCount
    local locLine = tooltipLine(SI_ACCOUNTHOLD_TOOLTIP_LOCATION, row.locationLabel or "?")
    local status, holderName = self:HoldStatusLabel(row)
    local holdLine
    if status then
        if holderName and holderName ~= "" then
            holdLine = tooltipLine(SI_ACCOUNTHOLD_TOOLTIP_HOLD_STATUS_FOR, status, holderName)
        else
            holdLine = tooltipLine(SI_ACCOUNTHOLD_TOOLTIP_HOLD_STATUS, status)
        end
    end

    local function injectSection(tt)
        local section = tt:AcquireSection(tt:GetStyle("bodySection"))
        if locLine then
            section:AddLine(locLine, tt:GetStyle("bodyDescription"))
        end
        if holdLine then
            section:AddLine(holdLine, tt:GetStyle("bodyDescription"))
        end
        tt:AddSection(section)
    end

    -- The native card, then our section appended at the BOTTOM. We deliberately
    -- do NOT inject below the item name (the old AddItemTitle-wrapper approach):
    -- that top-of-card slot collides with other add-ons that write there.
    -- Appending after layout is naturally bottom-anchored and never touches the
    -- native title path.
    --
    -- Prefer the RICHER native call when the row really is a live slot on this
    -- character: LayoutBagItem adds the player-locked marker, the crafter's
    -- name, the BoP trade timer and armory-build lines, and counts the stack
    -- the way that bag counts it (itemtooltips.lua:1686-1727). Items parked on
    -- another character have no readable slot, so they keep the link-only card.
    local laidOut = false
    if Tab.RowHasLiveSlot(row, liveItemLink(row.bagId, row.slotIndex)) then
        local ok, valid = pcall(function()
            return GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_LEFT_TOOLTIP,
                row.bagId, row.slotIndex)
        end)
        laidOut = ok and valid ~= false and valid ~= nil
    end
    if not laidOut then
        pcall(function()
            GAMEPAD_TOOLTIPS:LayoutItemWithStackCountSimple(
                GAMEPAD_LEFT_TOOLTIP, itemLink, stackCount)
        end)
    end
    pcall(function()
        if type(GAMEPAD_TOOLTIPS.GetTooltip) ~= "function" then return end
        local tt = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
        if tt and type(tt.AcquireSection) == "function"
           and type(tt.AddSection) == "function"
           and type(tt.GetStyle) == "function" then
            injectSection(tt)
        end
    end)

    -- An item this character is WEARING gets the native status-rail label
    -- (gamepadinventory.lua:1136-1140 -> :908). Only for our own worn pieces:
    -- "Equipped" over another character's gear would be a lie.
    if row.isWorn and row.isLocal then
        pcall(function()
            GAMEPAD_TOOLTIPS:SetStatusLabelText(GAMEPAD_LEFT_TOOLTIP,
                GetString(SI_GAMEPAD_EQUIPPED_ITEM_HEADER))
        end)
    end

    -- Gear comparison against what is currently equipped, on the RIGHT
    -- tooltip. The native item list drives exactly this off the same selection
    -- callback: OnSelectedDataChangedCallback calls UpdateItemLeftTooltip
    -- (gamepadinventory.lua:1162) AND UpdateRightTooltip (:1169), and the
    -- comparison branch there is ZO_LayoutBagItemEquippedComparison (:1610,
    -- defined at itemtooltips.lua:1745). We call the LINK-only sibling
    -- ZO_LayoutItemLinkEquippedComparison (itemtooltips.lua:1731-1743) because
    -- our rows may describe an item on another character with no slot to read;
    -- it returns false for anything non-equippable
    -- (GetItemLinkEquippedComparisonEquipSlots -> EQUIP_SLOT_NONE) and sets the
    -- right pane's "Equipped" rail itself via
    -- ZO_InventoryUtils_UpdateTooltipEquippedIndicatorText. We cleared the right
    -- tooltip above, so any failure degrades to the empty pane we shipped
    -- before rather than a stale card.
    if type(ZO_LayoutItemLinkEquippedComparison) == "function" then
        pcall(function()
            ZO_LayoutItemLinkEquippedComparison(GAMEPAD_RIGHT_TOOLTIP, itemLink)
        end)
    end
end

-- Called by the parametric list whenever the highlighted (target) row changes.
-- Repaints the item tooltip to follow the cursor and refreshes the keybind
-- strip so Place/Cancel visibility tracks the new selection.
function Blade:OnTargetChanged(selectedData)
    self:UpdateTooltip(selectedData)
    if type(GAMEPAD_INVENTORY) == "table" and GAMEPAD_INVENTORY.RefreshKeybinds then
        pcall(function() GAMEPAD_INVENTORY:RefreshKeybinds() end)
    end
end

-- Drop every tooltip we may have painted. Called when focus leaves our list so
-- a stale Quartermaster card can never sit over a native screen. Native uses
-- Reset (not ClearTooltip) when it switches lists —
-- ZO_GamepadInventory:SwitchActiveList does
-- GAMEPAD_TOOLTIPS:Reset(GAMEPAD_LEFT_TOOLTIP) / Reset(GAMEPAD_RIGHT_TOOLTIP)
-- (gamepadinventory.lua:269-270) — because Reset also restores the background,
-- scroll and header state a Layout* call may have changed, where ClearTooltip
-- only empties the lines (zo_tooltip_gamepad.lua:292-310 vs :156-170). We use
-- Reset when it exists and fall back to the ClearTooltip pair we shipped
-- before. ClearTooltip already clears the status label itself (:169), so the
-- explicit ClearStatusLabel only matters on the Reset path.
function Blade:ClearTooltips()
    if GAMEPAD_TOOLTIPS == nil then return end
    local which = {}
    -- Built by hand rather than as a literal: a nil constant in a table literal
    -- would truncate ipairs and silently skip the other tooltip.
    if GAMEPAD_LEFT_TOOLTIP  ~= nil then which[#which + 1] = GAMEPAD_LEFT_TOOLTIP  end
    if GAMEPAD_RIGHT_TOOLTIP ~= nil then which[#which + 1] = GAMEPAD_RIGHT_TOOLTIP end
    local reset = GAMEPAD_TOOLTIPS.Reset
    for _, which_ in ipairs(which) do
        local done = false
        if type(reset) == "function" then
            done = pcall(function() GAMEPAD_TOOLTIPS:Reset(which_) end)
        end
        if not done then
            pcall(function() GAMEPAD_TOOLTIPS:ClearTooltip(which_) end)
        end
    end
    pcall(function() GAMEPAD_TOOLTIPS:ClearStatusLabel(GAMEPAD_LEFT_TOOLTIP) end)
end

-- The player types the item-name filter into our own in-list search field (a
-- ZO_GamepadTextFieldItem row at the top of the list, exactly like the guild
-- store BROWSE screen). Its text lives here; SetupNameSearchRow keeps it in
-- sync with the edit box.
function Blade:CurrentSearchText()
    return self.searchText or ""
end

-- Narrow self.rows to items whose name contains the current search text
-- (case-insensitive substring, matching the native search's spirit). No-op
-- when the box is empty.
function Blade:FilterRowsBySearch()
    local q = self:CurrentSearchText()
    if not q or q == "" then return end
    q = string.lower(q)
    local kept = {}
    for _, r in ipairs(self.rows) do
        local name = string.lower((r.entry and r.entry.name) or "")
        if name ~= "" and string.find(name, q, 1, true) then
            kept[#kept + 1] = r
        end
    end
    self.rows = kept
end

-- Wire one ZO_GamepadTextFieldItem row to act as the guild-store "Item Name"
-- search box. The edit box drives blade.searchText on every keystroke (via the
-- template's textChangedCallback) and refreshes the results LIVE as the player
-- types. The name-search row is always list index 1 and rebuilt from the same
-- control pool, so re-committing the item rows below it keeps this edit box's
-- focus and text intact (we skip SetText when it already matches, so the cursor
-- never jumps). Mirrors ZO_TradingHouseNameSearchFeature_Gamepad.
function Blade:SetupNameSearchRow(control, data, selected)
    local blade = self
    if control.highlight and control.highlight.SetHidden then
        pcall(function() control.highlight:SetHidden(not selected) end)
    end
    local editBox = control.editBoxControl
    if not editBox then return end
    data.editBoxControl = editBox

    editBox.textChangedCallback = function(eb)
        local text = eb:GetText() or ""
        if text == (blade.searchText or "") then return end
        blade.searchText = text
        blade:ScheduleLiveRefresh()
    end
    if editBox.SetDefaultText then
        pcall(function()
            editBox:SetDefaultText(GetString(SI_ACCOUNTHOLD_SEARCH_NAME_DEFAULT))
        end)
    end
    if editBox.GetText and editBox.SetText and editBox:GetText() ~= (blade.searchText or "") then
        pcall(function() editBox:SetText(blade.searchText or "") end)
    end
end

-- Live-filter as the player types. Rebuilding the whole list on every keystroke
-- would be wasteful and could race the in-flight OnTextChanged event, so we
-- debounce: each keystroke schedules a refresh ~60ms out and supersedes any
-- pending one (via a monotonic token). The refresh re-queries + rebuilds the
-- item rows while preserving the selected index, so the search field keeps
-- focus and the player's cursor. Falls back to an immediate refresh where
-- zo_callLater is unavailable (e.g. the test harness).
function Blade:ScheduleLiveRefresh()
    self._liveToken = (self._liveToken or 0) + 1
    local token = self._liveToken
    local function run()
        if token ~= self._liveToken then return end   -- superseded by a newer keystroke
        self:RefreshResultsPreservingSelection()
    end
    if type(zo_callLater) == "function" then
        zo_callLater(run, 60)
    else
        run()
    end
end

-- Repopulate the list but keep the current selection index (so the search field
-- stays selected/focused while typing). pcall-guarded so a transient API hiccup
-- can't crash the inventory scene mid-keystroke.
function Blade:RefreshResultsPreservingSelection()
    local list = self.list
    if not list then return end
    local prevIndex = (list.GetSelectedIndex and list:GetSelectedIndex()) or 1
    pcall(function() self:Populate() end)
    if list.SetSelectedIndexWithoutAnimation then
        pcall(function() list:SetSelectedIndexWithoutAnimation(prevIndex) end)
    end
end

-- Right-stick "Reset Search": clear the name filter, every dropdown filter, the
-- category and sort back to defaults, then repaint. Matches the guild store's
-- UI_SHORTCUT_RIGHT_STICK reset.
function Blade:ResetSearch()
    self.searchText   = ""
    self.sortKey      = "name"
    self.categoryIndex = 1
    self.filter       = {}
    pcall(function() self:Populate() end)
    local inv = GAMEPAD_INVENTORY
    if type(inv) == "table" and inv.RefreshKeybinds then
        pcall(function() inv:RefreshKeybinds() end)
    end
end
-- Order the result rows by the Sort By dropdown selection.
--
-- Every comparator is total and deterministic: after the chosen key it falls
-- through to name, then to the location label and the item signature. Without
-- those trailing terms two rows for the same item in different containers
-- compare equal, and table.sort (which is not stable) is free to reorder them
-- on every repaint -- so the list visibly reshuffled while typing a search.
function Blade:SortRows()
    local key = self.sortKey or "name"
    local index = self.addon and self.addon.Index

    local function nameOf(r) return string.lower((r.entry and r.entry.name) or "") end
    local function qualityOf(r)
        -- Same resolver Index:Query's quality filter uses, so an entry whose
        -- cached quality is missing still sorts by its real quality instead of
        -- collapsing to 0.
        if index and index.GetEntryQuality then return index:GetEntryQuality(r.entry) end
        return (r.entry and r.entry.quality) or 0
    end
    -- "Item Type" must order by the localized type NAME the player reads, not
    -- by the ITEMTYPE_* enum id. The enum is ordered by internal id, so sorting
    -- on it interleaves unrelated types and the list looks unsorted. Falls back
    -- to the numeric id only when the string enum can't be resolved.
    local typeLabelCache = {}
    local function typeLabelOf(r)
        local t = (r.entry and r.entry.itemType) or 0
        local cached = typeLabelCache[t]
        if cached then return cached end
        local label
        if type(GetString) == "function" then
            local ok, v = pcall(GetString, "SI_ITEMTYPE", t)
            if ok and type(v) == "string" and v ~= "" then label = string.lower(v) end
        end
        label = label or string.format("%010d", t)
        typeLabelCache[t] = label
        return label
    end

    -- Final tiebreakers: stable across repaints, never equal for distinct rows.
    local function tieBreak(a, b)
        local la = (a.locationLabel or "")
        local lb = (b.locationLabel or "")
        if la ~= lb then return la < lb end
        local sa = (a.entry and a.entry.itemSignature) or ""
        local sb = (b.entry and b.entry.itemSignature) or ""
        if sa ~= sb then return sa < sb end
        return tostring(a.slotIndex or 0) < tostring(b.slotIndex or 0)
    end

    local function byName(a, b)
        local na, nb = nameOf(a), nameOf(b)
        if na ~= nb then return na < nb end
        return tieBreak(a, b)
    end

    -- Comparator for the chosen sort key (name / quality / type).
    local function base(a, b)
        if key == "quality" then
            -- Highest quality first (gold -> white), matching the label's intent.
            local qa, qb = qualityOf(a), qualityOf(b)
            if qa ~= qb then return qa > qb end
            return byName(a, b)
        elseif key == "type" then
            local ta, tb = typeLabelOf(a), typeLabelOf(b)
            if ta ~= tb then return ta < tb end
            return byName(a, b)
        else
            return byName(a, b)
        end
    end
    if self.filter and self.filter.characterId then
        -- Character filter view: equipped (worn) pieces first, then the rest
        -- of that character's held items; each section ordered by the chosen
        -- sort key.
        table.sort(self.rows, function(a, b)
            local wa = a.isWorn and 0 or 1
            local wb = b.isWorn and 0 or 1
            if wa ~= wb then return wa < wb end
            return base(a, b)
        end)
    else
        table.sort(self.rows, base)
    end
end

-- Build the ZO_GamepadEntryData for one item row so it looks EXACTLY like a
-- native inventory row. The stock gamepad inventory builds a row with
--     local entryData = ZO_GamepadEntryData:New(itemData.name, itemData.iconFile)
--     entryData:InitializeInventoryVisualData(itemData)
-- (esoui/esoui@master esoui/ingame/inventory/gamepad/gamepadinventory.lua:1309-1310),
-- then flags the worn piece (:1313) and suppresses the trait pip (:1343). We do
-- the same, and everything InitializeInventoryVisualData would have done is ALSO
-- set explicitly afterwards so the row still looks right on a client where that
-- method is missing or throws.
--
-- Notes on the two things that were wrong here before:
--   * ONE icon, not two. New(name, icon) already calls AddIcon
--     (zo_gamepadentrydata.lua:13) and InitializeInventoryVisualData calls
--     AddIcon(itemData.icon) again (:29). Native survives that because the
--     shared inventory only ever populates slot.iconFile, never slot.icon
--     (sharedinventory.lua:635) — so the second AddIcon is a no-op and the row
--     has exactly one icon. We were setting BOTH fields, giving every row two
--     icons in the ZO_MultiIcon, which animates/cycles between frames.
--   * SetSubLabels does not exist. The real API is AddSubLabel
--     (zo_gamepadentrydata.lua:366-371), so the guarded call we had could never
--     fire and the location sub label never rendered.
function Blade:MakeItemEntry(row, holdLookup)
    local e = row.entry or {}
    -- Item names must be run through zo_strformat(SI_TOOLTIP_ITEM_NAME, ...)
    -- the way the base game does (sharedinventory.lua:625), or the raw
    -- "^Fn"/"^m" gender+article markers render on screen. Our Scanner caches
    -- the unformatted GetItemName result, so we format here.
    local text, subLabels = Tab.RowLabels(row, nil, Tab.ShowRowLocation())
    -- Native colours by DISPLAY quality (zo_gamepadentrydata.lua:32); our
    -- Scanner caches FUNCTIONAL quality, so re-resolve off the link.
    local displayQuality = Tab.ResolveDisplayQuality(e)
    local stackCount = e.stackCount or 1

    local data = ZO_GamepadEntryData:New(text, e.icon)
    if data.InitializeInventoryVisualData then
        local itemData = {
            name           = text,
            -- iconFile ONLY. See the one-icon note above.
            iconFile       = e.icon,
            stackCount     = stackCount,
            displayQuality = displayQuality,
            quality        = displayQuality,
            uniqueId       = e.uniqueId,
            bagId          = row.bagId,
            slotIndex      = row.slotIndex,
        }
        pcall(function() data:InitializeInventoryVisualData(itemData) end)
    end
    data.accountHoldRow = row

    -- Explicit belt-and-braces copies of what InitializeInventoryVisualData
    -- sets, so a client where it is absent still gets a native-looking row.
    if displayQuality and data.SetNameColors and data.GetColorsBasedOnQuality then
        pcall(function() data:SetNameColors(data:GetColorsBasedOnQuality(displayQuality)) end)
    end
    if data.SetStackCount then
        -- ZO_SharedGamepadEntryIconSetup only prints the badge when the count
        -- is > 1 (zo_gamepadtemplatescommon.lua:300-306), so singles stay bare
        -- exactly like native.
        pcall(function() data:SetStackCount(stackCount) end)
    end
    -- Item rows explicitly do NOT grow on selection — InitializeInventoryVisualData
    -- ends with SetFontScaleOnSelection(false) and the comment "item entries
    -- don't grow on selection" (zo_gamepadentrydata.lua:35). Only menu/category
    -- rows scale. Set it again in case the initializer never ran.
    if data.SetFontScaleOnSelection then
        pcall(function() data:SetFontScaleOnSelection(false) end)
    end
    -- Native sets this on every inventory item row (gamepadinventory.lua:1343).
    -- Without it data.traitInformation is nil, and the status-indicator setup
    -- tests `traitInformation ~= ITEM_TRAIT_INFORMATION_NONE` (which is 0), so
    -- nil passes and it would ask for the icon of a nil trait
    -- (zo_gamepadtemplatescommon.lua:428-430).
    if data.SetIgnoreTraitInformation then
        pcall(function() data:SetIgnoreTraitInformation(true) end)
    end
    -- The equipped chevron. Native raises this as a plain field, not a setter
    -- (gamepadinventory.lua:1313), and the status-indicator pass turns it into
    -- gp_inventory_icon_equipped.dds (zo_gamepadtemplatescommon.lua:366, :6).
    -- Only for gear this character is actually wearing.
    if row.isWorn and row.isLocal then
        data.isEquippedInCurrentCategory = true
    end
    -- A reserved item gets the native padlock pip rather than another line of
    -- text: SetLocked (zo_gamepadentrydata.lua:387) drives
    -- ZO_GAMEPAD_LOCKED_ICON_32 in the same status-indicator pass
    -- (zo_gamepadtemplatescommon.lua:424-426). This is the same visual language
    -- the game already uses for "you cannot casually get rid of this".
    if data.SetLocked and Tab.RowIsReserved(row, holdLookup) then
        pcall(function() data:SetLocked(true) end)
    end

    -- Location (which character / bank / set) as an always-visible sub label.
    -- Sub labels are the native home for secondary detail; the row name is one
    -- ELLIPSIS-clipped line (zo_gamepadtemplatescommon.xml:188) so folding the
    -- location into it would clip the item name at TV distance. The
    -- always-visible pattern (rather than selected-only) follows
    -- InitializeTradingHouseVisualData (zo_gamepadentrydata.lua:48-52).
    if data.AddSubLabel then
        for _, s in ipairs(subLabels) do
            pcall(function() data:AddSubLabel(s) end)
        end
        if #subLabels > 0 then
            if data.SetSubLabelColors and ZO_NORMAL_TEXT then
                pcall(function() data:SetSubLabelColors(ZO_NORMAL_TEXT) end)
            end
            if data.SetShowUnselectedSublabels then
                pcall(function() data:SetShowUnselectedSublabels(true) end)
            end
        end
    end
    return data
end

-- Rebuild the list entries from the current index + filters. The filter
-- dropdown rows are added FIRST (always visible, guild-store style), then the
-- item rows below. Uses the framework's Clear/AddEntry/Commit, so there is no
-- async render hazard.
function Blade:Populate()
    self:EnsureCategories()
    local list = self.list
    if not list then return end

    self.filter.categoryKey = self:_CurrentCategoryKey()

    -- Neutralize any filter whose dropdown is hidden for the current category
    -- (e.g. a leftover Set filter after switching to Consumables) so a hidden
    -- constraint can't silently empty the list.
    local specs = self:FilterSpecs()
    for _, spec in ipairs(specs) do
        if spec.visible and spec.visible() == false and spec.clearValue then
            spec.clearValue()
        end
    end

    -- ...but SEVERAL sub-filters write the SAME query field: consumable,
    -- material, glyph, companion and misc all write `filter.itemTypes`, and
    -- furnishing writes `filter.specializedTypes`. Their clearValue() nulls
    -- that shared field unconditionally, so the pass above also wiped the
    -- selection the VISIBLE sub-filter had just stored — which is exactly why
    -- the second-layer dropdowns appeared to do nothing at all. Each spec's own
    -- private field (filter.consumableType, filter.glyphType, ...) survives, so
    -- the dropdown kept DISPLAYING the choice while the query ignored it.
    --
    -- Re-assert every visible spec's contribution to the shared field after the
    -- clear pass. Recomputed from that spec's private field, so a stale value
    -- from a previous category can't survive here either.
    for _, spec in ipairs(specs) do
        if spec.reapplyShared and not (spec.visible and spec.visible() == false) then
            spec.reapplyShared()
        end
    end

    self.rows = (self.addon.Index and self.addon.Index.Query
                 and self.addon.Index:Query(self.filter)) or {}
    self:FilterRowsBySearch()
    self:SortRows()

    if list.Clear then list:Clear() end

    -- Item-name search field FIRST (guild-store BROWSE layout): a single
    -- ZO_GamepadTextFieldItem row with an "Item Name" header, then the filter
    -- dropdowns, then the item rows.
    if list.AddEntryWithHeader and ZO_GamepadEntryData then
        local nameData = ZO_GamepadEntryData:New("")
        nameData.header             = GetString(SI_ACCOUNTHOLD_SEARCH_NAME_HEADER)
        nameData.isNameSearch       = true
        if nameData.SetHeader then
            pcall(function() nameData:SetHeader(GetString(SI_ACCOUNTHOLD_SEARCH_NAME_HEADER)) end)
        end
        pcall(function()
            list:AddEntryWithHeader("ZO_GamepadTextFieldItem", nameData)
        end)
    end

    -- Inline filter dropdown rows (always present, at the top of the list).
    -- Hidden specs (per current category) are skipped entirely.
    if list.AddEntryWithHeader and ZO_GamepadEntryData then
        for _, spec in ipairs(specs) do
            if not (spec.visible and spec.visible() == false) then
                local data = ZO_GamepadEntryData:New("")
                data.header     = spec.header
                data.ahSpec     = spec
                data.isDropDown = spec.template ~= "slider"
                data.isSlider   = spec.template == "slider"
                pcall(function()
                    if spec.template == "slider" and list.AddEntry then
                        list:AddEntry("ZO_GamepadGuildStoreBrowseSliderTemplate", data)
                    elseif spec.multi then
                        list:AddEntryWithHeader("ZO_GamepadMultiSelectionDropdownItem", data)
                    else
                        list:AddEntryWithHeader("ZO_GamepadDropdownItem", data)
                    end
                end)
            end
        end
    end

    -- Item rows. When a specific Character filter is selected, split into an
    -- "Equipped" section (worn pieces, emitted first by SortRows) and a "Held
    -- Items" section, each introduced by a section header on its first row.
    if ZO_GamepadEntryData and list.AddEntry then
        -- The Equipped category already contains nothing but worn pieces, so
        -- the "Equipped"/"Held Items" split would emit a single redundant
        -- header echoing the category name. Only section when the list can
        -- actually hold both kinds.
        local charMode = self.filter.characterId ~= nil
            and self:_CurrentCategoryKey() ~= "equipped"
        local lastSection
        -- One pass over the hold table instead of one pass PER ROW.
        local holdLookup = self:_BuildHoldLookup()
        local template = list.qmItemTemplate or self._itemTemplate or ITEM_ROW_TEMPLATE_FALLBACK
        for _, row in ipairs(self.rows) do
            local entry = self:MakeItemEntry(row, holdLookup)
            local added = false
            if charMode then
                local section = row.isWorn and "equipped" or "held"
                if section ~= lastSection then
                    lastSection = section
                    local hdr = row.isWorn
                        and GetString(SI_ACCOUNTHOLD_SECTION_EQUIPPED)
                        or  GetString(SI_ACCOUNTHOLD_SECTION_HELD)
                    entry.header = hdr
                    if entry.SetHeader then pcall(function() entry:SetHeader(hdr) end) end
                    if list.AddEntryWithHeader then
                        added = pcall(function()
                            list:AddEntryWithHeader(template, entry)
                        end)
                    end
                end
            end
            if not added then
                list:AddEntry(template, entry)
            end
        end
    end

    if list.Commit then list:Commit() end
end

function Blade:PlaceHoldOnSelected(holdMode)
    local blade = self
    local ok, err = pcall(function()
        local row = blade:GetSelectedRow()
        if not row then return end
        if blade.addon.UI.HoldDialog and blade.addon.UI.HoldDialog.BeginPlaceHold then
            blade.addon.UI.HoldDialog:BeginPlaceHold(row, holdMode)
        end
    end)
    if not ok and self.addon and self.addon.Log then
        self.addon:Log("|cFF6666[Quartermaster]|r place hold failed: " .. shortErr(err))
    end
end

function Blade:CancelHoldOnSelected()
    local blade = self
    local ok, err = pcall(function()
        blade:_CancelHoldOnSelectedUnsafe()
    end)
    if not ok and self.addon and self.addon.Log then
        self.addon:Log("|cFF6666[Quartermaster]|r cancel hold failed: " .. shortErr(err))
    end
end

function Blade:_CancelHoldOnSelectedUnsafe()
    local row = self:GetSelectedRow()
    if not row then return end
    if not (self.addon.sv and self.addon.sv.holds) then return end
    local cancelled = 0
    for id, hold in pairs(self.addon.sv.holds) do
        if hold.status ~= "delivered" and hold.status ~= "cancelled" then
            local match = false
            if hold.holdType == "item"
               and hold.itemSignature == row.entry.itemSignature then
                match = true
            elseif hold.holdType == "set" and hold.setId == row.entry.setId then
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
    self:Populate()
end

-- Clear-My-Holds confirmation dialog. Registered once. canQueue + gamepadInfo
-- make it work in gamepad UI mode. The `1` fallback for GAMEPAD_DIALOGS.BASIC
-- matches the constant's stable value and keeps the addon loadable on
-- stripped/older builds where the table is absent. Full data wipes live in the
-- Settings panel only — this tab action clears just the current character's
-- holds.
local CLEAR_HOLDS_DIALOG = "ACCOUNT_HOLD_GP_CLEAR_MY_HOLDS"
local clearHoldsDialogRegistered = false
local function ensureClearHoldsDialog()
    if ZO_Dialogs_RegisterCustomDialog and not clearHoldsDialogRegistered then
        clearHoldsDialogRegistered = true
        ZO_Dialogs_RegisterCustomDialog(CLEAR_HOLDS_DIALOG, {
            canQueue    = true,
            gamepadInfo = { dialogType = GAMEPAD_DIALOGS and GAMEPAD_DIALOGS.BASIC or 1 },
            title       = { text = GetString(SI_ACCOUNTHOLD_CLEAR_MY_HOLDS_TITLE) },
            mainText    = { text = GetString(SI_ACCOUNTHOLD_CONFIRM_CLEAR_MY_HOLDS) },
            buttons = {
                {
                    text     = GetString(SI_ACCOUNTHOLD_CLEAR_MY_HOLDS_CONFIRM),
                    keybind  = "DIALOG_PRIMARY",
                    callback = function(dialog)
                        local d = dialog and dialog.data or {}
                        local ok, err = pcall(function()
                            if d.blade then d.blade:_ClearMyHoldsUnsafe() end
                        end)
                        if not ok and d.addon and d.addon.Log then
                            d.addon:Log("|cFF6666[Quartermaster]|r clear holds failed: " .. shortErr(err))
                        end
                    end,
                },
                {
                    text    = GetString(SI_ACCOUNTHOLD_DIALOG_CANCEL),
                    keybind = "DIALOG_NEGATIVE",
                },
            },
        })
    end
end

-- Cancel every active hold reserved for the current character, then repaint
-- the list + keybinds. Separated so the dialog callback can pcall it.
function Blade:_ClearMyHoldsUnsafe()
    if self.addon and self.addon.Holds and self.addon.Holds.CancelForCurrentCharacter then
        self.addon.Holds:CancelForCurrentCharacter()
    end
    pcall(function() self:Populate() end)
    local inv = GAMEPAD_INVENTORY
    if type(inv) == "table" and inv.RefreshKeybinds then
        pcall(function() inv:RefreshKeybinds() end)
    end
end

function Blade:OpenClearMyHoldsConfirm()
    ensureClearHoldsDialog()
    -- ShowPlatformDialog routes to ShowGamepadDialog on console (isGamepad=true)
    -- so the BASIC gamepad dialog renders correctly; ShowDialog alone would
    -- treat it as keyboard and crash in zo_dialog.lua.
    local data = { addon = self.addon, blade = self }
    if ZO_Dialogs_ShowPlatformDialog then
        ZO_Dialogs_ShowPlatformDialog(CLEAR_HOLDS_DIALOG, data)
    elseif ZO_Dialogs_ShowDialog then
        ZO_Dialogs_ShowDialog(CLEAR_HOLDS_DIALOG, data)
    end
end

-- ---------------------------------------------------------------------------
-- Inline filter dropdowns (guild-store style, ALWAYS visible in the list).
--
-- The guild store gamepad BROWSE screen embeds its filter dropdowns as rows at
-- the top of its own parametric list — you simply scroll onto a dropdown and
-- press (A) to open it; there is no separate "open filters" button. We do the
-- SAME here: Blade:Populate adds one ZO_GamepadDropdownItem row per filter at
-- the top of the list (via AddEntryWithHeader), then the item rows below. The
-- filter rows are ALWAYS present — no button, no dialog, no Y-to-filter.
--
-- Reference: esoui/ingame/tradinghouse/gamepad/tradinghouse_browse_gamepad.lua
-- (FocusDropDown/UnfocusDropDown suspend/restore the keybind group around the
-- combobox activation) and the generic ZO_GamepadDropdownItem template whose
-- control.dropdown is a ZO_ComboBox_Gamepad
-- (common/gamepad/zo_gamepadtemplatescommon.xml : ZO_Gamepad_Dropdown_Base).
-- ---------------------------------------------------------------------------

-- Sort options offered in the Sort dropdown: {key, stringId}.
local SORT_OPTIONS = {
    { key = "name",    stringId = "SI_ACCOUNTHOLD_SORT_NAME" },
    { key = "quality", stringId = "SI_ACCOUNTHOLD_SORT_QUALITY" },
    { key = "type",    stringId = "SI_ACCOUNTHOLD_SORT_TYPE" },
}

-- Prepend an "All" (no-filter, value = nil) option to a facet option list.
local function withAllOption(options)
    local all = { { value = nil, label = GetString(SI_ACCOUNTHOLD_FILTER_ALL) } }
    for _, o in ipairs(options) do all[#all + 1] = o end
    return all
end

local function ahString(id, fallback)
    if type(GetString) == "function" then
        local ok, v = pcall(GetString, id)
        if ok and type(v) == "string" and v ~= "" then return v end
    end
    return fallback or tostring(id or "")
end

local function enumString(prefix, value, fallback)
    if type(GetString) == "function" and value ~= nil then
        local ok, v = pcall(GetString, prefix, value)
        if ok and type(v) == "string" and v ~= "" then return v end
    end
    return fallback or tostring(value or "")
end

local function const(name)
    return type(_G) == "table" and _G[name] or nil
end

local function constList(names)
    local out = {}
    for _, name in ipairs(names) do
        local v = const(name)
        if type(v) == "number" then out[#out + 1] = v end
    end
    return out
end

local function oneOf(names)
    for _, name in ipairs(names) do
        local v = const(name)
        if type(v) == "number" then return v end
    end
    return nil
end

local function hasSetValues(t)
    if type(t) ~= "table" then return false end
    for _, selected in pairs(t) do if selected then return true end end
    return false
end

local WEAPON_GROUPS = {
    { value = nil, label = ahString(SI_ACCOUNTHOLD_WEAPON_ALL, "All Weapons"), values = nil },
    { value = "one", label = ahString(SI_ACCOUNTHOLD_WEAPON_ONE_HANDED, "One-Handed Melee"), values = constList({ "WEAPONTYPE_AXE", "WEAPONTYPE_HAMMER", "WEAPONTYPE_SWORD", "WEAPONTYPE_DAGGER" }) },
    { value = "two", label = ahString(SI_ACCOUNTHOLD_WEAPON_TWO_HANDED, "Two-Handed Melee"), values = constList({ "WEAPONTYPE_TWO_HANDED_AXE", "WEAPONTYPE_TWO_HANDED_HAMMER", "WEAPONTYPE_TWO_HANDED_SWORD" }) },
    { value = "bow", label = enumString("SI_WEAPONTYPE", const("WEAPONTYPE_BOW"), "Bow"), values = constList({ "WEAPONTYPE_BOW" }) },
    { value = "destro", label = ahString(SI_ACCOUNTHOLD_WEAPON_DESTRO_STAFF, "Destruction Staff"), values = constList({ "WEAPONTYPE_FIRE_STAFF", "WEAPONTYPE_FROST_STAFF", "WEAPONTYPE_LIGHTNING_STAFF" }) },
    { value = "resto", label = ahString(SI_ACCOUNTHOLD_WEAPON_RESTO_STAFF, "Restoration Staff"), values = constList({ "WEAPONTYPE_HEALING_STAFF" }) },
}

local WEAPON_SUBTYPES = {
    one = { "WEAPONTYPE_AXE", "WEAPONTYPE_HAMMER", "WEAPONTYPE_SWORD", "WEAPONTYPE_DAGGER" },
    two = { "WEAPONTYPE_TWO_HANDED_AXE", "WEAPONTYPE_TWO_HANDED_HAMMER", "WEAPONTYPE_TWO_HANDED_SWORD" },
    destro = { "WEAPONTYPE_FIRE_STAFF", "WEAPONTYPE_FROST_STAFF", "WEAPONTYPE_LIGHTNING_STAFF" },
}

local TRAIT_NAMES = {
    weapon = { "ITEM_TRAIT_TYPE_WEAPON_ORNATE", "ITEM_TRAIT_TYPE_WEAPON_INTRICATE", "ITEM_TRAIT_TYPE_WEAPON_POWERED", "ITEM_TRAIT_TYPE_WEAPON_CHARGED", "ITEM_TRAIT_TYPE_WEAPON_PRECISE", "ITEM_TRAIT_TYPE_WEAPON_INFUSED", "ITEM_TRAIT_TYPE_WEAPON_DEFENDING", "ITEM_TRAIT_TYPE_WEAPON_TRAINING", "ITEM_TRAIT_TYPE_WEAPON_SHARPENED", "ITEM_TRAIT_TYPE_WEAPON_DECISIVE", "ITEM_TRAIT_TYPE_WEAPON_NIRNHONED", "ITEM_TRAIT_TYPE_NONE" },
    armor = { "ITEM_TRAIT_TYPE_ARMOR_ORNATE", "ITEM_TRAIT_TYPE_ARMOR_INTRICATE", "ITEM_TRAIT_TYPE_ARMOR_STURDY", "ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE", "ITEM_TRAIT_TYPE_ARMOR_REINFORCED", "ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED", "ITEM_TRAIT_TYPE_ARMOR_TRAINING", "ITEM_TRAIT_TYPE_ARMOR_INFUSED", "ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS", "ITEM_TRAIT_TYPE_ARMOR_DIVINES", "ITEM_TRAIT_TYPE_ARMOR_NIRNHONED", "ITEM_TRAIT_TYPE_NONE" },
    jewelry = { "ITEM_TRAIT_TYPE_JEWELRY_ORNATE", "ITEM_TRAIT_TYPE_JEWELRY_INTRICATE", "ITEM_TRAIT_TYPE_JEWELRY_ARCANE", "ITEM_TRAIT_TYPE_JEWELRY_HEALTHY", "ITEM_TRAIT_TYPE_JEWELRY_ROBUST", "ITEM_TRAIT_TYPE_JEWELRY_TRIUNE", "ITEM_TRAIT_TYPE_JEWELRY_INFUSED", "ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE", "ITEM_TRAIT_TYPE_JEWELRY_SWIFT", "ITEM_TRAIT_TYPE_JEWELRY_HARMONY", "ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY", "ITEM_TRAIT_TYPE_NONE" },
    companionWeapon = { "ITEM_TRAIT_TYPE_WEAPON_QUICKENED", "ITEM_TRAIT_TYPE_WEAPON_PROLIFIC", "ITEM_TRAIT_TYPE_WEAPON_FOCUSED", "ITEM_TRAIT_TYPE_WEAPON_SHATTERING", "ITEM_TRAIT_TYPE_WEAPON_AGGRESSIVE", "ITEM_TRAIT_TYPE_WEAPON_SOOTHING", "ITEM_TRAIT_TYPE_WEAPON_AUGMENTED", "ITEM_TRAIT_TYPE_WEAPON_BOLSTERED", "ITEM_TRAIT_TYPE_WEAPON_VIGOROUS", "ITEM_TRAIT_TYPE_NONE" },
    companionArmor = { "ITEM_TRAIT_TYPE_ARMOR_QUICKENED", "ITEM_TRAIT_TYPE_ARMOR_PROLIFIC", "ITEM_TRAIT_TYPE_ARMOR_FOCUSED", "ITEM_TRAIT_TYPE_ARMOR_SHATTERING", "ITEM_TRAIT_TYPE_ARMOR_AGGRESSIVE", "ITEM_TRAIT_TYPE_ARMOR_SOOTHING", "ITEM_TRAIT_TYPE_ARMOR_AUGMENTED", "ITEM_TRAIT_TYPE_ARMOR_BOLSTERED", "ITEM_TRAIT_TYPE_ARMOR_VIGOROUS", "ITEM_TRAIT_TYPE_NONE" },
    companionJewelry = { "ITEM_TRAIT_TYPE_JEWELRY_QUICKENED", "ITEM_TRAIT_TYPE_JEWELRY_PROLIFIC", "ITEM_TRAIT_TYPE_JEWELRY_FOCUSED", "ITEM_TRAIT_TYPE_JEWELRY_SHATTERING", "ITEM_TRAIT_TYPE_JEWELRY_AGGRESSIVE", "ITEM_TRAIT_TYPE_JEWELRY_SOOTHING", "ITEM_TRAIT_TYPE_JEWELRY_AUGMENTED", "ITEM_TRAIT_TYPE_JEWELRY_BOLSTERED", "ITEM_TRAIT_TYPE_JEWELRY_VIGOROUS", "ITEM_TRAIT_TYPE_NONE" },
}

local function traitOptions(kind)
    local out, seen = {}, {}
    for _, name in ipairs(TRAIT_NAMES[kind] or {}) do
        local v = const(name)
        if type(v) == "number" and not seen[v] then
            seen[v] = true
            out[#out + 1] = { value = v, label = enumString("SI_ITEMTRAITTYPE", v, name == "ITEM_TRAIT_TYPE_NONE" and ahString(SI_ACCOUNTHOLD_TRAIT_NONE, "No Trait") or tostring(v)) }
        end
    end
    return out
end

local function namedEnumOptions(names, prefix, allLabel)
    local opts = {}
    for _, name in ipairs(names) do
        local v = const(name)
        if type(v) == "number" then opts[#opts + 1] = { value = v, label = enumString(prefix, v, name) } end
    end
    return withAllOption(opts, allLabel)
end

local function levelMax(kind)
    if kind == "cp" and type(GetChampionPointsPlayerProgressionCap) == "function" then
        local ok, v = pcall(GetChampionPointsPlayerProgressionCap)
        if ok and type(v) == "number" then return v end
    elseif type(GetMaxLevel) == "function" then
        local ok, v = pcall(GetMaxLevel)
        if ok and type(v) == "number" then return v end
    end
    return kind == "cp" and 3600 or 50
end

local SIMPLE_CATEGORY_FILTERS = {
    consumable = {
        field = "consumableType",
        header = function() return ahString(SI_ACCOUNTHOLD_FILTER_CONSUMABLE_TYPE, "Consumable Type") end,
        options = {
            { label = "All Consumables" },
            { label = "Food", itemTypes = constList({ "ITEMTYPE_FOOD" }) },
            { label = "Drink", itemTypes = constList({ "ITEMTYPE_DRINK" }) },
            { label = "Potion", itemTypes = constList({ "ITEMTYPE_POTION" }) },
            { label = "Poison", itemTypes = constList({ "ITEMTYPE_POISON" }) },
            { label = "Racial Style Motif", itemTypes = constList({ "ITEMTYPE_RACIAL_STYLE_MOTIF" }) },
            { label = "Recipe", itemTypes = constList({ "ITEMTYPE_RECIPE" }) },
            { label = "Master Writ", itemTypes = constList({ "ITEMTYPE_MASTER_WRIT" }) },
            { label = "Container", itemTypes = constList({ "ITEMTYPE_CONTAINER", "ITEMTYPE_CONTAINER_CURRENCY" }) },
            { label = "Alliance War Repair", itemTypes = constList({ "ITEMTYPE_AVA_REPAIR" }) },
        },
    },
    material = {
        field = "materialType",
        header = function() return ahString(SI_ACCOUNTHOLD_FILTER_MATERIAL_TYPE, "Material Type") end,
        options = {
            { label = "All Materials" },
            { label = "Blacksmithing", itemTypes = constList({ "ITEMTYPE_BLACKSMITHING_RAW_MATERIAL", "ITEMTYPE_BLACKSMITHING_MATERIAL", "ITEMTYPE_BLACKSMITHING_BOOSTER" }) },
            { label = "Clothier", itemTypes = constList({ "ITEMTYPE_CLOTHIER_RAW_MATERIAL", "ITEMTYPE_CLOTHIER_MATERIAL", "ITEMTYPE_CLOTHIER_BOOSTER" }) },
            { label = "Woodworking", itemTypes = constList({ "ITEMTYPE_WOODWORKING_RAW_MATERIAL", "ITEMTYPE_WOODWORKING_MATERIAL", "ITEMTYPE_WOODWORKING_BOOSTER" }) },
            { label = "Jewelry Crafting", itemTypes = constList({ "ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL", "ITEMTYPE_JEWELRYCRAFTING_MATERIAL", "ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER", "ITEMTYPE_JEWELRYCRAFTING_BOOSTER" }) },
            { label = "Alchemy", itemTypes = constList({ "ITEMTYPE_POTION_BASE", "ITEMTYPE_POISON_BASE", "ITEMTYPE_REAGENT" }) },
            { label = "Enchanting", itemTypes = constList({ "ITEMTYPE_ENCHANTING_RUNE_POTENCY", "ITEMTYPE_ENCHANTING_RUNE_ASPECT", "ITEMTYPE_ENCHANTING_RUNE_ESSENCE" }) },
            { label = "Provisioning Ingredients", itemTypes = constList({ "ITEMTYPE_INGREDIENT" }) },
            { label = "Style Materials", itemTypes = constList({ "ITEMTYPE_RAW_MATERIAL", "ITEMTYPE_STYLE_MATERIAL" }) },
            { label = "Trait Materials", itemTypes = constList({ "ITEMTYPE_WEAPON_TRAIT", "ITEMTYPE_ARMOR_TRAIT", "ITEMTYPE_RAW_TRAIT_MATERIAL", "ITEMTYPE_JEWELRY_RAW_TRAIT", "ITEMTYPE_JEWELRY_TRAIT" }) },
            { label = "Furnishing Material", itemTypes = constList({ "ITEMTYPE_FURNISHING_MATERIAL" }) },
        },
    },
    glyph = {
        field = "glyphType",
        header = function() return ahString(SI_ACCOUNTHOLD_FILTER_GLYPH_TYPE, "Glyph Type") end,
        options = {
            { label = "All Glyphs", itemTypes = constList({ "ITEMTYPE_GLYPH_WEAPON", "ITEMTYPE_GLYPH_ARMOR", "ITEMTYPE_GLYPH_JEWELRY" }) },
            { label = "Weapon Glyphs", itemTypes = constList({ "ITEMTYPE_GLYPH_WEAPON" }) },
            { label = "Armor Glyphs", itemTypes = constList({ "ITEMTYPE_GLYPH_ARMOR" }) },
            { label = "Jewelry Glyphs", itemTypes = constList({ "ITEMTYPE_GLYPH_JEWELRY" }) },
        },
    },
    companion = {
        field = "companionType",
        header = function() return ahString(SI_ACCOUNTHOLD_FILTER_COMPANION_TYPE, "Companion Equipment Type") end,
        -- No itemTypes: companion gear shares the player's ITEMTYPE_* values
        -- exactly, so the split is done by Index's COMPANION_SUBTYPE_MATCHERS
        -- keyed off filter.companionType. The old itemTypes lists both clobbered
        -- sibling categories' shared filter.itemTypes AND could never work
        -- ("ITEMTYPE_JEWELRY" does not exist, so that entry resolved to {}).
        options = {
            { value = nil,       label = "All Companion Equipment" },
            { value = "weapon",  label = "Companion Weapons" },
            { value = "armor",   label = "Companion Armor" },
            { value = "jewelry", label = "Companion Jewelry" },
        },
    },
    furnishing = {
        field = "furnishingType",
        header = function() return ahString(SI_ACCOUNTHOLD_FILTER_FURNISHING_TYPE, "Furnishing Type") end,
        options = {
            { label = "All Furnishings" },
            { label = "Crafting Stations", specializedTypes = constList({ "SPECIALIZED_ITEMTYPE_FURNISHING_CRAFTING_STATION", "SPECIALIZED_ITEMTYPE_FURNISHING_ATTUNABLE_STATION" }) },
            { label = "Target Dummy", specializedTypes = constList({ "SPECIALIZED_ITEMTYPE_FURNISHING_TARGET_DUMMY" }) },
            { label = "Lights", specializedTypes = constList({ "SPECIALIZED_ITEMTYPE_FURNISHING_LIGHT" }) },
            { label = "Seating", specializedTypes = constList({ "SPECIALIZED_ITEMTYPE_FURNISHING_SEATING" }) },
            { label = "Ornamental", specializedTypes = constList({ "SPECIALIZED_ITEMTYPE_FURNISHING_ORNAMENTAL" }) },
            -- Most ordinary furnishings carry SPECIALIZED_ITEMTYPE_NONE, and
            -- ESO itself lists it under ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING
            -- (esoui/ingame/inventory/inventory.lua). Without this option they
            -- are reachable only via "All Furnishings".
            { label = "Other Furnishings", specializedTypes = constList({ "SPECIALIZED_ITEMTYPE_NONE" }) },
        },
    },
    misc = {
        field = "miscType",
        header = function() return ahString(SI_ACCOUNTHOLD_FILTER_MISC_TYPE, "Miscellaneous Type") end,
        options = {
            -- An "All" entry is required, not cosmetic: getCurrent() returns 1
            -- on first paint, so without it the dropdown DISPLAYED "Soul Gem"
            -- while setValue had never run and nothing was filtered — the UI
            -- lying about what it was showing.
            { label = "All Miscellaneous" },
            { label = "Soul Gem", itemTypes = constList({ "ITEMTYPE_SOUL_GEM" }) },
            { label = "Bait", itemTypes = constList({ "ITEMTYPE_LURE" }) },
            { label = "Tool", itemTypes = constList({ "ITEMTYPE_TOOL" }) },
            { label = "Siege", itemTypes = constList({ "ITEMTYPE_SIEGE" }) },
            { label = "Trophy", itemTypes = constList({ "ITEMTYPE_TROPHY" }) },
            { label = "Guild Tabard", itemTypes = constList({ "ITEMTYPE_TABARD" }) },
        },
    },
}

-- Each spec drives one inline dropdown row:
--   header       -> the label shown ABOVE the dropdown (e.g. "Sort by")
--   getOptions() -> array of { value = <any|nil>, label = <string> }
--   getCurrent() -> the currently-selected value
--   setValue(v)  -> store the newly-selected value
-- Options + current are read lazily so they always reflect live filter state
-- and the live scan (only traits/sets/qualities that actually exist show up).
function Blade:FilterSpecs()
    local blade = self
    return {
        {
            -- Character — top-level owner filter, always visible. "All
            -- Characters" leaves behavior unchanged; choosing a character
            -- constrains every category and enables equipped/held sectioning.
            header     = GetString(SI_ACCOUNTHOLD_FILTER_CHARACTER),
            getOptions = function()
                local out = {
                    { value = nil, label = ahString(SI_ACCOUNTHOLD_FILTER_CHARACTER_ALL, "All Characters") },
                }
                local chars = (blade.addon.ListKnownCharacters
                               and blade.addon:ListKnownCharacters()) or {}
                for _, c in ipairs(chars) do
                    out[#out + 1] = { value = c.id, label = c.name }
                end
                return out
            end,
            getCurrent = function() return blade.filter.characterId end,
            setValue   = function(v) blade.filter.characterId = v end,
        },
        {
            header = GetString(SI_ACCOUNTHOLD_FILTER_CATEGORY),
            getOptions = function()
                blade:EnsureCategories()
                local out = {}
                for _, c in ipairs(blade.categories) do
                    out[#out + 1] = { value = c.key, label = c.label }
                end
                return out
            end,
            getCurrent = function()
                blade:EnsureCategories()
                return (blade.categories[blade.categoryIndex] or {}).key or "all"
            end,
            setValue = function(key)
                blade:EnsureCategories()
                for i, c in ipairs(blade.categories) do
                    if c.key == key then
                        blade.categoryIndex = i
                        break
                    end
                end
            end,
        },
        {
            -- Weapon Type — contextual sub-filter, weapons only (guild store's
            -- weapon-type row). Neutralized/hidden for every other category.
            header     = GetString(SI_ACCOUNTHOLD_FILTER_WEAPON_TYPE),
            visible    = function() return blade:_CurrentCategoryKey() == "weapon" end,
            clearValue = function()
                blade.filter.weaponGroup = nil
                blade.filter.weaponTypes = nil
                blade.filter.weaponType = nil
            end,
            getOptions = function()
                return WEAPON_GROUPS
            end,
            getCurrent = function() return blade.filter.weaponGroup end,
            setValue   = function(v)
                blade.filter.weaponGroup = v
                blade.filter.weaponType = nil
                blade.filter.weaponTypes = nil
                for _, group in ipairs(WEAPON_GROUPS) do
                    if group.value == v then
                        blade.filter.weaponTypes = group.values
                        break
                    end
                end
            end,
        },
        {
            header     = ahString(SI_ACCOUNTHOLD_FILTER_WEAPON_SUBTYPE, "Weapon Subtype"),
            visible    = function()
                return blade:_CurrentCategoryKey() == "weapon"
                    and WEAPON_SUBTYPES[blade.filter.weaponGroup] ~= nil
            end,
            clearValue = function() blade.filter.weaponType = nil end,
            getOptions = function()
                return namedEnumOptions(
                    WEAPON_SUBTYPES[blade.filter.weaponGroup] or {},
                    "SI_WEAPONTYPE",
                    ahString(SI_ACCOUNTHOLD_WEAPON_ALL_TYPES, "All Weapon Types"))
            end,
            getCurrent = function() return blade.filter.weaponType end,
            setValue   = function(v) blade.filter.weaponType = v end,
        },
        {
            -- Armor Weight — contextual sub-filter, armor only (guild store's
            -- Light/Medium/Heavy row).
            header     = GetString(SI_ACCOUNTHOLD_FILTER_ARMOR_WEIGHT),
            visible    = function() return blade:_CurrentCategoryKey() == "armor" end,
            clearValue = function() blade.filter.armorType = nil end,
            getOptions = function()
                local known = (blade.addon.Index and blade.addon.Index.GetKnownArmorTypes
                               and blade.addon.Index:GetKnownArmorTypes()) or {}
                return withAllOption(known)
            end,
            getCurrent = function() return blade.filter.armorType end,
            setValue   = function(v) blade.filter.armorType = v end,
        },
        {
            header = SIMPLE_CATEGORY_FILTERS.consumable.header(),
            visible = function() return blade:_CurrentCategoryKey() == "consumable" end,
            clearValue = function() blade.filter.itemTypes = nil; blade.filter.consumableType = nil end,
            -- filter.itemTypes is shared with the material/glyph/companion/misc
            -- rows, whose clearValue() nulls it whenever they are hidden.
            -- Populate calls this back for the VISIBLE row so our selection
            -- survives that pass. Option 1 ("All Consumables") legitimately
            -- imposes no constraint. An EMPTY list would be a truthy table that
            -- matches nothing, so it degrades to "no constraint" too.
            reapplyShared = function()
                local o = SIMPLE_CATEGORY_FILTERS.consumable.options[blade.filter.consumableType or 1]
                local types = o and o.itemTypes
                blade.filter.itemTypes = (types and #types > 0) and types or nil
            end,
            getOptions = function()
                local out = {}
                for i, o in ipairs(SIMPLE_CATEGORY_FILTERS.consumable.options) do out[#out + 1] = { value = i, label = o.label } end
                return out
            end,
            getCurrent = function() return blade.filter.consumableType or 1 end,
            setValue = function(v)
                blade.filter.consumableType = v or 1
                local o = SIMPLE_CATEGORY_FILTERS.consumable.options[blade.filter.consumableType]
                local types = o and o.itemTypes
                blade.filter.itemTypes = (types and #types > 0) and types or nil
            end,
        },
        {
            header = SIMPLE_CATEGORY_FILTERS.material.header(),
            visible = function() return blade:_CurrentCategoryKey() == "material" end,
            clearValue = function() blade.filter.itemTypes = nil; blade.filter.materialType = nil end,
            -- See the consumable spec: filter.itemTypes is shared, so the
            -- hidden-spec clear pass in Populate would otherwise wipe this.
            reapplyShared = function()
                local o = SIMPLE_CATEGORY_FILTERS.material.options[blade.filter.materialType or 1]
                local types = o and o.itemTypes
                blade.filter.itemTypes = (types and #types > 0) and types or nil
            end,
            getOptions = function()
                local out = {}
                for i, o in ipairs(SIMPLE_CATEGORY_FILTERS.material.options) do out[#out + 1] = { value = i, label = o.label } end
                return out
            end,
            getCurrent = function() return blade.filter.materialType or 1 end,
            setValue = function(v)
                blade.filter.materialType = v or 1
                local o = SIMPLE_CATEGORY_FILTERS.material.options[blade.filter.materialType]
                local types = o and o.itemTypes
                blade.filter.itemTypes = (types and #types > 0) and types or nil
            end,
        },
        {
            header = SIMPLE_CATEGORY_FILTERS.glyph.header(),
            visible = function() return blade:_CurrentCategoryKey() == "glyph" end,
            clearValue = function() blade.filter.itemTypes = nil; blade.filter.glyphType = nil end,
            -- See the consumable spec above: filter.itemTypes is shared, so the
            -- hidden-spec clear pass in Populate would otherwise wipe this.
            reapplyShared = function()
                local o = SIMPLE_CATEGORY_FILTERS.glyph.options[blade.filter.glyphType or 1]
                local types = o and o.itemTypes
                blade.filter.itemTypes = (types and #types > 0) and types or nil
            end,
            getOptions = function()
                local out = {}
                for i, o in ipairs(SIMPLE_CATEGORY_FILTERS.glyph.options) do out[#out + 1] = { value = i, label = o.label } end
                return out
            end,
            getCurrent = function() return blade.filter.glyphType or 1 end,
            setValue = function(v)
                blade.filter.glyphType = v or 1
                local o = SIMPLE_CATEGORY_FILTERS.glyph.options[blade.filter.glyphType]
                local types = o and o.itemTypes
                blade.filter.itemTypes = (types and #types > 0) and types or nil
            end,
        },
        {
            header = SIMPLE_CATEGORY_FILTERS.furnishing.header(),
            visible = function() return blade:_CurrentCategoryKey() == "furnishing" end,
            clearValue = function() blade.filter.specializedTypes = nil; blade.filter.furnishingType = nil end,
            -- Kept symmetrical with the itemTypes-sharing specs: an EMPTY list
            -- is a truthy table that would match nothing, so an option whose
            -- constants didn't resolve degrades to "no constraint".
            reapplyShared = function()
                local o = SIMPLE_CATEGORY_FILTERS.furnishing.options[blade.filter.furnishingType or 1]
                local types = o and o.specializedTypes
                blade.filter.specializedTypes = (types and #types > 0) and types or nil
            end,
            getOptions = function()
                local out = {}
                for i, o in ipairs(SIMPLE_CATEGORY_FILTERS.furnishing.options) do out[#out + 1] = { value = i, label = o.label } end
                return out
            end,
            getCurrent = function() return blade.filter.furnishingType or 1 end,
            setValue = function(v)
                blade.filter.furnishingType = v or 1
                local o = SIMPLE_CATEGORY_FILTERS.furnishing.options[blade.filter.furnishingType]
                local types = o and o.specializedTypes
                blade.filter.specializedTypes = (types and #types > 0) and types or nil
            end,
        },
        {
            header = SIMPLE_CATEGORY_FILTERS.companion.header(),
            visible = function() return blade:_CurrentCategoryKey() == "companion" end,
            -- Only clears its OWN field: companion no longer writes the shared
            -- filter.itemTypes, so it must not nil it either (that stomped
            -- other categories' selections).
            clearValue = function() blade.filter.companionType = nil end,
            getOptions = function()
                local out = {}
                for i, o in ipairs(SIMPLE_CATEGORY_FILTERS.companion.options) do out[#out + 1] = { value = o.value or i, label = o.label } end
                return out
            end,
            getCurrent = function() return blade.filter.companionType or 1 end,
            setValue = function(v)
                blade.filter.companionType = type(v) == "string" and v or nil
                blade.filter.traitTypes = nil
            end,
        },
        {
            header = SIMPLE_CATEGORY_FILTERS.misc.header(),
            visible = function() return blade:_CurrentCategoryKey() == "misc" end,
            clearValue = function() blade.filter.itemTypes = nil; blade.filter.miscType = nil end,
            -- See the consumable spec: filter.itemTypes is shared, so the
            -- hidden-spec clear pass in Populate would otherwise wipe this.
            reapplyShared = function()
                local o = SIMPLE_CATEGORY_FILTERS.misc.options[blade.filter.miscType or 1]
                local types = o and o.itemTypes
                blade.filter.itemTypes = (types and #types > 0) and types or nil
            end,
            getOptions = function()
                local out = {}
                for i, o in ipairs(SIMPLE_CATEGORY_FILTERS.misc.options) do out[#out + 1] = { value = i, label = o.label } end
                return out
            end,
            getCurrent = function() return blade.filter.miscType or 1 end,
            setValue = function(v)
                blade.filter.miscType = v or 1
                local o = SIMPLE_CATEGORY_FILTERS.misc.options[blade.filter.miscType]
                local types = o and o.itemTypes
                blade.filter.itemTypes = (types and #types > 0) and types or nil
            end,
        },
        {
            header     = ahString(SI_ACCOUNTHOLD_FILTER_LEVEL, "Level"),
            visible    = function()
                local k = blade:_CurrentCategoryKey()
                return k == "all" or k == "weapon" or k == "armor" or k == "jewelry"
                    or k == "consumable" or k == "glyph"
            end,
            clearValue = function()
                blade.filter.requiredLevelType = nil
                blade.filter.minLevel = nil
                blade.filter.maxLevel = nil
            end,
            getOptions = function()
                return {
                    { value = nil, label = ahString(SI_ACCOUNTHOLD_LEVEL_ALL, "All Levels") },
                    { value = "level", label = ahString(SI_ACCOUNTHOLD_LEVEL_PLAYER, "Player Level") },
                    { value = "cp", label = ahString(SI_ACCOUNTHOLD_LEVEL_CP, "Champion Points") },
                }
            end,
            getCurrent = function() return blade.filter.requiredLevelType end,
            setValue = function(v)
                blade.filter.requiredLevelType = v
                if v == nil then
                    blade.filter.minLevel = nil
                    blade.filter.maxLevel = nil
                else
                    blade.filter.minLevel = 0
                    blade.filter.maxLevel = levelMax(v)
                end
            end,
        },
        {
            template = "slider",
            header = ahString(SI_ACCOUNTHOLD_FILTER_MIN_LEVEL, "Min Level"),
            visible = function()
                local k = blade:_CurrentCategoryKey()
                return k == "all" or k == "weapon" or k == "armor" or k == "jewelry"
                    or k == "consumable" or k == "glyph"
            end,
            enabled = function() return blade.filter.requiredLevelType ~= nil end,
            clearValue = function() blade.filter.minLevel = nil end,
            getMin = function() return 0 end,
            getMax = function() return levelMax(blade.filter.requiredLevelType) end,
            getStep = function() return blade.filter.requiredLevelType == "cp" and 10 or 1 end,
            getValue = function() return blade.filter.minLevel or 0 end,
            setValue = function(v)
                v = tonumber(v) or 0
                blade.filter.minLevel = v
                if blade.filter.maxLevel and blade.filter.maxLevel < v then blade.filter.maxLevel = v end
            end,
            maxConstraint = function() return blade.filter.maxLevel or levelMax(blade.filter.requiredLevelType) end,
        },
        {
            template = "slider",
            header = ahString(SI_ACCOUNTHOLD_FILTER_MAX_LEVEL, "Max Level"),
            visible = function()
                local k = blade:_CurrentCategoryKey()
                return k == "all" or k == "weapon" or k == "armor" or k == "jewelry"
                    or k == "consumable" or k == "glyph"
            end,
            enabled = function() return blade.filter.requiredLevelType ~= nil end,
            clearValue = function() blade.filter.maxLevel = nil end,
            getMin = function() return 0 end,
            getMax = function() return levelMax(blade.filter.requiredLevelType) end,
            getStep = function() return blade.filter.requiredLevelType == "cp" and 10 or 1 end,
            getValue = function() return blade.filter.maxLevel or levelMax(blade.filter.requiredLevelType) end,
            setValue = function(v)
                v = tonumber(v) or levelMax(blade.filter.requiredLevelType)
                blade.filter.maxLevel = v
                if blade.filter.minLevel and blade.filter.minLevel > v then blade.filter.minLevel = v end
            end,
            minConstraint = function() return blade.filter.minLevel or 0 end,
        },
        {
            header = ahString(SI_ACCOUNTHOLD_FILTER_TRAITS, "Traits"),
            multi = true,
            -- Native guild-store trait filters are single-select; this row uses
            -- ZO_GamepadMultiSelectionDropdownItem when present so the popup has
            -- checkbox entries and keeps the dropdown open while toggling.
            visible    = function() return blade:_TraitKindForCurrent() ~= nil end,
            clearValue = function()
                blade.filter.traitType = nil
                blade.filter.traitTypes = nil
            end,
            getOptions = function()
                return traitOptions(blade:_TraitKindForCurrent())
            end,
            isSelected = function(v)
                return type(blade.filter.traitTypes) == "table" and blade.filter.traitTypes[v] == true
            end,
            setValue   = function(v, selected)
                if v == nil then return end
                blade.filter.traitType = nil
                blade.filter.traitTypes = blade.filter.traitTypes or {}
                blade.filter.traitTypes[v] = selected and true or nil
                if not hasSetValues(blade.filter.traitTypes) then blade.filter.traitTypes = nil end
            end,
        },
        {
            header = GetString(SI_ACCOUNTHOLD_FILTER_SET),
            -- Item sets surface for All / Weapons / Armor (per design) AND for
            -- the dedicated Sets category; hidden + neutralized elsewhere.
            visible    = function()
                return blade:_CategoryHasGear() or blade:_CurrentCategoryKey() == "sets"
            end,
            clearValue = function() blade.filter.setName = nil end,
            getOptions = function()
                local opts = {}
                -- In the Sets category, append "(<owned> / <reconstructable>)"
                -- to each set name: owned unique pieces, and pieces the player
                -- can reconstruct from their Collections sticker book.
                local showCount = (blade:_CurrentCategoryKey() == "sets")
                local known = (blade.addon.Index and blade.addon.Index.GetKnownSets
                               and blade.addon.Index:GetKnownSets()) or {}
                for _, s in ipairs(known) do
                    local label = s.name
                    if showCount and s.count then
                        label = string.format(
                            GetString(SI_ACCOUNTHOLD_SET_WITH_COUNT),
                            s.name, s.count, s.reconstructable or 0)
                    end
                    opts[#opts + 1] = { value = s.name, label = label }
                end
                return withAllOption(opts)
            end,
            getCurrent = function()
                local n = blade.filter.setName
                if n == nil or n == "" then return nil end
                return n
            end,
            setValue = function(v) blade.filter.setName = v end,
        },
        {
            header = GetString(SI_ACCOUNTHOLD_FILTER_BOUND),
            getOptions = function()
                return {
                    { value = "any",         label = GetString(SI_ACCOUNTHOLD_BOUND_ANY) },
                    { value = "boundOnly",   label = GetString(SI_ACCOUNTHOLD_BOUND_BOUND) },
                    { value = "unboundOnly", label = GetString(SI_ACCOUNTHOLD_BOUND_UNBOUND) },
                }
            end,
            getCurrent = function() return blade.filter.bound or "any" end,
            setValue   = function(v) blade.filter.bound = v end,
        },
        {
            header = GetString(SI_ACCOUNTHOLD_SORT_HEADER),
            getOptions = function()
                local out = {}
                for _, s in ipairs(SORT_OPTIONS) do
                    out[#out + 1] = { value = s.key, label = GetString(_G[s.stringId]) }
                end
                return out
            end,
            getCurrent = function() return blade.sortKey or "name" end,
            setValue   = function(v) blade.sortKey = v or "name" end,
        },
        {
            -- Item Quality — always present, anchored at the BOTTOM of the
            -- filter section (per user request).
            header = ahString(SI_ACCOUNTHOLD_FILTER_QUALITY, "Quality"),
            getOptions = function()
                local opts = { { value = nil, label = ahString(SI_ACCOUNTHOLD_QUALITY_ANY, "Any") } }
                local names = {
                    "ITEM_DISPLAY_QUALITY_NORMAL",
                    "ITEM_DISPLAY_QUALITY_MAGIC",
                    "ITEM_DISPLAY_QUALITY_ARCANE",
                    "ITEM_DISPLAY_QUALITY_ARTIFACT",
                    "ITEM_DISPLAY_QUALITY_LEGENDARY",
                }
                local functional = {
                    "ITEM_FUNCTIONAL_QUALITY_NORMAL",
                    "ITEM_FUNCTIONAL_QUALITY_MAGIC",
                    "ITEM_FUNCTIONAL_QUALITY_ARCANE",
                    "ITEM_FUNCTIONAL_QUALITY_ARTIFACT",
                    "ITEM_FUNCTIONAL_QUALITY_LEGENDARY",
                }
                local fallbacks = { "Normal", "Magic", "Arcane", "Artifact", "Legendary" }
                local seen = {}
                for i, name in ipairs(names) do
                    local q = const(name) or const(functional[i])
                    if type(q) == "number" and not seen[q] then
                        seen[q] = true
                        opts[#opts + 1] = {
                            value = q,
                            label = enumString("SI_ITEMDISPLAYQUALITY", q,
                                enumString("SI_ITEMQUALITY", q, fallbacks[i])),
                        }
                    end
                end
                return opts
            end,
            getCurrent = function() return blade.filter.quality end,
            setValue   = function(v) blade.filter.quality = v end,
        },
    }
end

-- Populate one inline dropdown row's combobox from its spec. Runs on every
-- redraw of the row, so its options + the shown selection always reflect live
-- state. Selecting an option writes the value and flags the list dirty; the
-- combobox auto-deactivates on selection (SelectHighlightedItem -> Deactivate),
-- which fires our deactivated callback -> UnfocusDropdown (re-adds the keybinds
-- and repaints the list). All combobox calls are pcall-guarded so an API drift
-- degrades to a static row instead of crashing the inventory scene.
function Blade:SetupDropdownRow(control, data, selected)
    local dropdown = control.dropdown
    if not dropdown then return end
    local spec  = data.ahSpec
    if not spec then return end
    local blade = self

    if dropdown.SetNormalColor and ZO_GAMEPAD_COMPONENT_COLORS then
        pcall(function()
            dropdown:SetNormalColor(ZO_GAMEPAD_COMPONENT_COLORS.UNSELECTED_INACTIVE:UnpackRGB())
            dropdown:SetHighlightedColor(ZO_GAMEPAD_COMPONENT_COLORS.SELECTED_ACTIVE:UnpackRGB())
        end)
    end
    if dropdown.SetSelectedItemTextColor then
        pcall(function() dropdown:SetSelectedItemTextColor(selected) end)
    end
    pcall(function() dropdown:SetSortsItems(false) end)
    pcall(function() dropdown:SetDeactivatedCallback(function() blade:UnfocusDropdown() end) end)
    pcall(function() dropdown:ClearItems() end)

    local options      = (spec.getOptions and spec.getOptions()) or {}
    local current      = spec.getCurrent and spec.getCurrent()
    local currentIndex = 1
    if spec.multi and dropdown.LoadData and type(ZO_MultiSelection_ComboBox_Data_Gamepad) == "table" then
        local multiData = ZO_MultiSelection_ComboBox_Data_Gamepad:New()
        for _, opt in ipairs(options) do
            local value = opt.value
            local entry = dropdown:CreateItemEntry(opt.label or "", function(_, _, item, selectedNow)
                if spec.setValue then spec.setValue(item.value, selectedNow) end
                blade._filtersDirty = true
            end)
            entry.value = value
            multiData:AddItem(entry)
            if spec.isSelected and spec.isSelected(value) then
                multiData:SetItemSelected(entry, true)
            end
        end
        pcall(function() dropdown:SetNoSelectionText(ahString(SI_ACCOUNTHOLD_FILTER_ALL, "All")) end)
        pcall(function() dropdown:SetMultiSelectionTextFormatter(ahString(SI_ACCOUNTHOLD_TRAITS_SELECTED, "<<1>> selected")) end)
        pcall(function() dropdown:LoadData(multiData) end)
        data.dropDown   = dropdown
        data.isDropDown = true
        return
    end
    for i, opt in ipairs(options) do
        local value = opt.value
        local entry = dropdown:CreateItemEntry(opt.label or "", function()
            if spec.multi then
                local selectedNow = not (spec.isSelected and spec.isSelected(value))
                if spec.setValue then spec.setValue(value, selectedNow) end
            elseif spec.setValue then
                spec.setValue(value)
            end
            blade._filtersDirty = true
        end)
        dropdown:AddItem(entry)
        if value == current then currentIndex = i end
    end
    pcall(function() dropdown:UpdateItems() end)
    -- Show the active option WITHOUT firing its callback, so redrawing the row
    -- never clobbers the stored selection or spuriously flags the list dirty.
    local IGNORE_CALLBACK = true
    pcall(function() dropdown:SelectItemByIndex(currentIndex, IGNORE_CALLBACK) end)

    data.dropDown   = dropdown
    data.isDropDown = true
end

function Blade:SetupSliderRow(control, data, selected)
    local spec = data and data.ahSpec
    if not spec or not control then return end
    local slider = control.GetNamedChild and control:GetNamedChild("Slider")
    local label = control.GetNamedChild and control:GetNamedChild("SliderLabel")
    local valueLabel = control.GetNamedChild and control:GetNamedChild("SliderValue")
    if label and label.SetText then pcall(function() label:SetText(spec.header or "") end) end
    if not slider then return end

    local minValue = (spec.getMin and spec.getMin()) or 0
    local maxValue = (spec.getMax and spec.getMax()) or 50
    local value = (spec.getValue and spec.getValue()) or minValue
    if slider.SetValueStep then pcall(function() slider:SetValueStep((spec.getStep and spec.getStep()) or 1) end) end
    if slider.SetMinMax then pcall(function() slider:SetMinMax(minValue, maxValue) end) end
    if slider.SetValueConstraints then
        pcall(function() slider:SetValueConstraints(spec.minConstraint, spec.maxConstraint) end)
    end
    if slider.SetHandler then
        pcall(function()
            slider:SetHandler("OnValueChanged", function(_, newValue)
                if spec.setValue then spec.setValue(newValue) end
                if valueLabel and valueLabel.SetText then valueLabel:SetText(tostring(newValue)) end
                self:ScheduleLiveRefresh()
            end)
        end)
    end
    if slider.SetValue then pcall(function() slider:SetValue(value) end) end
    if valueLabel and valueLabel.SetText then pcall(function() valueLabel:SetText(tostring(value)) end) end
    local enabled = not spec.enabled or spec.enabled()
    if slider.SetEnabled then pcall(function() slider:SetEnabled(enabled) end) end
    if valueLabel and valueLabel.SetHidden then pcall(function() valueLabel:SetHidden(not enabled) end) end
    if control.SetAlpha and ZO_GamepadMenuEntryTemplate_GetAlpha then
        pcall(function() control:SetAlpha(ZO_GamepadMenuEntryTemplate_GetAlpha(selected, not enabled)) end)
    end
    data.isSlider = true
end

-- Scroll INTO an inline dropdown (open it). Mirrors the guild store's
-- FocusDropDown: suspend our keybind group so the combobox owns directional
-- input, then activate. The combobox returns focus to the list on close via
-- UnfocusDropdown (its deactivated callback).
function Blade:FocusDropdown(dropdown)
    if self._activeDropdown or not dropdown then return end
    local inv = GAMEPAD_INVENTORY
    if type(inv) == "table" and inv.RemoveKeybinds then
        pcall(function() inv:RemoveKeybinds() end)
    end
    self._activeDropdown = dropdown
    pcall(function() dropdown:Activate() end)
end

-- Called when an inline dropdown closes (selection or cancel). Re-add our
-- keybinds and, if a filter actually changed, re-query the list once.
function Blade:UnfocusDropdown()
    if not self._activeDropdown then return end
    self._activeDropdown = nil
    local inv = GAMEPAD_INVENTORY
    if type(inv) == "table" and inv.AddKeybinds then
        pcall(function() inv:AddKeybinds() end)
    end
    if self._filtersDirty then
        self._filtersDirty = false
        pcall(function() self:Populate() end)
        if type(inv) == "table" and inv.RefreshKeybinds then
            pcall(function() inv:RefreshKeybinds() end)
        end
    end
end

-- Build the keybind-strip descriptor installed (via the inventory's own
-- SetActiveKeybinds) while our list is current. On an item row (A) places a
-- hold; on an inline filter dropdown row (A) opens the dropdown — exactly like
-- the guild store, where the same Select button opens whichever filter you are
-- scrolled onto. There is NO "open filters" button: the filters are always in
-- the list. Place/Cancel only surface when the list is actually focused so they
-- don't fight the header tab bar.
function Blade:BuildKeybinds()
    if self.keybinds then return self.keybinds end
    local blade = self
    local function listActive()
        return blade.list and blade.list.IsActive and blade.list:IsActive()
    end
    local function targetData()
        local list = blade.list
        if list and list.GetTargetData then return list:GetTargetData() end
        return nil
    end
    self.keybinds = {
        alignment = KEYBIND_STRIP_ALIGN_RIGHT,
        {
            -- (A): edit the name field, open the focused filter dropdown, or
            -- reserve the highlighted concrete item/stack as an item hold.
            name    = function()
                local td = targetData()
                if td and td.editBoxControl then return GetString(SI_GAMEPAD_SELECT_OPTION) end
                if td and td.isDropDown then return GetString(SI_GAMEPAD_SELECT_OPTION) end
                return GetString(SI_ACCOUNTHOLD_BTN_PLACE_ITEM_HOLD)
            end,
            keybind = "UI_SHORTCUT_PRIMARY",
            visible = function()
                if not listActive() then return false end
                local td = targetData()
                if not td then return false end
                if td.editBoxControl then return true end
                if td.isDropDown then return true end
                local row = td.accountHoldRow
                if not row or not row.entry then return false end
                if row.entry.isCharacterBound then return false end
                if row.isCraftBag then return false end
                return true
            end,
            callback = function()
                local td = targetData()
                if td and td.editBoxControl then
                    local editBox = td.editBoxControl
                    if editBox.HasFocus and editBox:HasFocus() then
                        pcall(function() editBox:LoseFocus() end)
                    else
                        pcall(function() editBox:TakeFocus() end)
                    end
                elseif td and td.isDropDown and td.dropDown then
                    blade:FocusDropdown(td.dropDown)
                else
                    blade:PlaceHoldOnSelected("item")
                end
            end,
        },
        {
            -- (X): reserve one full set-level hold keyed by the row's setId.
            -- Only surfaces for gear that actually carries a set bonus; item
            -- rows, dropdowns, the name field, bound and craft-bag rows never
            -- show it. There is no set-vs-per-piece chooser — A reserves the
            -- concrete item, X reserves the set.
            name    = function() return GetString(SI_ACCOUNTHOLD_BTN_PLACE_SET_HOLD) end,
            keybind = "UI_SHORTCUT_SECONDARY",
            visible = function()
                if not listActive() then return false end
                local td = targetData()
                if not td then return false end
                if td.editBoxControl or td.isDropDown then return false end
                local row = td.accountHoldRow
                if not row or not row.entry then return false end
                if row.entry.isCharacterBound then return false end
                if row.isCraftBag then return false end
                return row.entry.setId ~= nil and row.entry.setId ~= 0
            end,
            callback = function() blade:PlaceHoldOnSelected("set") end,
        },
        {
            -- These name/visible closures run inside ZOS's native (UNHARDENED)
            -- keybind update loop, so they must never propagate an error. Both
            -- consult Holds:FindActiveHoldForRow / HolderName (which iterate the
            -- saved holds and call game APIs), so the whole body is pcall-guarded
            -- and degrades to the plain label / hidden on any failure.
            name    = function()
                local ok, label = pcall(function()
                    local td  = targetData()
                    local row = td and td.accountHoldRow
                    local hold = row and blade.addon.Holds
                                 and blade.addon.Holds:FindActiveHoldForRow(row)
                    if hold then
                        local who = blade.addon.Holds:HolderName(hold)
                        if who and who ~= "" then
                            return string.format(GetString(SI_ACCOUNTHOLD_BTN_CANCEL_HOLD_FOR), who)
                        end
                    end
                    return GetString(SI_ACCOUNTHOLD_BTN_CANCEL_HOLD)
                end)
                if ok and label then return label end
                return GetString(SI_ACCOUNTHOLD_BTN_CANCEL_HOLD)
            end,
            keybind = "UI_SHORTCUT_TERTIARY",
            -- Only when the selected row actually carries an active reservation
            -- (by ANY character) — the player can cancel any hold at any time.
            -- Hidden otherwise. (Y)
            visible = function()
                if not listActive() then return false end
                local ok, res = pcall(function()
                    local td  = targetData()
                    if not td then return false end
                    -- Hide on non-item rows (the name field / filter dropdowns),
                    -- matching X — Cancel only applies to a reserved item/set.
                    if td.editBoxControl or td.isDropDown then return false end
                    local row = td.accountHoldRow
                    if not row then return false end
                    return blade.addon.Holds
                           and blade.addon.Holds:FindActiveHoldForRow(row) ~= nil
                end)
                return (ok and res) and true or false
            end,
            callback = function() blade:CancelHoldOnSelected() end,
        },
        {
            -- Right-stick: clear name + all filters (guild-store Reset Search).
            name     = function() return GetString(SI_ACCOUNTHOLD_RESET_SEARCH) end,
            keybind  = "UI_SHORTCUT_RIGHT_STICK",
            visible  = function() return listActive() end,
            callback = function() blade:ResetSearch() end,
        },
        {
            -- Clear only the current character's holds (bulk action on the
            -- QUATERNARY slot — distinct from the A/X/Y reserve/cancel contract).
            -- Full data wipes are Settings-only now. Hidden when this character
            -- has no active holds.
            name     = function() return GetString(SI_ACCOUNTHOLD_CLEAR_MY_HOLDS) end,
            keybind  = "UI_SHORTCUT_QUATERNARY",
            visible  = function()
                local h = blade.addon and blade.addon.Holds
                if not (h and h.CountForCurrentCharacter) then return false end
                local ok, n = pcall(function() return h:CountForCurrentCharacter() end)
                return ok and (n or 0) > 0
            end,
            callback = function() blade:OpenClearMyHoldsConfirm() end,
        },
    }

    -- (B): back out of our tab. Our custom descriptor replaces the inventory's
    -- own keybinds while our list is current, so without an explicit back entry
    -- the native back-navigation is gone and B does nothing.
    --
    -- Previously we hand-rolled a UI_SHORTCUT_NEGATIVE entry whose callback
    -- called inv:RequestEnterHeader(). That silently NO-OPPED: RequestEnterHeader
    -- drives the inventory *text-search* header focus (not the tab bar), and it
    -- early-returns when the search box is hidden (which it always is on our
    -- tab). The pcall saw no error, so the callback returned without ever
    -- hiding the scene -> B appeared dead.
    --
    -- The correct approach is exactly what all three native inventory
    -- descriptors do: add back-navigation via the shared helper. Our tab
    -- mirrors the native category list (SwitchActiveList keeps the tab bar
    -- active), and on the category list B simply exits the inventory scene
    -- (DefaultBack = SCENE_MANAGER:HideCurrentScene). The tab bar stays
    -- reachable via LEFT/RIGHT.
    --
    -- B is context-sensitive so it is never a dead-end and never surprises the
    -- player mid-edit (per the UX acceptance details):
    --   1. An open inline filter dropdown -> B closes the dropdown and returns
    --      focus to the list (normally the combobox already owns B because
    --      FocusDropdown suspends our group; we guard here too so it is
    --      deterministic even where that suspension is a no-op).
    --   2. A focused search / name edit box -> the FIRST B commits+unfocuses the
    --      edit box and stays on the tab; only a SECOND B (edit box no longer
    --      focused) exits the scene.
    --   3. Otherwise B exits the inventory scene (native DefaultBack).
    local function backCallback()
        if blade._activeDropdown then
            local dd = blade._activeDropdown
            if dd.Deactivate then pcall(function() dd:Deactivate() end) end
            return
        end
        local td = targetData()
        local eb = td and td.editBoxControl
        if eb and eb.HasFocus and eb:HasFocus() then
            pcall(function() eb:LoseFocus() end)
            return
        end
        if SCENE_MANAGER ~= nil and SCENE_MANAGER.HideCurrentScene then
            pcall(function() SCENE_MANAGER:HideCurrentScene() end)
        end
    end
    if type(ZO_Gamepad_AddBackNavigationKeybindDescriptors) == "function"
       and type(GAME_NAVIGATION_TYPE_BUTTON) ~= "nil" then
        -- Native helper: adds a UI_SHORTCUT_NEGATIVE entry (order -1500,
        -- visible = IsInGamepadPreferredMode) with our explicit callback.
        pcall(function()
            ZO_Gamepad_AddBackNavigationKeybindDescriptors(
                self.keybinds, GAME_NAVIGATION_TYPE_BUTTON, backCallback)
        end)
    else
        -- Fallback (test harness / older client without the helper): replicate
        -- the helper's BUTTON entry by hand.
        self.keybinds[#self.keybinds + 1] = {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name      = function() return GetString(SI_GAMEPAD_BACK_OPTION) end,
            keybind   = "UI_SHORTCUT_NEGATIVE",
            order     = -1500,
            callback  = backCallback,
        }
    end

    return self.keybinds
end

-- Lazily create our managed list on the inventory singleton. AddList builds a
-- properly templated container + hidden fragment on the inventory scene and
-- returns a real ZO_GamepadVerticalItemParametricScrollList.
function Blade:EnsureList()
    if self.list then return self.list end
    local inv = GAMEPAD_INVENTORY
    if type(inv) ~= "table" or type(inv.AddList) ~= "function" then return nil end

    local ok, list = pcall(function()
        return inv:AddList(LIST_NAME, function(theList)
            -- ITEM rows. Native registers the SUB-entry template for its item
            -- list, with BOTH a plain and a with-header variant
            -- (esoui/esoui@master esoui/ingame/inventory/gamepad/gamepadinventory.lua:1153-1154):
            --     list:AddDataTemplate("ZO_GamepadItemSubEntryTemplate",
            --         ZO_SharedGamepadEntry_OnSetup,
            --         ZO_GamepadMenuEntryTemplateParametricListFunction, ...)
            --     list:AddDataTemplateWithHeader("ZO_GamepadItemSubEntryTemplate",
            --         ..., "ZO_GamepadMenuEntryHeaderTemplate")
            -- We used to register only ZO_GamepadItemEntryTemplate, and only
            -- WITHOUT a header. Two things followed from that:
            --   1. Item names rendered in ALL CAPS, because that template's
            --      label is ZO_GamepadMenuEntryLabelTemplate, which carries
            --      modifyTextType="UPPERCASE"
            --      (esoui/common/gamepad/zo_gamepadtemplatescommon.xml:212).
            --      The sub-entry label has no modifyTextType (:188), which is
            --      why the native Items tab shows mixed case.
            --   2. The "Equipped" / "Held Items" section headers never
            --      appeared: Populate's AddEntryWithHeader call is inside a
            --      pcall, and with no header variant registered it always
            --      failed and silently fell through to a plain AddEntry.
            -- Registration is guarded; if it throws we keep the old template so
            -- the tab still lists items rather than coming up empty.
            local itemTemplate = ITEM_ROW_TEMPLATE_FALLBACK
            if theList.AddDataTemplate
               and ZO_SharedGamepadEntry_OnSetup
               and ZO_GamepadMenuEntryTemplateParametricListFunction then
                local registered = pcall(function()
                    theList:AddDataTemplate(
                        ITEM_ROW_TEMPLATE,
                        ZO_SharedGamepadEntry_OnSetup,
                        ZO_GamepadMenuEntryTemplateParametricListFunction)
                    if theList.AddDataTemplateWithHeader then
                        theList:AddDataTemplateWithHeader(
                            ITEM_ROW_TEMPLATE,
                            ZO_SharedGamepadEntry_OnSetup,
                            ZO_GamepadMenuEntryTemplateParametricListFunction,
                            nil,
                            "ZO_GamepadMenuEntryHeaderTemplate")
                    end
                end)
                if registered then
                    itemTemplate = ITEM_ROW_TEMPLATE
                else
                    -- Fallback path: register the old template, this time WITH
                    -- a header variant so the section headers work there too.
                    pcall(function()
                        theList:AddDataTemplate(
                            ITEM_ROW_TEMPLATE_FALLBACK,
                            ZO_SharedGamepadEntry_OnSetup,
                            ZO_GamepadMenuEntryTemplateParametricListFunction)
                        if theList.AddDataTemplateWithHeader then
                            theList:AddDataTemplateWithHeader(
                                ITEM_ROW_TEMPLATE_FALLBACK,
                                ZO_SharedGamepadEntry_OnSetup,
                                ZO_GamepadMenuEntryTemplateParametricListFunction,
                                nil,
                                "ZO_GamepadMenuEntryHeaderTemplate")
                        end
                    end)
                end
            end
            self._itemTemplate = itemTemplate
            -- Also stamped on the LIST so Populate can never add rows under a
            -- template this list did not register (AddEntry would throw and the
            -- tab would come up empty).
            theList.qmItemTemplate = itemTemplate
            -- Inline filter dropdown rows (always-visible, guild-store style).
            -- Registered WITH a header so each dropdown shows its filter name
            -- (Sort by / Category / Trait / ...). We use the guild store's own
            -- compact header template (ZO_GamepadGuildStoreBrowseHeaderTemplate)
            -- rather than the default ZO_GamepadMenuEntryHeaderTemplate: it anchors
            -- the label tight above its dropdown (offsetY -19, fixed 24px, centered)
            -- so the filter block reads like the guild store BROWSE screen instead
            -- of being stretched out with large gaps. The generic ZO_GamepadDropdownItem
            -- template (same base the guild store dropdown inherits) auto-creates
            -- control.dropdown (a ZO_ComboBox_Gamepad); SetupDropdownRow populates it.
            if theList.AddDataTemplateWithHeader
               and ZO_GamepadMenuEntryTemplateParametricListFunction then
                local bladeRef = self
                theList:AddDataTemplateWithHeader(
                    "ZO_GamepadDropdownItem",
                    function(control, data, selected, ...)
                        bladeRef:SetupDropdownRow(control, data, selected)
                    end,
                    ZO_GamepadMenuEntryTemplateParametricListFunction,
                    nil,
                    "ZO_GamepadGuildStoreBrowseHeaderTemplate")

                theList:AddDataTemplateWithHeader(
                    "ZO_GamepadMultiSelectionDropdownItem",
                    function(control, data, selected, ...)
                        bladeRef:SetupDropdownRow(control, data, selected)
                    end,
                    ZO_GamepadMenuEntryTemplateParametricListFunction,
                    nil,
                    "ZO_GamepadGuildStoreBrowseHeaderTemplate")

                theList:AddDataTemplate(
                    "ZO_GamepadGuildStoreBrowseSliderTemplate",
                    function(control, data, selected, ...)
                        bladeRef:SetupSliderRow(control, data, selected)
                    end,
                    ZO_GamepadMenuEntryTemplateParametricListFunction)

                -- Item-name search field (guild-store BROWSE style). Same
                -- compact centered header template as the dropdowns so the
                -- "Item Name" label sits tight above the edit box.
                theList:AddDataTemplateWithHeader(
                    "ZO_GamepadTextFieldItem",
                    function(control, data, selected, ...)
                        bladeRef:SetupNameSearchRow(control, data, selected)
                    end,
                    ZO_GamepadMenuEntryTemplateParametricListFunction,
                    nil,
                    "ZO_GamepadGuildStoreBrowseHeaderTemplate")
            end
        end)
    end)
    if ok and list then
        self.list = list
        if list.SetNoItemText then
            pcall(function()
                list:SetNoItemText(GetString(SI_ACCOUNTHOLD_EMPTY) or "No items scanned yet.")
            end)
        end
        -- Follow the cursor: repaint the item tooltip (and refresh keybinds)
        -- whenever the highlighted row changes. We set this AFTER AddList so it
        -- overrides the generic inventory target callback CreateAndSetupList
        -- installs (which is inventory-specific and would not show our detail).
        if list.SetOnTargetDataChangedCallback then
            local blade = self
            pcall(function()
                list:SetOnTargetDataChangedCallback(function(_, selectedData)
                    blade:OnTargetChanged(selectedData)
                end)
            end)
        end
    elseif self.addon and self.addon.Diagnostic then
        self.addon:Diagnostic("warn", "Quartermaster list could not be created: %s",
            shortErr(list))
    end
    return self.list
end

-- Called after a hold is placed/changed elsewhere (e.g. the place-hold dialog)
-- so our detail pane reflects it IMMEDIATELY, without waiting for the player to
-- scroll to another row. Repaints the tooltip for the current target and the
-- item rows (a reserved item may now show its indicator), then refreshes the
-- keybinds. Deferred a frame so it runs after the dialog finishes closing.
function Tab.NotifyHoldChanged()
    local blade = Tab._blade
    if not blade then return end
    local function refresh()
        -- Only touch tooltips / keybinds when OUR list is the one the gamepad
        -- inventory is currently showing. Without this guard, placing or
        -- cancelling a hold from a NATIVE tab (Items / Craft Bag) would run
        -- blade:UpdateTooltip(), which clears GAMEPAD_RIGHT_TOOLTIP and the LEFT
        -- status label — visibly wiping the native item card — and call the
        -- native inventory's RefreshKeybinds out of band. Bail if we're not the
        -- active list.
        local inv = GAMEPAD_INVENTORY
        local ours = blade.list and type(inv) == "table"
            and type(inv.GetCurrentList) == "function"
            and inv:GetCurrentList() == blade.list
        if not ours then return end
        pcall(function() blade:Populate() end)
        pcall(function()
            local td = blade.list and blade.list.GetTargetData and blade.list:GetTargetData()
            blade:UpdateTooltip(td)
        end)
        if type(inv) == "table" and inv.RefreshKeybinds then
            pcall(function() inv:RefreshKeybinds() end)
        end
    end
    if type(zo_callLater) == "function" then
        zo_callLater(refresh, 50)
    else
        refresh()
    end
end

-- ---------------------------------------------------------------------------
-- Inventory header-tab construction (testable seam)
--
-- Builds the tab descriptor appended to the gamepad Inventory header tab bar.
-- The ESO generic header invokes `descriptor.callback()` when the player
-- scrolls onto the tab, so the callback is what switches to our list. The
-- callback is wrapped in pcall so a bad frame degrades to a diagnostic instead
-- of crashing the session.
--
-- `onOpen` is injected so tests can supply a capture function; production
-- passes the SwitchActiveList closure.
-- ---------------------------------------------------------------------------
function Tab.MakeInventoryTabEntry(addonRef, onOpen)
    return {
        text = GetString(SI_ACCOUNTHOLD_OPEN_ENTRY),
        callback = function()
            local ok, err = pcall(onOpen)
            if not ok and addonRef and addonRef.Diagnostic then
                addonRef:Diagnostic("error",
                    "Quartermaster tab open failed: %s", tostring(err))
            end
        end,
    }
end

-- Append our tab descriptor to an existing tab-bar entries list, guarded so a
-- malformed list or a throw can never break the player's inventory header.
-- Returns the appended descriptor (or nil if it could not be appended).
function Tab.AppendInventoryTab(entries, addonRef, onOpen)
    if type(entries) ~= "table" then return nil end
    local descriptor
    local ok = pcall(function()
        descriptor = Tab.MakeInventoryTabEntry(addonRef, onOpen)
        entries[#entries + 1] = descriptor
    end)
    if not ok then return nil end
    return descriptor
end

-- ---------------------------------------------------------------------------
-- Tab module entry point
-- ---------------------------------------------------------------------------
function Tab:Initialize(addonRef)
    self.addon = addonRef

    -- Tracing. Diagnostic("info") is gated behind debugLogging and is captured
    -- by the diagnostics ring buffer either way, so it is silent by default and
    -- still recoverable on console via "Show recent diagnostics".
    -- USE_CHAT routes it to chat instead; it must stay FALSE in shipped builds
    -- (chat is the only diagnostic channel on console, so unconditional tracing
    -- drowns the output you actually need, and it looks like scan spam to the
    -- player). Flip it to true only while debugging the entry point on hardware.
    local USE_CHAT = false
    local function shout(fmt, ...)
        local msg = string.format(fmt, ...)
        if USE_CHAT and addonRef and addonRef.Log then
            addonRef:Log("|cFFD700[AH tab]|r " .. msg)
        elseif addonRef and addonRef.Diagnostic then
            addonRef:Diagnostic("info", "[tab] %s", msg)
        end
    end
    self._shout = shout

    shout("Initialize begin (gamepad=%s, console=%s).",
        tostring(IsInGamepadPreferredMode and IsInGamepadPreferredMode() or false),
        tostring(IsConsoleUI and IsConsoleUI() or false))

    if type(ZO_GamepadInventory) ~= "table"
       or type(ZO_GamepadInventory.GetTabBarEntries) ~= "function"
       or type(ZO_GamepadInventory.SwitchActiveList) ~= "function" then
        shout("SKIP: ZO_GamepadInventory API unavailable (keyboard-only build?).")
        addonRef:Diagnostic("warn",
            "ZO_GamepadInventory API unavailable — third inventory tab NOT added (keyboard-only build?).")
        return
    end

    local blade = Blade.New(addonRef)
    self._blade = blade

    -- The tab callback: switch our list in place, exactly like the built-in
    -- tabs call SwitchActiveList with their own descriptor. This is safe to
    -- call synchronously from the header's tab-change callback (the built-in
    -- tabs do the same); it does NOT show a foreign scene.
    local function openBlade()
        blade:EnsureList()
        if GAMEPAD_INVENTORY and GAMEPAD_INVENTORY.SwitchActiveList then
            GAMEPAD_INVENTORY:SwitchActiveList(ACCOUNT_HOLD_LIST, true)
        end
    end

    -- --- Hook 1: append our tab to the header tab bar. -------------------
    -- RefreshHeader calls GetTabBarEntries() fresh on every header refresh,
    -- so appending here means our tab is re-applied every rebuild. Wrapping
    -- the CLASS method keeps the hook alive across singleton rebuilds.
    if not ZO_GamepadInventory.__AccountHoldTabHooked then
        ZO_GamepadInventory.__AccountHoldTabHooked = true
        local originalGetTabBarEntries = ZO_GamepadInventory.GetTabBarEntries
        ZO_GamepadInventory.GetTabBarEntries = function(inventorySelf, ...)
            local entries = originalGetTabBarEntries(inventorySelf, ...)
            Tab.AppendInventoryTab(entries, addonRef, openBlade)
            return entries
        end
        shout("Hook installed on ZO_GamepadInventory.GetTabBarEntries.")
    end

    -- --- Hook 2: teach SwitchActiveList about our list descriptor. -------
    -- Mirrors the native INVENTORY_CATEGORY_LIST branch (which keeps the
    -- header active) but points at our list + keybinds. Because our descriptor
    -- is now first-class, the framework's own hide/show handling
    -- (SwitchActiveList(nil) on hide, SwitchActiveList(previousListType) on
    -- show) restores/returns to our tab correctly — no scene, no corruption.
    if not ZO_GamepadInventory.__AccountHoldSwitchHooked then
        ZO_GamepadInventory.__AccountHoldSwitchHooked = true
        local originalSwitch = ZO_GamepadInventory.SwitchActiveList
        ZO_GamepadInventory.SwitchActiveList = function(inv, listDescriptor, selectDefaultEntry)
            if listDescriptor ~= ACCOUNT_HOLD_LIST then
                return originalSwitch(inv, listDescriptor, selectDefaultEntry)
            end
            local ok, err = pcall(function()
                if listDescriptor == inv.currentListType then return end
                if inv.IsHeaderActive and inv:IsHeaderActive() and inv.RequestLeaveHeader then
                    inv:RequestLeaveHeader()
                end
                inv.previousListType = inv.currentListType
                inv.currentListType  = listDescriptor

                -- Only actually swap the visible content when the inventory
                -- scene is showing; otherwise just record the type and let the
                -- scene-show path re-enter us (mirrors the native else branch).
                if inv.scene and inv.scene:IsShowing() then
                    blade:EnsureList()
                    if blade.list then
                        -- Clear any tooltip content the previous tab left in
                        -- the detail pane (e.g. the craft bag's item/comparison
                        -- tooltip). Native SwitchActiveList resets these at its
                        -- top — GAMEPAD_TOOLTIPS:Reset(GAMEPAD_LEFT_TOOLTIP) /
                        -- Reset(GAMEPAD_RIGHT_TOOLTIP), gamepadinventory.lua:269-270
                        -- — and our custom branch must do the same or the stale
                        -- content lingers to the right of our list.
                        blade:ClearTooltips()
                        inv:SetCurrentList(blade.list)
                        blade:Populate()
                        if inv.SetActiveKeybinds then
                            inv:SetActiveKeybinds(blade:BuildKeybinds())
                        end
                        inv:RefreshHeader()
                        if inv.ActivateHeader then inv:ActivateHeader() end
                        if inv.RefreshKeybinds then inv:RefreshKeybinds() end
                        -- Paint the detail pane for the initial selection (the
                        -- target-changed callback covers subsequent moves).
                        if blade.list.GetTargetData then
                            blade:UpdateTooltip(blade.list:GetTargetData())
                        end
                    end
                end
            end)
            if not ok and addonRef and addonRef.Log then
                addonRef:Log("|cFF6666[Quartermaster]|r tab switch error: " .. shortErr(err))
            end
        end
        shout("Hook installed on ZO_GamepadInventory.SwitchActiveList.")
    end

    -- --- Hook 3: keep the tab strip visible while our list is current. ---
    -- Stock RefreshHeader falls through to itemListHeaderData (which has no
    -- tabBarEntries) for any non-built-in list, so the tab bar would vanish
    -- on our tab. Inject a header data carrying the current tab entries.
    if not ZO_GamepadInventory.__AccountHoldHeaderHooked then
        ZO_GamepadInventory.__AccountHoldHeaderHooked = true
        local originalRefreshHeader = ZO_GamepadInventory.RefreshHeader
        ZO_GamepadInventory.RefreshHeader = function(inv, blockCallback)
            if blade.list and inv.GetCurrentList and inv:GetCurrentList() == blade.list then
                local ok = pcall(function()
                    blade.headerData = blade.headerData or {}
                    blade.headerData.tabBarEntries = inv:GetTabBarEntries()
                    inv.headerData = blade.headerData
                    if ZO_GamepadGenericHeader_Refresh then
                        ZO_GamepadGenericHeader_Refresh(inv.header, blade.headerData, blockCallback)
                    end
                    -- Our tab has its own in-list "Item Name" field, so the
                    -- native inventory search box at the top is redundant and
                    -- does nothing here. Hide it while our list is current.
                    if inv.textSearchHeaderControl and inv.textSearchHeaderControl.SetHidden then
                        inv.textSearchHeaderControl:SetHidden(true)
                    end
                end)
                if ok then return end
            end
            -- Any other list: make sure the native search box is visible again.
            if inv.textSearchHeaderControl and inv.textSearchHeaderControl.SetHidden then
                pcall(function() inv.textSearchHeaderControl:SetHidden(false) end)
            end
            return originalRefreshHeader(inv, blockCallback)
        end
        shout("Hook installed on ZO_GamepadInventory.RefreshHeader.")
    end

    -- If the inventory has ALREADY completed its deferred initialization
    -- (the player opened Inventory at least once this session), its header
    -- data tables exist and we can safely force a header rebuild so our tab
    -- appears immediately. Before deferred init, both GetCurrentList() and
    -- self.craftBagList are nil, so native RefreshHeader takes the
    -- `currentList == self.craftBagList` branch (nil == nil) and indexes the
    -- not-yet-created craftBagHeaderData (gamepadinventory.lua:1835) — a hard
    -- error. So we MUST NOT force a refresh until deferred init has run; the
    -- tab attaches naturally via our GetTabBarEntries hook the first time the
    -- player opens Inventory. `categoryHeaderData` is built in InitializeHeader
    -- during deferred init, so its presence is our readiness signal.
    -- Our list is created lazily on first tab open (openBlade / the
    -- SwitchActiveList branch both call blade:EnsureList()), so nothing is
    -- created here.
    if type(GAMEPAD_INVENTORY) == "table"
       and GAMEPAD_INVENTORY.categoryHeaderData ~= nil
       and type(GAMEPAD_INVENTORY.RefreshHeader) == "function" then
        local ok, err = pcall(function() GAMEPAD_INVENTORY:RefreshHeader() end)
        if not ok then
            shout("Header refresh skipped: %s", shortErr(err))
        end
    else
        shout("GAMEPAD_INVENTORY singleton not present yet; tab attaches on first inventory open.")
    end

    -- Repaint our list when scanner data changes, but only while our list is
    -- the current one (otherwise the next switch/Populate picks it up). Guarded
    -- so a second attach (re-entry) can't stack duplicate callbacks that would
    -- each retain the blade/list.
    if addonRef.Index and addonRef.Index.RegisterChangeCallback
       and not blade._changeCallbackRegistered then
        blade._changeCallbackRegistered = true
        addonRef.Index:RegisterChangeCallback(function()
            if blade.list and type(GAMEPAD_INVENTORY) == "table"
               and GAMEPAD_INVENTORY.GetCurrentList
               and GAMEPAD_INVENTORY:GetCurrentList() == blade.list then
                pcall(function() blade:Populate() end)
            end
        end)
    end
end
