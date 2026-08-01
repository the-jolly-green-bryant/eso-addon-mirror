if ESOAssistant == nil or ESOAssistant.internal == nil then assert(false, "Error on zone module startup: Main module missing!") end
---@type table
local egint = ESOAssistant.internal
local logger = egint.logger

local currentSkillId
local currentSkillLineId
local currentKeyboardSkillLineId
local function OpenSkillOrSkillLineLink()
    if currentSkillId and currentSkillLineId then
        logger:Warn("Both currentSkillId (%d: %s) and currentSkillLineId (%d, %s) have values!", currentSkillId, GetAbilityName(currentSkillId), currentSkillLineId, GetSkillLineNameById(currentSkillLineId))
    end
    if currentSkillId then
        local urlSegments = "skill/" .. currentSkillId
        logger:Info("Trying OpenSkillLink: %d", currentSkillId)
        egint.ProcessLink(urlSegments)
        return
    end
    if currentSkillLineId then
        local urlSegments = "skillLine/" .. currentSkillLineId
        logger:Info("Trying OpenSkillLineLink: %d", currentSkillLineId)
        egint.ProcessLink(urlSegments)
        return
    end
    if currentKeyboardSkillLineId then
        local urlSegments = "skillLine/" .. currentKeyboardSkillLineId
        logger:Info("Trying OpenSkillLineLink: %d", currentKeyboardSkillLineId)
        egint.ProcessLink(urlSegments)
    end
end

local skillButtonsKeyboard = {
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
    {
        name = function() 
            return GetString(currentSkillId and SI_ESOASSISTANT_SHOW_ABILITY or SI_ESOASSISTANT_SHOW_SKILL_LINE) 
        end,
        keybind = "UI_SHORTCUT_QUINARY",
        callback = OpenSkillOrSkillLineLink,
        visible = function()
            return true
        end,
        enabled = function()
            return true
        end,
    },
}

local skillButtonsGamepad = {
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    {
        name = function() 
            return GetString(currentSkillId and SI_ESOASSISTANT_SHOW_ABILITY or SI_ESOASSISTANT_SHOW_SKILL_LINE) 
        end,
        keybind = "UI_SHORTCUT_QUINARY",
        callback = OpenSkillOrSkillLineLink,
        visible = function()
            return true
        end,
        enabled = function()
            return true
        end,
    }
}

local keybindsEnabled = false

local function UpdateKeybindStripButton()
    if keybindsEnabled == false then return end
    if IsInGamepadPreferredMode() or ZO_IsConsoleUI() then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(skillButtonsGamepad)
    else
        KEYBIND_STRIP:UpdateKeybindButtonGroup(skillButtonsKeyboard)
    end

    logger:Info("Updating Skills Keystrip Binding.")
end

local function RemoveKeybindStripButton()
    if egint.sv.openLink == false then egint.HideQR() end
    if keybindsEnabled == false or currentKeyboardSkillLineId ~= nil then 
        UpdateKeybindStripButton() 
        return 
    end
    if IsInGamepadPreferredMode() or ZO_IsConsoleUI() then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(skillButtonsGamepad)
    else
        KEYBIND_STRIP:RemoveKeybindButtonGroup(skillButtonsKeyboard)
    end
    keybindsEnabled = false
    logger:Info("Remove Skills Keystrip Binding.")
end


local function AddKeybindStripButton(keybindStripId)
    if keybindsEnabled == true or (currentSkillId == nil and currentSkillLineId == nil and currentKeyboardSkillLineId == nil) then  
        UpdateKeybindStripButton()
        return
    end
    if IsInGamepadPreferredMode() or ZO_IsConsoleUI() then
        KEYBIND_STRIP:AddKeybindButtonGroup(skillButtonsGamepad, keybindStripId)
    else
        KEYBIND_STRIP:AddKeybindButtonGroup(skillButtonsKeyboard)
    end

    logger:Info("Adding Skills Keystrip Binding. Id: %s", tostring(keybindStripId))
    keybindsEnabled = true
end

local function GetSkillOrSkillLineIdGamepad(_, selectedData)
    currentSkillId = nil
    currentSkillLineId = nil
    RemoveKeybindStripButton()

    if selectedData.skillLineData then 
        currentSkillLineId = selectedData.skillLineData.id
        logger:Debug("Selected SkillLine %s (%d)", GetSkillLineNameById(currentSkillLineId), currentSkillLineId)
        AddKeybindStripButton()
        return
    end

    if selectedData.skillData then
        local skillData = selectedData.skillData
        if skillData:IsPassive() then
            currentSkillId = skillData.skillProgressions[skillData.currentRank].abilityId
        elseif skillData.currentMorphSlot then
            currentSkillId = skillData.skillProgressions[skillData.currentMorphSlot].abilityId
        elseif skillData.craftedAbilityId then
            local craftedAbilityId = skillData.craftedAbilityId
            currentSkillId = GetAbilityIdForCraftedAbilityId(craftedAbilityId)            
            if currentSkillId == 0 and skillData.GetRepresentativeAbilityId then
                currentSkillId = selectedData.data:GetRepresentativeAbilityId()
            end
            logger:Info("Selected Scribing Skill %d", craftedAbilityId)
        end
        if currentSkillId then logger:Info("Selected Skill %s (%d)", GetAbilityName(currentSkillId), currentSkillId) end
        return
    end
