local addon = SquirrelSlayer
addon.Services.Hud = addon.Services.Hud or {}
local Hud = addon.Services.Hud

local hudControls = {}

local HOVER_LEFT_PADDING = 8
local HOVER_RIGHT_PADDING = 14
local HOVER_TOP_PADDING = 10
local HOVER_BOTTOM_PADDING = 10

local MENU_ICON_WIDTH = 64
local MENU_ICON_HEIGHT = 64

--- Raccourci vers les SavedVariables.
--- @return table|nil
local function GetSavedVariables()
    return addon.State.GetSV()
end

--- Calcule un facteur d'échelle automatique selon la largeur écran.
--- @return number uiScale
local function ComputeAutoScale()
    local screenWidth = select(1, GuiRoot:GetDimensions())
    local referenceWidth = 3840
    if not screenWidth or screenWidth <= 0 then return 1.0 end
    return screenWidth / referenceWidth
end

--- Affiche/masque le menu contextuel du HUD.
--- @param shouldShow boolean
local function SetContextMenuVisible(shouldShow)
    if not hudControls.menu then return end
    hudControls.menu:SetHidden(not shouldShow)
end

--- Recalcule les ancrages du menu et de la zone de survol étendue.
--- @param menuOffset number
--- @param menuWidth number
--- @param leftPadding number
--- @param rightPadding number
--- @param topPadding number
--- @param bottomPadding number
local function RefreshAnchors(menuOffset, menuWidth, leftPadding, rightPadding, topPadding, bottomPadding)
    if hudControls.menu and hudControls.frame then
        hudControls.menu:ClearAnchors()
        hudControls.menu:SetAnchor(TOPLEFT, hudControls.frame, TOPRIGHT, menuOffset, topPadding)
    end

    if hudControls.hoverZone and hudControls.frame then
        local rightExtension = menuWidth + menuOffset + rightPadding
        hudControls.hoverZone:ClearAnchors()
        hudControls.hoverZone:SetAnchor(TOPLEFT, hudControls.frame, TOPLEFT, -leftPadding, -topPadding)
        hudControls.hoverZone:SetAnchor(BOTTOMRIGHT, hudControls.frame, BOTTOMRIGHT, rightExtension, bottomPadding)
    end
end

--- Persiste la position actuelle du médaillon HUD.
local function SaveHudPosition(savedVariables)
    if not hudControls.frame or not savedVariables then return end
    savedVariables.pos.x, savedVariables.pos.y = hudControls.frame:GetLeft(), hudControls.frame:GetTop()
    if RequestAddOnSavedVariablesSave then RequestAddOnSavedVariablesSave() end
end

