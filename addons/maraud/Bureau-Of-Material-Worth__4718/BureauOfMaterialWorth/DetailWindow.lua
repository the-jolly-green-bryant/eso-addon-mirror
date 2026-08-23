local addon = BureauOfMaterialWorth
addon.DetailWindow = addon.DetailWindow or {}

local DetailWindow = addon.DetailWindow
local private = addon.private

local GetString = GetString
local stringformat = string.format
local zo_round = zo_round
local zo_floor = zo_floor
local mathabs = math.abs
local tablesort = table.sort
local GetTimeStamp = GetTimeStamp

-- Palette (shared house style; see private.COLOR_* in BureauOfMaterialWorth.lua)
local COLOR_ACCENT = private.COLOR_ACCENT
local COLOR_MUTED  = private.COLOR_MUTED
local COLOR_WARN   = private.COLOR_WARN
local COLOR_GAIN   = private.COLOR_GAIN
local COLOR_LOSS   = private.COLOR_LOSS

-- Shared visual language (UI.lua). Every font, control tint, divider weight and
-- tooltip line in this file comes from here, so the material table cannot drift
-- away from the summary panel and the withdraw window the way it had.
local UI = private.UI
local FONT = UI.FONT
local METRIC = UI.METRIC

-- The column headers are sort toggles, so their tone is set with SetColor rather
-- than an inline |c code (the hover handler brightens one to white, which an
-- embedded colour would fight). Derived from the palette's muted tone instead of
-- being written out as a triple, so header text and every other secondary label
-- are provably the same grey.
local HEADER_MUTED_R, HEADER_MUTED_G, HEADER_MUTED_B = UI.Tone("muted")

-- Cumulative-share column coloring. The figure marks the Pareto "knee": rows up
-- to CUM_CORE_THRESHOLD make up the bulk of the value (the stacks worth hauling),
-- everything past it is the long tail. We make that readable at a glance:
--   * 0 .. threshold  : ramp from a dim tone to a vivid hot one, so the core rows
--                       that build toward the knee read as "warm = keep". The
--                       endpoints are spread WIDE in brightness on purpose - a
--                       narrow ramp is invisible on small text over a dark panel,
--                       and the value distribution often bunches the core rows
--                       into the upper part of the range.
--   * past threshold  : NOT colored - it falls back to the muted grey of the rest
--                       of the secondary text, so the long tail recedes and the
--                       eye is drawn to the warm core. (A red tail would collide
--                       with the price-change column, where red means "price
--                       fell"; de-emphasis, not warning, is the right signal.)
-- Endpoints are normalized RGB triples; the ramp interpolates between CORE_LO and
-- CORE_HI.
local CUM_CORE_THRESHOLD = 80   -- percent; the Pareto cut between core and tail
local CUM_CORE_LO  = { 0.50, 0.48, 0.42 }  -- dim warm grey: low % (top, most value)
local CUM_CORE_HI  = { 1.00, 0.80, 0.20 }  -- vivid gold: approaching the threshold

-- Build a "RRGGBB" hex string from a normalized RGB triple, for inline |c codes.
local function RGBToHex(r, g, b)
    return stringformat("%02X%02X%02X",
        zo_round(r * 255), zo_round(g * 255), zo_round(b * 255))
end

-- Pick the cumulative-share color for a given percent: a dim->vivid ramp across
-- the core (0..threshold), or COLOR_MUTED for the past-threshold tail so it reads
-- as plain de-emphasized text. Returns a hex string ready for Colorize.
local function CumulativeColor(percent)
    if percent > CUM_CORE_THRESHOLD then
        return COLOR_MUTED
    end
    local frac = percent / CUM_CORE_THRESHOLD  -- 0 at top, 1 at the knee
    local r = CUM_CORE_LO[1] + frac * (CUM_CORE_HI[1] - CUM_CORE_LO[1])
    local g = CUM_CORE_LO[2] + frac * (CUM_CORE_HI[2] - CUM_CORE_LO[2])
    local b = CUM_CORE_LO[3] + frac * (CUM_CORE_HI[3] - CUM_CORE_LO[3])
    return RGBToHex(r, g, b)
end

-- The cumulative column's header text ("Cum. 80%"), with the threshold filled in
-- from CUM_CORE_THRESHOLD rather than hardcoded in the localized string. Both
-- places that set the header label call this, so changing the constant above
-- changes the header in every language at once.
local function CumulativeHeaderText()
    return stringformat(GetString(SI_BMW_DETAIL_COL_CUM), CUM_CORE_THRESHOLD)
end

local GOLD_ICON = private.GOLD_ICON
local FEE_LISTING_RATE = private.FEE_LISTING_RATE
local FEE_SALES_RATE = private.FEE_SALES_RATE
-- Same sort-arrow textures Window.lua uses for its delta, for the same reason:
-- the ESO UI font doesn't render the Unicode triangles reliably.
local ARROW_UP = "|t16:16:EsoUI/Art/Miscellaneous/list_sortUp.dds|t"
local ARROW_DOWN = "|t16:16:EsoUI/Art/Miscellaneous/list_sortDown.dds|t"

-- Layout
-- ---------------------------------------------------------------------------
local WINDOW_WIDTH = 800   -- widened from 720 for the cumulative-share column
-- A free-floating window, so it takes the wider step of the shared spacing scale
-- (the narrow summary panel takes METRIC.PADDING). Every inset below is derived
-- from this, so the whole frame re-flows from the one token.
local PADDING      = METRIC.PADDING_WIDE
local TITLE_HEIGHT = 26
local CONTEXT_HEIGHT = 18
local HEADER_HEIGHT = 20
local ROW_ACTION_WIDTH = 48
local DIVIDER_GAP  = 10
local ROW_HEIGHT   = 26
local LIST_MAX_ROWS = 16   -- beyond this the list scrolls instead of growing
local FOOTER_HEIGHT = 18   -- summary line beneath the list (divider + this label)


-- Single row data type id for the scroll list (we only have one kind of row).
local ROW_TYPE_ID = 1

-- The row template's text columns, by name suffix (see DetailWindow.xml). The
-- markup declares their geometry only; this list is what SetupRow hands to
-- UI.ApplyRowFonts so all five carry the shared body face. Adding a column means
-- adding it in both places.
local ROW_COLUMNS = { "Name", "Qty", "Value", "Cum", "Change" }

-- Search debounce. GetMaterialsMatching walks every occupied slot and filters by
-- name, so running it on every keystroke micro-stutters on a large craft bag.
-- Instead a keystroke arms this timer and only the last one within the window
-- actually rebuilds the list -- the coalescing pattern the Valuation getter's
-- comment already assumes ("debounced by the caller"). Short enough to feel
-- instant, long enough to collapse a fast typist's burst into one rebuild.
local SEARCH_DEBOUNCE_MS = 150
local SEARCH_TIMER_NAME = addon.name .. "_DetailSearchDebounce"

-- Identifier for the "clear snapshot?" confirmation dialog, registered once in
-- Initialize. Clearing is destructive (one snapshot, no undo), so a stray click
-- on the toolbar button must not wipe the baseline without a confirm.
local CLEAR_SNAPSHOT_DIALOG = "BUREAU_OF_MATERIAL_WORTH_CLEAR_SNAPSHOT"

local Colorize = private.Colorize
local FormatGold = private.FormatGold

-- "How long ago" for the diff title, from a unix timestamp (GetTimeStamp) to a
-- short localized phrase. Note this works off the unix clock, NOT
-- GetGameTimeMilliseconds like Window's footer: the snapshot persists across
-- sessions, so its age must survive a restart. Unlike the footer (game-time, so
-- never more than a session old) this can span days, so it composes the largest
-- non-zero unit plus the next smaller one - "5d 3h", "3h 20m", "45m" - instead
-- of an unbounded hour count like "123h". The _AGO wrapper keeps word order
-- localizable.
local function FormatSnapshotAge(stampSeconds)
    if not stampSeconds then
        return GetString(SI_BMW_TIME_NEVER)
    end

    local seconds = GetTimeStamp() - stampSeconds
    if seconds < 5 then
        return GetString(SI_BMW_TIME_JUST_NOW)
    elseif seconds < 60 then
        return stringformat(GetString(SI_BMW_TIME_SECONDS), seconds)
    end

    local totalMinutes = zo_floor(seconds / 60)
    local days = zo_floor(totalMinutes / (60 * 24))
    local hours = zo_floor((totalMinutes - days * 60 * 24) / 60)
    local minutes = totalMinutes - days * 60 * 24 - hours * 60

    -- Largest non-zero unit + the immediately smaller one (when non-zero), capped
    -- at two parts so the phrase stays compact and never jumps a zero unit.
    local parts = {}
    if days > 0 then
        parts[1] = stringformat(GetString(SI_BMW_TIME_UNIT_DAYS), days)
        if hours > 0 then
            parts[2] = stringformat(GetString(SI_BMW_TIME_UNIT_HOURS), hours)
        end
    elseif hours > 0 then
        parts[1] = stringformat(GetString(SI_BMW_TIME_UNIT_HOURS), hours)
        if minutes > 0 then
            parts[2] = stringformat(GetString(SI_BMW_TIME_UNIT_MINUTES), minutes)
        end
    else
        parts[1] = stringformat(GetString(SI_BMW_TIME_UNIT_MINUTES), minutes)
    end

    return stringformat(GetString(SI_BMW_TIME_AGO), table.concat(parts, " "))
end

-- Runtime control references, created once in Initialize().
local windowControl   -- top-level container
local backdrop        -- background + border
local headerBand      -- accent wash + underline behind the title and scope line
local titleLabel      -- "<Category> - materials"
local contextLabel    -- active category/search/diff scope beneath the title
local headerName, headerQty, headerValue, headerCum, headerChange  -- column headers
local divider
local listControl     -- ZO_ScrollList
local footerDivider   -- rule above the summary line
local footerLabel     -- summary beneath the list (count/value/share, or diff net)
local emptyLabel      -- shown when the category has no materials
local currentCategoryId  -- remembered so a refresh can rebuild the same view
local currentCategoryName  -- remembered so the title can restore after a search
local searchBox       -- the search editbox
local searchHint      -- placeholder inside the search box
local searchClearButton -- clears the whole-bag search without touching filters
local changesButton   -- toolbar button; toggles between "Changes" and "Back"
local snapshotStatusLabel -- compact persistent state of the saved comparison baseline
local filterButtons = {} -- { all, priced, unpriced } price-coverage filter controls
local selectedFilterFrame -- accent outline around the active price filter
local resetFiltersButton -- clears the active price filter and/or text query
local searchQuery = ""  -- current search text; "" means "show the category"
local suppressSearchEvent = false  -- guards the search box against its own SetText
local currentResultCount = 0  -- rows in the list just built by Populate; feeds the
                              -- search-result counter in the title
local priceFilter = "all"  -- "all" | "priced" | "unpriced"

-- Which list the window is showing. "category" is the normal per-category table
-- (with the whole-bag search as a sub-state, driven by searchQuery); "diff" is
-- the snapshot comparison, where the Qty/Value/Cum/Change columns are repurposed
-- to signed deltas / share-of-change / status (see SetupRow and UpdateHeaders).
local viewMode = "category"  -- "category" | "diff"
local diffSource = "snapshot"  -- "snapshot" | "visit"

-- Column sort state. The list is re-sorted in Populate() before it fills, so it
-- applies equally to a category view, the whole-bag search, and a live refresh.
-- Default to value-descending: the practical "what to sell right now" order, so
-- the stacks that make up most of the bag's worth sit at the top on open.
--   sortKey: "name" | "qty" | "value" | "change"
--   sortAsc: ascending when true. Numeric columns default to descending (biggest
--            first); the name column defaults to ascending (A->Z).
local sortKey = "value"
local sortAsc = false

-- Forward declarations so the search-box handlers built in Initialize can
-- capture these as upvalues; they are defined (as plain assignments) further
-- down, after Initialize.
local FillList, Populate, UpdateTitle, UpdateContext, UpdateHeaders, UpdateColumnLayout, UpdatePriceFilterButtons, UpdateSnapshotStatus

-- The basic table focuses on the immediate inventory decision: what it is, how
-- much is held, and what it is worth. Analytics adds the Pareto and price-drift
-- columns. Snapshot comparison always keeps its full delta/share/status layout.
local function UsesAnalyticsColumns()
    if viewMode == "diff" then
        return true
    end
    return private.savedVars and private.savedVars.detailColumnMode == "analytics"
end

-- Coalesce a burst of search keystrokes into a single rebuild. Each keystroke
-- re-arms the one-shot timer; only the last one within SEARCH_DEBOUNCE_MS fires,
-- and it calls Populate against the current searchQuery. Mirrors the coalescing
-- Valuation uses for its window refresh, and satisfies the "debounced by the
-- caller" contract on GetMaterialsMatching. Populate is an upvalue resolved by
-- the time this ever runs (Initialize, which wires the handler, runs after the
-- assignments below).
local function QueueSearch()
    EVENT_MANAGER:UnregisterForUpdate(SEARCH_TIMER_NAME)
    EVENT_MANAGER:RegisterForUpdate(SEARCH_TIMER_NAME, SEARCH_DEBOUNCE_MS, function()
        EVENT_MANAGER:UnregisterForUpdate(SEARCH_TIMER_NAME)
        -- Hide() also cancels this timer, but guard anyway: never rebuild into a
        -- hidden window if the two ever race.
        if not windowControl or windowControl:IsHidden() then
            return
        end
        Populate()
    end)
end

-- Build the colored price-change text for a material row: an up/down arrow (the
-- texture carries the direction) plus a colored magnitude, matching Window.lua's
-- footer-delta idiom. Returns nil when there is no comparable change (no price,
-- no baseline yet, or no recorded percent) so the caller can fall back to a dash.
-- Shared by the Change column and the row hover tooltip so the two never drift.
local function FormatGrowthText(data)
    if data.priced and not data.isNew and data.growthPercent ~= nil then
        local gain = data.growthDir
        local color = gain and COLOR_GAIN or COLOR_LOSS
        local arrow = gain and ARROW_UP or ARROW_DOWN
        local magnitude = stringformat("%.1f", mathabs(data.growthPercent))
        return arrow .. " " .. Colorize(color,
            stringformat(GetString(SI_BMW_DETAIL_GROWTH), magnitude))
    end
    return nil
end

-- Render the Qty / Value / Cumulative / Change columns for a normal material row
-- (category view or whole-bag search). Split out of SetupRow so the diff view can
-- repurpose the same four controls without threading a mode flag through each.
local function SetupMaterialColumns(rowControl, data)
    rowControl:GetNamedChild("Qty"):SetText(
        Colorize(COLOR_MUTED, ZO_LocalizeDecimalNumber(data.count or 0)))

    rowControl:GetNamedChild("Value"):SetText(FormatGold(data.gold))

    -- Cumulative-share column: this row's running share of the displayed list's
    -- total value, assigned in Populate after the sort. Read top-down on the
    -- default value-descending view it answers "the top stacks down to here make
    -- up N% of the bag's worth" - the Pareto "what to sell" cue. Unpriced rows
    -- (and any view where the figure is meaningless) carry nil and show a dash.
    local cumLabel = rowControl:GetNamedChild("Cum")
    if data.cumPercent ~= nil then
        cumLabel:SetText(Colorize(CumulativeColor(data.cumPercent),
            stringformat(GetString(SI_BMW_DETAIL_CUM), data.cumPercent)))
    else
        cumLabel:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_GROWTH_NEW)))
    end

    -- Price-change column: an up/down arrow (the texture carries the direction)
    -- plus a colored magnitude, matching Window.lua's footer-delta idiom. A
    -- material with no recorded baseline yet, or no price at all, shows a dash.
    local changeLabel = rowControl:GetNamedChild("Change")
    local growthText = FormatGrowthText(data)
    if growthText then
        changeLabel:SetText(growthText)
    else
        changeLabel:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_GROWTH_NEW)))
    end
