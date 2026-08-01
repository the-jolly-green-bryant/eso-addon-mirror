---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------
local numEntries = 0
local shownTree

local function GetOrCreateMenuButton(index)
    local button = DynamicCPQuickstarsContextMenu:GetNamedChild("Entry" .. tostring(index))
    if (not button) then
        button = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Entry" .. tostring(index), DynamicCPQuickstarsContextMenu, "DynamicCPQuickstarsMenuEntry")
        if (index == 1) then
            button:SetAnchor(TOPLEFT, DynamicCPQuickstarsContextMenu, TOPLEFT, 4, 4)
        else
            button:SetAnchor(TOPLEFT, DynamicCPQuickstarsContextMenu:GetNamedChild("Entry" .. tostring(index - 1)), BOTTOMLEFT, 0, 4)
        end
        button:SetDrawTier(DT_HIGH)
        button:GetLabelControl():SetFont(DynamicCP.GetStyles().gameFont)
    end
    if (index > numEntries) then
        numEntries = index
    end

    button:SetHidden(false)
    return button
end

function DynamicCP.ApplyQuickstarsSlotGroupMenuFonts()
    for i = 1, numEntries do
        local button = DynamicCPQuickstarsContextMenu:GetNamedChild("Entry" .. tostring(i))
        if (button) then
            button:GetLabelControl():SetFont(DynamicCP.GetStyles().gameFont)
        end
    end
end

local function HideMenu()
    EVENT_MANAGER:UnregisterForEvent(DynamicCP.name .. "QSMouseUpHide", EVENT_GLOBAL_MOUSE_UP)
    DynamicCPQuickstarsContextMenu:SetHidden(true)
end
DynamicCP.HideSlotGroupMenu = HideMenu

local function ShowMenu(tree)
    shownTree = tree

    -- Sort keys because ugh
    local keys = {}
    for setId, setData in pairs(DynamicCP.savedOptions.slotGroups[tree]) do
        table.insert(keys, setData.name)
    end
    table.sort(keys)

    -- Create a button for each
    for i, key in ipairs(keys) do
        local button = GetOrCreateMenuButton(i)
        button:SetText(key)
    end

    -- Hide unused entries
    for i = #keys + 1, numEntries do
        DynamicCPQuickstarsContextMenu:GetNamedChild("Entry" .. tostring(i)):SetHidden(true)
    end

    -- Adjust backdrop
    if (#keys == 0) then
        DynamicCPQuickstarsContextMenu:SetHeight(58)
        DynamicCPQuickstarsContextMenuHint:SetHidden(false)
    else
        DynamicCPQuickstarsContextMenu:SetHeight(#keys * 20 + 8)
        DynamicCPQuickstarsContextMenuHint:SetHidden(true)
    end
    DynamicCPQuickstarsContextMenu:SetAnchor(TOPLEFT, DynamicCPQuickstars:GetNamedChild(tree .. "Button"), TOPRIGHT)
    DynamicCPQuickstarsContextMenu:SetHidden(false)

    -- Add a mouse listener to close menu when "losing focus"
    EVENT_MANAGER:UnregisterForEvent(DynamicCP.name .. "QSMouseUpHide", EVENT_GLOBAL_MOUSE_UP)
    zo_callLater(function()
        EVENT_MANAGER:RegisterForEvent(DynamicCP.name .. "QSMouseUpHide", EVENT_GLOBAL_MOUSE_UP, function()
            if (not DynamicCPQuickstarsContextMenu:IsHidden() and not MouseIsOver(DynamicCPQuickstarsContextMenu)) then
                HideMenu()
            end
        end)
    end, 250)
end
DynamicCP.ShowSlotGroupMenu = ShowMenu
-- /script DynamicCP.ShowSlotGroupMenu("Red")

local function ToggleMenu(tree)
    if (not DynamicCPQuickstarsContextMenu:IsHidden() and tree == shownTree) then
        HideMenu()
    else
        ShowMenu(tree)
    end
end
DynamicCP.ToggleSlotGroupMenu = ToggleMenu

---------------------------------------------------------------------
-- On entry clicked in menu
---------------------------------------------------------------------
local function OnQuickstarSlotGroupClicked(text)
    HideMenu()

    local setId = DynamicCP.GetSlotSetIdByName(shownTree, text)
    local data = DynamicCP.savedOptions.slotGroups[shownTree][setId]
    if (not data) then
        d("|cFF0000This code shouldn't be reachable. OnQuickstarSlotGroupClicked|r")
        return
    end

    -- Slot each slottable
    for i = 1, 4 do
        local skillId = data[i]
        if (skillId and skillId ~= 0) then
            DynamicCP.SelectQuickstar(shownTree, i, skillId)
        else
            DynamicCP.SelectQuickstar(shownTree, i, -1)
        end
    end
end
DynamicCP.OnQuickstarSlotGroupClicked = OnQuickstarSlotGroupClicked


---------------------------------------------------------------------
-- On hover over entry in menu
---------------------------------------------------------------------
local function AdjustHoverWidth()
    DynamicCPQuickstarsContextMenuPreview:SetWidth(500)
    local width = DynamicCPQuickstarsContextMenuPreviewLabel:GetTextWidth() + 8
    if (width < 200) then width = 200 end
    DynamicCPQuickstarsContextMenuPreview:SetWidth(width)
end

local function GetSlotSetString(tree, setData)
    local TEXT_COLORS_HEX = {
        Green = "a5d752",
        Blue = "59bae7",
        Red = "e46b2e",
    }

    local committed = DynamicCP.GetCommittedSlottables()

    local starsString = ""
    for i = 1, 4 do
        local starName = ""
        local skillId = setData[i]
        local color = TEXT_COLORS_HEX[tree]
        local unlocked = true
        if (skillId) then
            starName = GetChampionSkillName(skillId)
            unlocked = WouldChampionSkillNodeBeUnlocked(skillId, GetNumPointsSpentOnChampionSkill(skillId))
            if (not committed[skillId]) then
                color = "ffff80"
            end
        end

        starsString = starsString .. zo_strformat("|c<<1>><<2>> - <<C:3>><<4>>|r\n",
            color,
            i,
            starName,
            unlocked and "" or " |cFF4444- not unlocked")
    end

    return starsString
end

function DynamicCP.OnQuickstarSlotGroupEnter(text)
    local setId = DynamicCP.GetSlotSetIdByName(shownTree, text)
    local data = DynamicCP.savedOptions.slotGroups[shownTree][setId]
    if (not data) then
        d("|cFF0000This code shouldn't be reachable. OnQuickstarSlotGroupEnter|r")
        return
    end
    local slotSetString = GetSlotSetString(shownTree, data)

    DynamicCPQuickstarsContextMenuPreview:ClearAnchors()
    DynamicCPQuickstarsContextMenuPreview:SetAnchor(TOPLEFT, DynamicCPQuickstarsContextMenu, TOPRIGHT, 2)
    DynamicCPQuickstarsContextMenuPreview:SetHidden(false)
    DynamicCPQuickstarsContextMenuPreviewLabel:SetText(slotSetString)
    AdjustHoverWidth()
end

function DynamicCP.OnQuickstarSlotGroupExit(text)
    DynamicCPQuickstarsContextMenuPreview:SetHidden(true)
end
