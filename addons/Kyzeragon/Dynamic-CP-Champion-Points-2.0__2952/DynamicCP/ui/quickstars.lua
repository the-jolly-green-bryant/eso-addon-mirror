-- Keep track of our own pending slottables, even though slottables.lua also has it
-- because slottables.lua is for presets and it's possible the user still has pending
-- changes in a preset
-- [slotIndex] = skillId
local pendingSlottables = nil

-- [1] = emptyEntry,
local emptyEntries = {}
DynamicCP.emptyEntries = emptyEntries
local skillIdToEntry -- So that we can call this from context menu

local offsets = {
    Green = 0,
    Blue = 4,
    Red = 8,
}

local trees = {
    [1] = "Green",
    [2] = "Blue",
    [3] = "Red",
}

local quickstarsFragment = nil

---------------------------------------------------------------------
-- Utility
---------------------------------------------------------------------
-- Flip the key and value for easier use for quickstars
local function GetFlippedSlottables()
    local committed = DynamicCP.GetCommittedSlottables() -- [skillId] = index
    local flipped = {}
    for skillId, slotIndex in pairs(committed) do
        flipped[slotIndex] = skillId
    end

    -- TODO: kinda a hack to fill in missing gaps when there are multiple unslotted items. I should fix GetCommittedSlottables somehow
    for i = 1, 12 do
        if (not flipped[i]) then
            flipped[i] = 0
        end
    end

    return flipped
end

---------------------------------------------------------------------
-- Provides list of stars that have enough points to be slotted
-- {[skillId] = points,}
local function GetAvailableSlottables(tree)
    local treeToIndex = {
        Green = 1,
        Blue = 2,
        Red = 3,
    }
    -- [disciplineIndex][skillId] = points
    local committedPoints = DynamicCP.GetCommittedCP()
    local available = {}

    local disciplineIndex = treeToIndex[tree]
    local disciplineData = committedPoints[disciplineIndex]
    for skillId, points in pairs(disciplineData) do
        if (CanChampionSkillTypeBeSlotted(GetChampionSkillType(skillId)) and WouldChampionSkillNodeBeUnlocked(skillId, points)) then
            available[skillId] = points
        end
    end

    return available
end


---------------------------------------------------------------------
-- Pending functions
---------------------------------------------------------------------
local function NeedsSlottableRespec()
    if (not pendingSlottables) then
        return false
    end

    local committed = GetFlippedSlottables()
    for slotIndex, skillId in pairs(pendingSlottables) do
        -- If star is not already slotted in the same slot, then we're done

        local committedId = committed[slotIndex]
        if (committedId == 0) then committedId = -1 end
        if (committedId ~= skillId) then
            return true
        end
    end

    -- If nothing changed, then we can just clear everything
    pendingSlottables = nil
    return false
end

local function SetSlottableSlot(tree, slotIndex, skillId)
    if (not pendingSlottables) then
        pendingSlottables = {}
    end
    pendingSlottables[slotIndex] = skillId


    -- Check the other slots
    local committed = GetFlippedSlottables()
    if (skillId == -1) then return end
    for dropdownIndex = 1, 4 do
        local offset = math.floor((slotIndex - 1) / 4) * 4
        local i = offset + dropdownIndex
        if (slotIndex ~= i) then
            local currentId = pendingSlottables[i]
            if (not currentId) then
                currentId = committed[i]
            end

            -- If it's currently slotted in a different dropdown, it needs to be removed
            if (currentId == skillId) then
                local dropdown = ZO_ComboBox_ObjectFromContainer(DynamicCPQuickstarsPanelLists:GetNamedChild(tree .. "Star" .. tostring(dropdownIndex)))
                dropdown:SelectItem(emptyEntries[i])
            end
        end
    end
end


---------------------------------------------------------------------
-- Slot selected handler
---------------------------------------------------------------------
local function OnStarSelected(tree, dropdownIndex, skillId, origSkillId)
    local dropdownControl = DynamicCPQuickstarsPanelLists:GetNamedChild(tree .. "Star" .. tostring(dropdownIndex))
    local slotIndex = offsets[tree] + dropdownIndex

    -- Show the unsaved changes icon if it is changed
    if (skillId == origSkillId) then
        dropdownControl:GetNamedChild("Unsaved"):SetHidden(true)
    else
        dropdownControl:GetNamedChild("Unsaved"):SetHidden(false)
    end

    SetSlottableSlot(tree, slotIndex, skillId)

    -- Show/hide confirm/cancel buttons
    local needsRespec = NeedsSlottableRespec()
    if (needsRespec) then
        DynamicCPQuickstarsPanelConfirm:SetHidden(false)
        DynamicCPQuickstarsPanelCancel:SetHidden(false)
    else
        DynamicCPQuickstarsPanelConfirm:SetHidden(true)
        DynamicCPQuickstarsPanelCancel:SetHidden(true)
    end
