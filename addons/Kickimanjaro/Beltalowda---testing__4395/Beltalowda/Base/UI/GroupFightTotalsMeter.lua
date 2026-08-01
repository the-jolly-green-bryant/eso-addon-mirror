-- Beltalowda Group Fight Totals Meter
-- Three-column leaderboard (Damage | Healing | Shield Output) showing
-- raw fight totals for each group member in PvP.
--
-- Data flow:
-- 1. FightTotals.lua collects local player's totals via EVENT_COMBAT_EVENT
-- 2. GroupBroadcast.lua broadcasts totals every 3s via LGB protocol 229
-- 3. This module displays all group members' totals sorted by value
--
-- UI inspired by RdK's HpDmgMeter but adapted for Beltalowda's patterns.

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.GroupFightTotalsMeter = Beltalowda.UI.GroupFightTotalsMeter or {}

local GFTM = Beltalowda.UI.GroupFightTotalsMeter

-- ============================================================================
-- Constants
-- ============================================================================

GFTM.CALLBACK_NAME = "BeltalowdaGroupFightTotalsMeter"
GFTM.TLW_NAME = "BeltalowdaGroupFightTotalsMeterTLW"

GFTM.MAX_PLAYERS = 12  -- PvP group cap

-- View modes
GFTM.VIEW_ALL = 1
GFTM.VIEW_DAMAGE_HEALING = 2
GFTM.VIEW_DAMAGE = 3
GFTM.VIEW_HEALING = 4
GFTM.VIEW_SHIELDING = 5
GFTM.VIEW_HEALING_SHIELDING = 6

GFTM.VIEW_NAMES = {
    [1] = "All Three",
    [2] = "Damage + Healing",
    [3] = "Damage Only",
    [4] = "Healing Only",
    [5] = "Shield Only",
    [6] = "Healing + Shields",
}

-- Size presets
GFTM.SIZE_SMALL = 1
GFTM.SIZE_BIG = 2

GFTM.SIZES = {
    [1] = { columnWidth = 220, blockHeight = 18, fontSize = 13, titleHeight = 20 },
    [2] = { columnWidth = 340, blockHeight = 30, fontSize = 22, titleHeight = 28 },
}

-- Update interval for the UI loop (ms)
GFTM.UI_UPDATE_INTERVAL = 500

-- Number display format
GFTM.DISPLAY_NUMBER_PERCENT = 1
GFTM.DISPLAY_NUMBER_ONLY = 2
GFTM.DISPLAY_PERCENT_ONLY = 3

GFTM.DISPLAY_FORMAT_NAMES = {
    [1] = "Number + Percent",
    [2] = "Number Only",
    [3] = "Percent Only",
}

-- ============================================================================
-- State
-- ============================================================================

GFTM.state = {
    initialized = false,
    menuHidden = false,
    pvpHidden = false,
}

GFTM.controls = {}
GFTM.settings = nil

local wm = WINDOW_MANAGER

-- ============================================================================
-- Default Settings
-- ============================================================================

function GFTM.GetDefaults()
    return {
        enabled = false,
        positionLocked = false,
        location = nil,
        size = GFTM.SIZE_SMALL,
        viewMode = GFTM.VIEW_ALL,
        verticalStack = false,
        displayFormat = GFTM.DISPLAY_NUMBER_PERCENT,
        autoReset = false,
    }
end

-- ============================================================================
-- Settings Persistence
-- ============================================================================

function GFTM.LoadSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}

    if not BeltalowdaVars.ui.groupFightTotalsMeter then
        BeltalowdaVars.ui.groupFightTotalsMeter = GFTM.GetDefaults()
    end

    -- Ensure all default keys exist (forward compat)
    local defaults = GFTM.GetDefaults()
    for k, v in pairs(defaults) do
        if BeltalowdaVars.ui.groupFightTotalsMeter[k] == nil then
            BeltalowdaVars.ui.groupFightTotalsMeter[k] = v
        end
    end

    GFTM.settings = BeltalowdaVars.ui.groupFightTotalsMeter
end

