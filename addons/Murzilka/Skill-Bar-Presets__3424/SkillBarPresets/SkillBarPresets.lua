PRESETLIST = {}
PRESETLIST.Name = SkillBarPresets_Globals_AddonInfo.Name
PRESETLIST.presets = {}
PRESETLIST.presetsCompanion = {}
PRESETLIST.rows = {}
PRESETLIST.editPreset = {}
PRESETLIST.editPreset.iconId = 0
PRESETLIST.selectedPresetId = 0
PRESETLIST.characterDefaults = {
    presets = {},
    presetsCompanion = {}
}
PRESETLIST.TYPES = {
    PLAYER = 0,
    COMPANION = 1,
}
PRESETLIST.type = PRESETLIST.TYPES.PLAYER
PRESETLIST.ACTION_TYPES = {
    NONE = 0,
    LOAD = 1,
    ADD_NEW = 2,
    MODIFY = 3,
    DELETE = 4,
}
PRESETLIST.actionType = PRESETLIST.ACTION_TYPES.NONE
PRESETLIST.canEdit = false
PRESETLIST.companion = {
    presets = {},
    skillLines = {},
    skillLineActive = { "weapon", "armor" }
}

-- Local functions
local function isCompanion()
    if PRESETLIST.type == PRESETLIST.TYPES.COMPANION then
        return true
    end
    return false
end

local function isPlayer()
    if PRESETLIST.type == PRESETLIST.TYPES.PLAYER then
        return true
    end
    return false
end

local function getPresetsList()
    if isCompanion() then
        return PRESETLIST.companion.presets
    end
    return PRESETLIST.presets
end

local function getRowIndex(rowName)
    local index = tonumber(string.sub(rowName,string.len(rowName)))
    return index
end

local function getSlotTexture(slot)
    if isPlayer() then
        if slot.skill <= 0 then return ZO_NO_TEXTURE_FILE end
        local _, texture = GetSkillAbilityInfo(slot.skill, slot.line, slot.ability)
        return texture
    elseif isCompanion() then
        if not slot then return ZO_NO_TEXTURE_FILE end
        if not slot.ability then return ZO_NO_TEXTURE_FILE end
        if slot.ability < 0 then return ZO_NO_TEXTURE_FILE end
        return GetAbilityIcon(slot.ability)
    end
end

local function setupEditPreset(actionType)
    local presets = getPresetsList()
    PRESETLIST.editPreset = {}
    PRESETLIST.editPreset.slots = {}
    local presetTemp = {}
    if actionType == PRESETLIST.ACTION_TYPES.ADD_NEW then
        presetTemp.id = #presets + 1
        presetTemp.iconId = 1
        presetTemp.icon = SkillBarPresets_EsoIconTextures[presetTemp.iconId]
        presetTemp.name = "preset name"
        presetTemp.slots = {}
        for i = 1, 6 do
            presetTemp.slots[i] = {}
            presetTemp.slots[i].skill = 0
            presetTemp.slots[i].line = 0
            presetTemp.slots[i].ability = 0
            presetTemp.slots[i].texture = ZO_NO_TEXTURE_FILE
        end
    elseif actionType == PRESETLIST.ACTION_TYPES.MODIFY then
        local id = PRESETLIST.selectedPresetId
        local selectPreset = presets[id]
        presetTemp.id = PRESETLIST.selectedPresetId
        presetTemp.icon = selectPreset.icon
        presetTemp.name = selectPreset.name
        for i = 1, #SkillBarPresets_EsoIconTextures do
            if SkillBarPresets_EsoIconTextures[i] == selectPreset.icon then
                presetTemp.iconId = i
            end
        end

        local function getSlotTextureByPreset(preset, slotNum)
            local slot = preset.slots[slotNum]
            return getSlotTexture(slot)
        end

        presetTemp.slots = {}
        for i = 1, 6 do
            presetTemp.slots[i] = {}
            presetTemp.slots[i].skill = selectPreset.slots[i].skill
            presetTemp.slots[i].line = selectPreset.slots[i].line
            presetTemp.slots[i].ability = selectPreset.slots[i].ability
            presetTemp.slots[i].texture = getSlotTextureByPreset(selectPreset, i)
        end
    end

    PRESETLIST.editPreset.id = presetTemp.id
    PRESETLIST.editPreset.iconId = presetTemp.iconId
    PRESETLIST.editPreset.icon = presetTemp.icon
    PRESETLIST.editPreset.name = presetTemp.name
    for i = 1, 6 do
        PRESETLIST.editPreset.slots[i] = {}
        PRESETLIST.editPreset.slots[i].skill = presetTemp.slots[i].skill
        PRESETLIST.editPreset.slots[i].line = presetTemp.slots[i].line
        PRESETLIST.editPreset.slots[i].ability = presetTemp.slots[i].ability
        PRESETLIST.editPreset.slots[i].texture = presetTemp.slots[i].texture
    end
