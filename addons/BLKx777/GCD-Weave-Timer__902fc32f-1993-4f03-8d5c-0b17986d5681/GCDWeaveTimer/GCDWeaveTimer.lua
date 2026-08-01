GCDWeaveTimer = GCDWeaveTimer or {}
local CMG = GCDWeaveTimer

CMG.name = "GCDWeaveTimer"
CMG.displayName = "GCD Weave Timer"
CMG.savedVersion = 14

CMG.defaults = {
    enabled = true,
    liteModeInstances = false,
    hideOutOfCombat = true,
    showLatency = true,
    preview = false,
    width = 360,
    height = 24,
    x = 0,
    y = 0,
    fillColor = {0.80, 0.08, 0.08, 0.95},
    latencyColor = {1.00, 1.00, 1.00, 0.35},
    backgroundColor = {0.00, 0.00, 0.00, 0.55},
    borderColor = {1.00, 1.00, 1.00, 0.18},

    -- Centre-collapse GCD display
    collapseToCentre = true,
    weaveZoneEnabled = true,
    weaveZoneWidth = 52,
    weaveZoneColor = {0.20, 0.95, 0.35, 0.28},
    centreLineColor = {1.00, 1.00, 1.00, 0.80},

    -- Channel-aware timing
    channelAware = true,
    channelMinDurationMs = 1250,
    channelMaxDurationMs = 6000,
    channelDetectionFallbackMs = 4500,

    -- Known channel / beam abilities used when ESO does not raise EVENT_BEGIN_CAST reliably.
    -- Names are intentionally partial/lowercase matched so morphs still work.
    knownChannelSkills = {
        fatecarver = 4500,
        ["pragmatic fatecarver"] = 4500,
        ["exhausting fatecarver"] = 4500,
        ["radiant destruction"] = 1800,
        ["radiant oppression"] = 1800,
        ["radiant glory"] = 1800,
        ["soul assault"] = 3500,
        ["shifting standard"] = 4000,
        ["rapid strikes"] = 1300,
        ["bloodthirst"] = 1300,
        ["flurry"] = 1300,
        ["jabs"] = 1000,
        ["puncturing sweeps"] = 1000,
        ["biting jabs"] = 1000,
        ["engulfing dragonfire"] = 4800,
        ["dragonfire"] = 4800,
        ["dragon fire"] = 4800,
        ["flame breath"] = 4800,
        ["fiery breath"] = 4800,
    },

    -- Ability ID detection is preferred when available because it avoids morph/localisation
    -- issues. The table is intentionally user/settings backed so exact IDs can be added
    -- without rewriting the timing engine as ESO updates abilities.
    knownChannelAbilityIds = {
        -- [123456] = 4500,
    },

    -- Weave Now prompt
    weaveNowEnabled = true,
    weaveNowLeadMs = 200,
    weaveNowFont = "$(BOLD_FONT)|28|soft-shadow-thick",
    weaveNowColor = {0.20, 0.95, 0.35, 1.00},

    -- Lightweight light attack weaving tracker
    weaveTrackerEnabled = true,
    weaveTrackerMode = "compact", -- compact, gap, rate
    weaveTrackerHideOutOfCombat = true,
    weaveTrackerWidth = 240,
    weaveTrackerHeight = 30,
    weaveTrackerYOffset = 34,
    weaveTrackerGoodMs = 1150,
    weaveTrackerLateMs = 1600,
    weaveTrackerHideDelayMs = 3500,
    weaveTrackerFont = "$(BOLD_FONT)|23|soft-shadow-thick",

    -- Total light attack streak display
    streakEnabled = true,
    streakOnlyValidWeaves = false,
    weaveValidationGraceMs = 260,
    streakWidth = 58,
    streakFont = "$(BOLD_FONT)|26|soft-shadow-thick",
    streakColor = {1.00, 1.00, 1.00, 1.00},

    weaveGoodColor = {0.20, 0.95, 0.35, 0.95},
    weaveLateColor = {1.00, 0.72, 0.20, 0.95},
    weaveMissColor = {1.00, 0.15, 0.12, 0.95},
    weaveTextColor = {1.00, 1.00, 1.00, 0.95},
}

CMG.weave = {
    combatStart = 0,
    count = 0,
    lastTime = 0,
    gap = 0,
    rate = 0,
    lastResult = "N/A",
    streak = 0,
    total = 0,
}

CMG.active = false
CMG.started = 0
CMG.duration = 1000
CMG.isChannel = false
CMG.weaveNowShown = false
CMG.waitingForLightAttack = false
CMG.weaveWindowOpenAt = 0
CMG.weaveWindowCloseAt = 0
CMG.lastUpdate = 0
CMG.updateRateMs = 33

local function Clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

local function Now()
    return GetGameTimeMilliseconds()
end

local function NormaliseAbilityName(abilityName)
    if not abilityName then return "" end
    abilityName = zo_strlower(tostring(abilityName))
    abilityName = abilityName:gsub("%^[%a%d]+", "")
    return abilityName
end