function GFTM.SaveSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.groupFightTotalsMeter = GFTM.settings
end

-- ============================================================================
-- Font Helper
-- ============================================================================

local function MakeFontString(size)
    return "$(MEDIUM_FONT)|" .. tostring(math.floor(size)) .. "|soft-shadow-thin"
end

-- ============================================================================
-- Number Formatting
-- ============================================================================

--[[
    Format a raw number into a compact readable string.
    Examples: 1234 → "1,234", 1234567 → "1,234k", 12345678 → "12,345k"
]]
local function FormatNumber(value)
    if value >= 1000000 then
        -- Show in k with comma separator
        local k = math.floor(value / 1000)
        return ZO_LocalizeDecimalNumber(k) .. "k"
    elseif value >= 1000 then
        return ZO_LocalizeDecimalNumber(math.floor(value))
    else
        return tostring(math.floor(value))
    end
end

-- ============================================================================
-- UI Creation
-- ============================================================================

function GFTM.CreateUI()
    -- Top-level window
    GFTM.controls.TLW = wm:CreateTopLevelWindow(GFTM.TLW_NAME)
    GFTM.SetTlwLocation()
    GFTM.controls.TLW:SetClampedToScreen(true)
    GFTM.controls.TLW:SetHandler("OnMoveStop", GFTM.SaveWindowLocation)

    -- Root control
    local root = wm:CreateControl(nil, GFTM.controls.TLW, CT_CONTROL)
    root:SetAnchor(TOPLEFT, GFTM.controls.TLW, TOPLEFT, 0, 0)
    GFTM.controls.root = root

    -- Movable backdrop (visible when unlocked)
    root.movableBackdrop = wm:CreateControl(nil, root, CT_BACKDROP)
    root.movableBackdrop:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
    root.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
    root.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)

    -- Create three columns
    root.damageColumn = GFTM.CreateColumn(root, "Damage", 0)
    root.healingColumn = GFTM.CreateColumn(root, "Healing", 1)
    root.shieldColumn = GFTM.CreateColumn(root, "Shields", 2)

    GFTM.controls.TLW:SetHidden(true)
    GFTM.AdjustSize()
    GFTM.AdjustViewMode()
    GFTM.SetPositionLocked(GFTM.settings.positionLocked)
end

--[[
    Create a single column with title label + 12 player rows.
    @param parent   control  Parent control
    @param title    string   Column header text
    @param colIndex number   Column index (0, 1, 2) for horizontal positioning
    @return table   Column control with .title and .playerBlocks[1..12]
]]
function GFTM.CreateColumn(parent, title, colIndex)
    local small = GFTM.SIZES[GFTM.SIZE_SMALL]
    local col = wm:CreateControl(nil, parent, CT_CONTROL)
    col:SetAnchor(TOPLEFT, parent, TOPLEFT, colIndex * small.columnWidth, 0)

    -- Title label
    col.title = wm:CreateControl(nil, col, CT_LABEL)
    col.title:SetAnchor(TOPLEFT, col, TOPLEFT, 0, 0)
    col.title:SetFont(MakeFontString(small.fontSize))
    col.title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    col.title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    col.title:SetText(title)
    col.title:SetColor(1, 1, 1, 1)

    -- Player blocks
    col.playerBlocks = {}
    for i = 1, GFTM.MAX_PLAYERS do
        col.playerBlocks[i] = GFTM.CreatePlayerBlock(col, i, small)
    end

    return col
end

