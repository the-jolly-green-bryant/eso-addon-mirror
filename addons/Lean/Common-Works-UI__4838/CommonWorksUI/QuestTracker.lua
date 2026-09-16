-- Common Works -- everything the panel lists: the quest scan itself, pledges,
-- guild dailies, tomes, the activity queue and PvP objectives, plus
-- the refresh pipeline and the native-tracker handling.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI

-- Quest scan

-- Journal slots are sparse; GetNumJournalQuests is a count, and freed slots still
-- return stale quests. All scanners, including WritBridge, use this iterator.
function CW.JournalQuests()
    local i = 0
    return function()
        repeat
            i = i + 1
            if i > MAX_JOURNAL_QUESTS then return nil end
        until IsValidQuestIndex(i)
        return i
    end
end

function CW.AssistedQuestIndex()
    -- Zone Guide assistance can put a non-quest arg in focusedQuestIndex; validate it.
    local focused = QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex()
    if focused and focused > 0 and GetTrackedIsAssisted(TRACK_TYPE_QUEST, focused) then
        return focused
    end
    for i in CW.JournalQuests() do
        if GetTrackedIsAssisted(TRACK_TYPE_QUEST, i) then return i end
    end
end

-- Match ZO_Tracker:PopulateQuestConditions: want selects main (nil), optional or hint steps.
-- Later steps with neither visibility are hidden; return nil for an empty step.
local function ReadStep(i, s, want)
    local _, visibility, stepType, override, numConditions = GetJournalQuestStepInfo(i, s)
    if visibility == QUEST_STEP_VISIBILITY_HIDDEN then return end
    if want ~= nil and visibility ~= want then return end
    -- Like the native tracker, omit optional endings so they cannot imply quest turn-in.
    if s > QUEST_MAIN_STEP_INDEX and stepType == QUEST_STEP_TYPE_END then return end

    local conds, overrideDone = {}, false
    for c = 1, numConditions do
        local text, cur, max, isFail, isComplete, _, isVisible = GetJournalQuestConditionInfo(i, s, c)
        if override ~= "" then
            -- Show override text once (pledges otherwise repeat it); any done condition completes it.
            overrideDone = overrideDone or (isComplete and not isFail)
        elseif isVisible and not isFail and text ~= "" then
            -- Kept once complete: the quest journal greys a finished condition, where the
            -- tracker drops it.
            conds[#conds + 1] = { text = zo_strformat("<<1>>", text), cur = cur, max = max,
                complete = isComplete }
        end
    end
    if override ~= "" then
        conds[1] = { text = zo_strformat("<<1>>", override), cur = 0, max = 0, complete = overrideDone }
    end
    if #conds == 0 then return end
    return {
        visibility = want,
        conds      = conds,
        -- An OR step: any one of these finishes it.
        choice     = stepType == QUEST_STEP_TYPE_OR and #conds > 1 and override == "",
    }
end

