-- zo_callLater(functionName, milisecondDelay)
-- ========================================
-- Accessor values
local Kills = 1
local KillingBlows = 2
local Avenge_Kills = 3
local Revent_Kills = 4
local Alliance = 5
local vLevel = 6
local Name = 7
local Level = 8
local Class = 9
local KilledBy = 10
-- ========================================

local counter = 0 -- Current number of kills
local deathCounter = 0
local streak = 0
local rankPointsGained = 0
local apGained = 0 -- current number of AP

local KC_ON = false

-- local queueCampaignID = false
local deathStreak = 0
local overrideHideMain = false

local streak_array = {}
local deathStreak_array = {}
local kb_streak_array = {}

local pushed = 0
local version = 112

local justKilled = {}
local reticle_data = {}

local showingStats = false

local showOOC = false
local doSounds = true

local kbCounter = 0 -- killing blows
local kbStreak = 0

local test_mode = false

-- settings stuff
local showingSettings = false
local settings_window = nil
local settings_table = nil

local currentSession = {
    players = {},
    longestStreak = 0,
    longestDeathStreak = 0,
    longestKBStreak = 0,
    kbSpells = {}
}

-- KC_Fn.table_shallow_copy(t)
local function newPlayerArray() return {0, 0, 0, 0, 0, 0, "", 0, 0, 0} end
local defaultPlayerArray = {}

local defaults = {
    SC = {
        keepsCaptured = 0,
        longestKeepStreak = 0,
        resourcesCaptured = 0,
        longestResourceStreak = 0
    },
    kbSpells = {},
    offsetY = 0,
    anchorPoint = 9,
    longestKBStreak = 0,
    offsetX = 0,
    players = {},
    rankPointsGained = 0,
    longestStreak = 0,
    totalKills = 0,
    totalDeaths = 0,
    version = 112,
    totalKillingBlows = 0,
    longestDeathStreak = 0
}

-- Kill Counter Global -KC_G

KC_G = {
    name = "KillCounter",
    savedVars = {}
    -- svDefaults = defaults
}

function KC_G.GetCounter() return counter end
function KC_G.GetDeathCounter() return deathCounter end
function KC_G.GetStreak() return streak end
function KC_G.GetDStreak() return deathStreak end
function KC_G.GetRankPoints() return rankPointsGained end
function KC_G.GetKBStreak() return kbStreak end
function KC_G.GetKillingBlows() return kbCounter end
function KC_G.GetAP() return rankPointsGained end
function KC_G.NewPlayerArray() return newPlayerArray() end

function KC_G.GetCurrentSession() return currentSession end

function KC_G.TestMode() return test_mode end

-- Reporting using /kc report
function KC_G.UpdateDisplayText()
    local KDratio = deathCounter > 0 and counter / deathCounter or counter
    if KC_Fn.CheckSetting("APBar") then
        APOnBar()
    else
        APOffBar()
    end
end

function APOnBar()
    local KDratio = deathCounter > 0 and counter / deathCounter or counter
    KillCounter_Kills:SetText(string.format(
                                  "K/D[%d/%d : %.1f] KB[%d] KBS[%d] Streak[%d] AP[%d]", -- To keep AP here AP(%d)
                                  counter, deathCounter,
                                  KC_Fn.round(KDratio, 2), kbCounter, kbStreak, streak, rankPointsGained)) -- rankPointsGained
    KillCounter_Kills.anchorX = .5
end

function APOffBar()
    local KDratio = deathCounter > 0 and counter / deathCounter or counter
    KillCounter_Kills:SetText(string.format(
                                  "K/D[%d/%d : %.1f] KB[%d] KBS[%d] Streak[%d]", -- To keep AP here AP(%d)
                                  counter, deathCounter,
                                  KC_Fn.round(KDratio, 2), kbCounter, kbStreak, streak)) -- rankPointsGained
    KillCounter_Kills.anchorPoint = .5
end

function KC_G.OnMoveStop()
    if KC_G.savedVars ~= nil then
        local arg1, arg2, arg3, arg4, xoff, yoff = KillCounter:GetAnchor()
        -- d(KillCounter:GetAnchor())
        KC_G.savedVars.offsetX = xoff
        KC_G.savedVars.offsetY = yoff
        KC_G.savedVars.anchorPoint = arg2
    end
end

function KC_G.UpdateKillStats(n, doKB)

    -- Retrieve the class/alliance info from available sources
    local function retrieveClassAlliance()
        local t = newPlayerArray()
        t[Name] = n
        t[Kills] = 1 -- one
        if reticle_data[n] ~= nil then
            t[Class] = reticle_data[n][Class]
            t[Alliance] = reticle_data[n][Alliance]
        elseif KC_G.savedVars.players[n] ~= nil then
            t[Class] = KC_G.savedVars.players[n][Class]
            t[Alliance] = KC_G.savedVars.players[n][Alliance]
        end
        return t
    end

    -- Update session information
    if KC_G.savedVars.players[n] == nil then
        KC_G.savedVars.players[n] = retrieveClassAlliance()
    else -- target has data already
        KC_G.savedVars.players[n][Kills] = KC_G.savedVars.players[n][Kills] + 1
    end -- end if

    -- If target not in the currentSession list
    if currentSession.players[n] == nil then
        currentSession.players[n] = retrieveClassAlliance() -- the copied/modified player array.
    else
        currentSession.players[n][Kills] = currentSession.players[n][Kills] + 1
    end

    -- ============================================================
    -- Update global counters
    KC_G.savedVars.totalKills = KC_G.savedVars.totalKills + 1
    counter = counter + 1
    streak = streak + 1
    KC_G.doDeathStreakEnd()

    local b = KC_G.doStreak(doKB)
    -- ============================================================
    -- Apply bandage to fix data gaps.

    if reticle_data[n] ~= nil and KC_G.savedVars.players[n] ~= nil then
        KC_G.savedVars.players[n][Level] = reticle_data[n][Level]
        KC_G.savedVars.players[n][vLevel] = reticle_data[n][vLevel]
        KC_G.savedVars.players[n][Class] = reticle_data[n][Class]
        KC_G.savedVars.players[n][Alliance] = reticle_data[n][Alliance]
    end

    -- play sound
    if not b and KC_Fn.CheckSetting("Sounds") then
        PlaySound(SOUNDS.LOCKPICKING_SUCCESS_CELEBRATION) -- maybe a kill
        PlaySound(SOUNDS.LOCKPICKING_UNLOCKED)
    end
    KC_G.UpdateSessionData()
end

