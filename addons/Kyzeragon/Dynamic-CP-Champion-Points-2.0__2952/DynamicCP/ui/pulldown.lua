local CREATE_NEW_STRING = "-- Create New --"

---------------------------------------------------------------------
-- Per-tree values
local function GetMiddlePoint(tree)
    if (tree == "Green") then
        return ZO_ChampionPerksActionBarSlot2:GetCenter() + ZO_ChampionPerksActionBarSlot3:GetCenter()
    elseif (tree == "Blue") then
        return ZO_ChampionPerksActionBarSlot6:GetCenter() + ZO_ChampionPerksActionBarSlot7:GetCenter()
    elseif (tree == "Red") then
        return ZO_ChampionPerksActionBarSlot10:GetCenter() + ZO_ChampionPerksActionBarSlot11:GetCenter()
    end
    return 0
end

local TEXT_COLORS = {
    Green = {0.55, 0.78, 0.22},
    Blue = {0.35, 0.73, 0.9},
    Red = {0.88, 0.4, 0.19},
}

local TEXT_COLORS_HEX = {
    Green = "a5d752",
    Blue = "59bae7",
    Red = "e46b2e",
}

local INDEX_TO_TREE = {
    [1] = "Green",
    [2] = "Blue",
    [3] = "Red",
}

local TREE_TO_FIRST_INDEX = {
    Green = 1,
    Blue = 5,
    Red = 9,
}

local function GetStarControlFromIndex(index)
    local tree = INDEX_TO_TREE[math.floor((index - 1) / 4) + 1]
    local starIndex = (index - 1) % 4 + 1
    return DynamicCPPulldown:GetNamedChild(tree):GetNamedChild("Star" .. tostring(starIndex))
end

---------------------------------------------------------------------
-- Slot sets
---------------------------------------------------------------------
local currentSelected = {} -- {Green = "Craft",}

-- Iterate through the UI stars to find the championSkilLData for a skillId
-- I guess this info is UI-only, so this is Not IdealTM
local function FindChampionSkillData(skillId)
    local skillDataFromManager = CHAMPION_DATA_MANAGER:GetChampionSkillData(skillId)
    if (skillDataFromManager) then
        return skillDataFromManager
    end

    -- Not sure if this is still needed. I didn't have the above previously,
    -- but I don't remember if there was a reason I didn't use that or I just didn't know
    for i = 1, ZO_ChampionPerksCanvas:GetNumChildren() do
        local child = ZO_ChampionPerksCanvas:GetChild(i)
        if (child.star and child.star.championSkillData) then
            local id = child.star.championSkillData.championSkillId
            if (id == skillId) then
                return child.star.championSkillData
            end
        end
    end
end

local function LoadSlotSet(tree, id)
    local setData = DynamicCP.savedOptions.slotGroups[tree][id]
    for i = 1, 4 do
        local slot = CHAMPION_PERKS.championBar:GetSlot(TREE_TO_FIRST_INDEX[tree] + i - 1)
        slot:ClearSlot()
        if (setData[i]) then
            slot:AssignChampionSkillToSlot(FindChampionSkillData(setData[i]))
        end
    end
end

local function ShowSlottables(tree, data)
    for i = 1, 4 do
        local starControl = GetStarControlFromIndex(i + TREE_TO_FIRST_INDEX[tree] - 1)
        local skillId = data[i]

        local color = TEXT_COLORS[tree]
        if (skillId) then
            -- Show it in yellow if it's not unlocked
            local unlocked = WouldChampionSkillNodeBeUnlocked(skillId, GetNumPointsSpentOnChampionSkill(skillId))
            if (not unlocked) then
                color = {1, 1, 0.5}
            end
            starControl:GetNamedChild("Name"):SetText(zo_strformat("<<C:1>>", GetChampionSkillName(skillId)))
            if (DynamicCP.savedOptions.showPulldownPoints) then
                starControl:GetNamedChild("Points"):SetText(GetNumPointsSpentOnChampionSkill(skillId))
            else
                starControl:GetNamedChild("Points"):SetText("")
            end
        else
            starControl:GetNamedChild("Name"):SetText("")
            starControl:GetNamedChild("Points"):SetText("")
        end
        starControl.SetColors(color)
    end
