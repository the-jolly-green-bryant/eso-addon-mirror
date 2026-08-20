-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.ActiveQuest = EPC.ActiveQuest or {}
local Q = EPC.ActiveQuest
local wm = WINDOW_MANAGER

local DEFAULT_WIDTH = 420
local DEFAULT_HEIGHT = 160
local MIN_WIDTH = 280
local MIN_HEIGHT = 120
local MAX_WIDTH = 900
local MAX_HEIGHT = 520

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a,b,c,d,e,f,g,h,i,j,k = pcall(fn, ...)
    if not ok then return fallback end
    return a,b,c,d,e,f,g,h,i,j,k
end

local function safeNumber(fn, fallback, ...)
    local value = safe(fn, fallback, ...)
    local number = tonumber(value)
    if number ~= nil then return number end
    return tonumber(fallback) or 0
end

local function trim(value)
    local s = tostring(value or "")
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function stripESOFormatting(value)
    value = tostring(value or "")
    value = value:gsub("|c%x%x%x%x%x%x", "")
    value = value:gsub("|r", "")
    value = value:gsub("|t.-|t", " ")
    value = value:gsub("|H.-|h(.-)|h", "%1")
    -- Quest condition strings can contain hidden control bytes used by ESO's
    -- tracker formatter. Those bytes may render as square glyphs and can split
    -- an otherwise normal 7/9 token so the old duplicate matcher misses it.
    value = value:gsub("[%z\1-\31\127]", " ")
    return trim(value:gsub("%s+", " "))
end

local function extractAndStripProgress(value)
    value = stripESOFormatting(value)
    local firstCurrent, firstMaximum = nil, nil
    local function capture(a, b)
        if firstCurrent == nil then
            firstCurrent = tostring(a):gsub(",", "")
            firstMaximum = tostring(b):gsub(",", "")
        end
        return " "
    end
    value = value:gsub("%(%s*([%d,]+)%s*/%s*([%d,]+)%s*%)", capture)
    value = value:gsub("%(%s*([%d,]+)%s+[Oo][Ff]%s+([%d,]+)%s*%)", capture)
    value = value:gsub("([%d,]+)%s*/%s*([%d,]+)", capture)
    value = value:gsub("([%d,]+)%s+[Oo][Ff]%s+([%d,]+)", capture)
    value = trim(value:gsub("%s+", " "))
    return value, tonumber(firstCurrent), tonumber(firstMaximum)
end