--[[
    Create a single player row within a column.
    Each row has: background backdrop + name label + value label.
]]
function GFTM.CreatePlayerBlock(parent, index, sizeConfig)
    local block = {}

    local yOffset = sizeConfig.titleHeight + (index - 1) * sizeConfig.blockHeight
    local nameWidth = math.floor(sizeConfig.columnWidth * 0.55)
    local valueWidth = sizeConfig.columnWidth - nameWidth

    -- Name backdrop (left portion)
    block.nameBackdrop = wm:CreateControl(nil, parent, CT_BACKDROP)
    block.nameBackdrop:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, yOffset)
    block.nameBackdrop:SetDimensions(nameWidth, sizeConfig.blockHeight)
    block.nameBackdrop:SetCenterColor(0, 0, 0, 0)
    block.nameBackdrop:SetEdgeColor(0, 0, 0, 0)

    -- Name label
    block.name = wm:CreateControl(nil, parent, CT_LABEL)
    block.name:SetAnchor(TOPLEFT, parent, TOPLEFT, 2, yOffset)
    block.name:SetDimensions(nameWidth - 4, sizeConfig.blockHeight)
    block.name:SetFont(MakeFontString(sizeConfig.fontSize))
    block.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    block.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    block.name:SetWrapMode(ELLIPSIS)

    -- Value backdrop (right portion)
    block.valueBackdrop = wm:CreateControl(nil, parent, CT_BACKDROP)
    block.valueBackdrop:SetAnchor(TOPLEFT, parent, TOPLEFT, nameWidth, yOffset)
    block.valueBackdrop:SetDimensions(valueWidth, sizeConfig.blockHeight)
    block.valueBackdrop:SetCenterColor(0, 0, 0, 0)
    block.valueBackdrop:SetEdgeColor(0, 0, 0, 0)

    -- Value label
    block.value = wm:CreateControl(nil, parent, CT_LABEL)
    block.value:SetAnchor(TOPLEFT, parent, TOPLEFT, nameWidth, yOffset)
    block.value:SetDimensions(valueWidth - 2, sizeConfig.blockHeight)
    block.value:SetFont(MakeFontString(sizeConfig.fontSize))
    block.value:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    block.value:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    return block
end

-- ============================================================================
-- Positioning
-- ============================================================================

function GFTM.SetTlwLocation()
    GFTM.controls.TLW:ClearAnchors()
    if GFTM.settings.location then
        GFTM.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
            GFTM.settings.location.x, GFTM.settings.location.y)
    else
        local screenW, screenH = GuiRoot:GetDimensions()
        GFTM.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
            math.floor(screenW / 2 - 200), math.floor(screenH / 2 - 100))
    end
end

function GFTM.SaveWindowLocation()
    if not GFTM.settings.positionLocked then
        GFTM.settings.location = GFTM.settings.location or {}
        GFTM.settings.location.x = GFTM.controls.TLW:GetLeft()
        GFTM.settings.location.y = GFTM.controls.TLW:GetTop()
        GFTM.SaveSettings()
    end
end

-- ============================================================================
-- Size / Layout / View Mode
-- ============================================================================

function GFTM.AdjustSize()
    local sizeIncrease = GFTM.settings.size - GFTM.SIZE_SMALL
    local small = GFTM.SIZES[GFTM.SIZE_SMALL]
    local big   = GFTM.SIZES[GFTM.SIZE_BIG]

    local colWidth    = small.columnWidth  + (big.columnWidth  - small.columnWidth)  * sizeIncrease
    local blockH      = small.blockHeight  + (big.blockHeight  - small.blockHeight)  * sizeIncrease
    local fontSize    = small.fontSize     + (big.fontSize     - small.fontSize)     * sizeIncrease
    local titleH      = small.titleHeight  + (big.titleHeight  - small.titleHeight)  * sizeIncrease

    local font = MakeFontString(fontSize)
    local nameWidth = math.floor(colWidth * 0.55)
    local valueWidth = colWidth - nameWidth
    local numCols = GFTM.GetVisibleColumnCount()
    local colHeight = titleH + blockH * GFTM.MAX_PLAYERS
    local vertical = GFTM.settings.verticalStack

    local totalWidth, totalHeight
    if vertical then
        totalWidth = colWidth
        totalHeight = colHeight * numCols
    else
        totalWidth = colWidth * numCols
        totalHeight = colHeight
    end

    -- Size the TLW and root
    GFTM.controls.TLW:SetDimensions(totalWidth, totalHeight)
    GFTM.controls.root:SetDimensions(totalWidth, totalHeight)
    GFTM.controls.root.movableBackdrop:SetDimensions(totalWidth, totalHeight)

    -- Resize all three columns
    local columns = { GFTM.controls.root.damageColumn, GFTM.controls.root.healingColumn, GFTM.controls.root.shieldColumn }
    for _, col in ipairs(columns) do
        col:SetDimensions(colWidth, totalHeight)
        col.title:SetDimensions(colWidth, titleH)
        col.title:SetFont(font)

        for i = 1, GFTM.MAX_PLAYERS do
            local block = col.playerBlocks[i]
            local yOffset = titleH + (i - 1) * blockH

            block.nameBackdrop:ClearAnchors()
            block.nameBackdrop:SetAnchor(TOPLEFT, col, TOPLEFT, 0, yOffset)
            block.nameBackdrop:SetDimensions(nameWidth, blockH)

            block.name:ClearAnchors()
            block.name:SetAnchor(TOPLEFT, col, TOPLEFT, 2, yOffset)
            block.name:SetDimensions(nameWidth - 4, blockH)
            block.name:SetFont(font)

            block.valueBackdrop:ClearAnchors()
            block.valueBackdrop:SetAnchor(TOPLEFT, col, TOPLEFT, nameWidth, yOffset)
            block.valueBackdrop:SetDimensions(valueWidth, blockH)

            block.value:ClearAnchors()
            block.value:SetAnchor(TOPLEFT, col, TOPLEFT, nameWidth, yOffset)
            block.value:SetDimensions(valueWidth - 2, blockH)
            block.value:SetFont(font)
        end
    end
