-- Beltalowda Group Composition Panel
-- Unified panel displaying per-player sets, group/self buffs, and synergies
-- organized in role-based columns (Pull → Damage → Support).
-- Activated via the Composition Warnings button context menu.
-- Dismissible by Escape key or clicking outside the panel.

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.GroupCompositionPanel = {}

local GCP = Beltalowda.UI.GroupCompositionPanel
local wm = WINDOW_MANAGER

-- ============================================================================
-- Constants
-- ============================================================================

GCP.COLUMN_WIDTH = 230
GCP.COLUMN_GAP = 12
GCP.PADDING = 14
GCP.CONTENT_INSET = 8           -- Extra inset from the decorative borders
GCP.PANEL_WIDTH = (GCP.PADDING + GCP.CONTENT_INSET) * 2 + GCP.COLUMN_WIDTH * 3 + GCP.COLUMN_GAP * 2

GCP.ICON_SIZE = 14
GCP.ICON_GAP = 3
GCP.SECTION_LABEL_HEIGHT = 18
GCP.SET_ROW_HEIGHT = 18
GCP.PLAYER_NAME_HEIGHT = 22
GCP.PLAYER_GAP = 10
GCP.SECTION_GAP = 2
GCP.SET_INDENT = 12
GCP.ICON_ROW_HEIGHT = 18

GCP.ROWS_PER_COLUMN = 4
GCP.ROLE_SORT_ORDER = { pull = 1, damage = 2, support = 3 }
GCP.ROLE_LABELS = { pull = "Pull", damage = "Damage", support = "Support" }

GCP.FONT_HEADER = "ZoFontGameBold"
GCP.FONT_NORMAL = "ZoFontGame"
GCP.FONT_SMALL  = "ZoFontGameSmall"
GCP.FONT_TITLE  = "ZoFontWinH1"

GCP.HEADER_HEIGHT = 42          -- Space reserved for the title row
GCP.CLOSE_BUTTON_HEIGHT = 28    -- Close button height
GCP.FOOTER_HEIGHT = 40          -- Space reserved below content for the button

-- ============================================================================
-- State
-- ============================================================================

GCP.state = {
    visible = false,
    menuHidden = false,
    pvpHidden = false,
}
GCP.controls = {}
GCP.dynamicControls = {}
GCP.initialized = false

-- ============================================================================
-- Settings
-- ============================================================================

GCP.settings = {
    positionX = 400,
    positionY = 300,
}

-- ============================================================================
-- Buff Icon Resolution
-- ============================================================================

-- Representative ability IDs for buff icon display (resolved at runtime)
local BUFF_ICON_ABILITY_IDS = {
    [2] = 86126,   -- Major Resolve → Expansive Frost Cloak
    [4] = 29556,   -- Major Evasion (self) → Evasion
}

-- Static fallback icon paths for buffs without ability-based sources
local BUFF_FALLBACK_ICONS = {
    [1] = "/esoui/art/icons/ability_dragonknight_031.dds",      -- Major Courage
    [3] = "/esoui/art/icons/ability_dragonknight_031.dds",      -- Major Evasion (group)
    [5] = "/esoui/art/icons/gear_breton_medium_feet_d.dds",     -- Snare Immunity
    [6] = "/esoui/art/icons/ability_warden_013.dds",            -- Minor Toughness
}

-- Cache for resolved ability icons
local buffIconCache = {}

local function GetBuffIcon(buffId, sourceAbilityId)
    -- Source-specific icon (local player's actual slotted ability)
    if sourceAbilityId and sourceAbilityId > 0 then
        local icon = GetAbilityIcon(sourceAbilityId)
        if icon and icon ~= "" then return icon end
    end

    -- Default ability ID for this buff type
    local defAbilityId = BUFF_ICON_ABILITY_IDS[buffId]
    if defAbilityId then
        if not buffIconCache[buffId] then
            local icon = GetAbilityIcon(defAbilityId)
            buffIconCache[buffId] = (icon and icon ~= "") and icon or false
        end
        if buffIconCache[buffId] then
            return buffIconCache[buffId]
        end
    end

    -- Static fallback
    return BUFF_FALLBACK_ICONS[buffId] or "/esoui/art/icons/ability_dragonknight_031.dds"
end

-- ============================================================================
-- Initialize
-- ============================================================================

function GCP.Initialize()
    if GCP.initialized then return end

    GCP.LoadSettings()
    GCP.CreatePanel()

    GCP.initialized = true
end

-- ============================================================================
-- Settings persistence
-- ============================================================================

function GCP.LoadSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.groupCompositionPanel = BeltalowdaVars.ui.groupCompositionPanel or {}

    local saved = BeltalowdaVars.ui.groupCompositionPanel
    GCP.settings.positionX = saved.positionX or 400
    GCP.settings.positionY = saved.positionY or 300
end

function GCP.SaveSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.groupCompositionPanel = {
        positionX = GCP.settings.positionX,
        positionY = GCP.settings.positionY,
    }
end

-- ============================================================================
-- Create Panel UI
-- ============================================================================

function GCP.CreatePanel()
    if GCP.controls.window then return end

    -- Main panel window
    local win = wm:CreateTopLevelWindow("BeltalowdaGroupCompositionPanel")
    win:SetDimensions(GCP.PANEL_WIDTH, 100)  -- height set dynamically
    win:SetClampedToScreen(true)
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetHidden(true)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawLevel(10)
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GCP.settings.positionX, GCP.settings.positionY)

    win:SetHandler("OnMoveStop", function(control)
        GCP.settings.positionX = control:GetLeft()
        GCP.settings.positionY = control:GetTop()
        GCP.SaveSettings()
    end)

    -- ── Main backdrop (ZO_InsetBackdrop — native ESO panel with rounded corners)
    local bd = CreateControlFromVirtual("BeltalowdaGCPBackdrop", win, "ZO_InsetBackdrop")
    bd:SetAnchorFill(win)
    bd:SetCenterColor(0.06, 0.05, 0.05, 0.92)
    bd:SetEdgeColor(0, 0, 0, 0)
    bd:SetMouseEnabled(false)

    -- ── Header divider (fading horizontal line below title) ──────────────
    local headerDivider = wm:CreateControl(nil, win, CT_TEXTURE)
    headerDivider:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
    headerDivider:SetAnchor(TOPLEFT, win, TOPLEFT, 4, GCP.HEADER_HEIGHT - 2)
    headerDivider:SetAnchor(TOPRIGHT, win, TOPRIGHT, -4, GCP.HEADER_HEIGHT - 2)
    headerDivider:SetHeight(4)
    headerDivider:SetColor(0.85, 0.75, 0.5, 0.8)
    headerDivider:SetDrawLevel(2)

    -- ── Title label ──────────────────────────────────────────────────────
    local title = wm:CreateControl(nil, win, CT_LABEL)
    title:SetFont(GCP.FONT_TITLE)
    title:SetText("Group Composition")
    title:SetColor(0.85, 0.75, 0.5, 1)  -- Warm gold matching settings headers
    title:SetAnchor(TOPLEFT, win, TOPLEFT, GCP.PADDING, 6)
    title:SetDimensions(GCP.PANEL_WIDTH - GCP.PADDING * 2, GCP.HEADER_HEIGHT - 10)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    -- ── Close button (ZO_DefaultButton style, matching Dolgubons) ───────
    local closeBtn = CreateControlFromVirtual("BeltalowdaGCPCloseBtn", win, "ZO_DefaultButton")
    closeBtn:SetDimensions(130, GCP.CLOSE_BUTTON_HEIGHT)
    closeBtn:SetAnchor(BOTTOM, win, BOTTOM, 0, -15)
    closeBtn:SetText("Close")
    closeBtn:SetClickSound(SOUNDS.BOOK_ACQUIRED)
    closeBtn:SetHandler("OnClicked", function() GCP.Hide() end)

    GCP.controls.window = win
    GCP.controls.backdrop = bd
    GCP.controls.headerDivider = headerDivider
    GCP.controls.title = title
    GCP.controls.closeBtn = closeBtn

    -- Keybind strip descriptor for Escape to close
    GCP.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_RIGHT,
        {
            name = "Close",
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function() GCP.Hide() end,
        },
    }
