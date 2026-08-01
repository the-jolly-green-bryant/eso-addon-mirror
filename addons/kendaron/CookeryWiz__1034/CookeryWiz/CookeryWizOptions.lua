
local L = CookeryWizLanguage.language

CookeryWizOptions = EasyFrameDialog:new()
CookeryWizOptions.name = "CookeryWizOptions"
CookeryWizOptions.cookeryWiz = nil

CookeryWizOptions.contentControl = nil

CookeryWizOptions.characterComboBox = nil
CookeryWizOptions.characterDropdown = nil
CookeryWizOptions.externalCharacterComboBox = nil
CookeryWizOptions.externalCharacterDropdown = nil
CookeryWizOptions.characterEnabledButton = nil

CookeryWizOptions.enableAGSIntegrationCheckButton = nil
CookeryWizOptions.disableMiniIconCheckButton = nil
CookeryWizOptions.enableChatThemeCheckButton = nil

CookeryWizOptions.displayWithStationInteractionCheckButton = nil
CookeryWizOptions.deleteReadMailCheckButton = nil
CookeryWizOptions.disableWritCollectionCheckButton = nil

CookeryWizOptions.enableKnowledgeIconCheckButton = nil

CookeryWizOptions.traceEnabled = false

CookeryWizOptions.loadOrder = nil

local function trace(msg)
  if CookeryWizOptions.traceEnabled then
    --d(GetTimeString()..":"..msg)
    d(msg)
  end
end

function CookeryWizOptions:loaded(msg) 
  if not self.loadOrder then
    self.loadOrder = msg
  else
    self.loadOrder = self.loadOrder .. "," .. msg
  end
end
---------------------------------------------------------------------
-- Function: OnCookeryWizOptionsInitialized
--
-- This function initialises the dialog. It is called from the
-- OnInitialized event in the control XML definition
--
---------------------------------------------------------------------
function CookeryWizOptions:OnCookeryWizOptionsInitialized(control) 
  
  --
  -- Setup the combo dropdowns
  -- NOTE: It seems like we cannot implement the OnInitialized event for combo boxes
  -- Perhaps the ZO_ComboBox needs the initialise and it is somehow not being propagated?
  --

  local content = control:GetNamedChild("Content")  
  
  local combo
  local entry
  local dropdown

  -- Character Dropdown
  self.characterComboBox = content:GetNamedChild("CharacterCombo")
  self.characterDropdown = ZO_ComboBox_ObjectFromContainer(self.characterComboBox)
  self.characterDropdown.m_openDropdown:SetDrawLayer(100)
  --self.characterComboBox:SetDrawLayer(100)
  --entry = dropdown:CreateItemEntry("test")
  --dropdown:AddItem(entry)  

  -- Station Interaction dropdown
  self.stationComboBox = content:GetNamedChild("StationInteractionCombo")
  self.stationDropdown = ZO_ComboBox_ObjectFromContainer(self.stationComboBox)

  -- Knowledge Icon dropdown
  self.iconComboBox = content:GetNamedChild("IconCombo")
  self.iconDropdown = ZO_ComboBox_ObjectFromContainer(self.iconComboBox) 
  self.iconDropdown:SetFont("ZoFontHeader4")
  
  -- Imported Character dropdown
  self.externalCharacterComboBox = content:GetNamedChild("ImportedCharacterCombo")
  self.externalCharacterDropdown = ZO_ComboBox_ObjectFromContainer(self.externalCharacterComboBox)
  
  
  self:Initialize()
  
end

function CookeryWizOptions:OnGeneralOptionsLabelInitialized(control)
  control:SetText(L[CWL_LABEL_OPTIONS_GENERAL_OPTIONS_TEXT])
  control:SetColor(255,255,255)
end

function CookeryWizOptions:OnAccountOptionsLabelInitialized(control)
  control:SetText(L[CWL_LABEL_OPTIONS_ACCOUNT_OPTIONSL_TEXT ])
  control:SetColor(255,255,255)
