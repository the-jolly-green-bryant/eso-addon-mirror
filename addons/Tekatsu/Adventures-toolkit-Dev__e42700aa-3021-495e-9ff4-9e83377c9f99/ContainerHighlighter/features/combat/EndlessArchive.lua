-- ============================================
-- ENDLESS ARCHIVE (Infinite Archive) TRACKER
-- Adventurer's Toolkit
-- ============================================

NWT.EndlessArchive = {
    isOpen = false,
    sceneInitialized = false,
    currentTab = 1,
    tabs = { "Current Run", "Buffs", "History" },
    -- Runtime state
    inArchive = false,
    runStartTime = 0,
    currentScore = 0,
    -- Buff tracking
    activeVerses = {},
    activeVisions = {},
    lifetimeVerses = {},
    lifetimeVisions = {},
    -- Selection for scrolling
    selectedBuffIndex = 1,
    buffScrollOffset = 0,
    maxVisibleBuffs = 12,
    selectedHistoryIndex = 1,
    historyScrollOffset = 0,
    maxVisibleHistory = 8,
}

-- ============================================
-- SAVED VARIABLES DEFAULTS
-- ============================================
NWT.ENDLESS_ARCHIVE_DEFAULTS = {
    -- Personal bests
    bestScore = {
        solo = 0,
        duo = 0,
    },
    bestStage = {
        solo = { arc = 0, cycle = 0, stage = 0 },
        duo = { arc = 0, cycle = 0, stage = 0 },
    },
    -- Run history (last 20 runs)
    history = {},
    -- Lifetime stats
    lifetime = {
        totalRuns = 0,
        totalScore = 0,
        completedRuns = 0,
        soloRuns = 0,
        duoRuns = 0,
        totalKills = 0,
        bossKills = 0,
        highestArc = 0,
        highestCycle = 0,
        totalTime = 0,
    },
    -- Favorite buffs tracking
    favoritedBuffs = {},
    -- First tracked timestamp
    firstTracked = 0,
}

-- ============================================
-- INITIALIZATION
-- ============================================
function NWT.InitEndlessArchiveData()
    if not NWT.savedVars.endlessArchive then
        NWT.savedVars.endlessArchive = ZO_DeepTableCopy(NWT.ENDLESS_ARCHIVE_DEFAULTS)
    end
    -- Ensure all keys exist
    for k, v in pairs(NWT.ENDLESS_ARCHIVE_DEFAULTS) do
        if NWT.savedVars.endlessArchive[k] == nil then
            NWT.savedVars.endlessArchive[k] = ZO_DeepTableCopy(v)
        end
    end
    
    if NWT.savedVars.endlessArchive.firstTracked == 0 then
        NWT.savedVars.endlessArchive.firstTracked = GetTimeStamp()
    end
    
    -- Check if we're already in the archive on load
    NWT.CheckArchiveState()
end

function NWT.CheckArchiveState()
    local ea = NWT.EndlessArchive
    if IsInstanceEndlessDungeon and IsInstanceEndlessDungeon() then
        ea.inArchive = true
        if IsEndlessDungeonStarted and IsEndlessDungeonStarted() then
            ea.runStartTime = GetEndlessDungeonStartTimeMilliseconds and GetEndlessDungeonStartTimeMilliseconds() or GetGameTimeMilliseconds()
            NWT.RefreshEndlessArchiveBuffs()
        end
    else
        ea.inArchive = false
    end
end

-- ============================================
-- PROGRESS FUNCTIONS
-- ============================================
function NWT.GetArchiveProgress()
    if not IsInstanceEndlessDungeon or not IsInstanceEndlessDungeon() then
        return { arc = 0, cycle = 0, stage = 0, lives = 0, score = 0, isActive = false }
    end
    
    local arc = GetEndlessDungeonCounterValue and GetEndlessDungeonCounterValue(ENDLESS_DUNGEON_COUNTER_TYPE_ARC) or 0
    local cycle = GetEndlessDungeonCounterValue and GetEndlessDungeonCounterValue(ENDLESS_DUNGEON_COUNTER_TYPE_CYCLE) or 0
    local stage = GetEndlessDungeonCounterValue and GetEndlessDungeonCounterValue(ENDLESS_DUNGEON_COUNTER_TYPE_STAGE) or 0
    local lives = GetEndlessDungeonCounterValue and GetEndlessDungeonCounterValue(ENDLESS_DUNGEON_COUNTER_TYPE_WIPES_REMAINING) or 0
    local score = GetEndlessDungeonScore and GetEndlessDungeonScore() or 0
    local isCompleted = IsEndlessDungeonCompleted and IsEndlessDungeonCompleted() or false
    local groupType = GetEndlessDungeonGroupType and GetEndlessDungeonGroupType() or ENDLESS_DUNGEON_GROUP_TYPE_SOLO
    local isSolo = groupType == ENDLESS_DUNGEON_GROUP_TYPE_SOLO
    
    return {
        arc = arc,
        cycle = cycle,
        stage = stage,
        lives = lives,
        score = score,
        isActive = IsEndlessDungeonStarted and IsEndlessDungeonStarted() or false,
        isCompleted = isCompleted,
        isSolo = isSolo,
        groupType = groupType,
    }