end

-- ============================================================================
-- Toggle / Show / Hide
-- ============================================================================

function GCP.Toggle(anchorControl)
    if GCP.state.visible then
        GCP.Hide()
    else
        GCP.Show(anchorControl)
    end
end

function GCP.Show(anchorControl)
    if not GCP.controls.window then return end
    GCP.state.visible = true

    GCP.Refresh()
    GCP.controls.window:SetHidden(false)

    if KEYBIND_STRIP then
        KEYBIND_STRIP:AddKeybindButtonGroup(GCP.keybindStripDescriptor)
    end

    -- Subscribe to live data change callbacks so the panel auto-refreshes
    GCP.RegisterLiveCallbacks()
end

function GCP.Hide()
    if GCP.controls.window then
        GCP.controls.window:SetHidden(true)
    end
    GCP.state.visible = false

    if KEYBIND_STRIP then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(GCP.keybindStripDescriptor)
    end

    -- Unsubscribe from live data change callbacks
    GCP.UnregisterLiveCallbacks()
end

function GCP.SetMenuHidden(hidden)
    GCP.state.menuHidden = hidden
    if not GCP.controls.window then return end
    if hidden then
        GCP.controls.window:SetHidden(true)
    elseif GCP.state.visible and not GCP.state.pvpHidden then
        GCP.controls.window:SetHidden(false)
    end
end

function GCP.SetPvPHidden(hidden)
    GCP.state.pvpHidden = hidden
    if not GCP.controls.window then return end
    if hidden then
        GCP.controls.window:SetHidden(true)
    elseif GCP.state.visible and not GCP.state.menuHidden then
        GCP.controls.window:SetHidden(false)
    end
end

-- ============================================================================
-- Live Refresh Callbacks
-- ============================================================================

--[[
    Debounced refresh — collapses rapid change events into a single panel redraw.
]]
function GCP.ScheduleRefresh()
    EVENT_MANAGER:UnregisterForUpdate("BeltalowdaGCPLiveRefresh")
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaGCPLiveRefresh", 300, function()
        EVENT_MANAGER:UnregisterForUpdate("BeltalowdaGCPLiveRefresh")
        if GCP.state.visible then
            GCP.Refresh()
        end
    end)
end

--[[
    Register for all relevant data-change callbacks so the panel refreshes live.
    Called when the panel is shown.
]]
function GCP.RegisterLiveCallbacks()
    if GCP.liveCallbacksRegistered then return end

    -- Buff composition changes
    local BC = Beltalowda.Data and Beltalowda.Data.BuffComposition
    if BC and CALLBACK_MANAGER then
        CALLBACK_MANAGER:RegisterCallback(BC.CALLBACK_NAME, GCP.ScheduleRefresh)
    end

    -- Synergy composition changes
    local SC = Beltalowda.Data and Beltalowda.Data.SynergyComposition
    if SC and CALLBACK_MANAGER then
        CALLBACK_MANAGER:RegisterCallback(SC.CALLBACK_NAME, GCP.ScheduleRefresh)
    end

    -- Mundus composition changes
    local MC = Beltalowda.Data and Beltalowda.Data.MundusComposition
    if MC and CALLBACK_MANAGER then
        CALLBACK_MANAGER:RegisterCallback(MC.CALLBACK_NAME, GCP.ScheduleRefresh)
    end

    -- Consumable tracker changes
    local ConsT = Beltalowda.Data and Beltalowda.Data.ConsumableTracker
    if ConsT and CALLBACK_MANAGER then
        CALLBACK_MANAGER:RegisterCallback(ConsT.CALLBACK_NAME, GCP.ScheduleRefresh)
    end

    -- Equipment data changes (hook OnDataChanged)
    if Beltalowda.network then
        GCP.originalOnDataChanged = Beltalowda.network.OnDataChanged
        Beltalowda.network.OnDataChanged = function(dataType, unitTag)
            if GCP.originalOnDataChanged and type(GCP.originalOnDataChanged) == "function" then
                GCP.originalOnDataChanged(dataType, unitTag)
            end
            if dataType == "equipment" and GCP.state.visible then
                GCP.ScheduleRefresh()
            end
        end
    end

    GCP.liveCallbacksRegistered = true