end

function CookeryWizOptions:OnExternalOptionsLabelInitialized(control)
  control:SetText(L[CWL_LABEL_OPTIONS_IMPORTED_OPTIONS_TEXT ])
  control:SetColor(255,255,255)  
end


--[[
--
-- Recipe knowledge
--
function CookeryWizOptions:OnEnableKnowledgeIconInitialized(control)
  control:SetText(L[CWL_LABEL_OPTIONS_ENABLE_RECIPE_KNOWLEDGE_ICON]) 
end

function CookeryWizOptions:OnEnableKnowledgeIconCheckButtonInitialized(control)
  self.enableKnowledgeIconCheckButton = control
  self:SetupTooltip(control, L[CWL_LABEL_OPTIONS_ENABLE_RECIPE_KNOWLEDGE_ICON_TOOLTIP]) 
end

function CookeryWizOptions:OnEnableKnowledgeIconCheckButtonClicked(control, mouseButton)
  local enabled = self.cookeryWiz:IsRecipeKnowledgeIconEnabled()
  self.cookeryWiz:EnableRecipeKnowledgeIcon(not enabled)
  ZO_CheckButton_OnClicked(control, mouseButton)    
end
]]--

--
-- AGS Integration
--

function CookeryWizOptions:OnIntegrateAGSLabelInitialized(control)
control:SetText(L[CWL_LABEL_OPTIONS_ENABLE_AGS_TEXT]) 
end

function CookeryWizOptions:OnIntegrateAGSCheckButtonInitialized(control)  
  self.enableAGSIntegrationCheckButton = control
end

function CookeryWizOptions:OnIntegrateAGSCheckButtonClicked(control, mouseButton)
  local agsEnabled = self.cookeryWiz:IsAwesomeGuildStoreIntegrationEnabled()
  self.cookeryWiz:EnableAwesomeGuildStoreIntegration(not agsEnabled)
  ZO_CheckButton_OnClicked(control, mouseButton)   
end


--
-- Cooking Station Interaction combo and label
--
function CookeryWizOptions:OnStationInteractionLabelInitialized(control)
  control:SetText(L[CWL_LABEL_OPTIONS_COOKING_STATION_INTERACTION])
end

function CookeryWizOptions:OnStationInteractionSelect(comboBox, name, item, selectionChanged)  
  local parent = self:GetParent()
  local currentInteractionIndex = parent:GetStationInteractionMethod()
  parent:SetStationInteractionMethod(item.interactionIndex)
  --[[
  local scene = SCENE_MANAGER:GetCurrentScene()
  if scene == PROVISIONER_SCENE then
    d("Prov scene")
    if currentInteractionIndex == CW_STATION_INTERACTION_METHOD_REPLACE then
      d("-replace")
      if item.interactionIndex ~= CW_STATION_INTERACTION_METHOD_REPLACE then
        d("-restoring")
        parent:RestoreCookeryWizPosition()
      end
    end    
  end
  ]]--
end
  
function CookeryWizOptions:PopulateStationInteractionDropDown()
  if not self.stationDropdown then
    d("No station interaction Dropdown")
    return
  end

  self.stationDropdown:ClearItems()

  local parent = self:GetParent()

  self:AddStationInteractionListItem(L[CWL_COMBO_OPTION_INTERACTION_NONE], CW_STATION_INTERACTION_METHOD_NONE)
  self:AddStationInteractionListItem(L[CWL_COMBO_OPTION_INTERACTION_DISPLAY], CW_STATION_INTERACTION_METHOD_DISPLAY)
  self:AddStationInteractionListItem(L[CWL_COMBO_OPTION_INTERACTION_REPLACE], CW_STATION_INTERACTION_METHOD_REPLACE)
  
  local items = self.stationDropdown:GetItems()
  table.sort(items, function(a, b)
      return a.interactionIndex < b.interactionIndex
    end)
  
  -- set the current selection
  self.stationDropdown:SelectItemByIndex(parent:GetStationInteractionMethod() + 1)
  