end

local function updatePlayerEditPreset(importData)
    function string:split(pattern, result)
        if not result then result = {} end
        local index = 1
        local splitStart, splitEnd = string.find(self, pattern, index)
        while splitStart do
            table.insert(result, string.sub(self, index, splitStart - 1))
            index = splitEnd + 1
            splitStart, splitEnd = string.find(self, pattern, index)
        end
        table.insert(result, string.sub(self, index))
        return result
    end
    local dataTable = importData:split(", ")
    for i = 1, #dataTable do
        local n, m = string.find(dataTable[i], "slot")
        if n and m then
            local slot = dataTable[i]:split(":")
            local skillInfo = {}
            for j = 2, #slot do
                skillInfo[j-1] = tonumber(slot[j])
            end
            local slotIndex = tonumber(string.sub(dataTable[i], m + 1, m + 1))
            PRESETLIST.editPreset.slots[slotIndex].skill = skillInfo[1]
            PRESETLIST.editPreset.slots[slotIndex].line = skillInfo[2]
            PRESETLIST.editPreset.slots[slotIndex].ability = skillInfo[3]
            local _, texture = GetSkillAbilityInfo(skillInfo[1], skillInfo[2], skillInfo[3])
            PRESETLIST.editPreset.slots[slotIndex].texture = texture

        else
            PRESETLIST.editPreset.name = dataTable[i]
        end
    end
end

local function updateCompanionEditPreset(importData)
    function string:split(pattern, result)
        if not result then result = {} end
        local index = 1
        local splitStart, splitEnd = string.find(self, pattern, index)
        while splitStart do
            table.insert(result, string.sub(self, index, splitStart - 1))
            index = splitEnd + 1
            splitStart, splitEnd = string.find(self, pattern, index)
        end
        table.insert(result, string.sub(self, index))
        return result
    end
    local dataTable = importData:split(", ")
    for i = 1, #dataTable do
        local n, m = string.find(dataTable[i], "slot")
        if n and m then
            local slot = dataTable[i]:split(":")
            local abilityId = tonumber(slot[2])
            local slotIndex = tonumber(string.sub(dataTable[i], m + 1, m + 1))
            PRESETLIST.editPreset.slots[slotIndex].skill = -1
            PRESETLIST.editPreset.slots[slotIndex].line = -1
            PRESETLIST.editPreset.slots[slotIndex].ability = abilityId
            PRESETLIST.editPreset.slots[slotIndex].texture = GetAbilityIcon(abilityId)
        else
            PRESETLIST.editPreset.name = dataTable[i]
        end
    end
end

local function updateEditPreset(importData)
    if isPlayer() then
        updatePlayerEditPreset(importData)
    end
    if isCompanion() then
        updateCompanionEditPreset(importData)
    end
end