function CMG:GetKnownChannelDuration(abilityName, abilityId)
    if not self.sv or not self.sv.channelAware then return nil end

    local minDuration = self.sv.channelMinDurationMs or 1250
    local maxDuration = self.sv.channelMaxDurationMs or 6000

    -- Primary path: abilityId. This is more reliable than text names because names
    -- can vary by morph, localisation, or what the event exposes.
    if abilityId then
        local id = tonumber(abilityId)
        if id then
            local idTable = self.sv.knownChannelAbilityIds or self.defaults.knownChannelAbilityIds or {}
            local idDuration = tonumber(idTable[id] or idTable[tostring(id)])
            if idDuration and idDuration >= minDuration then
                return Clamp(idDuration, minDuration, maxDuration)
            end
        end
    end

    -- Fallback path: partial lowercase name matching. This keeps the addon useful
    -- for new channels whose ability IDs are not known yet.
    local name = NormaliseAbilityName(abilityName)
    if name == "" then return nil end

    local known = self.sv.knownChannelSkills or self.defaults.knownChannelSkills or {}
    local bestDuration = nil
    local bestLength = 0

    for key, duration in pairs(known) do
        local needle = NormaliseAbilityName(key)
        if needle ~= "" and string.find(name, needle, 1, true) then
            -- Prefer the most specific morph name if multiple names match.
            if string.len(needle) > bestLength then
                bestDuration = tonumber(duration)
                bestLength = string.len(needle)
            end
        end
    end

    if bestDuration and bestDuration >= minDuration then
        return Clamp(bestDuration, minDuration, maxDuration)
    end
    return nil
end

function CMG:TryStartKnownChannel(abilityName, abilityId)
    local duration = self:GetKnownChannelDuration(abilityName, abilityId)
    if duration then
        self:StartTimer(duration, true)
        return true
    end
    return false
end

function CMG:IsGroupInstance()
    -- Lite Mode is intended for dungeon/trial environments where addon load matters most.
    -- Use multiple safe checks because ESO API availability can vary by client/API version.
    if IsUnitInDungeon and IsUnitInDungeon("player") then
        return true
    end

    if GetCurrentZoneDungeonDifficulty then
        local difficulty = GetCurrentZoneDungeonDifficulty()
        if difficulty and difficulty ~= 0 then
            return true
        end
    end

    return false
end

function CMG:IsLiteModeActive()
    return self.sv and self.sv.enabled and self.sv.liteModeInstances and self:IsGroupInstance()
end


function CMG:CreateUI()
    local frame = WINDOW_MANAGER:CreateTopLevelWindow("GCDWeaveTimerFrame")
    frame:SetDimensions(self.sv.width, self.sv.height)
    frame:SetAnchor(CENTER, GuiRoot, CENTER, self.sv.x, self.sv.y)
    frame:SetMouseEnabled(false)
    frame:SetMovable(false)
    frame:SetHidden(true)
    self.frame = frame

    local bg = WINDOW_MANAGER:CreateControl("GCDWeaveTimerBackground", frame, CT_BACKDROP)
    bg:SetAnchorFill(frame)
    bg:SetCenterColor(unpack(self.sv.backgroundColor))
    bg:SetEdgeColor(unpack(self.sv.borderColor))
    bg:SetEdgeTexture(nil, 1, 1, 1)
    self.background = bg

    local zone = WINDOW_MANAGER:CreateControl("GCDWeaveTimerWeaveZone", frame, CT_TEXTURE)
    zone:SetAnchor(CENTER, frame, CENTER, 0, 0)
    zone:SetDimensions(self.sv.weaveZoneWidth, self.sv.height)
    zone:SetColor(unpack(self.sv.weaveZoneColor))
    zone:SetHidden(not self.sv.weaveZoneEnabled)
    self.weaveZone = zone

    local leftFill = WINDOW_MANAGER:CreateControl("GCDWeaveTimerLeftFill", frame, CT_TEXTURE)
    leftFill:SetAnchor(RIGHT, frame, CENTER, 0, 0)
    leftFill:SetDimensions(self.sv.width / 2, self.sv.height)
    leftFill:SetColor(unpack(self.sv.fillColor))
    self.leftFill = leftFill

    local rightFill = WINDOW_MANAGER:CreateControl("GCDWeaveTimerRightFill", frame, CT_TEXTURE)
    rightFill:SetAnchor(LEFT, frame, CENTER, 0, 0)
    rightFill:SetDimensions(self.sv.width / 2, self.sv.height)
    rightFill:SetColor(unpack(self.sv.fillColor))
    self.rightFill = rightFill

    -- Kept for legacy fallback if centre-collapse is disabled later.
    local fill = WINDOW_MANAGER:CreateControl("GCDWeaveTimerFill", frame, CT_TEXTURE)
    fill:SetAnchor(LEFT, frame, LEFT, 0, 0)
    fill:SetDimensions(0, self.sv.height)
    fill:SetColor(unpack(self.sv.fillColor))
    fill:SetHidden(true)
    self.fill = fill

    local latency = WINDOW_MANAGER:CreateControl("GCDWeaveTimerLatency", frame, CT_TEXTURE)
    latency:SetAnchor(RIGHT, frame, RIGHT, 0, 0)
    latency:SetDimensions(0, self.sv.height)
    latency:SetColor(unpack(self.sv.latencyColor))
    latency:SetHidden(not self.sv.showLatency)
    self.latency = latency

    local centreLine = WINDOW_MANAGER:CreateControl("GCDWeaveTimerCentreLine", frame, CT_TEXTURE)
    centreLine:SetAnchor(CENTER, frame, CENTER, 0, 0)
    centreLine:SetDimensions(3, self.sv.height + 8)
    centreLine:SetColor(unpack(self.sv.centreLineColor))
    self.centreLine = centreLine

    local weaveNow = WINDOW_MANAGER:CreateControl("GCDWeaveTimerWeaveNow", frame, CT_LABEL)
    weaveNow:SetAnchor(BOTTOM, frame, TOP, 0, -8)
    weaveNow:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    weaveNow:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    weaveNow:SetFont(self.sv.weaveNowFont)
    weaveNow:SetColor(unpack(self.sv.weaveNowColor))
    weaveNow:SetText("WEAVE NOW")
    weaveNow:SetHidden(true)
    self.weaveNow = weaveNow

    local weaveFrame = WINDOW_MANAGER:CreateTopLevelWindow("GCDWeaveTimerWeaveFrame")
    weaveFrame:SetDimensions(self.sv.weaveTrackerWidth, self.sv.weaveTrackerHeight)
    weaveFrame:SetAnchor(TOP, frame, BOTTOM, 0, self.sv.weaveTrackerYOffset)
    weaveFrame:SetMouseEnabled(false)
    weaveFrame:SetMovable(false)
    weaveFrame:SetHidden(true)
    self.weaveFrame = weaveFrame

    local weaveBg = WINDOW_MANAGER:CreateControl("GCDWeaveTimerWeaveBackground", weaveFrame, CT_BACKDROP)
    weaveBg:SetAnchorFill(weaveFrame)
    weaveBg:SetCenterColor(0, 0, 0, 0.48)
    weaveBg:SetEdgeColor(unpack(self.sv.borderColor))
    weaveBg:SetEdgeTexture(nil, 1, 1, 1)
    self.weaveBackground = weaveBg

    local weaveIndicator = WINDOW_MANAGER:CreateControl("GCDWeaveTimerWeaveIndicator", weaveFrame, CT_TEXTURE)
    weaveIndicator:SetAnchor(LEFT, weaveFrame, LEFT, 4, 0)
    weaveIndicator:SetDimensions(9, self.sv.weaveTrackerHeight - 8)
    weaveIndicator:SetColor(unpack(self.sv.weaveTextColor))
    self.weaveIndicator = weaveIndicator

    local weaveLabel = WINDOW_MANAGER:CreateControl("GCDWeaveTimerWeaveLabel", weaveFrame, CT_LABEL)
    weaveLabel:SetAnchor(LEFT, weaveIndicator, RIGHT, 8, 0)
    weaveLabel:SetAnchor(RIGHT, weaveFrame, RIGHT, -8, 0)
    weaveLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    weaveLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    weaveLabel:SetFont(self.sv.weaveTrackerFont)
    weaveLabel:SetColor(unpack(self.sv.weaveTextColor))
    weaveLabel:SetText("LA: N/A")
    self.weaveLabel = weaveLabel

    local streakLabel = WINDOW_MANAGER:CreateControl("GCDWeaveTimerStreakLabel", weaveFrame, CT_LABEL)
    streakLabel:SetAnchor(RIGHT, weaveFrame, LEFT, -12, 0)
    streakLabel:SetDimensions(self.sv.streakWidth, self.sv.weaveTrackerHeight + 8)
    streakLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    streakLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    streakLabel:SetFont(self.sv.streakFont)
    streakLabel:SetColor(unpack(self.sv.streakColor))
    streakLabel:SetText("0")
    streakLabel:SetHidden(not self.sv.streakEnabled)
    self.streakLabel = streakLabel
