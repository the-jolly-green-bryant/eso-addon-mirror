EWPFinder = {}
EWPFinder.name = "EWPFinder"
EWPFinder.isLoaded = false
EWPFinder.version = "1.0"
EWPFinder.defaults_db = {
    location = {
        x = 500,
        y = 520
    },
    locationbuff = {
        x = 500,
        y = 580
    },
    locationup = {
        x = 530,
        y = 626
    },
    settings = {
        global = false,
        customScale = 1.0,
        color = {1, 1, 1, 1},
        uptime = true,
        hexcolor = "E58A2B",
        uptimecolor = "F2BA6A",
        inactivecolor = "C63422",
        enablebuff = true,
        enableUp = true,
    },
}
-- Rolling window length for uptime (ms)
EWPFinder.UPTIME_WINDOW_MS = 120000 -- 60s rolling window
 -- 60s, change to 30000 / 120000 etc.
EWPFinder.ROLL_SECONDS = 60
EWPFinder.BAR_ANIM_TICK_MS = 60
EWPFinder.BAR_ANIM_LERP = 0.32

EWPFinder.roll = {
    idx = 0,
    filled = 0,
    sums = {},     -- per buffName: active sample count
    samples = {},  -- per buffName: { [1..ROLL_SECONDS] = 0/1 }
}

EWPFinder.uptime = {
    windowStartMs = 120000,
    overallStartMs = GetGameTimeMilliseconds(),
    buffs = {
        ["Major Brutality"] = { isActive=false, lastChangeMs=0, activeMs=0 },
        ["Major Sorcery"]   = { isActive=false, lastChangeMs=0, activeMs=0 }
    }
}

local function GetNowMs()
    return GetGameTimeMilliseconds()
end

local function HexToRGBA(hex, alpha)
    local clean = tostring(hex or "FFFFFF"):gsub("#", ""):upper()
    if clean:len() ~= 6 then
        clean = "FFFFFF"
    end

    local r = tonumber(clean:sub(1, 2), 16) or 255
    local g = tonumber(clean:sub(3, 4), 16) or 255
    local b = tonumber(clean:sub(5, 6), 16) or 255
    return r / 255, g / 255, b / 255, alpha or 1
end

local function GetOrCreateBuffUptime(tbl, buffName, nowMs)
    local b = tbl.buffs[buffName]
    if not b then
        b = { isActive = false, lastChangeMs = nowMs, activeMs = 0 }
        tbl.buffs[buffName] = b
    end
    return b
end
function EWPFinder:ManageUptime(nowMs)
    local up = self.uptime
    if up.windowStartMs == 0 then
        up.windowStartMs = nowMs
        return
    end

    -- If we've exceeded the window, shift the window forward.
    -- Simple (and stable) approach: reset counters on window roll.
    -- (You can make this a true sliding window later; this works great for buff upkeep.)
    local elapsed = nowMs - up.windowStartMs
    if elapsed >= self.UPTIME_WINDOW_MS then
        up.windowStartMs = nowMs
        for _, b in pairs(up.buffs) do
            b.activeMs = 0
            b.lastChangeMs = nowMs
            -- keep isActive as-is (buff might still be active at window boundary)
        end
    end
end

function EWPFinder:GetBuffUptimePercent(buffName, nowMs)
    local up = self.uptime
    local b = GetOrCreateBuffUptime(up, buffName, nowMs)

    local windowElapsed = math.max(1, nowMs - up.windowStartMs)
    local activeMs = b.activeMs

    -- If currently active, include time since last change
    if b.isActive then
        activeMs = activeMs + math.max(0, nowMs - b.lastChangeMs)
    end

    -- Clamp to window size so it never goes > 100%
    activeMs = math.min(activeMs, windowElapsed)

    local pct = (activeMs / windowElapsed) * 100
    return pct, (100 - pct)
end

