-- Shissu Guild Tools Addon
-- ShissuNotebook
--
-- Version: v2.5.5.2
-- Last Update: 17.12.2020
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local orange = _globals["orange"]

local setDefaultColor = ShissuFramework["interface"].setDefaultColor
local createScrollContainer = ShissuFramework["interface"].createScrollContainer
local createFlatWindow = ShissuFramework["interface"].createFlatWindow
local createLine = ShissuFramework["interface"].createLine
local createFlatButton = ShissuFramework["interface"].createFlatButton

local showDialog = function(dialogTitle, dialogText, callbackFunc, vars)
  ESO_Dialogs["SGT_DIALOG"].title = {text = dialogTitle,}
  ESO_Dialogs["SGT_DIALOG"].mainText = {text = dialogText,}
  ESO_Dialogs["SGT_DIALOG"].buttons[1].callback = callbackFunc

  ZO_Dialogs_ShowDialog("SGT_DIALOG", vars)
end

local getWindowPosition = ShissuFramework["interface"].getWindowPosition
local saveWindowPosition = ShissuFramework["interface"].saveWindowPosition
local createColorButton = ShissuFramework["interface"].coloredButton
local notesDD = nil

local _addon = {}
_addon.Name	= "ShissuNotebook"
_addon.Version = "2.5.5.1"
_addon.lastUpdate = "17.12.2020"
_addon.formattedName = stdColor .. "Shissu" .. white .. "'s Notebook"
_addon.hexColorPicker = nil

local _L = ShissuFramework["func"]._L(_addon.Name)
local _ui = {}

local _note = {}
_note.scrollItem = 1
_note.indexPool = nil
_note.list = nil
_note.lastFocus = nil
_note.currentID = nil
_note.cache = {}
_note.autoPost = false
_note.command = ""

-- Notebook
function _note.setControlToolTip(control)
  control:SetHandler("OnMouseEnter", function(self) 
    if control:GetText() ~= "" then ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, control:GetText()) end
  end)
  
  control:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
end

function _note.createIndexButton(indexPool)
  local control = ZO_ObjectPool_CreateControl("SGT_Notebook_Index", indexPool, _note.list.scrollChild)
  local anchorBtn = _note.scrollItem == 1 and _note.list.scrollChild or indexPool:AcquireObject(_note.scrollItem-1)
  
  control:SetAnchor(TOPLEFT, anchorBtn, _note.scrollItem == 1 and TOPLEFT or BOTTOMLEFT)
  control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  control:SetWidth(180)
  control:SetHandler("OnMouseUp", function(self, button)
    _note.selected:SetHidden(false)
    _note.selected:ClearAnchors()
    _note.selected:SetAnchorFill(self)      
    _note.currentID = self.ID

    SGT_Notebook_NoteTitleText:SetText(self.noteTitle) 
    SGT_Notebook_NoteText:SetText(self.text)
    SGT_Notebook_SlashText:SetText(self.command) 
    SGT_Notebook_AutoStringText:SetText(self.autoString)

    if self.autopost then ZO_CheckButton_SetChecked(SGT_Notebook_AutoStringEnabled)
    else ZO_CheckButton_SetUnchecked(SGT_Notebook_AutoStringEnabled) end

    -- Rückgängig machen - Cache
    _note.cache.title = self.noteTitle
    _note.cache.text = self.text
    _note.cache.autoString = self.autoString
    if (_note.cache.autoPost) then
      _note.cache.autoPost = _note.autoPost
    end
    
    _note.cache.command = _note.command
  end)
  
  control:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, white .. self.noteTitle) end)
  control:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)  

  _note.scrollItem = _note.scrollItem  + 1
  
  return control
end

function _note.removeIndexButton(control)
  control:SetHidden(true)
end