end

local function PreviewSlotGroup(tree, slotSetId)
    local data = DynamicCP.savedOptions.slotGroups[tree][slotSetId]
    ShowSlottables(tree, data)
end

local function RestoreSlotGroup(tree)
    local currentSlottables = DynamicCP.GetCurrentUISlottables()

    -- Put it into [1], [2], [3], [4]
    local data = {}
    for i = 1, 4 do
        local index = TREE_TO_FIRST_INDEX[tree] + i - 1
        local slottableSkillData = currentSlottables[index]
        if (slottableSkillData) then
            data[i] = slottableSkillData.championSkillId
        end
    end

    ShowSlottables(tree, data)
end

-- Generate a unique starting name for the slot set
local function FindUniqueSlotSetName(tree)
    local newIndex = 1
    local conflict = false
    while (true) do
        local newName = "Slot Set " .. tostring(newIndex)
        for _, data in pairs(DynamicCP.savedOptions.slotGroups[tree]) do
            if (data.name == newName) then
                conflict = true
                break
            end
        end
        if (not conflict) then
            return newName
        end
        newIndex = newIndex + 1
        conflict = false
    end
end

-- Initialize the dropdown with the saved slot sets
local function InitSlotSetDropdown(tree, idToSelect)
    local dropdownControl = DynamicCPPulldown:GetNamedChild(tree .. "SlotSetControlsDropdown")
    local dropdown = ZO_ComboBox_ObjectFromContainer(dropdownControl)
    dropdown:ClearItems()
    dropdown:SetSortsItems(true)

    -- Add the data to dropdown
    local entryToSelect
    for setId, setData in pairs(DynamicCP.savedOptions.slotGroups[tree]) do
        local function OnItemSelected()
            DynamicCP.dbg("Loading " .. tostring(setId) .. " " .. setData.name)
            LoadSlotSet(tree, setId)
            currentSelected[tree] = setId
            dropdownControl:GetParent():GetNamedChild("Delete"):SetHidden(false)
            dropdownControl:GetParent():GetNamedChild("TextField"):SetHidden(false)
            dropdownControl:GetParent():GetNamedChild("TextField"):SetText(setData.name)
            dropdownControl:GetParent():GetNamedChild("Save"):SetHidden(false)
            DynamicCPPulldownHint:SetHidden(true)
        end

        -- TODO: tooltip on dropdown entry hover with what stars it has?
        local entry = ZO_ComboBox:CreateItemEntry(string.format("|c%s%s|r", TEXT_COLORS_HEX[tree], setData.name), OnItemSelected)
        ZO_ComboBox:SetItemOnEnter(entry, function() PreviewSlotGroup(tree, setId) end)
        ZO_ComboBox:SetItemOnExit(entry, function() RestoreSlotGroup(tree) end)
        dropdown:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)

        if (setId == idToSelect) then
            entryToSelect = entry
        end
    end

    -- Create New entry
    local entry = ZO_ComboBox:CreateItemEntry("|cEBDB34" .. CREATE_NEW_STRING .. "|r", function()
        currentSelected[tree] = nil

        -- Pre-fill the name and show the save button, hide delete button
        local newName = FindUniqueSlotSetName(tree)
        dropdownControl:GetParent():GetNamedChild("TextField"):SetHidden(false)
        dropdownControl:GetParent():GetNamedChild("TextField"):SetText(newName)
        dropdownControl:GetParent():GetNamedChild("Save"):SetHidden(false)
        dropdownControl:GetParent():GetNamedChild("Delete"):SetHidden(true)
        DynamicCPPulldownHint:SetHidden(true)
    end)
    dropdown:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)

    -- TODO: if pending is cancelled, then need to deselect?
    if (entryToSelect) then
        dropdown:SelectItem(entryToSelect)
        currentSelected[tree] = idToSelect
    else
        currentSelected[tree] = nil
    end
    dropdownControl:GetParent():GetNamedChild("Delete"):SetHidden(currentSelected[tree] == nil)
    dropdownControl:GetParent():GetNamedChild("TextField"):SetHidden(currentSelected[tree] == nil)
    dropdownControl:GetParent():GetNamedChild("Save"):SetHidden(currentSelected[tree] == nil)
    dropdown:UpdateItems()