end

--[[
    Unregister live data-change callbacks.
    Called when the panel is hidden.
]]
function GCP.UnregisterLiveCallbacks()
    if not GCP.liveCallbacksRegistered then return end

    EVENT_MANAGER:UnregisterForUpdate("BeltalowdaGCPLiveRefresh")

    local BC = Beltalowda.Data and Beltalowda.Data.BuffComposition
    if BC and CALLBACK_MANAGER then
        CALLBACK_MANAGER:UnregisterCallback(BC.CALLBACK_NAME, GCP.ScheduleRefresh)
    end

    local SC = Beltalowda.Data and Beltalowda.Data.SynergyComposition
    if SC and CALLBACK_MANAGER then
        CALLBACK_MANAGER:UnregisterCallback(SC.CALLBACK_NAME, GCP.ScheduleRefresh)
    end

    local MC = Beltalowda.Data and Beltalowda.Data.MundusComposition
    if MC and CALLBACK_MANAGER then
        CALLBACK_MANAGER:UnregisterCallback(MC.CALLBACK_NAME, GCP.ScheduleRefresh)
    end

    local ConsT = Beltalowda.Data and Beltalowda.Data.ConsumableTracker
    if ConsT and CALLBACK_MANAGER then
        CALLBACK_MANAGER:UnregisterCallback(ConsT.CALLBACK_NAME, GCP.ScheduleRefresh)
    end

    -- Restore original OnDataChanged
    if GCP.originalOnDataChanged and Beltalowda.network then
        Beltalowda.network.OnDataChanged = GCP.originalOnDataChanged
        GCP.originalOnDataChanged = nil
    end

    GCP.liveCallbacksRegistered = false
end

-- ============================================================================
-- Refresh Panel Content
-- ============================================================================

function GCP.Refresh()
    if not GCP.controls.window then return end

    GCP.DestroyDynamicControls()

    local parent = GCP.controls.window

    -- Content starts below the fixed header
    local contentTop = GCP.HEADER_HEIGHT + 4
    local inset = GCP.PADDING + GCP.CONTENT_INSET

    if GetGroupSize() == 0 then
        local soloWidth = GCP.COLUMN_WIDTH + inset * 2

        local noticeLabel = wm:CreateControl(nil, parent, CT_LABEL)
        noticeLabel:SetFont(GCP.FONT_NORMAL)
        noticeLabel:SetText("Not in a group")
        noticeLabel:SetColor(0.6, 0.6, 0.6, 1)
        noticeLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, inset, contentTop + 10)
        noticeLabel:SetDimensions(GCP.COLUMN_WIDTH, GCP.PLAYER_NAME_HEIGHT)
        noticeLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        table.insert(GCP.dynamicControls, noticeLabel)

        local totalHeight = contentTop + GCP.PLAYER_NAME_HEIGHT + GCP.FOOTER_HEIGHT + 20
        parent:SetDimensions(soloWidth, totalHeight)

        if GCP.controls.title then
            GCP.controls.title:SetDimensions(soloWidth - GCP.PADDING * 2, GCP.HEADER_HEIGHT - 10)
        end
        return
    end

    local sorted = GCP.GatherGroupDataSorted()
    local totalPlayers = #sorted
    local numCols = math.min(3, math.ceil(totalPlayers / GCP.ROWS_PER_COLUMN))
    if numCols < 1 then numCols = 1 end
    local panelWidth = inset * 2 + GCP.COLUMN_WIDTH * numCols + GCP.COLUMN_GAP * (numCols - 1)

    -- Distribute players into columns (column-major: fill column 1 first)
    local columns = {}
    for c = 1, numCols do columns[c] = {} end
    for idx, p in ipairs(sorted) do
        local col = math.ceil(idx / GCP.ROWS_PER_COLUMN)
        if col > numCols then col = numCols end
        table.insert(columns[col], p)
    end

    local maxColumnHeight = contentTop

    for colIndex = 1, numCols do
        local players = columns[colIndex]
        local xOffset = inset + (colIndex - 1) * (GCP.COLUMN_WIDTH + GCP.COLUMN_GAP)
        local y = contentTop

        for _, p in ipairs(players) do
            -- Player name with role colour
            local rr, rg, rb = GCP.GetRoleColor(p.role)
            local roleTag = GCP.ROLE_LABELS[p.role] or p.role
            y = GCP.CreateTextRow(parent, xOffset, y, GCP.COLUMN_WIDTH,
                p.name, rr, rg, rb, GCP.PLAYER_NAME_HEIGHT, GCP.FONT_HEADER)

            -- Sets (indented, smaller font, colored by quality)
            if p.sets and #p.sets > 0 then
                for _, s in ipairs(p.sets) do
                    local setLine = string.format("%s %d/%d", s.name, s.pieces, s.maxPieces)
                    if s.barInfo and s.barInfo ~= "" then
                        setLine = setLine .. s.barInfo
                    end
                    local sr, sg, sb = GCP.GetQualityColor(s.quality)
                    y = GCP.CreateTextRow(parent, xOffset + GCP.SET_INDENT, y,
                        GCP.COLUMN_WIDTH - GCP.SET_INDENT, setLine,
                        sr, sg, sb, GCP.SET_ROW_HEIGHT, GCP.FONT_SMALL)
                end
            end

            -- Champion points (three discipline icons with tooltip)
            if p.championPoints and #p.championPoints > 0 then
                y = y + GCP.SECTION_GAP
                y = GCP.CreateIconRow(parent, xOffset + GCP.SET_INDENT, y,
                    GCP.COLUMN_WIDTH - GCP.SET_INDENT, "CP:", p.championPoints)
            end

            -- Mundus stones ("Boon:" label + icon with tooltip)
            if p.mundus and #p.mundus > 0 then
                y = y + GCP.SECTION_GAP
                y = GCP.CreateIconRow(parent, xOffset + GCP.SET_INDENT, y,
                    GCP.COLUMN_WIDTH - GCP.SET_INDENT, "Boon:", p.mundus)
            elseif p.mundus then
                -- Player has been scanned but has no mundus — show warning text
                y = y + GCP.SECTION_GAP
                y = GCP.CreateTextRow(parent, xOffset + GCP.SET_INDENT, y,
                    GCP.COLUMN_WIDTH - GCP.SET_INDENT, "Boon: (none)",
                    1, 0.4, 0.4, GCP.SET_ROW_HEIGHT, GCP.FONT_SMALL)
            end

            -- Consumable status (indented icon row + missing food warning)
            if p.missingFood then
                y = y + GCP.SECTION_GAP
                if p.consumables and #p.consumables > 0 then
                    -- Has some consumables (AP/XP) but missing food
                    y = GCP.CreateIconRow(parent, xOffset + GCP.SET_INDENT, y,
                        GCP.COLUMN_WIDTH - GCP.SET_INDENT, "Consumable:", p.consumables)
                end
                y = y + GCP.SECTION_GAP
                y = GCP.CreateTextRow(parent, xOffset + GCP.SET_INDENT, y,
                    GCP.COLUMN_WIDTH - GCP.SET_INDENT, "Consumable: Missing food or drink buff",
                    1, 0.3, 0.3, GCP.SET_ROW_HEIGHT, GCP.FONT_SMALL)
            elseif p.consumables and #p.consumables > 0 then
                y = y + GCP.SECTION_GAP
                y = GCP.CreateIconRow(parent, xOffset + GCP.SET_INDENT, y,
                    GCP.COLUMN_WIDTH - GCP.SET_INDENT, "Consumable:", p.consumables)
            end

            -- Synergies (indented icon row)
            if p.synergies and #p.synergies > 0 then
                y = y + GCP.SECTION_GAP
                y = GCP.CreateIconRow(parent, xOffset + GCP.SET_INDENT, y,
                    GCP.COLUMN_WIDTH - GCP.SET_INDENT, "Synergy:", p.synergies)
            end

            -- Group buffs (indented icon row)
            if p.groupBuffs and #p.groupBuffs > 0 then
                y = y + GCP.SECTION_GAP
                y = GCP.CreateIconRow(parent, xOffset + GCP.SET_INDENT, y,
                    GCP.COLUMN_WIDTH - GCP.SET_INDENT, "Group:", p.groupBuffs)
            end

            -- Self buffs (indented icon row)
            if p.selfBuffs and #p.selfBuffs > 0 then
                y = y + GCP.SECTION_GAP
                y = GCP.CreateIconRow(parent, xOffset + GCP.SET_INDENT, y,
                    GCP.COLUMN_WIDTH - GCP.SET_INDENT, "Self:", p.selfBuffs)
            end

            y = y + GCP.PLAYER_GAP
        end

        if y > maxColumnHeight then maxColumnHeight = y end
    end

    local totalHeight = maxColumnHeight + GCP.FOOTER_HEIGHT
    parent:SetDimensions(panelWidth, totalHeight)

    -- Update title width to match dynamic panel width
    if GCP.controls.title then
        GCP.controls.title:SetDimensions(panelWidth - GCP.PADDING * 2, GCP.HEADER_HEIGHT - 10)
    end
