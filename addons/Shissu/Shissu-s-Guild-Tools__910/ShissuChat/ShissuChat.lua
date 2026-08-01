-- Shissu Guild Tools Addon
-- ShissuChat
--
-- Version: v2.3.1.20
-- Last Update: 17.12.2020
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]

local setPanel = ShissuFramework["setPanel"]
local RGBtoHex = ShissuFramework["functions"]["datatypes"].RGBtoHex

local _addon = {}
_addon.Name = "ShissuChat"
_addon.Version = "2.3.1.20"
_addon.lastUpdate = "17.12.2020"
_addon.formattedName	= stdColor .. "Shissu" .. white .. "'s Chat"
_addon.enabled = false
_addon.LINK = "shissu"
_addon.urlLINK = 101    
_addon.currentZone = ""                                                            
_addon.core = {}  

_addon.settings = {
  ["hideText"] = true,                                                                          
  ["brackets"] = true,                                  
  ["nameFormat"] = 3,
  ["registerTab"] = 1,
  ["channel"] = "/zone",
  ["startChannel"] = true,
  ["url"] = true,
  ["partySwitch"] = true,
  ["partyLead"] = true,
  ["whisperSound"] = 2,
  ["partyLeadColor"] = {1, 1, 1, 1},
  ["whisperInfoColor"] = {0.50196081399918, 0.80000001192093, 1, 1},
  ["timeStamp"] = true,
  ["timeStampNPC"] = false,
  ["timeStampFormat"] = "DD.MM.Y HH:m:s" ,  
  ["timeColor"] = {0.50196081399918, 0.80000001192093, 1, 1},
  ["dateColor"] = {0.8901960849762, 0.93333333730698, 1, 1},  
  ["nameFormatColor"] = {0.8901960849762, 0.93333333730698, 1, 1},
  ["nameFormatColored"] = true,
  ["autoWhisper"] = true,
  ["autoGroup"] = true,
  ["autoZone"] = true,
  ["auto"] = {},
  ["info"] = {},
  ["names"] = {},
  ["namesColor"] = {0.50196081399918, 0.80000001192093, 1, 1},
  ["stdGuildColor"] = true,
  ["guild"] = true,
  ["level"] = true,
  ["alliance"] = true,
  ["rank"] = true, 
}                  

_addon.zoneName = nil
_addon.panel = setPanel("Chat", _addon.formattedName, _addon.Version, _addon.lastUpdate)
_addon.controls = {}

local _L = ShissuFramework["func"]._L(_addon.Name)

local _sounds = {
  SOUNDS.NONE,
  SOUNDS.EMPEROR_DEPOSED_ALDMERI,
  SOUNDS.AVA_GATE_CLOSED,
  SOUNDS.NEW_NOTIFICATION,
  SOUNDS.CHAMPION_POINTS_COMMITTED,
  SOUNDS.CHAMPION_ZOOM_IN,
  SOUNDS.CHAMPION_ZOOM_OUT,
  SOUNDS.CHAMPION_STAR_MOUSEOVER,
  SOUNDS.CHAMPION_CYCLED_TO_MAGE,
  SOUNDS.BLACKSMITH_EXTRACTED_BOOSTER,
  SOUNDS.ENCHANTING_ASPECT_RUNE_REMOVED,
  SOUNDS.SMITHING_OPENED,
  SOUNDS.GUILD_ROSTER_REMOVED,
  SOUNDS.GUILD_ROSTER_ADDED,
  SOUNDS.GUILD_WINDOW_OPEN,
  SOUNDS.GROUP_DISBAND,
  SOUNDS.DEFAULT_CLICK,
  SOUNDS.EDIT_CLICK,
  SOUNDS.STABLE_FEED_STAMINA,
  SOUNDS.QUICKSLOT_SET,
  SOUNDS.MARKET_CROWNS_SPENT,
}  

function _addon.core.defaultRegister()
  if (CHAT_SYSTEM == nil) then return end
  if (CHAT_SYSTEM.primaryContainer == nil) then return end
  
  local numRegister = #CHAT_SYSTEM.primaryContainer.windows
	
	if numRegister > 1 then
		for numRegister, container in ipairs (CHAT_SYSTEM.primaryContainer.windows) do
      local control = GetControl("ZO_ChatWindowTabTemplate" .. numRegister .. "Text")
      
      if (numRegister == shissuChat["registerTab"]) then
        CHAT_SYSTEM.primaryContainer:HandleTabClick(container.tab)
					
				control:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
				control:GetParent().state = PRESSED
      else
				control:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
    		control:GetParent().state = UNPRESSED      
      end
    end
  end
end

function _addon.core.changePrimaryContainer()
	for tabIndex, tabObject in ipairs(CHAT_SYSTEM.primaryContainer.windows) do
		tabObject.buffer:SetMaxHistoryLines(1000)
      
    if shissuChat["hideText"] == false then
  		tabObject.buffer:SetLineFade(3600, 2)
  	end
	end
end

