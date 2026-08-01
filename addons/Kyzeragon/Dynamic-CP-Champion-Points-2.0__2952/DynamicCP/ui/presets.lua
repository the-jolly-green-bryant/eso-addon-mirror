local PSB = DynamicCP.PointsStringBuilder

local CREATE_NEW_STRING = "-- Create New --"
local MESSAGES_TOOLTIP_GAP = 24

local ROLE_TO_STRING = {
    [LFG_ROLE_DPS] = "Dps",
    [LFG_ROLE_HEAL] = "Healer",
    [LFG_ROLE_TANK] = "Tank",
}

local CLASSES = {
    Dragonknight = true,
    Sorcerer = true,
    Nightblade = true,
    Templar = true,
    Warden = true,
    Necromancer = true,
}

local ROLES = {
    Tank = true,
    Healer = true,
    Dps = true,
}

-- This is the INDEX, not ID
local TREE_TO_DISCIPLINE = {
    Green = 1,
    Blue = 2,
    Red = 3,
}

local HOTBAR_OFFSET = {
    Green = 0,
    Blue = 4,
    Red = 8,
}

local isRespeccing = false

---------------------------------------------------------------------
local selected = {
    Red = nil,
    Green = nil,
    Blue = nil,
}

---------------------------------------------------------------------
function GetSubControl(name)
    if (not name) then
        name = ""
    end

    return DynamicCPSidePresets:GetNamedChild(name)
end
DynamicCP.GetSubControl = GetSubControl

---------------------------------------------------------------------
-- Strip control name down to just Red/Green/Blue
local function GetTreeName(name, prefix, suffix)
    return name:sub(prefix:len() + 1, name:len() - suffix:len())
end

