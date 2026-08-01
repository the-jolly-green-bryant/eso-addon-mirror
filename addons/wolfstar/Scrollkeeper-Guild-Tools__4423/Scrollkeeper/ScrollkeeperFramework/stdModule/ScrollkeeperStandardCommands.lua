-- Scrollkeeper Guild Tools Addon
-- ScrollkeeperStandardCommands

-- Local references
local Scrollkeeper = Scrollkeeper
local SF = Scrollkeeper.Framework

if not SF then
  d("ERROR: ScrollkeeperFramework missing!")
  return
end

-- Initialize module
Scrollkeeper.StandardCommands = Scrollkeeper.StandardCommands or {
  Name = "ScrollkeeperStandardCommands",
  controls = {},
}
local _addon = Scrollkeeper.StandardCommands

-- Backward compatibility (DEPRECATED)
_G.ScrollkeeperStandardCommands = Scrollkeeper.StandardCommands

-- Debug command with comprehensive system check
SLASH_COMMANDS["/skdebug"] = function()
  d(SF.func._L("ScrollkeeperStandardCommands", "DEBUG_HEADER"))
  d(string.format(SF.func._L("ScrollkeeperStandardCommands", "DEBUG_FRAMEWORK"), tostring(type(ScrollkeeperFramework) == "table")))
  d(string.format(SF.func._L("ScrollkeeperStandardCommands", "DEBUG_SETTINGS"), tostring(type(ScrollkeeperSettings) == "table")))
  d(string.format(SF.func._L("ScrollkeeperStandardCommands", "DEBUG_LAM"), tostring(LibAddonMenu2 ~= nil)))
  -- Framework functions check
  if ScrollkeeperFramework then
    d(string.format(SF.func._L("ScrollkeeperStandardCommands", "DEBUG_FUNC"), tostring(type(ScrollkeeperFramework.func) == "table")))
    d(string.format(SF.func._L("ScrollkeeperStandardCommands", "DEBUG_GET_SETTINGS"), tostring(type(ScrollkeeperFramework.getModuleSettings) == "function")))
    d(string.format(SF.func._L("ScrollkeeperStandardCommands", "DEBUG_PANEL"), tostring(ScrollkeeperFramework.panel ~= nil)))
  end
  if ScrollkeeperFramework and ScrollkeeperFramework._settings then
    local moduleCount = 0
    for modName, data in pairs(ScrollkeeperFramework._settings) do
      moduleCount = moduleCount + 1
      local controlCount = data.controls and #data.controls or 0
      d(string.format(SF.func._L("ScrollkeeperStandardCommands", "DEBUG_MODULE"), modName, controlCount, tostring(data.icon ~= nil)))
    end
    d(string.format(SF.func._L("ScrollkeeperStandardCommands", "DEBUG_TOTAL_MODULES"), moduleCount))
  else
    d(SF.func._L("ScrollkeeperStandardCommands", "DEBUG_NO_MODULES"))
  end
  
  -- Check specific module states
  d(string.format(SF.func._L("ScrollkeeperStandardCommands", "DEBUG_CONTEXT"), tostring(Scrollkeeper.ContextMenu ~= nil)))
  d(string.format(SF.func._L("ScrollkeeperStandardCommands", "DEBUG_NOTEBOOK"), tostring(Scrollkeeper.Notebook ~= nil)))
  d(string.format(SF.func._L("ScrollkeeperStandardCommands", "DEBUG_DATA"), tostring(Scrollkeeper.Data ~= nil)))
  
  -- Library status
  d(string.format(SF.func._L("ScrollkeeperStandardCommands", "DEBUG_HISTOIRE"), tostring(LibHistoire ~= nil)))
  d(string.format(SF.func._L("ScrollkeeperStandardCommands", "DEBUG_LAM"), tostring(LibAddonMenu2 ~= nil)))
  d(string.format(SF.func._L("ScrollkeeperStandardCommands", "DEBUG_DATETIME"), tostring(LibDateTime ~= nil)))
end

