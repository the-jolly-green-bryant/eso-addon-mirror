ValknarrUIEGrid = ValknarrUIEGrid or {}

local Grid = ValknarrUIEGrid
local Log = ValknarrUIELog
local Store = ValknarrUIELayoutStore
local Safe = ValknarrUIESafe

local DEFAULTS = {
    divisionsX = 40,
    divisionsY = 22,
    margin = 0.03,
    lineAlpha = 0.22,
}

-- Size bounds. Cell-relative values keep the original feel at the default
-- 40x22 grid. The absolute fractions are a backstop: saved grid settings allow
-- as few as 4 divisions, where 32 cells would be eight screens wide.
local SIZE_CELLS = {
    minW = 2,
    maxW = 32,
    minH = 0.75,
    maxH = 15,
}

local SIZE_FRACTION = {
    minW = 0.02,
    maxW = 0.80,
    minH = 0.015,
    maxH = 0.70,
}

local PRECISION_FACTOR = 0.25

local function Clamp(value, low, high)
    if value < low then
        return low
    end
    if value > high then
        return high
    end
    return value
end

local function SnapToStep(value, step)
    return math.floor((value / step) + 0.5) * step
end

-- Pull a bound onto the active lattice before clamping, so the clamped result
-- is still a whole number of steps. A 0.75-cell floor cannot exist on the
-- coarse lattice, so there it becomes one whole cell; precision mode keeps it.
local function ClampToStep(value, step, low, high)
    local lo = math.ceil((low / step) - 1e-9) * step
    local hi = math.floor((high / step) + 1e-9) * step
    if hi < lo then
        hi = lo
    end
    return Clamp(value, lo, hi)
end

-- Active grid config: SavedVars when present, else built-in defaults.
function Grid:Settings()
    if Store and type(Store.GetGrid) == "function" then
        local grid = Store:GetGrid()
        if type(grid) == "table" then
            return grid
        end
    end
    return DEFAULTS
end

function Grid:CellSize()
    local settings = self:Settings()
    return 1 / settings.divisionsX, 1 / settings.divisionsY
end

-- Step used for one stick press. Move and resize share it so both react to
-- the precision toggle identically.
function Grid:Step(precision)
    local cellX, cellY = self:CellSize()
    if precision then
        return cellX * PRECISION_FACTOR, cellY * PRECISION_FACTOR
    end
    return cellX, cellY
end

function Grid:SizeLimits()
    local cellX, cellY = self:CellSize()
    local minW = math.max(SIZE_CELLS.minW * cellX, SIZE_FRACTION.minW)
    local maxW = math.min(SIZE_CELLS.maxW * cellX, SIZE_FRACTION.maxW)
    local minH = math.max(SIZE_CELLS.minH * cellY, SIZE_FRACTION.minH)
    local maxH = math.min(SIZE_CELLS.maxH * cellY, SIZE_FRACTION.maxH)
    if minW > maxW then
        minW = maxW
    end
    if minH > maxH then
        minH = maxH
    end
    return minW, maxW, minH, maxH
end

function Grid:SnapValue(value, divisions, precision)
    local settings = self:Settings()
    local cell = 1 / divisions
    if precision then
        cell = cell * PRECISION_FACTOR
    end
    return Clamp(SnapToStep(value, cell), settings.margin, 1 - settings.margin)
end

function Grid:Snap(position, precision)
    if type(position) ~= "table" then
        return
    end
    local settings = self:Settings()
    position.x = self:SnapValue(position.x or 0.5, settings.divisionsX, precision)
    position.y = self:SnapValue(position.y or 0.5, settings.divisionsY, precision)
end

-- Width and height only. Absent values stay absent: the editor decides what
-- an unmeasured element should start at.
function Grid:SnapSize(position, precision)
    if type(position) ~= "table" then
        return
    end
    local stepX, stepY = self:Step(precision)
    local minW, maxW, minH, maxH = self:SizeLimits()
    if type(position.w) == "number" then
        position.w = ClampToStep(SnapToStep(position.w, stepX), stepX, minW, maxW)
    end
    if type(position.h) == "number" then
        position.h = ClampToStep(SnapToStep(position.h, stepY), stepY, minH, maxH)
    end
end

-- Position and size together. Used when a rect comes from measuring a live
-- HUD control, where the pixel dimensions are arbitrary reals.
function Grid:SnapRect(position, precision)
    self:Snap(position, precision)
    self:SnapSize(position, precision)
end

-- Nearest peer within half a cell, so the alignment guide latches onto the
-- element the player is actually lining up with rather than whichever peer
-- happened to come last in registration order.
function Grid:AlignAxis(value, others, axis)
    local cellX, cellY = self:CellSize()
    local radius = ((axis == "x") and cellX or cellY) * 0.5
    local best = value
    local bestDistance = nil
    for index = 1, #others do
        local other = others[index][axis]
        if other then
            local distance = math.abs(other - value)
            if distance <= radius and (bestDistance == nil or distance < bestDistance) then
                best = other
                bestDistance = distance
            end
        end
    end
    return best, bestDistance ~= nil