function _note.fillScrollList()
  local numPages = #shissuNotebook
  local sortedTitle = {}
  local sortedData = {}
  for i = 1, numPages do
    table.insert(sortedTitle, i, shissuNotebook[i].title .. "**shissu" ..i)
  end
  
  table.sort(sortedTitle)
  
  for i = 1, numPages do
    local length = string.len(sortedTitle[i])
    local number = string.sub(sortedTitle[i], string.find(sortedTitle[i], "**shissu"), length)
    
    number = string.gsub(number, "**shissu", "")
    number = string.gsub(number, " ", "")
    number = tonumber(number)

    sortedData[i] = {}
    sortedData[i].title = shissuNotebook[number].title
    sortedData[i].text = shissuNotebook[number].text
    sortedData[i].autoString = shissuNotebook[number].autostring
    sortedData[i].autopost = shissuNotebook[number].autopost
    sortedData[i].command = shissuNotebook[number].command
    sortedData[i].number = number
  end

  notesDD.notes:ClearItems()

  for i = 1, numPages do
    notesDD.notes:AddItem(notesDD.notes:CreateItemEntry(sortedData[i].title, _addon.setMailContent))
          
    local control = _note.indexPool:AcquireObject(i)
    control.noteTitle = sortedData[i].title
    control.text = sortedData[i].text
    control.ID = sortedData[i].number
    control.autoString = sortedData[i].autoString
    control.autopost = sortedData[i].autopost
    control.command = sortedData[i].command
    control:SetText(white .. sortedData[i].title)
    control:SetHidden(false)
  end
  
  local activePages = _note.indexPool:GetActiveObjectCount()
  if activePages > numPages then
    for i = numPages+1, activePages do _note.indexPool:ReleaseObject(i) end
  end
end

function _addon.setMailContent(_, statusText)
  local numPages = #shissuNotebook

  for i = 1, numPages do
    if (statusText == shissuNotebook[i].title) then
      ZO_MailSendSubjectField:SetText(statusText)
      ZO_MailSendBodyField:SetText(shissuNotebook[i].text)  
      break
    end
  end
  
end

function _note.onTextChanged()
  local control = SGT_Notebook_NoteLength
  local length = string.len(SGT_Notebook_NoteText:GetText())

  if length > 700 then control:SetText(_L("MAIL") .. " " .. orange .. length .. "|r/700")
  elseif length > 400 then control:SetText(_L("CHAT") .. " " .. stdColor .. length .. "|r/700") 
  elseif length > 350 then control:SetText(_L("CHAT") .. " " .. stdColor .. length .. "|r/350")
  else control:SetText(_L("CHAT") .. " " .. length .. "/350")
  end
end

function _note.new() 
  _note.clearAllElements()
  _note.cache.title = nil
  _note.currentID = nil
  
  SGT_Notebook_NoteTitleText:SetText(":-)")
  SGT_Notebook_NoteTitleText:TakeFocus()
end  

function _note.clearAllElements()
  SGT_Notebook_NoteTitleText:Clear()
  SGT_Notebook_NoteText:Clear()
  SGT_Notebook_AutoStringText:Clear()
  SGT_Notebook_SlashText:Clear()
  ZO_CheckButton_SetUnchecked(SGT_Notebook_AutoStringEnabled)
end

function _note.delete()
  if _note.currentID ~= nil then
    showDialog(_L("DELETE_TT"), _L("DELETE_TT") .. ": " .. shissuNotebook[_note.currentID].title, function()
      table.remove(shissuNotebook, _note.currentID)
      _note.clearAllElements()   
      _note.fillScrollList()
    end, nil)
  end
end

function _note.sendTo(self, button)
  if button == 1 then CHAT_SYSTEM:StartTextEntry(SGT_Notebook_NoteText:GetText()) 
  elseif button == 2 then _note.save()
  elseif button == 3 then
    SCENE_MANAGER:Show('mailSend')
    ZO_MailSendBodyField:SetText(SGT_Notebook_NoteText:GetText())
    ZO_MailSendSubjectField:SetText(SGT_Notebook_NoteTitleText:GetText())
    ZO_MailSendBodyField:TakeFocus()  
  end
end

