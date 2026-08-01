QuickSurveyOpener = {}
QuickSurveyOpener.name = "QuickSurveyOpener"
QuickSurveyOpener.openQueue = nil
QuickSurveyOpener.isOpening = false
QuickSurveyOpener.stopRequested = false
QuickSurveyOpener.scrollInitialized = false
QuickSurveyOpener.isRefreshingScroll = false

local function Clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

function QuickSurveyOpener.ToggleWindow()
    if not QuickSurveyOpenerWindow then return end
    if QuickSurveyOpenerWindow:IsHidden() then
        QuickSurveyOpenerWindow:SetHidden(false)
        QuickSurveyOpener.RefreshSurveyData()
        QuickSurveyOpener.RefreshScrollList()
    else
        QuickSurveyOpener.ResetSelectedCounts()
        QuickSurveyOpener.RefreshScrollList()
        QuickSurveyOpenerWindow:SetHidden(true)
    end
end

function QuickSurveyOpener.GetGroupState(itemId)
    if not QuickSurveyOpener_SelectionState then QuickSurveyOpener_SelectionState = {} end
    if not QuickSurveyOpener_SelectionState[itemId] then
        QuickSurveyOpener_SelectionState[itemId] = { selected = false, count = 0 }
    end
    return QuickSurveyOpener_SelectionState[itemId]
end

function QuickSurveyOpener.SetSelectedCount(itemId, count)
    local group = QuickSurveyOpener_GroupsById[itemId]
    if not group then return end
    local state = QuickSurveyOpener.GetGroupState(itemId)
    state.count = Clamp(count, 0, group.count)
    state.selected = state.count > 0
end

function QuickSurveyOpener.ResetSelectedCounts()
    if not QuickSurveyOpener_SelectionState then return end
    for _, state in pairs(QuickSurveyOpener_SelectionState) do
        state.count = 0
        state.selected = false
    end
end

function QuickSurveyOpener.RefreshSurveyData()
    if not QuickSurveyOpener_SelectionState then QuickSurveyOpener_SelectionState = {} end
    if not QuickSurveyOpener_Groups then QuickSurveyOpener_Groups = {} end
    if not QuickSurveyOpener_GroupsById then QuickSurveyOpener_GroupsById = {} end
    local groups = {}
    local groupsById = {}
    local bagSize = GetBagSize(BAG_BACKPACK)

    for slotIndex = 0, bagSize - 1 do
        local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
        if itemLink and itemLink ~= "" then
            local name = GetItemLinkName(itemLink)
            if string.find(name, "Unidentified") then
                local itemId = GetItemLinkItemId(itemLink)
                if itemId and itemId ~= 0 then
                    local stackCount = GetSlotStackSize(BAG_BACKPACK, slotIndex) or 1
                    local group = groupsById[itemId]
                    if not group then
                        group = { itemId = itemId, name = name, count = 0 }
                        groupsById[itemId] = group
                        table.insert(groups, group)
                    end
                    group.count = group.count + stackCount
                end
            end
        end
    end

    table.sort(groups, function(a, b) return a.name < b.name end)
    QuickSurveyOpener_Groups = groups
    QuickSurveyOpener_GroupsById = groupsById

    for itemId, state in pairs(QuickSurveyOpener_SelectionState) do
        local group = groupsById[itemId]
        if group then
            if state.count > group.count then
                state.count = group.count
            end
            state.selected = state.count > 0
        else
            QuickSurveyOpener_SelectionState[itemId] = nil
        end
    end
end

function QuickSurveyOpener.InitializeScrollList()
    if QuickSurveyOpener.scrollInitialized then return end
    local list = QuickSurveyOpenerScrollList
    if not list then return end

    ZO_ScrollList_Initialize(list)
    ZO_ScrollList_AddDataType(list, 1, "QuickSurveyOpenerRow", 34, QuickSurveyOpener.SetupScrollRow)
    ZO_ScrollList_SetTypeSelectable(list, 1, false)
    QuickSurveyOpener.scrollInitialized = true
