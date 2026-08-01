-- Leaderboard2Chat - Convert leaderboard notifications to chat messages
-- Features:
--   - Trial and arena score notifications in chat
--   - Infinite Archive score tracking
--   - Guild member filtering
--   - Customizable message colors
--   - Performance rating system

Leaderboard2Chat = Leaderboard2Chat or {}
local LAM2 = LibAddonMenu2

-- Configuration
local CONFIG = {
    NAME = "Leaderboard2Chat",
    LONG_NAME = "Leaderboard 2 Chat",
    AUTHOR = "|c00c1ffZai|r|cffffffZah|r",
    VERSION = "20.08.2025",
    SVAR_VERSION = 1,
    GUILD_CACHE_THROTTLE_MS = 5000,
}

-- Default settings
local DEFAULT_SETTINGS = {
    PrintToChat = true,
    ShowIAScores = true,
    ShowOwnScores = true,
    ShowScores = true,
    GuildFilter = {
        [1] = true, [2] = true, [3] = true, [4] = true, [5] = true,
    },
    MessageColors = {
        ScoreColor = "E5C100",
        ContentColor = "FFFFFF",
        GeneralColor = "FFFF00",
        PlayersColor = "FFFFFF"
    },
    ScoreRatings = {
        TRIAL = {
            -- Generic trial ratings with icons
            {threshold = 200000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
            {threshold = 165000, name = "|c00FF00Outstanding|r", icon = "High"},
            {threshold = 140000, name = "|cAAFF00Excellent|r", icon = "Normal"},
            {threshold = 120000, name = "|cFFFF00Very Good|r", icon = "Normal"},
            {threshold = 100000, name = "|cFFAA00Good|r", icon = "Low"},
            {threshold = 80000, name = "|cFF7700Average|r", icon = "Low"},
            {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
        },
        ARCHIVE = {
            {threshold = 720000, name = "|c00FFFFInfinite Archivist|r", icon = "VeryHigh"},
            {threshold = 180000, name = "|c00FFFFMaster Archivist|r", icon = "VeryHigh"},
            {threshold = 120000, name = "|c00FF00Expert Explorer|r", icon = "High"},
            {threshold = 72000, name = "|cAAFF00Skilled Delver|r", icon = "Normal"},
            {threshold = 36000, name = "|cFFFF00Archive Adept|r", icon = "Normal"},
            {threshold = 18000, name = "|cFFAA00Archive Novice|r", icon = "Low"},
            {threshold = 6000, name = "|cFF8000Archive Initiate|r", icon = "Low"},
            {threshold = 0, name = "|cFF5500Beginner|r", icon = "VeryLow"}
        },
        -- Trial-specific rating thresholds based on current in-game leaderboard high scores
        TRIAL_SPECIFIC = {
            -- Craglorn Trials
            ["Aetherian Archive"] = {
                {threshold = 135000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 115000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 100000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 85000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 70000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 60000, name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            ["Hel Ra Citadel"] = {
                {threshold = 140000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 120000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 100000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 85000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 70000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 60000, name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            ["Sanctum Ophidia"] = {
                {threshold = 160000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 130000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 105000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 90000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 75000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 60000, name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            -- DLC Trials
            ["Maw of Lorkhaj"] = {
                {threshold = 150000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 140000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 130000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 120000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 110000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 95000, name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            ["Halls of Fabrication"] = {
                {threshold = 190000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 170000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 150000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 130000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 110000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 95000, name = "|cFF7700Average|r", icon = "Low"}, 
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            ["Asylum Sanctorium"] = {
                {threshold = 105000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 95000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 85000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 75000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 65000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 55000, name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            ["Cloudrest"] = {
                {threshold = 120000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 110000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 100000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 90000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 80000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 70000, name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            ["Sunspire"] = {
                {threshold = 220000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 190000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 160000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 130000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 110000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 90000, name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            ["Kyne's Aegis"] = {
                {threshold = 220000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 190000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 160000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 130000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 110000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 90000, name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            ["Rockgrove"] = {
                {threshold = 270000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 225000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 180000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 150000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 125000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 100000, name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            ["Dreadsail Reef"] = {
                {threshold = 300000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 250000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 200000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 150000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 125000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 100000, name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            ["Sanity's Edge"] = {
                {threshold = 240000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 200000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 170000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 140000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 120000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 100000, name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            ["Lucent Citadel"] = {
                {threshold = 230000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 200000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 170000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 145000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 125000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 105000, name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            ["Ossein Cage"] = {
                {threshold = 265000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 245000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 205000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 170000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 135000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 85000,  name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0,      name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            -- 4-Player Arenas
            ["Dragonstar Arena"] = {
                {threshold = 40000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 35000, name = "|c00FF00Outstanding|r", icon = "High"}, 
                {threshold = 30000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 25000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 20000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 15000, name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            ["Black Rose Prison"] = {
                {threshold = 95000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 85000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 75000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 65000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 55000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 45000, name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            -- Solo Arenas
            ["Maelstrom Arena"] = {
                {threshold = 550000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 500000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 450000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 400000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 350000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 300000, name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            },
            ["Vateshran Hollows"] = {
                {threshold = 280000, name = "|c00FFFFGodlike|r", icon = "VeryHigh"},
                {threshold = 250000, name = "|c00FF00Outstanding|r", icon = "High"},
                {threshold = 220000, name = "|cAAFF00Excellent|r", icon = "Normal"},
                {threshold = 190000, name = "|cFFFF00Very Good|r", icon = "Normal"},
                {threshold = 160000, name = "|cFFAA00Good|r", icon = "Low"},
                {threshold = 130000, name = "|cFF7700Average|r", icon = "Low"},
                {threshold = 0, name = "|cFF5500Struggling|r", icon = "VeryLow"}
            }
        }    
    }
}

-- State management
local State = {
    SVAR = {},
    isInitialized = false,
    Data = {
        isDisabled = false,
        RNToChat = true,
        RNEndless = true,
        ShowScore = true,
        ShowOwnScores = true,
        GuildFilter = {},
        MessageColors = {},
        ARC_COLOR = "|c5ECED4",
        CYCLE_COLOR = "|cFFB3C7",
        STAGE_COLOR = "|c6ABEFF",
    }
}

-- Icons and content mapping
local ICONS = {
    trialIcon = "/esoui/art/treeicons/gamepad/gp_reconstruction_tabicon_trialgroup.dds",
    arenaIcon = "/esoui/art/treeicons/gamepad/gp_reconstruction_tabicon_arenagroup.dds",
    soloIcon = "/esoui/art/treeicons/gamepad/gp_reconstruction_tabicon_arenasolo.dds",
    endlessIcon = "/esoui/art/icons/mapkey/mapkey_endlessdungeon.dds",
    VeryLow = "EsoUI/Art/Trials/trialpoints_verylow.dds",
    Low = "EsoUI/Art/Trials/trialpoints_low.dds",
    Normal = "EsoUI/Art/Trials/trialpoints_normal.dds",
    High = "EsoUI/Art/Trials/trialpoints_high.dds",
    VeryHigh = "EsoUI/Art/Trials/trialpoints_veryhigh.dds",
    Arc = "EsoUI/Art/EndlessDungeon/icon_progression_arc.dds",
    Cycle = "EsoUI/Art/EndlessDungeon/icon_progression_cycle.dds",
    Stage = "EsoUI/Art/EndlessDungeon/icon_progression_stage.dds",
}

local CONTENT_ICONS = {
    [1] = ICONS.trialIcon,   [2] = ICONS.trialIcon,   [3] = ICONS.trialIcon,
    [4] = ICONS.arenaIcon,   [5] = ICONS.trialIcon,   [6] = ICONS.soloIcon,
    [7] = ICONS.trialIcon,   [8] = ICONS.trialIcon,   [9] = ICONS.trialIcon,
    [11] = ICONS.arenaIcon,  [12] = ICONS.trialIcon,  [13] = ICONS.trialIcon,
    [14] = ICONS.soloIcon,   [15] = ICONS.trialIcon,  [16] = ICONS.trialIcon,
    [17] = ICONS.trialIcon,  [18] = ICONS.trialIcon,  [19] = ICONS.trialIcon,
    ["DEFAULT"] = ICONS.trialIcon,
    ["Infinite Archive"] = ICONS.endlessIcon
}

-- Cache variables
local Cache = {
    arcParts = {},
    contacts = {},
    guildMembers = {},
    guildCacheUpdateScheduled = false,
    guildCacheLastUpdateTime = 0,
}

-- Localized API functions for performance
local ZO_ClearNumericallyIndexedTable = ZO_ClearNumericallyIndexedTable
local GetSetting_Bool = GetSetting_Bool
local zo_strformat = zo_strformat
local string_gsub = string.gsub
local RemoveLeaderboardScoreNotification = RemoveLeaderboardScoreNotification
local GetNextLeaderboardScoreNotificationId = GetNextLeaderboardScoreNotificationId
local GetLeaderboardScoreNotificationInfo = GetLeaderboardScoreNotificationInfo
local GetLeaderboardScoreNotificationMemberInfo = GetLeaderboardScoreNotificationMemberInfo
local GetRaidName = GetRaidName
local GetString = GetString
local SI_ENDLESS_DUNGEON_LEADERBOARDS_CATEGORIES_HEADER = SI_ENDLESS_DUNGEON_LEADERBOARDS_CATEGORIES_HEADER
local ZO_CommaDelimitNumber = ZO_CommaDelimitNumber


-- Module: Utility System
local UtilitySystem = {}

function UtilitySystem.HexToRGBA(hex)
    if not hex or hex == "" then
        return 1, 1, 1, 1  -- Default to white if invalid hex
    end
    
    -- Ensure hex is exactly 6 characters
    if string.len(hex) ~= 6 then
        return 1, 1, 1, 1  -- Default to white if invalid length
    end
    
    local r = tonumber(string.sub(hex, 1, 2), 16) / 255
    local g = tonumber(string.sub(hex, 3, 4), 16) / 255
    local b = tonumber(string.sub(hex, 5, 6), 16) / 255
    return r, g, b, 1  -- Always return alpha = 1
end

function UtilitySystem.RGBToHex(r, g, b)
    -- Handle nil values and clamp to valid range
    r = math.max(0, math.min(1, r or 0))
    g = math.max(0, math.min(1, g or 0))
    b = math.max(0, math.min(1, b or 0))
    return string.format("%02X%02X%02X", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
end

-- Module: Guild System
local GuildSystem = {}

function GuildSystem.IsPlayerInEnabledGuild(displayName)
    local anyGuildEnabled = false
    for i = 1, 5 do
        if State.Data.GuildFilter[i] then
            anyGuildEnabled = true
            break
        end
    end
    
    if not anyGuildEnabled then return false end
    
    for guildId = 1, GetNumGuilds() do
        local guildIndex = GetGuildId(guildId)
        
        if State.Data.GuildFilter[guildId] and 
           Cache.guildMembers[guildIndex] and 
           Cache.guildMembers[guildIndex][displayName] then
            return true
        end
    end
    
    return false
end

function GuildSystem.RebuildMemberCache()
    if Cache.guildCacheUpdateScheduled then
        return
    end
    
    Cache.guildCacheUpdateScheduled = true
    
    zo_callLater(function()
        ZO_ClearTable(Cache.guildMembers)
        
        for guildId = 1, GetNumGuilds() do
            local guildIndex = GetGuildId(guildId)
            local numGuildMembers = GetNumGuildMembers(guildIndex)
            
            Cache.guildMembers[guildIndex] = {}
            
            for memberIndex = 1, numGuildMembers do
                local memberDisplayName, _, _, _, memberCharacterName = GetGuildMemberInfo(guildIndex, memberIndex)
                local _, charName, _, classType = GetGuildMemberCharacterInfo(guildIndex, memberIndex)
                
                Cache.guildMembers[guildIndex][memberDisplayName] = {
                    characterName = charName,
                    class = classType,
                    guildName = GetGuildName(guildIndex),
                    guildId = guildId
                }
            end
        end
        
        Cache.guildCacheLastUpdateTime = GetGameTimeMilliseconds()
        Cache.guildCacheUpdateScheduled = false
    end, CONFIG.GUILD_CACHE_THROTTLE_MS)
end

-- Module: Rating System
local RatingSystem = {}

function RatingSystem.GetScoreRating(contentType, score, contentName)
    local ratingTable
    
    if contentType == LEADERBOARD_SCORE_NOTIFICATION_TYPE_ENDLESS_DUNGEON then
        ratingTable = State.SVAR.ScoreRatings.ARCHIVE
    else
        ratingTable = State.SVAR.ScoreRatings.TRIAL_SPECIFIC[contentName] or State.SVAR.ScoreRatings.TRIAL
    end
    
    for _, rating in ipairs(ratingTable) do
        if score >= rating.threshold then
            return rating.name, ICONS[rating.icon]
        end
    end
    
    return "|cFF0000Unrated|r", ICONS.VeryLow
end

function RatingSystem.CalculateArchiveProgression(score)
    ZO_ClearTable(Cache.arcParts)
    
    local pointsPerStage = 1000
    local pointsPerCycle = 6000
    local pointsPerArc = 36000
    local stagesPerCycle = 3
    local cyclesPerArc = 5
    
    local remainingPoints = score
    local arc = 1
    
    while remainingPoints >= pointsPerArc do
        remainingPoints = remainingPoints - pointsPerArc
        arc = arc + 1
    end
    
    local cycle = 1
    while remainingPoints >= pointsPerCycle do
        remainingPoints = remainingPoints - pointsPerCycle
        cycle = cycle + 1
        if cycle > cyclesPerArc then
            cycle = cyclesPerArc
            break
        end
    end
    
    local stage = math.min(math.floor(remainingPoints / pointsPerStage) + 1, stagesPerCycle)
    
    table.insert(Cache.arcParts, State.Data.ARC_COLOR .. zo_iconTextFormat(ICONS.Arc, 20, 20, "Arc: "..arc, true) .. "|r")
    table.insert(Cache.arcParts, State.Data.CYCLE_COLOR .. zo_iconTextFormat(ICONS.Cycle, 20, 20, "Cycle: "..cycle, true) .. "|r")
    table.insert(Cache.arcParts, State.Data.STAGE_COLOR .. zo_iconTextFormat(ICONS.Stage, 20, 20, "Stage: "..stage, true) .. "|r")
    
    return #Cache.arcParts > 0 and " (" .. table.concat(Cache.arcParts, " - ") .. ")" or ""
end

-- Module: Message System
local MessageSystem = {}

function MessageSystem.FormatMembersList(contacts)
    local nbContacts = #contacts
    
    if nbContacts == 0 then
        return "|cFFAAAA[unknown]|r"
    elseif nbContacts > 4 then
        return zo_strformat("<<1>>, <<2>> and <<3>> others", 
            "|c" .. State.Data.MessageColors.PlayersColor .. (contacts[1] or "[Unknown]") .. "|r", 
            "|c" .. State.Data.MessageColors.PlayersColor .. (contacts[2] or "[Unknown]") .. "|r", 
            "|c" .. State.Data.MessageColors.PlayersColor .. (nbContacts - 2) .. "|r")
    else
        -- Join all names with commas first, then wrap the entire string in color
        local namesList = table.concat(contacts, ", ")
        return "|c" .. State.Data.MessageColors.PlayersColor .. namesList .. "|r"
    end
end

function MessageSystem.GetRelationshipText(hasFriend, hasGuildMember, hasPlayer, numMembers)
    if hasPlayer then
        return "You"
    elseif hasFriend and hasGuildMember and numMembers > 1 then
        return "Your friends & guild mates"
    elseif hasFriend then
        return "Your " .. (numMembers > 1 and "friends" or "friend")
    else
        return "Your " .. (numMembers > 1 and "guild mates" or "guild mate")
    end
end

function MessageSystem.CreateNotificationMessage(contentType, contentName, score, numMembers, hasFriend, hasGuildMember, contacts, notificationId, contextInfo, contentId, hasPlayer)
    local cleanContentName = string_gsub(contentName, " %(Veteran%)", "")
    
    local contentIcon = CONTENT_ICONS["DEFAULT"]
    if contentType == LEADERBOARD_SCORE_NOTIFICATION_TYPE_RAID then
        contentIcon = CONTENT_ICONS[contentId] or contentIcon
    else
        contentIcon = CONTENT_ICONS[cleanContentName] or contentIcon
    end
    
    local formattedScore = "|c" .. State.Data.MessageColors.ScoreColor .. ZO_CommaDelimitNumber(score) .. "|r"
    
    local scoreRating = ""
    if State.Data.ShowScore then
        local ratingText, ratingIcon = RatingSystem.GetScoreRating(contentType, score, cleanContentName)
        scoreRating = " -" .. zo_iconFormat(ratingIcon, 28, 28) .. ratingText
    end
        
    local archiveInfo = ""
    if contentType == LEADERBOARD_SCORE_NOTIFICATION_TYPE_ENDLESS_DUNGEON then
        archiveInfo = RatingSystem.CalculateArchiveProgression(score)
    end
    
    local membersListShorten = MessageSystem.FormatMembersList(contacts)
    local relationship = MessageSystem.GetRelationshipText(hasFriend, hasGuildMember, hasPlayer, numMembers)
    
    local message = string.format("|c%s%s (|r%s|c%s) completed|r%s|c%s%s|r |c%swith a score of|r %s%s%s", 
               State.Data.MessageColors.GeneralColor,
               relationship,
               membersListShorten, 
               State.Data.MessageColors.GeneralColor,
               zo_iconFormat(contentIcon, 28, 28),
               State.Data.MessageColors.ContentColor,
               cleanContentName,
               State.Data.MessageColors.GeneralColor,
               formattedScore,
               archiveInfo,
               scoreRating)
        
    CHAT_ROUTER:AddSystemMessage(message)
    if notificationId then
        RemoveLeaderboardScoreNotification(notificationId)
    end
end

-- Module: Notification System
local NotificationSystem = {}

function NotificationSystem.ProcessNotification(self, notificationId)
    local contentType, contentId, contentContextualInfo, score, millisecondsSinceRequest, numMembers = GetLeaderboardScoreNotificationInfo(notificationId)

    if not State.Data.RNToChat or (contentType == LEADERBOARD_SCORE_NOTIFICATION_TYPE_ENDLESS_DUNGEON and not State.Data.RNEndless) then
        RemoveLeaderboardScoreNotification(notificationId)
        return
    end
    
    local contentName
    if contentType == LEADERBOARD_SCORE_NOTIFICATION_TYPE_RAID then
        contentName = GetRaidName(contentId)
    elseif contentType == LEADERBOARD_SCORE_NOTIFICATION_TYPE_ENDLESS_DUNGEON then
        contentName = GetString(SI_ENDLESS_DUNGEON_LEADERBOARDS_CATEGORIES_HEADER)
    end
    
    if not contentName or contentName == "" then
        RemoveLeaderboardScoreNotification(notificationId)
        return
    end
    
    ZO_ClearTable(Cache.contacts)
    local hasFriend, hasGuildMember, hasPlayer = false, false, false
    
    for memberIndex = 1, numMembers do
        local displayName, characterName, isFriend, isGuildMember, isPlayer = GetLeaderboardScoreNotificationMemberInfo(notificationId, memberIndex)    
        
        local isInEnabledGuild = isGuildMember and GuildSystem.IsPlayerInEnabledGuild(displayName)
    
        hasFriend = hasFriend or isFriend
        hasGuildMember = hasGuildMember or isInEnabledGuild
        hasPlayer = hasPlayer or isPlayer

        if isPlayer and State.Data.ShowOwnScores then
            local nameToUse = (displayName and displayName ~= "") and displayName or (characterName or "[Unknown]")
            table.insert(Cache.contacts, nameToUse)
        elseif isFriend or isInEnabledGuild then
            local nameToUse = (displayName and displayName ~= "") and displayName or (characterName or "[Unknown]")
            table.insert(Cache.contacts, nameToUse)
        end
    end
    
    if (hasPlayer and State.Data.ShowOwnScores) or ((hasFriend or hasGuildMember) and #Cache.contacts > 0) then
        MessageSystem.CreateNotificationMessage(contentType, contentName, score, numMembers, hasFriend, hasGuildMember, Cache.contacts, notificationId, contentContextualInfo, contentId, hasPlayer)  
    else
        RemoveLeaderboardScoreNotification(notificationId)
    end
end

function NotificationSystem.BuildNotificationList_Hook(self)
    ZO_ClearNumericallyIndexedTable(self.list)
    if GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_LEADERBOARD_NOTIFICATIONS) and State.Data.RNToChat then
        local notificationId = GetNextLeaderboardScoreNotificationId()
        while notificationId do
            NotificationSystem.ProcessNotification(self, notificationId)
            notificationId = GetNextLeaderboardScoreNotificationId(notificationId)
        end
    end
end

-- Module: Threshold Editor
local ThresholdEditor = {}
ThresholdEditor.window = nil
ThresholdEditor.list = nil
ThresholdEditor.currentCategory = "TRIAL"
ThresholdEditor.currentContent = nil
ThresholdEditor.selectedIndex = nil
ThresholdEditor.addDialog = nil

local RATING_ICONS = {
    {name = "Very Low", value = "VeryLow"},
    {name = "Low", value = "Low"},
    {name = "Normal", value = "Normal"},
    {name = "High", value = "High"},
    {name = "Very High", value = "VeryHigh"}
}

local function InitializeDialogs()
    -- Error dialog
    ZO_Dialogs_RegisterCustomDialog("L2C_ERROR_DIALOG", {
        title = {
            text = function(dialog)
                return dialog.data.title or "Error"
            end,
        },
        mainText = {
            text = function(dialog)
                return dialog.data.message or "An error occurred."
            end,
        },
        buttons = {
            {
                text = SI_OK,
                callback = function(dialog)
                    -- Just close the dialog
                end,
            },
        },
    })
    
    -- Confirmation dialog for reset
    ZO_Dialogs_RegisterCustomDialog("L2C_CONFIRM_RESET_DIALOG", {
        title = {
            text = "Reset to Defaults",
        },
        mainText = {
            text = function(dialog)
                local category = dialog.data.category
                local content = dialog.data.content
                
                if category == "TRIAL_SPECIFIC" and content then
                    return "Are you sure you want to reset all thresholds for " .. content .. " to default values? This action cannot be undone."
                elseif category == "TRIAL" then
                    return "Are you sure you want to reset all Generic Trial thresholds to default values? This action cannot be undone."
                elseif category == "ARCHIVE" then
                    return "Are you sure you want to reset all Infinite Archive thresholds to default values? This action cannot be undone."
                else
                    return "Are you sure you want to reset all thresholds to default values? This action cannot be undone."
                end
            end,
        },
        buttons = {
            {
                text = SI_YES,
                callback = function(dialog)
                    local category = dialog.data.category
                    local content = dialog.data.content
                    
                    if category == "TRIAL_SPECIFIC" and content then
                        State.SVAR.ScoreRatings.TRIAL_SPECIFIC[content] = 
                            ZO_DeepTableCopy(DEFAULT_SETTINGS.ScoreRatings.TRIAL_SPECIFIC[content])
                    else
                        State.SVAR.ScoreRatings[category] = 
                            ZO_DeepTableCopy(DEFAULT_SETTINGS.ScoreRatings[category])
                    end
                    ThresholdEditor.selectedIndex = nil
                    ThresholdEditor.RefreshList()
                    
                    -- Show success message
                    ZO_Dialogs_ShowDialog("L2C_SUCCESS_DIALOG", {
                        title = "Reset Complete",
                        message = "Thresholds have been reset to default values."
                    })
                end,
            },
            {
                text = SI_NO,
                callback = function(dialog)
                    -- Just close the dialog
                end,
            },
        },
    })
    
    -- Success dialog
    ZO_Dialogs_RegisterCustomDialog("L2C_SUCCESS_DIALOG", {
        title = {
            text = function(dialog)
                return dialog.data.title or "Success"
            end,
        },
        mainText = {
            text = function(dialog)
                return dialog.data.message or "Operation completed successfully."
            end,
        },
        buttons = {
            {
                text = SI_OK,
                callback = function(dialog)
                    -- Just close the dialog
                end,
            },
        },
    })
end

local function InitializeRemoveDialog()
    ZO_Dialogs_RegisterCustomDialog("L2C_CONFIRM_REMOVE_DIALOG", {
        title = {
            text = "Remove Threshold",
        },
        mainText = {
            text = function(dialog)
                local threshold = dialog.data.threshold
                if threshold then
                    return "Are you sure you want to remove the threshold for " .. ZO_CommaDelimitNumber(threshold.threshold) .. " points?\n\nThis action cannot be undone."
                else
                    return "Are you sure you want to remove this threshold?"
                end
            end,
        },
        buttons = {
            {
                text = SI_YES,
                callback = function(dialog)
                    local index = dialog.data.index
                    local thresholds = ThresholdEditor.GetCurrentThresholds()
                    
                    if thresholds and index and index <= #thresholds then
                        table.remove(thresholds, index)
                        ThresholdEditor.selectedIndex = nil
                        ThresholdEditor.RefreshList()
                        
                        ZO_Dialogs_ShowDialog("L2C_SUCCESS_DIALOG", {
                            title = "Threshold Removed",
                            message = "The threshold has been successfully removed."
                        })
                    end
                end,
            },
            {
                text = SI_NO,
                callback = function(dialog)
                    -- Just close the dialog
                end,
            },
        },
    })
end

function ThresholdEditor.Initialize()
    -- Create main window
    ThresholdEditor.window = WINDOW_MANAGER:CreateTopLevelWindow("L2C_ThresholdEditor")
    ThresholdEditor.window:SetDimensions(580, 520)  -- Increased width from 520 to 580, reduced height from 520 to 500
    ThresholdEditor.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    ThresholdEditor.window:SetMovable(true)
    ThresholdEditor.window:SetMouseEnabled(true)
    ThresholdEditor.window:SetClampedToScreen(true)
    ThresholdEditor.window:SetHidden(true)
    
    -- Background
    local bg = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.window, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.9)
    bg:SetEdgeColor(0.3, 0.5, 0.8, 1)
    bg:SetEdgeTexture("", 2, 2, 1)
    
    -- Header
    local header = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.window, CT_LABEL)
    header:SetFont("ZoFontWinH2")
    header:SetText("Score Rating Thresholds Editor")
    header:SetColor(1, 1, 1, 1)
    header:SetAnchor(TOPLEFT, ThresholdEditor.window, TOPLEFT, 20, 15)
    
    -- Close button
    local closeButton = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.window, CT_BUTTON)
    closeButton:SetDimensions(32, 32)
    closeButton:SetAnchor(TOPRIGHT, ThresholdEditor.window, TOPRIGHT, -15, 10)
    closeButton:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
    closeButton:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
    closeButton:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
    closeButton:SetHandler("OnClicked", function() ThresholdEditor.Hide() end)
    
    -- Category dropdown
    local categoryLabel = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.window, CT_LABEL)
    categoryLabel:SetFont("ZoFontGameBold")
    categoryLabel:SetText("Category:")
    categoryLabel:SetColor(1, 1, 1, 1)
    categoryLabel:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 20)
    
    local categoryDropdown = WINDOW_MANAGER:CreateControlFromVirtual("L2C_CategoryDropdown", ThresholdEditor.window, "ZO_ComboBox")
    categoryDropdown:SetDimensions(140, 30)
    categoryDropdown:SetAnchor(TOPLEFT, categoryLabel, BOTTOMLEFT, 0, 5)
    ThresholdEditor.categoryDropdown = ZO_ComboBox_ObjectFromContainer(categoryDropdown)
    ThresholdEditor.categoryDropdown:SetSortsItems(false)
    
    -- Content dropdown (for TRIAL_SPECIFIC)
    local contentLabel = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.window, CT_LABEL)
    contentLabel:SetFont("ZoFontGameBold")
    contentLabel:SetText("Content:")
    contentLabel:SetColor(1, 1, 1, 1)
    contentLabel:SetAnchor(TOPLEFT, categoryDropdown, TOPRIGHT, 15, -25)
    
    local contentDropdown = WINDOW_MANAGER:CreateControlFromVirtual("L2C_ContentDropdown", ThresholdEditor.window, "ZO_ComboBox")
    contentDropdown:SetDimensions(180, 30)
    contentDropdown:SetAnchor(TOPLEFT, contentLabel, BOTTOMLEFT, 0, 5)
    ThresholdEditor.contentDropdown = ZO_ComboBox_ObjectFromContainer(contentDropdown)
    ThresholdEditor.contentDropdown:SetSortsItems(false)
    
    -- Store references to the labels for hiding/showing
    ThresholdEditor.contentLabel = contentLabel
    
    -- Headers
    local headersBG = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.window, CT_BACKDROP)
    headersBG:SetDimensions(540, 30)  -- Increased from 480 to 540
    headersBG:SetAnchor(TOPLEFT, categoryDropdown, BOTTOMLEFT, 0, 20)
    headersBG:SetCenterColor(0.2, 0.2, 0.2, 0.8)
    headersBG:SetEdgeColor(0.4, 0.4, 0.4, 1)
    headersBG:SetEdgeTexture("", 1, 1, 1)
    
    local thresholdHeader = WINDOW_MANAGER:CreateControl(nil, headersBG, CT_LABEL)
    thresholdHeader:SetFont("ZoFontGameBold")
    thresholdHeader:SetText("Threshold")
    thresholdHeader:SetColor(1, 1, 1, 1)
    thresholdHeader:SetAnchor(LEFT, headersBG, LEFT, 10, 0)
    
    local nameHeader = WINDOW_MANAGER:CreateControl(nil, headersBG, CT_LABEL)
    nameHeader:SetFont("ZoFontGameBold")
    nameHeader:SetText("Rating Name")
    nameHeader:SetColor(1, 1, 1, 1)
    nameHeader:SetAnchor(LEFT, thresholdHeader, RIGHT, 70, 0)  -- Increased spacing from 60 to 70
    
    local iconHeader = WINDOW_MANAGER:CreateControl(nil, headersBG, CT_LABEL)
    iconHeader:SetFont("ZoFontGameBold")
    iconHeader:SetText("Icon")
    iconHeader:SetColor(1, 1, 1, 1)
    iconHeader:SetAnchor(LEFT, nameHeader, RIGHT, 160, 0)  -- Increased spacing from 130 to 160
    
    -- Scroll list
    local scrollContainer = WINDOW_MANAGER:CreateControlFromVirtual("L2C_ScrollContainer", ThresholdEditor.window, "ZO_ScrollContainer")
    scrollContainer:SetDimensions(540, 280)  -- Increased width from 480 to 540, reduced height from 300 to 280
    scrollContainer:SetAnchor(TOPLEFT, headersBG, BOTTOMLEFT, 0, 10)
    
    ThresholdEditor.list = WINDOW_MANAGER:CreateControlFromVirtual("L2C_ThresholdList", scrollContainer, "ZO_ScrollList")
    ThresholdEditor.list:SetAnchorFill()
    
    -- Control buttons
    local buttonContainer = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.window, CT_CONTROL)
    buttonContainer:SetDimensions(540, 40)  -- Increased width from 480 to 540
    buttonContainer:SetAnchor(TOPLEFT, scrollContainer, BOTTOMLEFT, 0, 10)
    
    local addButton = WINDOW_MANAGER:CreateControlFromVirtual("L2C_AddButton", buttonContainer, "ZO_DefaultButton")
    addButton:SetDimensions(70, 30)
    addButton:SetAnchor(LEFT, buttonContainer, LEFT, 0, 0)
    addButton:SetText("Add")
    addButton:SetHandler("OnClicked", function() ThresholdEditor.ShowAddDialog() end)
    
    local editButton = WINDOW_MANAGER:CreateControlFromVirtual("L2C_EditButton", buttonContainer, "ZO_DefaultButton")
    editButton:SetDimensions(70, 30)
    editButton:SetAnchor(LEFT, addButton, RIGHT, 8, 0)
    editButton:SetText("Edit")
    editButton:SetHandler("OnClicked", function() ThresholdEditor.ShowEditDialog() end)
    
    local removeButton = WINDOW_MANAGER:CreateControlFromVirtual("L2C_RemoveButton", buttonContainer, "ZO_DefaultButton")
    removeButton:SetDimensions(70, 30)
    removeButton:SetAnchor(LEFT, editButton, RIGHT, 8, 0)
    removeButton:SetText("Remove")
    removeButton:SetHandler("OnClicked", function() ThresholdEditor.RemoveThreshold() end)
    
    local resetButton = WINDOW_MANAGER:CreateControlFromVirtual("L2C_ResetButton", buttonContainer, "ZO_DefaultButton")
    resetButton:SetDimensions(130, 30)
    resetButton:SetAnchor(RIGHT, buttonContainer, RIGHT, 0, 0)
    resetButton:SetText("Reset to Defaults")
    resetButton:SetHandler("OnClicked", function() ThresholdEditor.ResetToDefaults() end)
    
    ThresholdEditor.InitializeScrollList()
    ThresholdEditor.PopulateDropdowns()
    ThresholdEditor.CreateAddDialog()
end

function ThresholdEditor.CreateAddDialog()
    -- Create dialog window - Made larger to accommodate all controls
    ThresholdEditor.addDialog = WINDOW_MANAGER:CreateTopLevelWindow("L2C_AddThresholdDialog")
    ThresholdEditor.addDialog:SetDimensions(390, 420)  -- Reduced height since no icon preview
    ThresholdEditor.addDialog:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    ThresholdEditor.addDialog:SetMovable(true)
    ThresholdEditor.addDialog:SetMouseEnabled(true)
    ThresholdEditor.addDialog:SetClampedToScreen(true)
    ThresholdEditor.addDialog:SetHidden(true)
    ThresholdEditor.addDialog:SetDrawTier(DT_MEDIUM)  -- Changed to MEDIUM so color picker can be HIGH
    ThresholdEditor.addDialog:SetDrawLevel(1)
    
    -- Background
    local bg = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.addDialog, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.9)
    bg:SetEdgeColor(0.3, 0.5, 0.8, 1)
    bg:SetEdgeTexture("", 2, 2, 1)
    
    -- Header
    local header = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.addDialog, CT_LABEL)
    header:SetFont("ZoFontWinH3")
    header:SetText("Add New Threshold")
    header:SetColor(1, 1, 1, 1)
    header:SetAnchor(TOPLEFT, ThresholdEditor.addDialog, TOPLEFT, 20, 15)
    ThresholdEditor.addDialog.header = header
    
    -- Close button
    local closeButton = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.addDialog, CT_BUTTON)
    closeButton:SetDimensions(24, 24)
    closeButton:SetAnchor(TOPRIGHT, ThresholdEditor.addDialog, TOPRIGHT, -15, 15)
    closeButton:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
    closeButton:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
    closeButton:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
    closeButton:SetHandler("OnClicked", function() ThresholdEditor.HideAddDialog() end)
    
    -- Score input with increment/decrement buttons
    local scoreLabel = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.addDialog, CT_LABEL)
    scoreLabel:SetFont("ZoFontGameBold")
    scoreLabel:SetText("Score Threshold:")
    scoreLabel:SetColor(1, 1, 1, 1)
    scoreLabel:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 25)
    
    -- Score input container
    local scoreContainer = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.addDialog, CT_CONTROL)
    scoreContainer:SetDimensions(350, 32)
    scoreContainer:SetAnchor(TOPLEFT, scoreLabel, BOTTOMLEFT, 0, 5)
    
    -- Score editbox background
    local scoreBG = WINDOW_MANAGER:CreateControl(nil, scoreContainer, CT_BACKDROP)
    scoreBG:SetDimensions(250, 32)
    scoreBG:SetAnchor(LEFT, scoreContainer, LEFT, 0, 0)
    scoreBG:SetCenterColor(0.1, 0.1, 0.1, 1)
    scoreBG:SetEdgeColor(0.4, 0.4, 0.4, 1)
    scoreBG:SetEdgeTexture("", 1, 1, 1)
    
    -- Score editbox
    local scoreInput = WINDOW_MANAGER:CreateControl(nil, scoreBG, CT_EDITBOX)
    scoreInput:SetAnchor(TOPLEFT, scoreBG, TOPLEFT, 5, 5)
    scoreInput:SetAnchor(BOTTOMRIGHT, scoreBG, BOTTOMRIGHT, -5, -5)
    scoreInput:SetFont("ZoFontGame")
    scoreInput:SetMaxInputChars(10)
    scoreInput:SetEditEnabled(true)
    scoreInput:SetMouseEnabled(true)
    scoreInput:SetTextType(TEXT_TYPE_NUMERIC)
    scoreInput:SetColor(1, 1, 1, 1)
    scoreInput:SetText("0")
    ThresholdEditor.addDialog.scoreInput = scoreInput
    
    -- Force the editbox to be selectable
    scoreInput:SetHandler("OnMouseDown", function(self) 
        self:TakeFocus() 
    end)

    -- Add mouse wheel handler for score input
    scoreInput:SetHandler("OnMouseWheel", function(control, delta)
        local currentValue = tonumber(control:GetText()) or 0
        if delta > 0 then
            control:SetText(tostring(currentValue + 1000))
        else
            control:SetText(tostring(math.max(0, currentValue - 1000)))
        end
    end)
    
    -- Decrement button (-) - Now on the left
    local decrementButton = WINDOW_MANAGER:CreateControlFromVirtual("L2C_DecrementButton", scoreContainer, "ZO_DefaultButton")
    decrementButton:SetDimensions(40, 32)  -- Made wider
    decrementButton:SetAnchor(LEFT, scoreBG, RIGHT, 5, 0)
    decrementButton:SetText("-")
    decrementButton:SetHandler("OnClicked", function()
        local currentValue = tonumber(scoreInput:GetText()) or 0
        scoreInput:SetText(tostring(math.max(0, currentValue - 1000)))
    end)
    
    -- Increment button (+) - Now on the right of decrement
    local incrementButton = WINDOW_MANAGER:CreateControlFromVirtual("L2C_IncrementButton", scoreContainer, "ZO_DefaultButton")
    incrementButton:SetDimensions(40, 32)  -- Made wider
    incrementButton:SetAnchor(LEFT, decrementButton, RIGHT, 2, 0)
    incrementButton:SetText("+")
    incrementButton:SetHandler("OnClicked", function()
        local currentValue = tonumber(scoreInput:GetText()) or 0
        scoreInput:SetText(tostring(currentValue + 1000))
    end)
    
    -- Name input
    local nameLabel = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.addDialog, CT_LABEL)
    nameLabel:SetFont("ZoFontGameBold")
    nameLabel:SetText("Rating Name:")
    nameLabel:SetColor(1, 1, 1, 1)
    nameLabel:SetAnchor(TOPLEFT, scoreContainer, BOTTOMLEFT, 0, 15)
    
    local nameBG = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.addDialog, CT_BACKDROP)
    nameBG:SetDimensions(350, 30)
    nameBG:SetAnchor(TOPLEFT, nameLabel, BOTTOMLEFT, 0, 5)
    nameBG:SetCenterColor(0.1, 0.1, 0.1, 1)
    nameBG:SetEdgeColor(0.4, 0.4, 0.4, 1)
    nameBG:SetEdgeTexture("", 1, 1, 1)
    
    local nameInput = WINDOW_MANAGER:CreateControl(nil, nameBG, CT_EDITBOX)
    nameInput:SetAnchor(TOPLEFT, nameBG, TOPLEFT, 5, 5)
    nameInput:SetAnchor(BOTTOMRIGHT, nameBG, BOTTOMRIGHT, -5, -5)
    nameInput:SetFont("ZoFontGame")
    nameInput:SetMaxInputChars(50)
    nameInput:SetEditEnabled(true)
    nameInput:SetMouseEnabled(true)
    nameInput:SetTextType(TEXT_TYPE_ALL)
    nameInput:SetColor(1, 1, 1, 1)
    -- Force the editbox to be selectable
    nameInput:SetHandler("OnMouseDown", function(self) 
        self:TakeFocus() 
    end)
    ThresholdEditor.addDialog.nameInput = nameInput
    
    -- Color picker for the rating name
    local colorLabel = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.addDialog, CT_LABEL)
    colorLabel:SetFont("ZoFontGameBold")
    colorLabel:SetText("Rating Color:")
    colorLabel:SetColor(1, 1, 1, 1)
    colorLabel:SetAnchor(TOPLEFT, nameBG, BOTTOMLEFT, 0, 15)
    
    -- Create color picker button
    local colorButton = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.addDialog, CT_BUTTON)
    colorButton:SetDimensions(40, 30)
    colorButton:SetAnchor(TOPLEFT, colorLabel, BOTTOMLEFT, 0, 5)
    
    -- Create color swatch backdrop
    local colorSwatch = WINDOW_MANAGER:CreateControl(nil, colorButton, CT_BACKDROP)
    colorSwatch:SetAnchorFill()
    colorSwatch:SetCenterColor(1, 1, 1, 1)  -- Default to white
    colorSwatch:SetEdgeColor(0.4, 0.4, 0.4, 1)
    colorSwatch:SetEdgeTexture("", 1, 1, 1)
    
    ThresholdEditor.addDialog.colorSwatch = colorSwatch
    ThresholdEditor.addDialog.selectedColor = {r = 1, g = 1, b = 1}
    
    -- Preview label to show how the colored name will look - Anchored to the right
    local previewLabel = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.addDialog, CT_LABEL)
    previewLabel:SetFont("ZoFontGameBold")
    previewLabel:SetText("Preview:")
    previewLabel:SetColor(1, 1, 1, 1)
    previewLabel:SetAnchor(LEFT, colorButton, RIGHT, 20, 0)
    
    local previewText = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.addDialog, CT_LABEL)
    previewText:SetFont("ZoFontGame")
    previewText:SetText("Sample Rating")
    previewText:SetColor(1, 1, 1, 1)
    previewText:SetAnchor(LEFT, previewLabel, RIGHT, 10, 0)  -- Anchored to the right of Preview label
    previewText:SetDimensions(220, 30)  -- Set explicit width to prevent overflow
    previewText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    previewText:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)  -- Add ellipsis for overflow
    ThresholdEditor.addDialog.previewText = previewText

    -- Update preview function - DEFINE THIS FIRST before using it
    local function UpdatePreview()
        local nameText = nameInput:GetText()
        local color = ThresholdEditor.addDialog.selectedColor
        if nameText and nameText ~= "" and color then
            -- Limit the preview text length to prevent overflow
            local displayText = nameText
            if string.len(displayText) > 28 then
                displayText = string.sub(displayText, 1, 25) .. "..."
            end
            
            local colorCode = string.format("|c%02X%02X%02X%s|r", 
                math.floor(color.r * 255), 
                math.floor(color.g * 255), 
                math.floor(color.b * 255), 
                displayText)
            previewText:SetText(colorCode)
        else
            previewText:SetText("Sample Rating")
        end
    end
    
    -- Store the function reference
    ThresholdEditor.addDialog.updatePreview = UpdatePreview
    
    -- Set up color picker callback with highest draw tier
    colorButton:SetHandler("OnClicked", function()
        local color = ThresholdEditor.addDialog.selectedColor
        COLOR_PICKER:Show(function(newR, newG, newB)
            colorSwatch:SetCenterColor(newR, newG, newB, 1)
            ThresholdEditor.addDialog.selectedColor = {r = newR, g = newG, b = newB}
            UpdatePreview()  -- Call the local function directly
        end, color.r, color.g, color.b)
    end)
    
    -- Set up text change handler
    nameInput:SetHandler("OnTextChanged", UpdatePreview)  -- Call the local function directly
    
    -- Icon dropdown - Removed preview since icons are now in dropdown text
    local iconLabel = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.addDialog, CT_LABEL)
    iconLabel:SetFont("ZoFontGameBold")
    iconLabel:SetText("Icon:")
    iconLabel:SetColor(1, 1, 1, 1)
    iconLabel:SetAnchor(TOPLEFT, colorButton, BOTTOMLEFT, 0, 15)
    
    local iconDropdown = WINDOW_MANAGER:CreateControlFromVirtual("L2C_IconDropdown", ThresholdEditor.addDialog, "ZO_ComboBox")
    iconDropdown:SetDimensions(350, 30)  -- Made wider since no preview beside it
    iconDropdown:SetAnchor(TOPLEFT, iconLabel, BOTTOMLEFT, 0, 5)
    ThresholdEditor.addDialog.iconDropdown = ZO_ComboBox_ObjectFromContainer(iconDropdown)
    ThresholdEditor.addDialog.iconDropdown:SetSortsItems(false)
    
    -- Populate icon dropdown with icons in text
    local function OnIconSelect(_, choiceText, choice)
        ThresholdEditor.addDialog.selectedIcon = choice.value
    end
    
    for _, icon in ipairs(RATING_ICONS) do
        local iconText = zo_iconTextFormat(ICONS[icon.value], 16, 16, icon.name)
        local entry = ZO_ComboBox:CreateItemEntry(iconText, OnIconSelect)
        entry.value = icon.value
        ThresholdEditor.addDialog.iconDropdown:AddItem(entry)
    end
    ThresholdEditor.addDialog.iconDropdown:SelectFirstItem()
    ThresholdEditor.addDialog.selectedIcon = RATING_ICONS[1].value
    
    -- Buttons
    local buttonContainer = WINDOW_MANAGER:CreateControl(nil, ThresholdEditor.addDialog, CT_CONTROL)
    buttonContainer:SetDimensions(350, 40)
    buttonContainer:SetAnchor(TOPLEFT, iconDropdown, BOTTOMLEFT, 0, 15)
    
    local saveButton = WINDOW_MANAGER:CreateControlFromVirtual("L2C_SaveButton", buttonContainer, "ZO_DefaultButton")
    saveButton:SetDimensions(80, 30)
    saveButton:SetAnchor(LEFT, buttonContainer, LEFT, 0, 0)
    saveButton:SetText("Save")
    saveButton:SetHandler("OnClicked", function() ThresholdEditor.SaveThreshold() end)
    
    local cancelButton = WINDOW_MANAGER:CreateControlFromVirtual("L2C_CancelButton", buttonContainer, "ZO_DefaultButton")
    cancelButton:SetDimensions(80, 30)
    cancelButton:SetAnchor(RIGHT, buttonContainer, RIGHT, 0, 0)
    cancelButton:SetText("Cancel")
    cancelButton:SetHandler("OnClicked", function() ThresholdEditor.HideAddDialog() end)
end

function ThresholdEditor.ShowAddDialog()
    if not ThresholdEditor.addDialog then
        ThresholdEditor.CreateAddDialog()
    end
    
    -- Center the dialog relative to the main threshold editor window
    if ThresholdEditor.window and not ThresholdEditor.window:IsHidden() then
        ThresholdEditor.addDialog:ClearAnchors()
        ThresholdEditor.addDialog:SetAnchor(CENTER, ThresholdEditor.window, CENTER, 0, 0)
    else
        ThresholdEditor.addDialog:ClearAnchors()
        ThresholdEditor.addDialog:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    
    -- Reset form for adding
    ThresholdEditor.addDialog.header:SetText("Add New Threshold")
    ThresholdEditor.addDialog.scoreInput:SetText("0")
    ThresholdEditor.addDialog.nameInput:SetText("")
    ThresholdEditor.addDialog.colorSwatch:SetCenterColor(1, 1, 1, 1)
    ThresholdEditor.addDialog.selectedColor = {r = 1, g = 1, b = 1}
    ThresholdEditor.addDialog.iconDropdown:SelectFirstItem()
    ThresholdEditor.addDialog.selectedIcon = RATING_ICONS[1].value
    ThresholdEditor.addDialog.editingIndex = nil
    
    -- Safety check before calling updatePreview
    if ThresholdEditor.addDialog.updatePreview then
        ThresholdEditor.addDialog.updatePreview()
    end
    
    ThresholdEditor.addDialog:SetHidden(false)
    -- Force focus to the name input after a brief delay
    zo_callLater(function()
        if ThresholdEditor.addDialog and not ThresholdEditor.addDialog:IsHidden() then
            ThresholdEditor.addDialog.nameInput:TakeFocus()
        end
    end, 50)
end

function ThresholdEditor.ShowEditDialog()
    if not ThresholdEditor.selectedIndex then return end
    
    if not ThresholdEditor.addDialog then
        ThresholdEditor.CreateAddDialog()
    end
    
    -- Center the dialog relative to the main threshold editor window
    if ThresholdEditor.window and not ThresholdEditor.window:IsHidden() then
        ThresholdEditor.addDialog:ClearAnchors()
        ThresholdEditor.addDialog:SetAnchor(CENTER, ThresholdEditor.window, CENTER, 0, 0)
    else
        ThresholdEditor.addDialog:ClearAnchors()
        ThresholdEditor.addDialog:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    
    local thresholds = ThresholdEditor.GetCurrentThresholds()
    if not thresholds or ThresholdEditor.selectedIndex > #thresholds then return end
    
    local threshold = thresholds[ThresholdEditor.selectedIndex]
    
    -- Populate form for editing
    ThresholdEditor.addDialog.header:SetText("Edit Threshold")
    ThresholdEditor.addDialog.scoreInput:SetText(tostring(threshold.threshold))
    
    -- Extract color and plain text from the colored name
    local plainName, colorR, colorG, colorB = ThresholdEditor.ExtractColorFromName(threshold.name)
    ThresholdEditor.addDialog.nameInput:SetText(plainName)
    ThresholdEditor.addDialog.colorSwatch:SetCenterColor(colorR, colorG, colorB, 1)
    ThresholdEditor.addDialog.selectedColor = {r = colorR, g = colorG, b = colorB}
    
    -- Select the correct icon
    for i, icon in ipairs(RATING_ICONS) do
        if icon.value == threshold.icon then
            ThresholdEditor.addDialog.iconDropdown:SelectItemByIndex(i)
            ThresholdEditor.addDialog.selectedIcon = icon.value
            break
        end
    end
    
    ThresholdEditor.addDialog.editingIndex = ThresholdEditor.selectedIndex
    
    -- Safety check before calling updatePreview
    if ThresholdEditor.addDialog.updatePreview then
        ThresholdEditor.addDialog.updatePreview()
    end
    
    ThresholdEditor.addDialog:SetHidden(false)
    -- Force focus to the name input after a brief delay
    zo_callLater(function()
        if ThresholdEditor.addDialog and not ThresholdEditor.addDialog:IsHidden() then
            ThresholdEditor.addDialog.nameInput:TakeFocus()
        end
    end, 50)
end

function ThresholdEditor.SaveThreshold()
    local score = tonumber(ThresholdEditor.addDialog.scoreInput:GetText()) or 0
    local nameText = ThresholdEditor.addDialog.nameInput:GetText()
    local selectedIcon = ThresholdEditor.addDialog.selectedIcon
    local color = ThresholdEditor.addDialog.selectedColor
    
    -- Validate input
    if not nameText or nameText == "" then
        ZO_Dialogs_ShowDialog("L2C_ERROR_DIALOG", {
            title = "Input Error",
            message = "Please enter a rating name."
        })
        return
    end
    
    if score < 0 then
        ZO_Dialogs_ShowDialog("L2C_ERROR_DIALOG", {
            title = "Input Error", 
            message = "Score must be a positive number."
        })
        return
    end
    
    local thresholds = ThresholdEditor.GetCurrentThresholds()
    if not thresholds then return end
    
    -- Check for duplicate threshold scores (excluding current item when editing)
    local editingIndex = ThresholdEditor.addDialog.editingIndex
    for i, threshold in ipairs(thresholds) do
        if threshold.threshold == score and i ~= editingIndex then
            ZO_Dialogs_ShowDialog("L2C_ERROR_DIALOG", {
                title = "Duplicate Score",
                message = "A threshold with score " .. ZO_CommaDelimitNumber(score) .. " already exists."
            })
            return
        end
    end
    
    -- Create colored name
    local coloredName = string.format("|c%02X%02X%02X%s|r", 
        math.floor(color.r * 255), 
        math.floor(color.g * 255), 
        math.floor(color.b * 255), 
        nameText)
    
    local newThreshold = {
        threshold = score,
        name = coloredName,
        icon = selectedIcon
    }
    
    if editingIndex then
        -- Edit existing threshold
        thresholds[editingIndex] = newThreshold
        -- Keep the same selection after editing
        ThresholdEditor.selectedIndex = editingIndex
    else
        -- Add new threshold
        table.insert(thresholds, newThreshold)
        
        -- Sort thresholds by score (descending)
        table.sort(thresholds, function(a, b) return a.threshold > b.threshold end)
        
        -- Find the new position of our added threshold and select it
        for i, threshold in ipairs(thresholds) do
            if threshold.threshold == score and threshold.name == coloredName and threshold.icon == selectedIcon then
                ThresholdEditor.selectedIndex = i
                break
            end
        end
    end
    
    ThresholdEditor.HideAddDialog()
    ThresholdEditor.RefreshList()
end

function ThresholdEditor.HideAddDialog()
    if ThresholdEditor.addDialog then
        ThresholdEditor.addDialog:SetHidden(true)
    end
end

function ThresholdEditor.ExtractColorFromName(coloredName)
    if not coloredName then return "", 1, 1, 1 end
    
    -- Try to match pattern |cRRGGBBtext|r
    local colorCode, plainText = string.match(coloredName, "|c(%x%x%x%x%x%x)(.+)|r")
    
    if colorCode and plainText then
        local r = tonumber(string.sub(colorCode, 1, 2), 16) / 255
        local g = tonumber(string.sub(colorCode, 3, 4), 16) / 255
        local b = tonumber(string.sub(colorCode, 5, 6), 16) / 255
        return plainText, r, g, b
    else
        -- No color formatting found, return as is with white color
        return coloredName, 1, 1, 1
    end
end

function ThresholdEditor.ShowContextMenu(control)
    ClearMenu()
    
    AddMenuItem("Edit", function()
        ThresholdEditor.ShowEditDialog()
    end)
    
    AddMenuItem("Remove", function()
        ThresholdEditor.RemoveThreshold()
    end)
    
    ShowMenu(control)
end

function ThresholdEditor.InitializeScrollList()
    local function SetupRow(control, data)
        control.data = data
        
        -- Ensure the control is properly sized and positioned
        control:SetDimensions(540, 30)  -- Increased from 480 to 540
        control:SetMouseEnabled(true)
        
        -- Clear any existing children
        for i = 1, control:GetNumChildren() do
            local child = control:GetChild(i)
            if child then
                child:SetHidden(true)
            end
        end
        
        -- Threshold
        local thresholdLabel = control:GetNamedChild("Threshold")
        if not thresholdLabel then
            thresholdLabel = WINDOW_MANAGER:CreateControl(control:GetName().."Threshold", control, CT_LABEL)
            thresholdLabel:SetFont("ZoFontGame")
            thresholdLabel:SetAnchor(LEFT, control, LEFT, 10, 0)
            thresholdLabel:SetDimensions(90, 30)  -- Increased from 80 to 90
            thresholdLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end
        thresholdLabel:SetText(ZO_CommaDelimitNumber(data.threshold))
        thresholdLabel:SetColor(1, 1, 1, 1)
        thresholdLabel:SetHidden(false)
        
        -- Name
        local nameLabel = control:GetNamedChild("Name")
        if not nameLabel then
            nameLabel = WINDOW_MANAGER:CreateControl(control:GetName().."Name", control, CT_LABEL)
            nameLabel:SetFont("ZoFontGame")
            nameLabel:SetAnchor(LEFT, thresholdLabel, RIGHT, 50, 0)  -- Increased spacing from 50 to 60
            nameLabel:SetDimensions(240, 30)  -- Increased from 210 to 240
            nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end
        nameLabel:SetText(data.name)
        nameLabel:SetHidden(false)
        
        -- Icon
        local iconTexture = control:GetNamedChild("Icon")
        if not iconTexture then
            iconTexture = WINDOW_MANAGER:CreateControl(control:GetName().."Icon", control, CT_TEXTURE)
            iconTexture:SetDimensions(24, 24)
            iconTexture:SetAnchor(LEFT, nameLabel, RIGHT, 20, 3)  -- Increased spacing from 100 to 130
        end
        iconTexture:SetTexture(ICONS[data.icon])
        iconTexture:SetHidden(false)
        
        -- Selection highlight
        local highlight = control:GetNamedChild("Highlight")
        if not highlight then
            highlight = WINDOW_MANAGER:CreateControl(control:GetName().."Highlight", control, CT_BACKDROP)
            highlight:SetAnchorFill()
            highlight:SetCenterColor(0.3, 0.5, 0.8, 0.3)
        end
        highlight:SetHidden(ThresholdEditor.selectedIndex ~= data.index)
        
        -- Mouse handling for selection
        control:SetHandler("OnMouseUp", function(self, button, upInside)
            if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
                ThresholdEditor.selectedIndex = data.index
                ThresholdEditor.RefreshList()
            elseif button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
                -- Right click context menu
                ThresholdEditor.selectedIndex = data.index
                ThresholdEditor.RefreshList()
                ThresholdEditor.ShowContextMenu(control)
            end
        end)
        
        control:SetHandler("OnMouseEnter", function(self)
            if ThresholdEditor.selectedIndex ~= data.index then
                local hoverHighlight = control:GetNamedChild("HoverHighlight")
                if not hoverHighlight then
                    hoverHighlight = WINDOW_MANAGER:CreateControl(control:GetName().."HoverHighlight", control, CT_BACKDROP)
                    hoverHighlight:SetAnchorFill()
                    hoverHighlight:SetCenterColor(1, 1, 1, 0.1)
                end
                hoverHighlight:SetHidden(false)
            end
        end)
        
        control:SetHandler("OnMouseExit", function(self)
            local hoverHighlight = control:GetNamedChild("HoverHighlight")
            if hoverHighlight then
                hoverHighlight:SetHidden(true)
            end
        end)
    end
    
    local function ResetRow(control)
        control:SetHidden(true)
        control.data = nil
        control:SetMouseEnabled(false)
        
        -- Clear event handlers
        control:SetHandler("OnMouseUp", nil)
        control:SetHandler("OnMouseEnter", nil)
        control:SetHandler("OnMouseExit", nil)
        
        -- Hide all children
        for i = 1, control:GetNumChildren() do
            local child = control:GetChild(i)
            if child then
                child:SetHidden(true)
            end
        end
    end
    
    -- Initialize scroll list
    ZO_ScrollList_Initialize(ThresholdEditor.list)
    
    -- Use a proper row template
    ZO_ScrollList_AddDataType(ThresholdEditor.list, 1, "ZO_SelectableLabel", 30, SetupRow, nil, nil, ResetRow)
end

function ThresholdEditor.PopulateDropdowns()
    -- Category dropdown
    ThresholdEditor.categoryDropdown:ClearItems()
    
    local function OnCategorySelect(_, choiceText, choice)
        ThresholdEditor.currentCategory = choice.value
        ThresholdEditor.currentContent = nil
        ThresholdEditor.selectedIndex = nil
        ThresholdEditor.PopulateContentDropdown()
        ThresholdEditor.RefreshList()
    end
    
    local categories = {
        {name = "Generic Trial", value = "TRIAL"},
        {name = "Infinite Archive", value = "ARCHIVE"},
        {name = "Specific Content", value = "TRIAL_SPECIFIC"}
    }
    
    for _, category in ipairs(categories) do
        local entry = ZO_ComboBox:CreateItemEntry(category.name, OnCategorySelect)
        entry.value = category.value
        ThresholdEditor.categoryDropdown:AddItem(entry)
    end
    
    ThresholdEditor.categoryDropdown:SelectFirstItem()
    ThresholdEditor.PopulateContentDropdown()
end

function ThresholdEditor.PopulateContentDropdown()
    ThresholdEditor.contentDropdown:ClearItems()
    
    if ThresholdEditor.currentCategory ~= "TRIAL_SPECIFIC" then
        ThresholdEditor.contentDropdown:GetContainer():SetHidden(true)
        if ThresholdEditor.contentLabel then
            ThresholdEditor.contentLabel:SetHidden(true)
        end
        return
    end
    
    ThresholdEditor.contentDropdown:GetContainer():SetHidden(false)
    if ThresholdEditor.contentLabel then
        ThresholdEditor.contentLabel:SetHidden(false)
    end
    
    local function OnContentSelect(_, choiceText, choice)
        ThresholdEditor.currentContent = choice.value
        ThresholdEditor.selectedIndex = nil
        ThresholdEditor.RefreshList()
    end
    
    for contentName, _ in pairs(State.SVAR.ScoreRatings.TRIAL_SPECIFIC) do
        local entry = ZO_ComboBox:CreateItemEntry(contentName, OnContentSelect)
        entry.value = contentName
        ThresholdEditor.contentDropdown:AddItem(entry)
    end
    
    ThresholdEditor.contentDropdown:SelectFirstItem()
end

function ThresholdEditor.RefreshList()
    local scrollData = ZO_ScrollList_GetDataList(ThresholdEditor.list)
    ZO_ClearTable(scrollData)
    
    local thresholds
    if ThresholdEditor.currentCategory == "TRIAL_SPECIFIC" and ThresholdEditor.currentContent then
        thresholds = State.SVAR.ScoreRatings.TRIAL_SPECIFIC[ThresholdEditor.currentContent]
    else
        thresholds = State.SVAR.ScoreRatings[ThresholdEditor.currentCategory]
    end
    
    if thresholds then
        for i, threshold in ipairs(thresholds) do
            local data = {
                threshold = threshold.threshold,
                name = threshold.name,
                icon = threshold.icon,
                index = i
            }
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
        end
    end
    
    ZO_ScrollList_Commit(ThresholdEditor.list)
end

function ThresholdEditor.Show()
    if not ThresholdEditor.window then
        ThresholdEditor.Initialize()
    end
    ThresholdEditor.window:SetHidden(false)
    ThresholdEditor.RefreshList()
end

function ThresholdEditor.Hide()
    if ThresholdEditor.window then
        ThresholdEditor.window:SetHidden(true)
    end
    ThresholdEditor.HideAddDialog()
end

function ThresholdEditor.AddThreshold()
    ThresholdEditor.ShowAddDialog()
end

function ThresholdEditor.EditThreshold()
    ThresholdEditor.ShowEditDialog()
end

function ThresholdEditor.RemoveThreshold()
    if not ThresholdEditor.selectedIndex then 
        ZO_Dialogs_ShowDialog("L2C_ERROR_DIALOG", {
            title = "No Selection",
            message = "Please select a threshold to remove."
        })
        return 
    end
    
    local thresholds = ThresholdEditor.GetCurrentThresholds()
    if not thresholds or ThresholdEditor.selectedIndex > #thresholds then
        ZO_Dialogs_ShowDialog("L2C_ERROR_DIALOG", {
            title = "Invalid Selection",
            message = "Selected threshold no longer exists."
        })
        return
    end
    
    local threshold = thresholds[ThresholdEditor.selectedIndex]
    ZO_Dialogs_ShowDialog("L2C_CONFIRM_REMOVE_DIALOG", {
        threshold = threshold,
        index = ThresholdEditor.selectedIndex
    })
end

function ThresholdEditor.ResetToDefaults()
    ZO_Dialogs_ShowDialog("L2C_CONFIRM_RESET_DIALOG", {
        category = ThresholdEditor.currentCategory,
        content = ThresholdEditor.currentContent
    })
end

function ThresholdEditor.GetCurrentThresholds()
    if ThresholdEditor.currentCategory == "TRIAL_SPECIFIC" and ThresholdEditor.currentContent then
        return State.SVAR.ScoreRatings.TRIAL_SPECIFIC[ThresholdEditor.currentContent]
    else
        return State.SVAR.ScoreRatings[ThresholdEditor.currentCategory]
    end
end

-- Module: Settings System
local SettingsSystem = {}

function SettingsSystem.Donation()
    SCENE_MANAGER:Show('mailSend')
    zo_callLater(function() 
        ZO_MailSendToField:SetText("@ZaiZah")
        ZO_MailSendSubjectField:SetText("Donation for Zai's Addon")
        ZO_MailSendBodyField:SetText("Thanks for the Cool Addon!")
        ZO_MailSendBodyField:TakeFocus()
    end, 250)
end

function SettingsSystem.CreateGuildFilterControls()
    local guildControls = {}
    
    -- Add header for guild filters
    table.insert(guildControls, {
        type = "header",
        name = "Guild Member Notifications",
        tooltip = "Choose which guilds to monitor for leaderboard achievements",
    })
    
    -- Add checkboxes for each guild
    for guildId = 1, 5 do
        local guildName = "Not in a guild"
        if GetNumGuilds() >= guildId then
            local guildIndex = GetGuildId(guildId)
            guildName = GetGuildName(guildIndex)
        end
        
        table.insert(guildControls, {
            type = "checkbox",
            name = "Guild " .. guildId .. ": " .. guildName,
            tooltip = "Include leaderboard achievements from members of " .. guildName,
            getFunc = function() return State.SVAR.GuildFilter[guildId] end,
            setFunc = function(enabled) 
                State.SVAR.GuildFilter[guildId] = enabled
                State.Data.GuildFilter[guildId] = enabled
            end,
            default = DEFAULT_SETTINGS.GuildFilter[guildId],
            disabled = function() return not State.Data.RNToChat end,
            width = "half",
        })
    end
    
    return guildControls
end

function SettingsSystem.CreateMessageExamplesControl()
    local controls = {}
    table.insert(controls, {
        type = "header",
        name = "Message Examples",
        width = "full",
    })
    
    table.insert(controls, {
        type = "custom",
        reference = "L2CMessageExamples",
        width = "full",
        minHeight = 200,
        
        createFunc = function(customControl)
            -- Create example labels
            customControl.labels = {}
            
            for i = 1, 3 do
                local label = WINDOW_MANAGER:CreateControl(nil, customControl, CT_LABEL)
                label:SetFont("ZoFontGame")
                label:SetWidth(customControl:GetWidth() - 20)
                label:SetMaxLineCount(4)
                label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
                table.insert(customControl.labels, label)
            end
            
            -- Position labels vertically
            customControl.labels[1]:SetAnchor(TOPLEFT, customControl, TOPLEFT, 10, 10)
            customControl.labels[2]:SetAnchor(TOPLEFT, customControl.labels[1], BOTTOMLEFT, 0, 20)
            customControl.labels[3]:SetAnchor(TOPLEFT, customControl.labels[2], BOTTOMLEFT, 0, 20)
            
            -- Initial update
            SettingsSystem.UpdateExampleMessages(customControl)
        end,
        
        refreshFunc = function(customControl)
            SettingsSystem.UpdateExampleMessages(customControl)
        end
    })
    
    return controls
end

function SettingsSystem.UpdateExampleMessages(customControl)
    if not customControl or not customControl.labels then return end
    
    local raidExampleIcon = zo_iconFormat(ICONS.trialIcon, 32, 32)
    local archiveExampleIcon = zo_iconFormat(ICONS.endlessIcon, 28, 28)
    local ratingExampleIcon = zo_iconFormat(ICONS.High, 28, 28)
    local ratingExampleIcon2 = zo_iconFormat(ICONS.Normal, 28, 28)

    -- Trial example with consistent colors
    local trialExample = string.format(
        "|c%sYour friends|r (|c%sPlayerOne, PlayerTwo|r)|c%s completed|r%s|c%sRockgrove|r |c%swith a score of|r |c%s180,000|r - %s|c00FF00Outstanding|r", 
        State.Data.MessageColors.GeneralColor,
        State.Data.MessageColors.PlayersColor,
        State.Data.MessageColors.GeneralColor,
        raidExampleIcon, 
        State.Data.MessageColors.ContentColor,
        State.Data.MessageColors.GeneralColor,
        State.Data.MessageColors.ScoreColor,
        ratingExampleIcon
    )
    
    -- Archive example with progression info and icons
    local archiveExample = string.format(
        "|c%sYour guild mate|r (|c%sPlayerThree|r)|c%s completed|r %s|c%sInfinite Archive|r |c%swith a score of|r |c%s50,000|r (%s - %s - %s) - %s|cFFFF00Archive Adept|r", 
        State.Data.MessageColors.GeneralColor,
        State.Data.MessageColors.PlayersColor,
        State.Data.MessageColors.GeneralColor,
        archiveExampleIcon,
        State.Data.MessageColors.ContentColor,
        State.Data.MessageColors.GeneralColor,
        State.Data.MessageColors.ScoreColor,
        State.Data.ARC_COLOR .. zo_iconTextFormat(ICONS.Arc, 20, 20, "Arc: 2", true) .. "|r",
        State.Data.CYCLE_COLOR .. zo_iconTextFormat(ICONS.Cycle, 20, 20, "Cycle: 3", true) .. "|r",
        State.Data.STAGE_COLOR .. zo_iconTextFormat(ICONS.Stage, 20, 20, "Stage: 3", true) .. "|r",
        ratingExampleIcon2
    )
    
    -- Own score example
    local ownScoreExample = string.format(
        "|c%sYou|r (|c%s%s|r)|c%s completed|r%s|c%sSanity's Edge|r |c%swith a score of|r |c%s220,000|r - %s|c00FF00Outstanding|r", 
        State.Data.MessageColors.GeneralColor,
        State.Data.MessageColors.PlayersColor,
        GetUnitName("player"),
        State.Data.MessageColors.GeneralColor,
        raidExampleIcon, 
        State.Data.MessageColors.ContentColor,
        State.Data.MessageColors.GeneralColor,
        State.Data.MessageColors.ScoreColor,
        ratingExampleIcon
    )
    
    -- Set the examples to the labels
    customControl.labels[1]:SetText(trialExample)
    customControl.labels[2]:SetText(archiveExample)
    customControl.labels[3]:SetText(ownScoreExample)
end

function SettingsSystem.Register()
    if not LAM2 then
        local message = string.format("%s requires LibAddonMenu2 to display settings", CONFIG.NAME)
        CHAT_ROUTER:AddSystemMessage(message)
        return
    end

    local panelId = "L2CSettingsPanel"
    
    LAM2:RegisterAddonPanel(panelId, {
        type = "panel",
        name = CONFIG.LONG_NAME,
        displayName = CONFIG.LONG_NAME,
        author = CONFIG.AUTHOR,
        version = CONFIG.VERSION,
        donation = SettingsSystem.Donation,
        slashCommand = "/l2c",
        registerForRefresh = true,
        registerForDefaults = true,
    })

    local options = {
        {
            type = "checkbox",
            name = "Display Leaderboard Scores in Chat",
            tooltip = "Show trial/arena/dungeon leaderboard scores in chat instead of using the default notification system",
            getFunc = function() return State.SVAR.PrintToChat end,
            setFunc = function(enabled) 
                State.SVAR.PrintToChat = enabled
                State.Data.RNToChat = enabled
            end,
            default = DEFAULT_SETTINGS.PrintToChat,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Include Your Own Scores",
            tooltip = "Show notifications for your own achievements alongside those of friends and guildmates",
            getFunc = function() return State.SVAR.ShowOwnScores end,
            setFunc = function(enabled) 
                State.SVAR.ShowOwnScores = enabled
                State.Data.ShowOwnScores = enabled
            end,
            default = DEFAULT_SETTINGS.ShowOwnScores,
            disabled = function() return not State.Data.RNToChat end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Include Infinite Archive Scores",
            tooltip = "Show Infinite Archive leaderboard achievements in chat",
            getFunc = function() return State.SVAR.ShowIAScores end,
            setFunc = function(enabled) 
                State.SVAR.ShowIAScores = enabled
                State.Data.RNEndless = enabled
            end,
            default = DEFAULT_SETTINGS.ShowIAScores,
            disabled = function() return not State.Data.RNToChat end,
            width = "half",
        }, 
        {
            type = "checkbox",
            name = "Show Performance Ratings",
            tooltip = "Display achievement ratings (Outstanding, Excellent, etc.) based on score thresholds",
            getFunc = function() return State.SVAR.ShowScores end,
            setFunc = function(enabled) 
                State.SVAR.ShowScores = enabled
                State.Data.ShowScore = enabled
            end,
            default = DEFAULT_SETTINGS.ShowScores,
            disabled = function() return not State.Data.RNToChat end,
            width = "half",
        },


        {
            type = "button",
            name = "Edit Score Thresholds",
            tooltip = "Open the threshold editor to customize rating thresholds for trials, arenas, and Infinite Archive",
            func = function() ThresholdEditor.Show() end,
            disabled = function() return not State.Data.RNToChat end,
            width = "half",
        }

    }
    
    -- Add guild filter controls
    local guildControls = SettingsSystem.CreateGuildFilterControls()
    for _, control in ipairs(guildControls) do
        table.insert(options, control)
    end
    
    -- Add message appearance controls
    table.insert(options, {
        type = "header",
        name = "Message Appearance",
        tooltip = "Customize the colors used in notification messages",
    })
    
    -- Add color picker controls
    local colorOptions = {
        {
            name = "Score Color",
            tooltip = "Color used for the score value (default: gold)",
            setting = "ScoreColor"
        },
        {
            name = "Content Name Color",
            tooltip = "Color used for trial/arena/dungeon names (default: white)",
            setting = "ContentColor"
        },
        {
            name = "General Text Color",
            tooltip = "Color used for 'You', 'Your friend', 'completed', etc. (default: yellow)",
            setting = "GeneralColor"
        },
        {
            name = "Player Names Color",
            tooltip = "Color used for player names in the group list (default: white)",
            setting = "PlayersColor"
        }
    }
    
    for _, option in ipairs(colorOptions) do
        table.insert(options, {
            type = "colorpicker",
            name = option.name,
            tooltip = option.tooltip,
            getFunc = function() 
                return UtilitySystem.HexToRGBA(State.SVAR.MessageColors[option.setting])
            end,
            setFunc = function(r, g, b, a) 
                State.SVAR.MessageColors[option.setting] = UtilitySystem.RGBToHex(r, g, b)
                State.Data.MessageColors[option.setting] = State.SVAR.MessageColors[option.setting]
                -- Refresh the examples
                local control = WINDOW_MANAGER:GetControlByName("L2CMessageExamples")
                if control then
                    SettingsSystem.UpdateExampleMessages(control)
                end
            end,
            default = function()
                local r, g, b, a = UtilitySystem.HexToRGBA(DEFAULT_SETTINGS.MessageColors[option.setting])
                return {r = r, g = g, b = b, a = a}
            end,
            disabled = function() return not State.Data.RNToChat end,
            width = "half",
        })
    end
    
    -- Add message examples
    local exampleControls = SettingsSystem.CreateMessageExamplesControl()
    for _, control in ipairs(exampleControls) do
        table.insert(options, control)
    end

    LAM2:RegisterOptionControls(panelId, options)
end

-- Event Handlers
local EventHandlers = {}

function EventHandlers.OnGuildMemberEvent()
    GuildSystem.RebuildMemberCache()
end

function EventHandlers.OnPlayerActivated()
    local timeSinceLastUpdate = GetGameTimeMilliseconds() - Cache.guildCacheLastUpdateTime
    if timeSinceLastUpdate > 60000 then
        GuildSystem.RebuildMemberCache()
    end
end

-- Initialization
local function Initialize()
    State.SVAR = ZO_SavedVars:NewAccountWide("Leaderboard2Chat_SV", CONFIG.SVAR_VERSION, nil, DEFAULT_SETTINGS, GetWorldName())
    
    -- Load settings into State.Data
    State.Data.isDisabled = true
    State.Data.RNToChat = State.SVAR.PrintToChat
    State.Data.RNEndless = State.SVAR.ShowIAScores
    State.Data.ShowScore = State.SVAR.ShowScores
    State.Data.ShowOwnScores = State.SVAR.ShowOwnScores
    
    if not State.SVAR.GuildFilter then
        State.SVAR.GuildFilter = {[1] = true, [2] = true, [3] = true, [4] = true, [5] = true}
    end
    State.Data.GuildFilter = State.SVAR.GuildFilter

    if not State.SVAR.MessageColors then
        State.SVAR.MessageColors = {
            ScoreColor = "E5C100",
            ContentColor = "FFFFFF",
            GeneralColor = "FFFF00",
            PlayersColor = "FFFFFF"
        }
    end
    State.Data.MessageColors = State.SVAR.MessageColors
    
    -- Ensure ScoreRatings exist in saved variables
    if not State.SVAR.ScoreRatings then
        State.SVAR.ScoreRatings = ZO_DeepTableCopy(DEFAULT_SETTINGS.ScoreRatings)
    end

    -- Initialize dialogs
    InitializeDialogs()
    InitializeRemoveDialog()

    -- Build initial guild member cache
    GuildSystem.RebuildMemberCache()

    -- Register events
    EVENT_MANAGER:RegisterForEvent(CONFIG.NAME .. "_GuildUpdate", EVENT_GUILD_MEMBER_ADDED, EventHandlers.OnGuildMemberEvent)
    EVENT_MANAGER:RegisterForEvent(CONFIG.NAME .. "_GuildUpdate", EVENT_GUILD_MEMBER_REMOVED, EventHandlers.OnGuildMemberEvent)
    EVENT_MANAGER:RegisterForEvent(CONFIG.NAME .. "_PlayerGuildUpdate", EVENT_GUILD_SELF_JOINED_GUILD, GuildSystem.RebuildMemberCache)
    EVENT_MANAGER:RegisterForEvent(CONFIG.NAME .. "_PlayerGuildUpdate", EVENT_GUILD_SELF_LEFT_GUILD, GuildSystem.RebuildMemberCache)
    EVENT_MANAGER:RegisterForEvent(CONFIG.NAME .. "_ZoneChanged", EVENT_PLAYER_ACTIVATED, EventHandlers.OnPlayerActivated)
    
    ZO_PreHook(ZO_LeaderboardScoreProvider, "BuildNotificationList", NotificationSystem.BuildNotificationList_Hook)
    
    SettingsSystem.Register()

    State.isInitialized = true
    return true
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= CONFIG.NAME then return end
    EVENT_MANAGER:UnregisterForEvent(CONFIG.NAME, EVENT_ADD_ON_LOADED)
    Initialize()
end

EVENT_MANAGER:RegisterForEvent(CONFIG.NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)