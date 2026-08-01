---@class KFS_GridOverlay
---@field control userdata Top-level overlay window control
---@field verticalLinePool table ZO_ObjectPool for vertical lines
---@field horizontalLinePool table ZO_ObjectPool for horizontal lines
---@field activeVerticalLines table<any, any> Map of active vertical line keys
---@field activeHorizontalLines table<any, any> Map of active horizontal line keys
---@field size number Current grid size in pixels
local GridOverlay = {};
GridOverlay.__index = GridOverlay;

local wm = GetWindowManager();

local GRID_COLOR =
{
    r = 0.1;
    g = 0.7;
    b = 0.9;
    a = 0.35;
};

---Creates line factory function
---@param parentControl userdata
---@return fun():LineControl
local function CreateLineFactory(parentControl)
    return function ()
        local line = wm:CreateControl(nil, parentControl, CT_LINE);
        line:SetDrawLayer(DL_OVERLAY);
        line:SetDrawTier(DT_LOW);
        line:SetDrawLevel(2);
        line:SetColor(GRID_COLOR.r, GRID_COLOR.g, GRID_COLOR.b, GRID_COLOR.a);
        line:SetThickness(1);
        return line;
    end;
end;

---Resets line to hidden state
---@param line LineControl
local function ResetLine(line)
    line:SetHidden(true);
    line:ClearAnchors();
end;

---Releases all active line keys tracked by a pool
---@param pool ZO_ObjectPool|nil
---@param activeLineMap table<any, any>?
local function ReleaseActiveLines(pool, activeLineMap)
    if not pool or not activeLineMap then
        return;
    end;

    for lineKey in IterateTables(pairs, activeLineMap) do
        pool:ReleaseObject(lineKey);
    end;

    ZO_ClearTable(activeLineMap);
end;

---Creates new GridOverlay
---@return KFS_GridOverlay
function GridOverlay:New()
    local overlay =
    {
        control = nil;
        verticalLinePool = nil;
        horizontalLinePool = nil;
        activeVerticalLines = {};
        activeHorizontalLines = {};
        size = 0;
    };

    return setmetatable(overlay, self);
end;

---Ensures control is created
function GridOverlay:EnsureControl()
    if self.control then
        return;
    end;

    local control = wm:CreateTopLevelWindow("KhajiitFengShuiGridOverlay");
    control:SetAnchorFill(GuiRoot);
    control:SetDrawLayer(DL_OVERLAY);
    control:SetDrawTier(DT_LOW);
    control:SetDrawLevel(1);
    control:SetAlpha(1);
    control:SetMouseEnabled(false);
    control:SetMovable(false);
    control:SetHidden(true);
    control:SetClampedToScreen(false);

    self.control = control;
    self.verticalLinePool = ZO_ObjectPool:New(CreateLineFactory(control), ResetLine);
    self.horizontalLinePool = ZO_ObjectPool:New(CreateLineFactory(control), ResetLine);
end;

---Updates grid lines for given size
---@param size number
function GridOverlay:UpdateLines(size)
    if not self.control or not self.verticalLinePool or not self.horizontalLinePool then
        return;
    end;

    ReleaseActiveLines(self.verticalLinePool, self.activeVerticalLines);
    ReleaseActiveLines(self.horizontalLinePool, self.activeHorizontalLines);

    local rootWidth = GuiRoot:GetWidth() or 0;
    local rootHeight = GuiRoot:GetHeight() or 0;

    local verticalCount = zo_floor(rootWidth / size);
    for i = 0, verticalCount do
        local offsetX = zo_round(i * size);
        local line, lineKey = self.verticalLinePool:AcquireObject();
        line:SetHidden(false);
        local anchorTop = ZO_Anchor:New(TOPLEFT, self.control, TOPLEFT, offsetX, 0);
        local anchorBottom = ZO_Anchor:New(BOTTOMLEFT, self.control, BOTTOMLEFT, offsetX, 0);
        anchorTop:Set(line);
        anchorBottom:AddToControl(line);
        self.activeVerticalLines[lineKey] = lineKey;
    end;

    local horizontalCount = math.floor(rootHeight / size);
    for i = 0, horizontalCount do
        local offsetY = zo_round(i * size);
        local line, lineKey = self.horizontalLinePool:AcquireObject();
        line:SetHidden(false);
        local anchorLeft = ZO_Anchor:New(TOPLEFT, self.control, TOPLEFT, 0, offsetY);
        local anchorRight = ZO_Anchor:New(TOPRIGHT, self.control, TOPRIGHT, 0, offsetY);
        anchorLeft:Set(line);
        anchorRight:AddToControl(line);
        self.activeHorizontalLines[lineKey] = lineKey;
    end;
end;

---Hides grid overlay
function GridOverlay:Hide()
    if not self.control then
        return;
    end;

    self.control:SetHidden(true);

    if self.verticalLinePool then
        self.verticalLinePool:ReleaseAllObjects();
        ZO_ClearTable(self.activeVerticalLines);
    end;

    if self.horizontalLinePool then
        self.horizontalLinePool:ReleaseAllObjects();
        ZO_ClearTable(self.activeHorizontalLines);
    end;
end;

---Refreshes grid visibility and size
---@param visible boolean
---@param size number?
function GridOverlay:Refresh(visible, size)
    self.size = size or self.size;
    if not visible or not size or size <= 0 then
        self:Hide();
        return;
    end;

    self:EnsureControl();
    self.control:SetHidden(false);
    self:UpdateLines(size);
end;

KhajiitFengShui.GridOverlay = GridOverlay;
