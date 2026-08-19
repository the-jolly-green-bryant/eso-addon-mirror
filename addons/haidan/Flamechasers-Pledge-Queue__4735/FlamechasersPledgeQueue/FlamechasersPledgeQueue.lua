FlamechasersPledgeQueue = {}
local FPQ = FlamechasersPledgeQueue
local WM = WINDOW_MANAGER
local ADDON_NAME = "FlamechasersPledgeQueue"
FPQ.version = "0.7.18"
local SAVED_VARIABLES_NAME = "FlamechasersPledgeQueueSavedVariables"
-- Keep the wrapper version unchanged so existing data is never reset merely
-- because the active namespace is now server-specific.
local SAVED_VARIABLES_VERSION = 3
local SV

-- Bindings.xml is loaded after this file. Register these labels now so the
-- shared category already exists when ESO parses the binding definitions.
if _G["SI_BINDING_NAME_FLAMECHASERS_CATEGORY"] == nil then
    ZO_CreateStringId("SI_BINDING_NAME_FLAMECHASERS_CATEGORY", "Flamechasers")
end
ZO_CreateStringId("SI_BINDING_NAME_FLAMECHASERS_PLEDGE_TOGGLE", "Open/Close Pledge Queue")

local COLORS = {
    cyan = { 0.60, 0.48, 0.70, 1 },
    white = { 0.95, 0.94, 0.98, 1 },
    muted = { 0.59, 0.56, 0.65, 1 },
    green = { 0.35, 0.84, 0.58, 1 },
    red = { 1.00, 0.38, 0.40, 1 },
}

local ROLE_NAMES = {
    [LFG_ROLE_TANK] = "TANK",
    [LFG_ROLE_HEAL] = "HEALER",
    [LFG_ROLE_DPS] = "DAMAGE",
}

local function RoleName(role)
    return ROLE_NAMES[role] or "UNKNOWN ROLE"
end

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

-- ESO occasionally includes a leading word in an Activity Finder name that
-- is omitted from the corresponding localized pledge title. Keep the exact
-- localized match as the primary path, then expose one conservative alias
-- without that first word. This handles names such as Banished Cells without
-- hardcoding any language-specific article.
local function NormalizeWithoutFirstWord(text)
    text = zo_strformat("<<C:1>>", text or "")
    text = zo_strlower(text)
    text = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    local _, firstWordEnd = text:find("^%s*%S+")
    if not firstWordEnd then return "" end
    local aliasKey = Normalize(text:sub(firstWordEnd + 1))
    return #aliasKey >= 8 and aliasKey or ""
end

local function SafeActivityInfo(activityId)
    if not activityId then return nil end
    local name = GetActivityInfo(activityId)
    if name ~= "" then return zo_strformat("<<C:1>>", name) end
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
                    entry = {
                        key = key,
                        aliasKey = NormalizeWithoutFirstWord(name),
                        name = name,
                    }
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

local function GetActivityArtwork(activity)
    if activity.artTexture == false then return nil end
    if activity.artTexture then return activity.artTexture end

    local activityId = activity.normalId or activity.veteranId
    if not activityId then
        activity.artTexture = false
        return nil
    end

    local smallTexture, largeTexture =
        GetActivityKeyboardDescriptionTextures(activityId)
    if smallTexture and smallTexture ~= "" then
        activity.artTexture = smallTexture
    elseif largeTexture and largeTexture ~= "" then
        activity.artTexture = largeTexture
    else
        activity.artTexture = false
    end
    return activity.artTexture or nil
end