end

function CMG:ApplyLayout()
    if not self.frame then return end
    self.frame:ClearAnchors()
    self.frame:SetAnchor(CENTER, GuiRoot, CENTER, self.sv.x, self.sv.y)
    self.frame:SetDimensions(self.sv.width, self.sv.height)

    local halfWidth = self.sv.width / 2
    self.leftFill:SetHeight(self.sv.height)
    self.rightFill:SetHeight(self.sv.height)
    self.leftFill:SetWidth(halfWidth)
    self.rightFill:SetWidth(halfWidth)
    self.fill:SetHeight(self.sv.height)
    self.latency:SetHeight(self.sv.height)

    self.weaveZone:SetDimensions(self.sv.weaveZoneWidth, self.sv.height)
    self.weaveZone:SetHidden(not self.sv.weaveZoneEnabled)
    self.centreLine:SetDimensions(3, self.sv.height + 8)
    if self.weaveNow then
        self.weaveNow:SetFont(self.sv.weaveNowFont)
        self.weaveNow:SetColor(unpack(self.sv.weaveNowColor))
    end

    if self.weaveFrame then
        self.weaveFrame:ClearAnchors()
        self.weaveFrame:SetAnchor(TOP, self.frame, BOTTOM, 0, self.sv.weaveTrackerYOffset)
        self.weaveFrame:SetDimensions(self.sv.weaveTrackerWidth, self.sv.weaveTrackerHeight)
        self.weaveIndicator:SetDimensions(9, self.sv.weaveTrackerHeight - 8)
        self.weaveLabel:SetFont(self.sv.weaveTrackerFont)
        if self.streakLabel then
            self.streakLabel:SetDimensions(self.sv.streakWidth, self.sv.weaveTrackerHeight + 8)
            self.streakLabel:SetFont(self.sv.streakFont)
            self.streakLabel:SetColor(unpack(self.sv.streakColor))
            self.streakLabel:SetHidden(not self.sv.streakEnabled)
        end
    end
end

function CMG:SetAddonEnabled(value)
    self.sv.enabled = value == true

    if not self.sv.enabled then
        self.active = false
        self.isChannel = false
        self.weaveNowShown = false
        self.waitingForLightAttack = false
        EVENT_MANAGER:UnregisterForUpdate(self.name .. "Update")

        if self.weaveNow then self.weaveNow:SetHidden(true) end
        if self.frame then self.frame:SetHidden(true) end
        if self.weaveFrame then self.weaveFrame:SetHidden(true) end
        if self.streakLabel then self.streakLabel:SetHidden(true) end
        return
    end

    self:RefreshPreview()
