local ACTIVITY_FINDER_PLUS = ACTIVITY_FINDER_PLUS
local DungeonData = ACTIVITY_FINDER_PLUS.DungeonData

local PLEDGE_NPC_STRING_IDS = {
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_NPC1,
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_NPC2,
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_NPC3,
}

local ICON_QUEST_DONE = "|t16:16:/esoui/art/cadwell/check.dds|t"
local ICON_HARDMODE = "|t20:20:/esoui/art/unitframes/target_veteranrank_icon.dds|t"
local ICON_TRIFECTA = "|t20:20:/esoui/art/ava/overview_icon_underdog_score.dds|t"
local ICON_NO_DEATH = "|t20:20:/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_death.dds|t"

local ICON_ACHIEVEMENT_DONE = "|t28:28:/esoui/art/cadwell/check.dds|t"
local ICON_ACHIEVEMENT_PENDING = "|t28:28:/esoui/art/buttons/decline_up.dds|t"

local KEYBOARD_TOOLTIP_WIDTH = 420
local KEYBOARD_TOOLTIP_BASE_HEIGHT = 240
local KEYBOARD_TOOLTIP_LINE_HEIGHT = 24

local cacheEventsRegistered = false
local isDecoratingRows = false
local pledgeJournalRefreshPending = false
local collectionEventsRegistered = false

local activityIdToZoneId = {}

local function IsLibSetsAvailable()
    return LibSets ~= nil
        and type(LibSets.GetNumItemSetCollectionZoneUnlockedPieces) == "function"
        and type(LibSets.GetAllDungeonZoneIdData) == "function"
end

local function BuildActivityIdToZoneIdMap()
    activityIdToZoneId = {}
    if not IsLibSetsAvailable() then return end

    local allDungeonData = LibSets.GetAllDungeonZoneIdData()
    if not allDungeonData then return end

    for zoneId, data in pairs(allDungeonData) do
        local finderIds = data.dungeonFinderId
        if finderIds then
            if finderIds[false] then
                activityIdToZoneId[finderIds[false]] = zoneId
            end
            if finderIds[true] then
                activityIdToZoneId[finderIds[true]] = zoneId
            end
        end
    end
end

local function GetCollectionProgressForZone(zoneId)
    if not zoneId or not IsLibSetsAvailable() then return nil, nil end
    local numUnlocked, numTotal = LibSets.GetNumItemSetCollectionZoneUnlockedPieces(zoneId)
    if not numUnlocked or not numTotal or numTotal <= 0 then
        return nil, nil
    end
    return numUnlocked, numTotal
end

local function BuildCollectionText(activityId)
    if not ACTIVITY_FINDER_PLUS.ShowSetCollectionProgress then return "" end
    local entry = ACTIVITY_FINDER_PLUS.collectionCache and ACTIVITY_FINDER_PLUS.collectionCache[activityId]
    if not entry then return "" end

    local color = entry.unlocked >= entry.total and "00ff00" or "aaaaaa"
    return string.format("|c%s%d/%d|r ", color, entry.unlocked, entry.total)
end

local function GetPledgeStatus(pledges, pledgeName)
    if not pledges or not pledgeName or pledgeName == "" then
        return nil, nil
    end
    for _, info in ipairs(pledges) do
        if info.dungeon == pledgeName then
            return info.complete, info.daily
        end
    end
    return nil, nil
end

local function HasIncompletePledge(pledges, pledgeName)
    local complete = GetPledgeStatus(pledges, pledgeName)
    return complete == false
end

local function HasIncompleteSkillQuest(dungeon)
    return dungeon ~= nil and dungeon.questId ~= nil and GetCompletedQuestInfo(dungeon.questId) == ""
end

local function HasAnyIncompleteSkillQuest()
    local normalIndex = ACTIVITY_FINDER_PLUS.FinderNormalIndex
    if not normalIndex then return false end
    for _, dungeon in pairs(normalIndex) do
        if HasIncompleteSkillQuest(dungeon) then
            return true
        end
    end
    return false
end

function ACTIVITY_FINDER_PLUS.HasAnyIncompleteSkillQuest()
    return HasAnyIncompleteSkillQuest()
end

local function RefreshSkillQuestButtonState()
    local button = ACTIVITY_FINDER_PLUS.checkSkillQuests.button
    if not button or button:IsHidden() then return end
    if IsUnitGrouped("player") and not IsUnitGroupLeader("player") then return end
    button:SetState(HasAnyIncompleteSkillQuest() and BSTATE_NORMAL or BSTATE_DISABLED)
end

local function GetTodayDailyPledgeNames()
    local lupPledges = LibUndauntedPledges.GetPledges()
    if type(lupPledges) ~= "table" then return {} end

    local namesByQuestName = {}
    local pledgeGivers = { LibUndauntedPledges.BASE1, LibUndauntedPledges.BASE2, LibUndauntedPledges.DLC1 }
    for _, giverId in ipairs(pledgeGivers) do
        local info = lupPledges[giverId]
        if info and info.questId and info.questId > 0 then
            local questName = GetQuestName(info.questId)
            if questName and questName ~= "" then
                namesByQuestName[questName] = true
            end
        end
    end

    return namesByQuestName
end

