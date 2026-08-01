-- Beltalowda Group Synergy Display (Classic)
-- Columnar synergy tracker: clickable header icons with player cooldown bars
-- Modeled on GroupUltimateDisplay.lua

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.GroupSynergyDisplay = Beltalowda.UI.GroupSynergyDisplay or {}

local GSD = Beltalowda.UI.GroupSynergyDisplay
local ST = Beltalowda.Data.SynergyTracker
local wm = WINDOW_MANAGER

-- ============================================================================
-- Constants
-- ============================================================================

GSD.SYNERGY_ICON_SIZE = 48
GSD.PLAYER_BLOCK_WIDTH = 48
GSD.PLAYER_BLOCK_HEIGHT = 20
GSD.COUNTDOWN_LABEL_HEIGHT = 14
GSD.MAX_SYNERGIES = 23
GSD.MAX_PLAYERS_PER_SYNERGY = 12
GSD.OFFSET = 12
GSD.DEFAULT_SYNERGY_COUNT = 6

-- Colors
GSD.COLORS = {
    COOLDOWN_FULL = {0.9, 0.2, 0.2, 1},      -- Red (just used synergy)
    COOLDOWN_LOW = {0.9, 0.6, 0.2, 1},        -- Orange (near end of cooldown)
    COOLDOWN_TEXT = {1, 1, 1, 1},              -- White countdown text
    PLAYER_NAME = {0.28515625, 0.8828125, 0.02734375, 1},  -- Green (matches ult tracker)
    BAR_BACKDROP = {0.5, 0.5, 0.5, 0.3},
}

-- Settings version
GSD.SETTINGS_VERSION = 2  -- Version 2: Updated default classic synergies

-- ============================================================================
-- Controls & State
-- ============================================================================

GSD.controls = {
    mainWindow = nil,
    synergyColumns = {},
}

GSD.menuHidden = false
GSD.pvpHidden = false
GSD.initialized = false
GSD.updateRegistered = false

-- Settings
GSD.settings = {
    enabled = false,  -- Disabled by default (role-based is primary)
    locked = false,
    scale = 1.0,
    opacity = 1.0,
    positionX = 400,
    positionY = 100,
    synergyCount = GSD.DEFAULT_SYNERGY_COUNT,
    synergyIds = {},
}

-- ============================================================================
-- Menu Visibility
-- ============================================================================

function GSD.SetMenuHidden(hidden)
    GSD.menuHidden = hidden
    GSD.ApplySettings()
end

function GSD.SetPvPHidden(hidden)
    GSD.pvpHidden = hidden
    GSD.ApplySettings()
end

-- ============================================================================
-- Initialization
-- ============================================================================

function GSD.Initialize()
    if GSD.initialized then return end

    GSD.LoadSettings()
    GSD.CreateMainWindow()
    GSD.CreateSynergyColumns()
    GSD.ApplySettings()
    GSD.RegisterForUpdates()

    GSD.initialized = true
    return true
end

-- ============================================================================
-- Settings Load/Save
-- ============================================================================

function GSD.LoadSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.groupSynergyDisplay = BeltalowdaVars.ui.groupSynergyDisplay or {}

    local saved = BeltalowdaVars.ui.groupSynergyDisplay
    local savedVersion = saved.version or 0
    local needsReset = (savedVersion < GSD.SETTINGS_VERSION)

    GSD.settings.enabled = (saved.enabled ~= nil) and saved.enabled or false
    GSD.settings.locked = (saved.locked ~= nil) and saved.locked or false
    GSD.settings.scale = saved.scale or 1.0
    GSD.settings.opacity = saved.opacity or 1.0
    GSD.settings.positionX = saved.positionX or 400
    GSD.settings.positionY = saved.positionY or 100
    GSD.settings.synergyCount = saved.synergyCount or GSD.DEFAULT_SYNERGY_COUNT

    -- Load synergy IDs or use defaults
    if needsReset or not saved.synergyIds or #saved.synergyIds ~= GSD.settings.synergyCount then
        GSD.settings.synergyIds = {}
        for i = 1, GSD.settings.synergyCount do
            GSD.settings.synergyIds[i] = ST.DEFAULT_CLASSIC_SYNERGIES[i] or 0
        end
    else
        GSD.settings.synergyIds = saved.synergyIds
    end
