-- Shissu Guild Tools Addon
-- ShissuNotifications
--
-- Version: v2.2.1
-- Last Update: 05.12.2020
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local yellow = _globals["yellow"]
local red = _globals["red"]

local cutStringAtLetter = ShissuFramework["functions"]["datatypes"].cutStringAtLetter
local setPanel = ShissuFramework["setPanel"]

local _addon = {}
_addon.Name	= "ShissuNotifications"
_addon.Version = "2.2.1.8"
_addon.lastUpdate = "06.12.2020"

_addon.formattedName	= stdColor .. "Shissu" .. white .. "'s Notifications"            

_addon.settings = {
  ["guildRank"] = true,
  ["guildJoined"] = true,
  ["guildKicked"] = true,
  ["memberNote"] = false,
  ["mail"] = false,
  ["memberRank"] = true,
  ["inSight"] = {},
  ["motD"] = {}, 
  ["background"] = {},
}

local _L = ShissuFramework["func"]._L(_addon.Name)

_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version, _addon.lastUpdate)
_addon.controls = {}
  
local fString = {
  ["mail"] = stdColor .. _L("INFO") .. "|r " .. _L("MAIL"),
  ["inSight"] = stdColor .. _L("INFO") .. "|r " .. _L("INSIGHT"),
  ["motD"] = stdColor .. _L("INFO") .. "|r " .. _L("MOTD"),
  ["friend"] = stdColor .. _L("INFO") .. "|r " .. _L("FRIEND"),
  ["background"] = stdColor .. _L("INFO") .. "|r " .. _L("BACKGROUND"),
}  

local libNotification = {}  -- ZO_NotificationProvider:Subclass()

local KEYBOARD_NOTIFICATION_ICONS = {
  [NOTIFICATION_TYPE_FRIEND] = "EsoUI/Art/Notifications/notificationIcon_friend.dds",
  [NOTIFICATION_TYPE_GUILD] = "EsoUI/Art/Notifications/notificationIcon_guild.dds",
  [NOTIFICATION_TYPE_GUILD_MOTD] = "EsoUI/Art/Notifications/notificationIcon_guild.dds",
  [NOTIFICATION_TYPE_CAMPAIGN_QUEUE] = "EsoUI/Art/Notifications/notificationIcon_campaignQueue.dds",
  [NOTIFICATION_TYPE_RESURRECT] = "EsoUI/Art/Notifications/notificationIcon_resurrect.dds",
  [NOTIFICATION_TYPE_GROUP] = "EsoUI/Art/Notifications/notificationIcon_group.dds",
  [NOTIFICATION_TYPE_TRADE] = "EsoUI/Art/Notifications/notificationIcon_trade.dds",
  [NOTIFICATION_TYPE_QUEST_SHARE] = "EsoUI/Art/Notifications/notificationIcon_quest.dds",
  [NOTIFICATION_TYPE_PLEDGE_OF_MARA] = "EsoUI/Art/Notifications/notificationIcon_mara.dds",
  [NOTIFICATION_TYPE_CUSTOMER_SERVICE] = "EsoUI/Art/Notifications/notification_cs.dds",
  [NOTIFICATION_TYPE_LEADERBOARD] = "EsoUI/Art/Notifications/notificationIcon_leaderboard.dds",
  [NOTIFICATION_TYPE_COLLECTIONS] = "EsoUI/Art/Notifications/notificationIcon_collections.dds",
  [NOTIFICATION_TYPE_LFG] = "EsoUI/Art/Notifications/notificationIcon_group.dds",
  [NOTIFICATION_TYPE_POINTS_RESET] = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_character.dds",
  [NOTIFICATION_TYPE_CRAFT_BAG_AUTO_TRANSFER] = "EsoUI/Art/Notifications/notificationIcon_autoTransfer.dds",
  [NOTIFICATION_TYPE_GROUP_ELECTION] = "EsoUI/Art/Notifications/notificationIcon_autoTransfer.dds",
}

function NOTIFICATIONS:SetupBaseRow(control, data)
  ZO_SortFilterList.SetupRow(self.sortFilterList, control, data)

  local notificationType = data.notificationType
  local texture          = data.texture or KEYBOARD_NOTIFICATION_ICONS[notificationType]
  local headingText      = data.heading or zo_strformat(SI_NOTIFICATIONS_TYPE_FORMATTER, GetString("SI_NOTIFICATIONTYPE", notificationType))

  control.notificationType = notificationType
  control.index            = data.index

  GetControl(control, "Icon"):SetTexture(texture)
  GetControl(control, "Type"):SetText(headingText)
