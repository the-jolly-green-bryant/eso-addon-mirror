-- ScrollkeeperAttendance
-- Event attendance tracking with late/early tracking

-- Local references
local Scrollkeeper = Scrollkeeper
local SF = Scrollkeeper.Framework
local SF_Set = Scrollkeeper.Settings

-- Initialize module
Scrollkeeper.Attendance = Scrollkeeper.Attendance or { Name = "ScrollkeeperAttendance" }
local _addon = Scrollkeeper.Attendance

if _addon._initialized then return end

-- Backward compatibility (DEPRECATED)
_G.ScrollkeeperAttendance = Scrollkeeper.Attendance
if type(SF) ~= "table" then
  d("[ScrollkeeperAttendance] Framework not available")
  return
end

-- Settings defaults
local defaults = {
  enabled = true,
  currentSession = nil,
  sessions = {}, -- eventName -> {startTime, endTime, attendees}
}

-- Get settings using unified system
local function getSettings()
  return SF.getModuleSettings(_addon.Name, defaults)
end

-- Active tracking state
local activeSession = nil

-- Start attendance tracking
local function startTracking(eventName)
  if activeSession then
    d("|cFF5555" .. SF.func._L("ScrollkeeperAttendance", "ERROR_ALREADY_TRACKING") .. "|r")
    return false
  end
  
  if not eventName or eventName == "" then
    eventName = "Event " .. os.date("%Y-%m-%d %H:%M", GetTimeStamp())
  end
  
  activeSession = {
    eventName = eventName,
    startTime = GetTimeStamp(),
    endTime = nil,
    attendees = {}, -- displayName -> {joinTime, leaveTime, notes}
    initialSnapshot = {} -- Members present at start
  }
  
  -- Take initial snapshot of group
  for i = 1, GetGroupSize() do
    local unitTag = GetGroupUnitTagByIndex(i)
    if unitTag then
      local displayName = GetUnitDisplayName(unitTag)
      if displayName and displayName ~= "" then
        activeSession.attendees[displayName] = {
          joinTime = activeSession.startTime,
          leaveTime = nil,
          status = "present"
        }
        activeSession.initialSnapshot[displayName] = true
      end
    end
  end
  
  local settings = getSettings()
  settings.currentSession = activeSession
  
  d("|c00FF00" .. string.format(SF.func._L("ScrollkeeperAttendance", "SUCCESS_TRACKING_STARTED"), eventName, table.count(activeSession.attendees)) .. "|r")
  return true
end

