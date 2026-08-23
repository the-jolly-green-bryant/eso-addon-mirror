SugasTestZoneProject = SugasTestZoneProject or {}
local Project = SugasTestZoneProject

Project.HUD = Project.HUD or {}
local HUD = Project.HUD

local function FormatSeconds(totalSeconds)
    totalSeconds = math.max(0, tonumber(totalSeconds) or 0)
    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = totalSeconds % 60
    if hours > 0 then
        return string.format("%d:%02d:%02d", hours, minutes, seconds)
    end
    return string.format("%02d:%02d", minutes, seconds)
end

-- Countdown clocks use ceil so they do not visually reach zero early.
local function FormatCountdownMs(ms)
    ms = math.max(0, tonumber(ms) or 0)
    return FormatSeconds(math.ceil(ms / 1000))
end

-- SURVIVED is elapsed time, so floor it. Paired with ceil on the countdown
-- clocks this keeps the visible clocks aligned to the same second boundary.
local function FormatElapsedMs(ms)
    ms = math.max(0, tonumber(ms) or 0)
    return FormatSeconds(math.floor(ms / 1000))
end

local function GetNowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        return GetFrameTimeMilliseconds()
    end
    if type(GetGameTimeMilliseconds) == "function" then
        return GetGameTimeMilliseconds()
    end
    if type(GetTimeStamp) == "function" then
        return GetTimeStamp() * 1000
    end
    return 0
end

function HUD:Initialize()
    if self.controls then return end
    local wm = WINDOW_MANAGER
    if not wm or not GuiRoot then return end

    local root = wm:CreateTopLevelWindow("SugasTestZoneWinterHarvestHUD")
    root:SetDimensions(760, 205)
    root:SetAnchor(TOP, GuiRoot, TOP, 0, 105)
    root:SetHidden(true)
    root:SetMouseEnabled(false)
    if root.SetDrawTier then root:SetDrawTier(DT_HIGH) end
    if root.SetDrawLayer then root:SetDrawLayer(DL_OVERLAY) end
    if root.SetDrawLevel then root:SetDrawLevel(1000) end

    local backdrop = wm:CreateControl("$(parent)Backdrop", root, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, root, TOPLEFT, 30, -8)
    backdrop:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, -30, 8)
    backdrop:SetCenterColor(0, 0, 0, 0.68)
    backdrop:SetEdgeColor(0, 0, 0, 0.30)
    backdrop:SetEdgeTexture(nil, 1, 1, 1)

    local title = wm:CreateControl("$(parent)Title", root, CT_LABEL)
    title:SetFont("ZoFontGamepadBold34")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetAnchor(TOP, root, TOP, 0, 0)
    title:SetDimensions(760, 40)

    local harvest = wm:CreateControl("$(parent)Harvest", root, CT_LABEL)
    harvest:SetFont("ZoFontGamepad42")
    harvest:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    harvest:SetAnchor(TOP, title, BOTTOM, 0, -3)
    harvest:SetDimensions(760, 50)

    local clocks = wm:CreateControl("$(parent)Clocks", root, CT_LABEL)
    clocks:SetFont("ZoFontGamepad27")
    clocks:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    clocks:SetAnchor(TOP, harvest, BOTTOM, 0, 0)
    clocks:SetDimensions(760, 34)

    local status = wm:CreateControl("$(parent)Status", root, CT_LABEL)
    status:SetFont("ZoFontGamepad22")
    status:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    status:SetAnchor(TOP, clocks, BOTTOM, 0, 1)
    status:SetDimensions(760, 30)

    local effect = wm:CreateControl("$(parent)Effect", root, CT_LABEL)
    effect:SetFont("ZoFontGamepad22")
    effect:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    effect:SetAnchor(TOP, status, BOTTOM, 0, 0)
    effect:SetDimensions(760, 32)

    self.controls = {
        root = root,
        title = title,
        harvest = harvest,
        clocks = clocks,
        status = status,
        effect = effect,
    }
    self:Refresh()
end

function HUD:Hide()
    if self.controls and self.controls.root then
        self.controls.root:SetHidden(true)
    end
end

