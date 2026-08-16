--[[
    BlockPooky HoT Tracker Module - Update 49 HoT Cap Support

    This module tracks Healing-over-Time effects on the player to monitor compliance
    with the Update 49 HoT cap (maximum 8 stacks per player).

    Key Features:
    - Counts HoTs directly from the game's own buff list (GetUnitBuffInfo)
    - No manual ability-ID database: every HoT source is covered automatically
      (skills, sets, items, scribing effects, procs, …) and can never go stale.
    - Uses the game's authoritative remaining duration (handles refreshes,
      CP/buff/set duration modifiers, and automatic expiry for us).
    - Visual counter bar showing current count vs cap (8)
    - Color warnings: Green (safe) → Yellow (warning) → Red (at cap)
    - Movable UI with position persistence
    - Toggle on/off via settings menu (default: OFF)

    How It Works:
    1. COUNTING: CountPlayerHoTs() scans the player's active buff list once.
       - Keeps only buffs (not debuffs) with abilityType == ABILITY_TYPE_HEAL
       - Includes only effects with remaining duration (timeEnding > now)
       - Every active HoT instance counts as 1 toward the 8-cap.
       Because the game itself maintains this list, the count is always exact:
       no ability IDs to maintain, no manual expiry, no duration guessing.

    2. DISPLAY: UpdateHoTDisplay() is driven by the 1s main tick in
       BlockPooky.lua, so the bar stays current without any dedicated events.
       - Green: 0-5 (safe)
       - Yellow: 6-7 (warning)
       - Red: 8+ (at cap)

    NOTE ON ARCHITECTURE:
    The previous implementation (a hand-maintained hotDatabase of ~2000 ability
    IDs + EVENT_COMBAT_EVENT tracking with hardcoded durations) was removed.
    It was inherently incomplete (any missing/unknown ability ID meant a missed
    HoT, e.g. from sets or scribing skills), its hardcoded durations drifted
    from real in-game durations (CP/buff/set modifiers), and it could not react
    to zone changes or deaths. Reading the game's buff list is both simpler and
    correct by construction.
--]]

--[[ basic initialization -------------------------------------------------------------------------------------------]]
BlockPooky = BlockPooky or {}
local BlockPooky = BlockPooky

--[[ HoT counting ---------------------------------------------------------------------------------------------------]]

---Count active Healing-over-Time effects on the player.
---
---Reads the player's active buff list (the authoritative in-game state) and
---counts every buff that is a heal-over-time: a positive buff whose originating
---ability is a heal and that still has remaining duration.
---
---This is the same robust approach used by dedicated HoT-counter addons. It
---automatically covers ALL HoT sources (skills, sets, items, scribing effects,
---procs), tracks real remaining durations (including CP/buff/set modifiers),
---and needs no per-ability maintenance.
---
---@return number Count of active HoT effects on the player
function BlockPooky.CountPlayerHoTs()
    local count = 0
    local numBuffs = GetNumBuffs("player")
    local now = GetGameTimeSeconds()

    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename,
        deprecatedBuffType, effectType, abilityType, statusEffectType, abilityId,
        canClickOff, castByPlayer = GetUnitBuffInfo("player", i)

        -- A HoT is a buff (not debuff) with ABILITY_TYPE_HEAL and remaining duration
        if effectType == BUFF_EFFECT_TYPE_BUFF
            and abilityType == ABILITY_TYPE_HEAL
            and timeEnding > 0
            and timeEnding > now then
            count = count + 1
        end
    end

    return count
end

---Get total HoT count on player (toward the 8-cap).
---@return number total number of active HoT effects
function BlockPooky.GetTotalHoTCount()
    return BlockPooky.CountPlayerHoTs()
end

---Get a breakdown of active HoTs by buff name (for debugging).
---@return table {[buffName] = count}
function BlockPooky.GetHoTBreakdown()
    local breakdown = {}
    local numBuffs = GetNumBuffs("player")
    local now = GetGameTimeSeconds()

    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename,
        deprecatedBuffType, effectType, abilityType, statusEffectType, abilityId,
        canClickOff, castByPlayer = GetUnitBuffInfo("player", i)

        if effectType == BUFF_EFFECT_TYPE_BUFF
            and abilityType == ABILITY_TYPE_HEAL
            and timeEnding > 0
            and timeEnding > now then
            breakdown[buffName] = (breakdown[buffName] or 0) + 1
        end
    end

    return breakdown