end

local libNotificationProvider = ZO_NotificationProvider:Subclass()

function libNotificationProvider:New(notificationManager)
  local provider = ZO_NotificationProvider.New(self, notificationManager)
  table.insert(notificationManager.providers, provider)

  return provider
end

function libNotificationProvider:BuildNotificationList()
  ZO_ClearNumericallyIndexedTable(self.list)

  local notifications = self.providerLinkTable.notifications
  self.list = ZO_DeepTableCopy(notifications)
end

local libNotificationKeyboardProvider = libNotificationProvider:Subclass()

function libNotificationKeyboardProvider:New(notificationManager)
  local keyboardProvider = libNotificationProvider.New(self, notificationManager)

  return keyboardProvider
end

function libNotificationKeyboardProvider:Accept(data)
  if data.keyboardAcceptCallback then
    data.keyboardAcceptCallback(data)
  end
end

function libNotificationKeyboardProvider:Decline(data, button, openedFromKeybind)
  if data == nil then return end
  
  local notifId = data.notificationId
  
  activeNotifications.notifications[notifId] = nil
  activeNotifications.UpdateNotifications()
end

function libNotification.CreateProvider()
  local keyboardProvider = libNotificationKeyboardProvider:New(NOTIFICATIONS)

  local provider = {
    notifications       = {},
    keyboardProvider    = keyboardProvider,
    UpdateNotifications = function()
      -- anpassen!
      keyboardProvider:pushUpdateCallback()
     -- activeNotifications.UpdateNotifications()
    end,
  }
  
  keyboardProvider.providerLinkTable = provider

  return provider
end
  
function _addon.createControls()
  local controls = _addon.controls 
  
  controls[#controls+1] = {
    type = "title",
    name = _L("GENERAL"),
  }
       
  controls[#controls+1] = {
    type = "checkbox", 
    name = fString["mail"],
    getFunc = shissuNotifications["mail"],
    setFunc = function(_, value)
      shissuNotifications["mail"] = value
      
      if (not value) then 
        MAIL_INBOX.Delete = _addon.mailInBoxDelete
      end
    end,
  }
    
  controls[#controls+1] = {
    type = "checkbox", 
    name = fString["friend"],
    getFunc = shissuNotifications["friend"],
    setFunc = function(_, value)
      shissuNotifications["friend"] = value
      
      if (not value) then 
        _addon.deactiveFriendStatus() 
      end
    end,
  }
  
  controls[#controls+1] = {
    type = "title",
    name = _L("OWN"),
  }  
  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("RANKCHANGE2"),
    getFunc = shissuNotifications["guildRank"],
    setFunc = function(_, value)
      shissuNotifications["guildRank"] = value
    end,
  }
  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("JOINGUILD2"),
    getFunc = shissuNotifications["guildJoined"],
    setFunc = function(_, value)
      shissuNotifications["guildJoined"] = value
    end,
  }
  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("LEFTGUILD2"),
    getFunc = shissuNotifications["guildKicked"],
    setFunc = function(_, value)
      shissuNotifications["guildKicked"] = value
    end,
  }    

  controls[#controls+1] = {
    type = "title",
    name = _L("GUILD"),
  }  
  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("RANKCHANGE2"),
    getFunc = shissuNotifications["memberRank"],
    setFunc = function(_, value)
      shissuNotifications["memberRank"] = value
    end,
  }      
  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("NOTECHANGE2"),
    getFunc = shissuNotifications["memberNote"],
    setFunc = function(_, value)
      shissuNotifications["memberNote"] = value
    end,
  }        
  controls[#controls+1] = {
    type = "title",
    name = fString["inSight"],     
  }

  controls[#controls+1] = {
    type = "guildCheckbox",
    saveVar = shissuNotifications["inSight"],
  }     

  controls[#controls+1] = {
    type = "title",
    name = fString["motD"],     
  }

  controls[#controls+1] = {
    type = "guildCheckbox",
    saveVar = shissuNotifications["motD"],
  }     
  
  controls[#controls+1] = {
    type = "title",
    name = fString["background"],     
  }

  controls[#controls+1] = {
    type = "guildCheckbox",
    saveVar = shissuNotifications["background"],
  }         
end