end

function QuickSurveyOpener.RefreshScrollList()
    QuickSurveyOpener.InitializeScrollList()
    local list = QuickSurveyOpenerScrollList
    if not list then return end

    QuickSurveyOpener.isRefreshingScroll = true
    local scrollData = ZO_ScrollList_GetDataList(list)
    ZO_ScrollList_Clear(list)

    local totalSelected = 0
    for _, group in ipairs(QuickSurveyOpener_Groups) do
        local state = QuickSurveyOpener.GetGroupState(group.itemId)
        state.count = Clamp(state.count, 0, group.count)
        if state.count > 0 then
            state.selected = true
        end

        totalSelected = totalSelected + state.count

        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, {
            itemId = group.itemId,
            name = group.name,
            available = group.count,
            openCount = state.count,
        }))
    end

    ZO_ScrollList_Commit(list)
    QuickSurveyOpener.isRefreshingScroll = false
    QuickSurveyOpener.UpdateButtonsAndStatus(totalSelected)
end

function QuickSurveyOpener.SetupScrollRow(control, data)
    local itemId = data.itemId
    control.itemId = itemId

    local nameLabel = control:GetNamedChild("Name")
    if nameLabel then
        nameLabel:SetText(data.name)
    end

    local availableLabel = control:GetNamedChild("AvailableLabel")
    if availableLabel then
        availableLabel:SetText(tostring(data.available))
    end

    local countBox = control:GetNamedChild("CountBox")
    if countBox then
        countBox.itemId = itemId
        countBox:SetText(tostring(data.openCount))
        countBox:SetHandler("OnTextChanged", function(self)
            QuickSurveyOpener.OnCountChanged(self)
        end)
        countBox:SetHandler("OnFocusLost", function(self)
            QuickSurveyOpener.OnCountChanged(self)
        end)
    end

    local plus = control:GetNamedChild("PlusButton")
    if plus then
        plus.itemId = itemId
        plus:SetHandler("OnClicked", function(self)
            QuickSurveyOpener.AdjustSelectedCount(self, 1)
        end)
    end

    local minus = control:GetNamedChild("MinusButton")
    if minus then
        minus.itemId = itemId
        minus:SetHandler("OnClicked", function(self)
            QuickSurveyOpener.AdjustSelectedCount(self, -1)
        end)
    end

    local maxButton = control:GetNamedChild("MaxButton")
    if maxButton then
        maxButton.itemId = itemId
        maxButton:SetHandler("OnClicked", function(self)
            QuickSurveyOpener.SetSelectedToMax(self)
        end)
    end

    local enabled = true
    if countBox then countBox:SetMouseEnabled(enabled) end
    if plus then plus:SetEnabled(enabled) end
    if minus then minus:SetEnabled(enabled) end
    if maxButton then maxButton:SetEnabled(enabled) end
end

function QuickSurveyOpener.OnCountChanged(editBox)
    if QuickSurveyOpener.isRefreshingScroll then
        return
    end

    local itemId = editBox.itemId
    if not itemId then return end

    local group = QuickSurveyOpener_GroupsById[itemId]
    if not group then return end

    local count = tonumber(editBox:GetText()) or 0
    QuickSurveyOpener.SetSelectedCount(itemId, count)
    QuickSurveyOpener.RefreshScrollList()
end

function QuickSurveyOpener.AdjustSelectedCount(button, delta)
    local itemId = button.itemId
    if not itemId then return end

    local group = QuickSurveyOpener_GroupsById[itemId]
    if not group then return end

    local state = QuickSurveyOpener.GetGroupState(itemId)
    QuickSurveyOpener.SetSelectedCount(itemId, state.count + delta)
    QuickSurveyOpener.RefreshScrollList()
end

function QuickSurveyOpener.SetSelectedToMax(button)
    local itemId = button.itemId
    if not itemId then return end

    local group = QuickSurveyOpener_GroupsById[itemId]
    if not group then return end

    QuickSurveyOpener.SetSelectedCount(itemId, group.count)
    QuickSurveyOpener.RefreshScrollList()