end

-- ============================================================================
-- Gather group data for display
-- ============================================================================

--[[
    Format a consumable time value into a readable string for the composition panel.
    @param seconds: Time remaining in seconds
    @return string (e.g. "1h 45m", "14m", "30s")
]]--
function GCP.FormatConsumableTime(seconds)
    if not seconds or seconds <= 0 then return "expired" end
    seconds = math.floor(seconds)
    if seconds >= 3600 then
        local h = math.floor(seconds / 3600)
        local m = math.floor((seconds % 3600) / 60)
        return string.format("%dh %dm", h, m)
    elseif seconds >= 60 then
        local m = math.floor(seconds / 60)
        return string.format("%dm", m)
    end
    return string.format("%ds", seconds)
end

--[[
    Gather all group members with sets/buffs/synergies, sorted by role
    (pull → damage → support) then alphabetically within each role.
    Returns a flat array for distribution into columns.
]]--
function GCP.GatherGroupDataSorted()
    local groupSize = GetGroupSize()
    if groupSize == 0 then return {} end

    local BC = Beltalowda.Data and Beltalowda.Data.BuffComposition
    local SC = Beltalowda.Data and Beltalowda.Data.SynergyComposition
    local ST = Beltalowda.Data and Beltalowda.Data.SynergyTracker
    local BuffDB = Beltalowda.Data and Beltalowda.Data.BuffDatabase
    local MC = Beltalowda.Data and Beltalowda.Data.MundusComposition
    local MundusData = Beltalowda.Data and Beltalowda.Data.MundusData
    local ConsT = Beltalowda.Data and Beltalowda.Data.ConsumableTracker
    local CPC = Beltalowda.Data and Beltalowda.Data.ChampionPointComposition
    local playerName = GetUnitName("player")

    local players = {}

    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        local name = GetUnitName(unitTag)
        local displayName = Beltalowda.GetDisplayName(unitTag)
        local equipData = Beltalowda.network and Beltalowda.network.GetEquipmentData(unitTag)

        local role = "damage"
        local sets = {}

        if equipData and equipData.usefulBits then
            local data = equipData.usefulBits
            role = data.role or "damage"
            if data.sets then
                for _, s in ipairs(data.sets) do
                    table.insert(sets, {
                        name = s.name or ("Set #" .. tostring(s.id)),
                        pieces = s.pieces or 0,
                        maxPieces = s.maxPieces or 5,
                        barInfo = s.barInfo or "",
                        quality = s.quality,
                    })
                end
            end
        end

        if role ~= "support" and role ~= "pull" then
            role = "damage"
        end

        -- Gather buffs from BuffComposition bitmask
        local groupBuffs = {}
        local selfBuffs = {}
        local isLocal = (name == playerName)

        if BC and BuffDB then
            local bitmask = BC.compositionData and BC.compositionData[name]
            if bitmask then
                for buffId = 1, BC.MAX_BUFF_BITS do
                    if BC.TestBit(bitmask, buffId) then
                        local buffName = BuffDB.idToBuff[buffId]
                        if buffName then
                            local def = BuffDB.BUFF_DEFINITIONS[buffName]
                            local sourceAbilityId = isLocal and BC.GetLocalSourceAbilityId(buffId) or nil
                            local iconPath = GetBuffIcon(buffId, sourceAbilityId)

                            local isIndividual = BuffDB.individualBitIds and BuffDB.individualBitIds[buffId]
                            local isPerPlayer = def and def.perPlayer

                            local entry = {
                                iconPath = iconPath,
                                tooltip = buffName,
                            }

                            if isIndividual or isPerPlayer then
                                table.insert(selfBuffs, entry)
                            else
                                table.insert(groupBuffs, entry)
                            end
                        end
                    end
                end
            end
        end

        -- Gather synergies from SynergyComposition bitmask
        local synergies = {}
        if SC and ST then
            local synergyIds = SC.GetPlayerSynergies(unitTag)
            if synergyIds then
                for _, synergyId in ipairs(synergyIds) do
                    local synergy = ST.SYNERGIES[synergyId]
                    if synergy then
                        table.insert(synergies, {
                            iconPath = synergy.iconPath,
                            tooltip = synergy.name,
                        })
                    end
                end
            end
        end

        -- Gather mundus stones from MundusComposition
        local mundusIcons = {}
        if MC and MundusData then
            local mundusAbilities = MC.GetPlayerMundus(name)
            if mundusAbilities then
                for _, abilityId in ipairs(mundusAbilities) do
                    table.insert(mundusIcons, {
                        iconPath = MundusData.GetMundusIcon(abilityId),
                        tooltip = MundusData.GetMundusName(abilityId),
                    })
                end
            end
        end

        -- Gather consumable status from ConsumableTracker
        local consumables = {}
        local missingFood = false
        if ConsT and ConsT.GetPlayerConsumableData then
            local cData = ConsT.GetPlayerConsumableData(name)
            if cData then
                -- Food/Drink
                if cData.foodRemain and cData.foodRemain > 0 then
                    -- Fallback: use GetAbilityIcon with a known food ability ID for a generic food icon
                    local foodIcon = GetAbilityIcon(61259) or "/esoui/art/icons/ability_provisioner_004.dds"
                    local foodName = "Food/Drink"
                    -- Use actual icon for local player via LibFoodDrinkBuff
                    if isLocal and ConsT.GetLocalFoodBuffDetails then
                        local actualIcon, buffName = ConsT.GetLocalFoodBuffDetails()
                        if actualIcon and actualIcon ~= "" then foodIcon = actualIcon end
                        if buffName and buffName ~= "" then foodName = buffName end
                    end
                    table.insert(consumables, {
                        iconPath = foodIcon,
                        tooltip = string.format("%s: %s remaining", foodName, GCP.FormatConsumableTime(cData.foodRemain)),
                    })
                end
                -- AP Buff
                if cData.apRemain and cData.apRemain > 0 then
                    local apIcon = GetAbilityIcon(147687) or "/esoui/art/icons/ability_provisioner_004.dds"
                    if isLocal and ConsT.localState.apAbilityId then
                        local actualIcon = GetAbilityIcon(ConsT.localState.apAbilityId)
                        if actualIcon and actualIcon ~= "" then apIcon = actualIcon end
                    end
                    local apName = isLocal and ConsT.localState.apAbilityId and GetAbilityName(ConsT.localState.apAbilityId) or "AP Buff"
                    if not apName or apName == "" then apName = "AP Buff" end
                    table.insert(consumables, {
                        iconPath = apIcon,
                        tooltip = string.format("%s: %s remaining", apName, GCP.FormatConsumableTime(cData.apRemain)),
                    })
                end
                -- XP Buff
                if cData.xpRemain and cData.xpRemain > 0 then
                    local xpIcon = GetAbilityIcon(64210) or "/esoui/art/icons/ability_provisioner_004.dds"
                    if isLocal and ConsT.localState.xpAbilityId then
                        local actualIcon = GetAbilityIcon(ConsT.localState.xpAbilityId)
                        if actualIcon and actualIcon ~= "" then xpIcon = actualIcon end
                    end
                    local xpName = isLocal and ConsT.localState.xpAbilityId and GetAbilityName(ConsT.localState.xpAbilityId) or "XP Buff"
                    if not xpName or xpName == "" then xpName = "XP Buff" end
                    table.insert(consumables, {
                        iconPath = xpIcon,
                        tooltip = string.format("%s: %s remaining", xpName, GCP.FormatConsumableTime(cData.xpRemain)),
                    })
                end

                -- Flag missing food/drink buff (AP/XP are optional)
                if not cData.foodRemain or cData.foodRemain <= 0 then
                    missingFood = true
                end
            end
        end

        -- Gather champion point data from ChampionPointComposition
        local cpIcons = {}
        local trackCP = not BeltalowdaVars or not BeltalowdaVars.composition
            or BeltalowdaVars.composition.trackChampionPoints ~= false
        if trackCP and CPC then
            local cpData = CPC.GetPlayerChampionData(name)
            if cpData then
                local orderedIds = CPC.GetOrderedDisciplineIds()
                for _, discId in ipairs(orderedIds) do
                    local perks = cpData[discId] or {}
                    local filled = CPC.CountFilledSlots(perks)
                    local iconPath = CPC.GetDisciplineIcon(discId, filled)
                    local tooltip = CPC.BuildDisciplineTooltip(discId, perks)
                    if iconPath then
                        table.insert(cpIcons, {
                            iconPath = iconPath,
                            tooltip = tooltip,
                        })
                    end
                end
            end
        end

        table.insert(players, {
            name = displayName,
            role = role,
            sets = sets,
            groupBuffs = groupBuffs,
            selfBuffs = selfBuffs,
            synergies = synergies,
            mundus = mundusIcons,
            consumables = consumables,
            missingFood = missingFood,
            championPoints = cpIcons,
        })
    end

    -- Sort: by role priority (pull → damage → support), then alphabetically
    table.sort(players, function(a, b)
        local ra = GCP.ROLE_SORT_ORDER[a.role] or 2
        local rb = GCP.ROLE_SORT_ORDER[b.role] or 2
        if ra ~= rb then return ra < rb end
        return a.name < b.name
    end)

    return players
