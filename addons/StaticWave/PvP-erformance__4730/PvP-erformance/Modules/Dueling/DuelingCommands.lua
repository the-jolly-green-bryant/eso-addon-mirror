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
function Dueling:GetSummary()
    local wins, losses, draws = 0, 0, 0

    for _, duel in ipairs(self.savedVars.history) do
        if duel.drawn then
            draws = draws + 1
        elseif duel.won then
            wins = wins + 1
        else
            losses = losses + 1
        end
    end

    local total = wins + losses + draws
    -- Total duels retains draws; the win rate is decisive duels only.
    local winRate = WinRatePercent({ wins = wins, losses = losses })
    return wins, losses, draws, total, winRate
end

function Dueling:GetUniqueOpponentCount()
    local opponents = {}
    local count = 0
    for _, duel in ipairs(self.savedVars.history) do
        local displayName = duel.opponent and duel.opponent.displayName or "Unknown @name"
        local key = zo_strlower(displayName)
        if not opponents[key] then
            opponents[key] = true
            count = count + 1
        end
    end
    return count
end

function Dueling:PrintWinRateCard()
    local wins, losses, draws, _, winRate = self:GetSummary()
    self:OpenShareChat(string.format(
        "Player: %s, Win Rate: %.1f%%, Stats: %dW-%dL-%dD",
        GetDisplayName() or "@Unknown",
        winRate,
        wins,
        losses,
        draws
    ))
end

function Dueling:ShowWinRateShareMenu(control)
    local addMenuItem = AddCustomMenuItem or AddMenuItem
    if not ClearMenu or not addMenuItem or not ShowMenu then
        self:PrintWinRateCard()
        return
    end

    ClearMenu()
    addMenuItem("Post Win Rate and W-L-D to chat", function()
        self:PrintWinRateCard()
    end)
    addMenuItem("Post Overall Tier to chat", function()
        self:PrintTierCard("overall")
    end)
    addMenuItem("Post Full Profile to chat", function()
        self:ShareProfileCard()
    end)
    ShowMenu(control)
end

function Dueling:ShareProfileCard()
    local _, _, _, _, winRate = self:GetSummary()
    local overallRatingState = self:GetRatingState()
    local classRatingState = self:GetClassRatingState(self:GetSelectedClassTierId())
    local function TierText(ratingState)
        if ratingState.placed then
            local tierText = RankForRating(ratingState.rating).name
            if ratingState.calibrating then
                tierText = string.format("%s (PROV %d/%d)", tierText, ratingState.calibrationDecisiveCount, CALIBRATION_DECISIVE_DUELS_REQUIRED)
            end
            return tierText
        end

        return "Placement " .. ProvisionalProgressText(ratingState)
    end

    self:OpenShareChat(string.format(
        "Player: %s, Overall Tier: %s, Class Tier (%s): %s, Win Rate: %.1f%%",
        GetDisplayName() or "@Unknown",
        TierText(overallRatingState),
        classRatingState.className,
        TierText(classRatingState),
        winRate
    ))
end

function Dueling:ShowTierShareMenu(kind, control)
    local addMenuItem = AddCustomMenuItem or AddMenuItem
    if not ClearMenu or not addMenuItem or not ShowMenu then
        self:PrintTierCard(kind)
        return
    end

    local isClassTier = kind == "class"
    local ratingState = isClassTier and self:GetClassRatingState(self:GetSelectedClassTierId()) or self:GetRatingState()
    local tierLabel = isClassTier and string.format("%s Class Tier", ratingState.className) or "Overall Tier"

    ClearMenu()
    addMenuItem(string.format("Post %s to chat", tierLabel), function()
        self:PrintTierCard(kind)
    end)
    addMenuItem("Post Win Rate and W-L-D to chat", function()
        self:PrintWinRateCard()
    end)
    addMenuItem("Post Full Profile to chat", function()
        self:ShareProfileCard()
    end)
    ShowMenu(control)
end