end

function CookeryWizOptions:AddStationInteractionListItem(text, interactionIndex)
  local entry = self.stationDropdown:CreateItemEntry(text, function(...)
      self:OnStationInteractionSelect(...)
    end)
  entry.interactionIndex = interactionIndex

  self.stationDropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)  
end



--
-- Knowledge Icon combo and label
--

function CookeryWizOptions:OnIconLabelInitialized(control)
  control:SetText(L[CWL_LABEL_KNOWLEDGE_ICON_TEXT])
end

function CookeryWizOptions:OnIconSelect(comboBox, name, item, selectionChanged)  
  local parent = self:GetParent()
  --d("iconIndex:"..item.iconIndex)
  parent:SetIconIndex(item.iconIndex)
end
  
function CookeryWizOptions:PopulateIconDropDown()
  if not self.iconDropdown then
    d("No icon Dropdown")
    return
  end
  
  self.iconDropdown:ClearItems()

  local parent = self:GetParent()
  local iconTable = parent:GetIconTable()

  local iconVariations = self.cookeryWiz.savedVariables.iconCount;
  for i = 0, iconVariations do
    self:AddIconListItem(iconTable, i)
  end
  
  -- select the chosen icon
  self.iconDropdown:SelectItemByIndex(parent:GetIconIndex() ) 
end

function CookeryWizOptions:AddIconListItem(iconTable, iconIndex)
  local iconText
  if iconIndex == 0 then
    iconText = L[CWL_COMBO_OPTION_INTERACTION_NONE]
  else
    local texture = string.format(iconTable[1].texture, iconIndex)
    iconText = zo_iconTextFormat(texture, 24, 24)
  end  
  
  local entry = self.iconDropdown:CreateItemEntry(iconText, function(...)
      self:OnIconSelect(...)
    end)
  entry.iconIndex = iconIndex
  self.iconDropdown:AddItem(entry)  
end
--
-- Enable Chat Theme
--

function CookeryWizOptions:OnEnableChatThemeLabelInitialized(control)
  control:SetText(L[CWL_LABEL_OPTIONS_ENABLE_CHAT_THEME_TEXT])
end

function CookeryWizOptions:OnEnableChatThemeCheckButtonInitialized(control)
  self.enableChatThemeCheckButton = control
  self:SetupTooltip(control, L[CWL_BUTTON_OPTIONS_ENABLE_CHAT_THEME_TOOLTIP])    
end

function CookeryWizOptions:OnEnableChatThemeCheckButtonClicked(control, mouseButton)
  local chatEdgeEnabled = self.cookeryWiz:IsChatEdgeEnabledSetting()
  self.cookeryWiz:EnableChatEdgeSetting(not chatEdgeEnabled)

  ZO_CheckButton_OnClicked(control, mouseButton)
end

--
-- Disable shrink
--

function CookeryWizOptions:OnDisableMiniIconLabelInitialized(control)
  control:SetText(L[CWL_LABEL_OPTIONS_DISABLE_MINI_ICON_TEXT]) 
end

function CookeryWizOptions:OnDisableMiniIconCheckButtonInitialized(control)
  self.disableMiniIconCheckButton = control
  self:SetupTooltip(control, L[CWL_BUTTON_OPTIONS_DISABLE_MINI_ICON_TOOLTIP])  
end

function CookeryWizOptions:OnDisableMiniIconCheckButtonClicked(control, mouseButton)

  local miniIconDisabled = self.cookeryWiz:IsMiniIconDisabledSetting()
  self.cookeryWiz:DisableMiniIconSetting(not miniIconDisabled)

  ZO_CheckButton_OnClicked(control, mouseButton)
end

