-- ShissuPlayerObservation
-- -----------------------
-- 
-- Desc:        Hebt Spieler im Sichtfeld auf Wunsch farbig hevor. Zudem wird eine Information mitgeteilt, wenn der Spieler sich in Gilde XYZ befindet. 
--              Auf Wunsch lässt sich der Spieler automatischen kicken, indem dieser auf die Ausschlussliste gesetzt wird.
--
-- Filename:    ShissuObservePlayers
-- Last Update: 17.12.2020
-- Version:     v1.4.1
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local yellow = _globals["yellow"]
local red = _globals["red"]

local _addon = {}
_addon.Name = "ShissuPlayerObservation"
_addon.Version = "1.4.0"
_addon.lastUpdate = "14.12.2020"                                                        
_addon.selectCategory = "general"
 
local _L = ShissuFramework["func"]._L(_addon.Name)

_addon.formatedName = stdColor .. "Shissu" .. white .. "'s " .. _L("TITLE")  

local ShissuPlayerObservation = ZO_SocialListKeyboard:Subclass()

ShissuPlayerObservation.SORT_KEYS = {
  ["name"] = {},
  ["observe"] = {tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["autokick"] = {tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["guild1"] = {tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["guild2"] = {tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["guild3"] = {tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["guild4"] = {tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["guild5"] = {tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP},
}

function ShissuPlayerObservation:New(...)
  return ZO_SocialListKeyboard.New(self, ...)
end

function _addon.selectedCategory(_ , statusText)
  if (statusText == stdColor .. "-- " .. white .. _L("GENERAL")) then
    _addon.selectCategory = "general" 
  else
    _addon.selectCategory = statusText  
  end
  
  _addon.getColors()   
  SHISSUPLAYEROBSERVATION:Refresh()
end

function _addon.isBlank(x)
  return not not tostring(x):find("^%s*$")
end

function _addon.newCategory()
  ESO_Dialogs["SGT_EDIT"].title = {text = _L("CATEGORY"),}
  ESO_Dialogs["SGT_EDIT"].mainText = {text = "Name?",}  
  ESO_Dialogs["SGT_EDIT"].buttons[1] = {text = "OK",}     
  ESO_Dialogs["SGT_EDIT"].buttons[1].callback = function(dialog) 
    local title = dialog:GetNamedChild("EditBox"):GetText()
    
    if not _addon.isBlank(title) then
      _addon.categories:AddItem(_addon.categories:CreateItemEntry(title, _addon.selectedCategory))

      if (shissuPlayerObservation[title] == nil) then
        shissuPlayerObservation[title] = {}
      end
    end
  end

  ZO_Dialogs_ShowDialog("SGT_EDIT")
end
                                   
function _addon.deleteCategory()
  if ( _addon.selectCategory ~= "general") then
    shissuPlayerObservation[_addon.selectCategory] = nil
  end
  
  _addon.selectCategory = "general"
  _addon.refreshCategory()
end
                           
function _addon.refreshCategory()
  _addon.categories:ClearItems()
  
  _addon.categories:AddItem(_addon.categories:CreateItemEntry(stdColor .. "-- " .. white .. _L("GENERAL"), _addon.selectedCategory))
  
  for categoryName, categoryData in pairs(shissuPlayerObservation) do  
    if (categoryName ~= "general" and categoryName ~= "color") then     
      _addon.categories:AddItem(_addon.categories:CreateItemEntry(categoryName, _addon.selectedCategory))
    end
  end 
  
  _addon.getColors()   
end

function _addon.getColors()   
  if shissuPlayerObservation["color"] ~= nil then
    if shissuPlayerObservation["color"][_addon.selectCategory] ~= nil then      
      local color = shissuPlayerObservation["color"][_addon.selectCategory].color
      
      if color then
        ShissuPlayerObservationColorPicker:SetColor(color[1], color[2], color[3])
      else
        ShissuPlayerObservationColorPicker:SetColor(1, 1, 1)
      end
      
      if shissuPlayerObservation["color"][_addon.selectCategory].enabled then
        ZO_CheckButton_SetChecked(ShissuPlayerObservationColorCheckBox)
      else
        ZO_CheckButton_SetUnchecked(ShissuPlayerObservationColorCheckBox)
      end
    else
      ShissuPlayerObservationColorPicker:SetColor(1, 1, 1)
      ZO_CheckButton_SetUnchecked(ShissuPlayerObservationColorCheckBox)
    end       
  else
    ShissuPlayerObservationColorPicker:SetColor(1, 1, 1)
    ZO_CheckButton_SetUnchecked(ShissuPlayerObservationColorCheckBox)  
  end
end

function ShissuPlayerObservation:Initialize(control)     
  ZO_SocialListKeyboard.Initialize(self, control)

  control:SetHandler("OnEffectivelyHidden", function() self:OnEffectivelyHidden() end)

  ZO_ScrollList_AddDataType(self.list, 1, "ShissuPlayerObservationRow", 30, function(control, data) self:SetupRow(control, data) end)
  ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
  
  self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, self.SORT_KEYS, self.currentSortOrder) end
  self:SetAlternateRowBackgrounds(true)
  self:SetEmptyText("NO DATA")
  self.sortHeaderGroup:SelectHeaderByKey("name") 

  ShissuPlayerObservationObserve:SetText(yellow .. _L("OBSERVE"))
  ShissuPlayerObservationAutoKick:SetText(red .. _L("AUTOKICK"))
  ShissuPlayerObservationDeleteLabel:SetText(red .. _L("DELETEINFO"))   
  ShissuPlayerObservationVersion:SetText(stdColor .. "Shissu's" .. white .. " Player observation " .. _addon.Version) 
  
  ShissuPlayerObservationCategoriesLabel:SetText(white .. _L("CATEGORIES"))
  
  local numGuild = GetNumGuilds()
  
  for i=1, numGuild do
    local guildId = GetGuildId(i)
    local guildName = GetGuildName(guildId)
    
    local textControl = control:GetNamedChild("Guild" .. i)
    textControl:SetText(white .. guildName)
    textControl:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
    textControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, "|ceeeeee".. guildName) end)
  end
  
  local controlAnchor = control:GetNamedChild("CategoriesLabel")
  
  _addon.Categories = CreateControlFromVirtual(control:GetName() .. "Combo", control, "ZO_ComboBox")
  _addon.Categories:SetAnchor(RIGHT, controlAnchor, RIGHT, 250, 0)
  _addon.Categories:SetHidden(false)
  _addon.Categories:SetWidth(200) 
  _addon.Categories.dropdown = ZO_ComboBox_ObjectFromContainer(_addon.Categories)

  _addon.categories = _addon.Categories.dropdown
  _addon.categories:SetSortsItems(false) 

  ShissuPlayerObservationAdd:SetHandler("OnClicked", _addon.newCategory)
  ShissuPlayerObservationDelete:SetHandler("OnClicked", _addon.deleteCategory)
  
  local sceneName = "shissuPlayerObservation"
  self.scene = ZO_Scene:New("shissuPlayerObservation", SCENE_MANAGER)
  
  local fragment = ZO_FadeSceneFragment:New(control, "nil", 0)

  local menuBarIcon = MAIN_MENU_KEYBOARD["sceneGroupInfo"]["guildsSceneGroup"]["menuBarIconData"]
  table.insert(menuBarIcon, {
    categoryName = _addon.formatedName,
    descriptor = "shissuPlayerObservation",
    normal = "ShissuFramework/textures/button_sgt.dds",
    pressed = "ShissuFramework/textures/button_sgt.dds",
    highlight = "ShissuFramework/textures/button_sgt2.dds",
  })
  
  local sceneGroup = "guildsSceneGroup"
  local fragsceneGroup = SCENE_MANAGER:GetSceneGroup("guildsSceneGroup")
  fragsceneGroup:AddScene(sceneName)

  self.scene:AddFragment(KEYBIND_STRIP_FADE_FRAGMENT)   
  self.scene:AddFragment(UI_SHORTCUTS_ACTION_LAYER_FRAGMENT)
  self.scene:AddFragment(GUILD_SHARED_INFO_FRAGMENT)     
  self.scene:AddFragment(fragment)

  self.scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
  self.scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
  self.scene:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
  self.scene:AddFragment(RIGHT_BG_FRAGMENT)
  self.scene:AddFragment(FRAME_EMOTE_FRAGMENT_SOCIAL)
    
  self.scene:RegisterCallback("StateChange", function(oldState, state)
    if(state == SCENE_SHOWING) then
      self:PerformDeferredInitialization()                                                               
      KEYBIND_STRIP:AddKeybindButtonGroup(self.staticKeybindStripDescriptor)
    elseif(state == SCENE_HIDDEN) then
      KEYBIND_STRIP:RemoveKeybindButtonGroup(self.staticKeybindStripDescriptor)                           
    end
  end)   
  
  -- Kategorienfarben, für Spieler in Sichtfeld!
  local function checkCategorie()
    if shissuPlayerObservation["color"] == nil then
      shissuPlayerObservation["color"] = {}
    end   
    
    if shissuPlayerObservation["color"][_addon.selectCategory] == nil then
      shissuPlayerObservation["color"][_addon.selectCategory] = {}
    end  
  end
  
  ShissuPlayerObservationColorLabel:SetText(white .. _L("COLOR"))
  ShissuPlayerObservationColorLabel2:SetText(white .. _L("COLORINSIGHT"))
  
  local controlColorPicker = CreateControl("ShissuPlayerObservationColorPicker", ShissuPlayerObservationColorLabel, CT_TEXTURE)
  controlColorPicker:SetAnchor(LEFT, ShissuPlayerObservationColorLabel, RIGHT, 10, 0)
  controlColorPicker:SetDimensions(40, 24)
  controlColorPicker:SetMouseEnabled(true)
  
  local function ColorPickerCallback(r, g, b)                        
    controlColorPicker:SetColor(r, g, b)
    checkCategorie()  
    
    shissuPlayerObservation["color"][_addon.selectCategory].color = {r, g, b, a or 1}  
  end
         
  controlColorPicker:SetHandler("OnMouseUp", function(self, btn, upInside) 
    if upInside then
      COLOR_PICKER:Show(ColorPickerCallback, r, g, b, a, _L("COLORINSIGHT"))
    end
  end)
    
  local controlColor = CreateControlFromVirtual("ShissuPlayerObservationColorCheckBox", controlColorPicker, "ZO_CheckButton")
  controlColor:SetAnchor(LEFT, controlColorPicker, RIGHT, 10, 0) 
   
  ZO_CheckButton_SetToggleFunction(controlColor, function(control, checked)
    checkCategorie()
      
    if (checked) then
      shissuPlayerObservation["color"][_addon.selectCategory].enabled = 1
    else
      shissuPlayerObservation["color"][_addon.selectCategory].enabled = 0
    end  
  end)            
  
  _addon.getColors()                                    
end

function ShissuPlayerObservation:PerformDeferredInitialization()   
  if self.staticKeybindStripDescriptor ~= nil then return end
  self:RefreshData()
  self:InitializeKeybindDescriptors()
end

function ShissuPlayerObservation:InitializeKeybindDescriptors()
  self.staticKeybindStripDescriptor = {
    alignment = KEYBIND_STRIP_ALIGN_CENTER, 
    
    {
      name = _L("ADD"),
      keybind = "UI_SHORTCUT_PRIMARY",
      callback = function()
        ESO_Dialogs["SGT_EDIT"].title = {text = _L("ADD"),}
        ESO_Dialogs["SGT_EDIT"].mainText = {text = "Account, Character?",}  
        ESO_Dialogs["SGT_EDIT"].buttons[1] = {text = "OK",}     
        ESO_Dialogs["SGT_EDIT"].buttons[1].callback = function(dialog) 
          local displayName = dialog:GetNamedChild("EditBox"):GetText()
          
          self:addToList(displayName)
        end
      
        ZO_Dialogs_ShowDialog("SGT_EDIT")
      end,
    },
    {
      name = _L("IMPORT1"),
      keybind = "UI_SHORTCUT_SECONDARY",
      callback = function()
        ESO_Dialogs["SGT_RADIOBUTTONS"].title = {text = _L("IMPORT1"),}
        ESO_Dialogs["SGT_RADIOBUTTONS"].mainText = {
          text = red .. " L|r" .. " = " .. _L("IMPORT2") .. "\n"
            .. stdColor .. " B|r" .. " = " .. _L("IMPORT3") .. "\n"
            .. yellow .. " O|r" .. " = " .. _L("IMPORT4")
        ,}  
        
        ESO_Dialogs["SGT_RADIOBUTTONS"].radioButtons = {}
        ESO_Dialogs["SGT_RADIOBUTTONS"].radioButtons[1] = {
          text = _L("IMPORT5"),
          data = { ignore = true}
        }
                 
        local guildId = GUILD_SELECTOR.guildId
        local numRanks = GetNumGuildRanks(guildId)
             
        for rankId=1, numRanks do
          local ranks = ESO_Dialogs["SGT_RADIOBUTTONS"].radioButtons
          
          local lead = ""
          
          if ( IsGuildRankGuildMaster(guildId, rankId) ) then
            lead = red .. " L"
          end
          
          local bid = ""
          if ( DoesGuildRankHavePermission(guildId, rankId, GUILD_PERMISSION_GUILD_KIOSK_BID) ) then
           bid = stdColor .. " B"
          end 

          local offChat = ""
          if ( DoesGuildRankHavePermission(guildId, rankId, GUILD_PERMISSION_OFFICER_CHAT_READ) or DoesGuildRankHavePermission(guildId, rankId, GUILD_PERMISSION_OFFICER_CHAT_WRITE) )then
           offChat = yellow .. " O"
          end    
          
          local info = ""          
          if ( offChat ~= "" or bid ~= "" or lead ~= bid ) then
            info = " (" .. lead .. bid .. offChat .. "|r )"
          end      
          
          local icon = "|t24:24:" .. GetGuildRankSmallIcon(GetGuildRankIconIndex(guildId, rankId)) .. "|t"
          
          ranks[#ranks + 1] = {
            text = icon .. GetGuildRankCustomName(guildId, rankId) .. info,
            
            data = { ignore = false, rankId = rankId}
          }  
        end  
        
        ESO_Dialogs["SGT_RADIOBUTTONS"].buttons[1] = {text = _L("IMPORT1"),}    
        ESO_Dialogs["SGT_RADIOBUTTONS"].buttons[1].callback = function(dialog)           
          local selectedData = ZO_Dialogs_GetSelectedRadioButtonData(dialog)

          if ( selectedData.ignore == true) then
            local numIgnored = GetNumIgnored()
            
            for ignoredId = 1, numIgnored do
              self:addToList(GetIgnoredInfo(ignoredId))
            end       
          else
            local numMembers = GetNumGuildMembers(guildId)
            
            for memberId=1, numMembers do
              local accInfo = {GetGuildMemberInfo(guildId, memberId)}

              if (accInfo[3] == selectedData.rankId) then
                self:addToList(accInfo[1])
              end      
            end  
          end            
        end

        ZO_Dialogs_ShowDialog("SGT_RADIOBUTTONS")
      end,
    },
  }
end

function ShissuPlayerObservation:addToList(name)
  if not _addon.isBlank(name) then
    if self.masterList[name] == nil then 
      self.masterList[name] = {}
              
      self.masterList[name].observe = 0
      self.masterList[name].autokick = 0
    end
            
    if shissuPlayerObservation[_addon.selectCategory] == nil then
      shissuPlayerObservation[_addon.selectCategory] = {}
    end
        
    shissuPlayerObservation[_addon.selectCategory][name] = {}
  end
          
  self:Refresh()
end

function ShissuPlayerObservation:BuildMasterList()
  self.masterList = {} 

  if (shissuPlayerObservation[_addon.selectCategory] ~= nil) then
    for displayName, saveData in pairs(shissuPlayerObservation[_addon.selectCategory]) do
      local data = {}
        
      data["name"] = displayName
        
      for varName, varArgument in pairs(saveData) do
        if varName ~= "name" then
          data[varName] = varArgument
        end
      end
                       
      table.insert(self.masterList, data)
    end
  end       
end

function ShissuPlayerObservation:FilterScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(scrollData)
    
  for i = 1, #self.masterList do
    if ((self.masterList[i].hidden == nil) or (self.masterList[i].hidden == false)) then
      local entry = self.masterList[i]
      table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1,  entry))
     end
  end
end

function ShissuPlayerObservation:SortScrollList()
  if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
  end
end

function _addon.SetCheckBox(control, data)
  if (data == 1) then
    ZO_CheckButton_SetChecked(control)
  else
    ZO_CheckButton_SetUnchecked(control)
  end  
end

function _addon.SetCheckFunction(control, data, varName)
  ZO_CheckButton_SetToggleFunction(control, function(control, checked)
    if (checked) then
      data[varName] = 1
    else
      data[varName] = 0
    end  
    
    if shissuPlayerObservation[_addon.selectCategory] == nil then 
      shissuPlayerObservation[_addon.selectCategory] = {} 
    end
    
    local displayName = ""
    
    for varName, varArgument in pairs(data) do
      if varName == "name" then
        if ( shissuPlayerObservation[_addon.selectCategory][varArgument] == nil) then
          shissuPlayerObservation[_addon.selectCategory][varArgument] = {}
        end 
        
        displayName = varArgument
                
        break
      end
    end
    
    shissuPlayerObservation[_addon.selectCategory][displayName][varName] = data[varName]
  end)
end

function ShissuPlayerObservation:SetupRow(control, data)
  control.data = data
  
  local nameControl = control:GetNamedChild('Name')
  nameControl:SetText(data.name) 

  local observeControl = control:GetNamedChild('Observe')
  if(not observeControl) then
    controlName = control:GetName() .. "Observe"
    observeControl = CreateControlFromVirtual(controlName, control, "ZO_CheckButton")
    observeControl:SetAnchor(LEFT, nameControl, RIGHT, 10, 0) 
  end  

  if data.observe ~= nil then 
    _addon.SetCheckBox(observeControl, data.observe)
  end
  
  _addon.SetCheckFunction(observeControl, data, "observe")
  
  local autokickControl = control:GetNamedChild('AutoKick')
  if(not autokickControl) then
    controlName = control:GetName() .. "AutoKick"
    autokickControl = CreateControlFromVirtual(controlName, control, "ZO_CheckButton")
    autokickControl:SetAnchor(LEFT, observeControl, RIGHT, 100, 0) 
  end  
  
  if data.autokick ~= nil then 
    _addon.SetCheckBox(autokickControl, data.autokick)
  end
  
  _addon.SetCheckFunction(autokickControl, data, "autokick")
  
  local numGuild = GetNumGuilds()
  local first = 1
    
  for i=1, numGuild do
    local guildId = GetGuildId(i)
    local guildName = GetGuildName(guildId)
    
    local guildControl = control:GetNamedChild('Guild' .. i)            
    
    if(not guildControl) then
      controlName = control:GetName() .. "Guild" .. i
      guildControl = CreateControlFromVirtual(controlName, control, "ZO_CheckButton")
      
      if (first == 1) then
        guildControl:SetAnchor(LEFT, autokickControl, RIGHT, 80, 0)   
        first = 0     
      else
        local oldControl = control:GetNamedChild('Guild' .. i-1)
        
        guildControl:SetAnchor(LEFT, oldControl, RIGHT, 95, 0)  
      end
      
      _addon.SetCheckFunction(guildControl, data, guildName)
    end  
    
    if data[guildName] ~= nil then 
      _addon.SetCheckBox(guildControl, data[guildName])              
    else
      _addon.SetCheckBox(guildControl, 0)              
    end
  end
end
        
function ShissuPlayerObservation:Refresh()
  SHISSUPLAYEROBSERVATION:BuildMasterList()
  self:RefreshData()
end

function ShissuPlayerObservation:UnlockSelection()
  ZO_SortFilterList.UnlockSelection(self)
  self:RefreshVisible()
end

function ShissuPlayerObservation:OnEffectivelyHidden()
  ClearMenu()
end

function ShissuPlayerObservation:Refresh()
  self:RefreshData()
end
                                                                              
function ShissuPlayerObservation_OnInitialized(self)
  SHISSUPLAYEROBSERVATION = ShissuPlayerObservation:New(self)
end

function ShissuPlayerObservationRowName_OnMouseUp(self, button, upInside)
  if(button == 2) then
    local displayName = self:GetText()
    shissuPlayerObservation[_addon.selectCategory][displayName] = nil
    SHISSUPLAYEROBSERVATION:Refresh()       
  end
end

function _addon.onGuildEvent(eventCode, guildId, displayName)
  local guildName = GetGuildName(guildId) 
  
  if (eventCode == EVENT_GUILD_MEMBER_ADDED) then
    _addon.checkNewPlayer(guildId, guildName, displayName)
	end  
end

function _addon.kick(guildId, displayName)
  if (displayName ~= GetDisplayName()) then
    if (DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_MANAGE_BLACKLIST) == true) then
      --d("KICK: " ..displayName)
      AddToGuildBlacklistByDisplayName(guildId, displayName, "by " .. stdColor ..  "Shissu" .. "'s Blacklist")
    elseif (DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_REMOVE) == true) then
      GuildRemove(guildId, displayName)
    end
  end     