end

function GFTM.GetVisibleColumnCount()
    local mode = GFTM.settings.viewMode
    if mode == GFTM.VIEW_ALL then return 3
    elseif mode == GFTM.VIEW_DAMAGE_HEALING or mode == GFTM.VIEW_HEALING_SHIELDING then return 2
    else return 1
    end
end

--[[
    Get the list of visible column controls and their stat keys for the current view mode.
    @return table  Array of { col = columnControl, stat = "damage"|"healing"|"shielding" }
]]
function GFTM.GetVisibleColumns()
    local root = GFTM.controls.root
    local mode = GFTM.settings.viewMode
    if mode == GFTM.VIEW_ALL then
        return {
            { col = root.damageColumn, stat = "damage" },
            { col = root.healingColumn, stat = "healing" },
            { col = root.shieldColumn, stat = "shielding" },
        }
    elseif mode == GFTM.VIEW_DAMAGE_HEALING then
        return {
            { col = root.damageColumn, stat = "damage" },
            { col = root.healingColumn, stat = "healing" },
        }
    elseif mode == GFTM.VIEW_HEALING_SHIELDING then
        return {
            { col = root.healingColumn, stat = "healing" },
            { col = root.shieldColumn, stat = "shielding" },
        }
    elseif mode == GFTM.VIEW_DAMAGE then
        return { { col = root.damageColumn, stat = "damage" } }
    elseif mode == GFTM.VIEW_HEALING then
        return { { col = root.healingColumn, stat = "healing" } }
    elseif mode == GFTM.VIEW_SHIELDING then
        return { { col = root.shieldColumn, stat = "shielding" } }
    end
    return {}
end

function GFTM.AdjustViewMode()
    local root = GFTM.controls.root
    local sizeIncrease = GFTM.settings.size - GFTM.SIZE_SMALL
    local small = GFTM.SIZES[GFTM.SIZE_SMALL]
    local big   = GFTM.SIZES[GFTM.SIZE_BIG]
    local colWidth = small.columnWidth + (big.columnWidth - small.columnWidth) * sizeIncrease

    -- Hide all columns first
    root.damageColumn:SetHidden(true)
    root.healingColumn:SetHidden(true)
    root.shieldColumn:SetHidden(true)

    -- Show and position visible columns
    local visible = GFTM.GetVisibleColumns()
    local vertical = GFTM.settings.verticalStack

    for colIdx, entry in ipairs(visible) do
        entry.col:SetHidden(false)
        entry.col:ClearAnchors()
        if vertical then
            -- Stack vertically: same X, offset Y by column height
            local blockH = small.blockHeight + (big.blockHeight - small.blockHeight) * sizeIncrease
            local titleH = small.titleHeight + (big.titleHeight - small.titleHeight) * sizeIncrease
            local colHeight = titleH + blockH * GFTM.MAX_PLAYERS
            entry.col:SetAnchor(TOPLEFT, root, TOPLEFT, 0, (colIdx - 1) * colHeight)
        else
            -- Side by side
            entry.col:SetAnchor(TOPLEFT, root, TOPLEFT, (colIdx - 1) * colWidth, 0)
        end
    end

    GFTM.AdjustSize()