function CookeryWizOptions:OnCharacterLabelInitialized(control)
    control:SetText(L[CWL_LABEL_OPTIONS_ACCOUNT_CHARACTER_TEXT])
end

function CookeryWizOptions:OnContentControlInitialized(control)
  self.contentControl = control
end

function CookeryWizOptions:OnCharacterDisabledButtonClicked(control)
  
  --local characterName = ZO_ComboBox:GetSelectedItem(self.characterComboBox)
  local characterName = self.characterDropdown:GetSelectedItem()
  
  local characterVars = self.cookeryWiz.savedVariables.characters[characterName];
  if not characterVars then
    return
  end

  characterVars.enabled = not characterVars.enabled
  self:ConfigureDisabledButton(characterVars)
  self.cookeryWiz:PopulateCharacterDropDown()
end

function CookeryWizOptions:ConfigureDisabledButton(characterVars)
   if characterVars.enabled then
    self.characterEnabledButton:SetText(L[CWL_BUTTON_OPTIONS_DISABLE])
    self:SetupTooltip(self.characterEnabledButton, string.format(L[CWL_BUTTON_OPTIONS_DISABLE_TOOLTIP], L[CWL_COOKERYWIZ_TITLE]))      
  else
    self.characterEnabledButton:SetText(L[CWL_BUTTON_OPTIONS_ENABLE])
    self:SetupTooltip(self.characterEnabledButton, string.format(L[CWL_BUTTON_OPTIONS_ENABLE_TOOLTIP], L[CWL_COOKERYWIZ_TITLE]))       
  end 
end

function CookeryWizOptions:OnCharacterSelected(control, choiceText, choice)
  local characterVars = self.cookeryWiz.savedVariables.characters[choiceText];
  if not characterVars then
    return
  end
  
  if control.m_name == self.characterComboBox:GetName() then
    --d("Character")
    self:ConfigureDisabledButton(characterVars)
  elseif control.m_name == self.externalCharacterComboBox:GetName() then
    --d("External")
  end

end


--
-- Character combo
--
function CookeryWizOptions:OnCharacterDropDownInitialized(control)
  self.characterDropdown = control
end

function CookeryWizOptions:OnCharacterDisabledButtonInitialized(control)
  self.characterEnabledButton = control
  control:SetText(L[CWL_BUTTON_OPTIONS_DISABLE])
  self:SetupTooltip(control, string.format(L[CWL_BUTTON_OPTIONS_DISABLE_TOOLTIP], L[CWL_COOKERYWIZ_TITLE]))
end


-- Display Ticks
function CookeryWizOptions:OnDisplayTicksLabelInitialized(control)
  control:SetText(L[CWL_LABEL_OPTIONS_DISPLAY_TICKS])
end
 
function CookeryWizOptions:OnDisplayTicksCheckButtonInitialized(control)
  self.displayTicksCheckButton = control
  local text = string.format(L[CWL_LABEL_OPTIONS_DISPLAY_TICKS_TOOLTIP])
  self:SetupTooltip(control, text)  
end

function CookeryWizOptions:OnDisplayTicksCheckButtonClicked(control, mouseButton)
  local parent = self:GetParent()
  
  local enabled = parent:IsDisplayTicksEnabled()
  parent:SetDisplayTicksEnabled(not enabled)
  ZO_CheckButton_OnClicked(control, mouseButton)
end


-- Delete processed mail
function CookeryWizOptions:OnDeleteReadMailLabelInitialized(control)
  control:SetText(L[CWL_LABEL_OPTIONS_ENABLE_DELETE_READ_MAIL_TEXT])
end
 
function CookeryWizOptions:OnDeleteReadMailCheckButtonInitialized(control)
  self.deleteReadMailCheckButton = control
  local text = string.format(L[CWL_BUTTON_OPTIONS_ENABLE_DELETE_READ_MAIL_TOOLTIP], L[CWL_COOKERYWIZ_NAME])
  self:SetupTooltip(control, text)  
