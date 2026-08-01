-- StickyHoTs - HoT Counter Addon
-- Counts active Heal over Time effects on the player and displays current/8

-- ============================================================================
-- Namespace
-- ============================================================================

local StickyHoTs = {}

local SH = StickyHoTs

-- Addon metadata
SH.name = "StickyHoTs"
SH.version = "2.0.1"
SH.author = "Kickimanjaro"

-- Constants
SH.MAX_HOTS = 8
SH.UPDATE_INTERVAL_MS = 1000

-- State
SH.inPvPZone = false
SH.groupMode = true
SH.controls = {}
SH.savedVars = nil
SH.useCharacterName = false
SH.showBackground = false
SH.mockData = nil -- set by /stickyhots test12

-- Group mode UI dimensions
SH.PLAYER_MODE_WIDTH = 80
SH.PLAYER_MODE_HEIGHT = 32
SH.GROUP_COUNT_WIDTH = 30 -- space reserved for right-aligned count numbers
SH.GROUP_PADDING = 20    -- total extra width beyond name text (count column + margins)
SH.GROUP_INSET = 10      -- left/right inset for content labels
SH.GROUP_HEADER_HEIGHT = 24 -- header label height
SH.GROUP_DIVIDER_HEIGHT = 8 -- divider texture height + spacing

-- Window manager reference
local wm = GetWindowManager()

-- ============================================================================
-- HoT Counting
-- ============================================================================

--[[
    Count active Heal over Time effects on a specific unit.
    
    Filters for buffs (not debuffs) with abilityType == ABILITY_TYPE_HEAL
    that have remaining duration (timeEnding > 0 and timeEnding > now).
    
    @param unitTag  string  Unit tag to scan (e.g. "player", "group1")
    @return number  Count of active HoT effects
]]--
function SH.CountHoTsOnUnit(unitTag)
    local count = 0
    local numBuffs = GetNumBuffs(unitTag)
    local now = GetGameTimeSeconds()

    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename,
              deprecatedBuffType, effectType, abilityType, statusEffectType, abilityId,
              canClickOff, castByPlayer = GetUnitBuffInfo(unitTag, i)

        -- A HoT is a buff (not debuff) with ABILITY_TYPE_HEAL and a remaining duration
        if effectType == BUFF_EFFECT_TYPE_BUFF
           and abilityType == ABILITY_TYPE_HEAL
           and timeEnding > 0
           and timeEnding > now then
            count = count + 1
        end
    end

    return count
end

--[[
    Scan group members and count HoTs on each player.
    Returns a table:  {[displayName] = count}
    Falls back to scanning just the player when solo.
]]--
function SH.CountGroupStickyHoTs()
    local results = {}
    local groupSize = GetGroupSize()

    -- Always read local player directly via "player" tag for reliable data
    local playerName = GetUnitDisplayName("player")
    local playerLabel = SH.useCharacterName and GetUnitName("player") or playerName
    results[playerLabel] = SH.CountHoTsOnUnit("player")

    if groupSize == 0 then
        return results
    end

    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag and DoesUnitExist(unitTag) then
            local name = GetUnitDisplayName(unitTag)
            -- Skip the local player (already added above via "player" tag)
            if name ~= playerName then
                local label = SH.useCharacterName and GetUnitName(unitTag) or name
                results[label] = SH.CountHoTsOnUnit(unitTag)
            end
        end
    end

    return results
end

-- ============================================================================
-- Display Update
-- ============================================================================

--[[
    Update the HoT counter display label.
    Colors the text to warn as count approaches the U49 healing debuff cap (8 HoTs):
      - Red (>= 8): healing debuff active (-33% healing taken)
      - Yellow (6-7): approaching cap, danger zone
      - Green (1-5): safe
      - White (0): no HoTs
    
    @param count  number  Current number of active HoTs
]]--
function SH.UpdateDisplay(count)
    local label = SH.controls.label
    if not label then return end

    label:SetText(count .. "/" .. SH.MAX_HOTS)

    -- Color thresholds: warn as HoT count approaches the debuff cap
    if count >= SH.MAX_HOTS then
        label:SetColor(1.0, 0.3, 0.3, 1) -- red: debuff active
    elseif count >= 6 then
        label:SetColor(1.0, 1.0, 0.2, 1) -- yellow: approaching cap
    elseif count >= 1 then
        label:SetColor(0.2, 1.0, 0.2, 1) -- green: safe
    else
        label:SetColor(1.0, 1.0, 1.0, 1) -- white: no HoTs
    end
