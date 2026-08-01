FlamechasersPledgeQueue = {}
local FPQ = FlamechasersPledgeQueue
local WM = WINDOW_MANAGER
local ADDON_NAME = "FlamechasersPledgeQueue"
local SAVED_VARIABLES_NAME = "FlamechasersPledgeQueueSavedVariables"
-- Keep the wrapper version unchanged so existing data is never reset merely
-- because the active namespace is now server-specific.
local SAVED_VARIABLES_VERSION = 3
local SV

local COLORS = {
    cyan = { 0.60, 0.48, 0.70, 1 },
    white = { 0.95, 0.94, 0.98, 1 },
    muted = { 0.59, 0.56, 0.65, 1 },
    green = { 0.35, 0.84, 0.58, 1 },
    red = { 1.00, 0.38, 0.40, 1 },
}

local function SetColor(control, color)
    control:SetColor(unpack(color))
end

local function Label(parent, name, text, font)
    local control = WM:CreateControl(name, parent, CT_LABEL)
    control:SetFont(font or "ZoFontGame")
    SetColor(control, COLORS.white)
    control:SetText(text or "")
    return control
end

local function Button(parent, name, text, font)
    local control = WM:CreateControl(name, parent, CT_BUTTON)
    control:SetFont(font or "ZoFontGame")
    control:SetNormalFontColor(unpack(COLORS.white))
    control:SetMouseOverFontColor(unpack(COLORS.cyan))
    control:SetPressedFontColor(unpack(COLORS.cyan))
    control:SetText(text or "")
    return control
end

local function Panel(parent, name, color)
    local control = WM:CreateControl(name, parent, CT_BACKDROP)
    control:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    control:SetCenterColor(unpack(color or { 0.015, 0.025, 0.04, 0.92 }))
    control:SetEdgeTexture("", 1, 1, 1)
    control:SetEdgeColor(0, 0, 0, 0)
    return control
end