-- Function handler registered to receive Killing Blow/Target released combat events. 
function KC_G.OnKillingBlow(eventCode, result, isError, abilityName,
                            abilityGraphic, abilityActionSlotType, sourceName,
                            sourceType, targetName, targetType, hitValue,
                            powerType, damageType, log)

    if KC_G.savedVars == nil or KC_G.savedVars.players == nil then return end

    local currPlayer = GetUnitName('player')
    local target = zo_strformat("<<1>>", targetName)
    local source = zo_strformat("<<1>>", sourceName)

    -- If the current player "killed" an "Other" player, or pets
    if (((sourceType == COMBAT_UNIT_TYPE_PLAYER and targetType == COMBAT_UNIT_TYPE_OTHER)  or 
        (sourceType == COMBAT_UNIT_TYPE_PLAYER_PET and targetType == COMBAT_UNIT_TYPE_OTHER)) 
            and (IsPlayerInAvAWorld() or IsActiveWorldBattleground())) then
        local s =
            "|C00CF34Killed " .. ZO_LinkHandler_CreatePlayerLink(target) .. "|r" -- the print string message -> s
        if abilityName ~= "" then -- If I got the killing blow
            local time = GetFrameTimeMilliseconds()
            s = s .. (" |C00CF34with a Killing Blow using ") .. abilityName ..
                    "|r"
            -- add spells to stats
            if KC_G.savedVars.kbSpells[abilityName] == nil then
                KC_G.savedVars.kbSpells[abilityName] = 1
            else
                KC_G.savedVars.kbSpells[abilityName] =
                    KC_G.savedVars.kbSpells[abilityName] + 1
            end

            if currentSession.kbSpells[abilityName] == nil then
                currentSession.kbSpells[abilityName] = 1
            else
                currentSession.kbSpells[abilityName] =
                    KC_G.savedVars.kbSpells[abilityName] + 1
            end

            if not justKilled[target] or (time - justKilled[target]) > 2000 then -- if not just killed or killed more that 1000 milliseconds ago
                -- inclement KB counters
                kbCounter = kbCounter + 1
                kbStreak = kbStreak + 1

                -- Adjust KB streak
                if currentSession.longestKBStreak < kbStreak then
                    currentSession.longestKBStreak = kbStreak
                    -- Moved this inside, Can't beat the overall record without beating the current streak.
                    if KC_G.savedVars.longestKBStreak < kbStreak then
                        KC_G.savedVars.longestKBStreak = kbStreak
                        s = s .. ". New Killing Blow Streak Record!"
                    end
                end

                KC_G.UpdateKillStats(target, true) -- update lists before doing the stuff below	 
                -- Always adding 1 to the KB stats
                KC_G.savedVars.players[target][KillingBlows] =
                    KC_G.savedVars.players[target][KillingBlows] + 1
                currentSession.players[target][KillingBlows] =
                    currentSession.players[target][KillingBlows] + 1
                justKilled[target] = time -- mark the kill as "reported"
            end

            if KC_Fn.CheckSetting("ChatKills") then
                d(s) -- immediately print KB message.
            end
        else -- What to do upon an enemy "release"
            if justKilled[target] then
                justKilled[target] = nil -- the target has released so clear him from the list.
            else
                KC_G.UpdateKillStats(target, false)
                if KC_Fn.CheckSetting("ChatKills") then
                    d(s) -- immediately print KB message.
                end
            end

            -- end
        end

    end
    KC_G.UpdateDisplayText()
end -- end KC_G.OnKill()

-- function KC_G.OnKillXP(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log,sourceUnitId, targetUnitId, abilityId)
--    if result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP then
--       df("Real time kill: %s -> %s, %s", tostring(sourceUnitId), tostring(targetUnitId), tostring(abilityName))
--    end
-- end

function KC_G.OnKilled(eventCode)
    if not (IsPlayerInAvAWorld() or IsActiveWorldBattleground()) then return end
    local killer, vlevel, level, pvplevel, isPlayer, par6bool, alliance, par8str =
        GetKillingAttackerInfo()
    if not isPlayer and KC_Fn.CheckSetting("ignoreNPCDeath") then return end

    assert(type(alliance) == "number")
    deathCounter = deathCounter + 1
    KC_G.savedVars.totalDeaths = KC_G.savedVars.totalDeaths + 1

    if streak > 0 then
        if KC_Fn.CheckSetting("ChatKStreak") then
            d(string.format(
                  "|C9C9C9CYour kill streak has ended! You had a streak of %d (%d KBStreak)|r",
                  streak, kbStreak))
        end
    else
        deathStreak = deathStreak + 1
        KC_G.doDeathStreak()
        SC_G.resetStreaks()
    end
    streak = 0
    kbStreak = 0
    SC_G.ResetCurrentObjectiveStreaks()
    -- d(GetKillingAttackerInfo())
    -- par7-combat unit type?COMBAT_UNIT_TYPE_PLAYER
    -- par7 is alliance
    -- par2 is v level it seems.?
    -- par5 seems to be seems to be whether or not they are a player

    -- d(GetKillingAttackerInfo()) 
    -- d(GetClassName(GENDER_MALE, par7int), GetClassName(GENDER_MALE, par2))
    -- d(GetAllianceName(par7int))
    killer = zo_strformat("<<1>>", killer)
    if isPlayer then
        local function PopulateNewPlayerArray()
            local a = newPlayerArray()
            a[Name] = killer
            a[KilledBy] = 1
            a[Alliance] = alliance
            a[Level] = level
            a[vLevel] = vlevel
            if reticle_data[killer] ~= nil then
                a[Class] = reticle_data[killer][Class]
                a[Alliance] = reticle_data[killer][Alliance]
            end
            return a
        end

        local savedPlayer = KC_G.savedVars.players[killer]
        if savedPlayer == nil then
            savedPlayer = PopulateNewPlayerArray()
            KC_G.savedVars.players[killer] = savedPlayer
        else
            savedPlayer[KilledBy] = savedPlayer[KilledBy] + 1
            savedPlayer[Alliance], savedPlayer[Level], savedPlayer[vLevel] =
                alliance, level, vlevel
            if reticle_data[killer] ~= nil then
                savedPlayer[Class] = reticle_data[killer][Class]
                savedPlayer[Alliance] = reticle_data[killer][Alliance]
            end
        end
        -- current session

        if currentSession.players[killer] == nil then
            currentSession.players[killer] = PopulateNewPlayerArray()
            if KC_G.savedVars.players[killer] ~= nil then
                currentSession.players[killer][Class] = savedPlayer[Class]
                currentSession.players[killer][Alliance] = savedPlayer[Alliance]
            end
        else
            local player = currentSession.players[killer]
            player[KilledBy] = player[KilledBy] + 1
            player[Alliance] = alliance
            player[Level] = level
            player[vLevel] = vlevel
            if reticle_data[killer] ~= nil then
                player[Class] = reticle_data[killer][Class]
                player[Alliance] = reticle_data[killer][Alliance]
            elseif savedPlayer ~= nil then
                player[Class] = savedPlayer[Class]
                player[Alliance] = savedPlayer[Alliance]
            end
        end
        KC_G.UpdateSessionData()
        if KC_Fn.CheckSetting("ChatDeaths") then
            d(string.format("|C870505You were killed by|r %s%s|r.",
                            KC_Fn.Alliance_Color(alliance),
                            ZO_LinkHandler_CreatePlayerLink(killer)))
        end
        KC_G.UpdateDisplayText()
    end