EWPFinder.UI = {}
function EWPFinder:DisplayBuff(buffName, buffOn)
    local buffs = {
        61665, -- Major Brutality
        61687, -- Major Sorcery
    }
    if buffName == "Major Brutality" and buffOn == "removed" then
        local inactivecolor = self.db.settings.inactivecolor
        return string.format("|c%Buff Inactive|r", inactivecolor)
    elseif buffName == "Major Brutality" and buffOn == "added" then
        local hexcolor =  self.db.settings.hexcolor
        return string.format("|c%sBuff Active|r", hexcolor)
    elseif buffName == "Major Sorcery" and buffOn == "removed" then
        local inactivecolor = self.db.settings.inactivecolor
        return string.format("|c%sBuff Inactive|r", inactivecolor)
    elseif buffName == "Major Sorcery" and buffOn == "added" then
        local hexcolor =  self.db.settings.hexcolor
        return string.format("|c%sSTATUS: Buff Active|r", hexcolor)
    end
end
function EWPFinder:DisplayDamage()
    local weapon_damage = GetPlayerStat(STAT_POWER)
    local spell_damage = GetPlayerStat(STAT_SPELL_POWER)
    local hexcolor = self.db.settings.hexcolor
    if weapon_damage > spell_damage then
        if weapon_damage == EWPFinder.savedVars.weapondamage then
            return string.format("|c%sWD %d|r", hexcolor, EWPFinder.savedVars.weapondamage)
        else
            EWPFinder.savedVars.weapondamage = weapon_damage
            return string.format("|c%sWD %d|r", hexcolor, EWPFinder.savedVars.weapondamage)
        end
    elseif spell_damage > weapon_damage then
        if spell_damage == EWPFinder.savedVars.spelldamage then
            return string.format("|c%sSD %d|r", hexcolor, EWPFinder.savedVars.spelldamage)
        else
            EWPFinder.savedVars.spelldamage = spell_damage
            return string.format("|c%sSD %d|r", hexcolor, EWPFinder.savedVars.spelldamage)
        end
    else
        if EWPFinder.savedVars.weapondamage == weapon_damage then
            return string.format("|c%sWD %d|r", hexcolor, EWPFinder.savedVars.weapondamage)
        else
            EWPFinder.savedVars.weapondamage = weapon_damage
            return string.format("|c%sWD %d|r", hexcolor, EWPFinder.savedVars.weapondamage)
        end
    end
end

function EWPFinder:Initialize()
    -- Initialize saved variables
    self.db = ZO_SavedVars:New("EWPFinderSettings", 3, nil, self.defaults_db )
    self.savedVars = ZO_SavedVars:New("EWPFinderDamage", 1, nil, {
        weapondamage = GetPlayerStat(STAT_POWER),
        spelldamage = GetPlayerStat(STAT_SPELL_POWER)
    })


    self.ROLL_SECONDS = self.ROLL_SECONDS or 60
    self.roll = self.roll or { idx = 0, filled = 0, sums = {}, samples = {} }
    self.UI.barState = self.UI.barState or {
        Brutality = { display = 0, target = 0, active = false },
        Sorcery = { display = 0, target = 0, active = false },
    }

    -- Initialize UI control
    self.UI.control = _G["EWPFinderContainer"]
    if not self.UI.control then
        d("EWPFinder: Error - EWPFinderContainer control not found.")
        return
    end

    local EWPFinderUIControl = self.UI.control
    local EWPFinderUIControlLabel = EWPFinderUIControl:GetNamedChild("Label")
    local EWPFinderUIControlBuffLabel = EWPFinderUIControl:GetNamedChild("BuffLabel")
    if not EWPFinderUIControlLabel then
        d("EWPFinder: Error - EWPFinderContainerLabel not found.")
        return
    end

    -- Set up control properties
    EWPFinderUIControl:SetHidden(false)
    EWPFinderUIControl:SetClampedToScreen(true)
    EWPFinderUIControl:SetInheritAlpha(false)
    self:SetAppearance()
    self:SetBuffAppearance(self.db.settings.enablebuff)
    -- Set up label properties
    EWPFinderUIControlLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    EWPFinderUIControlLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    EWPFinderUIControlBuffLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    EWPFinderUIControlBuffLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)

    -- Register for updates
    EVENT_MANAGER:RegisterForUpdate(self.name, 1000, function() self:UpdateUI() end)
    EVENT_MANAGER:RegisterForUpdate(self.name .. "_BarAnim", self.BAR_ANIM_TICK_MS, function() self:AnimateMajorBuffBars() end)
