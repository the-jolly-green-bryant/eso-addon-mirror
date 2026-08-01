TamrielRaces = TamrielRaces or {}
local TR = TamrielRaces

TR.HUD = TR.HUD or {}
local HUD = TR.HUD

function HUD:Initialize()
    if self.controls then return end
    local wm = WINDOW_MANAGER
    if not wm or not GuiRoot then return end

    local root = wm:CreateTopLevelWindow("TamrielRacesHUD")
    root:SetDimensions(700, 120)
    root:SetAnchor(TOP, GuiRoot, TOP, 0, 120)
    root:SetHidden(true)
    root:SetMouseEnabled(false)
    if root.SetDrawTier then root:SetDrawTier(DT_HIGH) end
    if root.SetDrawLayer then root:SetDrawLayer(DL_OVERLAY) end
    if root.SetDrawLevel then root:SetDrawLevel(1000) end

    local backdrop = wm:CreateControl("$(parent)Backdrop", root, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, root, TOPLEFT, 35, -8)
    backdrop:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, -35, 8)
    backdrop:SetCenterColor(0, 0, 0, 0.55)
    backdrop:SetEdgeColor(0, 0, 0, 0.25)
    backdrop:SetEdgeTexture(nil, 1, 1, 1)

    local title = wm:CreateControl("$(parent)Title", root, CT_LABEL)
    title:SetFont("ZoFontGamepadBold34")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetAnchor(TOP, root, TOP, 0, 0)
    title:SetDimensions(700, 45)

    local target = wm:CreateControl("$(parent)Target", root, CT_LABEL)
    target:SetFont("ZoFontGamepad34")
    target:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    target:SetAnchor(TOP, title, BOTTOM, 0, 2)
    target:SetDimensions(700, 42)

    local timer = wm:CreateControl("$(parent)Timer", root, CT_LABEL)
    timer:SetFont("ZoFontGamepad27")
    timer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    timer:SetAnchor(TOP, target, BOTTOM, 0, 0)
    timer:SetDimensions(700, 35)

    self.controls = { root = root, title = title, target = target, timer = timer }
    self:Refresh()
end

function HUD:Hide()
    if self.controls and self.controls.root then
        self.controls.root:SetHidden(true)
    end
end

function HUD:Refresh()
    if not self.controls then self:Initialize() end
    if not self.controls then return end

    local state = TR.State
    local current = state.route and state.route[state.currentIndex]
    local root = self.controls.root

    if state.countdownActive then
        local remaining = math.max(0, (state.countdownEndsMs or TR.Util.NowMs()) - TR.Util.NowMs())
        local number = math.ceil(remaining / 1000)
        if number > 5 then number = 5 end
        self.controls.title:SetText(number > 0 and tostring(number) or "GO!")
        self.controls.target:SetText(state.route[2] and ("FIRST TARGET: " .. tostring(state.route[2].name)) or "")
        self.controls.timer:SetText("Map closes at GO")
        root:SetHidden(false)
        return
    end

    if state.waitingAtStart and current then
        self.controls.title:SetText(state.startReady and "START READY" or "GO TO START")
        self.controls.target:SetText(tostring(current.name))
        self.controls.timer:SetText(state.startReady
            and "Press X in STARS to start the countdown"
            or "Fast travel is allowed before the race starts")
        root:SetHidden(false)
        return
    end

    if state.running and current then
        local elapsed = TR.Util.NowMs() - (state.startTimeMs or TR.Util.NowMs())
        if state.currentIndex >= #state.route then
            self.controls.title:SetText("FINAL CHECKPOINT")
            self.controls.target:SetText(state.finalCheckpointReady
                and "PRESS X TO FINISH"
                or ("ACTIVATE: " .. tostring(current.name)))
        else
            self.controls.title:SetText(string.format("CHECKPOINT %d / %d", state.currentIndex - 1, math.max(1, #state.route - 1)))
            self.controls.target:SetText("NEXT: " .. tostring(current.name))
        end
        -- Keep integrity decisions hidden until the finish line.
        self.controls.timer:SetText(TR.Util.FormatMs(elapsed))
        root:SetHidden(false)
        return
    end

    if state.lastResult then
        if state.lastResult.forfeited then
            self.controls.title:SetText("RACE FORFEITED")
            self.controls.target:SetText(tostring(state.lastResult.reason or "Fast travel detected"))
            self.controls.timer:SetText("Recorded time: " .. TR.Util.FormatMs(state.lastResult.time))
        else
            self.controls.title:SetText("RACE COMPLETE")
            self.controls.target:SetText(tostring(state.lastResult.zone or ""))
            self.controls.timer:SetText(TR.Util.FormatMs(state.lastResult.time))
        end
        root:SetHidden(false)
        return
    end

    root:SetHidden(true)
end

function HUD:OnRouteCreated() self:Refresh() end
function HUD:OnCountdownStarted() self:Refresh() end
function HUD:OnRaceStarted() self:Refresh() end
function HUD:OnRaceTick() self:Refresh() end
function HUD:OnStartReadinessChanged() self:Refresh() end
function HUD:OnCheckpointAdvanced() self:Refresh() end
function HUD:OnFinalCheckpointReadinessChanged() self:Refresh() end
function HUD:OnRaceFinished()
    self:Refresh()
    if zo_callLater then
        zo_callLater(function() HUD:Hide() end, 5000)
    end
end
function HUD:ShutdownRace() self:Hide() end

TR.Controller:RegisterModule("HUD", HUD)