function _addon.core.createNewTab()
	local origChatSystemCreateNewChatTab = CHAT_SYSTEM.CreateNewChatTab
  
	CHAT_SYSTEM.CreateNewChatTab = function(self, ...)
		origChatSystemCreateNewChatTab(self, ...)
		_addon.core.changePrimaryContainer()
	end
end

-- Orig Func: ingame/chatsystem/chathandlers.lua
local ChannelInfo = ZO_ChatSystem_GetChannelInfo()

local function CreateChannelLink(channelInfo, overrideName)
  if channelInfo.channelLinkable then
    local channelName = overrideName or GetChannelName(channelInfo.id)
    return ZO_LinkHandler_CreateChannelLink(channelName)
  end
end

local function GetCustomerServiceIcon(isCustomerServiceAccount)
  if(isCustomerServiceAccount) then
    return "|t16:16:EsoUI/Art/ChatWindow/csIcon.dds|t"
  end
  
  return ""
end

function _addon.core.displayBrackets(from, userFacingName, linkType)
	if not userFacingName then userFacingName = from end
	
  if (shissuChat["brackets"]) then
		return ZO_LinkHandler_CreateLinkWithoutBrackets(userFacingName, nil, linkType, from)
	else
		return ZO_LinkHandler_CreateLink(userFacingName, nil, linkType, from)
	end
end

function _addon.core.fromLink(messageType, fromName, isCS, fromDisplayName)
  local newFrom = fromName

	if IsDecoratedDisplayName(fromName) then
    -- Nachricht mit "@" (Gilde, Whisper)
    newFrom = _addon.core.displayBrackets(newFrom, newFrom, DISPLAY_NAME_LINK_TYPE) 
  else
    newFrom = zo_strformat(SI_UNIT_NAME, newFrom)

    -- Nicht für NPCs
		if not (messageType == CHAT_CHANNEL_MONSTER_SAY or messageType == CHAT_CHANNEL_MONSTER_YELL or messageType == CHAT_CHANNEL_MONSTER_WHISPER or messageType == CHAT_CHANNEL_MONSTER_EMOTE) then
			if shissuChat["nameFormat"] == 1 then
				newFrom = _addon.core.displayBrackets(fromDisplayName, fromDisplayName, DISPLAY_NAME_LINK_TYPE)
			elseif shissuChat["nameFormat"] == 3 then
        newFrom = newFrom
				newFrom = _addon.core.displayBrackets(newFrom, newFrom, CHARACTER_LINK_TYPE)  
        newFrom = newFrom .. _addon.core.displayBrackets(fromDisplayName, fromDisplayName, DISPLAY_NAME_LINK_TYPE) 
		  else
				newFrom = _addon.core.displayBrackets(newFrom, newFrom, CHARACTER_LINK_TYPE)
			end	
    end  
  end                                             
  
  if isCS then -- ZOS icon
		newFrom = "|t16:16:EsoUI/Art/ChatWindow/csIcon.dds|t" .. newFrom
	end
  
  -- Gruppenanführer???
	if (messageType == CHAT_CHANNEL_PARTY and shissuChat["partyLead"]) then
    if zo_strformat(SI_UNIT_NAME, fromName) == GetUnitName(GetGroupLeaderUnitTag()) then
      newFrom = RGBtoHex(shissuChat["partyLeadColor"]) .. newFrom .. "|r"
    end
  end 
  
	return newFrom
end

function _addon.core.createLinkURL(text)
  if (string.find(text, "www.") or string.find(text, "http://") or string.find(text, "https://")) then
    local oldText = text
    local cache = 0  
    local cache2 = 0
    local cache3 = 0
    
    local onlyWWW = string.find(text, "www.")
    
    if (onlyWWW and not string.find(text, "http")) then
      text = string.gsub(text, "www.", "http://www.")
    end
    
    if (string.sub(text, 1, 4) == "http" or string.sub(text, 1, 3) == "www") then
      cache2 = 1
      text = "shissu meow " .. text .. " meow shissu meow"
    end
               
    local preT, url, nextT = text:match( "(.+)%s+(https?%S+)%s+(.*)$" )
    
    if (nextT == nil) then
      cache3 = 1
      text = text .. " meow shissu meow"
      
      preT, url, nextT = text:match( "(.+)%s+(https?%S+)%s+(.*)$" )
    end
    if url~= nil then
    local stringLen = string.len(url)  
    local last = string.sub(url, stringLen, stringLen)
        
    if (last== "," or last == ".") then
      url = string.sub(url, 0, stringLen-1)
      cache = 1
    end
   
    local urlLink = stdColor .. string.format("|H1:%s:%s:%s|h%s|h", _addon.LINK, 1, _addon.urlLINK, url) .. "|r"
  
    if (cache2 == 0) then  	
      local stringLen2 = string.len(preT)
      local stringLen3 = string.len(text)
         
      local newNextT = string.sub(text, stringLen + stringLen2 + 2, stringLen3)  
     
      if (cache3 == 1) then
        text = preT .. " " .. urlLink 
      elseif (cache == 1) then
        text = preT .. " " .. urlLink .. newNextT
      else
       text = preT .. " " .. urlLink .. " " .. newNextT
      end
    else
      text = urlLink
    end
        else
          return oldText
        end
  end
    
  return text
