--[[
    BlockPooky Active CC Bar Module

    This module tracks crowd control effects currently affecting the player and shows the
    highest-priority active CC on a dedicated bar (separate from the CC immunity bar):

        Stun -> Fear -> Disorient -> Silence -> Stagger

    When a higher-priority CC expires, the bar immediately switches to the next active one.
    Each CC type has its own text and color (configurable in the menu).

    Detection (based on the CrowdControlTracker approach):
    - Stun/Fear/Disorient: EVENT_COMBAT_EVENT landing results; duration from hitValue
    - Stagger: ACTION_RESULT_STAGGERED (short fixed duration)
    - Silence: Negate Magic debuff (EFFECT_GAINED_DURATION on the Negate ability)
    - Stun early-end: EVENT_PLAYER_STUNNED_STATE_CHANGED (break free clears it instantly)
--]]

--[[ basic initialization -------------------------------------------------------------------------------------------]]
BlockPooky = BlockPooky or {}
local BlockPooky = BlockPooky

-- Priority order shown on the bar (highest first)
BlockPooky.ccDebuffOrder = { "stun", "fear", "disorient", "silence", "stagger" }

-- Per-CC-type display info (text + default color). Colors are customizable in the menu.
BlockPooky.ccDebuffInfo = {
    stun      = { text = "STUNNED", color = { 0.894, 0.133, 0.090, 1 } },   -- red
    fear      = { text = "FEARED", color = { 0.561, 0.035, 0.925, 1 } },    -- purple
    disorient = { text = "DISORIENTED", color = { 0.031, 0.627, 1.0, 1 } }, -- blue
    silence   = { text = "SILENCED", color = { 0.0, 1.0, 1.0, 1 } },        -- cyan
    stagger   = { text = "STAGGER", color = { 1.0, 0.949, 0.129, 1 } },     -- yellow
}

-- Negate Magic ability IDs -> silence while standing in the field
BlockPooky.ccDebuffNegateIds = {
    [47158] = true, -- Negate Magic
    [51894] = true, -- Negate Magic (morph)
}

-- Fallback durations (seconds) used when a combat event carries no usable duration
BlockPooky.ccDebuffDefaults = {
    stun      = 4.0,
    fear      = 4.0,
    disorient = 4.0,
    silence   = 5.0,
    stagger   = 0.8,
}

-- Per-CC-type state (end/begin time in game seconds)
local ccDebuffEndTimes = {}
local ccDebuffBeginTimes = {}
local ccDebuffUpdateRegistered = false
local ccDebuffActiveType = nil

--[[ ui -------------------------------------------------------------------------------------------------------------]]

---Set the status bar color for a given CC type (uses the menu-configured color, else default)
---@param typeKey string
function BlockPooky.SetCCDebuffBarColor(typeKey)
    local color = (BlockPooky.config.ccDebuffColors and BlockPooky.config.ccDebuffColors[typeKey])
        or BlockPooky.ccDebuffInfo[typeKey].color
    BlockPooky.ccDebuffStatusBar:SetColor(unpack(color))
end