end
function EWPFinder:SetBuffAppearance(value)
    if not self.UI or not self.UI.control or not self.db or not self.db.settings then
        return
    end

    local showBuff = self.db.settings.enablebuff
    local showUp = self.db.settings.enableUp
    local showBars = showUp

    local uptimeLabel = self.UI.control:GetNamedChild("UptimeLabel")
    local buffLabel = self.UI.control:GetNamedChild("BuffLabel")

    if uptimeLabel then
        -- Legacy percentage label is retired in favor of status bars.
        uptimeLabel:SetHidden(true)
    end

    if buffLabel then
        buffLabel:SetHidden(not showBuff)
    end

    local barControlNames = {
        "BrutalityBarFrame",
        "BrutalityBar",
        "BrutalityBarName",
        "BrutalityBarValue",
        "SorceryBarFrame",
        "SorceryBar",
        "SorceryBarName",
        "SorceryBarValue",
    }

    for _, controlName in ipairs(barControlNames) do
        local ctl = self.UI.control:GetNamedChild(controlName)
        if ctl then
            ctl:SetHidden(not showBars)
        end
    end
end
local function IsPlayerBuffActive(buffName)
    for i = 1, GetNumBuffs("player") do
        local name = GetUnitBuffInfo("player", i)
        if name == buffName then
            return true
        end
    end
    return false
end
function EWPFinder:SampleRolling(buffName, isActive)
    local r = self.roll
    r.idx = (r.idx % self.ROLL_SECONDS) + 1

    r.samples[buffName] = r.samples[buffName] or {}
    r.sums[buffName] = r.sums[buffName] or 0

    local buf = r.samples[buffName]
    local old = buf[r.idx] or 0
    local new = isActive and 1 or 0

    -- update moving sum
    r.sums[buffName] = r.sums[buffName] - old + new
    buf[r.idx] = new
end

function EWPFinder:ReconcileBuffState(buffName)
    local nowMs = GetGameTimeMilliseconds()
    local up = self.uptime

    up.overallStartMs = up.overallStartMs or nowMs
    up.overallActiveMs = up.overallActiveMs or {}
    up.buffs = up.buffs or {}

    local b = up.buffs[buffName]
    if not b then
        b = { isActive = false, lastChangeMs = nowMs }
        up.buffs[buffName] = b
    end
    if up.overallActiveMs[buffName] == nil then
        up.overallActiveMs[buffName] = 0
    end

    local actuallyActive = IsPlayerBuffActive(buffName)

    -- transition active -> inactive
    if b.isActive and not actuallyActive then
        local delta = math.max(0, nowMs - b.lastChangeMs)
        up.overallActiveMs[buffName] = up.overallActiveMs[buffName] + delta
        b.isActive = false
        b.lastChangeMs = nowMs
        return
    end

    -- transition inactive -> active
    if (not b.isActive) and actuallyActive then
        b.isActive = true
        b.lastChangeMs = nowMs
    end
end
function EWPFinder:ReconcileRolling(buffName, nowMs)
    self.uptime = self.uptime or {}
    local up = self.uptime

    up.windowStartMs = up.windowStartMs or 0
    up.buffs = up.buffs or {}

    if up.windowStartMs == 0 then
        up.windowStartMs = nowMs
    end

    -- roll the window forward (simple reset window)
    local windowElapsed = nowMs - up.windowStartMs
    if windowElapsed >= self.UPTIME_WINDOW_MS then
        up.windowStartMs = nowMs
        for _, b in pairs(up.buffs) do
            b.activeMs = 0
            b.lastChangeMs = nowMs
            -- keep b.isActive as-is
        end
    end

    local b = up.buffs[buffName]
    if not b then
        b = { isActive = false, lastChangeMs = nowMs, activeMs = 0 }
        up.buffs[buffName] = b
    end

    local actuallyActive = IsPlayerBuffActive(buffName)

    -- ACTIVE -> INACTIVE (add time to activeMs)
    if b.isActive and not actuallyActive then
        local delta = math.max(0, nowMs - b.lastChangeMs)
        b.activeMs = b.activeMs + delta
        b.isActive = false
        b.lastChangeMs = nowMs
        return
    end

    -- INACTIVE -> ACTIVE (start timing)
    if (not b.isActive) and actuallyActive then
        b.isActive = true
        b.lastChangeMs = nowMs
    end
