-- Shissu Guild Tools Addon
-- ShissuContextMenu
--
-- Version: v1.3.0.5
-- Last Update: 28.11.2020
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!
 
local ZOS_ShowPlayerContextMenu = CHAT_SYSTEM.ShowPlayerContextMenu
local ZOS_MailInboxRow_OnMouseUp = ZO_MailInboxRow_OnMouseUp
local ZOS_GUILD_ROSTER_KEYBOARD = GUILD_ROSTER_KEYBOARD.GuildRosterRow_OnMouseUp

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local red = _globals["red"]

local splitToArray = ShissuFramework["functions"]["datatypes"].splitToArray
local setPanel = ShissuFramework["setPanel"]

local _addon = {}
_addon.Name	= "ShissuContextMenu"
_addon.Version = "1.3.0.5"
_addon.lastUpdate = "28.11.2020"
_addon.formattedName = stdColor .. "Shissu" .. white .. "'s Contextmenu"

local _L = ShissuFramework["func"]._L(_addon.Name)

_addon.settings = {
  guild = true,
  chatNewMail = true,
  chatInvite = true,
  mailAnswer = true,
  mailInvite = true,
}

local _personalNote = {}
                                                                                                      
_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version, _addon.lastUpdate)
_addon.controls = {}

function _addon.guildInvite(displayName)     
  for i = 1, GetNumGuilds() do
    local guildId = GetGuildId(i)
        
    if DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_INVITE) then
      local GuildName = GetGuildName(guildId)
      
      AddMenuItem(string.gsub(_L("INVITEC"), "%%1", GuildName), function() 
        GuildInvite(guildId, displayName) 

        -- Wenn das AddOn ShissuWelcome genutzt wird...
        if (shissuWelcome ~= nil) then
          if (shissuWelcome["invite"] ~= nil) then
            local allowInvite = shissuWelcome["invite"][GuildName]
                
            if allowInvite then 
              local currentText = CHAT_SYSTEM.textEntry:GetText()
      
              if string.len(currentText) < 1 then
                local welcomeString = shissuWelcome["message"][GuildName]
                
                  if welcomeString then
                    local chatMessageArray = splitToArray(welcomeString, "|")
                    local rnd = math.random(#chatMessageArray) 
                    local chatMessage = string.gsub(chatMessageArray[rnd], "%%1", displayName)
                    chatMessage = string.gsub(chatMessage, "%%2", GuildName)
      
                    local text = "/g" .. i .. " " .. chatMessage     
                    ZO_ChatWindowTextEntryEditBox:SetText(text)
                end
              end                 
            end
          end
        end       
      end)
    end 
  end
end

function _addon.setToBlacklist(displayName)
  for gId = 1, GetNumGuilds() do
    local guildId = GetGuildId(gId)
    local guildName = GetGuildName(guildId)

    if DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_MANAGE_BLACKLIST) then
      AddMenuItem(white .. ShissuFramework["functions"]["chat"].replacePlaceholder(_L("BLACKLIST"), {red, white, stdColor .. guildName}), function() 
        AddToGuildBlacklistByDisplayName(guildId, displayName, "")
      end)
    end
  end
end

function _addon.contextHead(previous)
  if (not previous) then previous = 1 end
  local func = function() end

  if (previous == 1) then AddMenuItem(" ", func, nil, "$(CHAT_FONT)|1|shadow") end
  AddMenuItem(stdColor .. "Shissu" .. white .. "'s " .. _L("ADDON"), func, nil, "$(ANTIQUE_FONT)|16")
  AddMenuItem(" ", func, nil, "$(CHAT_FONT)|1|shadow")
end

function _addon.chat()
  CHAT_SYSTEM.ShowPlayerContextMenu = function(self, displayName, rawName)
    ZOS_ShowPlayerContextMenu(self, displayName, rawName)
  
    if shissuContextMenu["chatNewMail"] or shissuContextMenu["chatInvite"] then _addon.contextHead() end
    
    if shissuContextMenu["chatNewMail"] then  

      AddMenuItem(white .. _L("NEWMAIL"), function() 
        SCENE_MANAGER:Show('mailSend') ZO_MailSendToField:SetText(displayName) 
      end)       
    end
    
    if shissuContextMenu["chatInvite"] then _addon.guildInvite(displayName) end  
    _addon.setToBlacklist(displayName)
    
    if ZO_Menu_GetNumMenuItems() > 0 then ShowMenu() end
  end