end

function CMG:SetVisible(visible)
    if not self.frame then return end
    if self.sv.preview then visible = true end
    if not self.sv.enabled then visible = false end
    if self.sv.hideOutOfCombat and not IsUnitInCombat("player") and not self.sv.preview then visible = false end
    self.frame:SetHidden(not visible)
end

function CMG:SetWeaveVisible(visible)
    if not self.weaveFrame then return end
    if self.sv.preview then visible = true end
    if not self.sv.enabled or not self.sv.weaveTrackerEnabled or self:IsLiteModeActive() then visible = false end
    if self.sv.weaveTrackerHideOutOfCombat and not IsUnitInCombat("player") and not self.sv.preview then visible = false end
    self.weaveFrame:SetHidden(not visible)
    if self.streakLabel then
        self.streakLabel:SetHidden((not visible) or (not self.sv.streakEnabled))
    end
end

function CMG:UpdateWeaveDisplay()
    if not self.weaveLabel or not self.weaveIndicator then return end
    if self.streakLabel then
        self.streakLabel:SetText(tostring(self.weave.streak or 0))
        self.streakLabel:SetHidden(not self.sv.streakEnabled)
    end

    local text
    if self.weave.count == 0 then
        text = "LA: N/A"
        self.weaveIndicator:SetColor(unpack(self.sv.weaveTextColor))
    else
        if self.sv.weaveTrackerMode == "gap" then
            text = string.format("LA GAP: %sms", self.weave.gap > 0 and tostring(self.weave.gap) or "N/A")
        elseif self.sv.weaveTrackerMode == "rate" then
            text = string.format("LA/s: %.2f", self.weave.rate)
        else
            if self.weave.gap == 0 then
                text = string.format("LA: %d", self.weave.count)
            else
                text = string.format("LA: %s  %dms", self.weave.lastResult, self.weave.gap)
            end
        end

        if self.weave.lastResult == "GOOD" then
            self.weaveIndicator:SetColor(unpack(self.sv.weaveGoodColor))
        elseif self.weave.lastResult == "LATE" then
            self.weaveIndicator:SetColor(unpack(self.sv.weaveLateColor))
        elseif self.weave.lastResult == "MISS" then
            self.weaveIndicator:SetColor(unpack(self.sv.weaveMissColor))
        else
            self.weaveIndicator:SetColor(unpack(self.sv.weaveTextColor))
        end
    end

    self.weaveLabel:SetText(text)
    self:SetWeaveVisible(true)
end

function CMG:ResetWeaveTracker()
    self.weave.combatStart = 0
    self.weave.count = 0
    self.weave.total = 0
    self.weave.streak = 0
    self.weave.lastTime = 0
    self.weave.gap = 0
    self.weave.rate = 0
    self.weave.lastResult = "N/A"
    self.waitingForLightAttack = false
    self.weaveWindowOpenAt = 0
    self.weaveWindowCloseAt = 0
    self:UpdateWeaveDisplay()
    zo_callLater(function()
        if not IsUnitInCombat("player") and not self.sv.preview then
            self:SetWeaveVisible(false)
        end
    end, self.sv.weaveTrackerHideDelayMs)
end

function CMG:MarkWeaveMiss()
    self.weave.lastResult = "MISS"
    self.weave.gap = 0
    self.weave.streak = 0
    self.waitingForLightAttack = false
    self:UpdateWeaveDisplay()
end

function CMG:HandleLightAttack(timeMs)
    if not self.sv.enabled or not self.sv.weaveTrackerEnabled then return end

    timeMs = timeMs or Now()
    if self.weave.combatStart == 0 then
        self.weave.combatStart = timeMs
    end

    self.weave.total = (self.weave.total or 0) + 1

    if self.weave.lastTime > 0 then
        self.weave.gap = timeMs - self.weave.lastTime
    else
        self.weave.gap = 0
    end

    local validWindow = true
    if self.sv.streakOnlyValidWeaves then
        -- A successful streak LA must land inside the active GCD/channel weave window.
        -- Long channels naturally hold the streak because StartTimer() sets the window
        -- from the reported channel end rather than from a fixed 1-second GCD.
        if self.waitingForLightAttack then
            validWindow = timeMs >= self.weaveWindowOpenAt and timeMs <= self.weaveWindowCloseAt
        else
            -- First LA of combat can initialise the chain; later random LAs outside a window reset.
            validWindow = (self.weave.lastTime == 0 or self.weave.streak == 0)
        end
    elseif self.weave.gap > 0 then
        validWindow = self.weave.gap <= self.sv.weaveTrackerGoodMs
    end

    if validWindow then
        self.weave.lastResult = "GOOD"
        self.weave.streak = (self.weave.streak or 0) + 1
        self.waitingForLightAttack = false
    else
        self.weave.lastResult = "MISS"
        self.weave.streak = 0
        self.waitingForLightAttack = false
    end

    self.weave.lastTime = timeMs
    self.weave.count = self.weave.streak

    local elapsed = timeMs - self.weave.combatStart
    if elapsed > 0 then
        self.weave.rate = ((self.weave.total or 0) * 1000) / elapsed
    end

    self:UpdateWeaveDisplay()
end

