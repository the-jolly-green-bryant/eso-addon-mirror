-- screen dimensions
local uiW, uiH = GuiRoot:GetDimensions()

local TICKRATE = 10 -- milisecs. higher - reduse load, lower - increase "fps"

local MAX_DISTANCE = 6500
local MIN_FADE_DISTANCE = 3000
local MIN_FADE_OPACITY = 0.2

-------------------------------------
--Base Obj--
-------------------------------------
Lib3dObjectBase = ZO_Object:Subclass()
function Lib3dObjectBase:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function Lib3dObjectBase:Initialize(control)
    self.control = control
    self.baseAlpha = control:GetAlpha()
    for i = 1, self.control:GetNumChildren() do
        self.control:GetChild(i):SetDrawLayer(self.control:GetDrawLayer())
    end
    self.maxDistance = MAX_DISTANCE
    self.minFadeDistance = MIN_FADE_DISTANCE
    self.minFadeOpacity = MIN_FADE_OPACITY
end

function Lib3dObjectBase:OnAttach(parent)
    self.parent = parent
    self.control:SetParent(parent)
    self.control:ClearAnchors()
    self.control:SetHidden(true)
end

function Lib3dObjectBase:OnDetach()
    self.parent = nil
    self.control:ClearAnchors()
    self.control:SetHidden(true)
end

function Lib3dObjectBase:SetMaxDistance(value)
    self.maxDistance = value
end

function Lib3dObjectBase:SetMinFadeDistance(value)
    self.minFadeDistance = value
end

function Lib3dObjectBase:SetMinFadeOpacity(value)
    self.minFadeOpacity = value
end

function Lib3dObjectBase:GetPosition()
    d("GetPosition method must be implemented in subclass!")
end

function Lib3dObjectBase:OnShow()
end
function Lib3dObjectBase:OnHide()
end

function Lib3dObjectBase:Update(cX, cY, cZ, i11, i12, i13, i21, i22, i23, i31, i32, i33, i41, i42, i43)
    local selfX, selfY, selfZ = self:GetPosition()
    -- calculate unit view position
    local pX = selfX * i11 + selfY * i21 + selfZ * i31 + i41
    local pY = selfX * i12 + selfY * i22 + selfZ * i32 + i42
    local pZ = selfX * i13 + selfY * i23 + selfZ * i33 + i43

    -- if unit is in front
    if pZ > 0 then
        -- calculate unit screen position
        local w, h = GetWorldDimensionsOfViewFrustumAtDepth(pZ)
        local x, y = pX * uiW / w, -pY * uiH / h

        -- distance
        local dist = 1 + zo_distance3D(selfX, selfY, selfZ, cX, cY, cZ)

        if dist < self.maxDistance then
            self.control:SetScale(1000 / dist)

            -- position
            self.control:SetAnchor(BOTTOM, self.parent, CENTER, x, y)

            -- opacity
            local alpha = zo_clampedPercentBetween(self.maxDistance, self.minFadeDistance, dist)
            self.control:SetAlpha(self.baseAlpha * zo_max(self.minFadeOpacity, alpha))

            -- z-order
            local zIndex = ZO_ABOVE_SCENEGRAPH_DRAW_LEVEL - zo_round(dist)
            self.control:SetDrawLevel(zIndex)
            for i = 1, self.control:GetNumChildren() do
                self.control:GetChild(i):SetDrawLevel(zIndex)
            end

            if self.control:IsHidden() then
                self.control:SetHidden(false)
                self:OnShow()
            end
        elseif not self.control:IsHidden() then
            self.control:SetHidden(true)
            self:OnHide()
        end
    elseif not self.control:IsHidden() then
        self.control:SetHidden(true)
        self:OnHide()
    end
end
-------------------------------------
--Coordinates (ground) based--
-------------------------------------
Lib3dObjectCoord = Lib3dObjectBase:Subclass()
function Lib3dObjectCoord:New(...)
    return Lib3dObjectBase.New(self, ...)
end
function Lib3dObjectCoord:Initialize(control, x, y, z)
    self.x = x
    self.y = y
    self.z = z
    Lib3dObjectBase.Initialize(self, control)
end
function Lib3dObjectCoord:GetPosition()
    return self.x, self.y, self.z
end
-------------------------------------
-- Works only for unitTags: player, groupX
-------------------------------------
Lib3dObjectUnit = Lib3dObjectBase:Subclass()
function Lib3dObjectUnit:New(...)
    return Lib3dObjectBase.New(self, ...)
end
function Lib3dObjectUnit:Initialize(control, unitTag)
    self.unitTag = unitTag
    Lib3dObjectBase.Initialize(self, control)
end
function Lib3dObjectUnit:GetPosition()
    local _, x, y, z = GetUnitRawWorldPosition(self.unitTag)
    return x, y, z