function _note.save()
  local noteTitle = SGT_Notebook_NoteTitleText:GetText()
  local noteText = SGT_Notebook_NoteText:GetText()
  local noteSlashCommand = SGT_Notebook_SlashText:GetText()
  local noteAutoPost = SGT_Notebook_AutoStringText:GetText()

  if _note.currentID == nil then
    table.insert(shissuNotebook, {["title"] = noteTitle, ["text"] = noteText, ["command"] = noteSlashCommand, ["autopost"]= _note.autoPost, ["autostring"] = noteAutoPost})
    _note.currentID = #shissuNotebook
  else
    if (shissuNotebook[_note.currentID] ~= nil) then  
      shissuNotebook[_note.currentID].title = noteTitle
      shissuNotebook[_note.currentID].text = noteText
      shissuNotebook[_note.currentID].command = noteSlashCommand
      shissuNotebook[_note.currentID].autopost = _note.autoPost
      shissuNotebook[_note.currentID].autostring = noteAutoPost 
    end
  end
      
  _note.fillScrollList()
end

function _note.undo()
  if _note.cache.title ~= nil then
    SGT_Notebook_NoteTitleText:SetText(_note.cache.title) 
    SGT_Notebook_NoteText:SetText(_note.cache.text)
    SGT_Notebook_SlashText:SetText(_note.cache.command) 
    SGT_Notebook_AutoStringText:SetText(_note.cache.autoString) 
      
    if _note.cache.autopost then ZO_CheckButton_SetChecked(SGT_Notebook_AutoStringEnabled)
    else ZO_CheckButton_SetUnchecked(SGT_Notebook_AutoStringEnabled) end
  end
end

function _addon.createBackdropBackground(mainParent, mainParent2, dimensions, tex)
  if (tex == nil) then tex = "" end
  
  local control = CreateControl(mainParent .. "_BG", mainParent2, CT_TEXTURE)
	control:SetTexture("ShissuFramework/textures/backdrop" .. tex .. ".dds")
	control:SetDimensions(dimensions[1], dimensions[2])  
	control:SetAnchor(TOPLEFT, mainParent2, TOPLEFT, 0, 0)
	control:SetDrawLayer(1)
end

function _addon.close()
 SGT_Notebook:SetHidden(true) 
      
  if (SGT_Notebook_MessagesRecipient) then
    SGT_Notebook_MessagesRecipient:SetHidden(true)
  end
end

