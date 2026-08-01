-- ScrollkeeperApplications
-- Automatic logging of guild applications to Notebook

-- Local references
local Scrollkeeper = Scrollkeeper
local SF = Scrollkeeper.Framework
local SF_Set = Scrollkeeper.Settings

if type(SF) ~= "table" or not SF.initAddon then
  d("[ScrollkeeperApplications] ERROR: Framework missing")
  return
end

-- Initialize module
Scrollkeeper.Applications = Scrollkeeper.Applications or { Name = "ScrollkeeperApplications" }
local _addon = Scrollkeeper.Applications

-- Prevent multiple initialization
if _addon._initialized then return end

-- Settings defaults
local defaults = {
  enabled = true,
  autoLog = true,
  showNotifications = true,
  guilds = {}, -- [guildName] = true/false
}

-- Get settings using unified system
local function getSettings()
  return SF.getModuleSettings(_addon.Name, defaults)
end

-- Track logged applications to prevent duplicates
-- Structure: [guildId][accountName] = timestamp
local loggedApplications = {}

-- Helper: Get alliance name
local function getAllianceName(allianceId)
  if allianceId == ALLIANCE_ALDMERI_DOMINION then return "Aldmeri Dominion"
  elseif allianceId == ALLIANCE_DAGGERFALL_COVENANT then return "Daggerfall Covenant"
  elseif allianceId == ALLIANCE_EBONHEART_PACT then return "Ebonheart Pact"
  else return "None" end
end

-- Helper: Get class name
local function getClassName(classId)
  return GetClassName(GENDER_MALE, classId) or "Unknown"
end

-- Log a single application to Notebook
local function logApplication(guildId, guildName, level, cp, alliance, classId, accountName, characterName, achievementPoints, applicationMessage, expiresAt)
  local settings = getSettings()
  
  -- Create note title with expiration date (prevents duplicates)
  local expiresDate = os.date("%Y-%m-%d", expiresAt or GetTimeStamp())
  local noteTitle = string.format("Application - %s (expires %s)", accountName, expiresDate)
  
  -- Check if this note already exists in Notebook
  local notebook = Scrollkeeper.Notebook or ScrollkeeperNotebook
  if notebook then
    local notebookSettings = SF.getModuleSettings("ScrollkeeperNotebook", {})
    if notebookSettings.noteList and notebookSettings.noteList["Applications"] then
      if notebookSettings.noteList["Applications"][noteTitle] then
        -- Note already exists, skip logging silently
        return false
      end
    end
  end
  
  -- Also check in-memory cache (for same session)
  loggedApplications[guildId] = loggedApplications[guildId] or {}
  if loggedApplications[guildId][accountName] then
    return false
  end
  
  -- Calculate days remaining
  local daysRemaining = expiresAt and math.floor((expiresAt - GetTimeStamp()) / 86400) or 0
  
  -- Create detailed note body
  local noteBody = string.format([[Guild: %s
Logged: %s
Expires: %s (%d days remaining)
__________________________________________________
APPLICANT INFORMATION

Character: %s
Account: %s

Level: %d
Champion Points: %d
Class: %s
Alliance: %s
Achievement Points: %d
__________________________________________________
APPLICATION MESSAGE

%s

__________________________________________________
This application will expire on %s.
To accept/decline, use the in-game Guild Finder interface.]],
    guildName,                                                                    -- Guild: %s
    os.date("%Y-%m-%d %H:%M:%S", GetTimeStamp()),                                 -- Logged: %s
    os.date("%Y-%m-%d %H:%M", expiresAt or GetTimeStamp()),                       -- Expires: %s
    daysRemaining,                                                                -- (%d days remaining)
    characterName,                                                                -- Character: %s
    accountName,                                                                  -- Account: %s
    level,                                                                        -- Level: %d
    cp,                                                                           -- Champion Points: %d
    getClassName(classId),                                                        -- Class: %s
    getAllianceName(alliance),                                                    -- Alliance: %s
    achievementPoints,                                                            -- Achievement Points: %d
    applicationMessage and applicationMessage ~= "" and applicationMessage or "(No message provided)",  -- %s
    os.date("%Y-%m-%d %H:%M", expiresAt or GetTimeStamp())                        -- expire on %s
  )
  
