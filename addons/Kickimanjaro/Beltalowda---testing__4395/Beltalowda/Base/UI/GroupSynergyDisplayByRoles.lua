-- Beltalowda Group Synergy Display By Roles
-- Role-based synergy tracker: Damage + Support categories, coupled container
-- Horizontal icon row with columnar player cooldown bars beneath each icon
-- Negative tracking: players appear when on cooldown, disappear when ready

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.GroupSynergyDisplayByRoles = Beltalowda.UI.GroupSynergyDisplayByRoles or {}

local GSDBR = Beltalowda.UI.GroupSynergyDisplayByRoles
local ST = Beltalowda.Data.SynergyTracker
local wm = WINDOW_MANAGER

-- ============================================================================
-- Constants
-- ============================================================================

GSDBR.SYNERGY_ICON_SIZE = 48       -- Icon size in horizontal row
GSDBR.COLUMN_WIDTH = 48            -- Width of each synergy column
GSDBR.PLAYER_BLOCK_HEIGHT = 20     -- Height of each player cooldown bar
GSDBR.WINDOW_PADDING = 8
GSDBR.HEADER_HEIGHT = 24           -- Category header text height
GSDBR.MAX_PLAYERS_PER_SYNERGY = 12
GSDBR.OFFSET = 4                   -- Small gap between icon row and content

-- Colors
GSDBR.COLORS = {
    COOLDOWN_FULL = {0.9, 0.2, 0.2, 1},      -- Red (just used synergy)
    COOLDOWN_LOW = {0.9, 0.6, 0.2, 1},        -- Orange (near end of cooldown)
    COOLDOWN_TEXT = {1, 1, 1, 1},              -- White countdown text
    PLAYER_NAME = {0.28515625, 0.8828125, 0.02734375, 1},  -- Green
    BAR_BACKDROP = {0.5, 0.5, 0.5, 0.3},
    DAMAGE_HEADER = {1, 0.3, 0.3, 1},         -- Red-ish
    SUPPORT_HEADER = {0.3, 0.7, 1, 1},        -- Blue-ish
}

-- Role constants
GSDBR.ROLE_DAMAGE = 1
GSDBR.ROLE_SUPPORT = 2

-- Settings version
GSDBR.SETTINGS_VERSION = 5  -- Version 5: preventMovement replaces locked

-- ============================================================================
-- Controls & State
-- ============================================================================

GSDBR.controls = {}
GSDBR.roleWindows = {
    [GSDBR.ROLE_DAMAGE] = nil,
    [GSDBR.ROLE_SUPPORT] = nil,
}
GSDBR.coupledContainer = nil
GSDBR.menuHidden = false
GSDBR.pvpHidden = false
GSDBR.initialized = false
GSDBR.updateRegistered = false

-- Settings
GSDBR.settings = {
    enabled = true,  -- Primary synergy tracker, enabled by default
    preventMovement = false,
    scale = 1.0,
    opacity = 1.0,

    -- Coupling: when true, Damage and Support windows move together
    coupled = true,

    -- Coupled container position
    coupledPositionX = 200,
    coupledPositionY = 200,

    -- Category visibility
    showDamage = true,
    showSupport = true,

    -- Individual positions (decoupled mode)
    damagePositionX = 200,
    damagePositionY = 200,
    supportPositionX = 200,
    supportPositionY = 350,

    -- Synergy configuration per category
    damageSynergyCount = 3,
    supportSynergyCount = 4,
    damageSynergyIds = {},
    supportSynergyIds = {},

    -- (dynamicMode removed — role-based tracker is always dynamic)

    -- Preferred synergy display order for dynamic mode (ordered arrays)
    -- Index = display position (1 = leftmost), value = synergy ID (0 = None)
    -- Synergies detected in group but not in these lists appear after preferred ones.
    damageSynergyOrder = {},
    supportSynergyOrder = {},

    -- Hide category headers ("Damage" / "Support") to save space
    hideHeaders = true,
}

-- ============================================================================
-- Helpers
-- ============================================================================

--[[
    Get effective header height based on hideHeaders setting.
    Returns 0 when headers are hidden so icons shift up.
]]--
function GSDBR.GetEffectiveHeaderHeight()
    if GSDBR.settings.hideHeaders then
        return 0
    end
    return GSDBR.HEADER_HEIGHT
end

-- ============================================================================
-- Menu Visibility
-- ============================================================================

function GSDBR.SetMenuHidden(hidden)
    GSDBR.menuHidden = hidden
    GSDBR.ApplySettings()
end

function GSDBR.SetPvPHidden(hidden)
    GSDBR.pvpHidden = hidden
    GSDBR.ApplySettings()
end

-- ============================================================================
-- Initialization
-- ============================================================================

function GSDBR.Initialize()
    if GSDBR.initialized then return end

    GSDBR.LoadSettings()
    GSDBR.CreateCoupledContainer()
    GSDBR.CreateRoleWindows()

    -- Start hidden — the deferred RebuildDynamicColumns will show only the
    -- synergies actually present in the group.  Without this, all default
    -- synergy columns flash on screen for ~5 s before the dynamic scan hides
    -- the missing ones.
    if GSDBR.coupledContainer and GSDBR.coupledContainer.control then
        GSDBR.coupledContainer.control:SetHidden(true)
    end
    for _, window in pairs(GSDBR.roleWindows) do
        if window and window.control then
            window.control:SetHidden(true)
        end
    end

    GSDBR.RegisterForCompositionChanges()

    -- Schedule a dynamic rebuild after remote data has had time to arrive
    -- (SC initial scan fires at 2s, group request at 3s, responses ~1s after).
    -- The periodic RefreshDisplay timer is NOT started until this fires, so
    -- we never show default/stale columns before the composition scan.
    zo_callLater(function()
        if GSDBR.settings.enabled then
            GSDBR.RebuildDynamicColumns()
            -- Now that columns reflect actual group composition, start the
            -- periodic refresh that drives cooldown bar updates.
            GSDBR.RegisterForUpdates()
        end
    end, 5000)

    GSDBR.initialized = true
    return true
end

-- ============================================================================
-- Settings Load/Save
-- ============================================================================