end

-- function KC_doStreak() 
function KC_G.doStreak(doKB)
    local ret = false
    if currentSession.longestStreak < streak then
        currentSession.longestStreak = streak
    end
    if streak_array[streak] ~= nil then
        if KC_Fn.CheckSetting("ChatKStreak") then
            d(string.format("|CFFA203%s (%d Kills).|r", streak_array[streak],
                            streak))
            -- s = s .. "|CFFA203" ..(streak_array[streak] .. " (" .. streak .. " Kills). ") .. "|r"
        end

        if streak < 17 and KC_Fn.CheckSetting("Sounds") then
            PlaySound(SOUNDS.EMPEROR_CORONATED_EBONHEART)
            PlaySound(SOUNDS.ELDER_SCROLL_CAPTURED_BY_EBONHEART)
            PlaySound(SOUNDS.SKILL_GAINED)
        elseif streak <= 50 and KC_Fn.CheckSetting("Sounds") then
            PlaySound(SOUNDS.LEVEL_UP)
            PlaySound(SOUNDS.LOCKPICKING_BREAK)
        end
        ret = true
    end
    if kb_streak_array[kbStreak] ~= nil and doKB then
        if KC_Fn.CheckSetting("ChatKStreak") then
            d(string.format("|C878787%s (%d KBs).|r", kb_streak_array[kbStreak],
                            kbStreak))
            -- s = s .. "|C878787".. (kb_streak_array[kbStreak] .. " (" .. kbStreak .. " KBs). ") .. "|r"
        end
    end

    if KC_G.savedVars.longestStreak == nil or streak >
        KC_G.savedVars.longestStreak then
        if KC_Fn.CheckSetting("ChatKStreak") then
            d("|C5DD61CNew Kill Streak Record! |r")
        end
        KC_G.savedVars.longestStreak = streak
    end
    return ret
end

-- function KC_doDeathStreak() 
function KC_G.doDeathStreak()

    if KC_G.savedVars.longestDeathStreak == nil or deathStreak >
        KC_G.savedVars.longestDeathStreak then
        if KC_Fn.CheckSetting("ChatDStreak") then
            d("|C9C9C9CNew Death Streak Record!|r")
        end
        KC_G.savedVars.longestDeathStreak = deathStreak
    end
    if deathStreak_array[deathStreak] ~= nil and
        KC_Fn.CheckSetting("ChatDStreak") then
        d(string.format("|C9C9C9C%s (%d Deaths)|r",
                        deathStreak_array[deathStreak], deathStreak))
        -- d("|C9C9C9C"..  deathStreak_array[deathStreak] .. " (" .. deathStreak .. " Deaths)" .. "|r")
    end

    if currentSession.longestDeathStreak < deathStreak then
        currentSession.longestDeathStreak = deathStreak
    end
end

do
    defaultSettings = {
        Sounds = true,
        ChatKills = true,
        ChatSeiges = true, -- flag capture 50%
        ChatCaptures = true, -- current objective flipped
        ChatDeaths = true,
        ChatKStreak = true,
        ChatDStreak = true,
        ChatCapStreak = true,
        ignoreNPCDeath = false,
        StatBar = true,
        APBar = true,
        QueueLabel = true,
        AutoQueueAccept = true,
        ImperialDistrictFlags = false
    }
    defaultSettings.__index = defaultSettings
    KC_G.classMap = {
        -- 1 Sorcerer
        -- 2 Dragonknight
        -- 3 Nightblade
        -- 4 Warden
        -- 5 Necromancer
        -- 6 Templar
        -- 7 Arcanist
        -- 8 Battlemage (future class)
        [""] = 0,
        [GetClassName(GENDER_FEMALE, 1)] = 1,
        [GetClassName(GENDER_FEMALE, 2)] = 2,
        [GetClassName(GENDER_FEMALE, 3)] = 3,
        [GetClassName(GENDER_FEMALE, 4)] = 4,
        [GetClassName(GENDER_FEMALE, 5)] = 5,
        [GetClassName(GENDER_FEMALE, 6)] = 6,
        [GetClassName(GENDER_FEMALE, 7)] = 7,
        [GetClassName(GENDER_FEMALE, 8)] = 8,
        [GetClassName(GENDER_MALE, 1)] = 1,
        [GetClassName(GENDER_MALE, 2)] = 2,
        [GetClassName(GENDER_MALE, 3)] = 3,
        [GetClassName(GENDER_MALE, 4)] = 4,
        [GetClassName(GENDER_MALE, 5)] = 5,
        [GetClassName(GENDER_MALE, 6)] = 6,
        [GetClassName(GENDER_MALE, 7)] = 7,
        [GetClassName(GENDER_MALE, 8)] = 8,
        [GetClassName(GENDER_NEUTER, 1)] = 1,
        [GetClassName(GENDER_NEUTER, 2)] = 2,
        [GetClassName(GENDER_NEUTER, 3)] = 3,
        [GetClassName(GENDER_NEUTER, 4)] = 4,
        [GetClassName(GENDER_NEUTER, 5)] = 5,
        [GetClassName(GENDER_NEUTER, 6)] = 6,
        [GetClassName(GENDER_NEUTER, 7)] = 7,
        [GetClassName(GENDER_NEUTER, 8)] = 8
    }
    local function NeedsVariableUpdate(t)
        return t.killedBy ~= nil and t.killed ~= nil
    end
    local function AllianceStringToNumber(a)
        if a == "Ebonheart Pact" then
            return ALLIANCE_EBONHEART_PACT
        elseif a == "Aldmeri Dominion" then
            return ALLIANCE_ALDMERI_DOMINION
        elseif a == "Daggerfall Covenant" then
            return ALLIANCE_DAGGERFALL_COVENANT
        end
        return 0
    end
    local function CombineKillTables(killed, killedBy)
        players = {}
        for k, v in pairs(killed) do
            if type(v[Alliance]) ~= "number" then
                v[Alliance] = AllianceStringToNumber(v[Alliance])
            end
            if not players[k] then
                local new = newPlayerArray()
                new[Kills] = v.Kills
                new[KillingBlows] = v.KillingBlows
                new[Revent_Kills] = v.Revent_Kills
                new[Avenge_Kills] = v.Avenge_Kills
                new[Name] = v.Name
                new[Alliance] = v.Alliance
                new[Class] = KC_G.classMap[v.Class]
                new[Level] = v.Level
                -- 7/10 fields 3 defaults
                players[k] = new
            end
        end
        for k, v in pairs(killedBy) do
            if type(v[Alliance]) ~= "number" then
                v[Alliance] = AllianceStringToNumber(v[Alliance])
            end
            local p = players[k]
            if p then -- if already in list, grab some 
                p[Level], p[vLevel], p[KilledBy], p[Alliance] = v.Level,
                                                                v.vLevel,
                                                                v.KilledBy,
                                                                v.Alliance
                p[Class] = KC_G.classMap[v.Class]
            else
                local new = newPlayerArray()
                new[Name] = v.Name
                new[Alliance] = v.Alliance
                new[Class] = KC_G.classMap[v.Class]
                new[Level] = v.Level
                new[vLevel] = v.vLevel
                new[KilledBy] = v.KilledBy
                players[k] = new
            end
        end
        return players
    end
    -- function KC_OnAddOnLoaded(eventCode, addOnName)
    function KC_G.OnAddOnLoaded(eventCode, addOnName)
        if (addOnName ~= KC_G.name) then return end
        -- Settings Panel Initializer 
        if addOnName == KC_G.name then KC_G.CreateConfigMenuX() end
        KC_G.savedVars = ZO_SavedVars:New("KillCounter_Data", version, nil,
                                          defaults, nil)
        if KC_G.savedVars.settings == nil then
            KC_G.savedVars.settings = {}
        end
        setmetatable(KC_G.savedVars.settings, defaultSettings)

        if NeedsVariableUpdate(KC_G.savedVars) then
            KC_G.savedVars.players = CombineKillTables(KC_G.savedVars.killed,
                                                       KC_G.savedVars.killedBy)
            KC_G.savedVars.killed = nil
            KC_G.savedVars.killedBy = nil
            KC_G.newClassData = {[0] = 0, 0, 0, 0, 0, 0, 0}
            for k, v in pairs(KC_G.savedVars.players) do
                assert(v[Class])
                KC_G.newClassData[v[Class]] =
                    KC_G.newClassData[v[Class]] + v[Kills]
            end
        end

        KillCounter:ClearAnchors()
        KillCounter:SetAnchor(KC_G.savedVars.anchorPoint, GuiRoot, nil,
                              KC_G.savedVars.offsetX, KC_G.savedVars.offsetY)

        KC_G.KCMenuSetup()

        -- Queue handling setup
        if KC_G.savedVars.settings.QueueLabel then
            KC_G.QueueControl(true)
        end
        if KC_G.savedVars.settings.AutoQueueAccept then
            KC_G.AutoQueueAccept(true)
        end
    end
