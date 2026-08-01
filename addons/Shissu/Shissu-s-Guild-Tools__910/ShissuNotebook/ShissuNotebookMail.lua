-- Shissu Guild Tools Addon
-- ShissuNotebookMail
--
-- Version: v2.5.5.1
-- Last Update: 28.11.2020
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local orange = _globals["orange"]
local green = _globals["green"]
local yellow = _globals["yellow"]
local red = _globals["red"]

local setDefaultColor = ShissuFramework["interface"].setDefaultColor
local checkBoxLabel = ShissuFramework["interface"].checkBoxLabel
local createFlatWindow = ShissuFramework["interface"].createFlatWindow
local createLine = ShissuFramework["interface"].createLine
local createFlatButton = ShissuFramework["interface"].createFlatButton
local createBackdropBackground = ShissuFramework["interface"].createBackdropBackground

local createScrollContainer = ShissuFramework["interface"].createScrollContainer
local getWindowPosition = ShissuFramework["interface"].getWindowPosition
local saveWindowPosition = ShissuFramework["interface"].saveWindowPosition

local showDialog = function(dialogTitle, dialogText, callbackFunc, vars)
  ESO_Dialogs["SGT_DIALOG"].title = {text = dialogTitle,}
  ESO_Dialogs["SGT_DIALOG"].mainText = {text = dialogText,}
  ESO_Dialogs["SGT_DIALOG"].buttons[1].callback = callbackFunc

  ZO_Dialogs_ShowDialog("SGT_DIALOG", vars)
end

local _addon = {}
_addon.Name	= "ShissuNotebookMail"
_addon.Version = "2.5.5.1"
_addon.lastUpdate = "28/11/2020"
_addon.formattedName = stdColor .. "Shissu" .. white .. "'s Notebook"

local _L = ShissuFramework["func"]._L(_addon.Name)

_addon.friends = "--|r " .. white .. _L("FRIENDS") 

local _mail = {}
_mail.cache = {}
_mail.dropDownGuilds = nil
_mail.dropDownRanks = nil
_mail.offlineSince = 0
_mail.currentGuild = 1
_mail.currentRank = 0
_mail.guildList = {}
_mail.currentList = {}
_mail.scrollItem = 1
_mail.indexPool = nil
_mail.list = nil
_mail.protocolFullIndexPool = nil
_mail.protocolIgnoreIndexPool = nil
_mail.isSend = false
_mail.isOpen = false
_mail.kick = nil
_mail.all = nil
_mail.clickChoice = nil
_mail.clickIndex = nil
_mail.recipientName = ""
_mail.gold = 0
_mail.goldDate = nil
_mail.inviteDate = nil
_mail.memberSince = 0
_mail.gold = 0
_mail.goldSince = 0

local _checkBox = {}

local _direction = {
  ["offlineSince"] = true,
  ["memberSince"] = true,
  ["gold"] = true,
}


_mail.Item = {
  Full = 1,
  Ignore = 1,
}

_mail.ProtocolList = {
  Full = nil,
  Ignore = nil,
}    

_mail.emailError = {
   full = {},
   ignore = {},
}    

function _mail.removeIndexButton(control)
  control:SetHidden(true)
  control = nil
end

function _mail.getGuildNote(memberId)
  local memberVar = {GetGuildMemberInfo(_mail.currentGuild, memberId)}
  
  if memberVar then
    return memberVar[2]
  end
  
  return false
end

function _mail.createIndexButton(indexPool)
  local control = ZO_ObjectPool_CreateControl("SGT_Notebook_MailIndex", indexPool, _mail.list.scrollChild)
  local anchorBtn = _mail.scrollItem == 1 and _mail.list.scrollChild or indexPool:AcquireObject(_mail.scrollItem-1)
  
  control:SetAnchor(TOPLEFT, anchorBtn, _mail.scrollItem == 1 and TOPLEFT or BOTTOMLEFT)
  control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  control:SetWidth(140)
  control:SetHandler("OnMouseUp", function(self, button)
    if button == 2 then
      if _mail.guildList[self.index][2] == false then
        _mail.guildList[self.index] = {self.name, true} 
        control:SetText(red .. self.name)
      elseif _mail.guildList[self.index][2] == true then
        _mail.guildList[self.index] = {self.name, false}
        control:SetText(white .. self.name)
      else
        _mail.guildList[self.index] = {self.name, true}
        control:SetText(red .. self.name)
      end
    else
      SGT_Notebook_MessagesRecipient_Choice2:SetText(self.name)
      _mail.clickChoice = self.name
      _mail.clickIndex = self.index
    end
  end)
  
  control:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end) 
  control:SetHandler("OnMouseEnter", function(self) 
    if _mail.getGuildNote(self.id) and _mail.getGuildNote(self.id) ~= "" then
      ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, white .. _mail.getGuildNote(self.id)) 
    end
  end)

  _mail.scrollItem = _mail.scrollItem  + 1
  
  return control
end

function _mail.manuellMailList()
  SGT_Notebook_MessagesRecipient_Add:SetHidden(false)
  SGT_Notebook_MessagesRecipient_Delete:SetHidden(false)   
  SGT_Notebook_MessagesRecipient_BuildGroup:SetHidden(false)          
end

function _mail.autoMailList()
  SGT_Notebook_MessagesRecipient_Add:SetHidden(true)
  SGT_Notebook_MessagesRecipient_Delete:SetHidden(true)
  SGT_Notebook_MessagesRecipient_BuildGroup:SetHidden(true)            
end

function _addon.getFriendsList()
  local searchTerm = SGT_Notebook_MessagesRecipient_FilterText:GetText()  or ""
  local numFriends = GetNumFriends() 
  local availableNames = {}
  
  for i = 1, numFriends do
    local displayName, _ = GetFriendInfo(i)  

    if (searchTerm == "" or string.find(displayName, searchTerm)) then        
      table.insert(availableNames, { displayName, false} )
    end
  end
  
  return availableNames   
end