end


---------------------------------------------------------------------
-- External function for selecting a dropdown item
---------------------------------------------------------------------
local function ExternalSelectStar(tree, dropdownIndex, skillId)
    local entry = skillIdToEntry[tree][dropdownIndex][skillId]
    if (not entry) then
        DynamicCP.dbg(tostring(dropdownIndex) .. " " .. GetChampionSkillName(skillId) .. " not unlocked")
        return
    end

    local dropdown = ZO_ComboBox_ObjectFromContainer(DynamicCPQuickstarsPanelLists:GetNamedChild(tree .. "Star" .. tostring(dropdownIndex)))
    dropdown:SelectItem(entry)
end
DynamicCP.SelectQuickstar = ExternalSelectStar

---------------------------------------------------------------------
-- Reinitialize dropdowns for the particular tree
---------------------------------------------------------------------
local function UpdateDropdowns(tree, listTree)
    if (tree == "NONE") then return end
    if (not listTree) then
        listTree = "Green"
    end
    local selectedColor = {
        Green = "a5d752",
        Blue = "59bae7",
        Red = "e46b2e",
    }
    local slottedColor = {
        Green = "7f9c4f",
        Blue = "5096b3",
        Red = "b56238",
    }

    local offset = offsets[tree]
    local committed = DynamicCP.GetCommittedSlottables()
    local flipped = GetFlippedSlottables()
    local availableSlottables = GetAvailableSlottables(tree)

    for i = 1, 4 do
        local dropdown = ZO_ComboBox_ObjectFromContainer(DynamicCPQuickstarsPanelLists:GetNamedChild(listTree .. "Star" .. tostring(i)))
        dropdown:ClearItems()
        dropdown:SetSortsItems(false)
        local entryToSelect = nil
        local selectedSkillId = flipped[offset + i]
        if (not selectedSkillId or selectedSkillId == 0) then
            selectedSkillId = -1
        end

        -- Iterate through all available slottable stars and add sort keys and format name
        local sortedSlottables = {}
        local index = 1
        for skillId, points in pairs(availableSlottables) do
            local name = zo_strformat("<<C:1>>", GetChampionSkillName(skillId))

            -- Adjust the color of the item according to whether it's slotted (mastermind, anyone?)
            local sortKey = 99
            if (skillId == selectedSkillId) then
                -- For the currently slotted in the same slot
                name = "|c" .. selectedColor[tree] .. name .. "|r"
                sortKey = committed[skillId]
            elseif (committed[skillId]) then
                -- Currently slotted in a different slot
                name = "|c" .. slottedColor[tree] .. name .. "|r"
                sortKey = committed[skillId]
            end
            sortedSlottables[index] = {skillId = skillId, name = name, sortKey = sortKey}
            index = index + 1
        end

        -- Add an empty item
        local emptyName = "---"
        if (selectedSkillId == -1) then
            emptyName = "|c" .. selectedColor[tree] .. emptyName .. "|r"
        end
        sortedSlottables[index] = {skillId = -1, name = emptyName, sortKey = 100}

        -- Sort the table according to sort keys
        table.sort(sortedSlottables, function(item1, item2)
            return item1.sortKey < item2.sortKey
        end)

        -- Add sorted items to dropdown
        for _, data in ipairs(sortedSlottables) do
            local function OnItemSelected(_, _, entry)
                -- DynamicCP.dbg("Selected " .. data.name .. " " .. tostring(data.skillId))
                OnStarSelected(tree, i, data.skillId, selectedSkillId)
            end

            local entry = ZO_ComboBox:CreateItemEntry(data.name, OnItemSelected)
            -- Don't add slotted stars if the setting is enabled
            if (not DynamicCP.savedOptions.quickstarsDropdownHideSlotted or data.sortKey >= 99) then
                dropdown:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
            end

            if (data.skillId == selectedSkillId) then
                entryToSelect = entry
            end
            if (data.skillId == -1) then
                emptyEntries[i + offset] = entry
            end
            skillIdToEntry[tree][i][data.skillId] = entry -- Save it for context menu to call
        end

        dropdown:UpdateItems()
        dropdown:SelectItem(entryToSelect)
    end