end
                                                             
function _addon.core.createTimestamp()
	local timeString = GetTimeString()
  local dateString = GetDateStringFromTimestamp(GetTimeStamp())
  
  -- Uhrzeit
	local hours, minutes, seconds = timeString:match("([^%:]+):([^%:]+):([^%:]+)")
  
  local hours12	
  local hours_0 = tonumber(hours)
	local hours12_0 = (hours_0 - 1)%12 + 1
	
	if (hours12_0 < 10) then
		hours12 = "0" .. hours12_0
	else
		hours12 = hours12_0
	end        
  
  -- AM-PM-System
	local englishUP  = "AM"
	local englishLOW = "am"
  
	if (hours_0 >= 12) then
		englishUP = "PM"
		englishLOW = "pm"
	end
  
  local minutes_0 = minutes
  local seconds_0 = seconds
  
  if (string.len(minutes) < 2) then
    minutes_0 = "0" .. minutes     
  end

  if (string.len(seconds) < 2) then
    seconds_0 = "0" .. seconds
  end
    
  -- Datum
  local days, month, year = dateString:match("(%d+).(%d+).(%d+)")
  local days_0 = tonumber(days)
  local month_0 = tonumber(days)
  
  -- Farben
  local cTime = shissuChat["timeColor"] or {1, 1, 1, 1}
  cTime = RGBtoHex(shissuChat["timeColor"])
  
  local cDate = RGBtoHex(shissuChat["dateColor"] or {1, 1, 1, 1}) 
  cDate = RGBtoHex(shissuChat["dateColor"])
  
  -- Ausgabe String
  timestamp = shissuChat["timeStampFormat"] or "DD.MM.Y HH:m:s"
  
  -- Datum	
  timestamp = timestamp:gsub("DD", cDate .. days)
  timestamp = timestamp:gsub("D", cDate .. days_0)
  timestamp = timestamp:gsub("MM", cDate .. month)
  timestamp = timestamp:gsub("M", cDate .. month_0)  
  timestamp = timestamp:gsub("Y", cDate .. year)

  -- Uhrzeit  
	timestamp = timestamp:gsub("HH", cTime .. hours)
	timestamp = timestamp:gsub("H", cTime .. hours_0)
  timestamp = timestamp:gsub("hh", cTime .. hours12)
	timestamp = timestamp:gsub("h", cTime .. hours12_0)  
  timestamp = timestamp:gsub("mm", cTime .. minutes_0)  
	timestamp = timestamp:gsub("m", cTime .. minutes)
  timestamp = timestamp:gsub("ss", cTime .. seconds_0)    
	timestamp = timestamp:gsub("s", cTime .. seconds)  
	timestamp = timestamp:gsub("A", cTime .. englishUP)
	timestamp = timestamp:gsub("a", cTime .. englishLOW)
	
	return timestamp .. "|r"
end

function _addon.core.getGuildInfo(fromName, displayName)
  if shissuChat["info"] then  
    local foundInList = 0
    local foundNameInList = ""
    
    if ( _SGTguildMemberList[fromName] ) then
      foundInList = 1
      foundNameInList = fromName
    elseif ( _SGTguildMemberList[displayName] ) then
      foundInList = 1
      foundNameInList = fromName
    end
    
    if ( foundInList == 1 ) then
      if _SGTguildMemberList == nil then return end
      if _SGTguildMemberList[foundNameInList] == nil then return end

      local guildId = _SGTguildMemberList[foundNameInList].gid
      local memberId = _SGTguildMemberList[foundNameInList].id
      
      local accInfo = {GetGuildMemberInfo(guildId, memberId)}
      local charInfo = {GetGuildMemberCharacterInfo(guildId, memberId)}    
      
      --d(accInfo)
      
      local guilds = _SGTguildMemberList[foundNameInList]["guilds"]
 
      for i = 1, #guilds do
        local guildName = guilds[i][1]
        
        if (shissuChat["info"][guildName]) then  
        --  d(guilds[i][1])
          
          local accInfo = {GetGuildMemberInfo(guildId, memberId)}
          local charInfo = {GetGuildMemberCharacterInfo(guildId, memberId)}
          local accName = accInfo[1]
          local charName = zo_strformat(SI_UNIT_NAME, charInfo[2])   
          
          --d(guildId)
          --d(memberId) 
          --gd(charName)

          local charAlliance = charInfo[5]
          
          if charAlliance ~= nil and charAlliance ~= 0 then
            charAlliance = zo_iconFormat(GetAllianceBannerIcon(charAlliance), 24, 24)
          end 

          local rang = GetGuildRankSmallIcon(GetGuildRankIconIndex(guildId, accInfo[3]))
          rang = "|t24:24:" .. rang .. "|t"
          
          local charLvL = charInfo[6]
          
          if charLvL == 50 and charInfo[7] > 0 then 
            charLvL = "[CP" .. charInfo[7] .."]"
          else 
            charLvL = " [" .. charLvL .. "]"
          end            

          -- Liegen abgespeicherte Namen vor?
          if (shissuChat["names"] ~= nil) then
            if (shissuChat["names"][guildName] ~= nil) then
              if (shissuChat["names"][guildName] ~= "") then
                return guildName, shissuChat["names"][guildName], guildId, charLvL, rang, charAlliance, charName
              end
            end
          end
            
          return guildName, guildName, guildId, charLvL, rang, charAlliance, charName
        end
      end
    end
  end

  return ""