end

-- KONTEXTMENÜ: E-Mail Fenster (Empfangen)
function _addon.MailOnMouseUp(control, button)
  ClearMenu()
  ZOS_MailInboxRow_OnMouseUp(control, button)

  if (button ~= 2) then return end
  if (shissuContextMenu["mailAnswer"] or shissuContextMenu["mailInvite"]) then
    _addon.contextHead(0)
  end
  
  if shissuContextMenu["mailAnswer"] then        
    AddMenuItem(white .. _L("NEWMAIL"), function() SCENE_MANAGER:Show('mailSend') ZO_MailSendToField:SetText(GetMailSender(control.dataEntry.data.mailId)) end)         
    AddMenuItem(white .. _L("ANSWER2"), function() 
      SCENE_MANAGER:Show('mailSend') 
      ZO_MailSendToField:SetText(GetMailSender(control.dataEntry.data.mailId)) 
      ZO_MailSendSubjectField:SetText(_L("ANSWER_PREFIX") .. ": " .. control.dataEntry.data.subject) 
    end) 
        
    AddMenuItem(white .. _L("FORWARD"), function() 
      SCENE_MANAGER:Show('mailSend') 
      ZO_MailSendSubjectField:SetText(_L("FORWARD_PREFIX") .. ": " .. control.dataEntry.data.subject) 
      ZO_MailSendBodyField:SetText(ZO_MailInboxMessageBody:GetText()) 
    end)    
    
    AddMenuItem(white .. _L("DEL"), function() 
      DeleteMail(control.dataEntry.data.mailId, control.dataEntry.data.confirmedDelete)
      MAIL_INBOX:RefreshData()
    end)    
  end
  
  if shissuContextMenu["mailInvite"] then 
    _addon.guildInvite(GetMailSender(control.dataEntry.data.mailId)) 
  end 
  
  ShowMenu()
end

-- KONTEXTMENÜ: Gildenroster
-- Original ZOS Code + SGT Code: esoui\ingame\guild\keyboard\guildroster_keyboard.lua
-- Original Version Date: 01.09.2015
function _addon.GuildRosterRow_OnMouseUp(self, control, button, upInside)
  local data = ZO_ScrollList_GetData(control)
  
  data.characterName = string.gsub(data.characterName, white, "")
  ZOS_GUILD_ROSTER_KEYBOARD(self, control, button, upInside)

  if (button ~= MOUSE_BUTTON_INDEX_RIGHT --[[and not upInside]]) then return end
  
  if data then 
    if (shissuRoster) then
      if (shissuRoster["colNote"]) or shissuContextMenu["guild"] then
        _addon.contextHead(1, self:ShowMenu(control))
      end
    elseif shissuContextMenu["guild"] then
      _addon.contextHead(1, self:ShowMenu(control))

      
    end

    if shissuContextMenu["guild"] then
      _addon.guildInvite(data.displayName) 

      _addon.setToBlacklist(data.displayName)
    end
    
    -- Persönliche Notizen
    _addon.persNote(data)

    self:ShowMenu(control)
  end
end

-- Persönliche Notizen
function _addon.checkGuildRosterVars(guildId, displayName)
  if shissuRoster["PersonalNote"] == nil then
    shissuRoster["PersonalNote"] = {}
  end

  if shissuRoster["PersonalNote"][guildId] == nil then 
    shissuRoster["PersonalNote"][guildId] = {}
  end

  if (displayName ~= nil) then
    if shissuRoster["PersonalNote"][guildId][displayName] ~= nil then 
      shissuRoster["PersonalNote"][guildId][displayName] = {} 
    end
  end
end

function _addon.persNote(data)
  if (shissuRoster) then
      if (shissuRoster["colNote"]) then
        AddMenuItem(white .. _L("NOTE"), function(self) 
          zo_callLater(function()
            local guildId = GUILD_ROSTER_MANAGER:GetGuildId()
            local notes = ""
            local displayName = data.displayName
            
            _addon.checkGuildRosterVars(guildId)
                          
            if shissuRoster["PersonalNote"][guildId][displayName] == nil then 
              notes = ""
            else
              notes = shissuRoster["PersonalNote"][guildId][displayName]
            end     
       
            ZO_Dialogs_ShowDialog("EDIT_NOTE", {displayName = data.displayName, note = notes, changedCallback = _addon.personalNoteChange})
          end, 50)
        end)
      end
    end
end