end



-- ============================================================================
-- UI Helper: Create icon row with label and tooltip-on-hover icons
-- ============================================================================

function GCP.CreateIconRow(parent, x, y, width, label, icons)
    -- Section label (e.g. "Group:", "Self:", "Synergies:")
    local lbl = wm:CreateControl(nil, parent, CT_LABEL)
    lbl:SetFont(GCP.FONT_SMALL)
    lbl:SetText(label)
    lbl:SetColor(0.6, 0.7, 0.8, 1)
    lbl:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    lbl:SetDimensions(width, GCP.SECTION_LABEL_HEIGHT)
    lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    table.insert(GCP.dynamicControls, lbl)

    -- Icons arranged horizontally after the label text
    local labelWidth = lbl:GetTextWidth() + 4
    local iconX = x + labelWidth
    local iconSz = GCP.ICON_SIZE

    for _, iconData in ipairs(icons) do
        -- Wrap each icon in a CT_CONTROL container for reliable mouse events
        -- (CT_TEXTURE on a movable parent doesn't receive OnMouseEnter reliably)
        local container = wm:CreateControl(nil, parent, CT_CONTROL)
        container:SetDimensions(iconSz, iconSz)
        local iconY = y + math.floor((GCP.SECTION_LABEL_HEIGHT - iconSz) / 2)
        container:SetAnchor(TOPLEFT, parent, TOPLEFT, iconX, iconY)
        container:SetMouseEnabled(true)
        container:SetDrawTier(DT_HIGH)

        local tex = wm:CreateControl(nil, container, CT_TEXTURE)
        tex:SetAnchorFill(container)
        tex:SetTexture(iconData.iconPath)

        if iconData.tooltip then
            container:SetHandler("OnMouseEnter", function(control)
                InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOP)
                SetTooltipText(InformationTooltip, iconData.tooltip)
            end)
            container:SetHandler("OnMouseExit", function()
                ClearTooltip(InformationTooltip)
            end)
        end

        table.insert(GCP.dynamicControls, container)
        iconX = iconX + iconSz + GCP.ICON_GAP
    end

    return y + GCP.ICON_ROW_HEIGHT
