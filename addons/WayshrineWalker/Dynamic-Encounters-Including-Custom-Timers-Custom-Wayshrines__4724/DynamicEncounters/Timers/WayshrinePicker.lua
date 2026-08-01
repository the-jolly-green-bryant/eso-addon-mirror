--[[----------------------------------------------------------------------
    Dynamic Encounters : Wayshrine Picker
    Searchable scrollable wayshrine browser for the timer system.
    SHIFT+Right-click on a timer's wayshrine button opens this picker.
    Supports fuzzy search by zone name or wayshrine name.

    Design: manual scrollable list (no ZO_ScrollList dependency).
    Rows are pre-allocated and recycled. Mouse wheel to scroll.
----------------------------------------------------------------------]]--

DynamicEncounters.Timers = DynamicEncounters.Timers or {}
local T = DynamicEncounters.Timers
local HE = DynamicEncounters

-- Constants
local MAX_VISIBLE_ROWS = 14
local ROW_HEIGHT = 24
local PICKER_W   = 400
local PICKER_H   = 500

-- State
local picker       = nil      -- the TLW once created
local allEntries   = {}       -- cached flat list of wayshrines
local filteredData = {}       -- filtered subset based on search
local scrollOffset = 0        -- current scroll position (0-indexed)

-- -------------------------------------------------------------------
-- Levenshtein distance (for fuzzy matching of similar spellings)
-- -------------------------------------------------------------------
local function Levenshtein(a, b)
    if a == b then return 0 end
    if #a == 0 then return #b end
    if #b == 0 then return #a end

    local prev, curr = {}, {}
    for j = 0, #b do prev[j] = j end

    for i = 1, #a do
        curr[0] = i
        local ai = a:byte(i)
        for j = 1, #b do
            local cost = (ai == b:byte(j)) and 0 or 1
            curr[j] = math.min(
                curr[j - 1] + 1,
                prev[j]     + 1,
                prev[j - 1] + cost
            )
        end
        prev, curr = curr, prev
    end
    return prev[#b]
end

-- -------------------------------------------------------------------
-- Build a flat sorted list of all known wayshrines from the cache.
-- -------------------------------------------------------------------
local function BuildEntryList()
    if not T.wayshrinesByIndex then return {} end
    local list = {}
    for index, entry in pairs(T.wayshrinesByIndex) do
        if entry.known and entry.name and entry.name ~= "" then
            local zoneName = entry.zoneName
            if not zoneName and entry.zoneId and entry.zoneId > 0 then
                zoneName = GetZoneNameById(entry.zoneId)
            end
            zoneName = zoneName or "Unknown Zone"

            -- Build display text: "Zone Name: Wayshrine Name"
            local displayText
            if zoneName and zoneName ~= "" then
                displayText = zoneName .. ": " .. entry.name
            else
                displayText = entry.name
            end

            table.insert(list, {
                index       = index,
                name        = entry.name,
                zoneName    = zoneName,
                zoneId      = entry.zoneId,
                displayText = displayText,
            })
        end
    end
    -- Sort by zone first, then wayshrine name
    table.sort(list, function(a, b)
        if a.zoneName ~= b.zoneName then
            return (a.zoneName or "") < (b.zoneName or "")
        end
        return a.name < b.name
    end)
    return list
end

-- -------------------------------------------------------------------
-- Filter entries by search text.
-- Priority: exact substring match > multi-word match > fuzzy (Levenshtein)
-- -------------------------------------------------------------------
local function FilterEntries(entries, searchText)
    if not searchText or searchText:match("^%s*$") then
        return entries  -- no filter, show all
    end

    searchText = searchText:lower():gsub("^%s+", ""):gsub("%s+$", "")
    local exact, fuzzy = {}, {}

    for _, entry in ipairs(entries) do
        local nameLower = entry.name:lower()
        local zoneLower = (entry.zoneName or ""):lower()
        local fullLower = nameLower .. " " .. zoneLower

        -- Exact substring match (against name OR zone)
        if nameLower:find(searchText, 1, true) or zoneLower:find(searchText, 1, true) then
            table.insert(exact, entry)
        else
            -- Multi-word: all whitespace-separated terms must appear in name or zone
            local allWordsMatch = true
            for word in searchText:gmatch("%S+") do
                if not fullLower:find(word, 1, true) then
                    allWordsMatch = false
                    break
                end
            end
            if allWordsMatch then
                table.insert(exact, entry)
            else
                -- Fuzzy: Levenshtein distance within threshold
                local dist = Levenshtein(searchText, nameLower)
                local threshold = math.max(2, math.floor(#searchText * 0.3))
                if dist <= threshold then
                    table.insert(fuzzy, entry)
                end
            end
        end
    end

    -- Exact matches first, then fuzzy
    for _, entry in ipairs(fuzzy) do
        table.insert(exact, entry)
    end
    return exact
end

-- -------------------------------------------------------------------
-- Create the picker window (called once, reused afterwards)
-- -------------------------------------------------------------------
local function CreatePickerWindow()
    local tlw = CreateTopLevelWindow("DynamicEncountersWayshrinePicker")
    tlw:SetClampedToScreen(true)
    tlw:SetDimensions(PICKER_W, PICKER_H)
    tlw:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    tlw:SetHidden(true)
    tlw:SetDrawLayer(DL_OVERLAY)
    tlw:SetDrawTier(DT_HIGH)
    tlw:SetMouseEnabled(true)

    -- Window background
    tlw.bg = CreateControl("$(parent)Bg", tlw, CT_BACKDROP)
    tlw.bg:SetAnchorFill(tlw)
    tlw.bg:SetCenterColor(0.06, 0.07, 0.11, 0.96)
    tlw.bg:SetEdgeColor(0.30, 0.60, 0.85, 0.90)

    -- Title bar
    tlw.title = CreateControl("$(parent)Title", tlw, CT_LABEL)
    tlw.title:SetAnchor(TOPLEFT, tlw, TOPLEFT, 14, 8)
    tlw.title:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, -36, 8)
    tlw.title:SetHeight(22)
    tlw.title:SetFont("ZoFontWinH4")
    tlw.title:SetText("|c70CCFFSelect Wayshrine|r")
    tlw.title:SetColor(0.70, 0.85, 1.0)

    -- Close button (top-right X)
    tlw.closeBtn = CreateControl("$(parent)Close", tlw, CT_LABEL)
    local cb = tlw.closeBtn
    cb:SetDimensions(24, 24)
    cb:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, -8, 4)
    cb:SetFont("ZoFontGameLargeBold")
    cb:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    cb:SetText("X")
    cb:SetColor(0.50, 0.50, 0.50, 1)
    cb:SetMouseEnabled(true)
    cb:SetHandler("OnMouseUp", function(_, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            T.HideWayshrinePicker()
        end
    end)
    cb:SetHandler("OnMouseEnter", function(self)
        self:SetColor(1, 0.30, 0.30, 1)
    end)
    cb:SetHandler("OnMouseExit", function(self)
        self:SetColor(0.50, 0.50, 0.50, 1)
    end)

    -- Search box background
    local searchBg = CreateControl("$(parent)SearchBg", tlw, CT_BACKDROP)
    searchBg:SetAnchor(TOPLEFT, tlw, TOPLEFT, 10, 36)
    searchBg:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, -10, 36)
    searchBg:SetHeight(30)
    searchBg:SetCenterColor(0.10, 0.12, 0.16, 0.90)
    searchBg:SetEdgeColor(0.25, 0.50, 0.75, 0.60)

    -- Search edit box (on top of searchBg)
    tlw.searchBox = CreateControl("$(parent)Search", tlw, CT_EDITBOX)
    local sb = tlw.searchBox
    sb:SetAnchor(TOPLEFT, searchBg, TOPLEFT, 6, 4)
    sb:SetAnchor(BOTTOMRIGHT, searchBg, BOTTOMRIGHT, -6, -4)
    sb:SetFont("ZoFontGame")
    sb:SetMaxInputChars(40)
    sb:SetColor(1, 1, 1)
    sb:SetMouseEnabled(true)
    sb:SetHandler("OnTextChanged", function()
        PopulateList()
    end)
    sb:SetHandler("OnEscape", function()
        T.HideWayshrinePicker()
    end)
    sb:SetHandler("OnEnter", function()
        sb:TakeFocus()  -- keep focus so user can continue typing
    end)

    -- Result count / scroll info label
    tlw.countLabel = CreateControl("$(parent)Count", tlw, CT_LABEL)
    tlw.countLabel:SetAnchor(TOPLEFT, tlw, TOPLEFT, 12, 70)
    tlw.countLabel:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, -12, 70)
    tlw.countLabel:SetHeight(16)
    tlw.countLabel:SetFont("ZoFontGameSmall")
    tlw.countLabel:SetColor(0.55, 0.60, 0.65)
    tlw.countLabel:SetText("0 wayshrines")

    -- Scroll area background (ESO controls max 2 anchors)
    local scrollBg = CreateControl("$(parent)ScrollBg", tlw, CT_BACKDROP)
    scrollBg:SetAnchor(TOPLEFT, tlw, TOPLEFT, 8, 90)
    scrollBg:SetAnchor(BOTTOMRIGHT, tlw, BOTTOMRIGHT, -8, -8)
    scrollBg:SetCenterColor(0.04, 0.05, 0.08, 0.80)
    scrollBg:SetEdgeColor(0.20, 0.40, 0.60, 0.40)

    -- Rows container (clipped, sits on top of scrollBg)
    tlw.rowsContainer = CreateControl("$(parent)Rows", tlw, CT_CONTROL)
    local rc = tlw.rowsContainer
    rc:SetAnchor(TOPLEFT, scrollBg, TOPLEFT, 4, 4)
    rc:SetAnchor(BOTTOMRIGHT, scrollBg, BOTTOMRIGHT, -4, -4)
    rc:SetClampedToScreen(false)
    rc:SetMouseEnabled(true)
    rc:SetHandler("OnMouseWheel", function(_, delta)
        local maxOffset = math.max(0, #filteredData - MAX_VISIBLE_ROWS)
        scrollOffset = math.max(0, math.min(scrollOffset - delta, maxOffset))
        RefreshRows()
    end)

    -- Pre-allocate row controls (recycled)
    tlw.rows = {}
    for i = 1, MAX_VISIBLE_ROWS do
        local row = CreateControl("$(parent)Row" .. i, rc, CT_LABEL)
        row:SetAnchor(TOPLEFT, rc, TOPLEFT, 4, (i - 1) * ROW_HEIGHT)
        row:SetAnchor(TOPRIGHT, rc, TOPRIGHT, -4, (i - 1) * ROW_HEIGHT)
        row:SetHeight(ROW_HEIGHT)
        row:SetFont("ZoFontGameSmall")
        row:SetColor(1, 1, 1)
        row:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        row:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        row:SetMouseEnabled(true)
        row:SetHidden(true)

        -- Highlight on hover
        row:SetHandler("OnMouseEnter", function(self)
            self:SetColor(0.80, 0.90, 1.0)
        end)
        row:SetHandler("OnMouseExit", function(self)
            self:SetColor(1, 1, 1)
        end)

        -- Click to select
        row:SetHandler("OnMouseUp", function(_, button, upInside)
            if not upInside or button ~= MOUSE_BUTTON_INDEX_LEFT then return end
            local dataIndex = scrollOffset + i
            local data = filteredData[dataIndex]
            if data and tlw.callback then
                tlw.callback(data)
            end
            T.HideWayshrinePicker()
        end)

        tlw.rows[i] = row
    end

    return tlw
end

-- -------------------------------------------------------------------
-- Refresh visible rows from filteredData at current scrollOffset.
-- -------------------------------------------------------------------
function RefreshRows()
    if not picker then return end
    local total = #filteredData

    for i = 1, MAX_VISIBLE_ROWS do
        local dataIndex = scrollOffset + i
        local data = filteredData[dataIndex]
        local row = picker.rows[i]
        if data then
            row:SetText(data.displayText)
            row:SetHidden(false)
        else
            row:SetText("")
            row:SetHidden(true)
        end
    end

    -- Update info label
    if total == 0 then
        if #allEntries > 0 then
            picker.countLabel:SetText("No matches found — try a different search term")
        else
            picker.countLabel:SetText("No wayshrines discovered yet")
        end
    elseif total > MAX_VISIBLE_ROWS then
        picker.countLabel:SetText(string.format("Showing %d-%d of %d  (scroll with mouse wheel)",
            scrollOffset + 1,
            math.min(scrollOffset + MAX_VISIBLE_ROWS, total),
            total))
    else
        picker.countLabel:SetText(total .. " wayshrine" .. (total == 1 and "" or "s"))
    end
end

-- -------------------------------------------------------------------
-- Rebuild filteredData from allEntries + current search text, then refresh.
-- -------------------------------------------------------------------
function PopulateList()
    if not picker then return end
    local searchText = picker.searchBox:GetText()
    filteredData = FilterEntries(allEntries, searchText)
    scrollOffset = 0
    RefreshRows()
end

-- -------------------------------------------------------------------
-- Public API
-- -------------------------------------------------------------------
function T.ShowWayshrinePicker(callback)
    if not picker then
        picker = CreatePickerWindow()
    end

    -- The node cache (wayshrinesByIndex) is built once on
    -- EVENT_PLAYER_ACTIVATED and never changes mid-session, so we skip
    -- the expensive rebuild (~200 GetFastTravelNodeInfo calls) unless
    -- the cache is somehow empty.
    if not T.wayshrinesByIndex or not next(T.wayshrinesByIndex) then
        if T.BuildWayshrineCache then T.BuildWayshrineCache() end
    end

    -- Zone resolution is separate from cache building: it tags each
    -- cached node with its zoneId by iterating all maps. It self-guards
    -- via "if unresolved == 0 then return end", so on the second+ open
    -- it exits after one cheap loop. Must NOT be inside the cache-empty
    -- guard above, or zones are never resolved and all show "Unknown".
    -- Force fresh zone resolution on every picker open so zone names
    -- are always accurate, even if a previous resolution was incorrect.
    if T.ResolveNodeZones then T.ResolveNodeZones(true) end

    allEntries = BuildEntryList()
    picker.callback = callback

    -- Clear search
    picker.searchBox:SetText("")
    -- Explicitly populate — SetText("") on an already-empty box does NOT
    -- fire OnTextChanged, so the list would stay empty without this call.
    PopulateList()

    picker:SetHidden(false)
    picker.searchBox:TakeFocus()

    -- Register scene callback so picker hides in menus/inventory
    if not picker.sceneHooked then
        picker.sceneHooked = true
        local function HookScene(name)
            local scene = SCENE_MANAGER and SCENE_MANAGER:GetScene(name)
            if scene then
                scene:RegisterCallback("StateChange", function(oldState, newState)
                    if newState == SCENE_HIDDEN and picker and not picker:IsHidden() then
                        T.HideWayshrinePicker()
                    end
                end)
            end
        end
        HookScene("hud")
        HookScene("hudui")
    end
end

function T.HideWayshrinePicker()
    if not picker then return end
    picker.searchBox:LoseFocus()
    picker:SetHidden(true)
    picker.callback = nil
end

function T.ToggleWayshrinePicker(callback)
    if picker and not picker:IsHidden() then
        T.HideWayshrinePicker()
    else
        T.ShowWayshrinePicker(callback)
    end
end
