
Verditer = Verditer or {}
local Verditer = Verditer

Verditer.Sound = {}
local S = Verditer.Sound

local PlaySound               = PlaySound
local GetGameTimeMilliseconds = GetGameTimeMilliseconds
local SOUNDS                  = SOUNDS

local MAP = {
  WINDOW_OPEN  = SOUNDS.DIALOG_SHOW,     -- a window appears
  WINDOW_CLOSE = SOUNDS.DIALOG_HIDE,     -- a window dismissed
  RECORD       = SOUNDS.DIALOG_ACCEPT,   -- start recording (positive)
  STOP         = SOUNDS.DEFAULT_CLICK,   -- stop (neutral)
  FLUSH        = SOUNDS.DIALOG_DECLINE,  -- clear the session (destructive)
  PAGE         = SOUNDS.BOOK_PAGE_TURN,  -- page through death recaps
  CLICK        = SOUNDS.DEFAULT_CLICK,   -- generic
}

function S.play(name)
  local id = MAP[name]
  if id then PlaySound(id) end
end

local SLIDER_SOUND   = SOUNDS.COUNTDOWN_TICK
local SLIDER_MIN_GAP = 45
local last_slider_ms = 0

function S.slider()
  local now = GetGameTimeMilliseconds()
  if now - last_slider_ms < SLIDER_MIN_GAP then return end
  last_slider_ms = now
  PlaySound(SLIDER_SOUND)
end
