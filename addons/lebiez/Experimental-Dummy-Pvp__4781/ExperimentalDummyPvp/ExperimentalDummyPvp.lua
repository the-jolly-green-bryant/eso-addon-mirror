ExperimentalDummyPvp = ExperimentalDummyPvp or {}

local PDC = ExperimentalDummyPvp
PDC.name = "ExperimentalDummyPvp"
PDC.displayName = "Experimental Dummy PvP"
PDC.version = "0.1.9"
PDC.savedVariableVersion = 1

PDC.defaults = {
    enabled = true,
    onlyTrainingDummies = true,
    dummyResistance = 18200,
    targetResistance = 33000,
    penetration = 0,
    battleSpiritReduction = 50,
    extraMitigation = 0,
    resistanceCap = 50,
    attackerCriticalDamage = 50,
    targetCriticalResistance = 1320,
    showOriginal = true,
    showAbility = true,
    displayDuration = 1400,
    displayScale = 1.0,
    debug = false,
    showSummaryAfterCombat = false,
    summaryMaxRows = 12,
    summaryLeft = nil,
    summaryTop = nil,
}

local DAMAGE_RESULTS = {}

local function AddDamageResult(result)
    if result ~= nil then
        DAMAGE_RESULTS[result] = true
    end
end

AddDamageResult(ACTION_RESULT_DAMAGE)
AddDamageResult(ACTION_RESULT_CRITICAL_DAMAGE)
AddDamageResult(ACTION_RESULT_DOT_TICK)
AddDamageResult(ACTION_RESULT_DOT_TICK_CRITICAL)
AddDamageResult(ACTION_RESULT_BLOCKED_DAMAGE)
AddDamageResult(ACTION_RESULT_DAMAGE_SHIELDED)

local function Clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

function PDC:GetResistanceMitigation(resistance, penetration)
    local effectiveResistance = math.max(0, (tonumber(resistance) or 0) - (tonumber(penetration) or 0))
    -- At level 50/CP, 33,000 resistance corresponds to 50% mitigation.
    local mitigation = effectiveResistance / 66000
    return Clamp(mitigation, 0, (self.sv.resistanceCap or 50) / 100)
end

function PDC:GetCriticalMultiplier(isCritical)
    if not isCritical then
        return 1, 0
    end

    local attackerCriticalBonus = math.max(0, (tonumber(self.sv.attackerCriticalDamage) or 0) / 100)
    -- At level 50, 66 Critical Resistance removes 1 percentage point
    -- from the attacker's critical damage bonus.
    local criticalReduction = math.max(0, (tonumber(self.sv.targetCriticalResistance) or 0) / 6600)
    local reducedCriticalBonus = math.max(0, attackerCriticalBonus - criticalReduction)

    -- The observed dummy hit already contains the attacker's full critical
    -- multiplier, so replace it with the multiplier remaining against the target.
    return (1 + reducedCriticalBonus) / (1 + attackerCriticalBonus), criticalReduction
end

function PDC:ConvertDamage(hitValue, isCritical)
    local observed = math.max(0, tonumber(hitValue) or 0)
    local dummyMitigation = self:GetResistanceMitigation(self.sv.dummyResistance, self.sv.penetration)
    local unmitigated = observed

    if dummyMitigation < 1 then
        unmitigated = observed / (1 - dummyMitigation)
    end

    local targetMitigation = self:GetResistanceMitigation(self.sv.targetResistance, self.sv.penetration)
    local battleSpirit = Clamp((self.sv.battleSpiritReduction or 0) / 100, 0, 0.99)
    local extraMitigation = Clamp((self.sv.extraMitigation or 0) / 100, 0, 0.99)
    local criticalMultiplier, criticalReduction = self:GetCriticalMultiplier(isCritical)

    return zo_round(unmitigated * (1 - targetMitigation) * (1 - battleSpirit) * (1 - extraMitigation) * criticalMultiplier), {
        observed = observed,
        unmitigated = unmitigated,
        dummyMitigation = dummyMitigation,
        targetMitigation = targetMitigation,
        battleSpirit = battleSpirit,
        extraMitigation = extraMitigation,
        criticalMultiplier = criticalMultiplier,
        criticalReduction = criticalReduction,
    }