function Dueling:PrintTierCard(kind)
    local isClassTier = kind == "class"
    local ratingState = isClassTier and self:GetClassRatingState(self:GetSelectedClassTierId()) or self:GetRatingState()
    local label = isClassTier and string.format("%s Class Tier", ratingState.className) or "Overall Tier"
    local displayName = GetDisplayName() or "@Unknown"

    if not ratingState.placed then
        self:OpenShareChat(string.format(
            "%s - %s: Placement %s",
            displayName,
            label,
            ProvisionalProgressText(ratingState)
        ))
        return
    end

    local rank = RankForRating(ratingState.rating)
    local pointsToNextRank, nextRankName = PointsToNextRank(ratingState.rating, rank)
    if not pointsToNextRank then
        local provisionalText = ratingState.calibrating
            and string.format(" | PROV %d/%d", ratingState.calibrationDecisiveCount, CALIBRATION_DECISIVE_DUELS_REQUIRED)
            or ""
        self:OpenShareChat(string.format("%s - %s: %s (maximum tier)%s", displayName, label, rank.name, provisionalText))
        return
    end

    local provisionalText = ratingState.calibrating
        and string.format(" | PROV %d/%d", ratingState.calibrationDecisiveCount, CALIBRATION_DECISIVE_DUELS_REQUIRED)
        or ""
    self:OpenShareChat(string.format(
        "%s - %s: %s | %s points to %s%s",
        displayName,
        label,
        rank.name,
        FormatRating(pointsToNextRank),
        nextRankName,
        provisionalText
    ))
end

function Dueling:OpenShareChat(message)
    -- Opening the standard text entry lets the player choose or retain a
    -- social channel and consciously send the message with Enter.
    if StartChatInput then
        StartChatInput(message)
    else
        Print(message)
    end
end

function Dueling:PrintSummary()
    local wins, losses, draws, total, winRate = self:GetSummary()
    local ratingState = self:GetRatingState()
    local classRatingState = self:GetClassRatingState()
    local overallTierText
    if ratingState.placed then
        local rank = RankForRating(ratingState.rating)
        overallTierText = string.format("%s rating (%s tier)", FormatRating(ratingState.rating), rank.name)
        if ratingState.calibrating then
            overallTierText = string.format(
                "%s | PROV %d/%d",
                overallTierText,
                ratingState.calibrationDecisiveCount,
                CALIBRATION_DECISIVE_DUELS_REQUIRED
            )
        end
    else
        overallTierText = "Placement " .. ProvisionalProgressText(ratingState)
    end
    Print(string.format(
        "Total duels: %d | %dW-%dL-%dD (%.1f%% win rate) | %s",
        total,
        wins,
        losses,
        draws,
        winRate,
        overallTierText
    ))

    if classRatingState.placed then
        local classRank = RankForRating(classRatingState.rating)
        local classProvisionalText = classRatingState.calibrating
            and string.format(" | PROV %d/%d", classRatingState.calibrationDecisiveCount, CALIBRATION_DECISIVE_DUELS_REQUIRED)
            or ""
        Print(string.format(
            "%s Class Tier: %s rating (%s tier)%s",
            classRatingState.className,
            FormatRating(classRatingState.rating),
            classRank.name,
            classProvisionalText
        ))
    else
        Print(string.format(
            "%s Class Tier placement: %s",
            classRatingState.className,
            ProvisionalProgressText(classRatingState)
        ))
    end
end

function Dueling:PrintHistory(limit)
    local viewedSeason = self:GetViewedSeason()
    local history = viewedSeason and viewedSeason.history or {}
    local total = #history

    if total == 0 then
        Print("No recorded duels yet.")
        return
    end

    limit = tonumber(limit) or 10
    limit = math.max(1, math.min(math.floor(limit), total))

    Print(string.format("Latest %d of %d duels:", limit, total))
    for index = total, total - limit + 1, -1 do
        local duel = history[index] or {}
        local result = duel.drawn and "DRAW" or (duel.won and "WIN" or "LOSS")
        local opponentData = type(duel.opponent) == "table" and duel.opponent or {}
        local opponent = opponentData.displayName or "Unknown @name"
        local overallChange = duel.overallRatingChange ~= nil
            and FormatSignedRating(duel.overallRatingChange)
            or "N/A"
        local classChange = duel.classRatingChange ~= nil
            and FormatSignedRating(duel.classRatingChange)
            or "N/A"

        Print(string.format(
            "%d. %s vs %s | %s | %s | Overall %s | Class %s",
            total - index + 1,
            result,
            opponent,
            FormatDuration(duel.durationSeconds),
            FormatDuelTime(duel),
            overallChange,
            classChange
        ))
    end
end