---init the active CC bar UI
function BlockPooky.initCCDebuffUI()
    if not BlockPooky.ccDebuffBar then
        BlockPooky.ccDebuffBar = CreateControl(BlockPooky.name .. "CCDebuffBar", GuiRoot, CT_TOPLEVELCONTROL)
        BlockPooky.ccDebuffBar:SetDimensions(200, 40)
        BlockPooky.ccDebuffBar:SetAnchor(CENTER, GuiRoot, CENTER, 0, -165)
        BlockPooky.ccDebuffBar:SetHidden(true)
        BlockPooky.ccDebuffBar:SetMovable(true)      -- Verschiebbar machen
        BlockPooky.ccDebuffBar:SetMouseEnabled(true) -- Mausinteraktionen erlauben

        -- Event für das Loslassen nach dem Bewegen
        BlockPooky.ccDebuffBar:SetHandler("OnMoveStop", function()
            BlockPooky.SaveCCDebuffPosition()
        end)
    end

    if not BlockPooky.ccDebuffLabel then
        BlockPooky.ccDebuffLabel = CreateControl(BlockPooky.name .. "CCDebuffLabel", BlockPooky.ccDebuffBar, CT_LABEL)
        BlockPooky.ccDebuffLabel:SetFont("ZoFontWinH4")
        BlockPooky.ccDebuffLabel:SetColor(1, 1, 1, 1)
        BlockPooky.ccDebuffLabel:SetText("")
        BlockPooky.ccDebuffLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        BlockPooky.ccDebuffLabel:SetAnchor(TOP, BlockPooky.ccDebuffBar, TOP, 0, 0)
    end

    if not BlockPooky.ccDebuffStatusBar then
        BlockPooky.ccDebuffStatusBar = CreateControl(BlockPooky.name .. "CCDebuffStatus", BlockPooky.ccDebuffBar,
            CT_STATUSBAR)
        BlockPooky.ccDebuffStatusBar:SetDimensions(200, 20)
        BlockPooky.ccDebuffStatusBar:SetAnchor(BOTTOM, BlockPooky.ccDebuffBar, BOTTOM, 0, 0)
        BlockPooky.ccDebuffStatusBar:SetMinMax(0, 1)
        BlockPooky.SetCCDebuffBarColor("stun")
    end

    BlockPooky.LoadCCDebuffPosition()
end

function BlockPooky.SaveCCDebuffPosition()
    if not BlockPooky.ccDebuffBar then return end
    local left, top = BlockPooky.ccDebuffBar:GetLeft(), BlockPooky.ccDebuffBar:GetTop()
    BlockPooky.config.ccDebuffPosition = { left = left, top = top }
end

function BlockPooky.LoadCCDebuffPosition()
    if not BlockPooky.ccDebuffBar then return end
    if BlockPooky.config and BlockPooky.config.ccDebuffPosition then
        if BlockPooky.ccDebuffBar:GetAnchor() ~= nil then
            BlockPooky.ccDebuffBar:ClearAnchors()
        end
        BlockPooky.ccDebuffBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BlockPooky.config.ccDebuffPosition.left,
            BlockPooky.config.ccDebuffPosition.top)
    else
        BlockPooky.ResetCCDebuffPosition()
    end
end

function BlockPooky.ResetCCDebuffPosition()
    if not BlockPooky.ccDebuffBar then return end
    if BlockPooky.ccDebuffBar:GetAnchor() ~= nil then
        BlockPooky.ccDebuffBar:ClearAnchors()
    end
    BlockPooky.ccDebuffBar:SetAnchor(CENTER, GuiRoot, CENTER, 0, -165)
    BlockPooky.SaveCCDebuffPosition()
end

function BlockPooky.RestoreCCDebuffPosition()
    BlockPooky.LoadCCDebuffPosition()
end

--[[ core logic -----------------------------------------------------------------------------------------------------]]

---Extract a duration in seconds from a combat event hitValue (ms).
---Falls back to `fallback` seconds when the value is missing or implausible.
---@param hitValue number combat event hitValue (duration in ms for CC effects)
---@param fallback number seconds
---@return number duration in seconds
function BlockPooky.CCDebuffDuration(hitValue, fallback)
    if hitValue and hitValue > 0 then
        local seconds = hitValue / 1000
        if seconds >= 0.1 and seconds <= 60 then
            return seconds
        end
    end
    return fallback
end

---Register (or extend) an active CC of the given type.
---@param typeKey string "stun"|"fear"|"disorient"|"silence"|"stagger"
---@param endTime number end time in game seconds
function BlockPooky.SetCCDebuff(typeKey, endTime)
    if endTime <= GetGameTimeSeconds() then return end
    if not ccDebuffEndTimes[typeKey] or endTime > ccDebuffEndTimes[typeKey] then
        ccDebuffEndTimes[typeKey] = endTime
        ccDebuffBeginTimes[typeKey] = GetGameTimeSeconds()
    end
    BlockPooky.StartCCDebuffUpdate()
end

---Clear an active CC of the given type (e.g. break free ended a stun early).
function BlockPooky.ClearCCDebuff(typeKey)
    if ccDebuffEndTimes[typeKey] then
        ccDebuffEndTimes[typeKey] = nil
        ccDebuffBeginTimes[typeKey] = nil
        BlockPooky.UpdateCCDebuff() -- refresh so the bar switches to the next CC immediately
    end
