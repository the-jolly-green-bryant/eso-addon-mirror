CompanionHelper = CompanionHelper
local CH = CompanionHelper

-- Dev-only right panel (shows only for @Scribe Rob)
function IsDevUser()
    return GetDisplayName() == "@Scribe Rob"
end

local function DestroyDevPanel()
    if not CH.DevPanel then return end

    -- hide it first to avoid any weirdness
    CH.DevPanel:SetHidden(true)

    -- release references so CreateDevPanel can build again
    CH.DevPanel = nil
    CH.DevPanelTitle = nil
    CH.DevPanelBody = nil
    wm = nil
    panel = nil
    bg = nil
    title = nil
    divider = nil
    body = nil
end

function CreateDevPanel()
    if CH.DevPanel then return end

    local wm = WINDOW_MANAGER

    local panel = wm:CreateTopLevelWindow("CH_DevPanel")
    panel:SetHidden(true)
    panel:SetMouseEnabled(true)
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)

    panel:SetDrawTier(DT_HIGH)
    panel:SetDrawLayer(DL_OVERLAY)
    panel:SetDrawLevel(10)

    panel:SetDimensions(360, 520)
    panel:ClearAnchors()
    panel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -20, 120)

    local bg = wm:CreateControl(nil, panel, CT_BACKDROP)
    bg:SetAnchorFill()

    -- ESO-like tooltip textures so it looks like a real UI panel
    bg:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-TooltipEdge.dds", 128, 16)
    bg:SetInsets(12, 12, -12, -12)

    -- Slight tint, not a black slab
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.85)
    bg:SetEdgeColor(1, 1, 1, 0.25)

    local title = wm:CreateControl(nil, panel, CT_LABEL)
    title:SetAnchor(TOPLEFT, panel, TOPLEFT, 16, 14)
    title:SetFont("ZoFontGamepad36")
    title:SetColor(1, 1, 1, 1)
    title:SetText("CompanionHelper (Dev)")

    local divider = wm:CreateControl(nil, panel, CT_TEXTURE)
    divider:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 10)
    divider:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -16, 0)
    divider:SetHeight(1)
    divider:SetColor(1, 1, 1, 0.15)

    local body = wm:CreateControl(nil, panel, CT_LABEL)
    body:SetAnchor(TOPLEFT, divider, BOTTOMLEFT, 0, 10)
    body:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -16, 0)
    body:SetFont("ZoFontGamepadChat")
    body:SetColor(0.92, 0.92, 0.92, 1)
    body:SetText("Hello Scribe Rob.\n\nThis is a learning panel.\n\nUse /chdev to toggle.\nUse /chdevrebuild to rebuild.")

    CH.DevPanel = panel
    CH.DevPanelTitle = title
    CH.DevPanelBody = body
end

function UpdateDevPanelVisibility()
    if not CH.DevPanel then return end
    CH.DevPanel:SetHidden(not IsDevUser())
end

SLASH_COMMANDS["/chdev"] = function()
    if not CH.DevPanel then
        CreateDevPanel()
        UpdateDevPanelVisibility()
    end

    if not IsDevUser() then
        d("Dev panel is restricted.")
        return
    end

    CH.DevPanel:SetHidden(not CH.DevPanel:IsHidden())
end

-- Option B: rebuild without /reloadui
SLASH_COMMANDS["/chdevrebuild"] = function()
    if not IsDevUser() then
        d("Dev panel is restricted.")
        return
    end

    DestroyDevPanel()
    CreateDevPanel()
    CH.DevPanel:SetHidden(false)
end