end

function EWPFinder:UpdateBuff(eventCode, effectResult, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, bufftype, effecttype, statusType, unitName, unitId, abilityId )
    local EWPFinderUIControlBuffLabel = self.UI.control:GetNamedChild("BuffLabel")
    if unitTag == "player" then
        if effectName == "Major Brutality" or effectName == "Major Sorcery" then
        -- Ensure uptime tables exist (prevents nil indexing)
        self.uptime = self.uptime or {}
        local up = self.uptime
        up.buffs = up.buffs or {}
        up.overallActiveMs = up.overallActiveMs or {}
        up.overallStartMs = up.overallStartMs or GetGameTimeMilliseconds()


        local nowMs = GetGameTimeMilliseconds()
        local up = self.uptime

        -- create per-buff state if missing
        local b = up.buffs[effectName]
        if not b then
            b = { isActive = false, lastChangeMs = nowMs }
            up.buffs[effectName] = b
        end

        -- init overall accumulator
        if up.overallActiveMs[effectName] == nil then
            up.overallActiveMs[effectName] = 0
        end

        local isFaded = (effectResult == EFFECT_RESULT_FADED)

        -- ===== transition: ACTIVE -> INACTIVE (only when it actually fades)
        if isFaded then
            if b.isActive then
                local delta = math.max(0, nowMs - b.lastChangeMs)
                up.overallActiveMs[effectName] = up.overallActiveMs[effectName] + delta
            end
            b.isActive = false
            b.lastChangeMs = nowMs
            return
        end

        -- ===== transition: INACTIVE -> ACTIVE (only when it was inactive)
        if not b.isActive then
            b.isActive = true
            b.lastChangeMs = nowMs
        end

        -- IMPORTANT:
        -- If we get GAINED/UPDATED while already active, do NOTHING.
        -- (Do NOT reset lastChangeMs here, or you break overall.)
    end
    if effectName == "Major Brutality" then
        if effectResult == EFFECT_RESULT_FADED then
            local buff = EWPFinder:DisplayBuff(effectName, "removed")
            self.UI.control:GetNamedChild("BuffLabel"):SetText(buff)
            local notifcontrol = self.UI.control:GetNamedChild("NotifLabel")
            notifcontrol:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.db.locationbuff.x, self.db.locationbuff.y - 100)
            local animation = ANIMATION_MANAGER:CreateTimeline()
            local animslideY = animation:InsertAnimation(ANIMATION_TRANSLATE, notifcontrol, 0)
            local animFade = animation:InsertAnimation(ANIMATION_ALPHA, notifcontrol, 1500)
            animslideY:SetTranslateOffsets(self.db.locationbuff.x, self.db.locationbuff.y - 100, self.db.locationbuff.x, (self.db.location.y - 100) - 250)
            animslideY:SetDuration(1500)
            notifcontrol:SetScale(1.2)
            animFade:SetAlphaValues(notifcontrol:GetAlpha(), 0)
            animFade:SetEasingFunction(ZO_EaseOutCubic)
            animslideY:SetEasingFunction(ZO_EaseInCubic)
            animFade:SetDuration(400)
            animation:SetHandler("OnPlay", function(animation) 
                notifcontrol:SetHidden(false)
                notifcontrol:SetText(string.format("|c%s%s requires rebuff!|r", self.db.settings.inactivecolor, effectName))
            end)
            animation:SetHandler("OnStop", function(completed) 
                    notifcontrol:SetAlpha(1)
                    notifcontrol:SetText("")
                    notifcontrol:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.db.locationbuff.x, self.db.locationbuff.y - 100)
                    notifcontrol:SetHidden(true)
            
            
        end)
            animation:PlayFromStart()

        elseif effectResult == EFFECT_RESULT_GAINED then
            local buff = EWPFinder:DisplayBuff(effectName, "added")
            self.UI.control:GetNamedChild("BuffLabel"):SetText(buff)
            local notifcontrol = self.UI.control:GetNamedChild("NotifLabel")
            notifcontrol:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.db.locationbuff.x, self.db.locationbuff.y - 100)
            local animation = ANIMATION_MANAGER:CreateTimeline()
            local animslideY = animation:InsertAnimation(ANIMATION_TRANSLATE, notifcontrol, 0)
            local animFade = animation:InsertAnimation(ANIMATION_ALPHA, notifcontrol, 1500)
            animslideY:SetTranslateOffsets(self.db.locationbuff.x, self.db.locationbuff.y - 100, self.db.locationbuff.x, (self.db.location.y - 100) - 250)
            animslideY:SetDuration(1500)
            notifcontrol:SetScale(1.2)
            animFade:SetAlphaValues(notifcontrol:GetAlpha(), 0)
            animFade:SetEasingFunction(ZO_EaseOutCubic)
            animslideY:SetEasingFunction(ZO_EaseInCubic)
            animFade:SetDuration(400)
            animation:SetHandler("OnPlay", function(animation) 
                notifcontrol:SetHidden(false)
                notifcontrol:SetText(string.format("|c%s%s Buffed!|r", self.db.settings.hexcolor, effectName))
            end)
            animation:SetHandler("OnStop", function(completed) 
                    notifcontrol:SetAlpha(1)
                    notifcontrol:SetText("")
                    notifcontrol:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.db.locationbuff.x, self.db.locationbuff.y - 100)
                    notifcontrol:SetHidden(true)
            
            
        end)
            animation:PlayFromStart()
        end
    end
    if effectName == "Major Sorcery" then
        if effectResult == EFFECT_RESULT_FADED then
            local buff = EWPFinder:DisplayBuff(effectName, "removed")
            self.UI.control:GetNamedChild("BuffLabel"):SetText(buff)
            local notifcontrol = self.UI.control:GetNamedChild("NotifLabel")
            notifcontrol:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.db.locationbuff.x, self.db.locationbuff.y - 100)
            local animation = ANIMATION_MANAGER:CreateTimeline()
            local animslideY = animation:InsertAnimation(ANIMATION_TRANSLATE, notifcontrol, 0)
            local animFade = animation:InsertAnimation(ANIMATION_ALPHA, notifcontrol, 1500)
            animslideY:SetTranslateOffsets(self.db.locationbuff.x, self.db.locationbuff.y - 100, self.db.locationbuff.x, (self.db.location.y - 100) - 250)
            animslideY:SetDuration(1500)
            notifcontrol:SetScale(1.2)
            animFade:SetAlphaValues(notifcontrol:GetAlpha(), 0)
            animFade:SetEasingFunction(ZO_EaseOutCubic)
            animslideY:SetEasingFunction(ZO_EaseInCubic)
            animFade:SetDuration(400)
            animation:SetHandler("OnPlay", function(animation) 
                notifcontrol:SetHidden(false)
                notifcontrol:SetText(string.format("|c%s%s Requires Rebuff!|r", self.db.settings.inactivecolor, effectName))
            end)
            animation:SetHandler("OnStop", function(completed) 
                    notifcontrol:SetAlpha(1)
                    notifcontrol:SetText("")
                    notifcontrol:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.db.locationbuff.x, self.db.locationbuff.y - 100)
                    notifcontrol:SetHidden(true)
            
            
        end)
            animation:PlayFromStart()
        elseif effectResult == EFFECT_RESULT_GAINED then
            local nowMs = GetNowMs()
            self:ManageUptime(nowMs)
            local buff = EWPFinder:DisplayBuff(effectName, "added")
            self.UI.control:GetNamedChild("BuffLabel"):SetText(buff)
            local notifcontrol = self.UI.control:GetNamedChild("NotifLabel")
            notifcontrol:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.db.locationbuff.x, self.db.locationbuff.y - 100)
            local animation = ANIMATION_MANAGER:CreateTimeline()
            local animslideY = animation:InsertAnimation(ANIMATION_TRANSLATE, notifcontrol, 0)
            local animFade = animation:InsertAnimation(ANIMATION_ALPHA, notifcontrol, 1500)
            animslideY:SetTranslateOffsets(self.db.locationbuff.x, self.db.locationbuff.y - 100, self.db.locationbuff.x, (self.db.location.y - 100) - 250)
            animslideY:SetDuration(1500)
            notifcontrol:SetScale(1.2)
            animFade:SetAlphaValues(notifcontrol:GetAlpha(), 0)
            animFade:SetEasingFunction(ZO_EaseOutCubic)
            animslideY:SetEasingFunction(ZO_EaseInCubic)
            animFade:SetDuration(400)
            animation:SetHandler("OnPlay", function(animation) 
                notifcontrol:SetHidden(false)
                notifcontrol:SetText(string.format("|c%s%s Buffed!|r", self.db.settings.hexcolor, effectName))
            end)
            animation:SetHandler("OnStop", function(completed) 
                    notifcontrol:SetAlpha(1)
                    notifcontrol:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.db.locationbuff.x, self.db.locationbuff.y - 100)
                    notifcontrol:SetHidden(true)
            
            
        end)
            animation:PlayFromStart()
        end
    end
