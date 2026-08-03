local PvPerformance = PvPerformance
local Dueling = PvPerformance.Modules.Dueling
local Private = PvPerformance.Private
setfenv(1, setmetatable({
    PvPerformance = PvPerformance,
    Dueling = Dueling,
    Private = Private,
}, {
    __index = function(_, key)
        local value = Private[key]
        if value ~= nil then
            return value
        end
        return _G[key]
    end,
}))
function Dueling:SaveWindowPosition()
    if not self.ui or not self.ui.window then
        return
    end

    self.savedVars.window.left = self.ui.window:GetLeft()
    self.savedVars.window.top = self.ui.window:GetTop()
    self.savedVars.window.width = self.ui.window:GetWidth()
    self.savedVars.window.height = self.ui.window:GetHeight()
end

function Dueling:ApplyUIScale()
    if not self.ui or not self.ui.window or not self.ui.window.SetScale then
        return
    end
    self.ui.window:SetScale(self:GetSettings().uiScale)
    -- Top-level controls scale visually, but their manually sized children
    -- retain logical dimensions. Reflow them immediately after a scale change
    -- so the journal grid reaches the same right edge as its backdrop.
    if self.ui.rows then
        self:ApplyWindowLayout()
    end
end

function Dueling:CycleUIScale()
    local settings = self:GetSettings()
    local selectedIndex = 1
    for index, value in ipairs(UI_SCALE_OPTIONS) do
        if math.abs(value - settings.uiScale) < 0.02 then
            selectedIndex = index
            break
        end
    end
    selectedIndex = selectedIndex % #UI_SCALE_OPTIONS + 1
    settings.uiScale = UI_SCALE_OPTIONS[selectedIndex]
    self:ApplyUIScale()
    self:RefreshUI()
end

function Dueling:CycleEffectIntensity()
    local settings = self:GetSettings()
    local selectedIndex = 1
    for index, option in ipairs(EFFECT_INTENSITY_OPTIONS) do
        if math.abs(option.value - settings.effectIntensity) < 0.02 then
            selectedIndex = index
            break
        end
    end
    selectedIndex = selectedIndex % #EFFECT_INTENSITY_OPTIONS + 1
    settings.effectIntensity = EFFECT_INTENSITY_OPTIONS[selectedIndex].value
    self:RefreshUI()
end

function Dueling:ToggleDamageRatingAdjustment()
    local settings = self:GetSettings()
    settings.damageRatingEnabled = not settings.damageRatingEnabled
    -- Replaying makes the displayed rating and every stored rating delta
    -- agree with the new setting, rather than mixing old and new rules.
    self:RebuildRankingFromHistory()
    self:RebuildClassRankingsFromHistory()
    self.testRatingState = nil
    self.testClassRatingState = nil
    self.testSandbox = nil
    Print(settings.damageRatingEnabled and "Damage rating adjustment enabled; ratings rebuilt." or "Damage rating adjustment disabled; ratings rebuilt.")
    self:RefreshUI()
end

function Dueling:IsDuelTrackingEnabled()
    return self:GetSettings().duelTrackingEnabled ~= false
end

function Dueling:ToggleDuelTracking()
    local settings = self:GetSettings()
    settings.duelTrackingEnabled = not settings.duelTrackingEnabled
    if not settings.duelTrackingEnabled then
        -- Build-testing mode must discard any duel already in progress and
        -- immediately remove its transient combat/latency listeners.
        self:UnregisterDuelTrackingEvents()
        self:StopLatencySampling()
        local Analytics = PvPerformance.Modules.Analytics
        if Analytics and Analytics.CancelDuel then
            Analytics:SafeCall("CancelDuel")
        end
        self.currentDuelStartMS = nil
        self.currentDuelTracking = nil
    end
    Print(settings.duelTrackingEnabled
        and "Duel tracking enabled. New duels will update records and ratings."
        or "Duel tracking paused. Existing records remain visible; new duels will be ignored.")
    self:RefreshUI()
end

function Dueling:ApplyWindowLayout()
    if not self.ui or not self.ui.window then
        return
    end

    local scale = self.ui.window.GetScale and self.ui.window:GetScale() or 1
    local width = self.ui.window:GetWidth() * scale
    local height = self.ui.window:GetHeight() * scale
    local rowWidth = math.max(650, width - MAIN_CONTENT_LEFT - 22)
    self.ui.rowWidth = rowWidth
    self.ui.headerDivider:SetDimensions(width, 2)
    self.ui.summaryRailDivider:SetDimensions(2, math.max(1, height - SUMMARY_RAIL_DIVIDER_TOP - 18))
    for _, row in ipairs(self.ui.rows) do
        row:SetDimensions(rowWidth, JOURNAL_ROW_HEIGHT)
    end

    if self.ui.statisticsPanel then
        local metricWidth = math.floor((rowWidth - 24) / 5)
        local detailMetricWidth = math.floor((rowWidth - 18) / 4)
        local leaderboardWidth = math.floor((rowWidth - 12) / 2)
        local metricTextWidth = math.max(110, metricWidth - 8)
        local detailTextWidth = math.max(150, detailMetricWidth - 8)
        local metricCaptionScale = metricWidth < 175 and 0.82 or 0.88
        local detailCaptionScale = detailMetricWidth < 200 and 0.80 or 0.86
        self.ui.statisticsPanel:SetDimensions(rowWidth, 630)
        for _, card in ipairs(self.ui.statMetricCards) do
            card:SetDimensions(metricWidth, 88)
            card.caption:SetDimensions(metricTextWidth, 20)
            card.caption:SetScale(metricCaptionScale)
            card.value:SetDimensions(metricTextWidth, 24)
            card.detail:SetDimensions(metricTextWidth, 22)
        end
        for _, card in ipairs(self.ui.statDetailCards) do
            card:SetDimensions(detailMetricWidth, 88)
            card.caption:SetDimensions(detailTextWidth, 20)
            card.caption:SetScale(detailCaptionScale)
            card.value:SetDimensions(detailTextWidth, 24)
            card.detail:SetDimensions(detailTextWidth, 22)
        end
        self.ui.dangerousBoard:SetDimensions(leaderboardWidth, 218)
        self.ui.easiestBoard:SetDimensions(leaderboardWidth, 218)
        self.ui.easiestBoard:ClearAnchors()
        self.ui.easiestBoard:SetAnchor(TOPLEFT, self.ui.dangerousBoard, TOPRIGHT, 12, 0)

        self.ui.statisticsTrendGraph:SetDimensions(rowWidth, 176)
        self.ui.statisticsTrendGraph.plot:SetDimensions(math.max(180, rowWidth - 104), 124)

        self.ui.opponentPerformancePanel:SetDimensions(rowWidth, DETAIL_PERFORMANCE_HEIGHT)
        local graphWidth = math.max(300, math.floor(rowWidth * 0.52))
        self.ui.opponentPerformanceGraph:SetDimensions(graphWidth, 178)
        self.ui.opponentPerformanceGraph.plot:SetDimensions(math.max(180, graphWidth - 104), 126)
        local performanceTextWidth = math.max(220, rowWidth - graphWidth - 34)
        self.ui.opponentPerformanceTitle:SetDimensions(performanceTextWidth, 28)
        for _, line in ipairs(self.ui.opponentPerformanceLines) do
            line:SetDimensions(performanceTextWidth, 22)
        end
        self.ui.opponentPerformanceLastFive:SetDimensions(performanceTextWidth, 22)

        if self.ui.duelDetailPanel then
            local detailMargin = 12
            local cardGap = 10
            local summaryRowWidth = rowWidth - detailMargin * 2
            local summaryCardWidth = math.floor((summaryRowWidth - cardGap * 3) / 4)
            local summaryCardHeight = 128
            local breakdownWidth = summaryRowWidth
            local breakdownHeight = 320
            local breakdownGap = 12
            local detailHeight = 80 + summaryCardHeight + breakdownGap + breakdownHeight + breakdownGap + breakdownHeight + 12
            self.ui.duelDetailPanel:SetDimensions(rowWidth, detailHeight)
            -- Reserve the report header's right edge for GO TO ANALYTICS so
            -- long opponent metadata cannot render beneath the button.
            self.ui.duelDetailTitle:SetDimensions(math.max(360, rowWidth - 238), 26)
            self.ui.duelDetailSubtitle:SetDimensions(math.max(360, rowWidth - 238), 20)
            self.ui.duelDetailNotice:SetDimensions(math.max(360, rowWidth - 28), 18)
            self.ui.duelDetailSummaryRow:SetDimensions(summaryRowWidth, summaryCardHeight)
            for index, card in ipairs(self.ui.duelDetailSummaryCards) do
                card:ClearAnchors()
                card:SetAnchor(TOPLEFT, self.ui.duelDetailSummaryRow, TOPLEFT, (index - 1) * (summaryCardWidth + cardGap), 0)
                card:SetDimensions(summaryCardWidth, summaryCardHeight)
                card.caption:SetDimensions(summaryCardWidth - 20, 22)
                if card.leftHeader then
                    local columnWidth = math.floor((summaryCardWidth - 24) / 2)
                    -- Each heading/value pair shares the exact same column
                    -- anchor and width. This prevents font metrics from
                    -- making TOTAL and DPS look offset from their values.
                    card.leftHeader:ClearAnchors()
                    card.leftHeader:SetAnchor(TOPLEFT, card, TOPLEFT, 10, 46)
                    card.leftHeader:SetDimensions(columnWidth, 20)
                    card.rightHeader:ClearAnchors()
                    card.rightHeader:SetAnchor(TOPRIGHT, card, TOPRIGHT, -10, 46)
                    card.rightHeader:SetDimensions(columnWidth, 20)
                    card.leftValue:ClearAnchors()
                    card.leftValue:SetAnchor(TOP, card.leftHeader, BOTTOM, 0, 3)
                    card.leftValue:SetDimensions(columnWidth, 30)
                    card.rightValue:ClearAnchors()
                    card.rightValue:SetAnchor(TOP, card.rightHeader, BOTTOM, 0, 3)
                    card.rightValue:SetDimensions(columnWidth, 30)
                    card.divider:ClearAnchors()
                    card.divider:SetAnchor(TOP, card, TOP, 0, 44)
                    card.divider:SetDimensions(1, 58)
                    card.note:SetDimensions(summaryCardWidth - 20, 20)
                else
                    card.value:SetDimensions(summaryCardWidth - 20, 32)
                    card.note:SetDimensions(summaryCardWidth - 20, 20)
                end
            end

            local doneBoard = self.ui.duelDetailDamageDoneBoard
            local takenBoard = self.ui.duelDetailDamageTakenBoard
            doneBoard:SetDimensions(breakdownWidth, breakdownHeight)
            takenBoard:SetDimensions(breakdownWidth, breakdownHeight)
            doneBoard:ClearAnchors()
            doneBoard:SetAnchor(TOPLEFT, self.ui.duelDetailSummaryRow, BOTTOMLEFT, 0, breakdownGap)
            takenBoard:ClearAnchors()
            takenBoard:SetAnchor(TOPLEFT, doneBoard, BOTTOMLEFT, 0, breakdownGap)
            for _, board in ipairs({ doneBoard, takenBoard }) do
                local numericWidths = {
                    percent = 52,
                    dps = 82,
                    damage = 94,
                    critHits = 84,
                    critPercent = 66,
                    min = 82,
                    avg = 82,
                    max = 82,
                }
                local numericWidth = 0
                for _, key in ipairs(board.numericColumnOrder) do
                    numericWidth = numericWidth + numericWidths[key]
                end
                local columnX = 10
                local abilityWidth = math.max(190, breakdownWidth - 28 - numericWidth)
                board.caption:SetDimensions(breakdownWidth - 20, 22)
                board.headers.name:ClearAnchors()
                board.headers.name:SetAnchor(TOPLEFT, board, TOPLEFT, columnX, 35)
                board.headers.name:SetDimensions(abilityWidth, 18)
                board.headers.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
                columnX = columnX + abilityWidth
                for _, key in ipairs(board.numericColumnOrder) do
                    local widthForColumn = numericWidths[key]
                    local header = board.headers[key]
                    header:ClearAnchors()
                    header:SetAnchor(TOPLEFT, board, TOPLEFT, columnX, 35)
                    header:SetDimensions(widthForColumn, 18)
                    header:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
                    columnX = columnX + widthForColumn
                end
                board.rule:SetDimensions(breakdownWidth - 20, 1)
                board.empty:SetDimensions(breakdownWidth - 20, 20)
                board.abilityTextWidth = abilityWidth - 26
                board.scrollTrack:ClearAnchors()
                board.scrollTrack:SetAnchor(TOPRIGHT, board, TOPRIGHT, -5, 61)
                board.scrollTrack:SetDimensions(4, math.max(1, breakdownHeight - 74))
                for rowIndex, row in ipairs(board.rows) do
                    local rowY = 61 + (rowIndex - 1) * board.rowHeight
                    row.icon:ClearAnchors()
                    row.icon:SetAnchor(TOPLEFT, board, TOPLEFT, 10, rowY + 2)
                    row.icon:SetDimensions(20, 20)
                    row.name:ClearAnchors()
                    row.name:SetAnchor(TOPLEFT, board, TOPLEFT, 34, rowY)
                    row.name:SetDimensions(abilityWidth - 26, board.rowHeight)
                    row.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
                    local rowColumnX = 10 + abilityWidth
                    for _, key in ipairs(board.numericColumnOrder) do
                        local widthForColumn = numericWidths[key]
                        local label = row[key]
                        label:ClearAnchors()
                        label:SetAnchor(TOPLEFT, board, TOPLEFT, rowColumnX, rowY)
                        label:SetDimensions(widthForColumn, board.rowHeight)
                        label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
                        rowColumnX = rowColumnX + widthForColumn
                    end
                end
            end
        end

        local nameWidth = math.max(125, leaderboardWidth - 194)
        for _, board in ipairs({ self.ui.dangerousBoard, self.ui.easiestBoard }) do
            for _, nameLabel in ipairs(board.names) do
                nameLabel:SetDimensions(nameWidth, 22)
                nameLabel.maximumCharacters = math.max(14, math.floor(nameWidth / 7.4))
            end
            for _, recordLabel in ipairs(board.records) do
                recordLabel:SetDimensions(104, 22)
            end
            for _, rateLabel in ipairs(board.rates) do
                rateLabel:SetDimensions(58, 22)
            end
        end
    end

    if self.ui.settingsPanel then
        self.ui.settingsPanel:SetDimensions(rowWidth, 590)
        self.ui.settingsIntro:SetDimensions(math.max(350, rowWidth - 8), 24)
        self.ui.settingsNotesHelp:SetDimensions(math.max(350, rowWidth - 8), 24)
        for _, row in ipairs(self.ui.settingsRows) do
            row:SetDimensions(rowWidth, 94)
            row.detail:SetDimensions(math.max(240, rowWidth - 222), 48)
        end
    end

    if self.ui.commandsPanel then
        self.ui.commandsPanel:SetDimensions(rowWidth, 690)
        self.ui.commandsIntro:SetDimensions(math.max(420, rowWidth - 8), 24)
        for _, row in ipairs(self.ui.commandRows) do
            row:SetDimensions(rowWidth, 42)
            local commandWidth = math.min(260, math.max(220, math.floor(rowWidth * 0.33)))
            row.command:SetDimensions(commandWidth, 32)
            row.detail:SetDimensions(math.max(220, rowWidth - commandWidth - 34), 32)
        end
    end
end