end

function GSD.SaveSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}

    BeltalowdaVars.ui.groupSynergyDisplay = {
        version = GSD.SETTINGS_VERSION,
        enabled = GSD.settings.enabled,
        locked = GSD.settings.locked,
        scale = GSD.settings.scale,
        opacity = GSD.settings.opacity,
        positionX = GSD.settings.positionX,
        positionY = GSD.settings.positionY,
        synergyCount = GSD.settings.synergyCount,
        synergyIds = GSD.settings.synergyIds,
    }
end

-- ============================================================================
-- Main Window
-- ============================================================================

function GSD.CreateMainWindow()
    local window = wm:GetControlByName("BeltalowdaGroupSynergyDisplay")
    if window then
        GSD.controls.mainWindow = window
        return
    end

    window = wm:CreateTopLevelWindow("BeltalowdaGroupSynergyDisplay")
    window:SetClampedToScreen(true)
    window:SetDrawLayer(DL_BACKGROUND)
    window:SetDrawLevel(0)
    window:SetMovable(not GSD.settings.locked)
    window:SetMouseEnabled(not GSD.settings.locked)
    window:SetHidden(not GSD.settings.enabled)
    window:SetAlpha(0)  -- Window background transparent

    local width = (GSD.SYNERGY_ICON_SIZE * GSD.settings.synergyCount) + (GSD.OFFSET * 2)
    local height = GSD.SYNERGY_ICON_SIZE + (GSD.OFFSET * 2)
    window:SetDimensions(width, height)

    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GSD.settings.positionX, GSD.settings.positionY)

    window:SetHandler("OnMoveStop", function()
        GSD.OnWindowMoved()
    end)

    -- Backdrop
    local backdrop = wm:CreateControl(nil, window, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    backdrop:SetDimensions(width, height)
    if GSD.settings.locked then
        backdrop:SetCenterColor(1, 0, 0, 0.0)
        backdrop:SetEdgeColor(1, 0, 0, 0.0)
    else
        backdrop:SetCenterColor(1, 0, 0, 0.5)
        backdrop:SetEdgeColor(1, 0, 0, 0.0)
    end
    backdrop:SetMouseEnabled(not GSD.settings.locked)

    backdrop:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not GSD.settings.locked then
            window:StartMoving()
        end
    end)
    backdrop:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not GSD.settings.locked then
            window:StopMovingOrResizing()
        end
    end)

    window.backdrop = backdrop
    GSD.controls.mainWindow = window
end

-- ============================================================================
-- Synergy Columns
-- ============================================================================

function GSD.CreateSynergyColumns()
    local mainWindow = GSD.controls.mainWindow
    for i = 1, GSD.MAX_SYNERGIES do
        local column = GSD.CreateSynergyColumn(mainWindow, i)
        GSD.controls.synergyColumns[i] = column
    end
end