end

local function UpdateAllDropdowns()
    skillIdToEntry = {
        ["Green"] = {
            [1] = {}, -- [skillId] = entry,
            [2] = {},
            [3] = {},
            [4] = {},
        },
        ["Blue"] = {
            [1] = {},
            [2] = {},
            [3] = {},
            [4] = {},
        },
        ["Red"] = {
            [1] = {},
            [2] = {},
            [3] = {},
            [4] = {},
        },
    }
    UpdateDropdowns("Green", "Green")
    UpdateDropdowns("Blue", "Blue")
    UpdateDropdowns("Red", "Red")
end
DynamicCP.UpdateAllDropdowns = UpdateAllDropdowns


---------------------------------------------------------------------
-- Set backdrops to reflect which tab is selected
---------------------------------------------------------------------
local function SetBackdrops()
    local colors = {
        Green = {0.55, 0.78, 0.22, 1},
        Blue = {0.35, 0.73, 0.9, 1},
        Red = {0.88, 0.4, 0.19, 1},
    }

    for tree, color in pairs(colors) do
        if (DynamicCP.savedOptions["quickstarsShow" .. tree]) then
            DynamicCPQuickstars:GetNamedChild(tree .. "Button"):GetNamedChild("Backdrop"):SetCenterColor(unpack(color))
        else
            DynamicCPQuickstars:GetNamedChild(tree .. "Button"):GetNamedChild("Backdrop"):SetCenterColor(0, 0, 0, 1)
        end
    end
end

local function RefreshDisplay()
    DynamicCP.RefreshTreesDisplay()
    SetBackdrops()
end


---------------------------------------------------------------------
-- Called when user clicks tab button
---------------------------------------------------------------------
function DynamicCP.SelectQuickstarsTab(tree, button)
    if (tree ~= "Green" and tree ~= "Blue" and tree ~= "Red") then
        d("This code should not be reachable! DynamicCP.SelectQuickstarsTab")
        return
    end

    -- Show context menu instead
    if (button == MOUSE_BUTTON_INDEX_RIGHT) then
        DynamicCP.ToggleSlotGroupMenu(tree)
        -- DynamicCPQuickstarsContextMenu:SetMouseEnabled(true)
        return
    end

    DynamicCP.savedOptions["quickstarsShow" .. tree] = not DynamicCP.savedOptions["quickstarsShow" .. tree]
    RefreshDisplay()
end

-- Keybind to cycle through tabs
function DynamicCP.CycleQuickstars()
    local currentTab = "NONE"
    local green = DynamicCP.savedOptions.quickstarsShowGreen
    local blue = DynamicCP.savedOptions.quickstarsShowBlue
    local red = DynamicCP.savedOptions.quickstarsShowRed

    if (green and blue and red) then
        currentTab = "ALL"
    else
        if (DynamicCP.savedOptions.quickstarsShowRed) then
            currentTab = "Red"
        elseif (DynamicCP.savedOptions.quickstarsShowBlue) then
            currentTab = "Blue"
        elseif (DynamicCP.savedOptions.quickstarsShowGreen) then
            currentTab = "Green"
        end
    end

    local nextTab = {
        NONE = "Green",
        Green = "Blue",
        Blue = "Red",
        Red = "ALL",
        ALL = "NONE",
    }

    local next = nextTab[currentTab]
    DynamicCP.savedOptions.quickstarsShowGreen = (next == "Green" or next == "ALL")
    DynamicCP.savedOptions.quickstarsShowBlue = (next == "Blue" or next == "ALL")
    DynamicCP.savedOptions.quickstarsShowRed = (next == "Red" or next == "ALL")

    RefreshDisplay()
end


