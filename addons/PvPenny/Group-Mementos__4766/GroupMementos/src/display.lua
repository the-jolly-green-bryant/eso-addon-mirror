GroupMementos = GroupMementos or {}
local GroupMementos = GroupMementos

---------------------------------------------------------------------
local truncatedText = {} -- Cache to avoid recalculating text width repeatedly

-- How much room names have to work with before truncating. This isn't a
-- fixed constant - GroupMementos.RefreshLayout() updates it (and clears the cache
-- above) to whatever space is actually available between the left edge and
-- the first tally column, since that changes as mementos are toggled on
-- and off.
local DEFAULT_NAMES_WIDTH = 130

local function TruncateText(orig)
    local maxWidth = GroupMementos.namesColumnWidth or DEFAULT_NAMES_WIDTH

    if (truncatedText[orig]) then
        return truncatedText[orig]
    end

    local text = orig
    GroupMementosDummyText:SetWidth(300)
    GroupMementosDummyText:SetText(text)
    if (GroupMementosDummyText:GetTextWidth() <= maxWidth) then
        return text
    end

    for i = 1, #orig do
        GroupMementosDummyText:SetWidth(300)
        GroupMementosDummyText:SetText(text)
        if (GroupMementosDummyText:GetTextWidth() <= maxWidth - 10) then -- leave room for the ellipsis
            text = text .. "..."
            truncatedText[orig] = text
            return text
        end
        text = string.sub(text, 1, #text - 1)
    end

    return text
end

---------------------------------------------------------------------
-- Maps a memento type to the suffix used by both its header icon
-- (GroupMementosPanelButtons<suffix>) and its count column
-- (GroupMementosPanel<suffix>).
local COLUMN_SUFFIX = {
    mudball = "Mudball",
    snowball = "Snowball",
    blossom = "Blossom",
    crow = "Crow",
    pie = "Pie",
}

-- Small safety margin in case a column still lands right at the scroll
-- container's edge (e.g. a scrollbar appears for a large group). The header
-- icons themselves are kept far enough from the panel edge that centering
-- shouldn't need this margin to kick in under normal circumstances.
local SCROLL_EDGE_MARGIN = 2

-- Visual order of the icons in the header row, right to left, and the
-- spacing between them - matches how they were originally laid out in XML.
local ICON_VISUAL_ORDER = { "pie", "crow", "blossom", "snowball", "mudball" }
local ICON_EDGE_INSET = 24
local ICON_GAP = 25

-- Breathing room between adjacent columns (name -> total -> tally columns).
local COLUMN_GAP = 8

-- The Total column always sits between the name and the first memento column.
local TOTAL_COLUMN_WIDTH = 45

-- Lay out the header icons and their count columns based on which mementos
-- are currently tracked. A disabled memento's icon and column are hidden
-- entirely, and everything else shifts over to fill the gap rather than
-- leaving a blank space - same as unplugging a monitor from an extended
-- desktop, the remaining ones slide over rather than leaving a hole.
--
-- Icon positions and column positions are both computed here (not read from
-- static XML anchors), since which icons exist at all now depends on the
-- user's settings. Column alignment reads the icon's *actual* rendered
-- position rather than assuming anything about ZO_ScrollContainer's internal
-- scrollbar padding - that's not something we can see from here.
function GroupMementos.RefreshLayout()
    local buttons = GroupMementosPanel:GetNamedChild("Buttons")
    local scrollContainer = GroupMementosPanel:GetNamedChild("ScrollContainer")
    local scrollChild = GetControl("GroupMementosPanelScrollContainerScrollChild")
    if (not buttons or not scrollChild or not scrollContainer) then return end

    local scrollChildLeft = scrollChild:GetLeft()
    local visibleLeft = scrollContainer:GetLeft() + SCROLL_EDGE_MARGIN
    local visibleRight = scrollContainer:GetRight() - SCROLL_EDGE_MARGIN

    -- The Names column is pinned to the left edge of the scroll area, so it
    -- doesn't drift around as memento columns are toggled on and off.
    local names = GroupMementosPanel:GetNamedChild("Names")
    names:ClearAnchors()
    names:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, visibleLeft - scrollChildLeft, 0)

    local previousIcon = nil -- the last *visible* icon, walking right to left
    local leftmostColumnLeft = visibleRight -- if nothing's tracked, names can use the whole row

    for _, mementoType in ipairs(ICON_VISUAL_ORDER) do
        local suffix = COLUMN_SUFFIX[mementoType]
        local icon = GetControl("GroupMementosPanelButtons" .. suffix)
        local label = GroupMementosPanel:GetNamedChild(suffix)
        local enabled = GroupMementos.savedOptions.trackMemento[mementoType]

        if (icon) then icon:SetHidden(not enabled) end
        if (label) then label:SetHidden(not enabled) end

        if (enabled and icon) then
            icon:ClearAnchors()
            if (previousIcon) then
                icon:SetAnchor(RIGHT, previousIcon, LEFT, -ICON_GAP, 0)
            else
                icon:SetAnchor(RIGHT, buttons, RIGHT, -ICON_EDGE_INSET, 0)
            end
            previousIcon = icon

            if (label) then
                local width = label:GetWidth()
                local iconCenterX = (icon:GetLeft() + icon:GetRight()) / 2
                local left = iconCenterX - width / 2
                local right = left + width

                if (right > visibleRight) then
                    left = left - (right - visibleRight)
                elseif (left < visibleLeft) then
                    left = visibleLeft
                end

                label:ClearAnchors()
                label:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, left - scrollChildLeft, 0)
                leftmostColumnLeft = left -- keeps overwriting; the last one hit going right-to-left wins
            end
        end
    end

    -- A total that's just equal to the one tracked memento's own count isn't
    -- telling you anything new, so hide the column entirely when there's
    -- nothing to actually sum (0 or 1 tracked mementos).
    local trackedCount = 0
    for _, mementoType in ipairs(GroupMementos.MEMENTO_ORDER) do
        if (GroupMementos.savedOptions.trackMemento[mementoType]) then
            trackedCount = trackedCount + 1
        end
    end
    local showTotal = trackedCount > 1

    local totalColumn = GroupMementosPanel:GetNamedChild("Total")
    local totalHeader = buttons:GetNamedChild("Total")
    totalColumn:SetHidden(not showTotal)
    totalHeader:SetHidden(not showTotal)

    -- Give names all the room between the left edge and wherever the Total
    -- column starts (which itself sits right before the first tally column),
    -- instead of a fixed width - so disabling mementos (or hiding Total
    -- entirely) frees up space for longer names to show in full.
    local reservedForTotal = showTotal and (COLUMN_GAP + TOTAL_COLUMN_WIDTH) or 0
    local namesWidth = math.max(leftmostColumnLeft - visibleLeft - COLUMN_GAP - reservedForTotal, 20)
    names:SetWidth(namesWidth)
    GroupMementos.namesColumnWidth = namesWidth
    ZO_ClearTable(truncatedText)

    -- The Total column (and its header label above it) sits right after
    -- Names, wherever that ends up given the dynamic width above.
    if (showTotal) then
        local totalLeft = visibleLeft + namesWidth + COLUMN_GAP

        totalColumn:ClearAnchors()
        totalColumn:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, totalLeft - scrollChildLeft, 0)

        totalHeader:ClearAnchors()
        totalHeader:SetAnchor(TOPLEFT, buttons, TOPLEFT, totalLeft - buttons:GetLeft(), 0)
    end