end

function NWT.GetArchiveRunTime()
    local ea = NWT.EndlessArchive
    if not ea.inArchive or ea.runStartTime == 0 then return 0 end
    
    local startMs = GetEndlessDungeonStartTimeMilliseconds and GetEndlessDungeonStartTimeMilliseconds() or ea.runStartTime
    local nowMs = GetGameTimeMilliseconds()
    return math.floor((nowMs - startMs) / 1000)
end

function NWT.FormatArchiveTime(seconds)
    if not seconds or seconds <= 0 then return "0:00" end
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    if hours > 0 then
        return string.format("%d:%02d:%02d", hours, mins, secs)
    else
        return string.format("%d:%02d", mins, secs)
    end
end

function NWT.FormatArchiveProgress(arc, cycle, stage)
    return string.format("Arc %d - Cycle %d - Stage %d", arc, cycle, stage)
end

-- ============================================
-- BUFF TRACKING (Verses & Visions)
-- ============================================
function NWT.RefreshEndlessArchiveBuffs()
    local ea = NWT.EndlessArchive
    ea.activeVerses = {}
    ea.activeVisions = {}
    ea.lifetimeVerses = {}
    ea.lifetimeVisions = {}
    
    if not IsInstanceEndlessDungeon or not IsInstanceEndlessDungeon() then return end
    
    -- Get active verses
    local numVerses = GetNumEndlessDungeonActiveVerses and GetNumEndlessDungeonActiveVerses() or 0
    for i = 1, numVerses do
        local abilityId = GetEndlessDungeonActiveVerseAbility(i)
        if abilityId and abilityId > 0 then
            local name = GetAbilityName(abilityId) or "Unknown Verse"
            local icon = GetAbilityIcon(abilityId) or ""
            local stacks = GetNumStacksForEndlessDungeonBuff and GetNumStacksForEndlessDungeonBuff(abilityId, false) or 1
            table.insert(ea.activeVerses, {
                abilityId = abilityId,
                name = name,
                icon = icon,
                stacks = stacks,
                type = "verse",
            })
        end
    end
    
    -- Get lifetime verses (persists across runs)
    local lastVerseId = nil
    while true do
        local nextId, stackCount = GetNextEndlessDungeonLifetimeVerseAbilityAndStackCount(lastVerseId)
        if not nextId then break end
        local name = GetAbilityName(nextId) or "Unknown Verse"
        local icon = GetAbilityIcon(nextId) or ""
        table.insert(ea.lifetimeVerses, {
            abilityId = nextId,
            name = name,
            icon = icon,
            stacks = stackCount or 1,
            type = "lifetime_verse",
        })
        lastVerseId = nextId
    end
    
    -- Get visions
    local lastVisionId = nil
    while true do
        local nextId, stackCount = GetNextEndlessDungeonVisionAbilityAndStackCount(lastVisionId)
        if not nextId then break end
        local name = GetAbilityName(nextId) or "Unknown Vision"
        local icon = GetAbilityIcon(nextId) or ""
        table.insert(ea.activeVisions, {
            abilityId = nextId,
            name = name,
            icon = icon,
            stacks = stackCount or 1,
            type = "vision",
        })
        lastVisionId = nextId
    end
end

function NWT.GetBuffSummary()
    local ea = NWT.EndlessArchive
    if not GetNumEndlessDungeonLifetimeVerseAndVisionStackCounts then
        return { verseStacks = 0, visionStacks = 0, avatarStacks = 0 }
    end
    local verseStacks, nonAvatarVisionStacks, avatarVisionStacks = GetNumEndlessDungeonLifetimeVerseAndVisionStackCounts()
    return {
        verseStacks = verseStacks or 0,
        visionStacks = nonAvatarVisionStacks or 0,
        avatarStacks = avatarVisionStacks or 0,
        totalBuffs = #ea.activeVerses + #ea.activeVisions,
    }
end

-- ============================================
-- LEADERBOARD & PERSONAL BESTS
-- ============================================
function NWT.GetArchiveLeaderboardInfo()
    local result = {
        soloRank = 0,
        soloBestScore = 0,
        duoRank = 0,
        duoBestScore = 0,
        weeklyTimeLeft = 0,
    }
    
    if GetEndlessDungeonOfTheWeekLeaderboardLocalPlayerInfo then
        result.soloRank, result.soloBestScore = GetEndlessDungeonOfTheWeekLeaderboardLocalPlayerInfo(ENDLESS_DUNGEON_GROUP_TYPE_SOLO)
        result.duoRank, result.duoBestScore = GetEndlessDungeonOfTheWeekLeaderboardLocalPlayerInfo(ENDLESS_DUNGEON_GROUP_TYPE_DUO)
    end
    
    if GetEndlessDungeonOfTheWeekTimes then
        result.weeklyTimeLeft = GetEndlessDungeonOfTheWeekTimes()
    end
    
    return result