end

function _addon.checkNewPlayer(_, guildId, displayName)
  local guildName = GetGuildName(guildId)

  for categoryName, categoryData in pairs(shissuPlayerObservation) do  
    if categoryName ~= "color" then
      for name, nameData in pairs(categoryData) do  
        if (name == displayName) then
  
          if (nameData.autokick == 1 and nameData[guildName]) then
            d(string.format(_L("INGUILD", red, white, displayName, white, guildName)) .. L("KICK"))       
            _addon.kick(guildId, displayName)         
          elseif (nameData.observe == 1 and nameData[guildName]) then
            d(string.format(_L("INGUILD", red, white, displayName, white, guildName)))    
          end 
        end
      end
    end
  end
end

function _addon.checkAfterLogin()
  local nameList = {}
  local observeList = {}
  local kickList = {}
  
  for categoryName, categoryData in pairs(shissuPlayerObservation) do  
    if categoryName ~= "color" then
      for displayName, nameData in pairs(categoryData) do  
        nameList[displayName] = nameData  
      end
    end
  end   
  
  local numGuild = GetNumGuilds()
  
  for i=1, numGuild do
    local guildId = GetGuildId(i)
    local guildName = GetGuildName(guildId)
    local numMember = GetNumGuildMembers(guildId)
    
    observeList[guildName] = {}
    kickList[guildName] = {}
    
    for memberId = 1, numMember, 1 do
      local charData = { GetGuildMemberCharacterInfo(guildId, memberId) }
      local memberData = { GetGuildMemberInfo(guildId, memberId) }
      local displayName = memberData[1]  
      local charName = charData[2]          
      
      if nameList[displayName] ~= nil then
        if (nameList[displayName][guildName] == 1) then
          if (nameList[displayName].autokick == 1) then
            table.insert(kickList[guildName], displayName)
            _addon.kick(guildId, displayName)        
          elseif (nameList[displayName].observe == 1) then
            table.insert(observeList[guildName], displayName)
          end
        end
      elseif nameList[charName] ~= nil then
        if (nameList[displayName][guildName] == 1) then      
          if (nameList[charName].autokick == 1) then
            table.insert(kickList[guildName], charName)
            _addon.kick(guildId, displayName)
          elseif (nameList[charName].observe == 1) then
            table.insert(observeList[guildName], charName)
          end
        end     
      end     
    end
    
    local observeFound = ""
    local first = 1
    
    for y=1, #observeList[guildName] do
      if first == 1 then
        observeFound = observeList[guildName][y]
        first = 0
      else
        observeFound = observeFound .. ", " .. observeList[guildName][y]
      end
    end
    
    local kickFound = ""
    first = 1

    for y=1, #kickList[guildName] do
      if first == 1 then
        kickFound = kickList[guildName][y]
        first = 0
      else
        kickFound = kickFound .. ", " .. kickList[guildName][y]
      end
    end
    
    if (observeFound ~= "") then
      d(_L("INGUILD2") .. stdColor .. guildName .. white .. ": " ..  observeFound)
    end

    if (kickFound ~= "") then
      d(_L("KICKGUILD2") .. stdColor .. guildName .. white .. _L("KICK") .. ": " .. red ..  kickFound)
    end
  end
