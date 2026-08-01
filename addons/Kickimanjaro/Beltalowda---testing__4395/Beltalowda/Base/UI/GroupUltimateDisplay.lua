-- Beltalowda Group Ultimate Display
-- Main UI for displaying group ultimate statuses
-- Inspired by RdK's ResourceOverview design

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.GroupUltimateDisplay = Beltalowda.UI.GroupUltimateDisplay or {}

local GUD = Beltalowda.UI.GroupUltimateDisplay
local wm = WINDOW_MANAGER

-- Constants
GUD.ULTIMATE_ICON_SIZE = 48
GUD.PLAYER_BLOCK_WIDTH = 48    -- Compact width matching RdK's coupled view
GUD.PLAYER_BLOCK_HEIGHT = 28   -- Ultimate (16px) + Magicka (6px) + Stamina (6px) = 28px total
GUD.RESOURCE_BAR_HEIGHT = 6    -- Height of magicka/stamina bars (slightly taller to fill gaps)
GUD.ULTIMATE_BAR_HEIGHT = 16   -- Height of ultimate bar (slightly larger for balanced appearance)
GUD.COMBAT_BORDER_WIDTH = 1    -- Width of combat state border (thin for compact view)
GUD.MAX_ULTIMATES = 12  -- Maximum number of ultimate columns (pre-created for dynamic count)
GUD.DEFAULT_ULTIMATE_COUNT = 4  -- Default visible columns (Volendrung is dynamic, not counted here)
GUD.MAX_PLAYERS_PER_ULTIMATE = 12
GUD.OFFSET = 12  -- Matches RdK exactly
GUD.VOLENDRUNG_ABILITY_ID = 116096  -- Ruinous Cyclone (Volendrung artifact ultimate)

-- Color constants (matching RdK values)
GUD.COLORS = {
    MAGICKA = {0.0, 0.0703125, 0.9453125},           -- Blue (RdK magicka bar)
    STAMINA = {0.0859375, 0.5703125, 0.1953125},     -- Green (RdK stamina bar)
    ULTIMATE_NOT_FULL = {0.359375, 0.54296875, 0.84375},  -- Light blue (RdK progress bar when < 100%)
    ULTIMATE_FULL = {0.30078125, 0.98046875, 0.22265625}, -- Bright green (RdK progress bar when 100%)
    PLAYER_NAME = {0.28515625, 0.8828125, 0.02734375},    -- Green (RdK player name color)
    IN_COMBAT = {1, 0, 0},                           -- Red
    OUT_OF_COMBAT = {0, 0, 0},                       -- Black
    MAX_ULT_WASTED = {1, 0.6, 0},                     -- Orange (max ult with ult-spending set)
}

-- Default ultimate abilities to track
-- Uses role-aggregate virtual IDs (negative)
-- Volendrung is handled as a special dynamic column, not part of user-configurable defaults
GUD.DEFAULT_ULTIMATES = {
    -1,      -- All Damage Ultimates (ROLE_ALL_DAMAGE_ID)
    -3,      -- All Shield Ultimates (ROLE_ALL_SHIELDS_ID)
    -2,      -- All Heal Ultimates (ROLE_ALL_HEALS_ID)
    -4,      -- All Utility Ultimates (ROLE_ALL_UTILITY_ID)
}

-- Simplified list of known ultimates for manual selection (testing)
-- Used in column override dropdowns
GUD.KNOWN_ULTIMATES = {
    -- Arcanist
    {id = 86117, name = "Gibbering Shelter"},
    
    -- Fighters Guild - Dawnbreaker (any morph)
    {id = 35713, name = "Dawnbreaker"},
    {id = 40158, name = "Flawless Dawnbreaker"},
    {id = 40156, name = "Dawnbreaker of Smiting"},
    
    -- Alliance War - Barrier (any morph)
    {id = 38573, name = "Barrier"},
    {id = 40237, name = "Reviving Barrier"},
    {id = 40239, name = "Replenishing Barrier"},
    
    -- Alliance War - War Horn
    {id = 38563, name = "War Horn"},
    {id = 40223, name = "Aggressive Horn"},
    {id = 40220, name = "Sturdy Horn"},
    
    -- Destruction Staff (all element variants)
    {id = 83619, name = "Elemental Storm"},
    {id = 83625, name = "Fire Storm"},
    {id = 83628, name = "Ice Storm"},
    {id = 83630, name = "Thunder Storm"},
    {id = 84434, name = "Elemental Rage"},
    {id = 85126, name = "Fiery Rage"},
    {id = 85128, name = "Icy Rage"},
    {id = 85130, name = "Thunderous Rage"},
    {id = 83642, name = "Eye of the Storm"},
    {id = 83682, name = "Eye of Flame"},
    {id = 83684, name = "Eye of Frost"},
    {id = 83686, name = "Eye of Lightning"},
    
    -- Templar - Sweep (any morph)
    {id = 22138, name = "Radial Sweep"},
    {id = 22139, name = "Crescent Sweep"},
    {id = 22144, name = "Empowering Sweep"},
}

-- Special IDs for "All [Role] Ultimates" tracking
-- Negative IDs are used to represent tracking all ultimates of a specific role
GUD.ROLE_ALL_DAMAGE_ID = -1
GUD.ROLE_ALL_HEALS_ID = -2
GUD.ROLE_ALL_SHIELDS_ID = -3
GUD.ROLE_ALL_UTILITY_ID = -4

-- Role-based "All Ultimates" special IDs and their representative icons
-- Using ESO's built-in power pellet and proc icons
GUD.ROLE_ALL_ICONS = {
    [GUD.ROLE_ALL_DAMAGE_ID] = {iconPath = "esoui/art/icons/powerpellet_health.dds", name = "All Damage Ultimates"},
    [GUD.ROLE_ALL_HEALS_ID] = {iconPath = "esoui/art/icons/powerpellet_stamina.dds", name = "All Heal Ultimates"},
    [GUD.ROLE_ALL_SHIELDS_ID] = {iconPath = "esoui/art/icons/powerpellet_magicka.dds", name = "All Shield Ultimates"},
    [GUD.ROLE_ALL_UTILITY_ID] = {iconPath = "esoui/art/icons/procs_001.dds", name = "All Utility Ultimates"},
}

-- Controls
GUD.controls = {
    mainWindow = nil,
    ultimateColumns = {},
    playerBlocks = {},
}

-- Dynamic Volendrung column tracking
-- This column appears/disappears automatically when someone in the group has Volendrung.
-- It uses a pre-created column (from the MAX_ULTIMATES pool) positioned after user columns.
GUD.volendrungColumnIndex = nil  -- Set dynamically in ApplySettings()

-- Menu visibility state (set by centralized layer handler)
GUD.menuHidden = false

-- PvP visibility state (set by centralized PvP zone handler)
GUD.pvpHidden = false

-- Settings version - increment when DEFAULT_ULTIMATES changes
GUD.SETTINGS_VERSION = 5  -- Version 5: Volendrung is now a dynamic column, removed from user-configurable defaults

--[[
    Set menu-hidden state (called by centralized layer handler)
]]--
function GUD.SetMenuHidden(hidden)
    GUD.menuHidden = hidden
    GUD.ApplySettings()
end

--[[
    Set PvP-hidden state (called by centralized PvP zone handler)
]]--
function GUD.SetPvPHidden(hidden)
    GUD.pvpHidden = hidden
    GUD.ApplySettings()
end

-- Settings (will be saved to SavedVariables)
GUD.settings = {
    enabled = false,  -- Disabled by default - role-based tracker is the primary view
    locked = false,
    scale = 1.0,
    opacity = 1.0,
    positionX = 100,
    positionY = 100,
    testMode = false,
    ultimateCount = GUD.DEFAULT_ULTIMATE_COUNT,
    ultimateIds = {},
    
    -- Compact display settings (RdK coupled style)
    showResourceBars = true,                   -- Show magicka/stamina bars
    showCombatState = true,                    -- Show combat state via border color
    combatBorderColor = {1, 0, 0, 1},         -- Red border when in combat
    outOfCombatBorderColor = {0, 0, 0, 1},    -- Black border when out of combat
}

-- Data tracking
GUD.playerData = {} -- Tracks which ultimate each player has selected

--[[
    Initialize the Group Ultimate Display UI
]]--
function GUD.Initialize()
    if GUD.initialized then return end
    
    -- Load settings from SavedVariables
    GUD.LoadSettings()
    
    -- Create main window
    GUD.CreateMainWindow()
    
    -- Create ultimate columns
    GUD.CreateUltimateColumns()
    
    -- Apply saved settings
    GUD.ApplySettings()
    
    -- Register for data updates
    GUD.RegisterForUpdates()
    
    GUD.initialized = true
    return true
end