end

-- ============================================================================
-- Visibility
-- ============================================================================

function GFTM.SetControlVisibility()
    if not GFTM.controls.TLW then return end

    if GFTM.settings.enabled then
        GFTM.controls.TLW:SetHidden(GFTM.state.menuHidden == true or GFTM.state.pvpHidden == true)
    else
        GFTM.controls.TLW:SetHidden(true)
    end
end

function GFTM.SetMenuHidden(hidden)
    GFTM.state.menuHidden = hidden
    GFTM.SetControlVisibility()
end

function GFTM.SetPvPHidden(hidden)
    GFTM.state.pvpHidden = hidden
    GFTM.SetControlVisibility()
end

function GFTM.SetPositionLocked(value)
    GFTM.settings.positionLocked = value
    GFTM.controls.TLW:SetMovable(not value)
    GFTM.controls.TLW:SetMouseEnabled(not value)

    if value then
        GFTM.controls.root.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
        GFTM.controls.root.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
    else
        GFTM.controls.root.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
        GFTM.controls.root.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
    end
    GFTM.SaveSettings()
end

-- ============================================================================
-- Enable / Disable
-- ============================================================================

function GFTM.SetEnabled(value)
    if not GFTM.state.initialized then return end
    GFTM.settings.enabled = value
    GFTM.SaveSettings()

    local FT = Beltalowda.Data and Beltalowda.Data.FightTotals
    if value then
        -- Register combat events and start UI loop
        if FT then FT.RegisterCombatEvents() end
        EVENT_MANAGER:RegisterForUpdate(GFTM.CALLBACK_NAME, GFTM.UI_UPDATE_INTERVAL, GFTM.UiLoop)
    else
        -- Unregister combat events and stop UI loop
        if FT then FT.UnregisterCombatEvents() end
        EVENT_MANAGER:UnregisterForUpdate(GFTM.CALLBACK_NAME)
    end

    GFTM.SetControlVisibility()
end

-- ============================================================================
-- Data Collection
-- ============================================================================

--[[
    Build a sorted player list for a given stat column.
    Combines local player data from FightTotals with remote data from GroupBroadcast.
    @param stat  string  "damage", "healing", or "shielding"
    @return table  Sorted list of { unitTag, name, value, isDead }
    @return number Total of all values for percentage calculation
]]
function GFTM.BuildPlayerList(stat)
    local players = {}
    local total = 0
    local groupSize = GetGroupSize()
    if groupSize == 0 then return players, 0 end

    local FT = Beltalowda.Data and Beltalowda.Data.FightTotals
    local BN = Beltalowda.network

    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then
            local name = Beltalowda.GetDisplayName(unitTag)
            local value = 0
            local isPlayer = AreUnitsEqual(unitTag, "player")

            if isPlayer and FT then
                -- Local player: use direct FightTotals data (full precision)
                if stat == "damage" then
                    value = FT.GetDamage()
                elseif stat == "healing" then
                    value = FT.GetHealing()
                elseif stat == "shielding" then
                    value = FT.GetShielding()
                end
            elseif BN and BN.groupData and BN.groupData[unitTag] then
                -- Remote player: use broadcast data
                local ft = BN.groupData[unitTag].fightTotals
                if ft then
                    value = ft[stat] or 0
                end
            end

            table.insert(players, {
                unitTag = unitTag,
                name = name or "",
                value = value,
                isDead = IsUnitDead(unitTag),
            })
            total = total + value
        end
    end

    -- Sort descending by value, then alphabetical
    table.sort(players, function(a, b)
        if a.value ~= b.value then
            return a.value > b.value
        end
        return a.name < b.name
    end)

    return players, total
