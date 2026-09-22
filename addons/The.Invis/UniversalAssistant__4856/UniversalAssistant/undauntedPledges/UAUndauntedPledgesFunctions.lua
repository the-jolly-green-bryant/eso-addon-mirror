local ua = UAssistant
local pledges = {}
ua.UndauntedPledges = pledges

local function L(key)
    return ua.GetString(key)
end

function pledges.GetTargets()
    local library = LibUndauntedPledges
    local root = ZO_ACTIVITY_FINDER_ROOT_MANAGER
    local targets, accepted = {}, 0
    if not library or not library.LookupIds then
        return targets, accepted, "PLEDGES_MISSING_LIBRARY"
    end
    local activityIds = {}
    for index = 1, MAX_JOURNAL_QUESTS do
        if IsValidQuestIndex(index) then
            local questId = GetJournalQuestId(index)
            local _, pledgeQuestId, _, veteranId = library.LookupIds(questId, library.TYPE_QUEST)
            if pledgeQuestId and pledgeQuestId ~= 0 and veteranId and veteranId ~= 0 then
                accepted = accepted + 1
                activityIds[veteranId] = true
            end
        end
    end

    for _, location in ipairs(root:GetLocationsData(LFG_ACTIVITY_MASTER_DUNGEON) or {}) do
        if
            activityIds[location:GetId()]
            and location:IsActive()
            and not location:IsLocked()
            and location:GetEntryType() == ZO_ACTIVITY_FINDER_LOCATION_ENTRY_TYPE.SPECIFIC
        then
            targets[#targets + 1] = location
        end
    end
    local reason
    if accepted == 0 then
        reason = "PLEDGES_NO_QUESTS"
    elseif #targets == 0 then
        reason = "PLEDGES_UNAVAILABLE"
    end
    return targets, accepted, reason
end

local function IsSearching()
    return IsCurrentlySearchingForGroup() or ZO_ACTIVITY_FINDER_ROOT_MANAGER:GetIsCurrentlyInQueue()
end

function pledges.ApplyTargets(targets)
    if pledges.applying or IsSearching() or #targets == 0 then
        return false
    end
    pledges.applying = true
    local finder = DUNGEON_FINDER_KEYBOARD
    local selectedSpecific = finder.filterComboBox:SetSelectedItemByEval(function(entry)
        return entry.data and entry.data.singular == false
    end)
    if selectedSpecific then
        local root = ZO_ACTIVITY_FINDER_ROOT_MANAGER
        root:ClearSelections()
        for _, location in ipairs(targets) do
            root:SetLocationSelected(location, true)
        end
        finder:RefreshView()
    end
    pledges.applying = false
    return selectedSpecific
end

function pledges.Refresh()
    if not pledges.control or pledges.applying then
        return
    end
    local finder = DUNGEON_FINDER_KEYBOARD
    local showing = finder.fragment:IsShowing()
    pledges.control:SetHidden(not showing)
    if not showing then
        return
    end
    local targets, _, reason = pledges.GetTargets()
    if IsSearching() then
        reason = "PLEDGES_IN_QUEUE"
    end
    pledges.available = reason == nil
    pledges.tooltipKey = reason or "PLEDGES_SELECT_TOOLTIP"
    if reason and not IsSearching() then
        if pledges.selected then
            pledges.applying = true
            ZO_ACTIVITY_FINDER_ROOT_MANAGER:ClearSelections()
            pledges.applying = false
            finder:RefreshView()
        end
        pledges.selected = false
    elseif pledges.selected and not IsSearching() then
        pledges.selected = pledges.ApplyTargets(targets) or false
    end
    ZO_CheckButton_SetCheckState(pledges.check, pledges.selected == true)
    ZO_CheckButton_SetEnableState(pledges.check, pledges.available)
end

function pledges.Initialize()
    if pledges.initialized then
        return
    end
    local finder = DUNGEON_FINDER_KEYBOARD
    local status = ZO_SearchingForGroup and ZO_SearchingForGroup:GetNamedChild("Status")
    if not finder or not status then
        return
    end
    pledges.initialized = true
    local control =
        WINDOW_MANAGER:CreateControl("UAUndauntedPledges", ZO_GroupMenu_Keyboard, CT_CONTROL)
    control:SetDimensions(280, 30)
    control:SetAnchor(BOTTOMLEFT, status, TOPLEFT, -15, -12)
    control:SetMouseEnabled(true)
    control:SetHidden(true)
    pledges.control = control
    local check = CreateControlFromVirtual("UAUndauntedPledgesCheck", control, "ZO_CheckButton")
    check:SetAnchor(LEFT, control, LEFT, 0, 0)
    ZO_CheckButton_SetLabelText(check, L("UNDAUNTED_PLEDGES"))
    pledges.check = check
    pledges.label = check.label
    pledges.label:SetFont("ZoFontGame")
    ZO_CheckButton_SetToggleFunction(check, function(_, checked)
        if not pledges.available or IsSearching() then
            pledges.Refresh()
            return
        end
        if checked then
            pledges.selected = pledges.ApplyTargets(pledges.GetTargets()) or false
        else
            pledges.selected = false
            pledges.applying = true
            ZO_ACTIVITY_FINDER_ROOT_MANAGER:ClearSelections()
            finder:RefreshView()
            pledges.applying = false
        end
        pledges.Refresh()
    end)
    local function ShowTooltip()
        InitializeTooltip(InformationTooltip, control, TOP)
        InformationTooltip:AddLine(L(pledges.tooltipKey or "PLEDGES_SELECT_TOOLTIP"))
    end
    local function HideTooltip()
        ClearTooltip(InformationTooltip)
    end

    control:SetHandler("OnMouseEnter", ShowTooltip)
    control:SetHandler("OnMouseExit", HideTooltip)
    ZO_PreHookHandler(check, "OnMouseEnter", ShowTooltip)
    ZO_PreHookHandler(check, "OnMouseExit", HideTooltip)
    local function ScheduleRefresh()
        if pledges.applying then
            return
        end
        EVENT_MANAGER:UnregisterForUpdate("UAUndauntedPledgesRefresh")
        EVENT_MANAGER:RegisterForUpdate("UAUndauntedPledgesRefresh", 50, function()
            EVENT_MANAGER:UnregisterForUpdate("UAUndauntedPledgesRefresh")
            pledges.Refresh()
        end)
    end
    finder.fragment:RegisterCallback("StateChange", function(_, state)
        if state == SCENE_FRAGMENT_HIDDEN then
            control:SetHidden(true)
        elseif state == SCENE_FRAGMENT_SHOWN then
            ScheduleRefresh()
        end
    end)
    local root = ZO_ACTIVITY_FINDER_ROOT_MANAGER
    root:RegisterCallback("OnUpdateLocationData", ScheduleRefresh)
    root:RegisterCallback("OnActivityFinderStatusUpdate", ScheduleRefresh)
    local function ReleaseSelection()
        if pledges.applying or not pledges.selected or IsSearching() then
            return
        end

        pledges.selected = false
        ZO_CheckButton_SetCheckState(check, false)
    end
    ZO_PreHook(root, "ToggleLocationSelected", ReleaseSelection)
    ZO_PreHook(finder, "OnFilterChanged", ReleaseSelection)
    for _, event in ipairs({ EVENT_QUEST_ADDED, EVENT_QUEST_REMOVED, EVENT_PLAYER_ACTIVATED }) do
        EVENT_MANAGER:RegisterForEvent("UAUndauntedPledges", event, ScheduleRefresh)
    end

    ZO_PostHook(finder, "RefreshView", ScheduleRefresh)
end