--[[
    Load settings from SavedVariables
]]--
function GUD.LoadSettings()
    -- Initialize BeltalowdaVars if it doesn't exist yet
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.groupUltimateDisplay = BeltalowdaVars.ui.groupUltimateDisplay or {}
    
    local saved = BeltalowdaVars.ui.groupUltimateDisplay
    
    -- Check if saved version matches current version
    local savedVersion = saved.version or 0
    local needsReset = (savedVersion < GUD.SETTINGS_VERSION)
    
    -- Load or set defaults
    GUD.settings.enabled = (saved.enabled ~= nil) and saved.enabled or false
    GUD.settings.locked = (saved.locked ~= nil) and saved.locked or false
    GUD.settings.scale = saved.scale or 1.0
    GUD.settings.opacity = saved.opacity or 1.0
    GUD.settings.positionX = saved.positionX or 100
    GUD.settings.positionY = saved.positionY or 100
    GUD.settings.testMode = (saved.testMode ~= nil) and saved.testMode or false
    GUD.settings.ultimateCount = saved.ultimateCount or GUD.DEFAULT_ULTIMATE_COUNT
    
    -- Load compact display settings
    GUD.settings.showResourceBars = (saved.showResourceBars ~= nil) and saved.showResourceBars or true
    GUD.settings.showCombatState = (saved.showCombatState ~= nil) and saved.showCombatState or true
    GUD.settings.combatBorderColor = saved.combatBorderColor or {1, 0, 0, 1}
    GUD.settings.outOfCombatBorderColor = saved.outOfCombatBorderColor or {0, 0, 0, 1}
    
    -- Load ultimate IDs or use defaults
    -- Reset to defaults if version changed (indicates DEFAULT_ULTIMATES was updated)
    if needsReset or not saved.ultimateIds or #saved.ultimateIds ~= GUD.settings.ultimateCount then
        GUD.settings.ultimateIds = {}
        for i = 1, GUD.settings.ultimateCount do
            GUD.settings.ultimateIds[i] = GUD.DEFAULT_ULTIMATES[i] or 0
        end
    else
        GUD.settings.ultimateIds = saved.ultimateIds
    end
end

--[[
    Save settings to SavedVariables
]]--
function GUD.SaveSettings()
    -- Ensure BeltalowdaVars exists
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    
    BeltalowdaVars.ui.groupUltimateDisplay = {
        version = GUD.SETTINGS_VERSION,  -- Save version for future upgrades
        enabled = GUD.settings.enabled,
        locked = GUD.settings.locked,
        scale = GUD.settings.scale,
        opacity = GUD.settings.opacity,
        positionX = GUD.settings.positionX,
        positionY = GUD.settings.positionY,
        testMode = GUD.settings.testMode,
        ultimateCount = GUD.settings.ultimateCount,
        ultimateIds = GUD.settings.ultimateIds,
        
        -- Save compact display settings
        showResourceBars = GUD.settings.showResourceBars,
        showCombatState = GUD.settings.showCombatState,
        combatBorderColor = GUD.settings.combatBorderColor,
        outOfCombatBorderColor = GUD.settings.outOfCombatBorderColor,
    }
end

--[[
    Create main window container
]]--
function GUD.CreateMainWindow()
    -- Check if window already exists to prevent duplicate name errors
    local window = wm:GetControlByName("BeltalowdaGroupUltimateDisplay")
    if window then
        GUD.controls.window = window
        return
    end
    
    window = wm:CreateTopLevelWindow("BeltalowdaGroupUltimateDisplay")
    window:SetClampedToScreen(true)
    window:SetDrawLayer(DL_BACKGROUND)
    window:SetDrawLevel(0)
    window:SetMovable(not GUD.settings.locked)
    window:SetMouseEnabled(not GUD.settings.locked)  -- Matches RdK: both toggle together
    window:SetHidden(not GUD.settings.enabled)
    window:SetAlpha(0)  -- Make window background transparent - only content and backdrop visible
    
    -- Calculate window dimensions based on visible ultimate columns
    local width = (GUD.ULTIMATE_ICON_SIZE * GUD.settings.ultimateCount) + (GUD.OFFSET * 2)
    local height = GUD.ULTIMATE_ICON_SIZE + (GUD.OFFSET * 2)
    window:SetDimensions(width, height)
    
    -- Position window
    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GUD.settings.positionX, GUD.settings.positionY)
    
    -- Save position when moved
    window:SetHandler("OnMoveStop", function()
        GUD.OnWindowMoved()
    end)
    
    -- Create backdrop for dragging (matching RdK)
    local backdrop = wm:CreateControl(nil, window, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    backdrop:SetDimensions(width, height)
    -- Initial colors based on lock state (matches RdK exactly)
    if GUD.settings.locked then
        backdrop:SetCenterColor(1, 0, 0, 0.0)  -- Transparent when locked
        backdrop:SetEdgeColor(1, 0, 0, 0.0)
    else
        backdrop:SetCenterColor(1, 0, 0, 0.5)  -- Red semi-transparent fill when unlocked
        backdrop:SetEdgeColor(1, 0, 0, 0.0)
    end
    backdrop:SetMouseEnabled(not GUD.settings.locked)  -- Make backdrop draggable when unlocked
    
    -- Make backdrop draggable by forwarding drag events to parent window
    backdrop:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not GUD.settings.locked then
            window:StartMoving()
        end
    end)
    backdrop:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not GUD.settings.locked then
            window:StopMovingOrResizing()
        end
    end)
    
    window.backdrop = backdrop  -- Store reference for lock/unlock
    
    GUD.controls.mainWindow = window
end

--[[
    Create ultimate column displays
]]--
function GUD.CreateUltimateColumns()
    local mainWindow = GUD.controls.mainWindow
    
    for i = 1, GUD.MAX_ULTIMATES do
        local column = GUD.CreateUltimateColumn(mainWindow, i)
        GUD.controls.ultimateColumns[i] = column
    end
end

--[[
    Create a single ultimate column (icon + player blocks beneath)
]]--
function GUD.CreateUltimateColumn(parent, index)
    local column = {}
    
    -- Container for this column
    local container = wm:CreateControl(nil, parent, CT_CONTROL)
    local xOffset = GUD.OFFSET + (GUD.ULTIMATE_ICON_SIZE * (index - 1))
    container:SetAnchor(TOPLEFT, parent, TOPLEFT, xOffset, GUD.OFFSET)
    container:SetDimensions(GUD.ULTIMATE_ICON_SIZE, GUD.ULTIMATE_ICON_SIZE + (GUD.PLAYER_BLOCK_HEIGHT * GUD.MAX_PLAYERS_PER_ULTIMATE))
    
    -- Create button (matches RdK: CT_BUTTON works even when parent has SetMouseEnabled(false))
    local button = wm:CreateControl(nil, container, CT_BUTTON)
    button:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    button:SetDimensions(GUD.ULTIMATE_ICON_SIZE, GUD.ULTIMATE_ICON_SIZE)
    button:SetNormalTexture("/esoui/art/actionbar/abilityframe64_up.dds")
    button:SetPressedTexture("/esoui/art/actionbar/abilityframe64_down.dds")
    button:SetMouseOverTexture("EsoUI/Art/ActionBar/actionBar_mouseOver.dds")
    button:SetHandler("OnClicked", function(control)
        GUD.ShowUltimateSelectionDialog(index, control)
    end)
    
    -- Create icon texture on top of button
    local icon = wm:CreateControl(nil, container, CT_TEXTURE)
    icon:SetAnchor(CENTER, button, CENTER, 0, 0)
    icon:SetDimensions(GUD.ULTIMATE_ICON_SIZE - 4, GUD.ULTIMATE_ICON_SIZE - 4)
    icon:SetTexture("/esoui/art/icons/ability_default.dds")
    
    -- Tooltip on button
    button:SetHandler("OnMouseEnter", function(control)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -5)
        if GUD.volendrungColumnIndex and index == GUD.volendrungColumnIndex then
            SetTooltipText(InformationTooltip, "Ruinous Cyclone (Volendrung)\nAuto-detected in group")
        elseif column.abilityName then
            SetTooltipText(InformationTooltip, string.format("Click to change\n%s", column.abilityName))
        else
            SetTooltipText(InformationTooltip, "Click to select ultimate")
        end
    end)
    button:SetHandler("OnMouseExit", function(control)
        ClearTooltip(InformationTooltip)
    end)
    
    -- Player blocks (stacked beneath the icon)
    local playerBlocks = {}
    for j = 1, GUD.MAX_PLAYERS_PER_ULTIMATE do
        local block = GUD.CreatePlayerBlock(container, j)
        playerBlocks[j] = block
    end
    
    column.container = container
    column.button = button
    column.icon = icon
    column.playerBlocks = playerBlocks
    column.ultimateId = GUD.settings.ultimateIds[index] or 0
    
    -- Cache the icon path (RdK approach: call GetAbilityIcon once during initialization)
    local ultimateId = column.ultimateId
    local roleInfo = GUD.ROLE_ALL_ICONS[ultimateId]
    
    if roleInfo then
        -- Special "All [Role] Ultimates" ID - use direct icon path
        column.iconPath = roleInfo.iconPath
        column.abilityName = roleInfo.name
    elseif ultimateId and ultimateId > 0 then
        -- Regular specific ultimate
        column.iconPath = GetAbilityIcon(ultimateId)
        column.abilityName = GetAbilityName(ultimateId)
    else
        column.iconPath = nil
        column.abilityName = nil
    end
    
    -- Update icon texture based on cached icon path
    GUD.UpdateUltimateIcon(column)
    
    return column