function Dueling:SetTierCardGlow(card, rank)
    local sparkleLevels = { ["B-"] = 1, ["B"] = 2, ["B+"] = 3 }
    local emberLevels = { ["S-"] = 1, ["S"] = 2, ["S+"] = 3 }
    local rayBurstLevels = { ["S-"] = 1, ["S"] = 2, ["S+"] = 3 }
    local moteLevels = {}
    local cometLevels = { ["A-"] = 1, ["A"] = 2, ["A+"] = 3 }
    local pulseRingLevels = { ["C-"] = 1, ["C"] = 2, ["C+"] = 3 }
    local sparkleLevel = rank and sparkleLevels[rank.name] or 0
    local emberLevel = rank and emberLevels[rank.name] or 0
    local rayBurstLevel = rank and rayBurstLevels[rank.name] or 0
    local moteLevel = rank and moteLevels[rank.name] or 0
    local cometLevel = rank and cometLevels[rank.name] or 0
    local pulseRingLevel = rank and pulseRingLevels[rank.name] or 0
    local effectLevel = math.max(sparkleLevel, emberLevel, moteLevel, cometLevel, pulseRingLevel)
    local effectIntensity = self:GetSettings().effectIntensity

    if effectLevel == 0 then
        card.isElite = false
        card.glowColor = nil
        card.showEmbers = false
        card.showRayBurst = false
        card.showLightning = false
        card.showMotes = false
        card.showCometTrail = false
        card.showPulseRings = false
        card.emberLevel = 0
        card.rayBurstLevel = 0
        card.sparkleLevel = 0
        card.moteLevel = 0
        card.cometLevel = 0
        card.pulseRingLevel = 0
        card.effectIntensity = 1
        card.glowOuter:SetHidden(true)
        card.glowInner:SetHidden(true)
        for _, ember in ipairs(card.embers) do
            ember:SetHidden(true)
        end
        for _, sparkle in ipairs(card.sparkles) do
            sparkle:SetHidden(true)
        end
        for _, mote in ipairs(card.motes) do
            mote:SetHidden(true)
        end
        for _, comet in ipairs(card.cometTrail) do
            comet:SetHidden(true)
        end
        for _, ring in ipairs(card.pulseRings) do
            ring:SetHidden(true)
        end
        if card.rayBurst then
            card.rayBurst:SetHidden(true)
        end
        card.tier:SetScale(card.tierScale or TIER_LABEL_SCALE)
        card.tier:SetAlpha(1)
        card.box:SetCenterColor(0.02, 0.02, 0.03, 1)
        return
    end

    -- The card, its glow, and its optional visual effect use the same tier
    -- colour. This keeps red A tiers, orange B tiers, green C tiers, and the
    -- three distinct gold S tiers legible even while an effect is active.
    local red, green, blue = rank.color[1], rank.color[2], rank.color[3]
    card.isElite = true
    card.glowColor = { red, green, blue }
    card.showEmbers = emberLevel > 0
    card.showRayBurst = rayBurstLevel > 0
    card.showLightning = sparkleLevel > 0
    card.showMotes = moteLevel > 0
    card.showCometTrail = cometLevel > 0
    card.showPulseRings = pulseRingLevel > 0
    card.emberLevel = emberLevel
    card.rayBurstLevel = rayBurstLevel
    card.sparkleLevel = sparkleLevel
    card.moteLevel = moteLevel
    card.cometLevel = cometLevel
    card.pulseRingLevel = pulseRingLevel
    card.effectIntensity = effectIntensity
    card.glowOuter:SetHidden(false)
    card.glowInner:SetHidden(false)
    card.glowOuter:SetCenterColor(red, green, blue, math.min(0.36, (0.07 + effectLevel * 0.05) * effectIntensity))
    card.glowOuter:SetEdgeColor(red, green, blue, math.min(1, (0.35 + effectLevel * 0.18) * effectIntensity))
    card.glowInner:SetCenterColor(red, green, blue, math.min(0.42, (0.10 + effectLevel * 0.05) * effectIntensity))
    card.glowInner:SetEdgeColor(red, green, blue, math.min(1, (0.55 + effectLevel * 0.18) * effectIntensity))
    card.box:SetCenterColor(red * (0.09 + effectLevel * 0.05), green * (0.09 + effectLevel * 0.05), blue * (0.09 + effectLevel * 0.05), 1)
    if card.rayBurst then
        card.rayBurst:SetHidden(not card.showRayBurst)
    end
end

local function AnchorTierEffect(effect, card, side, offset, distance)
    effect:ClearAnchors()
    if side == 0 then
        effect:SetAnchor(TOPLEFT, card.box, TOPLEFT, offset, -distance)
    elseif side == 1 then
        effect:SetAnchor(TOPLEFT, card.box, TOPLEFT, TIER_CARD_SIZE + distance, offset)
    elseif side == 2 then
        effect:SetAnchor(TOPLEFT, card.box, TOPLEFT, offset, TIER_CARD_SIZE + distance)
    else
        effect:SetAnchor(TOPLEFT, card.box, TOPLEFT, -distance, offset)
    end
end