-- Notebook UI
function _addon.notebook()
  createFlatWindow(
    "SGT_Notebook",
    SGT_Notebook,  
    {640, 480}, 
    _addon.close,
    _L("TITLE")
  ) 

  _ui.divider = createLine("Divider", {400, 1}, "SGT_Notebook", SGT_Notebook,  TOPLEFT, 200, 50, {BOTTOMLEFT, 200, -20}, {0.49019607901573, 0.74117648601532, 1}, true)
  _ui.background1 = _addon.createBackdropBackground("SGT_Notebook_NoteTitle", SGT_Notebook_NoteTitle, {290, 30})
  _ui.background2 = _addon.createBackdropBackground("SGT_Notebook_Note", SGT_Notebook_Note, {420, 230}, 2)
  _ui.background3 = _addon.createBackdropBackground("SGT_Notebook_AutoString", SGT_Notebook_AutoString, {290, 30})
  _ui.background4 = _addon.createBackdropBackground("SGT_Notebook_Slash", SGT_Notebook_Slash, {290, 30})

  -- ScrollContainer + UI
  _note.indexPool = ZO_ObjectPool:New(_note.createIndexButton, _note.removeIndexButton) 
  _note.list = createScrollContainer("SGT_Notebook_List", 185, SGT_Notebook, SGT_Notebook_Line2, 10, 10, -10)

  _note.selected = WINDOW_MANAGER:CreateControl(nil, _note.list.scrollChild, CT_TEXTURE)
  _note.selected:SetTexture("EsoUI\\Art\\Buttons\\generic_highlight.dds")
  _note.selected:SetHidden(true)
  setDefaultColor(_note.selected)
  
  -- Allgemeine Formatierungen
  SGT_Notebook_NoteText:SetMaxInputChars(30000)
  SGT_Notebook_SlashText:SetMaxInputChars(24)
  SGT_Notebook_SlashInfo:SetText(_L("SLASH"))
  SGT_Notebook_Version:SetText(_addon.formattedName.. " " .. _addon.Version)
  
  local editBox = SGT_Notebook_NoteText
  local buttonLabel = "SGT_Notebook_Color"
  _ui.button1 = createColorButton("1", SGT_Notebook_NoteTitle, "1", {-250, 40}, buttonLabel, editBox)  
  _ui.button2 = createColorButton("2", _ui.button1, "2", nil, buttonLabel, editBox)  
  _ui.button3 = createColorButton("3", _ui.button2, "3", nil, buttonLabel, editBox)  
  _ui.button4 = createColorButton("4", _ui.button3, "4", nil, buttonLabel, editBox)  
  _ui.button5 = createColorButton("5", _ui.button4, "5", nil, buttonLabel, editBox)  
  _ui.buttonW = createColorButton("W", _ui.button5, nil, nil, buttonLabel, editBox)  
  _ui.buttonANY = createColorButton("ANY", _ui.buttonW, nil, nil, buttonLabel, editBox)   

  SGT_Notebook_NoteText:SetHandler("OnFocusGained", function(self) _note.lastFocus = self end)
  
  SGT_Notebook_NoteTitleText:SetHandler("OnFocusGained", function(self) _note.lastFocus = self end)
  SGT_Notebook_NoteText:SetHandler("OnTextChanged",_note.onTextChanged)
  SGT_Notebook_New:SetHandler("OnClicked", _note.new)
  SGT_Notebook_New:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, _L("NEW_TT")) end)
  SGT_Notebook_Delete:SetHandler("OnClicked", _note.delete)
  SGT_Notebook_Delete:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, _L("DELETE_TT")) end)
  SGT_Notebook_SendTo:SetHandler("OnMouseUp", _note.sendTo) 
  SGT_Notebook_SendTo:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, _L("SENDTO_TT")) end)
  SGT_Notebook_Undo:SetHandler("OnMouseUp", _note.undo) 
  SGT_Notebook_Undo:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, _L("UNDO_TT")) end)

  SGT_Notebook_SlashText:SetHandler("OnEnter", function(self) self:LoseFocus() _note.save() end)     
  SGT_Notebook_SlashText:SetHandler("OnTextChanged", function() 
    local text = SGT_Notebook_SlashText:GetText()
    
    if (string.len(text) > 0) then
      ZO_Tooltips_ShowTextTooltip(self, BOTTOMRIGHT, stdColor .. "/note " .. white .. text)
    else
      ZO_Tooltips_HideTextTooltip()
    end
    
    _note.onTextChanged()
  end) 

  ZO_CheckButton_SetLabelText(SGT_Notebook_AutoStringEnabled, white .. "Auto Post")
  ZO_CheckButton_SetToggleFunction(SGT_Notebook_AutoStringEnabled, function(control, checked) _note.autoPost = checked end)
  

  _note.setControlToolTip(SGT_Notebook_NoteTitleText)                                                                                    
  _note.setControlToolTip(SGT_Notebook_NoteText) 
    
  notesDD = WINDOW_MANAGER:CreateControlFromVirtual("SGT_TTTTTTTTT", ZO_MailSend, "ZO_ComboBox")
  notesDD:SetAnchor(TOPLEFT, ZO_MailSend, TOPLEFT, 200, 30)
  notesDD:SetHidden(false)
  notesDD:SetWidth(140) 
  notesDD.dropdown = ZO_ComboBox_ObjectFromContainer(notesDD)
  
  notesDD.notes = notesDD.dropdown
  notesDD.notes:SetSortsItems(false) 

  _note.fillScrollList()  
end