local function BuildPledgeText(completed, daily)
    if daily == nil then return "" end
    local dailyText = daily and (" ["..GetString(SI_ACTIVITY_FINDER_PLUS_PLEDGE_DAILY).."]") or ""
    if completed == false then
        return "|cb7ff00 "..dailyText.."|r |c00ffff["..GetString(SI_ACTIVITY_FINDER_PLUS_PLEDGE_QUEST).."]|r"
    elseif completed == true then
        return "|cb7ff00 "..dailyText.."|r |cffffff["..GetString(SI_ACTIVITY_FINDER_PLUS_PLEDGE_DONE).."]|r"
    elseif daily then
        return " |cb7ff00"..dailyText.."|r"
    end
    return ""
end

local function BuildIconText(cacheEntry)
    if not cacheEntry then return "" end
    local icons = ""
    if cacheEntry.questDone then
        icons = icons .. ICON_QUEST_DONE
    end
    if cacheEntry.hm then
        icons = icons .. ICON_HARDMODE
    end
    if cacheEntry.tt then
        icons = icons .. ICON_TRIFECTA
    end
    if cacheEntry.nd then
        icons = icons .. ICON_NO_DEATH
    end
    return icons
end
ACTIVITY_FINDER_PLUS.BuildIconText = BuildIconText

-- activityId (either normal.id or vet.id) -> dungeon record, mode ("normal"/"vet").
function ACTIVITY_FINDER_PLUS.GetDungeonForActivityId(activityId)
    if not activityId then return nil end

    if not ACTIVITY_FINDER_PLUS.FinderVeteranIndex then
        ACTIVITY_FINDER_PLUS.BuildDungeonIndices()
    end

    local vetDungeon = ACTIVITY_FINDER_PLUS.FinderVeteranIndex and ACTIVITY_FINDER_PLUS.FinderVeteranIndex[activityId]
    if vetDungeon then return vetDungeon, "vet" end

    local normalDungeon = ACTIVITY_FINDER_PLUS.FinderNormalIndex and ACTIVITY_FINDER_PLUS.FinderNormalIndex[activityId]
    if normalDungeon then return normalDungeon, "normal" end

    return nil
end

local function BuildAchievementMark(done)
    return done and ICON_ACHIEVEMENT_DONE or ICON_ACHIEVEMENT_PENDING
end

local function BuildAchievementLine(done, text)
    local color = done and "c5eeb5e" or "caaaaaa"
    return string.format("%s |%s%s|r", BuildAchievementMark(done), color, text)
end

-- Set collection progress line for the achievement panel (shared by the gamepad
-- singular panel and the keyboard hover tooltip). collectionCache is keyed by
-- activityId for both normal and vet ids, mapping to the same per-zone totals.
local function BuildCollectionPanelLine(activityId)
    if not ACTIVITY_FINDER_PLUS.ShowSetCollectionProgress then return nil end
    local entry = ACTIVITY_FINDER_PLUS.collectionCache and ACTIVITY_FINDER_PLUS.collectionCache[activityId]
    if not entry then return nil end

    local color = entry.unlocked >= entry.total and "5eeb5e" or "aaaaaa"
    return string.format("|c%s%s %d/%d|r",
        color, GetString(SI_ACTIVITY_FINDER_PLUS_SET_COLLECTION), entry.unlocked, entry.total)
end

-- Shared by the gamepad singular panel and the keyboard hover tooltip.
-- mode is "vet" or "normal"; only vet dungeons carry hm/tt/nd challenge IDs.
function ACTIVITY_FINDER_PLUS.BuildAchievementPanelText(dungeon, mode)
    local modeData = dungeon and dungeon[mode]
    if not modeData then return nil end

    local parts = {}
    local cacheEntry = ACTIVITY_FINDER_PLUS.completionCache and ACTIVITY_FINDER_PLUS.completionCache[modeData.id]
    local collectionLine = BuildCollectionPanelLine(modeData.id)

    if mode == "vet" then
        local header = "|cffcc66" .. GetString(SI_ACTIVITY_FINDER_PLUS_ACHIEVEMENTS_HEADER) .. "|r"
        if modeData.tt then
            header = header .. " " .. BuildAchievementMark(IsAchievementComplete(modeData.tt))
        end

        local iconRow = BuildIconText(cacheEntry)
        if iconRow ~= "" then
            header = header .. " " .. iconRow
        end

        table.insert(parts, header)
    end

    local lines = {}

    if modeData.ac then
        -- vet.ac/normal.ac are account-wide achievements, so they stay
        -- checked on alts who never ran the dungeon. questDone tracks the
        -- current character's own pledge/skill quest completion instead.
        table.insert(lines, BuildAchievementLine(
            cacheEntry ~= nil and cacheEntry.questDone == true,
            GetString(mode == "vet" and SI_ACTIVITY_FINDER_PLUS_VET_CLEAR or SI_ACTIVITY_FINDER_PLUS_NORMAL_CLEAR)))
    end

    if mode == "vet" then
        -- hm/tt/nd are three separate achievement IDs (hard mode, trifecta,
        -- no death), same as the icon logic above.
        for _, achievementId in ipairs({ modeData.hm, modeData.tt, modeData.nd }) do
            if achievementId then
                local name = GetAchievementInfo(achievementId)
                if name and name ~= "" then
                    table.insert(lines, BuildAchievementLine(
                        IsAchievementComplete(achievementId),
                        zo_strformat("<<1>>", name)))
                end
            end
        end
    end

    if #lines > 0 then
        table.insert(parts, table.concat(lines, "\n"))
    end

    if collectionLine then
        table.insert(parts, collectionLine)
    end

    if #parts == 0 then return nil end

    return table.concat(parts, "\n")
