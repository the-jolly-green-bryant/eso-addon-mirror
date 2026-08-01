-------------------
--[Constant Part]--
-------------------

local addonTitle = "ChatClassCP"
local addonVersion = "0.4"
local addonAuthor = "@MelanAster"

local CLASS_ICON = {
  [1]   = "|t24:24:esoui/art/icons/class/class_dragonknight.dds|t", --DragonKnight
  [2]   = "|t24:24:esoui/art/icons/class/class_sorcerer.dds|t",     --Sorcerer
  [3]   = "|t24:24:esoui/art/icons/class/class_nightblade.dds|t",   --NightBlade
  [4]   = "|t24:24:esoui/art/icons/class/class_warden.dds|t",       --Warden
  [5]   = "|t24:24:esoui/art/icons/class/class_necromancer.dds|t",  --Necromancer
  [6]   = "|t24:24:esoui/art/icons/class/class_templar.dds|t",      --Templar
  [117] = "|t24:24:esoui/art/icons/class/class_arcanist.dds|t",     --Arcanist
}

local CHANNEL_INFO = {
  {CHAT_CHANNEL_SAY,             SI_CHATCHANNELCATEGORIES1,  false},  --发言
  {CHAT_CHANNEL_YELL,            SI_CHATCHANNELCATEGORIES2,  false},  --吆喝
  {CHAT_CHANNEL_PARTY,           SI_CHATCHANNELCATEGORIES7,  true},   --队伍
  {CHAT_CHANNEL_WHISPER,         SI_CHATCHANNELCATEGORIES3,  true},   --接收的私聊
  {CHAT_CHANNEL_WHISPER_SENT,    SI_CHATCHANNELCATEGORIES4,  false},  --发送的私聊
  " ",
  {CHAT_CHANNEL_GUILD_1,         SI_CHATCHANNELCATEGORIES10, true},   --公会1
  {CHAT_CHANNEL_GUILD_2,         SI_CHATCHANNELCATEGORIES11, true},   --公会2
  {CHAT_CHANNEL_GUILD_3,         SI_CHATCHANNELCATEGORIES12, true},   --公会3
  {CHAT_CHANNEL_GUILD_4,         SI_CHATCHANNELCATEGORIES13, true},   --公会4
  {CHAT_CHANNEL_GUILD_5,         SI_CHATCHANNELCATEGORIES14, true},   --公会5
  " ",
  {CHAT_CHANNEL_OFFICER_1,       SI_CHATCHANNELCATEGORIES15, true},   --公会管理员1
  {CHAT_CHANNEL_OFFICER_2,       SI_CHATCHANNELCATEGORIES16, true},   --公会管理员2
  {CHAT_CHANNEL_OFFICER_3,       SI_CHATCHANNELCATEGORIES17, true},   --公会管理员3
  {CHAT_CHANNEL_OFFICER_4,       SI_CHATCHANNELCATEGORIES18, true},   --公会管理员4
  {CHAT_CHANNEL_OFFICER_5,       SI_CHATCHANNELCATEGORIES19, true},   --公会管理员5
  " ",
  {CHAT_CHANNEL_ZONE,            SI_CHATCHANNELCATEGORIES6,  false},  --区域
  {CHAT_CHANNEL_ZONE_LANGUAGE_1, SI_CHATCHANNELCATEGORIES20, false},  --区域-英语
  {CHAT_CHANNEL_ZONE_LANGUAGE_2, SI_CHATCHANNELCATEGORIES21, false},  --区域-法语
  {CHAT_CHANNEL_ZONE_LANGUAGE_3, SI_CHATCHANNELCATEGORIES22, false},  --区域-德语
  {CHAT_CHANNEL_ZONE_LANGUAGE_4, SI_CHATCHANNELCATEGORIES23, false},  --区域-日语
  {CHAT_CHANNEL_ZONE_LANGUAGE_5, SI_CHATCHANNELCATEGORIES24, false},  --区域-俄语
  {CHAT_CHANNEL_ZONE_LANGUAGE_6, SI_CHATCHANNELCATEGORIES25, false},  --区域-西班牙语
  {CHAT_CHANNEL_ZONE_LANGUAGE_7, SI_CHATCHANNELCATEGORIES26, false},  --区域-中文
}

