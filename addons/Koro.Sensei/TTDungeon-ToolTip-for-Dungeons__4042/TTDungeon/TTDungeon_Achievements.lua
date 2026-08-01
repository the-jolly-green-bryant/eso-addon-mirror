-- TTDungeon_Achievements.lua
-- Handles achievement tracking and display for dungeon achievements
-- Shows completion status for Hard Mode, Speed Run, No Death, and Trifecta achievements

-- Initialize addon namespace
TTDungeon = TTDungeon or {}

-- Debug function specific to achievements module
local function Debug(msg)
    if TTDungeon.savedVars and TTDungeon.savedVars.debugEnabled then
        d("[TTD Ach] " .. tostring(msg))
    end
end

-- =====================================================
-- Achievement Check Functions
-- =====================================================

-- Check if an achievement is completed
-- @param achId: Achievement ID to check
-- @return: true if completed, false if not, nil if invalid ID
local function IsAchievementComplete(achId)
    if not achId or achId <= 0 then
        return nil -- Invalid achievement ID
    end
    
    -- Get achievement info from ESO API
    local _, _, _, _, completed = GetAchievementInfo(achId)
    return completed
end

-- Get colored status text for an achievement
-- @param achId: Achievement ID to check
-- @return: Colored string indicating completion status
local function GetColoredStatus(achId)
    local completed = IsAchievementComplete(achId)
    
    if completed == true then
        return "|c00FF00[Completed]|r"  -- Green
    elseif completed == false then
        return "|cFF0000[Missing]|r"     -- Red
    else
        return "|cAAAAAA[N/A]|r"         -- Gray for invalid/unavailable
    end
end

-- =====================================================
-- Tooltip Functions
-- =====================================================

-- Display a detailed tooltip for an achievement when hovering
-- Shows name, points, completion status, date, and criteria progress
local function ShowCustomAchievementTooltip(control, achId)
    if not achId or achId <= 0 then return end

    -- Get achievement information from ESO API
    local name, desc, points, icon, completed, date, time = GetAchievementInfo(achId)
    if not name or name == "" then
        return -- Invalid achievement
    end

    -- Initialize tooltip anchored to the control
    InitializeTooltip(InformationTooltip, control, TOPRIGHT, 0, 0, TOPLEFT)

    -- Add achievement title in gold
    InformationTooltip:AddLine("|cFFD700" .. name .. "|r", "ZoFontGame", 1, 1, 1)

    -- Add achievement points if any
    if points and points > 0 then
        InformationTooltip:AddLine(string.format("Points: %d", points), "ZoFontGame", 1, 1, 1)
    end

    -- Add completion status
    if completed then
        InformationTooltip:AddLine(string.format("|c00FF00Completed|r on %s", date), "ZoFontGame", 1, 1, 1)
    else
        InformationTooltip:AddLine("|cFF0000Not Completed|r", "ZoFontGame", 1, 1, 1)
    end

    -- Add empty line for spacing
    InformationTooltip:AddLine("", "ZoFontGame")

    -- Add achievement description
    if desc and desc ~= "" then
        InformationTooltip:AddLine(
            desc,
            "ZoFontGame",
            1, 1, 1,
            CENTER,
            MODIFY_TEXT_TYPE_NONE,
            TEXT_ALIGN_LEFT,
            true  -- Allow text wrapping
        )
    end

    -- Add achievement criteria if available
    local critCount = GetAchievementNumCriteria(achId)
    if critCount and critCount > 0 then
        InformationTooltip:AddLine("", "ZoFontGame")  -- Spacing
        
        -- List each criterion with progress
        for i = 1, critCount do
            local cDesc, cCur, cMax = GetAchievementCriterion(achId, i)
            if cDesc and cDesc ~= "" then
                local line = string.format("• %s: %d / %d", cDesc, cCur, cMax)
                InformationTooltip:AddLine(line, "ZoFontGame", 1, 1, 1)
            end
        end
    end
end

-- Hide the achievement tooltip
local function HideCustomAchievementTooltip()
    ClearTooltip(InformationTooltip)
end

-- =====================================================
-- Achievement UI Elements
-- =====================================================

