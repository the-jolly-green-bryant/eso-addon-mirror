local FTC = FTC
FTC.Logger = {}
FTC.Logger.name = "FTC"

FTC.Logger.show_log = false
if LibDebugLogger then
  FTC.Logger.logger = LibDebugLogger.Create(FTC.Logger.name)
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
  if not FTC.Logger.show_log then return end
  if logger and log_type == "Debug" then
    FTC.Logger.logger:Debug(log_content)
  end
  if logger and log_type == "Info" then
    FTC.Logger.logger:Info(log_content)
  end
  if logger and log_type == "Verbose" then
    FTC.Logger.logger:Verbose(log_content)
  end
  if logger and log_type == "Warn" then
    FTC.Logger.logger:Warn(log_content)
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

function FTC.Logger:dm(log_type, ...)
  for i = 1, select("#", ...) do
    local value = select(i, ...)
    if (type(value) == "table") then
      emit_table(log_type, value)
    else
      emit_message(log_type, tostring(value))
    end
  end
end