-- Helper to count table entries
function table.count(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

-- Stop attendance tracking
local function stopTracking()
  if not activeSession then
    d("|cFF5555" .. SF.func._L("ScrollkeeperAttendance", "ERROR_NO_ACTIVE_SESSION") .. "|r")
    return false
  end
  
  activeSession.endTime = GetTimeStamp()
  
  -- Mark all still-present members
  for displayName, data in pairs(activeSession.attendees) do
    if not data.leaveTime then
      data.leaveTime = activeSession.endTime
    end
  end
  
  -- Save to history
  local settings = getSettings()
  settings.sessions = settings.sessions or {}
  table.insert(settings.sessions, activeSession)
  settings.currentSession = nil
  
  -- Create note if Notebook is available
  if Scrollkeeper.Notebook and Scrollkeeper.Notebook.saveNote then
    local attendanceText = generateAttendanceReport(activeSession)
    
    -- Use the correct saveNote signature: (title, body, tagList, meta)
    local success = Scrollkeeper.Notebook:saveNote(
      activeSession.eventName,           -- title
      attendanceText,                    -- body
      {"attendance", "event"},           -- tags as table
      {category = "Events"}              -- meta
    )
    
    if success then
      d("|cAADDFF" .. SF.func._L("ScrollkeeperAttendance", "SUCCESS_SAVED_TO_NOTEBOOK") .. "|r")
      
    else
      d("|cFFAA55" .. SF.func._L("ScrollkeeperAttendance", "ERROR_NOT_SAVED") .. "|r")
    end
  else
    d("|cFFAA55" .. SF.func._L("ScrollkeeperAttendance", "ERROR_NOTEBOOK_DISABLED") .. "|r")
  end
  
  d("|c00FF00" .. string.format(SF.func._L("ScrollkeeperAttendance", "SUCCESS_TRACKING_STOPPED"), activeSession.eventName) .. "|r")
  
  activeSession = nil
  return true
end

-- Generate attendance report
function generateAttendanceReport(session)
  local report = string.format(SF.func._L("ScrollkeeperAttendance", "REPORT_HEADER"), session.eventName) .. "\n"
  report = report .. string.format(SF.func._L("ScrollkeeperAttendance", "REPORT_TIME"), 
    os.date("%Y-%m-%d %H:%M", session.startTime),
    os.date("%H:%M", session.endTime or GetTimeStamp())) .. "\n"
  report = report .. string.rep("-", 50) .. "\n\n"
  
  -- Categorize attendees
  local onTime = {}
  local late = {}
  local leftEarly = {}
  local fullAttendance = {}
  
  local eventDuration = (session.endTime or GetTimeStamp()) - session.startTime
  local lateThreshold = session.startTime + 300 -- 5 minutes
  local earlyThreshold = (session.endTime or GetTimeStamp()) - 300 -- Left 5+ min early
  
  for displayName, data in pairs(session.attendees) do
    local minutesLate = math.max(0, math.floor((data.joinTime - session.startTime) / 60))
    local wasLate = data.joinTime > lateThreshold
    local leftEarly = data.leaveTime and data.leaveTime < earlyThreshold
    
    local attendeeInfo = {
      name = displayName,
      joinTime = data.joinTime,
      leaveTime = data.leaveTime,
      minutesLate = minutesLate
    }
    
    if wasLate then
      table.insert(late, attendeeInfo)
    elseif leftEarly then
      table.insert(leftEarly, attendeeInfo)
    elseif not leftEarly and not wasLate then
      table.insert(fullAttendance, attendeeInfo)
    else
      table.insert(onTime, attendeeInfo)
    end
  end
  
  -- Full attendance list
  if #fullAttendance > 0 then
    report = report .. SF.func._L("ScrollkeeperAttendance", "SECTION_FULL_ATTENDANCE") .. " (" .. #fullAttendance .. "):\n"
    table.sort(fullAttendance, function(a, b) return a.name < b.name end)
    for _, info in ipairs(fullAttendance) do
      report = report .. "  • " .. info.name .. "\n"
    end
    report = report .. "\n"
  end
  
  -- On time (but maybe left early)
  if #onTime > 0 then
    report = report .. SF.func._L("ScrollkeeperAttendance", "SECTION_ON_TIME") .. " (" .. #onTime .. "):\n"
    table.sort(onTime, function(a, b) return a.name < b.name end)
    for _, info in ipairs(onTime) do
      report = report .. "  • " .. info.name .. "\n"
    end
    report = report .. "\n"
  end
  
  -- Late arrivals
  if #late > 0 then
    report = report .. SF.func._L("ScrollkeeperAttendance", "SECTION_LATE") .. " (" .. #late .. "):\n"
    table.sort(late, function(a, b) return a.minutesLate > b.minutesLate end)
    for _, info in ipairs(late) do
      report = report .. string.format("  • %s (%d min late)\n", info.name, info.minutesLate)
    end
    report = report .. "\n"
  end
  
  -- Left early
  if #leftEarly > 0 then
    report = report .. SF.func._L("ScrollkeeperAttendance", "SECTION_LEFT_EARLY") .. " (" .. #leftEarly .. "):\n"
    table.sort(leftEarly, function(a, b) return a.name < b.name end)
    for _, info in ipairs(leftEarly) do
      local minutesEarly = math.floor(((session.endTime or GetTimeStamp()) - info.leaveTime) / 60)
      report = report .. string.format("  • %s (%d min early)\n", info.name, minutesEarly)
    end
    report = report .. "\n"
  end
  
  -- Summary
  report = report .. string.rep("-", 50) .. "\n"
  report = report .. string.format(SF.func._L("ScrollkeeperAttendance", "REPORT_SUMMARY"), 
    #fullAttendance + #onTime + #late + #leftEarly,
    #fullAttendance,
    #late,
    #leftEarly) .. "\n"
  
  return report
end

-- Update tracking (called periodically or on group change)
local function updateTracking()
  if not activeSession then return end
  
  local currentTime = GetTimeStamp()
  local currentMembers = {}
  
  -- Get current group members
  for i = 1, GetGroupSize() do
    local unitTag = GetGroupUnitTagByIndex(i)
    if unitTag then
      local displayName = GetUnitDisplayName(unitTag)
      if displayName and displayName ~= "" then
        currentMembers[displayName] = true
        
        -- New member joined
        if not activeSession.attendees[displayName] then
          activeSession.attendees[displayName] = {
            joinTime = currentTime,
            leaveTime = nil,
            status = "joined_late"
          }
          
          local minutesLate = math.floor((currentTime - activeSession.startTime) / 60)
          d("|cFFDD88" .. string.format(SF.func._L("ScrollkeeperAttendance", "LOG_MEMBER_JOINED"), displayName, minutesLate) .. "|r")
        end
      end
    end
  end
  
  -- Check for members who left
  for displayName, data in pairs(activeSession.attendees) do
    if not data.leaveTime and not currentMembers[displayName] then
      data.leaveTime = currentTime
      
      local minutesPresent = math.floor((currentTime - data.joinTime) / 60)
      d("|cFFAA55" .. string.format(SF.func._L("ScrollkeeperAttendance", "LOG_MEMBER_LEFT"), displayName, minutesPresent) .. "|r")
    end
  end
end

-- Event handlers
local function onGroupMemberJoined(_, memberDisplayName)
  if activeSession then
    updateTracking()
  end
end

local function onGroupMemberLeft(_, _, _, isLocalPlayer, _, memberDisplayName)
  if activeSession then
    updateTracking()
  end
end

-- Slash commands
SLASH_COMMANDS["/sgtattendance"] = function(args)
  if args == "" or args == "help" then
    d(SF.func._L("ScrollkeeperAttendance", "HELP_HEADER"))
    d(SF.func._L("ScrollkeeperAttendance", "HELP_START"))
    d(SF.func._L("ScrollkeeperAttendance", "HELP_STOP"))
    d(SF.func._L("ScrollkeeperAttendance", "HELP_STATUS"))
    return
  end
  
  local cmd, eventName = string.match(args, "^(%S+)%s*(.*)$")
  if not cmd then cmd = args end
  
  if cmd == "start" then
    startTracking(eventName)
  elseif cmd == "stop" then
    stopTracking()
  elseif cmd == "status" then
    if not activeSession then
      d(SF.func._L("ScrollkeeperAttendance", "STATUS_NO_SESSION"))
    else
      local duration = math.floor((GetTimeStamp() - activeSession.startTime) / 60)
      d(string.format(SF.func._L("ScrollkeeperAttendance", "STATUS_ACTIVE"), 
        activeSession.eventName, 
        duration,
        table.count(activeSession.attendees)))
    end
  else
    d(SF.func._L("ScrollkeeperAttendance", "ERROR_UNKNOWN_COMMAND"))
  end
end

-- Shorter alias
SLASH_COMMANDS["/att"] = SLASH_COMMANDS["/attendance"]

-- Build settings controls
local function buildControls()
  local settings = getSettings()
  
  return {
    {
      type = "submenu",
      name = SF.func._L("ScrollkeeperAttendance", "SUBMENU_NAME"),
      controls = {
        {
          type = "description",
          text = SF.func._L("ScrollkeeperAttendance", "DESCRIPTION"),
        },
        {
          type = "checkbox",
          name = SF.func._L("ScrollkeeperAttendance", "MASTER_ENABLE"),
          tooltip = SF.func._L("ScrollkeeperAttendance", "MASTER_ENABLE_TIP"),
          getFunc = function() return settings.enabled end,
          setFunc = function(v) settings.enabled = v end,
          default = defaults.enabled,
        },
        {
          type = "header",
          name = SF.func._L("ScrollkeeperAttendance", "HEADER_COMMANDS"),
        },
        {
          type = "description",
          text = SF.func._L("ScrollkeeperAttendance", "COMMANDS_DESC"),
        },
        {
          type = "header",
          name = SF.func._L("ScrollkeeperAttendance", "HEADER_HISTORY"),
        },
        {
          type = "description",
          text = function()
            local settings = getSettings()
            local sessions = settings.sessions or {}
            
            if #sessions == 0 then
              return SF.func._L("ScrollkeeperAttendance", "NO_SESSIONS")
            end
            
            local text = string.format(SF.func._L("ScrollkeeperAttendance", "SESSIONS_COUNT"), #sessions) .. "\n\n"
            
            -- Show last 5 sessions
            local startIdx = math.max(1, #sessions - 4)
            for i = #sessions, startIdx, -1 do
              local session = sessions[i]
              text = text .. string.format("• %s (%s) - %d attendees\n",
                session.eventName,
                os.date("%Y-%m-%d", session.startTime),
                table.count(session.attendees))
            end
            
            return text
          end,
        },
        {
          type = "button",
          name = SF.func._L("ScrollkeeperAttendance", "BTN_CLEAR_HISTORY"),
          tooltip = SF.func._L("ScrollkeeperAttendance", "BTN_CLEAR_HISTORY_TIP"),
          func = function()
            local settings = getSettings()
            settings.sessions = {}
            d(SF.func._L("ScrollkeeperAttendance", "SUCCESS_HISTORY_CLEARED"))
          end,
          warning = SF.func._L("ScrollkeeperAttendance", "WARNING_CLEAR_HISTORY"),
          width = "half",
        },
      },
    },
  }
end

-- Initialize
local function initialize()
  if _addon._initialized then return end
  
  local settings = getSettings()
  if not settings then return end
  
  -- Register with framework
  if SF_Set and SF_Set.RegisterModuleOptions then
    local controls = buildControls()
    SF_Set.RegisterModuleOptions(_addon.Name, controls)
  end
  
  -- Register event handlers
  if settings.enabled then
    EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GROUP_MEMBER_JOINED, onGroupMemberJoined)
    EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GROUP_MEMBER_LEFT, onGroupMemberLeft)
    
    -- Periodic update for tracking
    EVENT_MANAGER:RegisterForUpdate(_addon.Name .. "_Update", 30000, function()
      if activeSession then
        updateTracking()
      end
    end)
  end
  
  _addon._initialized = true
end

-- Register for proper initialization
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_PLAYER_ACTIVATED, function()
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_PLAYER_ACTIVATED)
  initialize()
end)

CALLBACK_MANAGER:RegisterCallback("Scrollkeeper_Initialized", initialize)