end
end
local function DebugBuff(buffName)
    local b = self.uptime.buffs[buffName]
    local active = self.uptime.overallActiveMs[buffName] or 0
    if b and b.isActive then
        active = active + math.max(0, nowMs - b.lastChangeMs)
    end

    local totalElapsed = math.max(1, nowMs - self.uptime.overallStartMs)
    d(string.format(
        "[UP] %s elapsed=%.1fs active=%.1fs isActive=%s",
        buffName,
        totalElapsed / 1000,
        active / 1000,
        tostring(b and b.isActive)
    ))
end
local function DebugIsPlayerBuffActive(buffName)
    local matches = 0
    for i = 1, GetNumBuffs("player") do
        local name = GetUnitBuffInfo("player", i)
        if name == buffName then
            matches = matches + 1
        end
    end
    return (matches > 0), matches
end
function EWPFinder:SampleRollingAtIndex(buffName, isActive, idx)
    local r = self.roll
    r.samples[buffName] = r.samples[buffName] or {}
    r.sums[buffName] = r.sums[buffName] or 0

    local buf = r.samples[buffName]
    local old = buf[idx] or 0
    local new = isActive and 1 or 0

    r.sums[buffName] = r.sums[buffName] - old + new
    buf[idx] = new
end

function EWPFinder:GetRollingPct(buffName)
    local r = self.roll
    local filled = math.max(1, r.filled or 1)
    local sum = r.sums[buffName] or 0
    return (sum / filled) * 100