end

---Clear all active CCs and hide the bar (used when the feature is disabled).
function BlockPooky.HideCCDebuffBar()
    for _, typeKey in ipairs(BlockPooky.ccDebuffOrder) do
        ccDebuffEndTimes[typeKey] = nil
        ccDebuffBeginTimes[typeKey] = nil
    end
    BlockPooky.UpdateCCDebuff()
end

---Ensure the update loop is running and refresh immediately
function BlockPooky.StartCCDebuffUpdate()
    if not ccDebuffUpdateRegistered then
        ccDebuffUpdateRegistered = true
        EVENT_MANAGER:RegisterForUpdate(BlockPooky.name .. "UpdateCCDebuff", 50, BlockPooky.UpdateCCDebuff, false)
    end
    BlockPooky.UpdateCCDebuff()
end

---Current CC type shown on the bar (nil when hidden) - used by the menu to recolor live.
---@return string|nil
function BlockPooky.GetActiveCCDebuffType()
    return ccDebuffActiveType
end

---Per-frame update: shows the highest-priority active CC, switches/hides as they expire.
function BlockPooky.UpdateCCDebuff()
    local now = GetGameTimeSeconds()
    local activeType = nil

    -- Find the highest-priority CC that is still active (and clean up expired ones)
    for _, typeKey in ipairs(BlockPooky.ccDebuffOrder) do
        if ccDebuffEndTimes[typeKey] and ccDebuffEndTimes[typeKey] > now then
            activeType = typeKey
            break
        elseif ccDebuffEndTimes[typeKey] then
            ccDebuffEndTimes[typeKey] = nil
            ccDebuffBeginTimes[typeKey] = nil
        end
    end

    if not activeType then
        BlockPooky.ccDebuffBar:SetHidden(not BlockPooky.config.lockedUI)
        ccDebuffActiveType = nil
        if ccDebuffUpdateRegistered then
            ccDebuffUpdateRegistered = false
            EVENT_MANAGER:UnregisterForUpdate(BlockPooky.name .. "UpdateCCDebuff")
        end
        return
    end

    local remaining = ccDebuffEndTimes[activeType] - now
    local barMax = math.max(ccDebuffEndTimes[activeType] - ccDebuffBeginTimes[activeType], 0.001)

    BlockPooky.ccDebuffStatusBar:SetMinMax(0, barMax)
    BlockPooky.ccDebuffStatusBar:SetValue(math.min(remaining, barMax))
    BlockPooky.ccDebuffLabel:SetText(BlockPooky.ccDebuffInfo[activeType].text)
    BlockPooky.SetCCDebuffBarColor(activeType)
    BlockPooky.ccDebuffBar:SetHidden(false)
    ccDebuffActiveType = activeType
end

--[[ event handling -------------------------------------------------------------------------------------------------]]

-- Combat results we care about (fast Lua gate - the event is registered unfiltered like
-- CrowdControlTracker does, because C-level result filters were found to silently drop CC events).
local ccDebuffValidResults = {
    [ACTION_RESULT_STUNNED] = true,
    [ACTION_RESULT_FEARED] = true,
    [ACTION_RESULT_DISORIENTED] = true,
    [ACTION_RESULT_STAGGERED] = true,
    [ACTION_RESULT_EFFECT_GAINED_DURATION] = true,
}

-- Tracks the ability ID that stunned/feared/disoriented us, so the real duration from the
-- following EFFECT_GAINED_DURATION event can be applied (same pairing as CrowdControlTracker).
local ccDebuffIncoming = {}

-- Debug: print raw CC combat events to chat (toggle with /blockpookyccdebug)
local ccDebuffDebug = false

-- Last CSA timestamp PER CC TYPE (for the anti-spam cooldown). Per-type so a fear
-- right after a stun is not swallowed by the stun's cooldown.
local ccDebuffLastCSATimes = {}