end

--[[
    Show dialog to select which ultimate to track in a column
    Now dynamically builds list from detected ultimates (player's slotted + seen in group)
]]--
function GUD.ShowUltimateSelectionDialog(columnIndex, control)
    -- Don't show selection menu for the dynamic Volendrung column — it's not user-configurable
    if GUD.volendrungColumnIndex and columnIndex == GUD.volendrungColumnIndex then
        return
    end
    
    -- Two-level menu system organized by role categories
    -- Level 1: Role categories + specific ultimates
    -- Level 2: Specific ultimates within each category
    
    local GUDBR = Beltalowda.UI.GroupUltimateDisplayByRoles
    if not GUDBR or not GUDBR.ULTIMATE_ROLES then
        -- Fallback to old behavior if role system not loaded
        ClearMenu()
        for _, ult in ipairs(GUD.KNOWN_ULTIMATES) do
            AddMenuItem(ult.name, function()
                GUD.SetColumnUltimate(columnIndex, ult.id)
            end)
        end
        ShowMenu(control)
        return
    end
    
    -- Morph consolidation: map morph IDs to their representative base ID
    -- Only the representative ID will appear in menus
    local morphGroups = {
        -- 2H ultimates → Berserker Strike
        [83216] = 83216,  -- Berserker Strike (base, representative)
        [83229] = 83216,  -- Onslaught → Berserker Strike
        [83238] = 83216,  -- Berserker Rage → Berserker Strike
        
        -- Templar Aedric Spear → Radial Sweep
        [22138] = 22138,  -- Radial Sweep (base, representative)
        [22144] = 22138,  -- Everlasting Sweep → Radial Sweep
        [22139] = 22138,  -- Crescent Sweep → Radial Sweep
        
        -- Destruction Staff → Elemental Storm (all element-specific variants)
        [83619] = 83619,  -- Elemental Storm (base, representative)
        [83625] = 83619,  -- Fire Storm
        [83628] = 83619,  -- Ice Storm
        [83630] = 83619,  -- Thunder Storm
        [84434] = 83619,  -- Elemental Rage
        [85126] = 83619,  -- Fiery Rage
        [85128] = 83619,  -- Icy Rage
        [85130] = 83619,  -- Thunderous Rage
        [83642] = 83619,  -- Eye of the Storm
        [83682] = 83619,  -- Eye of Flame
        [83684] = 83619,  -- Eye of Frost
        [83686] = 83619,  -- Eye of Lightning
        
        -- Bow → Rapid Fire
        [83465] = 83465,  -- Rapid Fire (base, representative)
        [85257] = 83465,  -- Toxic Barrage → Rapid Fire
        [85451] = 83465,  -- Ballista → Rapid Fire
        
        -- Dual Wield → Lacerate
        [83600] = 83600,  -- Lacerate (base, representative)
        [85179] = 83600,  -- Thrive in Chaos → Lacerate
        [85187] = 83600,  -- Rend → Lacerate
        
        -- Fighter's Guild → Dawnbreaker
        [35713] = 35713,  -- Dawnbreaker (base, representative)
        [40161] = 35713,  -- Flawless Dawnbreaker → Dawnbreaker
        [40158] = 35713,  -- Dawnbreaker of Smiting → Dawnbreaker
        
        -- Mage's Guild → Meteor
        [16536] = 16536,  -- Meteor (base, representative)
        [40489] = 16536,  -- Ice Comet → Meteor
        [40493] = 16536,  -- Shooting Star → Meteor
    }
    
    -- Build categorized lists from ULTIMATE_ROLES mapping
    local damageUlts = {}
    local healUlts = {}
    local shieldUlts = {}
    local utilityUlts = {}
    local seenRepresentatives = {}  -- Track which representatives we've already added
    
    for abilityId, role in pairs(GUDBR.ULTIMATE_ROLES) do
        -- Skip Volendrung — it has its own dynamic column and shouldn't be user-selectable
        if abilityId == GUD.VOLENDRUNG_ABILITY_ID then
            -- nop
        else
        -- Check if this ability is part of a morph group
        local representativeId = morphGroups[abilityId] or abilityId
        
        -- Skip if we've already added this representative
        if not seenRepresentatives[representativeId] then
            local abilityName = GetAbilityName(representativeId)
            if abilityName and abilityName ~= "" then
                local entry = {id = representativeId, name = abilityName}
                if role == GUDBR.ROLE_DAMAGE then
                    table.insert(damageUlts, entry)
                    seenRepresentatives[representativeId] = true
                elseif role == GUDBR.ROLE_HEALS then
                    table.insert(healUlts, entry)
                    seenRepresentatives[representativeId] = true
                elseif role == GUDBR.ROLE_SHIELDS then
                    table.insert(shieldUlts, entry)
                    seenRepresentatives[representativeId] = true
                elseif role == GUDBR.ROLE_UTILITY then
                    table.insert(utilityUlts, entry)
                    seenRepresentatives[representativeId] = true
                end
            end
        end
        end -- else (skip Volendrung)
    end
    
    -- Sort each category alphabetically by name
    table.sort(damageUlts, function(a, b) return a.name < b.name end)
    table.sort(healUlts, function(a, b) return a.name < b.name end)
    table.sort(shieldUlts, function(a, b) return a.name < b.name end)
    table.sort(utilityUlts, function(a, b) return a.name < b.name end)
    
    -- Show Level 1 menu: role categories (Volendrung is dynamic, not user-selectable)
    ClearMenu()
    
    -- Icon size for menu items (inline texture in text)
    local MENU_ICON_SIZE = 20
    
    -- All category options grouped together (with role icons)
    if #damageUlts > 0 then
        local label = zo_iconTextFormat(GUD.ROLE_ALL_ICONS[GUD.ROLE_ALL_DAMAGE_ID].iconPath, MENU_ICON_SIZE, MENU_ICON_SIZE, "All damage")
        AddMenuItem(label, function()
            GUD.SetColumnUltimate(columnIndex, GUD.ROLE_ALL_DAMAGE_ID)
        end)
    end
    
    if #shieldUlts > 0 then
        local label = zo_iconTextFormat(GUD.ROLE_ALL_ICONS[GUD.ROLE_ALL_SHIELDS_ID].iconPath, MENU_ICON_SIZE, MENU_ICON_SIZE, "All shields")
        AddMenuItem(label, function()
            GUD.SetColumnUltimate(columnIndex, GUD.ROLE_ALL_SHIELDS_ID)
        end)
    end
    
    if #healUlts > 0 then
        local label = zo_iconTextFormat(GUD.ROLE_ALL_ICONS[GUD.ROLE_ALL_HEALS_ID].iconPath, MENU_ICON_SIZE, MENU_ICON_SIZE, "All heals")
        AddMenuItem(label, function()
            GUD.SetColumnUltimate(columnIndex, GUD.ROLE_ALL_HEALS_ID)
        end)
    end
    
    if #utilityUlts > 0 then
        local label = zo_iconTextFormat(GUD.ROLE_ALL_ICONS[GUD.ROLE_ALL_UTILITY_ID].iconPath, MENU_ICON_SIZE, MENU_ICON_SIZE, "All utility")
        AddMenuItem(label, function()
            GUD.SetColumnUltimate(columnIndex, GUD.ROLE_ALL_UTILITY_ID)
        end)
    end
    
    -- Specific category options grouped together
    if #damageUlts > 0 then
        AddMenuItem("Specific damage →", function()
            zo_callLater(function()
                GUD.ShowCategoryMenu(columnIndex, control, damageUlts, "Damage Ultimates")
            end, 100)
        end)
    end
    
    if #shieldUlts > 0 then
        AddMenuItem("Specific shields →", function()
            zo_callLater(function()
                GUD.ShowCategoryMenu(columnIndex, control, shieldUlts, "Shield Ultimates")
            end, 100)
        end)
    end
    
    if #healUlts > 0 then
        AddMenuItem("Specific heals →", function()
            zo_callLater(function()
                GUD.ShowCategoryMenu(columnIndex, control, healUlts, "Heal Ultimates")
            end, 100)
        end)
    end
    
    if #utilityUlts > 0 then
        AddMenuItem("Specific utility →", function()
            zo_callLater(function()
                GUD.ShowCategoryMenu(columnIndex, control, utilityUlts, "Utility Ultimates")
            end, 100)
        end)
    end
    
    ShowMenu(control)
end

--[[
    Show Level 2 menu: specific ultimates within a category
]]--
function GUD.ShowCategoryMenu(columnIndex, control, ultimates, categoryName)
    ClearMenu()
    
    -- Add header (back option)
    AddMenuItem("← Back", function()
        GUD.ShowUltimateSelectionDialog(columnIndex, control)
    end)
    
    -- Add all ultimates in this category (with ability icons)
    local MENU_ICON_SIZE = 20
    for _, ult in ipairs(ultimates) do
        local iconPath = GetAbilityIcon(ult.id)
        local label
        if iconPath and iconPath ~= "" then
            label = zo_iconTextFormat(iconPath, MENU_ICON_SIZE, MENU_ICON_SIZE, ult.name)
        else
            label = ult.name
        end
        AddMenuItem(label, function()
            GUD.SetColumnUltimate(columnIndex, ult.id)
        end)
    end
    
    ShowMenu(control)
end

--[[
    Set which ultimate a column should track
]]--
function GUD.SetColumnUltimate(columnIndex, abilityId)
    if columnIndex < 1 or columnIndex > GUD.MAX_ULTIMATES then return end
    
    -- Volendrung is handled as a dynamic column — don't allow manual assignment
    if abilityId == GUD.VOLENDRUNG_ABILITY_ID then return end
    
    -- Update settings
    GUD.settings.ultimateIds[columnIndex] = abilityId
    GUD.SaveSettings()
    
    -- Update column
    local column = GUD.controls.ultimateColumns[columnIndex]
    if column then
        column.ultimateId = abilityId
        
        -- Handle special "All [Role] Ultimates" IDs
        local roleInfo = GUD.ROLE_ALL_ICONS[abilityId]
        
        if roleInfo then
            -- Special "All [Role] Ultimates" ID - use direct icon path
            column.iconPath = roleInfo.iconPath
            column.abilityName = roleInfo.name
        else
            -- Regular specific ultimate - use ability icon
            column.iconPath = GetAbilityIcon(abilityId)
            column.abilityName = GetAbilityName(abilityId)
        end
        
        GUD.UpdateUltimateIcon(column)
        
        -- Explicitly clear all player blocks in this column since we're changing what it tracks
        if column.playerBlocks then
            for j = 1, GUD.MAX_PLAYERS_PER_ULTIMATE do
                local block = column.playerBlocks[j]
                if block then
                    block.unitTag = nil
                    block.playerName = nil
                    block.ultimatePercent = 0
                    block.magickaPercent = 0
                    block.staminaPercent = 0
                    if block.container then
                        block.container:SetHidden(true)
                    end
                    if block.progressBar then
                        block.progressBar:SetValue(0)
                    end
                    if block.nameLabel then
                        block.nameLabel:SetText("")
                    end
                    if block.magickaBar then
                        block.magickaBar:SetValue(0)
                    end
                    if block.staminaBar then
                        block.staminaBar:SetValue(0)
                    end
                end
            end
        end
    end
    
    -- Refresh display
    GUD.RefreshDisplay()
end

--[[
    Set the number of visible ultimate columns (1-11)
    Capped at MAX_ULTIMATES - 1 to reserve one slot for the dynamic Volendrung column
]]--
function GUD.SetUltimateCount(count)
    count = math.max(1, math.min(GUD.MAX_ULTIMATES - 1, count))
    GUD.settings.ultimateCount = count

    -- Extend ultimateIds array if needed
    while #GUD.settings.ultimateIds < count do
        local nextDefault = GUD.DEFAULT_ULTIMATES[#GUD.settings.ultimateIds + 1] or 0
        table.insert(GUD.settings.ultimateIds, nextDefault)
    end

    GUD.SaveSettings()
    GUD.ApplySettings()
end

--[[
    Create a compact player block for coupled mode (RdK style):
    - Narrow width (48px) to fit under ultimate icons
    - Ultimate progress bar
    - Thin resource bars (magicka/stamina)
    - Combat state border
    - Name/percentage in tooltip only
]]--
function GUD.CreatePlayerBlock(parent, index)
    local block = {}
    
    -- Container
    local container = wm:CreateControl(nil, parent, CT_CONTROL)
    local yOffset = GUD.ULTIMATE_ICON_SIZE + (GUD.PLAYER_BLOCK_HEIGHT * (index - 1))
    container:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, yOffset)
    container:SetDimensions(GUD.PLAYER_BLOCK_WIDTH, GUD.PLAYER_BLOCK_HEIGHT)
    container:SetHidden(true) -- Hidden by default until assigned
    
    -- Background
    local backdrop = wm:CreateControl(nil, container, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    backdrop:SetDimensions(GUD.PLAYER_BLOCK_WIDTH, GUD.PLAYER_BLOCK_HEIGHT)
    backdrop:SetCenterColor(0, 0, 0, 0)  -- Transparent center
    backdrop:SetEdgeColor(0, 0, 0, 0)    -- No edge (combat border handles this)
    
    -- Combat state border (created FIRST but will have highest DrawLevel)
    local combatBorder = wm:CreateControl(nil, container, CT_BACKDROP)
    combatBorder:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    combatBorder:SetDimensions(GUD.PLAYER_BLOCK_WIDTH, GUD.PLAYER_BLOCK_HEIGHT)
    combatBorder:SetCenterColor(0, 0, 0, 0)  -- Transparent center
    combatBorder:SetEdgeColor(0, 0, 0, 1)    -- Default to out of combat
    combatBorder:SetEdgeTexture(nil, GUD.COMBAT_BORDER_WIDTH, GUD.COMBAT_BORDER_WIDTH, GUD.COMBAT_BORDER_WIDTH, 0)
    combatBorder:SetDrawLevel(10)  -- Highest draw level to be on top of everything
    
    -- Calculate bar positions with fixed heights
    local barInset = GUD.COMBAT_BORDER_WIDTH
    local ultBarHeight = GUD.settings.showResourceBars and GUD.ULTIMATE_BAR_HEIGHT or (GUD.PLAYER_BLOCK_HEIGHT - (barInset * 2))
    
    -- Ultimate progress bar (taller bar for name display)
    local progressBar = wm:CreateControl(nil, container, CT_STATUSBAR)
    progressBar:SetAnchor(TOPLEFT, container, TOPLEFT, barInset, barInset)
    progressBar:SetDimensions(GUD.PLAYER_BLOCK_WIDTH - (barInset * 2), ultBarHeight)
    progressBar:SetMinMax(0, 100)
    progressBar:SetValue(0)
    
    -- Progress bar backdrop (color-coded for readiness)
    local barBackdrop = wm:CreateControl(nil, progressBar, CT_BACKDROP)
    barBackdrop:SetAnchor(TOPLEFT, progressBar, TOPLEFT, 0, 0)
    barBackdrop:SetDimensions(GUD.PLAYER_BLOCK_WIDTH - (barInset * 2), ultBarHeight)
    barBackdrop:SetCenterColor(0.5, 0.5, 0.5, 0.3)
    barBackdrop:SetEdgeColor(0, 0, 0, 0)
    barBackdrop:SetDrawLevel(0)
    
    -- Magicka bar (thin bar directly below ultimate, no gap)
    local magickaBar = wm:CreateControl(nil, container, CT_STATUSBAR)
    magickaBar:SetAnchor(TOPLEFT, container, TOPLEFT, barInset, barInset + ultBarHeight)
    magickaBar:SetDimensions(GUD.PLAYER_BLOCK_WIDTH - (barInset * 2), GUD.RESOURCE_BAR_HEIGHT)
    magickaBar:SetMinMax(0, 100)
    magickaBar:SetValue(0)
    magickaBar:SetColor(GUD.COLORS.MAGICKA[1], GUD.COLORS.MAGICKA[2], GUD.COLORS.MAGICKA[3])  -- Blue bar fill
    
    -- Magicka bar backdrop (background/unfilled portion)
    local magickaBackdrop = wm:CreateControl(nil, magickaBar, CT_BACKDROP)
    magickaBackdrop:SetAnchor(TOPLEFT, magickaBar, TOPLEFT, 0, 0)
    magickaBackdrop:SetDimensions(GUD.PLAYER_BLOCK_WIDTH - (barInset * 2), GUD.RESOURCE_BAR_HEIGHT)
    magickaBackdrop:SetCenterColor(0.5, 0.5, 0.5, 0.3)  -- Match ultimate bar background
    magickaBackdrop:SetEdgeColor(0, 0, 0, 0)
    magickaBackdrop:SetDrawLevel(0)
    
    -- Stamina bar (thin bar directly below magicka, no gap)
    local staminaBar = wm:CreateControl(nil, container, CT_STATUSBAR)
    staminaBar:SetAnchor(TOPLEFT, container, TOPLEFT, barInset, barInset + ultBarHeight + GUD.RESOURCE_BAR_HEIGHT)
    staminaBar:SetDimensions(GUD.PLAYER_BLOCK_WIDTH - (barInset * 2), GUD.RESOURCE_BAR_HEIGHT)
    staminaBar:SetMinMax(0, 100)
    staminaBar:SetValue(0)
    staminaBar:SetColor(GUD.COLORS.STAMINA[1], GUD.COLORS.STAMINA[2], GUD.COLORS.STAMINA[3])  -- Green bar fill
    
    -- Stamina bar backdrop (background/unfilled portion)
    local staminaBackdrop = wm:CreateControl(nil, staminaBar, CT_BACKDROP)
    staminaBackdrop:SetAnchor(TOPLEFT, staminaBar, TOPLEFT, 0, 0)
    staminaBackdrop:SetDimensions(GUD.PLAYER_BLOCK_WIDTH - (barInset * 2), GUD.RESOURCE_BAR_HEIGHT)
    staminaBackdrop:SetCenterColor(0.5, 0.5, 0.5, 0.3)  -- Match ultimate bar background
    staminaBackdrop:SetEdgeColor(0, 0, 0, 0)
    staminaBackdrop:SetDrawLevel(0)
    
    -- Player name label (green text, centered in ultimate bar, RdK style)
    local nameLabel = wm:CreateControl(nil, container, CT_LABEL)
    nameLabel:SetAnchor(LEFT, progressBar, LEFT, 2, 0)  -- Left aligned in ultimate bar with 2px padding
    nameLabel:SetFont("ZoFontGameSmall")
    nameLabel:SetText("")
    nameLabel:SetDimensions(GUD.PLAYER_BLOCK_WIDTH - 4, ultBarHeight)  -- Full height of ultimate bar
    nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)  -- Centered vertically within ultimate bar
    nameLabel:SetColor(GUD.COLORS.PLAYER_NAME[1], GUD.COLORS.PLAYER_NAME[2], GUD.COLORS.PLAYER_NAME[3], 1)
    nameLabel:SetDrawLevel(3)  -- Above bars and backdrop
    
    -- Enhanced tooltip showing all details (RdK compact style)
    container:SetMouseEnabled(true)
    container:SetHandler("OnMouseEnter", function(control)
        if block.unitTag then
            local charName = GetUnitName(block.unitTag)
            local acctName = string.sub(GetUnitDisplayName(block.unitTag), 2)  -- Remove @ prefix
            local ultPercent = block.ultimatePercent or 0
            local magPercent = block.magickaPercent or 0
            local stamPercent = block.staminaPercent or 0
            local combat = block.inCombat and "In Combat" or "Out of Combat"
            
            -- Look up ultimate ability name from playerData
            local ultName = "Unknown"
            local pd = GUD.playerData and GUD.playerData[charName]
            if pd and pd.selectedUltimateId and pd.selectedUltimateId > 0 then
                ultName = GetAbilityName(pd.selectedUltimateId) or "Unknown"
                
                -- Show both original and upgraded ult names when backbar differs
                if pd.backbarUltimateId and pd.backbarUltimateId > 0 and pd.backbarUltimateId ~= pd.selectedUltimateId then
                    local backName = GetAbilityName(pd.backbarUltimateId) or "Unknown"
                    ultName = string.format("%s / %s", ultName, backName)
                end
            end
            
            -- Show raw ult value instead of percentage
            local rawUlt = block.currentUlt or 0
            local ultDisplay = (rawUlt >= 500) and "MAX" or tostring(rawUlt)
            
            InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -5)
            -- Tooltip always shows both names for identification
            SetTooltipText(InformationTooltip, string.format("%s (@%s)\n%s\n%s\nUltimate: %s\nMagicka: %d%%\nStamina: %d%%", 
                charName, acctName, combat, ultName, ultDisplay, magPercent, stamPercent))
        end
    end)
    container:SetHandler("OnMouseExit", function(control)
        ClearTooltip(InformationTooltip)
    end)
    
    -- Store references
    block.container = container
    block.backdrop = backdrop
    block.combatBorder = combatBorder
    block.progressBar = progressBar
    block.barBackdrop = barBackdrop
    block.nameLabel = nameLabel
    block.magickaBar = magickaBar
    block.magickaBackdrop = magickaBackdrop
    block.staminaBar = staminaBar
    block.staminaBackdrop = staminaBackdrop
    block.unitTag = nil
    block.ultimatePercent = 0
    block.magickaPercent = 0
    block.staminaPercent = 0
    block.inCombat = false
    
    return block