end

function EWPFinder:UpdateMajorBuffBar(prefix, pct, isActive)
    if not self.UI or not self.UI.control or not self.db or not self.db.settings then
        return
    end

    self.UI.barState = self.UI.barState or {}
    local state = self.UI.barState[prefix] or { display = 0, target = 0, active = false }
    self.UI.barState[prefix] = state

    local clampedPct = math.max(0, math.min(100, pct or 0))
    if state.display == nil then
        state.display = clampedPct
    end
    state.target = clampedPct
    state.active = (isActive == true)
end

function EWPFinder:AnimateMajorBuffBars()
    if not self.UI or not self.UI.control or not self.db or not self.db.settings then
        return
    end

    self.UI.barState = self.UI.barState or {}
    local lerp = self.BAR_ANIM_LERP or 0.32
    local valueR, valueG, valueB = HexToRGBA(self.db.settings.uptimecolor, 1)

    for _, prefix in ipairs({ "Brutality", "Sorcery" }) do
        local state = self.UI.barState[prefix]
        if state then
            local bar = self.UI.control:GetNamedChild(prefix .. "Bar")
            local barFrame = self.UI.control:GetNamedChild(prefix .. "BarFrame")
            local barValue = self.UI.control:GetNamedChild(prefix .. "BarValue")

            if bar then
                local current = state.display or state.target or 0
                local target = state.target or 0
                local delta = target - current

                if math.abs(delta) < 0.05 then
                    current = target
                else
                    current = current + (delta * lerp)
                end

                state.display = math.max(0, math.min(100, current))

                local colorHex = state.active and self.db.settings.hexcolor or self.db.settings.inactivecolor
                local r, g, b = HexToRGBA(colorHex, 1)

                bar:SetMinMax(0, 100)
                bar:SetValue(state.display)
                bar:SetColor(r, g, b, state.active and 0.94 or 0.50)

                if barFrame then
                    barFrame:SetCenterColor(0.01, 0.01, 0.01, 0.42)
                    barFrame:SetEdgeColor(r, g, b, state.active and 0.84 or 0.44)
                end

                if barValue then
                    barValue:SetText(string.format("%.0f%%", state.display))
                    barValue:SetColor(valueR, valueG, valueB, 0.98)
                end
            end
        end
    end