end

-- function KC_initStreak()
function KC_G.initStreak()

    -- kill streaks
    streak_array[3] = "Three For One!"
    streak_array[5] = "Killing Spree!"
    streak_array[8] = "Dominating!"
    streak_array[12] = "Unstoppable!"
    streak_array[15] = "Massacre!"
    streak_array[18] = "Annihilation!"
    streak_array[21] = "Legendary!"
    streak_array[25] = "Genocide!"
    streak_array[28] = "Demonic!"
    streak_array[32] = "God Like!"
    streak_array[40] = "Praise Thee, Demi-God!"
    streak_array[50] = "Praise Thee, God of Pain!"
    streak_array[60] = "Praise Thee, God of Blood!"
    streak_array[75] = "Praise Thee, God of Destruction!"
    streak_array[100] = "Praise Thee, God of Chaos!"

    kb_streak_array[2] = "Hunter"
    kb_streak_array[3] = "Stalker"
    kb_streak_array[5] = "Killer"
    kb_streak_array[8] = "Slayer!"
    kb_streak_array[12] = "Hit Man!"
    kb_streak_array[15] = "Mass Murderer!"
    kb_streak_array[18] = "Executioner!"
    kb_streak_array[21] = "Assassin!"
    kb_streak_array[25] = "Blood Drinker!"
    kb_streak_array[28] = "Agent of Death!"
    kb_streak_array[32] = "Reaper!"
    kb_streak_array[40] = "Angel of Death!"
    kb_streak_array[50] = "God of Death!"
    kb_streak_array[75] = "Obviously Cheating! REPORTED!"

    deathStreak_array[2] = "Honorless Death!"
    deathStreak_array[3] = "Dry Spell!"
    deathStreak_array[4] = "Unfair Disadvantage!"
    deathStreak_array[5] = "Lover, Not a Fighter!"
    deathStreak_array[6] = "Forsaken!"
    deathStreak_array[7] = "500 ms Latency!"
    deathStreak_array[8] = "Plain Ole Baddie!"
    deathStreak_array[10] = "Have you considered reading a book instead?"
end

function KC_G.OnCharacterLoad(eventCode, initialLoad)
    if IsPlayerInAvAWorld() or IsActiveWorldBattleground() then
        KC_ON = false
        KC_G.show()
        if not KC_G.eventsRegistered then
            --[[ 
	    Most of these events are only useful in cyrodiil. I did
	    leave the OnKill function alive though because I find it
	    funny and satisfying to get kill counter updates when
       killing allies in trials
       -Cast, disabled this because duels inconsistency. -- May create a dueling addition
	 --]]
            KC_G.eventsRegistered = true
            EVENT_MANAGER:RegisterForEvent(KC_G.name,
                                           EVENT_RETICLE_TARGET_CHANGED,
                                           KC_G.TargetChanged)
            EVENT_MANAGER:RegisterForEvent(KC_G.name, EVENT_AVENGE_KILL,
                                           KC_G.AvengeKill)
            EVENT_MANAGER:RegisterForEvent(KC_G.name, EVENT_REVENGE_KILL,
                                           KC_G.RevengeKill)
            EVENT_MANAGER:RegisterForEvent(KC_G.name,
                                           EVENT_ALLIANCE_POINT_UPDATE,
                                           KC_G.Experience_Update)
            EVENT_MANAGER:RegisterForEvent(KC_G.name, EVENT_PLAYER_DEAD,
                                           KC_G.OnKilled)
            -- Used to determine actual keep captures rather than just flag status
            EVENT_MANAGER:RegisterForEvent(KC_G.name,
                                           EVENT_KEEP_ALLIANCE_OWNER_CHANGED,
                                           SC_G.KeepOwnerChanged)
            -- Flag flipping status
            EVENT_MANAGER:RegisterForEvent(KC_G.name,
                                           EVENT_OBJECTIVE_CONTROL_STATE,
                                           SC_G.ObjectiveControlState)
        end
    elseif KC_ON then
        KC_G.show()
    else
        KC_G.hide()
        if KC_G.eventsRegistered then
            KC_G.eventsRegistered = false
            EVENT_MANAGER:UnregisterForEvent(KC_G.name,
                                             EVENT_RETICLE_TARGET_CHANGED)
            EVENT_MANAGER:UnregisterForEvent(KC_G.name, EVENT_AVENGE_KILL)
            EVENT_MANAGER:UnregisterForEvent(KC_G.name, EVENT_REVENGE_KILL)
            EVENT_MANAGER:UnregisterForEvent(KC_G.name,
                                             EVENT_ALLIANCE_POINT_UPDATE)
            EVENT_MANAGER:UnregisterForEvent(KC_G.name, EVENT_PLAYER_DEAD)
            -- Used to determine actual keep captures rather than just flag status
            EVENT_MANAGER:UnregisterForEvent(KC_G.name,
                                             EVENT_KEEP_ALLIANCE_OWNER_CHANGED)
            -- Flag flipping status
            EVENT_MANAGER:UnregisterForEvent(KC_G.name,
                                             EVENT_OBJECTIVE_CONTROL_STATE)
        end
    end
    KC_G.UpdateDisplayText()