-- Save to Notebook if available
  local notebook = Scrollkeeper.Notebook or ScrollkeeperNotebook
  
  if not notebook then
    d(SF.func._L("ScrollkeeperApplications", "ERROR_NOTEBOOK_UNAVAILABLE"))
    return false
  end
  
  if not notebook.saveNote then
	d("[Applications] ERROR: Notebook module loaded but saveNote function missing")
	d("[DEBUG] Notebook type: " .. type(notebook))
	d("[DEBUG] saveNote type: " .. type(notebook.saveNote))
	if notebook.SaveNote then
      d("[DEBUG] Found SaveNote (capital S)")
    end
    for k, v in pairs(notebook) do
      if type(v) == "function" and k:lower():find("save") then
        d("[DEBUG] Found function: " .. k)
      end
    end
  return false
  end
  
  local success = notebook:saveNote(
    noteTitle,
    noteBody,
    {"application", "recruitment", guildName},
    {category = "Applications"}
  )
  
  if success then
    -- Mark as logged
    loggedApplications[guildId][accountName] = GetTimeStamp()
    
    -- Show notification if enabled
    local settings = getSettings()
    if settings.showNotifications then
      d(string.format(SF.func._L("ScrollkeeperApplications", "SUCCESS_LOGGED_SINGLE"), accountName, guildName))
    end
    
    return true
  else
    d(string.format(SF.func._L("ScrollkeeperApplications", "ERROR_SAVE_FAILED"), accountName))
    return false
  end
end

-- Process all pending applications for a guild
local function processGuildApplications(guildId)
  local settings = getSettings()
  if not settings.enabled or not settings.autoLog then return end
  
  local guildName = GetGuildName(guildId)
  if not guildName then return end
  
  -- Check per-guild settings
  if settings.guilds[guildName] == false then
    -- This guild is disabled
    return
  end
  
  -- Get number of applications
  local numApplications = GetGuildFinderNumGuildApplications(guildId)
  if numApplications == 0 then return end
  
  local loggedCount = 0
  
  -- Iterate through all applications
  for i = 1, numApplications do
    local level, cp, alliance, classId, accountName, characterName, achievementPoints, applicationMessage = 
      GetGuildFinderGuildApplicationInfoAt(guildId, i)
    
    -- Get expiration timestamp (protected in case user lacks permissions)
    local timeRemaining = 1296000 -- Default 15 days
    local success, result = pcall(function()
      return GetGuildFinderGuildApplicationDuration(guildId, i)
    end)
    if success and result then
      timeRemaining = result
    end
    local expiresAt = GetTimeStamp() + timeRemaining
    
    if accountName and accountName ~= "" then
      local success = logApplication(
        guildId, guildName, level, cp, alliance, classId, 
        accountName, characterName, achievementPoints, applicationMessage,
        expiresAt
      )
      
      if success then
        loggedCount = loggedCount + 1
      end
    end
  end
  
  -- Summary notification if multiple applications were logged
  if loggedCount > 1 and settings.showNotifications then
    d(string.format(SF.func._L("ScrollkeeperApplications", "SUCCESS_LOGGED_MULTIPLE"), loggedCount, guildName))
  end
end

-- Event: New applications received
local function onGuildNewApplications(_, guildId, numApplications)
  -- Small delay to ensure API data is ready
  zo_callLater(function()
    processGuildApplications(guildId)
  end, 500)
end

-- Event: Application list updated
local function onApplicationResultsGuild(_, guildId)
  -- Small delay to ensure API data is ready
  zo_callLater(function()
    processGuildApplications(guildId)
  end, 500)
