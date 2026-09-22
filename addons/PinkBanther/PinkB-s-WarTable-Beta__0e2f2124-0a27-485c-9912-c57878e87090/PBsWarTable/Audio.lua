-- Short cues for board events. Named outright rather than looked up by guesswork: the client's
-- SOUNDS table is not guaranteed to hold every name, so each cue carries fallbacks and the
-- module stays silent when none of them exist.
local A={}; PBWT.Audio=A
A.CUES={
    -- Tales of Tribute's knock-out cue: the sound of a card being destroyed on the board.
    defeat={'TRIBUTE_AGENT_KNOCKED_OUT','TRIBUTE_AGENT_DAMAGED','DEFAULT_CLICK'},
    -- A wooden tablet set down on the table.
    move={'ENCHANTING_POTENCY_RUNE_PLACED','DEFAULT_CLICK'},
}
A.THROTTLE={defeat=0.05,move=0.08}
A.last={}
function A.Resolve(cue)
    if not SOUNDS then return nil end
    for _,name in ipairs(A.CUES[cue] or {}) do
        if SOUNDS[name] then return SOUNDS[name],name end
    end
end
-- Tales of Tribute's match music while the table is open. The client hands the override to
-- whoever asks last, so the request is only made once, released on the way out, and dropped
-- for good if something else takes it over: fighting another add-on for the music is worse
-- than silence. Named outright, because the constant is not a plain global on every client.
function A.MusicMode()
    if A.mode==nil then A.mode=OVERRIDE_MUSIC_MODE_TRIBUTE or false end
    return A.mode
end
function A.MusicEnabled()
    local data=PBWT.Records and PBWT.Records.Data and PBWT.Records.Data()
    return not data or data.music~=false
end
function A.Music(active)
    local want=active and A.MusicEnabled() and A.MusicMode()
    if not (GetOverrideMusicMode and SetOverrideMusicMode) then return false end
    if not want then return A.ReleaseMusic() end
    if A.owned then
        if GetOverrideMusicMode()~=A.requested then
            -- Someone else owns it now; stand down and stay down for this session.
            A.owned,A.previous,A.yielded=false,nil,true
        end
        return A.owned
    end
    if A.yielded then return false end
    local previous=GetOverrideMusicMode()
    if pcall(SetOverrideMusicMode,want) then
        A.owned,A.previous,A.requested=true,previous,want
        return true
    end
    return false
end
function A.ReleaseMusic()
    if A.owned then
        if GetOverrideMusicMode and GetOverrideMusicMode()==A.requested then
            pcall(SetOverrideMusicMode,A.previous)
        end
        A.owned,A.previous,A.requested=false,nil,nil
    end
    return false
end
function A.Play(cue)
    if not A.CUES[cue] or not PlaySound then return false end
    local now=GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    local gap=A.THROTTLE[cue] or 0.05
    if now-(A.last[cue] or -100)<gap then return false end
    local id=A.Resolve(cue)
    if not id then return false end
    A.last[cue]=now; PlaySound(id); return true
end