end

function _addon.core.getGuildColor(guildName)
  local color = ""

  if ((guildName == nil) or (guildName == "")) then
    return color
	end

  local guildChatCategories = {}
  guildChatCategories[1] = CHAT_CATEGORY_GUILD_1
  guildChatCategories[2] = CHAT_CATEGORY_GUILD_2
  guildChatCategories[3] = CHAT_CATEGORY_GUILD_3
  guildChatCategories[4] = CHAT_CATEGORY_GUILD_4
  guildChatCategories[5] = CHAT_CATEGORY_GUILD_5

  for i = 1, GetNumGuilds() do
    local guildId = GetGuildId(i)
      if (GetGuildName(guildId) == guildName) then
        color = ZO_ColorDef:New(1, 1, 1, 1)
        color:SetRGB(GetChatCategoryColor(guildChatCategories[i]))
        
        color = RGBtoHex({color["r"], color["g"], color["b"]})
        break
      end
  end

  return color
end

function _addon.core.formatMessage(messageType, fromName, text, isFromCustomerService, fromDisplayName)
  local channelInfo = ChannelInfo[messageType]
  local timeStamp = ""
  local additionalInfo = ""

  if channelInfo and channelInfo.format then
    local channelLink = CreateChannelLink(channelInfo)

  --  local mss = GetGameTimeMilliseconds()
    local origname, guildName, guildId, guildLvL, guildRang, guildAlliance, guildChar = _addon.core.getGuildInfo(fromName, displayName)
    
 --   local mse = GetGameTimeMilliseconds()
 --   d("Diff: " .. mse - mss .. " ms")
    
    if ((messageType >= CHAT_CHANNEL_GUILD_1 and messageType <= CHAT_CHANNEL_GUILD_5) or messageType == CHAT_CHANNEL_WHISPER) then
      if (guildChar ~= nil) then
        fromName = guildChar
      end
    end
    
    local fromLinkColor = ""
     
    if (shissuChat["nameFormatColored"] == true) then
      fromLinkColor = shissuChat["nameFormatColor"] or {1, 1, 1, 1}
      fromLinkColor = RGBtoHex(fromLinkColor)
    end
                
    local fromLink = fromLinkColor .. _addon.core.fromLink(messageType, fromName, isCS, fromDisplayName)
    
    if (shissuChat["guild"] and guildName ~= nil and not (messageType >= CHAT_CHANNEL_GUILD_1 and messageType <= CHAT_CHANNEL_GUILD_5)) then
      local guildNameColor = ""

      if ( shissuChat["stdGuildColor"] == true ) then
        guildNameColor = _addon.core.getGuildColor(origname)
      else
        guildNameColor =  shissuChat["namesColor"]
        guildNameColor = RGBtoHex(guildNameColor)
      end

      additionalInfo = guildNameColor .. "[" .. guildName .. "]|r"
    end

    if (shissuChat["alliance"] and guildAlliance ~= nil) then
      additionalInfo = additionalInfo .. guildAlliance
    end

    if (shissuChat["rank"] and guildRang ~= nil)  then
      additionalInfo = additionalInfo .. guildRang
    end  

    if (shissuChat["level"] == false) then
      guildLvL = ""
    end 
    
    -- URL Handling
    if shissuChat["url"] then   
      text = _addon.core.createLinkURL(text)     
    end

    if (shissuChat["timeStampNPC"] == nil) then shissuChat["timeStampNPC"] = false end
   
    if (shissuChat["timeStampNPC"] == false and shissuChat["timeStamp"] == true) then
      -- Zeitstempel nicht anzeigen, wenn Chatnachricht von einem NPC stammt 
      if  (messageType ~= CHAT_CHANNEL_MONSTER_SAY and 
          messageType ~= CHAT_CHANNEL_MONSTER_YELL and
          messageType ~= CHAT_CHANNEL_MONSTER_WHISPER and
          messageType ~= CHAT_CHANNEL_MONSTER_EMOTE) then
        
        timeStamp = "|c8989A2[|r" .. _addon.core.createTimestamp() .. "|c8989A2]|r "
      end
    elseif shissuChat["timeStamp"] == true then
      timeStamp = "|c8989A2[|r" .. _addon.core.createTimestamp() .. "|c8989A2]|r "
    end


    -- Soundausgabe, beim plüstern
    if (messageType == CHAT_CHANNEL_WHISPER and shissuChat["whisperSound"] ~= 0) then
      PlaySound(_sounds[shissuChat["whisperSound"]])
    end

    if (guildLvL ~= nil) then
      fromLink = fromLink .. " " .. guildLvL
    end   

    if channelInfo.formatMessage then
      text = zo_strformat(SI_CHAT_MESSAGE_FORMATTER, text)
    end

    if channelLink then
      formattedText = string.format(GetString(channelInfo.format), channelLink, " " .. fromLink .."|r", text)
    else
      if channelInfo.supportCSIcon then
        formattedText = string.format(GetString(channelInfo.format), GetCustomerServiceIcon(isFromCustomerService), fromLink .. "|r", text)
      else
        formattedText = string.format(GetString(channelInfo.format), fromLink .. "|r", text)
      end
    end
  
    return timeStamp .. additionalInfo .. formattedText, channelInfo.saveTarget, fromDisplayName, text
  end

  return timeStamp .. text