function _addon.autoPost(_, channelType, fromName, text, isCustomerService, fromDisplayName)
  if text == nil then return false end
  
  local currentText = CHAT_SYSTEM.textEntry:GetText()
  local channelInfo = ZO_ChatSystem_GetChannelInfo()[channelType]
  
  if (channelInfo.switches ~= nil) then
    local channelString  = string.sub(channelInfo.switches, 1, string.find(channelInfo.switches, " "))

    if string.len(currentText) < 1 then
      local pages = #shissuNotebook
    
      for i = 1, pages do
        local note = shissuNotebook[i]
        
        if note.autopost then   
          if (note.autostring ~= nil) then
            if (string.len(note.autostring) > 1) then
              -- Mehrere getrennte Wörter in den jeweiligen Strings
              if string.find (note.autostring, " ") or string.find (text, " ")  then
                for singleString in string.gmatch(note.autostring, "%a+") do 
                  for singleString2 in string.gmatch(text, "%a+") do 
                    if string.lower(singleString) == string.lower(singleString2) then
                      CHAT_SYSTEM:StartTextEntry(channelString .. "")
                      CHAT_SYSTEM:StartTextEntry(note.text)
                      return true
                    end
                  end
                end
                
              else
                if string.lower(text) == string.lower(note.autostring) then  
                  CHAT_SYSTEM:StartTextEntry(channelString .. "")
                  CHAT_SYSTEM:StartTextEntry(note.text)
                  return true
                end
              end              
            end
          end
        end 
      end
    end
  end
end

function _addon.cmdSlash(cmd)
  if (cmd == nil) then return end
  if ( shissuNotebook == nil ) then return end

  local pages = #shissuNotebook
                     
  for i = 1, pages do
    local note = shissuNotebook[i]
           
    if string.lower(cmd) == string.lower(note.command) then
      if string.len(note.text) > 1 then
        CHAT_SYSTEM:StartTextEntry(note.text)
      else
        d(_L("NOSLASH"))
      end
      return true
    end 
  end
end
            
local function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  
  if orig_type == 'table' then
    copy = {}
    
    for orig_key, orig_value in next, orig, nil do
      copy[deepcopy(orig_key)] = deepcopy(orig_value)
    end
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else
    copy = orig
  end
  
  return copy
end      

-- Initialisierung
function _addon.initialized()
  shissuNotebook = shissuNotebook or {}
  shissuColor = shissuColor or {}

  if ( shissuNotebook == {} and shissuGT ~= nil ) then
    if ( shissuGT["Notes"] ~= nil ) then
      shissuNotebook = deepcopy(shissuGT["Notes"])
      shissuGT["Notes"] = nil
    end
  end

  zo_callLater(function() 
    _addon.notebook()
    ShissuFramework["interface"].initChatButton()
  end, 150)

  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_CHAT_MESSAGE_CHANNEL, _addon.autoPost)
  
  if shissuNotebook["positions"] == nil then
    shissuNotebook["positions"] = {}
  end  

  if (shissuNotebook["positions"]["notebook"] == nil) then
    shissuNotebook["positions"]["notebook"] = {}
  end
  
  saveWindowPosition(SGT_Notebook, shissuNotebook["positions"]["notebook"])
  getWindowPosition(SGT_Notebook, shissuNotebook["positions"]["notebook"])
    
  -- Slash Command      
  SLASH_COMMANDS["/note"] = _addon.cmdSlash
  SLASH_COMMANDS["/no"] = _addon.cmdSlash
  SLASH_COMMANDS["/n"] = _addon.cmdSlash
  SLASH_COMMANDS["/notebook"] = function() 
    SGT_Notebook:SetHidden(false) 
    
    if SGT_Notebook_MessagesRecipient then
      SGT_Notebook_MessagesRecipient:SetHidden(false)
    end
  end            

  --_addon.buttonColor(SGT_Notebook_New)
 -- _addon.buttonColor(SGT_Notebook_SendTo)
end       

function _addon.buttonColor(control)
  control:SetColor( ShissuFramework["interface"].getThemeColor() )

  control:SetHandler("OnMouseExit", function(self) 
    ZO_Tooltips_HideTextTooltip()
    self:SetColor( ShissuFramework["interface"].getThemeColor() )
  end)

  control:SetHandler("OnMouseEnter", function(self) 
    self:SetColor(1, 1, 1, 1)
  end)
end                        
 
function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end
                        
  zo_callLater(function()              
    ShissuFramework.initAddon(_addon.Name, _addon.initialized)

    ShissuFramework._bindings.notebookToogle = function() 
      local control = GetControl("SGT_Notebook")
      if (control) then
        if (control:IsHidden()) then
          control:SetHidden(false)
        else
          control:SetHidden(true)
        end
      end
    end

  end, 150) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)