end

function EWPFinder:UpdateUI()
    if not self.UI.control then return end

    -- Damage label
    local message = self:DisplayDamage()
    if message then
        local dmgLabel = self.UI.control:GetNamedChild("Label")
        if dmgLabel then dmgLabel:SetText(message) end
    end

    if not self.db or not self.db.settings or not self.db.settings.uptime then
        return
    end

    -- Ensure rolling state exists
    self.ROLL_SECONDS = self.ROLL_SECONDS or 60
    self.roll = self.roll or { idx = 0, filled = 0, sums = {}, samples = {} }

    local r = self.roll
    local win = self.ROLL_SECONDS

    -- Advance index ONCE per tick
    r.idx = (r.idx % win) + 1
    r.filled = math.min(win, (r.filled or 0) + 1)

    -- Sample BOTH buffs into the SAME idx
    local brutalityActive = IsPlayerBuffActive("Major Brutality")
    local sorceryActive = IsPlayerBuffActive("Major Sorcery")
    self:SampleRollingAtIndex("Major Brutality", brutalityActive, r.idx)
    self:SampleRollingAtIndex("Major Sorcery",   sorceryActive,   r.idx)

    local brPct = self:GetRollingPct("Major Brutality")
    local soPct = self:GetRollingPct("Major Sorcery")

    self:UpdateMajorBuffBar("Brutality", brPct, brutalityActive)
    self:UpdateMajorBuffBar("Sorcery", soPct, sorceryActive)
end





