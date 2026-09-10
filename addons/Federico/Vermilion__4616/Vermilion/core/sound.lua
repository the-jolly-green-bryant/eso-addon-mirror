Vermilion = Vermilion or {}
local Vermilion = Vermilion

Vermilion.Sound = {}
local M = Vermilion.Sound

local CUE = {
  open        = "BOOK_OPEN",
  close       = "BOOK_CLOSE",
  page        = "BOOK_PAGE_TURN",
  on          = "TREE_HEADER_CLICK",
  off         = "TREE_SUBCATEGORY_CLICK",
  confirm     = "TREE_HEADER_CLICK",
  click       = "DEFAULT_CLICK",
  record      = "SKILLS_ADVISOR_SELECT",
  stop        = "QUICKSLOT_CLOSE",
  save        = "BOOK_ACQUIRED",
  deny        = "NEGATIVE_CLICK",
  discard     = "DIALOG_DECLINE",
  arm         = "ABILITY_SLOTTED",
  alert_ready = "ABILITY_READY",
  alert_timer = "NEW_TIMED_NOTIFICATION",
}

local ORDER = {
  "open", "close", "page", "on", "off", "confirm", "click", "record", "stop",
  "save", "deny", "discard", "arm", "alert_ready", "alert_timer",
}

local AUDITION = {
  "BOOK_OPEN", "BOOK_CLOSE", "BOOK_PAGE_TURN", "BOOK_ACQUIRED",
  "TREE_HEADER_CLICK", "TREE_SUBCATEGORY_CLICK", "MENU_BAR_CLICK", "DEFAULT_CLICK",
  "TAMRIEL_TOMES_NAVIGATE_FORWARD", "SKILLS_ADVISOR_SELECT", "QUICKSLOT_CLOSE",
  "GAMEPAD_MENU_FORWARD", "GAMEPAD_MENU_BACK", "MAP_LOCATION_CLICKED",
  "CHAMPION_SPINNER_UP", "CHAMPION_SPINNER_DOWN", "DIALOG_ACCEPT", "DIALOG_DECLINE",
  "NEGATIVE_CLICK", "ABILITY_SLOTTED", "ABILITY_READY", "NEW_TIMED_NOTIFICATION",
}

local audition_i = 0

function M.name(cue) return CUE[cue] end

function M.cues() return ORDER end

function M.play(cue)
  local key = CUE[cue]
  if not key then return end
  local id = SOUNDS and SOUNDS[key]
  if id then Vermilion.zenimax.ui.PlaySound(id) end
end

function M.audition(arg)
  arg = (arg or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if arg == "" then
    d("[Vm] sound cues:")
    for _, cue in ipairs(ORDER) do d("  " .. cue .. "  =  " .. CUE[cue]) end
    d("[Vm] /vermilion sound next   plays the audition list one by one")
    d("[Vm] /vermilion sound NAME   plays any SOUNDS.NAME")
    return
  end
  local key
  if arg == "next" then
    audition_i = (audition_i % #AUDITION) + 1
    key = AUDITION[audition_i]
  else
    key = arg:upper()
  end
  local id = SOUNDS and SOUNDS[key]
  if not id then
    d("[Vm] no sound named " .. key)
    return
  end
  PlaySound(id)
  d("[Vm] sound " .. key)
end
