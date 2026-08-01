
local L = CookeryWizLanguage.language

CookeryWizMailer = EasyFrameDialog:new()
CookeryWizMailer.name = "CookeryWizMailer"
CookeryWizMailer.isInitialised = false

CookeryWizMailer.throttlePeriod = 500

CookeryWizMailer.cookeryWiz = nil
CookeryWizMailer.editAddressControl = nil

CookeryWizMailer.characterComboBox = nil
CookeryWizMailer.characterDropdown = nil
  
CookeryWizMailer.contentControl = nil

CookeryWizMailer.statusLabelControl = nil

CookeryWizMailer.selectedCharacter = nil
CookeryWizMailer.currentSendTo = nil
CookeryWizMailer.parentWindow = nil

CookeryWizMailer.normalColor = nil
CookeryWizMailer.errorColor = nil
        
CookeryWizMailer.addContactButton = nil
CookeryWizMailer.removeContactButton = nil
CookeryWizMailer.contactsComboBox = nil
CookeryWizMailer.contactsDropdown = nil

CookeryWizMailer.sendTo = {}

CookeryWizMailer.traceEnabled = false

local function trace(msg)
  CookeryWizMailer:Trace(msg)
end

---------------------------------------------------------------------
-- EasyFrame virtual functions
---------------------------------------------------------------------

function CookeryWizMailer:OnHideWindow(isHidden)
  
  if not isHidden then
    -- d("Populating characters")
    self:PopulateCharacterDropDown()
  
    self:ClearStatus()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_SEND_FAILED, 
      function(...)
        self:OnMailSendFailed(...)
      end)    
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_SEND_SUCCESS, 
      function(...)
        self:OnMailSendSuccess(...)
      end)    
    
    local contacts = self:GetContacts()
    
    if not contacts then
      d("Unable to get contacts")
      return
    end
   
    self:PopulateContactsDropDown(contacts)
    
  else
    --d("Hiding")
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_MAIL_SEND_FAILED)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_MAIL_SEND_SUCCESS) 
  end  
end

function CookeryWizMailer:OnMailShow(topLevelControl)
  --d("OnShowCookeryWizMailer")
  --self:OnReloadRecipes(true)

end

-- Use this function to hide and show controls according to whether we are shrunk or expanded
function CookeryWizMailer:OnShrink(isHidden)
  if not self then
    d("OnShrink called without :")
    return
  end
   
  local vars = self.easyFrameVariables
  local isShrunk = vars.isShrunk
  
  if isShrunk then
    -- hide controls

  else
    -- show controls

  end

  self.contentControl:SetHidden(isShrunk)
end

function CookeryWizMailer:PopulateCharacterDropDown()
  local cookeryWizMailer = self
  
  if not self.characterDropdown then
    d("No Character Dropdown")
    return
  end
  
  local function OnItemSelect(control, choiceText, choice)
    cookeryWizMailer.selectedCharacter = choiceText
  end
  
  self.characterDropdown:ClearItems()
      
  -- populate from our stored list. The key of the list is the character name
  for key, characterData in pairs(CookeryWiz.savedVariables.characters) do
    if characterData.enabled then
      -- skip external characters 
      if not key:find("@", 1, true) then
        local entry = self.characterDropdown:CreateItemEntry(key, OnItemSelect)
        self.characterDropdown:AddItem(entry)
      end
    end    
  end

  self.characterDropdown:SetSelectedItem(self.selectedCharacter)
end

function CookeryWizMailer:OnStatusLabelInitialized(control)
  self.statusLabelControl = control
  self.statusLabelControl:SetText("")
end

function CookeryWizMailer:OnDescriptionLabelInitialized(control)
  --self.statusLabelControl = control
  control:SetText(L[CWL_LABEL_MAILER_DESCRIPTION_TEXT])
end

function CookeryWizMailer:OnCharacterLabelInitialized(control)
  --self.statusLabelControl = control
  control:SetText(L[CWL_LABEL_MAILER_CHARACTER_TEXT])
end

function CookeryWizMailer:OnAddressLabelInitialized(control)
  --self.statusLabelControl = control
  control:SetText(L[CWL_LABEL_MAILER_ADDRESS_TEXT])
end


function CookeryWizMailer:OnCharacterComboInitialized(control)  
  self.characterComboBox = control
  self.characterDropdown = ZO_ComboBox:New(control)   
end

function CookeryWizMailer:OnContentInitialized(control)

end

function CookeryWizMailer:OnEditAddressInitialized(control)
  self.editAddressControl = control
  control:SetText(L[CWL_EDIT_MAILER_ADDRESS_BLANK_TEXT])
end

