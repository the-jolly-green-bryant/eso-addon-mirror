local PledgeHighlights = {}
local PH = PledgeHighlights
PH.name = "PledgeHighlights"
PH.lastPledges = nil
PH.normalEntries = {}
PH.veteranEntries = {}

--[[
        Pledges
--]]

function PH.GetActivePledgeNames()
    local pledgeQuests = {}

    for index = 1, MAX_JOURNAL_QUESTS do
        if IsValidQuestIndex(index) then
            local questName, _, _, _, _, _, _, _, _, questType, _ = GetJournalQuestInfo(index)

            if questType == QUEST_TYPE_UNDAUNTED_PLEDGE and not PH.IsPledgeQuestComplete(index) then
                pledgeQuests[questName] = true
            end
        end
    end
    return pledgeQuests
end

function PH.UpdatePledges()
    local currentPledges = PH.GetActivePledgeNames()
    if PH.ArePledgeTablesEqual(PH.lastPledges, currentPledges) then return false end
    PH.lastPledges = currentPledges
    return true
end

function PH.IsPledgeQuestComplete(index)
    local conditionText = GetJournalQuestConditionInfo(index, nil, nil)
    return conditionText:find("Glirion") or conditionText:find("Maj") or conditionText:find("Urgarlag")
end

function PH.ArePledgeTablesEqual(t1, t2)
    if not t1 or not t2 then return false end

    for questName in pairs(t1) do
        if not t2[questName] then return false end
    end

    for questName in pairs(t2) do
        if not t1[questName] then return false end
    end

    return true
end

function PH.FindPledgeName(dungeonName, pledgesNames)
    dungeonName = dungeonName:lower():gsub("%sii$", " 2"):gsub("%si$", " 1")
    for k, _ in pairs(pledgesNames) do
        local pledgesName = k:lower():gsub("%sii$", " 2"):gsub("%si$", " 1")
        if string.find(pledgesName, dungeonName, 1, true) then
            return k
        end
    end
end

--[[
        Markers
--]]

function PH.InitMarkerPool()
    PH.markerPool = ZO_ObjectPool:New(function(pool)
        local id = pool:GetNextFree()
        local name = "PH_PledgeMarker" .. id
        local control = WINDOW_MANAGER:CreateControl(name, GuiRoot, CT_TEXTURE)
        control:SetTexture("esoui/art/journal/journal_quest_selected.dds")
        control:SetDimensions(20, 20)
        return control
    end, function(control)
        control:SetHidden(true)
        control:ClearAnchors()
        control:SetParent(GuiRoot)
    end)
end

function PH.InitEntryControls()
    local normalDungeonsList = GetControl("ZO_DungeonFinder_KeyboardListSectionScrollChildContainer", 2)
    if not normalDungeonsList then return end
    local dungeonCount = normalDungeonsList:GetNumChildren()
    for index = 1, dungeonCount do 
        local normalEntry = GetControl("ZO_DungeonFinder_KeyboardListSectionScrollChildZO_ActivityFinderTemplateNavigationEntry_Keyboard", index)
        local veteranEntry = GetControl("ZO_DungeonFinder_KeyboardListSectionScrollChildZO_ActivityFinderTemplateNavigationEntry_Keyboard", index + dungeonCount)
        if normalEntry and veteranEntry then
            table.insert(PH.normalEntries, normalEntry)
            table.insert(PH.veteranEntries, veteranEntry)
        end
    end 
    return true
end

function PH.CreateAllMarkers()
    if PH.UpdatePledges() == false then return end
    PH.markerPool:ReleaseAllObjects()

    if #PH.normalEntries <= 0 then 
        if not PH.InitEntryControls() then return end 
    end

    for index = 1, #PH.normalEntries do 
        local normalEntry = PH.normalEntries[index]
        local veteranEntry = PH.veteranEntries[index]
        
        if normalEntry and veteranEntry then 
            local dungeonName = normalEntry:GetNamedChild("Text"):GetText()
            local pledgeName = PH.FindPledgeName(dungeonName, PH.lastPledges)

            if pledgeName then
                PH.UpdateMarker(normalEntry)
                PH.UpdateMarker(veteranEntry)
            end
        end
    end  
end

function PH.UpdateMarker(parent)
    local marker = PH.markerPool:AcquireObject()
    marker:SetParent(parent)
    marker:SetAnchor(RIGHT, parent, LEFT, -20, 0)
    marker:SetHidden(false)
end


--[[
        Addon Loaded
--]]

function PH.OnAddonLoaded(event, addonName)
    if addonName ~= PH.name then return end

    EVENT_MANAGER:UnregisterForEvent(PH.name, EVENT_ADD_ON_LOADED)

    PH.InitMarkerPool()

    ZO_PostHookHandler(ZO_DungeonFinder_KeyboardListSection, 'OnEffectivelyShown', function()
        zo_callLater(PH.CreateAllMarkers, 100)
    end)

end

EVENT_MANAGER:RegisterForEvent(PH.name, EVENT_ADD_ON_LOADED, PH.OnAddonLoaded)