end

-- Map a diff status to its localized word. Four states: new (added since the
-- snapshot), gone (removed entirely), added (quantity went up), reduced (quantity
-- went down).
local DIFF_STATUS_STRING = {
    new = SI_BMW_DETAIL_STATUS_NEW,
    gone = SI_BMW_DETAIL_STATUS_GONE,
    added = SI_BMW_DETAIL_STATUS_ADDED,
    reduced = SI_BMW_DETAIL_STATUS_REDUCED,
}

-- Render the same four columns for a diff row, repurposed:
--   Qty    -> signed count delta (green up / red down)
--   Value  -> arrow + colored signed gold delta + gold icon (Change-column idiom);
--             a dash when the material is unpriced
--   Cum    -> share of total absolute change, assigned in Populate (else dash)
--   Change -> colored status word (new / gone / added / reduced)
-- A positive delta is a gain (deposited/added), negative a loss (withdrawn/gone),
-- colored with the same green/red the price-change column uses.
local function SetupDiffColumns(rowControl, data)
    local up = (data.countDelta or 0) >= 0
    local deltaColor = up and COLOR_GAIN or COLOR_LOSS
    local arrow = up and ARROW_UP or ARROW_DOWN
    local sign = up and "+" or "-"

    -- Qty delta: signed integer, colored by direction.
    rowControl:GetNamedChild("Qty"):SetText(Colorize(deltaColor,
        stringformat(GetString(SI_BMW_DETAIL_QTY_DELTA), sign,
            ZO_LocalizeDecimalNumber(mathabs(data.countDelta or 0)))))

    -- Value delta: arrow + colored magnitude + gold icon, or a dash when the
    -- material has no price to value the move with.
    local valueLabel = rowControl:GetNamedChild("Value")
    if data.priced and data.goldDelta ~= nil then
        local magnitude = ZO_LocalizeDecimalNumber(zo_round(mathabs(data.goldDelta)))
        valueLabel:SetText(arrow .. " " .. Colorize(deltaColor, magnitude) .. " " .. GOLD_ICON)
    else
        valueLabel:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_GROWTH_NEW)))
    end

    -- Cum -> share of the list's total movement (abs gold delta), assigned in
    -- Populate. Reuses the same warm gradient as the category view. Dash fallback.
    local cumLabel = rowControl:GetNamedChild("Cum")
    if data.cumPercent ~= nil then
        cumLabel:SetText(Colorize(CumulativeColor(data.cumPercent),
            stringformat(GetString(SI_BMW_DETAIL_CUM), data.cumPercent)))
    else
        cumLabel:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_GROWTH_NEW)))
    end

    -- Change -> status word, colored by direction: gains (new / added) green,
    -- losses (gone / reduced) red. The Qty/Value columns carry the magnitude.
    local changeLabel = rowControl:GetNamedChild("Change")
    local statusStringId = DIFF_STATUS_STRING[data.status]
    local statusColor = COLOR_MUTED
    if data.status == "new" or data.status == "added" then
        statusColor = COLOR_GAIN
    elseif data.status == "gone" or data.status == "reduced" then
        statusColor = COLOR_LOSS
    end
    if statusStringId then
        changeLabel:SetText(Colorize(statusColor, GetString(statusStringId)))
    else
        changeLabel:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_GROWTH_NEW)))
    end
end