---------------------------------------------------------------------
-- Show a message in the area under the options
local function ShowMessage(tree, text, diffText, color, numChanges, col1, col2, slottablesText)
    local messages = GetSubControl("Inner"):GetNamedChild(tree .. "Messages")
    if (not diffText) then diffText = "" end
    messages:SetHidden(false)

    if (not text) then text = messages:GetNamedChild("Label"):GetText() end

    numChanges = numChanges or 0

    -- Append the slottables to the end
    if (slottablesText) then
        for i, slottableString in ipairs(slottablesText) do
            table.insert(col1, slottableString)
            table.insert(col2, "")
            numChanges = numChanges + 1
        end
    end

    messages:GetNamedChild("Backdrop"):SetEdgeColor(unpack(color))
    messages:GetNamedChild("Label"):SetText(text)
    messages:GetNamedChild("Tooltip"):SetHidden(diffText == nil or diffText == "")
    messages:GetNamedChild("Tooltip"):SetHeight(numChanges * 19 + 4)

    if (numChanges == 0) then
        numChanges = 1
        messages:GetNamedChild("Tooltip"):SetHeight(numChanges * 19 + 4)
        if (col1) then
            table.insert(col1, "No points changes.")
        end
    end

    if (col1 ~= nil and col2 ~= nil) then
        -- Adjust width of the popup
        local col1Text = table.concat(col1, "\n")
        local col2Text = table.concat(col2, "\n")
        messages:GetNamedChild("TooltipLabel"):SetText(col1Text)
        messages:GetNamedChild("TooltipLabel2"):SetText(col2Text)
        messages:GetNamedChild("Tooltip"):SetWidth(500)
        messages:GetNamedChild("Tooltip"):SetWidth(messages:GetNamedChild("TooltipLabel"):GetTextWidth() + messages:GetNamedChild("TooltipLabel2"):GetTextWidth() + MESSAGES_TOOLTIP_GAP)
    else
        messages:GetNamedChild("TooltipLabel"):SetText(diffText)
        messages:GetNamedChild("TooltipLabel2"):SetText("")
    end

    -- Do a second panel
    if (numChanges >= 12 and col1 ~= nil and col2 ~= nil) then
        local halfLines = math.floor((numChanges + 1) / 2)

        local col1Text = table.concat(col1, "\n", 1, halfLines)
        local col2Text = table.concat(col2, "\n", 1, halfLines)
        messages:GetNamedChild("Tooltip"):SetHeight(halfLines * 19 + 4)
        messages:GetNamedChild("TooltipLabel"):SetText(col1Text)
        messages:GetNamedChild("TooltipLabel2"):SetText(col2Text)
        messages:GetNamedChild("Tooltip"):SetWidth(500)
        messages:GetNamedChild("Tooltip"):SetWidth(messages:GetNamedChild("TooltipLabel"):GetTextWidth() + messages:GetNamedChild("TooltipLabel2"):GetTextWidth() + MESSAGES_TOOLTIP_GAP)

        col1Text = table.concat(col1, "\n", halfLines + 1, #col1)
        col2Text = table.concat(col2, "\n", halfLines + 1, #col2)
        messages:GetNamedChild("TooltipExtra"):SetHidden(false)
        messages:GetNamedChild("TooltipExtra"):SetHeight(halfLines * 19 + 4)
        messages:GetNamedChild("TooltipExtraLabel"):SetText(col1Text)
        messages:GetNamedChild("TooltipExtraLabel2"):SetText(col2Text)
        messages:GetNamedChild("TooltipExtra"):SetWidth(500)
        messages:GetNamedChild("TooltipExtra"):SetWidth(messages:GetNamedChild("TooltipExtraLabel"):GetTextWidth() + messages:GetNamedChild("TooltipExtraLabel2"):GetTextWidth() + MESSAGES_TOOLTIP_GAP + 10)
    else
        messages:GetNamedChild("TooltipExtra"):SetHidden(true)
    end

    -- Need to move it upwards if it's a "delete" which means nothing is selected and it looks empty
    if (GetSubControl("Inner"):GetNamedChild(tree .. "Options"):IsHidden()) then
        messages:SetAnchor(TOP, GetSubControl("Inner"):GetNamedChild(tree .. "Dropdown"), BOTTOM, 0, 4)
    else
        messages:SetAnchor(TOP, GetSubControl("Inner"):GetNamedChild(tree .. "OptionsButtons"), BOTTOM, 0, 0)
    end
end

local function HideMessage(tree)
    local messages = GetSubControl("Inner"):GetNamedChild(tree .. "Messages")
    messages:SetHidden(true)
end


---------------------------------------------------------------------
local function DisplayMildWarning(text)
    DynamicCPMildWarningLabel:SetText(text)
    DynamicCPMildWarningLabel:SetFont(DynamicCP.GetStyles().gameFont)
    DynamicCPMildWarning:SetHidden(false)
    DynamicCPMildWarning:ClearAnchors()
    DynamicCPMildWarning:SetAnchor(BOTTOM, DynamicCPWarning, TOP, 0, -10)
end

local function SetMildWarning(text)
    DynamicCPMildWarning:SetText(text)
end

local function HideMildWarning()
    DynamicCPMildWarning:SetHidden(true)
end


---------------------------------------------------------------------
-- Apply
---------------------------------------------------------------------
-- Apply the slottables
local function ApplySlottables(tree)
    local presetName = selected[tree]

    local slottablesResult
    -- From smart preset
    if (DynamicCP.SMART_PRESETS[tree][presetName]) then
        -- TODO
        slottablesResult = DynamicCP.SMART_PRESETS[tree][presetName].applyFunc().slottables
    else
        -- From user preset or automatic
        slottablesResult = DynamicCP.GetSlottablesDynamically(DynamicCP.savedOptions.cp[tree][presetName], tree)
    end


    local offset = HOTBAR_OFFSET[tree]
    for i = 1, 4 do
        local skillId = slottablesResult[i] or -1
        DynamicCP.SetSlottableInIndex(i + offset, skillId)
        DynamicCP.dbg(zo_strformat("adding <<C:1>> to slot <<2>>", GetChampionSkillName(skillId), i + offset))
    end
end

-- When apply button is clicked
function DynamicCP:OnApplyClicked(button)
    local tree = GetTreeName(button:GetName(), GetSubControl():GetName() .. "Inner", "OptionsApplyButton")
    local presetName = selected[tree]

    if (not presetName) then
        d("You shouldn't be seeing this message! Please leave Kyzer a message saying which buttons you clicked to get here. OnApplyClicked")
        return
    end

    DynamicCP.dbg("Attempting to apply \"" .. presetName .. "\" to the " .. tree .. " tree.")

    -- Either load the saved preset, or use smart preset
    local cp
    if (DynamicCP.SMART_PRESETS[tree][presetName]) then
        cp = DynamicCP.SMART_PRESETS[tree][presetName].applyFunc()
    else
        cp = DynamicCP.savedOptions.cp[tree][presetName]
    end


    local currentCP = DynamicCP.GetCommittedCP()

    -- First find all of the slottable skillIds to check them later
    local currentHotbar = {}
    for slotIndex = 1, 12 do
        local skillId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_CHAMPION)
        currentHotbar[skillId] = slotIndex
    end

    if (not isRespeccing) then
        DynamicCP.ClearPendingCP()
        DynamicCP.ClearPendingSlottables()
        isRespeccing = true
    end

    -- Apply all stars within the tree
    local disciplineIndex = TREE_TO_DISCIPLINE[tree]
    local hasOverMaxPoints = false
    for skillIndex = 1, GetNumChampionDisciplineSkills(disciplineIndex) do
        local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
        local numPoints = 0
        if (cp[disciplineIndex] and cp[disciplineIndex][skillId] ~= nil) then
            local maxPoints = GetChampionSkillMaxPoints(skillId)
            if (cp[disciplineIndex][skillId] > maxPoints) then
                numPoints = maxPoints
                hasOverMaxPoints = true
            else
                numPoints = cp[disciplineIndex][skillId]
            end
        else
            DynamicCP.dbg("else" .. GetChampionSkillName(skillId))
            numPoints = 0
        end

        -- Unslot slottables that are no longer slottable because of not enough points
        -- We still do this even though slottables are replaced later because user could have slotStars setting off [TODO: is this still needed?]
        if (currentHotbar[skillId] and not WouldChampionSkillNodeBeUnlocked(skillId, numPoints)) then
            DynamicCP.dbg("unslotting" .. GetChampionSkillName(skillId))
            DynamicCP.SetSlottableInIndex(currentHotbar[skillId], -1)
        end

        DynamicCP.SetStarPoints(disciplineIndex, skillId, numPoints)
    end

    -- Slottables
    ApplySlottables(tree)

    local diffText, numChanges, col1, col2, slottablesText = PSB.GenerateDiff(DynamicCP.GetCommittedCP(), cp)
    ShowMessage(tree, "|c00FF00Preset loaded!\nPress \"Confirm\" to commit.|r", diffText, {0, 1, 0, 1}, numChanges, col1, col2, slottablesText)
    -- Unhide confirm button and also update the cost
    GetSubControl("InnerConfirmButton"):SetHidden(false)
    GetSubControl("InnerCancelButton"):SetHidden(false)
    if (DynamicCP.NeedsRespec()) then
        GetSubControl("InnerConfirmButton"):SetText("Confirm (" .. tostring(GetChampionRespecCost()) .. " |t18:18:esoui/art/currency/currency_gold.dds|t)")
    else
        GetSubControl("InnerConfirmButton"):SetText("Confirm")
    end

    -- Show warning message
    if (hasOverMaxPoints) then
        DisplayMildWarning("Warning: the preset you applied has more than the maximum points allowed in certain stars. The points will be left as extra. Make sure to save the preset after you allocate your points to overwrite the old preset! If this was a default preset, you can also re-import all of the default presets in the add-on settings by clicking on the gear icon.")
    end
end


---------------------------------------------------------------------
-- When confirm button is clicked
function DynamicCP:OnConfirmClicked(button)
    local needsRespec = DynamicCP.NeedsRespec()
    DynamicCP.dbg("needs respec? " .. (needsRespec and "yes" or "no"))

    local function CommitPoints()
        PrepareChampionPurchaseRequest(needsRespec)
        DynamicCP.ConvertPendingPointsToPurchase()
        DynamicCP.ConvertPendingSlottablesToPurchase()
        SendChampionPurchaseRequest()

        isRespeccing = false
        DynamicCP.ClearPendingCP()
        DynamicCP.ClearPendingSlottables()
        GetSubControl("InnerConfirmButton"):SetHidden(true)
        GetSubControl("InnerCancelButton"):SetHidden(true)
        HideMessage("Green")
        HideMessage("Blue")
        HideMessage("Red")
    end

    local respecCost = "\nRedistribution cost: "  .. GetChampionRespecCost() .. " |t18:18:esoui/art/currency/currency_gold.dds|t"
    DynamicCP.ShowConfirmationDialog(
        "ConfirmConfirmation",
        "Confirm Changes",
        "Are you sure you want to commit your points?" .. (needsRespec and respecCost or ""),
        CommitPoints)
end


---------------------------------------------------------------------
-- When cancel button is clicked
function DynamicCP:OnCancelClicked()
    isRespeccing = false
    DynamicCP.ClearPendingCP()
    DynamicCP.ClearPendingSlottables()
    GetSubControl("InnerConfirmButton"):SetHidden(true)
    GetSubControl("InnerCancelButton"):SetHidden(true)
    HideMessage("Green")
    HideMessage("Blue")
    HideMessage("Red")
end


---------------------------------------------------------------------
-- Perform saving of CP preset
local function SavePreset(tree, oldName, presetName, newCP, message)
    if (oldName ~= CREATE_NEW_STRING) then
        DynamicCP.savedOptions.cp[tree][oldName] = nil
    end

    DynamicCP.savedOptions.cp[tree][presetName] = newCP

    DynamicCP:InitializeDropdown(tree, presetName)
    DynamicCP.dbg("|c00FF00Saved preset \"" .. presetName .. "\"|r")

    message = message or ("|c00FF00Done! Saved preset \"" .. presetName .. "\"|r")
    local treeText, numChanges, col1, col2, slottablesText = PSB.GenerateTree(newCP, tree)
    ShowMessage(tree, message, treeText, {0, 1, 0, 1}, numChanges, col1, col2, slottablesText)
end


---------------------------------------------------------------------
-- When save button is clicked
function DynamicCP:OnSaveClicked(button, tree)
    tree = tree or GetTreeName(button:GetName(), GetSubControl():GetName() .. "Inner", "OptionsSaveButton")
    local presetName = selected[tree]
    if (presetName == nil) then
        d("You shouldn't be seeing this message! Please leave Kyzer a message saying which buttons you clicked to get here. OnSaveClicked")
        return
    end

    -- Do a deep copy
    local currentCP = DynamicCP.GetCommittedCP()
    local newCP = {}
    local disciplineIndex = TREE_TO_DISCIPLINE[tree]
    newCP[disciplineIndex] = {}
    for k, v in pairs(currentCP[disciplineIndex]) do
        newCP[disciplineIndex][k] = v
    end
    -- Also copy the other things like role and class
    if (DynamicCP.savedOptions.cp[tree][presetName]) then
        for index, value in pairs(DynamicCP.savedOptions.cp[tree][presetName]) do
            if (index ~= disciplineIndex and type(index) == "table") then
                newCP[index] = {}
                for k, v in pairs(DynamicCP.savedOptions.cp[tree][presetName][index]) do
                    newCP[index][k] = v
                end
            elseif (index == "slotSet") then
                newCP[index] = value
            end
        end
    end

    -- Don't want to deal with formatting, colors are stripped when parsing name from dropdown
    local newName = GetSubControl("Inner"):GetNamedChild(tree .. "OptionsTextField"):GetText()
    if (newName:find("|")) then
        ShowMessage(tree, "|cFF0000\"||\" is not allowed in preset names.|r", nil, {1, 0, 0, 1}, 0)
        return
    end

    -- New and no conflict
    if (presetName == CREATE_NEW_STRING and not DynamicCP.savedOptions.cp[tree][newName]) then
        DynamicCP.dbg("Saving to new preset")
        SavePreset(tree, presetName, newName, newCP)

    -- New but has the same name as existing... OR overwrite existing that has been selected
    elseif (presetName == CREATE_NEW_STRING or presetName == newName) then
        DynamicCP.dbg("Overwriting existing preset")
        local function OverwritePreset()
            SavePreset(tree, presetName, newName, newCP,
                "|c00FF00Done! Overwrote preset \"" .. presetName .. "\"|r")
        end

        DynamicCP.ShowConfirmationDialog(
            "OverwriteConfirmation",
            "Overwrite Preset",
            "Overwrite the \"" .. newName .. "\" preset?\n" .. PSB.GenerateDiff(DynamicCP.savedOptions.cp[tree][newName], currentCP),
            OverwritePreset)

    else
        d("You shouldn't be seeing this message! Please leave Kyzer a message saying which buttons you clicked to get here. OnSaveClicked fallthrough")
    end
end


---------------------------------------------------------------------
-- When focus is lost on the text field
function DynamicCP:OnTextFocusLost(textfield)
    DynamicCP.dbg("focus lost")
    local tree = GetTreeName(textfield:GetName(), GetSubControl():GetName() .. "Inner", "OptionsTextField")
    local presetName = selected[tree]
    if (presetName == nil) then
        d("You shouldn't be seeing this message! Please leave Kyzer a message saying which buttons you clicked to get here. OnTextFocusLost")
        return
    end

    if (presetName == CREATE_NEW_STRING) then
        return
    end

    local newName = GetSubControl("Inner"):GetNamedChild(tree .. "OptionsTextField"):GetText()

    if (newName:find("|")) then
        ShowMessage(tree, "|cFF0000\"||\" is not allowed in preset names.|r", nil, {1, 0, 0, 1}, 0)
        return
    end


    if (presetName == newName) then
        return
    end

    -- We are renaming an existing preset
    SavePreset(tree, presetName, newName, DynamicCP.savedOptions.cp[tree][presetName],
        "|c00FF00Renamed preset \"" .. presetName .. "\" to \"" .. newName .. "\"|r")
end


---------------------------------------------------------------------
-- When delete button is clicked
function DynamicCP:OnDeleteClicked(button)
    local tree = GetTreeName(button:GetName(), GetSubControl():GetName() .. "Inner", "OptionsDeleteButton")
    local presetName = selected[tree]
    if (presetName == nil or presetName == CREATE_NEW_STRING) then
        d("You shouldn't be seeing this message! Please leave Kyzer a message saying which buttons you clicked to get here. OnDeleteClicked")
        return
    end

    function DeletePreset()
        DynamicCP.savedOptions.cp[tree][presetName] = nil
        DynamicCP:InitializeDropdown(tree)
        DynamicCP.dbg("Deleted " .. presetName)
        ShowMessage(tree, "|c00FF00Preset \"" .. presetName .. "\" deleted.|r", nil, {0, 1, 0, 1}, 0)
    end

    DynamicCP.ShowConfirmationDialog(
        "DeleteConfirmation",
        "Delete Preset",
        "Delete the \"" .. presetName .. "\" preset?",
        DeletePreset)
end


---------------------------------------------------------------------
-- Hide/unhide the options
local function AdjustDividers()
    local r = not GetSubControl("Inner"):GetNamedChild("RedOptions"):IsHidden() or not GetSubControl("Inner"):GetNamedChild("RedMessages"):IsHidden()
    local g = not GetSubControl("Inner"):GetNamedChild("GreenOptions"):IsHidden() or not GetSubControl("Inner"):GetNamedChild("GreenMessages"):IsHidden()
    local b = not GetSubControl("Inner"):GetNamedChild("BlueOptions"):IsHidden() or not GetSubControl("Inner"):GetNamedChild("BlueMessages"):IsHidden()

    GetSubControl("InnerInstructions"):SetHidden(r or g or b)
end

local function UnhideOptions(tree)
    GetSubControl("Inner"):GetNamedChild(tree .. "Options"):SetHidden(false)
    AdjustDividers()
end

local function HideOptions(tree)
    GetSubControl("Inner"):GetNamedChild(tree .. "Options"):SetHidden(true)
    AdjustDividers()
end


---------------------------------------------------------------------
-- Class/Role buttons

local function DecoratePresetName(presetName, cp)
    local class = GetUnitClass("player")
    local role = ROLE_TO_STRING[GetSelectedLFGRole()]

    if (cp.classes and not cp.classes[class]) then
        return "|c444444" .. presetName .. "|r"
    elseif (cp.roles and not cp.roles[role]) then
        return "|c444444" .. presetName .. "|r"
    else
        return "|c9FBFAF" .. presetName .. "|r"
    end
end

local function SetTextureButtonEnabled(textureButton, enabled)
    textureButton.enabled = enabled
    if (enabled) then
        textureButton:SetColor(0.9, 1, 0.9)
    else
        textureButton:SetColor(0.4, 0.3, 0.3)
    end
end

function DynamicCP:ToggleOptionButton(textureButton)
    local tree = GetTreeName(textureButton:GetName(), GetSubControl():GetName() .. "Inner", "OptionsButtons" .. (textureButton.class or textureButton.role))

    if (selected[tree] == CREATE_NEW_STRING) then
        d("You shouldn't be seeing this message! Please leave Kyzer a message saying which buttons you clicked to get here. ToggleOptionButton")
        return
    end

    SetTextureButtonEnabled(textureButton, not textureButton.enabled)
    local presetName = selected[tree]

    -- Immediately save to the preset when buttons are toggled
    if (textureButton.class) then
        if (not DynamicCP.savedOptions.cp[tree][presetName].classes) then
            DynamicCP.savedOptions.cp[tree][presetName].classes = {
                Dragonknight = true,
                Sorcerer = true,
                Nightblade = true,
                Templar = true,
                Warden = true,
                Necromancer = true,
            }
        end
        DynamicCP.savedOptions.cp[tree][presetName].classes[textureButton.class] = textureButton.enabled
    elseif (textureButton.role) then
        if (not DynamicCP.savedOptions.cp[tree][presetName].roles) then
            DynamicCP.savedOptions.cp[tree][presetName].roles = {
                Tank = true,
                Healer = true,
                Dps = true,
            }
        end
        DynamicCP.savedOptions.cp[tree][presetName].roles[textureButton.role] = textureButton.enabled
    end

    -- Update the dropdown to reflect matching or not matching
    local dropdown = ZO_ComboBox_ObjectFromContainer(GetSubControl("Inner"):GetNamedChild(tree .. "Dropdown"))
    local itemData = dropdown:GetSelectedItemData()
    itemData.name = DecoratePresetName(presetName, DynamicCP.savedOptions.cp[tree][presetName])
    dropdown:UpdateItems()
    dropdown:SelectItem(itemData)
end


---------------------------------------------------------------------
-- Open/close this window
local function TogglePresetsWindow()
    local isHidden = GetSubControl():IsHidden()
    GetSubControl():SetHidden(not isHidden)
    if (isHidden) then
        DynamicCP:InitializeDropdowns()
        DynamicCPPresetsContainer:SetHidden(false)
    end
end
DynamicCP.TogglePresetsWindow = TogglePresetsWindow


---------------------------------------------------------------------
-- Show a "tooltip" for the currently selected preset and slot set
-- Called upon selecting a preset from the dropdown
---------------------------------------------------------------------
local function ShowCPPointsOrDiff(tree, createNew, createNewText, slotSetId, existingLoadText, afterCP)
    if (createNew) then
        local diffText, numChanges, col1, col2, slottablesText = PSB.GenerateTree(DynamicCP.GetCommittedCP(), tree, slotSetId)
        ShowMessage(tree, createNewText, diffText, {1, 1, 1, 1}, numChanges, col1, col2, slottablesText)
    else
        local diffText, numChanges, col1, col2, slottablesText = PSB.GenerateDiff(DynamicCP.GetCommittedCP(), afterCP)
        ShowMessage(tree, existingLoadText, diffText, {1, 1, 1, 1}, numChanges, col1, col2, slottablesText)
    end
end


---------------------------------------------------------------------
-- Populate the slot set dropdown
local AUTOMATIC_STRING = "|cEBDB34-- Auto slots --|r"

local function GetCurrentlySelectedSlotSetId(tree)
    local presetName = selected[tree]
    if (presetName == CREATE_NEW_STRING) then
        return nil
    end
    return DynamicCP.savedOptions.cp[tree][presetName].slotSet
end

-- slotSetId: the slotSet to select after updating the dropdown, can be nil
local function UpdateSlotSetDropdown(tree, slotSetId)
    local function OnSetSelected(_, _, entry)
        local slotSetName = entry.name
        if (slotSetName == AUTOMATIC_STRING) then
            slotSetName = nil
        end

        local selectedSlotSetId = DynamicCP.GetSlotSetIdByName(tree, slotSetName)

        local presetName = selected[tree]
        if (presetName ~= CREATE_NEW_STRING) then
            DynamicCP.savedOptions.cp[tree][presetName].slotSet = selectedSlotSetId
        end

        local after = DynamicCP.savedOptions.cp[tree][presetName] -- Can be nil
        ShowCPPointsOrDiff(tree, presetName == CREATE_NEW_STRING, nil, slotSetId, nil, after)
    end


    local dropdown = ZO_ComboBox_ObjectFromContainer(GetSubControl("Inner"):GetNamedChild(tree .. "OptionsSlotSetDropdown"))
    local desiredEntry = nil
    dropdown:ClearItems()
    local data = DynamicCP.savedOptions.slotGroups[tree]
    for id, setData in pairs(data) do
        local entry = ZO_ComboBox:CreateItemEntry(setData.name, OnSetSelected)
        dropdown:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)

        if (slotSetId == id) then
            desiredEntry = entry
        end
    end

    -- Create an -- Automatic -- entry for when there is no attached slot set
    local automaticEntry = ZO_ComboBox:CreateItemEntry(AUTOMATIC_STRING, OnSetSelected)
    dropdown:AddItem(automaticEntry, ZO_COMBOBOX_SUPPRESS_UPDATE)
    if (slotSetId == nil) then
        desiredEntry = automaticEntry
    end

    dropdown:UpdateItems()
    if (desiredEntry) then
        dropdown:SelectItem(desiredEntry)
    end