function CookeryWizMailer:OnEditAddressFocusLost(control)
  local text = control:GetText()
  if text == "" then
    control:SetText(L[CWL_EDIT_MAILER_ADDRESS_BLANK_TEXT])
  end 
end

function CookeryWizMailer:OnEditAddressFocusGained(control)
  local text = control:GetText()
  if text == L[CWL_EDIT_MAILER_ADDRESS_BLANK_TEXT] then
    control:SetText("")
  end 
end

function CookeryWizMailer:OnEditAddressChanged(control)

  local text = control:GetText()
  
  if text == L[CWL_EDIT_MAILER_ADDRESS_BLANK_TEXT] then
    return
  end 

end

function CookeryWizMailer:OnAddContactButtonInitialized(control)
  self.addContactButton = control
  self:SetupTooltip(control, L[CWL_BUTTON_MAILER_TOOLTIP_ADD_TO_CONTACTS])
end

function CookeryWizMailer:OnRemoveContactButtonInitialized(control)
  self.removeContactButton = control
  self:SetupTooltip(control, L[CWL_BUTTON_MAILER_TOOLTIP_REMOVE_FROM_CONTACTS])
end

function CookeryWizMailer:OnContactsLabelInitialized(control)
  control:SetText(L[CWL_LABEL_MAILER_CONTACTS_TEXT])
end

function CookeryWizMailer:OnContactsComboInitialized(control)  
  self.contactsComboBox = control
  self.contactsDropdown = ZO_ComboBox:New(control)   
end

function CookeryWizMailer:PopulateContactsDropDown(contacts)
  local cookeryWizMailer = self
  
  if not self.contactsDropdown then
    d("No Contacts Dropdown")
    return
  end
  
  local function OnItemSelect(control, choiceText, choice)
    cookeryWizMailer.editAddressControl:SetText(choiceText)
  end
    
  self.contactsDropdown:ClearItems()

  -- populate from our stored list. The key of the list is the character name
  for key, contactData in pairs(contacts) do
      local entry = self.contactsDropdown:CreateItemEntry(key, OnItemSelect)
      self.contactsDropdown:AddItem(entry)
  end

  --self.characterDropdown:SetSelectedItem(self.selectedCharacter)
end

function CookeryWizMailer:GetContacts()
  if not self.cookeryWiz then
    d("Missing CookeryWiz object")
    return
  end
  
  local savedVars = self.cookeryWiz.savedVariables
  if not savedVars.contacts then
    self.cookeryWiz.savedVariables.contacts = {}
  end
  
  return self.cookeryWiz.savedVariables.contacts
end

-- If the entered address is not already a contact this routine will add it to the contacts
-- list
function CookeryWizMailer:OnAddContactButtonClicked(control)
  local contacts = self:GetContacts()
  
  if not contacts then
    d("Unable to get contacts")
    return
  end

  local text = self.editAddressControl:GetText()
  if text == L[CWL_EDIT_MAILER_ADDRESS_BLANK_TEXT] or text == "" then
    return
  end 
  
  -- only add if it exists
  if not contacts[text] then
    contacts[text] = { address = text }
    self:PopulateContactsDropDown(contacts)
  end
end

function CookeryWizMailer:OnRemoveContactButtonClicked(control)  
  local contacts = self:GetContacts()
  
  if not contacts then
    d("Unable to get contacts")
    return
  end
 
  local text = self.contactsDropdown:GetSelectedItem()
  if contacts[text] then
    contacts[text] = nil
    self:PopulateContactsDropDown(contacts)
  end
   
end

function CookeryWizMailer:OnSendToContactsButtonInitialized(control)
  control:SetText(L[CWL_BUTTON_MAILER_SEND_TO_CONTACTS])
  self:SetupTooltip(control, L[CWL_BUTTON_MAILER_TOOLTIP_SEND_TO_CONTACTS])
end

function CookeryWizMailer:OnSendToContactsButtonClicked(control)  
  if not self.selectedCharacter or self.selectedCharacter == "" then
    d("No character selected")
    return    
  end
  
  local contacts = self:GetContacts()
  
  if not contacts then
    d("Unable to get contacts")
    return
  end

  self:ClearSendToAddresses()

  -- populate from our stored list. The key of the list is the address
  local address = nil
  for address, contactData in pairs(contacts) do
      self:AddSendToAddress(address)
  end
  
  self:ClearStatus()
  
  -- mail them
  self.cookeryWiz:EnableScanning(false)
  
  -- now start the sending process
  self:SendToAddresses()
  
end

function CookeryWizMailer:OnSendButtonInitialized(control)
  control:SetText(L[CWL_BUTTON_MAILER_SENDMAIL])
  self:SetupTooltip(control, L[CWL_BUTTON_MAILER_TOOLTIP_SENDMAIL])