end

local function GetSlotSetString(tree, setData)
    local starsString = ""
    for i = 1, 4 do
        local starName = ""
        if (setData[i]) then
            starName = GetChampionSkillName(setData[i])
        end

        starsString = starsString .. zo_strformat("\n|c<<1>><<2>> - <<C:3>>|r",
            TEXT_COLORS_HEX[tree],
            i,
            starName)
    end

    return starsString
end

local function RemoveSlotSetFromPresets(tree, slotSetId)
    if (not slotSetId) then return end
    for presetName, data in pairs(DynamicCP.savedOptions.cp[tree]) do
        if (data.slotSet == slotSetId) then
            -- TODO: summarize it
            DynamicCP.msg("Removed slot set from preset " .. presetName)
            data.slotSet = nil
        end
    end
end

local function RemoveSlotSetFromRules(tree, slotSetId)
    if (not slotSetId) then return end
    for ruleName, ruleData in pairs(DynamicCP.savedOptions.customRules.rules) do
        if (ruleData.stars[tree] == slotSetId) then
            ruleData.stars[tree] = nil
            DynamicCP.msg("Removed slot set from custom rule " .. ruleName)
        end
    end
end

-- Called from pulldown.xml. When user is done entering a name, either
-- rename the currently selected, or if this is for creating a new set,
-- then do nothing
function DynamicCP.OnSlotSetTextFocusLost(editBox)
    local tree = string.sub(editBox:GetParent():GetParent():GetName(), 18)
    local text = editBox:GetText()

    -- TODO: name validation
    -- If renaming, do it immediately
    if (currentSelected[tree]) then
        if (text == "") then -- Don't allow empty. Put the name back
            editBox:SetText(DynamicCP.savedOptions.slotGroups[tree][currentSelected[tree]].name)
            return
        end

        DynamicCP.savedOptions.slotGroups[tree][currentSelected[tree]].name = text
        InitSlotSetDropdown(tree, currentSelected[tree])
        DynamicCP.RefreshPresetsSlotSetDropdown(tree)
        DynamicCP.BuildSlotSetDropdowns()
        DynamicCP.UpdateSlotSetDropdowns()
    else
        if (text == "") then -- Don't allow empty. Generate a name again
            editBox:SetText(FindUniqueSlotSetName(tree))
        end
    end
end

-- Called from pulldown.xml. Delete the currently selected slot set
function DynamicCP.DeleteSlotSet(button)
    local tree = string.sub(button:GetParent():GetParent():GetName(), 18)
    local setId = currentSelected[tree]

    local starsString = GetSlotSetString(tree, DynamicCP.savedOptions.slotGroups[tree][setId])
    local function OnDeleteConfirmed()
        DynamicCP.savedOptions.slotGroups[tree][setId] = nil
        InitSlotSetDropdown(tree)
        RemoveSlotSetFromPresets(tree, setId)
        RemoveSlotSetFromRules(tree, setId)
        DynamicCP.RefreshPresetsSlotSetDropdown(tree)
        DynamicCP.BuildSlotSetDropdowns()
        DynamicCP.UpdateSlotSetDropdowns()
    end

    local setName = DynamicCP.savedOptions.slotGroups[tree][setId].name
    DynamicCP.ShowConfirmationDialog(
        "ConfirmDeleteSlotSet",
        "Confirm Deleting Slottable Set",
        zo_strformat("Delete |c<<1>><<2>>|r with the following slottables?<<3>>", TEXT_COLORS_HEX[tree], setName, starsString),
        OnDeleteConfirmed)
