-- ESO Adventurer Suite
-- v0.29.569 - Raid companion visibility + layout stability.
-- Raid rows support companions, but the expensive row reflow only runs when the
-- visible roster/companion-height layout actually changes.

local EPC = ESOProgressionCoach
if not EPC or not EPC.UnitFrames then return end

local F = EPC.UnitFrames

if type(F.CreateMemberRow) == "function" and not F._easRaidCompanionCreateWrapped029566 then
    F._easRaidCompanionCreateWrapped029566 = true
    local baseCreateMemberRow = F.CreateMemberRow

    function F:CreateMemberRow(parent, name, width, height, x, y, showCompanion)
        local rowName = tostring(name or "")
        if string.find(rowName, "^EPC_RaidMember") then
            showCompanion = true
        end
        return baseCreateMemberRow(self, parent, name, width, height, x, y, showCompanion)
    end
end

local function buildLayoutSignature(frame)
    local parts = {}
    for index, row in ipairs(frame.epcRows or {}) do
        if row and type(row.IsHidden) == "function" and not row:IsHidden() then
            local height = type(row.GetHeight) == "function" and tonumber(row:GetHeight()) or tonumber(row.epcCompactHeight) or 0
            parts[#parts + 1] = table.concat({
                tostring(index),
                tostring(row.epcUnitTag or ""),
                row.epcHasCompanion == true and "1" or "0",
                tostring(math.floor((height or 0) + 0.5)),
            }, ":")
        end
    end
    return table.concat(parts, "|")
end

local function reflowRaid(self, force)
    local frame = self and self.raidFrame
    if not frame or type(frame.IsHidden) ~= "function" or frame:IsHidden() then return end
    if type(frame.epcRows) ~= "table" then return end

    local signature = buildLayoutSignature(frame)
    if force ~= true and frame._easRaidLayoutSignature029569 == signature then return end
    frame._easRaidLayoutSignature029569 = signature

    local visible = {}
    for _, row in ipairs(frame.epcRows) do
        if row and type(row.IsHidden) == "function" and not row:IsHidden() then
            visible[#visible + 1] = row
        end
    end
    if #visible == 0 then return end

    local columns = #visible > 12 and 3 or 2
    if #visible <= 4 then columns = 2 end
    local rowsPerColumn = math.max(1, math.ceil(#visible / columns))
    local columnGap = 7
    local rowGap = 3
    local leftPad = 10
    local topPad = 27

    local firstRow = visible[1]
    local rowWidth = 270
    if firstRow and type(firstRow.GetWidth) == "function" then
        rowWidth = math.max(1, tonumber(firstRow:GetWidth()) or rowWidth)
    end

    local columnY = {}
    for column = 1, columns do columnY[column] = topPad end

    for index, row in ipairs(visible) do
        local column = math.floor((index - 1) / rowsPerColumn) + 1
        local y = columnY[column] or topPad
        if type(row.ClearAnchors) == "function" then row:ClearAnchors() end
        if type(row.SetAnchor) == "function" then
            row:SetAnchor(TOPLEFT, frame, TOPLEFT,
                leftPad + ((column - 1) * (rowWidth + columnGap)), y)
        end
        local rowHeight = type(row.GetHeight) == "function" and tonumber(row:GetHeight()) or nil
        rowHeight = math.max(1, rowHeight or tonumber(row.epcCompactHeight) or 32)
        columnY[column] = y + rowHeight + rowGap
    end

    local maxBottom = topPad
    for column = 1, columns do
        maxBottom = math.max(maxBottom, (columnY[column] or topPad) - rowGap)
    end
    local wantedHeight = maxBottom + 5
    if type(frame.GetHeight) == "function" and type(frame.SetHeight) == "function" then
        local current = tonumber(frame:GetHeight()) or 0
        if math.abs(current - wantedHeight) > 0.5 then frame:SetHeight(wantedHeight) end
    elseif type(frame.SetHeight) == "function" then
        frame:SetHeight(wantedHeight)
    end
end

if type(F.RefreshGroupFrames) == "function" and not F._easRaidCompanionRefreshWrapped029566 then
    F._easRaidCompanionRefreshWrapped029566 = true
    local baseRefreshGroupFrames = F.RefreshGroupFrames

    function F:RefreshGroupFrames(...)
        local result = baseRefreshGroupFrames(self, ...)
        reflowRaid(self, false)
        return result
    end
end