-- Create a single achievement row in the UI
-- @param parent: Parent control to attach row to
-- @param offsetY: Vertical offset for positioning
-- @param labelText: Text label for the achievement type
-- @param achId: Achievement ID to display
-- @return: Updated Y offset for next row
local function CreateAchievementRow(parent, offsetY, labelText, achId)
    local rowHeight = 30
    local rowWidth = parent:GetWidth()

    -- Create row container
    local row = CreateControl(nil, parent, CT_CONTROL)
    row:SetDimensions(rowWidth, rowHeight)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, offsetY)
    row:SetMouseEnabled(false)

    -- Create highlight background for hover effect
    local bg = CreateControl(nil, row, CT_BACKDROP)
    bg:SetAnchorFill(row)
    bg:SetCenterColor(0, 0, 0, 0)  -- Transparent by default
    bg:SetEdgeColor(0, 0, 0, 0)
    row.bg = bg

    -- Create interactive button for the row
    local btn = CreateControl(nil, row, CT_BUTTON)
    btn:SetAnchorFill(row)
    btn:SetNormalTexture("EsoUI/Art/Buttons/wood_up.dds")
    btn:SetPressedTexture("EsoUI/Art/Buttons/wood_down.dds")
    btn:SetMouseOverTexture("EsoUI/Art/Buttons/wood_over.dds")

    -- Format display text with colored status
    local status = GetColoredStatus(achId)
    local displayText = string.format("• %s: %s", labelText, status)
    btn:SetFont("ZoFontGame")
    btn:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    btn:SetText(displayText)

    -- Set up mouse handlers for valid achievement IDs
    if achId and achId > 0 then
        -- Show tooltip and highlight on mouse enter
        btn:SetHandler("OnMouseEnter", function()
            bg:SetCenterColor(0.3, 0.3, 0.3, 0.3)
            bg:SetEdgeColor(0.5, 0.5, 0.5, 0.5)
            ShowCustomAchievementTooltip(btn, achId)
        end)
        
        -- Hide tooltip and highlight on mouse exit
        btn:SetHandler("OnMouseExit", function()
            bg:SetCenterColor(0, 0, 0, 0)
            bg:SetEdgeColor(0, 0, 0, 0)
            HideCustomAchievementTooltip()
        end)
    else
        -- For invalid achievement IDs, only show visual highlight
        btn:SetHandler("OnMouseEnter", function()
            bg:SetCenterColor(0.3, 0.3, 0.3, 0.3)
            bg:SetEdgeColor(0.5, 0.5, 0.5, 0.5)
        end)
        btn:SetHandler("OnMouseExit", function()
            bg:SetCenterColor(0, 0, 0, 0)
            bg:SetEdgeColor(0, 0, 0, 0)
        end)
    end

    -- Track created rows for cleanup
    TTDungeon.achLines = TTDungeon.achLines or {}
    table.insert(TTDungeon.achLines, row)

    -- Return updated Y offset for next row
    return offsetY + rowHeight + 2  -- 2 pixels spacing between rows
end

-- =====================================================
-- Achievement Tab Management
-- =====================================================

-- Clear all achievement rows from the UI
-- Called when switching dungeons or tabs
function TTDungeon.ClearAchievementLines()
    if TTDungeon.achLines then
        for _, c in ipairs(TTDungeon.achLines) do
            c:SetHidden(true)
            c:SetParent(nil)
        end
    end
    TTDungeon.achLines = {}
end

-- Update the achievements tab with current dungeon achievement data
-- Displays Hard Mode, Speed Run, No Death, and Trifecta achievements
-- @param data: Dungeon data containing achievement IDs
function TTDungeon.UpdateAchievements(data)
    -- Get the achievements container
    local parent = TTDungeon.achLabelInTab
    if not parent then
        Debug("No achLabelInTab container found => Achievement tab missing?")
        return
    end

    -- Clear existing achievement displays
    TTDungeon.ClearAchievementLines()

    -- If no dungeon data, clear the tab
    if not data then
        Debug("No dungeon data => clearing Achievement lines.")
        return
    end

    Debug("Achievements updated for: " .. (data.name or "???"))

    local offsetY = 10

    -- Add instructions label at the top
    local instructions = CreateControl(nil, parent, CT_LABEL)
    instructions:SetFont("ZoFontGameSmall")
    instructions:SetColor(0.7, 0.7, 0.7, 1)  -- Light gray
    instructions:SetText("Hover for Achievements Info")
    instructions:SetAnchor(TOPLEFT, parent, TOPLEFT, 10, offsetY)
    offsetY = offsetY + 25
    table.insert(TTDungeon.achLines, instructions)

    -- Add visual divider line
    local divider = CreateControl(nil, parent, CT_TEXTURE)
    divider:SetDimensions(parent:GetWidth() - 20, 2)
    divider:SetAnchor(TOPLEFT, parent, TOPLEFT, 10, offsetY)
    divider:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
    divider:SetColor(0.5, 0.5, 0.5, 0.5)
    offsetY = offsetY + 10
    table.insert(TTDungeon.achLines, divider)

    -- Create rows for each achievement type
    -- HM = Hard Mode, SR = Speed Run, ND = No Death, TR = Trifecta
    offsetY = CreateAchievementRow(parent, offsetY, "Hard Mode", data.HM)
    offsetY = CreateAchievementRow(parent, offsetY, "Speed Run", data.SR)
    offsetY = CreateAchievementRow(parent, offsetY, "No Death", data.ND)
    offsetY = CreateAchievementRow(parent, offsetY, "Trifecta", data.TR)

    -- Set final container height with padding
    offsetY = offsetY + 10
    parent:SetHeight(offsetY)
end