function Dueling:PrintDuelDebug(limit)
    local history = self.savedVars.history
    local total = #history
    if total == 0 then
        Print("No recorded duels yet.")
        return
    end

    limit = tonumber(limit) or 1
    limit = math.max(1, math.min(math.floor(limit), total, 5))
    Print(string.format("Rating debug for latest %d duel%s:", limit, limit == 1 and "" or "s"))
    for index = total, total - limit + 1, -1 do
        local duel = history[index]
        local result = duel.drawn and "DRAW" or (duel.won and "WIN" or "LOSS")
        local opponent = duel.opponent and duel.opponent.displayName or "@Unknown"
        Print(string.format("[%s] %s", result, opponent))
        Print(FormatRatingDebugLine("Overall", duel, duel.overallRatingDebug))
        Print(FormatRatingDebugLine("Class", duel, duel.classRatingDebug))
        if duel.suspectedLatencySpike then
            Print(string.format(
                "Latency flag: %s (baseline %s ms, peak %s ms; diagnostic only).",
                zo_strlower(duel.latencySpikeConfidence or "moderate"),
                tostring(duel.latencyBaselineMS or "N/A"),
                tostring(duel.latencyPeakMS or "N/A")
            ))
        end
    end
end

local function ReadControlBoolean(control, methodName)
    if not control then
        return false
    end

    local method = control[methodName]
    if type(method) ~= "function" then
        return false
    end

    local ok, value = pcall(method, control)
    return ok and value == true
end

function Dueling:PrintInputStatus()
    -- Read-only emergency diagnostic. It deliberately does not change focus,
    -- UI mode, handlers, controls, scenes, or action layers.
    local ui = self.ui or {}
    local overlayVisible = ui.rankingInfoOverlay and not ui.rankingInfoOverlay:IsHidden() or false
    local keyboardEnabled = ReadControlBoolean(ui.searchInput, "IsKeyboardEnabled")
    local editBoxFocused = ReadControlBoolean(ui.searchInput, "HasFocus")
    local sceneInUIMode = SCENE_MANAGER and SCENE_MANAGER:IsInUIMode() or false
    local scene = self:GetSceneInputStatus()

    Print(string.format(
        "Input status: scene initialized=%s | scene name=%s | current ESO scene=%s | scene state=%s | fragment initialized=%s (%s) | mouse UI group=%s | exit keybind=%s | active=%s | main window hidden=%s | fallback=%s%s",
        tostring(scene.sceneExists),
        tostring(scene.sceneName),
        tostring(scene.currentSceneName),
        scene.sceneState,
        tostring(scene.fragmentExists),
        scene.fragmentState,
        tostring(scene.mouseDrivenGroup),
        tostring(scene.exitKeybindActive),
        tostring(scene.active),
        tostring(scene.windowHidden),
        tostring(scene.fallback),
        scene.fallbackReason and string.format(" (%s)", scene.fallbackReason) or ""
    ))
    Print(string.format(
        "Input status: view=%s | selected duel=%s | overlay=%s | search keyboard=%s | search focused=%s | scene UI mode=%s | PvP-erformance owns UI mode=%s",
        tostring(scene.view),
        tostring(scene.selectedDuel),
        tostring(overlayVisible),
        tostring(keyboardEnabled),
        tostring(editBoxFocused),
        tostring(sceneInUIMode),
        tostring(scene.ownsUIMode)
    ))
end