end

function QuickSurveyOpener.GetTotalSelectedCount()
    if not QuickSurveyOpener_SelectionState then QuickSurveyOpener_SelectionState = {} end
    local total = 0
    for _, state in pairs(QuickSurveyOpener_SelectionState) do
        if state.selected then
            total = total + state.count
        end
    end
    return total
end

function QuickSurveyOpener.UpdateButtonsAndStatus(totalSelected)
    local openButton = QuickSurveyOpenerWindow and QuickSurveyOpenerWindow:GetNamedChild("OpenButton")
    local statusLabel = QuickSurveyOpenerWindow and QuickSurveyOpenerWindow:GetNamedChild("StatusLabel")

    totalSelected = totalSelected or QuickSurveyOpener.GetTotalSelectedCount()

    if openButton then
        openButton:SetHidden(totalSelected == 0 or QuickSurveyOpener.isOpening)
        openButton:SetEnabled(totalSelected > 0 and not QuickSurveyOpener.isOpening)
    end
    if statusLabel then
        if QuickSurveyOpener.isOpening then
            statusLabel:SetText("Opening selected reports...")
        elseif totalSelected > 0 then
            statusLabel:SetText("Ready to open " .. totalSelected .. " selected survey(s). Click Open to begin.")
        else
            statusLabel:SetText("Enter counts for the survey types you want to open.")
        end
    end
end

function QuickSurveyOpener.BuildOpenQueue()
    local queue = {}
    for _, group in ipairs(QuickSurveyOpener_Groups) do
        local state = QuickSurveyOpener_SelectionState[group.itemId]
        if state and state.selected and state.count > 0 then
            local count = Clamp(state.count, 0, group.count)
            if count > 0 then
                table.insert(queue, { itemId = group.itemId, name = group.name, count = count })
            end
        end
    end
    return queue
end

function QuickSurveyOpener.FindSlotForItem(itemId)
    local bagSize = GetBagSize(BAG_BACKPACK)
    for slotIndex = 0, bagSize - 1 do
        local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
        if itemLink and itemLink ~= "" then
            if GetItemLinkItemId(itemLink) == itemId then
                return slotIndex
            end
        end
    end
    return nil
end

function QuickSurveyOpener.CancelOpening()
    -- Not needed for synchronous opening
end

function QuickSurveyOpener.FinishOpening(message)
    QuickSurveyOpener.isOpening = false
    QuickSurveyOpener.stopRequested = false
    QuickSurveyOpener.openQueue = nil
    QuickSurveyOpener.RefreshSurveyData()
    QuickSurveyOpener.RefreshScrollList()
    if message and message ~= "" then
        d(message)
    end
end

function QuickSurveyOpener.ProcessNextOpen()
    -- Not used for synchronous opening
end