end

-- ============================================================================
-- UI Update Loop
-- ============================================================================

function GFTM.UiLoop()
    if not GFTM.settings.enabled then return end
    if GFTM.state.menuHidden or GFTM.state.pvpHidden then return end

    local visible = GFTM.GetVisibleColumns()
    for _, entry in ipairs(visible) do
        GFTM.UpdateColumn(entry.col, entry.stat)
    end
end

--[[
    Update a single column with sorted player data.
    @param column  table   Column control with .playerBlocks
    @param stat    string  "damage", "healing", or "shielding"
]]
function GFTM.UpdateColumn(column, stat)
    local players, total = GFTM.BuildPlayerList(stat)
    local blocks = column.playerBlocks

    for i = 1, GFTM.MAX_PLAYERS do
        local block = blocks[i]
        if i <= #players then
            local player = players[i]

            -- Alternating row backdrop
            local alpha = (i % 2 == 1) and 0.15 or 0.25
            block.nameBackdrop:SetCenterColor(0, 0, 0, alpha)
            block.nameBackdrop:SetEdgeColor(0, 0, 0, 0)
            block.valueBackdrop:SetCenterColor(0, 0, 0, alpha)
            block.valueBackdrop:SetEdgeColor(0, 0, 0, 0)

            -- Set name
            block.name:SetText(player.name)

            -- Set value
            local pct = 0
            if total > 0 and player.value > 0 then
                pct = (player.value / total) * 100
            end
            if player.value > 0 then
                local fmt = GFTM.settings.displayFormat or GFTM.DISPLAY_NUMBER_PERCENT
                if fmt == GFTM.DISPLAY_NUMBER_ONLY then
                    block.value:SetText(FormatNumber(player.value))
                elseif fmt == GFTM.DISPLAY_PERCENT_ONLY then
                    block.value:SetText(string.format("%.1f%%", pct))
                else
                    block.value:SetText(string.format("%s (%.1f%%)", FormatNumber(player.value), pct))
                end
            else
                block.value:SetText("")
            end

            -- Text color
            block.name:SetColor(1, 1, 1)
            block.value:SetColor(1, 1, 1)
        else
            -- Empty row
            block.name:SetText("")
            block.value:SetText("")
            block.nameBackdrop:SetCenterColor(0, 0, 0, 0)
            block.nameBackdrop:SetEdgeColor(0, 0, 0, 0)
            block.valueBackdrop:SetCenterColor(0, 0, 0, 0)
            block.valueBackdrop:SetEdgeColor(0, 0, 0, 0)
        end
    end
end

-- ============================================================================
-- Data Change Callback
-- ============================================================================

--[[
    Called by GroupBroadcast when fight totals data arrives from a group member.
    Triggers a UI refresh on next loop iteration (no immediate redraw needed
    since the UI loop runs every 500ms).
]]
function GFTM.OnFightTotalsChanged(unitTag)
    -- No-op: UiLoop will pick up the data on next tick.
    -- This hook exists for future use (e.g. immediate refresh for important events).
end

-- ============================================================================
-- Reset
-- ============================================================================

function GFTM.ResetFightTotals()
    local FT = Beltalowda.Data and Beltalowda.Data.FightTotals
    if FT then
        FT.Reset()
    end

    -- Clear remote data
    local BN = Beltalowda.network
    if BN and BN.groupData then
        for tag, data in pairs(BN.groupData) do
            if data.fightTotals then
                data.fightTotals = nil
            end
        end
    end
end

-- ============================================================================
-- Settings Controls (for BeltalowdaSettings.lua)
-- ============================================================================