function GSDBR.LoadSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.groupSynergyDisplayByRoles = BeltalowdaVars.ui.groupSynergyDisplayByRoles or {}

    local saved = BeltalowdaVars.ui.groupSynergyDisplayByRoles
    local savedVersion = saved.version or 0
    local needsReset = (savedVersion < GSDBR.SETTINGS_VERSION)

    GSDBR.settings.enabled = (saved.enabled ~= nil) and saved.enabled or true
    -- Migrate locked → preventMovement
    if saved.preventMovement ~= nil then
        GSDBR.settings.preventMovement = saved.preventMovement
    elseif saved.locked ~= nil then
        GSDBR.settings.preventMovement = saved.locked
    else
        GSDBR.settings.preventMovement = false
    end
    GSDBR.settings.scale = saved.scale or 1.0
    GSDBR.settings.opacity = saved.opacity or 1.0

    -- Migrate old per-window decouple settings to single coupled toggle
    if saved.coupled ~= nil then
        GSDBR.settings.coupled = saved.coupled
    elseif saved.damageDecoupled ~= nil or saved.supportDecoupled ~= nil then
        -- Old settings: if either was decoupled, new coupled = false
        GSDBR.settings.coupled = not (saved.damageDecoupled or saved.supportDecoupled)
    else
        GSDBR.settings.coupled = true
    end

    GSDBR.settings.coupledPositionX = saved.coupledPositionX or 200
    GSDBR.settings.coupledPositionY = saved.coupledPositionY or 200

    GSDBR.settings.showDamage = (saved.showDamage ~= nil) and saved.showDamage or true
    GSDBR.settings.showSupport = (saved.showSupport ~= nil) and saved.showSupport or true

    GSDBR.settings.damagePositionX = saved.damagePositionX or 200
    GSDBR.settings.damagePositionY = saved.damagePositionY or 200
    GSDBR.settings.supportPositionX = saved.supportPositionX or 200
    GSDBR.settings.supportPositionY = saved.supportPositionY or 350

    GSDBR.settings.damageSynergyCount = saved.damageSynergyCount or 3
    GSDBR.settings.supportSynergyCount = saved.supportSynergyCount or 4

    GSDBR.settings.hideHeaders = (saved.hideHeaders ~= nil) and saved.hideHeaders or true

    -- Load or default dynamic synergy order (6 slots each)
    local DYNAMIC_SLOT_COUNT = 6
    if saved.damageSynergyOrder and #saved.damageSynergyOrder == DYNAMIC_SLOT_COUNT then
        GSDBR.settings.damageSynergyOrder = saved.damageSynergyOrder
    else
        GSDBR.settings.damageSynergyOrder = {}
        for i = 1, DYNAMIC_SLOT_COUNT do
            GSDBR.settings.damageSynergyOrder[i] = ST.DEFAULT_DAMAGE_SYNERGIES[i] or 0
        end
    end
    if saved.supportSynergyOrder and #saved.supportSynergyOrder == DYNAMIC_SLOT_COUNT then
        GSDBR.settings.supportSynergyOrder = saved.supportSynergyOrder
    else
        GSDBR.settings.supportSynergyOrder = {}
        for i = 1, DYNAMIC_SLOT_COUNT do
            GSDBR.settings.supportSynergyOrder[i] = ST.DEFAULT_SUPPORT_SYNERGIES[i] or 0
        end
    end

    -- Load or default synergy IDs
    if needsReset or not saved.damageSynergyIds or #saved.damageSynergyIds ~= GSDBR.settings.damageSynergyCount then
        GSDBR.settings.damageSynergyIds = {}
        for i = 1, GSDBR.settings.damageSynergyCount do
            GSDBR.settings.damageSynergyIds[i] = ST.DEFAULT_DAMAGE_SYNERGIES[i] or 0
        end
    else
        GSDBR.settings.damageSynergyIds = saved.damageSynergyIds
    end

    if needsReset or not saved.supportSynergyIds or #saved.supportSynergyIds ~= GSDBR.settings.supportSynergyCount then
        GSDBR.settings.supportSynergyIds = {}
        for i = 1, GSDBR.settings.supportSynergyCount do
            GSDBR.settings.supportSynergyIds[i] = ST.DEFAULT_SUPPORT_SYNERGIES[i] or 0
        end
    else
        GSDBR.settings.supportSynergyIds = saved.supportSynergyIds
    end
end

function GSDBR.SaveSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}

    BeltalowdaVars.ui.groupSynergyDisplayByRoles = {
        version = GSDBR.SETTINGS_VERSION,
        enabled = GSDBR.settings.enabled,
        preventMovement = GSDBR.settings.preventMovement,
        scale = GSDBR.settings.scale,
        opacity = GSDBR.settings.opacity,
        coupled = GSDBR.settings.coupled,
        coupledPositionX = GSDBR.settings.coupledPositionX,
        coupledPositionY = GSDBR.settings.coupledPositionY,
        showDamage = GSDBR.settings.showDamage,
        showSupport = GSDBR.settings.showSupport,
        damagePositionX = GSDBR.settings.damagePositionX,
        damagePositionY = GSDBR.settings.damagePositionY,
        supportPositionX = GSDBR.settings.supportPositionX,
        supportPositionY = GSDBR.settings.supportPositionY,
        damageSynergyCount = GSDBR.settings.damageSynergyCount,
        supportSynergyCount = GSDBR.settings.supportSynergyCount,
        damageSynergyIds = GSDBR.settings.damageSynergyIds,
        supportSynergyIds = GSDBR.settings.supportSynergyIds,
        hideHeaders = GSDBR.settings.hideHeaders,
        damageSynergyOrder = GSDBR.settings.damageSynergyOrder,
        supportSynergyOrder = GSDBR.settings.supportSynergyOrder,
    }
end

-- ============================================================================
-- Coupled Container
-- ============================================================================

function GSDBR.CreateCoupledContainer()
    local uniqueName = "BeltalowdaSynergyByRoles_CoupledContainer"
    local control = wm:GetControlByName(uniqueName)

    if control then
        GSDBR.coupledContainer = {
            control = control,
            backdrop = wm:GetControlByName(uniqueName .. "Backdrop"),
        }
        return GSDBR.coupledContainer
    end

    control = wm:CreateTopLevelWindow(uniqueName)
    control:SetClampedToScreen(true)
    control:SetDrawLayer(DL_BACKGROUND)
    control:SetDrawLevel(0)
    control:SetMovable(not GSDBR.settings.preventMovement)
    control:SetMouseEnabled(not GSDBR.settings.preventMovement)
    control:SetHidden(not GSDBR.settings.enabled)
    control:SetScale(GSDBR.settings.scale or 1.0)
    control:SetAlpha(GSDBR.settings.opacity or 1.0)
    control:SetDimensions(400, 100)

    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GSDBR.settings.coupledPositionX, GSDBR.settings.coupledPositionY)

    -- Save position when moved (and restore opacity after drag)
    control:SetHandler("OnMoveStop", function()
        GSDBR.isDragging = false
        -- Restore opacity on all role windows
        local opacity = GSDBR.settings.opacity or 1.0
        for _, window in pairs(GSDBR.roleWindows) do
            if window and window.control then
                window.control:SetAlpha(opacity)
            end
        end
        GSDBR.OnCoupledContainerMoved()
    end)

    -- Update coupled window positions during dragging (only when actively dragging)
    control:SetHandler("OnUpdate", function()
        if GSDBR.isDragging then
            GSDBR.UpdateCoupledWindowPositions()
        end
    end)

    -- Backdrop: always transparent (no red unlock indicator)
    local backdrop = wm:CreateControl(uniqueName .. "Backdrop", control, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    backdrop:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 0)
    backdrop:SetDrawLevel(0)
    backdrop:SetCenterColor(0, 0, 0, 0)
    backdrop:SetEdgeColor(0, 0, 0, 0)
    backdrop:SetEdgeTexture(nil, 1, 1, 1, 0)
    backdrop:SetMouseEnabled(not GSDBR.settings.preventMovement)

    -- Make backdrop draggable (fallback for any area not covered by role windows)
    backdrop:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            GSDBR.HandleDragStart()
        end
    end)
    backdrop:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            GSDBR.HandleDragStop()
        end
    end)

    GSDBR.coupledContainer = {
        control = control,
        backdrop = backdrop,
    }

    return GSDBR.coupledContainer