end

function _addon.core.onLickClicked(rawLink, mouseButton, linkText, color, linkType, lineNumber, chanCode)
	if linkType == _addon.LINK then
		local chanNumber = tonumber(chanCode)
		local numLine = tonumber(lineNumber)

		if chanCode and mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			if (chanNumber == _addon.urlLINK) then
        RequestOpenUnsafeURL(linkText)
			end
		end

		return true
	end
end

function _addon.core.onGroupMemberJoined()
  if shissuChat["partySwitch"] then
    ZO_ChatWindowTextEntryEditBox:SetText("/party ")  
  end
end

function _addon.core.onGroupMemberLeft(_, characterName)
  local ownName = GetUnitName("player")
  
  if ( shissuChat["partySwitch"] and characterName ~= ownName ) then
    ZO_ChatWindowTextEntryEditBox:SetText("/zone ")  
  end
end 

function _addon.core.chatMessageChannel(eventId, messageType, fromName, text, isFromCustomerService, fromDisplayName)
  local currentText = CHAT_SYSTEM.textEntry:GetText()
  local allow = 0
  local channel = ""
  
  local channelString = {
    [CHAT_CHANNEL_PARTY] = "/party ",
    [CHAT_CHANNEL_ZONE] = "/zone ",
    [CHAT_CHANNEL_WHISPER] = "/t " .. fromDisplayName .. " ",
    [CHAT_CHANNEL_ZONE_LANGUAGE_1] = "/zen ",
    [CHAT_CHANNEL_ZONE_LANGUAGE_2] = "/zfr ",
    [CHAT_CHANNEL_ZONE_LANGUAGE_3] = "/zde ",
    [CHAT_CHANNEL_ZONE_LANGUAGE_4] = "/zjp ",
    [CHAT_CHANNEL_GUILD_1] = {"/g1 ", 1},
    [CHAT_CHANNEL_GUILD_2] = {"/g2 ", 2},
    [CHAT_CHANNEL_GUILD_3] = {"/g3 ", 3},
    [CHAT_CHANNEL_GUILD_4] = {"/g4 ", 4},
    [CHAT_CHANNEL_GUILD_5] = {"/g5 ", 5},
  }

  if string.len(currentText) < 1 then
    if (messageType == CHAT_CHANNEL_WHISPER and shissuChat["autoWhisper"] == true) 
      or (messageType == CHAT_CHANNEL_PARTY and shissuChat["autoGroup"] == true)
      or (messageType >= CHAT_CHANNEL_ZONE and messageType <= CHAT_CHANNEL_ZONE_LANGUAGE_4 and shissuChat["autoZone"] == true) then

      allow = 1
      channel = channelString[messageType]
    end   
        
    if (messageType >= CHAT_CHANNEL_GUILD_1 and messageType <= CHAT_CHANNEL_GUILD_5) then 
      local guildId = channelString[messageType][2]
      guildId = GetGuildId(guildId)
      
      local guildName = GetGuildName(guildId)  
      
      if shissuChat["auto"] then
        if shissuChat["auto"][guildName] then
          allow = 1
          channel = channelString[messageType][1]
        end
      end
    end    
  end 
  
  if (allow == 1 and channelString[messageType] ~= nil) then
     ZO_ChatWindowTextEntryEditBox:SetText(channel)
  end
end

function ZO_TabButton_Text_SetTextColor(self, color)
	local c = shissuChat["whisperInfoColor"]

	if(self.allowLabelColorChanges) then
		local label = GetControl(self, "Text")
		label:SetColor(c[1], c[2], c[3], c[4])
	end	
end
 
