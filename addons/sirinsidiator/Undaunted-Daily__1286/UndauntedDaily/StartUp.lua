local ADDON_NAME = "UndauntedDaily"
UndauntedDaily = {}

local nextEventHandleIndex = 1

local function RegisterForEvent(event, callback)
    local eventHandleName = ADDON_NAME .. nextEventHandleIndex
    EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
    nextEventHandleIndex = nextEventHandleIndex + 1
    return eventHandleName
end

local function UnregisterForEvent(event, name)
    EVENT_MANAGER:UnregisterForEvent(name, event)
end

local function WrapFunction(object, functionName, wrapper)
    if (type(object) == "string") then
        wrapper = functionName
        functionName = object
        object = _G
    end
    local originalFunction = object[functionName]
    object[functionName] = function(...) return wrapper(originalFunction, ...) end
end

local function OnAddonLoaded(callback)
    local eventHandle = ""
    eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
        if (name ~= ADDON_NAME) then return end
        callback()
        UnregisterForEvent(event, name)
    end)
end

local Dungeon = ZO_InitializingObject:Subclass()

function Dungeon:Initialize(normalId, veteranId)
    self.normalId = normalId
    self.veteranId = veteranId
    local _, index = GetActivityTypeAndIndex(normalId)
    self.name = GetActivityName(normalId)
    self.index = index
end

function Dungeon:GetNormalId()
    return self.normalId
end

function Dungeon:GetVeteranId()
    return self.veteranId
end

function Dungeon:GetName()
    return self.name
end