end

-- ============================================================================
-- Role Windows
-- Each role window has:
--   - A header label ("Damage" / "Support")
--   - A horizontal row of clickable synergy icons
--   - Columnar player cooldown bars beneath each icon
-- ============================================================================

function GSDBR.CreateRoleWindows()
    -- Start with zero synergy columns — RebuildDynamicColumns will populate
    -- them once composition data arrives.  This prevents default/saved synergies
    -- from flashing on screen before the group scan completes.
    GSDBR.roleWindows[GSDBR.ROLE_DAMAGE] = GSDBR.CreateRoleWindow(GSDBR.ROLE_DAMAGE, "Damage",
        "damagePositionX", "damagePositionY",
        GSDBR.COLORS.DAMAGE_HEADER,
        {}, 0)

    GSDBR.roleWindows[GSDBR.ROLE_SUPPORT] = GSDBR.CreateRoleWindow(GSDBR.ROLE_SUPPORT, "Support",
        "supportPositionX", "supportPositionY",
        GSDBR.COLORS.SUPPORT_HEADER,
        {}, 0)
end

function GSDBR.CreateRoleWindow(roleType, roleName, posXKey, posYKey, headerColor, synergyIds, synergyCount)
    local window = {}
    window.roleType = roleType
    window.roleName = roleName
    window.posXKey = posXKey
    window.posYKey = posYKey
    window.synergyColumns = {}

    local uniqueName = "BeltalowdaSynergyByRoles_" .. roleName
    local control = wm:GetControlByName(uniqueName)
    if control then
        window.control = control
        window.backdrop = wm:GetControlByName(uniqueName .. "Backdrop")
        window.header = wm:GetControlByName(uniqueName .. "Header")
        window.iconRow = wm:GetControlByName(uniqueName .. "IconRow")
        window.synergyColumns = {}
        GSDBR.CreateSynergyColumns(window, synergyIds, synergyCount)
        return window
    end

    local width = (GSDBR.COLUMN_WIDTH * synergyCount) + (GSDBR.WINDOW_PADDING * 2)
    local headerHeight = GSDBR.GetEffectiveHeaderHeight()
    local height = headerHeight + GSDBR.SYNERGY_ICON_SIZE + (GSDBR.WINDOW_PADDING * 2)

    control = wm:CreateTopLevelWindow(uniqueName)
    control:SetClampedToScreen(true)
    control:SetDrawLayer(DL_BACKGROUND)
    control:SetDrawLevel(1)
    control:SetMovable(not GSDBR.settings.preventMovement)
    control:SetMouseEnabled(true)  -- Always enabled for tooltips
    control:SetHidden(not GSDBR.settings.enabled)
    control:SetScale(GSDBR.settings.scale or 1.0)
    control:SetAlpha(GSDBR.settings.opacity or 1.0)
    control:SetDimensions(width, height)

    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GSDBR.settings[posXKey], GSDBR.settings[posYKey])

    control:SetHandler("OnMoveStop", function()
        GSDBR.OnWindowMoved(window)
    end)

    -- Forward mouse events to coupled container for drag (or move self if decoupled)
    control:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not GSDBR.settings.preventMovement then
            if GSDBR.settings.coupled then
                GSDBR.HandleDragStart()
            end
            -- If decoupled, the control's native SetMovable(true) handles it
        end
    end)
    control:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            if GSDBR.settings.coupled then
                GSDBR.HandleDragStop()
            end
        end
    end)

    -- Backdrop: always transparent (no red unlock indicator)
    local backdrop = wm:CreateControl(uniqueName .. "Backdrop", control, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    backdrop:SetDimensions(width, height)
    backdrop:SetDrawLevel(0)
    backdrop:SetCenterColor(0, 0, 0, 0)
    backdrop:SetEdgeColor(0, 0, 0, 0)
    backdrop:SetEdgeTexture(nil, 1, 1, 1, 0)
    backdrop:SetMouseEnabled(false)

    -- Header label (centered above icon row)
    local header = wm:CreateControl(uniqueName .. "Header", control, CT_LABEL)
    header:SetAnchor(TOP, control, TOP, 0, GSDBR.WINDOW_PADDING)
    header:SetFont("ZoFontWinH4")
    header:SetText(roleName)
    header:SetColor(headerColor[1], headerColor[2], headerColor[3], headerColor[4])
    header:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    -- Icon row container (holds the horizontal row of icons + columns beneath)
    local iconRow = wm:CreateControl(uniqueName .. "IconRow", control, CT_CONTROL)
    iconRow:SetAnchor(TOPLEFT, control, TOPLEFT, GSDBR.WINDOW_PADDING,
        headerHeight + GSDBR.WINDOW_PADDING)
    iconRow:SetDimensions(GSDBR.COLUMN_WIDTH * synergyCount, GSDBR.SYNERGY_ICON_SIZE)

    window.control = control
    window.backdrop = backdrop
    window.header = header
    window.iconRow = iconRow
    window.synergyColumns = {}

    GSDBR.CreateSynergyColumns(window, synergyIds, synergyCount)

    return window
end

-- ============================================================================
-- Synergy Columns (horizontal layout)
-- Each column: clickable icon at top, player blocks stacking vertically below
-- ============================================================================

function GSDBR.CreateSynergyColumns(window, synergyIds, synergyCount)
    window.synergyColumns = {}

    for i = 1, synergyCount do
        local synergyId = synergyIds[i] or 0
        local column = GSDBR.CreateSynergyColumn(window, i, synergyId)
        table.insert(window.synergyColumns, column)
    end
end

function GSDBR.CreateSynergyColumn(window, index, synergyId)
    local column = {}
    column.synergyId = synergyId
    column.playerBlocks = {}

    local parent = window.iconRow
    local xOffset = GSDBR.COLUMN_WIDTH * (index - 1)

    -- Column container (spans icon + player blocks below)
    local container = wm:CreateControl(nil, parent, CT_CONTROL)
    container:SetAnchor(TOPLEFT, parent, TOPLEFT, xOffset, 0)
    container:SetDimensions(GSDBR.COLUMN_WIDTH,
        GSDBR.SYNERGY_ICON_SIZE + (GSDBR.PLAYER_BLOCK_HEIGHT * GSDBR.MAX_PLAYERS_PER_SYNERGY))

    -- Synergy icon container (drag-forwardable, dynamic-only — no button appearance)
    local iconButton = wm:CreateControl(nil, container, CT_CONTROL)
    iconButton:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    iconButton:SetDimensions(GSDBR.SYNERGY_ICON_SIZE, GSDBR.SYNERGY_ICON_SIZE)
    iconButton:SetMouseEnabled(true)

    -- Forward drag events to coupled container or role window
    iconButton:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not GSDBR.settings.preventMovement then
            if GSDBR.settings.coupled then
                GSDBR.HandleDragStart()
            else
                window.control:StartMoving()
            end
        end
    end)
    iconButton:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            if GSDBR.settings.coupled then
                GSDBR.HandleDragStop()
            else
                window.control:StopMovingOrResizing()
            end
        end
    end)

    -- Icon texture
    local icon = wm:CreateControl(nil, container, CT_TEXTURE)
    icon:SetAnchor(CENTER, iconButton, CENTER, 0, 0)
    icon:SetDimensions(GSDBR.SYNERGY_ICON_SIZE - 4, GSDBR.SYNERGY_ICON_SIZE - 4)

    -- Tooltip on icon (synergy name + providers)
    iconButton:SetHandler("OnMouseEnter", function(ctrl)
        if column.synergyName then
            InitializeTooltip(InformationTooltip, ctrl, BOTTOM, 0, -5)
            local tooltipText = column.synergyName
            local SC = Beltalowda.Data and Beltalowda.Data.SynergyComposition
            if SC and SC.GetProvidersForSynergy and column.synergyId then
                local providers = SC.GetProvidersForSynergy(column.synergyId)
                if #providers > 0 then
                    tooltipText = tooltipText .. "\n\nProviders:"
                    for _, name in ipairs(providers) do
                        tooltipText = tooltipText .. "\n  " .. name
                    end
                end
            end
            SetTooltipText(InformationTooltip, tooltipText)
        end
    end)
    iconButton:SetHandler("OnMouseExit", function(ctrl)
        ClearTooltip(InformationTooltip)
    end)

    -- Pre-create player blocks (stacking vertically below the icon)
    for j = 1, GSDBR.MAX_PLAYERS_PER_SYNERGY do
        local block = GSDBR.CreatePlayerBlock(container, j)
        -- Forward drag events from cooldown bars to coupled container or role window
        block.container:SetHandler("OnMouseDown", function(self, button)
            if button == MOUSE_BUTTON_INDEX_LEFT and not GSDBR.settings.preventMovement then
                if GSDBR.settings.coupled then
                    GSDBR.HandleDragStart()
                else
                    window.control:StartMoving()
                end
            end
        end)
        block.container:SetHandler("OnMouseUp", function(self, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                if GSDBR.settings.coupled then
                    GSDBR.HandleDragStop()
                else
                    window.control:StopMovingOrResizing()
                end
            end
        end)
        table.insert(column.playerBlocks, block)
    end

    column.container = container
    column.iconButton = iconButton
    column.icon = icon

    -- Set initial icon
    GSDBR.UpdateColumnIcon(column)

    return column
end

function GSDBR.UpdateColumnIcon(column)
    local synergy = ST.GetSynergyById(column.synergyId)
    if synergy then
        column.icon:SetTexture(synergy.iconPath)
        column.synergyName = synergy.name
    else
        column.icon:SetTexture("/esoui/art/icons/ability_default.dds")
        column.synergyName = nil
    end
end

-- ============================================================================
-- Player Blocks (cooldown bars beneath each synergy icon column)
-- ============================================================================

function GSDBR.CreatePlayerBlock(parent, index)
    local block = {}

    local container = wm:CreateControl(nil, parent, CT_CONTROL)
    local yOffset = GSDBR.SYNERGY_ICON_SIZE + (GSDBR.PLAYER_BLOCK_HEIGHT * (index - 1))
    container:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, yOffset)
    container:SetDimensions(GSDBR.COLUMN_WIDTH, GSDBR.PLAYER_BLOCK_HEIGHT)
    container:SetHidden(true)

    -- Background (transparent - visual provided by bar backdrop)
    local backdrop = wm:CreateControl(nil, container, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    backdrop:SetDimensions(GSDBR.COLUMN_WIDTH, GSDBR.PLAYER_BLOCK_HEIGHT)
    backdrop:SetCenterColor(0, 0, 0, 0)
    backdrop:SetEdgeColor(0, 0, 0, 0)
    backdrop:SetEdgeTexture(nil, 1, 1, 1, 0)

    -- Cooldown progress bar (fills container minus 1px inset, matching RdK)
    local barHeight = GSDBR.PLAYER_BLOCK_HEIGHT - 2
    local progressBar = wm:CreateControl(nil, container, CT_STATUSBAR)
    progressBar:SetAnchor(TOPLEFT, container, TOPLEFT, 1, 1)
    progressBar:SetDimensions(GSDBR.COLUMN_WIDTH - 2, barHeight)
    progressBar:SetMinMax(0, 100)
    progressBar:SetValue(0)
    progressBar:SetColor(GSDBR.COLORS.COOLDOWN_FULL[1], GSDBR.COLORS.COOLDOWN_FULL[2],
        GSDBR.COLORS.COOLDOWN_FULL[3], GSDBR.COLORS.COOLDOWN_FULL[4])

    local barBackdrop = wm:CreateControl(nil, progressBar, CT_BACKDROP)
    barBackdrop:SetAnchor(TOPLEFT, progressBar, TOPLEFT, 0, 0)
    barBackdrop:SetDimensions(GSDBR.COLUMN_WIDTH - 2, barHeight)
    barBackdrop:SetCenterColor(GSDBR.COLORS.BAR_BACKDROP[1], GSDBR.COLORS.BAR_BACKDROP[2],
        GSDBR.COLORS.BAR_BACKDROP[3], GSDBR.COLORS.BAR_BACKDROP[4])
    barBackdrop:SetEdgeColor(0, 0, 0, 0)
    barBackdrop:SetDrawLevel(0)

    -- Player name label (anchored to progress bar, centered — matches ult tracker pattern)
    local nameLabel = wm:CreateControl(nil, container, CT_LABEL)
    nameLabel:SetAnchor(LEFT, progressBar, LEFT, 2, 0)
    nameLabel:SetFont("ZoFontGameSmall")
    nameLabel:SetText("")
    nameLabel:SetDimensions(GSDBR.COLUMN_WIDTH - 4, barHeight)
    nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetColor(GSDBR.COLORS.PLAYER_NAME[1], GSDBR.COLORS.PLAYER_NAME[2],
        GSDBR.COLORS.PLAYER_NAME[3], GSDBR.COLORS.PLAYER_NAME[4])
    nameLabel:SetDrawLevel(5)

    -- Tooltip
    container:SetMouseEnabled(true)
    container:SetHandler("OnMouseEnter", function(ctrl)
        if block.charName then
            InitializeTooltip(InformationTooltip, ctrl, RIGHT, 5, 0)
            local remaining = math.ceil((block.remainingMs or 0) / 1000)
            -- Tooltip always shows character name for data context
            local tooltipName = block.charName
            if block.unitTag then
                local acctName = GetUnitDisplayName(block.unitTag)
                if acctName and acctName ~= "" then
                    tooltipName = string.format("%s (%s)", block.charName, acctName)
                end
            end
            SetTooltipText(InformationTooltip, string.format("%s\nCooldown: %ds", tooltipName, remaining))
        end
    end)
    container:SetHandler("OnMouseExit", function(ctrl)
        ClearTooltip(InformationTooltip)
    end)

    block.container = container
    block.backdrop = backdrop
    block.progressBar = progressBar
    block.barBackdrop = barBackdrop
    block.nameLabel = nameLabel
    block.charName = nil
    block.remainingMs = 0

    return block
end

-- (ShowSynergySelectionDialog and SetColumnSynergy removed —
--  role-based tracker is dynamic-only, use classic tracker for manual selection)

-- ============================================================================
-- Update Loop
-- ============================================================================

function GSDBR.RegisterForUpdates()
    if GSDBR.settings.enabled then
        EVENT_MANAGER:RegisterForUpdate("BeltalowdaGroupSynergyDisplayByRoles", 1000, function()
            GSDBR.RefreshDisplay()
        end)
        GSDBR.updateRegistered = true
    end
end

function GSDBR.RefreshDisplay()
    if not GSDBR.settings.enabled or GSDBR.menuHidden or GSDBR.pvpHidden then return end

    -- Clean up expired cooldowns
    if ST.CleanupExpiredCooldowns then
        ST.CleanupExpiredCooldowns()
    end

    -- Update each role window
    for roleType, window in pairs(GSDBR.roleWindows) do
        if window then
            GSDBR.UpdateRoleWindow(window)
        end
    end

    -- Resize coupled container to match
    GSDBR.ResizeCoupledContainer()
end

function GSDBR.UpdateRoleWindow(window)
    if not window or not window.synergyColumns then return end

    local visible = GSDBR.settings.enabled and GSDBR.GetRoleVisibility(window.roleType) and not GSDBR.menuHidden and not GSDBR.pvpHidden
    window.control:SetHidden(not visible)
    if not visible then return end

    local synergyCount = #window.synergyColumns
    local maxPlayerCount = 0

    for i, column in ipairs(window.synergyColumns) do
        local synergyId = column.synergyId
        local playerCount = 0

        if synergyId and synergyId > 0 then
            local playersOnCooldown = ST.GetPlayersOnCooldown(synergyId)
            playerCount = math.min(#playersOnCooldown, GSDBR.MAX_PLAYERS_PER_SYNERGY)

            if playerCount > maxPlayerCount then
                maxPlayerCount = playerCount
            end

            -- Update visible player blocks
            for j = 1, playerCount do
                local player = playersOnCooldown[j]
                local block = column.playerBlocks[j]
                if block then
                    block.container:SetHidden(false)
                    block.charName = player.charName
                    block.unitTag = player.unitTag
                    block.remainingMs = player.remainingMs

                    -- Truncate name to fit column
                    local displayName = (player.unitTag and Beltalowda.GetDisplayName(player.unitTag)) or player.charName or ""
                    if #displayName > 7 then
                        displayName = string.sub(displayName, 1, 6) .. ".."
                    end
                    block.nameLabel:SetText(displayName)

                    -- Cooldown bar (drains from 100 to 0)
                    local percent = player.percent * 100
                    block.progressBar:SetValue(percent)

                    -- Color interpolation: red -> orange
                    local r = GSDBR.COLORS.COOLDOWN_FULL[1]
                    local g = GSDBR.COLORS.COOLDOWN_FULL[2] +
                        (GSDBR.COLORS.COOLDOWN_LOW[2] - GSDBR.COLORS.COOLDOWN_FULL[2]) * (1 - player.percent)
                    local b = GSDBR.COLORS.COOLDOWN_FULL[3]
                    block.progressBar:SetColor(r, g, b, 1)
                end
            end

            -- Hide unused blocks
            for j = playerCount + 1, GSDBR.MAX_PLAYERS_PER_SYNERGY do
                local block = column.playerBlocks[j]
                if block then
                    block.container:SetHidden(true)
                end
            end
        else
            -- No synergy selected, hide all blocks
            for j = 1, GSDBR.MAX_PLAYERS_PER_SYNERGY do
                local block = column.playerBlocks[j]
                if block then
                    block.container:SetHidden(true)
                end
            end
        end
    end

    -- Resize window to fit content
    local width = (GSDBR.COLUMN_WIDTH * synergyCount) + (GSDBR.WINDOW_PADDING * 2)
    local headerHeight = GSDBR.GetEffectiveHeaderHeight()
    local height = headerHeight + GSDBR.SYNERGY_ICON_SIZE +
        (GSDBR.PLAYER_BLOCK_HEIGHT * maxPlayerCount) + (GSDBR.WINDOW_PADDING * 2)
    window.control:SetDimensions(width, height)
    if window.backdrop then
        window.backdrop:SetDimensions(width, height)
    end
end

-- ============================================================================
-- Apply Settings
-- ============================================================================

function GSDBR.ApplySettings()
    if not GSDBR.settings.enabled or GSDBR.menuHidden or GSDBR.pvpHidden then
        if GSDBR.coupledContainer and GSDBR.coupledContainer.control then
            GSDBR.coupledContainer.control:SetHidden(true)
        end
        for _, window in pairs(GSDBR.roleWindows) do
            if window and window.control then
                window.control:SetHidden(true)
            end
        end
        return
    end

    local globalScale = GSDBR.settings.scale or 1.0
    local globalOpacity = GSDBR.settings.opacity or 1.0

    local isCoupled = GSDBR.settings.coupled

    -- Coupled container
    if GSDBR.coupledContainer and GSDBR.coupledContainer.control then
        GSDBR.coupledContainer.control:SetHidden(not isCoupled)
        GSDBR.coupledContainer.control:SetMovable(not GSDBR.settings.preventMovement)
        GSDBR.coupledContainer.control:SetMouseEnabled(not GSDBR.settings.preventMovement)
        GSDBR.coupledContainer.control:SetScale(globalScale)
        GSDBR.coupledContainer.control:SetAlpha(globalOpacity)

        if GSDBR.coupledContainer.backdrop then
            GSDBR.coupledContainer.backdrop:SetMouseEnabled(not GSDBR.settings.preventMovement)
            -- Always transparent (no red backdrop)
            GSDBR.coupledContainer.backdrop:SetCenterColor(0, 0, 0, 0)
            GSDBR.coupledContainer.backdrop:SetEdgeColor(0, 0, 0, 0)
        end
    end

    local coupledX = GSDBR.settings.coupledPositionX
    local coupledY = GSDBR.settings.coupledPositionY
    local coupledXOffset = 0

    -- Position Damage window
    local damageWindow = GSDBR.roleWindows[GSDBR.ROLE_DAMAGE]
    if damageWindow and damageWindow.control then
        damageWindow.control:SetScale(globalScale)
        damageWindow.control:SetAlpha(globalOpacity)
        damageWindow.control:ClearAnchors()

        if isCoupled and GSDBR.coupledContainer then
            damageWindow.control:SetHidden(not GSDBR.settings.showDamage)
            damageWindow.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                coupledX + coupledXOffset, coupledY)
            damageWindow.control:SetMovable(false)
            damageWindow.control:SetMouseEnabled(true)  -- Always enabled for tooltips
            if GSDBR.settings.showDamage then
                coupledXOffset = coupledXOffset + damageWindow.control:GetWidth() + 4
            end
        else
            damageWindow.control:SetHidden(not GSDBR.settings.showDamage)
            damageWindow.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                GSDBR.settings.damagePositionX, GSDBR.settings.damagePositionY)
            damageWindow.control:SetMovable(not GSDBR.settings.preventMovement)
            damageWindow.control:SetMouseEnabled(true)  -- Always enabled for tooltips
        end
    end

    -- Position Support window
    local supportWindow = GSDBR.roleWindows[GSDBR.ROLE_SUPPORT]
    if supportWindow and supportWindow.control then
        supportWindow.control:SetScale(globalScale)
        supportWindow.control:SetAlpha(globalOpacity)
        supportWindow.control:ClearAnchors()

        if isCoupled and GSDBR.coupledContainer then
            supportWindow.control:SetHidden(not GSDBR.settings.showSupport)
            supportWindow.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                coupledX + coupledXOffset, coupledY)
            supportWindow.control:SetMovable(false)
            supportWindow.control:SetMouseEnabled(true)  -- Always enabled for tooltips
            if GSDBR.settings.showSupport then
                coupledXOffset = coupledXOffset + supportWindow.control:GetWidth() + 4
            end
        else
            supportWindow.control:SetHidden(not GSDBR.settings.showSupport)
            supportWindow.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                GSDBR.settings.supportPositionX, GSDBR.settings.supportPositionY)
            supportWindow.control:SetMovable(not GSDBR.settings.preventMovement)
            supportWindow.control:SetMouseEnabled(true)  -- Always enabled for tooltips
        end
    end

    -- Show/hide columns based on current synergy count
    for _, window in pairs(GSDBR.roleWindows) do
        if window and window.synergyColumns then
            local count
            if window.roleType == GSDBR.ROLE_DAMAGE then
                count = GSDBR.settings.damageSynergyCount
            else
                count = GSDBR.settings.supportSynergyCount
            end
            for i, column in ipairs(window.synergyColumns) do
                column.container:SetHidden(i > count)
            end
        end
    end

    -- Apply header visibility and reposition icon rows
    local headerHeight = GSDBR.GetEffectiveHeaderHeight()
    for _, window in pairs(GSDBR.roleWindows) do
        if window then
            if window.header then
                window.header:SetHidden(GSDBR.settings.hideHeaders)
            end
            if window.iconRow then
                window.iconRow:ClearAnchors()
                window.iconRow:SetAnchor(TOPLEFT, window.control, TOPLEFT,
                    GSDBR.WINDOW_PADDING, headerHeight + GSDBR.WINDOW_PADDING)
            end
        end
    end

    GSDBR.ResizeCoupledContainer()
