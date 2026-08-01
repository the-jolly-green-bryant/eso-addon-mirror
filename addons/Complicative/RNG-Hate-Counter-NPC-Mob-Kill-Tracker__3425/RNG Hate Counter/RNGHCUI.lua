RNGHCUI = {
    buttonFragment = ZO_SimpleSceneFragment:New(RNGHCButtonControl),
    mainFragment = ZO_SimpleSceneFragment:New(RNGHCMainWindow),
    sortBy = "name",
    sortAscName = true,
    sortAscAmount = false
}

function RNGHCUI.SetHidden(fragment, hidden)
    -- Removes adds to Scenes (proper way to hide/unhide windows)
    if hidden then
        HUD_SCENE:RemoveFragment(fragment)
        HUD_UI_SCENE:RemoveFragment(fragment)
    end
    if not hidden then
        HUD_SCENE:AddFragment(fragment)
        HUD_UI_SCENE:AddFragment(fragment)
    end
end

function RNGHCUI.Init()
    RNGHCUI.CreateScrollListDataType() --Init of the ScrollList
    RNGHCUI.Update()                   --Updating the ScrollList with data

    --UI
    RNGHCUI.SetHidden(RNGHCUI.buttonFragment, RNGHateCounter.Settings.buttonHidden)
    RNGHCUI.SetHidden(RNGHCUI.mainFragment, true)
    RNGHCButtonControlButtonLabel:SetHidden(RNGHateCounter.Settings.buttonLabelHidden)
    RNGHCButtonControl:ClearAnchors()
    RNGHCButtonControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RNGHateCounter.Settings.buttonX,
        RNGHateCounter.Settings.buttonY)
end

function RNGHCUI.SaveButtonLocation()
    --Saves the location of the button (Is called when mouse is released after moving the button)
    RNGHateCounter.Settings.buttonX = RNGHCButtonControl:GetLeft()
    RNGHateCounter.Settings.buttonY = RNGHCButtonControl:GetTop()
end

function RNGHCUI.CreateScrollListDataType()
    --Init of the ScrollList
    ZO_ScrollList_AddDataType(RNGHCMainWindow:GetNamedChild("ScrollList"):GetNamedChild("ItemList"), 1,
        "RNGHateCounterListItemTemplate", 30, RNGHCUI.UpdateDataRow)
end

function RNGHCUI.GetFilteredList(func)
    --Filters the list with func and sorts it by RNGHCUI.sortBy category
    --The returned list is indexed by number
    local t = {}
    for k, v in pairs(RNGHateCounterData[RNGHateCounter.worldName][RNGHateCounter.accountName]) do
        if (func(k)) then
            table.insert(t, {
                name = k,
                amount = v
            })
        end
    end

    if (RNGHCUI.sortBy == "name") then
        if RNGHCUI.sortAscName then
            table.sort(t, function(a, b) return a.name < b.name end)
        else
            table.sort(t, function(a, b) return a.name > b.name end)
        end
    elseif (RNGHCUI.sortBy == "amount") then
        if RNGHCUI.sortAscAmount then
            table.sort(t, function(a, b)
                if a.amount ~= b.amount then
                    return a.amount < b.amount
                else
                    return a.name < b.name
                end
            end)
        else
            table.sort(t, function(a, b)
                if a.amount ~= b.amount then
                    return a.amount > b.amount
                else
                    return a.name < b.name
                end
            end)
        end
    end

    return t
end

function RNGHCUI.UpdateDataRow(control, data)
    --Gets called for every row of data

    control:GetNamedChild("Name"):SetText(data.name)                            --Name
    control:GetNamedChild("Amount"):SetText(ZO_CommaDelimitNumber(data.amount)) --Amount

    --Updates the info text at the bottom
    RNGHCMainWindow:GetNamedChild("InfoLabel"):SetText("Different Species killed: " ..
        ZO_CommaDelimitNumber(RNGHateCounter.differentCount) ..
        " | Total kills: " .. ZO_CommaDelimitNumber(RNGHateCounter.totalCount))

    --Updates the button label
    RNGHCUI.UpdateButton()
end

function RNGHCUI.UpdateButton()
    RNGHCButtonControlButtonLabel:SetText(ZO_CommaDelimitNumber(RNGHateCounter.totalCount))
end

function RNGHCUI.Update()
    --Gets called when the list is supposed to be updated

    local func = function() return true end                                  --no filtering
    if RNGHCMainWindow:GetNamedChild("SearchBar"):GetText() ~= "Search" then --filtering by search text
        func = function(a)
            if string.find(string.lower(a), string.lower(RNGHCMainWindow:GetNamedChild("SearchBar"):GetText())) ~= nil then
                return true
            else
                return false
            end
        end
    end

    ZO_ScrollList_Clear(RNGHCMainWindow:GetNamedChild("ScrollList"):GetNamedChild("ItemList"))                          --Clears the ScrollList list
    local scrollData = ZO_ScrollList_GetDataList(RNGHCMainWindow:GetNamedChild("ScrollList"):GetNamedChild("ItemList")) --Gets the ScrollList list

    for _, v in ipairs(RNGHCUI.GetFilteredList(func)) do
        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(1, v) --Adds entries to the ScrollList list
    end

    ZO_ScrollList_Commit(RNGHCMainWindow:GetNamedChild("ScrollList"):GetNamedChild("ItemList")) --Tells the scrollList to update itself
end