function _addon.getHistoryInfo(guildName, name)
  local history = shissuHistoryScanner
  local historyData = {}
  local member = true
  local gold = true
  
  if history then
    if history[guildName] then
      if history[guildName][name] then
        local timeJoined = history[guildName][name].timeJoined
        local day = 0
        
        if (timeJoined == nil) then
          -- Was passiert, wenn Spieler schon so lange in der Gilde ist, das keine Aufzeichnungen existieren?
          -- Aufzeichnungen existieren ~ etwa 10 Monate zurück, max
          day = 40 * 7 * 86400  
        else
          timeJoined = GetTimeStamp() - timeJoined 
          day = math.floor(timeJoined / 86400)             
        end
            
        if ((day >= _mail.memberSince) == false and _direction["memberSince"]) or ((day <= _mail.memberSince) == false and _direction["memberSince"] == false) then   
          member = false
        else
          member = true
        end                
        
        
        -- NEUNEU
        if history[guildName][name][GUILD_EVENT_BANKGOLD_ADDED] then
        local lastGold = history[guildName][name][GUILD_EVENT_BANKGOLD_ADDED].last or 0
        local timeLast = history[guildName][name][GUILD_EVENT_BANKGOLD_ADDED].timeLast or 0 
        else
        local lastGold =  0
        local timeLast = 0         
        end

        --if (name == "@Splatadude") then
        --  d(name .. " - " .. lastGold .. " - " .. timeLast .. " - " .. _mail.gold)
        --    d(_mail.goldSince)
        --end

        if (lastGold and timeLast) then
          if (((lastGold >= _mail.gold) == false) and _direction["gold"]) or (((lastGold <= _mail.gold) == false) and (_direction["gold"] == false)) then
            gold = false
          end
          
          if _mail.goldSince > 0 then
            timeLast = GetTimeStamp() - timeLast 
            timeLast = math.floor(timeLast / 86400)  
             
            if (timeLast >= _mail.goldSince) then
              gold = false
            end
          end        
        end    
      end
    end
  end    

  table.insert(historyData, member)
  table.insert(historyData, gold)
  
  return historyData
end

function _addon.getGuildList()
  local numMembers = GetNumGuildMembers(_mail.currentGuild)
  local availableNames = {}
  local sortedMembers = {}
  local sortedData = {}
  local searchTerm = SGT_Notebook_MessagesRecipient_FilterText:GetText()  or ""

  for i = 1, numMembers do
    local memberVar = {GetGuildMemberInfo(_mail.currentGuild, i)}
    table.insert(sortedMembers, i, memberVar[1] .. "**shissu" ..i)
  end
  
  table.sort(sortedMembers)
  
  for i = 1, numMembers do
    local length = string.len(sortedMembers[i])
    local number = string.sub(sortedMembers[i], string.find(sortedMembers[i], "**shissu"), length)
    
    number = string.gsub(number, "**shissu", "")
    number = string.gsub(number, " ", "")
    number = tonumber(number)
   
    local memberVar = {GetGuildMemberInfo(_mail.currentGuild, number)}
   
    sortedData[i] = {}
    sortedData[i].name = memberVar[1]
    sortedData[i].id = number
  end
  
  for i = 1, #sortedData do
    local memberVar = {GetGuildMemberInfo(_mail.currentGuild, sortedData[i].id)}
    local charVar = {GetGuildMemberCharacterInfo(_mail.currentGuild, sortedData[i].id)}  
    local memberOfflineSince = math.floor(memberVar[5] / 86400)

    local guildName = GetGuildName(_mail.currentGuild)

    if (_checkBox["aldmeri"].value and charVar[5] == 1) 
      or (_checkBox["ebonheart"].value and charVar[5] == 2) 
      or (_checkBox["daggerfall"].value and charVar[5] == 3) then 

      if (_checkBox["online"].value and (memberVar[4] == 1 or memberVar[4] == 2 or memberVar[4] == 3)) 
        or (_checkBox["offline"].value and (memberVar[4] == 4)) then 
          
      --  d(memberVar[3] .. " - " .. _mail.currentRank)

        if _mail.currentRank == 0 and memberOfflineSince >= _mail.offlineSince
          or memberVar[3] == _mail.currentRank and memberOfflineSince >= _mail.offlineSince then  
          if (searchTerm == "" or string.find(sortedData[i].name, searchTerm) or string.find(memberVar[2], searchTerm)) then 

            local historyData = _addon.getHistoryInfo(guildName, sortedData[i].name)
            
            if historyData[1] == true and historyData[2] == true then
              table.insert(availableNames, { sortedData[i].name, false, sortedData[i].id} )
            end
          end
        end
      end
    end                              
  end
  
  return availableNames
end

-- Liste füllen
function _mail.fillScrollList()
  local searchTerm = SGT_Notebook_MessagesRecipient_FilterText:GetText()  or ""
  local done = 0
  
  _mail.guildList = {}

  -- Freunde
  if _mail.currentDropText == yellow .. "--|r " .. white .. _L("FRIENDS") and done == 0 then
    _mail.autoMailList()
    _mail.guildList = _addon.getFriendsList()    

    done = 1
  end
  
  -- Eigene Liste 
  if (shissuNotebook["mailList"] ~= nil) then
    for listName, listContent in pairs(shissuNotebook["mailList"]) do
    --d(ShissuGT.Color[6] .. "--|r " .. ShissuGT.Color[5] .. listName .. "         -    " .. _mail.currentDropText) 
    if stdColor .. "--|r " .. white .. listName == _mail.currentDropText and done == 0 then
      _mail.manuellMailList()
      
      _mail.currentList = listName
      numMembers = #shissuNotebook["mailList"][listName]    
      local availableNames = {}
      
      for i = 1, numMembers do
        local displayName, _ = shissuNotebook["mailList"][listName][i]
        table.insert(_mail.guildList, {shissuNotebook["mailList"][listName][i], false})
      end
      
      done = 1      
    end
  end
   end 
  -- Gilde
  if done == 0 then
    _mail.autoMailList()
    _mail.guildList = _addon.getGuildList()             
  end     
  
  local numMembers = #_mail.guildList 
  
  for i = 1, numMembers do
    local control = _mail.indexPool:AcquireObject(i)
      
    control.name = _mail.guildList[i][1]
    control.id = i
    control.index = i
    control:SetText(white .. _mail.guildList[i][1])
    
    if _mail.guildList[i][3] then
      control.memberId = _mail.guildList[i][3]
    end
    
    control:SetHidden(false)      
  end  

  local activePages = _mail.indexPool:GetActiveObjectCount()
  if activePages > numMembers then
    for i = numMembers+1, activePages do _mail.indexPool:ReleaseObject(i) end
  end