end

--[[
    Update the group HoT display with a sorted, color-coded list.
    Shows @name and HoT count for each group member.
]]--
function SH.UpdateGroupDisplay()
    local label = SH.controls.label
    local countLabel = SH.controls.countLabel
    if not label or not countLabel then return end

    local data = SH.mockData or SH.CountGroupStickyHoTs()

    -- Convert to sortable table
    local sorted = {}
    for name, count in pairs(data) do
        table.insert(sorted, {name = name, count = count})
    end

    -- Sort highest HoTs first
    table.sort(sorted, function(a, b) return a.count > b.count end)

    local nameText = ""
    local countText = ""

    for i, entry in ipairs(sorted) do
        local color
        if entry.count >= 8 then
            color = "|cFF3333"
        elseif entry.count >= 6 then
            color = "|cFFAA33"
        elseif entry.count >= 4 then
            color = "|cFFFF66"
        else
            color = "|c66FF66"
        end
        if i > 1 then
            nameText = nameText .. "\n"
            countText = countText .. "\n"
        end
        nameText = nameText .. color .. entry.name
        countText = countText .. color .. entry.count
    end
    nameText = nameText .. "|r"
    countText = countText .. "|r"

    -- Expand window before setting text so labels have room for all lines.
    -- Must expand BOTH width and height — labels are two-point anchored, so
    -- GetTextDimensions() wraps text within the label's current width.
    SH.controls.window:SetDimensions(800, 800)

    label:SetText(nameText)
    label:SetColor(1, 1, 1, 1)
    countLabel:SetText(countText)
    countLabel:SetColor(1, 1, 1, 1)

    -- Size window to fit actual text content
    local nameWidth, nameHeight = label:GetTextDimensions()
    local headerOffset = SH.GROUP_INSET + SH.GROUP_HEADER_HEIGHT + SH.GROUP_DIVIDER_HEIGHT
    local width = nameWidth + SH.GROUP_COUNT_WIDTH + SH.GROUP_PADDING
    local height = headerOffset + nameHeight + SH.GROUP_INSET -- top and bottom padding match
    SH.controls.window:SetDimensions(width, height)

    -- Stretch divider to match content width
    SH.controls.divider:SetWidth(width - SH.GROUP_PADDING)
end

--[[
    Update the header text with Battle Spirit icon.
    The addon only displays in PvP zones where Battle Spirit is always active,
    so we can rely on GetArtificialEffectInfo() returning its icon.
]]--
function SH.UpdateHeaderText()
    if not SH.controls.headerLabel then return end
    for effectId in ZO_GetNextActiveArtificialEffectIdIter do
        local displayName, icon = GetArtificialEffectInfo(effectId)
        if zo_strformat(SI_ABILITY_TOOLTIP_NAME, displayName) == "Battle Spirit" then
            SH.controls.headerLabel:SetText(zo_iconFormat(icon, 24, 24) .. " HoTs")
            return
        end
    end
    SH.controls.headerLabel:SetText("HoTs")
end