-- Populate one recycled row from its material record. Mirrors the column
-- geometry declared in DetailWindow.xml.
local function SetupRow(rowControl, data)
    -- Stash the current record on the control so the click handlers (bound once
    -- below) always act on the freshest data; ZO_ScrollList recycles a small
    -- pool of rows across many materials.
    rowControl.bmwData = data

    -- The template declares the columns' geometry; their face comes from the
    -- shared type scale, so a row of the table reads at the same size as a row of
    -- the summary panel. No-ops after the first time this control is used.
    UI.ApplyRowFonts(rowControl, ROW_COLUMNS)

    rowControl:GetNamedChild("Icon"):SetTexture(data.icon)

    local nameLabel = rowControl:GetNamedChild("Name")
    -- The name column is a fixed width (anchored both sides), so long material
    -- names would be silently clipped mid-word. Ellipsize instead so it reads
    -- "Decorative Wax Sea…" and the truncation is visible. The full name is
    -- always available in the game's own item tooltip.
    nameLabel:SetMaxLineCount(1)
    nameLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    nameLabel:SetText(addon.Valuation.ColorizeMaterialName(data.name, data.quality))

    local sourceBg = rowControl:GetNamedChild("SourceBg")
    local sourceLabel = rowControl:GetNamedChild("Source")
    local sourceBadge = not data.diff and data.priced
        and addon.Valuation.GetSourceShortName(data.source) or nil
    UI.PaintRowFill(sourceBg, "badge")
    sourceLabel:SetFont(FONT.small)
    sourceLabel:SetText(sourceBadge and Colorize(COLOR_ACCENT, sourceBadge) or "")
    sourceBg:SetHidden(sourceBadge == nil)
    sourceLabel:SetHidden(sourceBadge == nil)

    nameLabel:ClearAnchors()
    nameLabel:SetAnchor(LEFT, rowControl:GetNamedChild("Icon"), RIGHT, 6, 0)
    if sourceBadge then
        nameLabel:SetAnchor(RIGHT, sourceBg, LEFT, -6, 0)
    else
        nameLabel:SetAnchor(RIGHT, rowControl:GetNamedChild("Qty"), LEFT, -6, 0)
    end

    -- Diff rows repurpose the four numeric/status columns; a category/search row
    -- renders them as the normal Qty / Value / Cumulative / Change. Branch once on
    -- the diff flag rather than threading mode through every column.
    if data.diff then
        SetupDiffColumns(rowControl, data)
    else
        SetupMaterialColumns(rowControl, data)
    end

    -- The action buttons occupy a fixed strip at the right edge, preserving the
    -- column geometry whether they are shown or hidden. Diff rows do not carry a
    -- live Craft Bag slot, so never offer withdrawal actions for them.
    -- The row wash is the shared accent hover, not this file's own grey: pointing
    -- at a material row, a category row in the summary panel and a queue row in
    -- the withdraw window now all light up the same way. The backdrop comes from
    -- the XML template, and UI.PaintRowFill flattens it to a bare rectangle for
    -- us, so this file states no colours and no edge of its own.
    UI.PaintRowFill(rowControl:GetNamedChild("Hover"))
    local withdrawButton = rowControl:GetNamedChild("Withdraw")
    local queueButton = rowControl:GetNamedChild("Queue")
    rowControl.bmwRowHovered = false
    rowControl.bmwActionHovered = false
    withdrawButton:SetHidden(true)
    queueButton:SetHidden(true)

    local useAnalytics = UsesAnalyticsColumns()
    local valueLabel = rowControl:GetNamedChild("Value")
    valueLabel:ClearAnchors()
    if useAnalytics then
        valueLabel:SetAnchor(RIGHT, rowControl:GetNamedChild("Cum"), LEFT, -6, 0)
    else
        valueLabel:SetAnchor(RIGHT, queueButton, LEFT, -6, 0)
    end
    rowControl:GetNamedChild("Cum"):SetHidden(not useAnalytics)
    rowControl:GetNamedChild("Change"):SetHidden(not useAnalytics)

    -- Bind action-button handlers once per recycled control (sentinel), then let
    -- them read rowControl.bmwData at event time. Actions intentionally live only
    -- on the explicit buttons: clicks on the rest of the row remain non-mutating.
    -- Diff rows carry no source slot (a removed material has none at all), so the
    -- buttons and row tooltip are guarded on the diff flag at event time.
    if not rowControl.bmwClickBound then
        rowControl.bmwClickBound = true

        local actionHideTimer = rowControl:GetName() .. "_ActionHide"

        local function ShowActionTooltip(control, stringId)
            InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -2, TOP)
            UI.TipLine(InformationTooltip, GetString(stringId))
        end

        local function CancelActionHide()
            EVENT_MANAGER:UnregisterForUpdate(actionHideTimer)
        end

        local function ShowActions()
            CancelActionHide()
            rowControl:GetNamedChild("Withdraw"):SetHidden(false)
            rowControl:GetNamedChild("Queue"):SetHidden(false)
        end

        -- Moving onto a child button triggers OnMouseExit for the row in ESO.
        -- Defer hiding briefly and let either button cancel that pending hide, so
        -- the controls stay stable while the pointer crosses the boundary.
        local function QueueActionHide()
            CancelActionHide()
            EVENT_MANAGER:RegisterForUpdate(actionHideTimer, 75, function()
                EVENT_MANAGER:UnregisterForUpdate(actionHideTimer)
                if not rowControl.bmwRowHovered and not rowControl.bmwActionHovered then
                    rowControl:GetNamedChild("Withdraw"):SetHidden(true)
                    rowControl:GetNamedChild("Queue"):SetHidden(true)
                end
            end)
        end

        -- Use the familiar game accept/plus iconography rather than tiny text
        -- buttons. The actions are discoverable on hover and replace the former
        -- hidden left/right-click gestures on the row itself.
        local withdrawButton = rowControl:GetNamedChild("Withdraw")
        withdrawButton:SetNormalTexture("EsoUI/Art/Buttons/accept_up.dds")
        withdrawButton:SetMouseOverTexture("EsoUI/Art/Buttons/accept_over.dds")
        withdrawButton:SetPressedTexture("EsoUI/Art/Buttons/accept_down.dds")
        withdrawButton:SetHandler("OnClicked", function(self)
            local rowData = self:GetParent().bmwData
            if rowData and not rowData.diff and addon.WithdrawDialog then
                addon.WithdrawDialog.Open(rowData)
            end
        end)
        withdrawButton:SetHandler("OnMouseEnter", function(self)
            rowControl.bmwActionHovered = true
            CancelActionHide()
            ShowActionTooltip(self, SI_BMW_DETAIL_ACTION_WITHDRAW_TOOLTIP)
        end)
        withdrawButton:SetHandler("OnMouseExit", function()
            rowControl.bmwActionHovered = false
            ClearTooltip(InformationTooltip)
            QueueActionHide()
        end)

        local queueButton = rowControl:GetNamedChild("Queue")
        queueButton:SetNormalTexture("EsoUI/Art/Buttons/plus_up.dds")
        queueButton:SetMouseOverTexture("EsoUI/Art/Buttons/plus_over.dds")
        queueButton:SetPressedTexture("EsoUI/Art/Buttons/plus_down.dds")
        queueButton:SetHandler("OnClicked", function(self)
            local rowData = self:GetParent().bmwData
            if rowData and not rowData.diff and addon.WithdrawDialog then
                addon.WithdrawDialog.AddToQueue(rowData)
            end
        end)
        queueButton:SetHandler("OnMouseEnter", function(self)
            rowControl.bmwActionHovered = true
            CancelActionHide()
            ShowActionTooltip(self, SI_BMW_DETAIL_ACTION_QUEUE_TOOLTIP)
        end)
        queueButton:SetHandler("OnMouseExit", function()
            rowControl.bmwActionHovered = false
            ClearTooltip(InformationTooltip)
            QueueActionHide()
        end)

        rowControl:SetHandler("OnMouseEnter", function(self)
            self.bmwRowHovered = true
            local rowData = self.bmwData
            -- Diff rows carry a different shape (deltas/status, no source slot) and
            -- no withdraw affordance, so they get no hover tooltip.
            if not rowData or rowData.diff then
                return
            end

            self:GetNamedChild("Hover"):SetHidden(false)
            ShowActions()

            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -2, TOP)

            -- Composed in the shared tooltip voice: a title, block openers, and
            -- one line per fact whose tone names the KIND of fact it carries (a
            -- gold figure, a fee leaving the sale, the take-home amount, a plain
            -- count, a warning). No font or colour is decided here.
            --
            -- Title: the quality-colored material name (the |c codes are carried in
            -- the string itself, so the tone underneath it is just the base).
            UI.TipTitle(InformationTooltip,
                addon.Valuation.ColorizeMaterialName(rowData.name, rowData.quality))

            -- Value block: stock, market price, explicit guild-trader deductions,
            -- and take-home amount. Technical provenance follows in its own block.
            UI.TipSection(InformationTooltip, GetString(SI_BMW_ROW_TOOLTIP_VALUE_SECTION))
            UI.TipLine(InformationTooltip, stringformat(GetString(SI_BMW_ROW_TOOLTIP_QTY),
                ZO_LocalizeDecimalNumber(rowData.count or 0)), "soft")

            if rowData.priced and rowData.unitPrice and rowData.unitPrice > 0 then
                UI.TipLine(InformationTooltip, stringformat(GetString(SI_BMW_ROW_TOOLTIP_UNIT),
                    FormatGold(rowData.unitPrice)), "soft")
                UI.TipLine(InformationTooltip, stringformat(GetString(SI_BMW_ROW_TOOLTIP_TOTAL),
                    FormatGold(rowData.gold)), "gold")
                UI.TipLine(InformationTooltip, stringformat(GetString(SI_BMW_ROW_TOOLTIP_LISTING_FEE),
                    FormatGold(rowData.gold * FEE_LISTING_RATE)), "warn")
                UI.TipLine(InformationTooltip, stringformat(GetString(SI_BMW_ROW_TOOLTIP_SALES_TAX),
                    FormatGold(rowData.gold * FEE_SALES_RATE)), "warn")
                UI.TipLine(InformationTooltip, stringformat(GetString(SI_BMW_ROW_TOOLTIP_NET),
                    FormatGold(private.NetAfterFees(rowData.gold))), "accent")
            else
                UI.TipLine(InformationTooltip, GetString(SI_BMW_ROW_TOOLTIP_UNPRICED), "warn")
            end

            if rowData.priced and rowData.unitPrice and rowData.unitPrice > 0 then
                local sourceName = rowData.source and addon.Valuation.GetSourceDisplayName(rowData.source)
                local growthText = FormatGrowthText(rowData)
                if sourceName or growthText then
                    UI.TipDivider(InformationTooltip)
                    UI.TipSection(InformationTooltip,
                        GetString(SI_BMW_ROW_TOOLTIP_TECHNICAL_SECTION))
                end
                -- Provenance is a footnote about the figures above, not another
                -- figure, so both lines drop to the caption size.
                if sourceName then
                    UI.TipCaption(InformationTooltip, stringformat(
                        GetString(SI_BMW_ROW_TOOLTIP_SOURCE), sourceName))
                end
                -- Price-change line, only when there's a comparable figure (shares
                -- the arrow+color idiom of the Change column via FormatGrowthText).
                if growthText then
                    UI.TipCaption(InformationTooltip, stringformat(
                        GetString(SI_BMW_ROW_TOOLTIP_CHANGE), growthText))
                end
            end


        end)
        rowControl:SetHandler("OnMouseExit", function(self)
            self.bmwRowHovered = false
            self:GetNamedChild("Hover"):SetHidden(true)
            ClearTooltip(InformationTooltip)
            QueueActionHide()
        end)
    end
end

-- Height of the header wash: the identity block this window opens with (its title
-- plus the scope line beneath it) and their top padding, closed by a little air
-- under the last line so the accent underline does not crowd the text above it.
-- Derived rather than a constant, so a change to either row carries the band.
local function HeaderBandHeight()
    return PADDING + TITLE_HEIGHT + CONTEXT_HEIGHT + METRIC.BAND_PAD
end