-- Mail Benachrichtigungen
-- Original ZOS LUA Code + Modifikation: esoui\ingame\mail\keyboard\mailinbox_keyboard.lua, Version 08.03.2017
function _addon.mailInBoxDelete(self)
  if self.mailId then
    if self:IsMailDeletable() then
      local numAttachments, attachedMoney = GetMailAttachmentInfo(self.mailId)
      
      if numAttachments > 0 and attachedMoney > 0 then
        ZO_Dialogs_ShowDialog("DELETE_MAIL_ATTACHMENTS_AND_MONEY", self.mailId)
      elseif numAttachments > 0 then
        ZO_Dialogs_ShowDialog("DELETE_MAIL_ATTACHMENTS", self.mailId)
      elseif attachedMoney > 0 then
        ZO_Dialogs_ShowDialog("DELETE_MAIL_MONEY", self.mailId)
      else
        if shissuNotifications["mail"] then
          ZO_Dialogs_ShowDialog("DELETE_MAIL", {callback = function(...) self:ConfirmDelete(...) end, mailId = self.mailId})
        else
          self:ConfirmDelete(self.mailId) 
        end
      end
    end
  end  
end

function _addon.deactiveFriendStatus() 
  ZO_PreHook(ZO_ChatSystem_GetEventHandlers(), EVENT_FRIEND_PLAYER_STATUS_CHANGED, function() return true end )
  EVENT_MANAGER:UnregisterForEvent( "FriendsList", EVENT_FRIEND_PLAYER_STATUS_CHANGE)
end      

-- GuildMoTD deaktivieren
-- Original ZOS LUA Code + Modifikation: notifications_common.lua, Version Morrowind, 24.06.2017
function ZO_GuildMotDProvider:BuildNotificationList()
  if self.sv then
    ZO_ClearNumericallyIndexedTable(self.list)

    for i = 1, GetNumGuilds() do
      local guildId = GetGuildId(i)
      local guildName = GetGuildName(guildId)
      
      if shissuNotifications ~= nil then 
      if shissuNotifications["motD"] ~= nil then
        if shissuNotifications["motD"][guildName] == true then
          local savedMotDHash = self.sv[guildName]
          local currentMotD = GetGuildMotD(guildId)
          local currentMotDHash = HashString(currentMotD)
    
          if savedMotDHash == nil then
            self.sv[guildName] = currentMotDHash
          elseif savedMotDHash ~= currentMotDHash then
            local guildAlliance = GetGuildAlliance(guildId)
            local message = self:CreateMessage(guildAlliance, guildName)
            table.insert(self.list,
            {
              dataType = NOTIFICATIONS_ALERT_DATA,
              notificationType = NOTIFICATION_TYPE_GUILD_MOTD,
              secsSinceRequest = ZO_NormalizeSecondsSince(0),
              note = currentMotD,
              message = message,
              guildId = guildId,
              shortDisplayText = guildName,
            })
          end
        end
        end
      end
    end
  end
end

-- EVENT_GUILD_DESCRIPTION_CHANGED (integer eventCode, integer guildId) 
function _addon.guildDescriptionChanged(_, guildId)
  local guildName = GetGuildName(guildId)
  local guildDescription = GetGuildDescription(guildId)
  local guildAlliance = GetGuildAlliance(guildId)
  local allianceIcon = zo_iconFormat(GetAllianceBannerIcon(guildAlliance), 24, 24)
  
  if ( shissuNotifications["background"] ) then
    if ( shissuNotifications["background"][guildName] == true) then
      _addon.createNotif(
        GetString(SI_GUILD_DESCRIPTION_HEADER),
        zo_strformat(_L("BACKGROUND2"), allianceIcon, guildName),
        guildDescription
      )
    end
  end
end

function _addon.allowForInSight()
  for guildName, guildData in pairs(shissuNotifications["inSight"]) do 
    if ( guildData == true ) then
      return true
    end   
  end
  
  return false
end