--[[
    Resize the window to match the current display mode.
]]--
function SH.ResizeForMode()
    if not SH.controls.window then return end
    if SH.groupMode then
        -- Will be sized dynamically by UpdateGroupDisplay
        SH.controls.window:SetDimensions(150, 200)
        local contentTop = SH.GROUP_INSET + SH.GROUP_HEADER_HEIGHT + SH.GROUP_DIVIDER_HEIGHT
        SH.controls.label:ClearAnchors()
        SH.controls.label:SetAnchor(TOPLEFT, SH.controls.window, TOPLEFT, SH.GROUP_INSET, contentTop)
        SH.controls.label:SetAnchor(BOTTOMRIGHT, SH.controls.window, BOTTOMRIGHT, -SH.GROUP_INSET, 0)
        SH.controls.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        SH.controls.label:SetVerticalAlignment(TEXT_ALIGN_TOP)
        SH.controls.countLabel:ClearAnchors()
        SH.controls.countLabel:SetAnchor(TOPLEFT, SH.controls.window, TOPLEFT, SH.GROUP_INSET, contentTop)
        SH.controls.countLabel:SetAnchor(BOTTOMRIGHT, SH.controls.window, BOTTOMRIGHT, -SH.GROUP_INSET, 0)
        SH.controls.countLabel:SetHidden(false)
        SH.controls.headerLabel:SetHidden(false)
        SH.controls.divider:SetHidden(false)
    else
        SH.controls.window:SetDimensions(SH.PLAYER_MODE_WIDTH, SH.PLAYER_MODE_HEIGHT)
        SH.controls.label:ClearAnchors()
        SH.controls.label:SetAnchorFill(SH.controls.window)
        SH.controls.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        SH.controls.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        SH.controls.countLabel:SetHidden(true)
        SH.controls.countLabel:SetText("")
        SH.controls.headerLabel:SetHidden(true)
        SH.controls.divider:SetHidden(true)
    end
end

--[[
    Recount HoTs and refresh the display. Called by both event handlers
    and the periodic fallback scan.
]]--
function SH.RefreshCount()
    if SH.groupMode then
        SH.UpdateGroupDisplay()
    else
        SH.UpdateDisplay(SH.CountHoTsOnUnit("player"))
    end
end

-- ============================================================================
-- PvP Zone Detection
-- ============================================================================

--[[
    Check if the player is currently in a PvP zone where Battle Spirit applies.
    Uses the same reliable ESO API functions as Beltalowda's PvPDetection:
      IsPlayerInAvAWorld()        — on an AvA campaign server
      IsInCyrodiil()              — Cyrodiil overland, delves
      IsInImperialCity()          — IC districts and sewers
      IsActiveWorldBattleground() — Battleground instances

    @return boolean
]]--
function SH.IsInPvPZone()
    return IsPlayerInAvAWorld() == true
        or IsInCyrodiil() == true
        or IsInImperialCity() == true
        or IsActiveWorldBattleground() == true
end

--[[
    Update visibility based on PvP zone state.
    Shows the window when in a PvP zone and HUD is visible; hides otherwise.
]]--
function SH.UpdatePvPVisibility()
    if not SH.controls.window then return end

    if SH.inPvPZone then
        -- Show if HUD is active
        local hudScene = SCENE_MANAGER:GetScene("hud")
        local hudUiScene = SCENE_MANAGER:GetScene("hudui")
        local hudVisible = (hudScene and hudScene:GetState() == SCENE_SHOWN)
                        or (hudUiScene and hudUiScene:GetState() == SCENE_SHOWN)
        SH.controls.window:SetHidden(not hudVisible)
    else
        SH.controls.window:SetHidden(true)
    end
end

-- ============================================================================
-- UI Creation
-- ============================================================================

