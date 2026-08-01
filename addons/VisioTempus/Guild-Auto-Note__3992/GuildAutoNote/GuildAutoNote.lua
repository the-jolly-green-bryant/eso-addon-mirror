local LAM = LibAddonMenu2

local GAN = {
  name = "GuildAutoNote",
  settingsPanelName = "Guild Auto Note",
  version = "2.0.0",
  author = "VisioTempus",
  isActive = true,
  debugMode = true,
  preventErase = true,
  targetGuildId = 0,
  noteText = "",
  welcomeMsg = "",
  isWelcomeMsgActive = false,
  welcomeMsgNames = "",
  applicationDisplayName = "",
  guildsList = {},
  savedVariables = {},
}

function GAN.Initialize()
  
  GAN.BuildGuildList()

  EVENT_MANAGER:RegisterForEvent(GAN.name, EVENT_GUILD_FINDER_PROCESS_APPLICATION_RESPONSE, GAN.OnGuildApplicationResponse)

  GAN.savedVariables = ZO_SavedVars:NewAccountWide("GANSavedVariables", 1, nil, {})

  GAN.InitSettings()
  
  if GAN.savedVariables.settings.isActive then
    GAN.isActive = GAN.savedVariables.settings.isActive
  end
  if GAN.savedVariables.settings.targetGuildId then
    GAN.targetGuildId = GAN.savedVariables.settings.targetGuildId
  end
  if GAN.savedVariables.settings.noteText then
    GAN.noteText = GAN.savedVariables.settings.noteText
  end
  if GAN.savedVariables.settings.targetGuildId then
    GAN.targetGuildId = GAN.savedVariables.settings.targetGuildId
  end
  if GAN.savedVariables.settings.preventErase then
    GAN.preventErase = GAN.savedVariables.settings.preventErase
  end
  if GAN.savedVariables.settings.welcomeMsg then
    GAN.welcomeMsg = GAN.savedVariables.settings.welcomeMsg
  end
  if GAN.savedVariables.settings.isWelcomeMsgActive then
    GAN.isWelcomeMsgActive = GAN.savedVariables.settings.isWelcomeMsgActive
  end
  if GAN.savedVariables.settings.debugMode then
    GAN.debugMode = GAN.savedVariables.settings.debugMode
  end

  -- Settings panel =============================
  local panelData = { type = "panel", name = GAN.settingsPanelName }
  
  local optionsData = {
    [1] = {
      type = "checkbox",
      name = GetString(SETTINGS_IS_ACTIVE_NAME),
      tooltip = GetString(SETTINGS_IS_ACTIVE_TOOLTIP),
      getFunc = function() return GAN.isActive end,
      setFunc = function(value) 
        GAN.savedVariables.settings.isActive = value
        GAN.isActive = value
      end,
    },
    [2] = {
      type = "dropdown",
      name = GetString(SETTINGS_TARGET_NAME),
      tooltip = GetString(SETTINGS_TARGET_TOOLTIP),
      choices = GAN.GetGuildList(),
      getFunc = function() return GetGuildName(GAN.targetGuildId) end,
      setFunc = function(value) 
        GAN.savedVariables.settings.targetGuildId = GAN.GetGuildIdWithName(value)
        GAN.targetGuildId = GAN.GetGuildIdWithName(value)
      end,
    },
    [3] = {
      type = "editbox",
      name = GetString(SETTINGS_NOTE_NAME),
      isMultiline = true,
      tooltip = GetString(SETTINGS_NOTE_TOOLTIP),
      getFunc = function() return GAN.noteText end,
      setFunc = function(value)
        GAN.noteText = string.format(value)
        GAN.savedVariables.settings.noteText = string.format(value)
      end,
    },
    [4] = {
      type = "checkbox",
      name = GetString(SETTINGS_PREVENT_ERASE_NAME),
      tooltip = GetString(SETTINGS_PREVENT_ERASE_TOOLTIP),
      getFunc = function() return GAN.savedVariables.settings.preventErase end,
      setFunc = function(value)
        GAN.savedVariables.settings.preventErase = value
      end,
    },
    [5] = {
      type = "editbox",
      name = GetString(SETTINGS_WELCOME_MSG_NAME),
      isMultiline = true,
      tooltip = GetString(SETTINGS_WELCOME_MSG_TOOLTIP),
      getFunc = function() return GAN.welcomeMsg end,
      setFunc = function(value)
        GAN.welcomeMsg = string.format(value)
        GAN.savedVariables.settings.welcomeMsg = string.format(value)
      end,
    },
    [6] = {
      type = "checkbox",
      name = GetString(SETTINGS_WELCOME_MSG_ACTIVE_NAME),
      tooltip = GetString(SETTINGS_WELCOME_MSG_ACTIVE_TOOLTIP),
      getFunc = function() return GAN.savedVariables.settings.isWelcomeMsgActive end,
      setFunc = function(value)
        GAN.isWelcomeMsgActive = value
        GAN.savedVariables.settings.isWelcomeMsgActive = value
      end,
    },
    [7] = {
      type = "checkbox",
      name = GetString(SETTINGS_DEBUG_NAME),
      tooltip = GetString(SETTINGS_DEBUG_TOOLTIP),
      getFunc = function() return GAN.savedVariables.settings.debugMode end,
      setFunc = function(value)
        GAN.savedVariables.settings.debugMode = value
      end,
    },
  }
  
  LAM:RegisterAddonPanel(GAN.settingsPanelName, panelData)
  LAM:RegisterOptionControls(GAN.settingsPanelName, optionsData)