local function collapseAdjacentDuplicateWords(value)
    local words = {}
    for word in tostring(value or ""):gmatch("%S+") do
        local key = string.lower(word:gsub("[%p]+$", ""))
        local previous = words[#words]
        local previousKey = previous and string.lower(previous:gsub("[%p]+$", "")) or nil
        if key == "" or key ~= previousKey then
            words[#words + 1] = word
        end
    end
    return table.concat(words, " ")
end

local function escapeLuaPattern(value)
    return tostring(value or ""):gsub("([^%w])", "%%%1")
end

local function stripAuthoritativeProgress(value, current, maximum)
    value = tostring(value or "")
    current = tonumber(current)
    maximum = tonumber(maximum)
    if not current or not maximum or maximum <= 1 then return value end

    local cur = escapeLuaPattern(string.format("%d", current))
    local max = escapeLuaPattern(string.format("%d", maximum))

    -- Remove the authoritative counter even when ESO inserts hidden glyphs,
    -- icons, punctuation, or non-ASCII separator bytes around the slash.
    -- The bounded separator class deliberately refuses letters/digits so it
    -- cannot consume ordinary objective text.
    local pattern = cur .. "%s*[^%a%d]-/%s*[^%a%d]-" .. max
    value = value:gsub(pattern, " ")
    return trim(value:gsub("%s+", " "))
end

local function stripTrailingProgressGarbage(value)
    value = stripESOFormatting(value)

    -- Some ESO tracker strings contain non-printing/private glyph bytes inside
    -- the progress token. In-game those can appear as square boxes, e.g.
    -- "Resources:[] 70 /[] 9" even though the API reports 7/9. Treat any
    -- trailing digit/slash/digit cluster with no letters after it as tracker
    -- progress garbage and remove the whole cluster before rendering.
    local prefix = value:match("^(.-)%s*[%d,]+%s*[^%a%d]-/%s*[^%a%d]-[%d,]+%s*$")
    if prefix then
        -- Also remove separator glyphs/punctuation immediately before the
        -- numeric cluster so unsupported formatting does not survive as boxes.
        prefix = prefix:gsub("[^%w%)%]]+$", "")
        return trim(prefix)
    end
    return value
end

local function stripMalformedProgressSuffix(value)
    value = stripESOFormatting(value)

    -- ESO can occasionally return a visually corrupted tracker suffix such as
    -- "70 /□ 9" while the numeric API correctly reports 7/9.  When a line
    -- has a colon-delimited suffix containing digits and a slash, the suffix is
    -- presentation data, not objective text, so discard it wholesale.
    local head, tail = value:match("^(.*:)([^:]*)$")
    if head and tail and tail:find("/", 1, true) and tail:find("%d") then
        return trim(head)
    end

    -- Fallback for tracker strings without a colon.  Remove a trailing
    -- digit/separator/digit cluster even when unsupported glyphs sit around
    -- the slash.  Requiring a slash prevents ordinary numbered objectives
    -- such as "Defeat 3 Captains" from being stripped.
    local prefix = value:match("^(.-)%s+%d[^%a]-/[^%a]-%d.*$")
    if prefix and prefix ~= "" then return trim(prefix) end
    return value
end

local function sanitizeRenderedLine(value, current, maximum)
    current = tonumber(current)
    maximum = tonumber(maximum)

    -- When the quest API gives us an authoritative current/max pair, strip
    -- every textual copy of that pair before generic cleanup, then append one
    -- clean counter at the very end. This guarantees a single x/y on screen.
    local prepared = stripESOFormatting(value)
    if maximum and maximum > 1 then
        prepared = stripMalformedProgressSuffix(prepared)
        prepared = stripAuthoritativeProgress(prepared, current or 0, maximum)
        prepared = stripTrailingProgressGarbage(prepared)
    end

    local base, embeddedCurrent, embeddedMaximum = extractAndStripProgress(prepared)
    base = collapseAdjacentDuplicateWords(base)

    if not maximum or maximum <= 1 then
        current, maximum = embeddedCurrent, embeddedMaximum
    end

    if maximum and maximum > 1 then
        local counter = string.format("%d/%d", current or 0, maximum)
        return base ~= "" and (base .. "  " .. counter) or counter
    end
    return base
end

local function normalizeProgressCounters(value)
    local out, seen = {}, {}
    for line in (tostring(value or "") .. "\n"):gmatch("(.-)\n") do
        line = sanitizeRenderedLine(line)
        local key = string.lower(line:gsub("[%d,]+%s*/%s*[%d,]+", " "):gsub("[%p%s]+", " "))
        key = trim(key:gsub("%s+", " "))
        if line ~= "" and not seen[key] then
            seen[key] = true
            out[#out + 1] = line
        end
    end
    return table.concat(out, "\n")
end

function Q:GetActiveQuestIndex()
    local fallbackTracked = nil
    local max = tonumber(MAX_JOURNAL_QUESTS) or 25
    for i = 1, max do
        local valid = type(IsValidQuestIndex) ~= "function" or safe(IsValidQuestIndex, false, i) == true
        if valid then
            local name, _, _, _, _, _, tracked = safe(GetJournalQuestInfo, "", i)
            name = trim(name)
            if name ~= "" then
                if TRACK_TYPE_QUEST ~= nil and type(GetTrackedIsAssisted) == "function" then
                    local assisted = safe(GetTrackedIsAssisted, false, TRACK_TYPE_QUEST, i, 0) == true
                    if assisted then return i end
                end
                if tracked == true and not fallbackTracked then fallbackTracked = i end
            end
        end
    end
    return fallbackTracked
end

function Q:BuildObjectiveText(index)
    if not index then return "Track or focus a quest to see its next steps." end

    local questName, _, activeStepText, _, activeOverride, completed = safe(GetJournalQuestInfo, "", index)
    questName = trim(questName)

    local function objectiveKey(value)
        local stripped = extractAndStripProgress(value)
        value = string.lower(stripped)
        value = value:gsub("^optional%s*:?%s*", "")
        value = value:gsub("[%[%]%(%){}<>]", " ")
        value = value:gsub("[%p%s]+", " ")
        value = trim(value:gsub("%s+", " "))
        return value
    end

    local function displayLine(base, current, maximum)
        return sanitizeRenderedLine(base, current, maximum)
    end

    local questKey = objectiveKey(questName)
    local ordered = {}
    local byKey = {}

    local function addObjective(textValue, current, maximum)
        local base = extractAndStripProgress(textValue)
        if base == "" then return end
        local key = objectiveKey(base)
        if key == "" or key == questKey then return end

        -- One authoritative row per normalized objective. If ESO exposes the same
        -- objective through more than one step/condition, keep only the most useful
        -- counter for that objective instead of rendering a duplicate line.
        local existing = byKey[key]
        local cur = tonumber(current) or 0
        local max = tonumber(maximum) or 0
        if existing then
            local replace = false
            if max > (existing.maximum or 0) then
                replace = true
            elseif max == (existing.maximum or 0) and cur > (existing.current or 0) then
                replace = true
            end
            if replace then
                existing.current = cur
                existing.maximum = max
                existing.text = displayLine(base, cur, max)
            end
            return
        end

        local row = {
            key = key,
            current = cur,
            maximum = max,
            text = displayLine(base, cur, max),
        }
        byKey[key] = row
        ordered[#ordered + 1] = row
    end

    if completed == true and type(GetJournalQuestEnding) == "function" then
        local ending = sanitizeRenderedLine(safe(GetJournalQuestEnding, "", index))
        if ending ~= "" then return ending end
    end

    -- Conditions are the single source of truth for the live objective list.
    -- Do not also render step/tracker override strings when conditions exist;
    -- mixing both sources is what caused repeated names and repeated counters.
    local numSteps = safeNumber(GetJournalQuestNumSteps, 0, index)
    if type(GetJournalQuestNumConditions) == "function" and type(GetJournalQuestConditionInfo) == "function" then
        for stepIndex = 1, numSteps do
            local _, visibility = safe(GetJournalQuestStepInfo, "", index, stepIndex)
            if visibility ~= QUEST_STEP_VISIBILITY_HIDDEN then
                local conditionCount = safeNumber(GetJournalQuestNumConditions, 0, index, stepIndex)
                for conditionIndex = 1, conditionCount do
                    local conditionText, current, maximum, isFail, isComplete, _, isVisible = safe(GetJournalQuestConditionInfo, "", index, stepIndex, conditionIndex, true)
                    if isVisible ~= false and isComplete ~= true and isFail ~= true then
                        addObjective(conditionText, current, maximum)
                    end
                end
            end
        end
    end

    local lines = {}
    for i = 1, math.min(#ordered, 5) do
        local row = ordered[i]
        if row.text and row.text ~= "" then
            lines[#lines + 1] = "• " .. row.text
        end
    end

    if #lines == 0 then
        -- Only use ESO's tracker/step text as a fallback when no visible incomplete
        -- condition rows exist. Normalize every progress token down to one copy.
        local fallback = sanitizeRenderedLine(activeOverride)
        if fallback == "" then fallback = sanitizeRenderedLine(activeStepText) end
        if fallback ~= "" and objectiveKey(fallback) ~= questKey then
            lines[1] = fallback
        end
    end

    if #lines == 0 then
        lines[1] = completed == true and "Quest ready to complete." or "Follow the quest marker."
    end
    return normalizeProgressCounters(table.concat(lines, "\n"))
end

function Q:Create()
    local frame = wm:CreateTopLevelWindow("EAS_ActiveQuestOverlay")
    local savedWidth = tonumber(EPC.saved and EPC.saved.activeQuestWidth) or DEFAULT_WIDTH
    local savedHeight = tonumber(EPC.saved and EPC.saved.activeQuestHeight) or DEFAULT_HEIGHT
    savedWidth = math.max(MIN_WIDTH, math.min(MAX_WIDTH, savedWidth))
    savedHeight = math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, savedHeight))
    frame:SetDimensions(savedWidth, savedHeight)
    frame:SetDimensionConstraints(MIN_WIDTH, MIN_HEIGHT)
    frame:SetResizeHandleSize(18)
    frame:SetClampedToScreen(true)
    frame:SetMouseEnabled(false)
    frame:SetMovable(false)

    local left = tonumber(EPC.saved and EPC.saved.activeQuestLeft) or -1
    local top = tonumber(EPC.saved and EPC.saved.activeQuestTop) or -1
    if left >= 0 and top >= 0 then frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    else frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 34, 180) end

    -- No gameplay background. This outline is visible only in HUD Layout Mode
    -- so the transparent tracker still has an obvious resize boundary.
    local layoutGuide = wm:CreateControl("EAS_ActiveQuestOverlay_LayoutGuide", frame, CT_BACKDROP)
    layoutGuide:SetAnchorFill(frame)
    layoutGuide:SetCenterColor(0, 0, 0, 0)
    layoutGuide:SetEdgeTexture(nil, 1, 1, 1)
    layoutGuide:SetEdgeColor(0.91, 0.70, 0.28, 0.45)
    layoutGuide:SetHidden(true)

    local header = wm:CreateControl("EAS_ActiveQuestOverlay_Header", frame, CT_LABEL)
    header:SetFont("ZoFontGameSmall")
    header:SetColor(0.55, 0.60, 0.68, 1)
    header:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 7)
    header:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -12, 7)
    header:SetHeight(18)
    header:SetText("ACTIVE QUEST")

    local title = wm:CreateControl("EAS_ActiveQuestOverlay_Title", frame, CT_LABEL)
    title:SetFont("ZoFontGameBold")
    title:SetColor(0.91, 0.70, 0.28, 1)
    title:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 25)
    title:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -12, 25)
    title:SetHeight(44)
    title:SetVerticalAlignment(TEXT_ALIGN_TOP)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    local steps = wm:CreateControl("EAS_ActiveQuestOverlay_Steps", frame, CT_LABEL)
    steps:SetFont("ZoFontGame")
    steps:SetColor(0.92, 0.94, 0.97, 1)
    steps:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 72)
    steps:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -12, -8)
    steps:SetVerticalAlignment(TEXT_ALIGN_TOP)
    steps:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    if steps.SetLineSpacing then steps:SetLineSpacing(2) end
    -- Do not set TEXT_WRAP_MODE_ELLIPSIS here. With a bounded label width,
    -- ESO wraps normal text naturally; ellipsis mode was clipping objectives.

    local moveHint = wm:CreateControl("EAS_ActiveQuestOverlay_MoveHint", frame, CT_LABEL)
    moveHint:SetFont("ZoFontGameSmall")
    moveHint:SetColor(0.91, 0.70, 0.28, 1)
    moveHint:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -12, 7)
    moveHint:SetDimensions(230, 18)
    moveHint:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    moveHint:SetText("DRAG TO MOVE • EDGES TO RESIZE")
    moveHint:SetHidden(true)

    frame:SetHandler("OnMoveStop", function(control)
        if EPC.saved then
            EPC.saved.activeQuestLeft = control:GetLeft()
            EPC.saved.activeQuestTop = control:GetTop()
        end
    end)
    frame:SetHandler("OnResizeStop", function(control)
        if EPC.saved then
            local width, height = control:GetDimensions()
            EPC.saved.activeQuestWidth = math.floor((tonumber(width) or DEFAULT_WIDTH) + 0.5)
            EPC.saved.activeQuestHeight = math.floor((tonumber(height) or DEFAULT_HEIGHT) + 0.5)
        end
    end)

    self.frame, self.title, self.steps, self.moveHint = frame, title, steps, moveHint
    self.layoutGuide = layoutGuide