end

-- ============================================================================
-- UI Helper: Mundus row with icon + localized name per stone
-- ============================================================================

--[[
    Renders one row per mundus stone showing:  icon  Name
    If a player has multiple mundus (Twice-Born Star), each gets its own row.
]]--
function GCP.CreateMundusRow(parent, x, y, width, mundusEntries)
    for _, entry in ipairs(mundusEntries) do
        local iconSz = GCP.ICON_SIZE
        local rowH = GCP.SET_ROW_HEIGHT

        -- Icon texture
        local tex = wm:CreateControl(nil, parent, CT_TEXTURE)
        tex:SetDimensions(iconSz, iconSz)
        tex:SetTexture(entry.iconPath)
        local iconY = y + math.floor((rowH - iconSz) / 2)
        tex:SetAnchor(TOPLEFT, parent, TOPLEFT, x, iconY)
        table.insert(GCP.dynamicControls, tex)

        -- Localized name label next to the icon
        local lbl = wm:CreateControl(nil, parent, CT_LABEL)
        lbl:SetFont(GCP.FONT_SMALL)
        lbl:SetText(entry.tooltip or "Unknown Mundus")
        lbl:SetColor(0.9, 0.85, 0.6, 1)   -- warm gold tint for mundus text
        lbl:SetAnchor(TOPLEFT, parent, TOPLEFT, x + iconSz + 4, y)
        lbl:SetDimensions(width - iconSz - 4, rowH)
        lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        table.insert(GCP.dynamicControls, lbl)

        y = y + rowH
    end

    return y
end

-- ============================================================================
-- Dynamic control helpers
-- ============================================================================

function GCP.DestroyDynamicControls()
    for _, ctrl in ipairs(GCP.dynamicControls) do
        ctrl:SetHidden(true)
        ctrl:ClearAnchors()
        ctrl:SetParent(nil)
    end
    GCP.dynamicControls = {}
end

function GCP.CreateSectionHeader(parent, x, y, width, text, r, g, b)
    r = r or 1; g = g or 1; b = b or 1

    local lbl = wm:CreateControl(nil, parent, CT_LABEL)
    lbl:SetFont(GCP.FONT_HEADER)
    lbl:SetText(text)
    lbl:SetColor(r, g, b, 1)
    lbl:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    lbl:SetDimensions(width, GCP.PLAYER_NAME_HEIGHT)
    lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    table.insert(GCP.dynamicControls, lbl)
    return y + GCP.PLAYER_NAME_HEIGHT
end

function GCP.CreateTextRow(parent, x, y, width, text, r, g, b, height, font)
    height = height or GCP.PLAYER_NAME_HEIGHT
    font = font or GCP.FONT_NORMAL
    r = r or 1; g = g or 1; b = b or 1

    local lbl = wm:CreateControl(nil, parent, CT_LABEL)
    lbl:SetFont(font)
    lbl:SetText(text)
    lbl:SetColor(r, g, b, 1)
    lbl:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    lbl:SetDimensions(width, height)
    lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    table.insert(GCP.dynamicControls, lbl)
    return y + height
end

-- ============================================================================
-- Role color helper
-- ============================================================================

function GCP.GetRoleColor(role)
    if Beltalowda.SetDatabase and Beltalowda.SetDatabase.GetRoleColor then
        return Beltalowda.SetDatabase.GetRoleColor(role)
    end
    if role == "pull" then return 1, 0.5, 0 end
    if role == "support" then return 0.3, 1, 0.3 end
    return 1, 0.3, 0.3