function GSD.CreateSynergyColumn(parent, index)
    local column = {}

    -- Container
    local container = wm:CreateControl(nil, parent, CT_CONTROL)
    local xOffset = GSD.OFFSET + (GSD.SYNERGY_ICON_SIZE * (index - 1))
    container:SetAnchor(TOPLEFT, parent, TOPLEFT, xOffset, GSD.OFFSET)
    container:SetDimensions(GSD.SYNERGY_ICON_SIZE, GSD.SYNERGY_ICON_SIZE + (GSD.PLAYER_BLOCK_HEIGHT * GSD.MAX_PLAYERS_PER_SYNERGY))

    -- Button (clickable header)
    local button = wm:CreateControl(nil, container, CT_BUTTON)
    button:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    button:SetDimensions(GSD.SYNERGY_ICON_SIZE, GSD.SYNERGY_ICON_SIZE)
    button:SetNormalTexture("/esoui/art/actionbar/abilityframe64_up.dds")
    button:SetPressedTexture("/esoui/art/actionbar/abilityframe64_down.dds")
    button:SetMouseOverTexture("EsoUI/Art/ActionBar/actionBar_mouseOver.dds")
    button:SetHandler("OnClicked", function(control)
        GSD.ShowSynergySelectionDialog(index, control)
    end)

    -- Icon texture
    local icon = wm:CreateControl(nil, container, CT_TEXTURE)
    icon:SetAnchor(CENTER, button, CENTER, 0, 0)
    icon:SetDimensions(GSD.SYNERGY_ICON_SIZE - 4, GSD.SYNERGY_ICON_SIZE - 4)
    icon:SetTexture("/esoui/art/icons/ability_default.dds")
    
    -- Variant overlay for Combustion/Shards (1/4 size in bottom-right corner)
    local overlaySize = math.floor((GSD.SYNERGY_ICON_SIZE - 4) / 2)
    local variantOverlay = wm:CreateControl(nil, container, CT_TEXTURE)
    variantOverlay:SetAnchor(BOTTOMRIGHT, icon, BOTTOMRIGHT, 0, 0)
    variantOverlay:SetDimensions(overlaySize, overlaySize)
    variantOverlay:SetDrawLevel(3)
    variantOverlay:SetHidden(true)

    -- Tooltip
    button:SetHandler("OnMouseEnter", function(control)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -5)
        if column.synergyName then
            SetTooltipText(InformationTooltip, string.format("Click to change\n%s", column.synergyName))
        else
            SetTooltipText(InformationTooltip, "Click to select synergy")
        end
    end)
    button:SetHandler("OnMouseExit", function(control)
        ClearTooltip(InformationTooltip)
    end)

    -- Player blocks
    local playerBlocks = {}
    for j = 1, GSD.MAX_PLAYERS_PER_SYNERGY do
        local block = GSD.CreatePlayerBlock(container, j)
        playerBlocks[j] = block
    end

    column.container = container
    column.button = button
    column.icon = icon
    column.variantOverlay = variantOverlay
    column.playerBlocks = playerBlocks
    column.synergyId = GSD.settings.synergyIds[index] or 0

    -- Update icon
    GSD.UpdateSynergyIcon(column)

    return column
end

function GSD.UpdateSynergyIcon(column)
    local synergy = ST.GetSynergyById(column.synergyId)
    if synergy then
        -- Special handling for Combustion/Shards (synergy ID 1): show variant-specific icons
        if column.synergyId == 1 then
            GSD.UpdateSynergy1Icon(column, synergy)
        else
            column.icon:SetTexture(synergy.iconPath)
            if column.variantOverlay then
                column.variantOverlay:SetHidden(true)
            end
        end
        column.synergyName = synergy.name
    else
        column.icon:SetTexture("/esoui/art/icons/ability_default.dds")
        if column.variantOverlay then
            column.variantOverlay:SetHidden(true)
        end
        column.synergyName = nil
    end
end

