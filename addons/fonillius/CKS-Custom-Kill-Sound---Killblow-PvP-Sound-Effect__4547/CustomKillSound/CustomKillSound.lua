local AddonName = "CustomKillSound"
local savedVars

-- Expanded ESO Sound Library (Over 70 verified API sounds)
local soundCategories = {
    { 
        categoryName = "1. Epic Triumphs & Trials", 
        sounds = { 
            { name = "Duel Won (Gong)", path = SOUNDS.DUEL_WON }, 
            { name = "Trial Completed (Massive Triumph)", path = SOUNDS.RAID_TRIAL_COMPLETED }, 
            { name = "Trial Failed (Loud Thud)", path = SOUNDS.RAID_TRIAL_FAILED }, 
            { name = "Trial Score: Very High", path = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_HIGH },
            { name = "Trial Score: High", path = SOUNDS.RAID_TRIAL_SCORE_ADDED_HIGH },
            { name = "Trial Life Regain (Loud Magic)", path = SOUNDS.RAID_LIFE_REGAIN },
            { name = "Arena Stage Start (Horn)", path = SOUNDS.ARENA_STAGE_START },
            { name = "Arena Stage Complete", path = SOUNDS.ARENA_STAGE_COMPLETE },
            { name = "Tribute Match Won", path = SOUNDS.TRIBUTE_MATCH_WON },
            { name = "Endeavor Completed", path = SOUNDS.ENDEAVOR_COMPLETED }
        } 
    },
    { 
        categoryName = "2. Cyrodiil & Battlegrounds", 
        sounds = { 
            { name = "AvA Gate Opened (Grinding)", path = SOUNDS.AVA_GATE_OPENED }, 
            { name = "AvA Gate Closed (Heavy Thud)", path = SOUNDS.AVA_GATE_CLOSED }, 
            { name = "Emperor Coronated (Aldmeri)", path = SOUNDS.EMPEROR_CORONATED_ALDMERI }, 
            { name = "Emperor Coronated (Daggerfall)", path = SOUNDS.EMPEROR_CORONATED_DAGGERFALL }, 
            { name = "Emperor Coronated (Ebonheart)", path = SOUNDS.EMPEROR_CORONATED_EBONHEART }, 
            { name = "Keep Captured (Aldmeri)", path = SOUNDS.KEEP_CAPTURED_ALDMERI }, 
            { name = "Keep Captured (Daggerfall)", path = SOUNDS.KEEP_CAPTURED_DAGGERFALL }, 
            { name = "Keep Captured (Ebonheart)", path = SOUNDS.KEEP_CAPTURED_EBONHEART }, 
            { name = "BG Team Score (Horn)", path = SOUNDS.BATTLEGROUND_TEAM_SCORE },
            { name = "BG Flag Captured (Loud Cheer)", path = SOUNDS.BATTLEGROUND_CAPTURE_FLAG },
            { name = "BG Minute Warning", path = SOUNDS.BATTLEGROUND_MINUTE_WARNING },
            { name = "Volendrung Spawned", path = SOUNDS.ARTIFACT_SPAWNED }
        } 
    },
    { 
        categoryName = "3. Assassination & Criminal", 
        sounds = { 
            { name = "Blade of Woe Equip (Schwing)", path = SOUNDS.ASSASSINATION_BLADE_EQUIP },
            { name = "Blade of Woe Kill (Stab)", path = SOUNDS.ASSASSINATION_BLADE_KILL },
            { name = "Justice State Changed (Heartbeat)", path = SOUNDS.JUSTICE_STATE_CHANGED }, 
            { name = "Bounty Cleared", path = SOUNDS.JUSTICE_NO_LONGER_KOS },
            { name = "Pickpocket Failed (Sharp Alert)", path = SOUNDS.JUSTICE_PICKPOCKET_FAILED },
            { name = "Pickpocket Success", path = SOUNDS.JUSTICE_PICKPOCKET_SUCCESS },
            { name = "Vampire Feeding", path = SOUNDS.VAMPIRE_FEEDING },
            { name = "Dark Fissure Opened", path = SOUNDS.DARK_FISSURE_OPENED }
        } 
    },
    { 
        categoryName = "4. Heavy Impacts & Steel", 
        sounds = { 
            { name = "Smithing Item Improved (Anvil Smash)", path = SOUNDS.SMITHING_ITEM_IMPROVED }, 
            { name = "Smithing Research Finish", path = SOUNDS.SMITHING_FINISH_RESEARCH }, 
            { name = "Outfit Station Applied (Armor Clank)", path = SOUNDS.OUTFIT_STATION_APPLY_CHANGES }, 
            { name = "Lockpick Broken (Sharp Snap)", path = SOUNDS.LOCKPICKING_FORCE },
            { name = "Group Kick (Harsh Thud)", path = SOUNDS.GROUP_KICK },
            { name = "Group Disband (Heavy Impact)", path = SOUNDS.GROUP_DISBAND },
            { name = "Weapon Swapped", path = SOUNDS.WEAPON_SWAPPED },
            { name = "Duel Start (Swords Cross)", path = SOUNDS.DUEL_START },
            { name = "Strike Locator (Combat Impact)", path = SOUNDS.STRIKE_LOCATOR }
        } 
    },
    { 
        categoryName = "5. Treasure, Gold & Loot", 
        sounds = { 
            { name = "Tel Var Multiplier Up (Coin Chime)", path = SOUNDS.TELVAR_MULTIPLIERUP }, 
            { name = "Tel Var Multiplier Down (Lost)", path = SOUNDS.TELVAR_MULTIPLIERDOWN }, 
            { name = "Money Changed (Gold Coins)", path = SOUNDS.MONEY_CHANGED },
            { name = "Loot Item", path = SOUNDS.LOOT_ITEM },
            { name = "Chest Opened", path = SOUNDS.CHEST_OPENED },
            { name = "Antiquity Unearthed", path = SOUNDS.ANTIQUITIES_DIGGING_ANTIQUITY_UNEARTHED },
            { name = "Scrying Success (Ethereal)", path = SOUNDS.ANTIQUITIES_SCRYING_FINISH_BOARD },
            { name = "Crown Gem Acquired", path = SOUNDS.CROWN_CRATES_GEM_ACQUISITION },
            { name = "Crown Card Reveal (Magic Whoosh)", path = SOUNDS.CROWN_CRATES_OPEN_MANUAL_CARD_REVEAL }
        } 
    },
    { 
        categoryName = "6. Magic, Elements & Crafting", 
        sounds = { 
            { name = "Enchanting Start (Rune Magic)", path = SOUNDS.ENCHANTING_COMPOSE_START_ANIM },
            { name = "Enchanting Extract (Rune Shatter)", path = SOUNDS.ENCHANTING_EXTRACT_START_ANIM },
            { name = "Dye Applied (Splash)", path = SOUNDS.DYEING_APPLY_CHANGES },
            { name = "Alchemy Potion Created", path = SOUNDS.ALCHEMY_CREATE_TOOLTIP },
            { name = "Champion Points Respec (Magic)", path = SOUNDS.CHAMPION_RESPEC_ACCEPT },
            { name = "Thunder Rain", path = SOUNDS.THUNDER_RAIN },
            { name = "Water Splash", path = SOUNDS.WATER_SPLASH },
            { name = "Campfire Crackle", path = SOUNDS.CAMPFIRE_CRACKLE }
        } 
    },
    { 
        categoryName = "7. Level Ups & Progression", 
        sounds = { 
            { name = "Level Up (Classic)", path = SOUNDS.LEVEL_UP }, 
            { name = "Ultimate Ready (Whoosh)", path = SOUNDS.ABILITY_ULTIMATE_READY }, 
            { name = "Achievement Awarded (Loud Chime)", path = SOUNDS.ACHIEVEMENT_AWARDED }, 
            { name = "Champion Point Gained", path = SOUNDS.CHAMPION_POINT_GAINED }, 
            { name = "Quest Complete", path = SOUNDS.QUEST_COMPLETED }, 
            { name = "Skill Line Leveled Up", path = SOUNDS.SKILL_LINE_LEVELED_UP },
            { name = "Book Acquired (Page Turn)", path = SOUNDS.BOOK_ACQUIRED }
        } 
    },
    { 
        categoryName = "8. UI, Alerts & Oddities", 
        sounds = { 
            { name = "Group Joined", path = SOUNDS.GROUP_JOIN }, 
            { name = "Notification Alert", path = SOUNDS.NEW_TIMED_NOTIFICATION }, 
            { name = "Role Check (Ping)", path = SOUNDS.LFG_ROLE_CHECK }, 
            { name = "Dungeon Ready Pop", path = SOUNDS.LFG_COMPLETE_ANNOUNCEMENT },
            { name = "Election Requested", path = SOUNDS.GROUP_ELECTION_REQUESTED },
            { name = "Election Failed (Warning Thump)", path = SOUNDS.GROUP_ELECTION_FAILED },
            { name = "Guild Member Added", path = SOUNDS.GUILD_ROSTER_ADDED },
            { name = "Trading House Search (Swoosh)", path = SOUNDS.TRADING_HOUSE_SEARCH_INITIATED },
            { name = "Mount Summoned", path = SOUNDS.MOUNT_SUMMONED }
        } 
    }
}