end

local function CreateLine(name, parent, alpha)
    local line = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    line:SetCenterColor(1, 0.85, 0.35, alpha or DEFAULTS.lineAlpha)
    line:SetEdgeColor(0, 0, 0, 0)
    line:SetDrawLayer(DL_BACKGROUND)
    line:SetDrawTier(DT_LOW)
    line:SetHidden(true)
    line:SetMouseEnabled(false)
    return line
end

function Grid:CreateOverlay(parent)
    if self.created or not WINDOW_MANAGER or not parent then
        return
    end

    local settings = self:Settings()
    self.root = WINDOW_MANAGER:CreateControl("ValknarrUIEGridRoot", parent, CT_CONTROL)
    self.root:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    self.root:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0)
    self.root:SetHidden(true)
    self.root:SetMouseEnabled(false)

    self.vLines = {}
    self.hLines = {}
    -- Draw every other cell to keep control count modest on console.
    local vCount = math.floor(settings.divisionsX / 2)
    local hCount = math.floor(settings.divisionsY / 2)
    for index = 1, vCount do
        self.vLines[index] = CreateLine("ValknarrUIEGridV" .. index, self.root, settings.lineAlpha or DEFAULTS.lineAlpha)
    end
    for index = 1, hCount do
        self.hLines[index] = CreateLine("ValknarrUIEGridH" .. index, self.root, settings.lineAlpha or DEFAULTS.lineAlpha)
    end

    self.guideV = CreateLine("ValknarrUIEGuideV", self.root, 0.55)
    self.guideH = CreateLine("ValknarrUIEGuideH", self.root, 0.55)
    self.guideV:SetCenterColor(0.4, 0.85, 1, 0.55)
    self.guideH:SetCenterColor(0.4, 0.85, 1, 0.55)
    self.guideV:SetDrawLayer(DL_CONTROLS)
    self.guideH:SetDrawLayer(DL_CONTROLS)

    self.created = true
    self.layoutWidth = nil
    self.layoutHeight = nil
    if Log then
        Log:Debug(string.format("Grid overlay created (%d x %d lines)", vCount, hCount))
    end
end

function Grid:LayoutLines(width, height)
    if not self.created or not width or not height then
        return
    end
    -- RefreshOverlay calls this on every stick repeat, but the lines only move
    -- when the screen size changes. Re-anchoring 31 controls ~11 times a second
    -- was pure waste against the shared frame budget.
    if self.layoutWidth == width and self.layoutHeight == height then
        return
    end
    self.layoutWidth = width
    self.layoutHeight = height
    local vCount = #self.vLines
    local hCount = #self.hLines
    for index = 1, vCount do
        local x = (index / (vCount + 1)) * width
        local line = self.vLines[index]
        Safe.Call(line, "ClearAnchors")
        Safe.Call(line, "SetAnchor", TOPLEFT, self.root, TOPLEFT, x, 0)
        Safe.Call(line, "SetDimensions", 1, height)
    end
    for index = 1, hCount do
        local y = (index / (hCount + 1)) * height
        local line = self.hLines[index]
        Safe.Call(line, "ClearAnchors")
        Safe.Call(line, "SetAnchor", TOPLEFT, self.root, TOPLEFT, 0, y)
        Safe.Call(line, "SetDimensions", width, 1)
    end
end

function Grid:SetVisible(visible)
    if self.root then
        self.root:SetHidden(not visible)
    end
    local hideLines = not visible
    for index = 1, #(self.vLines or {}) do
        self.vLines[index]:SetHidden(hideLines)
    end
    for index = 1, #(self.hLines or {}) do
        self.hLines[index]:SetHidden(hideLines)
    end
    if hideLines then
        self:HideGuides()
    end
end

function Grid:HideGuides()
    if self.guideV then
        self.guideV:SetHidden(true)
    end
    if self.guideH then
        self.guideH:SetHidden(true)
    end
end

function Grid:UpdateGuides(selected, others, width, height, visible)
    if not self.created or not visible or not selected or not width then
        self:HideGuides()
        return
    end

    local alignX, matchX = self:AlignAxis(selected.x, others, "x")
    local alignY, matchY = self:AlignAxis(selected.y, others, "y")

    if matchX then
        Safe.Call(self.guideV, "ClearAnchors")
        Safe.Call(self.guideV, "SetAnchor", TOPLEFT, self.root, TOPLEFT, alignX * width, 0)
        Safe.Call(self.guideV, "SetDimensions", 2, height)
        self.guideV:SetHidden(false)
    else
        self.guideV:SetHidden(true)
    end

    if matchY then
        Safe.Call(self.guideH, "ClearAnchors")
        Safe.Call(self.guideH, "SetAnchor", TOPLEFT, self.root, TOPLEFT, 0, alignY * height)
        Safe.Call(self.guideH, "SetDimensions", width, 2)
        self.guideH:SetHidden(false)
    else
        self.guideH:SetHidden(true)
    end
end

return Grid
