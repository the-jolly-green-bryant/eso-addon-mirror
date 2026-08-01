-- =============================================================================
-- VicsUnfinishedBusiness.lua
-- Shows zone stories that have not been completed on ANY character.
--   • Never started  → white
--   • In progress    → yellow, shows which character(s) started it
--   • Completed on any character → hidden entirely
-- Toggle with /vub | Reset with /vub reset
-- Ref: https://wiki.esoui.com/API
-- =============================================================================

local ADDON_NAME    = "VicsUnfinishedBusiness"
local ADDON_VERSION = "1.1.5"
local UB            = {}

-- ---------------------------------------------------------------------------
-- Layout
-- ---------------------------------------------------------------------------
local PAD    = 10
local ROW_H  = 22
local WIN_W  = 520
local WIN_H  = 500
local TITLE_H = 28
local LIST_Y  = TITLE_H + ROW_H + 10   -- room for tab-style section headers

-- ---------------------------------------------------------------------------
-- Colours
-- ---------------------------------------------------------------------------
local CLR = {
    title      = { 0.95, 0.82, 0.40, 1 },
    white      = { 1.00, 1.00, 1.00, 1 },
    inprogress = { 1.00, 0.80, 0.20, 1 },  -- yellow for in-progress
    charname   = { 0.55, 0.85, 1.00, 1 },  -- light blue for character names
    section    = { 0.70, 0.70, 0.70, 1 },  -- section header
    zero       = { 0.40, 0.40, 0.40, 1 },  -- dim
    edge       = { 0.42, 0.36, 0.18, 1 },
    bg         = { 0.04, 0.04, 0.06, 0.90 },
    stripe     = { 1.00, 1.00, 1.00, 0.04 },
    close_btn  = { 0.90, 0.30, 0.30, 1 },
}

local wm = WINDOW_MANAGER

-- =============================================================================
-- Data collection
-- =============================================================================

local function CharKey()
    return GetUnitName("player") .. "@" .. GetDisplayName()
end

-- Iterates all zone story zones and records quest line complete/started state
-- for the current character.
-- API ref:
--   GetNextZoneStoryZoneId(lastZoneId:nilable)                                 → nextZoneId:nilable
--   GetZoneNameById(zoneId)                                                    → name
--   IsZoneStoryZoneAvailable(zoneId)                                           → bool
--   AreAllZoneStoryActivitiesCompleteForZoneCompletionType(zoneId, type)       → bool
--   GetNumCompletedZoneActivitiesForZoneCompletionType(zoneId, type)           → integer
--   GetNumZoneActivitiesForZoneCompletionType(zoneId, type)                    → integer
-- Note: IsZoneStoryComplete() = ALL zone activities done (skyshards, delves, etc.)
--       We want ZONE_COMPLETION_TYPE_PRIORITY_QUESTS = the main story quest line only.
local function CollectZoneData()
    local zones = {}

    -- Build a set of zoneIds already completed by any character
    -- so we can skip rescanning them entirely.
    local alreadyComplete = {}
    for _, charData in pairs(VicsUnfinishedBusinessData) do
        if type(charData) == "table" and charData.zones then
            for zoneId, zInfo in pairs(charData.zones) do
                if zInfo.complete then
                    alreadyComplete[zoneId] = true
                end
            end
        end
    end

    local zoneId = GetNextZoneStoryZoneId(nil)
    while zoneId do
        if IsZoneStoryZoneAvailable(zoneId) then
            local zoneKey = tostring(zoneId)
            if alreadyComplete[zoneKey] then
                -- Already confirmed complete by another character — preserve
                -- that record and skip the API calls entirely.
                zones[zoneKey] = { name = GetZoneNameById(zoneId), complete = true, started = true }
            else
                local name    = GetZoneNameById(zoneId)
                local total   = GetNumZoneActivitiesForZoneCompletionType(zoneId, ZONE_COMPLETION_TYPE_PRIORITY_QUESTS)
                local complete = false
                local started  = false
                if total and total > 0 then
                    complete = AreAllZoneStoryActivitiesCompleteForZoneCompletionType(zoneId, ZONE_COMPLETION_TYPE_PRIORITY_QUESTS)
                    local numDone = GetNumCompletedZoneActivitiesForZoneCompletionType(zoneId, ZONE_COMPLETION_TYPE_PRIORITY_QUESTS) or 0
                    started = (numDone > 0)
                    zones[zoneKey] = { name = name, complete = complete, started = started, numDone = numDone, total = total }
                else
                    zones[zoneKey] = { name = name, complete = false, started = false, numDone = 0, total = 0 }
                end
            end
        end
        zoneId = GetNextZoneStoryZoneId(zoneId)
    end
    return zones
