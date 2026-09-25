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
    -- Tick returns one impact for every visible coin that touched its stack. Do not throttle
    -- this signal: dense opening volleys should sound dense, while the thinning tail naturally
    -- becomes sparse. Calls in the same frame are intentional; ESO mixes them as a stronger
    -- burst instead of silently dropping most of the landed coins.
    for _=1,math.floor(impacts) do PlaySound(sound) end
    visual.lastSound=visual.time
    return true
end
-- Background music via ESO's UI music override (the same public API PBsTetris uses).
-- Add-ons cannot ship music files, but the client offers several override tracks; each screen
-- asks for the one that fits it. Constants are resolved on first use (they live in the client).
A.musicEnabled=true
A.screenMusic={title="credits",opening="credits",naming="credits",battle="dueling",result="dueling"}
A.defaultMusic="tribute"
local overrides
local function override(key)
    if not overrides then
        overrides={tribute=OVERRIDE_MUSIC_MODE_TRIBUTE,dueling=OVERRIDE_MUSIC_MODE_DUELING,
            credits=OVERRIDE_MUSIC_MODE_CREDITS,champion=OVERRIDE_MUSIC_MODE_CHAMPION}
    end
    return overrides[key] or overrides.champion
end
function A.MusicFor(screen) return A.screenMusic[screen] or A.defaultMusic end
-- Keeps the override in step with the screen. Remembers the mode it replaced so it can hand
-- it back, and steps aside for good if something else takes the override meanwhile.
function A.SyncMusic(screen)
    if not A.musicEnabled or A.musicBroken or A.musicYielded then return false end
    if type(SetOverrideMusicMode)~="function" then A.musicBroken=true; return false end
    local want=override(A.MusicFor(screen)); if want==nil then A.musicBroken=true; return false end
    local current=type(GetOverrideMusicMode)=="function" and GetOverrideMusicMode() or nil
    if A.musicOn then
        if A.musicMode==want then return true end
        if current~=nil and current~=A.musicMode then A.musicOn=false; A.musicYielded=true; return false end
    end
    local ok=pcall(SetOverrideMusicMode,want)
    if not ok then A.musicBroken=true; return false end
    if not A.musicOn then A.musicPrevious=current end
    A.musicOn=true; A.musicMode=want; A.musicKey=A.MusicFor(screen)
    return true
end
function A.StartMusic(screen) return A.SyncMusic(screen or "map") end
function A.StopMusic()
    if A.musicOn then
        local current=type(GetOverrideMusicMode)=="function" and GetOverrideMusicMode() or A.musicMode
        if current==A.musicMode then
            pcall(SetOverrideMusicMode,A.musicPrevious~=nil and A.musicPrevious or OVERRIDE_MUSIC_MODE_NONE)
        end
    end
    A.musicOn=false; A.musicMode=nil; A.musicPrevious=nil; A.musicYielded=nil
end
function A.SetMusicEnabled(on,screen)
    A.musicEnabled=on and true or false
    if A.musicEnabled then A.SyncMusic(screen) else A.StopMusic() end
end
return A