function _addon.core.startModule()
  _addon.enabled = true
  _addon.core.createNewTab()
  _addon.core.defaultRegister()

  if (shissuChat["channel"] and shissuChat["startChannel"]) then
    if (_addon.zoneName == nil) then
      local cutStringAtLetter = ShissuFramework["functions"]["datatypes"].cutStringAtLetter

      shissuChat["channel"] = cutStringAtLetter(shissuChat["channel"], ' ') 
      ZO_ChatWindowTextEntryEditBox:SetText(shissuChat["channel"] .. " ")
    end
  end

  _addon.zoneName = GetUnitZone('player')

  -- Vergrößerung der Chatbox auf Fenstergröße, bei Bedarf
  CHAT_SYSTEM.maxContainerWidth, CHAT_SYSTEM.maxContainerHeight = GuiRoot:GetDimensions() 
  
  -- URL
  LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, _addon.core.onLickClicked)
  LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, _addon.core.onLickClicked)
  
  -- Gruppenwechsel; automatischer Wechsel
	EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GROUP_MEMBER_JOINED, _addon.core.onGroupMemberJoined)
	EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GROUP_MEMBER_LEFT, _addon.core.onGroupMemberLeft)
  
  -- Formatierung der Textausgaben

  local registerFormatEventChatMessage = ShissuFramework["functions"]["chat"].registerFormatEventChatMessage 
  registerFormatEventChatMessage(_addon.Name, _addon.core.formatMessage)
end
    
