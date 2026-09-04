local C = Chorus
local S = Chorus.Strings
local API = Chorus.API

local function applySettings()
    C.engine:Configure(Chorus.Settings.EngineOptions())
    Chorus.Text.ApplyFont()
    if Chorus.Text.unlocked then Chorus.Text.Render(Chorus.Text.PreviewView()) end
end

local function setLocked(locked)
    Chorus.Settings.sv.locked = locked
    Chorus.Text.SetUnlocked(not locked)
    API.Print(S.Get(locked and "LOCKED" or "UNLOCKED"))
end

local PREVIEW = {
    { 0,    "Burning Embers",    412,   true },
    { 150,  "Fiery Grip",        4120 },
    { 300,  "Burning Embers",    418,   true },
    { 320,  "Whirling Blades",   3200 }, { 325, "Whirling Blades", 3100 }, { 331, "Whirling Blades", 3300 },
    { 900,  "Rapid Strikes",     1800 }, { 1050, "Rapid Strikes", 1900 }, { 1200, "Rapid Strikes", 1850 },
    { 1400, "Burning Embers",    405,   true },
    { 1700, "Crystal Fragments", 31200, false, true },
    { 2400, "Burning Embers",    420,   true },
    { 2700, "Fiery Grip",        4300 },
}
local function preview()
    local start = API.Now()
    local names = {}
    for _, p in ipairs(PREVIEW) do
        zo_callLater(function()
            local id = names[p[2]] or (#names + 1); names[p[2]] = id
            C.engine:Hit(API.Now(), { id = 9000 + id, name = p[2], amount = p[3], tick = p[4] == true, crit = p[5] == true, kind = "damage" })
            Chorus.Events.StartTicking()
        end, p[1])
    end
end

local function listFonts()
    API.Print(S.Get("FONTS_HEAD"))
    for _, f in ipairs(Chorus.Fonts.List()) do API.Print("  " .. f.key .. "  -  " .. f.label) end
end

local function setFont(key)
    for _, f in ipairs(Chorus.Fonts.List()) do
        if f.key == key then
            Chorus.Settings.sv.font = key
            applySettings()
            API.Print(S.Get("FONT_SET", f.label))
            return
        end
    end
    API.Print(S.Get("FONT_UNKNOWN", key))
end

function C.Slash(args)
    local cmd, rest = (args or ""):match("^(%S*)%s*(.-)$")
    cmd = (cmd or ""):lower()
    if cmd == "unlock" then setLocked(false)
    elseif cmd == "lock" then setLocked(true)
    elseif cmd == "test" then preview()
    elseif cmd == "fonts" then listFonts()
    elseif cmd == "font" then setFont(rest)
    elseif cmd == "summary" then
        local sv = Chorus.Settings.sv
        sv.summary = not sv.summary
        API.Print(S.Get(sv.summary and "SUMMARY_ON" or "SUMMARY_OFF"))
    else API.Print(S.Get("HELP")) end
end

local function onAddOnLoaded(_, addonName)
    if addonName ~= C.name then return end
    EVENT_MANAGER:UnregisterForEvent(C.name, EVENT_ADD_ON_LOADED)
    S.SetLanguage(API.Language())
    API.ResetNames()
    local sv = Chorus.Settings.Init()
    C.engine = Chorus.Engine.New(Chorus.Settings.EngineOptions())
    Chorus.Text.Init(sv)
    Chorus.Events.Init(C.engine, sv, { onShow = Chorus.Text.Show, onHide = Chorus.Text.Hide, onTick = Chorus.Text.Render })
    Chorus.Menu.Init(sv, { apply = applySettings, lock = function(locked) Chorus.Text.SetUnlocked(not locked) end,
        resetPosition = Chorus.Text.ResetPosition, preview = preview })
    if not sv.locked then Chorus.Text.SetUnlocked(true) end
    SLASH_COMMANDS["/chorus"] = C.Slash
    C.ready = true
end
EVENT_MANAGER:RegisterForEvent(C.name, EVENT_ADD_ON_LOADED, onAddOnLoaded)