end

function PDC:ResetSession()
    self.session = {
        startTime = nil,
        endTime = nil,
        targetName = "",
        originalTotal = 0,
        convertedTotal = 0,
        hits = 0,
        crits = 0,
        abilities = {},
        events = {},
        inCombat = false,
        completed = false,
    }
    if self.summary then
        self.summary:SetHidden(true)
    end
end

function PDC:RecordDamage(result, abilityId, abilityName, targetName, original, converted)
    -- ESO may dispatch the first damage event before EVENT_PLAYER_COMBAT_STATE.
    -- Start a fresh session here when the preceding encounter was completed.
    if self.session.completed then
        self:ResetSession()
    end

    local now = GetGameTimeMilliseconds()
    -- Fallback for combat events received before EVENT_PLAYER_COMBAT_STATE.
    if not self.session.startTime then
        self.session.startTime = now
    end
    self.session.endTime = now
    self.session.targetName = zo_strformat(SI_UNIT_NAME, targetName or "")
    self.session.originalTotal = self.session.originalTotal + original
    self.session.convertedTotal = self.session.convertedTotal + converted
    self.session.hits = self.session.hits + 1

    local critical = result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_DOT_TICK_CRITICAL
    if critical then
        self.session.crits = self.session.crits + 1
    end

    local key = abilityId and abilityId > 0 and abilityId or (abilityName or "Inconnu")
    local row = self.session.abilities[key]
    if not row then
        row = {
            id = abilityId or 0,
            name = zo_strformat(SI_ABILITY_NAME, abilityName or "Inconnu"),
            original = 0,
            converted = 0,
            hits = 0,
            crits = 0,
            maximum = 0,
        }
        self.session.abilities[key] = row
    end
    row.original = row.original + original
    row.converted = row.converted + converted
    row.hits = row.hits + 1
    row.maximum = math.max(row.maximum, converted)
    if critical then row.crits = row.crits + 1 end

    self.session.events[#self.session.events + 1] = {
        timestamp = now,
        result = result,
        critical = critical,
        abilityId = abilityId or 0,
        abilityName = zo_strformat(SI_ABILITY_NAME, abilityName or "Unknown"),
        targetName = zo_strformat(SI_UNIT_NAME, targetName or "Unknown Target"),
        original = original,
        converted = converted,
    }
end

function PDC:GetSessionDuration()
    if not self.session or not self.session.startTime then return 0 end
    return math.max(1, ((self.session.endTime or GetGameTimeMilliseconds()) - self.session.startTime) / 1000)
end

function PDC:IsLikelyTrainingDummy(targetName, targetType)
    if not self.sv.onlyTrainingDummies then
        return true
    end

    -- Training dummies are NPC targets. This intentionally avoids language-specific
    -- name matching; combat against players and player pets is excluded.
    if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER_PET then
        return false
    end

    return targetName ~= nil and targetName ~= ""
end

function PDC:FormatNumber(value)
    value = tonumber(value) or 0
    if ZO_LocalizeDecimalNumber then
        return ZO_LocalizeDecimalNumber(value)
    end
    return tostring(value)
end