end

function DynamicCP.RefreshPresetsSlotSetDropdown(tree)
    if (GetSubControl("Inner"):GetNamedChild(tree .. "OptionsSlotSetDropdown"):IsHidden()) then
        return
    end

    UpdateSlotSetDropdown(tree, GetCurrentlySelectedSlotSetId(tree))
end

---------------------------------------------------------------------
-- Populate the dropdown with presets
function DynamicCP:InitializeDropdown(tree, desiredEntryName)
    if (tree ~= "Red" and tree ~= "Green" and tree ~= "Blue") then
        DynamicCP.dbg("You're using this wrong >:[")
        return
    end

    local function OnPresetSelected(_, _, entry)
        local presetName = entry.name:gsub("|[cC]%x%x%x%x%x%x", ""):gsub("|r", "")

        selected[tree] = presetName
        UnhideOptions(tree)

        local innerControl = GetSubControl("Inner")
        if (presetName == CREATE_NEW_STRING) then
            local newIndex = 1
            while (DynamicCP.savedOptions.cp[tree]["Preset " .. newIndex] ~= nil) do
                newIndex = newIndex + 1
            end
            innerControl:GetNamedChild(tree .. "OptionsTextField"):SetHidden(false)
            innerControl:GetNamedChild(tree .. "OptionsTextField"):SetText("Preset " .. newIndex)
            innerControl:GetNamedChild(tree .. "OptionsSaveButton"):SetHidden(false)
            innerControl:GetNamedChild(tree .. "OptionsApplyButton"):SetHidden(true)
            innerControl:GetNamedChild(tree .. "OptionsDeleteButton"):SetHidden(true)
            innerControl:GetNamedChild(tree .. "OptionsSaveButton"):SetWidth(190)
            innerControl:GetNamedChild(tree .. "OptionsButtons"):SetHidden(true)
            innerControl:GetNamedChild(tree .. "OptionsSlotSetDropdown"):SetHidden(true)
            innerControl:GetNamedChild(tree .. "OptionsSlotSetHelp"):SetHidden(true)
        else
            innerControl:GetNamedChild(tree .. "OptionsTextField"):SetHidden(false)
            innerControl:GetNamedChild(tree .. "OptionsTextField"):SetText(presetName)
            innerControl:GetNamedChild(tree .. "OptionsApplyButton"):SetWidth(66)
            innerControl:GetNamedChild(tree .. "OptionsApplyButton"):SetHidden(false)
            innerControl:GetNamedChild(tree .. "OptionsDeleteButton"):SetHidden(false)
            innerControl:GetNamedChild(tree .. "OptionsSaveButton"):SetWidth(66)
            innerControl:GetNamedChild(tree .. "OptionsSaveButton"):SetHidden(false)
            innerControl:GetNamedChild(tree .. "OptionsButtons"):SetHidden(false)
            innerControl:GetNamedChild(tree .. "OptionsSlotSetDropdown"):SetHidden(false)
            innerControl:GetNamedChild(tree .. "OptionsSlotSetHelp"):SetHidden(false)
        end


        local data = DynamicCP.savedOptions.cp[tree][presetName] or {}

        -- Select the slot set
        UpdateSlotSetDropdown(tree, data.slotSet)

        local buttons = GetSubControl("Inner"):GetNamedChild(tree .. "OptionsButtons")
        for role, _ in pairs(ROLES) do
            SetTextureButtonEnabled(buttons:GetNamedChild(role), data.roles == nil or data.roles[role] == nil or data.roles[role]) -- Both nil or true
        end

        buttons:GetNamedChild("Tank"):SetAnchor(TOPLEFT, buttons, TOPLEFT, 2)
        buttons:GetNamedChild("Help"):SetAnchor(TOPRIGHT, buttons, TOPRIGHT, 0)

        ShowCPPointsOrDiff(
            tree,
            presetName == CREATE_NEW_STRING,
            "Rename and click \"Save\" to create a new preset.",
            nil,
            "Click \"Apply\" to load this preset.",
            data)
    end

    -- Init/clear dropdown
    local data = DynamicCP.savedOptions.cp[tree]
    local dropdown = ZO_ComboBox_ObjectFromContainer(GetSubControl("Inner"):GetNamedChild(tree .. "Dropdown"))
    local desiredEntry = nil
    dropdown:ClearItems()

    -- Add smart presets
    for id, data in pairs(DynamicCP.SMART_PRESETS[tree]) do
        local displayName = string.format("|c9BDB34%s|r", data.name())
        local entry = ZO_ComboBox:CreateItemEntry(displayName, function()
            UnhideOptions(tree)
            local innerControl = GetSubControl("Inner")
            innerControl:GetNamedChild(tree .. "OptionsTextField"):SetHidden(true)
            innerControl:GetNamedChild(tree .. "OptionsApplyButton"):SetWidth(190)
            innerControl:GetNamedChild(tree .. "OptionsApplyButton"):SetHidden(false)
            innerControl:GetNamedChild(tree .. "OptionsDeleteButton"):SetHidden(true)
            innerControl:GetNamedChild(tree .. "OptionsSaveButton"):SetHidden(true)
            innerControl:GetNamedChild(tree .. "OptionsButtons"):SetHidden(true)
            innerControl:GetNamedChild(tree .. "OptionsSlotSetDropdown"):SetHidden(true)
            innerControl:GetNamedChild(tree .. "OptionsSlotSetHelp"):SetHidden(true)
            selected[tree] = id

            ShowCPPointsOrDiff(
                tree,
                presetName == CREATE_NEW_STRING,
                "Rename and click \"Save\" to create a new preset.",
                nil,
                "Click \"Apply\" to load this preset.",
                data.applyFunc())
        end)
        dropdown:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
    end

    -- Add saved presets
    for presetName, cp in pairs(data) do
        local name = DecoratePresetName(presetName, cp)
        local entry = ZO_ComboBox:CreateItemEntry(name, OnPresetSelected)
        dropdown:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)

        if (presetName == desiredEntryName) then
            desiredEntry = entry
        end
    end

    -- Add new item entry
    local entry = ZO_ComboBox:CreateItemEntry("|cEBDB34" .. CREATE_NEW_STRING .. "|r", OnPresetSelected)
    dropdown:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
    dropdown:UpdateItems()

    if (desiredEntry) then
        dropdown:SelectItem(desiredEntry)
        OnPresetSelected(nil, nil, desiredEntry)
    else
        selected[tree] = nil
        HideOptions(tree)
    end