local STYLE_OFF, STYLE_SIMPLE, STYLE_DETAIL = 0, 1, 2

local defaultSetting = {
  --Account/Character setting
  ["CV"] = false,
  
  --Source
  ["guildList"] = true,
  ["friendList"] = false,
  ["groupList"] = false,
  
  --Formatter
  ["classIcon"] = true,
  ["cpFormatter"] = STYLE_SIMPLE,
  ["levelFormatter"] = STYLE_SIMPLE,
  
  --Channel list
  ["enabledChannels"] = {--[[
    [CHAT_CHANNEL_GUILD_1] = true,
    ...
  ]]}, 
}

---------------
--[Menu Part]--
---------------

local aV, cV, sV = {}, {}, {}

local function SwitchSV()
  --Switch between account and character setting
  if cV["CV"] then
    sV = cV
  else
    sV = aV
  end
  --Apply default setting
  if sV["enabledChannels"][CHAT_CHANNEL_SAY] == nil then
    for k, v in ipairs(CHANNEL_INFO) do
      if v ~= " " then sV["enabledChannels"][v[1]] = v[3] end
    end
  end
end

local function AddChannelSettings(options)
  local option = {
    type = "submenu", 
    name = GetString(SI_CHATCHANNELCATEGORYHEADERS1),
    controls = {},
  }
  
  for k, v in ipairs(CHANNEL_INFO) do
    if v == " " then
      table.insert(option.controls, {type = "divider"})
    else
      local control = {
        type = "checkbox",
        name = GetString(v[2]),
        getFunc = function() return sV["enabledChannels"][v[1]] end,
        setFunc = function(var) sV["enabledChannels"][v[1]] = var end,
        width = "full",
      }
      table.insert(option.controls, control)
    end
  end
  
  table.insert(options, option)
  return options
end