--[[
    Create the movable HoT counter UI element.
    
    Structure:
      StickyHoTsUI (TopLevelWindow, movable)
        └── Backdrop (CT_BACKDROP, semi-transparent black)
        └── Label (CT_LABEL, "0/8" text)
]]--
function SH.CreateUI()
    -- Top-level movable window
    local tlw = wm:CreateTopLevelWindow("StickyHoTsUI")
    tlw:SetDimensions(80, 32)
    tlw:SetMovable(true)
    tlw:SetMouseEnabled(true)
    tlw:SetClampedToScreen(true)
    tlw:SetHidden(true)

    -- Save position on drag
    tlw:SetHandler("OnMoveStop", function()
        SH.SaveWindowPosition()
    end)

    SH.controls.window = tlw

    -- Semi-transparent backdrop
    local bg = wm:CreateControl("$(parent)BG", tlw, CT_BACKDROP)
    bg:SetAnchorFill(tlw)
    bg:SetCenterColor(0, 0, 0, 0.6)
    bg:SetEdgeColor(0, 0, 0, 0.8)
    SH.controls.backdrop = bg

    -- Apply saved background visibility
    bg:SetHidden(not SH.showBackground)

    -- Header label (group mode: Battle Spirit icon + "HoTs" title)
    local headerLabel = wm:CreateControl("$(parent)Header", tlw, CT_LABEL)
    headerLabel:SetFont("ZoFontGameLarge")
    headerLabel:SetColor(1, 1, 1, 1)
    headerLabel:SetText("HoTs")
    headerLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    headerLabel:SetAnchor(TOPLEFT, tlw, TOPLEFT, 0, SH.GROUP_INSET)
    headerLabel:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, 0, SH.GROUP_INSET)
    headerLabel:SetDrawLayer(1)
    headerLabel:SetMouseEnabled(true)
    -- Dragging: forward mouse down/up to parent TLW for move behavior
    headerLabel:SetHandler("OnMouseDown", function()
        tlw:StartMoving()
    end)
    headerLabel:SetHandler("OnMouseUp", function()
        tlw:StopMovingOrResizing()
        SH.SaveWindowPosition()
    end)
    headerLabel:SetHandler("OnMouseEnter", function(control)
        -- Show Battle Spirit tooltip. Since the addon only displays in PvP zones,
        -- Battle Spirit is always active when this handler fires.
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -5, TOP)
        for effectId in ZO_GetNextActiveArtificialEffectIdIter do
            local displayName = GetArtificialEffectInfo(effectId)
            if zo_strformat(SI_ABILITY_TOOLTIP_NAME, displayName) == "Battle Spirit" then
                InformationTooltip:AddLine(displayName, "", ZO_SELECTED_TEXT:UnpackRGBA())
                InformationTooltip:AddLine(GetArtificialEffectTooltipText(effectId), "", ZO_NORMAL_TEXT:UnpackRGBA())
                break
            end
        end
    end)
    headerLabel:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
    headerLabel:SetHidden(true)
    SH.controls.headerLabel = headerLabel

    -- Horizontal divider under header (group mode only)
    local divider = wm:CreateControl("$(parent)Divider", tlw, CT_TEXTURE)
    divider:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
    divider:SetAnchor(TOP, headerLabel, BOTTOM, 0, 2)
    divider:SetDimensions(150, 4)
    divider:SetColor(0.5, 0.5, 0.5, 0.6)
    divider:SetDrawLayer(1)
    divider:SetHidden(true)
    SH.controls.divider = divider

    -- Counter label (player mode: centered count; group mode: left-aligned names)
    local label = wm:CreateControl("$(parent)Label", tlw, CT_LABEL)
    label:SetFont("ZoFontGameLarge")
    label:SetColor(1, 1, 1, 1)
    label:SetText("0/" .. SH.MAX_HOTS)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetAnchorFill(tlw)
    label:SetMaxLineCount(0)
    label:SetDrawLayer(1)
    SH.controls.label = label

    -- Right-aligned count label (group mode only)
    local countLabel = wm:CreateControl("$(parent)CountLabel", tlw, CT_LABEL)
    countLabel:SetFont("ZoFontGameLarge")
    countLabel:SetColor(1, 1, 1, 1)
    countLabel:SetText("")
    countLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    countLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    countLabel:SetAnchorFill(tlw)
    countLabel:SetMaxLineCount(0)
    countLabel:SetDrawLayer(1)
    countLabel:SetHidden(true)
    SH.controls.countLabel = countLabel

    -- Restore saved position or default to center
    SH.RestoreWindowPosition()
end

-- ============================================================================
-- Window Position Persistence
-- ============================================================================

function SH.SaveWindowPosition()
    if not SH.savedVars then return end
    SH.savedVars.position = SH.savedVars.position or {}
    SH.savedVars.position.x = SH.controls.window:GetLeft()
    SH.savedVars.position.y = SH.controls.window:GetTop()
end

function SH.RestoreWindowPosition()
    local win = SH.controls.window
    if not win then return end

    win:ClearAnchors()
    if SH.savedVars and SH.savedVars.position and SH.savedVars.position.x then
        win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SH.savedVars.position.x, SH.savedVars.position.y)
    else
        win:SetAnchor(CENTER, GuiRoot, CENTER, 0, -200)
    end
end