-- Shape of the returned row:
--   index, name, questType, instanceDisplayType, stepType, stepLine
--   steps: the main step, the optional lines, then the hints, each with its conds
--   (text, cur, max, complete)
function CW.ReadQuest(i)
    if not i then return nil end
    local name, _bgText, stepText, stepType, stepOverride, completed, _tracked,
          _, _, questType, instanceDisplayType = GetJournalQuestInfo(i)
    if not name or name == "" then return nil end

    local data = {
        index               = i,
        name                = zo_strformat("<<1>>", name),
        questType           = questType,
        instanceDisplayType = instanceDisplayType,
        recurs              = GetJournalQuestRepeatType(i) ~= QUEST_REPEAT_NOT_REPEATABLE,
        completed           = completed == true,
        stepType            = stepType,
        activeStepText      = stepText,
        stepOverrideText    = stepOverride,
        stepLine            = (stepOverride ~= nil and stepOverride ~= "") and stepOverride
                              or stepText,
        steps               = {},
    }
    -- The main step, then the optional lines, then the hints: the native tracker's own
    -- order, which is not step order.
    local steps = data.steps
    steps[1] = ReadStep(i, QUEST_MAIN_STEP_INDEX)
    local numSteps = GetJournalQuestNumSteps(i)
    for _, want in ipairs({ QUEST_STEP_VISIBILITY_OPTIONAL, QUEST_STEP_VISIBILITY_HINT }) do
        for s = QUEST_MAIN_STEP_INDEX + 1, numSteps do
            steps[#steps + 1] = ReadStep(i, s, want)
        end
    end
    return data
end

-- Whatever ESO's own tracker would be showing.
function CW.ReadAssistedQuest()
    return CW.ReadQuest(CW.AssistedQuestIndex())
end

function CW.RecordLastProgressedQuest(journalIndex)
    if not IsValidQuestIndex(journalIndex) then return false end
    local name = GetJournalQuestName(journalIndex)
    if name == "" then return false end
    CW.SavedVars.lastProgressedQuest = {
        id   = GetJournalQuestId(journalIndex),
        name = zo_strformat("<<1>>", name),
    }
    return true
end

-- Runs every redraw; don't ReadQuest here.
function CW.ResolveLastProgressedQuest()
    local saved = CW.SavedVars.lastProgressedQuest
    if not saved then return nil end
    for i in CW.JournalQuests() do
        local name = zo_strformat("<<1>>", GetJournalQuestName(i))
        if saved.id == GetJournalQuestId(i) or name == saved.name then
            return i, name
        end
    end
    return nil
end

function CW.RecordLastProgressedQuestFromArgs(...)
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if type(v) == "number" and CW.RecordLastProgressedQuest(v) then
            return true
        end
    end
    return false
end

-- Tracked Quests — the player's own short list
--
-- Save stable ids because journal indices shuffle. Bucket by character:
-- account-wide selections cannot distinguish another character's quests from turn-ins.

function CW.TrackedQuestStore()
    local sv = CW.SavedVars
    sv.trackedQuests = sv.trackedQuests or {}
    local key = GetCurrentCharacterId()
    sv.trackedQuests[key] = sv.trackedQuests[key] or {}
    return sv.trackedQuests[key]
end

-- Stable ids come back as numbers, saved-variable keys survive as strings, so every
-- lookup and store goes through this.
local function StableKey(journalIndex)
    local id = GetJournalQuestId(journalIndex)
    if id == 0 then return nil end
    return tostring(id)
end

function CW.IsQuestTracked(journalIndex)
    local key = StableKey(journalIndex)
    if not key then return false end
    return CW.TrackedQuestStore()[key] ~= nil
end

function CW.SetQuestTracked(journalIndex, wanted)
    local key = StableKey(journalIndex)
    if not key then return false end
    local store = CW.TrackedQuestStore()
    if wanted then
        store[key] = GetJournalQuestName(journalIndex)
    else
        store[key] = nil
    end
    return true
end

-- Keep the assisted quest in the list so assisting its only entry cannot empty it.
-- Sort by name to keep the order stable as assist changes.
function CW.ReadTrackedList()
    local store = CW.TrackedQuestStore()
    if next(store) == nil then return {} end

    local live = {}
    for i in CW.JournalQuests() do
        local key = StableKey(i)
        if key then live[key] = i end
    end

    local list = {}
    for key in pairs(store) do
        local index = live[key]
        if not index then
            store[key] = nil          -- pruned: gone from this character's journal
        else
            local q = CW.ReadQuest(index)
            if q then
                q.tracked = true
                list[#list + 1] = q
            end
        end
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

-- Undaunted daily pledges — UPU supplies the maintained daily rotation. Common Works
-- tracks turn-ins it observes so the HUD can show today's 0/1 -> 1/1 status.
local PLEDGE_GIVERS = { "Maj", "Glirion", "Urgarlag" }

local function GetUPU()
    local upu = UndauntedPledgesUtilities or _G.UPU
    if type(upu) ~= "table" then return nil end
    if not (upu.GetDaysSinceCycleStart and upu.BuildDailyData and upu.GetZoneName
        and upu.ManualCompletionCheck) then return nil end
    return upu
end

local function GetDailyPledgeData()
    local upu = GetUPU()
    if not upu then return nil end
    local majGlirionDay, urgarlagDay = upu.GetDaysSinceCycleStart()
    local data = upu.BuildDailyData(majGlirionDay, urgarlagDay)
    if not data then return nil end
    return upu, data, tostring(majGlirionDay or "") .. ":" .. tostring(urgarlagDay or "")
end

local function EnsurePledgeState(dayKey)
    local pledges = CW.SavedVars.pledges
    if pledges.dayKey ~= dayKey then
        pledges.dayKey = dayKey
        pledges.completedByCharacter = {}
    end

    local characterKey = GetCurrentCharacterId()
    local characterState = pledges.completedByCharacter[characterKey]
    if not characterState then
        characterState = {}
        pledges.completedByCharacter[characterKey] = characterState
    end
    return characterState
end

local function IsUndauntedPledgeQuest(index)
    return GetJournalQuestType(index) == QUEST_TYPE_UNDAUNTED_PLEDGE
end

local function IsDailyQuest(index)
    return GetJournalQuestRepeatType(index) == QUEST_REPEAT_DAILY
end

-- Strip the pledge's "<prefix>: "; UPU's QuestID differs from GetJournalQuestId
-- for the same quest, so the name is all there is to match on.
local function PledgeZoneName(name)
    local stripped = zo_strformat("<<1>>", name or ""):gsub("^.-:%s*", ""):upper()
    return stripped
end

-- The zone keeps an article the quest name drops -- zone "The Banished Cells II",
-- quest "Pledge: Banished Cells II" -- so match on the end of the name. UPU's
-- ComparePledgeQuestNames matches anywhere and so confuses Fungal Grotto I with II.
local function PledgeNamesMatch(a, b)
    return a == b or a:sub(-#b) == b or b:sub(-#a) == a
end

local function FindPledgeGiverForQuestName(upu, data, questName)
    local name = PledgeZoneName(questName)
    for _, giver in ipairs(PLEDGE_GIVERS) do
        local pledge = data[giver]
        if pledge and PledgeNamesMatch(PledgeZoneName(upu.GetZoneName(pledge.ZoneID)), name) then return giver end
    end
    return nil
end

function CW.RecordCompletedUndauntedPledge(questName)
    local upu, data, dayKey = GetDailyPledgeData()
    if not upu then return end
    local giver = FindPledgeGiverForQuestName(upu, data, questName)
    if not giver then return end
    local completedByGiver = EnsurePledgeState(dayKey)
    completedByGiver[giver] = true
end

local function NormalizeQuestDirectiveText(text)
    text = zo_strformat("<<1>>", text)
    text = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|t.-|t", "")
    text = zo_strtrim(text):gsub("%s+", " ")
    return text:lower()
end

local function IsReturnDirectiveText(text)
    text = NormalizeQuestDirectiveText(text)
    if text == "" then return false end

    -- Narrow on purpose: "Talk to" can be a pickup step, while "Return to" is the
    -- pre-proximity turn-in cue for these dailies.
    return text:find("return to", 1, true) ~= nil
end

local function GetQuestTurnInState(quest)
    local state = { normal = 0, complete = 0, conditionReturn = false }
    state.currentReturnDirective = IsReturnDirectiveText(quest.activeStepText)
        or IsReturnDirectiveText(quest.stepOverrideText)
        or IsReturnDirectiveText(quest.stepLine)

    for _, step in ipairs(quest.steps) do
        -- An optional line or a hint gates nothing: an unfinished one must not hold the
        -- quest back from reading as ready.
        if not step.visibility then
            for _, cond in ipairs(step.conds) do
                state.normal = state.normal + 1
                if cond.complete then
                    state.complete = state.complete + 1
                elseif IsReturnDirectiveText(cond.text) then
                    state.conditionReturn = true
                end
            end
        end
    end
    return state
end

local function QuestIsReadyForTurnIn(quest)
    if not quest then return false end
    if quest.completed then return true end
    if quest.stepType == QUEST_STEP_TYPE_END then return true end
    local state = GetQuestTurnInState(quest)
    if state.currentReturnDirective then return true end
    if state.conditionReturn then return true end
    if state.normal > 0 and state.complete == state.normal then return true end
    return false
end

function CW.ReadPledges()
    local upu, data, dayKey = GetDailyPledgeData()
    if not upu then return nil end
    local completedByGiver = EnsurePledgeState(dayKey)
    local model = { rows = {}, accepted = 0, ready = 0, completed = 0, turnedIn = 0, progress = 0, total = #PLEDGE_GIVERS }
    local byGiver = {}

    for _, giver in ipairs(PLEDGE_GIVERS) do
        local pledge = data[giver]
        if pledge then
            local row = {
                name      = upu.GetZoneName(pledge.ZoneID),
                completed = completedByGiver[giver] == true,
                accepted  = false,
                ready     = false,
            }
            byGiver[giver] = row
            model.rows[#model.rows + 1] = row
        end
    end

    for i in CW.JournalQuests() do
        if IsUndauntedPledgeQuest(i) then
            model.accepted = model.accepted + 1
            local giver = FindPledgeGiverForQuestName(upu, data, GetJournalQuestName(i))
            local row = giver and byGiver[giver]
            if row then
                row.accepted = true
                row.index = i
                row.ready = upu.ManualCompletionCheck(i)
            else
                -- Held from an earlier day: it still turns in, so it lists and counts.
                local q = CW.ReadQuest(i)
                local ready = QuestIsReadyForTurnIn(q) or upu.ManualCompletionCheck(i)
                local name = q and q.name or zo_strformat("<<1>>", GetJournalQuestName(i))
                model.rows[#model.rows + 1] = {
                    index       = i,
                    name        = name:gsub("^%s*[Pp][Ll][Ee][Dd][Gg][Ee]:%s*", ""),
                    accepted    = true,
                    ready       = ready,
                }
            end
        end
    end

    -- Done first, available last.
    local ordered = {}
    for _, row in ipairs(model.rows) do
        if row.completed then
            model.turnedIn = model.turnedIn + 1
        elseif row.ready then
            model.ready = model.ready + 1
        end
        if row.completed or row.ready then ordered[#ordered + 1] = row end
    end
    for _, row in ipairs(model.rows) do
        if not (row.completed or row.ready) then ordered[#ordered + 1] = row end
    end
    model.rows = ordered
    model.completed = model.turnedIn
    -- A pledge held from an earlier day still counts toward today's three.
    model.progress = zo_min(model.turnedIn + model.ready, model.total)

    model.hasCharacterActivity = model.accepted > 0 or model.progress > 0
    return model
end

-- The quest's own location string first; the zone-story id is the fallback, being often
-- a parent zone and 0 for plenty of quests. Empty means "no zone to show", not "unknown".
local function GetQuestZoneName(index)
    local zoneName = GetJournalQuestLocationInfo(index)
    if zoneName == "" then
        local zoneId = GetJournalQuestZoneStoryZoneId(index)
        if zoneId ~= 0 then zoneName = GetZoneNameById(zoneId) end
    end
    return zo_strformat("<<1>>", zoneName)
end

-- Infer the guild from its merit reward name (e.g. "Shadowfen Mages Guild Merits"),
-- matched to localized Guild skill line names; the quest has no guild field.
local guildNames
local function GuildDailyGuildName(index)
    if not guildNames then
        guildNames = {}
        for s = 1, GetNumSkillLines(SKILL_TYPE_GUILD) do
            guildNames[s] = GetSkillLineNameById(GetSkillLineId(SKILL_TYPE_GUILD, s))
        end
    end
    for r = 1, GetJournalQuestNumRewards(index) do
        local _, name = GetJournalQuestRewardInfo(index, r)
        for _, guild in ipairs(guildNames) do
            if guild ~= "" and name:find(guild, 1, true) then return guild end
        end
    end
end

-- GetJournalQuestLocationInfo names the pickup hall, not the target zone; use the title
-- ("Dark Anchors in Greenshade"). Prefer the longest zone name and cache per title.
local zoneNames, zoneByTitle = nil, {}
local function TitleZoneName(title)
    local cached = zoneByTitle[title]
    if cached ~= nil then return cached end
    if not zoneNames then
        -- Zone indexes address only part of the zone table, so walk ids up to the highest
        -- one an index reports. GetZoneNameByIndex alone misses instances like Sewer Tenement.
        local maxId = 0
        for index = 0, GetNumZones() do
            local id = GetZoneId(index)
            if id > maxId then maxId = id end
        end
        zoneNames = {}
        for id = 1, maxId do
            local name = zo_strformat("<<1>>", GetZoneNameById(id))
            if name ~= "" then zoneNames[#zoneNames + 1] = name end
        end
    end
    local lower, best = title:lower(), false
    for _, zone in ipairs(zoneNames) do
        if zone ~= "" and (not best or #zone > #best) and lower:find(zone:lower(), 1, true) then
            best = zone
        end
    end
    zoneByTitle[title] = best
    return best
end

-- Label: "Greenshade: Close Dark Anchors"; ready quests show the turn-in guild instead.
-- `underline` selects the label portion to rule off.
local function GuildDailyLabel(index, quest)
    -- End steps and "Return to" directives also mean ready. Replace the objective
    -- with the turn-in guild; the row already says "Ready for turn-in".
    if quest.ready then
        local guild = GuildDailyGuildName(index) or quest.name
        return guild, guild
    end
    local label = TitleZoneName(quest.name) or quest.name
    return label, label
end

-- Accepted-only: a full "available today" list would need maintained quest-id data,
-- so this reports the active journal.
local function IsGuildDailyQuest(index)
    if not IsDailyQuest(index) then return false end
    if IsUndauntedPledgeQuest(index) then return false end
    return GetJournalQuestType(index) == QUEST_TYPE_GUILD
end

-- Shared repeatable scan: filter, normalize, check turn-in, sort ready-first.
-- `decorate` adds section fields; prefer the display label over the quest's flavor name.
local function ReadRepeatables(isMine, decorate)
    local model = { rows = {}, count = 0, ready = 0, progress = 0 }
    for i in CW.JournalQuests() do
        if isMine(i) then
            local q = CW.ReadQuest(i)
            if q then
                q.ready = QuestIsReadyForTurnIn(q)
                for _, step in ipairs(q.steps) do
                    for _, cond in ipairs(step.conds) do
                        if not (cond.complete or q.objective) then q.objective = cond end
                    end
                end
                if decorate then decorate(q, i) end
                model.rows[#model.rows + 1] = q
                if q.ready then
                    model.ready = model.ready + 1
                    model.progress = model.progress + 1
                end
            end
        end
    end
    table.sort(model.rows, function(a, b)
        if a.ready ~= b.ready then return a.ready end
        if not a.ready and a.label and a.label == b.label then
            return (a.objective and a.objective.text or "") < (b.objective and b.objective.text or "")
        end
        return (a.label or a.name) < (b.label or b.name)
    end)
    model.count = #model.rows
    return model
end

function CW.ReadGuildDailies()
    return ReadRepeatables(IsGuildDailyQuest, function(q, i)
        q.label, q.labelUnderline = GuildDailyLabel(i, q)
    end)
end

-- Show even with no accepted quest as a reminder to pick up the BG daily.
local function IsBattlegroundQuest(index)
    return GetJournalQuestType(index) == QUEST_TYPE_BATTLEGROUND
end

-- No day cache: an empty BG journal is meaningful, unlike guild turn-in totals.
function CW.ReadBattlegroundDailies()
    return ReadRepeatables(IsBattlegroundQuest)
end

-- Measured: captures report QUEST_REPEAT_REPEATABLE, kills and IC dailies QUEST_REPEAT_DAILY,
-- and one-time IC quests are QUEST_TYPE_AVA too, so the repeat check excludes those.
local AVA_QUEST_TYPES = {
    [QUEST_TYPE_AVA] = true, [QUEST_TYPE_AVA_GROUP] = true, [QUEST_TYPE_AVA_GRAND] = true,
}

local function IsAvaRepeatableQuest(index)
    return AVA_QUEST_TYPES[GetJournalQuestType(index)]
        and GetJournalQuestRepeatType(index) ~= QUEST_REPEAT_NOT_REPEATABLE
end

-- Only the current area's: a quest's location zone index against the Cyrodiil or IC map's.
-- Class kill quests report Cyrodiil even when taken in IC. No label: the title repeats
-- the objective ("Capture Kingscrest Keep"), so rows show the objective alone.
function CW.ReadAvaDailies()
    local mapIndex = CW.IsImperialCity() and GetImperialCityMapIndex() or GetCyrodiilMapIndex()
    local zoneIndex = mapIndex and select(4, GetMapInfoByIndex(mapIndex))
    return ReadRepeatables(function(i)
        return IsAvaRepeatableQuest(i) and select(3, GetJournalQuestLocationInfo(i)) == zoneIndex
    end)
end

-- World-boss / delve / geyser dailies by exclusion: the closed set of special
-- quest types belongs to dedicated sections, like DungeonFinder's EXCLUDED_ZONES.
local ZONE_DAILY_EXCLUDED_TYPES = {
    [QUEST_TYPE_GUILD] = true, [QUEST_TYPE_UNDAUNTED_PLEDGE] = true,
    [QUEST_TYPE_BATTLEGROUND] = true, [QUEST_TYPE_CRAFTING] = true,
    [QUEST_TYPE_AVA] = true, [QUEST_TYPE_AVA_GRAND] = true, [QUEST_TYPE_AVA_GROUP] = true,
}

local function IsZoneDailyQuest(index)
    if not IsDailyQuest(index) then return false end
    return not ZONE_DAILY_EXCLUDED_TYPES[GetJournalQuestType(index)]
end

-- No day cache: turned-in zone dailies leave the journal.
-- Zone buckets inherit the shared scan's ready-first order.
function CW.ReadZoneDailies()
    local model = ReadRepeatables(IsZoneDailyQuest, function(q, i)
        q.zoneName = GetQuestZoneName(i)
        q.label, q.labelUnderline = q.name, q.name
    end)

    model.groups = {}
    local byZone = {}
    for _, row in ipairs(model.rows) do
        local group = byZone[row.zoneName]
        if not group then
            group = { zone = row.zoneName, rows = {}, progress = 0 }
            byZone[row.zoneName] = group
            model.groups[#model.groups + 1] = group
        end
        group.rows[#group.rows + 1] = row
        if row.ready then group.progress = group.progress + 1 end
    end
    table.sort(model.groups, function(a, b)
        -- Put unnamed rows last so they cannot look like part of the next named zone.
        if (a.zone == "") ~= (b.zone == "") then return b.zone == "" end
        return a.zone < b.zone
    end)
    -- When every daily is ready, show turn-in status in the zone header instead of rows.
    for _, group in ipairs(model.groups) do
        group.allReady = group.progress >= #group.rows
    end
    return model
end

-- Quest icons
--
-- ZO_GetZoneDisplayTypeIcon (sharedloadingscreen.lua) supplies instance icons;
-- this table covers the remaining quest types with matching base-game art.
local QUEST_TYPE_ICON = {
    [QUEST_TYPE_CLASS]            = "EsoUI/Art/CharacterCreate/CharacterCreate_classIcon_up.dds",
    [QUEST_TYPE_COMPANION]        = "EsoUI/Art/Journal/journal_Quest_Companion.dds",
    -- Favor quests are the guild repeatables; the journal's own repeat glyph.
    [QUEST_TYPE_FAVOR]            = "EsoUI/Art/Journal/journal_Quest_Repeat.dds",
    [QUEST_TYPE_GUILD]            = "EsoUI/Art/Icons/mapKey/mapKey_u26_priest_of_arkay_complete.dds",
    [QUEST_TYPE_CRAFTING]         = "EsoUI/Art/Inventory/inventory_tabIcon_crafting_up.dds",
    [QUEST_TYPE_SCRIBING]         = "EsoUI/Art/crafting/gamepad/gp_crafting_menuicon_scribing.dds",
    [QUEST_TYPE_UNDAUNTED_PLEDGE] = "EsoUI/Art/Icons/mapKey/mapKey_undaunted.dds",
    [QUEST_TYPE_BATTLEGROUND]     = "EsoUI/Art/Icons/mapKey/mapKey_bg_banner.dds",
    [QUEST_TYPE_TRIBUTE]          = "EsoUI/Art/Icons/servicemappins/servicepin_talesoftribute.dds",
    [QUEST_TYPE_HOLIDAY_EVENT]    = "EsoUI/Art/Icons/mapKey/mapKey_events.dds",
    [QUEST_TYPE_PROLOGUE]         = "EsoUI/Art/MainMenu/menuBar_journal_up.dds",
    -- Tamriel Tales are standalone stories filed under Other; use the Lore Library tab.
    [QUEST_TYPE_TAMRIEL_TALE]     = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_up.dds",
    -- All three Alliance War types read the same on a row: it is a keep fight.
    [QUEST_TYPE_AVA]              = "EsoUI/Art/Icons/poi/poi_keep_complete.dds",
    [QUEST_TYPE_AVA_GROUP]        = "EsoUI/Art/Icons/poi/poi_keep_complete.dds",
    [QUEST_TYPE_AVA_GRAND]        = "EsoUI/Art/Icons/poi/poi_keep_complete.dds",
}

local DEFAULT_QUEST_ICON = "EsoUI/Art/Compass/quest_icon.dds"
-- The compass pin the game gives repeatables; a type icon still says more.
local REPEATABLE_QUEST_ICON = "EsoUI/Art/Compass/repeatableQuest_icon.dds"

function CW.GetQuestIcon(quest)
    return QUEST_TYPE_ICON[quest.questType]
        or quest.recurs and REPEATABLE_QUEST_ICON
        or ZO_GetZoneDisplayTypeIcon(quest.instanceDisplayType)
        or DEFAULT_QUEST_ICON
end

-- Tamriel Tomes, which ESO calls timed activities.
CW.tomeProgressCache = CW.tomeProgressCache or {}

-- Second return is the quantity; the first is the currency type, always Tome Points here.
local function TomeReward(i)
    local _, qty = GetTimedActivityCurrencyRewardInfo(i)
    return qty
end

local function TomeActivityKey(activityId, activityType, text, max, reward)
    if activityId ~= 0 then return "id:" .. activityId end
    return table.concat({ activityType, max, reward, text }, "\031")
end

function CW.ReadTomes()
    local list = {}
    for i = 1, GetNumTimedActivities() do
        local desc = GetTimedActivityDescription(i)
        local name = GetTimedActivityName(i)
        if name ~= "" or desc ~= "" then
            local cur = GetTimedActivityProgress(i)
            local max = GetTimedActivityMaxProgress(i)
            local claimed = GetTimedActivityNumTimesClaimed(i)
            local claimable = GetTimedActivityTotalNumTimesClaimable(i)
            local reward = TomeReward(i)
            local text = zo_strformat("<<1>>", name)
            local description = zo_strformat("<<1>>", desc)
            local activityId = GetTimedActivityId(i)
            local activityType = GetTimedActivityType(i)
            local key = TomeActivityKey(activityId, activityType, text, max, reward)
            local cached = CW.tomeProgressCache[key]
            if cur == 0 and cached and cached.cur and cached.cur > 0 then
                cur = cached.cur
            elseif cur > 0 then
                CW.tomeProgressCache[key] = { cur = cur, max = max }
            end
            local hasClaims = claimable > 0
            local complete
            if hasClaims then
                complete = claimed >= claimable
            else
                complete = max > 0 and cur >= max
            end
            list[#list + 1] = {
                index    = i,
                id       = activityId,
                key      = key,
                name     = text,
                desc     = description,
                text     = text,
                cur      = cur,
                max      = max,
                claimed  = claimed,
                claimable= claimable,
                hasClaims= hasClaims,
                reward   = reward,   -- in Tome Points
                complete = complete,
                type     = activityType,
            }
        end
    end
    return list
end

-- ClaimTimedActivityReward is unprotected (ESOUIDocumentation.txt:20107): no keypress.
-- ZOS notes it cannot fail while rewards are only uncapped Tome Points
-- (timedactivities_keyboard.lua:68). No loot window, bag space or dialog needed.
-- Claim individually to record each receipt.
CW.tomeClaims = CW.tomeClaims or {}
local TOME_CLAIM_MS = 5 * 60 * 1000
-- Throttle successful claims to stop event recursion, but leave empty sweeps unthrottled:
-- EVENT_PLAYER_ACTIVATED precedes the populated EVENT_TIMED_ACTIVITIES_UPDATED by 1-2s.
local TOME_CLAIM_SETTLE_MS = 2000
local lastTomeClaimMs = nil

-- ZO_TimedActivityData:CanClaim: full progress, not already claimed to its limit. A
-- zero max is not "trivially finished", it is an activity the client cannot describe.
local function TomeCanClaim(i)
    local max = GetTimedActivityMaxProgress(i)
    if max <= 0 then return false end
    if (GetTimedActivityProgress(i)) < max then return false end
    local total = GetTimedActivityTotalNumTimesClaimable(i)
    if total > 0 then
        local taken = GetTimedActivityNumTimesClaimed(i)
        if taken >= total then return false end
    end
    return true
end

-- Newest first; prune on read because only the next layout needs current receipts.
function CW.RecentTomeClaims(seasonal)
    local now = GetFrameTimeMilliseconds()
    for i = #CW.tomeClaims, 1, -1 do
        if now - CW.tomeClaims[i].t > TOME_CLAIM_MS then table.remove(CW.tomeClaims, i) end
    end
    local out = {}
    for i = #CW.tomeClaims, 1, -1 do
        if CW.tomeClaims[i].seasonal == (seasonal == true) then out[#out + 1] = CW.tomeClaims[i] end
    end
    return out
end

function CW.AutoClaimTomePoints()
    if not CW.SavedVars.autoClaimTomePoints then return end
    if not IsTimedActivitySystemAvailable() then return end

    local now = GetFrameTimeMilliseconds()
    if lastTomeClaimMs and (now - lastTomeClaimMs) < TOME_CLAIM_SETTLE_MS then return end

    local claimed = false
    for i = 1, GetNumTimedActivities() do
        if TomeCanClaim(i) then
            -- Read before claiming banks the reward and resets repeatable progress.
            local name = GetTimedActivityName(i)
            if name == "" then
                name = GetTimedActivityDescription(i)
            end
            local reward = TomeReward(i)
            local seasonal = GetTimedActivityType(i) == TIMED_ACTIVITY_TYPE_SEASONAL
            ClaimTimedActivityReward(i)
            CW.tomeClaims[#CW.tomeClaims + 1] =
                { t = now, name = zo_strformat("<<1>>", name), reward = reward, seasonal = seasonal }
            claimed = true
        end
    end

    if not claimed then return end
    lastTomeClaimMs = now
    CW.RedrawSoon()
    CW.QueueTomeResync()
    -- Nothing else is guaranteed to redraw the panel in the quiet minutes after a claim.
    zo_callLater(function() CW.RedrawSoon() end, TOME_CLAIM_MS + 100)
end

-- Mirror HUD_TRACKER_MANAGER's IsZoneStoryAssisted swap for the assist cycle (default T);
-- Core's three zone-story events refresh it, and the native tracker stays hidden.
-- Follow ZoneStoryTracker:Update's call order; zone id 0 means nothing tracked.
function CW.ReadZoneStory()
    if not IsZoneStoryAssisted() then return nil end
    local zoneId, completionType, activityId = GetTrackedZoneStoryActivityInfo()
    if zoneId == 0 then return nil end

    local desc = GetZoneStoryShortDescriptionByActivityId(zoneId, completionType, activityId)
    return {
        name = zo_strformat("<<1>>", ZONE_STORIES_MANAGER:GetZoneData(zoneId).name),
        -- Not every activity carries one; the native tracker just shows a blank line.
        desc = desc ~= "" and zo_strformat("<<1>>", desc) or nil,
    }
end

-- Replace ZO_ActivityTracker (see ApplyActivityTrackerState), adding campaign queues.
-- Follow ingame/lfg/activitytracker.lua; both GetActivityRequestIds(1) returns matter
-- for random/set queues. Walk campaign entries as ZO_CampaignQueueProvider does.

-- Reproduce activitytracker.lua's inaccessible local HEADER_MAPPING for queues
-- without a single activity name, including random queues.
local ACTIVITY_CATEGORY = {
    [LFG_ACTIVITY_DUNGEON] = GetString(SI_ACTIVITY_FINDER_CATEGORY_DUNGEON_FINDER),
    [LFG_ACTIVITY_MASTER_DUNGEON] = GetString(SI_ACTIVITY_FINDER_CATEGORY_DUNGEON_FINDER),
    [LFG_ACTIVITY_BATTLE_GROUND_CHAMPION] = GetString(SI_ACTIVITY_FINDER_CATEGORY_BATTLEGROUNDS),
    [LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION] = GetString(SI_ACTIVITY_FINDER_CATEGORY_BATTLEGROUNDS),
    [LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL] = GetString(SI_ACTIVITY_FINDER_CATEGORY_BATTLEGROUNDS),
    [LFG_ACTIVITY_TRIBUTE_COMPETITIVE] = GetString(SI_ACTIVITY_FINDER_CATEGORY_TRIBUTE),
    [LFG_ACTIVITY_TRIBUTE_CASUAL] = GetString(SI_ACTIVITY_FINDER_CATEGORY_TRIBUTE),
}

-- Which glyph leads the block. The finder queues these three categories and nothing else;
-- UI.lua owns the art.
local ACTIVITY_KIND = {
    [LFG_ACTIVITY_DUNGEON] = "dungeon",
    [LFG_ACTIVITY_MASTER_DUNGEON] = "dungeon",
    [LFG_ACTIVITY_BATTLE_GROUND_CHAMPION] = "bg",
    [LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION] = "bg",
    [LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL] = "bg",
    [LFG_ACTIVITY_TRIBUTE_COMPETITIVE] = "tribute",
    [LFG_ACTIVITY_TRIBUTE_CASUAL] = "tribute",
}

local function ActivityFinderStatusText()
    return GetString("SI_ACTIVITYFINDERSTATUS", GetActivityFinderStatus())
end

-- During ready checks, seeking is false and request ids are 0 before a group forms.
-- Cache the activity name to keep the header visible.
local lastQueueHeader = nil

-- The Activity Finder block: { kind, title, count, status, queuedAt, urgent }, or nil.
local function ReadActivityQueue()
    local activityId, activitySetId, seeking = 0, 0, false
    if IsCurrentlySearchingForGroup() then
        seeking = true
        activityId, activitySetId = GetActivityRequestIds(1)
    elseif IsInLFGGroup() then
        activityId = GetCurrentLFGActivityId()
    end

    -- Stop pulsing once the player accepts, even while others are deciding.
    local urgent = HasLFGReadyCheckNotification() and not HasAcceptedLFGReadyCheck()

    if activityId == 0 and activitySetId == 0 then
        if CW.InLfgReadyCheck() then
            local statusText = ActivityFinderStatusText()
            local readyType = GetLFGReadyCheckActivityType()
            return {
                kind = ACTIVITY_KIND[readyType] or "dungeon",
                -- Without a cached queue name (e.g. /reloadui mid-queue), use the category.
                title = lastQueueHeader or ACTIVITY_CATEGORY[readyType] or statusText,
                status = statusText,
                urgent = urgent,
            }
        end
        -- Neither queued nor in a ready check: drop the cache, or a stale name leaks
        -- into the next queue.
        lastQueueHeader = nil
        return nil
    end

    -- The representative activityId is only one possible destination;
    -- do not present it as the matchmaker's chosen dungeon.
    local representativeActivityId = activityId
    if representativeActivityId == 0 and activitySetId ~= 0 then
        representativeActivityId = GetActivitySetActivityIdByIndex(activitySetId, 1)
    end

    local activityType = representativeActivityId ~= 0
        and GetActivityType(representativeActivityId)
    local header
    if seeking and activitySetId ~= 0 then
        header = GetActivitySetInfo(activitySetId)
    elseif seeking and GetNumActivityRequests() > 1 then
        header = activityType ~= nil and ACTIVITY_CATEGORY[activityType] or nil
    elseif activityId ~= 0 then
        header = GetActivityName(activityId)
    end

    header = (header and header ~= "") and zo_strformat("<<1>>", header)
    if not header and activityType ~= nil then header = ACTIVITY_CATEGORY[activityType] end

    local statusText = ActivityFinderStatusText()
    lastQueueHeader = header

    -- Only meaningful while actively seeking.
    local queuedAt
    if seeking then
        local s = GetLFGSearchTimes()
        if s > 0 then queuedAt = s end
    end

    return {
        kind = activityType and ACTIVITY_KIND[activityType] or "dungeon",
        title = header or statusText,
        -- How many specific picks one search covers. A random set expands into one request
        -- per destination, and its name already says what was queued.
        count = seeking and activitySetId == 0 and GetNumActivityRequests() or 0,
        status = statusText,
        queuedAt = queuedAt,
        urgent = urgent,
    }
end

-- WAITING has no localized string; queue position alone describes it.
local CAMPAIGN_STATE_STRING = {
    [CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_JOIN]   = SI_CAMPAIGN_BROWSER_QUEUE_PENDING_JOIN,
    [CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_LEAVE]  = SI_CAMPAIGN_BROWSER_QUEUE_PENDING_LEAVE,
    [CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_ACCEPT] = SI_CAMPAIGN_BROWSER_QUEUE_PENDING_ACCEPT,
    [CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING]     = SI_CAMPAIGN_BROWSER_QUEUE_CAMPAIGN,
}

-- One block per campaign queued for, appended to `out`. Solo and group are separate
-- entries, which is why the campaign id alone never identifies one.
local function ReadCampaignQueues(out)
    for i = 1, GetNumCampaignQueueEntries() do
        local campaignId, asGroup = GetCampaignQueueEntry(i)
        local state = GetCampaignQueueState(campaignId, asGroup)
        local confirming = state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING
        local stateString = CAMPAIGN_STATE_STRING[state]
        local name = zo_strformat("<<1>>", GetCampaignName(campaignId))
        local now = GetFrameTimeMilliseconds()
        out[#out + 1] = {
            kind = "campaign",
            title = asGroup
                and string.format("%s (%s)", name, GetString(SI_CAMPAIGN_BROWSER_QUEUE_GROUP))
                or name,
            -- The place in line, which the Activity Finder never reports.
            status = stateString and GetString(stateString)
                or zo_strformat(GetString(SI_CAMPAIGN_BROWSER_QUEUED),
                    GetCampaignQueuePosition(campaignId, asGroup)),
            queuedAt = not confirming
                and now - GetSecondsInCampaignQueue(campaignId, asGroup) * 1000 or nil,
            -- The countdown people miss and get dropped for.
            expiresAt = confirming
                and now + GetCampaignQueueRemainingConfirmationSeconds(campaignId, asGroup) * 1000
                or nil,
            urgent = confirming,
        }
    end
end

-- Every queue at once, in draw order, or nil when there is none. Both kinds can be live
-- together, so they stack rather than compete for one block.
function CW.ReadQueue()
    local queues = {}
    local activity = ReadActivityQueue()
    if activity then queues[1] = activity end
    ReadCampaignQueues(queues)
    return queues[1] and queues or nil
end

-- Read from the housing state's cache, not the raw API: the panel redraws on its
-- HouseSettingsChanged, which fires only once that cache is current.
function CW.ReadHouse()
    local house = HOUSING_EDITOR_STATE
    if not house:IsHouseInstance() then return nil end
    return {
        name = zo_strformat("<<C:1>>", house:GetHouseName()),
        population = zo_strformat(SI_HOUSING_INFORMATION_TRACKER_POPULATION,
            house:GetPopulation(), house:GetMaxPopulation()),
        owner = not house:IsLocalPlayerHouseOwner()
            and zo_strformat(SI_HOUSING_INFORMATION_TRACKER_OWNER_NAME,
                ZO_FormatUserFacingDisplayName(house:GetOwnerName())) or nil,
    }
end

-- The whole window, not just the unanswered part: the notification clears the moment
-- the player accepts, but the block stays up while the rest answer.
-- ZO_ReadyCheckTracker tests the same status.
function CW.InLfgReadyCheck()
    return HasLFGReadyCheckNotification()
        or GetActivityFinderStatus() == ACTIVITY_FINDER_STATUS_READY_CHECK
end

-- Contested keeps in Cyrodiil and Imperial City. Battlegrounds are not reproduced here:
-- ESO's own BG HUD is docked under the panel instead (see CW.PlaceBattlegroundHud).

function CW.IsBattleground()
    return GetCurrentBattlegroundId() ~= 0
end

-- IsInAvAZone covers Cyrodiil, IC and its sewers, excluding Battlegrounds.
-- Check IC separately for the section title.
local function IsAvaZone()
    return IsInAvAZone() and not CW.IsBattleground()
end

function CW.IsImperialCity()
    return IsAvaZone() and IsInImperialCity()
end

function CW.IsCyrodiil()
    return IsAvaZone() and IsInCyrodiil()
end

function CW.IsPvpZone()
    return CW.IsBattleground() or IsAvaZone()
end

-- Hide quests only in group/PvP instances. Pair IsUnitInDungeon with difficulty:
-- delves, public dungeons, solo instances and housing also report dungeon flags.
function CW.InQuestTrackerInstance()
    if CW.IsPvpZone() then return true end

    local displayType = CW.currentZoneDisplayType
    if displayType == ZONE_DISPLAY_TYPE_BATTLEGROUND or displayType == ZONE_DISPLAY_TYPE_DUNGEON
        or displayType == ZONE_DISPLAY_TYPE_RAID or displayType == ZONE_DISPLAY_TYPE_ENDLESS_DUNGEON then
        return true
    end

    -- EVENT_PREPARE_FOR_JUMP misses group-finder ports, summons and /reloadui inside.
    -- Also query the game; DUNGEON_DIFFICULTY_NONE excludes delves/public dungeons.
    if IsUnitInDungeon("player") and GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_NONE then
        return true
    end
    if IsRaidInProgress() then return true end

    return false
end

function CW.QuestContentHiddenInInstance()
    return CW.SavedVars.hideQuestTrackerInInstances and CW.InQuestTrackerInstance()
end

function CW.ShowActiveQuestInHiddenTracker()
    return CW.QuestContentHiddenInInstance() and CW.SavedVars.showActiveQuestInInstances
end

-- Alliance War layout ignores instance-hiding: quests, then contested keeps
-- in place of repeatable categories.
function CW.PvpFocusMode()
    return CW.IsCyrodiil() or CW.IsImperialCity()
end

-- Hidden in an activity instance when the setting asks, and always in Cyrodiil / IC.
function CW.ExtraQuestGroupsHidden()
    return CW.PvpFocusMode() or CW.QuestContentHiddenInInstance()
end

-- Prioritize keeps, then resources, then towns by campaign importance.
local KEEP_TIER = { [KEEPTYPE_RESOURCE] = 2, [KEEPTYPE_TOWN] = 3 }
local function KeepTier(keepType) return KEEP_TIER[keepType] or 1 end

-- Any keep type can hold a scroll (observed: Ghartok in Black Boot, Chim in Rayles).
-- GetKeepThatHasCapturedThisArtifactScrollObjective returns the holder, including the
-- home temple; keeptooltip.lua's GetKeepArtifactObjectiveId only covers temples.
local function ScrollsByKeep()
    local held = {}
    for i = 1, GetNumObjectives() do
        local keepId, objectiveId, ctx = GetObjectiveIdsForIndex(i)
        local kind = GetObjectiveType(keepId, objectiveId, ctx)
        if IsLocalBattlegroundContext(ctx)
            and (kind == OBJECTIVE_ARTIFACT_OFFENSIVE or kind == OBJECTIVE_ARTIFACT_DEFENSIVE) then
            local holder =
                GetKeepThatHasCapturedThisArtifactScrollObjective(keepId, objectiveId, ctx)
            if holder ~= 0 then held[holder] = (held[holder] or 0) + 1 end
        end
    end
    return held
end

-- { context = "cyrodiil"|"ic", myAlliance, rows = {...} }, or nil anywhere else. A row
-- carries only what the panel draws; the alliance glyph and its tint are resolved UI-side.
function CW.ReadAvaObjectives()
    local inIC = CW.IsImperialCity()
    if not (inIC or CW.IsCyrodiil()) then return nil end

    -- No API counts players at a keep; show siege per alliance, ownership, travel cutoff
    -- and scroll presence as signs of activity and importance.
    local myAlliance = GetUnitAlliance("player")
    local scrolls = ScrollsByKeep()
    local rows, listed = {}, {}
    -- Local context only, as cmaphandlers.lua does. Measured: a keep can still be listed
    -- twice (Fort Glademist, id 5, both local), so take each id once.
    for i = 1, GetNumKeeps() do
        local keepId, keepCtx = GetKeepKeysByIndex(i)
        if IsLocalBattlegroundContext(keepCtx) and not listed[keepId]
            and GetKeepUnderAttack(keepId, keepCtx) then
            listed[keepId] = true
            -- Whoever has siege on the field, defender included.
            local sieges, total = {}, 0
            for alliance = 1, NUM_ALLIANCES do
                local n = GetNumSieges(keepId, keepCtx, alliance)
                if n > 0 then
                    sieges[#sieges + 1] = { alliance = alliance, n = n }
                    total = total + n
                end
            end
            -- Yours leads, the rest follow by weight.
            table.sort(sieges, function(l, r)
                if (l.alliance == myAlliance) ~= (r.alliance == myAlliance) then
                    return l.alliance == myAlliance
                end
                return l.n > r.n
            end)

            local name  = GetKeepName(keepId)
            local owner = GetKeepAlliance(keepId, keepCtx)
            local keepType = GetKeepType(keepId)

            -- Count any alliance's scroll; an empty temple means its own scroll is away.
            local isTemple = keepType == KEEPTYPE_ARTIFACT_KEEP
            local scrollHere = (scrolls[keepId] or 0) > 0

            rows[#rows + 1] = {
                keepId      = keepId,
                -- A blank name means the client has not caught up; the id at least keeps
                -- the row apart from its neighbours.
                name        = name ~= "" and zo_strformat("<<1>>", name) or ("Keep " .. keepId),
                owner       = owner,
                owned       = owner == myAlliance,
                keepType    = keepType,
                tier        = KeepTier(keepType),
                -- RESOURCETYPE_NONE on anything that is not a farm, mine or lumbermill.
                resourceType = GetKeepResourceType(keepId),
                siegeMine   = sieges,
                weight      = total,
                isTemple    = isTemple,
                scrollHere  = scrollHere,
                scrollGone  = isTemple and not scrollHere,
                noTravel    = not GetKeepHasResourcesForTravel(keepId, keepCtx),
            }
        end
    end

    -- Urgency: objective tier, our holdings under attack, then scrolls for campaign score.
    -- Siege weight breaks remaining ties.
    table.sort(rows, function(l, r)
        if l.tier ~= r.tier then return l.tier < r.tier end
        if l.owned ~= r.owned then return l.owned end
        if l.scrollHere ~= r.scrollHere then return l.scrollHere end
        if l.weight ~= r.weight then return l.weight > r.weight end
        return l.name < r.name
    end)

    return { context = inIC and "ic" or "cyrodiil", myAlliance = myAlliance, rows = rows }
end

-- Siege has no event. The 20s bucket keeps ages and Recent-action expiry moving.
local pvpFingerprint

function CW.PvpStateChanged()
    if CW.ShouldHideTracker() then return false end
    local parts = { CW.IsImperialCity() and "ic" or "cyrodiil",
                    zo_floor(GetFrameTimeMilliseconds() / 20000) }
    for i = 1, GetNumKeeps() do
        local keepId, keepCtx = GetKeepKeysByIndex(i)
        if IsLocalBattlegroundContext(keepCtx) and GetKeepUnderAttack(keepId, keepCtx) then
            parts[#parts + 1] = keepId
            for alliance = 1, NUM_ALLIANCES do
                parts[#parts + 1] = GetNumSieges(keepId, keepCtx, alliance)
            end
        end
    end

    local current = table.concat(parts, ",")
    if current == pvpFingerprint then return false end
    pvpFingerprint = current
    return true
end

-- Crossed-swords map pins: kill locations expose only pin type and normalized position,
-- with no id, name or player count. Pin type supplies alliances and small/medium/large tier.
-- APIs: GetNumKillLocations, GetKillLocationPinInfo, GetKeepPinInfo,
-- GetMapPlayerPosition, GetCurrentMapId.
local battlePins
local function BattlePins()
    if battlePins then return battlePins end
    battlePins = {}
    local sets = {
        { "TRI_BATTLE",              "EsoUI/Art/MapPins/AvA_3Way.dds" },
        { "ALDMERI_VS_EBONHEART",    "EsoUI/Art/MapPins/AvA_AldmeriVEbonheart.dds" },
        { "ALDMERI_VS_DAGGERFALL",   "EsoUI/Art/MapPins/AvA_AldmeriVDaggerfall.dds" },
        { "EBONHEART_VS_DAGGERFALL", "EsoUI/Art/MapPins/AvA_EbonheartVDaggerfall.dds" },
    }
    for _, set in ipairs(sets) do
        for tier, suffix in ipairs({ "SMALL", "MEDIUM", "LARGE" }) do
            local pin = _G["MAP_PIN_TYPE_" .. set[1] .. "_" .. suffix]
            if pin then battlePins[pin] = { icon = set[2], tier = tier, factions = set[1] } end
        end
    end
    return battlePins
end

-- Keyed by map id: each AvA map normalizes its own coordinate space, so a position
-- measured on one is meaningless on the other.
local landmarks, landmarksMapId
-- Answers keyed by grid cell, below; both die with the map they were measured on.
local nearestByCell = {}
local function Landmarks()
    local mapId = GetCurrentMapId()
    if landmarks and landmarksMapId == mapId then return landmarks end
    landmarks, landmarksMapId = {}, mapId
    ZO_ClearTable(nearestByCell)
    for i = 1, GetNumKeeps() do
        local keepId, keepCtx = GetKeepKeysByIndex(i)
        local pin, x, y = GetKeepPinInfo(keepId, keepCtx)
        local name = GetKeepName(keepId)
        if IsLocalBattlegroundContext(keepCtx) and (x > 0 or y > 0) and name ~= "" then
            landmarks[#landmarks + 1] = {
                name = zo_strformat("<<1>>", name), x = x, y = y,
                resource = GetKeepType(keepId) == KEEPTYPE_RESOURCE,
            }
        end
    end
    return landmarks
end

-- Compare squared distances, favoring keeps over resources as landmarks.
-- Cache on a ~50m grid to avoid scanning every objective for every kill pin each refresh.
local RESOURCE_PENALTY = 1.8
local function NearestLandmark(x, y)
    local list = Landmarks()
    -- Pin positions are normalized, so cell numbers cannot collide.
    local cell = math.floor(x * 1000) * 1001 + math.floor(y * 1000)
    local hit = nearestByCell[cell]
    if hit ~= nil then return hit or nil end

    local best, bestScore
    for _, l in ipairs(list) do
        local dx, dy = l.x - x, l.y - y
        local score = (dx * dx + dy * dy) * (l.resource and RESOURCE_PENALTY or 1)
        if not bestScore or score < bestScore then best, bestScore = l, score end
    end
    local name = best and best.name or false
    nearestByCell[cell] = name
    return name or nil
end

-- nil means no reliable reading: outside AvA, or the world map showing elsewhere.
-- An empty list means no fights; callers must not retire live battles on nil.
function CW.ReadBattles()
    if not (CW.IsCyrodiil() or CW.IsImperialCity()) then return nil end
    local _, _, _, shownOnThisMap = GetMapPlayerPosition("player")
    if not shownOnThisMap then return nil end

    local pins, byKey, rows = BattlePins(), {}, {}
    for i = 1, GetNumKillLocations() do
        local pinType, x, y = GetKillLocationPinInfo(i)
        local p = pins[pinType]
        if p then
            local near = NearestLandmark(x, y)
            -- Indices shuffle and no id exists; key by alliances and location so a drifting
            -- or growing fight keeps its place and clock.
            local key = p.factions .. "|" .. (near or string.format("%.2f,%.2f", x, y))
            local row = byKey[key]
            if row then
                if p.tier > row.tier then row.tier = p.tier end
            else
                row = { kind = "battle", key = key, icon = p.icon, tier = p.tier, near = near }
                byKey[key], rows[#rows + 1] = row, row
            end
        end
    end
    -- Biggest first, then by landmark, so the order does not jitter between passes.
    table.sort(rows, function(l, r)
        if l.tier ~= r.tier then return l.tier > r.tier end
        return (l.near or "") < (r.near or "")
    end)
    return rows
end

function CW.Redraw()
    -- Unconditional: replacing the native trackers is the whole purpose.
    CW.SuppressNativeTracker()
    CW.SuppressNativeExtras()
    CW.UI.Redraw()
end

-- A burst of events costs one refresh.
local redrawQueued = false
function CW.RedrawSoon()
    if redrawQueued then return end
    redrawQueued = true
    zo_callLater(function()
        redrawQueued = false
        CW.Redraw()
    end, 50)
end

local tomeResyncGeneration = 0

local function GetTomeSnapshot()
    local count = GetNumTimedActivities()
    local parts = { count }
    for i = 1, count do
        parts[#parts + 1] = table.concat({
            GetTimedActivityId(i),
            GetTimedActivityName(i),
            GetTimedActivityDescription(i),
            GetTimedActivityProgress(i),
            GetTimedActivityMaxProgress(i),
            GetTimedActivityNumTimesClaimed(i),
            GetTimedActivityTotalNumTimesClaimable(i),
        }, "\031")
    end
    return table.concat(parts, "\030")
end

function CW.QueueTomeResync()
    tomeResyncGeneration = tomeResyncGeneration + 1
    local generation = tomeResyncGeneration
    local snapshot = GetTomeSnapshot()
    for _, delay in ipairs({ 500, 2000, 5000 }) do
        zo_callLater(function()
            if generation ~= tomeResyncGeneration then return end
            local updated = GetTomeSnapshot()
            if updated ~= snapshot then
                snapshot = updated
                CW.RedrawSoon()
            end
        end, delay)
    end
end

-- Native HUD elements Common Works stands in for
--
-- ESO re-shows these on events; an OnEffectivelyShown hook keeps them hidden
-- without polling or suppressing ESO's handler. Dock the Battleground HUD below us instead.

-- The focused-quest panel is the one Common Works exists to replace.
function CW.SuppressNativeTracker()
    local panel = ZO_FocusedQuestTrackerPanel
    if not panel:IsControlHidden() then
        panel:SetHidden(true)
    end
end

-- Installed once at load; CW.SuppressNativeTracker covers the state it is already in.
function CW.WatchNativeTracker()
    ZO_PreHookHandler(ZO_FocusedQuestTrackerPanel, "OnEffectivelyShown", function(self)
        self:SetHidden(true)
        return false
    end)
end

local HIDDEN_TRACKERS = {
    ZO_PromotionalEventTracker_TL,         -- season pass / Tamriel Tomes progress
    ZO_ZoneStoryTracker,                   -- Zone Guide, redrawn at the top of the quest list
    ZO_HouseInformationTrackerTopLevel,    -- house name, owner and population; the House section
}

-- The replaced queue display also parents ESO's LFG ready check; dock that below the panel.
-- Reapply on show because ESO resets the anchor.
local function ApplyActivityTrackerState()
    local c = ZO_ActivityTracker
    if not c.cwHideHook then
        ZO_PreHookHandler(c, "OnEffectivelyShown", function(self)
            if CW.InLfgReadyCheck() then
                CW.DockActivityTracker()
            else
                self:SetHidden(true)
            end
            return false
        end)
        c.cwHideHook = true
    end
    if CW.InLfgReadyCheck() then
        if c:IsControlHidden() then c:SetHidden(false) end
        CW.DockActivityTracker()
    else
        -- Hand it back to ESO in one piece before it goes away again.
        CW.UndockActivityTracker()
        if not c:IsControlHidden() then c:SetHidden(true) end
    end
end

function CW.SuppressNativeExtras()
    for _, c in ipairs(HIDDEN_TRACKERS) do
        if not c.cwHideHook then
            ZO_PreHookHandler(c, "OnEffectivelyShown", function(self)
                self:SetHidden(true)
                return false
            end)
            c.cwHideHook = true
        end
        if not c:IsControlHidden() then c:SetHidden(true) end
    end
    ApplyActivityTrackerState()
end

-- Clear of the panel's bottom rule without reading as part of it.
local BG_HUD_GAP = 14

-- The Battleground objective/score HUD anchors to the quest-tracker slot, which is where
-- the panel now sits, so the two overlap. Move it below us instead.
local function PinBgHudBelow(c, panel)
    -- Clear first: the XML's TOPRIGHT-to-ZO_ActivityTracker anchor otherwise survives and
    -- floats the HUD right, over the panel's last lines. Its size is fixed, not anchored.
    c:ClearAnchors()
    c:SetAnchor(TOPLEFT, panel, BOTTOMLEFT, CW.UI.GetContentIndent(), BG_HUD_GAP)
end

function CW.PlaceBattlegroundHud()
    local panel = CW.UI.panel
    local c = BATTLEGROUND_HUD_FRAGMENT.control
    -- Reapply the dock on show because the fragment system resets the anchor.
    if not c.cwBgDockHook then
        ZO_PreHookHandler(c, "OnEffectivelyShown", function(self)
            PinBgHudBelow(self, CW.UI.panel)
            return false
        end)
        c.cwBgDockHook = true
    end
    if CW.IsBattleground() then PinBgHudBelow(c, panel) end
end

-- Docking the ready check below our panel: its default quest-tracker slot overlaps us
-- (see ApplyActivityTrackerState).
local function AnchorActivityTrackerUnderPanel(c, panel)
    -- The native anchor may not be TOPLEFT; adding ours would stretch the control.
    -- Save both native anchors before clearing, then restore them on undock.
    if not c.cwNativeAnchors then
        local saved = {}
        for i = 0, 1 do
            local isValid, point, relativeTo, relativePoint, x, y = c:GetAnchor(i)
            if isValid then
                saved[#saved + 1] = { point, relativeTo, relativePoint, x, y }
            end
        end
        c.cwNativeAnchors = saved
    end
    -- Same slot, gap and indent as the docked BG HUD.
    local x = CW.UI.GetContentIndent()
    c:ClearAnchors()
    c:SetAnchor(TOPLEFT, panel, BOTTOMLEFT, x, 8)
    -- Our rows draw on DL_OVERLAY, so without a tier bump the two interleave wherever
    -- they overlap.
    c:SetDrawTier(DT_HIGH)
end

-- A no-op unless we actually moved it.
function CW.UndockActivityTracker()
    local c = ZO_ActivityTracker
    if not c.cwNativeAnchors then return end
    -- With no native anchors to restore, leave it docked. Retain the empty stash
    -- so the next dock cannot mistake our anchor for a native one.
    if #c.cwNativeAnchors == 0 then return end
    c:ClearAnchors()
    for _, a in ipairs(c.cwNativeAnchors) do
        c:SetAnchor(a[1], a[2], a[3], a[4], a[5])
    end
    c:SetDrawTier(DT_MEDIUM)
    c.cwNativeAnchors = nil
end

function CW.DockActivityTracker()
    local c = ZO_ActivityTracker
    local panel = CW.UI.panel
    -- Only while the ready check is up AND the panel is on screen: anchoring to a
    -- hidden panel drags the ready check off with it (hide-in-combat, scene changes).
    if panel:IsControlHidden() or not CW.InLfgReadyCheck() then
        CW.UndockActivityTracker()
        return
    end
    AnchorActivityTrackerUnderPanel(c, panel)
end

function CW.SetAssisted(questIndex)
    FOCUSED_QUEST_TRACKER:ForceAssist(questIndex)
end


-- Sharing solo is a no-op the game rejects, so say why instead. ShareQuest must run off
-- a hardware event, which a click or keybind always is.
function CW.PromptQuestShare(questIndex)
    if GetIsQuestSharable(questIndex) and GetGroupSize() > 1 then
        ShareQuest(questIndex)
    else
        d(CW.BRAND .. ": " .. CW.L.SHARE_NEEDS_GROUP)
    end
end

-- Through the journal's own confirmation dialog, so nothing is abandoned silently.
function CW.DropQuest(questIndex)
    QUEST_JOURNAL_MANAGER:ConfirmAbandonQuest(questIndex)
end