local function getPlayerSkillsFromBar()

    local function getSlotInfo(abilityName)
        abilityName = zo_strlower(abilityName)
        for skillType = 1, GetNumSkillTypes() do
            for skillLineIndex = 1, GetNumSkillLines(skillType) do
                for abilityIndex = 1, GetNumSkillAbilities(skillType, skillLineIndex) do
                    local name, _, _, passive = GetSkillAbilityInfo(skillType, skillLineIndex, abilityIndex)
                    if not passive then
                        name = zo_strlower(name)
                    end
                    if name == abilityName then
                        return skillType, skillLineIndex, abilityIndex
                    end
                end
            end
        end
        return 0, 0, 0
    end

    for slotNum = 3, 8 do
        local index = slotNum - 2
        local type, line, ability = 0, 0, 0
        local texture = GetSlotTexture(slotNum)
        if IsSlotUsed(slotNum) then
            local abilityId = GetSlotBoundId(slotNum)
            local _, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
            type, line, ability = GetSkillAbilityIndicesFromProgressionIndex(progressionIndex)
            if type == 0 then
                local abilityName = GetSlotName(slotNum)
                type, line, ability = getSlotInfo(abilityName)
            end
        end

        PRESETLIST.editPreset.slots[index] = {}
        PRESETLIST.editPreset.slots[index].skill = type
        PRESETLIST.editPreset.slots[index].line = line
        PRESETLIST.editPreset.slots[index].ability = ability
        PRESETLIST.editPreset.slots[index].texture = texture
    end
end

local function getCompanionSkillsFromBar()
    local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(HOTBAR_CATEGORY_COMPANION)
    local activeSkillsList = {}
    for i, data in hotbar:SlotIterator(COMPANION_SKILLS_FILTER) do
        local skillData = data:GetCompanionSkillData()
        local index = tonumber(i) - 2
        if skillData ~= nil then
            if index <= 6 then
                activeSkillsList[index] = {}
                activeSkillsList[index].abilityId = skillData.abilityId
                activeSkillsList[index].texture = GetAbilityIcon(skillData.abilityId)
            end
        else
            if index <= 6 then
                activeSkillsList[index] = {}
                activeSkillsList[index].abilityId = -1
                activeSkillsList[index].texture = ZO_NO_TEXTURE_FILE
            end
        end
    end

    for i = 1, 6 do
        PRESETLIST.editPreset.slots[i] = {}
        PRESETLIST.editPreset.slots[i].skill = -1
        PRESETLIST.editPreset.slots[i].line = -1
        PRESETLIST.editPreset.slots[i].ability = activeSkillsList[i].abilityId
        PRESETLIST.editPreset.slots[i].texture = activeSkillsList[i].texture
    end
end

local function getSkillsFromBar()
    if isPlayer() then
        getPlayerSkillsFromBar()
    end
    if isCompanion() then
        getCompanionSkillsFromBar()
    end
end

local function getNextIcon(controlIcon, currentIconId, iconsList, step)

    local iconId = currentIconId + step
    if iconId > #iconsList then
        iconId = 1
    elseif iconId < 1 then
        iconId = #iconsList
    end
    controlIcon:SetTexture(iconsList[iconId])
    controlIcon:SetDimensions(72, 72)
    return iconId
end

