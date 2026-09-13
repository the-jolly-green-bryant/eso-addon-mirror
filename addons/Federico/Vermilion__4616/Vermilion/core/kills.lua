Vermilion = Vermilion or {}
local Vermilion = Vermilion

Vermilion.Kills = {}
local M = Vermilion.Kills

local CAP = 200
local DEDUPE_MS = 250

local recording = false
local n = 0
local kill_t    = {}
local kill_uid  = {}
local kill_name = {}
local kill_aid  = {}

function M.start_session()
  recording = true
  n = 0
end

function M.finalize()
  recording = false
end

function M.reset()
  recording = false
  n = 0
end

function M.on_kill(t, uid, name, aid)
  Vermilion.Diagnostics.bump("kills.seen")
  if not recording or n >= CAP then return end
  if n > 0 and kill_uid[n] == (uid or 0) and (t - kill_t[n]) <= DEDUPE_MS then return end
  n = n + 1
  kill_t[n]    = t
  kill_uid[n]  = uid or 0
  kill_name[n] = name or ""
  kill_aid[n]  = aid or 0
end

function M.count() return n end
function M.get(i)
  if i < 1 or i > n then return nil end
  return kill_t[i], kill_uid[i], kill_name[i], kill_aid[i]
end
function M.is_recording() return recording end

function M.load_session(recs, t0)
  M.reset()
  for i = 1, #recs do
    local r = recs[i]
    kill_t[i]    = (r.t or 0) + (t0 or 0)
    kill_uid[i]  = r.id or 0
    kill_name[i] = r.name or ""
    kill_aid[i]  = r.aid or 0
  end
  n = #recs
end