-- ============================================================================
-- Scene Visibility (show only on HUD)
-- ============================================================================

function SH.OnSceneStateChange(oldState, newState)
    if not SH.controls.window then return end

    -- Only show when in a PvP zone and HUD is visible
    if newState == SCENE_SHOWN and SH.inPvPZone then
        SH.controls.window:SetHidden(false)
    elseif newState == SCENE_HIDDEN then
        SH.controls.window:SetHidden(true)
    end
end

function SH.RegisterSceneCallbacks()
    local hudScene = SCENE_MANAGER:GetScene("hud")
    local hudUiScene = SCENE_MANAGER:GetScene("hudui")

    if hudScene then
        hudScene:RegisterCallback("StateChange", SH.OnSceneStateChange)
    end
    if hudUiScene then
        hudUiScene:RegisterCallback("StateChange", SH.OnSceneStateChange)
    end
end

-- ============================================================================
-- Event Handlers
-- ============================================================================

--[[
    EVENT_EFFECT_CHANGED handler.
    Fires when any buff/debuff is gained, faded, or updated on the player.
    We recount all HoTs on each change to keep the display accurate.
]]--
function SH.OnEffectChanged(eventCode, changeType, effectSlot, effectName,
        unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType,
        effectType, abilityType, statusEffectType, unitName, unitId, abilityId,
        sourceType)
    -- Only care about buff changes that could affect HoT count
    if changeType == EFFECT_RESULT_GAINED
       or changeType == EFFECT_RESULT_FADED
       or changeType == EFFECT_RESULT_UPDATED then
        SH.RefreshCount()
    end
end

--[[
    EVENT_PLAYER_ACTIVATED handler.
    Fires after every loading screen. Buff lists reset on zone transitions,
    so we must rescan immediately.
]]--
function SH.OnPlayerActivated()
    -- Detect PvP zone using reliable API functions (works immediately, no event timing issues)
    SH.inPvPZone = SH.IsInPvPZone()
    SH.UpdateHeaderText()
    SH.RefreshCount()
    SH.UpdatePvPVisibility()
end

-- ============================================================================
-- Initialization
-- ============================================================================