--[[
    Update Combustion/Shards icon based on locally detected variants.
    - Only Orb detected → Necrotic Orb icon
    - Only Shards detected → Spear Shards icon
    - Both detected → first as main, second as 1/4 overlay
    - Neither detected (remote only) → default synergy icon
]]--
function GSD.UpdateSynergy1Icon(column, synergy)
    local SC = Beltalowda.Data and Beltalowda.Data.SynergyComposition
    local hasOrb = SC and SC.localSynergy1Variants and SC.localSynergy1Variants.orb
    local hasShards = SC and SC.localSynergy1Variants and SC.localSynergy1Variants.shards
    
    -- Also check last activation sub-type from combat events
    local lastActivation = ST.lastSynergy1ActivationSubtype
    if not hasOrb and not hasShards and lastActivation then
        if lastActivation == "orb" then hasOrb = true
        elseif lastActivation == "shards" then hasShards = true end
    end
    
    local orbIcon = SC and SC.synergy1IconCache and SC.synergy1IconCache.orb
    local shardsIcon = SC and SC.synergy1IconCache and SC.synergy1IconCache.shards
    
    -- Fallback: resolve icons from base ability IDs if not cached
    if not orbIcon and ST.SYNERGY1_BASE_ABILITY then
        orbIcon = GetAbilityIcon(ST.SYNERGY1_BASE_ABILITY.orb)
        if SC and SC.synergy1IconCache then SC.synergy1IconCache.orb = orbIcon end
    end
    if not shardsIcon and ST.SYNERGY1_BASE_ABILITY then
        shardsIcon = GetAbilityIcon(ST.SYNERGY1_BASE_ABILITY.shards)
        if SC and SC.synergy1IconCache then SC.synergy1IconCache.shards = shardsIcon end
    end
    
    if hasOrb and hasShards then
        -- Both detected: main = orb, overlay = shards
        column.icon:SetTexture(orbIcon or synergy.iconPath)
        if column.variantOverlay then
            column.variantOverlay:SetTexture(shardsIcon or synergy.iconPath)
            column.variantOverlay:SetHidden(false)
        end
    elseif hasOrb then
        column.icon:SetTexture(orbIcon or synergy.iconPath)
        if column.variantOverlay then
            column.variantOverlay:SetHidden(true)
        end
    elseif hasShards then
        column.icon:SetTexture(shardsIcon or synergy.iconPath)
        if column.variantOverlay then
            column.variantOverlay:SetHidden(true)
        end
    else
        -- No local detection: use default synergy icon
        column.icon:SetTexture(synergy.iconPath)
        if column.variantOverlay then
            column.variantOverlay:SetHidden(true)
        end
    end
end

-- ============================================================================
-- Player Blocks (cooldown bars beneath each synergy icon)
-- ============================================================================

