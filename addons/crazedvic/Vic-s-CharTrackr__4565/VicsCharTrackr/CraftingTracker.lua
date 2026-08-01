-- =============================================================================
-- CraftingTracker.lua
-- Tracks crafting skill points spent across all characters.
-- Each purchased passive rank in every crafting skill line = 1 skill point.
-- Toggle with /vct  |  Reset with /vct reset
-- =============================================================================

local ADDON_NAME = "VicsCharTrackr"
local ADDON_VERSION = "1.5.9"
local CT = {}

-- ---------------------------------------------------------------------------
-- Display order and short names for the seven crafting skill lines.
-- Names match those returned by ZO_SkillLineData:GetName() via SKILLS_DATA_MANAGER.
-- ---------------------------------------------------------------------------
local CRAFT_LINES = {
    { full = "Blacksmithing",    short = "Smith" },
    { full = "Clothing",         short = "Cloth" },
    { full = "Woodworking",      short = "Wood"  },
    { full = "Provisioning",     short = "Prov"  },
    { full = "Alchemy",          short = "Alch"  },
    { full = "Enchanting",       short = "Ench"  },
    { full = "Jewelry Crafting", short = "Jewel" },
}

-- Fast lookup: full name -> index in CRAFT_LINES
local CRAFT_LINE_INDEX = {}
for i, v in ipairs(CRAFT_LINES) do
    CRAFT_LINE_INDEX[v.full] = i
end