end

function NWT.CheckAndUpdatePersonalBest(progress)
    if not progress.isActive then return end
    local sv = NWT.savedVars.endlessArchive
    local key = progress.isSolo and "solo" or "duo"
    
    -- Check score
    if progress.score > (sv.bestScore[key] or 0) then
        sv.bestScore[key] = progress.score
    end
    
    -- Check stage progress (compare arc > cycle > stage)
    local best = sv.bestStage[key] or { arc = 0, cycle = 0, stage = 0 }
    local isBetter = false
    if progress.arc > best.arc then
        isBetter = true
    elseif progress.arc == best.arc then
        if progress.cycle > best.cycle then
            isBetter = true
        elseif progress.cycle == best.cycle and progress.stage > best.stage then
            isBetter = true
        end
    end
    
    if isBetter then
        sv.bestStage[key] = { arc = progress.arc, cycle = progress.cycle, stage = progress.stage }
    end
    
    -- Update lifetime highest
    if progress.arc > (sv.lifetime.highestArc or 0) then
        sv.lifetime.highestArc = progress.arc
    end
    if progress.cycle > (sv.lifetime.highestCycle or 0) then
        sv.lifetime.highestCycle = progress.cycle
    end
end

-- ============================================
-- EVENT HANDLERS
-- ============================================
function NWT.OnEndlessDungeonStarted(eventCode)
    local ea = NWT.EndlessArchive
    ea.inArchive = true
    ea.runStartTime = GetGameTimeMilliseconds()
    ea.currentScore = 0
    
    NWT.RefreshEndlessArchiveBuffs()
    
    local sv = NWT.savedVars.endlessArchive
    sv.lifetime.totalRuns = (sv.lifetime.totalRuns or 0) + 1
    
    local groupType = GetEndlessDungeonGroupType and GetEndlessDungeonGroupType() or ENDLESS_DUNGEON_GROUP_TYPE_SOLO
    if groupType == ENDLESS_DUNGEON_GROUP_TYPE_SOLO then
        sv.lifetime.soloRuns = (sv.lifetime.soloRuns or 0) + 1
    else
        sv.lifetime.duoRuns = (sv.lifetime.duoRuns or 0) + 1
    end
    
    if ea.isOpen then NWT.UpdateEndlessArchiveDashboard() end
end

function NWT.OnEndlessDungeonCompleted(eventCode, flags)
    local ea = NWT.EndlessArchive
    local sv = NWT.savedVars.endlessArchive
    
    local progress = NWT.GetArchiveProgress()
    local runTime = NWT.GetArchiveRunTime()
    
    -- Save to history
    local entry = {
        timestamp = GetTimeStamp(),
        arc = progress.arc,
        cycle = progress.cycle,
        stage = progress.stage,
        score = progress.score,
        isSolo = progress.isSolo,
        duration = runTime,
        completed = progress.isCompleted,
    }
    table.insert(sv.history, 1, entry)
    while #sv.history > 20 do table.remove(sv.history) end
    
    -- Update lifetime stats
    sv.lifetime.totalScore = (sv.lifetime.totalScore or 0) + progress.score
    sv.lifetime.totalTime = (sv.lifetime.totalTime or 0) + runTime
    if progress.isCompleted then
        sv.lifetime.completedRuns = (sv.lifetime.completedRuns or 0) + 1
    end
    
    -- Check personal bests
    NWT.CheckAndUpdatePersonalBest(progress)
    
    ea.inArchive = false
    
    if ea.isOpen then NWT.UpdateEndlessArchiveDashboard() end
end

function NWT.OnEndlessDungeonScoreUpdated(eventCode, currentScore, reason)
    local ea = NWT.EndlessArchive
    ea.currentScore = currentScore
    
    -- Track kills by reason
    local sv = NWT.savedVars.endlessArchive
    if reason == ENDLESS_DUNGEON_POINT_REASON_KILL_BOSS then
        sv.lifetime.bossKills = (sv.lifetime.bossKills or 0) + 1
    end
    if reason == ENDLESS_DUNGEON_POINT_REASON_KILL_NORMAL_MONSTER or 
       reason == ENDLESS_DUNGEON_POINT_REASON_KILL_BOSS or
       reason == ENDLESS_DUNGEON_POINT_REASON_KILL_MINIBOSS or
       reason == ENDLESS_DUNGEON_POINT_REASON_KILL_CHAMPION or
       reason == ENDLESS_DUNGEON_POINT_REASON_KILL_BANNERMEN then
        sv.lifetime.totalKills = (sv.lifetime.totalKills or 0) + 1
    end
    
    if ea.isOpen then NWT.UpdateEndlessArchiveDashboard() end
end

function NWT.OnEndlessDungeonCounterChanged(eventCode, counterType, counterValue)
    local ea = NWT.EndlessArchive
    local progress = NWT.GetArchiveProgress()
    NWT.CheckAndUpdatePersonalBest(progress)
    
    if ea.isOpen then NWT.UpdateEndlessArchiveDashboard() end
