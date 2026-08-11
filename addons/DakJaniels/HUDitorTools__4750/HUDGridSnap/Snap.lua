-- -----------------------------------------------------------------------------
-- HUDGridSnap — grid snap helpers (adapted from LuiExtended)
-- -----------------------------------------------------------------------------

local zo_floor = zo_floor

function HUDGridSnap.SnapToGrid(position, gridSize)
    position = zo_floor(position)
    if (position % gridSize >= gridSize / 2) then
        return position + (gridSize - (position % gridSize))
    end
    return position - (position % gridSize)
end

function HUDGridSnap.ApplySnap(left, top, gridSize)
    return HUDGridSnap.SnapToGrid(left, gridSize), HUDGridSnap.SnapToGrid(top, gridSize)
end