end

-- Quest/achievement completion: cached at login and refreshed on achievement events.
function ACTIVITY_FINDER_PLUS.BuildCompletionCache()
    local cache = {}
    for npc = 1, 3 do
        for _, dungeon in ipairs(DungeonData[npc]) do
            local questDone = GetCompletedQuestInfo(dungeon.questId) ~= ""
            local pledgeName = GetQuestName(dungeon.pledgeId)
            for _, mode in ipairs({ "normal", "vet" }) do
                local modeData = dungeon[mode]
                if modeData and modeData.id then
                    cache[modeData.id] = {
                        questDone = questDone,
                        hm = modeData.hm and IsAchievementComplete(modeData.hm) or false,
                        tt = modeData.tt and IsAchievementComplete(modeData.tt) or false,
                        nd = modeData.nd and IsAchievementComplete(modeData.nd) or false,
                        pledgeName = pledgeName,
                    }
                end
            end
        end
    end
    ACTIVITY_FINDER_PLUS.completionCache = cache
end

-- Set collection book progress per dungeon (LibSets + zone mapping).
function ACTIVITY_FINDER_PLUS.BuildCollectionCache()
    local cache = {}
    if not ACTIVITY_FINDER_PLUS.ShowSetCollectionProgress or not IsLibSetsAvailable() then
        ACTIVITY_FINDER_PLUS.collectionCache = cache
        return
    end

    if next(activityIdToZoneId) == nil then
        BuildActivityIdToZoneIdMap()
    end

    for npc = 1, 3 do
        for _, dungeon in ipairs(DungeonData[npc]) do
            for _, mode in ipairs({ "normal", "vet" }) do
                local modeData = dungeon[mode]
                if modeData and modeData.id then
                    local activityId = modeData.id
                    local zoneId = activityIdToZoneId[activityId]
                    if zoneId then
                        local numUnlocked, numTotal = GetCollectionProgressForZone(zoneId)
                        if numUnlocked and numTotal then
                            cache[activityId] = { unlocked = numUnlocked, total = numTotal }
                        end
                    end
                end
            end
        end
    end
    ACTIVITY_FINDER_PLUS.collectionCache = cache
end

-- Today's daily pledge dungeon names: date-driven, safe to cache per session.
function ACTIVITY_FINDER_PLUS.RefreshDailyPledges()
    ACTIVITY_FINDER_PLUS.dailyPledgeNames = GetTodayDailyPledgeNames()
end

-- Active pledge journal state: always live (accept/complete during play).
function ACTIVITY_FINDER_PLUS.RefreshPledgeJournal()
    ACTIVITY_FINDER_PLUS.pledgeJournal = ACTIVITY_FINDER_PLUS.GetGoalPledges()
end

function ACTIVITY_FINDER_PLUS.DecorateDungeonRow(obj)
    if not ACTIVITY_FINDER_PLUS.EnhanceGAF or not obj or not obj.node or not obj.node.data then return end
    local activityId = obj.node.data.id

    local collectionText = BuildCollectionText(activityId)
    if collectionText ~= "" then
        ACTIVITY_FINDER_PLUS.Label(
            "ACTIVITY_FINDER_PLUS_DungeonCollection_" .. activityId,
            obj, {55, 20}, {LEFT, LEFT, 400, 0},
            "ZoFontGame", nil, {2, 1}, collectionText
        )
    end

    local cacheEntry = ACTIVITY_FINDER_PLUS.completionCache and ACTIVITY_FINDER_PLUS.completionCache[activityId]
    if not cacheEntry then return end

    ACTIVITY_FINDER_PLUS.Label(
        "ACTIVITY_FINDER_PLUS_DungeonInfo_" .. activityId,
        obj, {80, 20}, {LEFT, LEFT, 465, 0},
        "ZoFontGame", nil, {0, 1}, BuildIconText(cacheEntry)
    )

    local completed, daily = GetPledgeStatus(ACTIVITY_FINDER_PLUS.pledgeJournal, cacheEntry.pledgeName)
    if obj.text then
        ACTIVITY_FINDER_PLUS.Label(
            "ACTIVITY_FINDER_PLUS_DungeonPledge_" .. activityId,
            obj, {180, 16}, {LEFT, RIGHT, 5, -3, obj.text},
            "ZoFontGame", nil, {0, 1}, BuildPledgeText(completed, daily)
        )
    end
    obj.pledge = completed == false
end

function ACTIVITY_FINDER_PLUS.DecorateDungeonRows()
    if not ACTIVITY_FINDER_PLUS.EnhanceGAF or isDecoratingRows then return end
    isDecoratingRows = true
    for c = 2, 3 do
        local parent = _G["ZO_DungeonFinder_KeyboardListSectionScrollChildContainer" .. c]
        if parent then
            for i = 1, parent:GetNumChildren() do
                ACTIVITY_FINDER_PLUS.DecorateDungeonRow(parent:GetChild(i))
            end
        end
    end
    isDecoratingRows = false
end

local FINDER_BUTTON_WIDTH = 200
local FINDER_BUTTON_HEIGHT = 28

function ACTIVITY_FINDER_PLUS.IsVeteranModeSelected()
    if IsInGamepadPreferredMode() then
        return ACTIVITY_FINDER_PLUS.checkVeteran.sessionEnabled == true
    end

    local checkbox = ACTIVITY_FINDER_PLUS.checkVeteran.checkbox
    return checkbox ~= nil and checkbox:GetState() == BSTATE_PRESSED