end
-------------------------------------
--Manager--
-------------------------------------
local ObjectPool = ZO_Object:Subclass()
function ObjectPool:New()
    local obj = ZO_Object.New(self)
    obj.pool = {}
    return obj
end

do
    local Lib3dOCtrl, Lib3dOWin
    local function InitUI()
        -- create render space control
        local ctrl = CreateControl("Lib3dOCtrl", GuiRoot, CT_CONTROL)
        ctrl:SetAnchorFill(GuiRoot)
        ctrl:Create3DRenderSpace()
        ctrl:SetHidden(true)

        -- create parent window for icons
        local win = CreateTopLevelWindow("Lib3dOWin")
        win:SetClampedToScreen(true)
        win:SetMouseEnabled(false)
        win:SetMovable(false)
        win:SetAnchorFill(GuiRoot)
        win:SetDrawLayer(DL_BACKGROUND)
        win:SetDrawTier(DT_LOW)
        win:SetDrawLevel(0)

        -- create parent window scene fragment
        local frag = ZO_HUDFadeSceneFragment:New(win)
        HUD_UI_SCENE:AddFragment(frag)
        HUD_SCENE:AddFragment(frag)
        LOOT_SCENE:AddFragment(frag)

        Lib3dOCtrl = ctrl
        Lib3dOWin = win
    end
    function ObjectPool:OnUpdate()
        -- looks like Set3DRenderSpaceToCurrentCamera must be called every time before GuiRender3DPositionToWorldPosition
        Set3DRenderSpaceToCurrentCamera(Lib3dOCtrl:GetName())
        -- retrieve camera world position and orientation vectors
        local cX, cY, cZ = GuiRender3DPositionToWorldPosition(Lib3dOCtrl:Get3DRenderSpaceOrigin())
        local fX, fY, fZ = Lib3dOCtrl:Get3DRenderSpaceForward()
        local rX, rY, rZ = Lib3dOCtrl:Get3DRenderSpaceRight()
        local uX, uY, uZ = Lib3dOCtrl:Get3DRenderSpaceUp()

        -- https://semath.info/src/inverse-cofactor-ex4.html
        -- calculate determinant for camera matrix
        -- local det = rX * uY * fZ - rX * uZ * fY - rY * uX * fZ + rZ * uX * fY + rY * uZ * fX - rZ * uY * fX
        -- local mul = 1 / det
        -- determinant should always be -1
        -- instead of multiplying simply negate
        -- calculate inverse camera matrix
        local i11 = -(uY * fZ - uZ * fY)
        local i12 = -(rZ * fY - rY * fZ)
        local i13 = -(rY * uZ - rZ * uY)
        local i21 = -(uZ * fX - uX * fZ)
        local i22 = -(rX * fZ - rZ * fX)
        local i23 = -(rZ * uX - rX * uZ)
        local i31 = -(uX * fY - uY * fX)
        local i32 = -(rY * fX - rX * fY)
        local i33 = -(rX * uY - rY * uX)
        local i41 = -(uZ * fY * cX + uY * fX * cZ + uX * fZ * cY - uX * fY * cZ - uY * fZ * cX - uZ * fX * cY)
        local i42 = -(rX * fY * cZ + rY * fZ * cX + rZ * fX * cY - rZ * fY * cX - rY * fX * cZ - rX * fZ * cY)
        local i43 = -(rZ * uY * cX + rY * uX * cZ + rX * uZ * cY - rX * uY * cZ - rY * uZ * cX - rZ * uX * cY)

        for i = #self.pool, 1, -1 do
            self.pool[i]:Update(cX, cY, cZ, i11, i12, i13, i21, i22, i23, i31, i32, i33, i41, i42, i43)
        end
    end

    local LazyInited = false
    function ObjectPool:LazyInit()
        if not LazyInited then
            LazyInited = true
            InitUI()
            uiW, uiH = GuiRoot:GetDimensions()
            EVENT_MANAGER:RegisterForEvent("Lib3dObject", EVENT_SCREEN_RESIZED, function()
                uiW, uiH = GuiRoot:GetDimensions()
            end)
        end
    end
    function ObjectPool:Attach(obj)
        self:LazyInit()
        if #self.pool == 0 then
            EVENT_MANAGER:RegisterForUpdate("Lib3dObject", TICKRATE, function()
                self:OnUpdate()
            end)
        end
        obj:OnAttach(Lib3dOWin)
        obj.poolIndex = #self.pool + 1
        self.pool[obj.poolIndex] = obj
    end
    function ObjectPool:Detach(obj)
        if obj.poolIndex and self.pool[obj.poolIndex] then
            obj:OnDetach()
            self.pool[obj.poolIndex] = nil
            obj.poolIndex = nil
        end
        if #self.pool == 0 then
            EVENT_MANAGER:UnregisterForUpdate("Lib3dObject")
        end
    end
end

Lib3dObjectManager = ObjectPool:New()