function CMG:StartTimer(durationMs, isChannel)
    -- Do not immediately reset the LA streak when the next skill event arrives.
    -- ESO can report ability-use events before the matching Light Attack combat event,
    -- especially under latency or during fast weaving. Only mark the previous window
    -- as missed once its grace period has actually expired. This restores the smoother
    -- 1.6.x bar/LA behaviour while keeping valid-weave streak rules intact.
    if self.sv.streakOnlyValidWeaves and self.waitingForLightAttack and (self.weave.streak or 0) > 0 then
        if Now() > (self.weaveWindowCloseAt or 0) then
            self:MarkWeaveMiss()
        end
    end

    local maxDuration = self.sv.channelMaxDurationMs or 6000
    self.duration = Clamp(durationMs or 1000, 250, maxDuration)
    self.isChannel = isChannel == true
    self.weaveNowShown = false
    self.started = Now()
    local leadMs = self.sv.weaveNowLeadMs or 200
    local graceMs = self.sv.weaveValidationGraceMs or 260
    self.waitingForLightAttack = true
    self.weaveWindowOpenAt = self.started + self.duration - leadMs
    self.weaveWindowCloseAt = self.started + self.duration + graceMs
    self.active = true
    if self.weaveNow then self.weaveNow:SetHidden(true) end
    self:SetVisible(true)
    EVENT_MANAGER:RegisterForUpdate(self.name .. "Update", self.updateRateMs, function() self:UpdateBar() end)
end

function CMG:StopTimer()
    self.active = false
    self.isChannel = false
    self.weaveNowShown = false
    self.waitingForLightAttack = false
    if self.weaveNow then self.weaveNow:SetHidden(true) end
    if self.fill then self.fill:SetWidth(0) end
    if self.leftFill then self.leftFill:SetWidth(0) end
    if self.rightFill then self.rightFill:SetWidth(0) end
    if self.latency then self.latency:SetWidth(0) end
    EVENT_MANAGER:UnregisterForUpdate(self.name .. "Update")
    self:SetVisible(false)
end

function CMG:UpdateBar()
    if not self.active then return end

    local elapsed = Now() - self.started
    local progress = Clamp(elapsed / self.duration, 0, 1)
    local remainingProgress = 1 - progress
    local remaining = self.duration - elapsed

    if self.sv.collapseToCentre then
        local halfWidth = (self.sv.width / 2) * remainingProgress
        self.leftFill:SetHidden(false)
        self.rightFill:SetHidden(false)
        self.fill:SetHidden(true)
        self.leftFill:SetWidth(halfWidth)
        self.rightFill:SetWidth(halfWidth)
    else
        self.leftFill:SetHidden(true)
        self.rightFill:SetHidden(true)
        self.fill:SetHidden(false)
        self.fill:SetWidth(self.sv.width * progress)
    end

    if self.sv.showLatency then
        local latencyMs = GetLatency() or 0
        local latencyWidth = Clamp((latencyMs / self.duration) * self.sv.width, 0, self.sv.width)
        self.latency:SetWidth(latencyWidth)
    end

    if self.sv.weaveNowEnabled and not self:IsLiteModeActive() and self.weaveNow then
        local showAtMs = self.sv.weaveNowLeadMs or 200
        local shouldShow = remaining <= showAtMs
        self.weaveNow:SetHidden(not shouldShow)
        self.weaveNowShown = shouldShow
    elseif self.weaveNow then
        self.weaveNow:SetHidden(true)
    end

    if remaining <= 0 then
        self.leftFill:SetWidth(0)
        self.rightFill:SetWidth(0)
        if self.sv.weaveNowEnabled and not self:IsLiteModeActive() and self.weaveNow and self.waitingForLightAttack then
            self.weaveNow:SetHidden(false)
        end

        if self.waitingForLightAttack and Now() <= (self.weaveWindowCloseAt or 0) then
            return
        end

        if self.waitingForLightAttack then
            self:MarkWeaveMiss()
        end
        self:StopTimer()
    end
end

function CMG:RefreshPreview()
    self:ApplyLayout()
    if self.sv.preview then
        self.active = false
        self.leftFill:SetHidden(false)
        self.rightFill:SetHidden(false)
        self.fill:SetHidden(true)
        self.leftFill:SetWidth(self.sv.width / 2)
        self.rightFill:SetWidth(self.sv.width / 2)
        if self.weaveNow then self.weaveNow:SetHidden(not self.sv.weaveNowEnabled) end
        self:SetVisible(true)
        self:SetWeaveVisible(true)
        self:UpdateWeaveDisplay()
    else
        self:SetVisible(false)
        self:SetWeaveVisible(false)
    end
end

function CMG:OnCombatState(_, inCombat)
    if inCombat then
        self:SetVisible(true)
        self.weave.combatStart = Now()
        self:SetWeaveVisible(self.sv.weaveTrackerEnabled and not self:IsLiteModeActive())
        self:UpdateWeaveDisplay()
    elseif not self.active then
        self:SetVisible(false)
        self:ResetWeaveTracker()
    end
end


function CMG:GetSlotAbilityIdSafe(slotNum)
    -- API names vary across ESO versions/addon examples, so guard every lookup.
    if GetSlotBoundId then
        local ok, id = pcall(GetSlotBoundId, slotNum)
        if ok and id and id ~= 0 then return id end
    end
    if GetSlotAbilityId then
        local ok, id = pcall(GetSlotAbilityId, slotNum)
        if ok and id and id ~= 0 then return id end
    end
    if GetSlotBoundAbilityId then
        local ok, id = pcall(GetSlotBoundAbilityId, slotNum)
        if ok and id and id ~= 0 then return id end
    end
    return nil
end