end

function ACTIVITY_FINDER_PLUS.SetVeteranModeEnabled(enabled)
    ACTIVITY_FINDER_PLUS.checkVeteran.sessionEnabled = enabled == true

    local checkbox = ACTIVITY_FINDER_PLUS.checkVeteran.checkbox
    if checkbox then
        checkbox:SetState(enabled and BSTATE_PRESSED or BSTATE_NORMAL, true)
    end
end

local function GetTargetDungeonSection()
    return ACTIVITY_FINDER_PLUS.IsVeteranModeSelected() and 3 or 2
end

local function GetFinderIndex()
    return ACTIVITY_FINDER_PLUS.IsVeteranModeSelected() and ACTIVITY_FINDER_PLUS.FinderVeteranIndex or ACTIVITY_FINDER_PLUS.FinderNormalIndex
end

function ACTIVITY_FINDER_PLUS.CanUseQuickSelect()
    if not ACTIVITY_FINDER_PLUS.EnhanceGAF then return false end
    if IsUnitGrouped("player") and not IsUnitGroupLeader("player") then return false end
    if ACTIVITY_FINDER_PLUS.coolDownStatus[LFG_COOLDOWN_ACTIVITY_STARTED] then return false end
    if ZO_ACTIVITY_FINDER_ROOT_MANAGER and ZO_ACTIVITY_FINDER_ROOT_MANAGER:GetIsCurrentlyInQueue() then return false end
    return true
end

function ACTIVITY_FINDER_PLUS.SelectMatchingDungeons(shouldSelect)
    if not ACTIVITY_FINDER_PLUS.CanUseQuickSelect() then return end

    local finderIndex = GetFinderIndex()
    if not finderIndex then return end

    local manager = ZO_ACTIVITY_FINDER_ROOT_MANAGER
    if not manager then return end

    local anySelected = false
    for activityId, dungeon in pairs(finderIndex) do
        if shouldSelect(activityId, dungeon) then
            local location = manager:GetSpecificLocation(activityId)
            if location and not location:IsSelected() and not location:IsLocked() then
                manager:SetLocationSelected(location, true)
                anySelected = true
            end
        end
    end

    if not anySelected then return end

    if DUNGEON_FINDER_KEYBOARD and ACTIVITY_FINDER_PLUS.showSpecificDung then
        DUNGEON_FINDER_KEYBOARD:RefreshView()
    end

    local gamepadFinder = rawget(_G, "DUNGEON_FINDER_GAMEPAD")
    if gamepadFinder and IsInGamepadPreferredMode() then
        gamepadFinder:RefreshView()
    end
end

function ACTIVITY_FINDER_PLUS.RunQuickSelectPledges()
    local pledgesNow = ACTIVITY_FINDER_PLUS.GetGoalPledges()
    if not pledgesNow then return end

    ACTIVITY_FINDER_PLUS.SelectMatchingDungeons(function(_, dungeon)
        return HasIncompletePledge(pledgesNow, GetQuestName(dungeon.pledgeId))
    end)
end

function ACTIVITY_FINDER_PLUS.RunQuickSelectSets()
    ACTIVITY_FINDER_PLUS.SelectMatchingDungeons(function(activityId)
        local finderIndex = GetFinderIndex()
        if not finderIndex or not finderIndex[activityId] then return false end
        local entry = ACTIVITY_FINDER_PLUS.collectionCache and ACTIVITY_FINDER_PLUS.collectionCache[activityId]
        return entry ~= nil and entry.unlocked < entry.total
    end)
end

function ACTIVITY_FINDER_PLUS.RunQuickSelectSkillQuests()
    ACTIVITY_FINDER_PLUS.SelectMatchingDungeons(function(_, dungeon)
        return HasIncompleteSkillQuest(dungeon)
    end)
end

local function ConfigureFinderActionButton(button, state, labelStringId, onClick)
    button:SetDimensions(FINDER_BUTTON_WIDTH, FINDER_BUTTON_HEIGHT)
    button:SetText(GetString(labelStringId))
    button:SetClickSound("Click")
    button:SetHandler("OnClicked", onClick)
    button:SetState(state.state)
    button:SetHidden(ACTIVITY_FINDER_PLUS.coolDownStatus[LFG_COOLDOWN_ACTIVITY_STARTED])
    button:SetDrawTier(2)

    if IsUnitGrouped("player") and not IsUnitGroupLeader("player") then
        button:SetState(BSTATE_DISABLED)
    end
end

local function CreateFinderActionButton(controlName, stateKey, labelStringId, parentKeyboard, anchorTo, onClick)
    local state = ACTIVITY_FINDER_PLUS[stateKey]
    local button = _G[controlName] or WINDOW_MANAGER:CreateControlFromVirtual(controlName, parentKeyboard, "ZO_DefaultButton")
    state.button = button

    ConfigureFinderActionButton(button, state, labelStringId, onClick)
    button:ClearAnchors()
    button:SetAnchor(anchorTo[1], anchorTo[2], anchorTo[3], anchorTo[4], anchorTo[5])
    return button
end

local function ShowVeteranModeTooltip(show)
    if show then
        InitializeTooltip(InformationTooltip, ACTIVITY_FINDER_PLUS_VeteranCheck, TOPRIGHT, -8, 0, TOPLEFT)
        SetTooltipText(InformationTooltip, GetString(SI_ACTIVITY_FINDER_PLUS_VETERAN_MODE_TT))
    else
        ClearTooltip(InformationTooltip)
    end
