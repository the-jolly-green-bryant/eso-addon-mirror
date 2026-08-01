local class = IMP_LibSurfaceTools__class

-- ----------------------------------------------------------------------------

local Quadtree = class()

function Quadtree:__init(capacity)
    capacity = capacity or 4

    self.root = {
        x = 0, y = 0, w = 1, h = 1,
        points = {},
        divided = false
    }
    self.capacity = capacity
    self.points = {}

    return self
end

local function _inBounds(node, x, y)
    return x >= node.x and x < node.x + node.w and y >= node.y and y < node.y + node.h
end

function Quadtree:Insert(x, y, data)
    local pt = {x = x, y = y, data = data}
    self.points[#self.points + 1] = pt
    self:_insertNode(self.root, pt)
end

function Quadtree:_insertNode(node, pt)
    if not _inBounds(node, pt.x, pt.y) then return false end
    if not node.divided and #node.points < self.capacity then
        node.points[#node.points + 1] = pt
        return true
    end
    if not node.divided then
        local hw = node.w / 2
        local hh = node.h / 2
        node.nw = {x = node.x, y = node.y, w = hw, h = hh, points = {}, divided = false}
        node.ne = {x = node.x + hw, y = node.y, w = hw, h = hh, points = {}, divided = false}
        node.sw = {x = node.x, y = node.y + hh, w = hw, h = hh, points = {}, divided = false}
        node.se = {x = node.x + hw, y = node.y + hh, w = hw, h = hh, points = {}, divided = false}
        node.divided = true
        local old = node.points
        node.points = {}
        for i = 1, #old do
            self:_insertNode(node, old[i])
        end
    end
    if _inBounds(node.nw, pt.x, pt.y) then return self:_insertNode(node.nw, pt)
    elseif _inBounds(node.ne, pt.x, pt.y) then return self:_insertNode(node.ne, pt)
    elseif _inBounds(node.sw, pt.x, pt.y) then return self:_insertNode(node.sw, pt)
    elseif _inBounds(node.se, pt.x, pt.y) then return self:_insertNode(node.se, pt)
    end
    return false
end

function Quadtree:Query(x, y, size)
    local half = size * 0.5
    local xmin, xmax = x - half, x + half
    local ymin, ymax = y - half, y + half

    local result = {}
    self:_queryNode(self.root, xmin, ymin, xmax, ymax, result)

    return result
end

function Quadtree:_queryNode(node, xmin, ymin, xmax, ymax, result)
    if node.x > xmax or node.x + node.w < xmin or node.y > ymax or node.y + node.h < ymin then
        return
    end

    if node.divided then
        self:_queryNode(node.nw, xmin, ymin, xmax, ymax, result)
        self:_queryNode(node.ne, xmin, ymin, xmax, ymax, result)
        self:_queryNode(node.sw, xmin, ymin, xmax, ymax, result)
        self:_queryNode(node.se, xmin, ymin, xmax, ymax, result)
    else
        for i = 1, #node.points do
            local pt = node.points[i]
            if pt.x >= xmin and pt.x <= xmax and pt.y >= ymin and pt.y <= ymax then
                result[#result + 1] = pt
            end
        end
    end
end

function Quadtree:Remove(id)
    for i = #self.points, 1, -1 do
        if self.points[i].data == id then
            table.remove(self.points, i)
            break
        end
    end

    self:_removeNode(self.root, id)
end

function Quadtree:_removeNode(node, id)
    if not node.divided then
        for i = #node.points, 1, -1 do
            if node.points[i].data == id then
                table.remove(node.points, i)
                return true
            end
        end
        return false
    end

    return self:_removeNode(node.nw, id)
        or self:_removeNode(node.ne, id)
        or self:_removeNode(node.sw, id)
        or self:_removeNode(node.se, id)
end

function Quadtree:Clear()
    self.root = {x = 0, y = 0, w = 1, h = 1, points = {}, divided = false}
    self.points = {}
end

-- function Quadtree:Rebuild(pointList)
--     self:Clear()

--     for i = 1, #pointList do
--         local p = pointList[i]
--         self:Insert(p.x, p.y, p.data)
--     end
-- end

IMP_LibSurfaceTools__Quadtree = Quadtree