end

function GAN.BuildGuildList()
  
  for guildIndex = 1, GetNumGuilds() do
    guildId = tonumber(GetGuildId(guildIndex))
    guildName = GetGuildName(guildId)

    GAN.guildsList[guildIndex] = {guildId, guildName}
  end
  
end

function GAN.GetGuildList()
  
  local list = {}
  
  if not GAN.guildsList then return end
  
  for index, guild in pairs(GAN.guildsList) do
    table.insert(list, guild[2])
  end
  
  return list
  
end

function GAN.GetGuildIdWithName(guildName)
  
  local guildId = 0
  
  if not GAN.guildsList then return end
  
  for index, guild in pairs(GAN.guildsList) do
    if guild[2] == guildName then
      guildId = guild[1]
    end
  end
  
  return guildId
  
end

function GAN.GetGuildIndexWithId(guildId)
  
  local guildIndex = 0
  
  if not GAN.guildsList then return end
  
  for index, guild in pairs(GAN.guildsList) do
    if guild[1] == guildId then
      guildIndex = index
    end
  end
  
  return guildIndex
  
end

-- applicationResponse == 0 (GUILD_PROCESS_APP_RESPONSE_APPLICATION_PROCESSED_ACCEPT)
-- when member is accepted successfully.
function GAN.OnGuildApplicationResponse(eventCode, guildId, displayName, applicationResponse)

	if applicationResponse == GUILD_PROCESS_APP_RESPONSE_APPLICATION_PROCESSED_ACCEPT then
	  GAN.updateNote(guildId, displayName)
	end

end

function GAN.updateNote(guildId, displayName) 

  if guildId ~= GAN.targetGuildId then return end

  GAN.debugMessage(GetString(LOG_NEW_MEMBER) .. displayName)
  
  for memberIndex = 1, GetNumGuildMembers(GAN.targetGuildId) do
    
    local memberName, memberNote, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(GAN.targetGuildId, memberIndex)
    
    if memberName == displayName then
    
      local noteDate = tostring(os.date("%d/%m/%Y"))
      local headerNote = noteDate .. " - " .. GetDisplayName() .. "\n"
      
      if (memberNote == "" or not GAN.savedVariables.settings.preventErase) then
        zo_callLater(function()
          SetGuildMemberNote(GAN.targetGuildId, memberIndex, headerNote .. string.format(GAN.noteText))
          GAN.debugMessage(GetString(LOG_ADDED_NOTE) .. GAN.noteText)
        end, 1500)
      else
        zo_callLater(function()
          SetGuildMemberNote(GAN.targetGuildId, memberIndex, memberNote .. "\n" .. headerNote .. string.format(GAN.noteText))
          GAN.debugMessage(GetString(LOG_ADDED_NOTE) .. GAN.noteText)
        end, 1500)
      end
	        
      if GAN.isWelcomeMsgActive and GAN.welcomeMsg ~= "" then
        GAN.PrepareWelcomeMsg(GAN.GetGuildIndexWithId(GAN.targetGuildId), GetGuildName(GAN.targetGuildId), displayName)
      end
        
      return
    
    end
    
  end
  