---------------------------------------------------------------------
-- Button click handlers
---------------------------------------------------------------------
function DynamicCP.OnQuickstarConfirm()
    if (not pendingSlottables) then
        d("|cFF0000This code shouldn't be reachable! Yell at Kyzer, preferably with what steps you took to get here. OnQuickstarConfirm|r")
    end

    PrepareChampionPurchaseRequest(false)

    -- Convert pending points to purchase request
    for slotIndex, skillId in pairs(pendingSlottables) do
        local id = skillId
        if (id == -1) then
            id = nil
        end
        AddHotbarSlotToChampionPurchaseRequest(slotIndex, id)
    end

    -- Should be able to just use this because points aren't being changed
    -- If we want to do point respecs too eventually, will probably
    -- need to use the button spend points again, with confirmation dialog
    SendChampionPurchaseRequest()

    if (DynamicCP.savedOptions.quickstarsPlaySound) then
        PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
    end
    -- TODO: add message maybe
end

function DynamicCP.OnQuickstarCancel()
    pendingSlottables = nil
    UpdateAllDropdowns()
end


---------------------------------------------------------------------
-- Window
---------------------------------------------------------------------
-- On move stop
function DynamicCP.SaveQuickstarsPosition()
    DynamicCP.savedOptions.quickstarsX = DynamicCPQuickstars:GetLeft()
    DynamicCP.savedOptions.quickstarsY = DynamicCPQuickstars:GetTop()
end

---------------------------------------------------------------------
-- Reanchors because of toggling

-- Anchors each separate tree within the Lists control, so that they're
-- displayed one above the other
local function AnchorTreeToPrev(tree, prevTree)
    tree:ClearAnchors()

    -- This is the first tree being shown, so anchor it to the Lists control
    if (not prevTree) then
        tree:SetAnchor(TOPLEFT, DynamicCPQuickstarsPanelLists, TOPLEFT)
        return
    end

    -- Else, put it below the previous
    tree:SetAnchor(TOPLEFT, prevTree, BOTTOMLEFT)
end

local function RefreshTreesDisplay()
    local numShowing = 0
    local prevTree
    DynamicCP.HideSlotGroupMenu()

    for _, treeName in ipairs(trees) do
        local tree = DynamicCPQuickstarsPanelLists:GetNamedChild(treeName)
        if (DynamicCP.savedOptions["quickstarsShow" .. treeName]) then
            numShowing = numShowing + 1
            AnchorTreeToPrev(tree, prevTree)
            prevTree = tree
            tree:SetHidden(false)
        else
            tree:SetHidden(true)
        end
    end

    DynamicCPQuickstarsPanelLists:SetHeight(numShowing * 144)

    DynamicCPQuickstarsPanel:SetHidden(numShowing == 0)
end
DynamicCP.RefreshTreesDisplay = RefreshTreesDisplay