-- ---------------------------------------------------------------------------
-- Layout constants
-- ---------------------------------------------------------------------------
local PAD       = 10
local ROW_H     = 22
local ICON_W    = 20    -- class icon column
local C_CHAR    = 118   -- character name text width
local C_CRAFT   = 50    -- per-craft-line column width
local C_TOTAL   = 84    -- total column width (max value 350, needs 3 digits)
local WIN_W     = PAD + ICON_W + C_CHAR + (#CRAFT_LINES * C_CRAFT) + C_TOTAL + PAD + 14
local WIN_H     = 470
local TITLE_H   = 28
local HDR_Y     = TITLE_H + 4
local HDR_DIV_Y = HDR_Y + ROW_H + 3
local LIST_Y    = HDR_DIV_Y + 6

-- ---------------------------------------------------------------------------
-- Colours
-- ---------------------------------------------------------------------------
local CLR = {
    title     = { 0.95, 0.82, 0.40, 1 },
    header    = { 0.80, 0.70, 0.30, 1 },
    white     = { 1.00, 1.00, 1.00, 1 },
    maxed     = { 0.20, 1.00, 0.20, 1 },  -- bright green for level 50
    zero      = { 0.40, 0.40, 0.40, 1 },  -- dim for undiscovered/zero
    edge      = { 0.42, 0.36, 0.18, 1 },
    bg        = { 0.04, 0.04, 0.06, 0.90 },
    stripe    = { 1.00, 1.00, 1.00, 0.04 },
    close_btn = { 0.90, 0.30, 0.30, 1 },
}

local wm = WINDOW_MANAGER

-- =============================================================================
-- Data collection
-- =============================================================================

-- Returns the current character's key used in SavedVariables.
local function CharKey()
    return GetUnitName("player") .. "@" .. GetDisplayName()
end


-- Walks every tradeskill line for the active character and reads
-- the experience-based rank (0-50) via SKILLS_DATA_MANAGER.
-- NOTE: The correct ESO constant is SKILL_TYPE_TRADESKILL, not SKILL_TYPE_CRAFTING.
-- Ref: https://wiki.esoui.com/SkillLines
local function CollectCraftingData()
    local data = { lines = {}, total = 0 }

    local numLines = GetNumSkillLines(SKILL_TYPE_TRADESKILL)
    for li = 1, numLines do
        local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(SKILL_TYPE_TRADESKILL, li)
        if skillLineData and skillLineData:IsDiscovered() then
            local lineName = skillLineData:GetName()
            local lineRank = skillLineData:GetCurrentRank() or 0
            data.lines[lineName] = lineRank
            data.total = data.total + lineRank
        end
    end

    return data
end


-- Writes the current character's crafting snapshot to SavedVariables.
local function SaveCurrentChar()
    local key     = CharKey()
    local craft   = CollectCraftingData()
    VicsCharTrackrData[key] = {
        charName = GetUnitName("player"),
        account  = GetDisplayName(),
        classId  = GetUnitClassId("player"),
        lines    = craft.lines,
        total    = craft.total,
    }
end

-- Returns a list of all saved character records, sorted by total (desc).
local function GetSortedList()
    local list = {}
    for _, v in pairs(VicsCharTrackrData) do
        if type(v) == "table" and v.charName then
            table.insert(list, v)
        end
    end
    table.sort(list, function(a, b)
        return (a.total or 0) > (b.total or 0)
    end)
    return list
end

-- =============================================================================
-- UI helpers
-- =============================================================================

-- Returns the left X offset for column index:
--   0           → character name
--   1 .. N      → crafting line columns
--   N+1         → total column
local function ColX(idx)
    if idx == 0 then
        return PAD                                      -- icon starts here
    elseif idx == "name" then
        return PAD + ICON_W                             -- name text starts after icon
    elseif idx <= #CRAFT_LINES then
        return PAD + ICON_W + C_CHAR + (idx - 1) * C_CRAFT
    else
        return PAD + ICON_W + C_CHAR + #CRAFT_LINES * C_CRAFT
    end
end

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

-- Clears previous row controls then rebuilds from saved data.
local function RefreshList()
    if not CT.scrollChild then return end

    -- Hide/destroy old row controls
    for _, ctrl in ipairs(CT.rowControls or {}) do
        ctrl:SetHidden(true)
    end
    CT.rowControls = {}

    local charList = GetSortedList()

    for rowIdx, charData in ipairs(charList) do
        local y = (rowIdx - 1) * ROW_H

        -- Alternating row background stripe
        if rowIdx % 2 == 0 then
            local stripe = wm:CreateControl(nil, CT.scrollChild, CT_BACKDROP)
            stripe:SetDimensions(WIN_W - PAD * 2, ROW_H)
            stripe:SetAnchor(TOPLEFT, CT.scrollChild, TOPLEFT, 0, y)
            stripe:SetCenterColor(
                CLR.stripe[1], CLR.stripe[2], CLR.stripe[3], CLR.stripe[4])
            stripe:SetEdgeColor(0, 0, 0, 0)
            stripe:SetEdgeTexture("", 1, 1, 0, 0)
            table.insert(CT.rowControls, stripe)
        end

        -- Class icon texture
        local icon = wm:CreateControl(nil, CT.scrollChild, CT_TEXTURE)
        icon:SetDimensions(ICON_W - 2, ROW_H - 4)
        icon:SetAnchor(TOPLEFT, CT.scrollChild, TOPLEFT, ColX(0), y + 2)
        local classIcon = charData.classId and ZO_GetClassIcon and ZO_GetClassIcon(charData.classId)
        if classIcon and classIcon ~= "" then
            icon:SetTexture(classIcon)
        else
            icon:SetHidden(true)
        end
        table.insert(CT.rowControls, icon)

        -- Character name (white)
        local nameLabel = MkLabel(
            CT.scrollChild,
            charData.charName,
            ColX("name"), y, C_CHAR, ROW_H,
            "ZoFontGame", TEXT_ALIGN_LEFT, CLR.white)
        table.insert(CT.rowControls, nameLabel)

        -- Per-craft-line skill levels: green if maxed, dim if zero, white otherwise
        for ci, lineInfo in ipairs(CRAFT_LINES) do
            local sp  = charData.lines and charData.lines[lineInfo.full]
            local txt = sp and sp > 0 and sp or "-"
            local clr = (not sp or sp == 0) and CLR.zero
                        or (sp >= 50)            and CLR.maxed
                        or                           CLR.white
            local col = MkLabel(
                CT.scrollChild,
                txt,
                ColX(ci), y, C_CRAFT, ROW_H,
                "ZoFontGame", TEXT_ALIGN_CENTER, clr)
            table.insert(CT.rowControls, col)
        end

        -- Total (white, bold)
        local totalLabel = MkLabel(
            CT.scrollChild,
            charData.total or 0,
            ColX(#CRAFT_LINES + 1), y, C_TOTAL, ROW_H,
            "ZoFontGameBold", TEXT_ALIGN_CENTER, CLR.white)
        table.insert(CT.rowControls, totalLabel)
    end

    -- Resize scroll child to fit all rows
    local contentH = math.max(#charList * ROW_H, ROW_H)
    CT.scrollChild:SetDimensions(WIN_W - PAD * 2, contentH)

    -- Footer note
    local noteY = contentH + 4
    local note = MkLabel(
        CT.scrollChild,
        "Shows crafting experience level (0-50) per line. " ..
        "Log in on each character to update.  |cAAAAAA v" .. ADDON_VERSION .. "|r",
        0, noteY, WIN_W - PAD * 2, ROW_H * 2,
        "ZoFontGameSmall", TEXT_ALIGN_CENTER,
        { 0.5, 0.5, 0.5, 1 })
    table.insert(CT.rowControls, note)
end

-- =============================================================================
-- Window creation
-- =============================================================================

local function CreateWindow()
    if CT.window then return end

    -- ── Top-level window ────────────────────────────────────────────────────
    local win = wm:CreateTopLevelWindow("CraftingTrackerWin")
    win:SetDimensions(WIN_W, WIN_H)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    win:SetMovable(true)
    win:SetMouseEnabled(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)

    -- ── Background ──────────────────────────────────────────────────────────
    local bg = wm:CreateControl(nil, win, CT_BACKDROP)
    bg:SetAnchorFill(win)
    bg:SetCenterColor(CLR.bg[1], CLR.bg[2], CLR.bg[3], CLR.bg[4])
    bg:SetEdgeColor(CLR.edge[1], CLR.edge[2], CLR.edge[3], 1)
    bg:SetEdgeTexture("", 1, 1, 2, 0)

    -- ── Title ───────────────────────────────────────────────────────────────
    MkLabel(win, "Vic's CharTrackr",
        PAD, 6, WIN_W - PAD * 2 - 100, 20,
        "ZoFontGameBold", TEXT_ALIGN_LEFT, CLR.title)

    -- ── Close button ────────────────────────────────────────────────────────
    local closeBtn = wm:CreateControl("CraftingTrackerCloseBtn", win, CT_BUTTON)
    closeBtn:SetDimensions(18, 18)
    closeBtn:SetAnchor(TOPRIGHT, win, TOPRIGHT, -PAD, 6)
    closeBtn:SetText("X")
    closeBtn:SetFont("ZoFontGame")
    closeBtn:SetNormalFontColor(
        CLR.close_btn[1], CLR.close_btn[2], CLR.close_btn[3], CLR.close_btn[4])
    closeBtn:SetHandler("OnClicked", function()
        SCENE_MANAGER:HideTopLevel(CT.window)
    end)

    -- ── Refresh button ───────────────────────────────────────────────────────
    local refreshBtn = wm:CreateControl("CraftingTrackerRefreshBtn", win, CT_BUTTON)
    refreshBtn:SetDimensions(60, 18)
    refreshBtn:SetAnchor(TOPRIGHT, win, TOPRIGHT, -PAD - 24, 6)
    refreshBtn:SetText("Refresh")
    refreshBtn:SetFont("ZoFontGame")
    refreshBtn:SetNormalFontColor(0.45, 0.85, 1.00, 1)
    refreshBtn:SetHandler("OnClicked", function()
        SaveCurrentChar()
        RefreshList()
    end)

    -- ── Divider under title ─────────────────────────────────────────────────
    MkDivider(win, TITLE_H)

    -- ── Column headers ──────────────────────────────────────────────────────
    MkLabel(win, "Character",
        ColX("name"), HDR_Y, C_CHAR, ROW_H,
        "ZoFontGameBold", TEXT_ALIGN_LEFT, CLR.header)

    for ci, lineInfo in ipairs(CRAFT_LINES) do
        MkLabel(win, lineInfo.short,
            ColX(ci), HDR_Y, C_CRAFT, ROW_H,
            "ZoFontGameBold", TEXT_ALIGN_CENTER, CLR.header)
    end

    MkLabel(win, "Total",
        ColX(#CRAFT_LINES + 1), HDR_Y, C_TOTAL, ROW_H,
        "ZoFontGameBold", TEXT_ALIGN_CENTER, CLR.header)

    -- ── Divider under headers ───────────────────────────────────────────────
    MkDivider(win, HDR_DIV_Y, 0.45)

    -- ── Scrollable list area ────────────────────────────────────────────────
    local listH = WIN_H - LIST_Y - PAD

    -- ZO_ScrollContainer provides mouse-wheel scrolling out of the box.
    local scrollContainer = CreateControlFromVirtual(
        "CraftingTrackerScrollContainer", win, "ZO_ScrollContainer")
    scrollContainer:SetDimensions(WIN_W - PAD * 2, listH)
    scrollContainer:SetAnchor(TOPLEFT, win, TOPLEFT, PAD, LIST_Y)

    -- The scroll child is the control we parent row labels to.
    -- ZO_ScrollContainer names its inner control "$(parent)ScrollChild".
    local scrollChild = scrollContainer:GetNamedChild("ScrollChild")
    if scrollChild then
        scrollChild:SetResizeToFitDescendents(false)
    else
        -- Fallback for unusual ESO builds: create our own child
        scrollChild = wm:CreateControl(
            "CraftingTrackerScrollChild", scrollContainer, CT_CONTROL)
    end
    scrollChild:SetDimensions(WIN_W - PAD * 2, listH)

    CT.window      = win
    CT.scrollChild = scrollChild

    SCENE_MANAGER:RegisterTopLevel(win, false)

    win:SetHandler("OnShow", function()
        SaveCurrentChar()
        RefreshList()
    end)
end

-- ---------------------------------------------------------------------------
-- Toggle open/close; refreshes data on open.
-- ---------------------------------------------------------------------------
local function ToggleWindow()
    if not CT.window then CreateWindow() end
    SCENE_MANAGER:ToggleTopLevel(CT.window)
end

-- =============================================================================
-- Event handlers
-- =============================================================================

local function OnSkillsFullUpdate()
    -- EVENT_SKILLS_FULL_UPDATE fires when SKILLS_DATA_MANAGER has fully
    -- populated all skill line data — the correct time to read ranks.
    SaveCurrentChar()
    -- If the window is already open, refresh it live
    if CT.window and not CT.window:IsHidden() then
        RefreshList()
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end

    -- Initialise saved vars
    if VicsCharTrackrData == nil then VicsCharTrackrData = {} end

    -- EVENT_SKILLS_FULL_UPDATE fires after login and after reloadui once
    -- SKILLS_DATA_MANAGER has finished building all skill line data.
    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME, EVENT_SKILLS_FULL_UPDATE, OnSkillsFullUpdate)

    -- Unregister load event; we only need it once
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- Slash commands
    SLASH_COMMANDS["/vct"] = function(args)
        local arg = args and args:lower():match("^%s*(.-)%s*$") or ""
        if arg == "reset" then
            VicsCharTrackrData = {}
            d("[CraftingTracker] All data cleared.")
        elseif arg == "layers" then
            local num = GetNumActionLayers()
            d("[CT Debug] Total action layers: " .. tostring(num))
            for i = 1, num do
                d("  ["..i.."] " .. tostring(GetActionLayerNameByIndex(i)))
            end
        elseif arg == "debug" then
            d("[CT Debug] SKILL_TYPE_TRADESKILL=" .. tostring(SKILL_TYPE_TRADESKILL))
            local numLines = GetNumSkillLines(SKILL_TYPE_TRADESKILL)
            d("[CT Debug] numLines=" .. tostring(numLines))
            for li = 1, (numLines or 0) do
                local sld = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(SKILL_TYPE_TRADESKILL, li)
                if sld then
                    d("  ["..li.."] "..tostring(sld:GetName()).." rank="..tostring(sld:GetCurrentRank()).." discovered="..tostring(sld:IsDiscovered()))
                else
                    d("  ["..li.."] nil")
                end
            end
        else
            ToggleWindow()
        end
    end
    SLASH_COMMANDS["/vicstrackr"] = SLASH_COMMANDS["/vct"]

    d("|c6699FFVic's CharTrackr|r loaded — |cFFFFFF/vct|r to open, |cFFFFFF/vct reset|r to clear data.")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