end

function NWT.OnEndlessDungeonBuffUpdated(eventCode, buffType, abilityId, stackCount)
    NWT.RefreshEndlessArchiveBuffs()
    local ea = NWT.EndlessArchive
    if ea.isOpen then NWT.UpdateEndlessArchiveDashboard() end
end

function NWT.OnEndlessDungeonInitialized(eventCode, endlessDungeonId, flags, completed)
    local ea = NWT.EndlessArchive
    ea.inArchive = true
    NWT.RefreshEndlessArchiveBuffs()
    if ea.isOpen then NWT.UpdateEndlessArchiveDashboard() end
end

-- ============================================
-- SCENE MANAGEMENT
-- ============================================
local ATK_EndlessArchiveScreen = ZO_Gamepad_ParametricList_Screen:Subclass()

function ATK_EndlessArchiveScreen:New(control)
    return ZO_Gamepad_ParametricList_Screen.New(self, control)
end

function ATK_EndlessArchiveScreen:Initialize(control)
    ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, NWT.EndlessArchiveScene)
end

function ATK_EndlessArchiveScreen:PerformUpdate()
end

function ATK_EndlessArchiveScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = "Refresh",
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = function()
                NWT.RefreshEndlessArchiveBuffs()
                NWT.UpdateEndlessArchiveDashboard()
                PlaySound(SOUNDS.POSITIVE_CLICK)
            end,
        },
        {
            name = function()
                local ea = NWT.EndlessArchive
                return ea.tabs[ea.currentTab] or "Current Run"
            end,
            keybind = "UI_SHORTCUT_SECONDARY",
            callback = function()
                -- Cycle through tabs
                local ea = NWT.EndlessArchive
                ea.currentTab = (ea.currentTab % #ea.tabs) + 1
                NWT.UpdateEndlessArchiveDashboard()
                PlaySound(SOUNDS.POSITIVE_CLICK)
            end,
        },
        {
            name = "Travel to Archive",
            keybind = "UI_SHORTCUT_TERTIARY",
            callback = function()
                NWT.TravelToInfiniteArchive()
            end,
        },
        {
            name = "< Prev Tab",
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            callback = function()
                local ea = NWT.EndlessArchive
                ea.currentTab = ea.currentTab - 1
                if ea.currentTab < 1 then ea.currentTab = #ea.tabs end
                NWT.UpdateEndlessArchiveDashboard()
                PlaySound(SOUNDS.GAMEPAD_MENU_BACKWARD)
            end,
        },
        {
            name = "Next Tab >",
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            callback = function()
                local ea = NWT.EndlessArchive
                ea.currentTab = ea.currentTab + 1
                if ea.currentTab > #ea.tabs then ea.currentTab = 1 end
                NWT.UpdateEndlessArchiveDashboard()
                PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
            end,
        },
    }
    local function OnBack()
        NWT.CloseEndlessArchiveDashboard()
        -- Return to addon menu instead of closing everything
        zo_callLater(function()
            if MAIN_MENU_GAMEPAD then
                SCENE_MANAGER:Show("mainMenuGamepad")
            end
        end, 100)
    end
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, OnBack)
end

function NWT.InitEndlessArchiveScene()
    if NWT.EndlessArchive.sceneInitialized then return end
    local ui = ATK_EndlessArchive_UI
    if not ui then return end
    
    local hiddenControl = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenEndlessArchiveList", GuiRoot, "ATK_HouseList_Screen")
    hiddenControl:SetHidden(true)
    hiddenControl:SetAlpha(0)
    
    local fragment = ZO_SimpleSceneFragment:New(ui)
    local hiddenFragment = ZO_SimpleSceneFragment:New(hiddenControl)
    
    NWT.EndlessArchiveScene = ZO_Scene:New("endlessArchiveDashboardScene", SCENE_MANAGER)
    NWT.EndlessArchiveScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    NWT.EndlessArchiveScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    NWT.EndlessArchiveScene:AddFragment(fragment)
    NWT.EndlessArchiveScene:AddFragment(hiddenFragment)
    
    NWT.EndlessArchiveScreen = ATK_EndlessArchiveScreen:New(hiddenControl)
    NWT.EndlessArchiveList = NWT.EndlessArchiveScreen:GetMainList()
    
    NWT.EndlessArchiveList:AddDataTemplate("ZO_GamepadItemEntryTemplate", function() end, ZO_GamepadMenuEntryTemplateParametricListFunction)
    
    -- D-pad navigation
    NWT.EndlessArchiveList.MovePrevious = function(self, ...)
        NWT.EndlessArchiveScroll("up")
    end
    NWT.EndlessArchiveList.MoveNext = function(self, ...)
        NWT.EndlessArchiveScroll("down")
    end
    
    NWT.EndlessArchiveScene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            NWT.EndlessArchive.isOpen = true
            NWT.RefreshEndlessArchiveBuffs()
            NWT.UpdateEndlessArchiveDashboard()
        elseif newState == SCENE_HIDDEN then
            NWT.EndlessArchive.isOpen = false
        end
    end)
    
    NWT.EndlessArchive.sceneInitialized = true