end

function GSDBR.ResizeCoupledContainer()
    if not GSDBR.coupledContainer or not GSDBR.coupledContainer.control then return end

    if not GSDBR.settings.coupled then return end

    local totalWidth = 0
    local maxHeight = 0

    local damageWindow = GSDBR.roleWindows[GSDBR.ROLE_DAMAGE]
    if damageWindow and damageWindow.control and GSDBR.settings.showDamage then
        totalWidth = totalWidth + damageWindow.control:GetWidth() + 4
        maxHeight = math.max(maxHeight, damageWindow.control:GetHeight())
    end

    local supportWindow = GSDBR.roleWindows[GSDBR.ROLE_SUPPORT]
    if supportWindow and supportWindow.control and GSDBR.settings.showSupport then
        totalWidth = totalWidth + supportWindow.control:GetWidth() + 4
        maxHeight = math.max(maxHeight, supportWindow.control:GetHeight())
    end

    if totalWidth > 4 then totalWidth = totalWidth - 4 end
    if totalWidth > 0 and maxHeight > 0 then
        GSDBR.coupledContainer.control:SetDimensions(totalWidth, maxHeight)
    end
end

-- ============================================================================
-- Coupled Container Handlers
-- ============================================================================

function GSDBR.UpdateCoupledWindowPositions()
    if not GSDBR.coupledContainer or not GSDBR.coupledContainer.control then return end
    if not GSDBR.settings.enabled then return end

    local coupledX = GSDBR.coupledContainer.control:GetLeft()
    local coupledY = GSDBR.coupledContainer.control:GetTop()
    if not coupledX or not coupledY then return end

    local coupledXOffset = 0

    local damageWindow = GSDBR.roleWindows[GSDBR.ROLE_DAMAGE]
    if GSDBR.settings.coupled and damageWindow and damageWindow.control and GSDBR.settings.showDamage then
        damageWindow.control:ClearAnchors()
        damageWindow.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
            coupledX + coupledXOffset, coupledY)
        coupledXOffset = coupledXOffset + damageWindow.control:GetWidth() + 4
    end

    local supportWindow = GSDBR.roleWindows[GSDBR.ROLE_SUPPORT]
    if GSDBR.settings.coupled and supportWindow and supportWindow.control and GSDBR.settings.showSupport then
        supportWindow.control:ClearAnchors()
        supportWindow.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
            coupledX + coupledXOffset, coupledY)
    end