end

local function SaveCurrentChar()
    local key = CharKey()
    VicsUnfinishedBusinessData[key] = {
        charName = GetUnitName("player"),
        zones    = CollectZoneData(),
    }
end

-- ---------------------------------------------------------------------------
-- Builds the merged account-wide zone report.
-- Returns two sorted lists:
--   inProgress  = { { zoneName, chars = "CharA, CharB" }, ... }
--   neverStarted = { zoneName, ... }
-- A zone only appears if NO character has completed it.
-- ---------------------------------------------------------------------------
local function BuildZoneReport()
    -- Merge all character data into per-zone buckets
    local zoneMap = {}  -- [zoneId] = { name, completedBy={}, startedBy={} }

    for _, charData in pairs(VicsUnfinishedBusinessData) do
        if type(charData) == "table" and charData.charName and charData.zones then
            for zoneId, zInfo in pairs(charData.zones) do
                if not zoneMap[zoneId] then
                    zoneMap[zoneId] = {
                        name        = zInfo.name or "?",
                        completedBy = {},
                        startedBy   = {},
                    }
                end
                if zInfo.complete then
                    table.insert(zoneMap[zoneId].completedBy, charData.charName)
                elseif zInfo.started then
                    table.insert(zoneMap[zoneId].startedBy, {
                        charName = charData.charName,
                        numDone  = zInfo.numDone or 0,
                        total    = zInfo.total   or 0,
                    })
                end
            end
        end
    end

    local inProgress      = {}
    local neverStarted    = {}
    local currentCharName = GetUnitName("player")
    local myInProgress    = {}

    for _, info in pairs(zoneMap) do
        if #info.completedBy == 0 then
            if #info.startedBy > 0 then
                -- Find the character with the most quests done (account-wide section)
                local bestChar  = info.startedBy[1].charName
                local bestDone  = info.startedBy[1].numDone
                local bestTotal = info.startedBy[1].total
                for i = 2, #info.startedBy do
                    if info.startedBy[i].numDone > bestDone then
                        bestChar  = info.startedBy[i].charName
                        bestDone  = info.startedBy[i].numDone
                        bestTotal = info.startedBy[i].total
                    end
                end
                table.insert(inProgress, {
                    zoneName = info.name,
                    charName = bestChar,
                    numDone  = bestDone,
                    total    = bestTotal,
                })
            else
                table.insert(neverStarted, { zoneName = info.name })
            end
        end
    end

    -- Current character's personal in-progress zones
    local myKey = CharKey()
    local myData = VicsUnfinishedBusinessData[myKey]
    if myData and myData.zones then
        for _, zInfo in pairs(myData.zones) do
            if zInfo.started and not zInfo.complete then
                table.insert(myInProgress, {
                    zoneName = zInfo.name,
                    numDone  = zInfo.numDone or 0,
                    total    = zInfo.total   or 0,
                })
            end
        end
    end
    -- Sort by most progress first
    table.sort(myInProgress, function(a, b)
        if a.numDone == b.numDone then
            return a.zoneName < b.zoneName
        end
        return a.numDone > b.numDone
    end)

    table.sort(inProgress,   function(a, b) return a.zoneName < b.zoneName end)
    table.sort(neverStarted, function(a, b) return a.zoneName < b.zoneName end)

    return inProgress, neverStarted, myInProgress, currentCharName
end

-- =============================================================================
-- UI helpers
-- =============================================================================

local function MkLabel(parent, text, x, y, w, h, font, align, clr)
    local lbl = wm:CreateControl(nil, parent, CT_LABEL)
    lbl:SetDimensions(w, h)
    lbl:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    lbl:SetText(tostring(text))
    lbl:SetFont(font or "ZoFontGame")
    lbl:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
    if clr then lbl:SetColor(clr[1], clr[2], clr[3], clr[4] or 1) end
    return lbl
end

local function MkDivider(parent, y, alpha)
    local d = wm:CreateControl(nil, parent, CT_TEXTURE)
    d:SetDimensions(WIN_W - PAD * 2, 1)
    d:SetAnchor(TOPLEFT, parent, TOPLEFT, PAD, y)
    d:SetColor(CLR.edge[1], CLR.edge[2], CLR.edge[3], alpha or 1)
end

-- =============================================================================
-- List renderer
-- =============================================================================