function GSD.CreatePlayerBlock(parent, index)
    local block = {}

    local container = wm:CreateControl(nil, parent, CT_CONTROL)
    local yOffset = GSD.SYNERGY_ICON_SIZE + (GSD.PLAYER_BLOCK_HEIGHT * (index - 1))
    container:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, yOffset)
    container:SetDimensions(GSD.PLAYER_BLOCK_WIDTH, GSD.PLAYER_BLOCK_HEIGHT)
    container:SetHidden(true)

    -- Background (transparent - visual provided by bar backdrop)
    local backdrop = wm:CreateControl(nil, container, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    backdrop:SetDimensions(GSD.PLAYER_BLOCK_WIDTH, GSD.PLAYER_BLOCK_HEIGHT)
    backdrop:SetCenterColor(0, 0, 0, 0)
    backdrop:SetEdgeColor(0, 0, 0, 0)
    backdrop:SetEdgeTexture(nil, 1, 1, 1, 0)

    -- Cooldown progress bar (fills container minus 1px inset, matching RdK)
    local barHeight = GSD.PLAYER_BLOCK_HEIGHT - 2
    local progressBar = wm:CreateControl(nil, container, CT_STATUSBAR)
    progressBar:SetAnchor(TOPLEFT, container, TOPLEFT, 1, 1)
    progressBar:SetDimensions(GSD.PLAYER_BLOCK_WIDTH - 2, barHeight)
    progressBar:SetMinMax(0, 100)
    progressBar:SetValue(0)
    progressBar:SetColor(GSD.COLORS.COOLDOWN_FULL[1], GSD.COLORS.COOLDOWN_FULL[2], GSD.COLORS.COOLDOWN_FULL[3], GSD.COLORS.COOLDOWN_FULL[4])

    local barBackdrop = wm:CreateControl(nil, progressBar, CT_BACKDROP)
    barBackdrop:SetAnchor(TOPLEFT, progressBar, TOPLEFT, 0, 0)
    barBackdrop:SetDimensions(GSD.PLAYER_BLOCK_WIDTH - 2, barHeight)
    barBackdrop:SetCenterColor(GSD.COLORS.BAR_BACKDROP[1], GSD.COLORS.BAR_BACKDROP[2], GSD.COLORS.BAR_BACKDROP[3], GSD.COLORS.BAR_BACKDROP[4])
    barBackdrop:SetEdgeColor(0, 0, 0, 0)
    barBackdrop:SetDrawLevel(0)

    -- Player name label (anchored to progress bar, centered — matches ult tracker pattern)
    local nameLabel = wm:CreateControl(nil, container, CT_LABEL)
    nameLabel:SetAnchor(LEFT, progressBar, LEFT, 2, 0)
    nameLabel:SetFont("ZoFontGameSmall")
    nameLabel:SetText("")
    nameLabel:SetDimensions(GSD.PLAYER_BLOCK_WIDTH - 4, barHeight)
    nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetColor(GSD.COLORS.PLAYER_NAME[1], GSD.COLORS.PLAYER_NAME[2], GSD.COLORS.PLAYER_NAME[3], GSD.COLORS.PLAYER_NAME[4])
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

-- ============================================================================
-- Synergy Selection Dialog
-- ============================================================================

function GSD.ShowSynergySelectionDialog(columnIndex, control)
    ClearMenu()

    -- Two-level menu: top level shows category submenus
    AddMenuItem("Specific damage \226\134\146", function()
        zo_callLater(function()
            GSD.ShowCategoryMenu(columnIndex, control, ST.DAMAGE_SYNERGIES, "Damage")
        end, 100)
    end)

    AddMenuItem("Specific support \226\134\146", function()
        zo_callLater(function()
            GSD.ShowCategoryMenu(columnIndex, control, ST.SUPPORT_SYNERGIES, "Support")
        end, 100)
    end)

    ShowMenu(control)
end

function GSD.ShowCategoryMenu(columnIndex, control, synergies, categoryName)
    ClearMenu()

    AddMenuItem("\226\134\144 Back", function()
        zo_callLater(function()
            GSD.ShowSynergySelectionDialog(columnIndex, control)
        end, 100)
    end)

    for _, synergy in ipairs(synergies) do
        AddMenuItem(synergy.name, function()
            GSD.SetColumnSynergy(columnIndex, synergy.id)
        end)
    end

    ShowMenu(control)
end

function GSD.SetColumnSynergy(columnIndex, synergyId)
    if columnIndex < 1 or columnIndex > GSD.MAX_SYNERGIES then return end

    GSD.settings.synergyIds[columnIndex] = synergyId

    local column = GSD.controls.synergyColumns[columnIndex]
    if column then
        column.synergyId = synergyId
        GSD.UpdateSynergyIcon(column)
    end

    GSD.SaveSettings()
end

-- ============================================================================
-- Update Loop
-- ============================================================================

function GSD.RegisterForUpdates()
    if GSD.settings.enabled then
        EVENT_MANAGER:RegisterForUpdate("BeltalowdaGroupSynergyDisplay", 1000, function()
            GSD.RefreshDisplay()
        end)
        GSD.updateRegistered = true
    end
end

function GSD.RefreshDisplay()
    if not GSD.settings.enabled or GSD.menuHidden or GSD.pvpHidden then return end

    -- Clean up expired cooldowns periodically
    if ST.CleanupExpiredCooldowns then
        ST.CleanupExpiredCooldowns()
    end

    -- Track max rows for window resizing
    local maxPlayerCount = 0

    for i = 1, GSD.settings.synergyCount do
        local column = GSD.controls.synergyColumns[i]
        if not column then break end

        local synergyId = column.synergyId
        
        -- Refresh Combustion/Shards icon on each cycle (variant may change)
        if synergyId == 1 then
            GSD.UpdateSynergyIcon(column)
        end
        
        if synergyId and synergyId > 0 then
            local playersOnCooldown = ST.GetPlayersOnCooldown(synergyId)
            local playerCount = math.min(#playersOnCooldown, GSD.MAX_PLAYERS_PER_SYNERGY)

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

                    -- Truncate name to fit
                    local displayName = (player.unitTag and Beltalowda.GetDisplayName(player.unitTag)) or player.charName or ""
                    if #displayName > 7 then
                        displayName = string.sub(displayName, 1, 6) .. ".."
                    end
                    block.nameLabel:SetText(displayName)

                    -- Update cooldown bar (drains from 100 to 0)
                    local percent = player.percent * 100
                    block.progressBar:SetValue(percent)

                    -- Color interpolation: red when full → orange when low
                    local r = GSD.COLORS.COOLDOWN_FULL[1]
                    local g = GSD.COLORS.COOLDOWN_FULL[2] + (GSD.COLORS.COOLDOWN_LOW[2] - GSD.COLORS.COOLDOWN_FULL[2]) * (1 - player.percent)
                    local b = GSD.COLORS.COOLDOWN_FULL[3]
                    block.progressBar:SetColor(r, g, b, 1)
                end
            end

            -- Hide unused blocks
            for j = playerCount + 1, GSD.MAX_PLAYERS_PER_SYNERGY do
                local block = column.playerBlocks[j]
                if block then
                    block.container:SetHidden(true)
                end
            end
        else
            -- No synergy selected, hide all blocks
            for j = 1, GSD.MAX_PLAYERS_PER_SYNERGY do
                local block = column.playerBlocks[j]
                if block then
                    block.container:SetHidden(true)
                end
            end
        end
    end

    -- Resize main window to fit content
    GSD.ResizeMainWindow(maxPlayerCount)
end

function GSD.ResizeMainWindow(maxPlayerRows)
    local window = GSD.controls.mainWindow
    if not window then return end

    local width = (GSD.SYNERGY_ICON_SIZE * GSD.settings.synergyCount) + (GSD.OFFSET * 2)
    local height = GSD.SYNERGY_ICON_SIZE + (GSD.PLAYER_BLOCK_HEIGHT * maxPlayerRows) + (GSD.OFFSET * 2)
    window:SetDimensions(width, height)

    if window.backdrop then
        window.backdrop:SetDimensions(width, height)
    end
end

-- ============================================================================
-- Apply Settings
-- ============================================================================

function GSD.ApplySettings()
    local window = GSD.controls.mainWindow
    if not window then return end

    -- Hide if disabled, menu is open, or not in PvP zone
    if not GSD.settings.enabled or GSD.menuHidden or GSD.pvpHidden then
        window:SetHidden(true)
        return
    end

    window:SetHidden(false)
    window:SetMovable(not GSD.settings.locked)
    window:SetMouseEnabled(not GSD.settings.locked)
    window:SetScale(GSD.settings.scale)
    window:SetAlpha(GSD.settings.opacity)

    -- Update backdrop lock appearance
    if window.backdrop then
        window.backdrop:SetMouseEnabled(not GSD.settings.locked)
        if GSD.settings.locked then
            window.backdrop:SetCenterColor(1, 0, 0, 0.0)
            window.backdrop:SetEdgeColor(1, 0, 0, 0.0)
        else
            window.backdrop:SetCenterColor(1, 0, 0, 0.5)
            window.backdrop:SetEdgeColor(1, 0, 0, 0.0)
        end
    end

    -- Show/hide columns based on current synergy count
    for i = 1, GSD.MAX_SYNERGIES do
        local column = GSD.controls.synergyColumns[i]
        if column then
            column.container:SetHidden(i > GSD.settings.synergyCount)
        end
    end

    -- Resize window for current column count
    GSD.ResizeMainWindow(0)
end

-- ============================================================================
-- Event Handlers
-- ============================================================================

function GSD.OnWindowMoved()
    if GSD.settings.locked then return end
    local window = GSD.controls.mainWindow
    if not window then return end

    local left = window:GetLeft()
    local top = window:GetTop()
    if left and top then
        GSD.settings.positionX = left
        GSD.settings.positionY = top
        GSD.SaveSettings()
    end
end

-- ============================================================================
-- Public API
-- ============================================================================

function GSD.SetEnabled(enabled)
    GSD.settings.enabled = enabled
    GSD.SaveSettings()
    GSD.ApplySettings()

    if enabled then
        if not GSD.updateRegistered then
            EVENT_MANAGER:RegisterForUpdate("BeltalowdaGroupSynergyDisplay", 1000, function()
                GSD.RefreshDisplay()
            end)
            GSD.updateRegistered = true
        end
        GSD.RefreshDisplay()
    else
        EVENT_MANAGER:UnregisterForUpdate("BeltalowdaGroupSynergyDisplay")
        GSD.updateRegistered = false
    end
end

function GSD.SetLocked(locked)
    GSD.settings.locked = locked
    GSD.SaveSettings()
    GSD.ApplySettings()
end

function GSD.SetSynergyCount(count)
    count = math.max(1, math.min(GSD.MAX_SYNERGIES, count))
    GSD.settings.synergyCount = count

    -- Extend synergyIds array if needed
    while #GSD.settings.synergyIds < count do
        local nextDefault = ST.DEFAULT_CLASSIC_SYNERGIES[#GSD.settings.synergyIds + 1] or 0
        table.insert(GSD.settings.synergyIds, nextDefault)
    end

    GSD.SaveSettings()
    GSD.ApplySettings()
end

-- ============================================================================
-- Settings Panel
-- ============================================================================

function GSD.GetSettingsControls()
    return {
        {
            type = "submenu",
            name = "|c4592FFClassic Synergy Tracker|r",
            tooltip = "Columnar synergy tracker with clickable header icons and player cooldown bars",
            controls = {
                {
                    type = "description",
                    text = "Track synergy cooldowns with configurable columns. Click any synergy icon to choose which synergy to track. Players appear under a column when they take that synergy and are on cooldown.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable Classic Synergy Tracker",
                    tooltip = "Show the classic columnar synergy tracker",
                    getFunc = function() return GSD.settings.enabled end,
                    setFunc = function(value) GSD.SetEnabled(value) end,
                    width = "full",
                    default = false,
                },
                {
                    type = "checkbox",
                    name = "Lock UI",
                    tooltip = "Lock the classic synergy tracker in place",
                    getFunc = function() return GSD.settings.locked end,
                    setFunc = function(value) GSD.SetLocked(value) end,
                    width = "full",
                    default = false,
                },
                {
                    type = "slider",
                    name = "Synergy Count",
                    tooltip = "Number of synergy columns to display (1-23)",
                    min = 1,
                    max = 23,
                    step = 1,
                    getFunc = function() return GSD.settings.synergyCount end,
                    setFunc = function(value) GSD.SetSynergyCount(value) end,
                    width = "full",
                    default = GSD.DEFAULT_SYNERGY_COUNT,
                },
                {
                    type = "slider",
                    name = "UI Scale",
                    tooltip = "Scale of the classic synergy tracker",
                    min = 0.5,
                    max = 2.0,
                    step = 0.1,
                    getFunc = function() return GSD.settings.scale end,
                    setFunc = function(value)
                        GSD.settings.scale = value
                        GSD.ApplySettings()
                        GSD.SaveSettings()
                    end,
                    width = "full",
                    default = 1.0,
                },
                {
                    type = "slider",
                    name = "UI Opacity",
                    tooltip = "Transparency of the classic synergy tracker",
                    min = 0.1,
                    max = 1.0,
                    step = 0.1,
                    getFunc = function() return GSD.settings.opacity end,
                    setFunc = function(value)
                        GSD.settings.opacity = value
                        GSD.ApplySettings()
                        GSD.SaveSettings()
                    end,
                    width = "full",
                    default = 1.0,
                },
            },
        },
    }
end