function _addon.personalNoteChange(displayName, note)
  local guildId = GUILD_ROSTER_MANAGER:GetGuildId()
   
  if guildId == nil then return false end
  if displayName == nil then return false end
  
  -- Variablen erstellen, falls nicht vorhanden, und danach abspeichern
  _addon.checkGuildRosterVars(guildId, displayName)

  if string.len(note) == 1 and note ~= " " then 
    note = " " .. note
  end
  
  shissuRoster["PersonalNote"][guildId][displayName] = note
  --d(note)

  GUILD_ROSTER_MANAGER:RefreshData()     
end
    
function _addon.createSettingMenu()
  local controls = _addon.controls 
  
  controls[#controls+1] = {
    type = "title",
    name = "Chat",
  }
   
  controls[#controls+1] = {
    type = "checkbox",                                                                            
    name = _L("NEWMAIL"),
    getFunc = shissuContextMenu["chatNewMail"],
    setFunc = function(_, value)     
      shissuContextMenu["chatNewMail"] = value
      _addon.chat()
    end,
  }

  controls[#controls+1] = {
    type = "checkbox",                                                                            
    name = _L("INVITE"),
    getFunc = shissuContextMenu["chatInvite"],
    setFunc = function(_, value)
      shissuContextMenu["chatInvite"] = value
      _addon.chat()
    end,
  }

  controls[#controls+1] = {
    type = "title",
    name = _L("MAIL"),
  }

  controls[#controls+1] = {
    type = "checkbox",                                                                            
    name = _L("ANSWER"),
    getFunc = shissuContextMenu["mailAnswer"],
    setFunc = function(_, value)
      shissuContextMenu["mailAnswer"] = value
      ZO_MailInboxRow_OnMouseUp = _addon.MailOnMouseUp
    end,
  }
  
  controls[#controls+1] = {
    type = "checkbox",                                                                            
    name = _L("INVITE"),
    getFunc = shissuContextMenu["mailInvite"],
    setFunc = function(_, value)
      shissuContextMenu["mailInvite"] = value
      ZO_MailInboxRow_OnMouseUp = _addon.MailOnMouseUp
    end,
  }

  controls[#controls+1] = {
    type = "title",
    name = GetString(SI_GAMEPAD_HOUSING_PERMISSIONS_SEARCH_GUILD),
  }

  controls[#controls+1] = {
    type = "checkbox",                                                                            
    name = _L("INVITE"),
    getFunc = shissuContextMenu["guild"],
    setFunc = function(_, value)
      shissuContextMenu["guild"] = value
      GUILD_ROSTER_KEYBOARD.GuildRosterRow_OnMouseUp = _addon.GuildRosterRow_OnMouseUp 
    end,
  }
end

function _addon.createGuildVars(saveVar, value)
  if shissuContextMenu[saveVar] == nil then shissuContextMenu[saveVar] = {} end
  
  if shissuContextMenu[saveVar] ~= nil then  
    local numGuild = GetNumGuilds()
    
    for guildId=1, numGuild do
      local guildId = GetGuildId(guildId)
      local guildName = GetGuildName(GetGuildId(guildId))  
      
      if shissuContextMenu[saveVar][guildName] == nil then shissuContextMenu[saveVar][guildName] = value end
    end
  end
end 

function _addon.initialized()
  shissuContextMenu = shissuContextMenu or {}
  if shissuContextMenu["guild"] == nil then shissuContextMenu = _addon.settings end 

  _addon.createSettingMenu()

  if (shissuRoster ~= nil) then
    if (shissuRoster["PersonalNote"] ~= nil) then
      _personalNote = shissuRoster["PersonalNote"]
    end
  end

  if shissuContextMenu["chatNewMail"] or shissuContextMenu["chatInvite"] then 
    _addon.chat() 
  end

  if (shissuContextMenu["mailAnswer"] or shissuContextMenu["mailInvite"]) then 
    ZO_MailInboxRow_OnMouseUp = _addon.MailOnMouseUp
  end

  GUILD_ROSTER_KEYBOARD.GuildRosterRow_OnMouseUp = _addon.GuildRosterRow_OnMouseUp              
end

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end
  
  zo_callLater(function()              
    ShissuFramework._settings[_addon.Name] = {}
    ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
    ShissuFramework._settings[_addon.Name].controls = _addon.controls  

    ShissuFramework.initAddon(_addon.Name, _addon.initialized)
  end, 150) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end    

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)