end

function GSDBR.OnCoupledContainerMoved()
    if not GSDBR.coupledContainer or not GSDBR.coupledContainer.control then return end
    if GSDBR.settings.preventMovement then return end

    local left = GSDBR.coupledContainer.control:GetLeft()
    local top = GSDBR.coupledContainer.control:GetTop()
    if left and top then
        GSDBR.settings.coupledPositionX = left
        GSDBR.settings.coupledPositionY = top
        GSDBR.SaveSettings()
    end
end

function GSDBR.OnWindowMoved(window)
    if not window or not window.control then return end
    if GSDBR.settings.preventMovement then return end

    if GSDBR.settings.coupled then return end

    local left = window.control:GetLeft()
    local top = window.control:GetTop()
    if left and top then
        GSDBR.settings[window.posXKey] = left
        GSDBR.settings[window.posYKey] = top
        GSDBR.SaveSettings()
    end
end

-- ============================================================================
-- Helpers
-- ============================================================================

function GSDBR.GetRoleVisibility(roleType)
    if roleType == GSDBR.ROLE_DAMAGE then
        return GSDBR.settings.showDamage
    elseif roleType == GSDBR.ROLE_SUPPORT then
        return GSDBR.settings.showSupport
    end
    return false
end

-- ============================================================================
-- Dynamic Mode (composition-driven synergy display)
-- ============================================================================

