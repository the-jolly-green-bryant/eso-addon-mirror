-- Scrollkeeper Guild Tools Addon
-- ScrollkeeperWelcome

-- Local references
local Scrollkeeper = Scrollkeeper
local SF = Scrollkeeper.Framework
local SF_Set = Scrollkeeper.Settings

if type(SF) ~= "table" or not SF.initAddon or type(SF_Set) ~= "table" then
  return
end

-- Initialize module
Scrollkeeper.Welcome = Scrollkeeper.Welcome or { Name = "ScrollkeeperWelcome" }
local _addon = Scrollkeeper.Welcome

-- Backward compatibility (DEPRECATED)
_G.ScrollkeeperWelcome = Scrollkeeper.Welcome

-- 💾 SavedVars defaults
local defaultMsg = "Welcome %1 to %2"
local defaults = {
  enabled = true, -- master toggle
  invite  = {},   -- [guildName] = bool
  message = {},   -- [guildName] = string
}

-- Use unified settings system instead of LibSavedVars
local function getSettings()
  return SF.getModuleSettings(_addon.Name, defaults)
end

-- Track members already welcomed (guildId -> accountName -> timestamp)
local joinedMembers = {}

-- Chat queue (prevents lost welcomes when chat is busy or multiple joins occur)
local pendingChatQueue = {}
local chatQueueActive = false

local function ProcessChatQueue()
  if chatQueueActive then return end
  chatQueueActive = true

  local function tryNext()
    -- Wait until chat is clear
    if CHAT_SYSTEM.textEntry:GetText() ~= "" then
      zo_callLater(tryNext, 500)
      return
    end

    local nextMsg = table.remove(pendingChatQueue, 1)
    if not nextMsg then
      chatQueueActive = false
      return
    end

    ZO_ChatWindowTextEntryEditBox:SetText(nextMsg)

    -- Give ESO time to send before attempting the next message
    zo_callLater(tryNext, 800)
  end

  tryNext()
end

local function QueueChatMessage(text)
  table.insert(pendingChatQueue, text)
  ProcessChatQueue()
end

-- Internal reference to splitToArray with fallback
local function getSplitToArray()
  return (SF.func and SF.func.splitToArray) or function(text, delimiter)
    if not text or text == '' then return {} end
    local result = {}
    for match in string.gmatch(text, "([^" .. delimiter .. "]+)") do
      table.insert(result, match)
    end
    return result
  end
end

-- 📢️ Generate a random welcome for this guild/player
function _addon.getMessageForGuild(guildName, displayName)
  local settings = getSettings()
  if not settings.message then return nil end
  
  local defaultMsg = SF.func._L("ScrollkeeperWelcome", "DEFAULT_MESSAGE")
  local splitToArray = getSplitToArray()
  local tmplList = splitToArray(settings.message[guildName] or defaultMsg, "|")
  if #tmplList == 0 then return nil end
  local choice = tmplList[math.random(#tmplList)]
  return choice:gsub("%%1", displayName):gsub("%%2", guildName)
end

-- Helper: Get guild index from guild ID
local function getGuildIndexFromId(guildId)
  for i = 1, GetNumGuilds() do
    if GetGuildId(i) == guildId then
      return i
    end
  end
  return nil
end

-- Helper: Resolve visual guild index (respects DolgubonsGuildReorder)
local function resolveVisualGuildIndex(guildIndex)
  if DolgubonsGuildReorder and type(DolgubonsGuildReorder.keyOrder) == "table" then
    for visualPos, originalIdx in pairs(DolgubonsGuildReorder.keyOrder) do
      if originalIdx == guildIndex then
        return visualPos
      end
    end
  end
  return guildIndex
end

-- Enhanced event handler: only trigger on actual joins, not invites
function _addon.guildMemberAdded(_, guildId, accountName)
  local settings = getSettings()
  if not settings or not settings.enabled then return end

  local guildName = GetGuildName(guildId)
  if not guildName or not settings.invite or not settings.invite[guildName] then return end

  -- Wait for rank to settle, then check if it's a real join
  zo_callLater(function()
    local found, rankIndex, rankName

    for i = 1, GetNumGuildMembers(guildId) do
      local name, _, rIndex = GetGuildMemberInfo(guildId, i)
      if name == accountName then
        found = true
        rankIndex = rIndex
        rankName = GetFinalGuildRankName(guildId, rIndex)
        break
      end
    end

    -- If not found or no rank info, skip silently
    if not found or not rankIndex or not rankName or rankName == "" then
      return
    end

    -- Check for the "Invited" rank name
    if rankName == GetString(SI_GUILD_RANK_INVITED) then
      return
    end

    -- Prevent duplicate welcomes
    joinedMembers[guildId] = joinedMembers[guildId] or {}
    if joinedMembers[guildId][accountName] then return end

    local msg = _addon.getMessageForGuild(guildName, accountName)
    if not msg then return end

    -- Only NOW do we know this is a real join - get the guild index
    local guildIndex = getGuildIndexFromId(guildId)
    if not guildIndex then return end
    guildIndex = resolveVisualGuildIndex(guildIndex)

    -- Mark as welcomed ONLY after we've confirmed everything and have a message
    joinedMembers[guildId][accountName] = GetTimeStamp()

    -- Notification appears ONLY when we have a valid message to send
    d(string.format(SF.func._L("ScrollkeeperWelcome", "LOG_MEMBER_JOINED"), accountName, guildName, rankName))

    QueueChatMessage(("/g%d %s"):format(guildIndex, msg))
  end, 1500)
end

-- 🎛 Enhanced event registration
function _addon:EnableEvents()
  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GUILD_MEMBER_ADDED, _addon.guildMemberAdded)
end

function _addon:DisableEvents()
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_GUILD_MEMBER_ADDED)
end