local function getIconFromIconsList(iconId)
    if (iconId < 1) or (iconId > #SkillBarPresets_EsoIconTextures) then return end
    return SkillBarPresets_EsoIconTextures[iconId]
end
-- End local functions

function PRESETLIST.OpenEditWindow()
    if SkillBarAddPresetWindow:IsHidden() then
        SkillBarAddPresetWindow:SetHidden(false)
        SkillBarImportExportWindowTextEdit:SetText("")
    end

    local panel = GetControl(SkillBarAddPresetWindow, "Edit")
    local editBox = GetControl(panel, "EditBox")
    editBox:SetText(PRESETLIST.editPreset.name)


    local icon = GetControl(SkillBarAddPresetWindow, "Icon")
    icon:SetTexture(PRESETLIST.editPreset.icon)

    for i = 1, 6 do
        local slot = GetControl(SkillBarAddPresetWindow, "IconSlot" .. i)
        local texture = GetControl(slot, "Texture")
        texture:SetTexture(PRESETLIST.editPreset.slots[i].texture)
    end

    editBox:TakeFocus()
end

function PRESETLIST.LoadSavedData()
    local storageName = SkillBarPresets_Globals_AddonInfo.SavedVariables
    local savedVars = ZO_SavedVars:NewCharacterIdSettings(storageName, 2, nil, PRESETLIST.characterDefaults)
    PRESETLIST.presets = savedVars.presets
    PRESETLIST.companion.presets = savedVars.presetsCompanion
end

function PRESETLIST.InitializeList()
    local list = GetControl(SkillBarPresetsWindow, "List")
    local typeId = 1
    local templateName = "SkillBarPresetTemplate"
    local height = 80
    local setupFunction = PRESETLIST.PresetRowSetup
    local hideCallback = nil
    local dataTypeSelectSound = nil
    local resetControlCallback = nil
    local selectTemplate = "ZO_ThinListHighlight"
    local selectCallback = nil

    ZO_ScrollList_AddDataType(list, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
    ZO_ScrollList_EnableSelection(list, selectTemplate, selectCallback)
end

function PRESETLIST.UpdateList()
    local list = GetControl(SkillBarPresetsWindow, "List")
    local data = getPresetsList()
    local dataCopy = ZO_DeepTableCopy(data)
    local dataList = ZO_ScrollList_GetDataList(list)

    PRESETLIST.rows = {}
    ZO_ScrollList_Clear(list)

    for key, value in ipairs(dataCopy) do
        local entry = ZO_ScrollList_CreateDataEntry(1, value)
        table.insert(dataList, entry)
    end

    ZO_ScrollList_Commit(list)
end

function PRESETLIST.PresetRowSetup(rowControl, data)
    local name = GetControl(rowControl, "PresetName")
    name:SetText(data.name)

    local icon = GetControl(rowControl, "PresetIcon")
    icon:SetNormalTexture(data.icon)

    for i = 1, 6 do
        local slot = GetControl(rowControl, "IconSlot" .. i)
        local texture = GetControl(slot, "Texture")
        local slotTexture = getSlotTexture(data.slots[i])
        texture:SetTexture(slotTexture)
    end

    PRESETLIST.rows[data.id] = rowControl
end

function PRESETLIST.PresetAdd_Click(control)
    if PRESETLIST.actionType ~= PRESETLIST.ACTION_TYPES.NONE then
        d("You already edit preset.")
        return
    end
    PRESETLIST.actionType = PRESETLIST.ACTION_TYPES.ADD_NEW
    setupEditPreset(PRESETLIST.actionType)
    getSkillsFromBar()
    PRESETLIST.OpenEditWindow()
end

function PRESETLIST.PresetApply_Click(control)
    local presets = getPresetsList()
    local preset = presets[PRESETLIST.selectedPresetId]
    for i = 1, 6 do
        local slot = preset.slots[i]
        if isPlayer() then
            SlotSkillAbilityInSlot(slot.skill, slot.line, slot.ability, i + 2)
        elseif isCompanion() then
            local index = tonumber(i) + 2
            local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(HOTBAR_CATEGORY_COMPANION)
            if slot.ability > -1 then
                hotbar:AssignSkillToSlotByAbilityId(index, slot.ability)
            end
        end
    end
end

function PRESETLIST.PresetModify_Click(control)
    if PRESETLIST.actionType ~= PRESETLIST.ACTION_TYPES.NONE then
        d("You already edit preset.")
        return
    end
    PRESETLIST.actionType = PRESETLIST.ACTION_TYPES.MODIFY
    setupEditPreset(PRESETLIST.actionType)
    PRESETLIST.OpenEditWindow()
end

function PRESETLIST.PresetDelete_Click(control)
    if PRESETLIST.actionType ~= PRESETLIST.ACTION_TYPES.NONE then
        d("You already edit preset.")
        return
    end
    local presets = getPresetsList()
    table.remove(presets, PRESETLIST.selectedPresetId)
    -- Update presets ids
    for i = 1, #presets do
        presets[i].id = i
    end

    PRESETLIST.UpdateList()
end

function PRESETLIST.PresetRow_MouseEnter(control)
    local row = control:GetParent()
    if PRESETLIST.actionType == PRESETLIST.ACTION_TYPES.NONE then
        PRESETLIST.selectedPresetId = getRowIndex(row:GetName())
    end
    local background = GetControl(row, "BackgroundOn")
    background:SetAlpha(1)

    for i = 1, 6 do
        local slot = GetControl(row, "IconSlot" .. i)
        slot:SetAlpha(1)
    end
end

function PRESETLIST.PresetRow_MouseExit(control)
    local row = control:GetParent()
    local background = GetControl(row, "BackgroundOn")
    background:SetAlpha(0)

    for i = 1, 6 do
        local slot = GetControl(row, "IconSlot" .. i)
        slot:SetAlpha(0)
    end
end

function PRESETLIST.PresetMoveUp_Click(control)
    local panel = control:GetParent()
    local row = panel:GetParent()
    local rowIndex = getRowIndex(row:GetName())
    local nextIndex = rowIndex - 1
    local presets = getPresetsList()
    if nextIndex < 1 then
        nextIndex = 1
    end
    if nextIndex ~= rowIndex then
        local nextData = ZO_DeepTableCopy(presets[nextIndex])
        nextData.id = rowIndex
        local rowData = ZO_DeepTableCopy(presets[rowIndex])
        rowData.id = nextIndex
        presets[nextIndex] = rowData
        presets[rowIndex] = nextData
        PRESETLIST.UpdateList()
    end
end

function PRESETLIST.PresetMoveDown_Click(control)
    local panel = control:GetParent()
    local row = panel:GetParent()
    local rowIndex = getRowIndex(row:GetName())
    local nextIndex = rowIndex + 1
    local presets = getPresetsList()
    if nextIndex > #presets then
        nextIndex = #presets
    end
    if nextIndex ~= rowIndex then
        local nextData = ZO_DeepTableCopy(presets[nextIndex])
        nextData.id = rowIndex
        local rowData = ZO_DeepTableCopy(presets[rowIndex])
        rowData.id = nextIndex
        presets[nextIndex] = rowData
        presets[rowIndex] = nextData
        PRESETLIST.UpdateList()
    end
end

function PRESETLIST.PresetCancelAdd_Click(control)
    SkillBarAddPresetWindow:SetHidden(true)
    SkillBarImportExportWindow:SetHidden(true)
    PRESETLIST.actionType = PRESETLIST.ACTION_TYPES.NONE

end

function PRESETLIST.PresetIconNext_Click(control)
    local presetIcon = GetControl(SkillBarAddPresetWindow, "Icon")
    local nextIconId = getNextIcon(presetIcon, PRESETLIST.editPreset.iconId, SkillBarPresets_EsoIconTextures, 1)
    PRESETLIST.editPreset.iconId = nextIconId
    PRESETLIST.editPreset.icon = getIconFromIconsList(PRESETLIST.editPreset.iconId)
end

function PRESETLIST.PresetIconPrev_Click(control)
    local presetIcon = GetControl(SkillBarAddPresetWindow, "Icon")
    local nextIconId = getNextIcon(presetIcon, PRESETLIST.editPreset.iconId, SkillBarPresets_EsoIconTextures, -1)
    PRESETLIST.editPreset.iconId = nextIconId
    PRESETLIST.editPreset.icon = getIconFromIconsList(PRESETLIST.editPreset.iconId)
end

function PRESETLIST.PresetSave_Click(control)
    local id = PRESETLIST.editPreset.id
    local panel = GetControl(SkillBarAddPresetWindow, "Edit" )
    local editBox = GetControl(panel, "EditBox")
    local presets = getPresetsList()
    local editPreset = PRESETLIST.editPreset

    presets[id] = {}
    presets[id].id = editPreset.id
    presets[id].name = editBox:GetText()
    presets[id].icon = editPreset.icon
    presets[id].slots = {}
    for i = 1, 6 do

        -- local slotNum = i + 2
        presets[id].slots[i] = {}
        if isPlayer() then
            presets[id].slots[i].skill = editPreset.slots[i].skill
            presets[id].slots[i].line = editPreset.slots[i].line
        end
        presets[id].slots[i].ability = editPreset.slots[i].ability
    end

    PRESETLIST.UpdateList()

    SkillBarAddPresetWindow:SetHidden(true)
    SkillBarImportExportWindow:SetHidden(true)
    PRESETLIST.actionType = PRESETLIST.ACTION_TYPES.NONE
end

function PRESETLIST.PresetImportExport_Click(control)
    if SkillBarImportExportWindow:IsHidden() then
        SkillBarImportExportWindow:SetHidden(false)

    else
        SkillBarImportExportWindow:SetHidden(true)
    end
end

function PRESETLIST.PresetImportExportCancel_Click(control)
    SkillBarImportExportWindow:SetHidden(true)
end

function PRESETLIST.PresetImportData_Click(control)
    local data = SkillBarImportExportWindowTextEdit:GetText()
    if string.len(data) < 1 then return end
    updateEditPreset(data)
    PRESETLIST.OpenEditWindow()
end

function PRESETLIST.PresetExportData_Click(control)
    local preset = PRESETLIST.editPreset
    local data = preset.name .. ", "
    for i = 1, 6 do
        local slot = preset.slots[i]
        if isPlayer() then
            data = data .. "slot" .. i .. ":" .. slot.skill .. ":" .. slot.line .. ":" .. slot.ability
        end
        if isCompanion() then
            data = data .. "slot" .. i .. ":" .. slot.ability
        end
        if i < 6 then data = data .. ", " end
    end

    SkillBarImportExportWindowTextEdit:SetText(data)
end

function PRESETLIST.ListEdit_Click(control)
    PRESETLIST.canEdit = not PRESETLIST.canEdit
    local textures = {}
    if PRESETLIST.canEdit then
        textures.normal = "EsoUI/Art/Buttons/edit_cancel_up.dds"
        textures.over = "EsoUI/Art/Buttons/edit_cancel_over.dds"
        textures.down = "EsoUI/Art/Buttons/edit_cancel_down.dds"
    else
        textures.normal = "EsoUI/Art/Buttons/edit_up.dds"
        textures.over = "EsoUI/Art/Buttons/edit_over.dds"
        textures.down = "EsoUI/Art/Buttons/edit_down.dds"
    end
    control:SetNormalTexture(textures.normal)
    control:SetMouseOverTexture(textures.over)
    control:SetPressedTexture(textures.down)

    local presets = getPresetsList()

    for i = 1, #presets do
        local row = PRESETLIST.rows[i]
        local buttonDelete = GetControl(row, "DeleteButton")
        buttonDelete:SetHidden(PRESETLIST.canEdit)

        local buttonModify = GetControl(row, "ModifyButton")
        buttonModify:SetHidden(PRESETLIST.canEdit)

        local panel = GetControl(row, "Move")
        panel:SetHidden(not PRESETLIST.canEdit)
    end
end

function PRESETLIST.SkillSlot_MouseEnter(control)
    if PRESETLIST.selectedPresetId < 1 then return end

    local slotNum = getRowIndex(control:GetName())
    local presets = getPresetsList()
    local slot = presets[PRESETLIST.selectedPresetId].slots[slotNum]
    local abilityId = -1
    if isPlayer() then
        abilityId = GetSkillAbilityId(slot.skill, slot.line, slot.ability, false)
    end
    if isCompanion() then
        abilityId = slot.ability
    end

    local row = control:GetParent()
    local background = GetControl(row, "BackgroundOn")
    background:SetAlpha(1)

    for i = 1, 6 do
        local slot = GetControl(row, "IconSlot" .. i)
        slot:SetAlpha(1)
    end

    if abilityId < 1 then return end

    InitializeTooltip(AbilityTooltip, control, RIGHT, -5, 0, LEFT)
    AbilityTooltip:SetAbilityId(abilityId)
end

function PRESETLIST.SkillSlot_MouseExit(control)
    local row = control:GetParent()
    local background = GetControl(row, "BackgroundOn")
    background:SetAlpha(0)

    for i = 1, 6 do
        local slot = GetControl(row, "IconSlot" .. i)
        slot:SetAlpha(0)
    end

    ClearTooltip(AbilityTooltip)
end

function PRESETLIST.SkillSlot_Click(control)
    if PRESETLIST.selectedPresetId < 1 then return end

    local slotNum = getRowIndex(control:GetName())
    local presets = getPresetsList()
    local slot = presets[PRESETLIST.selectedPresetId].slots[slotNum]
    if isPlayer() then
        SlotSkillAbilityInSlot(slot.skill, slot.line, slot.ability, slotNum + 2)
    end
    if isCompanion() then
        local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(HOTBAR_CATEGORY_COMPANION)
        if slot.ability > -1 then
            hotbar:AssignSkillToSlotByAbilityId(slotNum + 2, slot.ability)
        end
    end
end

function PRESETLIST.SkillsBarReload_Click(control)
    getSkillsFromBar()
    -- reload slots
    for i = 1, 6 do
        local slot = SkillBarAddPresetWindow:GetNamedChild("IconSlot" .. i)
        local texture = GetControl(slot, "Texture")
        texture:SetTexture(PRESETLIST.editPreset.slots[i].texture)
    end
end

function PRESETLIST.Init(event, addOnName)
    if addOnName ~= PRESETLIST.Name then return end

    EVENT_MANAGER:UnregisterForEvent(PRESETLIST.Name, EVENT_ADD_ON_LOADED)

    -- Show and Hide Player Skill Presets
    local function skillFragmentChange(oldState, newState)
        if newState == SCENE_FRAGMENT_SHOWN then
            PRESETLIST.type = PRESETLIST.TYPES.PLAYER
            PRESETLIST.UpdateList()
            SkillBarPresetsWindow:SetHidden(false)
        elseif newState == SCENE_FRAGMENT_HIDDEN then
            SkillBarPresetsWindow:SetHidden(true)
            SkillBarAddPresetWindow:SetHidden(true)
            SkillBarImportExportWindow:SetHidden(true)
            PRESETLIST.actionType = PRESETLIST.ACTION_TYPES.NONE
        end
    end
    local skillFragment = SKILLS_FRAGMENT
    skillFragment:RegisterCallback("StateChange", skillFragmentChange)
    -- End Show and Hide Player Skill Presets

    -- Show and Hide Companion Skill Presets
    local function companionFragmentChange(oldState, newState)
        if newState == SCENE_FRAGMENT_SHOWN then
            PRESETLIST.type = PRESETLIST.TYPES.COMPANION
            PRESETLIST.UpdateList()
            SkillBarPresetsWindow:SetHidden(false)
        elseif newState == SCENE_FRAGMENT_HIDDEN then
            SkillBarPresetsWindow:SetHidden(true)
            SkillBarAddPresetWindow:SetHidden(true)
            SkillBarImportExportWindow:SetHidden(true)
            PRESETLIST.actionType = PRESETLIST.ACTION_TYPES.NONE
        end
    end
    local companionFragment = COMPANION_SKILLS_KEYBOARD_FRAGMENT
    companionFragment:RegisterCallback("StateChange", companionFragmentChange)
    -- End Show and Hide Companion Skill Presets

    PRESETLIST.LoadSavedData()
    PRESETLIST.InitializeList()
    PRESETLIST.UpdateList()
end

EVENT_MANAGER:RegisterForEvent(PRESETLIST.Name, EVENT_ADD_ON_LOADED, PRESETLIST.Init)
