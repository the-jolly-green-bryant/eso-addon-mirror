-- -----------------------------------------------------------------------------
-- HUDGridSnap — grid overlay (adapted from LuiExtended GridOverlay)
-- -----------------------------------------------------------------------------

local DEFAULT_GRID_SIZE = 15
local OVERLAY_CONTROL_NAME = "HUDGridSnap_Overlay"
local LINE_TEMPLATE_V = "HUDGridSnap_Overlay_Line_V"
local LINE_TEMPLATE_H = "HUDGridSnap_Overlay_Line_H"
local EDITOR_SCENE_NAME = "hud_editor_keyboard"

local GRID_COLOR =
{
    r = 0.1,
    g = 0.7,
    b = 0.9,
    a = 0.35,
}

local windowManager = GetWindowManager()
local sceneManager = SCENE_MANAGER
local zo_floor = zo_floor
local zo_round = zo_round

local function ResetLine(line)
    line:ClearAnchors()
    line:SetHidden(true)
end

local function ApplyLineStyle(line)
    line:SetDrawLayer(DL_BACKGROUND)
    line:SetDrawTier(DT_LOW)
    line:SetDrawLevel(2)
    line:SetColor(GRID_COLOR.r, GRID_COLOR.g, GRID_COLOR.b, GRID_COLOR.a)
    line:SetThickness(1)
end

local Overlay = ZO_DeferredInitializingObject:Subclass()

function Overlay:Initialize(fragment, control)
    ZO_DeferredInitializingObject.Initialize(self, fragment)
    self.control = control
    self.fragment = fragment
    self.size = DEFAULT_GRID_SIZE
    self:OnDeferredInitialize()
end

function Overlay:OnDeferredInitialize()
    local parentControl = self.control
    local function verticalLineFactory(objectPool, objectKey)
        return ZO_ObjectPool_CreateControl(LINE_TEMPLATE_V, objectPool, parentControl)
    end
    local function horizontalLineFactory(objectPool, objectKey)
        return ZO_ObjectPool_CreateControl(LINE_TEMPLATE_H, objectPool, parentControl)
    end
    self.verticalPool = ZO_ObjectPool:New(verticalLineFactory, ResetLine)
    self.verticalPool:SetCustomFactoryBehavior(ApplyLineStyle)
    self.verticalPool:SetCustomAcquireBehavior(function (line)
        line:SetHidden(false)
    end)

    self.horizontalPool = ZO_ObjectPool:New(horizontalLineFactory, ResetLine)
    self.horizontalPool:SetCustomFactoryBehavior(ApplyLineStyle)
    self.horizontalPool:SetCustomAcquireBehavior(function (line)
        line:SetHidden(false)
    end)
end

function Overlay:AddFragmentToEditorScene()
    local scene = sceneManager:GetScene(EDITOR_SCENE_NAME)
    if not scene:HasFragment(self.fragment) then
        scene:AddFragment(self.fragment)
    end
end

function Overlay:RemoveFragmentFromEditorScene()
    sceneManager:GetScene(EDITOR_SCENE_NAME):RemoveFragment(self.fragment)
end

function Overlay:OnShowing()
    self:UpdateLines(self.size)
end

function Overlay:AcquireLine(objectPool, objectKey)
    return select(1, objectPool:AcquireObject(objectKey))
end

function Overlay:ReleaseUnused(objectPool, maxRetainedKey)
    local activeObjects = objectPool:GetActiveObjects()
    for objectKey in pairs(activeObjects) do
        if objectKey > maxRetainedKey then
            objectPool:ReleaseObject(objectKey)
        end
    end
end

function Overlay:ReleaseAll()
    self.verticalPool:ReleaseAllObjects()
    self.horizontalPool:ReleaseAllObjects()
end

function Overlay:UpdateLines(gridSize)
    local rootWidth = GuiRoot:GetWidth()
    local rootHeight = GuiRoot:GetHeight()

    local verticalLineCount = zo_floor(rootWidth / gridSize)
    for lineIndex = 0, verticalLineCount do
        local offsetX = zo_round(lineIndex * gridSize)
        local line = self:AcquireLine(self.verticalPool, lineIndex)
        line:ClearAnchors()
        line:SetAnchor(TOPLEFT, self.control, TOPLEFT, offsetX, 0)
        line:SetAnchor(BOTTOMLEFT, self.control, BOTTOMLEFT, offsetX, 0)
    end
    self:ReleaseUnused(self.verticalPool, verticalLineCount)

    local horizontalLineCount = zo_floor(rootHeight / gridSize)
    for lineIndex = 0, horizontalLineCount do
        local offsetY = zo_round(lineIndex * gridSize)
        local line = self:AcquireLine(self.horizontalPool, lineIndex)
        line:ClearAnchors()
        line:SetAnchor(TOPLEFT, self.control, TOPLEFT, 0, offsetY)
        line:SetAnchor(TOPRIGHT, self.control, TOPRIGHT, 0, offsetY)
    end
    self:ReleaseUnused(self.horizontalPool, horizontalLineCount)
end

function Overlay:Hide()
    self:ReleaseAll()
    self:RemoveFragmentFromEditorScene()
    self.control:SetHidden(true)
end

function Overlay:Refresh(visible, size)
    self.size = size
    if not visible then
        self:Hide()
        return
    end
    self:AddFragmentToEditorScene()
    self.control:SetHidden(false)
    self:UpdateLines(self.size)
end

local sharedOverlay

local function GetOverlay()
    if not sharedOverlay then
        local control = windowManager:GetControlByName(OVERLAY_CONTROL_NAME)
        control:SetAnchorFill(GuiRoot)
        control:SetDrawLayer(DL_BACKGROUND)
        control:SetDrawTier(DT_LOW)
        control:SetDrawLevel(0)
        control:SetAlpha(1)
        control:SetMouseEnabled(false)
        control:SetMovable(false)
        control:SetHidden(true)
        control:SetClampedToScreen(false)
        sharedOverlay = Overlay:New(ZO_SimpleSceneFragment:New(control), control)
    end
    return sharedOverlay
end

function HUDGridSnap.RefreshGridOverlay()
    local sv = HUDGridSnap.SV
    GetOverlay():Refresh(HUDGridSnap.IsEditorShowing() and sv.showGrid, sv.gridSize)
end

function HUDGridSnap.HideGridOverlay()
    GetOverlay():Hide()
end