-- Default Settings
local defaultSettings = {
    selectedSounds = {},
    debugMode = false,
    
    playbackStyle = 1, -- 1: Normal, 2: Stutter, 3: Echo
    effectMaxVolume = false,
    effectCinematicMute = false,
    effectBuildUp = false
}

for _, category in ipairs(soundCategories) do
    for _, soundInfo in ipairs(category.sounds) do
        if soundInfo.path ~= nil then
            if soundInfo.path == SOUNDS.LOCKPICKING_FORCE or soundInfo.path == SOUNDS.TRIAL_FAILED then
                defaultSettings.selectedSounds[soundInfo.path] = false
            else
                defaultSettings.selectedSounds[soundInfo.path] = true
            end
        end
    end
end

local function DebugLog(message)
    if savedVars.debugMode then d("|cFF00FF[CKS Debug]|r " .. message) end
end

-------------------------------------------------------------------
-- THE AUDIO ENGINE (Effects Processing)
-------------------------------------------------------------------
local originalSFX, originalMusic, originalAmbience
local isAudioManipulated = false

local function RestoreAudio()
    if isAudioManipulated then
        if originalSFX then SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, tostring(originalSFX)) end
        if originalMusic then SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME, tostring(originalMusic)) end
        if originalAmbience then SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME, tostring(originalAmbience)) end
        isAudioManipulated = false
    end