function CMG:OnActionSlotAbilityUsed(_, slotNum)
    if not self.sv.enabled then return end
    if slotNum < ACTION_BAR_FIRST_NORMAL_SLOT_INDEX or slotNum > ACTION_BAR_ULTIMATE_SLOT_INDEX then return end

    local abilityName = nil
    if GetSlotName then abilityName = GetSlotName(slotNum) end
    local abilityId = self:GetSlotAbilityIdSafe(slotNum)

    -- Some beam/channel skills do not always provide a reliable EVENT_BEGIN_CAST
    -- window on every client/addon setup. AbilityId detection is preferred here;
    -- name matching remains as a fallback for unknown/new channels.
    if self:TryStartKnownChannel(abilityName, abilityId) then return end

    self:StartTimer(1000, false)
end

function CMG:OnBeginCast(_, unitTag, _, abilityName, _, _, _, startTime, endTime, _, abilityId)
    if unitTag ~= "player" or not self.sv.enabled then return end
    local duration = nil
    if startTime and endTime and endTime > startTime then
        duration = endTime - startTime
    end

    -- Channeled/cast skills, including Fatecarver-style beams, should not falsely
    -- complete the visual GCD after 1 second. When ESO reports a longer begin/end
    -- cast window, the centre-collapse bar uses that full window and only prompts
    -- the next weave at the end of the channel.
    if self.sv.channelAware and duration and duration >= (self.sv.channelMinDurationMs or 1250) then
        self:StartTimer(duration, true)
    elseif self:TryStartKnownChannel(abilityName, abilityId) then
        return
    else
        self:StartTimer(1000, false)
    end
end

function CMG:OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if not self.sv.enabled then return end
    if isError or sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end

    -- Secondary channel fallback. Some channeled skills are most reliably seen
    -- as combat begin/effect events rather than EVENT_BEGIN_CAST. If the skill
    -- name matches a known beam/channel, immediately replace the 1s GCD with
    -- the configured channel duration.
    if self.sv.channelAware and abilityName then
        if result == ACTION_RESULT_BEGIN
            or result == ACTION_RESULT_EFFECT_GAINED
            or result == ACTION_RESULT_EFFECT_GAINED_DURATION
            or result == ACTION_RESULT_BEGIN_CHANNEL then
            if self:TryStartKnownChannel(abilityName, abilityId) then
                return
            end
        end
    end

    -- In dungeon/trial Lite Mode, keep channel fallback above, but stop all Light Attack
    -- tracking work and hide the lower feedback/streak UI for lower raid-addon load.
    if self:IsLiteModeActive() then
        self:SetWeaveVisible(false)
        return
    end

    if abilityActionSlotType ~= ACTION_SLOT_TYPE_LIGHT_ATTACK and abilityActionSlotType ~= ACTION_SLOT_TYPE_WEAPON_ATTACK then return end

    if result == ACTION_RESULT_DAMAGE
        or result == ACTION_RESULT_CRITICAL_DAMAGE
        or result == ACTION_RESULT_EFFECT_GAINED then
        local t = Now()
        if self.lastLightAttackEvent ~= t then
            self.lastLightAttackEvent = t
            self:HandleLightAttack(t)
        end
    end
end