function DetailWindow.Initialize()
    if windowControl then
        return
    end

    local innerWidth = WINDOW_WIDTH - PADDING * 2

    windowControl = WINDOW_MANAGER:CreateTopLevelWindow(addon.name .. "_DetailWindow")
    windowControl:SetClampedToScreen(true)
    windowControl:SetDimensions(WINDOW_WIDTH, 200)
    windowControl:SetHidden(true)
    windowControl:SetMouseEnabled(true)
    windowControl:SetMovable(true)
    -- Restore the player's last placement. A new installation has no saved
    -- coordinates, so it starts centered once and then remembers drag stops.
    local savedVars = private.savedVars or {}
    if savedVars.detailWindowLeft and savedVars.detailWindowTop then
        windowControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
            savedVars.detailWindowLeft, savedVars.detailWindowTop)
    else
        windowControl:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    windowControl:SetHandler("OnMoveStop", function(self)
        local vars = private.savedVars
        if vars then
            vars.detailWindowLeft = zo_round(self:GetLeft())
            vars.detailWindowTop = zo_round(self:GetTop())
        end
    end)

    -- Confirmation dialog for the destructive "Clear snapshot" action. Registered
    -- once; the accept callback does the actual clear so a stray button click only
    -- opens the prompt. Uses the standard two-button ESO dialog so it matches the
    -- game's look and the cancel path needs no custom wiring.
    ZO_Dialogs_RegisterCustomDialog(CLEAR_SNAPSHOT_DIALOG, {
        title = { text = GetString(SI_BMW_DETAIL_CLEAR_CONFIRM_TITLE) },
        mainText = { text = GetString(SI_BMW_DETAIL_CLEAR_CONFIRM_BODY) },
        buttons = {
            {
                text = GetString(SI_BMW_DETAIL_CLEAR_CONFIRM_ACCEPT),
                callback = function()
                    addon.Valuation.ClearSnapshot()
                    private.ChatInfo(SI_BMW_MSG_SNAPSHOT_CLEARED)
                    UpdateSnapshotStatus()
                    -- Refresh the diff view in place so it drops to the "press
                    -- Remember" empty state immediately after the clear.
                    if viewMode == "diff" then
                        Populate()
                    end
                end,
            },
            {
                text = GetString(SI_BMW_DETAIL_CLEAR_CONFIRM_CANCEL),
            },
        },
    })

    backdrop = WINDOW_MANAGER:CreateControl(addon.name .. "_DetailBackdrop", windowControl, CT_BACKDROP)
    backdrop:SetAnchorFill(windowControl)
    -- One call for the whole shell: ground, border, insets and opacity all come
    -- from the shared chrome, so this window is the same surface as the other two
    -- rather than a third slightly different near-black.
    UI.ApplyPanelChrome(backdrop)

    -- The shared letterhead, behind the title and its scope line: a faint accent
    -- wash the full width of the window, closed by an accent underline. Created
    -- before those labels so it sits behind them, and spanning the full width (not
    -- the inner width) so it reads as a band rather than a floating rectangle.
    headerBand = UI.CreateHeaderBand(addon.name .. "_DetailHeaderBand", windowControl,
        WINDOW_WIDTH, HeaderBandHeight())
    headerBand:SetAnchor(TOPLEFT, windowControl, TOPLEFT, 0, 0)

    titleLabel = WINDOW_MANAGER:CreateControl(addon.name .. "_DetailTitle", windowControl, CT_LABEL)
    -- The section-heading step, not the title step: TITLE_HEIGHT is a 26px row
    -- shared with the toolbar buttons, and the larger title face would clip in it.
    titleLabel:SetFont(FONT.heading)
    titleLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    titleLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    titleLabel:SetMaxLineCount(1)
    titleLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    titleLabel:SetAnchor(TOPLEFT, windowControl, TOPLEFT, PADDING, PADDING)
    -- The title has its own row (only the close button shares it), so it can run
    -- the full width up to the close button. Snapshot actions and list filters
    -- occupy their own toolbar rows below.
    titleLabel:SetDimensions(WINDOW_WIDTH - PADDING * 2 - 32 - 8, TITLE_HEIGHT)
    titleLabel:SetMouseEnabled(true)
    titleLabel:SetHandler("OnMouseEnter", function(self)
        if viewMode ~= "diff" or diffSource ~= "visit" then
            return
        end
        InitializeTooltip(InformationTooltip, self, BOTTOMLEFT, 0, 4, TOPLEFT)
        UI.TipTitle(InformationTooltip, GetString(SI_BMW_DETAIL_VISIT_DIFF_TOOLTIP_TITLE))
        UI.TipLine(InformationTooltip, GetString(SI_BMW_DETAIL_VISIT_DIFF_TOOLTIP_BODY))
    end)
    titleLabel:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    -- A persistent, muted scope line makes the active representation explicit:
    -- category vs whole-bag search vs snapshot comparison. The title stays short
    -- and scannable while this line carries result count, price filter, or age.
    contextLabel = WINDOW_MANAGER:CreateControl(addon.name .. "_DetailContext", windowControl, CT_LABEL)
    contextLabel:SetFont(FONT.small)
    contextLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    contextLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    contextLabel:SetMaxLineCount(1)
    contextLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    contextLabel:SetDimensions(WINDOW_WIDTH - PADDING * 2, CONTEXT_HEIGHT)
    contextLabel:SetAnchor(TOPLEFT, windowControl, TOPLEFT, PADDING, PADDING + TITLE_HEIGHT)

    -- Close button (built-in virtual) anchored top-right.
    local closeButton = WINDOW_MANAGER:CreateControlFromVirtual(
        addon.name .. "_DetailClose", windowControl, "ZO_CloseButton")
    closeButton:SetAnchor(TOPRIGHT, windowControl, TOPRIGHT, -PADDING, PADDING)
    closeButton:SetHandler("OnClicked", function()
        DetailWindow.Hide()
    end)

    -- Two distinct toolbar rows keep snapshot actions separate from list filters:
    -- the first owns Remember / Changes / Clear, the second owns price coverage
    -- filters and whole-bag search. TOOLBAR_GAP provides the vertical air between
    -- each row and the surrounding controls.
    local TOOLBAR_GAP = 6
    local snapshotToolbarY = PADDING + TITLE_HEIGHT + CONTEXT_HEIGHT + TOOLBAR_GAP
    local filterToolbarY = snapshotToolbarY + TITLE_HEIGHT + TOOLBAR_GAP

    -- Search box (whole-bag). Typing here switches the list to materials matching
    -- the query across every category; clearing it returns to the opened category.
    local SEARCH_WIDTH = 240
    local searchBg = WINDOW_MANAGER:CreateControlFromVirtual(
        addon.name .. "_DetailSearchBg", windowControl, "ZO_DefaultBackdrop")
    searchBg:SetDimensions(SEARCH_WIDTH, TITLE_HEIGHT)
    searchBg:ClearAnchors()
    searchBg:SetAnchor(TOPRIGHT, windowControl, TOPRIGHT, -PADDING, filterToolbarY)
    -- Clicking anywhere on the backdrop (incl. its padding) focuses the editbox,
    -- so the hit target is the whole field, not just the text glyphs.
    searchBg:SetMouseEnabled(true)
    searchBg:SetHandler("OnMouseUp", function()
        if searchBox then
            searchBox:TakeFocus()
        end
    end)

    -- Faint placeholder shown only while the box is empty. Created BEFORE the
    -- editbox (so the editbox is the top-most sibling for mouse hits) and with
    -- mouse explicitly disabled so it never intercepts clicks meant for the box.
    searchHint = WINDOW_MANAGER:CreateControl(addon.name .. "_DetailSearchHint", searchBg, CT_LABEL)
    searchHint:SetFont(FONT.body)
    searchHint:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    searchHint:SetAnchor(LEFT, searchBg, LEFT, 8, 0)
    searchHint:SetMouseEnabled(false)
    searchHint:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_SEARCH_HINT)))

    searchBox = WINDOW_MANAGER:CreateControl(addon.name .. "_DetailSearch", searchBg, CT_EDITBOX)
    searchBox:SetAnchor(TOPLEFT, searchBg, TOPLEFT, 8, 2)
    searchBox:SetAnchor(BOTTOMRIGHT, searchBg, BOTTOMRIGHT, -8, -2)
    searchBox:SetFont(FONT.body)
    searchBox:SetMaxInputChars(50)
    searchBox:SetMouseEnabled(true)
    searchBox:SetText("")
    -- Clicking the box should focus it for typing. Some custom (non-dialog)
    -- editboxes do not auto-focus reliably, so take focus explicitly.
    searchBox:SetHandler("OnMouseUp", function(self)
        self:TakeFocus()
    end)

    searchBox:SetHandler("OnTextChanged", function()
        -- suppressSearchEvent guards against the SetText we issue on a category
        -- open (which would otherwise re-trigger this and clobber the view).
        if not suppressSearchEvent then
            searchQuery = searchBox:GetText() or ""
            -- Debounce the (whole-bag) rebuild so a fast typist's burst collapses
            -- into one Populate instead of one per keystroke; see QueueSearch.
            QueueSearch()
        end
        searchHint:SetHidden((searchBox:GetText() or "") ~= "")
        UpdatePriceFilterButtons()
    end)
    -- Escape clears the search and drops focus, returning to the category view.
    searchBox:SetHandler("OnEscape", function(self)
        self:SetText("")
        self:LoseFocus()
    end)

    searchClearButton = WINDOW_MANAGER:CreateControlFromVirtual(
        addon.name .. "_DetailSearchClear", windowControl, "ZO_CloseButton")
    searchClearButton:SetDimensions(20, 20)
    searchClearButton:SetAnchor(RIGHT, searchBg, LEFT, -4, 0)
    searchClearButton:SetHandler("OnClicked", function()
        suppressSearchEvent = true
        searchBox:SetText("")
        suppressSearchEvent = false
        searchQuery = ""
        searchHint:SetHidden(false)
        UpdatePriceFilterButtons()
        Populate()
        searchBox:TakeFocus()
    end)
    searchClearButton:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -2, TOP)
        UI.TipLine(InformationTooltip, GetString(SI_BMW_DETAIL_SEARCH_CLEAR_TOOLTIP))
    end)
    searchClearButton:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
    searchClearButton:SetHidden(true)

    -- Snapshot buttons on the left of the toolbar row. "Remember" freezes the
    -- current composition; "Changes" switches to the diff view. ZO_DefaultButton's
    -- virtual height (~30) is taller than the 26px row, so force the height. Each
    -- gets a title+body hover tooltip (the headerCum idiom) since the
    -- manual-snapshot model is not self-evident.
    local BUTTON_WIDTH = 100
    local GROUP_LABEL_WIDTH = 62
    local GROUP_LABEL_GAP = 8

    local snapshotGroupLabel = WINDOW_MANAGER:CreateControl(
        addon.name .. "_DetailSnapshotGroupLabel", windowControl, CT_LABEL)
    snapshotGroupLabel:SetFont(FONT.small)
    snapshotGroupLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    snapshotGroupLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    snapshotGroupLabel:SetDimensions(GROUP_LABEL_WIDTH, TITLE_HEIGHT)
    snapshotGroupLabel:SetAnchor(TOPLEFT, windowControl, TOPLEFT, PADDING, snapshotToolbarY)
    snapshotGroupLabel:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_GROUP_SNAPSHOT)))

    local function WireButtonTooltip(button, titleId, bodyId)
        button:SetHandler("OnMouseEnter", function(self)
            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -2, TOP)
            UI.TipTitle(InformationTooltip, GetString(titleId))
            UI.TipLine(InformationTooltip, GetString(bodyId))
        end)
        button:SetHandler("OnMouseExit", function()
            ClearTooltip(InformationTooltip)
        end)
    end

    local rememberButton = WINDOW_MANAGER:CreateControlFromVirtual(
        addon.name .. "_DetailRemember", windowControl, "ZO_DefaultButton")
    rememberButton:SetDimensions(BUTTON_WIDTH, TITLE_HEIGHT)
    rememberButton:SetAnchor(LEFT, snapshotGroupLabel, RIGHT, GROUP_LABEL_GAP, 0)
    rememberButton:SetText(GetString(SI_BMW_DETAIL_BTN_REMEMBER))
    rememberButton:SetHandler("OnClicked", function()
        local snapshot = addon.Valuation.CaptureSnapshot()
        -- Confirm the save in chat with what was captured, so the action has
        -- visible feedback even when the diff view isn't open to show the reset.
        if snapshot then
            private.ChatInfo(SI_BMW_MSG_SNAPSHOT_SAVED, snapshot.slots or 0,
                FormatGold(snapshot.gold or 0))
        end
        UpdateSnapshotStatus()
        -- If the diff view is open, refresh it so it reflects the new baseline
        -- (it will now read "nothing changed"); otherwise just leave it.
        if viewMode == "diff" then
            Populate()
        end
    end)
    WireButtonTooltip(rememberButton, SI_BMW_DETAIL_BTN_REMEMBER_TOOLTIP_TITLE,
        SI_BMW_DETAIL_BTN_REMEMBER_TOOLTIP_BODY)

    changesButton = WINDOW_MANAGER:CreateControlFromVirtual(
        addon.name .. "_DetailChanges", windowControl, "ZO_DefaultButton")
    changesButton:SetDimensions(BUTTON_WIDTH, TITLE_HEIGHT)
    changesButton:SetAnchor(TOPLEFT, rememberButton, TOPRIGHT, 8, 0)
    changesButton:SetText(GetString(SI_BMW_DETAIL_BTN_CHANGES))
    -- This button is a toggle: in the material views it opens the diff ("Changes");
    -- in the diff view it returns to the material list ("Back"). The label is kept
    -- in step by UpdateChangesButton (called from each Show*). Its action and
    -- tooltip read viewMode at event time so the single bound handler covers both.
    changesButton:SetHandler("OnClicked", function()
        if viewMode == "diff" then
            DetailWindow.ShowMaterials()
        else
            DetailWindow.ShowDiff()
        end
    end)
    changesButton:SetHandler("OnMouseEnter", function(self)
        local titleId, bodyId
        if viewMode == "diff" then
            titleId, bodyId = SI_BMW_DETAIL_BTN_BACK_TOOLTIP_TITLE, SI_BMW_DETAIL_BTN_BACK_TOOLTIP_BODY
        else
            titleId, bodyId = SI_BMW_DETAIL_BTN_CHANGES_TOOLTIP_TITLE, SI_BMW_DETAIL_BTN_CHANGES_TOOLTIP_BODY
        end
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -2, TOP)
        UI.TipTitle(InformationTooltip, GetString(titleId))
        UI.TipLine(InformationTooltip, GetString(bodyId))
    end)
    changesButton:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    -- "Clear" forgets the saved snapshot. Sits after "Changes" on the toolbar.
    -- Because clearing is destructive and cannot be undone, it opens a confirmation
    -- dialog. When the diff view is open, a confirmed clear refreshes it into the
    -- "press Remember" empty state immediately.
    local clearButton = WINDOW_MANAGER:CreateControlFromVirtual(
        addon.name .. "_DetailClear", windowControl, "ZO_DefaultButton")
    clearButton:SetDimensions(BUTTON_WIDTH, TITLE_HEIGHT)
    clearButton:SetAnchor(TOPLEFT, changesButton, TOPRIGHT, 8, 0)
    clearButton:SetText(GetString(SI_BMW_DETAIL_BTN_CLEAR))
    clearButton:SetHandler("OnClicked", function()
        -- Destructive and not undoable, so confirm before clearing. The dialog's
        -- accept callback (registered below) does the actual clear + chat notice.
        ZO_Dialogs_ShowDialog(CLEAR_SNAPSHOT_DIALOG)
    end)
    WireButtonTooltip(clearButton, SI_BMW_DETAIL_BTN_CLEAR_TOOLTIP_TITLE,
        SI_BMW_DETAIL_BTN_CLEAR_TOOLTIP_BODY)

    -- Keep the automatic baseline visible beside its controls instead of making
    -- players infer it from a tooltip or from the Changes view.
    snapshotStatusLabel = WINDOW_MANAGER:CreateControl(
        addon.name .. "_DetailSnapshotStatus", windowControl, CT_LABEL)
    snapshotStatusLabel:SetFont(FONT.small)
    snapshotStatusLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    snapshotStatusLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    snapshotStatusLabel:SetMaxLineCount(1)
    snapshotStatusLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    snapshotStatusLabel:SetAnchor(LEFT, clearButton, RIGHT, 10, 0)
    snapshotStatusLabel:SetDimensions(WINDOW_WIDTH - (PADDING * 2 + GROUP_LABEL_WIDTH
        + GROUP_LABEL_GAP + BUTTON_WIDTH * 3 + 26), TITLE_HEIGHT)

    -- Price coverage filters live on their own row beside the search box. They
    -- filter the current category/search view and are hidden for the snapshot
    -- diff, where priced/unpriced has a different meaning.
    local filterGroupLabel = WINDOW_MANAGER:CreateControl(
        addon.name .. "_DetailFilterGroupLabel", windowControl, CT_LABEL)
    filterGroupLabel:SetFont(FONT.small)
    filterGroupLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    filterGroupLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    filterGroupLabel:SetDimensions(GROUP_LABEL_WIDTH, TITLE_HEIGHT)
    filterGroupLabel:SetAnchor(TOPLEFT, windowControl, TOPLEFT, PADDING, filterToolbarY)
    filterGroupLabel:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_GROUP_FILTER)))

    local FILTER_BUTTON_GAP = 4
    local filterDefinitions = {
        { key = "all", stringId = SI_BMW_DETAIL_FILTER_ALL, width = 44 },
        { key = "priced", stringId = SI_BMW_DETAIL_FILTER_PRICED, width = 68 },
        { key = "unpriced", stringId = SI_BMW_DETAIL_FILTER_UNPRICED, width = 84 },
    }
    local previousFilterButton = nil
    for i = 1, #filterDefinitions do
        local definition = filterDefinitions[i]
        local button = WINDOW_MANAGER:CreateControlFromVirtual(
            addon.name .. "_DetailFilter" .. definition.key, windowControl, "ZO_DefaultButton")
        button:SetDimensions(definition.width, TITLE_HEIGHT)
        if previousFilterButton then
            button:SetAnchor(TOPLEFT, previousFilterButton, TOPRIGHT, FILTER_BUTTON_GAP, 0)
        else
            button:SetAnchor(LEFT, filterGroupLabel, RIGHT, GROUP_LABEL_GAP, 0)
        end
        button:SetText(GetString(definition.stringId))
        button:SetHandler("OnClicked", function()
            if priceFilter ~= definition.key then
                priceFilter = definition.key
                UpdatePriceFilterButtons()
                Populate()
            end
        end)
        filterButtons[definition.key] = button
        previousFilterButton = button
    end

    -- The outline that marks the active price filter. Built by the shared layer, so
    -- it is provably the same green as the header underline and the row hover wash,
    -- and its strength is a token rather than a number chosen here.
    selectedFilterFrame = UI.CreateSelectionFrame(
        addon.name .. "_DetailSelectedFilterFrame", windowControl)

    resetFiltersButton = WINDOW_MANAGER:CreateControlFromVirtual(
        addon.name .. "_DetailResetFilters", windowControl, "ZO_DefaultButton")
    resetFiltersButton:SetDimensions(70, TITLE_HEIGHT)
    resetFiltersButton:SetAnchor(TOPLEFT, previousFilterButton, TOPRIGHT, 8, 0)
    resetFiltersButton:SetText(GetString(SI_BMW_DETAIL_FILTER_RESET))
    resetFiltersButton:SetHandler("OnClicked", function()
        priceFilter = "all"
        suppressSearchEvent = true
        searchBox:SetText("")
        suppressSearchEvent = false
        searchQuery = ""
        searchHint:SetHidden(false)
        UpdatePriceFilterButtons()
        Populate()
    end)
    resetFiltersButton:SetHidden(true)

    -- Column headers, aligned to the same geometry as the XML row template. They
    -- sit below the toolbar row.
    local headerY = filterToolbarY + TITLE_HEIGHT + TOOLBAR_GAP

    headerChange = WINDOW_MANAGER:CreateControl(addon.name .. "_DetailHeaderChange", windowControl, CT_LABEL)
    headerChange:SetFont(FONT.small)
    headerChange:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    headerChange:SetDimensions(90, HEADER_HEIGHT)
    headerChange:SetAnchor(TOPRIGHT, windowControl, TOPRIGHT,
        -PADDING - 4 - ROW_ACTION_WIDTH, headerY)
    headerChange:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_COL_CHANGE)))

    -- Cumulative-share header. Unlike the others it is NOT a sort toggle (sorting
    -- by cumulative share would be identical to sorting by value), so it is a
    -- plain muted label and is skipped by WireHeaderSort/UpdateHeaders below.
    headerCum = WINDOW_MANAGER:CreateControl(addon.name .. "_DetailHeaderCum", windowControl, CT_LABEL)
    headerCum:SetFont(FONT.small)
    headerCum:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    headerCum:SetDimensions(70, HEADER_HEIGHT)
    headerCum:SetAnchor(TOPRIGHT, headerChange, TOPLEFT, -6, 0)
    headerCum:SetText(Colorize(COLOR_MUTED, CumulativeHeaderText()))

    -- The column abbreviation can't carry its full meaning, so a hover tooltip on
    -- the header spells it out: a title line, a divider, then the explanation --
    -- the shared title/body pair every other hover in the addon uses.
    -- InformationTooltip wraps a long line to its own width.
    headerCum:SetMouseEnabled(true)
    headerCum:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, TOP, 0, 4, BOTTOM)
        UI.TipTitle(InformationTooltip, GetString(SI_BMW_DETAIL_CUM_TOOLTIP_TITLE))
        UI.TipLine(InformationTooltip, GetString(SI_BMW_DETAIL_CUM_TOOLTIP_BODY))
    end)
    headerCum:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    headerValue = WINDOW_MANAGER:CreateControl(addon.name .. "_DetailHeaderValue", windowControl, CT_LABEL)
    headerValue:SetFont(FONT.small)
    headerValue:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    headerValue:SetDimensions(150, HEADER_HEIGHT)
    headerValue:SetAnchor(TOPRIGHT, headerCum, TOPLEFT, -6, 0)
    headerValue:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_COL_VALUE)))

    headerQty = WINDOW_MANAGER:CreateControl(addon.name .. "_DetailHeaderQty", windowControl, CT_LABEL)
    headerQty:SetFont(FONT.small)
    headerQty:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    headerQty:SetDimensions(70, HEADER_HEIGHT)
    headerQty:SetAnchor(TOPRIGHT, headerValue, TOPLEFT, -6, 0)
    headerQty:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_COL_QTY)))

    headerName = WINDOW_MANAGER:CreateControl(addon.name .. "_DetailHeaderName", windowControl, CT_LABEL)
    headerName:SetFont(FONT.small)
    headerName:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    headerName:SetAnchor(TOPLEFT, windowControl, TOPLEFT, PADDING + 2, headerY)
    headerName:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_COL_NAME)))

    -- Make each header a sort toggle. Clicking the active column flips its
    -- direction; clicking another switches to it with a sensible default (A->Z
    -- for the name, biggest-first for the numeric columns - that is what a
    -- player scanning for "what to sell" wants). Numeric columns default to
    -- descending; the name column to ascending. The headers are plain labels, so
    -- enable mouse and bind OnMouseUp directly; the existing right-aligned
    -- geometry already gives each a generous hit box.
    local function WireHeaderSort(headerControl, key, defaultAsc)
        headerControl:SetMouseEnabled(true)
        headerControl:SetHandler("OnMouseUp", function(_, button, upInside)
            -- Headers do not sort in diff mode (the order is fixed); ignore clicks.
            if viewMode == "diff" then
                return
            end
            if not upInside or button ~= MOUSE_BUTTON_INDEX_LEFT then
                return
            end
            if sortKey == key then
                sortAsc = not sortAsc
            else
                sortKey = key
                sortAsc = defaultAsc
            end
            UpdateHeaders()
            Populate()
        end)
        headerControl:SetHandler("OnMouseEnter", function(self)
            -- No brighten-on-hover affordance when the header isn't clickable.
            if viewMode == "diff" then
                return
            end
            -- Hovering promotes the header from the secondary reading tone to the
            -- primary one. Both come from the palette, so the affordance is a step
            -- along the addon's own scale rather than a jump to raw white.
            local r, g, b = UI.Tone("name")
            self:SetColor(r, g, b, 1)
        end)
        headerControl:SetHandler("OnMouseExit", function()
            UpdateHeaders()
        end)
    end
    WireHeaderSort(headerName, "name", true)
    WireHeaderSort(headerQty, "qty", false)
    WireHeaderSort(headerValue, "value", false)
    WireHeaderSort(headerChange, "change", false)
    UpdateColumnLayout()
    UpdateHeaders()

    -- Divider under the headers, at the shared structural weight: it closes the
    -- header block off from the table, the same job the rule under the summary
    -- panel's identity block does.
    local dividerY = headerY + HEADER_HEIGHT
    divider = UI.CreateRule(addon.name .. "_DetailDivider", windowControl, innerWidth, "strong")
    divider:SetAnchor(TOPLEFT, windowControl, TOPLEFT, PADDING, dividerY)

    -- Scroll list, instantiated from the XML virtual so its rows can be
    -- recycled. Sized to LIST_MAX_ROWS; longer categories scroll.
    local listY = dividerY + DIVIDER_GAP
    listControl = WINDOW_MANAGER:CreateControlFromVirtual(
        addon.name .. "_DetailListControl", windowControl, "BureauOfMaterialWorth_DetailList")
    listControl:SetDimensions(innerWidth, ROW_HEIGHT * LIST_MAX_ROWS)
    listControl:SetAnchor(TOPLEFT, windowControl, TOPLEFT, PADDING, listY)

    ZO_ScrollList_Initialize(listControl)
    ZO_ScrollList_AddDataType(listControl, ROW_TYPE_ID,
        "BureauOfMaterialWorth_DetailRow", ROW_HEIGHT, SetupRow)

    emptyLabel = WINDOW_MANAGER:CreateControl(addon.name .. "_DetailEmpty", windowControl, CT_LABEL)
    emptyLabel:SetFont(FONT.body)
    emptyLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    emptyLabel:SetAnchor(TOPLEFT, listControl, TOPLEFT, 0, 0)
    emptyLabel:SetAnchor(TOPRIGHT, listControl, TOPRIGHT, 0, 0)
    emptyLabel:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_EMPTY)))
    emptyLabel:SetHidden(true)

    -- Summary line beneath the list, mirroring the main panel's footer so the two
    -- windows read as one family. A divider sets it off from the list; the label
    -- itself is filled by UpdateFooter for the active view (category/search count +
    -- value + bag share, or the diff's net movement). Right-aligned so the figure
    -- sits under the value columns.
    local footerDividerY = listY + ROW_HEIGHT * LIST_MAX_ROWS + DIVIDER_GAP
    -- The lighter of the two shared weights: the summary belongs to the table it
    -- totals, so this rule must not compete with the list above it -- exactly the
    -- distinction the summary panel's own footer rule makes.
    footerDivider = UI.CreateRule(addon.name .. "_DetailFooterDivider", windowControl,
        innerWidth, "soft")
    footerDivider:SetAnchor(TOPLEFT, windowControl, TOPLEFT, PADDING, footerDividerY)

    footerLabel = WINDOW_MANAGER:CreateControl(addon.name .. "_DetailFooter", windowControl, CT_LABEL)
    footerLabel:SetFont(FONT.small)
    footerLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    footerLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    footerLabel:SetDimensions(innerWidth, FOOTER_HEIGHT)
    footerLabel:SetAnchor(TOPLEFT, windowControl, TOPLEFT, PADDING, footerDividerY + DIVIDER_GAP)

    windowControl:SetHeight(footerDividerY + DIVIDER_GAP + FOOTER_HEIGHT + PADDING)
end

-- Fill the scroll list from a prebuilt materials array.
function FillList(materials)
    local dataList = ZO_ScrollList_GetDataList(listControl)
    ZO_ScrollList_Clear(listControl)

    for i = 1, #materials do
        dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(ROW_TYPE_ID, materials[i])
    end

    -- Commit is what triggers (re)layout of the visible rows; without it the
    -- list renders blank.
    ZO_ScrollList_Commit(listControl)

    emptyLabel:SetHidden(#materials > 0)
end

-- Filter an already-built material list by price coverage. Keep it separate from
-- Valuation so the getter remains useful to other consumers and the UI can layer
-- category, text search, and price filters in either order.
local function ApplyPriceFilter(materials)
    if priceFilter == "all" then
        return materials
    end

    local filtered = {}
    local wantPriced = priceFilter == "priced"
    for i = 1, #materials do
        if materials[i].priced == wantPriced then
            filtered[#filtered + 1] = materials[i]
        end
    end
    return filtered
end

-- Re-sort the material rows in place by the active column. The Valuation getters
-- already return rows sorted by name; this overrides that with the user's chosen
-- column. Name ties (and ties on any numeric column) fall back to name then
-- itemId so the order is stable across rebuilds and the value/change views read
-- alphabetically within equal figures.
--
-- Unpriced rows carry gold = 0 and growthPercent = nil. On the numeric columns
-- they always sink to the bottom regardless of direction, so toggling a column
-- never buries a real figure beneath the priceless ones.
local function SortMaterials(materials)
    -- Diff mode has a fixed order: biggest absolute gold movement first, so the
    -- materials that moved the most value sit on top. Secondary by absolute count
    -- delta so a large unpriced add/remove (no gold figure) still surfaces, then
    -- name/itemId for stability. The column headers do not sort in this mode.
    if viewMode == "diff" then
        tablesort(materials, function(a, b)
            local ag, bg = mathabs(a.goldDelta or 0), mathabs(b.goldDelta or 0)
            if ag ~= bg then
                return ag > bg
            end
            local ac, bc = mathabs(a.countDelta or 0), mathabs(b.countDelta or 0)
            if ac ~= bc then
                return ac > bc
            end
            if a.name ~= b.name then
                return a.name < b.name
            end
            return a.itemId < b.itemId
        end)
        return
    end

    if sortKey == "name" then
        tablesort(materials, function(a, b)
            if a.name ~= b.name then
                if sortAsc then return a.name < b.name end
                return a.name > b.name
            end
            return a.itemId < b.itemId
        end)
        return
    end

    tablesort(materials, function(a, b)
        local av, bv
        if sortKey == "qty" then
            av, bv = a.count or 0, b.count or 0
        elseif sortKey == "change" then
            -- Unpriced or no-baseline rows have no comparable change; treat as
            -- the lowest so they sink. nil < any real percentage.
            av = (a.priced and not a.isNew) and a.growthPercent or nil
            bv = (b.priced and not b.isNew) and b.growthPercent or nil
        else  -- "value"
            av, bv = a.gold or 0, b.gold or 0
        end

        -- Push nils to the bottom irrespective of sort direction.
        if av == nil or bv == nil then
            if av == bv then
                return a.name < b.name
            end
            return bv == nil
        end

        if av ~= bv then
            if sortAsc then return av < bv end
            return av > bv
        end
        -- Stable tie-break: alphabetical, then itemId.
        if a.name ~= b.name then
            return a.name < b.name
        end
        return a.itemId < b.itemId
    end)
end

-- Assign each row its cumulative share (percent) of the list's total value.
-- Deliberately decoupled from the active sort: accumulation ALWAYS proceeds from
-- the most valuable material downward, so a row's figure is a stable property -
-- "this material plus everything worth more is N% of the list's value" - that
-- does not change when the user re-sorts by name or quantity. On the default
-- value-descending view it then reads cleanly top-down 0->100. The useful signal
-- is where the top rows cross ~80% (the few stacks holding most of the worth),
-- not the trailing 100%, which by definition lands on the cheapest priced row.
-- Rows with no value are left nil so they show a dash. A zero-value list leaves
-- every row nil.
-- The weight each row contributes to the cumulative-share total: its value in
-- the category/search view, or the magnitude of its gold movement in the diff
-- view. Reads only the file-level viewMode, so it is defined once here rather
-- than re-created on every AssignCumulativeShare call.
local function WeightOfRow(row)
    if viewMode == "diff" then
        return mathabs(row.goldDelta or 0)
    end
    return row.gold or 0
end

local function AssignCumulativeShare(materials)
    local weightOf = WeightOfRow

    local total = 0
    for i = 1, #materials do
        total = total + weightOf(materials[i])
    end

    if total <= 0 then
        for i = 1, #materials do
            materials[i].cumPercent = nil
        end
        return
    end

    -- Rank by descending weight, independent of how the list is displayed. The
    -- tie-break (name, then itemId) mirrors SortMaterials so equal-weight rows
    -- accumulate in a stable order. We sort an index list rather than the
    -- materials array so the caller's chosen display order is untouched.
    local order = {}
    for i = 1, #materials do
        order[i] = i
    end
    tablesort(order, function(ia, ib)
        local a, b = materials[ia], materials[ib]
        local av, bv = weightOf(a), weightOf(b)
        if av ~= bv then
            return av > bv
        end
        if a.name ~= b.name then
            return a.name < b.name
        end
        return a.itemId < b.itemId
    end)

    local running = 0
    for rank = 1, #order do
        local mat = materials[order[rank]]
        local weight = weightOf(mat)
        if weight > 0 then
            running = running + weight
            mat.cumPercent = zo_round(running / total * 100)
        else
            mat.cumPercent = nil
        end
    end
end

-- Fill the summary line beneath the list from the just-built materials array.
-- Mirrors the main panel's footer so the two windows read as one family.
--   category/search : "Materials: N · <total> · M% of bag" - the count, the summed
--                     value of the shown rows, and that value's share of the whole
--                     bag (omitted when the bag total is zero / unavailable).
--   diff            : "Net: <signed gold> · X up · Y down" - the net gold movement
--                     and how many materials rose vs fell.
-- Records the row count for the title's search counter as a side effect, so the
-- two always agree. An empty list shows a plain count (or net of zero) rather than
-- blanking, so the line never looks broken.
local function UpdateFooter(materials)
    currentResultCount = #materials

    if viewMode == "diff" then
        local net, up, down = 0, 0, 0
        for i = 1, #materials do
            local delta = materials[i].goldDelta or 0
            net = net + delta
            -- Count direction by the quantity move, not the gold figure, so an
            -- unpriced add/remove (goldDelta 0) is still tallied.
            if (materials[i].countDelta or 0) >= 0 then
                up = up + 1
            else
                down = down + 1
            end
        end

        local gain = net >= 0
        local color = gain and COLOR_GAIN or COLOR_LOSS
        local arrow = gain and ARROW_UP or ARROW_DOWN
        local netText = arrow .. " " .. Colorize(color,
            ZO_LocalizeDecimalNumber(zo_round(mathabs(net)))) .. " " .. GOLD_ICON
        local parts = {
            Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_FOOTER_NET)) .. " " .. netText,
            Colorize(COLOR_GAIN, stringformat(GetString(SI_BMW_DETAIL_FOOTER_GAINED), up)),
            Colorize(COLOR_LOSS, stringformat(GetString(SI_BMW_DETAIL_FOOTER_LOST), down)),
        }
        footerLabel:SetText(table.concat(parts, Colorize(COLOR_MUTED, "  ·  ")))
        return
    end

    -- Category / search view: count + summed value + share of the whole bag.
    local total = 0
    for i = 1, #materials do
        total = total + (materials[i].gold or 0)
    end

    local parts = {
        Colorize(COLOR_MUTED, stringformat(GetString(SI_BMW_DETAIL_FOOTER_COUNT), #materials)),
        FormatGold(total),
    }

    -- Net for the shown rows after the guild-store fees (1% + 7%): the take-home
    -- if all of this sold through a trader. Only when there's a value to net down.
    if total > 0 then
        parts[#parts + 1] = Colorize(COLOR_GAIN,
            stringformat(GetString(SI_BMW_DETAIL_FOOTER_NET_SOLD),
                ZO_LocalizeDecimalNumber(zo_round(private.NetAfterFees(total))))) .. " " .. GOLD_ICON
    end

    -- Share of the whole bag's value, when the grand total is known and non-zero.
    -- GetStatus returns the live grand total cheaply (no category rebuild).
    local grandGold = addon.Valuation.GetStatus()
    if grandGold and grandGold > 0 then
        local share = zo_round(total / grandGold * 100)
        parts[#parts + 1] = Colorize(COLOR_MUTED,
            stringformat(GetString(SI_BMW_DETAIL_FOOTER_SHARE), share))
    end

    footerLabel:SetText(table.concat(parts, Colorize(COLOR_MUTED, "  ·  ")))
end

-- Rebuild the scroll list for the current view. Four sources route through here:
-- the diff list (viewMode == "diff"), whole-bag search results (a query is
-- active), the current category, or the full Craft Bag coverage view. Centralized
-- so the search box, a category open, the diff buttons, coverage click, and live
-- refresh all share one path. Also sets the empty-state label to match the mode,
-- since FillList only toggles its
-- visibility, not its text.
function Populate()
    local materials
    if viewMode == "diff" then
        if diffSource == "snapshot" and not addon.Valuation.HasSnapshot() then
            -- No snapshot to diff against: show the "press Remember" prompt.
            emptyLabel:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_NO_SNAPSHOT)))
            FillList({})
            UpdateFooter({})
            UpdateTitle()
            UpdateContext()
            UpdateSnapshotStatus()
            return
        end
        if diffSource == "visit" then
            materials = addon.Valuation.GetLastVisitDiffMaterials()
            emptyLabel:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_VISIT_DIFF_EMPTY)))
        else
            materials = addon.Valuation.GetDiffMaterials()
            emptyLabel:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_DIFF_EMPTY)))
        end
    else
        if searchQuery ~= "" then
            materials = addon.Valuation.GetMaterialsMatching(searchQuery)
        elseif currentCategoryId then
            materials = addon.Valuation.GetCategoryMaterials(currentCategoryId)
        else
            materials = addon.Valuation.GetAllMaterials()
        end
        emptyLabel:SetText(Colorize(COLOR_MUTED, GetString(SI_BMW_DETAIL_EMPTY)))
    end

    if viewMode ~= "diff" then
        materials = ApplyPriceFilter(materials)
    end
    SortMaterials(materials)
    AssignCumulativeShare(materials)
    FillList(materials)
    UpdateFooter(materials)
    -- The title's search counter reflects what was just built, so refresh it here
    -- (after UpdateFooter set the count) rather than at each call site. This also
    -- keeps the live Refresh path's counter truthful as stock changes.
    UpdateTitle()
    UpdateContext()
    UpdateSnapshotStatus()