end

--[[
    Update ultimate icon texture using cached icon path
    (RdK approach: use pre-fetched icon path instead of calling GetAbilityIcon every time)
]]--
function GUD.UpdateUltimateIcon(column)
    if not column or not column.icon then return end
    
    -- Use cached icon path from initialization
    if column.iconPath and column.iconPath ~= "" then
        column.icon:SetTexture(column.iconPath)
    else
        column.icon:SetTexture("/esoui/art/icons/ability_default.dds")
    end
end

--[[
    Check whether anyone in the group currently has Volendrung.
    Returns true if any player in GUD.playerData has hasVolendrung == true.
]]--
function GUD.IsVolendrungInGroup()
    for _, data in pairs(GUD.playerData) do
        if data.hasVolendrung then
            return true
        end
    end
    return false
end

--[[
    Apply settings to UI
]]--
function GUD.ApplySettings()
    local window = GUD.controls.mainWindow
    if not window then return end
    
    -- Apply scale
    window:SetScale(GUD.settings.scale)
    
    -- Apply opacity (alpha)
    window:SetAlpha(GUD.settings.opacity)
    
    -- Apply visibility
    window:SetHidden(not GUD.settings.enabled or GUD.menuHidden or GUD.pvpHidden)
    
    -- Apply lock state (matching RdK approach: both toggle together)
    window:SetMovable(not GUD.settings.locked)
    window:SetMouseEnabled(not GUD.settings.locked)
    
    -- Update backdrop color (matching RdK exactly)
    if window.backdrop then
        window.backdrop:SetMouseEnabled(not GUD.settings.locked)  -- Toggle backdrop draggability
        if GUD.settings.locked then
            window.backdrop:SetCenterColor(1, 0, 0, 0.0)  -- Transparent when locked
            window.backdrop:SetEdgeColor(1, 0, 0, 0.0)
        else
            window.backdrop:SetCenterColor(1, 0, 0, 0.5)  -- Red semi-transparent fill when unlocked
            window.backdrop:SetEdgeColor(1, 0, 0, 0.0)
        end
    end
    
    -- Show/hide user-configured columns, then append dynamic Volendrung column if present.
    -- Volendrung is never part of ultimateIds — it uses a dedicated pre-created column
    -- that appears/disappears based on group detection.
    local volendrungPresent = GUD.IsVolendrungInGroup()
    local visibleSlot = 0  -- running count of visible columns for contiguous anchoring
    
    -- Phase 1: User-configured columns (indices 1..ultimateCount)
    -- IMPORTANT: Always restore column identity from settings, because a column that was
    -- previously used as the dynamic Volendrung column retains stale .ultimateId/iconPath
    -- when it transitions back to being a user column (e.g., when ultimateCount increases).
    for i = 1, GUD.MAX_ULTIMATES do
        local column = GUD.controls.ultimateColumns[i]
        if column and column.container then
            if i <= GUD.settings.ultimateCount then
                -- Restore this column's identity from saved settings
                local userUltId = GUD.settings.ultimateIds[i] or 0
                column.ultimateId = userUltId
                local roleInfo = GUD.ROLE_ALL_ICONS[userUltId]
                if roleInfo then
                    column.iconPath = roleInfo.iconPath
                    column.abilityName = roleInfo.name
                elseif userUltId > 0 then
                    column.iconPath = GetAbilityIcon(userUltId)
                    column.abilityName = GetAbilityName(userUltId)
                else
                    column.iconPath = nil
                    column.abilityName = nil
                end
                GUD.UpdateUltimateIcon(column)
                
                -- User-configured column — always visible
                column.container:SetHidden(false)
                local xOffset = GUD.OFFSET + (GUD.ULTIMATE_ICON_SIZE * visibleSlot)
                column.container:ClearAnchors()
                column.container:SetAnchor(TOPLEFT, GUD.controls.mainWindow, TOPLEFT, xOffset, GUD.OFFSET)
                visibleSlot = visibleSlot + 1
            else
                -- Beyond user count — hide (Volendrung column will be un-hidden below if needed)
                column.container:SetHidden(true)
            end
        end
    end
    
    -- Phase 2: Dynamic Volendrung column (the first column after user columns)
    local volColIdx = GUD.settings.ultimateCount + 1
    GUD.volendrungColumnIndex = nil  -- Reset
    
    if volColIdx <= GUD.MAX_ULTIMATES then
        local volColumn = GUD.controls.ultimateColumns[volColIdx]
        if volColumn and volColumn.container then
            if volendrungPresent then
                -- Configure this column as the Volendrung tracker
                GUD.volendrungColumnIndex = volColIdx
                volColumn.ultimateId = GUD.VOLENDRUNG_ABILITY_ID
                volColumn.iconPath = GetAbilityIcon(GUD.VOLENDRUNG_ABILITY_ID)
                volColumn.abilityName = GetAbilityName(GUD.VOLENDRUNG_ABILITY_ID)
                GUD.UpdateUltimateIcon(volColumn)
                
                volColumn.container:SetHidden(false)
                local xOffset = GUD.OFFSET + (GUD.ULTIMATE_ICON_SIZE * visibleSlot)
                volColumn.container:ClearAnchors()
                volColumn.container:SetAnchor(TOPLEFT, GUD.controls.mainWindow, TOPLEFT, xOffset, GUD.OFFSET)
                visibleSlot = visibleSlot + 1
            else
                volColumn.container:SetHidden(true)
            end
        end
    end
    
    -- Resize window for visible column count
    local visibleColumnCount = visibleSlot
    local width = (GUD.ULTIMATE_ICON_SIZE * visibleColumnCount) + (GUD.OFFSET * 2)
    local height = GUD.ULTIMATE_ICON_SIZE + (GUD.OFFSET * 2)
    window:SetDimensions(width, height)
    if window.backdrop then
        window.backdrop:SetDimensions(width, height)
    end
    
    -- Update position
    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GUD.settings.positionX, GUD.settings.positionY)
    
    -- Also apply settings to uncoupled tracker by roles if it exists
    if Beltalowda.UI.GroupUltimateDisplayByRoles and Beltalowda.UI.GroupUltimateDisplayByRoles.ApplySettings then
        Beltalowda.UI.GroupUltimateDisplayByRoles.ApplySettings()
    end