function Dueling:ExportHistorySummary(limit)
    local history = self.savedVars.history
    if #history == 0 then
        Print("No recorded duels to export.")
        return
    end

    -- ESO cannot write arbitrary local files or send data over the network.
    -- This is deliberately a compact, copyable social-chat summary instead of
    -- pretending to be a full importable backup.
    limit = tonumber(limit) or 3
    limit = math.max(1, math.min(5, math.floor(limit), #history))
    local wins, losses, draws, total, winRate = self:GetSummary()
    local recent = {}
    for index = #history, #history - limit + 1, -1 do
        local duel = history[index]
        local result = duel.drawn and "D" or (duel.won and "W" or "L")
        local opponent = duel.opponent and duel.opponent.displayName or "@Unknown"
        if string.len(opponent) > 18 then
            opponent = string.sub(opponent, 1, 18)
        end
        table.insert(recent, string.format("%s %s %s", result, opponent, FormatDuration(duel.durationSeconds)))
    end

    self:OpenShareChat(string.format(
        "%s Export | Player: %s | %d duels | %dW-%dL-%dD | %.1f%% WR | Recent: %s",
        DISPLAY_NAME,
        GetDisplayName() or "@Unknown",
        total,
        wins,
        losses,
        draws,
        winRate,
        table.concat(recent, ", ")
    ))
end

function Dueling:OnOpponentNoteCommand(argument)
    local rawAction, remainder = string.match(argument or "", "^%s*(%S*)%s*(.-)%s*$")
    local action = zo_strlower(rawAction or "")
    if action == "clear" or action == "remove" or action == "delete" then
        local displayName = remainder
        if not displayName or displayName == "" then
            Print("Usage: /metrics note clear @name")
            return
        end
        self.savedVars.opponentNotes[zo_strlower(displayName)] = nil
        Print(string.format("Removed the note for %s.", displayName))
        self:RefreshUI()
        return
    end

    local displayName = rawAction
    local note = remainder
    if not displayName or displayName == "" or note == "" then
        Print("Usage: /metrics note @name <note>  |  /metrics note clear @name")
        return
    end
    note = string.sub(note, 1, 120)
    self.savedVars.opponentNotes[zo_strlower(displayName)] = {
        name = displayName,
        text = note,
    }
    Print(string.format("Saved note for %s.", displayName))
    self:RefreshUI()
end

function Dueling:ClearAllDuelRecords()
    local season = self:GetActiveSeason()
    if not season then
        return
    end
    season.history = {}
    season.ranking = self:CreateInitialRanking()
    season.classRankings = {}
    season.classRankingRulesVersion = CLASS_RATING_RULES_VERSION
    self.testRatingState = nil
    self.testClassRatingState = nil
    self.testSandbox = nil
    Print("Active-season duel records and rating progress cleared. Archived seasons and opponent notes were kept.")
    self:RefreshUI()
end

function Dueling:IsCreatorAccount()
    return CREATOR_DISPLAY_NAMES[zo_strlower(GetDisplayName() or "")] == true
end

function Dueling:OnCreatorCommand(argument)
    if not self:IsCreatorAccount() then
        return
    end

    local action, value = string.match(argument or "", "^%s*(%S*)%s*(.-)%s*$")
    action = zo_strlower(action or "")
    if action == "clear" and zo_strlower(value or "") == "confirm" then
        self:ClearAllDuelRecords()
    else
        Print("Creator command requires: /metrics dev clear confirm")
    end
end

function Dueling:OnSlashCommand(argument)
    -- Preserve the argument's casing for opponent notes and shareable text;
    -- only the command keyword itself is case-insensitive.
    local rawCommand, value = string.match(argument or "", "^%s*(%S*)%s*(.-)%s*$")
    local command = zo_strlower(rawCommand or "")

    if command == "" or command == "ui" or command == "window" then
        self:ToggleUI()
    elseif command == "share" or command == "card" or command == "profile" then
        self:ShareProfileCard()
    elseif command == "history" or command == "h" or command == "duels" then
        self:PrintHistory(value)
    elseif command == "debug" or command == "ratingdebug" then
        self:PrintDuelDebug(value)
    elseif command == "debugcombat" or command == "combatdebug" then
        self:PrintCombatDebug()
    elseif command == "inputstatus" then
        self:PrintInputStatus()
    elseif command == "export" then
        self:ExportHistorySummary(value)
    elseif command == "note" or command == "notes" then
        self:OnOpponentNoteCommand(value)
    elseif command == "dev" then
        self:OnCreatorCommand(value)
    elseif command == "ww" or command == "werewolf" then
        self:OnWerewolfCommand(value)
    elseif command == "test" or command == "preview" then
        local rawAction, previewValue = string.match(value or "", "^%s*(%S*)%s*(.-)%s*$")
        local action = zo_strlower(rawAction or "")
        if action == "placement" or action == "place" then
            self:SetPlacementPreview(previewValue)
        elseif action == "rating" or action == "rank" then
            self:SetRatingPreview(previewValue)
        elseif action == "classplacement" or action == "classplace" then
            self:SetClassPlacementPreview(previewValue)
        elseif action == "class" or action == "classrating" then
            self:SetClassRatingPreview(previewValue)
        elseif action == "simulate" or action == "duel" then
            local result, opponentClass, opponentName = string.match(previewValue or "", "^%s*(%S+)%s*(%S+)%s*(.-)%s*$")
            self:SimulateTestDuel(result, opponentClass, opponentName)
        elseif action == "off" or action == "clear" or action == "reset" then
            self:ClearRatingPreview()
        else
            Print("Creator preview: placement [0-19] | rating [points] | classplacement [0-19] | class [points] | simulate <win|loss|draw> <class> [@name] | off")
        end
    elseif command == "help" or command == "?" then
        Print("/metrics summary | ui | share | duels [count] | history [count] | debug [count] | debugcombat | inputstatus | export [1-5] | note | ww")
    else
        self:PrintSummary()
    end
end