end

function _mail.ProtocolFillScrollList()
  local numFull = #_mail.emailError.full
  local numIgnore = #_mail.emailError.ignore
      
  for i = 1, numFull do
    local control = _mail.protocolFullIndexPool:AcquireObject(i)
    control:SetText(white .. _mail.emailError.full[i])
    control:SetHidden(false)      
  end                                                                               

  local activePages = _mail.protocolFullIndexPool:GetActiveObjectCount()
  if activePages > numFull then
    for i = numFull+1, activePages do _mail.protocolFullIndexPool:ReleaseObject(i) end
  end 
  
  for i = 1, numIgnore do
    local control = _mail.protocolIgnoreIndexPool:AcquireObject(i)
    control:SetText(white .. _mail.emailError.ignore[i])
    control:SetHidden(false)      
  end                                                                               

  local activePages = _mail.protocolIgnoreIndexPool:GetActiveObjectCount()
  if activePages > numIgnore then
    for i = numIgnore+1, activePages do _mail.protocolIgnoreIndexPool:ReleaseObject(i) end
  end                
end


function _mail.GetOfflineDays(offlineString)
  local stringStart = stdColor
  local endString = white .. " " .. _L("DAYS")
  local days = "0"
  
  if string.len(offlineString) > 3 then
    days = string.gsub(string.gsub(offlineString, stringStart, ""), endString, "")   
    days = tonumber(days)
  else
    days = tonumber(offlineString)
  end
  
  return days
end

function _mail.checkBox(control, var)  
  ZO_CheckButton_SetToggleFunction(control, function(control, checked)
    _mail.RecipientChoice[var] = checked
    _mail.fillScrollList()
  end)
end