function _addon.createSettingMenu()
  local controls = ShissuFramework._settings[_addon.Name].controls
  
  -- Allgemeines
  controls[#controls+1] = {
    type = "title",
    name = _L("GENERAL"),
  } 
  
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("BRACKETS"),
    tooltip = _L("BRACKETS_TT"),
    getFunc = shissuChat["brackets"],
    setFunc = function(_, value)
      shissuChat["brackets"] = value
    end,
  } 
  
  local accountArr = { _L("NAME_2"), _L("NAME_3"), _L("NAME_4"), }
  
  controls[#controls+1] = {
    type = "combobox",
    name = _L("NAME"),
    items = accountArr,
    getFunc = accountArr[shissuChat["nameFormat"]],
    setFunc = function(_, value)

      for valueId = 1, 3 do
        if accountArr[valueId] == value then
          shissuChat["nameFormat"] = valueId
          break
        end
      end
    end,
  }  
  
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("NAME") .. " " .. _L("COLOR"),
    tooltip = _L("NAME") .. " " .. _L("COLOR"),
    getFunc = shissuChat["nameFormatColored"],
    setFunc = function(_, value)
      shissuChat["nameFormatColored"] = value
    end,    
  }   
             
  controls[#controls+1] = {
    type = "colorpicker", 
    name = _L("NAME") .. " " .. _L("COLOR"),
    getFunc = shissuChat["nameFormatColor"], 
    setFunc = function (r, g, b)                                                                                                                                                           
      shissuChat["nameFormatColor"] = {r, g, b}
    end,
  } 
            
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("URL"),
    tooltip = _L("URL_TT"),
    getFunc = shissuChat["url"],
    setFunc = function(_, value)
      shissuChat["url"] = value
    end,
  } 
  
  -- Zeitstempel
  controls[#controls+1] = {
    type = "title",
    name = _L("TIMESTAMP"),
  }             

  controls[#controls+1] = {
    type = "checkbox",
    name = _L("TIMESTAMP"),
    tooltip = _L("TIMESTAMP_TT"),
    getFunc = shissuChat["timeStamp"],
    setFunc = function(_, value)
      shissuChat["timeStamp"] = value
    end,
  }
  controls[#controls+1] = {
    type = "textbox",
    name = _L("TIMESTAMP_FORMAT"),
    tooltip = _L("TIMESTAMP_FORMAT_TT"),
    getFunc = shissuChat["timeStampFormat"],
    setFunc = function(value)
      shissuChat["timeStampFormat"] = value
    end,
  }  

  controls[#controls+1] = {
    type = "colorpicker", 
    name = _L("TIME"),
    getFunc = shissuChat["timeColor"], 
    setFunc = function (r, g, b)                                                                                                                                                           
      shissuChat["timeColor"] = {r, g, b}
    end,
  }        
  controls[#controls+1] = {
    type = "colorpicker", 
    name = _L("DATE"),
    getFunc = shissuChat["dateColor"], 
    setFunc = function (r, g, b)                                                                                                                                                           
      shissuChat["dateColor"] = {r, g, b}
    end,
  }         

  controls[#controls+1] = {
    type = "checkbox",
    name = _L("TIMESTAMPNPC"),
    tooltip = _L("TIMESTAMPNPC_TT"),
    getFunc = shissuChat["timeStampNPC"] or false,
    setFunc = function(_, value)
      shissuChat["timeStampNPC"] = value
    end,
  } 
    
  -- Chatfenster
  controls[#controls+1] = {
    type = "title",
    name = _L("WINDOW"),
  }             
  
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("HIDETEXT"),
    tooltip = _L("HIDETEXT_TT"),
    getFunc = shissuChat["hideText"],
    setFunc = function(_, value)
      shissuChat["hideText"] = value
    end,
  } 
  
  local channels = {}

  controls[#controls+1] = {
    type = "checkbox",
    name = _L("CHANNEL"),
    tooltip = _L("CHANNEL_TT"),
    getFunc = shissuChat["startChannel"],
    setFunc = function(_, value)
      shissuChat["startChannel"] = value
    end,
  } 
  
  for chanId = 1, table.getn(CHAT_SYSTEM.channelData) do
    if (CHAT_SYSTEM.channelData[chanId] ~= nil) then
		  table.insert(channels, CHAT_SYSTEM.channelData[chanId].switches)
    end
	end 

  controls[#controls+1] = {
    type = "combobox",
    name = _L("CHANNEL"),
    tooltip = _L("CHANNEL_TT"),
    items = channels,
    getFunc = shissuChat["channel"],
    setFunc = function(_, value)
      shissuChat["channel"] = value
    end,
  }  
    
	local countRegister = {}
  
  if (CHAT_SYSTEM ~= nil) then
    if (CHAT_SYSTEM.primaryContainer ~= nil) then
      for tabId = 1, table.getn(CHAT_SYSTEM.primaryContainer.windows) do
    		table.insert(countRegister, tabId)
    	end
  
      controls[#controls+1] = {
        type = "combobox",
        name = _L("REGISTER"),
        tooltip = _L("REGISTER_TT"),
        items = countRegister,
        getFunc = shissuChat["registerTab"],
        setFunc = function(_, value)
          shissuChat["registerTab"] = value
        end,
      }  
    end
  end
    
  -- Flüstern
  controls[#controls+1] = {
    type = "title",
    name = _L("WHISPER"),
  }   
  
  local sounds = {}
  
  for soundId = 0, table.getn(_sounds)-1 do
		table.insert(sounds, soundId)
  end
  
  controls[#controls+1] = {
    type = "combobox",
    name = _L("SOUND"),
    tooltip = _L("SOUND_TT"),
    items = sounds,
    getFunc = shissuChat["whisperSound"],
    setFunc = function(_, value)
      shissuChat["whisperSound"] = value + 1
      PlaySound(_sounds[value+1])
    end,
  } 
  
  controls[#controls+1] = {
    type = "colorpicker", 
    name = _L("WARNINGCOLOR"),
    tooltip = _L("WARNINGCOLOR"),
    getFunc = shissuChat["whisperInfoColor"], 
    setFunc = function (r, g, b)                                                                                                                                                           
      shissuChat["whisperInfoColor"] = {r, g, b}
    end,
  }         

  -- Gruppe
  controls[#controls+1] = {
    type = "title",
    name = _L("PARTY"),
  } 

  controls[#controls+1] = {
    type = "checkbox",
    name = _L("PARTYSWITCH"),
    tooltip = _L("PARTYSWITCH_TT"),
    getFunc = shissuChat["partySwitch"],
    setFunc = function(_, value)
      shissuChat["partySwitch"] = value
    end,    
  }        
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("PARTYLEAD"),
    tooltip = _L("PARTYLEAD"),
    getFunc = shissuChat["partyLead"],
    setFunc = function(_, value)
      shissuChat["partyLead"] = value
    end,
  }   
  controls[#controls+1] = {
    type = "colorpicker", 
    name = _L("PARTYLEAD"),
    getFunc = shissuChat["partyLeadColor"], 
    setFunc = function (r, g, b)                                                                                                                                                           
      shissuChat["partyLeadColor"] = {r, g, b}
    end,
  }       

  -- Gildeninformationen
  controls[#controls+1] = {
    type = "title",
    name = _L("GUILDINFO"),
  }    

  controls[#controls+1] = {
    type = "checkbox",
    name = _L("GUILDS"),
    getFunc = shissuChat["guild"],
    setFunc = function(_, value)
      shissuChat["guild"] = value
    end,
  }     
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("RANG"),
    getFunc = shissuChat["rank"],
    setFunc = function(_, value)
      shissuChat["rank"] = value
    end,
  }
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("ALLIANCE"),
    getFunc = shissuChat["alliance"],
    setFunc = function(_, value)
      shissuChat["alliance"] = value
    end,
  }  
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("LEVEL"),
    getFunc = shissuChat["level"],
    setFunc = function(_, value)
      shissuChat["level"] = value
    end,
  }                     
  
  controls[#controls+1] = {
    type = "guildCheckbox",
    name = stdColor .. _L("GUILDWHICH"),
    saveVar = shissuChat["info"],
  }   

  -- Automatischer Wechsel
  controls[#controls+1] = {
    type = "title",
    name = _L("AUTO"),
  }
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("WHISPER"),
    getFunc = shissuChat["autoWhisper"],
    setFunc = function(_, value)
      shissuChat["autoWhisper"] = value
    end,
  }
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("PARTY"),
    getFunc = shissuChat["autoGroup"],
    setFunc = function(_, value)
      shissuChat["autoGroup"] = value
    end,
  } 
  controls[#controls+1] = {
    type = "checkbox",
    name = "Zone",
    getFunc = shissuChat["autoZone"],
    setFunc = function(_, value)
      shissuChat["autoZone"] = value 
    end,
  }   

  controls[#controls+1] = {
    type = "guildCheckbox",
    name = stdColor .. _L("GUILDCHAN"),
    saveVar = shissuChat["auto"],
  }     

  controls[#controls+1] = {
    type = "title",
    name = _L("GUILDNAMES_1"),
  }
  
   controls[#controls+1] = {
    type = "description",
    text = stdColor .. _L("GUILDNAMES_2"),
  }   
  
  local numGuild = GetNumGuilds()
  
  controls[#controls+1] = {
    type = "colorpicker", 
    name = _L("COLOR2"),
    getFunc = shissuChat["namesColor"], 
    setFunc = function (r, g, b)                                                                                                                                                           
      shissuChat["namesColor"] = {r, g, b}
    end,
  } 

  -- Gildenbezeichnung
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("USEGUILDCOLORS"),
    tooltip = _L("USEGUILDCOLORS_TT"),
    getFunc = shissuChat["stdGuildColor"],
    setFunc = function(_, value)
      shissuChat["stdGuildColor"] = value
    end,
  }

  for guildId=1, GetNumGuilds() do
    local gId = GetGuildId(guildId)
    local guildName = GetGuildName(gId) 
    
    controls[#controls+1] = {
      type = "textbox",
      name = guildName,
      tooltip = shissuChat["names"][guildName] or guildName,
      getFunc = shissuChat["names"][guildName] or guildName,      
      setFunc = function(value, name)
        shissuChat["names"][name] = value
      end,
    }    
  end 