end

function NWT.EndlessArchiveScroll(dir)
    local ea = NWT.EndlessArchive
    if ea.currentTab == 2 then -- Buffs tab
        local totalBuffs = #ea.activeVerses + #ea.activeVisions
        if dir == "up" and ea.selectedBuffIndex > 1 then
            ea.selectedBuffIndex = ea.selectedBuffIndex - 1
            PlaySound(SOUNDS.GAMEPAD_MENU_BACKWARD)
        elseif dir == "down" and ea.selectedBuffIndex < totalBuffs then
            ea.selectedBuffIndex = ea.selectedBuffIndex + 1
            PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
        end
        -- Update scroll offset
        if ea.selectedBuffIndex <= ea.buffScrollOffset then
            ea.buffScrollOffset = ea.selectedBuffIndex - 1
        elseif ea.selectedBuffIndex > ea.buffScrollOffset + ea.maxVisibleBuffs then
            ea.buffScrollOffset = ea.selectedBuffIndex - ea.maxVisibleBuffs
        end
    elseif ea.currentTab == 3 then -- History tab
        local sv = NWT.savedVars.endlessArchive
        local historyCount = #(sv.history or {})
        if dir == "up" and ea.selectedHistoryIndex > 1 then
            ea.selectedHistoryIndex = ea.selectedHistoryIndex - 1
            PlaySound(SOUNDS.GAMEPAD_MENU_BACKWARD)
        elseif dir == "down" and ea.selectedHistoryIndex < historyCount then
            ea.selectedHistoryIndex = ea.selectedHistoryIndex + 1
            PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
        end
        -- Update scroll offset
        if ea.selectedHistoryIndex <= ea.historyScrollOffset then
            ea.historyScrollOffset = ea.selectedHistoryIndex - 1
        elseif ea.selectedHistoryIndex > ea.historyScrollOffset + ea.maxVisibleHistory then
            ea.historyScrollOffset = ea.selectedHistoryIndex - ea.maxVisibleHistory
        end
    end
    NWT.UpdateEndlessArchiveDashboard()
end

function NWT.OpenEndlessArchiveDashboard()
    NWT.InitEndlessArchiveScene()
    if NWT.EndlessArchiveScene then
        SCENE_MANAGER:Show("endlessArchiveDashboardScene")
    end
end

function NWT.CloseEndlessArchiveDashboard()
    if NWT.EndlessArchiveScene then
        SCENE_MANAGER:Hide("endlessArchiveDashboardScene")
    end
end