end

--[[
    Handle window movement - save position (matching RdK approach)
]]--
function GUD.OnWindowMoved()
    -- Only save position when unlocked (matching RdK)
    if GUD.settings.locked then return end
    
    local window = GUD.controls.mainWindow
    if not window then return end
    
    -- Use GetLeft() and GetTop() like RdK does for accurate screen coordinates
    GUD.settings.positionX = window:GetLeft()
    GUD.settings.positionY = window:GetTop()
    
    GUD.SaveSettings()
end

--[[
    Register for data updates from network layer
]]--
function GUD.RegisterForUpdates()
    -- Hook into network data change callback
    if Beltalowda.network then
        -- Store the original callback if it exists (it might just be a placeholder)
        local originalCallback = Beltalowda.network.OnDataChanged
        
        Beltalowda.network.OnDataChanged = function(dataType, unitTag)
            -- Call original callback if it was a real function
            if originalCallback and type(originalCallback) == "function" then
                originalCallback(dataType, unitTag)
            end
            
            -- Update UI when ultimate data changes
            if dataType == "ultimate" then
                GUD.OnUltimateDataChanged(unitTag)
            end
        end
        
    end
    
    -- Update periodically, but less frequently (every 5 seconds instead of 1)
    -- This gives manual broadcasts time to propagate without being immediately overwritten
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaGroupUltimateDisplay", 5000, function()
        GUD.RefreshDisplay()
    end)
    
    -- Register for Volendrung state changes so we can show/hide the Volendrung column
    if Beltalowda.BuffMonitor and Beltalowda.BuffMonitor.RegisterVolendrungCallback then
        Beltalowda.BuffMonitor.RegisterVolendrungCallback("GUD_VolendrungColumn", function(unitTag, hasVolendrung)
            -- Re-apply settings (handles column visibility + window sizing) then refresh player blocks
            GUD.ApplySettings()
            GUD.RefreshDisplay()
        end)
    end
    