function EWPFinder:SetAppearance()
    local EWPFinderUIControl = self.UI.control
    if not EWPFinderUIControl then
        d("EWPFinder: Error - Cannot set appearance, control is nil.")
        return
    end
    local EWPFinderUIControlLabel = EWPFinderUIControl:GetNamedChild("Label")
    local EWPFinderUIControlBuffLabel = EWPFinderUIControl:GetNamedChild("BuffLabel")
    local EWPFinderUIControlUPTIMELABEL = EWPFinderUIControl:GetNamedChild("UptimeLabel")
    if not EWPFinderUIControlLabel then
        d("EWPFinder: Error - Cannot set label properties, label is nil.")
        return
    end
    EWPFinderUIControl:ClearAnchors()
    EWPFinderUIControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.db.location.x, self.db.location.y)
    EWPFinderUIControl:SetDimensions(430, 188)

    local fontSize = math.floor(21 * self.db.settings.customScale)

    local accentR, accentG, accentB = HexToRGBA(self.db.settings.hexcolor, 1)
    local warningR, warningG, warningB = HexToRGBA(self.db.settings.inactivecolor, 1)
    local upR, upG, upB = HexToRGBA(self.db.settings.uptimecolor, 1)

    local card = EWPFinderUIControl:GetNamedChild("Card")
    local glowTop = EWPFinderUIControl:GetNamedChild("GlowTop")
    local glowBottom = EWPFinderUIControl:GetNamedChild("GlowBottom")
    local header = EWPFinderUIControl:GetNamedChild("HeaderLabel")

    if card then
        card:SetHidden(true)
        card:SetCenterColor(0.03, 0.03, 0.03, 0.36)
        card:SetEdgeColor(accentR, accentG * 0.82, accentB * 0.62, 0.88)
    end

    if glowTop then
        glowTop:SetHidden(true)
        glowTop:SetColor(accentR, accentG, accentB, 0.95)
    end

    if glowBottom then
        glowBottom:SetHidden(true)
        glowBottom:SetColor(warningR, warningG, warningB, 0.80)
    end

    if header then
        header:SetHidden(true)
    end

    EWPFinderUIControlLabel:SetFont(string.format("/esoui/common/fonts/univers67.otf|%d|soft-shadow-thick", fontSize))
    EWPFinderUIControlLabel:SetColor(unpack(self.db.settings.color))
    EWPFinderUIControlBuffLabel:SetFont(string.format("/esoui/common/fonts/univers67.otf|%d|soft-shadow-thick", fontSize))
    EWPFinderUIControlBuffLabel:SetColor(unpack(self.db.settings.color))
    EWPFinderUIControlBuffLabel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.db.locationbuff.x, self.db.locationbuff.y)
    EWPFinderUIControlUPTIMELABEL:SetHidden(true)

    local brutFrame = EWPFinderUIControl:GetNamedChild("BrutalityBarFrame")
    local brutBar = EWPFinderUIControl:GetNamedChild("BrutalityBar")
    local brutName = EWPFinderUIControl:GetNamedChild("BrutalityBarName")
    local brutValue = EWPFinderUIControl:GetNamedChild("BrutalityBarValue")
    local sorFrame = EWPFinderUIControl:GetNamedChild("SorceryBarFrame")
    local sorBar = EWPFinderUIControl:GetNamedChild("SorceryBar")
    local sorName = EWPFinderUIControl:GetNamedChild("SorceryBarName")
    local sorValue = EWPFinderUIControl:GetNamedChild("SorceryBarValue")

    if brutFrame then
        brutFrame:ClearAnchors()
        brutFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.db.locationup.x, self.db.locationup.y)
    end

    if sorFrame then
        sorFrame:ClearAnchors()
        sorFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.db.locationup.x, self.db.locationup.y + 24)
    end

    if brutBar then
        brutBar:SetColor(accentR, accentG, accentB, 0.94)
    end

    if sorBar then
        sorBar:SetColor(accentR, accentG * 0.9, accentB * 0.82, 0.94)
    end

    if brutName then
        brutName:SetFont(string.format("/esoui/common/fonts/univers67.otf|%d|soft-shadow-thick", math.max(13, fontSize - 7)))
        brutName:SetColor(upR, upG, upB, 0.94)
    end

    if sorName then
        sorName:SetFont(string.format("/esoui/common/fonts/univers67.otf|%d|soft-shadow-thick", math.max(13, fontSize - 7)))
        sorName:SetColor(upR * 0.96, upG * 0.94, upB * 0.92, 0.94)
    end

    if brutValue then
        brutValue:SetFont(string.format("/esoui/common/fonts/univers67.otf|%d|soft-shadow-thick", math.max(13, fontSize - 7)))
        brutValue:SetColor(upR, upG, upB, 0.96)
    end

    if sorValue then
        sorValue:SetFont(string.format("/esoui/common/fonts/univers67.otf|%d|soft-shadow-thick", math.max(13, fontSize - 7)))
        sorValue:SetColor(upR * 0.96, upG * 0.94, upB * 0.92, 0.96)
    end

    local notifLabel = EWPFinderUIControl:GetNamedChild("NotifLabel")
    if notifLabel then
        notifLabel:SetFont(string.format("/esoui/common/fonts/univers67.otf|%d|soft-shadow-thick", math.max(fontSize + 2, 20)))
    end

    self:SetBuffAppearance()
    self:AnimateMajorBuffBars()
end
function EWPFinder.OnAddOnLoaded(event, addonName)
    if addonName ~= EWPFinder.name then return end
    EWPFinder.isLoaded = true
    EWPFinder:Initialize()
    EVENT_MANAGER:AddFilterForEvent(EWPFinder.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:RegisterForEvent(EWPFinder.name, EVENT_EFFECT_CHANGED, function(...) EWPFinder:UpdateBuff(...) end)
    
    EVENT_MANAGER:RegisterForEvent(EWPFinder.name, EVENT_STATS_UPDATED, function() EWPFinder:UpdateUI() end)
end

EVENT_MANAGER:RegisterForEvent(EWPFinder.name, EVENT_ADD_ON_LOADED, EWPFinder.OnAddOnLoaded)