end

---------------------------------------------------------------------
function GroupMementos.UpdateDisplay()
    local control = GroupMementosPanel
    if (not control) then return end

    -- Tally storage stays keyed by character name (the only thing combat
    -- events give us), but each row is shown using whichever name the
    -- "Group member display name" setting picks. Each row's total only sums
    -- currently tracked mementos, so it always matches what the visible
    -- columns actually add up to.
    local rows = {}
    for characterName in pairs(GroupMementos.groupMembers) do
        local counts = GroupMementos.savedOptions.sessionTally[characterName] or {}
        local total = 0
        for _, mementoType in ipairs(GroupMementos.MEMENTO_ORDER) do
            if (GroupMementos.savedOptions.trackMemento[mementoType]) then
                total = total + (counts[mementoType] or 0)
            end
        end
        table.insert(rows, { key = characterName, display = GroupMementos.GetDisplayName(characterName), total = total })
    end

    if (GroupMementos.savedOptions.sortBy == "total") then
        table.sort(rows, function(a, b)
            if (a.total ~= b.total) then return a.total > b.total end
            return a.display < b.display
        end)
    else
        table.sort(rows, function(a, b) return a.display < b.display end)
    end

    local nameLines = {}
    local totalLines = {}
    local countLines = { mudball = {}, snowball = {}, blossom = {}, crow = {}, pie = {} }

    for _, row in ipairs(rows) do
        local counts = GroupMementos.savedOptions.sessionTally[row.key] or {}
        table.insert(nameLines, TruncateText(row.display))
        table.insert(totalLines, row.total)
        for _, mementoType in ipairs(GroupMementos.MEMENTO_ORDER) do
            table.insert(countLines[mementoType], counts[mementoType] or 0)
        end
    end

    control:GetNamedChild("Names"):SetText(table.concat(nameLines, "\n"))
    control:GetNamedChild("Total"):SetText(table.concat(totalLines, "\n"))
    control:GetNamedChild("Mudball"):SetText(table.concat(countLines.mudball, "\n"))
    control:GetNamedChild("Snowball"):SetText(table.concat(countLines.snowball, "\n"))
    control:GetNamedChild("Blossom"):SetText(table.concat(countLines.blossom, "\n"))
    control:GetNamedChild("Crow"):SetText(table.concat(countLines.crow, "\n"))
    control:GetNamedChild("Pie"):SetText(table.concat(countLines.pie, "\n"))

    control:GetNamedChild("Names"):SetHeight(1000)
    local textHeight = math.max(control:GetNamedChild("Names"):GetTextHeight(), 20)
    control:GetNamedChild("Names"):SetHeight(textHeight)
    control:GetNamedChild("Total"):SetHeight(textHeight)
    control:GetNamedChild("Mudball"):SetHeight(textHeight)
    control:GetNamedChild("Snowball"):SetHeight(textHeight)
    control:GetNamedChild("Blossom"):SetHeight(textHeight)
    control:GetNamedChild("Crow"):SetHeight(textHeight)
    control:GetNamedChild("Pie"):SetHeight(textHeight)

    control:GetNamedChild("ScrollContainer"):SetHeight(textHeight)
    control:SetHeight(textHeight + 60)

    control:SetHidden(not GroupMementos.savedOptions.showPanel or #rows == 0)
end

-- Locking just disables dragging (SetMovable) - it doesn't touch mouseEnabled,
-- so the Close/Options buttons keep working normally either way.
function GroupMementos.ApplyLockState()
    GroupMementosPanel:SetMovable(not GroupMementos.savedOptions.locked)
end

function GroupMementos.InitializeDisplay()
    GroupMementosPanel:ClearAnchors()
    GroupMementosPanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GroupMementos.savedOptions.displayX, GroupMementos.savedOptions.displayY)

    GroupMementos.ApplyLockState()
    GroupMementos.RefreshLayout()
    GroupMementos.UpdateDisplay()
end
