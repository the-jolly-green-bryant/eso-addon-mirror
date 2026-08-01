-- global namspacing
PITHKA = PITHKA or {} 
PITHKA.layout = PITHKA.layout or {}
PITHKA.layout.grid = {}

-- convenient namespacing
local grid = PITHKA.layout.grid
local api = PITHKA.common.api

---------------------------------------------------------------------------------------------------------
-- Grid
---------------------------------------------------------------------------------------------------------

-- Define the Grid class
grid.__index = grid

-- Constructor for Grid
function grid.new(xOffset, yOffset, relativeObject, alignment)
    local self = setmetatable({}, grid)
    local xOffset = xOffset or 0
    local yOffset = yOffset or 0
    local alignment = alignment or TOPLEFT
    local relativeObject = relativeObject or PITHKA_GUI
    
    -- create anchor for grid
    self.anchor = api.control.newLabel()
    self.anchor:SetDimensions(1,1)
	self.anchor:SetAnchor(alignment, relativeObject, alignment, xOffset, yOffset)

    -- create rows and initialize previousRow to anchor
    self.rows = {}
    self.prevRow = self.anchor
    
    return self
end

-- Add row method
function grid:addRow(objects)
    local row = {}

    for i, obj in ipairs(objects) do
        if i == 1 then
            -- if first item in row then anchor to previous row
            obj:SetAnchor(TOPLEFT, self.prevRow, BOTTOMLEFT, 0, 3)
            -- update previous row so subsequent rows stack below
            self.prevRow = obj
        else
            -- other anchor to previous object in the row
            local prevObject = row[#row]
            obj:SetAnchor(LEFT, prevObject, RIGHT, 3, 0)
        end
        -- add oject to row
        table.insert(row, obj)
    end
    
    -- add row to grid
    table.insert(self.rows, row)
end

-- setHidden method
function grid:setHidden(hidden)
    for _, row in ipairs(self.rows) do
        for _, obj in ipairs(row) do
            obj:SetHidden(hidden)
        end
    end
end

return grid