---------------------------------------------------------------------
-- Should be called on init and also when user changes window width
function DynamicCP.ResizeQuickstars()
    local dropdownWidth = DynamicCP.savedOptions.quickstarsWidth
    DynamicCPQuickstarsPanelLists:SetWidth(dropdownWidth + 8)

    DynamicCPQuickstarsPanelListsGreen:SetWidth(dropdownWidth + 8)
    DynamicCPQuickstarsPanelListsGreenStar1:SetWidth(dropdownWidth)
    DynamicCPQuickstarsPanelListsGreenStar2:SetWidth(dropdownWidth)
    DynamicCPQuickstarsPanelListsGreenStar3:SetWidth(dropdownWidth)
    DynamicCPQuickstarsPanelListsGreenStar4:SetWidth(dropdownWidth)

    DynamicCPQuickstarsPanelListsBlue:SetWidth(dropdownWidth + 8)
    DynamicCPQuickstarsPanelListsBlueStar1:SetWidth(dropdownWidth)
    DynamicCPQuickstarsPanelListsBlueStar2:SetWidth(dropdownWidth)
    DynamicCPQuickstarsPanelListsBlueStar3:SetWidth(dropdownWidth)
    DynamicCPQuickstarsPanelListsBlueStar4:SetWidth(dropdownWidth)

    DynamicCPQuickstarsPanelListsRed:SetWidth(dropdownWidth + 8)
    DynamicCPQuickstarsPanelListsRedStar1:SetWidth(dropdownWidth)
    DynamicCPQuickstarsPanelListsRedStar2:SetWidth(dropdownWidth)
    DynamicCPQuickstarsPanelListsRedStar3:SetWidth(dropdownWidth)
    DynamicCPQuickstarsPanelListsRedStar4:SetWidth(dropdownWidth)

    -- Orientation
    DynamicCPQuickstarsGreenButton:ClearAnchors()
    DynamicCPQuickstarsBlueButton:ClearAnchors()
    DynamicCPQuickstarsRedButton:ClearAnchors()
    DynamicCPQuickstarsPanelLists:ClearAnchors()
    DynamicCPQuickstarsPanelCancel:ClearAnchors()

    RefreshDisplay()

    if (DynamicCP.savedOptions.quickstarsVertical) then
        DynamicCPQuickstars:SetDimensions(dropdownWidth + 8 + 32 + 24, 172)
        DynamicCPQuickstarsBlueButton:SetAnchor(TOPLEFT, DynamicCPQuickstarsGreenButton, BOTTOMLEFT)
        DynamicCPQuickstarsRedButton:SetAnchor(TOPLEFT, DynamicCPQuickstarsBlueButton, BOTTOMLEFT)
        if (DynamicCP.savedOptions.quickstarsMirrored) then
            -- Opening to the left
            DynamicCPQuickstarsGreenButton:SetAnchor(TOPRIGHT, DynamicCPQuickstars, TOPRIGHT)
            DynamicCPQuickstarsPanelLists:SetAnchor(TOPRIGHT, DynamicCPQuickstarsGreenButton, TOPLEFT)
        else
            -- Opening to the right
            DynamicCPQuickstarsGreenButton:SetAnchor(TOPLEFT, DynamicCPQuickstars, TOPLEFT)
            DynamicCPQuickstarsPanelLists:SetAnchor(TOPLEFT, DynamicCPQuickstarsGreenButton, TOPRIGHT)
        end
        DynamicCPQuickstarsPanelCancel:SetAnchor(TOPRIGHT, DynamicCPQuickstarsPanelLists, BOTTOMRIGHT)
    else
        DynamicCPQuickstars:SetDimensions(dropdownWidth + 8 + 24, 204)
        DynamicCPQuickstarsBlueButton:SetAnchor(TOPLEFT, DynamicCPQuickstarsGreenButton, TOPRIGHT)
        DynamicCPQuickstarsRedButton:SetAnchor(TOPLEFT, DynamicCPQuickstarsBlueButton, TOPRIGHT)
        if (DynamicCP.savedOptions.quickstarsMirrored) then
            -- Opening above, also move the confirm buttons above
            DynamicCPQuickstarsGreenButton:SetAnchor(BOTTOMLEFT, DynamicCPQuickstars, BOTTOMLEFT)
            DynamicCPQuickstarsPanelCancel:SetAnchor(BOTTOMRIGHT, DynamicCPQuickstarsPanelLists, TOPRIGHT)
            DynamicCPQuickstarsPanelLists:SetAnchor(BOTTOMLEFT, DynamicCPQuickstarsGreenButton, TOPLEFT)
        else
            -- Opening below
            DynamicCPQuickstarsGreenButton:SetAnchor(TOPLEFT, DynamicCPQuickstars, TOPLEFT)
            DynamicCPQuickstarsPanelCancel:SetAnchor(TOPRIGHT, DynamicCPQuickstarsPanelLists, BOTTOMRIGHT)
            DynamicCPQuickstarsPanelLists:SetAnchor(TOPLEFT, DynamicCPQuickstarsGreenButton, BOTTOMLEFT)
        end
    end

    DynamicCPQuickstarsPanelListsGreenStar1Unsaved:ClearAnchors()
    DynamicCPQuickstarsPanelListsGreenStar2Unsaved:ClearAnchors()
    DynamicCPQuickstarsPanelListsGreenStar3Unsaved:ClearAnchors()
    DynamicCPQuickstarsPanelListsGreenStar4Unsaved:ClearAnchors()
    DynamicCPQuickstarsPanelListsBlueStar1Unsaved:ClearAnchors()
    DynamicCPQuickstarsPanelListsBlueStar2Unsaved:ClearAnchors()
    DynamicCPQuickstarsPanelListsBlueStar3Unsaved:ClearAnchors()
    DynamicCPQuickstarsPanelListsBlueStar4Unsaved:ClearAnchors()
    DynamicCPQuickstarsPanelListsRedStar1Unsaved:ClearAnchors()
    DynamicCPQuickstarsPanelListsRedStar2Unsaved:ClearAnchors()
    DynamicCPQuickstarsPanelListsRedStar3Unsaved:ClearAnchors()
    DynamicCPQuickstarsPanelListsRedStar4Unsaved:ClearAnchors()
    if (DynamicCP.savedOptions.quickstarsVertical and DynamicCP.savedOptions.quickstarsMirrored) then
        -- If it's vertical and opening to the left, the unsaved icons also need to be on the left side
        DynamicCPQuickstarsPanelListsGreenStar1Unsaved:SetAnchor(RIGHT, DynamicCPQuickstarsPanelListsGreenStar1, LEFT, -8, 0)
        DynamicCPQuickstarsPanelListsGreenStar2Unsaved:SetAnchor(RIGHT, DynamicCPQuickstarsPanelListsGreenStar2, LEFT, -8, 0)
        DynamicCPQuickstarsPanelListsGreenStar3Unsaved:SetAnchor(RIGHT, DynamicCPQuickstarsPanelListsGreenStar3, LEFT, -8, 0)
        DynamicCPQuickstarsPanelListsGreenStar4Unsaved:SetAnchor(RIGHT, DynamicCPQuickstarsPanelListsGreenStar4, LEFT, -8, 0)
        DynamicCPQuickstarsPanelListsBlueStar1Unsaved:SetAnchor(RIGHT, DynamicCPQuickstarsPanelListsBlueStar1, LEFT, -8, 0)
        DynamicCPQuickstarsPanelListsBlueStar2Unsaved:SetAnchor(RIGHT, DynamicCPQuickstarsPanelListsBlueStar2, LEFT, -8, 0)
        DynamicCPQuickstarsPanelListsBlueStar3Unsaved:SetAnchor(RIGHT, DynamicCPQuickstarsPanelListsBlueStar3, LEFT, -8, 0)
        DynamicCPQuickstarsPanelListsBlueStar4Unsaved:SetAnchor(RIGHT, DynamicCPQuickstarsPanelListsBlueStar4, LEFT, -8, 0)
        DynamicCPQuickstarsPanelListsRedStar1Unsaved:SetAnchor(RIGHT, DynamicCPQuickstarsPanelListsRedStar1, LEFT, -8, 0)
        DynamicCPQuickstarsPanelListsRedStar2Unsaved:SetAnchor(RIGHT, DynamicCPQuickstarsPanelListsRedStar2, LEFT, -8, 0)
        DynamicCPQuickstarsPanelListsRedStar3Unsaved:SetAnchor(RIGHT, DynamicCPQuickstarsPanelListsRedStar3, LEFT, -8, 0)
        DynamicCPQuickstarsPanelListsRedStar4Unsaved:SetAnchor(RIGHT, DynamicCPQuickstarsPanelListsRedStar4, LEFT, -8, 0)
    else
        -- Regular unsaved icons on the right
        DynamicCPQuickstarsPanelListsGreenStar1Unsaved:SetAnchor(LEFT, DynamicCPQuickstarsPanelListsGreenStar1, RIGHT, 8, 0)
        DynamicCPQuickstarsPanelListsGreenStar2Unsaved:SetAnchor(LEFT, DynamicCPQuickstarsPanelListsGreenStar2, RIGHT, 8, 0)
        DynamicCPQuickstarsPanelListsGreenStar3Unsaved:SetAnchor(LEFT, DynamicCPQuickstarsPanelListsGreenStar3, RIGHT, 8, 0)
        DynamicCPQuickstarsPanelListsGreenStar4Unsaved:SetAnchor(LEFT, DynamicCPQuickstarsPanelListsGreenStar4, RIGHT, 8, 0)
        DynamicCPQuickstarsPanelListsBlueStar1Unsaved:SetAnchor(LEFT, DynamicCPQuickstarsPanelListsBlueStar1, RIGHT, 8, 0)
        DynamicCPQuickstarsPanelListsBlueStar2Unsaved:SetAnchor(LEFT, DynamicCPQuickstarsPanelListsBlueStar2, RIGHT, 8, 0)
        DynamicCPQuickstarsPanelListsBlueStar3Unsaved:SetAnchor(LEFT, DynamicCPQuickstarsPanelListsBlueStar3, RIGHT, 8, 0)
        DynamicCPQuickstarsPanelListsBlueStar4Unsaved:SetAnchor(LEFT, DynamicCPQuickstarsPanelListsBlueStar4, RIGHT, 8, 0)
        DynamicCPQuickstarsPanelListsRedStar1Unsaved:SetAnchor(LEFT, DynamicCPQuickstarsPanelListsRedStar1, RIGHT, 8, 0)
        DynamicCPQuickstarsPanelListsRedStar2Unsaved:SetAnchor(LEFT, DynamicCPQuickstarsPanelListsRedStar2, RIGHT, 8, 0)
        DynamicCPQuickstarsPanelListsRedStar3Unsaved:SetAnchor(LEFT, DynamicCPQuickstarsPanelListsRedStar3, RIGHT, 8, 0)
        DynamicCPQuickstarsPanelListsRedStar4Unsaved:SetAnchor(LEFT, DynamicCPQuickstarsPanelListsRedStar4, RIGHT, 8, 0)
    end