end

local function FireSelectedSounds()
    for soundPath, isEnabled in pairs(savedVars.selectedSounds) do
        if isEnabled then PlaySound(soundPath) end
    end
end

local lastPlayTime = 0
local function PlayKillSoundSequence()
    local now = GetFrameTimeMilliseconds()
    if now - lastPlayTime < 1500 then return end
    lastPlayTime = now

    if not isAudioManipulated then
        originalSFX = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME)
        originalMusic = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME)
        originalAmbience = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME)
    end
    isAudioManipulated = true

    if savedVars.effectMaxVolume then
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, "100")
    end
    if savedVars.effectCinematicMute then
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME, "0")
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME, "0")
    end

    EVENT_MANAGER:RegisterForUpdate(AddonName .. "RestoreAudio", 2000, function()
        EVENT_MANAGER:UnregisterForUpdate(AddonName .. "RestoreAudio")
        RestoreAudio()
    end)

    local delayOffset = 0
    if savedVars.effectBuildUp then
        PlaySound(SOUNDS.TRADING_HOUSE_SEARCH_INITIATED) 
        delayOffset = 400
    end

    zo_callLater(function()
        if savedVars.playbackStyle == 2 then
            FireSelectedSounds()
            zo_callLater(FireSelectedSounds, 80)
            zo_callLater(FireSelectedSounds, 160)
        elseif savedVars.playbackStyle == 3 then
            FireSelectedSounds()
            zo_callLater(FireSelectedSounds, 250)
            zo_callLater(FireSelectedSounds, 500)
        else
            FireSelectedSounds()
        end
    end, delayOffset)

    DebugLog("Kill sequence triggered!")
end

-------------------------------------------------------------------
-- KILL DETECTION
-------------------------------------------------------------------
local function OnPvPKillFeed(eventCode, killLocation, killerPlayerDisplayName, killerCharacterName, killerAlliance, killerRank, victimPlayerDisplayName, victimCharacterName, victimAlliance, victimRank, isKillStreak)
    local myCharName = GetRawUnitName(GetUnitName("player"))
    local myAccountName = GetDisplayName()
    if killerCharacterName == myCharName or killerPlayerDisplayName == myAccountName then
        if victimCharacterName ~= myCharName and victimPlayerDisplayName ~= myAccountName then
            PlayKillSoundSequence()
        end
    end
end

local function OnDuelFinished(eventCode, duelResult, wasLocalPlayersResult, opponentCharacterName)
    if duelResult == DUEL_RESULT_WON and wasLocalPlayersResult == true then
        PlayKillSoundSequence()
    end
end

local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP or result == ACTION_RESULT_KILLING_BLOW then
        local rawSourceName = GetRawUnitName(sourceName)
        local rawTargetName = GetRawUnitName(targetName)
        local myName = GetRawUnitName(GetUnitName("player"))
        local isMe = (rawSourceName == myName or AreUnitsEqual("player", sourceUnitId))

        if isMe and rawTargetName ~= myName and rawTargetName ~= "" then
            PlayKillSoundSequence()
        end
    end