local function BuildMenu()
  local LAM = LibAddonMenu2
  local panelData = {
    type = "panel",
    name = addonTitle,
    displayName = addonTitle,
    author = addonAuthor,
    version = addonVersion,
    registerForRefresh = true,
  }
  LAM:RegisterAddonPanel(addonTitle.."_Options", panelData)
  
  local options = {
    { --Account/Character setting
      type = "checkbox",
      name = GetString(SI_ADDON_MANAGER_CHARACTER_SELECT_LABEL)..GetString(SI_CURRENCYLOCATION3).." / "..GetString(SI_CURRENCYLOCATION0),
      tooltip = GetString(SI_CHECK_BUTTON_OFF)..": "..GetString(SI_CURRENCYLOCATION3).."\r\n"..GetString(SI_CHECK_BUTTON_ON)..": "..GetString(SI_CURRENCYLOCATION0),
      getFunc = function() return cV["CV"] end,
      setFunc = function(var)
        cV["CV"] = var
        SwitchSV()
      end,
      width = "full",
    },
    { --Source
      type = "submenu", 
      name = GetString(SI_GAMEPAD_CONSOLE_WAIT_FOR_CONSOLE_CHARACTER_INFO_TITLE),
      controls = {
        { --Guild
          type = "checkbox",
          name = GetString(SI_MAIN_MENU_GUILDS),
          getFunc = function() return sV["guildList"] end,
          setFunc = function(var) sV["guildList"] = var end,
          width = "full",
        },
        { --Friend
          type = "checkbox",
          name = GetString(SI_MAIN_MENU_CONTACTS),
          getFunc = function() return sV["friendList"] end,
          setFunc = function(var) sV["friendList"] = var  end,
          width = "full",
        },
        { --Group
          type = "checkbox",
          name = GetString(SI_MAIN_MENU_GROUP),
          getFunc = function() return sV["groupList"] end,
          setFunc = function(var) sV["groupList"] = var  end,
          width = "full",
        },
      },
    },
    { --Formatter
      type = "submenu", 
      name = GetString(SI_GUILD_HERALDRY_STYLE),
      controls = {
        { --Class icon
          type = "checkbox",
          name = GetString(SI_COLLECTIBLERESTRICTIONTYPE3),
          getFunc = function() return sV["classIcon"] end,
          setFunc = function(var) sV["classIcon"] = var end,
          width = "full",
        },
        { --Level
          type = "dropdown",
          name = GetString(SI_CAMPAIGNLEVELREQUIREMENTTYPE1), 
          choices = {GetString(SI_CHECK_BUTTON_OFF), "v1, v10", "Lv01, Lv10"},
          choicesValues = {STYLE_OFF, STYLE_SIMPLE, STYLE_DETAIL},
          getFunc = function() return sV["levelFormatter"] end,
          setFunc = function(var) sV["levelFormatter"] = var  end,
          scrollable = true,
          width = "full",
        },
        { --CP
          type = "dropdown",
          name = GetString(SI_CAMPAIGNLEVELREQUIREMENTTYPE2), 
          choices = {GetString(SI_CHECK_BUTTON_OFF), "1, 10, 100, 1000", "0001, 0010, 0100, 1000"},
          choicesValues = {STYLE_OFF, STYLE_SIMPLE, STYLE_DETAIL},
          getFunc = function() return sV["cpFormatter"] end,
          setFunc = function(var) sV["cpFormatter"] = var  end,
          scrollable = true,
          width = "full",
        },
      },
    },
  }
  options = AddChannelSettings(options)
  LAM:RegisterOptionControls(addonTitle.."_Options", options)
end

local function OnAddOnLoaded(eventCode, addonName)
  --When CCC loaded
  if addonName ~= addonTitle then return end
  EVENT_MANAGER:UnregisterForEvent(addonTitle, EVENT_ADD_ON_LOADED)
  
  --Saved setting
  aV = ZO_SavedVars:NewAccountWide("ChatClassCP_SaveVars", 1, nil, defaultSetting, GetWorldName())
  cV = ZO_SavedVars:NewCharacterIdSettings("ChatClassCP_SaveVars", 1, nil, defaultSetting, GetWorldName())
  SwitchSV()
  
  --Build menu
  BuildMenu()
end

---------------
--[Core Part]--
---------------

local playerCache = {--[[
  {
    displayName = ,
    timeStamp = ,
    classType = ,
    championRank = ,
    level = ,
  },
  ...
]]}

local function UpdatePlayerCache(classType, level, championRank, displayName)
  local nowTimeStamp = GetTimeStamp()
  
  playerCache[displayName] = {
    ["playerName"] = displayName,
    ["timeStamp"] = nowTimeStamp,
    ["classType"] = classType,
    ["championRank"] = championRank,
    ["level"] = level,
  }
end
  
local function GetPlayerCache(displayName)
  if playerCache[displayName] then
    local nowTimeStamp = GetTimeStamp()
    local lastTimeStamp = playerCache[displayName]["timeStamp"]
    if nowTimeStamp - lastTimeStamp < 10 then
      return playerCache[displayName]
    end
  end
  return nil
end

local function InsertModify(message, modify)
  --DisplayName
  local firstDisplayIndice = string.find(message, ":display:")
  if firstDisplayIndice then
    local pre = string.sub(message, 0, math.max(0, firstDisplayIndice - 4))
    local tail = string.sub(message, firstDisplayIndice - 3)
    message = pre..modify..tail
    return message
  end
  
  --CharacterName
  local firstCharacterIndice = string.find(message, ":character:")
  if firstCharacterIndice then
    local pre = string.sub(message, 0, math.max(0, firstCharacterIndice - 4))
    local tail = string.sub(message, firstCharacterIndice - 3)
    message = pre..modify..tail
  end
  
  return message