end

--[[
    Handle ultimate data change for a specific unit
]]--
function GUD.OnUltimateDataChanged(unitTag)
    -- Update the display for this player
    GUD.UpdatePlayerDisplay(unitTag)
end

--[[
    Update display for a specific player with enhanced data
    Shows ultimate, resources, player name, and combat state
]]--
function GUD.UpdatePlayerDisplay(unitTag)
    if not unitTag then return end
    
    local UT = Beltalowda.Data.UltimateTracker
    local playerName = GetUnitName(unitTag)
    local abilityId = nil
    local percent = 0
    local magickaPercent = 0
    local staminaPercent = 0
    local inCombat = false
    
    -- Get player data from network broadcasts
    if GUD.playerData[playerName] and GUD.playerData[playerName].selectedUltimateId and GUD.playerData[playerName].selectedUltimateId > 0 then
        -- Use broadcasted data
        abilityId = GUD.playerData[playerName].selectedUltimateId
        percent = GUD.playerData[playerName].ultimatePercent or 0
        magickaPercent = GUD.playerData[playerName].magickaPercent or 0
        staminaPercent = GUD.playerData[playerName].staminaPercent or 0
        inCombat = GUD.playerData[playerName].inCombat or false
        
        -- Register this ultimate with the tracker
        UT.RegisterUltimate(abilityId)
    else
        -- No data yet for this player - don't display anything
        return
    end
    
    -- Find which ultimate column this player belongs to
    local columnIndex = GUD.FindUltimateColumn(abilityId)
    if not columnIndex then
        -- This ultimate isn't in our tracked list
        return
    end
    
    -- CRITICAL: Remove this player from ALL other columns first
    -- This prevents duplicate tracking when ultimate changes (e.g., Gibber -> Ruinous Cyclone with Volendrung)
    local playerWasMovedBetweenColumns = false
    for i = 1, GUD.MAX_ULTIMATES do
        if i ~= columnIndex then
            local otherColumn = GUD.controls.ultimateColumns[i]
            if otherColumn and otherColumn.playerBlocks then
                -- Search for this player in the other column and remove them
                for j = 1, GUD.MAX_PLAYERS_PER_ULTIMATE do
                    local block = otherColumn.playerBlocks[j]
                    if block then
                        -- Check multiple ways to identify this player
                        local isThisPlayer = false
                        
                        -- Method 1: Compare stored playerName
                        if block.playerName and playerName and block.playerName == playerName then
                            isThisPlayer = true
                        end
                        
                        -- Method 2: Compare via unitTag (if still valid)
                        if not isThisPlayer and block.unitTag then
                            local blockPlayerName = GetUnitName(block.unitTag)
                            if blockPlayerName and blockPlayerName == playerName then
                                isThisPlayer = true
                            end
                        end
                        
                        if isThisPlayer then
                            playerWasMovedBetweenColumns = true
                            -- Mark as stale - make it visually grayed out
                            block.unitTag = nil
                            block.playerName = nil
                            block.ultimatePercent = 0
                            block.magickaPercent = 0
                            block.staminaPercent = 0
                            if block.container then
                                -- Make it semi-transparent to show it's stale
                                block.container:SetAlpha(0.3)
                            end
                            if block.progressBar then
                                block.progressBar:SetValue(0)
                            end
                            if block.nameLabel then
                                -- Add "[STALE]" prefix to player name
                                local currentName = block.nameLabel:GetText()
                                if currentName and currentName ~= "" and not string.match(currentName, "^%[STALE%]") then
                                    block.nameLabel:SetText("[STALE] " .. currentName)
                                end
                            end
                            if block.magickaBar then
                                block.magickaBar:SetValue(0)
                            end
                            if block.staminaBar then
                                block.staminaBar:SetValue(0)
                            end
                            --  Don't break - player might appear multiple times due to bugs
                        end
                    end
                end
            end
        end
    end
    
    local column = GUD.controls.ultimateColumns[columnIndex]
    if not column then return end
    
    -- Find or assign a player block for this player
    local blockIndex = GUD.FindOrAssignPlayerBlock(column, unitTag)
    if not blockIndex then return end
    
    local block = column.playerBlocks[blockIndex]
    if not block then return end
    
    -- Update block display (compact mode - no text overlays)
    block.container:SetHidden(false)
    
    -- Update player name label (character name, green text like RdK)
    -- NOTE: playerName already declared at line 741, don't redeclare
    if block.nameLabel and playerName then
        block.nameLabel:SetText(Beltalowda.GetDisplayName(unitTag))
    end
    
    -- Store player name in block for reliable cleanup (unitTag can become nil)
    block.playerName = playerName
    
    -- Update ultimate progress bar
    block.progressBar:SetValue(percent)
    block.ultimatePercent = percent
    -- Derive raw ult from percentage + cost (more reliable than LGCS currentUlt)
    local pd = GUD.playerData[playerName]
    if pd and pd.ultimatePercent and pd.selectedUltimateId and pd.selectedUltimateId > 0 then
        local cost = GetAbilityCost(pd.selectedUltimateId)
        if cost and cost > 0 then
            block.currentUlt = math.floor((pd.ultimatePercent / 100) * cost)
        else
            block.currentUlt = pd.currentUlt or 0
        end
    else
        block.currentUlt = pd and pd.currentUlt or 0
    end
    
    -- Update resource bars (if enabled)
    if GUD.settings.showResourceBars then
        block.magickaBar:SetHidden(false)
        block.staminaBar:SetHidden(false)
        block.magickaBackdrop:SetHidden(false)
        block.staminaBackdrop:SetHidden(false)
        block.magickaBar:SetValue(magickaPercent)
        block.staminaBar:SetValue(staminaPercent)
        block.magickaPercent = magickaPercent
        block.staminaPercent = staminaPercent
        
        -- Set full height with resources visible
        local fullHeight = GUD.PLAYER_BLOCK_HEIGHT
        block.container:SetHeight(fullHeight)
        block.backdrop:SetHeight(fullHeight)
        block.combatBorder:SetHeight(fullHeight)
    else
        -- Hide resource bars and their backdrops completely
        block.magickaBar:SetHidden(true)
        block.staminaBar:SetHidden(true)
        block.magickaBackdrop:SetHidden(true)
        block.staminaBackdrop:SetHidden(true)
        
        -- Shrink player block to just fit ultimate bar + border
        local compactHeight = GUD.ULTIMATE_BAR_HEIGHT + (GUD.COMBAT_BORDER_WIDTH * 2)
        block.container:SetHeight(compactHeight)
        block.backdrop:SetHeight(compactHeight)
        block.combatBorder:SetHeight(compactHeight)
    end
    
    -- Update combat state border (if enabled)
    if GUD.settings.showCombatState then
        local borderColor = inCombat and GUD.settings.combatBorderColor or GUD.settings.outOfCombatBorderColor
        block.combatBorder:SetEdgeColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
        block.inCombat = inCombat
    else
        block.combatBorder:SetEdgeColor(0, 0, 0, 0)  -- Transparent border
    end
    
    -- Color code ultimate bar based on readiness
    GUD.UpdateBlockColor(block, percent)