end

-- Keep the title in step with the view: the diff label while comparing, the
-- searched-across-bag label while a query is active, otherwise the category name.
function UpdateTitle()
    if viewMode == "diff" then
        if diffSource == "visit" then
            titleLabel:SetText(Colorize(COLOR_ACCENT, GetString(SI_BMW_DETAIL_VISIT_DIFF_TITLE)))
        else
            local info = addon.Valuation.GetSnapshotInfo()
            local whenText
            if info and info.t then
                whenText = FormatSnapshotAge(info.t)
            else
                whenText = GetString(SI_BMW_TIME_NEVER)
            end
            titleLabel:SetText(Colorize(COLOR_ACCENT,
                stringformat(GetString(SI_BMW_DETAIL_DIFF_TITLE), whenText)))
        end
    elseif searchQuery ~= "" then
        -- Search title carries the match count (set by UpdateFooter, which runs
        -- just before this in Populate) so the user sees how many rows matched.
        titleLabel:SetText(Colorize(COLOR_ACCENT,
            stringformat(GetString(SI_BMW_DETAIL_SEARCH_TITLE), currentResultCount)))
    elseif not currentCategoryId then
        titleLabel:SetText(Colorize(COLOR_ACCENT,
            stringformat(GetString(SI_BMW_DETAIL_FILTER_TITLE), currentResultCount)))
    else
        titleLabel:SetText(Colorize(COLOR_ACCENT,
            stringformat(GetString(SI_BMW_DETAIL_TITLE), currentCategoryName or "")))
    end
