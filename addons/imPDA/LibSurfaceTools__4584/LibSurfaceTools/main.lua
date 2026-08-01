local floor = math.floor
local class = IMP_LibSurfaceTools__class
local Quadtree = IMP_LibSurfaceTools__Quadtree
local SurfaceManager = IMP_LibSurfaceTools__SurfaceManager

-- ----------------------------------------------------------------------------

local addon = {
    name = 'LibSurfaceTools'
}

local EVENT_NAMESPACE = addon.name


local function _atlasIndexToAtlasXY(atlasIndex, atlasSizeX, atlasSizeY)
    atlasIndex = atlasIndex - 1
    return atlasIndex % atlasSizeX + 1, floor(atlasIndex / atlasSizeX) + 1
end

-- local function _atlasXYToAtlasIndex(atlasX, atlasY, atlasSizeX, atlasSizeY)
--     return atlasSizeX * (atlasY - 1) + atlasX
-- end

-- local function _getTextureInsets(atlasX, atlasY, atlasSizeX, atlasSizeY)
--     if atlasY == nil then
--         atlasX, atlasY = _atlasIndexToAtlasXY(atlasX, atlasSizeX, atlasSizeY)
--     end

--     local atlasStepX, atlasStepY = 1 / atlasSizeX, 1 / atlasSizeY
--     local tiL, tiR = (atlasX - 1) * atlasStepX, atlasX * atlasStepX
--     local tiT, tiB = (atlasY - 1) * atlasStepY, atlasY * atlasStepY

--     return tiL, tiR, tiT, tiB
-- end

function GetTextureInsets(self, atlasIndex)  -- TODO: meta
    if atlasIndex == nil then
        return 0, 1, 0, 1
    else
        -- TODO: can store as precomputed values
        local atlasStepX, atlasStepY = 1 / self.atlasSizeX, 1 / self.atlasSizeY

        local atlasX, atlasY = _atlasIndexToAtlasXY(atlasIndex, self.atlasSizeX, self.atlasSizeY)

        local tiR = atlasX * atlasStepX
        local tiL = tiR - atlasStepX
        local tiB = atlasY * atlasStepY
        local tiT = tiB - atlasStepY

        return tiL, tiR, tiT, tiB
    end
end

-- ----------------------------------------------------------------------------
----[[
local RigidGrid = class()

function RigidGrid:__init(parent, name, cellW, cellH)
    self.cellW = cellW
    self.cellH = cellH

    name = name or ('$(parent)Grid' .. parent:GetNumChildren())

    local composite = CreateControl(name, parent, CT_TEXTURECOMPOSITE)
    assert(composite, 'TextureComposite was not created!')

    -- control:SetDimensions(sizeX * cellW, sizeY * cellH)
    composite:ClearAllSurfaces()
    composite:SetAnchor(TOPLEFT, parent)

    self.composite = composite

    return self
end

function RigidGrid:SetAnchor(...)
    self.composite:ClearAnchors()  -- only 1 anchor!
    self.composite:SetAnchor(...)
    return self
end

function RigidGrid:SetOffsets(offsetX, offsetY)
    self.composite:SetAnchorOffsets(offsetX, offsetY, 1)
    return self
end

function RigidGrid:SetTexture(fileName, atlasSizeX, atlasSizeY)
    atlasSizeX = atlasSizeX or 1
    atlasSizeY = atlasSizeY or 1

    self.composite:SetTexture(fileName)

    if atlasSizeX > 1 or atlasSizeY > 1 then
        self.atlas = true
        self.atlasSizeX = atlasSizeX
        self.atlasSizeY = atlasSizeY
    end

    return self
end

function RigidGrid:Add(gridX, gridY, offsetX, offsetY, w, h, atlasIndex)
    offsetX = offsetX or 0
    offsetY = offsetY or 0

    local tiL, tiR, tiT, tiB = self:GetTextureInsets(atlasIndex)

    gridX = gridX - 1
    gridY = gridY - 1

    local centerX = self.cellW * (gridX + 0.5) + offsetX
    local centerY = self.cellH * (gridY + 0.5) + offsetY

    local half_w, half_h = w/2, h/2
    local iL, iR = centerX - half_w, centerX + half_w
    local iT, iB = centerY - half_h, centerY + half_h

    local surfaceNumber = self.composite:AddSurface(tiL, tiR, tiT, tiB)
    self.composite:SetInsets(surfaceNumber, iL, iR, iT, iB)

    -- TODO: add to list
end

RigidGrid.GetTextureInsets = GetTextureInsets

function RigidGrid:Clear()
    self.composite:ClearAllSurfaces()
end

--]]
-- ----------------------------------------------------------------------------

local FlexRect = class()