local function RefreshList()
    if not UB.scrollChild then return end

    for _, ctrl in ipairs(UB.rowControls or {}) do
        ctrl:SetHidden(true)
    end
    UB.rowControls = {}

    local inProgress, neverStarted, myInProgress, currentCharName = BuildZoneReport()
    local rowIdx = 0

    local function AddRow(text, clr, indent)
        local y = rowIdx * ROW_H
        -- Alternating stripe
        if rowIdx % 2 == 0 then
            local stripe = wm:CreateControl(nil, UB.scrollChild, CT_BACKDROP)
            stripe:SetDimensions(WIN_W - PAD * 2, ROW_H)
            stripe:SetAnchor(TOPLEFT, UB.scrollChild, TOPLEFT, 0, y)
            stripe:SetCenterColor(CLR.stripe[1], CLR.stripe[2], CLR.stripe[3], CLR.stripe[4])
            stripe:SetEdgeColor(0, 0, 0, 0)
            stripe:SetEdgeTexture("", 1, 1, 0, 0)
            table.insert(UB.rowControls, stripe)
        end
        local lbl = MkLabel(UB.scrollChild, text,
            indent or 0, y, WIN_W - PAD * 2, ROW_H,
            "ZoFontGame", TEXT_ALIGN_LEFT, clr)
        table.insert(UB.rowControls, lbl)
        rowIdx = rowIdx + 1
    end

    local function AddSectionHeader(text)
        local y = rowIdx * ROW_H
        local lbl = MkLabel(UB.scrollChild, text,
            0, y, WIN_W - PAD * 2, ROW_H,
            "ZoFontGameBold", TEXT_ALIGN_LEFT, CLR.section)
        table.insert(UB.rowControls, lbl)
        rowIdx = rowIdx + 1
    end

    -- In progress section
    if #inProgress > 0 then
        AddSectionHeader("In Progress (" .. #inProgress .. ")")
        for _, entry in ipairs(inProgress) do
            -- Zone name in yellow
            local y = rowIdx * ROW_H
            if rowIdx % 2 == 0 then
                local stripe = wm:CreateControl(nil, UB.scrollChild, CT_BACKDROP)
                stripe:SetDimensions(WIN_W - PAD * 2, ROW_H)
                stripe:SetAnchor(TOPLEFT, UB.scrollChild, TOPLEFT, 0, y)
                stripe:SetCenterColor(CLR.stripe[1], CLR.stripe[2], CLR.stripe[3], CLR.stripe[4])
                stripe:SetEdgeColor(0, 0, 0, 0)
                stripe:SetEdgeTexture("", 1, 1, 0, 0)
                table.insert(UB.rowControls, stripe)
            end
            local zoneLbl = MkLabel(UB.scrollChild, entry.zoneName,
                0, y, 260, ROW_H,
                "ZoFontGame", TEXT_ALIGN_LEFT, CLR.inprogress)
            table.insert(UB.rowControls, zoneLbl)
            -- Character name in blue with progress count to the right
            local charLbl = MkLabel(UB.scrollChild, entry.charName .. " (" .. entry.numDone .. "/" .. entry.total .. ")",
                265, y, WIN_W - PAD * 2 - 265, ROW_H,
                "ZoFontGameSmall", TEXT_ALIGN_LEFT, CLR.charname)
            table.insert(UB.rowControls, charLbl)
            rowIdx = rowIdx + 1
        end
    end

    -- Never started section
    if #neverStarted > 0 then
        if #inProgress > 0 then
            rowIdx = rowIdx + 1  -- spacer row
        end
        AddSectionHeader("Never Started (" .. #neverStarted .. ")")
        for _, entry in ipairs(neverStarted) do
            AddRow(entry.zoneName, CLR.inprogress, 0)
        end
    end

    if #inProgress == 0 and #neverStarted == 0 then
        AddRow("All zone stories complete! Log in on each character to populate data.", CLR.zero, 0)
    end

    -- Current character's personal in-progress section
    if #myInProgress > 0 then
        rowIdx = rowIdx + 1  -- spacer
        AddSectionHeader("Your In Progress - " .. currentCharName .. " (" .. #myInProgress .. ")")
        for _, entry in ipairs(myInProgress) do
            local y = rowIdx * ROW_H
            if rowIdx % 2 == 0 then
                local stripe = wm:CreateControl(nil, UB.scrollChild, CT_BACKDROP)
                stripe:SetDimensions(WIN_W - PAD * 2, ROW_H)
                stripe:SetAnchor(TOPLEFT, UB.scrollChild, TOPLEFT, 0, y)
                stripe:SetCenterColor(CLR.stripe[1], CLR.stripe[2], CLR.stripe[3], CLR.stripe[4])
                stripe:SetEdgeColor(0, 0, 0, 0)
                stripe:SetEdgeTexture("", 1, 1, 0, 0)
                table.insert(UB.rowControls, stripe)
            end
            local zoneLbl = MkLabel(UB.scrollChild, entry.zoneName,
                0, y, 360, ROW_H,
                "ZoFontGame", TEXT_ALIGN_LEFT, CLR.inprogress)
            table.insert(UB.rowControls, zoneLbl)
            local progLbl = MkLabel(UB.scrollChild,
                entry.numDone .. "/" .. entry.total,
                365, y, WIN_W - PAD * 2 - 365, ROW_H,
                "ZoFontGame", TEXT_ALIGN_LEFT, CLR.charname)
            table.insert(UB.rowControls, progLbl)
            rowIdx = rowIdx + 1
        end
    end

    -- Resize scroll child
    local contentH = math.max(rowIdx * ROW_H, ROW_H)
    UB.scrollChild:SetDimensions(WIN_W - PAD * 2, contentH + ROW_H * 2 + 8)

    -- Footer line 1: instructions + version
    local note = MkLabel(UB.scrollChild,
        "Log in on each character to update.  |cAAAAAA v" .. ADDON_VERSION .. "|r",
        0, contentH + 4, WIN_W - PAD * 2, ROW_H,
        "ZoFontGameSmall", TEXT_ALIGN_CENTER, { 0.5, 0.5, 0.5, 1 })
    table.insert(UB.rowControls, note)

    -- Footer line 2: comma list of all characters scanned so far
    local charNames = {}
    for _, charData in pairs(VicsUnfinishedBusinessData) do
        if type(charData) == "table" and charData.charName then
            table.insert(charNames, charData.charName)
        end
    end
    table.sort(charNames)
    local charLine = #charNames > 0
        and "Checked: " .. table.concat(charNames, ", ")
        or  "No characters scanned yet."
    local charNote = MkLabel(UB.scrollChild,
        charLine,
        0, contentH + 4 + ROW_H, WIN_W - PAD * 2, ROW_H,
        "ZoFontGameSmall", TEXT_ALIGN_CENTER, { 0.5, 0.5, 0.5, 1 })
    table.insert(UB.rowControls, charNote)
end

-- =============================================================================
-- Window creation
-- =============================================================================

local function CreateWindow()
    if UB.window then return end

    local win = wm:CreateTopLevelWindow("VicsUnfinishedBusinessWin")
    win:SetDimensions(WIN_W, WIN_H)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    win:SetMovable(true)
    win:SetMouseEnabled(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)

    -- Background
    local bg = wm:CreateControl(nil, win, CT_BACKDROP)
    bg:SetAnchorFill(win)
    bg:SetCenterColor(CLR.bg[1], CLR.bg[2], CLR.bg[3], CLR.bg[4])
    bg:SetEdgeColor(CLR.edge[1], CLR.edge[2], CLR.edge[3], 1)
    bg:SetEdgeTexture("", 1, 1, 2, 0)

    -- Title
    MkLabel(win, "Vic's Unfinished Business",
        PAD, 6, WIN_W - PAD * 2 - 100, 20,
        "ZoFontGameBold", TEXT_ALIGN_LEFT, CLR.title)

    -- Close button
    local closeBtn = wm:CreateControl("VicsUBCloseBtn", win, CT_BUTTON)
    closeBtn:SetDimensions(18, 18)
    closeBtn:SetAnchor(TOPRIGHT, win, TOPRIGHT, -PAD, 6)
    closeBtn:SetText("X")
    closeBtn:SetFont("ZoFontGame")
    closeBtn:SetNormalFontColor(CLR.close_btn[1], CLR.close_btn[2], CLR.close_btn[3], CLR.close_btn[4])
    closeBtn:SetHandler("OnClicked", function()
        SCENE_MANAGER:HideTopLevel(UB.window)
    end)

    -- Refresh button
    local refreshBtn = wm:CreateControl("VicsUBRefreshBtn", win, CT_BUTTON)
    refreshBtn:SetDimensions(60, 18)
    refreshBtn:SetAnchor(TOPRIGHT, win, TOPRIGHT, -PAD - 24, 6)
    refreshBtn:SetText("Refresh")
    refreshBtn:SetFont("ZoFontGame")
    refreshBtn:SetNormalFontColor(0.45, 0.85, 1.00, 1)
    refreshBtn:SetHandler("OnClicked", function()
        SaveCurrentChar()
        RefreshList()
    end)

    -- Divider under title
    MkDivider(win, TITLE_H)

    -- Column headers
    MkLabel(win, "Zone Story",
        PAD, TITLE_H + 4, 260, ROW_H,
        "ZoFontGameBold", TEXT_ALIGN_LEFT, CLR.section)
    MkLabel(win, "In Progress By",
        PAD + 265, TITLE_H + 4, WIN_W - PAD * 2 - 265, ROW_H,
        "ZoFontGameBold", TEXT_ALIGN_LEFT, CLR.section)

    MkDivider(win, TITLE_H + ROW_H + 6, 0.45)

    -- Scrollable list
    local listH = WIN_H - LIST_Y - PAD

    local scrollContainer = CreateControlFromVirtual(
        "VicsUBScrollContainer", win, "ZO_ScrollContainer")
    scrollContainer:SetDimensions(WIN_W - PAD * 2, listH)
    scrollContainer:SetAnchor(TOPLEFT, win, TOPLEFT, PAD, LIST_Y)

    local scrollChild = scrollContainer:GetNamedChild("ScrollChild")
    if scrollChild then
        scrollChild:SetResizeToFitDescendents(false)
    else
        scrollChild = wm:CreateControl("VicsUBScrollChild", scrollContainer, CT_CONTROL)
    end
    scrollChild:SetDimensions(WIN_W - PAD * 2, listH)

    UB.window      = win
    UB.scrollChild = scrollChild

    SCENE_MANAGER:RegisterTopLevel(win, false)

    win:SetHandler("OnShow", function()
        SaveCurrentChar()
        RefreshList()
    end)

end


local function ToggleWindow()
    if not UB.window then CreateWindow() end
    SCENE_MANAGER:ToggleTopLevel(UB.window)
end

-- =============================================================================
-- Events
-- =============================================================================

local function OnPlayerActivated()
    -- Zone story completion data isn't ready at EVENT_PLAYER_ACTIVATED.
    -- Delay to allow the zone story system to fully initialize.
    zo_callLater(function()
        SaveCurrentChar()
        if UB.window and not UB.window:IsHidden() then
            RefreshList()
        end
    end, 5000)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end


    -- Initialise saved vars
    if VicsUnfinishedBusinessData == nil then VicsUnfinishedBusinessData = {} end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    SLASH_COMMANDS["/vub"] = function(args)
        local arg = args and args:lower():match("^%s*(.-)%s*$") or ""
        if arg == "reset" then
            VicsUnfinishedBusinessData = {}
            d("[VicsUnfinishedBusiness] All data cleared.")
        elseif arg == "layers" then
            local num = GetNumActionLayers()
            d("[VUB Debug] Total action layers: " .. tostring(num))
            for i = 1, num do
                d("  ["..i.."] " .. tostring(GetActionLayerNameByIndex(i)))
            end
        elseif arg == "debug" then
            d("[VUB Debug] ZONE_COMPLETION_TYPE_PRIORITY_QUESTS=" .. tostring(ZONE_COMPLETION_TYPE_PRIORITY_QUESTS))
            local zoneId = GetNextZoneStoryZoneId(nil)
            local count, complete, started, neither = 0, 0, 0, 0
            while zoneId do
                if IsZoneStoryZoneAvailable(zoneId) then
                    local name     = GetZoneNameById(zoneId)
                    local total    = GetNumZoneActivitiesForZoneCompletionType(zoneId, ZONE_COMPLETION_TYPE_PRIORITY_QUESTS)
                    local numDone  = GetNumCompletedZoneActivitiesForZoneCompletionType(zoneId, ZONE_COMPLETION_TYPE_PRIORITY_QUESTS)
                    local allDone  = AreAllZoneStoryActivitiesCompleteForZoneCompletionType(zoneId, ZONE_COMPLETION_TYPE_PRIORITY_QUESTS)
                    d("  "..tostring(name).." quests="..tostring(numDone).."/"..tostring(total).." allDone="..tostring(allDone))
                    if allDone then complete = complete + 1
                    elseif numDone and numDone > 0 then started = started + 1
                    else neither = neither + 1 end
                    count = count + 1
                end
                zoneId = GetNextZoneStoryZoneId(zoneId)
            end
            d("[VUB Debug] Total="..count.." Complete="..complete.." InProgress="..started.." Untouched="..neither)
        else
            ToggleWindow()
        end
    end

    d("|cFFAA33Vic's Unfinished Business|r loaded — |cFFFFFF/vub|r to open.")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