end

function Q:Refresh()
    if not self.frame or not EPC.saved then return end
    local show = EPC.saved.showActiveQuestOverlay ~= false
    if self.layoutMode then show = true
    elseif EPC.OverlayModeAllows then show = show and EPC:OverlayModeAllows("activeQuestVisibility") end
    if show and not self.layoutMode and EPC.IsGameplayHudSuppressed and EPC:IsGameplayHudSuppressed() then show = false end
    self.frame:SetHidden(not show)
    if not show then return end

    local index = self:GetActiveQuestIndex()
    if self.layoutMode and not index then
        self.title:SetText("Quest Overlay Preview")
        self.steps:SetText("• Current objective\n• Next quest step")
        return
    end
    if not index then
        self.title:SetText("No Focused Quest")
        self.steps:SetText("Track or focus a quest to see its next steps.")
        return
    end
    local name = trim(safe(GetJournalQuestInfo, "", index))
    if name == "" then name = "Active Quest" end
    self.title:SetText(name)
    self.steps:SetText(normalizeProgressCounters(self:BuildObjectiveText(index)))
end

function Q:SetLayoutMode(active)
    self.layoutMode = active == true
    if not self.frame then return end
    self.frame:SetMouseEnabled(self.layoutMode)
    self.frame:SetMovable(self.layoutMode)
    if self.moveHint then self.moveHint:SetHidden(not self.layoutMode) end
    if self.layoutGuide then self.layoutGuide:SetHidden(not self.layoutMode) end
    self:Refresh()