end

-- Render the scope line directly below the title. It deliberately describes the
-- displayed rows after filters are applied, so the count always matches the list
-- rather than the broader category or search before narrowing.
function UpdateContext()
    if viewMode == "diff" then
        if diffSource == "visit" then
            local details = addon.Valuation.GetLastVisitDeltaDetails()
            local function SignedAmount(value)
                local sign = value >= 0 and "+" or "-"
                return sign .. FormatGold(mathabs(value))
            end
            contextLabel:SetText(Colorize(COLOR_MUTED, stringformat(
                GetString(SI_BMW_DETAIL_CONTEXT_VISIT_DIFF),
                SignedAmount(details and details.quantityGold or 0),
                SignedAmount(details and details.priceGold or 0))))
        else
            local info = addon.Valuation.GetSnapshotInfo()
            local whenText = info and info.t and FormatSnapshotAge(info.t) or GetString(SI_BMW_TIME_NEVER)
            contextLabel:SetText(Colorize(COLOR_MUTED,
                stringformat(GetString(SI_BMW_DETAIL_CONTEXT_DIFF), whenText)))
        end
        return
    end

    local filterId = SI_BMW_DETAIL_CONTEXT_FILTER_ALL
    if priceFilter == "priced" then
        filterId = SI_BMW_DETAIL_FILTER_PRICED
    elseif priceFilter == "unpriced" then
        filterId = SI_BMW_DETAIL_FILTER_UNPRICED
    end
    local filterText = GetString(filterId)

    if searchQuery ~= "" then
        contextLabel:SetText(Colorize(COLOR_MUTED,
            stringformat(GetString(SI_BMW_DETAIL_CONTEXT_SEARCH), searchQuery,
                currentResultCount, filterText)))
    elseif currentCategoryId then
        contextLabel:SetText(Colorize(COLOR_MUTED,
            stringformat(GetString(SI_BMW_DETAIL_CONTEXT_CATEGORY), currentCategoryName or "",
                currentResultCount, filterText)))
    else
        contextLabel:SetText(Colorize(COLOR_MUTED,
            stringformat(GetString(SI_BMW_DETAIL_CONTEXT_BAG), currentResultCount, filterText)))
    end