end

--[[
    Find which column should display a specific ultimate ability.
    
    Three-pass approach:
      0. Volendrung intercept — always routes to the dynamic Volendrung column
      1. Exact ID match in user-configured columns
      2. Role-aggregate match ("All Damage", "All Heals", etc.)
    
    Volendrung is never in user columns. Players carrying Volendrung are routed
    to the dynamic column (GUD.volendrungColumnIndex) which only exists when
    someone in the group has it.
]]--
function GUD.FindUltimateColumn(abilityId)
    -- Pass 0: Volendrung always routes to the dedicated dynamic column
    if abilityId == GUD.VOLENDRUNG_ABILITY_ID then
        return GUD.volendrungColumnIndex  -- nil if nobody has Volendrung (column hidden)
    end
    
    -- Pass 1: Exact ability ID match in user-configured columns
    for i = 1, GUD.settings.ultimateCount do
        local columnUltimateId = GUD.settings.ultimateIds[i]
        if columnUltimateId == abilityId then
            return i
        end
    end
    
    -- Pass 2: Role-aggregate match (fallback for "All [Role]" columns)
    local GUDBR = Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplayByRoles
    if GUDBR and GUDBR.ULTIMATE_ROLES then
        local playerUltRole = GUDBR.ULTIMATE_ROLES[abilityId]
        if playerUltRole then
            for i = 1, GUD.settings.ultimateCount do
                local columnUltimateId = GUD.settings.ultimateIds[i]
                if columnUltimateId == GUD.ROLE_ALL_DAMAGE_ID and playerUltRole == GUDBR.ROLE_DAMAGE then
                    return i
                elseif columnUltimateId == GUD.ROLE_ALL_HEALS_ID and playerUltRole == GUDBR.ROLE_HEALS then
                    return i
                elseif columnUltimateId == GUD.ROLE_ALL_SHIELDS_ID and playerUltRole == GUDBR.ROLE_SHIELDS then
                    return i
                elseif columnUltimateId == GUD.ROLE_ALL_UTILITY_ID and playerUltRole == GUDBR.ROLE_UTILITY then
                    return i
                end
            end
        end
    end
    return nil
end

--[[
    Find or assign a player block in a column
]]--
function GUD.FindOrAssignPlayerBlock(column, unitTag)
    local playerName = GetUnitName(unitTag)
    
    -- First check if this player (by name) already has a block in this column
    -- This prevents duplicates when the same player might be referenced by different unitTags
    for i = 1, GUD.MAX_PLAYERS_PER_ULTIMATE do
        local block = column.playerBlocks[i]
        -- Check stored playerName first (persists even after unitTag cleared)
        if block.playerName == playerName then
            -- Update the unitTag to the current one (in case it changed)
            block.unitTag = unitTag
            return i
        end
        -- Fall back to unitTag comparison if playerName not set
        if block.unitTag then
            local blockPlayerName = GetUnitName(block.unitTag)
            if blockPlayerName == playerName then
                -- Update the unitTag to the current one (in case it changed)
                block.unitTag = unitTag
                return i
            end
        end
    end
    
    -- Find first empty block (both unitTag AND playerName must be nil)
    for i = 1, GUD.MAX_PLAYERS_PER_ULTIMATE do
        local block = column.playerBlocks[i]
        if not block.unitTag and not block.playerName then
            block.unitTag = unitTag
            return i
        end
    end
    
    return nil
end

--[[
    Get group index for a unit tag
]]--
function GUD.GetGroupIndex(unitTag)
    if unitTag == "player" then
        return GetGroupIndexByUnitTag("player") or 0
    end
    
    -- Extract group index from unit tag (e.g., "group1" -> 1)
    local index = tonumber(string.match(unitTag, "group(%d+)"))
    return index or 0
end

--[[
    Update block color based on ultimate percentage (RdK style)
]]--
function GUD.UpdateBlockColor(block, percent)
    if not block or not block.progressBar then return end
    
    if percent >= 100 then
        -- Full - bright green (RdK full color)
        block.progressBar:SetColor(GUD.COLORS.ULTIMATE_FULL[1], GUD.COLORS.ULTIMATE_FULL[2], GUD.COLORS.ULTIMATE_FULL[3])
    else
        -- Not full - light blue (RdK not full color)
        block.progressBar:SetColor(GUD.COLORS.ULTIMATE_NOT_FULL[1], GUD.COLORS.ULTIMATE_NOT_FULL[2], GUD.COLORS.ULTIMATE_NOT_FULL[3])
    end
end

--[[
    Reposition all player blocks based on current showResourceBars setting
]]--
function GUD.RepositionPlayerBlocks()
    local blockHeight = GUD.settings.showResourceBars and GUD.PLAYER_BLOCK_HEIGHT or (GUD.ULTIMATE_BAR_HEIGHT + (GUD.COMBAT_BORDER_WIDTH * 2))
    
    for i = 1, GUD.MAX_ULTIMATES do
        local column = GUD.controls.ultimateColumns[i]
        if column and column.playerBlocks then
            for j = 1, GUD.MAX_PLAYERS_PER_ULTIMATE do
                local block = column.playerBlocks[j]
                if block and block.container then
                    local yOffset = GUD.ULTIMATE_ICON_SIZE + (blockHeight * (j - 1))
                    block.container:ClearAnchors()
                    block.container:SetAnchor(TOPLEFT, column.container, TOPLEFT, 0, yOffset)
                end
            end
        end
    end
end

--[[
    Refresh entire display (all players, all columns).
    Coalesces rapid calls: when multiple network messages arrive in the same
    frame, only one actual rebuild executes (deferred to next frame via
    zo_callLater).  A full-group burst of 12 heartbeats in one frame becomes
    a single Clear → Reposition → Sort → Update pass instead of 12.
]]--
function GUD.RefreshDisplay()
    if not GUD.settings.enabled then return end
    if not Beltalowda.network then return end

    if not GUD._refreshPending then
        GUD._refreshPending = true
        zo_callLater(function()
            GUD._refreshPending = false
            GUD._DoRefreshDisplay()
        end, 0)
    end
end

--[[
    Internal: actual display rebuild (separated from RefreshDisplay for
    frame-coalescing).
]]--
function GUD._DoRefreshDisplay()
    if not GUD.settings.enabled then return end
    if not Beltalowda.network then return end
    
    -- Reposition blocks first (in case showResourceBars changed)
    GUD.RepositionPlayerBlocks()
    
    -- Clear all player blocks
    GUD.ClearAllPlayerBlocks()
    
    -- Organize players by column
    local playersByColumn = {}
    for i = 1, GUD.MAX_ULTIMATES do
        playersByColumn[i] = {}
    end
    
    -- Collect all unique players by name (to avoid duplicates when player is both "player" and "group1")
    local playersByName = {}
    
    -- Add player
    local playerName = GetUnitName("player")
    if playerName then
        playersByName[playerName] = "player"
    end
    
    -- Add all group members (will overwrite if player is in group, which is fine)
    local groupSize = GetGroupSize()
    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then
            local name = GetUnitName(unitTag)
            if name then
                playersByName[name] = unitTag
            end
        end
    end
    
    -- Categorize players by column
    for playerName, unitTag in pairs(playersByName) do
        if GUD.playerData[playerName] and GUD.playerData[playerName].selectedUltimateId and GUD.playerData[playerName].selectedUltimateId > 0 then
            local abilityId = GUD.playerData[playerName].selectedUltimateId
            local columnIndex = GUD.FindUltimateColumn(abilityId)
            
            if columnIndex then
                table.insert(playersByColumn[columnIndex], {
                    unitTag = unitTag,
                    playerName = playerName,
                    data = GUD.playerData[playerName],
                })
            end
        end
    end
    
    -- Sort players within each column by ultimate readiness (descending), then by name
    for columnIndex, players in pairs(playersByColumn) do
        table.sort(players, function(a, b)
            local aPercent = a.data.ultimatePercent or 0
            local bPercent = b.data.ultimatePercent or 0
            
            -- Primary sort: ultimate percentage (higher first)
            if aPercent ~= bPercent then
                return aPercent > bPercent
            end
            
            -- Secondary sort: player name (alphabetical)
            return a.playerName < b.playerName
        end)
    end
    
    -- Update display for each column with sorted players
    for columnIndex, players in pairs(playersByColumn) do
        local column = GUD.controls.ultimateColumns[columnIndex]
        if column then
            for blockIndex, playerInfo in ipairs(players) do
                if blockIndex <= GUD.MAX_PLAYERS_PER_ULTIMATE then
                    GUD.UpdatePlayerBlock(column, blockIndex, playerInfo.unitTag, playerInfo.playerName, playerInfo.data)
                end
            end
        end
    end