end

local function CreateVeteranModeControls(parentKeyboard, pledgesButton)
    local veteranState = ACTIVITY_FINDER_PLUS.checkVeteran
    local label = veteranState.label or WINDOW_MANAGER:CreateControl("ACTIVITY_FINDER_PLUS_VeteranLabel", parentKeyboard, CT_LABEL)
    veteranState.label = label
    label:SetFont("ZoFontGame")
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetText(GetString(SI_ACTIVITY_FINDER_PLUS_VETERAN_MODE))
    label:ClearAnchors()
    label:SetAnchor(TOP, pledgesButton, BOTTOM, 0, 4)
    label:SetHidden(false)
    label:SetDrawTier(2)

    local checkbox = veteranState.checkbox or WINDOW_MANAGER:CreateControlFromVirtual("ACTIVITY_FINDER_PLUS_VeteranCheck", parentKeyboard, "ZO_CheckButton")
    veteranState.checkbox = checkbox
    checkbox:ClearAnchors()
    checkbox:SetAnchor(LEFT, label, RIGHT, 6, 0)
    checkbox:SetDrawTier(2)
    checkbox:SetHidden(false)
    checkbox:SetState(BSTATE_NORMAL, false)
    checkbox:SetHandler("OnMouseEnter", function() ShowVeteranModeTooltip(true) end)
    checkbox:SetHandler("OnMouseExit", function() ShowVeteranModeTooltip(false) end)
    checkbox:SetHandler("OnClicked", function(control)
        local nowChecked = control:GetState() ~= BSTATE_PRESSED
        ACTIVITY_FINDER_PLUS.SetVeteranModeEnabled(nowChecked)
        ACTIVITY_FINDER_PLUS.ExpandDungeonListHeaders()
    end)

    return label, checkbox
end

function ACTIVITY_FINDER_PLUS.ExpandDungeonListHeaders()
    local targetSection = GetTargetDungeonSection()
    for c = 2, 3 do
        local header = _G["ZO_DungeonFinder_KeyboardListSectionScrollChildZO_ActivityFinderTemplateNavigationHeader_Keyboard" .. c - 1]
        if header and header.text and ((targetSection == c) ~= (header.text:GetColor() == 1)) then
            header:OnMouseUp(true)
        end
    end
end

function ACTIVITY_FINDER_PLUS.SetupDungeonFinderChrome()
    if not ACTIVITY_FINDER_PLUS.EnhanceGAF then return end

    local parentKeyboard = ZO_DungeonFinder_Keyboard
    if not parentKeyboard then return end

    ACTIVITY_FINDER_PLUS.OnCooldownsUpdate()

    local pledgesButton = CreateFinderActionButton(
        "ACTIVITY_FINDER_PLUS_PledgesCheck",
        "checkPledges",
        SI_ACTIVITY_FINDER_PLUS_CHECK_QUESTS,
        parentKeyboard,
        { BOTTOM, parentKeyboard, BOTTOM, 200, 0 },
        function()
            ACTIVITY_FINDER_PLUS.RunQuickSelectPledges()
        end
    )

    CreateVeteranModeControls(parentKeyboard, pledgesButton)

    local stackAnchor = pledgesButton

    if ACTIVITY_FINDER_PLUS.libSetsAvailable then
        stackAnchor = CreateFinderActionButton(
            "ACTIVITY_FINDER_PLUS_SetsCheck",
            "checkSets",
            SI_ACTIVITY_FINDER_PLUS_CHECK_SETS,
            parentKeyboard,
            { BOTTOM, pledgesButton, TOP, 0, -4 },
            function()
                ACTIVITY_FINDER_PLUS.RunQuickSelectSets()
            end
        )
    end

    local skillQuestButton = CreateFinderActionButton(
        "ACTIVITY_FINDER_PLUS_SkillQuestCheck",
        "checkSkillQuests",
        SI_ACTIVITY_FINDER_PLUS_CHECK_SKILL_QUESTS,
        parentKeyboard,
        { BOTTOM, stackAnchor, TOP, 0, -4 },
        function()
            ACTIVITY_FINDER_PLUS.RunQuickSelectSkillQuests()
        end
    )
    skillQuestButton:SetHandler("OnMouseEnter", function()
        InitializeTooltip(InformationTooltip, skillQuestButton, TOPRIGHT, -8, 0, TOPLEFT)
        SetTooltipText(InformationTooltip, GetString(SI_ACTIVITY_FINDER_PLUS_CHECK_SKILL_QUESTS_TT))
    end)
    skillQuestButton:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
    RefreshSkillQuestButtonState()

    if ACTIVITY_FINDER_PLUS.perfectPixelCompat then
        ZO_SearchingForGroupStatus:ClearAnchors()
        ZO_SearchingForGroupStatus:SetAnchor(BOTTOM, parentKeyboard, BOTTOM, 0, -114)
        ZO_SearchingForGroupStatus:SetDrawTier(2)
    end

    if not ACTIVITY_FINDER_PLUS.perfectPixelCompat and ZO_DungeonFinder_KeyboardQueueButton then
        ZO_DungeonFinder_KeyboardQueueButton:ClearAnchors()
        ZO_DungeonFinder_KeyboardQueueButton:SetAnchor(BOTTOM, parentKeyboard, BOTTOM, -parentKeyboard:GetWidth() / 5, 0)
        ZO_DungeonFinder_KeyboardQueueButton:SetDrawTier(2)
    end

    ACTIVITY_FINDER_PLUS.ExpandDungeonListHeaders()