function HUD:Refresh(nowMs)
    if not self.controls then self:Initialize() end
    if not self.controls then return end

    local state = Project.State
    local root = self.controls.root

    if state:IsCountdown() then
        local current = tonumber(nowMs) or GetNowMs()
        local remaining = math.max(0, (state.countdownEndsMs or current) - current)
        local number = math.max(1, math.ceil(remaining / 1000))
        self.controls.title:SetText("WINTER'S HARVEST")
        self.controls.harvest:SetText("STARTING IN " .. tostring(number))
        self.controls.clocks:SetText(string.format(
            "HARVEST %02d:00   •   GATHER 00:%02d",
            math.floor(Project.Config.startingSeconds / 60),
            Project.Config.gatherWindowSeconds))
        self.controls.status:SetText("SURVIVED 00:00")
        self.controls.effect:SetText("Gather any resource node to reset GATHER.")
        root:SetHidden(false)
        return
    end

    if state:IsRunning() then
        local current = tonumber(nowMs) or GetNowMs()
        local harvestRemaining = Project.WinterHarvest:GetRemainingMs()
        local gatherRemaining = Project.WinterHarvest:GetGatherRemainingMs(current)
        local survived = Project.WinterHarvest:GetElapsedMs(current)

        self.controls.title:SetText("WINTER'S HARVEST")
        self.controls.harvest:SetText("HARVEST  " .. FormatCountdownMs(harvestRemaining))
        self.controls.clocks:SetText(string.format(
            "GATHER %s   •   SURVIVED %s",
            FormatCountdownMs(gatherRemaining), FormatElapsedMs(survived)))
        self.controls.status:SetText(string.format(
            "NODES %d   •   MISSED GATHERS %d",
            state.nodesGathered or 0, state.gatherPenalties or 0))

        local effectText = tostring(state.lastEffectText or "")
        if state.lastItemName and state.lastItemName ~= "" then
            effectText = effectText .. "   •   " .. tostring(state.lastItemName)
        end
        self.controls.effect:SetText(effectText)
        root:SetHidden(false)
        return
    end

    if state.phase == "finished" and state.lastResult then
        local result = state.lastResult
        self.controls.title:SetText("TIME'S UP")
        self.controls.harvest:SetText("SURVIVED  " .. FormatElapsedMs(result.durationMs))
        self.controls.clocks:SetText(string.format(
            "NODES %d   •   MISSED GATHERS %d",
            result.nodes or 0, result.gatherPenalties or 0))
        self.controls.status:SetText(result.newBest and "NEW PERSONAL BEST" or "WINTER'S HARVEST COMPLETE")
        self.controls.effect:SetText(tostring(result.reason or "Run complete"))
        root:SetHidden(false)
        return
    end

    root:SetHidden(true)
end

function HUD:OnHarvestCountdownStarted(now) self:Refresh(now) end
function HUD:OnHarvestRunStarted(now) self:Refresh(now) end
function HUD:OnHarvestTick(now) self:Refresh(now) end
function HUD:OnHarvestNodeGathered(_, _, now) self:Refresh(now) end
function HUD:OnHarvestGatherPenalty(_, _, now) self:Refresh(now) end
function HUD:OnHarvestRunCancelled() self:Hide() end

function HUD:ShowFinishAlert(result)
    if type(ZO_Alert) ~= "function" then return end

    local soundId = nil
    if SOUNDS then
        soundId = SOUNDS.ACHIEVEMENT_AWARDED or SOUNDS.QUEST_COMPLETED or SOUNDS.POSITIVE_CLICK
    end

    local text = string.format(
        "Winter's Harvest complete — survived %s — %d nodes",
        FormatElapsedMs(result and result.durationMs or 0),
        tonumber(result and result.nodes) or 0
    )
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, soundId, text)
end

function HUD:OnHarvestRunFinished(result, now)
    self:Refresh(now)
    self:ShowFinishAlert(result)

    self.hideToken = (tonumber(self.hideToken) or 0) + 1
    local token = self.hideToken
    if zo_callLater then
        zo_callLater(function()
            if HUD.hideToken == token and Project.State.phase == "finished" then
                HUD:Hide()
            end
        end, 10000)
    end
end
function HUD:Shutdown() self:Hide() end

Project.Controller:RegisterModule("HUD", HUD)