end

----------------------------------------------------------------------
local expanded = true
function DynamicCP.OnSidebarClicked()
    if (expanded) then
        -- Close it
        DynamicCPSidePresets.slide:SetDeltaOffsetX(DynamicCPSidePresets:GetWidth())
        DynamicCPSidePresetsInnerGreenMessagesTooltip.slide:SetDeltaOffsetX(400)
        DynamicCPSidePresetsInnerBlueMessagesTooltip.slide:SetDeltaOffsetX(400)
        DynamicCPSidePresetsInnerRedMessagesTooltip.slide:SetDeltaOffsetX(400)
        DynamicCPSidePresetsSidebarClose.rotateAnimation:PlayFromStart()
    else
        -- Expand it
        DynamicCPSidePresets.slide:SetDeltaOffsetX(-1 * DynamicCPSidePresets:GetWidth())
        DynamicCPSidePresetsInnerGreenMessagesTooltip.slide:SetDeltaOffsetX(-400)
        DynamicCPSidePresetsInnerBlueMessagesTooltip.slide:SetDeltaOffsetX(-400)
        DynamicCPSidePresetsInnerRedMessagesTooltip.slide:SetDeltaOffsetX(-400)
        DynamicCPSidePresetsSidebarClose.rotateAnimation:PlayBackward()
    end
    expanded = not expanded
    DynamicCPSidePresets.slideAnimation:PlayFromStart()
    DynamicCPSidePresetsInnerGreenMessagesTooltip.slideAnimation:PlayFromStart()
    DynamicCPSidePresetsInnerBlueMessagesTooltip.slideAnimation:PlayFromStart()
    DynamicCPSidePresetsInnerRedMessagesTooltip.slideAnimation:PlayFromStart()