end

local function OnDungeonListRefresh()
    if not ACTIVITY_FINDER_PLUS.EnhanceGAF or not ACTIVITY_FINDER_PLUS.showSpecificDung then return end
    if ZO_DungeonFinder_KeyboardListSection and not ZO_DungeonFinder_KeyboardListSection:IsHidden() then
        ACTIVITY_FINDER_PLUS.DecorateDungeonRows()
    end
end

local function SchedulePledgeJournalRefresh()
    if pledgeJournalRefreshPending then return end
    pledgeJournalRefreshPending = true
    zo_callLater(function()
        pledgeJournalRefreshPending = false
        ACTIVITY_FINDER_PLUS.RefreshPledgeJournal()
        RefreshSkillQuestButtonState()
        OnDungeonListRefresh()
    end, 100)
end

local function RegisterCacheEvents()
    if cacheEventsRegistered then return end
    cacheEventsRegistered = true

    local em = ACTIVITY_FINDER_PLUS.eventManager
    local prefix = ACTIVITY_FINDER_PLUS.name .. "_PledgeCache"

    em:RegisterForEvent(prefix .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        ACTIVITY_FINDER_PLUS.BuildCompletionCache()
        ACTIVITY_FINDER_PLUS.BuildCollectionCache()
        ACTIVITY_FINDER_PLUS.RefreshDailyPledges()
        ACTIVITY_FINDER_PLUS.RefreshPledgeJournal()
    end)

    em:RegisterForEvent(prefix .. "_Achievement", EVENT_ACHIEVEMENT_AWARDED, function()
        ACTIVITY_FINDER_PLUS.BuildCompletionCache()
        OnDungeonListRefresh()
    end)

    em:RegisterForEvent(prefix .. "_QuestAdded", EVENT_QUEST_ADDED, SchedulePledgeJournalRefresh)
    em:RegisterForEvent(prefix .. "_QuestRemoved", EVENT_QUEST_REMOVED, SchedulePledgeJournalRefresh)
    em:RegisterForEvent(prefix .. "_QuestComplete", EVENT_QUEST_COMPLETE, SchedulePledgeJournalRefresh)
    em:RegisterForEvent(prefix .. "_QuestCounter", EVENT_QUEST_CONDITION_COUNTER_CHANGED, SchedulePledgeJournalRefresh)
end

local function RegisterCollectionEvents()
    if collectionEventsRegistered or not IsLibSetsAvailable() then return end
    collectionEventsRegistered = true

    local em = ACTIVITY_FINDER_PLUS.eventManager
    local prefix = ACTIVITY_FINDER_PLUS.name .. "_SetCollection"
    local function OnCollectionChanged()
        ACTIVITY_FINDER_PLUS.BuildCollectionCache()
        OnDungeonListRefresh()
    end

    em:RegisterForEvent(prefix .. "_Updated", EVENT_ITEM_SET_COLLECTION_UPDATED, OnCollectionChanged)
    em:RegisterForEvent(prefix .. "_UpdatedAll", EVENT_ITEM_SET_COLLECTIONS_UPDATED, OnCollectionChanged)
end

local function InitCachesIfReady()
    if not DoesUnitExist("player") then return end
    ACTIVITY_FINDER_PLUS.BuildCompletionCache()
    ACTIVITY_FINDER_PLUS.BuildCollectionCache()
    ACTIVITY_FINDER_PLUS.RefreshDailyPledges()
    ACTIVITY_FINDER_PLUS.RefreshPledgeJournal()
end

-- Keyboard equivalent of the gamepad singular panel. Other addons (e.g.
-- DungeonTracker) also hook ShowActivityTooltip and inject their own content
-- directly into ZO_ActivityFinderTemplateTooltip_Keyboard's Contents control,
-- which can collide with ours. KeyboardAchievementSeparateWindow (settings
-- panel) lets the user pick: a window we fully own (never collides with
-- anything, but sits apart from the native tooltip), or writing straight
-- into the native tooltip's Contents like the old behavior (matches native
-- layout, but can visually overlap other addons doing the same thing -
-- that collision is a known, accepted tradeoff of this mode).
local function CountTextLines(text)
    local _, lineBreaks = text:gsub("\n", "\n")
    return lineBreaks + 1
end

-- "Separate window" mode: a floating window we fully own, anchored below
-- the native tooltip so it never overlaps content any addon adds inside or
-- beside that tooltip.
local keyboardAchievementTooltip

local function GetKeyboardAchievementTooltip()
    if keyboardAchievementTooltip then return keyboardAchievementTooltip end

    local tooltip = WINDOW_MANAGER:CreateTopLevelWindow("ACTIVITY_FINDER_PLUS_KeyboardAchievementTooltip")
    tooltip:SetClampedToScreen(true)
    tooltip:SetMouseEnabled(false)
    tooltip:SetDrawTier(DT_HIGH)
    tooltip:SetHidden(true)

    local backdrop = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Bg", tooltip, "ZO_DefaultBackdrop")
    backdrop:SetAnchorFill()

    local label = WINDOW_MANAGER:CreateControl("$(parent)Label", tooltip, CT_LABEL)
    label:SetFont("ZoFontGameLarge")
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    label:SetAnchor(TOPLEFT, tooltip, TOPLEFT, 10, 10)
    label:SetAnchor(BOTTOMRIGHT, tooltip, BOTTOMRIGHT, -10, -10)

    keyboardAchievementTooltip = { control = tooltip, label = label }
    return keyboardAchievementTooltip