end


---------------------------------------------------------------------
-- Toggle showing quickstars, persist it
function DynamicCP.ToggleQuickstars()
    DynamicCP.savedOptions.showQuickstars = not DynamicCP.savedOptions.showQuickstars
    DynamicCPQuickstars:SetHidden(not DynamicCP.savedOptions.showQuickstars)
end

-- Called from settings to show quickstars when adjusting the settings
function DynamicCP.ShowQuickstars()
    DynamicCP.savedOptions.showQuickstars = true
    DynamicCPQuickstarsContainer:SetHidden(false)
    DynamicCPQuickstars:SetHidden(false)
end


---------------------------------------------------------------------
-- UI fragment init
function DynamicCP.InitQuickstarsScenes()
    if (not quickstarsFragment) then
        quickstarsFragment = ZO_SimpleSceneFragment:New(DynamicCPQuickstarsContainer)
    end

    if (DynamicCP.savedOptions.quickstarsShowOnHud) then
        HUD_SCENE:AddFragment(quickstarsFragment)
        DynamicCPQuickstarsContainer:SetHidden(false)
    else
        HUD_SCENE:RemoveFragment(quickstarsFragment)
        DynamicCPQuickstarsContainer:SetHidden(true)
    end

    if (DynamicCP.savedOptions.quickstarsShowOnHudUi) then
        HUD_UI_SCENE:AddFragment(quickstarsFragment)
    else
        HUD_UI_SCENE:RemoveFragment(quickstarsFragment)
    end

    if (DynamicCP.savedOptions.quickstarsShowOnCpScreen) then
        CHAMPION_PERKS_SCENE:AddFragment(quickstarsFragment)
        GAMEPAD_CHAMPION_PERKS_SCENE:AddFragment(quickstarsFragment)
    else
        CHAMPION_PERKS_SCENE:RemoveFragment(quickstarsFragment)
        GAMEPAD_CHAMPION_PERKS_SCENE:RemoveFragment(quickstarsFragment)
    end