end

local function GetScribingLibrarySkillIdGamepad(self, list, selectedData)
    currentSkillId = nil
    currentSkillLineId = nil
    RemoveKeybindStripButton()

    if list ~= self.craftedAbilityList then return end
    if selectedData == nil or selectedData.data == nil then return end
    local craftedAbilityId = selectedData.data.craftedAbilityId

    if craftedAbilityId then
        currentSkillId = GetAbilityIdForCraftedAbilityId(craftedAbilityId)
        if currentSkillId == 0 and selectedData.data.GetRepresentativeAbilityId then
            currentSkillId = selectedData.data:GetRepresentativeAbilityId()
        end
        logger:Info("Selected Scribing Library Skill %d (skillId: %d)", craftedAbilityId, currentSkillId)
        AddKeybindStripButton()
    end
end

local function GetScribingSkill(self, ...)
    currentSkillId = nil
    currentSkillLineId = nil
    RemoveKeybindStripButton()

    local selectedData = self:GetSelectedData()
    if not (self:IsShowing() and self.isActive and selectedData) then return end

    local skillData = selectedData.skillData
    local craftedAbilityId = skillData and skillData.craftedAbilityId
    if craftedAbilityId == nil or craftedAbilityId == 0 then return end

    currentSkillId = GetAbilityIdForCraftedAbilityId(craftedAbilityId)
    if currentSkillId == 0 and skillData.GetRepresentativeAbilityId then
        currentSkillId = selectedData.data:GetRepresentativeAbilityId()
    end

    logger:Info("Selected Active Scribing Skill %d (skillId: %d)", craftedAbilityId, currentSkillId)
end

local function RefreshKeybinds()
    RemoveKeybindStripButton()
    AddKeybindStripButton(ZO_GAMEPAD_SCRIBING_CRAFTED_ABILITY_SKILLS.keybindStripId)
    logger:Info("RefreshKeybinds. keybindStripId: %d", ZO_GAMEPAD_SCRIBING_CRAFTED_ABILITY_SKILLS.keybindStripId)
end

local function AddOptionsDialogEntry()
    local dialog = ESO_Dialogs["SKILLS_OPTIONS_DIALOG_GAMEPAD"]

    local new_button = {
        keybind = "DIALOG_TERTIARY",
        text = SI_ESOASSISTANT_SHOW_ABILITY,
        callback = function()
            ZO_Dialogs_ReleaseDialogOnButtonPress("SKILLS_OPTIONS_DIALOG_GAMEPAD")
            zo_callLater(OpenSkillOrSkillLineLink, 200)
        end,
    }

    local newEntry = ZO_GamepadEntryData:New(zo_strformat(SI_ESOASSISTANT_SHOW_ABILITY))
    newEntry.setup = ZO_SharedGamepadEntry_OnSetup
    newEntry.callback = function() 
        ZO_Dialogs_ReleaseDialogOnButtonPress("SKILLS_OPTIONS_DIALOG_GAMEPAD") 
        zo_callLater(OpenSkillOrSkillLineLink, 200) 
    end


    table.insert(dialog.buttons, new_button)
    table.insert(dialog.parametricList , {template = "ZO_GamepadMenuEntryTemplate", entryData = newEntry,})
    
end

local lastTooltipMouseoverControl

local function OnTooltipShow(tooltipControl, ...)
    local itemControl = moc()
    if itemControl and lastTooltipMouseoverControl == itemControl then return end

    lastTooltipMouseoverControl = itemControl
    AddKeybindStripButton()
end

local function OnTooltipHide()
    lastTooltipMouseoverControl = nil
    currentSkillLineId = nil
    currentSkillId = nil
    RemoveKeybindStripButton()
end

local function SetSkillLineId(_, skillLineId)
    currentSkillId = nil
    currentSkillLineId = skillLineId
    logger:Info("Selected SkillLine %s (%d)", GetSkillLineNameById(currentSkillLineId), currentSkillLineId)
end

local function SetSkillId(_, ...)
    currentSkillLineId = nil
    currentSkillId = nil

    local skillType, skillLineIndex, skillIndex = select(1, ...)
    local overrideAbilityId = select(14, ...)
    if overrideAbilityId then 
        currentSkillId = overrideAbilityId
        logger:Info("Selected Skill %s (%d)", GetAbilityName(currentSkillId), currentSkillId)
        return
    else
        currentSkillId = GetSkillAbilityId(skillType, skillLineIndex, skillIndex)
        logger:Info("Selected Skill %s (%d)", GetAbilityName(currentSkillId), currentSkillId)
    end
end

local function SetPassiveSkillId(_, ...)
    currentSkillLineId = nil
    currentSkillId = nil

    local skillType, skillLineIndex, skillIndex = select(1, ...)
    currentSkillId = GetSkillAbilityId(skillType, skillLineIndex, skillIndex)
    logger:Info("Selected Skill %s (%d)", GetAbilityName(currentSkillId), currentSkillId)
