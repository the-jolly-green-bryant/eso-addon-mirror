LibAlchemy = {}
LibAlchemy.isMMInitialized = false -- Master Merchant
LibAlchemy.isMTInitialized = false -- Market Tracker Addon
LibAlchemy.isArkadiusInitialized = false -- Arkadius Trade Tools
LibAlchemy.isTTCInitialized = false -- Tamriel Trade Centre
LibAlchemy.isTSCInitialized = false -- Tamriel Savings Co
LibAlchemy.isAttInitialized = false -- Alchemy Tool Tip

LibAlchemy.SOURCE_MM = 1
LibAlchemy.SOURCE_MT = 2
LibAlchemy.SOURCE_ATT = 3
LibAlchemy.SOURCE_TTC = 4
LibAlchemy.SOURCE_TSC = 5
LibAlchemy.SOURCE_ATTip = 6

LibAlchemy.show_log = false
LibAlchemy.loggerName = 'InventoryInsight'
if LibDebugLogger then
  LibAlchemy.logger = LibDebugLogger.Create(LibAlchemy.loggerName)
end

local logger
local viewer
if DebugLogViewer then viewer = true else viewer = false end
if LibDebugLogger then logger = true else logger = false end

local function create_log(log_type, log_content)
  if not viewer and log_type == "Info" then
    CHAT_ROUTER:AddSystemMessage(log_content)
    return
  end
  if not LibAlchemy.show_log then return end
  if logger and log_type == "Debug" then
    LibAlchemy.logger:Debug(log_content)
  end
  if logger and log_type == "Info" then
    LibAlchemy.logger:Info(log_content)
  end
  if logger and log_type == "Verbose" then
    LibAlchemy.logger:Verbose(log_content)
  end
  if logger and log_type == "Warn" then
    LibAlchemy.logger:Warn(log_content)
  end
end

local function emit_message(log_type, text)
  if (text == "") then
    text = "[Empty String]"
  end
  create_log(log_type, text)
end

local function emit_table(log_type, t, indent, table_history)
  indent = indent or "."
  table_history = table_history or {}

  if not t then
    emit_message(log_type, indent .. "[Nil Table]")
    return
  end

  if next(t) == nil then
    emit_message(log_type, indent .. "[Empty Table]")
    return
  end

  for k, v in pairs(t) do
    local vType = type(v)

    emit_message(log_type, indent .. "(" .. vType .. "): " .. tostring(k) .. " = " .. tostring(v))

    if (vType == "table") then
      if (table_history[v]) then
        emit_message(log_type, indent .. "Avoiding cycle on table...")
      else
        table_history[v] = true
        emit_table(log_type, v, indent .. "  ", table_history)
      end
    end
  end
end

local function emit_userdata(log_type, udata)
  local function_limit = 5  -- Limit the number of functions displayed
  local total_limit = 10   -- Total number of entries to display (functions + non-functions)
  local function_count = 0  -- Counter for functions
  local entry_count = 0     -- Counter for total entries displayed

  emit_message(log_type, "Userdata: " .. tostring(udata))

  local meta = getmetatable(udata)
  if meta and meta.__index then
    for k, v in pairs(meta.__index) do
      -- Show function name for functions
      if type(v) == "function" then
        if function_count < function_limit then
          emit_message(log_type, "  Function: " .. tostring(k))  -- Function name
          function_count = function_count + 1
          entry_count = entry_count + 1
        end
      elseif type(v) ~= "function" then
        -- For non-function entries (like tables or variables), show them
        emit_message(log_type, "  " .. tostring(k) .. ": " .. tostring(v))
        entry_count = entry_count + 1
      end

      -- Stop when we've reached the total limit
      if entry_count >= total_limit then
        emit_message(log_type, "  ... (output truncated due to limit)")
        break
      end
    end
  else
    emit_message(log_type, "  (No detailed metadata available)")
  end
end

local function contains_placeholders(str)
  return type(str) == "string" and str:find("<<%d+>>")
end

function LibAlchemy:dm(log_type, ...)
  local num_args = select("#", ...)
  local first_arg = select(1, ...)  -- The first argument is always the message string

  -- Check if the first argument is a string with placeholders
  if type(first_arg) == "string" and contains_placeholders(first_arg) then
    -- Extract any remaining arguments for zo_strformat (after the message string)
    local remaining_args = { select(2, ...) }

    -- Format the string with the remaining arguments
    local formatted_value = zo_strformat(first_arg, unpack(remaining_args))

    -- Emit the formatted message
    emit_message(log_type, formatted_value)
  else
    -- Process other argument types (userdata, tables, etc.)
    for i = 1, num_args do
      local value = select(i, ...)
      if type(value) == "userdata" then
        emit_userdata(log_type, value)
      elseif type(value) == "table" then
        emit_table(log_type, value)
      else
        emit_message(log_type, tostring(value))
      end
    end
  end
end