function _addon.memberInSight(_, name)
  local target = GetUnitName('reticleover')
  local unitName = GetRawUnitName('reticleover')

  ZO_Tooltips_HideTextTooltip()
  
  if unitName ~= "" and _SGTguildMemberList[unitName] then   
    local count = 0
    local memberData = _SGTguildMemberList[unitName]
    
    if ( memberData ~= nil ) then                                                         
      local _, _, _, class, alliance, lvl, champ = GetGuildMemberCharacterInfo( memberData["gid"], memberData["id"])
      local text = GetGuildMemberInfo(memberData["gid"], memberData["id"])

      local acc = text
      local charName = cutStringAtLetter(unitName, '^')

      if (class ~= nil and alliance ~= nil) then
        local class = "|t28:28:" .. GetClassIcon(class) .. "|t"
        local alliance = "|t28:28:" .. GetAllianceBannerIcon(alliance) .. "|t"
   
        text = stdColor .. acc .. "\n"
        text = text .. alliance .. class .. "|ceeeeee" .. charName
  
        if champ == 0 then
          text = text .. " |ceeeeee(|cAFD3FFLvL " .. "|ceeeeee" .. lvl .. ")"
        else
          text = text .. " |ceeeeee(|cAFD3FFCP " .. "|ceeeeee" .. champ .. ")"
        end
        
        if ( _addon.allowForInSight() == true ) then   
          memberData = memberData["guilds"]                        
          
          local first = 0

          if (shissuNotifications["inSight"] == nil) then return false end

          for saveId, guildData in pairs(memberData) do 
            local guildName = guildData[1]

            if (shissuNotifications["inSight"][guildName] == nil) then return false end
            if (shissuNotifications["inSight"][guildName] == true ) then
              count = count + 1
                  
              if (first == 0) then
                first = 1
                text = text .. "\n"
              end
  
              text = text .. "\n|ceeeeee" .. guildName
            end 
          end
        end
  
        if (count > 0 ) then
          ZO_Tooltips_ShowTextTooltip(SGT_notificationsInSight, TOPRIGHT, text)
        end
      end
    end
  end
end    

function _addon.memberRankChanged(_, guildId, displayName, rankIndex)
  local guildName = GetGuildName(guildId)
  local guildAlliance = GetGuildAlliance(guildId)
  
  if (GetAllianceBannerIcon(guildAlliance) ~= nil) then
    local allianceIcon = zo_iconFormat(GetAllianceBannerIcon(guildAlliance), 24, 24) 
    local rankName = GetFinalGuildRankName(guildId, rankIndex)
    local rankIcon = zo_iconFormat(GetGuildRankLargeIcon(GetGuildRankIconIndex(guildId, rankIndex)), 24, 24)  
  
    if (allianceIcon ~= nil and guildName ~=nil and rankIcon ~=nil and rankName ~= nil and displayName ~=  nil) then
      if shissuNotifications["guildRank"] == true then 
        if displayName == GetUnitDisplayName("player") then
          _addon.createNotif(
            GetString(SI_GAMEPAD_GUILD_ROSTER_RANK_HEADER),
            zo_strformat(_L("RANKCHANGE"), allianceIcon, guildName, rankIcon, rankName)  
          )
          return
        end
      end
      
      if shissuNotifications["memberRank"] == true then
        _addon.createNotif(
          displayName,
          zo_strformat(_L("RANKCHANGE"), allianceIcon, guildName, rankIcon, rankName)  
        )
      end
    end
  end
end

function _addon.memberNoteChanged(_, guildId, displayName, note)
  local guildName = GetGuildName(guildId)
  
  if shissuNotifications["memberNote"] == true then  
    _addon.createNotif(
      displayName,
      zo_strformat(_L("NOTECHANGE"), guildName),
      note  
    )  
  end
end

function _addon.leftGuild(_, guildId, guildName)
  if shissuNotifications["guildKicked"] == false then return end

  local guildAlliance = GetGuildAlliance(guildId)
  local allianceIcon = zo_iconFormat(GetAllianceBannerIcon(1), 24, 24)
  
  if (allianceIcon ~= nil and guildName ~=nil) then
    _addon.createNotif(
      GetString(SI_GAMEPAD_GUILD_KIOSK_GUILD_LABEL),
      zo_strformat(_L("LEFTGUILD"), allianceIcon, guildName)  
    )
  end
end

function _addon.joinGuild(_, guildId, guildName)
  if shissuNotifications["guildJoined"] == false then return end

  local guildAlliance = GetGuildAlliance(guildId)
  local allianceIcon = zo_iconFormat(GetAllianceBannerIcon(guildAlliance), 24, 24)
  
  if (allianceIcon ~= nil and guildName ~=nil) then  
    _addon.createNotif(
      GetString(SI_GAMEPAD_GUILD_KIOSK_GUILD_LABEL),
      zo_strformat(_L("JOINGUILD"), allianceIcon, guildName)  
    )  
  end
end
                     
function _addon.createNotif(heading, message, note)
	local notificationData = {
		dataType                = NOTIFICATIONS_ALERT_DATA,
		secsSinceRequest        = ZO_NormalizeSecondsSince(0),
		note                    = note, --GetGuildDescription(1),
		message                 = message,
		heading                 = heading,
		texture                 = "esoui/art/notifications/notificationicon_guild.dds",
		controlsOwnSounds       = false,
		keyboardDeclineCallback = deleteCallback,

		notificationId          = #activeNotifications.notifications + 1,
	}

	table.insert(activeNotifications.notifications, notificationData)
	activeNotifications:UpdateNotifications()  
end