end

local function ShowSeparateWindow(achievementText)
    local panel = GetKeyboardAchievementTooltip()
    if not achievementText then
        panel.control:SetHidden(true)
        return
    end

    panel.label:SetText(achievementText)
    panel.control:ClearAnchors()
    panel.control:SetAnchor(TOPLEFT, ZO_ActivityFinderTemplateTooltip_Keyboard, BOTTOMLEFT, 0, 10)
    panel.control:SetDimensions(KEYBOARD_TOOLTIP_WIDTH, CountTextLines(achievementText) * KEYBOARD_TOOLTIP_LINE_HEIGHT + 20)
    panel.control:SetHidden(false)
end

local function HideSeparateWindow()
    if keyboardAchievementTooltip then
        keyboardAchievementTooltip.control:SetHidden(true)
    end
end

-- "Same area" mode: writes directly into the native tooltip's Contents,
-- below its set-types section, growing the native tooltip to fit. Can
-- overlap other addons that customize the same tooltip; that's accepted.
local keyboardInlineAchievementLabel

local function GetKeyboardInlineAchievementLabel(parent)
    if keyboardInlineAchievementLabel then return keyboardInlineAchievementLabel end
    local label = WINDOW_MANAGER:CreateControl("ACTIVITY_FINDER_PLUS_KeyboardInlineAchievements", parent, CT_LABEL)
    label:SetFont("ZoFontGameLarge")
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    label:SetDimensions(KEYBOARD_TOOLTIP_WIDTH - 40, 160)
    label:SetDrawTier(2)
    keyboardInlineAchievementLabel = label
    return label
end

local function ShowInline(achievementText)
    local tooltip = ZO_ActivityFinderTemplateTooltip_Keyboard
    local tooltipContents = tooltip:GetNamedChild("Contents")

    local extraHeight = 0
    if achievementText then
        extraHeight = CountTextLines(achievementText) * KEYBOARD_TOOLTIP_LINE_HEIGHT + 20
    end
    tooltip:SetDimensions(KEYBOARD_TOOLTIP_WIDTH, KEYBOARD_TOOLTIP_BASE_HEIGHT + extraHeight)

    -- Bottom-align to the tooltip's lower edge so our text sits below whatever
    -- other addons (e.g. DungeonTracker) inject right under SetTypesSection,
    -- avoiding overlap with their content.
    local label = GetKeyboardInlineAchievementLabel(tooltipContents)
    label:ClearAnchors()
    label:SetAnchor(BOTTOMLEFT, tooltipContents, BOTTOMLEFT, 0, -10)
    label:SetText(achievementText or "")
    label:SetHidden(not achievementText)
end

local function HideInline()
    if keyboardInlineAchievementLabel then
        keyboardInlineAchievementLabel:SetHidden(true)
    end
end

local function AppendAchievementsToKeyboardTooltip(control)
    local achievementText
    if ACTIVITY_FINDER_PLUS.EnhanceGAF then
        local data = control.node and control.node.data
        local dungeon, mode = ACTIVITY_FINDER_PLUS.GetDungeonForActivityId(data and data.id)
        achievementText = dungeon and ACTIVITY_FINDER_PLUS.BuildAchievementPanelText(dungeon, mode)
    end

    if ACTIVITY_FINDER_PLUS.KeyboardAchievementSeparateWindow then
        HideInline()
        ShowSeparateWindow(achievementText)
    else
        HideSeparateWindow()
        ShowInline(achievementText)
    end
end

local function HideKeyboardAchievementTooltip()
    HideSeparateWindow()
    HideInline()
end