function FlexRect:__init(parent, name, onMouseEnter, onMouseExit)
    -- parent = parent or addon.control
    name = name or ('$(parent)FlexRect'..parent:GetNumChildren())
    self._eventNamespace = EVENT_NAMESPACE..name

    local control = CreateControl(name, parent, CT_TEXTURECOMPOSITE)
    assert(control, 'TextureComposite was not created!')

    control:ClearAllSurfaces()
    control:SetPixelRoundingEnabled(false)
    control:SetHandler('OnUpdate', function() self:_onParentUpdate() end)
    control:SetAnchor(TOPLEFT, parent)
    -- control:SetAnchorFill(parent)

    self.composite = control
    self.parent = parent

    self.surfaceManager = SurfaceManager(control)
    self.surfaces = {}

    if onMouseEnter then
        -- df('Mouse over enabled')
        self._onMouseEnter = onMouseEnter
        self._onMouseExit = onMouseExit
        self.mouseOver = {}

        -- self.hash = {}  -- setmetatable({}, {__mode='k'})

        control:SetMouseEnabled(true)

        control:SetHandler('OnMouseEnter', function()
            -- df('Mouse over %s', name)
            EVENT_MANAGER:RegisterForUpdate(EVENT_NAMESPACE..name, 0, function()
                self:_onUpdate()
            end)
        end)

        control:SetHandler('OnMouseExit', function()
            -- df('Mouse exit %s', name)
            EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE..name)
        end)

        -- if surface hidden, need to update all previously mouse over pins, TODO: make it effectively
        control:SetHandler('OnEffectivelyHidden', function()
            self:_clearMouseOver()
        end)

        self.quadtree = Quadtree()
    end

    self.animations = {}

    return self
end

function FlexRect:_clearMouseOver()
    if not self._onMouseEnter then return end

    for surface in pairs(self.mouseOver) do
        local surfaces = self.surfaces
        local surfaceData = surfaces[surface]
        local tag = surfaceData.tag
        self._onMouseExit(tag, surface)
        self.mouseOver[surface] = nil
    end
end

function FlexRect:SetAnchor(...)
    self.composite:SetAnchor(...)
    return self
end

function FlexRect:SetTexture(fileName, atlasSizeX, atlasSizeY)
    atlasSizeX = atlasSizeX or 1
    atlasSizeY = atlasSizeY or 1

    self.composite:SetTexture(fileName)

    if atlasSizeX > 1 or atlasSizeY > 1 then
        self.atlas = true
        self.atlasSizeX = atlasSizeX
        self.atlasSizeY = atlasSizeY
    end

    return self
end

function FlexRect:SetColor(surfaceIndex, r, g, b, a)
    self.composite:SetColor(surfaceIndex, r, g, b, a)
    return self
end

function FlexRect:SetAlpha(surfaceIndex, alpha)
    self.composite:SetSurfaceAlpha(surfaceIndex, alpha)
    return self
end

function FlexRect:Add(n_x, n_y, offsetX, offsetY, w, h, atlasIndex, tag)
    local surface = self.surfaceManager:AddSurface(self:GetTextureInsets(atlasIndex))

    self:_place(surface, n_x, n_y, offsetX, offsetY, w, h)

    -- not very safe, but it should work OK until someone used it inproperly
    local surfaceData = {n_x, n_y, offsetX, offsetY, w, h, atlasIndex, 1, tag = tag}  -- added current scale
    self.surfaces[surface] = surfaceData

    if self.quadtree then
        self.quadtree:Insert(n_x, n_y, surface)
        -- self.hash[surfaceData] = surface
    end

    return surface
end

FlexRect.GetTextureInsets = GetTextureInsets

function FlexRect:_place(surface, n_x, n_y, offsetX, offsetY, w, h, scale)
    offsetX = offsetX or 0
    offsetY = offsetY or 0

    scale = scale or 1
    w, h = w * scale, h * scale

    local parent = self.parent
    local W, H = parent:GetWidth(), parent:GetHeight()

    local centerX = W * n_x + offsetX
    local centerY = H * n_y + offsetY

    local half_w, half_h = w/2, h/2
    local iL, iR = centerX - half_w, centerX + half_w
    local iT, iB = centerY - half_h, centerY + half_h
    -- local iL, iR = centerX - half_w, centerX + half_w - W
    -- local iT, iB = centerY - half_h, centerY + half_h - H

    surface:SetInsets(iL, iR, iT, iB)
end

function FlexRect:_onParentUpdate()
    if not self:_isParentSizeChanged() then return end

    for surface, s in pairs(self.surfaces) do
        -- TODO: (..., unpack(s)) vs (..., s[1], s[2], ...)
        self:_place(surface, s[1], s[2], s[3], s[4], s[5], s[6], s[8])
    end
end

function FlexRect:_isParentSizeChanged()
    local parent = self.parent

    local W, H = parent:GetWidth(), parent:GetHeight()
    if self.W == W and self.H == H then return end

    self.W, self.H = W, H
    return true
end

function FlexRect:_updateSurface(surface)
    local s = self.surfaces[surface]
    self:_place(surface, s[1], s[2], s[3], s[4], s[5], s[6], s[8])
end

function FlexRect:RemoveSurface(surface)
    if self.quadtree then
        self._onMouseExit(self.surfaces[surface].tag, surface)
        self.mouseOver[surface] = nil
        self.quadtree:Remove(surface)
    end

    self.surfaces[surface] = nil
    self.animations[surface] = nil
    surface:RemoveSurface()
