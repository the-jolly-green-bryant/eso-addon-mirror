-- Dread Vision
-- PvP threat readout. A ring on your reticle that says what to press, plus the
-- two numbers you cannot work out mid-fight: how many roll dodges you can still
-- afford, and whether you can pay for a break free.
--
-- Everything shown is exact. Nothing is estimated, inferred or guessed. If the
-- API cannot tell us something, it is not on screen.
--
-- Nothing is hardcoded that the game can tell us at runtime. Roll dodge and
-- break free costs are learned by watching your own stamina, and crowd control
-- timers are read off the live buff. A patch cannot make this addon quietly
-- wrong.
--
-- Console-safe: gamepad fonts, CHAT_ROUTER output, every API guarded.

local ADDON_NAME = "DreadVision"
local SV_VERSION = 1

local TICK_MS       = 100     -- one clock for the whole addon
local CALLOUT_MS    = 1200    -- how long a callout stays up if nothing renews it
local MIN_SHOW_MS   = 400     -- nothing is replaced faster than it can be read
local RULE_COOL_MS  = 1500    -- same callout cannot immediately re-fire
local ARC_SEGMENTS  = 24

-- ------------------------------------------------------------- environment
local function Try(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b = pcall(fn, ...)
    if not ok then return nil end
    return a, b
end

local function DetectConsole()
    return (Try(ZO_IsConsoleOrGameCoreUI) or Try(IsGameCoreUI) or Try(IsConsoleUI)) and true or false
end

local IS_CONSOLE = DetectConsole()

local FONT_VERB = IS_CONSOLE and "ZoFontGamepadBold48" or "ZoFontWinH1"
local FONT_SUB  = IS_CONSOLE and "ZoFontGamepad22"     or "ZoFontGame"
local FONT_MID  = IS_CONSOLE and "ZoFontGamepad27"     or "ZoFontGameBold"

local function Msg(text)
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        pcall(function() CHAT_ROUTER:AddSystemMessage("|cFF4444[DV]|r " .. tostring(text)) end)
    elseif type(d) == "function" then
        pcall(d, "[DV] " .. tostring(text))
    end
end

local function Now()
    return Try(GetGameTimeMilliseconds) or 0
end

-- Every power the game has told us about, keyed by its power type. Filled by
-- EVENT_POWER_UPDATE, which is authoritative and costs nothing - the game
-- pushes these to us rather than us polling for them.
--
-- Polling GetUnitPower with a named constant was the first approach and it
-- read zero. If POWERTYPE_STAMINA does not resolve on this client the call
-- fails silently behind the pcall guard and there is no way to tell that from
-- genuinely having no stamina. Recording what the game actually sends removes
-- the guess entirely.
local powers = {}          -- [powerType] = { cur = n, max = n }

local function PowerOf(powerType)
    if powerType == nil then return nil end
    local p = powers[powerType]
    if p then return p.cur, p.max end
    -- not seen yet, so ask directly this once
    local cur, max = Try(GetUnitPower, "player", powerType)
    if type(cur) == "number" then return cur, max end
    return nil
end

-- Resolving a power type by asking the client, never by hardcoding a number.
--
-- The live client sends power types 4 and 32, which are neither the legacy
-- POWERTYPE_ values nor anything we should be guessing between. ZOS moved these
-- to COMBAT_MECHANIC_FLAGS_, which are bit flags. Rather than bake in a table
-- of magic numbers that a future update can invalidate, we read whichever
-- constant this client actually defines. Hardcoded numbers are the last resort,
-- not the first, and if none of it resolves we say so instead of inventing one.
local RESOURCE_GLOBALS = {
    stamina = { "COMBAT_MECHANIC_FLAGS_STAMINA", "POWERTYPE_STAMINA" },
    magicka = { "COMBAT_MECHANIC_FLAGS_MAGICKA", "POWERTYPE_MAGICKA" },
    health  = { "COMBAT_MECHANIC_FLAGS_HEALTH",  "POWERTYPE_HEALTH"  },
}

local resolved = {}
local function ResourceType(which)
    local hit = resolved[which]
    if hit ~= nil then return hit end
    for _, name in ipairs(RESOURCE_GLOBALS[which]) do
        local v = _G[name]
        if type(v) == "number" then
            resolved[which] = v
            return v
        end
    end
    return nil
end

-- Which numeric type each named constant resolved to, for the debug readout.
local function ResourceSource(which)
    for _, name in ipairs(RESOURCE_GLOBALS[which]) do
        if type(_G[name]) == "number" then return name, _G[name] end
    end
    return "unresolved", nil
end

-- Current stamina, or nil if we have not been told what it is. Never zero as a
-- stand-in for unknown - zero reads as "you are empty" and gets people killed.
local function Stamina()
    local t = ResourceType("stamina")
    if t == nil then return nil end
    return (PowerOf(t))
end

local function Magicka()
    local t = ResourceType("magicka")
    if t == nil then return nil end
    return (PowerOf(t))
end

-- ---------------------------------------------------------------- defaults
local defaults = {
    ui      = { x = 0, y = 0, hidden = false },
    showBudget = true,
    showCC     = true,
    -- Learned costs. Seeded with sane values and corrected the first time the
    -- player actually rolls or breaks free, so they are never stale.
    learned = { roll = 2721, breakFree = 4590 },
}

local sv
local win, verbLabel, subLabel, ccLabel, budgetLabel
local arcSegs = {}

-- ------------------------------------------------------------- self state
local S = {
    immunityUntil  = 0,
    stunUntil      = 0,
    rootUntil      = 0,
    offBalanceUntil = 0,
    dodgeCount     = 0,
    lastDodgeAt    = -100000,
    -- nil, not zero, until the game has told us. Zero reads as "you are empty".
    stamina        = nil,
    prevStamina    = nil,
    blocking       = false,
    inCombat       = false,
    inDuel         = false,
}

local FATIGUE_WINDOW_MS = 4000
local FATIGUE_MULT      = 1.33

-- Forward declarations. UpdateDisplay needs to ask whether we are active, and
-- that answer depends on duel state defined further down. Declaring the locals
-- here keeps them as upvalues rather than accidental globals.
local IsDuelling, Active

local function ResetState()
    S.immunityUntil  = 0
    S.stunUntil      = 0
    S.rootUntil      = 0
    S.offBalanceUntil = 0
    S.dodgeCount     = 0
    S.lastDodgeAt    = -100000
    S.blocking       = false
end

local function RollCost(extraDodges)
    local c = sv.learned.roll
    for _ = 1, (extraDodges or 0) do c = c * FATIGUE_MULT end
    return math.floor(c + 0.5)
end

-- How many more rolls the current stamina pays for, accounting for the fact
-- that each one costs more than the last while the fatigue window is open.
local function RollsAffordable()
    if S.stamina == nil then return nil end
    local remaining = S.stamina
    local fatigue   = S.dodgeCount
    local n = 0
    while n < 20 do
        local cost = RollCost(fatigue)
        if cost <= 0 or remaining < cost then break end
        remaining = remaining - cost
        fatigue = fatigue + 1
        n = n + 1
    end
    return n
end

local function CanBreakFree()
    if S.stamina == nil then return nil end
    return S.stamina >= sv.learned.breakFree
end

-- Crowd control is read live off the player's buffs rather than assumed, so a
-- balance change to immunity length cannot silently break the countdown.
local function ReadCrowdControl(now)
    local n = Try(GetNumBuffs, "player") or 0
    local immunityEnd = 0
    for i = 1, n do
        if type(GetUnitBuffInfo) == "function" then
            local ok, name, _, endTime = pcall(GetUnitBuffInfo, "player", i)
            if ok and type(name) == "string" then
                local lower = string.lower(name)
                if string.find(lower, "immun", 1, true)
                   or string.find(lower, "unstopp", 1, true) then
                    local ms = ((endTime or 0) * 1000)
                    if ms > immunityEnd then immunityEnd = ms end
                end
            end
        end
    end
    if immunityEnd > 0 then
        local gameSecs = Try(GetGameTimeSeconds) or 0
        local remaining = immunityEnd - (gameSecs * 1000)
        if remaining > 0 then S.immunityUntil = now + remaining end
    end
end

-- Ordered by how much trouble you are in, worst first. Off balance sits above
-- immunity because being immune to crowd control does not stop you being
-- opened up by a heavy attack while you are off balance.
local function CCState(now)
    if now < S.stunUntil       then return "STUNNED",     S.stunUntil - now end
    if now < S.rootUntil       then return "ROOTED",      S.rootUntil - now end
    if now < S.offBalanceUntil then return "OFFBALANCE",  S.offBalanceUntil - now end
    if now < S.immunityUntil   then return "IMMUNE",      S.immunityUntil - now end
    return "OPEN", 0
end

-- ------------------------------------------------------------------ arbiter
local A = { current = nil, shownAt = 0, lastFired = {} }

local ACTION_VERB = { ["BLOCK"] = "blocking" }

local candidates = {}
local candCount  = 0

local function Push(id, tier, verb, deadline)
    if candCount >= 6 then return end
    candCount = candCount + 1
    local c = candidates[candCount]
    if c == nil then c = {}; candidates[candCount] = c end
    c.id, c.tier, c.verb, c.deadline, c.at = id, tier, verb, deadline, Now()
end

local function Select(now)
    local best = nil
    for i = 1, candCount do
        local c = candidates[i]
        local suppressed = false

        local flag = ACTION_VERB[c.verb]
        if flag == "blocking" and S.blocking then suppressed = true end

        local last = A.lastFired[c.id]
        if last and (now - last) < RULE_COOL_MS then suppressed = true end

        if not suppressed then
            if best == nil or c.tier < best.tier
               or (c.tier == best.tier and c.deadline < best.deadline) then
                best = c
            end
        end
    end

    local cur = A.current
    if cur ~= nil then
        local expired = (now - A.shownAt) > CALLOUT_MS
        local held    = (now - A.shownAt) < MIN_SHOW_MS
        local preempt = best ~= nil and best.tier < cur.tier
        if expired and not preempt and best == nil then
            A.lastFired[cur.id] = now
            A.current = nil
            return nil
        end
        if held and not preempt then return cur end
    end

    if best == nil then return A.current end

    if cur == nil or cur.id ~= best.id then
        if cur ~= nil then A.lastFired[cur.id] = now end
        A.current = { id = best.id, tier = best.tier, verb = best.verb, deadline = best.deadline }
        A.shownAt = now
    end
    return A.current
end

-- ----------------------------------------------------------------- display
local lastVerb, lastSub, lastCC, lastBudget, lastArc

local function BuildUI()
    local wm = WINDOW_MANAGER
    if not wm then return end

    win = wm:CreateTopLevelWindow(ADDON_NAME .. "Window")
    win:SetDimensions(700, 700)
    win:ClearAnchors()
    win:SetAnchor(CENTER, GuiRoot, CENTER, sv.ui.x, sv.ui.y)
    win:SetMouseEnabled(false)
    win:SetMovable(false)
    win:SetHidden(true)

    -- ring segments, placed round a circle, shown by progress
    local radius = IS_CONSOLE and 170 or 150
    local size   = IS_CONSOLE and 11 or 9
    for i = 1, ARC_SEGMENTS do
        local angle = (i - 1) * (2 * math.pi / ARC_SEGMENTS) - (math.pi / 2)
        local t = wm:CreateControl(ADDON_NAME .. "Seg" .. i, win, CT_TEXTURE)
        t:SetTexture("EsoUI/Art/Miscellaneous/whiteCircle.dds")
        t:SetDimensions(size, size)
        t:SetAnchor(CENTER, win, CENTER,
                    math.cos(angle) * radius, math.sin(angle) * radius)
        t:SetHidden(true)
        arcSegs[i] = t
    end

    local function Label(key, font, offsetY, r, g, b)
        local c = wm:CreateControl(ADDON_NAME .. key, win, CT_LABEL)
        c:SetFont(font)
        c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        c:SetAnchor(CENTER, win, CENTER, 0, offsetY)
        c:SetColor(r, g, b, 1)
        c:SetText("")
        return c
    end

    local vOff = IS_CONSOLE and -215 or -190
    verbLabel   = Label("Verb",   FONT_VERB, vOff,        1.00, 0.24, 0.24)
    subLabel    = Label("Sub",    FONT_SUB,  vOff + 58,   1.00, 0.69, 0.13)
    ccLabel     = Label("CC",     FONT_SUB,  200,         0.25, 0.85, 0.78)
    budgetLabel = Label("Budget", FONT_MID,  232,         0.80, 0.84, 0.88)

    -- Ride the HUD scene so the ring hides with the rest of the interface
    -- instead of drawing over menus, the map and inventory.
    pcall(function()
        if ZO_HUDFadeSceneFragment then
            local fragment = ZO_HUDFadeSceneFragment:New(win)
            if HUD_SCENE    and HUD_SCENE.AddFragment    then HUD_SCENE:AddFragment(fragment)    end
            if HUD_UI_SCENE and HUD_UI_SCENE.AddFragment then HUD_UI_SCENE:AddFragment(fragment) end
        end
    end)
end

local function SetArc(progress)
    local count = 0
    if progress and progress > 0 then
        count = math.floor(progress * ARC_SEGMENTS + 0.5)
        if count > ARC_SEGMENTS then count = ARC_SEGMENTS end
    end
    if count == lastArc then return end
    lastArc = count
    for i = 1, ARC_SEGMENTS do
        arcSegs[i]:SetHidden(i > count)
    end
end

local function UpdateDisplay(now)
    if not win then return end

    -- The box stays on screen whenever the addon is enabled, in combat or not.
    -- Hiding it entirely out of combat makes working and broken look identical,
    -- which is the exact trap KillCount already learned the hard way. Out of
    -- combat it simply shows less.
    win:SetHidden(sv.ui.hidden)
    if sv.ui.hidden then return end

    local active = Active()

    if not active then
        -- Idle. No callouts, no crowd control, but the budget still means
        -- something and the header proves the addon is running.
        if lastVerb ~= "" then lastVerb = ""; verbLabel:SetText("") end
        if lastSub ~= "DREAD VISION" then
            lastSub = "DREAD VISION"
            subLabel:SetText("DREAD VISION")
            subLabel:SetColor(0.45, 0.50, 0.56, 1)
        end
        SetArc(0)
        if lastCC ~= "" then lastCC = ""; ccLabel:SetText("") end
        if sv.showBudget then
            local rolls = RollsAffordable()
            local canBreak = CanBreakFree()
            local text = string.format("ROLL DODGES %s    BREAK FREE %s",
                rolls and tostring(rolls) or "?",
                canBreak == nil and "?" or (canBreak and "READY" or "CANNOT AFFORD"))
            if text ~= lastBudget then
                lastBudget = text
                budgetLabel:SetText(text)
                budgetLabel:SetColor(0.45, 0.50, 0.56, 1)
            end
        end
        return
    end

    -- back in combat, so restore the live colours the idle state dimmed
    if lastSub == "DREAD VISION" then
        lastSub = nil
        subLabel:SetColor(1.00, 0.69, 0.13, 1)
        lastBudget = nil
    end

    local chosen = Select(now)

    local verb = chosen and chosen.verb or ""
    if verb ~= lastVerb then
        lastVerb = verb
        verbLabel:SetText(verb)
    end

    local sub = ""
    if chosen then
        local left = (chosen.deadline - (now - A.shownAt)) / 1000
        if left < 0 then left = 0 end
        sub = string.format("%.1fs", left)
    end
    if sub ~= lastSub then
        lastSub = sub
        subLabel:SetText(sub)
    end

    if chosen then
        local elapsed = now - A.shownAt
        local frac = 1 - (elapsed / chosen.deadline)
        SetArc(frac)
    else
        SetArc(0)
    end

    if sv.showCC then
        local state, remaining = CCState(now)
        local text
        if state == "OPEN" then
            text = "YOU CAN BE STUNNED NOW"
        elseif state == "IMMUNE" then
            text = string.format("CC IMMUNITY %.1fs", remaining / 1000)
        elseif state == "STUNNED" then
            text = string.format("YOU ARE STUNNED %.1fs", remaining / 1000)
        elseif state == "OFFBALANCE" then
            text = string.format("YOU ARE OFF BALANCE %.1fs", remaining / 1000)
        else
            text = string.format("YOU ARE IMMOBILISED %.1fs", remaining / 1000)
        end
        if text ~= lastCC then
            lastCC = text
            ccLabel:SetText(text)
            -- off balance is the one state where you are about to be hit for
            -- far more than usual, so it gets its own colour rather than
            -- sharing the calm cyan of an immunity countdown
            if state == "OFFBALANCE" then
                ccLabel:SetColor(1.00, 0.55, 0.15, 1)
            elseif state == "OPEN" then
                ccLabel:SetColor(1.00, 0.36, 0.36, 1)
            else
                ccLabel:SetColor(0.25, 0.85, 0.78, 1)
            end
        end
    elseif lastCC ~= "" then
        lastCC = ""
        ccLabel:SetText("")
    end

    if sv.showBudget then
        local rolls = RollsAffordable()
        local canBreak = CanBreakFree()
        local text = string.format("ROLL DODGES %s    BREAK FREE %s",
            rolls and tostring(rolls) or "?",
            canBreak == nil and "?" or (canBreak and "READY" or "CANNOT AFFORD"))
        if text ~= lastBudget then
            lastBudget = text
            budgetLabel:SetText(text)
            if rolls == 0 or canBreak == false then
                budgetLabel:SetColor(1.00, 0.36, 0.36, 1)
            else
                budgetLabel:SetColor(0.80, 0.84, 0.88, 1)
            end
        end
    elseif lastBudget ~= "" then
        lastBudget = ""
        budgetLabel:SetText("")
    end
end

-- ------------------------------------------------------------------ events
-- Learn the real cost of an action from the stamina it actually consumed.
-- Guards against counting regeneration or an unrelated spend as a cost.
local function LearnCost(kind, spent)
    if spent < 500 or spent > 20000 then return end
    local key = (kind == "roll") and "roll" or "breakFree"
    local prev = sv.learned[key]
    -- move a third of the way toward the observation, so one odd frame cannot
    -- throw the number but a genuine change is picked up within a few uses
    sv.learned[key] = math.floor(prev + ((spent - prev) * 0.34) + 0.5)
end

local function OnCombatEvent(_, result, isError, _, _, _,
                             _, _, targetName, targetType,
                             _, _, _, _, _, _, abilityId)
    if isError then return end
    if not Active() then return end

    local now = Now()

    -- Something with a cast time has begun against us.
    --
    -- The test is on the TARGET being us, never on what the source is. That is
    -- deliberate: a boss winding up a heavy attack and an enemy player casting
    -- a snipe are the same problem, and the same callout solves both. Do not
    -- add a source filter here to make it "PvP only" - it would break every
    -- telegraphed NPC attack in the game for no gain.
    if ACTION_RESULT_BEGIN and result == ACTION_RESULT_BEGIN
       and targetType == COMBAT_UNIT_TYPE_PLAYER then
        Push("cast" .. tostring(abilityId), 0, "BLOCK", 900)
        return
    end

    -- We dodged something: feeds roll fatigue and teaches the roll cost.
    if ACTION_RESULT_DODGED and result == ACTION_RESULT_DODGED
       and targetType == COMBAT_UNIT_TYPE_PLAYER then
        if (now - S.lastDodgeAt) > FATIGUE_WINDOW_MS then S.dodgeCount = 0 end
        S.dodgeCount  = S.dodgeCount + 1
        S.lastDodgeAt = now
        local spent = (S.prevStamina and S.stamina) and (S.prevStamina - S.stamina) or 0
        if spent > 0 then LearnCost("roll", spent) end
        return
    end
end

-- The game pushes every power change for the player here. Recording them all
-- means we never have to trust a constant name we cannot verify.
local function OnPowerUpdate(_, unitTag, _, powerType, powerValue, powerMax)
    if unitTag ~= "player" then return end
    if type(powerType) ~= "number" then return end
    local p = powers[powerType]
    if p == nil then p = {}; powers[powerType] = p end
    p.cur, p.max = powerValue, powerMax
end

local function OnEffectChanged(_, changeType, _, effectName, unitTag, _, endTime,
                               _, _, _, _, _, _, _, abilityId)
    if unitTag ~= "player" then return end
    if type(effectName) ~= "string" then return end

    local now = Now()
    local lower = string.lower(effectName)
    local faded = (EFFECT_RESULT_FADED and changeType == EFFECT_RESULT_FADED)

    local gameSecs = Try(GetGameTimeSeconds) or 0
    local remaining = ((endTime or 0) - gameSecs) * 1000
    if remaining < 0 then remaining = 0 end

    -- Off balance is checked before the immunity test on purpose: several of
    -- its effect names contain "immun" for the follow-up immunity period, and
    -- matching that first would file an off balance as crowd control immunity.
    if string.find(lower, "off balance", 1, true)
       or string.find(lower, "off-balance", 1, true)
       or string.find(lower, "offbalance", 1, true) then
        if faded then S.offBalanceUntil = 0 else S.offBalanceUntil = now + remaining end
    elseif string.find(lower, "immun", 1, true) or string.find(lower, "unstopp", 1, true) then
        if faded then S.immunityUntil = 0 else S.immunityUntil = now + remaining end
    elseif string.find(lower, "stun", 1, true) then
        if faded then S.stunUntil = 0 else S.stunUntil = now + remaining end
    elseif string.find(lower, "immobil", 1, true) or string.find(lower, "root", 1, true)
        or string.find(lower, "snare", 1, true) then
        if faded then S.rootUntil = 0 else S.rootUntil = now + remaining end
    end
end

-- EVENT_DUEL_STARTED is not guaranteed to have fired by the time the first
-- blow lands, so confirm against live duel state as well. Without this the
-- readout can miss the opening seconds of a duel, which is exactly when the
-- break free number matters.
function IsDuelling()
    if S.inDuel then return true end
    if type(GetDuelInfo) == "function" and DUEL_STATE_DUELING then
        local ok, state = pcall(GetDuelInfo)
        if ok and state == DUEL_STATE_DUELING then return true end
    end
    return false
end

function Active()
    return S.inCombat or IsDuelling()
end

local function OnDuelStarted()
    S.inDuel = true
    UpdateDisplay(Now())
end

local function OnDuelFinished()
    S.inDuel = false
    if not S.inCombat then
        ResetState()
        A.current, A.shownAt, A.lastFired = nil, 0, {}
        candCount = 0
        lastVerb, lastSub, lastCC, lastBudget, lastArc = nil, nil, nil, nil, nil
    end
    UpdateDisplay(Now())
end

local function OnCombatState(_, inCombat)
    S.inCombat = inCombat and true or false
    if not Active() then
        -- everything wipes when the fight ends
        ResetState()
        A.current, A.shownAt, A.lastFired = nil, 0, {}
        candCount = 0
        lastVerb, lastSub, lastCC, lastBudget, lastArc = nil, nil, nil, nil, nil
    end
    UpdateDisplay(Now())
end

local function OnTick()
    local now = Now()
    S.prevStamina = S.stamina
    S.stamina = Stamina()
    S.blocking = Try(IsBlockActive) and true or false

    if (now - S.lastDodgeAt) > FATIGUE_WINDOW_MS then S.dodgeCount = 0 end

    ReadCrowdControl(now)
    UpdateDisplay(now)
    candCount = 0
end

-- ---------------------------------------------------------------- commands
local function OnSlash(args)
    args = string.lower(tostring(args or ""))
    args = string.gsub(args, "^%s+", "")
    args = string.gsub(args, "%s+$", "")

    if args == "" then
        sv.ui.hidden = not sv.ui.hidden
        UpdateDisplay(Now())
        Msg(sv.ui.hidden and "hidden" or "shown")
    elseif args == "cc" then
        sv.showCC = not sv.showCC
        lastCC = nil
        Msg("crowd control readout " .. (sv.showCC and "on" or "off"))
    elseif args == "budget" then
        sv.showBudget = not sv.showBudget
        lastBudget = nil
        Msg("budget readout " .. (sv.showBudget and "on" or "off"))
    elseif args == "debug" then
        Msg("console=" .. tostring(IS_CONSOLE)
            .. "  active=" .. tostring(Active())
            .. "  inCombat=" .. tostring(S.inCombat)
            .. "  inDuel=" .. tostring(S.inDuel))
        for _, which in ipairs({ "stamina", "magicka", "health" }) do
            local name, value = ResourceSource(which)
            Msg(which .. " -> " .. name .. " = " .. tostring(value))
        end
        Msg("S.stamina=" .. tostring(S.stamina)
            .. "  rolls=" .. tostring(RollsAffordable())
            .. "  canBreak=" .. tostring(CanBreakFree()))
        local seen = 0
        for ptype, p in pairs(powers) do
            seen = seen + 1
            local label = ""
            for _, which in ipairs({ "stamina", "magicka", "health" }) do
                if ResourceType(which) == ptype then label = "  <- " .. which end
            end
            Msg("  power type " .. tostring(ptype)
                .. ": cur=" .. tostring(p.cur)
                .. " max=" .. tostring(p.max) .. label)
        end
        if seen == 0 then
            Msg("  no EVENT_POWER_UPDATE received yet - take or deal damage and retry")
        end
        Msg("magicka = " .. tostring(Magicka()))
    elseif args == "costs" then
        Msg(string.format("learned costs - roll %d, break free %d",
            sv.learned.roll, sv.learned.breakFree))
    elseif args == "up" then
        sv.ui.y = sv.ui.y - 20
        win:ClearAnchors()
        win:SetAnchor(CENTER, GuiRoot, CENTER, sv.ui.x, sv.ui.y)
        Msg("offset " .. sv.ui.y)
    elseif args == "down" then
        sv.ui.y = sv.ui.y + 20
        win:ClearAnchors()
        win:SetAnchor(CENTER, GuiRoot, CENTER, sv.ui.x, sv.ui.y)
        Msg("offset " .. sv.ui.y)
    else
        Msg("/dv         show or hide")
        Msg("/dv up      move the ring up 20 (third person)")
        Msg("/dv down    move the ring down 20")
        Msg("/dv cc      toggle the crowd control line")
        Msg("/dv budget  toggle the roll and break free line")
        Msg("/dv costs   show the learned action costs")
        Msg("/dv debug   dump power values and state")
    end
end

-- ------------------------------------------------------------------- setup
local function Initialize()
    sv = ZO_SavedVars:NewCharacterIdSettings("DreadVisionVars", SV_VERSION, nil, defaults)
    sv.ui      = sv.ui or { x = 0, y = 0, hidden = false }
    sv.learned = sv.learned or { roll = 2721, breakFree = 4590 }

    BuildUI()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_CE", EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "_CE", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_IS_ERROR, false)

    -- Deliberately unfiltered. A filter whose constant does not resolve
    -- registers wrong and silently drops every event, and behind a pcall there
    -- is no way to tell that from the player simply having no stamina.
    -- OnPowerUpdate checks the unit tag itself, which costs a comparison.
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_PW", EVENT_POWER_UPDATE, OnPowerUpdate)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_EF", EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "_EF", EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "player")

    if EVENT_PLAYER_COMBAT_STATE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_CS", EVENT_PLAYER_COMBAT_STATE, OnCombatState)
    end
    if EVENT_DUEL_STARTED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_DS", EVENT_DUEL_STARTED, OnDuelStarted)
    end
    if EVENT_DUEL_FINISHED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_DF", EVENT_DUEL_FINISHED, OnDuelFinished)
    end

    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_TICK", TICK_MS, OnTick)

    if SLASH_COMMANDS then
        SLASH_COMMANDS["/dv"] = OnSlash
        SLASH_COMMANDS["/dreadvision"] = OnSlash
    end

    S.stamina = Stamina()
    S.prevStamina = S.stamina
    Msg("loaded. /dv for options")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, name)
    if name ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    Initialize()
end)
