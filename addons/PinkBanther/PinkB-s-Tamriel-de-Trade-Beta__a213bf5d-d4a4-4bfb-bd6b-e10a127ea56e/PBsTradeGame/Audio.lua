-- Public ESO money transaction cue; no external audio file or global volume changes.
local A={}; PBTrade.Audio=A
local C=PBTrade.Config.coins
function A.Play(kind)
    if not PlaySound or not SOUNDS then return false end
    local sound=SOUNDS[PBTrade.Config.uiSounds[kind] or ""]
    if not sound or sound=="No_Sound" then return false end
    PlaySound(sound); return true
end
function A.Impact(visual,impacts)
    if not C.soundEnabled or impacts<=0 or not PlaySound or not SOUNDS then return false end
    local sound=SOUNDS[C.soundKey]
    if not sound or sound=="No_Sound" then return false end
    if visual.lastSound and visual.time-visual.lastSound<C.soundInterval then return false end
    visual.lastSound=visual.time
    PlaySound(sound)
    return true
end