---Player's raw name as used in combat events (cached; may include ^Mx/^Fx markers).
---@return string
function BlockPooky.GetRawPlayerName()
    if not BlockPooky.rawPlayerName then
        BlockPooky.rawPlayerName = GetRawUnitName("player") or GetUnitName("player") or ""
    end
    return BlockPooky.rawPlayerName
end

---Combat-event tolerant check whether a name belongs to the player.
---ESO can append ^Mx / ^Fx markers to renamed character names in combat events, so a
---plain equality check against GetUnitName("player") would silently drop the events.
---@param name string
---@return boolean
function BlockPooky.IsPlayerName(name)
    if not name or name == "" then return false end
    local myName = BlockPooky.GetRawPlayerName()
    if name == myName then return true end
    if name == (myName .. "^Mx") or name == (myName .. "^Fx") then return true end
    return false
end

---Show a center screen CC alert, throttled PER CC TYPE by ccDebuffCSACooldown to avoid
---spam during chain CCs. Does nothing if the CSA toggle is off.
---@param typeKey string
---@param message string
function BlockPooky.ShowCCDebuffCSA(typeKey, message)
    if not BlockPooky.config.ccDebuffCSA then return end
    local cooldown = BlockPooky.config.ccDebuffCSACooldown or 2000
    local now = GetGameTimeMilliseconds()
    local last = ccDebuffLastCSATimes[typeKey] or 0
    if now - last >= cooldown then
        ccDebuffLastCSATimes[typeKey] = now
        BlockPooky.MessageThePooky(message)
    end
end

---EVENT_COMBAT_EVENT handler for CC debuffs affecting the player.
function BlockPooky.OnCCDebuffCombat(
    eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
    sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType,
    combatLog, sourceUnitId, targetUnitId, abilityId)
    -- Debug: log every CC-relevant combat event BEFORE any filtering so we can verify what
    -- the game actually sends (turn on with /blockpookyccdebug, then get stunned/feared).
    if ccDebuffDebug and ccDebuffValidResults[result] then
        d(string.format("[CCBar] result=%d ability=%s(%d) src=%s tgt=%s tType=%d hit=%d",
            result, tostring(abilityName), abilityId or 0, tostring(sourceName),
            tostring(targetName), targetType or 0, hitValue or 0))
    end

    if not ccDebuffValidResults[result] then return end
    if targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end
    if not BlockPooky.IsPlayerName(targetName) then return end

    local now = GetGameTimeSeconds()
    local dur = BlockPooky.CCDebuffDuration

    if result == ACTION_RESULT_STUNNED then
        ccDebuffIncoming[ACTION_RESULT_STUNNED] = abilityId
        BlockPooky.SetCCDebuff("stun", now + dur(hitValue, BlockPooky.ccDebuffDefaults.stun))
        BlockPooky.ShowCCDebuffCSA("stun", BlockPooky.config.messages.ccStun)
    elseif result == ACTION_RESULT_FEARED then
        ccDebuffIncoming[ACTION_RESULT_FEARED] = abilityId
        BlockPooky.SetCCDebuff("fear", now + dur(hitValue, BlockPooky.ccDebuffDefaults.fear))
        BlockPooky.ShowCCDebuffCSA("fear", BlockPooky.config.messages.ccFear)
    elseif result == ACTION_RESULT_DISORIENTED then
        ccDebuffIncoming[ACTION_RESULT_DISORIENTED] = abilityId
        BlockPooky.SetCCDebuff("disorient", now + dur(hitValue, BlockPooky.ccDebuffDefaults.disorient))
        BlockPooky.ShowCCDebuffCSA("disorient", BlockPooky.config.messages.ccDisorient)
    elseif result == ACTION_RESULT_STAGGERED then
        BlockPooky.SetCCDebuff("stagger", now + dur(hitValue, BlockPooky.ccDebuffDefaults.stagger))
    elseif result == ACTION_RESULT_EFFECT_GAINED_DURATION then
        -- Apply the real duration for a stun/fear/disorient we already registered (the
        -- landing result alone often carries no duration - same pairing as CCT).
        if ccDebuffIncoming[ACTION_RESULT_STUNNED] == abilityId then
            ccDebuffIncoming[ACTION_RESULT_STUNNED] = nil
            BlockPooky.SetCCDebuff("stun", now + dur(hitValue, BlockPooky.ccDebuffDefaults.stun))
        elseif ccDebuffIncoming[ACTION_RESULT_FEARED] == abilityId then
            ccDebuffIncoming[ACTION_RESULT_FEARED] = nil
            BlockPooky.SetCCDebuff("fear", now + dur(hitValue, BlockPooky.ccDebuffDefaults.fear))
        elseif ccDebuffIncoming[ACTION_RESULT_DISORIENTED] == abilityId then
            ccDebuffIncoming[ACTION_RESULT_DISORIENTED] = nil
            BlockPooky.SetCCDebuff("disorient", now + dur(hitValue, BlockPooky.ccDebuffDefaults.disorient))
        elseif BlockPooky.ccDebuffNegateIds[abilityId] then
            -- Silence: standing in an enemy Negate Magic field
            BlockPooky.SetCCDebuff("silence", now + dur(hitValue, BlockPooky.ccDebuffDefaults.silence))
        end
    end