-- Speichern des alten Rangs 
-- Überprüfen nach reloadui und co
function _addon.checkRankSinceOffline()
  if (shissuNotifications["ownRank"] == nil) then return end
  if shissuNotifications["guildRank"] == false then return end
  
  for guildId=1, GetNumGuilds() do
local xxguildId = GetGuildId(guildId)
    local guildName = GetGuildName(xxguildId)  
  
    if (shissuNotifications["ownRank"][guildName] ~= nil) then 
      local ownId = GetPlayerGuildMemberIndex(xxguildId)
      local _, _, rankIndex = { GetGuildMemberInfo(xxguildId, ownId) }
  
      if (rankIndex ~=  shissuNotifications["ownRank"][guildName] ) then
        local guildName = GetGuildName(xxguildId)
        local allianceIcon = zo_iconFormat(GetAllianceBannerIcon(xxguildId), 24, 24)
        local rankName = GetFinalGuildRankName(xxguildId, rankIndex)
        local rankIcon = zo_iconFormat(GetGuildRankLargeIcon(GetGuildRankIconIndex(xxguildId, rankIndex)), 24, 24)
                
        _addon.createNotif(
          GetString(SI_GAMEPAD_GUILD_ROSTER_RANK_HEADER),
          zo_strformat(_L("RANKCHANGE"), allianceIcon, guildName, rankIcon, rankName)  
        )
      end
    end
  end  
end
                                          
-- Initialisierung
function _addon.initialized() 
  if (not shissuNotifications.mail) then        
    MAIL_INBOX.Delete = _addon.mailInBoxDelete 
  end

  if (not shissuNotifications.friend) then _addon.deactiveFriendStatus() end

  -- Hat jemand die neue SaveVar schon?  
  if (shissuNotifications["inSight"] == nil) then shissuNotifications["inSight"] = {} end
  if (shissuNotifications["motD"] == nil) then shissuNotifications["motD"] = {} end
  if (shissuNotifications["background"] == nil) then shissuNotifications["background"] = {} end
  if (shissuNotifications["ownRank"] == nil) then shissuNotifications["ownRank"] = {} end
 
  if (shissuNotifications["guildRank"] == nil) then shissuNotifications["guildRank"] = true end
  if (shissuNotifications["guildJoined"] == nil) then shissuNotifications["guildJoined"] = true end
  if (shissuNotifications["guildKicked"] == nil) then shissuNotifications["guildKicked"] = true end
  if (shissuNotifications["memberRank"] == nil) then shissuNotifications["memberRank"] = true end
  if (shissuNotifications["memberNote"] == nil) then shissuNotifications["memberNote"] = false end
    
  for guildId=1, GetNumGuilds() do
    local guildName = GetGuildName(guildId)  
    
    if (shissuNotifications["inSight"][guildName] == nil) then shissuNotifications["inSight"][guildName] = true end
    if (shissuNotifications["motD"][guildName] == nil) then shissuNotifications["motD"][guildName] = true end
    if (shissuNotifications["background"][guildName] == nil) then shissuNotifications["background"][guildName] = true end
    
    if (shissuNotifications["ownRank"][guildName] == nil) then 
      local ownId = GetPlayerGuildMemberIndex(guildId)
      local _, _, rankIndex = { GetGuildMemberInfo(guildId, ownId) }

      shissuNotifications["ownRank"][guildName] = rankIndex 
    end
  end
 
  _addon.createControls()

  activeNotifications = libNotification.CreateProvider()

  _addon.checkRankSinceOffline()

  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GUILD_DESCRIPTION_CHANGED, _addon.guildDescriptionChanged)
  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_RETICLE_TARGET_CHANGED, _addon.memberInSight)
  
  EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_GUILD_MEMBER_RANK_CHANGED, _addon.memberRankChanged)
  EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_GUILD_MEMBER_NOTE_CHANGED, _addon.memberNoteChanged) 
	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_GUILD_SELF_LEFT_GUILD, _addon.leftGuild)
	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_GUILD_SELF_JOINED_GUILD, _addon.joinGuild)   
end 
                     
function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end
  
  -- KOPIE / Leeren alter SGT Var
  shissuNotifications = shissuNotifications or {}
  
  if shissuNotifications == {} then
    shissuNotifications = _addon.settings 
  end 
  -- KOPIE / Leeren alter SGT Var
   
  zo_callLater(function()               
    ShissuFramework._settings[_addon.Name] = {}
    ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
    ShissuFramework._settings[_addon.Name].controls = _addon.controls  

    ShissuFramework.initAddon(_addon.Name, _addon.initialized)
  end, 150) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)