end

function CookeryWizOptions:OnDeleteReadMailCheckButtonClicked(control, mouseButton)
  local deleteEnabled = self.cookeryWiz:IsDeleteReadMailEnabled()
  self.cookeryWiz:DeleteReadMail(not deleteEnabled)
  ZO_CheckButton_OnClicked(control, mouseButton)
end

-- Disable Writ Collection
function CookeryWizOptions:OnDisableWritCollectionLabelInitialized(control)
  control:SetText(L[CWL_LABEL_OPTIONS_DISABLE_WRIT_COLLECTION_TEXT])
end
 
function CookeryWizOptions:OnDisableWritCollectionCheckButtonInitialized(control)
  self.disableWritCollectionCheckButton = control
  local text = L[CWL_LABEL_OPTIONS_DISABLE_WRIT_COLLECTION_TOOLTIP]
  self:SetupTooltip(control, text)  
end

function CookeryWizOptions:OnDisableWritCollectionCheckButtonClicked(control, mouseButton)
  local disableEnabled = self.cookeryWiz:IsWritCollectionDisabled()
  self.cookeryWiz:DisableWritCollection(not disableEnabled)
  ZO_CheckButton_OnClicked(control, mouseButton)
end



-- External
function CookeryWizOptions:OnImportedCharacterLabelInitialized(control)
  control:SetText(L[CWL_LABEL_OPTIONS_IMPORTED_CHARACTER_TEXT])
end



function CookeryWizOptions:OnDeleteExternalCharacterButtonInitialized(control)
  control:SetText(L[CWL_BUTTON_OPTIONS_DELETE])
  self:SetupTooltip(control, L[CWL_BUTTON_OPTIONS_DELETE_TOOLTIP])
end

function CookeryWizOptions:OnDeleteExternalCharacterButtonClicked(control)
  local characterName = self.externalCharacterDropdown:GetSelectedItem()
  local characterVars = self.cookeryWiz.savedVariables.characters[characterName];
  if not characterVars then
    return
  end
  self.cookeryWiz.savedVariables.characters[characterName] = nil
  self.cookeryWiz:PopulateCharacterDropDown()
  self:PopulateCharacterDropDown(self.externalCharacterDropdown, true)
  self.externalCharacterDropdown:SelectFirstItem()
end

function CookeryWizOptions:PopulateCharacterDropDown(characterDropdown, isExternal)
  local cookeryWizOptions = self
  
  if not characterDropdown then
    d("No Character Dropdown")
    return
  end


  local function OnItemSelect(comboBox, name, entry)
    self:OnCharacterSelected(comboBox, name, entry)
  end
  
  characterDropdown:ClearItems()
      
  -- populate from our stored list. The key of the list is the character name
  for key, characterData in pairs(CookeryWiz.savedVariables.characters) do
    -- skip external characters 
    local foundAt = key:find("@", 1, true)

    if isExternal then
      --d(key)
      if foundAt then
        local entry = characterDropdown:CreateItemEntry(key, OnItemSelect)
        characterDropdown:AddItem(entry)          
      end        
    else 
      if not foundAt then
        local entry = characterDropdown:CreateItemEntry(key, OnItemSelect)
        characterDropdown:AddItem(entry)
      end
    end

  end
  characterDropdown:SelectFirstItem()
end
---------------------------------------------------------------------
-- EasyFrame virtual functions
---------------------------------------------------------------------

