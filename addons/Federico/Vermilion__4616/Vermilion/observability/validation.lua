Vermilion = Vermilion or {}
local Vermilion = Vermilion

Vermilion.Validation = {}
local M = Vermilion.Validation

local NOOP = function() end
M.pool_acquired         = NOOP
M.pool_released         = NOOP
M.check_pool_balanced   = function() return 0 end
M.check_monotonic_clock = NOOP
M.check_ring_sane       = NOOP
M.check_payload_shape   = NOOP
M.run_all_checks        = function() return { failure_count = 0, pool_outstanding = 0, failures = {} } end
M.report_lines          = function() return { "[validate] disabled (DEBUG=false)" } end
M.dump_to_chat          = function() d("[validate] disabled (DEBUG=false)") end
M.reset                 = NOOP

if not Vermilion.Constants.DEBUG then return end

local outstanding = {}
local failures    = {}

local function record_failure(check, details)
  failures[#failures+1] = {
    t       = Vermilion.zenimax.api.GetGameTimeMilliseconds(),
    check   = check,
    details = details,
  }
  if Vermilion.Log and Vermilion.Log.write then
    Vermilion.Log.write("error", "validation." .. check, details)
  end
end

function M.pool_acquired(label, rec)
  if not rec or not rec._pool_idx then return end
  local s = outstanding[label]
  if not s then s = {}; outstanding[label] = s end
  if s[rec._pool_idx] then
    record_failure("pool.double_acquire",
      { pool = label, pool_idx = rec._pool_idx })
  end
  s[rec._pool_idx] = true
end

function M.pool_released(label, rec)
  if not rec or not rec._pool_idx then return end
  local s = outstanding[label]
  if not s or not s[rec._pool_idx] then
    record_failure("pool.released_unowned",
      { pool = label, pool_idx = rec and rec._pool_idx })
    return
  end
  s[rec._pool_idx] = nil
end

function M.check_pool_balanced(label)
  local s = outstanding[label]
  local count = 0
  if s then for _ in pairs(s) do count = count + 1 end end
  return count
end

function M.check_monotonic_clock(prev_t, cur_t, where)
  if cur_t < prev_t then
    record_failure("clock.regression",
      { prev = prev_t, cur = cur_t, where = where })
  end
end

function M.check_ring_sane(ring, label)
  if not ring or not ring.head or not ring.tail or not ring.capacity then
    record_failure("ring.shape", { label = label })
    return
  end
  local size = ring.tail - ring.head + 1
  if size < 0 or size > ring.capacity then
    record_failure("ring.size_out_of_bounds",
      { label = label, head = ring.head, tail = ring.tail, capacity = ring.capacity })
  end
end

function M.check_payload_shape(payload, expected_keys, label)
  if type(payload) ~= "table" then
    record_failure("payload.not_table", { label = label })
    return
  end
  for k in pairs(expected_keys) do
    if payload[k] == nil then
      record_failure("payload.missing_key", { label = label, key = k })
    end
  end
  for k in pairs(payload) do
    if not expected_keys[k] and not tostring(k):match("^_") then
      record_failure("payload.unexpected_key", { label = label, key = k })
    end
  end
end

function M.run_all_checks()
  local leaked_count = 0
  for _, s in pairs(outstanding) do
    for _ in pairs(s) do leaked_count = leaked_count + 1 end
  end
  return {
    failure_count    = #failures,
    pool_outstanding = leaked_count,
    failures         = failures,
  }
end

local function format_details(d_)
  if type(d_) == "table" then
    local parts = {}
    for k, v in pairs(d_) do
      parts[#parts+1] = tostring(k) .. "=" .. tostring(v)
    end
    return table.concat(parts, " ")
  end
  return tostring(d_)
end

function M.report_lines()
  local r = M.run_all_checks()
  local lines = { string.format("[validate] failures=%d  pool_outstanding=%d",
    r.failure_count, r.pool_outstanding) }
  for _, f in ipairs(failures) do
    lines[#lines+1] = string.format("  t=%d %s  %s",
      f.t, f.check, format_details(f.details))
  end
  return lines
end

function M.dump_to_chat()
  local lines = M.report_lines()
  for _, l in ipairs(lines) do d(l) end
  if Vermilion.CopyBox and Vermilion.CopyBox.show then
    Vermilion.CopyBox.show("Vermilion /validate", table.concat(lines, "\n"))
  end
end

function M.reset()
  outstanding = {}
  failures    = {}
end