function Dueling:UpdateTierCardGlowEffects()
    if not self.ui or self.ui.window:IsHidden() then
        return
    end

    local now = GetGameTimeMilliseconds()
    if self.lastTierGlowUpdate and now - self.lastTierGlowUpdate < 50 then
        return
    end
    self.lastTierGlowUpdate = now

    local elapsedSeconds = now / 1000
    for _, card in ipairs({ self.ui.overallTierCard, self.ui.classTierCard, self.ui.winRateEffectCard }) do
        if card.isElite and card.glowColor then
            local red, green, blue = card.glowColor[1], card.glowColor[2], card.glowColor[3]
            local visualIntensity = card.effectIntensity or 1
            local pulse = 0.5 + 0.5 * math.sin(elapsedSeconds * 7 + card.flamePhase)
            local effectLevel = math.max(
                card.emberLevel or 0,
                card.rayBurstLevel or 0,
                card.sparkleLevel or 0,
                card.moteLevel or 0,
                card.cometLevel or 0,
                card.pulseRingLevel or 0
            )
            card.glowOuter:SetEdgeColor(red, green, blue, math.min(1, (0.30 + effectLevel * 0.14 + pulse * 0.20) * visualIntensity))
            card.glowInner:SetEdgeColor(red, green, blue, math.min(1, (0.48 + effectLevel * 0.16 + pulse * 0.24) * visualIntensity))
            card.box:SetCenterColor(
                red * (0.08 + effectLevel * 0.045 + pulse * 0.045),
                green * (0.08 + effectLevel * 0.045 + pulse * 0.045),
                blue * (0.08 + effectLevel * 0.045 + pulse * 0.045),
                1
            )

            -- S- through S+ add a slow additive ray burst and a small badge
            -- shimmer to the existing outward embers. The intensity rises
            -- by sub-tier while staying compact enough for the fixed rail.
            if card.rayBurst and card.showRayBurst then
                local rayLevel = card.rayBurstLevel or 1
                local rayPulse = 0.5 + 0.5 * math.sin(elapsedSeconds * 4.6 + card.flamePhase)
                card.rayBurst:SetTextureRotation((elapsedSeconds * (0.65 + rayLevel * 0.04)) % (math.pi * 2), 0.5, 0.5)
                card.rayBurst:SetColor(red, green, blue, 0.16 + rayLevel * 0.06 + rayPulse * 0.08)
                card.rayBurst:SetHidden(false)
                local tierScale = card.tierScale or TIER_LABEL_SCALE
                card.tier:SetScale(tierScale * (0.97 + rayPulse * (0.04 + rayLevel * 0.01)))
                card.tier:SetAlpha(0.84 + rayPulse * 0.16)
            elseif card.rayBurst then
                card.rayBurst:SetHidden(true)
                card.tier:SetScale(card.tierScale or TIER_LABEL_SCALE)
                card.tier:SetAlpha(1)
            end

            for _, ember in ipairs(card.embers) do
                if card.showEmbers and ember.index <= math.max(1, math.floor(card.emberLevel * 6 * visualIntensity + 0.5)) then
                    local cycle = (elapsedSeconds * ember.speed + ember.phase) % 1
                    local distance = 5 + cycle * (28 + card.emberLevel * 11)
                    local alpha = math.min(1, math.max(0, (0.68 + card.emberLevel * 0.18 - cycle * 0.58) * visualIntensity))
                    AnchorTierEffect(ember, card, ember.side, ember.offset, distance)
                    ember:SetDimensions(ember.width + card.emberLevel - 1, math.max(3, math.floor(ember.height * (1 - cycle * 0.42))))
                    ember:SetCenterColor(
                        math.min(1, red + (1 - cycle) * 0.18),
                        math.min(1, green + (1 - cycle) * 0.12),
                        math.min(1, blue + (1 - cycle) * 0.06),
                        alpha
                    )
                    ember:SetEdgeColor(
                        math.min(1, red + 0.16),
                        math.min(1, green + 0.16),
                        math.min(1, blue + 0.10),
                        alpha
                    )
                    ember:SetHidden(false)
                else
                    ember:SetHidden(true)
                end
            end

            for _, sparkle in ipairs(card.sparkles) do
                if card.showLightning and sparkle.index <= math.max(1, math.floor(card.sparkleLevel * 6 * visualIntensity + 0.5)) then
                    local cycle = (elapsedSeconds * sparkle.speed + sparkle.phase) % 1
                    local activeWindow = 0.16 + card.sparkleLevel * 0.08
                    if cycle < activeWindow then
                        local intensity = math.sin((cycle / activeWindow) * math.pi)
                        AnchorTierEffect(sparkle, card, sparkle.side, sparkle.offset, 4 + intensity * (7 + card.sparkleLevel * 5))
                        sparkle:SetDimensions(
                            math.max(2, math.floor(sparkle.width * (1 + intensity * (0.30 + card.sparkleLevel * 0.15)))),
                            math.max(2, math.floor(sparkle.height * (1 + intensity * (0.30 + card.sparkleLevel * 0.15))))
                        )
                        sparkle:SetCenterColor(
                            math.min(1, red + 0.28 + intensity * 0.18),
                            math.min(1, green + 0.28 + intensity * 0.18),
                            math.min(1, blue + 0.28 + intensity * 0.18),
                            math.min(1, (0.40 + intensity * 0.60) * visualIntensity)
                        )
                        sparkle:SetEdgeColor(red, green, blue, 0.55 + intensity * 0.45)
                        sparkle:SetHidden(false)
                    else
                        sparkle:SetHidden(true)
                    end
                else
                    sparkle:SetHidden(true)
                end
            end
 
            for _, mote in ipairs(card.motes) do
                if card.showMotes then
                    local angle = elapsedSeconds * 1.45 + mote.phase
                    local radiusX = TIER_CARD_SIZE / 2 + 18
                    local radiusY = TIER_CARD_SIZE / 2 + 12
                    local twinkle = 0.55 + 0.45 * math.sin(elapsedSeconds * 6 + mote.phase)
                    mote:ClearAnchors()
                    mote:SetAnchor(CENTER, card.box, CENTER, math.floor(math.cos(angle) * radiusX), math.floor(math.sin(angle) * radiusY))
                    mote:SetDimensions(4 + math.floor(twinkle * 4), 4 + math.floor(twinkle * 4))
                    mote:SetCenterColor(
                        math.min(1, red + 0.20 + twinkle * 0.12),
                        math.min(1, green + 0.20 + twinkle * 0.12),
                        math.min(1, blue + 0.20 + twinkle * 0.12),
                        0.50 + twinkle * 0.50
                    )
                    mote:SetEdgeColor(red, green, blue, 0.65 + twinkle * 0.35)
                    mote:SetHidden(false)
                else
                    mote:SetHidden(true)
                end
            end

            for _, comet in ipairs(card.cometTrail) do
                local cometLevel = card.cometLevel or 0
                local activeComets = math.min(#card.cometTrail, math.max(1, math.floor((3 + cometLevel * 2) * visualIntensity + 0.5)))
                if card.showCometTrail and comet.index <= activeComets then
                    local angle = elapsedSeconds * (1.00 + cometLevel * 0.14) + card.flamePhase - (comet.index - 1) * 0.22
                    local distanceX = TIER_CARD_SIZE / 2 + 16 + cometLevel * 4
                    local distanceY = TIER_CARD_SIZE / 2 + 8 + cometLevel * 3
                    local tail = 1 - (comet.index - 1) / activeComets
                    local size = math.max(2, math.floor(4 + tail * (5 + cometLevel * 2)))
                    comet:ClearAnchors()
                    comet:SetAnchor(CENTER, card.box, CENTER, math.floor(math.cos(angle) * distanceX), math.floor(math.sin(angle) * distanceY))
                    comet:SetDimensions(size, size)
                    comet:SetCenterColor(
                        math.min(1, red + tail * 0.30),
                        math.min(1, green + tail * 0.30),
                        math.min(1, blue + tail * 0.30),
                        math.min(1, (0.20 + tail * (0.48 + cometLevel * 0.10)) * visualIntensity)
                    )
                    comet:SetEdgeColor(red, green, blue, 0.28 + tail * (0.48 + cometLevel * 0.12))
                    comet:SetHidden(false)
                else
                    comet:SetHidden(true)
                end
            end

            for _, ring in ipairs(card.pulseRings) do
                local pulseLevel = card.pulseRingLevel or 0
                local activeRingCount = math.min(#card.pulseRings, math.max(1, math.floor((pulseLevel + 1) * visualIntensity + 0.5)))
                if card.showPulseRings and ring.index <= activeRingCount then
                    local cycle = (elapsedSeconds * (0.42 + pulseLevel * 0.10) + ring.phase) % 1
                    local expansion = math.floor(6 + cycle * (24 + pulseLevel * 10))
                    ring:ClearAnchors()
                    ring:SetAnchor(CENTER, card.box, CENTER)
                    ring:SetDimensions(TIER_CARD_SIZE + expansion, TIER_CARD_SIZE + expansion)
                    ring:SetCenterColor(red, green, blue, 0)
                    ring:SetEdgeColor(red, green, blue, math.min(1, (1 - cycle) * (0.38 + pulseLevel * 0.16) * visualIntensity))
                    ring:SetHidden(false)
                else
                    ring:SetHidden(true)
                end
            end
        elseif card.embers then
            if card.rayBurst then
                card.rayBurst:SetHidden(true)
            end
            card.tier:SetAlpha(1)
            for _, ember in ipairs(card.embers) do
                ember:SetHidden(true)
            end
            for _, sparkle in ipairs(card.sparkles) do
                sparkle:SetHidden(true)
            end
            for _, mote in ipairs(card.motes) do
                mote:SetHidden(true)
            end
            for _, comet in ipairs(card.cometTrail) do
                comet:SetHidden(true)
            end
            for _, ring in ipairs(card.pulseRings) do
                ring:SetHidden(true)
            end
        end
    end
end

function Dueling:CreateUI()
    if self.ui then
        return
    end

    local window = WINDOW_MANAGER:CreateTopLevelWindow("PvPerformanceDuelingWindow")
    local maximumWidth = math.max(MIN_WINDOW_WIDTH, GuiRoot:GetWidth() - 40)
    local maximumHeight = math.max(MIN_WINDOW_HEIGHT, GuiRoot:GetHeight() - 40)
    local savedWidth = tonumber(self.savedVars.window.width) or DEFAULT_WINDOW_WIDTH
    local savedHeight = tonumber(self.savedVars.window.height) or DEFAULT_WINDOW_HEIGHT
    local windowWidth = math.max(MIN_WINDOW_WIDTH, math.min(savedWidth, maximumWidth))
    local windowHeight = math.max(MIN_WINDOW_HEIGHT, math.min(savedHeight, maximumHeight))
    window:SetDimensions(windowWidth, windowHeight)
    window:SetDimensionConstraints(MIN_WINDOW_WIDTH, MIN_WINDOW_HEIGHT, maximumWidth, maximumHeight)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetResizeHandleSize(14)
    window:SetClampedToScreen(true)

    if self.savedVars.window.left and self.savedVars.window.top then
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.savedVars.window.left, self.savedVars.window.top)
    else
        window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end

    local backdrop = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0.012, 0.016, 0.024, 1)
    backdrop:SetEdgeColor(0.36, 0.74, 1, 1)

    -- Only the header starts a drag, so interactive controls keep their input focus.
    local dragHandle = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    dragHandle:SetAnchor(TOPLEFT, window, TOPLEFT, 10, 10)
    dragHandle:SetDimensions(228, 46)
    dragHandle:SetMouseEnabled(true)
    dragHandle:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StartMoving()
        end
    end)
    dragHandle:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StopMovingOrResizing()
        end
    end)

    local title = CreateLabel(window, "ZoFontWinH1", 0.44, 0.78, 1)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 22, 16)
    title:SetDimensions(220, 36)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetText(DISPLAY_NAME)

    local titleModuleDivider = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    titleModuleDivider:SetAnchor(TOPLEFT, window, TOPLEFT, 242, 13)
    titleModuleDivider:SetDimensions(1, 32)
    titleModuleDivider:SetCenterColor(0.22, 0.34, 0.48, 1)
    titleModuleDivider:SetEdgeColor(0, 0, 0, 0)

    local moduleTab = CreateLabel(window, "ZoFontGameBold", 0.44, 0.78, 1)
    moduleTab:SetAnchor(TOPRIGHT, window, TOPRIGHT, -72, 18)
    moduleTab:SetDimensions(112, 30)
    moduleTab:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    moduleTab:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    moduleTab:SetText("DUELING")
    moduleTab:SetMouseEnabled(true)
    moduleTab:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:SelectModule("dueling")
        end
    end)

    local moduleTabBorder = WINDOW_MANAGER:CreateControl(nil, moduleTab, CT_BACKDROP)
    moduleTabBorder:SetAnchorFill(moduleTab)
    moduleTabBorder:SetCenterColor(0.44, 0.78, 1.00, 0.18)
    moduleTabBorder:SetEdgeColor(0.44, 0.78, 1, 1)
    moduleTabBorder:SetDrawLayer(DL_BACKGROUND)

    local moduleUnderline = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    moduleUnderline:SetAnchor(BOTTOM, moduleTab, BOTTOM, 0, 0)
    moduleUnderline:SetDimensions(94, 2)
    moduleUnderline:SetCenterColor(0.44, 0.78, 1, 1)
    moduleUnderline:SetEdgeColor(0, 0, 0, 0)
    moduleUnderline:SetHidden(true)

    local modulePlayerDivider = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    modulePlayerDivider:SetAnchor(RIGHT, moduleTab, LEFT, -12, 0)
    modulePlayerDivider:SetDimensions(1, 32)
    modulePlayerDivider:SetCenterColor(0.22, 0.34, 0.48, 1)
    modulePlayerDivider:SetEdgeColor(0, 0, 0, 0)

    local headerDivider = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    headerDivider:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 57)
    headerDivider:SetDimensions(windowWidth, 2)
    headerDivider:SetCenterColor(0.24, 0.56, 0.82, 0.90)
    headerDivider:SetEdgeColor(0, 0, 0, 0)

    local summaryRailDivider = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    summaryRailDivider:SetAnchor(TOPLEFT, window, TOPLEFT, SUMMARY_RAIL_DIVIDER_X, SUMMARY_RAIL_DIVIDER_TOP)
    summaryRailDivider:SetDimensions(2, windowHeight - SUMMARY_RAIL_DIVIDER_TOP - 18)
    summaryRailDivider:SetCenterColor(0.22, 0.34, 0.48, 0.9)
    summaryRailDivider:SetEdgeColor(0, 0, 0, 0)

    local recordBox = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    recordBox:SetAnchor(TOPLEFT, window, TOPLEFT, SUMMARY_RAIL_LEFT, SUMMARY_RAIL_TOP + SUMMARY_RAIL_STEP * 3 + SUMMARY_RAIL_SELECTOR_TO_SUMMARY_GAP)
    recordBox:SetDimensions(TIER_CARD_SIZE, TIER_CARD_SIZE)
    recordBox:SetCenterColor(0.02, 0.02, 0.03, 1)
    recordBox:SetEdgeColor(0.36, 0.74, 1, 1)

    local winRateBox = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    winRateBox:SetAnchor(TOPLEFT, window, TOPLEFT, SUMMARY_RAIL_LEFT, SUMMARY_RAIL_TOP + SUMMARY_RAIL_STEP * 2 + SUMMARY_RAIL_SELECTOR_TO_SUMMARY_GAP)
    winRateBox:SetDimensions(TIER_CARD_SIZE, TIER_CARD_SIZE)
    winRateBox:SetCenterColor(0.015, 0.02, 0.03, 1)
    winRateBox:SetEdgeColor(0.36, 0.74, 1, 1)

    local totalDuelsCaption = CreateLabel(recordBox, "ZoFontGameSmall", 0.70, 0.77, 0.85)
    totalDuelsCaption:SetAnchor(TOP, recordBox, TOP, 0, 9)
    totalDuelsCaption:SetDimensions(TIER_CARD_SIZE + 20, 16)
    totalDuelsCaption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    totalDuelsCaption:SetScale(0.95)
    totalDuelsCaption:SetText("TOTAL DUELS")

    local summary = CreateLabel(recordBox, "ZoFontWinH2", 0.94, 0.94, 0.94)
    summary:SetAnchor(TOP, recordBox, TOP, 0, 27)
    summary:SetDimensions(TIER_CARD_SIZE - 8, 25)
    summary:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    summary:SetScale(0.90)

    local uniqueOpponentsCaption = CreateLabel(recordBox, "ZoFontGameSmall", 0.70, 0.77, 0.85)
    uniqueOpponentsCaption:SetAnchor(TOP, recordBox, TOP, 0, 62)
    uniqueOpponentsCaption:SetDimensions(TIER_CARD_SIZE + 30, 16)
    uniqueOpponentsCaption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    uniqueOpponentsCaption:SetScale(0.86)
    uniqueOpponentsCaption:SetText("UNIQUE OPPONENTS")

    local uniqueOpponents = CreateLabel(recordBox, "ZoFontWinH2", 0.94, 0.94, 0.94)
    uniqueOpponents:SetAnchor(TOP, recordBox, TOP, 0, 84)
    uniqueOpponents:SetDimensions(TIER_CARD_SIZE - 8, 25)
    uniqueOpponents:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    uniqueOpponents:SetScale(0.90)

    local close = CreateLabel(window, "ZoFontWinH2", 0.90, 0.90, 0.90)
    close:SetAnchor(TOPRIGHT, window, TOPRIGHT, -20, 17)
    close:SetDimensions(40, 28)
    close:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    close:SetText("[X]")
    close:SetMouseEnabled(true)
    close:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:HideUI()
        end
    end)

    local function CreateTierCard(captionText, offsetX, offsetY, captionScale, existingBox, effectOnly)
        local card = {}
        card.glowOuter = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
        card.glowOuter:SetAnchor(TOPLEFT, window, TOPLEFT, offsetX - 5, offsetY - 5)
        card.glowOuter:SetDimensions(TIER_CARD_SIZE + 10, TIER_CARD_SIZE + 10)
        card.glowOuter:SetCenterColor(0, 0, 0, 0)
        card.glowOuter:SetEdgeColor(0, 0, 0, 0)
        card.glowOuter:SetHidden(true)

        card.glowInner = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
        card.glowInner:SetAnchor(TOPLEFT, window, TOPLEFT, offsetX - 2, offsetY - 2)
        card.glowInner:SetDimensions(TIER_CARD_SIZE + 4, TIER_CARD_SIZE + 4)
        card.glowInner:SetCenterColor(0, 0, 0, 0)
        card.glowInner:SetEdgeColor(0, 0, 0, 0)
        card.glowInner:SetHidden(true)

        -- B-tier cards use sparkles, A-tier cards use comet trails, and S-tier
        -- cards combine outward embers with a softly rotating ray burst.
        card.embers = {}
        card.flamePhase = (offsetX + offsetY) * 0.03
        for emberIndex = 1, 18 do
            local ember = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
            ember.index = emberIndex
            ember.side = (emberIndex - 1) % 4
            ember.offset = 8 + ((emberIndex * 17) % (TIER_CARD_SIZE - 16))
            ember.width = 2 + (emberIndex % 3)
            ember.height = 8 + ((emberIndex * 5) % 10)
            ember.phase = emberIndex * 0.137
            ember.speed = 0.42 + (emberIndex % 4) * 0.09
            ember:SetDimensions(ember.width, ember.height)
            ember:SetCenterColor(1, 0.55, 0.08, 0)
            ember:SetEdgeColor(1, 0.78, 0.12, 0)
            ember:SetHidden(true)
            table.insert(card.embers, ember)
        end

        card.sparkles = {}
        for sparkleIndex = 1, 18 do
            local sparkle = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
            sparkle.index = sparkleIndex
            sparkle.side = (sparkleIndex - 1) % 4
            sparkle.offset = 7 + ((sparkleIndex * 19) % (TIER_CARD_SIZE - 14))
            if sparkle.side == 0 or sparkle.side == 2 then
                sparkle.width = 6 + (sparkleIndex % 3) * 2
                sparkle.height = 2
            else
                sparkle.width = 2
                sparkle.height = 6 + (sparkleIndex % 3) * 2
            end
            sparkle.phase = sparkleIndex * 0.173
            sparkle.speed = 0.58 + (sparkleIndex % 5) * 0.11
            sparkle:SetDimensions(sparkle.width, sparkle.height)
            sparkle:SetCenterColor(0.76, 0.92, 1, 0)
            sparkle:SetEdgeColor(0.32, 0.72, 1, 0)
            sparkle:SetHidden(true)
            table.insert(card.sparkles, sparkle)
        end

        -- The reusable effect pool supports the C pulse rings, A comet trail,
        -- and B sparkle mapping without allocating effects during updates.
        card.motes = {}
        for moteIndex = 1, 12 do
            local mote = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
            mote.index = moteIndex
            mote.phase = moteIndex * (math.pi * 2 / 12)
            mote:SetDimensions(4, 4)
            mote:SetCenterColor(1, 0.76, 0.22, 0)
            mote:SetEdgeColor(1, 0.94, 0.58, 0)
            mote:SetHidden(true)
            table.insert(card.motes, mote)
        end

        card.cometTrail = {}
        for cometIndex = 1, 10 do
            local comet = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
            comet.index = cometIndex
            comet:SetDimensions(4, 4)
            comet:SetCenterColor(0.42, 1, 0.60, 0)
            comet:SetEdgeColor(0.80, 1, 0.88, 0)
            comet:SetHidden(true)
            table.insert(card.cometTrail, comet)
        end

        card.pulseRings = {}
        for ringIndex = 1, 4 do
            local ring = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
            ring.index = ringIndex
            ring.phase = (ringIndex - 1) / 4
            ring:SetDimensions(TIER_CARD_SIZE, TIER_CARD_SIZE)
            ring:SetCenterColor(0.25, 0.78, 1, 0)
            ring:SetEdgeColor(0.25, 0.78, 1, 0)
            ring:SetHidden(true)
            table.insert(card.pulseRings, ring)
        end

        card.box = existingBox or WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
        if not existingBox then
            card.box:SetAnchor(TOPLEFT, window, TOPLEFT, offsetX, offsetY)
            card.box:SetDimensions(TIER_CARD_SIZE, TIER_CARD_SIZE)
            card.box:SetCenterColor(0.02, 0.02, 0.03, 1)
            card.box:SetEdgeColor(0.36, 0.74, 1, 1)
            card.box:SetMouseEnabled(true)
        end

        card.rayBurst = WINDOW_MANAGER:CreateControl(nil, card.box, CT_TEXTURE)
        card.rayBurst:SetTexture("EsoUI/Art/Crafting/white_burst.dds")
        card.rayBurst:SetDimensions(TIER_CARD_SIZE + 20, TIER_CARD_SIZE + 20)
        card.rayBurst:SetAnchor(CENTER, card.box, CENTER, 0, -2)
        card.rayBurst:SetColor(1, 0.84, 0.08, 0)
        card.rayBurst:SetDrawLevel(0)
        card.rayBurst:SetHidden(true)
        pcall(function()
            card.rayBurst:SetBlendMode(TEX_BLEND_MODE_ADD)
        end)

        if effectOnly then
            return card
        end

        card.caption = CreateLabel(card.box, "ZoFontGameSmall", 0.70, 0.77, 0.85)
        card.caption:SetAnchor(TOP, card.box, TOP, 0, 13)
        card.caption:SetDimensions(TIER_CARD_SIZE + 20, 18)
        card.caption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        card.caption:SetScale(captionScale)
        card.caption:SetText(captionText)

        card.tier = CreateLabel(card.box, "ZoFontWinH1", 1, 1, 1)
        card.tier:SetAnchor(CENTER, card.box, CENTER, 0, -4)
        card.tier:SetDimensions(TIER_CARD_SIZE - 10, 40)
        card.tier:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        card.tier:SetScale(TIER_LABEL_SCALE)

        card.progress = WINDOW_MANAGER:CreateControl(nil, card.box, CT_BACKDROP)
        card.progress:SetAnchor(BOTTOM, card.box, BOTTOM, 0, -10)
        card.progress:SetDimensions(TIER_PROGRESS_WIDTH, TIER_PROGRESS_HEIGHT)
        card.progress:SetCenterColor(0.015, 0.02, 0.03, 1)
        card.progress:SetEdgeColor(0.36, 0.74, 1, 1)

        card.progressFill = WINDOW_MANAGER:CreateControl(nil, card.progress, CT_BACKDROP)
        card.progressFill:SetAnchor(TOPLEFT, card.progress, TOPLEFT, 2, 2)
        card.progressFill:SetDimensions(0, TIER_PROGRESS_FILL_HEIGHT)
        card.progressFill:SetCenterColor(0.36, 0.74, 1, 1)
        card.progressFill:SetEdgeColor(0, 0, 0, 0)

        card.progressLabel = CreateLabel(card.progress, "ZoFontGameSmall", 1, 1, 1)
        card.progressLabel:SetAnchor(TOP, card.progress, TOP, 0, 0)
        card.progressLabel:SetDimensions(TIER_PROGRESS_FILL_WIDTH, TIER_PROGRESS_HEIGHT)
        card.progressLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        card.progressLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        card.clickTarget = WINDOW_MANAGER:CreateControl(nil, card.box, CT_CONTROL)
        card.clickTarget:SetAnchorFill(card.box)
        card.clickTarget:SetMouseEnabled(true)

        return card
    end

    local overallTierCard = CreateTierCard("OVERALL TIER", SUMMARY_RAIL_LEFT, SUMMARY_RAIL_TOP, 0.78)
    local classTierCard = CreateTierCard("CLASS TIER", SUMMARY_RAIL_LEFT, SUMMARY_RAIL_TOP + SUMMARY_RAIL_STEP, 0.82)
    local tierBox = overallTierCard.box
    local tierCaption = overallTierCard.caption
    local tier = overallTierCard.tier
    local tierProgress = overallTierCard.progress
    local tierProgressFill = overallTierCard.progressFill
    local tierProgressLabel = overallTierCard.progressLabel

    -- Build the Win Rate card's visual-effect layer before its labels so the
    -- animated effects always render behind the percentage and W-L-D record.
    local winRateEffectCard = CreateTierCard(
        nil,
        SUMMARY_RAIL_LEFT,
        SUMMARY_RAIL_TOP + SUMMARY_RAIL_STEP * 2 + SUMMARY_RAIL_SELECTOR_TO_SUMMARY_GAP,
        nil,
        winRateBox,
        true
    )

    local headerClassIcon = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
    headerClassIcon:SetAnchor(LEFT, titleModuleDivider, RIGHT, 16, 0)
    headerClassIcon:SetDimensions(26, 26)
    headerClassIcon:SetHidden(true)

    local headerChampionPoints = CreateLabel(window, "ZoFontGameBold", 0.82, 0.88, 0.96)
    headerChampionPoints:SetAnchor(LEFT, headerClassIcon, RIGHT, 7, 0)
    headerChampionPoints:SetDimensions(92, 28)
    headerChampionPoints:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    headerChampionPoints:SetText("CP 0")

    local playerNameBox = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    playerNameBox:SetAnchor(LEFT, headerChampionPoints, RIGHT, 8, 0)
    playerNameBox:SetDimensions(360, 40)
    playerNameBox:SetCenterColor(0, 0, 0, 0)
    playerNameBox:SetEdgeColor(0, 0, 0, 0)

    local playerName = CreateLabel(playerNameBox, "ZoFontWinH1", 1, 1, 1)
    playerName:SetAnchor(LEFT, playerNameBox, LEFT, 0, 0)
    playerName:SetDimensions(348, 32)
    playerName:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    overallTierCard.clickTarget:SetHandler("OnMouseEnter", function(control)
        if self.ui and self.ui.tierTooltipText then
            ZO_Tooltips_ShowTextTooltip(control, LEFT, self.ui.tierTooltipText)
        end
    end)
    overallTierCard.clickTarget:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)
    overallTierCard.clickTarget:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_RIGHT then
            self:ShowTierShareMenu("overall", overallTierCard.clickTarget)
        end
    end)
    classTierCard.clickTarget:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_RIGHT then
            self:ShowTierShareMenu("class", classTierCard.clickTarget)
        end
    end)
    classTierCard.clickTarget:SetHandler("OnMouseEnter", function(control)
        if self.ui and self.ui.classTierTooltipText then
            ZO_Tooltips_ShowTextTooltip(control, LEFT, self.ui.classTierTooltipText)
        end
    end)
    classTierCard.clickTarget:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)

    local overallTierInfo = WINDOW_MANAGER:CreateControl(nil, overallTierCard.box, CT_BACKDROP)
    overallTierInfo:SetAnchor(TOPRIGHT, overallTierCard.box, TOPRIGHT, -4, 4)
    overallTierInfo:SetDimensions(17, 17)
    overallTierInfo:SetCenterColor(0.025, 0.03, 0.05, 1)
    overallTierInfo:SetEdgeColor(0.44, 0.78, 1, 1)

    local overallTierInfoText = CreateLabel(overallTierInfo, "ZoFontGameSmall", 0.55, 0.82, 1)
    overallTierInfoText:SetAnchor(CENTER, overallTierInfo, CENTER, 0, -1)
    overallTierInfoText:SetDimensions(15, 17)
    overallTierInfoText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    overallTierInfoText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    overallTierInfoText:SetScale(0.82)
    overallTierInfoText:SetText("i")

    local overallTierInfoClickTarget = WINDOW_MANAGER:CreateControl(nil, overallTierInfo, CT_CONTROL)
    overallTierInfoClickTarget:SetAnchorFill(overallTierInfo)
    overallTierInfoClickTarget:SetMouseEnabled(true)
    overallTierInfoClickTarget:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:ShowRankingInfoPanel("overall")
        end
    end)

    local classTierInfo = WINDOW_MANAGER:CreateControl(nil, classTierCard.box, CT_BACKDROP)
    classTierInfo:SetAnchor(TOPRIGHT, classTierCard.box, TOPRIGHT, -4, 4)
    classTierInfo:SetDimensions(17, 17)
    classTierInfo:SetCenterColor(0.025, 0.03, 0.05, 1)
    classTierInfo:SetEdgeColor(0.44, 0.78, 1, 1)

    local classTierInfoText = CreateLabel(classTierInfo, "ZoFontGameSmall", 0.55, 0.82, 1)
    classTierInfoText:SetAnchor(CENTER, classTierInfo, CENTER, 0, -1)
    classTierInfoText:SetDimensions(15, 17)
    classTierInfoText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    classTierInfoText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    classTierInfoText:SetScale(0.82)
    classTierInfoText:SetText("i")

    local classTierInfoClickTarget = WINDOW_MANAGER:CreateControl(nil, classTierInfo, CT_CONTROL)
    classTierInfoClickTarget:SetAnchorFill(classTierInfo)
    classTierInfoClickTarget:SetMouseEnabled(true)
    classTierInfoClickTarget:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:ShowRankingInfoPanel("class")
        end
    end)

    -- The card shows one class at a time. This selector lives in the fixed
    -- rail gap beneath it, so the card stack keeps the same layout at every
    -- journal size.
    local classTierSelector = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    classTierSelector:SetAnchor(TOPLEFT, window, TOPLEFT, SUMMARY_RAIL_LEFT, SUMMARY_RAIL_TOP + SUMMARY_RAIL_STEP + TIER_CARD_SIZE + 12)
    classTierSelector:SetDimensions(TIER_CARD_SIZE, 28)
    classTierSelector:SetCenterColor(0.025, 0.03, 0.05, 1)
    classTierSelector:SetEdgeColor(0.36, 0.74, 1, 1)

    local classTierSelectorText = CreateLabel(classTierSelector, "ZoFontGameSmall", 0.82, 0.88, 0.96)
    classTierSelectorText:SetAnchor(CENTER, classTierSelector, CENTER, 0, -1)
    classTierSelectorText:SetDimensions(TIER_CARD_SIZE - 4, 24)
    classTierSelectorText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    classTierSelectorText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    classTierSelectorText:SetText("Select class")

    -- Backdrops are visual-only in some ESO UI contexts. A transparent
    -- CT_CONTROL matches the click pattern used by the other interactive
    -- cards and remains reliably clickable above their visual effects.
    local classTierSelectorClickTarget = WINDOW_MANAGER:CreateControl(nil, classTierSelector, CT_CONTROL)
    classTierSelectorClickTarget:SetAnchorFill(classTierSelector)
    classTierSelectorClickTarget:SetMouseEnabled(true)
    classTierSelectorClickTarget:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:ShowClassTierSelectorMenu(classTierSelector)
        end
    end)

    local winRateCaption = CreateLabel(winRateBox, "ZoFontGameBold", 0.70, 0.77, 0.85)
    winRateCaption:SetAnchor(TOP, winRateBox, TOP, 0, 12)
    winRateCaption:SetDimensions(TIER_CARD_SIZE - 6, 18)
    winRateCaption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    winRateCaption:SetScale(0.90)
    winRateCaption:SetText("WIN RATE")

    local winRate = CreateLabel(winRateBox, "ZoFontWinH1", 1, 1, 1)
    winRate:SetAnchor(TOP, winRateBox, TOP, 0, 38)
    winRate:SetDimensions(TIER_CARD_SIZE - 6, 38)
    winRate:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    winRate:SetScale(0.90)

    -- Its rank is derived from win-rate percentage during RefreshUI, while
    -- the percentage keeps the compact scale needed for this smaller card.
    winRateEffectCard.tier = winRate
    winRateEffectCard.tierScale = 0.90

    local record = CreateLabel(winRateBox, "ZoFontWinH2", 0.88, 0.90, 0.94)
    record:SetAnchor(BOTTOM, winRateBox, BOTTOM, 0, -10)
    record:SetDimensions(TIER_CARD_SIZE - 8, 28)
    record:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    record:SetScale(0.90)

    local winRateClickTarget = WINDOW_MANAGER:CreateControl(nil, winRateBox, CT_CONTROL)
    winRateClickTarget:SetAnchorFill(winRateBox)
    winRateClickTarget:SetMouseEnabled(true)
    winRateClickTarget:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_RIGHT then
            self:ShowWinRateShareMenu(winRateClickTarget)
        end
    end)

    local tabs = {}
    local function AddTab(tabName, text, offsetX, width)
        local tab = CreateLabel(window, "ZoFontGameBold", 0.55, 0.67, 0.78)
        tab:SetAnchor(TOPLEFT, window, TOPLEFT, offsetX, TAB_TOP)
        tab:SetDimensions(width, 26)
        tab:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        tab:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        tab:SetText(text)
        tab.tabBorder = WINDOW_MANAGER:CreateControl(nil, tab, CT_BACKDROP)
        tab.tabBorder:SetAnchorFill(tab)
        tab.tabBorder:SetCenterColor(0, 0, 0, 0)
        tab.tabBorder:SetEdgeColor(0.48, 0.52, 0.58, 1)
        tab.tabBorder:SetDrawLayer(DL_BACKGROUND)
        tab:SetMouseEnabled(true)
        tab:SetHandler("OnMouseUp", function(_, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                self:SetActiveTab(tabName)
            end
        end)
        tabs[tabName] = tab
    end
    -- Recent Duels needs the wider title field; keep the following tabs
    -- evenly spaced while preserving a clear gap before Search.
    local tabOffset = MAIN_CONTENT_LEFT
    local function AddSpacedTab(tabName, text, width)
        AddTab(tabName, text, tabOffset, width)
        tabOffset = tabOffset + width + 10
    end
    AddSpacedTab("recent", "RECENT DUELS", 124)
    AddSpacedTab("opponents", "OPPONENTS", 100)
    AddSpacedTab("classes", "CLASSES", 84)
    AddSpacedTab("statistics", "STATISTICS", 96)
    AddSpacedTab("settings", "SETTINGS", 86)
    AddSpacedTab("commands", "COMMANDS", 100)

    local detailBack = CreateLabel(window, "ZoFontGameBold", 0.52, 0.79, 1)
    detailBack:SetAnchor(TOPRIGHT, window, TOPRIGHT, -28, TAB_TOP)
    detailBack:SetDimensions(194, 28)
    detailBack:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    detailBack:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    detailBack:SetMouseEnabled(true)
    detailBack:SetHidden(true)
    detailBack.navBorder = WINDOW_MANAGER:CreateControl(nil, detailBack, CT_BACKDROP)
    detailBack.navBorder:SetAnchorFill(detailBack)
    detailBack.navBorder:SetCenterColor(0, 0, 0, 0)
    detailBack.navBorder:SetEdgeColor(0.48, 0.52, 0.58, 1)
    detailBack.navBorder:SetDrawLayer(DL_BACKGROUND)
    detailBack:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            if self.ui and self.ui.selectedDuel then
                self:CloseDuelSummary()
            else
                self:CloseDetail()
            end
        end
    end)

    local searchLabel = CreateLabel(window, "ZoFontGameBold", 0.70, 0.77, 0.85)
    searchLabel:SetAnchor(TOPRIGHT, window, TOPRIGHT, -248, TAB_TOP)
    searchLabel:SetDimensions(70, 24)
    searchLabel:SetText("Search:")

    local searchBackdrop = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    searchBackdrop:SetAnchor(TOPRIGHT, window, TOPRIGHT, -28, TAB_TOP - 4)
    searchBackdrop:SetDimensions(212, 30)
    searchBackdrop:SetCenterColor(0.055, 0.07, 0.10, 1)
    searchBackdrop:SetEdgeColor(0.22, 0.34, 0.48, 1)

    -- Use ESO's edit-control template instead of a bare keyboard-enabled
    -- CT_EDITBOX. The bare control can retain the initial keyboard action
    -- path and consume the first ESC until another journal control is used.
    -- ZO_DefaultEdit supplies ESO's normal focus lifecycle.
    local searchInput = WINDOW_MANAGER:CreateControlFromVirtual(
        "PvPerformanceDuelingSearchInput",
        searchBackdrop,
        "ZO_DefaultEdit"
    )
    searchInput:ClearAnchors()
    searchInput:SetAnchor(TOPLEFT, searchBackdrop, TOPLEFT, 8, 4)
    searchInput:SetDimensions(196, 24)
    searchInput:SetFont("ZoFontGame")
    searchInput:SetColor(0.94, 0.94, 0.94, 1)
    searchInput:SetMouseEnabled(true)
    searchInput:SetEditEnabled(true)
    searchInput:SetTextType(TEXT_TYPE_ALL)
    searchInput:SetMaxInputChars(64)
    searchInput:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            control:TakeFocus()
        end
    end)
    searchInput:SetHandler("OnTextChanged", function(control)
        self.ui.searchText = control:GetText() or ""
        self.ui.page = 1
        self:RefreshUI()
    end)
    searchInput:SetHandler("OnEnter", function(control)
        control:LoseFocus()
    end)
    searchInput:SetHandler("OnEscape", function(control)
        control:LoseFocus()
        self:HideUI()
    end)

    -- Keep the aggregate sort action beside Search, but make it a plain text
    -- control so it cannot crowd or clip the search field at smaller widths.
    local aggregateSortBackdrop = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    aggregateSortBackdrop:SetAnchor(TOPRIGHT, searchLabel, TOPLEFT, -8, 0)
    aggregateSortBackdrop:SetDimensions(46, 26)
    aggregateSortBackdrop:SetCenterColor(0, 0, 0, 0)
    aggregateSortBackdrop:SetEdgeColor(0, 0, 0, 0)
    aggregateSortBackdrop:SetHidden(true)

    local aggregateSortLabel = CreateLabel(aggregateSortBackdrop, "ZoFontGameBold", 0.70, 0.77, 0.85)
    aggregateSortLabel:SetAnchor(CENTER, aggregateSortBackdrop, CENTER, 0, 0)
    aggregateSortLabel:SetDimensions(46, 24)
    aggregateSortLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    aggregateSortLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    aggregateSortLabel:SetScale(0.88)
    aggregateSortLabel:SetText("Sort")

    local aggregateSortClickTarget = WINDOW_MANAGER:CreateControl(nil, aggregateSortBackdrop, CT_CONTROL)
    aggregateSortClickTarget:SetAnchorFill(aggregateSortBackdrop)
    aggregateSortClickTarget:SetMouseEnabled(true)
    aggregateSortClickTarget:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:ShowAggregateSortMenu(aggregateSortBackdrop)
        end
    end)

    -- Opening an opponent aggregate row exposes a compact, saved-history
    -- performance view before the normal newest-first duel list.
    local opponentPerformancePanel = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    opponentPerformancePanel:SetAnchor(TOPLEFT, window, TOPLEFT, MAIN_CONTENT_LEFT, ROW_TOP)
    opponentPerformancePanel:SetDimensions(DEFAULT_WINDOW_WIDTH - MAIN_CONTENT_LEFT - 22, DETAIL_PERFORMANCE_HEIGHT)
    opponentPerformancePanel:SetCenterColor(0.035, 0.045, 0.065, 0.98)
    opponentPerformancePanel:SetEdgeColor(0.17, 0.26, 0.36, 1)
    opponentPerformancePanel:SetHidden(true)

    local opponentPerformanceTitle = CreateLabel(opponentPerformancePanel, "ZoFontWinH2", 0.94, 0.94, 0.94)
    opponentPerformanceTitle:SetAnchor(TOPLEFT, opponentPerformancePanel, TOPLEFT, 14, 10)
    opponentPerformanceTitle:SetDimensions(310, 28)

    local opponentPerformanceLines = {}
    for index = 1, 5 do
        local line = CreateLabel(opponentPerformancePanel, "ZoFontGame", 0.76, 0.82, 0.90)
        line:SetAnchor(TOPLEFT, opponentPerformancePanel, TOPLEFT, 16, 42 + (index - 1) * 24)
        line:SetDimensions(330, 22)
        opponentPerformanceLines[index] = line
    end
    local opponentPerformanceLastFive = CreateLabel(opponentPerformancePanel, "ZoFontGameBold", 0.70, 0.77, 0.85)
    opponentPerformanceLastFive:SetAnchor(TOPLEFT, opponentPerformancePanel, TOPLEFT, 16, 163)
    opponentPerformanceLastFive:SetDimensions(330, 22)

    local opponentPerformanceGraph = CreateTrendGraph(opponentPerformancePanel, 178)
    opponentPerformanceGraph:SetAnchor(TOPRIGHT, opponentPerformancePanel, TOPRIGHT, -10, 10)

    -- All individual duel rows share this one compact post-duel report. Its
    -- summary cards and source tables are populated from the selected saved
    -- record; no duplicate combat data is made for any source tab.
    local duelDetailPanel = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    duelDetailPanel:SetAnchor(TOPLEFT, window, TOPLEFT, MAIN_CONTENT_LEFT, ROW_TOP)
    duelDetailPanel:SetDimensions(DEFAULT_WINDOW_WIDTH - MAIN_CONTENT_LEFT - 22, 884)
    duelDetailPanel:SetCenterColor(0.035, 0.045, 0.065, 0.98)
    duelDetailPanel:SetEdgeColor(0.17, 0.26, 0.36, 1)
    duelDetailPanel:SetHidden(true)

    local duelDetailTitle = CreateLabel(duelDetailPanel, "ZoFontWinH2", 0.44, 0.78, 1)
    duelDetailTitle:SetAnchor(TOPLEFT, duelDetailPanel, TOPLEFT, 14, 10)
    duelDetailTitle:SetDimensions(640, 26)

    local duelDetailSubtitle = CreateLabel(duelDetailPanel, "ZoFontGame", 0.70, 0.77, 0.85)
    duelDetailSubtitle:SetAnchor(TOPLEFT, duelDetailPanel, TOPLEFT, 16, 37)
    duelDetailSubtitle:SetDimensions(640, 22)
    duelDetailSubtitle:SetScale(1.00)

    local duelDetailNotice = CreateLabel(duelDetailPanel, "ZoFontGame", 1, 0.68, 0.58)
    duelDetailNotice:SetAnchor(TOPLEFT, duelDetailPanel, TOPLEFT, 16, 58)
    duelDetailNotice:SetDimensions(800, 22)
    duelDetailNotice:SetHidden(true)

    local duelDetailAnalyticsButton = WINDOW_MANAGER:CreateControl(nil, duelDetailPanel, CT_BACKDROP)
    duelDetailAnalyticsButton:SetAnchor(TOPRIGHT, duelDetailPanel, TOPRIGHT, -12, 10)
    duelDetailAnalyticsButton:SetDimensions(190, 42)
    duelDetailAnalyticsButton:SetCenterColor(0.018, 0.024, 0.038, 1)
    duelDetailAnalyticsButton:SetEdgeColor(0.44, 0.78, 1, 1)
    duelDetailAnalyticsButton.label = CreateLabel(duelDetailAnalyticsButton, "ZoFontGameBold", 0.84, 0.88, 0.94)
    duelDetailAnalyticsButton.label:SetAnchorFill(duelDetailAnalyticsButton)
    duelDetailAnalyticsButton.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    duelDetailAnalyticsButton.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    duelDetailAnalyticsButton.label:SetText("GO TO ANALYTICS")
    duelDetailAnalyticsButton.clickTarget = WINDOW_MANAGER:CreateControl(nil, duelDetailAnalyticsButton, CT_CONTROL)
    duelDetailAnalyticsButton.clickTarget:SetAnchorFill(duelDetailAnalyticsButton)
    duelDetailAnalyticsButton.clickTarget:SetMouseEnabled(true)
    duelDetailAnalyticsButton.clickTarget:SetHandler("OnMouseEnter", function()
        local Analytics = PvPerformance.Modules.Analytics
        local available = Analytics and Analytics.GetAnalyticsForDuel
            and Analytics:GetAnalyticsForDuel(self.ui and self.ui.selectedDuel)
        duelDetailAnalyticsButton:SetEdgeColor(
            available and 0.62 or 0.48,
            available and 0.86 or 0.52,
            available and 1.00 or 0.58,
            1
        )
    end)
    duelDetailAnalyticsButton.clickTarget:SetHandler("OnMouseExit", function()
        local Analytics = PvPerformance.Modules.Analytics
        local available = Analytics and Analytics.GetAnalyticsForDuel
            and Analytics:GetAnalyticsForDuel(self.ui and self.ui.selectedDuel)
        duelDetailAnalyticsButton:SetEdgeColor(
            available and 0.44 or 0.48,
            available and 0.78 or 0.52,
            available and 1.00 or 0.58,
            1
        )
    end)
    duelDetailAnalyticsButton.clickTarget:SetHandler("OnMouseUp", function(_, button, upInside)
        if button == MOUSE_BUTTON_INDEX_LEFT and upInside ~= false then
            local Analytics = PvPerformance.Modules.Analytics
            if Analytics and Analytics.OpenDuelFromJournal then
                Analytics:OpenDuelFromJournal(self.ui and self.ui.selectedDuel)
            end
        end
    end)

    local duelDetailSummaryRow = WINDOW_MANAGER:CreateControl(nil, duelDetailPanel, CT_CONTROL)
    duelDetailSummaryRow:SetAnchor(TOPLEFT, duelDetailPanel, TOPLEFT, 12, 80)
    duelDetailSummaryRow:SetDimensions(DEFAULT_WINDOW_WIDTH - MAIN_CONTENT_LEFT - 46, 128)

    local function CreateDuelSummaryCard(parent, captionText, rateCaption)
        local card = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
        card:SetDimensions(200, 128)
        card:SetCenterColor(0.025, 0.03, 0.05, 1)
        card:SetEdgeColor(0.12, 0.20, 0.30, 1)

        card.caption = CreateLabel(card, "ZoFontGameBold", 0.70, 0.77, 0.85)
        card.caption:SetAnchor(TOP, card, TOP, 0, 10)
        card.caption:SetDimensions(180, 22)
        card.caption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        card.caption:SetScale(0.98)
        card.caption:SetText(captionText)

        card.note = CreateLabel(card, "ZoFontGame", 0.62, 0.70, 0.79)
        card.note:SetAnchor(BOTTOM, card, BOTTOM, 0, -8)
        card.note:SetDimensions(180, 20)
        card.note:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        card.note:SetScale(0.90)
        card.note:SetHidden(true)

        if rateCaption then
            card.leftHeader = CreateLabel(card, "ZoFontGameBold", 0.62, 0.70, 0.79)
            card.leftHeader:SetAnchor(TOPLEFT, card, TOPLEFT, 10, 45)
            card.leftHeader:SetDimensions(82, 20)
            card.leftHeader:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            card.leftHeader:SetScale(0.90)
            card.leftHeader:SetText("TOTAL")

            card.rightHeader = CreateLabel(card, "ZoFontGameBold", 0.62, 0.70, 0.79)
            card.rightHeader:SetAnchor(TOPRIGHT, card, TOPRIGHT, -10, 45)
            card.rightHeader:SetDimensions(82, 20)
            card.rightHeader:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            card.rightHeader:SetScale(0.90)
            card.rightHeader:SetText(rateCaption)

            card.divider = WINDOW_MANAGER:CreateControl(nil, card, CT_BACKDROP)
            card.divider:SetAnchor(TOP, card, TOP, 0, 43)
            card.divider:SetDimensions(1, 58)
            card.divider:SetCenterColor(0.17, 0.26, 0.36, 1)
            card.divider:SetEdgeColor(0, 0, 0, 0)

            card.leftValue = CreateLabel(card, "ZoFontGameBold", 0.88, 0.90, 0.94)
            card.leftValue:SetAnchor(TOP, card.leftHeader, BOTTOM, 0, 3)
            card.leftValue:SetDimensions(82, 30)
            card.leftValue:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            card.leftValue:SetScale(1.30)

            card.rightValue = CreateLabel(card, "ZoFontGameBold", 0.88, 0.90, 0.94)
            card.rightValue:SetAnchor(TOP, card.rightHeader, BOTTOM, 0, 3)
            card.rightValue:SetDimensions(82, 30)
            card.rightValue:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            card.rightValue:SetScale(1.30)
        else
            card.value = CreateLabel(card, "ZoFontGameBold", 0.88, 0.90, 0.94)
            card.value:SetAnchor(TOP, card, TOP, 0, 52)
            card.value:SetDimensions(180, 32)
            card.value:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            card.value:SetScale(1.30)
        end
        return card
    end

    local duelDetailTotals = {
        damageDone = CreateDuelSummaryCard(duelDetailSummaryRow, "DAMAGE DONE", "DPS"),
        damageTaken = CreateDuelSummaryCard(duelDetailSummaryRow, "DAMAGE TAKEN", "DPS"),
        healing = CreateDuelSummaryCard(duelDetailSummaryRow, "HEALING", "HPS"),
        shield = CreateDuelSummaryCard(duelDetailSummaryRow, "SHIELD ABSORPTION"),
    }
    local duelDetailSummaryCards = {
        duelDetailTotals.damageDone,
        duelDetailTotals.damageTaken,
        duelDetailTotals.healing,
        duelDetailTotals.shield,
    }

    local function CreateCombatBreakdownBoard(parent, captionText)
        local board = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
        board:SetDimensions(300, 320)
        board:SetCenterColor(0.045, 0.055, 0.08, 0.98)
        board:SetEdgeColor(0.22, 0.34, 0.48, 1)
        board:SetMouseEnabled(true)
        board.rowHeight = 26
        board.visibleRowCount = 9
        board.numericColumnOrder = {
            "percent",
            "dps",
            "damage",
            "critHits",
            "critPercent",
            "min",
            "avg",
            "max",
        }

        board.caption = CreateLabel(board, "ZoFontGameBold", 0.44, 0.78, 1)
        board.caption:SetAnchor(TOPLEFT, board, TOPLEFT, 10, 10)
        board.caption:SetDimensions(276, 22)
        board.caption:SetScale(1.02)
        board.caption:SetText(captionText)

        board.headers = {}
        local headerText = {
            name = "ABILITY",
            percent = "%",
            dps = "DPS",
            damage = "DAMAGE",
            critHits = "CRITS/HITS",
            critPercent = "CRIT %",
            min = "MIN",
            avg = "AVG",
            max = "MAX",
        }
        for key, text in pairs(headerText) do
            local header = CreateLabel(board, "ZoFontGameBold", 0.70, 0.77, 0.85)
            header:SetDimensions(56, 18)
            header:SetScale(0.90)
            header:SetText(text)
            board.headers[key] = header
        end

        board.rule = WINDOW_MANAGER:CreateControl(nil, board, CT_BACKDROP)
        board.rule:SetAnchor(TOPLEFT, board, TOPLEFT, 10, 55)
        board.rule:SetDimensions(278, 1)
        board.rule:SetCenterColor(0.22, 0.34, 0.48, 1)
        board.rule:SetEdgeColor(0, 0, 0, 0)

        board.empty = CreateLabel(board, "ZoFontGame", 0.62, 0.70, 0.79)
        board.empty:SetAnchor(TOP, board, TOP, 0, 76)
        board.empty:SetDimensions(270, 20)
        board.empty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        board.empty:SetText("No recorded source data")

        board.scrollTrack = WINDOW_MANAGER:CreateControl(nil, board, CT_BACKDROP)
        board.scrollTrack:SetAnchor(TOPRIGHT, board, TOPRIGHT, -5, 61)
        board.scrollTrack:SetDimensions(4, 245)
        board.scrollTrack:SetCenterColor(0.09, 0.14, 0.20, 0.9)
        board.scrollTrack:SetEdgeColor(0, 0, 0, 0)
        board.scrollTrack:SetHidden(true)
        board.scrollThumb = WINDOW_MANAGER:CreateControl(nil, board.scrollTrack, CT_BACKDROP)
        board.scrollThumb:SetDimensions(4, 18)
        board.scrollThumb:SetCenterColor(0.44, 0.78, 1, 0.9)
        board.scrollThumb:SetEdgeColor(0, 0, 0, 0)
        board.scrollThumb:SetHidden(true)

        board.rows = {}
        for index = 1, board.visibleRowCount do
            local row = {}
            local offsetY = 61 + (index - 1) * board.rowHeight
            row.icon = WINDOW_MANAGER:CreateControl(nil, board, CT_TEXTURE)
            row.icon:SetAnchor(TOPLEFT, board, TOPLEFT, 10, offsetY + 2)
            row.icon:SetDimensions(20, 20)
            row.icon:SetHidden(true)
            row.name = CreateLabel(board, "ZoFontGame", 0.84, 0.88, 0.94)
            row.name:SetAnchor(TOPLEFT, board, TOPLEFT, 34, offsetY)
            row.name:SetDimensions(150, board.rowHeight)
            row.name:SetScale(1.00)
            for _, key in ipairs(board.numericColumnOrder) do
                local label = CreateLabel(board, "ZoFontGame", 0.84, 0.88, 0.94)
                label:SetAnchor(TOPRIGHT, board, TOPRIGHT, -10, offsetY)
                label:SetDimensions(58, board.rowHeight)
                label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
                label:SetScale(1.00)
                row[key] = label
            end
            table.insert(board.rows, row)
        end
        board:SetHandler("OnMouseWheel", function(_, delta)
            self:SetCombatBreakdownScroll(board, (board.scrollOffset or 0) - (tonumber(delta) or 0))
        end)
        return board
    end

    local duelDetailDamageDoneBoard = CreateCombatBreakdownBoard(duelDetailPanel, "DAMAGE DONE")
    duelDetailDamageDoneBoard:SetAnchor(TOPLEFT, duelDetailSummaryRow, BOTTOMLEFT, 0, 12)
    local duelDetailDamageTakenBoard = CreateCombatBreakdownBoard(duelDetailPanel, "DAMAGE TAKEN")
    duelDetailDamageTakenBoard:SetAnchor(TOPLEFT, duelDetailDamageDoneBoard, BOTTOMLEFT, 0, 12)

    local statisticsPanel = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    statisticsPanel:SetAnchor(TOPLEFT, window, TOPLEFT, MAIN_CONTENT_LEFT, ROW_TOP)
    statisticsPanel:SetDimensions(DEFAULT_WINDOW_WIDTH - MAIN_CONTENT_LEFT - 22, 630)
    statisticsPanel:SetHidden(true)

    local statMetricCards = {}
    local previousMetricCard
    local metricCaptions = {
        "LONGEST WIN STREAK",
        "LONGEST LOSS STREAK",
        "CURRENT STREAK",
        "AVERAGE DUEL TIME",
        "LONGEST DUEL TIME",
    }
    for index, captionText in ipairs(metricCaptions) do
        local card = WINDOW_MANAGER:CreateControl(nil, statisticsPanel, CT_BACKDROP)
        if previousMetricCard then
            card:SetAnchor(TOPLEFT, previousMetricCard, TOPRIGHT, 6, 0)
        else
            card:SetAnchor(TOPLEFT, statisticsPanel, TOPLEFT, 0, 0)
        end
        card:SetDimensions(210, 88)
        card:SetCenterColor(0.045, 0.055, 0.08, 0.98)
        card:SetEdgeColor(0.17, 0.26, 0.36, 1)

        card.caption = CreateLabel(card, "ZoFontGameBold", 0.70, 0.77, 0.85)
        card.caption:SetAnchor(TOP, card, TOP, 0, 8)
        card.caption:SetDimensions(200, 20)
        card.caption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        card.caption:SetScale(0.88)
        card.caption:SetText(captionText)

        card.value = CreateLabel(card, "ZoFontGameBold", 0.44, 0.78, 1)
        card.value:SetAnchor(TOP, card, TOP, 0, 33)
        card.value:SetDimensions(200, 24)
        card.value:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

        card.detail = CreateLabel(card, "ZoFontGame", 0.62, 0.70, 0.79)
        card.detail:SetAnchor(BOTTOM, card, BOTTOM, 0, -7)
        card.detail:SetDimensions(200, 22)
        card.detail:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        card.detail:SetScale(1.00)

        statMetricCards[index] = card
        previousMetricCard = card
    end

    local function CreateLeaderboard(captionText)
        local board = WINDOW_MANAGER:CreateControl(nil, statisticsPanel, CT_BACKDROP)
        board:SetDimensions(430, 218)
        board:SetCenterColor(0.045, 0.055, 0.08, 0.98)
        board:SetEdgeColor(0.17, 0.26, 0.36, 1)

        board.caption = CreateLabel(board, "ZoFontGameBold", 0.44, 0.78, 1)
        board.caption:SetAnchor(TOPLEFT, board, TOPLEFT, 12, 8)
        board.caption:SetDimensions(260, 20)
        board.caption:SetText(captionText)

        board.recordHeader = CreateLabel(board, "ZoFontGameBold", 0.70, 0.77, 0.85)
        board.recordHeader:SetAnchor(TOPRIGHT, board, TOPRIGHT, -80, 34)
        board.recordHeader:SetDimensions(104, 18)
        board.recordHeader:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        board.recordHeader:SetScale(0.76)
        board.recordHeader:SetText("RECORD")

        board.rateHeader = CreateLabel(board, "ZoFontGameBold", 0.70, 0.77, 0.85)
        board.rateHeader:SetAnchor(TOPRIGHT, board, TOPRIGHT, -10, 34)
        board.rateHeader:SetDimensions(58, 18)
        board.rateHeader:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        board.rateHeader:SetScale(0.76)
        board.rateHeader:SetText("WR")

        board.statsDivider = WINDOW_MANAGER:CreateControl(nil, board, CT_BACKDROP)
        board.statsDivider:SetAnchor(TOPRIGHT, board, TOPRIGHT, -74, 34)
        board.statsDivider:SetDimensions(1, 174)
        board.statsDivider:SetCenterColor(0.22, 0.34, 0.48, 1)
        board.statsDivider:SetEdgeColor(0, 0, 0, 0)

        board.names = {}
        board.records = {}
        board.rates = {}
        for index = 1, 5 do
            local name = CreateLabel(board, "ZoFontGame", 0.94, 0.94, 0.94)
            name:SetAnchor(TOPLEFT, board, TOPLEFT, 12, 62 + (index - 1) * 29)
            name:SetDimensions(220, 22)
            board.names[index] = name

            local record = CreateLabel(board, "ZoFontGame", 0.68, 0.75, 0.84)
            record:SetAnchor(TOPRIGHT, board, TOPRIGHT, -80, 62 + (index - 1) * 29)
            record:SetDimensions(104, 22)
            record:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            board.records[index] = record

            local rate = CreateLabel(board, "ZoFontGame", 0.68, 0.75, 0.84)
            rate:SetAnchor(TOPRIGHT, board, TOPRIGHT, -10, 62 + (index - 1) * 29)
            rate:SetDimensions(58, 22)
            rate:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            board.rates[index] = rate
        end

        return board
    end

    local dangerousBoard = CreateLeaderboard("TOP 5 HARDEST OPPONENTS")
    dangerousBoard:SetAnchor(TOPLEFT, statisticsPanel, TOPLEFT, 0, 102)
    local easiestBoard = CreateLeaderboard("TOP 5 EASIEST OPPONENTS")
    easiestBoard:SetAnchor(TOPLEFT, dangerousBoard, TOPRIGHT, 12, 0)

    local statDetailCards = {}
    local previousDetailCard
    local detailCaptions = {
        "MOST-PLAYED OPPONENT",
        "BEST CLASS MATCHUP",
        "WORST CLASS MATCHUP",
        "LAST 10 WIN RATE",
    }
    for index, captionText in ipairs(detailCaptions) do
        local card = WINDOW_MANAGER:CreateControl(nil, statisticsPanel, CT_BACKDROP)
        if previousDetailCard then
            card:SetAnchor(TOPLEFT, previousDetailCard, TOPRIGHT, 6, 0)
        else
            card:SetAnchor(TOPLEFT, statisticsPanel, TOPLEFT, 0, 336)
        end
        card:SetDimensions(210, 88)
        card:SetCenterColor(0.045, 0.055, 0.08, 0.98)
        card:SetEdgeColor(0.17, 0.26, 0.36, 1)

        card.caption = CreateLabel(card, "ZoFontGameBold", 0.70, 0.77, 0.85)
        card.caption:SetAnchor(TOP, card, TOP, 0, 8)
        card.caption:SetDimensions(200, 20)
        card.caption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        card.caption:SetScale(0.86)
        card.caption:SetText(captionText)

        card.value = CreateLabel(card, "ZoFontGameBold", 0.44, 0.78, 1)
        card.value:SetAnchor(TOP, card, TOP, 0, 33)
        card.value:SetDimensions(200, 24)
        card.value:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

        card.detail = CreateLabel(card, "ZoFontGame", 0.62, 0.70, 0.79)
        card.detail:SetAnchor(BOTTOM, card, BOTTOM, 0, -7)
        card.detail:SetDimensions(200, 22)
        card.detail:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        card.detail:SetScale(1.00)

        statDetailCards[index] = card
        previousDetailCard = card
    end

    local statisticsTrendGraph = CreateTrendGraph(statisticsPanel, 176)
    statisticsTrendGraph:SetAnchor(TOPLEFT, statisticsPanel, TOPLEFT, 0, 440)
    statisticsTrendGraph.title:SetText("TREND")

    local statisticsTrendButtons = {}
    local function CreateStatisticsTrendButton(mode, text, offsetX, width)
        local button = CreateLabel(statisticsTrendGraph, "ZoFontGameBold", 0.70, 0.77, 0.85)
        button:SetAnchor(TOPRIGHT, statisticsTrendGraph, TOPRIGHT, offsetX, 8)
        button:SetDimensions(width, 18)
        button:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        button:SetScale(0.88)
        button:SetText(text)
        button.tabBorder = WINDOW_MANAGER:CreateControl(nil, button, CT_BACKDROP)
        button.tabBorder:SetAnchorFill(button)
        button.tabBorder:SetCenterColor(0, 0, 0, 0)
        button.tabBorder:SetEdgeColor(0.48, 0.52, 0.58, 1)
        button.tabBorder:SetDrawLayer(DL_BACKGROUND)
        button:SetMouseEnabled(true)
        button:SetHandler("OnMouseUp", function(_, mouseButton)
            if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
                self.ui.statisticsTrendMode = mode
                self:RefreshStatistics()
            end
        end)
        statisticsTrendButtons[mode] = button
    end
    -- WIN RATE was clipped because its original 76px label field was too
    -- narrow at the supported UI scales. Give it a real text width and
    -- anchor RATING relative to it so the two controls cannot collide.
    CreateStatisticsTrendButton("rating", "RATING", -20, 68)
    CreateStatisticsTrendButton("rollingWinRate", "WIN RATE", -14, 96)
    statisticsTrendButtons.rollingWinRate:ClearAnchors()
    statisticsTrendButtons.rollingWinRate:SetAnchor(TOPRIGHT, statisticsTrendGraph, TOPRIGHT, -14, 8)
    statisticsTrendButtons.rating:ClearAnchors()
    statisticsTrendButtons.rating:SetAnchor(TOPRIGHT, statisticsTrendButtons.rollingWinRate, TOPLEFT, -14, 0)

    local settingsPanel = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    settingsPanel:SetAnchor(TOPLEFT, window, TOPLEFT, MAIN_CONTENT_LEFT, ROW_TOP)
    settingsPanel:SetDimensions(DEFAULT_WINDOW_WIDTH - MAIN_CONTENT_LEFT - 22, 590)
    settingsPanel:SetHidden(true)

    local settingsTitle = CreateLabel(settingsPanel, "ZoFontWinH1", 0.44, 0.78, 1)
    settingsTitle:SetAnchor(TOPLEFT, settingsPanel, TOPLEFT, 2, 0)
    settingsTitle:SetDimensions(420, 34)
    settingsTitle:SetText("JOURNAL SETTINGS")

    local settingsIntro = CreateLabel(settingsPanel, "ZoFontGame", 0.70, 0.77, 0.85)
    settingsIntro:SetAnchor(TOPLEFT, settingsPanel, TOPLEFT, 4, 38)
    settingsIntro:SetDimensions(680, 24)
    settingsIntro:SetText("Settings are saved account-wide. Rating changes rebuild safely when the damage adjustment is changed.")

    local settingsRows = {}
    local function CreateSettingsRow(captionText, detailText, offsetY, onClick)
        local row = WINDOW_MANAGER:CreateControl(nil, settingsPanel, CT_BACKDROP)
        row:SetAnchor(TOPLEFT, settingsPanel, TOPLEFT, 0, offsetY)
        row:SetDimensions(620, 94)
        row:SetCenterColor(0.045, 0.055, 0.08, 0.98)
        row:SetEdgeColor(0.17, 0.26, 0.36, 1)

        row.caption = CreateLabel(row, "ZoFontGameBold", 0.82, 0.88, 0.96)
        row.caption:SetAnchor(TOPLEFT, row, TOPLEFT, 14, 10)
        row.caption:SetDimensions(270, 18)
        row.caption:SetText(captionText)

        row.detail = CreateLabel(row, "ZoFontGame", 0.68, 0.75, 0.84)
        row.detail:SetAnchor(TOPLEFT, row, TOPLEFT, 14, 32)
        row.detail:SetDimensions(370, 48)
        row.detail:SetScale(1.00)
        row.detail:SetText(detailText)

        row.button = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
        row.button:SetAnchor(TOPRIGHT, row, TOPRIGHT, -12, 27)
        row.button:SetDimensions(174, 36)
        row.button:SetCenterColor(0.025, 0.03, 0.05, 1)
        row.button:SetEdgeColor(0.36, 0.74, 1, 1)

        row.buttonText = CreateLabel(row.button, "ZoFontGameBold", 0.82, 0.88, 0.96)
        row.buttonText:SetAnchor(CENTER, row.button, CENTER, 0, 0)
        row.buttonText:SetDimensions(164, 28)
        row.buttonText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        row.buttonText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        row.buttonText:SetScale(1.00)

        local clickTarget = WINDOW_MANAGER:CreateControl(nil, row.button, CT_CONTROL)
        clickTarget:SetAnchorFill(row.button)
        clickTarget:SetMouseEnabled(true)
        clickTarget:SetHandler("OnMouseUp", function(_, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                onClick()
            end
        end)
        row.clickTarget = clickTarget
        table.insert(settingsRows, row)
        return row
    end

    CreateSettingsRow("TIER EFFECT INTENSITY", "Changes the strength of tier glow, rings, sparkles, comets, and embers.", 76, function()
        self:CycleEffectIntensity()
    end)
    CreateSettingsRow("DAMAGE RATING ADJUSTMENT", "Awards a flat 15% bonus for eligible damage-gap or difficult-opponent upset wins; burst-heavy finishes are excluded.", 176, function()
        self:ToggleDamageRatingAdjustment()
    end)
    CreateSettingsRow("BUILD TESTING TOGGLE", "Ignore new duels for build testing; existing history, ratings, and win rate stay visible.", 276, function()
        self:ToggleDuelTracking()
    end)
    CreateSettingsRow("COPY DUEL SUMMARY", "Places a compact recent-duel summary into chat for copying or social sharing.", 376, function()
        self:ExportHistorySummary(3)
    end)

    local settingsNotesHelp = CreateLabel(settingsPanel, "ZoFontGame", 0.62, 0.70, 0.79)
    settingsNotesHelp:SetAnchor(TOPLEFT, settingsPanel, TOPLEFT, 4, 480)
    settingsNotesHelp:SetDimensions(720, 24)
    settingsNotesHelp:SetText("Opponent notes: /metrics note @name <note>   |   Remove: /metrics note clear @name")

    local commandsPanel = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    commandsPanel:SetAnchor(TOPLEFT, window, TOPLEFT, MAIN_CONTENT_LEFT, ROW_TOP)
    commandsPanel:SetDimensions(DEFAULT_WINDOW_WIDTH - MAIN_CONTENT_LEFT - 22, 690)
    commandsPanel:SetHidden(true)

    local commandsTitle = CreateLabel(commandsPanel, "ZoFontWinH1", 0.44, 0.78, 1)
    commandsTitle:SetAnchor(TOPLEFT, commandsPanel, TOPLEFT, 2, 0)
    commandsTitle:SetDimensions(420, 34)
    commandsTitle:SetText("COMMAND REFERENCE")

    local commandsIntro = CreateLabel(commandsPanel, "ZoFontGame", 0.70, 0.77, 0.85)
    commandsIntro:SetAnchor(TOPLEFT, commandsPanel, TOPLEFT, 4, 38)
    commandsIntro:SetDimensions(720, 24)
    commandsIntro:SetText("Type these in chat. /dl and /duelledger may be used in place of /metrics.")

    local commandRows = {}
    local commandDefinitions = {
        { "/metrics", "Print your W-L-D, neutral-draw win rate, and current rank progress." },
        { "/metrics ui", "Open or close the PvP-erformance journal." },
        { "/metrics share", "Prefill a chat-ready Overall Tier, selected Class Tier, and win-rate card." },
        { "/metrics duels [count]", "Print compact recent-duel summaries in chat (default: 10)." },
        { "/metrics history [count]", "Alias for /metrics duels [count]." },
        { "/metrics debug [count]", "Print the stored rating-modifier log for recent duels (default: 1)." },
        { "/metrics export [1-5]", "Prefill a compact, copyable recent-duel summary in the chat box." },
        { "/metrics note @name <note>", "Save a short note that appears on that opponent's aggregate row." },
        { "/metrics note clear @name", "Remove a saved opponent note." },
        { "/metrics ww scan", "Scan the reticle target for a visible Werewolf-form effect during countdown." },
        { "/metrics ww debug on|off", "Enable or disable the local Werewolf ability-ID diagnostic." },
        { "/metrics ww add <abilityId>", "Save a confirmed Werewolf-only ability ID for future detection." },
        { "/metrics help", "Print a compact command reminder in chat." },
    }
    for index, definition in ipairs(commandDefinitions) do
        local row = WINDOW_MANAGER:CreateControl(nil, commandsPanel, CT_BACKDROP)
        row:SetAnchor(TOPLEFT, commandsPanel, TOPLEFT, 0, 72 + (index - 1) * 46)
        row:SetDimensions(760, 42)
        row:SetCenterColor(0.045, 0.055, 0.08, 0.98)
        row:SetEdgeColor(0.17, 0.26, 0.36, 1)

        row.command = CreateLabel(row, "ZoFontGameBold", 0.44, 0.78, 1)
        row.command:SetAnchor(LEFT, row, LEFT, 14, 0)
        row.command:SetDimensions(250, 32)
        row.command:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        row.command:SetText(definition[1])

        row.detail = CreateLabel(row, "ZoFontGame", 0.72, 0.78, 0.86)
        row.detail:SetAnchor(LEFT, row.command, RIGHT, 12, 0)
        row.detail:SetDimensions(470, 32)
        row.detail:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        row.detail:SetScale(1.00)
        row.detail:SetText(definition[2])
        table.insert(commandRows, row)
    end

    local rows = {}
    local previousRow
    for index = 1, 6 do
        local row = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
        if previousRow then
            row:SetAnchor(TOPLEFT, previousRow, BOTTOMLEFT, 0, 6)
        else
            row:SetAnchor(TOPLEFT, window, TOPLEFT, MAIN_CONTENT_LEFT, ROW_TOP)
        end
        row:SetDimensions(876, JOURNAL_ROW_HEIGHT)
        row:SetCenterColor(0.075, 0.09, 0.13, 0.98)
        row:SetEdgeColor(0.17, 0.26, 0.36, 1)
        row:SetMouseEnabled(false)
        row:SetHandler("OnMouseUp", function(control, button)
            if button == MOUSE_BUTTON_INDEX_LEFT and control.entry and control.entry.kind == "aggregate" then
                self:OpenDetail(control.entry)
            end
        end)
        row:SetHandler("OnMouseEnter", function(control)
            if control.entry and control.entry.kind == "aggregate" then
                control:SetEdgeColor(0.36, 0.74, 1, 1)
            end
        end)
        row:SetHandler("OnMouseExit", function(control)
            if control.entry and control.entry.kind == "aggregate" then
                control:SetEdgeColor(0.17, 0.26, 0.36, 1)
            end
        end)

        row.result = CreateLabel(row, "ZoFontGameBold", 0.90, 0.90, 0.90)
        row.result:SetAnchor(TOPLEFT, row, TOPLEFT, 12, 5)
        row.result:SetDimensions(60, 22)

        row.opponent = CreateLabel(row, "ZoFontGame", 0.94, 0.94, 0.94)
        row.opponent:SetAnchor(TOPLEFT, row, TOPLEFT, 88, 5)
        row.opponent:SetDimensions(420, 22)

        row.time = CreateLabel(row, "ZoFontGame", 0.68, 0.75, 0.84)
        row.time:SetAnchor(TOPRIGHT, row, TOPRIGHT, -12, 5)
        row.time:SetDimensions(250, 22)
        row.time:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

        -- Duel rows use a compact right-hand statistics grid. It mirrors the
        -- separate Record/WR columns in aggregate rows, while keeping all
        -- stored combat data limited to the final damage totals.
        row.duelDateHeader = CreateLabel(row, "ZoFontGameBold", 0.70, 0.77, 0.85)
        row.duelDateHeader:SetDimensions(160, 16)
        row.duelDateHeader:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        row.duelDateHeader:SetScale(0.76)
        row.duelDateHeader:SetText("DATE")

        row.duelDurationHeader = CreateLabel(row, "ZoFontGameBold", 0.70, 0.77, 0.85)
        row.duelDurationHeader:SetDimensions(100, 16)
        row.duelDurationHeader:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        row.duelDurationHeader:SetScale(0.76)
        row.duelDurationHeader:SetText("DURATION")

        row.duelDamageDoneHeader = CreateLabel(row, "ZoFontGameBold", 0.70, 0.77, 0.85)
        row.duelDamageDoneHeader:SetDimensions(132, 16)
        row.duelDamageDoneHeader:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        row.duelDamageDoneHeader:SetScale(0.76)
        row.duelDamageDoneHeader:SetText("DAMAGE DONE")

        row.duelDamageTakenHeader = CreateLabel(row, "ZoFontGameBold", 0.70, 0.77, 0.85)
        row.duelDamageTakenHeader:SetDimensions(132, 16)
        row.duelDamageTakenHeader:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        row.duelDamageTakenHeader:SetScale(0.76)
        row.duelDamageTakenHeader:SetText("DAMAGE TAKEN")

        row.duelDate = CreateLabel(row, "ZoFontGame", 0.72, 0.81, 0.91)
        row.duelDate:SetDimensions(160, 20)
        row.duelDate:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        row.duelDate:SetScale(1.00)

        row.duelDuration = CreateLabel(row, "ZoFontGame", 0.72, 0.81, 0.91)
        row.duelDuration:SetDimensions(100, 20)
        row.duelDuration:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        row.duelDuration:SetScale(1.00)

        row.duelDamageDone = CreateLabel(row, "ZoFontGame", 0.46, 0.82, 1, 1)
        row.duelDamageDone:SetDimensions(132, 20)
        row.duelDamageDone:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        row.duelDamageDone:SetScale(1.00)

        row.duelDamageTaken = CreateLabel(row, "ZoFontGame", 1, 0.64, 0.60, 1)
        row.duelDamageTaken:SetDimensions(132, 20)
        row.duelDamageTaken:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        row.duelDamageTaken:SetScale(1.00)

        row.duelStatsDivider = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
        row.duelStatsDivider:SetDimensions(1, 52)
        row.duelStatsDivider:SetCenterColor(0.22, 0.34, 0.48, 1)
        row.duelStatsDivider:SetEdgeColor(0, 0, 0, 0)

        row.rate = CreateLabel(row, "ZoFontGame", 0.68, 0.75, 0.84)
        row.rate:SetAnchor(TOPRIGHT, row, TOPRIGHT, -12, 30)
        row.rate:SetDimensions(330, 18)
        row.rate:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        row.rate:SetHidden(true)

        row.recordHeader = CreateLabel(row, "ZoFontGameBold", 0.70, 0.77, 0.85)
        row.recordHeader:SetAnchor(TOPRIGHT, row, TOPRIGHT, -80, 12)
        row.recordHeader:SetDimensions(104, 16)
        row.recordHeader:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        row.recordHeader:SetScale(0.76)
        row.recordHeader:SetText("RECORD")
        row.recordHeader:SetHidden(true)

        row.rateHeader = CreateLabel(row, "ZoFontGameBold", 0.70, 0.77, 0.85)
        row.rateHeader:SetAnchor(TOPRIGHT, row, TOPRIGHT, -10, 12)
        row.rateHeader:SetDimensions(58, 16)
        row.rateHeader:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        row.rateHeader:SetScale(0.76)
        row.rateHeader:SetText("WR")
        row.rateHeader:SetHidden(true)

        row.statsDivider = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
        row.statsDivider:SetAnchor(TOPRIGHT, row, TOPRIGHT, -74, 10)
        row.statsDivider:SetDimensions(1, 64)
        row.statsDivider:SetCenterColor(0.22, 0.34, 0.48, 1)
        row.statsDivider:SetEdgeColor(0, 0, 0, 0)
        row.statsDivider:SetHidden(true)

        row.matchup = CreateLabel(row, "ZoFontGame", 0.70, 0.81, 0.92)
        row.matchup:SetAnchor(TOPLEFT, row, TOPLEFT, 12, 29)
        row.matchup:SetDimensions(750, 20)

        -- Keep the three per-duel rating fields deliberately separated. The
        -- gain/loss values use the regular game font so they remain readable
        -- at every supported journal size.
        row.ratingChange = CreateLabel(row, "ZoFontGameBold", 0.62, 0.70, 0.79)
        row.ratingChange:SetAnchor(TOPLEFT, row, TOPLEFT, 12, 65)
        row.ratingChange:SetDimensions(72, 20)
        row.ratingChange:SetScale(0.76)
        row.ratingChange:SetText("RATING")

        row.overallRatingChange = CreateLabel(row, "ZoFontGame", 0.62, 0.76, 0.90)
        row.overallRatingChange:SetAnchor(TOPLEFT, row, TOPLEFT, 92, 64)
        row.overallRatingChange:SetDimensions(104, 21)
        row.overallRatingChange:SetScale(1.00)

        row.ratingDivider = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
        row.ratingDivider:SetAnchor(TOPLEFT, row, TOPLEFT, 204, 65)
        row.ratingDivider:SetDimensions(1, 19)
        row.ratingDivider:SetCenterColor(0.22, 0.34, 0.48, 1)
        row.ratingDivider:SetEdgeColor(0, 0, 0, 0)

        row.classRatingChange = CreateLabel(row, "ZoFontGame", 0.62, 0.76, 0.90)
        row.classRatingChange:SetAnchor(TOPLEFT, row, TOPLEFT, 216, 64)
        row.classRatingChange:SetDimensions(100, 21)
        row.classRatingChange:SetScale(1.00)

        row.ratingPlacementDivider = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
        row.ratingPlacementDivider:SetAnchor(TOPLEFT, row, TOPLEFT, 322, 65)
        row.ratingPlacementDivider:SetDimensions(1, 19)
        row.ratingPlacementDivider:SetCenterColor(0.22, 0.34, 0.48, 1)
        row.ratingPlacementDivider:SetEdgeColor(0, 0, 0, 0)

        row.ratingPlacement = CreateLabel(row, "ZoFontGame", 0.70, 0.77, 0.85)
        row.ratingPlacement:SetAnchor(TOPLEFT, row, TOPLEFT, 334, 64)
        row.ratingPlacement:SetDimensions(136, 21)
        row.ratingPlacement:SetScale(1.00)

        row.damage = CreateLabel(row, "ZoFontGameSmall", 0.62, 0.75, 0.86)
        row.damage:SetAnchor(TOPLEFT, row, TOPLEFT, 12, 51)
        row.damage:SetDimensions(750, 18)

        -- A transparent top-layer control guarantees that every visible part
        -- of an aggregate row receives the click, including its labels.
        row.clickTarget = WINDOW_MANAGER:CreateControl(nil, row, CT_CONTROL)
        row.clickTarget:SetAnchorFill(row)
        row.clickTarget:SetMouseEnabled(false)
        row.clickTarget:SetHandler("OnMouseUp", function(_, button)
            if button ~= MOUSE_BUTTON_INDEX_LEFT or not row.entry then
                return
            end
            if row.entry.kind == "aggregate" then
                self:OpenDetail(row.entry)
            elseif row.entry.kind == "duel" and self:CanOpenDuelSummaryFromCurrentView() then
                self:OpenDuelSummary(row.entry.duel, {
                    tab = self.ui.activeTab,
                    detailFilter = self.ui.detailFilter,
                    page = self.ui.page,
                })
            end
        end)
        row.clickTarget:SetHandler("OnMouseEnter", function()
            if row.entry and (row.entry.kind == "aggregate" or self:CanOpenDuelSummaryFromCurrentView()) then
                row:SetEdgeColor(0.36, 0.74, 1, 1)
            end
        end)
        row.clickTarget:SetHandler("OnMouseExit", function()
            if row.entry and (row.entry.kind == "aggregate" or self:CanOpenDuelSummaryFromCurrentView()) then
                row:SetEdgeColor(0.17, 0.26, 0.36, 1)
            end
        end)

        rows[index] = row
        previousRow = row
    end

    local newer = CreateLabel(window, "ZoFontGameBold", 0.52, 0.79, 1)
    newer:SetAnchor(TOPLEFT, previousRow, BOTTOMLEFT, 0, 10)
    newer:SetDimensions(132, 30)
    newer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    newer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    newer:SetText("< Newer")
    newer:SetMouseEnabled(true)
    newer.navBorder = WINDOW_MANAGER:CreateControl(nil, newer, CT_BACKDROP)
    newer.navBorder:SetAnchorFill(newer)
    newer.navBorder:SetCenterColor(0, 0, 0, 0)
    newer.navBorder:SetEdgeColor(0.48, 0.52, 0.58, 1)
    newer.navBorder:SetDrawLayer(DL_BACKGROUND)
    newer:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and self.ui.page > 1 then
            self.ui.page = self.ui.page - 1
            self:RefreshUI()
        end
    end)

    local pageLabel = CreateLabel(window, "ZoFontGame", 0.88, 0.90, 0.94)
    pageLabel:SetAnchor(TOP, previousRow, BOTTOM, 0, 10)
    pageLabel:SetDimensions(180, 28)
    pageLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local older = CreateLabel(window, "ZoFontGameBold", 0.52, 0.79, 1)
    older:SetAnchor(TOPRIGHT, previousRow, BOTTOMRIGHT, 0, 10)
    older:SetDimensions(132, 30)
    older:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    older:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    older:SetText("Older >")
    older:SetMouseEnabled(true)
    older.navBorder = WINDOW_MANAGER:CreateControl(nil, older, CT_BACKDROP)
    older.navBorder:SetAnchorFill(older)
    older.navBorder:SetCenterColor(0, 0, 0, 0)
    older.navBorder:SetEdgeColor(0.48, 0.52, 0.58, 1)
    older.navBorder:SetDrawLayer(DL_BACKGROUND)
    older:SetHandler("OnMouseUp", function(_, button)
        local pageCount = math.max(1, math.ceil(#self:GetViewEntries() / #self.ui.rows))
        if button == MOUSE_BUTTON_INDEX_LEFT and self.ui.page < pageCount then
            self.ui.page = self.ui.page + 1
            self:RefreshUI()
        end
    end)

    -- The ranking guide is intentionally independent of the journal dimensions.
    -- It uses most of GuiRoot so the full rating system remains readable without
    -- forcing the journal itself to become nearly full-screen.
    local rankingInfoOverlay = WINDOW_MANAGER:CreateTopLevelWindow("PvPerformanceRankingInfoOverlay")
    rankingInfoOverlay:SetAnchorFill(GuiRoot)
    rankingInfoOverlay:SetDrawTier(DT_HIGH)
    rankingInfoOverlay:SetHidden(true)

    local rankingInfoDim = WINDOW_MANAGER:CreateControl(nil, rankingInfoOverlay, CT_TEXTURE)
    rankingInfoDim:SetAnchorFill(rankingInfoOverlay)
    rankingInfoDim:SetColor(0, 0, 0, 0.76)
    rankingInfoDim:SetMouseEnabled(true)
    rankingInfoDim:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:HideRankingInfoPanel()
        end
    end)

    local rootWidth = GuiRoot:GetWidth()
    local rootHeight = GuiRoot:GetHeight()
    local rankingPanelWidth = math.floor(math.min(rootWidth - 40, math.max(1180, rootWidth * 0.94)))
    local rankingPanelHeight = math.floor(math.min(rootHeight - 24, math.max(860, rootHeight * 0.96)))
    local panelMargin = 34
    local tierColumnWidth = math.floor(math.min(390, math.max(360, rankingPanelWidth * 0.215)))
    local columnDividerX = panelMargin + tierColumnWidth + 20
    local rulesStartX = columnDividerX + 34
    local rulesWidth = rankingPanelWidth - rulesStartX - panelMargin
    local rulesGap = 32
    local ruleColumnWidth = math.floor((rulesWidth - rulesGap) / 2)
    local footerTop = rankingPanelHeight - 158
    local tierRowStep = math.floor(math.min(44, math.max(34, (footerTop - 220) / #RANK_THRESHOLDS)))
    local tierRowHeight = math.max(30, tierRowStep - 6)

    local rankingInfoPanel = WINDOW_MANAGER:CreateControl(nil, rankingInfoOverlay, CT_BACKDROP)
    rankingInfoPanel:SetAnchor(CENTER, rankingInfoOverlay, CENTER, 0, 0)
    rankingInfoPanel:SetDimensions(rankingPanelWidth, rankingPanelHeight)
    rankingInfoPanel:SetCenterColor(0.015, 0.02, 0.032, 1)
    rankingInfoPanel:SetEdgeColor(0.36, 0.74, 1, 1)
    rankingInfoPanel:SetMouseEnabled(true)

    local rankingInfoPanelClickTarget = WINDOW_MANAGER:CreateControl(nil, rankingInfoPanel, CT_CONTROL)
    rankingInfoPanelClickTarget:SetAnchorFill(rankingInfoPanel)
    rankingInfoPanelClickTarget:SetMouseEnabled(true)

    local rankingInfoTitle = CreateLabel(rankingInfoPanel, "ZoFontWinH1", 0.44, 0.78, 1)
    rankingInfoTitle:SetAnchor(TOPLEFT, rankingInfoPanel, TOPLEFT, panelMargin, 14)
    rankingInfoTitle:SetDimensions(rankingPanelWidth - panelMargin * 2, 60)
    rankingInfoTitle:SetScale(1.50)
    rankingInfoTitle:SetText("DUELING TIER PROGRESSION")

    local rankingInfoRule = WINDOW_MANAGER:CreateControl(nil, rankingInfoPanel, CT_BACKDROP)
    rankingInfoRule:SetAnchor(TOPLEFT, rankingInfoPanel, TOPLEFT, panelMargin, 84)
    rankingInfoRule:SetDimensions(rankingPanelWidth - panelMargin * 2, 2)
    rankingInfoRule:SetCenterColor(0.30, 0.58, 0.84, 0.85)
    rankingInfoRule:SetEdgeColor(0, 0, 0, 0)

    local rankingInfoBlurb = CreateLabel(rankingInfoPanel, "ZoFontGameSmall", 0.68, 0.76, 0.86)
    rankingInfoBlurb:SetAnchor(TOPLEFT, rankingInfoPanel, TOPLEFT, panelMargin, 102)
    rankingInfoBlurb:SetDimensions(math.floor((tierColumnWidth - 8) / 1.30), 64)
    rankingInfoBlurb:SetScale(1.30)
    rankingInfoBlurb:SetText("Your Overall Tier appears after placement. The 0-100 point ladder is shown below;\nyour current tier is highlighted.")

    local tierColumnHeader = CreateLabel(rankingInfoPanel, "ZoFontGameBold", 0.52, 0.79, 1)
    tierColumnHeader:SetAnchor(TOPLEFT, rankingInfoPanel, TOPLEFT, panelMargin, 190)
    tierColumnHeader:SetDimensions(math.floor(tierColumnWidth / 1.25), 24)
    tierColumnHeader:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    tierColumnHeader:SetScale(1.25)
    tierColumnHeader:SetText("TIER / RATING")

    local rankingInfoColumnDivider = WINDOW_MANAGER:CreateControl(nil, rankingInfoPanel, CT_BACKDROP)
    rankingInfoColumnDivider:SetAnchor(TOPLEFT, rankingInfoPanel, TOPLEFT, columnDividerX, 102)
    rankingInfoColumnDivider:SetDimensions(2, footerTop - 114)
    rankingInfoColumnDivider:SetCenterColor(0.22, 0.43, 0.64, 0.78)
    rankingInfoColumnDivider:SetEdgeColor(0, 0, 0, 0)

    local rankingRulesTitle = CreateLabel(rankingInfoPanel, "ZoFontGameBold", 0.44, 0.78, 1)
    rankingRulesTitle:SetAnchor(TOPLEFT, rankingInfoPanel, TOPLEFT, rulesStartX, 102)
    rankingRulesTitle:SetDimensions(math.floor(rulesWidth / 1.45), 32)
    rankingRulesTitle:SetScale(1.45)
    rankingRulesTitle:SetText("RANKING RULES")

    local rankingRulesDivider = WINDOW_MANAGER:CreateControl(nil, rankingInfoPanel, CT_BACKDROP)
    rankingRulesDivider:SetAnchor(TOPLEFT, rankingInfoPanel, TOPLEFT, rulesStartX, 140)
    rankingRulesDivider:SetDimensions(rulesWidth, 1)
    rankingRulesDivider:SetCenterColor(0.16, 0.30, 0.44, 0.9)
    rankingRulesDivider:SetEdgeColor(0, 0, 0, 0)

    local rankingRulesColumnDivider = WINDOW_MANAGER:CreateControl(nil, rankingInfoPanel, CT_BACKDROP)
    rankingRulesColumnDivider:SetAnchor(
        TOPLEFT,
        rankingInfoPanel,
        TOPLEFT,
        rulesStartX + ruleColumnWidth + math.floor(rulesGap / 2),
        166
    )
    rankingRulesColumnDivider:SetDimensions(1, footerTop - 178)
    rankingRulesColumnDivider:SetCenterColor(0.12, 0.23, 0.34, 0.75)
    rankingRulesColumnDivider:SetEdgeColor(0, 0, 0, 0)

    local rankingInfoTierRows = {}
    local function TierRangeText(index, rank)
        local nextHigherRank = RANK_THRESHOLDS[index - 1]
        if not nextHigherRank then
            return string.format("%d - 100", rank.minimum)
        end

        return string.format("%d - %d", rank.minimum, nextHigherRank.minimum - 1)
    end

    for index, rank in ipairs(RANK_THRESHOLDS) do
        local row = WINDOW_MANAGER:CreateControl(nil, rankingInfoPanel, CT_BACKDROP)
        row:SetAnchor(TOPLEFT, rankingInfoPanel, TOPLEFT, panelMargin, 226 + (index - 1) * tierRowStep)
        row:SetDimensions(tierColumnWidth, tierRowHeight)
        row:SetCenterColor(0.025, 0.03, 0.045, 1)
        row:SetEdgeColor(0.16, 0.24, 0.34, 1)

        row.highlight = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
        row.highlight:SetAnchorFill(row)
        row.highlight:SetColor(rank.color[1], rank.color[2], rank.color[3], 0.16)
        row.highlight:SetHidden(true)

        local badge = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
        badge:SetAnchor(LEFT, row, LEFT, 10, 0)
        badge:SetDimensions(76, 29)
        badge:SetCenterColor(0.015, 0.02, 0.03, 1)
        badge:SetEdgeColor(rank.color[1], rank.color[2], rank.color[3], 1)

        local badgeText = CreateLabel(badge, "ZoFontGameBold", rank.color[1], rank.color[2], rank.color[3])
        badgeText:SetAnchor(CENTER, badge, CENTER, 0, -1)
        badgeText:SetDimensions(70, 26)
        badgeText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        badgeText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        badgeText:SetScale(1.35)
        badgeText:SetText(rank.name)

        local tierName = CreateLabel(row, "ZoFontGameBold", 0.88, 0.90, 0.94)
        tierName:SetAnchor(LEFT, badge, RIGHT, 18, 0)
        tierName:SetDimensions(140, 30)
        tierName:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        tierName:SetScale(1.35)
        tierName:SetText(string.format("%s Tier", rank.name))

        local range = CreateLabel(row, "ZoFontGame", rank.color[1], rank.color[2], rank.color[3])
        range:SetAnchor(RIGHT, row, RIGHT, -12, 0)
        range:SetDimensions(105, 30)
        range:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        range:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        range:SetScale(1.35)
        range:SetText(TierRangeText(index, rank))

        rankingInfoTierRows[rank.name] = row
    end

    local rankingInfoPlacement = CreateLabel(rankingInfoPanel, "ZoFontGame", 0.72, 0.79, 0.88)
    rankingInfoPlacement:SetAnchor(TOPLEFT, rankingInfoPanel, TOPLEFT, rulesStartX + 12, 166)
    rankingInfoPlacement:SetDimensions(
        math.floor((ruleColumnWidth - 24) / 1.10),
        math.floor((footerTop - 186) / 1.10)
    )
    rankingInfoPlacement:SetScale(1.10)
    rankingInfoPlacement:SetText(
        "|c73C7FFPLACEMENT & BASE RATING|r\n\n"
        .. "Placement requires 20 decisive results against at least 15 opponents. Only 2 results from the same opponent can count.\n\n"
        .. "Everyone starts from 50. Each placement win moves the starting rating up by 2 points and each loss moves it down by 2, with a final placement range of 40 to 84. The next 20 decisive results are marked PROV.\n\n"
        .. "After placement, a standard win adds half a point, a standard loss removes half a point, and a draw or forfeit changes nothing. Ratings stay between 0 and 100.\n\n"
        .. "|c73C7FFREPEAT-OPPONENT ANTI-FARMING|r\n\n"
        .. "Successive wins against one opponent award 100%, 75%, 50%, 25%, then 2%. At standard rating value, an exhausted win adds only one-hundredth of a point, so 100 exhausted wins are needed for 1 point before other modifiers.\n\n"
        .. "A loss before exhaustion lowers fatigue by one step; draws do not restore value.\n\n"
        .. "An exhausted matchup resets either after 48 real-world hours or after 10 decisive duels against other opponents that include at least 5 different players. If five opponents are exhausted together, they provide only four other players for each activity-based lock. You must duel a sixth different player before that kind of reset is possible."
    )

    local rankingInfoDiminishing = CreateLabel(rankingInfoPanel, "ZoFontGame", 0.72, 0.79, 0.88)
    rankingInfoDiminishing:SetAnchor(TOPLEFT, rankingInfoPanel, TOPLEFT, rulesStartX + ruleColumnWidth + rulesGap + 12, 166)
    rankingInfoDiminishing:SetDimensions(
        math.floor((ruleColumnWidth - 24) / 1.10),
        math.floor((footerTop - 186) / 1.10)
    )
    rankingInfoDiminishing:SetScale(1.10)
    rankingInfoDiminishing:SetText(
        "|c73C7FFSTREAK & HIGH-TIER MODIFIERS|r\n\n"
        .. "Losing after one prior win costs 5% more. Losing after two or more prior wins costs 10% more.\n\n"
        .. "At S-, wins award 65% of their normal value and losses cost 95% of normal. At S, wins award 50% and losses cost 90%. At S+, wins award 35% and losses cost 85%. Ratings below S- use normal values.\n\n"
        .. "|c73C7FFUPSET VICTORY & PROTECTION|r\n\n"
        .. "A qualifying post-placement upset victory awards 15% more rating. Multiple qualifying reasons never stack.\n\n"
        .. "For a pressure-disadvantage upset, the duel must last at least 20 seconds, contain at least 150,000 combined damage, and meet a damage gap that grows with duel duration. Your strongest 3-second burst cannot account for more than 60% of all outgoing damage.\n\n"
        .. "A victory can also qualify after at least 5 prior decisive duels against an opponent you beat no more than one-third of the time.\n\n"
        .. "Possible, Likely, and Strong suspected CC locks reduce a loss by 10%, 20%, and 25%. Lag flags are diagnostic only."
    )

    local rankingInfoFooterDivider = WINDOW_MANAGER:CreateControl(nil, rankingInfoPanel, CT_BACKDROP)
    rankingInfoFooterDivider:SetAnchor(TOPLEFT, rankingInfoPanel, TOPLEFT, panelMargin, footerTop)
    rankingInfoFooterDivider:SetDimensions(rankingPanelWidth - panelMargin * 2, 1)
    rankingInfoFooterDivider:SetCenterColor(0.16, 0.30, 0.44, 0.9)
    rankingInfoFooterDivider:SetEdgeColor(0, 0, 0, 0)

    local rankingInfoClass = CreateLabel(rankingInfoPanel, "ZoFontGame", 0.52, 0.79, 1)
    rankingInfoClass:SetAnchor(TOPLEFT, rankingInfoPanel, TOPLEFT, panelMargin, footerTop + 14)
    rankingInfoClass:SetDimensions(math.floor((rankingPanelWidth - panelMargin * 2 - 170) / 1.08), 104)
    rankingInfoClass:SetScale(1.08)
    rankingInfoClass:SetText(
        "Overall Tier records raw results. Class Tier is independent per class and adjusts expected matchups. Win Rate counts wins and losses only; draws are neutral.\n"
        .. "Ratings are local progression, not official ESO MMR or a verified global percentile. Class coefficients are patch-dependent; CC and damage signals are API-based approximations. No results are uploaded automatically."
    )

    local rankingInfoClose = WINDOW_MANAGER:CreateControl(nil, rankingInfoPanel, CT_BACKDROP)
    rankingInfoClose:SetAnchor(BOTTOMRIGHT, rankingInfoPanel, BOTTOMRIGHT, -28, -24)
    rankingInfoClose:SetDimensions(120, 44)
    rankingInfoClose:SetCenterColor(0.025, 0.03, 0.05, 1)
    rankingInfoClose:SetEdgeColor(0.36, 0.74, 1, 1)

    local rankingInfoCloseText = CreateLabel(rankingInfoClose, "ZoFontGameBold", 0.82, 0.88, 0.96)
    rankingInfoCloseText:SetAnchor(CENTER, rankingInfoClose, CENTER, 0, 0)
    rankingInfoCloseText:SetDimensions(128, 32)
    rankingInfoCloseText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    rankingInfoCloseText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    rankingInfoCloseText:SetScale(1.30)
    rankingInfoCloseText:SetText("CLOSE")

    local rankingInfoCloseClickTarget = WINDOW_MANAGER:CreateControl(nil, rankingInfoClose, CT_CONTROL)
    rankingInfoCloseClickTarget:SetAnchorFill(rankingInfoClose)
    rankingInfoCloseClickTarget:SetMouseEnabled(true)
    rankingInfoCloseClickTarget:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:HideRankingInfoPanel()
        end
    end)

    window:SetHandler("OnMoveStop", function()
        self:SaveWindowPosition()
    end)
    window:SetHandler("OnResizeStop", function()
        self:ApplyWindowLayout()
        self:SaveWindowPosition()
        self:RefreshUI()
    end)
    window:SetHandler("OnUpdate", function()
        self:UpdateTierCardGlowEffects()
    end)
    window:SetHidden(true)

    self.ui = {
        window = window,
        summary = summary,
        uniqueOpponents = uniqueOpponents,
        record = record,
        rows = rows,
        headerDivider = headerDivider,
        moduleTab = moduleTab,
        moduleTabBorder = moduleTabBorder,
        moduleUnderline = moduleUnderline,
        titleModuleDivider = titleModuleDivider,
        modulePlayerDivider = modulePlayerDivider,
        overallTierCard = overallTierCard,
        classTierCard = classTierCard,
        overallTierInfo = overallTierInfo,
        classTierInfo = classTierInfo,
        rankingInfoOverlay = rankingInfoOverlay,
        rankingInfoTierRows = rankingInfoTierRows,
        rankingInfoTitle = rankingInfoTitle,
        rankingInfoBlurb = rankingInfoBlurb,
        rankingInfoPlacement = rankingInfoPlacement,
        rankingInfoDiminishing = rankingInfoDiminishing,
        rankingInfoClass = rankingInfoClass,
        newer = newer,
        older = older,
        pageLabel = pageLabel,
        winRate = winRate,
        winRateBox = winRateBox,
        winRateEffectCard = winRateEffectCard,
        tierBox = tierBox,
        tierCaption = tierCaption,
        tierProgress = tierProgress,
        tierProgressFill = tierProgressFill,
        tierProgressLabel = tierProgressLabel,
        classTierBox = classTierCard.box,
        classTierCaption = classTierCard.caption,
        classTier = classTierCard.tier,
        classTierProgress = classTierCard.progress,
        classTierProgressFill = classTierCard.progressFill,
        classTierProgressLabel = classTierCard.progressLabel,
        classTierSelector = classTierSelector,
        classTierSelectorText = classTierSelectorText,
        classTierSelectorClickTarget = classTierSelectorClickTarget,
        playerName = playerName,
        headerClassIcon = headerClassIcon,
        headerChampionPoints = headerChampionPoints,
        recordBox = recordBox,
        summaryRailDivider = summaryRailDivider,
        tier = tier,
        tabs = tabs,
        detailBack = detailBack,
        searchLabel = searchLabel,
        searchBackdrop = searchBackdrop,
        searchInput = searchInput,
        aggregateSortBackdrop = aggregateSortBackdrop,
        aggregateSortLabel = aggregateSortLabel,
        aggregateSortClickTarget = aggregateSortClickTarget,
        aggregateSort = {
            opponents = { key = "total" },
            classes = { key = "total" },
        },
        statisticsPanel = statisticsPanel,
        statMetricCards = statMetricCards,
        statDetailCards = statDetailCards,
        dangerousBoard = dangerousBoard,
        easiestBoard = easiestBoard,
        statisticsTrendGraph = statisticsTrendGraph,
        statisticsTrendButtons = statisticsTrendButtons,
        statisticsTrendMode = "rating",
        opponentPerformancePanel = opponentPerformancePanel,
        opponentPerformanceTitle = opponentPerformanceTitle,
        opponentPerformanceLines = opponentPerformanceLines,
        opponentPerformanceLastFive = opponentPerformanceLastFive,
        opponentPerformanceGraph = opponentPerformanceGraph,
        duelDetailPanel = duelDetailPanel,
        duelDetailTitle = duelDetailTitle,
        duelDetailSubtitle = duelDetailSubtitle,
        duelDetailNotice = duelDetailNotice,
        duelDetailAnalyticsButton = duelDetailAnalyticsButton,
        duelDetailSummaryRow = duelDetailSummaryRow,
        duelDetailSummaryCards = duelDetailSummaryCards,
        duelDetailTotals = duelDetailTotals,
        duelDetailDamageDoneBoard = duelDetailDamageDoneBoard,
        duelDetailDamageTakenBoard = duelDetailDamageTakenBoard,
        settingsPanel = settingsPanel,
        settingsRows = settingsRows,
        settingsIntro = settingsIntro,
        settingsNotesHelp = settingsNotesHelp,
        commandsPanel = commandsPanel,
        commandsIntro = commandsIntro,
        commandRows = commandRows,
        activeTab = "recent",
        searchText = "",
        detailFilter = nil,
        selectedDuel = nil,
        duelSummarySource = nil,
        mainContentMode = "dashboard",
        page = 1,
    }
    self:ApplyUIScale()
    self:ApplyWindowLayout()
end