--[[
    Register for GROUP_SYNERGY_COMPOSITION_CHANGED callback.
    When dynamic mode is enabled, rebuilds synergy columns based on
    which synergies are actually present in the group.
]]--
function GSDBR.RegisterForCompositionChanges()
    local SC = Beltalowda.Data and Beltalowda.Data.SynergyComposition
    if not SC then return end

    if CALLBACK_MANAGER then
        CALLBACK_MANAGER:RegisterCallback(SC.CALLBACK_NAME, function(groupBitmask)
            if GSDBR.settings.enabled then
                GSDBR.RebuildDynamicColumns()
            end
        end)
    end
end

--[[
    Rebuild synergy columns based on group composition (dynamic mode).
    Scans the group bitmask for detected synergies and splits them into
    damage/support categories, then rebuilds each role window's columns.
]]--
function GSDBR.RebuildDynamicColumns()
    local SC = Beltalowda.Data and Beltalowda.Data.SynergyComposition
    if not SC then return end

    local groupSynergies = SC.GetGroupSynergyList()

    -- Split detected synergies into damage and support sets for fast lookup
    local detectedDamage = {}
    local detectedSupport = {}

    for _, synergyId in ipairs(groupSynergies) do
        local synergy = ST.GetSynergyById(synergyId)
        if synergy then
            if synergy.category == ST.CATEGORY_DAMAGE then
                detectedDamage[synergyId] = true
            elseif synergy.category == ST.CATEGORY_SUPPORT then
                detectedSupport[synergyId] = true
            end
        end
    end

    -- Build ordered list: preferred slots first, then remaining detected synergies
    local function buildOrderedList(preferredOrder, detectedSet)
        local result = {}
        local used = {}
        -- Add preferred synergies (in order) if they are detected in the group
        for _, synergyId in ipairs(preferredOrder) do
            if synergyId > 0 and detectedSet[synergyId] and not used[synergyId] then
                table.insert(result, synergyId)
                used[synergyId] = true
            end
        end
        -- Append any remaining detected synergies not in preferred list
        -- Sort remainder by displayOrder for consistency
        local remainder = {}
        for synergyId, _ in pairs(detectedSet) do
            if not used[synergyId] then
                table.insert(remainder, synergyId)
            end
        end
        table.sort(remainder, function(a, b)
            local synA = ST.GetSynergyById(a)
            local synB = ST.GetSynergyById(b)
            local orderA = synA and synA.displayOrder or a
            local orderB = synB and synB.displayOrder or b
            if orderA == orderB then
                return (synA and synA.name or "") < (synB and synB.name or "")
            end
            return orderA < orderB
        end)
        for _, synergyId in ipairs(remainder) do
            table.insert(result, synergyId)
        end
        return result
    end

    local damageSynergies = buildOrderedList(GSDBR.settings.damageSynergyOrder, detectedDamage)
    local supportSynergies = buildOrderedList(GSDBR.settings.supportSynergyOrder, detectedSupport)

    -- Update damage window
    local damageWindow = GSDBR.roleWindows[GSDBR.ROLE_DAMAGE]
    if damageWindow then
        if #damageSynergies > 0 then
            GSDBR.settings.showDamage = true
            -- Rebuild columns with detected synergies
            for _, column in ipairs(damageWindow.synergyColumns or {}) do
                if column.container then column.container:SetHidden(true) end
            end
            GSDBR.CreateSynergyColumns(damageWindow, damageSynergies, #damageSynergies)
            -- Resize window
            local width = (GSDBR.COLUMN_WIDTH * #damageSynergies) + (GSDBR.WINDOW_PADDING * 2)
            damageWindow.control:SetDimensions(width, damageWindow.control:GetHeight())
            if damageWindow.backdrop then damageWindow.backdrop:SetDimensions(width, damageWindow.backdrop:GetHeight()) end
            if damageWindow.iconRow then damageWindow.iconRow:SetDimensions(GSDBR.COLUMN_WIDTH * #damageSynergies, GSDBR.SYNERGY_ICON_SIZE) end
        else
            -- No damage synergies detected — hide the window
            GSDBR.settings.showDamage = false
        end
    end

    -- Update support window
    local supportWindow = GSDBR.roleWindows[GSDBR.ROLE_SUPPORT]
    if supportWindow then
        if #supportSynergies > 0 then
            GSDBR.settings.showSupport = true
            for _, column in ipairs(supportWindow.synergyColumns or {}) do
                if column.container then column.container:SetHidden(true) end
            end
            GSDBR.CreateSynergyColumns(supportWindow, supportSynergies, #supportSynergies)
            local width = (GSDBR.COLUMN_WIDTH * #supportSynergies) + (GSDBR.WINDOW_PADDING * 2)
            supportWindow.control:SetDimensions(width, supportWindow.control:GetHeight())
            if supportWindow.backdrop then supportWindow.backdrop:SetDimensions(width, supportWindow.backdrop:GetHeight()) end
            if supportWindow.iconRow then supportWindow.iconRow:SetDimensions(GSDBR.COLUMN_WIDTH * #supportSynergies, GSDBR.SYNERGY_ICON_SIZE) end
        else
            GSDBR.settings.showSupport = false
        end
    end

    GSDBR.ApplySettings()
    GSDBR.RefreshDisplay()
end

-- (SetDynamicMode removed — role-based tracker is always dynamic)

-- ============================================================================
-- Public API
-- ============================================================================

function GSDBR.SetEnabled(enabled)
    GSDBR.settings.enabled = enabled
    GSDBR.SaveSettings()
    GSDBR.ApplySettings()

    if enabled then
        if not GSDBR.updateRegistered then
            EVENT_MANAGER:RegisterForUpdate("BeltalowdaGroupSynergyDisplayByRoles", 1000, function()
                GSDBR.RefreshDisplay()
            end)
            GSDBR.updateRegistered = true
        end
        GSDBR.RefreshDisplay()
    else
        EVENT_MANAGER:UnregisterForUpdate("BeltalowdaGroupSynergyDisplayByRoles")
        GSDBR.updateRegistered = false
    end
end

function GSDBR.SetPreventMovement(value)
    GSDBR.settings.preventMovement = value
    GSDBR.SaveSettings()
    GSDBR.ApplySettings()
end

--[[
    Start dragging the coupled container (called from role windows / backdrop)
]]
function GSDBR.HandleDragStart()
    if GSDBR.settings.preventMovement then return end
    if not GSDBR.coupledContainer or not GSDBR.coupledContainer.control then return end
    if GSDBR.isDragging then return end
    GSDBR.isDragging = true
    -- Subtle drag feedback on all role windows
    for _, window in pairs(GSDBR.roleWindows) do
        if window and window.control then
            window.control:SetAlpha(0.7)
        end
    end
    GSDBR.coupledContainer.control:StartMoving()
end

--[[
    Stop dragging the coupled container
]]
function GSDBR.HandleDragStop()
    if not GSDBR.isDragging then return end
    if not GSDBR.coupledContainer or not GSDBR.coupledContainer.control then return end
    GSDBR.coupledContainer.control:StopMovingOrResizing()
    -- OnMoveStop handler handles isDragging=false, alpha restore, and position save
end

function GSDBR.SetCoupled(value)
    GSDBR.settings.coupled = value
    GSDBR.SaveSettings()
    GSDBR.ApplySettings()
    GSDBR.RefreshDisplay()
end

-- (SetDamageSynergyCount, SetSupportSynergyCount, RebuildSynergyColumns removed —
--  role-based tracker is dynamic-only, column count is driven by group composition)

-- ============================================================================
-- Settings Panel Controls
-- ============================================================================

function GSDBR.GetSettingsControls()
    return {
        {
            type = "submenu",
            name = "|c4592FFSynergy Tracker|r",
            tooltip = "Track synergy cooldowns organized by role (Damage/Support). Players appear when on cooldown and disappear when ready.",
            controls = {
                {
                    type = "description",
                    text = "Track synergy cooldowns by category. Synergies detected in the group are shown automatically. Drag icons or cooldown bars to reposition. Use the classic synergy tracker for manual synergy selection.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable Role-Based Synergy Tracker",
                    tooltip = "Show the role-based synergy tracker",
                    getFunc = function() return GSDBR.settings.enabled end,
                    setFunc = function(value) GSDBR.SetEnabled(value) end,
                    width = "full",
                    default = true,
                },
                {
                    type = "checkbox",
                    name = "Prevent Movement",
                    tooltip = "When enabled, windows cannot be dragged. When disabled, click and drag anywhere on the tracker to reposition it.",
                    getFunc = function() return GSDBR.settings.preventMovement end,
                    setFunc = function(value) GSDBR.SetPreventMovement(value) end,
                    width = "full",
                    default = false,
                },
                {
                    type = "checkbox",
                    name = "Hide Headers",
                    tooltip = "Hide the category headers (Damage / Support) to save space when tracking fewer synergies",
                    getFunc = function() return GSDBR.settings.hideHeaders end,
                    setFunc = function(value)
                        GSDBR.settings.hideHeaders = value
                        GSDBR.SaveSettings()
                        GSDBR.ApplySettings()
                        GSDBR.RefreshDisplay()
                    end,
                    width = "full",
                    default = true,
                },
                -- Synergy display order submenu
                {
                    type = "submenu",
                    name = "Synergy Display Order",
                    tooltip = "Set the preferred display order for synergies in dynamic mode. Preferred synergies appear first (left to right). Any additional synergies detected in the group appear after these.",
                    controls = (function()
                        local orderControls = {}
                        local SLOT_COUNT = 6

                        -- Build dropdown choice lists
                        local damageChoices = { "None" }
                        local damageValues = { 0 }
                        for _, synergy in ipairs(ST.DAMAGE_SYNERGIES) do
                            table.insert(damageChoices, synergy.name)
                            table.insert(damageValues, synergy.id)
                        end

                        local supportChoices = { "None" }
                        local supportValues = { 0 }
                        for _, synergy in ipairs(ST.SUPPORT_SYNERGIES) do
                            table.insert(supportChoices, synergy.name)
                            table.insert(supportValues, synergy.id)
                        end

                        -- Helper: swap duplicate on conflict
                        local function setSlotWithSwap(orderArray, slotIndex, newValue)
                            if newValue == 0 then
                                orderArray[slotIndex] = 0
                                return
                            end
                            -- Find if newValue is already used in another slot
                            for i = 1, SLOT_COUNT do
                                if i ~= slotIndex and orderArray[i] == newValue then
                                    -- Swap: give the other slot our old value
                                    orderArray[i] = orderArray[slotIndex] or 0
                                    break
                                end
                            end
                            orderArray[slotIndex] = newValue
                        end

                        -- Damage synergies header
                        table.insert(orderControls, {
                            type = "header",
                            name = "|cFF4D4DDamage Synergies|r",
                        })
                        for slot = 1, SLOT_COUNT do
                            table.insert(orderControls, {
                                type = "dropdown",
                                name = string.format("Position %d", slot),
                                tooltip = string.format("Synergy to show in position %d (leftmost = 1). Duplicates are swapped automatically.", slot),
                                choices = damageChoices,
                                choicesValues = damageValues,
                                getFunc = function()
                                    return GSDBR.settings.damageSynergyOrder[slot] or 0
                                end,
                                setFunc = function(value)
                                    setSlotWithSwap(GSDBR.settings.damageSynergyOrder, slot, value)
                                    GSDBR.SaveSettings()
                                    GSDBR.RebuildDynamicColumns()
                                end,
                                width = "full",
                                default = 0,
                            })
                        end

                        -- Support synergies header
                        table.insert(orderControls, {
                            type = "header",
                            name = "|c4D99FFSupport Synergies|r",
                        })
                        for slot = 1, SLOT_COUNT do
                            table.insert(orderControls, {
                                type = "dropdown",
                                name = string.format("Position %d", slot),
                                tooltip = string.format("Synergy to show in position %d (leftmost = 1). Duplicates are swapped automatically.", slot),
                                choices = supportChoices,
                                choicesValues = supportValues,
                                getFunc = function()
                                    return GSDBR.settings.supportSynergyOrder[slot] or 0
                                end,
                                setFunc = function(value)
                                    setSlotWithSwap(GSDBR.settings.supportSynergyOrder, slot, value)
                                    GSDBR.SaveSettings()
                                    GSDBR.RebuildDynamicColumns()
                                end,
                                width = "full",
                                default = 0,
                            })
                        end

                        return orderControls
                    end)(),
                },
                -- Category visibility
                {
                    type = "checkbox",
                    name = "Show Damage",
                    tooltip = "Show the Damage synergy window",
                    getFunc = function() return GSDBR.settings.showDamage end,
                    setFunc = function(value)
                        GSDBR.settings.showDamage = value
                        GSDBR.SaveSettings()
                        GSDBR.ApplySettings()
                        GSDBR.RefreshDisplay()
                    end,
                    width = "half",
                    default = true,
                },
                {
                    type = "checkbox",
                    name = "Show Support",
                    tooltip = "Show the Support synergy window",
                    getFunc = function() return GSDBR.settings.showSupport end,
                    setFunc = function(value)
                        GSDBR.settings.showSupport = value
                        GSDBR.SaveSettings()
                        GSDBR.ApplySettings()
                        GSDBR.RefreshDisplay()
                    end,
                    width = "half",
                    default = true,
                },
                -- Couple toggle
                {
                    type = "checkbox",
                    name = "Couple Damage and Support",
                    tooltip = "When enabled, Damage and Support windows move together as one block. When disabled, each window can be positioned independently.",
                    getFunc = function() return GSDBR.settings.coupled end,
                    setFunc = function(value) GSDBR.SetCoupled(value) end,
                    width = "full",
                    default = true,
                },
                -- Scale and opacity
                {
                    type = "slider",
                    name = "UI Scale",
                    tooltip = "Scale of the role-based synergy tracker windows",
                    min = 0.5,
                    max = 2.0,
                    step = 0.1,
                    getFunc = function() return GSDBR.settings.scale end,
                    setFunc = function(value)
                        GSDBR.settings.scale = value
                        GSDBR.ApplySettings()
                        GSDBR.SaveSettings()
                    end,
                    width = "full",
                    default = 1.0,
                },
                {
                    type = "slider",
                    name = "UI Opacity",
                    tooltip = "Transparency of the role-based synergy tracker windows",
                    min = 0.1,
                    max = 1.0,
                    step = 0.1,
                    getFunc = function() return GSDBR.settings.opacity end,
                    setFunc = function(value)
                        GSDBR.settings.opacity = value
                        GSDBR.ApplySettings()
                        GSDBR.SaveSettings()
                    end,
                    width = "full",
                    default = 1.0,
                },
            },
        },
    }
end