end

local function GetNewSlotSetId(tree)
    local i = 1
    while true do
        local attempt = tree .. tostring(i)
        if (not DynamicCP.savedOptions.slotGroups[tree][attempt]) then
            return attempt
        end
        i = i + 1
    end
end

-- Called from pulldown.xml. Save the UI-pending slottables into a slot set
function DynamicCP.SaveSlotSet(button)
    local tree = string.sub(button:GetParent():GetParent():GetName(), 18)
    local pendingName = button:GetParent():GetNamedChild("TextField"):GetText()
    if (not pendingName or pendingName == "") then
        d("|cFF0000Pending name is empty; this shouldn't be reachable!|r")
        return
    end

    local firstIndex = TREE_TO_FIRST_INDEX[tree]
    local currentSlottables = DynamicCP.GetCurrentUISlottables()

    -- Collect into setData
    local setData = {}
    for i = 1, 4 do
        local slottableSkillData = currentSlottables[firstIndex + i - 1]
        if (slottableSkillData) then
            setData[i] = slottableSkillData.championSkillId
        end
    end
    setData.name = pendingName

    local setId
    local dialogTitle, dialogFormat
    if (currentSelected[tree] ~= nil) then
        -- Overwriting the current
        setId = currentSelected[tree]
        dialogTitle = "Confirm Overwriting Slottable Set"
        dialogFormat = "Overwrite |c<<1>><<2>>|r?<<3>>"
    else
        -- Or making a new set
        setId = GetNewSlotSetId(tree)
        dialogTitle = "Confirm Saving Slottable Set"
        dialogFormat = "Save the following as |c<<1>><<2>>|r?<<3>>"
    end

    -- Save in data
    local starsString = GetSlotSetString(tree, setData)
    local function OnSaveConfirmed()
        DynamicCP.savedOptions.slotGroups[tree][setId] = setData
        InitSlotSetDropdown(tree, setId)
        DynamicCP.RefreshPresetsSlotSetDropdown(tree)
        DynamicCP.BuildSlotSetDropdowns()
        DynamicCP.UpdateSlotSetDropdowns()
    end

    DynamicCP.ShowConfirmationDialog(
        "ConfirmSaveSlotSet",
        dialogTitle,
        zo_strformat(dialogFormat, TEXT_COLORS_HEX[tree], pendingName, starsString),
        OnSaveConfirmed)
end

---------------------------------------------------------------------
-- Since U43, the ActionBar has deferred initialization, so it's
-- possible the user hasn't opened the CP screen yet before changing
-- CP via addons
DynamicCP.pulldownInitialized = false

---------------------------------------------------------------------
-- Update every item in the pulldown
local function ApplyCurrentSlottables(currentSlottables)
    if (not DynamicCP.pulldownInitialized) then return end

    for index = 1, 12 do
        local slottableSkillData = currentSlottables[index]
        local star = GetStarControlFromIndex(index)

        local tree = "Red"
        if (index <= 4) then
            tree = "Green"
        elseif (index <= 8) then
            tree = "Blue"
        end
        star.SetColors(TEXT_COLORS[tree])

        -- It could be empty
        if (not slottableSkillData) then
            star:GetNamedChild("Name"):SetText("")
            star:GetNamedChild("Points"):SetText("")
        else
            -- Set labels
            local id = slottableSkillData.championSkillId
            star:GetNamedChild("Name"):SetText(zo_strformat("<<C:1>>", GetChampionSkillName(id)))

            -- TODO: show pending points after refactor
            if (DynamicCP.savedOptions.showPulldownPoints) then
                star:GetNamedChild("Points"):SetText(GetNumPointsSpentOnChampionSkill(id))
            else
                star:GetNamedChild("Points"):SetText("")
            end
        end
    end