local function CreateOutline(parent, name, width, height, thickness, color)
    local outline = {}
    local function Line(suffix, lineWidth, lineHeight, point, relativePoint, x, y)
        local line = WM:CreateControl(name .. suffix, parent, CT_TEXTURE)
        line:SetDimensions(lineWidth, lineHeight)
        line:SetAnchor(point, parent, relativePoint, x or 0, y or 0)
        line:SetColor(unpack(color))
        outline[#outline + 1] = line
    end
    Line("Top", width, thickness, TOP, TOP, 0, 0)
    Line("Bottom", width, thickness, BOTTOM, BOTTOM, 0, 0)
    Line("Left", thickness, height, LEFT, LEFT, 0, 0)
    Line("Right", thickness, height, RIGHT, RIGHT, 0, 0)
    return outline
end

local function SetOutlineColor(outline, color)
    for _, line in ipairs(outline) do line:SetColor(unpack(color)) end
end

local function Normalize(text)
    text = zo_strformat("<<C:1>>", text or "")
    text = zo_strlower(text)
    text = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    return text:gsub("[%p%s%c]+", "")
end

local function SafeActivityInfo(activityId)
    if not activityId then return nil end
    local name = GetActivityInfo(activityId)
    if name and name ~= "" then return zo_strformat("<<C:1>>", name) end
end

function FPQ.BuildActivityCatalog()
    FPQ.activityCatalog = {}
    FPQ.activityList = {}
    FPQ.randomNormalId = FPQ.FindRandomActivitySet(LFG_ACTIVITY_DUNGEON)
    FPQ.randomVeteranId = FPQ.FindRandomActivitySet(LFG_ACTIVITY_MASTER_DUNGEON)

    local function AddType(activityType, field)
        local count = GetNumActivitiesByType(activityType)
        for index = 1, count do
            local activityId = GetActivityIdByTypeAndIndex(activityType, index)
            local name = SafeActivityInfo(activityId)
            local key = Normalize(name)
            if name and key ~= "" then
                local entry = FPQ.activityCatalog[key]
                if not entry then
                    entry = { key = key, name = name }
                    FPQ.activityCatalog[key] = entry
                    FPQ.activityList[#FPQ.activityList + 1] = entry
                end
                entry[field] = activityId
                entry.zoneId = entry.zoneId or GetActivityZoneId(activityId)
            end
        end
    end

    AddType(LFG_ACTIVITY_DUNGEON, "normalId")
    AddType(LFG_ACTIVITY_MASTER_DUNGEON, "veteranId")
    table.sort(FPQ.activityList, function(a, b) return #a.key > #b.key end)
end

function FPQ.FindRandomActivitySet(activityType)
    for index = 1, GetNumActivitySetsByType(activityType) do
        local activitySetId = GetActivitySetIdByTypeAndIndex(activityType, index)
        if DoesActivitySetHaveRewardData(activitySetId) then
            return activitySetId
        end
    end
end

function FPQ.FindPledges()
    if not FPQ.activityList then FPQ.BuildActivityCatalog() end
    local pledges, used = {}, {}

    for questIndex = 1, MAX_JOURNAL_QUESTS do
        local questName = GetJournalQuestName(questIndex)
        if questName and questName ~= "" then
            local isDaily = not GetJournalQuestRepeatType
                or GetJournalQuestRepeatType(questIndex) == QUEST_REPEAT_DAILY
            if isDaily then
                local normalizedQuest = Normalize(questName)
                for _, activity in ipairs(FPQ.activityList) do
                    if not used[activity.key]
                        and normalizedQuest:find(activity.key, 1, true) then
                        pledges[#pledges + 1] = {
                            key = activity.key,
                            name = activity.name,
                            questName = questName,
                            questIndex = questIndex,
                            normalId = activity.normalId,
                            veteranId = activity.veteranId,
                            zoneId = activity.zoneId,
                        }
                        used[activity.key] = true
                        break
                    end
                end
            end
        end
    end
    return pledges
end

function FPQ.GetSelection(key)
    FPQ.selections = FPQ.selections or {}
    FPQ.selections[key] = FPQ.selections[key] or { normal = false, veteran = false }
    return FPQ.selections[key]
end

function FPQ.CreateCheck(parent, name, labelText, field)
    local hit = WM:CreateControl(name, parent, CT_BUTTON)
    hit:SetDimensions(144, 46)

    local pill = Panel(hit, name .. "Pill", { 0.026, 0.020, 0.036, 0.98 })
    pill:SetAnchorFill(hit)
    pill:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Tooltip-Border.dds", 128, 8)
    pill:SetInsets(2, 2, -2, -2)
    pill:SetEdgeColor(0.27, 0.22, 0.34, 1)

    local indicator = WM:CreateControl(name .. "Indicator", hit, CT_TEXTURE)
    indicator:SetDimensions(22, 22)
    indicator:SetAnchor(LEFT, hit, LEFT, 13, 0)
    indicator:SetTexture("EsoUI/Art/Buttons/checkbox_unchecked.dds")

    local text = Label(hit, name .. "Text", labelText, "ZoFontGameBold")
    text:SetAnchor(LEFT, indicator, RIGHT, 10, 0)

    hit.pill, hit.indicator, hit.text, hit.field = pill, indicator, text, field
    hit:SetHandler("OnMouseEnter", function(control)
        if control.available then
            control.pill:SetCenterColor(0.075, 0.055, 0.095, 0.98)
        end
    end)
    hit:SetHandler("OnMouseExit", function(control)
        if control.selected then
            control.pill:SetCenterColor(0.085, 0.060, 0.105, 0.98)
        else
            control.pill:SetCenterColor(0.026, 0.020, 0.036, 0.98)
        end
    end)
    hit:SetHandler("OnClicked", function(control)
        local pledge = control.pledge
        if not pledge then return end
        local selection = FPQ.GetSelection(pledge.key)
        selection[field] = not selection[field]
        FPQ.UpdateCheck(control, selection[field], control.activityId ~= nil)
        FPQ.UpdateQueueButton()
    end)
    return hit
end

function FPQ.UpdateCheck(check, selected, available)
    check.selected, check.available = selected, available
    check:SetMouseEnabled(available)
    check:SetAlpha(available and 1 or 0.28)
    if selected then
        check.indicator:SetTexture("EsoUI/Art/Buttons/checkbox_checked.dds")
        check.pill:SetCenterColor(0.085, 0.060, 0.105, 0.98)
        check.pill:SetEdgeColor(unpack(COLORS.cyan))
        SetColor(check.text, COLORS.white)
    else
        check.indicator:SetTexture("EsoUI/Art/Buttons/checkbox_unchecked.dds")
        check.pill:SetCenterColor(0.026, 0.020, 0.036, 0.98)
        check.pill:SetEdgeColor(0.27, 0.22, 0.34, 1)
        SetColor(check.text, COLORS.muted)
    end
end

function FPQ.CreateRole(parent, role, x, labelText)
    local button = WM:CreateControl("FlamechasersPledgeRole" .. role, parent, CT_BUTTON)
    button:SetDimensions(190, 66)
    button:SetAnchor(TOPLEFT, parent, TOPLEFT, x, 0)
    local background = Panel(button, "FlamechasersPledgeRoleBg" .. role,
        { 0.025, 0.019, 0.035, 0.96 })
    background:SetAnchorFill(button)
    local outline = CreateOutline(button, "FlamechasersPledgeRoleOutline" .. role,
        190, 66, 1, { 0.24, 0.21, 0.29, 0.85 })
    local accent = WM:CreateControl("FlamechasersPledgeRoleAccent" .. role, button, CT_TEXTURE)
    accent:SetDimensions(190, 4)
    accent:SetAnchor(BOTTOM, button, BOTTOM, 0, 0)
    accent:SetColor(unpack(COLORS.cyan))
    local icon = WM:CreateControl("FlamechasersPledgeRoleIcon" .. role, button, CT_TEXTURE)
    icon:SetDimensions(38, 38)
    icon:SetAnchor(LEFT, button, LEFT, 18, 0)
    icon:SetTexture(ZO_GetRoleIcon(role))
    local label = Label(button, "FlamechasersPledgeRoleLabel" .. role, labelText, "ZoFontWinH3")
    label:SetAnchor(LEFT, icon, RIGHT, 13, 0)

    button.role, button.background, button.outline, button.accent, button.icon, button.label =
        role, background, outline, accent, icon, label
    button:SetHandler("OnMouseEnter", function(control)
        if not control.active then
            SetOutlineColor(control.outline, { 0.48, 0.39, 0.55, 1 })
            control.background:SetCenterColor(0.045, 0.035, 0.055, 0.98)
        end
    end)
    button:SetHandler("OnMouseExit", function(control)
        FPQ.RefreshRoles()
    end)
    button:SetHandler("OnClicked", function(control) FPQ.SetRole(control.role) end)
    FPQ.roleButtons[role] = button
end

function FPQ.SetRole(role)
    if CanUpdateSelectedLFGRole and not CanUpdateSelectedLFGRole() then
        FPQ.SetStatus("Your preferred role cannot be changed right now.", COLORS.red)
        return
    end
    UpdateSelectedLFGRole(role)
    if ZO_ACTIVITY_FINDER_ROOT_MANAGER
        and ZO_ACTIVITY_FINDER_ROOT_MANAGER.UpdateLocationData then
        ZO_ACTIVITY_FINDER_ROOT_MANAGER:UpdateLocationData()
    end
    FPQ.RefreshRoles()
    FPQ.SetStatus("Preferred group role updated.", COLORS.green)
end

function FPQ.RefreshRoles()
    if not FPQ.roleButtons then return end
    local selected = GetSelectedLFGRole()
    for role, button in pairs(FPQ.roleButtons) do
        local active = role == selected
        button.active = active
        button.background:SetCenterColor(
            active and 0.075 or 0.025,
            active and 0.055 or 0.019,
            active and 0.090 or 0.035,
            0.96)
        SetOutlineColor(button.outline,
            active and COLORS.cyan or { 0.24, 0.21, 0.29, 0.85 })
        button.accent:SetAlpha(active and 1 or 0.16)
        button.icon:SetAlpha(active and 1 or 0.48)
        button.label:SetAlpha(active and 1 or 0.58)
    end
end

function FPQ.SetStatus(text, color)
    if not FPQ.status then return end
    FPQ.status:SetText(text or "")
    SetColor(FPQ.status, color or COLORS.muted)
end

function FPQ.Refresh()
    FPQ.pledges = FPQ.FindPledges()
    local active = {}
    for _, pledge in ipairs(FPQ.pledges) do active[pledge.key] = true end
    for key in pairs(FPQ.selections or {}) do
        if not active[key] then FPQ.selections[key] = nil end
    end

    for index = 1, 3 do
        local row, pledge = FPQ.rows[index], FPQ.pledges[index]
        row:SetHidden(pledge == nil)
        if pledge then
            row.pledge = pledge
            row.name:SetText(pledge.name)
            row.quest:SetText(pledge.questName)
            local selection = FPQ.GetSelection(pledge.key)
            row.normal.pledge, row.normal.activityId = pledge, pledge.normalId
            row.veteran.pledge, row.veteran.activityId = pledge, pledge.veteranId
            FPQ.UpdateCheck(row.normal, selection.normal, pledge.normalId ~= nil)
            FPQ.UpdateCheck(row.veteran, selection.veteran, pledge.veteranId ~= nil)
        end
    end
    FPQ.empty:SetHidden(#FPQ.pledges > 0)
    FPQ.RefreshRoles()
    FPQ.UpdateQueueButton()
    if #FPQ.pledges == 0 then
        FPQ.SetStatus("No active Undaunted pledge quests detected.", COLORS.muted)
    else
        FPQ.SetStatus(string.format("%d active pledge%s detected.",
            #FPQ.pledges, #FPQ.pledges == 1 and "" or "s"), COLORS.green)
    end
end

function FPQ.GetSelectedActivities()
    local activities = {}
    for _, pledge in ipairs(FPQ.pledges or {}) do
        local selection = FPQ.GetSelection(pledge.key)
        if selection.normal and pledge.normalId then
            activities[#activities + 1] = pledge.normalId
        end
        if selection.veteran and pledge.veteranId then
            activities[#activities + 1] = pledge.veteranId
        end
    end
    return activities
end

function FPQ.UpdateQueueButton()
    if not FPQ.queueButton then return end
    local count = #FPQ.GetSelectedActivities()
    FPQ.queueButton.title:SetText(count > 0
        and string.format("QUEUE PLEDGES  (%d)", count)
        or "QUEUE PLEDGES")
    local queued = IsCurrentlySearchingForGroup and IsCurrentlySearchingForGroup()
    FPQ.queueButton:SetAlpha(queued and 0.25 or (count > 0 and 1 or 0.42))
end

function FPQ.CanStartQueue()
    if IsCurrentlySearchingForGroup and IsCurrentlySearchingForGroup() then
        FPQ.SetStatus("Leave your current queue before choosing another mode.", COLORS.red)
        return false
    end
    if IsUnitGrouped("player") and not IsUnitGroupLeader("player") then
        FPQ.SetStatus("Only the group leader can start the queue.", COLORS.red)
        return false
    end
    return true
end

function FPQ.StartPreparedQueue(addEntries)
    if not FPQ.CanStartQueue() then return false end
    ClearActivityFinderSearch()
    addEntries()
    local result = StartActivityFinderSearch()
    if result == ACTIVITY_QUEUE_RESULT_SUCCESS then
        FPQ.SetStatus("Queue started.", COLORS.green)
        FPQ.RefreshQueueState()
        FPQ.Close(true)
        return true
    end
    if ZO_AlertEvent then ZO_AlertEvent(EVENT_ACTIVITY_QUEUE_RESULT, result) end
    FPQ.SetStatus("ESO could not start this queue. Check the on-screen alert.", COLORS.red)
    return false
end

function FPQ.QueueRandom(veteran)
    if not FPQ.activityCatalog then FPQ.BuildActivityCatalog() end
    local activitySetId = veteran and FPQ.randomVeteranId or FPQ.randomNormalId
    if not activitySetId then
        FPQ.SetStatus("ESO's random dungeon activity is currently unavailable.", COLORS.red)
        return
    end
    FPQ.StartPreparedQueue(function()
        AddActivityFinderSetSearchEntry(activitySetId)
    end)
end

function FPQ.QueueSelected()
    local activities = FPQ.GetSelectedActivities()
    if #activities == 0 then
        FPQ.SetStatus("Select at least one Normal or Veteran activity.", COLORS.red)
        return
    end
    FPQ.StartPreparedQueue(function()
        for _, activityId in ipairs(activities) do
            AddActivityFinderSpecificSearchEntry(activityId)
        end
    end)
end

function FPQ.LeaveQueue()
    if not IsCurrentlySearchingForGroup() then
        FPQ.SetStatus("You are not currently queued.", COLORS.muted)
        return
    end
    if IsUnitGrouped("player") and not IsUnitGroupLeader("player") then
        FPQ.SetStatus("Only the group leader can leave the group queue.", COLORS.red)
        return
    end
    CancelGroupSearches()
    FPQ.SetStatus("Leaving activity queue…", COLORS.muted)
end

function FPQ.RefreshQueueState()
    if not FPQ.leaveButton then return end
    local queued = IsCurrentlySearchingForGroup()
    FPQ.leaveButton:SetAlpha(queued and 1 or 0.30)
    FPQ.leaveButton:SetMouseEnabled(queued)
    for _, control in ipairs(FPQ.modeButtons or {}) do
        control:SetAlpha(queued and 0.34 or 1)
    end
    if FPQ.queueButton then
        local count = #FPQ.GetSelectedActivities()
        FPQ.queueButton:SetAlpha(queued and 0.25 or (count > 0 and 1 or 0.42))
    end
end

function FPQ.AssistMatchingPledge()
    FPQ.pledges = FPQ.FindPledges()
    local zoneIndex = GetUnitZoneIndex("player")
    local zoneId = zoneIndex and GetZoneId(zoneIndex)
    if not zoneId or zoneId == 0 then return end
    for _, pledge in ipairs(FPQ.pledges) do
        local normalZone = pledge.normalId and GetActivityZoneId(pledge.normalId)
        local veteranZone = pledge.veteranId and GetActivityZoneId(pledge.veteranId)
        if zoneId == normalZone or zoneId == veteranZone or zoneId == pledge.zoneId then
            if FOCUSED_QUEST_TRACKER and FOCUSED_QUEST_TRACKER.ForceAssist then
                FOCUSED_QUEST_TRACKER:ForceAssist(pledge.questIndex)
            elseif SetTrackedIsAssisted then
                SetTrackedIsAssisted(TRACK_TYPE_QUEST, true, pledge.questIndex)
            end
            return
        end
    end
end

function FPQ.HoldCursorMode()
    if SetGameCameraUIMode then SetGameCameraUIMode(true) end
end

function FPQ.Open()
    FPQ.CreateWindow()
    FPQ.cursorWasActive = IsGameCameraUIModeActive and IsGameCameraUIModeActive() or false
    FPQ.window:SetHidden(false)
    FPQ.Refresh()
    FPQ.RefreshQueueState()
    if IsCurrentlySearchingForGroup() then
        FPQ.SetStatus("Queued. Use Leave Queue to cancel the search.", COLORS.green)
    end
    FPQ.HoldCursorMode()
    FPQ.window:SetHandler("OnUpdate", function(_, time)
        if not FPQ.nextCursorCheck or time >= FPQ.nextCursorCheck then
            FPQ.nextCursorCheck = time + 0.1
            FPQ.HoldCursorMode()
        end
    end)
end

function FPQ.Close(forceCursorOff)
    if not FPQ.window then return end
    FPQ.window:SetHandler("OnUpdate", nil)
    FPQ.window:SetHidden(true)
    if SetGameCameraUIMode and (forceCursorOff or not FPQ.cursorWasActive) then
        SetGameCameraUIMode(false)
    end
end

function FPQ.CreateWindow()
    if FPQ.window then return end
    FPQ.selections = {}

    local window = WM:CreateTopLevelWindow("FlamechasersPledgeQueueWindow")
    window:SetDimensions(760, 730)
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.left, SV.top)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)
    window:SetDrawLevel(20)
    window:SetHandler("OnMoveStop", function()
        SV.left, SV.top = window:GetLeft(), window:GetTop()
    end)
    FPQ.window = window

    local background = Panel(window, "FlamechasersPledgeQueueBackdrop",
        { 0.018, 0.014, 0.026, 0.975 })
    background:SetAnchorFill(window)
    background:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Tooltip-Border.dds", 128, 16)
    background:SetInsets(4, 4, -4, -4)
    background:SetEdgeColor(0.27, 0.22, 0.31, 1)

    local header = Panel(window, "FlamechasersPledgeHeader", { 0.040, 0.030, 0.050, 1 })
    header:SetDimensions(752, 102)
    header:SetAnchor(TOP, window, TOP, 0, 4)
    local accent = WM:CreateControl("FlamechasersPledgeHeaderAccent", header, CT_TEXTURE)
    accent:SetDimensions(752, 3)
    accent:SetAnchor(BOTTOM, header, BOTTOM, 0, 0)
    accent:SetColor(unpack(COLORS.cyan))

    local title = Label(header, "FlamechasersPledgeTitle", "FLAMECHASERS", "ZoFontWinH1")
    SetColor(title, COLORS.cyan)
    title:SetAnchor(TOPLEFT, header, TOPLEFT, 24, 12)
    local subtitle = Label(header, "FlamechasersPledgeSubtitle", "PLEDGE QUEUE", "ZoFontWinH3")
    subtitle:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, -5)
    local tagline = Label(header, "FlamechasersPledgeTagline",
        "Your Undaunted contracts. One decisive queue.", "ZoFontGameSmall")
    SetColor(tagline, COLORS.muted)
    tagline:SetAnchor(LEFT, subtitle, RIGHT, 16, 1)
    local close = Button(header, "FlamechasersPledgeClose", "CLOSE", "ZoFontWinH3")
    close:SetDimensions(90, 42)
    close:SetAnchor(TOPRIGHT, header, TOPRIGHT, -14, 11)
    close:SetHandler("OnClicked", function() FPQ.Close() end)

    local roleHeading = Label(window, "FlamechasersPledgeRoleHeading",
        "PREFERRED ROLE", "ZoFontWinH3")
    SetColor(roleHeading, COLORS.muted)
    roleHeading:SetAnchor(TOPLEFT, window, TOPLEFT, 25, 118)
    local roleLine = WM:CreateControl("FlamechasersPledgeRoleLine", window, CT_TEXTURE)
    roleLine:SetDimensions(565, 1)
    roleLine:SetAnchor(LEFT, roleHeading, RIGHT, 15, 1)
    roleLine:SetColor(0.27, 0.22, 0.32, 0.8)

    local roleBar = WM:CreateControl("FlamechasersPledgeRoles", window, CT_CONTROL)
    roleBar:SetDimensions(710, 66)
    roleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 25, 148)
    FPQ.roleButtons = {}
    FPQ.CreateRole(roleBar, LFG_ROLE_TANK, 0, "TANK")
    FPQ.CreateRole(roleBar, LFG_ROLE_HEAL, 260, "HEALER")
    FPQ.CreateRole(roleBar, LFG_ROLE_DPS, 520, "DAMAGE")

    local function CreateModeButton(name, x, titleText, iconTexture, onClick)
        local control = WM:CreateControl(name, window, CT_BUTTON)
        control:SetDimensions(226, 50)
        control:SetAnchor(TOPLEFT, window, TOPLEFT, x, 588)
        local shadow = Panel(control, name .. "Shadow", { 0, 0, 0, 0.72 })
        shadow:SetDimensions(226, 50)
        shadow:SetAnchor(TOPLEFT, control, TOPLEFT, 5, 6)
        local background = Panel(control, name .. "Background", { 0.095, 0.070, 0.115, 1 })
        background:SetAnchorFill(control)
        local outline = CreateOutline(control, name .. "Outline", 226, 50, 2,
            COLORS.cyan)
        local icon = WM:CreateControl(name .. "Icon", control, CT_TEXTURE)
        icon:SetDimensions(30, 30)
        icon:SetAnchor(LEFT, control, LEFT, 14, 1)
        icon:SetTexture(iconTexture)
        local title = Label(control, name .. "Title", titleText, "ZoFontGameBold")
        title:SetDimensions(166, 34)
        title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        title:SetAnchor(LEFT, control, LEFT, 50, 1)
        control:SetHandler("OnMouseEnter", function()
            background:SetCenterColor(0.155, 0.115, 0.18, 1)
            SetOutlineColor(outline, { 0.72, 0.61, 0.80, 1 })
            shadow:SetCenterColor(0.08, 0.045, 0.10, 0.78)
            icon:SetAlpha(1)
        end)
        control:SetHandler("OnMouseExit", function()
            background:SetCenterColor(0.095, 0.070, 0.115, 1)
            SetOutlineColor(outline, COLORS.cyan)
            shadow:SetCenterColor(0, 0, 0, 0.72)
            icon:SetAlpha(0.88)
        end)
        control:SetHandler("OnMouseDown", function()
            background:SetCenterColor(0.065, 0.045, 0.075, 1)
            shadow:SetAlpha(0.28)
        end)
        control:SetHandler("OnMouseUp", function()
            background:SetCenterColor(0.155, 0.115, 0.18, 1)
            shadow:SetAlpha(1)
        end)
        control:SetHandler("OnClicked", onClick)
        control.title, control.shadow, control.outline = title, shadow, outline
        icon:SetAlpha(0.88)
        FPQ.modeButtons[#FPQ.modeButtons + 1] = control
        return control
    end

    FPQ.modeButtons = {}
    CreateModeButton("FlamechasersPledgeRandomNormal", 25,
        "RANDOM NORMAL",
        ZO_GetKeyboardDungeonDifficultyIcon(DUNGEON_DIFFICULTY_NORMAL),
        function() FPQ.QueueRandom(false) end)
    CreateModeButton("FlamechasersPledgeRandomVeteran", 267,
        "RANDOM VETERAN",
        ZO_GetKeyboardDungeonDifficultyIcon(DUNGEON_DIFFICULTY_VETERAN),
        function() FPQ.QueueRandom(true) end)
    FPQ.queueButton = CreateModeButton("FlamechasersPledgeQueueButton", 509,
        "QUEUE PLEDGES",
        "EsoUI/Art/Icons/mapKey/mapKey_groupInstance.dds",
        function() FPQ.QueueSelected() end)

    local pledgeHeading = Label(window, "FlamechasersPledgeListHeading",
        "ACTIVE PLEDGES", "ZoFontWinH3")
    SetColor(pledgeHeading, COLORS.muted)
    pledgeHeading:SetAnchor(TOPLEFT, window, TOPLEFT, 25, 228)

    FPQ.rows = {}
    for index = 1, 3 do
        local row = Panel(window, "FlamechasersPledgeRow" .. index,
            { 0.026, 0.019, 0.036, 0.94 })
        row:SetDimensions(710, 86)
        row:SetAnchor(TOPLEFT, window, TOPLEFT, 25, 258 + ((index - 1) * 94))
        local stripe = WM:CreateControl("FlamechasersPledgeRowStripe" .. index, row, CT_TEXTURE)
        stripe:SetDimensions(5, 86)
        stripe:SetAnchor(LEFT, row, LEFT, 0, 0)
        stripe:SetColor(unpack(COLORS.cyan))
        local number = Label(row, "FlamechasersPledgeRowNumber" .. index,
            string.format("%02d", index), "ZoFontGameBold")
        SetColor(number, COLORS.cyan)
        number:SetAnchor(TOPRIGHT, row, TOPRIGHT, -13, 8)
        local icon = WM:CreateControl("FlamechasersPledgeRowIcon" .. index, row, CT_TEXTURE)
        icon:SetDimensions(42, 42)
        icon:SetAnchor(LEFT, row, LEFT, 18, 0)
        icon:SetTexture("EsoUI/Art/Icons/mapKey/mapKey_groupInstance.dds")
        local name = Label(row, "FlamechasersPledgeRowName" .. index, "", "ZoFontWinH3")
        name:SetDimensions(305, 30)
        name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        name:SetAnchor(TOPLEFT, row, TOPLEFT, 76, 13)
        local quest = Label(row, "FlamechasersPledgeRowQuest" .. index, "", "ZoFontGameSmall")
        SetColor(quest, COLORS.muted)
        quest:SetDimensions(305, 24)
        quest:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        quest:SetAnchor(TOPLEFT, name, BOTTOMLEFT, 0, 2)
        local normal = FPQ.CreateCheck(row,
            "FlamechasersPledgeNormal" .. index, "NORMAL", "normal")
        normal:SetAnchor(RIGHT, row, RIGHT, -169, 0)
        local veteran = FPQ.CreateCheck(row,
            "FlamechasersPledgeVeteran" .. index, "VETERAN", "veteran")
        veteran:SetAnchor(RIGHT, row, RIGHT, -19, 0)
        row.name, row.quest, row.normal, row.veteran = name, quest, normal, veteran
        FPQ.rows[index] = row
    end

    FPQ.empty = Label(window, "FlamechasersPledgeEmpty",
        "No active Undaunted pledges found.\nPick up a daily pledge, then reopen or refresh.",
        "ZoFontWinH3")
    FPQ.empty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    FPQ.empty:SetDimensions(600, 70)
    FPQ.empty:SetAnchor(CENTER, window, CENTER, 0, 35)
    SetColor(FPQ.empty, COLORS.muted)

    local modeHeading = Label(window, "FlamechasersPledgeModeHeading",
        "START QUEUE  •  CHOOSE ONE ACTION", "ZoFontWinH3")
    SetColor(modeHeading, COLORS.muted)
    modeHeading:SetAnchor(TOPLEFT, window, TOPLEFT, 25, 546)

    local footer = Panel(window, "FlamechasersPledgeFooter", { 0.040, 0.021, 0.055, 1 })
    footer:SetDimensions(752, 62)
    footer:SetAnchor(BOTTOM, window, BOTTOM, 0, -4)
    FPQ.status = Label(footer, "FlamechasersPledgeStatus", "", "ZoFontGameSmall")
    FPQ.status:SetDimensions(475, 38)
    FPQ.status:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    FPQ.status:SetAnchor(LEFT, footer, LEFT, 20, 0)
    FPQ.leaveButton = Button(footer, "FlamechasersPledgeLeaveButton",
        "LEAVE QUEUE", "ZoFontWinH3")
    FPQ.leaveButton:SetDimensions(210, 48)
    FPQ.leaveButton:SetAnchor(RIGHT, footer, RIGHT, -14, 0)
    FPQ.leaveButton:SetNormalFontColor(unpack(COLORS.red))
    FPQ.leaveButton:SetMouseOverFontColor(1, 0.68, 0.68, 1)
    FPQ.leaveButton:SetText("")
    local leaveShadow = Panel(FPQ.leaveButton, "FlamechasersPledgeLeaveShadow",
        { 0, 0, 0, 0.68 })
    leaveShadow:SetDimensions(210, 48)
    leaveShadow:SetAnchor(TOPLEFT, FPQ.leaveButton, TOPLEFT, 4, 5)
    local leaveBackground = Panel(FPQ.leaveButton, "FlamechasersPledgeLeaveBackground",
        { 0.10, 0.018, 0.025, 0.94 })
    leaveBackground:SetAnchorFill(FPQ.leaveButton)
    local leaveOutline = CreateOutline(FPQ.leaveButton, "FlamechasersPledgeLeaveOutline",
        210, 48, 2, { 0.62, 0.15, 0.19, 0.90 })
    local leaveLabel = Label(FPQ.leaveButton, "FlamechasersPledgeLeaveLabel",
        "LEAVE QUEUE", "ZoFontWinH3")
    SetColor(leaveLabel, COLORS.red)
    leaveLabel:SetAnchor(CENTER, FPQ.leaveButton, CENTER, 0, 0)
    FPQ.leaveButton:SetHandler("OnMouseEnter", function()
        leaveBackground:SetCenterColor(0.20, 0.03, 0.04, 1)
        SetOutlineColor(leaveOutline, { 1, 0.35, 0.38, 1 })
        leaveShadow:SetCenterColor(0.22, 0.02, 0.035, 0.82)
        leaveLabel:SetColor(1, 0.68, 0.68, 1)
    end)
    FPQ.leaveButton:SetHandler("OnMouseExit", function()
        leaveBackground:SetCenterColor(0.10, 0.018, 0.025, 0.94)
        SetOutlineColor(leaveOutline, { 0.62, 0.15, 0.19, 0.90 })
        leaveShadow:SetCenterColor(0, 0, 0, 0.68)
        SetColor(leaveLabel, COLORS.red)
    end)
    FPQ.leaveButton:SetHandler("OnClicked", function() FPQ.LeaveQueue() end)

    FPQ.Refresh()
    FPQ.RefreshQueueState()
end

function FPQ.Toggle()
    FPQ.CreateWindow()
    if FPQ.window:IsHidden() then FPQ.Open() else FPQ.Close() end
end

function FPQ.OnQuestChanged()
    if FPQ.window and not FPQ.window:IsHidden() then
        zo_callLater(function() FPQ.Refresh() end, 150)
    end
end

function FPQ.OnPlayerActivated()
    FPQ.BuildActivityCatalog()
    zo_callLater(function()
        FPQ.AssistMatchingPledge()
        if FPQ.window and not FPQ.window:IsHidden() then FPQ.Refresh() end
    end, 700)
end

function FPQ.OnActivityFinderStatusUpdate()
    zo_callLater(function()
        FPQ.RefreshQueueState()
        if FPQ.window and not FPQ.window:IsHidden() then
            if IsCurrentlySearchingForGroup() then
                FPQ.SetStatus("Queued. Use Leave Queue to cancel the search.", COLORS.green)
            else
                FPQ.SetStatus("Queue is idle. Choose one queue mode.", COLORS.muted)
            end
        end
    end, 100)
end

local function InitializeSavedVariables()
    -- Read the pre-0.7.8 "Default" namespace directly for migration only.
    -- The active SavedVars wrapper below is always server-aware.
    local root = rawget(_G, SAVED_VARIABLES_NAME)
    local defaultNamespace = root and root["Default"]
    local accountName = GetDisplayName and GetDisplayName()
    local accountData = accountName and defaultNamespace and defaultNamespace[accountName]
    local legacy = accountData and accountData["$AccountWide"]
    local defaults = {
        left = 430,
        top = 170,
        serverDataInitialized = false,
    }
    local worldName = GetWorldName and GetWorldName() or "Default"
    SV = ZO_SavedVars:NewAccountWide(
        SAVED_VARIABLES_NAME, SAVED_VARIABLES_VERSION, worldName, defaults)

    if not SV.serverDataInitialized then
        if legacy then
            SV.left = legacy.left or SV.left
            SV.top = legacy.top or SV.top
        end
        SV.serverDataInitialized = true
    end
end

function FPQ.Initialize()
    InitializeSavedVariables()

    ZO_CreateStringId("SI_BINDING_NAME_FLAMECHASERS_CATEGORY", "Flamechasers")
    ZO_CreateStringId("SI_BINDING_NAME_FLAMECHASERS_PLEDGE_TOGGLE", "Open/Close Pledge Queue")
    SLASH_COMMANDS["/fpq"] = function() FPQ.Toggle() end
    SLASH_COMMANDS["/fpledge"] = function() FPQ.Toggle() end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED,
        function() FPQ.OnPlayerActivated() end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_ADDED,
        function() FPQ.OnQuestChanged() end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_REMOVED,
        function() FPQ.OnQuestChanged() end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_ADVANCED,
        function() FPQ.OnQuestChanged() end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACTIVITY_FINDER_STATUS_UPDATE,
        function() FPQ.OnActivityFinderStatusUpdate() end)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    FPQ.Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