end

--[[ UI initialization -------------------------------------------------------------------------------------------]]

function BlockPooky.InitHoTBarUI()
    -- Create the main bar control
    if not BlockPooky.hotBar then
        BlockPooky.hotBar = CreateControl(BlockPooky.name .. "HoTBar", GuiRoot, CT_TOPLEVELCONTROL)
        if not BlockPooky.hotBar then
            return
        end
        BlockPooky.hotBar:SetDimensions(200, 40)
        BlockPooky.hotBar:SetAnchor(CENTER, GuiRoot, CENTER, 0, -20)
        BlockPooky.hotBar:SetHidden(true)
        BlockPooky.hotBar:SetMovable(true)
        BlockPooky.hotBar:SetMouseEnabled(true)

        -- Event for position saving when moved
        BlockPooky.hotBar:SetHandler("OnMoveStop", function()
            BlockPooky.SaveHoTBarPosition()
        end)
    end

    -- Create the label
    if not BlockPooky.hotLabel then
        BlockPooky.hotLabel = CreateControl(BlockPooky.name .. "HoTLabel", BlockPooky.hotBar, CT_LABEL)
        if not BlockPooky.hotLabel then
            return
        end
        BlockPooky.hotLabel:SetFont("ZoFontWinH4")
        BlockPooky.hotLabel:SetColor(0, 1, 0, 1) -- Green by default
        BlockPooky.hotLabel:SetText("")
        BlockPooky.hotLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        BlockPooky.hotLabel:SetAnchor(TOP, BlockPooky.hotBar, TOP, 0, 0)
        BlockPooky.hotLabel:SetHidden(false)
    end

    -- Create the status bar
    if not BlockPooky.hotStatusBar then
        BlockPooky.hotStatusBar = CreateControl(BlockPooky.name .. "HoTStatus", BlockPooky.hotBar, CT_STATUSBAR)
        if not BlockPooky.hotStatusBar then
            return
        end
        BlockPooky.hotStatusBar:SetDimensions(200, 20)
        BlockPooky.hotStatusBar:SetAnchor(BOTTOM, BlockPooky.hotBar, BOTTOM, 0, 0)
        BlockPooky.hotStatusBar:SetMinMax(0, 1)      -- Will be updated dynamically
        BlockPooky.hotStatusBar:SetValue(0)
        BlockPooky.hotStatusBar:SetColor(0, 1, 0, 1) -- Green by default
        BlockPooky.hotStatusBar:SetHidden(false)
    end

    BlockPooky.LoadHoTBarPosition()

    -- NOTE: The HoT display is updated via the main tick (UpdateHoTDisplay),
    -- NOT via a control OnUpdate handler. Control OnUpdate only fires while the
    -- control is visible, which made the bar unreliable in repositioning mode.
end

function BlockPooky.SaveHoTBarPosition()
    if BlockPooky.config and BlockPooky.hotBar then
        local left, top = BlockPooky.hotBar:GetLeft(), BlockPooky.hotBar:GetTop()
        BlockPooky.config.hotBarPosition = { left = left, top = top }
    end
end

function BlockPooky.LoadHoTBarPosition()
    if not BlockPooky.hotBar then
        return
    end

    if BlockPooky.hotBar:GetAnchor() ~= nil then
        BlockPooky.hotBar:ClearAnchors()
    end

    -- Load saved position if available, otherwise use default
    if BlockPooky.config and BlockPooky.config.hotBarPosition then
        BlockPooky.hotBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BlockPooky.config.hotBarPosition.left,
            BlockPooky.config.hotBarPosition.top)
    else
        -- Default position
        BlockPooky.hotBar:SetAnchor(CENTER, GuiRoot, CENTER, 0, -20)
    end
end