end
DynamicCP.ApplyCurrentSlottables = ApplyCurrentSlottables


---------------------------------------------------------------------
-- Expand / hide the pulldown
local function TogglePulldown()
    if (DynamicCPPulldown:IsHidden()) then
        -- Expand it
        DynamicCPPulldownTabArrowExpanded:SetHidden(IsConsoleUI())
        DynamicCPPulldownTabArrowHidden:SetHidden(true)
        DynamicCPPulldown:SetHidden(false)
        DynamicCPPulldownTab:SetAnchor(TOP, DynamicCPPulldown, BOTTOM)
        DynamicCP.savedOptions.pulldownExpanded = true
    else
        -- Hide it
        DynamicCPPulldownTabArrowExpanded:SetHidden(true)
        DynamicCPPulldownTabArrowHidden:SetHidden(IsConsoleUI())
        DynamicCPPulldown:SetHidden(true)
        DynamicCPPulldownTab:SetAnchor(TOP, ZO_ChampionPerksActionBar, BOTTOM)
        DynamicCP.savedOptions.pulldownExpanded = false
    end
end
DynamicCP.TogglePulldown = TogglePulldown


---------------------------------------------------------------------
-- tree = "Green" "Blue" "Red"
local function InitTree(control, tree)
    local width = ZO_ChampionPerksActionBarSlot4:GetRight() - ZO_ChampionPerksActionBarSlot1:GetLeft() + 20

    -- Size and position
    control:SetHeight(40)
    control:SetWidth(width)
    control:SetAnchor(TOP, GuiRoot, TOPLEFT, GetMiddlePoint(tree) / 2, ZO_ChampionPerksActionBar:GetBottom())

    -- Stars
    local color = TEXT_COLORS[tree]

    -- Widths are set on reanchor, star 3 & 4 anchors also
    local star1 = CreateControlFromVirtual("$(parent)Star1", control, "DynamicCPPulldownStar", "")
    star1:SetAnchor(TOPLEFT, control, TOPLEFT)
    star1.SetColors(color)
    local star2 = CreateControlFromVirtual("$(parent)Star2", control, "DynamicCPPulldownStar", "")
    star2:SetAnchor(TOPLEFT, star1, BOTTOMLEFT)
    star2.SetColors(color)
    local star3 = CreateControlFromVirtual("$(parent)Star3", control, "DynamicCPPulldownStar", "")
    star3.SetColors(color)
    local star4 = CreateControlFromVirtual("$(parent)Star4", control, "DynamicCPPulldownStar", "")
    star4.SetColors(color)

    -- Slot set controls
    local setControls = CreateControlFromVirtual("$(parent)SlotSetControls", control, "DynamicCPPulldownSetControls", "")
    setControls:SetWidth(width - 10)
    setControls:GetNamedChild("Dropdown"):SetWidth(width - 40)
    setControls:GetNamedChild("TextField"):SetWidth(width - 40)

    InitSlotSetDropdown(tree)
end

local function ApplyPulldownFonts()
    if (not DynamicCP.pulldownInitialized) then return end

    local styles = DynamicCP.GetStyles()

    -- Star names
    for i = 1, 12 do
        GetStarControlFromIndex(i):GetNamedChild("Name"):SetFont(styles.smallFont)
        GetStarControlFromIndex(i):GetNamedChild("Points"):SetFont(styles.smallFont)
    end

    -- Slot set dropdowns
    for tree, _ in pairs(TREE_TO_FIRST_INDEX) do
        local dropdown = ZO_ComboBox_ObjectFromContainer(DynamicCPPulldown:GetNamedChild(tree .. "SlotSetControlsDropdown"))
        dropdown:SetFont(styles.gameFont)
    end

    -- Hint
    DynamicCPPulldownHint:SetFont(styles.gameFont)
end
DynamicCP.ApplyPulldownFonts = ApplyPulldownFonts