function FPQ.FindPledges()
    if not FPQ.activityList then FPQ.BuildActivityCatalog() end
    local pledges, used = {}, {}

    for questIndex = 1, MAX_JOURNAL_QUESTS do
        local questName = GetJournalQuestName(questIndex)
        if questName ~= "" then
            local isPledge = GetJournalQuestType(questIndex)
                == QUEST_TYPE_UNDAUNTED_PLEDGE
            if isPledge then
                local normalizedQuest = Normalize(questName)
                for _, activity in ipairs(FPQ.activityList) do
                    if not used[activity.key]
                        and (normalizedQuest:find(activity.key, 1, true)
                            or (activity.aliasKey ~= ""
                                and normalizedQuest:find(
                                    activity.aliasKey, 1, true))) then
                        pledges[#pledges + 1] = {
                            key = activity.key,
                            name = activity.name,
                            questName = questName,
                            questIndex = questIndex,
                            normalId = activity.normalId,
                            veteranId = activity.veteranId,
                            zoneId = activity.zoneId,
                            artTexture = GetActivityArtwork(activity),
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
    hit:SetDrawLayer(DL_OVERLAY)
    hit:SetDrawLevel(30)

    local pill = Panel(hit, name .. "Pill", { 0.026, 0.020, 0.036, 0.98 })
    pill:SetAnchorFill(hit)
    pill:SetDrawLayer(DL_OVERLAY)
    pill:SetDrawLevel(31)
    pill:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Tooltip-Border.dds", 128, 8)
    pill:SetInsets(2, 2, -2, -2)
    pill:SetEdgeColor(0.27, 0.22, 0.34, 1)

    local indicator = WM:CreateControl(name .. "Indicator", hit, CT_TEXTURE)
    indicator:SetDimensions(22, 22)
    indicator:SetAnchor(LEFT, hit, LEFT, 13, 0)
    indicator:SetTexture("EsoUI/Art/Buttons/checkbox_unchecked.dds")
    indicator:SetDrawLayer(DL_OVERLAY)
    indicator:SetDrawLevel(32)

    local text = Label(hit, name .. "Text", labelText, "ZoFontGameBold")
    text:SetAnchor(LEFT, indicator, RIGHT, 10, 0)
    text:SetDrawLayer(DL_OVERLAY)
    text:SetDrawLevel(32)

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

    local selected = WM:CreateControl("FlamechasersPledgeRoleSelected" .. role,
        button, CT_TEXTURE)
    selected:SetDimensions(18, 18)
    selected:SetAnchor(TOPRIGHT, button, TOPRIGHT, -10, 9)
    selected:SetTexture("EsoUI/Art/Buttons/checkbox_checked.dds")
    selected:SetColor(unpack(COLORS.cyan))
    selected:SetHidden(true)

    button.role, button.background, button.outline, button.accent, button.icon,
        button.label, button.selected = role, background, outline, accent, icon,
        label, selected
    button:SetHandler("OnMouseEnter", function(control)
        if control.canUpdate and not control.active then
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
    -- Remember the player's explicit choice even if ESO refuses the update.
    -- This prevents a queue from silently starting with the previous role.
    FPQ.expectedRole = role
    if not CanUpdateSelectedLFGRole() then
        FPQ.RefreshRoles()
        FPQ.SetStatus("Your preferred role cannot be changed right now.", COLORS.red)
        return false
    end
    UpdateSelectedLFGRole(role)
    ZO_ACTIVITY_FINDER_ROOT_MANAGER:UpdateLocationData()
    local actualRole = GetSelectedLFGRole()
    -- Our button does not pass through ESO's own preferred-role radio group,
    -- so refresh that manager explicitly to keep the original group UI in sync.
    PREFERRED_ROLES:RefreshRoles()
    FPQ.RefreshRoles()
    if actualRole ~= role then
        FPQ.SetStatus("ESO did not apply the selected role. Queue was not changed.",
            COLORS.red)
        return false
    end
    PREFERRED_ROLES:FireCallbacks("LFGRoleChanged")
    FPQ.SetStatus("Queue role set to " .. RoleName(actualRole) .. ".", COLORS.green)
    return true
end

function FPQ.RefreshRoles()
    if not FPQ.roleButtons then return end
    local selected = GetSelectedLFGRole()
    local canUpdate = CanUpdateSelectedLFGRole()
    for role, button in pairs(FPQ.roleButtons) do
        local active = role == selected
        button.active, button.canUpdate = active, canUpdate
        button:SetMouseEnabled(canUpdate)
        button.background:SetCenterColor(
            active and 0.075 or 0.025,
            active and 0.055 or 0.019,
            active and 0.090 or 0.035,
            0.96)
        SetOutlineColor(button.outline,
            active and COLORS.cyan or { 0.24, 0.21, 0.29, 0.85 })
        button.accent:SetAlpha(active and 1 or 0.16)
        button.icon:SetAlpha(canUpdate and (active and 1 or 0.48)
            or (active and 0.62 or 0.24))
        button.label:SetAlpha(canUpdate and (active and 1 or 0.58)
            or (active and 0.68 or 0.30))
        button.selected:SetHidden(not active)
        button.selected:SetAlpha(canUpdate and 1 or 0.58)
        button:SetAlpha(canUpdate and 1 or (active and 0.72 or 0.48))
    end

    if FPQ.roleSummary then
        local roleText = RoleName(selected)
        if selected == LFG_ROLE_INVALID then
            FPQ.roleSummary:SetText("NO ROLE SELECTED")
            SetColor(FPQ.roleSummary, COLORS.red)
        elseif FPQ.expectedRole and selected ~= FPQ.expectedRole then
            FPQ.roleSummary:SetText("ROLE MISMATCH  •  ESO: " .. roleText)
            SetColor(FPQ.roleSummary, COLORS.red)
        elseif canUpdate then
            FPQ.roleSummary:SetText("QUEUE ROLE  •  " .. roleText)
            SetColor(FPQ.roleSummary, COLORS.cyan)
        else
            FPQ.roleSummary:SetText("ROLE LOCKED  •  " .. roleText)
            SetColor(FPQ.roleSummary, COLORS.muted)
        end
    end
end

function FPQ.VerifyQueueRole()
    local actualRole = GetSelectedLFGRole()
    local expectedRole = FPQ.expectedRole or actualRole
    if actualRole == LFG_ROLE_INVALID then
        FPQ.RefreshRoles()
        FPQ.SetStatus("Select a valid group role before queueing.", COLORS.red)
        return nil
    end
    if actualRole ~= expectedRole then
        FPQ.RefreshRoles()
        FPQ.SetStatus("ESO's active role is " .. RoleName(actualRole)
            .. ". Select the intended role again before queueing.", COLORS.red)
        return nil
    end
    return actualRole
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
            if pledge.artTexture then
                row.art:SetTexture(pledge.artTexture)
                row.art:SetHidden(false)
                row.artShade:SetHidden(false)
            else
                row.art:SetHidden(true)
                row.artShade:SetHidden(true)
            end
            row.name:SetText(pledge.name)
            row.quest:SetText(pledge.questName)
            local selection = FPQ.GetSelection(pledge.key)
            row.normal.pledge, row.normal.activityId = pledge, pledge.normalId
            row.veteran.pledge, row.veteran.activityId = pledge, pledge.veteranId
            FPQ.UpdateCheck(row.normal, selection.normal, pledge.normalId ~= nil)
            FPQ.UpdateCheck(row.veteran, selection.veteran, pledge.veteranId ~= nil)
        else
            row.art:SetHidden(true)
            row.artShade:SetHidden(true)
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
    local queued = IsCurrentlySearchingForGroup()
    FPQ.queueButton:SetAlpha(queued and 0.25 or (count > 0 and 1 or 0.42))
end

function FPQ.CanStartQueue()
    if IsCurrentlySearchingForGroup() then
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
    local queueRole = FPQ.VerifyQueueRole()
    if not queueRole then
        ClearActivityFinderSearch()
        return false
    end
    local result = StartActivityFinderSearch()
    if result == ACTIVITY_QUEUE_RESULT_SUCCESS then
        FPQ.SetStatus("Queue started as " .. RoleName(queueRole) .. ".", COLORS.green)
        FPQ.RefreshQueueState()
        FPQ.Close(true)
        return true
    end
    ZO_AlertEvent(EVENT_ACTIVITY_QUEUE_RESULT, result)
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
            FOCUSED_QUEST_TRACKER:ForceAssist(pledge.questIndex)
            return
        end
    end
end

function FPQ.HoldCursorMode()
    SetGameCameraUIMode(true)
end

function FPQ.Open()
    FPQ.CreateWindow()
    FPQ.cursorWasActive = IsGameCameraUIModeActive()
    FPQ.expectedRole = GetSelectedLFGRole()
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
    if forceCursorOff or not FPQ.cursorWasActive then
        SetGameCameraUIMode(false)
    end
end

function FPQ.CreateWindow()
    if FPQ.window then return end
    FPQ.selections = {}

    local window = WM:CreateTopLevelWindow("FlamechasersPledgeQueueWindow")
    window:SetDimensions(760, 686)
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
        { 0.018, 0.014, 0.026, 1 })
    background:SetAnchorFill(window)
    background:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Tooltip-Border.dds", 128, 16)
    background:SetInsets(4, 4, -4, -4)
    background:SetEdgeColor(0.27, 0.22, 0.31, 1)

    -- The tooltip texture is translucent by design. This independent layer
    -- keeps the game world from competing with the queue controls.
    local opacityLayer = WM:CreateControl("FlamechasersPledgeOpacityLayer",
        window, CT_BACKDROP)
    opacityLayer:SetAnchor(TOPLEFT, window, TOPLEFT, 8, 8)
    opacityLayer:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -8, -8)
    opacityLayer:SetCenterColor(0.008, 0.005, 0.012, 0.54)
    opacityLayer:SetEdgeColor(0, 0, 0, 0)

    -- The visible backdrop begins four pixels inside the top-level control.
    -- Frame that real edge so no transparent gap surrounds the interface.
    local strokeFrame = WM:CreateControl(
        "FlamechasersPledgeWindowStrokeFrame", window, CT_CONTROL)
    strokeFrame:SetDimensions(752, 678)
    strokeFrame:SetAnchor(TOPLEFT, window, TOPLEFT, 4, 4)
    local windowStroke = CreateOutline(
        strokeFrame, "FlamechasersPledgeWindowStroke",
        752, 678, 2, { 0.60, 0.48, 0.70, 0.84 })
    for _, line in ipairs(windowStroke) do
        line:SetDrawLayer(DL_OVERLAY)
        line:SetDrawLevel(250)
    end

    local header = Panel(window, "FlamechasersPledgeHeader", { 0.040, 0.030, 0.050, 1 })
    header:SetDimensions(752, 58)
    header:SetAnchor(TOP, window, TOP, 0, 4)
    local accent = WM:CreateControl("FlamechasersPledgeHeaderAccent", header, CT_TEXTURE)
    accent:SetDimensions(752, 3)
    accent:SetAnchor(BOTTOM, header, BOTTOM, 0, 0)
    accent:SetColor(unpack(COLORS.cyan))

    local title = Label(header, "FlamechasersPledgeTitle", "FLAMECHASERS", "ZoFontGameSmall")
    SetColor(title, COLORS.cyan)
    title:SetAnchor(TOPLEFT, header, TOPLEFT, 18, 7)
    local subtitle = Label(header, "FlamechasersPledgeSubtitle", "PLEDGE QUEUE", "ZoFontGameBold")
    subtitle:SetAnchor(TOPLEFT, header, TOPLEFT, 18, 25)
    local tagline = Label(header, "FlamechasersPledgeTagline",
        "Your Undaunted contracts. One decisive queue.", "ZoFontGameSmall")
    SetColor(tagline, COLORS.muted)
    tagline:SetAnchor(LEFT, subtitle, RIGHT, 14, 0)
    local close = Button(header, "FlamechasersPledgeClose", "X", "ZoFontGameBold")
    close:SetDimensions(32, 32)
    close:SetAnchor(TOPRIGHT, header, TOPRIGHT, -12, 13)
    close:SetHandler("OnClicked", function() FPQ.Close() end)

    local roleHeading = Label(window, "FlamechasersPledgeRoleHeading",
        "PREFERRED ROLE", "ZoFontWinH3")
    SetColor(roleHeading, COLORS.muted)
    roleHeading:SetAnchor(TOPLEFT, window, TOPLEFT, 25, 74)
    local roleLine = WM:CreateControl("FlamechasersPledgeRoleLine", window, CT_TEXTURE)
    roleLine:SetDimensions(270, 1)
    roleLine:SetAnchor(LEFT, roleHeading, RIGHT, 15, 1)
    roleLine:SetColor(0.27, 0.22, 0.32, 0.8)

    FPQ.roleSummary = Label(window, "FlamechasersPledgeRoleSummary", "", "ZoFontGameSmall")
    FPQ.roleSummary:SetDimensions(255, 24)
    FPQ.roleSummary:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    FPQ.roleSummary:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    FPQ.roleSummary:SetAnchor(TOPRIGHT, window, TOPRIGHT, -25, 72)

    local roleBar = WM:CreateControl("FlamechasersPledgeRoles", window, CT_CONTROL)
    roleBar:SetDimensions(710, 66)
    roleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 25, 104)
    FPQ.roleButtons = {}
    FPQ.CreateRole(roleBar, LFG_ROLE_TANK, 0, "TANK")
    FPQ.CreateRole(roleBar, LFG_ROLE_HEAL, 260, "HEALER")
    FPQ.CreateRole(roleBar, LFG_ROLE_DPS, 520, "DAMAGE")

    local function CreateModeButton(name, x, titleText, iconTexture, onClick)
        local control = WM:CreateControl(name, window, CT_BUTTON)
        control:SetDimensions(226, 50)
        control:SetAnchor(TOPLEFT, window, TOPLEFT, x, 544)
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
    pledgeHeading:SetAnchor(TOPLEFT, window, TOPLEFT, 25, 184)

    FPQ.rows = {}
    for index = 1, 3 do
        local row = Panel(window, "FlamechasersPledgeRow" .. index,
            { 0.026, 0.019, 0.036, 0.94 })
        row:SetDimensions(710, 86)
        row:SetAnchor(TOPLEFT, window, TOPLEFT, 25, 214 + ((index - 1) * 94))
        row:SetDrawLayer(DL_BACKGROUND)
        row:SetDrawLevel(0)

        -- ESO already exposes Activity Finder art for every dungeon. Reuse
        -- that client texture as a cropped, darkened card background instead
        -- of bundling image files or decoding artwork ourselves.
        local art = WM:CreateControl(
            "FlamechasersPledgeRowArt" .. index, row, CT_TEXTURE)
        -- Activity Finder's small keyboard artwork lives inside a padded
        -- atlas. ESO's own tooltip template crops that atlas at u=0.6836.
        -- Use the same right edge, then take a wide central slice so the art
        -- fills this card without distortion or transparent padding.
        art:SetResizeToFitFile(false)
        art:SetDimensions(710, 86)
        art:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
        art:SetTextureCoords(0, 0.6836, 0.41, 0.575)
        art:SetColor(0.62, 0.56, 0.68, 0.56)
        art:SetDrawLayer(DL_BACKGROUND)
        art:SetDrawLevel(1)
        art:SetHidden(true)

        -- A real colorable texture is required for the gradient to render.
        -- Fade the full-width artwork into the card's near-black base while
        -- keeping the entire overlay below labels and checkbox controls.
        local artShade = WM:CreateControl(
            "FlamechasersPledgeRowArtShade" .. index, row, CT_TEXTURE)
        artShade:SetResizeToFitFile(false)
        artShade:SetDimensions(710, 86)
        artShade:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
        artShade:SetTexture("EsoUI/Art/Miscellaneous/listItem_backdrop_white.dds")
        artShade:SetTextureCoords(0, 1, 0, 1)
        artShade:SetGradientColors(ORIENTATION_HORIZONTAL,
            0.008, 0.005, 0.012, 0.20,
            0.008, 0.005, 0.012, 0.92)
        artShade:SetDrawLayer(DL_BACKGROUND)
        artShade:SetDrawLevel(2)
        artShade:SetHidden(true)

        CreateOutline(row, "FlamechasersPledgeRowOutline" .. index,
            710, 86, 1, { 0.18, 0.14, 0.22, 0.82 })
        local highlight = WM:CreateControl("FlamechasersPledgeRowHighlight" .. index,
            row, CT_TEXTURE)
        highlight:SetDimensions(699, 1)
        highlight:SetAnchor(TOPRIGHT, row, TOPRIGHT, -1, 1)
        highlight:SetColor(0.45, 0.35, 0.53, 0.26)
        local stripe = WM:CreateControl("FlamechasersPledgeRowStripe" .. index, row, CT_TEXTURE)
        stripe:SetDimensions(5, 86)
        stripe:SetAnchor(LEFT, row, LEFT, 0, 0)
        stripe:SetColor(unpack(COLORS.cyan))
        local numberPlate = Panel(row, "FlamechasersPledgeRowNumberPlate" .. index,
            { 0.060, 0.042, 0.073, 0.96 })
        numberPlate:SetDimensions(36, 24)
        numberPlate:SetAnchor(TOPRIGHT, row, TOPRIGHT, -8, 7)
        local number = Label(numberPlate, "FlamechasersPledgeRowNumber" .. index,
            string.format("%02d", index), "ZoFontGameBold")
        SetColor(number, COLORS.cyan)
        number:SetAnchor(CENTER, numberPlate, CENTER, 0, 0)
        local icon = WM:CreateControl("FlamechasersPledgeRowIcon" .. index, row, CT_TEXTURE)
        icon:SetDimensions(42, 42)
        icon:SetAnchor(LEFT, row, LEFT, 18, 0)
        icon:SetTexture("EsoUI/Art/Icons/mapKey/mapKey_groupInstance.dds")
        local name = Label(row, "FlamechasersPledgeRowName" .. index, "", "ZoFontWinH3")
        name:SetDimensions(280, 30)
        name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        name:SetAnchor(TOPLEFT, row, TOPLEFT, 76, 13)
        local quest = Label(row, "FlamechasersPledgeRowQuest" .. index, "", "ZoFontGameSmall")
        SetColor(quest, COLORS.muted)
        quest:SetDimensions(280, 24)
        quest:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        quest:SetAnchor(TOPLEFT, name, BOTTOMLEFT, 0, 2)
        local normal = FPQ.CreateCheck(row,
            "FlamechasersPledgeNormal" .. index, "NORMAL", "normal")
        normal:SetAnchor(RIGHT, row, RIGHT, -205, 0)
        local veteran = FPQ.CreateCheck(row,
            "FlamechasersPledgeVeteran" .. index, "VETERAN", "veteran")
        veteran:SetAnchor(RIGHT, row, RIGHT, -55, 0)
        row.art, row.artShade = art, artShade
        row.name, row.quest = name, quest
        row.normal, row.veteran = normal, veteran
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
    modeHeading:SetAnchor(TOPLEFT, window, TOPLEFT, 25, 502)

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
            FPQ.RefreshRoles()
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
    local accountName = GetDisplayName()
    local accountData = defaultNamespace and defaultNamespace[accountName]
    local legacy = accountData and accountData["$AccountWide"]
    local defaults = {
        left = 430,
        top = 170,
        serverDataInitialized = false,
    }
    local worldName = GetWorldName()
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