end

local function BuildModify(message, classType, level, championRank, displayName)
  --Add cache
  UpdatePlayerCache(classType, level, championRank, displayName)
  
  --Concat string
  local classPart = sV["classIcon"] and CLASS_ICON[classType] or ""
  local levelPart = ""
  
  if championRank > 0 then
    if sV["cpFormatter"] == STYLE_OFF then levelPart = "" end
    if sV["cpFormatter"] == STYLE_SIMPLE then levelPart = tostring(championRank) end
    if sV["cpFormatter"] == STYLE_DETAIL then levelPart = string.format("%04d", championRank) end
  else
    if sV["levelFormatter"] == STYLE_OFF then levelPart = "" end
    if sV["levelFormatter"] == STYLE_SIMPLE then levelPart = "v"..tostring(level) end
    if sV["levelFormatter"] == STYLE_DETAIL then levelPart = "Lv"..string.format("%02d", level) end
  end
  
  local modify = "["..classPart..levelPart.."] "
  return InsertModify(message, modify)
end

local function newChatFormatter(message, ...)
  --Debug
  --StartChatInput(messageTextOfOriginal)
  
  --Sender display name
  local channelID, from, text, isCustomerService, displayName = ...
  --Enabled channel?
  if not sV["enabledChannels"][channelID] then return message end

  --Already in Cache?
  local cacheInfo = GetPlayerCache(displayName)
  if cacheInfo then
    local classType = cacheInfo["classType"]
    local level = cacheInfo["level"]
    local championRank = cacheInfo["championRank"]
    --d("from cache")
    return BuildModify(message, classType, level, championRank, displayName)
  end
  
  --Try get info from guild
  if sV["guildList"] then
    for i = 1, GetNumGuilds() do
      local guildId = GetGuildId(i)
      local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, displayName)
      if memberIndex then
        local hasCharacter, characterName, zoneName, classType, alliance, level, championRank, zoneId, consoleId = GetGuildMemberCharacterInfo(guildId, memberIndex)
        --d("from guild list")
        return BuildModify(message, classType, level, championRank, displayName)
      end
    end
  end
  
  --Try get info from friend
  if sV["friendList"] then
    for i = 1, GetNumFriends() do
      local friendDisplayName = GetFriendInfo(i)
      if friendDisplayName == displayName then
        local hasCharacter, characterName, zoneName, classType, alliance, level, championRank, zoneId, consoleId = GetFriendCharacterInfo(i)
        --d("from friend list")
        return BuildModify(message, classType, level, championRank, displayName)
      end
    end
  end

  --Try get info from group
  if sV["groupList"] then
    for i = 1, GetGroupSize() do
      local unitTag = GetGroupUnitTagByIndex(i)
      local groupDisplayName = GetUnitDisplayName(unitTag)
      if groupDisplayName == displayName then
        local classType = GetUnitClassId(unitTag)
        local level = GetUnitLevel(unitTag)
        local championRank = GetUnitChampionPoints(unitTag)
        --d("from group list")
        return BuildModify(message, classType, level, championRank, displayName)
      end
    end
  end
  
  --Not found
  return message
end

local function OnPlayerActivated()
  if pChat then
    local formatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
    local originalpChatFormatter = formatters[EVENT_CHAT_MESSAGE_CHANNEL]
    if originalpChatFormatter then
      CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, 
        function(...)
          local message = originalpChatFormatter(...)
          return newChatFormatter(message, ...)
        end
      )
    end
  end
end

-----------------
--[Start Point]--
-----------------

ZO_PostHook(pChat, "InitializeChatHandlers", OnPlayerActivated) 
EVENT_MANAGER:RegisterForEvent(addonTitle, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