end

local TryShowingStandardInteractLabel = ZO_PlayerToPlayer:TryShowingStandardInteractLabel()

function ZO_PlayerToPlayer:TryShowingStandardInteractLabel()     
  local function GetPlatformIgnoredString()
    return IsConsoleUI() and SI_PLAYER_TO_PLAYER_TARGET_BLOCKED or SI_PLAYER_TO_PLAYER_TARGET_IGNORED
  end

  self.resurrectable = false
  self:SetTargetIdentification()

  local isIgnored = IsUnitIgnored(P2P_UNIT_TAG)
  local interactLabel = isIgnored and GetPlatformIgnoredString() or SI_PLAYER_TO_PLAYER_TARGET

  self.actionKeybindButton:SetHidden(false)
  self.targetLabel:SetText(zo_strformat(interactLabel, ZO_GetPrimaryPlayerNameWithSecondary(self.currentTargetDisplayName, self.currentTargetCharacterName)))
  self.actionKeybindButton:SetText(GetString(SI_PLAYER_TO_PLAYER_ACTION_MENU))
  
  if (shissuPlayerObservation["color"] ~= nil) then
    local found = 0
    local category = ""
    
    for categoryName, categoryData in pairs(shissuPlayerObservation) do
      if categoryName ~= "color" then
        for name, nameData in pairs(categoryData) do    
          local name = string.lower(name)
            
          if (name == string.lower(self.currentTargetDisplayName) or name == string.lower(self.currentTargetCharacterName)) then    
            found = 0
            category = categoryName

            if (shissuPlayerObservation["color"][category] ~= nil) then
              if (shissuPlayerObservation["color"][category].enabled == 1) then
                found = 1
              end
            end
          end
        end
      end
    end

    if (found == 1 ) then
      local _C = ShissuFramework["functions"]["datatypes"].RGBtoHex
        local color = shissuPlayerObservation["color"][category].color or stdColor
          
        if (color ~= stdColor) then
          color = _C{color[1], color[2], color[3]}
        end

        local newText = self.targetLabel:GetText()

         if ( category == "general" ) then 
          category = _L("GENERAL")
        end

        if (not string.find(newText, category, 1)) then                        
          self.targetLabel:SetText(newText .. "\n" .. white .. "(" .. red .. "!!! " .. color .. category .. red .. " !!!" .. white .. ")")   
        end
    end
  end

  return true
end
                 
-- * Initialisierung                                                                         
function _addon.initialized()
  local control = GetControl("ShissuPlayerObservation")
  SHISSUPLAYEROBSERVATION = ShissuPlayerObservation:New(control)

  SHISSUPLAYEROBSERVATION:BuildMasterList()
  SHISSUPLAYEROBSERVATION:Refresh()
  
  _addon.refreshCategory()
  _addon.categories:SetSelectedItem(stdColor .. "-- " .. white .. _L("GENERAL"))
  
  _addon.checkAfterLogin()  
                            
  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GUILD_MEMBER_ADDED, _addon.checkNewPlayer)               
end

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end

  shissuPlayerObservation = shissuPlayerObservation or {}

  zo_callLater(function()    
    if (shissuBlackList ~= nil) then
      shissuPlayerObservation = shissuBlackList
      shissuBlackList = {}
    end

    ShissuFramework.initAddon(_addon.Name, _addon.initialized)
  end, 150) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end
 
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)