end

function FlexRect:AnimateScale(surface, startScale, endScale, duration)
    self.animations[surface] = {startScale, endScale, duration/1000, GetGameTimeSeconds()}
    self:_startAnimations()
end

function FlexRect:_startAnimations()
    if self._animationInProgress then return end
    self._animationInProgress = true

    EVENT_MANAGER:RegisterForUpdate(self._eventNamespace..'Animations', 0, function()
        self:_doAnimationStep()
    end)
end

function FlexRect:_stopAnimations()
    EVENT_MANAGER:UnregisterForUpdate(self._eventNamespace..'Animations')
    self._animationInProgress = false
end

function FlexRect:_doAnimationStep()
    for surface, animationParams in pairs(self.animations) do
        local duration = animationParams[3]

        local start = animationParams[4]
        local now = GetGameTimeSeconds()
        local progress = (now - start) / duration

        if progress >= 1 then  -- TODO: something better, reuse, etc.
            progress = 1
            self.animations[surface] = nil
        end

        -- df('progress %.6f', progress)

        -- local scale = zo_deltaNormalizedLerp(animationParams[1], animationParams[2], progress)
        local scale = zo_lerp(animationParams[1], animationParams[2], progress)

        local s = self.surfaces[surface]
        s[8] = scale

        self:_place(surface, s[1], s[2], s[3], s[4], s[5], s[6], s[8])
    end

    if not next(self.animations) then
        self:_stopAnimations()
    end
end

function FlexRect:RemoveSurfacesOfKind(atlasIndex)
    -- TODO: kinda slow, make bulk delete

    if not self.atlas then return end

    local surfaces = self.surfaces
    for surface, surfaceData in pairs(surfaces) do
        if surfaceData[7] == atlasIndex then
            self:RemoveSurface(surface)
        end
    end
end

function FlexRect:Clear()
    self.composite:ClearAllSurfaces()

    self:_clearMouseOver()

    ZO_ClearTable(self.surfaces)
    ZO_ClearTable(self.animations)

    if self.quadtree then
        self.quadtree:Clear()
    end
end

function FlexRect:_onUpdate()
    local x, y = self.composite:GetLeft(), self.composite:GetTop()
    local m_x, m_y = GetUIMousePosition()

    -- TODO: width, height optimization
    local parent = self.parent
    local W, H = parent:GetWidth(), parent:GetHeight()
    local mn_x, mn_y = (m_x - x) / W, (m_y - y) / H

    -- TODO: need some arbitrary width and height...
    -- 100 px, normalize for w and h
    local n_size = 64 / W
    local results = self.quadtree:Query(mn_x, mn_y, n_size)

    -- TODO: check if result is different

    -- df('%d', #results)

    local filtered = {}
    local mr_x, mr_y = m_x - x, m_y - y
    for _, result in ipairs(results) do
        local surface = result.data
        local surfaceData = self.surfaces[surface]

        local r_x, r_y = surfaceData[1] * W + surfaceData[3], surfaceData[2] * H + surfaceData[4]
        local halfSurfaceWidth, halfSurfaceHeight = surfaceData[5] / 1.75, surfaceData[6] / 1.75  -- arbitrary selected 1.75

        if r_x + halfSurfaceWidth > mr_x and
        r_x - halfSurfaceWidth < mr_x and
        r_y - halfSurfaceHeight < mr_y and
        r_y + halfSurfaceHeight > mr_y then
            filtered[#filtered+1] = surface
        end
    end

    -- df('%d', #filtered)

    local previousMouseOver = self.mouseOver
    local mouseOver = {}
    self.mouseOver = mouseOver

    local added = {}
    local surfaces = self.surfaces

    for i = 1, #filtered do
        local surface = filtered[i]

        mouseOver[surface] = true

        if not previousMouseOver[surface] then
            added[surface] = true
        end
    end

    for surface in pairs(previousMouseOver) do
        if not mouseOver[surface] then
            local surfaceData = surfaces[surface]
            local tag = surfaceData.tag
            self._onMouseExit(tag, surface)
            self:_updateSurface(surface)
        end
    end

    for surface in pairs(added) do
        self._onMouseEnter(surfaces[surface].tag, surface)
        self:_updateSurface(surface)
    end
end

addon.Tools = {
    FlexRect = FlexRect,
    RigidGrid = RigidGrid,
}

-- ----------------------------------------------------------------------------

function addon:Initialize()
    self.control = LibSurfaceTools_TLC

    LibSurfaceTools = self
end

-- ----------------------------------------------------------------------------

local function OnAddonLoaded(_, addonName)
    if addonName ~= addon.name then return end
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED)

    addon:Initialize()
end


EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED, OnAddonLoaded)

IMP_LibSurfaceTools__Quadtree = nil
IMP_LibSurfaceTools__class = nil
IMP_LibSurfaceTools__SurfaceManager = nil