QuickSurveyOpener_DoOpen = function()
    if not QuickSurveyOpener_SelectionState then QuickSurveyOpener_SelectionState = {} end
    if not QuickSurveyOpener_Groups then QuickSurveyOpener_Groups = {} end
    if not QuickSurveyOpener_GroupsById then QuickSurveyOpener_GroupsById = {} end
    -- Inline RefreshSurveyData
    local groups = {}
    local groupsById = {}
    local bagSize = GetBagSize(BAG_BACKPACK)
    for slotIndex = 0, bagSize - 1 do
        local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
        if itemLink and itemLink ~= "" then
            local name = GetItemLinkName(itemLink)
            if string.find(name, "Unidentified") then
                local itemId = GetItemLinkItemId(itemLink)
                if itemId and itemId ~= 0 then
                    local stackCount = GetSlotStackSize(BAG_BACKPACK, slotIndex) or 1
                    local group = groupsById[itemId]
                    if not group then
                        group = { itemId = itemId, name = name, count = 0 }
                        groupsById[itemId] = group
                        table.insert(groups, group)
                    end
                    group.count = group.count + stackCount
                end
            end
        end
    end
    table.sort(groups, function(a, b) return a.name < b.name end)
    QuickSurveyOpener.groups = groups
    QuickSurveyOpener.groupsById = groupsById
    for itemId, state in pairs(QuickSurveyOpener.selectionState) do
        local group = groupsById[itemId]
        if group then
            if state.count > group.count then
                state.count = group.count
            end
            state.selected = state.count > 0
        else
            QuickSurveyOpener.selectionState[itemId] = nil
        end
    end

    -- Inline BuildOpenQueue
    local queue = {}
    for _, group in ipairs(QuickSurveyOpener_Groups) do
        local state = QuickSurveyOpener_SelectionState[group.itemId]
        if state and state.selected and state.count > 0 then
            local count = math.min(state.count, group.count)
            if count > 0 then
                table.insert(queue, { itemId = group.itemId, name = group.name, count = count })
            end
        end
    end

    if #queue == 0 then
        d("Please choose at least one report and a quantity to open.")
        return
    end

    for _, item in ipairs(queue) do
        for i = 1, item.count do
            -- Inline FindSlotForItem
            local slotIndex = nil
            local bagSize2 = GetBagSize(BAG_BACKPACK)
            for s = 0, bagSize2 - 1 do
                local itemLink2 = GetItemLink(BAG_BACKPACK, s)
                if itemLink2 and itemLink2 ~= "" then
                    if GetItemLinkItemId(itemLink2) == item.itemId then
                        slotIndex = s
                        break
                    end
                end
            end
            if slotIndex then
                if IsProtectedFunction("UseItem") then
                    CallSecureProtected("UseItem", BAG_BACKPACK, slotIndex)
                else
                    UseItem(BAG_BACKPACK, slotIndex)
                end
            end
        end
    end

    d("Opened all selected survey reports.")
    QuickSurveyOpener.ResetSelectedCounts()

    -- Inline RefreshSurveyData again
    groups = {}
    groupsById = {}
    bagSize = GetBagSize(BAG_BACKPACK)
    for slotIndex = 0, bagSize - 1 do
        local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
        if itemLink and itemLink ~= "" then
            local name = GetItemLinkName(itemLink)
            if string.find(name, "Unidentified") then
                local itemId = GetItemLinkItemId(itemLink)
                if itemId and itemId ~= 0 then
                    local stackCount = GetSlotStackSize(BAG_BACKPACK, slotIndex) or 1
                    local group = groupsById[itemId]
                    if not group then
                        group = { itemId = itemId, name = name, count = 0 }
                        groupsById[itemId] = group
                        table.insert(groups, group)
                    end
                    group.count = group.count + stackCount
                end
            end
        end
    end
    table.sort(groups, function(a, b) return a.name < b.name end)
    QuickSurveyOpener.groups = groups
    QuickSurveyOpener.groupsById = groupsById
    for itemId, state in pairs(QuickSurveyOpener.selectionState) do
        local group = groupsById[itemId]
        if group then
            if state.count > group.count then
                state.count = group.count
            end
            state.selected = state.count > 0
        else
            QuickSurveyOpener_SelectionState[itemId] = nil
        end
    end

    QuickSurveyOpener.RefreshScrollList()
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= QuickSurveyOpener.name then return end

    QuickSurveyOpener_SelectionState = QuickSurveyOpener_SelectionState or {}
    QuickSurveyOpener_Groups = QuickSurveyOpener_Groups or {}
    QuickSurveyOpener_GroupsById = QuickSurveyOpener_GroupsById or {}

    SLASH_COMMANDS["/qso"] = function()
        QuickSurveyOpener.ToggleWindow()
    end

    EVENT_MANAGER:RegisterForEvent(QuickSurveyOpener.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
        if QuickSurveyOpenerWindow and not QuickSurveyOpenerWindow:IsHidden() then
            QuickSurveyOpener.RefreshSurveyData()
            QuickSurveyOpener.RefreshScrollList()
        end
    end)
end

EVENT_MANAGER:RegisterForEvent(QuickSurveyOpener.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