end

-- ============================================================================
-- Quality / rarity color mapping
-- ============================================================================

-- ESO quality tiers → RGB colors matching the in-game rarity scheme
-- Quality 6 is a synthetic value for Mythic sets (always displayed orange)
local QUALITY_COLORS = {
    [0] = { 0.60, 0.60, 0.60 },  -- Trash (gray)
    [1] = { 0.87, 0.87, 0.87 },  -- Normal (white)
    [2] = { 0.12, 0.76, 0.12 },  -- Fine (green)
    [3] = { 0.22, 0.56, 1.00 },  -- Superior (blue)
    [4] = { 0.64, 0.23, 0.93 },  -- Epic (purple)
    [5] = { 0.97, 0.80, 0.26 },  -- Legendary (gold)
    [6] = { 1.00, 0.50, 0.00 },  -- Mythic (orange)
}

function GCP.GetQualityColor(quality)
    local c = QUALITY_COLORS[quality or 5]
    if c then return c[1], c[2], c[3] end
    return 0.7, 0.7, 0.7  -- Fallback gray
end

-- ============================================================================
-- Auto-dismiss on movement or ability cast
-- ============================================================================


-- ============================================================================
-- Debug: Mock 12-player group for layout testing (/beltatest12)
-- ============================================================================

local MOCK_PLAYERS = {
    { name = "Aldmeri Tank",      role = "pull",    sets = {
        { name = "Saxhleel Champion", pieces = 5, maxPieces = 5, barInfo = " (Front Bar)", quality = 5 },
        { name = "Powerful Assault",  pieces = 5, maxPieces = 5, barInfo = " (Back Bar)",  quality = 5 },
        { name = "Archdruid Devyric", pieces = 1, maxPieces = 1, barInfo = "",             quality = 6 },
    }},
    { name = "Daggerfall Tank",   role = "pull",    sets = {
        { name = "Turning Tide",      pieces = 5, maxPieces = 5, barInfo = " (Front Bar)", quality = 5 },
        { name = "Claw of Yolnahkriin", pieces = 5, maxPieces = 5, barInfo = " (Back Bar)", quality = 5 },
        { name = "Monomyth Reforged", pieces = 1, maxPieces = 1, barInfo = "",             quality = 6 },
    }},
    { name = "Ebonheart Healer",  role = "support", sets = {
        { name = "Spell Power Cure",  pieces = 5, maxPieces = 5, barInfo = " (Front Bar)", quality = 5 },
        { name = "Worm's Raiment",    pieces = 5, maxPieces = 5, barInfo = " (Back Bar)",  quality = 5 },
        { name = "Symphony of Blades", pieces = 1, maxPieces = 1, barInfo = "",            quality = 6 },
    }},
    { name = "Breton Healer",     role = "support", sets = {
        { name = "Pillager's Profit", pieces = 5, maxPieces = 5, barInfo = " (Front Bar)", quality = 5 },
        { name = "Roaring Opportunist", pieces = 5, maxPieces = 5, barInfo = " (Back Bar)", quality = 5 },
        { name = "Monomyth Reforged", pieces = 1, maxPieces = 1, barInfo = "",             quality = 6 },
    }},
    { name = "Khajiit Nightblade", role = "damage", sets = {
        { name = "Pillar of Nirn",    pieces = 5, maxPieces = 5, barInfo = " (Front Bar)", quality = 5 },
        { name = "Kinras's Wrath",    pieces = 5, maxPieces = 5, barInfo = " (Back Bar)",  quality = 5 },
        { name = "Oakensoul Ring",    pieces = 1, maxPieces = 1, barInfo = "",             quality = 6 },
    }},
    { name = "Dunmer Sorcerer",   role = "damage",  sets = {
        { name = "False God's Devotion", pieces = 5, maxPieces = 5, barInfo = "",          quality = 5 },
        { name = "Mother's Sorrow",   pieces = 5, maxPieces = 5, barInfo = "",             quality = 5 },
        { name = "Maw of the Infernal", pieces = 2, maxPieces = 2, barInfo = "",           quality = 5 },
    }},
    { name = "Argonian Templar",  role = "damage",  sets = {
        { name = "Deadly Strike",     pieces = 5, maxPieces = 5, barInfo = " (Front Bar)", quality = 5 },
        { name = "Aegis of Galenwe", pieces = 5, maxPieces = 5, barInfo = " (Back Bar)",  quality = 5 },
        { name = "Armor of the Trainee", pieces = 1, maxPieces = 3, barInfo = "",          quality = 1 },
    }},
    { name = "Orc Dragonknight",  role = "damage",  sets = {
        { name = "Vicious Death",     pieces = 5, maxPieces = 5, barInfo = " (Front Bar)", quality = 5 },
        { name = "Plaguebreak",       pieces = 5, maxPieces = 5, barInfo = " (Back Bar)",  quality = 5 },
    }},
    { name = "Bosmer Warden",     role = "damage",  sets = {
        { name = "Briarheart",        pieces = 5, maxPieces = 5, barInfo = "",             quality = 5 },
        { name = "Hunding's Rage",    pieces = 5, maxPieces = 5, barInfo = "",             quality = 5 },
        { name = "Balorgh",           pieces = 2, maxPieces = 2, barInfo = "",             quality = 5 },
    }},
    { name = "Imperial Necro",    role = "damage",  sets = {
        { name = "Order's Wrath",     pieces = 5, maxPieces = 5, barInfo = "",             quality = 5 },
        { name = "Bahsei's Mania",    pieces = 5, maxPieces = 5, barInfo = "",             quality = 5 },
        { name = "Slimecraw",         pieces = 1, maxPieces = 2, barInfo = "",             quality = 5 },
    }},
    { name = "High Elf Arcanist", role = "damage",  sets = {
        { name = "Whorl of the Depths", pieces = 5, maxPieces = 5, barInfo = " (Front Bar)", quality = 5 },
        { name = "Coral Riptide",     pieces = 5, maxPieces = 5, barInfo = " (Back Bar)",   quality = 5 },
        { name = "Monomyth Reforged", pieces = 1, maxPieces = 1, barInfo = "",              quality = 6 },
    }},
    { name = "Redguard Stamplar", role = "damage",  sets = {
        { name = "Rallying Cry",      pieces = 5, maxPieces = 5, barInfo = " (Front Bar)", quality = 5 },
        { name = "Coldharbour Fav.",  pieces = 5, maxPieces = 5, barInfo = " (Back Bar)",  quality = 5 },
        { name = "Ring of the Pale Order", pieces = 1, maxPieces = 1, barInfo = "",        quality = 6 },
    }},
}

