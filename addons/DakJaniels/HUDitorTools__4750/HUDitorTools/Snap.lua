-- -----------------------------------------------------------------------------
-- HUDitorTools - GridSnap — grid snap helpers (adapted from LuiExtended)
-- -----------------------------------------------------------------------------

local zo_floor = zo_floor
local HT       = HUDitorTools


function HT.SnapToGrid(position, gridSize)
    position = zo_floor(position)
    if (position % gridSize >= gridSize / 2) then
        return position + (gridSize - (position % gridSize))
    end
    return position - (position % gridSize)
end
local snapToGrid = HT.SnapToGrid

function HT.ApplySnap(left, top, gridSize)
    return snapToGrid(left, gridSize), snapToGrid(top, gridSize)
end