end


---------------------------------------------------------------------
-- Register the cooldown updates
function OnCooldownStart()
    if (not DynamicCP.savedOptions.quickstarsShowCooldown) then return end
    local secondsRemaining = DynamicCP.GetCooldownSeconds()
    DynamicCPQuickstarsPanelCooldown:SetText(string.format("Cooldown %ds", secondsRemaining))
    DynamicCPQuickstarsPanelCooldown:SetHidden(false)
end

function OnCooldownUpdate()
    local secondsRemaining = DynamicCP.GetCooldownSeconds()
    DynamicCPQuickstarsPanelCooldown:SetText(string.format("Cooldown %ds", secondsRemaining))
end

function OnCooldownEnd()
    DynamicCPQuickstarsPanelCooldown:SetHidden(true)
end

function DynamicCP.QuickstarsOnPurchased()
    -- Refresh quickstars dropdowns with a slight delay, to hopefully avoid the not updated thing
    EVENT_MANAGER:RegisterForUpdate(DynamicCP.name .. "QuickstarsRefresh", 50, function()
        EVENT_MANAGER:UnregisterForUpdate(DynamicCP.name .. "QuickstarsRefresh")
        pendingSlottables = nil
        UpdateAllDropdowns()
    end)
end

---------------------------------------------------------------------
-- First-time hint
local function HintRightClick()
    local hint = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Hint", DynamicCPQuickstars, "QuickstarsSlotSetHint")
    hint:SetAnchor(BOTTOMLEFT, DynamicCPQuickstarsGreenButton, TOPLEFT, -10, -5)
    hint:GetNamedChild("Label"):SetFont(DynamicCP.GetStyles().gameBoldFont)
end