function ACTIVITY_FINDER_PLUS.InitializePledges()
    ACTIVITY_FINDER_PLUS.BuildDungeonIndices()
    ACTIVITY_FINDER_PLUS.libSetsAvailable = IsLibSetsAvailable()
    if ACTIVITY_FINDER_PLUS.libSetsAvailable then
        BuildActivityIdToZoneIdMap()
        RegisterCollectionEvents()
    end
    RegisterCacheEvents()
    InitCachesIfReady()

    local function OnDungeonListShown()
        ACTIVITY_FINDER_PLUS.OnCooldownsUpdate()
        ACTIVITY_FINDER_PLUS.RefreshDailyPledges()
        ACTIVITY_FINDER_PLUS.RefreshPledgeJournal()
        ACTIVITY_FINDER_PLUS.BuildCollectionCache()
        ACTIVITY_FINDER_PLUS.showSpecificDung = true
        ACTIVITY_FINDER_PLUS.SetVeteranModeEnabled(false)
        ACTIVITY_FINDER_PLUS.SetupDungeonFinderChrome()
        ACTIVITY_FINDER_PLUS.DecorateDungeonRows()
        -- Tree rows may appear one frame after header expand.
        zo_callLater(OnDungeonListRefresh, 0)
    end

    -- https://wiki.esoui.com/Dungeon_Scroll_List_Data
    ZO_PreHookHandler(ZO_DungeonFinder_KeyboardListSection, "OnEffectivelyShown", OnDungeonListShown)

    ZO_PreHookHandler(ZO_DungeonFinder_KeyboardListSection, "OnEffectivelyHidden", function()
        if ACTIVITY_FINDER_PLUS.perfectPixelCompat and ZO_DungeonFinder_Keyboard then
            ZO_SearchingForGroupStatus:ClearAnchors()
            ZO_SearchingForGroupStatus:SetAnchor(BOTTOM, ZO_DungeonFinder_Keyboard, BOTTOM, -474, -33)
            ZO_SearchingForGroupStatus:SetDrawTier(2)
        end
        if ACTIVITY_FINDER_PLUS_PledgesCheck then ACTIVITY_FINDER_PLUS_PledgesCheck:SetHidden(true) end
        if ACTIVITY_FINDER_PLUS_SetsCheck then ACTIVITY_FINDER_PLUS_SetsCheck:SetHidden(true) end
        if ACTIVITY_FINDER_PLUS_SkillQuestCheck then ACTIVITY_FINDER_PLUS_SkillQuestCheck:SetHidden(true) end
        if ACTIVITY_FINDER_PLUS_VeteranLabel then ACTIVITY_FINDER_PLUS_VeteranLabel:SetHidden(true) end
        if ACTIVITY_FINDER_PLUS_VeteranCheck then ACTIVITY_FINDER_PLUS_VeteranCheck:SetHidden(true) end
        ACTIVITY_FINDER_PLUS.showSpecificDung = false
        HideKeyboardAchievementTooltip()
    end)

    ZO_PostHook(ZO_ActivityFinderTemplate_Keyboard, "RefreshView", function(self)
        if self ~= DUNGEON_FINDER_KEYBOARD then return end
        OnDungeonListRefresh()
    end)

    ZO_PostHook(ZO_ActivityFinderTemplate_Keyboard, "OnFilterChanged", function()
        if ACTIVITY_FINDER_PLUS.showSpecificDung then
            zo_callLater(OnDungeonListRefresh, 0)
        end
    end)

    ZO_PostHook(ZO_ActivityFinderTemplate_Keyboard, "ShowActivityTooltip", AppendAchievementsToKeyboardTooltip)
    ZO_PostHook(ZO_ActivityFinderTemplate_Keyboard, "HideActivityTooltip", HideKeyboardAchievementTooltip)

    ACTIVITY_FINDER_PLUS.InitializePledgesGamepad()
end

function ACTIVITY_FINDER_PLUS.DailyPledges()
    local pledges = ACTIVITY_FINDER_PLUS.GetGoalPledges()
    df("|t16:16:ESOUI/art/icons/ability_weapon_001.dds|t |cffffff%s", GetString(SI_ACTIVITY_FINDER_PLUS_PLEDGE_SLASH))
    local lupPledges = LibUndauntedPledges.GetPledges()
    local pledgeGivers = { LibUndauntedPledges.BASE1, LibUndauntedPledges.BASE2, LibUndauntedPledges.DLC1 }
    for npcIndex, giverId in ipairs(pledgeGivers) do
        local info = lupPledges and lupPledges[giverId]
        local pledgeName
        if info and info.questId and info.questId > 0 then
            pledgeName = GetQuestName(info.questId)
        end
        local quest = ""
        if pledgeName and pledges then
            local completed = GetPledgeStatus(pledges, pledgeName)
            if completed ~= nil then
                quest = completed and "|cffffff["..GetString(SI_ACTIVITY_FINDER_PLUS_PLEDGE_DONE).."]|r"
                    or "|c00ffff["..GetString(SI_ACTIVITY_FINDER_PLUS_PLEDGE_QUEST).."]|r"
            end
        end
        local npcname = GetString(PLEDGE_NPC_STRING_IDS[npcIndex])
        if not pledgeName or pledgeName == "" then
            pledgeName = "?"
        end
        if quest ~= "" then
            df("|cb5b5b5%i.|r |cb7ff00%s|r %s - |cb5b5b5%s|r", npcIndex, pledgeName, quest, npcname)
        else
            df("|cb5b5b5%i.|r |cb7ff00%s|r - |cb5b5b5%s|r", npcIndex, pledgeName, npcname)
        end
    end
end

function ACTIVITY_FINDER_PLUS.GetGoalPledges()
    if not ACTIVITY_FINDER_PLUS.EnhanceGAF then return end

    local pledgeData = {}
    local seenNames = {}
    local dailyNames = ACTIVITY_FINDER_PLUS.dailyPledgeNames or GetTodayDailyPledgeNames()

    for i = 1, MAX_JOURNAL_QUESTS do
        local questName, _, _, stepType, _, _, _, _, _, questType, instanceDisplayType = GetJournalQuestInfo(i)
        if questName and questName ~= "" and questType == QUEST_TYPE_UNDAUNTED_PLEDGE and instanceDisplayType == INSTANCE_TYPE_GROUP then
            local isDaily = dailyNames[questName] or false
            table.insert(pledgeData, {
                dungeon = questName,
                haveQuest = stepType == QUEST_STEP_TYPE_AND,
                daily = isDaily,
                complete = stepType == QUEST_STEP_TYPE_OR
            })
            seenNames[questName] = true
        end
    end

    -- Today's pledge givers are known from LibUndauntedPledges even before the
    -- quest is accepted; surface those as a daily marker (no complete state
    -- yet) so the row tag isn't gated on having picked up the quest.
    for questName in pairs(dailyNames) do
        if not seenNames[questName] then
            table.insert(pledgeData, {
                dungeon = questName,
                haveQuest = false,
                daily = true,
                complete = nil,
            })
        end
    end

    return pledgeData
end