function GFTM.GetSettingsControls()
    local viewChoices = {}
    local viewValues = {}
    for k, v in pairs(GFTM.VIEW_NAMES) do
        table.insert(viewValues, k)
        table.insert(viewChoices, v)
    end

    local displayFormatChoices = {}
    local displayFormatValues = {}
    for k, v in pairs(GFTM.DISPLAY_FORMAT_NAMES) do
        table.insert(displayFormatValues, k)
        table.insert(displayFormatChoices, v)
    end

    return {
        {
            type = "submenu",
            name = "|c4592FFLeaderboard|r",
            tooltip = "Leaderboard showing total damage, healing, and shield output for each group member during a fight.",
            controls = {
                {
                    type = "description",
                    text = "Displays a leaderboard (Damage | Healing | Shield Output) showing the raw fight totals for each group member. Each player accumulates their own damage, healing, and shield output and shares the totals with the group.\n\nShield output measures the total value of damage shields you apply to group members. Note: shield attribution may have minor inaccuracies if two players shield the same target simultaneously.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enabled",
                    tooltip = "Enable or disable the Leaderboard.",
                    getFunc = function() return GFTM.settings.enabled end,
                    setFunc = function(value) GFTM.SetEnabled(value) end,
                    width = "full",
                    default = false,
                },
                {
                    type = "checkbox",
                    name = "Lock Position",
                    tooltip = "Lock the window position. When unlocked, drag to reposition.",
                    getFunc = function() return GFTM.settings.positionLocked end,
                    setFunc = function(value) GFTM.SetPositionLocked(value) end,
                    width = "full",
                    default = false,
                    disabled = function() return not GFTM.settings.enabled end,
                },
                {
                    type = "dropdown",
                    name = "View Mode",
                    tooltip = "Choose which columns to display.",
                    choices = viewChoices,
                    choicesValues = viewValues,
                    getFunc = function() return GFTM.settings.viewMode end,
                    setFunc = function(value)
                        GFTM.settings.viewMode = value
                        GFTM.AdjustViewMode()
                        GFTM.SaveSettings()
                    end,
                    width = "full",
                    default = GFTM.VIEW_ALL,
                    disabled = function() return not GFTM.settings.enabled end,
                },
                {
                    type = "checkbox",
                    name = "Stack Vertically",
                    tooltip = "Stack columns vertically instead of side-by-side.",
                    getFunc = function() return GFTM.settings.verticalStack end,
                    setFunc = function(value)
                        GFTM.settings.verticalStack = value
                        GFTM.AdjustViewMode()
                        GFTM.SaveSettings()
                    end,
                    width = "full",
                    default = false,
                    disabled = function() return not GFTM.settings.enabled end,
                },
                {
                    type = "slider",
                    name = "Size",
                    tooltip = "Adjust the size of the meter.",
                    min = 1, max = 2, step = 0.05,
                    getFunc = function() return GFTM.settings.size end,
                    setFunc = function(value)
                        GFTM.settings.size = value
                        GFTM.AdjustSize()
                        GFTM.SaveSettings()
                    end,
                    width = "full",
                    default = GFTM.SIZE_SMALL,
                    disabled = function() return not GFTM.settings.enabled end,
                },
                {
                    type = "dropdown",
                    name = "Number Display",
                    tooltip = "Choose how values are shown: number with percentage, number only, or percentage only.",
                    choices = displayFormatChoices,
                    choicesValues = displayFormatValues,
                    getFunc = function() return GFTM.settings.displayFormat end,
                    setFunc = function(value)
                        GFTM.settings.displayFormat = value
                        GFTM.SaveSettings()
                    end,
                    width = "full",
                    default = GFTM.DISPLAY_NUMBER_PERCENT,
                    disabled = function() return not GFTM.settings.enabled end,
                },
                {
                    type = "button",
                    name = "Reset Totals",
                    tooltip = "Reset all fight totals to zero for yourself and clear received data from group members.",
                    func = function() GFTM.ResetFightTotals() end,
                    width = "full",
                    disabled = function() return not GFTM.settings.enabled end,
                },
            },
        },
    }
end

-- ============================================================================
-- Initialization
-- ============================================================================

function GFTM.Initialize()
    if GFTM.state.initialized then return end

    GFTM.LoadSettings()
    GFTM.CreateUI()
    GFTM.state.initialized = true

    -- Auto-enable if previously enabled
    if GFTM.settings.enabled then
        GFTM.SetEnabled(true)
    end
end