end

-- A baseline is normally created automatically on the first non-empty Craft
-- Bag open. Its age makes that ready-to-use comparison point visible at all
-- times, including after a manual Remember replacement.
UpdateSnapshotStatus = function()
    if not snapshotStatusLabel then
        return
    end

    local info = addon.Valuation.GetSnapshotInfo()
    if info and info.t then
        snapshotStatusLabel:SetText(Colorize(COLOR_MUTED, stringformat(
            GetString(SI_BMW_DETAIL_SNAPSHOT_READY), FormatSnapshotAge(info.t))))
    else
        snapshotStatusLabel:SetText(Colorize(COLOR_WARN,
            GetString(SI_BMW_DETAIL_SNAPSHOT_MISSING)))
    end
end

-- Re-label the four column headers, appending a sort arrow to the active one so
-- the player can see which column orders the list and in which direction. The
-- arrow textures match the price-change column's idiom (the UI font won't render
-- the Unicode triangles). Tone is driven by SetColor (not an inline |c code) so
-- the hover handlers can brighten a header without fighting an embedded color.
-- Called after any sort-state change and on each open.
function UpdateHeaders()
    -- Diff mode relabels the four columns to their delta/status meaning and shows
    -- no sort arrow (the order is fixed to abs-gold-desc). The name header keeps
    -- its label. Cum is repurposed to "Share".
    if viewMode == "diff" then
        headerName:SetText(GetString(SI_BMW_DETAIL_COL_NAME))
        headerQty:SetText(GetString(SI_BMW_DETAIL_COL_QTY_DELTA))
        headerValue:SetText(GetString(SI_BMW_DETAIL_COL_VALUE_DELTA))
        headerCum:SetText(GetString(SI_BMW_DETAIL_COL_SHARE))
        headerChange:SetText(GetString(SI_BMW_DETAIL_COL_STATUS))
        headerName:SetColor(HEADER_MUTED_R, HEADER_MUTED_G, HEADER_MUTED_B, 1)
        headerQty:SetColor(HEADER_MUTED_R, HEADER_MUTED_G, HEADER_MUTED_B, 1)
        headerValue:SetColor(HEADER_MUTED_R, HEADER_MUTED_G, HEADER_MUTED_B, 1)
        headerCum:SetColor(HEADER_MUTED_R, HEADER_MUTED_G, HEADER_MUTED_B, 1)
        headerChange:SetColor(HEADER_MUTED_R, HEADER_MUTED_G, HEADER_MUTED_B, 1)
        return
    end

    local arrow = sortAsc and ARROW_UP or ARROW_DOWN
    local function apply(headerControl, stringId, key)
        local text = GetString(stringId)
        if sortKey == key then
            text = text .. " " .. arrow
        end
        headerControl:SetText(text)
        headerControl:SetColor(HEADER_MUTED_R, HEADER_MUTED_G, HEADER_MUTED_B, 1)
    end
    apply(headerName, SI_BMW_DETAIL_COL_NAME, "name")
    apply(headerQty, SI_BMW_DETAIL_COL_QTY, "qty")
    apply(headerValue, SI_BMW_DETAIL_COL_VALUE, "value")
    apply(headerChange, SI_BMW_DETAIL_COL_CHANGE, "change")
    -- The Cum header is non-sortable; restore its plain label (UpdateHeaders may
    -- be returning from diff mode, which overwrote it with "Share").
    headerCum:SetText(CumulativeHeaderText())
    headerCum:SetColor(HEADER_MUTED_R, HEADER_MUTED_G, HEADER_MUTED_B, 1)