function NWT.TravelToInfiniteArchive()
    -- Search for the Infinite Archive (it's a group dungeon POI, not a wayshrine)
    local numNodes = GetNumFastTravelNodes()
    for i = 1, numNodes do
        local known, name, _, _, _, _, poiType, isShown = GetFastTravelNodeInfo(i)
        if known then
            local nameLower = name:lower()
            -- Check for Infinite Archive or Endless Archive in the name
            if nameLower:find("infinite") or nameLower:find("endless archive") then
                FastTravelToNode(i)
                NWT.CloseEndlessArchiveDashboard()
                PlaySound(SOUNDS.POSITIVE_CLICK)
                return
            end
        end
    end
    -- If not found by name, try to find by zone
    for i = 1, numNodes do
        local known, name, _, _, _, _, poiType, isShown = GetFastTravelNodeInfo(i)
        if known then
            local zoneIndex, poiIndex = GetFastTravelNodePOIIndicies(i)
            local zoneName = GetZoneNameById(GetZoneId(zoneIndex))
            if zoneName then
                local zoneNameLower = zoneName:lower()
                if zoneNameLower:find("infinite") or zoneNameLower:find("endless") then
                    FastTravelToNode(i)
                    NWT.CloseEndlessArchiveDashboard()
                    PlaySound(SOUNDS.POSITIVE_CLICK)
                    return
                end
            end
        end
    end
    d("|cFFFF00[Infinite Archive]|r Location not found. Use /archivelocations to list available travel nodes.")
end

SLASH_COMMANDS["/archivelocations"] = function()
    local numNodes = GetNumFastTravelNodes()
    d("|cFFAA00[Debug]|r Listing travel nodes with 'archive' or 'infinite'...")
    for i = 1, numNodes do
        local known, name, _, _, _, _, poiType, isShown = GetFastTravelNodeInfo(i)
        if known then
            local nameLower = name:lower()
            if nameLower:find("archive") or nameLower:find("infinite") or nameLower:find("endless") then
                local zoneIndex = GetFastTravelNodePOIIndicies(i)
                local zoneName = GetZoneNameById(GetZoneId(zoneIndex)) or "Unknown"
                d("  " .. name .. " (Zone: " .. zoneName .. ", POI Type: " .. tostring(poiType) .. ")")
            end
        end
    end
end

-- ============================================
-- UI UPDATE FUNCTIONS
-- ============================================
function NWT.UpdateEndlessArchiveDashboard()
    local ui = ATK_EndlessArchive_UI
    if not ui then return end
    local ea = NWT.EndlessArchive
    local sv = NWT.savedVars.endlessArchive
    local colors = NWT.GetColors and NWT.GetColors() or { accent = "9932CC", positive = "00FF00", negative = "FF4444", warning = "FFAA00" }
    
    -- Update header
    local header = ui:GetNamedChild("Header")
    if header then
        local title = header:GetNamedChild("Title")
        local subtitle = header:GetNamedChild("Subtitle")
        if title then title:SetText("|c9932CCINFINITE ARCHIVE|r") end
        if subtitle then
            local tabText = ""
            for i, tab in ipairs(ea.tabs) do
                if i == ea.currentTab then
                    tabText = tabText .. "|cFFD700[" .. tab .. "]|r  "
                else
                    tabText = tabText .. "|c666666" .. tab .. "|r  "
                end
            end
            subtitle:SetText(tabText)
        end
    end
    
    -- Show/hide panels based on current tab
    local currentRunPanel = ui:GetNamedChild("CurrentRunPanel")
    local buffsPanel = ui:GetNamedChild("BuffsPanel")
    local historyPanel = ui:GetNamedChild("HistoryPanel")
    
    if currentRunPanel then currentRunPanel:SetHidden(ea.currentTab ~= 1) end
    if buffsPanel then buffsPanel:SetHidden(ea.currentTab ~= 2) end
    if historyPanel then historyPanel:SetHidden(ea.currentTab ~= 3) end
    
    if ea.currentTab == 1 then
        NWT.UpdateCurrentRunPanel(ui)
    elseif ea.currentTab == 2 then
        NWT.UpdateBuffsPanel(ui)
    elseif ea.currentTab == 3 then
        NWT.UpdateHistoryPanel(ui)
    end
end

function NWT.UpdateCurrentRunPanel(ui)
    local panel = ui:GetNamedChild("CurrentRunPanel")
    if not panel then return end
    local ea = NWT.EndlessArchive
    local sv = NWT.savedVars.endlessArchive
    local progress = NWT.GetArchiveProgress()
    local runTime = NWT.GetArchiveRunTime()
    local leaderboard = NWT.GetArchiveLeaderboardInfo()
    
    -- Left column - Current Run Stats
    local leftCol = panel:GetNamedChild("LeftCol")
    if leftCol then
        local statusLabel = leftCol:GetNamedChild("Status")
        if statusLabel then
            if progress.isActive then
                statusLabel:SetText("|c00FF00IN PROGRESS|r")
            elseif ea.inArchive then
                statusLabel:SetText("|cFFAA00IN ARCHIVE|r")
            else
                statusLabel:SetText("|c888888NOT IN ARCHIVE|r")
            end
        end
        
        local progressLabel = leftCol:GetNamedChild("Progress")
        if progressLabel then
            progressLabel:SetText("|cFFFFFFProgress:|r " .. NWT.FormatArchiveProgress(progress.arc, progress.cycle, progress.stage))
        end
        
        local scoreLabel = leftCol:GetNamedChild("Score")
        if scoreLabel then
            scoreLabel:SetText("|cFFFFFFScore:|r |cFFD700" .. NWT.FormatGold(progress.score) .. "|r")
        end
        
        local livesLabel = leftCol:GetNamedChild("Lives")
        if livesLabel then
            local livesColor = progress.lives > 1 and "00FF00" or (progress.lives == 1 and "FFAA00" or "FF4444")
            livesLabel:SetText("|cFFFFFFLives:|r |c" .. livesColor .. progress.lives .. "|r")
        end
        
        local timerLabel = leftCol:GetNamedChild("Timer")
        if timerLabel then
            timerLabel:SetText("|cFFFFFFTime:|r " .. NWT.FormatArchiveTime(runTime))
        end
        
        local modeLabel = leftCol:GetNamedChild("Mode")
        if modeLabel then
            local modeText = progress.isSolo and "|c00AAFFSolo|r" or "|cFFAA00Duo|r"
            modeLabel:SetText("|cFFFFFFMode:|r " .. modeText)
        end
    end
    
    -- Center column - Personal Bests
    local centerCol = panel:GetNamedChild("CenterCol")
    if centerCol then
        local soloBestScore = centerCol:GetNamedChild("SoloBestScore")
        if soloBestScore then
            soloBestScore:SetText("|c00AAFFSolo Best Score:|r " .. NWT.FormatGold(sv.bestScore.solo or 0))
        end
        
        local soloBestStage = centerCol:GetNamedChild("SoloBestStage")
        if soloBestStage then
            local best = sv.bestStage.solo or { arc = 0, cycle = 0, stage = 0 }
            soloBestStage:SetText("|c00AAFFSolo Best Stage:|r " .. NWT.FormatArchiveProgress(best.arc, best.cycle, best.stage))
        end
        
        local duoBestScore = centerCol:GetNamedChild("DuoBestScore")
        if duoBestScore then
            duoBestScore:SetText("|cFFAA00Duo Best Score:|r " .. NWT.FormatGold(sv.bestScore.duo or 0))
        end
        
        local duoBestStage = centerCol:GetNamedChild("DuoBestStage")
        if duoBestStage then
            local best = sv.bestStage.duo or { arc = 0, cycle = 0, stage = 0 }
            duoBestStage:SetText("|cFFAA00Duo Best Stage:|r " .. NWT.FormatArchiveProgress(best.arc, best.cycle, best.stage))
        end
        
        -- Weekly leaderboard info
        local weeklyRankLabel = centerCol:GetNamedChild("WeeklyRank")
        if weeklyRankLabel then
            local rankText = ""
            if leaderboard.soloRank > 0 then
                rankText = "|c00AAFFSolo #" .. leaderboard.soloRank .. "|r"
            end
            if leaderboard.duoRank > 0 then
                if rankText ~= "" then rankText = rankText .. "  " end
                rankText = rankText .. "|cFFAA00Duo #" .. leaderboard.duoRank .. "|r"
            end
            if rankText == "" then rankText = "|c888888Not ranked this week|r" end
            weeklyRankLabel:SetText("|cFFFFFFWeekly Rank:|r " .. rankText)
        end
    end
    
    -- Right column - Lifetime Stats
    local rightCol = panel:GetNamedChild("RightCol")
    if rightCol then
        local lt = sv.lifetime or {}
        
        local totalRunsLabel = rightCol:GetNamedChild("TotalRuns")
        if totalRunsLabel then
            totalRunsLabel:SetText("|cFFFFFFTotal Runs:|r " .. (lt.totalRuns or 0))
        end
        
        local completedLabel = rightCol:GetNamedChild("Completed")
        if completedLabel then
            completedLabel:SetText("|cFFFFFFCompleted:|r " .. (lt.completedRuns or 0))
        end
        
        local totalScoreLabel = rightCol:GetNamedChild("TotalScore")
        if totalScoreLabel then
            totalScoreLabel:SetText("|cFFFFFFTotal Score:|r " .. NWT.FormatGold(lt.totalScore or 0))
        end
        
        local totalKillsLabel = rightCol:GetNamedChild("TotalKills")
        if totalKillsLabel then
            totalKillsLabel:SetText("|cFFFFFFTotal Kills:|r " .. NWT.FormatGold(lt.totalKills or 0))
        end
        
        local bossKillsLabel = rightCol:GetNamedChild("BossKills")
        if bossKillsLabel then
            bossKillsLabel:SetText("|cFFFFFFBoss Kills:|r " .. (lt.bossKills or 0))
        end
        
        local totalTimeLabel = rightCol:GetNamedChild("TotalTime")
        if totalTimeLabel then
            totalTimeLabel:SetText("|cFFFFFFTotal Time:|r " .. NWT.FormatArchiveTime(lt.totalTime or 0))
        end
        
        local highestArcLabel = rightCol:GetNamedChild("HighestArc")
        if highestArcLabel then
            highestArcLabel:SetText("|cFFFFFFHighest Arc:|r " .. (lt.highestArc or 0))
        end
    end
end

function NWT.UpdateBuffsPanel(ui)
    local panel = ui:GetNamedChild("BuffsPanel")
    if not panel then return end
    local ea = NWT.EndlessArchive
    local summary = NWT.GetBuffSummary()
    
    -- Header stats
    local headerLabel = panel:GetNamedChild("Header")
    if headerLabel then
        headerLabel:SetText(string.format("|c9932CCACTIVE BUFFS|r  |cFFFFFF(%d Verses, %d Visions)|r", #ea.activeVerses, #ea.activeVisions))
    end
    
    -- Combine verses and visions for display
    local allBuffs = {}
    for _, v in ipairs(ea.activeVerses) do table.insert(allBuffs, v) end
    for _, v in ipairs(ea.activeVisions) do table.insert(allBuffs, v) end
    
    -- Buff list
    local listPanel = panel:GetNamedChild("List")
    if listPanel then
        local offset = ea.buffScrollOffset or 0
        for i = 1, ea.maxVisibleBuffs do
            local row = listPanel:GetNamedChild("Row" .. i)
            if row then
                local dataIndex = i + offset
                local buff = allBuffs[dataIndex]
                if buff then
                    local isSelected = (dataIndex == ea.selectedBuffIndex)
                    local prefix = isSelected and "|cFFD700> |r" or ""
                    local typeColor = buff.type == "verse" and "00AAFF" or (buff.type == "vision" and "FF66FF" or "888888")
                    local typeLabel = buff.type == "verse" and "[V]" or (buff.type == "vision" and "[Vis]" or "[?]")
                    local stackText = buff.stacks > 1 and (" x" .. buff.stacks) or ""
                    row:SetText(string.format("%s|c%s%s|r |cFFFFFF%s|r%s", prefix, typeColor, typeLabel, buff.name, stackText))
                else
                    row:SetText("")
                end
            end
        end
        
        local emptyLabel = listPanel:GetNamedChild("Empty")
        if emptyLabel then
            emptyLabel:SetHidden(#allBuffs > 0)
        end
    end
    
    -- Lifetime stacks summary
    local summaryLabel = panel:GetNamedChild("Summary")
    if summaryLabel then
        summaryLabel:SetText(string.format("|cFFFFFFLifetime:|r %d Verse Stacks, %d Vision Stacks, %d Avatar Stacks", 
            summary.verseStacks, summary.visionStacks, summary.avatarStacks))
    end
end

function NWT.UpdateHistoryPanel(ui)
    local panel = ui:GetNamedChild("HistoryPanel")
    if not panel then return end
    local ea = NWT.EndlessArchive
    local sv = NWT.savedVars.endlessArchive
    local history = sv.history or {}
    
    -- History list
    local listPanel = panel:GetNamedChild("List")
    if listPanel then
        local offset = ea.historyScrollOffset or 0
        for i = 1, ea.maxVisibleHistory do
            local row = listPanel:GetNamedChild("Row" .. i)
            if row then
                local dataIndex = i + offset
                local entry = history[dataIndex]
                if entry then
                    local isSelected = (dataIndex == ea.selectedHistoryIndex)
                    local prefix = isSelected and "|cFFD700> |r" or ""
                    local modeColor = entry.isSolo and "00AAFF" or "FFAA00"
                    local modeText = entry.isSolo and "Solo" or "Duo"
                    local dateText = os.date("%m/%d %H:%M", entry.timestamp)
                    local progressText = NWT.FormatArchiveProgress(entry.arc, entry.cycle, entry.stage)
                    row:SetText(string.format("%s|c%s%s|r |c888888%s|r - %s - |cFFD700%s|r", 
                        prefix, modeColor, modeText, dateText, progressText, NWT.FormatGold(entry.score)))
                else
                    row:SetText("")
                end
            end
        end
        
        local emptyLabel = listPanel:GetNamedChild("Empty")
        if emptyLabel then
            emptyLabel:SetHidden(#history > 0)
        end
    end
    
    -- Selected run details
    local detailsPanel = panel:GetNamedChild("Details")
    if detailsPanel and history[ea.selectedHistoryIndex] then
        local entry = history[ea.selectedHistoryIndex]
        
        local dateLabel = detailsPanel:GetNamedChild("Date")
        if dateLabel then
            dateLabel:SetText("|cFFFFFFDate:|r " .. os.date("%B %d, %Y at %I:%M %p", entry.timestamp))
        end
        
        local modeLabel = detailsPanel:GetNamedChild("Mode")
        if modeLabel then
            local modeText = entry.isSolo and "|c00AAFFSolo|r" or "|cFFAA00Duo|r"
            modeLabel:SetText("|cFFFFFFMode:|r " .. modeText)
        end
        
        local progressLabel = detailsPanel:GetNamedChild("Progress")
        if progressLabel then
            progressLabel:SetText("|cFFFFFFProgress:|r " .. NWT.FormatArchiveProgress(entry.arc, entry.cycle, entry.stage))
        end
        
        local scoreLabel = detailsPanel:GetNamedChild("Score")
        if scoreLabel then
            scoreLabel:SetText("|cFFFFFFScore:|r |cFFD700" .. NWT.FormatGold(entry.score) .. "|r")
        end
        
        local durationLabel = detailsPanel:GetNamedChild("Duration")
        if durationLabel then
            durationLabel:SetText("|cFFFFFFDuration:|r " .. NWT.FormatArchiveTime(entry.duration or 0))
        end
    end
end

-- ============================================
-- EVENT REGISTRATION
-- ============================================
function NWT.RegisterEndlessArchiveEvents()
    EVENT_MANAGER:RegisterForEvent("ATK_EndlessArchive", EVENT_ENDLESS_DUNGEON_STARTED, NWT.OnEndlessDungeonStarted)
    EVENT_MANAGER:RegisterForEvent("ATK_EndlessArchive", EVENT_ENDLESS_DUNGEON_COMPLETED, NWT.OnEndlessDungeonCompleted)
    EVENT_MANAGER:RegisterForEvent("ATK_EndlessArchive", EVENT_ENDLESS_DUNGEON_SCORE_UPDATED, NWT.OnEndlessDungeonScoreUpdated)
    EVENT_MANAGER:RegisterForEvent("ATK_EndlessArchive", EVENT_ENDLESS_DUNGEON_COUNTER_VALUE_CHANGED, NWT.OnEndlessDungeonCounterChanged)
    EVENT_MANAGER:RegisterForEvent("ATK_EndlessArchive", EVENT_ENDLESS_DUNGEON_BUFF_STACK_COUNT_UPDATED, NWT.OnEndlessDungeonBuffUpdated)
    EVENT_MANAGER:RegisterForEvent("ATK_EndlessArchive", EVENT_ENDLESS_DUNGEON_INITIALIZED, NWT.OnEndlessDungeonInitialized)
end

-- Slash command
SLASH_COMMANDS["/archive"] = function()
    NWT.OpenEndlessArchiveDashboard()
end