end

-------------------------------------------------------------------
-- SETTINGS UI
-------------------------------------------------------------------
local function SetupMenu()
    local LAM = LibAddonMenu2
    local panelData = { type = "panel", name = "Custom Kill Sound", displayName = "Custom Kill Sound", author = "fonillius", version = "6.0", registerForRefresh = true }
    LAM:RegisterAddonPanel("CustomKillSoundPanel", panelData)

    local optionsData = {
        {
            type = "button", name = "TEST COMBO & EFFECTS",
            tooltip = "Click to hear your combination of sounds with all active Audio Effects applied.",
            func = function() PlayKillSoundSequence() end,
        },
        { type = "header", name = "Audio Effects & Enhancements" },
        {
            type = "dropdown", name = "Playback Style", choices = {"Normal", "M-M-M-Monsterkill (Stutter)", "Echoing Void (Echo)"}, choicesValues = {1, 2, 3},
            getFunc = function() return savedVars.playbackStyle end, setFunc = function(value) savedVars.playbackStyle = value end,
        },
        {
            type = "checkbox", name = "Maximum Overdrive", tooltip = "Boosts game SFX Volume to 100 during the sound.",
            getFunc = function() return savedVars.effectMaxVolume end, setFunc = function(value) savedVars.effectMaxVolume = value end,
        },
        {
            type = "checkbox", name = "Cinematic Silence", tooltip = "Mutes Game Music and Ambient noise for 2 seconds to make the kill sound punchy.",
            getFunc = function() return savedVars.effectCinematicMute end, setFunc = function(value) savedVars.effectCinematicMute = value end,
        },
        {
            type = "checkbox", name = "The Bass Drop (Build-up)", tooltip = "Plays a rushing build-up sound 0.5s before your kill sounds actually drop.",
            getFunc = function() return savedVars.effectBuildUp end, setFunc = function(value) savedVars.effectBuildUp = value end,
        }
    }

    -- Dynamically build Sub-Menus with Category Toggles
    for _, category in ipairs(soundCategories) do
        local submenuControls = {}
        
        -- Category Toggles
        table.insert(submenuControls, {
            type = "button", name = "Enable All", isHalfWidth = true,
            func = function()
                for _, soundInfo in ipairs(category.sounds) do
                    if soundInfo.path ~= nil then savedVars.selectedSounds[soundInfo.path] = true end
                end
                d("|c00FF00[CustomKillSound]|r Enabled all: " .. category.categoryName)
            end
        })
        table.insert(submenuControls, {
            type = "button", name = "Disable All", isHalfWidth = true,
            func = function()
                for _, soundInfo in ipairs(category.sounds) do
                    if soundInfo.path ~= nil then savedVars.selectedSounds[soundInfo.path] = false end
                end
                d("|cFF0000[CustomKillSound]|r Disabled all: " .. category.categoryName)
            end
        })
        table.insert(submenuControls, { type = "divider" })

        -- Individual Sound Checkboxes
        for _, soundInfo in ipairs(category.sounds) do
            if soundInfo.path ~= nil then
                table.insert(submenuControls, {
                    type = "checkbox", name = soundInfo.name,
                    getFunc = function() return savedVars.selectedSounds[soundInfo.path] or false end,
                    setFunc = function(value) savedVars.selectedSounds[soundInfo.path] = value; if value then PlaySound(soundInfo.path) end end,
                })
            end
        end
        table.insert(optionsData, { type = "submenu", name = category.categoryName, controls = submenuControls })
    end

    table.insert(optionsData, { type = "header", name = "Troubleshooting" })
    table.insert(optionsData, {
        type = "checkbox", name = "Enable Debug Mode",
        getFunc = function() return savedVars.debugMode end, setFunc = function(value) savedVars.debugMode = value end,
    })

    LAM:RegisterOptionControls("CustomKillSoundPanel", optionsData)
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= AddonName then return end
    EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_ADD_ON_LOADED)

    savedVars = ZO_SavedVars:NewAccountWide("CustomKillSound_SavedVars", 13, nil, defaultSettings)
    if type(savedVars.selectedSounds) ~= "table" then savedVars.selectedSounds = {} end

    RestoreAudio() 
    SetupMenu()

    EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PVP_KILL_FEED_DEATH, OnPvPKillFeed)
    EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_DUEL_FINISHED, OnDuelFinished)
    EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_COMBAT_EVENT, OnCombatEvent)
end
EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)