end

function GAN.PrepareWelcomeMsg(guildIndex, guildName, displayName)

  local message = GAN.welcomeMsg

  -- Empty chat : Add text from settings
  if string.len(ZO_ChatWindowTextEntryEditBox:GetText()) == 0 then
    
    -- Empty display name "array" cause it's a new batch of welcomes by adding the newcomer name.
    GAN.welcomeMsgNames = displayName
    
    message = string.gsub(message, "@name", GAN.welcomeMsgNames, 1)
    message = string.gsub(message, "@guild", guildName, 1)
    zo_callLater(function()
      ZO_ChatWindowTextEntryEditBox:SetText("/g" .. guildIndex .. " " .. message)
    end, 500)
  
  else
    
    -- Add the newcomer name to the "array" of names.
    GAN.welcomeMsgNames = GAN.welcomeMsgNames .. ", " .. displayName
    
    message = string.gsub(message, "@name", GAN.welcomeMsgNames, 1)
    message = string.gsub(message, "@guild", guildName, 1)
    zo_callLater(function()
      ZO_ChatWindowTextEntryEditBox:SetText("/g" .. guildIndex .. " " .. message)
    end, 500)
  
  end
  
  CHAT_SYSTEM:Maximize()
  GAN.debugMessage(GetString(LOG_MSG_PREPARED))

end

function GAN.InitSettings()

  if GAN.savedVariables.settings == nil then GAN.savedVariables.settings = {} end
  
  if GAN.savedVariables.settings.isActive == nil then
    GAN.isActive = true
    GAN.savedVariables.settings.isActive = true
  end
  
  if GAN.savedVariables.settings.targetGuildId == nil then
    GAN.targetGuildId = 0
    GAN.savedVariables.settings.targetGuildId = 0
  end
  
  if GAN.savedVariables.settings.noteText == nil then
    GAN.noteText = ""
    GAN.savedVariables.settings.noteText = ""
  end
  
  if GAN.savedVariables.settings.preventErase == nil then
    GAN.preventErase = true
    GAN.savedVariables.settings.preventErase = true
  end
  
  if GAN.savedVariables.settings.welcomeMsg == nil then
    GAN.welcomeMsg = ""
    GAN.savedVariables.settings.welcomeMsg = ""
  end
  
  if GAN.savedVariables.settings.isWelcomeMsgActive == nil then
    GAN.isWelcomeMsgActive = false
    GAN.savedVariables.settings.isWelcomeMsgActive = false
  end
  
  if GAN.savedVariables.settings.debugMode == nil then
    GAN.debugMode = true
    GAN.savedVariables.settings.debugMode = true
  end
  
end

function GAN.debugMessage(message)
  d("[GAN] " .. message)
end

 
-- Create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function GAN.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == GAN.name then
    GAN.Initialize()
    --unregister the event again as our addon was loaded now and we do not need it anymore to be run for each other addon that will load
    EVENT_MANAGER:UnregisterForEvent(GAN.name, EVENT_ADD_ON_LOADED)    
  end
end
 
-- Finally, we'll register our event handler function to be called when the proper event occurs.
-->This event EVENT_ADD_ON_LOADED will be called for EACH of the addns/libraries enabled, this is why there needs to be a check against the addon name within your callback function! Else the very first addon loaded would run your code + all following addons too.
EVENT_MANAGER:RegisterForEvent(GAN.name, EVENT_ADD_ON_LOADED, GAN.OnAddOnLoaded)