local function ResetSlots()
    InitSlotSetDropdown("Green")
    InitSlotSetDropdown("Blue")
    InitSlotSetDropdown("Red")

    if (DynamicCP.savedOptions.showPulldownSlottableSets) then
        DynamicCPPulldownHint:SetHidden(false)
    end
end

local function ReanchorPulldown()
    if (not DynamicCP.pulldownInitialized) then return end

    DynamicCPPulldownGreen:SetAnchor(TOP, GuiRoot, TOPLEFT, GetMiddlePoint("Green") / 2, ZO_ChampionPerksActionBar:GetBottom())
    DynamicCPPulldownBlue:SetAnchor(TOP, GuiRoot, TOPLEFT, GetMiddlePoint("Blue") / 2, ZO_ChampionPerksActionBar:GetBottom())
    DynamicCPPulldownRed:SetAnchor(TOP, GuiRoot, TOPLEFT, GetMiddlePoint("Red") / 2, ZO_ChampionPerksActionBar:GetBottom())

    -- Slottable sets enabled/disabled below
    local useSlotSets = DynamicCP.savedOptions.showPulldownSlottableSets
    DynamicCPPulldown:SetHeight(useSlotSets and 104 or 92)

    ResetSlots()
    if (not useSlotSets) then
        DynamicCPPulldownHint:SetHidden(true)
    end
    DynamicCPPulldownGreenSlotSetControls:SetHidden(not useSlotSets)
    DynamicCPPulldownBlueSlotSetControls:SetHidden(not useSlotSets)
    DynamicCPPulldownRedSlotSetControls:SetHidden(not useSlotSets)

    local width = ZO_ChampionPerksActionBarSlot4:GetRight() - ZO_ChampionPerksActionBarSlot1:GetLeft()
    local starNameLength = (useSlotSets and width / 2 or width) - (DynamicCP.savedOptions.showPulldownPoints and 20 or 0)

    for _, tree in pairs(INDEX_TO_TREE) do
        DynamicCPPulldown:GetNamedChild(tree):SetWidth(width + 20) -- TODO

        local star1 = DynamicCPPulldown:GetNamedChild(tree .. "Star1")
        local star2 = DynamicCPPulldown:GetNamedChild(tree .. "Star2")
        local star3 = DynamicCPPulldown:GetNamedChild(tree .. "Star3")
        local star4 = DynamicCPPulldown:GetNamedChild(tree .. "Star4")

        star1:GetNamedChild("Name"):SetWidth(starNameLength)
        star2:GetNamedChild("Name"):SetWidth(starNameLength)
        star3:GetNamedChild("Name"):SetWidth(starNameLength)
        star4:GetNamedChild("Name"):SetWidth(starNameLength)

        star3:ClearAnchors()
        star4:ClearAnchors()

        if (useSlotSets) then
            star1:SetWidth((width + 20) / 2)
            star2:SetWidth((width + 20) / 2)
            star3:SetWidth((width + 20) / 2)
            star4:SetWidth((width + 20) / 2)
            star3:SetAnchor(LEFT, star1, RIGHT)
            star4:SetAnchor(LEFT, star2, RIGHT)
        else
            star1:SetWidth(width + 20)
            star2:SetWidth(width + 20)
            star3:SetWidth(width + 20)
            star4:SetWidth(width + 20)
            star3:SetAnchor(TOPLEFT, star2, BOTTOMLEFT)
            star4:SetAnchor(TOPLEFT, star3, BOTTOMLEFT)
        end
    end
end
DynamicCP.ReanchorPulldown = ReanchorPulldown

function DynamicCP.InitPulldown()
    InitTree(DynamicCPPulldownGreen, "Green")
    InitTree(DynamicCPPulldownBlue, "Blue")
    InitTree(DynamicCPPulldownRed, "Red")

    ZO_PreHook(CHAMPION_PERKS:GetChampionBar(), "ResetAllSlots", ResetSlots)

    DynamicCP.pulldownInitialized = true

    ApplyPulldownFonts()
    ReanchorPulldown()
end
