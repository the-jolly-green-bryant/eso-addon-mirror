-- ============================================================================
-- AetherChat : Sound Manager (Customizable High-Audibility Sound Catalog)
-- ============================================================================
AetherChat = AetherChat or {}
local AetherChat = AetherChat

AetherChat.SoundManager = {}
local SoundManager = AetherChat.SoundManager
local Settings = AetherChat.Settings

SoundManager.SOUND_CATALOG = {
    champion = {
        name = "Carillon Céleste (Point Champion - Fort & Cristallin)",
        soundId = SOUNDS.CHAMPION_POINT_GAINED,
    },
    notification_ding = {
        name = "Notification Nette (Ding Moderne & Clair)",
        soundId = SOUNDS.NEW_TIMED_NOTIFICATION,
    },
    achievement = {
        name = "Fanfare Dorée (Succès / Triomphe)",
        soundId = SOUNDS.ACHIEVEMENT_AWARDED,
    },
    magic_bell = {
        name = "Résonance Magique (Cloche Mystique)",
        soundId = SOUNDS.ABILITY_MORPH_PURCHASED,
    },
    gong = {
        name = "Gong de Combat (Cloche de Défi)",
        soundId = SOUNDS.DUEL_ACCEPTED,
    },
    quest = {
        name = "Harmonie de Quête (Cors & Cloches)",
        soundId = SOUNDS.QUEST_COMPLETED,
    },
    default_whisper = {
        name = "Chuchotement Discret (Son d'origine ESO)",
        soundId = SOUNDS.TELL_MESSAGE,
    },
}

function SoundManager.PlayIncomingAlert(channelKey)
    local soundKey = Settings.Get('whisperSound', 'champion')
    local entry = SoundManager.SOUND_CATALOG[soundKey] or SoundManager.SOUND_CATALOG.champion
    local soundId = (entry and entry.soundId) or SOUNDS.CHAMPION_POINT_GAINED

    if channelKey and channelKey:sub(1, 3) == 'dm:' then
        if Settings.Get('soundOnWhisper', true) then
            PlaySound(soundId)
        end
    elseif channelKey and channelKey:find('^guild') then
        if Settings.Get('soundOnGuild', false) then
            PlaySound(soundId)
        end
    elseif channelKey == 'party' then
        if Settings.Get('soundOnParty', false) then
            PlaySound(soundId)
        end
    end
end

function SoundManager.PlayWhisperAlert()
    local soundKey = Settings.Get('whisperSound', 'champion')
    local entry = SoundManager.SOUND_CATALOG[soundKey] or SoundManager.SOUND_CATALOG.champion
    local soundId = (entry and entry.soundId) or SOUNDS.CHAMPION_POINT_GAINED
    PlaySound(soundId)
end

function SoundManager.PlaySoundPreview(soundKey)
    local entry = SoundManager.SOUND_CATALOG[soundKey] or SoundManager.SOUND_CATALOG.champion
    local soundId = (entry and entry.soundId) or SOUNDS.CHAMPION_POINT_GAINED
    PlaySound(soundId)
end

function SoundManager.PlayMessageSent()
    PlaySound(SOUNDS.DEFAULT_CLICK)
end