function _mail.mailButtons(all, kick)
  local sleepTime = 3100
  local guildId = _mail.currentGuild                      
  local recipient = {}
  local i = 1
  local waitCount = 0
  
  -- aktueller Titel (Betreff) + Text zwischenspeichern, damit aktiv weitergearbeitet werden kann im Notizbuch
  _mail.cache.title = SGT_Notebook_NoteTitleText:GetText()
  _mail.cache.text = SGT_Notebook_NoteText:GetText()
 
  if all == 1 then
    for i = 1, #_mail.guildList do
      if _mail.guildList[i][2] == false then
        table.insert(recipient, _mail.guildList[i][1])
      end
    end
  else
    table.insert(recipient, SGT_Notebook_MessagesRecipient_Choice2:GetText()) 
  end
  
  if all == 3 and kick == 3 then
    all = _mail.all
    kick = _mail.kick
  else
    _mail.kick = all
    _mail.all = kick
  end         
  
  if _checkBox["kick"].value == true then sleepTime = 2500 end
  if _checkBox["demote"].value == true then sleepTime = 2500 end
  
  _mail.isSend = true
  if _mail.isOpen == false then RequestOpenMailbox() end 
                      
  SGT_Notebook_MessagesRecipient_Choice:SetText(_L("SEND"))
  
  -- Splash Screen Text  
  SGT_Notebook_Splash_Subject:SetText(_mail.cache.title) 

  SGT_Notebook_Splash_Subject:SetHandler("OnMouseEnter", function(self)
    ZO_Tooltips_ShowTextTooltip(SGT_Notebook_Splash_Subject, TOPRIGHT, _mail.cache.text)
  end)
  
  SGT_Notebook_Splash_Subject:SetHandler("OnMouseExit", function(self)
    ZO_Tooltips_HideTextTooltip()
  end)   
                      
  if _checkBox["kick"].value == true and kick == 1 and not kick == 3 then
    SGT_Notebook_Splash_Title:SetText("E-Mail Kick")
  elseif kick == 1 and not kick == 3  then 
    if _checkBox["kick"].value == true then
      SGT_Notebook_Splash_Title:SetText(_L("PROGRESS_KICK"))
    elseif _checkBox["demote"].value == true then
      SGT_Notebook_Splash_Title:SetText(_L("PROGRESS_DEMOTE"))
    end
  elseif not kick == 3 then
    SGT_Notebook_Splash_Title:SetText(_L("PROGRESS_SEND"))
  end                      
  
  SGT_Notebook_Splash:SetHidden(false)  
  SGT_Notebook:SetHidden(true)
  SGT_Notebook_MessagesRecipient:SetHidden(true)
  
  EVENT_MANAGER:RegisterForUpdate("SGT_EVENT_EMAIL", sleepTime, function()    
    if _checkBox["noMail"].value == false or kick == 0 then
      if _mail.emailIsOpen == false then RequestOpenMailbox() end 
      
      if recipient[i] ~= nil then
        if _mail.emailIsOpen == true and _mail.isSend == true then
          _mail.recipientName = recipient[i]
          SGT_Notebook_Splash_Recipient:SetText(stdColor.. recipient[i])
          
          if waitCount == 0 then 
            SGT_Notebook_Splash_Waiting:SetText(red .. _L("PROGRESS_WAITING")) 
            waitCount = 1
          else
            SGT_Notebook_Splash_Waiting:SetText(white .. _L("PROGRESS_WAITING")) 
            waitCount = 0
          end
          
          QueueMoneyAttachment(0)
          SendMail(recipient[i], _mail.cache.title, _mail.cache.text)  
          
          if kick == 1 then 
            if _checkBox["kick"].value == true then
              GuildRemove(guildId, recipient[i]) 
            elseif _checkBox["demote"].value == true  then
              GuildDemote(guildId, recipient[i])
            end
          end
                            
          i = i + 1
          _mail.isSend = false
        end
      end
    else
      if kick == 1 then 
        SGT_Notebook_Splash_Recipient:SetText(stdColor.. recipient[i]) 
        if _checkBox["kick"].value == true  then
          GuildRemove(guildId, recipient[i]) 
        elseif _checkBox["demote"].value == true  then                 
          GuildDemote(guildId, recipient[i])
        end
      end
      i = i + 1
    end

    -- Splash Screen    
    if i == #_mail.guildList+1 or all == 0 then
      SGT_Notebook_MessagesRecipient_Choice:SetText(stdColor .. _L("PROGRESS_DONE"))
      SGT_Notebook_Splash_Progress:SetText(green .. _L("PROGRESS_DONE"))
      SGT_Notebook_Splash_Waiting:SetText("")

      EVENT_MANAGER:UnregisterForUpdate("SGT_EVENT_EMAIL")    
      _mail.ProtocolFillScrollList()
    else
      SGT_Notebook_MessagesRecipient_Choice:SetText(stdColor .. i .. "/" .. white .. #recipient)
      SGT_Notebook_Splash_Progress:SetText(stdColor .. i .. "/" .. white .. #recipient)
    end
  end)
end

_mail.currentDropText = ""

-- Ränge
function _mail.rankSelected(_, statusText, choiceNumber)
  local guildId = _mail.currentGuild

  statusText = string.gsub(statusText, white, "")

  for rankId = 1, GetNumGuildRanks(guildId) do
    if (statusText == GetFinalGuildRankName(guildId, rankId)) then 
      SGT_Notebook_MessagesRecipient_Choice2:SetText(orange .. statusText)
      _mail.currentRank = rankId 
      break 
    else
      _mail.currentRank = 0
    end
  end 
  
  _mail.fillScrollList()  
end

function _mail.optionSelected(_, statusText, g)
  _mail.currentDropText = statusText

  for guildId = 1, GetNumGuilds() do
	guildId = GetGuildId(guildId)
    if GetGuildName(guildId) == statusText then
      SGT_Notebook_MessagesRecipient_Choice:SetText(red .. statusText)
      _mail.currentGuild = guildId
      
      _mail.dropDownRanks:ClearItems()
      _mail.dropDownRanks:AddItem(_mail.dropDownRanks:CreateItemEntry(yellow .. "-- " .. white .. _L("ALL"), _mail.rankSelected))

      for rankId = 1, GetNumGuildRanks(guildId) do
        _mail.dropDownRanks:AddItem(_mail.dropDownRanks:CreateItemEntry(GetFinalGuildRankName(guildId, rankId), _mail.rankSelected))
      end

      break
    end   
  end

  _mail.fillScrollList()
end

function _mail.mailAbort()  
  EVENT_MANAGER:UnregisterForUpdate("SGT_EVENT_EMAIL") 
  SGT_Notebook_MessagesRecipient_Choice:SetText(red .. _L("PROGRESS_DONE"))
  
  SGT_Notebook_Splash:SetHidden(true)  
end

function _mail.mailContinue()
   _mail.mailButtons(3, 3)
end

function _mail.mailProtocol()
  if SGT_MailProtocol:IsHidden() then
    SGT_MailProtocol:SetHidden(false)
    _mail.ProtocolFillScrollList()
  else
    SGT_MailProtocol:SetHidden(true)
  end  
end

function _mail.addPlayerToList(self, button)
  if button ~= 1 then return end
    ESO_Dialogs["SGT_EDIT"].title = {text = _L("PLAYER_ADD"),}
    ESO_Dialogs["SGT_EDIT"].mainText = {text = "Name?",}      
    ESO_Dialogs["SGT_EDIT"].buttons[1].callback = function(dialog) 
      local playerName = dialog:GetNamedChild("EditBox"):GetText()

      if playerName ~= nil or playerName ~= "" or playerName ~= " " then
        local guildSign = string.sub(playerName,1,1) 
        local guildId = string.sub(playerName,2,2) 

        if guildSign == "%" then
          guildId = GetGuildId(guildId)
          
          if guildId ~= 0 then
            for memberId=1, GetNumGuildMembers(guildId), 1 do
              local memberInfo = { GetGuildMemberInfo(guildId, memberId) }
              local found = 0
              
              for nameId = 1, #shissuNotebook["mailList"][_mail.currentList] do
                if shissuNotebook["mailList"][_mail.currentList][nameId] == memberInfo[1] then
                  found = 1
                end
              end

              if found == 0 then
                table.insert(shissuNotebook["mailList"][_mail.currentList], memberInfo[1]) 
              end 
            
            end
          end
        else
          table.insert(shissuNotebook["mailList"][_mail.currentList], playerName)        
        end
        
        _mail.fillScrollList()
      end
    end

    ZO_Dialogs_ShowDialog("SGT_EDIT")
end

function _mail.deletePlayerfromList(self, button)
  if button ~= 1 then return end
  
  local numPlayer = #shissuNotebook["mailList"][_mail.currentList]

  for i = 1, numPlayer do
    --d(shissuNotebook["mailList"][_mail.currentList][i] .. "       -  "  .. _mail.clickChoice)
    
    if shissuNotebook["mailList"][_mail.currentList][i] == _mail.clickChoice then
      --d("del")
      shissuNotebook["mailList"][_mail.currentList][i] = nil
      _mail.fillScrollList()
      return
    end
  end
end

function _mail.buildGroupWithList()
  for i = 1, #_mail.guildList do
    if _mail.guildList[i][2] == false then
      d(stdColor .. _L("PLAYER_INVITE") .." - " .. white .. _mail.guildList[i][1])
      GroupInviteByName(_mail.guildList[i][1])
    end
  end
end

function _mail.buildMailList()
  _mail.dropDownGuilds:ClearItems()
  _mail.dropDownGuilds:AddItem(_mail.dropDownGuilds:CreateItemEntry(yellow .. "--|r " .. white .. _L("FRIENDS"), _mail.optionSelected))
  
  if (shissuNotebook["mailList"] ~= nil) then
    for listName, listContent in pairs(shissuNotebook["mailList"]) do
      if listContent ~= nil then
        _mail.dropDownGuilds:AddItem(_mail.dropDownGuilds:CreateItemEntry(stdColor .. "--|r " .. white .. listName, _mail.optionSelected))
      end
    end
  end
  
  for guildId = 1, GetNumGuilds() do
    local gId = GetGuildId(guildId)
    _mail.dropDownGuilds:AddItem(_mail.dropDownGuilds:CreateItemEntry(GetGuildName(gId), _mail.optionSelected))

    if (gId == 1) then
      _mail.dropDownGuilds:SetSelectedItem()
      SGT_Notebook_MessagesRecipient_GuildsDropdownSelectedItemText:SetText(GetGuildName(GetGuildId(guildId)))
      SGT_Notebook_MessagesRecipient_Choice:SetText(red .. GetGuildName(guildId))
    end
  end
end

function _mail.protocolCreateIndexButton(indexPool)
  local var = "Full"
  
  if indexPool == _mail.protocolIgnoreIndexPool then var = "Ignore" end

  local control = ZO_ObjectPool_CreateControl("SGT_Notebook_MailProtocol" .. var .. "Index", indexPool, _mail.ProtocolList[var].scrollChild)
  local anchorBtn = _mail.Item[var] == 1 and _mail.ProtocolList[var].scrollChild or indexPool:AcquireObject(_mail.Item[var]-1)
  
  control:SetAnchor(TOPLEFT, anchorBtn, _mail.Item[var] == 1 and TOPLEFT or BOTTOMLEFT)
  control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  control:SetWidth(140)

  _mail.Item[var] = _mail.Item[var] + 1
  
  return control
end

function _addon.newList(self, button)
  if button == 1 then
    local listName = nil

    ESO_Dialogs["SGT_EDIT"].title = {text = _L("LIST_NEW"),}
    ESO_Dialogs["SGT_EDIT"].mainText = {text = _L("LIST_NAME"),}      
    ESO_Dialogs["SGT_EDIT"].buttons[1].callback = function(dialog) 
      listName = dialog:GetNamedChild("EditBox"):GetText()

      if listName ~= nil or listName ~= "" or listName ~= " " then
        _mail.dropDownGuilds:AddItem(_mail.dropDownGuilds:CreateItemEntry(stdColor .. "--|r " .. white .. listName, _mail.optionSelected))
        if (shissuNotebook["mailList"] == nil) then shissuNotebook["mailList"] = {} end
        if shissuNotebook["mailList"][listName] == nil then shissuNotebook["mailList"][listName] = {} end        
      end
    end

    ZO_Dialogs_ShowDialog("SGT_EDIT")
  else
    shissuNotebook["mailList"][_mail.currentList] = nil
    _mail.buildMailList()
  end
end
  
function _addon.createFlatCheckBox(name, parent, parentPos, parentAnchor, callBackFunc, label, color, checked)
  if parentAnchor == nil then parentAnchor = BOTTOMLEFT end 

  if color == nil then color = {0.49019607901573, 0.74117648601532, 1, 1} end
  
  local control = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
  control:SetAnchor(parentAnchor, parent, parentAnchor, parentPos[1], parentPos[2])
  control:SetDimensions(16, 16)
  control:SetTexture("ShissuFramework/textures/checkbox1.dds")
  control:SetHidden(false)
  control:SetMouseEnabled(true)
  control:SetDrawLayer(1)
  
  control:SetHandler("OnMouseEnter", function(self) 
    self:SetColor(color[1], color[2], color[3], color[4] or 1)   
  end) 
  
  control:SetHandler("OnMouseExit", function(self) 
    self:SetColor(1, 1, 1, 1)   
  end) 


  control.value = false
  
  if (checked) then
    control.value = true
    control:SetTexture("ShissuFramework/textures/checkbox4.dds")
  end
  
  control:SetHandler("OnMouseUp", function(self) 
    if (self.value == false) then
      control:SetTexture("ShissuFramework/textures/checkbox4.dds")
      self.value = true
      
      if callBackFunc then callBackFunc(self.value) end
    else
      control:SetTexture("ShissuFramework/textures/checkbox1.dds")
      self.value = false
      
      if callBackFunc then callBackFunc(self.value) end
    end
  end) 

  if (label) then
    control.label = WINDOW_MANAGER:CreateControl(name .. "_Label", control, CT_LABEL)
    control.label:SetAnchor(TOPLEFT, control, TOPLEFT, 20, -2)
    control.label:SetDimensions(label[2], label[3])
    control.label:SetHidden(false)
    control.label:SetFont('SF_BUTTONFONT')
    control.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT) 
    control.label:SetText(label[1])
  end
  
  return control 
end  

function _addon.filterEdit(variable)
  local control = SGT_Notebook_MessagesRecipient_OfflineSince   
  local title = _L("OFFLINE") 
  local mainText = _L("DAYS")
  
  if (variable == "gold") then
    control = SGT_Notebook_MessagesRecipient_Gold   
    title = "Gold?"
    mainText = "1000? 2000? 3000? 4000? 10000? ...?"
  elseif (variable == "memberSince") then
    control = SGT_Notebook_MessagesRecipient_MemberSince   
    title = _L("DAYS_2") .. "?"
    mainText = ""  
  elseif (variable == "goldSince") then
    control = SGT_Notebook_MessagesRecipient_GoldSince   
    title = _L("DAYS_2") .. "?"
    mainText = ""  
  end

  local func = function(dialog) 
    local number = dialog:GetNamedChild("EditBox"):GetText()
    number = tonumber(number)
    
    if (number ~= nil) then
      if (type(number) == "number") then
        control:SetText(stdColor .. number)
        _mail[variable] = number
        _mail.fillScrollList()
      end
    end
  end
   
  ESO_Dialogs["SGT_EDIT"].title = {text = title,}
  ESO_Dialogs["SGT_EDIT"].mainText = {text = mainText .. "?",}  
  ESO_Dialogs["SGT_EDIT"].buttons[1] = {text = "OK",}     
  ESO_Dialogs["SGT_EDIT"].buttons[1].callback = func
  ZO_Dialogs_ShowDialog("SGT_EDIT")
end

function _addon.setDirection(control, controlText, variable)
  control:SetHandler("OnMouseUp", function(self, button) 
    if(button == 2) then
      if (_direction[variable]) then
        controlText:SetText(stdColor .. "<")
        _direction[variable] = false
      else
        controlText:SetText(stdColor .. ">")
        _direction[variable] = true
      end
      
      _mail.fillScrollList()
    elseif (button == 1) then
      if variable then
        _addon.filterEdit(variable)
      end
    end  
  end)
end

function _mail.checkKick(choice)
  if _checkBox["kick"].value then    
    showDialog(GetString(SI_PROMPT_TITLE_GUILD_REMOVE_MEMBER), _L("CONFIRM_KICK"), function() 
      _mail.mailButtons(choice, 1)
    end, nil)
  elseif _checkBox["demote"].value then    
    showDialog(GetString(SI_PROMPT_TITLE_GUILD_REMOVE_MEMBER), _L("CONFIRM_DEMOTE"), function() 
      _mail.mailButtons(choice, 1)
    end, nil)
  else
    if (_checkBox["noMail"].value == false) then
      _mail.mailButtons(choice, 0)
    end
  end
end

function _addon.mail()
  createFlatWindow(
    "SGT_Notebook_MessagesRecipient",
    SGT_Notebook_MessagesRecipient,  
    {505, 480}, 
    nil,
    _L("TITLE")
  ) 
  
  createBackdropBackground("SGT_Notebook_MessagesRecipient_Filter", SGT_Notebook_MessagesRecipient_Filter, {200, 30})

  _mail.indexPool = ZO_ObjectPool:New(_mail.createIndexButton, _mail.removeIndexButton)
  _mail.list = createScrollContainer("SGT_Notebook_EMailList", 200, SGT_Notebook_MessagesRecipient, SGT_Notebook_MessagesRecipient_Line6, 10, 10, -10)
  
  _mail.button1 = createFlatButton("SGT_Notebook_NewSendListButton", SGT_Notebook_MessagesRecipient, {230, -20}, {110, 30}, white .. _L("CHOICE"), BOTTOMLEFT)   
  _mail.button2 = createFlatButton("SGT_Notebook_NewSendChoiceButton", SGT_Notebook_NewSendListButton, {130, 0}, {110, 30}, white .. _L("LIST"), TOPRIGHT)   
 
  _checkBox["aldmeri"] = _addon.createFlatCheckBox(
    "SGT_Notebook_MessagesRecipient_FactionAldmeri", 
    SGT_Notebook_MessagesRecipient_FactionLabel, 
    {55, 0}, 
    TOPRIGHT, 
    function(value) _mail.fillScrollList() end, 
    {zo_iconFormat(GetAllianceSymbolIcon(ALLIANCE_ALDMERI_DOMINION), 24, 24), 30, 25}, nil, true)
  
  _checkBox["ebonheart"] = _addon.createFlatCheckBox(
    "SGT_Notebook_MessagesRecipient_FactionEbonheart", 
    SGT_Notebook_MessagesRecipient_FactionAldmeri, 
    {50, 0}, 
    TOPRIGHT, 
    function(value) _mail.fillScrollList() end, 
    {zo_iconFormat(GetAllianceSymbolIcon(ALLIANCE_EBONHEART_PACT), 24, 24), 30, 25},
    nil,
    true
  )
  _checkBox["daggerfall"]  = _addon.createFlatCheckBox(
    "SGT_Notebook_MessagesRecipient_FactionDaggerfall", 
    SGT_Notebook_MessagesRecipient_FactionEbonheart, 
    {50, 0}, 
    TOPRIGHT, 
    function(value) _mail.fillScrollList() end, 
    {zo_iconFormat(GetAllianceSymbolIcon(ALLIANCE_DAGGERFALL_COVENANT), 24, 24), 30, 25},
    nil,
    true
  )
     
  _checkBox["online"] = _addon.createFlatCheckBox(
    "SGT_Notebook_MessagesRecipient_StatusOnline", 
    SGT_Notebook_MessagesRecipient_StatusLabel, 
    {71.5, 0}, 
    TOPRIGHT, 
    function(value) _mail.fillScrollList() end, 
    {zo_iconFormat(GetPlayerStatusIcon(PLAYER_STATUS_ONLINE), 24, 24), 30, 25},
    nil,
    true
  )
  _checkBox["offline"] = _addon.createFlatCheckBox(
    "SGT_Notebook_MessagesRecipient_StatusOffline", 
    SGT_Notebook_MessagesRecipient_StatusOnline, 
    {50, 0}, 
    TOPRIGHT, 
    function(value) _mail.fillScrollList() end, 
    {zo_iconFormat(GetPlayerStatusIcon(PLAYER_STATUS_OFFLINE), 24, 24), 30, 25},
    nil,
    true
  )

  _checkBox["kick"] = _addon.createFlatCheckBox(
    "SGT_Notebook_MessagesRecipient_CheckboxKick", 
    SGT_Notebook_MessagesRecipient, 
    {-100, 320}, 
    TOPRIGHT, 
    function(value)   
    end
  )
  _checkBox["demote"] = _addon.createFlatCheckBox(
    "SGT_Notebook_MessagesRecipient_CheckboxDemote", 
    SGT_Notebook_MessagesRecipient_CheckboxKick, 
    {0, 25}, 
    TOPLEFT, 
    function(value) 
    end
  )
  _checkBox["noMail"] = _addon.createFlatCheckBox(
    "SGT_Notebook_MessagesRecipient_CheckboxMail", 
    SGT_Notebook_MessagesRecipient_CheckboxDemote, 
    {0, 25}, 
    TOPLEFT, 
    function(value) end
  )
  
  SGT_Notebook_MessagesRecipient_FilterText:SetHandler("OnTextChanged", _mail.fillScrollList) 

  SGT_Notebook_MessagesRecipient_StatusOnline:SetHandler("OnMouseEnter", function() _addon.toolTip(self, _L("ONLINE")) end)
  SGT_Notebook_MessagesRecipient_StatusOffline:SetHandler("OnMouseEnter", function() _addon.toolTip(self, _L("OFFLINE")) end)

  SGT_Notebook_MessagesRecipient_FilterLabel:SetText(stdColor .. _L("FILTER"))
  SGT_Notebook_MessagesRecipient_ActionLabel:SetText(stdColor .. _L("ACTION"))
  SGT_Notebook_MessagesRecipient_SendLabel:SetText(yellow .. _L("SEND2"))
  
  SGT_Notebook_MessagesRecipient_OfflineSinceDir:SetText(stdColor .. ">")  
  _addon.setDirection(SGT_Notebook_MessagesRecipient_OfflineSinceDir, SGT_Notebook_MessagesRecipient_OfflineSinceDir, "offlineSince")
  _addon.setDirection(SGT_Notebook_MessagesRecipient_OfflineSinceLabel, SGT_Notebook_MessagesRecipient_OfflineSinceDir, "offlineSince")
  _addon.setDirection(SGT_Notebook_MessagesRecipient_OfflineSince, SGT_Notebook_MessagesRecipient_OfflineSinceDir, "offlineSince")

  SGT_Notebook_MessagesRecipient_MemberSinceDir:SetText(stdColor .. ">")  
  _addon.setDirection(SGT_Notebook_MessagesRecipient_MemberSinceDir, SGT_Notebook_MessagesRecipient_MemberSinceDir, "memberSince")
  _addon.setDirection(SGT_Notebook_MessagesRecipient_MemberSinceLabel, SGT_Notebook_MessagesRecipient_MemberSinceDir, "memberSince")
  _addon.setDirection(SGT_Notebook_MessagesRecipient_MemberSince, SGT_Notebook_MessagesRecipient_MemberSinceDir, "memberSince")
  
  SGT_Notebook_MessagesRecipient_GoldDir:SetText(stdColor .. ">")  
  _addon.setDirection(SGT_Notebook_MessagesRecipient_GoldDir, SGT_Notebook_MessagesRecipient_GoldDir, "gold")
  _addon.setDirection(SGT_Notebook_MessagesRecipient_GoldLabel, SGT_Notebook_MessagesRecipient_GoldDir, "gold")
  _addon.setDirection(SGT_Notebook_MessagesRecipient_Gold, SGT_Notebook_MessagesRecipient_GoldDir, "gold")
  
  _addon.setDirection(SGT_Notebook_MessagesRecipient_GoldSince, SGT_Notebook_MessagesRecipient_GoldDir, "goldSince")

  SGT_Notebook_MessagesRecipient_CheckboxKickLabel:SetText(_L("PROGRESS_KICK"))
  SGT_Notebook_MessagesRecipient_CheckboxDemoteLabel:SetText(_L("PROGRESS_DEMOTE"))
  SGT_Notebook_MessagesRecipient_CheckboxMailLabel:SetText(_L("NO_MAIL"))
    
  SGT_Notebook_MessagesRecipient_RanksLabel:SetText(_L("RANK"))
  SGT_Notebook_MessagesRecipient_OfflineSinceLabel:SetText(_L("OFFLINE"))
  SGT_Notebook_MessagesRecipient_FactionLabel:SetText(_L("ALLIANCE")) 
  SGT_Notebook_MessagesRecipient_MemberSinceLabel:SetText(_L("MEMBER"))
  SGT_Notebook_MessagesRecipient_GoldSinceLabel:SetText(_L("SINCE_GOLD"))
  
  -- Benutzerdefinierte Listen
  SGT_Notebook_MessagesRecipient_Add:SetHandler("OnMouseEnter", function(self) _addon.toolTip(self, _L("PLAYER_ADD")) end)
  SGT_Notebook_MessagesRecipient_Delete:SetHandler("OnMouseEnter", function(self) _addon.toolTip(self, _L("PLAYER_REMOVE")) end)
  SGT_Notebook_MessagesRecipient_BuildGroup:SetHandler("OnMouseEnter", function(self) _addon.toolTip(self, _L("GROUP")) end)
  SGT_Notebook_MessagesRecipient_NewList:SetHandler("OnMouseEnter", function(self) _addon.toolTip(self, _L("LIST_INFO")) end)
  SGT_Notebook_MessagesRecipient_NewList:SetHandler("OnMouseUp", _addon.newList)
  SGT_Notebook_MessagesRecipient_Add:SetHandler("OnMouseUp", _mail.addPlayerToList)
  SGT_Notebook_MessagesRecipient_Delete:SetHandler("OnMouseUp", _mail.deletePlayerfromList)
  SGT_Notebook_MessagesRecipient_BuildGroup:SetHandler("OnMouseUp", _mail.buildGroupWithList)  

  SGT_MailProtocol_Ignore:SetHandler("OnMouseEnter", function() _addon.toolTip(self, _L("PROTOCOL_INFO")) end)  
  SGT_Notebook_NewSendListButton:SetHandler("OnMouseUp", function() _mail.checkKick(0) end)
  SGT_Notebook_NewSendChoiceButton:SetHandler("OnMouseUp", function() _mail.checkKick(1) end)
  
  -- DropDown Menü "Rank" befüllen
  SGT_Notebook_MessagesRecipient_Ranks:GetNamedChild("Dropdown"):SetWidth(140)
  SGT_Notebook_MessagesRecipient_Ranks:SetWidth(140)  
           
  _mail.dropDownRanks  = SGT_Notebook_MessagesRecipient_Ranks.dropdown
  _mail.dropDownRanks:SetSortsItems(false) 
  _mail.dropDownRanks:AddItem(_mail.dropDownRanks:CreateItemEntry(yellow .. "-- " .. white .. _L("ALL"), _mail.rankSelected))
    
  for rankId = 1, GetNumGuildRanks(_mail.currentGuild) do
    _mail.dropDownRanks:AddItem(_mail.dropDownRanks:CreateItemEntry(white .. GetFinalGuildRankName(_mail.currentGuild, rankId), _mail.rankSelected))
  end  
  
  _mail.dropDownRanks:SetSelectedItem(yellow .. "-- " .. white .. _L("ALL"))
  
  -- DropDown Menü "Gilde" befüllen   
  SGT_Notebook_MessagesRecipient_Guilds:GetNamedChild("Dropdown"):SetWidth(200)
  SGT_Notebook_MessagesRecipient_Guilds:SetWidth(200)  
  
  _mail.dropDownGuilds = SGT_Notebook_MessagesRecipient_Guilds.dropdown
  _mail.dropDownGuilds:SetSortsItems(false) 
  _mail.dropDownGuilds:AddItem(_mail.dropDownGuilds:CreateItemEntry(yellow .. _addon.friends, _mail.optionSelected))

  -- EmpfängerListe
  -- ScrollContainer + UI
  _mail.buildMailList()

  _mail.selected = WINDOW_MANAGER:CreateControl(nil, _mail.list.scrollChild, CT_TEXTURE)
  _mail.selected:SetTexture("EsoUI\\Art\\Buttons\\generic_highlight.dds")
  setDefaultColor(_mail.selected)  
  _mail.selected:SetHidden(true)
  _mail.fillScrollList() 
   
  createFlatWindow(
    "SGT_Notebook_Splash",
    SGT_Notebook_Splash,  
    {430, 120}, 
    _mail.mailAbort,
    _L("PROGRESS_SEND")
  ) 
  
  SGT_Notebook_Splash_Version:SetText(_addon.formattedName .. " " .. _addon.Version)  
  SGT_Notebook_Splash_SubjectLabel:SetText(_L("SPLASH_SUBJECT") .. ":")
  SGT_Notebook_Splash_ProgressLabel:SetText(_L("SPLASH_PROGRESS") .. ":")

  SGT_Notebook_Splash_Continue:SetHandler("OnClicked", _mail.mailContinue)
  SGT_Notebook_Splash_Protocol:SetHandler("OnClicked", _mail.mailProtocol)
  SGT_Notebook_Splash_Continue:SetHandler("OnMouseEnter", function(self) _addon.toolTip(self, _L("MAIL_CONTIN")) end)
  SGT_Notebook_Splash_Protocol:SetHandler("OnMouseEnter", function(self) _addon.toolTip(self, _L("PROTOCOL_INFO")) end)  
                         
  createFlatWindow(
    "SGT_MailProtocol",
    SGT_MailProtocol,  
    {360, 300}, 
    false,
    _L("PROTOCOL")
  ) 
  
  SGT_MailProtocol_Full:SetText(_L("PROTOCOL_FULL"))
  SGT_MailProtocol_Ignore:SetText(_L("PROTOCOL_INVITE"))  
  SGT_MailProtocol_Version:SetText(_addon.formattedName .. " " .. _addon.Version)  

  _mail.divider2 = createLine("Divider", {400, 1}, "SGT_MailProtocol", SGT_MailProtocol,  TOPLEFT, 170, 50, {BOTTOMLEFT, 170, -20}, {0.49019607901573, 0.74117648601532, 1}, true)
  _mail.protocolFullIndexPool = ZO_ObjectPool:New(_mail.protocolCreateIndexButton, _mail.removeIndexButton)
  _mail.ProtocolList.Full = createScrollContainer("SGT_Notebook_FullList", 145, SGT_MailProtocol, SGT_MailProtocol_Line, 10, 40, -10)  
  _mail.protocolIgnoreIndexPool = ZO_ObjectPool:New(_mail.protocolCreateIndexButton, _mail.removeIndexButton)
  _mail.ProtocolList.Ignore = createScrollContainer("SGT_Notebook_IgnoreList", 145, SGT_MailProtocol, SGT_MailProtocol_Line, 175, 40, -10)  
end

function _addon.toolTip(control, text)
  ZO_Tooltips_ShowTextTooltip(control, TOPRIGHT, white .. text)
end
             
function _addon.getGuildNote(memberId)
  local memberVar = { GetGuildMemberInfo(_ui.currentGuild, memberId) }
  
  if memberVar then 
    return memberVar[2]
  end
  
  return false
end
                                               
-- Initialisierung
function _addon.initialized()                    
  shissuNotebook = shissuNotebook or {}

  if shissuNotebook["mailList"] == nil then
    shissuNotebook["mailList"] = {}
  end

  if shissuNotebook["positions"] == nil then
    shissuNotebook["positions"] = {}
  end  

  if (shissuNotebook["positions"]["protocol"] == nil) then
    shissuNotebook["positions"]["protocol"] = {}
  end
  
  if (shissuNotebook["positions"]["splash"] == nil) then
    shissuNotebook["positions"]["splash"] = {}
  end
    
  saveWindowPosition(SGT_MailProtocol, shissuNotebook["positions"]["protocol"])
  getWindowPosition(SGT_MailProtocol, shissuNotebook["positions"]["protocol"])
  
  saveWindowPosition(SGT_Notebook_Splash, shissuNotebook["positions"]["splash"])
  getWindowPosition(SGT_Notebook_Splash, shissuNotebook["positions"]["splash"])

  zo_callLater(_addon.mail, 1000)
end            

-- EVENT FUNCTIONS
function _mail.EVENT_MAIL_SEND_SUCCESS()
  _mail.recipientName = ""
  _mail.isSend = true
end
                        
function _mail.EVENT_MAIL_SEND_FAILED(event, reason) 
  local CN = _addon.formattedName .. ": " .. _L("MAIL_NEW") .. " - " .. orange
  local CT = orange.. " - "
  
  _mail.isSend = true

  if reason == MAIL_SEND_RESULT_FAIL_INVALID_NAME or reason == MAIL_SEND_RESULT_RECIPIENT_NOT_FOUND then d(CN .. GetString(SI_SENDMAILRESULT2).. CT .. _mail.recipientName)
  elseif reason == MAIL_SEND_RESULT_FAIL_BLANK_MAIL then d(CN.. _L("BLANK_MAIL"))
  elseif reason == MAIL_SEND_RESULT_NOT_ENOUGH_MONEY then d(CN.. GetString(SI_SENDMAILRESULT5))
  elseif reason == MAIL_SEND_RESULT_FAIL_MAILBOX_FULL then 
    d(CN.. GetString(SI_SENDMAILRESULT3).. CT .. _mail.recipientName)
    table.insert(_mail.emailError.full, _mail.recipientName)
  elseif reason == MAIL_SEND_RESULT_FAIL_IGNORED then 
    d(CN.. GetString(SI_SENDMAILRESULT4).. CT .. _mail.recipientName) 
    table.insert(_mail.emailError.ignore, _mail.recipientName)
  elseif reason == MAIL_SEND_RESULT_FAIL_DB_ERROR or reason == MAIL_SEND_RESULT_FAIL_IN_PROGRESS then d(CN.. GetString(SI_SENDMAILRESULT1))    
  end 
end

function _mail.EVENT_MAIL_CLOSE_MAILBOX()
  _mail.emailIsOpen = false
end   

function _mail.EVENT_MAIL_OPEN_MAILBOX()
  _mail.emailIsOpen = true  
end    

-- EVENTS
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_MAIL_CLOSE_MAILBOX, _mail.EVENT_MAIL_CLOSE_MAILBOX)
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_MAIL_SEND_FAILED, _mail.EVENT_MAIL_SEND_FAILED)
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_MAIL_SEND_SUCCESS, _mail.EVENT_MAIL_SEND_SUCCESS)
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_MAIL_OPEN_MAILBOX, _mail.EVENT_MAIL_OPEN_MAILBOX)                   
 
function _addon.EVENT_ADD_ON_LOADED(_, addOnName)    
  zo_callLater(function()              
    ShissuFramework.initAddon(_addon.Name, _addon.initialized)
  end, 150) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end
          
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)