-- Build LibAddonMenu-2.0 controls
local function buildControls()
  local settings = getSettings()
  
  local controls = {
    {
      type = "submenu",
      name = SF.func._L("ScrollkeeperWelcome", "SUBMENU_NAME"),
      controls = {
        {
          type = "description",
          text = SF.func._L("ScrollkeeperWelcome", "DESCRIPTION"),
        },
        -- Master enable toggle
        {
          type    = "checkbox",
          name    = SF.func._L("ScrollkeeperWelcome", "MASTER_ENABLE"),
          tooltip = SF.func._L("ScrollkeeperWelcome", "MASTER_ENABLE_TIP"),
          getFunc = function() return settings.enabled end,
          setFunc = function(v)
            settings.enabled = v
            if v then
              _addon:EnableEvents()
            else
              _addon:DisableEvents()
            end
          end,
          default = defaults.enabled,
        },
        { 
          type = "header", 
          name = SF.func._L("ScrollkeeperWelcome", "TEMPLATE_HEADER"),
        },
        {
          type = "description",
          text = "|cf3ebd1" .. SF.func._L("ScrollkeeperWelcome", "VAR_PLAYER") .. "|r\n" ..
                 "|cf3ebd1" .. SF.func._L("ScrollkeeperWelcome", "VAR_GUILD") .. "|r", 
        },
      }
    }
  }

  -- Per-guild settings
  for i = 1, GetNumGuilds() do
    local guildName = GetGuildName(GetGuildId(i))
    if guildName then
      -- Ensure defaults exist
      if settings.invite[guildName] == nil then
        settings.invite[guildName] = true
      end
      if not settings.message[guildName] then
        settings.message[guildName] = SF.func._L("ScrollkeeperWelcome", "DEFAULT_MESSAGE")
      end

      -- Create guild submenu
      local guildSubmenu = {
        type = "submenu",
        name = guildName,
        controls = {
          {
            type    = "checkbox",
            name    = SF.func._L("ScrollkeeperWelcome", "ENABLE_FOR_GUILD"),
            getFunc = function() return settings.invite[guildName] or false end,
            setFunc = function(v) settings.invite[guildName] = v end,
            default = true,
          },
          {
            type    = "editbox",
            name    = SF.func._L("ScrollkeeperWelcome", "MESSAGE_TEMPLATE"),
            getFunc = function() 
              return settings.message[guildName] or SF.func._L("ScrollkeeperWelcome", "DEFAULT_MESSAGE")
            end,
            setFunc = function(v)
              settings.message[guildName] = v
            end,
            default = SF.func._L("ScrollkeeperWelcome", "DEFAULT_MESSAGE"),
            width   = "full",
          },
          {
            type = "description",
            text = function()
              local currentMessage = settings.message[guildName] or SF.func._L("ScrollkeeperWelcome", "DEFAULT_MESSAGE")
              local sample = currentMessage:gsub("%%1", "@Player"):gsub("%%2", guildName)
              return "|cffffff" .. string.format(SF.func._L("ScrollkeeperWelcome", "PREVIEW"), "|cf3ebd1" .. sample .. "|r")
            end,
          },
        }
      }
      
      -- Add guild submenu to the main welcome submenu
      table.insert(controls[1].controls, guildSubmenu)
    end
  end

  return controls
end

-- 🚀 Register under the unified Scrollkeeper settings panel
local function initialize()
  if SF_Set then
    SF_Set.RegisterModuleOptions(_addon.Name, buildControls())
  end
  
  local settings = getSettings()
  if settings.enabled then
    _addon:EnableEvents()
  end
end

-- Register for proper initialization
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_PLAYER_ACTIVATED, function()
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_PLAYER_ACTIVATED)
  initialize()
end)

-- ⏳ Wait until the framework signals ready
CALLBACK_MANAGER:RegisterCallback("Scrollkeeper_Initialized", initialize)