end
function KC_G.QueueExited(eventCode, campaignId, isGroup)
    KillCounter_QueueStatus:SetText("")
    KillCounter_QueueStatus:SetAlpha(0.0)
    KillCounter_QueueStatus:SetHidden(true)

    if KC_Fn.CheckSetting("APBar") then
        KillCounter:SetDimensions(410, 25)
    else
        KillCounter:SetDimensions(350, 25)
    end
end
function KC_G.QueueEntered(eventCode, campaignId, isGroup, position)
    KC_G.show(true)
    KillCounter_QueueStatus:SetText(string.format("Queue Status: %s (%d)",
                                                  GetCampaignName(campaignId),
                                                  position or
                                                      GetCampaignQueuePosition(
                                                          campaignId)))

end

function KC_G.QueuePositionChange(eventCode, campaignId, isGroup, position)
    KC_G.QueueEntered(eventCode, campaignId, isGroup, position)
end

function KC_G.QueueStateChange(eventCode, id, isGroup, state)
    -- local stateArray = {
    --    [CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING]     =    "CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING",	   
    --    [CAMPAIGN_QUEUE_REQUEST_STATE_FINISHED]       =    "CAMPAIGN_QUEUE_REQUEST_STATE_FINISHED",	   
    --    [CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_ACCEPT] =    "CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_ACCEPT",
    --    [CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_JOIN]   =    "CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_JOIN",
    --    [CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_LEAVE]  =    "CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_LEAVE", 
    --    [CAMPAIGN_QUEUE_REQUEST_STATE_WAITING]	 =    "CAMPAIGN_QUEUE_REQUEST_STATE_WAITING"       
    -- }
    -- d(stateArray[state])
    if state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then
        KillCounter_QueueStatus:SetText(string.format(
                                            "Queue Status: %s (Accept?)",
                                            GetCampaignName(campaignId)))
        ConfirmCampaignEntry(id, isGroup, true)
    elseif state == CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_ACCEPT then
        KillCounter_QueueStatus:SetText(string.format(
                                            "Queue Status: %s (Entering Cyrodiil...)",
                                            GetCampaignName(campaignId)))
        -- These two likely won't ever be triggered due to the auto accept
        -- elseif state == CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_LEAVE then
        --    KillCounter_QueueStatus:SetText(string.format("Queue Status: %s (Exiting Queue...)",GetCampaignName(campaignId)))
        -- elseif state == CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_JOIN then
        --    KillCounter_QueueStatus:SetText(string.format("Queue Status: %s (Joining Queue...)",GetCampaignName(campaignId)))
    end
end