end

--[[
    Clear all player blocks
]]--
function GUD.ClearAllPlayerBlocks()
    for i = 1, GUD.MAX_ULTIMATES do
        local column = GUD.controls.ultimateColumns[i]
        if column then
            for j = 1, GUD.MAX_PLAYERS_PER_ULTIMATE do
                local block = column.playerBlocks[j]
                if block then
                    -- Thoroughly clear all block data
                    block.unitTag = nil
                    block.playerName = nil  -- Clear stored name too
                    block.ultimatePercent = 0
                    block.magickaPercent = 0
                    block.staminaPercent = 0
                    if block.container then
                        block.container:SetHidden(true)
                    end
                    if block.progressBar then
                        block.progressBar:SetValue(0)
                    end
                    if block.nameLabel then
                        block.nameLabel:SetText("")
                    end
                    if block.magickaBar then
                        block.magickaBar:SetValue(0)
                    end
                    if block.staminaBar then
                        block.staminaBar:SetValue(0)
                    end
                end
            end
        end
    end
end

--[[
    Update a specific player block with data
]]--
function GUD.UpdatePlayerBlock(column, blockIndex, unitTag, playerName, data)
    if not column or not column.playerBlocks then return end
    
    local block = column.playerBlocks[blockIndex]
    if not block then return end
    
    local UT = Beltalowda.Data.UltimateTracker
    
    -- Extract data
    local percent = data.ultimatePercent or 0
    local magickaPercent = data.magickaPercent or 0
    local staminaPercent = data.staminaPercent or 0
    local inCombat = data.inCombat or false
    
    -- Update block
    block.unitTag = unitTag
    block.playerName = playerName
    block.ultimatePercent = percent
    -- Derive raw ult from percentage + cost
    if data.ultimatePercent and data.selectedUltimateId and data.selectedUltimateId > 0 then
        local cost = GetAbilityCost(data.selectedUltimateId)
        if cost and cost > 0 then
            block.currentUlt = math.floor((data.ultimatePercent / 100) * cost)
        else
            block.currentUlt = data.currentUlt or 0
        end
    else
        block.currentUlt = data.currentUlt or 0
    end
    block.magickaPercent = magickaPercent
    block.staminaPercent = staminaPercent
    
    -- Show block
    block.container:SetHidden(false)
    block.container:SetAlpha(1.0)  -- Ensure full opacity
    
    -- Update player name label
    if block.nameLabel and playerName then
        block.nameLabel:SetText(Beltalowda.GetDisplayName(unitTag))
    end
    
    -- Update ultimate progress bar
    block.progressBar:SetValue(percent)
    
    -- Update resource bars (if enabled)
    if GUD.settings.showResourceBars then
        block.magickaBar:SetHidden(false)
        block.staminaBar:SetHidden(false)
        block.magickaBackdrop:SetHidden(false)
        block.staminaBackdrop:SetHidden(false)
        block.magickaBar:SetValue(magickaPercent)
        block.staminaBar:SetValue(staminaPercent)
        
        -- Set full height with resources visible
        local fullHeight = GUD.PLAYER_BLOCK_HEIGHT
        block.container:SetHeight(fullHeight)
    else
        -- Hide resource bars
        block.magickaBar:SetHidden(true)
        block.staminaBar:SetHidden(true)
        block.magickaBackdrop:SetHidden(true)
        block.staminaBackdrop:SetHidden(true)
        
        -- Set compact height (just ultimate bar)
        block.container:SetHeight(GUD.ULTIMATE_BAR_HEIGHT)
    end
    
    -- Update combat border
    if GUD.settings.showCombatState and block.combatBorder then
        if inCombat then
            block.combatBorder:SetEdgeColor(unpack(GUD.COLORS.IN_COMBAT))
        else
            block.combatBorder:SetEdgeColor(0, 0, 0, 0)  -- Transparent border
        end
    end
    
    -- Color code ultimate bar based on readiness
    GUD.UpdateBlockColor(block, percent)
end

--[[
    Toggle UI visibility
]]--
function GUD.Toggle()
    GUD.settings.enabled = not GUD.settings.enabled
    GUD.ApplySettings()
    GUD.SaveSettings()
    
    if GUD.settings.enabled then
    else
    end
end

--[[
    Toggle lock/unlock
]]--
function GUD.ToggleLock()
    GUD.settings.locked = not GUD.settings.locked
    GUD.ApplySettings()
    GUD.SaveSettings()
    
    if GUD.settings.locked then
    else
    end
end

-- ============================================================================
-- Settings Panel Controls (called from BeltalowdaSettings.lua)
-- ============================================================================

function GUD.GetSettingsControls()
    return {
        {
            type = "submenu",
            name = "|c4592FFClassic Ultimate Tracker|r",
            tooltip = "Configure the classic columnar ultimate tracker and client ultimate selector",
            controls = {
                {
                    type = "description",
                    text = "Configure the classic columnar ultimate tracker. Click any ultimate icon to choose which ultimate to track. The role-based tracker is the recommended tracker.",
                    width = "full",
                },
                -- Classic Ultimate Tracker Visibility
                {
                    type = "checkbox",
                    name = "Enable Classic Tracker",
                    tooltip = "Enable the classic columnar ultimate tracker",
                    getFunc = function() return GUD.settings.enabled end,
                    setFunc = function(value)
                        GUD.settings.enabled = value
                        GUD.ApplySettings()
                        GUD.SaveSettings()
                    end,
                    width = "full",
                    default = false,
                },
                -- Ultimate Count slider
                {
                    type = "slider",
                    name = "Ultimate Count",
                    tooltip = "Number of user-configurable ultimate columns (1-11). A Volendrung column appears automatically when detected in group.",
                    min = 1,
                    max = 11,
                    step = 1,
                    getFunc = function() return GUD.settings.ultimateCount end,
                    setFunc = function(value) GUD.SetUltimateCount(value) end,
                    width = "full",
                    default = GUD.DEFAULT_ULTIMATE_COUNT,
                },
                -- Lock UI toggle (classic tracker + client ultimate selector only)
                {
                    type = "checkbox",
                    name = "Lock UI",
                    tooltip = "Lock the classic ultimate tracker and client ultimate selector in place (prevents accidental movement)",
                    getFunc = function() return GUD.settings.locked end,
                    setFunc = function(value)
                        GUD.settings.locked = value
                        GUD.ApplySettings()
                        GUD.SaveSettings()
                        if Beltalowda.UI.ClientUltimateSelector then
                            Beltalowda.UI.ClientUltimateSelector.settings.locked = value
                            Beltalowda.UI.ClientUltimateSelector.ApplySettings()
                            Beltalowda.UI.ClientUltimateSelector.SaveSettings()
                        end
                    end,
                    width = "full",
                    default = false,
                },
                -- Scale slider
                {
                    type = "slider",
                    name = "UI Scale",
                    tooltip = "Scale of the group ultimate display",
                    min = 0.5,
                    max = 2.0,
                    step = 0.1,
                    getFunc = function() return GUD.settings.scale end,
                    setFunc = function(value)
                        GUD.settings.scale = value
                        GUD.ApplySettings()
                        GUD.SaveSettings()
                    end,
                    width = "full",
                    default = 1.0,
                },
                -- Opacity slider
                {
                    type = "slider",
                    name = "UI Opacity",
                    tooltip = "Transparency of the group ultimate display (0 = invisible, 1 = opaque)",
                    min = 0.1,
                    max = 1.0,
                    step = 0.1,
                    getFunc = function() return GUD.settings.opacity end,
                    setFunc = function(value)
                        GUD.settings.opacity = value
                        GUD.ApplySettings()
                        GUD.SaveSettings()
                    end,
                    width = "full",
                    default = 1.0,
                },
            },
        },
    }
end

-- Debug commands
SLASH_COMMANDS["/btlwui"] = function(args)
    if args == "toggle" then
        GUD.Toggle()
    elseif args == "lock" then
        GUD.ToggleLock()
    elseif args == "refresh" then
        GUD.RefreshDisplay()
    elseif args == "test" then
        GUD.settings.testMode = not GUD.settings.testMode
    else
        d("=== Beltalowda UI Commands ===")
        d("/btlwui toggle - Toggle UI visibility")
        d("/btlwui lock - Toggle UI lock/unlock")
        d("/btlwui refresh - Refresh display")
        d("/btlwui test - Toggle test mode")
    end
end

return GUD