end

---------------------------------------------------------------------
-- Entry point
local function ApplyPresetsFonts()
    local smallFont = DynamicCP.GetStyles().smallFont
    local gameFont = DynamicCP.GetStyles().gameFont


    for tree, _ in pairs(TREE_TO_DISCIPLINE) do
        -- At this rate, I wonder if it's better to just walk the tree dynamically...
        local innerTree = DynamicCPSidePresetsInner:GetNamedChild(tree)
        innerTree:GetNamedChild("MessagesLabel"):SetFont(smallFont)
        innerTree:GetNamedChild("MessagesTooltipLabel"):SetFont(smallFont)
        innerTree:GetNamedChild("MessagesTooltipLabel2"):SetFont(smallFont)
        innerTree:GetNamedChild("MessagesTooltipExtraLabel"):SetFont(smallFont)
        innerTree:GetNamedChild("MessagesTooltipExtraLabel2"):SetFont(smallFont)

        ZO_ComboBox_ObjectFromContainer(innerTree:GetNamedChild("Dropdown")):SetFont(gameFont)
        ZO_ComboBox_ObjectFromContainer(innerTree:GetNamedChild("OptionsSlotSetDropdown")):SetFont(gameFont)
    end

    DynamicCPSidePresetsSidebarLabel:SetFont(DynamicCP.GetStyles().gameBoldFont)

    DynamicCPSidePresetsInnerInstructions1:SetFont(gameFont)
    DynamicCPSidePresetsInnerInstructions2:SetFont(gameFont)
    DynamicCPSidePresetsInnerInstructions3:SetFont(gameFont)