end

function CookeryWizMailer:SetStatus(text, color)
  if self.statusLabelControl then
    self.statusLabelControl:SetText(text)
    self.statusLabelControl:SetColor(color:GetParams())  
  end
end

function CookeryWizMailer:ClearStatus()
    if self.statusLabelControl then
      self.statusLabelControl:SetText("")
    end  
end

--
-- SendToAddresses
--

-- Addresses to send to
function CookeryWizMailer:GetNextSendToAddress()
  if not self.sendTo then
    return
  end
  
  for key, entry in pairs(self.sendTo) do
    return entry
  end      
end

-- Clear send to addresses
function CookeryWizMailer:ClearSendToAddresses()
  self.sendTo = {}  
end

-- Add send to address
function CookeryWizMailer:AddSendToAddress(address)
  if not address then
    d("No address passed to add!")
    return
  end
  self.sendTo[address] = address
end

-- remove send to address
function CookeryWizMailer:RemoveSendToAddress(address)
  self.sendTo[address] = nil
end

function CookeryWizMailer:SendToAddresses()
  local address = self:GetNextSendToAddress()  
  self.currentSendTo = address
  if address then
    self.cookeryWiz:SendKnownRecipes(self.selectedCharacter, address)
  else
    self.cookeryWiz:EnableScanning(true)
  end
end

function CookeryWizMailer:OnSendButtonClicked(control) 

  local address = self.editAddressControl:GetText()

  if not address or address == "" or address == L[CWL_EDIT_MAILER_ADDRESS_BLANK_TEXT] then
    self:SetStatus(L[CWL_NOTIFY_BLANK_ADDRESS], self.errorColor)
    return
  end
  
  self:ClearStatus()
  
  if not self.selectedCharacter or self.selectedCharacter == "" then
    d("No character selected")
    return    
  end
  
  self:ClearSendToAddresses()
  
  -- mail them
  self.cookeryWiz:EnableScanning(false)
  
  -- now start the sending process
  self:AddSendToAddress(address)
  self:SendToAddresses()
  
end
  
function CookeryWizMailer:OnMailSendFailed(eventCode, reason)

  trace("OnMailSendFailed "..eventCode..", reason "..reason)
  if self.currentSendTo then
    --self.currentSendTo = false
    --self.cookeryWiz:EnableScanning(true)
    self:SetStatus(L[CWL_LABEL_MAILER_SENT_FAILED], self.errorColor) 
    self:RemoveSendToAddress(self.currentSendTo)
    zo_callLater(function()
        self:SendToAddresses()
      end, self.throttlePeriod
      )

  end
end

function CookeryWizMailer:OnMailSendSuccess(eventCode)
  trace("OnMailSendSuccess ["..eventCode.."]") 
  if self.currentSendTo then
    --self.currentSendTo = false  
    --self.cookeryWiz:EnableScanning(true)
    self:SetStatus(L[CWL_LABEL_MAILER_SENT_SUCCESS], self.normalColor)
    self:RemoveSendToAddress(self.currentSendTo)
    zo_callLater(function()
        self:SendToAddresses()
      end, self.throttlePeriod
      )

  end
end

function CookeryWizMailer:ToggleShow(parentWindow)
  if not self.isInitialised then
    d("Not initialised")
    return
  end
  self.parentWindow = parentWindow
  local ui = self.ui
  local isHidden = self.ui:IsHidden()
  self:HideWindow(not isHidden)  
end




--[[
CookeryWizMailer.dialogControl = nil

function CookeryWizMailer:OnCookeryWizMailerUIInitialized(control)
  self.dialogControl = control
end
 ]]--
 
function CookeryWizMailer:Initialize(cookeryWiz)
  self.cookeryWiz = cookeryWiz
	local defaultSave =
	{
    easyFrameVariables = self.easyFrameVariables
	} 
  
  self.easyFrameVariables.isHidden = true

  self.isInitialised = true
  self:InitializeEasyFrameDialog(L[CWL_COOKERYWIZMAILER_TITLE], CookeryWizMailerUI)
    
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
  
  -- setup colours we will use
  self.normalColor = self:CreateColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
  self.errorColor = self:CreateColor(ZO_ERROR_COLOR:UnpackRGBA())
  
end

--[[
function CookeryWizMailer.OnAddOnLoaded(event, addonName)
  local self = CookeryWizMailer
  if addonName == self.name then
    self:Initialize()
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
  end
end

EVENT_MANAGER:RegisterForEvent(CookeryWizMailer.name, EVENT_ADD_ON_LOADED, CookeryWizMailer.OnAddOnLoaded)
]]--