end

function _addon.createGuildVars(saveVar, value)
  if shissuChat[saveVar] == nil then shissuChat[saveVar] = {} end
  
  if shissuChat[saveVar] ~= nil then  
    local numGuild = GetNumGuilds()
    
    for guildId=1, numGuild do
      local guildId = GetGuildId(guildId)
      local guildName = GetGuildName(GetGuildId(guildId))  
      
      if shissuChat[saveVar][guildName] == nil then shissuChat[saveVar][guildName] = value end
    end
  end
end 

function _addon.createNewVar(saveVar, value)
  if shissuChat[saveVar] == nil then shissuChat[saveVar] = value end
end
 
 
function _addon.initNewVariables()
  _addon.createGuildVars("auto", true)
  _addon.createGuildVars("info", true)
  
  if shissuChat["names"] == nil then shissuChat["names"] = {} end
  
  _addon.createNewVar("hideText", true)
  _addon.createNewVar("brackets", true)
  _addon.createNewVar("nameFormat", 3)
  _addon.createNewVar("registerTab", 1)
  _addon.createNewVar("channel", "/zone")
  _addon.createNewVar("url", true)
  _addon.createNewVar("partySwitch",true)                                  
  _addon.createNewVar("partyLead", true)
  _addon.createNewVar("whisperSound", 2)
  _addon.createNewVar("partyLeadColor", {1, 1, 1, 1})
  _addon.createNewVar("whisperInfoColor", {0.50196081399918, 0.80000001192093, 1, 1})
  _addon.createNewVar("timeStamp", true)
  _addon.createNewVar("timeStampFormat", "DD.MM.Y HH:m:s")
  _addon.createNewVar("timeColor", {0.50196081399918, 0.80000001192093, 1, 1})
  _addon.createNewVar("dateColor", {0.8901960849762, 0.93333333730698, 1, 1})
  _addon.createNewVar("nameFormatColor", {0.8901960849762, 0.93333333730698, 1, 1})
  _addon.createNewVar("namesColor", {0.50196081399918, 0.80000001192093, 1, 1})
  _addon.createNewVar("autoWhisper", true)
  _addon.createNewVar("autoGroup", true)
  _addon.createNewVar("autoZone", true)
  _addon.createNewVar("level", true)
  _addon.createNewVar("alliance", true)
  _addon.createNewVar("rank", true)
  _addon.createNewVar("guild", true) 
  _addon.createNewVar("startChannel", true) 
  _addon.createNewVar("nameFormatColored", true) 
  _addon.createNewVar("stdGuildColor", true) 
end

function _addon.initialized()
  local registerEventChatMessage = ShissuFramework["functions"]["chat"].registerEventChatMessage

  --d(_addon.formattedName .. " " .. _addon.Version)
    
  _addon.initNewVariables()  
  _addon.createSettingMenu()
  
  _addon.zoneName = nil --GetUnitZone('player')

  registerEventChatMessage(_addon.Name, _addon.core.chatMessageChannel)
  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_PLAYER_ACTIVATED, _addon.core.startModule)

  if (_addon.enabled == false) then
    zo_callLater(function() _addon.core.startModule() end, 1000)  
  end                
end

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end
    
  -- KOPIE / Leeren alter SGT Var
  shissuChat = shissuChat or {}
  
  if shissuChat == {} then
    shissuChat = _addon.settings 
  end 

  zo_callLater(function()               
    ShissuFramework._settings[_addon.Name] = {}
    ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
    ShissuFramework._settings[_addon.Name].controls = _addon.controls  

    ShissuFramework.initAddon(_addon.Name, _addon.initialized)
  end, 150) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)