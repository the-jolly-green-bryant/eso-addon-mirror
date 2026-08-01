
BGMeter = BGMeter or {}
local BGMeter = BGMeter

local Sound = {}

local CUE = {
    open     = "GAMEPAD_MENU_FORWARD",
    menu     = "BOOK_OPEN",
    match    = "BOOK_PAGE_TURN",
    settings = "TREE_HEADER_CLICK",
    close    = "BOOK_CLOSE",
    win      = "DUEL_WON",
    loss     = "GENERAL_ALERT_ERROR",
    rankup   = "LEVEL_UP",
    pb       = "ACHIEVEMENT_AWARDED",
    nav      = "CHAMPION_SPINNER_UP",
}

function Sound.play(cue)
    if not BGMeter.Prefs.get("sounds") then return end
    local key = CUE[cue]
    if not key then return end
    local id = SOUNDS and SOUNDS[key]
    if id then pcall(PlaySound, id) end
end

Sound.AUDITION = {
    "BOOK_OPEN", "BOOK_PAGE_TURN", "TREE_HEADER_CLICK", "TREE_SUBCATEGORY_CLICK",
    "MENU_BAR_CLICK", "DEFAULT_CLICK", "GAMEPAD_MENU_FORWARD", "GAMEPAD_MENU_BACK",
    "DIALOG_ACCEPT", "QUICKSLOT_CLOSE", "MAP_LOCATION_CLICKED",
    "SKILLS_ADVISOR_SELECT", "TAMRIEL_TOMES_NAVIGATE_FORWARD", "BOOK_ACQUIRED",
}

local audit_i = 0

function Sound.audition(arg)
    if arg and arg ~= "" and arg ~= "next" then
        local key = arg:upper()
        local id = SOUNDS and SOUNDS[key]
        if id then
            pcall(PlaySound, id)
            BGMeter.Log.say("sound: %s", key)
        else
            BGMeter.Log.say("unknown sound '%s'", key)
        end
        return
    end
    audit_i = (audit_i % #Sound.AUDITION) + 1
    local key = Sound.AUDITION[audit_i]
    local id = SOUNDS and SOUNDS[key]
    if id then pcall(PlaySound, id) end
    BGMeter.Log.say("sound %d/%d: %s", audit_i, #Sound.AUDITION, key)
end

BGMeter.Sound = Sound