-- Comprehensive test command
SLASH_COMMANDS["/sktest"] = function(param)
  if not param or param == "" then
    d(SF.func._L("ScrollkeeperStandardCommands", "TEST_HEADER"))
    d(SF.func._L("ScrollkeeperStandardCommands", "TEST_USAGE"))
    d(SF.func._L("ScrollkeeperStandardCommands", "TEST_OPTIONS"))
    return
  end
  
  param = string.lower(param)
  
  if param == "context" then
    d(SF.func._L("ScrollkeeperStandardCommands", "TEST_CONTEXT_HEADER"))
    
    if CHAT_SYSTEM and CHAT_SYSTEM.ShowPlayerContextMenu then
      d(SF.func._L("ScrollkeeperStandardCommands", "TEST_CONTEXT_ACTIVE"))
      
      -- Check if our module is enabled
      if Scrollkeeper.ContextMenu then
        local settings = SF.getModuleSettings("ScrollkeeperContextMenu", {})
        d(string.format(SF.func._L("ScrollkeeperStandardCommands", "TEST_CONTEXT_ENABLED"), tostring(settings.enabled)))
        d(string.format(SF.func._L("ScrollkeeperStandardCommands", "TEST_CONTEXT_MAIL"), tostring(settings.chatNewMail)))
        d(string.format(SF.func._L("ScrollkeeperStandardCommands", "TEST_CONTEXT_INVITE"), tostring(settings.chatInvite)))
      else
        d(SF.func._L("ScrollkeeperStandardCommands", "TEST_CONTEXT_NOT_LOADED"))
      end
    else
      d(SF.func._L("ScrollkeeperStandardCommands", "TEST_CONTEXT_FAILED"))
    end
    
  elseif param == "settings" then
    d(SF.func._L("ScrollkeeperStandardCommands", "TEST_SETTINGS_HEADER"))
    if SF and SF.getModuleSettings then
      -- Test each module's settings
      local modules = {"ScrollkeeperContextMenu", "ScrollkeeperNotebook", "ScrollkeeperData"}
      for _, modName in ipairs(modules) do
        local settings = SF.getModuleSettings(modName, {})
        d(string.format(SF.func._L("ScrollkeeperStandardCommands", "TEST_SETTINGS_ACCESSIBLE"), modName, tostring(settings ~= nil)))
      end
      
      -- Test panel
      if SF.panel then
        d(SF.func._L("ScrollkeeperStandardCommands", "TEST_SETTINGS_PANEL"))
      else
        d(SF.func._L("ScrollkeeperStandardCommands", "TEST_SETTINGS_NO_PANEL"))
      end
    else
      d(SF.func._L("ScrollkeeperStandardCommands", "TEST_SETTINGS_NO_ACCESS"))
    end
    
  elseif param == "notebook" then
    d(SF.func._L("ScrollkeeperStandardCommands", "TEST_NOTEBOOK_HEADER"))
    if Scrollkeeper.Notebook then
      local settings = SF.getModuleSettings("ScrollkeeperNotebook", {})
      d(SF.func._L("ScrollkeeperStandardCommands", "TEST_NOTEBOOK_LOADED"))
      d(string.format(SF.func._L("ScrollkeeperStandardCommands", "TEST_NOTEBOOK_ENABLED"), tostring(settings.settings and settings.settings.enabled)))
      
      local window = GetControl("ScrollkeeperNotebook_Window")
      d(string.format(SF.func._L("ScrollkeeperStandardCommands", "TEST_NOTEBOOK_WINDOW"), tostring(window ~= nil)))
      
      -- Test note saving
      if Scrollkeeper.Notebook.saveNote then
        local success = Scrollkeeper.Notebook:saveNote("Test Note", "Test content from /sktest", {"test"})
        d(string.format(SF.func._L("ScrollkeeperStandardCommands", "TEST_NOTEBOOK_SAVE"), tostring(success)))
      end
    else
      d(SF.func._L("ScrollkeeperStandardCommands", "TEST_NOTEBOOK_NOT_LOADED"))
    end
    
  elseif param == "mail" then
    d(SF.func._L("ScrollkeeperStandardCommands", "TEST_MAIL_HEADER"))
    
    if Scrollkeeper.NotebookMail then
      local settings = SF.getModuleSettings("ScrollkeeperNotebookMail", {})
      d(SF.func._L("ScrollkeeperStandardCommands", "TEST_MAIL_LOADED"))
      d(string.format(SF.func._L("ScrollkeeperStandardCommands", "TEST_MAIL_ENABLED"), tostring(settings.enabled)))
      
      local window = GetControl("ScrollkeeperMail_Window")
      d(string.format(SF.func._L("ScrollkeeperStandardCommands", "TEST_MAIL_WINDOW"), tostring(window ~= nil)))
      -- Test slash command
      if SLASH_COMMANDS["/sgtmail"] then
        d(SF.func._L("ScrollkeeperStandardCommands", "TEST_MAIL_COMMAND"))
      else
        d(SF.func._L("ScrollkeeperStandardCommands", "TEST_MAIL_NO_COMMAND"))
      end
    else
      d(SF.func._L("ScrollkeeperStandardCommands", "TEST_MAIL_NOT_LOADED"))
    end
    
  elseif param == "data" then
    d(SF.func._L("ScrollkeeperStandardCommands", "TEST_DATA_HEADER"))
    
    if Scrollkeeper.Data then
      d(SF.func._L("ScrollkeeperStandardCommands", "TEST_DATA_LOADED"))
      
      -- Test LibHistoire
      if LibHistoire then
        d(SF.func._L("ScrollkeeperStandardCommands", "TEST_DATA_LH_AVAILABLE"))
        
        -- Test data functions
        if SF.Data and SF.Data.getEvents then
          d(string.format(SF.func._L("ScrollkeeperStandardCommands", "TEST_DATA_CACHE_ACCESSIBLE"), tostring(true)))
          
          -- Count total events across all guilds
          local count = 0
          for i = 1, GetNumGuilds() do
            local guildName = GetGuildName(GetGuildId(i))
            if guildName then
              local events = SF.Data.getEvents(guildName, "all", 999999)
              count = count + #events
            end
          end
          d(string.format(SF.func._L("ScrollkeeperStandardCommands", "TEST_DATA_RECORDS"), count))
        else
          d(SF.func._L("ScrollkeeperStandardCommands", "TEST_DATA_NO_FUNCTIONS"))
        end
      else
        d(SF.func._L("ScrollkeeperStandardCommands", "TEST_DATA_NO_LH"))
      end
    else
      d(SF.func._L("ScrollkeeperStandardCommands", "TEST_DATA_NOT_LOADED"))
    end
   
  -- Test attendance functions   
  elseif param == "attendance" then
    d(SF.func._L("ScrollkeeperStandardCommands", "TEST_ATTENDANCE_HEADER"))
    
    if Scrollkeeper.Attendance then
      d(SF.func._L("ScrollkeeperStandardCommands", "TEST_ATTENDANCE_LOADED"))
      
      local settings = SF.getModuleSettings("ScrollkeeperAttendance", {})
      d(string.format(SF.func._L("ScrollkeeperStandardCommands", "TEST_ATTENDANCE_ENABLED"), tostring(settings.enabled)))
      
      -- Check for active session
      if settings.currentSession then
        d(string.format(SF.func._L("ScrollkeeperStandardCommands", "TEST_ATTENDANCE_ACTIVE"), settings.currentSession.eventName))
      else
        d(SF.func._L("ScrollkeeperStandardCommands", "TEST_ATTENDANCE_NO_SESSION"))
      end
      
      -- Check session history
      if settings.sessions then
        d(string.format(SF.func._L("ScrollkeeperStandardCommands", "TEST_ATTENDANCE_HISTORY"), #settings.sessions))
      end
      
      -- Check slash commands
      if SLASH_COMMANDS["/sgtattendance"] then
        d(SF.func._L("ScrollkeeperStandardCommands", "TEST_ATTENDANCE_COMMANDS"))
      else
        d(SF.func._L("ScrollkeeperStandardCommands", "TEST_ATTENDANCE_NO_COMMANDS"))
      end
    else
      d(SF.func._L("ScrollkeeperStandardCommands", "TEST_ATTENDANCE_NOT_LOADED"))
    end
    
  else
    d(string.format(SF.func._L("ScrollkeeperStandardCommands", "TEST_UNKNOWN"), param))
    d(SF.func._L("ScrollkeeperStandardCommands", "TEST_AVAILABLE"))
  end
end

-- Enhanced command registration
local function registerCommands()
  
  -- Basic utility commands
  SLASH_COMMANDS["/rl"] = ReloadUI
  
  SLASH_COMMANDS["/on"] = function() 
    SelectPlayerStatus(PLAYER_STATUS_ONLINE)
    d(SF.func._L("ScrollkeeperStandardCommands", "STATUS_ONLINE"))
  end
  
  SLASH_COMMANDS["/off"] = function() 
    SelectPlayerStatus(PLAYER_STATUS_OFFLINE)
    d(SF.func._L("ScrollkeeperStandardCommands", "STATUS_OFFLINE"))
  end
  
  SLASH_COMMANDS["/dnd"] = function() 
    SelectPlayerStatus(PLAYER_STATUS_DO_NOT_DISTURB)
    d(SF.func._L("ScrollkeeperStandardCommands", "STATUS_DND"))
  end
  
  SLASH_COMMANDS["/afk"] = function() 
    SelectPlayerStatus(PLAYER_STATUS_AWAY)
    d(SF.func._L("ScrollkeeperStandardCommands", "STATUS_AWAY"))
  end
  
  -- Dice rolling utility
  SLASH_COMMANDS["/roll"] = _addon.rollDice
  SLASH_COMMANDS["/dice"] = _addon.rollDice
  
  -- Offline toggle
  SLASH_COMMANDS["/offl"] = _addon.toggleOffline
  
end

-- 🎲 Dice Roll util
function _addon.rollDice(input)
  if not input or input == "" then 
    d(SF.func._L("ScrollkeeperStandardCommands", "ROLL_USAGE"))
    d(SF.func._L("ScrollkeeperStandardCommands", "ROLL_EXAMPLE"))
    return 
  end
  
  local max = tonumber(input)
  if not max or max < 1 then 
    d(string.format(SF.func._L("ScrollkeeperStandardCommands", "ROLL_INVALID"), tostring(input)))
    return 
  end
  
  local result = math.random(max)
  local name = GetUnitName("player") or "@Player"
  
  -- Format the message using localization
  local text = string.format(SF.func._L("ScrollkeeperStandardCommands", "ROLL_OUTPUT"), result, max)
  
  -- Use CHAT_SYSTEM to populate the text entry
  if CHAT_SYSTEM and CHAT_SYSTEM.textEntry then
    CHAT_SYSTEM.textEntry:SetText(name .. " " .. text)
    CHAT_SYSTEM.textEntry:TakeFocus()
  else
    d(text)
  end
end

-- 📶 Toggle Online/Offline util
function _addon.toggleOffline()
  local status    = GetPlayerStatus()
  local newStatus = (status == PLAYER_STATUS_OFFLINE) and PLAYER_STATUS_ONLINE or PLAYER_STATUS_OFFLINE
  SelectPlayerStatus(newStatus)
  
  local label  = (newStatus == PLAYER_STATUS_OFFLINE) and 
                 SF.func._L("ScrollkeeperStandardCommands", "STATUS_OFFLINE") or 
                 SF.func._L("ScrollkeeperStandardCommands", "STATUS_ONLINE")
  d(string.format(SF.func._L("ScrollkeeperStandardCommands", "STATUS_CHANGED"), label))
end

-- 📋Build your LibAddonMenu2 controls
function _addon.createSettings()
  _addon.controls = {
    {
      type = "submenu",
      name = SF.func._L("ScrollkeeperStandardCommands", "SUBMENU_NAME"), 
      controls = {
        {
          type = "description",
          text = SF.func._L("ScrollkeeperStandardCommands", "DESCRIPTION")
        },
        {
          type = "header",
          name = SF.func._L("ScrollkeeperStandardCommands", "COMMANDS_HEADER")
        },
        {
          type = "description",
          text = SF.func._L("ScrollkeeperStandardCommands", "COMMAND_LIST")
        },
        {
          type = "button",
          name = SF.func._L("ScrollkeeperStandardCommands", "TEST_BUTTON"),
          tooltip = SF.func._L("ScrollkeeperStandardCommands", "TEST_BUTTON_TIP"),
          func = function()
            d(SF.func._L("ScrollkeeperStandardCommands", "TEST_RUNNING"))
            SLASH_COMMANDS["/skdebug"]()
            zo_callLater(function()
              SLASH_COMMANDS["/sktest"]("settings")
            end, 1000)
          end,
          width = "half",
        },
      }
    }
  }
end

-- Register keybinding targets
function _addon.setupKeybinds()
  SF._bindings = SF._bindings or {}
  SF._bindings.reload = ReloadUI
  SF._bindings.offlineToggle = _addon.toggleOffline

end

-- Module initialization
function _addon.initialized()
  
  registerCommands()
  _addon.setupKeybinds()
  _addon.createSettings()
  
  -- Register with framework
  if SF.RegisterModuleOptions then
    SF.RegisterModuleOptions(_addon.Name, _addon.controls)
  end

end

-- Initialize when framework is ready
CALLBACK_MANAGER:RegisterCallback("Scrollkeeper_Initialized", _addon.initialized)

-- Fallback if callback doesn't fire
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_PLAYER_ACTIVATED, function(_, initial)
  if not initial then return end
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_PLAYER_ACTIVATED)
  zo_callLater(function()
    if not _addon._initialized then
      _addon.initialized()
      _addon._initialized = true
    end
  end, 5000)
end)