function SH.OnAddOnLoaded(eventCode, addonName)
    if addonName ~= SH.name then return end
    EVENT_MANAGER:UnregisterForEvent(SH.name, EVENT_ADD_ON_LOADED)

    -- Initialize SavedVariables (account-wide)
    local defaults = {
        position = nil, -- { x = number, y = number }
        groupMode = true,
        useCharacterName = false,
        showBackground = false,
    }
    SH.savedVars = ZO_SavedVars:NewAccountWide("StickyHoTsVars", 1, nil, defaults)
    SH.groupMode = SH.savedVars.groupMode or false
    SH.useCharacterName = SH.savedVars.useCharacterName or false
    if SH.savedVars.showBackground == nil then SH.savedVars.showBackground = true end
    SH.showBackground = SH.savedVars.showBackground

    -- Create UI
    SH.CreateUI()
    SH.ResizeForMode()

    -- Register for buff change events on the player
    EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_EFFECT_CHANGED, SH.OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(SH.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    -- Periodic fallback scan (catches silent buff expirations)
    EVENT_MANAGER:RegisterForUpdate(SH.name .. "Scan", SH.UPDATE_INTERVAL_MS, SH.RefreshCount)

    -- Register for zone transitions
    EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_PLAYER_ACTIVATED, SH.OnPlayerActivated)

    -- Scene callbacks for HUD visibility
    SH.RegisterSceneCallbacks()

    -- Refresh immediately when group composition changes
    EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_GROUP_MEMBER_JOINED, function() SH.RefreshCount() end)
    EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_GROUP_MEMBER_LEFT, function() SH.RefreshCount() end)

    -- Slash commands
    SLASH_COMMANDS["/stickyhots"] = function(args)
        if args == "group" then
            SH.groupMode = true
            SH.savedVars.groupMode = true
            SH.ResizeForMode()
            SH.RefreshCount()
            d("|c00FF00[StickyHoTs]|r Group mode")
        elseif args == "self" then
            SH.groupMode = false
            SH.savedVars.groupMode = false
            SH.ResizeForMode()
            SH.RefreshCount()
            d("|c00FF00[StickyHoTs]|r Self mode")
        elseif args == "name" then
            SH.useCharacterName = not SH.useCharacterName
            SH.savedVars.useCharacterName = SH.useCharacterName
            -- Regenerate mock data if active so it picks up the name change
            if SH.mockData then
                SH.mockData = SH.GenerateMockData()
            end
            SH.RefreshCount()
            if SH.useCharacterName then
                d("|c00FF00[StickyHoTs]|r Showing character names")
            else
                d("|c00FF00[StickyHoTs]|r Showing account names")
            end
        elseif args == "background" then
            SH.showBackground = not SH.showBackground
            SH.savedVars.showBackground = SH.showBackground
            SH.controls.backdrop:SetHidden(not SH.showBackground)
            if SH.showBackground then
                d("|c00FF00[StickyHoTs]|r Background ON")
            else
                d("|c00FF00[StickyHoTs]|r Background OFF")
            end
        elseif args == "test12" then
            SH.ShowMockGroup()
        elseif args == "show" or args == "hide" or args == "toggle" then
            if SH.controls.window then
                local isHidden = SH.controls.window:IsHidden()
                SH.controls.window:SetHidden(not isHidden)
                if isHidden then
                    d("|c00FF00[StickyHoTs]|r Shown \226\128\148 drag to reposition")
                else
                    d("|c00FF00[StickyHoTs]|r Hidden")
                end
            end
        else
            d("|c00FF00[StickyHoTs]|r Usage:")
            d("/stickyhots |cFFFFFFtoggle|r — show/hide the window")
            d("/stickyhots |cFFFFFFself|r — self-only HoT counter")
            d("/stickyhots |cFFFFFFgroup|r — group HoT display")
            d("/stickyhots |cFFFFFFname|r — toggle account/character names")
            d("/stickyhots |cFFFFFFbackground|r — toggle backdrop")
            d("/stickyhots |cFFFFFFtest12|r — show mock 12-player group")
        end
    end

    -- Initial scan
    SH.RefreshCount()

end

-- ============================================================================
-- Debug: Mock 12-player group for layout testing
-- ============================================================================

local MOCK_PLAYERS = {
    { account = "@TankMain",      character = "Aldmeri Tank" },
    { account = "@OffTank",       character = "Daggerfall Guard" },
    { account = "@HealBot",       character = "Ebonheart Healer" },
    { account = "@RestoStaff",    character = "Breton Restorer" },
    { account = "@StamBlade",     character = "Khajiit Nightblade" },
    { account = "@MagSorc",       character = "Dunmer Sorcerer" },
    { account = "@BowBoy",        character = "Bosmer Warden" },
    { account = "@CritTempBoi",   character = "Argonian Templar" },
    { account = "@NecroMancer",   character = "Imperial Necro" },
    { account = "@IceWarden",     character = "Nord Frostmage" },
    { account = "@ArcanistPrime", character = "High Elf Arcanist" },
    { account = "@Kickimanjaro",  character = "Redguard Stamplar" },
}

function SH.GenerateMockData()
    local data = {}
    local counts = { 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, 12 }
    for i, mock in ipairs(MOCK_PLAYERS) do
        local name = SH.useCharacterName and mock.character or mock.account
        data[name] = counts[i] or math.random(0, 12)
    end
    return data
end

function SH.ShowMockGroup()
    -- Force group mode on and inject mock data
    SH.groupMode = true
    SH.mockData = SH.GenerateMockData()
    SH.ResizeForMode()
    SH.UpdateGroupDisplay()
    SH.controls.window:SetHidden(false)
    d("|c00FF00[StickyHoTs]|r Mock 12-player group shown. Type /stickyhots to hide.")

    -- Clear mock data after 30 seconds so real data resumes
    zo_callLater(function()
        if SH.mockData then
            SH.mockData = nil
            SH.RefreshCount()
            d("|c00FF00[StickyHoTs]|r Mock data cleared, showing real data.")
        end
    end, 30000)
end

-- Register for addon loaded
EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_ADD_ON_LOADED, SH.OnAddOnLoaded)