function KC_G.QueueControl(activate)
    if activate then
        EVENT_MANAGER:RegisterForEvent(KC_G.name, EVENT_CAMPAIGN_QUEUE_JOINED,
                                       KC_G.QueueEntered)
        EVENT_MANAGER:RegisterForEvent(KC_G.name, EVENT_CAMPAIGN_QUEUE_LEFT,
                                       KC_G.QueueExited)
        EVENT_MANAGER:RegisterForEvent(KC_G.name,
                                       EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED,
                                       KC_G.QueuePositionChange)
    else
        EVENT_MANAGER:UnregisterForEvent(KC_G.name,
                                         EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(KC_G.name, EVENT_CAMPAIGN_QUEUE_LEFT)
        EVENT_MANAGER:UnregisterForEvent(KC_G.name, EVENT_CAMPAIGN_QUEUE_JOINED)
        KC_G.QueueExited()
    end
end
function KC_G.AutoQueueAccept(activate)
    if activate then
        EVENT_MANAGER:RegisterForEvent(KC_G.name,
                                       EVENT_CAMPAIGN_QUEUE_STATE_CHANGED,
                                       KC_G.QueueStateChange)
    else
        EVENT_MANAGER:UnregisterForEvent(KC_G.name,
                                         EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
    end

end
-- function KC_OnInitialized(self)
function KC_G.OnInitialized(self)
    -- panelData Settings->Addon
    -- if addOnName ~="KillCounter" then return end
    -- Register on the top level control...
    EVENT_MANAGER:RegisterForEvent(KC_G.name, EVENT_COMBAT_EVENT,
                                   KC_G.OnKillingBlow)
    -- Throttle the function Event triggers to only Killing blow events
    EVENT_MANAGER:AddFilterForEvent(KC_G.name, EVENT_COMBAT_EVENT,
                                    REGISTER_FILTER_COMBAT_RESULT,
                                    ACTION_RESULT_KILLING_BLOW)

    -- EVENT_MANAGER:RegisterForEvent(KC_G.name.."XP", EVENT_COMBAT_EVENT, KC_G.OnKillXP)
    -- Throttle the function Event triggers to only Killing blow events
    -- EVENT_MANAGER:AddFilterForEvent(KC_G.name.."XP", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED_XP)
    -- EVENT_MANAGER:RegisterForEvent(KC_G.name, EVENT_UNIT_DEATH_STATE_CHANGED, KC_G.DeathStateChanged)
    EVENT_MANAGER:RegisterForEvent(KC_G.name, EVENT_ADD_ON_LOADED,
                                   KC_G.OnAddOnLoaded)
    EVENT_MANAGER:RegisterForEvent(KC_G.name, EVENT_ACTION_LAYER_PUSHED,
                                   KC_G.onActionLayerPushed)
    EVENT_MANAGER:RegisterForEvent(KC_G.name, EVENT_ACTION_LAYER_POPPED,
                                   KC_G.onActionLayerPopped)
    EVENT_MANAGER:RegisterForEvent(KC_G.name, EVENT_PLAYER_COMBAT_STATE,
                                   KC_G.CombatState)

    -- Temporarily Disabled: Not currently needed
    --   EVENT_MANAGER:RegisterForEvent(KC_G.name, EVENT_EXPERIENCE_UPDATE, KC_G.Veteran_Update)
    EVENT_MANAGER:RegisterForEvent(KC_G.name, EVENT_PLAYER_ACTIVATED,
                                   KC_G.OnCharacterLoad)

    -- Temporarily Disabled: not needed
    -- EVENT_MANAGER:RegisterForEvent(KC_G.name, EVENT_CAPTURE_AREA_STATUS, SC_G.CaptureAreaStatus)

    -- Slash Commands --
    SLASH_COMMANDS["/kcreset"] = function(extra)
        -- reset counter
        counter = 0
        deathCounter = 0
        streak = 0
        kbStreak = 0
        deathStreak = 0
        rankPointsGained = 0
        SC_G.resetStreaks()

        if extra == "full" then
            KC_G.statsResetFull()
            d("Stats Fully Reset")
            SC_G.ResetSeigeStats()
        else
            d("Current Stats Reset")
        end

    end

    -- General purpose kc command
    SLASH_COMMANDS["/kc"] = function(extra)
        if string.lower(extra) == "help" then
            d("/kc on - turns on the kc stat bar")
            d("/kc off - turns off the kc stat bar")
            d("/kc settings - opens the settings menu")
            d("/kcreport - creates a report of current stats")
            d("/kcreset - reset current stats")
            d("/kc stats - shows stats menu")
            d("/kc ooc - toggles out of combat messages")
            d("/kc sounds - toggles sounds")
            -- depricated function call
        elseif string.lower(extra) == "toggle" then
            d("\"/kc toggle\" has been removed, please use \"/kc on/off\"")
            -- KC_G.toggle(overrideHideMain)
        elseif string.lower(extra) == "on" then
            KC_ON = true
            KC_G.show()
            --	 KC_OFF = false
        elseif string.lower(extra) == "off" then
            KC_ON = false
            KC_G.hide()
            --	 KC_OFF = true
        elseif string.lower(extra) == "stats" then
            -- if (KC_G.showingStats()) then KC_G.closeStats() 
            KC_G.showStats()
            showingStats = not showingStats
            -- SetMouseCursor(1)
        elseif string.lower(extra) == "settings" then
            -- if (KC_G.showingSettings()) then KC_G.closeSettings() 
            KC_G.showSettings()
            -- showingSettings = not showingSettings
        elseif string.lower(extra) == "ooc" then
            showOOC = not showOOC
            if showOOC then
                d("Now showing Out of Combat Messages")
            else
                d("Out of Combat messages Hidden")
            end
        elseif string.lower(extra) == "sounds" then
            doSounds = not doSounds
            if doSounds then
                d("Kill Counter sounds turned on.")
            else
                d("Kill Counter sounds turned off.")
            end
            -- else
            -- 	 local arguments = KC_Fn.string_split(extra)
            -- 	 for i=tonumber(arguments[1]),tonumber(arguments[2]) do
            -- 	    df("%d -> %s", i, GetKeepName(i))
            -- 	 end
        end
    end
    -- CHAT_CATEGORY_SAY = Yell
    -- CHAT_CATEGORY_YELL = whisper

    SLASH_COMMANDS["/kcreport"] = function(extra)
        local channel_array = {
            guild1 = CHAT_CHANNEL_GUILD_1,
            guild2 = CHAT_CHANNEL_GUILD_2,
            guild3 = CHAT_CHANNEL_GUILD_3,
            guild4 = CHAT_CHANNEL_GUILD_4,
            guild5 = CHAT_CHANNEL_GUILD_5,
            g1 = CHAT_CHANNEL_GUILD_1,
            g2 = CHAT_CHANNEL_GUILD_2,
            g3 = CHAT_CHANNEL_GUILD_3,
            g4 = CHAT_CHANNEL_GUILD_4,
            g5 = CHAT_CHANNEL_GUILD_5,
            officer1 = CHAT_CHANNEL_OFFICER_1,
            officer2 = CHAT_CHANNEL_OFFICER_2,
            officer3 = CHAT_CHANNEL_OFFICER_3,
            officer4 = CHAT_CHANNEL_OFFICER_4,
            officer5 = CHAT_CHANNEL_OFFICER_5,
            o1 = CHAT_CHANNEL_OFFICER_1,
            o2 = CHAT_CHANNEL_OFFICER_2,
            o3 = CHAT_CHANNEL_OFFICER_3,
            o4 = CHAT_CHANNEL_OFFICER_4,
            o5 = CHAT_CHANNEL_OFFICER_5,
            group = CHAT_CHANNEL_PARTY,
            say = CHAT_CHANNEL_SAY,
            yell = CHAT_CHANNEL_YELL,
            zone = CHAT_CHANNEL_ZONE,
            tell = CHAT_CHANNEL_WHISPER,
            g = CHAT_CHANNEL_PARTY,
            s = CHAT_CHANNEL_SAY,
            y = CHAT_CHANNEL_YELL,
            z = CHAT_CHANNEL_ZONE,
            w = CHAT_CHANNEL_WHISPER
        }
        local pieces = KC_Fn.string_split(extra)
        -- d(pieces, #pieces)
        local chan = channel_array.say
        local message = "message"
        local target = nil
        local error = false

        local c = string.lower(pieces[1])
        if (channel_array[c] ~= nil) then chan = channel_array[c] end

        -- if its the whisper channel use 2nd piece

        if chan == CHAT_CHANNEL_WHISPER or chan == CHAT_CHANNEL_WHISPER_SENT then
            if #pieces > 1 then
                -- combine the rest of the pieces
                local t = ""
                for i = 2, #pieces do
                    local space = " "
                    if i == 2 then space = "" end

                    t = t .. space .. pieces[i]
                end
                target = t
            else
                d(
                    "You must specify a player when trying to g the Kill Counter report.")
                error = true
            end
        end

        local ratio = counter
        if deathCounter > 1 then ratio = ratio / deathCounter end
        message = "***Kill Counter Report *** "
        message = message .. "Kills: " .. counter .. " | Deaths: " ..
                      deathCounter .. " | Streak: " .. streak .. " "
        message = message .. "| KDR: " .. KC_Fn.round(ratio, 2) ..
                      " | Ap Gained: " .. rankPointsGained .. " "
        message = message .. "| Killing Blows: " .. kbCounter

        -- check last part of pieces. if its full, do full report
        if string.lower(pieces[#pieces]) == "full" then
            local tdeaths = 0
            local tkills = 0
            local lstreak = 0
            local ap = 0
            local tratio = 0
            if KC_G.savedVars ~= nil then
                tdeaths = KC_G.savedVars.totalDeaths or 0
            end
            if KC_G.savedVars ~= nil then
                tkills = KC_G.savedVars.totalKills or 0
            end
            if KC_G.savedVars ~= nil then
                lstreak = KC_G.savedVars.longestStreak or 0
            end
            if KC_G.savedVars ~= nil then
                ap = KC_G.savedVars.rankPointsGained
            end
            tratio = tkills
            --creating killing blows for overall stats
            local kbs_kc = 0
            for n, guy in pairs(KC_G.savedVars.players) do
                kbs_kc = kbs_kc + guy[KillingBlows]
            end
            if tdeaths > 1 then tratio = tratio / tdeaths end
            message = message .. " ***Overall Stats *** "
            message = message .. "Total Kills: " .. tkills ..
                          " | Total Deaths: " .. tdeaths ..
                          " | Longest Streak: " .. lstreak .. " "
            message = message .. " | Killing Blows: " .. kbs_kc .." "
            message = message .. "| Overall KDR: " .. KC_Fn.round(tratio, 2) ..
                          " | All Ap Gained: " .. ap .. " "
            message = message .. "| Death Streak: " ..
                          KC_G.savedVars.longestDeathStreak
            
        end

        if not error then
            CHAT_SYSTEM:StartTextEntry(message, chan, target)
        end
    end
    SC_G.slashCommands()
    -- /kctest1337
    -- SLASH_COMMANDS["/kctest1337"] = function (extra)
    -- reset counter
    -- PlaySound(SOUNDS.LOCKPICKING_BREAK)
    -- PlaySound(SOUNDS.LEVEL_UP) high kill streaks
    -- PlaySound(SOUNDS.EMPEROR_CORONATED_EBONHEART) maybe killing spree
    -- PlaySound(SOUNDS.LOCKPICKING_SUCCESS_CELEBRATION) --maybe a kill
    -- PlaySound(SOUNDS.LOCKPICKING_UNLOCKED)
    -- PlaySound(SOUNDS.EMPEROR_CORONATED_EBONHEART)
    -- PlaySound(SOUNDS.SKILL_GAINED)
    -- d(SOUNDS)
    -- d(GetFrameTimeSeconds())	--d(tagged, taggedTime)
    -- d(GetUnitZone("Player"))
    -- d("|CffFF00dddd")
    -- d(KC_G.savedVars.players)a
    -- d(KC_G.savedVars.kbSpells)
    -- CHAT_SYSTEM:StartTextEntry("dd", CHAT_CATEGORY_SAY)
    -- test_mode = true
    -- d(KC_G.savedVars.kills['Landymac'].Seige_Kills)

    -- end
    SLASH_COMMANDS["/kc help"] = function(extra) end

    KC_G.initStreak()
    SC_G.initStreak()
end

--[[]]
function KC_G.Experience_Update(eventCode, alliancePoints, playSound, diff,
                                reason)

    if KC_G.savedVars == nil then return end
    -- ALLIANCE POINTS CALL
    if reason ~= CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL and reason ~=
        CURRENCY_CHANGE_REASON_VENDOR and reason ~= CURRENCY_CHANGE_REASON_BANK_DEPOSIT then
        rankPointsGained = rankPointsGained + diff
        KC_G.savedVars.rankPointsGained = KC_G.savedVars.rankPointsGained + diff
    end
    KC_G.UpdateDisplayText()
end

function KC_G.Veteran_Update(eventCode, currxp, maxxp, reason, s)
    --[[ local ExperienceReasons = {
      [PROGRESS_REASON_ACHIEVEMENT] = "PROGRESS_REASON_ACHIEVEMENT",
      [PROGRESS_REASON_ACTION] = "PROGRESS_REASON_ACTION",
      [PROGRESS_REASON_ALLIANCE_POINTS] = "PROGRESS_REASON_ALLIANCE_POINTS",
      [PROGRESS_REASON_AVA] = "PROGRESS_REASON_AVA",
      [PROGRESS_REASON_BATTLEGROUND] = "PROGRESS_REASON_BATTLEGROUND",
      [PROGRESS_REASON_BOOK_COLLECTION_COMPLETE] = "PROGRESS_REASON_BOOK_COLLECTION_COMPLETE",
      [PROGRESS_REASON_BOSS_KILL] = "PROGRESS_REASON_BOSS_KILL",
      [PROGRESS_REASON_COLLECT_BOOK] = "PROGRESS_REASON_COLLECT_BOOK",
      [PROGRESS_REASON_COMMAND] = "PROGRESS_REASON_COMMAND",
      [PROGRESS_REASON_COMPLETE_POI] = "PROGRESS_REASON_COMPLETE_POI",
      [PROGRESS_REASON_DARK_ANCHOR_CLOSED] = "PROGRESS_REASON_DARK_ANCHOR_CLOSED",
      [PROGRESS_REASON_DARK_FISSURE_CLOSED] = "PROGRESS_REASON_DARK_FISSURE_CLOSED",
      [PROGRESS_REASON_DISCOVER_POI] = "PROGRESS_REASON_DISCOVER_POI",
      [PROGRESS_REASON_DUNGEON_CHALLENGE] = "PROGRESS_REASON_DUNGEON_CHALLENGE",
      [PROGRESS_REASON_EVENT] = "PROGRESS_REASON_EVENT",
      [PROGRESS_REASON_FINESSE] = "PROGRESS_REASON_FINESSE",
      [PROGRESS_REASON_GRANT_REPUTATION] = "PROGRESS_REASON_GRANT_REPUTATION",
      [PROGRESS_REASON_GUILD_REP] = "PROGRESS_REASON_GUILD_REP",
      [PROGRESS_REASON_JUSTICE_SKILL_EVENT] = "PROGRESS_REASON_JUSTICE_SKILL_EVENT",
      [PROGRESS_REASON_KEEP_REWARD] = "PROGRESS_REASON_KEEP_REWARD", -- offensive and defensive tick event
      [PROGRESS_REASON_KILL] = "PROGRESS_REASON_KILL",
      [PROGRESS_REASON_LFG_REWARD] = "PROGRESS_REASON_LFG_REWARD",
      [PROGRESS_REASON_LOCK_PICK] = "PROGRESS_REASON_LOCK_PICK",
      [PROGRESS_REASON_MEDAL] = "PROGRESS_REASON_MEDAL",
      [PROGRESS_REASON_NONE] = "PROGRESS_REASON_NONE",
      [PROGRESS_REASON_OTHER] = "PROGRESS_REASON_OTHER",
      [PROGRESS_REASON_OVERLAND_BOSS_KILL] = "PROGRESS_REASON_OVERLAND_BOSS_KILL",
      [PROGRESS_REASON_PVP_EMPEROR] = "PROGRESS_REASON_PVP_EMPEROR",
      [PROGRESS_REASON_QUEST] = "PROGRESS_REASON_QUEST",
      [PROGRESS_REASON_REWARD] = "PROGRESS_REASON_REWARD",
      [PROGRESS_REASON_SCRIPTED_EVENT] = "PROGRESS_REASON_SCRIPTED_EVENT",
      [PROGRESS_REASON_SKILL_BOOK] = "PROGRESS_REASON_SKILL_BOOK",
      [PROGRESS_REASON_TRADESKILL] = "PROGRESS_REASON_TRADESKILL",
      [PROGRESS_REASON_TRADESKILL_ACHIEVEMENT] = "PROGRESS_REASON_TRADESKILL_ACHIEVEMENT",
      [PROGRESS_REASON_TRADESKILL_CONSUME] = "PROGRESS_REASON_TRADESKILL_CONSUME",
      [PROGRESS_REASON_TRADESKILL_HARVEST] = "PROGRESS_REASON_TRADESKILL_HARVEST",
      [PROGRESS_REASON_TRADESKILL_QUEST] = "PROGRESS_REASON_TRADESKILL_QUEST",
      [PROGRESS_REASON_TRADESKILL_RECIPE] = "PROGRESS_REASON_TRADESKILL_RECIPE",
      [PROGRESS_REASON_TRADESKILL_TRAIT] = "PROGRESS_REASON_TRADESKILL_TRAIT"
   }
   --]]
    -- df("Experience reason: %s - %s", ExperienceReasons[reason], ExperienceReasons[s])
    -- d("Veteran", reason, s, "------VP------")
end
-- ]]

function KC_G.TargetChanged(eventCode, unitTag)
    if not DoesUnitExist('reticleover') then return end

    if IsUnitPlayer('reticleover') and GetUnitAlliance('reticleover') ~=
        GetUnitAlliance('player') then
        local n = GetUnitName('reticleover')

        local c = GetUnitClassId('reticleover')
        local a = GetUnitAlliance('reticleover')
        -- local l = GetUnitLevel('reticleover')
        -- local vl = GetUnitVeteranRank('reticleover')

        -- check if they are in the players table
        if KC_G.savedVars.players[n] ~= nil then
            KC_G.savedVars.players[n][Class] = c
            KC_G.savedVars.players[n][Alliance] = a
        elseif reticle_data[n] == nil then
            local t = newPlayerArray()
            t[Name] = n
            t[Class] = c or 0
            t[Alliance] = a or 0
            reticle_data[n] = t
        end
    end
    -- d(n,c,a)
end

-- function KC_onActionLayerPushed(self, arg1, arg2)
function KC_G.onActionLayerPushed(self, arg1, arg2)
    if pushed < 1 then
        pushed = pushed + 1
        return
    end
    -- d("things")
    if arg2 == 2 then return end
    KillCounter:SetHidden(true)
    if showingStats and stats_window ~= nil then stats_window:SetHidden(true) end
    pushed = pushed + 1
end

-- function KC_onActionLayerPopped(self, arg1, arg2)
function KC_G.onActionLayerPopped(self, arg1, arg2)
    KillCounter:SetHidden(false)

    if showingStats and stats_window ~= nil then
        stats_window:SetHidden(false)
    end
end

-- function KC_doDeathStreakEnd()
function KC_G.doDeathStreakEnd()
    if deathStreak > 0 and KC_Fn.CheckSetting("ChatDStreak") then
        d("Your death streak of " .. deathStreak .. " has ended!")
    end
    deathStreak = 0
end

-- function KC_statsResetFull()
function KC_G.statsResetFull()
    KC_G.savedVars.players = {}
    KC_G.savedVars.totalKills = 0
    KC_G.savedVars.totalDeaths = 0
    KC_G.savedVars.longestStreak = 0
    KC_G.savedVars.longestDeathStreak = 0
    -- KC_G.loadKilled()
    -- d("saved vars: " .. #KC_G.savedVars.Killed)
    KC_G.updateStats(true)
end

-- function KC_toggle()
function KC_G.toggle(display_bool)
    KillCounter:SetHidden(not display_bool)
    KillCounter:SetAlpha(display_bool and 1.0 or 0.0)
    -- if display_bool then
    --    KC_G.show()
    -- else
    --    KC_G.hide()
    -- end
end

-- SHOW FUNCTION - Dynamically programmed to change size if they turn AP off
function KC_G.show(showQueue)
    if KC_Fn.CheckSetting("APBar") then
        APBarStatBarTrue()
        APBarTStatBarF()
    else
        APBarFStatBarT()
        APBarFStatBarF()
    end
    if showQueue then
        KillCounter:SetDimensions(410, 50)
        KillCounter_QueueStatus:SetAlpha(1.0)
        KillCounter_QueueStatus:SetHidden(false)
    end
end
-- Below are functions that were requested, 
-- the ability to turn kill counter stat bar off while in pvp
function APBarStatBarTrue()
    if KC_Fn.CheckSetting("APBar") and KC_Fn.CheckSetting("StatBar") then
        KillCounter:SetHidden(false)
        KillCounter:SetAlpha(1.0)
        KillCounter:SetDimensions(410, 25)
    end
end

function APBarFStatBarT()
    if not KC_Fn.CheckSetting("APBar") and KC_Fn.CheckSetting("StatBar") then
        KillCounter:SetHidden(false)
        KillCounter:SetAlpha(1.0)
        KillCounter:SetDimensions(335, 25)
    end
end

function APBarTStatBarF()
    if KC_Fn.CheckSetting("APBar") and not KC_Fn.CheckSetting("StatBar") then
        KC_G.hide()
    end
end

function APBarFStatBarF()
    if not KC_Fn.CheckSetting("APBar") and not KC_Fn.CheckSetting("StatBar") then
        KillCounter:SetDimensions(335, 25)
        KC_G.hide()
    end
end

-- function KC_hide()
function KC_G.hide()
    KillCounter:SetAlpha(0.0)
    KillCounter:SetHidden(true)
end

function KC_G.CombatState(self, inCombat)
    if not inCombat then if showOOC then d("out of combat") end end
end

function KC_G.DeathStateChanged(self, unitTag, isDead)
    if (isDead) and IsUnitPlayer(unitTag) then
        if GetUnitAlliance(unitTag) ~= GetUnitAlliance('player') and
            GetUnitName('player') ~= GetUnitName(unitTag) then
            local n = GetUnitName(unitTag)

        end
    end

    if not isDead and unitTag == 'player' then reticle_data = {} end

end

function KC_G.AvengeKill(eventCode, avengedPlayer, killedPlayer)
    local n = zo_strformat("<<1>>", killedPlayer)
    if KC_G.savedVars.players[n] == nil then
        local t = newPlayerArray()
        t[Name] = n
        t[Avenge_Kills] = 1
        if reticle_data[n] ~= nil then
            t[Class] = reticle_data[n][Class]
            t[Alliance] = reticle_data[n][Alliance]
        end

        KC_G.savedVars.players[n] = t
    else
        KC_G.savedVars.players[n][Avenge_Kills] =
            KC_G.savedVars.players[n][Avenge_Kills] + 1
    end
    KC_G.UpdateDisplayText()
end

function KC_G.RevengeKill(eventCode, killedPlayer)
    local n = zo_strformat("<<1>>", killedPlayer)
    if KC_G.savedVars.players[n] == nil then
        local t = newPlayerArray()
        t[Name] = n
        t[Revent_Kills] = 1
        if reticle_data[n] ~= nil then
            t[Class] = reticle_data[n][Class]
            t[Alliance] = reticle_data[n][Alliance]
        end
        KC_G.savedVars.players[n] = t
    else
        KC_G.savedVars.players[n][Revent_Kills] =
            KC_G.savedVars.players[n][Revent_Kills] + 1
    end
    KC_G.UpdateDisplayText()
end

--[[
   /esoui/art/campaign/leaderboard_top20banner.dds

   /iv 
   lol 3 way

   /esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds
   /esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds
   /esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds

   /esoui/art/campaign/campaign_tabicon_browser_up.dds

   /esoui/art/progression/progression_crafting_delevel_up.dds
   /esoui/art/progression/progression_crafting_unlocked_down.dds
   /esoui/art/mainmenu/menubar_ava_up.dds
   /esoui/art/actionbar/quickslotbg.dds
   bgs
   /esoui/art/itemtooltip/simpleprogbarbg_center.dds
   /esoui/art/lorelibrary/lorelibrary_stonetablet.dds

   /esoui/art/screens/loadscreen_topmunge_tile.dds
   /esoui/art/tooltips/munge_overlay.dds
   /esoui/art/unitattributevisualizer/attributebar_dynamic_invulnerable_munge.dds

--]]