function BlockPooky.ResetHoTBarPosition()
    if BlockPooky.hotBar then
        if BlockPooky.hotBar:GetAnchor() ~= nil then
            BlockPooky.hotBar:ClearAnchors()
        end
        BlockPooky.hotBar:SetAnchor(CENTER, GuiRoot, CENTER, 0, -20)
        BlockPooky.SaveHoTBarPosition()
    end
end

--[[ display update ------------------------------------------------------------------------------------------------]]

---Update HoT bar display based on current count
function BlockPooky.UpdateHoTDisplay()
    if not BlockPooky.hotBar then
        return
    end

    -- While the UI is in repositioning mode (lockedUI = true), keep the bar
    -- visible regardless of HoT count or feature toggle so the player can move it.
    if BlockPooky.config and BlockPooky.config.lockedUI then
        BlockPooky.hotBar:SetHidden(false)
        -- Render a visible label so the bar is easy to find and move in repositioning mode
        if BlockPooky.hotLabel then
            BlockPooky.hotLabel:SetText("HoT")
        end
        return
    end

    if not BlockPooky.config or not BlockPooky.config.showHoTCounter then
        if BlockPooky.hotBar then BlockPooky.hotBar:SetHidden(true) end
        return
    end

    local total = BlockPooky.GetTotalHoTCount()

    if total == 0 then
        BlockPooky.hotBar:SetHidden(true)
        return
    end

    BlockPooky.hotBar:SetHidden(false)

    -- Determine color based on count
    local color
    if total >= 8 then
        color = { 1, 0, 0, 1 } -- Red: at cap
    elseif total >= 6 then
        color = { 1, 1, 0, 1 } -- Yellow: warning
    else
        color = { 0, 1, 0, 1 } -- Green: safe
    end

    -- Update label and status bar
    if not BlockPooky.hotLabel then return end
    if not BlockPooky.hotStatusBar then return end

    BlockPooky.hotLabel:SetColor(unpack(color))
    BlockPooky.hotLabel:SetText(total .. "/8")

    -- Dynamically set max to accommodate values above 8
    local maxValue = math.max(8, total)
    BlockPooky.hotStatusBar:SetMinMax(0, maxValue)
    BlockPooky.hotStatusBar:SetColor(unpack(color))
    BlockPooky.hotStatusBar:SetValue(total)
end

--[[ initialization hooks -------------------------------------------------------------------------------------------]]

---HoT initialization hook (called from BlockPooky.lua after UI init).
---HoTs are counted live from the game's buff list on the 1s main tick, so no
---dedicated event registration is needed; we only refresh the display once.
function BlockPooky.InitHoTTracker()
    BlockPooky.UpdateHoTDisplay()
end

---Update HoT tracking/display when the menu toggle changes.
function BlockPooky.HoTEventRegisterUpdate()
    BlockPooky.UpdateHoTDisplay()
end

--[[ debug/testing functions ---------------------------------------------------------------------------------------]]

---Debug helper (kept for compatibility with the documented /run command).
---With game-state counting there is no manual entry to add; prints the live count.
function BlockPooky.TestAddHoT()
    BlockPooky.PrintActiveHoTs()
end

---Print the currently active HoT buffs and their remaining time to chat.
function BlockPooky.PrintActiveHoTs()
    local total = BlockPooky.GetTotalHoTCount()
    d("=== Active HoTs (" .. total .. "/8) ===")

    local numBuffs = GetNumBuffs("player")
    local now = GetGameTimeSeconds()
    local found = false

    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename,
        deprecatedBuffType, effectType, abilityType, statusEffectType, abilityId,
        canClickOff, castByPlayer = GetUnitBuffInfo("player", i)

        if effectType == BUFF_EFFECT_TYPE_BUFF
            and abilityType == ABILITY_TYPE_HEAL
            and timeEnding > 0
            and timeEnding > now then
            found = true
            local remaining = math.floor((timeEnding - now) * 10) / 10
            d(string.format("  %s (%ds remaining, stacks=%d)", buffName, remaining, stackCount))
        end
    end

    if not found then
        d("No active HoTs")
    end
end