function GCP.GenerateMockData()
    -- Use GetAbilityIcon with known ability IDs for reliable icon textures
    local foodIcon = GetAbilityIcon(61259) or "/esoui/art/icons/ability_provisioner_004.dds"
    local apIcon = GetAbilityIcon(147687) or "/esoui/art/icons/ability_provisioner_004.dds"
    local xpIcon = GetAbilityIcon(64210) or "/esoui/art/icons/ability_provisioner_004.dds"
    local mundusIcon = GetAbilityIcon(13940) or "/esoui/art/icons/ability_mundusstones_007.dds"  -- The Warrior

    -- Buff icons from real ability IDs
    local majorResolveIcon = GetAbilityIcon(44835) or ""   -- Major Resolve
    local minorToughnessIcon = GetAbilityIcon(64149) or "" -- Minor Toughness
    local majorCourageIcon = GetAbilityIcon(109966) or ""  -- Major Courage
    local majorEvasionIcon = GetAbilityIcon(61716) or ""   -- Major Evasion
    local conduitIcon = GetAbilityIcon(68530) or ""        -- Conduit synergy

    -- Champion Point mock data — use real discipline textures if CPC is available
    local CPC = Beltalowda.Data and Beltalowda.Data.ChampionPointComposition
    local mockCpIcons = {}
    if CPC and CPC.GetOrderedDisciplineIds and #CPC.GetOrderedDisciplineIds() > 0 then
        local orderedIds = CPC.GetOrderedDisciplineIds()
        for _, discId in ipairs(orderedIds) do
            local iconPath = CPC.GetDisciplineIcon(discId, 4)
            local discName = CPC.GetDisciplineName(discId)
            local tooltip = string.format("|cFFFFFF%s (4/4)|r\n  |c00FF00Mock Perk 1|r\n  |c00FF00Mock Perk 2|r\n  |c00FF00Mock Perk 3|r\n  |c00FF00Mock Perk 4|r", discName)
            if iconPath then
                table.insert(mockCpIcons, { iconPath = iconPath, tooltip = tooltip })
            end
        end
    end

    local players = {}
    for i, mock in ipairs(MOCK_PLAYERS) do
        local p = {
            name = mock.name,
            role = mock.role,
            sets = mock.sets,
            groupBuffs = {},
            selfBuffs = {},
            synergies = {},
            mundus = {{ iconPath = mundusIcon, tooltip = "The Warrior" }},
            consumables = {},
            championPoints = mockCpIcons,
        }

        -- Add some mock buffs to tanks/healers
        if mock.role == "pull" then
            table.insert(p.groupBuffs, { iconPath = majorResolveIcon, tooltip = "Major Resolve" })
            table.insert(p.groupBuffs, { iconPath = minorToughnessIcon, tooltip = "Minor Toughness" })
        elseif mock.role == "support" then
            table.insert(p.groupBuffs, { iconPath = majorCourageIcon, tooltip = "Major Courage" })
            table.insert(p.selfBuffs, { iconPath = majorEvasionIcon, tooltip = "Major Evasion" })
        else
            -- Some DPS have self buffs
            if i % 2 == 0 then
                table.insert(p.selfBuffs, { iconPath = majorEvasionIcon, tooltip = "Major Evasion" })
            end
            if i % 3 == 0 then
                table.insert(p.synergies, { iconPath = conduitIcon, tooltip = "Conduit" })
            end
        end

        -- Add consumable icons with varying times
        local foodTime = 3600 + math.random(0, 7200)
        table.insert(p.consumables, {
            iconPath = foodIcon,
            tooltip = string.format("Artaeum Takeaway Broth: %s remaining", GCP.FormatConsumableTime(foodTime)),
        })
        if i <= 6 then
            local apTime = 600 + math.random(0, 1200)
            table.insert(p.consumables, {
                iconPath = apIcon,
                tooltip = string.format("Molten War Torte: %s remaining", GCP.FormatConsumableTime(apTime)),
            })
        end
        if i % 4 == 0 then
            local xpTime = 300 + math.random(0, 900)
            table.insert(p.consumables, {
                iconPath = xpIcon,
                tooltip = string.format("Psijic Ambrosia: %s remaining", GCP.FormatConsumableTime(xpTime)),
            })
        end

        table.insert(players, p)
    end

    -- Sort like real data: role priority then alphabetical
    table.sort(players, function(a, b)
        local ra = GCP.ROLE_SORT_ORDER[a.role] or 2
        local rb = GCP.ROLE_SORT_ORDER[b.role] or 2
        if ra ~= rb then return ra < rb end
        return a.name < b.name
    end)

    return players
end

function GCP.ShowMockPanel()
    if not GCP.initialized then GCP.Initialize() end

    -- Temporarily override GatherGroupDataSorted and GetGroupSize
    local origGather = GCP.GatherGroupDataSorted
    local origGetGroupSize = GetGroupSize

    GCP.GatherGroupDataSorted = function() return GCP.GenerateMockData() end
    -- Patch GetGroupSize so Refresh() doesn't show "Not in a group"
    GetGroupSize = function() return 12 end

    GCP.Refresh()
    GCP.controls.window:SetHidden(false)
    GCP.state.visible = true

    -- Restore originals
    GCP.GatherGroupDataSorted = origGather
    GetGroupSize = origGetGroupSize
end

SLASH_COMMANDS["/beltatest12"] = function()
    GCP.ShowMockPanel()
    d("[Beltalowda] Mock 12-player composition panel opened")
end