function CookeryWizOptions:OnHideWindow(isHidden)
  --d("CookeryWizOptions:OnHideWindow")
 
  local ui = self.ui
  if isHidden then
    --d("Hiding")
    
  else
    --d("Showing")
    --d("ChatEdge"..self.textureChatEdgeControl:GetName())
    local characterName = GetUnitName("player")
    self:PopulateCharacterDropDown(self.characterDropdown, false)    
    --self.characterDropdown:SetSelectedItem(characterName)    
    
    self:PopulateCharacterDropDown(self.externalCharacterDropdown, true)
    self.externalCharacterDropdown:SelectFirstItem()
    
    local characterVars = self.cookeryWiz.savedVariables.characters[characterName];
    if characterVars then
      self:ConfigureDisabledButton(characterVars)      
    end
    
    --CookeryWizUtils:CenterDialog(self:GetParentWindow(), ui)
    --self:CenterToParent()
    --local top = 
    --ui:ClearAnchors()
    --ui:SetAnchor(CENTER, self:GetParentWindow(), CENTER, 0, 0) 
    
    --ui:SetTopmost()
    --ui:BringWindowToTop()
    
    if self.statusLabelControl then
      self.statusLabelControl:SetText("")
    end   

    local parent = self:GetParent()
    
    -- set the check for shrink
    local miniIconDisabled = parent:IsMiniIconDisabledSetting()
    if miniIconDisabled then
        ZO_CheckButton_SetChecked(self.disableMiniIconCheckButton)
    else
        ZO_CheckButton_SetUnchecked(self.disableMiniIconCheckButton)
    end
    
    -- Chat edge
    if parent:IsChatEdgeEnabledSetting() then
        ZO_CheckButton_SetChecked(self.enableChatThemeCheckButton)
    else
        ZO_CheckButton_SetUnchecked(self.enableChatThemeCheckButton)
    end
        
    -- Display Ticks
    if parent:IsDisplayTicksEnabled() then
        ZO_CheckButton_SetChecked(self.displayTicksCheckButton)
    else
        ZO_CheckButton_SetUnchecked(self.displayTicksCheckButton)
    end

  
    -- AGS integration
    if self.cookeryWiz:IsAwesomeGuildStoreIntegrationEnabled() then
        ZO_CheckButton_SetChecked(self.enableAGSIntegrationCheckButton)
    else
        ZO_CheckButton_SetUnchecked(self.enableAGSIntegrationCheckButton)
    end
    
       
    -- Auto delete read mail
    if self.cookeryWiz:IsDeleteReadMailEnabled() then
        ZO_CheckButton_SetChecked(self.deleteReadMailCheckButton)
    else
        ZO_CheckButton_SetUnchecked(self.deleteReadMailCheckButton)
    end   
    
    -- Disable writ collection
    if self.cookeryWiz:IsWritCollectionDisabled() then
        ZO_CheckButton_SetChecked(self.disableWritCollectionCheckButton)
    else
        ZO_CheckButton_SetUnchecked(self.disableWritCollectionCheckButton)
    end   
    
    -- populate icons
    self:PopulateIconDropDown()
    
    -- station interaction
    self:PopulateStationInteractionDropDown()
        
  end  
end


function CookeryWizOptions:Initialize()
  self.cookeryWiz = CookeryWiz
	local defaultSave =
	{    
    easyFrameVariables = self.easyFrameVariables
	} 


  self.isInitialised = true
  --self:InitializeEasyFrameDialog(L[CWL_COOKERYWIZOPTIONS_TITLE], CookeryWizOptionsUI, CookeryWizUI)
  self:InitializeEasyFrameDialog(L[CWL_COOKERYWIZOPTIONS_TITLE], CookeryWizOptionsUI)

  
  self.ui:SetResizeHandleSize(0)
  
  self.selectedCharacter = GetUnitName("player")
  if self.reloadButton then
    self.reloadButton:SetHidden(true)
  end
  if self.shrinkButton then
    self.shrinkButton:SetHidden(true)
  end
  
    -- Configure strings
  self.closeTooltip = L[CWL_BUTTON_TOOLTIP_CLOSE] 
  self:SetupTooltip(self.enableAGSIntegrationCheckButton, string.format(L[CWL_BUTTON_OPTIONS_ENABLE_AGS_TOOLTIP],L[CWL_AGS], self.cookeryWiz.name,self.cookeryWiz.name))

end