end


local function SetAbilityId(_, abilityId, ...)
    currentSkillLineId = nil
    currentSkillId = nil

    currentSkillId = abilityId
    logger:Info("Selected abilityId", abilityId, ...)
end

local function applyTooltipHook(tooltip, method, callback)
    local orig = tooltip[method]

    tooltip[method] = function (self, ...)
        callback(self, ...)
        return orig(self, ...)
    end
end 

local function OnSkillLineKeyboardRefresh(_, skillLineData, ...)
    local isSubclassing = select(6, ...)
    if isSubclassing then
        currentKeyboardSkillLineId = nil
        RemoveKeybindStripButton()
        return
    end
    if skillLineData and skillLineData.id then
        currentKeyboardSkillLineId = skillLineData.id
        logger:Info("Selected Keyboard SkillLine: %s (%d)", GetSkillLineNameById(currentKeyboardSkillLineId), currentKeyboardSkillLineId)
        AddKeybindStripButton()
        return
    end
end

local function OnSkillsPanelHide()
    currentKeyboardSkillLineId = nil
    RemoveKeybindStripButton()
end

local function OnSkillsPanelShow()
    local lineData = SKILLS_WINDOW and SKILLS_WINDOW:GetSelectedSkillLineData()
    if lineData and lineData.id then
        currentKeyboardSkillLineId = lineData.id
        logger:Info("Skills Panel opened. Current SkillLine: %s (%d)", GetSkillLineNameById(currentKeyboardSkillLineId), currentKeyboardSkillLineId)
        AddKeybindStripButton()
    end
end

local function OnSkillsPanelShowGamepad()
    local currentData = GAMEPAD_SKILLS.categoryList:GetTargetData()
    if currentData.skillLineData then
        currentSkillLineId = currentData.skillLineData.id
        logger:Info("Skills Panel opened. Current SkillLine: %s (%d)", GetSkillLineNameById(currentSkillLineId), currentSkillLineId)
        AddKeybindStripButton()
    end
end

function egint.initSkillsModule()
    applyTooltipHook(SkillTooltip, "SetAbilityId", SetAbilityId)
    applyTooltipHook(SkillTooltip, "SetActiveSkill", SetSkillId)
    applyTooltipHook(SkillTooltip, "SetPassiveSkill", SetPassiveSkillId)
    applyTooltipHook(SkillTooltip, "SetSkillLineById", SetSkillLineId)
    applyTooltipHook(SkillTooltip, "SetSubclassingSkillLineById", SetSkillLineId)

    SkillTooltip:SetHandler("OnUpdate", OnTooltipShow, CONTROL_HANDLER_ORDER_BEFORE)
    SkillTooltip:SetHandler("OnHide", OnTooltipHide, CONTROL_HANDLER_ORDER_BEFORE)
    SkillTooltip:SetHandler("OnCleared", OnTooltipHide, CONTROL_HANDLER_ORDER_BEFORE)

    if ZO_Skills then
        ZO_Skills:SetHandler("OnHide", OnSkillsPanelHide, CONTROL_HANDLER_ORDER_AFTER)
        ZO_Skills:SetHandler("OnShow", OnSkillsPanelShow, CONTROL_HANDLER_ORDER_AFTER)
    end
    SecurePostHook(_G, "ZO_SkillLineInfo_Keyboard_Refresh", OnSkillLineKeyboardRefresh)
    
    GAMEPAD_SKILLS.control:SetHandler("OnShow", OnSkillsPanelShowGamepad, CONTROL_HANDLER_ORDER_AFTER)
    GAMEPAD_SKILLS.control:SetHandler("OnHide", RemoveKeybindStripButton, CONTROL_HANDLER_ORDER_AFTER)

    SecurePostHook(GAMEPAD_SKILLS, "OnSelectedSkillChanged", GetSkillOrSkillLineIdGamepad)
    SecurePostHook(GAMEPAD_SKILLS, "OnSelectedSkillLineChanged", GetSkillOrSkillLineIdGamepad)
    SecurePostHook(ZO_GAMEPAD_SCRIBING_CRAFTED_ABILITY_SKILLS , "UpdateTooltip", GetScribingSkill)
    SecurePostHook(ZO_GAMEPAD_SCRIBING_CRAFTED_ABILITY_SKILLS , "Activate", RefreshKeybinds)
    SecurePostHook(SCRIBING_LIBRARY_GAMEPAD, "RefreshSelection", GetScribingLibrarySkillIdGamepad)
    SecurePostHook(ZO_ScribingLayout_Gamepad, "OnHide", RemoveKeybindStripButton)
    -- SecurePostHook(ZO_ScribingLayout_Gamepad, "OnHide", function() logger:Info("ZO_ScribingLayout_Gamepad OnHide") end)
    SecurePostHook(ZO_ScribingLayout_Gamepad, "OnSelectionChanged", GetScribingLibrarySkillIdGamepad)
    AddOptionsDialogEntry()
end