OnAddonLoaded(function()
    ---@type table<string, Dungeon>
    local DUNGEONS = {}
    DUNGEONS.ARX_CORINIUM = Dungeon:New(8, 305)
    DUNGEONS.BAL_SUNNAR = Dungeon:New(613, 614)
    DUNGEONS.BEDLAM_VEIL = Dungeon:New(640, 641)
    DUNGEONS.BLACK_DRAKE_VILLA = Dungeon:New(591, 592)
    DUNGEONS.BLACKHEART_HAVEN = Dungeon:New(15, 321)
    DUNGEONS.BLESSED_CRUCIBLE = Dungeon:New(14, 320)
    DUNGEONS.BLOODROOT_FORGE = Dungeon:New(324, 325)
    DUNGEONS.CASTLE_THORN = Dungeon:New(509, 510)
    DUNGEONS.CITY_OF_ASH_I = Dungeon:New(10, 310)
    DUNGEONS.CITY_OF_ASH_II = Dungeon:New(322, 267)
    DUNGEONS.CORAL_AERIE = Dungeon:New(599, 600)
    DUNGEONS.CRADLE_OF_SHADOWS = Dungeon:New(295, 296)
    DUNGEONS.CRYPT_OF_HEARTS_I = Dungeon:New(9, 261)
    DUNGEONS.CRYPT_OF_HEARTS_II = Dungeon:New(317, 318)
    DUNGEONS.DARKSHADE_CAVERNS_I = Dungeon:New(5, 309)
    DUNGEONS.DARKSHADE_CAVERNS_II = Dungeon:New(308, 21)
    DUNGEONS.DEPTHS_OF_MALATAR = Dungeon:New(435, 436)
    DUNGEONS.DIREFROST_KEEP = Dungeon:New(11, 319)
    DUNGEONS.EARTHEN_ROOT_ENCLAVE = Dungeon:New(608, 609)
    DUNGEONS.ELDEN_HOLLOW_I = Dungeon:New(7, 23)
    DUNGEONS.ELDEN_HOLLOW_II = Dungeon:New(303, 302)
    DUNGEONS.EXILED_REDOUBT = Dungeon:New(855, 856)
    DUNGEONS.FALKREATH_HOLD = Dungeon:New(368, 369)
    DUNGEONS.FANG_LAIR = Dungeon:New(420, 421)
    DUNGEONS.FROSTVAULT = Dungeon:New(433, 434)
    DUNGEONS.FUNGAL_GROTTO_I = Dungeon:New(2, 299)
    DUNGEONS.FUNGAL_GROTTO_II = Dungeon:New(18, 312)
    DUNGEONS.GRAVEN_DEEP = Dungeon:New(610, 611)
    DUNGEONS.ICEREACH = Dungeon:New(503, 504)
    DUNGEONS.IMPERIAL_CITY_PRISON = Dungeon:New(289, 268)
    DUNGEONS.LAIR_OF_MAARSELOK = Dungeon:New(496, 497)
    DUNGEONS.LEP_SECLUSA = Dungeon:New(857, 858)
    DUNGEONS.MARCH_OF_SACRIFICES = Dungeon:New(428, 429)
    DUNGEONS.MOON_HUNTER_KEEP = Dungeon:New(426, 427)
    DUNGEONS.MOONGRAVE_FANE = Dungeon:New(494, 495)
    DUNGEONS.OATHSWORN_PIT = Dungeon:New(638, 639)
    DUNGEONS.RED_PETAL_BASTION = Dungeon:New(595, 596)
    DUNGEONS.RUINS_OF_MAZZATUN = Dungeon:New(293, 294)
    DUNGEONS.SCALECALLER_PEAK = Dungeon:New(418, 419)
    DUNGEONS.SCRIVENERS_HALL = Dungeon:New(615, 616)
    DUNGEONS.SELENES_WEB = Dungeon:New(16, 313)
    DUNGEONS.SHIPWRIGHTS_REGRET = Dungeon:New(601, 602)
    DUNGEONS.SPINDLECLUTCH_I = Dungeon:New(3, 315)
    DUNGEONS.SPINDLECLUTCH_II = Dungeon:New(316, 19)
    DUNGEONS.STONE_GARDEN = Dungeon:New(507, 508)
    DUNGEONS.TEMPEST_ISLAND = Dungeon:New(13, 311)
    DUNGEONS.THE_BANISHED_CELLS_I = Dungeon:New(4, 20)
    DUNGEONS.THE_BANISHED_CELLS_II = Dungeon:New(300, 301)
    DUNGEONS.THE_CAULDRON = Dungeon:New(593, 594)
    DUNGEONS.THE_DREAD_CELLAR = Dungeon:New(597, 598)
    DUNGEONS.UNHALLOWED_GRAVE = Dungeon:New(505, 506)
    DUNGEONS.VAULTS_OF_MADNESS = Dungeon:New(17, 314)
    DUNGEONS.VOLENFELL = Dungeon:New(12, 304)
    DUNGEONS.WAYREST_SEWERS_I = Dungeon:New(6, 306)
    DUNGEONS.WAYREST_SEWERS_II = Dungeon:New(22, 307)
    DUNGEONS.WHITEGOLD_TOWER = Dungeon:New(288, 287)

    local DUNGEON_BY_ACTIVITY_ID = {}
    for key, dungeon in pairs(DUNGEONS) do
        DUNGEON_BY_ACTIVITY_ID[dungeon:GetNormalId()] = dungeon
        DUNGEON_BY_ACTIVITY_ID[dungeon:GetVeteranId()] = dungeon
    end

    local SECONDS_PER_DAY = 24 * 3600
    -- 2016-07-22: Spindleclutch II / Direfrost Keep / Ruins of Mazzatun
    local startTime = 1473033600 + (GetTimeStamp() + GetTimeUntilNextDailyLoginRewardClaimS()) % SECONDS_PER_DAY

    local PLEDGE_DATA = {
        { -- dungeon set A: Maj al-Ragath
            cycle = {
                DUNGEONS.SPINDLECLUTCH_II,
                DUNGEONS.THE_BANISHED_CELLS_I,
                DUNGEONS.FUNGAL_GROTTO_II,
                DUNGEONS.SPINDLECLUTCH_I,
                DUNGEONS.DARKSHADE_CAVERNS_II,
                DUNGEONS.ELDEN_HOLLOW_I,
                DUNGEONS.WAYREST_SEWERS_II,
                DUNGEONS.FUNGAL_GROTTO_I,
                DUNGEONS.THE_BANISHED_CELLS_II,
                DUNGEONS.DARKSHADE_CAVERNS_I,
                DUNGEONS.ELDEN_HOLLOW_II,
                DUNGEONS.WAYREST_SEWERS_I
            },
            offset = 0
        },
        { -- dungeon set B: Gilirion the Redbeard
            cycle = {
                DUNGEONS.DIREFROST_KEEP,
                DUNGEONS.VAULTS_OF_MADNESS,
                DUNGEONS.CRYPT_OF_HEARTS_II,
                DUNGEONS.CITY_OF_ASH_I,
                DUNGEONS.TEMPEST_ISLAND,
                DUNGEONS.BLACKHEART_HAVEN,
                DUNGEONS.ARX_CORINIUM,
                DUNGEONS.SELENES_WEB,
                DUNGEONS.CITY_OF_ASH_II,
                DUNGEONS.CRYPT_OF_HEARTS_I,
                DUNGEONS.VOLENFELL,
                DUNGEONS.BLESSED_CRUCIBLE
            },
            offset = 0
        },
        { -- dlc dungeons: Urgalarg Chief-bane
            cycle = {
                DUNGEONS.IMPERIAL_CITY_PRISON,
                DUNGEONS.RUINS_OF_MAZZATUN,
                DUNGEONS.WHITEGOLD_TOWER,
                DUNGEONS.CRADLE_OF_SHADOWS,
                DUNGEONS.BLOODROOT_FORGE,
                DUNGEONS.FALKREATH_HOLD,
                DUNGEONS.FANG_LAIR,
                DUNGEONS.SCALECALLER_PEAK,
                DUNGEONS.MOON_HUNTER_KEEP,
                DUNGEONS.MARCH_OF_SACRIFICES,
                DUNGEONS.DEPTHS_OF_MALATAR,
                DUNGEONS.FROSTVAULT,
                DUNGEONS.MOONGRAVE_FANE,
                DUNGEONS.LAIR_OF_MAARSELOK,
                DUNGEONS.ICEREACH,
                DUNGEONS.UNHALLOWED_GRAVE,
                DUNGEONS.STONE_GARDEN,
                DUNGEONS.CASTLE_THORN,
                DUNGEONS.BLACK_DRAKE_VILLA,
                DUNGEONS.THE_CAULDRON,
                DUNGEONS.RED_PETAL_BASTION,
                DUNGEONS.THE_DREAD_CELLAR,
                DUNGEONS.CORAL_AERIE,
                DUNGEONS.SHIPWRIGHTS_REGRET,
                DUNGEONS.EARTHEN_ROOT_ENCLAVE,
                DUNGEONS.GRAVEN_DEEP,
                DUNGEONS.BAL_SUNNAR,
                DUNGEONS.SCRIVENERS_HALL,
                DUNGEONS.OATHSWORN_PIT,
                DUNGEONS.BEDLAM_VEIL,
                DUNGEONS.EXILED_REDOUBT,
                DUNGEONS.LEP_SECLUSA
            },
            offset = -7 -- new dungeons always seem to be added before ICP, so we simply add them to the end and modify the offset
        },
        startTime = startTime
    }

    local localization = {
        en = {
            DUNGEONS = "<<1>>, <<2>> and <<3>>",
            PAST = "The undaunted pledges <<3>> days ago (<<X:1>>) were <<2>>.",
            YESTERDAY = "Yesterday's undaunted pledges (<<X:1>>) were <<2>>.",
            TODAY = "Today's undaunted pledges (<<X:1>>, <<5>> left) are <<2>>.",
            TOMORROW = "Tomorrow's undaunted pledges (<<X:1>>, available in <<4>>) will be <<2>>.",
            FUTURE = "The undaunted pledges <<3>> days from now (<<X:1>>) will be <<2>>.",
            NOINFO = "No information about the undaunted pledges from <<3>> days ago available.",
            PLEDGE_COMMAND_DESCRIPTION = "Shows the undaunted pledges",
            SEND_COMMAND_DESCRIPTION = "Places the pledges for sending",
            UDLIST_COMMAND_DESCRIPTION = "Internal UndauntedDaily command",
        },
        de = {
            DUNGEONS = "<<1>>, <<2>> und <<3>>",
            PAST = "Die Unerschrockenen Gelöbnisse von vor <<3>> Tagen (<<X:1>>) waren <<2>>.",
            YESTERDAY = "Die Unerschrockenen Gelöbnisse von gestern (<<X:1>>) waren <<2>>.",
            TODAY = "Die Unerschrockenen Gelöbnisse von heute (<<X:1>>, <<5>> verbleibend) sind <<2>>.",
            TOMORROW = "Die Unerschrockenen Gelöbnisse von morgen (<<X:1>>, verfügbar in <<4>>) werden <<2>> sein.",
            FUTURE = "Die Unerschrockenen Gelöbnisse <<3>> Tage von heute (<<X:1>>) werden <<2>> sein.",
            NOINFO = "Keine Informationen über die Unerschrockenen Gelöbnisse von vor <<3>> Tagen verfügbar.",
            PLEDGE_COMMAND_DESCRIPTION = "Zeigt die Unerschrockenen Gelöbnisse",
            SEND_COMMAND_DESCRIPTION = "Plaziert die Gelöbnisse zum Senden",
            UDLIST_COMMAND_DESCRIPTION = "Interner UndauntedDaily Befehl",
        },
        fr = { -- provided by Ayantir
            DUNGEONS = "<<1>>, <<2>> et <<3>>",
            PAST = "Les donjons indomptables d'il y a <<3>> jours (<<X:1>>) étaient <<2>>.",
            YESTERDAY = "Les donjons indomptables d'hier (<<X:1>>) étaient <<2>>.",
            TODAY = "Les donjons indomptables d'aujourd'hui (<<X:1>>, <<5>> restantes) sont <<2>>.",
            TOMORROW = "Les donjons indomptables de demain (<<X:1>>, disponibles dans <<4>>) seront <<2>>.",
            FUTURE = "Les donjons indomptables dans <<3>> jours (<<X:1>>) seront <<2>>.",
            NOINFO = "Aucune information disponible sur les donjons indomptables d'il y a <<3>> jours",
            PLEDGE_COMMAND_DESCRIPTION = "Afficher les donjons indomptables",
            SEND_COMMAND_DESCRIPTION = "Afficher dans le Chat",
            UDLIST_COMMAND_DESCRIPTION = "Commande UndauntedDaily interne",
        },
        ru = { -- provided by Fellorion
            DUNGEONS = "<<1>>, <<2>> и <<3>>",
            PAST = "Обеты Неустрашимых <<3>> д. назад (<<X:1>>): <<2>>",
            YESTERDAY = "Обеты Неустрашимых вчера (<<X:1>>): <<2>>.",
            TODAY = "Обеты Неустрашимых сегодня (<<X:1>>, <<5>> осталось): <<2>>.",
            TOMORROW = "Обеты Неустрашимых завтра (<<X:1>>, доступны через <<4>>): <<2>>.",
            FUTURE = "Обеты Неустрашимых через <<3>> д. (<<X:1>>): <<2>>.",
            NOINFO = "Обеты Неустрашимых за <<3>> д. до этого недоступны.",
            PLEDGE_COMMAND_DESCRIPTION = "Показать обеты Неустрашимых",
            SEND_COMMAND_DESCRIPTION = "Поместить обеты в чат для отправки",
            UDLIST_COMMAND_DESCRIPTION = "Внутренняя комманда UndauntedDaily",
        },
    }

    local language = GetCVar("language.2")
    local L = localization[language] or {}
    if (language ~= "en") then
        setmetatable(L, { __index = localization["en"] })
    end

    local function CalculateTimeBetween(startTime, endTime)
        return math.abs(GetDiffBetweenTimeStamps(startTime, endTime))
    end

    local function FormatTime(time) -- formats as 11h 11m, strips seconds when over 1 minute
        return ZO_FormatTime(time, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR):gsub(
        "m.-$", "m")
    end

    ---@param dayOffset? number
    ---@return string
    local function GetFormatString(dayOffset)
        if (not dayOffset) then
            return L["NOINFO"]
        elseif (dayOffset < -1) then
            return L["PAST"]
        elseif (dayOffset == -1) then
            return L["YESTERDAY"]
        elseif (dayOffset == 0) then
            return L["TODAY"]
        elseif (dayOffset == 1) then
            return L["TOMORROW"]
        elseif (dayOffset > 1) then
            return L["FUTURE"]
        end
        return "" -- never reached, but makes the linter happy
    end

    local function GetTimeData(dayOffset)
        local now = GetTimeStamp()
        local diff = math.floor(GetDiffBetweenTimeStamps(now, startTime) / SECONDS_PER_DAY)
        local currentStartTime = startTime + diff * SECONDS_PER_DAY
        dayOffset = tonumber(dayOffset)

        if (dayOffset) then
            diff = diff + dayOffset
        else
            dayOffset = 0
        end

        return diff, dayOffset, currentStartTime, now
    end

    local function GetDungeon(setIndex, diff)
        local pledgeData = PLEDGE_DATA[setIndex]
        local pledgeCycle = pledgeData.cycle
        local cycleIndex = 1 + (pledgeData.offset + diff) % #pledgeCycle
        return pledgeCycle[cycleIndex]
    end

    ---@param dayOffset integer - optionally how many days to look into the future (positive) or past (negative).
    ---@return table dungeons - a numerically indexed table with the dungeon objects (one from each set)
    local function GetPledgeDungeons(dayOffset)
        local dungeons = {}
        local diff = GetTimeData(dayOffset)
        for i = 1, #PLEDGE_DATA do
            dungeons[i] = GetDungeon(i, diff)
        end
        return dungeons
    end

    ---@param dayOffset integer - optionally how many days to look into the future (positive) or past (negative).
    ---@return table pledgeData - a table with all parts that flow into the pledge string, including the formatted pledge string itself
    local function GetPledgeData(dayOffset)
        local diff, dayOffset, currentStartTime, now = GetTimeData(dayOffset)

        local dayOffsetAbs = math.abs(dayOffset)
        ---@type number|nil
        local effectiveDayOffset = dayOffset
        if (currentStartTime < startTime) then
            effectiveDayOffset = nil
        end
        local dateString = FormatAchievementLinkTimestamp(currentStartTime)
        local timeToStart = CalculateTimeBetween(now, currentStartTime)
        local timeToStartString = FormatTime(timeToStart)
        local timeToEnd = CalculateTimeBetween(now, currentStartTime + SECONDS_PER_DAY)
        local timeToEndString = FormatTime(timeToEnd)

        local indices = {}
        local dungeons = {}
        local dungeonNames = {}
        for i = 1, #PLEDGE_DATA do
            local dungeon = GetDungeon(i, diff)
            indices[i] = dungeon.index
            dungeons[i] = dungeon
            dungeonNames[i] = dungeon:GetName()
        end
        local dungeonFormat = L["DUNGEONS"]
        local dungeonString = zo_strformat(dungeonFormat, unpack(dungeonNames))
        local pledgeFormat = GetFormatString(effectiveDayOffset)

        return {
            diff = diff,
            dayOffset = dayOffset,
            dayOffsetAbs = dayOffsetAbs,
            effectiveDayOffset = effectiveDayOffset,
            currentStartTime = currentStartTime,
            now = now,
            timeToStart = timeToStart,
            timeToEnd = timeToEnd,
            indices = indices,
            dungeons = dungeons,
            dungeonNames = dungeonNames,
            dateString = dateString,
            timeToStartString = timeToStartString,
            timeToEndString = timeToEndString,
            dungeonFormat = dungeonFormat,
            dungeonString = dungeonString,
            pledgeFormat = pledgeFormat,
            pledgeString = zo_strformat(pledgeFormat, dateString, dungeonString, dayOffsetAbs, timeToStartString,
                timeToEndString)
        }
    end

    local LSC = LibSlashCommander
    local chat = LibChatMessage(ADDON_NAME, "UD")
    LSC:Register({ "/undaunted", "/pledges", "/dungeons" }, function(dayOffset)
        chat:Print(GetPledgeData(dayOffset).pledgeString)
    end, L["PLEDGE_COMMAND_DESCRIPTION"])

    LSC:Register({ "/undaunted2chat", "/pledges2chat", "/dungeons2chat" }, function(dayOffset)
        local text = GetPledgeData(dayOffset).pledgeString
        LSC.SafeStartChatInput(text)
    end, L["SEND_COMMAND_DESCRIPTION"])

    local function FetchAllDungeons(map, type, key)
        for i = 1, GetNumActivitiesByType(type) do
            local activityId = GetActivityIdByTypeAndIndex(type, i)
            local name = GetActivityName(activityId)
            map[name] = map[name] or {}
            map[name][key] = activityId
        end
    end

    LSC:Register("/udlist", function() -- for getting ids of new dungeons
        local map = {}
        FetchAllDungeons(map, LFG_ACTIVITY_DUNGEON, "normal")
        FetchAllDungeons(map, LFG_ACTIVITY_MASTER_DUNGEON, "veteran")

        local output = {}
        for name, entry in pairs(map) do
            local key = name:upper():gsub(" ", "_"):gsub("[-']", "")
            output[#output + 1] = string.format("DUNGEONS.%s = Dungeon:New(%d, %d)", key, entry.normal, entry.veteran)
        end
        table.sort(output)

        chat:Printf("local DUNGEONS = {}\n%s", table.concat(output, "\n"))
    end, L["UDLIST_COMMAND_DESCRIPTION"])

    -- expose things for other addons to use

    UndauntedDaily.GetPledgeDungeons = GetPledgeDungeons
    UndauntedDaily.GetPledgeData = GetPledgeData

    --- The raw data. Please make sure you only read from it and never modify it!
    UndauntedDaily.DUNGEONS = DUNGEONS
    UndauntedDaily.DUNGEON_BY_ACTIVITY_ID = DUNGEON_BY_ACTIVITY_ID
    UndauntedDaily.PLEDGE_DATA = PLEDGE_DATA
    UndauntedDaily.localization = localization
    UndauntedDaily.L = L

    -- deprecated functions - just for backwards compatibility

    ---@param dayOffset integer - optionally how many days to look into the future (positive) or past (negative).
    ---@return table indices - a numerically indexed table with the dungeon indices (one from each set)
    UndauntedDaily.GetPledgeDungeonIndices = function(dayOffset)
        local dungeons = GetPledgeDungeons(dayOffset)
        for i = 1, #dungeons do
            dungeons[i] = dungeons[i].index
        end
        return dungeons
    end

    ---@param dungeonIndex integer - the index of a dungeon
    ---@return string|nil dungeonName - the localized name of the dungeon as returned by the game
    UndauntedDaily.GetDungeonName = function(dungeonIndex)
        local activityId = GetActivityIdByTypeAndIndex(LFG_ACTIVITY_DUNGEON, dungeonIndex)
        local dungeon = DUNGEON_BY_ACTIVITY_ID[activityId]
        if dungeon then
            return dungeon:GetName()
        end
        return nil
    end
end)