--- Construit l'interface HUD du trophée et du compteur.
function Hud.CreateUI()
    local savedVariables = GetSavedVariables()
    if not savedVariables then return end

    local windowManager = WINDOW_MANAGER
    local baseSize = 256
    local hudScale = (type(savedVariables.scale) == "number") and savedVariables.scale or ComputeAutoScale()
    local menuWidth = MENU_ICON_WIDTH * hudScale
    local menuHeight = MENU_ICON_HEIGHT * hudScale
    local menuOffset = 12 * hudScale
    local hoverLeftPadding = HOVER_LEFT_PADDING * hudScale
    local hoverRightPadding = HOVER_RIGHT_PADDING * hudScale
    local hoverTopPadding = HOVER_TOP_PADDING * hudScale
    local hoverBottomPadding = HOVER_BOTTOM_PADDING * hudScale

    hudControls.frame = windowManager:CreateTopLevelWindow("SquirrelSlayer_Frame")
    hudControls.frame:SetDimensions(baseSize * hudScale, baseSize * hudScale)
    hudControls.frame:SetMouseEnabled(true)
    hudControls.frame:SetMovable(true)
    hudControls.frame:SetClampedToScreen(true)
    if hudControls.frame.SetClipsChildren then hudControls.frame:SetClipsChildren(false) end
    hudControls.frame:SetDrawTier(DT_HIGH)
    hudControls.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedVariables.pos.x, savedVariables.pos.y)

    hudControls.trophy = windowManager:CreateControl(nil, hudControls.frame, CT_TEXTURE)
    hudControls.trophy:SetAnchorFill(hudControls.frame)
    hudControls.trophy:SetTexture("SquirrelSlayer/icons/squirrel_trophy.dds")
    hudControls.trophy:SetDrawLayer(DL_BACKGROUND)

    hudControls.label = windowManager:CreateControl(nil, hudControls.frame, CT_LABEL)
    hudControls.label:SetFont("$(BOLD_FONT)|38|soft-shadow-thick")
    hudControls.label:SetColor(1, 0.12, 0.12, 1)
    hudControls.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    hudControls.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    hudControls.label:SetDrawLayer(DL_CONTROLS)
    hudControls.label:SetAnchor(CENTER, hudControls.frame, TOPLEFT, (baseSize * 0.5) * hudScale, (baseSize * 0.88) * hudScale)

    -- Zone de hit dédiée pour le drag & drop.
    hudControls.hitArea = windowManager:CreateControl(nil, hudControls.frame, CT_CONTROL)
    hudControls.hitArea:SetAnchorFill(hudControls.frame)
    hudControls.hitArea:SetMouseEnabled(true)

    -- Zone de survol invisible (équivalent de la zone orange demandée) pour
    -- garder le menu affiché pendant le passage souris trophée -> menu.
    hudControls.hoverZone = windowManager:CreateTopLevelWindow("SquirrelSlayer_HoverZone")
    hudControls.hoverZone:SetMouseEnabled(true)
    hudControls.hoverZone:SetClampedToScreen(true)
    hudControls.hoverZone:SetDrawTier(DT_MEDIUM)
    hudControls.hoverZone:SetDrawLayer(DL_BACKGROUND)

    -- Menu contextuel en TopLevel séparé pour éviter tout clipping du parent.
    hudControls.menu = windowManager:CreateTopLevelWindow("SquirrelSlayer_Menu")
    hudControls.menu:SetDimensions(menuWidth, menuHeight)
    hudControls.menu:SetMouseEnabled(true)
    hudControls.menu:SetClampedToScreen(true)
    hudControls.menu:SetDrawTier(DT_HIGH)
    hudControls.menu:SetDrawLayer(DL_OVERLAY)
    hudControls.menu:SetHidden(true)

    RefreshAnchors(menuOffset, menuWidth, hoverLeftPadding, hoverRightPadding, hoverTopPadding, hoverBottomPadding)

    -- Fond volontairement visible pour vérifier instantanément la présence du bouton.
    hudControls.menuBackdrop = windowManager:CreateControl(nil, hudControls.menu, CT_BACKDROP)
    hudControls.menuBackdrop:SetAnchorFill(hudControls.menu)
    hudControls.menuBackdrop:SetCenterColor(0.04, 0.05, 0.06, 0.92)
    hudControls.menuBackdrop:SetEdgeColor(0.72, 0.58, 0.33, 1)

    hudControls.statsButton = windowManager:CreateControl(nil, hudControls.menu, CT_BUTTON)
    hudControls.statsButton:SetAnchor(TOPLEFT, hudControls.menu, TOPLEFT, 3, 3)
    hudControls.statsButton:SetAnchor(BOTTOMRIGHT, hudControls.menu, BOTTOMRIGHT, -3, -3)
    hudControls.statsButton:SetNormalTexture("SquirrelSlayer/icons/icon_stats_table_up_64.dds")
    hudControls.statsButton:SetPressedTexture("SquirrelSlayer/icons/icon_stats_table_down_64.dds")
    hudControls.statsButton:SetMouseOverTexture("SquirrelSlayer/icons/icon_stats_table_hover_64.dds")
    hudControls.statsButton:SetDrawLayer(DL_CONTROLS)
    hudControls.statsButton:SetDrawLevel(1)

    hudControls.fragment = ZO_SimpleSceneFragment:New(hudControls.frame)
    HUD_SCENE:AddFragment(hudControls.fragment)
    HUD_UI_SCENE:AddFragment(hudControls.fragment)

    hudControls.menuFragment = ZO_SimpleSceneFragment:New(hudControls.menu)
    HUD_SCENE:AddFragment(hudControls.menuFragment)
    HUD_UI_SCENE:AddFragment(hudControls.menuFragment)

    hudControls.hoverZoneFragment = ZO_SimpleSceneFragment:New(hudControls.hoverZone)
    HUD_SCENE:AddFragment(hudControls.hoverZoneFragment)
    HUD_UI_SCENE:AddFragment(hudControls.hoverZoneFragment)

    local focusedSurfaces = {}

    local function IsAnySurfaceFocused()
        for _, isFocused in pairs(focusedSurfaces) do
            if isFocused then return true end
        end
        return false
    end

    local function HideMenuDelayedIfOutside()
        zo_callLater(function()
            if not IsAnySurfaceFocused() then SetContextMenuVisible(false) end
        end, 130)
    end

    local function HandleHoverEnter(key)
        focusedSurfaces[key] = true
        SetContextMenuVisible(true)
    end

    local function HandleHoverExit(key)
        focusedSurfaces[key] = false
        HideMenuDelayedIfOutside()
    end

    hudControls.frame:SetHandler("OnMouseEnter", function() HandleHoverEnter("frame") end)
    hudControls.frame:SetHandler("OnMouseExit", function() HandleHoverExit("frame") end)
    hudControls.hitArea:SetHandler("OnMouseEnter", function() HandleHoverEnter("hitArea") end)
    hudControls.hitArea:SetHandler("OnMouseExit", function() HandleHoverExit("hitArea") end)
    hudControls.hoverZone:SetHandler("OnMouseEnter", function() HandleHoverEnter("hoverZone") end)
    hudControls.hoverZone:SetHandler("OnMouseExit", function() HandleHoverExit("hoverZone") end)

    hudControls.hitArea:SetHandler("OnMouseDown", function(_, buttonIndex)
        if buttonIndex == MOUSE_BUTTON_INDEX_LEFT then hudControls.frame:StartMoving() end
    end)

    hudControls.hitArea:SetHandler("OnMouseUp", function()
        hudControls.frame:StopMovingOrResizing()
        SaveHudPosition(savedVariables)
    end)

    hudControls.frame:SetHandler("OnMoveStop", function()
        SaveHudPosition(savedVariables)
        RefreshAnchors(menuOffset, menuWidth, hoverLeftPadding, hoverRightPadding, hoverTopPadding, hoverBottomPadding)
    end)

    hudControls.menu:SetHandler("OnMouseEnter", function()
        HandleHoverEnter("menu")
    end)

    hudControls.menu:SetHandler("OnMouseExit", function()
        HandleHoverExit("menu")
    end)

    hudControls.statsButton:SetHandler("OnClicked", function()
        if addon.Services.StatsUI and addon.Services.StatsUI.ToggleWindow then
            addon.Services.StatsUI.ToggleWindow()
        end
    end)

    hudControls.statsButton:SetHandler("OnMouseEnter", function()
        HandleHoverEnter("statsButton")
    end)

    hudControls.statsButton:SetHandler("OnMouseExit", function()
        HandleHoverExit("statsButton")
    end)
end

--- Met à jour le compteur affiché sur le HUD.
function Hud.UpdateLabel()
    local savedVariables = GetSavedVariables()
    if hudControls and hudControls.label and savedVariables then
        hudControls.label:SetText(string.format("%d", savedVariables.total or 0))
    end
end
