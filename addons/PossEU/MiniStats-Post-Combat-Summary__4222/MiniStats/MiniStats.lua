MiniStats = MiniStats or {}
local MS = MiniStats

MS.name = "MiniStats"
MS.inCombat = false
MS.startTime = 0
MS.totals = { damage = 0, healing = 0, maxHit = 0 }
MS.playerName = nil

-- ========= UI =========
function MS:CreateUI()
    self.window = WINDOW_MANAGER:CreateTopLevelWindow("MiniStatsOverlay")
    self.window:SetDimensions(480, 90)
    self.window:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -50, 50)
    self.window:SetMovable(true)
    self.window:SetMouseEnabled(true)
    self.window:SetHidden(true)

    local bg = WINDOW_MANAGER:CreateControl(nil, self.window, CT_BACKDROP)
    bg:SetAnchorFill(self.window)
    bg:SetCenterColor(0,0,0,0.55)
    bg:SetEdgeColor(1,1,1,0.35)
    bg:SetEdgeTexture(nil, 1, 1, 1.0)

    self.label = WINDOW_MANAGER:CreateControl(nil, self.window, CT_LABEL)
    self.label:SetAnchor(CENTER, self.window, CENTER, 0, 0)
    self.label:SetFont("ZoFontGameLarge")
    self.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.label:SetText("")
end

local function K(n)
    if not n then return "0" end
    if n >= 1000000 then return string.format("%.1fm", n/1000000)
    elseif n >= 1000 then return string.format("%.1fk", n/1000)
    else return tostring(math.floor(n+0.5)) end
end

-- ========= EVENT FLOW =========
function MS.OnAddOnLoaded(_, addonName)
    if addonName ~= MS.name then return end
    EVENT_MANAGER:UnregisterForEvent(MS.name, EVENT_ADD_ON_LOADED)

    MS.playerName = zo_strformat("<<1>>", GetUnitName("player"))
    MS:CreateUI()

    EVENT_MANAGER:RegisterForEvent(MS.name, EVENT_PLAYER_COMBAT_STATE, MS.OnCombatState)
    EVENT_MANAGER:RegisterForEvent(MS.name, EVENT_COMBAT_EVENT, MS.OnCombatEvent)
end

function MS.OnCombatState(_, inCombat)
    if inCombat and not MS.inCombat then
        MS.inCombat = true
        MS.startTime = GetFrameTimeSeconds()
        MS.totals.damage = 0
        MS.totals.healing = 0
        MS.totals.maxHit = 0
        return
    end

    if (not inCombat) and MS.inCombat then
        MS.inCombat = false
        local duration = math.max(0, GetFrameTimeSeconds() - MS.startTime)
        if duration >= 2 then
            MS:ShowSummary(duration)
        end
    end
end

-- Very lightweight filter: only count events when YOU are the source.
function MS.OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                          sourceName, sourceType, targetName, targetType, hitValue, powerType,
                          damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if not MS.inCombat or isError then return end
    sourceName = zo_strformat("<<1>>", sourceName or "")
    if sourceName ~= MS.playerName then return end

    if hitValue and hitValue > 0 then
        -- Damage buckets
        if result == ACTION_RESULT_DAMAGE
        or result == ACTION_RESULT_CRITICAL_DAMAGE
        or result == ACTION_RESULT_DOT_TICK
        or result == ACTION_RESULT_DOT_TICK_CRITICAL
        or result == ACTION_RESULT_BLOCKED_DAMAGE then
            MS.totals.damage = MS.totals.damage + hitValue
            if hitValue > MS.totals.maxHit then MS.totals.maxHit = hitValue end
        end

        -- Healing buckets (heals you did)
        if result == ACTION_RESULT_HEAL
        or result == ACTION_RESULT_CRITICAL_HEAL
        or result == ACTION_RESULT_HOT_TICK then
            MS.totals.healing = MS.totals.healing + hitValue
        end
    end
end

function MS:ShowSummary(duration)
    local dps = (duration > 0) and (self.totals.damage / duration) or 0
    local text = string.format(
        "Fight: %ds  •  DPS %s  •  Max Hit %s  •  Healing %s",
        math.floor(duration + 0.5),
        K(dps), K(self.totals.maxHit), K(self.totals.healing)
    )
    self.label:SetText(text)
    self.window:SetHidden(false)
    zo_callLater(function() self.window:SetHidden(true) end, 8000)
end

-- simple slash command for testing
SLASH_COMMANDS["/ministats"] = function(arg)
    if arg == "test" then
        MS.totals.damage, MS.totals.maxHit, MS.totals.healing = 123456, 45678, 23456
        MS:ShowSummary(65)
    else
        d("MiniStats: /ministats test")
    end
end

EVENT_MANAGER:RegisterForEvent(MiniStats.name, EVENT_ADD_ON_LOADED, MiniStats.OnAddOnLoaded)