end
DynamicCP.ApplyPresetsFonts = ApplyPresetsFonts

function DynamicCP:InitializeDropdowns()
    if (isRespeccing) then return end -- Skip doing this so we don't overwrite

    DynamicCPSidePresets.slideAnimation = GetAnimationManager():CreateTimelineFromVirtual("ZO_LootSlideInAnimation", DynamicCPSidePresets)
    DynamicCPSidePresets.slide = DynamicCPSidePresets.slideAnimation:GetFirstAnimation()
    DynamicCPSidePresetsSidebarClose.rotateAnimation = GetAnimationManager():CreateTimelineFromVirtual("ArrowRotateAnim", DynamicCPSidePresetsSidebarClose)
    DynamicCPSidePresetsSidebarClose.rotate = DynamicCPSidePresetsSidebarClose.rotateAnimation:GetFirstAnimation()

    DynamicCPSidePresetsInnerGreenMessagesTooltip.slideAnimation = GetAnimationManager():CreateTimelineFromVirtual("ZO_LootSlideInAnimation", DynamicCPSidePresetsInnerGreenMessagesTooltip)
    DynamicCPSidePresetsInnerGreenMessagesTooltip.slide = DynamicCPSidePresetsInnerGreenMessagesTooltip.slideAnimation:GetFirstAnimation()
    DynamicCPSidePresetsInnerBlueMessagesTooltip.slideAnimation = GetAnimationManager():CreateTimelineFromVirtual("ZO_LootSlideInAnimation", DynamicCPSidePresetsInnerBlueMessagesTooltip)
    DynamicCPSidePresetsInnerBlueMessagesTooltip.slide = DynamicCPSidePresetsInnerBlueMessagesTooltip.slideAnimation:GetFirstAnimation()
    DynamicCPSidePresetsInnerRedMessagesTooltip.slideAnimation = GetAnimationManager():CreateTimelineFromVirtual("ZO_LootSlideInAnimation", DynamicCPSidePresetsInnerRedMessagesTooltip)
    DynamicCPSidePresetsInnerRedMessagesTooltip.slide = DynamicCPSidePresetsInnerRedMessagesTooltip.slideAnimation:GetFirstAnimation()

    DynamicCP:InitializeDropdown("Red")
    DynamicCP:InitializeDropdown("Green")
    DynamicCP:InitializeDropdown("Blue")
    HideMessage("Red")
    HideMessage("Green")
    HideMessage("Blue")

    ApplyPresetsFonts()
end