function PDC:ShowConvertedDamage(converted, original, abilityName)
    if not self.outputLabel then
        return
    end

    local parts = {}
    if self.sv.showAbility and abilityName and abilityName ~= "" then
        parts[#parts + 1] = zo_strformat(SI_ABILITY_NAME, abilityName)
    end
    parts[#parts + 1] = string.format("|cE94B3C%s PvP|r", self:FormatNumber(converted))
    if self.sv.showOriginal then
        parts[#parts + 1] = string.format("|cAAAAAA(%s dummy)|r", self:FormatNumber(original))
    end

    self.outputLabel:SetText(table.concat(parts, "  "))
    self.output:SetScale(self.sv.displayScale or 1)
    self.output:SetHidden(false)

    EVENT_MANAGER:UnregisterForUpdate(self.name .. "HideOutput")
    EVENT_MANAGER:RegisterForUpdate(self.name .. "HideOutput", self.sv.displayDuration or 1400, function()
        EVENT_MANAGER:UnregisterForUpdate(self.name .. "HideOutput")
        self.output:SetHidden(true)
    end)
end

function PDC:OnCombatEvent(result, abilityName, sourceName, sourceType, targetName, targetType, hitValue, abilityId)
    if not self.sv.enabled or not DAMAGE_RESULTS[result] or (hitValue or 0) <= 0 then
        return
    end

    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end

    if not self:IsLikelyTrainingDummy(targetName, targetType) then
        return
    end

    local isCritical = result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_DOT_TICK_CRITICAL
    local converted, details = self:ConvertDamage(hitValue, isCritical)
    self:RecordDamage(result, abilityId, abilityName, targetName, hitValue, converted)
    self:ShowConvertedDamage(converted, hitValue, abilityName)

    if self.sv.debug then
        d(string.format("[PDC] %s: %d -> %d (dummy %.1f%%, target %.1f%%, crit resistance %.1f%%)",
            abilityName or "?", hitValue, converted,
            details.dummyMitigation * 100, details.targetMitigation * 100,
            details.criticalReduction * 100))
    end
end

local function CreateLabel(parent, name, font, color, align)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font or "ZoFontGame")
    label:SetColor(unpack(color or { 1, 1, 1, 1 }))
    label:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

function PDC:CreateSummaryWindow()
    local win = WINDOW_MANAGER:CreateTopLevelWindow(self.name .. "Summary")
    self.summary = win
    win:SetDimensions(900, 590)
    if self.sv.summaryLeft and self.sv.summaryTop then
        win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.sv.summaryLeft, self.sv.summaryTop)
    else
        win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    win:SetMovable(true)
    win:SetMouseEnabled(true)
    win:SetClampedToScreen(true)
    win:SetDrawTier(DT_HIGH)
    win:SetHidden(true)
    win:SetHandler("OnMoveStop", function(control)
        self.sv.summaryLeft = control:GetLeft()
        self.sv.summaryTop = control:GetTop()
    end)

    local bg = WINDOW_MANAGER:CreateControl(self.name .. "SummaryBG", win, CT_BACKDROP)
    bg:SetAnchorFill(win)
    bg:SetCenterColor(0.015, 0.02, 0.03, 0.94)
    bg:SetEdgeColor(0.5, 0.75, 0.9, 0.9)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16)
    bg:SetInsets(8, 8, -8, -8)

    local title = CreateLabel(win, self.name .. "SummaryTitle", "$(BOLD_FONT)|22|soft-shadow-thick", { 0.4, 0.85, 1, 1 }, TEXT_ALIGN_CENTER)
    title:SetAnchor(TOPLEFT, win, TOPLEFT, 18, 10)
    title:SetAnchor(TOPRIGHT, win, TOPRIGHT, -18, 10)
    title:SetHeight(34)
    title:SetText("Simulated PvP Summary")

    self.summaryTabButton = WINDOW_MANAGER:CreateControl(self.name .. "SummaryTabButton", win, CT_BUTTON)
    self.summaryTabButton:SetDimensions(100, 28)
    self.summaryTabButton:SetAnchor(TOPLEFT, win, TOPLEFT, 125, 13)
    self.summaryTabButton:SetFont("ZoFontGameBold")
    self.summaryTabButton:SetText("Summary")
    self.summaryTabButton:SetHandler("OnClicked", function() self:SetSummaryTab("summary") end)

    self.logTabButton = WINDOW_MANAGER:CreateControl(self.name .. "LogTabButton", win, CT_BUTTON)
    self.logTabButton:SetDimensions(100, 28)
    self.logTabButton:SetAnchor(LEFT, self.summaryTabButton, RIGHT, 4, 0)
    self.logTabButton:SetFont("ZoFontGameBold")
    self.logTabButton:SetText("Event Log")
    self.logTabButton:SetHandler("OnClicked", function() self:SetSummaryTab("log") end)

    local close = WINDOW_MANAGER:CreateControl(self.name .. "SummaryClose", win, CT_BUTTON)
    close:SetDimensions(36, 32)
    close:SetAnchor(TOPRIGHT, win, TOPRIGHT, -8, 8)
    close:SetFont("$(BOLD_FONT)|22")
    close:SetText("×")
    close:SetHandler("OnClicked", function() win:SetHidden(true) end)

    local reset = WINDOW_MANAGER:CreateControl(self.name .. "SummaryReset", win, CT_BUTTON)
    reset:SetDimensions(100, 30)
    reset:SetAnchor(TOPLEFT, win, TOPLEFT, 14, 12)
    reset:SetFont("ZoFontGameBold")
    reset:SetText("Reset")
    reset:SetHandler("OnClicked", function() self:ResetSession() end)

    self.summaryTarget = CreateLabel(win, self.name .. "SummaryTarget", "ZoFontGameBold", { 1, 0.75, 0.3, 1 }, TEXT_ALIGN_CENTER)
    self.summaryTarget:SetAnchor(TOPLEFT, win, TOPLEFT, 20, 52)
    self.summaryTarget:SetAnchor(TOPRIGHT, win, TOPRIGHT, -20, 52)
    self.summaryTarget:SetHeight(28)

    local cardNames = { "Duration", "Actual DPS", "PvP DPS", "Actual Damage", "PvP Damage", "Critical Hits" }
    self.summaryCards = {}
    self.summaryCardControls = {}
    local cardWidth = 140
    for index, name in ipairs(cardNames) do
        local card = WINDOW_MANAGER:CreateControl(self.name .. "Card" .. index, win, CT_BACKDROP)
        card:SetDimensions(cardWidth, 64)
        card:SetAnchor(TOPLEFT, win, TOPLEFT, 20 + (index - 1) * 144, 86)
        card:SetCenterColor(0.04, 0.07, 0.10, 0.95)
        card:SetEdgeColor(0.18, 0.35, 0.45, 1)
        card:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16)
        local heading = CreateLabel(card, self.name .. "CardHeading" .. index, "ZoFontGameSmall", { 0.7, 0.8, 0.85, 1 }, TEXT_ALIGN_CENTER)
        heading:SetAnchor(TOPLEFT, card, TOPLEFT, 4, 3)
        heading:SetAnchor(TOPRIGHT, card, TOPRIGHT, -4, 3)
        heading:SetHeight(22)
        heading:SetText(name)
        local value = CreateLabel(card, self.name .. "CardValue" .. index, "$(BOLD_FONT)|18", { 0.85, 1, 0.35, 1 }, TEXT_ALIGN_CENTER)
        value:SetAnchor(TOPLEFT, card, TOPLEFT, 4, 27)
        value:SetAnchor(TOPRIGHT, card, TOPRIGHT, -4, 27)
        value:SetHeight(28)
        self.summaryCards[index] = value
        self.summaryCardControls[index] = card
    end

    local columns = {
        { "Ability", 18, 300, TEXT_ALIGN_LEFT }, { "%", 320, 55, TEXT_ALIGN_RIGHT },
        { "DPS", 382, 75, TEXT_ALIGN_RIGHT }, { "PvP Damage", 464, 105, TEXT_ALIGN_RIGHT },
        { "Hits", 576, 65, TEXT_ALIGN_RIGHT }, { "Crits", 648, 65, TEXT_ALIGN_RIGHT },
        { "Average", 720, 75, TEXT_ALIGN_RIGHT }, { "Max", 802, 75, TEXT_ALIGN_RIGHT },
    }
    self.summaryColumnLabels = {}
    for index, column in ipairs(columns) do
        local label = CreateLabel(win, self.name .. "Column" .. index, "ZoFontGameBold", { 0.65, 0.85, 1, 1 }, column[4])
        label:SetAnchor(TOPLEFT, win, TOPLEFT, column[2], 168)
        label:SetDimensions(column[3], 28)
        label:SetText(column[1])
        self.summaryColumnLabels[index] = label
    end

    self.summaryRows = {}
    for rowIndex = 1, 12 do
        local rowBg = WINDOW_MANAGER:CreateControl(self.name .. "RowBG" .. rowIndex, win, CT_BACKDROP)
        rowBg:SetAnchor(TOPLEFT, win, TOPLEFT, 14, 197 + (rowIndex - 1) * 30)
        rowBg:SetDimensions(872, 28)
        local shade = rowIndex % 2 == 0 and 0.055 or 0.025
        rowBg:SetCenterColor(shade, shade + 0.01, shade + 0.02, 0.9)
        rowBg:SetEdgeColor(0, 0, 0, 0)
        local row = {}
        for colIndex, column in ipairs(columns) do
            local label = CreateLabel(rowBg, self.name .. "Row" .. rowIndex .. "Col" .. colIndex, "ZoFontGame", { 0.92, 0.92, 0.92, 1 }, column[4])
            label:SetAnchor(TOPLEFT, win, TOPLEFT, column[2], 197 + (rowIndex - 1) * 30)
            label:SetDimensions(column[3], 28)
            row[colIndex] = label
        end
        self.summaryRows[rowIndex] = { background = rowBg, labels = row }
    end

    self.summaryFooter = CreateLabel(win, self.name .. "SummaryFooter", "ZoFontGameSmall", { 0.55, 0.65, 0.7, 1 }, TEXT_ALIGN_CENTER)
    self.summaryFooter:SetAnchor(BOTTOMLEFT, win, BOTTOMLEFT, 20, -8)
    self.summaryFooter:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -20, -8)
    self.summaryFooter:SetHeight(24)
    self.summaryFooter:SetText("Local estimate — resistance, penetration and Battle Spirit are configurable in LAM — /pdc")

    self.eventLog = WINDOW_MANAGER:CreateControl(self.name .. "EventLog", win, CT_BACKDROP)
    self.eventLog:SetAnchor(TOPLEFT, win, TOPLEFT, 14, 86)
    self.eventLog:SetDimensions(872, 458)
    self.eventLog:SetCenterColor(0.015, 0.025, 0.035, 0.92)
    self.eventLog:SetEdgeColor(0.18, 0.35, 0.45, 1)
    self.eventLog:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16)
    self.eventLog:SetHidden(true)

    local logHeader = CreateLabel(self.eventLog, self.name .. "LogHeader", "ZoFontGameBold", { 0.65, 0.85, 1, 1 }, TEXT_ALIGN_LEFT)
    logHeader:SetAnchor(TOPLEFT, self.eventLog, TOPLEFT, 10, 5)
    logHeader:SetAnchor(TOPRIGHT, self.eventLog, TOPRIGHT, -10, 5)
    logHeader:SetHeight(28)
    logHeader:SetText("Time       Event                                                        Actual        PvP")

    self.eventLogRows = {}
    for index = 1, 13 do
        local label = CreateLabel(self.eventLog, self.name .. "LogRow" .. index, "ZoFontGame", { 0.9, 0.9, 0.9, 1 }, TEXT_ALIGN_LEFT)
        label:SetAnchor(TOPLEFT, self.eventLog, TOPLEFT, 10, 34 + (index - 1) * 29)
        label:SetAnchor(TOPRIGHT, self.eventLog, TOPRIGHT, -10, 34 + (index - 1) * 29)
        label:SetHeight(28)
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        self.eventLogRows[index] = label
    end

    self.logPrevious = WINDOW_MANAGER:CreateControl(self.name .. "LogPrevious", self.eventLog, CT_BUTTON)
    self.logPrevious:SetDimensions(80, 28)
    self.logPrevious:SetAnchor(BOTTOMLEFT, self.eventLog, BOTTOMLEFT, 12, -8)
    self.logPrevious:SetFont("ZoFontGameBold")
    self.logPrevious:SetText("Previous")
    self.logPrevious:SetHandler("OnClicked", function()
        self.eventLogPage = math.max(1, (self.eventLogPage or 1) - 1)
        self:RefreshEventLog()
    end)

    self.logNext = WINDOW_MANAGER:CreateControl(self.name .. "LogNext", self.eventLog, CT_BUTTON)
    self.logNext:SetDimensions(80, 28)
    self.logNext:SetAnchor(BOTTOMRIGHT, self.eventLog, BOTTOMRIGHT, -12, -8)
    self.logNext:SetFont("ZoFontGameBold")
    self.logNext:SetText("Next")
    self.logNext:SetHandler("OnClicked", function()
        self.eventLogPage = math.min(self.eventLogPageCount or 1, (self.eventLogPage or 1) + 1)
        self:RefreshEventLog()
    end)

    self.logPageLabel = CreateLabel(self.eventLog, self.name .. "LogPageLabel", "ZoFontGame", { 0.65, 0.75, 0.8, 1 }, TEXT_ALIGN_CENTER)
    self.logPageLabel:SetAnchor(BOTTOMLEFT, self.eventLog, BOTTOMLEFT, 100, -8)
    self.logPageLabel:SetAnchor(BOTTOMRIGHT, self.eventLog, BOTTOMRIGHT, -100, -8)
    self.logPageLabel:SetHeight(28)