end

function Q:SetSize(width, height)
    if not self.frame or not EPC.saved then return end
    width = math.max(MIN_WIDTH, math.min(MAX_WIDTH, tonumber(width) or self.frame:GetWidth()))
    height = math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, tonumber(height) or self.frame:GetHeight()))
    self.frame:SetDimensions(width, height)
    EPC.saved.activeQuestWidth = math.floor(width + 0.5)
    EPC.saved.activeQuestHeight = math.floor(height + 0.5)
    self:Refresh()
end

function Q:ResetSize()
    if not self.frame or not EPC.saved then return end
    EPC.saved.activeQuestWidth = DEFAULT_WIDTH
    EPC.saved.activeQuestHeight = DEFAULT_HEIGHT
    self.frame:SetDimensions(DEFAULT_WIDTH, DEFAULT_HEIGHT)
    self:Refresh()
end

function Q:ResetPosition()
    if not self.frame or not EPC.saved then return end
    EPC.saved.activeQuestLeft, EPC.saved.activeQuestTop = -1, -1
    self.frame:ClearAnchors()
    self.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 34, 180)
end

function Q:Initialize()
    self.layoutMode = false
    self:Create()
    self:Refresh()
    local prefix = EPC.name .. "_ActiveQuest"
    local events = { EVENT_QUEST_ADDED, EVENT_QUEST_REMOVED, EVENT_QUEST_ADVANCED, EVENT_QUEST_CONDITION_COUNTER_CHANGED, EVENT_QUEST_COMPLETE, EVENT_TRACKING_UPDATE }
    local seen = {}
    for i=1,#events do
        local eventId = events[i]
        if eventId and not seen[eventId] then
            seen[eventId] = true
            EVENT_MANAGER:RegisterForEvent(prefix .. "_" .. tostring(eventId), eventId, function() self:Refresh() end)
        end
    end
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Tick", 500, function() self:Refresh() end)
end