---------------------------------------------------------------------
-- Refreshing all dropdowns on zone change
-- Presumably users wouldn't have pending stuff between zones. This
-- also fixes them being in a weird state after (probably) only
-- Vengeance, when attempting to use and then exiting campaign.
local prevZone = 0
local function OnPlayerActivated()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if (zoneId == prevZone) then return end

    prevZone = zoneId
    UpdateAllDropdowns()
end

---------------------------------------------------------------------
-- Init
local function ApplyQuickstarsFonts()
    local styles = DynamicCP.GetStyles()
    DynamicCPQuickstarsBackdropLockHint:SetFont(styles.smallFont)
    DynamicCPQuickstarsPanelCooldown:SetFont(styles.smallFont)
    DynamicCPQuickstarsContextMenuHint:SetFont(styles.gameFont)
    DynamicCPQuickstarsContextMenuPreviewLabel:SetFont(styles.gameFont)

    local dropdown
    for i = 1, 4 do
        dropdown = ZO_ComboBox_ObjectFromContainer(DynamicCPQuickstarsPanelListsGreen:GetNamedChild("Star" .. i))
        dropdown:SetFont(styles.gameFont)
        dropdown = ZO_ComboBox_ObjectFromContainer(DynamicCPQuickstarsPanelListsBlue:GetNamedChild("Star" .. i))
        dropdown:SetFont(styles.gameFont)
        dropdown = ZO_ComboBox_ObjectFromContainer(DynamicCPQuickstarsPanelListsRed:GetNamedChild("Star" .. i))
        dropdown:SetFont(styles.gameFont)
    end

    DynamicCP.ApplyQuickstarsSlotGroupMenuFonts()
end
DynamicCP.ApplyQuickstarsFonts = ApplyQuickstarsFonts

function DynamicCP.InitQuickstars()
    DynamicCPQuickstars:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, DynamicCP.savedOptions.quickstarsX, DynamicCP.savedOptions.quickstarsY)
    DynamicCPQuickstars:SetHidden(not DynamicCP.savedOptions.showQuickstars)
    DynamicCPQuickstars:SetMovable(not DynamicCP.savedOptions.lockQuickstars)
    DynamicCPQuickstars:SetMouseEnabled(not DynamicCP.savedOptions.lockQuickstars)
    DynamicCPQuickstarsBackdrop:SetHidden(DynamicCP.savedOptions.lockQuickstars)

    DynamicCP.ResizeQuickstars()

    EVENT_MANAGER:RegisterForEvent(DynamicCP.name .. "QuickstarsPlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    OnPlayerActivated()

    local alpha = DynamicCP.savedOptions.quickstarsAlpha
    DynamicCPQuickstarsGreenButtonBackdrop:SetAlpha(alpha)
    DynamicCPQuickstarsBlueButtonBackdrop:SetAlpha(alpha)
    DynamicCPQuickstarsRedButtonBackdrop:SetAlpha(alpha)
    DynamicCPQuickstarsPanelListsGreenBackdrop:SetAlpha(alpha)
    DynamicCPQuickstarsPanelListsBlueBackdrop:SetAlpha(alpha)
    DynamicCPQuickstarsPanelListsRedBackdrop:SetAlpha(alpha)
    DynamicCPQuickstarsPanelCancelBackdrop:SetAlpha(alpha)
    DynamicCPQuickstarsPanelConfirmBackdrop:SetAlpha(alpha)

    DynamicCPQuickstarsPanelListsGreenBackdrop:SetCenterColor(0.55, 0.78, 0.22, 1)
    DynamicCPQuickstarsPanelListsBlueBackdrop:SetCenterColor(0.35, 0.73, 0.9, 1)
    DynamicCPQuickstarsPanelListsRedBackdrop:SetCenterColor(0.88, 0.4, 0.19, 1)

    DynamicCPQuickstars:SetScale(DynamicCP.savedOptions.quickstarsScale)
    DynamicCPQuickstarsPanelCooldown:SetColor(unpack(DynamicCP.savedOptions.quickstarsCooldownColor))

    DynamicCP.InitQuickstarsScenes()

    ApplyQuickstarsFonts()

    DynamicCP.RegisterCooldownListener("Quickstars", OnCooldownStart, OnCooldownUpdate, OnCooldownEnd)

    if (DynamicCP.savedOptions.quickstarsFirstTime) then
        HintRightClick()
        DynamicCP.savedOptions.quickstarsFirstTime = false
    end
end