end

function PDC:SetSummaryTab(tab)
    self.activeSummaryTab = tab == "log" and "log" or "summary"
    local showLog = self.activeSummaryTab == "log"
    for _, control in ipairs(self.summaryCardControls or {}) do control:SetHidden(showLog) end
    for _, control in ipairs(self.summaryColumnLabels or {}) do control:SetHidden(showLog) end
    for _, row in ipairs(self.summaryRows or {}) do
        local hasText = row.labels[1]:GetText() ~= ""
        row.background:SetHidden(showLog or not hasText)
        for _, label in ipairs(row.labels) do label:SetHidden(showLog or not hasText) end
    end
    self.summaryFooter:SetHidden(showLog)
    self.eventLog:SetHidden(not showLog)
    self.summaryTabButton:SetText(showLog and "Summary" or "|cE94B3CSummary|r")
    self.logTabButton:SetText(showLog and "|cE94B3CEvent Log|r" or "Event Log")
    if showLog then self:RefreshEventLog() end
end

function PDC:RefreshEventLog()
    if not self.eventLogRows or not self.session then return end
    local events = self.session.events or {}
    local rowsPerPage = #self.eventLogRows
    self.eventLogPageCount = math.max(1, math.ceil(#events / rowsPerPage))
    self.eventLogPage = Clamp(self.eventLogPage or 1, 1, self.eventLogPageCount)
    local firstIndex = (self.eventLogPage - 1) * rowsPerPage + 1

    for rowIndex, label in ipairs(self.eventLogRows) do
        local event = events[firstIndex + rowIndex - 1]
        if event then
            local elapsed = math.max(0, (event.timestamp - self.session.startTime) / 1000)
            local icon = ""
            if event.abilityId > 0 and GetAbilityIcon then
                local iconPath = GetAbilityIcon(event.abilityId)
                if iconPath and iconPath ~= "" then icon = string.format("|t22:22:%s|t ", iconPath) end
            end
            local action = event.critical and "|cFFD34ECritically hit|r" or "Hit"
            local eventText = string.format("[%7.3fs] %s %s with %s%s|r", elapsed, action,
                event.targetName, icon, event.abilityName)
            label:SetText(string.format("%-92s  |cAAAAAA%8s|r  |cE94B3C%8s|r",
                eventText, self:FormatNumber(event.original), self:FormatNumber(event.converted)))
            label:SetHidden(false)
        else
            label:SetText("")
            label:SetHidden(true)
        end
    end

    self.logPageLabel:SetText(string.format("Page %d / %d — %d events", self.eventLogPage, self.eventLogPageCount, #events))
    self.logPrevious:SetEnabled(self.eventLogPage > 1)
    self.logNext:SetEnabled(self.eventLogPage < self.eventLogPageCount)
end

function PDC:RefreshSummary()
    if not self.session or not self.session.startTime or self.session.hits == 0 then
        d("|cE94B3CExperimental Dummy PvP: no recorded session.|r")
        return false
    end
    local duration = self:GetSessionDuration()
    local total = self.session.convertedTotal
    local rows = {}
    for _, data in pairs(self.session.abilities) do rows[#rows + 1] = data end
    table.sort(rows, function(a, b) return a.converted > b.converted end)

    self.summaryTarget:SetText(self.session.targetName ~= "" and self.session.targetName or "Training Target")
    self.summaryCards[1]:SetText(string.format("%.2f s", duration))
    self.summaryCards[2]:SetText(self:FormatNumber(zo_round(self.session.originalTotal / duration)))
    self.summaryCards[3]:SetText(self:FormatNumber(zo_round(total / duration)))
    self.summaryCards[4]:SetText(self:FormatNumber(self.session.originalTotal))
    self.summaryCards[5]:SetText(self:FormatNumber(total))
    self.summaryCards[6]:SetText(string.format("%d / %d", self.session.crits, self.session.hits))

    for index, uiRow in ipairs(self.summaryRows) do
        local data = rows[index]
        uiRow.background:SetHidden(data == nil)
        for _, label in ipairs(uiRow.labels) do label:SetHidden(data == nil) end
        if data then
            local percent = total > 0 and data.converted / total * 100 or 0
            uiRow.labels[1]:SetText(data.name)
            uiRow.labels[2]:SetText(string.format("%.1f%%", percent))
            uiRow.labels[3]:SetText(self:FormatNumber(zo_round(data.converted / duration)))
            uiRow.labels[4]:SetText(self:FormatNumber(data.converted))
            uiRow.labels[5]:SetText(tostring(data.hits))
            uiRow.labels[6]:SetText(string.format("%d%%", zo_round(data.crits / data.hits * 100)))
            uiRow.labels[7]:SetText(self:FormatNumber(zo_round(data.converted / data.hits)))
            uiRow.labels[8]:SetText(self:FormatNumber(data.maximum))
        end
    end
    return true
end

function PDC:ShowSummary()
    if self:RefreshSummary() then
        self.summary:SetHidden(false)
        self:SetSummaryTab(self.activeSummaryTab or "summary")
    end
end

function PDC:OnCombatStateChanged(inCombat)
    if inCombat then
        -- Measure DPS over the full combat duration, not merely the interval
        -- between the first and last hit (which can be zero milliseconds).
        -- Do not erase a first hit that ESO dispatched just before this event.
        if self.session.completed then
            self:ResetSession()
        end
        if not self.session.startTime then
            self.session.startTime = GetGameTimeMilliseconds()
        end
        self.session.inCombat = true
    elseif self.session and self.session.startTime then
        self.session.endTime = GetGameTimeMilliseconds()
        self.session.inCombat = false
        self.session.completed = self.session.hits > 0
    end
end

function PDC:CreateOutput()
    self.output = WINDOW_MANAGER:CreateTopLevelWindow(self.name .. "Output")
    self.output:SetDimensions(900, 70)
    self.output:SetAnchor(CENTER, GuiRoot, CENTER, 0, -180)
    self.output:SetMouseEnabled(false)
    self.output:SetClampedToScreen(true)
    self.output:SetHidden(true)

    self.outputLabel = WINDOW_MANAGER:CreateControl(self.name .. "OutputLabel", self.output, CT_LABEL)
    self.outputLabel:SetAnchor(CENTER, self.output, CENTER, 0, 0)
    self.outputLabel:SetFont("$(BOLD_FONT)|24|soft-shadow-thick")
    self.outputLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.outputLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
end

function PDC:RegisterCombatEvents()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT,
        function(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                 sourceName, sourceType, targetName, targetType, hitValue, powerType,
                 damageType, log, sourceUnitId, targetUnitId, abilityId)
            self:OnCombatEvent(result, abilityName, sourceName, sourceType, targetName, targetType, hitValue, abilityId)
        end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        self:OnCombatStateChanged(inCombat)
    end)
end

function PDC:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide("ExperimentalDummyPvpSavedVariables", self.savedVariableVersion, nil, self.defaults)
    self:ResetSession()
    self:CreateOutput()
    self:CreateSummaryWindow()
    self:RegisterCombatEvents()
    if self.CreateSettings then
        self:CreateSettings()
    end
    SLASH_COMMANDS["/pdc"] = function(argument)
        argument = zo_strlower(argument or "")
        if argument == "reset" then
            self:ResetSession()
            d("|cE94B3CExperimental Dummy PvP: session reset.|r")
        else
            self.activeSummaryTab = argument == "log" and "log" or "summary"
            self:ShowSummary()
        end
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= PDC.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(PDC.name, EVENT_ADD_ON_LOADED)
    PDC:Initialize()
end

EVENT_MANAGER:RegisterForEvent(PDC.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