end

-- Build settings controls
local function buildControls()
  local settings = getSettings()
  
  local controls = {
    {
      type = "submenu",
      name = SF.func._L("ScrollkeeperApplications", "SUBMENU_NAME"),
      controls = {
        {
          type = "description",
          text = SF.func._L("ScrollkeeperApplications", "DESCRIPTION"),
        },
        {
          type = "checkbox",
          name = SF.func._L("ScrollkeeperApplications", "MASTER_ENABLE"),
          tooltip = SF.func._L("ScrollkeeperApplications", "MASTER_ENABLE_TIP"),
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
          type = "checkbox",
          name = SF.func._L("ScrollkeeperApplications", "AUTO_LOG"),
          tooltip = SF.func._L("ScrollkeeperApplications", "AUTO_LOG_TIP"),
          getFunc = function() return settings.autoLog end,
          setFunc = function(v) settings.autoLog = v end,
          default = defaults.autoLog,
        },
        {
          type = "checkbox",
          name = SF.func._L("ScrollkeeperApplications", "SHOW_NOTIFICATIONS"),
          tooltip = SF.func._L("ScrollkeeperApplications", "SHOW_NOTIFICATIONS_TIP"),
          getFunc = function() return settings.showNotifications end,
          setFunc = function(v) settings.showNotifications = v end,
          default = defaults.showNotifications,
        },
        {
          type = "header",
          name = SF.func._L("ScrollkeeperApplications", "HEADER_GUILDS"),
        },
        {
          type = "description",
          text = SF.func._L("ScrollkeeperApplications", "GUILDS_DESC"),
        },
      }
    }
  }
  
  -- Add per-guild toggles
  for i = 1, GetNumGuilds() do
    local guildId = GetGuildId(i)
    local guildName = GetGuildName(guildId)
    
    if guildName then
      -- Default to enabled if not set
      if settings.guilds[guildName] == nil then
        settings.guilds[guildName] = true
      end
      
      table.insert(controls[1].controls, {
        type = "checkbox",
        name = guildName,
        tooltip = string.format(SF.func._L("ScrollkeeperApplications", "GUILD_TOGGLE_TIP"), guildName),
        getFunc = function() return settings.guilds[guildName] ~= false end,
        setFunc = function(v) settings.guilds[guildName] = v end,
        default = true,
        width = "half",
      })
    end
  end
  
  return controls
end

-- Enable event handlers
function _addon:EnableEvents()
  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GUILD_FINDER_GUILD_NEW_APPLICATIONS, onGuildNewApplications)
  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GUILD_FINDER_APPLICATION_RESULTS_GUILD, onApplicationResultsGuild)
end

-- Disable event handlers
function _addon:DisableEvents()
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_GUILD_FINDER_GUILD_NEW_APPLICATIONS)
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_GUILD_FINDER_APPLICATION_RESULTS_GUILD)
end

-- Initialize
local function initialize()
  if _addon._initialized then return end
  
  -- Check if Notebook is available
  if not Scrollkeeper.Notebook then
    d(SF.func._L("ScrollkeeperApplications", "WARNING_NOTEBOOK_MISSING"))
  end
  
  local settings = getSettings()
  
  -- Register with framework
  if SF_Set and SF_Set.RegisterModuleOptions then
    local controls = buildControls()
    SF_Set.RegisterModuleOptions(_addon.Name, controls)
  end
  
  --- Register event handlers if enabled
  if settings.enabled then
    _addon:EnableEvents()
  end
  
  _addon._initialized = true
end

-- Register for proper initialization
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_PLAYER_ACTIVATED, function(_, initial)
  if not initial then return end
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_PLAYER_ACTIVATED)
  initialize()
end)

CALLBACK_MANAGER:RegisterCallback("Scrollkeeper_Initialized", initialize)