function CMG:RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, function(...) self:OnCombatState(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTION_SLOT_ABILITY_USED, function(...) self:OnActionSlotAbilityUsed(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BEGIN_CAST, function(...) self:OnBeginCast(...) end)

    EVENT_MANAGER:RegisterForEvent(self.name .. "LightAttack", EVENT_COMBAT_EVENT, function(...) self:OnCombatEvent(...) end)
    EVENT_MANAGER:AddFilterForEvent(self.name .. "LightAttack", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
end

function CMG:RegisterSettings()
    local LAM = LibAddonMenu2 or LibAddonMenu2_0
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = self.displayName,
        displayName = self.displayName,
        author = "BLKx777",
        version = "1.6.8",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(self.name .. "Options", panelData)
    LAM:RegisterOptionControls(self.name .. "Options", {
        {
            type = "checkbox",
            name = "Enable Addon",
            tooltip = "Master on/off switch. When disabled, all GCD bar, WEAVE NOW, Light Attack feedback, and streak UI elements are hidden and combat timing updates stop.",
            getFunc = function() return self.sv.enabled end,
            setFunc = function(value) self:SetAddonEnabled(value) end,
            default = self.defaults.enabled,
        },
        {
            type = "checkbox",
            name = "Lite Mode in Dungeons/Trials",
            tooltip = "When enabled, dungeon and trial instances show only the centre-collapse GCD / Perfect Weave bar. WEAVE NOW, Light Attack feedback, LA counter, and streak UI are disabled to reduce combat UI load.",
            getFunc = function() return self.sv.liteModeInstances end,
            setFunc = function(value) self.sv.liteModeInstances = value; if self.weaveNow then self.weaveNow:SetHidden(true) end; self:SetWeaveVisible(false); self:RefreshPreview() end,
            default = self.defaults.liteModeInstances,
        },
        {
            type = "checkbox",
            name = "Preview Mode",
            tooltip = "Shows the bar and weave tracker outside combat while adjusting position.",
            getFunc = function() return self.sv.preview end,
            setFunc = function(value) self.sv.preview = value; self:RefreshPreview() end,
            default = self.defaults.preview,
        },
        {
            type = "checkbox",
            name = "Hide Out of Combat",
            getFunc = function() return self.sv.hideOutOfCombat end,
            setFunc = function(value) self.sv.hideOutOfCombat = value; self:RefreshPreview() end,
            default = self.defaults.hideOutOfCombat,
        },
        {
            type = "header",
            name = "Position",
        },
        {
            type = "slider",
            name = "X Position",
            tooltip = "Moves the addon left or right from the exact centre of the screen. 0 is centred on the crosshair.",
            min = -900,
            max = 900,
            step = 1,
            getFunc = function() return self.sv.x end,
            setFunc = function(value) self.sv.x = value; self:ApplyLayout(); self:SetVisible(true); self:SetWeaveVisible(true) end,
            default = self.defaults.x,
        },
        {
            type = "slider",
            name = "Y Position",
            tooltip = "Moves the addon up or down from the exact centre of the screen. 0 is centred on the crosshair.",
            min = -520,
            max = 520,
            step = 1,
            getFunc = function() return self.sv.y end,
            setFunc = function(value) self.sv.y = value; self:ApplyLayout(); self:SetVisible(true); self:SetWeaveVisible(true) end,
            default = self.defaults.y,
        },
        {
            type = "button",
            name = "Reset Position to Centre",
            tooltip = "Returns the addon to the exact centre of the screen/crosshair. X = 0, Y = 0.",
            func = function()
                self.sv.x = 0
                self.sv.y = 0
                self:ApplyLayout()
                self:SetVisible(true)
                self:SetWeaveVisible(true)
            end,
        },
        {
            type = "header",
            name = "GCD Bar",
        },
        {
            type = "slider",
            name = "Bar Width",
            min = 180,
            max = 700,
            step = 5,
            getFunc = function() return self.sv.width end,
            setFunc = function(value) self.sv.width = value; self:RefreshPreview() end,
            default = self.defaults.width,
        },
        {
            type = "slider",
            name = "Bar Height",
            min = 12,
            max = 48,
            step = 1,
            getFunc = function() return self.sv.height end,
            setFunc = function(value) self.sv.height = value; self:RefreshPreview() end,
            default = self.defaults.height,
        },
        {
            type = "checkbox",
            name = "Show Perfect Weave Zone",
            tooltip = "Displays the centre zone where the next light attack weave should land cleanly.",
            getFunc = function() return self.sv.weaveZoneEnabled end,
            setFunc = function(value) self.sv.weaveZoneEnabled = value; self:RefreshPreview() end,
            default = self.defaults.weaveZoneEnabled,
        },
        {
            type = "slider",
            name = "Perfect Weave Zone Width",
            min = 16,
            max = 120,
            step = 2,
            getFunc = function() return self.sv.weaveZoneWidth end,
            setFunc = function(value) self.sv.weaveZoneWidth = value; self:RefreshPreview() end,
            default = self.defaults.weaveZoneWidth,
        },

        {
            type = "checkbox",
            name = "Enable Channel-Aware Timing",
            tooltip = "When ESO reports a longer cast/channel window, the bar mirrors that full channel duration instead of incorrectly completing after one second. Useful for skills such as Fatecarver.",
            getFunc = function() return self.sv.channelAware end,
            setFunc = function(value) self.sv.channelAware = value end,
            default = self.defaults.channelAware,
        },
        {
            type = "slider",
            name = "Minimum Channel Duration ms",
            tooltip = "Only ability casts longer than this value are treated as channels. Default is 1250ms so normal 1-second GCD skills are not misclassified.",
            min = 1000,
            max = 1800,
            step = 25,
            getFunc = function() return self.sv.channelMinDurationMs end,
            setFunc = function(value) self.sv.channelMinDurationMs = value end,
            default = self.defaults.channelMinDurationMs,
        },
        {
            type = "checkbox",
            name = "Show WEAVE NOW Prompt",
            tooltip = "Shows a bold WEAVE NOW prompt above the centre-collapse bar at the end of the GCD or channel window.",
            getFunc = function() return self.sv.weaveNowEnabled end,
            setFunc = function(value) self.sv.weaveNowEnabled = value; self:RefreshPreview() end,
            default = self.defaults.weaveNowEnabled,
        },
        {
            type = "slider",
            name = "WEAVE NOW Lead Time ms",
            tooltip = "How early the WEAVE NOW prompt appears before the timing window ends.",
            min = 0,
            max = 400,
            step = 10,
            getFunc = function() return self.sv.weaveNowLeadMs end,
            setFunc = function(value) self.sv.weaveNowLeadMs = value end,
            default = self.defaults.weaveNowLeadMs,
        },
        {
            type = "header",
            name = "Light Attack Tracker",
        },
        {
            type = "checkbox",
            name = "Enable Light Attack Tracker",
            getFunc = function() return self.sv.weaveTrackerEnabled end,
            setFunc = function(value) self.sv.weaveTrackerEnabled = value; self:RefreshPreview() end,
            default = self.defaults.weaveTrackerEnabled,
        },
        {
            type = "checkbox",
            name = "Show Valid LA Streak",
            tooltip = "Shows a standalone successful-weave streak count to the left of the weave tracker under the main bar.",
            getFunc = function() return self.sv.streakEnabled end,
            setFunc = function(value) self.sv.streakEnabled = value; self:RefreshPreview() end,
            default = self.defaults.streakEnabled,
        },
        {
            type = "checkbox",
            name = "Only Count Valid Weaves",
            tooltip = "The streak increases only when a light attack lands inside the active GCD/channel weave window. Missing or landing outside the window resets the streak. Channels hold the streak until the next valid LA window.",
            getFunc = function() return self.sv.streakOnlyValidWeaves end,
            setFunc = function(value) self.sv.streakOnlyValidWeaves = value end,
            default = self.defaults.streakOnlyValidWeaves,
        },
        {
            type = "slider",
            name = "Post-Window Grace ms",
            tooltip = "Small grace period after the GCD/channel ends where the light attack can still validate the streak.",
            min = 0,
            max = 500,
            step = 10,
            getFunc = function() return self.sv.weaveValidationGraceMs end,
            setFunc = function(value) self.sv.weaveValidationGraceMs = value end,
            default = self.defaults.weaveValidationGraceMs,
        },
        {
            type = "dropdown",
            name = "Tracker Display Mode",
            choices = {"compact", "gap", "rate"},
            getFunc = function() return self.sv.weaveTrackerMode end,
            setFunc = function(value) self.sv.weaveTrackerMode = value; self:UpdateWeaveDisplay() end,
            default = self.defaults.weaveTrackerMode,
        },
        {
            type = "slider",
            name = "Good Weave Threshold ms",
            min = 800,
            max = 1300,
            step = 10,
            getFunc = function() return self.sv.weaveTrackerGoodMs end,
            setFunc = function(value) self.sv.weaveTrackerGoodMs = value end,
            default = self.defaults.weaveTrackerGoodMs,
        },
        {
            type = "slider",
            name = "Late Weave Threshold ms",
            min = 1200,
            max = 2200,
            step = 10,
            getFunc = function() return self.sv.weaveTrackerLateMs end,
            setFunc = function(value) self.sv.weaveTrackerLateMs = value end,
            default = self.defaults.weaveTrackerLateMs,
        },
    })
end

function CMG:ApplyPositionMigration()
    -- Position is now slider-only and always anchored from screen centre.
    -- Fresh installs start at X = 0, Y = 0. Older untouched defaults are migrated
    -- to centre, while deliberate custom positions are preserved.
    if self.sv.x == nil then self.sv.x = 0 end
    if self.sv.y == nil then self.sv.y = 0 end

    if self.sv.positionDefaultMigrated ~= true then
        if self.sv.x == 0 and (self.sv.y == 210 or self.sv.y == nil) then
            self.sv.x = 0
            self.sv.y = 0
        end
        self.sv.positionDefaultMigrated = true
    end

    if self.sv.positionSliderCentreMigrated ~= true then
        -- 1.6.9 confirms centre-screen slider positioning as the only positioning method.
        -- No joystick/mouse reposition state is used by this build.
        if self.sv.x == nil then self.sv.x = 0 end
        if self.sv.y == nil then self.sv.y = 0 end
        self.sv.positionSliderCentreMigrated = true
    end
end



function CMG:ApplyDefaultTuningMigration()
    -- Version 1.6.8 adds abilityId-first channel detection and DK breath channel fallbacks.
    if self.sv.knownChannelAbilityIds == nil then
        self.sv.knownChannelAbilityIds = self.defaults.knownChannelAbilityIds
    end
    self.sv.knownChannelSkills = self.sv.knownChannelSkills or {}
    local channelAdds = {
        ["engulfing dragonfire"] = 4800,
        ["dragonfire"] = 4800,
        ["dragon fire"] = 4800,
        ["flame breath"] = 4800,
        ["fiery breath"] = 4800,
    }
    for name, duration in pairs(channelAdds) do
        if self.sv.knownChannelSkills[name] == nil then
            self.sv.knownChannelSkills[name] = duration
        end
    end

    -- Version 1.6.6 raises the default channel threshold and WEAVE NOW lead time.
    -- Existing users on the previous defaults are migrated; custom values are preserved.
    if self.sv.defaultTuning166Migrated ~= true then
        if self.sv.channelMinDurationMs == nil or self.sv.channelMinDurationMs == 1150 then
            self.sv.channelMinDurationMs = self.defaults.channelMinDurationMs
        end
        if self.sv.weaveNowLeadMs == nil or self.sv.weaveNowLeadMs == 180 then
            self.sv.weaveNowLeadMs = self.defaults.weaveNowLeadMs
        end
        self.sv.defaultTuning166Migrated = true
    end
end

function CMG:ApplyCentreCollapseMigration()
    -- GCD Weave Timer is now centre-collapse only. Older saved variables
    -- that disabled centre-collapse are forced back on.
    self.sv.collapseToCentre = true
end

function CMG:ApplyLiteModeMigration()
    -- Version 1.6.7 adds optional automatic Lite Mode for group instances.
    -- Default is OFF so existing users keep the full tracker unless they opt in.
    if self.sv.liteModeInstances == nil then
        self.sv.liteModeInstances = false
    end
end

function CMG:ApplyValidWeavesDefaultMigration()
    -- Version 1.6.4 changes the default so normal LA tracking is permissive.
    -- Players can still enable strict valid-weave streak counting from settings.
    if self.sv.validWeavesDefaultMigrated ~= true then
        self.sv.streakOnlyValidWeaves = false
        self.sv.validWeavesDefaultMigrated = true
    end
end

function CMG:Init()
    self.sv = ZO_SavedVars:NewAccountWide("GCDWeaveTimerSavedVars", self.savedVersion, nil, self.defaults)
    self:ApplyPositionMigration()
    self:ApplyValidWeavesDefaultMigration()
    self:ApplyDefaultTuningMigration()
    self:ApplyCentreCollapseMigration()
    self:ApplyLiteModeMigration()
    self:CreateUI()
    self:ApplyLayout()
    self:RegisterSettings()
    self:RegisterEvents()
    self:SetVisible(false)
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= CMG.name then return end
    EVENT_MANAGER:UnregisterForEvent(CMG.name, EVENT_ADD_ON_LOADED)
    CMG:Init()
end

EVENT_MANAGER:RegisterForEvent(CMG.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