end

---EVENT_PLAYER_STUNNED_STATE_CHANGED handler.
---Sets the stun on the bar when a stun/knockdown begins (fallback in case the combat
---event is missed), and clears it the moment it ends (break free) so the bar switches
---to the next active CC immediately.
function BlockPooky.OnCCDebuffStunState(eventCode, playerStunned)
    if playerStunned then
        BlockPooky.SetCCDebuff("stun", GetGameTimeSeconds() + BlockPooky.ccDebuffDefaults.stun)
    else
        BlockPooky.ClearCCDebuff("stun")
    end
end

---EVENT_UNIT_DEATH_STATE_CHANGED handler - resets the bar when the player dies.
function BlockPooky.OnCCDebuffDeath(eventCode, unitTag, isDead)
    if isDead then
        BlockPooky.HideCCDebuffBar()
    end
end

---Registers or unregisters the active CC bar events based on configuration.
function BlockPooky.CCDebuffEventRegisterUpdate()
    if BlockPooky.config.showCCDebuff then
        -- Registered WITHOUT result/target filters (like CrowdControlTracker): C-level
        -- result filters were found to silently drop CC events, and the player-target
        -- filter is applied in the handler via IsPlayerName. The handler gates results
        -- with the cheap ccDebuffValidResults lookup.
        EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "CCDebuff", EVENT_COMBAT_EVENT,
            function(...) BlockPooky.OnCCDebuffCombat(...) end)
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "CCDebuff", EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR,
            false)

        EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "CCDebuffStunState", EVENT_PLAYER_STUNNED_STATE_CHANGED,
            function(...) BlockPooky.OnCCDebuffStunState(...) end)

        EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "CCDebuffDeath", EVENT_UNIT_DEATH_STATE_CHANGED,
            function(...) BlockPooky.OnCCDebuffDeath(...) end)
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "CCDebuffDeath", EVENT_UNIT_DEATH_STATE_CHANGED,
            REGISTER_FILTER_UNIT_TAG, "player")
    else
        EVENT_MANAGER:UnregisterForEvent(BlockPooky.name .. "CCDebuff")
        EVENT_MANAGER:UnregisterForEvent(BlockPooky.name .. "CCDebuffStunState")
        EVENT_MANAGER:UnregisterForEvent(BlockPooky.name .. "CCDebuffDeath")
    end
end

---Manual trigger for testing the active CC bar.
---Use via /blockpookytestcc to show a test STUN bar for 4 seconds.
function BlockPooky.TestCCDebuff()
    BlockPooky.SetCCDebuff("stun", GetGameTimeSeconds() + 4.0)
end

---Toggle debug logging of CC combat events to chat (via /blockpookyccdebug).
---Get stunned/feared while it's ON and watch the chat for [CCBar] lines - this shows
---exactly which events arrive, the target name/type and the reported duration.
function BlockPooky.ToggleCCDebuffDebug()
    ccDebuffDebug = not ccDebuffDebug
    d("BlockPooky Active CC Bar debug: " .. (ccDebuffDebug and "ON - get stunned/feared and watch chat" or "OFF"))
end