end

-- Re-anchor the Value header around the visible columns and hide analytics-only
-- controls in the basic mode. Row controls receive the matching layout in
-- SetupRow during the refresh initiated by ApplyColumnMode.
UpdateColumnLayout = function()
    local useAnalytics = UsesAnalyticsColumns()

    headerCum:SetHidden(not useAnalytics)
    headerChange:SetHidden(not useAnalytics)
    headerValue:ClearAnchors()
    if useAnalytics then
        headerValue:SetAnchor(TOPRIGHT, headerCum, TOPLEFT, -6, 0)
    else
        -- Anchor to Change's right edge, which remains at the header row even
        -- while hidden. Anchoring directly to windowControl had reset Y to zero.
        headerValue:SetAnchor(TOPRIGHT, headerChange, TOPRIGHT, 0, 0)
    end
end

-- The active filter stays clickable, but a green frame makes selection explicit
-- without ESO's grey disabled treatment. In diff view filters are irrelevant, so
-- hide the controls instead of leaving inert UI.
UpdatePriceFilterButtons = function()
    local hide = viewMode == "diff"
    for key, button in pairs(filterButtons) do
        button:SetHidden(hide)
        button:SetEnabled(not hide)
    end

    if selectedFilterFrame then
        selectedFilterFrame:ClearAnchors()
        selectedFilterFrame:SetAnchorFill(filterButtons[priceFilter])
        selectedFilterFrame:SetHidden(hide)
    end
    if searchClearButton then
        searchClearButton:SetHidden(hide or searchQuery == "")
    end
    if resetFiltersButton then
        resetFiltersButton:SetHidden(hide or (priceFilter == "all" and searchQuery == ""))
    end
end

-- Keep the toggle button's label in step with the mode: "Back" while the diff is
-- shown, "Changes" otherwise. The action and tooltip read viewMode at event time
-- (see Initialize), so only the label needs refreshing here.
local function UpdateChangesButton()
    if not changesButton then
        return
    end
    if viewMode == "diff" then
        changesButton:SetText(GetString(SI_BMW_DETAIL_BTN_BACK))
    else
        changesButton:SetText(GetString(SI_BMW_DETAIL_BTN_CHANGES))
    end
end

function DetailWindow.Show(categoryId, categoryName)
    if not windowControl then
        return
    end

    viewMode = "category"
    currentCategoryId = categoryId
    currentCategoryName = categoryName
    priceFilter = "all"

    -- A fresh category open clears any prior search so the user sees the category
    -- they clicked, not stale search results.
    searchQuery = ""
    suppressSearchEvent = true
    searchBox:SetText("")
    suppressSearchEvent = false

    -- Start every open from the value-descending default - the "what to sell
    -- right now" order - regardless of how the previous view was sorted.
    sortKey = "value"
    sortAsc = false

    UpdateChangesButton()
    UpdateColumnLayout()
    UpdateHeaders()
    UpdatePriceFilterButtons()
    Populate()
    windowControl:SetHidden(false)
    windowControl:BringWindowToTop()
end

-- Return from the diff view to the material list, restoring the category that was
-- open before (remembered in currentCategoryId). Reached via the toolbar toggle,
-- which reads "Back" in diff mode. Leaves the window open; only the mode flips.
function DetailWindow.ShowMaterials()
    if not windowControl then
        return
    end

    viewMode = "category"
    diffSource = "snapshot"
    searchQuery = ""
    suppressSearchEvent = true
    searchBox:SetText("")
    suppressSearchEvent = false

    -- Back to the default value-descending order, matching a fresh category open.
    sortKey = "value"
    sortAsc = false

    UpdateChangesButton()
    UpdateColumnLayout()
    UpdateHeaders()
    UpdatePriceFilterButtons()
    Populate()
end

-- Switch the window to the snapshot-diff view. Reachable from the "Changes"
-- button; when no snapshot exists Populate shows the "press Remember" prompt
-- rather than a list, so this is always safe to call. Reuses whatever category
-- context is loaded so leaving the diff (the "Back" toggle) restores it.
function DetailWindow.ShowDiff()
    if not windowControl then
        return
    end

    viewMode = "diff"
    diffSource = "snapshot"
    -- The diff spans the whole bag, so any active search is irrelevant here.
    searchQuery = ""
    suppressSearchEvent = true
    searchBox:SetText("")
    suppressSearchEvent = false

    UpdateChangesButton()
    UpdateColumnLayout()
    UpdateHeaders()
    UpdatePriceFilterButtons()
    Populate()
    windowControl:SetHidden(false)
    windowControl:BringWindowToTop()
end

-- Open the same delta table for the material movement behind the latest
-- visit/session footer delta. The price portion remains visible in its context
-- line because it can affect unchanged materials and has no per-row quantity.
function DetailWindow.ShowVisitDiff()
    if not windowControl or not addon.Valuation.GetLastVisitDeltaDetails() then
        return
    end

    viewMode = "diff"
    diffSource = "visit"
    searchQuery = ""
    suppressSearchEvent = true
    searchBox:SetText("")
    suppressSearchEvent = false

    UpdateChangesButton()
    UpdateColumnLayout()
    UpdateHeaders()
    UpdatePriceFilterButtons()
    Populate()
    windowControl:SetHidden(false)
    windowControl:BringWindowToTop()
end

-- Open the whole-bag material list pre-filtered to entries with no available
-- price. Called from the main window's Coverage footer so a warning leads
-- directly to the materials that need attention.
function DetailWindow.ShowUnpriced()
    if not windowControl then
        return
    end

    viewMode = "category"
    currentCategoryId = nil
    currentCategoryName = nil
    priceFilter = "unpriced"
    searchQuery = ""
    suppressSearchEvent = true
    searchBox:SetText("")
    suppressSearchEvent = false
    sortKey = "value"
    sortAsc = false

    UpdateChangesButton()
    UpdateColumnLayout()
    UpdateHeaders()
    UpdatePriceFilterButtons()
    Populate()
    windowControl:SetHidden(false)
    windowControl:BringWindowToTop()
end

function DetailWindow.Hide()
    -- Cancel a pending search rebuild: a keystroke followed by a quick close would
    -- otherwise fire Populate() (a full scroll-list rebuild + sorts) against a
    -- hidden window ~SEARCH_DEBOUNCE_MS later, wasted work with nothing on screen.
    EVENT_MANAGER:UnregisterForUpdate(SEARCH_TIMER_NAME)
    if windowControl then
        windowControl:SetHidden(true)
    end
end

-- Re-render the current view in place. Called from Valuation's coalesced refresh
-- after a slot change (e.g. a withdrawal shrank a stack) so the Qty/Value columns
-- stay truthful, and respects an active search. A no-op when the window is hidden.
function DetailWindow.Refresh()
    if not windowControl or windowControl:IsHidden() then
        return
    end
    Populate()
end

-- Apply the persisted detail-column mode immediately from the settings panel.
-- When the price-change column disappears, do not leave the user in an invisible
-- sort state; return to the practical value-descending default instead.
function DetailWindow.ApplyColumnMode()
    if not windowControl then
        return
    end
    if not UsesAnalyticsColumns() and sortKey == "change" then
        sortKey = "value"
        sortAsc = false
    end
    UpdateColumnLayout()
    UpdateHeaders()
    DetailWindow.Refresh()
end

-- The top-level control, exposed so the withdraw popup/queue can anchor to it
-- (centered popup, queue magnetized to its right edge) rather than scattering
-- floating windows. Returns nil before Initialize.
function DetailWindow.GetWindowControl()
    return windowControl
end

-- Hide the detail window when the craft bag closes, so it doesn't linger over
-- the rest of the UI with stale data. Called from the fragment wiring.
function DetailWindow.OnCraftBagHidden()
    DetailWindow.Hide()
end
